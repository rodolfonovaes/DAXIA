#INCLUDE "RWMAKE.CH"   
#INCLUDE "MATA410.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"       
#INCLUDE "FWADAPTEREAI.CH"     
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CRMDEF.CH"
#INCLUDE "FWLIBVERSION.CH"

//????????????????????
//?efine para tratamento do IVA Ajustado?      
//????????????????????
#DEFINE __UFORI  01
#DEFINE __ALQORI 02
#DEFINE __PROPOR 03

#DEFINE SMMARCA	   1
#DEFINE SMCODTRAN  2
#DEFINE SMNOMETRAN 3
#DEFINE SMVALOR    4
#DEFINE SMPRAZO    5

#DEFINE SMNUMCALC	6	
#DEFINE SMCLASSFRE 	7
#DEFINE SMTIPOPER  	8
#DEFINE SMTRECHO   	9
#DEFINE SMTABELA  	10
#DEFINE SMNUMNEGOC 	11
#DEFINE SMROTA     	12
#DEFINE SMDATVALID 	13
#DEFINE SMFAIXA    	14
#DEFINE SMTIPOVEI	15       
#DEFINE SMEXISTMP	16                        

Static aFreteP	:= {}    
//--------------------------------------------------------------
/*/{Protheus.doc} A410SMLFRT
Simula?o basica de Calculo de frete
                                                                
@return xRet Return Description
@author  -                                               
@since 22/02/2012                                                   
/*/
//--------------------------------------------------------------
User Function DxSimula()

Local aArea 		:= GetArea()
Local oModelSim  	:= FWLoadModel("GFEX010")
Local oModelNeg  	:= oModelSim:GetModel("GFEX010_01")
Local oModelAgr  	:= oModelSim:GetModel("DETAIL_01")  // oModel do grid "Agrupadores"
Local oModelDC   	:= oModelSim:GetModel("DETAIL_02")  // oModel do grid "Doc Carga"
Local oModelIt   	:= oModelSim:GetModel("DETAIL_03")  // oModel do grid "Item Carga"
Local oModelTr   	:= oModelSim:GetModel("DETAIL_04")  // oModel do grid "Trechos"
Local oModelInt  	:= oModelSim:GetModel("SIMULA")     // oModel do field que dispara a simula?o
Local oModelCal1 	:= oModelSim:GetModel("DETAIL_05")  // oModel do calculo do frete
Local oModelCal2 	:= oModelSim:GetModel("DETAIL_06")  // oModel das informa?es complemetares do calculo
Local nCont      	:= 0
Local nRegua 		:= 0                   
Local cCdClFr		:= Space(TamSX3("GWN_CDCLFR")[1]) //-- simulacao de frete: considerar todas a negociacoes cadastradas no GFE ou a selecionada pelo campo GWN_CDCLFR.
Local cTpOp			:= Space(TamSX3("GWN_CDTPOP")[1]) //-- simulacao de frete: considerar todas a negociacoes cadastradas no GFE ou a selecionada pelo campo GWN_CDTPOP.
Local cTpVc			:= Space(TamSX3("GWN_CDTPVC")[1]) //-- simulacao de frete: considerar todas a negociacoes cadastradas no GFE ou a selecionada pelo campo GWN_CDTPVC.
Local cTpDoc		:= ''
Local nLenAcols		:= 0
Local nItem			:= 0
Local nPProduto		:= aScan(aHeader,{|x| AllTrim(x[2])=="CK_PRODUTO"})
Local nPQtdVen		:= aScan(aHeader,{|x| AllTrim(x[2])=="CK_QTDVEN"})
Local nPValor		:= aScan(aHeader,{|x| AllTrim(x[2])=="CK_VALOR"})
Local nX			:= 0
Local cCGCTran		:= ''                                        
Local nVlrFrt		:= 0
Local nPrevEnt		:= 0
Local aRet			:= {}
Local nNumCalc		:= 0
Local nClassFret	:= 0
Local nTipOper		:= 0
Local cTrecho		:= ""
Local cTabela		:= ""
Local cNumNegoc		:= ""
Local cRota			:= ""
Local dDatValid		:= ""
Local cFaixa		:= ""
Local cTipoVei		:= ""
Local cCgc := ''
Local nAltura		:= 0
Local nVolume		:= 0
Local nRadio		:= 0
Local oRadio		:= Nil	
Local oDlg1			:= Nil
Local cCdEmis		:= ""
Local cCdRem		:= ""
Local cCdDest		:= ""
Local oCdClFr		:= Nil
Local oTpOp			:= Nil
Local oTpVc			:= Nil

If !Empty(M->CJ_CLIENTE) .And. !Empty(M->CJ_LOJA) .And. !Empty(TMP1->CK_PRODUTO) .And. !Empty(TMP1->CK_QTDVEN) .And. !Empty(TMP1->CK_VALOR)	.And. !("TMP1")->CK_FLAG 

	DEFINE MSDIALOG oDlg1 FROM	31,15 TO 240,285 TITLE STR0193 PIXEL OF oMainWnd //  "Simula?o de Frete"
	@ 005,005 SAY STR0356 PIXEL SIZE 160,160 Of oDlg1 //"Selecione a opera?o a ser consederada:"
	@ 020,005 RADIO oRadio VAR nRadio ITEMS STR0357,STR0358 SIZE 150,150 PIXEL OF oDlg1 //"1- Considera Tab.Frete em Negociacao","2- Considera apenas Tab.Frete Aprovadas"

	@ 045,005 TO 100, 100 LABEL "Informações do Frete"   PIXEL OF oDlg1	//##"Informa?es do Frete"  
	@ 057,010 SAY RetTitle("GWN_CDCLFR")	SIZE 40,10 PIXEL OF oDlg1
	@ 072,010 SAY RetTitle("GWN_CDTPOP")	SIZE 40,10 PIXEL OF oDlg1
	@ 087,010 SAY RetTitle("GWN_CDTPVC")	SIZE 40,10 PIXEL OF oDlg1
	@ 055,045 MSGET oCdClFr VAR cCdClFr	F3 'GUB' PICTURE PesqPict('GUB','GUB_CDCLFR') SIZE 50,10 PIXEL OF oDlg1 VALID GFEExistC("GUB",,AllTrim(cCdClFr),"GUB->GUB_SIT=='1'")
	@ 070,045 MSGET oTpOp	VAR cTpOp	F3 'GV4' PICTURE PesqPict('GV4','GV4_CDTPOP') SIZE 50,10 PIXEL OF oDlg1 VALID GFEExistC("GV4",,AllTrim(cTpOp),"GV4->GV4_SIT=='1'")
	@ 085,045 MSGET oTpVc	VAR cTpVc	F3 'GV3' PICTURE PesqPict('GV3','GV3_CDTPVC') SIZE 50,10 PIXEL OF oDlg1 VALID GFEExistC("GV3",,AllTrim(cTpVc),"GV3->GV3_SIT=='1'")

	DEFINE SBUTTON FROM 089,106 TYPE 1 ENABLE OF oDlg1 ACTION (oDlg1:End() )
	nRadio := 2
	ACTIVATE MSDIALOG oDlg1 CENTERED 
	ProcRegua(nRegua)      

	SA1->(dbSeek(xFilial("SA1")+M->CJ_CLIENTE+M->CJ_LOJA))	   
	
	//Verifica primeiro se existe a chave "NS" cadastrada, se n? busca a chave "N". Mesmo tratamento utilizado no OMSM011.
	cTpDoc	:= AllTrim(Posicione("SX5",1,xFilial("SX5")+"MQ"+M->CJ_TIPO+"S","X5_DESCRI"))
	If Empty(cTpDoc)
		cTpDoc := Posicione("SX5",1,xFilial("SX5")+"MQ"+M->CJ_TIPO,"X5_DESCRI")
	EndIf
	cCdEmis := OMSM011COD(,,,.T.,xFilial("SF2"))
	If SCJ->(ColumnPos("CJ_CLIENT")) > 0 .And. SCJ->(ColumnPos("CJ_LOJAENT")) > 0 .And. !Empty(M->CJ_CLIENT) .And. !Empty(M->CJ_LOJAENT)
		cCdRem 	:= OMSM011COD(M->CJ_CLIENT,M->CJ_LOJAENT,1)
		//Valida o remetente que ser?utilizado no Doc. de Carga, conforme o sentido configurado na rotina de Tipos de Documentos de Carga.
		If Posicione("GV5", 1, xFilial("GV5") + cTpDoc, "GV5_SENTID") == "2" .And. Posicione("GU3", 1, xFilial("GU3") + cCdRem, "GU3_EMFIL") == "2"
			Help(,, "GFECLIRET",,"O sentido (GV5_SENTID) do tipo de Documento: '"+Alltrim(cTpDoc)+"', está configurado como saida.",1,0,,,,,,{"Deverá ser informado no campo 'Cli. Retirada' (C5_CLIRET) um remetente do tipo filial (GU3_EMFIL)."})	
			Return Nil
		EndIf
	Else
		cCdRem 	:= cCdEmis
	EndIf

	cCdDest := IIF(MTA410ChkEmit(SA1->A1_CGC),SA1->A1_CGC, OMSM011COD(M->CJ_CLIENTE,M->CJ_LOJA,1,,) )
		
	oModelSim:SetOperation(3) //Seta como inclus?
	oModelSim:Activate() 			
	oModelNeg:LoadValue('CONSNEG' ,AllTrim(Str(nRadio))) // -- 1=Considera Tab.Frete em Negociacao; 2=Considera apenas Tab.Frete Aprovadas
	IncProc()
	//Agrupadores - N? obrigatorio
	oModelAgr:LoadValue('GWN_CDCLFR',AllTrim(cCdClFr))  //classifica?o de frete                                 
	oModelAgr:LoadValue('GWN_CDTPOP',AllTrim(cTpOp))    //tipo da opera?o
	oModelAgr:LoadValue('GWN_CDTPVC',AllTrim(cTpVc))  	//Tipo de veiculo
	oModelAgr:LoadValue('GWN_DOC'   ,"ROMANEIO"     )           
	//Documento de Carga
	oModelDC:LoadValue('GW1_EMISDC', cCdEmis) 	//codigo do emitente - chave
	oModelDC:LoadValue('GW1_NRDC'  , M->CJ_NUM  ) 	//numero da nota - chave
	oModelDC:LoadValue('GW1_CDTPDC', cTpDoc) 		// tipo do documento - chave
	oModelDC:LoadValue('GW1_CDREM' , cCdRem)  	//remetente
	oModelDC:LoadValue('GW1_CDDEST', cCdDest)   //destinatario

	oModelDC:LoadValue('GW1_TPFRET', "1")
	oModelDC:LoadValue('GW1_ICMSDC', "2")
	oModelDC:LoadValue('GW1_USO'   , "1")
	oModelDC:LoadValue('GW1_QTUNI' , 1)   

	//Trechos
	A410SetTrechos(oModelTr,cTpDoc,cCdEmis,cCdRem,cCdDest,Iif(Empty(SA1->A1_ESTE),SA1->A1_EST,SA1->A1_ESTE),Iif(Empty(SA1->A1_CODMUNE),SA1->A1_COD_MUN,SA1->A1_CODMUNE))

	//Itens								
    dbSelectArea("TMP1")
    dbGoTop()

    While !Eof()
		If !("TMP1")->CK_FLAG 	
			nItem += 1
			nAltura := Posicione("SB5",1,xFilial("SB5")+TMP1->CK_PRODUTO,"B5_ALTURA")
			nVolume := (nAltura * SB5->B5_LARG * SB5->B5_COMPR) * TMP1->CK_QTDVEN	
			SB1->(DbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1")+TMP1->CK_PRODUTO))
			//--VERIFICAR QUEST? DOS PRODUTOS
			oModelIt:LoadValue('GW8_EMISDC',cCdEmis)	//codigo do emitente - chave
			oModelIt:LoadValue('GW8_NRDC'  ,M->CJ_NUM  ) 	//numero da nota - chave
			oModelIt:LoadValue('GW8_CDTPDC',cTpDoc) 		// tipo do documento - chave
			oModelIt:LoadValue('GW8_ITEM'  , "ITEM"+ PADL((nItem),3,"0")  )        		//codigo do item    -
			oModelIt:LoadValue('GW8_DSITEM', "ITEM GENERICO  "	+ PADL((nItem),3,"0"))  	//descri?o do item -
			oModelIt:LoadValue('GW8_CDCLFR',cCdClFr)    										//classifica?o de frete
			oModelIt:LoadValue('GW8_VOLUME',nVolume) 											//Volume
			oModelIt:LoadValue('GW8_PESOR' ,TMP1->CK_QTDVEN * SB1->B1_PESBRU ) 		//peso real
			oModelIt:LoadValue('GW8_VALOR' ,TMP1->CK_VALOR )     						//valor do item
			oModelIt:LoadValue('GW8_QTDE'  ,TMP1->CK_QTDVEN )     						//valor do item
			oModelIt:LoadValue('GW8_TRIBP' ,"1" )
			oModelIt:AddLine(.T.)	
		EndIf
        TMP1->(DbSkip())
	EndDo   

  	// Dispara a simula?o
	oModelInt:SetValue("INTEGRA" ,"A") 	 
	IncProc()
	
	//Verifica se h?linhas no model do calculo, se n? h?linhas significa que a simula?o falhou
	If oModelCal1:GetQtdLine() > 1 .Or. !Empty( oModelCal1:GetValue('C1_NRCALC'  ,1) )
	   //Percorre o grid, cada linha corresponde a um calculo diferente
		For nCont := 1 to oModelCal1:GetQtdLine()
			oModelCal1:GoLine( nCont )                                 			

			nVlrFrt	 		:= oModelCal1:GetValue('C1_VALFRT'  ,nCont )       
			nPrevEnt  		:= oModelCal1:GetValue('C1_DTPREN'  ,nCont ) - ddatabase

			nNumCalc		:= oModelCal2:GetValue	("C2_NRCALC" ,1 )  //"N?ero C?culo"
			nClassFret		:= oModelCal2:GetValue	("C2_CDCLFR" ,1 )  //"Class Frete"
			nTipOper		:= oModelCal2:GetValue	("C2_CDTPOP" ,1 )  //"Tipo Opera?o"
			cTrecho			:= oModelCal2:GetValue	("C2_SEQ" ,1 )     //"Trecho"
			cCGCTran		:= oModelCal2:GetValue	("C2_CDEMIT" ,1 )  //"Emit Tabela"
			cTabela			:= oModelCal2:GetValue	("C2_NRTAB" ,1 )   //"Nr tabela "
			cNumNegoc		:= oModelCal2:GetValue	("C2_NRNEG" ,1 )   //"Nr Negoc"
			cRota			:= oModelCal2:GetValue	("C2_NRROTA" ,1 )  //"Rota"
			dDatValid		:= oModelCal2:GetValue	("C2_DTVAL" ,1 )   //"Data Validade"
			cFaixa			:= oModelCal2:GetValue	("C2_CDFXTV" ,1 )  //"Faixa"
			cTipoVei		:= oModelCal2:GetValue	("C2_CDTPVC" ,1 )  //"Tipo Ve?ulo"

			SA4->(dbSetOrder(3))
	     	If SA4->(dbSeek(xFilial("SA4")+cCGCTran))
				aAdd (aRet, {,SA4->A4_COD,SA4->A4_NOME,nVlrFrt,nPrevEnt,nNumCalc,nClassFret,nTipOper,cTrecho,cTabela,cNumNegoc,cRota,dDatValid,cFaixa,cTipoVei,.T.})			   
		 	Else
		 		cCGC := MTA410RetCGC(cCGCTran)
		 		If SA4->(dbSeek(xFilial("SA4")+cCGC))
		 			AADD (aRet, {,SA4->A4_COD,SA4->A4_NOME,nVlrFrt,nPrevEnt,nNumCalc,nClassFret,nTipOper,cTrecho,cTabela,cNumNegoc,cRota,dDatValid,cFaixa,cTipoVei,.T.})
		 		Else
		 			AADD (aRet, {,cCGCTran,STR0199,nVlrFrt,nPrevEnt,nNumCalc,nClassFret,nTipOper,cTrecho,cTabela,cNumNegoc,cRota,dDatValid,cFaixa,cTipoVei,.F.}) //--"Transportadora n? cadastrada no Microsiga Protheus!!!"
		 		EndIf
         	EndIf	
		Next nCont    
		
		// SIGAGFE - Ponto de Entrada para n? mostrar a Tela do Resultado da Simula?o de Frete
		If ExistBlock('MA410FRT')
			ExecBlock('MA410FRT',.F.,.F.,{aRet})
		Else
			a410RetSml(aRet)
		EndIf
		
	EndIf
ElseIf (M->CJ_TIPO $ "CIP")
	Aviso(STR0014,STR0317,{"OK"})	//"Atencao"##""A simula?o de frete n? ser?executada para os pedidos de Complemento de Pre?, ICMS e IPI, portanto n? haver?integra?o com o m?ulo SIGAGFE."
Else
	Help(" ",1,"A410SMLFRT")	//"Para a simula?o de frete ?necess?io preencher os campos: Cli.Entrega, Loja Entrega, Produto, Quantidade e Valor."	  		
EndIf

RestArea(aArea)
Return ( Nil )




//---------------------------------------------------
/*/
Function A410SetTrechos
Seta os Trechos do Documento de Carga para simula?o de frete
@author Andr?Anjos
@since 06/06/2020
/*/
//---------------------------------------------------
Static Function A410SetTrechos(oModelTr,cTpDoc,cCdEmis,cCdRem,cCdDest,cEst,cCodMun)
Local nI		:= 1
Local aTrechos	:= {}
Local cValor	:= ""
Local lMRedes	:= ExistBlock("M461LSF2")
Local cCidO		:= Posicione("GU3",1,xFilial("GU3")+cCdRem,"GU3_NRCID")
Local cCepO		:= Posicione("GU3",1,xFilial("GU3")+cCdRem,"GU3_CEP")

aAdd(aTrechos, { M->CJ_XTRANSP , AllTrim(M->CJ_XTPFRET), "", "" })

For nI := 1 To 5
	If !lMRedes .And. nI > 1 
		Exit
	EndIf
	If SCJ->(ColumnPos('CJ_XTREDES' +Iif(nI == 1,"",Str(nI,1)))) > 0
		aAdd(aTrechos, { M->&('CJ_XTREDES' +Iif(nI == 1,"",Str(nI,1))) , AllTrim(M->CJ_XTREDES) , "" , "" } )
	/*	If lMRedes
			If SC5->(ColumnPos('C5_TFRDP' +Str(nI,1))) > 0 .And. !Empty(cValor := M->&('C5_TFRDP' +Str(nI,1)))
				aTail(aTrechos)[2] := cValor
			EndIf
			If SC5->(ColumnPos('C5_ESTRDP' +Str(nI,1))) > 0 .And. !Empty(cValor := M->&('C5_ESTRDP' +Str(nI,1)))
				aTail(aTrechos)[3] := cValor
			EndIf
			If SC5->(ColumnPos('C5_CMURDP' +Str(nI,1))) > 0 .And. !Empty(cValor := M->&('C5_CMURDP' +Str(nI,1)))
				aTail(aTrechos)[4] := cValor
			EndIf
		EndIf*/
	EndIf
Next nI

aAdd(aTrechos, {Nil,Nil} )

For nI := 1 To Len(aTrechos)
	If nI != 1
		oModelTr:AddLine()
		oModelTr:GoLine( nI )
	EndIf
	
	oModelTr:LoadValue('GWU_SEQ'   , MsStrZero(nI,2) )	// sequencia - chave
	oModelTr:LoadValue('GWU_CDTPDC', cTpDoc )			// tipo do documento - chave
	oModelTr:LoadValue('GWU_EMISDC', cCdEmis)			// codigo do emitente - chave
	oModelTr:LoadValue('GWU_NRDC'  , M->CJ_NUM  ) 		// numero da nota - chave
	oModelTr:LoadValue('GWU_NRCIDO', cCidO )			// cidade origem
	oModelTr:LoadValue('GWU_CEPO'  , cCepO )			// cep origem

	If !Empty(aTrechos[nI + 1][1])
		SA4->( dbSetOrder(1) )
		SA4->( dbSeek(xFilial("SA4")+aTrechos[nI + 1][1] ) )
		If lMRedes .And. !Empty(aTrechos[nI + 1][3]) .And. !Empty(aTrechos[nI + 1][4])
			oModelTr:LoadValue('GWU_NRCIDD', rTrim(TMS120CDUF(aTrechos[nI + 1][3], "1") + aTrechos[nI + 1][4] ))
		Else
			oModelTr:LoadValue('GWU_NRCIDD', rTrim(TMS120CDUF(SA4->A4_EST, "1") + SA4->A4_COD_MUN ))
		EndIf
		oModelTr:LoadValue('GWU_CEPD', SA4->A4_CEP)
	Else
		oModelTr:LoadValue('GWU_NRCIDD', rTrim(TMS120CdUf(cEst, "1") + cCodMun ))
		oModelTr:LoadValue('GWU_CEPD', POSICIONE("GU3",1,xFilial("GU3")+cCdDest,"GU3_CEP"))

		nI := Len(aTrechos)
	EndIf

	//-- Origem do pr?imo trecho ?o destino do atual
	cCepO := oModelTr:GetValue('GWU_CEPD')
	cCidO := oModelTr:GetValue('GWU_NRCIDD')
Next nI

Return



Static Function a410RetSml(aListBox)

Local aSize     := {}
Local aObjects  := {}
Local aInfo     := {}
Local aPosObj   := {}  
Local oOk       := LoadBitMap(GetResources(),"LBOK")
Local oNo       := LoadBitMap(GetResources(),"LBNO")
Local oBtn01
Local oBtn02
Local cCodTrans := ""
Local nItemMrk	:= 0
Local nOpca		:= 0
Local nVlFrete	:= 0

Default aListBox:= {}

Private oListBox:= Nil
Private oDlg	 := Nil
                             
//-- Rotinas Marcadas
Private aRotMark:= {}                                                         
                           
aSize    	:= MsAdvSize(.F. )
aObjects 	:= {}
	
aAdd( aObjects, { 100, 000, .T., .F., .T.  } )
aAdd( aObjects, { 100, 100, .T., .T. } )
aAdd( aObjects, { 100, 005, .T., .T. } )

aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ]*0.60, aSize[ 4 ]*0.68, 3, 3, .T.  }
aPosObj := MsObjSize( aInfo, aObjects, .T. )
	
DEFINE MSDIALOG oDlg TITLE STR0193 From aSize[7],0 to aSize[6]*0.68,aSize[5]*0.61 OF oMainWnd PIXEL //--"Simula?o de Frete"
	
	oPanel := TPanel():New(aPosObj[1,1],aPosObj[1,2],"",oDlg,,,,,CLR_WHITE,(aPosObj[1,3]), (aPosObj[1,4]), .T.,.T.)
			
	//-- Cabecalho dos campos do Monitor.                                                        
	//@ aPosObj[2,1],aPosObj[2,2] LISTBOX oListBox Fields HEADER "",STR0194,STR0195,STR0196,STR0214,STR0218, STR0219, STR0220, STR0221, STR0222, STR0223, STR0224, STR0225, STR0226, STR0227  SIZE aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1] PIXEL //--"Nome Transp.","Valor do Frete","Cod.Transp.","Prazo de Entrega (Dias)"
	@ aPosObj[2,1],aPosObj[2,2] LISTBOX oListBox Fields HEADER "",STR0194,STR0195,STR0196,STR0214,STR0218,STR0219,STR0220,STR0221,STR0222,STR0223,STR0224,STR0225,STR0226,STR0227 SIZE aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1] PIXEL //--"Nome Transp.","Valor do Frete","Cod.Transp.","Prazo de Entrega (Dias)"
		 		   
	oListBox:SetArray( aListBox )
	oListBox:bLDblClick := { || a410MrkSml(aListBox,@nItemMrk,@cCodTrans,@nVlFrete) }                              
	oListBox:bLine      := { || {	Iif(aListBox[ oListBox:nAT,SMMARCA 	] == '1',oOk,oNo),;	
											aListBox[ oListBox:nAT,SMCODTRAN	],;				
											aListBox[ oListBox:nAT,SMNOMETRAN	],;
											aListBox[ oListBox:nAT,SMVALOR	   	],;
											aListBox[ oListBox:nAT,SMPRAZO	   	],; 
											aListBox[ oListBox:nAT,SMNUMCALC	],;
											aListBox[ oListBox:nAT,SMCLASSFRE 	],;
											aListBox[ oListBox:nAT,SMTIPOPER  	],;
											aListBox[ oListBox:nAT,SMTRECHO   	],;
											aListBox[ oListBox:nAT,SMTABELA  	],;
											aListBox[ oListBox:nAT,SMNUMNEGOC 	],;
											aListBox[ oListBox:nAT,SMROTA     	],;
											aListBox[ oListBox:nAT,SMDATVALID 	],;
											aListBox[ oListBox:nAT,SMFAIXA    	],;
											aListBox[ oListBox:nAT,SMTIPOVEI	]}}		        
	//	aAdd (aRet, {,SA4->A4_COD,SA4->A4_NOME,nVlrFrt,nPrevEnt,nNumCalc,nClassFret,nTipOper,cTrecho,cTabela,cNumNegoc,cRota,dDatValid,cFaixa,cTipoVei,.T.})			   
 								
	//-- Botoes da tela do monitor.
	@ aPosObj[3,1],001 BUTTON oBtn01	PROMPT STR0198	ACTION (nOpca := 1, oDlg:End()) OF oDlg PIXEL SIZE 035,011	//-- "Confirmar"
	@ aPosObj[3,1],040 BUTTON oBtn02	PROMPT STR0049	ACTION oDlg:End() OF oDlg PIXEL SIZE 035,011	//-- "Sair"																										                                                    		

ACTIVATE MSDIALOG oDlg CENTERED
/*
If nOpca == 1
	M->CJ_XTRANSP := cCodTrans 
    M->CJ_XNMTRAN := POSICIONE('SA4',1,xFilial('SA4') + M->CJ_XTRANSP,'A4_NREDUZ')          
    M->CJ_XVLFRET := nVlFrete

	U_UpdXFret()
EndIf*/
Return ( Nil )	 


Static Function a410MrkSml(aListBox,nItemMrk,cCodTrans,nVlFrete)

Local nItem   := oListBox:nAt

Default aListBox	:= {}
Default nItemMrk	:= 0 	//Item j?marcado        
Default cCodTrans	:= "" 
Default nVlFrete	:= 0 

If nItemMrk == 0  //Nenhum Item Marcado em Mem?ia
	If aListBox[nItem,SMEXISTMP]
		cCodTrans 	:=  aListBox[nItem,SMCODTRAN]
        nVlFrete    := aListBox[nItem,SMVALOR]
		aListBox[nItem,SMMARCA] := '1'	
		nItemMrk 	:= nItem                         		
	Else
		MsgAlert(STR0199)	//--"Transportadora n? cadastrada no Microsiga Protheus!"
	EndIf
ElseIf nItemMrk == nItem //Item J?Marcado
	aListBox[nItem,SMMARCA] := '2'                
	nItemMrk := 0
	cCodTrans 	:=  ""
Else //Marca o Item selecionado e desmarca o Item j?marcado anteriormente.
	If aListBox[nItem,SMEXISTMP]
		aListBox[nItem,SMMARCA] 	:= '1'			
		aListBox[nItemMrk,SMMARCA] := '2'				
		nItemMrk 						:= nItem                         		
		cCodTrans 						:=  aListBox[nItem,SMCODTRAN]	
        nVlFrete                        := aListBox[nItem,SMVALOR]	
	Else
		MsgAlert(STR0199)	//--"Transportadora n? cadastrada no Microsiga Protheus!"
	EndIf	
EndIf	
	
oListBox:Refresh()
Return ( Nil )



Static Function MTA410RetCGC(cCodEmit)

Local cCGC  := ""
Local aArea := GetArea()

dbSelectArea("GU3")
dbSetOrder(1)

If DBSeek(xFilial("GU3") + cCodEmit)
	cCGC := GU3->GU3_IDFED
EndIf

RestArea( aArea )
Return cCGC

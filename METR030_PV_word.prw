#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'MSOLE.CH'
#INCLUDE 'matr730.ch'

Static cStartPath := GetPvProfString(GetEnvServer(), 'StartPath', 'ERROR', GetADV97())

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³PROGRAMA  ³METR030   ³Autor  ³Totvs Ibirapuera                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³Impressao grafica do pedido de vendas                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function METR030()  
Local aAreaA   := GetArea()
//Local cPerg := 'METR030'  
Local cPedido := Space(6)
Local lContinua := .T. 

Local aParamBox	:= {}
Local aCombo01	:= {"Impressora", "Salvar em Disco"}
Local aCombo02	:= {"DOC", "PDF"}
Local aCombo03	:= {"Word 97-2003", "Word 2010-2013"}
Local aRet		:= {}
Local aMvPar	:= {}
Local nMv

Private cLocTemp
Private cAnexloc
Private cDotRede
//Private hWord
Private cArqDot

For nMv := 1 To 40
   aAdd( aMvPar, &( "MV_PAR" + StrZero( nMv, 2, 0 ) ) )
Next nMv

//--Ajusta Dicionario de Dados:
/*
	Alteração realizada em 08/11/2019 por Iago Bernardes.
	
	As funções PutHelp, PutSX1Help e PutSX1 foram descontinuadas.
	Todas as alterações de perguntas deverão ser feitas pelo Configurador.
*/
//AjustSX1(cPerg)

//AjustaHlp()
/*
	Fim das alterações.
*/
                  
If IsInCallStack('MATA410') //chamada do pedido de venda 
	cPedido := SC5->C5_NUM
EndIf   

/*
	Alteração realizada em 08/11/2019 por Iago Bernardes.
	
	Altera o formato da pergunta para passar a utilizar ParamBox.
*/
/*
If cPedido <> NIl 
	//preenche os parametros com o numero do pedido
	//a funcao HS_POSSX1 faz a verificacao se o sistema ta usando o profile(pergunta configurada por usuario) ou nao.
	aChave := { {cPerg,'01',cPedido} ,{cPerg,'02',cPedido} }
	HS_PosSX1(aChave)
	MV_PAR01 := cPedido                
	MV_PAR02 := cPedido
EndIf
  
If !Pergunte(cPerg,.T.,,,,.F.) //o sexto parametro eh para nao carregar o profile do usuario 
	Return nil
EndIf
*/
// Parametros da função Parambox()
// -------------------------------
// 1 - < aParametros > - Vetor com as configurações
// 2 - < cTitle >      - Título da janela
// 3 - < aRet >        - Vetor passador por referencia que contém o retorno dos parâmetros
// 4 - < bOk >         - Code block para validar o botão Ok
// 5 - < aButtons >    - Vetor com mais botões além dos botões de Ok e Cancel
// 6 - < lCentered >   - Centralizar a janela
// 7 - < nPosX >       - Se não centralizar janela coordenada X para início
// 8 - < nPosY >       - Se não centralizar janela coordenada Y para início
// 9 - < oDlgWizard >  - Utiliza o objeto da janela ativa
//10 - < cLoad >       - Nome do perfil se caso for carregar
//11 - < lCanSave >    - Salvar os dados informados nos parâmetros por perfil
//12 - < lUserSave >   - Configuração por usuário
aAdd(aParamBox, {1, "Pedido de ?", cPedido, "", "", "SC5", "", 75, .T.}) // Tipo caractere
aAdd(aParamBox, {1, "Pedido ate ?", cPedido, "", "MV_PAR02 >= MV_PAR01", "SC5", "", 75, .T.}) // Tipo caractere
aAdd(aParamBox, {1, "Dt. Emissao de ?", SToD("19900101"), "", "", "", "", 75, .T.}) // Tipo caractere
aAdd(aParamBox, {1, "Dt. Emissao ate ?", SToD("20491231"), "", "MV_PAR04 >= MV_PAR03", "", "", 75, .T.}) // Tipo caractere

aAdd(aParamBox, {2, "Destino do Relatorio", "Salvar em Disco", aCombo01, 75, "", .F.}) // Tipo combo
aAdd(aParamBox, {2, "Salvar Como", "DOC", aCombo02, 75, "", .F.}) // Tipo combo
aAdd(aParamBox, {2, "Versao MS-Word", "Word 97-2003", aCombo03, 75, "", .F.}) // Tipo combo

If !ParamBox(aParamBox, "Parâmetros", @aRet, , , , , , , , .F., .F.)
	Return Nil
EndIf

/*
	Fim das alterações.
*/

If MV_PAR07 == "Word 97-2003"
	cArqDot   := "PedidoVenda.dot"  
Else  
	cArqDot   := "PedidoVenda.dotm" 
EndIf 
cDotRede  := "word\" + cArqDot       

If MV_PAR05 == "Salvar em Disco" //salvar em disco                                          

	cFile := cGetFile ( 'Arquivo(*.DOC|*.PDF|)*.DOC|*.PDF' , 'Selecione a pasta para gravação do(s) pedido(s).', 1, '', .T., GETF_LOCALHARD+GETF_RETDIRECTORY,.F.)
	If Empty(cFile)
		Aviso('ATENCAO', 'Processo cancelado pelo usuário!', {'OK'}, 2)
		lContinua := .F.
	Else
		lContinua := ChkPerGrv(cFile)
		If !lContinua
			Aviso('ATENCAO', 'Você não possuí permissão de gravação para pasta selecionada. Tente Selecionar outra pasta.', {'OK'}, 2)
		EndIf
	EndIf
	
EndIf 

If lContinua  
	
	If MV_PAR05 == "Salvar em Disco"
		cAnexLoc := cFile
		
		MontaDir(cAnexLoc)                                               
	EndIf
	
	cLocTemp := GetTempPath()
	
	If File(cLocTemp+"\"+ cArqDot)
		FErase(cLocTemp+"\"+ cArqDot)
	EndIf'
	
	If !CpyS2T( cStartPath +  cDotRede, cLocTemp, .T. ) 
 	   Help('', 1, 'METR03002')		 
	   return nil
	EndIf 
	
	Processa( {|lEnd| WPedVenda()  }, "Aguarde...","Imprimindo Pedido(s) de Venda", .T. )
	
EndIf

For nMv := 1 To Len( aMvPar )
   &( "MV_PAR" + StrZero( nMv, 2, 0 ) ) := aMvPar[ nMv ]
Next nMv

RestArea(aAreaA)
Return() 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³WPedVenda ³AUTOR  ³Giane                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Cria os documentos word para os pedidos de vendas          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                                                                                                                                                              
Static Function WPedVenda() 

Local aImp      := {} 
Local nIPI
Local nICM
Local nVlrImp
Local cNumC5    := ""   
Local nTotReg   := 0   
Local cVlrUnit := ''  
Local cAlqIPi  := ''
Local cAlqIcm  := '' 
Local cVlrLiq  := ''  
Local cVlrImp  := ''   
Local nIt := 0

Private aItensPed := {}
Private lQuery    := .F.
Private cAliasSC5 := ""     
Private hWord

cAliasSC5 := GetNextAlias()

cQuery:=" SELECT "
cQuery+="   SC5.C5_NUM, " 
cQuery+="   SC6.C6_NUM, SC6.C6_ITEM, SC6.C6_PRODUTO, SC6.C6_UM, SC6.C6_QTDVEN, SC6.C6_PRCVEN, SC6.C6_VALOR, SC6.C6_LOTECTL, SC6.C6_TES, "
cQuery+="   SC6.C6_DESCRI, SC6.C6_XCONTE, SC6.C6_XPECA, SC6.C6_XMM, SC6.C6_CF, SC6.C6_ENTREG, SF4.F4_SITTRIB, SF4.F4_CTIPI, SF4.F4_TEXTO, SC6.C6_XIMPORT "   //Wellington
cQuery+=" FROM "+RetSqlName("SC5")+" SC5"
cQuery+="  INNER JOIN "+RetSqlName("SC6")+" SC6 ON SC6.C6_FILIAL = '"+xfilial("SC6")+"' "
cQuery+="   AND SC6.C6_NUM = SC5.C5_NUM AND SC6.D_E_L_E_T_= ' '"
cQuery+="  LEFT JOIN "+RetSqlName("SF4")+" SF4 ON "
cQuery+="   SF4.F4_FILIAL = '"+xfilial("SF4")+"' AND SF4.F4_CODIGO = SC6.C6_TES AND SF4.D_E_L_E_T_=' '"  
cQuery+=" WHERE"
cQuery+="   SC5.C5_FILIAL = '"+ xFilial("SC5") + "' "
cQuery+="   AND SC5.C5_NUM >=     '"+ MV_PAR01       +"' AND SC5.C5_NUM <=     '"+ MV_PAR02       +"'"
cQuery+="   AND SC5.C5_EMISSAO >= '"+ DTOS(MV_PAR03) +"' AND SC5.C5_EMISSAO <= '"+ DTOS(MV_PAR04) +"'"
cQuery+="   AND SC5.D_E_L_E_T_=   ' '"
cQuery+=" ORDER BY C6_NUM, C6_ITEM "
      
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasSC5,.F.,.T.)

TcSetField(cAliasSC5,"C5_EMISSAO","D",8,0)
TcSetField(cAliasSC5,"C6_ENTREG","D",8,0)   //Wellington
TcSetField(cAliasSC5,"C6_QTDVEN","N",TamSX3("C6_QTDVEN")[1],TamSX3("C6_QTDVEN")[2])
TcSetField(cAliasSC5,"C6_PRCVEN","N",TamSX3("C6_PRCVEN")[1],TamSX3("C6_PRCVEN")[2])
TcSetField(cAliasSC5,"C6_VALOR","N",TamSX3("C6_VALOR")[1],TamSX3("C6_VALOR")[2])

//(cAliasSC5)->(DBEVAL({|| nTotReg++}))
nTotReg := (cAliasSC5)->(RecCount())
(cAliasSC5)->(DbGotop())

ProcRegua(nTotReg) 

Do While (cAliasSC5)->(!eof())
	
	IncProc()
	aImp := fCalcImp() //calcula IPI, ICMS do pedido
	
	aItensPed := {}	

	cNumC5 := (cAliasSC5)->C5_NUM

	nIt := 0

	While !(cAliasSC5)->(EOF()) .And. (cAliasSC5)->C6_NUM == cNumC5
		nIt++
		nIpi := 0
		nICM := 0 
		nVlrImp := 0
			
	   //	cDescr := Posicione("SB1",1,xFilial("SB1") + (cAliasSC5)->C6_PRODUTO,"B1_DESC")	
	   //	nPos := Ascan(aImp, {|x| x[1] == SC6->C6_ITEM } ) 
		If len(aImp) >= nIt   //nPos > 0  
			nIPI    := aImp[nIt,2]
			nICM    := aImp[nIt,3] 
			nVlrImp := aImp[nIt,4]
		EndIf    

		cVlrUnit :=  Transform((cAliasSC5)->C6_PRCVEN,"@E 9,999.99999") 
		cAlqIpi  :=  transform(nIpi,"@E 99.99")			
		cAlqIcm  :=  transform(nICM,"@E 99.99") 
		cVlrLiq  :=  transform((cAliasSC5)->C6_VALOR,"@E 999,999.99") 					
		cVlrImp  :=  transform(nVlrImp,"@E 9,999.99")  	

		If (cAliasSC5)->C6_XCONTE='0'
			aadd(aItensPed, {(cAliasSC5)->C6_ITEM,alltrim((cAliasSC5)->C6_PRODUTO) + space(05) + alltrim((cAliasSC5)->C6_DESCRI),;
						IIf(!empty((cAliasSC5)->C6_ENTREG),dtoc((cAliasSC5)->C6_ENTREG),''),;   //Wellington
		              transform((cAliasSC5)->C6_QTDVEN,"@E 999,999.99"), cVlrUnit, '1 ' + (cAliasSC5)->C6_UM, cAlqIpi, cAlqIcm, cVlrLiq, cVlrImp } )
		EndIf
		
		If	(cAliasSC5)->C6_XCONTE='1'
			aadd(aItensPed, {(cAliasSC5)->C6_ITEM,alltrim((cAliasSC5)->C6_PRODUTO) + space(05) + alltrim((cAliasSC5)->C6_DESCRI) + " - " + alltrim((cAliasSC5)->C6_XPECA) + " PC " + STR((cAliasSC5)->C6_XMM) + " MM ",;	
						IIf(!empty((cAliasSC5)->C6_ENTREG),dtoc((cAliasSC5)->C6_ENTREG),''),;   //Wellington
		              transform((cAliasSC5)->C6_QTDVEN,"@E 999,999.99"), cVlrUnit, '1 ' + (cAliasSC5)->C6_UM, cAlqIpi, cAlqIcm, cVlrLiq, cVlrImp } )
		EndIf
						
		If !empty( (cAliasSC5)->C6_LOTECTL ) 
			aadd(aItensPed, {"", "Lote: " + (cAliasSC5)->C6_LOTECTL, "","", "", "", "", "", "", "" } )		
		EndIf
		If !empty( (cAliasSC5)->C6_CF ) 
			aadd(aItensPed, {"CFOP", alltrim((cAliasSC5)->C6_CF) + ' ' + alltrim(Posicione('SX5',1,xFilial('SX5')+'13'+(cAliasSC5)->C6_CF,'X5_DESCRI')), "","", "", "", "", "", "", "", "" } )		
		EndIf

		If !empty( (cAliasSC5)->F4_SITTRIB )   
			aadd(aItensPed, {"ICMS", alltrim((cAliasSC5)->F4_SITTRIB) + ' ' + alltrim(Posicione('SX5',1,xFilial('SX5')+'S2'+(cAliasSC5)->F4_SITTRIB,'X5_DESCRI')), "","", "", "", "", "", "", "", "" } )				
	    EndIf
	    
	    If !empty((cAliasSC5)->F4_CTIPI) 
			aadd(aItensPed, {"IPI", alltrim((cAliasSC5)->F4_CTIPI) + ' ' + alltrim( Posicione('SX5',1,xFilial('SX5')+'S3'+(cAliasSC5)->F4_CTIPI,'X5_DESCRI')), "","", "", "", "", "", "", "", "" } )					           	
	    EndIf  
	    
		 If (cAliasSC5)->C6_XIMPORT='1'   
		    If !empty((cAliasSC5)->C6_TES )  
				aadd(aItensPed, {"TES", (cAliasSC5)->C6_TES + ' ' + alltrim( (cAliasSC5)->F4_TEXTO) + '   ' + 'IMPORTADO' , "","", "", "", "", "", "", "", "" } )					           		    
		    EndIf  
		EndIf
		
		If (cAliasSC5)->C6_XIMPORT='2'   
		    If !empty((cAliasSC5)->C6_TES )  
				aadd(aItensPed, {"TES", (cAliasSC5)->C6_TES + ' ' + alltrim( (cAliasSC5)->F4_TEXTO) + '   ' + 'IMPORTADO' , "","", "", "", "", "", "", "", "" } )					           		    
		    EndIf  
		EndIf
		
		If (cAliasSC5)->C6_XIMPORT='0'   
		    If !empty((cAliasSC5)->C6_TES )  
				aadd(aItensPed, {"TES", (cAliasSC5)->C6_TES + ' ' + alltrim( (cAliasSC5)->F4_TEXTO) + '   ' + 'NACIONAL' , "","", "", "", "", "", "", "", "" } )					           		    
		    EndIf  
		EndIf
		
		aadd(aItensPed, {"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" } ) 
		
		(cAliasSC5)->(DbSkip()) 
	EndDo
	  
	If len(aItensPed) > 0 
	
		hWord	:= OLE_CreateLink()   
		OLE_SetProperty( hWord, oleWdVisible, .F. )
		If hWord == "-1"
		   Help('', 1, 'METR03001')		
			
		Else 
			fDocWord(cNumC5,.T.)  //versao do faturamento que imprime valores/impostos			
			OLE_CloseLink( hWord)   
		EndIf
		
		hWord	:= OLE_CreateLink()   
		OLE_SetProperty( hWord, oleWdVisible, .F. )
		If hWord == "-1"
		   Help('', 1, 'METR03001')		
			
		Else 
			fDocWord(cNumC5,.F.)  //versao do armazem sem valores/impostos			
			OLE_CloseLink( hWord)  		
		EndIf  				
	EndIf		
		   
EndDo

Return()   
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fCalcImp  ³ Autor ³Giane                  ³Data  ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³calcula os impostos                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/   
Static Function fCalcImp()   
Local aAreaC5    := SC5->(GetArea())
Local aAreaA     := GetArea()
Local cCliEnt 
Local nItem      := 0   
Local aRet       := {}
Local nFrete	  := 0
Local nSeguro	  := 0
Local nFretAut	  := 0
Local nDespesa	  := 0
Local nDescCab	  := 0
Local nPDesCab   := 0 
Local cNfOri     := Nil
Local cSeriOri   := Nil
Local nRecnoSD1  := Nil
Local nDesconto  := 0    
Local nValMerc   := 0
Local nPrcLista  := 0
Local nAcresFin  := 0   
Local aItemPed   := {}
Local nPesoIt    := 0   
Local nIPI

Private aRelImp    := MaFisRelImp("MT100",{"SF2","SD2"})
Private aFisGet    := Nil
Private aFisGetSC5 := Nil

MaFisSave()
MaFisEnd()

FisGetInit(@aFisGet,@aFisGetSC5)//IMPOSTOS   

cCliEnt  := IIf(!Empty(SC5->(FieldGet(FieldPos("C5_CLIENT")))),SC5->C5_CLIENT,SC5->C5_CLIENTE)  

MaFisIni(cCliEnt,;							// 1-Codigo Cliente/Fornecedor
			SC5->C5_LOJACLI,;			// 2-Loja do Cliente/Fornecedor
			If(SC5->C5_TIPO$'DB',"F","C"),;	// 3-C:Cliente , F:Fornecedor
			SC5->C5_TIPO,;				// 4-Tipo da NF
			SC5->C5_TIPOCLI,;			// 5-Tipo do Cliente/Fornecedor
			aRelImp,;							// 6-Relacao de Impostos que suportados no arquivo
			,;						   			// 7-Tipo de complemento
			,;									// 8-Permite Incluir Impostos no Rodape .T./.F.
			"SB1",;							// 9-Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
			"MATA461")							// 10-Nome da rotina que esta utilizando a funcao   
			
nFrete	:= SC5->C5_FRETE
nSeguro	:= SC5->C5_SEGURO
nFretAut	:= SC5->C5_FRETAUT
nDespesa	:= SC5->C5_DESPESA
nDescCab	:= SC5->C5_DESCONT
nPDesCab	:= SC5->C5_PDESCAB
	
dbSelectArea("SC5")
For nY := 1 to Len(aFisGetSC5)
	If !Empty(&(aFisGetSC5[ny][2]))
		If aFisGetSC5[ny][1] == "NF_SUFRAMA"
			MaFisAlt(aFisGetSC5[ny][1],Iif(&(aFisGetSC5[ny][2]) == "1",.T.,.F.),Len(aItemPed),.T.)
		Else
			MaFisAlt(aFisGetSC5[ny][1],&(aFisGetSC5[ny][2]),Len(aItemPed),.T.)
		EndIf
	EndIf
Next nY
         
DbSelectArea("SC6")
DbSetOrder(1)
DbSeek(xFilial("SC6")+SC5->C5_NUM)
Do While SC6->(!eof()) .and. SC6->C6_FILIAL + SC6->C6_NUM == xFilial("SC6")+ SC5->C5_NUM    

	nItem ++

	cNfOri     := Nil
	cSeriOri   := Nil
	nRecnoSD1  := Nil
	nDesconto  := 0
	
	If !Empty(SC6->C6_NFORI)
		If SC5->C5_TIPO $ 'BD'
			dbSelectArea("SD1")
			dbSetOrder(1)
			nRecnoSD1  := SD1->(RECNO())
		Else
			dbSelectArea("SD2")
			dbSetOrder(3)
			nRecnoSD1  := SD2->(RECNO())
		EndIf
		If dbSeek(xFilial("SC6")+SC6->C6_NFORI+SC6->C6_SERIORI+SC6->C6_CLI+SC6->C6_LOJA+SC6->C6_PRODUTO+SC6->C6_ITEMORI)
			cNfOri     := SC6->C6_NFORI
			cSeriOri   := SC6->C6_SERIORI
		EndIf
	EndIf
	
	dbSelectArea("SC6")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calcula o preco de lista                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nValMerc  := SC6->C6_VALOR
	nPrcLista := SC6->C6_PRUNIT
	If ( nPrcLista == 0 )
		nPrcLista := NoRound(nValMerc/SC6->C6_QTDVEN,TamSX3("C6_PRCVEN")[2])
	EndIf
	nAcresFin := A410Arred(SC6->C6_PRCVEN*SC5->C5_ACRSFIN/100,"D2_PRCVEN")
	nValMerc  += A410Arred(SC6->C6_QTDVEN*nAcresFin,"D2_TOTAL")
	nDesconto := a410Arred(nPrcLista*SC6->C6_QTDVEN,"D2_DESCON")-nValMerc
	nDesconto := IIf(nDesconto==0,SC6->C6_VALDESC,nDesconto)
	nDesconto := Max(0,nDesconto)
	nPrcLista += nAcresFin
	If cPaisLoc=="BRA"
		nValMerc  += nDesconto
	EndIf	 
                    
	If alltrim(SC6->C6_SEGUM) == 'KG'  
		nPesoIt := SC6->C6_UNSVEN
	ElseIf alltrim(SC6->C6_UM) == 'KG'  
		nPesoIt := SC6->C6_QTDVEN
	EndIf
	
	MaFisAdd(SC6->C6_PRODUTO,; 	  // 1-Codigo do Produto ( Obrigatorio )
				SC6->C6_TES,;			  // 2-Codigo do TES ( Opcional )
				SC6->C6_QTDVEN,;		  // 3-Quantidade ( Obrigatorio )
				nPrcLista,;		  // 4-Preco Unitario ( Obrigatorio )
				nDesconto,;       // 5-Valor do Desconto ( Opcional )
				cNfOri,;		                  // 6-Numero da NF Original ( Devolucao/Benef )
				cSeriOri,;		                  // 7-Serie da NF Original ( Devolucao/Benef )
				nRecnoSD1,;			          // 8-RecNo da NF Original no arq SD1/SD2
		    	0,;							  // 9-Valor do Frete do Item ( Opcional )
				0,;							  // 10-Valor da Despesa do item ( Opcional )
				0,;            				  // 11-Valor do Seguro do item ( Opcional )
				0,;							  // 12-Valor do Frete Autonomo ( Opcional )
				nValMerc,;// 13-Valor da Mercadoria ( Obrigatorio )
				0,;							  // 14-Valor da Embalagem ( Opiconal )
				0,;		     				  // 15-RecNo do SB1
				0) 							  // 16-RecNo do SF4
	
	aadd(aItemPed,	{	SC6->C6_ITEM,;
							SC6->C6_PRODUTO,;
							SC6->C6_DESCRI,;
							SC6->C6_TES,;
							SC6->C6_CF,;
							SC6->C6_UM,;
							SC6->C6_QTDVEN,;
							SC6->C6_PRCVEN,;
							SC6->C6_NOTA,;
							SC6->C6_SERIE,;
							SC6->C6_CLI,;
							SC6->C6_LOJA,;
							SC6->C6_VALOR,;
							SC6->C6_ENTREG,;
							SC6->C6_DESCONT,;
							SC6->C6_LOCAL,;
							SC6->C6_QTDEMP,;
							SC6->C6_QTDLIB,;
							SC6->C6_QTDENT,;
			})
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Forca os valores de impostos que foram informados no SC6.              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SC6")
	For nY := 1 to Len(aFisGet)
		If !Empty(&(aFisGet[ny][2]))
			MaFisAlt(aFisGet[ny][1],&(aFisGet[ny][2]),Len(aItemPed))
		EndIf
	Next nY
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calculo do ISS                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SF4->(dbSetOrder(1))
	SF4->(MsSeek(xFilial("SF4")+SC6->C6_TES))
	If ( SC5->C5_INCISS == "N" .And. SC5->C5_TIPO == "N")
		If ( SF4->F4_ISS=="S" )
			nPrcLista := a410Arred(nPrcLista/(1-(MaAliqISS(Len(aItemPed))/100)),"D2_PRCVEN")
			nValMerc  := a410Arred(nValMerc/(1-(MaAliqISS(Len(aItemPed))/100)),"D2_PRCVEN")
			MaFisAlt("IT_PRCUNI",nPrcLista,Len(aItemPed))
			MaFisAlt("IT_VALMERC",nValMerc,Len(aItemPed))
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Altera peso para calcular frete              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SB1->(dbSetOrder(1))
	SB1->(MsSeek(xFilial("SB1")+SC6->C6_PRODUTO))
	MaFisAlt("IT_PESO",SC6->C6_QTDVEN*SB1->B1_PESO,Len(aItemPed))
	MaFisAlt("IT_PRCUNI",nPrcLista,Len(aItemPed))
	MaFisAlt("IT_VALMERC",nValMerc,Len(aItemPed))
	
	dbSelectArea("SC6")
	 
	nAliqIpi:=	MaFisRet(nItem,"IT_ALIQIPI")  //RETORNA aliq do ipi DO ITEM DO PEDIDO
   //	nICMST	:=	MaFisRet(nItem,"IT_VALSOL") //RETORNA A ALIQUOTA DO ICMS ST DO ITEM   
 	nAliqIcm:=	MaFisRet(nItem,"IT_ALIQICM")     
    nIPI    :=  MaFisRet(nItem,"IT_VALIPI")
    nICM    :=  MaFisRet(nItem,"IT_VALICM")
   
	aadd(aRet,{SC6->C6_ITEM, nAliqIPI, nAliqIcm, nIPI, nICM} )
	
	SC6->(dbSkip())
EndDo
	
MaFisAlt("NF_FRETE"   ,nFrete)
MaFisAlt("NF_SEGURO"  ,nSeguro)
MaFisAlt("NF_AUTONOMO",nFretAut)
MaFisAlt("NF_DESPESA" ,nDespesa)

If nDescCab > 0
	MaFisAlt("NF_DESCONTO",Min(MaFisRet(,"NF_VALMERC")-0.01,nDescCab+MaFisRet(,"NF_DESCONTO")))
EndIf
If nPDesCab > 0
	MaFisAlt("NF_DESCONTO",A410Arred(MaFisRet(,"NF_VALMERC")*nPDesCab/100,"C6_VALOR")+MaFisRet(,"NF_DESCONTO"))
EndIf	
	            
MaFisEnd() 
MaFisRestore() 
    
RestArea(aAreaC5)
RestArea(aAreaA)
Return aRet   


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FisGetInit³ Autor ³Eduardo Riera          ³ Data ³17.11.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Inicializa as variaveis utilizadas no Programa              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±                                                        
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FisGetInit(aFisGet,aFisGetSC5,cAliasSC5)

Local cValid      := ""
Local cReferencia := ""
Local nPosIni     := 0
Local nLen        := 0

Local cAliasSX3   := GetNextAlias()

If Select(cAliasSX3) > 0
	(cAliasSX3)->(DbCloseArea())
EndIf

OpenSxs(,,,,,cAliasSX3,"SX3",,.F.)

If aFisGet == Nil
	aFisGet	:= {}

	(cAliasSX3)->(dbSetOrder(1))
	(cAliasSX3)->(MsSeek("SC6"))
	While !Eof().And. (cAliasSX3)->&('X3_ARQUIVO')=="SC6"
		cValid := UPPER((cAliasSX3)->&('X3_VALID')+(cAliasSX3)->&('X3_VLDUSER'))
		If 'MAFISGET("'$cValid
			nPosIni 	:= AT('MAFISGET("',cValid)+10
			nLen		:= AT('")',Substr(cValid,nPosIni,Len(cValid)-nPosIni))-1
			cReferencia := Substr(cValid,nPosIni,nLen)
			aAdd(aFisGet,{cReferencia,(cAliasSX3)->&('X3_CAMPO'),MaFisOrdem(cReferencia)})
		EndIf
		If 'MAFISREF("'$cValid
			nPosIni		:= AT('MAFISREF("',cValid) + 10
			cReferencia	:=Substr(cValid,nPosIni,AT('","MT410",',cValid)-nPosIni)
			aAdd(aFisGet,{cReferencia,(cAliasSX3)->&('X3_CAMPO'),MaFisOrdem(cReferencia)})
		EndIf
		(cAliasSX3)->(dbSkip())
	EndDo
	aSort(aFisGet,,,{|x,y| x[3]<y[3]})
EndIf

If aFisGetSC5 == Nil
	aFisGetSC5	:= {}

	(cAliasSX3)->(dbSetOrder(1))
	(cAliasSX3)->(MsSeek("SC5"))
	While !Eof().And.(cAliasSX3)->&('X3_ARQUIVO')=="SC5"
		cValid := UPPER((cAliasSX3)->&('X3_VALID')+(cAliasSX3)->&('X3_VLDUSER'))
		If 'MAFISGET("'$cValid
			nPosIni 	:= AT('MAFISGET("',cValid)+10
			nLen		:= AT('")',Substr(cValid,nPosIni,Len(cValid)-nPosIni))-1
			cReferencia := Substr(cValid,nPosIni,nLen)
			aAdd(aFisGetSC5,{cReferencia,(cAliasSX3)->&('X3_CAMPO'),MaFisOrdem(cReferencia)})
		EndIf
		If 'MAFISREF("'$cValid
			nPosIni		:= AT('MAFISREF("',cValid) + 10
			cReferencia	:=Substr(cValid,nPosIni,AT('","MT410",',cValid)-nPosIni)
			aAdd(aFisGetSC5,{cReferencia,(cAliasSX3)->&('X3_CAMPO'),MaFisOrdem(cReferencia)})
		EndIf
		(cAliasSX3)->(dbSkip())
	EndDo
	aSort(aFisGetSC5,,,{|x,y| x[3]<y[3]})
EndIf
MaFisEnd()
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³fDocWord  ³AUTOR  ³Giane                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Monta as variaveis com os conteudos para o word            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ 
Static Function fDocWord(cNumC5,lFat)   
          
Local cSaveFILE := ""     
Local cExt      := ""   
Local nX        := 0
Local nItens    := 0
Local cPar      
Local cItem 
Local cProduto 
Local cRemessa
Local cQuant   
Local cVUnit   
Local cQtdUn 
Local cPIcm  
Local cPIPI 
Local cLiquido
Local cVlrImp  
Local cObsCli := ''

OLE_NewFile( hWord, Alltrim( cLocTemp + cArqDot ) ) 

DbSelectArea('SC5')  
SC5->(DbSetorder(1))
SC5->(DbSeek( xFilial("SC5") + cNumC5 ))

OLE_SetDocumentVar(hWord, 'cNumPed'   , SC5->C5_NUM  )  
OLE_SetDocumentVar(hWord, 'cEmissao'  , SC5->C5_EMISSAO )
OLE_SetDocumentVar(hWord, 'cBanco'    , SC5->C5_BANCO )   //Wellington  
OLE_SetDocumentVar(hWord, 'cCodCli'   , SC5->C5_CLIENTE + ' ' + SC5->C5_LOJACLI )
OLE_SetDocumentVar(hWord, 'cPedCli'   , ALLTRIM( Posicione("SC6",1,xFilial("SC6") + SC5->C5_NUM ,"C6_PEDCLI") ) )   //Wellington  
OLE_SetDocumentVar(hWord, 'cTransp'   , SC5->C5_TRANSP + ' ' + ALLTRIM( Posicione("SA4",1,xFilial("SA4") + SC5->C5_TRANSP ,"A4_NOME") ) )
OLE_SetDocumentVar(hWord, 'cDdd'      , ALLTRIM( Posicione("SA4",1,xFilial("SA4") + SC5->C5_TRANSP ,"A4_DDD") ) )   //Wellington
OLE_SetDocumentVar(hWord, 'cTransT'   , ALLTRIM( Posicione("SA4",1,xFilial("SA4") + SC5->C5_TRANSP ,"A4_TEL") ) )   //Wellington
OLE_SetDocumentVar(hWord, 'cComplem'  , ALLTRIM( Posicione("SA4",1,xFilial("SA4") + SC5->C5_TRANSP ,"A4_COMPLEM") ) )   //Wellington
OLE_SetDocumentVar(hWord, 'cVend'     , SC5->C5_VEND1 + ' ' + ALLTRIM( Posicione("SA3",1,xFilial("SA3") + SC5->C5_VEND1 ,"A3_NOME") ) )

//Dados Cliente ou fornecedor
If SC5->C5_TIPO <> 'B'
	SA1->(DbSetorder(1))
	SA1->(DbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI ))   	
	
	OLE_SetDocumentVar(hWord, 'cCliente'    , SA1->A1_NOME )  	 
	OLE_SetDocumentVar(hWord, 'cEnder'      , alltrim(SA1->A1_END) ) 
	OLE_SetDocumentVar(hWord, 'cBairro'     , alltrim(SA1->A1_BAIRRO) )
	OLE_SetDocumentVar(hWord, 'cCidade'     , alltrim(SA1->A1_MUN) + ' - ' + alltrim(SA1->A1_EST) )
	OLE_SetDocumentVar(hWord, 'cCep'        , left(SA1->A1_CEP,5) + '-' + Right(SA1->A1_CEP,3) )
	OLE_SetDocumentVar(hWord, 'cCnpj'       , alltrim(SA1->A1_CGC) ) //Wellington
	OLE_SetDocumentVar(hWord, 'cInsc'       , alltrim(SA1->A1_INSCR) ) //Wellington
	OLE_SetDocumentVar(hWord, 'cRegiao'     , alltrim(SA1->A1_XZONA) ) //Wellington
	//OLE_SetDocumentVar(hWord, 'cUF'         , alltrim(SA1->A1_EST) )  
	
	If SA1->(FieldPos("A1_XOBS")) > 0
  		cObsCli := alltrim(SA1->A1_XOBS)
	EndIf
Else
	SA2->(DbSetorder(1))
	SA2->(DbSeek(xFilial("SA2") + SC5->C5_CLIENTE + SC5->C5_LOJACLI ))   
	
	OLE_SetDocumentVar(hWord, 'cCliente'    , SA2->A2_NOME )  	 
	OLE_SetDocumentVar(hWord, 'cEnder'      , alltrim(SA2->A2_END) ) 
	OLE_SetDocumentVar(hWord, 'cBairro'     , alltrim(SA2->A2_BAIRRO) )
	OLE_SetDocumentVar(hWord, 'cCidade'     , alltrim(SA2->A2_MUN) + ' - ' + alltrim(SA2->A2_EST) )
	OLE_SetDocumentVar(hWord, 'cCep'        , left(SA2->A2_CEP,5) + '-' + Right(SA2->A2_CEP,3) )
   //	OLE_SetDocumentVar(hWord, 'cUF'         , alltrim(SA2->A2_EST) ) 	

EndIf

OLE_SetDocumentVar(hWord, 'cMoeda'  , VerMoeda(SC5->C5_MOEDA)  )
OLE_SetDocumentVar(hWord, 'cCondPag', alltrim( Posicione("SE4",1, xFilial("SE4") + SC5->C5_CONDPAG,"E4_DESCRI" ))  )  
OLE_SetDocumentVar(hWord, 'cTexto1' , iif( SC5->(FieldPos('C5_XOBS')) > 0 ,ALLTRIM(SC5->C5_XOBS),'') ) 
	 
                         
nItens := len(aItensPed) 

For nX := 1 to  nItens
 		
	cItem    := "'cItem"      + Alltrim(str(nX)) + "'" 
	cProduto := "'cProduto"   + Alltrim(str(nX)) + "'" 
	cRemessa := "'cRemessa"   + Alltrim(str(nX)) + "'" 
	cQuant   := "'cQtdade"    + Alltrim(str(nX)) + "'"
	cVUnit   := "'cUnitario"  + Alltrim(str(nX)) + "'"		
	cQtdUn   := "'cQtdUn"     + Alltrim(str(nX)) + "'"  
	cPIPI    := "'cPIPI"      + Alltrim(str(nX)) + "'"	    	
	cPIcm    := "'cPICM"      + Alltrim(str(nX)) + "'"	    	
	cLiquido := "'cLiquido"   + Alltrim(str(nX)) + "'"
	cVlrImp  := "'cVlrImp"    + Alltrim(str(nX)) + "'"
   	
	OLE_SetDocumentVar(hWord, &cItem   , aItensPed[nx,1] ) 	
	OLE_SetDocumentVar(hWord, &cProduto, aItensPed[nx,2] ) 	
	OLE_SetDocumentVar(hWord, &cRemessa, aItensPed[nx,3] )	  	   
	OLE_SetDocumentVar(hWord, &cQuant  , aItensPed[nx,4] )			
	OLE_SetDocumentVar(hWord, &cQtdUn  , aItensPed[nx,6] )			

	If lFat
		OLE_SetDocumentVar(hWord, &cVUnit  , aItensPed[nX,5] )	
		OLE_SetDocumentVar(hWord, &cPIPI   , aItensPed[nX,7] ) 
		OLE_SetDocumentVar(hWord, &cPIcm   , aItensPed[nX,8] ) 
		OLE_SetDocumentVar(hWord, &cLiquido, aItensPed[nX,9] ) 					
		OLE_SetDocumentVar(hWord, &cVlrImp , aItensPed[nX,10] )   
	Else
		OLE_SetDocumentVar(hWord, &cVUnit  , "" )	
		OLE_SetDocumentVar(hWord, &cPIPI   , "" ) 
		OLE_SetDocumentVar(hWord, &cPIcm   , "" ) 
		OLE_SetDocumentVar(hWord, &cLiquido, "" ) 					
		OLE_SetDocumentVar(hWord, &cVlrImp , "" )  
	EndIf
		
/*	If Empty(aItensPed[nX,1])
		OLE_SetDocumentVar(hWord, &cItem   , "" ) 	
		OLE_SetDocumentVar(hWord, &cProduto, "" ) 	
		OLE_SetDocumentVar(hWord, &cRemessa, "" )	  	   
		OLE_SetDocumentVar(hWord, &cQuant  , "" )	
		OLE_SetDocumentVar(hWord, &cQtdUn  , "" )	
		OLE_SetDocumentVar(hWord, &cVUnit  , "" )	
		OLE_SetDocumentVar(hWord, &cPIPI   , "" ) 
		OLE_SetDocumentVar(hWord, &cPIcm   , "" ) 
		OLE_SetDocumentVar(hWord, &cLiquido, "" ) 					
		OLE_SetDocumentVar(hWord, &cVlrImp , "" ) 
    
	Else
   
	    cLinItem := aItensPed[nX,1]+ CRLF 
	    If len(aItensPed[nX,3]) > 30  
	    	cLinItem += "" + CRLF
	    EndIf  
   	    If !empty(aItensPed[nX,12])
	 	   cLinItem += "" + CRLF
	    EndIf  
	    cLinItem +=  "CFOP" + CRLF 
	    
	    If !empty(aItensPed[nX,16])    
		    cLinItem += "ICMS" + CRLF
	    EndIf 
	    If !empty(aItensPed[nX,18])        
		    cLinItem += "IPI" + CRLF 
	    EndIf
	    cLinItem += "TES"  
	
		cLinProd := aItensPed[nX,2] + ' ' + aItensPed[nX,3] + CRLF +;
		            iif(!empty(aItensPed[nX,12]), "Lote: " +aItensPed[nX,12] + CRLF,'') +;
		            aItensPed[nX,13] + ' ' + aItensPed[nX,14] + CRLF +;  
				    iif(!empty(aItensPed[nX,16]),aItensPed[nX,16] + ' ' + aItensPed[nX,17] + CRLF,'') +; 
				    iif(!empty(aItensPed[nX,18]),aItensPed[nX,18] + ' ' + aItensPed[nX,19] + CRLF,'') +; 
				    aItensPed[nX,11] + ' ' + aItensPed[nX,15]    
	
   	    
		OLE_SetDocumentVar(hWord, &cItem   , cLinItem ) 	
		OLE_SetDocumentVar(hWord, &cProduto, cLinProd ) 	
		OLE_SetDocumentVar(hWord, &cRemessa, iif(!empty(aItensPed[nX,10]),dtoc(aItensPed[nX,10]),'')  )	  	   
		OLE_SetDocumentVar(hWord, &cQuant  , transform(aItensPed[nX,4],"@E 999,999.99")   )	
		OLE_SetDocumentVar(hWord, &cQtdUn  , '1 ' + aItensPed[nX,20] )	
	
		If MV_PAR05 == 1  
			OLE_SetDocumentVar(hWord, &cVUnit  , transform(aItensPed[nX,5],"@E 9,999.99999")  )	
			OLE_SetDocumentVar(hWord, &cPIPI   , transform(aItensPed[nX,7],"@E 99.99")  ) 
			OLE_SetDocumentVar(hWord, &cPIcm   , transform(aItensPed[nX,8],"@E 99.99")  ) 
			OLE_SetDocumentVar(hWord, &cLiquido, transform(aItensPed[nX,6],"@E 999,999.99")  ) 					
			OLE_SetDocumentVar(hWord, &cVlrImp , transform(aItensPed[nX,9],"@E 9,999.99")  ) 					
		Else
			OLE_SetDocumentVar(hWord, &cVUnit  , ""  )	
			OLE_SetDocumentVar(hWord, &cPIPI   , ""  ) 
			OLE_SetDocumentVar(hWord, &cPIcm   , ""  ) 
			OLE_SetDocumentVar(hWord, &cLiquido, ""  ) 					
			OLE_SetDocumentVar(hWord, &cVlrImp , ""  ) 	
		EndIf   
			
   	EndIf  
   	*/       	 	
	
//	nLin++
Next nX   

OLE_SetDocumentVar(hWord, 'Prt_nroitens',str(nItens++))  

OLE_ExecuteMacro(hWord,"miteped") 

OLE_SetDocumentVar(hWord, 'cTexto2' , cObsCli ) 

//Dados do Rodape
OLE_SetDocumentVar(hWord, 'cEndereco' , alltrim(SM0->M0_ENDCOB) + ' - ' + alltrim(SM0->M0_BAIRCOB) + ' - ' + alltrim(SM0->M0_CIDCOB ) + ' - ' +;
                                        left(SM0->M0_CEPCOB,5) + '-' + right(SM0->M0_CEPCOB,3) + ' - ' + alltrim(SM0->M0_ESTCOB)   )
OLE_SetDocumentVar(hWord, 'cFoneFax'  , 'Telefone ' + left(SM0->M0_TEL,2) + ' ' + ALLTRIM(SUBSTR(SM0->M0_TEL,3,12)) + ' - Fax ' + LEFT(SM0->M0_FAX,2) + ' ' + alltrim(SUBSTR(SM0->M0_FAX,3,12)) )

OLE_SetDocumentVar(hWord, 'cEmail'  , 'metalinoxvendassp@metalinox.com.br - www.metalinox.com.br')  

OLE_ExecuteMacro(hWord,"IcEmpresa")   //esta macro serve para imprimir as docvariables que ficam no cabecalho e rodape
 
OLE_UpdateFields(hWord)


If MV_PAR06 == "DOC"
	cExt := '.doc'  
	cPar := nil
Else
	cExt := '.pdf'	 
	cPar := "17"
EndIf

//transforma em pdf
cSaveFILE := 'PedidoVenda_' + SC5->C5_NUM + iif(lFat,"_FAT","_ARM") + cExt

If MV_PAR05 == "Salvar em Disco"

	If File(cAnexLoc+"\"+ cSaveFILE)
		FErase(cAnexLoc+"\"+ cSaveFILE)
	EndIf          
	      
	//alert(alltrim(MV_PAR06))
	If alltrim(MV_PAR06) == "PDF"
		OLE_SaveAsFile(hWord,cAnexLoc+ "\" +cSaveFILE+".pdf",,,, '17') 
	ELSE
		OLE_SaveAsFile(hWord, cAnexLoc+ "\" +cSaveFILE, , , , cPar ) //parametro 17 salva em pdf
	ENDIF	
Else
   //	OLE_PrintFile(hWord, cAnexLoc+"\"+ cSaveFILE )
   	OLE_PrintFile(hWord, cSaveFILE )
	Sleep(1000)
EndIf
       

OLE_CloseFile( hWord )

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³Vermoeda  ³AUTOR  ³Giane                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ descricao da moeda                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ 
Static Function verMoeda( nMoeda )
Local _cRet := "R$"

If nMoeda == 1
	_cRet := "R$ "
ElseIf nMoeda == 2
	_cRet := "US$"
ElseIf nMoeda == 3
	_cRet := "UFI"
ElseIf nMoeda == 4
	_cRet := "EUR"
ElseIf nMoeda == 5
	_cRet := "YEN"
ElseIf nMoeda >= 6
	_cRet := "   "
EndIf

Return ( _cRet )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ChkPerGrv ³ Autor ³V.RASPA                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Checa permissao de gravacao na pasta indicada para geracao  ³±±
±±³          ³do relatorio                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ChkPerGrv(cPathTmp)
Local cFileTmp := CriaTrab(NIL, .F.)
Local nHdlTmp  := 0
Local lRet     := .F.

cPathTmp := AllTrim(cPathTmp)
nHdlTmp  := MSFCreate(cPathTmp + If(Right(cPathTmp, 1) <> '\', '\', '') + cFileTmp + '.TMP', 0)
If nHdlTmp <= 0
	lRet := .F.

Else
	lRet := .T.
	FClose(nHdlTmp)
	FErase(cPathTmp + If(Right(cPathTmp, 1) <> '\', '\', '') + cFileTmp + '.TMP')

EndIf

Return(lRet) 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³AjustaHlp ³AUTOR  ³Giane                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Cria Help's vinculados ao programa                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*
	Alteração realizada em 08/11/2019 por Iago Bernardes.
	
	As funções PutHelp, PutSX1Help e PutSX1 foram descontinuadas.
	Todas as alterações de perguntas deverão ser feitas pelo Configurador.
*/
/*
Static Function AjustaHlp()
Local aHlpPor := {}
Local aSolPor := {} 

//--HELP: 
aHlpPor := {}
aSolPor := {}
AAdd(aHlpPor, 'Impossível estabelecer comunicação com o') 
AAdd(aHlpPor, 'Microsoft Word.')
PutHelp('PMETR03001', aHlpPor, {}, {}, .F.)

//--HELP: DPREL00202
aHlpPor := {}
aSolPor := {}  
AAdd(aHlpPor, "Impossível copiar modelo word para o " )
AAdd(aHlpPor, "disco local!                         " )  
//AAdd(aHlpPor, cStartPath + cDotRede )
PutHelp('PMETR03002', aHlpPor, {}, {}, .f.)    

Return
*/
/*
	Fim das alterações.
*/

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³AjustaSX1 ³AUTOR  ³Totvs ibirapuera                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Cria perguntas da rotina                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*
	Alteração realizada em 08/11/2019 por Iago Bernardes.
	
	As funções PutHelp, PutSX1Help e PutSX1 foram descontinuadas.
	Todas as alterações de perguntas deverão ser feitas pelo Configurador.
*/
/*
Static Function AjustSX1(cPerg)
Local aHelp := {} 

aHelp := {}
AAdd( aHelp, 'Informe codigo inicial do Pedido' )
PutSx1(cPerg,'01','Pedido Venda De ?' ,'Pedido Venda De ?','Pedido Venda De?','mv_ch1','C',TamSX3("C5_NUM")[1],0,0,'G','','SC5','','',"mv_par01","","","","","","","","","","","","","","","","",aHelp,aHelp,aHelp)

aHelp := {}
AAdd( aHelp, 'Informe codigo final do Pedido' )
PutSx1(cPerg,'02','Pedido Venda Ate?' ,'Pedido Venda Ate?','Pedido Venda Ate?','mv_ch2','C',TamSX3("C5_NUM")[1],0,0,'G','(MV_PAR02 >= MV_PAR01)','SC5','','',"mv_par02","","","","","","","","","","","","","","","","",aHelp,aHelp,aHelp)

aHelp := {}
AAdd( aHelp, 'Informe a data inicial de emissao dos pedi')
AAdd( aHelp, 'dos de venda.')
PutSx1(cPerg,'03','Emissão De?' ,'Emissão De?','Emissão De?','mv_ch3','D',8,0,0,'G','','','','',"mv_par03","","","","","","","","","","","","","","","","",aHelp,aHelp,aHelp)

aHelp := {}
AAdd( aHelp, 'Informe a data final de emissao dos pedi')
AAdd( aHelp, 'dos de venda.')
PutSx1(cPerg,'04','Emissão Até?' ,'Emissão Até?','Emissão Até?','mv_ch4','D',8,0,0,'G','(MV_PAR04 >= MV_PAR03)','','','',"mv_par04","","","","","","","","","","","","","","","","",aHelp,aHelp,aHelp)

//aHelp := {}
//AAdd( aHelp, 'Informe se deseja que os valores e impos' ) 
//AAdd( aHelp, 'tos sejam impressos ou nao.                     ' )
//PutSx1(cPerg,'05','Impostos/Valores?' ,'Impostos/Valores?','Impostos/Valores?','mv_ch5','N',1,0,0,'C','','','','',"mv_par05","Imprime","Imprime","Imprime","","Não Imprime","Não Imprime","Não Imprime","","","","","","","","","",aHelp,aHelp,aHelp)
				
aHelp := {'Informe o destino do relatorio'}
PutSx1(cPerg, '05', 'Destino do Relatorio', '', '', 'MV_CH5','N', 1, 0, 0, 'C', '', '', '', '',"MV_PAR05",;
		"Impressora", "", "", "", "Salvar em Disco", "", "", "", "", "", "", "", "", "", "", "", aHelp, {}, {})

aHelp := {'Informe o formato do documento, somente' , 'se for salvar em disco'}
PutSx1(cPerg, '06', 'Salvar Como', '', '', 'MV_CH6','N', 1, 0, 0, 'C', '', '', '', '',"MV_PAR06",;
		"PDF", "PDF", "PDF", "", "DOC", "DOC", "DOC", "", "", "", "", "", "", "", "", "", aHelp, {}, {})

aHelp := {'Informe a versao do MS-Word'}
PutSx1(cPerg, '07', 'Versao MS-Word', '', '', 'MV_CH7','N', 1, 0, 0, 'C', '', '', '', '',"MV_PAR07",;
		"Word 97-2003", "", "", "", "Word 2010-2013", "", "", "", "", "", "", "", "", "", "", "", aHelp, {}, {})

Return
*/
/*
	Fim das alterações.
*/
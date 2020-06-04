#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

/*/{Protheus.doc} DAXREL03
Recibo de pagamento de comissoes
@type function
@author Rodolfo
@since 03/06/2019
@version 1.0
/*/
User Function DAXREL03()
Local cComp      := AnoMes(dDataBase)
Local oPrint
Local cNomeArq    := 'COMISSAO'+StrTran(DTOC(dDataBase),'/', '-') + "_" + StrTran(Time(),":","")+'.PDF'
Local cLocal      := GetTempPath()
Local aParam      := {}
Local aRet        := {}	
Local lRet		  := .T.

aAdd(aParam, {1, "Vendedor"   	, CriaVar('E3_VEND',.F.)  ,  ,, 'SA3',, 60, .T.} )
aAdd(aParam, {1, "Data Inicial"   	,dDataBase  ,  ,, ,, 60, .T.} )
aAdd(aParam, {1, "Data Final"   	, dDataBase ,  ,, ,, 60, .T.} )


If ParamBox(aParam,'Parâmetros',aRet)
	oPrint := FWMSPrinter():New(cNomeArq, IMP_PDF, .T., cLocal, .T.,  .F., , ,  .T.,  .T., , .T.)
	oPrint:SetLandscape()

	RptStatus({|| lRet:= ImpRel(oPrint,aRet)},"Imprimindo relatório...")
	If lRet
		oPrint:Preview()
	Else
		MsgInfo('Não foram encontrados registros!')
	EndIf	
Else	
	MsgInfo("Cancelado pelo usuário.")		
Endif

Return

/*/{Protheus.doc} ImpRel
Gerar relatório de Contribuicoes em Atraso
@type function
@author Rodolfo
@since 03/06/2019
@version 1.0
/*/
Static Function ImpRel(oPrint,aRet)
Local cAliasQry  	:= GetNextAlias()
Local cEmpAnt    	:= ""
Local cEmpAtu    	:= ""
Local cMes       	:= ""
Local cAno       	:= ""
Local oFont10    	:= TFont():New("Arial",9,12,.T.,.F.,5,.T.,5,.T.,.F.)
Local oFont15    	:= TFont():New("Arial",14,12,.T.,.F.,5,.T.,5,.T.,.F.)
Local lRet       	:= .F.
Local nControle  	:= 1
Local nLinha     	:= 0
Local nColContr  	:= 0150
Local nColVlrOri 	:= 0550
Local nColVlrMul 	:= 0950
Local nColVlrJur 	:= 1350
Local nColVlrTot 	:= 1750
Local nTotOri    	:= 0
Local nTotMul    	:= 0
Local nTotJur    	:= 0
Local nTotGer    	:= 0
Local nTotDesc   	:= 0
Local nTotal    	:= 0
Local nTotTrans		:= 0
Local nTotValIPI	:= 0
Local nAliqIpi		:= 0
Local nDesc      	:= 0
Local cFilBkp		:= cFilAnt
Local aSM0  		:= FWLoadSM0()
Local nX			:= 0
Local dDtVazia		:= Stod(' ')
Private nPagina		:= 1
		
For nX	:= 1 to Len(aSM0)
	cFilAnt := aSM0[nX][2]
	nTotal	:= 0
	BeginSQL Alias cAliasQry

		SELECT 	SE3.* , SA1.* , SF2.* , SE1.*,
			(
			SELECT 	COUNT(*) 				
			FROM %TABLE:SE1% SE1A					            
			WHERE SE1A.%NotDel%	AND
				SE1A.E1_FILIAL   = SE3.E3_FILIAL AND
				SE1A.E1_PREFIXO  = SE3.E3_PREFIXO AND
				SE1A.E1_NUM  	 = SE3.E3_NUM AND
				SE1A.E1_TIPO     = SE3.E3_TIPO    
			) AS TOTPARC
		FROM %TABLE:SE3% SE3					
		INNER JOIN  %TABLE:SA3% SA3 ON 			
			SA3.A3_FILIAL   = %Exp:FWxFilial("SA3")% AND 
			SA3.A3_COD      = SE3.E3_VEND 
		INNER JOIN  %TABLE:SA1% SA1 ON 			
			SA1.A1_FILIAL   = %Exp:FWxFilial("SA1")% AND 
			SA1.A1_COD      = SE3.E3_CODCLI AND
			SA1.A1_LOJA     = SE3.E3_LOJA  AND
			SA1.%NotDel%         
		LEFT JOIN  %TABLE:SF2% SF2 ON 			
			SF2.F2_FILIAL   = %Exp:FWxFilial("SF2")% AND 
			SF2.F2_DOC      = SE3.E3_NUM AND
			SF2.F2_SERIE    = SE3.E3_SERIE AND
			SF2.%NotDel%   
		INNER JOIN  %TABLE:SE1% SE1 ON 			
			SE1.E1_FILIAL    = %Exp:FWxFilial("SE1")% AND 
			SE1.E1_NUM       = SE3.E3_NUM AND
			SE1.E1_PREFIXO   = SE3.E3_PREFIXO AND
			SE1.E1_PARCELA	 = SE3.E3_PARCELA AND
			SE1.%NotDel%   			            
		WHERE SA3.%NotDel%	AND
			SE3.E3_DATA     = %Exp:DTOS(dDtVazia)% AND 
			SE3.E3_VEND     = %Exp:aRet[1]% AND 
			SE1.E1_VENCREA  >= %Exp:DTOS(aRet[2])% AND 
            SE1.E1_VENCREA  <= %Exp:DTOS(aRet[3])% AND
			SE3.%NotDel%
	EndSQL

	If !(cAliasQry)->(EOF())
		lRet:= .T.
	Else
		(cAliasQry)->(dbClosearea())
		Loop
	EndIf

	Cabecalho(oPrint, cAliasQry,aRet,aSM0[nX][7]) //Imprime Cabeçalho
	nLinha := 0500
	While (cAliasQry)->( ! Eof() )
		//nLinha += 50
		If nLinha >= 2300 //Se atingir o tamanho máximo imprime nova folha
			oPrint:EndPage()
			oPrint:StartPage()			

			//Imprime quadro da folha
			oPrint:Line(0100, 0100, 0100, 2900)
			oPrint:Line(2300, 0100, 2300, 2900)
			oPrint:Line(0100, 2900, 2300, 2900)
			oPrint:Line(0100, 0100, 2300, 0100)		
		
			nLinha := 0200
			nPagina++
		EndIf	
																
		oPrint:Say(nLinha, 0150        	, Alltrim( (cAliasQry)->E3_PEDIDO)	, oFont10 ) //PEDIDO
		//oPrint:Say(nLinha, 0400        	, DTOC(STOD((cAliasQry)->E3_EMISSAO))		, oFont10 ) //Fechamento
		If Empty((cAliasQry)->F2_EMISSAO) //Não tem F2- registros importados
			oPrint:Say(nLinha, 0400     	, DTOC(STOD((cAliasQry)->E3_EMISSAO))	, oFont10 ) //Emissao NF
			If  (cAliasQry)->TOTPARC > 1
				oPrint:Say(nLinha, 0700     	, (cAliasQry)->E3_NUM + ' - Parc ' + Alltrim( (cAliasQry)->E1_PARCELA) + ' de ' +  Alltrim(STR( (cAliasQry)->TOTPARC))						, oFont10 ) //Num NF
			Else
				oPrint:Say(nLinha, 0700     	, (cAliasQry)->E3_NUM						, oFont10 ) //Num NF
			EndIf
			oPrint:Say(nLinha, 1070      	, DTOC(STOD((cAliasQry)->E3_EMISSAO))		, oFont10 ) //Data Transação
			oPrint:Say(nLinha, 1550     	, Transform( (cAliasQry)->E3_BASE ,PesqPict("SF2","F2_VALMERC"))		, oFont10 ) //Valor Transação
			oPrint:Say(nLinha, 2000     	, Transform((cAliasQry)->E3_PORC ,PesqPict("SE3","E3_PORC"))		, oFont10 ) //% medio da transação
			oPrint:Say(nLinha, 2500     	, Transform((cAliasQry)->E3_COMIS ,PesqPict("SE3","E3_COMIS"))		, oFont10 ) //valor comissaão sem DSR		
		Else
			oPrint:Say(nLinha, 0400      	, DTOC(STOD((cAliasQry)->F2_EMISSAO))		, oFont10 ) //Emissao NF
			If  (cAliasQry)->TOTPARC > 1
				oPrint:Say(nLinha, 0700     	, (cAliasQry)->F2_DOC + ' - Parc ' + Alltrim( (cAliasQry)->E1_PARCELA) + ' de ' +  Alltrim(STR( (cAliasQry)->TOTPARC))						, oFont10 ) //Num NF
			Else
				oPrint:Say(nLinha, 0700     	, (cAliasQry)->F2_DOC						, oFont10 ) //Num NF
			EndIf
			nAliqIpi :=  (cAliasQry)->F2_VALIPI / (cAliasQry)->F2_BASEIPI
			oPrint:Say(nLinha, 1070      	, DTOC(STOD((cAliasQry)->E1_BAIXA))		, oFont10 ) //Liquidação do titulo
			oPrint:Say(nLinha, 1550      	, Transform((cAliasQry)->E3_BASE ,PesqPict("SF2","F2_VALMERC"))		, oFont10 ) //Valor Liquidado
			oPrint:Say(nLinha, 2000      	, Transform((cAliasQry)->E3_PORC ,PesqPict("SE3","E3_PORC"))		, oFont10 ) //% medio da transação
			oPrint:Say(nLinha, 2500     	, Transform((cAliasQry)->E3_COMIS ,PesqPict("SE3","E3_COMIS"))		, oFont10 ) //valor comissaão sem DSR
		EndIf
		nTotTrans += (cAliasQry)->E3_BASE
		nTotValIPI	+= (cAliasQry)->E3_BASE +  ((cAliasQry)->E3_BASE * nAliqIpi)
		nTotal += (cAliasQry)->E3_COMIS
		nLinha += 100
		(cAliasQry)->(dbSkip())
	EndDo

	(cAliasQry)->(dbClosearea())

	trailer(oPrint,nLinha,nTotal,nTotTrans,nTotValIPI)
Next

cFilAnt := cFilBkp

Return lRet

/*/{Protheus.doc} Cabecalho
Efetua a impressão do cabeçalho com os dados da Empresa
@type function
@author Janaina de Jesus
@since 03/06/2019
@version 1.0
@param oPrint, objeto, objeto de impressão
@param cAliasQry, character, tabela ativa
/*/
Static Function Cabecalho(oPrint, cAliasQry,aRet,cNomeFil)
	Local oFont10    := TFont():New("Arial"      ,9,12,.T.,.T.,5,.T.,5,.T.,.F.)
	Local oFont15    := TFont():New("Arial"      ,20,12,.T.,.T.,5,.T.,5,.T.,.F.)
	Local oFont10c   := TFont():New("Calibre",9,12,.T.,.T.,5,.T.,5,.T.,.F.)
	Local cNomeEmp   := AllTrim(SM0->M0_NOMECOM)
	Local cEmissao   := OemToAnsi("Impresso em: ") + DtoC( dDataBase) + ' ' + Time() + ' Pagina ' + Alltrim(STR(nPagina))
	
	cCGC:= Transform(cCGC, "@R 99.999.999/9999-99")
	
	oPrint:StartPage()
	//Imprime quadro da folha
	oPrint:Line(0100, 0100, 0100, 2900)
	oPrint:Line(2300, 0100, 2300, 2900)
	oPrint:Line(0100, 2900, 2300, 2900)
	oPrint:Line(0100, 0100, 2300, 0100)
		
	oPrint:Say(0150, 2000, cNomeEmp, oFont10c)
	oPrint:Say(0200, 2000, cNomeFil, oFont10c)
	oPrint:Say(0250, 2000, cEmissao, oFont10c)
	oPrint:Say(0150, 0150, "RELATORIO DE COMISSÕES ANALITICO" , oFont15)
	//oPrint:Line(0420, 0200, 0420, 2300)
	oPrint:Say(0250, 0150, "Periodo Considerado:    " + DTOC(aRet[2]) + ' a ' + DTOC(aRet[3]) , oFont15)
	oPrint:Say(0300, 0150, "Vendedor:               " + Posicione('SA3',1,xFilial('SA3') + aRet[1],'A3_NOME'), oFont15)

    oPrint:Line(0420, 0100, 0420, 2900)	
	
	oPrint:Say(0455, 0150, "Pedido"	, oFont10)
	oPrint:Say(0455, 0400, "Dt Emissão NF"	, oFont10)	
    oPrint:Say(0455, 0700, "Num NF"	, oFont10)
    oPrint:Say(0455, 1070, "Liquidação Titulo"	, oFont10)
    oPrint:Say(0455, 1530, "Valor Liquidado"	, oFont10)
	oPrint:Say(0455, 1950, "% medio de comissao"	, oFont10)
	oPrint:Say(0455, 2450, "Valor comissão sem DSR"	, oFont10)
	
Return


Static Function trailer(oPrint,nLinha,nTotal,nTotTrans,nTotValIPI)
						
	Local oFont10    := TFont():New("Arial"      ,9,12,.T.,.T.,5,.T.,5,.T.,.F.)
	Local oFont15    := TFont():New("Arial"      ,20,12,.T.,.T.,5,.T.,5,.T.,.F.)
	Local oFont10c   := TFont():New("Calibre",9,12,.T.,.T.,5,.T.,5,.T.,.F.)
	Local cNomeEmp   := AllTrim(SM0->M0_NOMECOM)
	Local cEmissao   := OemToAnsi("Impresso em: ") + DtoC( dDataBase) + ' ' + Time() + ' Pagina ' + Alltrim(STR(nPagina))

	nLinha += 100

	If nLinha >= 2900 //Se atingir o tamanho máximo imprime nova folha
		oPrint:EndPage()
		oPrint:StartPage()			
		//Imprime quadro da folha
		oPrint:Line(0100, 0100, 0100, 2900)
		oPrint:Line(2300, 0100, 2300, 2900)
		oPrint:Line(0100, 2900, 2300, 2900)
		oPrint:Line(0100, 0100, 2300, 0100)	

		oPrint:Say(0150, 2000, cNomeEmp, oFont10c)
		oPrint:Say(0250, 2000, cEmissao, oFont10c)
		oPrint:Say(0150, 0150, "RELATORIO DE COMISSÕES ANALITICO" , oFont15)
		//oPrint:Line(0420, 0200, 0420, 2300)
		oPrint:Say(0250, 0150, "Periodo Considerado:    " + DTOC(aRet[2]) + ' a ' + DTOC(aRet[3]) , oFont15)
		oPrint:Say(0300, 0150, "Vendedor:               " + Posicione('SA3',1,xFilial('SA3') + aRet[1],'A3_NOME'), oFont15)			
		oPrint:Line(0420, 0100, 0420, 2900)			
		nLinha := 0200
		mPagina
	EndIf	
		
	//oPrint:Say(nLinha	 , 2000 		, 'TOTAL DE COMISSÕES SEM DSR '		, oFont10 )

	oPrint:Say(nLinha	 , 1530 		,  Transform(nTotTrans,PesqPict("SE3","E3_BASE"))		, oFont10 )
	oPrint:Say(nLinha	 , 2000 		,  Transform((nTotal/nTotTrans) * 100 ,PesqPict("SE3","E3_PORC"))		, oFont10 )
	oPrint:Say(nLinha	 , 2500 		,  Transform(nTotal,PesqPict("SE3","E3_COMIS"))		, oFont10 )
    nLinha+=200
	oPrint:Line(nLinha, 2000, nLinha, 2700)
    nLinha+=50	
	oPrint:Say(nLinha	 , 2300 		, 'Assinatura ' 		, oFont10 )
	
Return
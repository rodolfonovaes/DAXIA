#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

/*/{Protheus.doc} DAXREL02
Recibo de pagamento de comissoes
@type function
@author Rodolfo
@since 03/06/2019
@version 1.0
/*/
User Function DAXREL02()
	Local cComp      := AnoMes(dDataBase)
	Local oPrint
	Local cNomeArq    := 'RECIBO_'+StrTran(DTOC(dDataBase),'/', '-') + "_" + StrTran(Time(),":","")+'.PDF'
	Local cLocal      := GetTempPath()
	Local aParam      := {}
	Local aRet        := {}	

	aAdd(aParam, {1, "Vendedor"   	, CriaVar('E3_VEND',.F.)  ,  ,, 'SA3',, 60, .T.} )
	aAdd(aParam, {1, "Data Inicial"   	,dDataBase  ,  ,, ,, 60, .T.} )
	aAdd(aParam, {1, "Data Final"   	, dDataBase ,  ,, ,, 60, .T.} )

	
	If ParamBox(aParam,'Parâmetros',aRet)
		oPrint := FWMSPrinter():New(cNomeArq, IMP_PDF, .T., cLocal, .T.,  .F., , ,  .T.,  .T., , .T.)
		oPrint:SetPortrait()
	
		RptStatus({|| lEnd:= ImpRel(oPrint,aRet)},"Imprimindo relatório...")
		//If lEnd
			oPrint:Preview()
		//EndIf	
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
/*/Static Function ImpRel(oPrint,aRet)
	Local cAliasQry  := GetNextAlias()
	Local cEmpAnt    := ""
	Local cEmpAtu    := ""
	Local cMes       := ""
	Local cAno       := ""
	Local oFont10    := TFont():New("Arial",9,12,.T.,.F.,5,.T.,5,.T.,.F.)
	Local oFont15    := TFont():New("Arial",14,12,.T.,.F.,5,.T.,5,.T.,.F.)
	Local lRet       := .T.
	Local nControle  := 1
	Local nLinha     := 0
	Local nColContr  := 0150
	Local nColVlrOri := 0550
	Local nColVlrMul := 0950
	Local nColVlrJur := 1350
	Local nColVlrTot := 1750
	Local nTotOri    := 0
	Local nTotMul    := 0
	Local nTotJur    := 0
	Local nTotGer    := 0
	Local nTotDesc   := 0
	Local nTotal    := 0
	Local nIrrf		:= 0
	Local nDesc      := 0
			
	BeginSQL Alias cAliasQry
	
		SELECT 	SUM(E3_COMIS) AS COMISSAO						
		FROM %TABLE:SE3% SE3					
			INNER JOIN  %TABLE:SA3% SA3 ON 			
			SA3.A3_FILIAL = %Exp:FWxFilial("SA3")% AND 
			SA3.A3_COD = SE3.E3_VEND 
		WHERE SA3.%NotDel%	AND
			SE3.E3_VEND = %Exp:aRet[1]% AND 
			SE3.E3_EMISSAO >= %Exp:DTOS(aRet[2])% AND 
			SE3.E3_EMISSAO <= %Exp:DTOS(aRet[3])% AND 				
			SE3.%NotDel%
	EndSQL
	
	If (cAliasQry)->(EOF())
		MsgInfo("Nenhum registro encontrado")
		lRet:= .F.
		Return
	EndIf
	
	Cabecalho(oPrint, cAliasQry,aRet) //Imprime Cabeçalho

	If (cAliasQry)->( ! Eof() )
		nTotal:= (cAliasQry)->COMISSAO
							
		oPrint:Say(500	 , 1300 		, 'TOTAL DE COMISSÕES SEM DSR '		, oFont10 )
		oPrint:Say(500	 , 2000 		,  Transform(nTotal,PesqPict("SE3","E3_COMIS"))		, oFont10 )
		oPrint:Say(550	 , 1300 		, 'DESCONTO DE IRRF', oFont10 )
		nIrrf := IRRF(nTotal)
		oPrint:Say(550	 , 2000 		,  Transform(nTotal * nIrrf ,PesqPict("SE3","E3_COMIS"))		, oFont10 )
		oPrint:Say(600	 , 1300 		, 'LIQUIDO A PAGAR ' 		, oFont10 )
		oPrint:Say(600	 , 2000 		, Transform(nTotal - (nTotal * nIrrf),PesqPict("SE3","E3_COMIS"))		, oFont10 )

		oPrint:Line(800, 1300, 800, 2200)		
		oPrint:Say(850	 , 1650 		, 'Assinatura ' 		, oFont10 )
	
	EndIf

	(cAliasQry)->(dbClosearea())
			
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
Static Function Cabecalho(oPrint, cAliasQry,aRet)
	Local oFont10    := TFont():New("Arial"      ,9,12,.T.,.T.,5,.T.,5,.T.,.F.)
	Local oFont15    := TFont():New("Arial"      ,20,12,.T.,.T.,5,.T.,5,.T.,.F.)
	Local oFont10c   := TFont():New("Calibre",9,12,.T.,.T.,5,.T.,5,.T.,.F.)
	Local cNomeEmp   := AllTrim(SM0->M0_NOMECOM)
	Local cEmissao   := OemToAnsi("Impresso em: ") + DtoC( dDataBase) + ' ' + Time()
	
	cCGC:= Transform(cCGC, "@R 99.999.999/9999-99")
	
	oPrint:StartPage()
	//Imprime quadro da folha
	oPrint:Line(0100, 0100, 0100, 2300)
	oPrint:Line(1000, 0100, 1000, 2300)
	oPrint:Line(0100, 2300, 1000, 2300)
	oPrint:Line(0100, 0100, 1000, 0100)
		
	oPrint:Say(0150, 1700, cEmissao, oFont10c)
	oPrint:Say(0150, 0150, "RECIBO DE PAGAMENTO DE COMISSOES" , oFont15)
	//oPrint:Line(0420, 0200, 0420, 2300)
	oPrint:Say(0250, 0150, "Periodo Considerado:    " + DTOC(aRet[2]) + ' a ' + DTOC(aRet[3]) , oFont15)
	oPrint:Say(0300, 0150, "Vendedor:               " + Posicione('SA3',1,xFilial('SA3') + aRet[1],'A3_NOME'), oFont15)

	//oPrint:Line(0420, 0100, 0420, 2300)
	
	oPrint:Say(0455, 1350, "FECHAMENTO DO RELATORIO DE COMISSOES"	, oFont15)
		
	
Return


Static Function IRRF(nValor)
Local nRet	:= 0
Local aCampos := IRFStruArq()
Local cArqTmp := ""
Local nX := 0
Local nY := 0
Local n	:= 0       
Local aArray := {}

cArqTmp := CriaTrab( aCampos , .T.)
dbUseArea( .T.,, cArqTmp, "cArqTmp", if(.F. .OR. .F., !.F., NIL), .F. )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ "Importa" o arquivo TXT com a tabela do I.R.       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea( "cArqTmp" )
If File( "SIGAADV.IRF" )
   APPEND FROM SIGAADV.IRF SDF            
	nX := cArqTmp->(RecCount())
   If nX < 5
		For nY := nX+1 to 5
		   RecLock( "cArqTmp" , .T. )
		Next
   Endif
Else        
	For nX := 1 to 5
	   RecLock( "cArqTmp" , .T. )
	Next
Endif     

dbGoTop()

While !Eof()
	Aadd(aArray, {LIMITE, ALIQUOTA, DEDUZIR})
	DbSkip()
End


For n := 1 to Len(aArray)
	If nValor <= val(aArray[n][1])
		nRet	:= val(aArray[n][2]) / 100
		exit
	EndIf
Next
Return nRet
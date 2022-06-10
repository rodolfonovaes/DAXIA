#include "Protheus.ch"
#include "TopConn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CLSBol341 ³ Autor ³ TOTVS OP                        ³ Data ³ 07/10/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Geração automática boletos de cobrança. Itau                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                       HISTORICO DE ATUALIZACOES DA ROTINA                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Desenvolvedor   ³ Data   ³Solic.³ Descricao                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                 ³        ³      ³                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function CLSBol341()
	Local cSql        := ""
	Local dDaData     := CTOD("")
	Local dAteData    := CTOD("")
	Local cNotaDe     := ""
	Local cNotaAte    := ""
	Local cSerie      := ""
	Local cBanco	     := ""
	Local cAgencia    := ""
	Local cConta      := ""
	Local nImpresso   := 0, nConsidera := 0
	Local aLog        := {}
	Local aItens      := {}
	Local i
	Local nTipoCart   := 2 //109 - Com Registro 
	//Local cAGeCta     := GetMV("MV_X_BO341")

	Private cPerg := padr("BOL341",Len(SX1->X1_GRUPO))

	GeraX1(cPerg)
	If !Pergunte(cPerg, .T.)
		Return Nil
	EndIf

	dDataDe   := mv_par01
	dDataAte  := mv_par02
	cNotaDe	  := mv_par03
	cNotaAte  := mv_par04
	cSerie    := mv_par05
	cBanco	   := mv_par06
	cAgencia  := mv_par07
	cConta    := mv_par08
	nImpresso := mv_par09
	nConsidera:= mv_par10

	If Empty(cBanco) .Or. Empty(cAgencia) .Or. Empty(cConta)
		HS_MsgInf("PROCESSO CANCELADO: Favor preencha os campos obrigatorios [Banco, Agencia e Conta]", "Mensagem", "ALERT")
		Return Nil
	EndIf

	// Customizado para aceitar somente banco Itau no pergunte.
	If !cBanco $ "341"
		HS_MsgInf(OemToAnsi("PROCESSO CANCELADO: O banco selecionado não pertence a esta rotina. Por favor confira o banco selecionado"), "Mensagem", "ALERT")
		Return
	EndIf
/*
	// Customizado para aceitar somente a conta especificad ano parametro
	aDad341 := StrTokarr(cAGeCta, ";")
	lOK := .F.
	For nCont := 1 To Len(aDad341)
		If AllTrim(cAgencia)+"/"+AllTrim(cConta) == aDad341[nCont]
			lOK := .T.
			Exit
		EndIf
	Next
*/
/*
	If !lOK
		HS_MsgInf(OemToAnsi("PROCESSO CANCELADO: Agencia/Conta selecionada não é permitida. Por favor confira o parametro [MV_X_BO341]"), "Mensagem", "ALERT")
		Return
	EndIf
*/
	cSql := " SELECT SE1.E1_FILIAL, SE1.E1_NUM, SE1.E1_PREFIXO, SE1.E1_EMISSAO, SE1.E1_PARCELA, SE1.E1_VALOR, SE1.E1_VENCTO, SE1.E1_NUMBCO, "
	cSql += " SE1.E1_TIPO, SE1.E1_PEDIDO, SE1.E1_VALJUR, SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NOME, SA1.A1_CGC, SA1.A1_ENDCOB, SA1.A1_BAIRROC, SA1.A1_CEPC, "
	cSql += " SA1.A1_MUNC, SA1.A1_ESTC, SA1.A1_PESSOA, SA1.A1_TIPO, SE1.E1_BARRA , SE1.R_E_C_N_O_ AS REC"
	cSql += " FROM " + RetSQLName("SE1") + " SE1 "

	If nConsidera == 1 //considera nota
		cSql += " JOIN " + RetSQLName("SF2") + " SF2  ON SF2.F2_FILIAL  =  '" + XFILIAL("SF2") + "' AND SF2.D_E_L_E_T_ <> '*' AND SF2.F2_DOC = SE1.E1_NUM "
		cSql += "                                       AND SF2.F2_SERIE = SE1.E1_SERIE "
		cSql += " JOIN " + RetSQLName("SC5") + " SC5 ON SC5.C5_FILIAL = '" + XFILIAL("SC5") + "' AND SC5.D_E_L_E_T_ <> '*' AND SC5.C5_NUM = SE1.E1_PEDIDO "
	Endif

	cSql += " JOIN " + RetSQLName("SA1") + " SA1 ON SA1.A1_FILIAL = '" + XFILIAL("SA1") + "' AND SA1.D_E_L_E_T_ <> '*' AND SE1.E1_CLIENTE = SA1.A1_COD "
	cSql += "                                AND SE1.E1_LOJA = SA1.A1_LOJA "

	cSql += " WHERE SE1.E1_FILIAL  =  '" + XFILIAL("SE1") + "' AND SE1.D_E_L_E_T_ <> '*' "
	cSql += " AND SE1.E1_TIPO  IN ('BOL','FT','NF') "
	cSql += " AND SE1.E1_SERIE = '" + cSerie + "' "

	If nImpresso == 1 //Sim
//		cSql += "                               AND SE1.E1_IMPBOL = 'S' "
		cSql += "                               AND SE1.E1_PORTADO <> '   ' "
	ElseIf nImpresso == 2 //Nao
		cSql += "                               AND SE1.E1_IMPBOL IN ('N', ' ') "
		cSql += "                               AND SE1.E1_PORTADO = '   ' "
	EndIf

	If !Empty( cNotaAte )
		cSql += " AND SE1.E1_NUM BETWEEN '" + cNotaDe + "' AND '" + cNotaAte + "' "
	EndIf

	If !Empty( dDataAte )
		cSql += " AND " + IIF(nConsidera == 1, "SF2.F2_", "SE1.E1_") + "EMISSAO BETWEEN '" + DToS( dDataDe ) + "' AND '" + DToS( dDataAte ) + "' "
	EndIf

	If SA1->(FieldPos("A1_USADDA"))>0
		cSql += " AND SA1.A1_USADDA <> '1' "
	Endif

	//Impressao pela DANFE inclui filtro de cliente imprime boleto
	If FunName() == "SPEDNFE"
		
		cSql += " AND SA1.A1_YBOLETO = 'S' "
		cSql += " AND ( SA1.A1_BCO1 = '341' OR SA1.A1_BCO2 = '341' ) "
		cSql += " AND SA1.A1_BCO1 <> '   ' "
		If nConsidera == 1
			cSQL += " AND F2_FIMP = 'S' "
		Endif

		cSQL += " AND E1_SALDO > 0 "

	Endif 

	If nConsidera == 1
		cSql += " ORDER BY F2_EMISSAO,F2_DOC, E1_PARCELA"
	Else
		cSql += " ORDER BY E1_EMISSAO,E1_NUM, E1_PARCELA"
	Endif

	DbUseArea( .T., "TOPCONN", TCGENQRY(,,ChangeQuery( cSql ) ), "TMPSE1", .F., .T. )

	DbGoTop()

	If EOF()
		HS_MsgInf("Não foram encontrados registros para os parâmetros selecionado. Por favor verifique.","Atenção","Não foram encontrados registros para os parâmetros selecionados.")
		TMPSE1->( DbCloseArea() )
		Return
	EndIf

	DbSelectArea( "SA6" )
	DbSetOrder( 1 ) // A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
	If !DbSeek( xFilial("SA6") + cBanco + cAgencia + cConta)
		HS_MsgInf("O Banco [" + cBanco + "] Agencia [" + cAgencia + "] Conta [" + cConta + "] selecionado não foi encontrado." +CHR(10)+;
		"Por favor selecione um banco válido.","Erro","Banco não cadastrado.")
		TMPSE1->( DbCloseArea() )
		Return Nil
	EndIf

	cMsg := ""
	While !TMPSE1->( Eof() )

		//Verifica se a condição de pagamento não é ANT (Antecipado)
		If Posicione("SF2",1,xFilial("SF2")+TMPSE1->E1_NUM+TMPSE1->E1_PREFIXO+TMPSE1->A1_COD+TMPSE1->A1_LOJA,"F2_COND") == "ANT"
		//	Alert("Titulo " + SE1->E1_NUM + " prefixo " + SE1->E1_PREFIXO + " não gerará boleto por ser condição de pagamento Antecipado")
		//	dbSelectArea("SE1")
			TMPSE1->( DbSkip() )
			Loop 
		Endif



		If !Empty(TMPSE1->E1_BARRA) .And. SUBSTR(TMPSE1->E1_BARRA, 1, 3) <> cBanco
			cMsg += IIF(!Empty(cMSg), "  **  ", "") + TMPSE1->E1_PREFIXO + "-" + TMPSE1->E1_NUM + "-" + TMPSE1->E1_PARCELA
		Else
			AAdd( aItens, { SA6->A6_FILIAL, cBanco, cAgencia, cConta, TMPSE1->E1_FILIAL, TMPSE1->E1_PREFIXO, TMPSE1->E1_NUM, TMPSE1->E1_PARCELA, TMPSE1->E1_TIPO, xFilial("SA1") , TMPSE1->REC} )
		EndIf
		TMPSE1->( DbSkip() )
	End

	TMPSE1->( DbCloseArea() )

	If !Empty(cMsg)
		MsgAlert("Existe(m) titulo(s) com Boletos já gerados para outro banco!" + CHR(13)+CHR(10)+;
		"Serão gerados/reimpressos apenas os titulos para o banco selecionado." +CHR(13)+CHR(10)+;
		cMsg, "Validação Boleto X Banco")
	EndIf

	//Processa( { |lEnd| U_CLiBol341(aItens, @aLog, nTipoCart) } )
	Processa( { |lEnd| U_PDFBOL341(aItens, @aLog, nTipoCart) } )

	If !Empty(aLog)
		HS_MsgInf("Existem alguns Erros/Avisos que ocorreram durante a impressão do relatório. Por favor verifique.",;
		"Atenção!", "A impressão de boleto gerou algumas mensagens." )
		// Gera relatório de erro de impressão.
		ImpRel( aLog )
	EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GeraX1   ³ Autor ³ Microsiga             ³ Data ³ 10/04/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica as perguntas inclu¡ndo-as caso n„o existam        ³±±
±±³          ³ Com tratamento para V10                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GeraX1()
	LOCAL aArea    := GetArea()
	LOCAL aRegs    := {}
	LOCAL i        := 0
	LOCAL j        := 0
	LOCAL aHelpPor  := {}
	LOCAL aHelpSpa  := {}
	LOCAL aHelpEng  := {}
	LOCAL cGruDoc   := "018" // Grupo de documento de entrada e saida
	//                                                                    1                                      2                             3                                     4
	//  1     2                      3   4  5        6   7  8 9 0  1   2         3   4  5  6  7  8  9  0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5  6  7     8  9       0
	AAdd(aRegs,{cPerg,"01","Da Data ?                 ","","","mv_ch1","D",08,0,0,"G","","mv_par01",""     , "", "","","",""       ,"","","","","","","","","","","","","","","","","","","   ","",     "","","","" })
	AAdd(aRegs,{cPerg,"02","Até a Data ?              ","","","mv_ch2","D",08,0,0,"G","","mv_par02",""     , "", "","","",""       ,"","","","","","","","","","","","","","","","","","","   ","",     "","","","" })
	AADD(aRegs,{cPerg,"03","Do Titulo ?               ","","","mv_ch3","C",06,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","   ","",cGruDoc,"","",""})
	AADD(aRegs,{cPerg,"04","Até Titulo ?              ","","","mv_ch4","C",06,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","   ","",cGruDoc,"","",""})
	AADD(aRegs,{cPerg,"05","Serie ?                   ","","","mv_ch5","C",03,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","01 ","","     ","","",""})
	AADD(aRegs,{cPerg,"06","Banco ?                   ","","","mv_ch6","C",03,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","SA6","","     ","","",""})
	AADD(aRegs,{cPerg,"07","Agencia  ?                ","","","mv_ch7","C",05,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","   ","","     ","","",""})
	AADD(aRegs,{cPerg,"08","Conta ?                   ","","","mv_ch8","C",10,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","   ","","     ","","",""})
	AAdd(aRegs,{cPerg,"09","Impressos ?               ","","","mv_ch9","N",01,0,0,"C","","mv_par09", "Sim", "", "","","","Nao","","","","","Ambos","","","","","","","","","","","","","","   ","",     "","","","" })
	AAdd(aRegs,{cPerg,"10","Considerar ?              ","","","mv_cha","N",01,0,0,"C","","mv_par10", "Nota de Saida", "", "","","","Titulo ","","","","","","","","","","","","","","","","","",""," ","", "","","","" })

	dbSelectArea("SX1")
	dbSetOrder(1)

	For i:=1 to Len(aRegs)

		If !dbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			For j := 1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next

			// se tiver grupo de campo, ajusta tamanho da pergunta
			IF !empty(aRegs[i,40])
				IF SXG->( DbSeek( PADR(aRegs[i,40],Len(SXG->XG_GRUPO)) ) )
					SX1->X1_TAMANHO := SXG->XG_SIZE
				ENDIF
			ENDIF

			MsUnlock()

			// criacao do Help
			aHelpPor := {}
			aHelpSpa := {}
			aHelpEng := {}

			IF i==1
				AADD(aHelpPor,"Informe a Data inicial a ser considera-")
				AADD(aHelpPor,"da na impressao.                       ")
			ELSEIF i==2
				AADD(aHelpPor,"Informe a Data final a ser considerada ")
				AADD(aHelpPor,"na impressao.                          ")
			ELSEIF i==3
				AADD(aHelpPor,"Informe o número inicial da fatura a   ")
				AADD(aHelpPor,"ser considerada na impressao           ")
			ELSEIF i==4
				AADD(aHelpPor,"Informe o número final da fatura a     ")
				AADD(aHelpPor,"ser considerada na impressao           ")
			ELSEIF i==5
				AADD(aHelpPor,"Informe a serie a ser considerada na   ")
				AADD(aHelpPor,"impressao                              ")
			ELSEIF i==6
				AADD(aHelpPor,"Informe o banco para impressão         ")
				AADD(aHelpPor,"                                       ")
			ELSEIF i==7
				AADD(aHelpPor,"Informe a agencia para impressão       ")
				AADD(aHelpPor,"                                       ")
			ELSEIF i==8
				AADD(aHelpPor,"Selecione a C/C para impressão         ")
			ELSEIF i==9
				AADD(aHelpPor,"Informe se sera considerados os titulos")
				AADD(aHelpPor,"ja impressos, nao impressos ou ambos.  ")
			ELSEIF i==10
				AADD(aHelpPor,"Informe se o sistema deve considerar   ")
				AADD(aHelpPor,"Notas de Saidas ou apenas Titulos      ")
			ENDIF
			PutSX1Help("P."+alltrim(cPerg)+strzero(i,2)+".",aHelpPor,aHelpEng,aHelpSpa)

		Endif
	Next
	RestArea(aArea)

return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ImpRel   ³ Autor ³ Adriano Orlovski      ³ Data ³ 20070828 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Imprime relatório de inconsistencias.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Uso Generico.                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImpRel( aItens )
	Local cDesc1     := ""
	Local cDesc2     := ""
	Local cDesc3     := ""
	Local cString    := ""
	Local wnRel		 := ""
	Local lEnd       := .F.
	Local nLen       := 0

	Private dDataDe    := ""
	Private dDataAte   := ""
	Private cFornDe    := ""
	Private cFornAte   := ""
	Private cFilDe     := ""
	Private cFilAte    := ""
	Private cProdutDe  := ""
	Private cProdutAte := ""
	Private nQtdProd   := ""

	Private aReturn    := {"Zebrado" , 1, "Administra‡„o" , 2, 2, 1, "",1 }
	Private aLinha     := {}
	Private nLastKey   := 0
	Private cPerg      := ""
	Private m_pag      := 1

	Private cTitulo    := OemToAnsi("Relatório de Inconformidades")
	Private cCabec1    := "" // Cabeçalho 01
	Private cCabec2    := ""
	Private cTamanho   := "M"
	Private cNomeProg  := "LIIMPBOL"

	wnrel := cNomeProg
	wnrel := SetPrint( cString, wnRel, cPerg, cTitulo, cDesc1, cDesc2, cDesc3, .F., , , cTamanho )

	If nLastKey == 27
		Return Nil
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return Nil
	Endif

	If !( nLastKey == 27 )

		RptStatus( { || PrnRel( aItens ) } , "Imprimindo " + cTitulo )

		If aReturn[5] = 1
			Set Printer To
			Commit
			Ourspool(wnrel)
		EndIf

		MS_FLUSH()

	EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PnrRel   ³ Autor ³ Adriano Orlovski      ³ Data ³ 20070828 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Impime relatório de inconsistencias.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Uso Generico.                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PrnRel( aItens )
	Local i          := 0
	Local nLen       := Len( aItens )
	// Imprime dados
	If nLastKey == 27
		@ ++nLin, 000 PSay "******** CANCELADO PELO OPERADOR ********"
		Return Nil
	EndIf

	ProcRegua( Len( aItens ) )
	//            1         2         3         4         5         6         7         8         9
	//   123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	//

	If !Empty( aItens )
		j    := 1  //
		nLin := 60
		lPrintFil := .T.
		For i := 1 To nLen
			If nLin > 55
				nLin := Cabec( cTitulo, cCabec1, cCabec2, cNomeProg, cTamanho, 15 ) + 1//  Cria cabeçalho do relatório
			Endif
			@ nLin++, 000 PSay aItens[i]
			nLin++
			IncProc()
		Next
	EndIf

Return Nil


#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} ImpExtAree()
Efetua a impressao do extrato de arrecadação

@author    Janaina de Jesus
@since     21/03/2019
@version   1.0
/*/
//-------------------------------------------------------------------
User Function ImpExtAree()
	Local oPrint
	Local cNomeArq   := 'Extrato'+StrTran(DTOC(dDataBase),'/', '-') + "_" + StrTran(Time(),":","")+'.PDF'
	Local cLocal     := GetTempPath()
	Local aParam     := {}
	Local cRef       := AnoMes(dDataBase)

	Private lEnd    := .F.// Controle de cancelamento do relatorio

	aAdd( aParam ,{1, "Empresa de "  ,'        ', "@!",,"",'.T.',50,.F.})
	aAdd( aParam ,{1, "Empresa ate " ,'        ', "@!",,"",'.T.',50,.T.})	
	aAdd( aParam ,{1, "Referencia de (AAAAMM)" ,Space(6), "@R 9999/99",,,'.T.',50,.F.})
	aAdd( aParam ,{1, "Referencia ate (AAAAMM)" ,cRef, "@R 9999/99",,,'.T.',50,.T.})

	If !ParamBox(aParam, "Parâmetros", , , , , , , , , .T., .F.)
		Return
	EndIf

	oPrint := FWMSPrinter():New(cNomeArq, IMP_PDF, .T., cLocal, .T.,  .F., , ,  .T.,  .T., , .T.)
	oPrint:SetPortrait()

	RptStatus({|lEnd| ImpRel(@lEnd,oPrint)},"Imprimindo Extrato...")

	If !lEnd
		oPrint:Preview()
	EndIf

Return

/*/{Protheus.doc} Imprel
Gerar relatório de extrato de arrecadação
@author    Janaina de Jesus
@since     21/03/2019
@version   1.0
/*/
Static Function Imprel(lEnd,oPrint)
	Local cAliasSE1	:= GetNextAlias()
	Local cAliasSE1X:= GetNextAlias()
	Local cAliasSE5 := ""
	Local cAliasZ08 := ""
	Local cSituac   := ""
	Local cValPag   := ""
	Local cPerc     := ""
	Local cCliAtu   := ""
	Local cCliAnt   := ""
	Local cDtPgto   := ""
	Local cNumLiq   := ""
	Local cFRC      := ""
	Local cDtVencto := ""
	Local cNumReLiq := ""
	Local oFont10  	:= TFont():New("Arial",9,12,.T.,.F.,5,.T.,5,.T.,.F.)
	Local nPagina   := 1
	Local nControle := 1
	Local nX        := 0
	Local nLinha    := 0
	Local nColRef   := 0150
	Local nColDtVc  := 0300
	Local nColPerc  := 0600
	Local nColVlr   := 0900
	Local nColTit   := 1100
	Local nCOlConv  := 1400
	Local nColSit   := 1700
	Local nColResp  := 1930
	Local nColDtPg  := 2100
	Local aNeg      := {}
	Local lReliq    := .F.

	BeginSQL Alias cAliasSE1
		SELECT 	SE1.E1_FILIAL,
		SE1.E1_XCOMP,
		SE1.E1_PREFIXO,
		SE1.E1_PARCELA,
		SE1.E1_TIPO,
		SE1.E1_NUM,
		SE1.E1_CLIENTE,
		SE1.E1_LOJA,
		SE1.E1_NOMCLI,
		SE1.E1_BAIXA,
		SE1.E1_VALOR,
		SE1.E1_SALDO,
		SE1.E1_VALLIQ,
		SE1.E1_VENCTO,
		SE1.E1_XPERC,
		SE1.E1_NUMBCO,
		SE1.E1_SALDO,
		SE1.E1_TIPOLIQ
		FROM %Table:SE1% SE1
		WHERE
		SE1.%NotDel% AND
		SE1.E1_CLIENTE >= %Exp:MV_PAR01% AND
		SE1.E1_CLIENTE <= %Exp:MV_PAR02% AND
		SE1.E1_XCOMP   >= %Exp:MV_PAR03% AND
		SE1.E1_XCOMP   <= %Exp:MV_PAR04% AND
		SE1.E1_PREFIXO = 'ARE'
		ORDER BY
		SE1.E1_CLIENTE,
		SE1.E1_XCOMP
	EndSQL

	If (cAliasSE1)->( ! Eof() )
		Cabecalho(oPrint, cAliasSE1) //Imprime Cabeçalho
		SETREGUA((cAliasSE1)->(RecCount()))
	Else
		MsgInfo("Não foram encontratos dados para impressão com os parâmetros informados.")
		Return
	EndIf

	While (cAliasSE1)->( ! Eof() )

		IncRegua()

		If lEnd
			(cAliasSE1)->(dbClosearea())
			@PROW()+1, 001 PSay OemToAnsi("CANCELADO PELO OPERADOR")
			Return
		EndIf
		cRef      := ""
		cDtPgto	  := ""
		cPerc     := ""
		cValPag	  := ""	
		cSituac   := ""
		cFRC      := ""
		cDtVencto := ""
		cNumReLiq := ""
		aNeg      := {}		
		lReliq    := .F.

		If (cAliasSE1)->E1_TIPOLIQ == "LIQ" //Caso seja titulo de liquidação
			cAliasSE5	:= GetNextAlias()

			BeginSQL Alias cAliasSE5
				SELECT SE5.E5_DOCUMEN, * FROM %Table:SE5% SE5
				WHERE
				SE5.E5_FILIAL 	= %Exp:(cAliasSE1)->E1_FILIAL% AND
				SE5.E5_PREFIXO	= %Exp:(cAliasSE1)->E1_PREFIXO% AND
				SE5.E5_NUMERO 	= %Exp:(cAliasSE1)->E1_NUM% AND
				SE5.E5_PARCELA 	= %Exp:(cAliasSE1)->E1_PARCELA% AND
				SE5.E5_CLIFOR 	= %Exp:(cAliasSE1)->E1_CLIENTE% AND
				SE5.E5_SITUACA 	<> 'C' AND
				SE5.E5_LOJA 	= %Exp:(cAliasSE1)->E1_LOJA% AND
				SE5.%NotDel%
			EndSQL

			If (cAliasSE5)->( ! Eof() )
				cNumLiq := (cAliasSE5)->E5_DOCUMEN
			EndIf

			(cAliasSE5)->(dbClosearea())

			dbSelectArea("SE1")
			dbSetOrder(15)

			If dbSeek(xFilial("SE1") + Alltrim(cNumLiq))
				If SE1->E1_TIPOLIQ == 'LIQ' //Caso de Reliquidação
					BeginSQL Alias cAliasSE5
						SELECT SE5.E5_DOCUMEN, * FROM %Table:SE5% SE5
						WHERE
						SE5.E5_FILIAL 	= %Exp:SE1->E1_FILIAL% AND
						SE5.E5_PREFIXO	= %Exp:SE1->E1_PREFIXO% AND
						SE5.E5_NUMERO 	= %Exp:SE1->E1_NUM% AND
						SE5.E5_PARCELA 	= %Exp:SE1->E1_PARCELA% AND
						SE5.E5_CLIFOR 	= %Exp:SE1->E1_CLIENTE% AND
						SE5.E5_SITUACA 	<> 'C' AND
						SE5.E5_LOJA 	= %Exp:SE1->E1_LOJA% AND
						SE5.%NotDel%
					EndSQL

					If (cAliasSE5)->( ! Eof() )
						cNumReLiq := (cAliasSE5)->E5_DOCUMEN
						lReliq := .T.
					EndIf

					(cAliasSE5)->(dbClosearea())

					//cAliasSE1X	:= GetNextAlias()

					BeginSQL Alias cAliasSE1X
						SELECT * FROM %Table:SE1% SE1
						WHERE
						SE1.E1_NUMLIQ = %Exp:cNumReLiq% AND
						SE1.D_E_L_E_T_ = ''
					EndSQL


					While !(cAliasSE1X)->(Eof())
						cSituac := "Reliquidado"

						If (cAliasSE1X)->E1_VALLIQ <> 0
							cValPag := cValToChar(Transform((cAliasSE1X)->E1_VALLIQ, PesqPict("SE1","E1_SALDO")))
						Else
							cValPag := cValToChar(Transform((cAliasSE1X)->E1_SALDO, PesqPict("SE1","E1_SALDO")))
						EndIf
						
						aadd(aNeg, {(cAliasSE1X)->E1_PREFIXO + "-" + (cAliasSE1X)->E1_NUM + "-" + (cAliasSE1X)->E1_PARCELA,;
						            DTOC(STOD((cAliasSE1)->E1_VENCTO)),;
									Iif(Empty((cAliasSE1X)->E1_BAIXA), "Aberto", "Tit.Neg. Pago"),;
									Alltrim(cValPag),;
									DTOC(STOD((cAliasSE1X)->E1_BAIXA))})

						(cAliasSE1X)->(dbSkip())
					EndDo

					(cAliasSE1X)->(dbClosearea())

				Else
					cSituac := Iif(Empty(SE1->E1_BAIXA), "Em negociação", "Tit.Neg. Pago")
					cDtVencto := DTOC(STOD((cAliasSE1)->E1_VENCTO))
					cDtPgto := DTOC(SE1->E1_BAIXA)
				EndIf

			EndIf

			cValPag := cValToChar(Transform((cAliasSE1)->E1_VALLIQ, PesqPict("SE1","E1_SALDO")))

			cAliasZ08	:= GetNextAlias()

			BeginSQL Alias cAliasZ08
				SELECT * FROM %Table:Z08% Z08
				WHERE
				Z08.Z08_NUMLIQ = %Exp:cNumLiq% AND
				Z08.%NotDel%
			EndSQL

			If (cAliasZ08)->( ! Eof() ) //Caso tenha liquidação, trago o número da FRC
				cFRC := (cAliasZ08)->Z08_NCALC
			EndIf
			(cAliasZ08)->(dbClosearea())

		EndIf

		If nControle == 1
			nLinha := 0450
			cCliAtu := (cAliasSE1)->E1_CLIENTE
			cCliAnt := (cAliasSE1)->E1_CLIENTE
		Else
			nLinha += 50
			If nLinha >= 2900 //Se atingir o tamanho máximo imprime nova folha
				oPrint:EndPage()
				oPrint:StartPage()
				nPagina ++
				//Imprime quadro da folha
				oPrint:Line(0050, 0100, 0050, 2300)
				oPrint:Line(3000, 0100, 3000, 2300)
				oPrint:Line(0050, 2300, 3000, 2300)
				oPrint:Line(0050, 0100, 3000, 0100)
				oPrint:Say(0100, 1800, "Página: " + Padl(cValtoChar(nPagina),4,"0"), oFont10)
				nLinha := 0200
			EndIf
		EndIf

		If cCliAnt <> cCliAtu //Inicia uma nova folha para outro cliente
			oPrint:EndPage()
			nPagina := 1
			nLinha := 0450
			Cabecalho(oPrint, cAliasSE1) //Imprime Cabeçalho
		EndIf

		dbSelectArea("SE5")
		dbSetOrder(7)

		dbSeek(xFilial("SE5") + (cAliasSE1)->E1_PREFIXO + (cAliasSE1)->E1_NUM + (cAliasSE1)->E1_PARCELA + (cAliasSE1)->E1_TIPO + (cAliasSE1)->E1_CLIENTE + (cAliasSE1)->E1_LOJA)

		cRef    := Transform((cAliasSE1)->E1_XCOMP, "@R 9999/99")

		If (cAliasSE1)->E1_VALLIQ <> 0
			cValPag := cValToChar(Transform((cAliasSE1)->E1_VALLIQ, PesqPict("SE1","E1_SALDO")))
		Else
			cValPag := cValToChar(Transform((cAliasSE1)->E1_SALDO, PesqPict("SE1","E1_SALDO")))
		EndIf

		If Empty(cSituac)
			If SE5->E5_MOTBX == 'DAC' //BAIXA SEM FUNCIONARIO
				cSituac := "Sem Func."
				cValPag := cValToChar(Transform(0, PesqPict("SE1","E1_SALDO")))
			Else
				cSituac := Iif(Empty((cAliasSE1)->E1_BAIXA), "Aberto", "Pago")
			EndIf
		EndIf

		If Empty(cPerc)
			cPerc   := Transform((cAliasSE1)->E1_XPERC, PesqPict("SE1","E1_SALDO"))
		EndIf
		If Empty(cDtPgto)
			cDtPgto := DTOC(Stod((cAliasSE1)->E1_BAIXA))
		EndIf
		If Empty(cDtVencto)
			cDtVencto:= DTOC(Stod((cAliasSE1)->E1_VENCTO))
		EndIf

		oPrint:Say(nLinha, nColRef 	, cRef					, oFont10 )
		oPrint:Say(nLinha, nColDtVc	, cDtVencto				, oFont10 )
		oPrint:Say(nLinha, nColPerc	, Alltrim(cPerc)		, oFont10 )
		oPrint:Say(nLinha, nColVlr	, Alltrim(cValPag)		, oFont10 )
		oPrint:Say(nLinha, nColTit	, (cAliasSE1)->E1_NUM	, oFont10 )
		oPrint:Say(nLinha, nCOlConv	, (cAliasSE1)->E1_NUMBCO, oFont10 )
		oPrint:Say(nLinha, nColSit	, cSituac				, oFont10 )
		oPrint:Say(nLinha, nColResp	, cFRC					, oFont10 )
		If !lReliq
			oPrint:Say(nLinha, nColDtPg	, cDtPgto				, oFont10 )
		EndIf

		If !Empty(aNeg)
			For nX:= 1 To Len(aNeg)
				nLinha += 50
				If nLinha >= 2900 //Se atingir o tamanho máximo imprime nova folha
					oPrint:EndPage()
					oPrint:StartPage()
					nPagina ++
					//Imprime quadro da folha
					oPrint:Line(0050, 0100, 0050, 2300)
					oPrint:Line(3000, 0100, 3000, 2300)
					oPrint:Line(0050, 2300, 3000, 2300)
					oPrint:Line(0050, 0100, 3000, 0100)
					oPrint:Say(0100, 1800, "Página: " + Padl(cValtoChar(nPagina),4,"0"), oFont10)
					nLinha := 0200
				EndIf
				oPrint:Say(nLinha, nColRef 	, ""			, oFont10 )
				oPrint:Say(nLinha, nColDtVc	, aNeg[nX,2]	, oFont10 )
				oPrint:Say(nLinha, nColPerc	, ""			, oFont10 )
				oPrint:Say(nLinha, nColVlr	, aNeg[nX,4]	, oFont10 )
				oPrint:Say(nLinha, nColTit	, aNeg[nX,1]	, oFont10 )
				oPrint:Say(nLinha, nCOlConv	, ""			, oFont10 )
				oPrint:Say(nLinha, nColSit	, aNeg[nX,3]	, oFont10 )
				oPrint:Say(nLinha, nColResp	, ""			, oFont10 )
				oPrint:Say(nLinha, nColDtPg	, aNeg[nX,5]	, oFont10 )
			Next nX
		EndIf

		nControle++

		cCliAnt := (cAliasSE1)->E1_CLIENTE

		(cAliasSE1)->(dbSkip())

		cCliAtu := (cAliasSE1)->E1_CLIENTE

	EndDo

	(cAliasSE1)->(dbClosearea())

Return

Static Function Cabecalho(oPrint, cAliasSE1)
	Local oFont10    := TFont():New("Arial"   ,9,12,.T.,.T.,5,.T.,5,.T.,.F.)
	Local oFont10c   := TFont():New("Calibre" ,9,12,.T.,.T.,5,.T.,5,.T.,.F.)
	Local cNomeEmp   := AllTrim(SM0->M0_NOMECOM)
	Local cEmissao   := OemToAnsi("Emissao: ") + DtoC( dDataBase)
	Local cCodCli    := (cAliasSE1)->E1_CLIENTE
	Local cCGC       := Posicione("SZ9", 1, xFilial("SZ9")+cCodCli,"Z9_CGC")
	Local cNomeCli   := Alltrim(Posicione("SZ9", 1, xFilial("SZ9")+cCodCli,"Z9_NOME"))
	Local cEndCli    := Alltrim(Posicione("SZ9", 1, xFilial("SZ9")+cCodCli,"Z9_END"))
	Local cBairro    := Alltrim(Posicione("SZ9", 1, xFilial("SZ9")+cCodCli,"Z9_BAIRRO"))
	Local cCidade    := Alltrim(Posicione("SZ9", 1, xFilial("SZ9")+cCodCli,"Z9_MUN"))
	Local cCEP       := Posicione("SZ9", 1, xFilial("SZ9")+cCodCli,"Z9_CEP")
	Local cUF        := Posicione("SZ9", 1, xFilial("SZ9")+cCodCli,"Z9_EST")
	Local cCodContab := Posicione("SZ9", 1, xFilial("SZ9")+cCodCli,"Z9_XCONT")
	Local cContab    := Posicione("SZF",1,xFilial("SZF")+cCodContab, "ZF_NOME")
	Local cDDD       := Posicione("SZ9", 1, xFilial("SZ9")+cCodCli,"Z9_DDD")
	Local cTel       := Posicione("SZ9", 1, xFilial("SZ9")+cCodCli,"Z9_TEL")

	cCGC:= Transform(cCGC, "@R 99.999.999/9999-99")

	oPrint:StartPage()
	//Imprime quadro da folha
	oPrint:Line(0100, 0100, 0100, 2300)
	oPrint:Line(2900, 0100, 2900, 2300)
	oPrint:Line(0100, 2300, 2900, 2300)
	oPrint:Line(0100, 0100, 2900, 0100)

	oPrint:Say(0150, 0150, cNomeEmp, oFont10c)
	oPrint:Say(0150, 1900, cEmissao, oFont10c)

	oPrint:Say(0200, 0150, "Empresa: " + cCGC, oFont10c)
	oPrint:Say(0200, 0700, cCodCli + " - " + cNomeCli, oFont10c)
	oPrint:Say(0250, 0150, "End.: " + cEndCli, oFont10c)
	oPrint:Say(0250, 1500, cBairro, oFont10c)
	oPrint:Say(0300, 0150, cCidade, oFont10c)
	oPrint:Say(0300, 0700, Transform(cCEP, "@R 99999-999"), oFont10c)
	oPrint:Say(0300, 1500, cUF, oFont10c)
	oPrint:Say(0300, 1700, "Tel: " + cDDD + cTel ,oFont10c)

	oPrint:Say(0350, 0150, cContab, oFont10c)
	oPrint:Say(0350, 1500, cCodContab, oFont10c)

	oPrint:Line(0370, 0100, 0370, 2300)

	oPrint:Say(0400, 0150, "Refer.", oFont10)
	oPrint:Say(0400, 0300, "Dt. Vencto.", oFont10)
	oPrint:Say(0400, 0600, "Percentual", oFont10)
	oPrint:Say(0400, 0900, "Valor", oFont10)
	oPrint:Say(0400, 1100, "Nº Título", oFont10)
	oPrint:Say(0400, 1400, "Convênio", oFont10)
	oPrint:Say(0400, 1700, "Situação", oFont10)
	oPrint:Say(0400, 1930, "Nº FRC", oFont10)
	oPrint:Say(0400, 2100, "Dt. Pagto.", oFont10)

	oPrint:Line(0420, 0100, 0420, 2300)

Return

/*/{Protheus.doc} PicCGC
//TODO Função que traz a picture do campo CGC de acordo com o Tipo de pessoa
@author Janaina de Jesus
@since 18/03/2020
@version 1.0
@param cCodCli, characters, descricao
@type function
/*/
User Function PicCGC(cCodCli)
	Local cPic  := ""
	Local aArea := GetArea()
	
	Default cCodCli := ""
	
	dbSelectArea("SA1")
	dbSetOrder(1)
	
	If dbSeek(xFilial("SA1") + cCodCli)
		If SA1->A1_PESSOA == ''
			cPic := "@R 99.999.999/9999-99"
		Else
			cPic := "@R 999.999.999-99"
		EndIf
	EndIf
	
	RestArea(aArea)
	
Return cPic

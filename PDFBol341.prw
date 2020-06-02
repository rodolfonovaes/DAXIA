#include "Protheus.ch"
#include "TopConn.ch"
#INCLUDE "FWPrintSetup.ch"
#include "ap5mail.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "RPTDEF.CH"

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Programa  ≥CLIBOL341 ≥ Autor ≥ TOTVS OP              ≥ Data ≥ 07/10/15 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriÁ„o ≥ Emiss„o de boletos do Itau                                 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥ Generico                                                   ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥                HISTORICO DE ATUALIZACOES DA ROTINA                    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Programador ≥ Data   ≥Solic.≥ Descricao                                ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥            ≥        ≥      ≥Inclusao boleto                           ≥±±
±±≥            ≥        ≥      ≥                                          ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

Criar Campos
==================================================================================================

Campo:			E1_NUMBOL
Tipo:			C
Tamanho:		10
Decimal:		00
Formato:		@!
Contexto:		Real
Propriedade:	Visualizar
Titulo:			Noss.N˙m
DescriÁ„o:		CÛpia do Nosso numero, serve para manter o nosso numero em casos de estorno de bordero

Campo:			E1_IMPBOL
Tipo:			C
Tamanho:		 1
Decimal:		00
Formato:		@!
Contexto:		Real
Propriedade:	Visualizar
Titulo:			Impr.Boleto
DescriÁ„o:		Imprimiu Boleto.

Campo:			E1_DVNSNUM
Tipo:			C
Tamanho:		1
Decimal:		00
Formato:		@!
Contexto:		Real
Propriedade:	Visualizar
Titulo:			DV Noss.N˙m
DescriÁ„o:		Dig. Verifc. Nosso N˙mero

Campo:			E1_LINDIG
Tipo:			C
Tamanho			54
Contexto:		Real
Propriedade:	Visualizar
Titulo:			Linha Dig
DescriÁ„o:		Linha Digitavel do Boleto
Help:			Trata-se da representaÁ„o digit·vel do cÛdigo de barras

Campo:			E1_BARRA
Tipo:			C
Tamanho			44
Contexto:		Real
Propriedade:	Visualizar
Titulo:			CÛd Barras
DescriÁ„o:		CÛdigo de barras
Help:			CÛdigo de barras

Campo:			A6_AGEBOL
Tipo:			C
Tamanho:		5
Decimal:		00
Contexto:		Real
Propriedade:	Alterar
Titulo:			Num.Age.Bol
DescriÁ„o:		Num.Agencia Boleto
Help:			Numero da agÍncia para boleto, conforme p·dr„o exigido pelo banco para impress„o/geraÁ„o dos boletos.

Campo:			A6_CONBOL
Tipo:			C
Tamanho:		6
Decimal:		00
Contexto:		Real
Propriedade:	Alterar
Titulo:			Num.Con.Bol
DescriÁ„o:		Num.Conta p/Boleto
Help:			Numero da Conta Corrente para boleto, conforme p·dr„o exigido pelo banco para impress„o/geraÁ„o dos boletos.

Campo:			A6_DVCC
Tipo:			C
Tamanho:		2
Decimal:		00
Formato:		@!
Contexto:		Real
Propriedade:	Alterar
Titulo:			DV CC
DescriÁ„o:		Dig. Verifc. Cta. Corr.

Campo:			A6_PROXNUM
Tipo:			C
Tamanho:		20
Decimal:		00
Contexto:		Real
Propriedade:	Alterar
Titulo:			Seq. Boleto
DescriÁ„o:		Sequencial do Boleto

Campo:			A6_ACEITE
Tipo:			C
Tamanho:		03
Decimal:		00
Formato:		@!
Contexto:		Real
Propriedade:	Alterar
Titulo:			Aceite
DescriÁ„o:		Aceite

Campo:		A6_ESPDOC
Tipo:			C
Tamanho:		03
Decimal:		00
Formato:		@!
Contexto:		Real
Propriedade:	Alterar
Titulo:			EspÈc.Documen
DescriÁ„o:		EspÈcie do Documento

Campo:			A6_ARQLOGO
Tipo:			C
Tamanho:		60
Decimal:		00
Formato:		@!
Contexto:		Real
Propriedade:	Alterar
Titulo:			Arq Logotipo
DescriÁ„o:		Arquivo do logotipo

Campo:			A6_LOCPAG
Tipo:			C
Tamanho:		55
Decimal:		00
Formato:		@!
Contexto:		Real
Propriedade:	Alterar
Titulo:			Local Pgto
DescriÁ„o:		Local de Pagamento

Campo*:			A6_INSTR1
Tipo:			C
Tamanho:		065
Decimal:		00
Contexto:		Real
Propriedade:	Alterar
Titulo:			Instruc„o L1
DescriÁ„o:		Instruc„o da linha 1

Campo*:			A6_INSTR2
Tipo:			C
Tamanho:		065
Decimal:		00
Formato:		@!
Contexto:		Real
Propriedade:	Alterar
Titulo:			Instruc„o L2
DescriÁ„o:		Instruc„o da linha 2

Campo*:			A6_INSTR3
Tipo:			C
Tamanho:		065
Decimal:		00
Formato:		@!
Contexto:		Real
Propriedade:	Alterar
Titulo:			Instruc„o L3
DescriÁ„o:		Instruc„o da linha 3

Campo*:			A6_INSTR4
Tipo:			C
Tamanho:		065
Decimal:		00
Contexto:		Real
Propriedade:	Alterar
Titulo:			Instruc„o L4
DescriÁ„o:		Instruc„o da linha 4

* As instruÁıes s„o fÛrmulas. Utilize aspas para adicionar texto simples.

/*/

User Function PDFBOL341(aItens, aLog, nTipoCart)
	Local nLen := Len( aItens )
	Local i

	Private oPrn
	Private cPathServG := "\bol_gerados"
	Private cPathTemp  := GETTEMPPATH()

	ProcRegua( nLen )

	For i := 1 To nLen
		IncProc( "Imprimindo titulos. Aguarde..." )

		DbSelectArea("SE1")
		DbSetOrder(1) // E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
		DbSeek( aItens[i, 5] + aItens[i, 6] + aItens[i, 7] + aItens[i, 8] + aItens[i, 9] )

		//Nome: BOL104_NUMERO_PARCELA+_CLIENTE+LOJA
		cNomArq := "bol341_" + ;
		AllTrim(SE1->E1_NUM) + "_" + ;
		AllTrim(IIF(Empty(SE1->E1_PARCELA), "U", SE1->E1_PARCELA)) + "_" +;
		AllTrim(SE1->E1_CLIENTE) + AllTrim(SE1->E1_LOJA) + ".pdf"

		oPrn   := FWMSPrinter():New(cNomArq, IMP_SPOOL, .F.,         , .T.)

		oPrn:SetResolution(78) //Tamanho estipulado para a Danfe
		oPrn:SetPortrait()
		oPrn:SetPaperSize(DMPAPER_A4)
		oPrn:SetMargin(60,60,60,60)
		oPrn:nDevice := IMP_PDF
		// ----------------------------------------------
		// Define para salvar o PDF
		// ----------------------------------------------
		oPrn:cPathPDF := cPathTemp

		oPrn:Setup()

		ProcBol(aItens[i], @aLog, nTipoCart)

		//Deleta se ja existir no TEMP
		FErase(oPrn:cPathPDF+cNomArq)

		//oPrn:Preview()//Visualiza antes de imprimir
		oPrn:Print()

		If !File(cPathServG)
			MAKEDIR(cPathServG)
		EndIf

		//Deleta se ja existir no Servidor
		FErase(cPathServG+"\"+cNomArq)
		//Copia PDF - TEMP para o Server (pasta Gerados)
		CpyT2S(oPrn:cPathPDF + cNomArq, cPathServG)

		FreeObj(oPrn)
		oPrn := Nil
	Next

Return Len(aLog) > 0

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥ ProcBol  ≥ Autor ≥ Lucas Fonseca         ≥ Data ≥ 06/01/17 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ Processa impressao                                         ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ Uso Boletos Banc·rios                                      ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function ProcBol(aItens, aLog, nTipoCart)
	Local aArea := GetArea()
	Local lRet  := .T.
	// CÛdigos do Banco
	Private cCodBco := "341"

	// CaracterÌsticas do Sacado
	Private cCliNome   := ""
	Private cCliEndere := ""
	Private cCliBairro := ""
	Private cCliCEP    := ""
	Private cCliMunici := ""
	Private cCliEstado := ""
	Private cCliCPFCNP := ""

	// CaracterÌsticas do Banco
	Private cBcoCdBanc := ""
	Private cAgeCodCed := ""
	Private cBcoAgenci := ""
	Private cBcoDVAge  := ""
	Private cBcoConta  := ""
	Private cBcoDVCC   := ""
	Private cBcoNomBco := ""
	Private cBcoLogBco := ""
	Private cBcoCdComp := "341-7"
	Private cBcoCdCart := "", cImpCart := ""
	Private cBcoAceite := ""
	Private cBcoEspDoc := ""
	Private cBcoLocPag := ""
	Private cBcoInstr1 := ""
	Private cBcoInstr2 := ""
	Private cBcoInstr3 := ""
	Private cBcoInstr4 := ""
	Private cBcoInstr5 := ""
	Private cBcoMenCS1 := ""
	Private cBcoMenCS2 := ""
	Private cBcoMenCS3 := ""

	// CaracterÌsticas do Cedente
	Private cCedentNom := ""
	Private cCedentCNP := ""
	Private cCedentEnd := ""
	Private cCedentBai := ""
	Private cCedentMun := ""
	Private cCedentEst := ""
	Private cCedentCEP := ""
	Private cCedCodEnt := ""

	// CaracterÌsticas do Boleto
	Private cBolDoc    := ""
	Private cBolMoeda  := ""
	Private cBolDscMoe := ""
	Private nBolValDoc := 0
	Private cBolValDoc := ""
	Private cBolDtFat  := ""
	Private cBolDtProc := ""
	Private cBolDtVenc := ""
	Private cBolAceite := ""
	Private cBolNosNum := ""
	Private cBolDVNsNm := ""
	Private cBolFatVnc := ""
	Private cBolDVCdBr := ""
	Private cBolCodBar := ""
	Private cBolDVLnDg := ""
	Private cBolLinDig := ""

	If ( lRet := GetBolDado(aItens, @aLog, nTipoCart) )
		PDFPrinter()
		DbSelectArea("SE1")
		If Empty(SE1->E1_NUMBCO)
			RecLock( "SE1", .F. )
			SE1->E1_NUMBCO  := cBolNosNum // Nosso N˙mero
			SE1->E1_NUMBOL  := cBolNosNum // COPIA DO Nosso N˙mero
			SE1->E1_DVNSNUM := cBolDVNsNm // DV - Nosso N˙mero
			SE1->E1_BARRA   := cBolCodBar // CÛdigo de barras
			SE1->E1_LINDIG  := cBolLinDig // Linha Digit·vel
			SE1->E1_CODBAR  := cBolCodBar // CÛdigo de barras
			SE1->E1_PORTADO := "341"
			SE1->E1_IMPBOL  := "S"
			MsUnlock()
		EndIf
	EndIf

	If !Empty( aArea )
		RestArea( aArea )
	EndIf

Return lRet

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥GetBolDad ∫Autor  ≥ AndrÈ Cruz         ∫ Data ≥  16/07/07   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥  Calcula os dados a sere impressos no boleto caso haja     ∫±±
±±∫          ≥ problema durante o processamento retorna .F.e adiciona     ∫±±
±±∫          ≥ uma linha ‡ matriz de log, cc .T.                          ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥                                                            ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function GetBolDado(aItens, aLog, nTipoCart)
	LOCAL nTotAbat	:= 0

	// Carregando dados do cedente
	DbSelectArea("SM0")
	DbSetOrder(1)

	// Carregando dados do banco
	DbSelectArea("SA6")
	DbSetOrder(1) // A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
	If !DbSeek( aItens[1]+aItens[2]+aItens[3]+aItens[4] )
		AAdd( aLog, "Erro TÌtulo " + aItens[6] + "-" + aItens[7] + ". Banco n„o encontrado. Filial: " + aItens[1] + ", Banco: " + aItens[2] + ", Agencia: " + aItens[3] + ", Conta: " + aItens[4] )
		Return .F.
	EndIf

	// Carregando dados do Documento
	DbSelectArea("SE1")
	DbSetOrder(1) // E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	If !DbSeek( aItens[5] + aItens[6] + aItens[7] + aItens[8] + aItens[9] )
		AAdd( aLog, "Erro TÌtulo " + aItens[6] + "-" + aItens[7] + ". TÌtulo n„o encontrado. Filial: " + aItens[5] + ", PrefÌxo: " + aItens[6] + ", Numero: " + aItens[7] + ", Parcela: " + aItens[8] )
		Return .F.
	EndIf

	// Carregando dados do Sacado
	DbSelectArea("SA1")
	DbSetOrder(1)
	If !DbSeek(aItens[10]+SE1->E1_CLIENTE+SE1->E1_LOJA)
		AAdd( aLog, "Erro TÌtulo " + aItens[6] + "-" + aItens[7] + ". Cliente n„o cadastrado. Filial: " + aItens[5] + ", PrefÌxo: " + aItens[6] + ", Numero: " + aItens[7] + ", Parcela: " + aItens[8] )
		Return .F.
	EndIf

	//SM0->(dbGoBottom())
	
	cCedentNom := SM0->M0_NOMECOM
	cCedentCNP := SM0->M0_CGC
	cCedentEnd := SM0->M0_ENDCOB
	cCedentBai := SM0->M0_BAIRCOB
	cCedentMun := SM0->M0_CIDCOB
	cCedentEst := SM0->M0_ESTCOB
	cCedentCEP := SM0->M0_CEPCOB

	cCliNome   := SA1->A1_NOME
	cCliEndere := Iif( Empty( SA1->A1_ENDCOB ), SA1->A1_END, SA1->A1_ENDCOB )
	cCliBairro := Iif( Empty( SA1->A1_ENDCOB ), SA1->A1_BAIRRO, SA1->A1_BAIRROC )
	cCliCEP    := Iif( Empty( SA1->A1_ENDCOB ), SA1->A1_CEP, SA1->A1_CEPC )
	cCliMunici := Iif( Empty( SA1->A1_ENDCOB ), SA1->A1_MUN, SA1->A1_MUNC )
	cCliEstado := Iif( Empty( SA1->A1_ENDCOB ), SA1->A1_EST, SA1->A1_ESTC )
	cCliCPFCNP := Transform( SA1->A1_CGC, Iif( RetPessoa( SA1->A1_CGC ) == "J", "@R 99.999.999/9999-99", "@R 999.999.999-99" ) )

	cBcoAgenci := AllTrim(SA6->A6_AGEBOL)
	cBcoDVAge  := ""//AllTrim(SA6->A6_DVAGE)
	cBcoConta  := AllTrim(SA6->A6_CONBOL)
	cBcoDVCC   := Alltrim(SA6->A6_DVCC)

	cBcoCdBanc := SA6->A6_COD
	cBcoNomBco := AllTrim(SA6->A6_NOME)
	cBcoLogBco := SA6->A6_ARQLOGO

	If nTipoCart == 1 //175 - Sem Registro
		cBcoCdCart	:= "175"
		cImpCart   := "175"
	ElseIf nTipoCart == 2 //109 - Com Registro
		cBcoCdCart	:= "109"
		cImpCart   := "109"
	EndIf

	cAgeCodCed := 	StrZero(Val(cBcoAgenci), 4) + "/" + StrZero(Val(cBcoConta),5) + "-" + ALLTRIM(cBcoDVCC	)
	cBcoAceite := SA6->A6_ACEITE
	cBcoEspDoc := SA6->A6_ESPDOC
	cBcoLocPag := SA6->A6_LOCPAG
	cBcoInstr1 := Iif( !Empty( SA6->A6_INSTR1 ), &( SA6->A6_INSTR1 ), " " )
	cBcoInstr2 := Iif( !Empty( SA6->A6_INSTR2 ), &( SA6->A6_INSTR2 ), " " )
	cBcoInstr3 := Iif( !Empty( SA6->A6_INSTR3 ), &( SA6->A6_INSTR3 ), " " ) //+ ;
	//              Transform((0.05/30) * (SE1->E1_VALOR-SE1->E1_IRRF-SE1->E1_CSLL-SE1->E1_COFINS-SE1->E1_PIS-SE1->E1_DECRESC),"@E 999,999,999.99")

	cBcoInstr4 := Iif( !Empty( SA6->A6_INSTR4 ), &( SA6->A6_INSTR4 ), " " )

	cBolDoc    := /*aItens[6] + "-" */ aItens[7] + "-" + aItens[8]
	cBolMoeda  := "9"   // DefiniÁ„o da moeda para TÌtulos em Reais
	cBolDscMoe := "R$"

	nTotAbat := SumAbatRec(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_MOEDA,"V") + SE1->E1_SDDECRE
	nBolValDoc := SE1->E1_SALDO - nTotAbat + SE1->E1_SDACRES
	cBolValDoc := Transform(nBolValDoc,"@E 999,999,999.99")

	cBolDtFat  := HS_DToC( SE1->E1_EMISSAO, 2 )
	cBolDtProc := HS_DToC( dDataBase, 2 )
	cBolDtVenc := HS_DToC( SE1->E1_VENCREA, 2 )

	If ( cBolNosNum := GetNossNum(@aLog) ) == Nil // Nosso n˙mero inv·lido
		AAdd( aLog, "Erro TÌtulo " + aItens[6] + "-" + aItens[7] + ". TÌtulo n„o encontrado. Filial: " + aItens[5] + ", PrefÌxo: " + aItens[6] + ", N˙mero: " + aItens[7] + ", Parcela: " + aItens[8] )
		Return .F.
	EndIf
	cBolFatVnc := GetFatVenc()
	If  ( cBolCodBar := GetCodBar() ) == Nil
		Return .F.
	EndIf
	cBolLinDig := GetLinDig(cBolCodBar)

Return .T.

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥GetNossNum∫Autor  ≥ AndrÈ Cruz         ∫ Data ≥  16/07/07   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥  Calcula e retorna o nosso n˙mero                          ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥                                                            ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function GetNossNum(aLog)
	Local cNossNum  := ""
	Local cProxNum  := ""
	Local i
	Local nTamNsNum := 8

	cBolDVNsNm     := ""

	If (!Empty(SE1->E1_NUMBCO) .OR. !Empty(SE1->E1_NUMBOL)) .AND. SE1->E1_NUMBCO == PADR(SE1->E1_NUMBOL	, TamSx3("E1_NUMBCO")[1])
		cNossNum   := SE1->E1_NUMBOL
		cBolDVNsNm := SE1->E1_DVNSNUM
	Else
		If Empty( SA6->A6_PROXNUM )
			cNossNum :=  StrZero( 1, nTamNsNum)
		Else
			cNossNum := SubStr(AllTrim( SA6->A6_PROXNUM ),-nTamNsNum)
			For i := 1 To nTamNsNum
				If SubStr( cNossNum, i, 1 ) < '0' .OR. SubStr( cNossNum, i, 1 ) > '9'
					AAdd( aLog, "N∫ do boleto inv·lido. O n∫ encontrado em " + RetTitle("A6_PROXNUM") + " n„o È valido para o banco " + SA6->A6_COD + ". Por favor verifique." )
					Return Nil
				EndIf
			Next
		EndIf
		cNossNum := StrZero(Val(cNossNum), nTamNsNum)
		cProxNum := Soma1(cNossNum, nTamNsNum)
		RecLock( "SA6" )
		SA6->A6_PROXNUM	:= cProxNum
		MsUnlock()

		cBolDVNsNm := DVNsNm(cBcoAgenci + cBcoConta + cBcoCdCart + cNossNum)
	EndIf

Return cNossNum

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥GetCodBar ∫Autor  ≥ AndrÈ Cruz         ∫ Data ≥  16/07/07   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥  Monta o cÛdigo de barras                                  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥  Banco CAixa Econ. Federal                                 ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function GetCodBar()
	LOCAL cCodBar 	:= ""
	LOCAL nTotAbat	:= 0

	If Empty(SE1->E1_BARRA)

		nTotAbat := SumAbatRec( SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_MOEDA,"V") //001740

		cCodBar := cCodBco			// Codigo do banco - 3 posic.
		cCodBar += cBolMoeda	// Codigo da Moeda "9" Real
		//PosiÁ„o 5 = DV CodBar - Adicionado no final,depois do calculo
		cCodBar += SubStr(cBolFatVnc, 1, 4)	// Fator vencimento

		cValor := AllTrim(Str(Int(nBolValDoc)))
		cValor += Right("00"+AllTrim(Str((nBolValDoc-Int(nBolValDoc))*100)),2)
		cValor := Right("0000000000"+cValor, 10)

		cCodBar += cValor  // valor do documento
		cCodBar += cBcoCdCart //Carteira - 3 posic.
		cCodBar += cBolNosNum //Nosso Nro - 8 posic
		cCodBar += cBolDVNsNm //DV Noss Nro - 1 Posic
		cCodBar += cBcoAgenci //Agencia - 4 posic
		cCodBar += cBcoConta  //Conta - 5 posic
		cCodBar += cBcoDVCC   //DV Conta - 1 posic
		cCodBar += "000"

		cBolDVCdBr := DvCdBar(cCodBar)

		cCodBar	   := substr(cCodBar,1,4) + cBolDVCdBr + substr(cCodBar,5,39)
	Else
		cCodBar := SE1->E1_BARRA
	EndIf

Return(cCodBar)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥GetLinDig ∫Autor  ≥ AndrÈ Cruz         ∫ Data ≥  16/07/07   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥  Montagem da Linha Digitavel                               ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Banco CAixa Econ. Federal                                  ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function GetLinDig(cBolCodBar)
	LOCAL cLinDig  := ""
	LOCAL cCampoLD	:= "" // Campo da linha digitavel

	If Empty(SE1->E1_LINDIG)
		// Primeiro campo
		cCampoLD := Substr(cBolCodBar, 01, 03)		// Codigo do banco (posicao 1 a 3 da barra)
		cCampoLD += Substr(cBolCodBar, 04, 01)		// Codigo da moeda (posicao 4 da barra)
		cCampoLD += Substr(cBolCodBar, 20, 5)	      	// 5 primeiras posicoes do campo livre (posicao 20 a 24 da barra)
		cCampoLD += DvLnDig(cCampoLD)	// digito verificador
		cLinDig := Substr(cCampoLD,01,05) + "." + Substr(cCampoLD,06,05) + Space(1)

		//Segundo Campo
		cCampoLD := Substr(cBolCodBar,25,10)		// posicoes 6 a 15 do campo livre (posicao 25 a 34 da barra)
		cCampoLD += DvLnDig(cCampoLD)		// digito verificador
		cLinDig += Substr(cCampoLD,01,05) + "." + Substr(cCampoLD,06,06) + Space(1)

		//Terceiro Campo
		cCampoLD := Substr(cBolCodBar,35,10)		// posicoes 16 a 25 do campo livre (posicao 35 a 44 da barra)
		cCampoLD += DvLnDig(cCampoLD)		// digito verificador
		cLinDig += Substr(cCampoLD,01,05) + "." + Substr(cCampoLD,06,06) + Space(1)

		//Quarto Campo
		cCampoLD := Substr(cBolCodBar,05,1)		// digito verificador geral da barra (posicao 5 da barra)
		cLinDig += cCampoLD + Space(1)

		//Quinto Campo - formar 14 posicoes
		cCampoLD := Substr(cBolCodBar,06,04)		// fator vencimento (posicao 06 a 09 da barra)
		cCampoLD += Strzero(val(Substr(cBolCodBar,10,10)),10) // valor do documento (posicao 10 a 19 da barra)
		cLinDig += cCampoLD

	Else
		cLinDig := SE1->E1_LINDIG
	EndIf

Return Transform( cLinDig, "@R 99999.99999 99999.999999 99999.999999 9 99999999999999" )

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ Mod11    ∫Autor  ≥ AndrÈ Cruz         ∫ Data ≥  16/07/07   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Calcula resto da divis„o por 11 de uma sÈrie com n termos  ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function Mod11( cString  )
	Local nLenCStrig := 0
	Local nSoma      := 0
	Local i          := 0
	Local j          := 1
	Local nResult    := 0

	Default cString := AllTrim( cString )
	nLenCStrig := Len( cString )

	For i := nLenCStrig To 1 Step - 1
		nSoma +=  Val( SubStr( cString, i, 1 ) ) * ( j := Iif( ( ++j ) > 9, 2, j ) )
	Next i

	If  (nSoma % 11) == 10 .or. (nSoma % 11) == 0
		nResult := 1
	ElseIf (nSoma % 11) == 1
		nResult := (nSoma % 11)
	Else
		nResult := (11 - (nSoma % 11))
	EndIf

Return AllTrim(Str(nResult))

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥GetFatVenc∫Autor  ≥ AndrÈ Cruz         ∫ Data ≥  16/07/07   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥  Retorna o fator de vencimento                             ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥                                                            ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function GetFatVenc()
	Local dDtaBase := CToD( "03/07/00" )

Return AllTrim( Str( 1000 + ( CToD(cBolDtVenc) - dDtaBase ) ) )

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ DVNsNm   ∫Autor  ≥Daniel Peixoto      ∫ Data ≥  20/11/08   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Calculo do digito verificador atraves do MODULO 11         ∫±±
±±∫          ≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function DVNsNm(cNossNum)
	LOCAL cRet
	LOCAL nPeso := 2, i, nMult, nSoma := 0, nResto

	For i := Len(cNossNum) To 1 Step -1

		nMult	:= ( nPeso * Val(substr(cNossNum,i,1)) )
		If nMult >= 10 // se a multiplicacao der 2 digitos
			nMult	:= val(substr(str(nMult,2),1,1)) + val(substr(str(nMult,2),2,1)) // soma os digitos
		Endif
		nSoma	+= nMult
		nPeso	:= if(nPeso==1,2,1)

	Next

	nResto	:= MOD(nSoma,10)
	IF nResto==0
		cRet	:= "0"
	ELSE
		cRet	:= str(10 - nResto,1)
	ENDIF

Return(cRet)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ DVLnDig  ∫Autor  ≥Daniel Peixoto      ∫ Data ≥  20/11/08   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Calculo do digito verificador atraves do MODULO 10         ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥                                                            ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function DvLnDig(cCampoLD)
	LOCAL cRet
	LOCAL nPeso := 2, i, nMult, nSoma := 0, nResto

	For i := Len(cCampoLD) To 1 Step -1

		nMult	:= ( nPeso * Val(substr(cCampoLD,i,1)) )
		If nMult >= 10 // se a multiplicacao der 2 digitos
			nMult	:= val(substr(str(nMult,2),1,1)) + val(substr(str(nMult,2),2,1)) // soma os digitos
		Endif
		nSoma	+= nMult
		nPeso	:= if(nPeso==1,2,1)

	Next

	nResto	:= MOD(nSoma,10)
	IF nResto==0
		cRet	:= "0"
	ELSE
		cRet	:= str(10 - nResto,1)
	ENDIF

Return(cRet)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ DVCdBar  ∫Autor  ≥Daniel Peixoto      ∫ Data ≥  20/11/08   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Calculo do digito verificador atraves do MODULO 11         ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥                                                            ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function DvCdBar(cTexto)
	LOCAL cRet
	LOCAL nPeso := 2, i, nMult, nSoma := 0, nResto

	For i := Len(cTexto) To 1 Step -1
		nMult	:= ( nPeso * Val(substr(cTexto,i,1)) )
		nSoma	+= nMult

		nPeso	:= if(nPeso==9,2,nPeso+1)
	Next

	nResto	:= MOD(nSoma,11)
	cRet	:= 11 - nResto

	IF cRet == 0 .OR. cRet >= 10
		cRet	:= "1"
	ELSE
		cRet	:= str(cRet,1)
	ENDIF

Return(cRet)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥PDFPrinter ∫Autor  ≥Lucas Fonseca      ∫ Data ≥  06/01/17   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥LayOut de Impress„o dos Boletos Banc·rios(Todos os Bancos)  ∫±±
±±∫          ≥(1 Boleto por Folha - Tradicional)                          ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
STATIC Function PDFPrinter()
	Private oFont0 	   := TFont():New( "Arial"      	, 09, 07, , .F., , , , ,.F. ) //Titulos dos Campos
	Private oFont1 	   := TFont():New( "Arial"      	, 09, 08, , .F., , , , ,.F. ) //Titulos dos Campos
	Private oFont1B	   := TFont():New( "Arial"      	, 09, 08, , .T., , , , ,.F. ) //Titulos dos Campos
	Private oFont2     := TFont():New( "Arial"      	, 09, 10, , .F., , , , ,.F. ) //Conteudo dos Campos
	Private oFont3Bold := TFont():New( "Arial Black"	, 09, 15, , .T., , , , ,.F. ) //Nome do Banco
	Private oFont4     := TFont():New( "Arial"      	, 09, 11, , .T., , , , ,.F. ) //Dados do Recibo de Entrega
	Private oFont5     := TFont():New( "Arial"      	, 09, 15, , .T., , , , ,.F. ) //Codigo de CompensaÁ„o do Banco
	Private oFont6     := TFont():New( "Arial"      	, 09, 14, , .T., , , , ,.F. ) //Codigo de CompensaÁ„o do Banco
	Private oFont7     := TFont():New( "Arial"          , 09, 10, , .T., , , , ,.F. ) //Conteudo dos Campos em Negrito
	Private oFont8     := TFont():New( "Arial"          , 09, 09, , .F., , , , ,.F. ) //Dados do Cliente
	Private oFont9     := TFont():New( "Times New Roman", 09, 14, , .T., , , , ,.F. ) //Linha Digitavel

	oPrn:startpage()

	// parte 1
	// ---------------------------------------------------------------------------------------------------------
	If File(cBcoLogBco)
		oPrn:SayBitmap( 0001, 0010, cBcoLogBco, 0100, 0035 )
	Else
		oPrn:Say( 0025, 0010, cBcoNomBco, oFont3Bold) //, 100 )
	EndIf

	oPrn:Say( 0025, 0155, "|" + cBcoCdComp + "|" , oFont5 )
	oPrn:Say( 0030, 0450, "RECIBO DE ENTREGA", oFont4 )

	oPrn:Box( 0035, 0010, 0060, 0400 )
	oPrn:Box( 0035, 0400, 0060, 0600 )
	oPrn:Say( 0045, 0015, "Pagador", oFont1) //, 100 )
	oPrn:Say( 0045, 0405, "Vencimento", oFont1)//, 100 )
	oPrn:Say( 0055, 0015, cCliNome, oFont2, 100 )
	oPrn:Say( 0055, 0520, cBolDtVenc, oFont7, 100 )

	oPrn:Box( 0060, 0010, 0085, 0400 )
	oPrn:Box( 0060, 0400, 0085, 0600 )
	oPrn:Say( 0070, 0015, "Benefici·rio", oFont1, 100 )
	oPrn:Say( 0070, 0405, "AgÍncia/CÛdigo Benefici·rio", oFont1, 100 )
	oPrn:Say( 0080, 0015, alltrim(cCedentNom) + " - CNPJ: " + cCedentCNP, oFont1, 100 )
	oPrn:Say( 0080, 0480, cAgeCodCed, oFont7, 100 )

	oPrn:Box( 0085, 0010, 0110, 0070 )
	oPrn:Box( 0085, 0070, 0110, 0160 )
	oPrn:Box( 0085, 0160, 0110, 0200 )
	oPrn:Box( 0085, 0200, 0110, 0250 )
	oPrn:Box( 0085, 0250, 0110, 0400 )
	oPrn:Box( 0085, 0400, 0110, 0600 )

	oPrn:Say( 0095, 0015, "Dt Documento", oFont1, 100 )
	oPrn:Say( 0095, 0075, "N˙mero do Documento", oFont1, 100 )
	oPrn:Say( 0095, 0165, "Esp.Doc.", oFont1, 100 )
	oPrn:Say( 0095, 0205, "Aceite", oFont1, 100 )
	oPrn:Say( 0095, 0255, "Data Processamento", oFont1, 100 )
	oPrn:Say( 0095, 0405, "Nosso N˙mero", oFont1, 100 )
	oPrn:Say( 0105, 0015, cBolDtFat, oFont2, 100 )
	oPrn:Say( 0105, 0075, cBolDoc, oFont8, 100 )
	oPrn:Say( 0105, 0165, cBcoEspDoc, oFont2, 100 )
	oPrn:Say( 0105, 0205, cBcoAceite, oFont2, 100 )
	oPrn:Say( 0105, 0255, cBolDtProc, oFont2, 100 )

	oPrn:Say( 0105, 0500, cBcoCdCart + "/" + Alltrim(cBolNosNum) + Iif(!Empty(cBolDVNsNm),  + "-" + Alltrim(cBolDVNsNm), ""), oFont7, 100 )

	oPrn:Box( 0110, 0010, 0135, 0070 )
	oPrn:Box( 0110, 0070, 0135, 0108 )
	oPrn:Box( 0110, 0108, 0135, 0160 )
	oPrn:Box( 0110, 0160, 0135, 0250 )
	oPrn:Box( 0110, 0250, 0135, 0400 )
	oPrn:Box( 0110, 0400, 0135, 0600 )
	oPrn:Say( 0120, 0015, "Uso do Banco", oFont1, 100 )
	oPrn:Say( 0120, 0075, "Carteira", oFont1, 100 )
	oPrn:Say( 0120, 0113, "EspÈcie", oFont1, 100 )
	oPrn:Say( 0120, 0165, "Quantidade", oFont1, 100 )
	oPrn:Say( 0120, 0255, "Valor", oFont1, 100 )
	oPrn:Say( 0120, 0405, "(=) Valor do Documento", oFont1, 100 )
	oPrn:Say( 0130, 0075, AllTrim( cImpCart ), oFont2, 100 )
	oPrn:Say( 0130, 0113, cBolDscMoe, oFont2, 100 )
	oPrn:Say( 0130, 0520, cBolValDoc, oFont7, 100 )

	oPrn:Say( 0160, 0050, "NOME DO RECEBEDOR (legivel)", oFont4, 100 )
	oPrn:Say( 0160, 0240, Repl("_",70), oFont4, 100 )
	oPrn:Say( 0180, 0050, "DOCUMENTO RG/CPF", oFont4, 100 )
	oPrn:Say( 0180, 0240, Repl("_",70), oFont4, 100 )
	oPrn:Say( 0200, 0050, "DATA DO RECEBIMENTO", oFont4, 100 )
	oPrn:Say( 0200, 0240, Repl("_",70), oFont4, 100 )

	oPrn:Box( 0210, 0010, 0255, 0600 )
	oPrn:Say( 0220, 0020, "Pagador", oFont1, 100 )
	oPrn:Say( 0220, 0070, cCliNome + " - CNPJ: " + cCliCPFCNP, oFont8, 100 )
	oPrn:Say( 0230, 0070, Alltrim(cCliEndere) + "-" + cCliBairro, oFont8, 100 )
	oPrn:Say( 0240, 0070, Alltrim(cCliMunici) + "/" + cCliEstado + "-" + cCliCEP, oFont8, 100 )
	oPrn:Say( 0250, 0020, "Sacador/Avalista", oFont1, 100 )

	oPrn:Say( 0265, 0001, Repl( "-", 235 ), oFont4)

	// Parte 2
	// ---------------------------------------------------------------------------------------------------------

	If File(cBcoLogBco)
		oPrn:SayBitmap( 0270, 0010, cBcoLogBco, 0100, 0035 )
	Else
		oPrn:Say( 0295, 0010, cBcoNomBco, oFont3Bold, 100 )
	EndIf

	oPrn:Say( 0295, 0155, "|" + cBcoCdComp + "|", oFont5, 100 )
	oPrn:Say( 0300, 0450, "RECIBO DO PAGADOR", oFont4, 100 )

	oPrn:Box( 0305, 0010, 0330, 0400 )
	oPrn:Box( 0305, 0400, 0330, 0600 )

	oPrn:Say( 0315, 0015, "Local de Pagamento", oFont1, 100 )
	oPrn:Say( 0315, 0405, "Vencimento", oFont1, 100 )
	oPrn:Say( 0325, 0015, cBcoLocPag, oFont0, 100 )
	oPrn:Say( 0325, 0520, cBolDtVenc, oFont7, 100 )

	oPrn:Box( 0330, 0010, 0355, 0400 )
	oPrn:Box( 0330, 0400, 0355, 0600 )
	oPrn:Say( 0340, 0015, "Benefici·rio", oFont1, 100 )
	oPrn:Say( 0340, 0405, "AgÍncia/CÛdigo Benefici·rio", oFont1, 100 )
	oPrn:Say( 0350, 0015, AllTrim(cCedentNom) + " - CNPJ: " + cCedentCNP, oFont1, 100 )
	oPrn:Say( 0350, 0480, cAgeCodCed, oFont7, 100 )

	oPrn:Box( 0355, 0010, 0380, 0400 )//box do endereÁo do cedente
	oPrn:Box( 0355, 0400, 0380, 0600 )//box do endereÁo do cedente
	oPrn:Say( 0365, 0015, "EndereÁo Benefici·rio", oFont1, 100 )
	oPrn:Say( 0375, 0015, AllTrim(cCedentEnd) + " - " + AllTrim(cCedentBai)+ ", CEP: " + AllTrim(cCedentCEP) + " " + alltrim(cCedentMun)  + " - " + alltrim(cCedentEst) , oFont1, 100 )
	oPrn:Say( 0365, 0405, "Nosso N˙mero", oFont1, 100 )
	oPrn:Say( 0375, 0500, cBcoCdCart + "/" + Alltrim(cBolNosNum) + Iif(!Empty(cBolDVNsNm),  + "-" + Alltrim(cBolDVNsNm), "" ), oFont7, 100 )

	oPrn:Box( 0380, 0010, 0405, 0070 )
	oPrn:Box( 0380, 0070, 0405, 0160 )
	oPrn:Box( 0380, 0160, 0405, 0200 )
	oPrn:Box( 0380, 0200, 0405, 0250 )
	oPrn:Box( 0380, 0250, 0405, 0400 )
	oPrn:Box( 0380, 0400, 0405, 0600 )
	oPrn:Say( 0390, 0015, "Dt Documento", oFont1, 100 )
	oPrn:Say( 0390, 0075, "N˙mero do Documento", oFont1, 100 )
	oPrn:Say( 0390, 0165, "Esp.Doc.", oFont1, 100 )
	oPrn:Say( 0390, 0205, "Aceite", oFont1, 100 )
	oPrn:Say( 0390, 0255, "Data Processamento", oFont1, 100 )
	oPrn:Say( 0390, 0405, "(=) Valor do Documento", oFont1, 100 )
	oPrn:Say( 0400, 0015, cBolDtFat, oFont2, 100 )
	oPrn:Say( 0400, 0075, cBolDoc, oFont8, 100 )
	oPrn:Say( 0400, 0165, cBcoEspDoc, oFont2, 100 )
	oPrn:Say( 0400, 0205, cBcoAceite, oFont2, 100 )
	oPrn:Say( 0400, 0255, cBolDtProc, oFont2, 100 )
	oPrn:Say( 0400, 0520, cBolValDoc, oFont7, 100 )

	oPrn:Box( 0405, 0010, 0430, 0070 )
	oPrn:Box( 0405, 0070, 0430, 0108 )
	oPrn:Box( 0405, 0108, 0430, 0160 )
	oPrn:Box( 0405, 0160, 0430, 0250 )
	oPrn:Box( 0405, 0250, 0430, 0400 )
	oPrn:Box( 0405, 0400, 0430, 0600 ) // box do valor do documento
	oPrn:Box( 0405, 0400, 0430, 0600 )// box desconto/abatimento
	oPrn:Say( 0415, 0015, "Uso do Banco", oFont1, 100 )
	oPrn:Say( 0415, 0075, "Carteira", oFont1, 100 )
	oPrn:Say( 0415, 0113, "Moeda", oFont1, 100 )
	oPrn:Say( 0415, 0165, "Quantidade", oFont1, 100 )
	oPrn:Say( 0415, 0255, "Valor", oFont1, 100 )
	oPrn:Say( 0415, 0405, "(-) Desconto/Abatimento", oFont1, 100 )

	oPrn:Say( 0425, 0075, AllTrim( cImpCart ), oFont2, 100 )
	oPrn:Say( 0425, 0113, cBolDscMoe, oFont2, 100 )

	oPrn:Box( 0430, 0010, 0530, 0400 )
	oPrn:Say( 0445, 0015, "InstruÁıes de responsabilidade do Benefici·rio. Qualquer d˙vida sobre este boleto, contate o Benefici·rio.", oFont1,100 )
	oPrn:Say( 0460, 0015, "PROTESTAR AP”S 05 DIAS CORRIDOS DO VENCIMENTO", oFont1,100 )
	oPrn:Say( 0475, 0015, "AP”S VENCIMENTO COBRAR JUROS DE R$ " + Alltrim(Transform(nBolValDoc * 0.002 ,"@E 999,999,999.99")), oFont1,100 )

	//oPrn:Box( 0420, 0100, 1510, 1500 )// box manual

	oPrn:Box( 0430, 0400, 0450, 0600 )
	oPrn:Say( 0440, 0405, "(-) Outras DeduÁıes", oFont1, 100 )

	oPrn:Box( 0450, 0400, 0470, 0600 )
	oPrn:Say( 0460, 0405, "(+) Mora/Multa", oFont1, 100 )

	oPrn:Box( 0470, 0400, 0490, 0600 )
	oPrn:Say( 0480, 0405, "(+) Outros AcrÈscimos", oFont1, 100 )

	oPrn:Box( 0490, 0400, 0510, 0600 )
	oPrn:Say( 0500, 0405, "(=) Valor Cobrado", oFont1, 100 )

	oPrn:Box( 0510, 0010, 0555, 0600 )
	oPrn:Say( 0520, 0020, "Pagador", oFont1, 100 )

	oPrn:Say( 0455, 0015, cBcoInstr1, oFont2, 100 )
	oPrn:Say( 0465, 0015, cBcoInstr2, oFont2, 100 )
	oPrn:Say( 0475, 0015, cBcoInstr3, oFont2, 100 )
	oPrn:Say( 0485, 0015, cBcoInstr4, oFont2, 100 )

	oPrn:Say( 0550, 0020, "Sacador/Avalista", oFont1, 100 )
	oPrn:Say( 0550, 0400, "CÛd.Baixa", oFont1, 100 )
	oPrn:Say( 0550, 0500, "AutenticaÁ„o Mec‚nica", oFont1, 100 )

	oPrn:Say( 0520, 0060, cCliNome + " - CNPJ: " + cCliCPFCNP, oFont8, 100 )
	oPrn:Say( 0530, 0060, Alltrim(cCliEndere) + "-" + cCliBairro, oFont8, 100 )
	oPrn:Say( 0540, 0060, Alltrim(cCliMunici) + "/" + cCliEstado + "-" + cCliCEP, oFont8, 100 )

	oPrn:Say( 0565, 0001, replicate("-", 205),oFont4)

	// parte 3
	// ---------------------------------------------------------------------------------------------------------
	If File( cBcoLogBco )
		oPrn:SayBitmap( 0560, 0010, cBcoLogBco, 0100, 0035 )
	Else
		oPrn:Say( 0585, 0010, cBcoNomBco, oFont3Bold, 0100 )
	EndIf

	oPrn:Say( 0585, 0155, "|" + cBcoCdComp + "|", oFont5, 0100 )
	oPrn:Say( 0585, 0280, cBolLinDig, oFont9, 100 )

	oPrn:Box( 0595, 0010, 0620, 0400 )
	oPrn:Box( 0595, 0400, 0620, 0600 )
	oPrn:Say( 0605, 0015, "Local de Pagamento", oFont1, 100 )
	oPrn:Say( 0605, 0405, "Vencimento", oFont1, 100 )
	oPrn:Say( 0615, 0015, cBcoLocPag, oFont0, 100 )
	oPrn:Say( 0615, 0520, cBolDtVenc, oFont7, 100 )

	oPrn:Box( 0620, 0010, 0645, 0400 )
	oPrn:Box( 0620, 0400, 0645, 0600 )
	oPrn:Say( 0630, 0015, "Benefici·rio", oFont1, 100 )
	oPrn:Say( 0630, 0405, "AgÍncia/CÛdigo Benefici·rio", oFont1, 100 )
	oPrn:Say( 0640, 0015, alltrim(cCedentNom) + " - CNPJ: " + cCedentCNP, oFont1, 100)
	oPrn:Say( 0640, 0480, cAgeCodCed, oFont7, 100 )

	oPrn:Box( 0645, 0010, 0670, 0070 )
	oPrn:Box( 0645, 0070, 0670, 0160 )
	oPrn:Box( 0645, 0160, 0670, 0200 )
	oPrn:Box( 0645, 0200, 0670, 0250 )
	oPrn:Box( 0645, 0250, 0670, 0400 )
	oPrn:Box( 0645, 0400, 0670, 0600 )
	oPrn:Say( 0655, 0015, "Dt Documento", oFont1, 100 )
	oPrn:Say( 0655, 0075, "N˙mero do Documento", oFont1, 100 )
	oPrn:Say( 0655, 0165, "Esp.Doc.", oFont1, 100 )
	oPrn:Say( 0655, 0205, "Aceite", oFont1, 100 )
	oPrn:Say( 0655, 0255, "Data Processamento", oFont1, 100 )
	oPrn:Say( 0655, 0405, "Nosso N˙mero", oFont1, 100 )
	oPrn:Say( 0665, 0015, cBolDtFat, oFont2, 100 )
	oPrn:Say( 0665, 0070, cBolDoc, oFont2, 100 )
	oPrn:Say( 0665, 0165, cBcoEspDoc, oFont2, 100 )
	oPrn:Say( 0665, 0205, cBcoAceite, oFont2, 100 )
	oPrn:Say( 0665, 0255, cBolDtProc, oFont2, 100 )

	oPrn:Say( 0665, 0500, cBcoCdCart + "/" + Alltrim(cBolNosNum) + Iif(!Empty(cBolDVNsNm),  + "-" + Alltrim(cBolDVNsNm), "" ), oFont7, 100 )

	oPrn:Box( 0670, 0010, 0695, 0070 )
	oPrn:Box( 0670, 0070, 0695, 0108 )
	oPrn:Box( 0670, 0108, 0695, 0160 )
	oPrn:Box( 0670, 0160, 0695, 0250 )
	oPrn:Box( 0670, 0250, 0695, 0400 )
	oPrn:Box( 0670, 0400, 0695, 0600 )
	oPrn:Say( 0680, 0015, "Uso do Banco", oFont1, 100 )
	oPrn:Say( 0680, 0075, "Carteira", oFont1, 100 )
	oPrn:Say( 0680, 0113, "Moeda", oFont1, 100 )
	oPrn:Say( 0680, 0165, "Quantidade", oFont1, 100 )
	oPrn:Say( 0680, 0255, "Valor", oFont1, 100 )
	oPrn:Say( 0680, 0405, "(=) Valor do Documento", oFont1, 100 )

	oPrn:Say( 0690, 0075, AllTrim( cImpCart ), oFont2, 100 )

	oPrn:Say( 0690, 0113, cBolDscMoe, oFont2, 100 )
	oPrn:Say( 0690, 0520, cBolValDoc, oFont7, 100 )

	oPrn:Box( 0695, 0010, 0770, 0400 )
	oPrn:Say( 0705, 0015, "InstruÁıes de responsabilidade do Benefici·rio. Qualquer d˙vida sobre este boleto, contate o Benefici·rio.", oFont1, 100 )
	oPrn:Say( 0720, 0015, "PROTESTAR AP”S 05 DIAS CORRIDOS DO VENCIMENTO", oFont1,100 )
	oPrn:Say( 0735, 0015, "AP”S VENCIMENTO COBRAR JUROS DE R$ " + Alltrim(Transform(nBolValDoc * 0.2 ,"@E 999,999,999.99")), oFont1,100 )

	oPrn:Box( 0695, 0400, 0710, 0600 )
	oPrn:Say( 0705, 0405, "(-) Desconto/Abatimento", oFont1, 100 )

	oPrn:Box( 0710, 0400, 0730, 0600 )
	oPrn:Say( 0720, 0405, "(-) Outras DeduÁıes", oFont1, 100 )

	oPrn:Box( 0725, 0400, 0740, 0600 )
	oPrn:Say( 0735, 0405, "(+) Mora/Multa", oFont1, 100 )

	oPrn:Box( 0740, 0400, 0755, 0600 )
	oPrn:Say( 0750, 0405,"(+) Outros AcrÈscimos", oFont1, 100 )

	oPrn:Box( 0755, 0400, 0770, 0600 )
	oPrn:Say( 0765, 0405, "(=) Valor Cobrado", oFont1, 100 )

	oPrn:Box( 0770, 0010, 0815, 0600 )
	oPrn:Say( 0780, 0020, "Pagador", oFont1, 100 )

	oPrn:Say( 0720, 0015, cBcoInstr1, oFont2, 100 )
	oPrn:Say( 0730, 0015, cBcoInstr2, oFont2, 100 )
	oPrn:Say( 0740, 0015, cBcoInstr3, oFont2, 100 )
	oPrn:Say( 0750, 0015, cBcoInstr4, oFont2, 100 )

	oPrn:Say( 0810, 0020, "Sacador/Avalista", oFont1, 100 )
	oPrn:Say( 0810, 0450, "CÛd.Baixa", oFont1, 100 )
	oPrn:Say( 0830, 0430, "AutenticaÁ„o Mec‚nica / FICHA DE COMPENSA«√O", oFont1, 100 )
	oPrn:Say( 0780, 0060, cCliNome + " - CNPJ: " + cCliCPFCNP, oFont8, 100 )
	oPrn:Say( 0790, 0060, Alltrim(cCliEndere) + "-" + cCliBairro, oFont8, 100 )
	oPrn:Say( 0800, 0060, Alltrim(cCliMunici) + "/" + cCliEstado + "-" + cCliCEP, oFont8, 100 )

	oPrn:FWMSBAR("INT25",66.7,0.75,cBolCodBar,oPrn,.F., ,.T.,0.028,0.6,NIL,NIL,NIL,.F.,2/*nPFWidth*/,2/*nPFHeigth*/,.F./*lCmtr2Pix*/)

	oPrn:EndPage()
	
Return Nil

#Include "Protheus.ch"
#Include "RWMake.ch"
#Include "FWBrowse.ch" 		// Header Browse do MVC
#Include "FWMVCDef.ch" 		// Header do MVC
#Include "RPTDEF.ch" 		// Header de impressao
#Include "FWPrintSetup.ch" 	// Header de impressao


/*======================================================================================+
| Programa............:   DAXR050.prw (Baseado no QIPA050.PRW)                          |
| Autor(es)...........:   Cicero Odilio Cruz - cicero.cruz@gmail.com                    |
| Data................:   20/10/2019                                                    |
| Descricao / Objetivo:   Ponto de Entrada que substitui o Certificado padrão da Totvs  |
| Doc. Origem.........:   MIT044 - Envio de Laudo de Qualidade Juntamento com o NFE.    |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Módulo Inspeção de Processos                                  |
| Obs.................:                                                                 |
+======================================================================================*/
USER FUNCTION QIP215C()     
	U_DAXR050( { QPK->QPK_OP, QPK->QPK_LOTE }, .F. )
RETURN

/*======================================================================================+
| Programa............:   DAXR050.prw (Baseado no QIPA050.PRW)                          |
| Autor(es)...........:   johnny.osugi@totvspartners.com.br                             |
|                         Cicero Odilio Cruz - cicero.cruz@gmail.com                    |
| Data................:   06/08/2019                                                    |
| Descricao / Objetivo:   Programa-fonte de geracao do laudo de qualidade.              |
| Doc. Origem.........:   MIT044 - Envio de Laudo de Qualidade Juntamento com o NFE.    |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
User Function DAXR050( aDados, lJob )

LOCAL aArea           := GetArea()
LOCAL lAdjustToLegacy := .F.
LOCAL lDisableSetup   := .T.
LOCAL cPathS		  := "\LAUDOS_DAXIA\"
LOCAL cLocal          := IIF( lJob, cPathS, GetTempPath() ) // "C:\TEMP\"
LOCAL cFilePrint      := ""
LOCAL nCnt            := 0
LOCAL nPag            := 1 // Numerador de pagina
LOCAL cNF             := '' // aDados[1]
LOCAL cSerie          := '' // aDados[2]
LOCAL cLote           := '' // aDados[3]
LOCAL cArquivo        := ''
LOCAL cPergS          := "DAXR050P  " // Pergunte Saída
LOCAL cPergP          := "DAXR050QIP" // Pergunte Inspeção de Processos 
LOCAL cPergE          := "DAXR050QIE" // Pergunte Inspeção de Entradas
LOCAL cPergF          := "DAXR050FAT" // Pergunte Faturamento
LOCAL cAliasNF 	      := GETNEXTALIAS()
LOCAL aLaudo          := {}
LOCAL aLotLeg         := {}  // ARRAY COM DADOS 
LOCAL cDirLeg         := "\LAUDOS_ANALISYS\" // Laudo do sistema Legado 

Private cCodCli
Private cCodLoj
Private cNF_ 
Private cNFSer_
Private oPrinter
Private nLin          := 801 // Inicializa com 'estouro' de linhas
Private oFont06	      := TFont():New( "Arial", 06, 06, , .F., , , , .T., .F. )  // Fonte Arial tamanho  6 Normal
Private oFont08	      := TFont():New( "Arial", 08, 08, , .F., , , , .T., .F. )  // Fonte Arial tamanho  8 Normal
Private oFont10	      := TFont():New( "Arial", 10, 10, , .F., , , , .T., .F. )  // Fonte Arial tamanho 10 Normal
Private oFont11       := TFont():New( "Arial", 11, 11, , .F., , , , .T., .F. )  // Fonte Arial tamanho 11 Normal
Private oFont12       := TFont():New( "Arial", 12, 12, , .F., , , , .T., .F. )  // Fonte Arial tamanho 12 Normal
Private oFont14	      := TFont():New( "Arial", 14, 14, , .F., , , , .T., .F. )  // Fonte Arial tamanho 14 Normal
Private oFont16	      := TFont():New( "Arial", 16, 16, , .F., , , , .T., .F. )  // Fonte Arial tamanho 16 Normal
Private oFont06N      := TFont():New( "Arial", 06, 06, , .T., , , , .T., .F. )  // Fonte Arial tamanho  6 Negrito
Private oFont08N      := TFont():New( "Arial", 08, 08, , .T., , , , .T., .F. )  // Fonte Arial tamanho  8 Negrito
Private oFont10N      := TFont():New( "Arial", 10, 10, , .T., , , , .T., .F. )  // Fonte Arial tamanho 10 Negrito
Private oFont12N      := TFont():New( "Arial", 12, 12, , .T., , , , .T., .F. )  // Fonte Arial tamanho 12 Negrito
Private oFont14N      := TFont():New( "Arial", 14, 14, , .T., , , , .T., .F. )  // Fonte Arial tamanho 14 Negrito
Private oFont16N      := TFont():New( "Arial", 16, 16, , .T., , , , .T., .F. )  // Fonte Arial tamanho 16 Negrito

//Default cLote := "000500"
CONOUT("DAXR050-001 -> Iniciando a Geração do Certificado/Laudo")

IF lJob  // Gerada por JOB

    CONOUT("DAXR050-002 -> Ajustando os parâmetros para execução por JOB")
    mv_par01  := aDados[1]      // Nota Fiscal - Saída
	mv_par02  := aDados[2]      // Serie
	mv_par03  := aDados[3]	    // Lote                               
    mv_par04  := aDados[4]	    // Item                               
    cArquivo  := ALLTRIM(mv_par01)+"_"+ALLTRIM(mv_par04)+"_"+ALLTRIM(mv_par03)
    cTipo     := "S" // FORÇA SER BASEADO EM UMA SAIDA

ELSE
    IF FunName() == "QIPA215"
       cTipo := "P"
       mv_par01  := aDados[1]
       mv_par02  := aDados[2]
    ELSE
       cTipo := DAX050TP()
       IF EMPTY(ALLTRIM(cTipo))
            RETURN NIL
       ENDIF
    ENDIF
    //CONOUT("Tipo Origem de dados:"+cTipo)
    IF cTipo == "S"
        CONOUT("DAXR050-003 -> Execução via Menu")
        Pergunte(cPergS, .T.)
        cArquivo  := ALLTRIM(mv_par01)+"_"+ALLTRIM(mv_par04)+"_"+ALLTRIM(mv_par03) // NOTA + ITEM + LOTE
    ELSEIF cTipo == "P"
        IF !FunName() == "QIPA215"
            Pergunte(cPergP, .T.)
        ENDIF
        cArquivo  := ALLTRIM(mv_par01)+"_"+ALLTRIM(mv_par02)// ORDEM DE PRODUÇÃO + LOTE
    ELSEIF cTipo == "E"
        Pergunte(cPergE, .T.)
        cDataEnt  := DTOC(mv_par01)
        cArquivo  := ALLTRIM(mv_par02)+"_"+DTOS(mv_par01)// LOTE + DATA ENTRADA
    ELSEIF  cTipo == "F"
        Pergunte(cPergF, .T.)
        cArquivo  := "LAUDOS_DE_"+ALLTRIM(mv_par01)+"_ATE_"+ALLTRIM(mv_par02)// LOTE + DATA ENTRADA
    ENDIF
ENDIF

CONOUT("DAXR050-004 -> Executando consulta")
IF  cTipo == "S"
    BEGINSQL ALIAS cAliasNF
        SELECT  DISTINCT SD2.D2_DOC     AS    NOTA, SD2.D2_SERIE AS      SERIE, SD2.D2_CLIENTE AS   CLIENTE, SD2.D2_LOJA   AS     LOJA, 
                        SA1.A1_NOME    AS    NOME, SB1.B1_COD   AS     CODIGO, SB1.B1_DESC    AS DESCRICAO, SB1.B1_TIPOCQ AS CONTROLE, 
                        SD2.D2_LOTECTL AS    LOTE, SD2.D2_QUANT AS QUANTIDADE, D2_EMISSAO     AS   EMISSAO, SB1.B1_TIPO   AS     TIPO,
                        SB8.B8_LOTEFOR AS LOTEFOR
        FROM    %table:SD2% SD2 (NOLOCK),
                %table:SB1% SB1 (NOLOCK),
                %table:SA1% SA1 (NOLOCK),
                %table:SB8% SB8 (NOLOCK)
        WHERE       SD2.D2_FILIAL  = %xFilial:SD2%
                AND SB1.B1_FILIAL  = %xFilial:SB1%            
                AND SA1.A1_FILIAL  = %xFilial:SA1%
                AND SD2.D2_DOC     = %exp:mv_par01% 
                AND SD2.D2_SERIE   = %exp:mv_par02% 
                AND SD2.D2_LOTECTL = %exp:mv_par03%  
                AND SD2.D2_ITEM    = %exp:mv_par04%  
                AND SD2.D2_COD     = SB1.B1_COD
                AND SD2.D2_CLIENTE = SA1.A1_COD
                AND SD2.D2_LOJA    = SA1.A1_LOJA
                AND SB8.B8_LOTECTL = SD2.D2_LOTECTL 
                AND SA1.%NotDel%
                AND SB1.%NotDel%
                AND SD2.%NotDel%
                AND SB8.%NotDel%
    ENDSQL
ELSEIF  cTipo == "P"
    BEGINSQL ALIAS cAliasNF
        SELECT  DISTINCT    ' '            AS    NOTA, ' '              AS      SERIE, QPK.QPK_CLIENT AS   CLIENTE, QPK.QPK_LOJA  AS     LOJA, 
                            ' '            AS    NOME, QPK.QPK_PRODUT   AS     CODIGO, SB1.B1_DESC    AS DESCRICAO, SB1.B1_TIPOCQ AS CONTROLE, 
                            SB8.B8_LOTECTL AS    LOTE,  QPK.QPK_TAMLOT  AS QUANTIDADE, QPK.QPK_EMISSA AS   EMISSAO, SB1.B1_TIPO   AS     TIPO, 
			    			SB8.B8_LOTEFOR AS LOTEFOR
        FROM    %table:QPK% QPK (NOLOCK),
                %table:SB1% SB1 (NOLOCK),
                %table:SB8% SB8 (NOLOCK)
        WHERE     QPK.QPK_LOTE = %exp:mv_par02%      
            AND QPK.QPK_FILIAL = %xFilial:SB8% 
            AND SB8.B8_FILIAL  = %xFilial:SB8%            
            AND SB1.B1_FILIAL  = %xFilial:SB1%            
            AND SB1.B1_COD     = QPK.QPK_PRODUT
            AND SB8.B8_PRODUTO = QPK.QPK_PRODUT
            AND SB8.B8_LOTECTL = QPK.QPK_LOTE
            AND QPK.%NotDel%
            AND SB8.%NotDel%
            AND SB1.%NotDel%
    ENDSQL
ELSEIF  cTipo == "E"
    BEGINSQL ALIAS cAliasNF
        SELECT  DISTINCT    ' '            AS NOTA, ' '              AS      SERIE,  ''            AS   CLIENTE, ''            AS     LOJA, 
                            ' '            AS NOME, QEK.QEK_PRODUT   AS     CODIGO, B1_DESC        AS DESCRICAO, SB1.B1_TIPOCQ AS CONTROLE, 
                            SB8.B8_LOTECTL AS LOTE,  QEK.QEK_TAMLOT  AS QUANTIDADE, QEK.QEK_DTENTR AS   EMISSAO, SB1.B1_TIPO    AS    TIPO, 
                            SB8.B8_LOTEFOR   AS LOTEFOR
        FROM    %table:QEK% QEK (NOLOCK),
                %table:SB1% SB1 (NOLOCK),
                %table:SB8% SB8 (NOLOCK)
        WHERE     QEK.QEK_LOTE = %exp:mv_par02%
            AND SB8.B8_FILIAL  = %xFilial:SB8% 
            AND SB1.B1_FILIAL  = %xFilial:SB1% 
            AND SB1.B1_COD     = QEK.QEK_PRODUT
            AND SB8.B8_PRODUTO = QEK.QEK_PRODUT
            AND SB8.B8_LOTECTL = QEK.QEK_LOTE
            AND QEK.%NotDel%
            AND SB8.%NotDel%
            AND SB1.%NotDel%
    ENDSQL
ELSEIF  cTipo == "F"
    BEGINSQL ALIAS cAliasNF
        SELECT  DISTINCT SD2.D2_DOC     AS    NOTA, SD2.D2_SERIE AS      SERIE, SD2.D2_CLIENTE AS   CLIENTE, SD2.D2_LOJA   AS     LOJA, 
                        SA1.A1_NOME    AS    NOME, SB1.B1_COD   AS     CODIGO, SB1.B1_DESC    AS DESCRICAO, SB1.B1_TIPOCQ AS CONTROLE, 
                        SD2.D2_LOTECTL AS    LOTE, SD2.D2_QUANT AS QUANTIDADE, D2_EMISSAO     AS   EMISSAO, SB1.B1_TIPO   AS     TIPO,
                        SB8.B8_LOTEFOR AS LOTEFOR
        FROM    %table:SD2% SD2 (NOLOCK),
                %table:SB1% SB1 (NOLOCK),
                %table:SA1% SA1 (NOLOCK),
                %table:SB8% SB8 (NOLOCK)
        WHERE       SD2.D2_FILIAL  = %xFilial:SD2%
                AND SB1.B1_FILIAL  = %xFilial:SB1%            
                AND SA1.A1_FILIAL  = %xFilial:SA1%
                AND SD2.D2_DOC     BETWEEN %exp:mv_par01% AND %exp:mv_par02% 
                AND SD2.D2_SERIE   = %exp:mv_par03%     
                AND SD2.D2_COD     = SB1.B1_COD
                AND SD2.D2_CLIENTE = SA1.A1_COD
                AND SD2.D2_LOJA    = SA1.A1_LOJA
                AND SB8.B8_LOTECTL = SD2.D2_LOTECTL 
                AND SA1.%NotDel%
                AND SB1.%NotDel%
                AND SD2.%NotDel%
                AND SB8.%NotDel%
    ENDSQL
ENDIF
CONOUT("DAXR050-005 -> Consulta Executada")
aLastQuery    := GetLastQuery()
cLastQuery    := aLastQuery[2]
MemoWrite( "C:\TEMP\QRY-ORIGEM.TXT", cLastQuery )

// Antes de Gerar o Laudo verifico se o Laudo existe no diretório corrente
//CONOUT("DAXR050-006 -> Verificando se o Arquivo do Laudo Existe.: " + cLocal+""+cArquivo+".pdf")
/*
IF FILE(UPPER(cLocal+""+cLote+".pdf"),,.T.)
	IF FERASE(UPPER(cLocal+""+cLote+".pdf")) <> -1
		CONOUT("DAXR050 -> Arquivo do Lote Encontrado e Deletado")
	ELSE
		CONOUT("DAXR050 -> Não foi possível gerar o Laudo deste Lote")
		RETURN .F.
	ENDIF
ELSE
	CONOUT("DAXR050 -> Arquivo do Lote não Encontrado")
ENDIF
*/
IF cTipo <> "F" // PARA QIE/QIP/JOB SERÁ POR LOTE
    IF !(cAliasNF)->(EOF())

        /*------------------------------------------------------------+
        | Dados do cliente e NF                                       |
        +------------------------------------------------------------*/
        /* 
        cCodCli := (cAliasNF)->CLIENTE
        cCodLoj := (cAliasNF)->LOJA
        cNF_    := (cAliasNF)->NOTA
        cNFSer_ := (cAliasNF)->SERIE
        cLote   := (cAliasNF)->LOTE
        */

        dDtFabr := CTOD("  /  /  ")
        dDtVal  := CTOD("  /  /  ")
        cLoteF  := ""

        IF !U_RetDFbVl( (cAliasNF)->CODIGO, (cAliasNF)->LOTE, '', @dDtFabr, @dDtVal, @cLoteF)
            IF !lJob
                Help( ,, "Help",,"Dados do Lote ("+aCab[8]+") não encontrados!", 1, 0 ) 
                RETURN NIL
            ELSE
                CONOUT("ERRO: Dados do Lote ("+aCab[8]+") não encontrados!")
                RETURN "ERRO: Dados do Lote ("+aCab[8]+") não encontrados!"
            ENDIF
        ENDIF

        If !Rastro((cAliasNF)->CODIGO)
            IF !lJob
                Help( ,, "Help",,"Produto não possui controle de Rastro!", 1, 0 ) 
                RETURN NIL
            ELSE
                CONOUT("ERRO: Produto não possui controle de Rastro!")
                RETURN "ERRO: Produto não possui controle de Rastro!"
            ENDIF
        ENDIF

        IF dDtVal < dDatabase
            IF !lJob
                Help( ,, "Aviso",,"Produto com Data de Validade Vencida!", 1, 0 ) 
            ELSE
                CONOUT("ERRO: Produto com Data de Validade Vencida!")
                RETURN "ERRO: Produto com Data de Validade Vencida!"
            ENDIF
        ENDIF

        IF  cTipo == "E"
            _nQTD := VAL( (cAliasNF)->QUANTIDADE )
        ELSE
            _nQTD := (cAliasNF)->QUANTIDADE
        ENDIF

        cOrigem := U_RtOriPrd( (cAliasNF)->CODIGO , (cAliasNF)->LOTE, lJob )

        aCabec := { (cAliasNF)->NOTA        , ; // 01 - Nota Fiscal de Saída
                    (cAliasNF)->SERIE       , ; // 02 - Série da Nota Fiscal de Saida
                    (cAliasNF)->CLIENTE     , ; // 03 - Cliente/Fornecedor
                    (cAliasNF)->LOJA        , ; // 04 - Loja
                    (cAliasNF)->NOME        , ; // 05 - Nome Cliente
                    (cAliasNF)->CODIGO      , ; // 06 - Código do Produto
                    (cAliasNF)->DESCRICAO   , ; // 07 - Nome do Produto
                    (cAliasNF)->LOTE        , ; // 08 - Lote 
                    _nQTD                   , ; // 09 - Quantidade
                    (cAliasNF)->EMISSAO     , ; // 10 - Emissao
                    (cAliasNF)->TIPO        , ; // 11 - Tipo ME (QIE) / PA (QIP)
                    dDtFabr                 , ; // 12 - Data de Fabricação
                    dDtVal                  , ; // 13 - Data de Validade
                    (cAliasNF)->LOTEFOR     , ; // 14 - Lote Fornecedor (Só Entradas)
                    IIF( cOrigem == "P", .T., .F.)   } // 15 - Manufaturado (.T.) / Revenda (.F.) //AJUSTAR

        //cLote := ALLTRIM(aCabec[8])
        IF EMPTY(ALLTRIM(aCabec[8]))
            IF !lJob
                Help( ,, "Help",,"Dados do Lote vazios na Nota Fiscal!", 1, 0 ) 
                RETURN NIL  
            ELSE
                CONOUT("ERRO: Dados do Lote vazios na Nota Fiscal!")
                RETURN "ERRO: Dados do Lote vazios na Nota Fiscal!"
            ENDIF
        ENDIF

    ELSE       
        
        IF !lJob
            Help( ,, "Help",,"Dados do Lote não Encontrados!", 1, 0 ) 
        ELSE
            CONOUT("ERRO: Dados do Lote não Encontrados!")
            RETURN "ERRO: Dados do Lote não Encontrados!"
        ENDIF
        RETURN NIL

    ENDIF	


    /*------------------------------------------------------------+
    | Realiza as configuracoes de impressao do Laudo de Qualidade |
    +------------------------------------------------------------*/
    oPrinter := FWMSPrinter():New( cArquivo+".PD_", IMP_PDF, lAdjustToLegacy, cLocal, lDisableSetup, , , , , , .F., .F. )
    oPrinter:SetPortrait()
    oPrinter:SetPaperSize( DMPAPER_A4 )

    /*------------------------------------------------------------+
    | Area de impressao do Laudo de Qualidade                     |
    +------------------------------------------------------------*/
    cLaudo := ''
    
    /*------------------------------------------------------------+
    | Impressão do LAUDO DO LOTE                                  |
    +------------------------------------------------------------*/
    cErro := ""
    IF DAX050LD( lJob, aCabec, @cErro )
        // PROSSEGUE 
    ELSE
        // EM CASO DE ERRO
        RETURN cErro
    ENDIF
    File2Printer( cFilePrint, "PDF" )
    oPrinter:cPathPDF := cLocal
    oPrinter:EndPage()
    //oPrinter:Preview()
    oPrinter:Print()
    CONOUT("DAXR050 -> Fim da impressão")
    RestArea( aArea )

    IF !lJob .AND. FILE(UPPER(cLocal+""+cArquivo+".pdf"),,.T.)
        QA_OPENARQ( cLocal+""+cArquivo+".pdf" )
    ENDIF

    IF lJob // Retorno Execução em JOB
        IF FILE(UPPER(cLocal+""+cArquivo+".pdf"),,.T.)
            RETURN UPPER(cLocal+""+cArquivo+".pdf")
        ELSE
            RETURN "ERRO: PDF NÃO FOI GERADO"
        ENDIF
    ENDIF

ELSE // FATURAMENTO USA CONCEITO DE RANGE
    IF !(cAliasNF)->(EOF())
        /*------------------------------------------------------------+
        | Realiza as configuracoes de impressao do Laudo de Qualidade |
        +------------------------------------------------------------*/
        oPrinter := FWMSPrinter():New( cArquivo+".PD_", IMP_PDF, lAdjustToLegacy, cLocal, lDisableSetup, , , , , , .F., .F. )
        oPrinter:SetPortrait()
        oPrinter:SetPaperSize( DMPAPER_A4 )
        //oPrinter:StartPage()
    ENDIF
   
    WHILE !(cAliasNF)->(EOF())
        IF VAL( (cAliasNF)->LOTE ) < 76071
            cLote := ALLTRIM( (cAliasNF)->LOTE )
            cDestino := ALLTRIM( (cAliasNF)->NOTA ) +"_"+ ALLTRIM( (cAliasNF)->SERIE ) +"_"+ cLote+".pdf"
            //MSGALERT("VERIFICANDO O ARQUIVO .: "+UPPER(cDirLeg+cLote+".pdf"))
            IF FILE(UPPER(cDirLeg+cLote+".pdf"),,.T.)
                //MSGALERT("ARQUIVO .: "+UPPER(cDirLeg+cLote+".pdf (ENCONTRADO)"))
                aADD( aLotLeg, { UPPER(cDirLeg+cLote+".pdf"), "C:\TEMP\"+cLote+".pdf","C:\TEMP\"+cDestino } )
            ENDIF
            (cAliasNF)->(DBSKIP())
            LOOP
        ENDIF
        // PRE-VALIDAÇÕES ANTES DE IMPRIMIR O LAUDO
        /*------------------------------------------------------------+
        | Dados do cliente e NF                                       |
        +------------------------------------------------------------*/
        /* 
        cCodCli := (cAliasNF)->CLIENTE
        cCodLoj := (cAliasNF)->LOJA
        cNF_    := (cAliasNF)->NOTA
        cNFSer_ := (cAliasNF)->SERIE
        cLote   := (cAliasNF)->LOTE
        */

        dDtFabr := CTOD("  /  /  ")
        dDtVal  := CTOD("  /  /  ")
        cLoteF  := ""
        aCabec := {}

        IF !U_RetDFbVl( (cAliasNF)->CODIGO, (cAliasNF)->LOTE, '', @dDtFabr, @dDtVal, @cLoteF)
            IF !lJob
                Help( ,, "Help",,"Dados do Lote ("+aCab[8]+") não encontrados!", 1, 0 ) 
                RETURN NIL
            ELSE
                CONOUT("ERRO: Dados do Lote ("+aCab[8]+") não encontrados!")
                RETURN "ERRO: Dados do Lote ("+aCab[8]+") não encontrados!"
            ENDIF
        ENDIF

        If !Rastro((cAliasNF)->CODIGO)
            IF !lJob
                Help( ,, "Help",,"Produto não possui controle de Rastro!", 1, 0 ) 
                RETURN NIL
            ELSE
                CONOUT("ERRO: Produto não possui controle de Rastro!")
                RETURN "ERRO: Produto não possui controle de Rastro!"
            ENDIF
        ENDIF

        IF dDtVal < dDatabase
            IF !lJob
                Help( ,, "Aviso",,"Produto com Data de Validade Vencida!", 1, 0 ) 
            ELSE
                CONOUT("ERRO: Produto com Data de Validade Vencida!")
                RETURN "ERRO: Produto com Data de Validade Vencida!"
            ENDIF
        ENDIF

        IF  cTipo == "E"
            _nQTD := VAL( (cAliasNF)->QUANTIDADE )
        ELSE
            _nQTD := (cAliasNF)->QUANTIDADE
        ENDIF

        cOrigem := U_RtOriPrd( (cAliasNF)->CODIGO , (cAliasNF)->LOTE )

        aCabec := { (cAliasNF)->NOTA        , ; // 01 - Nota Fiscal de Saída
                    (cAliasNF)->SERIE       , ; // 02 - Série da Nota Fiscal de Saida
                    (cAliasNF)->CLIENTE     , ; // 03 - Cliente/Fornecedor
                    (cAliasNF)->LOJA        , ; // 04 - Loja
                    (cAliasNF)->NOME        , ; // 05 - Nome Cliente
                    (cAliasNF)->CODIGO      , ; // 06 - Código do Produto
                    (cAliasNF)->DESCRICAO   , ; // 07 - Nome do Produto
                    (cAliasNF)->LOTE        , ; // 08 - Lote 
                    _nQTD                   , ; // 09 - Quantidade
                    (cAliasNF)->EMISSAO     , ; // 10 - Emissao
                    (cAliasNF)->TIPO        , ; // 11 - Tipo ME (QIE) / PA (QIP)
                    dDtFabr                 , ; // 12 - Data de Fabricação
                    dDtVal                  , ; // 13 - Data de Validade
                    (cAliasNF)->LOTEFOR     , ; // 14 - Lote Fornecedor (Só Entradas)
                    IIF( cOrigem == "P", .T., .F.)   } // 15 - Manufaturado (.T.) / Revenda (.F.) //AJUSTAR

        //cLote := ALLTRIM(aCabec[8])
        IF EMPTY(ALLTRIM(aCabec[8]))
            IF !lJob
                Help( ,, "Help",,"Dados do Lote vazios na Nota Fiscal!", 1, 0 ) 
                RETURN NIL  
            ELSE
                CONOUT("ERRO: Dados do Lote vazios na Nota Fiscal!")
                RETURN "ERRO: Dados do Lote vazios na Nota Fiscal!"
            ENDIF
        ENDIF        

        /*------------------------------------------------------------+
        | Area de impressao do Laudo de Qualidade                     |
        +------------------------------------------------------------*/
        cLaudo := ''
        
        /*------------------------------------------------------------+
        | Impressão do LAUDO DO LOTE                                  |
        +------------------------------------------------------------*/
        cErro := ""
    
        // PARA CADA ITEM DA NF IMPRIMO UMA NOVA PÁGINA
        IF DAX050LD( .F., aCabec, @cErro )
            // PROSSEGUE 
        ELSE
            // EM CASO DE ERRO VAI PARA A PROXIMO ITEM
        ENDIF

        (cAliasNF)->(DBSKIP())
        IF !(cAliasNF)->(EOF())
            // FIM DO LAUDO ATUAL
             oPrinter:EndPage()
            // INICIO UMA NOVA PÁGINA PRÓXIMO LAUDO
            // oPrinter:StartPage()
        ENDIF
    ENDDO
    RestArea( aArea )
ENDIF

IF cTipo == "F" .AND. !lJob 

    IF Valtype(oPrinter) == 'O' 
        File2Printer( cFilePrint, "PDF" )
        oPrinter:cPathPDF := cLocal
        oPrinter:EndPage()
        //oPrinter:Preview()
        oPrinter:Print()            

        IF FILE(UPPER(cLocal+""+cArquivo+".pdf"),,.T.)
            QA_OPENARQ( cLocal+""+cArquivo+".pdf" )
        ENDIF
    ENDIF
    
    IF LEN( aLotLeg ) > 0 
        
        IF MSGYESNO( 'Existem ('+ALLTRIM( STR( LEN( aLotLeg ) ) )+') Certificados do sistema legado, deseja abri-los?', 'Laudos Legado' )
            // ABRO TODOS OS PDF's
            FOR nI := 1 TO LEN( aLotLeg ) 
                // COPIO OS  DADOS PARA O CLIENT                
                CpyS2T( aLotLeg[nI][1], "C:\TEMP\", .T. )
                IF !FILE( aLotLeg[nI][3] )
                    // RENOMEAR O ARQUIVO
                    FRENAME( aLotLeg[nI][2], aLotLeg[nI][3] )
                    FERASE( aLotLeg[nI][2] )
                    // ABRO O PDF
                    shellExecute( "Open", aLotLeg[nI][3], " /k dir", "C:\Temp", 1 )
                ELSE
                    // ABRO O PDF
                    shellExecute( "Open", aLotLeg[nI][3], " /k dir", "C:\Temp", 1 )
                ENDIF                
            NEXT
        ELSE
            // COPIO OS  DADOS PARA O CLIENT
            FOR nI := 1 TO LEN( aLotLeg ) 
                // COPIO OS  DADOS PARA O CLIENT                
                CpyS2T( aLotLeg[nI][1], "C:\TEMP\", .T. )
                IF !FILE( aLotLeg[nI][3] )
                    // RENOMEAR O ARQUIVO
                    FRENAME( aLotLeg[nI][2], aLotLeg[nI][3] )
                    FErase( aLotLeg[nI][2] )
                ENDIF
            NEXT
            // ABRO A PASTA
            WINEXEC("explorer.exe C:\TEMP\")
        ENDIF
    ELSE
        MSGALERT( "Não existem dados no aLotLeg!" )
    ENDIF
ENDIF

/*
IF !lJob .AND. FILE(UPPER(cLocal+""+cLote+".pdf"),,.T.)
    CONOUT("DAXR050 -> Arquivo Encontrado Localmente")
	  CpyT2S( cLocal+""+cLote+".pdf", cPathS, .F. )
	  IF FILE(UPPER(cPathS+""+cLote+".pdf"),,.T.)
		    CONOUT("DAXR050 -> Arquivo Copiado para o Server")
		    IF FERASE(UPPER(cLocal+""+cLote+".pdf")) <> -1
			      CONOUT("DAXR050 -> Arquivo local Encontrado e Deletado")
		    ENDIF
	  ENDIF
ENDIF
*/

Return .T. // Retorno Execução em Tela ou via Ponto de Entrada

/*======================================================================================+
| Funcao Estatica ....:   DAX050LD                                                      |
| Autor(es)...........:   Cicero Odilio Cruz - cicero.cruz@gmail.com                    |
| Data................:   06/01/2020                                                    |
| Descricao / Objetivo:   Imprime a página do Laudo de um Lote/Produto                  |
| Doc. Origem.........:   MIT044 - Envio de Laudo de Qualidade Juntamento com o NFE.    |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
STATIC FUNCTION DAX050LD( lJob, aCabec, cErro )

LOCAL cLaudo := ""

LOCAL aPonto := {}
LOCAL aPEspe := {}
LOCAL aLaudo := {}    

LOCAL nCnt   := 0

LOCAL nLin  := 801 // Inicializa com 'estouro' de linhas

DEFAULT lJob := .F.

IF U_MTDADLAU(aCabec[15], aCabec, @aLaudo, @cLaudo, lJob) // Funcao que alimenta a array aLaudo com as espeficacoes tecnicas do produto

    For nX := 1 to Len( aLaudo )

        /*------------------------------------------+
        | Impressao do cabecalho Laudo de Qualidade |
        +------------------------------------------*/
        If nLin >= 750
            nCnt++
            Cabec( nCnt, aCabec, lJob )
            nLin := 290
        EndIf

        /*----------------------------------------------------------------------+
        | Impressao das linhas-detalhes do produto com certificado de qualidade |
        +----------------------------------------------------------------------*/
        aPonto := JustificaTXT( ALLTRIM(aLaudo[nX][1]), 40, .T. )	  	
        aPEspe := JustificaTXT( ALLTRIM(aLaudo[nX][2]), 40, .T. )	  	
        oPrinter:Say( nLin, 025, aPonto[1], oFont10 ) // Linha-detalhe de Pontos de Inspecao
        oPrinter:Say( nLin, 230, aPEspe[1], oFont10 ) // Linha-detalhe de Especificacao
        oPrinter:Say( nLin, 440, aLaudo[nX][3], oFont10 ) // Linha-detalhe de Resultado
        nLin += 3
        IF LEN(aPonto) > 1 .OR. LEN(aPEspe) > 1
            nLin += 7
            IF LEN(aPonto) > 1
                oPrinter:Say( nLin, 025, aPonto[2], oFont10 ) // Linha-detalhe de Pontos de Inspecao
            ENDIF
            IF LEN(aPEspe) > 1
                oPrinter:Say( nLin, 230, aPEspe[2], oFont10 ) // Linha-detalhe de Especificacao        
            ENDIF
            nLin += 3
        ENDIF
        oPrinter:Say( nLin, 025, Replicate( " ", 60 ), oFont06 ) // Linha de separacao
        nLin += 25
        
    NexT

ELSE
    IF !lJob
        oPrinter:Say( nLin, 025, "Dados da Medição NÃO Localizados",  oFont12  ) 
    ELSE
        cErro := "ERRO: Dados da Medição NÃO Localizados"
        //RETURN "ERRO: Dados da Medição NÃO Localizados"
        RETURN .F.
    ENDIF
ENDIF

nLin += 20

IF cLaudo == "A"
    oPrinter:Say( 785, 025, "Status:",  oFont12  )
    oPrinter:Say( 785, 055, "APROVADO", oFont12N )
ELSEIF cLaudo == "B" // Conversão do Laudo B para terminologia Aprovado
    oPrinter:Say( 785, 025, "Status:",  oFont12  )
    oPrinter:Say( 785, 055, "APROVADO", oFont12N )
ELSEIF cLaudo == "C" // Conversão do Laudo B para terminologia Aprovado
    oPrinter:Say( 785, 025, "Status:",  oFont12  )
    oPrinter:Say( 785, 055, "APROVADO", oFont12N )
ELSEIF cLaudo == "D" // Conversão do Laudo B para terminologia Aprovado
    oPrinter:Say( 785, 025, "Status:",  oFont12  )
    oPrinter:Say( 785, 055, "APROVADO", oFont12N )
ELSEIF cLaudo == "E" // *** verificar se gero Laudo Reprovado
    IF !lJob
        oPrinter:Say( 785, 025, "Status:",  oFont12  )
        oPrinter:Say( 785, 055, "REPROVADO", oFont12N )
    ELSE
        cErro := "ERRO: Produto/Lote Reprovado "
        RETURN .F.
        //RETURN "ERRO: Produto/Lote Reprovado "
    ENDIF
ELSEIF cLaudo == "U" // *** verificar se gero Laudo Liberado Urgente
    IF !lJob
        oPrinter:Say( 785, 025, "Status:",  oFont12  )
        oPrinter:Say( 785, 055, "LIBERADO COM URGÊNCIA", oFont12N )
    ELSE
        cErro := "ERRO: Produto/Lote Liberado em Regime de Urgência sem Análise"
        RETURN .F.
        //RETURN "ERRO: Produto/Lote Liberado em Regime de Urgência sem Análise"
    ENDIF
ELSE // *** verificar se gero Laudo para produto Em Analise
    IF !lJob
        oPrinter:Say( 785, 025, "Status:",  oFont12  )
        oPrinter:Say( 785, 055, "EM ANÁLISE", oFont12N )
    ELSE
        cErro :=  "ERRO: Produto/Lote em Análise"
        RETURN .F.
        //RETURN "ERRO: Produto/Lote em Análise"
    ENDIF
ENDIF

RETURN .T.

/*======================================================================================+
| Funcao Estatica ....:   DAX050TP                                                      |
| Autor(es)...........:   Cicero Odilio Cruz - cicero.cruz@gmail.com                    |
| Data................:   12/09/2019                                                    |
| Descricao / Objetivo:   Tipos possiveis de Impressão do Laudo JOB/QIE/QIP/FAT         |
| Doc. Origem.........:   MIT044 - Envio de Laudo de Qualidade Juntamento com o NFE.    |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
STATIC FUNCTION DAX050TP()
Local oDlg
Local oRadio
Local nOpc		:= 0
Local nRadio	:= 1
Local lOk       := .F.

DEFINE MSDIALOG oDlg FROM	35,37 TO 140,300 TITLE OemToAnsi("Origem Dados") PIXEL	//"Ensaios"

@ 005,005 TO 040,080 OF oDlg PIXEL
@ 007,007 RADIO oRadio VAR nRadio 3D SIZE 090,020 PROMPT OemToAnsi("Nota Fiscal Saída"), OemToAnsi("Ordem de Produção"), OemToAnsi("Nota Entrada"), OemToAnsi("Faturamento") OF oDlg PIXEL //"Produto" ### "Grupo"

DEFINE SBUTTON FROM 011, 090 TYPE 1 ENABLE OF oDlg Action (lOk:=.T.,oDlg:End())
DEFINE SBUTTON FROM 024, 090 TYPE 2 ENABLE OF oDlg Action (lOk:=.F.,oDlg:End())

ACTIVATE MSDIALOG oDlg Centered

lProduto := If(nRadio==1,.T.,.F.)

IF !lOk
   Return "" 
ENDIF

Return IIF( nRadio==1,"S", IIF( nRadio==2, "P", IIF( nRadio==3, "E", "F" ) ) )

/*======================================================================================+
| Funcao Estatica ....:   Cabec( nP )                                                   |
| Autor(es)...........:   johnny.osugi@totvspartners.com.br                             |
|                         Cicero Odilio Cruz - cicero.cruz@gmail.com                    |
| Data................:   12/09/2019                                                    |
| Descricao / Objetivo:   Cabecalho de impressao do laudo de qualidade.                 |
| Doc. Origem.........:   MIT044 - Envio de Laudo de Qualidade Juntamento com o NFE.    |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
Static Function Cabec( nP, aCab, lJob )
LOCAL  aArea    :=  GetArea()
//LOCAL  cCodProd := "9001160021     "
//Local  cLote    := "000500"
//LOCAL  cLtFabr  := "LC2704050519ORL"
//LOCAL cBitmap 	:= IIF( !lJob, GetTempPath()+"daxia_timbrado.BMP", "\system\daxia_timbrado.BMP")
LOCAL cBitmap1   := "\system\daxia_timbrado_r.BMP" // restrição do JOB arquivos de imagem com no maximo 1MB - dividi a imagem do papel timbrado
LOCAL cBitmap2   := "\system\daxia_timbrado_l.BMP" // restrição do JOB arquivos de imagem com no maximo 1MB - dividi a imagem do papel timbrado
/*
CONOUT("DAXR050 -> Verificando o Arquivo.: " + cBitmap)
IF !lJob .AND. !FILE(cBitmap)
	CONOUT("DAXR050 -> Copiando arquivo para o Local.")
	IF FILE("\system\daxia_timbrado.BMP")
		CpyS2T( "\system\daxia_timbrado.bmp", GetTempPath() )
	ELSE
		CONOUT("DAXR050 -> Arquivo (daxia_timbrado.bmp) não Localizado no Servidor.")
	ENDIF
ENDIF
    aCabec := { (cAliasNF)->NOTA        , ; // 01 - Nota Fiscal de Saída
                (cAliasNF)->SERIE       , ; // 02 - Série da Nota Fiscal de Saida
                (cAliasNF)->CLIENTE     , ; // 03 - Cliente
                (cAliasNF)->LOJA        , ; // 04 - Loja
                (cAliasNF)->NOME        , ; // 05 - Nome Cliente
                (cAliasNF)->PRODUTO     , ; // 06 - Código do Produto
                (cAliasNF)->DESCRICAO   , ; // 07 - Nome do Produto
                (cAliasNF)->LOTE        , ; // 08 - Lote 
                (cAliasNF)->QUANTIDADE  , ; // 09 - Quantidade
                (cAliasNF)->EMISSAO     , ; // 10 - Emissao
                (cAliasNF)->TIPO        , ; // 11 - Tipo ME (QIE) / PA (QIP)
                dDtFabr                 , ; // 12 - Data de Fabricação
                dDtVal                  , ; // 13 - Data de Validade
                cLoteF                  , ; // 14 - Lote Fornecedor (Só Entradas)
                EMPTY(ALLTRIM(cLoteF))    } // 15 - Manufaturado (.T.) / Revenda (.F.) 
*/

//oPrinter:EndPage()
oPrinter:StartPage() // Inicio/salto de pagina
oPrinter:SayBitmap( 010, 020, cBitmap1, 130, 73 )  // Impressao do logo Daxia
oPrinter:SayBitmap( 010, 460, cBitmap2, 130, 73 )  // Impressao do logo Daxia
oPrinter:Box( 105, 020, 160, 570, "-4" ) // Impressao do box do cabecalho - Dados do Cliente
oPrinter:Say( 115, 025, "Cliente:", oFont12N )
oPrinter:Say( 115, 065, aCab[5], oFont12 )
oPrinter:Say( 115, 450, "Código/Loja:", oFont12N )
oPrinter:Say( 115, 510, aCab[3] + "/" + aCab[4], oFont12 )
oPrinter:Say( 135, 025, "Quantidade do item:", oFont12N )
oPrinter:Say( 135, 120, ALLTRIM( STR( aCab[9] ) ), oFont12 )
//oPrinter:Say( 135, 350, "Emissão Laudo: ", oFont12N )
//oPrinter:Say( 135, 430, DtoC( dDataBase ) , oFont12 )
oPrinter:Say( 155, 025, "NF:" , oFont12N )
oPrinter:Say( 155, 080, aCab[1], oFont12 )
//oPrinter:Say( 155, 250, "Série:", oFont12N )
//oPrinter:Say( 155, 280, cNFSer_, oFont12 )
oPrinter:Say( 155, 350, "Emissão NF: ", oFont12N )
oPrinter:Say( 155, 445, SUBSTR( aCab[10], 7, 2 )+"/"+SUBSTR( aCab[10], 5, 2 )+"/"+SUBSTR( aCab[10], 1, 4 ), oFont12 )
oPrinter:Say( 155, 530, "Página: " + Str( nP, 4, 0 ), oFont06 )
oPrinter:SayAlign( 170, 000, "CERTIFICADO DE ANÁLISE", oFont16N, 600, 50, CLR_BLUE, 2, 0 )
oPrinter:Line( 200, 015, 200, 570, 0 )
oPrinter:Say( 215, 025, "Produto:", oFont10N )
oPrinter:Say( 215, 060, aCab[7], oFont10 )
oPrinter:Say( 215, 370, "Cód. Produto: ", oFont10N )
oPrinter:Say( 215, 425, aCab[6], oFont10 )
oPrinter:Say( 230, 025, "Lote:", oFont10N )
oPrinter:Say( 230, 055, aCab[8], oFont10 )
IF !aCab[15] // Só imprimo Lote fabricante para Entradas 
    oPrinter:Say( 230, 370, "Lote do Fabricante: ", oFont10N )
    oPrinter:Say( 230, 455, aCab[14], oFont10 )
ENDIF
oPrinter:Say( 245, 025, "Fabricação:", oFont10N )
oPrinter:Say( 245, 070, DTOC(aCab[12]), oFont10 )
oPrinter:Say( 245, 370, "Validade: ", oFont10N )
oPrinter:Say( 245, 415, DTOC(aCab[13]), oFont10 )
oPrinter:Line( 255, 015, 255, 570, 0 )
oPrinter:Say( 265, 025, "Pontos de Inspeção", oFont12N )
oPrinter:Say( 265, 230, "Especificação", oFont12N )
oPrinter:Say( 265, 440, "Resultado", oFont12N )
oPrinter:Line( 270, 015, 270, 570, 0 )

/*----------------------------------------------------------+
| Impressao do Rodape                                       |
+----------------------------------------------------------*/
Rdpe(aCab[6])

nLin := 290

RestArea( aArea )
Return( Nil )

/*======================================================================================+
| Funcao Estatica ....:   Rdpe()                                                        |
| Autor(es)...........:   johnny.osugi@totvspartners.com.br                             |
|                         Cicero Odilio Cruz - cicero.cruz@gmail.com                    |
| Data................:   12/09/2019                                                    |
| Descricao / Objetivo:   Rodape de impressao do laudo de qualidade.                    |
| Doc. Origem.........:   MIT044 - Envio de Laudo de Qualidade Juntamento com o NFE.    |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Parametros..........:                                                                 |
| Retorno.............:                                                                 |
| Obs.................:                                                                 |
+======================================================================================*/
Static Function Rdpe(cProduto)
Local aArea := GetArea()
//AJUSTAR
Local cRespTec := "Laudo Transcrito do Original e emitido eletronicamente, não necessita de assinatura. Responsável técnico "+U_RetInfoSBZ(cProduto)
Local cEndFil_ := ""
Local cSitMail := "WWW.DAXIA.COM.BR - administrativo@daxia.com.br"

IF FWxFilial("QPK") == "0101"
    cEndFil_ := "RUA JONAS FERREIRA GUIMARAES 100 - GUARULHOS - SP - CEP 07250-025 Fone/Fax 11 2633-3020"
ELSEIF FWxFilial("QPK") == "0102"
    cEndFil_ := "RUA JONAS FERREIRA GUIMARAES 100 - GUARULHOS - SP - CEP 07250-025 Fone/Fax 11 2633-3020"
ELSEIF FWxFilial("QPK") == "0103"
    cEndFil_ := "RUA JONAS FERREIRA GUIMARAES 100 - GUARULHOS - SP - CEP 07250-025 Fone/Fax 11 2633-3020"
ELSEIF FWxFilial("QPK") == "0104"
    cEndFil_ := "RUA REPUBLICA ESLOVACA 443 - JABOATAO DOS GUARARAPES - PE - CEP 54350-195 Fone/Fax 11 2633-3020"
ENDIF

oPrinter:Line( 790, 015, 790, 570, 0 )
oPrinter:SayAlign( 800, 000, cRespTec, oFont06, 600, 50, CLR_BLACK, 2, 0 )
oPrinter:SayAlign( 810, 000, cEndFil_, oFont06, 600, 50, CLR_BLACK, 2, 0 )
oPrinter:SayAlign( 820, 000, cSitMail, oFont06, 600, 50, CLR_BLACK, 2, 0 )

RestArea( aArea )
Return( Nil )

#Include "Protheus.ch"
#Include "RWMake.ch"
#Include "FWBrowse.ch" 		// Header Browse do MVC
#Include "FWMVCDef.ch" 		// Header do MVC
#Include "RPTDEF.ch" 		// Header de impressao
#Include "FWPrintSetup.ch" 	// Header de impressao

#DEFINE ENTER Chr(10) + Chr (13)   
/*======================================================================================+
| Funcao Estatica ....:   MTDADLAU()                                                    |
| Autor(es)...........:   Cicero Odilio Cruz - cicero.cruz@gmail.com                    |
| Data................:   13/09/2019                                                    |
| Descricao / Objetivo:   Montagem da array aLaudo com as especificacoes tecnicas do    |
|                         produto.                                                      |
| Doc. Origem.........:   MIT044 - Envio de Laudo de Qualidade Juntamento com o NFE.    |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Parametros..........:   lProc  - Indica se é do Inspeção de Processos (.T.) OU        |
|                                                 Inspeção de Entradas (.F.)            |
|                         aDados - Dados do Lote                                        |
|                         aEspec - Dados da Especificação                               |
|                         cLd    - Laudo                                                |
| Retorno.............:   lRet - Caso tenha encontrado o Lote                           |
| Obs.................:                                                                 |
+======================================================================================*/
USER FUNCTION MTDADLAU(lProc, aDados, aEspec, cLd, lJob)
LOCAL aArea     := GetArea()
LOCAL cAliasPro := GetNextAlias()
LOCAL cAliasEsp := GetNextAlias()
LOCAL cNroLote  := aDados[8]
LOCAL cProd     := aDados[6]
LOCAL cOP       := ''
LOCAL cRevisao  := ''
LOCAL cRoteiro  := '01'

aEspec := {} // Inicializacao da array aLaudo

/*IF dDatabase >= CTOD("15/04/2020")
	IF !lJob 
		cMsgP := "Periodo de validação expirado."
		cMsgS := "Solicite um novo período de validação."
		Help( ,, 'DAXR050 (001)',, cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})				
	ELSE
		CONOUT("AVISO: Periodo de validação expirado. Solicite um novo período de validação.")
	ENDIF
	RETURN .F.
ENDIF
*/
IF lProc // Especificação de Processos
    /*
    BEGINSQL ALIAS cAliasPro
        SELECT  QPK_OP, QPK_PRODUT, QPK_REVI, QPK_LOTE, QPK_LAUDO 
        FROM    %table:QPK% QPK (NOLOCK) 
        WHERE	QPK.QPK_FILIAL = %xFilial:QPK% 
            AND QPK.QPK_LOTE = %exp:cNroLote%
            AND QPK.%NotDel%
    ENDSQL
    */

    BEGINSQL ALIAS cAliasPro
        SELECT QPK_OP,QPK_PRODUT,QPK_REVI,QPK_LOTE,QPK_LAUDO, C2_ROTEIRO AS ROTEIRO
        FROM %table:QPK% QPK (NOLOCK),
             %table:SC2% SC2 (NOLOCK) 
        WHERE       QPK.QPK_FILIAL = %xFilial:QPK% 
                AND SC2.C2_FILIAL = QPK.QPK_FILIAL
                AND QPK.QPK_LOTE = %exp:cNroLote%
                AND SC2.C2_NUM+SC2.C2_ITEM+SC2.C2_SEQUEN =   QPK_OP        
                AND QPK.%NotDel%
                AND SC2.%NotDel%
    ENDSQL

    aLastQuery    := GetLastQuery()
    cLastQuery    := aLastQuery[2]
    MemoWrite( "C:\TEMP\QRY-ORDEM-LOTE.TXT", cLastQuery )

    IF !(cAliasPro)->(EOF())
        cOP         := (cAliasPro)->QPK_OP
        cRevisao    := (cAliasPro)->QPK_REVI
        cLd         := (cAliasPro)->QPK_LAUDO
        cRoteiro    := (cAliasPro)->ROTEIRO
    ELSE
        CONOUT("DAXR050 -> Ordem de Produção não Encontrada!")
        RETURN .F.
    ENDIF

    BEGINSQL ALIAS cAliasEsp
        SELECT    QP7.QP7_PRODUT AS PRODUTO,   QP7.QP7_REVI AS   REVISAO,  QP7.QP7_CODREC AS ROTEIRO, QP7.QP7_OPERAC AS OPERACAO, QP7.QP7_LABOR  AS LABORATORIO,
                QP7.QP7_ENSAIO AS  ENSAIO, QP7.QP7_SEQLAB AS SEQUENCIA,  QP7.QP7_ENSAIO AS  ENSAIO,          'DIM' AS     TIPO, QP7.QP7_MINMAX AS      MINMAX,
                QP7.QP7_LIE    AS     LIE, QP7.QP7_NOMINA AS   NOMINAL,     QP7.QP7_LSE AS     LSE, QP1.QP1_METODO AS   METODO, ''             AS       TEXTO,
                QP7.QP7_PLAMO  AS   PLAMO, QP7.QP7_FORMUL AS   FORMULA,  QP1.QP1_TPCART AS  TPCART, QP1.QP1_CARTA  AS    CARTA, QP1.QP1_DESCPO AS      DESCPO,
                QP1.QP1_DESCIN AS  DESCIN, QP1.QP1_DESCES AS    DESCES,  QP7.QP7_ENSOBR AS  ENSOBR, QP1.QP1_TIPO   AS       TP,   QP1.QP1_QTDE AS  QUANTIDADE,
                QP7.QP7_UNIMED AS  UNIMED, QP7.QP7_CERTIF EXIBE
        FROM	  %table:QP1% QP1 (NOLOCK),
                %table:QP7% QP7 (NOLOCK)
        WHERE	  QP7.QP7_FILIAL = %xFilial:QP7% 
            AND QP1.QP1_FILIAL = %xFilial:QP1% 
            AND QP7.QP7_PRODUT = %exp:cProd% 
            AND QP7.QP7_REVI   = %exp:cRevisao%	
            AND QP7.QP7_CODREC = %exp:cRoteiro%				
            AND QP1.QP1_ENSAIO = QP7.QP7_ENSAIO		
            AND QP7.%NotDel%
            AND QP1.%NotDel%
        UNION
        SELECT    QP8.QP8_PRODUT AS PRODUTO,   QP8.QP8_REVI AS   REVISAO,  QP8.QP8_CODREC AS ROTEIRO, QP8.QP8_OPERAC AS OPERACAO, QP8.QP8_LABOR  AS LABORATORIO,
                QP8.QP8_ENSAIO AS  ENSAIO, QP8.QP8_SEQLAB AS SEQUENCIA,  QP8.QP8_ENSAIO AS  ENSAIO,          'TXT' AS     TIPO, ''             AS      MINMAX,
                ''             AS     LIE, ''             AS   NOMINAL,     ''          AS     LSE, QP1.QP1_METODO AS   METODO, QP8.QP8_TEXTO  AS       TEXTO,
                QP8.QP8_PLAMO  AS   PLAMO, ''             AS   FORMULA,  QP1.QP1_TPCART AS  TPCARY, QP1.QP1_CARTA  AS    CARTA, QP1.QP1_DESCPO AS      DESCPO,
                QP1.QP1_DESCIN AS  DESCIN, QP1.QP1_DESCES AS    DESCES,  QP8.QP8_ENSOBR AS  ENSOBR, QP1.QP1_TIPO   AS       TP,   QP1.QP1_QTDE AS  QUANTIDADE,
                ''             AS  UNIMED, QP8.QP8_CERTIF EXIBE
        FROM	%table:QP1% QP1 (NOLOCK),
                %table:QP8% QP8 (NOLOCK)
        WHERE	QP8.QP8_FILIAL = %xFilial:QP8%					
            AND QP1.QP1_FILIAL = %xFilial:QP1% 
            AND QP8.QP8_PRODUT = %exp:cProd%
            AND QP8.QP8_REVI   = %exp:cRevisao%
            AND QP8.QP8_CODREC = %exp:cRoteiro%				
            AND QP1.QP1_ENSAIO = QP8.QP8_ENSAIO		
            AND QP1.%NotDel%
            AND QP8.%NotDel%
        ORDER BY LABORATORIO, SEQUENCIA
    ENDSQL

    aLastQuery    := GetLastQuery()
    cLastQuery    := aLastQuery[2]
    MemoWrite( "C:\TEMP\QRY-ESPECIFICACAO-QIP.TXT", cLastQuery )

    nK := 0
    WHILE !(cAliasEsp)->(EOF())
        
        IF (cAliasEsp)->EXIBE == "S"

            nK++
            //aAdd(waITM  ,	STRZERO(nK,3) )
            
            cEnsaio := ALLTRIM((cAliasEsp)->DESCPO)
            IF !EMPTY(ALLTRIM((cAliasEsp)->MINMAX))
                SAH->(dbSeek(xFilial("SAH")+(cAliasEsp)->UNIMED))
                cEnsaio +=" ("+ALLTRIM(SAH->AH_UMRES)+")"
            ENDIF

            cEspec := "NÃO LOCALIZADA"
            IF EMPTY(ALLTRIM((cAliasEsp)->MINMAX))
                cEspec := (cAliasEsp)->TEXTO 
            ELSE
                IF ALLTRIM((cAliasEsp)->MINMAX) == "1"
                    cEspec := (cAliasEsp)->LIE+" <<< - >>> "+(cAliasEsp)->LSE
                ELSEIF  ALLTRIM((cAliasEsp)->MINMAX) ==  "2"
                    cEspec := (cAliasEsp)->LIE+" <<< " 
                ELSEIF  ALLTRIM((cAliasEsp)->MINMAX) ==  "3" 
                    cEspec := " >>> "+(cAliasEsp)->LSE
                ENDIF		  
            ENDIF

            aMedicao := {}  
            U_GETMDOP( cOP, cNroLote, (cAliasEsp)->ENSAIO, @aMedicao )
            IF LEN(aMedicao) >= 1
                cMedicao := aMedicao[1]
            ELSE
                cMedicao := ''
            ENDIF
            
            IF !EMPTY(ALLTRIM(cMedicao)) // SÓ EXIBO ENSAIO COM RESULTADO
                aAdd( aEspec, { cEnsaio, cEspec, cMedicao} )
            ENDIF

        ENDIF
        (cAliasEsp)->(DBSKIP())
    ENDDO     
ELSE

    BEGINSQL ALIAS cAliasPro
        SELECT  QEK.QEK_PRODUT AS PRODUTO, QEK.QEK_REVI AS REVISAO, QEK.QEK_LOTE AS LOTE, QEK.QEK_DOCENT AS LOTFOR, 
                QEK.QEK_NTFISC AS    NOTA, QEL.QEL_LAUDO AS LAUDO
        FROM    %table:QEK% QEK (NOLOCK),
                %table:QEL% QEL (NOLOCK)  
        WHERE	     QEK.QEK_FILIAL = %xFilial:QEK%
                AND QEK.QEK_LOTE   = %exp:cNroLote%
                AND QEL.QEL_LABOR  = ' '
                AND QEK.QEK_FILIAL = QEL.QEL_FILIAL
                AND QEK.QEK_LOTE   = QEL.QEL_LOTE
                AND QEK.%NotDel%   
                AND QEL.%NotDel%
    ENDSQL

    aLastQuery    := GetLastQuery()
    cLastQuery    := aLastQuery[2]
    MemoWrite( "C:\TEMP\QRY-ENTRADA-LOTE.TXT", cLastQuery )

    IF !(cAliasPro)->(EOF())
        cNota       := (cAliasPro)->NOTA
        cLoteFor    := (cAliasPro)->LOTFOR
        cRevisao    := (cAliasPro)->REVISAO
        cLd         := (cAliasPro)->LAUDO       
    ELSE
        CONOUT("DAXR050 -> Entrada não Encontrada!")
        RETURN .F.
    ENDIF

    BEGINSQL ALIAS cAliasEsp
        SELECT  QE7.QE7_PRODUT AS  PRODUTO, QE7.QE7_REVI   AS REVISAO, QE7.QE7_LABOR  AS LABORATORIO, QE7.QE7_SEQLAB AS   SEQUENCIA,  
                QE7.QE7_ENSAIO AS   ENSAIO, 'DIM'          AS    TIPO, QE7.QE7_MINMAX AS      MINMAX, QE7.QE7_LIE    AS         LIE, 
                QE7.QE7_NOMINA AS  NOMINAL, QE7.QE7_LSE    AS     LSE, QE1.QE1_METODO AS      METODO, ''             AS       TEXTO,
                QE7.QE7_PLAMO  AS    PLAMO, QE7.QE7_FORMUL AS FORMULA, QE1.QE1_CARTA  AS       CARTA, QE1.QE1_TIPO   AS          TP,
                QE1.QE1_DESCPO AS   DESCPO, QE1.QE1_DESCIN AS  DESCIN, QE1.QE1_DESCES AS      DESCES, QE1.QE1_QTDE   AS  QUANTIDADE,
                QE7.QE7_UNIMED AS   UNIMED, 'S'            AS   EXIBE
        FROM    %table:QE1% QE1 (NOLOCK),
                %table:QE7% QE7 (NOLOCK)
        WHERE 	    QE7.QE7_FILIAL = %xFilial:QE7%					
                AND QE1.QE1_FILIAL = %xFilial:QE1%
                AND QE7.QE7_PRODUT = %exp:cProd% 
                AND QE7.QE7_REVI   = %exp:cRevisao%
                AND QE1.QE1_ENSAIO = QE7.QE7_ENSAIO	
                AND QE1.D_E_L_E_T_ = ' '
                AND QE7.D_E_L_E_T_ = ' '
		UNION
        SELECT  QE8.QE8_PRODUT AS  PRODUTO, QE8.QE8_REVI   AS REVISAO, QE8.QE8_LABOR  AS LABORATORIO, QE8.QE8_SEQLAB AS   SEQUENCIA,  
                QE8.QE8_ENSAIO AS   ENSAIO, 'TXT'          AS    TIPO, ''             AS      MINMAX, ''             AS         LIE, 
                ''             AS  NOMINAL, ''             AS     LSE, QE1.QE1_METODO AS      METODO, QE8.QE8_TEXTO  AS       TEXTO,
                QE8.QE8_PLAMO  AS    PLAMO, ''             AS FORMULA, QE1.QE1_CARTA  AS       CARTA, QE1.QE1_TIPO   AS          TP,
                QE1.QE1_DESCPO AS   DESCPO, QE1.QE1_DESCIN AS  DESCIN, QE1.QE1_DESCES AS      DESCES, QE1.QE1_QTDE   AS  QUANTIDADE,
                ''             AS   UNIMED, 'S'            AS   EXIBE
        FROM	%table:QE1% QE1 (NOLOCK),
                %table:QE8% QE8 (NOLOCK)
        WHERE	QE8.QE8_FILIAL = %xFilial:QE8%					
            AND QE1.QE1_FILIAL = %xFilial:QE1% 
            AND QE8.QE8_PRODUT = %exp:cProd%
            AND QE8.QE8_REVI   = %exp:cRevisao%					
            AND QE1.QE1_ENSAIO = QE8.QE8_ENSAIO		
            AND QE1.%NotDel%
            AND QE8.%NotDel%
        ORDER BY LABORATORIO, SEQUENCIA
    ENDSQL

    aLastQuery    := GetLastQuery()
    cLastQuery    := aLastQuery[2]
    MemoWrite( "C:\TEMP\QRY-ESPECIFICACAO-QIE.TXT", cLastQuery )

    nK := 0
    WHILE !(cAliasEsp)->(EOF())
        
        // NÃO EXIBE LAB RECEBE
        IF ALLTRIM((cAliasEsp)->LABORATORIO) <> "RECEBE" // TRATAMENTO ESPECIFICO DAXIA (NÃO EXIBIR LAB RECEBE)

            IF (cAliasEsp)->EXIBE == "S" // COMPATIBILIZAR COM O QIP LÁ É  POSSIVEL EXIBIR OU NÃO UM ENSAIO

                nK++
                //aAdd(waITM  ,	STRZERO(nK,3) )
                
                cEnsaio := ALLTRIM((cAliasEsp)->DESCPO)
                IF !EMPTY(ALLTRIM((cAliasEsp)->MINMAX))
                    SAH->(dbSeek(xFilial("SAH")+(cAliasEsp)->UNIMED))
                    cEnsaio +=" ("+ALLTRIM(SAH->AH_UMRES)+")"
                ENDIF

                cEspec := "NÃO LOCALIZADA"
                IF EMPTY(ALLTRIM((cAliasEsp)->MINMAX))
                    cEspec := (cAliasEsp)->TEXTO 
                ELSE
                    IF ALLTRIM((cAliasEsp)->MINMAX) == "1"
                        cEspec := (cAliasEsp)->LIE+" <<< - >>> "+(cAliasEsp)->LSE
                    ELSEIF  ALLTRIM((cAliasEsp)->MINMAX) ==  "2" // CONTRIOLA  MINIMO
                        cEspec := (cAliasEsp)->LIE+" >>> " 
                    ELSEIF  ALLTRIM((cAliasEsp)->MINMAX) ==  "3" // CONTRIOLA  MAXIMO 
                        cEspec := " <<< "+(cAliasEsp)->LSE
                    ENDIF		  
                ENDIF

                aMedicao := {}  
                U_GETMDENT( cNota, cNroLote, (cAliasEsp)->ENSAIO, @aMedicao )
                IF LEN(aMedicao) >= 1
                    cMedicao := aMedicao[1]
                ELSE
                    cMedicao := ''
                ENDIF
                
                IF !EMPTY(ALLTRIM(cMedicao)) // SÓ EXIBO ENSAIO COM RESULTADO
                    aAdd( aEspec, { cEnsaio, cEspec, cMedicao} )
                ENDIF

            ENDIF

        ENDIF
        (cAliasEsp)->(DBSKIP())
    ENDDO
ENDIF

RestArea( aArea )
Return .T.

/*======================================================================================+
| Programa............:   DAXR050.prw                                                   |
| Função..............:   RetDFbVl (Baseada na RetDataFab - SIGACUSA.PRW)               |
| Autor...............:   Cicero Odilio Cruz - cicero.cruz@gmail.com                    |
| Data................:   12/10/2019                                                    |
| Descricao / Objetivo:   Retorna Data de Fabricação e Data de Validade                 |
| Doc. Origem.........:   MIT044 - Envio de Laudo de Qualidade Juntamente com o NFE.    |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Cliente.............:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Parametros..........:   cProduto - Código do Produto                                  |
|                         cLoteCtl - Numero do Lote                                     |
|                         cNumLote - Sub-Lote                                           |
|                         dDataFab - Data de Fabricação (Passar por Referência)         |
|                         dDtValid - Data de Validade (Passar por Referência)           |
| Retorno.............:   lRet - Caso tenha encontrado o Lote                           |
| Obs.................:                                                                 |
+======================================================================================*/
USER FUNCTION RetDFbVl(cProduto, cLoteCtl, cNumLote, dDataFab, dDtValid, cLoteFor)

LOCAL   aArea 	 	:= GetArea()
LOCAL   lRet 		:= .F.
LOCAL   cAlias   	:= "SB8"

DEFAULT dDataFab    := CTOD("  /  /  ")
DEFAULT dDtValid    := CTOD("  /  /  ")
DEFAULT cLoteFor    := ""

DbSelectArea(cAlias)
(cAlias)->(DbSetOrder(5)) // FILIAL + PRODUTO + LOTE + SUB-LOTE + DATA VALIDADE

If (cAlias)->(DbSeek(xFilial("SB8")+cProduto+cLoteCtl+cNumLote))
	dDataFab := SB8->B8_DFABRIC
    dDtValid := SB8->B8_DTVALID
    cLoteFor := SB8->B8_LOTEFOR
	lRet := .T.
Endif

RestArea(aArea)

RETURN lRet

/*======================================================================================+
| Programa............:   DAXR050.prw                                                   |
| Função..............:   GETMDOP                                                     |
| Autor...............:   Cicero Odilio Cruz - cicero.cruz@gmail.com                    |
| Data................:   13/10/2019                                                    |
| Descricao / Objetivo:   Retorna dados das Medições de um Ensaio de uma OP             |
| Doc. Origem.........:   MIT044 - Envio de Laudo de Qualidade Juntamente com o NFE.    |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Cliente.............:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Parametros..........:   cOP     - Ordem de Produção                                   |
|                         cLote   - Numero do Lote                                      |
|                         cEnsaio - Numero do Ensaio                                    |
|                         aMed    - Medição Efetuada                                    |
| Retorno.............:   aMed    - Medição Efetuada                                    |
| Obs.................:                                                                 |
+======================================================================================*/
USER FUNCTION GETMDOP( cOP, cLote, cEnsaio, aMed )
LOCAL cAliasRes := GetNextAlias()

BEGINSQL ALIAS cAliasRes

	SELECT         QPR.QPR_FILIAL,     QPR.QPR_OP,	  QPR.QPR_LOTE,	 QPR.QPR_NUMSER,  QPR.QPR_ROTEIR,  QPR.QPR_OPERAC,
			        QPR.QPR_LABOR, QPR.QPR_ENSAIO,  QPR.QPR_DTMEDI,  QPR.QPR_HRMEDI,  QPR.QPR_AMOSTR,    QPR.QPR_ENSR, 
			QPS.QPS_MEDICA MEDICA, QPR.QPR_RESULT,   QPR.QPR_DTINI,   QPR.QPR_HRINI,   QPR.QPR_DTFIM,   QPR.QPR_HRFIM,
			       QPR.QPR_METODO,	QPR.QPR_RVDOC,   QPR.QPR_CHAVE,  QPR.QPR_FILMAT,    'QPS' TABELA,  QPS.R_E_C_N_O_,
			QPR.R_E_C_N_O_ RECNUM, QPS.QPS_INDMED
	FROM    %table:QPR% QPR (NOLOCK),
			%table:QPS% QPS (NOLOCK)
	WHERE   QPR.QPR_FILIAL = %xFilial:QPR%			AND
			QPR.QPR_OP     = %exp:cOP% 				AND
			QPR.QPR_LOTE   = %exp:cLote% 			AND
			QPR.QPR_ENSAIO = %exp:cEnsaio% 			AND
			QPR.QPR_FILIAL = QPS.QPS_FILIAL			AND
			QPS.QPS_CODMED = QPR.QPR_CHAVE			AND
			QPS.%NotDel%							AND
			QPR.%NotDel%
	UNION
	(
	SELECT         QPR.QPR_FILIAL,     QPR.QPR_OP,	  QPR.QPR_LOTE,	 QPR.QPR_NUMSER, QPR.QPR_ROTEIR, QPR.QPR_OPERAC,
			        QPR.QPR_LABOR, QPR.QPR_ENSAIO,  QPR.QPR_DTMEDI,  QPR.QPR_HRMEDI, QPR.QPR_AMOSTR,   QPR.QPR_ENSR,
			QPQ.QPQ_MEDICA MEDICA, QPR.QPR_RESULT,   QPR.QPR_DTINI,   QPR.QPR_HRINI,  QPR.QPR_DTFIM,  QPR.QPR_HRFIM,
			       QPR.QPR_METODO,  QPR.QPR_RVDOC,   QPR.QPR_CHAVE,  QPR.QPR_FILMAT,   'QPQ' TABELA, QPQ.R_E_C_N_O_,
			QPR.R_E_C_N_O_ RECNUM,  ' '
	FROM    %table:QPR% QPR (NOLOCK),
			%table:QPQ% QPQ (NOLOCK)
	WHERE   QPR.QPR_FILIAL = %xFilial:QPR%			AND
			QPR.QPR_OP     = %exp:cOP% 				AND
			QPR.QPR_LOTE   = %exp:cLote% 			AND
			QPR.QPR_ENSAIO = %exp:cEnsaio% 			AND
			QPR.QPR_FILIAL = QPQ.QPQ_FILIAL			AND
			QPQ.QPQ_CODMED = QPR.QPR_CHAVE			AND
			QPQ.%NotDel% 							AND
			QPR.%NotDel%
	)
	ORDER BY  1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11 
 
ENDSQL

aLastQuery    := GetLastQuery()
cLastQuery    := aLastQuery[2]
MemoWrite( "C:\TEMP\QRY-ENTRADA-MEDICOES-QIP.TXT", cLastQuery )

WHILE !(cAliasRes)->(EOF())
   aAdd( aMed, (cAliasRes)->MEDICA )
   (cAliasRes)->(DBSKIP())
ENDDO
	
RETURN aMed

/*======================================================================================+
| Programa............:   DAXR050.prw                                                   |
| Função..............:   GETMDENT                                                     |
| Autor...............:   Cicero Odilio Cruz - cicero.cruz@gmail.com                    |
| Data................:   13/10/2019                                                    |
| Descricao / Objetivo:   Retorna dados das Medições de um Ensaio de uma OP             |
| Doc. Origem.........:   MIT044 - Envio de Laudo de Qualidade Juntamente com o NFE.    |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Cliente.............:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Parametros..........:   cOP     - Ordem de Produção                                   |
|                         cLote   - Numero do Lote                                      |
|                         cEnsaio - Numero do Ensaio                                    |
|                         aMed    - Medição Efetuada                                    |
| Retorno.............:   aMed    - Medição Efetuada                                    |
| Obs.................:                                                                 |
+======================================================================================*/
USER FUNCTION GETMDENT( cOP, cLote, cEnsaio, aMed )

LOCAL cAliasRes := GetNextAlias()

BEGINSQL ALIAS cAliasRes

	SELECT  QER.QER_FILIAL,   QER.QER_LOTE, QER.QER_LABOR        , QER.QER_ENSAIO, QER.QER_DTMEDI,  QER.QER_HRMEDI,
            QER.QER_AMOSTR,   QER.QER_ENSR, QES.QES_MEDICA MEDICA, QER.QER_RESULT,  QER.QER_DTINI,   QER.QER_HRINI,
            QER.QER_DTFIM ,  QER.QER_HRFIM, QER.QER_METODO       ,  QER.QER_RVDOC,  QER.QER_CHAVE,  QER.QER_FILMAT,
			'QES'  TABELA , QES.R_E_C_N_O_, QER.R_E_C_N_O_ RECNUM, QES.QES_INDMED
	FROM    %table:QER% QER (NOLOCK),
			%table:QES% QES (NOLOCK)
	WHERE   QER.QER_FILIAL = %xFilial:QER%		AND
			QER.QER_LOTE   = %exp:cLote%		AND
            QER.QER_ENSAIO = %exp:cEnsaio%		AND
			QER.QER_FILIAL = QES.QES_FILIAL		AND
		    QES.QES_CODMED = QER.QER_CHAVE		AND
			QES.%NotDel%						AND
			QER.%NotDel%
	UNION
	(
	SELECT  QER.QER_FILIAL,   QER.QER_LOTE, QER.QER_LABOR        , QER.QER_ENSAIO, QER.QER_DTMEDI,  QER.QER_HRMEDI,
            QER.QER_AMOSTR,   QER.QER_ENSR, QEQ.QEQ_MEDICA MEDICA, QER.QER_RESULT,  QER.QER_DTINI,   QER.QER_HRINI,
            QER.QER_DTFIM ,  QER.QER_HRFIM, QER.QER_METODO       ,  QER.QER_RVDOC,  QER.QER_CHAVE,  QER.QER_FILMAT,
			'QEQ'  TABELA , QEQ.R_E_C_N_O_, QER.R_E_C_N_O_ RECNUM, ' '
	FROM    %table:QER% QER (NOLOCK),
			%table:QEQ% QEQ (NOLOCK)
	WHERE   QER.QER_FILIAL = %xFilial:QER%		AND
			QER.QER_LOTE   = %exp:cLote%		AND
            QER.QER_ENSAIO = %exp:cEnsaio%		AND
			QER.QER_FILIAL = QEQ.QEQ_FILIAL		AND
		    QEQ.QEQ_CODMED = QER.QER_CHAVE		AND
			QEQ.%NotDel%						AND
			QER.%NotDel%
	)
	ORDER BY  1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11 
 
ENDSQL

aLastQuery    := GetLastQuery()
cLastQuery    := aLastQuery[2]
MemoWrite( "C:\TEMP\QRY-ENTRADA-MEDICOES-QIE.TXT", cLastQuery )

WHILE !(cAliasRes)->(EOF())
   aAdd( aMed, (cAliasRes)->MEDICA )
   (cAliasRes)->(DBSKIP())
ENDDO
	
RETURN aMed

/*
+=======================================================================================+
| Funcao Estatica ....:   RetInfoSBZ()                                                  |
| Autor(es)...........:   Cicero Odilio Cruz - cicero.cruz@gmail.com                    |
| Data................:   31/10/2019                                                    |
| Descricao / Objetivo:   Retorna os dados do Responsável baseando-se na QAA            |
|                                                                                       |
| Doc. Origem.........:   MIT044 - Envio de Laudo de Qualidade Juntamento com o NFE.    |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Parametros..........:   cProduto - Código do Produto                                  |
| Retorno.............:   cRespons - Caso exista devolve Nome e CRQ do Responsável      |
| Obs.................:                                                                 |
+=======================================================================================+
*/
USER FUNCTION RetInfoSBZ(cProduto)

    Local aArea     := GetArea()
    Local cRespons  := ""

    DbSelectArea("SBZ")
    SBZ->( DbSetOrder(1) )    //BZ_FILIAL+BZ_COD
    IF SBZ->( DbSeek(xFilial("SBZ") + cProduto) )
        
        // RETORNO O RESPONSÁVEL TÉCNICO
        IF  SBZ->( ColumnPos( "BZ_XMAT" ) ) > 0
            dbSelectArea("QAA")
			dbSetOrder(1)
			IF dbSeek(xFilial("QAA")+SBZ->BZ_XMAT) .AND. QAA->( ColumnPos( "QAA_XCRQ" ) ) > 0
                cRespons := AllTrim( QAA->QAA_NOME )  + " - CRQ: " + AllTrim( QAA->QAA_XCRQ )
			ENDIF

        ENDIF

    ENDIF
    
    RestArea(aArea)

Return cRespons

/*
+=======================================================================================+
| Funcao Estatica ....:   RtOriPrd()                                                    |
| Autor(es)...........:   Cicero Odilio Cruz - cicero.cruz@gmail.com                    |
| Data................:   31/10/2019                                                    |
| Descricao / Objetivo:   Retorna os dados do Responsável baseando-se na QAA            |
|                                                                                       |
| Doc. Origem.........:   MIT044 - Envio de Laudo de Qualidade Juntamento com o NFE.    |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Parametros..........:   cProduto - Código do Produto                                  |
|                         cLote    - Lote                                               |
| Retorno.............:   cRespons - Caso exista devolve Nome e CRQ do Responsável      |
| Obs.................:                                                                 |
+=======================================================================================+
*/
USER FUNCTION RtOriPrd(cProduto, cLote, lJob)

LOCAL aArea     := GetArea()
LOCAL cOrigem   := "E"              
LOCAL cALIAS    := GetNextAlias()
/*
IF dDatabase >= CTOD("15/04/2020")
	IF !lJob 
		cMsgP := "Periodo de validação expirado."
		cMsgS := "Solicite um novo período de validação."
		Help( ,, 'DAXR050 (001)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})				
	ELSE
		CONOUT("AVISO: Periodo de validação expirado. Solicite um novo período de validação.")
	ENDIF
	RETURN .F.
ENDIF
*/
BEGINSQL ALIAS cALIAS
    SELECT PRODUTO, LOTE, ORIGEM, SEQUENCIAL 
    FROM (  SELECT SD51.D5_LOTECTL AS LOTE,SD51.D5_PRODUTO AS PRODUTO,         ' ' AS DOCUMENTO, ' ' AS SERIE,   SD51.D5_OP AS OP, 
                   'P' AS ORIGEM, SD51.D5_NUMSEQ SEQUENCIAL
            FROM   %table:SD5% SD51 (NOLOCK)
            WHERE      SD51.D5_FILIAL  =  %xFilial:SD5%
                   AND SD51.D5_ORIGLAN = '010' 
                   AND SD51.%NotDel%
            UNION  // PRODUÇÃO INVENTÁRIO
            SELECT SD51.D5_LOTECTL AS LOTE,SD51.D5_PRODUTO AS PRODUTO, SD51.D5_DOC AS DOCUMENTO, ' ' AS SERIE,   SD51.D5_OP AS OP, 
                   'P' AS ORIGEM, SD51.D5_NUMSEQ SEQUENCIAL
            FROM   %table:SD5% SD51 (NOLOCK)
            WHERE      SD51.D5_FILIAL  =  %xFilial:SD5%
                   AND SD51.D5_OP      <> ' ' 
                   AND SD51.D5_DOC     =  'INVENT'
                   AND SD51.%NotDel%
            UNION  // ENTRADA INVENTÁRIO
            SELECT SD52.D5_LOTECTL AS LOTE,SD52.D5_PRODUTO AS PRODUTO,         ' ' AS DOCUMENTO, ' ' AS SERIE,          ' ' AS OP, 
                   'E' AS ORIGEM, SD52.D5_NUMSEQ SEQUENCIAL 
            FROM   %table:SD5% SD52 (NOLOCK)
            WHERE      SD52.D5_FILIAL  =  %xFilial:SD5%
                   AND SD52.D5_OP      = ' ' 
                   AND SD52.D5_DOC     = 'INVENT'  
                   AND SD52.%NotDel%
            UNION  // ENTRADA NORMAL - QUALQUER ORIGLAN MENOR QUE 499 E DIFERENTE DE 010
            SELECT SD52.D5_LOTECTL AS LOTE,SD52.D5_PRODUTO AS PRODUTO,         ' ' AS DOCUMENTO, ' ' AS SERIE,          ' ' AS OP, 
                   'E' AS ORIGEM, SD52.D5_NUMSEQ SEQUENCIAL 
            FROM   %table:SD5% SD52 (NOLOCK)
            WHERE      SD52.D5_FILIAL  =  %xFilial:SD5%
                   AND SD52.D5_ORIGLAN <> '010'
                   AND SD52.D5_ORIGLAN <  '499'  
                   AND SD52.%NotDel%
		)  SD5 
        WHERE      PRODUTO  = %exp:cProduto%
               AND LOTE     = %exp:cLote%
        ORDER BY SEQUENCIAL
ENDSQL

aLastQuery    := GetLastQuery()
cLastQuery    := aLastQuery[2]
MemoWrite( "C:\TEMP\QRY-RtOriPrd.TXT", cLastQuery )

IF !(cALIAS)->(EOF()) // CONSIDERAR O PRIMEIRO REGISTRO DO LOTE
    cOrigem := (cALIAS)->ORIGEM
    CONOUT("CRZXFUN - ORIGEM LOTE ("+cLote+") do Produto ("+cProduto+") IDENTIFICADA")
ENDIF

RestArea(aArea)

Return cOrigem

/*
+=======================================================================================+
| Funcao Estatica ....:   RtItmNFS()                                                    |
| Autor(es)...........:   Cicero Odilio Cruz - cicero.cruz@gmail.com                    |
| Data................:   31/10/2019                                                    |
| Descricao / Objetivo:   Retorna os DADOS dos Itens Faturados sem Envio de Laudo       |
|                                                                                       |
| Doc. Origem.........:   MIT044 - Envio de Laudo de Qualidade Juntamente com o NFE.    |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Parametros..........:   << Sem Parametros >>                                          |
| Retorno.............:   aDados  - Dados das Notas que não tiveram Certificado Enviado |
| Obs.................:                                                                 |
+=======================================================================================+
*/
USER FUNCTION RtItmNFS(__xFilial, lJob)
LOCAL aArea     := GetArea()              
LOCAL cALIAS    := GetNextAlias()
LOCAL aDados    := {}
LOCAL _aAnexo   := {}
LOCAL cMsg      := ""
LOCAL cemail    := ""
LOCAL cDirLeg   := "\LAUDOS_ANALISYS\"
LOCAL nStart 	:= Seconds()
Local cItem     := '00'
DEFAULT __xFilial := "    "
DEFAULT lJob      := .F.
/*
IF dDatabase >= CTOD("15/04/2020")
	IF !lJob 
		cMsgP := "Periodo de validação expirado."
		cMsgS := "Solicite um novo período de validação."
		Help( ,, 'RtItmNFS (001)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})				
	ELSE
		CONOUT("AVISO: Periodo de validação expirado. Solicite um novo período de validação.")
	ENDIF
	RETURN .F.
ENDIF
*/
//tRATAMENTO PARA FILTRO DO JOB
cFFilial :='% '
IF !EMPTY(ALLTRIM(__xFilial))
    cFFilial += " AND SD2.D2_FILIAL = '"+__xFilial+"' "
ENDIF	
cFFilial +=' %'

BEGINSQL ALIAS cALIAS
    COLUMN EMISSAO AS DATE
    SELECT		SD2.D2_FILIAL FILIAL, SD2.D2_DOC    NOTA, SD2.D2_SERIE SERIE, SD2.D2_EMISSAO EMISSAO, 
                SD2.D2_LOTECTL  LOTE, SA1.A1_COD CLIENTE, SA1.A1_LOJA   LOJA, SA1.A1_XMAILLD MAIL
    FROM		%table:SD2% SD2 (NOLOCK), 
                %table:SA1% SA1 (NOLOCK) 
    WHERE               SD2.%NotDel% 
                    AND SA1.%NotDel% 
                    %exp:cFFilial% AND SD2.D2_CLIENTE = SA1.A1_COD  
                    AND SD2.D2_LOJA = SA1.A1_LOJA 
                    AND SD2.D2_FILIAL + SD2.D2_DOC + SD2.D2_SERIE + SD2.D2_ITEM + SD2.D2_EMISSAO NOT IN (
                        SELECT 		Z01.Z01_FILIAL + Z01.Z01_NTFISC + Z01.Z01_SERIE + Z01.Z01_ITEM + Z01.Z01_DTNOTA
                        FROM   		%table:Z01% Z01 (NOLOCK)
                        WHERE       Z01.%NotDel% )
    GROUP BY	SD2.D2_FILIAL , SD2.D2_DOC    , SD2.D2_SERIE , SD2.D2_EMISSAO , 
                SD2.D2_LOTECTL  , SA1.A1_COD , SA1.A1_LOJA   , SA1.A1_XMAILLD                         
    ORDER BY  SD2.D2_FILIAL, SD2.D2_DOC, SD2.D2_SERIE, SD2.D2_EMISSAO, SD2.D2_LOTECTL 
ENDSQL

aLastQuery    := GetLastQuery()
cLastQuery    := aLastQuery[2]
MemoWrite( "C:\TEMP\QRY-RtItmNFS.TXT", cLastQuery )
aDados := {}

Conout("Query - " + GetLastQuery()[2])
IF !(cALIAS)->(EOF()) // CONSIDERAR O PRIMEIRO REGISTRO DO LOTE
    WHILE !(cALIAS)->(EOF())
        cItem    := RetItem(cALIAS)
        cemail   := ""
        cMsgLog  := "Log de Envio de Certificados, Lote.: "+(cALIAS)->LOTE +" Nota Fiscal.: "+(cALIAS)->NOTA+"/"+(cALIAS)->SERIE+ " - Item.: "+ cItem + ENTER

        IF VAL( (cALIAS)->LOTE ) > 76071     
            aAdd( aDados, { (cALIAS)->FILIAL , ;
                            (cALIAS)->NOTA   , ;
                            (cALIAS)->SERIE  , ;
                            cItem            , ;
                            (cALIAS)->EMISSAO, ;
                            (cALIAS)->LOTE   })

            /*
            MSGALERT( "Dados da Nota "+ALLTRIM(STR(LEN(aDados))) +" -> "+ ;
                            "FILIAL.:" + (cALIAS)->FILIAL + ;
                            "  NOTA.:" + (cALIAS)->NOTA   + ;
                            " SERIE.:" + (cALIAS)->SERIE  + ;
                            "  ITEM.:" + cItem   + ;
                            "  LOTE.:" + (cALIAS)->LOTE   )
            */

            // CHAMO O RELATÓRIO
            cResult := U_DAXR050( { (cALIAS)->NOTA, (cALIAS)->SERIE, (cALIAS)->LOTE, cItem }, .T. )

            IF  SUBSTR( cResult, 1, 5 ) == "ERRO:"
                cMsgLog  += "RtItmNFS (003) Houve um ao gerar o Laudo << " + cResult  + " >>. " + ENTER
                lErro    := .T.
            ELSE
                _aAnexo  := {}
                AADD( _aAnexo,  { "Laudo Lote.: "+(cALIAS)->LOTE +" Nota Fiscal.: "+(cALIAS)->NOTA+"/"+(cALIAS)->SERIE+"" , cResult } )
                cAssunto := "Laudo Lote.: "+(cALIAS)->LOTE +" Nota Fiscal.: "+(cALIAS)->NOTA+"/"+(cALIAS)->SERIE+ " - Item.: "+cItem+""             
                cMsg     := "Olá," + ENTER 
                cMsg     += "Você esta recebendo o Laudo do Lote.: "+(cALIAS)->LOTE +", faturado na Nota Fiscal.: "+(cALIAS)->NOTA+"/"+(cALIAS)->SERIE+ ", item ("+cItem+") em Anexo. "
                cMsgLog  += "RtItmNFS (002) O Arquivo do Laudo foi gerado em :" + cResult  + "." + ENTER
                lErro    := .F.
                cErro    := ""
                cemail   := (cALIAS)->MAIL
            ENDIF

            // CHAMO A ROTINA DE ENVIO DE E-MAIL CASO NÃO TENHA HAVIDO ERRO NA GERAÇÃO DO LAUDO
            IF !lErro
                Conout('RtItmNFS - Enviando email  ' + (cALIAS)->NOTA + ' - ' +  (cALIAS)->SERIE + ' - ' +  (cALIAS)->LOTE + ' - ' + cItem )
                U_CRZMail(						                                cemail, ;
                                                                                    "", ;
                                                      "faturamento.daxia@daxia.com.br", ;
                                                                              cAssunto, ;
                                                                               _aAnexo, ;
                                                                                  cMsg, ;
                                                                                   .T., ;
                                                                                @cErro  )
                IF EMPTY(ALLTRIM(cErro))
                    cMsgLog += "RtItmNFS (004) LAUDO ENVIADO COM SUCESSO EM "+DTOC(dDatabase)+" Hora "+Time() + ENTER
                    cMsgLog += "Laudo enviado para: "+cemail
                ELSE
                    cMsgLog += "RtItmNFS (005) Houve erro no envio do Laudo "+DTOC(dDatabase)+" Hora "+Time() +" servidor retornou o seguinte erro << " + ENTER
                    cMsgLog += cErro + " >> " + ENTER
                ENDIF
            
            ENDIF
            SD2->(DbSetOrder(3))
            If SD2->(DbSeek((cALIAS)->FILIAL + (cALIAS)->NOTA + (cALIAS)->SERIE + (cALIAS)->CLIENTE + (cALIAS)->LOJA))
                While (SD2->(D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA) == (cALIAS)->FILIAL + (cALIAS)->NOTA + (cALIAS)->SERIE + (cALIAS)->CLIENTE + (cALIAS)->LOJA)
                    Conout('RtItmNFS - cAlias Lote ' + (cAlias)->LOTE + ' SD2->D2_LOTECTL ' + SD2->D2_LOTECTL)
                    If Alltrim(SD2->D2_LOTECTL) == Alltrim((cAlias)->LOTE)
                        conout('RtItmNFS - Gravando Z01 ' + (cALIAS)->NOTA + ' - ' + SD2->D2_ITEM )
                        // REGISTRO O STATUS DO ENVIO  
                        RECLOCK("Z01", .T.) // INCLUO OS DADOS NO REGISTRO DE ENVIO		
                            Z01_FILIAL  := (cALIAS)->FILIAL
                            Z01_NTFISC  := (cALIAS)->NOTA
                            Z01_SERIE   := (cALIAS)->SERIE
                            Z01_ITEM    := SD2->D2_ITEM 
                            Z01_DTNOTA  := (cALIAS)->EMISSAO 
                            Z01_DTENVI  := dDatabase
                            Z01_HORA    := TIME()
                            Z01_LOG     := cMsgLog
                        MSUNLOCK() 
                    EndIf
                    SD2->(DbSkip())
                EndDo
            EndIf
        ELSE
            cMsgLog  := "Log de Envio de Certificados, Lote.: "+ALLTRIM( (cALIAS)->LOTE )+" Nota Fiscal.: "+ALLTRIM( (cALIAS)->NOTA )+"/"+ALLTRIM( (cALIAS)->SERIE )+ " - Item.: "+cItem  + ENTER
            cLote := ALLTRIM( (cALIAS)->LOTE )
            FwLogMsg("INFO", /*cTransactionId*/, "CRZXFUN", FunName(), "", "01", "Procurando Laudo em:" + UPPER(cDirLeg+cLote+".pdf") , 0, (nStart - Seconds()), {}) 
            //CONOUT("Procurando Laudo em:" + UPPER(cDirLeg+cLote+".pdf"))
            IF FILE(UPPER(cDirLeg+ALLTRIM( cLote )+".pdf"),,.T.)
                //CONOUT( "ARQUIVO " + UPPER(cDirLeg+ALLTRIM( cLote )+".pdf - ENCONTRADO"))
                _aAnexo  := {}
                AADD( _aAnexo,  { "Laudo Lote.: "+(cALIAS)->LOTE +" Nota Fiscal.: "+(cALIAS)->NOTA+"/"+(cALIAS)->SERIE+"" , UPPER(cDirLeg+cLote+".pdf") } )
                cAssunto := "Laudo Lote.: "+(cALIAS)->LOTE +" Nota Fiscal.: "+(cALIAS)->NOTA+"/"+(cALIAS)->SERIE+ " - Item.: "+cItem+""             
                cMsg     := "Olá," + ENTER 
                cMsg     += "Você esta recebendo o Laudo do Lote.: "+(cALIAS)->LOTE +", faturado na Nota Fiscal.: "+(cALIAS)->NOTA+"/"+(cALIAS)->SERIE+ ", item ("+cItem+") em Anexo. "
                cMsgLog  += "RtItmNFS (006) O Arquivo do Laudo foi recuperado em: " + UPPER(cDirLeg+cLote+".pdf")  + "." + ENTER
                lErro    := .F.
                cErro    := ""
                cemail   := (cALIAS)->MAIL

                IF !lErro
                    U_CRZMail(						                                cemail, ;
                                                                                        "", ;
                                                          "faturamento.daxia@daxia.com.br", ;
                                                                                  cAssunto, ;
                                                                                   _aAnexo, ;
                                                                                      cMsg, ;
                                                                                       .T., ;
                                                                                    @cErro  )

                    IF EMPTY(ALLTRIM(cErro))
                        cMsgLog += "RtItmNFS (007) LAUDO ENVIADO COM SUCESSO EM "+DTOC(dDatabase)+" Hora "+Time() + ENTER
                        cMsgLog += "Laudo enviado para: "+cemail
                    ELSE
                        cMsgLog += "RtItmNFS (008) Houve erro no envio do Laudo "+DTOC(dDatabase)+" Hora "+Time() +" servidor retornou o seguinte erro << " + ENTER
                        cMsgLog += cErro + " >> " + ENTER
                    ENDIF
                
                ENDIF
            ELSE
                cMsgLog += "RtItmNFS (009) Arquivo do Lote Analisys não encontrado."
                //CONOUT( "ARQUIVO " + UPPER(cDirLeg+ALLTRIM( cLote )+".pdf - NAO ENCONTRADO"))
                FwLogMsg("INFO", /*cTransactionId*/, "CRZXFUN", FunName(), "", "01", "RtItmNFS (009) Arquivo do Lote Analisys não encontrado.", 0, (nStart - Seconds()), {}) 
            ENDIF
            
            RECLOCK("Z01", .T.) // INCLUO OS DADOS NO REGISTRO DE ENVIO		
                Z01_FILIAL  := (cALIAS)->FILIAL
                Z01_NTFISC  := (cALIAS)->NOTA
                Z01_SERIE   := (cALIAS)->SERIE
                Z01_ITEM    := cItem 
                Z01_DTNOTA  := (cALIAS)->EMISSAO 
                Z01_DTENVI  := dDatabase
                Z01_HORA    := TIME()
                Z01_LOG     := cMsgLog
            MSUNLOCK()

        ENDIF
        (cALIAS)->(DBSKIP())
    ENDDO
ENDIF


RestArea(aArea)

RETURN NIL
/*
aAdd( aLaudo, { "1-ASPECTO                       ", "LIQUIDO VISCOSO / LIQUIDO VISCOSO", "CONFORME"} )
aAdd( aLaudo, { "1-COR                           ", "MARROM / MARROM                  ", "CONFORME"} )
aAdd( aLaudo, { "1-UMIDADE (%)                   ", "0 / 1,0                          ", "0.33    "} )
aAdd( aLaudo, { "1-INSOLUVEL EM ACETONA (%)      ", "62 / >                           ", "63.45   "} )
aAdd( aLaudo, { "1-INSOLÚVEIS EM HEXANO (%)      ", "0 / 0,30                         ", "0.05    "} )
aAdd( aLaudo, { "1-ÍNDICE DE ACIDEZ (mgKOH/g)    ", "0 / 32                           ", "23.70   "} )
aAdd( aLaudo, { "1-ÍNDICE DE PERÓXIDO (meq/kg)   ", "0 / 5,00                         ", "<1      "} )
aAdd( aLaudo, { "1-COR GARDNER                   ", "0 / 10                           ", "7.00    "} )
aAdd( aLaudo, { "1-VISCOSIDADE 25°C (Cp)         ", "80 / >                           ", "104.00  "} )
aAdd( aLaudo, { "1-CONTAGEM TOTAL EM PLACA UFC/G ", "0 / 100                          ", "<10     "} )
aAdd( aLaudo, { "1-BOLORES E LEVEDURAS (UFC/g)   ", "0 / 100                          ", "<10     "} )
aAdd( aLaudo, { "1-SALMONELLA (/25g)             ", "AUSENTE / AUSENTE                ", "AUSENTE "} )
aAdd( aLaudo, { "1-COLIFORMES 45ºC (UFC/g)       ", "0 / 5                            ", "<1.0    "} )
aAdd( aLaudo, { "2-ASPECTO                       ", "LIQUIDO VISCOSO / LIQUIDO VISCOSO", "CONFORME"} )
aAdd( aLaudo, { "2-COR                           ", "MARROM / MARROM                  ", "CONFORME"} )
aAdd( aLaudo, { "2-UMIDADE (%)                   ", "0 / 1,0                          ", "0.33    "} )
aAdd( aLaudo, { "2-INSOLUVEL EM ACETONA (%)      ", "62 / >                           ", "63.45   "} )
aAdd( aLaudo, { "2-INSOLÚVEIS EM HEXANO (%)      ", "0 / 0,30                         ", "0.05    "} )
aAdd( aLaudo, { "2-ÍNDICE DE ACIDEZ (mgKOH/g)    ", "0 / 32                           ", "23.70   "} )
aAdd( aLaudo, { "2-ÍNDICE DE PERÓXIDO (meq/kg)   ", "0 / 5,00                         ", "<1      "} )
aAdd( aLaudo, { "2-COR GARDNER                   ", "0 / 10                           ", "7.00    "} )
aAdd( aLaudo, { "2-VISCOSIDADE 25°C (Cp)         ", "80 / >                           ", "104.00  "} )
aAdd( aLaudo, { "2-CONTAGEM TOTAL EM PLACA UFC/G ", "0 / 100                          ", "<10     "} )
aAdd( aLaudo, { "2-BOLORES E LEVEDURAS (UFC/g)   ", "0 / 100                          ", "<10     "} )
aAdd( aLaudo, { "2-SALMONELLA (/25g)             ", "AUSENTE / AUSENTE                ", "AUSENTE "} )
aAdd( aLaudo, { "2-COLIFORMES 45ºC (UFC/g)       ", "0 / 5                            ", "<1.0    "} )
aAdd( aLaudo, { "3-ASPECTO                       ", "LIQUIDO VISCOSO / LIQUIDO VISCOSO", "CONFORME"} )
aAdd( aLaudo, { "3-COR                           ", "MARROM / MARROM                  ", "CONFORME"} )
aAdd( aLaudo, { "3-UMIDADE (%)                   ", "0 / 1,0                          ", "0.33    "} )
aAdd( aLaudo, { "3-INSOLUVEL EM ACETONA (%)      ", "62 / >                           ", "63.45   "} )
aAdd( aLaudo, { "3-INSOLÚVEIS EM HEXANO (%)      ", "0 / 0,30                         ", "0.05    "} )
aAdd( aLaudo, { "3-ÍNDICE DE ACIDEZ (mgKOH/g)    ", "0 / 32                           ", "23.70   "} )
aAdd( aLaudo, { "3-ÍNDICE DE PERÓXIDO (meq/kg)   ", "0 / 5,00                         ", "<1      "} )
aAdd( aLaudo, { "3-COR GARDNER                   ", "0 / 10                           ", "7.00    "} )
aAdd( aLaudo, { "3-VISCOSIDADE 25°C (Cp)         ", "80 / >                           ", "104.00  "} )
aAdd( aLaudo, { "3-CONTAGEM TOTAL EM PLACA UFC/G ", "0 / 100                          ", "<10     "} )
aAdd( aLaudo, { "3-BOLORES E LEVEDURAS (UFC/g)   ", "0 / 100                          ", "<10     "} )
aAdd( aLaudo, { "3-SALMONELLA (/25g)             ", "AUSENTE / AUSENTE                ", "AUSENTE "} )
aAdd( aLaudo, { "3-COLIFORMES 45ºC (UFC/g)       ", "0 / 5                            ", "<1.0    "} )
aAdd( aLaudo, { "4-ASPECTO                       ", "LIQUIDO VISCOSO / LIQUIDO VISCOSO", "CONFORME"} )
aAdd( aLaudo, { "4-COR                           ", "MARROM / MARROM                  ", "CONFORME"} )
aAdd( aLaudo, { "4-UMIDADE (%)                   ", "0 / 1,0                          ", "0.33    "} )
aAdd( aLaudo, { "4-INSOLUVEL EM ACETONA (%)      ", "62 / >                           ", "63.45   "} )
aAdd( aLaudo, { "4-INSOLÚVEIS EM HEXANO (%)      ", "0 / 0,30                         ", "0.05    "} )
aAdd( aLaudo, { "4-ÍNDICE DE ACIDEZ (mgKOH/g)    ", "0 / 32                           ", "23.70   "} )
aAdd( aLaudo, { "4-ÍNDICE DE PERÓXIDO (meq/kg)   ", "0 / 5,00                         ", "<1      "} )
aAdd( aLaudo, { "4-COR GARDNER                   ", "0 / 10                           ", "7.00    "} )
aAdd( aLaudo, { "4-VISCOSIDADE 25°C (Cp)         ", "80 / >                           ", "104.00  "} )
aAdd( aLaudo, { "4-CONTAGEM TOTAL EM PLACA UFC/G ", "0 / 100                          ", "<10     "} )
aAdd( aLaudo, { "4-BOLORES E LEVEDURAS (UFC/g)   ", "0 / 100                          ", "<10     "} )
aAdd( aLaudo, { "4-SALMONELLA (/25g)             ", "AUSENTE / AUSENTE                ", "AUSENTE "} )
aAdd( aLaudo, { "4-COLIFORMES 45ºC (UFC/g)       ", "0 / 5                            ", "<1.0    "} )
aAdd( aLaudo, { "5-ASPECTO                       ", "LIQUIDO VISCOSO / LIQUIDO VISCOSO", "CONFORME"} )
aAdd( aLaudo, { "5-COR                           ", "MARROM / MARROM                  ", "CONFORME"} )
aAdd( aLaudo, { "5-UMIDADE (%)                   ", "0 / 1,0                          ", "0.33    "} )
aAdd( aLaudo, { "5-INSOLUVEL EM ACETONA (%)      ", "62 / >                           ", "63.45   "} )
aAdd( aLaudo, { "5-INSOLÚVEIS EM HEXANO (%)      ", "0 / 0,30                         ", "0.05    "} )
aAdd( aLaudo, { "5-ÍNDICE DE ACIDEZ (mgKOH/g)    ", "0 / 32                           ", "23.70   "} )
aAdd( aLaudo, { "5-ÍNDICE DE PERÓXIDO (meq/kg)   ", "0 / 5,00                         ", "<1      "} )
aAdd( aLaudo, { "5-COR GARDNER                   ", "0 / 10                           ", "7.00    "} )
aAdd( aLaudo, { "5-VISCOSIDADE 25°C (Cp)         ", "80 / >                           ", "104.00  "} )
aAdd( aLaudo, { "5-CONTAGEM TOTAL EM PLACA UFC/G ", "0 / 100                          ", "<10     "} )
aAdd( aLaudo, { "5-BOLORES E LEVEDURAS (UFC/g)   ", "0 / 100                          ", "<10     "} )
aAdd( aLaudo, { "5-SALMONELLA (/25g)             ", "AUSENTE / AUSENTE                ", "AUSENTE "} )
aAdd( aLaudo, { "5-COLIFORMES 45ºC (UFC/g)       ", "0 / 5                            ", "<1.0    "} )
*/


Static Function RetItem(cAliasQry)
Local cItem := ''
Conout('RetItem')
DbSelectArea('SD2')
SD2->(DbSetOrder(3))
If SD2->(DbSeek(xFilial('SD2') + (cAliasQry)->(NOTA + SERIE + CLIENTE + LOJA )))
    Conout('Achou' + Alltrim(SD2->D2_LOTECTL) + ' ' + Alltrim((cAliasQry)->LOTE))
    If Alltrim(SD2->D2_LOTECTL) <> Alltrim((cAliasQry)->LOTE)
        Conout(' é diferente ')
        While xFilial('SD2') + (cAliasQry)->(NOTA + SERIE + CLIENTE + LOJA ) == SD2->(D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA)
            Conout('While ' + Alltrim(SD2->D2_LOTECTL) + ' ' + Alltrim((cAliasQry)->LOTE))
            If Alltrim(SD2->D2_LOTECTL) == Alltrim((cAliasQry)->LOTE)
                cItem := SD2->D2_ITEM
                Exit
            EndIf
            SD2->(DbSkip())
        EndDo
    Else
        Conout(' é igual ')
        cItem := SD2->D2_ITEM
    EndIF
EndIf
Conout('Item - ' + cItem)
Return cItem
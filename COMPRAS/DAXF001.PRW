#INCLUDE 'PROTHEUS.CH'         

USER FUNCTION DMMDF001() // FUNÇÃO DUMMY
LOCAL cMsg := ""

// POSICIONO A NOTA FISCAL
DBSELECTAREA("SF1")
DBSETORDER(1)
IF DBSEEK(xFilial("SF1")+"000000420"+"001")
	cSeek       := xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA

	DBSELECTAREA("SD1")
	DBSETORDER(1)
	IF DBSEEK(cSeek)
		cMsg := U_DAXF001()
	ENDIF
ENDIF

RETURN cMsg
/*
+==========================================================================================+
| Programa............:   DAXF001                                                          |
| Autor(es)...........:   Cicero Odilio Cruz                                               |
| Data................:   20/10/2019                                                       |
| Descricao / Objetivo:   Retorna Mesnagem da Nota Fiscal de Importação                    |
| Doc. Origem.........:   N/A                                                              |
| Solicitante.........:   TOTVS Ibirapuera                                                 |
| Uso.................:   Importação - Nota de Entrada - Formula 162                       |
| Obs.................:                                                                    |
+==========================================================================================+
*/ 
USER FUNCTION DAXF001()
LOCAL aArea     := GetArea()
LOCAL aAreaSWD  := SWD->(GetArea())
LOCAL cNF 		:= SF1->F1_DOC 
LOCAL cSerie 	:= SF1->F1_SERIE
LOCAL cMsg722   := "" //POSICIONE( "SWD", 3, xFilial("SWD") + "722" + SF1->F1_DOC + SF1->F1_HAWB, ALLTRIM("WD_DESPESA") )
LOCAL cMsg405   := "" //POSICIONE( "SWD", 3, xFilial("SWD") + "405" + SF1->F1_DOC + SF1->F1_HAWB, ALLTRIM("WD_DESPESA") ) 
LOCAL cPIS      := ALLTRIM( TRANSFORM( SF1->F1_VALIMP6, '@E 99,999,999.99' ) )
LOCAL cCOFINS   := ALLTRIM( TRANSFORM( SF1->F1_VALIMP5, '@E 99,999,999.99' ) )
LOCAL cDI  	    := POSICIONE( "SW6", 1, xFilial("SW6") + SF1->F1_HAWB, ALLTRIM("W6_DI_NUM")) 
LOCAL cAliasDI  := GETNEXTALIAS()
LOCAL cMsg		:= ''
IF SD1->D1_ITEM == "0001" // Executa somente para o item 001
	BEGINSQL ALIAS cAliasDI
		SELECT 	WD_DESPESA, WD_VALOR_R
		FROM 	%table:SWD% SWD (NOLOCK)
		WHERE 		SWD.WD_FILIAL	= %xFilial:SWD%
           		AND SWD.WD_NF_COMP 	= %exp:cNF% 
          		AND SWD.WD_SE_NFC 	= %exp:cSerie% 
           		AND SWD.%NotDel%
	ENDSQL

	WHILE !(cAliasDI)->(EOF())
		
		IF (cAliasDI)->WD_DESPESA == "722"
			cMsg722 := ALLTRIM( TRANSFORM( (cAliasDI)->WD_VALOR_R , '@E 99,999,999.99' ) )
		ELSEIF (cAliasDI)->WD_DESPESA == "405"
			cMsg405 := ALLTRIM( TRANSFORM( (cAliasDI)->WD_VALOR_R , '@E 99,999,999.99' ) )
		ENDIF
		dbSelectArea(cAliasDI)
		dbSkip()

	ENDDO

	cMsg := " Custos de Nacionalização: SISCOMEX: " 
	cMsg += cMsg722
	cMsg += " - Marinha Mercante: " 
	cMsg += cMsg405
	cMsg += " - PIS: " + cPIS
	cMsg += " - COFINS: " + cCOFINS
	cMsg += " - DI: " +  cDI
	cMsg += " - Proc.Import.: " + SF1->F1_HAWB
ENDIF

RestArea(aAreaSWD)
RestArea(aArea)
RETURN cMsg
#Include "Protheus.CH"
#Include "topconn.ch"
/*/{Protheus.doc} DAXREL07()
    Relatorio de Resumo de importação
    @type  Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function DAXREL07()
Local cArqTrb, cIndice1, cIndice2, cIndice3, cIndice4
Local cQuery
Local aParam := {}
Local aRet := {}
Local cPoDe     := ''
Local cPoAte    := ''
Local dDtDe     := dDataBase
Local dDtAte    := dDataBase
Local cFornDe   := ''
Local cFornAte  := ''
Local cAgeDe    := ''
Local cAgeAte   := ''
Local dEmbDe    := dDataBase
Local dEmbAte   := dDataBase
Local cProdDe   := ''
Local cProdAte  := ''
Local dEstDe    := dDataBase
Local dEstAte   := dDataBase
Local cPortDe   := ''
Local cPortAte  := ''
Local cPaisDe   := ''
Local cPaisAte  := ''
Local nBook     := 0
Local nTTime    := 0
Local nDesemb   := 0
Local lDtEmbVazio   := .F.
Local lDtEstVazio   := .F.
Local cPoOld        := ''
Private oBrowse
Private aRotina		:= MenuDef()
Private cCadastro 	:= "Resumo de importação"
Private aCampos	:= {}, aSeek := {}, aDados := {}, aValores := {}, aFieFilter := {}

UpdZH()

aAdd(aParam, {1, "Po De"		        , CriaVar('W2_PO_NUM',.F.) ,  ,, ,, 60, .F.} )      //MV_PAR01
aAdd(aParam, {1, "Po Até"		        , CriaVar('W2_PO_NUM',.F.) ,  ,, ,, 60, .F.} )      //MV_PAR02
aAdd(aParam, {1, "Data Po de"		    , STOD("//") ,  ,, ,, 60, .F.} )                    //MV_PAR03
aAdd(aParam, {1, "Data Po ate"		    , STOD("//") ,  ,, ,, 60, .F.} )                    //MV_PAR04
aAdd(aParam, {1, "Fornecedor De"	    , CriaVar('W2_FORN',.F.) ,  ,, 'SA2',, 60, .F.} )   //MV_PAR05
aAdd(aParam, {1, "Fornecedor Ate"	    , CriaVar('W2_FORN',.F.) ,  ,, 'SA2',, 60, .F.})    //MV_PAR06
aAdd(aParam, {1, "Agente De"	        , CriaVar('W2_AGENTE',.F.) ,  ,, 'SY4',, 60, .F.} ) //MV_PAR07
aAdd(aParam, {1, "Agente Ate"	        , CriaVar('W2_AGENTE',.F.) ,  ,, 'SY4',, 60, .F.} ) //MV_PAR08
aAdd(aParam, {1, "Data Embarque De"		, STOD("//") ,  ,, ,, 60, .F.} )                    //MV_PAR09
aAdd(aParam, {1, "Data Embarque ate"	, STOD("//") ,  ,, ,, 60, .F.} )                    //MV_PAR10
aAdd(aParam, {2, "Considerar campo de data vazio?"	, '1-Sim',{'1-Sim','2-Não'},122,".T.",.F.  } )//MV_PAR11
aAdd(aParam, {1, "Produto De"	        , CriaVar('B1_COD',.F.) ,  ,, 'SB1',, 60, .F.} )    //MV_PAR12
aAdd(aParam, {1, "Produto Ate"	        , CriaVar('B1_COD',.F.) ,  ,, 'SB1',, 60, .F.} )    //MV_PAR13
aAdd(aParam, {1, "Data Estoque De"		, STOD("//") ,  ,, ,, 60, .F.} )                    //MV_PAR14
aAdd(aParam, {1, "Data Estoque ate"	, STOD("//") ,  ,, ,, 60, .F.} )                        //MV_PAR15
aAdd(aParam, {2, "Considerar campo de data vazio?"	,'1-Sim',{'1-Sim','2-Não'},122,".T.",.F.  } )//MV_PAR16
aAdd(aParam, {1, "Porto De"	        , CriaVar('W6_DEST',.F.) ,  ,, ,, 60, .F.} )            //MV_PAR17
aAdd(aParam, {1, "Porto Ate"	        , CriaVar('W6_DEST',.F.) ,  ,, ,, 60, .F.} )        //MV_PAR18
aAdd(aParam, {1, "Pais De"	            , CriaVar('A2_PAIS',.F.) ,  ,, 'SYA',, 60, .F.} )   //MV_PAR19
aAdd(aParam, {1, "Pais Ate"	            , CriaVar('A2_PAIS',.F.) ,  ,, 'SYA',, 60, .F.})    //MV_PAR20
If !ParamBox(aParam,'Parâmetros',aRet)
    Return
EndIf

cPoDe       := aRet[1]
cPoAte      := aRet[2]
dDtDe       := aRet[3]
dDtAte      := aRet[4]
cFornDe     := aRet[5]
cFornAte    := aRet[6]
cAgeDe      := aRet[7]
cAgeAte     := aRet[8]
dEmbDe      := aRet[9]
dEmbAte     := aRet[10]
lDtEmbVazio := IIF(aRet[11] == '1-Sim',.T.,.F.)
cProdDe     := aRet[12]
cProdAte    := aRet[13]
dEstDe      := aRet[14]
dEstAte     := aRet[15]
lDtEstVazio := IIF(aRet[16] == '1-Sim' , .T. ,.F.)
cPortDe     := aRet[17]
cPortAte    := aRet[18]
cPaisDe     := aRet[19]
cPaisAte     := aRet[20]

//Array contendo os campos da tabela temporï¿½ria
AADD(aCampos,{"W2_PO_NUM"		,"C", TAMSX3('W2_PO_NUM')[1], 0})
AADD(aCampos,{"W2_NR_PRO"		,"C", TAMSX3('W2_NR_PRO')[1], 0})
AADD(aCampos,{"W2_FORNDES"		,"C", 40, 0})
AADD(aCampos,{"W2_FORN"		    ,"C", TAMSX3('W2_FORN')[1], 0})
AADD(aCampos,{"YA_DESCR"		,"C", TAMSX3('YA_DESCR')[1], 0})
AADD(aCampos,{"W6_HOUSE"		,"C", TAMSX3('W6_HOUSE')[1], 0})
AADD(aCampos,{"W2_AGENTE"		,"C", TAMSX3('W2_AGENTE')[1], 0})
AADD(aCampos,{"Y4_NOME" 		,"C", TAMSX3('Y4_NOME')[1], 0})
AADD(aCampos,{"W9_FRETEIN"		,"N", TAMSX3('W9_FRETEIN')[1], 0})
AADD(aCampos,{"W8_COD_I"		,"C", TAMSX3('W8_COD_I')[1], 0})
AADD(aCampos,{"DESCRICAO"		,"C", /*TAMSX3('W8_DESC_VM')[1]*/ 15, 0})
AADD(aCampos,{"W7_PESO"		    ,"N", TAMSX3('W7_PESO')[1], 0})
AADD(aCampos,{"QTCONT"  		,"C", TAMSX3('W6_CONTA20')[1], 0})
AADD(aCampos,{"TIPO"		    ,"C", 15, 0})
AADD(aCampos,{"PORTODEST"		,"C", 15, 0})
AADD(aCampos,{"TERMINAL"		,"C", 40, 0})
AADD(aCampos,{"W7_PRECO_R"		,"N", TAMSX3('W7_PRECO_R')[1], 0})
AADD(aCampos,{"W2_PO_DT"		,"D", TAMSX3('W2_PO_DT')[1], 0})
AADD(aCampos,{"W2_DT_PRO"		,"D", TAMSX3('W2_DT_PRO')[1], 0})
AADD(aCampos,{"B1_ANUENTE"		,"C", 5, 0})
AADD(aCampos,{"W2_INCOTER"		,"C", TAMSX3('W2_INCOTER')[1], 0})
AADD(aCampos,{"W6_DT_ETD"		,"D", TAMSX3('W6_DT_ETD')[1], 0})
AADD(aCampos,{"W6_DT_EMB"		,"D", TAMSX3('W6_DT_EMB')[1], 0})
AADD(aCampos,{"W6_DT_ETA"		,"D", TAMSX3('W6_DT_ETA ')[1], 0})
AADD(aCampos,{"W6_DTREG_D"		,"D", TAMSX3('W6_DTREG_D')[1], 0})
AADD(aCampos,{"FRETNEG"		    ,"N", TAMSX3('W2_FRETNEG')[1], 0})
AADD(aCampos,{"ESTOQUE"		    ,"D", 8, 0})
AADD(aCampos,{"BOOK"		    ,"N", 8, 0})
AADD(aCampos,{"TRANSITTIM"		,"N", 8, 0})
AADD(aCampos,{"FREETIM"		    ,"N", TAMSX3('W6_FREETIM')[1], 0})
AADD(aCampos,{"DIASDESEMB"		,"N", 8, 0})
AADD(aCampos,{"TRANSTOT"		,"N", 8, 0})
AADD(aCampos,{"QUANT"		    ,"C", 8, 0})
AADD(aCampos,{"VUNIT"		    ,"N", 26, 8})
AADD(aCampos,{"VTOTAL"		    ,"C", 26, 8})
AADD(aCampos,{"CUSTOEST"		,"N", 26, 8})
AADD(aCampos,{"CUSTOEFT"		,"N", 26, 8})
AADD(aCampos,{"CUSTOFIN"   		,"N", 26, 8})
AADD(aCampos,{"VLRPAGO" 		,"N", 26, 8})
AADD(aCampos,{"VLRDI"    		,"N", 26, 8})
AADD(aCampos,{"VARCAMB"   		,"N", 26, 8})
AADD(aCampos,{"VARUNIT"   		,"N", 26, 8})
AADD(aCampos,{"VARIACAO"		,"N", 26, 8})
AADD(aCampos,{"W6_DTRECDO"		,"D", TAMSX3('W6_DTRECDO')[1], 0})
AADD(aCampos,{"Y5_NOME"		    ,"C", TAMSX3('Y5_NOME')[1], 0})
AADD(aCampos,{"PORTOORIG"		    ,"C", TAMSX3('YR_CID_ORI')[1], 0})


//Antes de criar a tabela, verificar se a mesma jï¿½ foi aberta
If (Select("TRBREL") <> 0)
    dbSelectArea("TRBREL")
    TRBREL->(dbCloseArea ())
Endif

cArqTrb   := CriaTrab(aCampos,.T.)

//Definir indices da tabela
cIndice1 := Alltrim(CriaTrab(,.F.))
cIndice2 := cIndice1
cIndice3 := cIndice1
cIndice4 := cIndice1

cIndice1 := Left(cIndice1,5)+Right(cIndice1,2)+"A"
cIndice2 := Left(cIndice2,5)+Right(cIndice2,2)+"B"
cIndice3 := Left(cIndice3,5)+Right(cIndice3,2)+"C"
cIndice4 := Left(cIndice4,5)+Right(cIndice4,2)+"D"
		
If File(cIndice1+OrdBagExt())
    FErase(cIndice1+OrdBagExt())
EndIf

If File(cIndice2+OrdBagExt())
    FErase(cIndice2+OrdBagExt())
EndIf

If File(cIndice3+OrdBagExt())
    FErase(cIndice3+OrdBagExt())
EndIf

If File(cIndice4+OrdBagExt())
    FErase(cIndice4+OrdBagExt())
EndIf

dbUseArea(.T.,,cArqTrb,"TRBREL",Nil,.F.)
	
/*Criar indice*/
IndRegua("TRBREL", cIndice1, "W2_PO_NUM"	,,, "Indice Num PO")
IndRegua("TRBREL", cIndice2, "W2_NR_PRO"	,,, "Indice Num Prop")
IndRegua("TRBREL", cIndice3, "W2_FORN"	    ,,, "Indice Fornecedor")
IndRegua("TRBREL", cIndice4, "W2_PO_DT"		,,, "Indice Data Entrada")

dbClearIndex()
dbSetIndex(cIndice1+OrdBagExt())
dbSetIndex(cIndice2+OrdBagExt())
dbSetIndex(cIndice3+OrdBagExt())
dbSetIndex(cIndice4+OrdBagExt())
    
//popular a tabela
cArq := CriaTrab(aCampos,.F.)
dbCreate(cArq,aCampos,"DBFCDX")


cQuery := "SELECT DISTINCT W2_PO_NUM AS PO , W2_FRETNEG AS FRETNEG, W6_XTERMIN AS TERMINAL ,W6_FREETIM AS FREETIM ,W2_NR_PRO AS DOC ,F1_RECBMTO, W2_FORLOJ AS LOJA, W6_DT_ENTR,W7_II AS II ,W2_FORN AS FORNECEDOR ,A2_PAIS AS PAIS,  W6_HOUSE AS HDL , W2_AGENTE AS AGENTE , Y4_NOME ,W6_VLFRECC  AS VLFRETE , B1_DESC AS DESCRICAO , W3_COD_I AS DESCVM , W7_PESO * W7_QTDE AS PESO  "
cQuery += "  ,W6_CONTA20 ,W2_ORIGEM AS PORTOORIG , W2_INCOTER, W6_CONTA40 , W6_CON40HC , W6_OUTROS ,  'TIPO ' AS TPCONT , W6_DEST AS PORTDEST , W7_QTDE * W7_PRECO AS VLRPROC , W2_PO_DT AS EMISPO, W2_DT_PRO AS DTPRO , B1_ANUENTE AS ANUENTE , W6_DT_ETD AS PREVEMB , W6_DT_EMB AS DTEMB , W6_DT_ETA AS DTPORTO , W6_DTREG_D AS DTDESEMB , F1_RECBMTO AS ESTOQUE , 'BOOK*' AS BOOK , 'TRANSIT TIME*' AS TRANSIT,"
cQuery += "'DIAS DESEMB*' AS DIASDESEMB ,W2_DESP, 'TRANSITO TOTAL*' AS TRANSTOT ,  W6_DTRECDO  AS RECDOCTO ,W6_DEST , W7_QTDE ,W7_PRECO , "
cQuery += " ( SELECT TOP 1((SUM(EI2_FOB_R+EI2_DESPES+EI2_VLDEII) / SM2.M2_MOEDA2) / SUM(EI2_QUANT)) FROM EI2010 EI2 INNER JOIN SM2010 SM2 ON M2_DATA = SW6.W6_DTREG_D  WHERE W2_PO_NUM = EI2_PO_NUM AND EI2_POSICA = SW7.W7_POSICAO AND EI2.D_E_L_E_T_ = '' AND EI2_FILIAL = '" + xFilial('EI2') + "'  	 GROUP BY M2_MOEDA2)AS CUSTOEFT,
cQuery += " (SUM(EI2_FOB_R+EI2_DESPES+EI2_VLDEII) / SUM(EI2_QUANT)) AS CUSTEFTR ,"
cQuery += " ( SELECT TOP 1 SUM(W7_QTDE) FROM SW7010 SW7A WHERE SW7A.D_E_L_E_T_ = '' AND  W2_PO_NUM = SW7A.W7_PO_NUM AND SW7A.W7_FILIAL = '" + xFilial('SW7') + "'  	 )AS QUANT,
cQuery += " W7_PRECO AS VUNIT,
cQuery += " W2_FOB_TOT AS VTOTAL,
cQuery += " ((SELECT SUM(ZH_VALOR)    FROM SZH010 SZH    WHERE ZH_PO_NUM = SW2.W2_PO_NUM    AND REPLICATE('0',(4 -LEN(ZH_NR_CONT)))+CAST(ZH_NR_CONT AS VARCHAR(4)) = SW7.W7_POSICAO    AND ZH_FILIAL = '" + xFilial('SZH') + "'    AND SZH.D_E_L_E_T_ = ' '    AND ZH_PO_NUM = SW2.W2_PO_NUM	AND ZH_DESPESA IN (SELECT ZH_DESPESA FROM SZH010 WHERE                         SZH.D_E_L_E_T_ = ' ' AND ZH_DESPESA BETWEEN '101' AND '899'						AND ZH_DESPESA NOT IN (SELECT ZH_DESPESA FROM SZH010 WHERE SZH.D_E_L_E_T_ = ' ' AND ZH_DESPESA BETWEEN '201' AND '299'						AND ZH_DESPESA NOT IN ('104')))		)/W7_QTDE) AS CUSTOEST ," 
cQuery += " EI2_HAWB PROCESSO, SUM(EI2_RATEIO) RATEIO, SUM(EI2_FOB_R) VLRDI, SUM((EI2_FOB_R/EI1_FOB_R) * E2_VALLIQ) VLRPAGO, SUM((EI2_FOB_R/EI1_FOB_R) * E2_VALLIQ)-SUM(EI2_FOB_R) VARCAMB, SUM(EI2_QUANT) QUANT, (SUM((EI2_FOB_R/EI1_FOB_R) *  E2_VALLIQ)-SUM(EI2_FOB_R))/SUM(EI2_QUANT) VARUNIT"
cQuery += "  FROM " + RetSqlName("SW2") + " SW2 "
cQuery += " INNER JOIN "  + RetSqlName("SW3") + " SW3 ON W2_PO_NUM = W3_PO_NUM  "
cQuery += " INNER JOIN "  + RetSqlName("SW6") + " SW6 ON W2_PO_NUM = W6_PO_NUM  "
cQuery += "  LEFT JOIN "  + RetSqlName("SW9") + " SW9 ON W2_PO_NUM = W9_HAWB AND W9_FILIAL = '" + xFilial('SW9') + "'"
cQuery += "  LEFT JOIN "  + RetSqlName("SW8") + " SW8 ON W2_PO_NUM = W8_PO_NUM AND SW8.D_E_L_E_T_ = '' AND W8_FILIAL = '" + xFilial('SW3') + "'"
cQuery += "  LEFT JOIN "  + RetSqlName("SF1") + " SF1 ON W2_PO_NUM = F1_HAWB"
If lDtEstVazio
    cQuery += " AND ((F1_RECBMTO BETWEEN '" + DTOS(dEstDe) + "' AND '" + DTOS(dEstAte) + "') OR F1_RECBMTO = '        ')"
Else
    cQuery += " AND F1_RECBMTO BETWEEN '" + DTOS(dEstDe) + "' AND '" + DTOS(dEstAte) + "' "
EndIf
cQuery += " AND SF1.D_E_L_E_T_ = ''" 

cQuery += "  INNER JOIN "  + RetSqlName("SW7") + " SW7 ON W2_PO_NUM = W7_PO_NUM AND W3_COD_I = W7_COD_I"
cQuery += "  INNER JOIN "  + RetSqlName("SB1") + " SB1 ON W7_COD_I = B1_COD "
cQuery += "  INNER JOIN "  + RetSqlName("SA2") + " SA2 ON A2_COD = W2_FORN  AND A2_LOJA = W2_FORLOJ "
cQuery += "  INNER JOIN "  + RetSqlName("SY4") + " SY4 ON Y4_FILIAL = '" + xFilial('SY4') +"' AND Y4_COD = W2_AGENTE AND SY4.D_E_L_E_T_ = ' ' "
cQuery += "  LEFT JOIN "  + RetSqlName("EI2") + " EI2 ON EI2_FILIAL = '" + xFilial('EI2') +"' AND W2_PO_NUM = EI2_PO_NUM AND EI2_PRODUT = W3_COD_I AND EI2.D_E_L_E_T_ = ' ' "
cQuery += "  LEFT JOIN "  + RetSqlName("SE2") + " SE2 ON E2_FILIAL = '" + xFilial('SE2') +"' AND SUBSTRING(E2_HIST, 4, CHARINDEX ( ':' , E2_HIST ,3 ) - 4 - 2 ) = SUBSTRING(EI2_HAWB, 1,LEN(TRIM(EI2_HAWB))) AND SE2.E2_TIPO = 'INV' AND SE2.D_E_L_E_T_ = ' ' "
cQuery += "  LEFT JOIN "  + RetSqlName("EI1") + " EI1 ON EI1_FILIAL = '" + xFilial('EI1') +"' AND EI1_HAWB = EI2_HAWB AND EI1_DOC = EI2_DOC AND EI1.D_E_L_E_T_='' "
cQuery += " WHERE "
cQuery += "   SW2.D_E_L_E_T_ = ''" 
cQuery += " AND SW6.D_E_L_E_T_ = ''" 
cQuery += " AND SW7.D_E_L_E_T_ = ''"    
cQuery += " AND SB1.D_E_L_E_T_ = ''" 

cQuery += " AND SA2.D_E_L_E_T_ = ''" 
cQuery += " AND W2_FILIAL = '" + xFilial('SW2') + "'"
cQuery += " AND W6_FILIAL = '" + xFilial('SW6') + "'"
cQuery += " AND W7_FILIAL = '" + xFilial('SW7') + "'"
cQuery += " AND B1_FILIAL = '" + xFilial('SB1') + "'"
cQuery += " AND W2_PO_NUM BETWEEN '" + cPoDe + "' AND '" + cPoAte + "' "
cQuery += " AND W2_PO_DT BETWEEN '" + DTOS(dDtDe) + "' AND '" + DTOS(dDtAte) + "' "
cQuery += " AND W2_AGENTE BETWEEN '" + cAgeDe + "' AND '" + cAgeAte + "' "
cQuery += " AND W2_FORN BETWEEN '" + cFornDe + "' AND '" + cFornAte + "' "
If lDtEmbVazio
    cQuery += " AND ((W6_DT_EMB BETWEEN '" + DTOS(dEmbDe) + "' AND '" + DTOS(dEmbAte) + "') OR W6_DT_EMB = '        ')"
Else
    cQuery += " AND W6_DT_EMB BETWEEN '" + DTOS(dEmbDe) + "' AND '" + DTOS(dEmbAte) + "' "
EndIf
cQuery += " AND W3_COD_I BETWEEN '" + cProdDe + "' AND '" + cProdAte + "' "
cQuery += " AND W6_DEST BETWEEN '" + cPortDe + "' AND '" + cPortAte + "' "
cQuery += " AND A2_PAIS BETWEEN '" + cPaisDe + "' AND '" + cPaisAte + "' "
cQuery += " GROUP BY W2_PO_NUM ,W6_FREETIM,W2_ORIGEM ,A2_PAIS, W2_DESP,W2_NR_PRO ,W2_FRETNEG ,W6_XFT,W2_FOB_TOT,F1_RECBMTO, B1_DESC ,W7_II,W2_INCOTER ,W3_COD_I,W6_VLFRECC, W6_DT_HAWB,W7_POSICAO,W2_FORLOJ ,W6_DT_ENTR, W2_FORN  , W6_HOUSE  , W2_AGENTE , W9_FRETEIN  , Y4_NOME ,W8_DESC_DI,  W7_PESO,  W6_CONTA20 , W6_CONTA40 , W6_CON40HC , W6_OUTROS ,  W6_DEST  , W7_PRECO_R  , W2_PO_DT , W2_DT_PRO  , B1_ANUENTE , W6_DT_ETD , W6_DT_EMB , W6_DT_ETA , W6_DTREG_D  , W6_DTREG_D  ,W6_DEST , W7_QTDE ,W7_PRECO   ,EI2_HAWB, EI2_POSICA,W6_XTERMIN,W6_DTRECDO"
cQuery += " ORDER BY PO ,EMISPO DESC " 


TCQUERY cQuery New Alias "TMPREL"
MemoWrite('C:\TOTVS\DAXREL07.txt', cQuery)	
Dbselectarea("TMPREL")
dbGoTop()
While TMPREL->(!EOF())

    dbSelectArea("TRBREL")
    RecLock("TRBREL",.T.) 
    TRBREL->W2_PO_NUM   := TMPREL->PO                   
    TRBREL->W2_NR_PRO   := TMPREL->DOC
    TRBREL->W2_FORN     := TMPREL->FORNECEDOR   
    TRBREL->W2_FORNDES  :=POSICIONE('SA2',1,xFilial('SA2') + TMPREL->FORNECEDOR + TMPREL->LOJA , 'A2_NOME')
    TRBREL->YA_DESCR    :=POSICIONE('SYA',1,xFilial('SYA') + TMPREL->PAIS , 'YA_DESCR')
    TRBREL->W6_HOUSE    := TMPREL->HDL
    TRBREL->W2_AGENTE   := TMPREL->AGENTE
    TRBREL->Y4_NOME     := TMPREL->Y4_NOME
    TRBREL->W9_FRETEIN   := TMPREL->FRETNEG
    TRBREL->W8_COD_I     := TMPREL->DESCVM
    TRBREL->DESCRICAO   := TMPREL->DESCRICAO
    TRBREL->W7_PESO     := TMPREL->PESO 
    If TMPREL->W6_CONTA20 > 0 
        TRBREL->QTCONT      := Alltrim(STR(TMPREL->W6_CONTA20))
        TRBREL->TIPO        := '20'
    ElseIf TMPREL->W6_CONTA40 > 0
        TRBREL->QTCONT      := Alltrim(STR(TMPREL->W6_CONTA40))
        TRBREL->TIPO        := '40'
    ElseIf TMPREL->W6_CON40HC > 0
        TRBREL->QTCONT      := Alltrim(STR(TMPREL->W6_CON40HC))
        TRBREL->TIPO        := 'HC'           
    ElseIf TMPREL->W6_OUTROS > 0 
        TRBREL->QTCONT      := Alltrim(STR(TMPREL->W6_OUTROS))
        TRBREL->TIPO        := 'OUTROS'     
    EndIf    
    TRBREL->PORTOORIG   := POSICIONE('SYR',3,xFilial('SYR') + TMPREL->PORTOORIG ,'YR_CID_ORI')
    TRBREL->PORTODEST   := TMPREL->PORTDEST
    TRBREL->TERMINAL   := TMPREL->TERMINAL
    TRBREL->Y5_NOME   := Posicione('SY5',1,xFilial('SY5')+ TMPREL->W2_DESP , 'Y5_NOME')
    TRBREL->W7_PRECO_R  := TMPREL->VLRPROC
    TRBREL->W2_PO_DT    := STOD(TMPREL->EMISPO)
    TRBREL->W2_DT_PRO   := STOD(TMPREL->DTPRO)
    TRBREL->B1_ANUENTE   := IIF(TMPREL->ANUENTE == '1','Sim','Não')
    TRBREL->W2_INCOTER   := TMPREL->W2_INCOTER
    TRBREL->FRETNEG     := TMPREL->FRETNEG
    TRBREL->FREETIM     := TMPREL->FREETIM
    TRBREL->W6_DT_ETD   := STOD(TMPREL->PREVEMB)
    TRBREL->W6_DT_EMB   := STOD(TMPREL->DTEMB)
    TRBREL->W6_DT_ETA   := STOD(TMPREL->DTPORTO)
    TRBREL->W6_DTREG_D  := STOD(TMPREL->DTDESEMB)
    TRBREL->ESTOQUE     := STOD(TMPREL->W6_DT_ENTR)
    nBook := DateDiffDay(STOD(TMPREL->PREVEMB),STOD(TMPREL->EMISPO))
    TRBREL->BOOK        := nBook
    nTTime := DateDiffDay(STOD(TMPREL->DTPORTO),STOD(TMPREL->PREVEMB))
    TRBREL->TRANSITTIM   := nTTime
    nDesemb := DateDiffDay(STOD(TMPREL->W6_DT_ENTR), STOD(TMPREL->DTPORTO))
    TRBREL->DIASDESEMB  := nDesemb
    TRBREL->TRANSTOT    := nBook + nDesemb + nTTime
    If cPoOld == TMPREL->PO
        TRBREL->QUANT   := '-'
        TRBREL->VTOTAL  := '-'
        TRBREL->QTCONT  := '-'
        TRBREL->TIPO    := '-'
    Else
        TRBREL->QUANT       := Alltrim(STR(TMPREL->QUANT))
        TRBREL->VTOTAL       := Alltrim(TRANSFORM(TMPREL->VTOTAL,"@E 999,999,999,999.99"))
        cPoOld := TMPREL->PO
    EndIf    
    TRBREL->VLRPAGO     := TMPREL->VLRPAGO        
    TRBREL->VLRDI       := TMPREL->VLRDI        
    TRBREL->VARCAMB     := TMPREL->VARCAMB        
    TRBREL->VARUNIT     := TMPREL->VARUNIT        
    TRBREL->VUNIT       := TMPREL->VUNIT        
    TRBREL->CUSTOEST    := TMPREL->CUSTOEST + TMPREL->II
    TRBREL->CUSTOEFT    := TMPREL->CUSTOEFT 
    TRBREL->CUSTOFIN    := TMPREL->CUSTEFTR + TMPREL->VARUNIT
    TRBREL->VARIACAO    := TRBREL->CUSTOEFT - TRBREL->CUSTOEST 
    TRBREL->W6_DTRECDO   := STOD(TMPREL->RECDOCTO)

    MsUnlock()
TMPREL->(dbSkip())
EndDo
TMPREL->(dbCloseArea())

dbSelectArea("TRBREL")
TRBREL->(DbGoTop())

//Campos que irï¿½o compor o combo de pesquisa na tela principal
Aadd(aSeek,{ "Indice Num PO"	    , {{"","C",TAMSX3('W2_PO_NUM')[1],0, "W2_PO_NUM" 	,"@!"}}, 1, .T. } )
Aadd(aSeek,{ "Indice Num Prop"	    , {{"","C",TAMSX3('W2_PO_DT')[1],0, "W2_PO_DT" 	,"@!"}}, 2, .T. } )
Aadd(aSeek,{ "Indice Fornecedor"	, {{"","C",TAMSX3('W2_PO_DT')[1],0, "W2_PO_DT"	 	,"@!"}}, 3, .T. } )
Aadd(aSeek,{ "Indice Data Entrada"  , {{"","D",TAMSX3('W2_PO_DT')[1],0, "W2_PO_DT" 	,"@D"}}, 4, .T. } )

//Campos que irï¿½o compor a tela de filtro
Aadd(aFieFilter,{"W2_PO_NUM"    , "Num PO"	  	    , "C", TAMSX3('W2_PO_NUM')[1], 0,"@!"})
Aadd(aFieFilter,{"W2_PO_DT" 	, "Num Prop"	  	, "C", TAMSX3('W2_PO_DT')[1], 0,"@!"})
Aadd(aFieFilter,{"W2_PO_DT"	    , "Fornecedor"	    , "C", TAMSX3('W2_PO_DT')[1], 0,"@!"})
Aadd(aFieFilter,{"W2_PO_DT" 	, "Data Entrada" 	, "D", TAMSX3('W2_PO_DT')[1], 0,"@D"})

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( "TRBREL" )
oBrowse:SetDescription( cCadastro )
oBrowse:SetSeek(.T.,aSeek)
oBrowse:SetTemporary(.T.)
oBrowse:SetLocate()
oBrowse:SetUseFilter(.T.)
oBrowse:SetDBFFilter(.T.)
oBrowse:SetFilterDefault( "" ) //Exemplo de como inserir um filtro padrï¿½o >>> "TR_ST == 'A'"
//oBrowse:SetFilterDefault("TRBREL->B8_LOTECTL='"+MV_PAR01+"' .And. TRBREL->B8_LOTEFOR='"+MV_PAR02+"'")
oBrowse:SetFieldFilter(aFieFilter)
oBrowse:DisableDetails()

//Detalhes das colunas que serï¿½o exibidas
oBrowse:SetColumns(MontaColunas("W2_PO_NUM"	    ,"Nro PO"			,01,"@!",1,010,0))//1
oBrowse:SetColumns(MontaColunas("W2_NR_PRO" 	,"Documento"		,02,"@!",0,010,0))//2
oBrowse:SetColumns(MontaColunas("W2_FORNDES"	,"Fornecedor"		,03,"@!",1,010,0))//3
oBrowse:SetColumns(MontaColunas("W2_FORN"	    ,"Nome Fornecedor"	,04,"@!",1,010,0))//4
oBrowse:SetColumns(MontaColunas("YA_DESCR"	    ,"Pais"     		,03,"@!",1,010,0))//5
oBrowse:SetColumns(MontaColunas("PORTOORIG"	    ,"Porto Origem"		,03,"@!",1,010,0))//6
oBrowse:SetColumns(MontaColunas("W6_HOUSE"	    ,"HBL\BL"		    ,05,"@!",1,020,0))//7
oBrowse:SetColumns(MontaColunas("W2_AGENTE"	    ,"Agente"		    ,06,"@!",1,010,0))//8
oBrowse:SetColumns(MontaColunas("Y4_NOME"	    ,"Nome Agente"	    ,06,"@!",1,010,0))//9
oBrowse:SetColumns(MontaColunas("Y5_NOME"	    ,"Nome Despachante" ,06,"@!",1,010,0))//10
oBrowse:SetColumns(MontaColunas("W9_FRETEIN"	,"Valor Frete"		,07,"@!",1,005,0))//11 ANTIGO W9_FRETEIN
oBrowse:SetColumns(MontaColunas("FREETIM"       ,"Free Time"	    ,29,"@!",1,020,0))//12
oBrowse:SetColumns(MontaColunas("TRANSITTIM"	,"Transit Time"		,27,"@!",1,020,0))//13
oBrowse:SetColumns(MontaColunas("W8_COD_I"	    ,"Cod Produto"		,08,"@!",1,010,0))//14
oBrowse:SetColumns(MontaColunas("DESCRICAO"	    ,"Nome Produto"		,09,"@!",1,040,0))//15
oBrowse:SetColumns(MontaColunas("W7_PESO"	    ,"Volume"			,10,"@!",2,005,0))//16
oBrowse:SetColumns(MontaColunas("QTCONT"	    ,"Qtd Container"	,11,"@!",1,010,0))//17
oBrowse:SetColumns(MontaColunas("TIPO"	        ,"Tipo Container"	,15,"@!",1,020,0))//18		
oBrowse:SetColumns(MontaColunas("PORTODEST"	    ,"Porto Dest"		,16,"@!",1,020,0))//19		
oBrowse:SetColumns(MontaColunas("TERMINAL"	    ,"Terminal"		    ,16,"@!",1,040,0))//20		
oBrowse:SetColumns(MontaColunas("W2_INCOTER"	,"Incoterm"     		,27,"@!",1,TAMSX3('W2_INCOTER')[1],0)) //21
oBrowse:SetColumns(MontaColunas("VUNIT"         ,"Valor Unitario"	    ,31,"@E 9,999,999.9999",2,020,0))	//22
oBrowse:SetColumns(MontaColunas("W7_PRECO_R"	,"Valor Processo U$",17,"@E 9,999,999.99",2,020,0))	//23
oBrowse:SetColumns(MontaColunas("W2_PO_DT"      ,"Emissao PO"		,18,"@!",1,020,0))//24	
oBrowse:SetColumns(MontaColunas("B1_ANUENTE"	,"Anuente"  		,20,"@!",1,020,0))//25		
oBrowse:SetColumns(MontaColunas("W6_DT_ETD"	    ,"ETD"      		,21,"@!",1,020,0))//26		
oBrowse:SetColumns(MontaColunas("W6_DT_ETA"	    ,"ETA"      		,23,"@!",1,020,0))//27				
oBrowse:SetColumns(MontaColunas("ESTOQUE"	    ,"Estoque"  		,25,"@!",1,020,0))//28		
oBrowse:SetColumns(MontaColunas("BOOK"	        ,"Book"     		,26,"@!",1,020,0))//29		
oBrowse:SetColumns(MontaColunas("DIASDESEMB"	,"Dias Desembaraço"	,28,"@!",1,020,0))//30				
oBrowse:SetColumns(MontaColunas("TRANSTOT"      ,"Transito Total"	,29,"@!",1,020,0))//31	
oBrowse:SetColumns(MontaColunas("VTOTAL"         ,"Valor Total"	    ,32,"@!",2,030,0))//32
oBrowse:SetColumns(MontaColunas("CUSTOEST"      ,"Custo Estimado"	,33,"@E 9,999,999.9999",2,020,0))//33
oBrowse:SetColumns(MontaColunas("CUSTOEFT"      ,"Custo Efetivo"	,34,"@E 9,999,999.9999",2,020,0))//34		
oBrowse:SetColumns(MontaColunas("CUSTOFIN"      ,"Custo Real"	    ,34,"@E 9,999,999.9999",2,020,0))//35		
oBrowse:SetColumns(MontaColunas("VLRPAGO"       ,"Valor Pago R$"	,34,"@E 9,999,999.99",2,020,0))//36		
oBrowse:SetColumns(MontaColunas("VLRDI"         ,"Valor DI"	        ,34,"@E 9,999,999.99",2,020,0))//37		
oBrowse:SetColumns(MontaColunas("VARCAMB"       ,"Var. Cambial"	    ,34,"@E 9,999,999.99",2,020,0))//38		
oBrowse:SetColumns(MontaColunas("VARUNIT"       ,"Var  Unitaria"	,34,"@E 9,999,999.9999",2,020,0))//39		
oBrowse:SetColumns(MontaColunas("VARIACAO"      ,"Variação"	        ,35,"@E 9,999,999.9999",2,020,0))//40		
oBrowse:SetColumns(MontaColunas("W6_DTRECDO"    ,"Recb. Docto"		,36,"@!",1,020,0))//41
oBrowse:Activate()

If !Empty(cArqTrb)
    Ferase(cArqTrb+GetDBExtension())
    Ferase(cArqTrb+OrdBagExt())
    cArqTrb := ""
    TRBREL->(DbCloseArea())
    delTabTmp('TRBREL')
    dbClearAll()
Endif
Return 


//------------------------------------------------------------------------------------//
//Rotina para montagem de colunas
//------------------------------------------------------------------------------------//
Static Function MontaColunas(cCampo,cTitulo,nArrData,cPicture,nAlign,nSize,nDecimal)
	Local aColumn
	Local bData 	:= {||}
	Default nAlign 	:= 1 //Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
	
	If nArrData > 0
		bData := &("{||" + cCampo +"}") //&("{||oBrowse:DataArray[oBrowse:At(),"+STR(nArrData)+"]}")
	EndIf

	aColumn := {cTitulo,bData,,cPicture,nAlign,nSize,nDecimal,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}}

	Return {aColumn}

//------------------------------------------------------------------------------------//
//Rotina MENUDEF
//------------------------------------------------------------------------------------//
Static Function MenuDef()
	//Local aArea		:= GetArea()
	Local aRotina 	:= {}
	Local aRotina1  := {}
	
	AADD(aRotina1, {"Planilha"           , "U_EXPIMP()"		, 0, 6, 0, Nil })
	AADD(aRotina,  {"Pesquisar"			 , "PesqBrw"		, 0, 1, 0, .T. })
	AADD(aRotina,  {"Exportar" 			 , aRotina1         , 0, 4, 0, Nil })
	
Return( aRotina )



/*/{Protheus.doc} EXPIMP
    Exporta para planilha excel
    @type  Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function EXPIMP()
Local oFWMsExcel
Local cArquivo    := GetTempPath() + 'Resumo ' + StrTran(Time(),":","") + '.xml'

oFWMsExcel := FWMSExcel():New()
				
oFWMsExcel:AddworkSheet("RESUMO")

//Criando a Tabela
oFWMsExcel:AddTable("RESUMO","ITENS")
oFWMsExcel:AddColumn("RESUMO","ITENS","Nro PO",1)               //1
oFWMsExcel:AddColumn("RESUMO","ITENS","Documento",1)            //2
oFWMsExcel:AddColumn("RESUMO","ITENS","Cod Fornecedor",1)       //3
oFWMsExcel:AddColumn("RESUMO","ITENS","Nome Fornecedor",1)      //4
oFWMsExcel:AddColumn("RESUMO","ITENS","Pais",1)                 //5
oFWMsExcel:AddColumn("RESUMO","ITENS","Porto Origem",1)         //6
oFWMsExcel:AddColumn("RESUMO","ITENS","HBL\BL",1)               //7
oFWMsExcel:AddColumn("RESUMO","ITENS","Agente",1)               //8
oFWMsExcel:AddColumn("RESUMO","ITENS","Nome Agente",1)          //9
oFWMsExcel:AddColumn("RESUMO","ITENS","Nome Desp",1)            //10
oFWMsExcel:AddColumn("RESUMO","ITENS","Valor Frete"		,1)     //11
oFWMsExcel:AddColumn("RESUMO","ITENS","Free Time",1)            //12
oFWMsExcel:AddColumn("RESUMO","ITENS","Transit Time",1)         //13
oFWMsExcel:AddColumn("RESUMO","ITENS","Cod Produto"	,1)         //14
oFWMsExcel:AddColumn("RESUMO","ITENS","Nome Produto",1)         //15
oFWMsExcel:AddColumn("RESUMO","ITENS","Volume",2)               //16
oFWMsExcel:AddColumn("RESUMO","ITENS","Qtd Container"	,1)     //17
oFWMsExcel:AddColumn("RESUMO","ITENS","Tipo Container",1)       //18
oFWMsExcel:AddColumn("RESUMO","ITENS","Porto Dest",1)           //19
oFWMsExcel:AddColumn("RESUMO","ITENS","Terminal",1)             //20
oFWMsExcel:AddColumn("RESUMO","ITENS","Incoterm"    ,1)         //21
oFWMsExcel:AddColumn("RESUMO","ITENS","Valor Unitario",2)       //22
oFWMsExcel:AddColumn("RESUMO","ITENS","Valor Processo U$",2)    //23
oFWMsExcel:AddColumn("RESUMO","ITENS","Emissao PO",1)           //24
oFWMsExcel:AddColumn("RESUMO","ITENS","Anuente" ,1)             //25
oFWMsExcel:AddColumn("RESUMO","ITENS","ETD"     ,1)             //26
oFWMsExcel:AddColumn("RESUMO","ITENS","ETA"    ,1)              //27
oFWMsExcel:AddColumn("RESUMO","ITENS","Estoque"  ,1)            //28
oFWMsExcel:AddColumn("RESUMO","ITENS","Book"  ,1)               //29
oFWMsExcel:AddColumn("RESUMO","ITENS","Dias Desembaraço"	,1) //30
oFWMsExcel:AddColumn("RESUMO","ITENS","Transito Total",1)       //31
oFWMsExcel:AddColumn("RESUMO","ITENS","Valor Total",2)          //32
oFWMsExcel:AddColumn("RESUMO","ITENS","Custo Estimado",2)       //33
oFWMsExcel:AddColumn("RESUMO","ITENS","Custo Efetivo"	,2)     //34
oFWMsExcel:AddColumn("RESUMO","ITENS","Custo Real"	,2)         //35
oFWMsExcel:AddColumn("RESUMO","ITENS","Valor Pago R$"	,2)     //36
oFWMsExcel:AddColumn("RESUMO","ITENS","Valor DI R$"	,2)         //37
oFWMsExcel:AddColumn("RESUMO","ITENS","Var. Cambial"	,2)     //38
oFWMsExcel:AddColumn("RESUMO","ITENS","Var. Unitaria"	,2)     //39
oFWMsExcel:AddColumn("RESUMO","ITENS","Variação"	,2)         //40
oFWMsExcel:AddColumn("RESUMO","ITENS","Recb. Docto",1)          //41

TRBREL->(DbGoTop()) 		
While TRBREL->(!Eof())
    oFWMsExcel:AddRow("RESUMO","ITENS",{;
    TRBREL->W2_PO_NUM       ,;  //1
    TRBREL->W2_NR_PRO       ,;//2
    TRBREL->W2_FORN         ,;//3
    TRBREL->W2_FORNDES      ,;//4
    TRBREL->YA_DESCR        ,;//5
    TRBREL->PORTOORIG       ,;//6
    TRBREL->W6_HOUSE        ,;//7
    TRBREL->W2_AGENTE       ,;//8
    TRBREL->Y4_NOME         ,;//9
    TRBREL->Y5_NOME         ,;//10
    TRBREL->W9_FRETEIN      ,;//11
    TRBREL->FREETIM         ,;//12
    TRBREL->TRANSITTIM      ,;//13
    TRBREL->W8_COD_I        ,;//14
    TRBREL->DESCRICAO       ,;//15
    TRBREL->W7_PESO         ,;//16
    TRBREL->QTCONT          ,;//17
    TRBREL->TIPO            ,;//18
    TRBREL->PORTODEST       ,;//19
    TRBREL->TERMINAL        ,;//20
    TRBREL->W2_INCOTER      ,;//21
    TRBREL->VUNIT           ,;//22
    TRBREL->W7_PRECO_R      ,;//23
    TRBREL->W2_PO_DT        ,;//24
    TRBREL->B1_ANUENTE      ,;//25
    TRBREL->W6_DT_ETD       ,;//26
    TRBREL->W6_DT_ETA       ,;//27
    TRBREL->ESTOQUE         ,;//28
    TRBREL->BOOK            ,;//29
    TRBREL->DIASDESEMB      ,;//30
    TRBREL->TRANSTOT        ,;//31
    TRBREL->VTOTAL          ,;//32
    TRBREL->CUSTOEST        ,;//33
    TRBREL->CUSTOEFT        ,;//34
    TRBREL->CUSTOFIN        ,;//35
    TRBREL->VLRPAGO         ,;//36
    TRBREL->VLRDI           ,;//37
    TRBREL->VARCAMB         ,;//38
    TRBREL->VARUNIT         ,;//39
    TRBREL->VARIACAO        ,;//40
    TRBREL->W6_DTRECDO      ; //41
    })
    TRBREL->(dbSkip())
EndDo

//Ativando o arquivo e gerando o xml
oFWMsExcel:Activate()
oFWMsExcel:GetXMLFile(cArquivo)
                
//Abrindo o excel e abrindo o arquivo xml
oExcel := MsExcel():New()             //Abre uma nova conexão com Excel
oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
oExcel:SetVisible(.T.)                 //Visualiza a planilha
oExcel:Destroy()  	
 			        		
Return 



/*/{Protheus.doc} UPDZH
    (long_description)
    @type  Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function UpdZH()
Local cQuery := ''
Local lReclock := .T.

cQuery := "SELECT SWH.* , ZH_PO_NUM FROM " + RetSqlName("SWH") + " SWH "
cQuery += " LEFT JOIN " + RetSqlName("SZH") + " SZH ON ZH_PO_NUM = WH_PO_NUM AND ZH_NR_CONT = WH_NR_CONT AND ZH_DESPESA = WH_DESPESA "
cQuery += "  WHERE "
cQuery += "  SWH.WH_DTAPUR = (SELECT MAX(WH_DTAPUR) FROM SWH010 SWHB WHERE SWHB.WH_PO_NUM = SWH.WH_PO_NUM)"
cQuery += " GROUP BY SWH.WH_FILIAL, SWH.WH_PO_NUM, SWH.WH_NR_CONT, SWH.WH_DESPESA , SWH.WH_MOEDA , SWH.WH_PER_DES , SWH.WH_VALOR , SWH.WH_DESC , SWH.WH_VALOR_R , SWH.WH_DTAPUR ,SWH.D_E_L_E_T_ , SWH.R_E_C_N_O_ ,SWH.R_E_C_D_E_L_ ,ZH_PO_NUM"   

If Select('TMPSZH') > 0
    ('TMPSZH')->(DbCloseArea())
EndIf

TCQUERY cQuery New Alias "TMPSZH"

Dbselectarea("TMPSZH")
dbGoTop()
SZH->(DbSetOrder(1))
While TMPSZH->(!EOF())
    If SZH->(DbSeek(xFilial('SZH') + PADR(TMPSZH->WH_PO_NUM,TAMSX3('ZH_PO_NUM')[1]) + PADR(STR(TMPSZH->WH_NR_CONT,4,0),TAMSX3('ZH_NR_CONT')[1])  + PADR(TMPSZH->WH_DESPESA,TAMSX3('ZH_DESPESA')[1])  ))
        lReclock := .F.
    Else
        lReclock := .T.
    EndIf
    RecLock('SZH',lReclock)
    SZH->ZH_FILIAL := xFilial('SZH')
    SZH->ZH_PO_NUM := TMPSZH->WH_PO_NUM
    SZH->ZH_NR_CONT := TMPSZH->WH_NR_CONT
    SZH->ZH_DESPESA := TMPSZH->WH_DESPESA
    SZH->ZH_MOEDA   := TMPSZH->WH_MOEDA
    SZH->ZH_PER_DES := TMPSZH->WH_PER_DES
    SZH->ZH_VALOR   := TMPSZH->WH_VALOR
    SZH->ZH_DESC    := TMPSZH->WH_DESC
    SZH->ZH_VALOR_R := TMPSZH->WH_VALOR_R
    SZH->ZH_DTAPUR  := STOD(TMPSZH->WH_DTAPUR)
    MsUnlock()

    TMPSZH->(DbSkip())
EndDo

Return 

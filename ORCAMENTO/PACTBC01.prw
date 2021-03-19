#INCLUDE "TOTVS.CH"
#Include "HBUTTON.CH"
#include "rwmake.ch"

/*/{Protheus.doc} PACTBC01
    Tela de demonstração de Registros não Contabilizados: COM, FAT, FIN
    @type  Function
    @author Rossana Barbosa
    @since 03/03/2021
    @version versio
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
   /*/

User Function PACTBC01()
Private nMilissegundos    := supergetmv('ES_TMPTELA',.T.,60000)
//Private cUsers            := SupergetMV('ES_USRCSHOM',.T.,'totvs.rnovaes')
Private aHeader         := {}
Private aHeaderEx       := {}
Private aColsEx         := {}
Private aFields         := {"MODULO","F2_FILIAL","F2_EMISSAO","F2_DOC","F2_SERIE","F2_CLIENTE","F2_LOJA","A2_NOME","E2_TIPO","E2_VALOR","E2_HIST","E2_ORIGEM"}
Private aTituloex       := {"","Filial","Data","Documento","Pref_Serie","Cod_ForCli","Loja_ForCli","Nome_ForCli","Tipo","Valor","Historico","Origem"}
Private aAlterFields    := {}
Private aHeaderAux      := {}
Private aRegD1          := {}
Private oDlg
Private oMSNewGe1
Private oGroup1
Private oHButton1
Private oHButton2
private lChkSel    := .F.
private lOkSalva   := .F.
private lChkFiltro := .F.
Private nI         := 0
Private  cAliasTrb := ''
Private lAtualiza  := .T.
Private aParam      := {}
Private aRet        := {}
static oChk, oChkFiltro
Private oTimer

lPACTBC01 := .T.

//aAdd(aParam, {1, "Data Inicio" , dDataBase ,  ,, ,, 60, .F.} )
//aAdd(aParam, {1, "Data Fim"    , dDataBase ,  ,, ,, 60, .F.} )

aAdd(aParam, { 01, "Data De"     , STOD("//")     ,""   ,""   ,""    ,""  , 60 , .F. } )   //MV_PAR01
aAdd(aParam, { 01, "Data Até"    , STOD("//")     ,""   ,""   ,""    ,""  , 60 , .F. } )   //MV_PAR02
aAdd(aParam, { 01, "Filial De"   ,"01010001"      ,""   ,""   ,"SM0" ,""  , 60 , .F. } )   //MV_PAR03
aAdd(aParam, { 01, "Filial Até"  ,"ZZZZZZZZ"      ,""   ,""   ,"SM0" ,""  , 60 , .F. } )   //MV_PAR04

DbSelectArea("SX3")
SX3->(DbSetOrder(2))
For nX := 1 to len(aFields)
    If aFields[nX] == "USADO"
       Aadd(aHeaderEx,{aTituloex[nX],;
      'CHECKBOL',;
       '@BMP',;
       2,;
       0,;
       ,;
       ,;
       'C',;
       ,;
       'V',;
       ,;
       ,;
       'seleciona',;
       'V',;
       'S',;
       })
    Endif

    If SX3->(DbSeek(aFields[nX]))
       Aadd(aHeaderEx,{aTituloex[nX],;
       SX3->X3_CAMPO,;
       SX3->X3_PICTURE,;
       IIF(aFields[nX] == 'B1_DESC' , 30 , SX3->X3_TAMANHO),;
       SX3->X3_DECIMAL,;
       SX3->X3_VALID,;
       SX3->X3_USADO,;
       SX3->X3_TIPO,;
       SX3->X3_F3,;
       SX3->X3_CONTEXT,;
       SX3->X3_CBOX,;
       SX3->X3_RELACAO})
    Endif

Next nX

If ParamBox(aParam,'Parâmetros',aRet)
//If at(UPPER(Alltrim(UsrRetName( retcodusr() ))),UPPER(cUsers)) > 0 .Or. UPPER(Alltrim(UsrRetName( retcodusr() ))) == 'TOTVS.RNOVAES'
    UpdTab()
    DEFINE MSDIALOG oDlg TITLE "Tela de Registros a Contabilizar - PARTAGE" FROM C(000), C(000)  TO C(500), C(1030) COLORS 0, 16777215 PIXEL STYLE DS_MODALFRAME

        @ C(200), C(002) GROUP oGroup1 TO C(225), C(496) OF oDlg COLOR 0, 16777215 PIXEL
//        @ C(210), C(350) checkbox oChk var lChkSel PROMPT "Selecionar todos" size 60,07 on CLICK seleciona(lChkSel)
//        @ C(210), C(410) HBUTTON oHButton1 PROMPT "Confirmar" SIZE 025, 007 OF oDlg ACTION Confirma()
//        @ C(210), C(440) HBUTTON oHButton2 PROMPT "Descartar" SIZE 025, 007 OF oDlg ACTION Descarta()
        @ C(210), C(470) HBUTTON oHButton2 PROMPT "Sair" SIZE 025, 007 OF oDlg ACTION Sair()

            fMSNewGe1()
            oTimer := TTimer():New(nMilissegundos, {|| UpdTimer() }, oDlg )
            oTimer:Activate()
    ACTIVATE MSDIALOG oDlg
EndIf
//else
//    Alert('Usuario não autorizado a acessar a rotina!')
//EndIf

Return

/*/{Protheus.doc} UpdTab
    Atualiza o aColsEx
    @type  Static Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/

Static Function UpdTab()
Local cQuery        := ''

/*
cQuery := "SELECT SD1.R_E_C_N_O_ AS RECD1 ,SBZ.R_E_C_N_O_ AS RECBZ,D1_FILIAL , D1_DTDIGIT, B1_COD , B1_DESC ,D1_DOC, BZ_CUSTD , D1_VUNIT , D1_VALICM , D1_QUANT, B2_CM1 , A2_NOME  , D1_LOCAL , BZ_MCUSTD, D1_DTDIGIT , D1_CUSTO"
cQuery += "  FROM " + RetSQLTab('SD1')
cQuery += "  INNER JOIN  " + RetSQLTab('SB1') + " ON B1_COD = D1_COD AND SB1.D_E_L_E_T_ = ' ' "
cQuery += "  INNER JOIN  " + RetSQLTab('SBZ') + " ON BZ_FILIAL = D1_FILIAL AND BZ_COD = D1_COD AND SBZ.D_E_L_E_T_ = ' ' "
cQuery += "  INNER JOIN  " + RetSQLTab('SA2') + " ON D1_FORNECE = A2_COD AND D1_LOJA = A2_LOJA AND SA2.D_E_L_E_T_ = ' ' "
cQuery += "  INNER JOIN  " + RetSQLTab('SB2') + " ON B2_FILIAL = D1_FILIAL AND B2_COD = D1_COD AND B2_LOCAL = D1_LOCAL AND SB2.D_E_L_E_T_ = ' ' "
cQuery += "  WHERE  "
cQuery += "  D1_XHOMOL <> 'S' AND D1_XDESCAR <> 'S' "
cQuery += "  AND SD1.D_E_L_E_T_ = ' '"
cQuery += "  ORDER BY SD1.D1_DTDIGIT DESC "
*/

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------
//-- CONSULTA DE REGISTROS NÃO CONTABILIZADOS (COMPRAS, FATURAMENTO, FINANCEIRO) ----
//-----------------------------------------------------------------------------------

cQuery := "	SELECT * "

cQuery += "	FROM ( "

cQuery += "		SELECT 'COMPRAS' MODULO, F1_FILIAL 'FILIAL', F1_DTDIGIT 'DATA', F1_DOC 'DOCUMENTO', UPPER(F1_SERIE) 'PREF_SERIE', F1_FORNECE 'COD_FORCLI', F1_LOJA 'LOJA_FORCLI', "
cQuery += "				UPPER(A2_NOME) 'NOME_FORCLI', F1_TIPO 'TIPO', F1_VALBRUT 'VALOR', UPPER(F1_MENNOTA) 'HISTORICO', 'MATA103' ORIGEM "
cQuery += "		FROM " + RetSqlName("SF1") + " F1  " 
cQuery += "		INNER JOIN " + RetSqlName("SA2") + " A2 ON A2.D_E_L_E_T_ = '' AND A2_FILIAL = '' AND A2_COD = F1_FORNECE AND A2_LOJA = F1_LOJA "
cQuery += "		WHERE F1.D_E_L_E_T_ = '' AND F1_DTLANC = '' AND F1_TIPO NOT IN ('D','B') AND F1_STATUS != '' "

cQuery += "	UNION ALL "

cQuery += "		SELECT 'COMPRAS' MODULO, F1_FILIAL 'FILIAL', F1_DTDIGIT 'DATA', F1_DOC 'DOCUMENTO', UPPER(F1_SERIE) 'PREF_SERIE', F1_FORNECE 'COD_FORCLI', F1_LOJA 'LOJA_FORCLI', "
cQuery += "				UPPER(A1_NOME) 'NOME_FORCLI', F1_TIPO 'TIPO', F1_VALBRUT 'VALOR', UPPER(F1_MENNOTA) 'HISTORICO', 'MATA103' ORIGEM "
cQuery += "		FROM " + RetSqlName("SF1") + " F1  "
cQuery += "		INNER JOIN " + RetSqlName("SA1") + " A1 ON A1.D_E_L_E_T_ = '' AND A1_FILIAL = '' AND A1_COD = F1_FORNECE AND A1_LOJA = F1_LOJA "
cQuery += "		WHERE F1.D_E_L_E_T_ = '' AND F1_DTLANC = '' AND F1_TIPO IN ('D','B') AND F1_STATUS != '' "

cQuery += "	UNION ALL "

cQuery += "		SELECT 'FATURAMENTO' MODULO, F2_FILIAL 'FILIAL', F2_EMISSAO 'DATA', F2_DOC 'DOCUMENTO', UPPER(F2_SERIE) 'PREF_SERIE', F2_CLIENTE 'COD_FORCLI', F2_LOJA 'LOJA_FORCLI', "
cQuery += "				UPPER(A1_NOME) 'NOME_FORCLI', F2_TIPO 'TIPO', F2_VALBRUT 'VALOR', UPPER(F2_MENNOTA) 'HISTORICO', 'MATA460' ORIGEM "
cQuery += "		FROM " + RetSqlName("SF2") + " F2  "
cQuery += "		INNER JOIN " + RetSqlName("SA1") + " A1 ON A1.D_E_L_E_T_ = '' AND A1_FILIAL = '' AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA "
cQuery += "		WHERE F2.D_E_L_E_T_ = '' AND F2_DTLANC = '' AND F2_TIPO NOT IN ('D','B') "

cQuery += "	UNION ALL "

cQuery += "		SELECT 'FATURAMENTO' MODULO, F2_FILIAL 'FILIAL', F2_EMISSAO 'DATA', F2_DOC 'DOCUMENTO', UPPER(F2_SERIE) 'PREF_SERIE', F2_CLIENTE 'COD_FORCLI', F2_LOJA 'LOJA_FORCLI', "
cQuery += "				UPPER(A2_NOME) 'NOME_FORCLI', F2_TIPO 'TIPO', F2_VALBRUT 'VALOR', UPPER(F2_MENNOTA) 'HISTORICO', 'MATA460' ORIGEM "
cQuery += "		FROM " + RetSqlName("SF2") + " F2  "
cQuery += "		INNER JOIN " + RetSqlName("SA2") + " A2 ON A2.D_E_L_E_T_ = '' AND A2_FILIAL = '' AND A2_COD = F2_CLIENTE AND A2_LOJA = F2_LOJA "
cQuery += "		WHERE F2.D_E_L_E_T_ = '' AND F2_DTLANC = '' AND F2_TIPO IN ('D','B') "
	
cQuery += "	UNION ALL "
	
cQuery += "		SELECT 'FIN_CR' MODULO, E1_FILIAL 'FILIAL', E1_EMISSAO 'DATA', E1_NUM 'DOCUMENTO', UPPER(E1_PREFIXO) 'PREF_SERIE', E1_CLIENTE 'COD_FORCLI', E1_LOJA 'LOJA_FORCLI', "
cQuery += "				UPPER(A1_NOME) 'NOME_FORCLI', E1_TIPO 'TIPO', E1_VALOR 'VALOR', UPPER(E1_HIST) 'HISTORICO', E1_ORIGEM 'ORIGEM' "
cQuery += "		FROM " + RetSqlName("SE1") + " E1  "
cQuery += "		INNER JOIN " + RetSqlName("SA1") + " A1 ON A1.D_E_L_E_T_ = '' AND A1_FILIAL = '' AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA "
cQuery += "		WHERE E1.D_E_L_E_T_ = '' AND E1_LA = '' AND E1_TIPO NOT IN ('PR','RA') AND E1_ORIGEM NOT IN ('MATA100 ', 'MATA460 ') "

cQuery += "	UNION ALL ""

cQuery += "		SELECT 'FIN_CP' MODULO, E2_FILIAL 'FILIAL', E2_EMISSAO 'DATA', E2_NUM 'DOCUMENTO', UPPER(E2_PREFIXO) 'PREF_SERIE', E2_FORNECE 'COD_FORCLI', E2_LOJA 'LOJA_FORCLI', "
cQuery += "				UPPER(A2_NOME) 'NOME_FORCLI', E2_TIPO 'TIPO', E2_VALOR 'VALOR', UPPER(E2_HIST) 'HISTORICO', E2_ORIGEM 'ORIGEM' "
cQuery += "		FROM " + RetSqlName("SE2") + " E2  "
cQuery += "		INNER JOIN " + RetSqlName("SA2") + " A2 ON A2.D_E_L_E_T_ = '' AND A2_FILIAL = '' AND A2_COD = E2_FORNECE AND A2_LOJA = E2_LOJA "
cQuery += "		WHERE E2.D_E_L_E_T_ = '' AND E2_LA = '' AND E2_TIPO NOT IN ('PR','PA') AND E2_ORIGEM NOT IN ('GPEM670 ','MATA100 ', 'MATA103 ', 'MATA460 ') "
cQuery += "		AND (E2_ORIGEM = 'FINA050' AND E2_TIPO NOT IN ('131','132','ADI','CSL','COF','FER','FGT','FOL','FT','ISS','INS','IRF','NDI''PIS','RES','TX')) "

cQuery += "	UNION ALL "

cQuery += "		SELECT 'FIN_MOV_CR' MODULO, E5_FILIAL 'FILIAL', E5_DTDISPO 'DATA', E5_NUMERO 'DOCUMENTO', UPPER(E5_PREFIXO) 'PREF_SERIE', E5_CLIFOR 'COD_FORCLI', E5_LOJA 'LOJA_FORCLI', "
cQuery += "				UPPER(A1_NOME) 'NOME_FORCLI', E5_TIPO 'TIPO', E5_VALOR 'VALOR', UPPER(E5_HISTOR) 'HISTORICO', E5_ORIGEM 'ORIGEM' "
cQuery += "		FROM " + RetSqlName("SE5") + " E5  "
cQuery += "		INNER JOIN " + RetSqlName("SA1") + " A1 ON A1.D_E_L_E_T_ = '' AND A1_FILIAL = '' AND A1_COD = E5_CLIENTE AND A1_LOJA = E5_LOJA AND E5_CLIENTE != '' "
cQuery += "		WHERE E5.D_E_L_E_T_ = '' AND E5_LA = '' AND E5_SITUACA = '' "

cQuery += "	UNION ALL "

cQuery += "		SELECT 'FIN_MOV_CP' MODULO, E5_FILIAL 'FILIAL', E5_DTDISPO 'DATA', E5_NUMERO 'DOCUMENTO', UPPER(E5_PREFIXO) 'PREF_SERIE', E5_CLIFOR 'COD_FORCLI', E5_LOJA 'LOJA_FORCLI', "
cQuery += "				UPPER(A2_NOME) 'NOME_FORCLI', E5_TIPO 'TIPO', E5_VALOR 'VALOR', UPPER(E5_HISTOR) 'HISTORICO', E5_ORIGEM 'ORIGEM' "
cQuery += "		FROM " + RetSqlName("SE5") + " E5  "
cQuery += "		INNER JOIN " + RetSqlName("SA2") + " A2 ON A2.D_E_L_E_T_ = '' AND A2_FILIAL = '' AND A2_COD = E5_FORNECE AND A2_LOJA = E5_LOJA AND E5_FORNECE != '' "
cQuery += "		WHERE E5.D_E_L_E_T_ = '' AND E5_LA = '' AND E5_SITUACA = '' "

cQuery += "	UNION ALL "

cQuery += "		SELECT 'FIN_MOV_BANC' MODULO, E5_FILIAL 'FILIAL', E5_DTDISPO 'DATA', E5_NUMERO 'DOCUMENTO', UPPER(E5_PREFIXO) 'PREF_SERIE', E5_CLIFOR 'COD_FORCLI', E5_LOJA 'LOJA_FORCLI', "
cQuery += "				UPPER(E5_BENEF) 'NOME_FORCLI', E5_TIPO 'TIPO', E5_VALOR 'VALOR', UPPER(E5_HISTOR) 'HISTORICO', E5_ORIGEM 'ORIGEM' "
cQuery += "		FROM " + RetSqlName("SE5") + " E5  "
cQuery += "		WHERE E5.D_E_L_E_T_ = '' AND E5_LA = '' AND E5_SITUACA = '' "

cQuery += "	UNION ALL "

cQuery += "		SELECT 'FIN_CAIXINHA' MODULO, EU_FILIAL 'FILIAL', EU_DTDIGIT 'DATA', EU_NRCOMP 'DOCUMENTO', '' 'PREF_SERIE', '' 'COD_FORCLI', '' 'LOJA_FORCLI', "
cQuery += "				UPPER(EU_BENEF) 'NOME_FORCLI', EU_TIPO 'TIPO', EU_VALOR 'VALOR', UPPER(EU_HISTOR) 'HISTORICO', 'FINA560' ORIGEM "
cQuery += "		FROM " + RetSqlName("SEU") + " EU  " 
cQuery += "		WHERE EU.D_E_L_E_T_ = '' AND EU_LA = '' "
	
cQuery += "	) AS TEMP "

cQuery += "	WHERE DATA BETWEEN '" +DTOS(MV_PAR01)+ "' AND '" +DTOS(MV_PAR02)+ "' "
cQuery += "	AND FILIAL BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "

cQuery += "	ORDER BY FILIAL, MODULO, DATA, DOCUMENTO, PREF_SERIE, COD_FORCLI, LOJA_FORCLI, TIPO "

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

MemoWrite('C:\TEMP\query_pactb01.txt', cQuery)

If Select(cAliasTrb) > 0 .And. !empty(cAliasTrb)
    (cAliasTrb)->(DbCloseArea())
EndIf
cQuery    := ChangeQuery(cQuery)
cAliasTrb := GetNextAlias()

DbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), cAliasTrb, .F., .T.)
aColsEx := {}
aRegD1 := {}
While (cAliasTrb)->(!EOF())
    aAdd(aColsEx,{})
    Aadd(aColsEx[Len(aColsEx)],(cAliasTrb)->MODULO)
    Aadd(aColsEx[Len(aColsEx)],(cAliasTrb)->FILIAL)    
    Aadd(aColsEx[Len(aColsEx)],Alltrim(FwFilialName(cEmpAnt,(cAliasTrb)->FILIAL,1)))
    Aadd(aColsEx[Len(aColsEx)],DTOC(STOD((cAliasTrb)->DATA)))
    Aadd(aColsEx[Len(aColsEx)],(cAliasTrb)->DOCUMENTO)
    Aadd(aColsEx[Len(aColsEx)],(cAliasTrb)->PREF_SERIE)    
    Aadd(aColsEx[Len(aColsEx)],(cAliasTrb)->COD_FORCLI)
    Aadd(aColsEx[Len(aColsEx)],(cAliasTrb)->LOJA_FORCLI)
    Aadd(aColsEx[Len(aColsEx)],(cAliasTrb)->NOME_FORCLI)
    Aadd(aColsEx[Len(aColsEx)],(cAliasTrb)->TIPO)
    Aadd(aColsEx[Len(aColsEx)],(cAliasTrb)->VALOR)
    Aadd(aColsEx[Len(aColsEx)],(cAliasTrb)->HISTORICO)
    Aadd(aColsEx[Len(aColsEx)],(cAliasTrb)->ORIGEM) 
	Aadd(aColsEx[Len(aColsEx)],.F.)	

//    Aadd(aRegD1, {(cAliasTrb)->RECD1,(cAliasTrb)->RECBZ})

    (cAliasTrb)->(DbSkip())
EndDo

If IsInCallStack('UpdTimer')
	oMSNewGe1:SetArray(aColsEx)
	oMSNewGe1:Refresh(.T.)
	oMSNewGe1:ForceRefresh()
	oMSNewGe1:GoTop ()
    oTimer:nInterval := nMilissegundos
EndIf


Return


/*/{Protheus.doc} DlgHomolog
    (long_description)
    @type  Static Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/

Static Function DlgHomolog()

Return

//=============================================================================================================================
Static Function fMSNewGe1()
//=============================================================================================================================
 oMSNewGe1 := MsNewGetDados():New( C(004), C(002), C(190), C(505), GD_UPDATE, "AllwaysTrue", "AllwaysTrue", , aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)
 //oMSNewGe1:oBrowse:bLDblClick := {|| oMSNewGe1:EditCell(), oMSNewGe1:aCols[oMSNewGe1:nAt,1] := iif(oMSNewGe1:aCols[oMSNewGe1:nAt,1] == 'LBOK','LBNO','LBOK')}
 oMSNewGe1:oBrowse:bLDblClick := {|| oMSNewGe1:aCols[oMSNewGe1:nAt,1] := iif(oMSNewGe1:aCols[oMSNewGe1:nAt,1] == 'LBOK','LBNO','LBOK')}
Return


/*/{Protheus.doc} Sair
    (long_description)
    @type  Static Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/

Static Function Sair()
	oDlg:End()
return

Static Function ChkUso()
Local lRet := .T.
Local n := 0

For n := 1 to Len(oMSNewGe1:aCOLS)
    If oMSNewGe1:aCOLS[n,1] == 'LBOK'
        lRet := .F.
        Exit
    EndIf
Next

Return lRet

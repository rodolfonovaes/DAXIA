#INCLUDE "TOTVS.CH"
#Include "HBUTTON.CH"
#include "rwmake.ch"
User Function IniSens()
Local cRet := M->B5_XALE   

//If cRet == 'N'
    M->B5_XSENS01 := 'N'
    M->B5_XSENS02 := 'N'
    M->B5_XSENS03 := 'N'
    M->B5_XSENS04 := 'N'
    M->B5_XSENS05 := 'N'
    M->B5_XSENS06 := 'N'
    M->B5_XSENS07 := 'N'
    M->B5_XSENS08 := 'N'
    M->B5_XSENS09 := 'N'
    M->B5_XSENS10 := 'N'
    M->B5_XSENS11 := 'N'
    M->B5_XSENS12 := 'N'
    M->B5_XSENS13 := 'N'
    M->B5_XSENS14 := 'N'
    M->B5_XSENS15 := 'N'
    M->B5_XSENS16 := 'N'
    M->B5_XSENS17 := 'N'
    M->B5_XSENS18 := 'N'
    M->B5_XSENS19 := 'N'
    M->B5_XSENS20 := 'N'
    M->B5_XSENS21 := 'N'
    M->B5_XSENS22 := 'N'
    M->B5_XSENS23 := 'N'
    M->B5_XSENS24 := 'N'
    M->B5_XSENS25 := 'N'
  /*  M->B5_XSENS26 := 'N'
    M->B5_XSENS27 := 'N'
    M->B5_XSENS28 := 'N'
    M->B5_XSENS29 := 'N'
    M->B5_XSENS30 := 'N'
    M->B5_XSENS31 := 'N'
    M->B5_XSENS32 := 'N'
    M->B5_XSENS33 := 'N'
    M->B5_XSENS34 := 'N'
    M->B5_XSENS35 := 'N'
    M->B5_XSENS36 := 'N'
    M->B5_XSENS37 := 'N'
    M->B5_XSENS38 := 'N'
    M->B5_XSENS39 := 'N'
    M->B5_XSENS40 := 'N'*/
//EndIf
Return cRet


User Function CPerigo()

Private cUsers            := SupergetMV('ES_USRCSHOM',.T.,'totvs.rnovaes')
Private aHeader         := {}
Private aHeaderEx       := {}
Private aColsEx         := {}
Private aFields         := {"USADO","ZZF_ID","ZZF_DESCR"}
Private aTituloex       := {"","ID","Descrição"}
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
Private nI          := 0
Private  cAliasTrb     := ''
Private lAtualiza   := .T.
static oChk, oChkFiltro
Private oTimer



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

UpdTab()
DEFINE MSDIALOG oDlg TITLE "Classificação de Perigo - DAXIA" FROM C(000), C(000)  TO C(500), C(1030) COLORS 0, 16777215 PIXEL STYLE DS_MODALFRAME

@ C(200), C(002) GROUP oGroup1 TO C(225), C(496) OF oDlg COLOR 0, 16777215 PIXEL
@ C(210), C(350) checkbox oChk var lChkSel PROMPT "Selecionar todos" size 60,07 on CLICK seleciona(lChkSel)
@ C(210), C(410) HBUTTON oHButton1 PROMPT "Confirmar" SIZE 025, 007 OF oDlg ACTION Confirma()
@ C(210), C(470) HBUTTON oHButton2 PROMPT "Sair" SIZE 025, 007 OF oDlg ACTION Sair()

fMSNewGe1()
ACTIVATE MSDIALOG oDlg



Return

Static Function UpdTab()
Local cQuery        := ''


cQuery := "SELECT *"
cQuery += "  FROM " + RetSQLTab('ZZF')
cQuery += "  LEFT JOIN " + RetSQLTab('ZZG') + "  ON ZZG_FILIAL = ZZF_FILIAL AND ZZG_ID = ZZF_ID AND ZZG_COD = '" + SB1->B1_COD + "' AND ZZG.D_E_L_E_T_ = ' ' "
cQuery += "  WHERE  "
cQuery += "  ZZF.D_E_L_E_T_ = ' '"
cQuery += "  AND ZZF_FILIAL = '" + xFilial('ZZF')+ "'"
cQuery += "  ORDER BY ZZF_ID "

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
    Aadd(aColsEx[Len(aColsEx)],IIF(Empty((cAliasTrb)->ZZG_COD) ,'LBNO','LBOK'))
    Aadd(aColsEx[Len(aColsEx)],(cAliasTrb)->ZZF_ID)
    Aadd(aColsEx[Len(aColsEx)],(cAliasTrb)->ZZF_DESCR)
    Aadd(aColsEx[Len(aColsEx)],.F.)

    (cAliasTrb)->(DbSkip())
EndDo

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


/*/{Protheus.doc} seleciona
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
static function seleciona(lChkSel)
Local i := 0
//percorre todas as linhas do oGetDados
for i := 1 to len(oMSNewGe1:aCols)
	//verifica o valor da variável lChkSel
	//se verdadeiro, define a primeira coluna do aCols como LBOK ou marcado (checked)
	if lChkSel
		oMSNewGe1:aCOLS[i,1] := 'LBOK'
	//se falso, marca como LBNO ou desmarcado (unchecked)
	else
		oMSNewGe1:aCOLS[i,1] := 'LBNO'
	endif
next
//executa refresh no getDados e na tela
//esses métodos Refresh() são próprio da classe MsNewGetDados e do dialog
//totalmente diferentes do método estático definido no corpo deste fonte
oMSNewGe1:oBrowse:Refresh()
oDlg:Refresh()

return


/*/{Protheus.doc} Confirma
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
Static Function Confirma()
Local cId       := ''
Local cOpc      := ''
Local lReclock  := .T.

If MsgYesNo('Confirma a ação?')
    ZZG->(DbSetOrder(1))
    For nI := 1 to Len(oMSNewGe1:aCols)
        If oMSNewGe1:aCOLS[nI,1] == 'LBOK' 

            cId   := oMSNewGe1:aCOLS[nI,2]
            
            If ZZG->(DbSeek(xFilial('ZZG')+ SB1->B1_COD + cId))
              lReclock := .F.
            Else
              lReclock := .T.
            EndIf
            If RecLock('ZZG',lReclock)
                ZZG->ZZG_FILIAL := xFilial('ZZG')
                ZZG->ZZG_COD    := SB1->B1_COD
                ZZG->ZZG_ID     := cId
                MsUnlock()
            EndIf
        Else //Se nao ta marcado deleta
            cId   := oMSNewGe1:aCOLS[nI,2]
            If ZZG->(DbSeek(xFilial('ZZG')+ SB1->B1_COD + cId))
              If RecLock('ZZG',.F.)
                  DbDelete()
                  MsUnlock()
              EndIf               
            EndIf
        EndIf
    Next
    MsgInfo('Registros Atualizados!')
EndIf

Return



User Function AxcadZZF()
AXCADASTRO('ZZF','Clasf. Perigo')
Return

User Function AxcadZZ1()
AXCADASTRO('ZZ1','Descrição de embalagens')
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





User Function DxAlerge()
Local cContador   := '01'
Private aAux        := {}
Private cUsers            := SupergetMV('ES_USRCSHOM',.T.,'totvs.rnovaes')
Private aHeader         := {}
Private aHeaderExA      := {}
Private aColsEx         := {}
Private aFields         := {"ZZH_SENS01","X3_TITULO","ZZH_AOBS01","ZZH_AORI01"}
Private aTituloex       := {"Opção","Descrição","Observação","Origem"}
Private aAlterFld       := {"ZZH_SENS01","ZZH_AOBS01","ZZH_AORI01"}
Private aHeaderAux      := {}
Private aRegD1          := {}
Private oDlg
Private oMSNewGe2
Private oGroup1
Private oHButton1
Private oHButton2
private lChkSel    := .F.
private lOkSalva   := .F.
private lChkFiltro := .F.
Private nI          := 0
Private  cAliasTrb     := ''
Private lAtualiza   := .T.

static oChk, oChkFiltro




DbSelectArea("SX3")
SX3->(DbSetOrder(2))
For nX := 1 to len(aFields)

    If aFields[nX] == "X3_TITULO"
       Aadd(aHeaderExA,{aTituloex[nX],;
      'B1_DESC',;
       '',;
       20,;
       0,;
       ,;
       ,;
       'C',;
       ,;
       'R',;
       ,;
       ;
       })
    Endif        

    If SX3->(DbSeek(aFields[nX]))
       Aadd(aHeaderExA,{aTituloex[nX],;
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

aColsEx := {}

ZZH->(DbSetOrder(1))
//Monta aCols
SX3->(DbSetOrder(2))
While SX3->(DbSeek('ZZH_SENS' + cContador)) .And. Alltrim(SX3->X3_TITULO) <> 'x'
    
    aadd(aAux,cContador)

    If ZZH->(DbSeek(xFilial('ZZH') + SB1->B1_COD))
        aAdd(aColsEx,{})
        Aadd(aColsEx[Len(aColsEx)],ZZH->&('ZZH_SENS'+cContador))
        Aadd(aColsEx[Len(aColsEx)],SX3->X3_TITULO)
        Aadd(aColsEx[Len(aColsEx)],ZZH->&('ZZH_AOBS'+cContador))
        Aadd(aColsEx[Len(aColsEx)],ZZH->&('ZZH_AORI'+cContador))
        Aadd(aColsEx[Len(aColsEx)],.F.)        
    Else
        aAdd(aColsEx,{})
        Aadd(aColsEx[Len(aColsEx)],'N')
        Aadd(aColsEx[Len(aColsEx)],SX3->X3_TITULO)
        Aadd(aColsEx[Len(aColsEx)],SPACE(100))
        Aadd(aColsEx[Len(aColsEx)],SPACE(70))
        Aadd(aColsEx[Len(aColsEx)],.F.)        
    EndIf

    cContador := Soma1(cContador)
EndDo

DEFINE MSDIALOG oDlg TITLE "Alergenicos - DAXIA" FROM C(000), C(000)  TO C(500), C(1030) COLORS 0, 16777215 PIXEL STYLE DS_MODALFRAME

@ C(200), C(002) GROUP oGroup1 TO C(225), C(496) OF oDlg COLOR 0, 16777215 PIXEL
//@ C(210), C(350) checkbox oChk var lChkSel PROMPT "Selecionar todos" size 60,07 on CLICK seleciona(lChkSel)
@ C(210), C(410) HBUTTON oHButton1 PROMPT "Confirmar" SIZE 025, 007 OF oDlg ACTION UpdZZH()
@ C(210), C(470) HBUTTON oHButton2 PROMPT "Sair" SIZE 025, 007 OF oDlg ACTION Sair()

GetAlerg()
ACTIVATE MSDIALOG oDlg


Return


//=============================================================================================================================
Static Function GetAlerg()
//=============================================================================================================================
 oMSNewGe2 := MsNewGetDados():New( C(004), C(002), C(190), C(505), GD_UPDATE, "AllwaysTrue", "AllwaysTrue", , aAlterFld,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderExA, aColsEx)
Return

Static Function UpdZZH()
local n := 0
Local lReclock := .F.

ZZH->(DbSetOrder(1))
If ZZH->(DbSeek(xFilial('ZZH') + SB1->B1_COD))
    lReclock := .F.
Else
    lReclock := .T.
EndIf

RecLock('ZZH',lReclock)
ZZH->ZZH_FILIAL := xFilial('ZZH')
ZZH->ZZH_COD := SB1->B1_COD
For n := 1 to len(aColsEx)
    ZZH->&('ZZH_SENS'+aAux[n]) := oMSNewGe2:aCols[n,1]  
    ZZH->&('ZZH_AOBS'+aAux[n]) := oMSNewGe2:aCols[n,3] 
    ZZH->&('ZZH_AORI'+aAux[n]) := oMSNewGe2:aCols[n,4] 
Next
MsUnlock()

oDlg:End()
Return 

#INCLUDE "TOTVS.CH"
#Include "HBUTTON.CH"
#include "rwmake.ch"
/*/{Protheus.doc} DAXATU01
    Manutenção de custo homologado
    @type  Function
    @author user
    @since date
    @version versio
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
   /*/
User Function DAXATU01()
Private nMilissegundos    := supergetmv('ES_TMPTELA',.T.,60000)
Private cUsers            := SupergetMV('ES_USRCSHOM',.T.,'totvs.rnovaes')
Private aHeader         := {}
Private aHeaderEx       := {}
Private aColsEx         := {}
Private aFields         := {"USADO","B1_DESC","B1_COD","B1_DESC","D1_DOC","D1_DTDIGIT","BZ_CUSTD","D1_VUNIT","Z4_CMEDIO","Z4_CDIGIT","Z4_TIPO","B2_QATU","A2_NOME"}
Private aTituloex       := {"","Filial","Codigo","Descrição","Doc","Data Entrada","Custo Atual","Novo Custo","Custo Medio","Custo Digitado","Tipo","Saldo","Fornecedor"}
Private aAlterFields    := {"USADO","Z4_CDIGIT","Z4_TIPO"}
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

lDaxAtu01 := .T.

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

    If aFields[nX] == "Z4_CDIGIT"
       Aadd(aHeaderEx,{'Digitado',;
      'Z4_CDIGIT',;
       '@E 9,999,999,999,999.99',;
       16,;
       2,;
      /* U_VlZ4Dig()*/,;
       '.T.',;
       'N',;
       ,;
       'R',;
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

If at(UPPER(Alltrim(UsrRetName( retcodusr() ))),UPPER(cUsers)) > 0 .Or. UPPER(Alltrim(UsrRetName( retcodusr() ))) == 'TOTVS.RNOVAES'
    UpdTab()
    DEFINE MSDIALOG oDlg TITLE "Custo Homologado - DAXIA" FROM C(000), C(000)  TO C(500), C(1030) COLORS 0, 16777215 PIXEL STYLE DS_MODALFRAME

        @ C(200), C(002) GROUP oGroup1 TO C(225), C(496) OF oDlg COLOR 0, 16777215 PIXEL
        @ C(210), C(350) checkbox oChk var lChkSel PROMPT "Selecionar todos" size 60,07 on CLICK seleciona(lChkSel)
        @ C(210), C(410) HBUTTON oHButton1 PROMPT "Confirmar" SIZE 025, 007 OF oDlg ACTION Confirma()
        @ C(210), C(440) HBUTTON oHButton2 PROMPT "Descartar" SIZE 025, 007 OF oDlg ACTION Descarta()
        @ C(210), C(470) HBUTTON oHButton2 PROMPT "Sair" SIZE 025, 007 OF oDlg ACTION Sair()

            fMSNewGe1()
            oTimer := TTimer():New(nMilissegundos, {|| UpdTimer() }, oDlg )
            oTimer:Activate()
    ACTIVATE MSDIALOG oDlg
else
    Alert('Usuario não autorizado a acessar a rotina!')
EndIf

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
    Aadd(aColsEx[Len(aColsEx)],'LBNO')
    Aadd(aColsEx[Len(aColsEx)],Alltrim(FwFilialName(cEmpAnt,(cAliasTrb)->D1_FILIAL,1)))
    Aadd(aColsEx[Len(aColsEx)],(cAliasTrb)->B1_COD)
    Aadd(aColsEx[Len(aColsEx)],(cAliasTrb)->B1_DESC)
    Aadd(aColsEx[Len(aColsEx)],(cAliasTrb)->D1_DOC)
    Aadd(aColsEx[Len(aColsEx)],DTOC(STOD((cAliasTrb)->D1_DTDIGIT)))
    Aadd(aColsEx[Len(aColsEx)],xMoeda((cAliasTrb)->BZ_CUSTD,VAL((cAliasTrb)->BZ_MCUSTD),1,STOD((cAliasTrb)->D1_DTDIGIT),TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,STOD((cAliasTrb)->D1_DTDIGIT),'M2_MOEDA2')))
    Aadd(aColsEx[Len(aColsEx)],(cAliasTrb)->D1_CUSTO / (cAliasTrb)->D1_QUANT)
    Aadd(aColsEx[Len(aColsEx)],(cAliasTrb)->B2_CM1)
    Aadd(aColsEx[Len(aColsEx)],0)
    Aadd(aColsEx[Len(aColsEx)],' ')
    Aadd(aColsEx[Len(aColsEx)],CalcEst((cAliasTrb)->B1_COD,(cAliasTrb)->D1_LOCAL)[1])
    Aadd(aColsEx[Len(aColsEx)],(cAliasTrb)->A2_NOME)
    Aadd(aColsEx[Len(aColsEx)],.F.)

    Aadd(aRegD1, {(cAliasTrb)->RECD1,(cAliasTrb)->RECBZ})

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
Local nCusto    := 0
Local nCMedio   := 0

If VldBranco() .And. MsgYesNo('Confirma a ação?')

    For nI := 1 to Len(oMSNewGe1:aCols)
        If oMSNewGe1:aCOLS[nI,1] == 'LBOK'
            Do Case
                Case oMSNewGe1:aCOLS[nI,11] == '1'
                    nCusto := oMSNewGe1:aCOLS[nI,8]
                Case oMSNewGe1:aCOLS[nI,11] == '2'
                    nCusto := oMSNewGe1:aCOLS[nI,9]
                Case oMSNewGe1:aCOLS[nI,11] == '3'
                    nCusto := oMSNewGe1:aCOLS[nI,10]
            EndCase
            nCMedio   := oMSNewGe1:aCOLS[nI,9]
            oMSNewGe1:aCOLS[nI,14] := .T.

            SBZ->(DbGoTo(aRegD1[nI,2]))

            SD1->(DbGoTo(aRegD1[nI,1]))


            UpdHist('C',nCusto,nCMedio)

            If RecLock('SD1',.F.)
                SD1->D1_XHOMOL := 'S'
                MsUnlock()
            EndIf

            If RecLock('SBZ',.F.)
                SBZ->BZ_CUSTD := nCusto
                MsUnlock()
            EndIf


            U_UpdDA1()

        EndIf
    Next
    MsgInfo('Registros Atualizados!')
EndIf

Return


Static Function Descarta()


If MsgYesNo('Confirma a ação?')
    For nI := 1 to Len(oMSNewGe1:aCols)
        If oMSNewGe1:aCOLS[nI,1] == 'LBOK'

            oMSNewGe1:aCOLS[nI,13] := .T.

            SBZ->(DbGoTo(aRegD1[nI,2]))

            SD1->(DbGoTo(aRegD1[nI,1]))

            UpdHist('D',0)
            If RecLock('SD1',.F.)
                SD1->D1_XDESCAR := 'S'
                MsUnlock()
            EndIf

        EndIf
    Next
    MsgInfo('Registros Descartados!')
EndIf

Return

Static Function UpdHist(cTipo,nCusto,nCMedio)
Reclock('SZ4',.T.)
SZ4->Z4_FILIAL  := SD1->D1_FILIAL
SZ4->Z4_DATA    := dDataBase
SZ4->Z4_COD     := oMSNewGe1:aCOLS[nI,3]
SZ4->Z4_TIPO    := cTipo
SZ4->Z4_DESC    := oMSNewGe1:aCOLS[nI,4]//Posicione('SB1',1,xFilial('SB1') + SD1->D1_COD,'B1_DESC')
SZ4->Z4_CANTER  := SBZ->BZ_CUSTD
SZ4->Z4_CHOMOLO := nCusto
SZ4->Z4_CMEDIO  := nCMedio

If cTipo == 'D'
    SZ4->Z4_DESCART := 'S'
else
    SZ4->Z4_OPCAO   := oMSNewGe1:aCOLS[nI,11]
EndIf

SZ4->Z4_USER    := Alltrim(UsrRetName( retcodusr() ))
SZ4->Z4_FORNECE := SD1->D1_FORNECE
SZ4->Z4_LOJA    := SD1->D1_LOJA
SZ4->Z4_NOME    := Posicione('SA2',1,xFilial('SA2') + SD1->D1_FORNECE + SD1->D1_LOJA , 'A2_NOME')

MsUnlock()

lAtualiza := .T.
//Atualizo a grid e dou refresh
oTimer:nInterval := 1

Return


Static Function UpdTimer()
    If ChkUso() .Or. lAtualiza
	    UpdTab()
        lAtualiza := .F.
    EndIf
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


user Function VlZ4Tipo()
Local lRet := .T.

IF oMSNewGe1 <> Nil
    If oMSNewGe1:aCOLS[n,10] == 0 .And. M->Z4_TIPO == '3'
        Alert("Digite um valor na coluna 'Digitado'")
        lRet := .F.
        oMSNewGe1:aCOLS[n,11] := ''
        oMSNewGe1:oBrowse:Refresh()
    EndIf
    If Empty(M->Z4_TIPO)
        Alert("Digite um valor na coluna 'Tipo'")
        lRet := .F.
        oMSNewGe1:oBrowse:Refresh()
    EndIf
EndIf
Return lRet


/*/{Protheus.doc} VldBranco
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
Static Function VldBranco()
Local lRet := .T.
Local n := 0

For n := 1 to Len(oMSNewGe1:aCOLS)
    If Empty(oMSNewGe1:aCOLS[n,11]) .And. oMSNewGe1:aCOLS[n,1] == 'LBOK'
        lRet := .F.
        Alert('Favor inserir um tipo de preço na linha: ' + Alltrim(STR(n)))
        Exit
    EndIf
Next
Return lRet
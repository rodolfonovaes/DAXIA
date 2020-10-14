#Include "Protheus.CH"
#Include "RWMake.CH"
#INCLUDE "TOPCONN.CH"

User Function DAXLP01()
Local cRet := ''
Local aArea := GetArea()
Local cQuery := ''
Local cAliasQry := GetNextAlias()


If Alltrim(SE2->E2_TIPO) == 'NF'
    //busco a NDF
    cQuery := "SELECT SE2.R_E_C_N_O_ AS REC "
    cQuery += "  FROM " + RetSQLTab('SE2')
    cQuery += "  WHERE  "
    cQuery += "  E2_FILIAL = '" + xFilial('SE2') + "' AND E2_TIPO = 'NDF'  AND "
    cQuery += "  E2_FORNECE = '" + SE2->E2_FORNECE + "' AND  E2_LOJA = '" + SE2->E2_LOJA + "'
    cQuery += "  AND SE2.D_E_L_E_T_ = ' '"

    TcQuery cQuery new Alias ( cAliasQry )

    (cAliasQry)->(dbGoTop())

    If !(cAliasQry)->(EOF())
        SE2->(DbGoTo((cAliasQry)->REC))
    EndIf    
    (cAliasQry)->(DBCloseArea())

    If Alltrim(SE2->E2_TIPO) == 'NDF'
        cRet := '101040100002'
    Else
        If ALLTRIM(SE2->E2_FORNECE) $ '000768|000790'
            cRet := '101040100003'
        Else
            cRet := '101040100001'
        EndIf
    EndIf    
Else
    If Alltrim(SE2->E2_TIPO) == 'NDF'
        cRet := '101040100002'
    Else
        If ALLTRIM(SE2->E2_FORNECE) $ '000768|000790'
            cRet := '101040100003'
        Else
            cRet := '101040100001'
        EndIf
    EndIf
EndIf
RestArea(aArea)
Return cRet
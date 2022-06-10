#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
User Function CRM980MDef()
Local aRotina := {}
Local cUsrCons  := SupergetMV('ES_USRCONS',.T.,'')
Local cUsrHist  := SupergetMV('ES_USRHIST',.T.,'')
Local aGrupos   := UsrRetGrp()

//----------------------------------------------------------------------------------------------------------
// [n][1] - Nome da Funcionalidade
// [n][2] - Função de Usuário 
// [n][3] - Operação (1-Pesquisa; 2-Visualização; 3-Inclusão; 4-Alteração; 5-Exclusão)
// [n][4] - Acesso relacionado a rotina, se esta posição não for informada nenhum acesso será validado
//----------------------------------------------------------------------------------------------------------

If Len(aGrupos) > 0
    If Autoriza(aGrupos,cUsrHist)
        aAdd(aRotina,{"Histórico Serasa","U_DAXATU30()",MODEL_OPERATION_VIEW,0})
    EndIf
    If Autoriza(aGrupos,cUsrCons)
        Aadd(aRotina,{'Consulta Serasa',"U_DAXATU17()"							, 0, 6, 0, NIL})
    EndIf
EndIf
Return aRotina

Static Function Autoriza(aGrupos,cGrupos)
Local lRet := .F.
Local n     := 0

For n := 1 to Len(aGrupos)
    If aGrupos[n] $ cGrupos
        lRet := .T.
        Exit
    EndIf
Next


Return( lRet )




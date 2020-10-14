#INCLUDE "PROTHEUS.CH"


/*/{Protheus.doc} MA030ROT
Adiciona informacoes no menu do cadastro de cliente
@type  User Function
@author B. Vinicius
@since 24/01/2020
/*/User Function MA030ROT()

Local aRotina := {}
Local cUsrCons  := SupergetMV('ES_USRCONS',.T.,'')
Local cUsrHist  := SupergetMV('ES_USRHIST',.T.,'')
Local aGrupos   := UsrRetGrp()

If Autoriza(aGrupos,cUsrHist)
    Aadd(aRotina,{'Histórico Serasa',"U_DAXATU30()"							, 0, 6, 0, NIL})
EndIf
If Autoriza(aGrupos,cUsrCons)
    Aadd(aRotina,{'Consulta Serasa',"U_DAXATU17()"							, 0, 6, 0, NIL})
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

Return lRet
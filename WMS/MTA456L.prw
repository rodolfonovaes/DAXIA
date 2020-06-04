#INCLUDE "TOPCONN.CH"
 /*/{Protheus.doc} MTA456I()
    TRATAMENTO PARA QUANDO A QUANTIDADE ULTRAPASSAR A NORMA, VOU GRAVAR UMA DCF POR NORMA
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
User Function MTA456L()
Local aArea := GetArea()
Local cPed       := SC9->C9_PEDIDO
Local nOpc       := PARAMIXB[1]

If nOpc == 1  .Or. nOpc == 4 //OK ou Lib Todos
    If U_DaxLib(SC9->C9_PEDIDO)
        U_AjustaC9(cPed)
    EndIf
EndIf

RestArea(aArea)
Return Nil




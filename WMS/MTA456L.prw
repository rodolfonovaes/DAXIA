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
    SC5->(DbSetOrder(1))
    If SC5->(DbSeek(xFilial('SC5') + SC9->C9_PEDIDO))
        SA1->(DbSetOrder(1))
        If SA1->(DbSeek(xFilial('SA1') + SC5->(C5_CLIENTE + C5_LOJACLI)))
            RecLock('SA1', .F.)
            SA1->A1_SALPEDL := SC5->C5_XVLTOT
            MsUnlock()
        EndIf
    EndIf

    If U_DaxLib(SC9->C9_PEDIDO)
        U_AjustaC9(cPed)
    EndIf
EndIf

RestArea(aArea)
Return Nil




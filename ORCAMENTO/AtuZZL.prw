#Include "Protheus.CH"
#Include "topconn.ch"
/*/{Protheus.doc} AtuZZL
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
User Function AtuZZL()
Local aArea := GetArea()
Local lReclock    := .F.


ZZL->(DbSetOrder(1))
If ZZL->(DbSeek(xFilial('ZZL') + M->A1_COD + M->A1_LOJA + DTOS(dDataBase)))
    lReclock := .F.
Else
    lReclock := .T.
EndIf

RecLock('ZZL',lReclock)
ZZL->ZZL_FILIAL := xFilial('ZZL')
ZZL->ZZL_COD    := M->A1_COD
ZZL->ZZL_LOJA   := M->A1_LOJA
ZZL->ZZL_NOME   := M->A1_NOME
ZZL->ZZL_DATA   := dDataBase
MsUnLock()

M->A1_DTALTER := dDataBase

RestArea(aArea)

Return .T.
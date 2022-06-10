/*/{Protheus.doc} MTA455P()
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
ZUser Function MTA455P()
Local lRet := .T.
Public  _cLibCred := '  '
_cLibCred := SC9->C9_BLCRED

If PARAMIXB[1] <> 0 
    SC5->(DbSetOrder(1))
    If SC5->(DbSeek(xFilial('SC5') + SC9->C9_PEDIDO)) .And. Posicione('SCJ',1,xFilial('SCJ') + SC5->C5_XNUMCJ , 'CJ_XFATPAR') == '2'
        If nQtdNew < SC9->C9_QTDLIB 
           Alert('Não é permitido alterar a quantidade a ser liberada!')
           lRet := .F.
        EndIf
    EndIf
EndIf
Return lRet

 /*/{Protheus.doc} A415TDOK
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
User Function A415TDOK
Local lRet := .T.

If M->CJ_XTPFRET <> '5' .And. Empty(M->CJ_XTRANSP)
    Alert('Favor preencher a tranportadora!')
    lRet := .F.
EndIf

Return lRet

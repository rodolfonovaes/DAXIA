/*/{Protheus.doc} NextDoCu()
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
User Function NextDoCu()
cRet := ''

SX6->(DbSetOrder(1))
If SX6->(DbSeek(xFilial('SX6') + 'ES_PRXDOCU'))
    cRet    := Alltrim(SX6->X6_CONTEUD)
    RecLock('SX6', .F.)
    SX6->X6_CONTEUD := Soma1(cRet)      
    MsUnlock()
EndIf

Return cRet

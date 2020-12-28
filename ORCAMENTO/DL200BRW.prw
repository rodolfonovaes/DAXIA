/*/{Protheus.doc} DL200BRW()
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
User Function DL200BRW()
Local aRet := {}
Local aParam := PARAMIXB
Local n     := 0

For n := 1 to Len(aParam)
    If n == 6
        AAdd( aRet ,{"PED_NMTRAN" , ,'Transportadora'} )
        AAdd( aRet ,{"PED_ENDTRA" , ,'Endereço'} )
        AAdd( aRet ,{"PED_BAITRA" , ,'Bairro'} )
        AAdd( aRet ,{"PED_CIDTRA" , ,'Cidade'} )
    EndIf
    Aadd(aRet,aParam[n])
Next
Return aRet
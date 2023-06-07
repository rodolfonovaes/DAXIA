/*/{Protheus.doc} WMSA320M
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
User Function WMSA320M()
Local nPos := aScan(aRotina,{|x| AllTrim(x[2])=="WMSR325()"})

If nPos > 0
    aRotina[nPos][2] := 'U_XWMSR325()'
EndIf
Return 

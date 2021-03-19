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
Local nPos  := 0

Aadd(aRet,aParam[1]) // STATUS

nPos := aScan(aParam, {|x| x[1] == 'PED_ROTA'})
If nPos > 0 
    Aadd(aRet,aParam[nPos]) // 
EndIf

nPos := aScan(aParam, {|x| x[1] == 'PED_PESO'})
If nPos > 0 
    Aadd(aRet,aParam[nPos]) // 
EndIf

nPos := aScan(aParam, {|x| x[1] == 'PED_VALOR'})
If nPos > 0 
    Aadd(aRet,aParam[nPos]) // 
EndIf

//Transportadora
AAdd( aRet ,{"PED_NMTRAN" , ,'Transportadora'} )
AAdd( aRet ,{"PED_ENDTRA" , ,'Endereço'} )
AAdd( aRet ,{"PED_BAITRA" , ,'Bairro'} )
AAdd( aRet ,{"PED_CIDTRA" , ,'Cidade'} )

nPos := aScan(aParam, {|x| x[1] == 'PED_CODCLI'})
If nPos > 0 
    Aadd(aRet,aParam[nPos]) // 
EndIf

nPos := aScan(aParam, {|x| x[1] == 'PED_LOJA'})
If nPos > 0 
    Aadd(aRet,aParam[nPos]) // 
EndIf

nPos := aScan(aParam, {|x| x[1] == 'PED_NOME'})
If nPos > 0 
    Aadd(aRet,aParam[nPos]) // 
EndIf

nPos := aScan(aParam, {|x| x[1] == 'PED_EST'})
If nPos > 0 
    Aadd(aRet,aParam[nPos]) // 
EndIf

nPos := aScan(aParam, {|x| x[1] == 'PED_MUN'})
If nPos > 0 
    Aadd(aRet,aParam[nPos]) // 
EndIf

nPos := aScan(aParam, {|x| x[1] == 'PED_BAIRRO'})
If nPos > 0 
    Aadd(aRet,aParam[nPos]) // 
EndIf

nPos := aScan(aParam, {|x| x[1] == 'PED_CEP'})
If nPos > 0 
    Aadd(aRet,aParam[nPos]) // 
EndIf

nPos := aScan(aParam, {|x| x[1] == 'PED_ENDCLI'})
If nPos > 0 
    Aadd(aRet,aParam[nPos]) // 
EndIf

For n := 1 to Len(aParam) //Adiciono o restante no retorno
    nPos := aScan(aRet, {|x| x[1] == aParam[n][1]})
    If nPos == 0
        Aadd(aRet,aParam[n])
    EndIf 
Next
Return aRet
User Function DL200TRB()
Local aRet := {}
Local aTamSX3   := {}
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
aTamSX3 := TamSx3("A4_NOME" )       ; AAdd(aRet,{"PED_NMTRAN"   ,"C",aTamSX3[1]    ,aTamSX3[2]})
aTamSX3 := TamSx3("A4_END" )        ; AAdd(aRet,{"PED_ENDTRA"   ,"C",aTamSX3[1]    ,aTamSX3[2]})
aTamSX3 := TamSx3("A4_BAIRRO" )     ; AAdd(aRet,{"PED_BAITRA"   ,"C",aTamSX3[1]    ,aTamSX3[2]})
aTamSX3 := TamSx3("A4_MUN" )        ; AAdd(aRet,{"PED_CIDTRA"   ,"C",aTamSX3[1]    ,aTamSX3[2]})

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
User Function DL200TRB()
Local aRet := {}
Local aTamSX3   := {}
Local aParam := PARAMIXB
Local n     := 0

For n := 1 to Len(aParam)
    If n == 6
        aTamSX3 := TamSx3("A4_NOME" )       ; AAdd(aRet,{"PED_NMTRAN"   ,"C",aTamSX3[1]    ,aTamSX3[2]})
        aTamSX3 := TamSx3("A4_END" )        ; AAdd(aRet,{"PED_ENDTRA"   ,"C",aTamSX3[1]    ,aTamSX3[2]})
        aTamSX3 := TamSx3("A4_BAIRRO" )     ; AAdd(aRet,{"PED_BAITRA"   ,"C",aTamSX3[1]    ,aTamSX3[2]})
        aTamSX3 := TamSx3("A4_MUN" )        ; AAdd(aRet,{"PED_CIDTRA"   ,"C",aTamSX3[1]    ,aTamSX3[2]})
    EndIf
    Aadd(aRet,aParam[n])
Next
Return aRet
User Function F4LoteHeader
/*cProg, lSLote, aHeaderF4cProg - Programa que chamou a F4LotelSLote - Informa se o produto tem rastro por sublote*/
Local aHeaderF4 := PARAMIXB[3]
Local aRet      := {}
Local n         := 0

For n := 1 to Len(aHeaderF4)
    If n == 6 
        Aadd(aRet, 'Nome Fabricante')
    EndIf
    Aadd(aRet,aHeaderF4[n])
Next
Return(aRet)
User Function F4LoteArray()
/*Deve retornar o array acrescido da coluna ou reordenado na sequencia desejada*/
Local aArrayF4 := PARAMIXB[5]
Local aRet     := {}
Local n        := 0

For n := 1 to Len(aArrayF4)
    If n == 6
        Aadd(aRet, SB8->B8_NFABRIC)
    EndIf
    Aadd(aRet,aArrayF4[n])
Next

Return(aRet)
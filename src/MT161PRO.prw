User Function MT161PRO()
Local aPropostas    := PARAMIXB[1]
Local n             := 0
Local nPag          := 0
Public _nDaxNumProp := 0
For nPag := 1 to Len(aPropostas)
    For n := 1 to Len(aPropostas[nPag])
        If aPropostas[nPag][n][2][1][1]
            _nDaxNumProp := aPropostas[nPag][n][2][1][9]
        EndIf
    Next
Next
Return aPropostas
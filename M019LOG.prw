User Function M019LOG
Local aCabec	    := PARAMIXB[1]
Local aCampos	    := PARAMIXB[2]
Local nPosFilial    := AScan(aCabec, {|x| x[2] == Alltrim('BZ_FILIAL')})
Local nPosCustd     := AScan(aCabec, {|x| x[2] == Alltrim('BZ_CUSTD')})
Local cCod             := SBZ->BZ_COD
Local nCanter       := 0
Local n             := 0
Local aArea         := GetArea()

For n := 1 to Len(aCampos)
    If aCampos[n][nPosCustd] > 0
        SBZ->(DbSetOrder(1))
        If SBZ->(DbSeek(xFilial('SBZ',aCampos[n][nPosFilial]) + cCod))
            nCanter := SBZ->BZ_CUSTD
        Else
            nCanter := 0
        EndIF

        Reclock('SZ4',.T.)
        SZ4->Z4_FILIAL  := aCampos[n][nPosFilial]
        SZ4->Z4_DATA    := dDataBase
        SZ4->Z4_COD     := SB1->B1_COD
        SZ4->Z4_TIPO    := 'C'
        SZ4->Z4_DESC    := SB1->B1_DESC
        SZ4->Z4_CANTER  := nCanter
        SZ4->Z4_CHOMOLO := aCampos[n][nPosCustd]
        SZ4->Z4_CMEDIO  := 0
        SZ4->Z4_USER    := Alltrim(UsrRetName( retcodusr() ))
        SZ4->Z4_OPCAO   := '4' //Editado
        MsUnlock()
    EndIf
Next

U_UpdDA1() //Atualizo as tabelas de preço 

RestArea(aArea)

Return

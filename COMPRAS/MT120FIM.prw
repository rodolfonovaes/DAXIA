User Function MT120FIM()
Local nOpcao := PARAMIXB[1]   // Opção Escolhida pelo usuario
Local cNumPC := PARAMIXB[2]   // Numero do Pedido de Compras
Local nOpcA     := PARAMIXB[3]   // Indica se a ação foi Cancelada = 0  ou Confirmada = 1.CODIGO DE APLICAÇÃO DO USUARIO.....
Local aArea     := GetArea()
If nOpcA == 1
    SCR->(DbSetOrder(1))
    If SCR->(DbSeek(xFilial('SCR') + 'PC' + cNumPC))
        While Alltrim(xFilial('SCR') + 'PC' + cNumPC) == Alltrim(xFilial('SCR') + SCR->(CR_TIPO + CR_NUM))
            Reclock('SCR',.F.)
            SCR->CR_FORNECE := cA120Forn
            SCR->CR_LOJA    := cA120Loj
            SCR->CR_NREDUZ  := Posicione('SA2',1,xFilial('SA2') + cA120Forn + cA120Loj ,'A2_NREDUZ')
            SCR->(DbSkip())
        EndDo
    EndIf

    If FindFunction( 'U_DXCMAIL') .And. nOpcao == 3
        U_DXCMAIL(cNumPC)
    EndIf

    SC7->(DbSetOrder(1))
    If SC7->(DbSeek(xFilial('SC7') + cNumPC))
        While xFilial('SC7') + cNumPC == SC7->(C7_FILIAL + SC7->C7_NUM)
            If !Empty(SC7->C7_CONTRA)    
                CND->(DbSetOrder(4))
                IF CND->(DbSeek(xFilial('CND') + SC7->(C7_MEDICAO)))
                    Reclock('SC7',.F.)
                    SC7->C7_OBSM := CND->CND_OBS
                    MsUnlock()
                EndIf
            EndIf
            SC7->(DbSkip())
        EndDo
    EndIf
EndIf
RestArea(aArea)
Return
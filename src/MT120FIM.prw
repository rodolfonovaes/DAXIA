User Function MT120FIM()
Local nOpcao := PARAMIXB[1]   // Op��o Escolhida pelo usuario
Local cNumPC := PARAMIXB[2]   // Numero do Pedido de Compras
Local nOpcA     := PARAMIXB[3]   // Indica se a a��o foi Cancelada = 0  ou Confirmada = 1.CODIGO DE APLICA��O DO USUARIO.....
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
EndIf
Return
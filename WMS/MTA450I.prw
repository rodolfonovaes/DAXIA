User Function MTA450I()
Local aArea := GetArea()

SC5->(DbSetOrder(1))
If SC5->(DbSeek(xFilial('SC5') + SC9->C9_PEDIDO))
    SA1->(DbSetOrder(1))
    If SA1->(DbSeek(xFilial('SA1') + SC5->(C5_CLIENTE + C5_LOJACLI)))
        RecLock('SA1', .F.)
        SA1->A1_SALPEDL := SC5->C5_XVLTOT
        MsUnlock()
    EndIf
EndIf

U_DaxLib(SC9->C9_PEDIDO)

RestArea(aArea)

Return Nil

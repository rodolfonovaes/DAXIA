User Function MT160GRPC()
Local aArea      := GetArea()

SC7->C7_XNOMFOR := Posicione('SA2',1,xFilial('SA2') + SC7->(C7_FORNECE + C7_LOJA),'A2_NOME')

RestArea(aArea)
Return

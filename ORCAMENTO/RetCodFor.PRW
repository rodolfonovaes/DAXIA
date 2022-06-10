


User Function RetCodFor()
Local aAreaAtu := SA2->(GetArea())
Local cCod
Local cTipo  := M->A2_TIPO
Local cCNPJ     := M->A2_CGC


dbSelectArea("SA2")
dbSetOrder(3)
If cTipo == "J" .and. dbSeek(xFilial("SA2")+Left(cCNPJ,8))
    cCod := SA2->A2_COD
Else
    cCod := GETSXENUM("SA2")
    ConfirmSx8()
Endif

RestArea(aAreaAtu)
Return cCod

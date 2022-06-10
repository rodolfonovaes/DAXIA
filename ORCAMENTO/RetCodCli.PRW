User Function RetCodCli
Local aAreaAtu := SA1->(GetArea())
Local cCod
Local cTPessoa  := M->A1_PESSOA
Local cCNPJ     := M->A1_CGC


dbSelectArea("SA1")
dbSetOrder(3)
If cTPessoa == "J" .and. dbSeek(xFilial("SA1")+Left(cCNPJ,8))
    cCod := SA1->A1_COD
Else
    cCod := GETSXENUM("SA1")
    ConfirmSx8()
Endif

RestArea(aAreaAtu)
Return cCod

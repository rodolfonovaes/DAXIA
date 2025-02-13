User Function RetNorma()
Local nNorma := 0
Local cLocal := Supergetmv('ES_LOCNORMA',.t.,'01')

//obtenho a norma
DC3->(DbSetOrder(2))
If DC3->(DbSeek(xFilial('DC3') + SB1->B1_COD + cLocal))
    DC2->(DbSetOrder(1))
    DC2->(DbSeek(xFilial('DC2') + DC3->DC3_CODNOR))			
    nNorma :=  (DC2->DC2_LASTRO * DC2->DC2_CAMADA) * SB1->B1_CONV
EndIf

Return nNorma



User Function JobNorma()
Local nNorma := 0
SB1->(DbSetOrder(1))
SB1->(DbGoTop())
While SB1->(!Eof())
    nNorma :=U_RetNorma()
    Reclock('SB1',.f.)
    SB1->B1_XNORMA := nNorma
    MsUnlock()
    SB1->(DbSkip())
EndDO
Return

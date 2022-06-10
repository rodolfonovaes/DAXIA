#Include 'Protheus.ch'
User Function GFEA1155()
Local aOldArea := GetArea()
Local cNumeroNF := GXH->GXH_NRDC
Local cSerieNF  := PADr(GXG->GXG_SERDF,Tamsx3('GZZ_SERDF')[1])
Local oModel    := FWModelActive()

RecLock('GXH', .F.)
GXH->GXH_NRDC :=  PADL(Alltrim(GXG->GXG_NRDF),9,'0') 
GXH->GXH_SERDC :=  PADL(Alltrim(GXG->GXG_SERDF),3,'0') 
MsUnlock()

RecLock('GW1', .F.)
GW1->GW1_NRDC :=  PADL(Alltrim(GXG->GXG_NRDF),9,'0') 
GW1->GW1_SERDC :=  PADL(Alltrim(GXG->GXG_SERDF),3,'0') 
MsUnlock()

RecLock('GXG', .F.)
GXG->GXG_NRDF :=  PADL(Alltrim(GXG->GXG_NRDF),9,'0') 
GXG->GXG_SERDF :=  PADL(Alltrim(GXG->GXG_SERDF),3,'0') 
MsUnlock()

oModel:LoadValue("GFEA065_GW3",'GW3_NRDF'   ,ALLTRIM(GXG->GXG_NRDF)  )
oModel:LoadValue("GFEA065_GW3",'GW3_SERDF'   ,ALLTRIM(GXG->GXG_SERDF)  )

GZZ->(DbSetOrder(1))
    If GZZ->(DbSeek(xFilial('GZZ') + 'CTE  ' +  GXG->GXG_EMISDF + cSerieNF + cNumeroNF))
    While xFilial('GZZ') + 'CTE  ' +  GXG->GXG_EMISDF + cSerieNF + Alltrim(cNumeroNF) == AllTrim(GZZ->(GZZ_FILIAL + GZZ_CDESP + GZZ_EMISDF + GZZ_SERDF + GZZ_NRDF))
        RecLock('GZZ', .F.)
        GZZ->GZZ_NRDF := Alltrim(GXG->GXG_NRDF)        
        GZZ->GZZ_SERDF := Alltrim(GXG->GXG_SERDF) 
        MsUnlock()
        GZZ->(DbSkip())
    EndDo
EndIf
RestArea(aOldArea)

Return .T.

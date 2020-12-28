User FUNCTION WMSA225()
Local aParam := PARAMIXB
Local oModel := aParam[1]
Local xRet   := .T.
Local oModelSel := Nil
Local dDVldSB8  := Ctod(' ')
Local dDFabSB8  := Ctod(' ') 
Local cLotForn  := ''
Local cNomFabr  := '' 
Local cPaisOri  := ''
Local cXCFABRI  := ''
Local cXLFABRI  := ''

If aParam[2] == 'FORMCOMMITTTSPOS' 
    oModelSel  := oModel:GetModel("SELECAO")
    DbSelectArea( "SB8" )
    DbSetOrder( 2 ) 
    
    If DbSeek( xFilial( "SB8" ) +oModelSel:GetValue("CODPRO") + oModelSel:GetValue("LOCAL") + oModelSel:GetValue("LOTECTL") )
        dDVldSB8 := SB8->B8_DTVALID
        dDFabSB8 := SB8->B8_DFABRIC
        cLotForn := SB8->B8_LOTEFOR
        cNomFabr := SB8->B8_NFABRIC
        cPaisOri := SB8->B8_XPAISOR
        cXCFABRI := SB8->B8_XCFABRI
        cXLFABRI := SB8->B8_XLFABRI
    EndIf    


    If DbSeek( xFilial( "SB8" ) +oModelSel:GetValue("CODPRO") + oModelSel:GetValue("LOCDES") + oModelSel:GetValue("LOTECTL") )
        RecLock( "SB8", .F. )
        Replace SB8->B8_DTVALID With dDVldSB8
        Replace SB8->B8_DFABRIC With dDFabSB8
        Replace SB8->B8_NFABRIC With cNomFabr
        Replace SB8->B8_LOTEFOR With cLotForn 
        Replace SB8->B8_XPAISOR With cPaisOri
        Replace SB8->B8_XCFABRI With cXCFABRI
        Replace SB8->B8_XLFABRI With cXLFABRI
        SB8->( MSUnLock() )
    EndIf

EndIf

Return xRet
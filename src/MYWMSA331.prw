User Function WMSA331
Local aParam := PARAMIXB
Local oModel := aParam[1]
Local xRet   := .T.
Local oMdl := FwModelActive()
Local dDVldSB8	 := dDataBase
Local dDFabSB8	 := dDataBase
Local cLotForn	 := ''
Local cNomFabr	 := ''
Local cPaisOri	 := ''
Local cXCFABRI	 := ''
Local cXLFABRI	 := ''
Local cCliFor    := ''
Local cLoja      := ''
Local cXDProd    := ''

If aParam[2] == 'FORMLINEPOS' 

EndIf

Return xRet
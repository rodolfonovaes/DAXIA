//PONTO DE ENTRADA NO CALCULO DE RESCISAO
User FUNCTION WMSA020()
Local aParam := PARAMIXB
Local oModel 
Local xRet   := .T.
Local nNorma := 0
Local cNorma := ''
Local nLastro := 0
Local nCamada   := 0
//Se tiver parâmetros
If  (aParam == Nil)
    Break
EndIf

If aParam[2] == 'MODELCOMMITNTTS' 
    oModel := aParam[1]

    cNorma := oModel:GetModel("DC2MASTER"):GetValue('DC2_CODNOR')
    nLastro := oModel:GetModel("DC2MASTER"):GetValue('DC2_LASTRO')
    nCamada := oModel:GetModel("DC2MASTER"):GetValue('DC2_CAMADA')

    DC3->(DbSetOrder(3))
    If DC3->(DbSeek(xFilial('DC3') + cNorma))
        SB1->(DbSetOrder(1))
        If SB1->(DbSeek(xFilial('SB1') + DC3->DC3_CODPRO))
            nNorma :=  (nLastro * nCamada) * SB1->B1_CONV
            Reclock('SB1',.f.)
            SB1->B1_XNORMA := nNorma
            MsUnlock()      
        EndIf
    EndIf

EndIf

Return xRet

User FUNCTION CNTA300()
Local aParam := PARAMIXB
Local oModel 
Local xRet   := .T.
Local oModelCNB := NIL
Local oModelCNZ := NIL
Local cConta    := ''
Local lCc   := .F.
Local lItem   := .F.
Local lClvl   := .F.
Local n         := 0
Local x         := 0

//Se tiver parâmetros
If  (aParam == Nil)
    Break
EndIf

If aParam[2] == 'MODELPOS' 
    oModel := aParam[1]

    For n := 1 to oModel:GetModel("CNBDETAIL"):Length()
        oModelCNB	:= oModel:GetModel("CNBDETAIL")
        oModelCNZ	:= oModel:GetModel("CNZDETAIL")
        cConta :=   oModelCNB:GetValue('CNB_CONTA') 
        oModelCNZ:GoLine(n)
        CT1->(DbSetOrder(1))
        If CT1->(DbSeek(xFilial('CT1') + cConta))
            If CT1->CT1_CCOBRG == '1'
                lCc := .T.
            EndIf
            If CT1->CT1_ITOBRG == '1'
                lItem := .T.
            EndIf
            If CT1->CT1_CLOBRG == '1'
                lClvl := .T.
            EndIf
        EndIf

        If oModel:GetModel("CNZDETAIL"):Length() > 1
            For x := 1 to oModel:GetModel("CNZDETAIL"):Length()
                oModelCNZ:GoLine(x)
                If (lCc .And. Empty(oModelCNZ:GetValue('CNZ_CC'))) .Or. ;
                    (lItem .And. Empty(oModelCNZ:GetValue('CNZ_ITEMCT'))) .Or. ;
                    (lClvl .And. Empty(oModelCNZ:GetValue('CNZ_CLVL')))

                    oModel:SetErrorMessage("CN9MASTER","CNZDETAIL" ,"CNZDETAIL","IDFIELDERR","CNTA300","Erro","Produto " + Alltrim(oModelCNB:GetValue('CNB_PRODUT')) + ' : O rateio deve respeitar a obrigatoriedade de preenchimento de Centro de custo, item e classe de valor informados na conta contabil ' )
                    xRet := .F.
                    Exit
                EndIf
            Next
        EndIf
    Next
EndIf

Return xRet

#INCLUDE "PROTHEUS.CH"
#INCLUDE "ApWizard.ch"
#INCLUDE "FWMVCDEF.CH"
/*/{Protheus.doc} DXVLCTA()
    (long_description)
    @type  Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function DXVLCTA()
Local lRet := .T.
Local aArea := GetArea()
Local oModelCNB := NIL
Local oModel := NIL
Local oStruCNB  := NIL
Local cConta := FwFldGet('CNB_CONTA')

oModel 		:= FWModelActive()
oModelCNB	:= oModel:GetModel("CNBDETAIL")
oModelCNB	:= oModelCNB:GetStruct()


if oModel:GetModel("CNZDETAIL"):Length() == 1
    CT1->(DbSetOrder(1))
    If CT1->(DbSeek(xFilial('CT1') + cConta))
        If CT1->CT1_CCOBRG == '1'
            oModelCNB:SetProperty("CNB_CC" 		,MODEL_FIELD_OBRIGAT,.T.)
        Else
            oModelCNB:SetProperty("CNB_CC" 		,MODEL_FIELD_OBRIGAT,.F.)
        EndIf
        If CT1->CT1_ITOBRG == '1'
            oModelCNB:SetProperty("CNB_ITEMCT" 		,MODEL_FIELD_OBRIGAT,.T.)
        Else
            oModelCNB:SetProperty("CNB_ITEMCT" 		,MODEL_FIELD_OBRIGAT,.F.)
        EndIf
        If CT1->CT1_CLOBRG == '1'
            oModelCNB:SetProperty("CNB_CLVL" 		,MODEL_FIELD_OBRIGAT,.T.)
        Else
            oModelCNB:SetProperty("CNB_CLVL" 		,MODEL_FIELD_OBRIGAT,.F.)
        EndIf
    EndIf
EndIf
RestArea(aArea)
Return lRet
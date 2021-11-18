/*/{Protheus.doc} OM200GRV
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
User Function OM200GRV()
Local aArea := GetArea()
Local cTransp := ''

SC5->(DbSetOrder(1))
If SC5->(DbSeek(xFilial('SC5') + TRBPED->PED_PEDIDO))
    cTransp := IIF(!Empty(SC5->C5_XTREDES), SC5->C5_XTREDES,SC5->C5_REDESP)
    //Aqui eu gravo os dados

    SA4->(DbSetOrder(1))
    SA1->(DbSetOrder(1))

    If !empty(cTransp) .And. SA4->(DbSeek(xFilial('SA4') + cTransp))
        Reclock('TRBPED',.F.)
        TRBPED->PED_NMTRAN    := SA4->A4_NOME
        TRBPED->PED_ENDTRA    := SA4->A4_END
        TRBPED->PED_BAITRA    := SA4->A4_BAIRRO
        TRBPED->PED_CIDTRA    := SA4->A4_MUN
        MsUnlock()
    EndIf    

    IF SA1->(DbSeek(xFilial('SA1') + SC5->(C5_CLIENTE + C5_LOJACLI)))
        Reclock('TRBPED',.F.)
        TRBPED->PED_CEP    := SA1->A1_CEP
        TRBPED->PED_ENDCLI := SA1->A1_END
        TRBPED->PED_BAIRRO := SA1->A1_BAIRRO
        TRBPED->PED_MUN    := SA1->A1_MUN
        TRBPED->PED_EST    := SA1->A1_EST
        MsUnlock()        
    EndIf
EndIf

RestArea(aArea)
Return 

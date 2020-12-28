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
//Aqui eu gravo os dados

SA4->(DbSetOrder(1))
If SA4->(DbSeek(xFilial('SA4') + SC5->C5_REDESP))
    Reclock('TRBPED',.F.)
    TRBPED->PED_NMTRAN    := SA4->A4_NOME
    TRBPED->PED_ENDTRA    := SA4->A4_END
    TRBPED->PED_BAITRA    := SA4->A4_BAIRRO
    TRBPED->PED_CIDTRA    := SA4->A4_MUN
    MsUnlock()
EndIf
RestArea(aArea)
Return 
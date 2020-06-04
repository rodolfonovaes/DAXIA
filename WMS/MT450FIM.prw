 /*/{Protheus.doc} MT450FIM()
    Tratamento na liberação de credito para o WMS
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
User Function MT450FIM()
Local cPed  := Paramixb[1]
Local aArea := GetArea()
Local cSrv		 := SuperGetMV('ES_SERVDIS',.T.,'019',cFilAnt)

If SC9->C9_SERVIC == cSrv
    U_AjustaC9(cPed)
EndIf

RestArea(aArea)

Return Nil
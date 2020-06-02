#INCLUDE "PROTHEUS.CH"

 /*/{Protheus.doc} MA090ATU
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
User Function MA090ATU()
Local aArea     := GetArea()

U_UpdDA1()

RestArea(aArea)
Return
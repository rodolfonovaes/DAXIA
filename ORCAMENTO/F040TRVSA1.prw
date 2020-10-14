#INCLUDE "PROTHEUS.CH" 
 /*/{Protheus.doc} F040TRVSA1
    Gravação da data de maior saldo
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
User Function F040TRVSA1
Local aArea := GetArea()
Reclock('SA1',.F.)
SA1->A1_XDTMSAL := Iif(SA1->A1_SALDUPM>=SA1->A1_MSALDO,dDataBase,SA1->A1_XDTMSAL)
MsUnlock()
RestArea(aArea)
Return .T.
#Include "Protheus.CH"
#Include "RWMake.CH"
/*/{Protheus.doc} MT410ALT
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
User Function MT410ALT()
Local aArea := GetArea()
Reclock('SC5',.F.)
SC5->C5_XUSER     := UsrRetName( retcodusr() )
SC5->C5_XDATE     := dDataBase
SC5->C5_XTIME     := Time()
MsUnlock()
RestArea(aArea)
Return Nil
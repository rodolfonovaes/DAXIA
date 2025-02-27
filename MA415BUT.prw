#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"
/*/{Protheus.doc} nomeFunction
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
User Function MA415BUT()
Local aBotao := {} 
Local cUsers   := SupergetMV('ES_NIVMARG',.T.,'totvs.rnovaes')

If at(UPPER(Alltrim(UsrRetName( retcodusr() ))),UPPER(cUsers)) > 0 .Or. at(UPPER(Alltrim(UsrRetName( retcodusr() ))),UPPER('totvs.rnovaes')) > 0
    aAdd( aBotao, {"BMPUSER",{|| U_DaxRenta()},"Margem de Rentabilidade"})
	aAdd( aBotao, {"BMPUSER",{|| U_DxRentIt()},"Margem de Rentabilidade Item"})
    SetKey(VK_F7,{||U_DaxRenta()})
    SetKey(VK_F8,{||U_DxRentIt()})
EndIf

aAdd( aBotao, {"BMPUSER",{|| U_DAXATU06()},"Consulta de Orçamentos"})

Return aBotao
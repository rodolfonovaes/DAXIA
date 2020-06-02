#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"

User Function MA440MNU()
Local cUsers   := SupergetMV('ES_NIVMARG',.T.,'totvs.rnovaes')

If at(UPPER(Alltrim(UsrRetName( retcodusr() ))),UPPER(cUsers)) > 0 .Or. at(UPPER(Alltrim(UsrRetName( retcodusr() ))),UPPER('totvs.rnovaes')) > 0
    AADD(aRotina, {'Margem', 'U_PdRent', 0, 0, 0, .F.} )
    AADD(aRotina, {'Margem Item', 'U_PdRentIt', 0, 0, 0, .F.} )

    SetKey(VK_F7,{||U_PdRent()})
    SetKey(VK_F8,{||U_pdRentIt()})
EndIf

//Atualizo campos de status
UpdStsC9()

Return 


/*/{Protheus.doc} UpdStsC9
    (long_description)
    @type  Static Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function UpdStsC9()
Local cQuery
Local nRet


cQuery := "UPDATE SC5010 SET C5_BLEST = XSC9.BLEST FROM SC5010 SC5  "
cQuery += "JOIN (SELECT C9_FILIAL,C9_PEDIDO,MAX(C9_BLEST) AS BLEST FROM SC9010 WHERE SC9010.D_E_L_E_T_ = ' ' GROUP BY C9_FILIAL,C9_PEDIDO) AS XSC9 ON XSC9.C9_FILIAL = SC5.C5_FILIAL AND XSC9.C9_PEDIDO = SC5.C5_NUM "
cQuery += "WHERE SC5.D_E_L_E_T_ = ' ' "
nRet   := TCSQLEXEC(cQuery)

cQuery := "UPDATE SC5010 SET C5_BLCRED = XSC9.BLCRED FROM SC5010 SC5  "
cQuery += "JOIN (SELECT C9_FILIAL,C9_PEDIDO,MAX(C9_BLCRED) AS BLCRED FROM SC9010 WHERE SC9010.D_E_L_E_T_ = ' ' GROUP BY C9_FILIAL,C9_PEDIDO) AS XSC9 ON XSC9.C9_FILIAL = SC5.C5_FILIAL AND XSC9.C9_PEDIDO = SC5.C5_NUM "
cQuery += "WHERE SC5.D_E_L_E_T_ = ' ' "
nRet   := TCSQLEXEC(cQuery)

cQuery := "UPDATE SC5010 SET C5_XBLWMS = XSC9.BLWMS FROM SC5010 SC5  "
cQuery += "JOIN (SELECT C9_FILIAL,C9_PEDIDO,MAX(C9_BLWMS) AS BLWMS FROM SC9010 WHERE SC9010.D_E_L_E_T_ = ' ' GROUP BY C9_FILIAL,C9_PEDIDO) AS XSC9 ON XSC9.C9_FILIAL = SC5.C5_FILIAL AND XSC9.C9_PEDIDO = SC5.C5_NUM "
cQuery += "WHERE SC5.D_E_L_E_T_ = ' ' "
nRet   := TCSQLEXEC(cQuery)
Return
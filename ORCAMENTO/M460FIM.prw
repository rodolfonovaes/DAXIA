#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
/*/{Protheus.doc}  M460FIM
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
User Function  M460FIM()

Reclock('SC5',.F.)
SC5->C5_XBLWMS  := SC9->C9_BLWMS
SC5->C5_BLEST   := SC9->C9_BLEST
SC5->C5_BLCRED  := SC9->C9_BLCRED
MsUnlock()

UpdLib()
Return 

 /*/{Protheus.doc} UpdLib()
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
Static Function UpdLib()
Local cQuery := ''
Local cAliasQry := GetNextAlias()
Local nValor := 0
Local aArea := GetArea()
Local nRecC5 := SC5->(Recno())

cQuery := "SELECT DISTINCT SC5.R_E_C_N_O_ AS REC"
cQuery += "  FROM " + RetSQLTab('SC9')
cQuery += "  INNER JOIN " + RetSQLTab('SC5') + " ON SC5.D_E_L_E_T_ = ' ' AND C5_NUM = C9_PEDIDO AND C5_FILIAL = C9_FILIAL "
cQuery += "  WHERE  "
cQuery += "  C9_CLIENTE = '"+ SC5->C5_CLIENTE + "'  AND C9_LOJA = '"+ SC5->C5_LOJACLI + "' "
cQuery += "  AND C9_BLCRED = '  ' AND SC9.D_E_L_E_T_ = ' '"

TcQuery cQuery new Alias ( cAliasQry )

(cAliasQry)->(dbGoTop())

While !(cAliasQry)->(EOF())
    SC5->(DbGoTo((cAliasQry)->REC))
    nValor += SC5->C5_XVLTOT
    (cAliasQry)->(dbSkip())
EndDo
(cAliasQry)->(DbCloseArea())


SA1->(DbSetOrder(1))
If SA1->(DbSeek(xFilial('SA1') + SC5->(C5_CLIENTE + C5_LOJACLI)))
    RecLock('SA1', .F.)
    SA1->A1_SALPEDL := nValor 
    MsUnlock()
EndIf
SC5->(DbGoTo(nRecC5))
RestArea(aArea)
Return 

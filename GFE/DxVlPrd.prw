 /*/{Protheus.doc} DxVlPrd
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
User Function DxVlPrd()
Local lTabCtr   := .F.
Local llRet     := .F.
Local lProdCtr  := .F.
Local cTransp   := M->CJ_XTRANSP
Local cProd     := M->CK_PRODUTO
Local cTabela   := M->CJ_XTBGFE
Local aArea     := GetArea()

If EMPTY(cTransp)
    RestArea(aArea)
    Return .T.
EndIF


SB5->(DbSetOrder(1))
If SB5->(DbSeek(xFilial('SB5') + cProd)) 
    If SB5->B5_XCONTRO == 'S'
        lProdCtr := .T.
    EndIf
    SA4->(DbSetOrder(1))
    If SA4->(DbSeek(xFilial('SA4') + cTransp))
        GU3->(DbSetOrder(11))
        If GU3->(DbSeek(xFilial('GU3') + SA4->A4_CGC))
            GVA->(DbSetOrder(1))
            If GVA->(DBSeek(xFilial('GVA') + GU3->GU3_CDEMIT + cTabela)) 
                While xFilial('GVA') + GU3->GU3_CDEMIT + cTabela == GVA->(GVA_FILIAL + GVA_CDEMIT + GVA_NRTAB)
                    If GVA->GVA_XCONTR == '1'
                        lTabCtr := .T.
                    EndIf
                    GVA->(DBSkip())
                EndDo
            EndIf
        EndIf
    EndIf

    If lTabCtr <> lProdCtr
        Alert('Transportadora/Tabela de frete incompatível com o produto escolhido, favor alterar para continuar.')
        lRet := .F.
    Else
        lRet := .T.
    EndIf        
EndIf

RestArea(aArea)
Return lRet

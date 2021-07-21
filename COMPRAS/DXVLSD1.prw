/*/{Protheus.doc} VlDtVld()
    Validação do campo D1_DTVALID
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
User Function VlDtVld()
Local lRet := .t.
Local nPosProd	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_COD"})
Local nPosFabr	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_DFABRIC"})
Local cProduto  := aCols[n][nPosProd]
Local dDtFabric := aCols[n][nPosFabr]

SB1->(DbSetOrder(1))
IF SB1->(DbSeek(xFilial('SB1') + cProduto))
    If M->D1_DTVALID <> SB1->B1_PRVALID +  dDtFabric
        lRet := .F.
        Alert('Não é permitido informar uma data diferente de ' + DTOC(SB1->B1_PRVALID +  dDtFabric))
    EndIf
EndIf

Return lRet

 /*/{Protheus.doc} VldF1Emiss
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
User Function VldF1Emi()
Local lRet := .T.

If cFormul == 'S' .and. ddemissao <> ddatabase
    lRet := .F.
    Alert('A data de emissão deve ser a data corrente.')
EndIf
Return lRet
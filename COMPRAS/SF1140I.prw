/*/{Protheus.doc} SF1140I
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
User Function SF1140I()
Local cMenNota := ''
Local aArea := GetArea()
Local cChave    := SF1->(F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA)

If PARAMIXB[1]
    SD1->(DbSetOrder(1))
    SD1->(DbSeek(xFilial('SD1') + cChave))
    Do While SD1->(!EOF()) .AND. cChave == SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
        If !Empty(SD1->D1_PEDIDO)
            SC7->(DbSetOrder(1))
            If SC7->(DbSeek(xFilial('SD1') + SD1->(D1_PEDIDO + D1_ITEMPC)))
                If !Alltrim(SC7->C7_OBSM) $ cMenNota
                    If !Empty(cMenNota)
                        cMenNota += ' | '
                    EndIf
                    cMenNota += Alltrim(SC7->C7_OBSM)
                EndIf
            EndIf
        EndIf    
        SD1->(DbSkip())
    EndDo
	RecLock('SF1',.F.)
	SF1->F1_MENNOTA := cMenNota
	MsUnlock()


EndIf
RestArea(aArea)
Return 


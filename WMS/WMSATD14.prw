/*/{Protheus.doc} WMSATD14()
    Utilizado para manipular D14 na segunda execução de serviços WMS
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
User Function WMSATD14()
Local nPosD14       := D14->(Recno())
Local nI            := 0
Local nQuant        := D14->D14_QTDEPR
Local nQtdeEp2      := D14->D14_QTDEP2
Local cEnder        := D14->D14_ENDER
Local aArea         := GetArea()
/*
If IsInCallStack('U_WMSA150U') .And. Len(_arrDCF) > 0
    D14->(DbSetOrder(3))
    For nI := 1 to Len(_arrDCF) - 1
        If cEnder == _arrDCF[nI,4]
            nQuant += _arrDCF[nI,2]
            nQtdeEp2 += _arrDCF[nI,3]
        EndIf
    Next

    D14->(DbGoTo(nPosD14))
    Reclock('D14',.F.)
    D14->D14_QTDEPR := nQuant
    D14->D14_QTDEP2 := nQtdeEp2
    MsUnlock()
EndIf
*/
RestArea(aArea)
Return
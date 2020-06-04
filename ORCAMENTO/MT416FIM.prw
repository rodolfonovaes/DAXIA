#Include "PROTHEUS.CH"

/*/{Protheus.doc} MT416FIM
    Usado para gravar os campos que não podem aparecer na tela
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
User Function MT416FIM()
Local aArea := GetArea()
Local nPerDsr := 0
/*
SCJ->(DbSetOrder(1))
If SCJ->(DbSeek(xFilial('SCJ') + SC5->C5_XNUMCJ))
    RecLock('SC5',.F.)
    MSMM(,200,,SCJ->CJ_XOBSPED,1,,,"SC5","C5_XOBSPED")
    MsUnlock()
EndIf
*/
DbSelectArea('SZD')
SZD->(Dbsetorder(1))
If SZD->(DbSeek(xFilial('SZD') + Alltrim(Str(year(dDatabase))) + PadL(Alltrim(STR(Month(dDataBase))),2,'0')))
    nPerDsr		:= SZD->ZD_PDSR / 100    
EndIf

DBselectarea('SC6')
SC6->(DbSetOrder(1))
If SC6->(DbSeek(xFilial('SC6') + SC5->C5_NUM))
    While SC6->(C6_FILIAL + C6_NUM) == SC5->(C5_FILIAL + C5_NUM)
        DBselectarea('SCK')
        SCK->(dbsetorder(3))//produto + pedido + item
        If SCK->(DbSeek(xFilial('SCK') + SC6->C6_PRODUTO + SC5->C5_XNUMCJ))
            RecLock('SC6',.F.)
            SC6->C6_XMOEDA := SCK->CK_MOEDA
            //SC6->C6_XCUSTD := 0//POSICIONE('DA1',1,xFilial('DA1') + SUPERGETMV('ES_DAXTAB',.T.,'001',cFilAnt)  + SC6->C6_PRODUTO , 'DA1_XCUSTD' )
            //SC6->C6_XRESULT := SCK->CK_XMGBRUT - (SCK->CK_COMIS1 * nPerDsr) - SCK->CK_COMIS1
            SC6->C6_NUMPCOM := SCK->CK_PEDCLI
            SC6->C6_ITEMPC := SCK->CK_ITECLI//SCK->CK_ITEMCLI
            //SC6->C6_XDSR    := 0 //nPerDsr
            MsUnlock()
        EndIf
        SC6->(DbSkip())
    EndDo
EndIf

RestArea(aArea)
Return
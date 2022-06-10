 /*/{Protheus.doc} MTValAvC
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
User Function MTValAvC
Local nRet := ParamIxb[2]

If ParamIxb[1] == 'MAAVALSC9' .And. ParamIxb[3] == 3
    SA1->(DbSetOrder(1))
    If SA1->(DbSeek(xFilial('SA1') + SC5->(C5_CLIENTE + C5_LOJACLI)))
        RecLock('SA1', .F.)
        SA1->A1_SALPEDL := 0 
        MsUnlock()

        nRet := SC5->C5_XVLTOT
    EndIf
EndIf
Return nRet

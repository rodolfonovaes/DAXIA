User Function MT121BRW()

	aAdd( aRotina  , {"Banco Conhec GCT"         , "U_DXCONHEC('MATA121')"    ,0,2,32, NIL})

Return(aRotina)


/*/{Protheus.doc} nomeFunction
    (long_description)
    @type  Function
    @author user
    @since 18/03/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function DXCONHEC(cRotina)
Local lAchou    := .F.

If cRotina == 'MATA121'
    CND->(DbSetOrder(7))
    If CND->(DbSeek(xFilial('CND') + SC7->(C7_CONTRA + C7_CONTREV + C7_MEDICAO)))
        MsDocument('CND',CND->(RECNO()), 4)
    Else
        Alert('Pedido de compras não oriundo de medição de contrato!')
    EndIf

ElseIf cRotina == 'FINA050'


    SD1->(DbSetOrder(1))
    If SD1->(DbSeek(xFilial('SD1') + SE2->(E2_NUM + E2_PREFIXO + E2_FORNECE + E2_LOJA)))
        While SE2->(E2_FILIAL+E2_NUM + E2_PREFIXO + E2_FORNECE + E2_LOJA) == SD1->(D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA) .And. !lAchou
            SC7->(dbSetOrder(1))
            If SC7->(DbSeek(xFilial('SC7') + SD1->D1_PEDIDO))
                CND->(DbSetOrder(7))
                If CND->(DbSeek(xFilial('CND') + SC7->(C7_CONTRA + C7_CONTREV + C7_MEDICAO)))
                    lAchou := .T.
                    MsDocument('CND',CND->(RECNO()), 4)
                EndIf   
                Exit             
            EndIF
            SD1->(DbSkip())
        EndDo
        If !lAchou
            Alert('Documento de entrada não oriundo de medição de contrato!')
        EndIf
    EndIf  

ElseIf cRotina == 'MATA103'
    SD1->(DbSetOrder(1))
    If SD1->(DbSeek(xFilial('SD1') + SF1->(F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA)))
        While SF1->(F1_FILIAL + F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA) == SD1->(D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA) .And. !lAchou
            SC7->(dbSetOrder(1))
            If SC7->(DbSeek(xFilial('SC7') + SD1->D1_PEDIDO))
                CND->(DbSetOrder(7))
                If CND->(DbSeek(xFilial('CND') + SC7->(C7_CONTRA + C7_CONTREV + C7_MEDICAO)))
                    lAchou := .T.
                    MsDocument('CND',CND->(RECNO()), 4)
                EndIf   
                Exit             
            EndIF
            SD1->(DbSkip())
        EndDo
        If !lAchou
            Alert('Documento de entrada não oriundo de medição de contrato!')
        EndIf
    EndIf    
EndIf
    
Return 

User Function MT121BRW()

	aAdd( aRotina  , {"*Conhecimento"         , "U_DXCONHEC('MATA121')"    ,0,3,32, NIL})

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

If cRotina == 'MATA121'
    CND->(DbSetOrder(7))
    If CND->(DbSeek(xFilial('CND') + SC7->(C7_CONTRA + C7_CONTREV + C7_MEDICAO)))
        MsDocument('CND',CND->(RECNO()), 4)
    Else
        Alert('Medição não encontrada!')
    EndIf

ElseIf cRotina == 'FINA050'
    CND->(DbSetOrder(7))
    If CND->(DbSeek(xFilial('CND') + SE2->(E2_MDCONTRA + E2_MDREVIS + E2_MDCRON)))
        MsDocument('CND',CND->(RECNO()), 4)
    Else
        Alert('Medição não encontrada!')
    EndIf
EndIf
    
Return 

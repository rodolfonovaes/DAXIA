#Include 'PROTHEUS.CH'
#Include 'RWMAKE.CH'
#Include 'topconn.ch'
#Include 'tbiconn.ch'
/*/{Protheus.doc} AjustaB8
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
User Function AjustaE1()
Local cQrySE1	:= ""
Local cAliasQry	:= GetNextAlias()
Local cQry	:= ""
Local cAliasQry2	:= GetNextAlias()
Local nTotal    := 0
Local nComis    := 0

If !MsgYesNo('Confirma atualização?')
    Return
EndIf
cQrySE1			:= ""
cQrySE1			:= " SELECT * FROM " + RetSqlName("SE1") + " SE1 "
cQrySE1			+= " WHERE "
cQrySE1			+= "       SE1.E1_FILIAL   = '" + xFilial("SE1") + "' "
cQrySE1			+= "   AND SE1.E1_PEDIDO  <> ' ' AND SE1.E1_COMIS1  = 0 "
cQrySE1			+= "   AND SE1.D_E_L_E_T_ = ' ' "
cQrySE1			:= ChangeQuery( cQrySE1 )

DbUseArea(.T., "TopConn", TCGenQry(, , cQrySE1 ), cAliasQry, .F., .F. )
DbSelectArea( cAliasQry )
( cAliasQry )->( DbGoTop() )
While ( cAliasQry )->( !Eof() )
    DbSelectArea("SD2")
    SD2->( DbSetOrder( 3 ) ) 
    If SD2->( DbSeek( xFilial("SD2") + ( cAliasQry )->E1_NUM  )) .And. ( cAliasQry )->E1_PEDIDO == SD2->D2_PEDIDO
        nTotal := 0
        nComis := 0
        While SD2->( !Eof() ) .AND. SD2->D2_FILIAL = ( cAliasQry )->E1_FILIAL .AND. ( cAliasQry )->E1_PEDIDO == SD2->D2_PEDIDO
            nTotal += SD2->D2_TOTAL                
            nComis += SD2->D2_TOTAL * SD2->D2_COMIS1
            SD2->(DbSkip())
        EndDo
        SE1->(DbSetOrder(1))
        If SE1->(DbSeek(xFilial('SE1') + ( cAliasQry )->E1_PREFIXO + ( cAliasQry )->E1_NUM ))
            While((xFilial('SE1') + ( cAliasQry )->E1_PREFIXO + ( cAliasQry )->E1_NUM ) == SE1->(E1_FILIAL + E1_PREFIXO + E1_NUM))
                If nComis > 0
                    Reclock('SE1')
                    SE1->E1_COMIS1 := nComis / nTotal
                    MsUnlock()
                EndIf
                SE1->(DbSkip())
            EndDo
        EndIf
    EndIf
    DbSelectArea( cAliasQry )
    ( cAliasQry )->( DbSkip() )
EndDo

MsgInfo('Processamento finalizado!')
Return 
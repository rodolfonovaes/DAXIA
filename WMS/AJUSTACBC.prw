#Include 'PROTHEUS.CH'
#Include 'RWMAKE.CH'
#Include 'topconn.ch'
#Include 'tbiconn.ch'
/*/{Protheus.doc} AjustaD14
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
User Function AjustaB7()
Local cQrySB7	:= ""
Local cAliasQry	:= GetNextAlias()
Local cQry	:= ""
Local cAliasQry2	:= GetNextAlias()
Local nAux          := 0
If !MsgYesNo('Confirma atualização?')
    Return
EndIf
cQrySB7			:= ""
cQrySB7			:= " SELECT SB7.* , R_E_C_N_O_ AS REC FROM " + RetSqlName("SB7") + " SB7 "
cQrySB7			+= " WHERE "
cQrySB7			+= "       SB7.B7_FILIAL   = '" + xFilial("SB7") + "' "
cQrySB7			+= "   AND SB7.B7_DATA   = '20201226' "
cQrySB7			+= "   AND SB7.B7_QUANT <> 0  "
cQrySB7			+= "   AND SB7.D_E_L_E_T_ = ' '  "
cQrySB7			:= ChangeQuery( cQrySB7 )

DbUseArea(.T., "TopConn", TCGenQry(, , cQrySB7 ), cAliasQry, .F., .F. )
DbSelectArea( cAliasQry )
( cAliasQry )->( DbGoTop() )
While (cAliasQry)->(!Eof())
    SB7->(DbGoTo(( cAliasQry )->REC))

    SB1->(DbSetOrder(1))
    IF SB1->(DbSeek(xFilial('SB1') + ( cAliasQry )->B7_COD))
        If SB1->B1_CONV > 0
            If SB1->B1_TIPCONV == 'D'
                If MOD(( cAliasQry )->B7_QUANT , SB1->B1_CONV) <> 0
                    nAux := ( cAliasQry )->B7_QUANT * SB1->B1_CONV
                    If RecLock("SB7", .F. )
                        SB7->B7_QUANT := nAux
                        SB7->B7_QTSEGUM := nAux / SB1->B1_CONV
                        SB7->( MsUnLock() )
                    EndIf                       
                EndIf              
            EndIf
        EndIf  
    EndIF
    DbSelectArea( cAliasQry )
    ( cAliasQry )->( DbSkip() )
EndDo

MsgInfo('Processamento finalizado!')
Return 1
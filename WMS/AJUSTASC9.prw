#Include 'PROTHEUS.CH'
#Include 'RWMAKE.CH'
#Include 'topconn.ch'
#Include 'tbiconn.ch'
/*/{Protheus.doc} AjustaSB5
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
User Function AjustaSC9()
Local cQrySC9	:= ""
Local cAliasQry	:= GetNextAlias()

If !MsgYesNo('Confirma atualização?')
    Return
EndIf
cQrySC9			:= ""
cQrySC9			:= " SELECT SC9.* FROM " + RetSqlName("SC9") + " SC9 "
cQrySC9			+= " WHERE SC9.D_E_L_E_T_ = ' ' AND C9_FILIAL  = '" + xFilial('SC9') + "' AND C9_BLEST = '02' AND C9_IDDCF <> '" + Space(TamSx3('C9_IDDCF')[1]) +  "' "
cQrySC9			:= ChangeQuery( cQrySC9 )

DbUseArea(.T., "TopConn", TCGenQry(, , cQrySC9 ), cAliasQry, .F., .F. )
DbSelectArea( cAliasQry )
( cAliasQry )->( DbGoTop() )
While ( cAliasQry )->( !Eof() )
    SC9->(DbGoTo(( cAliasQry )->R_E_C_N_O_))
    If RecLock("SC9", .F. )
        If !Empty(( cAliasQry )->C9_NFISCAL)
            SC9->C9_BLEST := '10'            
        Else
            SC9->C9_BLEST := '  '            
        ENdIf
        SC9->( MsUnLock() )
    ENdIf
    DbSelectArea( cAliasQry )
    ( cAliasQry )->( DbSkip() )
EndDo

MsgInfo('Processamento finalizado!')
Return 

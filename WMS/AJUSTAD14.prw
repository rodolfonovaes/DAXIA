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
User Function AjustaD14()
Local cQrySB8	:= ""
Local cAliasQry	:= GetNextAlias()
Local cQry	:= ""
Local cAliasQry2	:= GetNextAlias()
Local cLocQual	:= Supergetmv('MV_CQ',.T.,'98')
If !MsgYesNo('Confirma atualização?')
    Return
EndIf
cQrySB8			:= ""
cQrySB8			:= " SELECT SB8.* ,D14.R_E_C_N_O_ AS REC FROM " + RetSqlName("SB8") + " SB8 "
cQrySB8			+= " INNER JOIN " + RetSqlName("D14") + " D14 ON D14_LOCAL = B8_LOCAL AND B8_PRODUTO = D14_PRODUT AND D14_LOTECT = B8_LOTECTL AND D14.D_E_L_E_T_ = ' ' "
cQrySB8			+= " WHERE "
cQrySB8			+= "       SB8.B8_FILIAL   = '" + xFilial("SB8") + "' "
cQrySB8			+= "   AND D14.D14_FILIAL   = '" + xFilial("D14") + "' "
cQrySB8			+= "   AND SB8.D_E_L_E_T_ = ' ' "
cQrySB8			:= ChangeQuery( cQrySB8 )

DbUseArea(.T., "TopConn", TCGenQry(, , cQrySB8 ), cAliasQry, .F., .F. )
DbSelectArea( cAliasQry )
( cAliasQry )->( DbGoTop() )
While ( cAliasQry )->( !Eof() )
    D14->(DbGoTo(( cAliasQry )->REC))
    If RecLock("D14", .F. )
        D14->D14_DTFABR := STOD(( cAliasQry )->B8_DFABRIC)
        D14->D14_DTVALD:= STOD(( cAliasQry )->B8_DTVALID)
        D14->( MsUnLock() )
    EndIf                
    DbSelectArea( cAliasQry )
    ( cAliasQry )->( DbSkip() )
EndDo

MsgInfo('Processamento finalizado!')
Return 
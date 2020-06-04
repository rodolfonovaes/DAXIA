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
User Function AjustaSB5()
Local cQrySB5	:= ""
Local cAliasQry	:= GetNextAlias()

If !MsgYesNo('Confirma atualização?')
    Return
EndIf
cQrySB5			:= ""
cQrySB5			:= " SELECT DISTINCT SB5.* FROM " + RetSqlName("SB5") + " SB5 "
cQrySB5			+= " INNER JOIN " + RetSqlName("SG1") + " SG1 ON G1_FILIAL = '0103' AND G1_COD = B5_COD  AND SG1.D_E_L_E_T_ = ' ' "
cQrySB5			+= " WHERE SB5.D_E_L_E_T_ = ' ' "
cQrySB5			:= ChangeQuery( cQrySB5 )

DbUseArea(.T., "TopConn", TCGenQry(, , cQrySB5 ), cAliasQry, .F., .F. )
DbSelectArea( cAliasQry )
( cAliasQry )->( DbGoTop() )
While ( cAliasQry )->( !Eof() )
    If ( cAliasQry )->B5_SERVENT = '005'
        SB5->(DbGoTo(( cAliasQry )->R_E_C_N_O_))
        If RecLock("SB5", .F. )
            SB5->B5_SERVENT := '003'
            SB5->( MsUnLock() )
        ENdIf
    ENdIf
   
    DbSelectArea( cAliasQry )
    ( cAliasQry )->( DbSkip() )
EndDo

MsgInfo('Processamento finalizado!')
Return 
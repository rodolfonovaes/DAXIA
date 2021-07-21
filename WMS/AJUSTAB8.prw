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
User Function AjustaB8()
Local cQrySB8	:= ""
Local cAliasQry	:= GetNextAlias()
Local cQry	:= ""
Local cAliasQry2	:= GetNextAlias()
Local cLocQual	:= Supergetmv('MV_CQ',.T.,'98')
If !MsgYesNo('Confirma atualização?')
    Return
EndIf
cQrySB8			:= ""
cQrySB8			:= " SELECT * FROM " + RetSqlName("SB8") + " SB8 "
cQrySB8			+= " WHERE "
cQrySB8			+= "       SB8.B8_FILIAL   = '" + xFilial("SB8") + "' "
cQrySB8			+= "   AND SB8.B8_LOTEFOR  <> ' ' "
cQrySB8			+= "   AND SB8.B8_LOCAL    = '"+ cLocQual + "' "
cQrySB8			+= "   AND SB8.D_E_L_E_T_ = ' ' "
cQrySB8			:= ChangeQuery( cQrySB8 )

DbUseArea(.T., "TopConn", TCGenQry(, , cQrySB8 ), cAliasQry, .F., .F. )
DbSelectArea( cAliasQry )
( cAliasQry )->( DbGoTop() )
While ( cAliasQry )->( !Eof() )
    DbSelectArea("SB8")
    SB8->( DbSetOrder( 7 ) ) 
    If SB8->( DbSeek( xFilial("SB8") + ( cAliasQry )->B8_PRODUTO + ( cAliasQry )->B8_LOTECTL ) )
        While SB8->( !Eof() ) .AND. SB8->B8_FILIAL = ( cAliasQry )->B8_FILIAL .AND. SB8->B8_PRODUTO = ( cAliasQry )->B8_PRODUTO .AND. SB8->B8_LOTECTL = ( cAliasQry )->B8_LOTECTL    
            If SB8->B8_LOCAL <> '98' .And. Empty(SB8->B8_LOTEFOR)
				If RecLock("SB8", .F. )
					SB8->B8_LOTEFOR := ( cAliasQry )->B8_LOTEFOR
					SB8->( MsUnLock() )
				EndIf                
            EndIf
            SB8->(DbSkip())
        EndDo
    EndIf
    DbSelectArea( cAliasQry )
    ( cAliasQry )->( DbSkip() )
EndDo

MsgInfo('Processamento finalizado!')
Return 
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
User Function CPYD1B8()
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
cQrySB8			+= "   AND SB8.B8_XCFABRI  = ' ' "
cQrySB8			+= "   AND SB8.B8_LOCAL    = '"+ cLocQual + "' "
cQrySB8			+= "   AND SB8.D_E_L_E_T_ = ' ' "
cQrySB8			:= ChangeQuery( cQrySB8 )

DbUseArea(.T., "TopConn", TCGenQry(, , cQrySB8 ), cAliasQry, .F., .F. )
DbSelectArea( cAliasQry )
( cAliasQry )->( DbGoTop() )
While ( cAliasQry )->( !Eof() )
    SD1->( DbSetOrder( 1 ) ) 
    If SD1->( DbSeek( xFilial("SB8") + ( cAliasQry )->B8_DOC + ( cAliasQry )->B8_SERIE + ( cAliasQry )->B8_CLIFOR+( cAliasQry )->B8_LOJA+( cAliasQry )->B8_PRODUTO ) ) ;
        .And. SD1->D1_LOTECTL == ( cAliasQry )->B8_LOTECTL
        SA2->(DbSetOrder(1))
        If SA2->(dbSeek(xFilial("SA2")+SD1->D1_XCFABRI+SD1->D1_XLFABRI))
            SB8->(DbGoTo(( cAliasQry )->R_E_C_N_O_))
            If RecLock("SB8", .F. )
                REPLACE SB8->B8_XCFABRI WITH SD1->D1_XCFABRI
                REPLACE SB8->B8_XLFABRI WITH SD1->D1_XLFABRI
                REPLACE SB8->B8_NFABRIC WITH SA2->A2_NOME 
                REPLACE SB8->B8_XPAISOR WITH SA2->A2_PAISORI
                SB8->( MsUnLock() )
            EndIf      
        EndIf          
    EndIf
    DbSelectArea( cAliasQry )
    ( cAliasQry )->( DbSkip() )
EndDo

MsgInfo('Processamento finalizado!')
Return 
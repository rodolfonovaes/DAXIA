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
User Function UPDTEL()
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
cQrySE1			:= " SELECT A1_TEL, R_E_C_N_O_ AS REC FROM " + RetSqlName("SA1") + " SA1 "
cQrySE1			+= " WHERE "
cQrySE1			+= "       A1_TEL   LIKE '%/' "
cQrySE1			+= "   AND SA1.D_E_L_E_T_ = ' ' "
cQrySE1			:= ChangeQuery( cQrySE1 )

DbUseArea(.T., "TopConn", TCGenQry(, , cQrySE1 ), cAliasQry, .F., .F. )
DbSelectArea( cAliasQry )
( cAliasQry )->( DbGoTop() )
While ( cAliasQry )->( !Eof() )
    SA1->(DbGoTo(( cAliasQry )->REC))
    RecLock('SA1', .F.)
    SA1->A1_TEL := SUBSTR(SA1->A1_TEL,1,LEN(Alltrim(SA1->A1_TEL)) - 1 )        
    MsUnlock()
    
    DbSelectArea( cAliasQry )
    ( cAliasQry )->( DbSkip() )
EndDo

MsgInfo('Processamento finalizado!')
Return 

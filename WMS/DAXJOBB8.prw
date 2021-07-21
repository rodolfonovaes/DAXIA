#Include 'PROTHEUS.CH'
#Include 'RWMAKE.CH'
#Include 'topconn.ch'
#Include 'tbiconn.ch'
/*/{Protheus.doc} DAXJOBB8
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
User Function DAXJOBB8(aFilial)
Local cQrySB8	:= ""
Local cAliasQry	:= ''
Local cQry	:= ""
Local cAliasQry2	:= ''
Local cLocQual	:= ''
Local nCount    := 0
Local nAtu      := 0
Local nErro      := 0
PRIVATE cEmpProc	:= '01'
PRIVATE cFilProc	:= aFilial[2]

If Select("SX2") == 0
	//Preparando o ambiente
	RPCSetType(3)
	CONOUT('DAXJOBB8 - Empresa ' + cEmpProc + '/ Filial '+ cFilProc)

	RPCSetEnv(cEmpProc, cFilProc, "", "", "")
EndIf
cLocQual	:= Supergetmv('MV_CQ',.T.,'98')
cAliasQry	:= GetNextAlias()
cAliasQry2	:= GetNextAlias()
cQrySB8			:= ""
cQrySB8			:= " SELECT * FROM " + RetSqlName("SB8") + " SB8 "
cQrySB8			+= " WHERE "
cQrySB8			+= "       SB8.B8_FILIAL   = '" + xFilial("SB8") + "' "
cQrySB8			+= "   AND SB8.B8_XCFABRI  <> ' ' "
cQrySB8			+= "   AND SB8.B8_LOCAL    = '"+ cLocQual + "' "
cQrySB8			+= "   AND SB8.D_E_L_E_T_ = ' ' "
cQrySB8			:= ChangeQuery( cQrySB8 )

CONOUT('DAXJOBB8 - QUERY ' + cQrySB8)

DbUseArea(.T., "TopConn", TCGenQry(, , cQrySB8 ), cAliasQry, .F., .F. )
DbSelectArea( cAliasQry )
( cAliasQry )->( DbGoTop() )
While ( cAliasQry )->( !Eof() )
    nCount ++
    DbSelectArea("SB8")
    SB8->( DbSetOrder( 7 ) ) 
    If SB8->( DbSeek( xFilial("SB8") + ( cAliasQry )->B8_PRODUTO + ( cAliasQry )->B8_LOTECTL ) )
        While SB8->( !Eof() ) .AND. SB8->B8_FILIAL = ( cAliasQry )->B8_FILIAL .AND. SB8->B8_PRODUTO = ( cAliasQry )->B8_PRODUTO .AND. SB8->B8_LOTECTL = ( cAliasQry )->B8_LOTECTL    
            If SB8->B8_LOCAL <> '98'
				If RecLock("SB8", .F. )
					SB8->B8_NFABRIC := ( cAliasQry )->B8_NFABRIC
					SB8->B8_XPAISOR	:= ( cAliasQry )->B8_XPAISOR
					SB8->B8_CLIFOR	:= ( cAliasQry )->B8_CLIFOR
					SB8->B8_LOJA	:= ( cAliasQry )->B8_LOJA
					SB8->B8_XCFABRI	:= ( cAliasQry )->B8_XCFABRI
					SB8->B8_XLFABRI	:= ( cAliasQry )->B8_XLFABRI
                    SB8->B8_LOTEFOR	:= ( cAliasQry )->B8_LOTEFOR
					SB8->( MsUnLock() )
				EndIf         
                nAtu++       
            EndIf
            SB8->(DbSkip())
        EndDo
    ELSE
        nErro++
    EndIf
    DbSelectArea( cAliasQry )
    ( cAliasQry )->( DbSkip() )
EndDo

CONOUT('DAXJOBB8 - Fim da execução  Lidos - ' + Alltrim(Str(nCount)) + ' - gravados - ' + Alltrim(Str(nAtu)) + ' Erro - ' + Alltrim(Str(nErro)))
Return 
#Include 'PROTHEUS.CH'
#Include 'RWMAKE.CH'
#Include 'topconn.ch'
#Include 'tbiconn.ch'
//------------------------------------------------------------------------------------//
//Empresa...: TIB - IBIRAPUERA
//Projeto...: Ponto de Entrada - Operação após Liberar / Rejeitar WMS
//Funcao....: Q215FIM
//Autor.....: DANIEL EVANDRO BUSO
//Data......: 10/10/2019
//Uso.......: Gravar informações nos campos da tabela SB8 - B8_NFABRIC / B8_XPAISOR
//Versao....: 12
//------------------------------------------------------------------------------------//
USER FUNCTION Q215FIM()	

	Local lRet		:= .T.
	
	Local _cQUpd	:= ""
	Local _nStatus	:= 0
	Local cLocal	:= '01'
	Local cLocQual	:= Supergetmv('MV_CQ',.T.,'98')
	Local cProd		:= PARAMIXB[1]	
	Local cRevpr	:= PARAMIXB[2]
	Local cForn		:= PARAMIXB[3]
	Local cLjFor	:= PARAMIXB[4]
	Local cDtent	:= DTOS( PARAMIXB[5] )
	Local cLote		:= PARAMIXB[6]
	Local cNtFis	:= PARAMIXB[7]	
	Local cSerNF	:= PARAMIXB[8]	
	Local cItNF		:= PARAMIXB[9]
	Local cTpNF		:= PARAMIXB[10]	
	Local cOpc		:= PARAMIXB[11]	
	Local nRecAux	:= 0
	Local cQrySB8	:= ""
	Local cAliasQry	:= GetNextAlias()
	Local cLocPad	:= Posicione('SB1',1,xFilial('SB1') + cProd ,'B1_LOCPAD')
	Local cQry	:= ""
	Local cAliasQry2	:= GetNextAlias()
	
	cQrySB8			:= ""
	cQrySB8			:= " SELECT * FROM " + RetSqlName("SB8") + " SB8 "
	cQrySB8			+= " WHERE "
	cQrySB8			+= "       SB8.B8_FILIAL   = '" + xFilial("SB8") + "' "
	cQrySB8			+= "   AND SB8.B8_PRODUTO  = '" + cProd + "' "
	cQrySB8			+= "   AND SB8.B8_LOTECTL  = '" + cLote + "' "
	cQrySB8			+= "   AND SB8.B8_LOCAL    = '"+ cLocQual + "' "
	cQrySB8			+= "   AND SB8.D_E_L_E_T_ = ' ' "
	cQrySB8			:= ChangeQuery( cQrySB8 )
	//MemoWrite("\SYSTEM\QUERY\Q215FIM.SQL", ccQrySB8 )

	DbUseArea(.T., "TopConn", TCGenQry(, , cQrySB8 ), cAliasQry, .F., .F. )
	DbSelectArea( cAliasQry )
	( cAliasQry )->( DbGoTop() )
	While ( cAliasQry )->( !Eof() )
		DbSelectArea("SB8")
		SB8->( DbSetOrder( 3 ) ) 
		If SB8->( DbSeek( xFilial("SB8") + ( cAliasQry )->B8_PRODUTO + cLocPad + ( cAliasQry )->B8_LOTECTL ) )
			While SB8->( !Eof() ) .AND. SB8->B8_FILIAL = ( cAliasQry )->B8_FILIAL .AND. SB8->B8_PRODUTO = ( cAliasQry )->B8_PRODUTO .AND. SB8->B8_LOTECTL = ( cAliasQry )->B8_LOTECTL
				If RecLock("SB8", .F. )
					SB8->B8_NFABRIC := ( cAliasQry )->B8_NFABRIC
					SB8->B8_XPAISOR	:= ( cAliasQry )->B8_XPAISOR
					SB8->B8_CLIFOR	:= ( cAliasQry )->B8_CLIFOR
					SB8->B8_LOJA	:= ( cAliasQry )->B8_LOJA
					SB8->B8_XCFABRI	:= ( cAliasQry )->B8_XCFABRI
					SB8->B8_XLFABRI	:= ( cAliasQry )->B8_XLFABRI
					SB8->( MsUnLock() )
				EndIf

				nRecAux := SB8->(Recno())

				//vejo se existe B8 no armazem 01
			/*	cQry			:= ""
				cQry			:= " SELECT R_E_C_N_O_ AS REC FROM " + RetSqlName("SB8") + " SB8 "
				cQry			+= " WHERE "
				cQry			+= "       SB8.B8_FILIAL   = '" + xFilial("SB8") + "' "
				cQry			+= "   AND SB8.B8_LOCAL    = '" + cLocPad + "' "
				cQry			+= "   AND SB8.B8_PRODUTO  = '" + cProd + "' "
				cQry			+= "   AND SB8.B8_LOTECTL  = '" + cLote + "' "
				cQry			+= "   AND SB8.D_E_L_E_T_ = ' ' "
				cQry			:= ChangeQuery( cQry )
				//MemoWrite("\SYSTEM\QUERY\Q215FIM.SQL", ccQrySB8 )

				DbUseArea(.T., "TopConn", TCGenQry(, , cQry ), cAliasQry2, .F., .F. )
				DbSelectArea( cAliasQry2 )
				( cAliasQry2 )->( DbGoTop() )
				While ( cAliasQry2 )->( !Eof() )
					SB8->(DbGoTo(( cAliasQry2 )->REC))
					RecLock('SB8',.F.)
					SB8->B8_NFABRIC := ( cAliasQry )->B8_NFABRIC
					SB8->B8_XPAISOR	:= ( cAliasQry )->B8_XPAISOR
					SB8->B8_CLIFOR	:= ( cAliasQry )->B8_CLIFOR
					SB8->B8_LOJA	:= ( cAliasQry )->B8_LOJA
					SB8->B8_XCFABRI	:= ( cAliasQry )->B8_XCFABRI
					SB8->B8_XLFABRI	:= ( cAliasQry )->B8_XLFABRI
					SB8->( MsUnLock() )

					( cAliasQry2 )->(DbSkip())
				EndDo

				( cAliasQry2 )->(DbCloseArea())

				
				SB8->(DbGoTo(nRecAux))*/

				SB8->( DbSkip() )
			EndDo
		EndIf
		DbSelectArea( cAliasQry )
		( cAliasQry )->( DbSkip() )
	EndDo

	DbSelectArea( cAliasQry )
	( cAliasQry )->( DbCloseArea() )
		  
Return( lRet )
#Include 'PROTHEUS.CH'
#Include 'FWMVCDEF.CH'
#Include 'RWMAKE.CH'
#Include 'FONT.CH'
#Include 'COLORS.CH'
#Include 'TBICONN.CH'
#Include "topconn.ch"
#Include "fileio.ch"
/*======================================================================================+
| Programa............:   MT103FIM.prw                                                  |
| Autores ............:   daniel.buso@totvs.com.br                            			|
| Data................:   22/10/2019                                                    |
| Descricao / Objetivo:   Ponto de entrada para alimentar informaÃ§Ãµeses na tabela SB8   |
|                         SB8->NFABRIC e SB8->XPAISOR a partir do documento de entrada  |
| Doc. Origem.........:                                                                 |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:   Ponto de entrada aplicado em ambiente produÃ§Ã£o - 04/11/2019   |
+======================================================================================*/
User Function MT103FIM()

Local aArea 	:= GetArea()
Local _Opcao 	:= Paramixb[1]
Local nConfirma := Paramixb[2] // Se o usuario confirmou a operaï¿½ï¿½o de gravaï¿½ï¿½o da NFE
Local cChave 	:= SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
Local cChaveK   := QEK->( QEK_FILIAL + QEK_FORNEC + QEK_LOJFOR + QEK_NTFISC + QEK_SERINF + QEK_ITEMNF )
Local lOk		:= .F.

If SF1->F1_TIPO == 'D'
	dbSelectArea("SA1")
	dbSetOrder( 1 )
	If  SA1->(dbSeek(xFilial("SA1")+SF1->(F1_FORNECE + F1_LOJA)))
		RecLock('SF1',.F.)
		SF1->F1_XNOMFOR := SA1->A1_NOME
		MsUnlock()
	EndIf
Else
	dbSelectArea("SA2")
	dbSetOrder( 1 )
	If  SA2->(dbSeek(xFilial("SA2")+SF1->(F1_FORNECE + F1_LOJA)))
		RecLock('SF1',.F.)
		SF1->F1_XNOMFOR := SA2->A2_NOME
		MsUnlock()
	EndIf
EndIf
if nConfirma == 1
	lMT100TOK := .F.
	
	If SF1->F1_TIPO == 'N' .AND. ("SD1")->D1_DOC <> ""
		dbSelectArea("SF4")
		dbSetOrder(01)
		dbSeek(xFilial("SF4")+SD1->D1_TES)
		
		IF SF4->F4_ESTOQUE == "S"
	        //TABELA SB8	
			dbSelectArea("SB8")
			dbSetOrder(05) 
			
			Do While SD1->(!EOF()) .AND. cChave == SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
				
				If !SB8->(dbSeek(xFilial("SB8")+SD1->D1_COD+SD1->D1_LOTECTL))
					Alert("Lote nao encontrado na Tabela SB8")
					GravaLog('Lote nao encontrado na Tabela SB8')
					lOk := .F.
				Else
				
					dbSelectArea("SA2")
					dbSetOrder( 1 )
					
					If !Empty(SD1->D1_XCFABRI) .And. SA2->(dbSeek(xFilial("SA2")+SD1->D1_XCFABRI+SD1->D1_XLFABRI))
			     		RecLock("SB8",.F.)
				    	REPLACE SB8->B8_XCFABRI WITH SD1->D1_XCFABRI
			    		REPLACE SB8->B8_XLFABRI WITH SD1->D1_XLFABRI
						REPLACE SB8->B8_NFABRIC WITH SA2->A2_NOME 
						REPLACE SB8->B8_XPAISOR WITH SA2->A2_PAISORI
		     			SB8->( MsUnlock() )
		     			
                        DbSelectArea( "QEK" )
                        DbSetOrder( 6 )  // QEK_FILIAL + QEK_LOTE
                        If QEK->( DbSeek( xFilial( "QEK" ) + SB8->B8_LOTECTL ) )
  			     	       RecLock("QEK",.F.)
					       REPLACE QEK->QEK_XNFABR WITH SA2->A2_NOME
                           QEK->( MsUnlock() )
						Else
							Alert("Registro da QEK não encontrado!")
							lOk := .F.
                        EndIf
						lOk := .T.
					Else
						GravaLog('D1_XCFABRI em branco ou não encontrou na SA2')
						lOk := .F.
					Endif

			
				EndIf
			
				SD1->(DBSKIP())
			
			ENDDO
		Else
			GravaLog('Tes Não atualiza estoque')
		Endif
	
	Endif
	If lOk
		MsgInfo('Dados atualizados com sucesso!')
	Else
		MsgInfo('Um ou mais registros nao foram atualizados!')
	EndIf
	RestArea(aArea)
	
Endif

Return()	

/*/{Protheus.doc} GravaLog
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
Static Function GravaLog(cObs)
RecLock('SZJ',.T.)
SZJ->ZJ_FILIAL := xFilial('SZJ')
SZJ->ZJ_DOC		:= SD1->D1_DOC
SZJ->ZJ_COD		:= SD1->D1_COD
SZJ->ZJ_DATA	:= dDataBase
SZJ->ZJ_HORA	:= Left(Time(),5)
SZJ->ZJ_OBS		:= cObs	
MsUnlock()
Return 
#Include 'Protheus.ch'
#Include 'topconn.ch'
#Include 'tbiconn.ch'

/*======================================================================================+
| Programa............:   MTGRVLOT.prw                                                  |
| Autores ............:   daniel.buso@totvs.com.br                            			|
| Data................:   22/10/2019                                                    |
| Descricao / Objetivo:   Ponto de entrada para alimentar informaçõeses na tabela SB8   |
|                         SB8->NFABRIC e SB8->XPAISOR - TROCA DE LOTE                   |
| Doc. Origem.........:                                                                 |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:   Ponto de entrada aplicado em ambiente produção - 04/11/2019   |
+======================================================================================*/
User Function MTGRVLOT()
Local aAreaSB8	:= GetArea()
Local cChaveD0B := D0B->( D0B_FILIAL + D0B_PRODUT + D0B_LOCAL )
Local cChaveSB8 := SB8->(  B8_FILIAL + B8_PRODUTO + B8_LOCAL  )
Local xRet 		:= .T.
Local cNFABRIC  := "" 
Local cXPAISOR  := ""
Local cXCfabri  := ""
Local cXLfabri  := ""
Local cCliFor   := ""
Local cLoja     := "" 

			dbSelectArea('SB8')
			dbSetOrder(3) //B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL+B8_NUMLOTE+DTOS(B8_DTVALID) -> Vide tabela SIX
		
			If SB8->(msSeek(cChaveD0B))
		
				While SB8->(!Eof()) .And. SB8->(B8_FILIAL+B8_PRODUTO+B8_LOCAL) == cChaveD0B
		
					If !Empty(SB8->B8_NFABRIC)
						cNFABRIC := SB8->B8_NFABRIC
					EndIf
		
					If !Empty(SB8->B8_XPAISOR)
						cXPAISOR := SB8->B8_XPAISOR
					Endif
					
					If !Empty(SB8->B8_XCFABRI)
						cXCfabri := SB8->B8_XCFABRI
					Endif
					
					If !Empty(SB8->B8_XLFABRI)
						cXLfabri := SB8->B8_XLFABRI
					Endif
					
					If !Empty(SB8->B8_CLIFOR)
						cCliFor := SB8->B8_CLIFOR
					Endif
					
					If !Empty(SB8->B8_LOJA)
						cLoja := SB8->B8_LOJA
					Endif
										
					SB8->(dbSkip())
		
				EndDo
		
				//Restaura a area anterior, por causa de desposicionamento
				RestArea(aAreaSB8)
		
			EndIf
		
			dbSelectArea('SB8')
			dbSetOrder(3) //B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL+B8_NUMLOTE+DTOS(B8_DTVALID) -> Vide tabela SIX
			
			If SB8->(msSeek(cChaveD0B))
				
				While SB8->(!Eof()) .And. SB8->(B8_FILIAL+B8_PRODUTO+B8_LOCAL) == cChaveD0B
				
					If Empty(SB8->B8_NFABRIC) .Or. Empty(SB8->B8_XPAISOR)
						
						dbSelectArea('SB8')
						SB8->(RecLock('SB8',.F.))
						
						If Empty(SB8->B8_NFABRIC) .And. !Empty(cNFABRIC)
							SB8->B8_NFABRIC := cNFABRIC
						EndIf
						
						If Empty(SB8->B8_XPAISOR) .And. !Empty(cXPAISOR)
							SB8->B8_XPAISOR := cXPAISOR
						EndIf
						
						If Empty(SB8->B8_XCFABRI) .And. !Empty(cXCfabri)
							SB8->B8_XCFABRI := cXCfabri
						EndIf	
						
						If Empty(SB8->B8_XLFABRI) .And. !Empty(cXLfabri)
							SB8->B8_XLFABRI := cXLfabri
						EndIf											

						If Empty(SB8->B8_CLIFOR) .And. !Empty(cCLIFOR)
							SB8->B8_CLIFOR := cCLIFOR
						EndIf	

						If Empty(SB8->B8_LOJA) .And. !Empty(cLOJA)
							SB8->B8_LOJA := cLOJA
						EndIf	

						SB8->(MSUnlock())
					EndIf
				
					SB8->(dbSkip())

				EndDo
				
				//Restaura a area anterior, por causa de desposicionamento
				RestArea(aAreaSB8)
			
			EndIf
		
RestArea(aAreaSB8)

Return(xRet)


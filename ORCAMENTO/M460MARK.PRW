#INCLUDE 'RwMake.ch'
#INCLUDE 'Protheus.ch'
#INCLUDE 'TopConn.ch'
 
//Constantes
#DEFINE STR_PULA        Chr(13)+Chr(10)
 
/*------------------------------------------------------------------------------------------------------*
 | P.E.:  M460MARK                                                                                      |
 | Desc:  Permite usu�rio marcar registros para faturar somente se passar na valida��o                  |
 | Links: http://tdn.totvs.com/pages/releaseview.action�pageId=6784189                                  |
 *------------------------------------------------------------------------------------------------------*/
  
USER FUNCTION M460MARK()

    LOCAL aArea        	:= GetArea()
    LOCAL aAreaC9    	:= SC9->( GetArea() )
    LOCAL aAreaC5    	:= SC5->( GetArea() )
	LOCAL lRet			:= .F.
	Local cSegSepara	 := SuperGetMV('ES_SERVSEP',.T.,'025',cFilAnt)

	dbSelectArea("SC9")
	bCound := { || ((C9_OK != PARAMIXB[1] .And. PARAMIXB[2]) .Or.;
				(C9_OK == PARAMIXB[1] .And. !PARAMIXB[2])) }

	dbGoTop()
	//ProcRegua(RecCount())
	WHILE !Eof()
		IF Eval(bCound) 
			dbSelectArea("SC5")
			dbSetOrder(1)
			dbSeek(cFilAnt+SC9->C9_PEDIDO)
			bCound1 := {|| !SC9->(Eof()) .and. SC9->C9_FILIAL == cFilAnt .and. SC9->C9_PEDIDO == SC5->C5_NUM }
			WHILE Eval(bCound1)
				If SC9->C9_SERVIC == cSegSepara
					MsgInfo('Segunda Separa��o!')
					Reclock('SC9',.F.)
					SC9->C9_BLEST := 'XX'
					MsUnlock()
				EndIf
				lRet := U_DAXVNOTA(SC9->C9_PEDIDO, SC9->C9_PRODUTO)
				//cPedido := SC5->C5_NUM
				//cMsgP := "Pedido (" + cPedido + ") posicionado!"
				//Help( , , 'M460MARK (001)', , cMsgP, 1, 0 )
				DbSelectArea("SC9")
				DbSkip()
			ENDDO
		ENDIF
		DbSelectArea("SC9")
		DbSkip()
	ENDDO

	RestArea(aAreaC5)
    RestArea(aAreaC9)
    RestArea(aArea)

RETURN lRet

/*/
{Protheus.doc} DAXVNOTA

@type function
Valida��o Policia Civil, Policia Federal e Ex�rcito

@author 	Cicero Cruz
@since 		06/08/2019
@version 	P12.1.23
 
@param  NULL
@return NULL
*/ 
User FUNCTION DAXVNOTA(cPedido, cProduto)
LOCAL _lRet 	:= .T.
LOCAL cFilSC6 	:= xFilial("SC6")

DBSELECTAREA("SC6")
DBSETORDER( 1 )
 
IF DBSEEK(xFilial("SC6")+cPedido)
	WHILE !SC6->(Eof()) .And. cFilSC6 == SC6->C6_FILIAL .And. SC6->C6_NUM == cPedido
		IF cProduto == SC6->C6_PRODUTO
		//	cMsgP := "Pedido (" + cPedido + ") e (" + cProduto + ") posicionados!"
		//	Help( , , 'M460MARK (001)', , cMsgP, 1, 0 )	
			_dEntreg := dDatabase // COMO ESTOU GERANDO A NF VALIDO COM A DATABASE
			_nQuant  := SC6->C6_QTDVEN
			SB5->(DBSETORDER(1))
			IF SB5->(DBSEEK(XFILIAL("SB5")+cProduto))
				_lPerigo := ( SB5->B5_PRODPF == "S" /*.OR. SB5->B5_PRODCON == "S"*/ .OR. SB5->B5_PRODEX == "S" ) // VERIFICO SE O PRODUTO � PERIGOSO!
				
				IF _lPerigo
					DBSELECTAREA("Z00")
					// TRATAMENTO PRODUTO PERIGOSO - CONTROLE POLICIA FEDERAL
					IF SB5->B5_PRODPF  == "S" 
						
						IF SB5->B5_YVLLPF < _dEntreg
							cMsgP := "N�o � permitido vender o produto " + ALLTRIM(cProduto) + " pois a DAXIA est� com a Lice�a Vencida."
							cMsgS := "Inicie o processo de Licenciamento do Produto: ("+ ALLTRIM(cProduto) +")."
							Help( ,, 'M460MARK (001)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
							_lRet := .F.
						ENDIF

						// VERIFICAR CADASTRO DO CLIENTE
						IF _lRet
							DBSELECTAREA("AI0")
							DbSetOrder(1) //AI0_FILIAL + AI0_CODCLI + AI0_LOJA
							IF AI0->( DbSeek( xFilial("AI0")+ SC5->C5_CLIENTE+SC5->C5_LOJACLI ))
								IF !( AI0->AI0_YPROPF == "S" )
									cMsgP := "N�o � permitido vender o Produto (" + ALLTRIM(cProduto) + "), pois o cliente n�o possui licen�a."
									cMsgS := "Verifique se o cliente possui Licen�a e providencie o cadastro da mesma."
									Help( ,, 'M460MARK (004)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
									_lRet := .F.
								ENDIF
								IF _lRet .AND. AI0->AI0_YVLLPF < _dEntreg
									cMsgP := "N�o � permitido vender o produto " + ALLTRIM(cProduto) + " pois a Licen�a do Cliente est� Vencida na Data da Entrega."
									cMsgS := "Solicite a data de validade da licen�a renovada do Produto: ("+ ALLTRIM(cProduto) +")."
									Help( ,, 'M460MARK (006)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
									_lRet := .F.
								ENDIF

								IF _lRet .AND. Empty(AI0->AI0_YPROPF) .And. _nQuant > SB5->B5_YQTDPF
										cMsgP := "N�o � permitido vender esta quantidade do produto " + ALLTRIM(cProduto) + ", o limite permitido � (" + ALLTRIM(STR(SB5->B5_YQTDPF)) + ")."
										cMsgS := "Escolha uma quantidade do Produto: ("+ ALLTRIM(cProduto) +") dentro da permitida."
										Help( ,, 'M460MARK (003)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
										_lRet := .F.					
								ENDIF								
							ELSE
								cMsgP := "N�o � permitido vender o Produto (" + ALLTRIM(cProduto) + "), pois o cliente n�o possui licen�a."
								cMsgS := "Verifique se o cliente possui Licen�a e providencie o cadastro da mesma."
								Help( ,, 'M460MARK (005)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
								_lRet := .F.
							ENDIF
						ENDIF
					ENDIF
					// TRATAMENTO PRODUTO PERIGOSO - CONTROLE POLICIA CIVIL
					/*
					IF  _lRet .AND. SB5->B5_PRODCON == "S"
						IF SB5->B5_YVLLPC < _dEntreg
							cMsgP := "N�o � permitido vender o produto " + ALLTRIM(cProduto) + " pois a Daxia est� com a Lice�a Vencida."
							cMsgS := "Regitre o processo de Licenciamento do Produto: ("+ ALLTRIM(cProduto) +")."
							Help( ,, 'M460MARK (007)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
							_lRet := .F.
						ENDIF
						IF _lRet
							DBSELECTAREA("SA1")
							DBSETORDER(1)
							IF  DBSEEK( XFILIAL("SA1")+ SC5->C5_CLIENT + SC5->C5_LOJAENT ) 
								DBSELECTAREA("Z00")
								DBSETORDER(1)
								IF !DBSEEK(XFILIAL("Z00")+SA1->A1_EST)
									cMsgP := "N�o � permitido vender o produto " + ALLTRIM(cProduto) + " para o endere�o de Entrega do Cliente."
									cMsgS := ""
									Help( ,, 'M460MARK (008)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
									_lRet := .F.
								ENDIF
							ENDIF
						ENDIF
						IF _lRet
							DBSELECTAREA("AI0")
							DbSetOrder(1) //AI0_FILIAL + AI0_CODCLI + AI0_LOJA
							IF AI0->( DbSeek( xFilial("AI0")+ SC5->C5_CLIENTE+SC5->C5_LOJACLI ))
								IF !( AI0->AI0_YPROPC == "S" )
									cMsgP := "N�o � permitido vender o Produto (" + ALLTRIM(cProduto) + "), pois o cliente n�o possui licen�a."
									cMsgS := "Verifique se o cliente possui Licen�a e providencie o cadastro da mesma."
									Help( ,, 'M460MARK (009)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
									_lRet := .F.
								ENDIF
								IF _lRet .AND. AI0->AI0_YVLLPC < _dEntreg
									cMsgP := "N�o � permitido vender o produto " + ALLTRIM(cProduto) + " pois a Licen�a do Cliente est� Vencida na Data da Entrega."
									cMsgS := "Solicite a data de validade da licen�a renovada do Produto: ("+ ALLTRIM(cProduto) +")."
									Help( ,, 'M460MARK (010)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
									_lRet := .F.
								ENDIF
							ELSE
								cMsgP := "N�o � permitido vender o Produto (" + ALLTRIM(cProduto) + "), pois o cliente n�o possui licen�a."
								cMsgS := "Verifique se o cliente possui Licen�a e providencie o cadastro da mesma."
								Help( ,, 'M460MARK (011)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
								_lRet := .F.
							ENDIF	
						ENDIF
					ENDIF
					*/
					// TRATAMENTO PRODUTO PERIGOSO - CONTROLE EXERCITO 
					IF _lRet .AND. SB5->B5_PRODEX  == "S"
						IF SB5->B5_YVLLEX < _dEntreg
							cMsgP := "N�o � permitido vender o produto " + ALLTRIM(cProduto) + " pois a Daxia est� com a Lice�a Vencida."
							cMsgS := "Regitre o processo de Licenciamento do Produto: ("+ ALLTRIM(cProduto) +")."
							Help( ,, 'M460MARK (012)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
							_lRet := .F.
						ENDIF
						IF _lRet
							DBSELECTAREA("SA1")
							DBSETORDER(1)
							IF  DBSEEK( XFILIAL("SA1")+ SC5->C5_CLIENTE+SC5->C5_LOJACLI ) 
								
								IF SA1->A1_PESSOA == 'F' .AND. _nQuant > 2
									cMsgP := "N�o � permitido vender o produto " + ALLTRIM(cProduto) + " em uma quantidade superior a 2 kilos ou 2 litros para clientes pessoa f�sica."
									cMsgS := ""
									Help( ,, 'M460MARK (013)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
									_lRet := .F.
								ENDIF
							ENDIF
							DBSELECTAREA("AI0")
							DbSetOrder(1) //AI0_FILIAL + AI0_CODCLI + AI0_LOJA
							IF AI0->( DbSeek( xFilial("AI0")+ SC5->C5_CLIENTE + SC5->C5_LOJACLI ))
								IF _lRet .AND. !( AI0->AI0_YPROEX == "S" )
									cMsgP := "N�o � permitido vender o Produto (" + ALLTRIM(cProduto) + "), pois o cliente n�o possui licen�a."
									cMsgS := "Verifique se o cliente possui Licen�a e providencie o cadastro da mesma."
									Help( ,, 'M460MARK (014)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
									_lRet := .F.
								ENDIF
								IF _lRet .AND. AI0->AI0_YVLLEX < _dEntreg
									cMsgP := "N�o � permitido vender o produto " + ALLTRIM(cProduto) + " pois a Licen�a do Cliente est� Vencida na Data da Entrega."
									cMsgS := "Solicite a data de validade da licen�a renovada do Produto: ("+ ALLTRIM(cProduto) +")."
									Help( ,, 'M460MARK (016)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
									_lRet := .F.
								ENDIF
							ELSE
								cMsgP := "N�o � permitido vender o Produto (" + ALLTRIM(cProduto) + "), pois o cliente n�o possui licen�a."
								cMsgS := "Verifique se o cliente possui Licen�a e providencie o cadastro da mesma."
								Help( ,, 'M460MARK (015)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
								_lRet := .F.
							ENDIF
						ENDIF				
					ENDIF
					// VALIDA��O DA TRANSPORTADORA
					IF _lRet
						//If Alltrim(SC5->C5_TRANSP) <> '000950' //RETIRA
							dbSelectArea("SA4")
							dbSetOrder(1)
							IF dbSeek(xFilial("SA4")+ SC5->C5_TRANSP)
								//_lRet := .T.

								// TRATAMENTO PRODUTO PERIGOSO - CONTROLE POLICIA FEDERAL
								IF SB5->B5_PRODPF  == "S" 
									IF SA4->A4_YPRODPF <> "S"
										cMsgP := "A transportadora n�o possui licen�a."
										cMsgS := "Verifique se a transportadora possui Licen�a e providencie o cadastro da mesma."
										Help( ,, 'M460MARK (017)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
										_lRet := .F.
									ELSE
										IF SA4->A4_YVLLPF < _dEntreg
											cMsgP := "N�o � permitido vender o produto " + ALLTRIM(cProduto) + " pois a Transportadora est� com a Licen�a Vencida na Data da Entrega."
											cMsgS := "Solicite a data de validade da licen�a renovada e atualize o cadastro da Transportadora."
											Help( ,, 'M460MARK (018)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
											_lRet := .F.
										ENDIF
									ENDIF
								ENDIF
								// TRATAMENTO PRODUTO PERIGOSO - CONTROLE POLICIA CIVIL
								/*
								IF  _lRet .AND. SB5->B5_PRODCON == "S"
									IF SA4->A4_PRODCON <> "S"
										cMsgP := "A transportadora n�o possui licen�a."
										cMsgS := "Verifique se a transportadora possui Licen�a e providencie o cadastro da mesma."
										Help( ,, 'M460MARK (019)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
										_lRet := .F.
									ELSE
										IF SA4->A4_YVLLPC < _dEntreg
											cMsgP := "N�o � permitido vender o produto " + ALLTRIM(cProduto) + " pois a Transportadora est� com a Licen�a Vencida na Data da Entrega."
											cMsgS := "Solicite a data de validade da licen�a renovada e atualize o cadastro da Transportadora."
											Help( ,, 'M460MARK (020)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
											_lRet := .F.
										ENDIF
									ENDIF
								ENDIF
								*/
								// TRATAMENTO PRODUTO PERIGOSO - CONTROLE EXERCITO
								IF _lRet .AND. SB5->B5_PRODEX  == "S"
									IF SA4->A4_PRODEX <> "S"
										cMsgP := "A transportadora n�o possui licen�a."
										cMsgS := "Verifique se a transportadora possui Licen�a e providencie o cadastro da mesma."
										Help( ,, 'M460MARK (021)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
										_lRet := .F.
									ELSE
										IF SA4->A4_YVLLEX < _dEntreg
											cMsgP := "N�o � permitido vender o produto " + ALLTRIM(cProduto) + " pois a Transportadora est� com a Licen�a Vencida na Data da Entrega."
											cMsgS := "Solicite a data de validade da licen�a renovada e atualize o cadastro da Transportadora."
											Help( ,, 'M460MARK (022)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
											_lRet := .F.
										ENDIF
									ENDIF
								ENDIF
							ELSE
								// N�O TEM PREVIS�O DO QUE FAZER QUANDO N�O H� TRANSPORTADORA
							ENDIF
						//Else
							//Se for retira , faz as valida��es para o cliente - 
						/*	DBSELECTAREA("SA1")
							DBSETORDER(1)
							IF  DBSEEK( XFILIAL("SA1")+ SC5->C5_CLIENTE+SC5->C5_LOJACLI ) 
								
								IF SA1->A1_PESSOA == 'F' .AND. _nQuant > 2
									cMsgP := "N�o � permitido vender o produto " + ALLTRIM(cProduto) + " em uma quantidade superior a 2 kilos ou 2 litros para clientes pessoa f�sica."
									cMsgS := ""
									Help( ,, 'M460MARK (013)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
									_lRet := .F.
								ENDIF
							ENDIF
							DBSELECTAREA("AI0")
							DbSetOrder(1) //AI0_FILIAL + AI0_CODCLI + AI0_LOJA
							IF AI0->( DbSeek( xFilial("AI0")+ SC5->C5_CLIENTE + SC5->C5_LOJACLI ))
								IF _lRet .AND. !( AI0->AI0_YPROEX == "S" )
									cMsgP := "N�o � permitido vender o Produto (" + ALLTRIM(cProduto) + "), pois o cliente n�o possui licen�a."
									cMsgS := "Verifique se o cliente possui Licen�a e providencie o cadastro da mesma."
									Help( ,, 'M460MARK (014)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
									_lRet := .F.
								ENDIF
								IF _lRet .AND. AI0->AI0_YVLLEX < _dEntreg
									cMsgP := "N�o � permitido vender o produto " + ALLTRIM(cProduto) + " pois a Licen�a do Cliente est� Vencida na Data da Entrega."
									cMsgS := "Solicite a data de validade da licen�a renovada do Produto: ("+ ALLTRIM(cProduto) +")."
									Help( ,, 'M460MARK (016)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
									_lRet := .F.
								ENDIF
							ELSE
								cMsgP := "N�o � permitido vender o Produto (" + ALLTRIM(cProduto) + "), pois o cliente n�o possui licen�a."
								cMsgS := "Verifique se o cliente possui Licen�a e providencie o cadastro da mesma."
								Help( ,, 'M460MARK (015)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
								_lRet := .F.
							ENDIF	*/						
						//EndIf
					ENDIF
				ENDIF
			ENDIF
		ENDIF
		DBSELECTAREA("SC6")
		DBSKIP()
	ENDDO
ENDIF
//_lRet := .F. 
RETURN _lRet

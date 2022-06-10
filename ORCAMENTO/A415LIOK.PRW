USER FUNCTION A415LIOK()

LOCAL _lRet     := .T.
LOCAL cAliasSCK := aHeaderSCK[1][9]       // ITENS DA TABELA SCK
LOCAL cAliasSCL := aHeaderSCL[1][9]       // ITENS DA TABELA SCL
LOCAL aAreaSCK  := (cAliasSCK)->(GetArea()) // ARMAZENA A ÁREA CORRENTE DA SCK
LOCAL aAreaSCL  := (cAliasSCL)->(GetArea()) // ARMAZENA A ÁREA CORRENTE DA SCL
LOCAL _cProduto := (cAliasSCK)->CK_PRODUTO
LOCAL _nQuant	:= (cAliasSCK)->CK_QTDVEN
LOCAL _dEntreg	:= (cAliasSCK)->CK_ENTREG
LOCAL _lDeleta	:= (cAliasSCK)->CK_FLAG

LOCAL _lPerigo  := .F. 													// INDICA SE O PRODUTO ? PERIGOSO
Local nLinha := TMP1->(Recno())
 //TMP1->( Eof() )
//msgalert(FUNNAME())
IF FUNNAME() = "MATA415" .AND. !_lDeleta
	
	SB5->(DBSETORDER(1))
	IF SB5->(DBSEEK(XFILIAL("SB5")+_cProduto))
		_lPerigo := ( SB5->B5_PRODPF == "S" .OR. SB5->B5_PRODCON == "S" .OR. SB5->B5_PRODEX == "S" ) // VERIFICO SE O PRODUTO ? PERIGOSO!
		
		IF _lPerigo
			DBSELECTAREA("Z00")
			// TRATAMENTO PRODUTO PERIGOSO - CONTROLE POLICIA FEDERAL
			IF SB5->B5_PRODPF  == "S" 
				
				IF SB5->B5_YVLLPF < _dEntreg
					cMsgP := "Não á permitido vender o produto " + ALLTRIM(_cProduto) + " pois a DAXIA está com a Liceça Vencida."
					cMsgS := "Inicie o processo de Licenciamento do Produto: ("+ ALLTRIM(_cProduto) +")."
					Help( ,, 'A415LIOK (001)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
					_lRet := .F.
				ENDIF

				// VERIFICAR CADASTRO DO CLIENTE
				IF _lRet
					DBSELECTAREA("AI0")
					DbSetOrder(1) //AI0_FILIAL + AI0_CODCLI + AI0_LOJA
					IF AI0->( DbSeek( xFilial("AI0")+ M->CJ_CLIENTE+M->CJ_LOJA ))
						IF !( AI0->AI0_YPROPF == "S" )
							cMsgP := "Não é permitido vender o Produto (" + ALLTRIM(_cProduto) + "), pois o cliente não possui licença."
							cMsgS := "Verifique se o cliente possui Licença e providencie o cadastro da mesma."
							Help( ,, 'A415LIOK (004)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
							_lRet := .F.
						ENDIF
						IF _lRet .AND. AI0->AI0_YVLLPF < _dEntreg
							cMsgP := "Não é permitido vender o produto " + ALLTRIM(_cProduto) + " pois a Licença do Cliente está Vencida na Data da Entrega."
							cMsgS := "Solicite a data de validade da licença renovada do Produto: ("+ ALLTRIM(_cProduto) +")."
							Help( ,, 'A415LIOK (006)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
							_lRet := .F.
						ENDIF
						
						IF _lRet .AND. Empty(AI0->AI0_YPROPF) .And. _nQuant > SB5->B5_YQTDPF
								cMsgP := "Não é permitido vender esta quantidade do produto " + ALLTRIM(_cProduto) + ", o limite permitido é (" + ALLTRIM(STR(SB5->B5_YQTDPF)) + ")."
								cMsgS := "Escolha uma quantidade do Produto: ("+ ALLTRIM(_cProduto) +") dentro da permitida."
								Help( ,, 'A415LIOK (003)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
								_lRet := .F.					
						ENDIF						
					ELSE
						cMsgP := "Não é permitido vender o Produto (" + ALLTRIM(_cProduto) + "), pois o cliente não possui licença."
						cMsgS := "Verifique se o cliente possui Licença e providencie o cadastro da mesma."
						Help( ,, 'A415LIOK (005)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
						_lRet := .F.
					ENDIF
				ENDIF
			ENDIF
			// TRATAMENTO PRODUTO PERIGOSO - CONTROLE POLICIA CIVIL
			/*
			IF  _lRet .AND. SB5->B5_PRODCON == "S"
				IF SB5->B5_YVLLPC < _dEntreg
					cMsgP := "Não á permitido vender o produto " + ALLTRIM(_cProduto) + " pois a Daxia está com a Liceça Vencida."
					cMsgS := "Regitre o processo de Licenciamento do Produto: ("+ ALLTRIM(_cProduto) +")."
					Help( ,, 'A415LIOK (007)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
					_lRet := .F.
				ENDIF
				IF _lRet
					DBSELECTAREA("SA1")
					DBSETORDER(1)
					IF  DBSEEK( XFILIAL("SA1")+ M->CJ_CLIENT + M->CJ_LOJAENT ) 
						DBSELECTAREA("Z00")
						DBSETORDER(1)
						IF !DBSEEK(XFILIAL("Z00")+SA1->A1_EST)
							cMsgP := "Não á permitido vender o produto " + ALLTRIM(_cProduto) + " para o endereço de Entrega do Cliente."
							cMsgS := ""
							Help( ,, 'A415LIOK (008)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
							_lRet := .F.
						ENDIF
					ENDIF
				ENDIF
				IF _lRet
					DBSELECTAREA("AI0")
					DbSetOrder(1) //AI0_FILIAL + AI0_CODCLI + AI0_LOJA
					IF AI0->( DbSeek( xFilial("AI0")+ M->CJ_CLIENTE+M->CJ_LOJA ))
						IF !( AI0->AI0_YPROPC == "S" )
							cMsgP := "Não é permitido vender o Produto (" + ALLTRIM(_cProduto) + "), pois o cliente não possui licença."
							cMsgS := "Verifique se o cliente possui Licença e providencie o cadastro da mesma."
							Help( ,, 'A415LIOK (009)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
							_lRet := .F.
						ENDIF
						IF _lRet .AND. AI0->AI0_YVLLPC < _dEntreg
							cMsgP := "Não é permitido vender o produto " + ALLTRIM(_cProduto) + " pois a Licença do Cliente está Vencida na Data da Entrega."
							cMsgS := "Solicite a data de validade da licença renovada do Produto: ("+ ALLTRIM(_cProduto) +")."
							Help( ,, 'A415LIOK (010)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
							_lRet := .F.
						ENDIF
					ELSE
						cMsgP := "Não é permitido vender o Produto (" + ALLTRIM(_cProduto) + "), pois o cliente não possui licença."
						cMsgS := "Verifique se o cliente possui Licença e providencie o cadastro da mesma."
						Help( ,, 'A415LIOK (011)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
						_lRet := .F.
					ENDIF	
				ENDIF
			ENDIF
			*/
			// TRATAMENTO PRODUTO PERIGOSO - CONTROLE EXERCITO 
			IF _lRet .AND. SB5->B5_PRODEX  == "S"
				IF SB5->B5_YVLLEX < _dEntreg
					cMsgP := "Não á permitido vender o produto " + ALLTRIM(_cProduto) + " pois a Daxia está com a Liceça Vencida."
					cMsgS := "Regitre o processo de Licenciamento do Produto: ("+ ALLTRIM(_cProduto) +")."
					Help( ,, 'A415LIOK (012)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
					_lRet := .F.
				ENDIF
				IF _lRet
					DBSELECTAREA("SA1")
					DBSETORDER(1)
					IF  DBSEEK( XFILIAL("SA1")+ M->CJ_CLIENTE+M->CJ_LOJA ) 
						
						IF SA1->A1_PESSOA == 'F' .AND. _nQuant > 2
							cMsgP := "Não á permitido vender o produto " + ALLTRIM(_cProduto) + " em uma quantidade superior a 2 kilos ou 2 litros para clientes pessoa física."
							cMsgS := ""
							Help( ,, 'A415LIOK (013)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
							_lRet := .F.
						ENDIF
					ENDIF
					DBSELECTAREA("AI0")
					DbSetOrder(1) //AI0_FILIAL + AI0_CODCLI + AI0_LOJA
					IF AI0->( DbSeek( xFilial("AI0")+ M->CJ_CLIENTE+M->CJ_LOJA ))
						IF _lRet .AND. !( AI0->AI0_YPROEX == "S" )
							cMsgP := "Não é permitido vender o Produto (" + ALLTRIM(_cProduto) + "), pois o cliente não possui licença."
							cMsgS := "Verifique se o cliente possui Licença e providencie o cadastro da mesma."
							Help( ,, 'A415LIOK (014)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
							_lRet := .F.
						ENDIF
						IF _lRet .AND. AI0->AI0_YVLLEX < _dEntreg
							cMsgP := "Não é permitido vender o produto " + ALLTRIM(_cProduto) + " pois a Licença do Cliente está Vencida na Data da Entrega."
							cMsgS := "Solicite a data de validade da licença renovada do Produto: ("+ ALLTRIM(_cProduto) +")."
							Help( ,, 'A415LIOK (016)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
							_lRet := .F.
						ENDIF
					ELSE
						cMsgP := "Não é permitido vender o Produto (" + ALLTRIM(_cProduto) + "), pois o cliente não possui licença."
						cMsgS := "Verifique se o cliente possui Licença e providencie o cadastro da mesma."
						Help( ,, 'A415LIOK (015)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
						_lRet := .F.
					ENDIF
				ENDIF				
			ENDIF
			// VALIDAÇÃO DA TRANSPORTADORA (SÓ ALERTA)
			IF _lRet
				
				dbSelectArea("SA4")
				dbSetOrder(1)
				IF dbSeek(xFilial("SA4")+M->CJ_XTRANSP)
					_lExibe := .T.
					
					// TRATAMENTO PRODUTO PERIGOSO - CONTROLE POLICIA FEDERAL
					IF SB5->B5_PRODPF  == "S" 
						IF SA4->A4_YPRODPF <> "S"
							cMsgP := "A transportadora não possui licença."
							cMsgS := "Verifique se a transportadora possui Licença e providencie o cadastro da mesma."
							Help( ,, 'A415LIOK (017)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
							_lExibe := .F.
						ELSE
							IF SA4->A4_YVLLPF < _dEntreg
								cMsgP := "Não é permitido vender o produto " + ALLTRIM(_cProduto) + " pois a Transportadora está com a Licença Vencida na Data da Entrega."
								cMsgS := "Solicite a data de validade da licença renovada e atualize o cadastro da Transportadora."
								Help( ,, 'A415LIOK (018)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
								_lExibe := .F.
							ENDIF
						ENDIF
					ENDIF
					// TRATAMENTO PRODUTO PERIGOSO - CONTROLE POLICIA CIVIL
					/*
					IF  _lExibe .AND. SB5->B5_PRODCON == "S"
						IF SA4->A4_PRODCON <> "S"
							cMsgP := "A transportadora não possui licença."
							cMsgS := "Verifique se a transportadora possui Licença e providencie o cadastro da mesma."
							Help( ,, 'A415LIOK (019)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
							_lExibe := .F.
						ELSE
							IF SA4->A4_YVLLPC < _dEntreg
								cMsgP := "Não é permitido vender o produto " + ALLTRIM(_cProduto) + " pois a Transportadora está com a Licença Vencida na Data da Entrega."
								cMsgS := "Solicite a data de validade da licença renovada e atualize o cadastro da Transportadora."
								Help( ,, 'A415LIOK (020)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
								_lExibe := .F.
							ENDIF
						ENDIF
					ENDIF
					*/
					// TRATAMENTO PRODUTO PERIGOSO - CONTROLE EXERCITO
					IF _lExibe .AND. SB5->B5_PRODEX  == "S"
						IF SA4->A4_PRODEX <> "S"
							cMsgP := "A transportadora não possui licença."
							cMsgS := "Verifique se a transportadora possui Licença e providencie o cadastro da mesma."
							Help( ,, 'A415LIOK (021)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
							_lExibe := .F.
						ELSE
							IF SA4->A4_YVLLEX < _dEntreg
								cMsgP := "Não é permitido vender o produto " + ALLTRIM(_cProduto) + " pois a Transportadora está com a Licença Vencida na Data da Entrega."
								cMsgS := "Solicite a data de validade da licença renovada e atualize o cadastro da Transportadora."
								Help( ,, 'A415LIOK (022)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
								_lExibe := .F.
							ENDIF
						ENDIF
					ENDIF
				ELSE
					// NÃO TEM PREVISÃO DO QUE FAZER QUANDO NÃO HÁ TRANSPORTADORA
				ENDIF
			ENDIF
		ENDIF
	ENDIF
ENDIF



U_UpdTotal() //Chamo essa função apenas para atualizar o valor do rodapé na moeda REAL
//U_RetFrete() // no caso de deletar a linha eu recalculo o frete 


TMP1->(DbGoTo(nLinha))
GetDRefresh()

RESTAREA(aAreaSCK)
RESTAREA(aAreaSCL)
RETURN _lRet

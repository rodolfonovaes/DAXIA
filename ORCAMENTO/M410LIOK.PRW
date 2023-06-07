User Function M410LIOK() 
     
LOCAL _lRet     := .T.
LOCAL _nPosProd := ASCAN(aHeader,{ |x| ALLTRIM(x[2]) =="C6_PRODUTO"} ) 
LOCAL _cProduto := aCols[n,_nPosProd]
LOCAL _nPosQtd	:= ASCAN(aHeader,{ |x| ALLTRIM(x[2]) =="C6_QTDVEN"} ) 
LOCAL _nQuant	:= aCols[n,_nPosQtd]
LOCAL _nPosEnt	:= ASCAN(aHeader,{ |x| ALLTRIM(x[2]) =="C6_ENTREG"} ) 
LOCAL _dEntreg	:= aCols[n,_nPosEnt]
LOCAL _lDeleta	:= GdDeleted(n)
Local lDevol	:= IIF(M->C5_TIPO == 'D',.T.,.F.)
LOCAL _lPerigo  := .F. 													// INDICA SE O PRODUTO  PERIGOSO

IF FUNNAME() = "MATA410" .AND. !_lDeleta .and. !lDevol
	
	SB5->(DBSETORDER(1))
	IF SB5->(DBSEEK(XFILIAL("SB5")+_cProduto))
		_lPerigo := ( SB5->B5_PRODPF == "S" .OR. SB5->B5_PRODCON == "S" .OR. SB5->B5_PRODEX == "S" ) // VERIFICO SE O PRODUTO  PERIGOSO!
		
		IF _lPerigo
			DBSELECTAREA("Z00")
			// TRATAMENTO PRODUTO PERIGOSO - CONTROLE POLICIA FEDERAL
			IF SB5->B5_PRODPF  == "S" 
				
				IF SB5->B5_YVLLPF < _dEntreg
					cMsgP := "Não á permitido vender o produto " + ALLTRIM(_cProduto) + " pois a DAXIA está com a Liceça Vencida."
					cMsgS := "Inicie o processo de Licenciamento do Produto: ("+ ALLTRIM(_cProduto) +")."
					Help( ,, 'M410LIOK (001)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
					_lRet := .F.
				ENDIF

				// VERIFICAR CADASTRO DO CLIENTE
				IF _lRet
					DBSELECTAREA("AI0")
					DbSetOrder(1) //AI0_FILIAL + AI0_CODCLI + AI0_LOJA
					IF AI0->( DbSeek( xFilial("AI0")+ M->C5_CLIENTE+M->C5_LOJACLI ))
						IF !( AI0->AI0_YPROPF == "S" )
							cMsgP := "Não é permitido vender o Produto (" + ALLTRIM(_cProduto) + "), pois o cliente não possui licença."
							cMsgS := "Verifique se o cliente possui Licença e providencie o cadastro da mesma."
							Help( ,, 'M410LIOK (004)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
							_lRet := .F.
						ENDIF
						IF _lRet .AND. AI0->AI0_YVLLPF < _dEntreg
							cMsgP := "Não é permitido vender o produto " + ALLTRIM(_cProduto) + " pois a Licença do Cliente está Vencida na Data da Entrega."
							cMsgS := "Solicite a data de validade da licença renovada do Produto: ("+ ALLTRIM(_cProduto) +")."
							Help( ,, 'M410LIOK (006)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
							_lRet := .F.
						ENDIF

						IF _lRet .AND. Empty(AI0->AI0_YPROPF) .And. _nQuant > SB5->B5_YQTDPF
								cMsgP := "Não é permitido vender esta quantidade do produto " + ALLTRIM(_cProduto) + ", o limite permitido é (" + ALLTRIM(STR(SB5->B5_YQTDPF)) + ")."
								cMsgS := "Escolha uma quantidade do Produto: ("+ ALLTRIM(_cProduto) +") dentro da permitida."
								Help( ,, 'M410LIOK (003)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
								_lRet := .F.					
						ENDIF						
					ELSE
						cMsgP := "Não é permitido vender o Produto (" + ALLTRIM(_cProduto) + "), pois o cliente não possui licença."
						cMsgS := "Verifique se o cliente possui Licença e providencie o cadastro da mesma."
						Help( ,, 'M410LIOK (005)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
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
					Help( ,, 'M410LIOK (007)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
					_lRet := .F.
				ENDIF
				IF _lRet
					DBSELECTAREA("SA1")
					DBSETORDER(1)
					IF  DBSEEK( XFILIAL("SA1")+ M->C5_CLIENT + M->C5_LOJAENT ) 
						DBSELECTAREA("Z00")
						DBSETORDER(1)
						IF !DBSEEK(XFILIAL("Z00")+SA1->A1_EST)
							cMsgP := "Não á permitido vender o produto " + ALLTRIM(_cProduto) + " para o endereço de Entrega do Cliente."
							cMsgS := ""
							Help( ,, 'M410LIOK (008)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
							_lRet := .F.
						ENDIF
					ENDIF
				ENDIF
				IF _lRet
					DBSELECTAREA("AI0")
					DbSetOrder(1) //AI0_FILIAL + AI0_CODCLI + AI0_LOJA
					IF AI0->( DbSeek( xFilial("AI0")+ M->C5_CLIENTE+M->C5_LOJACLI ))
						IF !( AI0->AI0_YPROPC == "S" )
							cMsgP := "Não é permitido vender o Produto (" + ALLTRIM(_cProduto) + "), pois o cliente não possui licença."
							cMsgS := "Verifique se o cliente possui Licença e providencie o cadastro da mesma."
							Help( ,, 'M410LIOK (009)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
							_lRet := .F.
						ENDIF
						IF _lRet .AND. AI0->AI0_YVLLPC < _dEntreg
							cMsgP := "Não é permitido vender o produto " + ALLTRIM(_cProduto) + " pois a Licença do Cliente está Vencida na Data da Entrega."
							cMsgS := "Solicite a data de validade da licença renovada do Produto: ("+ ALLTRIM(_cProduto) +")."
							Help( ,, 'M410LIOK (010)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
							_lRet := .F.
						ENDIF
					ELSE
						cMsgP := "Não é permitido vender o Produto (" + ALLTRIM(_cProduto) + "), pois o cliente não possui licença."
						cMsgS := "Verifique se o cliente possui Licença e providencie o cadastro da mesma."
						Help( ,, 'M410LIOK (011)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
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
					Help( ,, 'M410LIOK (012)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
					_lRet := .F.
				ENDIF
				IF _lRet
					DBSELECTAREA("SA1")
					DBSETORDER(1)
					IF  DBSEEK( XFILIAL("SA1")+ M->C5_CLIENTE+M->C5_LOJACLI ) 
						
						IF SA1->A1_PESSOA == 'F' .AND. _nQuant > 2
							cMsgP := "Não á permitido vender o produto " + ALLTRIM(_cProduto) + " em uma quantidade superior a 2 kilos ou 2 litros para clientes pessoa física."
							cMsgS := ""
							Help( ,, 'M410LIOK (013)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
							_lRet := .F.
						ENDIF
					ENDIF
					DBSELECTAREA("AI0")
					DbSetOrder(1) //AI0_FILIAL + AI0_CODCLI + AI0_LOJA
					IF AI0->( DbSeek( xFilial("AI0")+ M->C5_CLIENTE+M->C5_LOJACLI ))
						IF _lRet .AND. !( AI0->AI0_YPROEX == "S" )
							cMsgP := "Não é permitido vender o Produto (" + ALLTRIM(_cProduto) + "), pois o cliente não possui licença."
							cMsgS := "Verifique se o cliente possui Licença e providencie o cadastro da mesma."
							Help( ,, 'M410LIOK (014)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
							_lRet := .F.
						ENDIF
						IF _lRet .AND. AI0->AI0_YVLLEX < _dEntreg
							cMsgP := "Não é permitido vender o produto " + ALLTRIM(_cProduto) + " pois a Licença do Cliente está Vencida na Data da Entrega."
							cMsgS := "Solicite a data de validade da licença renovada do Produto: ("+ ALLTRIM(_cProduto) +")."
							Help( ,, 'M410LIOK (016)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
							_lRet := .F.
						ENDIF
					ELSE
						cMsgP := "Não é permitido vender o Produto (" + ALLTRIM(_cProduto) + "), pois o cliente não possui licença."
						cMsgS := "Verifique se o cliente possui Licença e providencie o cadastro da mesma."
						Help( ,, 'M410LIOK (015)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
						_lRet := .F.
					ENDIF
				ENDIF				
			ENDIF
			// VALIDAÇÃO DA TRANSPORTADORA (SÓ ALERTA)
			IF _lRet

				dbSelectArea("SA4")
				dbSetOrder(1)
				IF dbSeek(xFilial("SA4")+M->C5_TRANSP)
					_lExibe := .T.

					// TRATAMENTO PRODUTO PERIGOSO - CONTROLE POLICIA FEDERAL
					IF SB5->B5_PRODPF  == "S" 
						IF SA4->A4_YPRODPF <> "S"
							cMsgP := "A transportadora não possui licença."
							cMsgS := "Verifique se a transportadora possui Licença e providencie o cadastro da mesma."
							Help( ,, 'M410LIOK (017)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
							_lExibe := .F.
						ELSE
							IF SA4->A4_YVLLPF < _dEntreg
								cMsgP := "Não é permitido vender o produto " + ALLTRIM(_cProduto) + " pois a Transportadora está com a Licença Vencida na Data da Entrega."
								cMsgS := "Solicite a data de validade da licença renovada e atualize o cadastro da Transportadora."
								Help( ,, 'M410LIOK (018)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
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
							Help( ,, 'M410LIOK (019)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
							_lExibe := .F.
						ELSE
							IF SA4->A4_YVLLPC < _dEntreg
								cMsgP := "Não é permitido vender o produto " + ALLTRIM(_cProduto) + " pois a Transportadora está com a Licença Vencida na Data da Entrega."
								cMsgS := "Solicite a data de validade da licença renovada e atualize o cadastro da Transportadora."
								Help( ,, 'M410LIOK (020)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
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
							Help( ,, 'M410LIOK (021)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
							_lExibe := .F.
						ELSE
							IF SA4->A4_YVLLEX < _dEntreg
								cMsgP := "Não é permitido vender o produto " + ALLTRIM(_cProduto) + " pois a Transportadora está com a Licença Vencida na Data da Entrega."
								cMsgS := "Solicite a data de validade da licença renovada e atualize o cadastro da Transportadora."
								Help( ,, 'M410LIOK (022)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
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

If lDevol
	SB5->(DBSETORDER(1))
	IF SB5->(DBSEEK(XFILIAL("SB5")+_cProduto))
		_lPerigo := ( SB5->B5_PRODPF == "S" .OR. SB5->B5_PRODCON == "S" .OR. SB5->B5_PRODEX == "S" ) // VERIFICO SE O PRODUTO  PERIGOSO!
		
		IF _lPerigo
			//Validação Transportadora só alerta
			IF _lRet

				dbSelectArea("SA4")
				dbSetOrder(1)
				IF dbSeek(xFilial("SA4")+M->C5_TRANSP)
					_lExibe := .T.

					// TRATAMENTO PRODUTO PERIGOSO - CONTROLE POLICIA FEDERAL
					IF SB5->B5_PRODPF  == "S" 
						IF SA4->A4_YPRODPF <> "S"
							cMsgP := "A transportadora não possui licença."
							cMsgS := "Verifique se a transportadora possui Licença e providencie o cadastro da mesma."
							Help( ,, 'M410LIOK (023)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
							_lExibe := .F.
						ELSE
							IF SA4->A4_YVLLPF < _dEntreg
								cMsgP := "Não é permitido vender o produto " + ALLTRIM(_cProduto) + " pois a Transportadora está com a Licença Vencida na Data da Entrega."
								cMsgS := "Solicite a data de validade da licença renovada e atualize o cadastro da Transportadora."
								Help( ,, 'M410LIOK (024)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
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
							Help( ,, 'M410LIOK (019)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
							_lExibe := .F.
						ELSE
							IF SA4->A4_YVLLPC < _dEntreg
								cMsgP := "Não é permitido vender o produto " + ALLTRIM(_cProduto) + " pois a Transportadora está com a Licença Vencida na Data da Entrega."
								cMsgS := "Solicite a data de validade da licença renovada e atualize o cadastro da Transportadora."
								Help( ,, 'M410LIOK (020)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
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
							Help( ,, 'M410LIOK (025)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
							_lExibe := .F.
						ELSE
							IF SA4->A4_YVLLEX < _dEntreg
								cMsgP := "Não é permitido vender o produto " + ALLTRIM(_cProduto) + " pois a Transportadora está com a Licença Vencida na Data da Entrega."
								cMsgS := "Solicite a data de validade da licença renovada e atualize o cadastro da Transportadora."
								Help( ,, 'M410LIOK (026)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
								_lExibe := .F.
							ENDIF
						ENDIF
					ENDIF
				ELSE
					// NÃO TEM PREVISÃO DO QUE FAZER QUANDO NÃO HÁ TRANSPORTADORA
				ENDIF
			ENDIF			
		EndIf
	EndIf
EndIf

RETURN _lRet 

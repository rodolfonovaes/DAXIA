#include "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE  'totvs.ch' 
#DEFINE OPC 5

User Function DXWS001()
Return

WsRestful Produtos Description "Importacao de Produtos" Format APPLICATION_JSON
	WSDATA CodProduto As String
	WSDATA CodFilial As String
	WSDATA GruProduto As String
	WsMethod GET Description "Retorna lista dos produtos" WsSyntax "/GET/{method}"
	WsMethod POST Description "Inclui um produto no Sistema" WsSyntax "/POST/{method}"
	WsMethod DELETE Description "Exclui um produto no Sistema" WsSyntax "/DELETE/{method}"
End WsRestful

WsRestful ProdutosList Description "Lista de Produtos" Format APPLICATION_JSON
	WSDATA CodProduto As String
	WsMethod GET Description "Retorna lista dos produtos" WsSyntax "/GET/{method}"
End WsRestful

WsRestful FamiliaItens Description "Importacao de Familia" Format APPLICATION_JSON
	WSDATA CodFamilia As String
	WsMethod GET Description "Retorna lista das Familias" WsSyntax "/GET/{method}"
End WsRestful

WsRestful LinhaItens Description "Importacao de Linha" Format APPLICATION_JSON
	WSDATA CodLinha As String
	WsMethod GET Description "Retorna lista das Linhas" WsSyntax "/GET/{method}"
End WsRestful

WsRestful GrupoItens Description "Importacao de Grupo" Format APPLICATION_JSON
	WSDATA CodGrupo As String
	WsMethod GET Description "Retorna lista dos Grupos de produto" WsSyntax "/GET/{method}"
End WsRestful

WsRestful TipoItens Description "Importacao de Tipo" Format APPLICATION_JSON
	WSDATA CodTipo As String
	WsMethod GET Description "Retorna lista dos tipos de produto" WsSyntax "/GET/{method}"
End WsRestful

WsRestful NcmItens Description "Importacao de NCM" Format APPLICATION_JSON
	WSDATA CodNcm As String
	WsMethod GET Description "Retorna lista dos NCM de produto" WsSyntax "/GET/{method}"
End WsRestful

WsRestful UmItens Description "Importacao de Unidade de medida" Format APPLICATION_JSON
	WSDATA CodUm As String
	WsMethod GET Description "Retorna lista dos Um de produto" WsSyntax "/GET/{method}"
End WsRestful

WsRestful CoordProduto Description "Importacao de coordenadores" Format APPLICATION_JSON
	WSDATA CodCoord As String
	WsMethod GET Description "Retorna lista dos coordenadores" WsSyntax "/GET/{method}"
End WsRestful



WsRestful categProduto Description "Importacao de Categoria de produto" Format APPLICATION_JSON
	WSDATA CodCateg As String
	WsMethod GET Description "Retorna lista de Categoria de produto" WsSyntax "/GET/{method}"
End WsRestful


WsRestful cargaProduto Description "Importacao de Carga de produto" Format APPLICATION_JSON
	WSDATA CodCarga As String
	WsMethod GET Description "Retorna lista de Carga de produto" WsSyntax "/GET/{method}"
End WsRestful


WsRestful grpTributarioProduto Description "Importacao de Grupo Tributario" Format APPLICATION_JSON
	WSDATA CodGrpTribut As String
	WsMethod GET Description "Retorna lista de Carga de produto" WsSyntax "/GET/{method}"
End WsRestful

WsRestful origemProduto Description "Importacao de Origem" Format APPLICATION_JSON
	WSDATA CodOrigem As String
	WsMethod GET Description "Retorna lista de Origem do produto" WsSyntax "/GET/{method}"
End WsRestful

WsRestful ctContProduto Description "Importacao de Conta do produto" Format APPLICATION_JSON
	WSDATA CodCtCont As String
	WsMethod GET Description "Retorna lista de Conta do produto" WsSyntax "/GET/{method}"
End WsRestful

WsRestful embalagemProduto Description "Importacao de Embalagens do produto" Format APPLICATION_JSON
	WSDATA codEmbala As String
	WsMethod GET Description "Retorna lista de Embalagens do produto" WsSyntax "/GET/{method}"
End WsRestful

WsRestful armazemProduto Description "Importacao de Armazens do produto" Format APPLICATION_JSON
	WSDATA codFilial As String
	WSDATA codArmazem As String
	WsMethod GET Description "Retorna lista de Armazens do produto" WsSyntax "/GET/{method}"
End WsRestful

WsRestful CentroCusto Description "Importacao de Centros de custo" Format APPLICATION_JSON
	WSDATA codCC As String
	WsMethod GET Description "Retorna lista de Centros de custo" WsSyntax "/GET/{method}"
End WsRestful


WsRestful RespTecnico Description "Importacao de Responsavel Tecnico" Format APPLICATION_JSON
	WSDATA codResp As String
	WSDATA codFilial As String
	WsMethod GET Description "Retorna lista de Responsaveis Tecnicos" WsSyntax "/GET/{method}"
End WsRestful

WsRestful servicosWms Description "Importacao de Servicos WMS" Format APPLICATION_JSON
	WSDATA codServ As String
	WsMethod GET Description "Retorna lista de Servicos WMS" WsSyntax "/GET/{method}"
End WsRestful

WsRestful enderecos Description "Importacao de Enderecos" Format APPLICATION_JSON
	WSDATA codEnd As String
	WSDATA codFilial As String
	WsMethod GET Description "Retorna lista de Enderecos" WsSyntax "/GET/{method}"
End WsRestful


WsMethod POST  WSRECEIVE CODFILIAL WSSERVICE Produtos

	Local oJSON := JsonObject():new()
	Local cRet
	Local cJson := ::GetContent()
	Local nX
	Local aProd := {}
	Local oModel := FWLoadModel("MATA010")
	Local oModelSB1  := oModel:GetModel("SB1MASTER")
	Local cJSONRet := ""
	Local xValor := ""
	Local lRet := .T.
	Local lOperacao
	Local cCod	:= ''
	Local cFornece	:= ''
	Local cLoja	:= ''
	Local cCodFilial:= Iif(ValType(Self:CodFilial) <> 'U',Self:CodFilial,'')
	Private INCLUI := .F.
	Private ALTERA := .F.

	::SetContentType("application/json")

	cRet := oJson:fromJson(FwNoAccent(cJson))

	Begin Transaction

	// GERANDO PRODUTO
	If ValType(oJson['produto']) != "U"

		For nX := 1 To Len(oJson['produto'])
			//VERIFICANDO SE O MESMO JA EXISTE
			If oJson['produto'][nX]['field'] == "B1_COD"
				SB1->(dbSetOrder(1))
				If SB1->( dbSeek( xFilial("SB1") + Alltrim(oJson['produto'][nX]['value']) ))
					nOpc := 4
					lOperacao := .F.
				Else
					nOpc := 3
					lOperacao := .T.
				Endif

				Exit

			Endif

		Next

		Reclock("SB1",lOperacao)

		B1_FILIAL := xFilial("SB1",cCodFilial)
		For nX := 1 To Len(oJson['produto'])

			&(oJson['produto'][nX]['field']) := u_DXCONVDT( oJson['produto'][nX]['value']  , oJson['produto'][nX]['field'])

		Next

		SB1->(MsUnLock())
		/*
		//INICIANDO MODELO E OPERACAO
		oModel:SetOperation(nOpc)
		oModel:Activate()

		For nX := 1 To Len(oJson['produto'])

		//	If oModelSB1:CanSetValue( oJson['produto'][nX]['field']  )
		//		oModelSB1:SetValue( oJson['produto'][nX]['field'] ,  u_DXCONVDT( oJson['produto'][nX]['value']  , oJson['produto'][nX]['field']) )
		//	Endif

			&(oJson['produto'][nX]['field']) := u_DXCONVDT( oJson['produto'][nX]['value']  , oJson['produto'][nX]['field'])

		Next
		*/
		If Len(oJson['produto']) > 0 //.And. oModel:VldData()

			//FwFormCommit(oModel)

			//Verifica se nao tem complemento para gerar o registro
			If ValType(oJson['complemento']) == "U" .OR. Len(oJson['complemento']) == 0

				cJSONRet += '{'
				cJSONRet += '"status":"ok",'
				cJSONRet += '"mensagem":"registro (SB1) gravado com sucesso!"'
				cJSONRet += '}'

			Endif

		Else

			aErro := oModel:GetErrorMessage()

			// A estrutura do vetor com erro �:
			// [1] identificador (ID) do formul�rio de origem
			// [2] identificador (ID) do campo de origem
			// [3] identificador (ID) do formul�rio de erro
			// [4] identificador (ID) do campo de erro
			// [5] identificador (ID) do erro
			// [6] mensagem do erro
			// [7] mensagem da solu��o
			// [8] Valor atribu�do
			// [9] Valor anterior

			cArqErrAuto := "Id do formul�rio de origem:"+ ' [' + AllToChar( aErro[1] ) + '] '
			cArqErrAuto += "Id do campo de origem: " 	+ ' [' + AllToChar( aErro[2] ) + '] '
			cArqErrAuto += "Id do formul�rio de erro: " + ' [' + AllToChar( aErro[3] ) + '] '
			cArqErrAuto += "Id do campo de erro: " 		+ ' [' + AllToChar( aErro[4] ) + '] '
			cArqErrAuto += "Id do erro: " 				+ ' [' + AllToChar( aErro[5] ) + '] '
			cArqErrAuto += "Mensagem do erro: " 		+ ' [' + AllToChar( aErro[6] ) + '] '
			cArqErrAuto += "Mensagem da solu��o: " 		+ ' [' + AllToChar( aErro[7] ) + '] '
			cArqErrAuto += "Valor atribu�do: " 			+ ' [' + AllToChar( aErro[8] ) + '] '
			cArqErrAuto += "Valor anterior: " 			+ ' [' + AllToChar( aErro[9] ) + '] '

			cJSONRet += '{'
			cJSONRet += '"status":"error no produto", ' + CRLF
			cJSONRet += '"mensagem":"' + cArqErrAuto + '"' + CRLF
			cJSONRet += '} ' + CRLF

			lRet := .F.

			SetRestFault(400, FwNoAccent(cJSONRet))

			DisarmTransaction()
			Break

		Endif

	Endif

	If lRet

			If ValType(oJson['complemento']) != "U"

				//Gravando o Complemento do Produto
				For nX := 1 To Len(oJson['complemento'])
					If oJson['complemento'][nX]['field'] == "B5_COD"
						SB5->(dbSetOrder(1))
						If SB5->( dbSeek( xFilial("SB5",cCodFilial) + Alltrim(oJson['complemento'][nX]['value']) ))
							nOpc := 4
						Else
							nOpc := 3
						Endif

						Exit

					Endif

				Next

				/*oModel2:SetOperation(nOpc)
				oModel2:Activate()*/
	
				lOperacao := IIf ( nOpc == 3 , .T. , .F. )

				Reclock("SB5",lOperacao)

				B5_FILIAL := xFilial("SB5",cCodFilial)
				For nX := 1 To Len(oJson['complemento'])
					/*If oModelSB5:CanSetValue( oJson['complemento'][nX]['field']  )
						oModelSB5:SetValue( oJson['complemento'][nX]['field'] ,  u_DXCONVDT( oJson['complemento'][nX]['value']  , oJson['complemento'][nX]['field']) )
					Endif*/

					//&("oJson['complemento'][nX]['field']") := u_DXCONVDT( oJson['complemento'][nX]['value']  , oJson['complemento'][nX]['field'])
					&(oJson['complemento'][nX]['field']) := u_DXCONVDT( oJson['complemento'][nX]['value']  , oJson['complemento'][nX]['field'])

				Next

				SB5->(MsUnLock())

				If  Len(oJson['complemento'])  > 0 //.And. oModel2:VldData()

				//	/FwFormCommit(oModel2)

					cJSONRet += '{'
					cJSONRet += '"status":"ok",'
					cJSONRet += '"mensagem":"registro (SB5) gravado com sucesso!"'
					cJSONRet += '}'

				Else

					//aErro := oModel:GetErrorMessage()

					// A estrutura do vetor com erro �:
					// [1] identificador (ID) do formul�rio de origem
					// [2] identificador (ID) do campo de origem
					// [3] identificador (ID) do formul�rio de erro
					// [4] identificador (ID) do campo de erro
					// [5] identificador (ID) do erro
					// [6] mensagem do erro
					// [7] mensagem da solu��o
					// [8] Valor atribu�do
					// [9] Valor anterior

					cJSONRet += '{'
					cJSONRet += '"status":"error no complemento", ' + CRLF
					cJSONRet += '"mensagem":"' + 'Informe o complemento' + '"' + CRLF
					cJSONRet += '} ' + CRLF

					lRet := .F.

					SetRestFault(400, FwNoAccent(cJSONRet))

				Endif
			Endif

			If ValType(oJson['indicador']) != "U"

				//Gravando o Complemento do Produto
				For nX := 1 To Len(oJson['indicador'])
					If oJson['indicador'][nX]['field'] == "BZ_COD"
						SBZ->(dbSetOrder(1))
						If SBZ->( dbSeek( xFilial("SBZ",cCodFilial) + Alltrim(oJson['indicador'][nX]['value']) ))
							nOpc := 4
						Else
							nOpc := 3
						Endif

						Exit

					Endif

				Next

				/*oModel2:SetOperation(nOpc)
				oModel2:Activate()*/
	
				lOperacao := IIf ( nOpc == 3 , .T. , .F. )

				Reclock("SBZ",lOperacao)

				BZ_FILIAL := xFilial("SBZ",cCodFilial)
				For nX := 1 To Len(oJson['indicador'])

					&(oJson['indicador'][nX]['field']) := u_DXCONVDT( oJson['indicador'][nX]['value']  , oJson['indicador'][nX]['field'])

				Next

				SBZ->(MsUnLock())

				If  Len(oJson['indicador'])  > 0 //.And. oModel2:VldData()

				//	/FwFormCommit(oModel2)

					cJSONRet += '{'
					cJSONRet += '"status":"ok",'
					cJSONRet += '"mensagem":"registro (SBZ) gravado com sucesso!"'
					cJSONRet += '}'

				Else

					aErro := oModel:GetErrorMessage()

					// A estrutura do vetor com erro �:
					// [1] identificador (ID) do formul�rio de origem
					// [2] identificador (ID) do campo de origem
					// [3] identificador (ID) do formul�rio de erro
					// [4] identificador (ID) do campo de erro
					// [5] identificador (ID) do erro
					// [6] mensagem do erro
					// [7] mensagem da solu��o
					// [8] Valor atribu�do
					// [9] Valor anterior

					cArqErrAuto := "Id do formul�rio de origem:"+ ' [' + AllToChar( aErro[1] ) + '] '
					cArqErrAuto += "Id do campo de origem: " 	+ ' [' + AllToChar( aErro[2] ) + '] '
					cArqErrAuto += "Id do formul�rio de erro: " + ' [' + AllToChar( aErro[3] ) + '] '
					cArqErrAuto += "Id do campo de erro: " 		+ ' [' + AllToChar( aErro[4] ) + '] '
					cArqErrAuto += "Id do erro: " 				+ ' [' + AllToChar( aErro[5] ) + '] '
					cArqErrAuto += "Mensagem do erro: " 		+ ' [' + AllToChar( aErro[6] ) + '] '
					cArqErrAuto += "Mensagem da solu��o: " 		+ ' [' + AllToChar( aErro[7] ) + '] '
					cArqErrAuto += "Valor atribu�do: " 			+ ' [' + AllToChar( aErro[8] ) + '] '
					cArqErrAuto += "Valor anterior: " 			+ ' [' + AllToChar( aErro[9] ) + '] '
					

					cJSONRet += '{'
					cJSONRet += '"status":"error no indicador", ' + CRLF
					cJSONRet += '"mensagem":"' + cArqErrAuto + '"' + CRLF
					cJSONRet += '} ' + CRLF

					lRet := .F.

					SetRestFault(400, FwNoAccent(cJSONRet))

				Endif
			Endif			

			If ValType(oJson['fornecedor']) != "U"

				//Gravando o Complemento do Produto
				For nX := 1 To Len(oJson['fornecedor'])
					If oJson['fornecedor'][nX]['field'] == "A5_PRODUTO"
						cCod := PADR(oJson['fornecedor'][nX]['value'],TamSx3('A5_PRODUTO')[1])
						Exit
					Endif
				Next

				For nX := 1 To Len(oJson['fornecedor'])
					If oJson['fornecedor'][nX]['field'] == "A5_FORNECE"
						cFornece := PADR(oJson['fornecedor'][nX]['value'],TamSx3('A5_FORNECE')[1])
						Exit
					Endif
				Next

				For nX := 1 To Len(oJson['fornecedor'])
					If oJson['fornecedor'][nX]['field'] == "A5_LOJA"
						cCod := PADR(oJson['fornecedor'][nX]['value'],TamSx3('A5_LOJA')[1])
						Exit
					Endif
				Next								

				SA5->(dbSetOrder(1))
				If SA5->( dbSeek( xFilial("SA5",cCodFilial) + cFornece + cLoja + cCod ))
					nOpc := 4
				Else
					nOpc := 3
				Endif				

				/*oModel2:SetOperation(nOpc)
				oModel2:Activate()*/
	
				lOperacao := IIf ( nOpc == 3 , .T. , .F. )

				Reclock("SA5",lOperacao)

				A5_FILIAL := xFilial("SA5",cCodFilial)
				For nX := 1 To Len(oJson['fornecedor'])

					&(oJson['fornecedor'][nX]['field']) := u_DXCONVDT( oJson['fornecedor'][nX]['value']  , oJson['fornecedor'][nX]['field'])

				Next

				SA5->(MsUnLock())

				If  Len(oJson['fornecedor'])  > 0 //.And. oModel2:VldData()

				//	/FwFormCommit(oModel2)

					cJSONRet += '{'
					cJSONRet += '"status":"ok",'
					cJSONRet += '"mensagem":"registro (SA5) gravado com sucesso!"'
					cJSONRet += '}'

				Else

					aErro := oModel:GetErrorMessage()

					// A estrutura do vetor com erro �:
					// [1] identificador (ID) do formul�rio de origem
					// [2] identificador (ID) do campo de origem
					// [3] identificador (ID) do formul�rio de erro
					// [4] identificador (ID) do campo de erro
					// [5] identificador (ID) do erro
					// [6] mensagem do erro
					// [7] mensagem da solu��o
					// [8] Valor atribu�do
					// [9] Valor anterior

					cArqErrAuto := "Id do formul�rio de origem:"+ ' [' + AllToChar( aErro[1] ) + '] '
					cArqErrAuto += "Id do campo de origem: " 	+ ' [' + AllToChar( aErro[2] ) + '] '
					cArqErrAuto += "Id do formul�rio de erro: " + ' [' + AllToChar( aErro[3] ) + '] '
					cArqErrAuto += "Id do campo de erro: " 		+ ' [' + AllToChar( aErro[4] ) + '] '
					cArqErrAuto += "Id do erro: " 				+ ' [' + AllToChar( aErro[5] ) + '] '
					cArqErrAuto += "Mensagem do erro: " 		+ ' [' + AllToChar( aErro[6] ) + '] '
					cArqErrAuto += "Mensagem da solu��o: " 		+ ' [' + AllToChar( aErro[7] ) + '] '
					cArqErrAuto += "Valor atribu�do: " 			+ ' [' + AllToChar( aErro[8] ) + '] '
					cArqErrAuto += "Valor anterior: " 			+ ' [' + AllToChar( aErro[9] ) + '] '
					

					cJSONRet += '{'
					cJSONRet += '"status":"error no fornecedor", ' + CRLF
					cJSONRet += '"mensagem":"' + cArqErrAuto + '"' + CRLF
					cJSONRet += '} ' + CRLF

					lRet := .F.

					SetRestFault(400, FwNoAccent(cJSONRet))

				Endif

				If ValType(oJson['alergenico']) != "U"

					For nX := 1 To Len(oJson['alergenico'])
						//VERIFICANDO SE O MESMO JA EXISTE
						If oJson['alergenico'][nX]['field'] == "ZZH_COD"
							ZZH->(dbSetOrder(1))
							If ZZH->( dbSeek( FWxFilial("ZZH",cCodFilial) + Alltrim(oJson['alergenico'][nX]['value']) ))
								nOpc := 4
								ALTERA := .T.
							Else
								nOpc := 3
								INCLUI := .T.
							Endif

							Exit

						Endif

					Next

					lOperacao := IIf ( nOpc == 3 , .T. , .F. )

					Reclock("ZZH",lOperacao)

					ZZH_FILIAL := FWxFilial("ZZH",cCodFilial)
					For nX := 1 To Len(oJson['alergenico'])

						&(oJson['alergenico'][nX]['field']) := u_DXCONVDT( oJson['alergenico'][nX]['value']  , oJson['alergenico'][nX]['field'])

					Next

					ZZH->(MsUnLock())

					cJSONRet += '{'
					cJSONRet += '"status":"ok",'
					cJSONRet += '"mensagem":"alergenicos gravados com sucesso!"'
					cJSONRet += '}'
				Else
					cJSONRet += '{'
					cJSONRet += '"status":"Erro",'
					cJSONRet += '"mensagem":"JSON invalido! (falta alergenicos)"'
					cJSONRet += '}'			
				EndIf				
			Endif				
	Endif

	End Transaction

	::SetResponse( FwNoAccent(cJSONRet) )

Return lRet

//Exclui um produto

WsMethod DELETE  WSRECEIVE CODPRODUTO , CODFILIAL  WSSERVICE  Produtos

	Local lRet := .T.
	Local cCodProd := Self:CODPRODUTO
	Local cCodFilial := Self:CODFILIAL
	Local oModel := FWLoadModel("MATA010")
	Local oModelSB1  := oModel:GetModel("SB1MASTER")
	Local cJsonRet := ""
	Local cArqErrAuto := ""
	Local aErro := {}
	Local cFilBkp	:= cFilAnt

	::SetContentType("application/json")

	cFilAnt := cCodFilial
	Opensm0(cempant+cfilant, .T.)
	Openfile(cempant+cfilant)

	SB1->(dbSetOrder(1))
	If SB1->( dbSeek( FWxFilial("SB1") + cCodProd ))
		INCLUI := .F.
		EXCLUI := .T.
		ALTERA := .F.
		oModel:SetOperation(OPC)
		oModel:Activate()

		If oModel:VldData()

			FwFormCommit(oModel)

			cJSONRet += '{'
			cJSONRet += '"status":"ok", '
			cJSONRet += '"mensagem":"registro gravado com sucesso!"'
			cJSONRet += '}'


		Else

			aErro := oModel:GetErrorMessage()

			// A estrutura do vetor com erro �:
			// [1] identificador (ID) do formul�rio de origem
			// [2] identificador (ID) do campo de origem
			// [3] identificador (ID) do formul�rio de erro
			// [4] identificador (ID) do campo de erro
			// [5] identificador (ID) do erro
			// [6] mensagem do erro
			// [7] mensagem da solu��o
			// [8] Valor atribu�do
			// [9] Valor anterior

			cArqErrAuto := "Id do formul�rio de origem:"+ ' [' + AllToChar( aErro[1] ) + '] '
			cArqErrAuto += "Id do campo de origem: " 	+ ' [' + AllToChar( aErro[2] ) + '] '
			cArqErrAuto += "Id do formul�rio de erro: " + ' [' + AllToChar( aErro[3] ) + '] '
			cArqErrAuto += "Id do campo de erro: " 		+ ' [' + AllToChar( aErro[4] ) + '] '
			cArqErrAuto += "Id do erro: " 				+ ' [' + AllToChar( aErro[5] ) + '] '
			cArqErrAuto += "Mensagem do erro: " 		+ ' [' + AllToChar( aErro[6] ) + '] '
			cArqErrAuto += "Mensagem da solu��o: " 		+ ' [' + AllToChar( aErro[7] ) + '] '
			cArqErrAuto += "Valor atribu�do: " 			+ ' [' + AllToChar( aErro[8] ) + '] '
			cArqErrAuto += "Valor anterior: " 			+ ' [' + AllToChar( aErro[9] ) + '] '

			cJSONRet += '{'
			cJSONRet += '"status":"error", ' + CRLF
			cJSONRet += '"mensagem":" ' + cArqErrAuto + '"' + CRLF
			cJSONRet += '} ' + CRLF

			lRet := .F.

			SetRestFault(400, FwNoAccent(cJSONRet))

		Endif

	Else
		cJSONRet += '{' + CRLF
		cJSONRet += '"status":"error"' + CRLF
		cJSONRet += '"mensagem":"produto nao encontrado"' +  CRLF
		cJSONRet += '}' + CRLF

	Endif
	
	::SetResponse( FwNoAccent(cJSONRet) )

	cFilAnt := cFilBkp

Return lRet



/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Metodo    � GET        � Autor � Flavio Valentin     � Data � 14/01/20 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Retorna a lista de kdbrprodutos - KDBR.                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum.                                                    ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum.                                                    ���
�������������������������������������������������������������������������Ĵ��
���Analista Resp.�  Data  � Manutencao Efetuada                           ���
�������������������������������������������������������������������������Ĵ��
���              �        �                                               ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
WsMethod GET WSRECEIVE CodProduto, GruProduto WSSERVICE Produtos

Local _aArea 	 	:= GetArea()
Local _cQuery 		:= ""
Local _cNextAlias 	:= GetNextAlias()
Local _cXml 		:= ''
Local _cCodProd		:= Iif(ValType(Self:CodProduto) <> 'U',Self:CodProduto,'')
Local _cGruProd		:= Iif(ValType(Self:GruProduto) <> 'U',Self:GruProduto,'')
Local cJsonRet		:= ''

::SetContentType('application/xml')

_cQuery := " SELECT * " + CRLF
_cQuery += " FROM " + RetSqlName("SB1") + " SB1 " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += " SB1.B1_FILIAL = '" + xFilial('SB1') + "' " + CRLF
If !Empty(_cCodProd)
	_cQuery += " AND SB1.B1_COD = '" + AllTrim(_cCodProd) + "' " + CRLF
EndIf
If !Empty(_cGruProd)
	_cQuery += " AND SB1.B1_XGRUPO = '" + AllTrim(_cGruProd) + "' " + CRLF
EndIf
_cQuery += " AND SB1.D_E_L_E_T_ = '' " + CRLF
_cQuery += " ORDER BY SB1.B1_FILIAL, SB1.B1_COD " 
_cQuery := ChangeQuery(_cQuery)

If Select(_cNextAlias) > 0
	dbSelectArea(_cNextAlias)
	dbCloseArea()
EndIf

dbUseArea(.T.,'TOPCONN',TCGENQRY(,,_cQuery),_cNextAlias,.T.,.T.)
dbSelectArea(_cNextAlias)
If !(_cNextAlias)->(Eof()) .And. !(_cNextAlias)->(Bof())
	
	cJsonRet := '{'
	cJsonRet += '	"Produtos" : [ '

	While !(_cNextAlias)->(Eof())
		cJsonRet +=	'{'
		cJsonRet += '"ItemNumber": "'      + AllTrim((_cNextAlias)->B1_COD) + '",'
		cJsonRet += '"ItemDescription": "' + AllTrim(STRTRAN((_cNextAlias)->B1_DESC,'"',''))   + '",'
		cJsonRet += '"GruProduto": "' + AllTrim((_cNextAlias)->B1_XGRUPO)   + '",'	
		cJsonRet += ' },'
		(_cNextAlias)->(dbSkip())
	EndDo

	cJsonRet := substr( Alltrim(cJsonRet) , 1 , len(Alltrim(cJsonRet)) -1 )
	cJsonRet += '	]'
	cJsonRet += '}'
	cJsonRet := StrTran(cJsonRet,Chr(129),"")
	cJsonRet := StrTran(cJsonRet,Chr(141),"")
	cJsonRet := StrTran(cJsonRet,Chr(143),"")
	cJsonRet := StrTran(cJsonRet,Chr(144),"")
	cJsonRet := StrTran(cJsonRet,Chr(157),"")
	cJsonRet := StrTran(cJsonRet,Chr(9),"")
	cJsonRet := StrTran(cJsonRet,Chr(10),"")
	cJsonRet := StrTran(cJsonRet,Chr(13),"")
	conout("WSREST - " + cJsonRet)
	cJsonRet := FwCutOff(cJsonRet,.F.)		
	::SetResponse(FwNoAccent(cJsonRet))	

	//Conout(_cXml)
Else
	cJsonRet := '{'
	cJsonRet += '	"Produtos" : [ '
	cJsonRet += '	"VAZIO" '
	cJsonRet += '	]'
	cJsonRet += '}'	
	::SetResponse(FwNoAccent(cJsonRet))	
EndIf

RestArea(_aArea)

Return(.T.)

WsMethod GET WSRECEIVE CodProduto WSSERVICE ProdutosList

Local _aArea 	 	:= GetArea()
Local _cQuery 		:= ""
Local _cNextAlias 	:= GetNextAlias()
Local _cXml 		:= ''
Local _cCodProd		:= Iif(ValType(Self:CodProduto) <> 'U',Self:CodProduto,'')
Local cJsonRet		:= ''

::SetContentType('application/xml')

_cQuery := " SELECT * " + CRLF
_cQuery += " FROM " + RetSqlName("SB1") + " SB1 " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += " SB1.B1_FILIAL = '" + xFilial('SB1') + "' " + CRLF
If !Empty(_cCodProd)
	_cQuery += " AND SB1.B1_COD = '" + AllTrim(_cCodProd) + "' " + CRLF
EndIf
_cQuery += " AND SB1.D_E_L_E_T_ = '' " + CRLF
_cQuery += " ORDER BY SB1.B1_FILIAL, SB1.B1_COD " 
_cQuery := ChangeQuery(_cQuery)

If Select(_cNextAlias) > 0
	dbSelectArea(_cNextAlias)
	dbCloseArea()
EndIf

dbUseArea(.T.,'TOPCONN',TCGENQRY(,,_cQuery),_cNextAlias,.T.,.T.)
dbSelectArea(_cNextAlias)
If !(_cNextAlias)->(Eof()) .And. !(_cNextAlias)->(Bof())
	
	cJsonRet := '{'
	cJsonRet += '	"ProdutosList" : [ '

	While !(_cNextAlias)->(Eof())
		cJsonRet +=	'{'
		cJsonRet += '"ItemNumber": "'      + AllTrim((_cNextAlias)->B1_COD) + '",'
		cJsonRet += '"ItemDescription": "' + AllTrim(STRTRAN((_cNextAlias)->B1_DESC,'"',''))   + '",'
		cJsonRet += ' },'
		(_cNextAlias)->(dbSkip())
	EndDo

	cJsonRet := substr( Alltrim(cJsonRet) , 1 , len(Alltrim(cJsonRet)) -1 )
	cJsonRet += '	]'
	cJsonRet += '}'
	cJsonRet := StrTran(cJsonRet,Chr(129),"")
	cJsonRet := StrTran(cJsonRet,Chr(141),"")
	cJsonRet := StrTran(cJsonRet,Chr(143),"")
	cJsonRet := StrTran(cJsonRet,Chr(144),"")
	cJsonRet := StrTran(cJsonRet,Chr(157),"")
	cJsonRet := StrTran(cJsonRet,Chr(9),"")
	cJsonRet := StrTran(cJsonRet,Chr(10),"")
	cJsonRet := StrTran(cJsonRet,Chr(13),"")
	conout("WSREST - " + cJsonRet)
	cJsonRet := FwCutOff(cJsonRet,.F.)		
	::SetResponse(FwNoAccent(cJsonRet))	

	//Conout(_cXml)
Else
	cJsonRet := '{'
	cJsonRet += '	"ProdutosList" : [ '
	cJsonRet += '	"VAZIO" '
	cJsonRet += '	]'
	cJsonRet += '}'	
	::SetResponse(FwNoAccent(cJsonRet))	
EndIf

RestArea(_aArea)

Return(.T.)



WsMethod GET WSRECEIVE CodFamilia WSSERVICE FamiliaItens

Local _aArea 	 	:= GetArea()
Local _cQuery 		:= ""
Local _cNextAlias 	:= GetNextAlias()
Local _cXml 		:= ''
Local cJsonRet 		:= ''
Local _cCodFam		:= Iif(ValType(Self:CodFamilia) <> 'U',Self:CodFamilia,'')

::SetContentType('application/xml')

_cQuery := " SELECT * " + CRLF
_cQuery += " FROM " + RetSqlName("SZ1") + " SZ1 " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += " SZ1.Z1_FILIAL = '" + FWxFilial('SZ1') + "' " + CRLF
If !Empty(_cCodFam)
	_cQuery += " AND SZ1.Z1_COD = '" + AllTrim(_cCodFam) + "' " + CRLF
EndIf
_cQuery += " AND SZ1.D_E_L_E_T_ = '' " + CRLF
_cQuery += " ORDER BY SZ1.Z1_FILIAL, SZ1.Z1_COD " 
_cQuery := ChangeQuery(_cQuery)

If Select(_cNextAlias) > 0
	dbSelectArea(_cNextAlias)
	dbCloseArea()
	_cNextAlias 	:= GetNextAlias()
EndIf

dbUseArea(.T.,'TOPCONN',TCGENQRY(,,_cQuery),_cNextAlias,.T.,.T.)
dbSelectArea(_cNextAlias)
If !(_cNextAlias)->(Eof()) .And. !(_cNextAlias)->(Bof())
/*	_cXml := '<?xml version="1.0" encoding="UTF-8"?> ' + CRLF
	_cXml += '<Items>' + CRLF
	(_cNextAlias)->(dbGoTop())
		While !(_cNextAlias)->(Eof())
			_cXml += '<Item>' + CRLF
			_cXml += '<FamNumber>' + AllTrim((_cNextAlias)->Z1_COD) + '</ItemNumber>' + CRLF
			_cXml += '<FamDescription>' + AllTrim((_cNextAlias)->Z1_DESC) + '</ItemDescription>' + CRLF
			_cXml += '<CreateUpdate>Create</CreateUpdate>' + CRLF
			_cXml += '</Item>' + CRLF
			(_cNextAlias)->(dbSkip())
		EndDo
	_cXml += '</Items>' + CRLF
	_cXml := EncodeUTF8(_cXml)
	::SetResponse(FwNoAccent(_cXml))
	//Conout(_cXml)
	Else
	_cXml := '<?xml version="1.0" encoding="utf-8" ?>' + CRLF
	_cXml += '<noitems>' + CRLF
	_cXml += '<message>Empty</message>' + CRLF
	_cXml += '</noitems>' + CRLF
	_cXml := EncodeUTF8(_cXml)*/

	cJsonRet := '{'
	cJsonRet += '	"FamiliaItens" : [ '

	While !(_cNextAlias)->(Eof())
		cJsonRet +=	'{'
		cJsonRet += '"FamNumber": "'      + AllTrim((_cNextAlias)->Z1_COD) + '",'
		cJsonRet += '"FamDescription": "' + AllTrim((_cNextAlias)->Z1_DESC)   + '",'
		cJsonRet += ' },'
		(_cNextAlias)->(dbSkip())
	EndDo

	cJsonRet := substr( Alltrim(cJsonRet) , 1 , len(Alltrim(cJsonRet)) -1 )
	cJsonRet += '	]'
	cJsonRet += '}'
	cJsonRet := StrTran(cJsonRet,Chr(129),"")
	cJsonRet := StrTran(cJsonRet,Chr(141),"")
	cJsonRet := StrTran(cJsonRet,Chr(143),"")
	cJsonRet := StrTran(cJsonRet,Chr(144),"")
	cJsonRet := StrTran(cJsonRet,Chr(157),"")
	cJsonRet := StrTran(cJsonRet,Chr(9),"")
	cJsonRet := StrTran(cJsonRet,Chr(10),"")
	cJsonRet := StrTran(cJsonRet,Chr(13),"")
	conout("WSREST - " + cJsonRet)
	cJsonRet := FwCutOff(cJsonRet,.F.)		
	::SetResponse(FwNoAccent(cJsonRet))
EndIf

RestArea(_aArea)

Return(.T.)


WsMethod GET WSRECEIVE CodLinha WSSERVICE LinhaItens

Local _aArea 	 	:= GetArea()
Local _cQuery 		:= ""
Local _cNextAlias 	:= GetNextAlias()
Local _cXml 		:= ''
Local _cCodLin		:= Iif(ValType(Self:CodLinha) <> 'U',Self:CodLinha,'')
Local cJsonRet		:= ''

::SetContentType('application/xml')

_cQuery := " SELECT * " + CRLF
_cQuery += " FROM " + RetSqlName("SZ2") + " SZ2 " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += " SZ2.Z2_FILIAL = '" + FWxFilial('SZ2') + "' " + CRLF
	If !Empty(_cCodLin)
	_cQuery += " AND SZ2.Z2_COD = '" + AllTrim(_cCodLin) + "' " + CRLF
	EndIf
_cQuery += " AND SZ2.D_E_L_E_T_ = '' " + CRLF
_cQuery += " ORDER BY SZ2.Z2_FILIAL, SZ2.Z2_COD " 
_cQuery := ChangeQuery(_cQuery)

If Select(_cNextAlias) > 0
	dbSelectArea(_cNextAlias)
	dbCloseArea()
	_cNextAlias 	:= GetNextAlias()
EndIf

dbUseArea(.T.,'TOPCONN',TCGENQRY(,,_cQuery),_cNextAlias,.T.,.T.)
dbSelectArea(_cNextAlias)
If !(_cNextAlias)->(Eof()) .And. !(_cNextAlias)->(Bof())

	cJsonRet := '{'
	cJsonRet += '	"Linha" : [ '

	While !(_cNextAlias)->(Eof())
		cJsonRet +=	'{'
		cJsonRet += '"LinNumber": "'      + AllTrim((_cNextAlias)->Z2_COD) + '",'
		cJsonRet += '"LinDescription": "' + AllTrim((_cNextAlias)->Z2_DESCR)   + '",'	
		cJsonRet += ' },'
		(_cNextAlias)->(dbSkip())
	EndDo

	cJsonRet := substr( Alltrim(cJsonRet) , 1 , len(Alltrim(cJsonRet)) -1 )
	cJsonRet += '	]'
	cJsonRet += '}'
	cJsonRet := StrTran(cJsonRet,Chr(129),"")
	cJsonRet := StrTran(cJsonRet,Chr(141),"")
	cJsonRet := StrTran(cJsonRet,Chr(143),"")
	cJsonRet := StrTran(cJsonRet,Chr(144),"")
	cJsonRet := StrTran(cJsonRet,Chr(157),"")
	cJsonRet := StrTran(cJsonRet,Chr(9),"")
	cJsonRet := StrTran(cJsonRet,Chr(10),"")
	cJsonRet := StrTran(cJsonRet,Chr(13),"")
	conout("WSREST - " + cJsonRet)
	cJsonRet := FwCutOff(cJsonRet,.F.)		
	::SetResponse(FwNoAccent(cJsonRet))		
Else
	cJsonRet := '{'
	cJsonRet += '	"Linha" : [ '
	cJsonRet += '	"VAZIO" '
	cJsonRet += '	]'
	cJsonRet += '}'	
	::SetResponse(FwNoAccent(cJsonRet))	
EndIf

RestArea(_aArea)

Return(.T.)




WsMethod GET WSRECEIVE CodGrupo WSSERVICE GrupoItens

Local _aArea 	 	:= GetArea()
Local _cQuery 		:= ""
Local _cNextAlias 	:= GetNextAlias()
Local _cXml 		:= ''
Local _cCodGru		:= Iif(ValType(Self:CodGrupo) <> 'U',Self:CodGrupo,'')
Local cJsonRet		:= ''
::SetContentType('application/xml')

_cQuery := " SELECT * " + CRLF
_cQuery += " FROM " + RetSqlName("SZ3") + " SZ3 " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += " SZ3.Z3_FILIAL = '" + FWxFilial('SZ3') + "' " + CRLF
If !Empty(_cCodGru)
	_cQuery += " AND SZ3.Z3_COD = '" + AllTrim(_cCodGru) + "' " + CRLF
EndIf
_cQuery += " AND SZ3.D_E_L_E_T_ = '' " + CRLF
_cQuery += " ORDER BY SZ3.Z3_FILIAL, SZ3.Z3_COD " 
_cQuery := ChangeQuery(_cQuery)

If Select(_cNextAlias) > 0
	dbSelectArea(_cNextAlias)
	dbCloseArea()
	_cNextAlias 	:= GetNextAlias()
EndIf

dbUseArea(.T.,'TOPCONN',TCGENQRY(,,_cQuery),_cNextAlias,.T.,.T.)
dbSelectArea(_cNextAlias)
If !(_cNextAlias)->(Eof()) .And. !(_cNextAlias)->(Bof())

	cJsonRet := '{'
	cJsonRet += '	"Grupo" : [ '

	While !(_cNextAlias)->(Eof())
		cJsonRet +=	'{'
		cJsonRet += '"GruNumber": "'      + AllTrim((_cNextAlias)->Z3_COD) + '",'
		cJsonRet += '"GruDescription": "' + AllTrim((_cNextAlias)->Z3_DESCR)   + '",'	
		cJsonRet += ' },'
		(_cNextAlias)->(dbSkip())
	EndDo

	cJsonRet := substr( Alltrim(cJsonRet) , 1 , len(Alltrim(cJsonRet)) -1 )
	cJsonRet += '	]'
	cJsonRet += '}'
	cJsonRet := StrTran(cJsonRet,Chr(129),"")
	cJsonRet := StrTran(cJsonRet,Chr(141),"")
	cJsonRet := StrTran(cJsonRet,Chr(143),"")
	cJsonRet := StrTran(cJsonRet,Chr(144),"")
	cJsonRet := StrTran(cJsonRet,Chr(157),"")
	cJsonRet := StrTran(cJsonRet,Chr(9),"")
	cJsonRet := StrTran(cJsonRet,Chr(10),"")
	cJsonRet := StrTran(cJsonRet,Chr(13),"")
	conout("WSREST - " + cJsonRet)
	cJsonRet := FwCutOff(cJsonRet,.F.)		
	::SetResponse(FwNoAccent(cJsonRet))			
Else
	cJsonRet := '{'
	cJsonRet += '	"Grupo" : [ '
	cJsonRet += '	"VAZIO" '
	cJsonRet += '	]'
	cJsonRet += '}'	
	::SetResponse(FwNoAccent(cJsonRet))	
EndIf

RestArea(_aArea)

Return(.T.)


WsMethod GET WSRECEIVE CodTipo WSSERVICE TipoItens

Local _aArea 	 	:= GetArea()
Local _cQuery 		:= ""
Local _cNextAlias 	:= GetNextAlias()
Local _cXml 		:= ''
Local _cCodType		:= Iif(ValType(Self:CodTipo) <> 'U',Self:CodTipo,'')
Local cJsonRet		:= ''
::SetContentType('application/xml')

_cQuery := " SELECT X5_CHAVE, X5_DESCRI " + CRLF
_cQuery += " FROM " + RetSqlName("SX5") + " SX5 " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += " SX5.X5_FILIAL = '" + FWxFilial('SX5') + "' " + CRLF
If !Empty(_cCodType)
	_cQuery += " AND SX5.X5_CHAVE = '" + AllTrim(_cCodType) + "' " + CRLF
EndIf
_cQuery += " AND SX5.X5_TABELA = '02' " + CRLF	
_cQuery += " AND SX5.D_E_L_E_T_ = ' ' " + CRLF
_cQuery += " ORDER BY SX5.X5_FILIAL, SX5.X5_CHAVE " 
_cQuery := ChangeQuery(_cQuery)

If Select(_cNextAlias) > 0
	dbSelectArea(_cNextAlias)
	dbCloseArea()
	_cNextAlias 	:= GetNextAlias()
	Conout('ja criou denovo :' + alltrim(_cNextAlias))
EndIf

dbUseArea(.T.,'TOPCONN',TCGENQRY(,,_cQuery),_cNextAlias,.T.,.T.)
dbSelectArea(_cNextAlias)
If !(_cNextAlias)->(Eof()) .And. !(_cNextAlias)->(Bof())
	
	cJsonRet := '{'
	cJsonRet += '	"TipoItens" : [ '

	While !(_cNextAlias)->(Eof())
		cJsonRet +=	'{'
		cJsonRet += '"TypeNumber": "'      + AllTrim((_cNextAlias)->X5_CHAVE) + '",'
		cJsonRet += '"TypeDescription": "' + AllTrim((_cNextAlias)->X5_DESCRI)  + '",'	
		cJsonRet += ' },'
		(_cNextAlias)->(dbSkip())
	EndDo

	cJsonRet := substr( Alltrim(cJsonRet) , 1 , len(Alltrim(cJsonRet)) -1 )
	cJsonRet += '	]'
	cJsonRet += '}'
	cJsonRet := StrTran(cJsonRet,Chr(129),"")
	cJsonRet := StrTran(cJsonRet,Chr(141),"")
	cJsonRet := StrTran(cJsonRet,Chr(143),"")
	cJsonRet := StrTran(cJsonRet,Chr(144),"")
	cJsonRet := StrTran(cJsonRet,Chr(157),"")
	cJsonRet := StrTran(cJsonRet,Chr(9),"")
	cJsonRet := StrTran(cJsonRet,Chr(10),"")
	cJsonRet := StrTran(cJsonRet,Chr(13),"")
	conout("WSREST - " + cJsonRet)
	cJsonRet := FwCutOff(cJsonRet,.F.)		
	::SetResponse(FwNoAccent(cJsonRet))		
Else
	cJsonRet := '{'
	cJsonRet += '	"Grupo" : [ '
	cJsonRet += '	"VAZIO" '
	cJsonRet += '	]'
	cJsonRet += '}'	
	::SetResponse(FwNoAccent(cJsonRet))	
EndIf

RestArea(_aArea)

Return(.T.)


WsMethod GET WSRECEIVE CodNcm WSSERVICE NcmItens

Local _aArea 	 	:= GetArea()
Local _cQuery 		:= ""
Local _cNextAlias 	:= GetNextAlias()
Local _cXml 		:= ''
Local _cCodNcm		:= Iif(ValType(Self:CodNcm) <> 'U',Self:CodNcm,'')
Local cJsonRet		:= ''

::SetContentType('application/xml')

_cQuery := " SELECT * " + CRLF
_cQuery += " FROM " + RetSqlName("SYD") + " SYD " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += " SYD.YD_FILIAL = '" + FWxFilial('SYD') + "' " + CRLF
If !Empty(_cCodNcm)
	_cQuery += " AND SYD.YD_TEC = '" + AllTrim(_cCodNcm) + "' " + CRLF
EndIf
_cQuery += " AND SYD.D_E_L_E_T_ = '' " + CRLF
_cQuery += " ORDER BY SYD.YD_TEC, SYD.YD_DESC_P " 
_cQuery := ChangeQuery(_cQuery)

If Select(_cNextAlias) > 0
	dbSelectArea(_cNextAlias)
	dbCloseArea()
	_cNextAlias 	:= GetNextAlias()
EndIf

dbUseArea(.T.,'TOPCONN',TCGENQRY(,,_cQuery),_cNextAlias,.T.,.T.)
dbSelectArea(_cNextAlias)
If !(_cNextAlias)->(Eof()) .And. !(_cNextAlias)->(Bof())

	cJsonRet := '{'
	cJsonRet += '	"NCMItens" : [ '

	While !(_cNextAlias)->(Eof())
		cJsonRet +=	'{'
		cJsonRet += '"NcmNumber": "'      + AllTrim((_cNextAlias)->YD_TEC) + '",'
		cJsonRet += '"NcmDescription": "' + AllTrim(Strtran((_cNextAlias)->YD_DESC_P,'"',''))  + '",'	
		cJsonRet += ' },'
		(_cNextAlias)->(dbSkip())
	EndDo

	cJsonRet := substr( Alltrim(cJsonRet) , 1 , len(Alltrim(cJsonRet)) -1 )
	cJsonRet += '	]'
	cJsonRet += '}'
	cJsonRet := StrTran(cJsonRet,Chr(129),"")
	cJsonRet := StrTran(cJsonRet,Chr(141),"")
	cJsonRet := StrTran(cJsonRet,Chr(143),"")
	cJsonRet := StrTran(cJsonRet,Chr(144),"")
	cJsonRet := StrTran(cJsonRet,Chr(157),"")
	cJsonRet := StrTran(cJsonRet,Chr(9),"")
	cJsonRet := StrTran(cJsonRet,Chr(10),"")
	cJsonRet := StrTran(cJsonRet,Chr(13),"")
	conout("WSREST - " + cJsonRet)
	cJsonRet := FwCutOff(cJsonRet,.F.)		
	::SetResponse(FwNoAccent(cJsonRet))			
Else
	cJsonRet := '{'
	cJsonRet += '	"NCMItens" : [ '
	cJsonRet += '	"VAZIO" '
	cJsonRet += '	]'
	cJsonRet += '}'	
	::SetResponse(FwNoAccent(cJsonRet))	
EndIf

RestArea(_aArea)

Return(.T.)



WsMethod GET WSRECEIVE CodUm WSSERVICE UmItens

Local _aArea 	 	:= GetArea()
Local _cQuery 		:= ""
Local _cNextAlias 	:= GetNextAlias()
Local _cXml 		:= ''
Local _cCodUm		:= Iif(ValType(Self:CodUm) <> 'U',Self:CodUm,'')
Local cJsonRet		:= ''

::SetContentType('application/xml')

_cQuery := " SELECT * " + CRLF
_cQuery += " FROM " + RetSqlName("SAH") + " SAH " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += " SAH.AH_FILIAL = '" + FWxFilial('SAH') + "' " + CRLF
If !Empty(_cCodUm)
	_cQuery += " AND SAH.AH_UNIMED = '" + AllTrim(_cCodUm) + "' " + CRLF
EndIf
_cQuery += " AND SAH.D_E_L_E_T_ = '' " + CRLF
_cQuery += " ORDER BY SAH.AH_UNIMED " 
_cQuery := ChangeQuery(_cQuery)

If Select(_cNextAlias) > 0
	dbSelectArea(_cNextAlias)
	dbCloseArea()
	_cNextAlias 	:= GetNextAlias()
EndIf

dbUseArea(.T.,'TOPCONN',TCGENQRY(,,_cQuery),_cNextAlias,.T.,.T.)
dbSelectArea(_cNextAlias)
If !(_cNextAlias)->(Eof()) .And. !(_cNextAlias)->(Bof())

	cJsonRet := '{'
	cJsonRet += '	"UM" : [ '

	While !(_cNextAlias)->(Eof())
		cJsonRet +=	'{'
		cJsonRet += '"UmCode": "'      + AllTrim((_cNextAlias)->AH_UNIMED) + '",'
		cJsonRet += '"UmDescription": "' + AllTrim((_cNextAlias)->AH_DESCPO)  + '",'	
		cJsonRet += ' },'
		(_cNextAlias)->(dbSkip())
	EndDo

	cJsonRet := substr( Alltrim(cJsonRet) , 1 , len(Alltrim(cJsonRet)) -1 )
	cJsonRet += '	]'
	cJsonRet += '}'
	cJsonRet := StrTran(cJsonRet,Chr(129),"")
	cJsonRet := StrTran(cJsonRet,Chr(141),"")
	cJsonRet := StrTran(cJsonRet,Chr(143),"")
	cJsonRet := StrTran(cJsonRet,Chr(144),"")
	cJsonRet := StrTran(cJsonRet,Chr(157),"")
	cJsonRet := StrTran(cJsonRet,Chr(9),"")
	cJsonRet := StrTran(cJsonRet,Chr(10),"")
	cJsonRet := StrTran(cJsonRet,Chr(13),"")
	conout("WSREST - " + cJsonRet)
	cJsonRet := FwCutOff(cJsonRet,.F.)		
	::SetResponse(FwNoAccent(cJsonRet))			
Else
	cJsonRet := '{'
	cJsonRet += '	"NCMItens" : [ '
	cJsonRet += '	"VAZIO" '
	cJsonRet += '	]'
	cJsonRet += '}'	
	::SetResponse(FwNoAccent(cJsonRet))	
EndIf

RestArea(_aArea)

Return(.T.)



WsMethod GET WSRECEIVE CodCoord WSSERVICE CoordProduto

Local _aArea 	 	:= GetArea()
Local _cQuery 		:= ""
Local cNextAlias 	:= GetNextAlias()
Local _cXml 		:= ''
Local _cCodCoord		:= Iif(ValType(Self:CodCoord) <> 'U',Self:CodCoord,'')
Local cJsonRet		:= ''

::SetContentType('application/xml')

_cQuery := " SELECT * " + CRLF
_cQuery += " FROM " + RetSqlName("SA3") + " SA3 " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += " SA3.A3_FILIAL = '" + FWxFilial('SA3') + "' " + CRLF
If !Empty(_cCodCoord)
	_cQuery += " AND SA3.A3_COD = '" + AllTrim(_cCodCoord) + "' " + CRLF
EndIf
_cQuery += " AND SA3.D_E_L_E_T_ = ' ' " + CRLF
_cQuery += " ORDER BY SA3.A3_COD, SA3.A3_NOME " 
_cQuery := ChangeQuery(_cQuery)

Conout('Query ' + _cQuery)
If Select(cNextAlias) > 0
	dbSelectArea(cNextAlias)
	dbCloseArea()
	cNextAlias 	:= GetNextAlias()
EndIf

dbUseArea(.T.,'TOPCONN',TCGENQRY(,,_cQuery),cNextAlias,.T.,.T.)
dbSelectArea(cNextAlias)
If !(cNextAlias)->(Eof()) .And. !(cNextAlias)->(Bof())
	cJsonRet := '{'
	cJsonRet += '	"Coord" : [ '

	While !(cNextAlias)->(Eof())
		cJsonRet +=	'{'
		cJsonRet += '"vendedorNumber": "'      +  AllTrim((cNextAlias)->A3_COD) + '",'
		cJsonRet += '"vendedorDescription": "' +  AllTrim((cNextAlias)->A3_NOME)  + '",'	
		cJsonRet += ' },'
		(cNextAlias)->(dbSkip())
	EndDo

	cJsonRet := substr( Alltrim(cJsonRet) , 1 , len(Alltrim(cJsonRet)) -1 )
	cJsonRet += '	]'
	cJsonRet += '}'
	cJsonRet := StrTran(cJsonRet,Chr(129),"")
	cJsonRet := StrTran(cJsonRet,Chr(141),"")
	cJsonRet := StrTran(cJsonRet,Chr(143),"")
	cJsonRet := StrTran(cJsonRet,Chr(144),"")
	cJsonRet := StrTran(cJsonRet,Chr(157),"")
	cJsonRet := StrTran(cJsonRet,Chr(9),"")
	cJsonRet := StrTran(cJsonRet,Chr(10),"")
	cJsonRet := StrTran(cJsonRet,Chr(13),"")
	conout("WSREST - " + cJsonRet)
	cJsonRet := FwCutOff(cJsonRet,.F.)		
	::SetResponse(FwNoAccent(cJsonRet))			
Else
	cJsonRet := '{'
	cJsonRet += '	"Coord" : [ '
	cJsonRet += '	"VAZIO" '
	cJsonRet += '	]'
	cJsonRet += '}'	
	::SetResponse(FwNoAccent(cJsonRet))	
EndIf

RestArea(_aArea)

Return(.T.)



WsMethod GET WSRECEIVE CodCateg WSSERVICE categProduto

Local _aArea 	 	:= GetArea()
Local _cQuery 		:= ""
Local cNextAlias 	:= GetNextAlias()
Local _cXml 		:= ''
Local _cCodCateg		:= Iif(ValType(Self:CodCateg) <> 'U',Self:CodCateg,'')
Local cJsonRet		:= ''

::SetContentType('application/xml')

_cQuery := " SELECT * " + CRLF
_cQuery += " FROM " + RetSqlName("ZZD") + " ZZD " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += " ZZD.ZZD_FILIAL = '" + FWxFilial('ZZD') + "' " + CRLF
If !Empty(_cCodCateg)
	_cQuery += " AND ZZD.ZZD_COD = '" + AllTrim(_cCodCateg) + "' " + CRLF
EndIf
_cQuery += " AND ZZD.D_E_L_E_T_ = ' ' " + CRLF
_cQuery += " ORDER BY ZZD.ZZD_COD, ZZD.ZZD_CATEG " 
_cQuery := ChangeQuery(_cQuery)

If Select(cNextAlias) > 0
	dbSelectArea(cNextAlias)
	dbCloseArea()
	cNextAlias 	:= GetNextAlias()
EndIf

dbUseArea(.T.,'TOPCONN',TCGENQRY(,,_cQuery),cNextAlias,.T.,.T.)
dbSelectArea(cNextAlias)
If !(cNextAlias)->(Eof()) .And. !(cNextAlias)->(Bof())
	
	cJsonRet := '{'
	cJsonRet += '	"Categoria" : [ '

	While !(cNextAlias)->(Eof())
		cJsonRet +=	'{'
		cJsonRet += '"codCateg": "'      +  AllTrim((cNextAlias)->ZZD_COD) + '",'
		cJsonRet += '"categDescription": "' +  AllTrim((cNextAlias)->ZZD_CATEG)  + '",'	
		cJsonRet += ' },'
		(cNextAlias)->(dbSkip())
	EndDo

	cJsonRet := substr( Alltrim(cJsonRet) , 1 , len(Alltrim(cJsonRet)) -1 )
	cJsonRet += '	]'
	cJsonRet += '}'
	cJsonRet := StrTran(cJsonRet,Chr(129),"")
	cJsonRet := StrTran(cJsonRet,Chr(141),"")
	cJsonRet := StrTran(cJsonRet,Chr(143),"")
	cJsonRet := StrTran(cJsonRet,Chr(144),"")
	cJsonRet := StrTran(cJsonRet,Chr(157),"")
	cJsonRet := StrTran(cJsonRet,Chr(9),"")
	cJsonRet := StrTran(cJsonRet,Chr(10),"")
	cJsonRet := StrTran(cJsonRet,Chr(13),"")
	conout("WSREST - " + cJsonRet)
	cJsonRet := FwCutOff(cJsonRet,.F.)		
	::SetResponse(FwNoAccent(cJsonRet))			
Else
	cJsonRet := '{'
	cJsonRet += '	"Coord" : [ '
	cJsonRet += '	"VAZIO" '
	cJsonRet += '	]'
	cJsonRet += '}'	
	::SetResponse(FwNoAccent(cJsonRet))	
EndIf

RestArea(_aArea)

Return(.T.)



WsMethod GET WSRECEIVE CodCarga WSSERVICE cargaProduto

Local _aArea 	 	:= GetArea()
Local _cQuery 		:= ""
Local cNextAlias 	:= GetNextAlias()
Local _cXml 		:= ''
Local _cCodCarga		:= Iif(ValType(Self:CodCarga) <> 'U',Self:CodCarga,'')
Local cJsonRet		:= ''

::SetContentType('application/xml')

_cQuery := " SELECT * " + CRLF
_cQuery += " FROM " + RetSqlName("DB0") + " DB0 " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += " DB0.DB0_FILIAL = '" + FWxFilial('DB0') + "' " + CRLF
If !Empty(_cCodCarga)
	_cQuery += " AND DB0.DB0_CODMOD = '" + AllTrim(_cCodCarga) + "' " + CRLF
EndIf
_cQuery += " AND DB0.D_E_L_E_T_ = ' ' " + CRLF
_cQuery += " ORDER BY DB0.DB0_CODMOD " 
_cQuery := ChangeQuery(_cQuery)

Conout('QUERY - ' + _cQuery)
If Select(cNextAlias) > 0
	dbSelectArea(cNextAlias)
	dbCloseArea()
	cNextAlias 	:= GetNextAlias()
EndIf

dbUseArea(.T.,'TOPCONN',TCGENQRY(,,_cQuery),cNextAlias,.T.,.T.)
dbSelectArea(cNextAlias)
If !(cNextAlias)->(Eof()) .And. !(cNextAlias)->(Bof())

	cJsonRet := '{'
	cJsonRet += '	"Carga" : [ '

	While !(cNextAlias)->(Eof())
		cJsonRet +=	'{'
		cJsonRet += '"codCarga": "'      +  AllTrim((cNextAlias)->DB0_CODMOD) + '",'
		cJsonRet += '"cargaDescription": "' +  AllTrim((cNextAlias)->DB0_DESMOD)  + '",'	
		cJsonRet += ' },'
		(cNextAlias)->(dbSkip())
	EndDo

	cJsonRet := substr( Alltrim(cJsonRet) , 1 , len(Alltrim(cJsonRet)) -1 )
	cJsonRet += '	]'
	cJsonRet += '}'
	cJsonRet := StrTran(cJsonRet,Chr(129),"")
	cJsonRet := StrTran(cJsonRet,Chr(141),"")
	cJsonRet := StrTran(cJsonRet,Chr(143),"")
	cJsonRet := StrTran(cJsonRet,Chr(144),"")
	cJsonRet := StrTran(cJsonRet,Chr(157),"")
	cJsonRet := StrTran(cJsonRet,Chr(9),"")
	cJsonRet := StrTran(cJsonRet,Chr(10),"")
	cJsonRet := StrTran(cJsonRet,Chr(13),"")
	conout("WSREST - " + cJsonRet)
	cJsonRet := FwCutOff(cJsonRet,.F.)		
	::SetResponse(FwNoAccent(cJsonRet))	

Else
	cJsonRet := '{'
	cJsonRet += '	"Carga" : [ '
	cJsonRet += '	"VAZIO" '
	cJsonRet += '	]'
	cJsonRet += '}'	
	::SetResponse(FwNoAccent(cJsonRet))	
EndIf

RestArea(_aArea)

Return(.T.)





WsMethod GET WSRECEIVE CodGrpTribut WSSERVICE grpTributarioProduto

Local _aArea 	 	:= GetArea()
Local _cQuery 		:= ""
Local cNextAlias 	:= GetNextAlias()
Local _cXml 		:= ''
Local _cCodGrpTribut		:= Iif(ValType(Self:CodGrpTribut) <> 'U',Self:CodGrpTribut,'')
Local cJsonRet		:= ''

::SetContentType('application/xml')

_cQuery := " SELECT * " + CRLF
_cQuery += " FROM " + RetSqlName("SX5") + " SX5 " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += " SX5.X5_FILIAL = '" + FWxFilial('SX5') + "' " + CRLF
If !Empty(_cCodGrpTribut)
	_cQuery += " AND SX5.X5_CHAVE = '" + AllTrim(_cCodGrpTribut) + "' " + CRLF
EndIf
_cQuery += " AND SX5.D_E_L_E_T_ = '' " + CRLF	
_cQuery += " AND SX5.X5_TABELA = '21' " + CRLF	
_cQuery += " ORDER BY SX5.X5_TABELA, SX5.X5_CHAVE " 

_cQuery := ChangeQuery(_cQuery)

If Select(cNextAlias) > 0
	dbSelectArea(cNextAlias)
	dbCloseArea()
	cNextAlias 	:= GetNextAlias()
EndIf

dbUseArea(.T.,'TOPCONN',TCGENQRY(,,_cQuery),cNextAlias,.T.,.T.)
dbSelectArea(cNextAlias)
If !(cNextAlias)->(Eof()) .And. !(cNextAlias)->(Bof())

	cJsonRet := '{'
	cJsonRet += '	"GrupoTributario" : [ '

	While !(cNextAlias)->(Eof())
		cJsonRet +=	'{'
		cJsonRet += '"chave": "'      +  AllTrim((cNextAlias)->X5_CHAVE) + '",'
		cJsonRet += '"grpTribDescription": "' +  AllTrim((cNextAlias)->X5_DESCRI)  + '",'	
		cJsonRet += ' },'
		(cNextAlias)->(dbSkip())
	EndDo

	cJsonRet := substr( Alltrim(cJsonRet) , 1 , len(Alltrim(cJsonRet)) -1 )
	cJsonRet += '	]'
	cJsonRet += '}'
	cJsonRet := StrTran(cJsonRet,Chr(129),"")
	cJsonRet := StrTran(cJsonRet,Chr(141),"")
	cJsonRet := StrTran(cJsonRet,Chr(143),"")
	cJsonRet := StrTran(cJsonRet,Chr(144),"")
	cJsonRet := StrTran(cJsonRet,Chr(157),"")
	cJsonRet := StrTran(cJsonRet,Chr(9),"")
	cJsonRet := StrTran(cJsonRet,Chr(10),"")
	cJsonRet := StrTran(cJsonRet,Chr(13),"")
	conout("WSREST - " + cJsonRet)
	cJsonRet := FwCutOff(cJsonRet,.F.)		
	::SetResponse(FwNoAccent(cJsonRet))		
Else
	cJsonRet := '{'
	cJsonRet += '	"Carga" : [ '
	cJsonRet += '	"VAZIO" '
	cJsonRet += '	]'
	cJsonRet += '}'	
	::SetResponse(FwNoAccent(cJsonRet))	
EndIf

RestArea(_aArea)

Return(.T.)




WsMethod GET WSRECEIVE CodOrigem WSSERVICE origemProduto

Local _aArea 	 	:= GetArea()
Local _cQuery 		:= ""
Local cNextAlias 	:= GetNextAlias()
Local _cXml 		:= ''
Local _cCodOrigem		:= Iif(ValType(Self:CodOrigem) <> 'U',Self:CodOrigem,'')
Local cJsonRet		:= ''

::SetContentType('application/xml')

_cQuery := " SELECT * " + CRLF
_cQuery += " FROM " + RetSqlName("SX5") + " SX5 " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += " SX5.X5_FILIAL = '" + FWxFilial('SX5') + "' " + CRLF
If !Empty(_cCodOrigem)
	_cQuery += " AND SX5.X5_CHAVE = '" + AllTrim(_cCodOrigem) + "' " + CRLF
EndIf
_cQuery += " AND SX5.X5_TABELA = 'S0' " + CRLF	
_cQuery += " AND SX5.D_E_L_E_T_ = '' " + CRLF
_cQuery += " ORDER BY SX5.X5_TABELA, SX5.X5_CHAVE " 
_cQuery := ChangeQuery(_cQuery)

If Select(cNextAlias) > 0
	dbSelectArea(cNextAlias)
	dbCloseArea()
	cNextAlias 	:= GetNextAlias()
EndIf

dbUseArea(.T.,'TOPCONN',TCGENQRY(,,_cQuery),cNextAlias,.T.,.T.)
dbSelectArea(cNextAlias)
If !(cNextAlias)->(Eof()) .And. !(cNextAlias)->(Bof())

	cJsonRet := '{'
	cJsonRet += '	"Origem" : [ '

	While !(cNextAlias)->(Eof())
		cJsonRet +=	'{'
		cJsonRet += '"origem": "'      +  AllTrim((cNextAlias)->X5_CHAVE) + '",'
		cJsonRet += '"origemDescription": "' +  AllTrim((cNextAlias)->X5_DESCRI)  + '",'	
		cJsonRet += ' },'
		(cNextAlias)->(dbSkip())
	EndDo

	cJsonRet := substr( Alltrim(cJsonRet) , 1 , len(Alltrim(cJsonRet)) -1 )
	cJsonRet += '	]'
	cJsonRet += '}'
	cJsonRet := StrTran(cJsonRet,Chr(129),"")
	cJsonRet := StrTran(cJsonRet,Chr(141),"")
	cJsonRet := StrTran(cJsonRet,Chr(143),"")
	cJsonRet := StrTran(cJsonRet,Chr(144),"")
	cJsonRet := StrTran(cJsonRet,Chr(157),"")
	cJsonRet := StrTran(cJsonRet,Chr(9),"")
	cJsonRet := StrTran(cJsonRet,Chr(10),"")
	cJsonRet := StrTran(cJsonRet,Chr(13),"")
	conout("WSREST - " + cJsonRet)
	cJsonRet := FwCutOff(cJsonRet,.F.)		
	::SetResponse(FwNoAccent(cJsonRet))	

Else
	cJsonRet := '{'
	cJsonRet += '	"Origem" : [ '
	cJsonRet += '	"VAZIO" '
	cJsonRet += '	]'
	cJsonRet += '}'	
	::SetResponse(FwNoAccent(cJsonRet))	
EndIf

RestArea(_aArea)

Return(.T.)



WsMethod GET WSRECEIVE CodCtCont WSSERVICE ctContProduto

Local _aArea 	 	:= GetArea()
Local _cQuery 		:= ""
Local cNextAlias 	:= GetNextAlias()
Local _cXml 		:= ''
Local _cCodCtCont		:= Iif(ValType(Self:CodCtCont) <> 'U',Self:CodCtCont,'')
Local cJsonRet		:= ''

::SetContentType('application/xml')

_cQuery := " SELECT * " + CRLF
_cQuery += " FROM " + RetSqlName("CT1") + " CT1 " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += " CT1.CT1_FILIAL = '" + FWxFilial('CT1') + "' " + CRLF
If !Empty(_cCodCtCont)
	_cQuery += " AND CT1.CT1_CONTA = '" + AllTrim(_cCodCtCont) + "' " + CRLF
EndIf
_cQuery += " AND CT1.D_E_L_E_T_ = '' " + CRLF
_cQuery += " ORDER BY CT1.CT1_CONTA, CT1.CT1_DESC01 " 
_cQuery := ChangeQuery(_cQuery)

If Select(cNextAlias) > 0
	dbSelectArea(cNextAlias)
	dbCloseArea()
	cNextAlias 	:= GetNextAlias()
EndIf

dbUseArea(.T.,'TOPCONN',TCGENQRY(,,_cQuery),cNextAlias,.T.,.T.)
dbSelectArea(cNextAlias)
If !(cNextAlias)->(Eof()) .And. !(cNextAlias)->(Bof())

	cJsonRet := '{'
	cJsonRet += '	"Conta" : [ '

	While !(cNextAlias)->(Eof())
		cJsonRet +=	'{'
		cJsonRet += '"codConta": "'      +  AllTrim((cNextAlias)->CT1_CONTA)  + '",'
		cJsonRet += '"contaDescription": "' +  AllTrim((cNextAlias)->CT1_DESC01)  + '",'	
		cJsonRet += ' },'
		(cNextAlias)->(dbSkip())
	EndDo

	cJsonRet := substr( Alltrim(cJsonRet) , 1 , len(Alltrim(cJsonRet)) -1 )
	cJsonRet += '	]'
	cJsonRet += '}'
	cJsonRet := StrTran(cJsonRet,Chr(129),"")
	cJsonRet := StrTran(cJsonRet,Chr(141),"")
	cJsonRet := StrTran(cJsonRet,Chr(143),"")
	cJsonRet := StrTran(cJsonRet,Chr(144),"")
	cJsonRet := StrTran(cJsonRet,Chr(157),"")
	cJsonRet := StrTran(cJsonRet,Chr(9),"")
	cJsonRet := StrTran(cJsonRet,Chr(10),"")
	cJsonRet := StrTran(cJsonRet,Chr(13),"")
	conout("WSREST - " + cJsonRet)
	cJsonRet := FwCutOff(cJsonRet,.F.)		
	::SetResponse(FwNoAccent(cJsonRet))		
Else
	cJsonRet := '{'
	cJsonRet += '	"Origem" : [ '
	cJsonRet += '	"VAZIO" '
	cJsonRet += '	]'
	cJsonRet += '}'	
	::SetResponse(FwNoAccent(cJsonRet))	
EndIf

RestArea(_aArea)

Return(.T.)






WsMethod GET WSRECEIVE codEmbala WSSERVICE embalagemProduto

Local _aArea 	 	:= GetArea()
Local _cQuery 		:= ""
Local cNextAlias 	:= GetNextAlias()
Local _cXml 		:= ''
Local _cCodEmb		:= Iif(ValType(Self:codEmbala) <> 'U',Self:codEmbala,'')
Local cJsonRet		:= ''

::SetContentType('application/xml')

_cQuery := " SELECT * " + CRLF
_cQuery += " FROM " + RetSqlName("ZZ1") + " ZZ1 " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += " ZZ1.ZZ1_FILIAL = '" + FWxFilial('ZZ1') + "' " + CRLF
If !Empty(_cCodEmb)
	_cQuery += " AND ZZ1.ZZ1_COD = '" + AllTrim(_cCodEmb) + "' " + CRLF
EndIf
_cQuery += " AND ZZ1.D_E_L_E_T_ = ' ' " + CRLF
_cQuery += " ORDER BY ZZ1.ZZ1_COD " 
_cQuery := ChangeQuery(_cQuery)

Conout('QUERY - ' + _cQuery)
If Select(cNextAlias) > 0
	dbSelectArea(cNextAlias)
	dbCloseArea()
	cNextAlias 	:= GetNextAlias()
EndIf

dbUseArea(.T.,'TOPCONN',TCGENQRY(,,_cQuery),cNextAlias,.T.,.T.)
dbSelectArea(cNextAlias)
If !(cNextAlias)->(Eof()) .And. !(cNextAlias)->(Bof())

	cJsonRet := '{'
	cJsonRet += '	"Embalagem" : [ '

	While !(cNextAlias)->(Eof())
		cJsonRet +=	'{'
		cJsonRet += '"codEmbalagem": "'      +  AllTrim((cNextAlias)->ZZ1_COD)  + '",'
		cJsonRet += '"embDescription": "' +  AllTrim((cNextAlias)->ZZ1_DESC)  + '",'	
		cJsonRet += ' },'
		(cNextAlias)->(dbSkip())
	EndDo

	cJsonRet := substr( Alltrim(cJsonRet) , 1 , len(Alltrim(cJsonRet)) -1 )
	cJsonRet += '	]'
	cJsonRet += '}'
	cJsonRet := StrTran(cJsonRet,Chr(129),"")
	cJsonRet := StrTran(cJsonRet,Chr(141),"")
	cJsonRet := StrTran(cJsonRet,Chr(143),"")
	cJsonRet := StrTran(cJsonRet,Chr(144),"")
	cJsonRet := StrTran(cJsonRet,Chr(157),"")
	cJsonRet := StrTran(cJsonRet,Chr(9),"")
	cJsonRet := StrTran(cJsonRet,Chr(10),"")
	cJsonRet := StrTran(cJsonRet,Chr(13),"")
	conout("WSREST - " + cJsonRet)
	cJsonRet := FwCutOff(cJsonRet,.F.)		
	::SetResponse(FwNoAccent(cJsonRet))			
Else
	cJsonRet := '{'
	cJsonRet += '	"Origem" : [ '
	cJsonRet += '	"VAZIO" '
	cJsonRet += '	]'
	cJsonRet += '}'	
	::SetResponse(FwNoAccent(cJsonRet))	
EndIf

RestArea(_aArea)

Return(.T.)



WsMethod GET WSRECEIVE codArmazem, codFilial WSSERVICE armazemProduto

Local _aArea 	 	:= GetArea()
Local _cQuery 		:= ""
Local cNextAlias 	:= GetNextAlias()
Local _cXml 		:= ''
Local _cCodArmazem		:= Iif(ValType(Self:codArmazem) <> 'U',Self:codArmazem,'')
Local _cCodFilial	:= Iif(ValType(Self:codFilial) <> 'U',Self:codFilial,'')
Local cJsonRet		:= ''

::SetContentType('application/xml')

_cQuery := " SELECT *,D_E_L_E_T_ as DEL " + CRLF
_cQuery += " FROM " + RetSqlName("NNR") + " NNR " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += " NNR.NNR_FILIAL = '" + xFilial('NNR',_cCodFilial) + "' " + CRLF
If !Empty(_cCodArmazem)
	_cQuery += " AND NNR.NNR_CODIGO = '" + AllTrim(_cCodArmazem) + "' " + CRLF
EndIf
//_cQuery += " AND NNR.D_E_L_E_T_ = ' ' " + CRLF
_cQuery += " ORDER BY NNR.NNR_CODIGO " 
_cQuery := ChangeQuery(_cQuery)

Conout('QUERY - ' + _cQuery)
If Select(cNextAlias) > 0
	dbSelectArea(cNextAlias)
	dbCloseArea()
	cNextAlias 	:= GetNextAlias()
EndIf

dbUseArea(.T.,'TOPCONN',TCGENQRY(,,_cQuery),cNextAlias,.T.,.T.)
dbSelectArea(cNextAlias)
If !(cNextAlias)->(Eof()) .And. !(cNextAlias)->(Bof())

	cJsonRet := '{'
	cJsonRet += '	"Armazem" : [ '

	While !(cNextAlias)->(Eof())
		cJsonRet +=	'{'
		cJsonRet += '"filial": "'      +  AllTrim((cNextAlias)->NNR_FILIAL)  + '",'
		cJsonRet += '"codArmazem": "'      +  AllTrim((cNextAlias)->NNR_CODIGO)  + '",'
		cJsonRet += '"ArmazemDescription": "' +  AllTrim((cNextAlias)->NNR_DESCRI)  + '",'	
		cJsonRet += '"Deletado": "' +  IIF((cNextAlias)->DEL == ' ' ,'false','true')    + '",'	
		cJsonRet += ' },'
		(cNextAlias)->(dbSkip())
	EndDo

	cJsonRet := substr( Alltrim(cJsonRet) , 1 , len(Alltrim(cJsonRet)) -1 )
	cJsonRet += '	]'
	cJsonRet += '}'
	cJsonRet := StrTran(cJsonRet,Chr(129),"")
	cJsonRet := StrTran(cJsonRet,Chr(141),"")
	cJsonRet := StrTran(cJsonRet,Chr(143),"")
	cJsonRet := StrTran(cJsonRet,Chr(144),"")
	cJsonRet := StrTran(cJsonRet,Chr(157),"")
	cJsonRet := StrTran(cJsonRet,Chr(9),"")
	cJsonRet := StrTran(cJsonRet,Chr(10),"")
	cJsonRet := StrTran(cJsonRet,Chr(13),"")
	conout("WSREST - " + cJsonRet)
	cJsonRet := FwCutOff(cJsonRet,.F.)		
	::SetResponse(FwNoAccent(cJsonRet))		
Else
	cJsonRet := '{'
	cJsonRet += '	"Origem" : [ '
	cJsonRet += '	"VAZIO" '
	cJsonRet += '	]'
	cJsonRet += '}'	
	::SetResponse(FwNoAccent(cJsonRet))	
EndIf

RestArea(_aArea)

Return(.T.)




WsMethod GET WSRECEIVE codCC WSSERVICE CentroCusto

Local _aArea 	 	:= GetArea()
Local _cQuery 		:= ""
Local cNextAlias 	:= GetNextAlias()
Local _cXml 		:= ''
Local _cCodCC		:= Iif(ValType(Self:codCC) <> 'U',Self:codCC,'')
Local cJsonRet		:= ''

::SetContentType('application/xml')

_cQuery := " SELECT * " + CRLF
_cQuery += " FROM " + RetSqlName("CTT") + " CTT " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += " CTT.CTT_FILIAL = '" + FWxFilial('CTT') + "' " + CRLF
If !Empty(_cCodCC)
	_cQuery += " AND CTT.CTT_CUSTO = '" + AllTrim(_cCodCC) + "' " + CRLF
EndIf
_cQuery += " AND CTT.D_E_L_E_T_ = ' ' " + CRLF
_cQuery += " ORDER BY CTT.CTT_CUSTO " 
_cQuery := ChangeQuery(_cQuery)

Conout('QUERY - ' + _cQuery)
If Select(cNextAlias) > 0
	dbSelectArea(cNextAlias)
	dbCloseArea()
	cNextAlias 	:= GetNextAlias()
EndIf

dbUseArea(.T.,'TOPCONN',TCGENQRY(,,_cQuery),cNextAlias,.T.,.T.)
dbSelectArea(cNextAlias)
If !(cNextAlias)->(Eof()) .And. !(cNextAlias)->(Bof())

	cJsonRet := '{'
	cJsonRet += '	"CentroCusto" : [ '

	While !(cNextAlias)->(Eof())
		cJsonRet +=	'{'
		cJsonRet += '"CentroCusto": "'      +  AllTrim((cNextAlias)->CTT_CUSTO)   + '",'
		cJsonRet += '"CentroCustoDescription": "' +  AllTrim((cNextAlias)->CTT_DESC01)  + '",'	
		cJsonRet += ' },'
		(cNextAlias)->(dbSkip())
	EndDo

	cJsonRet := substr( Alltrim(cJsonRet) , 1 , len(Alltrim(cJsonRet)) -1 )
	cJsonRet += '	]'
	cJsonRet += '}'
	cJsonRet := StrTran(cJsonRet,Chr(129),"")
	cJsonRet := StrTran(cJsonRet,Chr(141),"")
	cJsonRet := StrTran(cJsonRet,Chr(143),"")
	cJsonRet := StrTran(cJsonRet,Chr(144),"")
	cJsonRet := StrTran(cJsonRet,Chr(157),"")
	cJsonRet := StrTran(cJsonRet,Chr(9),"")
	cJsonRet := StrTran(cJsonRet,Chr(10),"")
	cJsonRet := StrTran(cJsonRet,Chr(13),"")
	conout("WSREST - " + cJsonRet)
	cJsonRet := FwCutOff(cJsonRet,.F.)		
	::SetResponse(FwNoAccent(cJsonRet))			
Else
	cJsonRet := '{'
	cJsonRet += '	"Origem" : [ '
	cJsonRet += '	"VAZIO" '
	cJsonRet += '	]'
	cJsonRet += '}'	
	::SetResponse(FwNoAccent(cJsonRet))	
EndIf

RestArea(_aArea)

Return(.T.)




WsMethod GET WSRECEIVE codResp, codFilial WSSERVICE RespTecnico

Local _aArea 	 	:= GetArea()
Local _cQuery 		:= ""
Local cNextAlias 	:= GetNextAlias()
Local _cXml 		:= ''
Local _cCodResp		:= Iif(ValType(Self:codResp) <> 'U',Self:codResp,'')
Local _cCodFilial		:= Iif(ValType(Self:codFilial) <> 'U',Self:codfilial,'')
Local cJsonRet		:= ''

::SetContentType('application/xml')

_cQuery := " SELECT *,D_E_L_E_T_ as DEL " + CRLF
_cQuery += " FROM " + RetSqlName("QAA") + " QAA " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += " QAA.QAA_FILIAL = '" + xFilial('QAA', _cCodFilial) + "' " + CRLF
If !Empty(_cCodResp)
	_cQuery += " AND QAA.QAA_MAT = '" + AllTrim(_cCodResp) + "' " + CRLF
EndIf
//_cQuery += " AND QAA.D_E_L_E_T_ = ' ' " + CRLF
_cQuery += " ORDER BY QAA.QAA_MAT " 
_cQuery := ChangeQuery(_cQuery)

Conout('QUERY - ' + _cQuery)
If Select(cNextAlias) > 0
	dbSelectArea(cNextAlias)
	dbCloseArea()
	cNextAlias 	:= GetNextAlias()
EndIf

dbUseArea(.T.,'TOPCONN',TCGENQRY(,,_cQuery),cNextAlias,.T.,.T.)
dbSelectArea(cNextAlias)
If !(cNextAlias)->(Eof()) .And. !(cNextAlias)->(Bof())

	cJsonRet := '{'
	cJsonRet += '	"ResponsavelTecnico" : [ '

	While !(cNextAlias)->(Eof())
		cJsonRet +=	'{'
		cJsonRet += '"Filial": "' +  AllTrim((cNextAlias)->QAA_FILIAL)  + '",'	
		cJsonRet += '"Matricula": "'      +  AllTrim((cNextAlias)->QAA_MAT)   + '",'
		cJsonRet += '"Nome": "' +  AllTrim((cNextAlias)->QAA_NOME)  + '",'	
		cJsonRet += '"Crq": "' +  AllTrim((cNextAlias)->QAA_XCRQ)  + '",'	
		cJsonRet += '"Deletado": "' +  IIF((cNextAlias)->DEL == ' ' ,'false','true')    + '",'	
		cJsonRet += ' },'
		(cNextAlias)->(dbSkip())
	EndDo

	cJsonRet := substr( Alltrim(cJsonRet) , 1 , len(Alltrim(cJsonRet)) -1 )
	cJsonRet += '	]'
	cJsonRet += '}'
	cJsonRet := StrTran(cJsonRet,Chr(129),"")
	cJsonRet := StrTran(cJsonRet,Chr(141),"")
	cJsonRet := StrTran(cJsonRet,Chr(143),"")
	cJsonRet := StrTran(cJsonRet,Chr(144),"")
	cJsonRet := StrTran(cJsonRet,Chr(157),"")
	cJsonRet := StrTran(cJsonRet,Chr(9),"")
	cJsonRet := StrTran(cJsonRet,Chr(10),"")
	cJsonRet := StrTran(cJsonRet,Chr(13),"")
	conout("WSREST - " + cJsonRet)
	cJsonRet := FwCutOff(cJsonRet,.F.)		
	::SetResponse(FwNoAccent(cJsonRet))			
Else
	cJsonRet := '{'
	cJsonRet += '	"Origem" : [ '
	cJsonRet += '	"VAZIO" '
	cJsonRet += '	]'
	cJsonRet += '}'	
	::SetResponse(FwNoAccent(cJsonRet))	
EndIf

RestArea(_aArea)

Return(.T.)





WsMethod GET WSRECEIVE codServ WSSERVICE servicosWms

Local _aArea 	 	:= GetArea()
Local _cQuery 		:= ""
Local cNextAlias 	:= GetNextAlias()
Local _cXml 		:= ''
Local _cCodServ	:= Iif(ValType(Self:codServ) <> 'U',Self:codServ,'')
Local cJsonRet		:= ''

::SetContentType('application/xml')

_cQuery := " SELECT DC5_SERVIC , X5_DESCRI " + CRLF
_cQuery += " FROM " + RetSqlName("DC5") + " DC5 " + CRLF
_cQuery += " INNER JOIN " + RetSqlName("SX5") + " SX5 ON X5_TABELA = 'L4' AND X5_CHAVE = DC5_SERVIC AND SX5.D_E_L_E_T_ = ' ' " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += " DC5.DC5_FILIAL = '" + FWxFilial('DC5') + "' " + CRLF
If !Empty(_cCodServ)
	_cQuery += " AND DC5.DC5_SERVIC = '" + AllTrim(_cCodServ) + "' " + CRLF
EndIf
_cQuery += " AND DC5.D_E_L_E_T_ = ' ' " + CRLF
_cQuery += " ORDER BY DC5.DC5_SERVIC " 
_cQuery := ChangeQuery(_cQuery)

Conout('QUERY - ' + _cQuery)
If Select(cNextAlias) > 0
	dbSelectArea(cNextAlias)
	dbCloseArea()
	cNextAlias 	:= GetNextAlias()
EndIf

dbUseArea(.T.,'TOPCONN',TCGENQRY(,,_cQuery),cNextAlias,.T.,.T.)
dbSelectArea(cNextAlias)
If !(cNextAlias)->(Eof()) .And. !(cNextAlias)->(Bof())

	cJsonRet := '{'
	cJsonRet += '	"ServicosWMS" : [ '

	While !(cNextAlias)->(Eof())
		cJsonRet +=	'{'
		cJsonRet += '"Servico": "'      +  AllTrim((cNextAlias)->DC5_SERVIC)   + '" ,'
		cJsonRet += '"Descricao": "'      +  AllTrim((cNextAlias)->X5_DESCRI)   + '" '
		cJsonRet += ' },'
		(cNextAlias)->(dbSkip())
	EndDo

	cJsonRet := substr( Alltrim(cJsonRet) , 1 , len(Alltrim(cJsonRet)) -1 )
	cJsonRet += '	]'
	cJsonRet += '}'
	cJsonRet := StrTran(cJsonRet,Chr(129),"")
	cJsonRet := StrTran(cJsonRet,Chr(141),"")
	cJsonRet := StrTran(cJsonRet,Chr(143),"")
	cJsonRet := StrTran(cJsonRet,Chr(144),"")
	cJsonRet := StrTran(cJsonRet,Chr(157),"")
	cJsonRet := StrTran(cJsonRet,Chr(9),"")
	cJsonRet := StrTran(cJsonRet,Chr(10),"")
	cJsonRet := StrTran(cJsonRet,Chr(13),"")
	conout("WSREST - " + cJsonRet)
	cJsonRet := FwCutOff(cJsonRet,.F.)		
	::SetResponse(FwNoAccent(cJsonRet))			
Else
	cJsonRet := '{'
	cJsonRet += '	"Origem" : [ '
	cJsonRet += '	"VAZIO" '
	cJsonRet += '	]'
	cJsonRet += '}'	
	::SetResponse(FwNoAccent(cJsonRet))	
EndIf

RestArea(_aArea)

Return(.T.)



WsMethod GET WSRECEIVE codEnd, codFilial WSSERVICE enderecos

Local _aArea 	 	:= GetArea()
Local _cQuery 		:= ""
Local cNextAlias 	:= GetNextAlias()
Local _cXml 		:= ''
Local _cCodEnd	:= Iif(ValType(Self:codEnd) <> 'U',Self:codEnd,'')
Local _cCodFil	:= Iif(ValType(Self:codFilial) <> 'U',Self:codFilial,'')
Local cJsonRet		:= ''

::SetContentType('application/xml')

_cQuery := " SELECT *,D_E_L_E_T_ as DEL " + CRLF
_cQuery += " FROM " + RetSqlName("SBE") + " SBE " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += " SBE.BE_FILIAL = '" + xFilial('SBE',_cCodFil) + "' " + CRLF
If !Empty(_cCodEnd)
	_cQuery += " AND SBE.BE_LOCALIZ = '" + AllTrim(_cCodEnd) + "' " + CRLF
EndIf
//_cQuery += " AND SBE.D_E_L_E_T_ = ' ' " + CRLF
_cQuery += " ORDER BY SBE.BE_LOCALIZ " 
_cQuery := ChangeQuery(_cQuery)

Conout('QUERY - ' + _cQuery)
If Select(cNextAlias) > 0
	dbSelectArea(cNextAlias)
	dbCloseArea()
	cNextAlias 	:= GetNextAlias()
EndIf

dbUseArea(.T.,'TOPCONN',TCGENQRY(,,_cQuery),cNextAlias,.T.,.T.)
dbSelectArea(cNextAlias)
If !(cNextAlias)->(Eof()) .And. !(cNextAlias)->(Bof())

	cJsonRet := '{'
	cJsonRet += '	"enderecos" : [ '

	While !(cNextAlias)->(Eof())
		cJsonRet +=	'{'
		cJsonRet += '"endereco": "'      +  AllTrim((cNextAlias)->BE_LOCALIZ)   + '" ,'
		cJsonRet += '"descricao": "'      +  AllTrim((cNextAlias)->BE_DESCRIC)   + '", '
		cJsonRet += '"Deletado": "' +  IIF((cNextAlias)->DEL == ' ' ,'false','true')    + '",'	
		cJsonRet += ' },'
		(cNextAlias)->(dbSkip())
	EndDo

	cJsonRet := substr( Alltrim(cJsonRet) , 1 , len(Alltrim(cJsonRet)) -1 )
	cJsonRet += '	]'
	cJsonRet += '}'
	cJsonRet := StrTran(cJsonRet,Chr(129),"")
	cJsonRet := StrTran(cJsonRet,Chr(141),"")
	cJsonRet := StrTran(cJsonRet,Chr(143),"")
	cJsonRet := StrTran(cJsonRet,Chr(144),"")
	cJsonRet := StrTran(cJsonRet,Chr(157),"")
	cJsonRet := StrTran(cJsonRet,Chr(9),"")
	cJsonRet := StrTran(cJsonRet,Chr(10),"")
	cJsonRet := StrTran(cJsonRet,Chr(13),"")
	conout("WSREST - " + cJsonRet)
	cJsonRet := FwCutOff(cJsonRet,.F.)		
	::SetResponse(FwNoAccent(cJsonRet))			
Else
	cJsonRet := '{'
	cJsonRet += '	"enderecos" : [ '
	cJsonRet += '	"" '
	cJsonRet += '	]'
	cJsonRet += '}'	
	::SetResponse(FwNoAccent(cJsonRet))	
EndIf

RestArea(_aArea)

Return(.T.)


/*/{Protheus.doc} DXCONVDT
    Converte/Formata Dados
    @author B. Vinicius
    @since 29/08/2019
    /*/

User Function DXCONVDT(xValor,cCampo)

Local xRet := ""

If FWSX3Util():GetFieldType( cCampo  ) == "D" //Data
		xRet := CTOD(xValor)
Elseif FWSX3Util():GetFieldType( cCampo  ) == "C" //Caracter
        xRet := Left(xValor,TamSx3(cCampo)[1])
Elseif FWSX3Util():GetFieldType( cCampo  ) == "M" //Memo
        xRet := Alltrim(xValor)
Else //Numerico nao precisa converter
        xRet := xValor
Endif

Return xRet


WsRestful zonaArmazenagem Description "Zonas de Armazenagem" Format APPLICATION_JSON
	WSDATA codZona As String
	WsMethod GET Description "Retorna lista de Zonas de Armazenagem" WsSyntax "/GET/{method}"
End WsRestful


WsMethod GET WSRECEIVE codZona WSSERVICE zonaArmazenagem

Local _aArea 	 	:= GetArea()
Local _cQuery 		:= ""
Local cNextAlias 	:= GetNextAlias()
Local _cXml 		:= ''
Local _cCodZona	:= Iif(ValType(Self:codZona) <> 'U',Self:codZona,'')
Local cJsonRet		:= ''

::SetContentType('application/xml')

_cQuery := " SELECT *,D_E_L_E_T_ AS DEL " + CRLF
_cQuery += " FROM " + RetSqlName("DC4") + " DC4 " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += " DC4.DC4_FILIAL = '" + FWxFilial('DC4') + "' " + CRLF
If !Empty(_cCodZona)
	_cQuery += " AND DC4.DC4_CODZON = '" + AllTrim(_cCodZona) + "' " + CRLF
EndIf
//_cQuery += " AND DC4.D_E_L_E_T_ = ' ' " + CRLF
_cQuery += " ORDER BY DC4.DC4_CODZON " 
_cQuery := ChangeQuery(_cQuery)

Conout('QUERY - ' + _cQuery)
If Select(cNextAlias) > 0
	dbSelectArea(cNextAlias)
	dbCloseArea()
	cNextAlias 	:= GetNextAlias()
EndIf

dbUseArea(.T.,'TOPCONN',TCGENQRY(,,_cQuery),cNextAlias,.T.,.T.)
dbSelectArea(cNextAlias)
If !(cNextAlias)->(Eof()) .And. !(cNextAlias)->(Bof())

	cJsonRet := '{'
	cJsonRet += '	"ZonasArmazenamento" : [ '

	While !(cNextAlias)->(Eof())
		cJsonRet +=	'{'
		cJsonRet += '"codigo": "'      +  AllTrim((cNextAlias)->DC4_CODZON)   + '" ,'
		cJsonRet += '"descricao": "'      +  AllTrim((cNextAlias)->DC4_DESZON)   + '", '
		cJsonRet += '"Deletado": "' +  IIF((cNextAlias)->DEL == ' ' ,'false','true')    + '" '	
		cJsonRet += ' },'
		(cNextAlias)->(dbSkip())
	EndDo

	cJsonRet := substr( Alltrim(cJsonRet) , 1 , len(Alltrim(cJsonRet)) -1 )
	cJsonRet += '	]'
	cJsonRet += '}'
	cJsonRet := StrTran(cJsonRet,Chr(129),"")
	cJsonRet := StrTran(cJsonRet,Chr(141),"")
	cJsonRet := StrTran(cJsonRet,Chr(143),"")
	cJsonRet := StrTran(cJsonRet,Chr(144),"")
	cJsonRet := StrTran(cJsonRet,Chr(157),"")
	cJsonRet := StrTran(cJsonRet,Chr(9),"")
	cJsonRet := StrTran(cJsonRet,Chr(10),"")
	cJsonRet := StrTran(cJsonRet,Chr(13),"")
	conout("WSREST - " + cJsonRet)
	cJsonRet := FwCutOff(cJsonRet,.F.)		
	::SetResponse(FwNoAccent(cJsonRet))			
Else
	cJsonRet := '{'
	cJsonRet += '	"Origem" : [ '
	cJsonRet += '	"VAZIO" '
	cJsonRet += '	]'
	cJsonRet += '}'	
	::SetResponse(FwNoAccent(cJsonRet))	
EndIf

RestArea(_aArea)

Return(.T.)




WsRestful Fornecedores Description "Fornecedores" Format APPLICATION_JSON
	WSDATA codForn As String
	WSDATA codLoja As String
	WsMethod GET Description "Retorna lista de Fornecedores" WsSyntax "/GET/{method}"
End WsRestful


WsMethod GET WSRECEIVE codForn,codLoja WSSERVICE Fornecedores

Local _aArea 	 	:= GetArea()
Local _cQuery 		:= ""
Local cNextAlias 	:= GetNextAlias()
Local _cXml 		:= ''
Local _cCodForn	:= Iif(ValType(Self:codForn) <> 'U',Self:codForn,'')
Local _cCodLoja	:= Iif(ValType(Self:codLoja) <> 'U',Self:codLoja,'')
Local cJsonRet		:= ''

::SetContentType('application/xml')

_cQuery := " SELECT * " + CRLF
_cQuery += " FROM " + RetSqlName("SA2") + " SA2 " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += " SA2.A2_FILIAL = '" + FWxFilial('SA2') + "' " + CRLF
If !Empty(_cCodForn)
	_cQuery += " AND SA2.A2_COD = '" + AllTrim(_cCodForn) + "' " + CRLF
EndIf
If !Empty(_cCodLoja)
	_cQuery += " AND SA2.A2_LOJA = '" + AllTrim(_cCodLoja) + "' " + CRLF
EndIf
_cQuery += " AND SA2.D_E_L_E_T_ = ' ' " + CRLF
_cQuery += " ORDER BY SA2.A2_COD " 
_cQuery := ChangeQuery(_cQuery)

Conout('QUERY - ' + _cQuery)
If Select(cNextAlias) > 0
	dbSelectArea(cNextAlias)
	dbCloseArea()
	cNextAlias 	:= GetNextAlias()
EndIf

dbUseArea(.T.,'TOPCONN',TCGENQRY(,,_cQuery),cNextAlias,.T.,.T.)
dbSelectArea(cNextAlias)
If !(cNextAlias)->(Eof()) .And. !(cNextAlias)->(Bof())

	cJsonRet := '{'
	cJsonRet += '	"Fornecedores" : [ '

	While !(cNextAlias)->(Eof())
		cJsonRet +=	'{'
		cJsonRet += '"codigo": "'      +  AllTrim((cNextAlias)->A2_COD)   + '" ,'
		cJsonRet += '"loja": "'      +  AllTrim((cNextAlias)->A2_LOJA)   + '" ,'
		cJsonRet += '"nome": "'      +  AllTrim((cNextAlias)->A2_NOME)   + '" '
		cJsonRet += ' },'
		(cNextAlias)->(dbSkip())
	EndDo

	cJsonRet := substr( Alltrim(cJsonRet) , 1 , len(Alltrim(cJsonRet)) -1 )
	cJsonRet += '	]'
	cJsonRet += '}'
	cJsonRet := StrTran(cJsonRet,Chr(129),"")
	cJsonRet := StrTran(cJsonRet,Chr(141),"")
	cJsonRet := StrTran(cJsonRet,Chr(143),"")
	cJsonRet := StrTran(cJsonRet,Chr(144),"")
	cJsonRet := StrTran(cJsonRet,Chr(157),"")
	cJsonRet := StrTran(cJsonRet,Chr(9),"")
	cJsonRet := StrTran(cJsonRet,Chr(10),"")
	cJsonRet := StrTran(cJsonRet,Chr(13),"")
	conout("WSREST - " + cJsonRet)
	cJsonRet := FwCutOff(cJsonRet,.F.)		
	::SetResponse(FwNoAccent(cJsonRet))			
Else
	cJsonRet := '{'
	cJsonRet += '	"Origem" : [ '
	cJsonRet += '	"VAZIO" '
	cJsonRet += '	]'
	cJsonRet += '}'	
	::SetResponse(FwNoAccent(cJsonRet))	
EndIf

RestArea(_aArea)

Return(.T.)




WsRestful Paises Description "Paises" Format APPLICATION_JSON
	WSDATA codPais As String
	WsMethod GET Description "Retorna lista de Paises" WsSyntax "/GET/{method}"
End WsRestful


WsMethod GET WSRECEIVE codPais WSSERVICE Paises

Local _aArea 	 	:= GetArea()
Local _cQuery 		:= ""
Local cNextAlias 	:= GetNextAlias()
Local _cXml 		:= ''
Local _cCodPais	:= Iif(ValType(Self:codPais) <> 'U',Self:codPais,'')
Local cJsonRet		:= ''

::SetContentType('application/xml')

_cQuery := " SELECT * " + CRLF
_cQuery += " FROM " + RetSqlName("CCH") + " CCH " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += " CCH.CCH_FILIAL = '" + FWxFilial('CCH') + "' " + CRLF
If !Empty(_cCodPais)
	_cQuery += " AND CCH.CCH_CODIGO = '" + AllTrim(_cCodPais) + "' " + CRLF
EndIf

_cQuery += " AND CCH.D_E_L_E_T_ = ' ' " + CRLF
_cQuery += " ORDER BY CCH.CCH_CODIGO " 
_cQuery := ChangeQuery(_cQuery)

Conout('QUERY - ' + _cQuery)
If Select(cNextAlias) > 0
	dbSelectArea(cNextAlias)
	dbCloseArea()
	cNextAlias 	:= GetNextAlias()
EndIf

dbUseArea(.T.,'TOPCONN',TCGENQRY(,,_cQuery),cNextAlias,.T.,.T.)
dbSelectArea(cNextAlias)
If !(cNextAlias)->(Eof()) .And. !(cNextAlias)->(Bof())

	cJsonRet := '{'
	cJsonRet += '	"Paises" : [ '

	While !(cNextAlias)->(Eof())
		cJsonRet +=	'{'
		cJsonRet += '"codigo": "'      +  AllTrim((cNextAlias)->CCH_CODIGO)   + '" ,'
		cJsonRet += '"nome": "'      +  AllTrim((cNextAlias)->CCH_PAIS)   + '" '
		cJsonRet += ' },'
		(cNextAlias)->(dbSkip())
	EndDo

	cJsonRet := substr( Alltrim(cJsonRet) , 1 , len(Alltrim(cJsonRet)) -1 )
	cJsonRet += '	]'
	cJsonRet += '}'
	cJsonRet := StrTran(cJsonRet,Chr(129),"")
	cJsonRet := StrTran(cJsonRet,Chr(141),"")
	cJsonRet := StrTran(cJsonRet,Chr(143),"")
	cJsonRet := StrTran(cJsonRet,Chr(144),"")
	cJsonRet := StrTran(cJsonRet,Chr(157),"")
	cJsonRet := StrTran(cJsonRet,Chr(9),"")
	cJsonRet := StrTran(cJsonRet,Chr(10),"")
	cJsonRet := StrTran(cJsonRet,Chr(13),"")
	conout("WSREST - " + cJsonRet)
	cJsonRet := FwCutOff(cJsonRet,.F.)		
	::SetResponse(FwNoAccent(cJsonRet))			
Else
	cJsonRet := '{'
	cJsonRet += '	"Origem" : [ '
	cJsonRet += '	"VAZIO" '
	cJsonRet += '	]'
	cJsonRet += '}'	
	::SetResponse(FwNoAccent(cJsonRet))	
EndIf

RestArea(_aArea)

Return(.T.)



WsRestful Alergenicos Description "Alergenicos" Format APPLICATION_JSON
	WSDATA codAlergenico As String
	WsMethod GET Description "Retorna lista de Alergenicos" WsSyntax "/GET/{method}"
	WsMethod POST Description "inclui um registro de Alergenicos" WsSyntax "/GET/{method}"
End WsRestful


WsMethod GET WSRECEIVE codAlergenico WSSERVICE Alergenicos

Local _aArea 	 	:= GetArea()
Local _cQuery 		:= ""
Local cNextAlias 	:= GetNextAlias()
Local _cXml 		:= ''
Local _cCodAle	:= Iif(ValType(Self:codAlergenico) <> 'U',Self:codAlergenico,'')
Local cJsonRet		:= ''

::SetContentType('application/xml')

_cQuery := " SELECT * " + CRLF
_cQuery += " FROM " + RetSqlName("ZZH") + " ZZH " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += " ZZH.ZZH_FILIAL = '" + FWxFilial('ZZH','0103') + "' " + CRLF
If !Empty(_cCodAle)
	_cQuery += " AND ZZH.ZZH_COD = '" + AllTrim(_cCodAle) + "' " + CRLF
EndIf

_cQuery += " AND ZZH.D_E_L_E_T_ = ' ' " + CRLF
_cQuery += " ORDER BY ZZH.ZZH_COD " 
_cQuery := ChangeQuery(_cQuery)

Conout('QUERY - ' + _cQuery)
If Select(cNextAlias) > 0
	dbSelectArea(cNextAlias)
	dbCloseArea()
	cNextAlias 	:= GetNextAlias()
EndIf

dbUseArea(.T.,'TOPCONN',TCGENQRY(,,_cQuery),cNextAlias,.T.,.T.)
dbSelectArea(cNextAlias)
If !(cNextAlias)->(Eof()) .And. !(cNextAlias)->(Bof())

	cJsonRet := '{'
	cJsonRet += '	"Alergenicos" : [ '

	While !(cNextAlias)->(Eof())
		cJsonRet +=	'{'
		cJsonRet += '"codigo": "'      +  AllTrim((cNextAlias)->ZZH_COD)   + '" ,'
		cJsonRet += '"sens01": "'      +  RetSens(AllTrim((cNextAlias)->ZZH_SENS01))   + '" ,'
		cJsonRet += '"sens02": "'      +  RetSens(AllTrim((cNextAlias)->ZZH_SENS02))   + '" ,'
		cJsonRet += '"sens03": "'      +  RetSens(AllTrim((cNextAlias)->ZZH_SENS03))   + '" ,'
		cJsonRet += '"sens04": "'      +  RetSens(AllTrim((cNextAlias)->ZZH_SENS04))   + '" ,'
		cJsonRet += '"sens05": "'      +  RetSens(AllTrim((cNextAlias)->ZZH_SENS05))   + '" ,'
		cJsonRet += '"sens06": "'      +  RetSens(AllTrim((cNextAlias)->ZZH_SENS06))   + '" ,'
		cJsonRet += '"sens07": "'      +  RetSens(AllTrim((cNextAlias)->ZZH_SENS07))   + '" ,'
		cJsonRet += '"sens08": "'      +  RetSens(AllTrim((cNextAlias)->ZZH_SENS08))   + '" ,'
		cJsonRet += '"sens09": "'      +  RetSens(AllTrim((cNextAlias)->ZZH_SENS09))   + '" ,'
		cJsonRet += '"sens10": "'      +  RetSens(AllTrim((cNextAlias)->ZZH_SENS10))   + '" ,'
		cJsonRet += '"sens11": "'      +  RetSens(AllTrim((cNextAlias)->ZZH_SENS11))   + '" ,'
		cJsonRet += '"sens12": "'      +  RetSens(AllTrim((cNextAlias)->ZZH_SENS12))   + '" ,'
		cJsonRet += '"sens13": "'      +  RetSens(AllTrim((cNextAlias)->ZZH_SENS13))   + '" ,'
		cJsonRet += '"sens14": "'      +  RetSens(AllTrim((cNextAlias)->ZZH_SENS14))   + '" ,'
		cJsonRet += '"sens15": "'      +  RetSens(AllTrim((cNextAlias)->ZZH_SENS15))   + '" ,'
		cJsonRet += '"sens16": "'      +  RetSens(AllTrim((cNextAlias)->ZZH_SENS16))   + '" ,'
		cJsonRet += '"sens17": "'      +  RetSens(AllTrim((cNextAlias)->ZZH_SENS17))   + '" ,'
		cJsonRet += '"sens18": "'      +  RetSens(AllTrim((cNextAlias)->ZZH_SENS18))   + '" ,'
		cJsonRet += '"sens19": "'      +  RetSens(AllTrim((cNextAlias)->ZZH_SENS19))   + '" ,'
		cJsonRet += '"sens20": "'      +  RetSens(AllTrim((cNextAlias)->ZZH_SENS20))   + '" ,'
		cJsonRet += '"sens21": "'      +  RetSens(AllTrim((cNextAlias)->ZZH_SENS21))   + '" ,'
		cJsonRet += '"sens22": "'      +  RetSens(AllTrim((cNextAlias)->ZZH_SENS22))   + '" ,'
		cJsonRet += '"sens23": "'      +  RetSens(AllTrim((cNextAlias)->ZZH_SENS23))   + '" ,'
		cJsonRet += '"sens24": "'      +  RetSens(AllTrim((cNextAlias)->ZZH_SENS24))   + '" ,'
		cJsonRet += '"sens25": "'      +  RetSens(AllTrim((cNextAlias)->ZZH_SENS25))   + '" ,'
		cJsonRet += ' },'
		(cNextAlias)->(dbSkip())
	EndDo

	cJsonRet := substr( Alltrim(cJsonRet) , 1 , len(Alltrim(cJsonRet)) -1 )
	cJsonRet += '	]'
	cJsonRet += '}'
	cJsonRet := StrTran(cJsonRet,Chr(129),"")
	cJsonRet := StrTran(cJsonRet,Chr(141),"")
	cJsonRet := StrTran(cJsonRet,Chr(143),"")
	cJsonRet := StrTran(cJsonRet,Chr(144),"")
	cJsonRet := StrTran(cJsonRet,Chr(157),"")
	cJsonRet := StrTran(cJsonRet,Chr(9),"")
	cJsonRet := StrTran(cJsonRet,Chr(10),"")
	cJsonRet := StrTran(cJsonRet,Chr(13),"")
	conout("WSREST - " + cJsonRet)
	cJsonRet := FwCutOff(cJsonRet,.F.)		
	::SetResponse(FwNoAccent(cJsonRet))			
Else
	cJsonRet := '{'
	cJsonRet += '	"Origem" : [ '
	cJsonRet += '	"VAZIO" '
	cJsonRet += '	]'
	cJsonRet += '}'	
	::SetResponse(FwNoAccent(cJsonRet))	
EndIf

RestArea(_aArea)

Return(.T.)

/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author user
	@since date
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function RetSens(cSens)
Local cRet := ''
//C=Contem;N=Nao Contem;P=Pode Conter;D=Contem Derivados                                                                          
Do Case
	Case cSens == 'C'
		cRet := 'Contem'
	Case cSens == 'N'
		cRet := 'Nao Contem'
	Case cSens == 'P'
		cRet := 'Pode Conter'
	Case cSens == 'D'
		cRet := 'Contem Derivados '								
EndCase

Return cRet


WsMethod POST  WSSERVICE Alergenicos

	Local oJSON := JsonObject():new()
	Local cRet
	Local cJson := ::GetContent()
	Local nX
	Local aProd := {}
	Local oModel := FWLoadModel("MATA010")
	Local oModelSB1  := oModel:GetModel("SB1MASTER")
	Local cJSONRet := ""
	Local xValor := ""
	Local lRet := .T.
	Local lOperacao
	Local cCod	:= ''
	Local cFornece	:= ''
	Local cLoja	:= ''
	Private INCLUI := .F.
	Private ALTERA := .F.

	::SetContentType("application/json")

	cRet := oJson:fromJson(FwNoAccent(cJson))

	Begin Transaction

	// GERANDO PRODUTO
	If ValType(oJson['alergenico']) != "U"

		For nX := 1 To Len(oJson['alergenico'])
			//VERIFICANDO SE O MESMO JA EXISTE
			If oJson['alergenico'][nX]['field'] == "ZZH_COD"
				ZZH->(dbSetOrder(1))
				If ZZH->( dbSeek( FWxFilial("ZZH",'0103') + Alltrim(oJson['alergenico'][nX]['value']) ))
					nOpc := 4
					ALTERA := .T.
				Else
					nOpc := 3
					INCLUI := .T.
				Endif

				Exit

			Endif

		Next

		lOperacao := IIf ( nOpc == 3 , .T. , .F. )

		Reclock("ZZH",lOperacao)

		ZZH_FILIAL := FWxFilial("ZZH",'0103')
		For nX := 1 To Len(oJson['alergenico'])

			&(oJson['alergenico'][nX]['field']) := u_DXCONVDT( oJson['alergenico'][nX]['value']  , oJson['alergenico'][nX]['field'])

		Next

		ZZH->(MsUnLock())

		cJSONRet += '{'
		cJSONRet += '"status":"ok",'
		cJSONRet += '"mensagem":"registro gravado com sucesso!"'
		cJSONRet += '}'
	Else
		cJSONRet += '{'
		cJSONRet += '"status":"Erro",'
		cJSONRet += '"mensagem":"JSON invalido!"'
		cJSONRet += '}'			
	EndIf

	End Transaction

	::SetResponse( FwNoAccent(cJSONRet) )

Return lRet

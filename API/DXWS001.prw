#include "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE  'totvs.ch' 
#DEFINE OPC 5

User Function DXWS001()
Return

WsRestful Produtos Description "Importacao de Produtos" Format APPLICATION_JSON
	WSDATA CodProduto As String
	WsMethod GET Description "Retorna lista dos produtos" WsSyntax "/GET/{method}"
	WsMethod POST Description "Inclui um produto no Sistema" WsSyntax "/POST/{method}"
	WsMethod DELETE Description "Exclui um produto no Sistema" WsSyntax "/DELETE/{method}"
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
	WSDATA codArmazem As String
	WsMethod GET Description "Retorna lista de Armazens do produto" WsSyntax "/GET/{method}"
End WsRestful

WsRestful CentroCusto Description "Importacao de Centros de custo" Format APPLICATION_JSON
	WSDATA codCC As String
	WsMethod GET Description "Retorna lista de Centros de custo" WsSyntax "/GET/{method}"
End WsRestful


WsMethod POST  WSSERVICE Produtos

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

	::SetContentType("application/json")

	cRet := oJson:fromJson(FwNoAccent(cJson))

	Begin Transaction

	// GERANDO PRODUTO
	If ValType(oJson['produto']) != "U"

		For nX := 1 To Len(oJson['produto'])
			//VERIFICANDO SE O MESMO JA EXISTE
			If oJson['produto'][nX]['field'] == "B1_COD"
				SB1->(dbSetOrder(1))
				If SB1->( dbSeek( FWxFilial("SB1") + Alltrim(oJson['produto'][nX]['value']) ))
					nOpc := 4
				Else
					nOpc := 3
				Endif

				Exit

			Endif

		Next

		//INICIANDO MODELO E OPERACAO
		oModel:SetOperation(nOpc)
		oModel:Activate()

		For nX := 1 To Len(oJson['produto'])

			If oModelSB1:CanSetValue( oJson['produto'][nX]['field']  )
				oModelSB1:SetValue( oJson['produto'][nX]['field'] ,  u_MUNATU01( oJson['produto'][nX]['value']  , oJson['produto'][nX]['field']) )
			Endif
		Next

		If Len(oJson['produto']) > 0 .And. oModel:VldData()

			FwFormCommit(oModel)

			//Verifica se nao tem complemento para gerar o registro
			If ValType(oJson['complemento']) == "U" .OR. Len(oJson['complemento']) == 0

				cJSONRet += '{'
				cJSONRet += '"status":"ok",'
				cJSONRet += '"mensagem":"registro gravado com sucesso!"'
				cJSONRet += '}'

			Endif

		Else

			aErro := oModel:GetErrorMessage()

			// A estrutura do vetor com erro é:
			// [1] identificador (ID) do formulário de origem
			// [2] identificador (ID) do campo de origem
			// [3] identificador (ID) do formulário de erro
			// [4] identificador (ID) do campo de erro
			// [5] identificador (ID) do erro
			// [6] mensagem do erro
			// [7] mensagem da solução
			// [8] Valor atribuído
			// [9] Valor anterior

			cArqErrAuto := "Id do formulário de origem:"+ ' [' + AllToChar( aErro[1] ) + '] '
			cArqErrAuto += "Id do campo de origem: " 	+ ' [' + AllToChar( aErro[2] ) + '] '
			cArqErrAuto += "Id do formulário de erro: " + ' [' + AllToChar( aErro[3] ) + '] '
			cArqErrAuto += "Id do campo de erro: " 		+ ' [' + AllToChar( aErro[4] ) + '] '
			cArqErrAuto += "Id do erro: " 				+ ' [' + AllToChar( aErro[5] ) + '] '
			cArqErrAuto += "Mensagem do erro: " 		+ ' [' + AllToChar( aErro[6] ) + '] '
			cArqErrAuto += "Mensagem da solução: " 		+ ' [' + AllToChar( aErro[7] ) + '] '
			cArqErrAuto += "Valor atribuído: " 			+ ' [' + AllToChar( aErro[8] ) + '] '
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
						If SB5->( dbSeek( FWxFilial("SB5") + Alltrim(oJson['complemento'][nX]['value']) ))
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

				B5_FILIAL := FWxFilial("SB5")
				For nX := 1 To Len(oJson['complemento'])
					/*If oModelSB5:CanSetValue( oJson['complemento'][nX]['field']  )
						oModelSB5:SetValue( oJson['complemento'][nX]['field'] ,  u_MUNATU01( oJson['complemento'][nX]['value']  , oJson['complemento'][nX]['field']) )
					Endif*/

					//&("oJson['complemento'][nX]['field']") := u_MUNATU01( oJson['complemento'][nX]['value']  , oJson['complemento'][nX]['field'])
					&(oJson['complemento'][nX]['field']) := u_MUNATU01( oJson['complemento'][nX]['value']  , oJson['complemento'][nX]['field'])

				Next

				SB5->(MsUnLock())

				If  Len(oJson['complemento'])  > 0 //.And. oModel2:VldData()

				//	/FwFormCommit(oModel2)

					cJSONRet += '{'
					cJSONRet += '"status":"ok",'
					cJSONRet += '"mensagem":"registro gravado com sucesso!"'
					cJSONRet += '}'

				Else

					aErro := oModel:GetErrorMessage()

					// A estrutura do vetor com erro é:
					// [1] identificador (ID) do formulário de origem
					// [2] identificador (ID) do campo de origem
					// [3] identificador (ID) do formulário de erro
					// [4] identificador (ID) do campo de erro
					// [5] identificador (ID) do erro
					// [6] mensagem do erro
					// [7] mensagem da solução
					// [8] Valor atribuído
					// [9] Valor anterior

					/*cArqErrAuto := "Id do formulário de origem:"+ ' [' + AllToChar( aErro[1] ) + '] '
					cArqErrAuto += "Id do campo de origem: " 	+ ' [' + AllToChar( aErro[2] ) + '] '
					cArqErrAuto += "Id do formulário de erro: " + ' [' + AllToChar( aErro[3] ) + '] '
					cArqErrAuto += "Id do campo de erro: " 		+ ' [' + AllToChar( aErro[4] ) + '] '
					cArqErrAuto += "Id do erro: " 				+ ' [' + AllToChar( aErro[5] ) + '] '
					cArqErrAuto += "Mensagem do erro: " 		+ ' [' + AllToChar( aErro[6] ) + '] '
					cArqErrAuto += "Mensagem da solução: " 		+ ' [' + AllToChar( aErro[7] ) + '] '
					cArqErrAuto += "Valor atribuído: " 			+ ' [' + AllToChar( aErro[8] ) + '] '
					cArqErrAuto += "Valor anterior: " 			+ ' [' + AllToChar( aErro[9] ) + '] '
					*/

					cJSONRet += '{'
					cJSONRet += '"status":"error no complemento", ' + CRLF
					cJSONRet += '"mensagem":"' + cArqErrAuto + '"' + CRLF
					cJSONRet += '} ' + CRLF

					lRet := .F.

					SetRestFault(400, FwNoAccent(cJSONRet))

				Endif
			Endif
	Endif

	End Transaction

	::SetResponse( FwNoAccent(cJSONRet) )

Return lRet

//Exclui um produto

WsMethod DELETE  WSRECEIVE CODPRODUTO WSSERVICE  Produtos

	Local lRet := .T.
	Local cCodProd := Self:CODPRODUTO
	Local oModel := FWLoadModel("MATA010")
	Local oModelSB1  := oModel:GetModel("SB1MASTER")
	Local cJsonRet := ""
	Local cArqErrAuto := ""
	Local aErro := {}

	::SetContentType("application/json")

	SB1->(dbSetOrder(1))
	If SB1->( dbSeek( FWxFilial("SB1") + cCodProd ))

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

			// A estrutura do vetor com erro é:
			// [1] identificador (ID) do formulário de origem
			// [2] identificador (ID) do campo de origem
			// [3] identificador (ID) do formulário de erro
			// [4] identificador (ID) do campo de erro
			// [5] identificador (ID) do erro
			// [6] mensagem do erro
			// [7] mensagem da solução
			// [8] Valor atribuído
			// [9] Valor anterior

			cArqErrAuto := "Id do formulário de origem:"+ ' [' + AllToChar( aErro[1] ) + '] '
			cArqErrAuto += "Id do campo de origem: " 	+ ' [' + AllToChar( aErro[2] ) + '] '
			cArqErrAuto += "Id do formulário de erro: " + ' [' + AllToChar( aErro[3] ) + '] '
			cArqErrAuto += "Id do campo de erro: " 		+ ' [' + AllToChar( aErro[4] ) + '] '
			cArqErrAuto += "Id do erro: " 				+ ' [' + AllToChar( aErro[5] ) + '] '
			cArqErrAuto += "Mensagem do erro: " 		+ ' [' + AllToChar( aErro[6] ) + '] '
			cArqErrAuto += "Mensagem da solução: " 		+ ' [' + AllToChar( aErro[7] ) + '] '
			cArqErrAuto += "Valor atribuído: " 			+ ' [' + AllToChar( aErro[8] ) + '] '
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


Return lRet



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo    ³ GET        ³ Autor ³ Flavio Valentin     ³ Data ³ 14/01/20 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna a lista de kdbrprodutos - KDBR.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Manutencao Efetuada                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WsMethod GET WSRECEIVE CodProduto WSSERVICE Produtos

Local _aArea 	 	:= GetArea()
Local _cQuery 		:= ""
Local _cNextAlias 	:= GetNextAlias()
Local _cXml 		:= ''
Local _cCodProd		:= Iif(ValType(Self:CodProduto) <> 'U',Self:CodProduto,'')

::SetContentType('application/xml')

_cQuery := " SELECT * " + CRLF
_cQuery += " FROM " + RetSqlName("SB1") + " SB1 " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += " SB1.B1_FILIAL = '" + FWxFilial('SB1') + "' " + CRLF
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
	_cXml := '<?xml version="1.0" encoding="UTF-8"?> ' + CRLF
	_cXml += '<Items>' + CRLF
	(_cNextAlias)->(dbGoTop())
		While !(_cNextAlias)->(Eof())
		_cXml += '<Item>' + CRLF
		_cXml += '<ItemNumber>' + AllTrim((_cNextAlias)->B1_COD) + '</ItemNumber>' + CRLF
		_cXml += '<ItemDescription>' + AllTrim((_cNextAlias)->B1_DESC) + '</ItemDescription>' + CRLF
			If AllTrim((_cNextAlias)->B1_GRUPO) == '0001'
			_cXml += '<ItemType>MACHINE</ItemType>' + CRLF
			ElseIf AllTrim((_cNextAlias)->B1_GRUPO) == '0002'
			_cXml += '<ItemType>ACESSORIES</ItemType>' + CRLF
			ElseIf AllTrim((_cNextAlias)->B1_GRUPO) == '0003'
			_cXml += '<ItemType>PARTS</ItemType>' + CRLF
			ElseIf AllTrim((_cNextAlias)->B1_GRUPO) == '0004'
			_cXml += '<ItemType>SUPPLY</ItemType>' + CRLF
			EndIf
		_cXml += '<Serialized>' + Space(2) + '<Serialized/>' + CRLF
		_cXml += '<KDAItemCategorySegment1>' + Space(2) + '<KDAItemCategorySegment1/>' + CRLF
		_cXml += '<KDAItemCategorySegment2>' + Space(2) + '<KDAItemCategorySegment2/>' + CRLF
		_cXml += '<KDAItemCategorySegment3>' + Space(2) + '<KDAItemCategorySegment3/>' + CRLF
		_cXml += '<KDAItemCategorySegment4>' + Space(2) + '<KDAItemCategorySegment4/>' + CRLF
		_cXml += '<KDAItemCategorySegment5>' + Space(2) + '<KDAItemCategorySegment5/>' + CRLF
		_cXml += '<KDAItemCategorySegment6>' + Space(2) + '<KDAItemCategorySegment6/>' + CRLF
		_cXml += '<KDAItemCategorySegment7>' + Space(2) + '<KDAItemCategorySegment7/>' + CRLF
		_cXml += '<KDAItemCategorySegment8>' + Space(2) + '<KDAItemCategorySegment8/>' + CRLF
		_cXml += '<KDAItemCategorySegment9>' + Space(2) + '<KDAItemCategorySegment9/>' + CRLF
		_cXml += '<KDAItemCategorySegment10>' + Space(2) + '<KDAItemCategorySegment10/>' + CRLF
		_cXml += '<KDCItemCategorySegment1>' + Space(2) + '<KDCItemCategorySegment1/>' + CRLF
		_cXml += '<KDCItemCategorySegment2>' + Space(2) + '<KDCItemCategorySegment2/>' + CRLF
		_cXml += '<KDCItemCategorySegment3>' + Space(2) + '<KDCItemCategorySegment3/>' + CRLF
		_cXml += '<KDCItemCategorySegment4>' + Space(2) + '<KDCItemCategorySegment4/>' + CRLF
		_cXml += '<KDCItemCategorySegment5>' + Space(2) + '<KDCItemCategorySegment5/>' + CRLF
		_cXml += '<KDCItemCategorySegment6>' + Space(2) + '<KDCItemCategorySegment6/>' + CRLF
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
	_cXml := EncodeUTF8(_cXml)
	::SetResponse(FwNoAccent(_cXml))
	EndIf

RestArea(_aArea)

Return(.T.)



WsMethod GET WSRECEIVE CodFamilia WSSERVICE FamiliaItens

Local _aArea 	 	:= GetArea()
Local _cQuery 		:= ""
Local _cNextAlias 	:= GetNextAlias()
Local _cXml 		:= ''
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
	_cXml := '<?xml version="1.0" encoding="UTF-8"?> ' + CRLF
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
	_cXml := EncodeUTF8(_cXml)
	::SetResponse(FwNoAccent(_cXml))
	EndIf

RestArea(_aArea)

Return(.T.)




WsMethod GET WSRECEIVE CodLinha WSSERVICE LinhaItens

Local _aArea 	 	:= GetArea()
Local _cQuery 		:= ""
Local _cNextAlias 	:= GetNextAlias()
Local _cXml 		:= ''
Local _cCodLin		:= Iif(ValType(Self:CodLinha) <> 'U',Self:CodLinha,'')

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
	_cXml := '<?xml version="1.0" encoding="UTF-8"?> ' + CRLF
	_cXml += '<Items>' + CRLF
	(_cNextAlias)->(dbGoTop())
		While !(_cNextAlias)->(Eof())
			_cXml += '<Item>' + CRLF
			_cXml += '<LinNumber>' + AllTrim((_cNextAlias)->Z2_COD) + '</LinNumber>' + CRLF
			_cXml += '<LinDescription>' + AllTrim((_cNextAlias)->Z2_DESCR) + '</LinDescription>' + CRLF
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
	_cXml := EncodeUTF8(_cXml)
	::SetResponse(FwNoAccent(_cXml))
	EndIf

RestArea(_aArea)

Return(.T.)




WsMethod GET WSRECEIVE CodGrupo WSSERVICE GrupoItens

Local _aArea 	 	:= GetArea()
Local _cQuery 		:= ""
Local _cNextAlias 	:= GetNextAlias()
Local _cXml 		:= ''
Local _cCodGru		:= Iif(ValType(Self:CodGrupo) <> 'U',Self:CodGrupo,'')

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
	_cXml := '<?xml version="1.0" encoding="UTF-8"?> ' + CRLF
	_cXml += '<Items>' + CRLF
	(_cNextAlias)->(dbGoTop())
		While !(_cNextAlias)->(Eof())
			_cXml += '<Item>' + CRLF
			_cXml += '<GruNumber>' + AllTrim((_cNextAlias)->Z3_COD) + '</GruNumber>' + CRLF
			_cXml += '<GruDescription>' + AllTrim((_cNextAlias)->Z3_DESCR) + '</GruDescription>' + CRLF
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
	_cXml := EncodeUTF8(_cXml)
	::SetResponse(FwNoAccent(_cXml))
	EndIf

RestArea(_aArea)

Return(.T.)


WsMethod GET WSRECEIVE CodTipo WSSERVICE TipoItens

Local _aArea 	 	:= GetArea()
Local _cQuery 		:= ""
Local _cNextAlias 	:= GetNextAlias()
Local _cXml 		:= ''
Local _cCodType		:= Iif(ValType(Self:CodTipo) <> 'U',Self:CodTipo,'')

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
		_cXml := '<?xml version="1.0" encoding="UTF-8"?> ' + CRLF
		_cXml += '<Items>' + CRLF
		(_cNextAlias)->(dbGoTop())
		While !(_cNextAlias)->(Eof())
			_cXml += '<Item>' + CRLF
			_cXml += '<TypeNumber>' + AllTrim((_cNextAlias)->X5_CHAVE) + '</TypeNumber>' + CRLF
			_cXml += '<TypeDescription>' + AllTrim((_cNextAlias)->X5_DESCRI) + '</TypeDescription>' + CRLF
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
		_cXml := EncodeUTF8(_cXml)
		::SetResponse(FwNoAccent(_cXml))		
	EndIf

RestArea(_aArea)

Return(.T.)


WsMethod GET WSRECEIVE CodNcm WSSERVICE NcmItens

Local _aArea 	 	:= GetArea()
Local _cQuery 		:= ""
Local _cNextAlias 	:= GetNextAlias()
Local _cXml 		:= ''
Local _cCodNcm		:= Iif(ValType(Self:CodNcm) <> 'U',Self:CodNcm,'')

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
	_cXml := '<?xml version="1.0" encoding="UTF-8"?> ' + CRLF
	_cXml += '<Items>' + CRLF
	(_cNextAlias)->(dbGoTop())
		While !(_cNextAlias)->(Eof())
			_cXml += '<Item>' + CRLF
			_cXml += '<NcmNumber>' + AllTrim((_cNextAlias)->YD_TEC) + '</NcmNumber>' + CRLF
			_cXml += '<NcmDescription>' + AllTrim((_cNextAlias)->YD_DESC_P) + '</NcmDescription>' + CRLF
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
	_cXml := EncodeUTF8(_cXml)
	::SetResponse(FwNoAccent(_cXml))
	EndIf

RestArea(_aArea)

Return(.T.)



WsMethod GET WSRECEIVE CodUm WSSERVICE UmItens

Local _aArea 	 	:= GetArea()
Local _cQuery 		:= ""
Local _cNextAlias 	:= GetNextAlias()
Local _cXml 		:= ''
Local _cCodUm		:= Iif(ValType(Self:CodUm) <> 'U',Self:CodUm,'')

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
	_cXml := '<?xml version="1.0" encoding="UTF-8"?> ' + CRLF
	_cXml += '<Items>' + CRLF
	(_cNextAlias)->(dbGoTop())
		While !(_cNextAlias)->(Eof())
			_cXml += '<Item>' + CRLF
			_cXml += '<UmCode>' + AllTrim((_cNextAlias)->AH_UNIMED) + '</UmCode>' + CRLF
			_cXml += '<UmDescription>' + AllTrim((_cNextAlias)->AH_DESCPO) + '</UmDescription>' + CRLF
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
	_cXml := EncodeUTF8(_cXml)
	::SetResponse(FwNoAccent(_cXml))
	EndIf

RestArea(_aArea)

Return(.T.)



WsMethod GET WSRECEIVE CodCoord WSSERVICE CoordProduto

Local _aArea 	 	:= GetArea()
Local _cQuery 		:= ""
Local cNextAlias 	:= GetNextAlias()
Local _cXml 		:= ''
Local _cCodCoord		:= Iif(ValType(Self:CodCoord) <> 'U',Self:CodCoord,'')

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
		_cXml := '<?xml version="1.0" encoding="UTF-8"?> ' + CRLF
		_cXml += '<Items>' + CRLF
		(cNextAlias)->(dbGoTop())
			While !(cNextAlias)->(Eof())
				_cXml += '<Item>' + CRLF
				_cXml += '<vendedorNumber>' + AllTrim((cNextAlias)->A3_COD) + '</vendedorNumber>' + CRLF
				_cXml += '<vendedorDescription>' + AllTrim((cNextAlias)->A3_NOME) + '</vendedorDescription>' + CRLF
				_cXml += '<CreateUpdate>Create</CreateUpdate>' + CRLF
				_cXml += '</Item>' + CRLF
				(cNextAlias)->(dbSkip())
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
		_cXml := EncodeUTF8(_cXml)
		::SetResponse(FwNoAccent(_cXml))
	EndIf

RestArea(_aArea)

Return(.T.)



WsMethod GET WSRECEIVE CodCateg WSSERVICE categProduto

Local _aArea 	 	:= GetArea()
Local _cQuery 		:= ""
Local cNextAlias 	:= GetNextAlias()
Local _cXml 		:= ''
Local _cCodCateg		:= Iif(ValType(Self:CodCateg) <> 'U',Self:CodCateg,'')

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
	_cXml := '<?xml version="1.0" encoding="UTF-8"?> ' + CRLF
	_cXml += '<Items>' + CRLF
	(cNextAlias)->(dbGoTop())
		While !(cNextAlias)->(Eof())
			_cXml += '<Item>' + CRLF
			_cXml += '<codCateg>' + AllTrim((cNextAlias)->ZZD_COD) + '</codCateg>' + CRLF
			_cXml += '<categDescription>' + AllTrim((cNextAlias)->ZZD_CATEG) + '</categDescription>' + CRLF
			_cXml += '<CreateUpdate>Create</CreateUpdate>' + CRLF
			_cXml += '</Item>' + CRLF
			(cNextAlias)->(dbSkip())
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
	_cXml := EncodeUTF8(_cXml)
	::SetResponse(FwNoAccent(_cXml))
	EndIf

RestArea(_aArea)

Return(.T.)



WsMethod GET WSRECEIVE CodCarga WSSERVICE cargaProduto

Local _aArea 	 	:= GetArea()
Local _cQuery 		:= ""
Local cNextAlias 	:= GetNextAlias()
Local _cXml 		:= ''
Local _cCodCarga		:= Iif(ValType(Self:CodCarga) <> 'U',Self:CodCarga,'')

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
	_cXml := '<?xml version="1.0" encoding="UTF-8"?> ' + CRLF
	_cXml += '<Items>' + CRLF
	(cNextAlias)->(dbGoTop())
		While !(cNextAlias)->(Eof())
			_cXml += '<Item>' + CRLF
			_cXml += '<codCarga>' + AllTrim((cNextAlias)->DB0_CODMOD) + '</codCarga>' + CRLF
			_cXml += '<cargaDescription>' + AllTrim((cNextAlias)->DB0_DESMOD) + '</cargaDescription>' + CRLF
			_cXml += '<CreateUpdate>Create</CreateUpdate>' + CRLF
			_cXml += '</Item>' + CRLF
			(cNextAlias)->(dbSkip())
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
	_cXml := EncodeUTF8(_cXml)
	::SetResponse(FwNoAccent(_cXml))
	EndIf

RestArea(_aArea)

Return(.T.)





WsMethod GET WSRECEIVE CodGrpTribut WSSERVICE grpTributarioProduto

Local _aArea 	 	:= GetArea()
Local _cQuery 		:= ""
Local cNextAlias 	:= GetNextAlias()
Local _cXml 		:= ''
Local _cCodGrpTribut		:= Iif(ValType(Self:CodGrpTribut) <> 'U',Self:CodGrpTribut,'')

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
	_cXml := '<?xml version="1.0" encoding="UTF-8"?> ' + CRLF
	_cXml += '<Items>' + CRLF
	(cNextAlias)->(dbGoTop())
		While !(cNextAlias)->(Eof())
			_cXml += '<Item>' + CRLF
			_cXml += '<chave>' + AllTrim((cNextAlias)->X5_CHAVE) + '</chave>' + CRLF
			_cXml += '<grpTribDescription>' + AllTrim((cNextAlias)->X5_DESCRI) + '</grpTribDescription>' + CRLF
			_cXml += '<CreateUpdate>Create</CreateUpdate>' + CRLF
			_cXml += '</Item>' + CRLF
			(cNextAlias)->(dbSkip())
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
	_cXml := EncodeUTF8(_cXml)
	::SetResponse(FwNoAccent(_cXml))
	EndIf

RestArea(_aArea)

Return(.T.)




WsMethod GET WSRECEIVE CodOrigem WSSERVICE origemProduto

Local _aArea 	 	:= GetArea()
Local _cQuery 		:= ""
Local cNextAlias 	:= GetNextAlias()
Local _cXml 		:= ''
Local _cCodOrigem		:= Iif(ValType(Self:CodOrigem) <> 'U',Self:CodOrigem,'')

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
	_cXml := '<?xml version="1.0" encoding="UTF-8"?> ' + CRLF
	_cXml += '<Items>' + CRLF
	(cNextAlias)->(dbGoTop())
		While !(cNextAlias)->(Eof())
			_cXml += '<Item>' + CRLF
			_cXml += '<origem>' + AllTrim((cNextAlias)->X5_CHAVE) + '</origem>' + CRLF
			_cXml += '<origemDescription>' + AllTrim((cNextAlias)->X5_DESCRI) + '</origemDescription>' + CRLF
			_cXml += '<CreateUpdate>Create</CreateUpdate>' + CRLF
			_cXml += '</Item>' + CRLF
			(cNextAlias)->(dbSkip())
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
	_cXml := EncodeUTF8(_cXml)
	::SetResponse(FwNoAccent(_cXml))
	EndIf

RestArea(_aArea)

Return(.T.)



WsMethod GET WSRECEIVE CodCtCont WSSERVICE ctContProduto

Local _aArea 	 	:= GetArea()
Local _cQuery 		:= ""
Local cNextAlias 	:= GetNextAlias()
Local _cXml 		:= ''
Local _cCodCtCont		:= Iif(ValType(Self:CodCtCont) <> 'U',Self:CodCtCont,'')

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
	_cXml := '<?xml version="1.0" encoding="UTF-8"?> ' + CRLF
	_cXml += '<Items>' + CRLF
	(cNextAlias)->(dbGoTop())
		While !(cNextAlias)->(Eof())
			_cXml += '<Item>' + CRLF
			_cXml += '<codConta>' + AllTrim((cNextAlias)->CT1_CONTA) + '</codConta>' + CRLF
			_cXml += '<contaDescription>' + AllTrim((cNextAlias)->CT1_DESC01) + '</contaDescription>' + CRLF
			_cXml += '<CreateUpdate>Create</CreateUpdate>' + CRLF
			_cXml += '</Item>' + CRLF
			(cNextAlias)->(dbSkip())
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
	_cXml := EncodeUTF8(_cXml)
	::SetResponse(FwNoAccent(_cXml))
	EndIf

RestArea(_aArea)

Return(.T.)






WsMethod GET WSRECEIVE codEmbala WSSERVICE embalagemProduto

Local _aArea 	 	:= GetArea()
Local _cQuery 		:= ""
Local cNextAlias 	:= GetNextAlias()
Local _cXml 		:= ''
Local _cCodEmb		:= Iif(ValType(Self:codEmbala) <> 'U',Self:codEmbala,'')

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
	_cXml := '<?xml version="1.0" encoding="UTF-8"?> ' + CRLF
	_cXml += '<Items>' + CRLF
	(cNextAlias)->(dbGoTop())
		While !(cNextAlias)->(Eof())
			_cXml += '<Item>' + CRLF
			_cXml += '<codEmbalagem>' + AllTrim((cNextAlias)->ZZ1_COD) + '</codEmbalagem>' + CRLF
			_cXml += '<embDescription>' + AllTrim((cNextAlias)->ZZ1_DESC) + '</embDescription>' + CRLF
			_cXml += '<CreateUpdate>Create</CreateUpdate>' + CRLF
			_cXml += '</Item>' + CRLF
			(cNextAlias)->(dbSkip())
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
	_cXml := EncodeUTF8(_cXml)
	::SetResponse(FwNoAccent(_cXml))
	EndIf

RestArea(_aArea)

Return(.T.)



WsMethod GET WSRECEIVE codArmazem WSSERVICE armazemProduto

Local _aArea 	 	:= GetArea()
Local _cQuery 		:= ""
Local cNextAlias 	:= GetNextAlias()
Local _cXml 		:= ''
Local _cCodArmazem		:= Iif(ValType(Self:codArmazem) <> 'U',Self:codArmazem,'')

::SetContentType('application/xml')

_cQuery := " SELECT * " + CRLF
_cQuery += " FROM " + RetSqlName("NNR") + " NNR " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += " NNR.NNR_FILIAL = '" + FWxFilial('NNR') + "' " + CRLF
	If !Empty(_cCodArmazem)
		_cQuery += " AND NNR.NNR_CODIGO = '" + AllTrim(_cCodArmazem) + "' " + CRLF
	EndIf
_cQuery += " AND NNR.D_E_L_E_T_ = ' ' " + CRLF
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
	_cXml := '<?xml version="1.0" encoding="UTF-8"?> ' + CRLF
	_cXml += '<Items>' + CRLF
	(cNextAlias)->(dbGoTop())
		While !(cNextAlias)->(Eof())
			_cXml += '<Item>' + CRLF
			_cXml += '<codArmazem>' + AllTrim((cNextAlias)->NNR_CODIGO) + '</codArmazem>' + CRLF
			_cXml += '<ArmazemDescription>' + AllTrim((cNextAlias)->NNR_DESCRI) + '</ArmazemDescription>' + CRLF
			_cXml += '<CreateUpdate>Create</CreateUpdate>' + CRLF
			_cXml += '</Item>' + CRLF
			(cNextAlias)->(dbSkip())
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
	_cXml := EncodeUTF8(_cXml)
	::SetResponse(FwNoAccent(_cXml))
	EndIf

RestArea(_aArea)

Return(.T.)




WsMethod GET WSRECEIVE codCC WSSERVICE CentroCusto

Local _aArea 	 	:= GetArea()
Local _cQuery 		:= ""
Local cNextAlias 	:= GetNextAlias()
Local _cXml 		:= ''
Local _cCodCC		:= Iif(ValType(Self:codCC) <> 'U',Self:codCC,'')

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
	_cXml := '<?xml version="1.0" encoding="UTF-8"?> ' + CRLF
	_cXml += '<Items>' + CRLF
	(cNextAlias)->(dbGoTop())
		While !(cNextAlias)->(Eof())
			_cXml += '<Item>' + CRLF
			_cXml += '<CentroCusto>' + AllTrim((cNextAlias)->CTT_CUSTO) + '</CentroCusto>' + CRLF
			_cXml += '<CentroCustoDescription>' + AllTrim((cNextAlias)->CTT_DESC01) + '</CentroCustoDescription>' + CRLF
			_cXml += '<CreateUpdate>Create</CreateUpdate>' + CRLF
			_cXml += '</Item>' + CRLF
			(cNextAlias)->(dbSkip())
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
	_cXml := EncodeUTF8(_cXml)
	::SetResponse(FwNoAccent(_cXml))
	EndIf

RestArea(_aArea)

Return(.T.)

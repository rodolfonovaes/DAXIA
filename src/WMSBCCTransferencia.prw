#Include "Totvs.ch"
#Include "WMSBCCTransferencia.ch"
#Define CLRF  Chr(13)+Chr(10)
#Define RELDETEST 9
//---------------------------------------------
/*/{Protheus.doc} WMSCLS0008
Função para permitir que a classe seja visualizada
no inspetor de objetos
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0008()
Return Nil
//---------------------------------------------
/*/{Protheus.doc} WMSBCCTransferencia
Classe para analise e geração dos movimentos de transferência
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
CLASS WMSBCCTransferencia FROM WMSDTCMovimentosServicoArmazem
	DATA oTmpSldD14
	// Declaração dos Métodos da Classe
	METHOD New() CONSTRUCTOR
	METHOD SetOrdServ(oOrdServ)
	METHOD ExecFuncao()
	METHOD VldGeracao()
	METHOD ProcEstFis()
	METHOD ProcTrfUni()
	METHOD CanUnitPar(lExeMovto)
	METHOD DelSldD14()
	METHOD LoadSldD14(lExeMovto,lHasSldUni)
	METHOD CalcUniEnd()
	METHOD ValPrdLot(lLoteCtl)
	METHOD CalcOcupac()
	METHOD QtdPrdUni()
	METHOD Destroy()
ENDCLASS

METHOD New() CLASS WMSBCCTransferencia
	_Super:New()
	Self:oTmpSldD14 := Nil
Return

METHOD SetOrdServ(oOrdServ) CLASS WMSBCCTransferencia
	Self:oOrdServ := oOrdServ
	Self:oMovServic := Self:oOrdServ:oServico
	// Carrega dados endereço origem
	Self:oMovEndOri:SetArmazem(Self:oOrdServ:oOrdEndOri:GetArmazem())
	Self:oMovEndOri:SetEnder(Self:oOrdServ:oOrdEndOri:GetEnder())
	Self:oMovEndOri:LoadData()
	Self:oMovEndOri:ExceptEnd()
	// Carrega dados endereço destino
	Self:oMovEndDes:SetArmazem(Self:oOrdServ:oOrdEndDes:GetArmazem())
	Self:oMovEndDes:SetEnder(Self:oOrdServ:oOrdEndDes:GetEnder())
	Self:oMovEndDes:LoadData()
	Self:oMovEndDes:ExceptEnd()
Return

METHOD Destroy() CLASS WMSBCCTransferencia
	FreeObj(Self)
Return

//------------------------------------------------------------------------------
METHOD ExecFuncao() CLASS WMSBCCTransferencia
//------------------------------------------------------------------------------
Local lRet    := .T.
	If Self:VldGeracao()
		If Empty(Self:cIdUnitiz)
			lRet := Self:ProcEstFis()
		Else
			lRet := Self:ProcTrfUni()
		EndIf
	Else
		lRet := .F.
	EndIf
Return lRet

METHOD VldGeracao() CLASS WMSBCCTransferencia
Local aAreaAnt := GetArea()
Local lRet     := .T.

	If Empty(Self:oOrdServ:GetDocto())
		Self:cErro := STR0007 // Número do documento de transferência não informado!
		lRet := .F.
	EndIf

	If lRet .And. Empty(Self:oMovServic:GetServico())
		Self:cErro := STR0003 //Não foi informado um serviço de transferência
		lRet := .F.
	EndIf

	If lRet
		If Self:oMovServic:LoadData()
			If !Self:oMovServic:ChkTransf() .And. !((Self:oMovServic:ChkSepara() .And. !Empty(Self:oMovEndOri:GetEnder())) .Or. (Self:oMovServic:ChkRecebi() .And. !Empty(Self:oMovEndDes:GetEnder())))
				Self:cErro := STR0006 //Somente serviços WMS de transferência podem ser utilizados!
				lRet := .F.
			EndIf
		Else
			Self:cErro := STR0004 //Informe um serviço de transferência!
			lRet := .F.
		EndIf
	EndIf

	If lRet
		Self:oMovPrdLot:LoadData()
		lRet := Self:ChkEndOri(.T.)
		If lRet
			lRet := Self:ChkEndDes(.T.)
		EndIf
	EndIf
	RestArea(aAreaAnt)
Return lRet

//------------------------------------------------------------------------------
METHOD ProcEstFis() CLASS WMSBCCTransferencia
//------------------------------------------------------------------------------
Local aAreaAnt   := GetArea()
Local lRet       := .T.
Local nCapEnder  := 0
Local nQtdNorma  := 0
Local nQtdEnd    := 0
	// Se o destino for estrutura do tipo produção ou qualidade, considera a norma do endereço origem,
	// visto que não é obrigatório possuir estas estruturas na sequência de abastecimento do produto
	If Self:oMovEndDes:GetTipoEst() == 7 .Or. Self:oMovEndDes:GetTipoEst() == 8
		nCapEnder := DLQtdNorma(Self:oMovPrdLot:GetProduto(),Self:oMovEndOri:GetArmazem(),Self:oMovEndOri:GetEstFis(),/*cDesUni*/,.T.,Self:oMovEndOri:GetEnder()) //Considerar a qtd pelo nr de unitizadores
		// Se não utiliza percentual de ocupação utiliza a norma da estrutura, senão calcula a do endereço
		nQtdNorma := DLQtdNorma(Self:oMovPrdLot:GetProduto(), Self:oMovEndOri:GetArmazem(), Self:oMovEndOri:GetEstFis(), /*cDesUni*/, .F., Self:oMovEndOri:GetEnder()) //Considerar somente a norma
	Else
		nCapEnder := DLQtdNorma(Self:oMovPrdLot:GetProduto(),Self:oMovEndDes:GetArmazem(),Self:oMovEndDes:GetEstFis(),/*cDesUni*/,.T.,Self:oMovEndDes:GetEnder()) //Considerar a qtd pelo nr de unitizadores
		// Se não utiliza percentual de ocupação utiliza a norma da estrutura, senão calcula a do endereço
		nQtdNorma := DLQtdNorma(Self:oMovPrdLot:GetProduto(), Self:oMovEndDes:GetArmazem(), Self:oMovEndDes:GetEstFis(), /*cDesUni*/, .F., Self:oMovEndDes:GetEnder()) //Considerar somente a norma
	EndIf
	// Verifica se a Atividade utiliza Radio Frequencia
	// Carregas as exceções das atividades no destino
	Self:oMovEndDes:ExceptEnd()
	If QtdComp(nCapEnder) == QtdComp(0)
		lRet := .F.
		Self:cErro := STR0001 // Capacidade do endereço destino não cadastrada!
	EndIf
	If QtdComp(nQtdNorma) == QtdComp(0)
		lRet := .F.
		Self:cErro := STR0002 // Norma do endereço destino não cadastrada!
	EndIf
	// Atividades do pedido
	If Self:oOrdServ:GetOrigem() == 'SC9'
		//Liberação do pedido
		Self:SetLibPed(Self:oMovServic:GetLibPed())
		// Servico monta volume
		Self:cMntVol  := IIf(Empty(Self:oMovServic:GetMntVol()),"0",Self:oMovServic:GetMntVol())
		// Servico Distribui Separação
		Self:cDisSep  := IIf(Empty(Self:oMovServic:GetDisSep()),"2",Self:oMovServic:GetDisSep())
	EndIf
	// Atividades da requisição
	If Self:oOrdServ:GetOrigem() $ 'SD4|DH1'
		// Baixa estoque movimento interno de requisição
		Self:cBxEsto  := IIf(Empty(Self:oMovServic:GetBxEsto()),"2",Self:oMovServic:GetBxEsto())
	EndIf
	Do While lRet .And. Self:nQuant > 0
		nQtdEnd   := Min(Self:nQuant,nCapEnder)
		// Enquanto for maior que zero, vai endereçando a quantidade de uma norma ou o restante
		Do While lRet .And. QtdComp(nQtdEnd) > QtdComp(0)
			// Status Movimento
			Self:cStatus := IIf(Self:oMovServic:GetBlqSrv() == "1","2","4")
			Self:nQtdMovto := Min(nQtdEnd,nQtdNorma)
			nQtdEnd  -= Self:nQtdMovto
			Self:nQuant -= Self:nQtdMovto
			// Gera a movimentação de estoque por endereco
			If Self:oOrdServ:ChkDistr()
				If !Self:MakeInput()
					lRet := .F.
				EndIf
			EndIf
			// Gera a movimentação de estoque por endereco
			If !Self:AssignD12()
				lRet := .F.
			EndIf
		EndDo
	EndDo
	RestArea(aAreaAnt)
Return lRet

//------------------------------------------------------------------------------
METHOD ProcTrfUni() CLASS WMSBCCTransferencia
//------------------------------------------------------------------------------
Local lRet := .T.
	// Carregas as exceções das atividades no destino
	Self:oMovEndDes:ExceptEnd()
	// Atividades do pedido
	If Self:oOrdServ:GetOrigem() == 'SC9'
		//Liberação do pedido
		Self:SetLibPed(Self:oMovServic:GetLibPed())
		// Servico monta volume
		Self:cMntVol  := IIf(Empty(Self:oMovServic:GetMntVol()),"0",Self:oMovServic:GetMntVol())
		// Servico Distribui Separação
		Self:cDisSep  := IIf(Empty(Self:oMovServic:GetDisSep()),"2",Self:oMovServic:GetDisSep())
	EndIf
	// Atividades da requisição
	If Self:oOrdServ:GetOrigem() == 'DH1'
		// Baixa estoque movimento interno de requisição
		Self:cBxEsto  := IIf(Empty(Self:oMovServic:GetBxEsto()),"2",Self:oMovServic:GetBxEsto())
	EndIf
	// Define o status que será atribuído às movimentações
	Self:cStatus := IIf(Self:oMovServic:GetBlqSrv() == "1","2","4")
	// Seta quantidade do movimento (unitizador completo é sempre 1)
	Self:nQtdMovto := Self:nQuant
	// Gera a movimentação de estoque por endereco
	If !Self:AssignD12()
		lRet := .F.
	EndIf
Return lRet

//------------------------------------------------------------------------------
METHOD CanUnitPar(lExeMovto) CLASS WMSBCCTransferencia
//------------------------------------------------------------------------------
Local aAreaAnt   := GetArea()
Local lRet       := .T.
Local lUnitMisto := .F.
Local lLoteMisto := .F.
Local lHasSldUni := .F.
Local nQtdMaxUni := 0
Local nQtdUniEnd := 0
Local nPesoUnit  := 0
Local nVolUnit   := 0
Local aRet       := {}
Local nPesoEnd   := 0
Local nVolEnd    := 0
Local nQtdPrdUni := 0
Local nToler1UM  := SuperGetMV("MV_NTOL1UM",.F.,0) // Qtde. de tolerancia p/calculos com a 1UM. Usado qdo o fator de conv gera um dizima periodica
Local oMntUnitiz := WMSDTCMontagemUnitizador():New()

Default lExeMovto := .F. // Indicador de que a validação está sendo chamada pela execução do movimento

	If Empty(Self:cUniDes) .Or. Empty(Self:oMovPrdLot:GetProduto()) .Or. Empty(Self:oMovEndDes:GetArmazem()) .Or. Empty(Self:oMovEndDes:GetEnder())
		Self:cErro := STR0008 // "Não foram passadas as informações para a validação da transferência do unitizador."
		Return .F.
	EndIf

	Self:oTmpSldD14 := WMSGTPSD14()
	If Self:oTmpSldD14 == Nil
		Self:cErro := STR0009 // Não foram criadas as temporárias necessárias para o processamento.
		Return .F.
	EndIf

	// Apaga algum registro que possa existir na temporária
	If !Self:DelSldD14()
		Return .F.
	EndIf

	// Valida se foi feito o LoadData do endereço destino
	If Empty(Self:oMovEndDes:GetEstFis())
		Self:oMovEndDes:LoadData()
	EndIf

	// Carrega os registros
	If !Self:LoadSldD14(lExeMovto,@lHasSldUni)
		Return .F.
	EndIf

	//Se não tem saldo no unitizador, deve verificar se o endereço suporta mais um unitizador
	If !lHasSldUni
		If WmsX312120("SBE","BE_NRUNIT")
			nQtdMaxUni := Iif(Self:oMovEndDes:GetNrUnit()>0,Self:oMovEndDes:GetNrUnit(),1)
		Else
			nQtdMaxUni := Iif(Self:oMovSeqAbt:GetNumUnit()>0,Self:oMovSeqAbt:GetNumUnit(),1)
		EndIf
		nQtdUniEnd := Self:CalcUniEnd()
		// Valida número máximo de unitizadores do endereço
		If (nQtdUniEnd + 1) > nQtdMaxUni
			// Estouro máximo de unitizadores
			Self:cErro := STR0010 // "Estouro máximo de unitizadores."
			lRet := .F.
		EndIf
	EndIf

	// Validações relativas ao tipo de endereçamento
	If lRet
		oMntUnitiz:SetIdUnit(Self:cUniDes)
		oMntUnitiz:SetTipUni(Self:cTipUni)
		oMntUnitiz:oTipUnit:LoadData()
		lUnitMisto := oMntUnitiz:IsMultPrd(/*cProduto*/,Self:oTmpSldD14)
		If !lUnitMisto
			lLoteMisto := oMntUnitiz:IsMultLot(/*cProduto*/,/*cLoteCtl*/,Self:oTmpSldD14)
		EndIf

		// Se não permite misturar produtos e é unitizador misto
		If Self:oMovSeqAbt:GetTipoEnd() != "4" .And. lUnitMisto
			// Tipo endereçamento não permite unitizador misto
			Self:cErro := STR0011 // "Tipo endereçamento não permite unitizador misto."
			lRet := .F.
		EndIf

		// Verifica se o unitizador a ser armazenado possui um produto diferente do existente no endereço
		// Pode ser que o unitizador destino seja um novo unitizador, portanto não há saldo nele no endereço
		If lRet .And. Self:oMovSeqAbt:GetTipoEnd() == "2" .And. !lHasSldUni
			If !Self:ValPrdLot(.F.)
				Self:cErro := STR0012 // "Tipo end. não permite misturar produtos. (Endereço)"
				lRet := .F.
			EndIf
		EndIf

		If lRet .And. !lUnitMisto
			// Busca a norma do produto
			nQtdNorma := DLQtdNorma(Self:oMovPrdLot:GetProduto(),Self:oMovEndDes:GetArmazem(),Self:oMovEndDes:GetEstFis(),,.F.)
			// Força para calcular a quantidade do produto no unitizador
			nQtdPrdUni := Self:QtdPrdUni()
			If QtdComp(nQtdNorma) < QtdComp(nQtdPrdUni) .And.;
				QtdComp(Abs(nQtdPrdUni-nQtdNorma)) > QtdComp(nToler1UM)
				Self:cErro := WmsFmtMsg(STR0020,{{"[VAR01]",cValtoChar(Self:GetQuant())},{"[VAR02]",cValtoChar(nQtdNorma)}}) // Quantidade informada ([VAR01]) ultrapassa a norma do produto ([VAR02]).
				lRet := .F.
			EndIf
		EndIf

		// Se não permite misturar lotes de um mesmo produto
		If lRet .And. Self:oMovSeqAbt:GetTipoEnd() == "3"
			// Verifica se o unitizador a ser armazenado possui mais de um lote
			If lLoteMisto
				// Tipo endereçamento não permite misturar lotes
				Self:cErro := STR0013 // "Tipo end. não permite misturar lotes. (Unitizador)"
				lRet := .F.
			EndIf
			// Verifica se o unitizador a ser armazenado possui um lote diferente do existente no endereço
			// Pode ser que o unitizador destino seja um novo unitizador, portanto não há saldo nele no endereço
			If lRet .And. !lHasSldUni
				If !Self:ValPrdLot(.T.)
					// Endereço possui lote diferente unitizador
					Self:cErro := STR0014 // "Tipo end. não permite misturar lotes. (Endereço)"
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf

	// Validações relativas a capacidade do endereço x unitizador
	If lRet
		// Calcula o peso e volume dos produtos do unitizador
		oMntUnitiz:SetArmazem(Self:oMovEndDes:GetArmazem())
		oMntUnitiz:SetEnder(Self:oMovEndDes:GetEnder())
		oMntUnitiz:CalcOcupac(Self:oTmpSldD14)
		// Calcula capacidade do unitizador
		If oMntUnitiz:GetPeso() > oMntUnitiz:GetCapMax()
			Self:cErro := STR0021 // Estouro do peso máximo suportado do unitizador.
			lRet := .F.
		EndIf

		If lRet
			nPesoUnit := oMntUnitiz:GetPeso() + oMntUnitiz:oTipUnit:GetTara()
			// Se controla a altura do unitizador por 1=ProdutoxCamada, deve somar o volume do unitizador
			If oMntUnitiz:oTipUnit:GetCtrAlt() == "1"
				nVolUnit := oMntUnitiz:GetVolume() + (oMntUnitiz:oTipUnit:GetLargura() * oMntUnitiz:oTipUnit:GetComprim() * oMntUnitiz:oTipUnit:GetAltura())
			Else
				// Caso seja pela altura do unitizador, sempre será considerado o volume do unitizador por completo
				nVolUnit := (oMntUnitiz:oTipUnit:GetLargura() * oMntUnitiz:oTipUnit:GetComprim() * oMntUnitiz:oTipUnit:GetAltura())
			EndIf

			// Calcula o peso e volume ocupados no endereço por outros unitizadores, caso existam
			aRet := Self:CalcOcupac()
			nPesoEnd := aRet[1]
			nVolEnd  := aRet[2]

			// Valida peso máximo do endereço
			If QtdComp(nPesoEnd + nPesoUnit) > QtdComp(Self:oMovEndDes:GetCapacid())
				// Estouro peso máximo
				Self:cErro := STR0015 // "Estouro do peso máximo suportado do endereço."
				lRet := .F.
			EndIf
			// Valida volume máximo do endereço
			If lRet .And. QtdComp(nVolEnd + nVolUnit) > QtdComp(Self:oMovEndDes:GetCubagem())
				// Estouro volume máximo
				Self:cErro := STR0016 // "Estouro do volume máximo suportado do endereço."
				lRet := .F.
			EndIf
		EndIf
	EndIf

	// Validações relativas as dimensões do endereço x unitizador
	If lRet
		// Calcula as dimensões do unitizador (Largura, Comprimento e Altura)
		oMntUnitiz:CalcDimens(Self:oTmpSldD14)
		// Valida altura máxima do endereço
		If QtdComp(oMntUnitiz:GetAltura()) > QtdComp(Self:oMovEndDes:GetAltura())
			// Altura unitizador maior que endereço
			Self:cErro := STR0017 // "Altura unitizador maior que endereço."
			lRet := .F.
		EndIf
		// Se não existia o unitizador no endereço, deve validar comprimento x largura
		If lRet .And. !lHasSldUni
			// Valida largura máxima do endereço
			If QtdComp(oMntUnitiz:GetLargura()) > QtdComp(Self:oMovEndDes:GetLargura())
				// Largura unitizador maior que endereço
				Self:cErro := STR0018 // "Largura unitizador maior que endereço."
				lRet := .F.
			EndIf
			// Valida comprimento máximo do endereço
			If lRet .And. QtdComp(oMntUnitiz:GetComprim()) > QtdComp(Self:oMovEndDes:GetComprim())
				// Comprimento unitizador maior que endereço
				Self:cErro := STR0019 // "Comprimento unitizador maior que endereço."
				lRet := .F.
			EndIf
		EndIf
	EndIf

Return lRet

//------------------------------------------------------------------------------
METHOD DelSldD14() CLASS WMSBCCTransferencia
//------------------------------------------------------------------------------
Local lRet    := .T.
Local cQuery  := ""

	cQuery := "DELETE FROM "+ Self:oTmpSldD14:GetRealName()
	If !(lRet := (TcSQLExec(cQuery) >= 0))
		Self:cErro := STR0005 // "Problema ao excluir os registros temporários do saldo do endereço."
	EndIf

Return lRet

//------------------------------------------------------------------------------
METHOD LoadSldD14(lExeMovto,lHasSldUni) CLASS WMSBCCTransferencia
//------------------------------------------------------------------------------
Local aAreaAnt   := GetArea()
Local lRet      := .T.
Local cQuery    := ""
Local cAliasD14 := ""
Local aTamSX3   := TamSx3("D14_QTDEST")
Local cAliasTmp := Self:oTmpSldD14:GetAlias()
Local nQuant    := Self:nQuant
Local nQtdEntPr := 0

	lHasSldUni := .F.
	// Inserindo na temp os registros de saldo unitizador
	cQuery := "SELECT D14.D14_PRDORI,"
	cQuery +=       " D14.D14_PRODUT,"
	cQuery +=       " D14.D14_LOTECT,"
	cQuery +=       " D14.D14_NUMLOT,"
	cQuery +=       " D14.D14_QTDEST,"
	cQuery +=       " D14.D14_QTDEPR,"
	cQuery +=       " D14.D14_CODUNI"
	cQuery +=  " FROM "+RetSqlName("D14")+" D14"
	cQuery += " WHERE D14.D14_FILIAL = '"+xFilial("D14")+"'"
	cQuery +=   " AND D14.D14_IDUNIT = '"+Self:cUniDes+"'"
	cQuery +=   " AND D14.D14_LOCAL  = '"+Self:oMovEndDes:GetArmazem()+"'"
	cQuery +=   " AND D14.D14_ENDER  = '"+Self:oMovEndDes:GetEnder()+"'"
	cQuery +=   " AND D14.D_E_L_E_T_ = ' '"
	cAliasD14 := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasD14,.F.,.T.)
	TcSetField(cAliasD14,'D14_QTDEST','N',aTamSX3[1],aTamSX3[2])
	TcSetField(cAliasD14,'D14_QTDEPR','N',aTamSX3[1],aTamSX3[2])
	If (cAliasD14)->(!Eof())
		While lRet .And. (cAliasD14)->(!Eof())
			// Desconta o saldo deste movimento, quando é o mesmo produto/lote
			If lExeMovto .And. QtdComp(nQuant) > 0 .And. ;
				(cAliasD14)->(D14_PRDORI+D14_PRODUT+D14_LOTECT+D14_NUMLOT) == Self:oMovPrdLot:GetPrdOri()+Self:oMovPrdLot:GetProduto()+Self:oMovPrdLot:GetLoteCtl()+Self:oMovPrdLot:GetNumLote()
				nQtdEntPr := (cAliasD14)->D14_QTDEPR - nQuant
				nQuant := 0
			Else
				nQtdEntPr := (cAliasD14)->D14_QTDEPR
			EndIf
			// Caso não esteja preenchido o tipo de untizador destino, pega do estoque
			If Empty(Self:cTipUni)
				Self:cTipUni := (cAliasD14)->D14_CODUNI
			EndIf
			// Pode ser que só tinha o registro de entrada prevista desta movimentação
			If QtdComp((cAliasD14)->D14_QTDEST+nQtdEntPr) > 0
				lHasSldUni := .T.
				RecLock(cAliasTmp,.T.)
				(cAliasTmp)->D14_FILIAL := xFilial("D14")
				(cAliasTmp)->D14_IDUNIT := Self:cUniDes
				(cAliasTmp)->D14_CODUNI := Self:cTipUni
				(cAliasTmp)->D14_LOCAL  := Self:oMovEndDes:GetArmazem()
				(cAliasTmp)->D14_ENDER  := Self:oMovEndDes:GetEnder()
				(cAliasTmp)->D14_ESTFIS := Self:oMovEndDes:GetEstFis()
				(cAliasTmp)->D14_PRODUT := (cAliasD14)->D14_PRODUT
				(cAliasTmp)->D14_LOTECT := (cAliasD14)->D14_LOTECT
				(cAliasTmp)->D14_NUMLOT := (cAliasD14)->D14_NUMLOT
				(cAliasTmp)->D14_QTDEST := (cAliasD14)->D14_QTDEST
				(cAliasTmp)->D14_QTDEPR := nQtdEntPr
				(cAliasTmp)->(MsUnlock())
			EndIf
			(cAliasD14)->(DbSkip())
		EndDo
	EndIf
	(cAliasD14)->(DbCloseArea())

	// Inserindo na temp o saldo do produto que se deseja adicionar ao unitizador
	(cAliasTmp)->(DbSetOrder(3)) // D14_PRODUT+D14_LOTECT+D14_NUMLOT
	If (cAliasTmp)->(DbSeek(Self:oMovPrdLot:GetProduto()+Self:oMovPrdLot:GetLoteCtl()+Self:oMovPrdLot:GetNumLote()))
		// Já existe o produto/lote no unitizador destino, soma apenas uma entrada prevista
		RecLock(cAliasTmp,.F.)
		(cAliasTmp)->D14_QTDEPR += Self:nQuant
		(cAliasTmp)->(MsUnlock())
		(cAliasTmp)->(DbCommit()) // Para forçar atualizar no banco
	Else
		// Caso não esteja preenchido o tipo de untizador destino, busca do tipo da etiqueta
		If Empty(Self:cTipUni)
			D0Y->(DbSetOrder(1)) // D0Y_FILIAL+D0Y_IDUNIT
			If D0Y->(DbSeek(xFilial("D0Y")+Self:cUniDes))
				Self:cTipUni := D0Y->D0Y_TIPUNI
			Else
				Self:cErro := "Etiqueta do unitizador não cadastrada!" // Etiqueta do unitizador não cadastrada!
				lRet := .F.
			EndIf
			If lRet .And. Empty(Self:cTipUni)
				Self:cErro := STR0022 // Não foi informado o tipo do unitizador destino.
				lRet := .F.
			EndIf
		EndIf
		// Não existe o produto/lote no unitizador destino, deve inserir o registro
		RecLock(cAliasTmp,.T.)
		(cAliasTmp)->D14_FILIAL := xFilial("D14")
		(cAliasTmp)->D14_IDUNIT := Self:cUniDes
		(cAliasTmp)->D14_CODUNI := Self:cTipUni
		(cAliasTmp)->D14_LOCAL  := Self:oMovEndDes:GetArmazem()
		(cAliasTmp)->D14_ENDER  := Self:oMovEndDes:GetEnder()
		(cAliasTmp)->D14_ESTFIS := Self:oMovEndDes:GetEstFis()
		(cAliasTmp)->D14_PRODUT := Self:oMovPrdLot:GetProduto()
		(cAliasTmp)->D14_LOTECT := Self:oMovPrdLot:GetLoteCtl()
		(cAliasTmp)->D14_NUMLOT := Self:oMovPrdLot:GetNumLote()
		(cAliasTmp)->D14_QTDEST := 0
		(cAliasTmp)->D14_QTDEPR := Self:nQuant
		(cAliasTmp)->(MsUnlock())
	EndIf

RestArea(aAreaAnt)
Return lRet

//------------------------------------------------------------------------------
METHOD CalcUniEnd() CLASS WMSBCCTransferencia
//------------------------------------------------------------------------------
Local lRet       := .T.
Local aAreaAnt   := GetArea()
Local cQuery     := ""
Local cAliasQry  := ""
Local nQtdUniEnd := 0

	cQuery := "SELECT COUNT(DISTINCT D14.D14_IDUNIT) D14_QTDUNI"
	cQuery +=  " FROM "+RetSqlName("D14")+" D14"
	cQuery += " WHERE D14.D14_FILIAL = '"+xFilial("D14")+"'"
	cQuery +=   " AND D14.D14_LOCAL = '"+Self:oMovEndDes:GetArmazem()+"'"
	cQuery +=   " AND D14.D14_ENDER = '"+Self:oMovEndDes:GetEnder()+"'"
	cQuery +=   " AND D14.D14_IDUNIT <> '"+Self:cUniDes+"'"
	cQuery +=   " AND D14.D_E_L_E_T_ = ' '"
	cAliasQry := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	If (cAliasQry)->(!Eof())
		nQtdUniEnd := (cAliasQry)->D14_QTDUNI
	EndIf
	(cAliasQry)->(DbCloseArea())
	RestArea(aAreaAnt)

Return nQtdUniEnd

//------------------------------------------------------------------------------
METHOD CalcOcupac() CLASS WMSBCCTransferencia
//------------------------------------------------------------------------------
Local aAreaAnt  := GetArea()
Local aRet      := {0,0}
Local cQuery    := ""
Local cAliasQry := ""
Local aTamSx3   := {}

	// Realiza o cálculo do peso dos produtos que já estão no endereço destino
	cQuery := " SELECT SUM ( ( SB1.B1_PESO + ("
	cQuery +=               " CASE WHEN (SB1.B1_CONV > 0 AND SB1.B1_TIPCONV = 'D')"
	cQuery +=                    " THEN (SB5.B5_ECPESOE / SB1.B1_CONV)"
	cQuery +=                    " ELSE  SB5.B5_ECPESOE"
	cQuery +=                " END ) ) * ( D14.D14_QTDEST + D14.D14_QTDEPR ) ) D14_PESUNI,"
	// Se o unitizador que está no endereço controla altura pelo unitizador, não calcula o volume dos itens
	cQuery +=        " SUM( CASE WHEN D0T.D0T_CTRALT = '2' THEN 0 ELSE "
	cQuery +=         " ( ( B5_COMPRLC * B5_LARGLC * B5_ALTURLC ) * ("
	cQuery +=             " CASE WHEN (SB1.B1_CONV > 0 AND SB1.B1_TIPCONV = 'D')"
	cQuery +=                   " THEN ( ( D14.D14_QTDEST + D14.D14_QTDEPR ) / SB1.B1_CONV)"
	cQuery +=                   " ELSE   ( D14.D14_QTDEST + D14.D14_QTDEPR )"
	cQuery +=               "END ) ) END ) D14_VOLUNI"
	cQuery +=   " FROM "+RetSqlName("D14")+" D14"
	cQuery +=  " INNER JOIN "+RetSqlName("D0T")+" D0T"
	cQuery +=     " ON D0T.D0T_FILIAL = '"+xFilial("D0T")+"'"
	cQuery +=    " AND D0T.D0T_CODUNI = D14.D14_CODUNI"
	cQuery +=  " INNER JOIN "+RetSqlName("SB1")+" SB1"
	cQuery +=     " ON SB1.B1_FILIAL = '"+xFilial("SB1")+"'"
	cQuery +=    " AND D14.D14_FILIAL = '"+xFilial("D14")+"'"
	cQuery +=    " AND SB1.B1_COD = D14.D14_PRODUT"
	cQuery +=    " AND SB1.D_E_L_E_T_ = ' '"
	cQuery +=  " INNER JOIN "+RetSqlName("SB5")+" SB5"
	cQuery +=     " ON SB5.B5_FILIAL = '"+xFilial("SB5")+"'"
	cQuery +=    " AND SB1.B1_FILIAL = '"+xFilial("SB1")+"'"
	cQuery +=    " AND SB5.B5_COD = SB1.B1_COD"
	cQuery +=    " AND SB5.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE D14.D14_FILIAL = '"+xFilial("D14")+"'"
	cQuery +=    " AND D14.D14_LOCAL = '"+Self:oMovEndDes:GetArmazem()+"'"
	cQuery +=    " AND D14.D14_ENDER = '"+Self:oMovEndDes:GetEnder()+"'"
	cQuery +=    " AND D14.D14_IDUNIT <> '"+Self:cUniDes+"'" // Não deve considerar o unitizador destino atual
	cQuery +=    " AND D14.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasQry:= GetNextAlias()
	dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	aTamSx3 := TamSx3("B1_PESO"); TcSetField(cAliasQry,'D14_PESUNI','N',aTamSx3[1],aTamSx3[2])
	TcSetField(cAliasQry,'D14_VOLUNI','N',16,6)
	If (cAliasQry)->(!Eof())
		aRet[1] := (cAliasQry)->D14_PESUNI
		aRet[2] := (cAliasQry)->D14_VOLUNI
	EndIf
	(cAliasQry)->(DbCloseArea())

	// Realiza o cálculo do peso dos unitizadores que já estão no endereço destino
	cQuery := " SELECT SUM (D0T_TARA * NRU.D14_NRUNIT) D0T_PESUNI,"
	cQuery +=        " SUM ((D0T_ALTURA * D0T_LARGUR * D0T_COMPRI) * NRU.D14_NRUNIT) D0T_VOLUNI"
	cQuery +=   " FROM "+RetSqlName("D0T")+" D0T"
	cQuery +=  " INNER JOIN (SELECT COUNT(DISTINCT D14.D14_IDUNIT) D14_NRUNIT,"
	cQuery +=                     " D14.D14_CODUNI"
	cQuery +=                " FROM "+RetSqlName("D14")+" D14"
	cQuery +=               " WHERE D14.D14_FILIAL = '"+xFilial("D14")+"'"
	cQuery +=                 " AND D14.D14_LOCAL = '"+Self:oMovEndDes:GetArmazem()+"'"
	cQuery +=                 " AND D14.D14_ENDER = '"+Self:oMovEndDes:GetEnder()+"'"
	cQuery +=                 " AND D14.D14_IDUNIT <> '"+Self:cUniDes+"'" // Não deve considerar o unitizador destino atual
	cQuery +=                 " AND D14.D_E_L_E_T_ = ' '
	cQuery +=               " GROUP BY D14.D14_CODUNI) NRU"
	cQuery +=     " ON D0T.D0T_CODUNI = NRU.D14_CODUNI"
	cQuery +=  " WHERE D0T.D0T_FILIAL = '"+xFilial("D0T")+"'"
	cQuery +=    " AND D0T.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasQry:= GetNextAlias()
	dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	aTamSx3 := TamSx3("D0T_TARA"); TcSetField(cAliasQry,'D0T_PESUNI','N',aTamSx3[1],aTamSx3[2])
	TcSetField(cAliasQry,'D0T_VOLUNI','N',16,6)
	If (cAliasQry)->(!Eof())
		aRet[1] += (cAliasQry)->D0T_PESUNI
		aRet[2] += (cAliasQry)->D0T_VOLUNI
	EndIf
	(cAliasQry)->(DbCloseArea())

	RestArea(aAreaAnt)
Return aRet

//------------------------------------------------------------------------------
METHOD ValPrdLot(lLoteCtl) CLASS WMSBCCTransferencia
//------------------------------------------------------------------------------
Local lRet      := .T.
Local aAreaAnt  := GetArea()
Local cQuery    := ""
Local cAliasQry := ""
Default lLoteCtl:= .F.

	cQuery := "SELECT DISTINCT D141.D14_ENDER"
	cQuery +=  " FROM "+RetSqlName("D14")+" D141"
	cQuery += " WHERE D141.D14_FILIAL = '"+xFilial("D14")+"'"
	cQuery +=   " AND D141.D14_LOCAL = '"+Self:oMovEndDes:GetArmazem()+"'"
	cQuery +=   " AND D141.D14_ENDER = '"+Self:oMovEndDes:GetEnder()+"'"
	cQuery +=   " AND D141.D_E_L_E_T_ = ' '"
	cQuery +=   " AND NOT EXISTS (SELECT DISTINCT 1"
	cQuery +=                     " FROM "+Self:oTmpSldD14:GetRealName()+" D142"
	cQuery +=                    " WHERE D142.D14_FILIAL = '"+xFilial("D14")+"'"
	cQuery +=                      " AND D142.D14_IDUNIT = '"+Self:cUniDes+"'"
	cQuery +=                      " AND D142.D14_PRODUT = D141.D14_PRODUT"
	If lLoteCtl
		cQuery +=                   " AND D142.D14_LOTECT = D141.D14_LOTECT"
	EndIf
	cQuery +=                      " AND D142.D_E_L_E_T_ = ' ')"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	If (cAliasQry)->(!Eof())
		lRet := .F.
	EndIf
	(cAliasQry)->(DbCloseArea())
	RestArea(aAreaAnt)

Return lRet

//------------------------------------------------------------------------------
METHOD QtdPrdUni() CLASS WMSBCCTransferencia
//------------------------------------------------------------------------------
Local nQtdPrdUni := 0
Local cQuery     := ""
Local cAliasQry  := Nil
Local aTamSX3    := TamSx3("D14_QTDEST")
	cQuery := "SELECT SUM(D14_QTDEST+D14_QTDEPR) PRD_QUANT"
	cQuery +=  " FROM "+Self:oTmpSldD14:GetRealName()+" D14"
	cQuery += " WHERE D14.D14_FILIAL = '"+xFilial("D14")+"'"
	cQuery +=   " AND D14.D14_LOCAL  = '"+Self:oMovEndDes:GetArmazem()+"'"
	cQuery +=   " AND D14.D14_PRODUT = '"+Self:oMovPrdLot:GetProduto()+"'"
	cQuery +=   " AND D14.D14_ENDER  = '"+Self:oMovEndDes:GetEnder()+"'"
	cQuery +=   " AND D14.D14_IDUNIT = '"+Self:cUniDes+"'"
	cQuery +=   " AND (D14.D14_QTDEST+D14.D14_QTDEPR) > 0"
	cQuery +=   " AND D14.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	TcSetField(cAliasQry,'PRD_QUANT','N',aTamSX3[1],aTamSX3[2])
	If (cAliasQry)->(!Eof())
		nQtdPrdUni := (cAliasQry)->PRD_QUANT
	EndIf
	(cAliasQry)->(dbCloseArea())
Return nQtdPrdUni

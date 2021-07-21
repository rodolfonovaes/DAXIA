#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'APVT100.CH'
#INCLUDE 'WMSV095.CH'

#DEFINE WMSV09501 "WMSV09501"
#DEFINE WMSV09502 "WMSV09502"
#DEFINE WMSV09503 "WMSV09503"
#DEFINE WMSV09505 "WMSV09505"
#DEFINE WMSV09506 ""
#DEFINE WMSV09507 ""
#DEFINE WMSV09508 ""
#DEFINE WMSV09509 "WMSV09509"
#DEFINE WMSV09510 ""
#DEFINE WMSV09511 "WMSV09511"
#DEFINE WMSV09512 "WMSV09512"
#DEFINE WMSV09513 "WMSV09513"
#DEFINE WMSV09514 "WMSV09514"
#DEFINE WMSV09515 "WMSV09515"
#DEFINE WMSV09516 "WMSV09516"
#DEFINE WMSV09517 "WMSV09517"
#DEFINE WMSV09518 "WMSV09518"
#DEFINE WMSV09519 "WMSV09519"
#DEFINE WMSV09520 "WMSV09520"
#DEFINE WMSV09521 "WMSV09521"
#DEFINE WMSV09522 "WMSV09522"
#DEFINE WMSV09523 "WMSV09523"
#DEFINE WMSV09524 "WMSV09524"
#DEFINE WMSV09525 "WMSV09525"
#DEFINE WMSV09526 "WMSV09526"
#DEFINE WMSV09527 "WMSV09527"
#DEFINE WMSV09528 "WMSV09528"
#DEFINE WMSV09529 "WMSV09529"
#DEFINE WMSV09530 "WMSV09530"
#DEFINE WMSV09531 "WMSV09531"
#DEFINE WMSV09532 "WMSV09532"
#DEFINE WMSV09533 "WMSV09533"
#DEFINE WMSV09534 "WMSV09534"
#DEFINE WMSV09535 "WMSV09535"
#DEFINE WMSV09536 "WMSV09536"
#DEFINE WMSV09537 "WMSV09537"
#DEFINE WMSV09538 "WMSV09538"
#DEFINE WMSV09539 "WMSV09539"
#DEFINE WMSV09540 "WMSV09540"

Static oOrdServ := Nil
Static oTransf  := WMSBCCTransferencia():New()

//------------------------------------------------------------
/*/{Protheus.doc} WMSV095
Transferência de produtos entre endereços.
@author felipe.m
@since 01/04/2015
@version 1.0
/*/
//------------------------------------------------------------
User Function WMSVU()
Local aAreaAnt := GetArea()
Local lRet     := .T.
// Salva todas as teclas de atalho anteriores
Local aSavKey  := VTKeys()
Local lExit    := .F.
Local cArmAnt  := PadR("",TamSx3("D14_LOCAL")[1])
Local lMovTot  := .F.

	// Permite efetuar validações, apresentar mensagem e abortar o programa quando desejado
	If !WMSChkPrg(FunName(),"1")
	   Return Nil
	EndIf

	// Cria as tabelas temporárias utilizadas no caso de transferência unitizada
	WMSCTPENDU()

	Do While .T.
		// Inicializa oOrdServ
		If !Empty(oOrdServ)
			cArmAnt := oOrdServ:oOrdEndOri:GetArmazem()
		EndIf
		oOrdServ := WMSDTCOrdemServicoCreate():New()
		WmsOrdSer(oOrdServ)
		// atribui armazem
		oOrdServ:oOrdEndOri:SetArmazem(cArmAnt)
		// Atribui data e hora inicio
		oOrdServ:SetData(dDataBase)
		oOrdServ:SetHora(Time())
		// Solicita endereço origem
		lExit := GetEndOri()
		// Se o armazém origem for unitizado e o endereço origem for picking ou produção, solicita o unitizador
		If !lExit .And. oOrdServ:oOrdEndOri:IsArmzUnit() .And. !(oOrdServ:oOrdEndOri:GetTipoEst() == 2 .Or. oOrdServ:oOrdEndOri:GetTipoEst() == 7)
			lExit := GetUniOri(oOrdServ:oOrdEndOri:GetArmazem(),oOrdServ:oOrdEndOri:GetEnder(),@lMovTot)
		EndIf
		// Confirma dados do produto
		If !lExit .And. !lMovTot
			ConfirmPrd(@lExit)
		EndIf
		// Solicita o endereço destino da transferência
		If !lExit
			lExit := GetEndDes()
		EndIf
		// Saida
		If lExit
			Exit
		EndIf
		lMovTot := .F.
	EndDo
	VTClear()
	VTKeyBoard(chr(13))
	VTInkey(0)
	// Restaura as teclas de atalho anteriores
	VTKeys(aSavKey)
	RestArea(aAreaAnt)
Return lRet

/*--------------------------------------------------------------------------------
---GetEndOri
---Atribui armazem e endereço origem
---felipe.m - 01/04/2015
----------------------------------------------------------------------------------*/
Static Function GetEndOri()
Local lAbandona := .F.
Local cEnderOri := PadR("",TamSx3("D14_ENDER")[1])
Private cArmazem  := PadR(oOrdServ:oOrdEndOri:GetArmazem(),TamSx3("D14_LOCAL")[1])
	  Do While !lAbandona
		 WMSVTCabec(STR0001,.F.,.F.,.T.) // Transferência
		 @ 01,00 VTSay PadR(STR0018,VTMaxCol()) // Armazem
		 @ 02,00 VTGet cArmazem Pict "@!" Valid VldArmOri(cArmazem) F3 'NNR'
		 @ 03,00 VTSay PadR(STR0002,VTMaxCol()) // Endereco Origem
		 @ 04,00 VTGet cEnderOri Pict "@!" Valid VldEndOri(cEnderOri)
		 VTKeyBoard(Chr(13))
		 VtRead()
		 /*PODE SER QUE PRECISA DA CUSTOMIZAÇÃO*/
		 // Valida se foi pressionado Esc
		 If VTLastKey() == 27
			If !Escape(@lAbandona)
				Loop
			EndIf
		 EndIf
		 Exit
	  EndDo
Return lAbandona

/*--------------------------------------------------------------------------------
---ConfirmPrd
---Solicita produto/lote/sub-lote e quantidade
---felipe.m - 01/04/2015
----------------------------------------------------------------------------------*/
Static Function ConfirmPrd(lExit)
Local aAreaAnt   := GetArea()
Local lRet       := .T.
Local lCtrlInter := .F.
Local cAliasD14  := ""
Local cProduto   := PadR("", TamSx3("D14_PRODUT")[1])
Local cLoteCtl   := PadR("", TamSx3("D14_LOTECT")[1])
Local cNumLote   := PadR("", TamSx3("D14_NUMLOT")[1])
Local cCodBar    := ""
Local cQuery     := ""
Local nQtdNorma  := 0
Local nQuant     := 0
Local nItem      := 0
Local nLin       := 1
Local lLoop      := .F.
	// Verifica se o endereço origem possui saldo a ser movimentado
	cQuery := " SELECT DISTINCT D14_FILIAL"
	cQuery +=   " FROM "+RetSqlName("D14")
	cQuery +=  " WHERE D14_FILIAL = '"+xFilial("D14")+"'"
	cQuery +=    " AND D14_LOCAL  = '"+oOrdServ:oOrdEndOri:GetArmazem()+"'"
	cQuery +=    " AND D14_ENDER  = '"+oOrdServ:oOrdEndOri:GetEnder()+"'"
	cQuery +=    " AND (D14_QTDEST - (D14_QTDSPR + D14_QTDEMP + D14_QTDBLQ)) > 0"
	cQuery +=    " AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasD14  := GetNextAlias()
	dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasD14,.F.,.T.)
	If (cAliasD14)->(Eof())
		WMSVTAviso(WMSV09509,STR0025) // Este endereco esta vazio!
		lRet  := .F.
		lExit := .T.
	EndIf
	(cAliasD14)->(dbCloseArea())
	If lRet
		// Limpa as informações do produto
		oOrdServ:oProdLote:ClearData()
		Do While !lCtrlInter
			// Zera as variáveis que serão utilizadas
			lLoop      := .F.
			nLin       := 1
			cCodbar    := Space(128)
			cProduto   := Space(TamSx3("D14_PRODUT")[1])
			// Solicita o código do produto a ser movimentado
			WMSVTCabec(STR0001,.F.,.F.,.T.) // Transferência
			@ nLin++,00 VTSay PadR(STR0003,VTMaxCol())
			@ nLin++,00 VtGet cCodBar Picture "@!" Valid ValidPrdLot(@cProduto,@cLoteCtl,@cNumLote,@nQuant,@cCodBar)
			VtRead()
			// Valida se foi pressionado Esc
			If VTLastKey() == 27
				If !Escape(@lCtrlInter)
					Loop
				Else
					lRet  := .F.
					lExit := .T.
					Exit
				EndIf
			EndIf
			lRet := TrfProdut(cProduto,cLoteCtl,cNumLote,@nQuant,@nItem,@lCtrlInter,@lExit,@lLoop,nLin)
			If lLoop
				Loop
			EndIf
			Exit
		EndDo
	EndIf
	// Realiza os tratamentos a respeito da unidade de medida do produto
	If lRet
		// O sistema trabalha sempre na 1a.UM
		If nItem == 1
			// Converter de U.M.I. p/ 1a.UM
			nQtdNorma:= DLQtdNorma(oOrdServ:oProdLote:GetProduto(),oOrdServ:oOrdEndOri:GetArmazem(),oOrdServ:oOrdEndOri:GetEstFis(),,.F.)
			oOrdServ:SetQuant(nQuant*nQtdNorma)
		ElseIf nItem == 2
			// Converter de 2a.UM p/ 1a.UM
			oOrdServ:SetQuant(ConvUm(oOrdServ:oProdLote:GetProduto(),0,nQuant,1))
		Else
			oOrdServ:SetQuant(nQuant)
		EndIf
	EndIf
	RestArea(aAreaAnt)
Return lRet

/*--------------------------------------------------------------------------------
---TrfProdut
---Transferência de produto normal ou unitizador parcial
---felipe.m - 01/04/2015
----------------------------------------------------------------------------------*/
Static Function TrfProdut(cProduto,cLoteCtl,cNumLote,nQuant,nItem,lCtrlInter,lExit,lLoop,nLin)
Local lRet     := .T.
Local cPrdOri  := PadR("", TamSx3("D14_PRDORI")[1])
Local nQtdTot  := 0
Local lWmsLote := SuperGetMV('MV_WMSLOTE',.F.,.F.) // Solicita a confirmacao do lote nas operacoes com RF
Local cWmsUMI  := ""
Local oTarefa  := WMSDTCTarefaAtividade():New()
Local cUM      := ""
Local cPictQt  := ""
Local nQtdItem := 0
	lLoop := .F.
	// Valida saldo e permite selecionar o produto/lote no endereço de origem
	If !PrdSldEnd(oOrdServ:oOrdEndOri:GetArmazem(),oOrdServ:oOrdEndOri:GetEnder(),@cPrdOri,cProduto,@cLoteCtl,@cNumLote,@nQtdTot)
		lLoop := .T.
		Return .F.
	EndIf
	oOrdServ:oProdLote:SetPrdOri(cPrdOri)
	oOrdServ:oProdLote:SetArmazem(oOrdServ:oOrdEndOri:GetArmazem())
	oOrdServ:oProdLote:SetProduto(cProduto)
	oOrdServ:oProdLote:SetLoteCtl(cLoteCtl)
	oOrdServ:oProdLote:SetNumLote(cNumLote)
	oOrdServ:oProdLote:SetNumSer("")
	oOrdServ:oProdLote:LoadData()
	If lWmsLote
		If oOrdServ:oProdLote:HasRastro()
			@ nLin,00  VtSay STR0004 // Lote:
			@ nLin++,06  VtGet cLoteCtl Picture "@!" When VTLastKey()==05 .Or. Empty(cLoteCtl) Valid ValidLote(cLoteCtl)
		EndIf
		If oOrdServ:oProdLote:HasRastSub()
			@ nLin,00 VTSay STR0005 // Sub-Lote:
			@ nLin++,10 VTGet cNumLote Picture "@!" When VTLastKey()==05 .Or. Empty(cNumLote) Valid ValSubLote(cNumLote)
		EndIf
		VtRead()
	EndIf
	If !Empty(oOrdServ:oProdLote:GetSerTran())
		// Serviço de transferência preenchido no cadastro SB5.
		oOrdServ:oServico:SetServico(oOrdServ:oProdLote:GetSerTran())
	Else
		// Retorna o primeiro serviço de transferência encontrado.
		oOrdServ:oServico:SetServico(oOrdServ:oServico:ChkServico('8')) // Operação de transferencia
	EndIf
	oOrdServ:oServico:LoadData()
	// Atribui tarefa
	oTarefa:SetTarefa(oOrdServ:oServico:GetTarefa())
	oTarefa:LoadData()
	// Carrega unidade de medida, simbolo da unidade e quantidade na unidade
	WmsValUM(@nQtdTot,;                           // Quantidade movimento
			@cWmsUMI,;                             // Unidade parametrizada
			oOrdServ:oProdLote:GetProduto(),;      // Produto
			oOrdServ:oOrdEndOri:GetArmazem(),;     // Armazem
			oOrdServ:oOrdEndOri:GetEnder())        // Endereço
	Do While !lCtrlInter
		// Monta tela produto
		WmsMontPrd(cWmsUMI,;                        // Unidade parametrizada
					.F.,;                              // Indica se é uma conferência
					oTarefa:GetDesTar(),;              // Descrição da tarefa
					oOrdServ:oOrdEndOri:GetArmazem(),; // Armazem
					oOrdServ:oOrdEndOri:GetEnder(),;   // Endereço
					oOrdServ:oProdLote:GetPrdOri(),;   // Produto Origem
					oOrdServ:oProdLote:GetProduto(),;  // Produto
					oOrdServ:oProdLote:GetLoteCtl(),;  // Lote
					oOrdServ:oProdLote:GetNumLote())   // sub-lote
		// Valida se foi pressionado Esc
		If VTLastKey() == 27
			If !Escape(@lCtrlInter)
				Loop
			Else
				lRet  := .F.
				lExit := .T.
			EndIf
		EndIf
		Exit
	EndDo

	If lRet
		Do While !lCtrlInter
			// Seleciona unidade de medida
			WmsSelUM(cWmsUMI,;                        // Unidade parametrizada
					@cUM,;                             // Unidade medida reduzida
					Nil,;                              // Descrição unidade medida
					nQtdTot,;                          // Quantidade movimento
					@nItem,;                           // Item seleção unidade
					@cPictQt,;                         // Mascara unidade medida
					@nQtdItem,;                        // Quantidade no item seleção unidade
					.F.,;                              // Indica se é uma conferência
					oTarefa:GetDesTar(),;              // Descrição da tarefa
					oOrdServ:oOrdEndOri:GetArmazem(),; // Armazem
					oOrdServ:oOrdEndOri:GetEnder(),;   // Endereço
					oOrdServ:oProdLote:GetPrdOri(),;   // Produto Origem
					oOrdServ:oProdLote:GetProduto(),;  // Produto
					oOrdServ:oProdLote:GetLoteCtl(),;  // Lote
					oOrdServ:oProdLote:GetNumLote())   // sub-lote
			// Valida se foi pressionado Esc
			If VTLastKey() == 27
				If !Escape(@lCtrlInter)
					Loop
				Else
					lRet  := .F.
					lExit := .T.
				EndIf
			EndIf
			Exit
		EndDo
	EndIf
	If lRet
		Do While !lCtrlInter
			@ nLin++,00 VTSay PadR('Qtd'+' '+AllTrim(Str(nQtdItem))+' '+cUM, VTMaxCol()) // Qtd 240.00 UN
			@ nLin++,00 VTGet nQuant Pict PesqPict('D12','D12_QTDMOV') When VTLastKey()==05 .Or. Empty(nQuant) Valid !Empty(nQuant) .And. (QtdComp(nQuant) <= QtdComp(nQtdItem))
			VtRead()
			// Valida se foi pressionado Esc
			If VTLastKey() == 27
				If !Escape(@lCtrlInter)
					nLin -= 2
					Loop
				Else
					lRet  := .F.
					lExit := .T.
				EndIf
			EndIf
			Exit
		EndDo
		If lRet .And. QtdComp(nQuant) > QtdComp(nQtdItem)
			WMSVTAviso(WMSV09527,WmsFmtMsg(STR0035,{{"[VAR01]",cValToChar(nQuant)},{"[VAR02]",cValToChar(nQtdItem)}}))   // Quantidade informada [VAR01] maior que os saldo [VAR02]!
			lLoop := .T.
		EndIf
	EndIf
Return lRet

//-----------------------------------------------
/*/{Protheus.doc} TrfUnitiz
Transferência de unitizador completo
@author  Guilherme A. Metzger
@since   10/05/2017
@version 1.0
/*/
//-----------------------------------------------
Static Function TrfUnitiz()
Local aAreaAnt  := GetArea()
Local lRet      := .T.
Local cQuery    := ""
Local cAliasD14 := ""
Local aTamSX3   := TamSX3("D14_QTDEST")
	// Valida se o saldo está comprometido ou se é apenas uma previsão
	cQuery := "SELECT SUM(D14_QTDEST) D14_QTDEST,"
	cQuery +=       " SUM(D14_QTDEPR) D14_QTDEPR,"
	cQuery +=       " SUM(D14_QTDSPR) D14_QTDSPR,"
	cQuery +=       " SUM(D14_QTDEMP) D14_QTDEMP,"
	cQuery +=       " SUM(D14_QTDBLQ) D14_QTDBLQ"
	cQuery +=  " FROM " + RetSqlName("D14")
	cQuery += " WHERE D14_FILIAL = '"+xFilial("D14")+"'"
	cQuery +=   " AND D14_LOCAL  = '"+oOrdServ:oOrdEndOri:GetArmazem()+"'"
	cQuery +=   " AND D14_ENDER  = '"+oOrdServ:oOrdEndOri:GetEnder()+"'"
	cQuery +=   " AND D14_IDUNIT = '"+oOrdServ:GetIdUnit()+"'"
	cQuery +=   " AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasD14 := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasD14,.F.,.T.)
	TcSetField(cAliasD14,'D14_QTDEST','N',aTamSX3[1],aTamSX3[2])
	TcSetField(cAliasD14,'D14_QTDEPR','N',aTamSX3[1],aTamSX3[2])
	TcSetField(cAliasD14,'D14_QTDSPR','N',aTamSX3[1],aTamSX3[2])
	TcSetField(cAliasD14,'D14_QTDEMP','N',aTamSX3[1],aTamSX3[2])
	TcSetField(cAliasD14,'D14_QTDBLQ','N',aTamSX3[1],aTamSX3[2])
	If QtdComp((cAliasD14)->D14_QTDEST) > 0
		If QtdComp((cAliasD14)->D14_QTDEPR) > 0
			WMSVTAviso(WMSV09529,STR0065) // "Existem movimentações de entrada pendentes para este endereço/unitizador."
			lRet  := .F.
		ElseIf QtdComp((cAliasD14)->D14_QTDSPR+(cAliasD14)->D14_QTDEMP+(cAliasD14)->D14_QTDBLQ) > 0
			WMSVTAviso(WMSV09532,STR0047) // "O saldo deste unitizador está total ou parcialmente comprometido!"
			lRet  := .F.
		EndIf
	Else
		WMSVTAviso(WMSV09533,STR0048) // "A movimentação de estoque do unitizador para este endereço ainda não foi realizada!"
		lRet  := .F.
	EndIf
	(cAliasD14)->(DbCloseArea())
	// Sugere o serviço de transferência com base no primeiro produto encontrado no unitizador
	If lRet
		cQuery := "SELECT D14_PRODUT"
		cQuery +=  " FROM " + RetSqlName("D14")
		cQuery += " WHERE D14_FILIAL = '"+xFilial("D14")+"'"
		cQuery +=   " AND D14_LOCAL  = '"+oOrdServ:oOrdEndOri:GetArmazem()+"'"
		cQuery +=   " AND D14_ENDER  = '"+oOrdServ:oOrdEndOri:GetEnder()+"'"
		cQuery +=   " AND D14_IDUNIT = '"+oOrdServ:GetIdUnit()+"'"
		cQuery +=   " AND D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasD14 := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasD14,.F.,.T.)
		If !(cAliasD14)->(Eof())
			oOrdServ:oProdLote:SetProduto((cAliasD14)->D14_PRODUT)
			oOrdServ:oProdLote:LoadData()
			If !Empty(oOrdServ:oProdLote:GetSerTran())
				// Serviço de transferência preenchido no cadastro SB5.
				oOrdServ:oServico:SetServico(oOrdServ:oProdLote:GetSerTran())
			Else
				// Retorna o primeiro serviço de transferência encontrado
				oOrdServ:oServico:SetServico(oOrdServ:oServico:ChkServico('8')) // Operação de transferencia
			EndIf
			oOrdServ:oServico:LoadData()
			// Limpa os dados do produto, pois é movimentação de unitizador completo
			oOrdServ:oProdLote:ClearData()
			// Para movimentação de unitizador completo
			// O unitizador destino é igual ao origem
			oOrdServ:SetUniDes(oOrdServ:GetIdUnit())
			oOrdServ:SetTipUni(oOrdServ:GetTipUni())
			// A quantidade é sempre igual a 1
			oOrdServ:SetQuant(1)
		EndIf
		(cAliasD14)->(DbCloseArea())
	EndIf
RestArea(aAreaAnt)
Return lRet

/*--------------------------------------------------------------------------------
---GetEndDes
---Adquire o endereço destino da transferência.
---felipe.m - 01/04/2015
---cArmazem, character, (Armazém destino, que sempre será o mesmo do origem)
---cEnderDes, character, (Endereço destino da transferencia)
---cProduto, character, (Produto para validação do endereço destino)
---nQuant, numérico, (Quantidade para validação do endereço destino)
----------------------------------------------------------------------------------*/
Static Function GetEndDes()
Local lAbandona := .F.
Local lConfirm  := .F.
Local cArmDes   := PadR("",TamSx3("D14_LOCAL" )[1])
Local cEnderDes := PadR("",TamSx3("D14_ENDER" )[1])
Local cEnderAux := PadR("",TamSx3("D14_ENDER" )[1])
Local nLin      := 1
	// Inicializa armazem destino
	cArmDes := oOrdServ:oOrdEndOri:GetArmazem()
	Do While !lAbandona
		WMSVTCabec(STR0001,.F.,.F.,.T.) // Transferência
		@ 01,00 VTSay PadR(STR0018,VTMaxCol()) // Armazem
		@ 02,00 VTGet cArmDes Pict "@!" Valid VldArmDes(cArmDes) F3 'NNR'
		@ 03,00 VTSay PadR(STR0009,VTMaxCol()) // Endereco Destino
		@ 04,00 VTGet cEnderDes Pict "@!" Valid VldEndDes(@cEnderDes,cArmDes,@lConfirm)
		VTRead()
		// Valida se foi pressionado Esc
		If VTLastKey() == 27
			If !Escape(@lAbandona)
				nLin := 1
				Loop
			EndIf
		EndIf
		// Quando o WMS sugere o endereço, deve solicitar a confirmação ao operador
		If !lAbandona .And. lConfirm
			@ 05,00 VTSay PadR(STR0037, VTMaxCol())  // Confirme!
			@ 06,00 VTGet cEnderAux Pict "@!" Valid !Empty(cEnderAux) .And. VldConfirm(cEnderDes,cEnderAux,cArmDes)
			VTRead()
			// Valida se foi pressionado Esc
			If VTLastKey() == 27
				If !Escape(@lAbandona)
					nLin := 1
					Loop
				EndIf
			EndIf
		EndIf
		// Se o destino for um armazém unitizado e a movimentação não for de unitizador completo
		If !lAbandona .And. oOrdServ:oOrdEndDes:IsArmzUnit() .And. !oOrdServ:IsMovUnit()
			// Caso endereço destino seja um picking ou seja a DOCA no processo de separação, limpa o unidizador destino do movimento
			If (oOrdServ:oOrdEndDes:GetTipoEst() <> 2 .And. oOrdServ:oOrdEndDes:GetTipoEst() <> 7)
				// Solicita o código do unitizador
				If !GetUniDes(cArmDes,cEnderDes) .And. !Escape(@lAbandona)
					nLin := 1
					Loop
				EndIf
			EndIf
		EndIf
		// Realiza a transferência conforme os dados informados
		If !lAbandona
			lAbandona := !Transfere()
		EndIf
		Exit
	EndDo
Return lAbandona

//-----------------------------------------------
/*/{Protheus.doc} GetUniOri
Solicita as informações do unitizador origem da transferência
@author  Guilherme A. Metzger
@since   31/05/2017
@version 1.0
/*/
//-----------------------------------------------
Static Function GetUniOri(cArmazem,cEndereco,lMovTot)
Local cIdUnit   := PadR("",TamSx3("D14_IDUNIT")[1])
Local lAbandona := .F.
	While !lAbandona
		WMSVTCabec(STR0001,.F.,.F.,.T.) // Transferência
		@ 01,00 VTSay PadR(STR0049,VTMaxCol()) // Unitizador
		@ 02,00 VTGet cIdUnit Pict "@!" Valid VldUniOri(cArmazem,cEndereco,cIdUnit)
		VTRead()
		// Valida se foi pressionado Esc
		If VTLastKey() == 27
			If !Escape(@lAbandona)
				Loop
			EndIf
		EndIf
		// Verifica se é movimentação total do unitizador
		If !lAbandona .And. WmsQuestion(STR0050) // "Deseja movimentar o unitizador por completo?"
			lAbandona := !TrfUnitiz()
			lMovTot   := .T.
		EndIf
		// Valida se foi pressionado Esc
		If !lAbandona .And. VTLastKey() == 27
			If !Escape(@lAbandona)
				Loop
			EndIf
		EndIf
		Exit
	EndDo
Return lAbandona

//-----------------------------------------------
/*/{Protheus.doc} VldUniOri
Valida o unitizador origem informado
@author  Guilherme A. Metzger
@since   31/05/2017
@version 1.0
/*/
//-----------------------------------------------
Static Function VldUniOri(cArmazem,cEndereco,cIdUnit)
Local aAreaAnt  := GetArea()
Local cQuery    := ""
Local cAliasD14 := ""
Local lRet      := .T.
	  If Empty(cIdUnit)
		 Return ListUnitiz(cArmazem,cEndereco)
	  EndIf
	  // Valida se o unitizador possui caractere especial
	  If !WmsVlStr(cIdUnit)
		 Return .F.
	  EndIf
	  // Valida o tamanho do código digitado
	  If Len(AllTrim(cIdUnit)) != TamSx3("D0R_IDUNIT")[1]
		 WMSVTAviso(WMSV09519,STR0051) // "Tamanho do código do unitizador inválido!"
		 Return .F.
	  EndIf
	  cQuery := " SELECT 1"
	  cQuery +=   " FROM "+RetSqlName("D14")
	  cQuery +=  " WHERE D14_FILIAL = '"+xFilial("D14")+"'"
	  cQuery +=    " AND D14_LOCAL  = '"+oOrdServ:oOrdEndOri:GetArmazem()+"'"
	  cQuery +=    " AND D14_ENDER  = '"+oOrdServ:oOrdEndOri:GetEnder()+"'"
	  cQuery +=    " AND D14_IDUNIT = '"+cIdUnit+"'"
	  cQuery +=    " AND D_E_L_E_T_ = ' '"
	  cQuery := ChangeQuery(cQuery)
	  cAliasD14  := GetNextAlias()
	  dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasD14,.F.,.T.)
	  If (cAliasD14)->(Eof())
		 WMSVTAviso(WMSV09520,WmsFmtMsg(STR0052,{{"[VAR01]",cIdUnit},{"[VAR02]",oOrdServ:oOrdEndOri:GetArmazem()},{"[VAR03]",oOrdServ:oOrdEndOri:GetEnder()}})) // "O unitizador [VAR01] não pertence ao armazém/endereço [VAR02]/[VAR03]."
		 cIdUnit := PadR("",TamSx3("D14_IDUNIT")[1])
		 lRet    := .F.
		 VTKeyBoard(Chr(20))
	  Else
		 oOrdServ:SetIdUnit(cIdUnit)
	  EndIf
	  (cAliasD14)->(DbCloseArea())
RestArea(aAreaAnt)
Return lRet

//-----------------------------------------------
/*/{Protheus.doc} ListUnitiz
Lista os unitizadores disponíveis no endereço para seleção
@author  Guilherme A. Metzger
@since   31/05/2017
@version 1.0
/*/
//-----------------------------------------------
Static Function ListUnitiz(cArmazem,cEndereco)
Local aTelaAnt  := VTSave(00,00,VTMaxRow(),VTMaxCol())
Local aAreaAnt  := GetArea()
Local cQuery    := ""
Local cAliasD14 := ""
Local aCab      := {STR0049} // "Unitizador"
Local aSize     := {VTMaxCol()}
Local aUnitiz   := {}
Local nItem     := 1
Local lRet      := .T.
	  // Busca todos os unitizadores contidos no endereço
	  cQuery := " SELECT DISTINCT(D14_IDUNIT)"
	  cQuery +=   " FROM "+RetSqlName("D14")
	  cQuery +=  " WHERE D14_FILIAL = '"+xFilial("D14")+"'"
	  cQuery +=    " AND D14_LOCAL  = '"+cArmazem+"'"
	  cQuery +=    " AND D14_ENDER  = '"+cEndereco+"'"
	  cQuery +=    " AND (D14_QTDEST - (D14_QTDSPR + D14_QTDEMP + D14_QTDBLQ)) > 0"
	  cQuery +=    " AND D_E_L_E_T_ = ' '"
	  cQuery := ChangeQuery(cQuery)
	  cAliasD14  := GetNextAlias()
	  dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasD14,.F.,.T.)
	  If !(cAliasD14)->(Eof())
		 (cAliasD14)->(DbEval({||Aadd(aUnitiz,{(cAliasD14)->D14_IDUNIT})}))
	  EndIf
	  (cAliasD14)->(DbCloseArea())
	  // Se conseguir encontrar unitizadores disponíveis no endereço
	  If Len(aUnitiz) > 0
		 VTClear()
		 WMSVTRodPe(, .F.)
		 // Apresenta os dados para seleção
		 nItem := VTaBrowse(00,00,Min(VTMaxRow()-1,Len(aUnitiz)+1),VTMaxCol(),aCab,aUnitiz,aSize)
		 // Tratamento da tecla Esc
		 If VTLastKey() == 27
	 		lRet := .F.
		 EndIf
	  Else
		 WMSVTAviso(WMSV09516,STR0053) // "O saldo dos unitizadores contidos neste endereço já estão comprometidos por outras movimentações!"
		 lRet := .F.
	  EndIf
	  If lRet
		 oOrdServ:SetIdUnit(aUnitiz[nItem][1])
	  EndIf
	  VTRestore(00,00,VTMaxRow(),VTMaxCol(),aTelaAnt)
      RestArea(aAreaAnt)
Return lRet

//-----------------------------------------------
/*/{Protheus.doc} GetUniDes
Solicita as informações do unitizador destino da transferência
@author  Guilherme A. Metzger
@since   17/05/2017
@version 1.0
/*/
//-----------------------------------------------
Static Function GetUniDes(cArmazem,cEndereco)
Local cTipUni  := PadR("",TamSx3("D14_CODUNI")[1])
Local cIdUnit  := PadR("",TamSx3("D14_IDUNIT")[1])
Local oTipUnit := WMSDTCUnitizadorArmazenagem():New()
	  VTClearBuffer()
	  oTipUnit:FindPadrao()
	  cTipUni := oTipUnit:GetTipUni()
	  WMSVTCabec(STR0001,.F.,.F.,.T.) // Transferência
	  // Solicita informações do unitizador destino
	  @ 01,00 VTSay PadR(STR0049,VTMaxCol()) // Unitizador
	  @ 02,00 VTGet cIdUnit Pict "@!" Valid VldUniDes(cArmazem,cEndereco,@cTipUni,@cIdUnit)
	  @ 03,00 VTSay PadR(STR0054,VTMaxCol()) // Tipo Unitiz.
	  @ 04,00 VTGet cTipUni Pict "@!" Valid VldTipUni(@cTipUni) F3 "D0T"
	  VTRead()
	  //S Valida se foi pressionado Esc
	  If VTLastKey() == 27
		 Return .F.
	  EndIf
Return .T.

//-----------------------------------------------
/*/{Protheus.doc} VldTipUni
Valida o tipo do unitizador informado end. destino
@author  Guilherme A. Metzger
@since   15/05/2017
@version 1.0
/*/
//-----------------------------------------------
Static Function VldTipUni(cTipUni)
Local lRet := .T.
	  If Empty(cTipUni)
		 Return .F.
	  EndIf
	  D0T->(DbSetOrder(1))
	  If !(lRet := D0T->(DbSeek(xFilial("D0T")+cTipUni)))
		 WMSVTAviso(WMSV09526,STR0069) // Tipo de unitizador inválido.
		 VTKeyBoard(Chr(20))
	  EndIf
	  If lRet
		 oOrdServ:SetTipUni(cTipUni)
	  EndIf
Return lRet

//-----------------------------------------------
/*/{Protheus.doc} VldUniDes
Valida o unitizador informado end. destino
@author  Guilherme A. Metzger
@since   12/05/2017
@version 1.0
/*/
//-----------------------------------------------
Static Function VldUniDes(cArmazem,cEndereco,cTipUni,cIdUnit)
Local aAreaAnt    := GetArea()
Local lRet        := .T.
Local cQuery      := ""
Local cAliasQry   := ""
Local cAliasD14   := ""
Local cTipUniD14  := ""
Local oMntUniItem := WMSDTCMontagemUnitizadorItens():New()
Local oTipUnit    := WMSDTCUnitizadorArmazenagem():New()
	If Empty(cIdUnit)
		Return .F.
	EndIf
	// Valida se o unitizador possui caractere especial
	If !WmsVlStr(cIdUnit)
		Return .F.
	EndIf
	// Valida o tamanho do código digitado
	If Len(AllTrim(cIdUnit)) != TamSx3("D0R_IDUNIT")[1]
		WMSVTAviso(WMSV09534,STR0051) // "Tamanho do código do unitizador inválido!"
		Return .F.
	EndIf
	// Valida se existe etiqueta do unitizador
	oMntUniItem:SetIdUnit(cIdUnit)
	If !oMntUniItem:VldIdUnit(4)
		// Valida a existencia do código do unitizador
		WMSVTAviso(WMSV09501,oMntUniItem:GetErro())
		Return .F.
	EndIf
	
	// Carrega informações do tipo do unitizador
	oTipUnit:SetTipUni(cTipUni)
	oTipUnit:LoadData()
	If!oTipUnit:CanUniMis() .And. oMntUniItem:oUnitiz:IsMultPrd(oOrdServ:oProdLote:GetProduto(),,.T.)
		WMSVTAviso(WMSV09538,WmsFmtMsg(STR0070,{{"[VAR01]",oTipUnit:GetTipUni()}})) //Tipo de unitizador [VAR01] não permite montagem de unitizador misto.
		Return .F.
	EndIf
	// Verifica se o unitizador já existe em algum endereço
	cQuery := "SELECT CASE WHEN (D14_LOCAL = '"+oOrdServ:oOrdEndOri:GetArmazem()+"' AND D14_ENDER = '"+oOrdServ:oOrdEndOri:GetEnder()+"') THEN 1"
	cQuery +=            " WHEN (D14_LOCAL = '"+oOrdServ:oOrdEndDes:GetArmazem()+"' AND D14_ENDER = '"+oOrdServ:oOrdEndDes:GetEnder()+"') THEN 2"
	cQuery +=            " ELSE 3"
	cQuery +=       " END END_UNITIZ,"
	cQuery +=       " D14_LOCAL,"
	cQuery +=       " D14_ENDER,"
	cQuery +=       " D14_CODUNI"
	cQuery +=  " FROM " + RetSqlName("D14")
	cQuery += " WHERE D14_FILIAL = '"+xFilial("D14")+"'"
	cQuery +=   " AND D14_IDUNIT = '"+cIdUnit+"'"
	cQuery +=   " AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
	// O unitizador não pode possuir estoque em dois endereços diferentes ao mesmo tempo
	If (cAliasQry)->(!Eof())
		// Guarda o tipo do unitizador, para que o usuário não precise informar posteriormente
		cTipUniD14 := (cAliasQry)->D14_CODUNI
		Do Case
			// Se estiver na origem, deve validar se existe mais algum produto no unitizador
			Case (cAliasQry)->END_UNITIZ == 1
				// Pode ser que o endereço comporte mais de um unitizador
				If oOrdServ:GetIdUnit() == cIdUnit
					cQuery := "SELECT CASE WHEN (D14_PRODUT <> '"+oOrdServ:oProdLote:GetProduto()+"'"
					cQuery +=              " OR  D14_LOTECT <> '"+oOrdServ:oProdLote:GetLoteCtl()+"'"
					cQuery +=              " OR  D14_NUMLOT <> '"+oOrdServ:oProdLote:GetNumLote()+"')"
					cQuery +=            " THEN 1"
					cQuery +=            " ELSE 0"
					cQuery +=        " END PRD_OUTROS,"
					cQuery +=        " (D14_QTDEST+D14_QTDEPR) D14_QTDEST"
					cQuery += " FROM " + RetSqlName("D14")
					cQuery += " WHERE D14_FILIAL = '"+xFilial("D14")+"'"
					cQuery +=   " AND D14_IDUNIT = '"+cIdUnit+"'"
					cQuery +=   " AND (D14_QTDEST+D14_QTDEPR) > 0"
					cQuery +=   " AND D_E_L_E_T_ = ' '"
					cQuery += " ORDER BY PRD_OUTROS DESC"
					cQuery := ChangeQuery(cQuery)
					cAliasD14 := GetNextAlias()
					dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasD14,.F.,.T.)
					If !(cAliasD14)->(Eof())
						If (cAliasD14)->PRD_OUTROS == 1
							WMSVTAviso(WMSV09535,STR0055) // "O unitizador possui outros produtos no endereço origem! Informe um novo ou movimente este unitizador por completo."
							lRet := .F.
						Else
							If QtdComp(oOrdServ:GetQuant()) < QtdComp((cAliasD14)->D14_QTDEST)
								WMSVTAviso(WMSV09536,STR0067) // "O unitizador possui saldo restante do produto no endereço origem! Informe um novo ou movimente o saldo total deste unitizador."
								lRet := .F.
							EndIf
						EndIf
					EndIf
					(cAliasD14)->(DbCloseArea())
				Else
					WMSVTAviso(WMSV09537,STR0068) // "Este unitizador está armazenado no endereço origem, porém é diferente do informado como origem da movimentação!"
					lRet := .F.
				EndIf
			// Se estiver no destino, deve validar se o unitizador pode receber o produto/lote/quantidade
			Case (cAliasQry)->END_UNITIZ == 2
				// Seta as informações da sequência de abastecimento
				oTransf:oMovSeqAbt:SetArmazem(oOrdServ:oOrdEndDes:GetArmazem())
				oTransf:oMovSeqAbt:SetProduto(oOrdServ:oProdLote:GetProduto())
				oTransf:oMovSeqAbt:SetEstFis(oOrdServ:oOrdEndDes:GetEstFis())
				If oTransf:oMovSeqAbt:LoadData(2)
					// Seta o unitizador destino
					oTransf:SetUniDes(cIdUnit)
					oTransf:SetTipUni(cTipUniD14)
					// Verifica se o unitizador pode receber o produto
					If !oTransf:CanUnitPar(.F.)
						WMSVTAviso(WMSV09504,STR0064 + CRLF + oTransf:GetErro()) // O endereço não pode receber o saldo do movimento. Motivo:
						lRet := .F.
					EndIf
				Else
					WMSVTAviso(WMSV09540,oTransf:oMovSeqAbt:GetErro())
					lRet := .F.
				EndIf
			// Se o unitizador está contido em algum endereço diferente da origem e destino
			Case (cAliasQry)->END_UNITIZ == 3
				WMSVTAviso(WMSV09518,WmsFmtMsg(STR0061,{{"[VAR01]",AllTrim((cAliasQry)->D14_LOCAL)},{"[VAR02]",AllTrim((cAliasQry)->D14_ENDER)}})) // "Este unitizador já encontra-se endereçado no armazém/endereço [VAR01]/[VAR02]."
				lRet := .F.
		EndCase
	EndIf
	(cAliasQry)->(dbCloseArea())
	If lRet
		If !Empty(cTipUniD14)
			cTipUni := cTipUniD14
			VTKeyBoard(Chr(13))
		EndIf
		oOrdServ:SetTipUni(cTipUni)
		oOrdServ:SetUniDes(cIdUnit)
	Else
		cIdUnit := PadR("",TamSx3("D14_IDUNIT")[1])
		VTKeyBoard(Chr(20))
	EndIf
	oMntUniItem:Destroy()
	RestArea(aAreaAnt)
Return lRet

/*--------------------------------------------------------------------------------
---Escape
---Pergunta ao usuário se deseja encerrar a transferência
---felipe.m - 01/04/2015
---lAbandona, ${boolean}, (Parâmetro por referência para encerrar a transferência)
---------------------------------------------------------------------------------*/
Static Function Escape(lAbandona)
Local nAviso := WMSVTAviso(STR0001,STR0015,{STR0016,STR0017}) // Tranferência","Deseja encerrar a transferencia?",{"Sim","Não"}
	  If nAviso == 1
		 lAbandona := .T.
	  ElseIf nAviso == 2
		 lAbandona := .F.
	  EndIf
Return lAbandona

Static oMovimento := Nil
/*--------------------------------------------------------------------------------
---Transfere
---Realiza a transferência com base nos dados informados.
---felipe.m - 02/04/2015
---------------------------------------------------------------------------------*/
Static Function Transfere()
Local lRet       := .T.
Local oEtiqUnit  := Nil
Local lMovUnit   := .F.
Local nI         := 0
Local dDVldSB8	 := dDataBase
Local dDFabSB8	 := dDataBase
Local cLotForn	 := ''
Local cNomFabr	 := ''
Local cPaisOri	 := ''
Local cXCFABRI	 := ''
Local cXLFABRI	 := ''
Local cCliFor    := ''
Local cLoja      := ''
Local cXDProd    := ''
Local cDocto     := GetSX8Num("DCF", "DCF_DOCTO"); ConfirmSx8()


	oMovimento := WMSBCCMovimentoServico():New()
	// Cria tabela temporária
	WMSCTPRGCV()
	VTMsg(STR0031) // Processando...
	Begin Transaction
		// Atribui usado para a etiqueta
		If !Empty(oOrdServ:GetUniDes())
			oEtiqUnit := WMSDTCEtiquetaUnitizador():New()
			oEtiqUnit:SetIdUnit(oOrdServ:GetUniDes())
			If oEtiqUnit:LoadData()
				If !oEtiqUnit:GetIsUsed()
					oEtiqUnit:SetTipUni(oOrdServ:GetTipUni())
					oEtiqUnit:SetUsado("1")
					oEtiqUnit:UpdateD0Y()
				EndIf
			EndIf
			oEtiqUnit:Destroy()
		EndIf
		// Atribui quantidade
		oOrdServ:SetOrigem("DCF")
		oOrdServ:SetDocto(cDocto)

		If !(oOrdServ:oOrdEndOri:GetArmazem() == oOrdServ:oOrdEndDes:GetArmazem())
			oOrdServ:SetOrigem("DH1")
			// Gera a DH1 com base nas informações do objeto e incrementa B2_RESERVA
			If !oOrdServ:IsMovUnit()
				oOrdServ:oProdLote:SetArmazem(oOrdServ:oOrdEndOri:GetArmazem())
				oOrdServ:oProdLote:LoadData()
				lRet := WmsGeraDH1("WMSV095")
			Else
				// Criação do serviço com origem DH1 quando o armazém é diferente para cada produto do unitizador
				lMovUnit := .T.
				cQuery := "SELECT D14.D14_LOCAL,"
				cQuery +=       " D14.D14_PRODUT,"
				cQuery +=       " D14.D14_LOTECT,"
				cQuery +=       " D14.D14_NUMLOT,"
				cQuery +=       " D14.D14_DTVALD,"
				cQuery +=       " D14.D14_NUMSER,"
				cQuery +=       " D14.D14_QTDEST,"
				cQuery +=       " D14.D14_QTDES2"
				cQuery +=  " FROM "+RetSqlName("D14")+" D14"
				cQuery += " WHERE D14.D14_FILIAL = '"+xFilial("D14")+"'"
				cQuery +=   " AND D14.D14_IDUNIT = '"+oOrdServ:GetIdUnit()+"'"
				cQuery +=   " AND D14.D_E_L_E_T_ = ' '"
				cAliasQry := GetNextAlias()
				dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
				Do While lRet .And. (cAliasQry)->(!Eof())
					// Seta as informações do produto do unitizador
					oOrdServ:oProdLote:SetArmazem((cAliasQry)->D14_LOCAL)
					oOrdServ:oProdLote:SetProduto((cAliasQry)->D14_PRODUT)
					oOrdServ:oProdLote:SetPrdOri((cAliasQry)->D14_PRODUT)
					oOrdServ:oProdLote:SetLoteCtl((cAliasQry)->D14_LOTECT)
					oOrdServ:oProdLote:SetNumLote((cAliasQry)->D14_NUMLOT)
					oOrdServ:oProdLote:SetDtValid((cAliasQry)->D14_DTVALD)
					
					oOrdServ:oProdLote:SetNumSer((cAliasQry)->D14_NUMSER)
					oOrdServ:oProdLote:LoadData()
					oOrdServ:SetQuant((cAliasQry)->D14_QTDEST)
					
					// Gera a DH1 com base nas informações do objeto e incrementa B2_RESERVA
					If (lRet := WmsGeraDH1("WMSV095"))
						// Atribui os valores e cria a ordem de serviço por produto
						lRet := GeraOrdSer()
					EndIf

					(cAliasQry)->(dbSkip())
				EndDo
				(cAliasQry)->(dbCloseArea())
			EndIf
		EndIf

		// Atribui os valores e cria a ordem de serviço por produto
		If lRet .And. !lMovUnit
			lRet := GeraOrdSer()
		EndIf

		If !lRet
			Disarmtransaction()
		Else
			//RODOLFO - Atualização de campos customizados da SB8
			If oOrdServ:oOrdEndOri:GetArmazem() <> oOrdServ:oOrdEndDes:GetArmazem()
				SB8->(DbSetOrder(3))
				If SB8->(DbSeek(xFilial('SB8') +  oOrdServ:oProdLote:GetProduto() + oOrdServ:oOrdEndOri:GetArmazem() + oOrdServ:oProdLote:GetLoteCtl()))
					dDVldSB8 := SB8->B8_DTVALID
					dDFabSB8 := SB8->B8_DFABRIC
					cLotForn := SB8->B8_LOTEFOR
					cNomFabr := SB8->B8_NFABRIC
					cPaisOri := SB8->B8_XPAISOR
					cXCFABRI := SB8->B8_XCFABRI
					cXLFABRI := SB8->B8_XLFABRI
					cCliFor  := SB8->B8_CLIFOR
					cLoja    := SB8->B8_LOJA
					cXDProd  := SB8->B8_XDPROD
					If SB8->(DbSeek(xFilial('SB8') + oOrdServ:oProdLote:GetProduto() + oOrdServ:oOrdEndDes:GetArmazem() + oOrdServ:oProdLote:GetLoteCtl()))
						Reclock('SB8',.F.)
						Replace SB8->B8_DTVALID With dDVldSB8
						Replace SB8->B8_DFABRIC With dDFabSB8
						Replace SB8->B8_NFABRIC With cNomFabr
						Replace SB8->B8_LOTEFOR With cLotForn 
						Replace SB8->B8_XPAISOR With cPaisOri
						Replace SB8->B8_XCFABRI With cXCFABRI
						Replace SB8->B8_XLFABRI With cXLFABRI	
						Replace SB8->B8_CLIFOR  With cCliFor
						Replace SB8->B8_LOJA    With cLoja
						Replace SB8->B8_XDPROD  With cXDProd   									
						Msunlock()
					EndIf
				EndIf
			EndIf
			//RODOLFO - Fim do ajuste		
		EndIf
	End Transaction
	WMSDTPRGCV()
	oMovimento:Destroy()
Return lRet
//-------------------------------------------------------------
Static Function GeraOrdSer()
//-------------------------------------------------------------
Local lRet       := .T.
Local cAliasD12  := Nil
Local cQuery     := ""
Local nI         := 0
	oOrdServ:ForceDtHr(.F.)
	If !oOrdServ:CreateDCF()
		WMSVTAviso(WMSV09539,oOrdServ:GetErro())
		lRet := .F.
	Else
		// Adiciona a ordem de serviço criada para ser executada automaticamente
		If oOrdServ:oServico:GetTpExec() != "2"
			AAdd(oOrdServ:aLibDCF,oOrdServ:GetIdDCF())
		EndIf
	EndIf
	// Efetua a execução automática quando serviço configurado 
	If lRet
		lRet := WmsExeServ(.F.,.T.)
	EndIf
	If lRet
		cQuery := "SELECT D12.R_E_C_N_O_ RECNOD12"
		cQuery +=  " FROM "+RetSqlName("D12")+" D12"
		cQuery += " WHERE D12.D12_FILIAL = '"+xFilial("D12")+"'"
		cQuery +=   " AND D12.D12_IDDCF = '"+oOrdServ:GetIdDCF()+"'"
		cQuery +=   " AND D12.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasD12 := GetNextAlias()
		dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasD12,.F.,.T.)
		Do While lRet .And. (cAliasD12)->(!Eof())
			oMovimento:GoToD12((cAliasD12)->RECNOD12)
			// Finaliza movimento
			oMovimento:SetQtdLid(oMovimento:nQtdMovto)
			oMovimento:dDtGeracao := oOrdServ:GetData()
			oMovimento:cHrGeracao := oOrdServ:GetHora()
			oMovimento:dDtInicio  := oOrdServ:GetData()
			oMovimento:cHrInicio  := oOrdServ:GetHora()
			// Atualiza o D12 para finalizado
			oMovimento:SetStatus("1")
			oMovimento:SetDataFim(dDataBase)
			oMovimento:SetHoraFim(Time())
			oMovimento:SetRecHum(__cUserID)
			If oMovimento:GetAtuEst()== "1"
				lRet := oMovimento:RecEnter()
			EndIf
			If lRet
				oMovimento:UpdateD12()
			EndIf
			(cAliasD12)->(dbSkip())
		EndDo
		(cAliasD12)->(dbCloseArea())
		If !lRet
			WMSVTAviso(WMSV09502,oMovimento:GetErro())
		EndIf
	EndIf
Return lRet
/*--------------------------------------------------------------------------------
---VldArmOri
---Validação do armazém origem informado.
---Alexsander.Correa - 01/04/2015
---cArmazem, character, (Armazém informado)
---------------------------------------------------------------------------------*/
Static Function VldArmOri(cArmazem)
Local lRet := .T.
	If Empty(cArmazem)
		Return .F.
	EndIf
	If Empty(Posicione("NNR",1,xFilial("NNR")+cArmazem,"NNR_CODIGO"))
		WMSVTAviso(WMSV09505,STR0010) // Armazem invalido!
		VTKeyBoard(chr(20))
		lRet := .F.
	EndIf
	If lRet
		// Atribui armazem endereço origem
		oOrdServ:oOrdEndOri:SetArmazem(cArmazem)
	EndIf
Return lRet

/*--------------------------------------------------------------------------------
---VldEndOri
---Validação do endereço origem informado.
---Alexsander.Correa - 01/04/2015
---cEndereco, character, (Endereço informado)
---alteração: 04/10/2019 - quando ler o codigo nivel#12345 trazer o codigo correto
------------- 010101A
---------------------------------------------------------------------------------*/
Static Function VldEndOri(cEndereco)
Local lRet := .T.
	  If Empty(cEndereco)
		 Return .F.
	  EndIf
      //De Para - solicitado por Bruno - 02/10/2019
	  dbSelectArea("SBE")
	  dbOrderNickName("XID")
	  If dbSeek(xFilial("SBE")+cArmazem+cEndereco)
	     cEndereco := SBE->BE_LOCALIZ
	     lRet := .T.
	  Endif
	  oOrdServ:oOrdEndOri:SetEnder(cEndereco)
	  If !oOrdServ:oOrdEndOri:LoadData()
		 WMSVTAviso(WMSV09503,STR0013) // Endereço invalido!
		 VTKeyBoard(chr(20))
		 lRet := .F.
      Else
		 If oOrdServ:oOrdEndOri:GetStatus() == "3"
			WMSVTAviso(WMSV09523,WmsFmtMsg(STR0032,{{"[VAR01]",oOrdServ:oOrdEndOri:GetEnder()}})) // Endereco origem [VAR01] esta bloqueado! (BE_STATUS)
			VTKeyBoard(chr(20))
			lRet := .F.
		 ElseIf oOrdServ:oOrdEndOri:GetStatus() == "5"
			    WMSVTAviso(WMSV09524,WmsFmtMsg(STR0033,{{"[VAR01]",oOrdServ:oOrdEndOri:GetEnder()}})) // Endereco origem [VAR01] esta com bloqueio de saida! (BE_STATUS)
			    VTKeyBoard(chr(20))
			    lRet := .F.
		 ElseIf oOrdServ:oOrdEndOri:GetStatus() == "6"
			    WMSVTAviso(WMSV09525,WmsFmtMsg(STR0034,{{"[VAR01]",oOrdServ:oOrdEndOri:GetEnder()}})) // Endereco origem [VAR01] esta com bloqueio de inventario! (BE_STATUS)
			    VTKeyBoard(chr(20))
			    lRet := .F.
		 EndIf
      EndIf
Return lRet

//-----------------------------------------------
/*/{Protheus.doc} ValidPrdLot
Validações referentes ao código do produto
@author  Guilherme A. Metzger
@since   10/05/2017
@version 1.0
@obs     Caso seja informado o código do unitizador,
         subentende-se que é uma transferência de
         unitizador completo
/*/
//-----------------------------------------------
Static Function ValidPrdLot(cProduto,cLoteCtl,cNumLote,nQuant,cCodBar)
Local lRet    := .T.
Local cCodBarBkp	:= ''

	If Empty(cCodBar)
  	   Return .F.
	EndIf
	// separa a variável cCodbar e atribui o código do produto na variável cProduto
	cProduto 	:= QbrString(1,cCodBar,TamSX3('D14_PRDORI')[1])
	cCodBarBkp 	:= cCodBar
	cCodBar	 	:= cProduto

	// Realiza as validações genéricas referentes ao código do produto
	lRet := WMSValProd(Nil,@cProduto,@cLoteCtl,@cNumLote,@nQuant,@cCodBar)

	If lRet 
		cLoteCtl := Padr(Alltrim(QbrString(2,cCodBarBkp)),TamSx3("D12_LOTECT")[1])
		//nQuant := Val(QbrString(3,cCodBarBkp))
	EndIf	
Return lRet

/*--------------------------------------------------------------------------------
---ValidLote
---Validação do lote do produto informado.
---Alexsander.Correa - 01/04/2015
---cLoteCtl, character, (Lote informado)
---------------------------------------------------------------------------------*/
Static Function ValidLote(cLoteCtl)
Local lRet := .T.
	If Empty(cLoteCtl)
		Return .F.
	EndIf
	If oOrdServ:oProdLote:GetLoteCtl() != cLoteCtl
		WMSVTAviso(WMSV09514,STR0026) // Lote inválido!
		VTKeyBoard(chr(20))
		lRet := .F.
	EndIf
Return lRet

/*--------------------------------------------------------------------------------
---ValSubLote
---Validação do sub-lote do lote do produto informado.
---Alexsander.Correa - 01/04/2015
---cNumLote, character, (Sub-lote informado)
---------------------------------------------------------------------------------*/
Static Function ValSubLote(cNumLote)
Local lRet := .T.
	If Empty(cNumLote)
		Return .F.
	EndIf
	If oOrdServ:oProdLote:GetNumLote() != cNumLote
		WMSVTAviso(WMSV09515,STR0027) // SubLote inválido
		VTKeyBoard(chr(20))
		lRet := .F.
	EndIf
Return lRet

/*--------------------------------------------------------------------------------
---VldArmDes
---Validação do armazém destino informado.
---Alexsander.Correa - 01/04/2015
---cArmazem, character, (Armazém informado)
---------------------------------------------------------------------------------*/
Static Function VldArmDes(cArmazem)
Local lRet := .T.
	If Empty(cArmazem)
		Return .F.
	EndIf
	If Empty(Posicione("NNR",1,xFilial("NNR")+cArmazem,"NNR_CODIGO"))
		WMSVTAviso(WMSV09517,STR0010) // Armazem invalido!
		lRet := .F.
	EndIf
	If !lRet
		VTKeyBoard(chr(20))
		@ 04,00 VTSay PadR("",VTMaxCol())
	EndIf
	oOrdServ:oOrdEndDes:SetArmazem(cArmazem)
Return lRet

/*--------------------------------------------------------------------------------
---VldEndDes
---Validação do endereço destino informado.
---Alexsander.Correa - 01/04/2015
---cEndereco, character, (Endereço informado)
---alteração: 04/10/2019 - quando ler o codigo nivel#12345 trazer o codigo correto
------------- 010101A
---------------------------------------------------------------------------------*/
Static Function VldEndDes(cEnderDes,cArmDes,lConfirm)
Local lRet     := .T.
Local lUnitOri := .F.
Local lUnitDes := .F.
Local cQuery   := ""
Local cAliasQry:= ""
	// Se o usuário pressionou Enter, disponibiliza lista de endereços para seleção
	If VTLastKey() == 13 .And. Empty(cEnderDes)
		ListEnder(cArmDes,@cEnderDes)
		lConfirm := .T. //Quando o WMS sugere o endereço, é necessário que o usuário confirme o endereço escolhido
	Else
		lConfirm := .F. //Quando usuário informa manualmente o endereço é desnecessário perdir confirmação do endereço escolhido
	EndIf
	//De Para - solicitado por Bruno - 02/10/2019
	dbSelectArea("SBE")
	dbOrderNickName("XID")
	If dbSeek(xFilial("SBE")+cArmDes+cEnderDes)
	   cEnderDes := SBE->BE_LOCALIZ
	   lRet := .T.
	Endif
	If lRet
		// Dados Endereço Destino
		oOrdServ:oOrdEndDes:SetArmazem(cArmDes)
		oOrdServ:oOrdEndDes:SetEnder(cEnderDes)
		// Atribui endereço destino
		oTransf:oMovEndDes := oOrdServ:oOrdEndDes
		oTransf:oMovEndOri := oOrdServ:oOrdEndOri
		oTransf:SetIdUnit(oOrdServ:GetIdUnit())
		// Caso o armazém destino não é unitizado, limpa o unitizador destino do objeto
		If oOrdServ:oOrdEndDes:IsArmzUnit()
			oTransf:SetUniDes(oOrdServ:GetUniDes())
			oTransf:SetTipUni(oOrdServ:GetTipUni())
		Else
			oTransf:SetUniDes("")
			oTransf:SetTipUni("")
			oOrdServ:SetUniDes("")
			oOrdServ:SetTipUni("")
		EndIf

		lUnitOri := WmsArmUnit(oTransf:oMovEndOri:GetArmazem())
		lUnitDes := WmsArmUnit(oTransf:oMovEndDes:GetArmazem())

		If oOrdServ:oOrdEndOri:GetArmazem() == oOrdServ:oOrdEndDes:GetArmazem() .And.;
		   oOrdServ:oOrdEndOri:GetEnder() == oOrdServ:oOrdEndDes:GetEnder()
			WMSVTAviso(WMSV09522,WmsFmtMsg(STR0030,{{"[VAR01]",oOrdServ:oOrdEndDes:GetEnder()}})) // Endereço destino [VAR01] não pode ser igual ao endereço origem!
			lRet := .F.
		EndIf

		If lRet
			If oOrdServ:IsMovUnit() .And. !(oTransf:oMovEndOri:GetArmazem() == oTransf:oMovEndDes:GetArmazem()) .And. lUnitOri .And. !lUnitDes
				cQuery := "SELECT D14.D14_LOCAL,"
				cQuery +=       " D14.D14_PRODUT,"
				cQuery +=       " D14.D14_PRDORI,"
				cQuery +=       " D14.D14_LOTECT,"
				cQuery +=       " D14.D14_NUMLOT,"
				cQuery +=       " D14.D14_DTVALD,"
				cQuery +=       " D14.D14_NUMSER,"
				cQuery +=       " D14.D14_QTDEST,"
				cQuery +=       " D14.D14_QTDES2"
				cQuery +=  " FROM "+RetSqlName("D14")+" D14"
				cQuery += " WHERE D14.D14_FILIAL = '"+xFilial("D14")+"'"
				cQuery +=   " AND D14.D14_IDUNIT = '"+oTransf:GetIdUnit()+"'"
				cQuery +=   " AND D14.D_E_L_E_T_ = ' '"
				cAliasQry := GetNextAlias()
				dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
				Do While lRet .And. (cAliasQry)->(!Eof())
					// Seta o Produto no movimento
					oTransf:oMovPrdLot:SetArmazem((cAliasQry)->D14_LOCAL)
					oTransf:oMovPrdLot:SetProduto((cAliasQry)->D14_PRODUT)
					oTransf:oMovPrdLot:SetPrdOri((cAliasQry)->D14_PRDORI)
					oTransf:oMovPrdLot:SetLoteCtl((cAliasQry)->D14_LOTECT)
					oTransf:oMovPrdLot:SetNumLote((cAliasQry)->D14_NUMLOT)
					oTransf:oMovPrdLot:SetDtValid((cAliasQry)->D14_DTVALD)
					oTransf:oMovPrdLot:SetNumSer((cAliasQry)->D14_NUMSER)
					oTransf:oMovPrdLot:LoadData()
					oTransf:SetQuant((cAliasQry)->D14_QTDEST)
					// Seta o Produto na ordem de serviço
					oOrdServ:oProdLote := oTransf:oMovPrdLot
					// Validação do produto
					lRet := VldEndPrd()

					(cAliasQry)->(dbSkip())
				EndDo
				(cAliasQry)->(dbCloseArea())
				// Limpa o objeto da ordem de serviço
				oOrdServ:oProdLote := WMSDTCProdutoLote():New()
			Else
				If !oOrdServ:IsMovUnit()
					// Seta o Produto no movimento
					oTransf:oMovPrdLot := oOrdServ:oProdLote
				EndIf
				oTransf:SetQuant(oOrdServ:GetQuant())
				// Validação do produto
				lRet := VldEndPrd()
			EndIf
		EndIf
	EndIf
	// Limpa o campo se houve erro
	If !lRet
		cEnderDes := PadR("",TamSx3("D14_ENDER")[1])
	Else
		@ 04,00 VTSay PadR(cEnderDes,VTMaxCol())
	EndIf
	VTKeyBoard(chr(20))
Return lRet
/*--------------------------------------------------------------------------------
---VldEndPrd
---Validação do endereço destino por produto.
---felipe.m - 19/07/2017
---------------------------------------------------------------------------------*/
Static Function VldEndPrd()
Local lRet := .T.
Local lConsCap := .T.

	If !oOrdServ:IsMovUnit() .And.;
		oOrdServ:oOrdEndOri:GetArmazem() != oOrdServ:oOrdEndDes:GetArmazem() .And.;
		oOrdServ:oProdLote:GetProduto()  != oOrdServ:oProdLote:GetPrdOri()
		WMSVTAviso(WMSV09530,WmsFmtMsg(STR0046,{{"[VAR01]",oOrdServ:oProdLote:GetProduto()},{"[VAR02]",oOrdServ:oProdLote:GetPrdOri()}})) //Transferência entre armazéns de produto [VAR01] e componente [VAR02] não permitida!
		lRet := .F.
	EndIf

	If lRet
		If (oOrdServ:IsMovUnit() .And. Empty(oOrdServ:GetUniDes())) .Or.;
			(oOrdServ:oOrdEndDes:IsArmzUnit() .And. oOrdServ:oOrdEndDes:GetTipoEst() != 2 .And. Empty(oOrdServ:GetUniDes()))
			lConsCap := .F.
		EndIf
		If !oTransf:ChkEndDes(.F.,lConsCap)
			WMSVTAviso(WMSV09513,oTransf:GetErro())
			lRet := .F.
		EndIf
	EndIf

Return lRet

//-----------------------------------------------
/*/{Protheus.doc} ListEnder
Responsável por sugerir o endereço destino da transferência

@author  amanda.vieira
@since   10/05/2016
@version 1.0
/*/
//-----------------------------------------------
Static Function ListEnder(cArmDes,cEnderDes)
Local aCab       := {STR0038,STR0039}
Local aSize      := {Len(aCab[1]), Len(aCab[2])}
Local aTelaAnt   := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local aEnderecos := {}
Local nItem      := 1
Local nSaldoCap  := 0
Local nAviso     := 1
Local cQuery     := ""
Local cAliasQry  := ""
Local cEndereco  := ""
Local aNorma     := {}

	While .T.
		cEnderDes := PadR("",TamSx3("D14_ENDER")[1])
		oOrdServ:oOrdEndDes:SetEnder(cEnderDes)
		If !oOrdServ:oOrdEndDes:IsArmzUnit()
			nAviso := WMSVTAviso(STR0036,STR0040,{STR0071,STR0041,STR0042}) // Endereços // Selecione a opção desejada:  // Automatico // Vazios // Parcialmente Cheios
			If VTLastKey() == 27
				VTRestore(00, 00, VTMaxRow()  , VTMaxCol(), aTelaAnt)
				@ 04,00 VTSay PadR(cEnderDes,VTMaxCol())
				Return
			EndIf
		Else
			// Armazém unitizado só vai trabalhar com a opção "Automático"
			nAviso := 1
		EndIf
		VTMsg(STR0045) // Processando...

		If nAviso == 1
			If FindEndDes() .And. !Empty(oTransf:oMovEndDes:GetEnder())
				cEnderDes := oTransf:oMovEndDes:GetEnder()
				If oOrdServ:oOrdEndDes:IsArmzUnit()
					WmsMessage(WmsFmtMsg(STR0072,{{"[VAR01]",AllTrim(cEnderDes)}}),STR0036) // "Transferência planejada para o endereço [VAR01]."
				EndIf
			EndIf
			VTRestore(00, 00, VTMaxRow()  , VTMaxCol(), aTelaAnt)
			@ 04,00 VTSay PadR(cEnderDes,VTMaxCol())
			Return
		ElseIf nAviso == 2
			//Busca endereços vazios
			cQuery := "SELECT SBE.BE_LOCAL,"
			cQuery +=       " SBE.BE_ESTFIS,"
			cQuery +=       " SBE.BE_LOCALIZ"
			cQuery +=  " FROM "+RetSqlName('SBE')+" SBE"
			cQuery += " INNER JOIN "+RetSqlName('DC3')+" DC3"
			cQuery +=    " ON DC3.DC3_FILIAL = '"+xFilial('DC3')+"'"
			cQuery +=   " AND DC3.DC3_LOCAL  = SBE.BE_LOCAL"
			cQuery +=   " AND DC3.DC3_CODPRO = '"+oOrdServ:oProdLote:GetProduto()+"'"
			cQuery +=   " AND DC3.DC3_EMBDES = '1'"
			cQuery +=   " AND DC3.D_E_L_E_T_ = ' '"
			cQuery += " WHERE SBE.BE_FILIAL  = '"+xFilial('SBE')+"'"
			cQuery +=   " AND SBE.BE_LOCAL   = '"+cArmDes+"'"
			cQuery +=   " AND SBE.BE_STATUS NOT IN ('3','4','6')"
			cQuery +=   " AND SBE.BE_CODZON  = '"+oOrdServ:oProdLote:GetCodZona()+"'"
			cQuery +=   " AND SBE.D_E_L_E_T_ = ' '"
			cQuery +=   " AND NOT EXISTS (SELECT 1"
			cQuery +=                     " FROM "+RetSqlName('D14')+" D14"
			cQuery +=                    " WHERE D14.D14_FILIAL = '"+xFilial('D14')+"'"
			cQuery +=                      " AND D14.D14_LOCAL  = BE_LOCAL"
			cQuery +=                      " AND D14.D14_ESTFIS = BE_ESTFIS"
			cQuery +=                      " AND D14.D14_ENDER  = BE_LOCALIZ"
			cQuery +=                      " AND D14.D_E_L_E_T_ = ' ')"
			cQuery += " UNION ALL "
			cQuery += "SELECT SBE.BE_LOCAL,"
			cQuery +=       " SBE.BE_ESTFIS,"
			cQuery +=       " SBE.BE_LOCALIZ"
			cQuery +=  " FROM "+RetSqlName('SBE')+" SBE"
			cQuery += " INNER JOIN "+RetSqlName('DC3')+" DC3"
			cQuery +=    " ON DC3.DC3_FILIAL = '"+xFilial('DC3')+"'"
			cQuery +=   " AND DC3.DC3_LOCAL  = SBE.BE_LOCAL"
			cQuery +=   " AND DC3.DC3_CODPRO = '"+oOrdServ:oProdLote:GetProduto()+"'"
			cQuery +=   " AND DC3.DC3_EMBDES = '1'"
			cQuery +=   " AND DC3.D_E_L_E_T_ = ' '"
			cQuery += " INNER JOIN "+RetSqlName("DCH")+" DCH"
			cQuery +=    " ON DCH.DCH_FILIAL = '"+xFilial("DCH")+"'"
			cQuery +=   " AND DCH.DCH_CODPRO = '"+oOrdServ:oProdLote:GetProduto()+"'"
			cQuery +=   " AND DCH.DCH_CODZON = SBE.BE_CODZON"
			cQuery +=   " AND DCH.D_E_L_E_T_ = ' '"
			cQuery += " WHERE SBE.BE_FILIAL  = '"+xFilial('SBE')+"'"
			cQuery +=   " AND SBE.BE_LOCAL   = '"+cArmDes+"'"
			cQuery +=   " AND SBE.BE_STATUS NOT IN ('3','4','6')"
			cQuery +=   " AND SBE.BE_CODZON <> '"+oOrdServ:oProdLote:GetCodZona()+"'"
			cQuery +=   " AND SBE.D_E_L_E_T_ = ' '"
			cQuery +=   " AND NOT EXISTS (SELECT 1"
			cQuery +=                     " FROM "+RetSqlName('D14')+" D14"
			cQuery +=                    " WHERE D14.D14_FILIAL = '"+xFilial('D14')+"'"
			cQuery +=                      " AND D14.D14_LOCAL  = BE_LOCAL"
			cQuery +=                      " AND D14.D14_ESTFIS = BE_ESTFIS"
			cQuery +=                      " AND D14.D14_ENDER  = BE_LOCALIZ"
			cQuery +=                      " AND D14.D_E_L_E_T_ = ' ')"
		ElseIf nAviso == 3
			//Busca endereços parcialmente cheios
			cQuery := " SELECT D14_LOCAL  BE_LOCAL,"
			cQuery +=        " D14_ESTFIS BE_ESTFIS,"
			cQuery +=        " D14_ENDER  BE_LOCALIZ,"
			cQuery +=        " D14_QTDEST,"
			cQuery +=        " D14_QTDEPR"
			cQuery +=   " FROM "+RetSqlName("D14")
			cQuery +=  " WHERE D14_FILIAL = '"+xFilial("D14")+"'"
			cQuery +=    " AND D14_LOCAL  = '"+cArmDes+"'"
			cQuery +=    " AND D14_PRODUT = '"+oOrdServ:oProdLote:GetProduto()+"'"
			cQuery +=    " AND (D14_QTDEST - (D14_QTDSPR + D14_QTDEMP + D14_QTDBLQ + D14_QTDPEM)) > 0"
			cQuery +=    " AND D_E_L_E_T_ = ' '"
		EndIf
		cAliasQry := GetNextAlias()
		dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)

		While (cAliasQry)->(!EoF())
			// Endereco
			cEndereco := (cAliasQry)->BE_LOCALIZ
			// Verifica norma por estrutura
			If (nPos := AScan(aNorma,{|x| x[1] == (cAliasQry)->BE_ESTFIS  })) == 0
				Aadd(aNorma,{(cAliasQry)->BE_ESTFIS,DLQtdNorma(oOrdServ:oProdLote:GetProduto(),(cAliasQry)->BE_LOCAL,(cAliasQry)->BE_ESTFIS,,.F.,cEndereco)})
				nSaldoCap := aNorma[Len(aNorma),2]
			Else
				nSaldoCap := aNorma[nPos,2]
			EndIf
			// Quando parcialmente  cheios desconta comprimetido
			If nAviso == 3
				nSaldoCap := nSaldoCap - ((cAliasQry)->D14_QTDEST + (cAliasQry)->D14_QTDEPR)
			EndIf
			// Verifica se a norma é maior que a quantidade
			If nSaldoCap >= oOrdServ:GetQuant()
				aAdd(aEnderecos, {cEndereco, cValToChar(nSaldoCap)})
			EndIf
			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(dbCloseArea())

		If VTLastKey() != 27
			If Len(aEnderecos) > 0
				VTClear()
				WMSVTRodPe(, .F.)
				nItem := VTaBrowse(00, 00, Min(VTMaxRow()-1,Len(aEnderecos)+1), VTMaxCol(), aCab, aEnderecos, aSize)
				If nItem > 0
					cEnderDes := aEnderecos[nItem][1]
				EndIf
			Else
				WMSVTAviso(WMSV09528,WmsFmtMsg(STR0043,{{"[VAR01]",cValToChar(oOrdServ:GetQuant())}}))
				Loop
			EndIf
		EndIf
		Exit
	EndDo
	VTRestore(00, 00, VTMaxRow()  , VTMaxCol(), aTelaAnt)
	@ 04,00 VTSay PadR(cEnderDes,VTMaxCol())
Return

//-----------------------------------------------
/*/{Protheus.doc} FindEndDes
Busca endereço destino de forma automática

@author  amanda.vieira
@since   10/05/2016
@version 1.0
/*/
//-----------------------------------------------
Static Function FindEndDes()
Local oFuncao    := Nil
Local cIdUnitGen := ""
Local aLogEnd    := {}
Local lRet       := .T.

	If oOrdServ:oOrdEndDes:IsArmzUnit()
		oFuncao := WMSBCCEnderecamentoUnitizado():New()
		oFuncao:SetOrdServ(oOrdServ)
		// Se for movimentação do unitizador completo
		If oOrdServ:IsMovUnit()
			oFuncao:SetLstUnit({{oOrdServ:GetIdUnit(),0}})
		Else
			// Gera um ID de unitizador genérico só para a busca funcionar
			cIdUnitGen := Replicate("Z",TamSX3("D0R_IDUNIT")[1])
			cTipUniGen := Posicione("D0Y",1,xFilial("D0Y"),"D0Y_TIPUNI")
			// Atribui dados genéricos ao objeto
			oFuncao:SetLstUnit({{cIdUnitGen,0}})
			oFuncao:SetTipUni(cTipUniGen)
			oFuncao:lTrfUnit := .T.
		EndIf
	Else
		// Transferir
		oFuncao := WMSBCCEnderecamento():New()
		oFuncao:oMovServic:SetServico(oOrdServ:oServico:GetServico())
		oFuncao:oMovServic:SetOrdem(oOrdServ:oServico:GetOrdem())
		oFuncao:oMovServic:LoadData()

		oFuncao:oMovPrdLot:SetArmazem(oOrdServ:oProdLote:GetArmazem())
		oFuncao:oMovPrdLot:SetPrdOri(oOrdServ:oProdLote:GetPrdOri())
		oFuncao:oMovPrdLot:SetProduto(oOrdServ:oProdLote:GetProduto())
		oFuncao:oMovPrdLot:SetLoteCtl(oOrdServ:oProdLote:GetLoteCtl())
		oFuncao:oMovPrdLot:SetNumLote(oOrdServ:oProdLote:GetNumLote())
		oFuncao:oMovPrdLot:SetNumSer(oOrdServ:oProdLote:GetNumSer())
		oFuncao:oMovPrdLot:LoadData()

		oFuncao:oMovEndOri:SetArmazem(oOrdServ:oOrdEndOri:GetArmazem())
		oFuncao:oMovEndOri:SetEnder(oOrdServ:oOrdEndOri:GetEnder())
		oFuncao:oMovEndOri:LoadData()
		oFuncao:oMovEndOri:ExceptEnd()

		oFuncao:oMovEndDes:SetArmazem(oOrdServ:oOrdEndDes:GetArmazem())
		oFuncao:oMovEndDes:SetEnder(oOrdServ:oOrdEndDes:GetEnder())
		oFuncao:oMovEndDes:LoadData()
	EndIf

	oFuncao:SetQuant(oOrdServ:GetQuant())
	oFuncao:SetLogEnd(aLogEnd)
	oFuncao:SetTrfCol(.T.)

	If !oFuncao:ExecFuncao()
		oTransf:oMovEndDes:SetEnder("")
		WMSVTAviso(WMSV09512,oFuncao:GetErro())
		lRet := .F.
	Else
		oTransf:oMovEndDes:SetEnder(oFuncao:oMovEndDes:GetEnder())
	EndIf

Return lRet

Static Function VldConfirm(cEnderDes,cEnderAux,cArmDes)
	//Verifica se houve troca de endereço
	If cEnderDes != cEnderAux
		nAviso := WMSVTAviso(STR0001,STR0044,{STR0016,STR0017}) // Tranferencia","Deseja trocar o endereço destino?",{"Sim","Não"}.
		If nAviso == 1 .And. VldEndDes(cEnderAux,cArmDes)
			@ 04,00 VTSay PadR(cEnderAux,VTMaxCol())
			Return .T.
		Else
			Return .F.
		EndIf
	Else
		// Seta novamente armazém e endereço destino, pois pode
		// ter passado pela função VldEndDes() com um endereço
		// inexistente, gerando problemas na geração da OS
		oOrdServ:oOrdEndDes:SetArmazem(cArmDes)
		oOrdServ:oOrdEndDes:SetEnder(cEnderDes)
	EndIf
Return .T.

//-----------------------------------------------
/*/{Protheus.doc} PrdSldEnd
Verifica o saldo do produto no endereço origem.
Caso exista mais do mesmo produto no endereço,
apresenta tela para seleção do unitizador/lote
que deve ser movimentado.
@author  Inovação WMS
@since   12/05/2017
@version 1.0
/*/
//-----------------------------------------------
Static Function PrdSldEnd(cArmazem,cEndereco,cPrdOri,cProduto,cLoteCtl,cNumLote,nQtdTot)
Local lRet      := .T.
Local aTelaAnt  := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local aItens    := {}
Local aItensAux := {}
Local aCab      := {}
Local aSize     := {}
Local cAliasD14 := GetNextAlias()
Local cQuery    := ""
Local nPos      := 1
Local nQtdDisp  := 0
Local lSldComp  := .F. // Indica que o saldo está comprometido
Local nI        := 1
	// Busca os saldos do produto/lote no endereço
	cQuery := " SELECT D14_PRDORI,"
	cQuery +=        " D14_PRODUT,"
	cQuery +=        " D14_LOTECT,"
	cQuery +=        " D14_NUMLOT,"
	cQuery +=        " D14_QTDEST,"
	cQuery +=        " D14_QTDSPR,"
	cQuery +=        " D14_QTDEMP,"
	cQuery +=        " D14_QTDBLQ,"
	cQuery +=        " D14_IDUNIT"
	cQuery +=   " FROM "+RetSqlName("D14")
	cQuery +=  " WHERE D14_FILIAL = '"+xFilial("D14")+"'"
	cQuery +=    " AND D14_LOCAL  = '"+cArmazem+"'"
	cQuery +=    " AND D14_ENDER  = '"+cEndereco+"'"
	If !Empty(oOrdServ:GetIdUnit())
		cQuery += " AND D14_IDUNIT = '"+oOrdServ:GetIdUnit()+"'"
	EndIf
	cQuery +=    " AND D14_PRODUT = '"+cProduto+"'"
	If !Empty(cLoteCtl)
		cQuery += " AND D14_LOTECT = '"+cLoteCtl+"'"
	EndIf
	If !Empty(cNumLote)
		cQuery += " AND D14_NUMLOT = '"+cNumLote+"'"
	EndIf
	cQuery +=    " AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasD14,.F.,.T.)
	While !(cAliasD14)->(Eof())
		nQtdDisp := (cAliasD14)->D14_QTDEST-((cAliasD14)->D14_QTDSPR+(cAliasD14)->D14_QTDEMP+(cAliasD14)->D14_QTDBLQ)
		If QtdComp(nQtdDisp) > 0
			Aadd(aItens,{;
			     nQtdDisp,;
			    (cAliasD14)->D14_IDUNIT,;
			    (cAliasD14)->D14_PRDORI,;
			    (cAliasD14)->D14_PRODUT,;
			    (cAliasD14)->D14_LOTECT,;
			    (cAliasD14)->D14_NUMLOT})
		Else
			lSldComp := .T.
		EndIf
		(cAliasD14)->(dbSkip())
	EndDo
	(cAliasD14)->(dbCloseArea())
	// Caso tenha encontrado mais do mesmo produto, apresente tela para seleção
	If Len(aItens) > 0
		// Guarda uma cópia do array para o caso da coluna do unitizador ser removida
		aItensAux := aClone(aItens)
		If Len(aItens) > 1
			// Monta o cabeçalho da tela para seleção do produto
			aCab := {RetTitle("D14_QTDEST"),;
						RetTitle("D14_IDUNIT"),;
						RetTitle("D14_PRDORI"),;
						RetTitle("D14_PRODUT"),;
						RetTitle("D14_LOTECT"),;
						RetTitle("D14_NUMLOT")}
			// Tamanho das colunas na tela para seleção do produto
			aSize := {9,;
						 TamSx3("D14_IDUNIT")[1],;
						 TamSx3("D14_PRDORI")[1],;
						 TamSx3("D14_PRDORI")[1],;
						 TamSx3("D14_LOTECT")[1],;
						 TamSx3("D14_NUMLOT")[1]}
			// Se não é armazém unitizado, remove a coluna do unitizador
			If !oOrdServ:oOrdEndOri:IsArmzUnit()
				aDel(aCab ,2)
				aDel(aSize,2)
				For nI := 1 To Len(aItens)
					aDel(aItens[nI],2)
				Next
			EndIf
			// Apresenta tela para seleção do produto
			WMSVTCabec("Produto Origem",.F.,.F.,.T.) // Produto Origem
			nPos := VTaBrowse(00, 00, Min(VTMaxRow()-1,Len(aItens)+1), VTMaxCol(), aCab, aItens, aSize)
		EndIf
		If VTLastKey() != 27
			// Atribui dados
			nQtdTot  := aItensAux[nPos][1]
			cIdUnit  := aItensAux[nPos][2]
			cPrdOri  := aItensAux[nPos][3]
			cLoteCtl := aItensAux[nPos][5]
			cNumLote := aItensAux[nPos][6]
			VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
		Else
			lRet := .F.
		EndIf
	Else
		If lSldComp
			WMSVTAviso(WMSV09531,WmsFmtMsg(STR0062,{{"[VAR01]",cProduto},{"[VAR02]",cEndereco}})) // "O produto [VAR01] está com todo o saldo comprometido no endereço [VAR02]."
		Else
			WMSVTAviso(WMSV09521,WmsFmtMsg(STR0063,{{"[VAR01]",cProduto},{"[VAR02]",cEndereco}})) // "Produto [VAR01] não encontrado no endereço [VAR02]."
		EndIf
		lRet := .F.
	EndIf
Return lRet

/*--------------------------------------------------------*/
//Funcao para quebrar o QRCODE lido
Static Function QbrString(nOpc,cString,nTam)

Local aDados := Separa(cString,"|")
Local cRet := {}
Default nTam := 0

If Len(aDados) > 0
	cRet := aDados[nOpc]
Endif

If nTam > 0
	cRet := Padr(cRet,nTam)
Endif

Return cRet
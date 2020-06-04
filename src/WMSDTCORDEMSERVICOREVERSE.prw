#INCLUDE "TOTVS.CH"
#INCLUDE "WMSDTCORDEMSERVICOREVERSE.CH"

//---------------------------------------------
/* {Protheus.doc} WMSCLS0033
Função para permitir que a classe seja visualizada
no inspetor de objetos
@author Inovação WMS
@since 16/12/2016
@version 1.0
*/
//---------------------------------------------
Function WMSCLS0033()
Return Nil
//-----------------------------------------------
/* {Protheus.doc} WMSDTCOrdemServicoReverse
Classe estorno da ordem de serviço
@author Inovação WMS
@since 16/12/2016
@version 1.0
*/
//-----------------------------------------------
CLASS WMSDTCOrdemServicoReverse FROM WMSDTCOrdemServico
	// Data
	DATA lEstSrvAut
	DATA cCodMntVol
	DATA cCodDisSep
	DATA cConfExped
	DATA aOrdOri
	DATA lCarteira
	DATA oMovimento
	DATA oRelacMov
	// Method
	METHOD New() CONSTRUCTOR
	METHOD CanReverse()
	METHOD SetEstSerA(lEstSrvAut)
	METHOD SetHasCart(lCarteira)
	METHOD ReverseDCF()
	METHOD RevExpedic()
	METHOD RevSldDist()
	METHOD RevEmpSB8()
	METHOD RevMovPrev()
	METHOD RevMovEst()
	METHOD RevGenDev(cSerTran)
	METHOD MakeEstSD3()
	METHOD EstMovSD3(cDocumento,cNumSeq)
	METHOD Destroy()
	METHOD CanEstPed()
	METHOD RevEmpSD4()
	METHOD RevPedAut(cListIdDcf)
ENDCLASS
//-----------------------------------------------
/* {Protheus.doc} New
Método construtor
@author felipe.m
@since 23/12/2014
@version 1.0
@example
(examples)
@see (links_or_references)
*/
//-----------------------------------------------
METHOD New() CLASS WMSDTCOrdemServicoReverse
	_Super:New()
	Self:lEstSrvAut := .F.
	Self:cCodMntVol := ""
	Self:cCodDisSep := ""
	Self:cConfExped := ""
	Self:aOrdOri    := {}
	Self:lCarteira  := .F.
	Self:oMovimento := Nil
	Self:oRelacMov  := Nil
Return

METHOD Destroy() CLASS WMSDTCOrdemServicoReverse
	FreeObj(Self)
Return

METHOD SetEstSerA(lEstSrvAut) CLASS WMSDTCOrdemServicoReverse
	Self:lEstSrvAut := lEstSrvAut
Return

METHOD SetHasCart(lCarteira) CLASS WMSDTCOrdemServicoReverse
	Self:lCarteira := lCarteira
Return
//-----------------------------------------------
/* {Protheus.doc} CanReverse
Verifica de pode ser estornado
@author felipe.m
@since 23/12/2014
@version 1.0
@example
(examples)
@see (links_or_references)
*/
//-----------------------------------------------
METHOD CanReverse() CLASS WMSDTCOrdemServicoReverse
Local lRet        := .T.
Local aAreaAnt    := GetArea()
Local aTamSX3     := TamSx3("D0E_QTDDIS")
Local oOrdSerAux  := WMSDTCOrdemServico():New()
Local oMntVolItem := Nil
Local oDisSepItem := Nil
Local oConfExpItem:= Nil
Local cWhere      := ""
Local cAliasSD4   := Nil
Local cAliasQry   := Nil
Local cLocalCQ    := SuperGetMV("MV_CQ",.F.,"")

	Self:cCodMntVol := ""
	Self:cCodDisSep := ""
	Self:cConfExped := ""
	If !(Self:GetStServ() $ "2|3")
		Self:cErro := STR0002 // Somente servicos executados ou interrompidos podem ser estornados.
		lRet := .F.
	EndIf
	If Self:GetStServ() == "3"
		If WmsX312118("D13","D13_USACAL") .And. !(Self:oServico:HasOperac({'3','4'})) // Caso o serviço for de separação ou separação crossdocking permite estorno
			cAliasQry := GetNextAlias()
			BeginSql Alias cAliasQry
				SELECT 1
				FROM %Table:D13% D13
				WHERE D13.D13_FILIAL = %xFilial:D13%
				AND D13.D13_IDDCF = %Exp:Self:cIdDCF%
				AND D13.D13_DTESTO < %Exp:DToS(MVUlmes())%
				AND D13.D13_USACAL <> '2'
				AND D13.%NotDel%
			EndSql
			If (cAliasQry)->(!Eof())
				Self:cErro := WmsFmtMsg(STR0022,{{"[VAR01]",MVUlmes()}}) // Data dos movimento de estoque maior que a data de fechamento do estoque ([VAR01])! Para efetuar os estorno é necessário reabrir o fechamento de estoque!
				lRet := .F.
			EndIf
			(cAliasQry)->(dbCloseArea())
		EndIf
		// Se for reabastecimento com origem preenchida, permite o estorno.
		If Self:oServico:HasOperac({'8'})
			If !Empty(Self:GetIdOrig()) .And. Self:GetStServ() == "3"
				// Verifica se exitem movimentos pendentes
				If !Self:HaveMovD12("6")
					oOrdSerAux:SetIdDCF(Self:GetIdOrig())
					If oOrdSerAux:LoadData()
						If oOrdSerAux:GetStServ() == "3"
							Self:cErro := WmsFmtMsg(STR0003,{{"[VAR01]",oOrdSerAux:GetDocto()}}) + Iif(Empty(oOrdSerAux:GetSerie()),"",STR0004+" " + oOrdSerAux:GetSerie()) // Não é possível estornar o documento, pois foi originado pelo documento: [VAR01]
							lRet := .F.
						EndIf
					EndIf
				EndIf
				// Verifica se existem movimentos finalizados
				If lRet .And. Self:HaveMovD12("1")
					Self:cErro := WmsFmtMsg(STR0018,{{"[VAR01]",Self:GetDocto()}}) + Iif(Empty(Self:GetSerie()),"",STR0004+" " + Self:GetSerie()) // Existem atividades finalizadas para o documento: [VAR01] // série:
					lRet := .F.
				EndIf
			EndIf
		EndIf
		//Verifica saldo do produto quando devolução crossdocking com reserva de pedido
		If lRet .And. Self:oServico:HasOperac({'2'})
			lRet := Self:ChkQtdRes()
		EndIf
		// Se for um serviço de reabastecimento deverá validar se o reabastecimento não está
		// comprometido com outras O.S.
		If lRet .And. Self:oServico:HasOperac({'5'})
			lRet := Self:CanEstReab()
		EndIf
		If lRet
			If Self:HaveMovD12("5")
				Self:cErro := WmsFmtMsg(STR0005,{{"[VAR01]",Self:GetDocto()}}) + Iif(Empty(Self:GetSerie()),"",STR0004+" " + Self:GetSerie()) // Existem atividades em execução para o documento: // série:
				lRet := .F.
			EndIf
		EndIf
		// Caso serviço tenha operação de transferencia e o armazém seja diferente do armazém de CQ
		If lRet .And. Self:oServico:HasOperac({'8'}) .And. Self:oOrdEndOri:GetArmazem() != cLocalCQ
			If Self:HaveMovD12("1")
				Self:cErro := WmsFmtMsg(STR0016,{{"[VAR01]",Self:GetDocto()},{"[VAR02]",Iif(Empty(Self:GetSerie()),""," "+STR0004+" "+Self:GetSerie())},{"[VAR03]",Self:oServico:GetServico()+" - "+AllTrim(Self:oServico:GetDesServ())}}) // Não é possível estornar o documento: [VAR01] [VAR02]. Serviço [VAR03] não permite operação.
				lRet := .F.
			EndIf
		EndIf
		If lRet
			If Self:oServico:GetTipo() == "2"
				If Self:cOrigem == "SC9" .And. !Self:lCarteira
					// Analisa se existe item faturado para o documento
					cAliasSC9 := GetNextAlias()
					BeginSql Alias cAliasSC9
						SELECT SC9.C9_PEDIDO,
								SC9.C9_ITEM,
								SC9.C9_PRODUTO,
								SC9.C9_QTDLIB
						FROM %Table:SC9% SC9
						WHERE SC9.C9_FILIAL = %xFilial:SC9%
						AND SC9.C9_IDDCF = %Exp:Self:GetIdDCF()%
						AND SC9.C9_NFISCAL <> ' '
						AND SC9.%NotDel%
					EndSql
					If (cAliasSC9)->(!Eof())
						Self:cErro := WmsFmtMsg(STR0006,{{"[VAR01]",(cAliasSC9)->C9_PEDIDO},{"[VAR02]",(cAliasSC9)->C9_ITEM},{"[VAR03]",(cAliasSC9)->C9_PRODUTO},{"[VAR04]",Str((cAliasSC9)->C9_QTDLIB)}}) // "Existe faturamento para o pedido: [VAR01] item: [VAR02] produto: [VAR03] quantidade: [VAR04]."
						lRet := .F.
					EndIf
					(cAliasSC9)->(dbCloseArea())
				EndIf
				//Verifica se existe conferência de expedição realizada
				If lRet
					cWhere := "%"
					If !Empty(Self:GetCarga()) .And. WMSCarga(Self:GetCarga())
						cWhere += " AND D02.D02_CARGA = '"+Self:GetCarga()+"'"
					EndIf
					If !Self:oProdLote:oProduto:oProdComp:IsDad()
						cWhere += " AND D02.D02_CODPRO = '"+Self:oProdLote:GetProduto()+ "'"
					EndIf
					If !Empty(Self:oProdLote:GetLoteCtl())
						cWhere += " AND D02.D02_LOTE   = '"+Self:oProdLote:GetLoteCtl()+"'"
					EndIf
					If !Empty(Self:oProdLote:GetNumLote())
						cWhere += " AND D02.D02_SUBLOT = '"+Self:oProdLote:GetNumLote()+"'"
					EndIf
					cWhere += "%"
					cAliasQry := GetNextAlias()
					BeginSql Alias cAliasQry
						SELECT D02.R_E_C_N_O_ RECNOD02,
								D02.D02_STATUS,
								D0H.D0H_CODEXP
						FROM %Table:D0H% D0H
						INNER JOIN %Table:D02% D02
						ON D02.D02_FILIAL = %xFilial:D02%
						AND D02.D02_CODEXP = D0H.D0H_CODEXP
						AND D02.D02_PEDIDO = %Exp:Self:GetDocto()%
						AND D02.D02_PRDORI = %Exp:Self:oProdLote:GetPrdOri()%
						AND D02.%NotDel%
						%Exp:cWhere%
						WHERE D0H.D0H_FILIAL = %xFilial:D0H%
						AND D0H.D0H_IDDCF  = %Exp:Self:GetIdDCF()%
						AND D0H.%NotDel%
					EndSql
					Do While (cAliasQry)->(!Eof())
						Self:cConfExped := (cAliasQry)->D0H_CODEXP
						If !((cAliasQry)->D02_STATUS == "1")
							lRet := .F.
							//Libera conferência para estorno
							If Self:lCarteira
								oConfExpItem := WMSDTCConferenciaExpedicaoItens():New()
								oConfExpItem:GoToD02((cAliasQry)->RECNOD02)
								oConfExpItem:oConfExp:SetLibEst("1")
								oConfExpItem:oConfExp:UpdLibEst()
							EndIf
						EndIf
						(cAliasQry)->(DbSkip())
					EndDo
					(cAliasQry)->(dbCloseArea())
					If !lRet
						Self:cErro := WmsFmtMsg(STR0009,{{"[VAR01]",Self:GetDocto()},{"[VAR02]",Self:oProdLote:GetProduto()},{"[VAR03]",Str(Self:GetQuant())},{"[VAR04]",Self:GetOrigem()}}) // "Existe conferência de expedição para o documento: [VAR01] produto: [VAR02] quantidade: [VAR03] origem: [VAR04]."
					EndIf
				EndIf
				//Verifica se existe volume montado
				If lRet
					cWhere := "%"
					If !Empty(Self:GetCarga()) .And. WmsCarga(Self:GetCarga())
						cWhere += " AND DCT.DCT_CARGA = '"+Self:GetCarga()+"'"
					EndIf
					If !Self:oProdLote:oProduto:oProdComp:IsDad()
						cWhere += " AND DCT.DCT_CODPRO = '"+Self:oProdLote:GetProduto()+"'"
					EndIf
					If !Empty(Self:oProdLote:GetLoteCtl())
						cWhere += " AND DCT.DCT_LOTE   = '"+Self:oProdLote:GetLoteCtl()+"'"
					EndIf
					If !Empty(Self:oProdLote:GetNumLote())
						cWhere += " AND DCT.DCT_SUBLOT = '"+Self:oProdLote:GetNumLote()+"'"
					EndIf
					cWhere += "%"
					cAliasQry := GetNextAlias()
					BeginSql Alias cAliasQry
						SELECT DCT.R_E_C_N_O_ RECNODCT,
								DCT.DCT_STATUS,
								D0I.D0I_CODMNT
						FROM %Table:D0I% D0I
						INNER JOIN %Table:DCT% DCT
						ON DCT.DCT_FILIAL = %xFilial:DCT%
						AND DCT.DCT_CODMNT = D0I.D0I_CODMNT
						AND DCT.DCT_PEDIDO = %Exp:Self:GetDocto()%
						AND DCT.DCT_PRDORI = %Exp:Self:oProdLote:GetPrdOri()%
						AND DCT.%NotDel%
						%Exp:cWhere%
						WHERE D0I.D0I_FILIAL = %xFilial:D0I%
						AND D0I.D0I_IDDCF  = %Exp:Self:GetIdDCF()%
						AND D0I.%NotDel%
					EndSql
					Do While (cAliasQry)->(!Eof())
						Self:cCodMntVol := (cAliasQry)->D0I_CODMNT
						If !((cAliasQry)->DCT_STATUS == "1")
							lRet := .F.
							//Libera volume para estorno
							If Self:lCarteira
								oMntVolItem := WMSDTCMontagemVolumeItens():New()
								oMntVolItem:GoToDCT((cAliasQry)->RECNODCT)
								oMntVolItem:oMntVol:SetLibEst("1")
								oMntVolItem:oMntVol:UpdLibEst()
							EndIf
						EndIf
						(cAliasQry)->(dbSkip())
					EndDo
					(cAliasQry)->(dbCloseArea())
					If !lRet
						Self:cErro := WmsFmtMsg(STR0007,{{"[VAR01]",Self:GetDocto()},{"[VAR02]",Self:oProdLote:GetProduto()},{"[VAR03]",Str(Self:GetQuant())},{"[VAR04]",Self:GetOrigem()}}) // "Existem volumes montados para o documento: [VAR01] produto: [VAR02] quantidade: [VAR03] origem: [VAR04]."
					EndIf
				EndIf
				//Verifica se existe distribução de separação realizada
				If lRet
					cWhere := "%"
					If !Empty(Self:GetCarga()) .And. WmsCarga(Self:GetCarga())
						cWhere += " AND D0E.D0E_CARGA = '" + Self:GetCarga() + "'"
					EndIf
					If !Self:oProdLote:oProduto:oProdComp:IsDad()
						cWhere += " AND D0E.D0E_PRODUT = '"+Self:oProdLote:GetProduto()+"'"
					EndIf
					If !Empty(Self:oProdLote:GetLoteCtl())
						cWhere += " AND D0E.D0E_LOTECT = '"+Self:oProdLote:GetLoteCtl()+"'"
					EndIf
					If !Empty(Self:oProdLote:GetNumLote())
						cWhere += " AND D0E.D0E_NUMLOT = '"+Self:oProdLote:GetNumLote()+"'"
					EndIf
					cWhere += "%"
					cAliasQry := GetNextAlias()
					BeginSql Alias cAliasQry
						SELECT D0E.R_E_C_N_O_ RECNOD0E,
								D0E.D0E_STATUS,
								D0E.D0E_QTDDIS, 
								D0J.D0J_CODDIS
						FROM %Table:D0J% D0J
						INNER JOIN %Table:D0E% D0E
						ON D0E.D0E_FILIAL = %xFilial:D0E%
						AND D0E.D0E_CODDIS = D0J.D0J_CODDIS
						AND D0E.D0E_PEDIDO = %Exp:Self:GetDocto()%
						AND D0E.D0E_PRDORI = %Exp:Self:oProdLote:GetPrdOri()%
						AND D0E.%NotDel%
						%Exp:cWhere%
						WHERE D0J.D0J_FILIAL = %xFilial:D0J%
						AND D0J.D0J_IDDCF  = %Exp:Self:GetIdDCF()%
						AND D0J.%NotDel%
					EndSql
					TcSetField(cAliasQry,'D0E_QTDDIS','N',aTamSX3[1],aTamSX3[2])
					Do While (cAliasQry)->(!Eof())
						Self:cCodDisSep := (cAliasQry)->D0J_CODDIS
						If !((cAliasQry)->D0E_STATUS == "1" .And. QtdComp((cAliasQry)->D0E_QTDDIS) == 0)
							lRet := .F.
							//Libera distribuição para estorno
							If Self:lCarteira
								oDisSepItem := WMSDTCDistribuicaoSeparacaoItens():New()
								oDisSepItem:GoToD0E((cAliasQry)->RECNOD0E)
								oDisSepItem:oDisSep:SetLibEst("1")
								oDisSepItem:oDisSep:UpdLibEst()
							EndIf
						EndIf
						(cAliasQry)->(DbSkip())
					EndDo
					(cAliasQry)->(dbCloseArea())
					If !lRet
						Self:cErro := WmsFmtMsg(STR0015,{{"[VAR01]",Self:GetDocto()},{"[VAR02]",Self:oProdLote:GetProduto()},{"[VAR03]",Str(Self:GetQuant())},{"[VAR04]",Self:GetOrigem()}}) // "Existem produtos já distruídos após a separação para o documento: [VAR01] produto: [VAR02] quantidade: [VAR03] origem: [VAR04]."
					EndIf
				EndIf
				// Verifica se requisição não teve nenhuma baixa
				If Self:cOrigem == "SD4"
					cAliasSD4  := GetNextAlias()
					BeginSql Alias cAliasSD4
						SELECT 1
						FROM %Table:SD4% SD4
						WHERE SD4.D4_FILIAL = %xFilial:SD4%
						AND SD4.D4_IDDCF = %Exp:Self:GetIdDCF()%
						AND SD4.D4_QTDEORI <> SD4.D4_QUANT
						AND SD4.D4_QTDEORI > 0
						AND NOT EXISTS (SELECT 1
										FROM %Table:DCR% DCR, %Table:D12% D12
										WHERE DCR.DCR_FILIAL = %xFilial:DCR%
										AND DCR.DCR_IDDCF  = %Exp:Self:cIdDCF%
										AND DCR.DCR_SEQUEN = %Exp:Self:cSequen%
										AND DCR.%NotDel%
										AND D12.D12_FILIAL = %xFilial:D12%
										AND D12.D12_IDDCF = DCR.DCR_IDORI
										AND D12.D12_IDMOV = DCR.DCR_IDMOV
										AND D12.D12_IDOPER = DCR.DCR_IDOPER
										AND D12.D12_BXESTO = '1'
										AND D12.D12_STATUS = '1'
										AND D12.%NotDel% )
						AND SD4.%NotDel%
					EndSql
					If (cAliasSD4)->(!Eof())
						Self:cErro := WmsFmtMsg(STR0021,{{"[VAR01]",Self:GetIdDCF()}}) // Ordem de serviço [VAR01] de requisição não pode ser estornada, já foram realizadas baixas de requisição! 
						lRet := .F.
					EndIf
					(cAliasSD4)->(dbCloseArea())
				EndIf
			EndIf
			If lRet
				cAliasQry := GetNextAlias()
				BeginSql Alias cAliasQry
					SELECT DISTINCT D12.D12_FILIAL 
					FROM %Table:DCR% DCR
					INNER JOIN %Table:D12% D12
					ON D12.D12_FILIAL = %xFilial:D12%
					AND D12.D12_IDDCF = DCR.DCR_IDORI
					AND D12.D12_IDMOV = DCR.DCR_IDMOV
					AND D12.D12_IDOPER = DCR.DCR_IDOPER
					AND D12.D12_STATUS = '1'
					AND D12.%NotDel%
					AND EXISTS ( SELECT 1
									FROM %Table:SBE% SBE
									WHERE SBE.BE_FILIAL = %xFilial:SBE%
									AND D12.D12_FILIAL = %xFilial:D12%
									AND ((SBE.BE_LOCAL = D12.D12_LOCORI AND SBE.BE_LOCALIZ = D12.D12_ENDORI)
									OR (SBE.BE_LOCAL = D12.D12_LOCDES AND SBE.BE_LOCALIZ = D12.D12_ENDDES))
									AND SBE.BE_STATUS = '6'
									AND SBE.%NotDel% )
					WHERE DCR.DCR_FILIAL = %xFilial:DCR%
					AND DCR.DCR_IDDCF = %Exp:Self:cIdDCF%
					AND DCR.DCR_SEQUEN = %Exp:Self:cSequen%
					AND DCR.%NotDel%
				EndSql
				If (cAliasQry)->(!Eof())
					Self:cErro := WmsFmtMsg(STR0017,{{"[VAR01]",Self:GetDocto()},{"[VAR02]",Self:oProdLote:GetProduto()}}) //"Documento [VAR01] produto [VAR02] não pode ser estornado por utilizar endereço com bloqueio de inventário."
					lRet := .F.
				EndIf
				(cAliasQry)->(dbCloseArea())
			EndIf
		EndIf
	EndIf
	If !lRet
		aAdd(Self:aWmsAviso, WmsFmtMsg(STR0001,{{"[VAR01]",Self:GetDocto()+Iif(!Empty(Self:GetSerie()),"/"+AllTrim(Self:GetSerie()),'')},{"[VAR02]",Self:oProdLote:GetProduto()}}) + CRLF +Self:GetErro()) // SIGAWMS - OS [VAR01] - Produto: [VAR02]
	EndIf
	RestArea(aAreaAnt)
Return lRet
//-----------------------------------------------
/* {Protheus.doc} ReverseDCF
Estorno da ordem de serviço
@author felipe.m
@since 23/12/2014
@version 1.0
@example
(examples)
@see (links_or_references)
*/
//-----------------------------------------------
METHOD ReverseDCF() CLASS WMSDTCOrdemServicoReverse
Local lRet       := .T.
Local aAreaAnt   := GetArea()
Local aAreaDCF   := DCF->(GetArea())
Local aAreaD12   := D12->(GetArea())
Local oBlqSaldo  := Nil
Local oMntUniItem:= Nil
Local cAliasD12  := Nil
Local cAliasDCF  := Nil
Local nTipoRegra := "3"
Local xRegra     := CtoD('  /  /  ')
	// Loca registro DCF
	If Self:LockDCF()
		If Self:GetStServ() == '3'
			//Ajusta quantidade à distribuir
			If Self:oServico:HasOperac({'1','2'})  // Caso serviço tenha operação de endereçamento, endereçamento crossdocking
				lRet := Self:RevSldDist()
			EndIf
			//Ajusta status do unitizador
			If Self:IsMovUnit() .And. Self:oServico:HasOperac({'1','2'})  // Caso serviço tenha operação de endereçamento, endereçamento crossdocking
				// Atualização do Status do unitizador na finalização do ultimo movimento
				oMntUniItem := WMSDTCMontagemUnitizadorItens():New()
				oMntUniItem:SetIdUnit(Self:cIdUnitiz)
				// Atualiza os produtos do unitizador (D0S) para endereçado '1=Não'
				oMntUniItem:SetEndrec("2") // 1=Não
				oMntUniItem:UpdEndrec(.F./*lProduto*/)
				// Atualiza o unitizador (D0R) para 3=OS Gerada
				oMntUniItem:oUnitiz:SetStatus("3") // 3=OS Gerada
				oMntUniItem:oUnitiz:UpdStatus()
			EndIf
			//Estorna bloqueio de saldo
			If lRet .And. WmsX212118("D0V")
				If lRet .And. Self:oServico:ChkRecebi() .And. Self:oServico:ChkBlqSld()
					oBlqSaldo := WMSDTCBloqueioSaldoItens():New()
					oBlqSaldo:SetOrdServ(Self)
					lRet := oBlqSaldo:RevBlqSld() 
				EndIf
			EndIf
			// Estorna processos de expedição
			If lRet .And. Self:oServico:HasOperac({'3','4'}) // Caso serviço tenha operação de separação, separação crossdocking
				// montagem de volume, distribuição da separação, conferência de expedição
				If lRet .And. (!Empty(Self:cCodMntVol) .Or. !Empty(Self:cCodDisSep) .Or. !Empty(Self:cConfExped))
					lRet := Self:RevExpedic()
				EndIf
				// Estorna liberação de pedidos
				If lRet .And. Self:cOrigem $ "SC9|DBN"
					nTipoRegra := Iif(Empty(Self:cRegra),nTipoRegra,Self:cRegra)
					xRegra     := Iif(nTipoRegra=="1",Self:oProdLote:GetLoteCtl(),xRegra)
					lRet := WmsEstSC9(Self:cCarga,Self:cDocumento,Self:cSerie,Self:oProdLote:GetPrdOri(),Self:oServico:GetServico(),Self:nQuant,Self:nQuant2,Self:oOrdEndDes:GetArmazem(),Self:oOrdEndDes:GetEnder(),Self:cIdDCF,Val(nTipoRegra),xRegra,.T.)
				EndIf
				// Estorna movimento separação de requisição SD3
				If lRet .And. Self:GetOrigem() == "DH1"
					lRet := Self:MakeEstSD3()
				EndIf
				// Estorna empenho requisições
				// Efetua o estorno do empenho de forma separada, pois a requisição pode solicitar
				// uma quantidade maior que a empenhada. 
				If lRet .And. Self:cOrigem = "SD4"
					lRet := Self:RevEmpSD4()
				EndIf
				// Deve estornar o empenho gerado para os itens
				If lRet .And. Self:cOrigem $ "SC9" .And. Self:oProdLote:HasRastro() .And. Empty(Self:oProdLote:GetLoteCtl())
					lRet := Self:RevEmpSB8()
				EndIf
			EndIf
			If lRet
				If Self:oMovimento == Nil
					Self:oMovimento := WMSDTCMovimentosServicoArmazem():New()
				EndIf
				If Self:oRelacMov == Nil
					Self:oRelacMov  := WMSDTCRelacionamentoMovimentosServicoArmazem():New()
				EndIf

				// Estornando as movimentações de estoque
				cAliasD12 := GetNextAlias()
				BeginSql Alias cAliasD12
					SELECT D12.R_E_C_N_O_ RECNOD12
					FROM %Table:DCR% DCR
					INNER JOIN %Table:D12% D12
					ON D12.D12_FILIAL = %xFilial:D12%
					AND D12.D12_IDDCF = DCR.DCR_IDORI
					AND D12.D12_IDMOV = DCR.DCR_IDMOV
					AND D12.D12_IDOPER = DCR.DCR_IDOPER
					AND D12.D12_STATUS <> '0'
					AND D12.%NotDel%
					WHERE DCR.DCR_FILIAL = %xFilial:DCR%
					AND DCR.DCR_IDDCF = %Exp:Self:cIdDCF%
					AND DCR.DCR_SEQUEN = %Exp:Self:cSequen%
					AND DCR.%NotDel%
				EndSql
				Do While lRet .And. (cAliasD12)->(!Eof())
					If Self:oMovimento:GoToD12((cAliasD12)->RECNOD12)
						If Self:oMovimento:GetStatus() == "1"
							lRet := Self:RevMovEst()
						Else
							lRet := Self:RevMovPrev()
						EndIf
					EndIf
					(cAliasD12)->(dbSkip())
				EndDo
				(cAliasD12)->(dbCloseArea())
				// Carrega documentos originados
				If lRet .And. Self:lEstSrvAut
					cAliasDCF := GetNextAlias()
					BeginSql Alias cAliasDCF
						SELECT DCF.DCF_ID
						FROM %Table:DCF% DCF
						INNER JOIN %Table:DC5% DC5
						ON DC5.DC5_FILIAL = %xFilial:DC5%
						AND DC5.DC5_SERVIC = DCF.DCF_SERVIC
						AND DC5.DC5_OPERAC = '5'
						AND DC5.%NotDel%
						WHERE DCF.DCF_FILIAL = %xFilial:DCF%
						AND DCF.DCF_IDORI = %Exp:Self:cIdDCF%
						AND DCF.%NotDel%
					EndSql
					Do While (cAliasDCF)->(!Eof())
						aAdd(Self:aOrdReab,(cAliasDCF)->DCF_ID)
						(cAliasDCF)->(DbSkip())
					EndDo
					(cAliasDCF)->(DbCloseArea())
				EndIf
			EndIf
		EndIf
		If lRet
			// Altera o Status para NAO EXECUTADO no DCF
			Self:SetStServ("1")
			Self:SetOk("")
			Self:SetSequen(Soma1(Self:GetSequen(),TamSx3("DCF_SEQUEN")[1]))
			Self:UpdateDCF()
			Self:UpdStatus()
		EndIf
		If !lRet
			aAdd(Self:aWmsAviso, WmsFmtMsg(STR0001,{{"[VAR01]",Self:GetDocto()+Iif(!Empty(Self:GetSerie()),"/"+AllTrim(Self:GetSerie()),'')},{"[VAR02]",Self:oProdLote:GetProduto()}}) + CRLF +Self:GetErro()) // SIGAWMS - OS [VAR01] - Produto: [VAR02]
		EndIf
	EndIf
	// Retira lock DCF
	Self:UnLockDCF()

	RestArea(aAreaAnt)
	RestArea(aAreaDCF)
	RestArea(aAreaD12)
Return lRet
//------------------------------------------------------------------------------
METHOD RevExpedic()  CLASS WMSDTCOrdemServicoReverse
Local lRet        := .T.
Local aAreaD12    := D12->(GetArea())
Local aTamSX3     := TamSx3("DCR_QUANT")
Local oMntVolItem := Nil
Local oDisSepItem := Nil
Local oConExpItem := Nil
Local cAliasD12   := Nil
	cAliasD12 := GetNextAlias()
	BeginSql Alias cAliasD12
		SELECT D12.D12_PRODUT,
				D12.D12_LOTECT,
				D12.D12_NUMLOT,
				D12.D12_NUMSER,
				DCR.DCR_IDDCF,
				D12.D12_STATUS,
				SUM(DCR.DCR_QUANT) DCR_QUANT
		FROM %Table:DCR% DCR
		INNER JOIN %Table:D12% D12
		ON D12.D12_FILIAL = %xFilial:D12%
		AND D12.D12_IDDCF = DCR.DCR_IDORI
		AND D12.D12_IDMOV = DCR.DCR_IDMOV
		AND D12.D12_IDOPER = DCR.DCR_IDOPER
		AND D12.D12_ATUEST = '1'
		AND D12.D12_STATUS <> '0'
		AND D12.%NotDel%
		WHERE DCR.DCR_FILIAL = %xFilial:DCR%
		AND DCR.DCR_IDDCF  = %Exp:Self:cIdDCF%
		AND DCR.DCR_SEQUEN = %Exp:Self:cSequen%
		AND DCR.%NotDel%
		GROUP BY D12.D12_PRODUT, 
					D12.D12_LOTECT,
					D12.D12_NUMLOT,
					D12.D12_NUMSER,
					DCR.DCR_IDDCF,
					D12.D12_STATUS
		ORDER BY D12.D12_PRODUT,
					D12.D12_LOTECT,
					D12.D12_NUMLOT,
					D12.D12_NUMSER,
					DCR.DCR_IDDCF
	EndSql
	TcSetField(cAliasD12,'DCR_QUANT','N',aTamSX3[1],aTamSX3[2])
	Do While (cAliasD12)->(!Eof())
		// Estorna a montagem de volume caso exista
		If !Empty(Self:cCodMntVol)
			If oMntVolItem == Nil
				oMntVolItem := WMSDTCMontagemVolumeItens():New()
			EndIf
			// Valida se possue montagem de volume
			oMntVolItem:SetCarga(Self:GetCarga())
			oMntVolItem:SetPedido(Self:GetDocto())
			oMntVolItem:SetPrdOri(Self:oProdLote:GetPrdOri())
			oMntVolItem:SetProduto((cAliasD12)->D12_PRODUT )
			oMntVolItem:SetLoteCtl((cAliasD12)->D12_LOTECT )
			oMntVolItem:SetNumLote((cAliasD12)->D12_NUMLOT )
			// Atribui codigo da montagem já selecionado na validação
			oMntVolItem:SetCodMnt(Self:cCodMntVol)
			If oMntVolItem:LoadData()
				oMntVolItem:SetIdDCF((cAliasD12)->DCR_IDDCF)
				If !oMntVolItem:RevMntVol((cAliasD12)->DCR_QUANT,Iif((cAliasD12)->D12_STATUS == "1",(cAliasD12)->DCR_QUANT,0))
					lRet := .F.
					Self:cErro := oMntVolItem:GetErro()
				EndIf
			EndIf
		EndIf
		// Estorna a distribuição da separação, caso exista
		If !Empty(Self:cCodDisSep)
			If oDisSepItem == Nil
				oDisSepItem := WMSDTCDistribuicaoSeparacaoItens():New()
			EndIf
			oDisSepItem:SetCarga(Self:GetCarga())
			oDisSepItem:SetPedido(Self:GetDocto())
			oDisSepItem:oDisEndOri:SetArmazem(Self:oOrdEndOri:GetArmazem())
			oDisSepItem:SetPrdOri(Self:oProdLote:GetPrdOri())
			oDisSepItem:SetProduto((cAliasD12)->D12_PRODUT)
			oDisSepItem:SetLoteCtl((cAliasD12)->D12_LOTECT)
			oDisSepItem:SetNumLote((cAliasD12)->D12_NUMLOT)
			oDisSepItem:SetNumSer((cAliasD12)->D12_NUMSER)
			// Busca o codigo da distribuição da separação
			oDisSepItem:SetCodDis(Self:cCodDisSep)
			If oDisSepItem:LoadData()
				oDisSepItem:SetIdDCF(Self:GetIdDCF())
				If !oDisSepItem:RevDisSep((cAliasD12)->DCR_QUANT,Iif((cAliasD12)->D12_STATUS == "1",(cAliasD12)->DCR_QUANT,0))
					lRet := .F.
					Self:cErro := oDisSepItem:GetErro()
				EndIf
			EndIf
		EndIf
		// Estorna a conferência de expedição, caso exista
		If !Empty(Self:cConfExped)
			If oConExpItem == Nil
				oConExpItem := WMSDTCConferenciaExpedicaoItens():New()
			EndIf
			oConExpItem:SetCarga(Self:GetCarga())
			oConExpItem:SetPedido(Self:GetDocto())
			oConExpItem:SetPrdOri(Self:oProdLote:GetPrdOri())
			oConExpItem:SetProduto((cAliasD12)->D12_PRODUT)
			oConExpItem:SetLoteCtl((cAliasD12)->D12_LOTECT)
			oConExpItem:SetNumLote((cAliasD12)->D12_NUMLOT)
			// Busca o codigo da conferencia de expedição
			oConExpItem:SetCodExp(Self:cConfExped)
			If oConExpItem:LoadData()
				oConExpItem:SetIdDCF(Self:GetIdDCF())
				If !oConExpItem:RevConfExp((cAliasD12)->DCR_QUANT,Iif((cAliasD12)->D12_STATUS == "1",(cAliasD12)->DCR_QUANT,0))
					lRet := .F.
					Self:cErro := oConExpItem:GetErro()
				EndIf
			EndIf
		EndIf
		(cAliasD12)->(dbSkip())
	EndDo
	(cAliasD12)->(dbCloseArea())
	// Deve excluir os relacionamentos das ordens de serviço com os processos
	If !Empty(Self:cCodMntVol) .And. oMntVolItem != Nil
		oMntVolItem:DeleteD0I() // Exclui D0I
	EndIf
	If !Empty(Self:cCodDisSep) .And. oDisSepItem != Nil
		oDisSepItem:DeleteD0J() // Exclui D0J
	EndIf
	If !Empty(Self:cConfExped) .And. oConExpItem != Nil
		oConExpItem:DeleteD0H() // Exclui D0H
	EndIf
	RestArea(aAreaD12)
Return lRet
//------------------------------------------------------------------------------
METHOD RevEmpSB8()  CLASS WMSDTCOrdemServicoReverse
Local lRet        := .T.
Local aTamSX3     := TamSx3("DCR_QUANT")
Local aArrProd    := Self:oProdLote:GetArrProd()
Local cAliasD12   := Nil
	// Faz somente para o primeiro produto, quando produto componente
	// Quando produto normal, retorna o próprio produto no array
	cAliasD12 := GetNextAlias()
	BeginSql Alias cAliasD12
		SELECT D12.D12_LOCORI,
				D12.D12_PRDORI,
				D12.D12_LOTECT,
				D12.D12_NUMLOT,
				(SUM(DCR.DCR_QUANT) / %Exp:aArrProd[1,2]% ) DCR_QUANT
		FROM %Table:DCR% DCR
		INNER JOIN %Table:D12% D12
		ON D12.D12_FILIAL = %xFilial:D12%
		AND D12.D12_IDDCF = DCR.DCR_IDORI
		AND D12.D12_IDMOV = DCR.DCR_IDMOV
		AND D12.D12_IDOPER = DCR.DCR_IDOPER
		AND D12.D12_PRODUT = %Exp:aArrProd[1,1]%
		AND D12.D12_PRDORI = %Exp:aArrProd[1,3]%
		AND D12.D12_ATUEST = '1'
		AND D12.D12_STATUS <> '0'
		AND D12.%NotDel%
		WHERE DCR.DCR_FILIAL = %xFilial:DCR%
		AND DCR.DCR_IDDCF = %Exp:Self:cIdDCF%
		AND DCR.DCR_SEQUEN = %Exp:Self:cSequen%
		AND DCR.%NotDel%
		GROUP BY D12.D12_LOCORI,
					D12.D12_PRDORI,
					D12.D12_LOTECT,
					D12.D12_NUMLOT
		ORDER BY D12.D12_LOCORI,
					D12.D12_PRDORI,
					D12.D12_LOTECT,
					D12.D12_NUMLOT
	EndSql
	TcSetField(cAliasD12,'DCR_QUANT','N',aTamSX3[1],aTamSX3[2])
	Do While (cAliasD12)->(!Eof())
		Self:UpdEmpSB8("-",(cAliasD12)->D12_PRDORI,(cAliasD12)->D12_LOCORI,(cAliasD12)->D12_LOTECT,(cAliasD12)->D12_NUMLOT,(cAliasD12)->DCR_QUANT)
		(cAliasD12)->(dbSkip())
	EndDo
	(cAliasD12)->(dbCloseArea())
Return lRet
//--------------------------------------------------
/*/{Protheus.doc} RevSldDist
//Ajusta quantidade à distribuir
@author Squad WMS Protheus
@since 27/06/2018
@version 1.0
@return lógico

@type function
@version 1.0
/*/
//--------------------------------------------------
METHOD RevSldDist() CLASS WMSDTCOrdemServicoReverse
Local lRet      := .T.
Local lWmsBlqe  := SuperGetMV("MV_WMSBLQE",.F.,.F.)
Local oSaldoADis:= WMSDTCSaldoADistribuir():New()
Local cAliasD0Q := Nil
	//Quando tratar-se de um produto componente, verifica se a demanda não está relacionada à outras ordens de serviços já executadas para só então estornar o produto pai
	If Self:IsMovUnit()
		cAliasD0Q := GetNextAlias()
		BeginSql Alias cAliasD0Q
			SELECT D0Q.D0Q_ID,
					D0Q.D0Q_DOCTO,
					D0Q.D0Q_SERIE,
					D0Q.D0Q_CLIFOR,
					D0Q.D0Q_LOJA,
					D0Q.D0Q_ORIGEM,
					D0Q.D0Q_NUMSEQ,
					D0Q.D0Q_QUANT,
					D0Q.D0Q_CODPRO,
					D0Q.D0Q_LOTECT,
					D0Q.D0Q_NUMLOT
			FROM %Table:D0Q% D0Q
			INNER JOIN %Table:D0U% D0U
			ON D0U.D0U_FILIAL = %xFilial:D0U%
			AND D0U.D0U_IDDCF = D0Q.D0Q_ID
			AND D0U.D0U_ORIGEM = 'D0Q'
			AND D0U.D_E_L_E_T_ = ' '"
			WHERE D0Q.D0Q_FILIAL = %xFilial:D0Q%
			AND D0Q.D0Q_ID IN ( SELECT DISTINCT D0S.D0S_IDD0Q
								FROM %Table:D0S% D0S
								WHERE D0S.D0S_FILIAL = %xFilial:D0S%
								AND D0S.D0S_IDUNIT = %Exp:Self:cIdUnitiz%
								AND D0S.%NotDel% )
			AND NOT EXISTS ( SELECT D0S.D0S_IDUNIT
								FROM %Table:D0S% D0S
								INNER JOIN %Table:DCF% DCF
								ON DCF.DCF_FILIAL = %xFilial:DCF%
								AND DCF.DCF_UNITIZ = D0S.D0S_IDUNIT
								AND DCF.DCF_ORIGEM = 'D0R'
								AND DCF.DCF_STSERV = '3'
								AND DCF.DCF_ID <> %Exp:Self:cIdDCF%
								AND DCF.%NotDel%
								WHERE D0S.D0S_FILIAL = %xFilial:D0S%
								AND D0S.D0S_IDD0Q = D0Q.D0Q_ID
								AND D0S.D0S_IDUNIT <> %Exp:Self:cIdUnitiz%
								AND D0S.%NotDel% )
			AND D0Q.%NotDel%
		EndSql
		aTamSX3 := TamSx3("D0Q_QUANT"); TcSetField(cAliasD0Q,'D0Q_QUANT','N',aTamSX3[1],aTamSX3[2])
		Do While lRet .And. (cAliasD0Q)->(!Eof())
			oSaldoADis:ClearData()
			//Informações do produto
			oSaldoADis:oProdLote:SetArmazem(Self:oProdLote:GetArmazem())
			oSaldoADis:oProdLote:SetProduto((cAliasD0Q)->D0Q_CODPRO)
			oSaldoADis:oProdLote:SetPrdOri((cAliasD0Q)->D0Q_CODPRO)
			oSaldoADis:oProdLote:SetLoteCtl((cAliasD0Q)->D0Q_LOTECT)
			oSaldoADis:oProdLote:SetNumLote((cAliasD0Q)->D0Q_NUMLOT)
			oSaldoADis:oProdLote:LoadData()
			//
			oSaldoADis:SetDocto((cAliasD0Q)->D0Q_DOCTO)
			oSaldoADis:SetSerie((cAliasD0Q)->D0Q_SERIE)
			oSaldoADis:SetCliFor((cAliasD0Q)->D0Q_CLIFOR)
			oSaldoADis:SetLoja((cAliasD0Q)->D0Q_LOJA)
			oSaldoADis:SetOrigem((cAliasD0Q)->D0Q_ORIGEM)
			oSaldoADis:SetNumSeq((cAliasD0Q)->D0Q_NUMSEQ)
			oSaldoADis:SetIdDCF((cAliasD0Q)->D0Q_ID)
			If oSaldoADis:LoadData(3)
				lRet := oSaldoADis:DeleteD0G()
			EndIf
			// Recria D0G
			// Somente se parametrizado para gerar saldo à distribuir
			If lRet .And. lWmsBlqe
				oSaldoADis:SetQtdOri((cAliasD0Q)->D0Q_QUANT)
				oSaldoADis:SetQtdSld((cAliasD0Q)->D0Q_QUANT)
				lRet := oSaldoADis:AssignD0G()
			EndIf
			(cAliasD0Q)->(dbSkip())
		EndDo
		(cAliasD0Q)->(dbCloseArea())
	Else
		oSaldoADis:oProdLote := Self:oProdLote // Utiliza a mesma referência do objeto já carregado
		oSaldoADis:SetDocto(Self:GetDocto())
		oSaldoADis:SetSerie(Self:GetSerie())
		oSaldoADis:SetCliFor(Self:GetCliFor())
		oSaldoADis:SetLoja(Self:GetLoja())
		oSaldoADis:SetOrigem(Self:GetOrigem())
		oSaldoADis:SetNumSeq(Self:GetNumSeq())
		oSaldoADis:SetIdDCF(Self:GetIdDCF())
		If oSaldoADis:LoadData(3)
			lRet := oSaldoADis:DeleteD0G()
		EndIf
		// Recria D0G
		// Somente se parametrizado para gerar saldo à distribuir
		If lRet .And. lWmsBlqe
			oSaldoADis:SetQtdOri(Self:GetQuant())
			oSaldoADis:SetQtdSld(Self:GetQuant())
			lRet := oSaldoADis:AssignD0G()
		EndIf
	EndIf
	If !lRet
		Self:cErro := oSaldoADis:GetErro()
	EndIf
Return lRet
//------------------------------------------------------------------------------
METHOD RevMovEst() CLASS WMSDTCOrdemServicoReverse
Local lRet       := .T.
Local lEmpenho   := .F.
Local lBloqueio  := .F.
Local aTamSX3    := {}
Local oEstEnder  := Self:oMovimento:oEstEnder // Para facilitar o apontamento do objeto
Local cAliasQry  := Nil
Local cSerTran   := ""
Local nQtdSldEnd := 0

	Self:oRelacMov:SetIdOrig(Self:oMovimento:GetIdDCF())
	Self:oRelacMov:SetIdDCF(Self:cIdDCF)
	Self:oRelacMov:SetSequen(Self:cSequen)
	Self:oRelacMov:SetIdMovto(Self:oMovimento:GetIdMovto())
	Self:oRelacMov:SetIdOpera(Self:oMovimento:GetIdOpera())
	If !Self:oRelacMov:LoadData()
		Self:cErro := Self:oRelacMov:GetErro()
		lRet := .F.
	EndIf
	// Verifica se movimento atualiza estoque
	If lRet .And. Self:oMovimento:IsUpdEst()
		cSerTran := IIf(!Empty(Self:oMovimento:oMovPrdLot:GetSerTrDv()),Self:oMovimento:oMovPrdLot:GetSerTrDv(),Self:oMovimento:oMovServic:FindTransf())
		If Empty(cSerTran)
			lRet := .F.
			Self:cErro := STR0014 // Servico de transferencia não configurado!
		EndIf
	EndIf
	// Verifica se o estorno é de um movimento aglutinado
	If lRet .And. QtdComp(Self:oMovimento:GetQtdMov()) <> QtdComp(Self:oRelacMov:GetQuant())
		// Quando o estorno é de um movimento aglutinado deverá ser criado um novo
		// movimento com a quantidade a ser estornada, e o movimento original deverá
		// ter a quantidade estornada subtraída. Irá posicionar no novo registro de
		// movimento e no novo registro de relacionamento para efetuar os controles
		// de estorno de movimento;
		If Self:oMovimento:ReverseAgl(Self:oRelacMov)
			// Posiciona na nova DCR gerada
			Self:oRelacMov:SetIdOrig(Self:oMovimento:GetIdDCF())
			Self:oRelacMov:SetIdDCF(Self:cIdDCF)
			Self:oRelacMov:SetSequen(Self:cSequen)
			Self:oRelacMov:SetIdMovto(Self:oMovimento:GetIdMovto())
			Self:oRelacMov:SetIdOpera(Self:oMovimento:GetIdOpera())
			If !Self:oRelacMov:LoadData()
				Self:cErro := Self:oRelacMov:GetErro()
				lRet := .F.
			EndIf
		Else
			Self:cErro := Self:oMovimento:GetErro()
			lRet := .F.
		EndIf
	EndIf
	// Verifica se movimento atualiza estoque
	If lRet .And. Self:oMovimento:IsUpdEst()
		// Inicializa
		lEmpenho   := Self:oMovimento:oMovServic:ChkSepara() .And. (Self:oMovimento:oOrdServ:GetOrigem() == 'SC9' .Or. (Self:oMovimento:oOrdServ:GetOrigem() == 'DH1' .And. Self:oMovimento:GetBxEsto() == "1"))
		If Self:oMovimento:IsMovUnit()
			cAliasQry := GetNextAlias()
			BeginSql Alias cAliasQry
				SELECT D0S.D0S_PRDORI,
						D0S.D0S_CODPRO,
						D0S.D0S_LOTECT,
						D0S.D0S_NUMLOT,
						D0S.D0S_QUANT
				FROM %Table:D0S% D0S
				WHERE D0S.D0S_FILIAL = %xFilial:D0S%
				AND D0S.D0S_IDUNIT = %Exp:Self:oMovimento:GetIdUnit()%
				AND D0S.%NotDel%
			EndSql
			aTamSX3 := TamSx3("D0S_QUANT"); TcSetField(cAliasQry,'D0S_QUANT','N',aTamSX3[1],aTamSX3[2])
			If (cAliasQry)->(!Eof())
				Do While lRet .And. (cAliasQry)->(!Eof())
					// Realiza os estorno da quantidade entrada prevista
					oEstEnder:ClearData()
					oEstEnder:oEndereco:SetArmazem(Self:oMovimento:oMovEndDes:GetArmazem())
					oEstEnder:oEndereco:SetEnder(Self:oMovimento:oMovEndDes:GetEnder())
					oEstEnder:oProdLote:SetArmazem(Self:oMovimento:oMovPrdLot:GetArmazem())
					oEstEnder:oProdLote:SetPrdOri((cAliasQry)->D0S_PRDORI)
					oEstEnder:oProdLote:SetProduto((cAliasQry)->D0S_CODPRO)
					oEstEnder:oProdLote:SetLoteCtl((cAliasQry)->D0S_LOTECT)
					oEstEnder:oProdLote:SetNumLote((cAliasQry)->D0S_NUMLOT)
					// Caso endereço destino seja um picking ou seja a DOCA no processo de separação, limpa o unitizador destino do movimento
					If Self:oMovimento:DesNotUnit()
						oEstEnder:SetIdUnit("")
					Else
						If Self:oMovimento:oMovServic:ChkTransf()
							oEstEnder:SetIdUnit(Self:oMovimento:GetUniDes())
						Else
							oEstEnder:SetIdUnit(Self:oMovimento:GetIdUnit())
						EndIf
					EndIf
					oEstEnder:SetQuant((cAliasQry)->D0S_QUANT)
					// Retira o emprenho e/ou bloqueio de estoque, caso exista
					If lEmpenho .Or. lBloqueio
						// Retira o empenho do endereco destino
						If !oEstEnder:UpdSaldo('999',.F. /*lEstoque*/,.F. /*lEntPrev*/,.F. /*lSaiPrev*/,lEmpenho /*lEmpenho*/,lBloqueio /*lBloqueio*/)
							Self:cErro := oEstEnder:GetErro()
							lRet := .F.
						EndIf
					EndIf
					// Valida se o endereço possui saldo suficiente para estornar esta quantidade
					If oEstEnder:LoadData()
						nQtdSldEnd := oEstEnder:GetQtdEst()-(oEstEnder:GetQtdEmp()+oEstEnder:GetQtdBlq())
						// Se já existe uma movimentação de saída prevista, ou não tem mais saldo no endereço, não deixa estornar
						If QtdComp(nQtdSldEnd-oEstEnder:GetQtdSPr()) < QtdComp((cAliasQry)->D0S_QUANT)
							lRet := .F.
							// O estorno não pode ser efetuado, pois o saldo do endereço [VAR01] está comprometido.
							// Quantidade para estorno de [VAR01]
							// Endereço possui saldo de [VAR01]
							// Movimentações WMS pendentes de saída de [VAR01]
							Self:cErro := WmsFmtMsg(STR0010,{{"[VAR01]",Self:oMovimento:oMovEndDes:GetEnder()}}) // O estorno não pode ser efetuado, pois o saldo do endereço [VAR01] está comprometido.
							Self:cErro += CRLF+WmsFmtMsg(STR0011,{{"[VAR01]",Transf((cAliasQry)->D0S_QUANT,PesqPictQt('D12_QTDMOV',14))}}) // Quantidade para estorno de [VAR01]
							If QtdComp(nQtdSldEnd) > 0
								Self:cErro += CRLF+WmsFmtMsg(STR0012,{{"[VAR01]",Transf(nQtdSldEnd,PesqPictQt('D12_QTDMOV',14))}}) // Endereço possui saldo de [VAR01]
							EndIf
							If oEstEnder:GetQtdSPr() > 0
								Self:cErro += CRLF+WmsFmtMsg(STR0013,{{"[VAR01]",Transf(oEstEnder:GetQtdSPr(),PesqPictQt('D12_QTDMOV',14))}}) // Movimentações WMS pendentes de saída de [VAR01]
							EndIf
						EndIf
					Else
						Self:cErro := oEstEnder:GetErro()
						lRet := .F.
					EndIf
					// Se for uma transferência de estorno e a origem for um picking ou produção não possui saldo por unitizador
					// Neste caso deve gerar as ordens de seviço como se fosse uma transferência parcial de produto
					If Self:oMovimento:oMovEndDes:GetTipoEst() == 2 .Or. Self:oMovimento:oMovEndDes:GetTipoEst() == 7 
						//Carrega as informações de produto temporariamente no movimento
						Self:oMovimento:oMovPrdLot:SetArmazem(oEstEnder:oProdLote:GetArmazem())
						Self:oMovimento:oMovPrdLot:SetPrdOri(oEstEnder:oProdLote:GetPrdOri() )
						Self:oMovimento:oMovPrdLot:SetProduto(oEstEnder:oProdLote:GetProduto())
						Self:oMovimento:oMovPrdLot:SetLoteCtl(oEstEnder:oProdLote:GetLoteCtl())
						Self:oMovimento:oMovPrdLot:SetNumLote(oEstEnder:oProdLote:GetNumLote())
						Self:oMovimento:oMovPrdLot:SetNumSer(oEstEnder:oProdLote:GetNumSer())
						Self:oRelacMov:SetQuant((cAliasQry)->D0S_QUANT)
						// Cria uma ordem de serviço auxiliar de devolução da mercadoria para a origem ou um novo endereço
						lRet := Self:RevGenDev(cSerTran)
						// Limpas as informações de produto do movimento novamente
						Self:oMovimento:oMovPrdLot:ClearData()
						Self:oRelacMov:SetQuant(1)
					EndIf
					(cAliasQry)->(DbSkip())
				EndDo
			Else
				Self:cErro := WmsFmtMsg(STR0020,{{"[VAR01]",Self:oMovimento:GetIdUnit()}}) // Não foi encontrado o saldo dos produtos recebidos no unitizador [VAR01].
				lRet := .F.
			EndIf
			(cAliasQry)->(DbCloseArea())
			If lRet .And. Self:oMovimento:oMovEndDes:GetTipoEst() != 2
				// Cria uma ordem de serviço auxiliar de devolução da mercadoria para a origem ou um novo endereço
				lRet := Self:RevGenDev(cSerTran)
			EndIf
		Else
			// Valida Saldo do endereco destino para permitir realizar a transferencia
			oEstEnder:ClearData()
			oEstEnder:oEndereco:SetArmazem(Self:oMovimento:oMovEndDes:GetArmazem())
			oEstEnder:oEndereco:SetEnder(Self:oMovimento:oMovEndDes:GetEnder())
			oEstEnder:oProdLote:SetArmazem(Self:oMovimento:oMovPrdLot:GetArmazem())
			oEstEnder:oProdLote:SetPrdOri(Self:oMovimento:oMovPrdLot:GetPrdOri() )
			oEstEnder:oProdLote:SetProduto(Self:oMovimento:oMovPrdLot:GetProduto())
			oEstEnder:oProdLote:SetLoteCtl(Self:oMovimento:oMovPrdLot:GetLoteCtl())
			oEstEnder:oProdLote:SetNumLote(Self:oMovimento:oMovPrdLot:GetNumLote())
			oEstEnder:oProdLote:SetNumSer(Self:oMovimento:oMovPrdLot:GetNumSer())
			// Caso endereço destino seja um picking ou seja a DOCA no processo de separação, limpa o unitizador destino do movimento
			If Self:oMovimento:DesNotUnit()
				oEstEnder:SetIdUnit("")
			Else
				If Self:oMovimento:oMovServic:ChkTransf()
					oEstEnder:SetIdUnit(Self:oMovimento:GetUniDes())
				Else
					oEstEnder:SetIdUnit(Self:oMovimento:GetIdUnit())
				EndIf
			EndIf
			oEstEnder:SetQuant(Self:oRelacMov:GetQuant())
			If lEmpenho .Or. lBloqueio
				// Retira o empenho do endereco destino
				If !oEstEnder:UpdSaldo('999',.F. /*lEstoque*/,.F. /*lEntPrev*/,.F. /*lSaiPrev*/,lEmpenho /*lEmpenho*/,lBloqueio /*lBloqueio*/)
					Self:cErro := oEstEnder:GetErro()
					lRet := .F.
				EndIf
			EndIf
			If lRet
				If oEstEnder:LoadData()
					nQtdSldEnd := oEstEnder:GetQtdEst()-(oEstEnder:GetQtdEmp()+oEstEnder:GetQtdBlq())
					// Se já existe uma movimentação de saída prevista, ou não tem mais saldo no endereço, não deixa estornar
					If QtdComp(nQtdSldEnd-oEstEnder:GetQtdSPr()) < QtdComp(Self:oRelacMov:GetQuant())
						lRet := .F.
						// O estorno não pode ser efetuado, pois o saldo do endereço [VAR01] está comprometido.
						// Quantidade para estorno de [VAR01]
						// Endereço possui saldo de [VAR01]
						// Movimentações WMS pendentes de saída de [VAR01]
						Self:cErro := WmsFmtMsg(STR0010,{{"[VAR01]",Self:oMovimento:oMovEndDes:GetEnder()}}) // O estorno não pode ser efetuado, pois o saldo do endereço [VAR01] está comprometido.
						Self:cErro += CRLF+WmsFmtMsg(STR0011,{{"[VAR01]",Transf(Self:oRelacMov:GetQuant(),PesqPictQt('D12_QTDMOV',14))}}) // Quantidade para estorno de [VAR01]
						If QtdComp(nQtdSldEnd) > 0
							Self:cErro += CRLF+WmsFmtMsg(STR0012,{{"[VAR01]",Transf(nQtdSldEnd,PesqPictQt('D12_QTDMOV',14))}}) // Endereço possui saldo de [VAR01]
						EndIf
						If oEstEnder:GetQtdSPr() > 0
							Self:cErro += CRLF+WmsFmtMsg(STR0013,{{"[VAR01]",Transf(oEstEnder:GetQtdSPr(),PesqPictQt('D12_QTDMOV',14))}}) // Movimentações WMS pendentes de saída de [VAR01]
						EndIf
					Else
						// Cria uma ordem de serviço auxiliar de devolução da mercadoria para a origem ou um novo endereço
						lRet := Self:RevGenDev(cSerTran)
					EndIf
				Else
					Self:cErro := oEstEnder:GetErro()
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf
	// Atualiza movimento corrente para estornado
	If lRet
		Self:oMovimento:SetStatus("0")
		Self:oMovimento:UpdateD12()
	EndIf
Return lRet
//------------------------------------------------------------------------------
METHOD RevMovPrev() CLASS WMSDTCOrdemServicoReverse
Local lRet       := .T.
Local lEmpPrev   := .F.
Local aTamSX3    := {}
Local oEstEnder  := Self:oMovimento:oEstEnder // Para facilitar o apontamento do objeto
Local cAliasQry  := Nil

	Self:oRelacMov:SetIdOrig(Self:oMovimento:GetIdDCF())
	Self:oRelacMov:SetIdDCF(Self:cIdDCF)
	Self:oRelacMov:SetSequen(Self:cSequen)
	Self:oRelacMov:SetIdMovto(Self:oMovimento:GetIdMovto())
	Self:oRelacMov:SetIdOpera(Self:oMovimento:GetIdOpera())
	If !Self:oRelacMov:LoadData()
		Self:cErro := Self:oRelacMov:GetErro()
		lRet := .F.
	EndIf

	If lRet .And. Self:oMovimento:IsUpdEst()
		lEmpPrev := Self:oMovimento:oMovServic:ChkSepara()
		If Self:oMovimento:IsMovUnit()
			// Se for uma transferência de estorno de endereçamento e a origem for um picking
			// Não possui saldo por unitizador, neste caso deve carregar o saldo inicial do unitizador
			If Self:oMovimento:oMovServic:ChkRecebi() .And. Self:oMovimento:oMovEndDes:GetTipoEst() == 2
				If Empty(Self:oOrdEndDes:GetEnder())
					cAliasQry := GetNextAlias()
					BeginSql Alias cAliasQry
						SELECT D0R.D0R_CODUNI,
								D0S.D0S_PRDORI,
								D0S.D0S_CODPRO,
								D0S.D0S_LOTECT,
								D0S.D0S_NUMLOT,
								D0S.D0S_QUANT
						FROM %Table:D0S% D0S
						INNER JOIN %Table:D0R% D0R 
						ON D0R.D0R_FILIAL = %xFilial:D0R%
						AND D0R.D0R_IDUNIT = D0S.D0S_IDUNIT
						AND D0R.%NotDel%
						INNER JOIN %Table:D0Q% D0Q
						ON D0Q.D0Q_FILIAL = %xFilial:D0Q%
						AND D0Q.D0Q_ID = D0S.D0S_IDD0Q
						AND D0Q.%NotDel%
						WHERE D0S.D0S_FILIAL = %xFilial:D0S%
						AND D0S.D0S_IDUNIT = %Exp:Self:oMovimento:GetIdUnit()%
						AND D0S.%NotDel%
					EndSql
					aTamSX3 := TamSx3("D0S_QUANT"); TcSetField(cAliasQry,'D0S_QUANT','N',aTamSX3[1],aTamSX3[2])
					If (cAliasQry)->(!Eof())
						Do While lRet .And. (cAliasQry)->(!Eof())
							// Realiza os estorno da quantidade entrada prevista
							oEstEnder:ClearData()
							oEstEnder:oEndereco:SetArmazem(Self:oMovimento:oMovEndDes:GetArmazem())
							oEstEnder:oEndereco:SetEnder(Self:oMovimento:oMovEndDes:GetEnder())
							oEstEnder:oProdLote:SetArmazem(Self:oMovimento:oMovPrdLot:GetArmazem())
							oEstEnder:oProdLote:SetPrdOri((cAliasQry)->D0S_PRDORI)
							oEstEnder:oProdLote:SetProduto((cAliasQry)->D0S_CODPRO)
							oEstEnder:oProdLote:SetLoteCtl((cAliasQry)->D0S_LOTECT)
							oEstEnder:oProdLote:SetNumLote((cAliasQry)->D0S_NUMLOT)
							oEstEnder:SetIdUnit("") // Picking não controla unitizador
							oEstEnder:SetTipUni("") // Picking não controla unitizador
							oEstEnder:SetQuant((cAliasQry)->D0S_QUANT)
							// Diminui entrada prevista
							If Self:oMovimento:oMovServic:GetTipo() $ "1|2|3"
								oEstEnder:oEndereco:SetArmazem(Self:oMovimento:oMovEndDes:GetArmazem())
								oEstEnder:oEndereco:SetEnder(Self:oMovimento:oMovEndDes:GetEnder())
								If !oEstEnder:UpdSaldo('999',.F. /*lEstoque*/,.T. /*lEntPrev*/,.F. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/)
									Self:cErro := oEstEnder:GetErro()
									lRet := .F.
								EndIf
							EndIf
							// Diminui saida prevista
							If lRet .And. (Self:oMovimento:oMovServic:GetTipo() == "2" .Or. (Self:oMovimento:oMovServic:GetTipo() == "3" .And. (Self:oMovimento:oOrdServ:ChkMovEst(.F.) .Or. !Self:oMovimento:ChkEndD0F())) )
								oEstEnder:oEndereco:SetArmazem(Self:oMovimento:oMovEndOri:GetArmazem())
								oEstEnder:oEndereco:SetEnder(Self:oMovimento:oMovEndOri:GetEnder())
								oEstEnder:SetIdUnit(Self:oMovimento:GetIdUnit())
								oEstEnder:SetTipUni((cAliasQry)->D0R_CODUNI)
								If !oEstEnder:UpdSaldo('999',.F. /*lEstoque*/,.F. /*lEntPrev*/,.T./*lSaiPrev*/,.F./*lEmpenho*/,.F. /*lBloqueio*/,lEmpPrev)
									Self:cErro := oEstEnder:GetErro()
									lRet := .F.
								EndIf
							EndIf
							(cAliasQry)->(DbSkip())
						EndDo
					Else
						Self:cErro := WmsFmtMsg(STR0020,{{"[VAR01]",Self:oMovimento:GetIdUnit()}}) // Não foi encontrado o saldo dos produtos recebidos no unitizador [VAR01].
						lRet := .F.
					EndIf
					(cAliasQry)->(DbCloseArea())
				EndIf
			Else
				cAliasQry := GetNextAlias()
				BeginSql Alias cAliasQry
					SELECT D14.D14_CODUNI,
							D14.D14_PRDORI,
							D14.D14_PRODUT,
							D14.D14_LOTECT,
							D14.D14_NUMLOT,
							D14.D14_NUMSER,
							D14.D14_QTDEPR
					FROM %Table:D14% D14
					WHERE D14.D14_FILIAL = %xFilial:D14%
					AND D14.D14_IDUNIT = %Exp:Self:oMovimento:GetUniDes()%
					AND D14.D14_LOCAL = %Exp:Self:oMovimento:oMovEndDes:GetArmazem()%
					AND D14.D14_ENDER = %Exp:Self:oMovimento:oMovEndDes:GetEnder()%
					AND D14.D14_QTDEPR > 0
					AND D14.%NotDel%
				EndSql
				aTamSX3 := TamSx3("D14_QTDEPR"); TcSetField(cAliasQry,'D14_QTDEPR','N',aTamSX3[1],aTamSX3[2])
				If (cAliasQry)->(!Eof())
					Do While lRet .And. (cAliasQry)->(!Eof())
						// Realiza os estorno da quantidade entrada prevista
						oEstEnder:ClearData()
						oEstEnder:oEndereco:SetArmazem(Self:oMovimento:oMovEndDes:GetArmazem())
						oEstEnder:oEndereco:SetEnder(Self:oMovimento:oMovEndDes:GetEnder())
						oEstEnder:oProdLote:SetArmazem(Self:oMovimento:oMovPrdLot:GetArmazem())
						oEstEnder:oProdLote:SetPrdOri((cAliasQry)->D14_PRDORI)
						oEstEnder:oProdLote:SetProduto((cAliasQry)->D14_PRODUT)
						oEstEnder:oProdLote:SetLoteCtl((cAliasQry)->D14_LOTECT)
						oEstEnder:oProdLote:SetNumLote((cAliasQry)->D14_NUMLOT)
						oEstEnder:oProdLote:SetNumSer((cAliasQry)->D14_NUMSER)
						// Caso endereço destino seja um picking ou seja a DOCA no processo de separação, limpa o unitizador destino do movimento
						If Self:oMovimento:DesNotUnit()
							oEstEnder:SetIdUnit("")
						Else
							If Self:oMovimento:oMovServic:ChkTransf()
								oEstEnder:SetIdUnit(Self:oMovimento:GetUniDes())
							Else
								oEstEnder:SetIdUnit(Self:oMovimento:GetIdUnit())
							EndIf
						EndIf
						oEstEnder:SetQuant((cAliasQry)->D14_QTDEPR)
						// Diminui entrada prevista
						If (Self:oMovimento:oMovServic:ChkSepara() .And. !Self:oMovimento:oOrdServ:ChkMovEst()) .Or. (!Self:oMovimento:oMovServic:ChkSepara() .And. !Self:oMovimento:oOrdServ:ChkMovEst(.F.)) .Or.  Self:oMovimento:oMovServic:ChkReabast()
							If Self:oMovimento:oMovServic:GetTipo() $ "1|2|3"
								oEstEnder:oEndereco:SetArmazem(Self:oMovimento:oMovEndDes:GetArmazem())
								oEstEnder:oEndereco:SetEnder(Self:oMovimento:oMovEndDes:GetEnder())
								If !oEstEnder:UpdSaldo('999',.F. /*lEstoque*/,.T. /*lEntPrev*/,.F. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/)
									Self:cErro := oEstEnder:GetErro()
									lRet := .F.
								EndIf
							EndIf
							// Diminui saida prevista
							If lRet .And. (Self:oMovimento:oMovServic:GetTipo() == "2" .Or. Self:oMovimento:oMovServic:ChkReabast() .Or. (Self:oMovimento:oMovServic:GetTipo() == "3" .And. (Self:oMovimento:oOrdServ:ChkMovEst(.F.) .Or. !Self:oMovimento:ChkEndD0F())))
								oEstEnder:oEndereco:SetArmazem(Self:oMovimento:oMovEndOri:GetArmazem())
								oEstEnder:oEndereco:SetEnder(Self:oMovimento:oMovEndOri:GetEnder())
								If !oEstEnder:UpdSaldo('999',.F. /*lEstoque*/,.F. /*lEntPrev*/,.T./*lSaiPrev*/,.F./*lEmpenho*/,.F. /*lBloqueio*/,lEmpPrev)
									Self:cErro := oEstEnder:GetErro()
									lRet := .F.
								EndIf
							EndIf
						EndIf
						(cAliasQry)->(dbSkip())
					EndDo
				Else
					Self:cErro := WmsFmtMsg(STR0019,{{"[VAR01]",Self:oMovimento:GetIdUnit()}}) // Não foi encontrado o saldo por endereço do unitizador [VAR01].
					lRet := .F.
				EndIf
				(cAliasQry)->(DbCloseArea())
			EndIf
		Else
			// Realiza os estorno da quantidade entrada prevista
			oEstEnder:ClearData()
			oEstEnder:oEndereco:SetArmazem(Self:oMovimento:oMovEndDes:GetArmazem())
			oEstEnder:oEndereco:SetEnder(Self:oMovimento:oMovEndDes:GetEnder())
			oEstEnder:oProdLote:SetArmazem(Self:oMovimento:oMovPrdLot:GetArmazem())
			oEstEnder:oProdLote:SetPrdOri(Self:oMovimento:oMovPrdLot:GetPrdOri())
			oEstEnder:oProdLote:SetProduto(Self:oMovimento:oMovPrdLot:GetProduto())
			oEstEnder:oProdLote:SetLoteCtl(Self:oMovimento:oMovPrdLot:GetLoteCtl())
			oEstEnder:oProdLote:SetNumLote(Self:oMovimento:oMovPrdLot:GetNumLote())
			oEstEnder:oProdLote:SetNumSer(Self:oMovimento:oMovPrdLot:GetNumSer())
			// Caso endereço destino seja um picking ou seja a DOCA no processo de separação, limpa o unitizador destino do movimento
			If Self:oMovimento:DesNotUnit()
				oEstEnder:SetIdUnit("")
			Else
				oEstEnder:SetIdUnit(Self:oMovimento:GetUniDes())
			EndIf
			oEstEnder:SetQuant(Self:oRelacMov:GetQuant())
			// Diminui entrada prevista
			If (Self:oMovimento:oMovServic:ChkSepara() .And. !Self:oMovimento:oOrdServ:ChkMovEst()) .Or. (!Self:oMovimento:oMovServic:ChkSepara() .And. !Self:oMovimento:oOrdServ:ChkMovEst(.F.)) .Or.  Self:oMovimento:oMovServic:ChkReabast()
				If Self:oMovimento:oMovServic:GetTipo() $ "1|2|3"
					oEstEnder:oEndereco:SetArmazem(Self:oMovimento:oMovEndDes:GetArmazem())
					oEstEnder:oEndereco:SetEnder(Self:oMovimento:oMovEndDes:GetEnder())
					If !oEstEnder:UpdSaldo('999',.F. /*lEstoque*/,.T. /*lEntPrev*/,.F. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/)
						Self:cErro := oEstEnder:GetErro()
						lRet := .F.
					EndIf
				EndIf
				// Diminui saida prevista
				If lRet .And. (Self:oMovimento:oMovServic:GetTipo() == "2" .Or. Self:oMovimento:oMovServic:ChkReabast() .Or. (Self:oMovimento:oMovServic:GetTipo() == "3" .And. (Self:oMovimento:oOrdServ:ChkMovEst(.F.) .Or. !Self:oMovimento:ChkEndD0F())) )
					oEstEnder:oEndereco:SetArmazem(Self:oMovimento:oMovEndOri:GetArmazem())
					oEstEnder:oEndereco:SetEnder(Self:oMovimento:oMovEndOri:GetEnder())
					// Caso endereço origem seja um picking ou produção, limpa o unitizador destino do movimento
					If Self:oMovimento:oMovEndOri:GetTipoEst() == 2 .Or. Self:oMovimento:oMovEndOri:GetTipoEst() == 7 
						oEstEnder:SetIdUnit("")
					Else
						oEstEnder:SetIdUnit(Self:oMovimento:GetIdUnit())
					EndIf
					If !oEstEnder:UpdSaldo('999',.F. /*lEstoque*/,.F. /*lEntPrev*/,.T./*lSaiPrev*/,.F./*lEmpenho*/,.F. /*lBloqueio*/,lEmpPrev)
						Self:cErro := oEstEnder:GetErro()
						lRet := .F.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	If lRet
		Self:oRelacMov:DeleteDCR()
		If QtdComp(Self:oMovimento:GetQtdMov() - Self:oRelacMov:GetQuant()) == QtdComp(0)
			Self:oMovimento:DeleteD12()
		Else
			If !Self:oMovimento:ReverseAgl(Self:oRelacMov)
				Self:cErro := Self:oMovimento:GetErro()
				lRet := .F.
			EndIf
		EndIf
	EndIf
Return lRet
//------------------------------------------------------------------------------
METHOD RevGenDev(cSerTran) CLASS WMSDTCOrdemServicoReverse
Local lRet       := .T.
Local lDesUnit   := WmsArmUnit(Self:oMovimento:oMovEndDes:GetArmazem())
Local oEtiqUnit  := Nil
Local oMovAux    := WMSDTCMovimentosServicoArmazem():New()
Local oOrdSerAux := WMSDTCOrdemServicoCreate():New()
	// Verifica se ha documento
	oOrdSerAux:SetIdDCF(Self:cIdDCF)
	oOrdSerAux:SetDocto(oOrdSerAux:FindDocto())
	oOrdSerAux:SetIdDCF("")
	oOrdSerAux:SetNumSeq("")
	If !Self:oMovimento:IsMovUnit()
		oOrdSerAux:oProdLote:SetArmazem(Self:oMovimento:oMovEndDes:GetArmazem())
		oOrdSerAux:oProdLote:SetProduto(Self:oMovimento:oMovPrdLot:GetProduto())
		oOrdSerAux:oProdLote:SetPrdOri(Self:oMovimento:oMovPrdLot:GetPrdOri())
		oOrdSerAux:oProdLote:SetLoteCtl(Self:oMovimento:oMovPrdLot:GetLoteCtl())
		oOrdSerAux:oProdLote:SetNumLote(Self:oMovimento:oMovPrdLot:GetNumLote())
		oOrdSerAux:oProdLote:SetNumSer(Self:oMovimento:oMovPrdLot:GetNumSer())
		// Carrega as informações do produto/Lote
		oOrdSerAux:oProdLote:LoadData()
	EndIf
	oOrdSerAux:oServico:SetServico(cSerTran)
	If oOrdSerAux:oServico:LoadData() .And. !oOrdSerAux:oServico:ChkTransf()
		Self:cErro := WmsFmtMsg(STR0023,{{"[VAR01]",oOrdSerAux:oServico:GetServico()}}) // Serviço [VAR01] configurado para o produto não é de transferência.
		lRet := .F.
	EndIf
	If lRet	
		oOrdSerAux:oOrdEndOri:SetArmazem(Self:oMovimento:oMovEndDes:GetArmazem())
		oOrdSerAux:oOrdEndOri:SetEnder(Self:oMovimento:oMovEndDes:GetEnder())
		// Verifica capacidade do endereço destino
		// se não houver espaco realiza um endereçamento colocando o endereço destino vazio
		// Faz uma referência dos objetos para a nova classe (Temporário)
		oMovAux:oMovPrdLot := Self:oMovimento:oMovPrdLot
		oMovAux:oMovServic := Self:oMovimento:oMovServic
		oMovAux:SetIdUnit(Self:oMovimento:GetUniDes()) // Id Unitizador
		oMovAux:SetUniDes(Self:oMovimento:GetIdUnit())
		oMovAux:SetTipUni(Self:oMovimento:GetTipUni())
		oMovAux:SetQuant(Self:oRelacMov:GetQuant())
		
		oMovAux:oMovEndOri:SetArmazem(Self:oMovimento:oMovEndDes:GetArmazem())
		oMovAux:oMovEndOri:SetEnder(Self:oMovimento:oMovEndDes:GetEnder())
		// Não refaz o cálculo da consulta de saldo do endereço
		If !oMovAux:ChkEndOri(/*lConsMov*/,/*lMovEst*/,.F.)
			Self:cErro := oMovAux:GetErro()
			lRet := .F.
		EndIf
	EndIf
	If lRet
		oMovAux:oMovEndDes:SetArmazem(Self:oMovimento:oMovEndOri:GetArmazem())
		oMovAux:oMovEndDes:SetEnder(Self:oMovimento:oMovEndOri:GetEnder())
		If !oMovAux:ChkEndDes()
			If Self:oMovimento:oMovServic:ChkRecebi() .Or. (Self:oMovimento:oOrdServ:GetOrigem() $ 'SC9|SD4' .And. !Empty(Self:oMovimento:oOrdServ:oOrdEndOri:GetEnder()))
				Self:cErro := oMovAux:GetErro()
				lRet := .F.
			Else
				oOrdSerAux:oOrdEndDes:SetArmazem(oMovAux:oMovEndDes:GetArmazem())
				// Limpa o endereço destino para que o endereçamento encontre um substituto
				oOrdSerAux:oOrdEndDes:SetEnder("")
				
				// Sempre gera um código de unitizador novo, para evitar utilizar o mesmo 
				// unitizador em endereços diferentes quando o mesmo for misto e para não 
				// deixar o unitizador em branco na DCF quando endereço original for picking
				If lDesUnit
					oOrdSerAux:SetUniDes(WmsGerUnit())
				EndIf
			EndIf
		Else
			oOrdSerAux:oOrdEndDes:SetArmazem(oMovAux:oMovEndDes:GetArmazem())
			oOrdSerAux:oOrdEndDes:SetEnder(oMovAux:oMovEndDes:GetEnder())
			oOrdSerAux:SetUniDes(oMovAux:GetUniDes())
		EndIf
	EndIf
	// Se o destino da movimentação não era unitizado, não deve gravar o unitizador origem na ordem de serviço
	If Self:oMovimento:DesNotUnit()
		oOrdSerAux:SetIdUnit("")
	Else
		oOrdSerAux:SetIdUnit(oMovAux:GetIdUnit())
	EndIf
	// Sempre busca o tipo do unitizador da etiqueta quando o armazém é unitizado
	If lDesUnit
		If Self:oMovimento:oMovServic:ChkSepara()
			oEtiqUnit := WMSDTCEtiquetaUnitizador():New()
			oEtiqUnit:SetIdUnit(oOrdSerAux:GetUniDes()) // Unitizador Destino
			If oEtiqUnit:LoadData()
				oOrdSerAux:SetTipUni(oEtiqUnit:GetTipUni())
			EndIf
		Else
			If !Self:oMovimento:DesNotUnit()
				oEtiqUnit := WMSDTCEtiquetaUnitizador():New()
				oEtiqUnit:SetIdUnit(oOrdSerAux:GetIdUnit()) // Unitizador Origem
				If oEtiqUnit:LoadData()
					oOrdSerAux:SetTipUni(oEtiqUnit:GetTipUni())
				EndIf
			EndIf
		EndIf
	EndIf
	// Retira as referências dos objetos
	oMovAux:oMovPrdLot := Nil
	oMovAux:oMovServic := Nil
	oMovAux:Destroy()
	If lRet
		// Demais informações
		oOrdSerAux:SetQuant(Self:oRelacMov:GetQuant())
		oOrdSerAux:SetIdOrig(Self:oRelacMov:GetIdDCF())
		oOrdSerAux:SetIdMovOr(Self:oMovimento:GetIdMovto())
		// Cria nova ordem de serviço para a quantidade estornada devolvendo para o endereço origem
		If !(Self:oMovimento:oMovEndDes:GetArmazem() == Self:oMovimento:oMovEndOri:GetArmazem())
			oOrdSerAux:SetOrigem("DH1")
			// Criação da DH1
			// Passa a referência da OS para a função
			WmsOrdSer(oOrdSerAux)
			lRet := WmsGeraDH1("WMSA225")
		Else
			oOrdSerAux:SetOrigem("DCF")
		EndIf
		If lRet
			// Criação da DCF
			If !oOrdSerAux:CreateDCF()
				lRet := .F.
				Self:cErro := oOrdSerAux:GetErro()
			Else
				// Copiando as DCFs para o array do objeto atual
				AEval(oOrdSerAux:aLibDCF,{|x| AAdd(Self:aLibDCF,x)})
			EndIf
		EndIf
	EndIf
Return lRet
/*----------------------------------------------------------------------
---CanEstPed
---Método utilizado no estorno do pedido pelo MATA461 que validade se pode
---ser estornado dependendo do status da ordem de serviço
---felipe.m 22/04/2016
----------------------------------------------------------------------*/
METHOD CanEstPed() CLASS WMSDTCOrdemServicoReverse
Local lRet := .T.
Local oOrdSerDel := Nil
	// 0=Estornado;1=Nao Executado;2=Interrompido;3=Executado;4=Bloqueado
	Do Case
		// Ao estornar o pedido pedo faturamento, precisa verificar qual o status da DCF
		// para decidir se pode delete ou se pode estornar
		Case Self:GetStServ() $ "0|1|4"
			oOrdSerDel := WMSDTCOrdemServicoDelete():New()
			oOrdSerDel:SetIdDCF(Self:GetIdDCF())
			oOrdSerDel:LoadData()
			If !(lRet := oOrdSerDel:CanDelete())
				Self:cErro := oOrdSerDel:GetErro()
			EndIf
			oOrdSerDel:Destroy()

		Case Self:GetStServ() $ "2|3"
			lRet := Self:CanReverse()
		Otherwise
			lRet := Self:CanReverse()
	EndCase
Return lRet

METHOD RevEmpSD4() CLASS WMSDTCOrdemServicoReverse
Local lRet      := .T.
Local lMovEst   := .F.
Local lBaixaEst := .F.
Local oEstEnder := WMSDTCEstoqueEndereco():New()
Local oOrdSerAux:= Nil
Local cAliasQry := Nil
Local cAliasD12 := Nil
Local cAliasSD3 := Nil
Local cAliasDH1 := Nil
Local cOp       := ""
Local cTrt      := ""
Local nQtdReq   := 0
Local nRecnoSD4 := 0
	// Caso haja transferência entre armazéns apaga as movimentações internas WMS
	// para serem regeradas com o ajuste das requisições
	If !(Self:oOrdEndOri:GetArmazem() == Self:oOrdEndDes:GetArmazem())
		cAliasDH1 := GetNextAlias()
		BeginSql Alias cAliasDH1
			SELECT DH1.R_E_C_N_O_ RECNODH1
			FROM %Table:DH1% DH1
			WHERE DH1.DH1_FILIAL = %xFilial:DH1%
			AND DH1.DH1_IDDCF = %Exp:Self:GetIdDCF()%
			AND DH1.%NotDel%
		EndSql
		Do While (cAliasDH1)->(!Eof())
			DH1->(dbGoTo((cAliasDH1)->RECNODH1))
			RecLock("DH1",.F.)
			DH1->(dbDelete())
			DH1->(MsUnlock())
			(cAliasDH1)->(dbSkip())
		EndDo
		(cAliasDH1)->(dbCloseArea())
	EndIf
	// busca requisições
	cAliasQry  := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT SD4.R_E_C_N_O_ RECNOSD4
		FROM %Table:SD4% SD4
		WHERE SD4.D4_FILIAL = %xFilial:SD4%
		AND SD4.D4_IDDCF = %Exp:Self:GetIdDCF()%
		AND SD4.D4_QTDEORI > 0
		AND SD4.%NotDel%
	EndSql
	If (cAliasQry)->(!Eof())
		nRecnoSD4 := (cAliasQry)->RECNOSD4
		// Ajusta empenhos e reservas para quando regerar
		// Após ajustes na requisição
		Do While lRet .And. (cAliasQry)->(!Eof())
			SD4->(dbGoTo((cAliasQry)->RECNOSD4))
			// Verifica se parametrizado para baixa de requisição no serviço
			// Se baixa requisição deverá dar entrada do saldo no estoque,
			// empenhar novamente a quantidade e atualizar a quantidade no empenho
			cAliasD12  := GetNextAlias()
			BeginSql Alias cAliasD12
				SELECT DISTINCT D12.D12_BXESTO
				FROM %Table:DCR% DCR
				INNER JOIN %Table:D12% D12
				ON D12.D12_FILIAL = %xFilial:D12%
				AND D12.D12_IDDCF = DCR.DCR_IDORI
				AND D12.D12_IDMOV = DCR.DCR_IDMOV
				AND D12.D12_IDOPER = DCR.DCR_IDOPER
				AND D12.D12_STATUS = '1'
				AND D12.%NotDel%
				WHERE DCR.DCR_FILIAL = %xFilial:DCR%
				AND DCR.DCR_IDDCF  = %Exp:Self:cIdDCF%
				AND DCR.DCR_SEQUEN = %Exp:Self:cSequen%
				AND DCR.%NotDel%
			EndSql
			If (cAliasD12)->(!Eof())
				lMovEst := .T.
				If (cAliasD12)->D12_BXESTO == '1'
					lBaixaEst := .T.
					// Dados requisição
					RecLock("SD4", .F.)
					SD4->D4_QUANT := SD4->D4_QTDEORI
					SD4->(MsUnlock())
					// Estorna movimento SD3 - Somente se foi movimentado tudo
					cAliasSD3  := GetNextAlias()
					BeginSql Alias cAliasSD3
						SELECT SD3.D3_DOC,
								SD3.D3_NUMSEQ
						FROM %Table:SD3% SD3
						WHERE SD3.D3_FILIAL = %xFilial:SD3%
						AND SD3.D3_DOC = %Exp:Self:cDocumento%
						AND SD3.D3_OP = %Exp:SD4->D4_OP%
						AND SD3.D3_TRT = %Exp:SD4->D4_TRT%
						AND SD3.D3_IDDCF = %Exp:SD4->D4_IDDCF%
						AND SD3.D3_ESTORNO <> 'S'
						AND SD3.%NotDel%
					EndSql
					Do While lRet .And. (cAliasSD3)->(!Eof())
						lRet := Self:EstMovSD3((cAliasSD3)->D3_DOC,(cAliasSD3)->D3_NUMSEQ)
						(cAliasSD3)->(dbSkip())
					EndDo
					(cAliasSD3)->(dbCloseArea())
					If lRet
						// Carrega dados para Estoque por Endereço
						oEstEnder:ClearData()
						oEstEnder:oEndereco:SetArmazem(Self:oOrdEndDes:GetArmazem())
						oEstEnder:oEndereco:SetEnder(Self:oOrdEndDes:GetEnder())
						oEstEnder:oProdLote:SetArmazem(Self:oProdLote:GetArmazem()) // Armazem
						oEstEnder:oProdLote:SetPrdOri(Self:oProdLote:GetPrdOri())   // Produto Origem
						oEstEnder:oProdLote:SetProduto(Self:oProdLote:GetProduto()) // Componente
						oEstEnder:oProdLote:SetLoteCtl(SD4->D4_LOTECTL)             // Lote do produto principal que deverá ser o mesmo no componentes
						oEstEnder:oProdLote:SetNumLote(SD4->D4_NUMLOTE)             // Sub-Lote do produto principal que deverá ser o mesmo no componentes
						oEstEnder:oProdLote:SetNumSer(Self:oProdLote:GetNumSer())   // Numero de serie
						oEstEnder:SetQuant(SD4->D4_QUANT)
						// Seta o bloco de código para informações do documento
						oEstEnder:SetBlkDoc({|oMovEstEnd|;
							oMovEstEnd:SetOrigem(Self:cOrigem),;
							oMovEstEnd:SetDocto(Self:cDocumento),;
							oMovEstEnd:SetSerie(Self:cSerie),;
							oMovEstEnd:SetCliFor(Self:cCliFor),;
							oMovEstEnd:SetLoja(Self:cLoja),;
							oMovEstEnd:SetNumSeq(Self:cNumSeq),;
							oMovEstEnd:SetIdDCF(Self:cIdDCF);
						})
						// Seta o bloco de código para informações do movimento
						oEstEnder:SetBlkMov({|oMovEstEnd|;
							oMovEstEnd:SetIdMovto(""),;
							oMovEstEnd:SetIdOpera("");
						})
						// Realiza Entrada Armazem Estoque por Endereço
						If !oEstEnder:UpdSaldo('499',.T. /*lEstoque*/,.F. /*lEntPrev*/,.F. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/,.F./*lEmpPrev*/,.T./*lMovEstEnd*/)
							Self:cErro := oEstEnder:GetErro()
							lRet := .F.
						EndIf
					EndIf
				Else
					If Self:oProdLote:HasRastro() .And. Empty(Self:oProdLote:GetLoteCtl())
						// Atualiza saldo por lote
						lRet := Self:UpdEmpSB8("-",;
												SD4->D4_COD,;
												SD4->D4_LOCAL,; // Armazem destino
												SD4->D4_LOTECTL,;
												SD4->D4_NUMLOTE,;
												SD4->D4_QUANT)
					EndIf
					If lRet
						// Carrega dados para Estoque por Endereço
						oEstEnder:ClearData()
						oEstEnder:oEndereco:SetArmazem(Self:oOrdEndDes:GetArmazem())
						oEstEnder:oEndereco:SetEnder(Self:oOrdEndDes:GetEnder())
						oEstEnder:oProdLote:SetArmazem(Self:oProdLote:GetArmazem()) // Armazem
						oEstEnder:oProdLote:SetPrdOri(Self:oProdLote:GetPrdOri())   // Produto Origem
						oEstEnder:oProdLote:SetProduto(Self:oProdLote:GetProduto()) // Componente
						oEstEnder:oProdLote:SetLoteCtl(SD4->D4_LOTECTL)             // Lote do produto principal que deverá ser o mesmo no componentes
						oEstEnder:oProdLote:SetNumLote(SD4->D4_NUMLOTE)             // Sub-Lote do produto principal que deverá ser o mesmo no componentes
						oEstEnder:oProdLote:SetNumSer(Self:oProdLote:GetNumSer())   // Numero de serie
						oEstEnder:SetQuant(SD4->D4_QUANT)
						// Realiza Entrada Armazem Estoque por Endereço
						lRet := oEstEnder:UpdSaldo('999',.F. /*lEstoque*/,.F. /*lEntPrev*/,.F. /*lSaiPrev*/,.T. /*lEmpenho*/,.F. /*lBloqueio*/,.F./*lEmpPrev*/,.F./*lMovEstEnd*/)
					EndIf
				EndIf
			Else
				If lRet
					If Self:oProdLote:HasRastro() .And. Empty(Self:oProdLote:GetLoteCtl())
						// Atualiza saldo por lote
						lRet := Self:UpdEmpSB8("-",;
												SD4->D4_COD,;
												Self:oOrdEndOri:GetArmazem(),; // Armazem origem
												SD4->D4_LOTECTL,;
												SD4->D4_NUMLOTE,;
												SD4->D4_QUANT)
					EndIf
					If lRet
						// Retira a reserva da SB2 da quantidade cancelada
						Self:UpdEmpSB2("-",Self:oProdLote:GetPrdOri(),Self:oOrdEndOri:GetArmazem(),Self:GetQuant())
					EndIf
				EndIf
			EndIf
			// Baixar SDC e ajustar SD4
			If lRet
				// Atualiza SD4
				lRet := WmsAtuSD4(SD4->D4_LOCAL,; // Armazem destino
									SD4->D4_COD,;
									SD4->D4_LOTECTL,;
									SD4->D4_NUMLOTE,;
									Nil,;
									Self:oOrdEndDes:GetEnder(),;
									SD4->D4_QUANT,;
									SD4->D4_IDDCF,;
									.T.,;
									!Empty(Self:oProdLote:GetLoteCtl()))
			EndIf
			If lRet
				If Self:oProdLote:HasRastro() .And. Empty(Self:oProdLote:GetLoteCtl())
					// Dados requisição
					RecLock("SD4", .F.)
					SD4->D4_LOTECTL := ""
					SD4->D4_NUMLOTE := ""
					SD4->D4_DTVALID := CtoD('  /  /  ')
					SD4->(MsUnlock())
				EndIf
				nQtdReq += SD4->D4_QUANT
			EndIf
			(cAliasD12)->(dbCloseArea())
			(cAliasQry)->(dbSkip())
		EndDo
	EndIf
	(cAliasQry)->(dbCloseArea())
	// Cria empenho para quantidade à maior
	If lRet .And. QtdComp(Self:GetQuant()) <> QtdComp(nQtdReq)
		cAliasQry  := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT SD4.R_E_C_N_O_ RECNOSD4
			FROM %Table:SD4% SD4
			WHERE SD4.D4_FILIAL = %xFilial:SD4%
			AND SD4.D4_IDDCF = %Exp:Self:GetIdDCF()%
			AND SD4.D4_QTDEORI = 0
			AND SD4.%NotDel%
		EndSql
		If (cAliasQry)->(!Eof())
			If Self:oProdLote:HasRastro() .And. Empty(Self:oProdLote:GetLoteCtl())
				Do While lRet .And. (cAliasQry)->(!Eof())
					SD4->(dbGoTo((cAliasQry)->RECNOSD4))
					// Atualiza empenho
					// Atualiza saldo por lote
					lRet := Self:UpdEmpSB8("-",;
											SD4->D4_COD,;
											Self:oOrdEndOri:GetArmazem(),;
											SD4->D4_LOTECTL,;
											SD4->D4_NUMLOTE,;
											SD4->D4_QUANT)
					//Atualiza registro corrente para quantidade lida no coletor
					RecLock("SD4", .F.)
					SD4->D4_LOTECTL := ""
					SD4->D4_NUMLOTE := ""
					SD4->D4_DTVALID := CtoD('  /  /  ')
					SD4->(MsUnlock())
					(cAliasQry)->(dbSkip())
				EndDo
				(cAliasQry)->(dbCloseArea())
			EndIf
		Else
			// Ajusta primeira SD4
			SD4->(dbGoTo(nRecnoSD4))
			cOp     := SD4->D4_OP
			cTrt := Soma1(StaticCall(WMSXFUNJ,WMaxTrtSD4,SD4->D4_OP,SD4->D4_COD))
			GravaEmp(SD4->D4_COD,;                 // Produto
						SD4->D4_LOCAL,;           // Armazem
						Self:GetQuant() - nQtdReq,; // Quantidade
						Nil,;                     // Quantidade 2 UM
						Self:oProdLote:GetLoteCtl(),; // Lote
						Self:oProdLote:GetNumLote(),; // Sub-Lote
						Nil,; // Endereço
						Nil,; // Número de série
						cOp,; // Ordem de produção
						cTrt,; // Trt Op
						Nil,; // Pedido
						Nil,; // Seq. Pedido
						'SD4',; // Origem
						Nil,; // Op Origem
						Nil,; // Data Entrega
						Nil,; // aTravas
						Nil,; // Estorno
						Nil,; // Projeto
						.F.,; // Empenha SB2
						.T.,; // Grava SD4
						Nil,; // Consulta Vencidos
						.F.,; // Empenha SB8/SBF
						Nil,; // Cria SDC
						Nil,; // Encerra Op
						Nil,; // IdDCF
						Nil,; // aSalvCols
						Nil,; // nSG1
						Nil,; // OpEncer
						Nil,; // TpOp 
						Nil,; // CAT83
						Nil,; // Data Emissão
						Nil,; // Grava Lote
						Nil) // aSDC
			// Busca requisição gerada para quantidade à maior
			If lRet
				SD4->(dbSetOrder(1))
				If SD4->(dbSeek(xFilial("SD4")+SD4->D4_COD+cOp+cTrt+Self:oProdLote:GetLoteCtl()+Self:oProdLote:GetNumLote()))
					RecLock('SD4',.F.)
					SD4->D4_QTDEORI := 0
					SD4->D4_DATA    := dDatabase
					SD4->D4_IDDCF   := Self:GetIdDCF()
					SD4->(MsUnLock())
				EndIf
			EndIf
		EndIf
	EndIf
	// Quando transferência entre armazém gera movimentos internos WMS
	cAliasQry  := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT SD4.R_E_C_N_O_ RECNOSD4
		FROM %Table:SD4% SD4
		WHERE SD4.D4_FILIAL = %xFilial:SD4%
		AND SD4.D4_IDDCF = %Exp:Self:GetIdDCF()%
		AND SD4.%NotDel%
	EndSql
	If (cAliasQry)->(!Eof())
		oOrdSerAux := WMSDTCOrdemServico():New()
		oOrdSerAux:SetIdDCF(Self:GetIdDCF())
		If oOrdSerAux:LoadData()
			// Gera empenhos no saldo do produto (SB2) e saldo por lote (SB8)
			// Quando há transferência entre armazéns gera movimentos internos WMS (DH1)
			Do While lRet .And. (cAliasQry)->(!Eof())
				SD4->(dbGoTo((cAliasQry)->RECNOSD4))
				// Ajusta movimento interno WMS (DH1) conforme a requisição 
				If !(Self:oOrdEndOri:GetArmazem() == Self:oOrdEndDes:GetArmazem())
					oOrdSerAux:SetOp(SD4->D4_OP)
					oOrdSerAux:SetTrt(SD4->D4_TRT)
					oOrdSerAux:SetQuant(SD4->D4_QUANT)
					// Passa a referência da OS para a função
					WmsOrdSer(oOrdSerAux)
					lRet := WmsGeraDH1("WMSDTCOrdemServicoReverse",.T.,.F.)
				EndIf
				// Atualiza quantidade empenho de acordo com a quantidade requisitada
				If lBaixaEst .And. SD4->D4_QTDEORI > 0
					GravaEmp(SD4->D4_COD,;            // Produto
							SD4->D4_LOCAL,;           // Armazem
							SD4->D4_QUANT,;           // Quantidade
							Nil,;                     // Quantidade 2 UM
							SD4->D4_LOTECTL,;         // Lote
							SD4->D4_NUMLOTE,;         // Sub-Lote
							Nil,;                     // Endereço
							Nil,;                     // Número de série
							SD4->D4_OP,;              // Ordem de produção
							SD4->D4_TRT,;             // Trt Op
							Nil,;                     // Pedido
							Nil,;                     // Seq. Pedido
							'SD4',;                   // Origem
							Nil,;                     // Op Origem
							Nil,;                     // Data Entrega
							Nil,;                     // aTravas
							.F.,;                     // Estorno
							Nil,;                     // Projeto
							.T.,;                     // Empenha SB2
							.F.,;                     // Grava SD4
							Nil,;                     // Consulta Vencidos
							.F.,;                     // Empenha SB8/SBF
							Nil,;                     // Cria SDC
							Nil,;                     // Encerra Op
							Nil,;                     // IdDCF
							Nil,;                     // aSalvCols
							Nil,;                     // nSG1
							Nil,;                     // OpEncer
							Nil,;                     // TpOp
							Nil,;                     // CAT83
							Nil,;                     // Data Emissão
							Nil,;                     // Grava Lote
							Nil)                      // aSDC
				EndIf
				(cAliasQry)->(dbSkip())
			EndDo
		EndIf
		oOrdSerAux:Destroy()
	EndIf
	(cAliasQry)->(dbCloseArea())
	oEstEnder:Destroy()
Return lRet
//--------------------------------------------------
/*/{Protheus.doc} MakeEstSD3
Atualiza SD3 liberação requisição
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//--------------------------------------------------
METHOD MakeEstSD3() CLASS WMSDTCOrdemServicoReverse
Local lRet       := .T.
Local aAreaAnt   := GetArea()
Local aTamSX3    := TamSx3("DCR_QUANT")
Local oEstEnder  := Nil
Local cAliasD12  := Nil
	// Alteração do status do DH1 para Pendente
	DH1->(dbSetOrder(2)) //DH1_FILIAL+DH1_DOC+DH1_NUMSEQ
	DH1->(dbSeek(xFilial("DH1")+Self:cDocumento+Self:cNumSeq)) //DH1_FILIAL+DH1_DOC+DH1_NUMSEQ
	Do While DH1->(!Eof()) .And. xFilial("DH1")+Self:cDocumento+Self:cNumSeq == DH1->(DH1_FILIAL+DH1_DOC+DH1_NUMSEQ)
		RecLock('DH1', .F.)
		DH1->DH1_STATUS := "1" // Pendente
		DH1->(MsUnLock())
		DH1->(dbSkip())
	EndDo

	// Atualiza movimentos WMS
	cAliasD12 := GetNextAlias()
	BeginSql Alias cAliasD12
		SELECT D12.D12_PRODUT,
				D12.D12_LOTECT,
				D12.D12_NUMLOT,
				D12.D12_NUMSER,
				SUM(DCR.DCR_QUANT) DCR_QUANT
		FROM %Table:DCR% DCR
		INNER JOIN %Table:D12% D12
		ON D12.D12_FILIAL = %xFilial:D12%
		AND D12.D12_SERVIC = %Exp:Self:oServico:GetServico()%
		AND D12.D12_PRDORI = %Exp:Self:oProdLote:GetProduto()%
		AND D12.D12_SEQUEN = DCR.DCR_SEQUEN
		AND D12.D12_IDDCF = DCR.DCR_IDORI
		AND D12.D12_IDMOV = DCR.DCR_IDMOV
		AND D12.D12_IDOPER = DCR.DCR_IDOPER
		AND D12.%NotDel%
		AND D12.D12_ORDTAR = %Exp:Self:oServico:GetOrdem()% // Assume a tarefa exatamante anterior
		AND D12.D12_ORDMOV IN ('3','4')
		AND D12.D12_BXESTO = '1' // Somente se baixa estoque
		AND NOT EXISTS (SELECT 1
						FROM %Table:D12% D12E
						WHERE D12E.D12_FILIAL = %xFilial:D12%
						AND D12E.D12_IDDCF = DCR.DCR_IDORI
						AND D12E.D12_SERVIC = D12.D12_SERVIC
						AND D12E.D12_TAREFA = D12.D12_TAREFA
						AND D12E.D12_ORDATI = D12.D12_ORDATI
						AND D12E.D12_STATUS IN ('4','3','2','-')
						AND D12E.%NotDel% )
		WHERE DCR.DCR_FILIAL = %xFilial:DCR%
		AND DCR.DCR_IDDCF = %Exp:Self:GetIdDCF()%
		AND DCR.DCR_SEQUEN = %Exp:Self:GetSequen()%
		AND DCR.%NotDel%
		GROUP BY D12.D12_PRODUT,
					D12.D12_LOTECT,
					D12.D12_NUMLOT,
					D12.D12_NUMSER
		ORDER BY D12.D12_PRODUT,
					D12.D12_LOTECT,
					D12.D12_NUMLOT
	EndSql
	TcSetField(cAliasD12,'DCR_QUANT','N',aTamSX3[1],aTamSX3[2])
	If (cAliasD12)->(!Eof())
		lRet := Self:EstMovSD3(Self:cDocumento,Self:cNumSeq)
		If lRet
			oEstEnder := WMSDTCEstoqueEndereco():New()
		EndIf
	EndIf
	If lRet
		Do While (cAliasD12)->(!Eof())
			// Atualiza Saldo
			// Carrega dados para Estoque por Endereço
			oEstEnder:oEndereco:SetArmazem(Self:oOrdEndDes:GetArmazem() )
			oEstEnder:oEndereco:SetEnder(Self:oOrdEndDes:GetEnder() )
			oEstEnder:oProdLote:SetArmazem(Self:oProdLote:GetArmazem())
			oEstEnder:oProdLote:SetPrdOri(Self:oProdLote:GetPrdOri()) // Produto Origem
			oEstEnder:oProdLote:SetProduto((cAliasD12)->D12_PRODUT )  // Componente
			oEstEnder:oProdLote:SetLoteCtl((cAliasD12)->D12_LOTECT )  // Lote do produto principal que deverá ser o mesmo no componentes
			oEstEnder:oProdLote:SetNumLote((cAliasD12)->D12_NUMLOT )  // Sub-Lote do produto principal que deverá ser o mesmo no componentes
			oEstEnder:oProdLote:SetNumSer((cAliasD12)->D12_NUMSER )   // Numero de serie
			oEstEnder:SetQuant((cAliasD12)->DCR_QUANT )
			// Seta o bloco de código para informações do documento
			oEstEnder:SetBlkDoc({|oMovEstEnd|;
				oMovEstEnd:SetOrigem(Self:cOrigem),;
				oMovEstEnd:SetDocto(Self:cDocumento),;
				oMovEstEnd:SetSerie(Self:cSerie),;
				oMovEstEnd:SetCliFor(Self:cCliFor),;
				oMovEstEnd:SetLoja(Self:cLoja),;
				oMovEstEnd:SetNumSeq(Self:cNumSeq),;
				oMovEstEnd:SetIdDCF(Self:cIdDCF);
			})
			// Seta o bloco de código para informações do movimento
			oEstEnder:SetBlkMov({|oMovEstEnd|;
				oMovEstEnd:SetIdMovto(""),;
				oMovEstEnd:SetIdOpera("");
			})
			// Realiza Entrada Armazem Estoque por Endereço
			If !oEstEnder:UpdSaldo("499",.T. /*lEstoque*/,.F. /*lEntPrev*/,.F. /*lSaiPrev*/,.T. /*lEmpenho*/,.F. /*lBloqueio*/,.F./*lEmpPrev*/,.T./*lMovEstEnd*/)
				Self:cErro := oEstEnder:GetErro()
				lRet := .F.
				Exit
			EndIf
			(cAliasD12)->(dbSkip())
		EndDo
	EndIf
	(cAliasD12)->(dbCloseArea())
	RestArea(aAreaAnt)
Return lRet
/*---------------------------------------------------------
Realiza o estorno da movimentação de estoque com base no CF
---------------------------------------------------------*/
METHOD EstMovSD3(cDocumento, cNumSeq) CLASS WMSDTCOrdemServicoReverse
Local lRet     := .T.
Local aAreaAnt := GetArea()
Local aRotAuto := {}
Local aErro    := {}
Local cErro    := ""
Local nI       := 0

Private lMsErroAuto := .F.
Private lExecWMS    := .T.
	// Itens SD3
	AAdd(aRotAuto,{"D3_DOC"    , cDocumento, Nil})
	AAdd(aRotAuto,{"D3_NUMSEQ" , cNumSeq, Nil})
	AAdd(aRotAuto,{"INDEX",8, Nil})
	// Estorno do movimento de requisição
	MsExecAuto({|x,y| MATA240(x,y)},aRotAuto,5)
	If lMsErroAuto
		// Erro na criação da SD3 pelo MsExecAuto
		If !IsTelNet()
			MostraErro()
		Else
			aErro := GetAutoGrLog()
			For nI := 1 To Len(aErro)
				cErro += aErro[nI] + CRLF
			Next nI
			Self:cErro := cErro
		EndIf
		lRet := .F.
	EndIf
	If lRet .And. Self:GetOrigem() == "DH1"
		// Gera do SB2
		Self:UpdEmpSB2("+",Self:oProdLote:GetProduto(),Self:oOrdEndOri:GetArmazem(),Self:GetQuant())
		// Gera do SB8
		If Self:oProdLote:HasRastro() .And. !Empty(Self:oProdLote:GetLoteCtl())
			Self:UpdEmpSB8("+",Self:oProdLote:GetProduto(),Self:oOrdEndOri:GetArmazem(),Self:oProdLote:GetLoteCtl(), Self:oProdLote:GetNumLote(), Self:GetQuant())
		EndIf
	EndIf
	RestArea(aAreaAnt)
Return lRet
/*--------------------------------------------------------------------
Realiza o estorno da ordem de serviço com base nos pedidos incompletos
---------------------------------------------------------------------*/
METHOD RevPedAut(cListIdDcf) CLASS WMSDTCOrdemServicoReverse
Local lRet      := .T.
Local cAliasDCF := Nil
	cAliasDCF := GetNextAlias()
	BeginSql Alias cAliasDCF
		SELECT DCF.R_E_C_N_O_ RECNODCF
		FROM %Table:DCF% DCF
		WHERE DCF.DCF_FILIAL = %xFilial:DCF%
		AND DCF.DCF_ID IN ( %Exp:cListIdDcf% )
		AND EXISTS (SELECT 1
					FROM %Table:DCF% DCF1
					WHERE DCF1.DCF_FILIAL = %xFilial:DCF%
					AND DCF1.DCF_SERVIC = DCF.DCF_SERVIC
					AND DCF1.DCF_DOCTO = DCF.DCF_DOCTO
					AND DCF1.DCF_STSERV = '2'
					AND DCF1.%NotDel% )
		AND DCF.%NotDel%
	EndSql
	Do While (cAliasDCF)->(!Eof())
		Self:GoToDCF((cAliasDCF)->RECNODCF)
		If Self:CanReverse()
			Self:ReverseDCF()
		EndIf
		(cAliasDCF)->(dbSkip())
	EndDo
	(cAliasDCF)->(dbCloseArea())
Return lRet
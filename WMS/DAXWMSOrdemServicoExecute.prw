#Include "Totvs.ch"
#Include "WMSDTCOrdemServicoExecute.ch"

//---------------------------------------------
/*/{Protheus.doc} WMSCLS0032
Fun��o para permitir que a classe seja visualizada
no inspetor de objetos
@author Inova��o WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
User Function WMSS0032()
Return Nil

//-----------------------------------------------
/*/{Protheus.doc} DAXWMSOrdemServicoExecute
Classe execu��o da ordem de servi�o
@author Inova��o WMS
@since 16/12/2016
@version 1.0
/*/
//-----------------------------------------------
CLASS DAXWMSOrdemServicoExecute FROM WMSDTCOrdemServico
	// Data
	DATA aRecD12    As array
	DATA aWmsReab   As array
	DATA aLogSld    As array
	DATA aLogEnd    As array
	DATA aLogEndUni As Array
	DATA aOrdAglu   As Array
	DATA aLstUnit   As array
	DATA aRecDCF    As array
	// Method
	METHOD New() CONSTRUCTOR
	METHOD GetLogUni()
	METHOD GetLogEnd()
	METHOD GetLogSld()
	METHOD ChecaPrior()
	METHOD ExecuteDCF()
	METHOD ExecuteUni()
	METHOD ExecutePrd()
	METHOD ExeDistPrd()
	METHOD AgluOSEnd()
	METHOD AgluOSTrf()
	METHOD AgluOSExp()
	METHOD ExecDesmon()
	METHOD VldOrdEnd()
	METHOD UpdateEnd()
	METHOD UpdEndOri(cNewEnd)
	METHOD UpdEndDes(cNewEnd)
	METHOD Destroy()
ENDCLASS

//-----------------------------------------------
/*/{Protheus.doc} New
M�todo construtor
@author felipe.m
@since 23/12/2014
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
//-----------------------------------------------
METHOD New() CLASS DAXWMSOrdemServicoExecute
	_Super:New()
	Self:aLibD12    := Nil
	Self:aRecD12    := {}
	Self:aWmsReab   := {}
	Self:aLogEnd    := {}
	Self:aLogSld    := {}
	Self:aLogEndUni := {}
	Self:aOrdAglu   := {}
	Self:aLstUnit   := {}
	Self:aRecDCF    := {}
Return

METHOD Destroy() CLASS DAXWMSOrdemServicoExecute
	FreeObj(Self)
Return

//-----------------------------------------------
/*/{Protheus.doc} GetLogUni
Retorna log de enderecamento unitizado
@author  Guilherme A. Metzger
@since   27/04/2017
@version 1.0
/*/
//-----------------------------------------------
METHOD GetLogUni() CLASS DAXWMSOrdemServicoExecute
Return Self:aLogEndUni

//-----------------------------------------------
/*/{Protheus.doc} GetLogEnd
Retorna log de endere�os
@author felipe.m
@since 23/12/2014
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
//-----------------------------------------------
METHOD GetLogEnd() CLASS DAXWMSOrdemServicoExecute
Return Self:aLogEnd

//-----------------------------------------------
/*/{Protheus.doc} GetLogSld
Retorna o log de saldos
@author felipe.m
@since 23/12/2014
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
//-----------------------------------------------
METHOD GetLogSld() CLASS DAXWMSOrdemServicoExecute
Return Self:aLogSld

//-----------------------------------------------
/*/{Protheus.doc} ChecaPrior
Checa a prioridade
@author felipe.m
@since 23/12/2014
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
//-----------------------------------------------
METHOD ChecaPrior() CLASS DAXWMSOrdemServicoExecute
Local lRet       := .T.
Local cCont      := ""
Local cError     := ""
Local cParam     := SuperGetMv("MV_WMSPRIO",.F.,"")
Local aTamSx3    := TamSx3("D12_PRIORI")
Local oLastError := ErrorBlock({|e| cError := e:Description + e:ErrorStack})
Local aAreaD12   := D12->(GetArea())
	dbSelectArea("D12")
	D12->(dbGoTop())
	cCont := &cParam

	If !Empty(cError)
		lRet := .F.
		Self:cErro := STR0002 // Valor inv�lido rever par�metro MV_WMSPRIO (Sequ�ncia de Prioridade).
	EndIf
	// Deve ser menor que o tamanho do campo menos as 4 posi��es fixas ZZ + (Parametro) + XX
	If lRet .And. Len(cCont) > aTamSx3[1]-4
		lRet := .F.
		Self:cErro := WmsFmtMsg(STR0003,{{"[VAR01]",LTrim(Str(aTamSx3[1]-4))}}) // Quantidade de caracteres da express�o configurada no par�metro MV_WMSPRIO (Sequ�ncia de Prioridade) � maior que [VAR01].
	EndIf
	ErrorBlock(oLastError)
	If !lRet
		AADD(Self:aWmsAviso, WmsFmtMsg(STR0001,{{"[VAR01]",Self:GetDocto()+Iif(!Empty(Self:GetSerie()),"/"+AllTrim(Self:GetSerie()),'')},{"[VAR02]",Self:oProdLote:GetProduto()}}) + CRLF +Self:GetErro()) //"SIGAWMS - OS [VAR01] - Produto: [VAR02]"
	EndIf
	RestArea(aAreaD12)
Return lRet

//-----------------------------------------------
/*/{Protheus.doc} ExecuteDCF
Execu��o da ordem de servi�o
@author felipe.m
@since 23/12/2014
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
//-----------------------------------------------
METHOD ExecuteDCF() CLASS DAXWMSOrdemServicoExecute
Local lRet       := .T.
Local nCont      := 0
Local cMessError := ""
Local nRecnoAnt  := Self:GetRecno()
Local lHasTransf := .F.
Local oEtiqUnit  := Nil
Local oBlqSaldo  := Nil 
	// Desconsidera ordens de servi�o j� executadas, n�o retorna o erro devido os casos de aglutina��o de documento
	// Desconsidera ordens de servi�o que est�o marcadas como executadas durante um mesmo processamento - aglutina��o
	If Self:cStServ == '3' .Or. !Empty(Self:cStRadi)
		Return .T.
	EndIf
	If lRet .And. Self:LockDCF()
		If Self:cStServ == '3' .Or. !Empty(Self:cStRadi)
			Return .T.
		EndIf

		// Verifica servico com conferencia de entrada
		If Self:oServico:HasOperac({'6'})
			If !Self:oServico:ChkConfOrd(1)
				Self:cErro := STR0013 //Tarefa de confer�ncia de entrada deve ser configurada antes das tarefas WMS Padr�o!
				lRet := .F.
			EndIf
		EndIf
		// Verifica servico com conferencia de sa�da
		If lRet .And. Self:oServico:HasOperac({'7'})
			If !Self:oServico:ChkConfOrd(2)
				Self:cErro := STR0014 //Tarefa de confer�ncia de sa�da deve ser configurada depois das tarefas WMS Padr�o de expedi��o!
				lRet := .F.
			EndIf
		EndIf
		// Valida bloqueio produto (B1_MSBLQL) somente se n�o for endere�amento ou transfer�ncia unitizada
		If lRet .And. !Self:IsMovUnit() .And. !WmsSB1Blq(Self:oProdLote:GetProduto(),@cMessError)
			Self:cErro := cMessError
			lRet := .F.
		EndIf
		If lRet .And. !(Self:cStServ $ '1|2')
			lRet := .F.
			Self:cErro := WmsFmtMsg(STR0008,{{"[VAR01]",Self:cStServ}}) // Situa��o ([VAR01]) da ordem de servi�o n�o permite que seja executada!
		EndIf
		// Verifica endere�o
		If lRet .And. !Self:VldOrdEnd()
			Self:cErro := WmsFmtMsg(STR0009,{{"[VAR01]",IIf(Self:oServico:HasOperac({'3','4'}),STR0010,STR0011)}}) // Endere�o [VAR01] n�o informado! // destino // origem
			lRet := .F.
		EndIf
		// Verifica parametro prioridade
		If lRet .And. !Self:ChecaPrior()
			lRet := .F.
		EndIf
		// Verifica se h� documentos originados desse documento que ainda estejam pendentes
		If lRet .And. Self:ChkDepPend()
			lRet := .F.
		EndIf
		//Valida se o tipo do unitizador est� preenchido na tabela de etiqueta
		lHasTransf := Self:oServico:HasOperac({'8'})
		If WmsX212118("D0Y")
			If lRet .And. lHasTransf .And. !Empty(Self:cUniDes)
				oEtiqUnit := WMSDTCEtiquetaUnitizador():New()
				oEtiqUnit:SetIdUnit(Self:cUniDes)
				If oEtiqUnit:LoadData() 
					If Empty(oEtiqUnit:GetTipUni())
						Self:cErro := WmsFmtMsg(STR0016,{{"[VAR01]",Self:cUniDes}}) //Unitizador destino da OS [VAR01] n�o possui tipo definido.
						lRet := .F.
					EndIf
				Else
					Self:cErro := WmsFmtMsg(STR0017,{{"[VAR01]",Self:cUniDes}}) // Etiqueta do unitizador [VAR01] n�o gerada!
					lRet := .F.
				EndIf
				oEtiqUnit:Destroy()
			EndIf
		EndIf
		If lRet
			// Se for endere�amento unitizado sem informar endere�o destino, deve aglutinar as ordens de servi�o selecionadas para execu��o
			If Self:IsMovUnit() .And. Empty(Self:oOrdEndDes:GetEnder())
				lRet := Self:AgluOSEnd()
			// Se for uma transfer�ncia com unitizador destino, por�m n�o possui endere�o definido
			// Deve executar como se fosse um endere�amento unitizado, mesmo possuindo o produto informado
			ElseIf lHasTransf .And. !Empty(Self:cUniDes) .And. Empty(Self:oOrdEndDes:GetEnder())
				lRet := Self:AgluOSTrf()
			Else
				// Se for um servi�o de expedi��o, verifica se est� parametrizado para gerar ordens de servi�o aglutinadas na expedi��o
				If (Self:oServico:GetTipo() == '2' .And. SuperGetMv("MV_WMSACEX",.F.,"0") <> '0' .And. WmsCarga(Self:GetCarga())) .Or. !Empty(Self:GetCodPln())
					lRet := Self:AgluOSExp()
				EndIf
			EndIf
			If lRet
				// Atualiza status do servi�o quando n�o est� aglutinado
				If Empty(Self:aRecDCF)
					Self:SetStServ('2')
					Self:SetOk("")
					Self:UpdateDCF(.F.) // Para n�o liberar o lock
					Self:UpdStatus()
				EndIf
			EndIf

			WMSCTPENDU() // Cria as tempor�rias - FORA DA TRANSA��O

			Begin Transaction
				// Carrega os produtos a serem geradas as movimentacoes
				If Self:IsMovUnit() .Or. (lHasTransf .And. !Empty(Self:cUniDes) .And. Empty(Self:oOrdEndDes:GetEnder()))
					lRet := Self:ExecuteUni()
				ElseIf Self:ChkDistr()
					lRet := Self:ExeDistPrd()
				Else
					lRet := Self:ExecutePrd()
				EndIf
				//Gera D0U, SDD e SDC para bloqueio de saldo
				If lRet .And. Self:oServico:ChkRecebi() .And. Self:oServico:ChkBlqSld()
					oBlqSaldo := WMSDTCBloqueioSaldoItens():New()
					oBlqSaldo:SetOrdServ(Self)
					lRet := oBlqSaldo:AssignSDD()
				EndIf
				If lRet
					// Carrega os movimentos criados
					For nCont := 1 To Len(Self:aRecD12)
						AAdd(Self:aLibD12,Self:aRecD12[nCont])
					Next
					Self:aRecD12:= {}
					// Quando documentos aglutinados
					If Len(Self:aRecDCF) > 0
						For nCont := 1 to Len(Self:aRecDCF)
							If Self:aRecDCF[nCont][2]
								Self:GoToDCF(Self:aRecDCF[nCont][1])
								// Atualiza status
								Self:SetStServ('3')
								Self:cStRadi := ' '
								Self:UpdateDCF()
								Self:UpdStatus()
							EndIf
						Next nCont
						Self:aRecDCF  := {}
						Self:aLstUnit := {}
						Self:aOrdAglu := {}
						Self:GoToDCF(nRecnoAnt)
					Else
						// Atualiza status
						Self:SetStServ('3')
						Self:cStRadi := ' '
						Self:UpdateDCF()
						Self:UpdStatus()
					EndIf
				Else
					DisarmTransaction()
				EndIf
			End Transaction

			WMSDTPENDU() // Destroy as tempor�rias - FORA DA TRANSA��O

		EndIf
		If !lRet
			If Self:IsMovUnit()
				AADD(Self:aWmsAviso, WmsFmtMsg(STR0015,{{"[VAR01]",Self:GetDocto()+Iif(!Empty(Self:GetSerie()),"/"+AllTrim(Self:GetSerie()),'')},{"[VAR02]",Self:cIdUnitiz}}) + CRLF +Self:GetErro()) // SIGAWMS - OS [VAR01] - Unitizador: [VAR02]
			Else
				AADD(Self:aWmsAviso, WmsFmtMsg(STR0001,{{"[VAR01]",Self:GetDocto()+Iif(!Empty(Self:GetSerie()),"/"+AllTrim(Self:GetSerie()),'')},{"[VAR02]",Self:oProdLote:GetProduto()}}) + CRLF +Self:GetErro()) // SIGAWMS - OS [VAR01] - Produto: [VAR02]
			EndIf
		EndIf
		Self:UnLockDCF()
	Else
		lRet := .F.
	EndIf
Return lRet

//-----------------------------------------------
/*/{Protheus.doc} ExecuteUni
Execu��o do endere�amento unitizado
@author  Guilherme A. Metzger
@since   27/04/2017
@version 1.0
/*/
//-----------------------------------------------
METHOD ExecuteUni() CLASS DAXWMSOrdemServicoExecute
Local lRet    := .T.
Local oFuncao := Nil
Local nI      := 1
	// Se for transfer�ncia ou endere�amento sem informar endere�o destino
	If Empty(Self:oOrdEndDes:GetEnder())
		// Instacia o objeto da classe de enderecamento unitizado
		oFuncao := WMSBCCEnderecamentoUnitizado():New()
		oFuncao:SetLstUnit(Self:aLstUnit)
		oFuncao:SetLogEnd(Self:aLogEndUni)
	Else
		oFuncao := WMSBCCTransferencia():New()
		oFuncao:SetIdUnit(Self:cIdUnitiz)
		oFuncao:SetUniDes(Self:cUniDes)
	EndIf
	// Carrega Servico x Tarefa
	Self:oServico:LoadData()
	// Atribui Demais Dados
	oFuncao:SetOrdServ(Self)
	oFuncao:SetQuant(Self:nQuant)
	oFuncao:SetRecD12(Self:aRecD12)
	If !oFuncao:ExecFuncao()
		Self:cErro := oFuncao:GetErro()
		lRet := .F.
	EndIf
	// Se o endere�o n�o estiver preenchido, passou pelo processo de aglutina��o de OS
	// Por isso deve guardar o registro no array de recnos para atualiza��o de status
	If Empty(Self:oOrdEndDes:GetEnder())
		// Faz o repasse do status da execu��o para o array de DCFs
		For nI := 1 To Len(Self:aLstUnit)
			Self:aRecDCF[nI][2] := Self:aLstUnit[nI][3]
		Next
	EndIf
	oFuncao:Destroy()
Return lRet

//-----------------------------------------------
/*/{Protheus.doc} ExecutePrd
Execu��o produto
@author felipe.m
@since 23/12/2014
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
//-----------------------------------------------
METHOD ExecutePrd() CLASS DAXWMSOrdemServicoExecute
Local lRet       := .T.
Local aProduto   := {}
Local aTarefa    := {}
Local nProdAux   := 0
Local nTarAux    := 0
Local nIdDCFAux  := 0
Local oFuncao    := Nil
Local cSegSepara := SuperGetMV('ES_SERVSEP',.T.,'025',cFilAnt)
	aProduto := Self:oProdLote:GetArrProd()
	Self:oServico:ServTarefa()
	aTarefa  := Self:oServico:GetArrTar()

	//Reserva os campos para as quantidades das atividades
	If !Empty(Self:aOrdAglu)
		For nIdDCFAux := 1 To Len(Self:aOrdAglu)
			For nProdAux := 1 To Len(aProduto)
				AAdd(Self:aOrdAglu[nIdDCFAux][5],{})
				For nTarAux := 1 To Len(aTarefa)
					AAdd(Self:aOrdAglu[nIdDCFAux][5][nProdAux],{Self:aOrdAglu[nIdDCFAux][2] * aProduto[nProdAux][2],0,'',0})
				Next
			Next
		Next
	EndIf
	// Produtos
	For nProdAux := 1 To Len(aProduto)
		Self:nProduto := nProdAux
		// Atribui quantidade multipla
		nQuant := (QtdComp(Self:nQuant * aProduto[Self:nProduto][2]) )
		// Tarefas
		For nTarAux := 1 To Len(aTarefa)
			Self:nTarefa := nTarAux
			// Atribui para oMovimento - oServico a ordem
			Self:oServico:SetOrdem(aTarefa[Self:nTarefa][1])
			Self:oServico:LoadData()
			// Quando informado a ordem da tarefa poder�o ser utilizadas as checagens de opera��o
			// Cria classe para regra derminada
			Do Case
				// Valida se � endere�amento, endere�amento crossdocking, transferencia, desfragmenta��o
				Case Self:oServico:ChkRecebi() .Or. Self:oServico:ChkTransf()
					// Valida se endere�o destino informado
					If Self:ChkMovEst(.F.)
						oFuncao := WMSBCCTransferencia():New()
					Else
						oFuncao := WMSBCCEnderecamento():New()
						oFuncao:SetLogEnd(Self:aLogEnd)
					EndIf
				// Valida se � conferencia de endere�amento
				Case Self:oServico:ChkConfEnt()
					oFuncao := WMSBCCConferenciaEntrada():New()
				// Valida se � conferencia de expedi��o
				Case Self:oServico:ChkConfSai()
					oFuncao := WMSBCCConferenciaSaida():New()
				// Valida se � processo de expedi��o
				Case Self:oServico:ChkSepara()
					//---------------------------------------
					// Trata os itens filhos dentro da classe
					//---------------------------------------
					If Self:nProduto > 1 .And. !Self:ChkMovEst()
						Loop
					EndIf
					//--------------------------------------------
					// Valida se endere�o origem informado
					// Somente para produtos sem componente,
					// onde � digitado o endere�o origem no pedido
					//--------------------------------------------
					If Self:ChkMovEst()
						oFuncao := WMSBCCTransferencia():New()
					Else
					//	If Self:oServico:GetServico() <> cSegSepara // Ajuste para nao efetuar reabastecimento qdo for segunda separa��o		
							oFuncao := WMSBCCSeparacao():New()
							oFuncao:SetContPrd(Self:nProduto)
							oFuncao:SetLogSld(Self:aLogSld)
											
                            oFuncao:SetWmsReab(Self:aWmsReab)
					//	Else
					//		lRet := .F.
                     //   EndIf
					EndIf
				// Valida se � processo de reabastecimento
				Case Self:oServico:ChkReabast() 
					oFuncao := WMSBCCAbastecimento():New()
				Otherwise
					oFuncao := WMSBCCCustomizacao():New()
			EndCase
			If lRet
				// Atribui o produto origem ao movimento
				// Atribui para oMovimento produto/lote/sub-lote
				oFuncao:oMovPrdLot:SetArmazem(Self:oProdLote:GetArmazem())
				oFuncao:oMovPrdLot:SetPrdOri(Self:oProdLote:GetPrdOri())
				oFuncao:oMovPrdLot:SetProduto(aProduto[Self:nProduto][1])
				oFuncao:oMovPrdLot:SetLoteCtl(Self:oProdLote:GetLoteCtl())
				oFuncao:oMovPrdLot:SetNumLote(Self:oProdLote:GetNumLote())
				oFuncao:oMovPrdLot:SetNumSer(Self:oProdLote:GetNumSer())
				oFuncao:oMovPrdLot:LoadData()
				// Valida possui segunda unidade de medida
				// e se possui fator de convers�o
				If !oFuncao:oMovPrdLot:oProduto:oProdGen:ChkFatConv()
					Self:cErro  := oFuncao:oMovPrdLot:oProduto:oProdGen:GetErro()
					lRet := .F.
				EndIf
				If lRet
					// Atribui Demais Dados
					oFuncao:SetOrdServ(Self)
					oFuncao:SetQuant(nQuant)
					oFuncao:SetRecD12(Self:aRecD12)
					oFuncao:SetOrdAglu(Self:aOrdAglu)
					oFuncao:oOrdServ:nProduto := Self:nProduto
					oFuncao:oOrdServ:nTarefa := Self:nTarefa
					oFuncao:SetIdUnit(Self:cIdUnitiz)
					oFuncao:SetTipUni(Self:cTipUni)
					oFuncao:SetUniDes(Self:cUniDes)
					If !oFuncao:ExecFuncao()
						Self:cErro := oFuncao:GetErro()
						lRet := .F.
					EndIf
				EndIf
			EndIf
			// Erro sai do for
			If !lRet
				Exit
			EndIf
		Next
		// Erro sai do for
		If !lRet
			Exit
		EndIf
	Next
	If oFuncao != Nil
		oFuncao:Destroy()
	EndIf
Return lRet

//-----------------------------------------------
/*/{Protheus.doc} AgluOSEnd
Aglutina ordens de servi�o de endere�amento unitizado
@author  Guilherme A. Metzger
@since   27/04/2017
@version 1.0
/*/
//-----------------------------------------------
METHOD AgluOSEnd() CLASS DAXWMSOrdemServicoExecute
Local lRet      := .T.
Local cQuery    := ""
Local cAliasQry := ""
Local cPrdVazio := Space(TamSX3("DCF_CODPRO")[1])
Local cEndVazio := Space(TamSX3("DCF_ENDDES")[1])
Local cUniVazio := Space(TamSX3("DCF_UNITIZ")[1])
Local nCont     := 1

	//Grava no array a OS que encontra-se posicionada, que n�o ser� considerada pelo SELECT
	AAdd(Self:aLstUnit,{Self:cIdUnitiz,Self:GetRecno(),.F.})
	AAdd(Self:aRecDCF ,{Self:GetRecno(),.F.})
	//Busca ordens de servi�os semelhantes para serem aglutinadas
	cQuery += "SELECT DCF.DCF_UNITIZ,"
	cQuery +=       " DCF.DCF_ID,"
	cQuery +=       " DCF.R_E_C_N_O_ RECNODCF"
	cQuery +=  " FROM "+RetSqlName('DCF')+" DCF"
	cQuery += " WHERE DCF.DCF_FILIAL  = '"+xFilial('DCF')+"'"
	cQuery +=   " AND DCF.DCF_SERVIC  = '"+Self:oServico:GetServico()+"'"
	cQuery +=   " AND DCF.DCF_CODPRO  = '"+cPrdVazio+"'"
	cQuery +=   " AND DCF.DCF_LOCDES  = '"+Self:oOrdEndDes:GetArmazem()+"'"
	cQuery +=   " AND DCF.DCF_ENDER   = '"+Self:oOrdEndOri:GetArmazem()+"'"
	cQuery +=   " AND DCF.DCF_OK      = '"+Self:cOk+"'"
	cQuery +=   " AND DCF.DCF_ENDDES  = '"+cEndVazio+"'"
	cQuery +=   " AND DCF.DCF_UNITIZ <> '"+cUniVazio+"'"
	cQuery +=   " AND DCF.DCF_STSERV <> '3'"
	cQuery +=   " AND DCF.DCF_STRADI = ' '"
	cQuery +=   " AND DCF.R_E_C_N_O_ <> "+AllTrim(Str(Self:GetRecno()))+""
	cQuery +=   " AND DCF.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	While !(cAliasQry)->(Eof())
		// Caso alguma ordem de servi�o da carga n�o esteja dispon�vel para execu��o n�o aglutina
		If Self:ChkDepPend((cAliasQry)->DCF_ID)
			lRet := .F.
			Exit
		EndIf
		// Salva o registro na lista de ordens de servi�o unitizadas
		AAdd(Self:aLstUnit,{(cAliasQry)->DCF_UNITIZ,(cAliasQry)->RECNODCF,.F.})
		// Salva o recno no array para posterior atualiza��o de status
		AAdd(Self:aRecDCF ,{(cAliasQry)->RECNODCF,.F.})
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
	// Seta o status das ordens de servi�o para Interrompido
	If Len(Self:aRecDCF) > 0
		For nCont := 1 To Len(Self:aRecDCF)
			Self:GoToDCF(Self:aRecDCF[nCont][1])
			Self:SetStServ('2')
			Self:SetOk("")
			Self:cStRadi := '1'
			Self:UpdateDCF(.F.) // Para n�o liberar o lock
		Next
	EndIf
	//Ordena o array pelo IDDCF
	ASort(Self:aLstUnit, , , {|x,y|x[1] < y[1]})
Return lRet

METHOD AgluOSTrf() CLASS DAXWMSOrdemServicoExecute
Local lRet      := .T.
Local cQuery    := ""
Local cAliasQry := ""
Local cPrdVazio := Space(TamSX3("DCF_CODPRO")[1])
Local cEndVazio := Space(TamSX3("DCF_ENDDES")[1])
Local cUniVazio := Space(TamSX3("DCF_UNITIZ")[1])
Local nCont     := 1

	//Grava no array a OS que encontra-se posicionada, que n�o ser� considerada pelo SELECT
	AAdd(Self:aLstUnit,{Self:cUniDes,Self:GetRecno(),.F.})
	AAdd(Self:aRecDCF ,{Self:GetRecno(),.F.})
	//Busca ordens de servi�os semelhantes para serem aglutinadas
	cQuery += "SELECT DCF.DCF_UNIDES,"
	cQuery +=       " DCF.DCF_ID,"
	cQuery +=       " DCF.R_E_C_N_O_ RECNODCF"
	cQuery +=  " FROM "+RetSqlName('DCF')+" DCF"
	cQuery += " WHERE DCF.DCF_FILIAL  = '"+xFilial('DCF')+"'"
	cQuery +=   " AND DCF.DCF_SERVIC  = '"+Self:oServico:GetServico()+"'"
	cQuery +=   " AND DCF.DCF_CODPRO <> '"+cPrdVazio+"'"
	cQuery +=   " AND DCF.DCF_LOCDES  = '"+Self:oOrdEndDes:GetArmazem()+"'"
	cQuery +=   " AND DCF.DCF_ENDER   = '"+Self:oOrdEndOri:GetArmazem()+"'"
	cQuery +=   " AND DCF.DCF_OK      = '"+Self:cOk+"'"
	cQuery +=   " AND DCF.DCF_ENDDES  = '"+cEndVazio+"'"
	cQuery +=   " AND DCF.DCF_UNIDES <> '"+cUniVazio+"'"
	cQuery +=   " AND DCF.DCF_STSERV <> '3'"
	cQuery +=   " AND DCF.DCF_STRADI = ' '"
	cQuery +=   " AND DCF.R_E_C_N_O_ <> "+AllTrim(Str(Self:GetRecno()))+""
	cQuery +=   " AND DCF.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	While !(cAliasQry)->(Eof())
		// Caso alguma ordem de servi�o da carga n�o esteja dispon�vel para execu��o n�o aglutina
		If Self:ChkDepPend((cAliasQry)->DCF_ID)
			lRet := .F.
			Exit
		EndIf
		// Salva o registro na lista de ordens de servi�o unitizadas
		AAdd(Self:aLstUnit,{(cAliasQry)->DCF_UNIDES,(cAliasQry)->RECNODCF,.F.})
		// Salva o recno no array para posterior atualiza��o de status
		AAdd(Self:aRecDCF ,{(cAliasQry)->RECNODCF,.F.})
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
	// Seta o status das ordens de servi�o para Interrompido
	If Len(Self:aRecDCF) > 0
		For nCont := 1 To Len(Self:aRecDCF)
			Self:GoToDCF(Self:aRecDCF[nCont][1])
			Self:SetStServ('2')
			Self:SetOk("")
			Self:cStRadi := '1'
			Self:UpdateDCF(.F.) // Para n�o liberar o lock
		Next
	EndIf
	//Ordena o array pelo IDDCF
	ASort(Self:aLstUnit, , , {|x,y|x[1] < y[1]})
Return lRet

//-----------------------------------------------
/*/{Protheus.doc} AgluOSExp
Verifica a possibilidade de aglutina��o de OS de
expedi��o pertencentes a uma mesma carga ou plano
de execu��o
@author  felipe.m
@since   23/12/2014
@version 1.0
/*/
//-----------------------------------------------
METHOD AgluOSExp() CLASS DAXWMSOrdemServicoExecute
Local lRet       := .T.
Local cQuery     := ""
Local cAliasQry  := ""
Local nQtdOrdSer := Self:nQuant
Local nCont      := 1

	//Busca ordens de servi�os semelhantes para serem aglutinadas
	cQuery := " SELECT DCF.DCF_ID,"
	cQuery +=        " DCF.DCF_NUMSEQ,"
	cQuery +=        " DCF.DCF_QUANT,"
	cQuery +=        " DCF.DCF_DOCTO,"
	cQuery +=        " DCF.DCF_SERIE,"
	cQuery +=        " DCF.DCF_CLIFOR,"
	cQuery +=        " DCF.DCF_LOJA,"
	cQuery +=        " DCF.DCF_SEQUEN,"
	cQuery +=        " DCF.R_E_C_N_O_ RECNODCF"
	cQuery +=  " FROM "+RetSqlName("DCF")+" DCF"
	cQuery += " WHERE DCF.DCF_FILIAL = '"+xFilial("DCF")+"'"
	cQuery +=   " AND DCF.DCF_SERVIC = '"+Self:oServico:GetServico()+"'"
	cQuery +=   " AND DCF.DCF_CODPRO = '"+Self:oProdLote:GetProduto()+"'"
	If !Empty(Self:GetCodPln())
		cQuery += " AND DCF.DCF_CODPLN = '"+Self:GetCodPln()+"'"
	ElseIf WmsCarga(Self:GetCarga())
		If SuperGetMv("MV_WMSACEX",.F.,"0") == '2' // Se aglutina por cliente
			cQuery += " AND DCF.DCF_CLIFOR = '"+Self:GetCliFor()+"'"
			cQuery += " AND DCF.DCF_LOJA = '"+Self:GetLoja()+"'"
		EndIf
		cQuery += " AND DCF.DCF_CARGA = '"+Self:GetCarga()+"'"
	EndIf
	If Self:oServico:GetTipo() == '2'
		cQuery += " AND DCF.DCF_LOCAL = '"+Self:oOrdEndOri:GetArmazem()+"'"
		cQuery += " AND DCF.DCF_ENDER = '"+Self:oOrdEndOri:GetEnder()+"'"
	Else
		cQuery += " AND DCF.DCF_LOCDES = '"+Self:oOrdEndDes:GetArmazem()+"'"
		cQuery += " AND DCF.DCF_ENDDES = '"+Self:oOrdEndDes:GetEnder()+"'"
	EndIf
	cQuery += " AND DCF.DCF_LOTECT = '"+Self:oProdLote:GetLoteCtl()+"'"
	cQuery += " AND DCF.DCF_NUMLOT = '"+Self:oProdLote:GetNumLote()+"'"
	cQuery += " AND DCF.DCF_STSERV <> '3'"
	cQuery += " AND DCF.DCF_STRADI = ' '"
	cQuery += " AND DCF.R_E_C_N_O_ <> "+ AllTrim(Str(Self:GetRecno()))+""
	cQuery += " AND DCF.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	While !(cAliasQry)->(Eof())
		// Caso alguma ordem de servi�o da carga n�o esteja dispon�vel para execu��o n�o aglutina
		If Self:ChkDepPend((cAliasQry)->DCF_ID)
			lRet := .F.
			Exit
		EndIf
		// Salva o registro na lista de ordens de servi�o de expedi��o aglutinada
		AAdd(Self:aOrdAglu,{(cAliasQry)->DCF_ID,(cAliasQry)->DCF_QUANT,(cAliasQry)->RECNODCF,(cAliasQry)->DCF_SEQUEN,{}})
		// Salva o recno no array para posterior atualiza��o de status
		AAdd(Self:aRecDCF ,{(cAliasQry)->RECNODCF,.T.})
		nQtdOrdSer += (cAliasQry)->DCF_QUANT
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
	If Len(Self:aOrdAglu) > 0
		//Grava no array a OS que encontra-se posicionada, que n�o foi considerada pelo SELECT
		AAdd(Self:aOrdAglu,{Self:cIdDCF,Self:nQuant,Self:GetRecno(),Self:cSequen,{}})
		AAdd(Self:aRecDCF ,{Self:GetRecno(),.T.})
		//Ordena o array pelo IDDCF
		ASort(Self:aOrdAglu, , , {|x,y|x[1] < y[1]})
		// Seta o status das ordens de servi�o para Interrompido
		If Len(Self:aRecDCF) > 0			
			For nCont := 1 To Len(Self:aRecDCF)
				Self:GoToDCF(Self:aRecDCF[nCont][1])
				Self:SetStServ('2')
				Self:SetOk("")
				Self:cStRadi := '1'
				Self:UpdateDCF(.F.) // Para n�o liberar o lock
			Next
		EndIf
		Self:nQuant := nQtdOrdSer
	EndIf
Return lRet

METHOD ExecDesmon() CLASS DAXWMSOrdemServicoExecute
Local oCompEnder := WMSDTCProdutoComponente():New()
Local oEstEnder := WMSDTCEstoqueEndereco():New()

	oCompEnder:SetPrdCmp(Self:oProdLote:GetProduto())
	oCompEnder:LoadData(2)

	oEstEnder:oEndereco:SetArmazem( Self:oOrdEndOri:GetArmazem() )
	oEstEnder:oEndereco:SetEnder( Self:oOrdEndOri:GetEnder() )
	oEstEnder:oProdLote:SetArmazem( Self:oProdLote:GetArmazem() )
	oEstEnder:oProdLote:SetPrdOri( oCompEnder:GetPrdOri() )
	oEstEnder:oProdLote:SetProduto( Self:oProdLote:GetProduto() )
	oEstEnder:oProdLote:SetLoteCtl( Self:oProdLote:GetLoteCtl() )
	oEstEnder:oProdLote:SetNumLote( Self:oProdLote:GetNumLote() )
	oEstEnder:oProdLote:SetNumSer( Self:oProdLote:GetNumSer() )
	oEstEnder:SetQuant( Self:GetQuant() )
	oEstEnder:UpdSaldo("999",.T.,.F.,.T.,.F.,.F.)

	oEstEnder:SetPrdOri( Self:oProdLote:GetPrdOri() )
	oEstEnder:UpdSaldo("499",.T.,.F.,.F.,.F.,.F.)
Return

METHOD UpdateEnd() CLASS DAXWMSOrdemServicoExecute
Local lRet      := .T.
Local lCarga    := WmsCarga(Self:GetCarga())
Local lCargaPE  := .F.
Local cQuery    := ""
Local aAreaDCF  := DCF->(GetArea())
Local aAreaSC9  := SC9->(GetArea())
Local cAliasDCF := ""
Local cAliasSC9 := ""
	// Permite indicar se considera a carga para atribuir o endere�o destino informado
	If lCarga .And. ExistBlock("DLENDOSE")
		lCargaPE := ExecBlock('DLENDOSE',.F.,.F.,{lCarga})
		If ValType(lCargaPE) =='L'
			lCarga := lCargaPE
		EndIf
	EndIf
	// Preenche DCF com os endereco e estrutura escolhidos
	// Atualiza as outras ordens de servi�o, caso existam
	cQuery := " SELECT DCF.R_E_C_N_O_ RECNODCF"
	cQuery +=   " FROM "+RetSqlName('DCF')+" DCF"
	cQuery +=  " WHERE DCF.DCF_FILIAL = '"+xFilial("DCF")+"'"
	cQuery +=    " AND DCF.DCF_SERVIC = '"+Self:oServico:GetServico()+"'"
	If lCarga
		cQuery += " AND DCF_CARGA = '"+Self:GetCarga()+"'"
	Else
		cQuery += " AND DCF_DOCTO = '"+Self:GetDocto()+"'"
		cQuery += " AND DCF_CLIFOR = '"+Self:GetCliFor()+"'"
		cQuery += " AND DCF_LOJA = '"+Self:GetLoja()+"'"
	EndIf
	If Self:oServico:HasOperac({'3','4'}) // Caso servi�o tenha opera��o de separa��o, separa��o crossdocking
		cQuery += " AND DCF_LOCAL = '"+Self:oOrdEndDes:GetArmazem()+"'"
		cQuery += " AND DCF_ENDDES = '"+Space(TamSx3("DCF_ENDDES")[1])+"'"
	Else
		cquery += " AND DCF_LOCAL = '"+Self:oOrdEndOri:GetArmazem()+"'"
		cQuery += " AND DCF_ENDER = '"+Space(TamSx3("DCF_ENDER")[1])+"'"
	EndIf
	cQuery += " AND DCF.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasDCF := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasDCF,.F.,.T.)
	Do While (cAliasDCF)->(!Eof())
		DCF->(dbGoTo((cAliasDCF)->RECNODCF))
		RecLock('DCF', .F.)
		DCF->DCF_ENDER  := Self:oOrdEndOri:GetEnder()
		DCF->DCF_ENDDES := Self:oOrdEndDes:GetEnder()
		DCF->(MsUnLock())
		// Atualiza pedido
		If DCF->DCF_ORIGEM == "SC9"
			// Atualiza as libera��es do pedido
			cQuery := "SELECT SC9.R_E_C_N_O_ RECNOSC9"
			cQuery +=  " FROM "+RetSqlName('SC9')+" SC9"
			cQuery += " WHERE SC9.C9_FILIAL = '"+xFilial('SC9')+"'"
			cQuery +=   " AND SC9.C9_SERVIC = '"+DCF->DCF_SERVIC+"'"
			If lCarga
				cQuery += " AND SC9.C9_CARGA   = '"+DCF->DCF_CARGA+"'"
			Else
				cQuery += " AND SC9.C9_PEDIDO  = '"+DCF->DCF_DOCTO+"'"
				cQuery += " AND SC9.C9_CLIENTE = '"+DCF->DCF_CLIFOR+"'"
				cQuery += " AND SC9.C9_LOJA    = '"+DCF->DCF_LOJA+"'"
			EndIf
			cQuery += " AND SC9.C9_ENDPAD  = '"+Space(TamSx3("C9_ENDPAD")[1])+"'"
			cQuery += " AND SC9.D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			cAliasSC9 := GetNextAlias()
			DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSC9,.F.,.T.)
			Do While (cAliasSC9)->(!Eof())
				SC9->(dbGoTo((cAliasSC9)->RECNOSC9))
				RecLock('SC9', .F.)
				SC9->C9_ENDPAD := DCF->DCF_ENDDES
				SC9->(MsUnLock())
				(cAliasSC9)->(dbSkip())
			EndDo
			(cAliasSC9)->(dbCloseArea())
		EndIf
		(cAliasDCF)->(dbSkip())
	EndDo
	(cAliasDCF)->(dbCloseArea())
	RestArea(aAreaDCF)
	RestArea(aAreaSC9)
Return lRet

METHOD VldOrdEnd() CLASS DAXWMSOrdemServicoExecute
Local lRet      := .T.
Local lFindEnd  := .T.
Local cArmazem  := ""
Local cEndereco := ""

	If Self:oServico:HasOperac({'1','2','3','4'}) // Caso servi�o tenha opera��o de endere�amento, endere�amento crossdocking, separa��o, separa��o crossdocking
		If Self:oServico:HasOperac({'3','4'}) // Caso servi�o tenha opera��o de separa��o, separa��o crossdocking
			cArmazem  := Self:oOrdEndDes:GetArmazem()
			cEndereco := Self:oOrdEndDes:GetEnder()
			lFindEnd  := Self:oOrdEndDes:LoadData()
		Else
			cArmazem  := Self:oOrdEndOri:GetArmazem()
			cEndereco := Self:oOrdEndOri:GetEnder()
			lFindEnd  := Self:oOrdEndOri:LoadData()
		EndIf
		// For�a a utiliza��o de um endereco destino caso o endere�o encontra-se vazio ou o endere�o preenchido � inv�lido.
		If Empty(cEndereco) .Or. (!Empty(cEndereco) .And. !lFindEnd)
			cEndereco := Space(TamSx3("D14_ENDER")[1])
			DLPergEnd(@cEndereco,.T.,.T.,IIf(Self:oServico:HasOperac({'3','4'}) ,'2','1'),cArmazem) // Identifique o destino do Servi�o WMS:
			If Self:oServico:HasOperac({'3','4'}) // Caso servi�o tenha opera��o de separa��o, separa��o crossdocking
				//Se o endere�o que encontra-se na DCF � inv�lido, realiza a troca de endere�os e ajusta a D14, DCF e demais tabelas
				If !Empty(Self:oOrdEndDes:GetEnder()) .And. !lFindEnd
					Self:UpdEndDes(cEndereco)
				Else //Caso o endere�o vazio na DCF
					Self:oOrdEndDes:SetEnder(cEndereco)
					If Self:UpdateEnd()
						Self:LoadData()
					Else
						lRet := .F.
					EndIf
				EndIf
			Else
				//Se o endere�o que encontra-se na DCF � inv�lido, realiza a troca de endere�os e ajusta a D14, DCF e demais tabelas
				If !Empty(Self:oOrdEndOri:GetEnder()) .And. !lFindEnd
					Self:UpdEndOri(cEndereco)
				Else //Caso o endere�o vazio na DCF
					Self:oOrdEndOri:SetEnder(cEndereco)
					If Self:UpdateEnd()
						Self:LoadData()
					Else
						lRet := .F.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
Return lRet

METHOD ExeDistPrd()  CLASS DAXWMSOrdemServicoExecute
Local lRet        := .T.
Local oOrdServAux := Nil
Local cAliasNew   := ""
Local lCarregou   := .F.

	// Busca as informa��es do documento de montagem/desmontagem
	cAliasNew := GetNextAlias()
	cQuery := " SELECT D0F.D0F_ENDER,"
	cQuery +=        " D0F.D0F_QTDDIS"
	cQuery +=   " FROM "+RetSqlName("SD1")+" SD1"
	cQuery +=  " INNER JOIN "+RetSqlName("D06")+" D06"
	cQuery +=     " ON D06.D06_FILIAL = '"+xFilial("D06")+"'"
	cQuery +=    " AND D06.D06_CODDIS = SD1.D1_CODDIS"
	cQuery +=    " AND D06.D06_SITDIS <> '3'"
	cQuery +=    " AND D06.D_E_L_E_T_ = ' '"
	cQuery +=  " INNER JOIN "+RetSqlName("D0F")+" D0F"
	cQuery +=     " ON D0F.D0F_FILIAL = '"+xFilial("D0F")+"'"
	cQuery +=    " AND D0F.D0F_CODDIS = SD1.D1_CODDIS"
	cQuery +=    " AND D0F.D0F_DOC = SD1.D1_DOC"
	cQuery +=    " AND D0F.D0F_SERIE = SD1.D1_SERIE"
	cQuery +=    " AND D0F.D0F_FORNEC = SD1.D1_FORNECE"
	cQuery +=    " AND D0F.D0F_LOJA = SD1.D1_LOJA"
	cQuery +=    " AND D0F.D0F_PRODUT = SD1.D1_COD"
	cQuery +=    " AND D0F.D0F_ITEM = SD1.D1_ITEM"
	cQuery +=    " AND D0F.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE SD1.D1_FILIAL = '"+xFilial("SD1")+"'"
	cQuery +=    " AND SD1.D1_NUMSEQ = '"+Self:cNumSeq+"'"
	cQuery +=    " AND SD1.D_E_L_E_T_ = ' '"
	cQuery +=  " ORDER BY D0F.D0F_ENDER"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasNew,.F.,.T.)
	If (cAliasNew)->(!Eof())
		oOrdServAux:= WMSDTCOrdemServico():New()
		// Carrega dados originais da ordem de servi�o
		oOrdServAux:GoToDCF(Self:nRecno)
		lCarregou := .T.
	Else
		Self:cErro := WmsFmtMsg(STR0012,{{"[VAR01]",Self:GetDocto()}})  // N�o encontrada a distribui��o de produtos do documento [VAR01]!
		lRet := .F.
	EndIf
	While lRet .And. (cAliasNew)->(!Eof())
		// Verifica se h� endere�o destino informado na distribui��o
		Self:oOrdEndDes:SetArmazem(Self:oOrdEndDes:GetArmazem())
		If !Empty((cAliasNew)->D0F_ENDER)
			Self:oOrdEndDes:SetEnder((cAliasNew)->D0F_ENDER) // Endere�o destino
		Else
			// Carrega dados endere�o destino
			Self:oOrdEndDes:SetEnder(Self:oOrdEndDes:GetEnder())
		EndIf
		Self:oOrdEndDes:LoadData()
		Self:oOrdEndDes:ExceptEnd()
		// Atribui demais informa��es
		Self:SetQuant((cAliasNew)->D0F_QTDDIS)
		// Dever� grava na ordem de servi�o as informa��es pois s�o utilizadas na gera��o das atividades
		Self:UpdateDCF(.F.)
		lRet := Self:ExecutePrd()
		(cAliasNew)->(dbSkip())
	EndDo
	(cAliasNew)->(dbCloseArea())
	If lRet .And. lCarregou
		// Recarrega a ordem de servi�o para atualiza��o das informa��es
		// Atribui dados endereco destino
		Self:oOrdEndDes:SetArmazem(oOrdServAux:oOrdEndDes:GetArmazem())
		Self:oOrdEndDes:SetEnder(oOrdServAux:oOrdEndDes:GetEnder()) // Endere�o Origem
		Self:oOrdEndDes:LoadData()
		Self:oOrdEndDes:ExceptEnd()
		// Atribui o produto origem ao movimento
		// Demais informa��es
		Self:SetQuant(oOrdServAux:GetQuant())
		// Dever� atualizar a ordem de servi�o com as informa��es originais
		Self:UpdateDCF(.F.)
	EndIf
Return lRet

//--------------------------------------------------
/*/{Protheus.doc} UpdEndDes
Atualiza endere�o destino antes de gerar D12
@author amanda.vieira
@since 24/11/2016
@version 1.0
@param cNewEnd, character, (Novo endere�o)
/*/
//--------------------------------------------------
METHOD UpdEndDes(cNewEnd) CLASS DAXWMSOrdemServicoExecute
Local lRet      := .T.
Local lEndOri   := !Empty(Self:oOrdEndOri:GetEnder())
Local  cSrv		 := SuperGetMV('ES_SERVDIS',.T.,'019',cFilAnt)
Local  cSegSepara	 := SuperGetMV('ES_SERVSEP',.T.,'025',cFilAnt)

	// Verifica se endere�o origem preenchi
	// Desfaz saida e entrada prevista
	If lEndOri
		lRet := Self:ReverseMI()
	EndIf
	// Atualiza endere�o destino
	If lRet
		Self:oOrdEndDes:SetEnder(cNewEnd)
		Self:UpdateDCF(.F.)
	EndIf
	// Verifca se endere�o origem preechido
	// Refaz saida e entrada prevista
	If lRet .And. lEndOri
		lRet := Self:MakeInput()
	EndIf
	 // Atualiza documentos com o endere�o destino
	If lRet
		If Self:cOrigem == "DH1"
			// Atualiza o endere�o na DH1 quando foi informado.
			DH1->(dbSetOrder(1)) // DH1_FILIAL+DH1_DOC+DH1_LOCAL+DH1_NUMSEQ
			DH1->(dbSeek(xFilial("DH1")+Self:cDocumento+Self:oOrdEndOri:GetArmazem()+Self:cNumSeq))
			Do While DH1->(!Eof()) .And. xFilial("DH1")+Self:cDocumento+Self:oOrdEndOri:GetArmazem()+Self:cNumSeq == DH1->(DH1_FILIAL+DH1_DOC+DH1_LOCAL+DH1_NUMSEQ)
				If Self:cIdDCF == DH1->DH1_IDDCF
					RecLock('DH1',.F.)
					DH1->DH1_LOCALI := cNewEnd
					DH1->(MsUnLock())
				EndIf
				DH1->(dbSkip())
			EndDo
		ElseIf Self:cOrigem == "SC9"
			SC9->(dbSetOrder(9)) // C9_FILIAL+C9_IDDCF
			If SC9->(dbSeek(xFilial("SC9")+Self:cIdDCF))
				SC6->(dbSetOrder(1)) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
				If SC6->(dbSeek(xFilial("SC6")+SC9->(C9_PEDIDO+C9_ITEM+C9_PRODUTO)))
					If DCF->DCF_SERVIC <> cSrv .And. DCF->DCF_SERVIC <> cSegSepara //RODOLFO - TRATAMENTO PARA NAO GRAVAR A C6
						RecLock('SC6',.F.)
						SC6->C6_ENDPAD := cNewEnd
						SC6->(MsUnLock())
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
Return lRet

//--------------------------------------------------
/*/{Protheus.doc} UpdEndOri
Atualiza endere�o origem antes de gerar D12
@author amanda.vieira
@since 24/11/2016
@version 1.0
@param cNewEnd, character, (Novo endere�o)
/*/
//--------------------------------------------------
METHOD UpdEndOri(cNewEnd) CLASS DAXWMSOrdemServicoExecute
Local lRet      := .T.
	// Desfaz o saldo do endere�o origem
	lRet := Self:ReverseMA()
	// Atualiza endere�o origem
	If lRet
		Self:oOrdEndOri:SetEnder(cNewEnd)
		Self:UpdateDCF()
	EndIf
	// Refaz saldo no endere�o origem
	If lRet
		lRet := Self:MakeArmaz()
	EndIf
	// Atualiza endere�o origem
	If lRet .And. Self:cOrigem == "DH1"
		// Atualiza o endere�o na DH1 quando foi informado.
		DH1->(dbSetOrder(1)) // DH1_FILIAL+DH1_DOC+DH1_LOCAL+DH1_NUMSEQ
		DH1->(dbSeek(xFilial("DH1")+Self:cDocumento+Self:oOrdEndDes:GetArmazem()+Self:cNumSeq))
		Do While DH1->(!Eof()) .And. xFilial("DH1")+Self:cDocumento+Self:oOrdEndDes:GetArmazem()+Self:cNumSeq == DH1->(DH1_FILIAL+DH1_DOC+DH1_LOCAL+DH1_NUMSEQ)
			If Self:cIdDCF == DH1->DH1_IDDCF
				RecLock('DH1',.F.)
				DH1->DH1_LOCALI := cNewEnd
				DH1->(MsUnLock())
			EndIf
			DH1->(dbSkip())
		EndDo
	EndIf
Return lRet

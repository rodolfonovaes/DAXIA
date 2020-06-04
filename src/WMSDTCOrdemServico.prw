#Include "Totvs.ch"
#Include "WMSDTCOrdemServico.ch"
//---------------------------------------------
/*/{Protheus.doc} WMSCLS0029
Função para permitir que a classe seja visualizada
no inspetor de objetos
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0029()
Return Nil
//----------------------------------------
/*/{Protheus.doc} WMSDTCOrdemServico
Classe ordem de serviço
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//----------------------------------------
CLASS WMSDTCOrdemServico FROM LongClassName
	// Data
	DATA lHasUniDes // Utilizado para suavizar o campo DCF_UNIDES
	DATA lHasCodUni // Utilizado para suavizar o campo D14_CODUNI
	DATA lHasIdMvOr // Utilizado para suavizar o campo DCF_IDMVOR
	DATA lHasHora   // Utilizado para suavizar o campo DCF_HORA
	DATA oProdLote
	DATA oOrdEndOri
	DATA oOrdEndDes
	DATA oServico
	DATA cDocumento
	DATA cSerieDoc
	DATA cSerie
	DATA cCliFor
	DATA cLoja
	DATA cOrigem
	DATA cNumSeq
	DATA nQuant
	DATA nQuant2
	DATA nQtdOri
	DATA nQtdDel
	DATA dData
	DATA cHora
	DATA cStServ
	DATA cRegra
	DATA cPriori
	DATA cCodFun
	DATA cCarga
	DATA cIdUnitiz
	DATA cUniDes
	DATA cTipUni
	DATA cCodNorma
	DATA cStRadi
	DATA cIdDCF
	DATA cSequen
	DATA cCodRec
	DATA cIdOrigem
	DATA cDocPen
	DATA cOk
	DATA aWmsAviso AS array
	DATA aLibD12   AS array
	DATA aLibDCF   AS array // Ordens de serviço criadas e liberadas para execução automatica
	DATA aOrdReab  AS Array // Ordens de serviço de reabastecimento de complemento para estorno
	DATA lLogSld
	DATA lLogEnd
	DATA lLogEndUni
	DATA lForceDtHr
	DATA nRecno
	DATA cErro
	DATA cSeqPriExe
	DATA cCodPln
	DATA cOp
	DATA cTrt
	DATA nProduto
	DATA nTarefa
	DATA cCodMntVol
	DATA cCodDisSep
	DATA cConfExped
	DATA cIdMovOrig
	// Controle dados anteriores
	DATA cServicAnt
	DATA cDoctoAnt
	DATA cIdDCFAnt
	// Method
	METHOD New() CONSTRUCTOR
	METHOD GoToDCF(nRecno)
	METHOD LockDCF()
	METHOD UnLockDCF()
	METHOD LoadData(nIndex)
	METHOD SetIdDCF(cIdDCF)
	METHOD SetSequen(cSequen)
	METHOD SetIdOrig(cIdOrigem)
	METHOD SetNumSeq(cNumSeq)
	METHOD SetDocto(cDocumento)
	METHOD SetSerie(cSerie)
	METHOD SetCliFor(cCliFor)
	METHOD SetLoja(cLoja)
	METHOD SetServico(cServico)
	METHOD SetStServ(cStServ)
	METHOD SetOrigem(cOrigem)
	METHOD SetCarga(cCarga)
	METHOD SetCodRec(cCodRec)
	METHOD SetQuant(nQuant)
	METHOD SetOk(cOk)
	METHOD SetRegra(cRegra)
	METHOD SetQtdOri(nQtdOri)
	METHOD SetArrLib(aLibD12)
	METHOD SetData(dData)
	METHOD SetHora(cHora)
	METHOD SetCodPln(cCodPln)
	METHOD SetIdUnit(cIdUnit)
	METHOD SetUniDes(cUniDes)
	METHOD SetTipUni(cTipUni)
	METHOD SetIdMovOr(cIdMovOrig)
	METHOD SetOp(cOp)
	METHOD SetTrt(cTrt)
	METHOD GetIdDCF()
	METHOD GetSequen()
	METHOD GetIdOrig()
	METHOD GetNumSeq()
	METHOD GetDocto()
	METHOD GetSerie()
	METHOD GetCliFor()
	METHOD GetLoja()
	METHOD GetServico()
	METHOD GetStServ()
	METHOD GetOrigem()
	METHOD GetCodNor()
	METHOD GetCarga()
	METHOD GetCodRec()
	METHOD GetQuant()
	METHOD GetQuant2()
	METHOD GetOk()
	METHOD GetRegra()
	METHOD GetRecNo()
	METHOD GetQtdOri()
	METHOD GetArrLib()
	METHOD GetData()
	METHOD GetHora()
	METHOD GetDocPen()
	METHOD GetErro()
	METHOD GetCodPln()
	METHOD GetIdUnit()
	METHOD GetUniDes()
	METHOD GetTipUni()
	METHOD GetIdMovOr()
	METHOD GetOp()
	METHOD GetTrt()
	METHOD ExcludeDCF()
	METHOD CancelDCF()
	METHOD RecordDCF()
	METHOD UpdateDCF(lMsUnLock)
	METHOD UpdStatus()
	METHOD UndoIntegr()
	METHOD UpdIntegra()
	METHOD UpdServic()
	METHOD CancelSC9(lEstPed,nRecnoSC9,nQtdQuebra,lPedFat)
	METHOD HaveMovD12(cAcao)
	METHOD MakeArmaz()
	METHOD UndoArmaz()
	METHOD ReverseMA()
	METHOD ReverseMI(nQtdEst)
	METHOD ReverseMO(nQtdEst)
	METHOD MakeOutput()
	METHOD MakeInput()
	METHOD MakeConv()
	METHOD UndoConv()
	METHOD SaiMovEst()
	METHOD ChkOrdDep()
	METHOD ChkDepPend(cIdDCF)
	METHOD FindDocto()
	METHOD ExisteDCF()
	METHOD UpdEndDCF(cEndereco,lEndVazio)
	METHOD ChkDistr()
	METHOD UndoMntDes()
	METHOD HaveMovD0A()
	METHOD ShowWarnig()
	METHOD HasLogEnd()
	METHOD HasLogSld()
	METHOD HasLogUni()
	METHOD ForceDtHr()
	METHOD AtuMovSD3(lMovAut)
	METHOD MovSD3Estr(lMovAut,lMontagem)
	METHOD MovSD3Prod(lMovAut,lMontagem)
	METHOD MovSD3Lote(lMovAut)
	METHOD UndoMovSD3()
	METHOD UpdEmpSD4(lEstorno)
	METHOD UpdLibD0A(cIdMovto,cIdOpera)
	METHOD UpdEmpSB2(cOper,cPrdOri,cArmazem,nQuant,lReserva,cTipOp)
	METHOD UpdEmpSB8(cOper,cPrdOri,cArmazem,cLoteCtl,cNumLote,nQuant)
	METHOD Destroy()
	METHOD GetSeqPri()
	METHOD FindSeqPri()
	METHOD FindDCFOri()
	METHOD NextSeqPri(cParametro, cField)
	METHOD EstParcial(nRecnoSC9,nQtdQuebra,lPedLib)
	METHOD ChkOrdReab()
	METHOD ChkQtdRes()
	METHOD ChkMovEst(lEndOri)
	METHOD CanEstReab()
	METHOD IsMovUnit()
ENDCLASS
//----------------------------------------
/*/{Protheus.doc} New
Método construtor
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//----------------------------------------
METHOD New() CLASS WMSDTCOrdemServico
	Self:lHasUniDes := WmsX312118("DCF","DCF_UNIDES")
	Self:lHasCodUni := WmsX312118("D14","D14_CODUNI")
	Self:lHasIdMvOr := WmsX312118("DCF","DCF_IDMVOR")
	Self:lHasHora   := WmsX312123("DCF","DCF_HORA")
	Self:oProdLote := WMSDTCProdutoLote():New()
	Self:oOrdEndOri:= WMSDTCEndereco():New()
	Self:oOrdEndDes:= WMSDTCEndereco():New()
	Self:oServico  := WMSDTCServicoTarefa():New()
	// Atribui demais campos
	Self:cIdDCF    := PadR("", TamSx3("DCF_ID")[1])
	Self:cSequen   := PadR("01", TamSx3("DCF_SEQUEN")[1])
	Self:cDocumento:= Space(TamSx3("DCF_DOCTO")[1])
	Self:cSerieDoc := Space(TamSx3("DCF_SERIE")[1]) // DCF->DCF_SDOC
	Self:cSerie    := Space(TamSx3("DCF_SERIE")[1])
	Self:cCliFor   := Space(TamSx3("DCF_CLIFOR")[1])
	Self:cLoja     := Space(TamSx3("DCF_LOJA")[1])
	Self:cOrigem   := Space(TamSx3("DCF_ORIGEM")[1])
	Self:cIdOrigem := Space(TamSx3("DCF_IDORI")[1])
	Self:cNumSeq   := Space(TamSx3("DCF_NUMSEQ")[1])
	Self:cCodRec   := Space(TamSx3("DCF_CODREC")[1])
	Self:cDocPen   := Space(TamSx3("DCF_DOCPEN")[1])
	Self:nQtdOri   := 0
	Self:nQuant    := 0
	Self:nQuant2   := 0
	Self:nQtdDel   := 0
	Self:dData     := dDataBase
	Self:cHora     := Space(IIf(Self:lHasHora,TamSx3("DCF_HORA")[1],8))
	Self:cStServ   := Space(TamSx3("DCF_STSERV")[1])
	Self:cRegra    := Space(TamSx3("DCF_REGRA")[1])
	Self:cPriori   := Space(TamSx3("DCF_PRIORI")[1])
	Self:cCodFun   := Space(TamSx3("DCF_CODFUN")[1])
	Self:cCarga    := Space(TamSx3("DCF_CARGA")[1])
	Self:cIdUnitiz := Space(TamSx3("DCF_UNITIZ")[1])
	Self:cUniDes   := Space(IIf(Self:lHasUniDes,TamSx3("DCF_UNIDES")[1],6))
	Self:cTipUni   := Space(IIf(Self:lHasCodUni,TamSx3("D14_CODUNI")[1],6))
	Self:cCodNorma := Space(TamSx3("DCF_CODNOR")[1])
	Self:cStRadi   := Space(TamSx3("DCF_STRADI")[1])
	Self:cIdMovOrig:= Space(IIf(Self:lHasIdMvOr,TamSx3("DCF_IDMVOR")[1],6))
	Self:cOp       := Space(TamSx3("D4_OP")[1])
	Self:cTrt      := Space(TamSx3("D4_TRT")[1])
	Self:aWmsAviso := {}
	Self:aLibDCF   := {}
	Self:aOrdReab  := {}
	Self:lLogEnd   := .F.
	Self:lLogSld   := .F.
	Self:lLogEndUni:= .F.
	Self:lForceDtHr:= .T.
	Self:cErro     := ""
	Self:nRecno    := 0
	// Controle dados anteriores
	Self:cServicAnt:= Space(TamSx3("DCF_SERVIC")[1])
	Self:cDoctoAnt := Space(TamSx3("DCF_DOCTO")[1])
	Self:cIdDCFAnt := Space(TamSx3("DCF_ID")[1])
	Self:cSeqPriExe:= ""
	Self:nProduto  := 0
	Self:nTarefa   := 0
Return

METHOD Destroy() CLASS WMSDTCOrdemServico
	FreeObj(Self)
Return Nil
//----------------------------------------
/*/{Protheus.doc} HasLogEnd
Seta log de endereço
@author felipe.m
@since 23/12/2014
@version 1.0
@param lLogEnd, ${logico}, (Descrição do parâmetro)
/*/
//----------------------------------------
METHOD HasLogEnd(lLogEnd) CLASS WMSDTCOrdemServico
	If ValType(lLogEnd) == 'L'
		Self:lLogEnd := lLogEnd
	EndIf
Return Self:lLogEnd
//----------------------------------------
/*/{Protheus.doc} HasLogSld
Seta log de saldo
@author felipe.m
@since 23/12/2014
@version 1.0
@param lLogSld, ${logico}, (Descrição do parâmetro)
/*/
//----------------------------------------
METHOD HasLogSld(lLogSld) CLASS WMSDTCOrdemServico
	If ValType(lLogSld) == 'L'
		Self:lLogSld := lLogSld
	EndIf
Return Self:lLogSld
//----------------------------------------
/*/{Protheus.doc} HasLogUni
Seta log de enderecamento unitizado
@author  Guilherme A. Metzger
@since   27/04/2017
@version 1.0
/*/
//----------------------------------------
METHOD HasLogUni(lLogEndUni) CLASS WMSDTCOrdemServico
	If ValType(lLogEndUni) == 'L'
		Self:lLogEndUni := lLogEndUni
	EndIf
Return Self:lLogEndUni
//----------------------------------------
/*/{Protheus.doc} ForceDtHr
Seta log se força data e hora do sistema
@author  Squad WMS/Protheus
@since   27/08/2018
@version 1.0
/*/
//----------------------------------------
METHOD ForceDtHr(lForceDtHr) CLASS WMSDTCOrdemServico
	If ValType(lForceDtHr) == 'L'
		Self:lForceDtHr := lForceDtHr
	EndIf
Return Self:lForceDtHr
//----------------------------------------
/*/{Protheus.doc} GoToDCF
Posicionamento para atualização das propriedades
@author felipe.m
@since 23/12/2014
@version 1.0
@param nRecno, numérico, (Descrição do parâmetro)
/*/
//----------------------------------------
METHOD GoToDCF(nRecno) CLASS WMSDTCOrdemServico
	Self:nRecno := nRecno
Return Self:LoadData(0)
//----------------------------------------
/*/{Protheus.doc} LockDCF
Prende a tabela para alteração DCF
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//----------------------------------------
METHOD LockDCF() CLASS WMSDTCOrdemServico
Local lRet := .T.
	DCF->(dbGoTo(Self:nRecno))
	If !DCF->(SimpleLock())
		lRet := .F.
		Self:cErro := STR0002 // Lock não foi efetuado!
	Else
		Self:cStServ := DCF->DCF_STSERV
	EndIf
Return lRet
//----------------------------------------
/*/{Protheus.doc} UnLockDCF
Libera a tabela para alteração DCF
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//----------------------------------------
METHOD UnLockDCF() CLASS WMSDTCOrdemServico
	DCF->(dbGoTo(Self:nRecno))
Return DCF->(MsUnlock())
//----------------------------------------
/*/{Protheus.doc} LoadData
Carregamento dos dados DCF
@author felipe.m
@since 23/12/2014
@version 1.0
@param nIndex, numérico, (Descrição do parâmetro)
/*/
//----------------------------------------
METHOD LoadData(nIndex) CLASS WMSDTCOrdemServico
Local aAreaAnt    := GetArea()
Local lRet        := .T.
Local cQuery      := ""
Local cAliasDCF   := ""
Local aAreaDCF    := DCF->(GetArea())
Local aDCF_QTDORI := TamSx3("DCF_QTDORI")
Local aDCF_QUANT  := TamSx3("DCF_QUANT")
Local aDCF_QTSEUM := TamSx3("DCF_QTSEUM")
Local lCarrega    := .T.
	Default nIndex := 9
	Do Case
		Case nIndex == 0 // R_E_C_N_O_
		If Empty(Self:nRecno)
			lRet := .F.
		EndIf
		Case nIndex == 3 // DCF_FILIAL+DCF_SERVIC+DCF_CODPRO+DCF_DOCTO+DCF_SERIE+DCF_CLIFOR+DCF_LOJA
		If (Empty(Self:GetServico()) .Or. Empty(Self:oProdLote:GetProduto()) .Or. Empty(Self:GetDocto()))
			lRet := .F.
		Else
			If Self:GetServico() == Self:cServicAnt .And. Self:oProdLote:GetProduto() == Self:cProdutAnt .And. Self:GetDocto() == Self:cDoctoAnt
				lCarrega := .F.
			EndIf
		EndIf
		Case nIndex == 9 // DCF_FILIAL+DCF_ID
		If Empty(Self:cIdDCF)
			lRet := .F.
		Else
			If Self:cIdDCF == Self:cIdDCFAnt
				lCarrega := .F.
			EndIf
		EndIf
		Otherwise
		lRet := .F.
	EndCase
	If !lRet
		Self:cErro := STR0004 // Dados para busca não foram informados!
	Else
		If lCarrega
			cQuery := "SELECT DCF.DCF_LOCAL,"
			cQuery +=       " DCF.DCF_ENDER,"
			cQuery +=       " DCF.DCF_LOCDES,"
			cQuery +=       " DCF.DCF_ENDDES,"
			cQuery +=       " DCF.DCF_PRDORI,"
			cQuery +=       " DCF.DCF_CODPRO,"
			cQuery +=       " DCF.DCF_LOTECT,"
			cQuery +=       " DCF.DCF_NUMLOT,"
			cQuery +=       " DCF.DCF_SERVIC,"
			cQuery +=       " DCF.DCF_DOCTO,"
			cQuery +=       " DCF.DCF_SERIE ,"
			cQuery +=       " DCF.DCF_CLIFOR,"
			cQuery +=       " DCF.DCF_LOJA,"
			cQuery +=       " DCF.DCF_ORIGEM,"
			cQuery +=       " DCF.DCF_NUMSEQ,"
			cQuery +=       " DCF.DCF_QTDORI,"
			cQuery +=       " DCF.DCF_QUANT,"
			cQuery +=       " DCF.DCF_QTSEUM,"
			cQuery +=       " DCF.DCF_DATA,"
			If Self:lHasHora
				cQuery +=       " DCF.DCF_HORA,"
			EndIf
			cQuery +=       " DCF.DCF_STSERV,"
			cQuery +=       " DCF.DCF_REGRA,"
			cQuery +=       " DCF.DCF_PRIORI,"
			cQuery +=       " DCF.DCF_CODFUN,"
			cQuery +=       " DCF.DCF_CARGA,"
			cQuery +=       " DCF.DCF_UNITIZ,"
			If Self:lHasUniDes
				cQuery +=    " DCF.DCF_UNIDES,"
			EndIf
			If Self:lHasIdMvOr
				cQuery +=    " DCF.DCF_IDMVOR,"
			EndIf
			cQuery +=       " DCF.DCF_CODNOR,"
			cQuery +=       " DCF.DCF_STRADI,"
			cQuery +=       " DCF.DCF_ID,"
			cQuery +=       " DCF.DCF_SEQUEN,"
			cQuery +=       " DCF.DCF_IDORI,"
			cQuery +=       " DCF.DCF_OK,"
			cQuery +=       " DCF.DCF_CODREC,"
			cQuery +=       " DCF.DCF_DOCPEN,"
			cQuery +=       " DCF.DCF_CODPLN,"
			cQuery +=       " DCF.R_E_C_N_O_ RECNODCF"
			cQuery +=  " FROM "+RetSqlName('DCF')+" DCF"
			cQuery += " WHERE DCF.DCF_FILIAL = '"+xFilial('DCF')+"'"
			Do Case
				Case nIndex == 0 // R_E_C_N_O_
				cQuery += " AND DCF.R_E_C_N_O_ = " + AllTrim(Str(Self:nRecno))
				Case nIndex == 3 // DCF_FILIAL+DCF_SERVIC+DCF_CODPRO+DCF_DOCTO+DCF_SERIE+DCF_CLIFOR+DCF_LOJA
				cQuery += " AND DCF.DCF_SERVIC = '" + Self:GetServico() + "'"
				cQuery += " AND DCF.DCF_CODPRO = '" + Self:oProdLote:GetProduto() + "'"
				If !Empty(Self:GetDocto())
					cQuery += " AND DCF.DCF_DOCTO = '" + Self:GetDocto() + "'"
				EndIf
				If !Empty(Self:GetSerie())
					cQuery += " AND DCF.DCF_SERIE = '" + Self:GetSerie() + "'"
				EndIf
				If !Empty(Self:GetCliFor())
					cQuery += " AND DCF.DCF_CLIFOR = '" + Self:GetCliFor() + "'"
				EndIf
				If !Empty(Self:GetLoja())
					cQuery += " AND DCF.DCF_LOJA = '" + Self:GetLoja() + "'"
				EndIf
				Case nIndex == 9 // DCF_FILIAL+DCF_ID
				cQuery += " AND DCF.DCF_ID = '" + Self:cIdDCF + "'"
			EndCase
			If nIndex > 0
				cQuery += " AND DCF.DCF_STSERV <> '0'"
			EndIf
			cQuery +=   " AND DCF.D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			cAliasDCF:= GetNextAlias()
			DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasDCF,.F.,.T.)
			TCSetField(cAliasDCF,'DCF_QTDORI','N',aDCF_QTDORI[1],aDCF_QTDORI[2])
			TCSetField(cAliasDCF,'DCF_QUANT' ,'N',aDCF_QUANT[1] ,aDCF_QUANT[2])
			TCSetField(cAliasDCF,'DCF_QTSEUM','N',aDCF_QTSEUM[1],aDCF_QTSEUM[2])
			TcSetField(cAliasDCF,'DCF_DATA','D')
			If (lRet := (cAliasDCF)->(!Eof()))
				// Busca dados endereco origem
				Self:oOrdEndOri:SetArmazem((cAliasDCF)->DCF_LOCAL)
				Self:oOrdEndOri:SetEnder((cAliasDCF)->DCF_ENDER)
				Self:oOrdEndOri:LoadData()
				// Busca dados endereco destino
				Self:oOrdEndDes:SetArmazem((cAliasDCF)->DCF_LOCDES)
				Self:oOrdEndDes:SetEnder((cAliasDCF)->DCF_ENDDES)
				Self:oOrdEndDes:LoadData()
				// Busca dados lote/produto
				Self:oProdLote:SetArmazem((cAliasDCF)->DCF_LOCAL)
				Self:oProdLote:SetPrdOri((cAliasDCF)->DCF_PRDORI)
				Self:oProdLote:SetProduto((cAliasDCF)->DCF_CODPRO)
				Self:oProdLote:SetLoteCtl((cAliasDCF)->DCF_LOTECT)
				Self:oProdLote:SetNumLote((cAliasDCF)->DCF_NUMLOT)
				Self:oProdLote:SetNumSer("")
				Self:oProdLote:LoadData()
				// Atribui dados servico
				Self:oServico:SetServico((cAliasDCF)->DCF_SERVIC)
				Self:oServico:LoadData()
				// Atribui dados aos demais campos
				Self:cDocumento:= (cAliasDCF)->DCF_DOCTO
				Self:cSerieDoc := (cAliasDCF)->DCF_SERIE // DCF->DCF_SDOC
				Self:cSerie    := (cAliasDCF)->DCF_SERIE
				Self:cCliFor   := (cAliasDCF)->DCF_CLIFOR
				Self:cLoja     := (cAliasDCF)->DCF_LOJA
				Self:cOrigem   := (cAliasDCF)->DCF_ORIGEM
				Self:cNumSeq   := (cAliasDCF)->DCF_NUMSEQ
				Self:nQtdOri   := (cAliasDCF)->DCF_QTDORI
				Self:nQuant    := (cAliasDCF)->DCF_QUANT
				Self:nQuant2   := (cAliasDCF)->DCF_QTSEUM
				Self:dData     := (cAliasDCF)->DCF_DATA
				If Self:lHasHora
					Self:cHora     := (cAliasDCF)->DCF_HORA
				EndIf
				Self:cStServ   := (cAliasDCF)->DCF_STSERV
				Self:cRegra    := (cAliasDCF)->DCF_REGRA
				Self:cPriori   := (cAliasDCF)->DCF_PRIORI
				Self:cCodFun   := (cAliasDCF)->DCF_CODFUN
				Self:cCarga    := (cAliasDCF)->DCF_CARGA
				Self:cIdUnitiz := (cAliasDCF)->DCF_UNITIZ
				If Self:lHasUniDes
					Self:cUniDes   := (cAliasDCF)->DCF_UNIDES
				EndIf
				If Self:lHasIdMvOr
					Self:cIdMovOrig:= (cAliasDCF)->DCF_IDMVOR
				EndIf
				Self:cCodNorma := (cAliasDCF)->DCF_CODNOR
				Self:cStRadi   := (cAliasDCF)->DCF_STRADI
				Self:cIdDCF    := (cAliasDCF)->DCF_ID
				Self:cSequen   := (cAliasDCF)->DCF_SEQUEN
				Self:cIdOrigem := (cAliasDCF)->DCF_IDORI
				Self:cOk       := (cAliasDCF)->DCF_OK
				Self:cCodRec   := (cAliasDCF)->DCF_CODREC
				Self:cDocPen   := (cAliasDCF)->DCF_DOCPEN
				Self:cCodPln   := (cAliasDCF)->DCF_CODPLN
				Self:nRecno    := (cAliasDCF)->RECNODCF
				// Controle dados anteriores
				Self:cServicAnt:= Self:GetServico()
				Self:cDoctoAnt := Self:GetDocto()
				Self:cIdDCFAnt := Self:cIdDCF
				Self:cSeqPriExe:= "" // Limpa para forçar uma nova busca
			Else
				Self:cErro := WmsFmtMsg(STR0010,{{"[VAR01]",AllTrim(Self:cIdDCF)}})// Ordem de serviço para o identificador [VAR01] não cadastrado!
			EndIf
			(cAliasDCF)->(dbCloseArea())
		EndIf
	EndIf
	RestArea(aAreaDCF)
	RestArea(aAreaAnt)
Return lRet
//----------------------------------------
// Setters
//----------------------------------------
METHOD SetIdDCF(cIdDCF) CLASS WMSDTCOrdemServico
	Self:cIdDCF := PadR(cIdDCF, TamSx3("D12_IDDCF")[1])
Return

METHOD SetSequen(cSequen) CLASS WMSDTCOrdemServico
	Self:cSequen := PadR(cSequen, TamSx3("DCF_SEQUEN")[1])
Return

METHOD SetIdOrig(cIdOrigem) CLASS WMSDTCOrdemServico
Local aAreaDCF := DCF->(GetArea())

	If !Empty(cIdOrigem)
		DCF->(dbSetOrder(9)) // DCF_FILIAL+DCF_ID
		DCF->(dbSeek(xFilial("DCF")+ PadR(cIdOrigem, TamSx3("DCF_IDORI")[1])))
		Self:cDocPen := DCF->DCF_DOCTO
	Else
		Self:cDocPen := PadR("", TamSx3("DCF_IDORI")[1])
	EndIf
	Self:cIdOrigem  := PadR(cIdOrigem, TamSx3("DCF_IDORI")[1])

	RestArea(aAreaDCF)
Return

METHOD SetNumSeq(cNumSeq) CLASS WMSDTCOrdemServico
	Self:cNumSeq := PadR(cNumSeq, TamSx3("DCF_NUMSEQ")[1])
Return

METHOD SetDocto(cDocumento) CLASS WMSDTCOrdemServico
	Self:cDocumento := PadR(cDocumento, TamSx3("DCF_DOCTO")[1])
Return

METHOD SetSerie(cSerie) CLASS WMSDTCOrdemServico
	Self:cSerie := PadR(cSerie, TamSx3("DCF_SERIE")[1])
Return

METHOD SetCliFor(cCliFor) CLASS WMSDTCOrdemServico
	Self:cCliFor := PadR(cCliFor, TamSx3("DCF_CLIFOR")[1])
Return

METHOD SetLoja(cLoja) CLASS WMSDTCOrdemServico
	Self:cLoja := PadR(cLoja, TamSx3("DCF_LOJA")[1])
Return

METHOD SetServico(cServico) CLASS WMSDTCOrdemServico
	Self:oServico:SetServico(cServico)
Return

METHOD SetStServ(cStatus) CLASS WMSDTCOrdemServico
	Self:cStServ := PadR(cStatus, TamSx3("DCF_STSERV")[1])
Return

METHOD SetCarga(cCarga) CLASS WMSDTCOrdemServico
	Self:cCarga := PadR(cCarga, TamSx3("DCF_CARGA")[1])
Return

METHOD SetCodRec(cCodRec) CLASS WMSDTCOrdemServico
	Self:cCodRec := PadR(cCodRec, TamSx3("DCF_CODREC")[1])
Return

METHOD SetOrigem(cOrigem) CLASS WMSDTCOrdemServico
	Self:cOrigem := PadR(cOrigem, TamSx3("DCF_ORIGEM")[1])
Return

METHOD SetQuant(nQuant) CLASS WMSDTCOrdemServico
	Self:nQuant := nQuant
Return

METHOD SetOk(cOk) CLASS WMSDTCOrdemServico
	Self:cOk := PadR(cOk, TamSx3("DCF_OK")[1])
Return

METHOD SetRegra(cRegra) CLASS WMSDTCOrdemServico
	Self:cRegra := PadR(cRegra, TamSx3("DCF_REGRA")[1])
Return

METHOD SetQtdOri(nQtdOri) CLASS WMSDTCOrdemServico
	Self:nQtdOri := nQtdOri
Return

METHOD SetArrLib(aLibD12) CLASS WMSDTCOrdemServico
	Self:aLibD12 := aLibD12
Return

METHOD SetData(dData) CLASS WMSDTCOrdemServico
	Self:dData := dData
Return

METHOD SetHora(cHora) CLASS WMSDTCOrdemServico
	Self:cHora := cHora
Return

METHOD SetCodPln(cCodPln) CLASS WMSDTCOrdemServico
	Self:cCodPln := cCodPln
Return

METHOD SetIdUnit(cIdUnit) CLASS WMSDTCOrdemServico
	Self:cIdUnitiz := PadR(cIdUnit, TamSx3("DCF_UNITIZ")[1])
Return

METHOD SetUniDes(cUniDes) CLASS WMSDTCOrdemServico
	Self:cUniDes := PadR(cUniDes, IIf(Self:lHasUniDes,TamSx3("DCF_UNIDES")[1],6))
Return

METHOD SetTipUni(cTipUni) CLASS WMSDTCOrdemServico
	Self:cTipUni := PadR(cTipUni, IIf(Self:lHasCodUni,TamSx3("D14_CODUNI")[1],6))
Return

METHOD SetIdMovOr(cIdMovOrig) CLASS WMSDTCOrdemServico
	Self:cIdMovOrig := PadR(cIdMovOrig, IIf(Self:lHasIdMvOr,TamSx3("DCF_IDMVOR")[1],6))
Return

METHOD SetOp(cOp) CLASS WMSDTCOrdemServico
	Self:cOp := PadR(cOp, TamSx3("D4_OP")[1])
Return

METHOD SetTrt(cTrt) CLASS WMSDTCOrdemServico
	Self:cTrt := PadR(cTrt, TamSx3("D4_TRT")[1])
Return

//----------------------------------------
// Getters
//----------------------------------------
METHOD GetIdDCF() CLASS WMSDTCOrdemServico
Return Self:cIdDCF

METHOD GetSequen() CLASS WMSDTCOrdemServico
Return Self:cSequen

METHOD GetIdOrig() CLASS WMSDTCOrdemServico
Return Self:cIdOrigem

METHOD GetNumSeq() CLASS WMSDTCOrdemServico
Return Self:cNumSeq

METHOD GetDocto() CLASS WMSDTCOrdemServico
Return Self:cDocumento

METHOD GetSerie() CLASS WMSDTCOrdemServico
Return Self:cSerie

METHOD GetCliFor() CLASS WMSDTCOrdemServico
Return Self:cCliFor

METHOD GetLoja() CLASS WMSDTCOrdemServico
Return Self:cLoja

METHOD GetServico() CLASS WMSDTCOrdemServico
Return Self:oServico:GetServico()

METHOD GetStServ() CLASS WMSDTCOrdemServico
Return Self:cStServ

METHOD GetOrigem() CLASS WMSDTCOrdemServico
Return Self:cOrigem

METHOD GetCodNor() CLASS WMSDTCOrdemServico
Return Self:cCodNorma

METHOD GetCarga() CLASS WMSDTCOrdemServico
Return Self:cCarga

METHOD GetCodRec() CLASS WMSDTCOrdemServico
Return Self:cCodRec

METHOD GetQuant() CLASS WMSDTCOrdemServico
Return Self:nQuant

METHOD GetQuant2() CLASS WMSDTCOrdemServico
Return Self:nQuant2

METHOD GetRegra() CLASS WMSDTCOrdemServico
Return Self:cRegra

METHOD GetOk() CLASS WMSDTCOrdemServico
Return Self:cOk

METHOD GetRecno() CLASS WMSDTCOrdemServico
Return Self:nRecno

METHOD GetQtdOri() CLASS WMSDTCOrdemServico
Return Self:nQtdOri

METHOD GetArrLib() CLASS WMSDTCOrdemServico
Return Self:aLibD12

METHOD GetData() CLASS WMSDTCOrdemServico
Return Self:dData

METHOD GetHora() CLASS WMSDTCOrdemServico
Return Self:cHora

METHOD GetDocPen() CLASS WMSDTCOrdemServico
Return Self:cDocPen

METHOD GetErro() CLASS WMSDTCOrdemServico
Return Self:cErro

METHOD GetCodPln() CLASS WMSDTCOrdemServico
Return Self:cCodPln

METHOD GetIdUnit() CLASS WMSDTCOrdemServico
Return Self:cIdUnitiz

METHOD GetUniDes() CLASS WMSDTCOrdemServico
Return Self:cUniDes

METHOD GetTipUni() CLASS WMSDTCOrdemServico
Return Self:cTipUni

METHOD GetIdMovOr() CLASS WMSDTCOrdemServico
Return Self:cIdMovOrig

METHOD GetOp() CLASS WMSDTCOrdemServico
Return Self:cOp

METHOD GetTrt() CLASS WMSDTCOrdemServico
Return Self:cTrt

//----------------------------------------
/*/{Protheus.doc} RecordDCF
Gravação dos dados DCF
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//----------------------------------------
METHOD RecordDCF() CLASS WMSDTCOrdemServico
Local lRet     := .T.
Local aAreaDCF := DCF->(GetArea())
	Self:cIdDCF  := WMSProxSeq('MV_DOCSEQ','DCF_ID')
	// Verifica se o Armazem está vazio e atribui para os enderecos
	If Empty(Self:oOrdEndOri:GetArmazem())
		Self:oOrdEndOri:SetArmazem(Self:oOrdEndDes:GetArmazem())
	EndIf
	If Empty(Self:oOrdEndDes:GetArmazem())
		Self:oOrdEndDes:SetArmazem(Self:oOrdEndOri:GetArmazem())
	EndIf
	If Self:lforceDtHr
		Self:dData := dDataBase
		Self:cHora := Time()
	Else
		If Empty(Self:dData)
			Self:dData := dDataBase
		EndIf
		If Empty(Self:cHora)
			Self:cHora := Time()
		EndIf
	EndIf
	Self:nQuant2 := ConvUm(Self:oProdLote:GetProduto(),Self:nQuant,0,2)
	Self:nQtdOri := Self:nQuant
	If Empty(Self:cStServ) .Or. Self:cStServ != "4"
		Self:cStServ := "1"
	EndIf
	// Grava DCF
	DCF->(dbSetOrder(9))
	If !DCF->(dbSeek(xFilial("DCF")+Self:cIdDCF))
		RecLock('DCF', .T.)
		DCF->DCF_FILIAL := xFilial('DCF')
		DCF->DCF_ID     := Self:cIdDCF
		DCF->DCF_SERVIC := Self:oServico:GetServico()
		DCF->DCF_DOCTO  := Self:cDocumento
		DCF->DCF_SERIE  := Self:cSerie
		// DCF->DCF_SDOC  := Self:cSerieDoc
		DCF->DCF_CLIFOR := Self:cCliFor
		DCF->DCF_LOJA   := Self:cLoja
		DCF->DCF_CODPRO := Self:oProdLote:GetProduto()
		DCF->DCF_DATA   := Self:dData
		If Self:lHasHora
			DCF->DCF_HORA   := Self:cHora
		EndIf
		DCF->DCF_STSERV := Self:cStServ
		DCF->DCF_QUANT  := Self:nQuant
		DCF->DCF_QTSEUM := Self:nQuant2
		DCF->DCF_QTDORI := Self:nQtdOri
		DCF->DCF_ORIGEM := Self:cOrigem
		DCF->DCF_NUMSEQ := Self:cNumseq
		DCF->DCF_LOCAL  := Self:oOrdEndOri:GetArmazem() //Self:oProdLote:GetArmazem()
		DCF->DCF_ESTFIS := Self:oOrdEndOri:GetEstFis()
		DCF->DCF_LOCDES := Self:oOrdEndDes:GetArmazem()
		DCF->DCF_ENDDES := Self:oOrdEndDes:GetEnder()
		DCF->DCF_REGRA  := Self:cRegra
		DCF->DCF_ENDER  := Self:oOrdEndOri:GetEnder()
		DCF->DCF_LOTECT := Self:oProdLote:GetLoteCtl()
		DCF->DCF_NUMLOT := Self:oProdLote:GetNumLote()
		DCF->DCF_PRDORI := Self:oProdLote:GetPrdOri()
		DCF->DCF_PRIORI := Self:cPriori
		DCF->DCF_CODFUN := Self:cCodFun
		DCF->DCF_CARGA  := Self:cCarga
		DCF->DCF_UNITIZ := Self:cIdUnitiz
		If Self:lHasUniDes
			DCF->DCF_UNIDES := Self:cUniDes
		EndIf
		If Self:lHasIdMvOr
			DCF->DCF_IDMVOR := Self:cIdMovOrig
		EndIf
		DCF->DCF_CODNOR := Self:cCodNorma
		DCF->DCF_STRADI := Self:cStradi
		DCF->DCF_SEQUEN := Self:cSequen
		DCF->DCF_IDORI  := Self:cIdOrigem
		DCF->DCF_OK     := Self:cOk
		DCF->DCF_CODREC := Self:cCodRec
		DCF->DCF_DOCPEN := Self:cDocPen
		DCF->DCF_CODPLN := Self:cCodPln
		DCF->(MsUnLock())
		// Grava recno
		Self:nRecno := DCF->(Recno())
		// Ponto de Entrada WMSPOSDCF apos as gravacoes
		// Recebe o recno da DCF criada
		If ExistBlock('WMSPOSDCF')
			ExecBlock('WMSPOSDCF',.F.,.F.,{Self:nRecno})
		EndIf
	Else
		lRet := .F.
		Self:cErro := STR0005 // Chave duplicada!
	EndIf
	RestArea(aAreaDCF)
Return lRet
//----------------------------------------
/*/{Protheus.doc} ExcludeDCF
Exclusão da DCF
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//----------------------------------------
METHOD ExcludeDCF() CLASS WMSDTCOrdemServico
Local lRet     := .T.
Local aAreaDCF := DCF->(GetArea())
// Posiciona registro
	DCF->(dbGoTo( Self:GetRecno() ))
	// Diminui a quantidade ou exclui a ordem de serviço
	If Self:cOrigem == "SC9" .And. QtdComp(Self:nQtdDel) > QtdComp(0) .And. QtdComp(DCF->DCF_QUANT) > QtdComp(Self:nQtdDel)
		RecLock('DCF', .F.)
		DCF->DCF_QUANT  -= Self:nQtdDel
		DCF->DCF_QTSEUM := ConvUm(DCF->DCF_CODPRO,DCF->DCF_QUANT,0,2)
		DCF->(MsUnlock())
	Else
		//Se exclui a ordem de serviço, deve excluir o IDDCF da origem
		Self:UpdIntegra()
		// Excluindo a ordem de serviço
		RecLock('DCF', .F.)
		DCF->(DbDelete())
		DCF->(MsUnlock())
	EndIf
	RestArea(aAreaDCF)
Return lRet
//----------------------------------------
/*/{Protheus.doc} CancelDCF
Cancelamento da DCF
@author alexsander.correa
@since 09/11/2016
@version 1.0
/*/
//----------------------------------------
METHOD CancelDCF() CLASS WMSDTCOrdemServico
Local lRet := .T.
Local aAreaDCF := DCF->(GetArea())
	// Posiciona registro
	DCF->(dbGoTo( Self:GetRecno() ))
	// Diminui a quantidade ou exclui a ordem de serviço
	//Se exclui a ordem de serviço, deve excluir o IDDCF da origem
	Self:UpdIntegra()
	// Excluindo a ordem de serviço
	RecLock('DCF', .F.)
	DCF->DCF_STSERV := '0'
	DCF->(MsUnlock())
	RestArea(aAreaDCF)
Return lRet
//----------------------------------------
/*/{Protheus.doc} UpdateDCF
Atualização dos dados DCF
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//----------------------------------------
METHOD UpdateDCF(lMsUnLock) CLASS WMSDTCOrdemServico
Local lRet := .T.

Default lMsUnLock := .T.

	If !Empty(Self:GetRecno())
		DCF->(dbGoTo( Self:GetRecno() ))
		Self:nQuant2 := ConvUm(Self:oProdLote:GetProduto(),Self:nQuant,0,2)
		// Grava DCF
		RecLock('DCF', .F.)
		DCF->DCF_SERVIC := Self:oServico:GetServico()
		DCF->DCF_DOCTO  := Self:cDocumento
		DCF->DCF_SERIE  := Self:cSerie
		// DCF->DCF_SDOC  := Self:cSerieDoc
		DCF->DCF_CLIFOR := Self:cCliFor
		DCF->DCF_LOJA   := Self:cLoja
		DCF->DCF_CODPRO := Self:oProdLote:GetProduto()
		DCF->DCF_DATA   := Self:dData
		If Self:lHasHora
			DCF->DCF_HORA   := Self:cHora
		EndIf
		DCF->DCF_STSERV := Self:cStServ
		DCF->DCF_QTDORI := Self:nQtdOri
		DCF->DCF_QUANT  := Self:nQuant
		DCF->DCF_QTSEUM := Self:nQuant2
		DCF->DCF_ORIGEM := Self:cOrigem
		DCF->DCF_NUMSEQ := Self:cNumseq
		DCF->DCF_LOCAL  := Self:oProdLote:GetArmazem()
		DCF->DCF_ENDER  := Self:oOrdEndOri:GetEnder()
		DCF->DCF_ESTFIS := Self:oOrdEndOri:GetEstFis()
		DCF->DCF_LOCDES := Self:oOrdEndDes:GetArmazem()
		DCF->DCF_ENDDES := Self:oOrdEndDes:GetEnder()
		DCF->DCF_LOTECT := Self:oProdLote:GetLoteCtl()
		DCF->DCF_NUMLOT := Self:oProdLote:GetNumLote()
		DCF->DCF_PRDORI := Self:oProdLote:GetPrdOri()
		DCF->DCF_REGRA  := Self:cRegra
		DCF->DCF_PRIORI := Self:cPriori
		DCF->DCF_CODFUN := Self:cCodFun
		DCF->DCF_CARGA  := Self:cCarga
		DCF->DCF_UNITIZ := Self:cIdUnitiz
		If Self:lHasUniDes
			DCF->DCF_UNIDES := Self:cUniDes
		EndIf
		If Self:lHasIdMvOr
			DCF->DCF_IDMVOR := Self:cIdMovOrig
		EndIf
		DCF->DCF_CODNOR := Self:cCodNorma
		DCF->DCF_STRADI := Self:cStradi
		DCF->DCF_SEQUEN := Self:cSequen
		DCF->DCF_IDORI  := Self:cIdOrigem
		DCF->DCF_OK     := Self:cOk
		DCF->DCF_CODREC := Self:cCodRec
		DCF->DCF_DOCPEN := Self:cDocPen
		DCF->DCF_CODPLN := Self:cCodPln
		DCF->(dbCommit()) // Para forçar atualização do banco
		If lMsUnLock
			DCF->(MsUnLock())
		EndIf
	Else
		lRet := .F.
		Self:cErro := STR0001 // Recno inválido!
	EndIf
Return lRet
//----------------------------------------
/*/{Protheus.doc} UpdStatus
Atualização do status
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//----------------------------------------
METHOD UpdStatus() CLASS WMSDTCOrdemServico
Local lRet     := .F.
Local aAreaSD1 := SD1->(GetArea())
Local aAreaSD2 := SD2->(GetArea())
Local aAreaSD3 := SD3->(GetArea())
Local aAreaSD4 := SD4->(GetArea())
Local aAreaSC9 := SC9->(GetArea())
	// Atualiza documento origem
	If Self:cOrigem == 'SD1'
		SD1->(dbSetOrder(4))
		If lRet := SD1->(dbSeek(xFilial('SD1')+Self:cNumSeq))
			RecLock('SD1', .F.)
			SD1->D1_STSERV := Self:cStServ
			SD1->(MsUnLock())
		EndIf
	ElseIf Self:cOrigem == 'SD2'
		SD2->(dbSetOrder(4))
		If lRet := SD2->(dbSeek(xFilial('SD2')+Self:cNumSeq))
			RecLock('SD2', .F.)
			SD2->D2_STSERV := Self:cStServ
			SD1->(MsUnLock())
		EndIf
	ElseIf Self:cOrigem == 'SD3'
		SD3->(dbSetOrder(3))
		If lRet := SD3->(dbSeek(xFilial("SD3")+Self:oProdLote:GetPrdOri()+Self:oProdLote:GetArmazem()+Self:cNumSeq))
			While SD3->(!Eof()) .And. SD3->(D3_COD+D3_LOCAL+D3_NUMSEQ) == Self:oProdLote:GetPrdOri()+Self:oProdLote:GetArmazem()+Self:cNumSeq
				RecLock('SD3', .F.)
				SD3->D3_STSERV := Self:cStServ
				SD3->(MsUnLock())
				SD3->(dbSkip())
			EndDo
		EndIf
	ElseIf Self:cOrigem == 'SC9'
		SC9->(dbSetOrder(9))
		SC9->(dbSeek(xFilial("SC9")+Self:cIdDCF))
		Do While SC9->(!Eof()) .And. SC9->C9_FILIAL+SC9->C9_IDDCF == xFilial("SC9")+Self:cIdDCF
			RecLock('SC9', .F.)
			SC9->C9_STSERV := Self:cStServ
			SC9->(MsUnLock())
			SC9->(dbSkip())
		EndDo
	EndIf
	// Restaura area
	RestArea(aAreaSD1)
	RestArea(aAreaSD2)
	RestArea(aAreaSD3)
	RestArea(aAreaSD4)
	RestArea(aAreaSC9)
Return lRet
//----------------------------------------
/*/{Protheus.doc} UndoIntegr
Desfaz a integração da ordem de serviço
@author felipe.m
@since 23/12/2014
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
//----------------------------------------
METHOD UndoIntegr() CLASS WMSDTCOrdemServico
Local lRet     := .T.
Local cLocalCQ := SuperGetMV("MV_CQ",.F.,"")
	// Atualiza estoque por endereco
	If Self:oServico:HasOperac({'1','2'}) // Caso serviço tenha operação de endereçamento, endereçamento crossdocking
		If lRet
			lRet := Self:ReverseMA()
		EndIf
		If lRet .And. Self:ChkMovEst(.F.)
			lRet := Self:ReverseMI()
		EndIf
		// Realiza a exclusão da D0G depois do SD3, pois do contrário gera erro de saldo negativo
		If lRet
			oSaldoADis := WMSDTCSaldoADistribuir():New()
			oSaldoADis:oProdLote:SetProduto(Self:oProdLote:GetPrdOri())
			oSaldoADis:oProdLote:SetArmazem(Self:oProdLote:GetArmazem())
			oSaldoADis:SetDocto(Self:cDocumento)
			oSaldoADis:SetSerie(Self:cSerie)
			oSaldoADis:SetCliFor(Self:cCliFor)
			oSaldoADis:SetLoja(Self:cLoja)
			oSaldoADis:SetNumSeq(Self:cNumSeq)
			oSaldoADis:SetIdDCF(Self:GetIdDCF())
			If oSaldoADis:LoadData(1)
				oSaldoADis:DeleteD0G()
			EndIf
		EndIf
		If lRet .And. WmsX312118("D13","D13_USACAL")
			// Ajuste movimento kardex de integração
			lRet := Self:SaiMovEst()
		EndIf
	ElseIf Self:oServico:HasOperac({'8'}) .And. !(Self:oOrdEndOri:GetArmazem() == cLocalCQ) // Caso serviço tenha operação de transferencia
		lRet := Self:ReverseMO()
		If lRet .And. Self:ChkMovEst(.F.)
			lRet := Self:ReverseMI()
		EndIf

		// Retirar a Reserva quando está desfazendo a integração
		If lRet .And. Self:cOrigem == "DH1"
			Self:UpdEmpSB2("-",Self:oProdLote:GetProduto(),Self:oOrdEndOri:GetArmazem(),Self:GetQuant())
			// Baixa da reserva do SB8
			If Self:oProdLote:HasRastro() .And. !Empty(Self:oProdLote:GetLoteCtl()+Self:oProdLote:GetNumLote())
				Self:UpdEmpSB8("-",Self:oProdLote:GetProduto(),Self:oOrdEndOri:GetArmazem(),Self:oProdLote:GetLoteCtl(), Self:oProdLote:GetNumLote(), Self:GetQuant())
			EndIf
		EndIf
	ElseIf Self:oServico:HasOperac({'3','4'}) // Caso serviço tenha operação de separação, separação crossdocking
		If lRet .And. !Empty(Self:oOrdEndOri:GetEnder())
			// Efetua ajuste estoque por endereço
			If Self:cOrigem $ "SC9" .And. QtdComp(Self:nQtdDel) > QtdComp(0)
				Self:nQuant := Self:nQtdDel
			EndIf
			If Self:ChkMovEst(.F.)
				lRet := Self:ReverseMO()
				If lRet
					lRet := Self:ReverseMI()
				EndIf
			EndIf
		EndIf
		If lRet .And. Self:cOrigem == "DH1"
			Self:UpdEmpSB2("-",Self:oProdLote:GetProduto(),Self:oOrdEndOri:GetArmazem(),Self:GetQuant())
			// Baixa da reserva do SB8
			If Self:oProdLote:HasRastro() .And. !Empty(Self:oProdLote:GetLoteCtl()+Self:oProdLote:GetNumLote())
				Self:UpdEmpSB8("-",Self:oProdLote:GetProduto(),Self:oOrdEndOri:GetArmazem(),Self:oProdLote:GetLoteCtl(), Self:oProdLote:GetNumLote(), Self:GetQuant())
			EndIf
			If lRet .And. WmsX312118("D13","D13_USACAL")
				// Ajuste movimento kardex de integração
				lRet := Self:SaiMovEst()
			EndIf
		EndIf
	EndIf
Return lRet

//----------------------------------------
/*/{Protheus.doc} UpdIntegra
Atualiza a integração da ordem de serviço
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//----------------------------------------
METHOD UpdIntegra() CLASS WMSDTCOrdemServico
Local aAreaSD1 := SD1->(GetArea())
Local aAreaSD2 := SD2->(GetArea())
Local aAreaSD3 := SD3->(GetArea())
Local aAreaSD4 := SD4->(GetArea())
Local aAreaSC9 := SC9->(GetArea())
Local aAreaD0B := D0B->(GetArea())
	// Atualiza documento origem
	If Self:cOrigem == 'SD1'
		SD1->(dbSetOrder(4))
		If SD1->(dbSeek(xFilial('SD1')+Self:cNumSeq))
			RecLock('SD1', .F.)
			SD1->D1_IDDCF  := ""
			SD1->D1_STSERV := ""
			SD1->(MsUnLock())
		EndIf
		// Cancela movimentos
	ElseIf Self:cOrigem == 'SD2'
		SD2->(dbSetOrder(4))
		If SD2->(dbSeek(xFilial('SD2')+Self:cNumSeq))
			RecLock('SD2', .F.)
			SD2->D2_IDDCF  := ""
			SD2->D2_STSERV := ""
			SD1->(MsUnLock())
		EndIf
	ElseIf Self:cOrigem == 'SD3'
		SD3->(dbSetOrder(3))
		If SD3->(dbSeek(xFilial("SD3")+Self:oProdLote:GetPrdOri()+Self:oProdLote:GetArmazem()+Self:cNumSeq))
			While SD3->(!Eof()) .AND. SD3->(D3_FILIAL+D3_COD+D3_LOCAL+D3_NUMSEQ) == xFilial("SD3")+Self:oProdLote:GetPrdOri()+Self:oProdLote:GetArmazem()+Self:cNumSeq
				RecLock('SD3', .F.)
				SD3->D3_IDDCF  := ""
				SD3->D3_STSERV := ""
				SD3->(MsUnLock())
				SD3->(dbSkip())
			EndDo
		EndIf
	ElseIf Self:cOrigem == 'SC9'
		SC9->(dbSetOrder(9))
		If SC9->(dbSeek(xFilial("SC9")+Self:cIdDCF))
			RecLock('SC9', .F.)
			SC9->C9_IDDCF  := ""
			SC9->C9_STSERV := ""
			SC9->(MsUnLock())
		EndIf
	ElseIf Self:cOrigem == 'D0A'
		D0B->(dbSetOrder(2))
		If D0B->(dbSeek(xFilial("D0B")+Self:GetDocto()+"2"))
			While D0B->(!Eof()) .AND. D0B->D0B_FILIAL+D0B->D0B_DOC+D0B->D0B_TIPMOV == xFilial("D0B")+Self:GetDocto()+"2"
				If D0B->D0B_IDDCF == Self:GetIdDCF()
					RecLock('D0B', .F.)
					D0B->D0B_IDDCF  := ""
					D0B->(MsUnLock())
				EndIf
				D0B->(dbSkip())
			EndDo
		EndIf
	ElseIf Self:cOrigem == "DH1"
		DH1->(dbSetOrder(1))
		If DH1->(dbSeek(xFilial("DH1")+Self:GetDocto()+Self:oProdLote:GetArmazem()+Self:cNumSeq))
			If DH1->DH1_IDDCF == Self:GetIdDCF()
				RecLock('DH1', .F.)
				DH1->DH1_IDDCF  := ""
				DH1->(MsUnLock())
			EndIf
			DH1->(dbSkip())
		EndIf
	ElseIf Self:cOrigem == "D0R"
		D0R->(dbSetOrder(2))
		If D0R->(dbSeek(xFilial("D0R")+Self:cIdDCF))
			RecLock('D0R', .F.)
			D0R->D0R_STATUS := "2"
			D0R->D0R_IDDCF  := ""
			D0R->(MsUnLock())
		EndIf
	EndIf
	RestArea(aAreaSD1)
	RestArea(aAreaSD2)
	RestArea(aAreaSD3)
	RestArea(aAreaSD4)
	RestArea(aAreaSC9)
	RestArea(aAreaD0B)
Return Nil
//----------------------------------------
/*/{Protheus.doc} UpdServic
Atualização do serviço
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//----------------------------------------
METHOD UpdServic() CLASS WMSDTCOrdemServico
Local lRet     := .F.
Local aAreaDCF := DCF->(GetArea())
Local aAreaSD1 := SD1->(GetArea())
Local aAreaSD2 := SD2->(GetArea())
Local aAreaSD3 := SD3->(GetArea())
Local aAreaSC9 := SC9->(GetArea())
Local aAreaSC6 := SC6->(GetArea())
	// Atualiza dados das tabelas de Origem do documento
	If self:cOrigem == 'SD1' // Documentos de Entrada
		dbSelectArea('SD1')
		SD1->(dbSetOrder(4)) // D1_FILIAL+D1_NUMSEQ
		If SD1->(dbSeek(xFilial('SD1')+self:cNumSeq))
			RecLock('SD1')
			SD1->D1_SERVIC := Self:GetServico()
			SD1->(MsUnlock())
		EndIf
	ElseIf DCF->DCF_ORIGEM == 'SD3' // Movimentos Internos
		dbSelectArea('SD3')
		SD3->(dbSetOrder(8)) // D3_FILIAL+D3_DOC+D3_NUMSEQ
		If SD3->(dbSeek(xFilial('SD3')+Self:cDocumento+Self:cNumSeq))
			While SD3->(!Eof()) .AND. SD3->(D3_FILIAL+D3_COD+D3_LOCAL+D3_NUMSEQ) == xFilial("SD3")+Self:oProdLote:GetPrdOri()+Self:oProdLote:GetArmazem()+Self:cNumSeq
				RecLock('SD3', .F.)
				SD3->D3_SERVIC := Self:GetServico()
				SD3->(MsUnlock())
				SD3->(dbSkip())
			EndDo
		EndIf
	ElseIf DCF->DCF_ORIGEM == 'SC9' // Pedidos de Venda
		// Atualiza dados do documento de saida
		dbSelectArea("SC9")
		SC9-> (dbSetOrder(9)) // C9_FILIAL+C9_IDDCF
		If SC9->(dbSeek(xFilial("SC9")+Self:cIdDCF))
			RecLock("SC9",.F.)
			C9_SERVIC := Self:GetServico()
			SC9-> (MsUnlock())
			DBSelectArea("SC6")
			DBSetOrder(1) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
			If DBSeek(xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_PRODUTO)
				If SC9->C9_SERVIC <> SC6->C6_SERVIC
					RecLock("SC6",.F.)
					C6_SERVIC := Self:GetServico()
					SC6->( MsUnlock())
				EndIf
			EndIf
		EndIf
	EndIf
	RestArea(aAreaDCF)
	RestArea(aAreaSD1)
	RestArea(aAreaSD2)
	RestArea(aAreaSD3)
	RestArea(aAreaSC9)
	RestArea(aAreaSC6)
Return lRet
//----------------------------------------
/*/{Protheus.doc} HaveMovD12
Verifica se a ordem de serviço tem movimentação D12
@author felipe.m
@since 23/12/2014
@version 1.0
@param cAcao, character, (Ação a ser executada)
/*/
//----------------------------------------
METHOD HaveMovD12(cAcao) CLASS WMSDTCOrdemServico
Local aAreaAnt  := GetArea()
Local cAliasD12 := GetNextAlias()
Local lRet      := .F.
Local cQuery := ""
Default cAcao := "1"
	// Utilzado pela funcao MaDeletDCF
	cQuery := " SELECT D12.R_E_C_N_O_ RECNOD12"
	cQuery += " FROM "+RetSqlName('DCF')+" DCF, "+RetSqlName('DCR')+" DCR, "+RetSqlName('D12')+" D12"
	cQuery += " WHERE DCF.DCF_FILIAL = '"+xFilial('DCF')+"'"
	If cAcao $ "1|2|3|4"
		If WmsCarga(Self:cCarga)
			cQuery += " AND DCF.DCF_CARGA = '"+Self:cCarga+"'"
		Else
			cQuery += " AND DCF.DCF_DOCTO = '"+Self:cDocumento+"'"
			cQuery += " AND DCF.DCF_SERIE = '"+Self:cSerie+"'"
			cQuery += " AND DCF.DCF_CLIFOR = '"+Self:cCliFor+"'"
			cQuery += " AND DCF.DCF_LOJA = '"+Self:cLoja+"'"
		EndIf
		cQuery += " AND DCF.DCF_SERVIC = '"+Self:oServico:GetServico()+"'"
		cQuery += " AND DCF.DCF_LOCAL = '"+Self:oProdLote:GetArmazem()+"'"
		cQuery += " AND DCF.DCF_CODPRO = '"+Self:oProdLote:GetPrdOri()+"'"
	Else
		cQuery += " AND DCF.DCF_ID = '"+Self:cIdDCF+"'"
	EndIf
	cQuery += " AND DCF.DCF_SEQUEN = '"+Self:cSequen+"'"
	If cAcao <> '0'
		cQuery += " AND DCF.DCF_STSERV <> '0'"
	EndIf
	cQuery += " AND DCF.D_E_L_E_T_ = ' '"
	cQuery += " AND DCR.DCR_FILIAL = '"+xFilial('DCR')+"'"
	cQuery += " AND DCF.DCF_FILIAL = '"+xFilial('DCF')+"'"
	cQuery += " AND DCR.DCR_IDDCF  = DCF.DCF_ID"
	cQuery += " AND DCR.DCR_SEQUEN = DCF.DCF_SEQUEN"
	cQuery += " AND DCR.D_E_L_E_T_ = ' '"
	cQuery += " AND D12.D12_FILIAL = '"+xFilial('D12')+"'"
	If cAcao == '1'
		cQuery += " AND D12.D12_STATUS IN ('1','3') "
	ElseIf cAcao == '2'
		cQuery += " AND D12.D12_STATUS = '2'"
	ElseIf (cAcao == '3' .OR. cAcao == '6')
		cQuery += " AND D12.D12_STATUS IN ('-','2','3','4')"
	ElseIf cAcao == '4'
		cQuery += " AND D12.D12_STATUS NOT IN ('-','2','4')"
	ElseIf cAcao == '5'
		cQuery += " AND D12.D12_STATUS = '3'"
	ElseIf cAcao == '7'
		cQuery += " AND D12.D12_STATUS = '1'"
	EndIf
	cQuery += " AND D12.D12_IDDCF = DCR.DCR_IDORI"
	cQuery += " AND D12.D12_IDMOV = DCR.DCR_IDMOV"
	cQuery += " AND D12.D12_IDOPER = DCR.DCR_IDOPER"
	cQuery += " AND D12.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasD12,.F.,.T.)
	If (cAliasD12)->(!Eof())
		lRet := .T.
	EndIf
	(cAliasD12)->(dbCloseArea())
	RestArea(aAreaAnt)
Return lRet
//----------------------------------------
/*/{Protheus.doc} MakeArmaz
Realiza a armazenagem
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//----------------------------------------
METHOD MakeArmaz() CLASS WMSDTCOrdemServico
Local lRet       := .T.
Local aProduto   := {}
Local nProduto   := 0
Local oEstEnder  := WMSDTCEstoqueEndereco():New()
	// Atualiza Saldo
	// Carrega estrutura do produto x componente
	aProduto := Self:oProdLote:GetArrProd()
	If Len(aProduto) > 0
		For nProduto := 1 To Len(aProduto)
			// Carrega dados para Estoque por Endereço
			oEstEnder:oEndereco:SetArmazem(Self:oOrdEndOri:GetArmazem())
			oEstEnder:oEndereco:SetEnder(Self:oOrdEndOri:GetEnder())
			oEstEnder:oProdLote:SetArmazem(Self:oProdLote:GetArmazem()) // Armazem
			oEstEnder:oProdLote:SetPrdOri(Self:oProdLote:GetPrdOri())   // Produto Origem
			oEstEnder:oProdLote:SetProduto(aProduto[nProduto][1])       // Componente
			oEstEnder:oProdLote:SetLoteCtl(Self:oProdLote:GetLotectl()) // Lote do produto principal que deverá ser o mesmo no componentes
			oEstEnder:oProdLote:SetNumLote(Self:oProdLote:GetNumLote()) // Sub-Lote do produto principal que deverá ser o mesmo no componentes
			oEstEnder:oProdLote:SetNumSer(Self:oProdLote:GetNumSer())   // Numero de serie
			oEstEnder:SetQuant(QtdComp(Self:nQuant * aProduto[nProduto][2]) )
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
			If !oEstEnder:UpdSaldo('499',.T. /*lEstoque*/,.F. /*lEntPrev*/,.T. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/,.F./*lEmpPrev*/,.T./*lMovEstEnd*/)
				Self:cErro := oEstEnder:GetErro()
				lRet := .F.
				Exit
			EndIf
		Next
	EndIf
Return lRet
//----------------------------------------
/*/{Protheus.doc} UndoArmaz
Desfaz a armazenagem
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//----------------------------------------
METHOD UndoArmaz() CLASS WMSDTCOrdemServico
Local lRet       := .T.
Local aProduto   := {}
Local nProduto   := 0
Local oEstEnder  := WMSDTCEstoqueEndereco():New()
	// Atualiza Saldo
	// Carrega estrutura do produto x componente
	aProduto := Self:oProdLote:GetArrProd()
	If Len(aProduto) > 0
		For nProduto := 1 To Len(aProduto)
			// Carrega dados para Estoque por Endereço
			oEstEnder:oEndereco:SetArmazem(Self:oOrdEndOri:GetArmazem())
			oEstEnder:oEndereco:SetEnder(Self:oOrdEndOri:GetEnder())
			oEstEnder:oProdLote:SetArmazem(Self:oProdLote:GetArmazem()) // Armazem
			oEstEnder:oProdLote:SetPrdOri(Self:oProdLote:GetPrdOri())   // Produto Origem
			oEstEnder:oProdLote:SetProduto(aProduto[nProduto][1])       // Componente
			oEstEnder:oProdLote:SetLoteCtl(Self:oProdLote:GetLotectl()) // Lote do produto principal que deverá ser o mesmo no componentes
			oEstEnder:oProdLote:SetNumLote(Self:oProdLote:GetNumLote()) // Sub-Lote do produto principal que deverá ser o mesmo no componentes
			oEstEnder:oProdLote:SetNumSer(Self:oProdLote:GetNumSer())   // Numero de serie
			oEstEnder:SetQuant(QtdComp(Self:nQuant * aProduto[nProduto][2]) )
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
				oMovEstEnd:SetIdOpera(""),;
				oMovEstEnd:SetlUsaCal(.F.);
			})
			// Realiza Entrada Armazem Estoque por Endereço
			If !oEstEnder:UpdSaldo('999',.T. /*lEstoque*/,.F. /*lEntPrev*/,.T. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/,.F./*lEmpPrev*/,.T./*lMovEstEnd*/)
				Self:cErro := oEstEnder:GetErro()
				lRet := .F.
				Exit
			EndIf
		Next
	EndIf
Return lRet
//----------------------------------------
/*/{Protheus.doc} ReverseMA
Estorno MA
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//----------------------------------------
METHOD ReverseMA() CLASS WMSDTCOrdemServico
Local lRet       := .T.
Local aProduto   := {}
Local nProduto   := 0
Local oEstEnder  := WMSDTCEstoqueEndereco():New()
	// Atualiza Saldo
	// Carrega estrutura do produto x componente
	aProduto := Self:oProdLote:GetArrProd()
	If Len(aProduto) > 0
		For nProduto := 1 To Len(aProduto)
			// Carrega dados para Estoque por Endereço
			oEstEnder:oEndereco:SetArmazem(Self:oOrdEndOri:GetArmazem())
			oEstEnder:oEndereco:SetEnder(Self:oOrdEndOri:GetEnder())
			oEstEnder:oProdLote:SetArmazem(Self:oProdLote:GetArmazem()) // Armazem
			oEstEnder:oProdLote:SetPrdOri(Self:oProdLote:GetPrdOri())   // Produto Origem
			oEstEnder:oProdLote:SetProduto(aProduto[nProduto][1])       // Componente
			oEstEnder:oProdLote:SetLoteCtl(Self:oProdLote:GetLotectl()) // Lote do produto principal que deverá ser o mesmo no componentes
			oEstEnder:oProdLote:SetNumLote(Self:oProdLote:GetNumLote()) // Sub-Lote do produto principal que deverá ser o mesmo no componentes
			oEstEnder:oProdLote:SetNumSer(Self:oProdLote:GetNumSer())   // Numero de serie
			oEstEnder:SetQuant(QtdComp(Self:nQuant * aProduto[nProduto][2]) )
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
				oMovEstEnd:SetIdOpera(""),;
				oMovEstEnd:SetlUsaCal(.F.);
			})
			// Realiza Entrada Armazem Estoque por Endereço
			If !oEstEnder:UpdSaldo('999',.T. /*lEstoque*/,.F. /*lEntPrev*/,.T. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/,.F./*lEmpPrev*/,.T./*lMovEstEnd*/)
				Self:cErro := oEstEnder:GetErro()
				lRet := .F.
				Exit
			EndIf
		Next
	EndIf
Return lRet
//----------------------------------------
/*/{Protheus.doc} ReverseMI
Estorno MI
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//----------------------------------------
METHOD ReverseMI(nQtdEst) CLASS WMSDTCOrdemServico
Local lRet       := .T.
Local aProduto   := {}
Local cQuery     := ""
Local cAliasQry  := Nil
Local nProduto   := 0
Local oEstEnder  := WMSDTCEstoqueEndereco():New()

Default nQtdEst := Self:nQuant
	// Atualiza Saldo
	If Self:IsMovUnit() .And. Self:oServico:HasOperac({'8'})
		cQuery := "SELECT D14.D14_CODUNI,"
		cQuery +=       " D14.D14_PRDORI,"
		cQuery +=       " D14.D14_PRODUT,"
		cQuery +=       " D14.D14_LOTECT,"
		cQuery +=       " D14.D14_NUMLOT,"
		cQuery +=       " D14.D14_QTDEST"
		cQuery +=  " FROM "+RetSqlName("D14")+" D14"
		cQuery += " WHERE D14.D14_FILIAL = '"+xFilial("D14")+"'"
		cQuery +=   " AND D14.D14_IDUNIT = '"+Self:cIdUnitiz+"'"
		cQuery +=   " AND D14.D14_LOCAL  = '"+Self:oOrdEndOri:GetArmazem()+"'"
		cQuery +=   " AND D14.D14_ENDER  = '"+Self:oOrdEndOri:GetEnder()+"'"
		cQuery +=   " AND D14.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
		aTamSX3 := TamSx3("D14_QTDEST"); TcSetField(cAliasQry,'D14_QTDEST','N',aTamSX3[1],aTamSX3[2])
		If (cAliasQry)->(!Eof())
			While lRet .And. (cAliasQry)->(!Eof())
				// Carrega dados para LoadData EstEnder
				oEstEnder:oEndereco:SetArmazem(Self:oOrdEndDes:GetArmazem())
				oEstEnder:oEndereco:SetEnder(Self:oOrdEndDes:GetEnder())
				oEstEnder:oProdLote:SetArmazem(Self:oOrdEndDes:GetArmazem()) // Armazem
				oEstEnder:oProdLote:SetPrdOri((cAliasQry)->D14_PRDORI)       // Produto Origem - Componente
				oEstEnder:oProdLote:SetProduto((cAliasQry)->D14_PRODUT)      // Produto Principal
				oEstEnder:oProdLote:SetLoteCtl((cAliasQry)->D14_LOTECT)      // Lote do produto principal que deverá ser o mesmo no componentes
				oEstEnder:oProdLote:SetNumLote((cAliasQry)->D14_NUMLOT)      // Sub-Lote do produto principal que deverá ser o mesmo no componentes
				oEstEnder:SetIdUnit(Self:cUniDes)
				oEstEnder:SetTipUni(Iif(Self:cUniDes==Self:cIdUnitiz,(cAliasQry)->D14_CODUNI,Self:cTipUni))
				oEstEnder:SetQuant((cAliasQry)->D14_QTDEST)
				// Realiza Saída Armazem Estoque por Endereço
				oEstEnder:UpdSaldo('999',.F. /*lEstoque*/,.T. /*lEntPrev*/,.F. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/)
				(cAliasQry)->(DbSkip())
			EndDo
		Else
			Self:cErro := WmsFmtMsg(STR0006,{{"[VAR01]",Self:cIdUnitiz}}) // Não foi encontrado o saldo por endereço do unitizador [VAR01].
			lRet := .F.
		EndIf
		(cAliasQry)->(DbCloseArea())
	Else
		// arrega estrutura do produto x componente
		aProduto := Self:oProdLote:GetArrProd()
		If Len(aProduto) > 0
			For nProduto := 1 To Len(aProduto)
				// Carrega dados para Estoque por Endereço
				oEstEnder:oEndereco:SetArmazem(Self:oOrdEndDes:GetArmazem())
				oEstEnder:oEndereco:SetEnder(Self:oOrdEndDes:GetEnder())
				oEstEnder:oProdLote:SetArmazem(Self:oProdLote:GetArmazem()) // Armazem
				oEstEnder:oProdLote:SetPrdOri(Self:oProdLote:GetPrdOri())   // Produto Origem
				oEstEnder:oProdLote:SetProduto(aProduto[nProduto][1])       // Componente
				oEstEnder:oProdLote:SetLoteCtl(Self:oProdLote:GetLotectl()) // Lote do produto principal que deverá ser o mesmo no componentes
				oEstEnder:oProdLote:SetNumLote(Self:oProdLote:GetNumLote()) // Sub-Lote do produto principal que deverá ser o mesmo no componentes
				oEstEnder:oProdLote:SetNumSer(Self:oProdLote:GetNumSer())   // Numero de Serie
				oEstEnder:SetIdUnit(Self:cUniDes)                           // Id Unitizador
				oEstEnder:LoadData()
				oEstEnder:SetQuant(QtdComp(nQtdEst * aProduto[nProduto][2]) )
				// Realiza Entrada Armazem Estoque por Endereço
				oEstEnder:UpdSaldo('999',.F. /*lEstoque*/,.T. /*lEntPrev*/,.F. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/)
			Next
		EndIf
	EndIf
Return lRet
//----------------------------------------
/*/{Protheus.doc} ReverseMO
Estorno MO
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//----------------------------------------
METHOD ReverseMO(nQtdEst) CLASS WMSDTCOrdemServico
Local lRet       := .T.
Local aProduto   := {}
Local cQuery     := ""
Local cAliasQry  := Nil
Local nProduto   := 0
Local oEstEnder  := WMSDTCEstoqueEndereco():New()
Local lEmpPrev   := Self:oServico:HasOperac({'3','4'}) // Caso serviço tenha operação de separação, separação crossdocking

Default nQtdEst := Self:nQuant
	// Atualiza Saldo
	If Self:IsMovUnit() .And. Self:oServico:HasOperac({'8'})
		cQuery := "SELECT D14.D14_CODUNI,"
		cQuery +=       " D14.D14_PRDORI,"
		cQuery +=       " D14.D14_PRODUT,"
		cQuery +=       " D14.D14_LOTECT,"
		cQuery +=       " D14.D14_NUMLOT,"
		cQuery +=       " D14.D14_QTDEST"
		cQuery +=  " FROM "+RetSqlName("D14")+" D14"
		cQuery += " WHERE D14.D14_FILIAL = '"+xFilial("D14")+"'"
		cQuery +=   " AND D14.D14_IDUNIT = '"+Self:cIdUnitiz+"'"
		cQuery +=   " AND D14.D14_LOCAL  = '"+Self:oOrdEndOri:GetArmazem()+"'"
		cQuery +=   " AND D14.D14_ENDER  = '"+Self:oOrdEndOri:GetEnder()+"'"
		cQuery +=   " AND D14.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
		aTamSX3 := TamSx3("D14_QTDEST"); TcSetField(cAliasQry,'D14_QTDEST','N',aTamSX3[1],aTamSX3[2])
		If (cAliasQry)->(!Eof())
			While lRet .And. (cAliasQry)->(!Eof())
				// Carrega dados para LoadData EstEnder
				oEstEnder:oEndereco:SetArmazem(Self:oOrdEndOri:GetArmazem())
				oEstEnder:oEndereco:SetEnder(Self:oOrdEndOri:GetEnder())
				oEstEnder:oProdLote:SetArmazem(Self:oOrdEndOri:GetArmazem()) // Armazem
				oEstEnder:oProdLote:SetPrdOri((cAliasQry)->D14_PRDORI)       // Produto Origem - Componente
				oEstEnder:oProdLote:SetProduto((cAliasQry)->D14_PRODUT)      // Produto Principal
				oEstEnder:oProdLote:SetLoteCtl((cAliasQry)->D14_LOTECT)      // Lote do produto principal que deverá ser o mesmo no componentes
				oEstEnder:oProdLote:SetNumLote((cAliasQry)->D14_NUMLOT)      // Sub-Lote do produto principal que deverá ser o mesmo no componentes
				oEstEnder:SetIdUnit(Self:cIdUnitiz)
				oEstEnder:SetTipUni(Iif(Self:cUniDes==Self:cIdUnitiz,(cAliasQry)->D14_CODUNI,Self:cTipUni))
				oEstEnder:SetQuant((cAliasQry)->D14_QTDEST)
				// Realiza Saída Armazem Estoque por Endereço
				oEstEnder:UpdSaldo('999',.F. /*lEstoque*/,.F. /*lEntPrev*/,.T./*lSaiPrev*/,.F./*lEmpenho*/,.F. /*lBloqueio*/,lEmpPrev)
				(cAliasQry)->(DbSkip())
			EndDo
		Else
			Self:cErro := WmsFmtMsg(STR0006,{{"[VAR01]",Self:cIdUnitiz}}) // Não foi encontrado o saldo por endereço do unitizador [VAR01].
			lRet := .F.
		EndIf
		(cAliasQry)->(DbCloseArea())
	Else
		// Carrega estrutura do produto x componente
		aProduto := Self:oProdLote:GetArrProd()
		If Len(aProduto) > 0
			For nProduto := 1 To Len(aProduto)
				// Carrega dados para Estoque por Endereço
				oEstEnder:oEndereco:SetArmazem(Self:oOrdEndOri:GetArmazem())
				oEstEnder:oEndereco:SetEnder(Self:oOrdEndOri:GetEnder())
				oEstEnder:oProdLote:SetArmazem(Self:oProdLote:GetArmazem()) // Armazem
				oEstEnder:oProdLote:SetPrdOri(Self:oProdLote:GetPrdOri())   // Produto Origem
				oEstEnder:oProdLote:SetProduto(aProduto[nProduto][1])       // Componente
				oEstEnder:oProdLote:SetLoteCtl(Self:oProdLote:GetLotectl()) // Lote do produto principal que deverá ser o mesmo no componentes
				oEstEnder:oProdLote:SetNumLote(Self:oProdLote:GetNumLote()) // Sub-Lote do produto principal que deverá ser o mesmo no componentes
				oEstEnder:oProdLote:SetNumSer(Self:oProdLote:GetNumSer())   // Numero de serie
				oEstEnder:SetIdUnit(Self:cIdUnitiz)
				oEstEnder:LoadData()
				oEstEnder:SetQuant(QtdComp(nQtdEst * aProduto[nProduto][2]) )
				// Realiza Entrada Armazem Estoque por Endereço
				oEstEnder:UpdSaldo('999',.F. /*lEstoque*/,.F. /*lEntPrev*/,.T./*lSaiPrev*/,.F./*lEmpenho*/,.F. /*lBloqueio*/,lEmpPrev)
			Next
		EndIf
	EndIf
Return lRet
//----------------------------------------
/*/{Protheus.doc} MakeOutput
Realiza uma saída
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//----------------------------------------
METHOD MakeOutput() CLASS WMSDTCOrdemServico
Local lRet       := .T.
Local cQuery     := ""
Local cAliasQry  := ""
Local aProduto   := {}
Local nProduto   := 0
Local oEstEnder  := WMSDTCEstoqueEndereco():New()
Local lEmpPrev   := Self:oServico:HasOperac({'3','4'}) // Caso serviço tenha operação de separação, separação crossdocking
	// Atualiza Saldo
	// Se for OS de transferência unitizada
	If Self:IsMovUnit() .And. Self:oServico:HasOperac({'8'})
		// Se for uma transferência de estorno de endereçamento e a origem for um picking ou produção
		// Não possui saldo por unitizador, neste caso deve carregar o saldo inicial do unitizador
		If !Empty(Self:cIdOrigem) .And. !Empty(Self:cUniDes) .And. (Self:oOrdEndOri:GetTipoEst() == 2 .Or. Self:oOrdEndOri:GetTipoEst() == 7)
			cQuery := "SELECT D0R.D0R_CODUNI,"
			cQuery +=       " D0S.D0S_PRDORI,"
			cQuery +=       " D0S.D0S_CODPRO,"
			cQuery +=       " D0S.D0S_LOTECT,"
			cQuery +=       " D0S.D0S_NUMLOT,"
			cQuery +=       " D0S.D0S_QUANT"
			cQuery +=  " FROM "+RetSqlName('D0S')+" D0S,"
			cQuery +=        RetSqlName('D0R')+" D0R"
			cQuery += " WHERE D0S.D0S_FILIAL = '"+xFilial('D0S')+"'"
			cQuery +=   " AND D0S.D0S_IDUNIT = '"+Self:cUniDes+"'"
			cQuery +=   " AND D0S.D_E_L_E_T_ = ' '"
			cQuery +=   " AND D0R.D0R_FILIAL = '"+xFilial('D0R')+"'"
			cQuery +=   " AND D0R.D0R_IDUNIT = D0S.D0S_IDUNIT"
			cQuery +=   " AND D0R.D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			cAliasQry := GetNextAlias()
			DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
			aTamSX3 := TamSx3("D0S_QUANT"); TcSetField(cAliasQry,'D0S_QUANT','N',aTamSX3[1],aTamSX3[2])
			If (cAliasQry)->(!Eof())
				While lRet .And. (cAliasQry)->(!Eof())
					// Carrega dados para LoadData EstEnder
					oEstEnder:oEndereco:SetArmazem(Self:oOrdEndOri:GetArmazem())
					oEstEnder:oEndereco:SetEnder(Self:oOrdEndOri:GetEnder())
					oEstEnder:oProdLote:SetArmazem(Self:oOrdEndOri:GetArmazem()) // Armazem
					oEstEnder:oProdLote:SetPrdOri((cAliasQry)->D0S_PRDORI)       // Produto Origem - Componente
					oEstEnder:oProdLote:SetProduto((cAliasQry)->D0S_CODPRO)      // Produto Principal
					oEstEnder:oProdLote:SetLoteCtl((cAliasQry)->D0S_LOTECT)      // Lote do produto principal que deverá ser o mesmo no componentes
					oEstEnder:oProdLote:SetNumLote((cAliasQry)->D0S_NUMLOT)      // Sub-Lote do produto principal que deverá ser o mesmo no componentes
					oEstEnder:SetIdUnit("") // Picking não controla unitizador
					oEstEnder:SetTipUni("") // Picking não controla unitizador
					oEstEnder:SetQuant((cAliasQry)->D0S_QUANT)
					// Realiza Saída Armazem Estoque por Endereço
					oEstEnder:UpdSaldo('499',.F. /*lEstoque*/,.F. /*lEntPrev*/,.T./*lSaiPrev*/,.F./*lEmpenho*/,.F. /*lBloqueio*/,lEmpPrev)
					(cAliasQry)->(DbSkip())
				EndDo
			Else
				Self:cErro := WmsFmtMsg(STR0011,{{"[VAR01]",Self:cUniDes}}) // Não foi encontrado o saldo dos produtos recebidos no unitizador [VAR01].
				lRet := .F.
			EndIf
			(cAliasQry)->(DbCloseArea())
		Else
			cQuery := "SELECT D14.D14_CODUNI,"
			cQuery +=       " D14.D14_PRDORI,"
			cQuery +=       " D14.D14_PRODUT,"
			cQuery +=       " D14.D14_LOTECT,"
			cQuery +=       " D14.D14_NUMLOT,"
			cQuery +=       " D14.D14_QTDEST"
			cQuery +=  " FROM "+RetSqlName("D14")+" D14"
			cQuery += " WHERE D14.D14_FILIAL = '"+xFilial("D14")+"'"
			cQuery +=   " AND D14.D14_IDUNIT = '"+Self:cIdUnitiz+"'"
			cQuery +=   " AND D14.D14_LOCAL  = '"+Self:oOrdEndOri:GetArmazem()+"'"
			cQuery +=   " AND D14.D14_ENDER  = '"+Self:oOrdEndOri:GetEnder()+"'"
			cQuery +=   " AND D14.D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			cAliasQry := GetNextAlias()
			DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
			aTamSX3 := TamSx3("D14_QTDEST"); TcSetField(cAliasQry,'D14_QTDEST','N',aTamSX3[1],aTamSX3[2])
			If (cAliasQry)->(!Eof())
				While lRet .And. (cAliasQry)->(!Eof())
					// Carrega dados para LoadData EstEnder
					oEstEnder:oEndereco:SetArmazem(Self:oOrdEndOri:GetArmazem())
					oEstEnder:oEndereco:SetEnder(Self:oOrdEndOri:GetEnder())
					oEstEnder:oProdLote:SetArmazem(Self:oOrdEndOri:GetArmazem()) // Armazem
					oEstEnder:oProdLote:SetPrdOri((cAliasQry)->D14_PRDORI)       // Produto Origem - Componente
					oEstEnder:oProdLote:SetProduto((cAliasQry)->D14_PRODUT)      // Produto Principal
					oEstEnder:oProdLote:SetLoteCtl((cAliasQry)->D14_LOTECT)      // Lote do produto principal que deverá ser o mesmo no componentes
					oEstEnder:oProdLote:SetNumLote((cAliasQry)->D14_NUMLOT)      // Sub-Lote do produto principal que deverá ser o mesmo no componentes
					oEstEnder:SetIdUnit(Self:cIdUnitiz)
					oEstEnder:SetTipUni(Iif(Self:cUniDes==Self:cIdUnitiz,(cAliasQry)->D14_CODUNI,Self:cTipUni))
					oEstEnder:SetQuant((cAliasQry)->D14_QTDEST)
					// Realiza Saída Armazem Estoque por Endereço
					oEstEnder:UpdSaldo('499',.F. /*lEstoque*/,.F. /*lEntPrev*/,.T./*lSaiPrev*/,.F./*lEmpenho*/,.F. /*lBloqueio*/,lEmpPrev)
					(cAliasQry)->(DbSkip())
				EndDo
			Else
				Self:cErro := WmsFmtMsg(STR0006,{{"[VAR01]",Self:cIdUnitiz}}) // Não foi encontrado o saldo por endereço do unitizador [VAR01].
				lRet := .F.
			EndIf
			(cAliasQry)->(DbCloseArea())
		EndIf
	Else
		// Carrega estrutura do produto x componente
		aProduto := Self:oProdLote:GetArrProd()
		// Verifica se há produtos
		If Len(aProduto) > 0
			For nProduto := 1 To Len(aProduto)
				// Carrega dados para Estoque por Endereço
				oEstEnder:oEndereco:SetArmazem(Self:oOrdEndOri:GetArmazem())
				oEstEnder:oEndereco:SetEnder(Self:oOrdEndOri:GetEnder())
				oEstEnder:oProdLote:SetArmazem(Self:oProdLote:GetArmazem()) // Armazem
				oEstEnder:oProdLote:SetPrdOri(Self:oProdLote:GetPrdOri())   // Produto Origem
				oEstEnder:oProdLote:SetProduto(aProduto[nProduto][1])       // Componente
				oEstEnder:oProdLote:SetLoteCtl(Self:oProdLote:GetLotectl()) // Lote do produto principal que deverá ser o mesmo no componentes
				oEstEnder:oProdLote:SetNumLote(Self:oProdLote:GetNumLote()) // Sub-Lote do produto principal que deverá ser o mesmo no componentes
				oEstEnder:oProdLote:SetNumSer(Self:oProdLote:GetNumSer())   // Numero de serie
				oEstEnder:SetIdUnit(Self:cIdUnitiz)                         // Id Unitizador
				oEstEnder:LoadData()
				oEstEnder:SetQuant(QtdComp(Self:nQuant * aProduto[nProduto][2]) )
				// Realiza Saída Armazem Estoque por Endereço
				oEstEnder:UpdSaldo('499',.F. /*lEstoque*/,.F. /*lEntPrev*/,.T./*lSaiPrev*/,.F./*lEmpenho*/,.F. /*lBloqueio*/,lEmpPrev)
			Next
		EndIf
	EndIf
Return lRet
//----------------------------------------
/*/{Protheus.doc} MakeInput
Realiza uma entrada
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//----------------------------------------
METHOD MakeInput() CLASS WMSDTCOrdemServico
Local lRet       := .T.
Local cQuery     := ""
Local cAliasQry  := ""
Local aProduto   := {}
Local nProduto   := 0
Local oEstEnder  := WMSDTCEstoqueEndereco():New()
	// Atualiza Saldo
	// Se for OS unitizada
	If Self:IsMovUnit()
		// Se for uma transferência de estorno de endereçamento e a origem for um picking ou produção
		// Não possui saldo por unitizador, neste caso deve carregar o saldo inicial do unitizador
		If Self:oServico:HasOperac({'8'}) .And. !Empty(Self:cIdOrigem) .And. !Empty(Self:cUniDes) .And. (Self:oOrdEndOri:GetTipoEst() == 2 .Or. Self:oOrdEndOri:GetTipoEst() == 7)
			cQuery := "SELECT D0R.D0R_CODUNI,"
			cQuery +=       " D0S.D0S_PRDORI,"
			cQuery +=       " D0S.D0S_CODPRO,"
			cQuery +=       " D0S.D0S_LOTECT,"
			cQuery +=       " D0S.D0S_NUMLOT,"
			cQuery +=       " D0S.D0S_QUANT"
			cQuery +=  " FROM "+RetSqlName('D0S')+" D0S,"
			cQuery +=        RetSqlName('D0R')+" D0R"
			cQuery += " WHERE D0S.D0S_FILIAL = '"+xFilial('D0S')+"'"
			cQuery +=   " AND D0S.D0S_IDUNIT = '"+Self:cUniDes+"'"
			cQuery +=   " AND D0S.D_E_L_E_T_ = ' '"
			cQuery +=   " AND D0R.D0R_FILIAL = '"+xFilial('D0R')+"'"
			cQuery +=   " AND D0R.D0R_IDUNIT = D0S.D0S_IDUNIT"
			cQuery +=   " AND D0R.D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			cAliasQry := GetNextAlias()
			DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
			aTamSX3 := TamSx3("D0S_QUANT"); TcSetField(cAliasQry,'D0S_QUANT','N',aTamSX3[1],aTamSX3[2])
			If (cAliasQry)->(!Eof())
				While lRet .And. (cAliasQry)->(!Eof())
					// Carrega dados para LoadData EstEnder
					oEstEnder:oEndereco:SetArmazem(Self:oOrdEndDes:GetArmazem())
					oEstEnder:oEndereco:SetEnder(Self:oOrdEndDes:GetEnder())
					oEstEnder:oProdLote:SetArmazem(Self:oOrdEndDes:GetArmazem()) // Armazem
					oEstEnder:oProdLote:SetPrdOri((cAliasQry)->D0S_PRDORI)       // Produto Origem - Componente
					oEstEnder:oProdLote:SetProduto((cAliasQry)->D0S_CODPRO)      // Produto Principal
					oEstEnder:oProdLote:SetLoteCtl((cAliasQry)->D0S_LOTECT)      // Lote do produto principal que deverá ser o mesmo no componentes
					oEstEnder:oProdLote:SetNumLote((cAliasQry)->D0S_NUMLOT)      // Sub-Lote do produto principal que deverá ser o mesmo no componentes
					oEstEnder:SetIdUnit(Self:cUniDes)
					oEstEnder:SetTipUni(Iif(Self:cUniDes==Self:cIdUnitiz,(cAliasQry)->D0R_CODUNI,Self:cTipUni))
					oEstEnder:SetQuant((cAliasQry)->D0S_QUANT)
					// Realiza Entrada Armazem Estoque por Endereço
					oEstEnder:UpdSaldo('499',.F. /*lEstoque*/,.T. /*lEntPrev*/,.F. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/)
					(cAliasQry)->(DbSkip())
				EndDo
			Else
				Self:cErro := WmsFmtMsg(STR0011,{{"[VAR01]",Self:cUniDes}}) // Não foi encontrado o saldo dos produtos recebidos no unitizador [VAR01].
				lRet := .F.
			EndIf
			(cAliasQry)->(DbCloseArea())
		Else
			cQuery := "SELECT D14.D14_CODUNI,"
			cQuery +=       " D14.D14_PRDORI,"
			cQuery +=       " D14.D14_PRODUT,"
			cQuery +=       " D14.D14_LOTECT,"
			cQuery +=       " D14.D14_NUMLOT,"
			cQuery +=       " D14.D14_QTDEST"
			cQuery +=  " FROM "+RetSqlName("D14")+" D14"
			cQuery += " WHERE D14.D14_FILIAL = '"+xFilial("D14")+"'"
			cQuery +=   " AND D14.D14_IDUNIT = '"+Self:cIdUnitiz+"'"
			cQuery +=   " AND D14.D14_LOCAL  = '"+Self:oOrdEndOri:GetArmazem()+"'"
			cQuery +=   " AND D14.D14_ENDER  = '"+Self:oOrdEndOri:GetEnder()+"'"
			cQuery +=   " AND D14.D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			cAliasQry := GetNextAlias()
			DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
			aTamSX3 := TamSx3("D14_QTDEST"); TcSetField(cAliasQry,'D14_QTDEST','N',aTamSX3[1],aTamSX3[2])
			If (cAliasQry)->(!Eof())
				While lRet .And. (cAliasQry)->(!Eof())
					// Carrega dados para LoadData EstEnder
					oEstEnder:oEndereco:SetArmazem(Self:oOrdEndDes:GetArmazem())
					oEstEnder:oEndereco:SetEnder(Self:oOrdEndDes:GetEnder())
					oEstEnder:oProdLote:SetArmazem(Self:oOrdEndDes:GetArmazem()) // Armazem
					oEstEnder:oProdLote:SetPrdOri((cAliasQry)->D14_PRDORI)       // Produto Origem - Componente
					oEstEnder:oProdLote:SetProduto((cAliasQry)->D14_PRODUT)      // Produto Principal
					oEstEnder:oProdLote:SetLoteCtl((cAliasQry)->D14_LOTECT)      // Lote do produto principal que deverá ser o mesmo no componentes
					oEstEnder:oProdLote:SetNumLote((cAliasQry)->D14_NUMLOT)      // Sub-Lote do produto principal que deverá ser o mesmo no componentes
					oEstEnder:SetIdUnit(Self:cUniDes)
					oEstEnder:SetTipUni(Iif(Self:cUniDes==Self:cIdUnitiz,(cAliasQry)->D14_CODUNI,Self:cTipUni))
					oEstEnder:SetQuant((cAliasQry)->D14_QTDEST)
					// Realiza Entrada Armazem Estoque por Endereço
					oEstEnder:UpdSaldo('499',.F. /*lEstoque*/,.T. /*lEntPrev*/,.F. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/)
					(cAliasQry)->(DbSkip())
				EndDo
			Else
				Self:cErro := WmsFmtMsg(STR0006,{{"[VAR01]",Self:cUniDes}}) // Não foi encontrado o saldo por endereço do unitizador [VAR01].
				lRet := .F.
			EndIf
			(cAliasQry)->(DbCloseArea())
		EndIf
	Else
		// Carrega estrutura do produto x componente
		aProduto := Self:oProdLote:GetArrProd()
		// Verifica se há produtos
		If Len(aProduto) > 0
			For nProduto := 1 To Len(aProduto)
				// Carrega dados para Estoque por Endereço
				oEstEnder:oEndereco:SetArmazem(Self:oOrdEndDes:GetArmazem())
				oEstEnder:oEndereco:SetEnder(Self:oOrdEndDes:GetEnder())
				oEstEnder:oProdLote:SetArmazem(Self:oProdLote:GetArmazem()) // Armazem
				oEstEnder:oProdLote:SetPrdOri(Self:oProdLote:GetPrdOri())   // Produto Origem
				oEstEnder:oProdLote:SetProduto(aProduto[nProduto][1])       // Componente
				oEstEnder:oProdLote:SetLoteCtl(Self:oProdLote:GetLotectl()) // Lote do produto principal que deverá ser o mesmo no componentes
				oEstEnder:oProdLote:SetNumLote(Self:oProdLote:GetNumLote()) // Sub-Lote do produto principal que deverá ser o mesmo no componentes
				oEstEnder:oProdLote:SetNumSer(Self:oProdLote:GetNumSer())   // Numero de serie
				oEstEnder:SetIdUnit(Self:cUniDes)                           // Id Unitizador
				oEstEnder:SetTipUni(Self:cTipUni)
				oEstEnder:LoadData()
				oEstEnder:SetQuant(QtdComp(Self:nQuant * aProduto[nProduto][2]) )
				// Realiza Entrada Armazem Estoque por Endereço
				oEstEnder:UpdSaldo('499',.F. /*lEstoque*/,.T. /*lEntPrev*/,.F. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/)
			Next
		EndIf
	EndIf
Return lRet
//----------------------------------------
/*/{Protheus.doc} MakeConv
Converte produtos Montagem/Desmontagem
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//----------------------------------------
METHOD MakeConv() CLASS WMSDTCOrdemServico
Local lRet       := .T.
Local cQuery     := ""
Local cAliasD0B  := GetNextAlias()
Local oEstEnder  := WMSDTCEstoqueEndereco():New()
Local oMntItem   := WMSDTCMontagemDesmontagemItens():New()

	cQuery := " SELECT D0B.R_E_C_N_O_ RESNOD0B"
	cQuery +=   " FROM "+RetSqlName('D0B')+" D0B"
	cQuery +=  " WHERE D0B.D0B_FILIAL = '"+xFilial("D0B")+"'"
	cQuery +=    " AND D0B.D0B_DOC = '"+Self:GetDocto()+"'"
	cQuery +=    " AND D0B.D0B_TIPMOV = '1'"
	cQuery +=    " AND D0B.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasD0B,.F.,.T.)
	While (cAliasD0B)->(!Eof())
		If oMntItem:GoToD0B((cAliasD0B)->RESNOD0B)
			// Entrada prevista no endereço destino
			oEstEnder:oEndereco:SetArmazem(oMntItem:oMntEndDes:GetArmazem())
			oEstEnder:oEndereco:SetEnder(oMntItem:oMntEndDes:GetEnder())
			oEstEnder:oProdLote:SetArmazem(oMntItem:oProdLote:GetArmazem()) // Armazem
			oEstEnder:oProdLote:SetPrdOri(oMntItem:oProdLote:GetPrdOri())   // Produto Origem
			oEstEnder:oProdLote:SetProduto(oMntItem:oProdLote:GetProduto()) // Componente
			oEstEnder:oProdLote:SetLoteCtl(oMntItem:oProdLote:GetLoteCtl()) // Lote do produto principal que deverá ser o mesmo no componentes
			oEstEnder:oProdLote:SetNumLote(oMntItem:oProdLote:GetNumlote()) // Sub-Lote do produto principal que deverá ser o mesmo no componentes
			oEstEnder:oProdLote:SetNumSer(oMntItem:oProdLote:GetNumSer())   // Numero de serie
			oEstEnder:SetQuant(oMntItem:GetQuant())
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
				oMovEstEnd:SetIdOpera(""),;
				oMovEstEnd:SetlUsaCal(.F.);
			})
			// Realiza Entrada Armazem Estoque por Endereço
			If !oEstEnder:UpdSaldo('999',.T. /*lEstoque*/,.F. /*lEntPrev*/,.F. /*lSaiPrev*/,.F. /*lEmpenho*/,.T. /*lBloqueio*/,.F./*lEmpPrev*/,.T./*lMovEstEnd*/)
				Self:cErro := oEstEnder:GetErro()
				lRet := .F.
				Exit
			EndIf
		EndIf
		(cAliasD0B)->(dbSkip())
	EndDo
	(cAliasD0B)->(dbCloseArea())
Return lRet

//----------------------------------------
/*/{Protheus.doc} UndoConv
Estorna Montagem/Desmontagem
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//----------------------------------------
METHOD UndoConv() CLASS WMSDTCOrdemServico
Local lRet       := .T.
Local cQuery     := ""
Local cAliasD0B  := GetNextAlias()
Local oEstEnder  := WMSDTCEstoqueEndereco():New()
Local oMntItem   := WMSDTCMontagemDesmontagemItens():New()

	cQuery := " SELECT D0B.R_E_C_N_O_ RESNOD0B"
	cQuery +=   " FROM "+RetSqlName('D0B')+" D0B"
	cQuery +=  " WHERE D0B.D0B_FILIAL = '"+xFilial("D0B")+"'"
	cQuery +=    " AND D0B.D0B_DOC = '"+Self:GetDocto()+"'"
	cQuery +=    " AND D0B.D0B_TIPMOV = '1'"
	cQuery +=    " AND D0B.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasD0B,.F.,.T.)
	While (cAliasD0B)->(!Eof())
		If oMntItem:GoToD0B((cAliasD0B)->RESNOD0B)
			// Entrada prevista no endereço destino
			oEstEnder:oEndereco:SetArmazem(oMntItem:oMntEndDes:GetArmazem())
			oEstEnder:oEndereco:SetEnder(oMntItem:oMntEndDes:GetEnder())
			oEstEnder:oProdLote:SetArmazem(oMntItem:oProdLote:GetArmazem()) // Armazem
			oEstEnder:oProdLote:SetPrdOri(oMntItem:oProdLote:GetPrdOri())   // Produto Origem
			oEstEnder:oProdLote:SetProduto(oMntItem:oProdLote:GetProduto()) // Componente
			oEstEnder:oProdLote:SetLoteCtl(oMntItem:oProdLote:GetLoteCtl()) // Lote do produto principal que deverá ser o mesmo no componentes
			oEstEnder:oProdLote:SetNumLote(oMntItem:oProdLote:GetNumlote()) // Sub-Lote do produto principal que deverá ser o mesmo no componentes
			oEstEnder:oProdLote:SetNumSer(oMntItem:oProdLote:GetNumSer())   // Numero de serie
			oEstEnder:SetQuant(oMntItem:GetQuant())
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
			If !oEstEnder:UpdSaldo('499',.T. /*lEstoque*/,.F. /*lEntPrev*/,.F. /*lSaiPrev*/,.F. /*lEmpenho*/,.T. /*lBloqueio*/,.F./*lEmpPrev*/,.T./*lMovEstEnd*/)
				Self:cErro := oEstEnder:GetErro()
				lRet := .F.
				Exit
			EndIf
		EndIf
		(cAliasD0B)->(dbSkip())
	EndDo
	(cAliasD0B)->(dbCloseArea())
Return lRet
//----------------------------------------
/*/{Protheus.doc} SaiMovEst
Realiza uma movimentação do estoque de saida
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//----------------------------------------
METHOD SaiMovEst() CLASS WMSDTCOrdemServico
Local lRet := .T.
Local aProduto   := {}
Local nProduto   := 0
Local cQuery     := ""
Local cAliasD13  := ""
	// Atualiza Saldo
	// Busca dados do kardex
	cQuery := " SELECT D13.R_E_C_N_O_ RECNOD13"
	cQuery +=   " FROM "+RetSqlName("D13")+" D13"
	cQuery +=  " WHERE D13.D13_FILIAL = '"+xFilial("D13")+"'"
	cQuery +=    " AND D13.D13_ORIGEM = '"+Self:cOrigem+"'"
	cQuery +=    " AND D13.D13_DOC = '"+Self:cDocumento+"'"
	cQuery +=    " AND D13.D13_SERIE = '"+Self:cSerie+"'"
	cQuery +=    " AND D13.D13_CLIFOR = '"+Self:cCliFor+"'"
	cQuery +=    " AND D13.D13_LOJA = '"+Self:cLoja+"'"
	cQuery +=    " AND D13.D13_NUMSEQ = '"+Self:cNumSeq+"'"
	cQuery +=    " AND D13.D13_IDDCF = '"+Self:cIdDCF+"'"
	cQuery +=    " AND D13.D13_USACAL <> '2'"
	cQuery +=    " AND D13.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasD13 := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasD13,.F.,.T.)
	Do While lRet .And. (cAliasD13)->(!Eof())
		// Posiciona D13
		D13->(dbGoTo((cAliasD13)->RECNOD13))
		// Atualiza dados
		Reclock("D13",.F.)
		D13->D13_DTESTO := dDataBase
		D13->D13_HRESTO := Time()
		D13->D13_USACAL := "2"
		D13->(MsUnlock())
		
		(cAliasD13)->(dbSkip())
	EndDo
	(cAliasD13)->(dbCloseArea())
Return lRet

//----------------------------------------
/*/{Protheus.doc} ChkOrdDep
Verifica de a ordem de serviço possui dependente
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//----------------------------------------
METHOD ChkOrdDep() CLASS WMSDTCOrdemServico
Local aAreaAnt   := GetArea()
Local lRet       := .F.
Local cQuery     := ""
Local cAliasDCF  := GetNextAlias()
	cQuery := " SELECT DCF.DCF_ID"
	cQuery += " FROM "+RetSqlName('DCF')+" DCF"
	cQuery += " WHERE DCF.DCF_FILIAL = '"+xFilial('DCF')+"'"
	cQuery += " AND DCF.DCF_IDORI = '"+Self:cIdDCF+"'"
	cQuery += " AND DCF.DCF_STSERV <> '0'"
	cQuery += " AND DCF.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasDCF,.F.,.T.)
	If (cAliasDCF)->(!Eof())
		lRet := .T.
	EndIf
	(cAliasDCF)->(dbCloseArea())
	RestArea(aAreaAnt)
Return lRet
//----------------------------------------
/*/{Protheus.doc} CancelSC9
Cancela a ordem de serviço
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//----------------------------------------
METHOD CancelSC9(lEstPed,nRecnoSC9,nQtdQuebra,lPedFat) CLASS WMSDTCOrdemServico
Local aAreaSC9   := SC9->(GetArea())
Local lRet       := .T.
Local lPedEmp    := .F.
Local lMovFin    := .F.
Local oOrdSerDel := Nil

Default lEstPed    := .F.
Default lPedFat    := .F.
Default nQtdQuebra := 0

	If nRecnoSC9 > 0
		SC9->(dbGoTo(nRecnoSC9))
		Self:SetIdDCF(SC9->C9_IDDCF)
		If Self:LoadData()
			// Estorno parcial da sequencia SC9
			If QtdComp(nQtdQuebra) <= 0
				nQtdQuebra := SC9->C9_QTDLIB
			EndIf

			If !lPedFat
				// Verifica se pedido já está empenhado
				dbSelectArea("SDC")
				SDC->(dbSetOrder(1)) // DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_ORIGEM+DC_PEDIDO+DC_ITEM+DC_SEQ+DC_LOTECTL+DC_NUMLOTE+DC_LOCALIZ+DC_NUMSERI
				If SDC->(dbSeek(xFilial("SDC")+SC9->C9_PRODUTO+SC9->C9_LOCAL+"SC6"+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN+SC9->C9_LOTECTL+SC9->C9_NUMLOTE+SC9->C9_ENDPAD+SC9->C9_NUMSERI))
					lPedEmp := .T.
				EndIf
			EndIf
			// Verifica se existe movimento finalizado, onde a primeira sequencia foi faturada e a segunda ainda
			// não foi separa no WMS, porém possuem o mesmo IDDCF/Ordem de Serviço.
			lMovFin := Self:HaveMovD12("7")
			// Verifica se ordem de servico executada com pedido empenhado
			If Self:GetStServ() == "3"
				lRet := Self:EstParcial(nRecnoSC9,nQtdQuebra,lPedEmp)
			Else
				oOrdSerDel := WMSDTCOrdemServicoDelete():New()
				oOrdSerDel:SetIdDCF(Self:GetIdDCF())
				If oOrdSerDel:LoadData()
					oOrdSerDel:SetQtdDel(nQtdQuebra)
					If !oOrdSerDel:DeleteDCF()
						lRet := .F.
					EndIf
				EndIf
			EndIf
		EndIf
		RestArea(aAreaSC9)
	Else
		lRet := .F.
	EndIf
Return lRet
//----------------------------------------
/*/{Protheus.doc} ChkDepPend
Verifica dependentes pendentes
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//----------------------------------------
METHOD ChkDepPend(cIdDCF) CLASS WMSDTCOrdemServico
Local aAreaAnt  := GetArea()
Local lRet      := .F.
Local cAliasDCF := GetNextAlias()
Local cQryDCF := ""

Default cIdDCF := Self:cIdDCF

	// Procura por DCF com o Id Origem preenchido
	cQryDCF += " SELECT DCF.DCF_DOCTO, DCF.DCF_PRDORI"
	cQryDCF +=   " FROM "+RetSqlName("DCF")+" DCF"
	cQryDCF +=  " INNER JOIN "+RetSqlName("DC5")+" DC5"
	cQryDCF +=     " ON DC5.DC5_FILIAL = '"+xFilial("DC5")+"'"
	cQryDCF +=    " AND DC5.DC5_SERVIC = DCF.DCF_SERVIC"
	cQryDCF +=    " AND DC5.DC5_OPERAC <> '5'"
	cQryDCF +=    " AND DC5.D_E_L_E_T_ = ' '"
	cQryDCF +=  " WHERE DCF.DCF_FILIAL = '"+xFilial("DCF")+"'"
	cQryDCF +=    " AND DCF.DCF_IDORI = '"+cIdDCF+"'"
	cQryDCF +=    " AND DCF.DCF_STSERV <> '0'"
	cQryDCF +=    " AND DCF.D_E_L_E_T_ = ' '"
	// Verifica se foi executada, porém não finalizada
	cQryDCF +=    " AND (EXISTS (SELECT 1"
	cQryDCF +=                   " FROM "+RetSqlName("D12")+" D121"
	cQryDCF +=                  " WHERE D121.D12_FILIAL = '"+xFilial("D12")+"'"
	cQryDCF +=                    " AND DCF.DCF_FILIAL = '"+xFilial("DCF")+"'"
	cQryDCF +=                    " AND D121.D12_IDDCF = DCF.DCF_ID"
	cQryDCF +=                    " AND D121.D12_SEQUEN = DCF.DCF_SEQUEN"
	cQryDCF +=                    " AND D121.D12_STATUS IN ('2','3','4')"
	cQryDCF +=                    " AND D121.D_E_L_E_T_ = ' ')"
	// Verifica se nao existe D12, ou seja, não foi executada
	cQryDCF +=             " OR NOT EXISTS (SELECT 1"
	cQryDCF +=                              " FROM "+RetSqlName("D12")+" D122"
	cQryDCF +=                             " WHERE D122.D12_FILIAL = '"+xFilial("D12")+"'"
	cQryDCF +=                               " AND DCF.DCF_FILIAL = '"+xFilial("DCF")+"'"
	cQryDCF +=                               " AND D122.D12_IDDCF = DCF.DCF_ID"
	cQryDCF +=                               " AND D122.D12_SEQUEN = DCF.DCF_SEQUEN"
	cQryDCF +=                               " AND D122.D_E_L_E_T_ = ' '))"
	cQryDCF := ChangeQuery(cQryDCF)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQryDCF),cAliasDCF,.F.,.T.)
	If (cAliasDCF)->(!Eof())
		Self:cErro := WmsFmtMsg(STR0018,{{"[VAR01]",(cAliasDCF)->DCF_DOCTO},{"[VAR02]",(cAliasDCF)->DCF_PRDORI}}) // Documento : [VAR01]/ Produto: [VAR02] pendente de execução ou finalização!
		lRet := .T.
	EndIf
	(cAliasDCF)->(dbCloseArea())
	RestArea(aAreaAnt)
Return lRet
//----------------------------------------
/*/{Protheus.doc} ExisteDCF
Verifica se existe DCF
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//----------------------------------------
METHOD ExisteDCF() CLASS WMSDTCOrdemServico
Local aAreaAnt  := GetArea()
Local lRet      := .F.
Local cAliasDCF := GetNextAlias()
	cQuery := " SELECT DCF.DCF_ID"
	cQuery += " FROM "+RetSqlName('DCF')+" DCF"
	cQuery += " WHERE DCF.DCF_FILIAL = '"+xFilial('DCF')+"'"
	cQuery += " AND DCF.DCF_ID = '"+Self:cIdDCF+"'"
	cQuery += " AND DCF.DCF_STSERV <> '0'"
	cQuery += " AND DCF.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasDCF,.F.,.T.)
	If (cAliasDCF)->(!Eof())
		lRet := .T.
	EndIf
	(cAliasDCF)->(dbCloseArea())
	RestArea(aAreaAnt)
Return lRet
//----------------------------------------
/*/{Protheus.doc} FindDocto
Procura o documento
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//----------------------------------------
METHOD FindDocto() CLASS WMSDTCOrdemServico
Local aAreaAnt   := GetArea()
Local cDocumento := ""
Local cAliasDCF  := GetNextAlias()
	cQuery := " SELECT DCF_DOCTO"
	cQuery += " FROM "+RetSqlName('DCF')+" DCF"
	cQuery += " WHERE DCF.DCF_FILIAL = '"+xFilial('DCF')+"'"
	cQuery += " AND DCF.DCF_IDORI = '"+Self:cIdDCF+"'"
	cQuery += " AND DCF.DCF_STSERV = '1'"
	cQuery += " AND DCF.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasDCF,.F.,.T.)
	If (cAliasDCF)->(!Eof())
		cDocumento := (cAliasDCF)->DCF_DOCTO
	EndIf
	// Busca dados servico
	If Empty(cDocumento)
		cDocumento :=  GetSX8Num('DCF', 'DCF_DOCTO'); ConfirmSx8()
	EndIf
	(cAliasDCF)->(dbCloseArea())
	RestArea(aAreaAnt)
Return cDocumento
//----------------------------------------
/*/{Protheus.doc} UpdEndDCF
Atualiza endereço DCF
@author felipe.m
@since 23/12/2014
@version 1.0
@param cEndereco, character, (Descrição do parâmetro)
@param lEndVazio, ${param_type}, (Descrição do parâmetro)
/*/
//----------------------------------------
METHOD UpdEndDCF(cEndereco,lEndVazio) CLASS WMSDTCOrdemServico
Local aArea      := GetArea()
Local cQuery     := ''
Local cAliasQry  := GetNextAlias()
Local oOrdSerAux := WMSDTCOrdemServico():New()

Default lEndVazio := .T. // Atualiza somente OS sem informação de endereço ou atualiza tudo

	cQuery := "SELECT DCF.R_E_C_N_O_ RECNODCF"
	cQuery +=  " FROM "+RetSqlName('DCF')+" DCF"
	cQuery += " WHERE DCF.DCF_FILIAL = '"+xFilial('DCF')+"'"
	cQuery +=   " AND DCF.DCF_DOCTO = '"+Self:cDocumento+"'"
	cQuery +=   " AND DCF.DCF_SERIE = '"+Self:cSerie+"'"
	cQuery +=   " AND DCF.DCF_CLIFOR = '"+Self:cCliFor+"'"
	cQuery +=   " AND DCF.DCF_LOJA = '"+Self:cLoja+"'"
	cQuery +=   " AND DCF.DCF_CODPRO = '"+Self:oProdLote:GetPrdOri()+"'"
	cQuery +=   " AND DCF.DCF_ORIGEM = 'SC9'"
	cQuery +=   " AND DCF.DCF_STSERV IN ('1','2')"
	If lEndVazio
		cQuery += " AND DCF.DCF_ENDER = ' '"
		cQuery += " AND DCF.DCF_ESTFIS = ' '"
	EndIf
	cQuery +=   " AND DCF.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	While (cAliasQry)->(!Eof())
		oOrdSerAux:GoToDCF((cAliasQry)->RECNODCF)
		oOrdSerAux:oOrdEndDes:SetEnder(cEndereco)
		oOrdSerAux:oOrdEndDes:LoadData()
		oOrdSerAux:UpdateDCF()
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
	RestArea(aArea)
Return lRet
//----------------------------------------
/*/{Protheus.doc} ChkDistr
Verifica distribuição
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//----------------------------------------
METHOD ChkDistr() CLASS WMSDTCOrdemServico
Local lRet := .T.
Local cAliasNew := GetNextAlias()
	cQuery := " SELECT 1"
	cQuery +=   " FROM "+RetSqlName("SD1")+" SD1"
	cQuery +=  " INNER JOIN "+RetSqlName("D07")+" D07" 
	cQuery +=     " ON D07.D07_FILIAL = '"+xFilial("D07")+"'"
	cQuery +=    " AND D07.D07_DOC = SD1.D1_DOC"
	cQuery +=    " AND D07.D07_SERIE = SD1.D1_SERIE"
	cQuery +=    " AND D07.D07_FORNEC = SD1.D1_FORNECE"
	cQuery +=    " AND D07.D07_LOJA = SD1.D1_LOJA"
	cQuery +=    " AND D07.D07_PRODUT = SD1.D1_COD"
	cQuery +=    " AND D07.D07_ITEM = SD1.D1_ITEM"
	cQuery +=    " AND D07.D_E_L_E_T_ = ' '"
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
	cQuery +=    " AND SD1.D1_IDDCF = '"+Self:cIdDCF+"'"
	cQuery +=    " AND SD1.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasNew,.F.,.T.)
	lRet := (cAliasNew)->(!Eof())
	(cAliasNew)->(dbCloseArea())
Return lRet
//----------------------------------------
/*/{Protheus.doc} UpdLibD0A
Realiza movimentações necessárias de estoque/saldo para a montagem/desmontagem de produto.
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//----------------------------------------
METHOD UpdLibD0A(cIdMovto,cIdOpera) CLASS WMSDTCOrdemServico
Local lRet       := .T.
Local cQuery     := ""
Local cAliasD12  := ""
Local oDmdUnit   := Nil
Local oOrdServ   := Nil
Local oRegraConv := Nil
Local oOrdSerExe := Nil
Local nX         := 0

Default cIdMovto := Space(TamSx3("D12_IDMOV")[1])
Default cIdOpera := Space(TamSx3("D12_IDOPER")[1])

	// Verifica se todos os movimentos da DCF foram concluidos
	// Desconsidera o movimento atual,pois o movimento é a ultima atividade mas não alterou o status
	cAliasD12 := GetNextAlias()
	cQuery := "SELECT D12.R_E_C_N_O_ RECNOD12 "
	cQuery +=  " FROM "+RetSqlName("D12")+" D12 "
	cQuery += " WHERE D12.D12_FILIAL = '"+xFilial("D12")+"'"
	cQuery +=   " AND D12.D12_DOC = '"+Self:GetDocto()+"'"
	cQuery +=   " AND D12.D12_ORIGEM = 'D0A'"
	cQuery +=   " AND D12.D12_SERVIC = '"+Self:oServico:GetServico()+"'"
	cQuery +=   " AND D12.D12_IDMOV <> '"+cIdMovto+"'"
	cQuery +=   " AND D12.D12_IDOPER <> '"+cIdOpera+"'"
	cQuery +=   " AND D12.D12_STATUS IN ('4','3','2','-')"
	cQuery +=   " AND D12.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasD12,.F.,.T.)
	If (cAliasD12)->(Eof())
		// Busca as montagens de demontagens de transferencia
		// Para baixar o saldo da doca com produto a ser montado ou desmontado.
		lRet := Self:MakeConv()
		If lRet
			lRet := Self:AtuMovSD3()
		EndIf
		If lRet
			//Se armazém controla unitizador, gera demanda de unitização
			If WmsArmUnit(Self:oOrdEndDes:GetArmazem())
				oDmdUnit := WMSDTCDemandaUnitizacaoCreate():New()
				oDmdUnit:SetDocto(Self:cDocumento)
				oDmdUnit:SetOrigem('D0A')
				lRet := oDmdUnit:CreateD0Q()
			Else
				oOrdServ   := WMSDTCOrdemServicoCreate():New()
				WmsOrdSer(oOrdServ)
				// Para criar a ordem de serviço
				//
				oOrdServ:SetArrLib(oRegraConv:GetArrLib())
				oOrdServ:SetDocto(Self:cDocumento)
				oOrdServ:SetTipMov("2")
				oOrdServ:SetOrigem("D0A")
				If !oOrdServ:CreateDCF()
					lRet := .F.
				EndIf
				// Verifica se é execução automática da ordem de serviço
				If lRet
					WmsExeServ()
				EndIf
			EndIf
		EndIf
	EndIf
	(cAliasD12)->(dbCloseArea())
Return lRet
//----------------------------------------
/*/{Protheus.doc} UndoMntDes
Montagem e desmontagem de produtos, ajuste de saldo estorno
produto origem para o produto destino
@author alexsander.correa
@since 03/03/2015
@version 1.0
/*/
//----------------------------------------
METHOD UndoMntDes() CLASS WMSDTCOrdemServico
Local lRet       := .T.
Local cQuery     := ""
Local cAliasDCF  := ""
Local cAliasD12  := ""
Local lLiberado  := .T.
Local lAchou     := .F.
Local oOrdSerDel := WMSDTCOrdemServicoDelete():New()

	// Verifica se todos os movimentos da DCF foram concluidos
	cAliasD12 := GetNextAlias()
	cQuery := "SELECT D12.R_E_C_N_O_ RECNOD12"
	cQuery +=  " FROM "+RetSqlName("D12")+" D12"
	cQuery += " WHERE D12.D12_FILIAL = '"+xFilial("D12")+"'"
	cQuery +=   " AND D12.D12_DOC = '"+Self:GetDocto()+"'"
	cQuery +=   " AND D12.D12_ORIGEM = 'D0A'"
	cQuery +=   " AND D12.D12_STATUS NOT IN ('0','1')"
	cQuery +=   " AND D12.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasD12,.F.,.T.)
	If (cAliasD12)->(!Eof())
		lLiberado := .F.
	EndIf
	If lLiberado
		cAliasDCF := GetNextAlias()
		cQuery := "SELECT DCF.DCF_ID"
		cQuery +=  " FROM "+ RetSqlName('DCF')+" DCF"
		cQuery += " WHERE DCF.DCF_FILIAL = '"+ xFilial("DCF")+"'"
		cQuery +=   " AND DCF.DCF_LOCAL = '"+Self:oProdLote:GetArmazem()+"'"
		cQuery +=   " AND DCF.DCF_DOCTO = '"+Self:cDocumento+"'"
		cQuery +=   " AND DCF.DCF_ORIGEM = 'D0A'"
		cQuery +=   " AND DCF.DCF_SERVIC <> '"+Self:oServico:GetServico()+"'"
		cQuery +=   " AND DCF.DCF_STSERV NOT IN ('0','3')"
		cQuery +=   " AND DCF.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDCF,.F.,.T.)
		If (cAliasDCF)->(!Eof())
			lAchou := .T.
		EndIf
		Do While lRet .And. (cAliasDCF)->(!Eof())
			oOrdSerDel:SetIdDCF((cAliasDCF)->DCF_ID)
			If oOrdSerDel:LoadData()
				If !oOrdSerDel:DeleteDCF()
					lRet := .F.
				EndIf
			Else
				lRet := .F.
			EndIf
			If !lRet
				Self:cErro := oOrdSerDel:GetErro()
				Exit
			EndIf
			(cAliasDCF)->(dbSkip())
		EndDo
		(cAliasDCF)->(dbCloseArea())
		If lRet .And. lAchou
			// Movimentação interna SD3
			lRet := Self:UndoConv()
			If lRet
				lRet := Self:UndoMovSD3()
			EndIf
		EndIf
	EndIf
Return lRet
//----------------------------------------
/*/{Protheus.doc} HaveMovD0A
Verificar se endereçamento da montagem ou desmontagem está executado
@author alexsander.correa
@since 05/03/2015
@version 1.0
/*/
//----------------------------------------
METHOD HaveMovD0A() CLASS WMSDTCOrdemServico
Local lRet       := .T.
Local cQuery     := ""
Local cAliasD0Q  := ""
Local cAliasDCF  := ""
Local cAliasDCF1 := ""
Local cAliasD12  := ""
Local oMntDesmon := WMSDTCMontagemDesmontagem():New()
	oMntDesmon:SetDocto(Self:cDocumento)
	If oMntDesmon:LoadData()
		If WmsArmUnit(Self:oProdLote:GetArmazem())
			cAliasD0Q := GetNextAlias()
			cQuery := " SELECT D0Q.D0Q_STATUS"
			cQuery +=   " FROM "+RetSqlName('D0Q')+" D0Q"
			cQuery +=  " WHERE D0Q.D0Q_FILIAL = '"+xFilial('D0Q')+"'"
			cQuery +=    " AND D0Q.D0Q_LOCAL  = '"+Self:oProdLote:GetArmazem()+"'"
			cQuery +=    " AND D0Q.D0Q_DOCTO  = '"+Self:cDocumento+"'"
			cQuery +=    " AND D0Q.D0Q_ORIGEM = 'D0A'"
			cQuery +=    " AND D0Q.D0Q_STATUS <> '1'"
			cQuery +=    " AND D0Q.D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasD0Q,.F.,.T.)
			If (cAliasD0Q)->(!EoF())
				Self:cErro := WmsFmtMsg(STR0033,{{"[VAR01]",Iif((cAliasD0Q)->D0Q_STATUS == "2",STR0034,STR0035)}}) //Existem demandas de unitização [VAR01] para o documento, estorno não poderá ser realizado. //em andamento //finalizada
				lRet := .F.
			EndIf
			(cAliasD0Q)->(dbCloseArea())
		EndIf
		If lRet
			cAliasDCF := GetNextAlias()
			cQuery := "SELECT 1"
			cQuery +=  " FROM "+ RetSqlName('DCF')+" DCF"
			cQuery += " WHERE DCF.DCF_FILIAL = '"+ xFilial("DCF")+"'"
			cQuery +=   " AND DCF.DCF_LOCAL = '"+Self:oProdLote:GetArmazem()+"'"
			cQuery +=   " AND DCF.DCF_DOCTO = '"+Self:cDocumento+"'"
			cQuery +=   " AND DCF.DCF_ORIGEM = 'D0A'"
			cQuery +=   " AND DCF.DCF_SERVIC <> '"+Self:oServico:GetServico()+"'"
			cQuery +=   " AND DCF.DCF_STSERV = '3'"
			cQuery +=   " AND DCF.D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDCF,.F.,.T.)
			If (cAliasDCF)->(!Eof())
				Self:cErro := STR0016 // Existem ordens de servico de endereçamento executadas para o documento, estorno não poderá ser realizado.
				lRet := .F.
			Else
				cAliasDCF1 := GetNextAlias()
				cQuery := "SELECT 1"
				cQuery +=  " FROM "+ RetSqlName('DCF')+" DCF"
				cQuery += " INNER JOIN "+ RetSqlName('DCF')+" DCF1"
				cQuery +=    " ON DCF.DCF_FILIAL = '"+ xFilial("DCF")+"'"
				cQuery +=   " AND DCF1.DCF_FILIAL = '"+ xFilial("DCF")+"'"
				cQuery +=   " AND DCF1.DCF_LOCAL = '"+Self:oProdLote:GetArmazem()+"'"
				cQuery +=   " AND DCF1.DCF_IDORI = DCF.DCF_ID"
				cQuery +=   " AND DCF1.DCF_STSERV <> '3'"
				cQuery +=   " AND DCF1.D_E_L_E_T_ = ' '"
				cQuery += " WHERE DCF.DCF_FILIAL = '"+ xFilial("DCF")+"'"
				cQuery +=   " AND DCF.DCF_LOCAL = '"+Self:oProdLote:GetArmazem()+"'"
				cQuery +=   " AND DCF.DCF_DOCTO = '"+Self:cDocumento+"'"
				cQuery +=   " AND DCF.DCF_ORIGEM = 'D0A'"
				cQuery +=   " AND DCF.DCF_SERVIC <> '"+Self:oServico:GetServico()+"'"
				cQuery +=   " AND DCF.DCF_STSERV <> '3'"
				cQuery +=   " AND DCF.D_E_L_E_T_ = ' '"
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDCF1,.F.,.T.)
				If (cAliasDCF1)->(!Eof())
					Self:cErro := STR0021 //Existem ordens de servico de transferência pendentes do endereçamento, estorno não poderá ser realizado.
					lRet := .F.
				Else
					cAliasD12 := GetNextAlias()
					cQuery := "SELECT 1"
					cQuery +=  " FROM "+ RetSqlName('DCF')+" DCF"
					cQuery += " INNER JOIN "+ RetSqlName('DCF')+" DCF1"
					cQuery +=    " ON DCF.DCF_FILIAL = '"+ xFilial("DCF")+"'"
					cQuery +=   " AND DCF1.DCF_FILIAL = '"+ xFilial("DCF")+"'"
					cQuery +=   " AND DCF1.DCF_LOCAL = '"+Self:oProdLote:GetArmazem()+"'"
					cQuery +=   " AND DCF1.DCF_IDORI = DCF.DCF_ID"
					cQuery +=   " AND DCF1.DCF_STSERV = '3'"
					cQuery += " INNER JOIN "+ RetSqlName('D12')+" D12"
					cQuery +=    " ON D12.D12_FILIAL = '"+ xFilial("DCF")+"'"
					cQuery +=   " AND D12.D12_STATUS IN ('-','2','3','4')"
					cQuery +=   " AND D12.D12_IDDCF IN ( SELECT DCR.DCR_IDORI"
					cQuery +=                            " FROM "+ RetSqlName('DCR')+" DCR"
					cQuery +=                           " WHERE DCR.DCR_FILIAL = '"+ xFilial("DCF")+"'"
					cQuery +=                             " AND DCF1.DCF_FILIAL = '"+ xFilial("DCF")+"'"
					cQuery +=                             " AND DCR.DCR_IDDCF = DCF1.DCF_ID"
					cQuery +=                             " AND DCR.DCR_SEQUEN = DCF1.DCF_SEQUEN"
					cQuery +=                             " AND DCR.D_E_L_E_T_ = ' ')"
					cQuery +=   " AND D12.D_E_L_E_T_ = ' '"
					cQuery += " WHERE DCF.DCF_FILIAL = '"+ xFilial("DCF")+"'"
					cQuery +=   " AND DCF.DCF_LOCAL = '"+Self:oProdLote:GetArmazem()+"'"
					cQuery +=   " AND DCF.DCF_DOCTO = '"+Self:cDocumento+"'"
					cQuery +=   " AND DCF.DCF_ORIGEM = 'D0A'"
					cQuery +=   " AND DCF.DCF_SERVIC <> '"+Self:oServico:GetServico()+"'"
					cQuery +=   " AND DCF.DCF_STSERV <> '3'"
					cQuery +=   " AND DCF.D_E_L_E_T_ = ' '"
					cQuery := ChangeQuery(cQuery)
					dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasD12,.F.,.T.)
					If (cAliasD12)->(!Eof())
						Self:cErro := STR0022 //Existem movimentos pendentes do servico de transferência do endereçamento, estorno não poderá ser realizado.
						lRet := .F.
					EndIf
					(cAliasD12)->(dbCloseArea())
				EndIf
				(cAliasDCF1)->(dbCloseArea())
			EndIf
			(cAliasDCF)->(dbCloseArea())
		EndIf
	Else
		Self:cErro := oMntDesmon:GetErro()
		lRet := .F.
	EndIf
Return lRet

//----------------------------------------
/*/{Protheus.doc} ShowWarnig
Mostra a mensagem de erro
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//----------------------------------------
METHOD ShowWarnig() CLASS WMSDTCOrdemServico
Local nCntFor := 0
Local cMemo   := ""
Local cMask   := STR0017 // Arquivos Texto (*.TXT) |*.txt|
Local cFile   := Space(100)
Local cTitle  := OemToAnsi(OemToAnsi(STR0019)) // Salvar Aquivo
	If !Empty(Self:aWmsAviso)
		For nCntFor := 1 To Len(Self:aWmsAviso)
			If nCntFor == 1
				cMemo := Self:aWmsAviso[nCntFor]
			Else
				cMemo += CRLF+Self:aWmsAviso[nCntFor]
			EndIf
		Next
		If Self:HasLogEnd()
			cMemo += CRLF+Replicate('*',90)
			cMemo += CRLF+STR0008 // Para ordens de serviço de endereçamento com problemas, execute manual as ordens de serviço interrompidas e analise o relatório de busca de endereço.
		EndIf
		If Self:HasLogSld()
			cMemo += CRLF+Replicate('*',90)
			cMemo += CRLF+STR0009 // Para ordens de serviço de expedição com problemas, execute manual as ordens de serviço interrompidas e analise o relatório de busca de saldo.
		EndIf
		If WmsMsgExibe()
			DEFINE FONT oFont NAME "Courier New" SIZE 5,0   //6,15
			
			DEFINE MSDIALOG oDlg TITLE "SIGAWMS" From 3,0 to 340,717 PIXEL
			
			@ 5,5 GET oMemo  VAR cMemo MEMO SIZE 351,145 OF oDlg PIXEL
			oMemo:bRClicked := {||AllwaysTrue()}
			oMemo:oFont:=oFont
			
			DEFINE SBUTTON  FROM 153,330 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL // Apaga
			DEFINE SBUTTON  FROM 153,300 TYPE 13 ACTION (cFile:=cGetFile(cMask,cTitle),If(cFile="",.T.,MemoWrite(cFile,cMemo)),oDlg:End()) ENABLE OF oDlg PIXEL // Salva e Apaga //"Salvar Como..."

			ACTIVATE MSDIALOG oDlg CENTER
		Else
			WmsMessage(cMemo,"ShowWarnig")
		EndIf
		// Limpa as mensagens anteriores
		Self:aWmsAviso := {}
	EndIf
Return

METHOD AtuMovSD3(lMovAut) CLASS WMSDTCOrdemServico
Local aAreaD0A  := D0A->(GetArea())
Local cProcesso := ""
Local lMontagem := .T.
Local lRet      := .T.
	D0A->(dbSelectArea("D0A"))
	D0A->(dbSetOrder(1))
	If D0A->(dbSeek(xFilial("D0A")+Self:GetDocto()))
		lMontagem := (D0A->D0A_OPERAC == "1")
		cProcesso := D0A->D0A_PROCES
		If cProcesso == "1"     // Process de montagem/desmontagem de estruturas
			lRet := Self:MovSD3Estr(lMovAut,lMontagem)
		ElseiF cProcesso == "2" //Processo de montagem/desmontagem de produtos
			lRet := Self:MovSD3Prod(lMovAut,lMontagem)
		ElseIf cProcesso == "3" // Processo de troca de lotes
			lRet := Self:MovSD3Lote(lMovAut)
		EndIf
	EndIf
	RestArea(aAreaD0A)
Return lRet

METHOD UndoMovSD3() CLASS WMSDTCOrdemServico
Local aAreaD0A   := D0A->(GetArea())
Local aLockProds := {}
Local aApont     := {}
Local cQuery     := ""
Local cAliasD0B  := ""
Local cAliasSD3  := ""
Local lRet       := .T.

Private lMsErroAuto := .F.
Private lExecWms    := Nil
Private lDocWms     := Nil

	D0A->(dbSelectArea("D0A"))
	D0A->(dbSetOrder(1))
	If D0A->(dbSeek(xFilial("D0A")+Self:GetDocto()))
		If D0A->D0A_OPERAC == "2"
			// Estorno de uma Desmontagem
			cQuery := " SELECT D0B_LOCAL,"
			cQuery +=        " D0B_PRDORI"
			cQuery +=   " FROM "+RetSqlName("D0B")
			cQuery +=  " WHERE D0B_FILIAL = '"+xFilial("D0B")+"'"
			cQuery +=    " AND D0B_DOC = '"+Self:GetDocto()+"'"
			cQuery +=    " AND D_E_L_E_T_ = ' '"
			cQuery +=  " GROUP BY D0B_LOCAL, D0B_PRDORI"
			cQuery := ChangeQuery(cQuery)
			cAliasD0B := GetNextAlias()
			dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasD0B,.F.,.T.)
			While (cAliasD0B)->(!Eof())

				aAdd(aLockProds, {(cAliasD0B)->D0B_PRDORI,;  // Produto
				(cAliasD0B)->D0B_LOCAL})   // Armazém
				(cAliasD0B)->(dbSkip())
			EndDo
			(cAliasD0B)->(dbCloseArea())

			cQuery := " SELECT DISTINCT D3_NUMSEQ"
			cQuery +=   " FROM "+RetSqlName("SD3")
			cQuery +=  " WHERE D3_FILIAL = '"+xFilial("SD3")+"'"
			cQuery +=    " AND D3_DOC = '"+Self:GetDocto()+"'"
			cQuery +=    " AND D3_ESTORNO <> 'S'"
			cQuery +=    " AND D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			cAliasSD3 := GetNextAlias()
			dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasSD3,.F.,.T.)
			While (cAliasSD3)->(!Eof())

				EstDesSD3(aLockProds, (cAliasSD3)->D3_NUMSEQ, D0A->D0A_OPERAC)

				(cAliasSD3)->(dbSkip())
			EndDo
			(cAliasSD3)->(dbCloseArea())

		ElseIf D0A->D0A_OPERAC == "1"
			// Estorno de uma Montagem
			cQuery := " SELECT D0B.D0B_LOCAL,"
			cQuery +=        " D0B.D0B_PRDORI,"
			cQuery +=        " SD3.D3_NUMSEQ,"
			cQuery +=        " CASE WHEN (D0B.D0B_PRDORI = D0A.D0A_PRODUT)  THEN '0' ELSE '1' END D0A_ORDEM"
			cQuery +=   " FROM "+RetSqlName("D0B")+" D0B"
			cQuery +=  " INNER JOIN "+RetSqlName('D0A')+" D0A"
			cQuery +=     " ON D0A.D0A_FILIAL = '"+xFilial('D0A')+"'"
			cQuery +=    " AND D0A.D0A_DOC = D0B.D0B_DOC"
			cQuery +=    " AND D0A.D_E_L_E_T_ = ' '"
			cQuery +=  " INNER JOIN "+RetSqlName("SD3")+" SD3"
			cQuery +=     " ON SD3.D3_FILIAL = '"+xFilial("SD3")+"'"
			cQuery +=    " AND SD3.D3_DOC = D0B.D0B_DOC"
			cQuery +=    " AND SD3.D3_LOCAL = D0B.D0B_LOCAL"
			cQuery +=    " AND SD3.D3_COD = D0B.D0B_PRDORI"
			cQuery +=    " AND SD3.D3_LOTECTL = D0B.D0B_LOTECT"
			cQuery +=    " AND SD3.D3_NUMLOTE = D0B.D0B_NUMLOT"
			cQuery +=    " AND SD3.D_E_L_E_T_= ' '"
			cQuery +=  " WHERE D0B.D0B_FILIAL = '"+xFilial("D0B")+"'"
			cQuery +=    " AND D0B_DOC = '"+Self:GetDocto()+"'"
			cQuery +=    " AND D0B.D_E_L_E_T_ = ' '"
			cQuery +=  " GROUP BY D0B.D0B_LOCAL, D0B.D0B_PRDORI, SD3.D3_NUMSEQ, D0A.D0A_PRODUT"
			cQuery +=  " ORDER BY D0A_ORDEM"
			cQuery := ChangeQuery(cQuery)
			cAliasSD3 := GetNextAlias()
			dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasSD3,.F.,.T.)
			Do While (cAliasSD3)->(!Eof())
				SD3->(dbSetOrder(3)) // D3_FILIAL+D3_COD+D3_LOCAL+D3_NUMSEQ+D3_CF
				SD3->(dbSeek(xFilial("SD3")+(cAliasSD3)->(D0B_PRDORI+D0B_LOCAL+D3_NUMSEQ)))
				aApont := {}
				If (cAliasSD3)->D0A_ORDEM == "0"
					Aadd(aApont,{"D3_DOC"    ,SD3->D3_DOC       ,Nil})
					Aadd(aApont,{"D3_OP"     ,SD3->D3_OP        ,Nil})
					Aadd(aApont,{"D3_COD"    ,SD3->D3_COD       ,Nil})
					Aadd(aApont,{"D3_UM"     ,SD3->D3_UM        ,Nil})
					Aadd(aApont,{"D3_QUANT"  ,SD3->D3_QUANT     ,Nil})
					Aadd(aApont,{"D3_LOCAL"  ,SD3->D3_LOCAL     ,Nil})
					Aadd(aApont,{"D3_CC"     ,SD3->D3_CC        ,Nil})
					Aadd(aApont,{"D3_EMISSAO",SD3->D3_EMISSAO   ,Nil})
					If Rastro(SD3->D3_COD)
						Aadd(aApont,{"D3_LOTECTL",SD3->D3_LOTECTL   ,Nil})
						Aadd(aApont,{"D3_DTVALID",SD3->D3_DTVALID   ,Nil})
					EndIf
					Aadd(aApont,{"D3_NUMSEQ" ,SD3->D3_NUMSEQ    ,Nil})
					Aadd(aApont,{"D3_CHAVE"  ,SD3->D3_CHAVE     ,Nil})
					Aadd(aApont,{"D3_CF"     ,"PR0"             ,Nil})
					aAdd(aApont,{"INDEX"     , 4                ,Nil})

					lMsErroAuto := .F.
					lExecWms := .T.
					
					// Estorno automático do apontamento da ordem de produção
					MsExecAuto({|x,y| MATA250(x,y)},aApont,5)

					If lMsErroAuto
						// Erro na criação da SD3 pelo MsExecAuto
						MostraErro()
						If Intransaction()
							DisarmTransaction()
						EndIf
						lRet := .F.
						Exit
					EndIf
				Else
					Do While SD3->(!Eof()) .And. SD3->(D3_FILIAL+D3_COD+D3_LOCAL+D3_NUMSEQ) == xFilial("SD3")+(cAliasSD3)->(D0B_PRDORI+D0B_LOCAL+D3_NUMSEQ)
						If SD3->D3_ESTORNO != "S"
							// Indica que será DH1 e DCF
							lExecWms := .T.
							lDocWms  := .T.
							lMsErroAuto := .F.

							// Estorno do movimento de requisição
							MsExecAuto({|x,y,z| MATA241(x,y,z)},{},Nil,6)

							If lMsErroAuto
								// Erro na criação da SD3 pelo MsExecAuto
								MostraErro()
								If Intransaction()
									DisarmTransaction()
								EndIf
								lRet := .F.
								Exit
							EndIf
						EndIf
						SD3->(dbSkip())
					EndDo
				EndIf

				If !lRet
					Exit
				EndIf

				(cAliasSD3)->(dbSkip())
			EndDo
			(cAliasSD3)->(dbCloseArea())
		EndIf
	EndIf
	RestArea(aAreaD0A)
Return lRet

METHOD UpdEmpSB2(cOper,cPrdOri,cArmazem,nQuant,lReserva,cTipOp)  CLASS WMSDTCOrdemServico
Local lRet       := .T.
Local aAreaSB2   := SB2->(GetArea())
Default lReserva := .T.
Default cTipOp   := ""
	// Reversa produto
	SB2->(dbSetOrder(1)) // B2_FILIAL+B2_COD+B2_LOCAL
	If SB2->(dbSeek(xFilial("SB2")+cPrdOri+cArmazem))
		GravaB2Emp(cOper,nQuant,cTipOp,lReserva)
	EndIf
	RestArea(aAreaSB2)
Return lRet

METHOD UpdEmpSB8(cOper,cPrdOri,cArmazem,cLoteCtl, cNumLote, nQuant)  CLASS WMSDTCOrdemServico
Local lRet     := .T.
Local aAreaSB8 := SB8->(GetArea())
	// Empenha Lote
	SB8->(dbSetOrder(3))	// B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL+B8_NUMLOTE+DTOS(B8_DTVALID)
	If SB8->(dbSeek(xFilial("SB8")+cPrdOri+cArmazem+cLoteCtl+Padr(cNumLote,TamSx3("B8_NUMLOTE")[1])))
		GravaB8Emp(cOper,nQuant,Nil,.T.)
	EndIf
	RestArea(aAreaSB8)
Return lRet

METHOD UpdEmpSD4(lExcluir) CLASS WMSDTCOrdemServico
Local lRet := .T.
Local cOp  := PadR("",TamSx3("D4_OP")[1])
Local cTrt := PadR("",TamSx3("D4_TRT")[1])

Default lExcluir := .F.

	dbSelectArea("SD4")
	SD4->(dbSetOrder(1)) // D4_FILIAL+D4_COD+D4_OP+D4_TRT+D4_LOTECTL+D4_NUMLOTE
	// D4_FILIAL, D4_COD, D4_OP, D4_TRT, D4_LOTECTL, D4_NUMLOTE, D4_LOCAL, D4_ORDEM, D4_OPORIG, D4_SEQ, R_E_C_D_E_L_
	If !SD4->(dbSeek(xFilial("SD4")+Self:oProdLote:GetPrdOri()+cOp+cTrt+Self:oProdLote:GetLoteCtl()+Self:oProdLote:GetNumLote()))
		RecLock("SD4", .T.)
		SD4->D4_FILIAL  := xFilial("SD4")
		SD4->D4_COD     := Self:oProdLote:GetPrdOri()
		SD4->D4_LOCAL   := Self:oProdLote:GetArmazem()
		SD4->D4_OP      := cOp
		SD4->D4_TRT     := cTrt
		SD4->D4_LOTECTL := Self:oProdLote:GetLoteCtl()
		SD4->D4_NUMLOTE := Self:oProdLote:GetNumLote()
		SD4->D4_DATA    := dDataBase
		SD4->D4_QUANT   := Self:nQuant
		SD4->D4_QTSEGUM := ConvUM(Self:oProdLote:GetPrdOri(), SD4->D4_QUANT, 0, 2)
		SD4->D4_QTDEORI := SD4->D4_QUANT
		SD4->D4_IDDCF   := Self:cIdDCF
		SD4->(MsUnlock())
		// Grava empenho SB2
		GravaEmp(Self:oProdLote:GetProduto(),; //1
		Self:oProdLote:GetArmazem(),;   //2
		Self:nQuant,;     //3
		Nil,;             //4
		Self:oProdLote:GetLoteCtl(),; //5
		Self:oProdLote:GetNumLote(),; //6
		Nil,;             //7
		Nil,;             //8
		Nil,;             //9
		,;                //10
		,;                //11
		,;                //12
		"SD3",;           //13
		Nil,;             //14
		Nil,;             //15
		Nil,;             //16
		.F.,;             //17
		.F.,;             //18
		.T.,;             //19
		.F.,;             //20
		!Empty(Self:oProdLote:GetLoteCtl()+Self:oProdLote:GetNumLote()),; //21
		.T.,;             //22
		.F.,;             //23
		.F.,;             //24
		Self:cIdDCF) //25
	Else
		lRet := .F.
	EndIf
Return lRet

METHOD GetSeqPri() CLASS WMSDTCOrdemServico
	If Empty(Self:cSeqPriExe)
		Self:cSeqPriExe := Self:FindSeqPri()
	EndIf
Return Self:cSeqPriExe

METHOD FindSeqPri() CLASS WMSDTCOrdemServico
Local aAreaAnt  := GetArea()
Local cAliasD12 := ""
Local cVazioSeq := Space(TamSx3("D12_SEQPRI")[1])
Local cSeqPri   := ""
	cQuery := " SELECT D12_SEQPRI"
	cQuery += " FROM " + RetSqlName('D12')+" D12"
	cQuery += " WHERE D12.D12_FILIAL = '"+xFilial("D12")+"'"
	If WmsCarga(Self:cCarga)
		cQuery += " AND D12.D12_CARGA = '"+Self:cCarga+"'"
	Else
		cQuery += " AND D12.D12_DOC = '"+Self:cDocumento+"'"
		cQuery += " AND D12.D12_CLIFOR = '"+Self:cCliFor+"'"
		cQuery += " AND D12.D12_LOJA = '"+Self:cLoja+"'"
	EndIf
	cQuery += " AND D12.D12_SEQPRI <> '"+cVazioSeq+"'"
	cQuery += " AND D12.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasD12 := GetNextAlias()
	dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasD12,.F.,.T.)
	(cAliasD12)->(dbGotop())
	If (cAliasD12)->( !Eof())
		cSeqPri := (cAliasD12)->D12_SEQPRI
	EndIf
	(cAliasD12)->(dbCloseArea())

	If Empty(cSeqPri)
		cSeqPri := Self:NextSeqPri('MV_WMSSQPR','D12_SEQPRI') // Proxima sequencia da execucao dos servicos
	EndIf
	RestArea(aAreaAnt)
Return cSeqPri

//--------------------------------------------------
/*/{Protheus.doc} NextSeqPri
Proxima sequencia de prioridade
@author felipe.m
@since 23/12/2014
@version 1.0
@param cParametro, character, (Parametro)
@param cField, character, (Campos)
/*/
//--------------------------------------------------
METHOD NextSeqPri(cParametro, cField) CLASS WMSDTCOrdemServico
Local cCodAnt := ""
Local nC      := 0
	While !LockByName("WMSPROXSEQ", .T., .F.)
		Sleep(50)
		nC++
		If nC == 60
			nC := 0
		EndIf
	EndDo
	cCodAnt := PadR(GetMv(cParametro), TamSx3(cField)[1])
	If Empty(cCodAnt)
		cCodAnt := Replicate('0',TamSX3(cField)[1])
	EndIf
	cCodAnt := Soma1(cCodAnt,TamSX3(cField)[1])
	PutMv(cParametro,cCodAnt)
	UnLockByName("WMSPROXSEQ", .T., .F.)
Return cCodAnt

METHOD EstParcial(nRecnoSC9,nQtdQuebra,lPedEmp) CLASS WMSDTCOrdemServico
Local lRet         := .T.
Local lBxEmp       := .F.
Local cQuery       := ""
Local cAliasD12    := ""
Local cProduto     := PadR("",TamSx3("D12_PRODUT")[1])
Local cOrdTar      := PadR("",TamSx3("D12_ORDTAR")[1])
Local cTarefa      := PadR("",TamSx3("D12_TAREFA")[1])
Local cOrdAti      := PadR("",TamSx3("D12_ORDATI")[1])
Local cAtividade   := PadR("",TamSx3("D12_ATIVID")[1])
Local nQtdOrig     := 0
Local nQtdMvto     := 0
Local nQtdAux      := nQtdQuebra
Local oMntVolItem  := Nil
Local oConfExpItem := Nil
Local oDisSepItem  := Nil
Local aAreaSC9     := SC9->(GetArea())
Local aAreaSDC     := SDC->(GetArea())
Local oEstEnder    := WMSDTCEstoqueEndereco():New()
Local oRelacMov    := Nil
	// Procura as movimentações criadas do produto para atualização da nova quantidade
	cQuery := " SELECT D12.D12_PRODUT,"
	cQuery +=        " D12.D12_SERVIC,"
	cQuery +=        " D12.D12_ORDTAR,"
	cQuery +=        " D12.D12_TAREFA,"
	cQuery +=        " D12.D12_ORDATI,"
	cQuery +=        " D12.D12_ATIVID,"
	cQuery +=        " (CASE"
	cQuery +=              " WHEN D11.D11_QTMULT IS NULL THEN 1"
	cQuery +=              " ELSE D11.D11_QTMULT"
	cQuery +=         " END) D11_QTMULT,"
	cQuery +=        " DCR.R_E_C_N_O_ RECNODCR"
	cQuery +=   " FROM "+RetSqlName("D12")+" D12"
	cQuery +=  " INNER JOIN "+RetSqlName("DCR")+" DCR"
	cQuery +=     " ON DCR.DCR_FILIAL = '"+xFilial("DCR")+"'"
	cQuery +=    " AND DCR.DCR_IDDCF = '"+Self:GetIDDCF()+"'"
	cQuery +=    " AND DCR.DCR_SEQUEN = '"+Self:GetSequen()+"'"
	cQuery +=    " AND DCR.D_E_L_E_T_ = ' '"
	cQuery +=   " LEFT JOIN "+RetSqlName("D11")+" D11"
	cQuery +=     " ON D11.D11_FILIAL = '"+xFilial("D11")+"'"
	cQuery +=    " AND D12.D12_FILIAL = '"+xFilial("D12")+"'"
	cQuery +=    " AND D11.D11_PRDORI = D12.D12_PRDORI"
	cQuery +=    " AND D11.D11_PRDCMP = D12.D12_PRODUT"
	cQuery +=    " AND D11.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE D12.D12_FILIAL = '"+xFilial("D12")+"'"
	cQuery +=    " AND D12.D12_IDDCF = DCR.DCR_IDORI"
	cQuery +=    " AND D12.D12_IDMOV = DCR.DCR_IDMOV"
	cQuery +=    " AND D12.D12_IDOPER = DCR.DCR_IDOPER"
	cQuery +=    " AND D12.D12_STATUS <> '0'"
	cQuery +=    " AND D12.D_E_L_E_T_ = ''"
	cQuery +=  " ORDER BY D12.D12_SERVIC,"
	cQuery +=           " D12.D12_ORDTAR,"
	cQuery +=           " D12.D12_TAREFA,"
	cQuery +=           " D12.D12_ORDATI,"
	cQuery +=           " D12.D12_ATIVID,"
	// Se empenhado deverá ordenar a partir dos movimentos finalizados
	// Se não empenhado deverá ordenar a partir dos movimentos não finalizados
	If !lPedEmp
		cQuery +=       " D12.D12_STATUS DESC"
	Else
		cQuery +=       " D12.D12_STATUS"
	EndIf
	cQuery := ChangeQuery(cQuery)
	cAliasD12 := GetNextAlias()
	dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasD12,.F.,.T.)
	If (cAliasD12)->(!Eof())
		oRelacMov := WMSDTCRelacionamentoMovimentosServicoArmazem():New()
		Do While (cAliasD12)->(!Eof()) .And. lRet
			If cProduto+cOrdTar+cTarefa+cOrdAti+cAtividade <> (cAliasD12)->(D12_PRODUT+D12_ORDTAR+D12_TAREFA+D12_ORDATI+D12_ATIVID)
				cProduto   := (cAliasD12)->D12_PRODUT
				cOrdTar    := (cAliasD12)->D12_ORDTAR
				cTarefa    := (cAliasD12)->D12_TAREFA
				cOrdAti    := (cAliasD12)->D12_ORDATI
				cAtividade := (cAliasD12)->D12_ATIVID
				nQtdQuebra := nQtdAux
			EndIf
			If nQtdQuebra > 0
				If oRelacMov:GotoDCR((cAliasD12)->RECNODCR)
					// Ajusta saida e entrada prevista
					// Ajusta movimentações
					nQtdOrig := oRelacMov:GetQuant()
					nQtdMvto := Iif((nQtdQuebra*(cAliasD12)->D11_QTMULT) >= oRelacMov:GetQuant(),oRelacMov:GetQuant(),nQtdQuebra*(cAliasD12)->D11_QTMULT)
					lRet := oRelacMov:UpdQtdMov(nQtdQuebra*(cAliasD12)->D11_QTMULT,@lBxEmp)
					nQtdQuebra -= (nQtdMvto/(cAliasD12)->D11_QTMULT)
				EndIf
			EndIf
			(cAliasD12)->(dbSkip())
		EndDo
	EndIf
	(cAliasD12)->(dbCloseArea())
	If lRet
		// Retira o empenho da DOCA com base no SC9 e quantidade estornada
		// Retira a quantidade original e separa dos processos de expedição
	 	If lBxEmp .And. lPedEmp
			oEstEnder:ReversePed(nRecnoSC9,nQtdAux)
		EndIf
		// Atualização DCT e DCS quando existir montagem de volume
		oMntVolItem := WMSDTCMontagemVolumeItens():New()
		oMntVolItem:SetCarga(Self:GetCarga())
		oMntVolItem:SetPedido(Self:GetDocto())
		oMntVolItem:SetCodMnt(oMntVolItem:oMntVol:FindCodMnt())
		oMntVolItem:SetPrdOri(Self:oProdLote:GetPrdOri())
		oMntVolItem:SetProduto(Self:oProdLote:GetProduto())
		oMntVolItem:SetIdDCF(Self:GetIdDCF())
		If oMntVolItem:LoadData()
			// Atualização das quantidades e liberação dos pedidos caso processo libere
			oMntVolItem:UpdQtdParc(nQtdAux,lBxEmp)
		EndIf
		// Atualiza D02 e D01 quando existir conferência de expedição
		oConfExpItem := WMSDTCConferenciaExpedicaoItens():New()
		oConfExpItem:SetCarga(Self:GetCarga())
		oConfExpItem:SetPedido(Self:GetDocto())
		oConfExpItem:SetCodExp(oConfExpItem:oConfExp:FindCodExp())
		oConfExpItem:SetPrdOri(Self:oProdLote:GetPrdOri())
		oConfExpItem:SetProduto(Self:oProdLote:GetProduto())
		oConfExpItem:SetIdDCF(Self:GetIdDCF())
		If oConfExpItem:LoadData()
			// Atualização das quantidades e liberação dos pedidos caso processo libere
			oConfExpItem:UpdQtdParc(nQtdAux,lBxEmp)
		EndIf
		// Atualiza D0E e D0D quando existir distribuição de separação
		oDisSepItem := WMSDTCDistribuicaoSeparacaoItens():New()
		oDisSepItem:SetCarga(Self:GetCarga())
		oDisSepItem:SetPedido(Self:GetDocto())
		oDisSepItem:oDisSep:oDisEndDes:SetArmazem(Self:oOrdEndDes:GetArmazem())
		oDisSepItem:SetCodDis(oDisSepItem:oDisSep:FindCodDis())
		oDisSepItem:oDisEndOri:SetArmazem(Self:oOrdEndOri:GetArmazem())
		oDisSepItem:oDisPrdLot:SetPrdOri(Self:oProdLote:GetPrdOri())
		oDisSepItem:oDisPrdLot:SetProduto(Self:oProdLote:GetProduto())
		If oDisSepItem:LoadData()
			// Atualização das quantidades da distribuição da separação
			oDisSepItem:UpdQtdParc(nQtdAux,lBxEmp)
		EndIf
		// Atualiza quantidade ordem de serviço
		Self:SetQuant(Self:GetQuant() - nQtdAux)
		If Self:GetQtdOri() == 0
			Self:SetQtdOri(Self:GetQuant())
		EndIf
		Self:UpdateDCF()
		// Verifica se existe movimentos para a ordem de serviço se não existir excluir a ordem de serviço
		If Self:GetQuant() == 0
			If !Self:HaveMovD12("0")
				If lRet
					If !(lRet := Self:UndoIntegr())
						Self:cErro := STR0007 // Não foi possível desfazer a integração da ordem de serviço!
					EndIf
				EndIf
				If lRet
					Self:ExcludeDCF()
				EndIf
			Else
				Self:CancelDCF()
			EndIf
		EndIf
	EndIf
	RestArea(aAreaSC9)
	RestArea(aAreaSDC)
Return lRet

METHOD FindDCFOri() CLASS WMSDTCOrdemServico
Local aAreaDCF := DCF->(GetArea())
Local cOrigem  := ""

	dbSelectArea("DCF")
	DCF->(dbSetOrder(9)) //DCF_FILIAL+DCF_ID

	//Procura a origem do documento originador da DCF
	If DCF->(DbSeek(xFilial("DCF")+Self:cIdOrigem))
		cOrigem := 	DCF->DCF_ORIGEM
	EndIf

	RestArea(aAreaDCF)
Return cOrigem

METHOD ChkOrdReab() CLASS WMSDTCOrdemServico
Local lRet     := .T.
Local nI       := 0
Local nPos     := 0
Local cProduto := ""
Local aReabD12 := {}
	For nI := 1 To Len(Self:aLibD12)
		cProduto := AllTrim(Self:aLibD12[nI][6])
		//Deve adicionar no log apenas uma vez
		If (nPos := AScan(Self:aWmsReab, { |x| cProduto $ x[1] })) > 0
			If AScan(aReabD12, { |x| cProduto $ x[1] }) == 0
				AAdd(aReabD12,{Self:aWmsReab[nPos][1]}) // Reabastecimentos pendentes que precisam ser executados para o produto
			EndIf
		EndIf
	Next nI
	Self:aWmsReab := aReabD12
Return lRet
//--------------------------------------------------
/*/{Protheus.doc} NextSeqPri
Proxima sequencia de prioridade
@author logistica
@since 23/12/2014
@version 1.0
@param cParametro, character, (Parametro)
@param cField, character, (Campos)
/*/
//--------------------------------------------------
METHOD CanEstReab() CLASS WMSDTCOrdemServico
Local oEstEnder   := WMSDTCEstoqueEndereco():New()
Local aD12_QTDMOV := TamSx3("D12_QTDMOV")
Local lRet        := .T.
Local cQuery      := ""
Local cAliasD12   := ""
	If Self:cStServ == '3'
		cQuery := "SELECT DISTINCT D12_LOCDES,"
		cQuery +=       " D12_ENDDES,"
		cQuery +=       " D12_PRODUT,"
		cQuery +=       " D12_PRDORI,"
		cQuery +=       " D12_LOTECT,"
		cQuery +=       " D12_NUMLOT,"
		cQuery +=       " D12_NUMSER,"
		If Self:lHasUniDes
			cQuery +=    " D12_UNIDES,"
		EndIf
		cQuery +=       " D12_QTDMOV"
		cQuery +=  " FROM "+RetSqlName("D12")+" D12"
		cQuery += " WHERE D12.D12_FILIAL = '"+xFilial("D12")+"'"
		cQuery +=   " AND D12.D12_IDDCF = '"+Self:cIdDCF+"'"
		cQuery +=   " AND D12.D12_STATUS IN ('2','3','4')"
		cQuery +=   " AND D12.D12_ATUEST = '1'"
		cQuery +=   " AND D12.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasD12 := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasD12,.F.,.T.)
		TCSetField(cAliasD12,'D12_QTDMOV','N',aD12_QTDMOV[1],aD12_QTDMOV[2])
		While (cAliasD12)->(!EoF())
			oEstEnder:ClearData()
			oEstEnder:oEndereco:SetArmazem((cAliasD12)->D12_LOCDES)
			oEstEnder:oEndereco:SetEnder((cAliasD12)->D12_ENDDES)
			oEstEnder:oProdLote:SetArmazem((cAliasD12)->D12_LOCDES)
			oEstEnder:oProdLote:SetPrdOri((cAliasD12)->D12_PRDORI)
			oEstEnder:oProdLote:SetProduto((cAliasD12)->D12_PRODUT)
			oEstEnder:oProdLote:SetNumSer((cAliasD12)->D12_NUMSER)
			oEstEnder:oProdLote:SetLoteCtl((cAliasD12)->D12_LOTECT)
			oEstEnder:oProdLote:SetNumLote((cAliasD12)->D12_NUMLOT)
			If Self:lHasUniDes
				oEstEnder:SetIdUnit((cAliasD12)->D12_UNIDES)
			EndIf
			If oEstEnder:LoadData()
				If QtdComp(oEstEnder:GetQtdEst() + oEstEnder:GetQtdEpr() - (cAliasD12)->D12_QTDMOV) < QtdComp(oEstEnder:GetQtdSpr())
					Self:cErro := STR0023 // Reabastecimento não pode ser estornado, saldo comprometido!
					lRet       := .F.
				EndIf
			EndIf
			(cAliasD12)->(dbSkip())
		EndDo
		(cAliasD12)->(dbCloseArea())
	EndIf
Return lRet
//--------------------------------------------------
/*/{Protheus.doc} ChkQtdRes
Verifica quantidade reservada SB2
@author logistica
@since 15/02/2016
@version 1.0
@param cParametro, character, (Parametro)
@param cField, character, (Campos)
/*/
//--------------------------------------------------
METHOD ChkQtdRes() CLASS WMSDTCOrdemServico
Local cQuery   := ""
Local cAliasSB2:= ""
Local aB2_QATU := TamSx3("B2_QATU")
Local lRet     := .T.
	cQuery := " SELECT SB2.B2_QATU - ((SB2.B2_QACLASS - CASE WHEN D0G.D0G_QTDORI IS NULL THEN 0 ELSE D0G.D0G_QTDORI END) + SB2.B2_RESERVA + SB2.B2_QEMP + SB2.B2_QEMPSA + SB2.B2_QTNP + SB2.B2_QEMPN + SB2.B2_QNPT) B2_QTDEST,"
	cQuery +=        " SB2.B2_QATU,"
	cQuery +=        " SB2.B2_QACLASS,"
	cQuery +=        " SB2.B2_RESERVA,"
	cQuery +=        " SB2.B2_QEMP,"
	cQuery +=        " SB2.B2_QEMPSA,"
	cQuery +=        " SB2.B2_QTNP,"
	cQuery +=        " SB2.B2_QEMPN,"
	cQuery +=        " SB2.B2_QNPT"
	cQuery +=   " FROM "+RetSqlName('SB2') + " SB2"
	cQuery +=   " LEFT JOIN "+RetSqlName('D0G') + " D0G"
	cQuery +=     " ON D0G.D0G_FILIAL = '"+xFilial('D0G')+"'"
	cQuery +=    " AND D0G.D0G_PRODUT = SB2.B2_COD"
	cQuery +=    " AND D0G.D0G_LOCAL = SB2.B2_LOCAL"
	cQuery +=    " AND D0G.D0G_IDDCF = '"+Self:GetIdDCF()+"'"
	cQuery +=    " AND D0G.D_E_L_E_T_= ' '"
	cQuery +=  " WHERE SB2.B2_FILIAL = '"+xFilial('SB2')+"'"
	cQuery +=    " AND SB2.B2_COD = '"+Self:oProdLote:GetPrdOri()+"'"
	cQuery +=    " AND SB2.B2_LOCAL = '"+Self:oOrdEndOri:GetArmazem()+"'"
	cQuery +=    " AND SB2.D_E_L_E_T_= ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasSB2 := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasSB2,.F.,.T.)
	TCSetField(cAliasSB2,'B2_QTDEST','N',aB2_QATU[1],aB2_QATU[2])
	If (cAliasSB2)->(!EoF())
		If QtdComp((cAliasSB2)->B2_QTDEST) < QtdComp(Self:nQuant)
			Self:cErro := WmsFmtMsg(STR0024; // Não é possível estornar o documento [VAR01]. O armazém/produto [VAR02]/[VAR03] possui:
									+CRLF+STR0025; // Quantidade atual de [VAR04]
									+CRLF+STR0026; // Quantidade reservada de [VAR05]
									+CRLF+STR0027; // Quantidade a classificar de [VAR06]
									+CRLF+STR0028; // Quantidade empenhada de [VAR07]
									+CRLF+STR0029; // Quantidade prevista SA de [VAR08]
									+CRLF+STR0030; // Quantidade terc. em nosso poder de [VAR09]
									+CRLF+STR0031; // Quantidade empenhada para NFs de [VAR10]
									+CRLF+STR0032,{{"[VAR01]",Self:cDocumento},; // Quantidade nosso em poder terc. de [VAR11]
													{"[VAR02]",Self:oProdLote:GetPrdOri()},;
													{"[VAR03]",Self:oOrdEndOri:GetArmazem()},;
													{"[VAR04]",Str((cAliasSB2)->B2_QATU)},;
													{"[VAR05]",Str((cAliasSB2)->B2_RESERVA)},;
													{"[VAR06]",Str((cAliasSB2)->B2_QACLASS)},;
													{"[VAR07]",Str((cAliasSB2)->B2_QEMP)},;
													{"[VAR08]",Str((cAliasSB2)->B2_QEMPSA)},;
													{"[VAR09]",Str((cAliasSB2)->B2_QTNP)},;
													{"[VAR10]",Str((cAliasSB2)->B2_QEMPN)},;
													{"[VAR11]",Str((cAliasSB2)->B2_QNPT)}})
			lRet := .F.
		EndIf
	EndIf
	(cAliasSB2)->(dbCloseArea())
Return lRet

//-----------------------------------------------
/*/{Protheus.doc} IsMovUnit
Verifica se é um movimento unitizado
@author  Guilherme A. Metzger
@since   28/04/2017
@version 1.0
/*/
//-----------------------------------------------
METHOD IsMovUnit() CLASS WMSDTCOrdemServico
Return (Empty(Self:oProdLote:GetProduto()) .And. (!Empty(Self:cIdUnitiz) .Or. !Empty(Self:cUniDes)))

//-----------------------------------------------
/*/{Protheus.doc} ChkMovEst
Verifica se é um movimento unitizado
@author  Guilherme A. Metzger
@since   28/04/2017
@version 1.0
/*/
//-----------------------------------------------
METHOD ChkMovEst(lEndOri) CLASS WMSDTCOrdemServico
Local lRet      := .F.
Local cEndereco := ""

Default lEndOri := .T.
	// Valida se o endereço e o lote estão informados para realizar a movimentação
	If lEndOri
		cEndereco := Self:oOrdEndOri:GetEnder()
	Else
		cEndereco := Self:oOrdEndDes:GetEnder()
	EndIf

	If !Empty(cEndereco) .And. (!Self:oProdLote:HasRastro() .Or. (Self:oProdLote:HasRastro() .And. !Empty(Self:oProdLote:GetLoteCtl())))
		lRet := .T.
	EndIf
Return lRet
//-----------------------------------------------
/*/{Protheus.doc} MovSD3Prod
Realiza movimentações SB3 para montagem ou desmontagem de produtos
@author  Squad WMS
@since   27/10/2017
@version 1.0
/*/
//-----------------------------------------------
METHOD MovSD3Estr(lMovAut,lMontagem) CLASS WMSDTCOrdemServico
Local lRet      := .T.
Local aArrSD3   := {}
Local aAreaSD3  := SD3->(GetArea())
Local cQuery    := ""
Local cAliasLot := ""
Local cAliasD0B := ""
Local cAliasD0C := ""
Local cAliasD11 := ""
Local cAliasCtrl:= ""
Local cNumOp    := ""
Local cPrdPai   := ""
Local cLocal    := ""
Local cNumSeq   := ProxNum()
Local oEstEnder := WMSDTCEstoqueEndereco():New()
Local nRateio   := 0
Local nQuant    := 0
Local nRecno    := 0
Local nCusPar   := 0
Local nCusto1   := 0

Default lMontagem := .T.
Default lMovAut := .F.

Private nHdlPrv
Private lExecWms := .T.
	//Realiza loop por lote
	//para criar uma ordem de produção e uma entrada SD3 (numseq) para cada lote
	cQuery := " SELECT D0B.D0B_LOTECT,"
	cQuery +=        " D0B.D0B_NUMLOT"
	cQuery +=   " FROM "+RetSqlName("D0B")+" D0B"
	cQuery +=  " WHERE D0B.D0B_FILIAL = '"+xFilial("D0B")+"'"
	cQuery +=    " AND D0B.D0B_DOC = '"+Self:GetDocto()+"'"
	cQuery +=    " AND D0B.D0B_TIPMOV = '"+Iif(lMontagem,"2","1")+"'"
	cQuery +=    " AND D0B.D_E_L_E_T_ = ' '"
	cQuery +=  " GROUP BY D0B.D0B_LOTECT,"
	cQuery +=           " D0B.D0B_NUMLOT"
	cAliasLot := GetNextAlias()
	dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasLot,.F.,.T.)
	Do While (cAliasLot)->(!Eof()) .And. lRet

		// Inicializa array
		aArrSD3 := {}
		
		// Produtos Origem
		cQuery := " SELECT D0B.D0B_LOCAL,"
		cQuery +=        " D0B.D0B_PRDORI,"
		cQuery +=        " D0B.D0B_LOTECT,"
		cQuery +=        " D0B.D0B_NUMLOT,"
		cQuery +=        " SUM(D0B.D0B_QUANT / CASE WHEN D11.D11_QTMULT IS NULL THEN 1 ELSE D11.D11_QTMULT END ) D0B_QUANT"
		cQuery +=   " FROM "+RetSqlName("D0B")+" D0B"
		cQuery +=   " LEFT JOIN "+RetSqlName("D11")+" D11"
		cQuery +=     " ON D11.D11_FILIAL = '"+xFilial("D11")+"'"
		cQuery +=    " AND D11.D11_PRDORI = D0B.D0B_PRDORI"
		cQuery +=    " AND D11.D11_PRDCMP = D0B.D0B_PRODUT"
		cQuery +=    " AND D11.D_E_L_E_T_ = ' '"
		cQuery +=  " WHERE D0B.D0B_FILIAL = '"+xFilial("D0B")+"'"
		cQuery +=    " AND D0B.D0B_DOC = '"+Self:GetDocto()+"'"
		cQuery +=    " AND D0B.D0B_TIPMOV = '"+Iif(lMontagem,"2","1")+"'"
		cQuery +=    " AND D0B.D0B_PRODUT = '"+Self:oProdLote:GetProduto()+"'"
		cQuery +=    " AND D0B.D0B_LOTECT = '"+(cAliasLot)->D0B_LOTECT+"'"
		cQuery +=    " AND D0B.D0B_NUMLOT = '"+(cAliasLot)->D0B_NUMLOT+"'"
		cQuery +=    " AND D0B.D_E_L_E_T_ = ' '"
		cQuery +=  " GROUP BY D0B.D0B_LOCAL,"
		cQuery +=           " D0B.D0B_PRDORI,"
		cQuery +=           " D0B.D0B_LOTECT,"
		cQuery +=           " D0B.D0B_NUMLOT"
		cQuery +=  " ORDER BY D0B.D0B_LOTECT,"
		cQuery +=           " D0B.D0B_NUMLOT"
		cQuery := ChangeQuery(cQuery)
		cAliasD0B := GetNextAlias()
		dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasD0B,.F.,.T.)
		Do While (cAliasD0B)->(!Eof()) .And. lRet
			If !lMontagem
				// Adiocina os produtos destino
				aAdd(aArrSD3, {"999",;                   // Tipo movimentação
								Self:GetDocto(),;         // Documento
								(cAliasD0B)->D0B_PRDORI,; // Produto
								(cAliasD0B)->D0B_LOTECT,; // Lote
								(cAliasD0B)->D0B_NUMLOT,; // Sub-Lote
								(cAliasD0B)->D0B_QUANT,;  // Quantidade
								100,;                     // % Rateio
								(cAliasD0B)->D0B_LOCAL,;  // Armazém
								"",;                      // Endereço
								"",;                      // Id DCF
								"RE7",;                   // Cf
								"E0",;                    // Chave
								Self:GetServico(),;       // Serviço
								Self:GetStServ(),;        // Status Servico
								Self:GetRegra()})         // Regra
			Else
				cLocal  := (cAliasD0B)->D0B_LOCAL
				cPrdPai := (cAliasD0B)->D0B_PRDORI
				nQuant  := (cAliasD0B)->D0B_QUANT
				cNumOp  := oEstEnder:WmsGeraOP(cLocal, cPrdPai, nQuant)
				If Empty(cNumOp)
					lRet := .F.
				EndIf
			EndIf
			(cAliasD0B)->(dbSkip())
		EndDo
		(cAliasD0B)->(dbCloseArea())

		// Produtos destino
		If lRet
			cQuery := " SELECT D0B.D0B_LOCAL,"
			cQuery +=        " D0B.D0B_PRDORI,"
			cQuery +=        " D0B.D0B_PRODUT,"
			cQuery +=        " D0B.D0B_LOTECT,"
			cQuery +=        " D0B.D0B_NUMLOT,"
			cQuery +=        " SUM(D0B.D0B_QUANT / CASE WHEN D11.D11_QTMULT IS NULL THEN 1 ELSE D11.D11_QTMULT END ) D0B_QUANT"
			cQuery +=   " FROM "+RetSqlName("D0B")+" D0B"
			cQuery +=   " LEFT JOIN "+RetSqlName("D11")+" D11"
			cQuery +=     " ON D11.D11_FILIAL = '"+xFilial("D11")+"'"
			cQuery +=    " AND D11.D11_PRDORI = D0B.D0B_PRDORI"
			cQuery +=    " AND D11.D11_PRDCMP = D0B.D0B_PRODUT"
			cQuery +=    " AND D11.D_E_L_E_T_ = ' '"
			cQuery +=  " WHERE D0B.D0B_FILIAL = '"+xFilial("D0B")+"'"
			cQuery +=    " AND D0B.D0B_DOC = '"+Self:GetDocto()+"'"
			cQuery +=    " AND D0B.D0B_LOTECT = '"+(cAliasLot)->D0B_LOTECT+"'"
			cQuery +=    " AND D0B.D0B_NUMLOT = '"+(cAliasLot)->D0B_NUMLOT+"'"
			cQuery +=    " AND D0B.D0B_TIPMOV = '"+Iif(lMontagem,"1","2")+"'"
			cQuery +=    " AND D0B.D_E_L_E_T_ = ' '"
			cQuery +=  " GROUP BY D0B.D0B_LOCAL,"
			cQuery +=           " D0B.D0B_PRDORI,"
			cQuery +=           " D0B.D0B_PRODUT,"
			cQuery +=           " D0B.D0B_LOTECT,"
			cQuery +=           " D0B.D0B_NUMLOT"
			cQuery +=  " ORDER BY D0B.D0B_LOTECT,"
			cQuery +=           " D0B.D0B_NUMLOT"
			cQuery := ChangeQuery(cQuery)
			cAliasD0B := GetNextAlias()
			dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasD0B,.F.,.T.)
			Do While (cAliasD0B)->(!Eof())
				nRateio := 0
				// Na montagem/desmontagem de estruturas o percentual de rateio é cadastrado nos componentes (D11)
				cQuery :=  "SELECT CASE WHEN D11.D11_RATEIO IS NULL THEN 100 ELSE D11.D11_RATEIO END D11_RATEIO"
				cQuery +=   " FROM "+RetSqlName("D11")+" D11"
				cQuery +=  " WHERE D11.D11_FILIAL = '"+xFilial("D11")+"'"
				cQuery +=    " AND D11.D11_PRDORI = '"+D0A->D0A_PRODUT+"'"
				cQuery +=    " AND D11.D11_PRDCMP = '"+(cAliasD0B)->D0B_PRODUT+"'"
				cQuery +=    " AND D11.D_E_L_E_T_ = ' '"
				cQuery := ChangeQuery(cQuery)
				cAliasD11 := GetNextAlias()
				dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasD11,.F.,.T.)
				If (cAliasD11)->(!Eof())
					nRateio := (cAliasD11)->D11_RATEIO
				EndIf
				(cAliasD11)->(dbCloseArea())
				If !lMontagem
					// Adiocina os produtos destino
					aAdd(aArrSD3, {"499",;                                               // Tipo movimentação
									Self:GetDocto(),;                                     // Documento
									(cAliasD0B)->D0B_PRODUT,;                             // Produto
									(cAliasD0B)->D0B_LOTECT,;                             // Lote
									(cAliasD0B)->D0B_NUMLOT,;                             // Sub-Lote
									(cAliasD0B)->D0B_QUANT,;                              // Quantidade
									nRateio,;                                             // % Rateio
									(cAliasD0B)->D0B_LOCAL,;                              // Armazém
									"",;                                                  // Endereço
									"",;                                                  // Id DCF
									"DE7",;                                               // Cf
									"E9",;                                                // Chave
									Self:GetServico(),;                                   // Serviço
									Self:GetStServ(),;                                    // Status Servico
									Self:GetRegra()})                                     // Regra
				Else
					A340SD3Prt((cAliasD0B)->D0B_PRODUT,;           // Produto
								"",;                               // Endereço
								"999",;                            // Tipo de movimentação
								(cAliasD0B)->D0B_QUANT,;           // Quantidade
								Self:GetDocto(),;                  // Documento
								.F./*lInventario*/,;               // Indica se é um processo de inventário
								{;                                 // aParam - Informações do SD3
								(cAliasD0B)->D0B_LOCAL,;           // [01] cLocal
								dDataBase,;                        // [02] dData
								(cAliasD0B)->D0B_NUMLOT,;          // [03] cNumLote
								(cAliasD0B)->D0B_LOTECT,;          // [04] cLoteCtl
								/*Self:oMovPrdLot:GetDtValid()*/,; // [05] dDtValid
								0,;                                // [06] nQtSegUm
								/*Self:oMovPrdLot:GetNumSer()*/,;  // [07] cNumSerie
								/*Self:oMovEndDes:GetEstFis()*/,;  // [08] cEstFis
								"",;                               // [09] cContagem
								Self:GetDocto(),;                  // [10] cNumDoc
								/*Self:oOrdServ:GetSerie()*/,;     // [11] cSerie
								/*Self:oOrdServ:GetCliFor()*/,;    // [12] cFornece
								/*Self:oOrdServ:GetLoja()*/,;      // [13] cLoja
								dDataBase,;                        // [14] mv_par01 -> D3_EMISSAO
								Posicione("SB1",1,xFilial("SB1")+(cAliasD0B)->D0B_PRODUT,"B1_CC"),; // [15] mv_par02 -> D3_CC  /*Self:oOrdServ:oProdLote:oProduto:oProdGen:GetCC()*/
								2;                                 // [16] mv_par14 -> 1=Pega os custos medios finais;2=Pega os custos medios atuais
								},;
								{dDataBase},;
								cNumSeq,;
								.F./*lDesmontagem*/,;
								cNumOP,;
								@nCusPar)
					// Soma o custo das partes para formar o custo do pai
					nCusto1 += nCusPar
				EndIf
				(cAliasD0B)->(dbSkip())
			EndDo
			(cAliasD0B)->(dbCloseArea())
		EndIf

		If lRet
			If lMontagem
				// Realiza o apontamento para gerar saldo do pai
				If !oEstEnder:WmsApontOp(cNumOP,cPrdPai,nQuant,Self:GetDocto(),@nRecno,cLocal,(cAliasLot)->D0B_LOTECT,(cAliasLot)->D0B_NUMLOT,Self:GetServico())
					lRet :=  .F.
				Else
					// Altera a movimentação SD3 para gravar o custo da produção do pai com relação aos filhos
					SD3->(dbGoto(nRecno))
					RecLock("SD3",.F.)
					SD3->D3_CUSTO1 := nCusto1
					SD3->(MsUnlock())
				EndIf
			Else
				// Gera movimento interno
				AtuDesSD3(aArrSD3,D0A->D0A_OPERAC)
			EndIf
		EndIf
		(cAliasLot)->(dbSkip())
	EndDo
	(cAliasLot)->(dbCloseArea())
	RestArea(aAreaSD3)
Return lRet
//-----------------------------------------------
/*/{Protheus.doc} MovSD3Prod
Realiza movimentações SB3 para montagem ou desmontagem de produtos
@author  Squad WMS
@since   27/10/2017
@version 1.0
/*/
//-----------------------------------------------
METHOD MovSD3Prod(lMovAut,lMontagem) CLASS WMSDTCOrdemServico
Local lRet      := .T.
Local aArrSD3   := {}
Local aAreaSD3  := SD3->(GetArea())
Local cQuery    := ""
Local cAliasLot := ""
Local cAliasD0B := ""
Local cAliasD0C := ""
Local cNumOp    := ""
Local cPrdPai   := ""
Local cLocal    := ""
Local cLote     := ""
Local cNumLote  := ""
Local cNumSeq   := ProxNum()
Local oEstEnder := WMSDTCEstoqueEndereco():New()
Local nRateio   := 0
Local nQuant    := 0
Local nRecno    := 0
Local nCusPar   := 0
Local nCusto1   := 0

Default lMovAut   := .F.
Default lMontagem := .T.

Private nHdlPrv
Private lExecWms := .T.

	// Inicializa array
	aArrSD3 := {}
	// Produtos Origem
	cQuery := " SELECT D0B.D0B_LOCAL,"
	cQuery +=        " D0B.D0B_PRDORI,"
	cQuery +=        " D0B.D0B_LOTECT,"
	cQuery +=        " D0B.D0B_NUMLOT,"
	cQuery +=        " SUM(D0B.D0B_QUANT) D0B_QUANT"
	cQuery +=   " FROM "+RetSqlName("D0B")+" D0B"
	cQuery +=  " WHERE D0B.D0B_FILIAL = '"+xFilial("D0B")+"'"
	cQuery +=    " AND D0B.D0B_DOC    = '"+Self:GetDocto()+"'"
	cQuery +=    " AND D0B.D0B_TIPMOV = '"+Iif(lMontagem,"2","1")+"'"
	cQuery +=    " AND D0B.D_E_L_E_T_ = ' '"
	cQuery +=  " GROUP BY D0B.D0B_LOCAL,"
	cQuery +=           " D0B.D0B_PRDORI,"
	cQuery +=           " D0B.D0B_LOTECT,"
	cQuery +=           " D0B.D0B_NUMLOT"
	cQuery +=  " ORDER BY D0B.D0B_LOTECT,"
	cQuery +=           " D0B.D0B_NUMLOT"
	cQuery := ChangeQuery(cQuery)
	cAliasD0B := GetNextAlias()
	dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasD0B,.F.,.T.)
	Do While (cAliasD0B)->(!Eof()) .And. lRet
		If !lMontagem
			// Adiocina os produtos destino
			aAdd(aArrSD3, {"999",;    // Tipo movimentação
							Self:GetDocto(),;         // Documento
							(cAliasD0B)->D0B_PRDORI,; // Produto
							(cAliasD0B)->D0B_LOTECT,; // Lote
							(cAliasD0B)->D0B_NUMLOT,; // Sub-Lote
							(cAliasD0B)->D0B_QUANT,;  // Quantidade
							100,;                     // % Rateio
							(cAliasD0B)->D0B_LOCAL,;  // Armazém
							"",;                      // Endereço
							"",;                      // Id DCF
							"RE7",;                   // Cf
							"E0",;                    // Chave
							Self:GetServico(),;       // Serviço
							Self:GetStServ(),;        // Status Servico
							Self:GetRegra()})         // Regra
		Else
			cLocal  := (cAliasD0B)->D0B_LOCAL
			cPrdPai := (cAliasD0B)->D0B_PRDORI
			nQuant  := (cAliasD0B)->D0B_QUANT
			cNumOp  := oEstEnder:WmsGeraOP(cLocal, cPrdPai, nQuant)
			cLote   := (cAliasD0B)->D0B_LOTECT
			cNumLote:= (cAliasD0B)->D0B_NUMLOT
			
			If Empty(cNumOp)
				lRet := .F.
			EndIf
		EndIf
		(cAliasD0B)->(dbSkip())
	EndDo
	(cAliasD0B)->(dbCloseArea())
	If lRet
		// Produtos destino
		cQuery := " SELECT D0B.D0B_LOCAL,"
		cQuery +=        " D0B.D0B_PRDORI,"
		cQuery +=        " D0B.D0B_PRODUT,"
		cQuery +=        " D0B.D0B_LOTECT,"
		cQuery +=        " D0B.D0B_NUMLOT,"
		cQuery +=        " SUM(D0B.D0B_QUANT) D0B_QUANT"
		cQuery +=   " FROM "+RetSqlName("D0B")+" D0B"
		cQuery +=  " WHERE D0B.D0B_FILIAL = '"+xFilial("D0B")+"'"
		cQuery +=    " AND D0B.D0B_DOC    = '"+Self:GetDocto()+"'"
		cQuery +=    " AND D0B.D0B_TIPMOV = '"+Iif(lMontagem,"1","2")+"'"
		cQuery +=    " AND D0B.D_E_L_E_T_ = ' '"
		cQuery +=  " GROUP BY D0B.D0B_LOCAL,"
		cQuery +=           " D0B.D0B_PRDORI,"
		cQuery +=           " D0B.D0B_PRODUT,"
		cQuery +=           " D0B.D0B_LOTECT,"
		cQuery +=           " D0B.D0B_NUMLOT"
		cQuery +=  " ORDER BY D0B.D0B_LOTECT,"
		cQuery +=           " D0B.D0B_NUMLOT"
		cQuery := ChangeQuery(cQuery)
		cAliasD0B := GetNextAlias()
		dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasD0B,.F.,.T.)
		Do While (cAliasD0B)->(!Eof())
			// Busca rateio do produto
			nRateio := 0
			// Na montagem/desmontagem de produto o percentual de rateio é informado (D0C)
			cQuery :=   " SELECT D0C.D0C_RATEIO"
			cQuery +=     " FROM "+RetSqlName("D0C")+" D0C"
			cQuery +=    " WHERE D0C.D0C_FILIAL = '"+xFilial("D0C")+"'"
			cQuery +=      " AND D0C.D0C_DOC = '"+Self:GetDocto()+"'"
			cQuery +=      " AND D0C.D0C_PRODUT = '"+(cAliasD0B)->D0B_PRDORI+"'"
			// Na desmontagem de produto deverá considerar o percentual de rateio por produto/lote e sublote
			// Na montagem será considerado o percentual de rateio de 100%
			cQuery +=    " AND D0C.D0C_LOTECT= '"+(cAliasD0B)->D0B_LOTECT+"'"
			cQuery +=    " AND D0C.D0C_NUMLOT= '"+(cAliasD0B)->D0B_NUMLOT+"'"
			cQuery +=    " AND D0C.D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			cAliasD0C := GetNextAlias()
			dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasD0C,.F.,.T.)
			If (cAliasD0C)->(!Eof())
				nRateio := (cAliasD0C)->D0C_RATEIO
			EndIf
			(cAliasD0C)->(dbCloseArea())
			If !lMontagem
					// Adiocina os produtos destino
					aAdd(aArrSD3, {"499",;                   // Tipo movimentação
									Self:GetDocto(),;         // Documento
									(cAliasD0B)->D0B_PRODUT,; // Produto
									(cAliasD0B)->D0B_LOTECT,; // Lote
									(cAliasD0B)->D0B_NUMLOT,; // Sub-Lote
									(cAliasD0B)->D0B_QUANT,;  // Quantidade
									nRateio,;                 // % Rateio
									(cAliasD0B)->D0B_LOCAL,;  // Armazém
									"",;                      // Endereço
									"",;                      // Id DCF
									"DE7",;                   // Cf
									"E9",;                    // Chave
									Self:GetServico(),;       // Serviço
									Self:GetStServ(),;        // Status Servico
									Self:GetRegra()})         // Regra
			Else
				A340SD3Prt((cAliasD0B)->D0B_PRODUT,;           // Produto
							"",;                               // Endereço
							"999",;                            // Tipo de movimentação
							(cAliasD0B)->D0B_QUANT,;           // Quantidade
							Self:GetDocto(),;                  // Documento
							.F./*lInventario*/,;               // Indica se é um processo de inventário
							{;                                 // aParam - Informações do SD3
							(cAliasD0B)->D0B_LOCAL,;           // [01] cLocal
							dDataBase,;                        // [02] dData
							(cAliasD0B)->D0B_NUMLOT,;          // [03] cNumLote
							(cAliasD0B)->D0B_LOTECT,;          // [04] cLoteCtl
							/*Self:oMovPrdLot:GetDtValid()*/,; // [05] dDtValid
							0,;                                // [06] nQtSegUm
							/*Self:oMovPrdLot:GetNumSer()*/,;  // [07] cNumSerie
							/*Self:oMovEndDes:GetEstFis()*/,;  // [08] cEstFis
							"",;                               // [09] cContagem
							Self:GetDocto(),;                  // [10] cNumDoc
							/*Self:oOrdServ:GetSerie()*/,;     // [11] cSerie
							/*Self:oOrdServ:GetCliFor()*/,;    // [12] cFornece
							/*Self:oOrdServ:GetLoja()*/,;      // [13] cLoja
							dDataBase,;                        // [14] mv_par01 -> D3_EMISSAO
							Posicione("SB1",1,xFilial("SB1")+(cAliasD0B)->D0B_PRODUT,"B1_CC"),; // [15] mv_par02 -> D3_CC  /*Self:oOrdServ:oProdLote:oProduto:oProdGen:GetCC()*/
							2;                                 // [16] mv_par14 -> 1=Pega os custos medios finais;2=Pega os custos medios atuais
							},;
							{dDataBase},;
							cNumSeq,;
							.F./*lDesmontagem*/,;
							cNumOP,;
							@nCusPar)
				// Soma o custo das partes para formar o custo do pai
				nCusto1 += nCusPar
			EndIf
			(cAliasD0B)->(dbSkip())
		EndDo
		(cAliasD0B)->(dbCloseArea())
	EndIf
	If lRet
		If lMontagem
			// Realiza o apontamento para gerar saldo do pai
			If !oEstEnder:WmsApontOp(cNumOP,cPrdPai,nQuant,Self:GetDocto(),@nRecno,cLocal,cLote,cNumLote,Self:GetServico())
				lRet := .F.
			Else
				// Altera a movimentação SD3 para gravar o custo da produção do pai com relação aos filhos
				SD3->(dbGoto(nRecno))
				RecLock("SD3",.F.)
				SD3->D3_CUSTO1 := nCusto1
				SD3->(MsUnlock())
			EndIf
		Else
			// Gera movimento interno
			AtuDesSD3(aArrSD3,D0A->D0A_OPERAC)
		EndIf
	EndIf
	RestArea(aAreaSD3)
Return lRet
//-----------------------------------------------
/*/{Protheus.doc} MovSD3Lote
Realiza movimentações SB3 para troca de lotes.
@author  Squad WMS
@since   27/10/2017
@version 1.0
/*/
//-----------------------------------------------
METHOD MovSD3Lote(lMovAut) CLASS WMSDTCOrdemServico
Local lRet      := .T.
Local aArrSD3   := {}
Local aAreaSD3  := SD3->(GetArea())
Local cQuery    := ""
Local cAliasD0B := ""
Local cAliasCtrl:= ""
Local oEstEnder := WMSDTCEstoqueEndereco():New()

Default lMovAut := .F.

Private nHdlPrv
Private lExecWms := .T.

	//Realiza loop por controle do processo
	//para amarrar entradas e saídas SD3 conforme o lote que está sendo trocado
	cQuery := " SELECT D0B.D0B_CTRL"
	cQuery +=   " FROM "+RetSqlName("D0B")+" D0B"
	cQuery +=  " WHERE D0B.D0B_FILIAL = '"+xFilial("D0B")+"'"
	cQuery +=    " AND D0B.D0B_DOC    = '"+Self:GetDocto()+"'"
	cQuery +=    " AND D0B.D_E_L_E_T_ = ' '"
	cQuery +=  " GROUP BY D0B.D0B_CTRL"
	cAliasCtrl := GetNextAlias()
	dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasCtrl,.F.,.T.)
	Do While (cAliasCtrl)->(!Eof())
		// Inicializa array
		aArrSD3 := {}
		// Produtos Origem
		cQuery := " SELECT D0B.D0B_LOCAL,"
		cQuery +=        " D0B.D0B_PRDORI,"
		cQuery +=        " D0B.D0B_LOTECT,"
		cQuery +=        " D0B.D0B_NUMLOT,"
		cQuery +=        " SUM(D0B.D0B_QUANT) D0B_QUANT"
		cQuery +=   " FROM "+RetSqlName("D0B")+" D0B"
		cQuery +=  " WHERE D0B.D0B_FILIAL = '"+xFilial("D0B")+"'"
		cQuery +=    " AND D0B.D0B_DOC    = '"+Self:GetDocto()+"'"
		cQuery +=    " AND D0B.D0B_CTRL   = '"+(cAliasCtrl)->D0B_CTRL+"'"
		cQuery +=    " AND D0B.D0B_TIPMOV = '1'"
		cQuery +=    " AND D0B.D_E_L_E_T_ = ' '"
		cQuery +=  " GROUP BY D0B.D0B_LOCAL,"
		cQuery +=           " D0B.D0B_PRDORI,"
		cQuery +=           " D0B.D0B_LOTECT,"
		cQuery +=           " D0B.D0B_NUMLOT"
		cQuery +=  " ORDER BY D0B.D0B_LOTECT,"
		cQuery +=           " D0B.D0B_NUMLOT"
		cQuery := ChangeQuery(cQuery)
		cAliasD0B := GetNextAlias()
		dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasD0B,.F.,.T.)
		Do While (cAliasD0B)->(!Eof())
			// Adiocina os produtos destino
			aAdd(aArrSD3, {"999",;                   // Tipo movimentação
							Self:GetDocto(),;         // Documento
							(cAliasD0B)->D0B_PRDORI,; // Produto
							(cAliasD0B)->D0B_LOTECT,; // Lote
							(cAliasD0B)->D0B_NUMLOT,; // Sub-Lote
							(cAliasD0B)->D0B_QUANT,;  // Quantidade
							100,;                     // % Rateio
							(cAliasD0B)->D0B_LOCAL,;  // Armazém
							"",;                      // Endereço
							"",;                      // Id DCF
							"RE7",;                   // Cf
							"E0",;                    // Chave
							Self:GetServico(),;       // Serviço
							Self:GetStServ(),;        // Status Servico
							Self:GetRegra()})         // Regra
			(cAliasD0B)->(dbSkip())
		EndDo
		(cAliasD0B)->(dbCloseArea())
		// Produtos destino
		cQuery := " SELECT D0B.D0B_LOCAL,"
		cQuery +=        " D0B.D0B_PRDORI,"
		cQuery +=        " D0B.D0B_PRODUT,"
		cQuery +=        " D0B.D0B_LOTECT,"
		cQuery +=        " D0B.D0B_NUMLOT,"
		cQuery +=        " D0B.D0B_ENDDES,"
		cQuery +=        " SUM(D0B.D0B_QUANT) D0B_QUANT"
		cQuery +=   " FROM "+RetSqlName("D0B")+" D0B"
		cQuery +=  " WHERE D0B.D0B_FILIAL = '"+xFilial("D0B")+"'"
		cQuery +=    " AND D0B.D0B_DOC    = '"+Self:GetDocto()+"'"
		cQuery +=    " AND D0B.D0B_CTRL   = '"+(cAliasCtrl)->D0B_CTRL+"'"
		cQuery +=    " AND D0B.D0B_TIPMOV = '2'"
		cQuery +=    " AND D0B.D_E_L_E_T_ = ' '"
		cQuery +=  " GROUP BY D0B.D0B_LOCAL,"
		cQuery +=           " D0B.D0B_PRDORI,"
		cQuery +=           " D0B.D0B_PRODUT,"
		cQuery +=           " D0B.D0B_LOTECT,"
		cQuery +=           " D0B.D0B_NUMLOT,"
		cQuery +=           " D0B.D0B_ENDDES"
		cQuery +=  " ORDER BY D0B.D0B_LOTECT,"
		cQuery +=           " D0B.D0B_NUMLOT"
		cQuery := ChangeQuery(cQuery)
		cAliasD0B := GetNextAlias()
		dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasD0B,.F.,.T.)
		Do While (cAliasD0B)->(!Eof())
			// Adiocina os produtos destino
			aAdd(aArrSD3, {"499",;    // Tipo movimentação
							Self:GetDocto(),;         // Documento
							(cAliasD0B)->D0B_PRODUT,; // Produto
							(cAliasD0B)->D0B_LOTECT,; // Lote
							(cAliasD0B)->D0B_NUMLOT,; // Sub-Lote
							(cAliasD0B)->D0B_QUANT,;  // Quantidade
							100,;                     // % Rateio
							(cAliasD0B)->D0B_LOCAL,;  // Armazém
							Iif(lMovAut,(cAliasD0B)->D0B_ENDDES,D0A->D0A_ENDER),; // Endereço
							"",;                      // Id DCF
							"DE7",;                   // Cf
							"E9",;                    // Chave
							Self:GetServico(),;       // Serviço
							Self:GetStServ(),;        // Status Servico
							Self:GetRegra()})         // Regra
			(cAliasD0B)->(dbSkip())
		EndDo
		(cAliasD0B)->(dbCloseArea())
		
		// Gera movimento interno
		AtuDesSD3(aArrSD3,D0A->D0A_OPERAC)
		
		(cAliasCtrl)->(DbSkip())
	EndDo
	(cAliasCtrl)->(DbCloseArea())
	RestArea(aAreaSD3)
Return lRet
#Include "Totvs.ch"
#Include "WMSDTCMovimentosServicoArmazem.ch"
#Define POSTAREFA 5
#Define POSQTDSOL 1
#Define POSQTDATD 2
#Define POSIDDCF  3
#Define POSSEQDCF 4
#Define POSQTDMOV 4
//---------------------------------------------
/*/{Protheus.doc} WMSCLS0027
Função para permitir que a classe seja visualizada
no inspetor de objetos
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0027()
Return Nil
//--------------------------------------------------
/*/{Protheus.doc} WMSDTCMovimentosServicoArmazem
Classe movimentos serviço armazem
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//--------------------------------------------------
CLASS WMSDTCMovimentosServicoArmazem FROM LongClassName
	DATA lHasUniDes // Utilizado para suavizar o campo D12_UNIDES
	DATA oOrdServ
	DATA oMovServic
	DATA oMovTarefa
	DATA oMovPrdLot
	DATA oMovEndOri
	DATA oMovEndDes
	DATA oMovSeqAbt
	DATA oEstEnder
	DATA cCodVolume
	DATA cIdVolume
	DATA cIdUnitiz
	DATA cTipUni
	DATA cUniDes
	DATA cStatus
	DATA dDtGeracao
	DATA cHrGeracao
	DATA cSeqPrior
	DATA cSeqCarga
	DATA cPriori
	DATA cRadioF
	DATA nQtdOrig
	DATA nQtdOrig2
	DATA nQtdMovto
	DATA nQtdMovto2
	DATA nQtdLida
	DATA nQtdLida2
	DATA nQuant     // Quantidade da ordem de serviço já atendida
	DATA dDtInicio
	DATA cHrInicio
	DATA dDtFinal
	DATA cHrFinal
	DATA cTempoMov
	DATA cRhFuncao
	DATA cRecHumano
	DATA cRecFisico
	DATA cLibPed
	DATA cAnomalia
	DATA cIdMovto
	DATA cMapaSep
	DATA cMapaCon
	DATA cMapaTipo
	DATA cRecConf
	DATA cRecEmbal
	DATA cEndConf
	DATA cOcorre
	DATA nQtdErro
	DATA cIdOpera
	DATA cMntVol
	DATA cDisSep
	DATA nSitSel
	DATA cOrdMov
	DATA cAtuEst
	DATA lEstAglu
	DATA aRecD12 AS ARRAY
	DATA aWmsReab AS ARRAY
	DATA aOrdAglu AS ARRAY
	DATA aPrdMont AS ARRAY
	DATA cArmInv
	DATA cEndInv
	DATA cAgluti
	DATA cNumOcor
	DATA cSolImpEti
	DATA cGrvPriAux
	DATA cPrioriAux
	DATA cRegraPrio
	DATA cPrAuto
	DATA cBxEsto
	DATA cLog
	DATA lUsuArm
	DATA nRecno
	DATA cErro
	// Mais campos necessário
	METHOD New() CONSTRUCTOR
	METHOD GoToD12(nRecno)
	METHOD LoadData(nIndex)
	METHOD LockD12()
	METHOD UnLockD12()
	// Method Set
	METHOD SetIdDCF(cIdDCF)
	METHOD SetSequen(cSequen)
	METHOD SetIdMovto(cIdMovto)
	METHOD SetIdOpera(cIdOpera)
	METHOD SetOrdAtiv(cOrdAtiv)
	METHOD SetQtdOri(nQtdOrig)
	METHOD SetQtdOri2(nQtdOrig2)
	METHOD SetQtdMov(nQtdMovto)
	METHOD SetQtdMov2(nQtdMovto2)
	METHOD SetQtdLid(nQtdLida)
	METHOD SetQtdLid2(nQtdLida2)
	METHOD SetQuant(nQuant)
	METHOD SetCodVol(cCodVolume)
	METHOD SetStatus(cStatus)
	METHOD SetMapTip(cMapaTipo)
	METHOD SetRhFunc(cRhFuncao)
	METHOD SetLibPed(cLibPed)
	METHOD SetPriori(cPriori)
	METHOD SetGrvPriA(cGrvPri)
	METHOD SetPrioriA(cPriori)
	METHOD SetSeqPrio(cSeqPrior)
	METHOD SetDataGer(dDtGeracao)
	METHOD SetHoraGer(cHrGeracao)
	METHOD SetDataIni(dDtInicio)
	METHOD SetHoraIni(cHrInicio)
	METHOD SetDataFim(dDtFinal)
	METHOD SetHoraFim(cHrFinal)
	METHOD SetRecHum(cRecHumano)
	METHOD SetRecFis(cRecFisico)
	METHOD SetAnomal(cAnomalia)
	METHOD SetRecCon(cRecConf)
	METHOD SetRecEmb(cRecEmbal)
	METHOD SetQtdErro(nQtdErro)
	METHOD SetMntVol(cMntVol)
	METHOD SetDisSep(cDisSep)
	METHOD SetAtuEst(cAtuEst)
	METHOD SetOcorre(cOcorre)
	METHOD SetIdUnit(cIdUnitiz)
	METHOD SetTipUni(cTipUni)
	METHOD SetUniDes(cUniDes)
	METHOD SetRecD12(aRecD12)
	METHOD SetWmsReab(aWmsReab)
	METHOD SetRadioF(cRadioF)
	METHOD SetArmInv(cArmInv)
	METHOD SetEndInv(cEndInv)
	METHOD SetAgluti(cAgluti)
	METHOD SetNumOcor(cNumOcor)
	METHOD SetSolImpE(cSolImpEti)
	METHOD SetOrdAglu(aOrdAglu)
	METHOD SetErro(cErro)
	METHOD SetPrAuto(cPrAuto)
	METHOD SetBxEsto(cBxEsto)
	METHOD SetLog(cLog)
	METHOD SetUsuArm(lUsuArm)
	// Method Get
	METHOD GetIdDCF()
	METHOD GetSequen()
	METHOD GetIdMovto()
	METHOD GetIdOpera()
	METHOD GetOrdAtiv()
	METHOD GetQtdMov()
	METHOD GetQtdMov2()
	METHOD GetQtdLid()
	METHOD GetQtdLid2()
	METHOD GetQuant()
	METHOD GetStatus()
	METHOD GetIdUnit()
	METHOD GetUniDes()
	METHOD GetTipUni()
	METHOD GetCodVol()
	METHOD GetPriori()
	METHOD GetRadioF()
	METHOD GetSeqPrio()
	METHOD GetDataGer()
	METHOD GetHoraGer()
	METHOD GetDataIni()
	METHOD GetHoraIni()
	METHOD GetDataFim()
	METHOD GetHoraFim()
	METHOD GetRecHum()
	METHOD GetRecFis()
	METHOD GetMapSep()
	METHOD GetMapaTip()
	METHOD GetLibPed()
	METHOD GetRhFunc()
	METHOD GetOcorre()
	METHOD GetRecCon()
	METHOD GetQtdErro()
	METHOD GetEndCon()
	METHOD GetMntVol()
	METHOD GetDisSep()
	METHOD GetAtuEst()
	METHOD GetArmInv()
	METHOD GetEndInv()
	METHOD GetAgluti()
	METHOD GetNumOcor()
	METHOD GetSolImpE()
	METHOD GetOrdAglu()
	METHOD GetPrAuto()
	METHOD GetBxEsto()
	// Method processos
	METHOD AssignD12()
	METHOD RecordD12()
	METHOD DeleteD12()
	METHOD UpdateD12(lMsUnLock)
	METHOD UpdExpedic(lConsExec)
	METHOD UpdQtdConf(cNovoLote,cNovoSubLote)
	METHOD UpdLote(cNovoLote,cNovoSbLot,cNovoUnit,cNovoEnder)
	METHOD UpdMovLote(cNovoLote,cNovoSbLot,cNovoUnit,cNovoEnder)
	METHOD UpdPedido(cNovoLote,cNovoSbLot)
	METHOD UpdMovExp()	
	METHOD MakeInput()
	METHOD MakeOutput()
	METHOD IsUltAtiv()
	METHOD IsPriAtiv()
	METHOD IsUpdEst()
	METHOD ChkMntVol(cTipoMnt)
	METHOD ChkDisSep()
	METHOD ChkConfExp()
	METHOD ChkSolImpE()
	METHOD ChkEndOri(lConsMov,lMovEst,lConsSld)
	METHOD ChkEndDes(lConsMov,lConsCap)
	METHOD ReverseAgl(oRelacMov)
	METHOD GetNextOri(cIdDCF,cIdMovto,cIdOpera)
	METHOD AtuNextOri(cIdDCF,cIdMovto,cIdOpera,cNextId)
	METHOD GetNextMov()
	METHOD AtuNextMov(cNextIdMov)
	METHOD VldEndInv()
	METHOD HasAgluAti()
	METHOD GetRecno()
	METHOD GetErro()
	METHOD Destroy()
	METHOD ChkEndD0F()
	METHOD IsMovUnit()
	METHOD DesNotUnit()
	METHOD OriNotUnit()
	METHOD HasSldUni()
	METHOD ChkEstPrd(lMovEst,lConsMov,cLocal,cProduto,cLoteCtl,cNumLote,nQuant)
	METHOD SldPrdLot(cLotectl,cNumlote)
ENDCLASS
//--------------------------------------------------
/*/{Protheus.doc} New
Método construtor
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//--------------------------------------------------
METHOD New() CLASS WMSDTCMovimentosServicoArmazem
	Self:lHasUniDes := WmsX312118("D12","D12_UNIDES")
	Self:oOrdServ   := WMSDTCOrdemServico():New()
	Self:oMovServic := Self:oOrdServ:oServico
	Self:oMovTarefa := WMSDTCTarefaAtividade():New()
	Self:oMovPrdLot := WMSDTCProdutoLote():New()
	Self:oMovEndOri := WMSDTCEndereco():New()
	Self:oMovEndDes := WMSDTCEndereco():New()
	Self:oMovSeqAbt := WMSDTCSequenciaAbastecimento():New()
	Self:oEstEnder  := WMSDTCEstoqueEndereco():New()
	// Inicializa campos
	Self:cIdMovto   := Space(TamSx3("D12_IDMOV")[1])
	Self:cIdOpera   := Space(TamSx3("D12_IDOPER")[1])
	Self:cStatus    := "-"
	Self:dDtGeracao := dDataBase
	Self:cHrGeracao := Time()
	Self:cSeqPrior  := Space(TamSx3("D12_SEQPRI")[1])
	Self:cPriori    := Space(TamSx3("D12_PRIORI")[1])
	Self:cRadioF    := Space(TamSx3("D12_RADIOF")[1])
	Self:cCodVolume := Space(TamSx3("D12_CODVOL")[1])
	Self:cIdVolume  := Space(TamSx3("D12_IDVOLU")[1])
	Self:cIdUnitiz  := Space(TamSx3("D12_IDUNIT")[1])
	Self:cTipUni    := Space(Iif(Self:lHasUniDes,TamSx3("D14_CODUNI")[1],6))
	Self:cUniDes    := Space(Iif(Self:lHasUniDes,TamSx3("D12_UNIDES")[1],6))
	Self:nQtdOrig   := 0
	Self:nQtdOrig2  := 0
	Self:nQtdMovto  := 0
	Self:nQtdMovto2 := 0
	Self:nQtdLida   := 0
	Self:nQtdLida2  := 0
	Self:nQuant     := 0
	Self:cSeqCarga  := Space(TamSx3("D12_SEQCAR")[1])
	Self:dDtInicio  := CtoD('  /  /  ')
	Self:cHrInicio  := Space(TamSx3("D12_DATINI")[1])
	Self:dDtFinal   := CtoD('  /  /  ')
	Self:cHrFinal   := Space(TamSx3("D12_HORFIM")[1])
	Self:cRhFuncao  := Space(TamSx3("D12_RHFUNC")[1])
	Self:cRecHumano := Space(TamSx3("D12_RECHUM")[1])
	Self:cRecFisico := Space(TamSx3("D12_RECFIS")[1])
	Self:cLibPed    := Space(TamSx3("D12_LIBPED")[1])
	Self:cAnomalia  := Space(TamSx3("D12_ANOMAL")[1])
	Self:cIdMovto   := Space(TamSx3("D12_IDMOV")[1])
	Self:cMapaSep   := Space(TamSx3("D12_MAPSEP")[1])
	Self:cMapaCon   := Space(TamSx3("D12_MAPCON")[1])
	Self:cMapaTipo  := "2" // Default - Caixa
	Self:cRecConf   := Space(TamSx3("D12_RECCON")[1])
	Self:cRecEmbal  := Space(TamSx3("D12_RECEMB")[1])
	Self:cEndConf   := Space(TamSx3("D12_ENDCON")[1])
	Self:cOcorre    := Space(TamSx3("D12_OCORRE")[1])
	Self:nQtdErro   := 0
	Self:cMntVol    := Space(TamSx3("D12_MNTVOL")[1])
	Self:cDisSep    := Space(TamSx3("D12_DISSEP")[1])
	Self:cIdOpera   := Space(TamSx3("D12_IDOPER")[1])
	Self:cSolImpEti := Space(TamSx3("D12_IMPETI")[1])
	Self:lUsuArm    := .F.
	Self:cOrdMov    := "1"
	Self:cAtuEst    := "2"
	Self:lEstAglu   := .F.
	Self:aRecD12    := {}
	Self:aOrdAglu   := {}
	Self:aPrdMont   := {}
	Self:cAgluti    := "2"
	Self:cNumOcor   := Space(TamSx3("D12_NUMERO")[1])
	Self:cRegraPrio := SuperGetMV('MV_WMSPRIO', .F., '' ) // Prioridade de convocacao no WMS.
	Self:cErro      := ""
	Self:nRecno     := 0
	Self:cPrAuto    := "2"
	Self:cBxEsto    := "2"
	Self:cLog       := "2"
Return

METHOD Destroy() CLASS WMSDTCMovimentosServicoArmazem
	FreeObj(Self)
Return Nil
//--------------------------------------------------
/*/{Protheus.doc} GoToD12
Método utilizado para posicionamentos dos dados
@author felipe.m
@since 23/12/2014
@version 1.0
@param nRecno, numérico, (Descrição do parâmetro)
/*/
//--------------------------------------------------
METHOD GoToD12(nRecno) CLASS WMSDTCMovimentosServicoArmazem
	Self:nRecno := nRecno
Return Self:LoadData(0)
//--------------------------------------------------
/*/{Protheus.doc} LockD12
Prende a tabela para alteração D12
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//--------------------------------------------------
METHOD LockD12() CLASS WMSDTCMovimentosServicoArmazem
Local lRet := .T.
	D12->(dbGoTo(Self:nRecno))
	If !D12->(SimpleLock())
		lRet := .F.
		Self:cErro := STR0002 // Lock não foi efetuado!
	Else
		Self:cStatus := D12->D12_STATUS
	EndIf
Return lRet
//--------------------------------------------------
/*/{Protheus.doc} UnLockD12
Libera a tabela para alteração D12
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//--------------------------------------------------
METHOD UnLockD12() CLASS WMSDTCMovimentosServicoArmazem
	D12->(dbGoTo(Self:nRecno))
Return D12->(MsUnlock())
//--------------------------------------------------
/*/{Protheus.doc} LoadData
Carregamentos dos dados D12
@author felipe.m
@since 23/12/2014
@version 1.0
@param nIndex, numérico, (Descrição do parâmetro)
/*/
//--------------------------------------------------
METHOD LoadData(nIndex) CLASS WMSDTCMovimentosServicoArmazem
Local aAreaAnt   := GetArea()
Local lRet       := .T.
Local cQuery     := ""
Local cAliasD12  := GetNextAlias()
Local aD12_QTDORI:= TamSx3("D12_QTDORI")
Local aD12_QTDOR2:= TamSx3("D12_QTDOR2")
Local aD12_QTDMOV:= TamSx3("D12_QTDMOV")
Local aD12_QTDMO2:= TamSx3("D12_QTDMO2")
Local aD12_QTDLID:= TamSx3("D12_QTDLID")
Local aD12_QTDLI2:= TamSx3("D12_QTDLI2")
Local aAreaD12 := D12->(GetArea())
Default nIndex := 4
	Do Case
		Case nIndex == 0
			If Empty(Self:nRecno)
				lRet := .F.
			EndIf
		Case nIndex == 4
			If (Empty(Self:GetIdDCF()) .OR. Empty(Self:cIdMovto).OR. Empty(Self:cIdOpera))
				lRet := .F.
			EndIf
		otherwise
			lRet := .F.
	EndCase

	If !lRet
		Self:cErro := STR0004 + " (" + GetClassName(Self) + ":LoadData(" + cValToChar(nIndex) + "))"// Dados para busca não foram informados!
	EndIf

	If lRet
		cQuery := "SELECT D12.D12_IDDCF,"
		cQuery +=       " D12.D12_SERVIC,"
		cQuery +=       " D12.D12_ORDTAR,"
		cQuery +=       " D12.D12_TAREFA,"
		cQuery +=       " D12.D12_ORDATI,"
		cQuery +=       " D12.D12_PRDORI,"
		cQuery +=       " D12.D12_PRODUT,"
		cQuery +=       " D12.D12_LOTECT,"
		cQuery +=       " D12.D12_NUMLOT,"
		cQuery +=       " D12.D12_NUMSER,"
		cQuery +=       " D12.D12_LOCORI,"
		cQuery +=       " D12.D12_ENDORI,"
		cQuery +=       " D12.D12_LOCDES,"
		cQuery +=       " D12.D12_ENDDES,"
		cQuery +=       " D12.D12_STATUS,"
		cQuery +=       " D12.D12_DTGERA,"
		cQuery +=       " D12.D12_HRGERA,"
		cQuery +=       " D12.D12_SEQPRI,"
		cQuery +=       " D12.D12_PRIORI,"
		cQuery +=       " D12.D12_RADIOF,"
		cQuery +=       " D12.D12_QTDORI,"
		cQuery +=       " D12.D12_QTDOR2,"
		cQuery +=       " D12.D12_QTDMOV,"
		cQuery +=       " D12.D12_QTDMO2,"
		cQuery +=       " D12.D12_QTDLID,"
		cQuery +=       " D12.D12_QTDLI2,"
		cQuery +=       " D12.D12_DATINI,"
		cQuery +=       " D12.D12_HORINI,"
		cQuery +=       " D12.D12_DATFIM,"
		cQuery +=       " D12.D12_HORFIM,"
		cQuery +=       " D12.D12_RHFUNC,"
		cQuery +=       " D12.D12_RECHUM,"
		cQuery +=       " D12.D12_RECFIS,"
		cQuery +=       " D12.D12_LIBPED,"
		cQuery +=       " D12.D12_SEQCAR,"
		cQuery +=       " D12.D12_CODVOL,"
		cQuery +=       " D12.D12_IDVOLU,"
		cQuery +=       " D12.D12_IDUNIT,"
		If Self:lHasUniDes
			cQuery +=    " D12.D12_UNIDES,"
		EndIf
		cQuery +=       " D12.D12_ANOMAL,"
		cQuery +=       " D12.D12_IDMOV,"
		cQuery +=       " D12.D12_MAPSEP,"
		cQuery +=       " D12.D12_MAPCON,"
		cQuery +=       " D12.D12_MAPTIP,"
		cQuery +=       " D12.D12_RECCON,"
		cQuery +=       " D12.D12_RECEMB,"
		cQuery +=       " D12.D12_ENDCON,"
		cQuery +=       " D12.D12_OCORRE,"
		cQuery +=       " D12.D12_QTDERR,"
		cQuery +=       " D12.D12_MNTVOL,"
		cQuery +=       " D12.D12_DISSEP,"
		cQuery +=       " D12.D12_IDOPER,"
		cQuery +=       " D12.D12_ORDMOV,"
		cQuery +=       " D12.D12_ATUEST,"
		cQuery +=       " D12.D12_AGLUTI,"
		cQuery +=       " D12.D12_NUMERO,"
		cQuery +=       " D12.D12_IMPETI,"
		cQuery +=       " D12.D12_PRAUTO,"
		cQuery +=       " D12.D12_BXESTO,"
		cQuery +=       " D12.D12_LOG,"
		cQuery +=       " D12.R_E_C_N_O_ RECNOD12"
		cQuery +=  " FROM "+RetSqlName('D12')+" D12"
		cQuery += " WHERE D12.D12_FILIAL = '"+xFilial("D12")+"'"
		Do Case
			Case nIndex == 0
				cQuery += " AND D12.R_E_C_N_O_ = " + AllTrim(Str(Self:nRecno))
			Case nIndex == 4
				cQuery += " AND D12.D12_IDDCF = '" + Self:GetIdDCF() + "'"
				cQuery += " AND D12.D12_IDMOV = '" + Self:cIdMovto + "'"
				cQuery += " AND D12.D12_IDOPER = '" + Self:cIdOpera + "'"
			otherwise
				lRet := .F.
		EndCase
		cQuery +=   " AND D12.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasD12,.F.,.T.)
		TCSetField(cAliasD12,'D12_QTDORI','N',aD12_QTDORI[1],aD12_QTDORI[2])
		TCSetField(cAliasD12,'D12_QTDOR2','N',aD12_QTDOR2[1],aD12_QTDOR2[2])
		TCSetField(cAliasD12,'D12_QTDMOV','N',aD12_QTDMOV[1],aD12_QTDMOV[2])
		TCSetField(cAliasD12,'D12_QTDMO2','N',aD12_QTDMO2[1],aD12_QTDMO2[2])
		TCSetField(cAliasD12,'D12_QTDLID','N',aD12_QTDLID[1],aD12_QTDLID[2])
		TCSetField(cAliasD12,'D12_QTDLI2','N',aD12_QTDLI2[1],aD12_QTDLI2[2])
		TcSetField(cAliasD12,'D12_DTGERA','D')
		TcSetField(cAliasD12,'D12_DATINI','D')
		TcSetField(cAliasD12,'D12_DATFIM','D')
		If (lRet := (cAliasD12)->(!Eof()))
			// Busca dados Ordem Servico
			Self:oOrdServ:SetIdDCF((cAliasD12)->D12_IDDCF)
			Self:oOrdServ:LoadData()
			// Busca dados Servico
			Self:oMovServic:SetServico((cAliasD12)->D12_SERVIC)
			Self:oMovServic:SetOrdem((cAliasD12)->D12_ORDTAR)
			Self:oMovServic:LoadData()
			// Busca dados Tarefa
			Self:oMovTarefa:SetTarefa((cAliasD12)->D12_TAREFA)
			Self:oMovTarefa:SetOrdem((cAliasD12)->D12_ORDATI)
			Self:oMovTarefa:LoadData()
			// Busca dados Produto/Lote
			Self:oMovPrdLot:SetArmazem((cAliasD12)->D12_LOCORI)
			Self:oMovPrdLot:SetPrdOri((cAliasD12)->D12_PRDORI)
			Self:oMovPrdLot:SetProduto((cAliasD12)->D12_PRODUT)
			Self:oMovPrdLot:SetLoteCtl((cAliasD12)->D12_LOTECT)
			Self:oMovPrdLot:SetNumLote((cAliasD12)->D12_NUMLOT)
			Self:oMovPrdLot:SetNumSer((cAliasD12)->D12_NUMSER)
			Self:oMovPrdLot:LoadData()
			// Busca dados Endereco Origem
			Self:oMovEndOri:SetArmazem((cAliasD12)->D12_LOCORI)
			Self:oMovEndOri:SetEnder((cAliasD12)->D12_ENDORI)
			Self:oMovEndOri:LoadData()
			// Busca dados Endereco Destino
			Self:oMovEndDes:SetArmazem((cAliasD12)->D12_LOCDES)
			Self:oMovEndDes:SetEnder((cAliasD12)->D12_ENDDES)
			Self:oMovEndDes:LoadData()
			// Atribui restante das informações
			Self:cStatus    := (cAliasD12)->D12_STATUS
			Self:dDtGeracao := (cAliasD12)->D12_DTGERA
			Self:cHrGeracao := (cAliasD12)->D12_HRGERA
			Self:cSeqPrior  := (cAliasD12)->D12_SEQPRI
			Self:cPriori    := (cAliasD12)->D12_PRIORI
			Self:cRadioF    := (cAliasD12)->D12_RADIOF
			Self:nQtdOrig   := (cAliasD12)->D12_QTDORI
			Self:nQtdOrig2  := (cAliasD12)->D12_QTDOR2
			Self:nQtdMovto  := (cAliasD12)->D12_QTDMOV
			Self:nQtdMovto2 := (cAliasD12)->D12_QTDMO2
			Self:nQtdLida   := (cAliasD12)->D12_QTDLID
			Self:nQtdLida2  := (cAliasD12)->D12_QTDLI2
			Self:dDtInicio  := (cAliasD12)->D12_DATINI
			Self:cHrInicio  := (cAliasD12)->D12_HORINI
			Self:dDtFinal   := (cAliasD12)->D12_DATFIM
			Self:cHrFinal   := (cAliasD12)->D12_HORFIM
			Self:cRhFuncao  := (cAliasD12)->D12_RHFUNC
			Self:cRecHumano := (cAliasD12)->D12_RECHUM
			Self:cRecFisico := (cAliasD12)->D12_RECFIS
			Self:cLibPed    := (cAliasD12)->D12_LIBPED
			Self:cSeqCarga  := (cAliasD12)->D12_SEQCAR
			Self:cCodVolume := (cAliasD12)->D12_CODVOL
			Self:cIdVolume  := (cAliasD12)->D12_IDVOLU
			Self:cIdUnitiz  := (cAliasD12)->D12_IDUNIT
			If Self:lHasUniDes
				Self:cUniDes    := (cAliasD12)->D12_UNIDES
			EndIf
			Self:cAnomalia  := (cAliasD12)->D12_ANOMAL
			Self:cIdMovto   := (cAliasD12)->D12_IDMOV
			Self:cMapaSep   := (cAliasD12)->D12_MAPSEP
			Self:cMapaCon   := (cAliasD12)->D12_MAPCON
			Self:cMapaTipo  := (cAliasD12)->D12_MAPTIP
			Self:cRecConf   := (cAliasD12)->D12_RECCON
			Self:cRecEmbal  := (cAliasD12)->D12_RECEMB
			Self:cEndConf   := (cAliasD12)->D12_ENDCON
			Self:cOcorre    := (cAliasD12)->D12_OCORRE
			Self:nQtdErro   := (cAliasD12)->D12_QTDERR
			Self:cMntVol    := (cAliasD12)->D12_MNTVOL
			Self:cDisSep    := (cAliasD12)->D12_DISSEP
			Self:cIdOpera   := (cAliasD12)->D12_IDOPER
			Self:cOrdMov    := (cAliasD12)->D12_ORDMOV
			Self:cAtuEst    := (cAliasD12)->D12_ATUEST
			Self:cAgluti    := (cAliasD12)->D12_AGLUTI
			Self:cNumOcor   := (cAliasD12)->D12_NUMERO
			Self:cSolImpEti := (cAliasD12)->D12_IMPETI
			Self:cPrAuto    := (cAliasD12)->D12_PRAUTO
			Self:cBxEsto    := (cAliasD12)->D12_BXESTO
			Self:cLog       := (cAliasD12)->D12_LOG
			Self:nRecno     := (cAliasD12)->RECNOD12
		EndIf
		(cAliasD12)->(dbCloseArea())
	EndIf
	RestArea(aAreaD12)
	RestArea(aAreaAnt)
Return lRet
//-----------------------------------
// Setters
//-----------------------------------
METHOD SetIdDCF(cIdDCF) CLASS WMSDTCMovimentosServicoArmazem
	Self:oOrdServ:SetIdDCF(cIdDCF)
Return

METHOD SetSequen(cSequen) CLASS WMSDTCMovimentosServicoArmazem
	Self:oOrdServ:SetSequen(cSequen)
Return

METHOD SetIdMovto(cIdMovto) CLASS WMSDTCMovimentosServicoArmazem
	Self:cIdMovto := PadR(cIdMovto,TamSx3("D12_IDMOV")[1])
Return

METHOD SetIdOpera(cIdOpera) CLASS WMSDTCMovimentosServicoArmazem
	Self:cIdOpera := PadR(cIdOpera,TamSx3("D12_IDOPER")[1])
Return

METHOD SetStatus(cStatus) CLASS WMSDTCMovimentosServicoArmazem
	Self:cStatus := PadR(cStatus, TamSx3("D12_STATUS")[1])
Return

METHOD SetOrdAtiv(cOrdAtiv) CLASS WMSDTCMovimentosServicoArmazem
	Self:cOrdemAtiv := PadR(cOrdAtiv,TamSx3("D12_ORDATI")[1])
Return

METHOD SetQtdOri(nQtdOrig) CLASS WMSDTCMovimentosServicoArmazem
	Self:nQtdOrig := nQtdOrig
Return

METHOD SetQtdOri2(nQtdOrig2) CLASS WMSDTCMovimentosServicoArmazem
	Self:nQtdOrig2 := nQtdOrig2
Return

METHOD SetQtdMov(nQtdMovto) CLASS WMSDTCMovimentosServicoArmazem
	Self:nQtdMovto := nQtdMovto
Return

METHOD SetQtdMov2(nQtdMovto2) CLASS WMSDTCMovimentosServicoArmazem
	Self:nQtdMovto2 := nQtdMovto2
Return

METHOD SetQtdLid(nQtdLida) CLASS WMSDTCMovimentosServicoArmazem
	Self:nQtdLida := nQtdLida
Return

METHOD SetQtdLid2(nQtdLida2) CLASS WMSDTCMovimentosServicoArmazem
	Self:nQtdLida2 := nQtdLida2
Return

METHOD SetQuant(nQuant) CLASS WMSDTCMovimentosServicoArmazem
	Self:nQuant := nQuant
Return

METHOD SetCodVol(cCodVolume) CLASS WMSDTCMovimentosServicoArmazem
	Self:cCodVolume := PadR(cCodVolume, TamSx3("D12_CODVOL")[1])
Return

METHOD SetMapTip(cMapaTipo) CLASS WMSDTCMovimentosServicoArmazem
	Self:cMapaTipo := PadR(cMapaTipo, TamSx3("D12_MAPTIP")[1])
Return

METHOD SetRhFunc(cRhFuncao) CLASS WMSDTCMovimentosServicoArmazem
	Self:cRhFuncao := PadR(cRhFuncao, TamSx3("D12_RHFUNC")[1])
Return

METHOD SetLibPed(cLibPed) CLASS WMSDTCMovimentosServicoArmazem
	Self:cLibPed := PadR(cLibPed, TamSx3("D12_LIBPED")[1])
Return

METHOD SetPriori(cPriori) CLASS WMSDTCMovimentosServicoArmazem
	Self:cPriori := PadR(cPriori, TamSx3("D12_PRIORI")[1])
Return

METHOD SetSeqPrio(cSeqPrior) CLASS WMSDTCMovimentosServicoArmazem
	Self:cSeqPrior := PadR(cSeqPrior, TamSx3("D12_SEQPRI")[1])
Return

METHOD SetDataGer(dDtGeracao) CLASS WMSDTCMovimentosServicoArmazem
	Self:dDtGeracao := dDtGeracao
Return

METHOD SetHoraGer(cHrGeracao) CLASS WMSDTCMovimentosServicoArmazem
	Self:cHrGeracao := PadR(cHrGeracao, TamSx3("D12_HRGERA")[1])
Return

METHOD SetDataIni(dDtInicio) CLASS WMSDTCMovimentosServicoArmazem
	Self:dDtInicio := dDtInicio
Return

METHOD SetHoraIni(cHrInicio) CLASS WMSDTCMovimentosServicoArmazem
	Self:cHrInicio := PadR(cHrInicio, TamSx3("D12_HORINI")[1])
Return

METHOD SetDataFim(dDtFinal) CLASS WMSDTCMovimentosServicoArmazem
	Self:dDtFinal := dDtFinal
Return

METHOD SetHoraFim(cHrFinal) CLASS WMSDTCMovimentosServicoArmazem
	Self:cHrFinal := PadR(cHrFinal, TamSx3("D12_HORFIM")[1])
Return

METHOD SetRecHum(cRecHumano) CLASS WMSDTCMovimentosServicoArmazem
	Self:cRecHumano := PadR(cRecHumano, TamSx3("D12_RECHUM")[1])
Return

METHOD SetRecFis(cRecFisico) CLASS WMSDTCMovimentosServicoArmazem
	Self:cRecFisico := PadR(cRecFisico, TamSx3("D12_RECFIS")[1])
Return

METHOD SetAnomal(cAnomalia) CLASS WMSDTCMovimentosServicoArmazem
	Self:cAnomalia := PadR(cAnomalia, TamSx3("D12_ANOMAL")[1])
Return

METHOD SetRecCon(cRecConf) CLASS WMSDTCMovimentosServicoArmazem
	Self:cRecConf := PadR(cRecConf, TamSx3("D12_RECCON")[1])
Return

METHOD SetRecEmb(cRecEmbal) CLASS WMSDTCMovimentosServicoArmazem
	Self:cRecEmbal := PadR(cRecEmbal, TamSx3("D12_RECEMB")[1])
Return

METHOD SetQtdErro(nQtdErro) CLASS WMSDTCMovimentosServicoArmazem
	Self:nQtdErro := nQtdErro
Return

METHOD SetMntVol(cMntVol) CLASS WMSDTCMovimentosServicoArmazem
	Self:cMntVol := PadR(cMntVol, TamSx3("D12_MNTVOL")[1])
Return

METHOD SetDisSep(cDisSep) CLASS WMSDTCMovimentosServicoArmazem
	Self:cDisSep := PadR(cDisSep, TamSx3("D12_DISSEP")[1])
Return

METHOD SetAtuEst(cAtuEst) CLASS WMSDTCMovimentosServicoArmazem
	Self:cAtuEst := PadR(cAtuEst, TamSx3("D12_ATUEST")[1])
Return

METHOD SetOcorre(cOcorre) CLASS WMSDTCMovimentosServicoArmazem
	Self:cOcorre := PadR(cOcorre, TamSx3("D12_OCORRE")[1])
Return

METHOD SetIdUnit(cIdUnitiz) CLASS WMSDTCMovimentosServicoArmazem
	Self:cIdUnitiz := PadR(cIdUnitiz, TamSx3("D12_IDUNIT")[1])
Return

METHOD SetTipUni(cTipUni) CLASS WMSDTCMovimentosServicoArmazem
	Self:cTipUni := PadR(cTipUni, Iif(Self:lHasUniDes,TamSx3("D14_CODUNI")[1],6))
Return

METHOD SetUniDes(cUniDes) CLASS WMSDTCMovimentosServicoArmazem
	Self:cUniDes := PadR(cUniDes, Iif(Self:lHasUniDes,TamSx3("D12_UNIDES")[1],6))
Return

METHOD SetRecD12(aRecD12) CLASS WMSDTCMovimentosServicoArmazem
	Self:aRecD12 := aRecD12
Return

METHOD SetWmsReab(aWmsReab) CLASS WMSDTCMovimentosServicoArmazem
	Self:aWmsReab := aWmsReab
Return

METHOD SetRadioF(cRadioF) CLASS WMSDTCMovimentosServicoArmazem
	Self:cRadioF := PadR(cRadioF, TamSx3("D12_RADIOF")[1])
Return

METHOD SetArmInv(cArmInv) CLASS WMSDTCMovimentosServicoArmazem
	Self:cArmInv := PadR(cArmInv, TamSx3("D12_LOCORI")[1])
Return

METHOD SetEndInv(cEndInv) CLASS WMSDTCMovimentosServicoArmazem
	Self:cEndInv := PadR(cEndInv, TamSx3("D12_ENDORI")[1])
Return

METHOD SetAgluti(cAgluti) CLASS WMSDTCMovimentosServicoArmazem
	Self:cAgluti := PadR(cAgluti, TamSx3("D12_AGLUTI")[1])
Return

METHOD SetNumOcor(cNumOcor) CLASS WMSDTCMovimentosServicoArmazem
	Self:cNumOcor := PadR(cNumOcor, TamSx3("D12_NUMERO")[1])
Return

METHOD SetSolImpE(cSolImpEti) CLASS WMSDTCMovimentosServicoArmazem
	Self:cSolImpEti := PadR(cSolImpEti, TamSx3("D12_IMPETI")[1])
Return

METHOD SetOrdAglu(aOrdAglu) CLASS WMSDTCMovimentosServicoArmazem
	Self:aOrdAglu := aOrdAglu
Return

METHOD SetErro(cErro) CLASS WMSDTCMovimentosServicoArmazem
	Self:cErro := cErro
Return

METHOD SetPrAuto(cPrAuto) CLASS WMSDTCMovimentosServicoArmazem
	Self:cPrAuto := cPrAuto
Return

METHOD SetBxEsto(cBxEsto) CLASS WMSDTCMovimentosServicoArmazem
	Self:cBxEsto := cBxEsto
Return

METHOD SetLog(cLog) CLASS WMSDTCMovimentosServicoArmazem
	Self:cLog := cLog
Return

METHOD SetUsuArm(lUsuArm) CLASS WMSDTCMovimentosServicoArmazem
	Self:lUsuArm := lUsuArm
Return

//-----------------------------------
// Getters
//-----------------------------------
METHOD GetIdDCF() CLASS WMSDTCMovimentosServicoArmazem
Return Self:oOrdServ:GetIdDCF()

METHOD GetSequen() CLASS WMSDTCMovimentosServicoArmazem
Return Self:oOrdServ:GetSequen()

METHOD GetIdMovto() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cIdMovto

METHOD GetIdOpera() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cIdOpera

METHOD GetOrdAtiv() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cOrdemAtiv

METHOD GetStatus() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cStatus

METHOD GetIdUnit() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cIdUnitiz

METHOD GetCodVol() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cCodVolume

METHOD GetUniDes() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cUniDes

METHOD GetTipUni() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cTipUni

METHOD GetPriori() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cPriori

METHOD GetRadioF() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cRadioF

METHOD GetSeqPrio() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cSeqPrior

METHOD GetQtdMov() CLASS WMSDTCMovimentosServicoArmazem
Return Self:nQtdMovto

METHOD GetQtdMov2() CLASS WMSDTCMovimentosServicoArmazem
Return Self:nQtdMovto2

METHOD GetQtdLid() CLASS WMSDTCMovimentosServicoArmazem
Return Self:nQtdLida

METHOD GetQtdLid2() CLASS WMSDTCMovimentosServicoArmazem
Return Self:nQtdLida2

METHOD GetQuant() CLASS WMSDTCMovimentosServicoArmazem
Return Self:nQuant

METHOD GetDataGer() CLASS WMSDTCMovimentosServicoArmazem
Return Self:dDtGeracao

METHOD GetHoraGer() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cHrGeracao

METHOD GetDataIni() CLASS WMSDTCMovimentosServicoArmazem
Return Self:dDtInicio

METHOD GetHoraIni() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cHrInicio

METHOD GetDataFim() CLASS WMSDTCMovimentosServicoArmazem
Return Self:dDtFinal

METHOD GetHoraFim() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cHrFinal

METHOD GetRecHum() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cRecHumano

METHOD GetRecFis() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cRecFisico

METHOD GetLibPed() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cLibPed

METHOD GetMapSep() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cMapaSep

METHOD GetMapaTip() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cMapaTipo

METHOD GetRhFunc() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cRhFuncao

METHOD GetOcorre() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cOcorre

METHOD GetRecCon() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cRecConf

METHOD GetQtdErro() CLASS WMSDTCMovimentosServicoArmazem
Return Self:nQtdErro

METHOD GetMntVol() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cMntVol

METHOD GetDisSep() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cDisSep

METHOD GetAtuEst() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cAtuEst

METHOD GetEndCon() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cEndConf

METHOD GetRecno() CLASS WMSDTCMovimentosServicoArmazem
Return Self:nRecno

METHOD GetErro() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cErro

METHOD GetArmInv() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cArmInv

METHOD GetEndInv() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cEndInv

METHOD GetAgluti() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cAgluti

METHOD GetNumOcor() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cNumOcor

METHOD GetSolImpE() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cSolImpEti

METHOD GetOrdAglu() CLASS WMSDTCMovimentosServicoArmazem
Return Self:aOrdAglu

METHOD GetPrAuto() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cPrAuto

METHOD GetBxEsto() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cBxEsto
//--------------------------------------------------
/*/{Protheus.doc} AssignD12
Atribui os dados as propriedades
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//--------------------------------------------------
METHOD AssignD12() CLASS WMSDTCMovimentosServicoArmazem
Local lRet       := .T.
Local aAtividade := {}
Local aExOrigem  := {}
Local aExDestino := {}
Local lNoExcec   := .T.
Local nAtividade := 0
Local cIdMovto   := ""
Local nRecnoD12  := 0
Local nContMov   := 0
Local nI         := 0
Local nPos       := 0
Local nQtSol     := 0
Local nOrdTar    := 0
Local nOrdPrd    := 0
Local aAgluMov   := {}
Local aAgluLot   := {}
Local aProduto   := {}
Local nRecnoDCF  := Self:oOrdServ:GetRecno()
Local nRegraWMS  := Self:oOrdServ:GetRegra()
Local cNoExOri   := ""
Local cNoExDes   := ""
Local cIDDCFOrig := ""

	// Caso endereço destino seja um picking ou seja a DOCA no processo de separação, limpa o unitizador destino do movimento
	If Self:DesNotUnit()
		Self:cUniDes := ""
		Self:cTipUni := ""
	Else
		// Caso não foi informado o unitizador destino, assume o mesmo que a origem, apenas se o armazém destino tbm for unitizado
		If Empty(Self:cUniDes) .And. WmsArmUnit(Self:oMovEndDes:GetArmazem())
			Self:cUniDes := Self:cIdUnitiz
		EndIf
	EndIf

	// Gera IDMOVTO
	cIdMovto   := GetSX8Num('D12', 'D12_IDMOV')
	ConfirmSx8()
	// Atribui identificador de movimento
	Self:SetIdMovto(cIdMovto)
	// Excecao endereco origem
	aExOrigem  := Self:oMovEndOri:GetArrExce()
	// Excecao endereco destino
	aExDestino := Self:oMovEndDes:GetArrExce()
	// Carrega as atividades da tarefa
	Self:oMovTarefa:SetTarefa(Self:oMovServic:GetTarefa())
	Self:oMovTarefa:TarefaAtiv()
	Self:cOrdMov := "1" // Primeira Atividade
	Self:cAtuEst := "2" // Atividade não atualiza estoque
	aAtividade := Self:oMovTarefa:GetArrAti()

	// Quando documentos aglutinados
	If !Empty(Self:aOrdAglu)
		//Realiza o rateio para a tarefa da quantidade total solicitada dentre os ID DCF que estão no array,
		//determinando neste momento quanto de cada ID DCF que será atendido pela quantidade total deste movimento
		nQtSol := Self:nQtdMovto

		nOrdPrd := Self:oOrdServ:nProduto
		nOrdTar := Self:oOrdServ:nTarefa
		For nI := 1 To Len(Self:aOrdAglu)
			aAgluMov := Self:aOrdAglu[nI][POSTAREFA][nOrdPrd][nOrdTar]
			// Reserva um novo array para os lotes que podem ser atendidos para o primeiro item
			// Exemplo de rateio para dois documentos DOC 01 e DOC 02 ambos com 5 unidades:
			//  MOV01 -> FILHO-01 -> LOTE A -> 2
			//                       DOC 01 -> 2 -> Sobram 3
			//  MOV02 -> FILHO-01 -> LOTE B -> 2
			//                       DOC 01 -> 2 -> Sobram 1
			//  MOV03 -> FILHO-01 -> LOTE A -> 6
			//                       DOC 01 -> 1 -> Sobram 0
			//                       DOC 02 -> 5 -> Sobram 0
			// Somando está gerando LOTE A -> 8 e LOTE B -> 2
			// Ao executar o segundo movimento vai tentar atender com os lotes na ordem,
			// forçando o rateio dos demais produtos serem para os lotes errados nos documentos
			// pois o rateio seria forçado a ser DOC 01 -> 5 e DOC 02 -> 3 + 2
			If nOrdPrd == 1
				If Len(aAgluMov) <= POSQTDMOV
					AAdd(aAgluMov,{})
				EndIf
			Else
				If Len(aAgluMov) <= POSQTDMOV
					// Copia o rateio de lotes para os outros produtos filhos
					aAgluLot := Self:aOrdAglu[nI][POSTAREFA][1][nOrdTar][POSQTDMOV+1]
					aAgluLot := AClone(aAgluLot)
					aProduto := Self:oOrdServ:oProdLote:GetArrProd()
					// Reserva uma linha para a quantidade já atendida para os demais produtos para o lote
					aEval(aAgluLot, {|x| x[3] := ((x[3]/aProduto[1][2])*(aProduto[nOrdPrd][2])), AAdd(x,0)})
					AAdd(aAgluMov,aAgluLot)
				EndIf
			EndIf
			If (aAgluMov[POSQTDSOL] - aAgluMov[POSQTDATD]) > 0
				//Considera a primeira DCF com saldo disponível para ser utilizado na movimentação, como a DCF de origem.
				If Empty(cIDDCFOrig)
					cIDDCFOrig := Self:aOrdAglu[nI][1]
				EndIf 
				aAgluMov[POSIDDCF] := cIDDCFOrig
				If nOrdPrd == 1
					If nQtSol > (aAgluMov[POSQTDSOL] - aAgluMov[POSQTDATD])
						nQtSol -= (aAgluMov[POSQTDSOL] - aAgluMov[POSQTDATD])
						aAgluMov[POSQTDMOV] := (aAgluMov[POSQTDSOL] - aAgluMov[POSQTDATD]) //Utiliza todo o saldo
					Else
						aAgluMov[POSQTDMOV] := nQtSol
						nQtSol := 0
					EndIf
					// Grava o total atendido
					aAgluMov[POSQTDATD] += aAgluMov[POSQTDMOV]
					// Grava o rateio por lote para o primeiro produto
					If (nPos := AScan(aAgluMov[POSQTDMOV+1],{|x| x[1]+x[2] == Self:oMovPrdLot:GetLoteCtl()+Self:oMovPrdLot:GetNumLote()})) > 0
						aAgluMov[POSQTDMOV+1][nPos][3] += aAgluMov[POSQTDMOV]
					Else
						 AAdd(aAgluMov[POSQTDMOV+1],{Self:oMovPrdLot:GetLoteCtl(),Self:oMovPrdLot:GetNumLote(),aAgluMov[POSQTDMOV]})
					EndIf

					If nQtSol == 0
						Exit
					EndIf
				Else
					// Deve fazer o rateio levando em consideração os lotes rateados para o primeiro produto
					nPos := AScan(aAgluMov[POSQTDMOV+1],{|x| x[1]+x[2] == Self:oMovPrdLot:GetLoteCtl()+Self:oMovPrdLot:GetNumLote()})
					If nPos > 0
						aAgluLot := aAgluMov[POSQTDMOV+1][nPos]
						If nQtSol > (aAgluLot[3] - aAgluLot[4])
							nQtSol -= (aAgluLot[3] - aAgluLot[4])
							aAgluMov[POSQTDMOV] := (aAgluLot[3] - aAgluLot[4]) //Utiliza todo o saldo
						Else
							aAgluMov[POSQTDMOV] := nQtSol
							nQtSol := 0
						EndIf
						// Grava o total atendido
						aAgluLot[4] += aAgluMov[POSQTDMOV]
						aAgluMov[POSQTDATD] += aAgluMov[POSQTDMOV]

						If nQtSol == 0
							Exit
						EndIf
					EndIf
				EndIf
			EndIf
		Next nI
	EndIf
	// Atividades
	For nAtividade := 1 To Len(aAtividade)
		Self:oMovTarefa:SetOrdem(aAtividade[nAtividade][1])
		Self:oMovTarefa:LoadData()
		// Valida Excecoes
		lNoExcec := .T.
		If Self:oMovServic:GetTipo() == "1" // Nas Entradas, verifica as Excecoes nos Enderecos Destino (Ex.: DOCA->Picking)
			lNoExcec := AScan(aExDestino, Self:oMovTarefa:GetAtivid()) == 0
		ElseIf Self:oMovServic:GetTipo() == "2" // Nas Saidas, verifica as Excecoes nos Enderecos Origem (Ex.: Picking->DOCA)
			lNoExcec := AScan(aExOrigem, Self:oMovTarefa:GetAtivid()) == 0
		ElseIf Self:oMovServic:GetTipo() == "3" // Nos Movtos.Internos, verifica as Excecoes nos Enderecos Destino ou Origem
			// Valida excessões
			If Len(aAtividade) > 1 .And. nAtividade == 1 // Se possuir mais de uma atividade, e for a primeira, deve verificar apenas na origem
				lNoExcec := AScan(aExOrigem, Self:oMovTarefa:GetAtivid()) == 0
			ElseIf Len(aAtividade) > 1                   // Se possuir mais de uma atividade, e não for a primeira, deve verificar apenas no destino
				lNoExcec := AScan(aExDestino, Self:oMovTarefa:GetAtivid()) == 0
			ElseIf Len(aAtividade) == 1                  // Se possuir uma unica atividade, deve verificar se há excessão na origem e/ou no destino
				lNoExcec := (AScan(aExOrigem, Self:oMovTarefa:GetAtivid()) == 0 .Or. AScan(aExDestino, Self:oMovTarefa:GetAtivid()) == 0)
			EndIf
		EndIf
		If lNoExcec // Se nao houverem excecoes
			Self:cRadioF := IIf(Empty(Self:oMovTarefa:GetRadioF()),"2",Self:oMovTarefa:GetRadioF())
			Self:RecordD12()
			Self:cOrdMov := "2" // Atividade Intermediaria
			nRecnoD12    := Self:nRecno
			nContMov++
		Else
			If Self:oMovServic:GetTipo() == "1"
				cNoExDes += IIf(Empty(cNoExDes),Alltrim(Self:oMovEndDes:GetEnder())," ,"+Alltrim(Self:oMovEndDes:GetEnder()))
			ElseIf Self:oMovServic:GetTipo() == "2"
				cNoExOri += IIf(Empty(cNoExOri),Alltrim(Self:oMovEndOri:GetEnder())," ,"+Alltrim(Self:oMovEndOri:GetEnder()))
			ElseIf Self:oMovServic:GetTipo() == "3"
				cNoExDes += IIf(Empty(cNoExDes),Alltrim(Self:oMovEndDes:GetEnder())," ,"+Alltrim(Self:oMovEndDes:GetEnder()))
				cNoExOri += IIf(Empty(cNoExOri),Alltrim(Self:oMovEndOri:GetEnder())," ,"+Alltrim(Self:oMovEndOri:GetEnder()))
			EndIf
		EndIf
	Next
	// Quando documentos aglutinados
	If !Empty(Self:aOrdAglu)
		// Zera as quantidades distribuídas nesta movimentação
		For nI := 1 To Len(Self:aOrdAglu)
			Self:aOrdAglu[nI][POSTAREFA][nOrdPrd][nOrdTar][POSQTDMOV] := 0
		Next nI
	EndIf
	// Verifica se foram criadas atividades
	If !Empty(nRecnoD12)
		Self:GoToD12(nRecnoD12)

		If Self:oMovServic:ChkSepara()
			// Efetua o ajuste na tabela de liberação de pedidos (SC9)
			// Cria tabelas:
			// Montagem de volumes
			// Distribuição da separação
			// Conferência expedição
			If Self:oOrdServ:GetOrigem() == "SC9" .And. (Self:oMovServic:ChkMntVol() .Or. Self:oMovServic:ChkConfExp() .Or. Self:oMovServic:ChkDisSep())
				// Cria os processos de expedição
				lRet := Self:UpdExpedic()
			EndIf
		EndIf

		If lRet
			If nContMov > 1
				Self:cOrdMov := "3" // Ultima Atividade
			Else
				Self:cOrdMov := "4" // Ultima e Primeira Atividade
			EndIf
			If Self:oMovServic:ChkMovEst()
				Self:cAtuEst := "1" // Ultima tarefa atualiza estoque
			EndIf
			Self:UpdateD12()
		EndIf
		Self:oOrdServ:GoToDCF(nRecnoDCF) // Recarrega a DCF original quando aglutina tarefas
		Self:oOrdServ:SetRegra(nRegraWMS) // Recarrega também a regra WMS, que pode estar em branco no registro da DCF, porém foi definida no processo de separação
	Else
		Self:cErro := WmsFmtMsg(STR0019,{{"[VAR01]",Self:oMovServic:GetTarefa()}}) // Não foi gerado atividade para a tarefa [VAR01]
		If !Empty(cNoExOri)
			Self:cErro += CRLF + WmsFmtMsg(STR0029,{{"[VAR01]",cNoExOri}}) // Verifique as excessoes dos endereços origem ([VAR01])
		EndIf
		If !Empty(cNoExDes)
			Self:cErro += CRLF + WmsFmtMsg(STR0030,{{"[VAR01]",cNoExDes}}) // Verifique as excessoes dos endereços destido ([VAR01])
		EndIf
		lRet := .F.
	EndIf
Return lRet

//------------------------------------------------------------------------------
METHOD UpdExpedic(lConsExec) CLASS WMSDTCMovimentosServicoArmazem
//------------------------------------------------------------------------------
Local lRet        := .T.
Local cQuery      := ""
Local cAliasQry   := ""
Local oMntVolItem := Nil
Local oDisSepItem := Nil
Local oConExpItem := Nil
Default lConsExec := .F.  //Indica se considera ordens de serviço executadas
	cQuery := " SELECT DCF.DCF_CARGA,"
	cQuery +=        " DCF.DCF_DOCTO,"
	cQuery +=        " DCF.DCF_ID,"
	cQuery +=        " DCR.DCR_QUANT"
	cQuery +=   " FROM "+RetSqlName("DCR")+" DCR"
	cQuery +=  " INNER JOIN "+RetSqlName("DCF")+" DCF"
	cQuery +=     " ON DCF.DCF_FILIAL = '"+xFilial("DCF")+"'"
	cQuery +=    " AND DCR.DCR_FILIAL = '"+xFilial("DCR")+"'"
	cQuery +=    " AND DCF.DCF_ID = DCR.DCR_IDDCF"
	If !lConsExec
		cQuery +=    " AND DCF.DCF_STSERV <> '3'"
	EndIf
	cQuery +=    " AND DCF.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE DCR.DCR_FILIAL = '"+xFilial("DCR")+"'"
	cQuery +=    " AND DCR.D_E_L_E_T_ = ' '"
	cQuery +=    " AND DCR.DCR_IDORI = '"+Self:oOrdServ:GetIdDCF()+"'"
	cQuery +=    " AND DCR.DCR_IDMOV = '"+Self:GetIdMovto()+"'"
	cQuery +=    " AND DCR.DCR_IDOPER = '"+Self:GetIdOpera()+"'"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	Do While (cAliasQry)->(!Eof())
		// Valida se possui montagem de volume
		If Self:oMovServic:ChkMntVol()
			oMntVolItem := WMSDTCMontagemVolumeItens():New()
			oMntVolItem:SetCarga((cAliasQry)->DCF_CARGA)
			oMntVolItem:SetPedido((cAliasQry)->DCF_DOCTO)
			oMntVolItem:SetPrdOri(Self:oMovPrdLot:GetPrdOri())
			oMntVolItem:SetProduto(Self:oMovPrdLot:GetProduto())
			oMntVolItem:SetLoteCtl(Self:oMovPrdLot:GetLoteCtl())
			oMntVolItem:SetNumLote(Self:oMovPrdLot:GetNumLote())
			oMntVolItem:SetLibPed(Self:oMovServic:GetLibPed())
			oMntVolItem:SetMntExc(Self:oMovServic:GetMntExc())
			// Busca o código da montagem de volume
			oMntVolItem:SetCodMnt(oMntVolItem:oMntVol:FindCodMnt())
			oMntVolItem:SetIdDCF((cAliasQry)->DCF_ID)
			oMntVolItem:SetQtdOri((cAliasQry)->DCR_QUANT)
			lRet := oMntVolItem:AssignDCT()
			If !lRet
				Self:cErro := oMntVolItem:GetErro()
			EndIf
			oMntVolItem:Destroy()
		EndIf
		// Enquanto for maior que zero, vai separando a quantidade de uma norma ou o restante
		// Deve verificar se a estrutura da sequência de abastecimento utiliza distribuição da separação
		If lRet .And. Self:oMovServic:ChkDisSep()
			oDisSepItem := WMSDTCDistribuicaoSeparacaoItens():New()
			oDisSepItem:oDisSep:SetCarga((cAliasQry)->DCF_CARGA)
			oDisSepItem:oDisSep:SetPedido((cAliasQry)->DCF_DOCTO)
			oDisSepItem:oDisSep:oDisEndDes:SetArmazem(Self:oMovEndDes:GetArmazem())
			oDisSepItem:SetPrdOri(Self:oMovPrdLot:GetPrdOri())
			oDisSepItem:oDisPrdLot:SetProduto(Self:oMovPrdLot:GetProduto())
			oDisSepItem:oDisPrdLot:SetLoteCtl(Self:oMovPrdLot:GetLoteCtl())
			oDisSepItem:oDisPrdLot:SetNumLote(Self:oMovPrdLot:GetNumLote())
			oDisSepItem:oDisPrdLot:SetNumSer(Self:oMovPrdLot:GetNumSer())
			oDisSepItem:oDisEndOri:SetArmazem(Self:oMovEndDes:GetArmazem())
			oDisSepItem:oDisEndOri:SetEnder(Self:oMovEndDes:GetEnder())
			// Busca codigo da distribuição da separação
			oDisSepItem:SetCodDis(oDisSepItem:oDisSep:FindCodDis())
			oDisSepItem:SetIdDCF((cAliasQry)->DCF_ID)
			oDisSepItem:SetQtdOri((cAliasQry)->DCR_QUANT)
			lRet := oDisSepItem:AssignD0E()
			If !lRet
				Self:cErro := oDisSepItem:GetErro()
			EndIf
			oDisSepItem:Destroy()
		EndIf
		// Valida se possui conferencia de expedição
		If lRet .And. Self:oMovServic:ChkConfExp()
			oConExpItem := WMSDTCConferenciaExpedicaoItens():New()
			oConExpItem:SetCarga((cAliasQry)->DCF_CARGA)
			oConExpItem:SetPedido((cAliasQry)->DCF_DOCTO)
			oConExpItem:SetPrdOri(Self:oMovPrdLot:GetPrdOri())
			oConExpItem:SetProduto(Self:oMovPrdLot:GetProduto())
			oConExpItem:SetLoteCtl(Self:oMovPrdLot:GetLoteCtl())
			oConExpItem:SetNumLote(Self:oMovPrdLot:GetNumLote())
			oConExpItem:SetLibPed(Self:oMovServic:GetLibPed())
			// Busca codigo da conferencia de expedição
			oConExpItem:SetCodExp(oConExpItem:oConfExp:FindCodExp())
			oConExpItem:SetIdDCF((cAliasQry)->DCF_ID)
			oConExpItem:SetQtdOri((cAliasQry)->DCR_QUANT)
			lRet := oConExpItem:AssignD02()
			If !lRet
				Self:cErro := oConExpItem:GetErro()
			EndIf
			oConExpItem:Destroy()
		EndIf
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
Return lRet

//--------------------------------------------------
/*/{Protheus.doc} RecordD12
Gravação dos dados D12
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//--------------------------------------------------
METHOD RecordD12() CLASS WMSDTCMovimentosServicoArmazem
Local lRet      := .T.
Local lAglutina := .F.
Local nQtdNorma := 0
Local nQtdMovto := 0
Local nQtdMovto2:= 0
Local nQtdLida  := 0
Local nQtdLida2 := 0
Local nQtdOrig  := 0
Local nQtdOrig2 := 0
Local nOrdTar   := 0
Local nI        := 0
Local nQtdTotal := 0
Local cIdDCF    := ""
Local cSequen   := ""
Local cIdMovto  := ""
Local cIdOpera  := ""
Local cAliasD12 := ""
Local aAreaD12  := D12->(GetArea())
Local cQuery    := ""
Local lHasLibD12:= AttIsMemberOf(Self:oOrdServ,"aLibD12",.T.) .And. ValType(Self:oOrdServ:aLibD12)=="A"
Local oRelacMov := WMSDTCRelacionamentoMovimentosServicoArmazem():New()
Local nQtdDCR   := 0

	// Armazena informações origem
	cIdDCF          := Self:GetIdDCF()
	cSequen         := Self:GetSequen()
	cIdMovto        := Self:cIdMovto
	cIdOpera        := GetSx8Num('D12','D12_IDOPER'); ConfirmSX8()
	Self:cIdOpera   := cIdOpera
	// Atribui quantidades
	nQtdMovto  := Self:nQtdMovto
	nQtdMovto2 := ConvUm(Self:oMovPrdLot:GetProduto(),Self:nQtdMovto,0,2)
	nQtdLida   := Self:nQtdLida
	nQtdLida2  := ConvUm(Self:oMovPrdLot:GetProduto(),Self:nQtdLida,0,2)

	// Preenche a Sequencia da Carga
	If !Empty(Self:oOrdServ:GetCarga()) .And. Empty(Self:cSeqCarga)
		DAK->(dbSetOrder(1))
		If DAK->(MsSeek(xFilial('DAK')+Self:oOrdServ:GetCarga(), .F.))
			Self:cSeqCarga := DAK->DAK_SEQCAR
		EndIf
	EndIf
	// Verifica tipo de aglutinação defido e se não é
	// um movimento de estorno de movimento aglutinado
	If Self:cStatus <> '0' .And. Self:oMovTarefa:GetTpAglu() > "1" .And. !Self:IsMovUnit() .And. !Self:lEstAglu .And. !Self:oMovServic:ChkConfer()
		// Posiciona no Registro para Aglutinacao
		nQtdNorma := DLQtdNorma(Self:oMovPrdLot:GetProduto(),Self:oMovEndDes:GetArmazem(),Self:oMovEndDes:GetEstFis(),,.F.)
		If QtdComp(Self:nQtdMovto) < QtdComp(nQtdNorma) .And. ;
			(!Self:oMovTarefa:GetTpAglu() $ "4|5"  .Or. (Self:oMovTarefa:GetTpAglu() $ "4|5" .And. WmsCarga(Self:oOrdServ:GetCarga())))
			cQuery := "SELECT D12.R_E_C_N_O_ RECNOD12"
			cQuery +=  " FROM "+RetSqlName("D12")+" D12"
			cQuery += " WHERE D12.D12_FILIAL = '"+xFilial("D12")+"'"
			cQuery +=   " AND D12.D12_PRODUT = '"+Self:oMovPrdLot:GetProduto()+"'"
			cQuery +=   " AND D12.D12_PRDORI = '"+Self:oMovPrdLot:GetPrdOri()+"'"
			cQuery +=   " AND D12.D12_LOTECT = '"+Self:oMovPrdLot:GetLoteCtl()+"'"
			cQuery +=   " AND D12.D12_NUMLOT = '"+Self:oMovPrdLot:GetNumLote()+"'"
			cQuery +=   " AND D12.D12_NUMSER = '"+Self:oMovPrdLot:GetNumSer()+"'"
			cQuery +=   " AND D12.D12_LOCORI = '"+Self:oMovEndOri:GetArmazem()+"'"
			cQuery +=   " AND D12.D12_ENDORI = '"+Self:oMovEndOri:GetEnder()+"'"
			cQuery +=   " AND D12.D12_LOCDES = '"+Self:oMovEndDes:GetArmazem()+"'"
			cQuery +=   " AND D12.D12_ENDDES = '"+Self:oMovEndDes:GetEnder()+"'"
			cQuery +=   " AND D12.D12_SERVIC = '"+Self:oMovServic:GetServico()+"'"
			cQuery +=   " AND D12.D12_TAREFA = '"+Self:oMovServic:GetTarefa()+"'"
			cQuery +=   " AND D12.D12_ATIVID = '"+Self:oMovTarefa:GetAtivid()+"'"
			cQuery +=   " AND D12.D12_MAPTIP = '"+Self:cMapaTipo+"'"
			cQuery +=   " AND D12.D12_IDUNIT = '"+Self:cIdUnitiz+"'"
			If Self:lHasUniDes
				cQuery +=   " AND D12.D12_UNIDES = '"+Self:cUniDes+"'"
			EndIf
			cQuery +=   " AND D12.D12_STATUS IN ('"+Self:cStatus+"','-')"
			cQuery +=   " AND D12.D12_MNTVOL = '"+Self:cMntVol+"'"
			cQuery +=   " AND D12.D12_DISSEP = '"+Self:cDisSep+"'"
			cQuery +=   " AND D12.D12_RADIOF = '"+Self:cRadioF+"'"
			cQuery +=   " AND D12.D12_ORIGEM <> 'D0A'"
			cQuery +=   " AND D12.D_E_L_E_T_ = ' '"
			cQuery +=   " AND D12.D12_QTDMOV  +  " + AllTrim(Str(Self:nQtdMovto)) + " <= " + AllTrim(Str(nQtdNorma))
			If Self:oMovTarefa:GetTpAglu() == "2" // 2 = Aglutina por Documento+Serie
				cQuery += " AND D12.D12_DOC = '"+Self:oOrdServ:GetDocto()+"'"
				If Self:oMovServic:ChkRecebi()
					cQuery += " AND D12.D12_SERIE = '"+Self:oOrdServ:GetSerie()+"'"
				EndIf
			ElseIf Self:oMovTarefa:GetTpAglu() == "3" // 3 = Aglutina por Cliente/Fornecedor+Loja
				cQuery += " AND D12.D12_CLIFOR = '"+Self:oOrdServ:GetCliFor()+"'"
				cQuery += " AND D12.D12_LOJA = '"+Self:oOrdServ:GetLoja()+"'"
			ElseIf Self:oMovTarefa:GetTpAglu() == "4"// 4 = Aglutina por Carga+Sequencia da Carga
				cQuery += " AND D12.D12_CARGA = '"+Self:oOrdServ:GetCarga()+"'"
				cQuery += " AND D12.D12_SEQCAR = '"+Self:cSeqCarga+"'"
			ElseIf Self:oMovTarefa:GetTpAglu() == "5" // 5 = Aglutina por Carga+Sequencia da Carga+Cliente+loja
				cQuery += " AND D12.D12_CARGA = '"+Self:oOrdServ:GetCarga()+"'"
				cQuery += " AND D12.D12_SEQCAR = '"+Self:cSeqCarga+"'"
				cQuery += " AND D12.D12_CLIFOR = '"+Self:oOrdServ:GetCliFor()+"'"
				cQuery += " AND D12.D12_LOJA = '"+Self:oOrdServ:GetLoja()+"'"
			EndIf
			cQuery := ChangeQuery(cQuery)
			cAliasD12 := GetNextAlias()
			dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasD12,.F.,.T.)
			If (cAliasD12)->(!Eof())
				lAglutina := .T.
				// Verifica se aglutina e posiciona no registro aglutinador
				D12->(dbGoTo((cAliasD12)->RECNOD12))
			EndIf
			(cAliasD12)->(DbCloseArea())
		EndIf
	EndIf
	dbSelectArea('D12')
	Self:cAgluti := Iif(lAglutina,"1","2")
	// Utiliza o array quando documentos aglutinados
	If !Empty(Self:aOrdAglu)
		// Grava relacionamento movimento servico armazem
		nOrdPrd := Self:oOrdServ:nProduto
		nOrdTar := Self:oOrdServ:nTarefa
		For nI := 1 To Len(Self:aOrdAglu)
			aAgluMov := Self:aOrdAglu[nI][POSTAREFA][nOrdPrd][nOrdTar]

			If aAgluMov[POSQTDMOV] > 0
				cIdDCF     := aAgluMov[POSIDDCF]
				nQtdMovto  := aAgluMov[POSQTDMOV]
				nQtdMovto2 := ConvUm(Self:oMovPrdLot:GetProduto(),nQtdMovto,0,2)

				oRelacMov:SetIdOrig(Iif(lAglutina,D12->D12_IDDCF,cIdDCF))
				oRelacMov:SetIdDCF(Self:aOrdAglu[nI][1])
				oRelacMov:SetIdMovto(Iif(lAglutina,D12->D12_IDMOV,cIdMovto))
				oRelacMov:SetIdOpera(Iif(lAglutina,D12->D12_IDOPER,cIdOpera))
				oRelacMov:SetSequen(Self:aOrdAglu[nI][4])
				If oRelacMov:LoadData()
					oRelacMov:SetQuant(oRelacMov:GetQuant()+nQtdMovto)
					oRelacMov:SetQuant2(oRelacMov:GetQuant2()+nQtdMovto2)
					oRelacMov:UpdateDCR()
				Else
					oRelacMov:SetQuant(nQtdMovto)
					oRelacMov:SetQuant2(nQtdMovto2)
					oRelacMov:RecordDCR()
				EndIf
				nQtdTotal += nQtdMovto
				nQtdDCR++
			EndIf
		Next nI
		nQtdMovto := nQtdTotal
		nQtdMovto2 := ConvUm(Self:oMovPrdLot:GetProduto(),nQtdMovto,0,2)
		Self:cAgluti := Iif(nQtdDCR > 1,"1","2")
		// Verifica se a DCF é diferente da executada, posiciona a mesma
		If cIdDCF <> Self:oOrdServ:GetIdDCF()
			// Atribui ordem de serviço para carregar os documentos corretos
			Self:oOrdServ:SetIdDCF(cIdDCF)
			Self:oOrdServ:LoadData()
		EndIf
	Else
		// Grava relacionamento movimento servico armazem
		oRelacMov:SetIdOrig(IIf(lAglutina,D12->D12_IDDCF,cIdDCF))
		oRelacMov:SetIdDCF(cIdDCF)
		oRelacMov:SetSequen(cSequen)
		oRelacMov:SetIdMovto(IIf(lAglutina,D12->D12_IDMOV,cIdMovto))
		oRelacMov:SetIdOpera(IIf(lAglutina,D12->D12_IDOPER,cIdOpera))
		If oRelacMov:LoadData()
			oRelacMov:SetQuant(oRelacMov:GetQuant()+nQtdMovto)
			oRelacMov:SetQuant2(oRelacMov:GetQuant2()+nQtdMovto2)
			oRelacMov:UpdateDCR()
		Else
			oRelacMov:SetQuant(nQtdMovto)
			oRelacMov:SetQuant2(nQtdMovto2)
			oRelacMov:RecordDCR()
		EndIf
	EndIf

	If lAglutina
		// Somatorias
		nQtdMovto  += D12->D12_QTDMOV
		nQtdMovto2 += D12->D12_QTDMO2
	EndIf
	// Ajusta quantidades
	nQtdOrig  := nQtdMovto
	nQtdOrig2 := nQtdMovto2
	// Busca sequencia de execução da OS
	If !lAglutina
		Self:cSeqPrior := Self:oOrdServ:GetSeqPri()
	EndIf
	// Grava dados
	Reclock('D12', !lAglutina)
	If !lAglutina
		D12->D12_FILIAL := xFilial("D12")
		D12->D12_IDDCF  := cIdDCF //Self:GetIdDCF()
		D12->D12_IDMOV  := Self:cIdMovto
		D12->D12_IDOPER := Self:cIdOpera
		D12->D12_NUMSEQ := Self:oOrdServ:GetNumSeq()
		D12->D12_SEQUEN := Self:oOrdServ:GetSequen()
		D12->D12_PRDORI := Self:oMovPrdLot:GetPrdOri()
		D12->D12_PRODUT := Self:oMovPrdLot:GetProduto()
		D12->D12_LOTECT := Self:oMovPrdLot:GetLoteCtl()
		D12->D12_NUMLOT := Self:oMovPrdLot:GetNumLote()
		D12->D12_NUMSER := Self:oMovPrdLot:GetNumSer()
		D12->D12_CODVOL := Self:cCodVolume
		D12->D12_IDVOLU := Self:cIdVolume
		D12->D12_IDUNIT := Self:cIdUnitiz
		If Self:lHasUniDes
			D12->D12_UNIDES := Self:cUniDes
		EndIf
		D12->D12_ORIGEM := Self:oOrdServ:GetOrigem()
		D12->D12_DOC    := Self:oOrdServ:GetDocto()
		D12->D12_SDOC   := Self:oOrdServ:GetSerie() // Self:oOrdServ:GetSDoc()
		D12->D12_CLIFOR := Self:oOrdServ:GetCliFor()
		D12->D12_LOJA   := Self:oOrdServ:GetLoja()
		D12->D12_SERIE  := Self:oOrdServ:GetSerie()
		D12->D12_CARGA  := Self:oOrdServ:GetCarga()
		D12->D12_CODREC := Self:oOrdServ:GetCodRec()
		D12->D12_SEQCAR := Self:cSeqCarga
		// Muda o status do movimento para posterior analise da regra de convoca
		If lHasLibD12 .And. !Self:lEstAglu
			D12->D12_STATUS := "-"
		Else
			D12->D12_STATUS := Self:cStatus
		EndIf
		D12->D12_DTGERA := Self:dDtGeracao
		D12->D12_HRGERA := Self:cHrGeracao
		D12->D12_SEQPRI := Self:cSeqPrior
		D12->D12_PRIORI := Self:cPriori
		D12->D12_SERVIC := Self:oMovServic:GetServico()
		D12->D12_TAREFA := Self:oMovServic:GetTarefa()
		D12->D12_ORDTAR := Self:oMovServic:GetOrdem()
		D12->D12_LIBPED := Self:cLibPed
		D12->D12_ATIVID := Self:oMovTarefa:GetAtivid()
		D12->D12_ORDATI := Self:oMovTarefa:GetOrdem()
		D12->D12_RHFUNC := Self:oMovTarefa:GetFuncao()
		D12->D12_RECFIS := Self:oMovTarefa:GetTpRec()
		D12->D12_RADIOF := Self:cRadioF
		D12->D12_PRAUTO := Self:cPrAuto
		D12->D12_QTDLID := Self:nQtdLida
		D12->D12_QTDLI2 := Self:nQtdLida2
		D12->D12_TM     := "0"
		D12->D12_LOCORI := Self:oMovEndOri:GetArmazem()
		D12->D12_ENDORI := Self:oMovEndOri:GetEnder()
		D12->D12_LOCDES := Self:oMovEndDes:GetArmazem()
		D12->D12_ENDDES := Self:oMovEndDes:GetEnder()
		D12->D12_DATINI := Self:dDtInicio
		D12->D12_HORINI := Self:cHrInicio
		D12->D12_DATFIM := Self:dDtFinal
		D12->D12_HORFIM := Self:cHrFinal
		D12->D12_RECHUM := Self:cRecHumano
		D12->D12_ORIGEM := Self:oOrdServ:GetOrigem()
		D12->D12_ANOMAL := Self:cAnomalia
		D12->D12_MAPSEP := Self:cMapaSep
		D12->D12_MAPCON := Self:cMapaCon
		D12->D12_MAPTIP := Self:cMapaTipo
		D12->D12_RECCON := Self:cRecConf
		D12->D12_RECEMB := Self:cRecEmbal
		D12->D12_ENDCON := Self:cEndConf
		D12->D12_OCORRE := Self:cOcorre
		D12->D12_QTDERR := Self:nQtdErro
		D12->D12_MNTVOL := Self:cMntVol
		D12->D12_DISSEP := Self:cDisSep
		D12->D12_ORDMOV := Self:cOrdMov
		D12->D12_ATUEST := Self:cAtuEst
		D12->D12_BXESTO := Self:cBxEsto
		D12->D12_IMPETI := Self:oMovServic:GetSolImpE()
	EndIf
	// Quantidade
	D12->D12_QTDORI := nQtdOrig
	D12->D12_QTDOR2 := nQtdOrig2
	D12->D12_QTDMOV := nQtdMovto
	D12->D12_QTDMO2 := nQtdMovto2
	D12->D12_QTDLID := nQtdLida
	D12->D12_QTDLI2 := nQtdLida2
	D12->D12_NUMERO := Self:cNumOcor
	D12->D12_LOG    := Self:cLog
	D12->D12_AGLUTI := Self:cAgluti
	D12->(MsUnLock())
	// Inclui movimento para analise de regra de convocação quando não for um
	// estorno de movimento aglutinado
	If lHasLibD12 .And. !Self:lEstAglu
		AAdd(Self:aRecD12, {Self:cStatus, D12->(Recno()),D12->D12_LOCORI, D12->D12_SERVIC," ",D12->D12_PRODUT})
	EndIf
	// Grava Recno da D12
	Self:nRecno := D12->(Recno())
	// Ponto de Entrada WMSPOSDCF apos as gravacoes
	// Recebe o recno da D12 criada
	// Recebe o recno da DCF da D12 criada
	If ExistBlock('WMSPOSD12')
		ExecBlock('WMSPOSD12',.F.,.F.,{Self:nRecno,Self:oOrdServ:GetRecno()})
	EndIf
	RestArea(aAreaD12)
Return lRet
//--------------------------------------------------
/*/{Protheus.doc} UpdateD12
Atualiza a movimentação D12
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//--------------------------------------------------
METHOD UpdateD12(lMsUnLock) CLASS WMSDTCMovimentosServicoArmazem
Local lRet       := .T.
Local aAreaD12   := D12->(GetArea())

Default lMsUnLock := .T.

	Self:nQtdMovto2 := ConvUm(Self:oMovPrdLot:GetProduto(),Self:nQtdMovto,0,2)
	Self:nQtdLida2  := ConvUm(Self:oMovPrdLot:GetProduto(),Self:nQtdLida,0,2)
	Self:nQtdOrig2  := ConvUm(Self:oMovPrdLot:GetProduto(),Self:nQtdOrig,0,2)
	// Garante que a D12 está posicionada
	D12->(dbGoTo(Self:GetRecno()))
	// Grava dados
	Reclock('D12', .F.)
	D12->D12_IDDCF  := Self:GetIdDCF()
	D12->D12_IDMOV  := Self:cIdMovto
	D12->D12_LOTECT := Self:oMovPrdLot:GetLoteCtl()
	D12->D12_NUMLOT := Self:oMovPrdLot:GetNumLote()
	D12->D12_NUMSER := Self:oMovPrdLot:GetNumSer()
	D12->D12_CODVOL := Self:cCodVolume
	D12->D12_IDVOLU := Self:cIdVolume
	D12->D12_IDUNIT := Self:cIdUnitiz
	If Self:lHasUniDes
		D12->D12_UNIDES := Self:cUniDes
	EndIf
	D12->D12_STATUS := Self:cStatus
	D12->D12_SEQPRI := Self:cSeqPrior
	D12->D12_PRIORI := Self:cPriori
	D12->D12_RHFUNC := Self:oMovTarefa:GetFuncao()
	D12->D12_RECFIS := Self:oMovTarefa:GetTpRec()
	D12->D12_RADIOF := Self:cRadioF
	D12->D12_QTDORI := Self:nQtdOrig
	D12->D12_QTDOR2 := Self:nQtdOrig2
	D12->D12_QTDMOV := Self:nQtdMovto
	D12->D12_QTDMO2 := Self:nQtdMovto2
	D12->D12_QTDLID := Self:nQtdLida
	D12->D12_QTDLI2 := Self:nQtdLida2
	D12->D12_LOCORI := Self:oMovEndOri:GetArmazem()
	D12->D12_ENDORI := Self:oMovEndOri:GetEnder()
	D12->D12_LOCDES := Self:oMovEndDes:GetArmazem()
	D12->D12_ENDDES := Self:oMovEndDes:GetEnder()
	D12->D12_DATINI := Self:dDtInicio
	D12->D12_HORINI := Self:cHrInicio
	D12->D12_DATFIM := Self:dDtFinal
	D12->D12_HORFIM := Self:cHrFinal
	D12->D12_RECHUM := Self:cRecHumano
	D12->D12_ANOMAL := Self:cAnomalia
	D12->D12_MAPSEP := Self:cMapaSep
	D12->D12_MAPCON := Self:cMapaCon
	D12->D12_MAPTIP := Self:cMapaTipo
	D12->D12_RECCON := Self:cRecConf
	D12->D12_RECEMB := Self:cRecEmbal
	D12->D12_ENDCON := Self:cEndConf
	D12->D12_OCORRE := Self:cOcorre
	D12->D12_QTDERR := Self:nQtdErro
	D12->D12_MNTVOL := Self:cMntVol
	D12->D12_DISSEP := Self:cDisSep
	D12->D12_ORDMOV := Self:cOrdMov
	D12->D12_ATUEST := Self:cAtuEst
	D12->D12_PRAUTO := Self:cPrAuto
	D12->D12_NUMERO := Self:cNumOcor
	D12->D12_IMPETI := Self:cSolImpEti
	D12->D12_AGLUTI := Self:cAgluti
	D12->D12_LOG    := Self:cLog
	D12->D12_DOC    := Self:oOrdServ:GetDocto()
	D12->D12_SDOC   := Self:oOrdServ:GetSerie() // Self:oOrdServ:GetSDoc()
	D12->D12_CLIFOR := Self:oOrdServ:GetCliFor()
	D12->D12_LOJA   := Self:oOrdServ:GetLoja()
	D12->D12_SERIE  := Self:oOrdServ:GetSerie()
	D12->D12_CARGA  := Self:oOrdServ:GetCarga()
	D12->D12_CODREC := Self:oOrdServ:GetCodRec()
	D12->D12_NUMSEQ := Self:oOrdServ:GetNumSeq()
	D12->D12_SEQCAR := Self:cSeqCarga
	D12->(dbCommit())
	If lMsUnLock
		D12->(MsUnLock())
	EndIf
	RestArea(aAreaD12)
Return lRet

//--------------------------------------------------
/*/{Protheus.doc} DeleteD12
Exclusão do registro D12
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//--------------------------------------------------
METHOD DeleteD12() CLASS WMSDTCMovimentosServicoArmazem
Local lRet     := .T.
Local aAreaD12 := D12->(GetArea())
	// Grava dados
	D12->(dbGoTo(Self:GetRecno()))
	Reclock('D12', .F.)
	D12->(DbDelete())
	D12->(MsUnlock())
	RestArea(aAreaD12)
Return lRet
//--------------------------------------------------
/*/{Protheus.doc} IsUltAtiv
Verifica se é a ultima atividade
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//--------------------------------------------------
METHOD IsUltAtiv() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cOrdMov $ "3|4"
//--------------------------------------------------
/*/{Protheus.doc} IsPriAtiv
Verifica se é a primeira atividade
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//--------------------------------------------------
METHOD IsPriAtiv() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cOrdMov $ "1|4"
//--------------------------------------------------
/*/{Protheus.doc} IsUpdEst
Verifica se atividades atualiza estoque
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//--------------------------------------------------
METHOD IsUpdEst() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cAtuEst == "1"
//--------------------------------------------------

//--------------------------------------------------
/*/{Protheus.doc} MakeInput
Efetua uma entrada prevista
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//--------------------------------------------------
METHOD MakeInput() CLASS WMSDTCMovimentosServicoArmazem
Local lRet      := .T.
Local cQuery    := ""
Local cAliasD14 := ""
Local aTamSX3   := {}
	// Caso endereço destino seja um picking ou seja a DOCA no processo de separação, limpa o unitizador destino do movimento
	If Self:DesNotUnit()
		Self:cUniDes := ""
		Self:cTipUni := ""
	Else
		// Caso não foi informado o unitizador destino, assume o mesmo que a origem, apenas se o armazém destino tbm for unitizado
		If Empty(Self:cUniDes) .And. WmsArmUnit(Self:oMovEndDes:GetArmazem())
			Self:cUniDes := Self:cIdUnitiz
		EndIf
	EndIf
	Self:oEstEnder:ClearData()
	If Self:IsMovUnit()
		cQuery := "SELECT D14.D14_CODUNI,"
		cQuery +=       " D14.D14_PRDORI,"
		cQuery +=       " D14.D14_PRODUT,"
		cQuery +=       " D14.D14_LOTECT,"
		cQuery +=       " D14.D14_NUMLOT,"
		cQuery +=       " D14.D14_QTDEST"
		cQuery +=  " FROM "+RetSqlName("D14")+" D14"
		cQuery += " WHERE D14.D14_FILIAL = '"+xFilial("D14")+"'"
		cQuery +=   " AND D14.D14_IDUNIT = '"+Self:cIdUnitiz+"'"
		cQuery +=   " AND D14.D14_LOCAL  = '"+Self:oMovEndOri:GetArmazem()+"'"
		cQuery +=   " AND D14.D14_ENDER  = '"+Self:oMovEndOri:GetEnder()+"'"
		cQuery +=   " AND D14.D_E_L_E_T_ = ' '"
		cAliasD14 := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasD14,.F.,.T.)
		aTamSX3 := TamSx3("D14_QTDEST"); TcSetField(cAliasD14,'D14_QTDEST','N',aTamSX3[1],aTamSX3[2])
		If (cAliasD14)->(!Eof())
			While lRet .And. (cAliasD14)->(!Eof())
				// Carrega dados para LoadData EstEnder
				Self:oEstEnder:oEndereco:SetArmazem(Self:oMovEndDes:GetArmazem())
				Self:oEstEnder:oEndereco:SetEnder(Self:oMovEndDes:GetEnder())
				Self:oEstEnder:oProdLote:SetArmazem(Self:oMovEndDes:GetArmazem()) // Armazem
				Self:oEstEnder:oProdLote:SetPrdOri((cAliasD14)->D14_PRDORI)   // Produto Origem - Componente
				Self:oEstEnder:oProdLote:SetProduto((cAliasD14)->D14_PRODUT) // Produto Principal
				Self:oEstEnder:oProdLote:SetLoteCtl((cAliasD14)->D14_LOTECT) // Lote do produto principal que deverá ser o mesmo no componentes
				Self:oEstEnder:oProdLote:SetNumLote((cAliasD14)->D14_NUMLOT) // Sub-Lote do produto principal que deverá ser o mesmo no componentes
				Self:oEstEnder:SetIdUnit(Self:cUniDes)
				Self:oEstEnder:SetTipUni(Iif(Self:cUniDes==Self:cIdUnitiz,(cAliasD14)->D14_CODUNI,Self:cTipUni))
				// Atribui a quantidade do produto no unitizador
				Self:oEstEnder:SetQuant((cAliasD14)->D14_QTDEST)
				lRet := Self:oEstEnder:UpdSaldo('499',.F.,.T.,.F.,.F.,.F.)
				(cAliasD14)->(DbSkip())
			EndDo
		Else
			Self:cErro := WmsFmtMsg(STR0031,{{"[VAR01]",Self:cUniDes}}) // Não foi encontrado o saldo por endereço do unitizador [VAR01].
			lRet := .F.
		EndIf
		(cAliasD14)->(DbCloseArea())
	Else
		// Carrega dados para LoadData EstEnder
		Self:oEstEnder:oEndereco:SetArmazem(Self:oMovEndDes:GetArmazem())
		Self:oEstEnder:oEndereco:SetEnder(Self:oMovEndDes:GetEnder())
		Self:oEstEnder:oProdLote:SetArmazem(Self:oMovPrdLot:GetArmazem()) // Armazem
		Self:oEstEnder:oProdLote:SetPrdOri(Self:oMovPrdLot:GetPrdOri())   // Produto Origem - Componente
		Self:oEstEnder:oProdLote:SetProduto(Self:oMovPrdLot:GetProduto()) // Produto Principal
		Self:oEstEnder:oProdLote:SetLoteCtl(Self:oMovPrdLot:GetLoteCtl()) // Lote do produto principal que deverá ser o mesmo no componentes
		Self:oEstEnder:oProdLote:SetNumLote(Self:oMovPrdLot:GetNumLote()) // Sub-Lote do produto principal que deverá ser o mesmo no componentes
		Self:oEstEnder:SetIdUnit(Self:cUniDes)
		Self:oEstEnder:SetTipUni(Self:cTipUni)
		Self:oEstEnder:SetQuant(Self:nQtdMovto)
		lRet := Self:oEstEnder:UpdSaldo('499',.F.,.T.,.F.,.F.,.F.)
	EndIf
Return lRet
//--------------------------------------------------
/*/{Protheus.doc} MakeOutput
Efetua uma saída prevista
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//--------------------------------------------------
METHOD MakeOutput() CLASS WMSDTCMovimentosServicoArmazem
Local lEmpPrev  := Self:oMovServic:ChkSepara()
Local lRet      := .T.
Local cQuery    := ""
Local cAliasD14 := ""
Local aTamSX3   := {}

	Self:oEstEnder:ClearData()
	If Self:IsMovUnit()
		cQuery := "SELECT D14.D14_CODUNI,"
		cQuery +=       " D14.D14_PRDORI,"
		cQuery +=       " D14.D14_PRODUT,"
		cQuery +=       " D14.D14_LOTECT,"
		cQuery +=       " D14.D14_NUMLOT,"
		cQuery +=       " D14.D14_QTDEST"
		cQuery +=  " FROM "+RetSqlName("D14")+" D14"
		cQuery += " WHERE D14.D14_FILIAL = '"+xFilial("D14")+"'"
		cQuery +=   " AND D14.D14_IDUNIT = '"+Self:cIdUnitiz+"'"
		cQuery +=   " AND D14.D14_LOCAL  = '"+Self:oMovEndOri:GetArmazem()+"'"
		cQuery +=   " AND D14.D14_ENDER  = '"+Self:oMovEndOri:GetEnder()+"'"
		cQuery +=   " AND D14.D_E_L_E_T_ = ' '"
		cAliasD14 := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasD14,.F.,.T.)
		aTamSX3 := TamSx3("D14_QTDEST"); TcSetField(cAliasD14,'D14_QTDEST','N',aTamSX3[1],aTamSX3[2])
		If (cAliasD14)->(!Eof())
			While lRet .And. (cAliasD14)->(!Eof())
				// Carrega dados para LoadData EstEnder
				Self:oEstEnder:oEndereco:SetArmazem(Self:oMovEndOri:GetArmazem())
				Self:oEstEnder:oEndereco:SetEnder(Self:oMovEndOri:GetEnder())
				Self:oEstEnder:oProdLote:SetArmazem(Self:oMovEndOri:GetArmazem()) // Armazem
				Self:oEstEnder:oProdLote:SetPrdOri((cAliasD14)->D14_PRDORI)   // Produto Origem - Componente
				Self:oEstEnder:oProdLote:SetProduto((cAliasD14)->D14_PRODUT) // Produto Principal
				Self:oEstEnder:oProdLote:SetLoteCtl((cAliasD14)->D14_LOTECT) // Lote do produto principal que deverá ser o mesmo no componentes
				Self:oEstEnder:oProdLote:SetNumLote((cAliasD14)->D14_NUMLOT) // Sub-Lote do produto principal que deverá ser o mesmo no componentes
				Self:oEstEnder:SetIdUnit(Self:cIdUnitiz)
				//Self:oEstEnder:SetTipUni((cAliasD14)->D14_CODUNI) // Registro já está na D14, não informar para não sobrepor
				Self:oEstEnder:SetQuant((cAliasD14)->D14_QTDEST)
				lRet := Self:oEstEnder:UpdSaldo('499',.F. /*lEstoque*/,.F. /*lEntPrev*/,.T./*lSaiPrev*/,.F./*lEmpenho*/,.F. /*lBloqueio*/,lEmpPrev /*lEmpPrev*/)
				(cAliasD14)->(dbSkip())
			EndDo
		Else
			Self:cErro := WmsFmtMsg(STR0031,{{"[VAR01]",Self:cIdUnitiz}}) // Não foi encontrado o saldo por endereço do unitizador [VAR01].
			lRet := .F.
		EndIf
		(cAliasD14)->(DbCloseArea())
	Else
		// Caso servico de separação gera quantidade empenho
		// Caso não seja separação gera quantidade saida prevista
		// Carrega dados para LoadData EstEndEr
		Self:oEstEnder:oEndereco:SetArmazem(Self:oMovEndOri:GetArmazem())
		Self:oEstEnder:oEndereco:SetEnder(Self:oMovEndOri:GetEnder())
		Self:oEstEnder:oProdLote:SetArmazem(Self:oMovPrdLot:GetArmazem()) // Armazem
		Self:oEstEnder:oProdLote:SetPrdOri(Self:oMovPrdLot:GetPrdOri())   // Produto Origem - Componente
		Self:oEstEnder:oProdLote:SetProduto(Self:oMovPrdLot:GetProduto()) // Produto Principal
		Self:oEstEnder:oProdLote:SetLoteCtl(Self:oMovPrdLot:GetLoteCtl()) // Lote do produto principal que deverá ser o mesmo no componentes
		Self:oEstEnder:oProdLote:SetNumLote(Self:oMovPrdLot:GetNumLote()) // Sub-Lote do produto principal que deverá ser o mesmo no componentes
		Self:oEstEnder:SetIdUnit(Self:cIdUnitiz)
		//Self:oEstEnder:SetTipUni(Self:cTipUni) // Registro já está na D14, não informar para não sobrepor
		Self:oEstEnder:SetQuant(Self:nQtdMovto)
		lRet := Self:oEstEnder:UpdSaldo('499',.F. /*lEstoque*/,.F. /*lEntPrev*/,.T./*lSaiPrev*/,.F./*lEmpenho*/,.F. /*lBloqueio*/,lEmpPrev /*lEmpPrev*/)
	EndIf
Return lRet

METHOD ChkMntVol(cTipoMnt) CLASS WMSDTCMovimentosServicoArmazem
Return (Self:cMntVol != "0" .And. Self:cMntVol == cTipoMnt)

METHOD ChkDisSep() CLASS WMSDTCMovimentosServicoArmazem
Return (Self:cDisSep == "1")

METHOD ChkConfExp() CLASS WMSDTCMovimentosServicoArmazem
Return (Self:oMovServic:ChkConfExp())

METHOD ChkSolImpE() CLASS WMSDTCMovimentosServicoArmazem
Return (Self:cSolImpEti == "1" .Or. Empty(Self:cSolImpEti))
//--------------------------------------------------
/*/{Protheus.doc} ChkEndOri
//Valida se endereço origem não possui restrição para movimentação
@author Squad WMS Protheus
@since 27/06/2018
@version 1.0
@return lógico
@param lMovEst, Logical, Indica se desconta quantidade da movimentação da quantidade saida prevista, pois quantidade do movimento está inclusa.
@param lConMov, Logical, Inidca se Considera apenas o saldo atual do endereço, pois está efetuando efetivamente a movimentação de estoque
@param lConsSld, Logical, Inidca se Não efetua a consulta de capacidade do endereço, pois é feita em outro momento

@type function
@version 1.0
/*/
//--------------------------------------------------
METHOD ChkEndOri(lConsMov,lMovEst,lConsSld) CLASS WMSDTCMovimentosServicoArmazem
Local lRet      := .T.
Local nSaldoPrd := 0
Local nSaldoPRE := 0
Local nSaldoPRS := 0
Local nSaldoSB2 := 0
Default lConsMov := .F. // Desconta quantidade da movimentação da quantidade saida prevista, pois quantidade do movimento está inclusa.
Default lMovEst  := .F. // Considera apenas o saldo atual do endereço, pois está efetuando efetivamente a movimentação de estoque
Default lConsSld := .T. // Não efetua a consulta de capacidade do endereço, pois é feita em outro momento

	If Self:oMovEndOri:LoadData(Nil,.T.)
		If Self:oMovEndOri:GetStatus() == "3" // Endereço bloqueado
			Self:cErro := WmsFmtMsg(STR0020,{{"[VAR01]",Self:oMovEndOri:GetEnder()}}) // O endereço origem [VAR01] está bloqueado.
			lRet := .F.
		ElseIf Self:oMovEndOri:GetStatus() == "5" // Endereço com bloqueio de saída
			Self:cErro := WmsFmtMsg(STR0021,{{"[VAR01]",Self:oMovEndOri:GetEnder()}}) // O endereço origem [VAR01] está com bloqueio de saída.
			lRet := .F.
		ElseIf Self:oMovEndOri:GetStatus() == "6" // Endereço com bloqueio de inventário
			Self:cErro := WmsFmtMsg(STR0022,{{"[VAR01]",Self:oMovEndOri:GetEnder()}}) // O endereço origem [VAR01] está com bloqueio de inventário.
			lRet := .F.
		EndIf
	EndIf
	// Se não deve consultar o saldo, retorna neste momento
	If !lConsSld
		Return lRet
	EndIf
	If lRet .And. !Self:oMovServic:ChkConfer()
		Self:oEstEnder:ClearData()
		If Self:IsMovUnit()
			cQuery := "SELECT D14.D14_CODUNI,"
			cQuery +=       " D14.D14_PRDORI,"
			cQuery +=       " D14.D14_PRODUT,"
			cQuery +=       " D14.D14_LOTECT,"
			cQuery +=       " D14.D14_NUMLOT,"
			cQuery +=       " D14.D14_NUMSER,"
			cQuery +=       " D14.D14_QTDEST,"
			cQuery +=       " D14.D14_QTDEPR,"
			cQuery +=       " D14.D14_QTDSPR,"
			cQuery +=       " D14.D14_QTDEMP,"
			cQuery +=       " D14.D14_QTDBLQ"
			cQuery +=  " FROM "+RetSqlName("D14")+" D14"
			cQuery += " WHERE D14.D14_FILIAL = '"+xFilial("D14")+"'"
			cQuery +=   " AND D14.D14_IDUNIT = '"+Self:cIdUnitiz+"'"
			cQuery +=   " AND D14.D14_LOCAL  = '"+Self:oMovEndOri:GetArmazem()+"'"
			cQuery +=   " AND D14.D14_ENDER  = '"+Self:oMovEndOri:GetEnder()+"'"
			cQuery +=   " AND D14.D_E_L_E_T_ = ' '"
			cAliasD14 := GetNextAlias()
			DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasD14,.F.,.T.)
			aTamSX3 := TamSx3("D14_QTDEST")
			TcSetField(cAliasD14,'D14_QTDEST','N',aTamSX3[1],aTamSX3[2])
			TcSetField(cAliasD14,'D14_QTDEPR','N',aTamSX3[1],aTamSX3[2])
			TcSetField(cAliasD14,'D14_QTDSPR','N',aTamSX3[1],aTamSX3[2])
			TcSetField(cAliasD14,'D14_QTDEMP','N',aTamSX3[1],aTamSX3[2])
			TcSetField(cAliasD14,'D14_QTDBLQ','N',aTamSX3[1],aTamSX3[2])
			If (cAliasD14)->(!Eof())
				While lRet .And. (cAliasD14)->(!Eof())
					nSaldoPrd := (cAliasD14)->D14_QTDEST - ( (cAliasD14)->D14_QTDEMP + (cAliasD14)->D14_QTDBLQ )
					nSaldoPRE := (cAliasD14)->D14_QTDEPR
					nSaldoPRS := (cAliasD14)->D14_QTDSPR
					// Utiliza o saldo descontando a saida prevista
					If (Iif(lMovEst,QtdComp(nSaldoPrd),QtdComp(nSaldoPrd - Iif(lConsMov,0,nSaldoPRS))) < QtdComp((cAliasD14)->D14_QTDEST))
						If QtdComp(nSaldoPRE) > 0 .Or. QtdComp(nSaldoPRS) > 0
							Self:cErro := WmsFmtMsg(STR0016,{{"[VAR01]",Self:oMovPrdLot:GetProduto()},{"[VAR02]",Self:oMovEndOri:GetEnder()}})  // Existem atividades a executar que comprometem o saldo do produto [VAR01] no endereço [VAR02].
							Self:cErro += CRLF+WmsFmtMsg(STR0011,{{"[VAR01]",Transf(nSaldoPrd,PesqPictQt('D12_QTDMOV',14))}})                   // Endereço possui saldo de [VAR01].
							Self:cErro += CRLF+WmsFmtMsg(STR0012,{{"[VAR01]",Transf(nSaldoPRE,PesqPictQt('D12_QTDMOV',14))}})                   // Entrada prevista de [VAR01].
							Self:cErro += CRLF+WmsFmtMsg(STR0015,{{"[VAR01]",Transf(nSaldoPRS,PesqPictQt('D12_QTDMOV',14))}})                   // Saída prevista de [VAR01].
						Else
							Self:cErro += WmsFmtMsg(STR0017,{{"[VAR01]",Self:oMovPrdLot:GetProduto()},{"[VAR02]",Self:oMovEndOri:GetEnder()}})  // Saldo do produto [VAR01] no endereço [VAR02] insuficiente para movimentação.
							Self:cErro += CRLF+WmsFmtMsg(STR0011,{{"[VAR01]",Transf(nSaldoPrd,PesqPictQt('D12_QTDMOV',14))}})                   // Endereço possui saldo de [VAR01].
						EndIf
						lRet := .F.
					EndIf
					// Analisa empenho do lote
					If lRet .And. Self:oMovServic:ChkTransf() .And. !(Self:oMovEndOri:GetArmazem() == Self:oMovEndDes:GetArmazem())
						If !Self:ChkEstPrd(lMovEst,lConsMov,(cAliasD14)->D14_LOCAL,(cAliasD14)->D14_PRODUT,(cAliasD14)->D14_LOTECTL,(cAliasD14)->D14_NUMLOT,(cAliasD14)->D14_QTDEST)
							Self:cErro := WmsFmtMsg(STR0045,{{"[VAR01]",Self:oMovPrdLot:GetProduto()},{"[VAR02]",Self:oMovEndOri:GetArmazem()},{"[VAR03]",Self:oMovEndOri:GetEnder()}})  // Existem reservas e/ou empenhos que comprometem o saldo do produto [VAR01] no armazém [VAR02] e endereço [VAR03].
							lRet := .F.
						EndIf
					EndIf
					(cAliasD14)->(DbSkip())
				EndDo
			Else
				Self:cErro := WmsFmtMsg(STR0031,{{"[VAR01]",Self:cIdUnitiz}}) // Não foi encontrado o saldo por endereço do unitizador [VAR01].
				lRet := .F.
			EndIf
			(cAliasD14)->(dbCloseArea())
		Else
			If lRet
				Self:oEstEnder:oEndereco:SetArmazem(Self:oMovEndOri:GetArmazem())
				Self:oEstEnder:oEndereco:SetEnder(Self:oMovEndOri:GetEnder())
				Self:oEstEnder:oProdLote:SetArmazem(Self:oMovPrdLot:GetArmazem())
				Self:oEstEnder:oProdLote:SetPrdOri(Self:oMovPrdLot:GetPrdOri())   // Produto Origem
				Self:oEstEnder:oProdLote:SetProduto(Self:oMovPrdLot:GetProduto())
				Self:oEstEnder:oProdLote:SetLoteCtl(Self:oMovPrdLot:GetLoteCtl())
				Self:oEstEnder:oProdLote:SetNumLote(Self:oMovPrdLot:GetNumLote())
				Self:oEstEnder:oProdLote:SetNumSer(Self:oMovPrdLot:GetNumSer())
				Self:oEstEnder:SetIdUnit(Self:GetIdUnit())
				Self:oEstEnder:SetTipUni(Self:GetTipUni())
				If Self:oEstEnder:LoadData()
					nSaldoPrd := Self:oEstEnder:GetQtdEst() - ( Self:oEstEnder:GetQtdEmp() + Self:oEstEnder:GetQtdBlq() )
					nSaldoPRE := Self:oEstEnder:GetQtdEPr()
					nSaldoPRS := Self:oEstEnder:GetQtdSPr()
					// Utiliza o saldo descontando a saida prevista
					If (Iif(lMovEst,QtdComp(nSaldoPrd),QtdComp(nSaldoPrd - Iif(lConsMov,(nSaldoPRS-Self:nQuant),nSaldoPRS))) < QtdComp(Self:nQuant))
						If QtdComp(nSaldoPRE) > 0 .Or. QtdComp(nSaldoPRS) > 0
							Self:cErro := WmsFmtMsg(STR0016,{{"[VAR01]",Self:oMovPrdLot:GetProduto()},{"[VAR02]",Self:oMovEndOri:GetEnder()}})  // Existem atividades a executar que comprometem o saldo do produto [VAR01] no endereço [VAR02].
							Self:cErro += CRLF+WmsFmtMsg(STR0011,{{"[VAR01]",Transf(nSaldoPrd,PesqPictQt('D12_QTDMOV',14))}})                   // Endereço possui saldo de [VAR01].
							Self:cErro += CRLF+WmsFmtMsg(STR0012,{{"[VAR01]",Transf(nSaldoPRE,PesqPictQt('D12_QTDMOV',14))}})                   // Entrada prevista de [VAR01].
							Self:cErro += CRLF+WmsFmtMsg(STR0015,{{"[VAR01]",Transf(nSaldoPRS,PesqPictQt('D12_QTDMOV',14))}})                   // Saída prevista de [VAR01].
						Else
							Self:cErro := WmsFmtMsg(STR0017,{{"[VAR01]",Self:oMovPrdLot:GetProduto()},{"[VAR02]",Self:oMovEndOri:GetEnder()}})  // Saldo do produto [VAR01] no endereço [VAR02] insuficiente para movimentação.
							Self:cErro += CRLF+WmsFmtMsg(STR0011,{{"[VAR01]",Transf(nSaldoPrd,PesqPictQt('D12_QTDMOV',14))}})                   // Endereço possui saldo de [VAR01].
						EndIf
						lRet := .F.
					EndIf
				Else
					Self:cErro := STR0038  //Não foi encontrado o saldo em estoque com as informações: 
					Self:cErro += CRLF+WmsFmtMsg(STR0039,{{"[VAR01]",Self:oMovEndOri:GetEnder()}})   //Endereço: [VAR01]
					Self:cErro += CRLF+WmsFmtMsg(STR0040,{{"[VAR01]",Self:oMovPrdLot:GetProduto()}}) //Produto: [VAR01]
					Self:cErro += CRLF+WmsFmtMsg(STR0041,{{"[VAR01]",Self:oMovPrdLot:GetLoteCtl()}}) //Lote: [VAR01]
					Self:cErro += CRLF+WmsFmtMsg(STR0042,{{"[VAR01]",Self:oMovPrdLot:GetNumLote()}}) //Sub-lote: [VAR01]
					Self:cErro += CRLF+WmsFmtMsg(STR0043,{{"[VAR01]",Self:GetIdUnit()}})             //Unitizador: [VAR01]
					lRet := .F.
				EndIf
			EndIf
			// Analisa empenho do lote
			If lRet .And. Self:oMovServic:ChkTransf() .And. !(Self:oMovEndOri:GetArmazem() == Self:oMovEndDes:GetArmazem()) .And. Self:oMovEndOri:GetTipoEst() <> 7
				If !Self:ChkEstPrd(lMovEst,lConsMov,Self:oMovEndOri:GetArmazem(),Self:oMovPrdLot:GetProduto(),Self:oMovPrdLot:GetLoteCtl(),Self:oMovPrdLot:GetNumLote(),Self:nQuant)
					Self:cErro := WmsFmtMsg(STR0045,{{"[VAR01]",Self:oMovPrdLot:GetProduto()},{"[VAR02]",Self:oMovEndOri:GetArmazem()},{"[VAR03]",Self:oMovEndOri:GetEnder()}})  // Existem reservas e/ou empenhos que comprometem o saldo do produto [VAR01] no armazém [VAR02] e endereço [VAR03].
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf
Return lRet

METHOD ChkEndDes(lConsMov,lConsCap) CLASS WMSDTCMovimentosServicoArmazem
Local lRet       := .T.
Local nCapEnder  := 0
Local oEstFis    := WMSDTCEstruturaFisica():New()
Local lPercOcup  := .F.
Local cTipEstVld := "3|5|7|8"
Local nSaldoPrd  := 0
Local nSaldoPRF  := 0
Local nSaldoD14  := 0
Local nSaldoRF   := 0
Local oProdZona  := Nil
Local oTrfUnitiz := Nil
Local oEndUnitiz := Nil
Local aRet       := {}
Local nPesoEnd   := 0
Local nVolEnd    := 0
Local nPesoItem  := 0
Local nVolItem   := 0
Local cAliasD14  := ""
Local cQuery     := "" 
Default lConsMov := .F.
Default lConsCap := .T.

	If Self:oMovEndDes:LoadData(Nil,.T.)
		If Self:oMovEndDes:GetStatus() == "3" // Endereço bloqueado
			Self:cErro := WmsFmtMsg(STR0005,{{"[VAR01]",Self:oMovEndDes:GetEnder()}}) // Endereço destino [VAR01] está bloqueado.
			lRet := .F.
		EndIf
		If Self:oMovEndDes:GetStatus() == "4" // Endereço com bloqueio de entrada
			Self:cErro := WmsFmtMsg(STR0023,{{"[VAR01]",Self:oMovEndDes:GetEnder()}}) // Endereço destino [VAR01] está com bloqueio de entrada.
			lRet := .F.
		EndIf
		If Self:oMovEndDes:GetStatus() == "6" // Endereço com bloqueio de inventário
			Self:cErro := WmsFmtMsg(STR0024,{{"[VAR01]",Self:oMovEndDes:GetEnder()}}) // Endereço destino [VAR01] está com bloqueio de inventário.
			lRet := .F.
		EndIf
	Else
		Self:cErro := Self:oMovEndDes:GetErro() // Erro do LoadData
		lRet := .F.
	EndIf
	If lRet
		oEstFis:SetEstFis(Self:oMovEndDes:GetEstFis())
		If !oEstFis:LoadData()
			Self:cErro := WmsFmtMsg(STR0006,{{"[VAR01]",Self:oMovEndDes:GetEstFis()}}) // Estrutura física [VAR01] não cadastrada. (DC8)
			lRet := .F.
		EndIf
	EndIf
	If lRet .And. !Empty(Self:oMovEndDes:GetProduto())
		If !Self:IsMovUnit()
			If !(Self:oMovEndDes:GetProduto() == Self:oMovPrdLot:GetProduto())
				Self:cErro := WmsFmtMsg(STR0046,{{"[VAR01]",Self:oMovEndDes:GetEnder()},{"[VAR02]",Self:oMovEndDes:GetProduto()}}) // Endereço [VAR01] exclusivo para o produto [VAR02]!
				lRet := .F.
			EndIf
		Else
			cQuery := "SELECT 1"
			cQuery +=  " FROM "+RetSqlName("D14")+" D14"
			cQuery += " WHERE D14.D14_FILIAL = '"+xFilial("D14")+"'"
			cQuery +=   " AND D14.D14_IDUNIT = '"+Self:cIdUnitiz+"'"
			cQuery +=   " AND D14.D14_LOCAL  = '"+Self:oMovEndOri:GetArmazem()+"'"
			cQuery +=   " AND D14.D14_ENDER  = '"+Self:oMovEndOri:GetEnder()+"'"
			cQuery +=   " AND D14.D14_PRODUT <> '"+Self:oMovEndDes:GetProduto()+"'"
			cQuery +=   " AND D14.D_E_L_E_T_ = ' '"
			cAliasD14 := GetNextAlias()
			DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasD14,.F.,.T.)
			If (cAliasD14)->(!Eof())
				Self:cErro := WmsFmtMsg(STR0046,{{"[VAR01]",Self:oMovEndDes:GetEnder()},{"[VAR02]",Self:oMovEndDes:GetProduto()}}) // Endereço [VAR01] exclusivo para o produto [VAR02]!.
				lRet := .F.
			EndIf
			(cAliasD14)->(dbCloseArea())
		EndIf
	EndIf
	// Se não deve consultar a capacidade, retorna neste momento
	If lConsCap
		// Valida se tipo de estrutura é picking e reabastecimento
		If lRet .And. oEstFis:GetTipoEst() == '2' .And. Self:oMovServic:ChkReabast()
			cTipEstVld := "2|3|5|7|8"
		EndIf
		If lRet .And. !(oEstFis:GetTipoEst() $ cTipEstVld)
			If !Self:IsMovUnit()
				// Verifica Sequência de Abastecimento
				Self:oMovSeqAbt:SetProduto(Self:oMovPrdLot:GetProduto())
				Self:oMovSeqAbt:SetArmazem(Self:oMovEndDes:GetArmazem())
				Self:oMovSeqAbt:SetEstFis(Self:oMovEndDes:GetEstFis())
				If !Self:oMovSeqAbt:LoadData(2)
					Self:cErro := WmsFmtMsg(STR0007,{{"[VAR01]",Self:oMovPrdLot:GetProduto()},{"[VAR02]",Self:oMovEndDes:GetArmazem()},{"[VAR03]",Self:oMovEndDes:GetEstFis()}}) // Produto [VAR01] não possui sequência de abastecimento para Armazém/Estrutura [VAR02]/[VAR03]. (DC3)
					lRet := .F.
				EndIf
				If lRet
					// Verifica Zona Armazenagem Alternativa
					If Self:oMovPrdLot:GetCodZona() <> Self:oMovEndDes:GetCodZona()
						oProdZona := WMSDTCProdutoZona():New()
						oProdZona:SetProduto(Self:oMovPrdLot:GetProduto())
						oProdZona:SetCodZona(Self:oMovEndDes:GetCodZona())
						If !oProdZona:LoadData()
							Self:cErro := WmsFmtMsg(STR0008,{{"[VAR01]",Self:oMovPrdLot:GetProduto()},{"[VAR02]",Self:oMovEndDes:GetCodZona()}}) // Produto [VAR01] não está cadastrado para a zona armazenagem [VAR02]. (SB5,DCH)
							lRet := .F.
						EndIf
					EndIf
				EndIf
				If lRet
					If !Empty(Self:cUniDes)
						oTrfUnitiz := WMSBCCTransferencia():New()
						// Faz uma referência dos objetos para a nova classe (Temporário)
						oTrfUnitiz:oMovPrdLot := Self:oMovPrdLot
						oTrfUnitiz:oMovEndOri := Self:oMovEndOri
						oTrfUnitiz:oMovEndDes := Self:oMovEndDes
						oTrfUnitiz:oMovSeqAbt := Self:oMovSeqAbt
						oTrfUnitiz:SetUniDes(Self:cUniDes)
						oTrfUnitiz:SetTipUni(Self:cTipUni)
						oTrfUnitiz:SetQuant(Self:nQuant)
						If !(lRet := oTrfUnitiz:CanUnitPar(lConsMov))
							Self:cErro := STR0033 //"O endereço não pode receber o saldo do movimento. Motivo:"
							Self:cErro += CRLF + oTrfUnitiz:GetErro()
						EndIf
						// Retira as referências dos objetos
						oTrfUnitiz:oMovPrdLot := Nil
						oTrfUnitiz:oMovEndOri := Nil
						oTrfUnitiz:oMovEndDes := Nil
						oTrfUnitiz:oMovSeqAbt := Nil
						oTrfUnitiz:Destroy()
					Else
						// Se o destino for armazém unitizado, realiza as validações de capacidade (peso e volume)
						If Self:oMovEndDes:IsArmzUnit()
							// Calcula o peso e volume dos itens contidos no endereço
							aRet     := WmsCalcEnd(Self:oMovEndDes:GetArmazem(),Self:oMovEndDes:GetEnder())
							nPesoEnd := aRet[1]
							nVolEnd  := aRet[2]
							// Calcula o peso e volume dos itens que estão sendo movimentados
							If !lConsMov
								aRet      := WmsCalcIt(Self:oMovPrdLot:GetProduto(),Self:nQuant)
								nPesoItem := aRet[1]
								nVolItem  := aRet[2]
							EndIf
							// Valida peso máximo do endereço
							If QtdComp(nPesoEnd + nPesoItem) > QtdComp(Self:oMovEndDes:GetCapacid())
								Self:cErro := STR0036 // "Estouro do peso máximo suportado do endereço."
								lRet := .F.
							EndIf
							// Valida volume máximo do endereço
							If lRet .And. QtdComp(nVolEnd + nVolItem) > QtdComp(Self:oMovEndDes:GetCubagem())
								Self:cErro := STR0037 // "Estouro do volume máximo suportado do endereço."
								lRet := .F.
							EndIf
						EndIf
						// Verifica se o endereço utiliza percentual de ocupação
						If lRet
							lPercOcup := WmsChkDCP(Self:oMovEndDes:GetArmazem(),Self:oMovEndDes:GetEnder(),Self:oMovEndDes:GetEstFis(),Self:oMovSeqAbt:GetCodNor(),Self:oMovPrdLot:GetProduto())
							Self:oEstEnder:ClearData()
							Self:oEstEnder:oEndereco:SetArmazem(Self:oMovEndDes:GetArmazem())
							Self:oEstEnder:oEndereco:SetEnder(Self:oMovEndDes:GetEnder())
							Self:oEstEnder:oProdLote:SetArmazem(Self:oMovPrdLot:GetArmazem())
							Self:oEstEnder:oProdLote:SetPrdOri("")
							Self:oEstEnder:oProdLote:SetProduto(Self:oMovPrdLot:GetProduto())
							Self:oEstEnder:oProdLote:SetNumSer(Self:oMovPrdLot:GetNumSer())
							// Saldo do produto
							nSaldoPrd := Self:oEstEnder:ConsultSld(.F.,.F.,.F.,.F.)
							// Saldo Previsto Entrada
							nSaldoPRF := Self:oEstEnder:ConsultSld(.T.,.F.,.F.,.F.) - nSaldoPrd
							// Saldo produto/lote/sublote
							Self:oEstEnder:oProdLote:SetLoteCtl(Self:oMovPrdlot:GetLoteCtl())
							Self:oEstEnder:oProdLote:SetNumLote(Self:oMovPrdLot:GetNumLote())
							nSaldoLT  := Self:oEstEnder:ConsultSld(.T.)
							If lPercOcup
								nSaldoD14 := nSaldoPrd
								nSaldoRF  := nSaldoPRF
							Else
								Self:oEstEnder:oProdLote:SetPrdOri("")
								Self:oEstEnder:oProdLote:SetProduto("")
								Self:oEstEnder:oProdLote:SetLoteCtl("")
								Self:oEstEnder:oProdLote:SetNumLote("")
								// Saldo do endereco
								nSaldoD14 := Self:oEstEnder:ConsultSld(.F.,.F.,.F.,.F.)
								// Saldo Previsto entrada no Endereco
								nSaldoRF  := Self:oEstEnder:ConsultSld(.T.,.F.,.F.,.F.) - nSaldoD14
							EndIf
							nCapEnder := DLQtdNorma(Self:oMovPrdLot:GetProduto(),Self:oMovEndDes:GetArmazem(),Self:oMovEndDes:GetEstFis(),/*cDesUni*/,.T.,Self:oMovEndDes:GetEnder()) // Considerar a qtd pelo nr de unitizadores
							// Deve verificar se a quantidade a transferir não ultrapassa a capacidade do endereço
							If QtdComp(nSaldoD14 + IIf(lConsMov,(nSaldoRF - Self:nQuant),nSaldoRF) + Self:nQuant) > QtdComp(nCapEnder)
								Self:cErro := WmsFmtMsg(STR0009,{{"[VAR01]",Transf(Self:nQuant,PesqPictQt('D12_QTDMOV',14))},{"[VAR02]",Self:oMovEndDes:GetEnder()}}) // Movimentação de [VAR01] para o endereço [VAR02] excedendo a capacidade de armazenagem.
								Self:cErro += CRLF+WmsFmtMsg(STR0010,{{"[VAR01]",Transf(nCapEnder,PesqPictQt('D12_QTDMOV',14))}})                                     // Capacidade total do endereço de [VAR01].
								If nSaldoD14 > 0
									Self:cErro += CRLF+WmsFmtMsg(STR0011,{{"[VAR01]",Transf(nSaldoD14,PesqPictQt('D12_QTDMOV',14))}}) // Endereço possui saldo de [VAR01].
								EndIf
								If nSaldoRF > 0
									Self:cErro += CRLF+WmsFmtMsg(STR0012,{{"[VAR01]",Transf(nSaldoRF,PesqPictQt('D12_QTDMOV',14))}})  // Entrada prevista de [VAR01].
								EndIf
								lRet := .F.
							EndIf
						EndIf
	
						// Se não compartilha endereço, deve verificar se o endereço está em uso por outro produto
						If lRet .And. Self:oMovSeqAbt:GetTipoEnd() != "4"
							If QtdComp(nSaldoPrd + nSaldoPRF) != QtdComp(nSaldoD14 + nSaldoRF)
								Self:cErro := WmsFmtMsg(STR0013,{{"[VAR01]",Self:oMovEndDes:GetEnder()}}) // Endereço [VAR01] em uso por outro produto.
								lRet := .F.
							EndIf
						EndIf
						// Se não compartilha endereço e não endereça produtos de mesmo lote,
						// deve verificar se o endereço está em uso por outro lote
						If lRet .And. Self:oMovSeqAbt:GetTipoEnd() == '3'
							If nSaldoLT != (nSaldoD14 + nSaldoRF) // A consulta de saldo por lote não está sendo feita separadamente, por isso não precisa somar RF
								Self:cErro := WmsFmtMsg(STR0014,{{"[VAR01]",Self:oMovEndDes:GetEnder()}}) // Endereço [VAR01] em uso por outro lote.
								lRet := .F.
							EndIf
						EndIf
					EndIf
				EndIf
			Else
				// Se for validação de movimentação unitizada
				// Cria instância da classe de endereçamento unitizado
				oEndUnitiz := WMSBCCEnderecamentoUnitizado():New()
				// Atribui os dados mínimos para execução da validação
				// Faz uma referência dos objetos para a nova classe (Temporário)
				oEndUnitiz:oMovEndOri := Self:oMovEndOri
				oEndUnitiz:oMovEndDes := Self:oMovEndDes
				oEndUnitiz:oMovSeqAbt := Self:oMovSeqAbt
				oEndUnitiz:SetIdUnit(Iif(Empty(Self:cUniDes),Self:cIdUnitiz,Self:cUniDes))
				oEndUnitiz:SetTipUni(Self:cTipUni)
				// Verifica se o unitizador pode ser armazenado no endereço
				If !(lRet := oEndUnitiz:UnitCanEnd(lConsMov))
					Self:cErro := STR0033 //"O endereço não pode receber o saldo do movimento. Motivo:"
					Self:cErro += CRLF + oEndUnitiz:GetErro()
				EndIf
				// Retira as referências dos objetos
				oEndUnitiz:oMovEndOri := Nil
				oEndUnitiz:oMovEndDes := Nil
				oEndUnitiz:oMovSeqAbt := Nil
				oEndUnitiz:Destroy()
			EndIf
		EndIf
	EndIf
Return lRet

//--------------------------------------------------
/*/{Protheus.doc} ReverseAgl
Estorno de movimentação aglutinada
@author alexsander.correa
@since 13/07/2015
@version 1.0
@return lógico
@param oRelacMov, object, relacionamento do movimento de distribuição
@param lTrocaLote, logical, identifica se é um processo de troca de lote
@type function
/*/
//--------------------------------------------------
METHOD ReverseAgl(oRelacMov,lTrocaLote) CLASS WMSDTCMovimentosServicoArmazem
Local lRet       := .T.
Local cQuery     := ""
Local cAliasQry  := ""
Local cIdDCFEst  := Self:GetIdDCF()
Local cIdMovEst  := Self:GetIdMovto()
Local cIdOpeEst  := Self:GetIdOpera()
Local cNextIdMov := ""
Local oMovEstEnd := Nil
Local oOrdSerOri := Nil
Local oOrdSerAux := Nil

Default lTrocaLote := .F.
	// Ajusta o movimento origem descontando a quantidade a ser estornada
	Self:nQtdOrig  -= oRelacMov:GetQuant()
	Self:nQtdMovto -= oRelacMov:GetQuant()
	If Self:nQtdLida > 0
		Self:nQtdLida  -= oRelacMov:GetQuant()
	EndIf
	// Se está estornando a própria OS aglutinadora, deve atualizar o movimento
	// com a próxima OS aglutinada para esta passar a ser a a OS aglutinadora
	If oRelacMov:GetIdDCF() == cIdDCFEst
		oOrdSerOri := Self:oOrdServ
		oOrdSerAux := WMSDTCOrdemServico():New()
		Self:oOrdServ := oOrdSerAux
		Self:oOrdServ:SetIdDCF(Self:GetNextOri(cIdDCFEst,cIdMovEst,cIdOpeEst))
		Self:oOrdServ:LoadData()
		lRet := Self:AtuNextOri(cIdDCFEst,cIdMovEst,cIdOpeEst,Self:oOrdServ:GetIdDCF())
	EndIf
	//Remove DCR, pois será criada uma nova DCR para a quantidade estornada
	If lRet
		lRet := oRelacMov:DeleteDCR()
	EndIf
	// Atualiza movimento origem
	If lRet
		Self:cAgluti := Iif(Self:HasAgluAti(),"1","2")
		// Se virou um movimento não aglutinado, verifica se existem outros movimentos
		// que não estavam originalmente aglutinados para normalizar o mesmo IDMOVTO
		If Self:cAgluti == "2" .And. Self:cStatus != "1"
			cNextIdMov := Self:GetNextMov()
			If !Empty(cNextIdMov)
				lRet := Self:AtuNextMov(cNextIdMov)
				// Deve obrigatoriamente ficar depois da atualização da DCR - Usa no SELECT
				Self:cIdMovto := cNextIdMov
			EndIf
		EndIf
		If lRet
			Self:UpdateD12()
		EndIf
	EndIf
	// Restaura a referencia original
	If oOrdSerOri != Nil
		Self:oOrdServ := oOrdSerOri
	EndIf
	// Somente recria um novo movimento, caso se tratar de um processo de troca de lote ou se a movimentação original estava executada
	If lRet .And. (lTrocaLote .Or. Self:cStatus == "1")
		// Cria novo movimento considerando com base no origem
		// Contendo as informações do movimentos aglutinado que será
		// Estornado
		// Atribui ordem de serviço
		If oRelacMov:GetIdDCF() <> Self:oOrdServ:GetIdDCF()
			Self:oOrdServ:SetIdDCF(oRelacMov:GetIdDCF())
			Self:oOrdServ:LoadData()
		EndIf
		// Atualiza a aquantidade para o novo movimento gerado
		Self:nQtdOrig   := oRelacMov:GetQuant()
		Self:nQtdMovto  := oRelacMov:GetQuant()
		Self:nQtdLida   := oRelacMov:GetQuant()
		Self:cAgluti    := "1"
		Self:lEstAglu   := .T.
		// Grava novo movimento
		If !Self:RecordD12()
			lRet := .F.
		EndIf
	EndIf

	// Quando o estorno é de um movimento aglutinado deverá ser criado uma nova
	// movimentação de estoque com a quantidade a ser estornada, e a movimentação
	// original deverá ter a quantidade estornada subtraída.
	If lRet .And. Self:cStatus == "1" .And. Self:IsUpdEst()
		oMovEstEnd := WMSDTCMovimentosEstoqueEndereco():New(.F.)
		cQuery := "SELECT D13.R_E_C_N_O_ RECNOD13"
		cQuery +=  " FROM "+RetSqlName('D13')+" D13"
		cQuery += " WHERE D13.D13_FILIAL = '"+xFilial("D13")+"'"
		cQuery +=   " AND D13.D13_IDDCF  = '"+cIdDCFEst+"'"
		cQuery +=   " AND D13.D13_IDMOV  = '"+cIdMovEst+"'"
		cQuery +=   " AND D13.D13_IDOPER = '"+cIdOpeEst+"'"
		cQuery +=   " AND D13.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
		// Subtrai quantidade cortada do DCR
		While (cAliasQry)->(!Eof())
			If oMovEstEnd:GoToD13((cAliasQry)->RECNOD13)
				oMovEstEnd:SetQtdEst(oMovEstEnd:nQtdEst - oRelacMov:GetQuant())
				// Se encontrou uma OS para ser a nova OS aglutinadora
				If oOrdSerAux != Nil
					oMovEstEnd:SetDocto(oOrdSerAux:GetDocto())
					oMovEstEnd:SetSerie(oOrdSerAux:GetSerie())
					oMovEstEnd:SetCliFor(oOrdSerAux:GetCliFor())
					oMovEstEnd:SetLoja(oOrdSerAux:GetLoja())
					oMovEstEnd:SetNumSeq(oOrdSerAux:GetNumSeq())
					oMovEstEnd:SetIdDCF(oOrdSerAux:GetIdDCF())
				EndIf
				oMovEstEnd:UpdateD13()
				// Cria novo D13 com o restante da quantidade para posterior convocacao pelo radio frequencia.
				oMovEstEnd:AssignD12(Self)
				oMovEstEnd:SetQtdEst(oRelacMov:GetQuant())
				oMovEstEnd:RecordD13()
			EndIf
			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(dbCloseArea())
	EndIf
Return lRet

METHOD VldEndInv() CLASS WMSDTCMovimentosServicoArmazem
Local lRet := .T.
Local oEndAux := WMSDTCEndereco():New()

	If Self:oMovServic:GetTipo() == "1" // Movimento de entrada
		// Seta o armazem destino do inventario
		Self:SetArmInv(Self:oMovEndDes:GetArmazem())
		oEndAux:SetArmazem(Self:oMovEndDes:GetArmazem())

	ElseIf Self:oMovServic:GetTipo() $ "2|3" // Movimento de saida/interno
		// Seta o armazem origem do inventario
		Self:SetArmInv(Self:oMovEndOri:GetArmazem())
		oEndAux:SetArmazem(Self:oMovEndOri:GetArmazem())
	EndIf

	oEndAux:SetEnder(Self:GetEndInv())
	If oEndAux:LoadData()
		If oEndAux:GetStatus() == "6"
			Self:cErro := WmsFmtMsg(STR0025,{{"[VAR01]",cEndereco}})// Endereço [VAR01] está bloqueado para inventário.
			lRet := .F.
		EndIf
	Else
		Self:cErro := oEndAux:GetErro()
		lRet := .F.
	EndIf

	If !lRet .And. Self:oMovServic:GetTipo() == "3" .And. Self:oMovEndOri:GetArmazem() != Self:oMovEndDes:GetArmazem()
		// Seta o armazem destino do inventario
		Self:SetArmInv(Self:oMovEndDes:GetArmazem())
		oEndAux:SetArmazem(Self:oMovEndDes:GetArmazem())

		oEndAux:SetEnder(Self:GetEndInv())
		If oEndAux:LoadData()
			If oEndAux:GetStatus() == "6"
				Self:cErro := WmsFmtMsg(STR0025,{{"[VAR01]",cEndereco}}) // Endereço [VAR01] está bloqueado para inventário.
				lRet := .F.
			Else
				lRet := .T.
			EndIf
		Else
			Self:cErro := oEndAux:GetErro()
			lRet := .F.
		EndIf
	EndIf

Return lRet

METHOD HasAgluAti() CLASS WMSDTCMovimentosServicoArmazem
Local aAreaDCR  := GetArea()
Local lRet      := .F.
Local cQuery    := ""
Local cAliasDCR := GetNextAlias()
	cQuery := "SELECT COUNT(DCR.DCR_IDDCF) NRO_COUNT"
	cQuery +=  " FROM " +RetSqlName("DCR")+" DCR"
	cQuery += " WHERE DCR.DCR_FILIAL = '"+xFilial("DCR")+"'"
	cQuery +=   " AND DCR.DCR_IDORI  = '"+Self:GetIdDCF()+"'"
	cQuery +=   " AND DCR.DCR_IDMOV  = '"+Self:cIdMovto+"'"
	cQuery +=   " AND DCR.DCR_IDOPER = '"+Self:cIdOpera+"'"
	cQuery +=   " AND DCR.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasDCR,.F.,.T.)
	TcSetField(cAliasDCR,'NRO_COUNT','N',5,0)
	If (cAliasDCR)->(!Eof())
		lRet := ((cAliasDCR)->NRO_COUNT > 1)
	EndIf
	(cAliasDCR)->(dbCloseArea())
	RestArea(aAreaDCR)
Return lRet

/*----------------------------------------------------------------------
---ChkEndD0F
---Método utilizado para verificar se o endereço destino está definido
---felipe.m 22/04/2016
----------------------------------------------------------------------*/
METHOD ChkEndD0F() CLASS WMSDTCMovimentosServicoArmazem
Local lRet       := .T.
Local aAreaD0F   := D0F->(GetArea())
Local cAliasD0F  := ""
Local cQuery     := ""
	// Busca as informações do documento de montagem/desmontagem
	cAliasD0F := GetNextAlias()
	cQuery := " SELECT D0F.D0F_ENDER"
	cQuery +=   " FROM "+RetSqlName("SD1")+" SD1, "+RetSqlName("D06")+" D06, "+RetSqlName("D0F")+" D0F"
	cQuery +=  " WHERE SD1.D1_FILIAL = '"+xFilial("SD1")+"'"
	cQuery +=    " AND SD1.D1_NUMSEQ = '"+Self:oOrdServ:GetNumSeq()+"'"
	cQuery +=    " AND SD1.D_E_L_E_T_ = ' '"
	cQuery +=    " AND D06.D06_FILIAL = '"+xFilial("D06")+"'"
	cQuery +=    " AND D06.D06_CODDIS = SD1.D1_CODDIS"
	cQuery +=    " AND D06.D_E_L_E_T_ = ' '"
	cQuery +=    " AND D0F.D0F_FILIAL = '"+xFilial("D0F")+"'"
	cQuery +=    " AND D0F.D0F_CODDIS = D06.D06_CODDIS"
	cQuery +=    " AND D0F.D0F_DOC = SD1.D1_DOC"
	cQuery +=    " AND D0F.D0F_SERIE = SD1.D1_SERIE"
	cQuery +=    " AND D0F.D0F_FORNEC = SD1.D1_FORNECE"
	cQuery +=    " AND D0F.D0F_LOJA = SD1.D1_LOJA"
	cQuery +=    " AND D0F.D0F_PRODUT = SD1.D1_COD"
	cQuery +=    " AND D0F.D0F_ITEM = SD1.D1_ITEM"
	cQuery +=    " AND D0F.D0F_LOCAL = '"+Self:oMovEndDes:GetArmazem() +"'"
	cQuery +=    " AND D0F.D0F_ENDER = '"+Self:oMovEndDes:GetEnder() +"'"
	cQuery +=    " AND D0F.D_E_L_E_T_ = ' '"
	cQuery +=  " ORDER BY D0F.D0F_ENDER"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasD0F,.F.,.T.)
	lRet := !(cAliasD0F)->(!Eof())
	(cAliasD0F)->(dbCloseArea())
	RestArea(aAreaD0F)
Return lRet

//----------------------------------------------------------------------
METHOD GetNextOri(cIdDCF,cIdMovto,cIdOpera) CLASS WMSDTCMovimentosServicoArmazem
Local cNextOri   := ""
Local cAliasDCR  := ""
Local cQuery     := ""

	cQuery := "SELECT MIN(DCR.DCR_IDDCF) DCR_IDDCF"
	cQuery +=  " FROM "+RetSqlName("DCR")+" DCR"
	cQuery += " WHERE DCR.DCR_FILIAL = '"+xFilial("DCR")+"'"
	cQuery +=   " AND DCR.DCR_IDORI  = '"+cIdDCF+"'"
	cQuery +=   " AND DCR.DCR_IDMOV  = '"+cIdMovto+"'"
	cQuery +=   " AND DCR.DCR_IDOPER = '"+cIdOpera+"'"
	cQuery +=   " AND DCR.DCR_IDDCF <> '"+cIdDCF+"'"
	cQuery +=   " AND DCR.D_E_L_E_T_ = ' '"
	cAliasDCR := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasDCR,.F.,.T.)
	If (cAliasDCR)->(!Eof())
		cNextOri := (cAliasDCR)->DCR_IDDCF
	EndIf
	(cAliasDCR)->(dbCloseArea())
	If Empty(cNextOri)
		cNextOri := cIdDCF
	EndIf
Return cNextOri

//----------------------------------------------------------------------
METHOD AtuNextOri(cIdDCF,cIdMovto,cIdOpera,cNextOri) CLASS WMSDTCMovimentosServicoArmazem
Local lRet   := .T.
Local cQuery := ""

	cQuery := "UPDATE "+RetSqlName("DCR")
	cQuery +=   " SET DCR_IDORI  = '"+cNextOri+"'"
	cQuery += " WHERE DCR_FILIAL = '"+xFilial("DCR")+"'"
	cQuery +=   " AND DCR_IDORI  = '"+cIdDCF+"'"
	cQuery +=   " AND DCR_IDMOV  = '"+cIdMovto+"'"
	cQuery +=   " AND DCR_IDOPER = '"+cIdOpera+"'"
	cQuery +=   " AND DCR_IDDCF <> '"+cIdDCF+"'"
	cQuery +=   " AND D_E_L_E_T_ = ' '"
	If !(lRet := (TcSQLExec(cQuery) >= 0))
		Self:cErro := STR0035 // "Problema ao atualizar o ID origem para os relacionamentos do movimento."
	EndIf
Return lRet

//----------------------------------------------------------------------
// Busca o IDMOVTO do movimento dos outros movimentos não aglutinados
// e altera no movimento e ajusta a DCR correspondente.
METHOD GetNextMov() CLASS WMSDTCMovimentosServicoArmazem
Local aAreaAnt  := GetArea()
Local lRet      := .T.
Local cQuery    := ""
Local cAliasD12 := GetNextAlias()
Local cNextIdMov:= ""

	cQuery := "SELECT D12_IDMOV"
	cQuery += "  FROM "+RetSqlName("D12")
	cQuery += " WHERE D12_FILIAL = '"+xFilial("D12")+"'"
	cQuery += "   AND D12_DOC    = '"+Self:oOrdServ:GetDocto()+"'"
	cQuery += "   AND D12_SERIE  = '"+Self:oOrdServ:GetSerie()+"'"
	cQuery += "   AND D12_CLIFOR = '"+Self:oOrdServ:GetCliFor()+"'"
	cQuery += "   AND D12_LOJA   = '"+Self:oOrdServ:GetLoja()+"'"
	cQuery += "   AND D12_SERVIC = '"+Self:oMovServic:GetServico()+"'"
	cQuery += "   AND D12_TAREFA = '"+Self:oMovServic:GetTarefa()+"'"
	cQuery += "   AND D12_PRODUT = '"+Self:oMovPrdLot:GetProduto()+"'"
	cQuery += "   AND D12_PRDORI = '"+Self:oMovPrdLot:GetPrdOri()+"'"
	cQuery += "   AND D12_LOTECT = '"+Self:oMovPrdLot:GetLoteCtl()+"'"
	cQuery += "   AND D12_NUMLOT = '"+Self:oMovPrdLot:GetNumLote()+"'"
	cQuery += "   AND D12_LOCORI = '"+Self:oMovEndOri:GetArmazem()+"'"
	cQuery += "   AND D12_ENDORI = '"+Self:oMovEndOri:GetEnder()+"'"
	cQuery += "   AND D12_LOCDES = '"+Self:oMovEndDes:GetArmazem()+"'"
	cQuery += "   AND D12_ENDDES = '"+Self:oMovEndDes:GetEnder()+"'"
	cQuery += "   AND D12_ORDATI <> '"+Self:oMovTarefa:GetOrdem()+"'"
	cQuery += "   AND D12_IDMOV  <> '"+Self:cIdMovto+"'"
	cQuery += "   AND D12_IDUNIT = '"+Self:cIdUnitiz+"'"
	cQuery += "   AND D12_UNIDES = '"+Self:cUniDes+"'"
	cQuery += "   AND D12_IDDCF  = '"+Self:GetIdDCF()+"'"
	cQuery += "   AND D12_QTDMOV = "+cValToChar(Self:nQtdMovto)
	cQuery +=   " AND D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY D12_IDMOV"
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasD12,.F.,.T.)
	If (cAliasD12)->(!Eof())
		cNextIdMov := (cAliasD12)->D12_IDMOV
	EndIf
	(cAliasD12)->(DbCloseArea())

	RestArea(aAreaAnt)
Return cNextIdMov

//-----------------------------------------------------------------------------
METHOD AtuNextMov(cNextIdMov) CLASS WMSDTCMovimentosServicoArmazem
	cQuery := "UPDATE "+RetSqlName("DCR")
	cQuery +=   " SET DCR_IDMOV  = '"+cNextIdMov+"'"
	cQuery += " WHERE DCR_FILIAL = '"+xFilial("DCR")+"'"
	cQuery +=   " AND DCR_IDORI  = '"+Self:GetIdDCF()+"'"
	cQuery +=   " AND DCR_IDMOV  = '"+Self:cIdMovto+"'"
	cQuery +=   " AND DCR_IDOPER = '"+Self:cIdOpera+"'"
	cQuery +=   " AND DCR_IDDCF  = '"+Self:GetIdDCF()+"'"
	cQuery +=   " AND D_E_L_E_T_ = ' '"
	If !(lRet := (TcSQLExec(cQuery) >= 0))
		Self:cErro := STR0044 //Problema ao atualizar o ID movimento para os relacionamentos do movimento.
	EndIf
Return lRet

//-----------------------------------------------------------------------------
METHOD IsMovUnit() CLASS WMSDTCMovimentosServicoArmazem
Return (Empty(Self:oMovPrdLot:GetProduto()) .And. (!Empty(Self:cIdUnitiz) .Or. !Empty(Self:cUniDes)))

//-----------------------------------------------------------------------------
METHOD DesNotUnit() CLASS WMSDTCMovimentosServicoArmazem
Return (Self:oMovEndDes:GetTipoEst() == 2 .Or. Self:oMovEndDes:GetTipoEst() == 7 .Or. (Self:oMovEndDes:GetTipoEst() == 5 .And. (Self:oMovServic:ChkSepara() .Or. Self:oOrdServ:GetOrigem() == "D0A")))

//-----------------------------------------------------------------------------
METHOD OriNotUnit() CLASS WMSDTCMovimentosServicoArmazem
Return (Self:oMovEndOri:GetTipoEst() == 2 .Or. Self:oMovEndOri:GetTipoEst() == 7 .Or. (Self:oMovEndOri:GetTipoEst() == 5 .And. (Self:oMovServic:ChkSepara() .Or. Self:oOrdServ:GetOrigem() == "D0A")))

/*/{Protheus.doc} UpdLote
Atualiza lote da movimentação
@author Squad WMS
@since 26/01/2018
@version 1.0
@return lógico
@param cNovoLote, characters, novo lote para a movimentação
@param cNovoSbLot, characters, novo sub-lote para a movimentação
@param cNovoUnit, characters, novo unitizador para a movimentação
@param cNovoEnder, characters, novo endereço para a movimentação
@type method
/*/
METHOD UpdLote(cNovoLote,cNovoSbLot,cNovoUnit,cNovoEnder) CLASS WMSDTCMovimentosServicoArmazem
Local lRet      := .T.
Local oEtiqUnit := Nil
Local cQuery    := ""
Local cAliasQry := Nil
Local nNewRecno := 0
Default cNovoEnder := ""
Default cNovoUnit  := ""
	// Atualiza liberação do pedido
	If Self:oOrdServ:GetOrigem() == "SC9"
		lRet := Self:UpdPedido(cNovoLote,cNovoSbLot)
		If lRet
			// Atualização das movimentações:
			// Remove a quantidade do lote antigo
			// Montagem de Volume
			// Distribuição Separação
			// Conferencia Expedição
			lRet := Self:UpdMovExp()
		EndIf
	ElseIf Self:oOrdServ:GetOrigem() == 'SD4'
		nQtdSld := (Self:GetQtdMov() / Self:oMovPrdLot:oProduto:oProdComp:GetQtMult())
		cQuery := "SELECT SD4.R_E_C_N_O_ RECNOSD4"
		cQuery +=  " FROM " +RetSqlName("SD4")+ " SD4"
		cQuery += " WHERE SD4.D4_FILIAL = '"+xFilial("SD4")+"'"
		cQuery += "   AND SD4.D4_LOTECTL = '"+Self:oMovPrdLot:GetLoteCtl()+"'"
		cQuery += "   AND SD4.D4_NUMLOTE = '"+Self:oMovPrdLot:GetNumLote()+"'"
		cQuery +=   " AND SD4.D4_IDDCF = '"+Self:GetIdDCF()+"'"
		cQuery +=   " AND SD4.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
		Do While (cAliasQry)->(!Eof()) .And. nQtdSld > 0
			SD4->(dbGoTo((cAliasQry)->RECNOSD4))
			WmsDivSD4(SD4->D4_COD,;
					Self:oMovEndDes:GetArmazem(),;
					SD4->D4_OP,;
					SD4->D4_TRT,;
					cNovoLote,;
					cNovoSbLot,;
					Nil,;
					nQtdSld,;
					Nil,;
					cNovoEnder,;
					Self:GetIdDCF(),;
					.F.,;
					SD4->(Recno()),;
					Nil,;
					@nNewRecno,;
					.F.)
			SD4->(dbGoTo(nNewRecno))
			// Ajusta empenho SB8
			lRet := Self:oOrdServ:UpdEmpSB8("-",Self:oMovPrdLot:GetPrdOri(),Self:oMovPrdLot:GetArmazem(),Self:oMovPrdLot:GetLoteCtl(),Self:oMovPrdLot:GetNumLote(),nQtdSld)
			If lRet
				lRet := Self:oOrdServ:UpdEmpSB8("+",Self:oMovPrdLot:GetPrdOri(),Self:oMovPrdLot:GetArmazem(),cNovoLote,cNovoSbLot,nQtdSld)
			EndIf
			nQtdSld -= SD4->D4_Quant
			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(dbCloseArea())
	EndIf
	If lRet
		// Ajusta lote da movimentação D12
		lRet := Self:UpdMovLote(cNovoLote,cNovoSbLot,cNovoUnit,cNovoEnder)
	EndIf
	If lRet
		// Ajuste estoque por endereço do lote anterior
		Self:HitMovEst()
		// Ajuste estoque por endereço do lote destino
		Self:oMovPrdLot:SetLoteCtl(cNovoLote)
		Self:oMovPrdLot:SetNumLote(cNovoSbLot)
		Self:SetIdUnit(cNovoUnit)
		If !Empty(cNovoEnder)
			Self:oMovEndOri:SetEnder(cNovoEnder)
		EndIf
		//Carrega tipo do unitizador
		oEtiqUnit := WMSDTCEtiquetaUnitizador():New()
		oEtiqUnit:SetIdUnit(cNovoUnit)
		If oEtiqUnit:LoadData()
			Self:SetTipUni(oEtiqUnit:GetTipUni())
		Else
			Self:SetTipUni("")
		EndIf
		Self:MakeOutput()
		Self:MakeInput()
	EndIf
	If lRet .And. Self:oOrdServ:GetOrigem() == "SC9"
		// Atualização das movimentações:
		// Ajusta a quantidade do lote selecionado
		// Montagem de Volume
		// Distribuição Separação
		// Conferencia Expedição
		lRet := Self:UpdExpedic(.T.)
	EndIf
Return lRet

/*/{Protheus.doc} UpdPedido
Troca de lote do pedido de venda (SC9)
@author Squad WMS
@since 28/01/2018
@version 1.0
@return lógico
@param cNovoLote, characters, novo lote para a movimentação
@param cNovoSbLot, characters, novo sub-lote para a movimentação
@type method
/*/
METHOD UpdPedido(cNovoLote,cNovoSbLot) CLASS WMSDTCMovimentosServicoArmazem
Local aAreaAnt  := GetArea()
Local aAreaSB2  := SB2->(GetArea())
Local aAreaSC9  := SC9->(GetArea())
Local nQtdMov   := Self:nQtdMovto
Local nQtdOrig  := Self:nQtdMovto
Local nNewRecno := 0
Local lRet      := .T.
Local lWmsNew   := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local lWmsAglu  := SuperGetMV('MV_WMSAGLU',.F.,.F.) .Or. lWmsNew //-- Aglutina itens da nota fiscal de saida com mesmo Lote e Sub-Lote
Local lDlEstC9  := .T.
Local lDelSC9   := .F.
Local cQuery    := ""
Local cAliasQry := ""
Local aLocaliz  := {}
Local aDlEstC9  := {}
	// P.E. para manipular o estorno da liberação do pedido
	// O retorno deve ser .T. para que o processo não tome o padrão
	If ExistBlock("DLVESTC9")
		aDlEstC9 := ExecBlock("DLVESTC9",.F.,.F.,{lDlEstC9,{oMovimento:GetRecno()},nQtdOrig,nQtdMov,.F.})
		If ValType(aDlEstC9) == "A" .And. Len(aDlEstC9) >= 2
			lDlEstC9 := aDlEstC9[1]
			lRet     := aDlEstC9[2]
		EndIf
	EndIf

	If lDlEstC9
		// Busca todos os documentos aglutinados ao movimento
		cQuery := " SELECT DCR.DCR_QUANT,"
		cQuery +=        " DCR.DCR_IDDCF,"
		cQuery +=        " SC9.C9_CARGA,"
		cQuery +=        " SC9.C9_PEDIDO,"
		cQuery +=        " SC9.C9_ITEM,"
		cQuery +=        " SC9.C9_QTDLIB,"
		cQuery +=        " SC9.C9_SEQUEN,"
		cQuery +=        " SC9.R_E_C_N_O_ RECNOSC9"
		cQuery +=   " FROM "+RetSqlName("DCR")+" DCR"
		cQuery +=  " INNER JOIN "+RetSqlName("SC9")+" SC9 "
		cQuery +=     " ON SC9.C9_FILIAL  = '"+xFilial("SC9")+"'"
		cQuery +=    " AND SC9.C9_IDDCF   = DCR.DCR_IDDCF"
		cQuery +=    " AND SC9.C9_LOTECTL = '"+Self:oMovPrdLot:GetLoteCtl()+"'"
		cQuery +=    " AND SC9.C9_NUMLOTE = '"+Self:oMovPrdLot:GetNumLote()+"'"
		cQuery +=    " AND SC9.C9_BLWMS   = '01'"
		cQuery +=    " AND SC9.C9_BLEST   = '  '"
		cQuery +=    " AND SC9.C9_BLCRED  = '  '"
		cQuery +=    " AND SC9.D_E_L_E_T_ = ' '"
		cQuery +=  " WHERE DCR.DCR_FILIAL = '"+xFilial("DCR")+"'"
		cQuery +=    " AND DCR.DCR_IDMOV  = '"+Self:cIdMovto+"'"
		cQuery +=    " AND DCR.DCR_IDOPER = '"+Self:cIdOpera+"'"
		cQuery +=    " AND DCR.DCR_IDORI  = '"+Self:oOrdServ:GetIdDCF()+"'"
		cQuery +=    " AND DCR.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
		While (cAliasQry)->(!EoF()) .And. lRet .And. nQtdMov > 0
			If QtdComp(nQtdMov) >= QtdComp((cAliasQry)->C9_QTDLIB)
				//Posiciona na SC9 que terá o lote alterado
				SC9->(DbGoTo((cAliasQry)->RECNOSC9))
				nQtdMov -= (cAliasQry)->C9_QTDLIB
			Else // Realiza quebra da SC9 para gravar novo lote informado
				lRet := WmsDivSC9((cAliasQry)->C9_CARGA,;                     //cCarga
								  (cAliasQry)->C9_PEDIDO,;                    //cPedido
								  (cAliasQry)->C9_ITEM,;                      //cItem
								  Self:oMovPrdLot:GetProduto(),;        //cProduto
								  Self:oOrdServ:oServico:GetServico(),; //cServico
								  Self:oMovPrdLot:GetLoteCtl(),;        //cLoteCtl
								  Self:oMovPrdLot:GetNumLote(),;        //cNumLote
								  Self:oMovPrdLot:GetNumSer(),;         //cNumSerie
								  (cAliasQry)->DCR_QUANT,;                    //nQuant
								  /*nQuant2UM*/,;                             //nQuant2UM
								  Self:oMovEndOri:GetArmazem(),;        //cLocal
								  Self:oMovEndOri:GetEnder(),;          //cEndereco
								  (cAliasQry)->DCR_IDDCF,;                    //cIdDCF
								  .F.,;                                       //lWmsLibSC9
								  .F.,;                                       //lGeraEmp
								  "01",;                                      //cBlqWMS
								  (cAliasQry)->RECNOSC9,;                     //nRecSC9
								  Nil,;                                       //cRomaneio
								  (cAliasQry)->C9_SEQUEN,;                    // cSeqSC9
								  .F.,;                                       //lLotVazio
								  @nNewRecno)                                 //Novo Recno da SC9 criada
				//Posiciona na SC9 que terá o lote alterado
				SC9->(DbGoTo(nNewRecno))
				//Atualiza quantidade movimentada restante
				nQtdMov -= (cAliasQry)->DCR_QUANT
			EndIf
			//Altera lote SC9
			If lRet
				// Itens Pedidos de Vendas
				SC6->(DbSetOrder(1))
				SC6->(MsSeek(xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM))
				// 2.Estorno do SC9 / Estorno da Liberacao de 6.Estoque/4.Credito do SC9 / WMS
				aLocaliz := {{ "","","","",SC9->C9_QTDLIB,,Ctod(""),"","","",SC9->C9_LOCAL,0}}
				MaAvalSC9("SC9",2,aLocaliz,Nil,Nil,Nil,Nil,Nil,Nil,,.F.,,.F.)
				//-- Atualiza quantidade liberada
				RecLock("SC9",.F.)
				SC9->C9_BLEST   := " "
				SC9->C9_BLCRED  := " "
				SC9->C9_LOTECTL := cNovoLote
				SC9->C9_NUMLOTE := cNovoSbLot
				
				SC9->(MsUnlock())
				SC9->(DbCommit()) //-- Força enviar para o banco a atualização da SC9
				//-- Atualiza Credito
				If !lDelSC9
					aLocaliz := {{ "","","","",SC9->C9_QTDLIB,,Ctod(""),"","","",SC9->C9_LOCAL,0}}
					MaAvalSC9("SC9",1,aLocaliz,Nil,Nil,Nil,Nil,Nil,Nil,,.F.,,.F.)
				EndIf
				//Verifica se pode aglutinar a SC9 criada
				If lWmsAglu
					If WmsAgluSC9(SC9->C9_CARGA,;                     //cCarga
					              SC9->C9_PEDIDO,;                    //cPedido
					              SC9->C9_ITEM,;                      //cItem
					              Self:oMovPrdLot:GetProduto(),;//cProduto
					              cNovoLote,;                         //cLoteCtl
					              cNovoSbLot,;                        //cNumLote
					              Self:oMovPrdLot:GetNumSer(),; //cNumSerie
					              (cAliasQry)->DCR_QUANT,;            //nQuant
					              Nil,;                               //nQuant2UM
					              Self:oMovEndOri:GetArmazem(),;//cLocal
					              Self:oMovEndOri:GetEnder(),;  //cEndereco
					              (cAliasQry)->DCR_IDDCF,;            //cIdDCF
					              .F.,;                               //lWmsLibSC9
					              .F.,;                               //lGeraEmp
					              SC9->C9_SEQUEN,;                    //cSeqSC9
					              .T.)                                //lDescSC9
						//-- Deve diminuir a quantidade da SC9 atual apenas
						SC9->C9_QTDLIB  -= (cAliasQry)->DCR_QUANT
						SC9->C9_QTDLIB2 -= ConvUM(Self:oMovPrdLot:GetProduto(),(cAliasQry)->DCR_QUANT,0,2)
						If QtdComp(SC9->C9_QTDLIB) <= 0
							SC9->(DbDelete())
						EndIf
						SC9->(MsUnlock())
					EndIf
				EndIf
			EndIf
			(cAliasQry)->(DbSkip())
		EndDo
		(cAliasQry)->(DbCloseArea())
	EndIf
	RestArea(aAreaSB2)
	RestArea(aAreaSC9)
	RestArea(aAreaAnt)
Return lRet

/*/{Protheus.doc} UpdMovExp
Atualização das movimentações de expedição:
	Montagem de Volume
	Distribuição Separação
	Conferencia Expedição
@author Squad WMS
@since 28/01/2018
@version 1.0
@return lógico
@type method
/*/
METHOD UpdMovExp() CLASS WMSDTCMovimentosServicoArmazem
Local lRet := .T.
Local oMntVolItem := WMSDTCMontagemVolumeItens():New()
Local oDisSepItem := WMSDTCDistribuicaoSeparacaoItens():New()
Local oConExpItem := WMSDTCConferenciaExpedicaoItens():New()
Local cQuery      := ""
Local cAliasQry   := ""
	cQuery := " SELECT DCF.DCF_CARGA,"
	cQuery +=        " DCF.DCF_DOCTO,"
	cQuery +=        " DCR.DCR_QUANT"
	cQuery +=   " FROM "+RetSqlName("DCR")+" DCR"
	cQuery +=  " INNER JOIN "+RetSqlName("DCF")+" DCF"
	cQuery +=     " ON DCF.DCF_FILIAL = '"+xFilial("DCF")+"'"
	cQuery +=    " AND DCR.DCR_FILIAL = '"+xFilial("DCR")+"'"
	cQuery +=    " AND DCF.DCF_ID = DCR.DCR_IDDCF"
	cQuery +=    " AND DCF.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE DCR.DCR_FILIAL = '"+xFilial("DCR")+"'"
	cQuery +=    " AND DCR.DCR_IDMOV  = '"+Self:cIdMovto+"'"
	cQuery +=    " AND DCR.DCR_IDOPER = '"+Self:cIdOpera+"'"
	cQuery +=    " AND DCR.DCR_IDORI  = '"+Self:oOrdServ:GetIdDCF()+"'"
	cQuery +=    " AND DCR.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	Do While (cAliasQry)->(!Eof()) .And. lRet
		// Atualiza Montagem Volume
		oMntVolItem:SetCarga((cAliasQry)->DCF_CARGA)
		oMntVolItem:SetPedido((cAliasQry)->DCF_DOCTO)
		oMntVolItem:SetPrdOri(Self:oMovPrdLot:GetPrdOri())
		oMntVolItem:SetProduto(Self:oMovPrdLot:GetProduto())
		oMntVolItem:SetLoteCtl(Self:oMovPrdLot:GetLoteCtl())
		oMntVolItem:SetNumLote(Self:oMovPrdLot:GetNumLote())
		// Busca o codigo da montagem do volume
		oMntVolItem:SetCodMnt(oMntVolItem:oMntVol:FindCodMnt())
		If oMntVolItem:LoadData()
			lRet := oMntVolItem:RevMntVol((cAliasQry)->DCR_QUANT,0)
			// Atualiza o status para da DCV para liberado
			If lRet .And. oMntVolItem:oMntVol:GetLibPed() == "6" .And. oMntVolItem:oMntVol:GetStatus() == "3"
				oMntVolItem:oMntVol:LiberSC9()
			EndIf
			If !lRet
				Self:cErro := oMntVolItem:GetErro()
			EndIf
		EndIf
		If lRet
			// Atualiza Distribuição Separação
			oDisSepItem:oDisSep:SetCarga((cAliasQry)->DCF_CARGA)
			oDisSepItem:oDisSep:SetPedido((cAliasQry)->DCF_DOCTO)
			oDisSepItem:SetPrdOri(Self:oMovPrdLot:GetPrdOri())
			oDisSepItem:oDisPrdLot:SetProduto(Self:oMovPrdLot:GetProduto())
			oDisSepItem:oDisPrdLot:SetLoteCtl(Self:oMovPrdLot:GetLoteCtl())
			oDisSepItem:oDisPrdLot:SetNumLote(Self:oMovPrdLot:GetNumLote())
			oDisSepItem:oDisPrdLot:SetNumSer(Self:oMovPrdLot:GetNumSer())
			oDisSepItem:oDisEndOri:SetArmazem(Self:oMovEndDes:GetArmazem())
			oDisSepItem:oDisSep:oDisEndDes:SetArmazem(Self:oMovEndDes:GetArmazem())
			oDisSepItem:oDisEndOri:SetArmazem(Self:oMovEndDes:GetArmazem())
			// Busca o codigo da distribuição da separação
			oDisSepItem:SetCodDis(oDisSepItem:oDisSep:FindCodDis())
			If oDisSepItem:LoadData()
				lRet := oDisSepItem:RevDisSep((cAliasQry)->DCR_QUANT,0) // Senão estorna a quantidade a menor
				If !lRet
					Self:cErro := oDisSepItem:GetErro()
				EndIf
			EndIf
		EndIf
		If lRet
			// Atualiza Conferencia Expedição
			oConExpItem:SetCarga((cAliasQry)->DCF_CARGA)
			oConExpItem:SetPedido((cAliasQry)->DCF_DOCTO)
			oConExpItem:SetPrdOri(Self:oMovPrdLot:GetPrdOri())
			oConExpItem:SetProduto(Self:oMovPrdLot:GetProduto())
			oConExpItem:SetLoteCtl(Self:oMovPrdLot:GetLoteCtl())
			oConExpItem:SetNumLote(Self:oMovPrdLot:GetNumLote())
			// Busca o codigo da conferencia de expedicao
			oConExpItem:SetCodExp(oConExpItem:oConfExp:FindCodExp())
			If oConExpItem:LoadData()
				lRet := oConExpItem:RevConfExp((cAliasQry)->DCR_QUANT,0) // Senão estorna a quantidade a menor
				//Se o status da conferência encontra-se como "3-Conferido" e o serviço WMS está parametrizado para liberar na conferência de expedição, então libera SC9
				If lRet .And. oConExpItem:oConfExp:GetLibPed() == "3"  .And. oConExpItem:oConfExp:GetStatus() == "3"
					WMSV102LIB(1,oConExpItem:GetCodExp(),oConExpItem:GetCarga(),oConExpItem:GetPedido())
				EndIf
				If !lRet
					Self:cErro := oConExpItem:GetErro()
				EndIf
			EndIf
		EndIf
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
Return lRet

/*/{Protheus.doc} UpdMovLote
Ajusta a movimentação com o novo lote (D12).
@author Squad WMS
@since 28/01/2016
@version 1.0
@return lógico
@param cNovoLote, characters, novo lote para a movimentação
@param cNovoSbLot, characters, novo sub-lote para a movimentação
@param cNovoUnit, characters, novo unitizador para a movimentação
@param cNovoEnder, characters, novo endereço para a movimentação
@type method
/*/
METHOD UpdMovLote(cNovoLote,cNovoSbLot,cNovoUnit,cNovoEnder) CLASS WMSDTCMovimentosServicoArmazem
Local lRet      := .T.
Local lGravaEnd := !Empty(cNovoEnder)
Local cQuery    := ""
Local cAliasD12 := GetNextAlias()
Local oMovAux1  := WMSDTCMovimentosServicoArmazem():New()
Local oRelacMov := Nil
	If Self:cAgluti == "1" //Altera lote de movimentações aglutinadas
		cQuery := " SELECT D12.R_E_C_N_O_ RECNOD12"
		cQuery +=   " FROM "+RetSqlName("DCR")+" DCR"
		cQuery +=  " INNER JOIN "+RetSqlName("D12")+" D12"
		cQuery +=     " ON D12.D12_FILIAL = '"+xFilial("D12")+"'"
		cQuery +=    " AND D12.D12_PRODUT = '"+Self:oMovPrdLot:GetProduto()+"'"
		cQuery +=    " AND D12.D12_LOTECT = '"+Self:oMovPrdLot:GetLoteCtl()+"'"
		cQuery +=    " AND D12.D12_NUMLOT = '"+Self:oMovPrdLot:GetNumLote()+"'"
		cQuery +=    " AND D12.D12_NUMSER = '"+Self:oMovPrdLot:GetNumSer()+"'"
		If WmsX312118("D12","D12_IDUNIT")
			cQuery +=    " AND D12.D12_IDUNIT = '"+Self:cIdUnitiz+"'"
		EndIf
		cQuery +=    " AND D12.D12_IDDCF  = DCR.DCR_IDDCF"
		cQuery +=    " AND D12.D_E_L_E_T_ = ' '"
		cQuery +=  " WHERE DCR.DCR_FILIAL = '"+xFilial("DCR")+"'"
		cQuery +=    " AND DCR.DCR_IDMOV  = '"+Self:cIdMovto+"'"
		cQuery +=    " AND DCR.DCR_IDOPER = '"+Self:cIdOpera+"'"
		cQuery +=    " AND DCR.DCR_IDORI  = '"+Self:oOrdServ:GetIdDCF()+"'"
		cQuery +=    " AND DCR.D_E_L_E_T_ = ' '"
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasD12,.F.,.T.)
		While (cAliasD12)->(!Eof()) .And. lRet
			oMovAux1:GoToD12((cAliasD12)->RECNOD12)
			oMovAux1:oMovPrdLot:SetLoteCtl(cNovoLote)
			oMovAux1:oMovPrdLot:SetNumLote(cNovoSbLot)
			oMovAux1:SetIdUnit(cNovoUnit)
			If lGravaEnd
				oMovAux1:oMovEndOri:SetEnder(cNovoEnder)
			EndIf
			oMovAux1:UpdateD12()
			(cAliasD12)->(DbSkip())
		EndDo
		(cAliasD12)->(DbCloseArea())
	Else //Altera lote de movimentações não aglutinadas
		cQuery := " SELECT D12.D12_AGLUTI,"
		cQuery +=        " D12.R_E_C_N_O_ RECNOD12," 
		cQuery +=        " DCR.R_E_C_N_O_ RECNODCR"
		cQuery +=   " FROM "+RetSqlName("DCR")+" DCR"
		cQuery +=  " INNER JOIN "+RetSqlName("D12")+" D12"
		cQuery +=     " ON D12.D12_FILIAL = '"+xFilial("D12")+"'"
		cQuery +=    " AND D12.D12_IDDCF  = DCR.DCR_IDORI" 
		cQuery +=    " AND D12.D12_IDMOV  = DCR.DCR_IDMOV"
		cQuery +=    " AND D12.D12_IDOPER = DCR.DCR_IDOPER"
		cQuery +=    " AND D12.D12_PRODUT = '"+Self:oMovPrdLot:GetProduto()+"'"
		cQuery +=    " AND D12.D12_LOTECT = '"+Self:oMovPrdLot:GetLoteCtl()+"'"
		cQuery +=    " AND D12.D12_NUMLOT = '"+Self:oMovPrdLot:GetNumLote()+"'"
		cQuery +=    " AND D12.D12_NUMSER = '"+Self:oMovPrdLot:GetNumSer()+"'"
		If WmsX312118("D12","D12_IDUNIT")
			cQuery +=    " AND D12.D12_IDUNIT = '"+Self:cIdUnitiz+"'"
		EndIf
		cQuery +=    " AND D12.D12_STATUS <> '0'"
		cQuery +=    " AND D12.D_E_L_E_T_ = ' '"
		cQuery +=  " WHERE DCR.DCR_FILIAL = '"+xFilial("DCR")+"'"
		cQuery +=    " AND DCR.DCR_IDORI  = '"+Self:oOrdServ:GetIdDCF()+"'"
		cQuery +=    " AND DCR.DCR_IDDCF  = '"+Self:oOrdServ:GetIdDCF()+"'"
		cQuery +=    " AND DCR.DCR_IDMOV  = '"+Self:cIdMovto+"'"
		cQuery +=    " AND DCR.D_E_L_E_T_ = ' '"
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasD12,.F.,.T.)
		While (cAliasD12)->(!Eof()) .And. lRet
			oMovAux1:GoToD12((cAliasD12)->RECNOD12)
			If (cAliasD12)->D12_AGLUTI == "2"
				oMovAux1:oMovPrdLot:SetLoteCtl(cNovoLote)
				oMovAux1:oMovPrdLot:SetNumLote(cNovoSbLot)
				If lGravaEnd
					oMovAux1:oMovEndOri:SetEnder(cNovoEnder)
				EndIf
				oMovAux1:SetIdUnit(cNovoUnit)
				oMovAux1:UpdateD12()
			Else
				//Se em uma tarefa conter uma atividade que encontra-se aglutinada e outra não
				//e a atividade posicionada para o estorno for a que não encontra-se aglutinada
				//é necessário desfazer a aglutinação para alterar o lote somente daquela quantidade posicionada no movimento
				oRelacMov := WMSDTCRelacionamentoMovimentosServicoArmazem():New()
				oRelacMov:GoToDCR((cAliasD12)->RECNODCR)
				If lRet := oMovAux1:ReverseAgl(oRelacMov,.T.)
					//Altera lote da nova movimentação criada
					oMovAux1:oMovPrdLot:SetLoteCtl(cNovoLote)
					oMovAux1:oMovPrdLot:SetNumLote(cNovoSbLot)
					If lGravaEnd
						oMovAux1:oMovEndOri:SetEnder(cNovoEnder)
					EndIf
					oMovAux1:SetIdUnit(cNovoUnit)
					oMovAux1:SetQtdLid(0)
					oMovAux1:UpdateD12()
				EndIf
			EndIf
			(cAliasD12)->(DbSkip())
		EndDo
		(cAliasD12)->(DbCloseArea())
	EndIf
	//Altera movimentações de conferência de saída
	If lRet
		lRet := Self:UpdQtdConf(cNovoLote,cNovoSbLot)
	EndIf
Return lRet

/*/{Protheus.doc} UpdQtdConf
//Ajusta quantidade do movimento de conferência de saída,
//que possuí como característica agrupar em uma única D12
//as quantidades referentes a um lote e produto 
@author amanda.vieira
@since 23/06/2018
@version 1.0
@return lógico
@param cNovoLote, characters, Novo lote para a quebra 
@param cNovoSubLote, characters, Novo sub-lote para a quebra
@type function
/*/
METHOD UpdQtdConf(cNovoLote,cNovoSubLote) CLASS WMSDTCMovimentosServicoArmazem
Local lRet       := .T.
Local aIdDCF     := {}
Local cIdDCF     := ""
Local cQuery     := ""
Local cAliasQry  := ""
Local cAliasD12  := ""
Local oMovimento := WMSDTCMovimentosServicoArmazem():New()
Local oMovNew    := WMSDTCMovimentosServicoArmazem():New()
Local oRelacMov  := WMSDTCRelacionamentoMovimentosServicoArmazem():New()
Local oRelacNew  := WMSDTCRelacionamentoMovimentosServicoArmazem():New()
Local nI         := 1
Local nQtdQuebra := 0
	
	//Monta array com os Id DCF e suas respectivas quantidades
	If Self:GetAgluti() == "1"
		cQuery := " SELECT DCR.DCR_IDDCF,"
		cQuery +=        " DCR.DCR_QUANT"
		cQuery +=   " FROM "+RetSqlName('DCR')+" DCR"
		cQuery +=  " INNER JOIN "+RetSqlName('D12')+" D12" 
		cQuery +=     " ON D12.D12_FILIAL = '"+xFilial('D12')+"'"
		cQuery +=    " AND D12.D12_IDDCF  = DCR.DCR_IDORI"
		cQuery +=    " AND D12.D12_IDMOV  = DCR.DCR_IDMOV"
		cQuery +=    " AND D12.D12_IDOPER = DCR.DCR_IDOPER"
		cQuery +=    " AND D12.D12_STATUS <> '0'"
		cQuery +=    " AND D12.D_E_L_E_T_ = ' '"
		cQuery +=  " WHERE DCR.DCR_FILIAL = '"+xFilial('DCR')+"'"
		cQuery +=    " AND DCR.DCR_IDMOV  = '"+Self:GetIdMovto()+"'"
		cQuery +=    " AND DCR.DCR_IDOPER = '"+Self:GetIdOpera()+"'"
		cQuery +=    " AND DCR.DCR_IDORI  = '"+Self:oOrdServ:GetIdDCF()+"'"
		cQuery +=    " AND DCR.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
		While (cAliasQry)->(!EoF())
			AADD(aIdDCF,{(cAliasQry)->DCR_IDDCF,(cAliasQry)->DCR_QUANT})
			(cAliasQry)->(DbSkip())
		EndDo
		(cAliasQry)->(DbCloseArea())
	Else
		AADD(aIdDCF,{Self:oOrdServ:GetIdDCF(),Self:nQuant})
	EndIf
	
	For nI :=1 To Len(aIdDCF)
		cIdDCF     := aIdDCF[nI][1]
		nQtdQuebra := aIdDCF[nI][2]
		//Busca conferência de saída para o Id DCF
		cQuery := " SELECT D12.R_E_C_N_O_ RECNOD12,"
		cQuery +=        " DCR.R_E_C_N_O_ RECNODCR"
		cQuery +=   " FROM "+RetSqlName("DCR")+" DCR"
		cQuery +=  " INNER JOIN "+RetSqlName("D12")+" D12"
		cQuery +=     " ON D12.D12_FILIAL = '"+xFilial("D12")+"'"
		cQuery +=    " AND D12.D12_IDDCF  = DCR.DCR_IDORI" 
		cQuery +=    " AND D12.D12_IDMOV  = DCR.DCR_IDMOV"
		cQuery +=    " AND D12.D12_IDOPER = DCR.DCR_IDOPER"
		cQuery +=    " AND D12.D12_PRODUT = '"+Self:oMovPrdLot:GetProduto()+"'"
		cQuery +=    " AND D12.D12_LOTECT = '"+Self:oMovPrdLot:GetLoteCtl()+"'"
		cQuery +=    " AND D12.D12_NUMLOT = '"+Self:oMovPrdLot:GetNumLote()+"'"
		cQuery +=    " AND D12.D12_NUMSER = '"+Self:oMovPrdLot:GetNumSer()+"'"
		cQuery +=    " AND D12.D12_STATUS <> '0'"
		cQuery +=    " AND D12.D_E_L_E_T_ = ' '"
		cQuery +=  " INNER JOIN "+RetSqlName("DC5")+" DC5"
		cQuery +=     " ON DC5.DC5_FILIAL = '"+xFilial("DC5")+"'"
		cQuery +=    " AND DC5.DC5_SERVIC = D12.D12_SERVIC"
		cQuery +=    " AND DC5.DC5_TAREFA = D12.D12_TAREFA"
		cQuery +=    " AND DC5.DC5_OPERAC = '7'"
		cQuery +=    " AND DC5.D_E_L_E_T_ = ' '"
		cQuery +=  " WHERE DCR.DCR_FILIAL = '"+xFilial("DCR")+"'"
		cQuery +=    " AND DCR.DCR_IDDCF  = '"+cIdDCF+"'"
		cQuery +=    " AND DCR.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
		If (cAliasQry)->(!EoF())
			//Posiciona D12 e DCR
			oMovimento:GoToD12((cAliasQry)->RECNOD12)
			oRelacMov:GoToDCR((cAliasQry)->RECNODCR)
			If QtdComp(oMovimento:GetQtdMov()) <= QtdComp(nQtdQuebra)
				// Exclui D12 e DCR quando a quantidade ficar zerada
				oMovimento:DeleteD12()
				oRelacMov:DeleteDCR()
			Else
				// Ajusta conferência atual
				oMovimento:SetQtdMov(oMovimento:GetQtdMov() - nQtdQuebra)
				oMovimento:SetQtdOri(oMovimento:GetQtdMov())
				If oMovimento:GetQtdMov() == oMovimento:GetQtdLid()
					oMovimento:SetStatus("1")
				EndIf
				oMovimento:UpdateD12()
				// Atualiza quantidade da DCR
				oRelacMov:SetQuant(oRelacMov:GetQuant() - nQtdQuebra)
				oRelacMov:SetQuant2(ConvUm(oMovimento:oMovPrdLot:GetProduto(),oRelacMov:GetQuant(),0,2))
				oRelacMov:UpdateDCR()
			EndIf
			//Verifica se já existe movimentação de conferência para o novo lote/sublote
			cQuery := " SELECT D12.R_E_C_N_O_ RECNOD12,"
			cQuery +=        " DCR.R_E_C_N_O_ RECNODCR"
			cQuery +=   " FROM "+RetSqlName("DCR")+" DCR"
			cQuery +=  " INNER JOIN "+RetSqlName("D12")+" D12"
			cQuery +=     " ON D12.D12_FILIAL = '"+xFilial("D12")+"'"
			cQuery +=    " AND D12.D12_IDDCF  = DCR.DCR_IDORI" 
			cQuery +=    " AND D12.D12_IDMOV  = DCR.DCR_IDMOV"
			cQuery +=    " AND D12.D12_IDOPER = DCR.DCR_IDOPER"
			cQuery +=    " AND D12.D12_PRODUT = '"+oMovimento:oMovPrdLot:GetProduto()+"'"
			cQuery +=    " AND D12.D12_LOTECT = '"+cNovoLote+"'"
			cQuery +=    " AND D12.D12_NUMLOT = '"+cNovoSubLote+"'"
			cQuery +=    " AND D12.D12_STATUS <> '0'"
			cQuery +=    " AND D12.D_E_L_E_T_ = ' '"
			cQuery +=  " INNER JOIN "+RetSqlName("DC5")+" DC5"
			cQuery +=     " ON DC5.DC5_FILIAL = '"+xFilial("DC5")+"'"
			cQuery +=    " AND DC5.DC5_SERVIC = D12.D12_SERVIC"
			cQuery +=    " AND DC5.DC5_TAREFA = D12.D12_TAREFA"
			cQuery +=    " AND DC5.DC5_OPERAC = '7'"
			cQuery +=    " AND DC5.D_E_L_E_T_ = ' '"
			cQuery +=  " WHERE DCR.DCR_FILIAL = '"+xFilial("DCR")+"'"
			cQuery +=    " AND DCR.DCR_IDDCF  = '"+cIdDCF+"'"
			cQuery +=    " AND DCR.D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			cAliasD12  := GetNextAlias()
			DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasD12,.F.,.T.)
			If (cAliasD12)->(!EoF())
				//Atualiza D12 já existente com a quantidade alterada
				oMovNew:GoToD12((cAliasD12)->RECNOD12)
				oMovNew:SetQtdMov(oMovNew:GetQtdMov()+nQtdQuebra)
				oMovNew:SetQtdOri(oMovNew:GetQtdMov())
				If oMovNew:GetQtdLid() > 0 .And. oMovNew:GetStatus() == "1"
					oMovNew:SetStatus("4")
				EndIf
				oMovNew:UpdateD12()
				//Atualiza DCR já existente com a quantidade alterada
				oRelacNew:GoToDCR((cAliasD12)->RECNODCR)
				oRelacNew:SetQuant(oRelacNew:GetQuant() + nQtdQuebra)
				oRelacNew:SetQuant2(ConvUm(oMovNew:oMovPrdLot:GetProduto(),oRelacNew:GetQuant(),0,2))
				oRelacNew:UpdateDCR()
			Else
				//Cria nova movimentação com a quantidade restante
				oMovNew:oOrdServ:SetIdDCF(cIdDCF)
				oMovNew:oOrdServ:LoadData()
				oMovNew:SetRadioF(oMovimento:GetRadioF())
				oMovNew:SetPrAuto(oMovimento:GetPrAuto())
				oMovNew:SetBxEsto(oMovimento:GetBxEsto())
				// Atribui dados servico
				oMovNew:oMovServic:SetServico(oMovimento:oMovServic:GetServico())
				oMovNew:oMovServic:SetOrdem(oMovimento:oMovServic:GetOrdem())
				oMovNew:oMovServic:LoadData()
				// Atribui dados Atividade
				oMovNew:oMovTarefa:SetTarefa(oMovimento:oMovTarefa:GetTarefa())
				oMovNew:oMovTarefa:SetOrdem(oMovimento:oMovTarefa:GetOrdem())
				oMovNew:oMovTarefa:LoadData()
				// Atribui dados Produto/Lote
				oMovNew:oMovPrdLot:SetPrdOri(oMovimento:oMovPrdLot:GetPrdOri())
				oMovNew:oMovPrdLot:SetProduto(oMovimento:oMovPrdLot:GetProduto())
				oMovNew:oMovPrdLot:SetLoteCtl(cNovoLote)
				oMovNew:oMovPrdLot:SetNumLote(cNovoSubLote)
				oMovNew:oMovPrdLot:SetNumSer(oMovimento:oMovPrdLot:GetNumSer())
				oMovNew:oMovPrdLot:LoadData()
				// Atribui dados endereço origem
				oMovNew:oMovEndOri:SetArmazem(oMovimento:oMovEndOri:GetArmazem())
				oMovNew:oMovEndOri:SetEnder(oMovimento:oMovEndOri:GetEnder())
				oMovNew:oMovEndOri:LoadData()
				// Atribui dados endereço destino
				oMovNew:oMovEndDes:SetArmazem(oMovimento:oMovEndDes:GetArmazem())
				oMovNew:oMovEndDes:SetEnder(oMovimento:oMovEndDes:GetEnder())
				oMovNew:oMovEndDes:LoadData()
				// Atribui dados gerais movimento serviço
				cIdMovto := GetSX8Num('D12', 'D12_IDMOV')
				ConfirmSx8()
				oMovNew:SetIdMovto(cIdMovto)
				oMovNew:SetQtdMov(nQtdQuebra)
				oMovNew:SetQtdLid(0)
				oMovNew:SetPriori(oMovimento:GetPriori())
				oMovNew:SetSeqPrio(oMovimento:GetSeqPrio())
				oMovNew:SetStatus('4')
				oMovNew:SetAgluti('2')
				oMovNew:SetIdUnit(oMovimento:GetIdUnit())
				oMovNew:SetUniDes(oMovimento:GetUniDes())
				oMovNew:SetRhFunc(oMovimento:GetRhFunc())
				oMovNew:SetRecHum(oMovimento:GetRecHum())
				oMovNew:SetRecFis(oMovimento:GetRecFis())
				oMovNew:SetAtuEst(oMovimento:GetAtuEst())
				oMovNew:SetLibPed(oMovimento:GetLibPed())
				oMovNew:SetMntVol(oMovimento:GetMntVol())
				oMovNew:SetDisSep(oMovimento:GetDisSep())
				// Atribui dados das atividades e cria as movimentações
				oMovNew:RecordD12()
			EndIf
			(cAliasD12)->(DbCloseArea())
		EndIf
		(cAliasQry)->(DbCloseArea())
	Next nI
Return lRet
//--------------------------------------------------
/*/{Protheus.doc} ChkEstPrd
//Valida se quantidade solicitada possui saldo do produto
//e quando possui controle de lote se a quantidade possui
//saldo por lote
@author Squad WMS Protheus
@since 27/06/2018
@version 1.0
@return lógico
@param lMovEst, Logical, Indica se desconta quantidade da movimentação da quantidade saida prevista, pois quantidade do movimento está inclusa.
@param lConMov, Logical, Inidca se Considera apenas o saldo atual do endereço, pois está efetuando efetivamente a movimentação de estoque
@param cLocal, characters, código do armazém 
@param cProduto, characters, código do produto
@param cLoteCtl, characters, código do lote 
@param cNumLote, characters, código do sub-lote do lote
@param nQuant, characters, Quantidade solicitada 

@type function
@version 1.0
/*/
//--------------------------------------------------
METHOD ChkEstPrd(lMovEst,lConsMov,cLocal,cProduto,cLoteCtl,cNumLote,nQuant) CLASS WMSDTCMovimentosServicoArmazem
Local lRet      := .T.
Local aSldD14   := {}
Local nSaldoSB2 := 0
Local nSldD14   := 0
Local nEmpD14   := 0
Local nEmpSB8   := 0
Local nSaldoDis := 0

Default cLoteCtl  := PadR(cLoteCtl,TamSx3("D12_LOTECT")[1])
Default cNumLote  := PadR(cNumLote,TamSx3("D12_NUMLOT")[1])
Default nQuant    := 0

	cLocal   := PadR(cLocal,TamSx3("D12_LOCORI")[1])
	cProduto := PadR(cProduto,TamSx3("D12_PRODUT")[1])
	// Valida saldo produto
	dbSelectArea("SB2")
	SB2->(dbSetOrder(1))
	If SB2->(dbSeek(xFilial("SB2")+cProduto+cLocal))
		nSaldoSB2:=SaldoSB2()
		nSaldoSB2:= Iif(lMovEst,QtdComp(nSaldoSB2),QtdComp(nSaldoSB2 - Iif(lConsMov,0,nQuant)))
	EndIf
	If QtdComp(nSaldoSB2) < 0
		lRet := .F.
	EndIf 
	// Valida se controla rastro e lote informado
	If lRet .And. Self:oMovPrdLot:HasRastro() .And. !Empty(cLoteCtl)
		SB8->(dbSetOrder(3))// B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL+B8_NUMLOTE+DTOS(B8_DTVALID)
		If SB8->(dbSeek(xFilial("SB8")+cProduto+cLocal+cLoteCtl+cNumLote))
			//Preenche informações sobre o saldo do lote D14/SB8
			aSldD14 := Self:SldPrdLot(cLoteCtl,cNumLote)
			nSldD14 := aSldD14[1]      //Quantidade em estoque do lote (D14)
			nEmpD14 := aSldD14[2]      //Quantidade de empenho e empenho previsto do lote (D14)
			nEmpSB8 := SB8->B8_EMPENHO //Quantidade de empenho do lote (SB8)
			//Verifica se a quantidade empenhada do lote (SB8) é maior que a quantidade empenhada dos endereços (D14)
			//Caso for maior, indica que existem ordens de serviços que estão pendentes de execução para o lote (lote informado no pedido)
			nSldD14 := Iif(lMovEst,QtdComp(nSldD14),QtdComp(nSldD14 - Iif(lConsMov,0,nQuant)))
			If QtdComp(nEmpSB8) > QtdComp(nEmpD14)
				//Calcula a quantidade disponível para o lote 
				nSldD14 -= nEmpSB8
			Else
				nSldD14 -= nEmpD14
			EndIf
			//Se sobrou saldo disponível, utiliza para realizar a transferencia
			If QtdComp(nSldD14) < 0
 				lRet := .F.
			EndIf
		EndIf
	EndIf
Return lRet
//--------------------------------------------------
/*/{Protheus.doc} SldPrdLot
//Busca os saldo do produto em estoque e o saldo do produto
//descontando a quantidade bloqueada, empenho previsto e empenho
@author Squad WMS Protheus
@since 27/06/2018
@version 1.0
@return array
@param cLoteCtl, characters, código do lote 
@param cNumLote, characters, código do sub-lote do lote
@type function
@version 1.0
/*/
//--------------------------------------------------
METHOD SldPrdLot(cLotectl, cNumlote) CLASS WMSDTCMovimentosServicoArmazem
Local aSaldo    := {}
Local aTamSX3   := TamSx3("D14_QTDEST")
Local cAliasD14 := Nil
Local cQuery    := ""
	cQuery := " SELECT SUM(D14_QTDEST) D14_SALDO,"
	cQuery +=        " SUM(D14_QTDBLQ+D14_QTDPEM+D14_QTDEMP) D14_EMP"
	cQuery +=   " FROM "+RetSqlName("D14")+" D14"
	cQuery +=  " WHERE D14.D14_FILIAL = '"+xFilial("D14")+"'"
	cQuery +=    " AND D14.D14_LOCAL = '"+Self:oMovEndOri:GetArmazem()+"'"
	cQuery +=    " AND D14.D14_PRODUT = '"+Self:oMovPrdLot:GetProduto()+"'"
	cQuery +=    " AND D14.D14_PRDORI = '"+Self:oMovPrdLot:GetPrdOri()+"'"
	cQuery +=    " AND D14.D14_LOTECT = '"+cLoteCtl+"'"
	If !Empty(cNumLote)
		cQuery +=    " AND D14.D14_NUMLOT = '"+cNumLote+"'"
	EndIf
	cQuery +=    " AND D14.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasD14 := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasD14,.F.,.T.)
	TcSetField(cAliasD14,'D14_SALDO' ,'N',aTamSX3[1],aTamSX3[2])
	TcSetField(cAliasD14,'D14_EMP'   ,'N',aTamSX3[1],aTamSX3[2])
	If (cAliasD14)->(!Eof())
		aSaldo := {(cAliasD14)->D14_SALDO,(cAliasD14)->D14_EMP}
	EndIf
	(cAliasD14)->(DbCloseArea())
Return aSaldo

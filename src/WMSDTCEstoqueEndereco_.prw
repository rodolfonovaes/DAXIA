#INCLUDE "TOTVS.CH"
#INCLUDE "WMSDTCESTOQUEENDERECO.CH"

#DEFINE CLRF  CHR(13)+CHR(10)

Static _lWMSCPEND := ExistBlock("WMSCPEND")
Static _lWMSATD14 := ExistBlock("WMSATD14")
Static _lWMSSLDWM := ExistBlock("WMSSLDWM")

//---------------------------------------------
/*/{Protheus.doc} WMSCLS0020
Função para permitir que a classe seja visualizada
no inspetor de objetos
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0020()
Return Nil
//----------------------------------------
/*/{Protheus.doc} WMSDTCEstoqueEndereco
Classe estoque endereço
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//----------------------------------------
CLASS WMSDTCEstoqueEndereco FROM LongNameClass
	// Data
	DATA lHasCodUni // Utilizado para suavizar o campo D14_CODUNI
	DATA oEndereco
	DATA oProdLote
	DATA bGetDocto // Bloco de código para buscar informações do documento para movimentação de estoque
	DATA bGetMovto // Bloco de código para buscar informações do movimento para movimentação de estoque
	DATA nQtdEst
	DATA nQtdEs2
	DATA nQtdEPr
	DATA nQtdEP2
	DATA nQtdSPr
	DATA nQtdSP2
	DATA nQtdPEm
	DATA nQtdPE2
	DATA nQtdEmp
	DATA nQtdEm2
	DATA nQtdBlq
	DATA nQtdBl2
	DATA cCodNorma
	DATA cCodVolume
	DATA cIdVolume
	DATA cIdUnitiz
	DATA cTipUni
	DATA nQuant
	DATA lUseQryCpm
	DATA nRecno
	DATA cErro
	DATA lProducao
	DATA aD14_QTDEST AS ARRAY
	DATA aB2_RESERVA AS ARRAY
	DATA aB8_EMPENHO AS ARRAY
	DATA aB8_SALDO AS ARRAY
	DATA aD11_RATEIO AS ARRAY
	DATA aDCF_ID AS ARRAY
	// Method
	METHOD New() CONSTRUCTOR
	METHOD LoadData(nIndex)
	METHOD SetCodNor(cCodNorma)
	METHOD SetCodVolu(cCodVolume)
	METHOD SetIdVolu(cIdVolume)
	METHOD SetIdUnit(cIdUnitiz)
	METHOD SetTipUni(cTipUni)
	METHOD SetQuant(nQuant)
	METHOD SetUseQryC(lUseQryCpm)
	METHOD SetProducao(lProducao)
	METHOD SetBlkDoc(bGetDocto)
	METHOD SetBlkMov(bGetMovto)
	METHOD GetQtdEst()
	METHOD GetQtdEs2()
	METHOD GetQtdEpr()
	METHOD GetQtdEP2()
	METHOD GetQtdSPr()
	METHOD GetQtdSP2()
	METHOD GetQtdPEm()
	METHOD GetQtdPE2()
	METHOD GetQtdEmp()
	METHOD GetQtdEm2()
	METHOD GetQtdBlq()
	METHOD GetQtdBl2()
	METHOD GetCodNor()
	METHOD GetCodVol()
	METHOD GetIdVolu()
	METHOD GetIdUnit()
	METHOD GetTipUni()
	METHOD GetQuant()
	METHOD GetUseQryC()
	METHOD GetLote()
	METHOD EndUsaComp()
	METHOD FindLote()
	METHOD GetErro()
	METHOD UpdSaldo(cTipo,lEstoque,lEntPrev,lSaiPrev,lEmpenho,lBloqueio,lEmpPrev,lMovEstEnd)
	METHOD ConsultSld(lEntrPrev,lSaidaPrev,lEmpenho,lBloqueio)
	METHOD FindSldEnd(cArmazem, cEndereco, cEstFis, cProduto, cLoteCtl, cNumLote, cNumserie, lEntrPrev, lSaidaPrev, lEmpenho, lBloqueio, cIdUnitiz)
	METHOD FindSldCmp(cArmazem, cEndereco, cProduto, cLoteCtl, cNumLote, cNumSerie, cIdUnitiz)
	METHOD HaveSaldo()
	METHOD GetSldPart(cArmazem,dDataInv,lSldComp)
	METHOD GetSldOrig(lMontado,lConsReser)
	METHOD UndoFatur(nRecno, lEmpenho, cNFiscal, cNumSeq)
	METHOD MakeFatur(nRecnoSC9)
	METHOD MakePerda(nRecnoSBC)
	METHOD UndoPerda(nRecnoSBC)
	METHOD GetSldEnd(cPrdOri,cLocal,cEnder,cLoteCtl,cNumLote,cNumSerie,nOrdem,lConsSaida,cProduto,nQtdSpr,cIdUnitiz)
	METHOD SldPrdData(cProduto,cArmazem,cEndereco,cLoteCtl,cNumLote,cNumSerie,dDataRef,cIdUnitiz)
	METHOD UpdEstoque(nQuant,cLocal,cEnder,cEstFis,cProduto,cLoteCtl,cNumLote,cNumSerie,aMV_Par,cLog,cIdUnitiz,cTipUni) // Utilizado no refaz saldos do inventário
	METHOD GetSldWMS(cProduto,cLocal,cEnder,cLoteCtl,cNumLote,cNumSerie,lConsSaida,cIdUnitiz)
	METHOD GetEndDisp(nQuant)
	METHOD ReversePed(nRecnoSC9,nQtdQuebra)
	METHOD ClearData()
	METHOD Destroy()
	METHOD UpdEnder(lConsBlq)
	METHOD GetQryDad(cQuery,lConsSaida,nOrdem,nQtdSpr)
	METHOD GetQryComp(cQuery,lConsSaida,nOrdem,nQtdSpr)
	METHOD FindSldPrd(nQtdRat)
	// Inventário
	METHOD PropPrdPai(lInventario,cLocal,cPrdPai,cLoteCtl,cNumLote,cNumSerie,aMV_Par,aParam,cIdUnitiz)
	METHOD MontPrdPai(lInventario,aPais,aParam,aMV_Par)
	METHOD CalcEstWms(cArmazem,cProduto,dData,cEndereco,cLoteCtl,cNumLote,cNumserie,nAcao,cPrdOri,cIdUnitiz)
	METHOD AnaEstoque(cLog,cCod,cLocal,cLoteCtl,cLote)
	METHOD EquateOver(cArmazem,cProduto,oProcess,nAcao)
	METHOD MovInvSD3(aMovSd3,lDesmontagem)
	METHOD GeraMovEst(cTipo)
	METHOD WmsGeraOP(cLocal,cProduto,nQtd)
	METHOD WmsApontOp(cNum,cProduto,nQtd,cDocSD3,nRecno,cLocal,cLote,cNumLote,cLote,cNumLote,cServic)
	METHOD WmsReqPart(cDocSD3,dDataInv,cNumSeq,cPrdComp,cArmazem,cEndereco,cLoteCtl,cNumLote,nQuant,cNumOp)
	METHOD GeraEmpReq(cOrigem,cOp,cTrt,cIdDCF,lEstorno,lCriaSDC,lEmpD14)
	METHOD GerUnitEst(cArmazem,cEndereco,cIdUnit,cTipUni)
	METHOD MakeFatLoj(nRecnoSD2)
	METHOD UndoFatLoj(nRecnoSD2)
	METHOD SelectKard(lProcess,cArmazem,cProduto)
	METHOD EquateKard(cArmazem,cProduto,oProcess)
	METHOD SelectEst(lProcess,cArmazem,cProduto)
	METHOD EquateEst(cArmazem,cProduto,oProcess)
	METHOD SelectAjt(lProcess,cArmazem,cProduto)
	METHOD AjusEstPrd(oProcess)
	METHOD SelectPrev(lProcess,cArmazem,cProduto)
	METHOD EquatePrev(cArmazem,cProduto,oProcess)
	METHOD AtuDesSD3(aArrSD3,nOperac)
	METHOD EstDesSD3(aArrSD3,cSeqEst,nOperac)
ENDCLASS
//----------------------------------------
/*/{Protheus.doc} New
Método construtor
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//----------------------------------------
METHOD New() CLASS WMSDTCEstoqueEndereco
	Self:lHasCodUni  := WmsX312118("D14","D14_CODUNI")
	Self:oProdLote   := WMSDTCProdutoLote():New()
	Self:oEndereco   := WMSDTCEndereco():New()
	Self:cCodNorma   := PadR("" , TamSx3("DC3_CODNOR")[1])
	Self:cCodVolume  := PadR("" , TamSx3("D14_CODVOL")[1])
	Self:cIdVolume   := PadR("" , TamSx3("D14_IDVOLU")[1])
	Self:cIdUnitiz   := PadR("" , TamSx3("D14_IDUNIT")[1])
	Self:cTipUni     := PadR("" , Iif(Self:lHasCodUni,TamSx3("D14_CODUNI")[1],6))
	Self:aD14_QTDEST := TamSx3("D14_QTDEST")
	Self:aB2_RESERVA := TamSx3("B2_RESERVA")
	Self:aB8_EMPENHO := TamSx3("B8_EMPENHO")
	Self:aB8_SALDO   := TamSx3("B8_SALDO")
	Self:aD11_RATEIO := TamSx3("D11_RATEIO")
	Self:aDCF_ID     := TamSx3("DCF_ID")
	Self:ClearData()
Return

METHOD ClearData() CLASS WMSDTCEstoqueEndereco
	Self:oProdLote:ClearData()
	Self:oEndereco:ClearData()
	Self:nQtdEst    := 0
	Self:nQtdEs2    := 0
	Self:nQtdEPr    := 0
	Self:nQtdEP2    := 0
	Self:nQtdSPr    := 0
	Self:nQtdSP2    := 0
	Self:nQtdPEm    := 0
	Self:nQtdPE2    := 0
	Self:nQtdEmp    := 0
	Self:nQtdEm2    := 0
	Self:nQtdBlq    := 0
	Self:nQtdBl2    := 0
	Self:cCodNorma  := PadR("" , Len(Self:cCodNorma))
	Self:cCodVolume := PadR("" , Len(Self:cCodVolume))
	Self:cIdVolume  := PadR("" , Len(Self:cIdVolume))
	Self:cIdUnitiz  := PadR("" , Len(Self:cIdUnitiz))
	Self:cTipUni    := PadR("" , Iif(Self:lHasCodUni,Len(Self:cTipUni),6))
	Self:lUseQryCpm := .F.
	Self:lProducao  := Nil
	Self:bGetDocto  := Nil
	Self:bGetMovto  := Nil
	Self:nRecno     := 0
Return

METHOD Destroy() CLASS WMSDTCEstoqueEndereco
	FreeObj(Self)
Return Nil
//----------------------------------------
/*/{Protheus.doc} LoadData
Carregamento dos dados D14
@author felipe.m
@since 23/12/2014
@version 1.0
@param nIndex, numérico, (Descrição do parâmetro)
/*/
//----------------------------------------
METHOD LoadData(nIndex) CLASS WMSDTCEstoqueEndereco
Local lRet       := .T.
Local aAreaAnt   := GetArea()
Local aAreaD14   := D14->(GetArea())
Local cCampos    := ""
Local cWhere     := ""
Local cAliasD14  := Nil

Default nIndex := 1
	Do Case
		Case nIndex == 1 // D14_FILIAL+D14_LOCAL+D14_ENDER+D14_PRDORI+D14_PRODUT+D14_LOTECT+D14_NUMLOT+D14_NUMSER+D14_IDUNIT
			If (Empty(Self:oEndereco:GetArmazem()).OR. Empty(Self:oEndereco:GetEnder()) .OR.;
				Empty(Self:oProdLote:GetPrdOri()) .OR. Empty(Self:oProdLote:GetProduto()))
				lRet := .F.
			EndIf
		Case nIndex == 3 // D14_FILIAL+D14_LOCAL+D14_PRODUT+D14_ENDER+D14_LOTECT+D14_NUMLOT+D14_NUMSER
			If (Empty(Self:oEndereco:GetArmazem()) .Or. Empty(Self:oProdLote:GetProduto()) .Or. Empty(Self:oEndereco:GetEnder()))
				lRet := .F.
			EndIf
		Otherwise
			lRet := .F.
	EndCase
	If !lRet
		Self:cErro := STR0001 // Dados para busca não foram informados!
	Else
		// Parâmetro Campos
		cCampos := "%"
		If Self:lHasCodUni
			cCampos += " D14.D14_CODUNI,"
		EndIf
		cCampos += "%"
		// Parâmetro Where
		cWhere := "%"
		If !Empty(Self:oProdLote:GetLoteCtl())
			cWhere += " AND D14.D14_LOTECT = '" + Self:oProdLote:GetLoteCtl() + "'"
		EndIf
		If !Empty(Self:oProdLote:GetNumLote())
			cWhere += " AND D14.D14_NUMLOT = '" + Self:oProdLote:GetNumLote() + "'"
		EndIf
		If !Empty(Self:oProdLote:GetNumSer())
			cWhere += " AND D14.D14_NUMSER = '" + Self:oProdLote:GetNumSer() + "'"
		EndIf
		If !Empty(Self:GetIdUnit())
			cWhere += " AND D14.D14_IDUNIT = '" + Self:GetIdUnit() + "'"
		EndIf
		cWhere += "%"
		cAliasD14  := GetNextAlias()
		Do Case
			Case nIndex == 1
				BeginSql Alias cAliasD14
					SELECT D14.D14_LOCAL,
							D14.D14_ENDER,
							D14.D14_PRODUT,
							D14.D14_LOTECT,
							D14.D14_NUMLOT,
							D14.D14_DTVALD,
							D14.D14_DTFABR,
							D14.D14_NUMSER,
							D14.D14_ESTFIS,
							D14.D14_PRIOR,
							D14.D14_QTDEST,
							D14.D14_QTDES2,
							D14.D14_QTDEPR,
							D14.D14_QTDEP2,
							D14.D14_QTDSPR,
							D14.D14_QTDSP2,
							D14.D14_QTDEMP,
							D14.D14_QTDEM2,
							D14.D14_QTDBLQ,
							D14.D14_QTDBL2,
							D14.D14_CODVOL,
							D14.D14_IDVOLU,
							D14.D14_IDUNIT,
							%Exp:cCampos%
							D14.D14_PRDORI,
							D14.D14_OK,
							D14.D14_QTDPEM,
							D14.D14_QTDPE2,
							D14.R_E_C_N_O_ RECNOD14
					FROM %Table:D14% D14
					WHERE D14.D14_FILIAL = %xFilial:D14%
					AND D14.D14_LOCAL = %Exp:Self:oEndereco:GetArmazem()%
					AND D14.D14_ENDER = %Exp:Self:oEndereco:GetEnder()%
					AND D14.D14_PRDORI = %Exp:Self:oProdLote:GetPrdOri()%
					AND D14.D14_PRODUT = %Exp:Self:oProdLote:GetProduto()%
					AND D14.%NotDel%
					%Exp:cWhere%
				EndSql
			Case nIndex == 3
				BeginSql Alias cAliasD14
					SELECT D14.D14_LOCAL,
							D14.D14_ENDER,
							D14.D14_PRODUT,
							D14.D14_LOTECT,
							D14.D14_NUMLOT,
							D14.D14_DTVALD,
							D14.D14_DTFABR,
							D14.D14_NUMSER,
							D14.D14_ESTFIS,
							D14.D14_PRIOR,
							D14.D14_QTDEST,
							D14.D14_QTDES2,
							D14.D14_QTDEPR,
							D14.D14_QTDEP2,
							D14.D14_QTDSPR,
							D14.D14_QTDSP2,
							D14.D14_QTDEMP,
							D14.D14_QTDEM2,
							D14.D14_QTDBLQ,
							D14.D14_QTDBL2,
							D14.D14_CODVOL,
							D14.D14_IDVOLU,
							D14.D14_IDUNIT,
							%Exp:cCampos%
							D14.D14_PRDORI,
							D14.D14_OK,
							D14.D14_QTDPEM,
							D14.D14_QTDPE2,
							D14.R_E_C_N_O_ RECNOD14
					FROM %Table:D14% D14
					WHERE D14.D14_FILIAL = %xFilial:D14%
					AND D14.D14_LOCAL =  %Exp:Self:oEndereco:GetArmazem()%
					AND D14.D14_PRODUT = %Exp:Self:oProdLote:GetProduto()%
					AND D14.D14_ENDER =  %Exp:Self:oEndereco:GetEnder()%
					AND D14.%NotDel%
					%Exp:cWhere%
				EndSql
		EndCase
		TCSetField(cAliasD14,'D14_QTDEST','N',Self:aD14_QTDEST[1],Self:aD14_QTDEST[2])
		TCSetField(cAliasD14,'D14_QTDES2','N',Self:aD14_QTDEST[1],Self:aD14_QTDEST[2])
		TCSetField(cAliasD14,'D14_QTDEPR','N',Self:aD14_QTDEST[1],Self:aD14_QTDEST[2])
		TCSetField(cAliasD14,'D14_QTDEP2','N',Self:aD14_QTDEST[1],Self:aD14_QTDEST[2])
		TCSetField(cAliasD14,'D14_QTDSPR','N',Self:aD14_QTDEST[1],Self:aD14_QTDEST[2])
		TCSetField(cAliasD14,'D14_QTDSP2','N',Self:aD14_QTDEST[1],Self:aD14_QTDEST[2])
		TCSetField(cAliasD14,'D14_QTDEMP','N',Self:aD14_QTDEST[1],Self:aD14_QTDEST[2])
		TCSetField(cAliasD14,'D14_QTDEM2','N',Self:aD14_QTDEST[1],Self:aD14_QTDEST[2])
		TCSetField(cAliasD14,'D14_QTDBLQ','N',Self:aD14_QTDEST[1],Self:aD14_QTDEST[2])
		TCSetField(cAliasD14,'D14_QTDBL2','N',Self:aD14_QTDEST[1],Self:aD14_QTDEST[2])
		TCSetField(cAliasD14,'D14_QTDPEM','N',Self:aD14_QTDEST[1],Self:aD14_QTDEST[2])
		TCSetField(cAliasD14,'D14_QTDPE2','N',Self:aD14_QTDEST[1],Self:aD14_QTDEST[2])
		lRet := (cAliasD14)->(!Eof())
		If lRet
			// Carrega dados endereco
			Self:oEndereco:SetArmazem((cAliasD14)->D14_LOCAL)
			Self:oEndereco:SetEnder((cAliasD14)->D14_ENDER)
			Self:oEndereco:LoadData()
			// Carrega dados produto
			Self:oProdLote:SetPrdOri((cAliasD14)->D14_PRDORI)
			Self:oProdLote:SetProduto((cAliasD14)->D14_PRODUT)
			Self:oProdLote:SetLoteCtl((cAliasD14)->D14_LOTECT)
			Self:oProdLote:SetNumLote((cAliasD14)->D14_NUMLOT)
			Self:oProdLote:SetNumSer((cAliasD14)->D14_NUMSER)
			Self:oProdLote:LoadData()
			Self:nQtdEst    := (cAliasD14)->D14_QTDEST
			Self:nQtdEs2    := (cAliasD14)->D14_QTDES2
			Self:nQtdEPr    := (cAliasD14)->D14_QTDEPR
			Self:nQtdEP2    := (cAliasD14)->D14_QTDEP2
			Self:nQtdSPr    := (cAliasD14)->D14_QTDSPR
			Self:nQtdSP2    := (cAliasD14)->D14_QTDSP2
			Self:nQtdEmp    := (cAliasD14)->D14_QTDEMP
			Self:nQtdEm2    := (cAliasD14)->D14_QTDEM2
			Self:nQtdBlq    := (cAliasD14)->D14_QTDBLQ
			Self:nQtdBl2    := (cAliasD14)->D14_QTDBL2
			Self:nQtdPEm    := (cAliasD14)->D14_QTDPEM
			Self:nQtdPE2    := (cAliasD14)->D14_QTDPE2
			Self:cCodVolume := (cAliasD14)->D14_CODVOL
			Self:cIdVolume  := (cAliasD14)->D14_IDVOLU
			Self:cIdUnitiz  := (cAliasD14)->D14_IDUNIT
			If Self:lHasCodUni
				Self:cTipUni := (cAliasD14)->D14_CODUNI
			EndIf
			Self:nRecno     := (cAliasD14)->RECNOD14
		Else
			Self:cErro := WmsFmtMsg(STR0005,{{"[VAR01]",Self:oEndereco:GetArmazem()},{"[VAR02]",Self:oEndereco:GetEnder()}}) // Não há saldo para retirada no armazem [VAR01] e endereço [VAR02]!
		EndIf
		(cAliasD14)->(dbCloseArea())
	EndIf
	RestArea(aAreaD14)
	RestArea(aAreaAnt)
Return lRet
//-----------------------------------
// Setters
//-----------------------------------
METHOD SetCodNor(cCodNorma) CLASS WMSDTCEstoqueEndereco
	Self:cCodNorma := PadR(cCodNorma, Len(Self:cCodNorma))
Return

METHOD SetCodVolu(cCodVolume) CLASS WMSDTCEstoqueEndereco
	Self:cCodVolume := PadR(cCodVolume, Len(Self:cCodVolume))
Return

METHOD SetIdVolu(cIdVolume) CLASS WMSDTCEstoqueEndereco
	Self:cIdVolume := PadR(cIdVolume, Len(Self:cIdVolume))
Return

METHOD SetIdUnit(cIdUnitiz) CLASS WMSDTCEstoqueEndereco
	Self:cIdUnitiz := PadR(cIdUnitiz, Len(Self:cIdUnitiz))
Return

METHOD SetTipUni(cTipUni) CLASS WMSDTCEstoqueEndereco
	Self:cTipUni := PadR(cTipUni, Iif(Self:lHasCodUni,Len(Self:cTipUni),6))
Return

METHOD SetQuant(nQuant) CLASS WMSDTCEstoqueEndereco
	Self:nQuant := nQuant
Return

METHOD SetUseQryC(lUseQryCpm) CLASS WMSDTCEstoqueEndereco
	Self:lUseQryCpm := lUseQryCpm
Return

METHOD SetProducao(lProducao)CLASS WMSDTCEstoqueEndereco
	Self:lProducao := lProducao
Return

METHOD SetBlkDoc(bGetDocto) CLASS WMSDTCEstoqueEndereco
	Self:bGetDocto := bGetDocto
Return

METHOD SetBlkMov(bGetMovto) CLASS WMSDTCEstoqueEndereco
	Self:bGetMovto := bGetMovto
Return
//-----------------------------------
// Getters
//-----------------------------------
METHOD GetCodNor() CLASS WMSDTCEstoqueEndereco
Return Self:cCodNorma

METHOD GetQtdEst() CLASS WMSDTCEstoqueEndereco
Return Self:nQtdEst

METHOD GetQtdEs2() CLASS WMSDTCEstoqueEndereco
Return Self:nQtdEs2

METHOD GetQtdEpr() CLASS WMSDTCEstoqueEndereco
Return Self:nQtdEPr

METHOD GetQtdEP2() CLASS WMSDTCEstoqueEndereco
Return Self:nQtdEP2

METHOD GetQtdSPr() CLASS WMSDTCEstoqueEndereco
Return Self:nQtdSPr

METHOD GetQtdSP2() CLASS WMSDTCEstoqueEndereco
Return Self:nQtdSP2

METHOD GetQtdPEm() CLASS WMSDTCEstoqueEndereco
Return Self:nQtdPEm

METHOD GetQtdPE2() CLASS WMSDTCEstoqueEndereco
Return Self:nQtdPE2

METHOD GetQtdEmp() CLASS WMSDTCEstoqueEndereco
Return Self:nQtdEmp

METHOD GetQtdEm2() CLASS WMSDTCEstoqueEndereco
Return Self:nQtdEm2

METHOD GetQtdBlq() CLASS WMSDTCEstoqueEndereco
Return Self:nQtdBlq

METHOD GetQtdBl2() CLASS WMSDTCEstoqueEndereco
Return Self:nQtdBl2

METHOD GetCodVol() CLASS WMSDTCEstoqueEndereco
Return Self:cCodVolume

METHOD GetIdVolu() CLASS WMSDTCEstoqueEndereco
Return Self:cIdVolume

METHOD GetIdUnit() CLASS WMSDTCEstoqueEndereco
Return Self:cIdUnitiz

METHOD GetTipUni() CLASS WMSDTCEstoqueEndereco
Return Self:cTipUni

METHOD GetQuant() CLASS WMSDTCEstoqueEndereco
Return Self:nQuant

METHOD GetUseQryC() CLASS WMSDTCEstoqueEndereco
Return Self:lUseQryCpm

METHOD GetErro() CLASS WMSDTCEstoqueEndereco
Return Self:cErro
//----------------------------------------
/*/{Protheus.doc} FindLote
Procura o lote e sub-lote do produto setado
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//----------------------------------------
METHOD FindLote() CLASS WMSDTCEstoqueEndereco
Local lRet      := .T.
Local aAreaD14  := D14->(GetArea())
Local cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT D14.D14_LOTECT,
				D14.D14_NUMLOT
		FROM %Table:D14% D14
		WHERE D14.D14_FILIAL = %xFilial:D14%
		AND D14.D14_LOCAL = %Exp:Self:oEndereco:GetArmazem()%
		AND D14.D14_ENDER = %Exp:Self:oEndereco:GetEnder()%
		AND D14.D14_PRDORI = %Exp:Self:oProdLote:GetPrdOri()%
		AND D14.D14_PRODUT = %Exp:Self:oProdLote:GetProduto()%
		AND D14.%NotDel%
	EndSql
	If (cAliasQry)->(!Eof())
		Self:oProdLote:SetLoteCtl((cAliasQry)->D14_LOTECT)
		Self:oProdLote:SetNumLote((cAliasQry)->D14_NUMLOT)
	Else
		lRet := .F.
	EndIf
	(cAliasQry)->(dbCloseArea())
	RestArea(aAreaD14)
Return lRet
//----------------------------------------
/*/{Protheus.doc} UpdSaldo
Inretação com a tabela estoque endereço D14
@author felipe.m
@since 23/12/2014
@version 1.0
@param cTipo, character, (Tipo de interação 499 = Entrada; 999 = Saída)
@param lEstoque, lógico, (Considerar quantidade em estoque)
@param lEntPrev, lógico, (Considerar quantidade de entrada prevista)
@param lSaiPrev, lógico, (Considerar quantidade de saida prevista)
@param lEmpenho, lógico, (Considerar quantidade empenhada)
@param lBloqueio, lógico, (Considerar quantidade bloquada)
@param lEmpPrev, lógico, (Considerar quantidade empenho previsto)
@param lMovEstEnd, lógico, (Realiza a movimentação do kardex)
/*/
//----------------------------------------
METHOD UpdSaldo(cTipo,lEstoque,lEntPrev,lSaiPrev,lEmpenho,lBloqueio,lEmpPrev,lMovEstEnd) CLASS WMSDTCEstoqueEndereco
Local lRet		 := .T.
Local lAchou	 := .F.
Local lAnalisEnd := .F.
Local aAreaD14   := D14->(GetArea())
Local cAliasQry  := Nil
Local cEndInv    := PadR('INVENTARIO',Len(Self:oEndereco:GetEnder()))
Local nQtd2UM    := 0

Default lEstoque  := .F.
Default lEntPrev  := .F.
Default lSaiPrev  := .F.
Default lEmpenho  := .F.
Default lBloqueio := .F.
Default lEmpPrev  := .F.
Default lMovEstEnd:= .F.

	If Empty(cTipo) .OR. (!lEstoque .AND. !lEntPrev .AND. !lSaiPrev .AND.  !lEmpenho .AND. !lBloqueio)
		lRet := .F.
		Self:cErro := STR0002 // Parâmetro(s) não informado(s), Verifique (UpdSaldo)!
	EndIf
	If lRet
		If lMovEstEnd .And. !lEstoque
			lMovEstEnd := .F.
		EndIf
		// Carrega informações
		Self:oProdLote:LoadData()
		Self:oEndereco:LoadData()
		// Busca o registro de saldo
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT D14.R_E_C_N_O_ RECNOD14
			FROM %Table:D14% D14
			WHERE D14.D14_FILIAL = %xFilial:D14%
			AND D14.D14_LOCAL = %Exp:Self:oEndereco:GetArmazem()%
			AND D14.D14_ENDER = %Exp:Self:oEndereco:GetEnder()%
			AND D14.D14_PRDORI = %Exp:Self:oProdLote:GetPrdOri()%
			AND D14.D14_PRODUT = %Exp:Self:oProdLote:GetProduto()%
			AND D14.D14_LOTECT = %Exp:Self:oProdLote:GetLoteCtl()%
			AND D14.D14_NUMLOT = %Exp:Self:oProdLote:GetNumLote()%
			AND D14.D14_NUMSER = %Exp:Self:oProdLote:GetNumSer()%
			AND D14.D14_IDUNIT = %Exp:Self:cIdUnitiz%
			AND D14.%NotDel%
		EndSql
		If lAchou := (cAliasQry)->(!Eof())
			D14->(dbGoTo((cAliasQry)->RECNOD14))
		EndIf
		(cAliasQry)->(dbCloseArea())
		If !lAchou .And. cTipo == "999" .And. !(Self:oEndereco:GetEnder() == cEndInv)
			Self:cErro := WmsFmtMsg(STR0005,{{"[VAR01]",Self:oEndereco:GetArmazem()},{"[VAR02]",Self:oEndereco:GetEnder()}}) // Não há saldo para retirada no armazem [VAR01] e endereço [VAR02]!
			lRet := .F.
		Else
			nQtd2UM := ConvUm(Self:oProdLote:GetProduto(),Self:nQuant,0,2)
			RecLock('D14',!lAchou)
			If !lAchou
				D14->D14_FILIAL := xFilial("D14")
				D14->D14_LOCAL  := Self:oEndereco:GetArmazem()
				D14->D14_ENDER  := Self:oEndereco:GetEnder()
				D14->D14_PRDORI := Self:oProdLote:GetPrdOri()
				D14->D14_PRODUT := Self:oProdLote:GetProduto()
				D14->D14_LOTECT := Self:oProdLote:GetLoteCtl()
				D14->D14_NUMLOT := Self:oProdLote:GetNumLote()
				D14->D14_NUMSER := Self:oProdLote:GetNumSer()
				D14->D14_CODVOL := Self:cCodVolume
				D14->D14_IDVOLU := Self:cIdVolume
				D14->D14_IDUNIT := Self:cIdUnitiz
				If Self:lHasCodUni
					D14->D14_CODUNI := Self:cTipUni
				EndIf
				D14->D14_ESTFIS := Self:oEndereco:GetEstFis()
				D14->D14_PRIOR  := Self:oEndereco:GetPrior()
				lAnalisEnd := .T.
			EndIf

			If !Empty(Self:oProdLote:GetLoteCtl()) .And. Empty(D14->D14_DTVALD)
				D14->D14_DTVALD  := Self:oProdLote:GetDtValid()
				D14->D14_DTFABR  := Self:oProdLote:GetDtFabr()
			EndIf

			If cTipo == "499"
				If lEstoque
					D14->D14_QTDEST += Self:nQuant
					D14->D14_QTDES2 += nQtd2UM
				EndIf
				If lEntPrev
					D14->D14_QTDEPR += Self:nQuant
					D14->D14_QTDEP2 += nQtd2UM
				EndIf
				If lSaiPrev
					D14->D14_QTDSPR += Self:nQuant
					D14->D14_QTDSP2 += nQtd2UM
				EndIf
				If lEmpenho
					D14->D14_QTDEMP += Self:nQuant
					D14->D14_QTDEM2 += nQtd2UM
				EndIf
				If lBloqueio
					D14->D14_QTDBLQ += Self:nQuant
					D14->D14_QTDBL2 += nQtd2UM
				EndIf
				If lEmpPrev
					D14->D14_QTDPEM += Self:nQuant
					D14->D14_QTDPE2 += nQtd2UM
				EndIf
			Else
				If lEstoque
					D14->D14_QTDEST -= Self:nQuant
					D14->D14_QTDES2 -= nQtd2UM
				EndIf
				If lEntPrev
					D14->D14_QTDEPR -= Self:nQuant
					D14->D14_QTDEP2 -= nQtd2UM
				EndIf
				If lSaiPrev
					D14->D14_QTDSPR -= Self:nQuant
					D14->D14_QTDSP2 -= nQtd2UM
				EndIf
				If lEmpenho
					D14->D14_QTDEMP -= Self:nQuant
					D14->D14_QTDEM2 -= nQtd2UM
				EndIf
				If lBloqueio
					D14->D14_QTDBLQ -= Self:nQuant
					D14->D14_QTDBL2 -= nQtd2UM
				EndIf
				If lEmpPrev
					D14->D14_QTDPEM -= Self:nQuant
					D14->D14_QTDPE2 -= nQtd2UM
				EndIf
			EndIf
			// Verifica se quantidade foram zeradas.
			If QtdComp(D14->D14_QTDEST) == 0 .AND. QtdComp(D14->D14_QTDEPR) == 0 .AND. QtdComp(D14->D14_QTDSPR) == 0 .AND. QtdComp(D14->D14_QTDEMP) == 0 .AND. QtdComp(D14->D14_QTDBLQ) == 0 .AND. QtdComp(D14->D14_QTDPEM) == 0
				D14->(dbDelete())
				lAnalisEnd := .T.
			EndIf
			D14->(MsUnLock())
			// Permite o preenchimento de campos customizados na Atualização de Saldo WMS
			If _lWMSATD14
				ExecBlock("WMSATD14",.F.,.F.,{cTipo,lEstoque,lEntPrev,lSaiPrev,lEmpenho,lBloqueio,lEmpPrev})
			EndIf
			If lAnalisEnd
				Self:UpdEnder()
			EndIf
			If lMovEstEnd
				// Realiza a movimentação do kardex toda vez que atualiza o Estoque
				Self:GeraMovEst(cTipo)
			EndIf
		EndIf
	EndIf
	RestArea(aAreaD14)
Return lRet
//----------------------------------------
/*/{Protheus.doc} ConsultSld
Consulta do saldo do produto no estoque endereço
@author felipe.m
@since 23/12/2014
@version 1.0
@param lEntPrevista, ${logico}, (Considerar saldo com entrada prevista)
@param lSaiPrevista, ${logico}, (Considerar saldo com saida prevista)
@param lEmpenho, ${logico}, (Considerar saldo com quantidade empenhada)
@param lBloqueado, ${logico}, (Considerar saldo com quantidade bloqueada)
/*/
//----------------------------------------
METHOD ConsultSld(lEntPrevista,lSaiPrevista,lEmpenho,lBloqueado) CLASS WMSDTCEstoqueEndereco
Local aAreaD14       := D14->(GetArea())
Local cQuery         := ""
Local cAliasD14      := GetNextAlias()
Local nSaldo         := 0

Default lEntPrevista := .F.
Default lSaiPrevista := .F.
Default lEmpenho     := .T.
Default lBloqueado   := .T.
	// Monta query
	cQuery := "% SUM (D14_QTDEST "
	If lEntPrevista
		cQuery += " + D14_QTDEPR "
	EndIf
	If lSaiPrevista
		cQuery += " - D14_QTDSPR "
	EndIf
	If lEmpenho
		cQuery += " - D14_QTDEMP "
	EndIf
	If lBloqueado
		cQuery += " - D14_QTDBLQ "
	EndIf
	cQuery += ") D14_QTDSLD "
	cQuery += " FROM " + RetSqlName('D14')+" D14"
	// Verifica se considera saldo em produção
	If Self:lProducao <> Nil
		cQuery +=  " INNER JOIN "+RetSqlName('DC8')+" DC8"
		cQuery +=     " ON DC8.DC8_FILIAL = '"+xFilial('DC8')+"'"
		cQuery +=    " AND DC8.DC8_CODEST = D14.D14_ESTFIS"
		If Self:lProducao
			cQuery += " AND DC8.DC8_TPESTR = '7'"
		Else
			cQuery += " AND DC8.DC8_TPESTR <> '7'"
		EndIf
		cQuery +=    " AND DC8.D_E_L_E_T_ = ' '"
	EndIf
	cQuery += " WHERE D14.D14_FILIAL = '"+xFilial("D14")+"'"
	If !Empty(Self:oEndereco:GetArmazem())
		cQuery += " AND D14.D14_LOCAL = '"+Self:oEndereco:GetArmazem()+"'"
	EndIf
	If !Empty(Self:oEndereco:GetEnder())
		cQuery += " AND D14.D14_ENDER = '"+Self:oEndereco:GetEnder()+"'"
	EndIf
	If !Empty(Self:oEndereco:GetEstFis())
		cQuery += " AND D14.D14_ESTFIS = '"+Self:oEndereco:GetEstFis()+"'"
	EndIf
	If !Empty(Self:oProdLote:GetProduto())
		cQuery += " AND D14.D14_PRODUT = '"+Self:oProdLote:GetProduto()+"'"
	EndIf
	If !Empty(Self:oProdLote:GetPrdOri())
		cQuery += " AND D14.D14_PRDORI = '"+Self:oProdLote:GetPrdOri()+"'"
	EndIf
	If !Empty(Self:oProdLote:GetLoteCtl())
		cQuery += " AND D14.D14_LOTECT = '"+Self:oProdLote:GetLoteCtl()+"'"
	EndIf
	If !Empty(Self:oProdLote:GetNumLote())
		cQuery += " AND D14.D14_NUMLOT = '"+Self:oProdLote:GetNumLote()+"'"
	EndIf
	If !Empty(Self:oProdLote:GetNumSer())
		cQuery += " AND D14.D14_NUMSER = '"+Self:oProdLote:GetNumSer()+"'"
	EndIf
	If !Empty(Self:cIdUnitiz)
		cQuery += " AND D14.D14_IDUNIT = '"+Self:cIdUnitiz+"'"
	EndIf
	If !Empty(Self:oProdLote:GetDtValid())
		cQuery += " AND D14.D14_DTVALD = '"+DTOS(Self:oProdLote:GetDtValid())+"'"
	EndIf
	If !Empty(Self:oProdLote:GetDtFabr())
		cQuery += " AND D14.D14_DTFABR = '"+DTOS(Self:oProdLote:GetDtFabr())+"'"
	EndIf
	If !Empty(Self:GetCodVol())
		cQuery += " AND D14.D14_CODVOL = '"+ Self:GetCodVol()+"'"
	EndIf
	If !Empty(Self:GetIdVolu())
		cQuery += " AND D14.D14_IDVOLU = '"+ Self:GetIdVolu()+"'"
	EndIf
	If !Empty(Self:GetIdUnit())
		cQuery += " AND D14.D14_IDUNIT = '"+ Self:GetIdUnit()+"'"
	EndIf
	cQuery += " AND D14.D_E_L_E_T_ = ' '"
	cQuery += "%"
	BeginSql Alias cAliasD14
		SELECT %Exp:cQuery%
	EndSql
	nSaldo := (cAliasD14)->D14_QTDSLD
	(cAliasD14)->( dbCloseArea() )
	RestArea(aAreaD14)
Return nSaldo
//----------------------------------------
/*/{Protheus.doc} FindSldEnd
Consulta do saldo do produto no estoque endereço
@author felipe.m
@since 23/12/2014
@version 1.0
@param lEntPrevista, ${logico}, (Considerar saldo com entrada prevista)
@param lSaiPrevista, ${logico}, (Considerar saldo com saida prevista)
@param lEmpenho, ${logico}, (Considerar saldo com quantidade empenhada)
@param lBloqueado, ${logico}, (Considerar saldo com quantidade bloqueada)
/*/
//----------------------------------------
METHOD FindSldEnd(cArmazem, cEndereco, cEstFis, cPrdOri, cProduto, cLoteCtl, cNumLote, cNumserie, lEntrPrev, lSaidaPrev, lEmpenho, lBloqueio, cIdUnitiz) CLASS WMSDTCEstoqueEndereco
Default cNumLote := ""

Default lEntrPrev  := .F.
Default lSaidaPrev := .F.
Default lEmpenho   := .F.
Default lBloqueio  := .F.
Default cIdUnitiz  := ""
	// Dados do endereço
	Self:oEndereco:SetArmazem(cArmazem)
	Self:oEndereco:SetEnder(cEndereco)
	Self:oEndereco:SetEstFis(cEstFis)
	// Dados do produto
	Self:oProdLote:SetArmazem(cArmazem)
	Self:oProdLote:SetPrdOri(cPrdOri)
	Self:oProdLote:SetProduto(cProduto)
	Self:oProdLote:SetLoteCtl(cLoteCtl)
	Self:oProdLote:SetNumLote(cNumLote)
	Self:oProdLote:SetNumSer(cNumserie)
	Self:SetIdUnit(cIdUnitiz)
	// Consulta o saldo pelo WMS
Return Self:ConsultSld(lEntrPrev, lSaidaPrev, lEmpenho, lBloqueio)
//----------------------------------------
/*/{Protheus.doc} FindSldCmp
Consulta do saldo comprometido do produto no estoque endereço
@author alexsander.correa
@since 22/02/2016
@version 1.0
/*/
//----------------------------------------
METHOD FindSldCmp(cArmazem, cEndereco, cProduto, cLoteCtl, cNumLote, cNumSerie, cIdUnitiz) CLASS WMSDTCEstoqueEndereco
Local lRastro     := Rastro(cProduto)
Local aAreaSB2    := SB2->(GetArea())
Local aAreaD11    := D11->(GetArea())
Local cAliasQry   := Nil
Local nComprom    := 0
Local nReserva    := 0
Local nEstoque    := 0
Local nSldDifEnd  := 0
Default cNumLote  := ""
Default cNumSerie := ""
Default cIdUnitiz := ""
	// Dados do endereço
	Self:oEndereco:SetArmazem(cArmazem)
	Self:oEndereco:SetEnder(cEndereco)
	// Dados do produto
	Self:oProdLote:SetArmazem(cArmazem)
	Self:oProdLote:SetProduto(cProduto)
	Self:oProdLote:SetLoteCtl(cLoteCtl)
	Self:oProdLote:SetNumLote(cNumLote)
	Self:oProdLote:SetNumSer(cNumSerie)
	Self:SetIdUnit(cIdUnitiz)
	If Self:LoadData(3)
		nEstoque := Self:GetQtdEst()
		nComprom := Self:GetQtdSPr() + Self:GetQtdBlq() + Self:GetQtdEmp()
		If QtdComp(nEstoque) > QtdComp(nComprom)
			If !lRastro
				cAliasQry := GetNextAlias()
				BeginSql Alias cAliasQry
					SELECT SUM(TOT.B2_RESERVA) B2_RESERVA
					FROM (SELECT SB2.B2_RESERVA B2_RESERVA
							FROM %Table:SB2% SB2
							WHERE SB2.B2_FILIAL = %xFilial:SB2%
							AND SB2.B2_COD = %Exp:cProduto%
							AND SB2.B2_LOCAL = %Exp:cArmazem%
							AND SB2.%NotDel%
							UNION ALL
							SELECT (SB2.B2_RESERVA * D11.D11_QTMULT) B2_RESERVA
							FROM %Table:D11% D11
							INNER JOIN %Table:SB2% SB2
							ON SB2.B2_FILIAL = %xFilial:SB2%
							AND SB2.B2_COD = D11.D11_PRDORI
							AND SB2.B2_LOCAL = %Exp:cArmazem%
							AND SB2.%NotDel%
							WHERE D11.D11_FILIAL = %xFilial:D11%
							AND D11.D11_PRODUT = %Exp:cProduto%
							AND D11.%NotDel%) TOT
				EndSql
				TcSetField(cAliasQry,'B2_RESERVA','N',Self:aB2_RESERVA[1],Self:aB2_RESERVA[2])
				If (cAliasQry)->(!Eof())
					nReserva := (cAliasQry)->B2_RESERVA
				EndIf
				(cAliasQry)->(dbCloseArea())
			Else
				cAliasQry := GetNextAlias()
				BeginSql Alias cAliasQry
					SELECT SUM(TOT.B8_EMPENHO) B8_EMPENHO
					FROM (SELECT SB8.B8_EMPENHO B8_EMPENHO
							FROM %Table:SB8% SB8
							WHERE SB8.B8_FILIAL = %xFilial:SB8%
							AND SB8.B8_PRODUTO= %Exp:cProduto%
							AND SB8.B8_LOCAL = %Exp:cArmazem%
							AND SB8.B8_LOTECTL = %Exp:cLoteCtl%
							AND SB8.B8_NUMLOTE = %Exp:cNumLote%
							AND SB8.%NotDel%
							UNION ALL
							SELECT SB8.B8_EMPENHO * D11.D11_QTMULT B8_EMPENHO
							FROM %Table:D11% D11
							INNER JOIN %Table:SB8% SB8
							ON SB8.B8_FILIAL = %xFilial:SB2%
							AND SB8.B8_PRODUTO = D11.D11_PRDORI
							AND SB8.B8_LOCAL = %Exp:cArmazem%
							AND SB8.B8_LOTECTL = %Exp:cLoteCtl%
							AND SB8.B8_NUMLOTE = %Exp:cNumLote%
							AND SB8.%NotDel%
							WHERE D11.D11_FILIAL = %xFilial:D11%
							AND D11.D11_PRODUT = %Exp:cProduto%
							AND D11.%NotDel%) TOT
				EndSql
				TcSetField(cAliasQry,'B8_EMPENHO','N',Self:aB8_EMPENHO[1],Self:aB8_EMPENHO[2])
				If (cAliasQry)->(!Eof())
					nReserva := (cAliasQry)->B8_EMPENHO
				EndIf
				(cAliasQry)->(dbCloseArea())
			EndIf
			// Reserva sem empenho previsto
			nReserva -= Self:GetQtdPem()
			// Busca quantidade
			cAliasQry := GetNextAlias()
			BeginSql Alias cAliasQry
				SELECT SUM(D14.D14_QTDEST - (D14.D14_QTDSPR+D14.D14_QTDBLQ+D14.D14_QTDEMP)) D14_QTDEST, // Quantidade disponível do produto nos outros endereços
						SUM(D14.D14_QTDPEM+D14.D14_QTDEMP) D14_QTDPEM // Quantidade de empenho previstos do produtos no outros endereços que virar empenho
				FROM %Table:D14% D14
				WHERE D14.D14_FILIAL = %xFilial:D14%
				AND D14.D14_LOCAL = %Exp:cArmazem%
				AND D14.D14_ENDER <> %Exp:cEndereco%
				AND D14.D14_PRODUT = %Exp:cProduto%
				AND D14.D14_LOTECT = %Exp:cLoteCtl%
				AND D14.D14_NUMLOT = %Exp:cNumLote%
				AND D14.D14_NUMSER = %Exp:cNumSerie%
				AND D14.%NotDel%
			EndSql
			TcSetField(cAliasQry,'D14_QTDEST','N',Self:aD14_QTDEST[1],Self:aD14_QTDEST[2])
			If (cAliasQry)->(!Eof())
				nSldDifEnd := (cAliasQry)->D14_QTDEST
				// Desconta do saldo de reserva do produto a quantidade de empenho previsto dos outros endereços
				nReserva -= (cAliasQry)->D14_QTDPEM
			EndIf
			(cAliasQry)->(dbCloseArea())
			// Calcula se há reserva e verifica se o saldo disponível do outros endereço é suficiente para atendê-los
			nComprom += IIf(QtdComp(nReserva-nSldDifEnd) < 0, 0,nReserva-nSldDifEnd)
		EndIf
	EndIf
	RestArea(aAreaSB2)
	RestArea(aAreaD11)
Return nComprom
//----------------------------------------
/*/{Protheus.doc} HaveSaldo
Retorno logico se possui saldo, de acordo com os dados setados
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//----------------------------------------
METHOD HaveSaldo() CLASS WMSDTCEstoqueEndereco
Local lRet := .T.
	lRet := Self:ConsultSld(.T.,.F.,.F.,.F.) > 0
Return lRet
//----------------------------------------
/*/{Protheus.doc} EndUsaComp
Verifica se o endereço utiliza compartilhamento
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//----------------------------------------
METHOD EndUsaComp() CLASS WMSDTCEstoqueEndereco
Local aAreaD14  := D14->(GetArea())
Local lRet      := .T.
Local lRetPE    := .T.
Local cAliasD14 := GetNextAlias()
Local oProdAdic := WMSDTCProdutoDadosAdicionais():New()
Local oSeqAbast := WMSDTCSequenciaAbastecimento():New()

	If (Empty(Self:oEndereco:GetArmazem()).OR. Empty(Self:oEndereco:GetEnder()).OR. Empty(Self:oProdLote:GetProduto()))
		lRet       := .F.
		Self:cErro := STR0001 // Dados para busca não foram informados!
	EndIf
	If lRet
		Self:oEndereco:LoadData()
		Self:oProdLote:LoadData()
		// Carregando saldo do endereço para outros produtos
		BeginSql Alias cAliasD14
			SELECT  D14.D14_PRODUT
			FROM %Table:D14% D14
			WHERE D14.D14_FILIAL = %xFilial:D14%
			AND D14.D14_LOCAL = %Exp:Self:oEndereco:GetArmazem()%
			AND D14.D14_ESTFIS = %Exp:Self:oEndereco:GetEstFis()%
			AND D14.D14_ENDER = %Exp:Self:oEndereco:GetEnder()%
			AND D14.D14_PRODUT <> %Exp:Self:oProdLote:GetProduto()% //Somente considera se for produto diferente
			AND (D14.D14_QTDEST + D14.D14_QTDEPR) > 0
			AND D14.%NotDel%
			GROUP BY D14.D14_PRODUT
		EndSql
		// efetua a análise do produto que já estiver armazenado no endereço (2o passo abaixo).
		// Só analisa o primeiro produto, pois se este permite, os demais foram analisados antes
		If (cAliasD14)->(!Eof())
			oProdAdic:SetProduto((cAliasD14)->D14_PRODUT)
			If (lRet := oProdAdic:LoadData())
				// Permite customizar a validação padrão de cadastro de produtos no processo de compartilhamento de endereços
				If _lWMSCPEND
					lRetPE := ExecBlock("WMSCPEND",.F.,.F.,{Self:oProdLote:GetProduto(),oProdAdic:GetProduto()})
					lRet   := Iif(ValType(lRetPE)=='L',lRetPE,.T.)
				Else
					// Verifica se as caracteristicas de tipo e grupo são iguais
					lRet := ((Self:oProdLote:GetTipo() == oProdAdic:GetTipo()) .AND. (Self:oProdLote:GetGrupo() == oProdAdic:GetGrupo()))
				EndIf
			EndIf
			If lRet
				// Carrega seq abastecimento
				oSeqAbast:SetArmazem(Self:oEndereco:GetArmazem())
				oSeqAbast:SetProduto(oProdAdic:GetProduto())
				oSeqAbast:SetEstFis(Self:oEndereco:GetEstFis())
				If (lRet := oSeqAbast:LoadData(2))
					// Se o tipo de endereçamento permite compartilhar endereços com produtos diferentes
					If (lRet := (oSeqAbast:GetTipoEnd() == "4"))
						// Só valida a norma para estruturas do tipo pulmão ou picking
						If Self:oEndereco:GetTipoEst() == 1 .Or. Self:oEndereco:GetTipoEst() == 2
							lRet := (oSeqAbast:GetCodNor() == Self:cCodNorma)
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
		(cAliasD14)->(DbCloseArea())
	EndIf
	RestArea(aAreaD14)
Return lRet
//----------------------------------------
/*/{Protheus.doc} GetSldPart
Retorna o saldo das partes com base no produto origem setado
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//----------------------------------------
METHOD GetSldPart(cArmazem,dDataInv,lSldComp) CLASS WMSDTCEstoqueEndereco
Local aProdComp := {}
Local aSldPart := {}
Local nI := 0
Local cProdAnt := ""
// Define se procura o saldo como componente ou produto
Default cArmazem := ""
Default dDataInv := dDatabase
Default lSldComp := .T.
	Self:oProdLote:oProduto:CreateArr()
	aProdComp := Self:oProdLote:GetArrProd()
	cProdAnt  := Self:oProdLote:GetProduto()

	For nI := 1 To Len(aProdComp)
		Self:oProdLote:SetPrdOri(Iif(lSldComp,aProdComp[nI][3],aProdComp[nI][1]))
		Self:oProdLote:SetProduto(aProdComp[nI][1])
		aAdd(aSldPart,{aProdComp[nI][1],aProdComp[nI][2],Self:CalcEstWms(cArmazem,aProdComp[nI][1],dDataInv,,,,,3,Self:oProdLote:GetPrdOri())})
	Next nI

	Self:oProdLote:SetProduto(cProdAnt)
Return aSldPart
//----------------------------------------
/*/{Protheus.doc} GetSldOrig
Retorna o saldo do produto origem com base no saldo das partes
@author felipe.m
@since 23/12/2014
@param lMontado   .T.-> Calcular quanto do produto PAI existe montado   (analise das partes montadas)
                  .F.-> Calcular quanto do produto PAI pode ser montado (analise das partes desmontadas)

@param lConsReser .T.-> Considerar o saldo físico menos o saldo comprometido, retornando apenas o saldo disponível
                  .F.-> Considerar o saldo físico, retornando o saldo real
@param lPai       .T.-> Indica que o produto é um produto pai, então enxerga o menor saldo D14 dos produtos filhos
                  .F.-> Indica que o produto é um produto normal, então exerga o saldo da D14
@version 4.0
/*/
//----------------------------------------
METHOD GetSldOrig(lMontado,lConsReser,lPai) CLASS WMSDTCEstoqueEndereco
Local lRastro    := .F.
Local lSubLot    := .F.
Local aAreaAnt := GetArea()
Local cAliasQry  := Nil
Local cAliasQry2 := Nil
Local cLoteCtl   := ""
Local cNumLote   := ""
Local cPrdOri    := ""
Local nMinSaldo  := Nil
Local nSaldo     := 0
Local nEmpenho   := 0
Local nLotReserv := 0
Local nB8Saldo   := 0
Local nB2Reserva := 0
Local nB8Disponi := 0
Local nSomaLot   := 0
Local dDtValid   := dDataBase

Default lMontado := .T.
Default lConsReser := .T.
Default lPai := WmsPrdPai(Self:oProdLote:GetPrdOri())

	dbSelectArea("D14")// Força area ativa para a função Rastro
	If (lRastro := Rastro(Self:oProdLote:GetPrdOri()))
		lSubLot := Rastro(Self:oProdLote:GetPrdOri(),"S")
	EndIf

	If !lRastro
		// Calculo do saldo de um produto sem lote
		// Utilizado no inventário!
		// Parâmetro Where
		cWhere := "%"
		If !Empty(Self:oProdLote:GetNumSer())
			cWhere +=        " AND D14.D14_NUMSER = '" + Self:oProdLote:GetNumSer() + "'"
		EndIf
		If !Empty(Self:cIdUnitiz)
			cWhere +=        " AND D14.D14_IDUNIT = '"+Self:cIdUnitiz+"'"
		EndIf
		cWhere += "%"
		cAliasQry := GetNextAlias()
		If lConsReser
			If lMontado
				BeginSql Alias cAliasQry
					SELECT MIN(CASE WHEN SLD.D14_QTDISP IS NULL THEN 0 ELSE SLD.D14_QTDISP END) SALDO
					FROM ( SELECT PRD.PRD_CODIGO,
									(SUM(D14.D14_QTDEST / PRD.PRD_QTMULT)                                           // Estoque D14
										- (SUM((D14.D14_QTDSPR + D14.D14_QTDEMP + D14.D14_QTDBLQ) / PRD.PRD_QTMULT) // Movimentações WMS D14 
										+ ( SB2.B2_RESERVA                                                          // Reserva estoque SB2/SB8
										- SUM((D14.D14_QTDPEM + D14.D14_QTDEMP) / PRD.PRD_QTMULT)))                 // Reserva WMS D14
									) D14_QTDISP
							FROM ( SELECT CASE WHEN D11.D11_PRDCMP IS NULL THEN SB5.B5_COD ELSE D11.D11_PRDCMP END PRD_CODIGO,
											CASE WHEN D11.D11_QTMULT IS NULL THEN 1 ELSE D11.D11_QTMULT END PRD_QTMULT
									FROM %Table:SB5% SB5
									LEFT JOIN %Table:D11% D11
									ON D11.D11_FILIAL = %xFilial:D11%
									AND SB5.B5_FILIAL = %xFilial:SB5%
									AND D11.D11_PRODUT = SB5.B5_COD
									AND D11.D11_PRDORI = SB5.B5_COD
									AND D11.%NotDel%
									WHERE SB5.B5_FILIAL = %xFilial:SB5%
									AND SB5.B5_COD = %Exp:Self:oProdLote:GetPrdOri()%
									AND SB5.%NotDel% ) PRD
							LEFT JOIN %Table:D14% D14
							ON D14.D14_FILIAL = %xFilial:D14%
							AND D14.D14_LOCAL  = %Exp:Self:oProdLote:GetArmazem()%
							AND D14.D14_PRDORI = %Exp:Self:oProdLote:GetPrdOri()%
							AND D14.D14_PRODUT = PRD.PRD_CODIGO
							AND D14.%NotDel%
							%Exp:cWhere%
							LEFT JOIN %Table:SB2% SB2
							ON SB2.B2_FILIAL = %xFilial:SB2%
							AND D14.D14_FILIAL = %xFilial:D14%
							AND SB2.B2_LOCAL = D14.D14_LOCAL
							AND SB2.B2_COD = D14.D14_PRDORI
							AND SB2.%NotDel%
							GROUP BY PRD.PRD_CODIGO, 
										SB2.B2_RESERVA,
										PRD.PRD_QTMULT) SLD
				EndSql
			Else
				BeginSql Alias cAliasQry
					SELECT MIN(CASE WHEN SLD.D14_QTDISP IS NULL THEN 0 ELSE SLD.D14_QTDISP END) SALDO
					FROM (SELECT PRD.PRD_CODIGO,
									(SUM(D14.D14_QTDEST / PRD.PRD_QTMULT)                                            // Estoque D14
										- (SUM((D14.D14_QTDSPR + D14.D14_QTDEMP + D14.D14_QTDBLQ) / PRD.PRD_QTMULT)  // Movimentações WMS D14
										+ (SB2.B2_RESERVA/PRD.PRD_QTMULT)                                            // Reserva estoque SB2/SB8
										- SUM((D14.D14_QTDPEM + D14.D14_QTDEMP) / PRD.PRD_QTMULT))                  // Reserva WMS D14
									) D14_QTDISP
							FROM (SELECT CASE WHEN D11.D11_PRDCMP IS NULL THEN SB5.B5_COD ELSE D11.D11_PRDCMP END PRD_CODIGO,
											CASE WHEN D11.D11_QTMULT IS NULL THEN 1 ELSE D11.D11_QTMULT END PRD_QTMULT
									FROM %Table:SB5% SB5
									LEFT JOIN %Table:D11% D11
									ON D11.D11_FILIAL =  %xFilial:D11%
									AND SB5.B5_FILIAL  = %xFilial:SB5%
									AND D11.D11_PRODUT = SB5.B5_COD
									AND D11.D11_PRDORI = SB5.B5_COD
									AND D11.%NotDel%
									WHERE SB5.B5_FILIAL  = %xFilial:SB5%
									AND SB5.B5_COD = %Exp:Self:oProdLote:GetPrdOri()%
									AND SB5.%NotDel% ) PRD
									LEFT JOIN %Table:D14% D14
									ON D14.D14_FILIAL = %xFilial:D14%
									AND D14.D14_LOCAL = %Exp:Self:oProdLote:GetArmazem()%
									AND D14.D14_PRDORI = PRD.PRD_CODIGO
									AND D14.D14_PRODUT = PRD.PRD_CODIGO
									AND D14.%NotDel%
									%Exp:cWhere%
									LEFT JOIN %Table:SB2% SB2
									ON SB2.B2_FILIAL = %xFilial:SB2%
									AND D14.D14_FILIAL = %xFilial:D14%
									AND SB2.B2_LOCAL = D14.D14_LOCAL
									AND SB2.B2_COD = D14.D14_PRDORI
									AND SB2.%NotDel%
									GROUP BY PRD.PRD_CODIGO,
												SB2.B2_RESERVA,
												PRD.PRD_QTMULT) SLD
				EndSql
			EndIf
		Else
			If lMontado
				BeginSql Alias cAliasQry
					SELECT MIN(CASE WHEN SLD.D14_QTDISP IS NULL THEN 0 ELSE SLD.D14_QTDISP END) SALDO
					FROM ( SELECT PRD.PRD_CODIGO,
									SUM(D14.D14_QTDEST / PRD.PRD_QTMULT) D14_QTDISP // Estoque D14
							FROM ( SELECT CASE WHEN D11.D11_PRDCMP IS NULL THEN SB5.B5_COD ELSE D11.D11_PRDCMP END PRD_CODIGO,
											CASE WHEN D11.D11_QTMULT IS NULL THEN 1 ELSE D11.D11_QTMULT END PRD_QTMULT
									FROM %Table:SB5% SB5
									LEFT JOIN %Table:D11% D11
									ON D11.D11_FILIAL = %xFilial:D11%
									AND SB5.B5_FILIAL = %xFilial:SB5%
									AND D11.D11_PRODUT = SB5.B5_COD
									AND D11.D11_PRDORI = SB5.B5_COD
									AND D11.%NotDel%
									WHERE SB5.B5_FILIAL  = %xFilial:SB5%
									AND SB5.B5_COD = %Exp:Self:oProdLote:GetPrdOri()%
									AND SB5.%NotDel% ) PRD
									LEFT JOIN %Table:D14% D14
									ON D14.D14_FILIAL = %xFilial:D14%
									AND D14.D14_LOCAL = %Exp:Self:oProdLote:GetArmazem()%
									AND D14.D14_PRDORI = %Exp:Self:oProdLote:GetPrdOri()%
									AND D14.D14_PRODUT = PRD.PRD_CODIGO
									AND D14.%NotDel%
									%Exp:cWhere%
									GROUP BY PRD.PRD_CODIGO,
												PRD.PRD_QTMULT) SLD
				EndSql
			Else
				BeginSql Alias cAliasQry
					SELECT MIN(CASE WHEN SLD.D14_QTDISP IS NULL THEN 0 ELSE SLD.D14_QTDISP END) SALDO
					FROM ( SELECT PRD.PRD_CODIGO,
									SUM(D14.D14_QTDEST / PRD.PRD_QTMULT) D14_QTDISP // Estoque D14
							FROM ( SELECT CASE WHEN D11.D11_PRDCMP IS NULL THEN SB5.B5_COD ELSE D11.D11_PRDCMP END PRD_CODIGO,
											CASE WHEN D11.D11_QTMULT IS NULL THEN 1 ELSE D11.D11_QTMULT END PRD_QTMULT
									FROM %Table:SB5% SB5
									LEFT JOIN %Table:D11% D11
									ON D11.D11_FILIAL = %xFilial:D11%
									AND SB5.B5_FILIAL = %xFilial:SB5%
									AND D11.D11_PRODUT = SB5.B5_COD
									AND D11.D11_PRDORI = SB5.B5_COD
									AND D11.%NotDel%
									WHERE SB5.B5_FILIAL = %xFilial:SB5%
									AND SB5.B5_COD = %Exp:Self:oProdLote:GetPrdOri()%
									AND SB5.%NotDel% ) PRD
							LEFT JOIN %Table:D14% D14
							ON D14.D14_FILIAL = %xFilial:D14%
							AND D14.D14_LOCAL  = %Exp:Self:oProdLote:GetArmazem()%
							AND D14.D14_PRDORI = PRD.PRD_CODIGO
							AND D14.D14_PRODUT = PRD.PRD_CODIGO
							AND D14.%NotDel%
							%Exp:cWhere%
							GROUP BY PRD.PRD_CODIGO,
										PRD.PRD_QTMULT) SLD
				EndSql
			EndIf
		EndIf
		TCSetField(cAliasQry,'SALDO','N',Self:aD14_QTDEST[1],Self:aD14_QTDEST[2])
		If (cAliasQry)->(!Eof())
			nSaldo := Iif(Empty((cAliasQry)->SALDO),0,(cAliasQry)->SALDO)
		EndIf
		(cAliasQry)->(dbCloseArea())
	Else
		If lMontado
			If lConsReser
				// Busca informações SB2/SB8 do produto para utilizar no rateio de reserva do lote
				cAliasQry := GetNextAlias()
				BeginSql Alias cAliasQry
					SELECT SB2.B2_RESERVA,
							SUM(SB8.B8_SALDO) B8_SALDO,
							SUM(SB8.B8_EMPENHO) B8_EMPENHO
					FROM %Table:SB2% SB2
					LEFT JOIN %Table:SB8% SB8
					ON SB8.B8_FILIAL = %xFilial:SB8%
					AND SB8.B8_PRODUTO = SB2.B2_COD
					AND SB8.B8_LOCAL = SB2.B2_LOCAL
					AND SB8.%NotDel%
					WHERE SB2.B2_FILIAL = %xFilial:SB2%
					AND SB2.B2_COD = %Exp:Self:oProdLote:GetPrdOri()%
					AND SB2.B2_LOCAL = %Exp:Self:oProdLote:GetArmazem()%
					AND SB2.%NotDel%
					GROUP BY SB2.B2_COD,
								SB2.B2_LOCAL,
								SB2.B2_RESERVA
				EndSql
				TCSetField(cAliasQry,'B2_RESERVA','N',Self:aB2_RESERVA[1],Self:aB2_RESERVA[2])
				TCSetField(cAliasQry,'B8_SALDO'  ,'N',TamSx3("B8_SALDO")[1]  ,TamSx3("B8_SALDO")[2])
				TCSetField(cAliasQry,'B8_EMPENHO','N',Self:aB8_EMPENHO[1],Self:aB8_EMPENHO[2])
				If (cAliasQry)->(!Eof())
					nB8Disponi := (cAliasQry)->B8_SALDO - (cAliasQry)->B8_EMPENHO
					// Desconta da reserva SB2 a reserva que já está na SB8
					nB2Reserva := (cAliasQry)->B2_RESERVA - (cAliasQry)->B8_EMPENHO
				EndIf
				(cAliasQry)->(dbCloseArea())
			EndIf
			// Busca os lotes do produto
			// Parâmetro Where
			cWhere := "%"
			// Caso o lote seja passado a função, considera o lote informado
			If !Empty(Self:oProdLote:GetLotectl())
				cWhere += " AND SB8.B8_LOTECTL = '"+Self:oProdLote:GetLotectl()+"'"
			EndIf
			If lSubLot
				If !Empty(Self:oProdLote:GetNumLote())
					cWhere += " AND SB8.B8_NUMLOTE = '"+Self:oProdLote:GetNumLote()+"'"
				EndIf
			EndIf
			cWhere += "%"
			cAliasQry := GetNextAlias()
			BeginSql Alias cAliasQry
				SELECT SB8.B8_SALDO,
						SB8.B8_EMPENHO,
						SB8.B8_LOTECTL,
						SB8.B8_NUMLOTE,
						SB8.B8_DTVALID
				FROM %Table:SB8% SB8
				WHERE SB8.B8_FILIAL = %xFilial:SB8%
				AND SB8.B8_PRODUTO = %Exp:Self:oProdLote:GetPrdOri()%
				AND SB8.B8_LOCAL = %Exp:Self:oProdLote:GetArmazem()%
				AND SB8.B8_SALDO <> 0
				AND SB8.%NotDel%
				%Exp:cWhere%
			EndSql
			TCSetField(cAliasQry,'B8_SALDO'  ,'N',TamSx3("B8_SALDO")[1]  ,TamSx3("B8_SALDO")[2])
			TCSetField(cAliasQry,'B8_EMPENHO','N',TamSx3("B8_EMPENHO")[1],TamSx3("B8_EMPENHO")[2])
			TCSetField(cAliasQry,'B8_DTVALID','D',TamSx3("B8_DTVALID")[1],TamSx3("B8_DTVALID")[2])
			Do While (cAliasQry)->(!Eof())
				nB8Saldo := (cAliasQry)->B8_SALDO
				nEmpenho := (cAliasQry)->B8_EMPENHO
				cLoteCtl := (cAliasQry)->B8_LOTECTL
				cNumLote := (cAliasQry)->B8_NUMLOTE
				dDtValid := (cAliasQry)->B8_DTVALID

				If lConsReser
					// Considera a reserva da SB8
					nLotReserv := nEmpenho

					If nB8Saldo != nEmpenho .And. nB2Reserva > 0
						// Se não informou o lote faz rateio simples
						If Empty(Self:oProdLote:GetLotectl())
							If (nB8Saldo - nEmpenho) > 0
								If (nB8Saldo - nEmpenho) >= nB2Reserva
									nLotReserv += nB2Reserva
									nB2Reserva := 0
								Else
									nLotReserv += (nB8Saldo - nEmpenho)
									nB2Reserva -= (nB8Saldo - nEmpenho)
								EndIf
							EndIf
						Else
							// Se informou o lote e o saldo disponível na SB8 menos a reserva SB2 que não possui lote vinculado, for menor
							// que o saldo do lote em questão menos o que já está empenhado, então soma a reserva SB2, que não existe
							// vínculo com SB8, apenas o necessário para atendar a quantidade sem lote.
							If (nB8Disponi - nB2Reserva) < (nB8Saldo - nEmpenho)
								nLotReserv += ((nB8Saldo - nEmpenho) - (nB8Disponi - nB2Reserva))
								nB2Reserva -= ((nB8Saldo - nEmpenho) - (nB8Disponi - nB2Reserva))
							Else
								nB2Reserva := 0
							EndIf
						EndIf
					EndIf
				EndIf
				// Parâmetro Where
				cWhere := "%"
				If !Empty(Self:oProdLote:GetNumSer())
					cWhere += " AND D14.D14_NUMSER = '" + Self:oProdLote:GetNumSer() + "'"
				EndIf
				If !Empty(Self:cIdUnitiz)
					cWhere += " AND D14.D14_IDUNIT = '"+Self:cIdUnitiz+"'"
				EndIf
				cWhere += "%"
				cAliasQry2 := GetNextAlias()
				If lPai
					If lConsReser
						BeginSql Alias cAliasQry2
							SELECT MIN(CASE WHEN SLD.D14_QTDISP IS NULL THEN 0 ELSE SLD.D14_QTDISP END) SALDO
							FROM ( SELECT PRD.PRD_CODIGO,
											(SUM(D14.D14_QTDEST / PRD.PRD_QTMULT)                                                            // Estoque D14
												- (SUM((D14.D14_QTDSPR + D14.D14_QTDEMP + D14.D14_QTDBLQ) / PRD.PRD_QTMULT)                  // Movimentações WMS D14
												+ ( %Exp:nLotReserv% - SUM((D14.D14_QTDPEM + D14.D14_QTDEMP) / PRD.PRD_QTMULT))) // Reserva estoque SB2/SB8 - reserva WMS D14
											) D14_QTDISP
									FROM ( SELECT CASE WHEN D11.D11_PRDCMP IS NULL THEN SB5.B5_COD ELSE D11.D11_PRDCMP END PRD_CODIGO,
													CASE WHEN D11.D11_QTMULT IS NULL THEN 1 ELSE D11.D11_QTMULT END PRD_QTMULT
											FROM %Table:SB5% SB5
											LEFT JOIN %Table:D11% D11
											ON D11.D11_FILIAL = %xFilial:D11%
											AND SB5.B5_FILIAL = %xFilial:SB5%
											AND D11.D11_PRODUT = SB5.B5_COD
											AND D11.D11_PRDORI = SB5.B5_COD
											AND D11.%NotDel%
											WHERE SB5.B5_FILIAL  = %xFilial:SB5%
											AND SB5.B5_COD = %Exp:Self:oProdLote:GetPrdOri()%
											AND SB5.%NotDel% ) PRD
											LEFT JOIN %Table:D14% D14
											ON D14.D14_FILIAL = %xFilial:D14%
											AND D14.D14_LOCAL = %Exp:Self:oProdLote:GetArmazem()%
											AND D14.D14_PRDORI = %Exp:Self:oProdLote:GetPrdOri()%
											AND D14.D14_PRODUT = PRD.PRD_CODIGO
											AND D14.D14_LOTECT = %Exp:cLoteCtl%
											AND D14.D14_NUMLOT = %Exp:cNumLote%
											AND D14.%NotDel%
											%Exp:cWhere%
											GROUP BY PRD.PRD_CODIGO,
														PRD.PRD_QTMULT) SLD
						EndSql
					Else
						BeginSql Alias cAliasQry2
							SELECT MIN(CASE WHEN SLD.D14_QTDISP IS NULL THEN 0 ELSE SLD.D14_QTDISP END) SALDO
							FROM ( SELECT PRD.PRD_CODIGO,
											SUM(D14.D14_QTDEST / PRD.PRD_QTMULT) D14_QTDISP  // Estoque D14
									FROM ( SELECT CASE WHEN D11.D11_PRDCMP IS NULL THEN SB5.B5_COD ELSE D11.D11_PRDCMP END PRD_CODIGO,
													CASE WHEN D11.D11_QTMULT IS NULL THEN 1 ELSE D11.D11_QTMULT END PRD_QTMULT
											FROM %Table:SB5% SB5
											LEFT JOIN %Table:D11% D11
											ON D11.D11_FILIAL = %xFilial:D11%
											AND SB5.B5_FILIAL = %xFilial:SB5%
											AND D11.D11_PRODUT = SB5.B5_COD
											AND D11.D11_PRDORI = SB5.B5_COD
											AND D11.%NotDel%
											WHERE SB5.B5_FILIAL = %xFilial:SB5%
											AND SB5.B5_COD = %Exp:Self:oProdLote:GetPrdOri()%
											AND SB5.%NotDel% ) PRD
									LEFT JOIN %Table:D14% D14
									ON D14.D14_FILIAL = %xFilial:D14%
									AND D14.D14_LOCAL = %Exp:Self:oProdLote:GetArmazem()%
									AND D14.D14_PRDORI = %Exp:Self:oProdLote:GetPrdOri()%
									AND D14.D14_PRODUT = PRD.PRD_CODIGO
									AND D14.D14_LOTECT = %cLoteCtl%
									AND D14.D14_NUMLOT = %cNumLote%
									AND D14.%NotDel%
									%Exp:cWhere
									GROUP BY PRD.PRD_CODIGO,
												PRD.PRD_QTMULT) SLD
						EndSql
					EndIf
				Else
					If lConsReser
						BeginSql Alias cAliasQry2
							SELECT D14.D14_PRODUT,
									(SUM(D14.D14_QTDEST)                                                      // Estoque D14
									- (SUM(D14.D14_QTDSPR + D14.D14_QTDEMP + D14.D14_QTDBLQ)                  // Movimentações WMS D14
									+ ( %Exp:nLotReserv% - SUM(D14.D14_QTDPEM + D14.D14_QTDEMP)))  // Reserva estoque SB2/SB8 - reserva WMS D14
									) SALDO
							FROM %Table:D14% D14
							WHERE D14.D14_FILIAL = %xFilial:D14%
							AND D14.D14_LOCAL = %Exp:Self:oProdLote:GetArmazem()%
							AND D14.D14_PRDORI = %Exp:Self:oProdLote:GetPrdOri()%
							AND D14.D14_LOTECT = %Exp:cLoteCtl%
							AND D14.D14_NUMLOT = %Exp:cNumLote%
							AND D14.%NotDel%
							%Exp:cWhere%
							GROUP BY D14.D14_PRODUT
						EndSql
					Else
						BeginSql Alias cAliasQry2
							SELECT D14.D14_PRODUT,
									SUM(D14.D14_QTDEST) SALDO // Estoque D14
							FROM %Table:D14% D14
							WHERE D14.D14_FILIAL = %xFilial:D14%
							AND D14.D14_LOCAL = %Exp:Self:oProdLote:GetArmazem()%
							AND D14.D14_PRDORI = %Exp:Self:oProdLote:GetPrdOri()%
							AND D14.D14_LOTECT = %Exp:cLoteCtl%
							AND D14.D14_NUMLOT = %Exp:cNumLote%
							AND D14.%NotDel%
							%Exp:cWhere%
							GROUP BY D14.D14_PRODUT
						EndSql
					EndIf
				EndIf
				TCSetField(cAliasQry2,'SALDO','N',Self:aD14_QTDEST[1],Self:aD14_QTDEST[2])
				If (cAliasQry2)->(!Eof())
					nSaldo += Iif(Empty((cAliasQry2)->SALDO),0,(cAliasQry2)->SALDO)
				EndIf
				(cAliasQry2)->(dbCloseArea())
				(cAliasQry)->(dbSkip())
			EndDo
			(cAliasQry)->(dbCloseArea())
		Else
			// Salva valor do objeto
			cPrdOri := Self:oProdLote:GetPrdOri()
			cLoteCtl := Self:oProdLote:GetLotectl()
			cAliasQry := GetNextAlias()
			If !Empty(Self:oProdLote:GetLotectl())
				BeginSql Alias cAliasQry
					SELECT DISTINCT SB8.B8_LOTECTL
					FROM %Table:SB8% SB8
					INNER JOIN %Table:D11% D11
					ON D11.D11_FILIAL = %xFilial:D11%
					AND D11.D11_PRODUT = %Exp:Self:oProdLote:GetPrdOri()%
					AND D11.D11_PRDORI = %Exp:Self:oProdLote:GetPrdOri()%
					AND D11.D11_PRDCMP = SB8.B8_PRODUTO
					AND D11.%NotDel%
					WHERE SB8.B8_FILIAL = %xFilial:SB8%
					AND SB8.B8_LOCAL = %Exp:Self:oProdLote:GetArmazem()%
					AND SB8.B8_LOTECTL = %Exp:Self:oProdLote:GetLotectl()%
					AND SB8.B8_SALDO <> 0
					AND SB8.%NotDel%
				EndSql
			Else
				BeginSql Alias cAliasQry
					SELECT DISTINCT SB8.B8_LOTECTL
					FROM %Table:SB8% SB8
					INNER JOIN %Table:D11% D11
					ON D11.D11_FILIAL = %xFilial:D11%
					AND D11.D11_PRODUT = %Exp:Self:oProdLote:GetPrdOri()%
					AND D11.D11_PRDORI = %Exp:Self:oProdLote:GetPrdOri()%
					AND D11.D11_PRDCMP = SB8.B8_PRODUTO
					AND D11.%NotDel%
					WHERE SB8.B8_FILIAL = %xFilial:SB8%
					AND SB8.B8_LOCAL = %Exp:Self:oProdLote:GetArmazem()%
					AND SB8.B8_SALDO <> 0
					AND SB8.%NotDel%
				EndSql
			EndIf
			Do While (cAliasQry)->(!Eof())
				nMinSaldo := Nil
				// Retorna valor original do objeto
				Self:oProdLote:SetPrdOri(cPrdOri)
				Self:oProdLote:SetLotectl(cLoteCtl)
				cAliasQry2 := GetNextAlias()
				BeginSql Alias cAliasQry2
					SELECT D11.D11_PRDCMP,
							D11.D11_QTMULT,
							CASE WHEN SB8.B8_LOTECTL IS NULL THEN 0 ELSE 1 END ORDEM
					FROM %Table:D11% D11
					LEFT JOIN %Table:SB8% SB8
					ON SB8.B8_FILIAL = %xFilial:SB8%
					AND SB8.B8_LOCAL = %Exp:Self:oProdLote:GetArmazem()%
					AND SB8.B8_PRODUTO = D11.D11_PRDCMP
					AND SB8.B8_LOTECTL = %Exp:(cAliasQry)->B8_LOTECTL%
					AND SB8.B8_SALDO <> 0
					AND SB8.%NotDel%
					WHERE D11.D11_FILIAL = %xFilial:D11%
					AND D11.D11_PRODUT = %Exp:Self:oProdLote:GetPrdOri()%
					AND D11.D11_PRDORI = %Exp:Self:oProdLote:GetPrdOri()%
					AND D11.%NotDel%
					ORDER BY ORDEM
				EndSql
				TCSetField(cAliasQry2,'ORDEM','N',1,0)
				Do While (cAliasQry2)->(!Eof())
					// Caso exista alguma parte sem saldo SB8, considera produto pai com saldo zero
					If (cAliasQry2)->ORDEM == 0
						nMinSaldo := 0
						Exit
					EndIf
					// Seta o produto filho e o lote na classe
					Self:oProdLote:SetPrdOri((cAliasQry2)->D11_PRDCMP)
					Self:oProdLote:SetLotectl((cAliasQry)->B8_LOTECTL)
					// Busca o saldo da parte
					nSaldo := (Self:GetSldOrig(.T.,.T.,.F.) / (cAliasQry2)->D11_QTMULT)

					// Considera o menor saldo entre os filhos deste lote
					If nMinSaldo != Nil
						If nSaldo < nMinSaldo
							nMinSaldo := nSaldo
						EndIf
					Else
						nMinSaldo := nSaldo
					EndIf

					(cAliasQry2)->(dbSkip())
				EndDo
				(cAliasQry2)->(dbCloseArea())

				// Considera a soma por lote do menor saldo entre os filhos de todos os lotes
				nSomaLot += Iif(nMinSaldo==Nil,0,nMinSaldo)

				(cAliasQry)->(dbSkip())
			EndDo
			(cAliasQry)->(dbCloseArea())

			// Retorna valor original do objeto
			Self:oProdLote:SetPrdOri(cPrdOri)
			Self:oProdLote:SetLotectl(cLoteCtl)
			nSaldo := nSomaLot
		EndIf
	EndIf

	RestArea(aAreaAnt)
Return nSaldo
//----------------------------------------
/*/{Protheus.doc} UndoFatur
Estorno do saldo na exclusão do faturamento
@author felipe.m
@since 23/12/2014
@version 1.0
@param nRecno, numérico, (Recno SC9)
@param lEmpenho, ${logico}, (Considerar a quantidade empenhada na exlusão)
/*/
//----------------------------------------
METHOD UndoFatur(nRecno, lEmpenho, cNFiscal, cNumSeq) CLASS WMSDTCEstoqueEndereco
Local lRet       := .T.
Local aProduto   := {}
Local aAreaSC9   := SC9->(GetArea())
Local oProdLote  := WMSDTCProdutoLote():New()
Local oMovEstEnd := WMSDTCMovimentosEstoqueEndereco():New()
Local cAliasD13  := Nil
Local nProduto   := 0

Default lEmpenho := .F.
Default cNumSeq  := ""

	If Empty(nRecno)
		lRet := .F.
		Self:cErro := STR0003 // Recno não informado!
	EndIf
	If lRet
		SC9->(dbGoTo(nRecno))
		oProdLote:SetArmazem(SC9->C9_LOCAL)
		oProdLote:SetPrdOri(SC9->C9_PRODUTO)
		oProdLote:SetProduto(SC9->C9_PRODUTO)
		oProdLote:SetLoteCtl(SC9->C9_LOTECTL)
		oProdLote:SetNumLote(SC9->C9_NUMLOTE)
		oProdLote:SetNumSer(SC9->C9_NUMSERIE)
		oProdLote:LoadData()
		// AtualizaSaldo
		// Carrega estrutura do produto x componente
		aProduto := oProdLote:GetArrProd()
		If Len(aProduto) > 0
			For nProduto := 1 To Len(aProduto)
				// Carrega dados para Estoque por Endereço
				Self:oEndereco:SetArmazem(oProdLote:GetArmazem())
				Self:oEndereco:SetEnder(SC9->C9_ENDPAD)
				Self:oProdLote:SetArmazem(oProdLote:GetArmazem())
				Self:oProdLote:SetPrdOri(oProdLote:GetPrdOri())   // Produto Origem
				Self:oProdLote:SetProduto(aProduto[nProduto][1] ) // Componente
				Self:oProdLote:SetLoteCtl(oProdLote:GetLotectl()) // Lote do produto principal que deverá ser o mesmo no componentes
				Self:oProdLote:SetNumLote(oProdLote:GetNumLote()) // Sub-Lote do produto principal que deverá ser o mesmo no componentes
				Self:oProdLote:SetNumSer(oProdLote:GetNumSer())   // Numero de serie
				Self:SetIdUnit("")
				Self:LoadData()
				Self:SetQuant(QtdComp(SC9->C9_QTDLIB * aProduto[nProduto][2]) )
				// Seta o bloco de código para informações do documento para o Kardex
				Self:SetBlkDoc({|oMovEstEnd|;
					oMovEstEnd:SetOrigem("SD2"),;
					oMovEstEnd:SetDocto(cNFiscal),;
					oMovEstEnd:SetNumSeq(cNumSeq),;
					oMovEstEnd:SetIdDCF(SC9->C9_IDDCF);
				})
				// Seta o bloco de código para informações do movimento para o Kardex
				Self:SetBlkMov({|oMovEstEnd|;
					oMovEstEnd:SetlUsaCal(.F.);
				})
				// Realiza Entrada Armazem Estoque por Endereço
				lRet := Self:UpdSaldo("499",.T. /*lEstoque*/,.F. /*lEntPrev*/,.F. /*lSaiPrev*/,lEmpenho,.F. /*lBloqueio*/,.F. /*lEmpPrev*/,.T./*lMovEstEnd*/)
				// Verifica os movimentos da ordem de serviço origem para desconsiderar
				// no cálculo de estoque 
				If lRet .And. WmsX312118("D13","D13_USACAL")
					cAliasD13 := GetNextAlias()
					BeginSql Alias cAliasD13
						SELECT D13.R_E_C_N_O_ RECNOD13
						FROM %Table:D13% D13
						WHERE D13.D13_FILIAL = %xFilial:D13%
						AND D13.D13_IDDCF = %Exp:SC9->C9_IDDCF%
						AND D13.D13_DOC =  %Exp:cNFiscal%
						AND D13.D13_NUMSEQ = %Exp:cNumSeq%
						AND D13.D13_USACAL <> '2'
						AND D13.%NotDel%
					EndSql
					Do While (cAliasD13)->(!Eof())
						D13->(dbGoTo((cAliasD13)->RECNOD13))
						RecLock("D13",.F.)
						D13->D13_USACAL = '2'
						D13->(MsUnLock())
						(cAliasD13)->(dbSkip())
					EndDo
					(cAliasD13)->(dbCloseArea())
				EndIf
			Next
		Else
			Self:cErro := STR0004 // Produto não encontrado.
			lRet := .F.
		EndIf
	EndIf
	RestArea(aAreaSC9)
Return lRet
//----------------------------------------
/*/{Protheus.doc} MakeFatur
Realisa a retirada da DOCA ao realisar o faturamento
@author felipe.m
@since 23/12/2014
@version 1.0
@param nRecno, numérico, (Recno SC9)
/*/
//----------------------------------------
METHOD MakeFatur(nRecnoSC9) CLASS WMSDTCEstoqueEndereco
Local lRet       := .T.
Local aProduto   := {}
Local nProduto   := 0
Local oMovEstEnd := WMSDTCMovimentosEstoqueEndereco():New()
Local oProdLote  := WMSDTCProdutoLote():New()
Local aAreaSC9   := SC9->(GetArea())
	If Empty(nRecnoSC9)
		lRet := .F.
		Self:cErro := STR0003 // Recno não informado!
	EndIf
	If lRet
		SC9->(dbGoTo(nRecnoSC9))
		oProdLote:SetArmazem(SC9->C9_LOCAL)
		oProdLote:SetPrdOri(SC9->C9_PRODUTO)
		oProdLote:SetProduto(SC9->C9_PRODUTO)
		oProdLote:SetLoteCtl(SC9->C9_LOTECTL)
		oProdLote:SetNumLote(SC9->C9_NUMLOTE)
		oProdLote:SetNumSer(SC9->C9_NUMSERI)
		oProdLote:LoadData()
		// AtualizaSaldo
		// Carrega estrutura do produto x componente
		aProduto := oProdLote:GetArrProd()
		If Len(aProduto) > 0
			For nProduto := 1 To Len(aProduto)
				// Carrega dados para Estoque por Endereço
				Self:oEndereco:SetArmazem(oProdLote:GetArmazem())
				Self:oEndereco:SetEnder(SC9->C9_ENDPAD)
				Self:oProdLote:SetArmazem(oProdLote:GetArmazem())
				Self:oProdLote:SetPrdOri(oProdLote:GetPrdOri())   // Produto Origem
				Self:oProdLote:SetProduto(aProduto[nProduto][1] ) // Componente
				Self:oProdLote:SetLoteCtl(oProdLote:GetLotectl()) // Lote do produto principal que deverá ser o mesmo no componentes
				Self:oProdLote:SetNumLote(oProdLote:GetNumLote()) // Sub-Lote do produto principal que deverá ser o mesmo no componentes
				Self:oProdLote:SetNumSer(oProdLote:GetNumSer()) // Número de série do produto
				Self:SetIdUnit("")
				Self:LoadData()
				Self:SetQuant(QtdComp(SC9->C9_QTDLIB * aProduto[nProduto][2]) )
				// Seta o bloco de código para informações do documento para o Kardex
				Self:SetBlkDoc({|oMovEstEnd|;
					oMovEstEnd:SetOrigem("SD2"),;
					oMovEstEnd:SetDocto(SC9->C9_NFISCAL),;
					oMovEstEnd:SetNumSeq(SC9->C9_NUMSEQ),;
					oMovEstEnd:SetIdDCF(SC9->C9_IDDCF);
				})
				// Realiza Entrada Armazem Estoque por Endereço
				lRet := Self:UpdSaldo("999",.T. /*lEstoque*/,.F. /*lEntPrev*/,.F. /*lSaiPrev*/,.T. /*lEmpenho*/,.F. /*lBloqueio*/,.F. /*lEmpPrev*/,.T./*lMovEstEnd*/)
			Next
		Else
			Self:cErro := STR0004 // Produto não encontrado.
			lRet := .F.
		EndIf
	EndIf
	RestArea(aAreaSC9)
Return lRet
//----------------------------------------
/*/{Protheus.doc} GetSldEnd
Retorna array com saldos por endereço que o produto está contido
@author felipe.m
@since 23/12/2014
@version 1.0
@param cPrdOri, character, (Códido do produto origem)
@param cLocal,  character, (Código do armazém)
@param cEnder,  character, (Endereço)
@param cLoteCtl,character, (Lote)
@param cNumLote,character, (Sub-Lote)
@param cNumSerie,character,(Número de série)
@param nOrdem,   numérico, (Ordenação dos dados com base no índice (D14), se passado 0, ordena por quantidade)
@param lConsSaida
@param cProduto
@param lQryComp, logico, (Força a busca do produto filho que está vinculado ao pai)
/*/
//----------------------------------------
METHOD GetSldEnd(cPrdOri,cLocal,cEnder,cLoteCtl,cNumLote,cNumSerie,nOrdem,lConsSaida,cProduto,nQtdSpr,cIdUnitiz) CLASS WMSDTCEstoqueEndereco
Local aAreaAnt := GetArea()
Local cAliasD14  := GetNextAlias()
Local aSldEnd  := {}
Local cQuery   := ""
Local lQryComp := Self:GetUseQryC()

Default cProduto   := Self:oProdLote:GetProduto()
Default cPrdOri    := Self:oProdLote:GetPrdOri()
Default cLocal     := Self:oEndereco:GetArmazem()
Default cEnder     := Self:oEndereco:GetEnder()
Default cLoteCtl   := Self:oProdLote:GetLoteCtl()
Default cNumLote   := Self:oProdLote:GetNumLote()
Default cNumSerie  := Self:oProdLote:GetNumSer()
Default cIdUnitiz  := Self:cIdUnitiz
Default nOrdem     := 1
Default lConsSaida := .T. // Considera saldo pendente de saída
Default nQtdSpr    := 0

	Self:oEndereco:SetArmazem(cLocal)
	Self:oEndereco:SetEnder(cEnder)
	Self:oProdLote:SetProduto(cProduto)
	Self:oProdLote:SetPrdOri(cPrdOri)
	Self:oProdLote:SetLoteCtl(cLoteCtl)
	Self:oProdLote:SetNumLote(cNumLote)
	Self:oProdLote:SetNumSer(cNumSerie)
	Self:SetIdUnit(cIdUnitiz)
	Self:oProdLote:oProduto:oProdComp:SetProduto(cPrdOri)

	// Se não forçou ser consulta de produção, mas está chamado da produção
	If Self:lProducao == Nil
		Self:lProducao := FwIsInCallStack("MATA650") .And. FwIsInCallStack("F4Localiz")
	EndIf

	//Monta query conforme a característica do produto
	If !lQryComp .And. Self:oProdLote:oProduto:oProdComp:IsDad()
		Self:GetQryDad(@cQuery,lConsSaida,nOrdem,nQtdSpr)
	Else
		Self:GetQryComp(@cQuery,lConsSaida,nOrdem,nQtdSpr)
	EndIf
	BeginSql Alias cAliasD14
		SELECT %Exp:cQuery%
	EndSql
	TcSetField(cAliasD14,'D14_QTDEST','N',Self:aD14_QTDEST[1],Self:aD14_QTDEST[2])
	TcSetField(cAliasD14,'D14_DTVALD','D')
	Do While (cAliasD14)->( !Eof() )
		aAdd(aSldEnd, { ;
			(cAliasD14)->(FieldGet(1)),;                                           //[1]  Local            D14_LOCAL
			(cAliasD14)->(FieldGet(2)),;                                           //[2]  Endereço         D14_ENDER
			(cAliasD14)->(FieldGet(3)),;                                           //[3]  Lote             D14_LOTECT
			(cAliasD14)->(FieldGet(4)),;                                           //[4]  Sub-lote         D14_NUMLOT
			(cAliasD14)->(FieldGet(5)),;                                           //[5]  Número de Série  D14_NUMSER
			(cAliasD14)->(FieldGet(6)),;                                      //[6]  Quantidade       D14_QTDEST
			ConvUm((cAliasD14)->(FieldGet(9)),(cAliasD14)->(FieldGet(6)),0,2),; //[7]  Seg. Un medida   D14_QTDES2
			(cAliasD14)->(FieldGet(7)),;                                           //[8]  Data de Validade D14_DTVALD
			(cAliasD14)->(FieldGet(8)),;                                           //[9]  Produto origem   D14_PRDORI
			(cAliasD14)->(FieldGet(9)),;                                           //[10] Produto          D14_PRODUT
			(cAliasD14)->(FieldGet(10)),;                                          //[11] Id Unitizador    D14_IDUNIT
			(cAliasD14)->(FieldGet(11))})                                          //[12] Tipo Unitizador  D14_TIPUNI

		(cAliasD14)->( dbSkip() )
	EndDo
	(cAliasD14)->( dbCloseArea() )

	If Empty(aSldEnd)
		aAdd(aSldEnd, {cLocal,cEnder,cLoteCtl,cNumLote,cNumSerie,0,0,StoD(""),cPrdOri,cProduto,cIdUnitiz,""})
	EndIf

	RestArea(aAreaAnt)
Return aSldEnd
/*--------------------------------------------------------------
---SldPrdData
---Informar o saldo do produto em uma determinada data.
---felipe.m 03/08/2015
Método semelhante ao CalcEstL
CalcEstL(cCod,cLocal,dData,cLoteCtl,cNumLote,cLocaliz,cNumSeri,lConsSub)

Parâmetros de entrada:
1- Código do produto (obrigatório)
2- Código do armazém (obrigatório)
3- Data de referência (opcional – default data sistema)
4- Código do lote (opcional – default não filtra)
5- Código do sub-lote (opcional - default não filtra)
6- Código do endereço (opcional – default não filtra)
7- Numero de série (opcional - default não filtra)
8- Id Unitizador (opcional - default não filtra)
Retorno:
Array de saldo da quantidade na data de referência
--------------------------------------------------------------*/
METHOD SldPrdData(cProduto,cArmazem,dDataRef,cLoteCtl,cNumLote,cEndereco,cNumSerie,cIdUnitiz) CLASS WMSDTCEstoqueEndereco
Local aSldPeriod := {}
Local aProdComp  := {}
Local aSaldo     := {0, 0, 0, 0, 0, 0, 0}
Local oMovEstEnd := Nil
Local cAliasD15  := ""
Local cWhere     := ""
Local nI         := 0
Local nPos       := 0
Local nQtdMult   := 0
Local dDataIni   := CtoD("31/12/1899")

Default cEndereco := ""
Default cLoteCtl  := ""
Default cNumLote  := ""
Default cNumSerie := ""
Default cIdUnitiz := ""
Default dDataRef  := dDataBase

	Self:oProdLote:SetProduto(cProduto)
	Self:oEndereco:SetArmazem(cArmazem)
	Self:oEndereco:SetEnder(cEndereco)
	Self:oProdLote:SetLoteCtl(cLoteCtl)
	Self:oProdLote:SetNumLote(cNumLote)
	Self:oProdLote:SetNumSer(cNumSerie)
	Self:SetIdUnit(cIdUnitiz)
	// Busca a data do último fechamento para o produto solicitado
	// Parâmetro Where
	cWhere := "%"
	If !Empty(Self:oEndereco:GetEnder())
		cWhere += " AND D15.D15_ENDER = '"+Self:oEndereco:GetEnder()+"'"
	EndIf
	If !Empty(Self:oProdLote:GetLoteCtl())
		cWhere += " AND D15.D15_LOTECT = '"+Self:oProdLote:GetLoteCtl()+"'"
		If !Empty(Self:oProdLote:GetNumLote())
			cWhere += " AND D15.D15_NUMLOT = '"+Self:oProdLote:GetNumLote()+"'"
		EndIf
	EndIf
	If !Empty(Self:oProdLote:GetNumSer())
		cWhere += " AND D15.D15_NUMSER = '"+Self:oProdLote:GetNumSer()+"'"
	EndIf
	If !Empty(Self:cIdUnitiz)
		cWhere += " AND D15.D15_IDUNIT = '"+Self:cIdUnitiz+"'"
	EndIf
	cWhere += "%"
	cAliasD15 := GetNextAlias()
	BeginSql Alias cAliasD15
		SELECT MAX(D15.D15_DATA) D15_DATA
		FROM %Table:D15% D15
		WHERE D15.D15_FILIAL = %xFilial:D15%
		AND D15.D15_LOCAL = %Exp:Self:oEndereco:GetArmazem()%
		AND D15.D15_PRDORI = %Exp:Self:oProdLote:GetProduto()%
		AND D15.D15_DATA <= %Exp:DtoS(dDataRef)%
		AND D15.%NotDel%
		%Exp:cWhere%
	EndSql
	If (cAliasD15)->(!Eof()) .And. !Empty((cAliasD15)->D15_DATA)
		dDataIni := StoD((cAliasD15)->D15_DATA)
	EndIf
	(cAliasD15)->(dbCloseArea())
	// Retornar um array com o saldo do produto
	oMovEstEnd := WMSDTCMovimentosEstoqueEndereco():New()
	// Data do ultimo fechamento do saldo do produto
	oMovEstEnd:SetUlMes(dDataIni)
	// Data de referencia
	oMovEstEnd:SetDatFech(dDataRef)
	// Informações do produto
	oMovEstEnd:SetArmazem(Self:oEndereco:GetArmazem())
	oMovEstEnd:SetPrdOri(Self:oProdLote:GetProduto())
	oMovEstEnd:SetLoteCtl(Self:oProdLote:GetLoteCtl())
	oMovEstEnd:SetNumLote(Self:oProdLote:GetNumLote())
	oMovEstEnd:SetNumSer(Self:oProdLote:GetNumSer())
	oMovEstEnd:SetEnder(Self:oEndereco:GetEnder())
	oMovEstEnd:SetIdUnit(Self:cIdUnitiz)
	aSldPeriod := oMovEstEnd:SldPeriod() // {LOCAL,ENDER,PRDORI,PRODUT,LOTECT,NUMLOT,NUMSER,IDUNIT,SALDO}
	// Busca os componentes do produto caso haja
	Self:oProdLote:oProduto:CreateArr()
	aProdComp := Self:oProdLote:GetArrProd()
	For nI := 1 To Len(aSldPeriod)
		If aSldPeriod[nI][9] == 0
			Loop
		EndIf

		nPos := aScan(aProdComp, {|x| x[1] == aSldPeriod[nI][4]})
		If nPos > 0
			nQtdMult := aProdComp[nPos][2]
		Else
			nQtdMult := 1
		EndIf

		// Soma o saldo do produto por endereço
		aSaldo[1] += ((aSldPeriod[nI][9] / nQtdMult) / Len(aProdComp))
		aSaldo[7] += ((aSldPeriod[nI][10] / nQtdMult) / Len(aProdComp))
	Next
Return aSaldo
/*--------------------------------------------------
---UpdEstoque
---Atualização dos saldos D14 e D13 utilizado no
---acerto de saldos do inventário. (MATA340)
---felipe.m 21/10/2015
--------------------------------------------------*/
METHOD UpdEstoque(nQuant,cLocal,cEnder,cEstFis,cProduto,cLoteCtl,cNumLote,cNumSerie,aMV_Par,cLog,cIdUnitiz,cTipUni) CLASS WMSDTCEstoqueEndereco
Local lRet       := .T.
Local lPartes    := .F.
Local aAreaAnt   := GetArea()
Local aAreaSB7   := SB7->(GetArea())
Local aAreaSD3   := SD3->(GetArea())
Local aQtdsPrd   := {}
Local aEndDisp   := {}
Local oMovEstEnd := WMSDTCMovimentosEstoqueEndereco():New()
Local oProdComp  := Self:oProdLote:oProduto:oProdComp
Local cPrdOri    := ""
Local cPrdComp   := ""
Local cNumSeq    := ProxNum()
Local cAliasQry  := Nil
Local nI         := 0
Local nI2        := 0
Local nQtdDif    := 0
Local nSaldoAtu  := 0
Local nQtdEst    := 0
Local nQtdMov    := 0
Local nQtdMult   := 0
Local nSaldoWMS  := 0
Local nQtdMovPai := 0

Default cIdUnitiz := ""
Default cTipUni   := ""
	// Seta as propriedades do objeto (D14)
	Self:oEndereco:SetArmazem(cLocal)
	Self:oEndereco:SetEnder(cEnder)
	Self:oEndereco:SetEstFis(cEstFis)
	Self:oProdLote:SetArmazem(cLocal)
	Self:oProdLote:SetProduto(cProduto)
	Self:oProdLote:SetLoteCtl(cLoteCtl)
	Self:oProdLote:SetNumLote(cNumLote)
	Self:oProdLote:SetNumSer(cNumSerie)
	Self:SetIdUnit(cIdUnitiz)
	Self:SetTipUni(cTipUni)
	// Procura o produto origem
	oProdComp:SetPrdCmp(Self:oProdLote:GetProduto())
	If (lPartes := oProdComp:LoadData(2))
		nQtdMult := oProdComp:GetQtMult()
		cPrdOri := oProdComp:GetPrdOri()
	Else
		cPrdOri := Self:oProdLote:GetProduto()
	EndIf
	Self:oProdLote:SetPrdOri(cPrdOri)
	// Carrega o objeto D14
	Self:LoadData()
	//Verifica se etiqueta existe na D0Y
	If !Empty(cIdUnitiz) .And. !Empty(cTipUni)
		If !WmsVldEti(cLocal, cEnder,cIdUnitiz,@cTipUni)
			cLog := "D14"
			Return .F.
		Else
			Self:SetTipUni(cTipUni)
		EndIf
	EndIf
	// Adiciona no array de quantidades, que terá o saldo como componente e como produto, do mesmo produto
	nSaldoAtu := Self:CalcEstWms(cLocal,cProduto,aMV_Par[1],cEnder,cLoteCtl,cNumLote,cNumserie,3,Self:oProdLote:GetPrdOri(),cIdUnitiz)
	aAdd(aQtdsPrd, {nSaldoAtu,Self:oProdLote:GetPrdOri()})

	// Log inventário
	MA340GrvLg("SALDO PRODUTO="+cProduto+" PRDORI="+cPrdOri,"07","NSALDOATU="+cValToChar(nSaldoAtu))
	If lPartes
		// Procura saldo do componente como produto
		Self:oProdLote:SetPrdOri(Self:oProdLote:GetProduto())
		If Self:LoadData()
			nQtdEst := Self:CalcEstWms(cLocal,cProduto,aMV_Par[1],cEnder,cLoteCtl,cNumLote,cNumserie,3,Self:oProdLote:GetPrdOri(),cIdUnitiz)
			aAdd(aQtdsPrd, {nQtdEst,Self:oProdLote:GetPrdOri()})
			nSaldoAtu += nQtdEst
		EndIf
		Self:oProdLote:SetPrdOri(cPrdOri)
		// Log inventário
		MA340GrvLg("SALDO PRODUTO="+cProduto+" PRDORI="+cProduto,"07","NQTDEST="+cValToChar(nQtdEst))
		If QtdComp(nSaldoAtu) > QtdComp(nQuant)
			nQtdDif := (nSaldoAtu - nQuant)
			// Verifica se o saldo do produto normal já atende o inventário, caso contrário, realiza uma desmontagem
			If QtdComp(nQtdEst) >= QtdComp(0) .And. QtdComp(nQtdEst) < QtdComp(nQtdDif)
				// Desconta o saldo que já existe montado, para desmontar apenas o necessário
				nQtdDif -= nQtdEst
				nQtdMovPai := (nQtdDif / nQtdMult)
				// Sempre desmonta uma quantidade a mais do inteiro nos casos de quantidade com decimal
				If nQtdMovPai > Int(nQtdMovPai)
					nQtdMovPai := Int(nQtdMovPai) + 1
				EndIf
				// Log inventário
				MA340GrvLg("DESMONTAGEM","08")
				// Analise o saldo atual do pai, para validar se ha endereços disponíveis para realizar a desmontagem
				If nQtdMovPai > Self:GetSldOrig(.T.,.T.)
					// Log inventário
					MA340GrvLg("ERRO ENDD","08")
					cLog := "ENDD"
					Return .F.
				EndIf
				// Movimenta a quantidade do pai desmontada
				A340SD3Prt(cPrdOri,,"999",nQtdMovPai,"DESMONTAG",.T.,,aMV_Par,cNumSeq,.T./*lDesmontagem*/,)
				// Log inventário
				MA340GrvLg("SD3 999 PRODUTO="+cPrdOri,"08",cValtoChar(nQtdMovPai))
				// Atualiza a data de inventário do produto pai.
				cAliasQry := GetNextAlias()
				BeginSql Alias cAliasQry
					SELECT SB2.R_E_C_N_O_ RECNOSB2
					FROM %Table:SB2% SB2
					WHERE SB2.B2_FILIAL = %xFilial:SB2%
					AND SB2.B2_DINVENT <= %Exp:aMV_Par[1]%
					AND SB2.B2_STATUS <> '2'
				EndSql
				If (cAliasQry)->(!Eof())
					SB2->(dbGoTo((cAliasQry)->RECNOSB2))
					RecLock("SB2",.F.)
					SB2->B2_DINVENT := aMV_Par[1]
					SB2->(MsUnlock())
					// Log inventário
					MA340GrvLg("B2_DINVENT","08",DtoS(B2_DINVENT))
				EndIf
				// Seta as propriedades do movimento estoque endereço (D13)
				// Altera o documento para indicar que houve uma desmontagem no inventário
				// Seta o bloco de código para informações do documento para o Kardex
				Self:SetBlkDoc({|oMovEstEnd|;
					oMovEstEnd:SetOrigem("SB7"),;
					oMovEstEnd:SetDocto("DESMONTAG"),;
					oMovEstEnd:SetNumSeq(cNumSeq),;
					oMovEstEnd:SetDtEsto(aMV_Par[1]);
				})
				// Seta o bloco de código para informações do movimento para o Kardex
				Self:SetBlkMov({|oMovEstEnd|;
					oMovEstEnd:SetIdUnit(Self:cIdUnitiz);
				})
				// Busca quantidade dos componentes da D14
				Self:oProdLote:SetArmazem(cLocal)
				Self:oProdLote:SetProduto(cPrdOri)
				aPartes := Self:GetSldPart(cLocal,aMV_Par[1])
				For nI := 1 To Len(aPartes)
					cPrdComp  := aPartes[nI][1]
					nQtdMult  := aPartes[nI][2]
					nSaldoWMS := aPartes[nI][3]
					nQtdMov   := (nQtdMovPai * nQtdMult)
					aEndDisp  := {}
					// Busca endereços disponíveis no WMS
					Self:oProdLote:SetProduto(cPrdComp)
					Self:oProdLote:SetPrdOri(cPrdOri)
					// Inicializa endereço para buscar os endereços disponíveis
					Self:oEndereco:SetEnder("")
					// Seta a propriedade para executar a query do componente, para buscar saldo endereços do filho que está vinculado ao pai
					Self:SetUseQryC(.T.)
					aEndDisp := Self:GetSldEnd()
					If cProduto == cPrdComp
						// Verifica se o produto componente não é o mesmo da contagem para priorizar o mesmo endereço
						aSort(aEndDisp,,,{ |x| AllTrim(x[2]) == AllTrim(cEnder) } )
					EndIf
					// Avalia os endereços disponíveis
					For nI2 := 1 To Len(aEndDisp)
						// Retira do primeiro endereço encontrado
						Self:oEndereco:SetEnder(aEndDisp[nI2][2])
						Self:oProdLote:SetPrdOri(aEndDisp[nI2][9])
						Self:oProdLote:SetLoteCtl(aEndDisp[nI2][3])
						Self:oProdLote:SetNumLote(aEndDisp[nI2][4])
						Self:oProdLote:SetNumSer(aEndDisp[nI2][5])
						nQtdEst   := aEndDisp[nI2][6]
						If QtdComp(nQtdMov) > QtdComp(nQtdEst)
							Self:SetQuant(nQtdEst)
						Else
							Self:SetQuant(nQtdMov)
						EndIf
						// Subtrai a quantidade do endereço, como componente
						lRet := Self:UpdSaldo("999",.T./*lEstoque*/,.F./*lEntPrev*/,.F./*lSaiPrev*/,.F./*lEmpenho*/,.F./*lBloqueio*/,.F./*lEmpPrev*/,.T./*lMovEstEnd*/)
						// Log inventário
						MA340GrvLg("D14 999 PRODUTO="+Self:oProdLote:GetProduto()+" PRDORI="+Self:oProdLote:GetPrdOri(),"08",cValtoChar(Self:GetQuant()))
						Self:SetBlkDoc({|oMovEstEnd|;
							oMovEstEnd:SetOrigem("SB7"),;
							oMovEstEnd:SetDocto("DESMONTAG"),;
							oMovEstEnd:SetNumSeq(cNumSeq),;
							oMovEstEnd:SetDtEsto(aMV_Par[1]);
						})
						// Seta o bloco de código para informações do movimento para o Kardex
						Self:SetBlkMov({|oMovEstEnd|;
							oMovEstEnd:SetIdUnit(Self:cIdUnitiz);
						})
						// Seta o parte para produto normal
						Self:oProdLote:SetPrdOri(cPrdComp)
						// Adiciona no mesmo endereço, porém para o produto normal
						Self:UpdSaldo("499",.T./*lEstoque*/,.F./*lEntPrev*/,.F./*lSaiPrev*/,.F./*lEmpenho*/,.F./*lBloqueio*/,.F./*lEmpPrev*/,.T./*lMovEstEnd*/)
						// Log inventário
						MA340GrvLg("D14 499 PRODUTO="+Self:oProdLote:GetProduto()+" PRDORI="+Self:oProdLote:GetPrdOri(),"08",cValtoChar(Self:GetQuant()))
						A340SD3Prt(cPrdComp,Self:oEndereco:GetEnder(),"499",Self:GetQuant(),"DESMONTAG",.T.,,aMV_Par,cNumSeq,.T./*lDesmontagem*/,)
						// Log inventário
						MA340GrvLg("SD3 499 PRODUTO="+Self:oProdLote:GetProduto(),"08",cValtoChar(Self:GetQuant()))
						If QtdComp((nQtdMov -= Self:GetQuant())) == QtdComp(0)
							Exit
						EndIf
					Next nI2
				Next nI
			EndIf
		EndIf
	EndIf

	Self:oEndereco:SetArmazem(cLocal)
	Self:oEndereco:SetEnder(cEnder)

	Self:oProdLote:SetProduto(cProduto)
	Self:oProdLote:SetPrdOri(cProduto)
	// Seta o bloco de código para informações do documento para o Kardex
	Self:SetBlkDoc({|oMovEstEnd|;
		oMovEstEnd:SetOrigem("SB7"),;
		oMovEstEnd:SetDocto("INVENT"),;
		oMovEstEnd:SetNumSeq(cNumSeq),;
		oMovEstEnd:SetDtEsto(aMV_Par[1]);
	})
	// Seta o bloco de código para informações do movimento para o Kardex
	Self:SetBlkMov({|oMovEstEnd|;
		oMovEstEnd:SetIdUnit(Self:cIdUnitiz);
	})
	If QtdComp(nSaldoAtu) > QtdComp(nQuant)
		nQtdDif := (nSaldoAtu - nQuant)

		Self:SetQuant(nQtdDif)
		// Subtrai a diferença do produto informado
		lRet := Self:UpdSaldo("999",.T./*lEstoque*/,.F./*lEntPrev*/,.F./*lSaiPrev*/,.F./*lEmpenho*/,.F./*lBloqueio*/,.F./*lEmpPrev*/,.T./*lMovEstEnd*/)
		// Log inventário
		MA340GrvLg("D14 999 PRODUTO="+Self:oProdLote:GetProduto()+" PRDORI="+Self:oProdLote:GetPrdOri(),"09",cValtoChar(Self:GetQuant()))
	ElseIf QtdComp(nSaldoAtu) < QtdComp(nQuant)
		nQtdDif := (nQuant - nSaldoAtu)
		Self:SetQuant(nQtdDif)
		// Soma a diferença do produto informado
		lRet := Self:UpdSaldo("499",.T./*lEstoque*/,.F./*lEntPrev*/,.F./*lSaiPrev*/,.F./*lEmpenho*/,.F./*lBloqueio*/,.F./*lEmpPrev*/,.T./*lMovEstEnd*/)
		// Log inventário
		MA340GrvLg("D14 499 PRODUTO="+Self:oProdLote:GetProduto()+" PRDORI="+Self:oProdLote:GetPrdOri(),"09",cValtoChar(Self:GetQuant()))
	EndIf
	// Log inventário
	MA340GrvLg("BE_STATUS ","09",SBE->BE_STATUS)
	If !lRet
		cLog := "D14"
		// Log inventário
		MA340GrvLg("Log D14","09")
	EndIf
	// Quando um produto partes é movimentado no WMS, retorna .F. com cLog == ''
	// para não realizar a movimentação do SD3.
	// Pois será realizado na função A340PropPrd()
	If lRet .And. lPartes
		lRet := .F.
	EndIf
	oMovEstEnd:Destroy()
	RestArea(aAreaAnt)
	RestArea(aAreaSB7)
	RestArea(aAreaSD3)
Return lRet
/*--------------------------------------------------
---GetSldWMS
---Busca saldo no estoque por endereço WMS
---Amanda Rosa Vieira 24/10/2016
--------------------------------------------------*/
METHOD GetSldWMS(cProduto,cLocal,cEnder,cLoteCtl,cNumLote,cNumSerie,lConsSaida,cIdUnitiz) CLASS WMSDTCEstoqueEndereco
Local lPai         := .F.
Local aAreaAnt     := GetArea()
Local cQuery       := ""
Local cAliasQry    := GetNextAlias()
Local nSaldo       := 0
Local nSaldoPE     := Nil
Default lConsSaida := .T.
Default cIdUnitiz  := ""

	Self:oProdLote:oProduto:oProdComp:SetProduto(cProduto)
	lPai := Self:oProdLote:oProduto:oProdComp:IsDad()

	cQuery :=     "% (MIN(SALDOPROD.SALDO)) SALDO"
	cQuery += " FROM (SELECT D14.D14_PRDORI,"
	cQuery +=              " D14.D14_LOCAL,"
	cQuery +=              " D11.D11_PRDCMP,"
	If lPai
		cQuery +=          " CASE WHEN SUM(D14.D14_QTDEST "+ Iif(lConsSaida,"- (D14.D14_QTDSPR  + D14.D14_QTDBLQ + D14.D14_QTDEMP)", "") +") / D11.D11_QTMULT IS NULL THEN 0 ELSE SUM(D14.D14_QTDEST "+ Iif(lConsSaida,"- (D14.D14_QTDSPR  + D14.D14_QTDBLQ + D14.D14_QTDEMP)", "") +") / D11.D11_QTMULT END SALDO"
	Else
		cQuery +=          " CASE WHEN SUM(D14.D14_QTDEST "+ Iif(lConsSaida,"- (D14.D14_QTDSPR  + D14.D14_QTDBLQ + D14.D14_QTDEMP)", "") +") IS NULL THEN 0 ELSE SUM(D14.D14_QTDEST "+ Iif(lConsSaida,"- (D14.D14_QTDSPR  + D14.D14_QTDBLQ + D14.D14_QTDEMP)", "") +")  END SALDO"
	EndIf
	cQuery +=         " FROM "+RetSqlName('D14')+" D14"
	If Self:lProducao <> Nil
		cQuery +=    " INNER JOIN "+RetSqlName('DC8')+" DC8"
		cQuery +=       " ON DC8.DC8_FILIAL = '"+xFilial('DC8')+"'"
		cQuery +=      " AND DC8.DC8_CODEST = D14.D14_ESTFIS"
		If Self:lProducao
			cQuery +=  " AND DC8.DC8_TPESTR = '7'"
		Else
			cQuery +=  " AND DC8.DC8_TPESTR <> '7'"
		EndIf
		cQuery +=      " AND DC8.D_E_L_E_T_ = ' '"
	EndIf
	cQuery +=         " LEFT JOIN "+RetSqlName('D11')+" D11"
	cQuery +=           " ON D11.D11_FILIAL = D14.D14_FILIAL"
	cQuery +=          " AND D11.D11_PRDORI = D14.D14_PRDORI"
	cQuery +=          " AND D11.D_E_L_E_T_ = ' '"
	cQuery +=        " WHERE D14.D14_FILIAL = '"+xFilial('D14')+"'"
	If !Empty(cLocal)
		cQuery +=      " AND D14.D14_LOCAL  = '"+cLocal+"'"
	EndIf
	If !Empty(cEnder)
		cQuery +=      " AND D14.D14_ENDER  = '"+cEnder+"'"
	EndIf
	If !Empty(cProduto)
		cQuery +=      " AND D14.D14_PRDORI = '"+cProduto+"'"
		cQuery +=      " AND D14.D14_PRODUT = "+ Iif(lPai,"D11.D11_PRDCMP","D14.D14_PRDORI")
	EndIf
	If !Empty(cLoteCtl)
		cQuery +=      " AND D14.D14_LOTECT = '"+cLoteCtl+"'"
	EndIF
	If !Empty(cNumLote)
		cQuery +=      " AND D14.D14_NUMLOT = '"+cNumLote+"'"
	EndIf
	If !Empty(cNumSerie)
		cQuery +=      " AND D14.D14_NUMSER = '"+cNumSerie+"'"
	EndIf
	If !Empty(cIdUnitiz)
		cQuery +=      " AND D14.D14_IDUNIT = '"+cIdUnitiz+"'"
	EndIf
	cQuery +=        " GROUP BY D14.D14_PRDORI,"
	cQuery +=                 " D14.D14_LOCAL,"
	cQuery +=                 " D11.D11_PRDCMP,"
	cQuery +=                 " D11.D11_QTMULT) SALDOPROD"
	cQuery += "%"
	BeginSql Alias cAliasQry
		SELECT %Exp:cQuery%
	EndSql
	If (cAliasQry)->(!EoF())
		nSaldo := (cAliasQry)->SALDO
	EndIf
	(cAliasQry)->(dbCloseArea())
	If lPai
		nSaldo := Int(nSaldo)
	EndIf
	If _lWMSSLDWM
		nSaldoPE := ExecBlock("WMSSLDWM",.F.,.F.,{cProduto,cLocal,cEnder,cLoteCtl,cNumLote,cNumSerie,lConsSaida,cIdUnitiz,nSaldo})
		If ValType(nSaldoPE) == "N"
			nSaldo := nSaldoPE
		EndIf
	EndIf
	RestArea(aAreaAnt)
Return nSaldo

METHOD GetEndDisp(nQuant) CLASS WMSDTCEstoqueEndereco
Local lRet      := .T.
Local cAliasD14 := Nil

Default nQuant := Self:GetQuant()

	cAliasD14 := GetNextAlias()
	If !Empty(Self:cIdUnitiz)
		BeginSql Alias cAliasD14
			SELECT D14.D14_ENDER
			FROM %Table:D14% D14
			WHERE D14.D14_FILIAL = %xFilial:D14%
			AND D14.D14_LOCAL = %Exp:Self:oEndereco:GetArmazem()%
			AND D14.D14_PRODUT = %Exp:Self:oProdLote:GetProduto()%
			AND D14.D14_PRDORI = %Exp:Self:oProdLote:GetPrdOri()%
			AND D14.D14_LOTECT = %Exp:Self:oProdLote:GetLoteCtl()%
			AND D14.D14_NUMLOT = %Exp:Self:oProdLote:GetNumLote()%
			AND D14.D14_IDUNIT = %Exp:Self:cIdUnitiz%
			AND (D14.D14_QTDEST-(D14.D14_QTDEMP+D14.D14_QTDBLQ+D14.D14_QTDSPR)) >= %Exp:AllTrim(Str(nQuant))%
			AND D14.%NotDel%
		EndSql
	Else
		BeginSql Alias cAliasD14
			SELECT D14.D14_ENDER
			FROM %Table:D14% D14
			WHERE D14.D14_FILIAL = %xFilial:D14%
			AND D14.D14_LOCAL = %Exp:Self:oEndereco:GetArmazem()%
			AND D14.D14_PRODUT = %Exp:Self:oProdLote:GetProduto()%
			AND D14.D14_PRDORI = %Exp:Self:oProdLote:GetPrdOri()%
			AND D14.D14_LOTECT = %Exp:Self:oProdLote:GetLoteCtl()%
			AND D14.D14_NUMLOT = %Exp:Self:oProdLote:GetNumLote()%
			AND (D14.D14_QTDEST-(D14.D14_QTDEMP+D14.D14_QTDBLQ+D14.D14_QTDSPR)) >= %Exp:AllTrim(Str(nQuant))%
			AND D14.%NotDel%
		EndSql
	EndIf
	If (cAliasD14)->(!Eof())
		Self:oEndereco:SetEnder((cAliasD14)->D14_ENDER)
	Else
		lRet := .F.
	EndIf
Return lRet

METHOD ReversePed(nRecnoSC9,nQtdQuebra) CLASS WMSDTCEstoqueEndereco
Local lRet     := .T.
Local aAreaSC9 := SC9->(GetArea())
Local oProdLote:= WMSDTCProdutoLote():New()
Local aProduto := {}
Local nProduto := 0
	// Verifica se há SDC criada e estorna
	SC9->(dbGoTo(nRecnoSC9))
	oProdLote:SetArmazem(SC9->C9_LOCAL)
	oProdLote:SetPrdOri(SC9->C9_PRODUTO)
	oProdLote:SetProduto(SC9->C9_PRODUTO)
	oProdLote:SetLoteCtl(SC9->C9_LOTECTL)
	oProdLote:SetNumLote(SC9->C9_NUMLOTE)
	oProdLote:SetNumSer(SC9->C9_NUMSERIE)
	oProdLote:LoadData()
	// AtualizaSaldo
	// Carrega estrutura do produto x componente
	aProduto := oProdLote:GetArrProd()
	If Len(aProduto) > 0
		For nProduto := 1 To Len(aProduto)
			// Carrega dados para Estoque por Endereço
			Self:oEndereco:SetArmazem(oProdLote:GetArmazem())
			Self:oEndereco:SetEnder(SC9->C9_ENDPAD)
			Self:oProdLote:SetArmazem(oProdLote:GetArmazem())
			Self:oProdLote:SetPrdOri(oProdLote:GetPrdOri())   // Produto Origem
			Self:oProdLote:SetProduto(aProduto[nProduto][1] ) // Componente
			Self:oProdLote:SetLoteCtl(oProdLote:GetLotectl()) // Lote do produto principal que deverá ser o mesmo no componentes
			Self:oProdLote:SetNumLote(oProdLote:GetNumLote()) // Sub-Lote do produto principal que deverá ser o mesmo no componentes
			Self:oProdLote:SetNumSer(oProdLote:GetNumSer())   // Numero de serie
			Self:LoadData()
			If nQtdQuebra == Nil
				nQtdQuebra := SC9->C9_QTDLIB
			EndIf
			Self:SetQuant(QtdComp(nQtdQuebra * aProduto[nProduto][2]) )
			// Realiza Entrada Armazem Estoque por Endereço
			Self:UpdSaldo("999",.F. /*lEstoque*/,.F. /*lEntPrev*/,.F. /*lSaiPrev*/,.T./*lEmpenho*/,.F. /*lBloqueio*/)
		Next
	Else
		Self:cErro := STR0004 // Produto não encontrado.
		lRet := .F.
	EndIf
	RestArea(aAreaSC9)
	// Estorna SDC
	WmsAtuSDC("SC6",,,SC9->C9_PEDIDO,SC9->C9_ITEM,SC9->C9_SEQUEN,SC9->C9_PRODUTO,SC9->C9_LOTECTL,SC9->C9_NUMLOTE,SC9->C9_NUMSERI,nQtdQuebra,,SC9->C9_LOCAL,SC9->C9_ENDPAD,SC9->C9_IDDCF,,.T.)
	RestArea(aAreaSC9)
Return lRet

METHOD MontPrdPai(lInventario,aPais,aParam,aMV_Par,aPrdMont) CLASS WMSDTCEstoqueEndereco
Local oMovEstEnd := WMSDTCMovimentosEstoqueEndereco():New()

Local aPartes    := {}
Local aEndDisp   := {}
Local aAreaSD3   := {}

Local cLocal     := ""
Local cPrdPai    := ""
Local cLoteCtl   := ""
Local cNumLote   := ""
Local cNumSerie  := ""
Local cPrdComp   := ""
Local cEndereco  := ""
Local cNumOP     := ""
Local cNumSeq    := ProxNum()
Local nRecno     := 0
Local cDocSD3    := Iif(lInventario,"MONTAGEM","MNTRECEBI")

Local nSaldoWMS  := 0
Local nQtdMult   := 0
Local nSldConv   := 0
Local nQtdEst    := 0
Local nI         := 0
Local nI2        := 0
Local nI3        := 0
Local dDataInv   := aMV_Par[01]

Private nHdlPrv
Private cLoteEst

Default aParam   := {}
Default aPrdMont := {}

	// aParam - Informações da movimentação SD3
	// [01] cLocal
	// [02] dData
	// [03] cNumLote
	// [04] cLoteCtl
	// [05] dDtValid
	// [06] nQtSegUm
	// [07] cNumSerie
	// [08] cEstFis
	// [09] cContagem
	// [10] cNumDoc
	// [11] cSerie
	// [12] cFornece
	// [13] cLoja
	// [14] mv_par01 -> D3_EMISSAO
	// [15] mv_par02 -> D3_CC
	// [16] mv_par14 -> 1=Pega os custos medios finais;2=Pega os custos medios atuais
	For nI := 1 To Len(aPais)
		cLocal   := aPais[nI][1]
		cPrdPai  := aPais[nI][2]
		cLoteCtl := aPais[nI][3]
		cNumLote := aPais[nI][4]
		cNumSerie:= aPais[nI][5]
		// Inicializa os atributos do objeto
		Self:ClearData()
		// Verifica se será montado o produto pai com base nas partes sobressalentes
		Self:oProdLote:oProduto:oProdComp:SetPrdOri(cPrdPai)
		Self:oProdLote:oProduto:oProdComp:LoadData(3)
		If Self:oProdLote:oProduto:oProdComp:IsMntPrd()
			// Seta as propriedades do objeto (D14)
			Self:oEndereco:SetArmazem(cLocal)
			If Rastro(cPrdPai)
				Self:oProdLote:SetLoteCtl(cLoteCtl)
				Self:oProdLote:SetNumLote(cNumLote)
				Self:oProdLote:SetNumSer(cNumSerie)
			EndIf
			// Busca o saldo do produto pai com base no saldo dos componentes na D14
			Self:oProdLote:SetArmazem(cLocal)
			Self:oProdLote:SetProduto(cPrdPai)
			Self:oProdLote:SetPrdOri(cPrdPai)
			Self:oEndereco:SetEnder("")
			nSaldoWMS := Int(Self:GetSldOrig(.F.,.T.))
			If lInventario
				// Log inventário
				MA340GrvLg("MONTPRDPAI","12","QUANTIDADE="+cValtoChar(nSaldoWMS))
			EndIf
			// Retorna o saldo que poderá ser montado
			If nSaldoWMS > 0
				cNumOP := Self:WmsGeraOP(cLocal, cPrdPai, nSaldoWMS)
				If Empty(cNumOP)
					If lInventario
						// Log inventário
						MA340GrvLg("NÃO FOI GERADO OP SC2","12","")
					EndIf
					Return .F.
				EndIf
				If lInventario
					// Log inventário
					MA340GrvLg("GERADO OP SC2","12",cNumOP)
				EndIf
				// Busca quantidade dos componente da D14 como produto
				Self:oProdLote:SetArmazem(cLocal)
				Self:oProdLote:SetProduto(cPrdPai)
				aPartes := Self:GetSldPart(cLocal,dDataInv,.F.)
				// Seta as propriedades do objeto (D14)
				Self:oEndereco:SetArmazem(cLocal)
				For nI2 := 1 To Len(aPartes)
					cPrdComp := aPartes[nI2,1]
					nQtdMult := aPartes[nI2,2]
					nSldConv := (nSaldoWMS * nQtdMult) // Saldo da parte que será convertido
					// Altera o objeto para considerar o produto parte
					Self:oProdLote:SetProduto(cPrdComp)
					Self:oProdLote:SetPrdOri(cPrdComp)
					Self:oEndereco:SetEnder("")
					// Busca endereços disponíveis no WMS
					Self:SetUseQryC(.F.)
					aEndDisp := Self:GetSldEnd()
					For nI3 := 1 To Len(aEndDisp)
						cEndereco := aEndDisp[nI3][2]
						nQtdEst   := aEndDisp[nI3][6]

						If nSldConv > nQtdEst
							Self:SetQuant(nQtdEst)
						Else
							Self:SetQuant(nSldConv)
						EndIf
						// Retira do primeiro endereço encontrado
						Self:oEndereco:SetEnder(cEndereco)
						Self:oProdLote:SetPrdOri(cPrdComp)
						Self:oProdLote:LoadData()
						// Seta as propriedades do movimento estoque endereço (D13)
						// Altera o documento para indicar que houve uma desmontagem no inventário
						// Seta o bloco de código para informações do documento para o Kardex
						Self:SetBlkDoc({|oMovEstEnd|;
							oMovEstEnd:SetOrigem(Iif(lInventario,"SB7","SD1")),;
							oMovEstEnd:SetDocto(cDocSD3),;
							oMovEstEnd:SetNumSeq(cNumSeq),;
							oMovEstEnd:SetDtEsto(dDataInv);
						})
						// Seta o bloco de código para informações do movimento para o Kardex
						Self:SetBlkMov({|oMovEstEnd|;
							oMovEstEnd:SetIdUnit(Self:cIdUnitiz);
						})
						// Subtrai do estoque a quantidade convertida do produto componente
 						If !Self:WmsReqPart(cDocSD3,dDataInv,cNumSeq,cPrdComp,cLocal,cEndereco,cLoteCtl,cNumLote,Self:GetQuant(),cNumOp)
							Return .F.
						EndIf
						If lInventario
							// Log inventário
							MA340GrvLg("SD3 999 FILHO="+cPrdComp,"12",cValtoChar(Self:GetQuant()))
						EndIf
						// Subtrai a quantidade do endereço, como componente
						Self:UpdSaldo("999",.T./*lEstoque*/,.F./*lEntPrev*/,.F./*lSaiPrev*/,.F./*lEmpenho*/,.F./*lBloqueio*/,.F./*lEmpPrev*/,.T. /*lMovEstEnd*/)
						If lInventario
							// Log inventário
							MA340GrvLg("D14 999 FILHO="+cPrdComp+" PRDORI="+cPrdComp,"12","ENDERECO="+cEndereco+" QTD="+cValtoChar(Self:GetQuant()))
						EndIf
						// Seta as propriedades do movimento estoque endereço (D13)
						// Altera o documento para indicar que houve uma desmontagem no inventário
						// Seta o bloco de código para informações do documento para o Kardex
						Self:SetBlkDoc({|oMovEstEnd|;
							oMovEstEnd:SetOrigem(Iif(lInventario,"SB7","SD1")),;
							oMovEstEnd:SetDocto(cDocSD3),;
							oMovEstEnd:SetNumSeq(cNumSeq),;
							oMovEstEnd:SetDtEsto(dDataInv);
						})
						// Seta o bloco de código para informações do movimento para o Kardex
						Self:SetBlkMov({|oMovEstEnd|;
							oMovEstEnd:SetIdUnit(Self:cIdUnitiz);
						})
						// Seta o parte para produto normal
						Self:oProdLote:SetPrdOri(cPrdPai)
						Self:oProdLote:LoadData()
						// Adiciona no mesmo endereço, porém para o produto normal
						Self:UpdSaldo("499",.T./*lEstoque*/,.F./*lEntPrev*/,.F./*lSaiPrev*/,.F./*lEmpenho*/,.F./*lBloqueio*/,.F./*lEmpPrev*/,.T. /*lMovEstEnd*/)
						If lInventario
							// Log inventário
							MA340GrvLg("D14 499 FILHO="+cPrdComp+" PRDORI="+cPrdPai,"12",cValtoChar(Self:GetQuant()))
						EndIf
						If QtdComp((nSldConv -= Self:GetQuant())) == QtdComp(0)
							Exit
						EndIf
					Next nI3
				Next nI2
				If !lInventario
					aAdd(aPrdMont,{nSaldoWMS,Posicione("SB1",1,xFilial("SB1")+cPrdPai,"B1_UM"),cPrdPai})
				EndIf
				If lInventario
					// Log inventário
					MA340GrvLg("SD3 499 PAI="+cPrdPai,"12",cValtoChar(nSaldoWMS))
				EndIf
				aAreaSD3 := SD3->(GetArea())
				// Realiza o apontamento para criar o saldo do produto pai
				If !Self:WmsApontOp(cNumOP,cPrdPai,nSaldoWMS,cDocSD3,@nRecno,cLocal,cLoteCtl,cNumLote)
					Return .F.
				EndIf
				RestArea(aAreaSD3)
			EndIf
		EndIf
		If lInventario
			IncProc()
		EndIf
	Next nI
Return .T.
//-----------------------------------
/*/{Protheus.doc} UpdEnder
Atualiza o endereço
@author felipe.m
@since 23/01/2015
@version 1.0
/*/
//-----------------------------------
METHOD UpdEnder(lConsBlq) CLASS WMSDTCEstoqueEndereco
Local lRet       := .T.
Local aAreaAnt   := GetArea()
Local cAliasQry  := Nil
Local cStatus    := ""
Local cChkStatus := ""

Default lConsBlq := .F.

	cChkStatus := IIf(lConsBlq,"1|2|3|4|5|6","1|2|6")

	If Self:oEndereco:LoadData()
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT SBE.BE_STATUS,
					SBE.R_E_C_N_O_ RECNOSBE,
					SUM(D14.D14_QTDEST + D14.D14_QTDEPR + D14.D14_QTDSPR + D14.D14_QTDEMP + D14.D14_QTDBLQ + D14.D14_QTDPEM) D14_SALDO
			FROM %Table:SBE% SBE
			LEFT JOIN %Table:D14% D14
			ON D14.D14_FILIAL = %xFilial:D14%
			AND SBE.BE_FILIAL = %xFilial:SBE%
			AND D14.D14_LOCAL = SBE.BE_LOCAL
			AND D14.D14_ESTFIS = SBE.BE_ESTFIS
			AND D14.D14_ENDER = SBE.BE_LOCALIZ
			AND D14.%NotDel%
			WHERE SBE.BE_FILIAL = %xFilial:SBE%
			AND SBE.BE_LOCAL = %Exp:Self:oEndereco:GetArmazem()%
			AND SBE.BE_LOCALIZ = %Exp:Self:oEndereco:GetEnder()%
			AND SBE.BE_ESTFIS = %Exp:Self:oEndereco:GetEstFis()%
			AND (( SBE.BE_STATUS = '6'
				AND NOT EXISTS (SELECT 1
								FROM %Table:SB7% SB7
								WHERE SB7.B7_FILIAL = %xFilial:SB7%
								AND SB7.B7_LOCAL = SBE.BE_LOCAL
								AND SB7.B7_LOCALIZ = SBE.BE_LOCALIZ
								AND SB7.B7_STATUS = '1'
								AND SB7.%NotDel% ))
				OR (SBE.BE_STATUS <> '6'))
			AND SBE.%NotDel%
			GROUP BY SBE.BE_STATUS,
						SBE.R_E_C_N_O_
		EndSql
		If (cAliasQry)->(!Eof())
			If Empty((cAliasQry)->D14_SALDO) .Or. (cAliasQry)->D14_SALDO <= 0
				If (cAliasQry)->BE_STATUS $ cChkStatus
					cStatus := "1"
				EndIf
			Else
				If (cAliasQry)->BE_STATUS $ cChkStatus
					cStatus := "2"
				EndIf
			EndIf
			If !Empty(cStatus)
				SBE->(dbGoto( (cAliasQry)->RECNOSBE ))
				RecLock('SBE',.F.)
				SBE->BE_STATUS := cStatus
				SBE->BE_DTINV  := CTOD('')
				SBE->(MsUnlock())
			EndIf
		EndIf
		(cAliasQry)->(dbCloseArea())
	EndIf
	RestArea(aAreaAnt)
Return lRet
/*
nAcao 1- Busca o saldo do produto pai com base nos filhos
		2- Busca o saldo do produto normal ou parte dele mesmo
		3- Busca o saldo do produto parte como componente do pai
*/
METHOD CalcEstWms(cArmazem,cProduto,dData,cEndereco,cLoteCtl,cNumLote,cNumserie,nAcao,cPrdOri,cIdUnitiz) CLASS WMSDTCEstoqueEndereco
Local aSldPeriod  := {}
Local cQuery      := ""
Local cAliasQry   := ""
Local nPos        := 0
Local dUltFech    := ""
Local nSldPeriod  := 0
Local nI          := 0

Default cArmazem  := Self:oProdLote:GetArmazem()
Default cProduto  := Self:oProdLote:GetPrdOri()
Default dData     := dDatabase
Default cEndereco := ""
Default cLoteCtl  := Self:oProdLote:GetLoteCtl()
Default cNumLote  := Self:oProdLote:GetNumLote()
Default cNumserie := ""
Default cIdUnitiz := Self:cIdUnitiz
Default nAcao     := 1
Default cPrdOri   := cProduto
	dUltFech := StaticCall(WMSC015C,GetUltFech,cArmazem,cProduto)

	// Saldo do fechamento anterior
	cQuery :=           "% '000' NIVEL,"
	cQuery +=             " D15.D15_LOCAL LOCAL,"
	cQuery +=             " D15.D15_PRDORI PRDORI,"
	cQuery +=             " D15.D15_PRODUT PRODUT,"
	cQuery +=             " SUM(D15.D15_QINI) SALDO"
	cQuery +=        " FROM "+RetSqlName("D15")+" D15"
	cQuery +=       " WHERE D15.D15_FILIAL = '"+xFilial("D15")+"'"
	cQuery +=         " AND D15.D15_DATA = '"+DTOS(dUltFech)+"'"
	cQuery +=         " AND D15.D15_LOCAL = '"+cArmazem+"'"
	Do Case
		Case nAcao == 1
			cQuery += " AND D15.D15_PRDORI = '"+cProduto+"'"
		Case nAcao == 2
			cQuery += " AND D15.D15_PRODUT = '"+cProduto+"'"
		Case nAcao == 3
			cQuery += " AND D15.D15_PRODUT = '"+cProduto+"'"
			cQuery += " AND D15.D15_PRDORI = '"+cPrdOri+"'"
	EndCase
	If !Empty(cEndereco)
		cQuery +=     " AND D15.D15_ENDER = '"+cEndereco+"'"
	EndIf
	If !Empty(cLoteCtl)
		cQuery +=     " AND D15.D15_LOTECT = '"+cLoteCtl+"'"
	EndIf
	If !Empty(cNumLote)
		cQuery +=     " AND D15.D15_NUMLOT = '"+cNumLote+"'"
	EndIf
	If !Empty(cNumserie)
		cQuery +=     " AND D15.D15_NUMSER = '"+cNumserie+"'"
	EndIf
	If !Empty(cIdUnitiz)
		cQuery +=     " AND D15.D15_IDUNIT = '"+cIdUnitiz+"'"
	EndIf
	cQuery +=         " AND D15.D_E_L_E_T_ = ' '"
	cQuery +=       " GROUP BY D15.D15_LOCAL,"
	cQuery +=                " D15.D15_PRDORI,"
	cQuery +=                " D15.D15_PRODUT"
	cQuery +=       " UNION ALL"
	// Saldo das entradas
	cQuery +=      " SELECT '499' NIVEL,"
	cQuery +=             " D13A.D13_LOCAL LOCAL,"
	cQuery +=             " D13A.D13_PRDORI PRDORI,"
	cQuery +=             " D13A.D13_PRODUT PRODUT,"
	cQuery +=             " SUM(D13A.D13_QTDEST) SALDO"
	cQuery +=        " FROM "+RetSqlName("D13")+" D13A"
	cQuery +=       " WHERE D13A.D13_FILIAL = '"+xFilial("D13")+"'"
	cQuery +=         " AND D13A.D13_TM = '499'"
	cQuery +=         " AND D13A.D13_DTESTO > '"+DTOS(dUltFech)+"'"
	cQuery +=         " AND D13A.D13_DTESTO <= '"+DTOS(dData)+"'"
	cQuery +=         " AND D13A.D13_LOCAL = '"+cArmazem+"'"
	Do Case
		Case nAcao == 1
			cQuery += " AND D13A.D13_PRDORI = '"+cProduto+"'"
		Case nAcao == 2
			cQuery += " AND D13A.D13_PRODUT = '"+cProduto+"'"
		Case nAcao == 3
			cQuery += " AND D13A.D13_PRODUT = '"+cProduto+"'"
			cQuery += " AND D13A.D13_PRDORI = '"+cPrdOri+"'"
	EndCase
	If !Empty(cEndereco)
		cQuery +=     " AND D13A.D13_ENDER = '"+cEndereco+"'"
	EndIf
	If !Empty(cLoteCtl)
		cQuery +=     " AND D13A.D13_LOTECT = '"+cLoteCtl+"'"
	EndIf
	If !Empty(cNumLote)
		cQuery +=     " AND D13A.D13_NUMLOT = '"+cNumLote+"'"
	EndIf
	If !Empty(cNumserie)
		cQuery +=     " AND D13A.D13_NUMSER = '"+cNumserie+"'"
	EndIf
	If !Empty(cIdUnitiz)
		cQuery +=     " AND D13A.D13_IDUNIT = '"+cIdUnitiz+"'"
	EndIf
	If WmsX312118("D13","D13_USACAL")
		cQuery +=     " AND D13A.D13_USACAL <> '2'"
	EndIf
	cQuery +=         " AND D13A.D_E_L_E_T_ = ' '"
	cQuery +=       " GROUP BY D13A.D13_LOCAL,"
	cQuery +=                " D13A.D13_PRDORI,"
	cQuery +=                " D13A.D13_PRODUT"
	cQuery +=       " UNION ALL"
	// Saldo das saídas
	cQuery +=      " SELECT '999' AS NIVEL,"
	cQuery +=             " D13B.D13_LOCAL LOCAL,"
	cQuery +=             " D13B.D13_PRDORI PRDORI,"
	cQuery +=             " D13B.D13_PRODUT PRODUT,"
	cQuery +=             " SUM(D13B.D13_QTDEST) SALDO"
	cQuery +=        " FROM "+RetSqlName("D13")+" D13B"
	cQuery +=       " WHERE D13B.D13_FILIAL = '"+xFilial("D13")+"'"
	cQuery +=         " AND D13B.D13_TM = '999'"
	cQuery +=         " AND D13B.D13_DTESTO > '"+DTOS(dUltFech)+"'"
	cQuery +=         " AND D13B.D13_DTESTO <= '"+DTOS(dData)+"'"
	cQuery +=         " AND D13B.D13_LOCAL = '"+cArmazem+"'"
	Do Case
		Case nAcao == 1
			cQuery += " AND D13B.D13_PRDORI = '"+cProduto+"'"
		Case nAcao == 2
			cQuery += " AND D13B.D13_PRODUT = '"+cProduto+"'"
		Case nAcao == 3
			cQuery += " AND D13B.D13_PRODUT = '"+cProduto+"'"
			cQuery += " AND D13B.D13_PRDORI = '"+cPrdOri+"'"
	EndCase
	If !Empty(cEndereco)
		cQuery +=     " AND D13B.D13_ENDER = '"+cEndereco+"'"
	EndIf
	If !Empty(cLoteCtl)
		cQuery +=     " AND D13B.D13_LOTECT = '"+cLoteCtl+"'"
	EndIf
	If !Empty(cNumLote)
		cQuery +=     " AND D13B.D13_NUMLOT = '"+cNumLote+"'"
	EndIf
	If !Empty(cNumserie)
		cQuery +=     " AND D13B.D13_NUMSER = '"+cNumserie+"'"
	EndIf
	If !Empty(cIdUnitiz)
		cQuery +=     " AND D13B.D13_IDUNIT = '"+cIdUnitiz+"'"
	EndIf
	If WmsX312118("D13","D13_USACAL")
		cQuery +=     " AND D13B.D13_USACAL <> '2'"
	EndIf
	cQuery +=         " AND D13B.D_E_L_E_T_ = ' '"
	cQuery +=       " GROUP BY D13B.D13_LOCAL,"
	cQuery +=                " D13B.D13_PRDORI,"
	cQuery +=                " D13B.D13_PRODUT"
	cQuery +=       " ORDER BY LOCAL,"
	cQuery +=                " PRDORI,"
	cQuery +=                " PRODUT,"
	cQuery +=                " NIVEL"
	cQuery += "%"
	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT %Exp:cQuery%
	EndSql
	Do While (cAliasQry)->(!Eof())
		nPos := aScan(aSldPeriod,{ |x| x[1]+x[2] == (cAliasQry)->(Iif(nAcao==2,"",PRDORI)+PRODUT) })
		If nPos == 0
			(cAliasQry)->( aAdd(aSldPeriod,{Iif(nAcao==2,"",PRDORI),PRODUT,0}) )
			nPos := Len(aSldPeriod)
		EndIf
		If (cAliasQry)->NIVEL == "000" // Considera o saldo do fechamento anterior
			aSldPeriod[nPos][3] += (cAliasQry)->SALDO
		ElseIf (cAliasQry)->NIVEL == "499" // Adiciona o saldo das movimentações de entrada
			aSldPeriod[nPos][3] += (cAliasQry)->SALDO
		ElseIf (cAliasQry)->NIVEL == "999" // Subtrai o saldo das movimentações de saída
			aSldPeriod[nPos][3] -= (cAliasQry)->SALDO
		EndIf
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
	If Len(aSldPeriod) > 1
		// Tratamento da quantidade multipla para produtos partes
		For nI := 1 To Len(aSldPeriod)
			cAliasQry := GetNextAlias()
			BeginSql Alias cAliasQry
				SELECT D11.D11_QTMULT
				FROM %Table:D11% D11
				WHERE D11.D11_FILIAL = %xFilial:D11%
				AND D11.D11_PRDCMP = %Exp:aSldPeriod[nI][2]%
				AND D11.%NotDel%
			EndSql
			If (cAliasQry)->(!Eof())
				aSldPeriod[nI][3] := aSldPeriod[nI][3] / (cAliasQry)->D11_QTMULT
			EndIf
			(cAliasQry)->(dbCloseArea())
		Next nI
		aSort(aSldPeriod,,,{|x,y| x[3] < y[3]})
		nSldPeriod := aSldPeriod[1][3]
	ElseIf Len(aSldPeriod) == 1
		nSldPeriod := aSldPeriod[1][3]
	EndIf
Return nSldPeriod

METHOD AnaEstoque(cLog,cCod,cLocal,cLoteCtl,cLote) CLASS WMSDTCEstoqueEndereco
	// Mantido para não apresentar falta de função em programas de versões antigas
Return Nil
//----------------------------------------
/*/{Protheus.doc} EquateOver
Análise/Ajustes estoque
@author Squad WMS Protheus
@since 31/01/2019
@version 1.0
@param cArmazem, Caracter, Armazém filtro da análise
@param cProduto, Caracter, Produto filtro da análise
@param oProcess, Objeto para controlar progresso
@param nAcao, numérico, acao filtro da análise 1 = Análise/Ajuste kardex por endereço (D14->D13)
                                               2 = Análise/Ajuste estoque por endereço (SB2->D14)
                                               3 = Análise/Ajuste saldo produto (D14->SB2)
/*/
//----------------------------------------
METHOD EquateOver(cArmazem,cProduto,oProcess,nAcao) CLASS WMSDTCEstoqueEndereco
Local aAreaAnt  := GetArea()

Default nAcao = 1
	// Ajusta kardex por endereço WMS
	Self:EquateKard(cArmazem  /*cArmazem*/,;
					cProduto  /*cProduto*/,;
					oProcess)
	If nAcao > 1
		// Ajusta estoque do produto com o estoque por endereço
		Self:EquateEst(cArmazem  /*cArmazem*/,;
						cProduto  /*cProduto*/,;
						oProcess)
		RestArea(aAreaAnt)
	EndIf
Return Nil
//----------------------------------------
/*/{Protheus.doc} GetQryDad
Monta query para buscar a quantidade de produtos 'pai' nos endereços.
@author felipe.m, amanda.vieira
@since 20/10/2016
@version 1.0
@param cQuery, caractere, (Query)
@param lConsSaida, lógico, (Indica se considera saída)
@param nOrdem, numérico, (Ordenação dos dados com base no índice (D14), se passado 0, ordena por quantidade)
/*/
//----------------------------------------
METHOD GetQryDad(cQuery,lConsSaida,nOrdem,nQtdSpr) CLASS WMSDTCEstoqueEndereco
	cQuery :=       "% SALDO.D14_LOCAL,"
	cQuery +=        " SALDO.D14_ENDER,"
	cQuery +=        " SALDO.D14_LOTECT,"
	cQuery +=        " SALDO.D14_NUMLOT,"
	cQuery +=        " SALDO.D14_NUMSER,"
	cQuery +=        " SALDO.QTDEST,"
	cQuery +=        " SALDO.D14_DTVALD,"
	cQuery +=        " SALDO.D14_PRDORI,"
	//Seleciona duas vezes o produto origem para que ao montar o array informe o produto origem(D14_PRDORI) no lugar do produto(D14_PRODUT)
	cQuery +=        " SALDO.D14_PRDORI AS D14_PRODUT,"
	cQuery +=        " SALDO.D14_ESTFIS,"
	cQuery +=        " SALDO.D14_IDUNIT,"
	cQuery +=        " SALDO.D14_CODUNI"
	cQuery +=   " FROM ( SELECT DISTINCT"
	cQuery +=                 " D14A.D14_LOCAL,"
	cQuery +=                 " D14A.D14_ENDER,"
	cQuery +=                 " D14A.D14_LOTECT,"
	cQuery +=                 " D14A.D14_NUMLOT,"
	cQuery +=                 " D14A.D14_NUMSER,"
	cQuery +=                 " D14A.D14_IDUNIT,"
	cQuery +=                 " D14A.D14_CODUNI,"
	cQuery +=                 " D14A.D14_PRDORI,"
	cQuery +=                 " D14A.D14_DTVALD,"
	//Verifica a quantidade do produto pai que existe na endereço, com base na quantidade dos produtos filhos
	If lConsSaida
		cQuery +=                 " (SELECT MIN((D14.D14_QTDEST-(D14.D14_QTDEMP+D14.D14_QTDBLQ+(D14.D14_QTDSPR-("+cValToChar(nQtdSpr)+" * CASE WHEN D11.D11_QTMULT IS NULL THEN 1 ELSE D11.D11_QTMULT END)))) / CASE WHEN D11.D11_QTMULT IS NULL THEN 1 ELSE D11.D11_QTMULT END) QTDPAI"
	Else
		cQuery +=                 " (SELECT MIN((D14.D14_QTDEST) / CASE WHEN D11.D11_QTMULT IS NULL THEN 1 ELSE D11.D11_QTMULT END) QTDPAI"
	EndIf
	cQuery +=                    " FROM "+RetSqlName('D14')+" D14"
	cQuery +=                   " INNER JOIN "+RetSqlName('D11')+" D11"
	cQuery +=                      " ON D11.D11_FILIAL = '"+xFilial('D11')+"'"
	cQuery +=                     " AND D11.D11_PRDCMP = D14.D14_PRODUT"
	cQuery +=                     " AND D11.D11_PRDORI = D14.D14_PRDORI"
	cQuery +=                     " AND D11.D11_PRODUT = D14.D14_PRDORI"
	cQuery +=                     " AND D11.D_E_L_E_T_ = ' '"
	cQuery +=                   " WHERE D14.D14_FILIAL = D14A.D14_FILIAL"
	cQuery +=                     " AND D14.D14_LOCAL  = D14A.D14_LOCAL"
	cQuery +=                     " AND D14.D14_ENDER  = D14A.D14_ENDER"
	cQuery +=                     " AND D14.D14_LOTECT = D14A.D14_LOTECT"
	cQuery +=                     " AND D14.D14_NUMLOT = D14A.D14_NUMLOT"
	cQuery +=                     " AND D14.D14_NUMSER = D14A.D14_NUMSER"
	cQuery +=                     " AND D14.D14_IDUNIT = D14A.D14_IDUNIT"
	cQuery +=                     " AND D14.D14_PRDORI = D14A.D14_PRDORI"
	cQuery +=                     " AND D14.D14_LOCAL  = D14A.D14_LOCAL"
	cQuery +=                     " AND D14.D14_ENDER  = D14A.D14_ENDER"
	cQuery +=                     " AND D14.D14_PRDORI = D14A.D14_PRDORI"
	cQuery +=                     " AND D14.D_E_L_E_T_ = ' '"
	cQuery +=                   " GROUP BY D14.D14_ENDER) QTDEST,"
	cQuery +=                    " D14A.D14_PRDORI AS D14_PRODUT,"
	cQuery +=                    " D14A.D14_ESTFIS"
	cQuery +=            " FROM "+RetSqlName('D14')+" D14A"
	// Filtra apenas os endereços que contém todos os produtos da estrutura"
	cQuery +=           " INNER JOIN (SELECT D14.D14_ENDER,"
	cQuery +=                              " D14.D14_LOTECT,"
	cQuery +=                              " D14.D14_NUMLOT,"
	cQuery +=                              " D14.D14_NUMSER,"
	cQuery +=                              " D14.D14_IDUNIT,"
	cQuery +=                              " D14.D14_CODUNI,"
	cQuery +=                              " D14.D14_DTVALD"
	cQuery +=                         " FROM (SELECT COUNT(*) QTD"
	cQuery +=                                 " FROM "+RetSqlName('D11')+" D11"
	cQuery +=                                " WHERE D11.D11_FILIAL = '"+xFilial('D11')+"'"
	cQuery +=                                  " AND D11.D11_PRDORI = '"+Self:oProdLote:GetPrdOri()+"'"
	cQuery +=                                  " AND D11.D_E_L_E_T_ = ' ') D11"
	cQuery +=                        " INNER JOIN (SELECT D14_ENDER,"
	cQuery +=                                           " D14_LOTECT,"
	cQuery +=                                           " D14_NUMLOT,"
	cQuery +=                                           " D14_NUMSER,"
	cQuery +=                                           " D14_IDUNIT,"
	cQuery +=                                           " D14_CODUNI,"
	cQuery +=                                           " D14_DTVALD,"
	cQuery +=                                           " COUNT(*) QTD"
	cQuery +=                                      " FROM "+RetSqlName('D14')+" D14"
	If Self:lProducao <> Nil
		cQuery +=                                  " INNER JOIN "+RetSqlName('DC8')+" DC8"
		cQuery +=                                     " ON DC8.DC8_FILIAL = '"+xFilial('DC8')+"'"
		cQuery +=                                    " AND DC8.DC8_CODEST = D14.D14_ESTFIS"
		If Self:lProducao
			cQuery +=                                    " AND DC8.DC8_TPESTR = '7'"
		Else
			cQuery +=                                    " AND DC8.DC8_TPESTR <> '7'"
		EndIf
		cQuery +=                                    " AND DC8.D_E_L_E_T_ = ' '"
	EndIf
	cQuery +=                                     " WHERE D14.D14_FILIAL = '"+xFilial('D14')+"'"
	If !Empty(Self:oProdLote:GetPrdOri())
		cQuery +=                                   " AND D14.D14_PRDORI = '"+Self:oProdLote:GetPrdOri()+"'"
	EndIf
	If !Empty(Self:oEndereco:GetArmazem())
		cQuery +=                                   " AND D14.D14_LOCAL = '"+Self:oEndereco:GetArmazem()+"'"
	EndIf
	If !Empty(Self:oEndereco:GetEnder())
		cQuery +=                                   " AND D14.D14_ENDER = '"+Self:oEndereco:GetEnder()+"'"
	EndIf
	If !Empty(Self:oProdLote:GetLoteCtl())
		cQuery +=                                   " AND D14.D14_LOTECT = '"+Self:oProdLote:GetLoteCtl()+"'"
	EndIf
	If !Empty(Self:oProdLote:GetNumLote())
		cQuery +=                                   " AND D14.D14_NUMLOT = '"+Self:oProdLote:GetNumLote()+"'"
	EndIf
	If !Empty(Self:oProdLote:GetNumSer())
		cQuery +=                                   " AND D14.D14_NUMSER = '"+Self:oProdLote:GetNumSer()+"'"
	EndIf
	If !Empty(Self:cIdUnitiz)
		cQuery +=                                   " AND D14.D14_IDUNIT = '"+Self:cIdUnitiz+"'"
	EndIf
	cQuery +=                                       " AND D14.D_E_L_E_T_ = ' '"
	cQuery +=                                     " GROUP BY D14_ENDER,"
	cQuery +=                                              " D14_LOTECT,"
	cQuery +=                                              " D14_NUMLOT,"
	cQuery +=                                              " D14_NUMSER,"
	cQuery +=                                              " D14_IDUNIT,"
	cQuery +=                                              " D14_CODUNI,"
	cQuery +=                                              " D14_DTVALD) D14"
	cQuery +=                           " ON D14.QTD = D11.QTD) ENDERECOS "
	cQuery +=              " ON ENDERECOS.D14_ENDER  = D14A.D14_ENDER"
	cQuery +=             " AND ENDERECOS.D14_LOTECT = D14A.D14_LOTECT"
	cQuery +=             " AND ENDERECOS.D14_NUMLOT = D14A.D14_NUMLOT"
	cQuery +=             " AND ENDERECOS.D14_NUMSER = D14A.D14_NUMSER"
	cQuery +=             " AND ENDERECOS.D14_IDUNIT = D14A.D14_IDUNIT"
	cQuery +=             " AND ENDERECOS.D14_DTVALD = D14A.D14_DTVALD"
	cQuery +=           " WHERE D14A.D14_FILIAL = '"+xFilial('D14')+"'"
	If !Empty(Self:oProdLote:GetPrdOri())
		cQuery +=         " AND D14A.D14_PRDORI = '"+Self:oProdLote:GetPrdOri()+"'"
	EndIf
	If !Empty(Self:oEndereco:GetArmazem())
		cQuery +=         " AND D14A.D14_LOCAL = '"+Self:oEndereco:GetArmazem()+"'"
	EndIf
	If !Empty(Self:oEndereco:GetEnder())
		cQuery +=         " AND D14A.D14_ENDER = '"+Self:oEndereco:GetEnder()+"'"
	EndIf
	If !Empty(Self:oProdLote:GetLoteCtl())
		cQuery +=         " AND D14A.D14_LOTECT = '"+Self:oProdLote:GetLoteCtl()+"'"
	EndIf
	If !Empty(Self:oProdLote:GetNumLote())
		cQuery +=         " AND D14A.D14_NUMLOT = '"+Self:oProdLote:GetNumLote()+"'"
	EndIf
	If !Empty(Self:oProdLote:GetNumSer())
		cQuery +=        " AND D14A.D14_NUMSER = '"+Self:oProdLote:GetNumSer()+"'"
	EndIf
	If !Empty(Self:cIdUnitiz)
		cQuery +=        " AND D14A.D14_IDUNIT = '"+Self:cIdUnitiz+"'"
	EndIf
	cQuery +=             " AND D14A.D_E_L_E_T_ = ' ') SALDO"
	cQuery +=   " WHERE SALDO.QTDEST >= 1"
	cQuery +=   " ORDER BY"
	Do Case
		Case nOrdem == 0
			cQuery += " SALDO.QTDEST DESC "
		Case nOrdem == 1
			cQuery += " SALDO.D14_LOCAL,"
			cQuery += " SALDO.D14_ENDER,"
			cQuery += " SALDO.D14_PRDORI,"
			cQuery += " SALDO.D14_LOTECT,"
			cQuery += " SALDO.D14_NUMLOT,"
			cQuery += " SALDO.D14_NUMSER,"
			cQuery += " SALDO.D14_IDUNIT"
		Case nOrdem == 2
			cQuery += " SALDO.D14_LOCAL,"
			cQuery += " SALDO.D14_PRDORI,"
			cQuery += " SALDO.D14_ESTFIS"
		Case nOrdem == 3
			cQuery += " SALDO.D14_PRDORI,"
			cQuery += " SALDO.D14_ENDER"
	EndCase
	cQuery += "%"
Return Nil
//----------------------------------------
/*/{Protheus.doc} GetQryComp
Monta query para buscar a quantidade de produtos 'componentes' nos endereços.
@author felipe.m
@since 20/10/2016
@version 2.0
@param cQuery, caractere, (Query)
@param lConsSaida, lógico, (Indica se considera saída)
@param nOrdem, numérico, (Ordenação dos dados com base no índice (D14), se passado 0, ordena por quantidade)
/*/
//----------------------------------------
METHOD GetQryComp(cQuery,lConsSaida,nOrdem,nQtdSpr) CLASS WMSDTCEstoqueEndereco
	cQuery :=       "% D14.D14_LOCAL,"
	cQuery +=        " D14.D14_ENDER,"
	cQuery +=        " D14.D14_LOTECT,"
	cQuery +=        " D14.D14_NUMLOT,"
	cQuery +=        " D14.D14_NUMSER,"
	If lConsSaida
		cQuery +=        " (D14.D14_QTDEST-(D14.D14_QTDEMP+D14.D14_QTDBLQ+(D14.D14_QTDSPR- "+cValToChar(nQtdSpr)+"))) D14_QTDEST,"
	Else
		cQuery +=        " D14.D14_QTDEST D14_QTDEST,"
	EndIf
	cQuery +=        " D14.D14_DTVALD,"
	cQuery +=        " D14.D14_PRDORI,"
	cQuery +=        " D14.D14_PRODUT,"
	cQuery +=        " D14.D14_IDUNIT,"
	cQuery +=        " D14.D14_CODUNI"
	cQuery +=   " FROM "+RetSqlName("D14")+" D14"
	If Self:lProducao
		cQuery += " INNER JOIN "+RetSqlName('DC8')+" DC8"
		cQuery +=    " ON DC8.DC8_FILIAL = '"+xFilial('DC8')+"'"
		cQuery +=   " AND DC8.DC8_CODEST = D14.D14_ESTFIS"
		cQuery +=   " AND DC8.DC8_TPESTR = '7'"
		cQuery +=   " AND DC8.D_E_L_E_T_ = ' '"
	EndIf
	cQuery +=  " WHERE D14.D14_FILIAL = '"+xFilial("D14")+"'"
	cQuery +=    " AND D14.D_E_L_E_T_ = ' '"
	If !Empty(Self:oEndereco:GetArmazem())
		cQuery += " AND D14.D14_LOCAL = '"+Self:oEndereco:GetArmazem()+"'"
	EndIf
	If !Empty(Self:oEndereco:GetEnder())
		cQuery += " AND D14.D14_ENDER = '"+Self:oEndereco:GetEnder()+"'"
	EndIf
	If !Empty(Self:oProdLote:GetLoteCtl())
		cQuery += " AND D14.D14_LOTECT = '"+Self:oProdLote:GetLoteCtl()+"'"
	EndIf
	If !Empty(Self:oProdLote:GetNumLote())
		cQuery += " AND D14.D14_NUMLOT = '"+Self:oProdLote:GetNumLote()+"'"
	EndIf
	If !Empty(Self:oProdLote:GetNumSer())
		cQuery += " AND D14.D14_NUMSER = '"+Self:oProdLote:GetNumSer()+"'"
	EndIf
	If !Empty(Self:cIdUnitiz)
		cQuery += " AND D14.D14_IDUNIT = '"+Self:cIdUnitiz+"'"
	EndIf
	If !Empty(Self:oProdLote:GetPrdOri())
		cQuery += " AND D14.D14_PRDORI = '"+Self:oProdLote:GetPrdOri()+"'"
	EndIf
	If !Empty(Self:oProdLote:GetProduto())
		cQuery += " AND D14.D14_PRODUT = '"+Self:oProdLote:GetProduto()+"'"
	EndIf
	If lConsSaida
		cQuery +=  " AND (D14.D14_QTDEST-(D14.D14_QTDEMP+D14.D14_QTDBLQ+(D14.D14_QTDSPR- "+cValToChar(nQtdSpr)+"))) > 0"
	EndIf
	cQuery +=  " ORDER BY"
	Do Case
		Case nOrdem == 0
			cQuery += " D14.D14_QTDEST DESC "
		Case nOrdem == 1
			cQuery += " D14.D14_LOCAL,"
			cQuery += " D14.D14_ENDER,"
			cQuery += " D14.D14_PRDORI,"
			cQuery += " D14.D14_PRODUT,"
			cQuery += " D14.D14_LOTECT,"
			cQuery += " D14.D14_NUMLOT,"
			cQuery += " D14.D14_NUMSER,"
			cQuery += " D14.D14_IDUNIT"
		Case nOrdem == 2
			cQuery += " D14.D14_LOCAL,"
			cQuery += " D14.D14_PRODUT,"
			cQuery += " D14.D14_ESTFIS"
		Case nOrdem == 3
			cQuery += " D14.D14_PRODUT,"
			cQuery += " D14.D14_ENDER"
	EndCase
	cQuery += "%"
Return Nil

METHOD WmsGeraOP(cLocal, cProduto, nQtd) CLASS WMSDTCEstoqueEndereco
Local aAreaAnt := GetArea()
Local aMata650 := {}
Local lRet     := .T.
Local cNum     := ""

Private lMSErroAuto := .F.
Private lMSHelpAuto := .T.

	cNum := GetSX8Num("SC2","C2_NUM")
	If __lSX8
		ConfirmSX8()
	EndIf

	//-------------------------------
	// Adiciona os dados em um vetor
	//-------------------------------
	SB1->(dbSeek(xFilial("SB1")+cProduto))
	aAdd(aMata650, {"C2_NUM"		, cNum      ,Nil})
	aAdd(aMata650, {"C2_ITEM"		, "01"      ,Nil})
	aAdd(aMata650, {"C2_SEQUEN" 	, "001"     ,Nil})
	aAdd(aMata650, {"C2_PRODUTO"	, cProduto  ,Nil})
	aAdd(aMata650, {"C2_QUANT"  	, nQtd      ,Nil})
	aAdd(aMata650, {"C2_LOCAL"  	, cLocal    ,Nil})
	aAdd(aMata650, {"C2_DATPRI" 	, dDataBase ,Nil})
	aAdd(aMata650, {"C2_DATPRF" 	, dDataBase ,Nil})
	aAdd(aMata650, {"C2_EMISSAO"	, dDataBase ,Nil})
	aAdd(aMata650, {"C2_TPOP"  		, "F"       ,Nil})
	aAdd(aMata650, {'AUTEXPLODE'	, "N"       ,Nil})
	//-----------------------------
	// Executa a rotina automatica
	//-----------------------------
	MSExecAuto({|x,y| mata650(x,y)},aMata650,3) // 3=Inclusao, 5=Exclusão
	// Chave da ordem de produção
	cNum := SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)
	If lMsErroAuto
		DisarmTransaction()
		MostraErro()
		cNum := ""
	EndIf
	RestArea(aAreaAnt)
Return cNum

METHOD WmsApontOp(cNum, cProduto, nQtd, cDocSD3, nRecno, cLocal, cLote, cNumLote, cServic) CLASS WMSDTCEstoqueEndereco
Local lRet     := .T.
Local aAreaAnt := GetArea()
Local aMata250 := {}
Local cTm      := SuperGetMv("MV_WMSTMMT",.F.,"")
Local cAliasQry:= Nil
Local cRastro  := ""

Default cLote    := CriaVar("D3_LOTECTL")
Default cNumLote := CriaVar("D3_NUMLOTE")
Default cServic  := CriaVar("D3_SERVIC")
Private lMSErroAuto := .F.
Private lMSHelpAuto := .T.
Private lExecWms    := .T.

	If Empty(cTm)
		WmsMessage(STR0006,"WmsApontOp") //"Configure o parâmetro MV_WMSTMMT para realizar o movimento de montagem."
		DisarmTransaction()
		lRet := .F.
	EndIf

	If lRet
		SB1->(dbSeek(xFilial("SB1")+cProduto))
		cRastro := SB1->B1_RASTRO
		aAdd(aMata250,{})
		aAdd(aMata250[01],{"D3_TM"     ,cTm                   ,Nil})
		aAdd(aMata250[01],{"D3_COD"    ,cProduto              ,Nil})
		aAdd(aMata250[01],{"D3_QUANT"  ,nQtd                  ,Nil})
		aAdd(aMata250[01],{"D3_EMISSAO",dDataBase             ,Nil})
		aAdd(aMata250[01],{"D3_TIPO"   ,""                    ,Nil})
		aAdd(aMata250[01],{"D3_CF"     ,"PR0"                 ,Nil})
		aAdd(aMata250[01],{"D3_OP"     ,cNum                  ,Nil})
		aAdd(aMata250[01],{"D3_DOC"    ,cDocSD3               ,Nil})
		aAdd(aMata250[01],{"D3_CHAVE"  ,"R0"                  ,Nil})
		aAdd(aMata250[01],{"D3_PARCTOT","T"                   ,Nil})
		aAdd(aMata250[01],{"D3_SERVIC" ,cServic               ,Nil})
		aAdd(aMata250[01],{"D3_USUARIO",Substr(cUsuario,7,15) ,Nil})
		If cRastro $ 'S|L'
			aAdd(aMata250[01],{"D3_LOTECTL",cLote                 ,Nil})
			If cRastro == "S"
				aAdd(aMata250[01],{"D3_NUMLOTE",cNumLote              ,Nil})
			EndIf
		EndIf
		MSExecAuto({|x,y| mata250(x,y)},aMata250[1],3)
		If lMSErroAuto
			DisarmTransaction()
			Mostraerro()
			lRet := .F.
		EndIf
	EndIf
	If lRet
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT SD3.R_E_C_N_O_ RECNOSD3
			FROM %Table:SD3% SD3
			WHERE SD3.D3_FILIAL = %xFilial:SD3%
			AND SD3.D3_OP = %Exp:cNum%
			AND SD3.D3_COD = %Exp:cProduto%
			AND SD3.D3_LOCAL = %Exp:cLocal%
			AND SD3.D_E_L_E_T_ = ' '"
		EndSql
		If (cAliasQry)->(!Eof())
			// Pega o recno da movimentação do apontamento que acabou de gerar
			nRecno := (cAliasQry)->RECNOSD3
			(cAliasQry)->(dbSkip())
		EndIf
		(cAliasQry)->(dbCloseArea())

		If Empty(nRecno)
			nRecno := SD3->(Recno())
		EndIf
	EndIf
	RestArea(aAreaAnt)
Return lRet
//----------------------------------------
/*/{Protheus.doc} GeraMovEst
Geraçãdo do movimento de estoque endereço (Kardex)
@author felipe.m
@since 12/05/2017
@version 1.0
@param cTipo, Caracter, (499=Entrada,999=Saída)
/*/
//----------------------------------------
METHOD GeraMovEst(cTipo) CLASS WMSDTCEstoqueEndereco
Local lRet       := .T.
Local oMovEstEnd := WMSDTCMovimentosEstoqueEndereco():New(.F.)

	// Informações do movimento estoque endereço
	oMovEstEnd:SetTipMov(cTipo)
	oMovEstEnd:SetDtEsto(dDataBase)
	oMovEstEnd:SetHrEsto(Time())
	oMovEstEnd:SetQtdEst(Self:GetQuant())
	oMovEstEnd:SetIdUnit(Self:GetIdUnit())
	// Preenche as informações do documento DCF por bloco de código
	If ValType(Self:bGetDocto) == "B"
		Eval(Self:bGetDocto,oMovEstEnd)
		// SetDocto()
		// SetSerie()
		// SetCliFor()
		// SetLoja()
		// SetOrigem()
		// SetNumSeq()
		// SetIdDCF()
	EndIf
	// Preenche informações do movimento D12 por bloco de código
	If ValType(Self:bGetMovto) == "B"
		Eval(Self:bGetMovto,oMovEstEnd)
		// SetIdMovto()
		// SetIdOpera()
		// SetIdUnit()
		// SetlUsalCal() // Opcional, default .T.
	EndIf
	// Preenche informaçãoes do endereço
	oMovEstEnd:SetArmazem(Self:oEndereco:GetArmazem())
	oMovEstEnd:SetEnder(Self:oEndereco:GetEnder())
	// Preenche informações do produto
	oMovEstEnd:SetPrdOri(Self:oProdLote:GetPrdOri())
	oMovEstEnd:SetProduto(Self:oProdLote:GetProduto())
	oMovEstEnd:SetLoteCtl(Self:oProdLote:GetLoteCtl())
	oMovEstEnd:SetNumLote(Self:oProdLote:GetNumLote())
	oMovEstEnd:SetNumSer(Self:oProdLote:GetNumSer())
	// Gravação do movimento estoque endereço
	If !(lRet := oMovEstEnd:RecordD13())
		Self:cErro := oMovEstEnd:GetErro()
	EndIf
Return lRet

METHOD WmsReqPart(cDocSD3,dDataInv,cNumSeq,cPrdComp,cArmazem,cEndereco,cLoteCtl,cNumLote,nQuant,cNumOp) CLASS WMSDTCEstoqueEndereco
Local aAreaAnt  := GetArea()
Local lRet      := .T.
Local aCab      := {}
Local aRotAuto  := {}
Local cTm       := SuperGetMv("MV_WMSTMRQ",.F.,"")
Local cAliasQry := Nil
Local nRateio   := 0
Local dDtValid  := CToD("  /  /    ")
Local lRastro   := Self:oProdLote:HasRastro()

Private lMsErroAuto := .F.
Private lExecWms    := Nil
Private lDocWms     := Nil

	If Empty(cTm)
		WmsMessage(STR0007,"WmsReqPart") //"Configure o parâmetro MV_WMSTMRQ para realizar o movimento de montagem."
		DisarmTransaction()
		lRet := .F.
	EndIf
	If lRet
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT D11.D11_RATEIO
			FROM %Table:D11% D11
			WHERE D11.D11_FILIAL = %xFilial:D11%
			AND D11.D11_PRDCMP = %Exp:cPrdComp%
			AND D11.%NotDel%
		EndSql
		TcSetField(cAliasQry,'D11_RATEIO','N',Self:aD11_RATEIO[1],Self:aD11_RATEIO[2])
		If (cAliasQry)->(!Eof())
			nRateio := (cAliasQry)->D11_RATEIO
		EndIf
		(cAliasQry)->(dbCloseArea())
		If lRastro
			cAliasQry := GetNextAlias()
			BeginSql Alias cAliasQry
				SELECT SB8.B8_DTVALID
				FROM %Table:SB8% SB8
				WHERE SB8.B8_FILIAL = %xFilial:SB8%
				AND SB8.B8_NUMLOTE = %Exp:cNumLote%
				AND SB8.B8_LOTECTL = %Exp:cLoteCtl%
				AND SB8.B8_PRODUTO = %Exp:cPrdComp%
				AND SB8.B8_LOCAL = %Exp:cArmazem%
				AND SB8.%NotDel%
			EndSql
			TcSetField(cAliasQry,'B8_DTVALID','D')
			If (cAliasQry)->(!Eof())
				dDtValid := (cAliasQry)->B8_DTVALID
			EndIf
			(cAliasQry)->(dbCloseArea())
		EndIf
	EndIf
	If lRet
		aAdd(aCab,{"D3_TM"     , cTm      , Nil})
		aAdd(aCab,{"D3_DOC"    , cDocSD3  , Nil})
		aAdd(aCab,{"D3_EMISSAO", dDataInv , Nil})
		// Itens SD3
		aAdd(aRotAuto,{})
		aAdd(aRotAuto[01], {"D3_NUMSEQ" , cNumSeq   ,Nil})
		aAdd(aRotAuto[01], {"D3_COD"    , cPrdComp  ,Nil})
		aAdd(aRotAuto[01], {"D3_LOCAL"  , cArmazem  ,Nil})
		aAdd(aRotAuto[01], {"D3_LOCALIZ", cEndereco ,Nil})
		aAdd(aRotAuto[01], {"D3_QUANT"  , nQuant    ,Nil})
		aAdd(aRotAuto[01], {"D3_OP"     , cNumOp    ,Nil})
		aAdd(aRotAuto[01], {"D3_USUARIO", cUserName ,Nil})
		aAdd(aRotAuto[01], {"D3_CF"     , "RE0"     ,Nil})
		aAdd(aRotAuto[01], {"D3_CHAVE"  , "E0"      ,Nil})
		aAdd(aRotAuto[01], {"D3_RATEIO" , Iif(Empty(nRateio),100,nRateio),Nil})
		If lRastro
			aAdd(aRotAuto[01], {"D3_LOTECTL", cLoteCtl ,Nil})
			aAdd(aRotAuto[01], {"D3_NUMLOTE", cNumLote ,Nil})
			aAdd(aRotAuto[01], {"D3_DTVALID", dDtValid ,Nil})
		EndIf
		// Indica que será DH1 e DCF
		lExecWms       := .T.
		lDocWms        := .T.
		// Realiza a baixa do SD3 com base no DH1
		MSExecAuto({|x,y,z| MATA241(x,y,z)},aCab,aRotAuto,3) //Inclusão
		If lMSErroAuto
			DisarmTransaction()
			Mostraerro()
			lRet := .F.
		EndIf
	EndIf
	RestArea(aAreaAnt)
Return lRet

METHOD GeraEmpReq(cOrigem,cOp,cTrt,cIdDCF,lEstorno,lCriaSDC,lEmpD14) CLASS WMSDTCEstoqueEndereco
Local lRet := .T.

Default cIdDCF   := ""
Default lEstorno := .F.
Default lCriaSDC := .F.
Default lEmpD14  := .T.

	If lEmpD14
		lRet := Self:UpdSaldo(Iif(lEstorno,'999','499'),.F.,.F.,.F.,.T.) // Somente empenho
	EndIf
	If lRet .And. lCriaSDC
		lRet := WmsAtuSDC(cOrigem,cOp,cTrt,/*cPedido*/,/*cItem*/,/*cSeqSC9*/,;
			Self:oProdLote:GetProduto(),;
			Self:oProdLote:GetLoteCtl(),;
			Self:oProdLote:GetNumLote(),;
			Self:oProdLote:GetNumSer(),;
			Self:nQuant,Nil,;
			Self:oEndereco:GetArmazem(),;
			Self:oEndereco:GetEnder(),;
			cIdDCF,2,lEstorno)
		If !lRet
			Self:cErro := WmsFmtMsg(STR0008,{{"[VAR01]",cOp},{"[VAR02]",Self:oEndereco:GetArmazem()},{"[VAR03]",Self:oEndereco:GetEnder()}}) //Problema ao gerar o empenho para a OP [VAR01] no armazém/endereço [VAR02]/[VAR03]. (SDC)
		EndIf
	EndIf
Return lRet
//----------------------------------------
/*/{Protheus.doc} FindSldPrd
Avalia o saldo de um endereço permitindo quando controla lote o rateio pelo Fifo
@author Squad WMS Protheus
@since 30/10/2018
@version 1.0
@param nQtdRat, Numerico, Quantidade requisitada
/*/
//----------------------------------------
METHOD FindSldPrd(nQtdRat) CLASS WMSDTCEstoqueEndereco
Local lRet      := .T.
Local lAchou    := .F.
Local lRastro   := Self:oProdLote:HasRastro()
Local cQuery    := ""
Local cAliasD14 := Nil
	// Busca o saldo mais antigo com quantidade que atenda na completude
	cQuery :=      "% D14.D14_LOTECT,"
	cQuery +=       " D14.D14_NUMLOT,"
	cQuery +=       " D14.D14_NUMSER,"
	If lRastro .And. Empty(Self:oProdLote:GetLoteCtl())
		cQuery +=   " MIN(D14.D14_DTVALD) D14_DTVALD,"
		cQuery += " CASE WHEN ((SB8.B8_SALDO - SB8.B8_EMPENHO) > (D14.D14_QTDEST - (D14.D14_QTDSPR + D14.D14_QTDBLQ + D14.D14_QTDPEM + D14.D14_QTDEMP)))"
		cQuery +=      " THEN (D14.D14_QTDEST - (D14.D14_QTDSPR + D14.D14_QTDBLQ + D14.D14_QTDPEM + D14.D14_QTDEMP))"
		cQuery +=      " ELSE (SB8.B8_SALDO - SB8.B8_EMPENHO) END D14_QTDEST"
	Else
		cQuery +=   " (D14.D14_QTDEST - (D14.D14_QTDSPR + D14.D14_QTDBLQ + D14.D14_QTDPEM + D14.D14_QTDEMP)) D14_QTDEST"
	EndIf
	cQuery +=  " FROM "+RetSqlName("D14")+" D14"
	If lRastro
		cQuery += " INNER JOIN "+RetSqlName("SB8")+" SB8"
		cQuery +=    " ON SB8.B8_FILIAL = '"+xFilial("SB8")+"'"
		cQuery +=   " AND SB8.B8_LOCAL = D14.D14_LOCAL"
		cQuery +=   " AND SB8.B8_PRODUTO = D14.D14_PRODUT"
		cQuery +=   " AND SB8.B8_LOTECTL = D14.D14_LOTECT"
		cQuery +=   " AND SB8.B8_NUMLOTE = D14.D14_NUMLOT"
		cQuery +=   " AND SB8.D_E_L_E_T_ = ' '"
	EndIf
	cQuery += " WHERE D14.D14_FILIAL = '"+xFilial("D14")+"'"
	cQuery +=   " AND D14.D14_LOCAL = '"+Self:oEndereco:GetArmazem()+"'"
	cQuery +=   " AND D14.D14_ENDER = '"+Self:oEndereco:GetEnder()+"'"
	cQuery +=   " AND D14.D14_PRODUT = '"+Self:oProdLote:GetProduto()+"'"
	cQuery +=   " AND D14.D14_PRDORI = '"+Self:oProdLote:GetPrdOri()+"'"
	If !Empty(Self:oProdLote:GetLoteCtl())
		cQuery +=   " AND D14.D14_LOTECT = '"+Self:oProdLote:GetLoteCtl()+"'"
	EndIf
	If !Empty(Self:oProdLote:GetNumLote())
		cQuery +=   " AND D14.D14_NUMLOT = '"+Self:oProdLote:GetNumLote()+"'"
	EndIf
	If !Empty(Self:oProdLote:GetNumSer())
		cQuery +=   " AND D14.D14_NUMSER = '"+Self:oProdLote:GetNumSer()+"'"
	EndIf
	cQuery +=   " AND (D14.D14_QTDEST - (D14.D14_QTDSPR + D14.D14_QTDEMP + D14.D14_QTDBLQ)) > 0"
	cQuery +=   " AND D14.D_E_L_E_T_ = ' '"
	If lRastro
		cQuery += " GROUP BY D14.D14_DTVALD,"
		cQuery +=          " D14.D14_LOTECT,"
		cQuery +=          " D14.D14_NUMLOT,"
		cQuery +=          " D14.D14_NUMSER,"
		cQuery +=          " D14.D14_QTDEST,"
		cQuery +=          " D14.D14_QTDSPR,"
		cQuery +=          " D14.D14_QTDEMP,"
		cQuery +=          " D14.D14_QTDBLQ,"
		cQuery +=          " D14.D14_QTDPEM,"
		cQuery +=          " SB8.B8_EMPENHO,"
		cQuery +=          " SB8.B8_SALDO"
	EndIf
	cQuery += "%"
	cAliasD14 := GetNextAlias()
	BeginSql Alias cAliasD14
		SELECT %Exp:cQuery%
	EndSql
	TcSetField(cAliasD14,'D14_QTDEST','N',Self:aD14_QTDEST[1],Self:aD14_QTDEST[2])
	Do While (cAliasD14)->(!Eof()) .And. !lAchou
		If QtdComp((cAliasD14)->D14_QTDEST) > QtdComp(0)
			Self:oProdLote:SetLoteCtl((cAliasD14)->D14_LOTECT)
			Self:oProdLote:SetNumLote((cAliasD14)->D14_NUMLOT)
			Self:nQuant := IIf(QtdComp(nQtdRat) >= QtdComp((cAliasD14)->D14_QTDEST),(cAliasD14)->D14_QTDEST,nQtdRat)
			lAchou := .T.
		EndIf
		(cAliasD14)->(dbSkip())
	EndDo
	(cAliasD14)->(dbCloseArea())
	If !lAchou
		Self:cErro := WmsFmtMsg(STR0009,{{"[VAR01]",AllTrim(Self:oEndereco:GetArmazem())},{"[VAR02]",AllTrim(Self:oEndereco:GetEnder())}}) // Não encontrado saldo disponível no armazém [VAR01] e endereço [VAR02]!
		lRet := .F.
	EndIf
Return lRet
//----------------------------------------
/*/{Protheus.doc} GerUniEst
Geração de saldo unitizado quando saldo em produto e alterado o armazém para controlar unitizadores
Quando informado o unitizador e o tipo do unitizador irá validar se o unitizador existe e se não está usado
Quando não informado o unitizador irá gerar um novo unitizador com o tipo do unitizador padrão

@author Squad WMS Protheus
@since 30/10/2018
@version 1.0
@param cArmazem, Caracter, Armazém
@param cEndereco, Caracter, Endereço com saldo
@param cIdUnit, Caracter, Identificador do unitizador
@param cTipUni, Caracter, Tipo do unitizador
/*/
//----------------------------------------
METHOD GerUnitEst(cArmazem, cEndereco, cIdUnit, cTipUni) CLASS WMSDTCEstoqueEndereco
Local lRet      := .T.
Local oEtiqUnit := Nil
Local bGetDocto := Nil
Local cAliasD14 := Nil
Local cIdUnitVz := Space(Len(Self:cIdUnitiz))

Default cIdUnit := Space(Len(Self:cIdUnitiz))
Default cTipUni := Space(Len(Self:cTipUni))
	// Valida o armazém
	If Empty(cArmazem)
		Self:cErro := STR0010 // Armazém não informado
		lRet := .F.
	EndIf
	// Valida o endereço
	If lRet .And. Empty(cEndereco)
		Self:cErro := STR0011 // Endereço não informado
		lRet := .F.
	EndIf
	// Quando não informada a etiqueta do unitizador
	// gera automaticamente
	If lRet .And. Empty(cIdUnit)
		cIdUnit := WmsGerUnit(.F.,.T.,.T.)
	EndIf
	// Valida a etiqueta do unitizador
	If lRet 
		If !Empty(cIdUnit)
			oEtiqUnit := WMSDTCEtiquetaUnitizador():New()
			oEtiqUnit:SetIdUnit(cIdUnit)
			If oEtiqUnit:LoadData()
				If oEtiqUnit:GetIsUsed()
					Self:cErro := STR0012 // Etiqueta já utilizada
					lRet := .F.
				EndIf
			Else
				Self:cErro := oEtiqUnit:GetErro()
			EndIf
			If !Empty(cTipUni)
				oEtiqUnit:SetTipUni(cTipUni)
			EndIf
			// Valida o tipo de unitizador
			If lRet .And. Empty(oEtiqUnit:GetTipUni())
				Self:cErro := STR0013 // Tipo do unitizador não informado
				lRet := .F.
			EndIf
		Else
			Self:cErro := STR0014 // Etiqueta do unitizador não informada
			lRet := .F.
		EndIf
	EndIf
	// Busca os saldos do produto no endereço cuja: 
	// Armazém controla unitizador
	// Estrutura física do endereço controla unitizadores 
	// Não existe saldo já unitizado no endereço
	If lRet
		cAliasD14 := GetNextAlias()
		BeginSql Alias cAliasD14
			SELECT D14.D14_LOCAL,
					D14.D14_ENDER,
					D14.D14_PRODUT,
					D14.D14_PRDORI,
					D14.D14_LOTECT,
					D14.D14_NUMLOT,
					D14.D14_NUMSER,
					D14.D14_IDUNIT,
					D14.D14_CODUNI,
					D14.D14_QTDEST
			FROM %Table:D14% D14
			INNER JOIN %Table:NNR% NNR
			ON NNR.NNR_FILIAL = %xFilial:NNR%
			AND NNR.NNR_CODIGO = D14.D14_LOCAL
			AND NNR.NNR_AMZUNI = '1'
			AND NNR.%NotDel%
			INNER JOIN %Table:DC8% DC8
			ON DC8.DC8_FILIAL = %xFilial:DC8%
			AND DC8.DC8_CODEST = D14.D14_ESTFIS
			AND DC8.DC8_TPESTR IN ('1','3','4','6')
			AND DC8.%NotDel%
			WHERE D14.D14_FILIAL = %xFilial:D14%
			AND D14.D14_LOCAL = %Exp:cArmazem%
			AND D14.D14_ENDER = %Exp:cEndereco%
			AND D14.D14_IDUNIT = %Exp:cIdUnitVz%
			AND NOT EXISTS (SELECT 1 
							FROM %Table:D14% D14A
							WHERE D14A.D14_FILIAL = D14.D14_FILIAL
							AND D14A.D14_LOCAL = D14.D14_LOCAL
							AND D14A.D14_ENDER = D14.D14_ENDE"
							AND D14A.D14_IDUNIT <> %Exp:cIdUnitVz%
							AND D14A.%NotDel% )
			AND (D14.D14_QTDEPR + D14.D14_QTDSPR + D14.D14_QTDBLQ + D14.D14_QTDPEM + D14.D14_QTDEMP) = 0
			AND D14.%NotDel%
		EndSql
		If (cAliasD14)->(!Eof())
			Do While (cAliasD14)->(!Eof())
				// Endereço
				Self:oEndereco:SetArmazem((cAliasD14)->D14_LOCAL)
				Self:oEndereco:SetEnder((cAliasD14)->D14_ENDER)
				// Produto
				Self:oProdLote:SetArmazem((cAliasD14)->D14_LOCAL)
				Self:oProdLote:SetProduto((cAliasD14)->D14_PRODUT)
				Self:oProdLote:SetPrdOri((cAliasD14)->D14_PRDORI)
				Self:oProdLote:SetLoteCtl((cAliasD14)->D14_LOTECT)
				Self:oProdLote:SetNumLote((cAliasD14)->D14_NUMLOT)
				Self:oProdLote:SetNumSer((cAliasD14)->D14_NUMSER)
				Self:SetIdUnit((cAliasD14)->D14_IDUNIT)
				Self:SetTipUni((cAliasD14)->D14_CODUNI)
				Self:SetQuant((cAliasD14)->D14_QTDEST)
				// Seta o bloco de código para informações do documento para o Kardex
				Self:SetBlkDoc({|oMovEstEnd|;
					oMovEstEnd:SetOrigem("D14"),;
					oMovEstEnd:SetDocto("UNIT");
				})
				// Seta o bloco de código para informações do movimento para o Kardex
				Self:SetBlkMov({|oMovEstEnd|;
								oMovEstEnd:SetIdUnit(Self:cIdUnitiz);
								})
				// Retira o saldo do endereço informado, que está com unitizador em branco
				lRet := Self:UpdSaldo("999",.T./*lEstoque*/,.F./*lEntPrev*/,.F./*lSaiPrev*/,.F./*lEmpenho*/,.F./*lBloqueio*/,.F./*lEmpPrev*/,.T./*lMovEstEnd*/)
				If lRet
					// Atribui a quantidade ao mesmo endereço, porém com unitizador informado
					Self:SetIdUnit(oEtiqUnit:GetIdUnit())
					Self:SetTipUni(oEtiqUnit:GetTipUni())
					lRet := Self:UpdSaldo("499",.T./*lEstoque*/,.F./*lEntPrev*/,.F./*lSaiPrev*/,.F./*lEmpenho*/,.F./*lBloqueio*/,.F./*lEmpPrev*/,.T./*lMovEstEnd*/)
				EndIf
				oEtiqUnit:SetUsado("1")
				oEtiqUnit:UpdateD0Y()
				(cAliasD14)->(dbSkip())
			EndDo
		Else
			Self:cErro := STR0015 // Dados não encontrados, verifique se o armazém é unitizado, se as estruturas físicas controlam o unitizador e se há saldos no endereço sem o unitizador informado.
			lRet := .F.
		EndIf
		(cAliasD14)->(dbCloseArea())
		oEtiqUnit:Destroy()
	EndIf
Return lRet
//----------------------------------------
/*/{Protheus.doc} MakeFatLoj
Realiza a retirada do armazem de loja ao realizar o faturamento
@author Squad WMS Protheus
@since 31/10/2018
@version 1.0
@param nRecno, numérico, (Recno SD2)
/*/
//----------------------------------------
METHOD MakeFatLoj(nRecnoSD2) CLASS WMSDTCEstoqueEndereco
Local lRet       := .T.
Local aProduto   := {}
Local nProduto   := 0
Local oMovEstEnd := WMSDTCMovimentosEstoqueEndereco():New()
Local oProdLote  := WMSDTCProdutoLote():New()
Local aAreaSD2   := SD2->(GetArea())
	If Empty(nRecnoSD2)
		lRet := .F.
		Self:cErro := STR0003 // Recno não informado!
	EndIf
	If lRet
		SD2->(dbGoTo(nRecnoSD2))
		oProdLote:SetArmazem(SD2->D2_LOCAL)
		oProdLote:SetPrdOri(SD2->D2_COD)
		oProdLote:SetProduto(SD2->D2_COD)
		oProdLote:SetLoteCtl(SD2->D2_LOTECTL)
		oProdLote:SetNumLote(SD2->D2_NUMLOTE)
		oProdLote:SetNumSer(SD2->D2_NUMSERI)
		oProdLote:LoadData()
		// AtualizaSaldo
		// Carrega estrutura do produto x componente
		aProduto := oProdLote:GetArrProd()
		If Len(aProduto) > 0
			For nProduto := 1 To Len(aProduto)
				// Carrega dados para Estoque por Endereço
				Self:oEndereco:SetArmazem(oProdLote:GetArmazem())
				Self:oEndereco:SetEnder(SD2->D2_LOCALIZ)
				Self:oProdLote:SetArmazem(oProdLote:GetArmazem())
				Self:oProdLote:SetPrdOri(oProdLote:GetPrdOri())   // Produto Origem
				Self:oProdLote:SetProduto(aProduto[nProduto][1] ) // Componente
				Self:oProdLote:SetLoteCtl(oProdLote:GetLotectl()) // Lote do produto principal que deverá ser o mesmo no componentes
				Self:oProdLote:SetNumLote(oProdLote:GetNumLote()) // Sub-Lote do produto principal que deverá ser o mesmo no componentes
				Self:oProdLote:SetNumSer(oProdLote:GetNumSer()) // Número de série do produto
				Self:SetIdUnit("")
				Self:LoadData()
				Self:SetQuant(QtdComp(SD2->D2_QUANT * aProduto[nProduto][2]) )
				// Seta o bloco de código para informações do documento para o Kardex
				Self:SetBlkDoc({|oMovEstEnd|;
					oMovEstEnd:SetOrigem("SD2"),;
					oMovEstEnd:SetDocto(SD2->D2_DOC),;
					oMovEstEnd:SetNumSeq(SD2->D2_NUMSEQ);
				})
				// Realiza Saída Armazem Estoque por Endereço
				lRet := Self:UpdSaldo("999",.T. /*lEstoque*/,.F. /*lEntPrev*/,.F. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/,.F. /*lEmpPrev*/,.T./*lMovEstEnd*/)
			Next
		Else
			Self:cErro := STR0004 // Produto não encontrado.
			lRet := .F.
		EndIf
	EndIf
	RestArea(aAreaSD2)
Return lRet
//----------------------------------------
/*/{Protheus.doc} UndoFatLoj
Recompor o saldo na exclusão do faturamento
@author Squad WMS Protheus
@since 31/10/2018
@version 1.0
@param nRecno, numérico, (Recno SD2)
/*/
//----------------------------------------
METHOD UndoFatLoj(nRecnoSD2) CLASS WMSDTCEstoqueEndereco
Local lRet       := .T.
Local aProduto   := {}
Local nProduto   := 0
Local oMovEstEnd := WMSDTCMovimentosEstoqueEndereco():New()
Local oProdLote  := WMSDTCProdutoLote():New()
Local aAreaSD2   := SD2->(GetArea())
Local cAliasD13  := Nil

	If Empty(nRecnoSD2)
		lRet := .F.
		Self:cErro := STR0003 // Recno não informado!
	EndIf
	If lRet
		SD2->(dbGoTo(nRecnoSD2))
		oProdLote:SetArmazem(SD2->D2_LOCAL)
		oProdLote:SetPrdOri(SD2->D2_COD)
		oProdLote:SetProduto(SD2->D2_COD)
		oProdLote:SetLoteCtl(SD2->D2_LOTECTL)
		oProdLote:SetNumLote(SD2->D2_NUMLOTE)
		oProdLote:SetNumSer(SD2->D2_NUMSERI)
		oProdLote:LoadData()
		// AtualizaSaldo
		// Carrega estrutura do produto x componente
		aProduto := oProdLote:GetArrProd()
		If Len(aProduto) > 0
			For nProduto := 1 To Len(aProduto)
				// Carrega dados para Estoque por Endereço
				Self:oEndereco:SetArmazem(oProdLote:GetArmazem())
				Self:oEndereco:SetEnder(SD2->D2_LOCALIZ)
				Self:oProdLote:SetArmazem(oProdLote:GetArmazem())
				Self:oProdLote:SetPrdOri(oProdLote:GetPrdOri())   // Produto Origem
				Self:oProdLote:SetProduto(aProduto[nProduto][1] ) // Componente
				Self:oProdLote:SetLoteCtl(oProdLote:GetLotectl()) // Lote do produto principal que deverá ser o mesmo no componentes
				Self:oProdLote:SetNumLote(oProdLote:GetNumLote()) // Sub-Lote do produto principal que deverá ser o mesmo no componentes
				Self:oProdLote:SetNumSer(oProdLote:GetNumSer()) // Número de série do produto
				Self:SetIdUnit("")
				Self:LoadData()
				Self:SetQuant(QtdComp(SD2->D2_QUANT * aProduto[nProduto][2]) )
				// Seta o bloco de código para informações do documento para o Kardex
				Self:SetBlkDoc({|oMovEstEnd|;
					oMovEstEnd:SetOrigem("SD2"),;
					oMovEstEnd:SetDocto(SD2->D2_DOC),;
					oMovEstEnd:SetNumSeq(SD2->D2_NUMSEQ);
				})
				// Seta o bloco de código para informações do movimento para o Kardex
				Self:SetBlkMov({|oMovEstEnd|;
					oMovEstEnd:SetlUsaCal(.F.);
				})
				// Realiza Entrada Armazem Estoque por Endereço
				lRet := Self:UpdSaldo("499",.T. /*lEstoque*/,.F. /*lEntPrev*/,.F. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/,.F. /*lEmpPrev*/,.T./*lMovEstEnd*/)
				// Verifica os movimentos da ordem de serviço origem para desconsiderar
				// no cálculo de estoque 
				If lRet .And. WmsX312118("D13","D13_USACAL")
					cAliasD13 := GetNextAlias()
					BeginSql Alias cAliasD13
						SELECT D13.R_E_C_N_O_ RECNOD13
						FROM "+RetSqlName('D13')+" D13"
						WHERE D13.D13_FILIAL = %xFilial:D13%
						AND D13.D13_DOC = %Exp:SD2->D2_DOC%
						AND D13.D13_NUMSEQ = %Exp:SD2->D2_NUMSEQ%
						AND D13.D13_USACAL <> '2'
						AND D13.%NotDel%
					EndSql
					Do While (cAliasD13)->(!Eof())
						D13->(dbGoTo((cAliasD13)->RECNOD13))
						RecLock("D13",.F.)
						D13->D13_USACAL = '2'
						D13->(MsUnLock())
						(cAliasD13)->(dbSkip())
					EndDo
					(cAliasD13)->(dbCloseArea())
				EndIf
			Next
		Else
			Self:cErro := STR0004 // Produto não encontrado.
			lRet := .F.
		EndIf
	EndIf
	RestArea(aAreaSD2)
Return lRet
//----------------------------------------
/*/{Protheus.doc} MakePerda
Executa a baixa de estoque no apontamento de perda por OP
@author  Squad WMS Protheus
@since   26/03/2019
@version 1.0
@param   nRecnoSBC, numérico, (Recno SBC)
/*/
//----------------------------------------
METHOD MakePerda(nRecnoSBC) CLASS WMSDTCEstoqueEndereco
Local lRet       := .T.
Local lRastro    := Rastro(SBC->BC_PRODUTO)
Local aAreaSBC   := SBC->(GetArea())
Local aProduto   := {}
Local oMovEstEnd := WMSDTCMovimentosEstoqueEndereco():New()
Local oProdLote  := WMSDTCProdutoLote():New()
Local cAliasSD4  := Nil
Local cIdDCFVz   := Space(Self:aDCF_ID[1])
Local nProduto   := 0
Local nDiferenca := 0
Local nNewRecno  := 0
Local nRecnoAtu  := 0
Local nSaldoPerda:= 0
Local nQtdPerda  := 0
Local nSaldoEnd  := 0
Local nSaldoPrd  := 0

	If Empty(nRecnoSBC)
		lRet := .F.
		Self:cErro := STR0003 // Recno não informado!
	EndIf
	If lRet
		SBC->(dbGoTo(nRecnoSBC))
		oProdLote:SetArmazem(SBC->BC_LOCORIG)
		oProdLote:SetPrdOri(SBC->BC_PRODUTO)
		oProdLote:SetProduto(SBC->BC_PRODUTO)
		oProdLote:SetLoteCtl(SBC->BC_LOTECTL)
		oProdLote:SetNumLote(SBC->BC_NUMLOTE)
		oProdLote:SetNumSer(SBC->BC_NUMSERI)
		oProdLote:LoadData()

		cAliasSD4 := GetNextAlias()
		BeginSql Alias cAliasSD4
			SELECT SD4.R_E_C_N_O_ RECNOSD4
			FROM %Table:SD4% SD4
			WHERE SD4.D4_FILIAL = %xFilial:SD4%
			AND SD4.D4_COD = %Exp:SBC->BC_PRODUTO%
			AND SD4.D4_OP = %Exp:SBC->BC_OP%
			AND SD4.D4_LOTECTL = %Exp:SBC->BC_LOTECTL%
			AND SD4.D4_NUMLOTE = %Exp:SBC->BC_NUMLOTE%
			AND SD4.D4_IDDCF <> %Exp:cIdDCFVz%
			AND SD4.%NotDel%
		EndSql
		If (cAliasSD4)->(!EoF())
			SD4->(DbGoTo((cAliasSD4)->RECNOSD4))
			//Armazena recno da SD4
			nRecnoAtu  := (cAliasSD4)->RECNOSD4
		EndIf
		(cAliasSD4)->(DbCloseArea())
		// Carrega estrutura do produto x componente
		aProduto := oProdLote:GetArrProd()
		//Se definido que não baixa empenho, verifica se ainda possuí saldo no endereço WMS
		If Len(aProduto) > 0
			For nProduto := 1 To Len(aProduto)
				nSaldoPrd   := 0
				nSaldoPerda := 0
				nSaldoEnd   := 0
				nQtdPerda   := SBC->BC_QUANT * aProduto[nProduto][2]

				Self:ClearData()
				Self:oProdLote:SetArmazem(oProdLote:GetArmazem())
				Self:oProdLote:SetProduto(aProduto[nProduto][1])
				Self:oProdLote:SetPrdOri(aProduto[nProduto][3])
				Self:oProdLote:SetLoteCtl(oProdLote:GetLotectl())
				Self:oProdLote:SetNumLote(oProdLote:GetNumLote())
				Self:oProdLote:SetNumSer("")
				Self:oProdLote:LoadData()
				Self:oEndereco:SetArmazem(oProdLote:GetArmazem())
				//Consulta saldo do produto
				nSaldoPrd := Self:ConsultSld(.F.,.T.,.T.,.T.)
				Self:oEndereco:SetEnder(SBC->BC_LOCALIZ)
				//Consulta saldo do endereço
				nSaldoEnd := Self:ConsultSld(.F.,.T.,.T.,.T.)
				//Saldo da perda que será utilizado de referencia para ajuste da SD4 e SDC
				//Não utiliza toda a quantidade da perda pois o que não possuí saldo em estoque (SB8) já foi ajustado previamente nas funções do módulo PCP
				If lRastro
					nSaldoPerda := Iif(nSaldoPrd < nQtdPerda,nSaldoPrd,nQtdPerda)
				Else
					nSaldoPerda := nQtdPerda
				EndIf
				If !Empty(SD4->D4_QUANT) .And. nSaldoPerda > nSaldoEnd
					
					//Valor que precisará ser descontado da SD4 e SDC por falta de saldo no endereço
					nDiferenca := (nSaldoPerda - nSaldoEnd)

					If !(nDiferenca == SD4->D4_QUANT) //Verifica se a OP pode ser parcialmente atendida
						WmsDivSD4(SD4->D4_COD,;
								 oProdLote:GetArmazem(),;
								 SD4->D4_OP,;
								 SD4->D4_TRT,;
								 oProdLote:GetLotectl(),;
								 oProdLote:GetNumLote(),;
								 Nil,;
								 nDiferenca/aProduto[nProduto][2],;
								 Nil,;
								 Nil,;
								 Nil,;
								 .F.,;
								 SD4->(Recno()),;
								 Nil,;
								 @nNewRecno)
							
								
						//Posiciona na OP "original"
						SD4->(DbGoTo(nRecnoAtu))

						WmsAtuSDC("SC2",;
									SD4->D4_OP,;
									SD4->D4_TRT,;
									Nil,;
									Nil,;
									Nil,;
									SD4->D4_COD,;
									oProdLote:GetLotectl(),;
									oProdLote:GetNumLote(),;
									oProdLote:GetNumSer(),;
									nDiferenca/aProduto[nProduto][2],;
									ConvUM(aProduto[nProduto][1], nDiferenca, 0, 2),;
									oProdLote:GetArmazem(),;
									SBC->BC_LOCALIZ,;
									SD4->D4_IDDCF,;
									2,;
									.T.)
					Else
						//Remove ID DCF da op para forçar nova requisição WMS.
						RecLock("SD4", .F.)
						SD4->D4_IDDCF := ""
						SD4->(MsUnlock())
					EndIf
				EndIf
				// Carrega dados para Estoque por Endereço
				Self:oEndereco:SetArmazem(oProdLote:GetArmazem())
				Self:oEndereco:SetEnder(SBC->BC_LOCALIZ)
				Self:oProdLote:SetArmazem(oProdLote:GetArmazem())
				Self:oProdLote:SetPrdOri(oProdLote:GetPrdOri())   // Produto Origem
				Self:oProdLote:SetProduto(aProduto[nProduto][1] ) // Componente
				Self:oProdLote:SetLoteCtl(oProdLote:GetLotectl()) // Lote do produto principal que deverá ser o mesmo no componentes
				Self:oProdLote:SetNumLote(oProdLote:GetNumLote()) // Sub-Lote do produto principal que deverá ser o mesmo no componentes
				Self:oProdLote:SetNumSer(oProdLote:GetNumSer()) // Número de série do produto
				Self:SetIdUnit("")
				Self:LoadData()

				// Seta o bloco de código para informações do documento para o Kardex
				Self:SetBlkDoc({|oMovEstEnd|;
					oMovEstEnd:SetOrigem("SBC"),;
					oMovEstEnd:SetDocto(SBC->BC_OP),;
					oMovEstEnd:SetNumSeq(SBC->BC_SEQSD3);
				})
				//Baixa saldo
				Self:SetQuant(QtdComp(nQtdPerda))
				lRet := Self:UpdSaldo("999",.T. /*lEstoque*/,.F. /*lEntPrev*/,.F. /*lSaiPrev*/,.F./*lEmpenho*/,.F. /*lBloqueio*/,.F. /*lEmpPrev*/,.T./*lMovEstEnd*/)
				//Baixa empenho separadamente, pois nem sempre a quantidade de baixa de estoque é igual a quantidade de baixa de empenho
				//O empenho apenas é baixado quando não existe mais saldo no endereço, caso ainda exista, mantêm empenhado para a op
				If lRet
					If nSaldoEnd < nQtdPerda
						Self:SetQuant(QtdComp((nQtdPerda - nSaldoEnd)) )
						// Realiza Saída Armazem Estoque por Endereço
						lRet := Self:UpdSaldo("999",.F. /*lEstoque*/,.F. /*lEntPrev*/,.F. /*lSaiPrev*/,.T./*lEmpenho*/,.F. /*lBloqueio*/,.F. /*lEmpPrev*/,.F./*lMovEstEnd*/)
					EndIf
				Else
					Exit
				EndIf
			Next
		Else
			Self:cErro := STR0004 // Produto não encontrado.
			lRet := .F.
		EndIf
	EndIf
	RestArea(aAreaSBC)
Return lRet
//----------------------------------------
/*/{Protheus.doc} UndoPerda
Recompor o saldo do apontamento de perda por OP
@author  Squad WMS Protheus
@since   26/03/2019
@version 1.0
@param   nRecnoSBC, numérico, (Recno SBC)
/*/
//----------------------------------------
METHOD UndoPerda(nRecnoSBC) CLASS WMSDTCEstoqueEndereco
Local lRet       := .T.
Local aAreaSBC   := SBC->(GetArea())
Local aProduto   := {}
Local oMovEstEnd := WMSDTCMovimentosEstoqueEndereco():New()
Local oProdLote  := WMSDTCProdutoLote():New()
Local cAliasD13  := Nil
Local nProduto   := 0
	If Empty(nRecnoSBC)
		lRet := .F.
		Self:cErro := STR0003 // Recno não informado!
	EndIf
	If lRet
		SBC->(dbGoTo(nRecnoSBC))
		oProdLote:SetArmazem(SBC->BC_LOCORIG)
		oProdLote:SetPrdOri(SBC->BC_PRODUTO)
		oProdLote:SetProduto(SBC->BC_PRODUTO)
		oProdLote:SetLoteCtl(SBC->BC_LOTECTL)
		oProdLote:SetNumLote(SBC->BC_NUMLOTE)
		oProdLote:SetNumSer(SBC->BC_NUMSERI)
		oProdLote:LoadData()
		// AtualizaSaldo
		// Carrega estrutura do produto x componente
		aProduto := oProdLote:GetArrProd()
		If Len(aProduto) > 0
			For nProduto := 1 To Len(aProduto)
				// Carrega dados para Estoque por Endereço
				Self:oEndereco:SetArmazem(oProdLote:GetArmazem())
				Self:oEndereco:SetEnder(SBC->BC_LOCALIZ)
				Self:oProdLote:SetArmazem(oProdLote:GetArmazem())
				Self:oProdLote:SetPrdOri(oProdLote:GetPrdOri())   // Produto Origem
				Self:oProdLote:SetProduto(aProduto[nProduto][1] ) // Componente
				Self:oProdLote:SetLoteCtl(oProdLote:GetLotectl()) // Lote do produto principal que deverá ser o mesmo no componentes
				Self:oProdLote:SetNumLote(oProdLote:GetNumLote()) // Sub-Lote do produto principal que deverá ser o mesmo no componentes
				Self:oProdLote:SetNumSer(oProdLote:GetNumSer()) // Número de série do produto
				Self:SetIdUnit("")
				Self:LoadData()
				Self:SetQuant(QtdComp(SBC->BC_QUANT * aProduto[nProduto][2]) )
				// Seta o bloco de código para informações do documento para o Kardex
				Self:SetBlkDoc({|oMovEstEnd|;
					oMovEstEnd:SetOrigem("SBC"),;
					oMovEstEnd:SetDocto(SBC->BC_OP),;
					oMovEstEnd:SetNumSeq(SBC->BC_SEQSD3); // Enviamos o NumSeq da SD3 porque o NumSeq da SBC permanece o mesmo quando fazemos a perda de diversos itens de uma só vez
				})
				// Seta o bloco de código para informações do movimento para o Kardex
				Self:SetBlkMov({|oMovEstEnd|;
					oMovEstEnd:SetlUsaCal(.F.);
				})
				// Realiza Entrada Armazem Estoque por Endereço
				lRet := Self:UpdSaldo("499",.T. /*lEstoque*/,.F. /*lEntPrev*/,.F. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/,.F. /*lEmpPrev*/,.T./*lMovEstEnd*/)
				// Verifica os movimentos da ordem de serviço origem para desconsiderar
				// no cálculo de estoque 
				If lRet .And. WmsX312118("D13","D13_USACAL")
					cAliasD13 := GetNextAlias()
					BeginSql Alias cAliasD13
						SELECT  D13.R_E_C_N_O_ RECNOD13
						FROM %Table:D13% D13
						WHERE D13.D13_FILIAL = %xFilial:D13%
						AND D13.D13_DOC = %Exp:SBC->BC_OP%
						AND D13.D13_NUMSEQ = %Exp:SBC->BC_NUMSEQ%
						AND D13.D13_USACAL <> '2'
						AND D13.%NotDel%
					EndSql
					Do While (cAliasD13)->(!Eof())
						D13->(dbGoTo((cAliasD13)->RECNOD13))
						RecLock("D13",.F.)
						D13->D13_USACAL = '2'
						D13->(MsUnLock())
						(cAliasD13)->(dbSkip())
					EndDo
					(cAliasD13)->(dbCloseArea())
				EndIf
			Next
		Else
			Self:cErro := STR0004 // Produto não encontrado.
			lRet := .F.
		EndIf
	EndIf
	RestArea(aAreaSBC)
Return lRet
//----------------------------------------
/*/{Protheus.doc} SelectKard
Busca as informações de divergencia entre o Kardex por endereço
e o saldo estoque por endereço.
@author Squad WMS Protheus
@since 22/11/2018
@version 1.0
@param lProcess, Lógico, Result a quantidade de registros quando .F. e os registros quando .T. 
@param dData, Date, Data Movimentação - Default dDatabase
@param cArmazem, Caracter, Armazém filtro da análise
@param cPrdOri, Caracter, Produto Origem filtro da análise
/*/
//----------------------------------------
METHOD SelectKard(lProcess,cArmazem,cPrdOri) CLASS WMSDTCEstoqueEndereco
Local cAliasQry  := Nil
Local cWhere     := ""
Local cCampos    := ""
Local cCamposAux := ""
Local cDecimal   := cValtoChar(Self:aD14_QTDEST[1])+","+cValtoChar(Self:aD14_QTDEST[2])
Local dData      := Dtos(dDataBase)

Default lProcess := .T.
	// Parâmetro cWhere
	If !Empty(cArmazem)
		cWhere += " AND TOT.TOT_LOCAL = '"+cArmazem+"'"
	EndIf
	If !Empty(cPrdOri)
		cWhere += " AND TOT.TOT_PRDORI = '"+cPrdOri+"'"
	EndIf
	cWhere := "%"+cWhere+"%"
	// Parâmetro cCampos
	If lProcess
		cCampos += " TOT.TOT_LOCAL,"
		cCampos += " TOT.TOT_ENDER,"
		cCampos += " TOT.TOT_PRDORI,"
		cCampos += " TOT.TOT_PRODUT,"
		cCampos += " TOT.TOT_LOTECT,"
		cCampos += " TOT.TOT_NUMLOT,"
		cCampos += " TOT.TOT_NUMSER,"
		cCampos += " TOT.TOT_IDUNIT,"
		cCampos += " CASE WHEN (TOT.TOT_QTDEST - ((TOT.TOT_QTDINI + TOT.TOT_QTDENT) - TOT.TOT_QTDSAI)) < 0"
		cCampos +=      " THEN '999'"
		cCampos +=      " ELSE '499'"
		cCampos +=      " END TOT_TM,"
		cCampos += " CASE WHEN (TOT.TOT_QTDEST - ((TOT.TOT_QTDINI + TOT.TOT_QTDENT) - TOT.TOT_QTDSAI)) < 0"
		cCampos +=      " THEN (TOT.TOT_QTDEST - ((TOT.TOT_QTDINI + TOT.TOT_QTDENT) - TOT.TOT_QTDSAI)) * -1"
		cCampos +=      " ELSE (TOT.TOT_QTDEST - ((TOT.TOT_QTDINI + TOT.TOT_QTDENT) - TOT.TOT_QTDSAI))"
		cCampos +=      " END TOT_QTDEST"
	Else
		cCampos += " COUNT(*) NR_COUNT"
	EndIf
	cCampos := "%"+cCampos+"%"
	// Parâmetro cCamposAux
	cCamposAux += " CAST((CASE WHEN SLD_QTDEST IS NULL THEN 0 ELSE SLD_QTDEST END) AS DECIMAL ("+cDecimal+")) TOT_QTDEST,"
	cCamposAux += " CAST((CASE WHEN FCH.FCH_SALDO IS NULL THEN 0 ELSE FCH.FCH_SALDO END) AS DECIMAL ("+cDecimal+")) TOT_QTDINI,"
	cCamposAux += " CAST((CASE WHEN ENT.ENT_SALDO IS NULL THEN 0 ELSE ENT.ENT_SALDO END) AS DECIMAL ("+cDecimal+")) TOT_QTDENT,"
	cCamposAux += " CAST((CASE WHEN SAI.SAI_SALDO IS NULL THEN 0 ELSE SAI.SAI_SALDO END) AS DECIMAL ("+cDecimal+")) TOT_QTDSAI"
	cCamposAux := "%"+cCamposAux+"%"
	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT %Exp:cCampos% 
		FROM (
			SELECT TOT_LOCAL,
					TOT_ENDER,
					TOT_PRDORI,
					TOT_PRODUT,
					TOT_LOTECT,
					TOT_NUMLOT,
					TOT_NUMSER,
					TOT_IDUNIT,
					CASE WHEN FCH.FCH_DATA IS NULL THEN '19800101' ELSE FCH.FCH_DATA END TOT_DATA,
					%Exp:cCamposAux%
			FROM (
				SELECT D14.D14_LOCAL TOT_LOCAL,
						D14.D14_ENDER TOT_ENDER,
						D14.D14_PRDORI TOT_PRDORI,
						D14.D14_PRODUT TOT_PRODUT,
						D14.D14_LOTECT TOT_LOTECT,
						D14.D14_NUMLOT TOT_NUMLOT,
						D14.D14_NUMSER TOT_NUMSER,
						D14.D14_IDUNIT TOT_IDUNIT
				FROM %Table:D14% D14
				WHERE D14.D14_FILIAL = %xFilial:D14%
				AND D14.%NotDel%
				UNION ALL
				SELECT D13.D13_LOCAL TOT_LOCAL,
						D13.D13_ENDER TOT_ENDER,
						D13.D13_PRDORI TOT_PRDORI,
						D13.D13_PRODUT TOT_PRODUT,
						D13.D13_LOTECT TOT_LOTECT,
						D13.D13_NUMLOT TOT_NUMLOT,
						D13.D13_NUMSER TOT_NUMSER,
						D13.D13_IDUNIT TOT_IDUNIT
				FROM %Table:D13% D13
				WHERE D13.D13_FILIAL = %xFilial:D13%
				AND D13.%NotDel%
				) TOT
			LEFT JOIN (
				SELECT D14.D14_LOCAL SLD_LOCAL,
						D14.D14_ENDER SLD_ENDER,
						D14.D14_PRDORI SLD_PRDORI,
						D14.D14_PRODUT SLD_PRODUT,
						D14.D14_LOTECT SLD_LOTECT,
						D14.D14_NUMLOT SLD_NUMLOT,
						D14.D14_NUMSER SLD_NUMSER,
						D14.D14_IDUNIT SLD_IDUNIT,
						D14.D14_QTDEST SLD_QTDEST
				FROM %Table:D14% D14
				WHERE D14.D14_FILIAL = %xFilial:D14%
				AND D14.%NotDel%
				) SLD
				ON SLD.SLD_LOCAL = TOT.TOT_LOCAL
				AND SLD.SLD_ENDER = TOT.TOT_ENDER
				AND SLD.SLD_PRDORI = TOT.TOT_PRDORI
				AND SLD.SLD_PRODUT = TOT.TOT_PRODUT
				AND SLD.SLD_LOTECT = TOT.TOT_LOTECT
				AND SLD.SLD_NUMLOT = TOT.TOT_NUMLOT
				AND SLD.SLD_NUMSER = TOT.TOT_NUMSER
				AND SLD.SLD_IDUNIT = TOT.TOT_IDUNIT
			LEFT JOIN (
				SELECT MAX(D15.D15_DATA) FCH_DATA,
						D15.D15_LOCAL FCH_LOCAL,
						D15.D15_ENDER FCH_ENDER,
						D15.D15_PRDORI FCH_PRDORI,
						D15.D15_PRODUT FCH_PRODUT,
						D15.D15_LOTECT FCH_LOTECT,
						D15.D15_NUMLOT FCH_NUMLOT,
						D15.D15_NUMSER FCH_NUMSER,
						D15.D15_IDUNIT FCH_IDUNIT,
						D15.D15_QINI FCH_SALDO
				FROM %Table:D15% D15
				WHERE D15.D15_FILIAL = %xFilial:D15%
				AND D15.D15_DATA <= %Exp:dData%
				AND D15.%NotDel%
				GROUP BY D15.D15_LOCAL,
							D15.D15_ENDER,
							D15.D15_PRDORI,
							D15.D15_PRODUT,
							D15.D15_LOTECT,
							D15.D15_NUMLOT,
							D15.D15_NUMSER,
							D15.D15_IDUNIT,
							D15.D15_QINI
				) FCH 
				ON FCH.FCH_LOCAL = TOT.TOT_LOCAL
				AND FCH.FCH_ENDER = TOT.TOT_ENDER
				AND FCH.FCH_PRDORI = TOT.TOT_PRDORI
				AND FCH.FCH_PRODUT = TOT.TOT_PRODUT
				AND FCH.FCH_LOTECT = TOT.TOT_LOTECT
				AND FCH.FCH_NUMLOT = TOT.TOT_NUMLOT
				AND FCH.FCH_NUMSER = TOT.TOT_NUMSER
				AND FCH.FCH_IDUNIT = TOT.TOT_IDUNIT
			LEFT JOIN (
				SELECT D13.D13_LOCAL ENT_LOCAL,
						D13.D13_ENDER ENT_ENDER,
						D13.D13_PRDORI ENT_PRDORI,
						D13.D13_PRODUT ENT_PRODUT,
						D13.D13_LOTECT ENT_LOTECT,
						D13.D13_NUMLOT ENT_NUMLOT,
						D13.D13_NUMSER ENT_NUMSER,
						D13.D13_IDUNIT ENT_IDUNIT,
						SUM(D13.D13_QTDEST) ENT_SALDO
				FROM %Table:D13% D13
				WHERE D13.D13_FILIAL = %xFilial:D13%
				AND D13.D13_DTESTO >= (
										SELECT CASE WHEN MAX(D15.D15_DATA) IS NULL THEN '19800101' ELSE MAX(D15.D15_DATA) END D15_DATA
										FROM %Table:D15% D15
										WHERE D15.D15_FILIAL = %xFilial:D15%
										AND D15.D15_LOCAL = D13.D13_LOCAL
										AND D15.D15_ENDER = D13.D13_ENDER
										AND D15.D15_PRDORI = D13.D13_PRDORI
										AND D15.D15_PRODUT = D13.D13_PRODUT
										AND D15.D15_LOTECT = D13.D13_LOTECT
										AND D15.D15_NUMLOT = D13.D13_NUMLOT
										AND D15.D15_NUMSER = D13.D13_NUMSER
										AND D15.D15_IDUNIT = D13.D13_IDUNIT
										AND D15.D15_DATA <= %Exp:dData%
										AND D15.%NotDel%
										)
				AND D13.D13_DTESTO <= %Exp:dData%
				AND D13.D13_TM = '499'
				AND D13.D13_USACAL <> '2'
				AND D13.%NotDel%
				GROUP BY D13.D13_LOCAL,
							D13.D13_ENDER,
							D13.D13_PRDORI,
							D13.D13_PRODUT,
							D13.D13_LOTECT,
							D13.D13_NUMLOT,
							D13.D13_NUMSER,
							D13.D13_IDUNIT
				) ENT 
				ON ENT.ENT_LOCAL = TOT.TOT_LOCAL
				AND ENT.ENT_ENDER = TOT.TOT_ENDER
				AND ENT.ENT_PRDORI = TOT.TOT_PRDORI
				AND ENT.ENT_PRODUT = TOT.TOT_PRODUT
				AND ENT.ENT_LOTECT = TOT.TOT_LOTECT
				AND ENT.ENT_NUMLOT = TOT.TOT_NUMLOT
				AND ENT.ENT_NUMSER = TOT.TOT_NUMSER
				AND ENT.ENT_IDUNIT = TOT.TOT_IDUNIT
			LEFT JOIN (
				SELECT D13.D13_LOCAL SAI_LOCAL,
						D13.D13_ENDER SAI_ENDER,
						D13.D13_PRDORI SAI_PRDORI,
						D13.D13_PRODUT SAI_PRODUT,
						D13.D13_LOTECT SAI_LOTECT,
						D13.D13_NUMLOT SAI_NUMLOT,
						D13.D13_NUMSER SAI_NUMSER,
						D13.D13_IDUNIT SAI_IDUNIT,
						SUM(D13.D13_QTDEST) SAI_SALDO
				FROM %Table:D13% D13
				WHERE D13.D13_FILIAL = %xFilial:D13%
				AND D13.D13_DTESTO >= (
										SELECT CASE WHEN MAX(D15.D15_DATA) IS NULL THEN '19800101' ELSE MAX(D15.D15_DATA) END D15_DATA
										FROM %Table:D15% D15
										WHERE D15.D15_FILIAL = %xFilial:D15%
										AND D15.D15_LOCAL = D13.D13_LOCAL
										AND D15.D15_ENDER = D13.D13_ENDER
										AND D15.D15_PRDORI = D13.D13_PRDORI
										AND D15.D15_PRODUT = D13.D13_PRODUT
										AND D15.D15_LOTECT = D13.D13_LOTECT
										AND D15.D15_NUMLOT = D13.D13_NUMLOT
										AND D15.D15_NUMSER = D13.D13_NUMSER
										AND D15.D15_IDUNIT = D13.D13_IDUNIT
										AND D15.D15_DATA <= %Exp:dData%
										AND D15.%NotDel%
										)
				AND D13.D13_DTESTO <= %Exp:dData%
				AND D13.D13_TM = '999'
				AND D13.D13_USACAL <> '2'
				AND D13.%NotDel%
				GROUP BY D13.D13_LOCAL,
							D13.D13_ENDER,
							D13.D13_PRDORI,
							D13.D13_PRODUT,
							D13.D13_LOTECT,
							D13.D13_NUMLOT,
							D13.D13_NUMSER,
							D13.D13_IDUNIT
				) SAI
				ON SAI.SAI_LOCAL = TOT.TOT_LOCAL
				AND SAI.SAI_ENDER = TOT.TOT_ENDER
				AND SAI.SAI_PRDORI = TOT.TOT_PRDORI
				AND SAI.SAI_PRODUT = TOT.TOT_PRODUT
				AND SAI.SAI_LOTECT = TOT.TOT_LOTECT
				AND SAI.SAI_NUMLOT = TOT.TOT_NUMLOT
				AND SAI.SAI_NUMSER = TOT.TOT_NUMSER
				AND SAI.SAI_IDUNIT = TOT.TOT_IDUNIT
			GROUP BY TOT.TOT_LOCAL,
						TOT.TOT_ENDER,
						TOT.TOT_PRDORI,
						TOT.TOT_PRODUT,
						TOT.TOT_LOTECT,
						TOT.TOT_NUMLOT,
						TOT.TOT_NUMSER,
						TOT.TOT_IDUNIT,
						FCH.FCH_DATA,
						SLD.SLD_QTDEST,
						FCH.FCH_SALDO,
						ENT.ENT_SALDO,
						SAI.SAI_SALDO
			) TOT
		WHERE (TOT.TOT_QTDEST - ((TOT.TOT_QTDINI + TOT.TOT_QTDENT) - TOT.TOT_QTDSAI)) <> 0
		AND TOT.TOT_ENDER <> '  '¨
		%Exp:cWhere%
	EndSql
Return cAliasQry
//----------------------------------------
/*/{Protheus.doc} EquateKard
Ajusta os registro do kardex com base na quantidade
do estoque por endereço WMS
@author Squad WMS Protheus
@since 22/11/2018
@version 1.0
@param cArmazem, Caracter, Armazém filtro da análise
@param cProduto, Caracter, Produto filtro da análise
@param oProcess, Objeto para controlar progresso
/*/
//----------------------------------------
METHOD EquateKard(cArmazem,cProduto,oProcess) CLASS WMSDTCEstoqueEndereco
Local lRet        := .T.
Local lProcess    := oProcess <> Nil
Local lContinua   := .T.
Local cAliasQry   := Nil
Local cAliasQr1   := Nil
Local cDocumento  := "AJT_D13"
Local cDecimal    := cValtoChar(Self:aD14_QTDEST[1])+","+cValtoChar(Self:aD14_QTDEST[2])
Local cOrigem     := "D14"
Local dData       := dDataBase
	// Verificar a quantidade de registros
	If lProcess
		cAliasQr1 := Self:SelectKard(.F.,cArmazem,cProduto)
		If (cAliasQr1)->(!Eof()) .And. (cAliasQr1)->NR_COUNT > 0
			oProcess:SetRegua1((cAliasQr1)->NR_COUNT)
			oProcess:SetRegua2(2)
		Else
			lContinua := .F.
		EndIf
		(cAliasQr1)->(dbCloseArea())
	EndIf
	If lContinua
		// Busca registros para processamento
		cAliasQry := Self:SelectKard(.T.,cArmazem,cProduto)
		Do While (cAliasQry)->(!Eof())
			If lProcess
				oProcess:IncRegua1( WmsFmtMsg(STR0016 + "...",{{"[VAR01]",cValToChar(oProcess:nMeter1+1)},{"[VAR02]",cValToChar(oProcess:oMeter1:nTotal)}}) ) // Processando [VAR01]/[VAR02] registro(s)
				oProcess:IncRegua2(WmsFmtMsg(STR0017,{{"[VAR01]","(D14|D13)"}})) // Atualizando [VAR01]
			EndIf
			// Carrega dados para Estoque por Endereço
			Self:ClearData()
			Self:oEndereco:SetArmazem((cAliasQry)->TOT_LOCAL)   // Armazem
			Self:oEndereco:SetEnder((cAliasQry)->TOT_ENDER)     // Endereço
			Self:oProdLote:SetArmazem((cAliasQry)->TOT_LOCAL)   // Armazem
			Self:oProdLote:SetPrdOri((cAliasQry)->TOT_PRDORI)   // Produto Origem
			Self:oProdLote:SetProduto((cAliasQry)->TOT_PRODUT)  // Produto/Componente
			Self:oProdLote:SetLoteCtl((cAliasQry)->TOT_LOTECT)  // Lote do produto
			Self:oProdLote:SetNumLote((cAliasQry)->TOT_NUMLOT)  // Sub-Lote do lote do produto
			Self:oProdLote:SetNumSer((cAliasQry)->TOT_NUMSER)   // Numero de serie
			Self:SetQuant((cAliasQry)->TOT_QTDEST)
			// Seta o bloco de código para informações do documento
			Self:SetBlkDoc({|oMovEstEnd|;
				oMovEstEnd:SetOrigem(cOrigem),;                 // Origem do movimento
				oMovEstEnd:SetDocto(cDocumento);                // Documento
			})
			// Seta o bloco de código para informações do movimento
			Self:SetBlkMov({|oMovEstEnd|;
				oMovEstEnd:SetIdUnit((cAliasQry)->TOT_IDUNIT);   // Identificador do unitizador
			})
			lRet := Self:GeraMovEst((cAliasQry)->TOT_TM)
			// Próximo registro
			If lProcess
				oProcess:IncRegua2(WmsFmtMsg(STR0018,{{"[VAR01]","(D14|D13)"}})) // Finalizando [VAR01]
			EndIf
			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(dbCloseArea())
	EndIf
Return lRet
//----------------------------------------
/*/{Protheus.doc} SelectEst
Busca as informações de divergencia entre o estoque do produto
e o estoque por endereço WMS
@author Squad WMS Protheus
@since 31/01/2019
@version 1.0
@param lProcess, Lógico, Result a quantidade de registros quando .F. e os registros quando .T. 
@param cArmazem, Caracter, Armazém filtro da análise
@param cProduto, Caracter, Produto filtro da análise
/*/
//----------------------------------------
METHOD SelectEst(lProcess,cArmazem,cProduto) CLASS WMSDTCEstoqueEndereco
Local cWhere     := ""
Local cCampos    := ""
Local cCamposAux := ""
Local cAliasQry  := Nil
Local cDecimal   := cValtoChar(Self:aD14_QTDEST[1])+","+cValtoChar(Self:aD14_QTDEST[2])
	// Parâmetro cWhere
	If !Empty(cArmazem)
		cWhere += " AND SB2.B2_LOCAL = '"+cArmazem+"'"
	EndIf
	If !Empty(cProduto)
		cWhere += " AND SB2.B2_COD = '"+cProduto+"'"
	EndIf
	cWhere := "%"+cWhere+"%"
	// Parâmetro cCAmpos
	If lProcess
		cCampos += " TOT.TOT_LOCAL,"
		cCampos += " 'INVENTARIO' TOT_ENDER,"
		cCampos += " TOT.TOT_PRDORI,"
		cCampos += " TOT.TOT_PRODUT,"
		cCampos += " TOT.TOT_LOTECT,"
		cCampos += " TOT.TOT_NUMLOT,"
		cCampos += " CASE WHEN (TOT.TOT_QTDEST - TOT.TOT_QTDD14) < 0 THEN '999'"
		cCampos +=      " ELSE '499' END TOT_TM,"
		cCampos += " CASE WHEN (TOT.TOT_QTDEST - TOT.TOT_QTDD14) < 0 THEN (TOT.TOT_QTDEST - TOT.TOT_QTDD14) * -1"
		cCampos +=      " ELSE (TOT.TOT_QTDEST -  TOT.TOT_QTDD14) END TOT_QTDDIF"
	Else
		cCampos += " COUNT(*) NR_COUNT"
	EndIf
	cCampos := "%"+cCampos+"%"
	// Parâmetro cCamposAux
	cCamposAux += " CAST((CASE WHEN TOT.TOT_QTDEST IS NULL THEN 0"
	cCamposAux +=            " ELSE TOT.TOT_QTDEST END) AS DECIMAL ("+cDecimal+")) TOT_QTDEST,
	cCamposAux += " CAST((CASE WHEN TOT.TOT_QTDD14 IS NULL THEN 0"
	cCamposAux +=            " ELSE TOT.TOT_QTDD14 END) AS DECIMAL ("+cDecimal+")) TOT_QTDD14
	cCamposAux := "%"+cCamposAux+"%"
	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT %Exp:cCampos%
		FROM (
				SELECT TOT.TOT_LOCAL,
						TOT.TOT_PRDORI,
						TOT.TOT_PRODUT,
						TOT.TOT_LOTECT,
						TOT.TOT_NUMLOT,
						%Exp:cCamposAux%
				FROM (
					SELECT SB2.B2_LOCAL TOT_LOCAL,
							SB2.B2_COD TOT_PRDORI,
							SB2.B2_COD TOT_PRODUT,
							'          ' TOT_LOTECT,
							'      ' TOT_NUMLOT,
							SB2.B2_QATU TOT_QTDEST,
							SUM(D14.D14_QTDEST) TOT_QTDD14
					FROM %Table:SB2% SB2
					INNER JOIN %Table:D14% D14 
					ON D14.D14_FILIAL = %xFilial:D14%
					AND D14.D14_LOCAL = SB2.B2_LOCAL
					AND D14.D14_PRDORI = SB2.B2_COD
					AND D14.%NotDel%
					WHERE SB2.B2_FILIAL = %xFilial:SB2%
					%Exp:cWhere%
					AND NOT EXISTS (
									SELECT 1
									FROM %Table:SB8% SB8
									WHERE SB8.B8_FILIAL = %xFilial:SB8%
									AND SB8.B8_LOCAL = SB2.B2_LOCAL
									AND SB8.B8_PRODUTO = SB2.B2_COD
									AND SB8.%NotDel%
									)
					AND SB2.%NotDel%
					GROUP BY SB2.B2_LOCAL,
								SB2.B2_COD,
								SB2.B2_QATU
					UNION ALL
					SELECT SB8.B8_LOCAL TOT_LOCAL,
							SB8.B8_PRODUTO TOT_PRDORI,
							SB8.B8_PRODUTO TOT_PRODUT,
							SB8.B8_LOTECTL TOT_LOTECT,
							SB8.B8_NUMLOTE TOT_NUMLOT,
							SB8.B8_SALDO TOT_QTDEST,
							SUM(D14.D14_QTDEST) TOT_QTDD14
					FROM %Table:SB8% SB8
					INNER JOIN %Table:SB2% SB2
					ON SB2.B2_FILIAL = %xFilial:SB8%
					AND SB2.B2_LOCAL = SB8.B8_LOCAL
					AND SB2.B2_COD = SB8.B8_PRODUTO
					%Exp:cWhere%
					AND SB2.%NotDel%
					INNER JOIN %Table:D14% D14
					ON D14.D14_FILIAL = %xFilial:D14%
					AND D14.D14_LOCAL = SB8.B8_LOCAL
					AND D14.D14_PRDORI = SB8.B8_PRODUTO
					AND D14.D14_LOTECT = SB8.B8_LOTECTL
					AND D14.D14_NUMLOT = SB8.B8_NUMLOTE
					AND D14.%NotDel%
					WHERE SB8.B8_FILIAL = %xFilial:SB8%
					AND SB8.%NotDel%
					GROUP BY SB8.B8_LOCAL,
								SB8.B8_PRODUTO,
								SB8.B8_LOTECTL,
								SB8.B8_NUMLOTE,
								SB8.B8_SALDO
					) TOT
			) TOT
		WHERE (TOT.TOT_QTDEST - TOT.TOT_QTDD14) <> 0
	EndSql
Return cAliasQry
//----------------------------------------
/*/{Protheus.doc} EquateEst
Ajusta os registro do estoque do produto com base na quantidade
do estoque por endereço WMS
@author Squad WMS Protheus
@since 31/01/2019
@version 1.0
@param cArmazem, Caracter, Armazém filtro da análise
@param cPrdOri, Caracter, Produto Origem filtro da análise
@param cProduto, Caracter, Produto filtro da análise
@param oProcess, Objeto para controlar progresso
/*/
//----------------------------------------
METHOD EquateEst(cArmazem,cProduto,oProcess) CLASS WMSDTCEstoqueEndereco
Local lRet        := .T.
Local lProcess    := oProcess <> Nil
Local lContinua   := .T.
Local cAliasQry   := Nil
Local cAliasQr1   := Nil
Local cDocumento  := "AJT_D14"
Local cEndereco   := "INVENTARIO"
Local cOrigem     := "SB2"
	// Verificar a quantidade de registros
	If lProcess
		cAliasQr1 := Self:SelectEst(.F.,cArmazem,cProduto)
		If (cAliasQr1)->(!Eof()) .And. (cAliasQr1)->NR_COUNT > 0
			oProcess:SetRegua1((cAliasQr1)->NR_COUNT)
			oProcess:SetRegua2(2)
		Else
			lContinua := .F.
		EndIf
		(cAliasQr1)->(dbCloseArea())
	EndIf
	If lContinua
		// Busca os registros para processamento
		cAliasQry := Self:SelectEst(.T.,cArmazem,cProduto)
		Do While lRet .And. (cAliasQry)->(!Eof())
			If lProcess
				oProcess:IncRegua1( WmsFmtMsg(STR0016 + "...",{{"[VAR01]",cValToChar(oProcess:nMeter1+1)},{"[VAR02]",cValToChar(oProcess:oMeter1:nTotal)}}) ) // Processando [VAR01]/[VAR02] registro(s)
				oProcess:IncRegua2(WmsFmtMsg(STR0017,{{"[VAR01]","(SB2|D14)"}})) // Atualizando [VAR01]
			EndIf
			// Carrega dados para Estoque por Endereço
			Self:ClearData()
			Self:oEndereco:SetArmazem((cAliasQry)->TOT_LOCAL)   // Armazem
			Self:oEndereco:SetEnder((cAliasQry)->TOT_ENDER)     // Endereço
			Self:oProdLote:SetArmazem((cAliasQry)->TOT_LOCAL)   // Armazem
			Self:oProdLote:SetPrdOri((cAliasQry)->TOT_PRDORI)   // Produto Origem
			Self:oProdLote:SetProduto((cAliasQry)->TOT_PRODUT)  // Produto/Componente
			Self:oProdLote:SetLoteCtl((cAliasQry)->TOT_LOTECT)  // Lote do produto
			Self:oProdLote:SetNumLote((cAliasQry)->TOT_NUMLOT)  // Sub-Lote do lote do produto
			Self:oProdLote:SetNumSer("")                        // Numero de serie
			Self:SetQuant((cAliasQry)->TOT_QTDDIF)
			// Seta o bloco de código para informações do documento
			Self:SetBlkDoc({|oMovEstEnd|;
				oMovEstEnd:SetOrigem(cOrigem),;                 // Origem do movimento
				oMovEstEnd:SetDocto(cDocumento);                // Documento
			})
			// Realiza Entrada Armazem Estoque por Endereço
			If !Self:UpdSaldo((cAliasQry)->TOT_TM, .T. /*lEstoque*/,.F. /*lEntPrev*/,.F. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/,.F./*lEmpPrev*/,.T./*lMovEstEnd*/)
				lRet := .F.
			EndIf
			// Próximo registro
			If lProcess
				oProcess:IncRegua2(WmsFmtMsg(STR0018,{{"[VAR01]","(SB2|D14)"}})) // Finalizando [VAR01]
			EndIf
			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(dbCloseArea())
	EndIf
Return lRet
//----------------------------------------
/*/{Protheus.doc} SelectAjt
Busca as informações de divergencia entre o estoque do produto
e o estoque por endereço WMS
@author Squad WMS Protheus
@since 31/01/2019
@version 1.0
@param lProcess, Lógico, Result a quantidade de registros quando .F. e os registros quando .T. 
@param cArmazem, Caracter, Armazém filtro da análise
@param cProduto, Caracter, Produto filtro da análise
/*/
//----------------------------------------
METHOD SelectAjt(lProcess,cArmazem) CLASS WMSDTCEstoqueEndereco
Local cAliasQry  := Nil
Local cEndereco  := 'INVENTARIO'

	cAliasQry := GetNextAlias()
	If lProcess
		BeginSql Alias cAliasQry
			SELECT D14.D14_LOCAL,
					D14.D14_ENDER,
					D14.D14_PRDORI,
					D14.D14_PRODUT,
					D14.D14_LOTECT,
					D14.D14_NUMLOT,
					D14.D14_DTVALD,
					SB1.B1_GRUPO,
					SB1.B1_UM,
					SB1.B1_SEGUM,
					SB1.B1_CONTA,
					SB1.B1_TIPO,
					D14.D14_QTDEST
			FROM %Table:D14% D14
			INNER JOIN %Table:SB1% SB1
			ON SB1.B1_FILIAL = %xFilial:SB1%
			AND SB1.B1_COD = D14.D14_PRDORI
			AND SB1.%NotDel%
			WHERE D14.D14_FILIAL = %xFilial:D14%
			AND D14.D14_LOCAL = %Exp:cArmazem%
			AND D14.D14_ENDER = %Exp:cEndereco%
			AND D14.%NotDel%
		EndSql
	Else
		BeginSql Alias cAliasQry
			SELECT COUNT(*) NR_COUNT
			FROM %Table:D14% D14
			INNER JOIN %Table:SB1% SB1
			ON SB1.B1_FILIAL = %xFilial:SB1%
			AND SB1.B1_COD = D14.D14_PRDORI
			AND SB1.%NotDel%
			WHERE D14.D14_FILIAL = %xFilial:D14%
			AND D14.D14_LOCAL = %Exp:cArmazem%
			AND D14.D14_ENDER = %Exp:cEndereco%
			AND D14.%NotDel%
		EndSql
	EndIf
	If lProcess
		TcSetField(cAliasQry,'D14_QTDEST','N',Self:aD14_QTDEST[1],Self:aD14_QTDEST[2])
		TcSetField(cAliasQry,'D14_DTVALD','D')
	EndIf
Return cAliasQry
//----------------------------------------
/*/{Protheus.doc} AjusEstPrd
Ajusta os registro do estoque do produto com base na quantidade
do estoque por endereço WMS
@author Squad WMS Protheus
@since 31/01/2019
@version 1.0
@param cArmazem, Caracter, Armazém filtro da análise
@param oProcess, Objeto para controlar progresso
/*/
//----------------------------------------
METHOD AjusEstPrd(cArmazem,oProcess) CLASS WMSDTCEstoqueEndereco
Local lRet       := .T.
Local lProcess   := oProcess <> Nil
Local lContinua  := .T.
Local aAreaAnt   := GetArea()
Local aCM		 := {}
Local aCusto	 := {}
Local cAliasQry  := Nil
Local cAliasQr1  := Nil
Local cApropri   := "0"
Local cDocumento := "AJT_SB2"
Local cEndereco  := "INVENTARIO"
Local cOrigem    := "D14"
Local cNumseq    := ""
Local cTM        := ""
Local cCF        := ""
Local cChave     := ""
Local nQtdMov    := 0
Local nQtdMovSeg := 0
	// Verificar a quantidade de registros
	If lProcess
		cAliasQr1 := Self:SelectAjt(.F.,cArmazem)
		If (cAliasQr1)->(!Eof()) .And. (cAliasQr1)->NR_COUNT > 0
			oProcess:SetRegua1((cAliasQr1)->NR_COUNT)
			oProcess:SetRegua2(2)
		Else
			lContinua := .F.
		EndIf
		(cAliasQr1)->(dbCloseArea())
	EndIf
	If lContinua
		// Busca os registros para processamento
		cAliasQry := Self:SelectAjt(.T.,cArmazem)
		Do While (cAliasQry)->(!Eof())
			If lProcess
				oProcess:IncRegua1( WmsFmtMsg(STR0016 + "...",{{"[VAR01]",cValToChar(oProcess:nMeter1+1)},{"[VAR02]",cValToChar(oProcess:oMeter1:nTotal)}}) ) // Processando [VAR01]/[VAR02] registro(s)
				oProcess:IncRegua2(WmsFmtMsg(STR0017,{{"[VAR01]","(SB2|D14|D13)"}})) // Atualizando [VAR01]
			EndIf
			cTM := IIf((cAliasQry)->D14_QTDEST > 0, '999','499')
			nQtdMov    := Abs((cAliasQry)->D14_QTDEST)
			nQtdMovSeg := ConvUm((cAliasQry)->D14_PRDORI,nQtdMov,0,2)
			// Pega o numero sequencial do movimento
			cNumseq := ProxNum()
			cCF     := IIf(cTm == '999',"RE"+cApropri,"DE"+cApropri)
			cChave  := SubStr(cCF,2,1)+IIf(cCF=="DE4","9","0")
			// Grava movimento interno
			dbSelectArea("SD3")
			RecLock("SD3",.T.)
			SD3->D3_FILIAL   := xFilial("SD3")
			SD3->D3_COD      := (cAliasQry)->D14_PRDORI
			SD3->D3_DOC      := cDocumento
			SD3->D3_EMISSAO  := dDataBase
			SD3->D3_GRUPO    := (cAliasQry)->B1_GRUPO
			SD3->D3_LOCAL    := (cAliasQry)->D14_LOCAL
			SD3->D3_UM       := (cAliasQry)->B1_UM
			SD3->D3_NUMSEQ   := cNumseq
			SD3->D3_SEGUM    := (cAliasQry)->B1_SEGUM
			SD3->D3_CONTA    := (cAliasQry)->B1_CONTA
			SD3->D3_QUANT    := nQtdMov
			SD3->D3_QTSEGUM  := nQtdMovSeg
			SD3->D3_TIPO     := (cAliasQry)->B1_TIPO
			SD3->D3_LOCALIZ  := (cAliasQry)->D14_ENDER
			SD3->D3_LOTECTL  := (cAliasQry)->D14_LOTECT
			SD3->D3_NUMLOTE  := (cAliasQry)->D14_NUMLOT
			SD3->D3_USUARIO  := CUSERNAME
			SD3->D3_DTVALID  := (cAliasQry)->D14_DTVALD
			SD3->D3_TM       := cTM
			SD3->D3_CF       := cCF 
			SD3->D3_CHAVE    := cChave
			// Pega os custos medios atuais
			aCM := PegaCMAtu(SD3->D3_COD,SD3->D3_LOCAL)
			// Grava o custo da movimentacao
			aCusto := GravaCusD3(aCM)
			// Atualiza o saldo atual do estoque com os dados do SD3
			// e caso retorne .T. grava o registro para log de saldo
			// negativo.
			B2AtuComD3(aCusto,,.F.,,,,,,,,,,,,,,,,,,,,,.F.)
			// AtualizaSaldo
			// Produto
			If lRet
				Self:ClearData()
				Self:oProdLote:SetArmazem((cAliasQry)->D14_LOCAL)
				Self:oProdLote:SetProduto((cAliasQry)->D14_PRODUT)
				Self:oProdLote:SetPrdOri((cAliasQry)->D14_PRDORI)
				Self:oProdLote:SetLoteCtl((cAliasQry)->D14_LOTECT)
				Self:oProdLote:SetNumLote((cAliasQry)->D14_NUMLOT)
				Self:oProdLote:SetNumSer("")
				// Endereço Destino
				Self:oEndereco:SetArmazem((cAliasQry)->D14_LOCAL)
				Self:oEndereco:SetEnder((cAliasQry)->D14_ENDER)
				// Dados Gerais
				Self:SetQuant(nQtdMov)
				// Seta o bloco de código para informações do documento para o Kardex
				Self:SetBlkDoc({|oMovEstEnd|;
								oMovEstEnd:SetOrigem("D14"),;
								oMovEstEnd:SetDocto(cDocumento)})
				// Realiza Saída Armazem Estoque por Endereço
				If !Self:UpdSaldo(cTm,.T./*lEstoque*/,.F. /*lEntPrev*/,.F. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/,/*lEmpPrev*/,.T./*lMovEstEnd*/)
					lRet := .F.
				EndIf
			EndIf
			// Próximo registro
			If lProcess
				oProcess:IncRegua2(WmsFmtMsg(STR0018,{{"[VAR01]","(SB2|D14|D13)"}})) // Finalizando [VAR01]
			EndIf
			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(dbCloseArea())
	EndIf
	RestArea(aAreaAnt)
Return lRet
//----------------------------------------
/*/{Protheus.doc} SelectPrev
Busca as informações de quantidades previstas
@author Squad WMS Protheus
@since 31/01/2019
@version 1.0
@param lProcess, Lógico, Result a quantidade de registros quando .F. e os registros quando .T. 
@param cArmazem, Caracter, Armazém filtro da análise
@param cProduto, Caracter, Produto filtro da análise
/*/
//----------------------------------------
METHOD SelectPrev(lProcess,cArmazem,cProduto) CLASS WMSDTCEstoqueEndereco
Local cWhere     := ""
Local cCampos    := ""
Local cCamposAux := ""
Local cAliasQry  := Nil
Local cDecimal   := cValtoChar(Self:aD14_QTDEST[1])+","+cValtoChar(Self:aD14_QTDEST[2])
	// Parâmetro cWhere
	If !Empty(cArmazem)
		cWhere += " AND SB2.B2_LOCAL = '"+cArmazem+"'"
	EndIf
	If !Empty(cProduto)
		cWhere += " AND SB2.B2_COD = '"+cProduto+"'"
	EndIf
	cWhere := "%"+cWhere+"%"
	// Parâmetro cCAmpos
	If lProcess
		cCampos += " TOT.TOT_LOCAL,"
		cCampos += " TOT.TOT_ENDER,"
		cCampos += " TOT.TOT_PRDORI,"
		cCampos += " TOT.TOT_PRODUT,"
		cCampos += " TOT.TOT_LOTECT,"
		cCampos += " TOT.TOT_NUMLOT,"
		cCampos += " TOT.TOT_NUMSER,"
		cCampos += " TOT.TOT_IDUNIT,"
		cCampos += " TOT.TOT_QTDEST,"
		cCampos += " TOT.TOT_QTDEPR,"
		cCampos += " TOT.TOT_QTDSPR,"
		cCampos += " TOT.TOT_QTDPEM,"
		cCampos += " TOT.TOT_QTDBLQ,"
		cCampos += " TOT.TOT_MOVEPR,"
		cCampos += " TOT.TOT_MOVSPR,"
		cCampos += " TOT.TOT_MOVPEM,"
		cCampos += " TOT.TOT_MOVBLQ"
	Else
		cCampos += " COUNT(*) NR_COUNT"
	EndIf
	cCampos := "%"+cCampos+"%"
	// Parâmetro cCamposAux
	cCamposAux += " CAST(SUM(SLD.TOT_QTDEST) AS DECIMAL ("+cDecimal+")) TOT_QTDEST,"
	cCamposAux += " CAST(SUM(SLD.TOT_QTDEPR) AS DECIMAL ("+cDecimal+")) TOT_QTDEPR,"
	cCamposAux += " CAST(SUM(SLD.TOT_QTDSPR) AS DECIMAL ("+cDecimal+")) TOT_QTDSPR,"
	cCamposAux += " CAST(SUM(SLD.TOT_QTDPEM) AS DECIMAL ("+cDecimal+")) TOT_QTDPEM,"
	cCamposAux += " CAST(SUM(SLD.TOT_QTDBLQ) AS DECIMAL ("+cDecimal+")) TOT_QTDBLQ,"
	cCamposAux += " CAST(SUM(SLD.TOT_MOVEPR) AS DECIMAL ("+cDecimal+")) TOT_MOVEPR,"
	cCamposAux += " CAST(SUM(SLD.TOT_MOVSPR) AS DECIMAL ("+cDecimal+")) TOT_MOVSPR,"
	cCamposAux += " CAST(SUM(SLD.TOT_MOVPEM) AS DECIMAL ("+cDecimal+")) TOT_MOVPEM,"
	cCamposAux += " CAST(SUM(SLD.TOT_MOVBLQ) AS DECIMAL ("+cDecimal+")) TOT_MOVBLQ"
	cCamposAux := "%"+cCamposAux+"%"
	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT %Exp:cCampos%
		FROM (
				SELECT SLD.TOT_LOCAL TOT_LOCAL,
						SLD.TOT_ENDER TOT_ENDER,
						SLD.TOT_PRDORI TOT_PRDORI,
						SLD.TOT_PRODUT TOT_PRODUT,
						SLD.TOT_LOTECT TOT_LOTECT,
						SLD.TOT_NUMLOT TOT_NUMLOT,
						SLD.TOT_NUMSER TOT_NUMSER,
						SLD.TOT_IDUNIT TOT_IDUNIT,
						%Exp:cCamposAux%
				FROM (
						// Ordens de serviço pendentes reservas do endereço origem
						// Documentos de entrada
						// Movimentos internos de devolução
						// Transferência sem endereço destino informado
						SELECT DCF.DCF_LOCAL TOT_LOCAL,
								DCF.DCF_ENDER TOT_ENDER,
								DCF.DCF_PRDORI TOT_PRDORI,
								CASE WHEN D11.D11_PRDCMP IS NULL THEN DCF.DCF_CODPRO ELSE D11.D11_PRDCMP END TOT_PRODUT,
								DCF.DCF_LOTECT TOT_LOTECT,
								DCF.DCF_NUMLOT TOT_NUMLOT,
								'  ' TOT_NUMSER,
								DCF.DCF_UNITIZ TOT_IDUNIT,
								0 TOT_QTDEST,
								0 TOT_QTDEPR,
								0 TOT_QTDSPR,
								0 TOT_QTDPEM,
								0 TOT_QTDBLQ,
								0 TOT_MOVEPR,
								CASE WHEN D11.D11_QTMULT IS NULL THEN DCF.DCF_QUANT ELSE DCF.DCF_QUANT * D11.D11_QTMULT END TOT_MOVSPR,
								0 TOT_MOVPEM,
								0 TOT_MOVBLQ
						FROM %Table:DCF% DCF
						LEFT JOIN %Table:D11% D11
						ON D11.D11_FILIAL = %xFilial:D11%
						AND D11.D11_PRODUT = DCF.DCF_CODPRO
						AND D11.D11_PRDORI = DCF.DCF_PRDORI
						AND D11.D11_PRODUT = D11.D11_PRDORI
						AND D11.%NotDel%
						WHERE DCF.DCF_FILIAL = %xFilial:DCF%
						AND DCF.DCF_STSERV NOT IN ('0','3')
						AND DCF.DCF_ENDER <> '  '
						AND DCF.DCF_ENDDES = '  '
						AND DCF.DCF_CODPRO = DCF.DCF_PRDORI
						AND DCF.%NotDel%
						UNION ALL
						// Ordens de serviço pendentes do endereço origem
						// Pedido de venda com o endereço informado e quando houver controle de lote/sublote também estiverem informados
						// Movimento interno de requisição com o endereço origem/destino informado e quando houver controle de lote/sublote também estiverem informados
						SELECT DCF.DCF_LOCAL TOT_LOCAL,
								DCF.DCF_ENDER TOT_ENDER,
								DCF.DCF_PRDORI TOT_PRDORI,
								CASE WHEN D11.D11_PRDCMP IS NULL THEN DCF.DCF_CODPRO ELSE D11.D11_PRDCMP END TOT_PRODUT,
								DCF.DCF_LOTECT TOT_LOTECT,
								DCF.DCF_NUMLOT TOT_NUMLOT,
								'  ' TOT_NUMSER,
								DCF.DCF_UNITIZ TOT_IDUNIT,
								0 TOT_QTDEST,
								0 TOT_QTDEPR,
								0 TOT_QTDSPR,
								0 TOT_QTDPEM,
								0 TOT_QTDBLQ,
								0 TOT_MOVEPR,
								CASE WHEN D11.D11_QTMULT IS NULL THEN DCF.DCF_QUANT ELSE DCF.DCF_QUANT * D11.D11_QTMULT END TOT_MOVSPR,
								CASE WHEN DCF.DCF_ORIGEM IN ('SC9','SD4') 
										THEN (CASE WHEN D11.D11_QTMULT IS NULL THEN DCF.DCF_QUANT 
										ELSE DCF.DCF_QUANT * D11.D11_QTMULT END) ELSE 0 END TOT_MOVPEM,
								0 TOT_MOVBLQ
						FROM %Table:DCF% DCF
						LEFT JOIN %Table:D11% D11
						ON D11.D11_FILIAL = %xFilial:D11%
						AND D11.D11_PRODUT = DCF.DCF_CODPRO
						AND D11.D11_PRDORI = DCF.DCF_PRDORI
						AND D11.D11_PRODUT = D11.D11_PRDORI
						AND D11.%NotDel%
						WHERE DCF.DCF_FILIAL = %xFilial:DCF%
						AND DCF.DCF_STSERV NOT IN ('0','3')
						AND DCF.DCF_ENDER <> '  '
						AND DCF.DCF_ENDDES <> '  '
						AND DCF.%NotDel%
						UNION ALL
						// Ordens de serviço pendentes do endereço destino informado
						// Pedido de venda com o endereço informado e quando houver controle de lote/sublote também estiverem informados
						// Movimento interno de requisição com o endereço origem/destino informado e quando houver controle de lote/sublote também estiverem informados
						// Transferência com endereço 
						SELECT DCF.DCF_LOCDES TOT_LOCAL,
								DCF.DCF_ENDDES TOT_ENDER,
								DCF.DCF_PRDORI TOT_PRDORI,
								CASE WHEN D11.D11_PRDCMP IS NULL THEN DCF.DCF_CODPRO ELSE D11.D11_PRDCMP END TOT_PRODUT,
								DCF.DCF_LOTECT TOT_LOTECT,
								DCF.DCF_NUMLOT TOT_NUMLOT,
								'  ' TOT_NUMSER,
								DCF.DCF_UNIDES TOT_IDUNIT,
								0 TOT_QTDEST,
								0 TOT_QTDEPR,
								0 TOT_QTDSPR,
								0 TOT_QTDPEM,
								0 TOT_QTDBLQ,
								CASE WHEN D11.D11_QTMULT IS NULL THEN DCF.DCF_QUANT ELSE DCF.DCF_QUANT * D11.D11_QTMULT END TOT_MOVEPR,
								0 TOT_MOVSPR,
								0 TOT_MOVPEM,
								0 TOT_MOVBLQ
						FROM %Table:DCF% DCF
						LEFT JOIN %Table:D11% D11
						ON D11.D11_FILIAL = %xFilial:D11%
						AND D11.D11_PRODUT = DCF.DCF_CODPRO
						AND D11.D11_PRDORI = DCF.DCF_PRDORI
						AND D11.D11_PRODUT = D11.D11_PRDORI
						AND D11.%NotDel%
						WHERE DCF.DCF_FILIAL = %xFilial:DCF%
						AND DCF.DCF_STSERV NOT IN ('0','3')
						AND DCF.DCF_ENDER <> '  '
						AND DCF.DCF_ENDDES <> '  '
						AND DCF.%NotDel%
						UNION ALL
						// Movimentos pendentes endereço destino
						SELECT D12.D12_LOCDES TOT_LOCAL,
								D12.D12_ENDDES TOT_ENDER,
								D12.D12_PRDORI TOT_PRDORI,
								D12.D12_PRODUT TOT_PRODUT,
								D12.D12_LOTECT TOT_LOTECT,
								D12.D12_NUMLOT TOT_NUMLOT,
								D12.D12_NUMSER TOT_NUMSER,
								D12.D12_UNIDES TOT_IDUNIT,
								0 TOT_QTDEST,
								0 TOT_QTDEPR,
								0 TOT_QTDSPR,
								0 TOT_QTDPEM,
								0 TOT_QTDBLQ,
								SUM(D12.D12_QTDMOV) TOT_MOVEPR,
								0 TOT_MOVSPR,
								0 TOT_MOVPEM,
								0 TOT_MOVBLQ
						FROM %Table:D12% D12
						WHERE D12.D12_FILIAL = %xFilial:D12%
						AND D12.D12_STATUS NOT IN ('0','1')
						AND D12.D12_ATUEST = '1'
						AND D12.%NotDel%
						GROUP BY D12.D12_LOCDES,
									D12.D12_ENDDES,
									D12.D12_PRDORI,
									D12.D12_PRODUT,
									D12.D12_LOTECT,
									D12.D12_NUMLOT,
									D12.D12_NUMSER,
									D12.D12_UNIDES
						UNION ALL
						// Movimentos pendentes endereço origem
						SELECT D12.D12_LOCORI TOT_LOCAL,
								D12.D12_ENDORI TOT_ENDER,
								D12.D12_PRDORI TOT_PRDORI,
								D12.D12_PRODUT TOT_PRODUT,
								D12.D12_LOTECT TOT_LOTECT,
								D12.D12_NUMLOT TOT_NUMLOT,
								D12.D12_NUMSER TOT_NUMSER,
								D12.D12_IDUNIT TOT_IDUNIT,
								0 TOT_QTDEST,
								0 TOT_QTDEPR,
								0 TOT_QTDSPR,
								0 TOT_QTDPEM,
								0 TOT_QTDBLQ,
								0 TOT_MOVEPR,
								SUM(D12.D12_QTDMOV) TOT_MOVSPR,
								0 TOT_MOVPEM,
								0 TOT_MOVBLQ
						FROM %Table:D12% D12
						WHERE D12.D12_FILIAL = %xFilial:D12%
						AND D12.D12_STATUS NOT IN ('0','1')
						AND D12.D12_ATUEST = '1'
						AND D12.%NotDel%
						GROUP BY D12.D12_LOCORI,
									D12.D12_ENDORI,
									D12.D12_PRDORI,
									D12.D12_PRODUT,
									D12.D12_LOTECT,
									D12.D12_NUMLOT,
									D12.D12_NUMSER,
									D12.D12_IDUNIT
						UNION ALL
						SELECT D14.D14_LOCAL TOT_LOCAL,
								D14.D14_ENDER TOT_ENDER,
								D14.D14_PRDORI TOT_PRDORI,
								D14.D14_PRODUT TOT_PRODUT,
								D14.D14_LOTECT TOT_LOTECT,
								D14.D14_NUMLOT TOT_NUMLOT,
								D14.D14_NUMSER TOT_NUMSER,
								D14.D14_IDUNIT TOT_IDUNIT,
								D14.D14_QTDEST TOT_QTDEST,
								D14.D14_QTDEPR TOT_QTDEPR,
								D14.D14_QTDSPR TOT_QTDSPR,
								D14.D14_QTDPEM TOT_QTDPEM,
								D14.D14_QTDBLQ TOT_QTDBLQ,
								0 TOT_MOVEPR,
								0 TOT_MOVSPR,
								0 TOT_MOVPEM,
								0 TOT_MOVBLQ
						FROM %Table:D14% D14
						WHERE D14.D14_FILIAL = %xFilial:D14%
						AND D14.%NotDel%
						UNION ALL
						SELECT D0V.D0V_LOCAL TOT_LOCAL,
								D0V.D0V_ENDER TOT_ENDER,
								D0V.D0V_PRDORI TOT_PRDORI,
								D0V.D0V_PRODUT TOT_PRODUT,
								D0V.D0V_LOTECT TOT_LOTECT,
								D0V.D0V_NUMLOT TOT_NUMLOT,
								'  ' TOT_NUMSER,
								D0V.D0V_IDUNIT TOT_IDUNIT,
								0 TOT_QTDEST,
								0 TOT_QTDEPR,
								0 TOT_QTDSPR,
								0 TOT_QTDPEM,
								0 TOT_QTDBLQ,
								0 TOT_MOVEPR,
								0 TOT_MOVSPR,
								0 TOT_MOVPEM,
								D0V.D0V_QTDBLQ
						FROM %Table:D0V% D0V
						WHERE D0V.D0V_FILIAL = %xFilial:D0V%
						AND D0V.%NotDel%
					) SLD
				GROUP BY SLD.TOT_LOCAL,
							SLD.TOT_ENDER,
							SLD.TOT_PRDORI,
							SLD.TOT_PRODUT,
							SLD.TOT_LOTECT,
							SLD.TOT_NUMLOT,
							SLD.TOT_NUMSER,
							SLD.TOT_IDUNIT
			) TOT
		WHERE TOT.TOT_LOCAL = '01'
		AND (TOT.TOT_QTDEPR + TOT.TOT_QTDSPR + TOT.TOT_QTDPEM + TOT.TOT_QTDBLQ) <> (TOT.TOT_MOVEPR + TOT.TOT_MOVSPR + TOT.TOT_MOVPEM + TOT.TOT_MOVBLQ)	
	EndSql
	If lProcess
		TcSetField(cAliasQry,'TOT_QTDEST','N',Self:aD14_QTDEST[1],Self:aD14_QTDEST[2])
		TcSetField(cAliasQry,'TOT_QTDEPR','N',Self:aD14_QTDEST[1],Self:aD14_QTDEST[2])
		TcSetField(cAliasQry,'TOT_QTDSPR','N',Self:aD14_QTDEST[1],Self:aD14_QTDEST[2])
		TcSetField(cAliasQry,'TOT_QTDPEM','N',Self:aD14_QTDEST[1],Self:aD14_QTDEST[2])
		TcSetField(cAliasQry,'TOT_QTDBLQ','N',Self:aD14_QTDEST[1],Self:aD14_QTDEST[2])
		TcSetField(cAliasQry,'TOT_MOVEPR','N',Self:aD14_QTDEST[1],Self:aD14_QTDEST[2])
		TcSetField(cAliasQry,'TOT_MOVSPR','N',Self:aD14_QTDEST[1],Self:aD14_QTDEST[2])
		TcSetField(cAliasQry,'TOT_MOVPEM','N',Self:aD14_QTDEST[1],Self:aD14_QTDEST[2])
		TcSetField(cAliasQry,'TOT_MOVBLQ','N',Self:aD14_QTDEST[1],Self:aD14_QTDEST[2])
	EndIf
Return cAliasQry
//----------------------------------------
/*/{Protheus.doc} EquatePrev
Ajusta os registro de quantidade prevista no estoque por endereço WMS
QTDEPR - Entrada prevista
QTDSPR - Saída prevista
QTDPEM - Empenho previsto
QTDBLQ - Quantidade bloqueada

@author Squad WMS Protheus
@since 31/01/2019
@version 1.0
@param cArmazem, Caracter, Armazém filtro da análise
@param cProduto, Caracter, Produto filtro da análise
@param oProcess, Objeto para controlar progresso
/*/
//----------------------------------------
METHOD EquatePrev(cArmazem,cProduto,oProcess,aErro) CLASS WMSDTCEstoqueEndereco
Local lRet       := .T.
Local lProcess   := oProcess <> Nil
Local lContinua  := .T.
Local lAchou     := .F.
Local aAreaAnt   := GetArea()
Local cAliasQry  := Nil
Local cAliasQr1  := Nil
Local nMovEPR    := 0
Local nMovEP2    := 0
Local nMovSPR    := 0
Local nMovSP2    := 0
Local nMovBLQ    := 0
Local nMovBL2    := 0
Local nMovPEM    := 0
Local nMovPE2    := 0

	// Verificar a quantidade de registros
	If lProcess
		cAliasQr1 := Self:SelectPrev(.F.,cArmazem,cProduto)
		If (cAliasQr1)->(!Eof()) .And. (cAliasQr1)->NR_COUNT > 0
			oProcess:SetRegua1((cAliasQr1)->NR_COUNT)
			oProcess:SetRegua2(2)
		Else
			lContinua := .F.
		EndIf
		(cAliasQr1)->(dbCloseArea())
	EndIf
	If lContinua
		// Busca os registros para processamento
		cAliasQry := Self:SelectPrev(.T.,cArmazem,cProduto)
		Do While (cAliasQry)->(!Eof())
			If lProcess
				oProcess:IncRegua1( WmsFmtMsg(STR0016 + "...",{{"[VAR01]",cValToChar(oProcess:nMeter1+1)},{"[VAR02]",cValToChar(oProcess:oMeter1:nTotal)}}) ) // Processando [VAR01]/[VAR02] registro(s)
				oProcess:IncRegua2(STR0019) // Atualizando quantidades previstas
			EndIf
			// Carrega dados para Estoque por Endereço
			lAnalisEnd := .F.
			
			Self:ClearData()
			Self:oEndereco:SetArmazem((cAliasQry)->TOT_LOCAL)   // Armazem
			Self:oEndereco:SetEnder((cAliasQry)->TOT_ENDER)     // Endereço
			Self:oProdLote:SetArmazem((cAliasQry)->TOT_LOCAL)   // Armazem
			Self:oProdLote:SetPrdOri((cAliasQry)->TOT_PRDORI)   // Produto Origem
			Self:oProdLote:SetProduto((cAliasQry)->TOT_PRODUT)  // Produto/Componente
			Self:oProdLote:SetLoteCtl((cAliasQry)->TOT_LOTECT)  // Lote do produto
			Self:oProdLote:SetNumLote((cAliasQry)->TOT_NUMLOT)  // Sub-Lote do lote do produto
			Self:oProdLote:SetNumSer("")                        // Numero de serie
			Self:cIdUnitiz  := (cAliasQry)->TOT_IDUNIT          // Identificador do unitizador
			If Self:lHasCodUni
				cAliasQr1 := GetNextAlias()
				BeginSql Alias cAliasQr1
					SELECT D0Y.D0Y_TIPUNI
					FROM %Table:D0Y% D0Y
					WHERE D0Y.D0Y_FILIAL = %xFilial:D0Y%
					AND D0Y.D0Y_IDUNIT = %Exp:Self:cIdUnitiz%
					AND D0Y.%NotDel%
				EndSql
				If (cAliasQr1)->(!Eof())
					Self:cTipUni := (cAliasQr1)->D0Y_TIPUNI
				EndIf
				(cAliasQr1)->(dbCloseArea())
			EndIf
			// Carrega informações
			Self:oProdLote:LoadData()
			Self:oEndereco:LoadData()
			// ajusta quantidades
			nQtdEst    := (cAliasQry)->TOT_QTDEST
			nMovEPR    := (cAliasQry)->TOT_MOVEPR
			nMovEP2    := ConvUm(Self:oProdLote:GetProduto(),nMovEPR,0,2)
			nMovSPR    := (cAliasQry)->TOT_MOVSPR
			nMovSP2    := ConvUm(Self:oProdLote:GetProduto(),nMovSPR,0,2)
			nMovBLQ    := (cAliasQry)->TOT_MOVBLQ
			nQtdBL2    := ConvUm(Self:oProdLote:GetProduto(),nMovBLQ,0,2)
			nMovPEM    := (cAliasQry)->TOT_MOVPEM
			nQtdPE2    := ConvUm(Self:oProdLote:GetProduto(),nMovPEM,0,2)
			
			If ((nMovSPR - nMovPEM) + nMovPEM + nMovBLQ) > nQtdEst
				cMessage := WmsFmtMsg(STR0020,{{"[VAR01]",AllTrim((cAliasQry)->TOT_LOCAL)}})+" " // Armazém : [VAR01]
				cMessage += WmsFmtMsg(STR0021,{{"[VAR01]",AllTrim((cAliasQry)->TOT_ENDER)}})+" " // Endereço: [VAR01]
				If Self:oProdLote:HasRastro()
					cMessage += WmsFmtMsg(STR0022,{{"[VAR01]",AllTrim((cAliasQry)->TOT_LOTECT)}})+" " // Lote: [VAR01]
					If Self:oProdLote:HasRastSub()
						cMessage += WmsFmtMsg(STR0023,{{"[VAR01]",AllTrim((cAliasQry)->TOT_NUMLOT)}})+" " // Sub-lote: [VAR01]
					EndIf
				EndIf
				If !Empty((cAliasQry)->TOT_IDUNIT)
					cMessage += WmsFmtMsg(STR0024,{{"[VAR01]",AllTrim((cAliasQry)->TOT_IDUNIT)}}) // Unitizador: [VAR01]
				EndIf
				AAdd(aErro,"---------------------------------------------------------------------------")
				AAdd(aErro,cMessage)
				AAdd(aErro,WmsFmtMsg(STR0025,{{"[VAR01]",AllTrim((cAliasQry)->TOT_PRODUT)}})) // Produto [VAR01] possui reservas previstas que comprometem o saldo.
			EndIf
			cAliasQr1 := GetNextAlias()
			BeginSql Alias cAliasQr1
				SELECT D14.R_E_C_N_O_ RECNOD14
				FROM %Table:D14% D14
				WHERE D14.D14_FILIAL = %xFilial:D14%
				AND D14.D14_LOCAL = %Exp:Self:oEndereco:GetArmazem()%
				AND D14.D14_ENDER = %Exp:Self:oEndereco:GetEnder()%
				AND D14.D14_PRDORI = %Exp:Self:oProdLote:GetPrdOri()%
				AND D14.D14_PRODUT = %Exp:Self:oProdLote:GetProduto()%
				AND D14.D14_LOTECT = %Exp:Self:oProdLote:GetLoteCtl()%
				AND D14.D14_NUMLOT = %Exp:Self:oProdLote:GetNumLote()%
				AND D14.D14_NUMSER = %Exp:Self:oProdLote:GetNumSer()%
				AND D14.D14_IDUNIT = %Exp:Self:cIdUnitiz%
				AND D14.%NotDel%
			EndSql
			If lAchou := (cAliasQr1)->(!Eof())
				D14->(dbGoTo((cAliasQr1)->RECNOD14))
			EndIf
			(cAliasQr1)->(dbCloseArea())
			RecLock('D14',!lAchou)
			If !lAchou
				D14->D14_FILIAL := xFilial("D14")
				D14->D14_LOCAL  := Self:oEndereco:GetArmazem()
				D14->D14_ENDER  := Self:oEndereco:GetEnder()
				D14->D14_PRDORI := Self:oProdLote:GetPrdOri()
				D14->D14_PRODUT := Self:oProdLote:GetProduto()
				D14->D14_LOTECT := Self:oProdLote:GetLoteCtl()
				D14->D14_NUMLOT := Self:oProdLote:GetNumLote()
				D14->D14_NUMSER := Self:oProdLote:GetNumSer()
				D14->D14_IDUNIT := Self:cIdUnitiz
				If Self:lHasCodUni
					D14->D14_CODUNI := Self:cTipUni
				EndIf
				D14->D14_ESTFIS := Self:oEndereco:GetEstFis()
				D14->D14_PRIOR  := Self:oEndereco:GetPrior()
				D14->D14_QTDEST := 0
				D14->D14_QTDES2 := 0
				lAnalisEnd := .T.
			EndIf
			If !Empty(Self:oProdLote:GetLoteCtl()) .And. Empty(D14->D14_DTVALD)
				D14->D14_DTVALD  := Self:oProdLote:GetDtValid()
				D14->D14_DTFABR  := Self:oProdLote:GetDtFabr()
			EndIf
			D14->D14_QTDEPR := nMovEPR
			D14->D14_QTDEP2 := nMovEP2
			D14->D14_QTDSPR := nMovSPR
			D14->D14_QTDSP2 := nMovSP2
			D14->D14_QTDBLQ := nMovBLQ
			D14->D14_QTDBL2 := nMovBL2
			D14->D14_QTDPEM := nMovPEM
			D14->D14_QTDPE2 := nMovPE2
			// Verifica se quantidade foram zeradas.
			If QtdComp(D14->D14_QTDEST) == 0 .AND. QtdComp(D14->D14_QTDEPR) == 0 .AND. QtdComp(D14->D14_QTDSPR) == 0 .AND. QtdComp(D14->D14_QTDEMP) == 0 .AND. QtdComp(D14->D14_QTDBLQ) == 0 .AND. QtdComp(D14->D14_QTDPEM) == 0
				D14->(dbDelete())
				lAnalisEnd := .T.
			EndIf
			D14->(MsUnLock())
			If lAnalisEnd
				Self:UpdEnder()
			EndIf
			// Próximo registro
			If lProcess
				oProcess:IncRegua2(STR0025) // Finalizando ajustes das quantidades previstas
			EndIf
			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(dbCloseArea())
	EndIf
	RestArea(aAreaAnt)
Return lRet
//----------------------------------------
/*/{Protheus.doc} AtuDesSD3
Gera SD3 apuração de custo
@author Squad WMS
@since 27/10/2017
@version 1.0
@param aArrSD3[1] - Tipo	movimentação
		aArrSD3[2] - Documento
		aArrSD3[3] - Produto
		aArrSD3[4] - Lote
		aArrSD3[5] - Sub-Lote
		aArrSD3[6] - Quantidade
		aArrSD3[7] - %	de	rateio do custo
		aArrSD3[8] - Local
		aArrSD3[9] - Endereço
		aArrSD3[10] - Identificador DCF
		aArrSD3[11] - Cf
		aArrSD3[12] - Chave
		aArrSD3[13] - Servico
		aArrSD3[14] - Status Servico
/*/
//----------------------------------------
METHOD AtuDesSD3(aArrSD3,nOperac) CLASS WMSDTCEstoqueEndereco
Local lLocS3     := FindFunction("LocalizS3")
Local lContinua  := .T.
Local lMontagem  := (nOperac == "1")
Local aAreaAnt   := GetArea() 
Local aLockSB2   := {}
Local aCtbDia    := {}
Local aSvCus     := {}
Local aSoma      := {}
Local cCusMed    := GetMv("MV_CUSMED")
Local cLoteEst   := ""
Local cArquivo   := ""
Local cTm        := ""
Local cDocumento := ""
Local cProduto   := ""
Local cLoteCtl   := ""
Local cNumLote   := ""
Local cLocal     := ""
Local cEndereco  := ""
Local cIdDCF     := ""
Local nTamDec    := TamSx3("D3_CUSTO1")[2]
Local nHdlPrv    := 0
Local nI         := 0
Local nX         := 0
Local nTotal     := 0
Local nQuant     := 0
Local nRateio    := ""
Local nPotenci   := 0
Local cAliasSB2  := Nil
Local cAliasSB1  := Nil
Local cAliasSB8  := Nil
Local dDtValid   := Nil
Local dDFabric   := Nil
Local cLoteFor   := ""

Private cNumSeq	:=	""

	cLoteEst := AllTrim(FWGetSX5("09",'EST')[1,4])
	If Empty(cLoteEst)
		cLoteEst := "EST"
	EndIf
	cTm        := aArrSD3[1][1]  // Tipo movimentação
	cDocumento := aArrSD3[1][2]  // Documento
	cProduto   := aArrSD3[1][3]  // Produto
	cLoteCtl   := aArrSD3[1][4]  // Lote
	cNumLote   := aArrSD3[1][5]  // Sub-Lote
	nQuant     := aArrSD3[1][6]  // Quantidade
	nRateio    := aArrSD3[1][7]  // % de rateio do custo
	cLocal     := aArrSD3[1][8]  // Local
	cEndereco  := aArrSD3[1][9]  // Endereço
	cIdDCF     := aArrSD3[1][10] // Id DCF
	cCf        := aArrSD3[1][11] // cCf
	cChave     := aArrSD3[1][12] // Chave
	cServico   := aArrSD3[1][13] // Servico WMS
	cStatus    := aArrSD3[1][14] // Status servico WMS
	cRegra     := aArrSD3[1][15] // Regra WMS
	// Verifica se o custo medio é calculado On-Line
	If	cCusMed == "O"
		// Se necessario cria o cabecalho do arquivo de prova
		nHdlPrv := HeadProva(cLoteEst,"WMSA510",Subs(cUsuario,7,6),@cArquivo)
		If	nHdlPrv <= 0
			lContinua := .F.
		EndIf
	EndIf
	If	lContinua
		// Tratamento para Dead-Lock |
		For nX := 1	to	Len(aArrSD3)
			If aScan(aLockSB2,aArrSD3[nX][3]+aArrSD3[nX][8]) == 0
				aAdd(aLockSB2,aArrSD3[nX][3]+aArrSD3[nX][8])
			EndIf
		Next nX
		// Tratamento para Dead-Lock
		If MultLock("SB2",aLockSB2,1)
			// Pega o proximo numero sequencial de movimento
			If !lMontagem
				cNumSeq := ProxNum()
			EndIf
			// Atualiza arquivo de saldos em estoque
			cAliasSB2 := GetNextAlias()
			BeginSql Alias cAliasSB2
				SELECT SB2.R_E_C_N_O_ RECNOSB2
				FROM %Table:SB2% SB2
				WHERE SB2.B2_FILIAL = %xFilial:SB2%
				AND SB2.B2_COD = %Exp:cProduto%
				AND SB2.B2_LOCAL = %Exp:cLocal%
				AND SB2.%NotDel%
			EndSql
			If (cAliasSB2)->(Eof())
				CriaSB2(cProduto,cLocal)
			EndIf
			(cAliasSB2)->(dbCloseArea())
			// Busca dados produto para geração do movimento interno
			cAliasSB1 := GetNextAlias()
			BeginSql Alias cAliasSB1
				SELECT SB1.B1_UM,
						SB1.B1_GRUPO,
						SB1.B1_SEGUM,
						SB1.B1_TIPO,
						SB1.B1_CONTA,
						SB1.B1_ITEMCC,
						SB1.B1_CLVL,
						SB1.B1_CC
				FROM %Table:SB1% SB1
				WHERE SB1.B1_FILIAL = %xFilial:SB1% 
				AND SB1.B1_COD = %Exp:cProduto%
				AND SB1.%NotDel%
			EndSql
			If (cAliasSB1)->(!Eof())
				If Rastro(cProduto)
					cAliasSB8 := GetNextAlias()
					BeginSql Alias cAliasSB8
						SELECT SB8.B8_DTVALID,
								SB8.B8_DFABRIC,
								SB8.B8_LOTEFOR,
								SB8.B8_POTENCI
						FROM %Table:SB8% SB8
						WHERE SB8.B8_FILIAL = %xFilial:SB8%
						AND SB8.B8_NUMLOTE = %Exp:cNumLote%
						AND SB8.B8_LOTECTL = %Exp:cLoteCtl%
						AND SB8.B8_PRODUTO = %Exp:cProduto%
						AND SB8.B8_LOCAL = %Exp:cLocal%
						AND SB8.%NotDel%
					EndSql
					TcSetField(cAliasSB8,'B8_DTVALID','D')
					TcSetField(cAliasSB8,'B8_DFABRIC','D')
					If (cAliasSB8)->(!Eof())
						dDtValid := (cAliasSB8)->B8_DTVALID
						dDFabric := (cAliasSB8)->B8_DFABRIC
						cLoteFor := (cAliasSB8)->B8_LOTEFOR
						nPotenci := (cAliasSB8)->B8_POTENCI
					EndIf
					
					(cAliasSB8)->(dbCloseArea())
				EndIf
				RecLock("SD3",.T.)
				Replace D3_FILIAL  With	xFilial("SD3")
				Replace D3_TM      With cTm	
				Replace D3_DOC     With cDocumento
				Replace D3_COD     With cProduto
				Replace D3_QUANT   With nQuant
				Replace D3_QTSEGUM With ConvUm(cProduto,nQuant,0,2)
				Replace D3_RATEIO  With nRateio
				Replace D3_LOCAL   With cLocal
				Replace D3_EMISSAO With dDataBase
				Replace D3_UM      With (cAliasSB1)->B1_UM
				Replace D3_GRUPO   With (cAliasSB1)->B1_GRUPO
				Replace D3_NUMSEQ  With Iif(!lMontagem,cNumSeq,ProxNum())
				Replace D3_SEGUM   With (cAliasSB1)->B1_SEGUM
				Replace D3_CF      With cCf
				Replace D3_CHAVE   With cChave
				Replace D3_TIPO    With (cAliasSB1)->B1_TIPO
				Replace D3_CONTA   With (cAliasSB1)->B1_CONTA
				Replace D3_ITEMCTA With (cAliasSB1)->B1_ITEMCC
				Replace D3_CLVL    With (cAliasSB1)->B1_CLVL
				Replace D3_CC      With (cAliasSB1)->B1_CC
				Replace D3_IDDCF   With cIdDCF
				Replace D3_SERVIC  With cServico
				Replace D3_STSERV  With cStatus
				Replace D3_REGWMS  With cRegra
				Replace D3_USUARIO With CUSERNAME
				// Atualiza os dados do lote quando controla rastro
				If Rastro(cProduto)
					Replace D3_LOTECTL With cLoteCtl
					Replace D3_NUMLOTE With IIf(Rastro(cProduto,"S"),cNumLote,CriaVar("D3_NUMLOTE"))
					Replace D3_DTVALID With dDtValid
					Replace D3_POTENCI With nPotenci
				EndIf
			EndIf
			(cAliasSB1)->(dbCloseArea())
			//---------------------------------+
			//	Pega os 15 custos	medios atuais |
			//---------------------------------+
			aCM := PegaCMAtu(SD3->D3_COD,SD3->D3_LOCAL)
			//-------------------------------+
			// Grava o custo da movimentacao |
			//-------------------------------+
			aCusto := GravaCusD3(aCM)
			//---------------------------------------------------+
			// Atualiza o saldo atual (VATU) com os dados do SD3 |
			//---------------------------------------------------+
			If	!B2AtuComD3(aCusto)
				If !lMontagem
					aSvCus := AClone(aCusto)
					aSoma  := AClone(aCusto)
				EndIf
				//-----------------------------------------------+
				// Verifica se o custo medio é calculado On-Line |
				//-----------------------------------------------+
				If	cCusMed == "O"
					//---------------------------------------+
					// Gera o lancamento no arquivo de prova |
					//---------------------------------------+
					nTotal += DetProva(nHdlPrv,"670","WMSA510",cLoteEst)
				EndIf
				If lMontagem
					cNumSeq := ProxNum()
				EndIf
				For nI := 2	To	Len(aArrSD3)
					//----------------------+
					// Inicializa variaveis |
					//----------------------+
					cTm        := aArrSD3[nI][1] //	Tipo movimentação (999/499)
					cDocumento := aArrSD3[nI][2] //	Documento
					cProduto   := aArrSD3[nI][3] //	Produto
					cLoteCtl   := aArrSD3[nI][4] //	Lote
					cNumLote   := aArrSD3[nI][5] //	Sub-Lote
					nQuant     := aArrSD3[nI][6] //	Quantidade
					nRateio    := aArrSD3[nI][7] //	% de rateio do custo
					cLocal     := aArrSD3[nI][8] //	Local
					cEndereco  := aArrSD3[nI][9] //	Endereço
					cIdDCF     := aArrSD3[nI][10] // Id DCF
					cCf        := aArrSD3[nI][11] // Cf
					cChave     := aArrSD3[nI][12] // Chave
					cServico   := aArrSD3[nI][13] // Servico WMS
					cStatus    := aArrSD3[nI][14] // Status servico WMS
					cRegra     := aArrSD3[nI][15] // Regra WMS
					// Recria produto se não existir
					cAliasSB2 := GetNextAlias()
					BeginSql Alias cAliasSB2
						SELECT SB2.R_E_C_N_O_ RECNOSB2
						FROM %Table:SB2% SB2
						WHERE SB2.B2_FILIAL = %xFilial:SB2%
						AND SB2.B2_COD = %Exp:cProduto%
						AND SB2.B2_LOCAL = %Exp:cLocal%
						AND SB2.%NotDel%
					EndSql
					If (cAliasSB2)->(Eof())
						CriaSB2(cProduto,cLocal)
					EndIf
					(cAliasSB2)->(dbCloseArea())
					// Busca dados produto para geração do movimento interno
					cAliasSB1 := GetNextAlias()
					BeginSql Alias cAliasSB1
						SELECT SB1.B1_UM,
								SB1.B1_GRUPO,
								SB1.B1_SEGUM,
								SB1.B1_TIPO,
								SB1.B1_CONTA,
								SB1.B1_PRVALID,
								SB1.B1_ITEMCC,
								SB1.B1_CLVL,
								SB1.B1_CC
						FROM %Table:SB1% SB1
						WHERE SB1.B1_FILIAL = %xFilial:SB1% 
						AND SB1.B1_COD = %Exp:cProduto%
						AND SB1.%NotDel%
					EndSql
					If (cAliasSB1)->(!Eof())
						If Rastro(cProduto)
							cAliasSB8 := GetNextAlias()
							BeginSql Alias cAliasSB8
								SELECT SB8.B8_DTVALID,
										SB8.B8_DFABRIC,
										SB8.B8_LOTEFOR,
										SB8.B8_POTENCI
								FROM %Table:SB8% SB8
								WHERE SB8.B8_FILIAL = %xFilial:SB8%
								AND SB8.B8_NUMLOTE = %Exp:cNumLote%
								AND SB8.B8_LOTECTL = %Exp:cLoteCtl%
								AND SB8.B8_PRODUTO = %Exp:cProduto%
								AND SB8.B8_LOCAL = %Exp:cLocal%
								AND SB8.%NotDel%
							EndSql
							TcSetField(cAliasSB8,'B8_DTVALID','D')
							TcSetField(cAliasSB8,'B8_DFABRIC','D')
							If (cAliasSB8)->(!Eof())
								cLoteFor := (cAliasSB8)->B8_LOTEFOR
								dDtValid := (cAliasSB8)->B8_DTVALID
								dDFabric := (cAliasSB8)->B8_DFABRIC
								nPotenci := (cAliasSB8)->B8_POTENCI
							Else
								If Empty(dDtValid)
									dDtValid := dDataBase + (cAliasSB1)->B1_PRVALID
								EndIf
								If Empty(dDFabric)
									dDFabric := dDataBase
								EndIf
							EndIf
							(cAliasSB8)->(dbCloseArea())
						EndIf
						RecLock("SD3",.T.)
						Replace D3_FILIAL  With xFilial("SD3")
						Replace D3_TM      With cTm
						Replace D3_DOC     With cDocumento
						Replace D3_COD     With cProduto
						Replace D3_QUANT   With nQuant
						Replace D3_QTSEGUM With ConvUm(cProduto,nQuant,0,2)
						Replace D3_RATEIO  With nRateio
						Replace D3_LOCAL   With cLocal
						Replace D3_EMISSAO With dDataBase
						Replace D3_UM      With (cAliasSB1)->B1_UM
						Replace D3_GRUPO   With (cAliasSB1)->B1_GRUPO
						Replace D3_NUMSEQ  With cNumSeq
						Replace D3_SEGUM   With (cAliasSB1)->B1_SEGUM
						Replace D3_CF      With cCf
						Replace D3_CHAVE   With cChave
						Replace D3_TIPO    With (cAliasSB1)->B1_TIPO
						Replace D3_CONTA   With (cAliasSB1)->B1_CONTA
						Replace D3_ITEMCTA With (cAliasSB1)->B1_ITEMCC
						Replace D3_CLVL    With (cAliasSB1)->B1_CLVL
						Replace D3_CC      With (cAliasSB1)->B1_CC
						Replace D3_IDDCF   With cIdDCF
						Replace D3_SERVIC  With cServico
						Replace D3_STSERV  With cStatus
						Replace D3_REGWMS  With cRegra
						Replace D3_USUARIO With CUSERNAME
						If Rastro(cProduto)
							Replace D3_LOTECTL With cLoteCtl
							Replace D3_NUMLOTE With IIf(Rastro(cProduto,"S"),cNumLote,CriaVar("D3_NUMLOTE"))
							Replace D3_DTVALID With dDtValid
							Replace D3_POTENCI With nPotenci
						EndIf
						
						If	!__lPyme	.Or. (lLocS3 .And. LocalizS3())
							Replace D3_LOCALIZ With	cEndereco
						EndIf
					EndIf
					(cAliasSB1)->(dbCloseArea())
					// Grava	o custo da movimentacao	com rateio
					If !lMontagem
						aCusto := {0,0,0,0,0}
						For nX := 1	To	5
							cCampo := "D3_CUSTO"+StrZero(nX,1,0)
	
							aCusto[nX] := Round(aSvCus[nX] * nRateio / 100,nTamDec)
							aSoma[nX] -= aCusto[nX]
	
							Replace &(cCampo)	With aCusto[nX]
						Next nX
					Else
						// Pega os 15 custos	medios atuais
						aCM := PegaCMAtu(SD3->D3_COD,SD3->D3_LOCAL)
						// Grava	o custo da movimentacao
						aCusto := GravaCusD3(aCM)
					EndIf
					// Atualiza o saldo atual (VATU) com os dados do SD3
					If	!B2AtuComD3(aCusto)
						// Verifica se o custo medio é calculado On-Line
						If	cCusMed == "O"
							// Gera o lancamento no arquivo de prova
							nTotal += DetProva(nHdlPrv,"672","WMSA510",cLoteEst)
						EndIf
					EndIf
					// Posicionar no lote novo
					If Rastro(cProduto)
						cAliasSB8 := GetNextAlias()
						BeginSql Alias cAliasSB8
							SELECT SB8.R_E_C_N_O_ RECNOSB8
							FROM %Table:SB8% SB8
							WHERE SB8.B8_FILIAL = %xFilial:SB8%
							AND SB8.B8_NUMLOTE = %Exp:SD3->D3_NUMLOTE%
							AND SB8.B8_LOTECTL = %Exp:SD3->D3_LOTECTL%
							AND SB8.B8_PRODUTO = %Exp:SD3->D3_COD%
							AND SB8.B8_LOCAL = %Exp:SD3->D3_LOCAL%
							AND SB8.%NotDel%
						EndSql
						If (cAliasSB8)->(!Eof())
							SB8->(dbGoTo((cAliasSB8)->RECNOSB8))
							RecLock("SB8",.F.)
							SB8->B8_LOTEFOR := cLoteFor
							SB8->B8_DFABRIC := dDFabric
							SB8->(MsUnlock())
						EndIf
						(cAliasSB8)->(dbCloseArea())
					EndIf
				Next nI
				// Verifica se o custo medio é calculado On-Line
				If	cCusMed == "O"
					// Inicializa perguntas deste programa
					// mv_par01 - Se mostra e permite digitar lancamentos contabeis
					// mv_par02 - Se deve aglutinar os lancamentos contabeis
					Pergunte("MTA260",.F.)
					lDigita := Iif(mv_par01 == 1,.T.,.F.)
					lAglutina := Iif(mv_par02 == 1,.T.,.F.)
					// Se ele criou o arquivo de prova ele deve gravar o rodapé
					RodaProva(nHdlPrv,nTotal)
					If	( FindFunction( "UsaSeqCor" )	.And.	UsaSeqCor()	)
						cCodDiario := CtbaVerdia()
						aCtbDia := {{"SD3",SD3->(RECNO()),cCodDiario,"D3_NODIA","D3_DIACTB"}}
					Else
						aCtbDia := {}
					EndIF
					cA100Incl(cArquivo,nHdlPrv,3,cLoteEst,lDigita,lAglutina,,,,,,aCtbDia)
				EndIf
				SD3->(MsUnlock())
			EndIf
		EndIf
	EndIf
Return Nil
//----------------------------------------
/*/{Protheus.doc} EstDesSD3
Gera SD3 apuração de custo
@author Squad WMS Protheus
@since 13/03/2015
@version 1.0
@param aArrSD3[1] - Produto
		aArrSD3[2] - Local
/*/
//----------------------------------------
METHOD EstDesSD3(aArrSD3, cSeqEst, nOperac) CLASS WMSDTCEstoqueEndereco
Local lContinua := .T.
Local aAreaAnt  := GetArea()
Local aLockSD3  := {}
Local aLockSB2  := {}
Local aCtbDia   := {}
Local bCampo    := {|nCPO|	Field(nCPO)}
Local cArquivo  := ""
Local cCusMed   := GetMv("MV_CUSMED")
Local cLoteEst  := ""
Local cAliasSD3 := Nil
Local nRecnoSD3 := 0
Local nHdlPrv   := 0
Local nTotal    := 0
Local nX        := 0
Local i         := 0
	cLoteEst := AllTrim(FWGetSX5("09",'EST')[1,4])
	If Empty(cLoteEst)
		cLoteEst := "EST"
	EndIf
	// Verifica se o custo medio é calculado On-Line
	If	cCusMed == "O"
		nHdlPrv := HeadProva(cLoteEst,"WMSA510",Subs(cUsuario,7,6),@cArquivo)
		If	nHdlPrv <= 0
			lContinua := .F.
		EndIf
	EndIf
	If	lContinua
		// Tratamento para Dead-Lock
		// Produto Origem
		For nX := 1	to	Len(aArrSD3)
			If	aScan(aLockSD3,aArrSD3[nX][1]+aArrSD3[nX][2]+cSeqEst)==0
				aadd(aLockSD3,aArrSD3[nX][1]+aArrSD3[nX][2]+cSeqEst)
			EndIf
			If	aScan(aLockSB2,aArrSD3[nX][1]+aArrSD3[nX][2])==0
				aadd(aLockSB2,aArrSD3[nX][1]+aArrSD3[nX][2])
			EndIf
		Next nX
		// Tratamento para Dead-Lock
		If	MultLock("SD3",aLockSD3,3)	.And.	MultLock("SB2",aLockSB2,1)
			// Gera movimento inverso da origem
			// Grava o Flag de estorno
			cAliasSD3 := GetNextAlias()
			BeginSql Alias cAliasSD3
				SELECT R_E_C_N_O_ RECNOSD3
				FROM %Table:SD3% SD3
				WHERE SD3.D3_FILIAL = %xFilial:SD3%
				AND SD3.D3_NUMSEQ = %Exp:cSeqEst%
				AND SD3.%NotDel%
				ORDER BY SD3.R_E_C_N_O_
			EndSql
			If (cAliasSD3)->(!Eof())
				nRecnoSD3 := (cAliasSD3)->RECNOSD3
			EndIf
			(cAliasSD3)->(dbCloseArea())
			
			SD3->(dbGoTo(nRecnoSD3))
			If	SD3->D3_ESTORNO == "S"
				Help(" ",1,"A242ESTORN")
			Else
				RecLock("SD3",.F.)
				Replace D3_ESTORNO With	"S"
				MsUnlock()
				//---------------------------------------------------+
				// Salva a integridade dos campos de Bancos de Dados |
				//---------------------------------------------------+
				For i	:=	1 To FCount()
					M->&(EVAL(bCampo,i))	:=	FieldGet(i)
				Next i
				//---------------------------------------------------------+
				// Cria o registro de estorno com mesmos dados do original |
				//---------------------------------------------------------+
				RecLock("SD3",.T.)
				For i	:=	1 To FCount()
					FieldPut(i,M->&(EVAL(bCampo,i)))
				Next i
				cTipMov := SubsTr(D3_TM,2,1)
				Replace D3_TM      With Iif(nOperac == "2","499","999") 
				Replace D3_CF      With Iif(D3_TM <= "500","DE"+cTipMov,"RE"+cTipMov)
				Replace D3_CHAVE   With SubStr(D3_CF,2,1)+IIf(D3_TM <= "500","9","0")
				Replace D3_USUARIO With CUSERNAME
				MsUnlock()
				// Pega o custo da movimentacao
				aCusto := PegaCusD3()
				// Atualiza o saldo atual (VATU) com os dados do SD3
				If	!B2AtuComD3(aCusto)
					// Verifica se o custo medio é calculado On-Line
					If	cCusMed == "O"
						// Gera o lancamento no arquivo de prova
						nTotal += DetProva(nHdlPrv,"672","WMSA510",cLoteEst)
					EndIf
					// Gera movimento inverso do destino
					cAliasSD3 := GetNextAlias()
					BeginSql Alias cAliasSD3
						SELECT R_E_C_N_O_ RECNOSD3
						FROM %Table:SD3% SD3
						WHERE SD3.D3_FILIAL = %xFilial:SD3%
						AND SD3.D3_NUMSEQ = %Exp:cSeqEst%
						AND D3_ESTORNO <> 'S'
						AND SD3.%NotDel%
						ORDER BY SD3.R_E_C_N_O_
					EndSql
					Do While (cAliasSD3)->(!Eof())
						// Grava o Flag de estorno
						SD3->(dbGoTo((cAliasSD3)->RECNOSD3))
						RecLock("SD3",.F.)
						Replace D3_ESTORNO With "S"
						SD3->(MsUnlock())
						// Salva a integridade dos campos de Bancos de Dados
						For i	:=	1 To FCount()
							M->&(EVAL(bCampo,i))	:=	FieldGet(i)
						Next i
						// Cria o registro de estorno com mesmos dados do original
						RecLock("SD3",.T.)
						For i	:=	1 To FCount()
							FieldPut(i,M->&(EVAL(bCampo,i)))
						Next i
						Replace D3_TM			With Iif(nOperac == "2","999","499") 
						Replace D3_CF      With Iif(D3_TM <= "500","DE"+cTipMov,"RE"+cTipMov)
						Replace D3_CHAVE   With SubStr(D3_CF,2,1)+IIf(D3_TM <= "500","9","0")
						Replace D3_USUARIO	With CUSERNAME
						SD3->(MsUnlock())
						// Pega o custo da movimentacao
						aCusto := PegaCusD3()
						// Atualiza o saldo atual (VATU) com os dados do SD3
						If	!B2AtuComD3(aCusto)
							// Verifica se o custo medio é calculado On-Line
							If	cCusMed == "O"
								// Gera o lancamento no arquivo de prova
								nTotal += DetProva(nHdlPrv,"670","WMSA510",cLoteEst)
							EndIf
						EndIf
						(cAliasSD3)->(dbSkip())
					EndDo
					(cAliasSD3)->(dbCloseArea())
				EndIf
			EndIf
		EndIf
		// Verifica se o custo medio é calculado On-Line
		If	cCusMed == "O"
			// Inicializa perguntas deste programa
			// mv_par01 - Se mostra e permite digitar lancamentos contabeis
			// mv_par02 - Se deve aglutinar os lancamentos contabeis
			Pergunte("MTA260",.F.)
			lDigita	 := Iif(mv_par01 == 1,.T.,.F.)
			lAglutina := Iif(mv_par02 == 1,.T.,.F.)
			// Se ele criou o arquivo de prova ele deve gravar o rodapé
			RodaProva(nHdlPrv,nTotal)
			If	( FindFunction( "UsaSeqCor" )	.And.	UsaSeqCor()	)
				cCodDiario := CtbaVerdia()
				aCtbDia := {{"SD3",SD3->(RECNO()),cCodDiario,"D3_NODIA","D3_DIACTB"}}
			Else
				 aCtbDia	:=	{}
			EndIF
			cA100Incl(cArquivo,nHdlPrv,3,cLoteEst,lDigita,lAglutina,,,,,,aCtbDia)
		EndIf
	EndIf
	RestArea(aAreaAnt)
Return Nil
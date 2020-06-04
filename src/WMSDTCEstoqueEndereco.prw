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
CLASS WMSDTCEstoqueEndereco FROM LongClassName
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
	METHOD AnaEstoque(cLog,cCod,cLocal)
	METHOD MovInvSD3(aMovSd3,lDesmontagem)
	METHOD GeraMovEst(cTipo)
	METHOD WmsGeraOP(cLocal,cProduto,nQtd)
	METHOD WmsApontOp(cNum,cProduto,nQtd,cDocSD3,nRecno,cLocal,cLote,cNumLote)
	METHOD WmsReqPart(cDocSD3,dDataInv,cNumSeq,cPrdComp,cArmazem,cEndereco,nQuant,cNumOp)
	METHOD GeraEmpReq(cOrigem,cOp,cTrt,cIdDCF,lEstorno,lCriaSDC,lEmpD14)
	METHOD GerUnitEst(cArmazem,cEndereco,cIdUnit,cTipUni)
	METHOD MakeFatLoj(nRecnoSD2)
	METHOD UndoFatLoj(nRecnoSD2)
	METHOD EquateKard(dData,cOrigem,cArmazem,cEndereco,cPrdOri,cProduto,cLoteCtl,cNumLote,cNumSer,cIdUnit)
	METHOD SelectKard(lProcess,dData,cArmazem,cEndereco,cPrdOri,cProduto,cLoteCtl,cNumLote,cNumSer,cIdUnit)
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
	Self:lHasCodUni := WmsX312118("D14","D14_CODUNI")
	Self:oProdLote  := WMSDTCProdutoLote():New()
	Self:oEndereco  := WMSDTCEndereco():New()
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
	Self:cCodNorma  := PadR("" , TamSx3("DC3_CODNOR")[1])
	Self:cCodVolume := PadR("" , TamSx3("D14_CODVOL")[1])
	Self:cIdVolume  := PadR("" , TamSx3("D14_IDVOLU")[1])
	Self:cIdUnitiz  := PadR("" , TamSx3("D14_IDUNIT")[1])
	Self:cTipUni    := PadR("" , Iif(Self:lHasCodUni,TamSx3("D14_CODUNI")[1],6))
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
Local aAreaAnt   := GetArea()
Local lRet       := .T.
Local cQuery     := ""
Local cAliasD14  := ""
Local aD14_QTDEST:= TamSx3("D14_QTDEST")
Local aD14_QTDES2:= TamSx3("D14_QTDES2")
Local aD14_QTDEPR:= TamSx3("D14_QTDEPR")
Local aD14_QTDEP2:= TamSx3("D14_QTDEP2")
Local aD14_QTDSPR:= TamSx3("D14_QTDSPR")
Local aD14_QTDSP2:= TamSx3("D14_QTDSP2")
Local aD14_QTDEMP:= TamSx3("D14_QTDEMP")
Local aD14_QTDEM2:= TamSx3("D14_QTDEM2")
Local aD14_QTDBLQ:= TamSx3("D14_QTDBLQ")
Local aD14_QTDBL2:= TamSx3("D14_QTDBL2")
Local aD14_QTDPEM:= TamSx3("D14_QTDPEM")
Local aD14_QTDPE2:= TamSx3("D14_QTDPE2")
Local aAreaD14   := D14->(GetArea())

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
		cQuery := " SELECT D14.D14_LOCAL,"
		cQuery +=        " D14.D14_ENDER,"
		cQuery +=        " D14.D14_PRODUT,"
		cQuery +=        " D14.D14_LOTECT,"
		cQuery +=        " D14.D14_NUMLOT,"
		cQuery +=        " D14.D14_DTVALD,"
		cQuery +=        " D14.D14_DTFABR,"
		cQuery +=        " D14.D14_NUMSER,"
		cQuery +=        " D14.D14_ESTFIS,"
		cQuery +=        " D14.D14_PRIOR,"
		cQuery +=        " D14.D14_QTDEST,"
		cQuery +=        " D14.D14_QTDES2,"
		cQuery +=        " D14.D14_QTDEPR,"
		cQuery +=        " D14.D14_QTDEP2,"
		cQuery +=        " D14.D14_QTDSPR,"
		cQuery +=        " D14.D14_QTDSP2,"
		cQuery +=        " D14.D14_QTDEMP,"
		cQuery +=        " D14.D14_QTDEM2,"
		cQuery +=        " D14.D14_QTDBLQ,"
		cQuery +=        " D14.D14_QTDBL2,"
		cQuery +=        " D14.D14_CODVOL,"
		cQuery +=        " D14.D14_IDVOLU,"
		cQuery +=        " D14.D14_IDUNIT,"
		If Self:lHasCodUni
			cQuery +=     " D14.D14_CODUNI,"
		EndIf
		cQuery +=        " D14.D14_PRDORI,"
		cQuery +=        " D14.D14_OK,"
		cQuery +=        " D14.D14_QTDPEM,"
		cQuery +=        " D14.D14_QTDPE2,"
		cQuery +=        " D14.R_E_C_N_O_ RECNOD14"
		cQuery +=  " FROM "+RetSqlName('D14')+" D14"
		cQuery += " WHERE D14.D14_FILIAL = '"+xFilial("D14")+"'"
		Do Case
			Case nIndex == 1 // D14_FILIAL+D14_LOCAL+D14_ENDER+D14_PRDORI+D14_PRODUT+D14_LOTECT+D14_NUMLOT+D14_NUMSER+D14_IDUNIT
				cQuery += " AND D14.D14_LOCAL = '" + Self:oEndereco:GetArmazem() + "'"
				cQuery += " AND D14.D14_ENDER = '" + Self:oEndereco:GetEnder() + "'"
				cQuery += " AND D14.D14_PRDORI = '" + Self:oProdLote:GetPrdOri() + "'"
				cQuery += " AND D14.D14_PRODUT = '" + Self:oProdLote:GetProduto() + "'"
				If !Empty(Self:oProdLote:GetLoteCtl())
					cQuery += " AND D14.D14_LOTECT = '" + Self:oProdLote:GetLoteCtl() + "'"
				EndIf
				If !Empty(Self:oProdLote:GetNumLote())
					cQuery += " AND D14.D14_NUMLOT = '" + Self:oProdLote:GetNumLote() + "'"
				EndIf
				If !Empty(Self:oProdLote:GetNumSer())
					cQuery += " AND D14.D14_NUMSER = '" + Self:oProdLote:GetNumSer() + "'"
				EndIf
				If !Empty(Self:GetIdUnit())
					cQuery += " AND D14.D14_IDUNIT = '" + Self:GetIdUnit() + "'"
				EndIf
			Case nIndex == 3 // D14_FILIAL+D14_LOCAL+D14_PRODUT+D14_ENDER+D14_LOTECT+D14_NUMLOT+D14_NUMSER+D14_IDUNIT
				cQuery += " AND D14.D14_LOCAL = '" + Self:oEndereco:GetArmazem() + "'"
				cQuery += " AND D14.D14_PRODUT = '" + Self:oProdLote:GetProduto() + "'"
				cQuery += " AND D14.D14_ENDER = '" + Self:oEndereco:GetEnder() + "'"
				If !Empty(Self:oProdLote:GetLoteCtl())
					cQuery += " AND D14.D14_LOTECT = '" + Self:oProdLote:GetLoteCtl() + "'"
				EndIf
				If !Empty(Self:oProdLote:GetNumLote())
					cQuery += " AND D14.D14_NUMLOT = '" + Self:oProdLote:GetNumLote() + "'"
				EndIf
				If !Empty(Self:oProdLote:GetNumSer())
					cQuery += " AND D14.D14_NUMSER = '" + Self:oProdLote:GetNumSer() + "'"
				EndIf
				If !Empty(Self:GetIdUnit())
					cQuery += " AND D14.D14_IDUNIT = '" + Self:GetIdUnit() + "'"
				EndIf
		EndCase
		cQuery +=   " AND D14.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasD14  := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasD14,.F.,.T.)
		TCSetField(cAliasD14,'D14_QTDEST','N',aD14_QTDEST[1],aD14_QTDEST[2])
		TCSetField(cAliasD14,'D14_QTDES2','N',aD14_QTDES2[1],aD14_QTDES2[2])
		TCSetField(cAliasD14,'D14_QTDEPR','N',aD14_QTDEPR[1],aD14_QTDEPR[2])
		TCSetField(cAliasD14,'D14_QTDEP2','N',aD14_QTDEP2[1],aD14_QTDEP2[2])
		TCSetField(cAliasD14,'D14_QTDSPR','N',aD14_QTDSPR[1],aD14_QTDSPR[2])
		TCSetField(cAliasD14,'D14_QTDSP2','N',aD14_QTDSP2[1],aD14_QTDSP2[2])
		TCSetField(cAliasD14,'D14_QTDEMP','N',aD14_QTDEMP[1],aD14_QTDEMP[2])
		TCSetField(cAliasD14,'D14_QTDEM2','N',aD14_QTDEM2[1],aD14_QTDEM2[2])
		TCSetField(cAliasD14,'D14_QTDBLQ','N',aD14_QTDBLQ[1],aD14_QTDBLQ[2])
		TCSetField(cAliasD14,'D14_QTDBL2','N',aD14_QTDBL2[1],aD14_QTDBL2[2])
		TCSetField(cAliasD14,'D14_QTDPEM','N',aD14_QTDPEM[1],aD14_QTDPEM[2])
		TCSetField(cAliasD14,'D14_QTDPE2','N',aD14_QTDPE2[1],aD14_QTDPE2[2])
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
	Self:cCodNorma := PadR(cCodNorma, TamSx3("DC3_CODNOR")[1])
Return

METHOD SetCodVolu(cCodVolume) CLASS WMSDTCEstoqueEndereco
	Self:cCodVolume := PadR(cCodVolume, TamSx3("D14_CODVOL")[1])
Return

METHOD SetIdVolu(cIdVolume) CLASS WMSDTCEstoqueEndereco
	Self:cIdVolume := PadR(cIdVolume, TamSx3("D14_IDVOLU")[1])
Return

METHOD SetIdUnit(cIdUnitiz) CLASS WMSDTCEstoqueEndereco
	Self:cIdUnitiz := PadR(cIdUnitiz, TamSx3("D14_IDUNIT")[1])
Return

METHOD SetTipUni(cTipUni) CLASS WMSDTCEstoqueEndereco
	Self:cTipUni := PadR(cTipUni, Iif(Self:lHasCodUni,TamSx3("D14_CODUNI")[1],6))
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
Local lRet := .T.
Local aAreaD14 := D14->(GetArea())
	dbSelectArea('D14')
	D14->(dbSetOrder(1)) // D14_FILIAL+D14_LOCAL+D14_ENDER+D14_PRDORI+D14_PRODUT+D14_LOTECT+D14_NUMLOT+D14_NUMSER+D14_IDUNIT
	If lRet := D14->(dbSeek(xFilial('D14')+Self:oEndereco:GetArmazem()+Self:oEndereco:GetEnder()+Self:oProdLote:GetPrdOri()+Self:oProdLote:GetProduto()))
		Self:oProdLote:SetLoteCtl(D14->D14_LOTECT)
		Self:oProdLote:SetNumLote(D14->D14_NUMLOT)
	EndIf
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
Local lRet		:= .T.
Local lAchou	:= .F.
Local aAreaD14:= D14->(GetArea())
Local cFilter := Nil
Local lAnalisEnd := .F.
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
		cFilter := D14->(dbFilter())
		D14->(dbClearFilter())
		D14->(dbSetOrder(1)) // D14_FILIAL+D14_LOCAL+D14_ENDER+D14_PRDORI+D14_PRODUT+D14_LOTECT+D14_NUMLOT+D14_NUMSER+D14_IDUNIT
		lAchou := D14->(dbSeek(xFilial("D14")+Self:oEndereco:GetArmazem()+Self:oEndereco:GetEnder()+Self:oProdLote:GetPrdOri()+Self:oProdLote:GetProduto()+Self:oProdLote:GetLoteCtl()+Self:oProdLote:GetNumLote()+Self:oProdLote:GetNumSer()+Self:cIdUnitiz))

		If !lAchou .And. cTipo == "999"
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
		If !Empty(cFilter)
			D14->(dbSetFilter(&("{|| "+cFilter+"}"), cFilter))
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
Local nSaldo         := 0
Local cQuery         := ''
Local cAliasD14      := GetNextAlias()
Local aAreaD14       := D14->(GetArea())

Default lEntPrevista := .F.
Default lSaiPrevista := .F.
Default lEmpenho     := .T.
Default lBloqueado   := .T.
	// Monta query
	cQuery := "SELECT SUM (D14_QTDEST "
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
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasD14,.F.,.T.)
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
Local nComprom    := 0
Local nReserva    := 0
Local nEstoque    := 0
Local nSldDifEnd  := 0
Local aAreaSB2    := SB2->(GetArea())
Local aAreaD11    := D11->(GetArea())
Local aTamSX3     := TamSx3("D14_QTDEST")
Local cAliasD14   := ""
Local lRastro     := Rastro(cProduto)
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
			dbSelectArea("SB2")
			SB2->(dbSetOrder(1))
			If SB2->(dbSeek(xFilial("SB2")+cProduto+cArmazem))
				If !lRastro
					nReserva := SB2->B2_RESERVA

					dbSelectArea("D11")
					D11->(dbSetOrder(2))
					If D11->(dbSeek(xFilial('D11')+cProduto))
						If SB2->(dbSeek(xFilial('SB2')+D11->D11_PRDORI+cArmazem))
							nReserva += (SB2->B2_RESERVA * D11->D11_QTMULT)
						EndIf
					EndIf
				Else
					dbSelectArea("SB8")
					SB8->(dbSetOrder(3)) // B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL+B8_NUMLOTE+DTOS(B8_DTVALID)
					If SB8->(dbSeek(xFilial("SB8")+cProduto+cArmazem+cLoteCtl+cNumLote))
						nReserva := SB8->B8_EMPENHO
					EndIf

					dbSelectArea("D11")
					D11->(dbSetOrder(2))
					If D11->(dbSeek(xFilial('D11')+cProduto))
						If SB8->(dbSeek(xFilial("SB8")+D11->D11_PRDORI+cArmazem+cLoteCtl+cNumLote))
							nReserva += (SB8->B8_EMPENHO * D11->D11_QTMULT)
						EndIf
					EndIf
				EndIf

				// Reserva sem empenho previsto
				nReserva -= Self:GetQtdPem()
				// Busca quantidade
				cAliasD14 := GetNextAlias()
				cQuery := "SELECT SUM(D14.D14_QTDEST - (D14.D14_QTDSPR+D14.D14_QTDBLQ+D14.D14_QTDEMP)) D14_QTDEST," // Quantidade disponível do produto nos outros endereços
				cQuery +=       " SUM(D14.D14_QTDPEM+D14.D14_QTDEMP) D14_QTDPEM" // Quantidade de empenho previstos do produtos no outros endereços que virar empenho
				cQuery +=  " FROM "+RetSqlName('D14')+" D14"
				cQuery += " WHERE D14.D14_FILIAL = '"+xFilial('D14')+"'"
				cQuery +=   " AND D14.D14_LOCAL  = '"+cArmazem+"'"
				cQuery +=   " AND D14.D14_ENDER <> '"+cEndereco+"'"
				cQuery +=   " AND D14.D14_PRODUT = '"+cProduto+"'"
				cQuery +=   " AND D14.D14_LOTECT = '"+cLoteCtl+"'"
				cQuery +=   " AND D14.D14_NUMLOT = '"+cNumLote+"'"
				cQuery +=   " AND D14.D14_NUMSER = '"+cNumSerie+"'"
				cQuery +=   " AND D14.D_E_L_E_T_ = ' '"
				cQuery := ChangeQuery(cQuery)
				DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasD14,.F.,.T.)
				TcSetField(cAliasD14,'D14_QTDEST','N',aTamSX3[1],aTamSX3[2])
				If (cAliasD14)->(!Eof())
					nSldDifEnd := (cAliasD14)->D14_QTDEST
					// Desconta do saldo de reserva do produto a quantidade de empenho previsto dos outros endereços
					nReserva -= (cAliasD14)->D14_QTDPEM
				EndIf
				(cAliasD14)->(DbCloseArea())
				// Calcula se há reserva e verifica se o saldo disponível do outros endereço é suficiente para atendê-los
				nComprom += IIf(QtdComp(nReserva-nSldDifEnd) < 0, 0,nReserva-nSldDifEnd)
			EndIf
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
Local cQuery    := ""
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
		cQuery := "SELECT D14_PRODUT"
		cQuery +=  " FROM "+RetSqlName("D14")
		cQuery += " WHERE D14_FILIAL = '"+xFilial("D14")+"'"
		cQuery +=   " AND D14_LOCAL  = '"+Self:oEndereco:GetArmazem()+"'"
		cQuery +=   " AND D14_ESTFIS = '"+Self:oEndereco:GetEstFis()+"'"
		cQuery +=   " AND D14_ENDER  = '"+Self:oEndereco:GetEnder()+"'"
		cQuery +=   " AND D14_PRODUT <> '"+Self:oProdLote:GetProduto()+"'" //Somente considera se for produto diferente
		cQuery +=   " AND (D14_QTDEST + D14_QTDEPR) > 0"
		cQuery +=   " AND D_E_L_E_T_ = ' '"
		cQuery += " GROUP BY D14_PRODUT"
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasD14,.F.,.T.)
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
Local aAreaAnt := GetArea()
Local nSaldo     := 0
Local nEmpenho   := 0
Local nLotReserv := 0
Local nB8Saldo   := 0
Local nB2Reserva := 0
Local nB8Disponi := 0
Local nSomaLot   := 0
Local cQuery     := ""
Local cAliasQry  := ""
Local cAliasQry2 := ""
Local cLoteCtl   := ""
Local cNumLote   := ""
Local cPrdOri    := ""
Local lRastro    := .F.
Local lSubLot    := .F.
Local nMinSaldo  := Nil
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
		cQuery := " SELECT MIN(CASE WHEN SLD.D14_QTDISP IS NULL THEN 0 ELSE SLD.D14_QTDISP END) SALDO"
		cQuery +=   " FROM (SELECT PRD.PRD_CODIGO,"
		cQuery +=                " (SUM(D14.D14_QTDEST / PRD.PRD_QTMULT)" // Estoque D14
		If lConsReser
			cQuery +=            " - (SUM((D14.D14_QTDSPR + D14.D14_QTDEMP + D14.D14_QTDBLQ) / PRD.PRD_QTMULT) + ( " // Movimentações WMS D14
			cQuery +=            Iif(lMontado,"SB2.B2_RESERVA","SB2.B2_RESERVA/PRD.PRD_QTMULT") // Reserva estoque SB2/SB8
			cQuery +=            " - SUM((D14.D14_QTDPEM + D14.D14_QTDEMP) / PRD.PRD_QTMULT)))" // Reserva WMS D14
		EndIf
		cQuery +=                " ) D14_QTDISP"
		cQuery +=           " FROM (SELECT CASE WHEN D11.D11_PRDCMP IS NULL THEN SB5.B5_COD ELSE D11.D11_PRDCMP END PRD_CODIGO,"
		cQuery +=                        " CASE WHEN D11.D11_QTMULT IS NULL THEN 1          ELSE D11.D11_QTMULT END PRD_QTMULT"
		cQuery +=                   " FROM "+RetSqlName("SB5")+" SB5"
		cQuery +=                   " LEFT JOIN "+RetSqlName("D11")+" D11"
		cQuery +=                     " ON D11.D11_FILIAL = '"+xFilial("D11")+"'"
		cQuery +=                    " AND SB5.B5_FILIAL  = '"+xFilial("SB5")+"'"
		cQuery +=                    " AND D11.D11_PRODUT = SB5.B5_COD"
		cQuery +=                    " AND D11.D11_PRDORI = SB5.B5_COD"
		cQuery +=                    " AND D11.D_E_L_E_T_ = ' '"
		cQuery +=                  " WHERE SB5.B5_FILIAL  = '"+xFilial("SB5")+"'"
		cQuery +=                    " AND SB5.B5_COD     = '"+Self:oProdLote:GetPrdOri()+"'"
		cQuery +=                    " AND SB5.D_E_L_E_T_ = ' ') PRD"
		cQuery +=           " LEFT JOIN "+RetSqlName("D14")+" D14"
		cQuery +=             " ON D14.D14_FILIAL = '"+xFilial("D14")+"'"
		cQuery +=            " AND D14.D14_LOCAL  = '"+Self:oProdLote:GetArmazem()+"'"
		cQuery +=            " AND D14.D14_PRDORI = "+Iif(lMontado,"'"+Self:oProdLote:GetPrdOri()+"'","PRD.PRD_CODIGO")
		cQuery +=            " AND D14.D14_PRODUT = PRD.PRD_CODIGO"
		If !Empty(Self:oProdLote:GetNumSer())
			cQuery +=        " AND D14.D14_NUMSER = '" + Self:oProdLote:GetNumSer() + "'"
		EndIf
		If !Empty(Self:cIdUnitiz)
			cQuery +=        " AND D14.D14_IDUNIT = '"+Self:cIdUnitiz+"'"
		EndIf
		cQuery +=            " AND D14.D_E_L_E_T_ = ' '"
		If lConsReser
			cQuery +=       " LEFT JOIN "+RetSqlName("SB2")+" SB2"
			cQuery +=         " ON SB2.B2_FILIAL  = '"+xFilial("SB2")+"'"
			cQuery +=        " AND D14.D14_FILIAL = '"+xFilial("D14")+"'"
			cQuery +=        " AND SB2.B2_LOCAL   = D14.D14_LOCAL"
			cQuery +=        " AND SB2.B2_COD     = D14.D14_PRDORI"
			cQuery +=        " AND SB2.D_E_L_E_T_ = ' '"
		EndIf
		cQuery +=          " GROUP BY PRD.PRD_CODIGO, "+Iif(lConsReser,"SB2.B2_RESERVA,","")+" PRD.PRD_QTMULT) SLD"
		cAliasQry := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
		TCSetField(cAliasQry,'SALDO','N',TamSx3("D14_QTDEST")[1],TamSx3("D14_QTDEST")[2])
		If (cAliasQry)->(!Eof())
			nSaldo := Iif(Empty((cAliasQry)->SALDO),0,(cAliasQry)->SALDO)
		EndIf
		(cAliasQry)->(dbCloseArea())
	Else
		If lMontado
			If lConsReser
				// Busca informações SB2/SB8 do produto para utilizar no rateio de reserva do lote
				cQuery := " SELECT SB2.B2_RESERVA,"
				cQuery +=        " SUM(SB8.B8_SALDO) B8_SALDO,"
				cQuery +=        " SUM(SB8.B8_EMPENHO) B8_EMPENHO"
				cQuery +=   " FROM "+RetSqlName("SB2")+" SB2"
				cQuery +=   " LEFT JOIN "+RetSqlName("SB8")+" SB8"
				cQuery +=     " ON SB8.B8_FILIAL = '"+xFilial("SB8")+"'"
				cQuery +=    " AND SB8.B8_PRODUTO = SB2.B2_COD"
				cQuery +=    " AND SB8.B8_LOCAL = SB2.B2_LOCAL"
				cQuery +=    " AND SB8.D_E_L_E_T_ = ' '"
				cQuery +=  " WHERE SB2.B2_FILIAL = '"+xFilial("SB2")+"'"
				cQuery +=    " AND SB2.B2_COD = '"+Self:oProdLote:GetPrdOri()+"'"
				cQuery +=    " AND SB2.B2_LOCAL = '"+Self:oProdLote:GetArmazem()+"'"
				cQuery +=    " AND SB2.D_E_L_E_T_ = ' '"
				cQuery +=  " GROUP BY SB2.B2_COD, SB2.B2_LOCAL, SB2.B2_RESERVA"
				cQuery := ChangeQuery(cQuery)
				cAliasQry := GetNextAlias()
				DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
				TCSetField(cAliasQry,'B2_RESERVA','N',TamSx3("B2_RESERVA")[1],TamSx3("B2_RESERVA")[2])
				TCSetField(cAliasQry,'B8_SALDO'  ,'N',TamSx3("B8_SALDO")[1]  ,TamSx3("B8_SALDO")[2])
				TCSetField(cAliasQry,'B8_EMPENHO','N',TamSx3("B8_EMPENHO")[1],TamSx3("B8_EMPENHO")[2])
				If (cAliasQry)->(!Eof())
					nB8Disponi := (cAliasQry)->B8_SALDO - (cAliasQry)->B8_EMPENHO
					// Desconta da reserva SB2 a reserva que já está na SB8
					nB2Reserva := (cAliasQry)->B2_RESERVA - (cAliasQry)->B8_EMPENHO
				EndIf
				(cAliasQry)->(dbCloseArea())
			EndIf

			// Busca os lotes do produto
			cQuery := " SELECT SB8.B8_SALDO,"
			cQuery +=        " SB8.B8_EMPENHO,"
			cQuery +=        " SB8.B8_LOTECTL,"
			cQuery +=        " SB8.B8_NUMLOTE,"
			cQuery +=        " SB8.B8_DTVALID"
			cQuery +=   " FROM "+RetSqlName("SB8")+" SB8"
			cQuery +=  " WHERE SB8.B8_FILIAL = '"+xFilial("SB8")+"'"
			cQuery +=    " AND SB8.B8_PRODUTO = '"+Self:oProdLote:GetPrdOri()+"'"
			cQuery +=    " AND SB8.B8_LOCAL = '"+Self:oProdLote:GetArmazem()+"'"
			// Caso o lote seja passado a função, considera o lote informado
			If !Empty(Self:oProdLote:GetLotectl())
				cQuery += " AND SB8.B8_LOTECTL = '"+Self:oProdLote:GetLotectl()+"'"
			EndIf
			If lSubLot
				If !Empty(Self:oProdLote:GetNumLote())
					cQuery += " AND SB8.B8_NUMLOTE = '"+Self:oProdLote:GetNumLote()+"'"
				EndIf
			EndIf
			cQuery +=    " AND SB8.B8_SALDO <> 0"
			cQuery +=    " AND SB8.D_E_L_E_T_ = ' '"
			cAliasQry := GetNextAlias()
			DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
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

				If lPai
					cQuery := " SELECT MIN(CASE WHEN SLD.D14_QTDISP IS NULL THEN 0 ELSE SLD.D14_QTDISP END) SALDO"
					cQuery +=   " FROM (SELECT PRD.PRD_CODIGO,"
					cQuery +=                " (SUM(D14.D14_QTDEST / PRD.PRD_QTMULT)" // Estoque D14
					If lConsReser
						cQuery +=            " - (SUM((D14.D14_QTDSPR + D14.D14_QTDEMP + D14.D14_QTDBLQ) / PRD.PRD_QTMULT) + " // Movimentações WMS D14
						cQuery +=               "("+cValToChar(nLotReserv)+" - SUM((D14.D14_QTDPEM + D14.D14_QTDEMP) / PRD.PRD_QTMULT)))" // Reserva estoque SB2/SB8 - reserva WMS D14
					EndIf
					cQuery +=                " ) D14_QTDISP"
					cQuery +=           " FROM (SELECT CASE WHEN D11.D11_PRDCMP IS NULL THEN SB5.B5_COD ELSE D11.D11_PRDCMP END PRD_CODIGO,"
					cQuery +=                        " CASE WHEN D11.D11_QTMULT IS NULL THEN 1          ELSE D11.D11_QTMULT END PRD_QTMULT"
					cQuery +=                   " FROM "+RetSqlName("SB5")+" SB5"
					cQuery +=                   " LEFT JOIN "+RetSqlName("D11")+" D11"
					cQuery +=                     " ON D11.D11_FILIAL = '"+xFilial("D11")+"'"
					cQuery +=                    " AND SB5.B5_FILIAL  = '"+xFilial("SB5")+"'"
					cQuery +=                    " AND D11.D11_PRODUT = SB5.B5_COD"
					cQuery +=                    " AND D11.D11_PRDORI = SB5.B5_COD"
					cQuery +=                    " AND D11.D_E_L_E_T_ = ' '"
					cQuery +=                  " WHERE SB5.B5_FILIAL  = '"+xFilial("SB5")+"'"
					cQuery +=                    " AND SB5.B5_COD     = '"+Self:oProdLote:GetPrdOri()+"'"
					cQuery +=                    " AND SB5.D_E_L_E_T_ = ' ') PRD"
					cQuery +=           " LEFT JOIN "+RetSqlName("D14")+" D14"
					cQuery +=             " ON D14.D14_FILIAL = '"+xFilial("D14")+"'"
					cQuery +=            " AND D14.D14_LOCAL  = '"+Self:oProdLote:GetArmazem()+"'"
					cQuery +=            " AND D14.D14_PRDORI = '"+Self:oProdLote:GetPrdOri()+"'"
					cQuery +=            " AND D14.D14_PRODUT = PRD.PRD_CODIGO"
					cQuery +=            " AND D14.D14_LOTECT = '"+cLoteCtl+"'"
					cQuery +=            " AND D14.D14_NUMLOT = '"+cNumLote+"'"
					//cQuery +=            " AND D14.D14_DTVALD = '"+DtoS(dDtValid)+"'" Não filtrar ainda pois há casos em que a data de validade D14 fica diferente da SB8
					If !Empty(Self:oProdLote:GetNumSer())
						cQuery +=        " AND D14.D14_NUMSER = '" + Self:oProdLote:GetNumSer() + "'"
					EndIf
					If !Empty(Self:cIdUnitiz)
						cQuery +=        " AND D14.D14_IDUNIT = '"+Self:cIdUnitiz+"'"
					EndIf
					cQuery +=            " AND D14.D_E_L_E_T_ = ' '"
					cQuery +=          " GROUP BY PRD.PRD_CODIGO, PRD.PRD_QTMULT) SLD"
				Else
					cQuery := " SELECT D14.D14_PRODUT,"
					cQuery +=        " (SUM(D14.D14_QTDEST)" // Estoque D14
					If lConsReser
						cQuery +=    " - (SUM(D14.D14_QTDSPR + D14.D14_QTDEMP + D14.D14_QTDBLQ) + " // Movimentações WMS D14
						cQuery +=       "("+cValToChar(nLotReserv)+" - SUM(D14.D14_QTDPEM + D14.D14_QTDEMP)))" // Reserva estoque SB2/SB8 - reserva WMS D14
					EndIf
					cQuery +=        " ) SALDO"
					cQuery +=   " FROM "+RetSqlName("D14")+" D14"
					cQuery +=  " WHERE D14.D14_FILIAL = '"+xFilial("D14")+"'"
					cQuery +=    " AND D14.D14_LOCAL  = '"+Self:oProdLote:GetArmazem()+"'"
					cQuery +=    " AND D14.D14_PRDORI = '"+Self:oProdLote:GetPrdOri()+"'"
					cQuery +=    " AND D14.D14_LOTECT = '"+cLoteCtl+"'"
					cQuery +=    " AND D14.D14_NUMLOT = '"+cNumLote+"'"
					//cQuery +=            " AND D14.D14_DTVALD = '"+DtoS(dDtValid)+"'" Não filtrar ainda pois há casos em que a data de validade D14 fica diferente da SB8
					If !Empty(Self:oProdLote:GetNumSer())
						cQuery += " AND D14.D14_NUMSER = '" + Self:oProdLote:GetNumSer() + "'"
					EndIf
					If !Empty(Self:cIdUnitiz)
						cQuery += " AND D14.D14_IDUNIT = '"+Self:cIdUnitiz+"'"
					EndIf
					cQuery +=    " AND D14.D_E_L_E_T_ = ' '"
					cQuery +=  " GROUP BY D14.D14_PRODUT"
				EndIf
				cAliasQry2 := GetNextAlias()
				DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry2,.F.,.T.)
				TCSetField(cAliasQry2,'SALDO','N',TamSx3("D14_QTDEST")[1],TamSx3("D14_QTDEST")[2])
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

			cQuery := " SELECT DISTINCT SB8.B8_LOTECTL"
			cQuery +=   " FROM "+RetSqlName("SB8")+" SB8"
			cQuery +=  " INNER JOIN "+RetSqlName("D11")+" D11"
			cQuery +=     " ON D11.D11_FILIAL = '"+xFilial("D11")+"'"
			cQuery +=    " AND D11.D11_PRODUT = '"+Self:oProdLote:GetPrdOri()+"'"
			cQuery +=    " AND D11.D11_PRDORI = '"+Self:oProdLote:GetPrdOri()+"'"
			cQuery +=    " AND D11.D11_PRDCMP = SB8.B8_PRODUTO"
			cQuery +=    " AND D11.D_E_L_E_T_ = ' '"
			cQuery +=  " WHERE SB8.B8_FILIAL = '"+xFilial("SB8")+"'"
			cQuery +=    " AND SB8.B8_LOCAL = '"+Self:oProdLote:GetArmazem()+"'"
			If !Empty(Self:oProdLote:GetLotectl())
				cQuery += " AND SB8.B8_LOTECTL = '"+Self:oProdLote:GetLotectl()+"'"
			EndIf
			cQuery +=    " AND SB8.B8_SALDO <> 0"
			cQuery +=    " AND SB8.D_E_L_E_T_ = ' '"
			cAliasQry := GetNextAlias()
			DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
			Do While (cAliasQry)->(!Eof())
				nMinSaldo := Nil
				// Retorna valor original do objeto
				Self:oProdLote:SetPrdOri(cPrdOri)
				Self:oProdLote:SetLotectl(cLoteCtl)

				cQuery := " SELECT D11.D11_PRDCMP,"
				cQuery +=        " D11.D11_QTMULT,"
				cQuery +=        " CASE WHEN SB8.B8_LOTECTL IS NULL THEN 0 ELSE 1 END ORDEM"
				cQuery +=   " FROM "+RetSqlName("D11")+" D11"
				cQuery +=   " LEFT JOIN "+RetSqlName("SB8")+" SB8"
				cQuery +=     " ON SB8.B8_FILIAL = '"+xFilial("SB8")+"'"
				cQuery +=    " AND SB8.B8_LOCAL = '"+Self:oProdLote:GetArmazem()+"'"
				cQuery +=    " AND SB8.B8_PRODUTO = D11.D11_PRDCMP"
				cQuery +=    " AND SB8.B8_LOTECTL = '"+(cAliasQry)->B8_LOTECTL+"'"
				cQuery +=    " AND SB8.B8_SALDO <> 0"
				cQuery +=    " AND SB8.D_E_L_E_T_ = ' '"
				cQuery +=  " WHERE D11.D11_FILIAL = '"+xFilial("D11")+"'"
				cQuery +=    " AND D11.D11_PRODUT = '"+Self:oProdLote:GetPrdOri()+"'"
				cQuery +=    " AND D11.D11_PRDORI = '"+Self:oProdLote:GetPrdOri()+"'"
				cQuery +=    " AND D11.D_E_L_E_T_ = ' '"
				cQuery +=  " ORDER BY ORDEM"
				cQuery := ChangeQuery(cQuery)
				cAliasQry2 := GetNextAlias()
				DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry2,.F.,.T.)
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
Local nProduto   := 0
Local oMovEstEnd := WMSDTCMovimentosEstoqueEndereco():New()
Local oProdLote  := WMSDTCProdutoLote():New()
Local aAreaSC9   := SC9->(GetArea())
Local cAliasD13  := Nil

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
					cQuery := "SELECT D13.R_E_C_N_O_ RECNOD13"
					cQuery +=  " FROM "+RetSqlName('D13')+" D13"
					cQuery += " WHERE D13.D13_FILIAL = '"+xFilial("D13")+"'"
					cQuery +=   " AND D13.D13_IDDCF = '" +SC9->C9_IDDCF+"'"
					cQuery +=   " AND D13.D13_DOC = '"+cNFiscal+"'"
					cQuery +=   " AND D13.D13_NUMSEQ = '"+cNumSeq+"'"
					cQuery +=   " AND D13.D13_USACAL <> '2'"
					cQuery +=   " AND D13.D_E_L_E_T_ = ' '"
					cQuery := ChangeQuery(cQuery)
					cAliasD13 := GetNextAlias()
					DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasD13,.F.,.T.)
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
Local cAliD14  := GetNextAlias()
Local aSldEnd  := {}
Local aTamSX3  := TamSx3('D14_QTDEST')
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

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliD14,.F.,.T.)
	TcSetField(cAliD14,'D14_QTDEST','N',aTamSX3[1],aTamSX3[2])
	TcSetField(cAliD14,'D14_DTVALD','D')
	While (cAliD14)->( !Eof() )
		aAdd(aSldEnd, { ;
			(cAliD14)->(FieldGet(1)),;                                           //[1]  Local            D14_LOCAL
			(cAliD14)->(FieldGet(2)),;                                           //[2]  Endereço         D14_ENDER
			(cAliD14)->(FieldGet(3)),;                                           //[3]  Lote             D14_LOTECT
			(cAliD14)->(FieldGet(4)),;                                           //[4]  Sub-lote         D14_NUMLOT
			(cAliD14)->(FieldGet(5)),;                                           //[5]  Número de Série  D14_NUMSER
			Int((cAliD14)->(FieldGet(6))),;                                      //[6]  Quantidade       D14_QTDEST
			ConvUm((cAliD14)->(FieldGet(9)),Int((cAliD14)->(FieldGet(6))),0,2),; //[7]  Seg. Un medida   D14_QTDES2
			(cAliD14)->(FieldGet(7)),;                                           //[8]  Data de Validade D14_DTVALD
			(cAliD14)->(FieldGet(8)),;                                           //[9]  Produto origem   D14_PRDORI
			(cAliD14)->(FieldGet(9)),;                                           //[10] Produto          D14_PRODUT
			(cAliD14)->(FieldGet(10)),;                                          //[11] Id Unitizador    D14_IDUNIT
			(cAliD14)->(FieldGet(11))})                                          //[12] Tipo Unitizador  D14_TIPUNI

		(cAliD14)->( dbSkip() )
	EndDo
	(cAliD14)->( dbCloseArea() )

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
Local dDataIni   := CtoD("31/12/1899")
Local aSldPeriod := {}
Local cAliasD15  := ""
Local cQuery     := ""
Local nI         := 0
Local nPos       := 0
Local nQtdMult   := 0
Local oMovEstEnd := Nil
Local aProdComp  := {}
Local aSaldo     := {0, 0, 0, 0, 0, 0, 0}

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
	cQuery := " SELECT MAX(D15_DATA) D15_DATA"
	cQuery +=   " FROM "+RetSqlName("D15")
	cQuery +=  " WHERE D15_FILIAL = '"+xFilial("D15")+"'"
	cQuery +=    " AND D15_LOCAL = '"+Self:oEndereco:GetArmazem()+"'"
	cQuery +=    " AND D15_PRDORI = '"+Self:oProdLote:GetProduto()+"'"
	If !Empty(Self:oEndereco:GetEnder())
		cQuery +=    " AND D15_ENDER = '"+Self:oEndereco:GetEnder()+"'"
	EndIf
	If !Empty(Self:oProdLote:GetLoteCtl())
		cQuery +=    " AND D15_LOTECT = '"+Self:oProdLote:GetLoteCtl()+"'"
		If !Empty(Self:oProdLote:GetNumLote())
			cQuery +=    " AND D15_NUMLOT = '"+Self:oProdLote:GetNumLote()+"'"
		EndIf
	EndIf
	If !Empty(Self:oProdLote:GetNumSer())
		cQuery +=    " AND D15_NUMSER = '"+Self:oProdLote:GetNumSer()+"'"
	EndIf
	If !Empty(Self:cIdUnitiz)
		cQuery +=    " AND D15_IDUNIT = '"+Self:cIdUnitiz+"'"
	EndIf
	cQuery +=    " AND D15_DATA <= '"+DtoS(dDataRef)+"'"
	cQuery +=    " AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasD15 := GetNextAlias()
	dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasD15,.F.,.T.)
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
	oMovEstEnd:oMovPrdLot:SetArmazem(Self:oEndereco:GetArmazem())
	oMovEstEnd:oMovPrdLot:SetPrdOri(Self:oProdLote:GetProduto())
	oMovEstEnd:oMovPrdLot:SetLoteCtl(Self:oProdLote:GetLoteCtl())
	oMovEstEnd:oMovPrdLot:SetNumLote(Self:oProdLote:GetNumLote())
	oMovEstEnd:oMovPrdLot:SetNumSer(Self:oProdLote:GetNumSer())
	oMovEstEnd:oEndereco:SetEnder(Self:oEndereco:GetEnder())
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
Local aAreaAnt   := GetArea()
Local aAreaSB7   := SB7->(GetArea())
Local aAreaSD3   := SD3->(GetArea())
Local oMovEstEnd := WMSDTCMovimentosEstoqueEndereco():New()
Local oProdComp  := Self:oProdLote:oProduto:oProdComp
Local lRet       := .T.
Local lPartes    := .F.
Local aQtdsPrd   := {}
Local aEndDisp   := {}
Local nI         := 0
Local nI2        := 0
Local nQtdDif    := 0
Local nSaldoAtu  := 0
Local nQtdEst    := 0
Local nQtdMov    := 0
Local nQtdMult   := 0
Local nSaldoWMS  := 0
Local nQtdMovPai := 0
Local cPrdOri    := ""
Local cPrdComp   := ""
Local cNumSeq    := ProxNum()
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

	/////////////////////////////
	/////LOG INVENTARIO//////////
	MA340GrvLg("SALDO PRODUTO="+cProduto+" PRDORI="+cPrdOri,"07","NSALDOATU="+cValToChar(nSaldoAtu))
	/////////////////////////////
	If lPartes
		// Procura saldo do componente como produto
		Self:oProdLote:SetPrdOri(Self:oProdLote:GetProduto())
		If Self:LoadData()
			nQtdEst := Self:CalcEstWms(cLocal,cProduto,aMV_Par[1],cEnder,cLoteCtl,cNumLote,cNumserie,3,Self:oProdLote:GetPrdOri(),cIdUnitiz)
			aAdd(aQtdsPrd, {nQtdEst,Self:oProdLote:GetPrdOri()})
			nSaldoAtu += nQtdEst
		EndIf
		Self:oProdLote:SetPrdOri(cPrdOri)
		/////////////////////////////
		/////LOG INVENTARIO//////////
		MA340GrvLg("SALDO PRODUTO="+cProduto+" PRDORI="+cProduto,"07","NQTDEST="+cValToChar(nQtdEst))
		/////////////////////////////
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
				/////////////////////////////
				/////LOG INVENTARIO//////////
				MA340GrvLg("DESMONTAGEM","08")
				/////////////////////////////

				// Analise o saldo atual do pai, para validar se ha endereços disponíveis para realizar a desmontagem
				If nQtdMovPai > Self:GetSldOrig(.T.,.T.)
					/////////////////////////////
					/////LOG INVENTARIO//////////
					MA340GrvLg("ERRO ENDD","08")
					/////////////////////////////
					cLog := "ENDD"
					Return .F.
				EndIf

				// Movimenta a quantidade do pai desmontada
				A340SD3Prt(cPrdOri,,"999",nQtdMovPai,"DESMONTAG",.T.,,aMV_Par,cNumSeq,.T./*lDesmontagem*/,)
				/////////////////////////////
				/////LOG INVENTARIO//////////
				MA340GrvLg("SD3 999 PRODUTO="+cPrdOri,"08",cValtoChar(nQtdMovPai))
				/////////////////////////////
				// Atualiza a data de inventário do produto pai.
				SB1->(dbSetOrder(1))
				SB1->(dbSeek(xFilial("SB1")+cPrdOri))
				If SB2->(dbSeek(xFilial("SB2")+cPrdOri+cLocal))
					If SB2->B2_DINVENT <= aMV_Par[1] .And. SB2->B2_STATUS # "2"
						dbSelectArea("SB2")
						RecLock("SB2",.F.)
						Replace B2_DINVENT With aMV_Par[1]
						MsUnlockAll()
						/////////////////////////////
						/////LOG INVENTARIO//////////
						MA340GrvLg("B2_DINVENT","08",DtoS(B2_DINVENT))
						/////////////////////////////
					EndIf
				EndIf
				// Seta as propriedades do movimento estoque endereço (D13)
				// Altera o documento para indicar que houve uma desmontagem no inventário
				oMovEstEnd:oOrdServ:SetDocto("DESMONTAG")
				oMovEstEnd:oOrdServ:SetOrigem("SB7")
				oMovEstEnd:SetDtEsto(aMV_Par[1])
				// Informações do endereço
				oMovEstEnd:oEndereco:SetArmazem(Self:oEndereco:GetArmazem())
				oMovEstEnd:oEndereco:SetEnder(Self:oEndereco:GetEnder())
				oMovEstEnd:oEndereco:LoadData()
				// Informações do produto
				oMovEstEnd:oMovPrdLot:SetArmazem(Self:oEndereco:GetArmazem())
				oMovEstEnd:oMovPrdLot:SetProduto(Self:oProdLote:GetProduto())
				oMovEstEnd:oMovPrdLot:SetPrdOri(Self:oProdLote:GetPrdOri())
				oMovEstEnd:oMovPrdLot:SetLoteCtl(Self:oProdLote:GetLoteCtl())
				oMovEstEnd:oMovPrdLot:SetNumLote(Self:oProdLote:GetNumLote())
				oMovEstEnd:oMovPrdLot:SetNumSer(Self:oProdLote:GetNumSer())
				oMovEstEnd:SetIdUnit(Self:cIdUnitiz)
				oMovEstEnd:oMovPrdLot:LoadData()
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
						Self:UpdSaldo("999",.T./*lEstoque*/,.F./*lEntPrev*/,.F./*lSaiPrev*/,.F./*lEmpenho*/,.F./*lBloqueio*/,.F./*lEmpPrev*/)
						/////////////////////////////
						/////LOG INVENTARIO//////////
						MA340GrvLg("D14 999 PRODUTO="+Self:oProdLote:GetProduto()+" PRDORI="+Self:oProdLote:GetPrdOri(),"08",cValtoChar(Self:GetQuant()))
						/////////////////////////////
						// Informações do endereço
						oMovEstEnd:oEndereco:SetArmazem(Self:oEndereco:GetArmazem())
						oMovEstEnd:oEndereco:SetEnder(Self:oEndereco:GetEnder())
						oMovEstEnd:oEndereco:LoadData()
						// Informações do produto
						oMovEstEnd:oMovPrdLot:SetArmazem(Self:oEndereco:GetArmazem())
						oMovEstEnd:oMovPrdLot:SetProduto(Self:oProdLote:GetProduto())
						oMovEstEnd:oMovPrdLot:SetPrdOri(Self:oProdLote:GetPrdOri())
						oMovEstEnd:oMovPrdLot:SetLoteCtl(Self:oProdLote:GetLoteCtl())
						oMovEstEnd:oMovPrdLot:SetNumLote(Self:oProdLote:GetNumLote())
						oMovEstEnd:oMovPrdLot:SetNumSer(Self:oProdLote:GetNumSer())
						oMovEstEnd:SetIdUnit(Self:cIdUnitiz)
						oMovEstEnd:oMovPrdLot:LoadData()
						// Realiza saída no endereço
						oMovEstEnd:SetQtdEst(Self:GetQuant())
						oMovEstEnd:MovEstExit()

						// Seta o parte para produto normal
						Self:oProdLote:SetPrdOri(cPrdComp)
						// Adiciona no mesmo endereço, porém para o produto normal
						Self:UpdSaldo("499",.T./*lEstoque*/,.F./*lEntPrev*/,.F./*lSaiPrev*/,.F./*lEmpenho*/,.F./*lBloqueio*/,.F./*lEmpPrev*/)
						/////////////////////////////
						/////LOG INVENTARIO//////////
						MA340GrvLg("D14 499 PRODUTO="+Self:oProdLote:GetProduto()+" PRDORI="+Self:oProdLote:GetPrdOri(),"08",cValtoChar(Self:GetQuant()))
						/////////////////////////////

						A340SD3Prt(cPrdComp,Self:oEndereco:GetEnder(),"499",Self:GetQuant(),"DESMONTAG",.T.,,aMV_Par,cNumSeq,.T./*lDesmontagem*/,)
						/////////////////////////////
						/////LOG INVENTARIO//////////
						MA340GrvLg("SD3 499 PRODUTO="+Self:oProdLote:GetProduto(),"08",cValtoChar(Self:GetQuant()))
						/////////////////////////////

						// Realiza o movimento do D13
						oMovEstEnd:oMovPrdLot:SetPrdOri(Self:oProdLote:GetPrdOri())
						oMovEstEnd:SetQtdEst(Self:GetQuant())
						// Realiza entrada no endereço
						oMovEstEnd:MovEstEnter()

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
	// Seta o endereço para o movimento de kardex
	oMovEstEnd:oEndereco:SetArmazem(Self:oEndereco:GetArmazem())
	oMovEstEnd:oEndereco:SetEnder(Self:oEndereco:GetEnder())
	oMovEstEnd:oEndereco:LoadData()
	// Sempre subtrai o saldo como produto normal
	oMovEstEnd:oMovPrdLot:SetArmazem(Self:oEndereco:GetArmazem())
	oMovEstEnd:oMovPrdLot:SetProduto(cProduto)
	oMovEstEnd:oMovPrdLot:SetPrdOri(cProduto)
	oMovEstEnd:oMovPrdLot:SetLoteCtl(Self:oProdLote:GetLoteCtl())
	oMovEstEnd:oMovPrdLot:SetNumLote(Self:oProdLote:GetNumLote())
	oMovEstEnd:oMovPrdLot:SetNumSer(Self:oProdLote:GetNumSer())
	oMovEstEnd:SetIdUnit(Self:cIdUnitiz)
	oMovEstEnd:oMovPrdLot:LoadData()
	oMovEstEnd:oOrdServ:SetDocto("INVENT")
	oMovEstEnd:oOrdServ:SetOrigem("SB7")
	oMovEstEnd:SetDtEsto(aMV_Par[1])

	If QtdComp(nSaldoAtu) > QtdComp(nQuant)
		nQtdDif := (nSaldoAtu - nQuant)

		Self:SetQuant(nQtdDif)
		// Subtrai a diferença do produto informado
		lRet := Self:UpdSaldo("999",.T./*lEstoque*/,.F./*lEntPrev*/,.F./*lSaiPrev*/,.F./*lEmpenho*/,.F./*lBloqueio*/)
		/////////////////////////////
		/////LOG INVENTARIO//////////
		MA340GrvLg("D14 999 PRODUTO="+Self:oProdLote:GetProduto()+" PRDORI="+Self:oProdLote:GetPrdOri(),"09",cValtoChar(Self:GetQuant()))
		/////////////////////////////
		If lRet
			oMovEstEnd:SetQtdEst(nQtdDif)
			// Realiza saída no endereço
			lRet := oMovEstEnd:MovEstExit()
		EndIf
	ElseIf QtdComp(nSaldoAtu) < QtdComp(nQuant)
		nQtdDif := (nQuant - nSaldoAtu)

		Self:SetQuant(nQtdDif)
		// Soma a diferença do produto informado
		lRet := Self:UpdSaldo("499",.T./*lEstoque*/,.F./*lEntPrev*/,.F./*lSaiPrev*/,.F./*lEmpenho*/,.F./*lBloqueio*/)
		/////////////////////////////
		/////LOG INVENTARIO//////////
		MA340GrvLg("D14 499 PRODUTO="+Self:oProdLote:GetProduto()+" PRDORI="+Self:oProdLote:GetPrdOri(),"09",cValtoChar(Self:GetQuant()))
		/////////////////////////////
		If lRet
			oMovEstEnd:SetQtdEst(nQtdDif)
			// Realiza entrada no endereço
			lRet := oMovEstEnd:MovEstEnter()
		EndIf
	EndIf
	/////////////////////////////
	/////LOG INVENTARIO//////////
	MA340GrvLg("BE_STATUS ","09",SBE->BE_STATUS)
	/////////////////////////////

	If !lRet
		cLog := "D14"
		/////////////////////////////
		/////LOG INVENTARIO//////////
		MA340GrvLg("Log D14","09")
		/////////////////////////////
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
Local aAreaAnt     := GetArea()
Local nSaldo       := 0
Local nSaldoPE     := Nil
Local cQuery       := ""
Local cAliasQry    := GetNextAlias()
Local lPai         := .F.
Default lConsSaida := .T.
Default cIdUnitiz  := ""

	Self:oProdLote:oProduto:oProdComp:SetProduto(cProduto)
	lPai := Self:oProdLote:oProduto:oProdComp:IsDad()

	cQuery := " SELECT (MIN(SALDOPROD.SALDO)) SALDO"
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
		cQuery += " INNER JOIN "+RetSqlName('DC8')+" DC8"
		cQuery +=    " ON DC8.DC8_FILIAL = '"+xFilial('DC8')+"'"
		cQuery +=   " AND DC8.DC8_CODEST = D14.D14_ESTFIS"
		If Self:lProducao
			cQuery +=   " AND DC8.DC8_TPESTR = '7'"
		Else
			cQuery +=   " AND DC8.DC8_TPESTR <> '7'"
		EndIf
		cQuery +=   " AND DC8.D_E_L_E_T_ = ' '"
	EndIf
	cQuery +=         " LEFT JOIN "+RetSqlName('D11')+" D11"
	cQuery +=           " ON D11.D11_FILIAL = D14.D14_FILIAL"
	cQuery +=          " AND D11.D11_PRDORI = D14.D14_PRDORI"
	cQuery +=          " AND D11.D_E_L_E_T_ = ' '"
	cQuery +=        " WHERE D14.D14_FILIAL = '"+xFilial('D14')+"'"
	If !Empty(cLocal)
		cQuery +=          " AND D14.D14_LOCAL  = '"+cLocal+"'"
	EndIf
	If !Empty(cEnder)
		cQuery +=          " AND D14.D14_ENDER  = '"+cEnder+"'"
	EndIf
	If !Empty(cProduto)
		cQuery +=          " AND D14.D14_PRDORI = '"+cProduto+"'"
		cQuery +=          " AND D14.D14_PRODUT = "+ Iif(lPai,"D11.D11_PRDCMP","D14.D14_PRDORI")
	EndIf
	If !Empty(cLoteCtl)
		cQuery +=          " AND D14.D14_LOTECT = '"+cLoteCtl+"'"
	EndIF
	If !Empty(cNumLote)
		cQuery +=          " AND D14.D14_NUMLOT = '"+cNumLote+"'"
	EndIf
	If !Empty(cNumSerie)
		cQuery +=          " AND D14.D14_NUMSER = '"+cNumSerie+"'"
	EndIf
	If !Empty(cIdUnitiz)
		cQuery +=          " AND D14.D14_IDUNIT = '"+cIdUnitiz+"'"
	EndIf
	cQuery +=        " GROUP BY D14.D14_PRDORI,"
	cQuery +=                 " D14.D14_LOCAL,"
	cQuery +=                 " D11.D11_PRDCMP,"
	cQuery +=                 " D11.D11_QTMULT) SALDOPROD"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,'TOPCONN',tcGenQry(,,cQuery),cAliasQry,.F.,.T.)
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
Local lRet := .T.
Local cQuery := ""
Local cAliasD14 := ""

Default nQuant := Self:GetQuant()

	cQuery := " SELECT D14.D14_ENDER"
	cQuery +=   " FROM "+RetSqlName("D14")+" D14"
	cQuery +=  " WHERE D14.D14_FILIAL = '"+xFilial("D14")+"'"
	cQuery +=    " AND D14.D14_LOCAL = '"+Self:oEndereco:GetArmazem()+"'"
	cQuery +=    " AND D14.D14_PRODUT = '"+Self:oProdLote:GetProduto()+"'"
	cQuery +=    " AND D14.D14_PRDORI = '"+Self:oProdLote:GetPrdOri()+"'"
	cQuery +=    " AND D14.D14_LOTECT = '"+Self:oProdLote:GetLoteCtl()+"'"
	cQuery +=    " AND D14.D14_NUMLOT = '"+Self:oProdLote:GetNumLote()+"'"
	If !Empty(Self:cIdUnitiz)
		cQuery += " AND D14.D14_IDUNIT = '"+Self:cIdUnitiz+"'"
	EndIf
	cQuery +=    " AND (D14.D14_QTDEST-(D14.D14_QTDEMP+D14.D14_QTDBLQ+D14.D14_QTDSPR)) >= "+AllTrim(Str(nQuant))
	cQuery +=    " AND D14.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasD14 := GetNextAlias()
	dbUseArea(.T.,'TOPCONN',tcGenQry(,,cQuery),cAliasD14,.F.,.T.)
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

	// Seta as propriedades do movimento estoque endereço (D13)
	// Informações do documento
	oMovEstEnd:oOrdServ:SetDocto(cDocSD3)
	oMovEstEnd:oOrdServ:SetOrigem(Iif(lInventario,"SB7","SD1"))
	oMovEstEnd:SetDtEsto(dDataInv)

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
				/////////////////////////////
				/////LOG INVENTARIO//////////
				MA340GrvLg("MONTPRDPAI","12","QUANTIDADE="+cValtoChar(nSaldoWMS))
				/////////////////////////////
			EndIf

			// Retorna o saldo que poderá ser montado
			If nSaldoWMS > 0
				cNumOP := Self:WmsGeraOP(cLocal, cPrdPai, nSaldoWMS)
				If Empty(cNumOP)
					If lInventario
						/////////////////////////////
						/////LOG INVENTARIO//////////
						MA340GrvLg("NÃO FOI GERADO OP SC2","12","")
						/////////////////////////////
					EndIf
					Return .F.
				EndIf

				If lInventario
					/////////////////////////////
					/////LOG INVENTARIO//////////
					MA340GrvLg("GERADO OP SC2","12",cNumOP)
					/////////////////////////////
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
						// Subtrai a quantidade do endereço, como componente
						Self:UpdSaldo("999",.T./*lEstoque*/,.F./*lEntPrev*/,.F./*lSaiPrev*/,.F./*lEmpenho*/,.F./*lBloqueio*/,.F./*lEmpPrev*/)
						If lInventario
							/////////////////////////////
							/////LOG INVENTARIO//////////
							MA340GrvLg("D14 999 FILHO="+cPrdComp+" PRDORI="+cPrdComp,"12","ENDERECO="+cEndereco+" QTD="+cValtoChar(Self:GetQuant()))
							/////////////////////////////
						EndIf
						// Subtrai do estoque a quantidade convertida do produto componente
						If !Self:WmsReqPart(cDocSD3,dDataInv,cNumSeq,cPrdComp,cLocal,cEndereco,Self:GetQuant(),cNumOp)
							Return .F.
						EndIf

						If lInventario
							/////////////////////////////
							/////LOG INVENTARIO//////////
							MA340GrvLg("SD3 999 FILHO="+cPrdComp,"12",cValtoChar(Self:GetQuant()))
							/////////////////////////////
						EndIf
						// Informações do endereço
						oMovEstEnd:oEndereco:SetArmazem(Self:oEndereco:GetArmazem())
						oMovEstEnd:oEndereco:SetEnder(Self:oEndereco:GetEnder())
						oMovEstEnd:oEndereco:LoadData()
						// Informações do produto
						oMovEstEnd:oMovPrdLot:SetArmazem(Self:oEndereco:GetArmazem())
						oMovEstEnd:oMovPrdLot:SetProduto(Self:oProdLote:GetProduto())
						oMovEstEnd:oMovPrdLot:SetPrdOri(Self:oProdLote:GetPrdOri())
						oMovEstEnd:oMovPrdLot:LoadData()
						// Realiza saída no endereço
						oMovEstEnd:SetQtdEst(Self:GetQuant())
						oMovEstEnd:MovEstExit()

						// Seta o parte para produto normal
						Self:oProdLote:SetPrdOri(cPrdPai)
						// Adiciona no mesmo endereço, porém para o produto normal
						Self:UpdSaldo("499",.T./*lEstoque*/,.F./*lEntPrev*/,.F./*lSaiPrev*/,.F./*lEmpenho*/,.F./*lBloqueio*/,.F./*lEmpPrev*/)
						If lInventario
							/////////////////////////////
							/////LOG INVENTARIO//////////
							MA340GrvLg("D14 499 FILHO="+cPrdComp+" PRDORI="+cPrdPai,"12",cValtoChar(Self:GetQuant()))
							/////////////////////////////
						EndIf
						// Realiza o movimento do D13
						oMovEstEnd:oMovPrdLot:SetPrdOri(Self:oProdLote:GetPrdOri())
						oMovEstEnd:SetQtdEst(Self:GetQuant())
						// Realiza entrada no endereço
						oMovEstEnd:MovEstEnter()

						If QtdComp((nSldConv -= Self:GetQuant())) == QtdComp(0)
							Exit
						EndIf
					Next nI3
				NExt nI2

				If !lInventario
					aAdd(aPrdMont,{nSaldoWMS,Posicione("SB1",1,xFilial("SB1")+cPrdPai,"B1_UM"),cPrdPai})
				EndIf
				If lInventario
					/////////////////////////////
					/////LOG INVENTARIO//////////
					MA340GrvLg("SD3 499 PAI="+cPrdPai,"12",cValtoChar(nSaldoWMS))
					/////////////////////////////
				EndIf

				aAreaSD3 := SD3->(GetArea())
				// Realiza o apontamento para criar o saldo do produto pai
				If !Self:WmsApontOp(cNumOP,cPrdPai,nSaldoWMS,cDocSD3,@nRecno,cLocal)
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
Local aAreaAnt   := GetArea()
Local lRet       := .T.
Local cQuery     := ""
Local cAliasQry  := ""
Local cStatus    := ""
Local cChkStatus := ""

Default lConsBlq := .F.

	cChkStatus := IIf(lConsBlq,"1|2|3|4|5|6","1|2|6")

	If Self:oEndereco:LoadData()
		//
		cQuery := "SELECT SBE.BE_STATUS,"
		cQuery +=       " SBE.R_E_C_N_O_ RECNOSBE,"
		cQuery +=       " SUM(D14.D14_QTDEST+D14.D14_QTDEPR+D14.D14_QTDSPR+D14.D14_QTDEMP+D14.D14_QTDBLQ+D14.D14_QTDPEM) D14_SALDO"
		cQuery +=  " FROM "+RetSqlName("SBE")+" SBE"
		cQuery +=  " LEFT JOIN "+RetSqlName("D14")+" D14"
		cQuery +=    " ON D14.D14_FILIAL = '"+xFilial("D14")+"'"
		cQuery +=   " AND SBE.BE_FILIAL = '"+xFilial("SBE")+"'"
		cQuery +=   " AND D14.D14_LOCAL = SBE.BE_LOCAL"
		cQuery +=   " AND D14.D14_ESTFIS = SBE.BE_ESTFIS"
		cQuery +=   " AND D14.D14_ENDER = SBE.BE_LOCALIZ"
		cQuery +=   " AND D14.D_E_L_E_T_ = ' '"
		cQuery += " WHERE SBE.BE_FILIAL = '"+xFilial("SBE")+"'"
		cQuery +=   " AND SBE.BE_LOCAL = '"+Self:oEndereco:GetArmazem()+"'"
		cQuery +=   " AND SBE.BE_LOCALIZ = '"+Self:oEndereco:GetEnder()+"'"
		cQuery +=   " AND SBE.BE_ESTFIS = '"+Self:oEndereco:GetEstFis()+"'"
		cQuery +=   " AND (( SBE.BE_STATUS = '6' AND NOT EXISTS ( SELECT 1"
		cQuery +=                                                 " FROM "+RetSqlName("SB7")+" SB7"
		cQuery +=                                                " WHERE SB7.B7_FILIAL = '"+xFilial("SB7")+"'"
		cQuery +=                                                  " AND SB7.B7_LOCAL = SBE.BE_LOCAL"
		cQuery +=                                                  " AND SB7.B7_LOCALIZ = SBE.BE_LOCALIZ"
		cQuery +=                                                  " AND SB7.B7_STATUS = '1'"
		cQuery +=                                                  " AND SB7.D_E_L_E_T_ = ' ' ))"
		cQuery +=     " OR ( SBE.BE_STATUS <> '6'))"
		cQuery +=   " AND SBE.D_E_L_E_T_ = ' '"
		cQuery += " GROUP BY SBE.BE_STATUS,"
		cQuery +=          " SBE.R_E_C_N_O_"
		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		dbUseArea(.T.,'TOPCONN',tcGenQry(,,cQuery),cAliasQry,.F.,.T.)
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

			If !Empty(cStatus) .And. (cAliasQry)->BE_STATUS != cStatus
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
Local cQuery      := ""
Local cAliasQry   := ""
Local aSldPeriod  := {}
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
	cQuery := " SELECT '000' NIVEL,"
	cQuery +=        " D15.D15_LOCAL LOCAL,"
	cQuery +=        " D15.D15_PRDORI PRDORI,"
	cQuery +=        " D15.D15_PRODUT PRODUT,"
	cQuery +=        " SUM(D15.D15_QINI) SALDO"
	cQuery +=   " FROM "+RetSqlName("D15")+" D15"
	cQuery +=  " WHERE D15.D15_FILIAL = '"+xFilial("D15")+"'"
	cQuery +=    " AND D15.D15_DATA = '"+DTOS(dUltFech)+"'"
	cQuery +=    " AND D15.D15_LOCAL = '"+cArmazem+"'"
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
		cQuery += " AND D15.D15_ENDER = '"+cEndereco+"'"
	EndIf
	If !Empty(cLoteCtl)
		cQuery += " AND D15.D15_LOTECT = '"+cLoteCtl+"'"
	EndIf
	If !Empty(cNumLote)
		cQuery += " AND D15.D15_NUMLOT = '"+cNumLote+"'"
	EndIf
	If !Empty(cNumserie)
		cQuery += " AND D15.D15_NUMSER = '"+cNumserie+"'"
	EndIf
	If !Empty(cIdUnitiz)
		cQuery += " AND D15.D15_IDUNIT = '"+cIdUnitiz+"'"
	EndIf
	cQuery +=    " AND D15.D_E_L_E_T_ = ' '"
	cQuery +=  " GROUP BY D15.D15_LOCAL,"
	cQuery +=           " D15.D15_PRDORI,"
	cQuery +=           " D15.D15_PRODUT"
	cQuery +=  " UNION ALL"
	// Saldo das entradas
	cQuery += " SELECT '499' NIVEL,"
	cQuery +=        " D13A.D13_LOCAL LOCAL,"
	cQuery +=        " D13A.D13_PRDORI PRDORI,"
	cQuery +=        " D13A.D13_PRODUT PRODUT,"
	cQuery +=        " SUM(D13A.D13_QTDEST) SALDO"
	cQuery +=   " FROM "+RetSqlName("D13")+" D13A"
	cQuery +=  " WHERE D13A.D13_FILIAL = '"+xFilial("D13")+"'"
	cQuery +=    " AND D13A.D13_TM = '499'"
	cQuery +=    " AND D13A.D13_DTESTO > '"+DTOS(dUltFech)+"'"
	cQuery +=    " AND D13A.D13_DTESTO <= '"+DTOS(dData)+"'"
	cQuery +=    " AND D13A.D13_LOCAL = '"+cArmazem+"'"
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
		cQuery += " AND D13A.D13_ENDER = '"+cEndereco+"'"
	EndIf
	If !Empty(cLoteCtl)
		cQuery += " AND D13A.D13_LOTECT = '"+cLoteCtl+"'"
	EndIf
	If !Empty(cNumLote)
		cQuery += " AND D13A.D13_NUMLOT = '"+cNumLote+"'"
	EndIf
	If !Empty(cNumserie)
		cQuery += " AND D13A.D13_NUMSER = '"+cNumserie+"'"
	EndIf
	If !Empty(cIdUnitiz)
		cQuery += " AND D13A.D13_IDUNIT = '"+cIdUnitiz+"'"
	EndIf
	If WmsX312118("D13","D13_USACAL")
		cQuery +=    " AND D13A.D13_USACAL <> '2'"
	EndIf
	cQuery +=    " AND D13A.D_E_L_E_T_ = ' '"
	cQuery +=  " GROUP BY D13A.D13_LOCAL,"
	cQuery +=           " D13A.D13_PRDORI,"
	cQuery +=           " D13A.D13_PRODUT"
	cQuery +=  " UNION ALL"
	// Saldo das saídas
	cQuery += " SELECT '999' AS NIVEL,"
	cQuery +=        " D13B.D13_LOCAL LOCAL,"
	cQuery +=        " D13B.D13_PRDORI PRDORI,"
	cQuery +=        " D13B.D13_PRODUT PRODUT,"
	cQuery +=        " SUM(D13B.D13_QTDEST) SALDO"
	cQuery +=   " FROM "+RetSqlName("D13")+" D13B"
	cQuery +=  " WHERE D13B.D13_FILIAL = '"+xFilial("D13")+"'"
	cQuery +=    " AND D13B.D13_TM = '999'"
	cQuery +=    " AND D13B.D13_DTESTO > '"+DTOS(dUltFech)+"'"
	cQuery +=    " AND D13B.D13_DTESTO <= '"+DTOS(dData)+"'"
	cQuery +=    " AND D13B.D13_LOCAL = '"+cArmazem+"'"
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
		cQuery += " AND D13B.D13_ENDER = '"+cEndereco+"'"
	EndIf
	If !Empty(cLoteCtl)
		cQuery += " AND D13B.D13_LOTECT = '"+cLoteCtl+"'"
	EndIf
	If !Empty(cNumLote)
		cQuery += " AND D13B.D13_NUMLOT = '"+cNumLote+"'"
	EndIf
	If !Empty(cNumserie)
		cQuery += " AND D13B.D13_NUMSER = '"+cNumserie+"'"
	EndIf
	If !Empty(cIdUnitiz)
		cQuery += " AND D13B.D13_IDUNIT = '"+cIdUnitiz+"'"
	EndIf
	If WmsX312118("D13","D13_USACAL")
		cQuery +=    " AND D13B.D13_USACAL <> '2'"
	EndIf
	cQuery +=    " AND D13B.D_E_L_E_T_ = ' '"
	cQuery +=  " GROUP BY D13B.D13_LOCAL,"
	cQuery +=           " D13B.D13_PRDORI,"
	cQuery +=           " D13B.D13_PRODUT"
	cQuery +=  " ORDER BY LOCAL,"
	cQuery +=           " PRDORI,"
	cQuery +=           " PRODUT,"
	cQuery +=           " NIVEL"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
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
		D11->(dbSetOrder(2)) //D11_FILIAL+D11_PRDCMP+D11_PRDORI+D11_PRODUT
		For nI := 1 To Len(aSldPeriod)
			If D11->(dbSeek(xFilial("D11")+aSldPeriod[nI][2]))
				aSldPeriod[nI][3] := aSldPeriod[nI][3] / D11->D11_QTMULT
			EndIf
		Next nI
		aSort(aSldPeriod,,,{|x,y| x[3] < y[3]})
		nSldPeriod := aSldPeriod[1][3]
	ElseIf Len(aSldPeriod) == 1
		nSldPeriod := aSldPeriod[1][3]
	EndIf

Return nSldPeriod

METHOD AnaEstoque(cLog,cCod,cLocal,cLoteCtl,cLote) CLASS WMSDTCEstoqueEndereco
Local aAreaAnt  := GetArea()
Local nSldB2    := 0
Local nSldB8    := 0
Local nSldD14   := 0
Local nKardex   := 0
Local cAliasQry := ""
Local lRastro   := Rastro(cCod)
	// Busca o saldo do SB2 para o produto normal
	SB2->(dbSetOrder(1))
	If SB2->(dbSeek(xFilial("SB2")+cCod+cLocal))
		nSldB2 := SB2->B2_QATU
	EndIf

	Self:ClearData()
	Self:oProdLote:SetProduto(cCod)
	Self:oProdLote:SetPrdOri(cCod)
	Self:oEndereco:SetArmazem(cLocal)
	nSldD14 := Self:ConsultSld(.F./*lEntrPrev*/,.F./*lSaidaPrev*/,.F./*lEmpenho*/,.F./*lBloqueio*/)
	// Inconsistencia de saldo entre SB2 e D14 por produto
	If nSldB2 <> nSldD14
		/////////////////////////////
		/////LOG INVENTARIO//////////
		MA340GrvLg("B214N -> ","06","PRODUT: "+cCod)
		MA340GrvLg("         ","06","PRDORI: "+cCod)
		MA340GrvLg("         ","06","LOCAL: "+cLocal)
		MA340GrvLg("         ","06","B2_QATU: "+cValtoChar(nSldB2))
		MA340GrvLg("         ","06","SUM(D14_QTDEST): "+cValtoChar(nSldD14))
		/////////////////////////////
		cLog := "B214N"
	EndIf

	If lRastro
		SB8->(dbSetOrder(3))
		If SB8->(dbSeek(xFilial("SB8")+cCod+cLocal+cLoteCtl+cLote))
			nSldB8 := SB8->B8_SALDO
		EndIf

		Self:oProdLote:SetLoteCtl(cLoteCtl)
		Self:oProdLote:SetNumLote(cLote)
		nSldD14 := Self:ConsultSld(.F./*lEntrPrev*/,.F./*lSaidaPrev*/,.F./*lEmpenho*/,.F./*lBloqueio*/)
		// Inconsistencia de saldo entre SB8 e D14 por produto
		If nSldB8 <> nSldD14
			/////////////////////////////
			/////LOG INVENTARIO//////////
			MA340GrvLg("B814N -> ","06","PRODUT: "+cCod)
			MA340GrvLg("         ","06","PRDORI: "+cCod)
			MA340GrvLg("         ","06","LOCAL: "+cLocal)
			MA340GrvLg("         ","06","LOTECTL: "+cLoteCtl)
			MA340GrvLg("         ","06","NUMLOTE: "+cLote)
			MA340GrvLg("         ","06","B8_SALDO: "+cValtoChar(nSldB8))
			MA340GrvLg("         ","06","SUM(D14_QTDEST): "+cValtoChar(nSldD14))
			/////////////////////////////
			cLog := "B814N"
		EndIf
	EndIf

	If Empty(cLog)
		Self:EquateKard(Nil      /*Data*/,;
						'SD7'    /*cOrigem*/,;
						cLocal   /*cArmazem*/,;
						Nil      /*cEndereco*/,;
						cCod     /*cPrdori*/,;
						cCod     /*cProduto*/,;
						Nil      /*cLoteCtl*/,;
						Nil      /*cNumLote*/,;
						Nil      /*cNumSer*/,;
						Nil      /*cIdUnit*/)
	EndIf

	If Empty(cLog)
		// Verifica se o produto é partes e busca o saldo do pai
		D11->(dbSetOrder(2)) // D11_FILIAL+D11_PRDCMP+D11_PRDORI+D11_PRODUT
		If D11->(dbSeek(xFilial("D11")+cCod))
			If SB2->(dbSeek(xFilial("SB2")+D11->D11_PRDORI+cLocal))
				// Busca o saldo do D14 do produto como parte do pai
				Self:ClearData()
				Self:oProdLote:SetProduto(cCod)
				Self:oProdLote:SetPrdOri(D11->D11_PRDORI)
				Self:oEndereco:SetArmazem(cLocal)
				nSldD14 := Self:ConsultSld(.F./*lEntrPrev*/,.F./*lSaidaPrev*/,.F./*lEmpenho*/,.F./*lBloqueio*/)
				// Quantidade do produto pai multiplicado pelo multiplo do filho para validação dos saldos
				nSldB2 := SB2->B2_QATU * D11->D11_QTMULT
				// Inconsistencia de saldo entre SB2 e D14 por produto
				If nSldB2 <> nSldD14
					/////////////////////////////
					/////LOG INVENTARIO//////////
					MA340GrvLg("B214P -> ","06","PRODUT: "+cCod)
					MA340GrvLg("         ","06","PRDORI: "+D11->D11_PRDORI)
					MA340GrvLg("         ","06","LOCAL: "+cLocal)
					MA340GrvLg("         ","06","B2_QATU: "+cValtoChar(nSldB2))
					MA340GrvLg("         ","06","SUM(D14_QTDEST): "+cValtoChar(nSldD14))
					/////////////////////////////
					cLog := "B214P"
				EndIf

				If lRastro
					SB8->(dbSetOrder(3))
					If SB8->(dbSeek(xFilial("SB8")+D11->D11_PRDORI+cLocal+cLoteCtl+cLote))
						nSldB8 := SB8->B8_SALDO * D11->D11_QTMULT
					EndIf

					Self:oProdLote:SetLoteCtl(cLoteCtl)
					Self:oProdLote:SetNumLote(cLote)
					nSldD14 := Self:ConsultSld(.F./*lEntrPrev*/,.F./*lSaidaPrev*/,.F./*lEmpenho*/,.F./*lBloqueio*/)
					// Inconsistencia de saldo entre SB8 e D14 por produto
					If nSldB8 <> nSldD14
						/////////////////////////////
						/////LOG INVENTARIO//////////
						MA340GrvLg("B814P -> ","06","PRODUT: "+cCod)
						MA340GrvLg("         ","06","PRDORI: "+D11->D11_PRDORI)
						MA340GrvLg("         ","06","LOCAL: "+cLocal)
						MA340GrvLg("         ","06","LOTECTL: "+cLoteCtl)
						MA340GrvLg("         ","06","NUMLOTE: "+cLote)
						MA340GrvLg("         ","06","B8_SALDO: "+cValtoChar(nSldB8))
						MA340GrvLg("         ","06","SUM(D14_QTDEST): "+cValtoChar(nSldD14))
						/////////////////////////////
						cLog := "B814P"
					EndIf
				EndIf

				If Empty(cLog)
					Self:EquateKard(Nil             /*Data*/,;
									'SD7'           /*cOrigem*/,;
									cLocal          /*cArmazem*/,;
									Nil             /*cEndereco*/,;
									D11->D11_PRDORI /*cPrdori*/,;
									cCod            /*cProduto*/,;
									Nil             /*cLoteCtl*/,;
									Nil             /*cNumLote*/,;
									Nil             /*cNumSer*/,;
									Nil             /*cIdUnit*/)
				EndIf
			EndIf
		EndIf
	EndIf

RestArea(aAreaAnt)
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
	cQuery := " SELECT SALDO.D14_LOCAL,"
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
	cQuery := " SELECT D14.D14_LOCAL,"
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
	aAdd(aMata650, {"C2_NUM"			, cNum      ,Nil})
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
Local aAreaAnt := GetArea()
Local aMata250 := {}
Local lRet     := .T.
Local cTm      := SuperGetMv("MV_WMSTMMT",.F.,"")
Local cQuery   := ""
Local cAliasQry:= ""
Local cRastro  := ""
Default cLote    := CriaVar("D3_LOTECTL")
Default cNumLote := CriaVar("D3_NUMLOTE")
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
		cQuery := " SELECT SD3.R_E_C_N_O_ RECNOSD3"
		cQuery +=   " FROM "+RetSqlName("SD3")+" SD3"
		cQuery +=  " WHERE SD3.D3_FILIAL = '"+xFilial("SD3")+"'"
		cQuery +=    " AND SD3.D3_OP = '"+cNum+"'"
		cQuery +=    " AND SD3.D3_COD = '"+cProduto+"'"
		cQuery +=    " AND SD3.D3_LOCAL = '"+cLocal+"'"
		cQuery +=    " AND SD3.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
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

METHOD WmsReqPart(cDocSD3,dDataInv,cNumSeq,cPrdComp,cArmazem,cEndereco,nQuant,cNumOp) CLASS WMSDTCEstoqueEndereco
Local aAreaAnt := GetArea()
Local lRet := .T.
Local aCab := {}
Local aRotAuto := {}
Local cTm := SuperGetMv("MV_WMSTMRQ",.F.,"")
Local nRateio := Posicione("D11",2,xFilial("D11")+cPrdComp,"D11_RATEIO")
Local dDtValid := Posicione("SB8",2,xFilial("SB8")+Self:oProdLote:GetNumLote()+Self:oProdLote:GetLoteCtl()+cPrdComp+cArmazem,"B8_DTVALID") // B8_FILIAL+B8_NUMLOTE+B8_LOTECTL+B8_PRODUTO+B8_LOCAL+DTOS(B8_DTVALID)

Private lMsErroAuto := .F.
Private lExecWms    := Nil
Private lDocWms     := Nil

	If Empty(cTm)
		WmsMessage(STR0007,"WmsReqPart") //"Configure o parâmetro MV_WMSTMRQ para realizar o movimento de montagem."
		DisarmTransaction()
		lRet := .F.
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
		If Self:oProdLote:HasRastro()
			aAdd(aRotAuto[01], {"D3_LOTECTL", Self:oProdLote:GetLoteCtl() ,Nil})
			aAdd(aRotAuto[01], {"D3_NUMLOTE", Self:oProdLote:GetNumLote() ,Nil})
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
	cQuery := "SELECT D14.D14_LOTECT,"
	cQuery +=       " D14.D14_NUMLOT,"
	cQuery +=       " D14.D14_NUMSER,"
	If lRastro .And. Empty(Self:oProdLote:GetLoteCtl())
		cQuery +=   " MIN(D14.D14_DTVALD) D14_DTVALD,"
		cQuery +=   " CASE WHEN (SB8.B8_EMPENHO >= (D14.D14_QTDSPR + D14.D14_QTDBLQ + D14.D14_QTDPEM + D14.D14_QTDEMP))"
		cQuery +=        " THEN (D14.D14_QTDEST - SB8.B8_EMPENHO)"
		cQuery +=        " ELSE (D14.D14_QTDEST - (D14.D14_QTDSPR + D14.D14_QTDBLQ + D14.D14_QTDPEM + D14.D14_QTDEMP)) END D14_QTDEST"
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
		cQuery +=          " SB8.B8_EMPENHO"
	EndIf
	cQuery := ChangeQuery(cQuery)
	cAliasD14 := GetNextAlias()
	dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasD14,.F.,.T.)
	TcSetField(cAliasD14,'D14_QTDEST','N',TamSx3('D14_QTDEST')[1],TamSx3('D14_QTDEST')[2])
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
Local cQuery    := ""
Local cAliasD14 := Nil
Local oEtiqUnit := Nil
Local bGetDocto := Nil

Default cIdUnit := Space(TamSx3("D14_IDUNIT")[1])
Default cTipUni := Space(TamSx3("D14_CODUNI")[1])
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
		cQuery := "SELECT D14.D14_LOCAL,"
		cQuery +=       " D14.D14_ENDER,"
		cQuery +=       " D14.D14_PRODUT,"
		cQuery +=       " D14.D14_PRDORI,"
		cQuery +=       " D14.D14_LOTECT,"
		cQuery +=       " D14.D14_NUMLOT,"
		cQuery +=       " D14.D14_NUMSER,"
		cQuery +=       " D14.D14_IDUNIT,"
		cQuery +=       " D14.D14_CODUNI,"
		cQuery +=       " D14.D14_QTDEST"
		cQuery +=  " FROM "+RetSqlName("D14")+" D14"
		cQuery += " INNER JOIN "+RetSqlName("NNR")+" NNR"
		cQuery +=    " ON NNR.NNR_FILIAL = '"+xFilial("NNR")+"'"
		cQuery +=   " AND NNR.NNR_CODIGO = D14.D14_LOCAL"
		cQuery +=   " AND NNR.NNR_AMZUNI = '1'"
		cQuery +=   " AND NNR.D_E_L_E_T_ = ''"
		cQuery += " INNER JOIN "+RetSqlName("DC8")+" DC8"
		cQuery +=    " ON DC8.DC8_FILIAL = '"+xFilial("DC8")+"'"
		cQuery +=   " AND DC8.DC8_CODEST = D14.D14_ESTFIS"
		cQuery +=   " AND DC8.DC8_TPESTR IN ('1','3','4','6')"
		cQuery +=   " AND DC8.D_E_L_E_T_ = ' '"
		cQuery += " WHERE D14.D14_FILIAL = '"+xFilial("D14")+"'"
		cQuery +=   " AND D14.D14_LOCAL = '"+cArmazem+"'"
		cQuery +=   " AND D14.D14_ENDER = '"+cEndereco+"'"
		cQuery +=   " AND D14.D14_IDUNIT = '"+Space(TamSx3("D14_IDUNIT")[1])+"'"
		cQuery +=   " AND NOT EXISTS (SELECT 1" 
		cQuery +=                     " FROM "+RetSqlName("D14")+" D14A"
		cQuery +=                    " WHERE D14A.D14_FILIAL = D14.D14_FILIAL"
		cQuery +=                      " AND D14A.D14_LOCAL = D14.D14_LOCAL"
		cQuery +=                      " AND D14A.D14_ENDER = D14.D14_ENDER"
		cQuery +=                      " AND D14A.D14_IDUNIT <> '"+Space(TamSx3("D14_IDUNIT")[1])+"'"
		cQuery +=                      " AND D14A.D_E_L_E_T_ = ' ')"
		cQuery +=   " AND (D14.D14_QTDEPR + D14.D14_QTDSPR + D14.D14_QTDBLQ + D14.D14_QTDPEM + D14.D14_QTDEMP) = 0"
		cQuery +=   " AND D14.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasD14 := GetNextAlias()
		dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasD14,.F.,.T.)
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
Realisa a retirada do armazem de loja ao realisar o faturamento
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
				// Realiza Entrada Armazem Estoque por Endereço
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
					cQuery := "SELECT D13.R_E_C_N_O_ RECNOD13"
					cQuery +=  " FROM "+RetSqlName('D13')+" D13"
					cQuery += " WHERE D13.D13_FILIAL = '"+xFilial("D13")+"'"
					cQuery +=   " AND D13.D13_DOC = '"+SD2->D2_DOC+"'"
					cQuery +=   " AND D13.D13_NUMSEQ = '"+SD2->D2_NUMSEQ+"'"
					cQuery +=   " AND D13.D13_USACAL <> '2'"
					cQuery +=   " AND D13.D_E_L_E_T_ = ' '"
					cQuery := ChangeQuery(cQuery)
					cAliasD13 := GetNextAlias()
					DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasD13,.F.,.T.)
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
/*/{Protheus.doc} EquateKard
Ajusta os registro do kardex com base na quantidade
do estoque por endereço WMS
@author Squad WMS Protheus
@since 22/11/2018
@version 1.0
@param dData, Date, Data Movimentação - Default dDatabase
@param cOrigem, Caracter, Origem do ajuste - Default 'D13'
@param cArmazem, Caracter, Armazém filtro da análise
@param cEndereco, Caracter, Endereço filtro da análise
@param cPrdOri, Caracter, Produto Origem filtro da análise
@param cProduto, Caracter, Produto filtro da análise
@param cLoteCtl, Caracter, Lote do produto filtro da análise
@param cNumLote, Caracter, SubLote do lote do produto filtro da análise
@param cNumSer, Caracter, Número de série filtro da análise
@param cIdUnit, Caracter, Unitizador filtro da análise
@param oProcess, Objeto para controlar progresso
/*/
//----------------------------------------
METHOD EquateKard(dData,cOrigem,cArmazem,cEndereco,cPrdOri,cProduto,cLoteCtl,cNumLote,cNumSer,cIdUnit,oProcess) CLASS WMSDTCEstoqueEndereco
Local lRet        := .T.
Local aTamSX3     := TamSX3("D14_QTDEST")
Local cQuery      := ""
Local cAliasQry   := Nil
Local cDocumento  := "AJT_D13"
Local nProcess    := 0
Local nAjuste     := 0
Local cDecimal    := cValtoChar(aTamSX3[1])+","+cValtoChar(aTamSX3[2])
Local lProcess    := oProcess <> Nil

Default dData     := dDataBase
Default cOrigem   := "D13"
	// Busca registros para processamento
	cAliasQry := Self:SelectKard(.T.,dData,cArmazem,cEndereco,cPrdOri,cProduto,cLoteCtl,cNumLote,cNumSer,cIdUnit)
	Do While (cAliasQry)->(!Eof())
		nAjuste++
		If lProcess
			oProcess:IncRegua1( WmsFmtMsg(STR0016 + "...",{{"[VAR01]",cValToChar(oProcess:nMeter1+1)},{"[VAR02]",cValToChar(oProcess:oMeter1:nTotal)}}) ) // Processando [VAR01]/[VAR02] registro(s)
			oProcess:SetRegua2(2)
			oProcess:IncRegua2(STR0017) // Atualizando
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
			oProcess:IncRegua2(STR0018) // Finalizando
		EndIf
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
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
@param cOrigem, Caracter, Origem do ajuste - Default 'D13'
@param cArmazem, Caracter, Armazém filtro da análise
@param cEndereco, Caracter, Endereço filtro da análise
@param cPrdOri, Caracter, Produto Origem filtro da análise
@param cProduto, Caracter, Produto filtro da análise
@param cLoteCtl, Caracter, Lote do produto filtro da análise
@param cNumLote, Caracter, SubLote do lote do produto filtro da análise
@param cNumSer, Caracter, Número de série filtro da análise
@param cIdUnit, Caracter, Unitizador filtro da análise
/*/
//----------------------------------------
METHOD SelectKard(lProcess,dData,cArmazem,cEndereco,cPrdOri,cProduto,cLoteCtl,cNumLote,cNumSer,cIdUnit) CLASS WMSDTCEstoqueEndereco
Local aTamSX3    := TamSX3("D14_QTDEST")
Local cQuery     := ""
Local cAliasQry  := Nil
Local cDecimal   := cValtoChar(aTamSX3[1])+","+cValtoChar(aTamSX3[2])

Default lProcess := .T.
Default dData     := dDataBase

	cQuery := "SELECT COUNT(*) NR_COUNT"
	If lProcess
		cQuery :=   "SELECT TOT.TOT_LOCAL,"
		cQuery +=         " TOT.TOT_ENDER,"
		cQuery +=         " TOT.TOT_PRDORI,"
		cQuery +=         " TOT.TOT_PRODUT,"
		cQuery +=         " TOT.TOT_LOTECT,"
		cQuery +=         " TOT.TOT_NUMLOT,"
		cQuery +=         " TOT.TOT_NUMSER,"
		cQuery +=         " TOT.TOT_IDUNIT,"
		cQuery +=         " CASE WHEN (TOT.TOT_QTDEST - ((TOT.TOT_QTDINI + TOT.TOT_QTDENT) - TOT.TOT_QTDSAI)) < 0"
		cQuery +=              " THEN '999'"
		cQuery +=              " ELSE '499'"
		cQuery +=              " END TOT_TM,"
		cQuery +=         " CASE WHEN (TOT.TOT_QTDEST - ((TOT.TOT_QTDINI + TOT.TOT_QTDENT) - TOT.TOT_QTDSAI)) < 0"
		cQuery +=              " THEN (TOT.TOT_QTDEST - ((TOT.TOT_QTDINI + TOT.TOT_QTDENT) - TOT.TOT_QTDSAI)) * -1"
		cQuery +=              " ELSE (TOT.TOT_QTDEST - ((TOT.TOT_QTDINI + TOT.TOT_QTDENT) - TOT.TOT_QTDSAI))"
		cQuery +=              " END TOT_QTDEST"
	EndIf
	cQuery +=    " FROM ( SELECT TOT_LOCAL,"
	cQuery +=                  " TOT_ENDER,"
	cQuery +=                  " TOT_PRDORI,"
	cQuery +=                  " TOT_PRODUT,"
	cQuery +=                  " TOT_LOTECT,"
	cQuery +=                  " TOT_NUMLOT,"
	cQuery +=                  " TOT_NUMSER,"
	cQuery +=                  " TOT_IDUNIT,"
	cQuery +=                  " CASE WHEN FCH.FCH_DATA IS NULL THEN '19800101' ELSE FCH.FCH_DATA END TOT_DATA,"
	cQuery +=                  " CAST((CASE WHEN SLD_QTDEST IS NULL THEN 0 ELSE SLD_QTDEST END) AS DECIMAL ("+cDecimal+")) TOT_QTDEST,"
	cQuery +=                  " CAST((CASE WHEN FCH.FCH_SALDO IS NULL THEN 0 ELSE FCH.FCH_SALDO END) AS DECIMAL ("+cDecimal+")) TOT_QTDINI,"
	cQuery +=                  " CAST((CASE WHEN ENT.ENT_SALDO IS NULL THEN 0 ELSE ENT.ENT_SALDO END) AS DECIMAL ("+cDecimal+")) TOT_QTDENT,"
	cQuery +=                  " CAST((CASE WHEN SAI.SAI_SALDO IS NULL THEN 0 ELSE SAI.SAI_SALDO END) AS DECIMAL ("+cDecimal+")) TOT_QTDSAI"
	cQuery +=             " FROM ( SELECT D14.D14_LOCAL TOT_LOCAL,"
	cQuery +=                           " D14.D14_ENDER TOT_ENDER,"
	cQuery +=                           " D14.D14_PRDORI TOT_PRDORI,"
	cQuery +=                           " D14.D14_PRODUT TOT_PRODUT,"
	cQuery +=                           " D14.D14_LOTECT TOT_LOTECT,"
	cQuery +=                           " D14.D14_NUMLOT TOT_NUMLOT,"
	cQuery +=                           " D14.D14_NUMSER TOT_NUMSER,"
	cQuery +=                           " D14.D14_IDUNIT TOT_IDUNIT"
	cQuery +=                      " FROM "+RetSqlName("D14")+" D14"
	cQuery +=                     " WHERE D14.D14_FILIAL = '"+xFilial("D14")+"'"
	cQuery +=                       " AND D_E_L_E_T_ = ' '"
	cQuery +=                     " UNION ALL"
	cQuery +=                    " SELECT D13.D13_LOCAL TOT_LOCAL,"
	cQuery +=                           " D13.D13_ENDER TOT_ENDER,"
	cQuery +=                           " D13.D13_PRDORI TOT_PRDORI,"
	cQuery +=                           " D13.D13_PRODUT TOT_PRODUT,"
	cQuery +=                           " D13.D13_LOTECT TOT_LOTECT,"
	cQuery +=                           " D13.D13_NUMLOT TOT_NUMLOT,"
	cQuery +=                           " D13.D13_NUMSER TOT_NUMSER,"
	cQuery +=                           " D13.D13_IDUNIT TOT_IDUNIT"
	cQuery +=                      " FROM "+RetSqlName("D13")+" D13"
	cQuery +=                     " WHERE D13.D13_FILIAL = '"+xFilial("D13")+"'"
	cQuery +=                       " AND D13.D_E_L_E_T_ = ' ' ) TOT"
	cQuery +=                      " LEFT JOIN ( SELECT D14.D14_LOCAL SLD_LOCAL,"
	cQuery +=                                         " D14.D14_ENDER SLD_ENDER,"
	cQuery +=                                         " D14.D14_PRDORI SLD_PRDORI,"
	cQuery +=                                         " D14.D14_PRODUT SLD_PRODUT,"
	cQuery +=                                         " D14.D14_LOTECT SLD_LOTECT,"
	cQuery +=                                         " D14.D14_NUMLOT SLD_NUMLOT,"
	cQuery +=                                         " D14.D14_NUMSER SLD_NUMSER,"
	cQuery +=                                         " D14.D14_IDUNIT SLD_IDUNIT,"
	cQuery +=                                         " D14.D14_QTDEST SLD_QTDEST"
	cQuery +=                                    " FROM "+RetSqlName("D14")+" D14"
	cQuery +=                                   " WHERE D14.D14_FILIAL = '"+xFilial("D14")+"'"
	cQuery +=                                     " AND D14.D_E_L_E_T_ = ' ' ) SLD"
	cQuery +=                        " ON SLD.SLD_LOCAL = TOT.TOT_LOCAL"
	cQuery +=                       " AND SLD.SLD_ENDER = TOT.TOT_ENDER"
	cQuery +=                       " AND SLD.SLD_PRDORI = TOT.TOT_PRDORI"
	cQuery +=                       " AND SLD.SLD_PRODUT = TOT.TOT_PRODUT"
	cQuery +=                       " AND SLD.SLD_LOTECT = TOT.TOT_LOTECT"
	cQuery +=                       " AND SLD.SLD_NUMLOT = TOT.TOT_NUMLOT"
	cQuery +=                       " AND SLD.SLD_NUMSER = TOT.TOT_NUMSER"
	cQuery +=                       " AND SLD.SLD_IDUNIT = TOT.TOT_IDUNIT"
	cQuery +=                      " LEFT JOIN ( SELECT MAX(D15.D15_DATA) FCH_DATA,"
	cQuery +=                                         " D15.D15_LOCAL FCH_LOCAL,"
	cQuery +=                                         " D15.D15_ENDER FCH_ENDER,"
	cQuery +=                                         " D15.D15_PRDORI FCH_PRDORI,"
	cQuery +=                                         " D15.D15_PRODUT FCH_PRODUT,"
	cQuery +=                                         " D15.D15_LOTECT FCH_LOTECT,"
	cQuery +=                                         " D15.D15_NUMLOT FCH_NUMLOT,"
	cQuery +=                                         " D15.D15_NUMSER FCH_NUMSER,"
	cQuery +=                                         " D15.D15_IDUNIT FCH_IDUNIT,"
	cQuery +=                                         " D15.D15_QINI FCH_SALDO"
	cQuery +=                                    " FROM "+RetSqlName("D15")+" D15"
	cQuery +=                                   " WHERE D15.D15_FILIAL = '"+xFilial("D15")+"'"
	cQuery +=                                     " AND D15.D15_DATA <= '"+DTOS(dData)+"'"
	cQuery +=                                     " AND D15.D_E_L_E_T_ = ' '"
	cQuery +=                                   " GROUP BY D15.D15_LOCAL,"
	cQuery +=                                            " D15.D15_ENDER,"
	cQuery +=                                            " D15.D15_PRDORI,"
	cQuery +=                                            " D15.D15_PRODUT,"
	cQuery +=                                            " D15.D15_LOTECT,"
	cQuery +=                                            " D15.D15_NUMLOT,"
	cQuery +=                                            " D15.D15_NUMSER,"
	cQuery +=                                            " D15.D15_IDUNIT,"
	cQuery +=                                            " D15.D15_QINI ) FCH"
	cQuery +=                        " ON FCH.FCH_LOCAL = TOT.TOT_LOCAL"
	cQuery +=                       " AND FCH.FCH_ENDER = TOT.TOT_ENDER"
	cQuery +=                       " AND FCH.FCH_PRDORI = TOT.TOT_PRDORI"
	cQuery +=                       " AND FCH.FCH_PRODUT = TOT.TOT_PRODUT"
	cQuery +=                       " AND FCH.FCH_LOTECT = TOT.TOT_LOTECT"
	cQuery +=                       " AND FCH.FCH_NUMLOT = TOT.TOT_NUMLOT"
	cQuery +=                       " AND FCH.FCH_NUMSER = TOT.TOT_NUMSER"
	cQuery +=                       " AND FCH.FCH_IDUNIT = TOT.TOT_IDUNIT"
	cQuery +=                      " LEFT JOIN ( SELECT D13.D13_LOCAL ENT_LOCAL,"
	cQuery +=                                         " D13.D13_ENDER ENT_ENDER,"
	cQuery +=                                         " D13.D13_PRDORI ENT_PRDORI,"
	cQuery +=                                         " D13.D13_PRODUT ENT_PRODUT,"
	cQuery +=                                         " D13.D13_LOTECT ENT_LOTECT,"
	cQuery +=                                         " D13.D13_NUMLOT ENT_NUMLOT,"
	cQuery +=                                         " D13.D13_NUMSER ENT_NUMSER,"
	cQuery +=                                         " D13.D13_IDUNIT ENT_IDUNIT,"
	cQuery +=                                         " SUM(D13.D13_QTDEST) ENT_SALDO"
	cQuery +=                                    " FROM "+RetSqlName("D13")+" D13"
	cQuery +=                                   " WHERE D13.D13_FILIAL = '"+xFilial("D13")+"'"
	cQuery +=                                     " AND D13.D13_DTESTO >= ( SELECT CASE WHEN MAX(D15.D15_DATA) IS NULL THEN '19800101' ELSE MAX(D15.D15_DATA) END D15_DATA"
	cQuery +=                                                               " FROM "+RetSqlName("D15")+" D15"
	cQuery +=                                                              " WHERE D15.D15_FILIAL = '"+xFilial("D15")+"'"
	cQuery +=                                                                " AND D15.D15_LOCAL = D13.D13_LOCAL"
	cQuery +=                                                                " AND D15.D15_ENDER = D13.D13_ENDER"
	cQuery +=                                                                " AND D15.D15_PRDORI = D13.D13_PRDORI"
	cQuery +=                                                                " AND D15.D15_PRODUT = D13.D13_PRODUT"
	cQuery +=                                                                " AND D15.D15_LOTECT = D13.D13_LOTECT"
	cQuery +=                                                                " AND D15.D15_NUMLOT = D13.D13_NUMLOT"
	cQuery +=                                                                " AND D15.D15_NUMSER = D13.D13_NUMSER"
	cQuery +=                                                                " AND D15.D15_IDUNIT = D13.D13_IDUNIT"
	cQuery +=                                                                " AND D15.D15_DATA <= '"+DTOS(dData)+"'"
	cQuery +=                                                                " AND D15.D_E_L_E_T_ = ' ')"
	cQuery +=                                     " AND D13.D13_DTESTO <= '"+DTOS(dData)+"'"
	cQuery +=                                     " AND D13.D13_TM = '499'"
	cQuery +=                                     " AND D13.D13_USACAL <> '2'"
	cQuery +=                                     " AND D13.D_E_L_E_T_ = ' '"
	cQuery +=                                   " GROUP BY D13.D13_LOCAL,"
	cQuery +=                                            " D13.D13_ENDER,"
	cQuery +=                                            " D13.D13_PRDORI,"
	cQuery +=                                            " D13.D13_PRODUT,"
	cQuery +=                                            " D13.D13_LOTECT,"
	cQuery +=                                            " D13.D13_NUMLOT,"
	cQuery +=                                            " D13.D13_NUMSER,"
	cQuery +=                                            " D13.D13_IDUNIT ) ENT"
	cQuery +=                        " ON ENT.ENT_LOCAL = TOT.TOT_LOCAL"
	cQuery +=                       " AND ENT.ENT_ENDER = TOT.TOT_ENDER"
	cQuery +=                       " AND ENT.ENT_PRDORI = TOT.TOT_PRDORI"
	cQuery +=                       " AND ENT.ENT_PRODUT = TOT.TOT_PRODUT"
	cQuery +=                       " AND ENT.ENT_LOTECT = TOT.TOT_LOTECT"
	cQuery +=                       " AND ENT.ENT_NUMLOT = TOT.TOT_NUMLOT"
	cQuery +=                       " AND ENT.ENT_NUMSER = TOT.TOT_NUMSER"
	cQuery +=                       " AND ENT.ENT_IDUNIT = TOT.TOT_IDUNIT"
	cQuery +=                      " LEFT JOIN ( SELECT D13.D13_LOCAL SAI_LOCAL,"
	cQuery +=                                         " D13.D13_ENDER SAI_ENDER,"
	cQuery +=                                         " D13.D13_PRDORI SAI_PRDORI,"
	cQuery +=                                         " D13.D13_PRODUT SAI_PRODUT,"
	cQuery +=                                         " D13.D13_LOTECT SAI_LOTECT,"
	cQuery +=                                         " D13.D13_NUMLOT SAI_NUMLOT,"
	cQuery +=                                         " D13.D13_NUMSER SAI_NUMSER,"
	cQuery +=                                         " D13.D13_IDUNIT SAI_IDUNIT,"
	cQuery +=                                         " SUM(D13.D13_QTDEST) SAI_SALDO"
	cQuery +=                                    " FROM "+RetSqlName("D13")+" D13"
	cQuery +=                                   " WHERE D13.D13_FILIAL = '"+xFilial("D13")+"'"
	cQuery +=                                     " AND D13.D13_DTESTO >= ( SELECT CASE WHEN MAX(D15.D15_DATA) IS NULL THEN '19800101' ELSE MAX(D15.D15_DATA) END D15_DATA"
	cQuery +=                                                               " FROM "+RetSqlName("D15")+" D15"
	cQuery +=                                                              " WHERE D15.D15_FILIAL = '"+xFilial("D15")+"'"
	cQuery +=                                                                " AND D15.D15_LOCAL = D13.D13_LOCAL"
	cQuery +=                                                                " AND D15.D15_ENDER = D13.D13_ENDER"
	cQuery +=                                                                " AND D15.D15_PRDORI = D13.D13_PRDORI"
	cQuery +=                                                                " AND D15.D15_PRODUT = D13.D13_PRODUT"
	cQuery +=                                                                " AND D15.D15_LOTECT = D13.D13_LOTECT"
	cQuery +=                                                                " AND D15.D15_NUMLOT = D13.D13_NUMLOT"
	cQuery +=                                                                " AND D15.D15_NUMSER = D13.D13_NUMSER"
	cQuery +=                                                                " AND D15.D15_IDUNIT = D13.D13_IDUNIT"
	cQuery +=                                                                " AND D15.D15_DATA <= '"+DTOS(dData)+"'"
	cQuery +=                                                                " AND D15.D_E_L_E_T_ = ' ')"
	cQuery +=                                     " AND D13.D13_DTESTO <= '"+DTOS(dData)+"'"
	cQuery +=                                     " AND D13.D13_TM = '999'"
	cQuery +=                                     " AND D13.D13_USACAL <> '2'"
	cQuery +=                                     " AND D13.D_E_L_E_T_ = ' '"
	cQuery +=                                   " GROUP BY D13.D13_LOCAL,"
	cQuery +=                                            " D13.D13_ENDER,"
	cQuery +=                                            " D13.D13_PRDORI,"
	cQuery +=                                            " D13.D13_PRODUT,"
	cQuery +=                                            " D13.D13_LOTECT,"
	cQuery +=                                            " D13.D13_NUMLOT,"
	cQuery +=                                            " D13.D13_NUMSER,"
	cQuery +=                                            " D13.D13_IDUNIT) SAI"
	cQuery +=                        " ON SAI.SAI_LOCAL = TOT.TOT_LOCAL"
	cQuery +=                       " AND SAI.SAI_ENDER = TOT.TOT_ENDER"
	cQuery +=                       " AND SAI.SAI_PRDORI = TOT.TOT_PRDORI"
	cQuery +=                       " AND SAI.SAI_PRODUT = TOT.TOT_PRODUT"
	cQuery +=                       " AND SAI.SAI_LOTECT = TOT.TOT_LOTECT"
	cQuery +=                       " AND SAI.SAI_NUMLOT = TOT.TOT_NUMLOT"
	cQuery +=                       " AND SAI.SAI_NUMSER = TOT.TOT_NUMSER"
	cQuery +=                       " AND SAI.SAI_IDUNIT = TOT.TOT_IDUNIT"
	cQuery +=            " GROUP BY  TOT.TOT_LOCAL,"
	cQuery +=                      " TOT.TOT_ENDER,"
	cQuery +=                      " TOT.TOT_PRDORI,"
	cQuery +=                      " TOT.TOT_PRODUT,"
	cQuery +=                      " TOT.TOT_LOTECT,"
	cQuery +=                      " TOT.TOT_NUMLOT,"
	cQuery +=                      " TOT.TOT_NUMSER,"
	cQuery +=                      " TOT.TOT_IDUNIT,"
	cQuery +=                      " FCH.FCH_DATA,"
	cQuery +=                      " SLD.SLD_QTDEST,"
	cQuery +=                      " FCH.FCH_SALDO,"
	cQuery +=                      " ENT.ENT_SALDO,"
	cQuery +=                      " SAI.SAI_SALDO) TOT"
	cQuery +=   " WHERE (TOT.TOT_QTDEST - ((TOT.TOT_QTDINI + TOT.TOT_QTDENT) - TOT.TOT_QTDSAI)) <> 0"
	If !Empty(cArmazem)
		cQuery += " AND TOT.TOT_LOCAL = '"+cArmazem+"'"
	EndIf
	If !Empty(cEndereco)
		cQuery += " AND TOT.TOT_ENDER = '"+cEndereco+"'"
	EndIf
	If !Empty(cPrdOri)
		cQuery += " AND TOT.TOT_PRDORI = '"+cPrdOri+"'"
	EndIf
	If !Empty(cProduto)
		cQuery += " AND TOT.TOT_PRODUT = '"+cProduto+"'"
	EndIf
	If !Empty(cLoteCtl)
		cQuery += " AND TOT.TOT_LOTECT = '"+cLoteCtl+"'"
	EndIf
	If !Empty(cNumLote)
		cQuery += " AND TOT.TOT_NUMLOT = '"+cNumLote+"'"
	EndIf
	If !Empty(cNumSer)
		cQuery += " AND TOT.TOT_NUMSER = '"+cNumSer+"'"
	EndIf
	If !Empty(cIdUnit)
		cQuery += " AND TOT.TOT_IDUNIT = '"+cIdUnit+"'"
	EndIf
	cQuery +=     " AND TOT.TOT_ENDER <> '"+Space(TamSX3("D14_ENDER")[1])+"'"
	If lProcess
		cQuery +=   " ORDER BY TOT.TOT_LOCAL,"
		cQuery +=            " TOT.TOT_ENDER,"
		cQuery +=            " TOT.TOT_PRDORI,"
		cQuery +=            " TOT.TOT_PRODUT,"
		cQuery +=            " TOT.TOT_LOTECT,"
		cQuery +=            " TOT.TOT_NUMLOT,"
		cQuery +=            " TOT.TOT_NUMSER,"
		cQuery +=            " TOT.TOT_IDUNIT"
	EndIf
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
Return cAliasQry
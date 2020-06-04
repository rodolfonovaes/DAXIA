#Include "Totvs.ch"
#Include "WMSDTCDistribuicaoSeparacaoItens.ch"
//----------------------------------------------
/*/{Protheus.doc} WMSCLS0018
Função para permitir que a classe seja visualizada
no inspetor de objetos
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0018()
Return Nil
//-----------------------------------------
/*/{Protheus.doc} WMSDTCDistribuicaoSeparacaoItens
Classe estrutura física
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//-----------------------------------------
CLASS WMSDTCDistribuicaoSeparacaoItens FROM LongClassName
	// Data
	DATA oDisSep
	DATA oDisPrdLot
	DATA oDisEndOri
	DATA cStatus
	DATA nQtdOri
	DATA nQtdSep
	DATA nQtdDis
	DATA nQtdLib
	DATA nTotOri
	DATA nTotSep
	DATA nTotDis
	DATA nRecno
	DATA cErro
	DATA cIdDCF
	// Method
	METHOD New() CONSTRUCTOR
	METHOD GoToD0E(nRecno)
	METHOD LoadData(nIndex)
	METHOD AssignD0J()
	METHOD DeleteD0J()
	METHOD AssignD0E()
	METHOD RecordD0E()
	METHOD UpdateD0E()
	METHOD GerAIdDCF()
	METHOD ChkQtdDis(aIdDCFs)
	// Setters
	METHOD SetCarga(cCarga)
	METHOD SetPedido(cPedido)
	METHOD SetCodDis(cCodDis)
	METHOD SetPrdOri(cPrdOrigem)
	METHOD SetProduto(cProduto)
	METHOD SetLoteCtl(cLoteCtl)
	METHOD SetNumLote(cNumLote)
	METHOD SetNumSer(cNumSer)
	METHOD SetStatus(cStatus)
	METHOD SetQtdOri(nQtdOri)
	METHOD SetQtdSep(nQtdSep)
	METHOD SetQtdDis(nQtdDis)
	METHOD SetIdDCF(cIdDCF)
	// Getters
	METHOD GetCarga()
	METHOD GetPedido()
	METHOD GetCodDis()
	METHOD GetPrdOri()
	METHOD GetProduto()
	METHOD GetLoteCtl()
	METHOD GetNumLote()
	METHOD GetNumSer()
	METHOD GetStatus()
	METHOD GetQtdOri()
	METHOD GetQtdSep()
	METHOD GetQtdDis()
	METHOD GetTotOri()
	METHOD GetTotSep()
	METHOD GetTotDis()
	METHOD GetIdDCF()
	METHOD GetRecno()
	METHOD GetErro()
	METHOD CalcDisSep(nAcao)
	METHOD RevDisSep(nQtdOri,nQtdSep)
	METHOD HasQtdDis()
	METHOD Destroy()
	METHOD UpdQtdParc(nQtdQuebra,lBxEmp)
	METHOD DelDisSep()
	METHOD GetQtMxPai()
ENDCLASS
//-----------------------------------------
/*/{Protheus.doc} New
Método construtor
@author alexsander.correa
@since 27/02/2015
@version 1.0
/*/
//-----------------------------------------
METHOD New() CLASS WMSDTCDistribuicaoSeparacaoItens
	Self:oDisSep    := WMSDTCDistribuicaoSeparacao():New()
	Self:oDisPrdLot := WMSDTCProdutoLote():New()
	Self:oDisEndOri := WMSDTCEndereco():New()
	Self:cStatus    := "1"
	Self:nQtdOri    := 0
	Self:nQtdSep    := 0
	Self:nQtdDis    := 0
	Self:nQtdLib    := 0
	Self:nTotOri    := 0
	Self:nTotSep    := 0
	Self:nTotDis    := 0
	Self:nRecno     := 0
	Self:cErro      := ""
	Self:cIdDCF     := ""
Return

METHOD Destroy() CLASS WMSDTCDistribuicaoSeparacaoItens
	FreeObj(Self)
Return

//----------------------------------------
/*/{Protheus.doc} GoToD0E
Posicionamento para atualização das propriedades
@author felipe.m
@since 23/12/2014
@version 1.0
@param nRecnoD0E, numérico, (Descrição do parâmetro)
/*/
//----------------------------------------
METHOD GoToD0E(nRecno) CLASS WMSDTCDistribuicaoSeparacaoItens
	Self:nRecno := nRecno
Return Self:LoadData(0)
//-----------------------------------------
/*/{Protheus.doc} LoadData
Carregamento dos dados D0E
@author alexsander.correa
@since 27/02/2015
@version 1.0
@param nIndex, numérico, (Descrição do parâmetro)
/*/
//-----------------------------------------
METHOD LoadData(nIndex) CLASS WMSDTCDistribuicaoSeparacaoItens
Local aAreaAnt    := GetArea()
Local lRet        := .T.
Local cQuery      := ""
Local cAliasD0E   := ""
Local aD0E_QTDORI := TamSx3("D0E_QTDORI")
Local aD0E_QTDSEP := TamSx3("D0E_QTDSEP")
Local aD0E_QTDDIS := TamSx3("D0E_QTDDIS")
Local aAreaD0E    := D0E->(GetArea())
Default nIndex := 1
	Do Case
		Case nIndex == 0
			If Empty(Self:nRecno)
				lRet := .F.
			EndIf
		Case nIndex == 1 // D0E_FILIAL+D0E_CODDIS+D0E_CARGA+D0E_PEDIDO+D0E_PRDORI+D0E_PRODUT+D0E_LOTECT+D0E_NUMLOT+D0E_LOCORI
			If Empty(Self:oDisSep:GetCodDis()) .Or. Empty(Self:oDisSep:GetPedido()) .Or. Empty(Self:oDisEndOri:GetArmazem()) .Or. Empty(Self:oDisPrdLot:GetPrdOri()) .Or. Empty(Self:oDisPrdLot:GetProduto())
				lRet := .F.
			EndIf
		Case nIndex == 3 //D0E_FILIAL+D0E_CARGA+D0E_PEDIDO+D0E_PRDORI+D0E_LOTECT+D0E_NUMLOT
			If Empty(Self:oDisSep:GetPedido()) .Or. Empty(Self:oDisPrdLot:GetPrdOri())
				lRet := .F.
			EndIf
		Otherwise
			lRet := .F.
	EndCase
	If !lRet
		Self:cErro := STR0002 // Dados para busca não foram informados!
	Else
		cQuery := " SELECT D0E.D0E_CODDIS,"
		cQuery +=        " D0E.D0E_CARGA,"
		cQuery +=        " D0E.D0E_PEDIDO,"
		cQuery +=        " D0E.D0E_STATUS,"
		cQuery +=        " D0E.D0E_LOCORI,"
		cQuery +=        " D0E.D0E_ENDORI,"
		cQuery +=        " D0E.D0E_PRDORI,"
		cQuery +=        " D0E.D0E_PRODUT,"
		cQuery +=        " D0E.D0E_LOTECT,"
		cQuery +=        " D0E.D0E_NUMLOT,"
		cQuery +=        " D0E.D0E_QTDORI,"
		cQuery +=        " D0E.D0E_QTDSEP,"
		cQuery +=        " D0E.D0E_QTDDIS,"
		cQuery +=        " D0E.R_E_C_N_O_ RECNOD0E"
		cQuery +=   " FROM "+RetSqlName("D0E")+" D0E"
		cQuery +=  " WHERE D0E.D0E_FILIAL = '"+xFilial("D0E")+"'"
		Do Case
			Case nIndex == 0
				cQuery += " AND D0E.R_E_C_N_O_ = " + AllTrim(Str(Self:nRecno))
			Case nIndex == 1 // D0E_FILIAL+D0E_CODDIS+D0E_CARGA+D0E_PEDIDO+D0E_PRDORI+D0E_PRODUT+D0E_LOTECT+D0E_NUMLOT
				cQuery += " AND D0E.D0E_CODDIS = '" + Self:GetCodDis() + "'"
				If !Empty(Self:GetCarga()) .And. WmsCarga(Self:GetCarga())
					cQuery += " AND D0E.D0E_CARGA = '" + Self:GetCarga() + "'"
				EndIf
				cQuery += " AND D0E.D0E_PEDIDO = '" + Self:GetPedido() + "'"
				cQuery += " AND D0E.D0E_LOCORI = '" + Self:oDisEndOri:GetArmazem() + "'"
				cQuery += " AND D0E.D0E_PRDORI = '" + Self:oDisPrdLot:GetPrdOri() + "'"
				cQuery += " AND D0E.D0E_PRODUT = '" + Self:oDisPrdLot:GetProduto() + "'"
				If !Empty(Self:oDisPrdLot:GetLoteCtl())
					cQuery += " AND D0E.D0E_LOTECT = '" + Self:oDisPrdLot:GetLoteCtl() + "'"
				EndIf
				If !Empty(Self:oDisPrdLot:GetNumLote())
					cQuery += " AND D0E.D0E_NUMLOT = '" + Self:oDisPrdLot:GetNumLote()+ "'"
				EndIf
			Case nIndex == 3 //D0E_FILIAL+D0E_CARGA+D0E_PEDIDO+D0E_PRDORI+D0E_LOTECT+D0E_NUMLOT
				If !Empty(Self:GetCarga()) .And. WmsCarga(Self:GetCarga())
					cQuery += " AND D0E.D0E_CARGA = '" + Self:GetCarga() + "'"
				EndIf
				cQuery += " AND D0E.D0E_PEDIDO = '" + Self:GetPedido() + "'"
				cQuery += " AND D0E.D0E_PRDORI = '" + Self:oDisPrdLot:GetPrdOri() + "'"
				cQuery += " AND D0E.D0E_PRODUT = '" + Self:oDisPrdLot:GetProduto() + "'"
				If !Empty(Self:oDisPrdLot:GetLoteCtl())
					cQuery += " AND D0E.D0E_LOTECT = '" + Self:oDisPrdLot:GetLoteCtl() + "'"
				EndIf
				If !Empty(Self:oDisPrdLot:GetNumLote())
					cQuery += " AND D0E.D0E_NUMLOT = '" + Self:oDisPrdLot:GetNumLote()+ "'"
				EndIf
		EndCase
		cQuery +=   " AND D0E.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasD0E := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasD0E,.F.,.T.)
		TCSetField(cAliasD0E,'D0E_QTDORI','N',aD0E_QTDORI[1],aD0E_QTDORI[2])
		TCSetField(cAliasD0E,'D0E_QTDSEP','N',aD0E_QTDSEP[1],aD0E_QTDSEP[2])
		TCSetField(cAliasD0E,'D0E_QTDDIS','N',aD0E_QTDDIS[1],aD0E_QTDDIS[2])
		If (lRet := (cAliasD0E)->(!Eof()))
			Self:SetCodDis((cAliasD0E)->D0E_CODDIS)
			Self:SetCarga((cAliasD0E)->D0E_CARGA)
			Self:SetPedido((cAliasD0E)->D0E_PEDIDO)
			Self:oDisEndOri:SetArmazem((cAliasD0E)->D0E_LOCORI)
			// Montagem
			Self:oDisSep:oDisEndDes:SetArmazem((cAliasD0E)->D0E_LOCORI)
			Self:oDisSep:LoadData()
			// Endereço origem
			Self:oDisEndOri:SetEnder((cAliasD0E)->D0E_ENDORI)
			Self:oDisEndOri:LoadData()
			// Busca dados lote/produto
			Self:oDisPrdLot:SetPrdOri((cAliasD0E)->D0E_PRDORI)
			Self:oDisPrdLot:SetProduto((cAliasD0E)->D0E_PRODUT)
			Self:oDisPrdLot:SetLoteCtl((cAliasD0E)->D0E_LOTECT)
			Self:oDisPrdLot:SetNumLote((cAliasD0E)->D0E_NUMLOT)
			Self:oDisPrdLot:SetNumSer("")
			Self:oDisPrdLot:LoadData()
			// Busca dados endereco origem
			// Dados complementares
			Self:cStatus  := (cAliasD0E)->D0E_STATUS
			Self:nQtdOri  := (cAliasD0E)->D0E_QTDORI
			Self:nQtdSep  := (cAliasD0E)->D0E_QTDSEP
			Self:nQtdDis  := (cAliasD0E)->D0E_QTDDIS
			Self:nRecno   := (cAliasD0E)->RECNOD0E
		EndIf
		(cAliasD0E)->(dbCloseArea())
	EndIf
	RestArea(aAreaD0E)
	RestArea(aAreaAnt)
Return lRet
//-----------------------------------
// Setters
//-----------------------------------
METHOD SetCarga(cCarga) CLASS WMSDTCDistribuicaoSeparacaoItens
	Self:oDisSep:SetCarga(cCarga)
Return

METHOD SetPedido(cPedido) CLASS WMSDTCDistribuicaoSeparacaoItens
	Self:oDisSep:SetPedido(cPedido)
Return

METHOD SetCodDis(cCodDis) CLASS WMSDTCDistribuicaoSeparacaoItens
	Self:oDisSep:SetCodDis(cCodDis)
Return

METHOD SetPrdOri(cPrdOrigem) CLASS WMSDTCDistribuicaoSeparacaoItens
	Self:oDisPrdLot:SetPrdOri(cPrdOrigem)
Return

METHOD SetProduto(cProduto) CLASS WMSDTCDistribuicaoSeparacaoItens
	Self:oDisPrdLot:SetProduto(cProduto)
Return

METHOD SetLoteCtl(cLoteCtl) CLASS WMSDTCDistribuicaoSeparacaoItens
	Self:oDisPrdLot:SetLoteCtl(cLoteCtl)
Return

METHOD SetNumLote(cNumLote) CLASS WMSDTCDistribuicaoSeparacaoItens
	Self:oDisPrdLot:SetNumLote(cNumLote)
Return

METHOD SetNumSer(cNumSer) CLASS WMSDTCDistribuicaoSeparacaoItens
	Self:oDisPrdLot:SetNumSer(cNumSer)
Return

METHOD SetStatus(cStatus) CLASS WMSDTCDistribuicaoSeparacaoItens
	Self:cStatus := PadR(cStatus, TamSx3("D0E_STATUS")[1])
Return

METHOD SetQtdOri(nQtdOri) CLASS WMSDTCDistribuicaoSeparacaoItens
	Self:nQtdOri := nQtdOri
Return

METHOD SetQtdSep(nQtdSep) CLASS WMSDTCDistribuicaoSeparacaoItens
	Self:nQtdSep := nQtdSep
Return

METHOD SetQtdDis(nQtdDis) CLASS WMSDTCDistribuicaoSeparacaoItens
	Self:nQtdDis := nQtdDis
Return

METHOD SetIdDCF(cIdDCF) CLASS WMSDTCDistribuicaoSeparacaoItens
	Self:cIdDCF := cIdDCF
Return
//-----------------------------------
// Getters
//-----------------------------------
METHOD GetCarga() CLASS WMSDTCDistribuicaoSeparacaoItens
Return Self:oDisSep:GetCarga()

METHOD GetPedido() CLASS WMSDTCDistribuicaoSeparacaoItens
Return Self:oDisSep:GetPedido()

METHOD GetCodDis() CLASS WMSDTCDistribuicaoSeparacaoItens
Return Self:oDisSep:GetCodDis()

METHOD GetPrdOri() CLASS WMSDTCDistribuicaoSeparacaoItens
Return Self:oDisPrdLot:GetPrdOri()

METHOD GetProduto() CLASS WMSDTCDistribuicaoSeparacaoItens
Return Self:oDisPrdLot:GetProduto()

METHOD GetLoteCtl() CLASS WMSDTCDistribuicaoSeparacaoItens
Return Self:oDisPrdLot:GetLoteCtl()

METHOD GetNumLote() CLASS WMSDTCDistribuicaoSeparacaoItens
Return Self:oDisPrdLot:GetNumLote()

METHOD GetNumSer() CLASS WMSDTCDistribuicaoSeparacaoItens
Return Self:oDisPrdLot:GetNumSer()

METHOD GetStatus() CLASS WMSDTCDistribuicaoSeparacaoItens
Return Self:cStatus

METHOD GetQtdOri() CLASS WMSDTCDistribuicaoSeparacaoItens
Return  Self:nQtdOri

METHOD GetQtdSep() CLASS WMSDTCDistribuicaoSeparacaoItens
Return Self:nQtdSep

METHOD GetQtdDis() CLASS WMSDTCDistribuicaoSeparacaoItens
Return Self:nQtdDis

METHOD GetTotOri() CLASS WMSDTCDistribuicaoSeparacaoItens
Return  Self:nTotOri

METHOD GetTotSep() CLASS WMSDTCDistribuicaoSeparacaoItens
Return Self:nTotSep

METHOD GetTotDis() CLASS WMSDTCDistribuicaoSeparacaoItens
Return Self:nTotDis

METHOD GetIdDCF() CLASS WMSDTCDistribuicaoSeparacaoItens
Return Self:cIdDCF

METHOD GetRecno() CLASS WMSDTCDistribuicaoSeparacaoItens
Return Self:nRecno

METHOD GetErro() CLASS WMSDTCDistribuicaoSeparacaoItens
Return Self:cErro

//-----------------------------------------
/*/{Protheus.doc} AssignD0J
Cria registro na tabela de Dist. Separação x OS

@author  felipe.m
@since   02/09/2016
@version 1.0
/*/
//-----------------------------------------
METHOD AssignD0J() CLASS WMSDTCDistribuicaoSeparacaoItens
	D0J->(dbSetOrder(1)) // D0J_FILIAL+D0J_CODDIS+D0J_IDDCF
	If !D0J->(dbSeek(xFilial('D0J')+Self:GetCodDis()+Self:GetIdDCF()))
		RecLock('D0J',.T.)
		D0J->D0J_FILIAL := xFilial('D0J')
		D0J->D0J_CODDIS := Self:GetCodDis()
		D0J->D0J_IDDCF  := Self:GetIdDCF()
		D0J->(MsUnlock())
	EndIf
Return .T.

METHOD AssignD0E() CLASS WMSDTCDistribuicaoSeparacaoItens
Local lRet    := .T.
Local nQtdOri := Self:nQtdOri
Local aAreaAnt:= GetArea()
	// Verifica se há montagem cadastra
	If Self:oDisSep:LoadData()
		// Verifica se montagem está liberada
		If Self:oDisSep:ChkPedFat()
			// Cria nova montagem
			If !Self:oDisSep:RecordD0D()
				lRet := .T.
				Self:cErro := Self:oDisSep:GetErro()
			EndIf
		EndIf
	Else
		// Cria nova montagem
		If !Self:oDisSep:RecordD0D()
			lRet := .F.
			Self:cErro := Self:oDisSep:GetErro()
		EndIf
	EndIf

	If lRet
		// Atualiza codigo da montagem
		If Self:LoadData()
			Self:nQtdOri += nQtdOri
			lRet := Self:UpdateD0E()
		Else
			lRet := Self:RecordD0E()
		EndIf
		If lRet
			Self:AssignD0J()
		EndIf
	EndIf
	RestArea(aAreaAnt)
Return lRet

METHOD RecordD0E() CLASS WMSDTCDistribuicaoSeparacaoItens
Local lRet   := .T.
	Self:cStatus := "1"
	DbSelectArea("D0E")
	D0E->(DbSetOrder(1)) // D0E_FILIAL+D0E_CODDIS+D0E_CARGA+D0E_PEDIDO+D0E_LOCORI+D0E_PRDORI+D0E_PRODUT+D0E_LOTECT+D0E_NUMLOT
	If !D0E->(dbSeek(xFilial("D0E")+Self:GetCodDis()+Self:GetCarga()+Self:GetPedido()+Self:oDisEndOri:GetArmazem()+Self:GetPrdOri()+Self:GetProduto()+Self:GetLoteCtl()+Self:GetNumLote()))
		Reclock('D0E',.T.)
		D0E->D0E_Filial := xFilial("D0E")
		D0E->D0E_CODDIS := Self:GetCodDis()
		D0E->D0E_CARGA  := Self:GetCarga()
		D0E->D0E_PEDIDO := Self:GetPedido()
		D0E->D0E_LOCORI := Self:oDisEndOri:GetArmazem()
		D0E->D0E_ENDORI := Self:oDisEndOri:GetEnder()
		D0E->D0E_PRDORI := Self:GetPrdOri()
		D0E->D0E_PRODUT := Self:GetProduto()
		D0E->D0E_LOTECT := Self:GetLoteCtl()
		D0E->D0E_NUMLOT := Self:GetNumLote()
		D0E->D0E_QTDORI := Self:nQtdOri
		D0E->D0E_QTDSEP := Self:nQtdSep
		D0E->D0E_QTDDIS := Self:nQtdDis
		D0E->D0E_STATUS := Self:cStatus
		D0E->(MsUnLock())
		// Grava recno
		Self:nRecno := D0E->(Recno())
		// Analise se produto é componente
		If D0E->D0E_PRODUT <> D0E->D0E_PRDORI
			If !D0E->(dbSeek(xFilial("D0E")+Self:GetCodDis()+Self:GetCarga()+Self:GetPedido()+Self:oDisEndOri:GetArmazem()+Self:GetPrdOri()+Self:GetPrdOri()+Self:GetLoteCtl()+Self:GetNumLote()))
				RecLock('D0E', .T.)
				D0E->D0E_Filial := xFilial("D0E")
				D0E->D0E_CODDIS := Self:GetCodDis()
				D0E->D0E_CARGA  := Self:GetCarga()
				D0E->D0E_PEDIDO := Self:GetPedido()
				D0E->D0E_LOCORI := Self:oDisEndOri:GetArmazem()
				D0E->D0E_ENDORI := Self:oDisEndOri:GetEnder()
				D0E->D0E_PRDORI := Self:GetPrdOri()
				D0E->D0E_PRODUT := Self:GetPrdOri()
				D0E->D0E_LOTECT := Self:GetLoteCtl()
				D0E->D0E_NUMLOT := Self:GetNumLote()
				D0E->D0E_STATUS := Self:cStatus
				D0E->(MsUnLock())
			EndIf
			Self:CalcDisSep(1)
			RecLock('D0E', .F.)
			D0E->D0E_QTDORI := Self:nTotOri
			D0E->D0E_QTDSEP := Self:nTotSep
			D0E->D0E_QTDDIS := Self:nTotDis
			D0E->D0E_STATUS := Self:cStatus
			D0E->(MsUnLock())
		EndIf

		If lRet
			// Atualiza quantidade original da montagem da carga
			If Self:CalcDisSep(2)
				Self:oDisSep:SetQtdOri(Self:nTotOri)
				If !Self:oDisSep:UpdateD0D()
					lRet := .F.
					Self:cErro := Self:oDisSep:GetErro()
				EndIf
			EndIf
		EndIf

	Else
		lRet := .F.
		Self:cErro := STR0003 // Chave duplicada!
	EndIf
Return lRet

METHOD UpdateD0E() CLASS WMSDTCDistribuicaoSeparacaoItens
Local lRet    := .T.
Local cStatus := ""
	If !Empty(Self:GetRecno())
		D0E->(dbGoTo( Self:GetRecno() ))
		// Status
		If QtdComp(Self:nQtdOri) == QtdComp(Self:nQtdDis)
			Self:cStatus := "2" // Em Andamente
		Else
			Self:cStatus := "1" // Não Iniciado
		EndIf
		// Grava DCF
		RecLock('D0E', .F.)
		D0E->D0E_QTDORI := Self:nQtdOri
		D0E->D0E_QTDSEP := Self:nQtdSep
		D0E->D0E_QTDDIS := Self:nQtdDis
		D0E->D0E_STATUS := Self:cStatus
		D0E->(MsUnLock())
		If D0E->D0E_PRODUT <> D0E->D0E_PRDORI
			D0E->(DbSetOrder(1)) //D0E_FILIAL+D0E_CODDIS+D0E_CARGA+D0E_PEDIDO+D0E_LOCORI+D0E_PRDORI+D0E_PRODUT+D0E_LOTECT+D0E_NUMLOT
			If D0E->(dbSeek(xFilial("D0E")+D0E_CODDIS+D0E_CARGA+D0E_PEDIDO+D0E_LOCORI+D0E_PRDORI+D0E_PRDORI+D0E_LOTECT+D0E_NUMLOT))
				Self:CalcDisSep(1)
				// Se está aumentando a quantidade distribuída
				If QtdComp(Self:nTotDis) == QtdComp(Self:nTotOri)
					cStatus := "2"
				Else
					cStatus := "1"
				EndIf
				RecLock('D0E', .F.)
				D0E->D0E_QTDORI := Self:nTotOri
				D0E->D0E_QTDSEP := Self:nTotSep
				D0E->D0E_QTDDIS := Self:nTotDis
				D0E->D0E_STATUS := cStatus
				D0E->(MsUnLock())
			EndIf
		EndIf

		If lRet
			// Atualiza quantidade original da montagem da carga
			If Self:CalcDisSep(2)
				Self:oDisSep:SetQtdOri(Self:nTotOri)
				Self:oDisSep:SetQtdSep(Self:nTotSep)
				Self:oDisSep:SetQtdDis(Self:nTotDis)
				If !Self:oDisSep:UpdateD0D()
					lRet := .F.
					Self:cErro := Self:oDisSep:GetErro()
				EndIf
			EndIf
		EndIf

	Else
		lRet := .F.
		Self:cErro := STR0004 // Dados não encontrados!
	EndIf
Return lRet

METHOD CalcDisSep(nAcao) CLASS WMSDTCDistribuicaoSeparacaoItens
Local lRet      := .T.
Local aTamSx3   := TamSx3("D0E_QTDORI")
Local cAliasD0E := ""
Local cQuery    := ""
Local aAreaAnt  := GetArea()

Default nAcao := 1
	// ----------nAcao-----------
	// [1] - Totalizador do item da distribuição da separação
	// [2] - Totalizador da distribuição da separação
	Self:nTotOri := 0
	Self:nTotSep := 0
	Self:nTotDis := 0

	cQuery := " SELECT "
	If nAcao == 1
		cQuery += "Min(D0E.D0E_QTDORI / CASE WHEN D11.D11_QTMULT IS NOT NULL THEN D11.D11_QTMULT ELSE 1 END) D0E_QTDORI,"
		cQuery += "Min(D0E.D0E_QTDSEP / CASE WHEN D11.D11_QTMULT IS NOT NULL THEN D11.D11_QTMULT ELSE 1 END) D0E_QTDSEP,"
		cQuery += "Min(D0E.D0E_QTDDIS / CASE WHEN D11.D11_QTMULT IS NOT NULL THEN D11.D11_QTMULT ELSE 1 END) D0E_QTDDIS"
	Else
		cQuery += "Sum(D0E.D0E_QTDORI) D0E_QTDORI,"
		cQuery += "Sum(D0E.D0E_QTDSEP) D0E_QTDSEP,"
		cQuery += "Sum(D0E.D0E_QTDDIS) D0E_QTDDIS"
	EndIf
	cQuery +=   " FROM "+RetSqlName("D0E")+" D0E"
	If nAcao == 1
		cQuery += " LEFT JOIN "+RetSqlName("D11")+" D11"
		cQuery +=   " ON D11_FILIAL = '"+xFilial("D11")+"'"
		cQuery +=  " AND D11.D11_PRDORI = D0E.D0E_PRDORI"
		cQuery +=  " AND D11.D11_PRDCMP = D0E.D0E_PRODUT"
		cQuery +=  " AND D11.D_E_L_E_T_ = ' '"
	EndIf
	cQuery +=  " WHERE D0E.D0E_FILIAL = '"+xFilial("D0E")+"'"
	cQuery +=    " AND D0E.D0E_CODDIS = '"+Self:oDisSep:GetCodDis()+"'"
	cQuery +=    " AND D0E.D0E_CARGA  = '"+Self:oDisSep:GetCarga()+"'"
	cQuery +=    " AND D0E.D0E_PEDIDO = '"+Self:oDisSep:GetPedido()+"'"
	cQuery +=    " AND D0E.D0E_LOCORI = '"+ Self:oDisEndOri:GetArmazem()+ "'"
	If nAcao == 1
		cQuery +=    " AND D0E.D0E_PRDORI = '"+Self:GetPrdOri()+"'"
		cQuery +=    " AND D0E.D0E_LOTECT = '"+Self:oDisPrdLot:GetLoteCtl()+"'"
		cQuery +=    " AND D0E.D0E_NUMLOT = '"+Self:oDisPrdLot:GetNumLote()+"'"
		cQuery +=    " AND D0E.D0E_PRODUT <> D0E.D0E_PRDORI"
	Else
		cQuery +=    " AND D0E.D0E_PRDORI = D0E.D0E_PRODUT"
	EndIf
	cQuery +=    " AND D0E.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasD0E := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasD0E,.F.,.T.)
	TcSetField(cAliasD0E,'D0E_QTDORI','N',aTamSX3[1],aTamSX3[2])
	TcSetField(cAliasD0E,'D0E_QTDSEP','N',aTamSX3[1],aTamSX3[2])
	TcSetField(cAliasD0E,'D0E_QTDDIS','N',aTamSX3[1],aTamSX3[2])
	If (cAliasD0E)->(!Eof() )
		Self:nTotOri := NoRound((cAliasD0E)->D0E_QTDORI,0)
		Self:nTotSep := NoRound((cAliasD0E)->D0E_QTDSEP,0)
		Self:nTotDis := NoRound((cAliasD0E)->D0E_QTDDIS,0)
	Else
		lRet := .F.
	EndIf
	(cAliasD0E)->(dbCloseArea())
	RestArea(aAreaAnt)
Return lRet

METHOD RevDisSep(nQtdOri,nQtdSep) CLASS WMSDTCDistribuicaoSeparacaoItens
Local lRet := .T.
Local cStatus := ""

	If QtdComp(Self:nQtdOri-nQtdOri) <= 0
		D0E->(dbGoTo( Self:GetRecno() ))
		RecLock('D0E', .F.)
		D0E->(dbDelete())
		D0E->(MsUnLock())
		If D0E->D0E_PRODUT <> D0E->D0E_PRDORI
			D0E->(DbSetOrder(1)) // D0E_FILIAL+D0E_CODDIS+D0E_CARGA+D0E_PEDIDO+D0E_LOCORI+D0E_PRDORI+D0E_PRODUT+D0E_LOTECT+D0E_NUMLOT
			If D0E->(dbSeek(xFilial("D0E")+D0E_CODDIS+D0E_CARGA+D0E_PEDIDO+D0E_LOCORI+D0E_PRDORI+D0E_PRDORI+D0E_LOTECT+D0E_NUMLOT))
				Self:CalcDisSep(1)
				RecLock('D0E', .F.)
				If QtdComp(Self:nTotOri) <= 0
					D0E->(dbDelete())
				Else
					// Se está aumentando a quantidade distribuída
					If QtdComp(Self:nTotDis) == QtdComp(Self:nTotOri)
						cStatus := "2"
					Else
						cStatus := "1"
					EndIf
					RecLock('D0E', .F.)
					D0E->D0E_QTDORI := Self:nTotOri
					D0E->D0E_QTDSEP := Self:nTotSep
					D0E->D0E_QTDDIS := Self:nTotDis
					D0E->D0E_STATUS := cStatus
				EndIf
				D0E->(MsUnLock())
			EndIf
		EndIf
		// Recalcula a quantidade original da capa
		Self:CalcDisSep(2)
		If QtdComp(Self:nTotOri) <= 0
			lRet := Self:oDisSep:ExcludeD0D()
			// Delete D0I
			If lRet
				Self:DeleteD0J()
			EndIf
		Else
			Self:oDisSep:SetQtdOri(Self:nTotOri)
			Self:oDisSep:SetQtdSep(Self:nTotSep)
			Self:oDisSep:SetQtdDis(Self:nTotDis)
			lRet := Self:oDisSep:UpdateD0D()
		EndIf
	Else
		Self:nQtdOri -= nQtdOri
		Self:nQtdSep -= nQtdSep
		lRet := Self:UpdateD0E()
	EndIf
	If !lRet
		Self:cErro := STR0005 // Problemas no processo de estorno da distribuição da separação (RevDisSep)!
	EndIf
Return lRet

METHOD HasQtdDis() CLASS WMSDTCDistribuicaoSeparacaoItens
Local lRet      := .F.
Local aTamSx3   := TamSx3("D0E_QTDDIS")
Local cAliasD0E := ""
Local cQuery    := ""
Local aAreaAnt  := GetArea()

	aTamSx3   := TamSx3("D0E_QTDORI")
	cQuery := " SELECT Sum(D0E.D0E_QTDDIS) D0E_QTDDIS"
	cQuery +=   " FROM "+RetSqlName("D0E")+" D0E"
	cQuery +=  " WHERE D0E.D0E_FILIAL = '"+xFilial("D0E")+"'"
	cQuery +=    " AND D0E.D0E_CODDIS = '"+Self:oDisSep:GetCodDis()+"'"
	cQuery +=    " AND D0E.D0E_CARGA  = '"+Self:oDisSep:GetCarga()+"'"
	cQuery +=    " AND D0E.D0E_PEDIDO = '"+Self:oDisSep:GetPedido()+"'"
	CQuery +=    " AND D0E.D0E_LOCORI = '"+Self:oDisEndOri:GetArmazem()+"'"
	cQuery +=    " AND D0E.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasD0E := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasD0E,.F.,.T.)
	TcSetField(cAliasD0E,'D0E_QTDDIS','N',aTamSX3[1],aTamSX3[2])
	If (cAliasD0E)->(!Eof() )
		lRet := QtdComp((cAliasD0E)->D0E_QTDDIS) > 0
	EndIf
	(cAliasD0E)->(dbCloseArea())
	RestArea(aAreaAnt)
Return lRet

METHOD DelDisSep() CLASS WMSDTCDistribuicaoSeparacaoItens
Local lRet      := .T.
Local cAliasD0E := ""
	// Exclui DCT
	cQuery := " SELECT D0E.R_E_C_N_O_ RECNOD0E"
	cQuery +=   " FROM "+RetSqlName("D0E")+" D0E"
	cQuery +=  " WHERE D0E.D0E_FILIAL = '"+xFilial("D0E")+"'"
	cQuery +=    " AND D0E.D0E_CARGA = '"+Self:oDisSep:GetCarga()+"'"
	cQuery +=    " AND D0E.D0E_PEDIDO = '"+Self:oDisSep:GetPedido()+"'"
	cQuery +=    " AND D0E.D0E_CODDIS = '"+Self:oDisSep:GetCodDis()+"'"
	If Self:GetProduto() != Self:GetPrdOri()
		cQuery +=    " AND D0E.D0E_PRDORI = '"+Self:GetPrdOri()+"'"
	Else
		cQuery +=    " AND D0E.D0E_PRODUT = '"+Self:GetProduto()+"'"
		cQuery +=    " AND D0E.D0E_PRDORI = '"+Self:GetPrdOri()+"'"
	EndIf
	cQuery +=    " AND D0E.D0E_QTDORI <= 0"
	cQuery +=    " AND D0E.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasD0E := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasD0E,.F.,.T.)
	Do While (cAliasD0E)->(!Eof())
		D0E->(dbGoTo((cAliasD0E)->RECNOD0E))
		RecLock('D0E', .F.)
		D0E->(dbDelete())
		D0E->(MsUnLock())
		(cAliasD0E)->(dbSkip())
	EndDo
	(cAliasD0E)->(dbCloseArea())
	// Recalcula D0D cada vez que um D0E é excluído, excluindo quando chega a 0
	Self:CalcDisSep(2)
	If QtdComp(Self:nTotOri) <= 0
		lRet := Self:oDisSep:ExcludeD0D()
		// Delete D0I
		If lRet
			Self:DeleteD0J()
		EndIf
	Else
		Self:oDisSep:SetQtdOri(Self:nTotOri)
		Self:oDisSep:SetQtdSep(Self:nTotSep)
		Self:oDisSep:SetQtdDis(Self:nTotDis)
		lRet := Self:oDisSep:UpdateD0D()
	EndIf
Return lRet

METHOD UpdQtdParc(nQtdQuebra,lBxEmp) CLASS WMSDTCDistribuicaoSeparacaoItens
Local aAreaAnt  := GetArea()
Local cQuery    := ""
Local cAliasQry := ""
	cQuery := "SELECT D0E.R_E_C_N_O_ RECNOD0E,"
	cQuery +=       " CASE WHEN D11.D11_QTMULT IS NULL THEN 1 ELSE D11.D11_QTMULT END D11_QTMULT"
	cQuery +=  " FROM "+RetSqlName("D0E")+" D0E"
	cQuery +=  " LEFT JOIN "+RetSqlName("D11")+" D11"
	cQuery +=    " ON D11.D11_FILIAL = '"+xFilial("D11")+"'"
	cQuery +=   " AND D0E.D0E_FILIAL = '"+xFilial("D0E")+"'"
	cQuery +=   " AND D11.D11_PRDORI = D0E.D0E_PRDORI"
	cQuery +=   " AND D11.D11_PRDCMP = D0E.D0E_PRODUT"
	cQuery +=   " AND D11.D_E_L_E_T_ = ' '"
	cQuery += " WHERE D0E.D0E_FILIAL = '"+xFilial("D0E")+"'"
	cQuery +=   " AND D0E.D0E_LOCORI = '"+Self:oDisEndOri:GetArmazem()+"'"
	cQuery +=   " AND D0E.D0E_CODDIS = '"+Self:GetCodDis()+"'"
	cQuery +=   " AND D0E.D0E_CARGA = '"+Self:GetCarga()+"'"
	cQuery +=   " AND D0E.D0E_PEDIDO = '"+Self:GetPedido()+"'"
	cQuery +=   " AND D0E.D0E_PRDORI = '"+Self:GetPrdOri()+"'"
	cQuery +=   " AND D0E.D0E_LOTECT = '"+Self:GetLoteCtl()+"'"
	cQuery +=   " AND D0E.D0E_NUMLOT = '"+Self:GetNumLote()+"'"
	cQuery +=   " AND D0E.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	Do While (cAliasQry)->(!Eof())
		Self:GoToD0E((cAliasQry)->RECNOD0E)
		Self:nQtdOri -= (nQtdQuebra * (cAliasQry)->D11_QTMULT)
		If lBxEmp
			Self:nQtdSep -= (nQtdQuebra * (cAliasQry)->D11_QTMULT)
		EndIf
		If Self:UpdateD0E()
			Self:DelDisSep()
		EndIf
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
	RestArea(aAreaAnt)
Return Nil
/*
Retorna a quantidade maxima do produto filho, utilizado para validar se
o estorno completo do produto pai foi realizado e deixar estornar a liberação parcial
*/
METHOD GetQtMxPai() CLASS WMSDTCDistribuicaoSeparacaoItens
Local aAreaAnt  := GetArea()
Local nQtdMax   := 0
Local cQuery    := ""
Local cAliasQry := ""

	cQuery := " SELECT MAX(D0E.D0E_QTDDIS / D11.D11_QTMULT) D0E_QTDDIS"
	cQuery +=   " FROM "+RetSqlName("D0E")+" D0E"
	cQuery +=  " INNER JOIN "+RetSqlName("D11")+" D11"
	cQuery +=     " ON D11.D11_FILIAL = '"+xFilial("D11")+"'"
	cQuery +=    " AND D11.D11_PRODUT = D0E.D0E_PRDORI"
	cQuery +=    " AND D11.D11_PRDORI = D0E.D0E_PRDORI"
	cQuery +=    " AND D11.D11_PRDCMP = D0E.D0E_PRODUT"
	cQuery +=    " AND D11.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE D0E.D0E_FILIAL = '"+xFilial("D0E")+"'"
	cQuery +=    " AND D0E.D0E_CODDIS = '"+Self:GetCodDis()+"'"
	cQuery +=    " AND D0E.D0E_PEDIDO = '"+Self:GetPedido()+"'"
	cQuery +=    " AND D0E.D0E_PRDORI = '"+Self:GetPrdOri()+"'"
	cQuery +=    " AND D0E.D0E_PRODUT <> D0E.D0E_PRDORI"
	cQuery +=    " AND D0E.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	If (cAliasQry)->(!Eof())
		nQtdMax := (cAliasQry)->D0E_QTDDIS
	EndIf
	(cAliasQry)->(dbCloseArea())

RestArea(aAreaAnt)
Return nQtdMax

METHOD DeleteD0J() CLASS WMSDTCDistribuicaoSeparacaoItens
	D0J->(DbSetOrder(1)) // D0J_FILIAL+D0J_CODDIS+D0J_IDDCF
	If D0J->(DbSeek(xFilial("D0J")+Self:GetCodDis()+Self:GetIdDCF()))
		RecLock("D0J",.F.)
		D0J->(DbDelete())
		D0J->(MsUnlock())
	EndIf
Return

METHOD GerAIdDCF() CLASS WMSDTCDistribuicaoSeparacaoItens
Local aIdDCFs  := {}
Local aAreaD0J := D0J->(GetArea())

	D0J->(dbSetOrder(1)) // D0J_FILIAL+D0J_CODDIS+D0J_IDDCF
	D0J->(dbSeek(xFilial('D0J')+Self:GetCodDis()))
	Do While D0J->(!Eof()) .And. D0J->D0J_CODDIS == Self:GetCodDis()
		Aadd(aIdDCFs,D0J->D0J_IDDCF)
		D0J->(dbSkip())
	EndDo
	RestArea(aAreaD0J)

Return aIdDCFs

METHOD ChkQtdDis(aIdDCFs) CLASS WMSDTCDistribuicaoSeparacaoItens
Local nQtdDis   := 0
Local nQtdOri   := 0
Local nQtdMov   := 0
Local cQuery    := ""
Local cAliasD0E := ""
Local cAliasD12 := ""
Local cIdDCF    := ""
Local nI        := 0
Local nPos      := 0
Local aTamSx3   := {}
Local aOrdSer   := {}
Default aIdDCFs   := {}
	// Verifica a quantidade distribuida
	cQuery := " SELECT SUM(D0E.D0E_QTDDIS) D0E_QTDDIS"
	cQuery +=   " FROM "+RetSqlName("D0E")+" D0E"
	cQuery +=  " WHERE D0E.D0E_FILIAL = '"+xFilial("D0E")+"'"
	If !Empty(Self:GetCarga()) .And. WmsCarga(Self:GetCarga())
		cQuery +=    " AND D0E.D0E_CARGA  = '"+Self:GetCarga()+"'"
	EndIf
	cQuery +=    " AND D0E.D0E_PEDIDO = '"+Self:GetPedido()+"'"
	cQuery +=    " AND D0E.D0E_PRDORI = '"+Self:GetPrdOri()+"'"
	cQuery +=    " AND D0E.D0E_PRODUT = '"+Self:GetProduto()+"'"
	If !Empty(Self:GetLoteCtl())
		cQuery += " AND D0E.D0E_LOTECT = '"+Self:GetLoteCtl()+"'"
	EndIf
	If !Empty(Self:GetNumLote())
		cQuery += " AND D0E.D0E_NUMLOT = '"+Self:GetNumLote()+"'"
	EndIf
	cQuery +=    " AND D0E.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasD0E := GetNextAlias()
	aTamSX3 := TamSx3("D0E_QTDDIS")
	dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasD0E,.F.,.T.)
	TcSetField(cAliasD0E,'D0E_QTDDIS','N',aTamSx3[1],aTamSx3[2])
	If (cAliasD0E)->(!Eof())
		nQtdTot := (cAliasD0E)->D0E_QTDDIS
	EndIf
	(cAliasD0E)->(dbCloseArea())
	// Verifica a quantidade origem
	cQuery := " SELECT DCR.DCR_IDDCF,"
	cquery +=        " SUM(DCR.DCR_QUANT) DCR_QUANT"
	cQuery +=   " FROM "+RetSqlName("D12")+" D12"
	cQuery +=  " INNER JOIN "+RetSqlName("D0J")+" D0J"
	cQuery +=     " ON D0J.D0J_FILIAL = '"+xFilial("D0J")+"'"
	cQuery +=    " AND D0J.D_E_L_E_T_ = ' '"
	cQuery +=  " INNER JOIN "+RetSqlName("DCR")+" DCR"
	cQuery +=     " ON DCR.DCR_FILIAL = '"+xFilial("DCR")+"'"
	cQuery +=    " AND DCR.DCR_IDDCF = D0J.D0J_IDDCF"
	cQuery +=    " AND DCR.D_E_L_E_T_ = ' '"
	cQuery +=  " INNER JOIN "+RetSqlName("DCF")+" DCF"
	cQuery +=     " ON DCF.DCF_FILIAL = '"+xFilial("DCF")+"'"
	cQuery +=    " AND DCF.DCF_ID = DCR.DCR_IDDCF"
	cQuery +=    " AND DCF.DCF_SEQUEN = DCR.DCR_SEQUEN"
	cQuery +=    " AND DCF.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE D12.D12_FILIAL = '"+xFilial("D12")+"'"
	cQuery +=    " AND D12.D12_IDDCF = DCR.DCR_IDORI"
	cQuery +=    " AND D12.D12_IDMOV = DCR.DCR_IDMOV"
	cQuery +=    " AND D12.D12_IDOPER = DCR.DCR_IDOPER"
	cQuery +=    " AND D12.D12_SEQUEN = DCR.DCR_SEQUEN"
	If !Empty(Self:GetCarga()) .And. WmsCarga(Self:GetCarga())
		cQuery +=    " AND D12.D12_CARGA  = '"+Self:GetCarga()+"'"
	EndIf
	cQuery +=    " AND D12.D12_DOC = '"+Self:GetPedido()+"'"
	cQuery +=    " AND D12.D12_PRDORI = '"+Self:GetPrdOri()+"'"
	cQuery +=    " AND D12.D12_PRODUT = '"+Self:GetProduto()+"'"
	If !Empty(Self:GetLoteCtl())
		cQuery += " AND D12.D12_LOTECT = '"+Self:GetLoteCtl()+"'"
	EndIf
	If !Empty(Self:GetNumLote())
		cQuery += " AND D12.D12_NUMLOT = '"+Self:GetNumLote()+"'"
	EndIf
	cQuery +=    " AND D12.D12_ATUEST = '1'"
	cQuery +=    " AND D12.D12_STATUS = '1'"
	cQuery +=    " AND D12.D_E_L_E_T_ = ' '"
	cQuery +=  " GROUP BY DCR.DCR_IDDCF"
	cQuery := ChangeQuery(cQuery)
	cAliasD12 := GetNextAlias()
	aTamSX3 := TamSx3("DCR_QUANT")
	dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasD12,.F.,.T.)
	TcSetField(cAliasD12,'DCR_QUANT','N',aTamSx3[1],aTamSx3[2])
	Do While (cAliasD12)->(!Eof())
		cIdDCF  := (cAliasD12)->DCR_IDDCF
		nQtdMov := (cAliasD12)->DCR_QUANT
		nQtdDis := 0
		If QtdComp(nQtdTot) > QtdComp(0)
			If QtdComp(nQtdTot) > QtdComp(nQtdMov)
				nQtdDis := nQtdMov
			Else
				nQtdDis := nQtdTot
			EndIf
			nQtdTot -= nQtdDis
		EndIf
		aAdd(aOrdSer,{cIdDCF,nQtdMov,nQtdDis})
		(cAliasD12)->(dbSkip())
	EndDo
	(cAliasD12)->(dbCloseArea())
	// Inicializa quantidades
	nQtdOri := 0
	nQtdDis := 0
	// Monta os id dcfs
	For nI := 1 To Len(aIdDCFs)
		If (nPos := AScan(aOrdSer, { |x| x[1] == aIdDCFs[nI] })) > 0
			nQtdOri += aOrdSer[nPos][2]
			nQtdDis += aOrdSer[nPos][3]
		EndIf
	Next nI
Return {nQtdOri,nQtdDis}

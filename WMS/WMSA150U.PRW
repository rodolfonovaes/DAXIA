#Include "Protheus.ch"
#Include "WMSA150.CH"
#Include "FWMVCDEF.CH"
#Include 'topconn.ch'
#Include 'tbiconn.ch'

#DEFINE WMSA15001 "WMSA15001"
#DEFINE WMSA15002 "WMSA15002"
#DEFINE WMSA15003 "WMSA15003"
#DEFINE WMSA15004 "WMSA15004"
#DEFINE WMSA15005 "WMSA15005"
#DEFINE WMSA15006 "WMSA15006"
#DEFINE WMSA15007 "WMSA15007"
#DEFINE WMSA15008 "WMSA15008"
#DEFINE WMSA15009 "WMSA15009"
#DEFINE WMSA15010 "WMSA15010"
#DEFINE WMSA15011 "WMSA15011"
#DEFINE WMSA15012 "WMSA15012"
#DEFINE WMSA15013 "WMSA15013"
#DEFINE WMSA15014 "WMSA15014"
#DEFINE WMSA15015 "WMSA15015"
#DEFINE WMSA15016 "WMSA15016"

Static lMarkAll := .F. // Indicador de marca/desmarca todos
Static nContDCF := 0   // Contador de Registros Marcados (ProcRegua)
Static lAutomato := .F.
Static cMark150 := ""
//----------------------------------------------------------
/*/{Protheus.doc} WMSA150
Execucao de Servicos

Neste arq. se encontram todas as ordens de servico,
dividas em 4 categorias:

1= Entradas, gerado atraves dos arquivos:
   SD1 - Itens das NF's de Entrada
   SD2 - Itens de venda da NF
   SD3 - Movimentacoes Internas
   SDA - Saldos a Distribuir
   SCM - Remitos de Entrada
2= Saidas, gerado atraves do arquivo:
   SC9 - Pedidos Liberados
   SCN - Remitos de Saida
3= Cargas, gerado atraves do arquivo:
   DBN - Quebra de Pallets
4= Ordem de Servico, gerado atraves do arquivo:
   DCF - Ordens de servico manual
@author Alex Egydio
@version 2.0
@since 26/12/2000
/*/
//----------------------------------------------------------
User Function WMSA150U(lAuto,nOpcao,cMark,cServico,cTipUnit)
Local aAreaAnt   := GetArea()
Local aAreaDCF   := DCF->(GetArea())
Local bKeyF5     := SetKey(VK_F5)
Local nRefreTela := SuperGetMV('MV_WMSREFS', .F., 10) // Tempo em Segundos para Refresh da tela de Execucao de Servicos (Default = 10 segundos)
Local aCampos	 := {}
Private oBrowse   := Nil
Private cCadastro := OemToAnsi(STR0001) // Execucao de Servicos
Private cCusMed   := SuperGetMv('MV_CUSMED')
Private lEnd      := .T.
Private cEndDes   := ''
Private	lAglutinado := .F.
Private	lSegSepara  := .F.
Default lAuto := .F.
_arrDCF := {}

AADD(aCampos,{ "Obs Lote"      , {|| RetObslo(DCF->DCF_DOCTO) } , "C" ,  })
	If !(lAutomato := lAuto)
		If !SuperGetMv("MV_WMSNEW",.F.,.F.)
			Return DLGA150()
		EndIf

		// Verifica se o custo medio e' calculado On-Line
		If cCusMed == 'O'
			Private nHdlPrv     := 0   // Endereco do arquivo de contra prova dos lanctos cont.
			Private lCriaHeader := .T. // Para criar o header do arquivo Contra Prova
			Private cLoteEst    := ''  // Numero do lote para lancamentos do estoque
			Private nTotal      := 0   // Total dos lancamentos contabeis
			Private cArquivo    := ''  // Nome do arquivo contra prova
			// Posiciona numero do Lote para Lancamentos do Faturamento
			SX5->(dbSetorder(1))
			cLoteEst := If(SX5->(DbSeek(xFilial('SX5')+'09EST',.F.)),Trim(X5Descri()),'EST ')
		EndIf

		If AMiIn(39,42) // Somente autorizado para OMS e WMS

			QbrNorma()

			// Variaveis utilizadas como parametros p/filtrar as ordens de servico
			//-----------------------------------------------------------------------------------
			// MV_PAR01 - Servico           De?
			// MV_PAR02                     Ate?
			// MV_PAR03 - Status do Servico 1- Nao Executados
			//                              2- Interrompidos
			//                              3- Ja Executados
			//                              4- Aptos a Execucao (Nao Executados e Iterrompidos)
			//                              5- Aptos ao Estorno (Ja Executados e Interrompidos)
			//                              6- Todos
			// MV_PAR04 - Documento         De?
			// MV_PAR05                     Ate?
			// MV_PAR06 - Data              De?
			// MV_PAR07                     Ate?
			// MV_PAR08 - Produto           De?
			// MV_PAR09                     Ate?
			// MV_PAR10 - Cliente/Forn      De?
			// MV_PAR11                     Ate?
			// MV_PAR12 - Loja              De?
			// MV_PAR13                     Ate?
			// MV_PAR14 - Tipo de Servico   1- Entradas
			//                              2- Saidas
			//                              3- Cargas
			//                              4- Ordem de Servico
			//                              5- Todos
			// MV_PAR15 - Carga             De?
			// MV_PAR16                     Ate?
			// MV_PAR17 - Refresh Autom.Tela  Refresh 1o Reg
			//                                Refresh Ult.Reg
			//                                Sem Refresh
			// MV_PAR18 - Habilita Estorno    Sim/Nao
			// MV_PAR19 - Estorna Serv.Autom. Sim/Nao
			If !Pergunte('DLA150', .T.)
				Return Nil
			EndIf
			oBrowse:= FWMarkBrowse():New()
			oBrowse:SetDescription(cCadastro)
			oBrowse:SetMenuDef("WMSA150U")
			oBrowse:SetAlias("DCF")
			oBrowse:SetFieldMark("DCF_OK")
			oBrowse:SetValid({||ValidMark()})
			oBrowse:SetAfterMark({||AfterMark(.F.,.F.)})
			oBrowse:SetAllMark({||AllMark()})
			oBrowse:SetFilterDefault("@"+MontaQuery())
			oBrowse:SetWalkThru(.F.)
			oBrowse:SetAmbiente(.F.)
			oBrowse:SetFixedBrowse(.T.)
			oBrowse:AddLegend("!Empty(DCF_SERVIC).And.DCF_STSERV=='1'","GREEN" ,STR0002) // O.S. Nï¿½o Executada
			oBrowse:AddLegend("!Empty(DCF_SERVIC).And.DCF_STSERV=='2'","YELLOW",STR0003) // O.S. Interrompida
			oBrowse:AddLegend("!Empty(DCF_SERVIC).And.DCF_STSERV=='3'","RED"   ,STR0004) // O.S. Executada
			oBrowse:AddLegend("Empty(DCF_SERVIC)"                     ,"BROWN" ,STR0005) // O.S. Sem Serviï¿½o
			oBrowse:SetTimer({|| RefreshBrw() }, Iif(nRefreTela <= 0, 3600, nRefreTela) * 1000)
			oBrowse:SetIniWindow({||oBrowse:oBrowse:oTimer:lActive := (mv_par17 < 3)})
			oBrowse:SetParam({|| UpdSelecao()})
			oBrowse:SetFields(aCampos)

			SetKey (VK_F5 , {|| Processa({|lEnd| oBrowse:Refresh()},cCadastro,OemToAnsi(STR0006),.T.)}) // Selecionando Servicos...

			oBrowse:Activate()

			SetKey (VK_F5 , bKeyF5)
			RestArea(aAreaDCF)
			RestArea(aAreaAnt)
		EndIf
	Else
		// Atribui marca passada por parï¿½metro
		cMark150 := cMark
		Do Case
			Case nOpcao == 1 // Executar
				UpdateServ(1)
			Case nOpcao == 2 // Estornar
				UpdateServ(2)
			Case nOpcao == 3 // Alterar Serviï¿½o
				UpdServico(cServico)
			Case nOpcao == 4 // Informar Tipo Unit.
				UpdTpUnit(cTipUnit)
		EndCase
	EndIf
Return NIL
/*/-----------------------------------------------------------------------------
 Monta o menu da rotina
-----------------------------------------------------------------------------/*/
Static Function MenuDef()
Local aRotina := {}

	Add OPTION aRotina TITLE STR0029 ACTION "AxPesqui"                         OPERATION 1 ACCESS 0 // Pesquisar
	Add OPTION aRotina TITLE STR0030 ACTION "VIEWDEF.WMSA150"                  OPERATION 2 ACCESS 0 // Visualizar
	Add OPTION aRotina TITLE STR0007 ACTION "StaticCall(WMSA150U,UpdateServ,1)" OPERATION 4 ACCESS 0 // Executar
	Add OPTION aRotina TITLE STR0008 ACTION "StaticCall(WMSA150U,UpdateServ,2)" OPERATION 5 ACCESS 0 // Estornar
	Add OPTION aRotina TITLE STR0009 ACTION "StaticCall(WMSA150,UpdSelecao)"   OPERATION 3 ACCESS 0 // Selecionar
	Add OPTION aRotina TITLE STR0010 ACTION "StaticCall(WMSA150U,UpdServico)"   OPERATION 4 ACCESS 0 // Alterar Serviï¿½o
	If WmsX312118('DCF','DCF_UNIDES')
		Add OPTION aRotina TITLE STR0038 ACTION "StaticCall(WMSA150,UpdTpUnit)"   OPERATION 4 ACCESS 0 // Informar Tipo Unit.
	EndIf
Return aRotina

Static Function ModelDef()
Local oStruDCF := FWFormStruct(1,"DCF",/*bAvalCampo*/,/*lViewUsado*/)
Local oStruD12 := FWFormStruct(1,"D12",/*bAvalCampo*/,/*lViewUsado*/)
Local oStruDCR := FWFormStruct(1,"DCR",/*bAvalCampo*/,/*lViewUsado*/)
Local oModel   := MPFormModel():New("WMSA150",/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/)
Local aColsSx3 := {}

	oModel:AddFields("DCFMASTER",/*cOwner*/,oStruDCF )
	oModel:GetModel("DCFMASTER"):SetDescription( STR0031 ) // "Ordem de Serviï¿½o"

	oModel:AddGrid("DCRREL","DCFMASTER",oStruDCR)
	oModel:GetModel("DCRREL"):SetDescription( STR0032 ) // "Movimentos WMS"
	oModel:SetRelation("DCRREL", {{"DCR_FILIAL","xFilial('DCR')"},{"DCR_IDDCF","DCF_ID"}})

	oModel:AddGrid("D12GRID","DCRREL",oStruD12)
	oModel:GetModel("D12GRID"):SetDescription( STR0032 ) // "Movimentos WMS"
	oModel:SetRelation("D12GRID", {{"D12_FILIAL","xFilial('D12')"},{"D12_IDDCF","DCR_IDORI"}})

	BuscarSX3("DCF_CARGA",,aColsSX3)
	oStruDCR:AddField( aColsSX3[1],aColsSX3[1],"DCR_VCARGA","C",aColsSX3[3],aColsSX3[4],Nil,Nil,Nil,Nil,{|| Posicione("DCF",9,xFilial("DCF")+DCR->DCR_IDDCF,"DCF_CARGA") } ,Nil,.F.,.T. )
	BuscarSX3("DCF_DOCTO",,aColsSX3)
	oStruDCR:AddField( aColsSX3[1],aColsSX3[1],"DCR_VDOCTO","C",aColsSX3[3],aColsSX3[4],Nil,Nil,Nil,Nil,{|| Posicione("DCF",9,xFilial("DCF")+DCR->DCR_IDDCF,"DCF_DOCTO") } ,Nil,.F.,.T. )
	BuscarSX3("DCF_SERIE",,aColsSX3)
	oStruDCR:AddField( aColsSX3[1],aColsSX3[1],"DCR_VSERIE","C",aColsSX3[3],aColsSX3[4],Nil,Nil,Nil,Nil,{|| Posicione("DCF",9,xFilial("DCF")+DCR->DCR_IDDCF,"DCF_SERIE") } ,Nil,.F.,.T. )
	BuscarSX3("DCF_CLIFOR",,aColsSX3)
	oStruDCR:AddField( aColsSX3[1],aColsSX3[1],"DCR_VCLIFO","C",aColsSX3[3],aColsSX3[4],Nil,Nil,Nil,Nil,{|| Posicione("DCF",9,xFilial("DCF")+DCR->DCR_IDDCF,"DCF_CLIFOR") },Nil,.F.,.T. )
	BuscarSX3("DCF_LOJA",,aColsSX3)
	oStruDCR:AddField( aColsSX3[1],aColsSX3[1],"DCR_VLOJA" ,"C",aColsSX3[3],aColsSX3[4],Nil,Nil,Nil,Nil,{|| Posicione("DCF",9,xFilial("DCF")+DCR->DCR_IDDCF,"DCF_LOJA") }  ,Nil,.F.,.T. )
	//BuscarSX3("CJ_ZZOBSLO",,aColsSX3)
	//oStruDCR:AddField( aColsSX3[1],aColsSX3[1],"CJ_ZZOBSLO" ,"C",aColsSX3[3],aColsSX3[4],Nil,Nil,Nil,Nil,{|| RetObslo(DCF->DCF_DOCTO) }  ,Nil,.F.,.T. )	

	oModel:AddGrid("DCRGRID","D12GRID",oStruDCR)
	oModel:GetModel("DCRGRID"):SetDescription( STR0032 ) // "Movimentos WMS"
	oModel:SetRelation("DCRGRID", {{"DCR_FILIAL","xFilial('DCR')"},{"DCR_IDMOV","D12_IDMOV"},{"DCR_IDOPER","D12_IDOPER"},{"DCR_IDORI","D12_IDDCF"}})
Return oModel

Static Function ViewDef()
Local oStruDCF := FWFormStruct( 2, "DCF" )
Local oStruDCR := FwFormStruct( 2, "DCR" )
Local oStruD12 := FWFormStruct( 2, "D12" )
Local oModel   := FWLoadModel( "WMSA150U" )
Local oView    := FWFormView():New()
Local aColsSx3 := {}

	BuscarSX3("DCF_CARGA",,aColsSX3)
	oStruDCR:AddField("DCR_VCARGA","01",aColsSX3[1],aColsSX3[1],Nil,"C",aColsSX3[2],Nil,"",.F.,Nil,Nil,Nil,Nil,Nil,.T.,Nil)
	BuscarSX3("DCF_DOCTO",,aColsSX3)
	oStruDCR:AddField("DCR_VDOCTO","02",aColsSX3[1],aColsSX3[1],Nil,"C",aColsSX3[2],Nil,"",.F.,Nil,Nil,Nil,Nil,Nil,.T.,Nil)
	BuscarSX3("DCF_SERIE",,aColsSX3)
	oStruDCR:AddField("DCR_VSERIE","03",aColsSX3[1],aColsSX3[1],Nil,"C",aColsSX3[2],Nil,"",.F.,Nil,Nil,Nil,Nil,Nil,.T.,Nil)
	BuscarSX3("DCF_CLIFOR",,aColsSX3)
	oStruDCR:AddField("DCR_VCLIFO","04",aColsSX3[1],aColsSX3[1],Nil,"C",aColsSX3[2],Nil,"",.F.,Nil,Nil,Nil,Nil,Nil,.T.,Nil)
	BuscarSX3("DCF_LOJA",,aColsSX3)
	oStruDCR:AddField("DCR_VLOJA" ,"05",aColsSX3[1],aColsSX3[1],Nil,"C",aColsSX3[2],Nil,"",.F.,Nil,Nil,Nil,Nil,Nil,.T.,Nil)
	//BuscarSX3("CJ_ZZOBSLO",,aColsSX3)
	//oStruDCR:AddField("CJ_ZZOBSLO" ,"06",aColsSX3[1],aColsSX3[1],Nil,"C",aColsSX3[2],Nil,"",.F.,Nil,Nil,Nil,Nil,Nil,.T.,Nil)	

	oStruDCR:SetProperty("DCR_IDORI"  ,MVC_VIEW_ORDEM,"06")
	oStruDCR:SetProperty("DCR_IDDCF"  ,MVC_VIEW_ORDEM,"07")
	oStruDCR:SetProperty("DCR_IDMOV"  ,MVC_VIEW_ORDEM,"08")
	oStruDCR:SetProperty("DCR_IDOPER" ,MVC_VIEW_ORDEM,"09")
	oStruDCR:SetProperty("DCR_QUANT"  ,MVC_VIEW_ORDEM,"10")
	oStruDCR:SetProperty("DCR_QTSEUM" ,MVC_VIEW_ORDEM,"11")
	oStruDCR:SetProperty("DCR_SEQUEN" ,MVC_VIEW_ORDEM,"12")

	oView:SetModel( oModel )

	oView:CreateHorizontalBox("UP"  , 60,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
	oView:CreateHorizontalBox("DOWN", 40,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )

	oView:CreateVerticalBox("LEFT",49.75,"DOWN")
	oView:CreateVerticalBox("MID",0.5,"DOWN")
	oView:CreateVerticalBox("RIGHT",49.75,"DOWN")

	oView:AddField("DCFVIEW", oStruDCF, "DCFMASTER")
	oView:SetOwnerView("DCFVIEW", "UP")

	oView:AddGrid("D12VIEW", oStruD12, "D12GRID")
	oView:EnableTitleView("D12VIEW", "Movimentos WMS")
	oView:SetOwnerView("D12VIEW", "LEFT")

	oView:AddGrid("DCRVIEW", oStruDCR, "DCRGRID")
	oView:EnableTitleView("DCRVIEW", STR0033) //"Detalhes do Movimento"
	oView:SetOwnerView("DCRVIEW", "RIGHT")
Return oView
// Pega a marca setada
Static Function GetMark150()
	If !lAutomato
		cMark150 := oBrowse:cMark
	EndIf
Return cMark150
/*/-----------------------------------------------------------------------------
 Valida a marcaï¿½ï¿½o do registro
-----------------------------------------------------------------------------/*/
Static Function ValidMark()
Local lRet := .F.
	If mv_par03 == 1 .Or. mv_par03 == 2 .Or. mv_par03 == 4 // Verde - Apto a Executar
		// Status do Servico
		//--------------------------------
		// 1 = Nao Executado  - Verde
		// 2 = Interrompido   - Verde
		// 3 = Executado      - Vermelho
		// 4 = Em Conferencia - Azul
		If !(DCF->DCF_STSERV=='3').And.!(DCF->DCF_STSERV=='4')  // Se for Interrompido ou Nao Executado
			lRet := .T.
		EndIf
	ElseIf mv_par03 == 2 .Or. mv_par03 == 3 .Or. mv_par03 == 5 // Verde - Apto a Estornar
		// Status do Servico
		//--------------------------------
		// 1 = Nao Executado  - Vermelho
		// 2 = Interrompido   - Verde
		// 3 = Executado      - Verde
		// 4 = Em Conferencia - Azul
		If (DCF->DCF_STSERV == '2' .Or. DCF->DCF_STSERV == '3') // Se for Interrompido ou Executado
			lRet := .T.
		EndIf
	EndIf
Return lRet
/*/-----------------------------------------------------------------------------
 Rotina apï¿½s a marcaï¿½ï¿½o do registro
-----------------------------------------------------------------------------/*/
Static Function AfterMark(lMarkAll,lMarkRec)
Static lDLA150Pe  := ExistBlock('DLGA150M')
Static lDla150Mk  := ExistBlock('DLA150MK')
Local aAreaAnt    := GetArea()
Local lRet        := .T.
	/*If lDla150Mk
		lRet := ExecBlock('DLA150MK',.F.,.F.,GetMark150())
	EndIf*/
	If lRet
		If lMarkAll
			Reclock('DCF',.F.)
			DCF->DCF_OK := Iif(lMarkRec,GetMark150(),Space(TamSx3("DCF_OK")[1]))
			DCF->DCF_STRADI := ' '
			DCF->(MsUnlock())
			Iif(!Empty(DCF->DCF_OK), nContDCF++, nContDCF--)
		Else
			Iif(oBrowse:IsMark(), nContDCF++, nContDCF--)
			Reclock('DCF',.F.)
			DCF->DCF_STRADI := ' '
			DCF->(MsUnlock())
			MarcaSimil(oBrowse:IsMark(),GetMark150(),Space(TamSx3("DCF_OK")[1])) // Marca ou Desmarca todos os servicos de uma mesma Carga/Documento ou documento
		EndIf

	EndIf
	/*If lDLA150Pe
		ExecBlock("DLGA150M",.F.,.F.,GetMark150())
	EndIf*/
	RestArea(aAreaAnt)

Return lRet
/*/-----------------------------------------------------------------------------
 Marca ou desmarca todos os servicos da mesma Carga/Documento
 Impede que estes servicos sejam executados separadamente
-----------------------------------------------------------------------------/*/
Static Function MarcaSimil(cMarca)
Local aAreaDCF  := DCF->(GetArea())
Local cAliasDCF := ""
Local cChave    := ""
Local cCompar   := ""
Local nRecnoDCF := 0
	
	// Define a chave de pesquisa para encontrar as ordens de serviï¿½o similares
	If DCF->DCF_ORIGEM == "DCF" .And. DCF->DCF_STSERV $ "1|2" .And. !Empty(DCF->DCF_DOCPEN)
		cChave := "xFilial('DCF')+DCF->DCF_SERVIC+DCF->DCF_DOCPEN"
	ElseIf WmsCarga(DCF->DCF_CARGA)
		cChave := "xFilial('DCF')+DCF->DCF_SERVIC+DCF->DCF_CARGA"
	Else
		If DCF->DCF_ORIGEM != "SC9"
			cChave := "xFilial('DCF')+DCF->DCF_SERVIC+DCF->DCF_DOCTO+DCF->DCF_SERIE+DCF->DCF_CLIFOR+DCF->DCF_LOJA"
		Else
			cChave := "xFilial('DCF')+DCF->DCF_SERVIC+DCF->DCF_DOCTO+DCF->DCF_CLIFOR+DCF->DCF_LOJA"
		EndIf
	EndIf
	
	// Define a string de comparaï¿½ï¿½o com base na DCF posicionada
	cCompar := &cChave

	// Busca alias do prï¿½prio browse, que neste caso ï¿½ a DCF
	cAliasDCF := oBrowse:Alias()
	nRecnoDCF := (cAliasDCF)->(Recno())

	// Ao executar o comando DbGoTop(), o sistema re-executa todos os filtros e, desta forma,
	// a regra de marcaï¿½ï¿½o serï¿½ executada apenas para os registros que o usuï¿½rio vï¿½ em tela
	(cAliasDCF)->(DbGoTop())

	While (cAliasDCF)->(!Eof())
		// Marca apenas se for um registro similar
		If &cChave == cCompar .And. nRecnoDCF != (cAliasDCF)->(Recno())
			AfterMark(.T.,!Empty(cMarca))
		EndIf
		(cAliasDCF)->(DbSkip())
	EndDo

RestArea(aAreaDCF)
oBrowse:Refresh()
Return Nil

/*/-----------------------------------------------------------------------------
 Marca todos os registros da seleï¿½ï¿½o
-----------------------------------------------------------------------------/*/
Static Function AllMark()
Local aAreaDCF  := DCF->(GetArea())
Local cAliasDCF := ""

	lMarkAll := !lMarkAll

	If lMarkAll
		nContDCF := 0
	EndIf
	// Busca alias do prï¿½prio browse, que neste caso ï¿½ a DCF
	cAliasDCF := oBrowse:Alias()
	// Ao executar o comando DbGoTop(), o sistema re-executa todos os filtros e, desta forma,
	// a regra de marcaï¿½ï¿½o serï¿½ executada apenas para os registros que o usuï¿½rio vï¿½ em tela
	(cAliasDCF)->(DbGoTop())
	While (cAliasDCF)->(!Eof())
		AfterMark(.T.,lMarkAll)
		(cAliasDCF)->(DbSkip())
	EndDo
	If !lMarkAll
		nContDCF := 0
	EndIf

RestArea(aAreaDCF)
oBrowse:Refresh()
Return Nil

/*/-----------------------------------------------------------------------------
 Desmarca todos os registros da seleï¿½ï¿½o
-----------------------------------------------------------------------------/*/
Static Function UncheckAll(cWhere)
Local aArea  := GetArea()
Local cQuery := ""

	cQuery := "UPDATE " + RetSqlName("DCF")
	cQuery +=   " SET DCF_OK = ' '"
	cQuery += " WHERE "+cWhere+" AND DCF_OK = '"+GetMark150()+"' AND D_E_L_E_T_ = ' '"
	If TcSQLExec(cQuery) < 0
		WmsMessage(STR0039 + CRLF + TcSQLError()) // "Problema ao tentar demarcar os registros DCF: "
	EndIf

	nContDCF := 0

RestArea(aArea)
oBrowse:Refresh()
Return Nil

/*---------------------------------------------------------------------------
---MontaQuery
---Retorna expressao do filtro
---Alex Egydio 13/06/2006
---------------------------------------------------------------------------*/
Static Function MontaQuery()
Local cQuery := ''
Local nStServ:= mv_par03
	cQuery  := "DCF_FILIAL = '"+xFilial('DCF')+"' And "
	cQuery  += "DCF_SERVIC >= '"+mv_par01+"' And "
	cQuery  += "DCF_SERVIC <= '"+mv_par02+"' And "
	cQuery  += "DCF_DOCTO  >= '"+mv_par04+"' And "
	cQuery  += "DCF_DOCTO  <= '"+mv_par05+"' And "
	cQuery  += "DCF_DATA   >='"+DtoS(mv_par06)+"' And "
	cQuery  += "DCF_DATA   <='"+DtoS(mv_par07)+"' And "
	cQuery  += "DCF_CODPRO >= '"+mv_par08+"' And "
	cQuery  += "DCF_CODPRO <= '"+mv_par09+"' And "
	cQuery  += "DCF_CLIFOR >= '"+mv_par10+"' And "
	cQuery  += "DCF_CLIFOR <= '"+mv_par11+"' And "
	cQuery  += "DCF_LOJA   >= '"+mv_par12+"' And "
	cQuery  += "DCF_LOJA   <= '"+mv_par13+"' And "
	cQuery  += "DCF_CARGA  >= '"+mv_par15+"' And "
	cQuery  += "DCF_CARGA  <= '"+mv_par16+"' And "
	cQuery  += "DCF_CODREC >= '"+mv_par20+"' And "
	cQuery  += "DCF_CODREC <= '"+mv_par21+"' And "

	If WmsX112118("DLA150","22")
		cQuery  += "DCF_UNITIZ >= '"+mv_par22+"' And "
		cQuery  += "DCF_UNITIZ <= '"+mv_par23+"' And "
	EndIf
	// Tipo de Servico 1- Entradas
	//                 2- Saidas
	//                 3- Cargas Unitizadas
	//                 4- Internos
	//                 5- Todos
	If mv_par14 == 1     // Entradas
		cQuery  += "DCF_ORIGEM IN ('SD1','SD2','SD3','SDA','SCM','D0R') And "
	ElseIf mv_par14 == 2 // Saidas
		cQuery  += "DCF_ORIGEM IN ('SC9','SCN','SD4') And "
	ElseIf mv_par14 == 3 // Cargas Unitizadas
		cQuery  += "DCF_ORIGEM = 'DBN' And "
	ElseIf mv_par14 == 4 // Internos
		cQuery  += "DCF_ORIGEM IN ('DCF','DH1') And "
	EndIf
	// Status do Servico 1- Nao Executados
	//                   2- Interrompidos
	//                   3- Ja Executados
	//                   4- Aptos a Execucao (Nao Executados e Iterrompidos)
	//                   5- Aptos ao Estorno (Ja Executados e Interrompidos)
	If nStServ == 1      // Mostra Somente Servicos ainda Nao Executados
		cQuery += "DCF_STSERV IN ('1','4')"
	ElseIf  nStServ == 2 // Mostra Somente Servicos Interrompidos
		cQuery += "DCF_STSERV = '2'"
	ElseIf  nStServ == 3 // Mostra somente Servicos Ja Executados
		cQuery += "DCF_STSERV = '3'"
	ElseIf  nStServ == 4 // Mostra somente Servicos Aptos a Execucao (Nao Executados e Iterrompidos)
		cQuery += "DCF_STSERV IN ('1','2')"
	Else // Mostra somente Servicos Aptos ao Estorno (Ja Executados e Interrompidos)
		cQuery += "DCF_STSERV IN ('3','2')"
		cQuery += "AND NOT EXISTS (SELECT 1"
		cQuery +=                  " FROM "+RetSqlName('SC9')+" SC9"
		cQuery +=                 " WHERE SC9.C9_FILIAL = '"+xFilial('SC9')+"'"
		cQuery +=                   " AND SC9.C9_IDDCF = DCF_ID"
		cQuery +=                   " AND SC9.C9_NFISCAL <> ' '"
		cQuery +=                   " AND SC9.D_E_L_E_T_ = ' ')"
	EndIf
	// Ponto de Entrada DL150FIL para a alteracao do Filtro executado pelo programa
	/*If ExistBlock('DL150FIL')
		If ValType(cQueryPE:=ExecBlock('DL150FIL',.F.,.F.,{cQuery,.T.})) == 'C'
			cQuery := cQueryPE
		EndIf
	EndIf*/
Return(cQuery)
/*---------------------------------------------------------------------------
---UpdSelecao
---Permite Selecionar Novamente o Intervalo
---Fernando Joly Siquini 24/04/2002
---------------------------------------------------------------------------*/
Static Function UpdSelecao()
Local lRet       := .T.
Local cWhere     := ""
	// Variaveis utilizadas como parametros p/filtrar as ordens de servico
	//--------------------------------------------------------------------------------------
	// MV_PAR01 - Servico           De?
	// MV_PAR02                     Ate?
	// MV_PAR03 - Status do Servico 1- Nao Executados
	//                              2- Interrompidos
	//                              3- Ja Executados
	//                              4- Aptos a Execucao (Nao Executados e Iterrompidos)
	//                              5- Aptos ao Estorno (Ja Executados e Interrompidos)
	//                              6- Todos
	// MV_PAR04 - Documento         De?
	// MV_PAR05                     Ate?
	// MV_PAR06 - Data              De?
	// MV_PAR07                     Ate?
	// MV_PAR08 - Produto           De?
	// MV_PAR09                     Ate?
	// MV_PAR10 - Cliente/Forn      De?
	// MV_PAR11                     Ate?
	// MV_PAR12 - Loja              De?
	// MV_PAR13                     Ate?
	// MV_PAR14 - Tipo de Servico   1- Entradas
	//                              2- Saidas
	//                              3- Cargas
	//                              4- Ordem de Servico
	//                              5- Todos
	// MV_PAR15 - Carga             De?
	// MV_PAR16                     Ate?
	// MV_PAR17 - Refresh Autom.Tela  Refresh 1o Reg
	//                                Refresh Ult.Reg
	//                                Sem Refresh
	// MV_PAR18 - Habilita Estorno    Sim/Nao
	// MV_PAR19 - Estorna Serv.Autom. Sim/Nao
	// MV_PAR20 - Docto.Conferencia Recebto.De?
	// MV_PAR21 - Docto.Conferencia Recebto.Ate?
	QbrNorma()
	If nContDCF > 0
		cWhere := MontaQuery()
	EndIf
	lRet := Pergunte('DLA150', .T.)
	If lRet
		// Antes de selecionar novos registros, eh obrigatoria a chamada da funcao AllMark para desmarcar todos os
		// registros selecionados anteriormente. Isto evita que fiquem marcas repetidas gravadas no campo DCF_OK
		If nContDCF > 0
			UncheckAll(cWhere)
		EndIf
		oBrowse:oBrowse:oTimer:lActive := (mv_par17 < 3)
		// Selecionar servicos conforme a parametrizacao do usuario.
		oBrowse:SetFilterDefault("@"+MontaQuery())
		oBrowse:Refresh()
	EndIf
Return lRet
/*---------------------------------------------------------------------------
---UpdateServ
---Execucao de Servicos
---Alex Egydio 26/12/2000
---nOpcx, Numerico, (Operacao)
/////////////////////////////////////////////////////////////////////////////
---Customizado: Daniel Evandro Buso 
---Colocado em ambiente HomologaÃ§Ã£o: 05/11/2019
---------------------------------------------------------------------------*/
Static Function UpdateServ(nOpcx)
Local  cQrySBE	 := ''
Local  cQryD12   := ''
Local  cAliasQry := GetNextAlias()
Local  cProd     := DCF->DCF_CODPRO
Local  cLote     := DCF->DCF_LOTECT
Local  cDoc      := DCF->DCF_DOCTO
Local  cSrv		 := SuperGetMV('ES_SERVDIS',.T.,'019',cFilAnt)
Local  cSegSepara	 := SuperGetMV('ES_SERVSEP',.T.,'025',cFilAnt)

lAglutinado := .F.
lSegSepara	:= .F.
	If nOpcx == 1 // Executa
	
	    //MIT044 - R01PT - SELECAO AUTOMATICA DOS ENDERECOS DE DESTINOS - WMS - 25/09/2019 - DANIEL BUSO
	    
	    //TABELA DC5 - SERVICOS X TAREFAS
		
   		DC5->( DbSetOrder( 1 ) )
   		If DC5->( DbSeek( xFilial( 'DC5' ) + DCF->DCF_SERVIC )) .AND. DC5->DC5_OPERAC = '3' 
		   If DCF->DCF_SERVIC == cSrv
				//TABELA DC6- TAREFA X ATIVIDADES
				DC6->( DbSetOrder( 1 ) )
				If DC6->( DbSeek( xFilial( 'DC6' ) + DC5->DC5_SERVIC )) .ANd.DC6->DC6_TPAGLU <> '1'
					If DC6->DC6_TPAGLU <> '1' //DC6_TPAGLU <> '1' INDICA QUE A ATIVIDADE E AGLUTINADA
						lAglutinado := .T.
					EndIf
				Endif
			ElseIf DCF->DCF_SERVIC == cSegSepara
				lSegSepara := .T.
			EndIf
	   	Endif
		//FIM DA CUSTOMIZAÃ‡ÃƒO REF. A MIT044 - R01PT

		// Selecionou o.s.wms aptas a estornar e tentou executar
		If mv_par03 == 5 .OR. mv_par03 == 3
			WmsMessage(STR0011,WMSA15001,1) // Para executar o serviï¿½o vocï¿½ deve habilitar esta opï¿½ï¿½o atravï¿½s das perguntas desta rotina. // Ok
		Else
			If !lAutomato
				Processa({|lEnd| ExecuteSrv(@lEnd)},cCadastro,OemToAnsi(STR0013),.T.)   //'Executando Servicos...'
			Else
				ExecuteSrv(.T.)
			EndIf
		EndIf
	Else // Estorna
		If mv_par18 == 2 .OR. (mv_par03 == 1 .And. cSegSepara <> DCF->DCF_SERVIC) .OR. mv_par03 == 4
			WmsMessage(STR0014,WMSA15002,1) // Para executar o estorno vocÃª deve habilitar esta opÃ§Ã£o atravÃ©s das perguntas desta rotina. // Ok
		Else

		/*	D14->(DbSetOrder(3))
			If D14->(DbSeek(xFilial('D14') + DCF->DCF_LOCDES + DCF->DCF_CODPRO + DCF->DCF_ENDDES + DCF->DCF_LOTECT))
				RecLock('D14',.F.)
				//D14->D14_QTDEMP := D14->D14_QTDEMP - DCF->DCF_QUANT
				//D14->D14_QTDEM2 := D14->D14_QTDEM2 - DCF->DCF_QTSEUM
			//	D14->D14_QTDPEM := D14->D14_QTDPEM + DCF->DCF_QUANT
			//	D14->D14_QTDPE2 := D14->D14_QTDPE2 + DCF->DCF_QTSEUM
				D14->D14_QTDSPR	:= D14->D14_QTDSPR + DCF->DCF_QUANT	
				D14->D14_QTDSP2 := D14->D14_QTDSP2 + DCF->DCF_QTSEUM
				MsUnlock()
			EndIf		*/
			If !lAutomato
				Processa({|lEnd| ReverseSrv(@lEnd)},cCadastro,OemToAnsi(STR0015),.T.) // Estornando Servicos...					
			Else
				ReverseSrv(.F.)
			EndIf
		EndIf
	EndIf
	If !lAutomato
		RefreshBrw()
	EndIf
Return Nil

Static Function RefreshBrw()
Local nPos := oBrowse:At()
	QbrNorma()
	If MV_PAR17 == 1
		oBrowse:Refresh(.T.)
	ElseIf MV_PAR17 == 2
		oBrowse:Refresh(.F.)
		oBrowse:GoBottom()
	Else
		oBrowse:Refresh(.F.)
		oBrowse:GoTo(nPos,.F.)
	EndIf
Return .T.
/*---------------------------------------------------*/
Static Function ExecuteSrv(lEnd)
Local aAreaDCF   := DCF->(GetArea())
Local cAliasDCF  := GetNextAlias()
Local cQuery     := ''
Local cSrvVazio  := PadR("", TamSx3("DCF_SERVIC")[1])
Local cMensagem  := ''
//Local oOrdSerExe := WMSDTCOrdemServicoExecute():New()
Local oOrdSerExe := DAXWMSOrdemServicoExecute():New()//RODOLFO
Local oRegraConv := WMSBCCRegraConvocacao():New()
Local aOrdSerExe := {}
Local aEndereco	 := {}
Local nI         := 0
Local oEndereco   := WMSDTCEndereco():New()
Public	_arrDCF	:= {} // utilizado para mapear a D14 no PE WMSATD14

	// Verificar data do ultimo fechamento em SX6.
	If MVUlmes() >= dDataBase
		WmsMessage(STR0020,WMSA15005,,,,STR0021) // Nï¿½o pode ser digitado movimento com data anterior a ï¿½ltima data de fechamento (virada de saldos). // Utilizar data posterior ao ï¿½ltimo fechamento de estoque (MV_ULMES) / posterior ï¿½ data do bloqueio de movimentos (MV_DBLQMOV).
		Return Nil
	EndIf

	If !oOrdSerExe:ChecaPrior()
		WmsMessage(oOrdSerExe:GetErro(),WMSA15013,1)
		Return Nil
	EndIf

	// Status do Servico 1- Nao Executados
	//                   2- Interrompidos
	//                   3- Ja Executados
	//                   4- Aptos a Execucao (Nao Executados e Iterrompidos)
	//                   5- Aptos ao Estorno (Ja Executados e Interrompidos)
	cQuery := "SELECT R_E_C_N_O_ RECNODCF"
	cQuery += "  FROM "+RetSqlName('DCF')
	cQuery += " WHERE DCF_FILIAL = '"+xFilial("DCF")+"'"
	If mv_par01 == mv_par02
		cQuery += " AND DCF_SERVIC = '"+mv_par01+"'"
	Else
		cQuery += " AND DCF_SERVIC BETWEEN '"+mv_par01+"' AND '"+mv_par02+"'"
	EndIf
	If Empty(mv_par01) .Or. Empty(mv_par02)
		cQuery += " AND DCF_SERVIC <> '"+cSrvVazio+"'"
	EndIf
	If mv_par03 == 1         // Executa Somente Servicos ainda Nao Executados
		cQuery += " AND DCF_STSERV = '1'"
	ElseIf mv_par03 == 2     // Executa Somente Servicos Interrompidos
		cQuery += " AND DCF_STSERV = '2'"
	ElseIf mv_par03 == 4     // Executa Somente Servicos Aptos a Execucao (Nao Executados e Iterrompidos)
		cQuery += " AND DCF_STSERV IN ('1','2')"
	EndIf
	cQuery +=   " AND DCF_OK = '"+GetMark150()+"'"
	cQuery +=   " AND D_E_L_E_T_ = ' '"
	cQuery +=   " ORDER BY DCF_CODPRO " //RODOLFO - ajuste para ordenar por produto
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasDCF,.F.,.T.)
	// Devido processo de execuï¿½ï¿½o efetuar o disarmtransaction ha situaï¿½ï¿½es que o cache ï¿½ limpo
	// e perde-se o cAliasDCF por isso ï¿½ gerado um vetor de dados para controle
	(cAliasDCF)->(dbEval({|| aAdd( aOrdSerExe,(cAliasDCF)->RECNODCF)}))
	(cAliasDCF)->(dbCloseArea())

	If Empty(aOrdSerExe)
		RestArea(aAreaDCF)
		Return Nil
	EndIf

	WMSCTPENDU() // Cria as temporï¿½rias - FORA DA TRANSAï¿½ï¿½O
	ProcRegua(Len(aOrdSerExe))
	If lAglutinado
		aEndereco := GetEndereco(aOrdSerExe) //RODOLFO - retorno os endereços automaticamente
	EndIf
	oOrdSerExe:SetArrLib(oRegraConv:GetArrLib())
	For nI := 1 To Len(aOrdSerExe)
		oOrdSerExe:GoToDCF(aOrdSerExe[nI])
		If (oOrdSerExe:GetStServ() $ "1|2") .And. Empty(oOrdSerExe:cStRadi)
			IncProc(oOrdSerExe:GetServico()+" - "+If(Empty(oOrdSerExe:GetCarga()),Trim(oOrdSerExe:GetDocto())+"/"+Trim(oOrdSerExe:GetSerie()),Trim(oOrdSerExe:GetCarga()))+"/"+Trim(oOrdSerExe:oProdLote:GetProduto()))
			If lAglutinado .And. Len(aEndereco) == len(aOrdSerExe)
				oOrdSerExe:UpdEndDes(aEndereco[nI]) //AJUSTE RODOLFO - SETO O ENDEREÇO PRO PROGRAMA NAO PEDIR
			EndIf

			If lAglutinado .And. !lSegSepara
				If Len(aEndereco) == len(aOrdSerExe)
					oOrdSerExe:ExecuteDCF()
					//Gravo o status da liberação do WMS
					SC9->(DbSetOrder(9))
					If SC9->(DbSeek(xFilial('SC9') + DCF->DCF_ID  ))
						While SC9->(C9_FILIAL + C9_IDDCF) == xFilial('SC9')  + DCF->DCF_ID
							RecLock('SC9',.F.)
							SC9->C9_XLOGWMS := UsrRetName( retcodusr() ) + ";" + DTOC(dDataBase) + ";" + Time()  + ";" + FUNNAME() + " Execução de serviço;" + SC9->C9_BLWMS
							MsUnlock()	
							SC5->(DbSetOrder(1))
							If SC5->(DbSeek(xFilial('SC5') + SC9->C9_PEDIDO))
								RecLock('SC5',.F.)
								SC5->C5_XLOGWMS := UsrRetName( retcodusr() ) + ";" + DTOC(dDataBase) + ";" + Time()  + ";" + FUNNAME() + ";" + SC9->C9_BLWMS
								MsUnLock()
							EndIf
							SC9->(DbSkip())
						EndDo
					EndIf					
				Else
					Alert('Não foram encontrados endereços disponivels!')
				EndIf
			Else
				If lSegSepara //Rodolfo - Tratamento para gravar 
					DCF->(DbGoTo(aOrdSerExe[nI]))
					SC9->(DbSetOrder(2))
					If SC9->(DbSeek(xFilial('SC9') + DCF->(DCF_CLIFOR + DCF_LOJA )  + PADR(DCF->DCF_DOCTO,TamSX3('C9_PEDIDO')[1]) + PADR(DCF->DCF_SERIE,TamSX3('C9_ITEM')[1])))
						
						aadd(_arrDCF,{xFilial('D14') + DCF->DCF_LOCDES + DCF->DCF_CODPRO + DCF->DCF_ENDDES + DCF->DCF_LOTECT ,;
									 DCF->DCF_QUANT ,;
									 DCF->DCF_QTSEUM ,;
									 DCF->DCF_ENDDES})

						oOrdSerExe:UpdEndOri(DCF->DCF_ENDER)						
						oOrdSerExe:UpdEndDes(DCF->DCF_ENDDES)	
					EndIf
				EndIf
				oOrdSerExe:ExecuteDCF()
			EndIf
		EndIf
	Next
	// Verifica as movimentaï¿½ï¿½es liberadas para verificar se hï¿½ reabastecimentos gerados
	oOrdSerExe:ChkOrdReab()
	// O wms devera avaliar as regras para convocacao do servico e disponibilizar os
	// registros do D12 para convocacao
	oRegraConv:LawExecute()
	// Exibe as mensages de erro na ordem de serviï¿½o
	// Aviso
	If !lAutomato
		oOrdSerExe:ShowWarnig()
		//-- Exibe as mensagens de reabastecimento
		If SuperGetMV('MV_WMSEMRE',.F.,.T.) .And. !Empty(oOrdSerExe:aWmsReab)
			TmsMsgErr(oOrdSerExe:aWmsReab, STR0028) // Reabastecimentos pendentes:
		EndIf
		If Len(oOrdSerExe:GetLogSld()) > 0 .And. (oOrdSerExe:HasLogSld() .Or. SuperGetMV('MV_WMSRLSA',.F.,.F.))
			cMensagem := ""
			// Se a impressï¿½o ï¿½ forï¿½ada, nï¿½o mostra a mensagem de OS nï¿½o atendida
			If !SuperGetMV('MV_WMSRLSA',.F.,.F.)
				cMensagem := STR0016+CRLF // Existem ordens de serviï¿½o de apanhe que nï¿½o foram totalmente atendidas.
			EndIf
			cMensagem += STR0017 // Deseja imprimir o relatï¿½rio de busca de saldo para o apanhe?
			If WmsQuestion(cMensagem,WMSA15003)
				WMSR111(oOrdSerExe:GetLogSld())
			EndIf
		EndIf
		If Len(oOrdSerExe:GetLogEnd()) > 0 .And. (oOrdSerExe:HasLogEnd() .Or. SuperGetMV('MV_WMSRLEN',.F.,.F.))
			cMensagem := ""
			// Se a impressï¿½o ï¿½ forï¿½ada, nï¿½o mostra a mensagem de OS nï¿½o atendida
			If !SuperGetMV('MV_WMSRLEN',.F.,.F.)
				cMensagem := STR0018+CRLF // Existem ordens de serviï¿½o de endereï¿½amento que nï¿½o foram totalmente atendidas.
			EndIf
			cMensagem += STR0019 // Deseja imprimir o relatï¿½rio de busca de endereï¿½os para a armazenagem?
			If WmsQuestion(cMensagem,WMSA15004)
				WMSR121(oOrdSerExe:GetLogEnd())
			EndIf
		EndIf
		If Len(oOrdSerExe:GetLogUni()) > 0 .And. (oOrdSerExe:HasLogUni() .Or. SuperGetMV('MV_WMSRLEN',.F.,.F.))
			cMensagem := ""
			// Se a impressï¿½o ï¿½ forï¿½ada, nï¿½o mostra a mensagem de OS nï¿½o atendida
			If !SuperGetMV('MV_WMSRLEN',.F.,.F.)
				cMensagem := STR0035+CRLF // Existem ordens de serviï¿½o de endereï¿½amento unitizado que nï¿½o foram totalmente atendidas.
			EndIf
			cMensagem += STR0036 // Deseja imprimir o relatï¿½rio de busca de endereï¿½os para a armazenagem unitizada?
			If WmsQuestion(cMensagem,WMSA15004)
				WMSR125(oOrdSerExe:GetLogUni())
			EndIf
		EndIf
	EndIf
	WMSDTPENDU() // Destroy as temporï¿½rias - FORA DA TRANSAï¿½ï¿½O
	RestArea(aAreaDCF)
Return lEnd
/*--------------------------------------------------------------------*/
Static Function ReverseSrv(lEnd)
Local aAreaDCF   := DCF->(GetArea())
Local cAliasDCF  := GetNextAlias()
Local cQuery     := ""
Local cSrvVazio  := PadR("", TamSx3("DCF_SERVIC")[1])
Local oOrdSerRev := WMSDTCOrdemServicoReverse():New()
Local oOrdserDel := Nil
Local oOrdSerExe := Nil
Local oRegraConv := Nil
Local aOrdSerEst := {}
Local nDcfRec	 := 0
Local nI         := 0
Local  cSrv		 := SuperGetMV('ES_SERVDIS',.T.,'019',cFilAnt)
Local  cSegSepara	 := SuperGetMV('ES_SERVSEP',.T.,'025',cFilAnt)
Local cNumSeq	:= ''
	// Verifica se opï¿½ï¿½o do filtro permite operaï¿½ï¿½o
	// Verificar data do ultimo fechamento em SX6
	If MVUlmes() >= dDataBase
		WmsMessage(STR0020,WMSA15006,,,,STR0021) // Nï¿½o pode ser digitado movimento com data anterior a ï¿½ltima data de fechamento (virada de saldos). // Utilizar data posterior ao ï¿½ltimo fechamento de estoque (MV_ULMES) / posterior ï¿½ data do bloqueio de movimentos (MV_DBLQMOV).
		Return Nil
	EndIf

	cQuery := "SELECT R_E_C_N_O_ RECNODCF"
	cQuery +=  " FROM "+RetSqlName('DCF')
	cQuery += " WHERE DCF_FILIAL = '"+xFilial("DCF")+"'"
	If mv_par01 == mv_par02
		cQuery += " AND DCF_SERVIC = '"+mv_par01+"'"
	Else
		cQuery += " AND DCF_SERVIC BETWEEN '"+mv_par01+"' AND '"+mv_par02+"'"
	EndIf
	If Empty(mv_par01) .Or. Empty(mv_par02)
		cQuery += " AND DCF_SERVIC <> '"+cSrvVazio+"'"
	EndIf
	If mv_par03 == 2 // Estorna Somente Servicos Executados
		cQuery += " AND DCF_STSERV = '2'"
	ElseIf mv_par03 == 3 // Estorna Somente Servicos Interrompidos
		cQuery += " AND DCF_STSERV = '3'"
	ElseIf mv_par03 == 5 // Estorna Somente Servicos Aptos ao Estorno (Executados e Iterrompidos)
		cQuery += " AND DCF_STSERV IN ('2','3')"
	EndIf
	cQuery += " AND DCF_OK = '"+GetMark150()+"'"
	cQuery += " AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDCF,.F.,.T.)
	// Devido processo de execuï¿½ï¿½o efetuar o disarmtransaction ha situaï¿½ï¿½es que o cache ï¿½ limpo
	// e perde-se o cAliasDCF por isso ï¿½ gerado um vetor de dados para controle
	(cAliasDCF)->(dbEval({|| AAdd(aOrdSerEst,(cAliasDCF)->RECNODCF)}))
	(cAliasDCF)->(dbCloseArea())

	If Empty(aOrdSerEst)
		RestArea(aAreaDCF)
		Return Nil
	EndIf

	WMSCTPENDU() // Cria as temporï¿½rias - FORA DA TRANSAï¿½ï¿½O
	ProcRegua(Len(aOrdSerEst))
	For nI := 1 To Len(aOrdSerEst)
		If lEnd
			Exit
		EndIf
		Begin Transaction
			oOrdSerRev:GoToDCF(aOrdSerEst[nI])

			DCF->(DbGoTo(aOrdSerEst[nI]))
			
			If DCF->DCF_SERVIC == cSegSepara .And. DCF->DCF_STSERV == '1'

				SC9->(DbSetOrder(9))
				If SC9->(DbSeek(xFilial('SC9') + DCF->DCF_ID  ))
					While SC9->(C9_FILIAL + C9_IDDCF) == xFilial('SC9')  + DCF->DCF_ID
						RecLock('SC9',.F.)
						SC9->(DbDelete())
						MsUnlock()	
						SC9->(DbSkip())
					EndDo
					
				EndIf

				nDcfRec := DCF->(Recno())
				cNumSeq := DCF->DCF_NUMSEQ


				D14->(DbSetOrder(3))
				If D14->(DbSeek(xFilial('D14')  + DCF->DCF_LOCDES + DCF->DCF_CODPRO + DCF->DCF_ENDDES + DCF->DCF_LOTECT))
					If D14->D14_QTDEPR >= DCF->DCF_QUANT
						Reclock('D14',.F.)
						D14->D14_QTDEPR -= DCF->DCF_QUANT
						D14->D14_QTDEP2	-= DCF->DCF_QTSEUM
						MsUnLock()

						If D14->D14_QTDEPR + D14->D14_QTDEST + D14->D14_QTDSPR + D14->D14_QTDEMP + D14->D14_QTDBLQ + D14->D14_QTDPEM == 0
							Reclock('D14',.F.)
							D14->(DbDelete())
							MsUnLock()
						EndIf
						
						If D14->(DbSeek(xFilial('D14')  + DCF->DCF_LOCAL + DCF->DCF_CODPRO + DCF->DCF_ENDER + DCF->DCF_LOTECT))
							Reclock('D14',.F.)
							D14->D14_QTDSPR -= DCF->DCF_QUANT
							D14->D14_QTDSP2	-= DCF->DCF_QTSEUM
							D14->D14_QTDPEM	-= DCF->DCF_QUANT
							D14->D14_QTDPE2 -= DCF->DCF_QTSEUM
							D14->D14_QTDEMP += DCF->DCF_QUANT
							D14->D14_QTDEM2 += DCF->DCF_QTSEUM
							MsUnLock()					
						EndIf	
					Else
						If D14->(DbSeek(xFilial('D14')  + DCF->DCF_LOCAL + DCF->DCF_CODPRO + DCF->DCF_ENDER + DCF->DCF_LOTECT))
							Reclock('D14',.F.)
							D14->D14_QTDEMP += DCF->DCF_QUANT
							D14->D14_QTDEM2 += DCF->DCF_QTSEUM
							MsUnLock()					
						EndIf		
					EndIf
				EndIf

				RecLock('DCF',.F.)
				DCF->(DbDelete())
				MsUnlock()

				DCF->(DbSetOrder(3))
				If DCF->(DbSeek(xFilial('DCF') + cSrv + DCF->(DCF_CODPRO+DCF_DOCTO+DCF_SERIE+DCF_CLIFOR+DCF_LOJA)))
					If DCF->DCF_NUMSEQ == cNumSeq
						//Rodolfo - Seto a SC6 para a primeira separação
						SC6->(DbSetOrder(1))
						If SC6->(DbSeek(xFilial('SC6') + PADR(DCF->DCF_DOCTO,TamSX3('C6_NUM')[1]) + PADR(DCF->DCF_SERIE,TamSX3('C6_ITEM')[1]) + PADR(DCF->DCF_CODPRO,TamSX3('C6_PRODUTO')[1])))
							RecLock('SC6',.F.)
							SC6->C6_SERVIC := cSrv
							MsUnlock()	
						EndIf			
						If !RestSC9(DCF->DCF_ID )					
							DisarmTransaction()
						EndIf
					EndIf
				EndIf

				DeletaSZG(DCF->DCF_DOCTO) //Apago as SZG

			Else
				IncProc(oOrdSerRev:GetServico()+" - "+If(Empty(oOrdSerRev:GetCarga()),oOrdSerRev:GetDocto()+"/"+oOrdSerRev:GetSerie(),oOrdSerRev:GetCarga())+"/"+oOrdSerRev:oProdLote:GetProduto())
				// Verifica se ordem de serviï¿½o pode ser estornada
				oOrdSerRev:SetEstSerA(mv_par19 == 1) // Indica se as O.S originadas da O.S estorna devem ser estornadas automaticamente
				If oOrdSerRev:CanReverse()
					If !oOrdSerRev:ReverseDCF()
						DisarmTransaction()
					EndIf
				EndIf					
			EndIf
			//Fim da alteração
	
		End Transaction
	Next

	If !lEnd
		// Verifica se hï¿½ ordens de serviï¿½o  de reabastecimento originados
		// das ordem de serviï¿½o estornadas para efetuar o estorno.
		If Len(oOrdSerRev:aOrdReab) > 0
			oOrdSerDel := WMSDTCOrdemServicoDelete():New()
			For nI := 1 To Len(oOrdSerRev:aOrdReab)
				Begin Transaction
					oOrdSerDel:SetIdDCF(oOrdSerRev:aOrdReab[nI])
					If oOrdSerDel:LoadData()
						// Somente os serviï¿½os que nï¿½o forem transferencia de devoluï¿½ï¿½o
						// Se for reabastecimento com origem preenchida, ï¿½ executado
						// automï¿½tico independente da configuraï¿½ï¿½o do serviï¿½o utilizado.
						oOrdSerDel:oServico:SetTpExec("2")
						If oOrdSerDel:CanDelete()
							oOrdSerDel:DeleteDCF()
						Else
							oOrdSerDel:SetIdOrig("")
							oOrdSerDel:UpdateDCF()
						EndIf
					EndIf
				End Transaction
			Next nI
		EndIf
		// Verifica as Ordens de servico geradas para execuï¿½ï¿½o automatica
		If Len(oOrdSerRev:aLibDCF) > 0
			oOrdSerExe := WMSDTCOrdemServicoExecute():New()
			oRegraConv := WMSBCCRegraConvocacao():New()
			For nI := 1 To Len(oOrdSerRev:aLibDCF)
				oOrdSerExe:SetIdDCF(oOrdSerRev:aLibDCF[nI])
				If oOrdSerExe:LoadData()
					oOrdSerExe:SetArrLib(oRegraConv:GetArrLib())
					oOrdSerExe:ExecuteDCF()
				EndIf
			Next nI
			If !Empty(oRegraConv:GetArrLib())
				oRegraConv:LawExecute()
			EndIf
			// Copiando as mensagens de aviso da execuï¿½ï¿½o para o array do objeto atual
			If !Empty(oOrdSerExe:aWmsAviso)
				AEval(oOrdSerExe:aWmsAviso, {|x| AAdd(oOrdSerRev:aWmsAviso,x)})
			EndIf
		EndIf
		// Aviso
		If !lAutomato
			oOrdSerRev:ShowWarnig()
		EndIf
	EndIf
	WMSDTPENDU() // Destroy as temporï¿½rias - FORA DA TRANSAï¿½ï¿½O
	RestArea(aAreaDCF)
Return lEnd
//-----------------------------------
/*{Protheus.doc}
Altera o Serviï¿½o das Ordens de Serviï¿½o selecionadas

@author Tiago Filipe da Silva
@version P11
@Since   05/02/14
@obs
*/
//-----------------------------------
Static Function UpdServico(cServico)
Local lRet       := .T.
Local aAreaDCF   := DCF->(GetArea())
Local cAliasDCF  := GetNextAlias()
Local nStServ    := mv_par03
Local cSrvVazio  := PadR("", TamSx3("DCF_SERVIC")[1])
Local cTipoServ  := ""
Local cTipoServ2 := ""
Local cCodServ   := ""
Local cCodServ2  := ""
Local lOk        := .T.
Local lAchou     := .F.
Local oOrdServ   := WMSDTCOrdemServico():New()
Local oServico   := WMSDTCServicoTarefa():New()
Local  cSegSepara	 := SuperGetMV('ES_SERVSEP',.T.,'025',cFilAnt)
Default cServico   := PadR("", TamSx3("DCF_SERVIC")[1])

	If DCF->DCF_SERVIC == cSegSepara
		WmsMessage('Não é possivel alterar serviços de segunda separação!','WMSA15099',1)
		RestArea(aAreaDCF)
		Return .F.
	EndIf

	If nStServ == 1 .Or. nStServ == 2 .Or. nStServ == 4 
		cAliasDCF := GetNextAlias()
		cQuery := " SELECT DCF.DCF_ID,DCF.DCF_SERVIC, DCF.R_E_C_N_O_ RECNODCF FROM "+RetSqlName('DCF')+" DCF"
		cQuery += " WHERE DCF.DCF_FILIAL = '"+xFilial("DCF")+"'"
		If mv_par01 == mv_par02
			cQuery += " AND DCF.DCF_SERVIC = '"+mv_par01+"'"
		Else
			cQuery += " AND DCF.DCF_SERVIC BETWEEN '"+mv_par01+"' AND '"+mv_par02+"'"
		EndIf
		If Empty(mv_par01) .Or. Empty(mv_par02)
			cQuery += " AND DCF.DCF_SERVIC <> '"+cSrvVazio+"'"
		EndIf
		If nStServ == 1         // Executa Somente Servicos ainda Nao Executados
			cQuery += " AND DCF.DCF_STSERV IN (' ','1')"
		ElseIf nStServ == 2     // Executa Somente Servicos Interrompidos
			cQuery += " AND DCF.DCF_STSERV = '2'"
		ElseIf nStServ == 4     // Executa Somente Servicos Aptos a Execucao (Nao Executados e Iterrompidos)
			cQuery += " AND DCF.DCF_STSERV IN ('1','2')"
		EndIf
		cQuery += " AND DCF.DCF_OK = '"+GetMark150()+"'"
		cQuery += " AND DCF.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDCF,.F.,.T.)
		If (cAliasDCF)->(!Eof())
			oServico:SetServico((cAliasDCF)->DCF_SERVIC)
			oServico:LoadData()
			cCodServ  := oServico:GetServico()
			cTipoServ := oServico:GetTipo()
			// Obtem o primeiro servico para comparacao
			While (cAliasDCF)->(!Eof())
				// Verifica se o tipo de servico das ordens de servico selecionadas sï¿½o
				oServico:SetServico((cAliasDCF)->DCF_SERVIC)
				oServico:LoadData()
				cCodServ2  := oServico:GetServico()
				cTipoServ2 := oServico:GetTipo()
				If cTipoServ <> cTipoServ2
					lOk := .F.
					Exit
				EndIf
				(cAliasDCF)->(DbSkip())
			EndDo

			If lOk
				lAchou := .F.
				While !lAchou
					If lAutomato .Or. ConPad1(,,, 'DC5',,, .F.)
						If DC5->DC5_SERVIC == cSegSepara
							lOk    := .F.
							lAchou := .T.
							WmsMessage('Favor selecionar outro serviço!','Não é permitido alterar um serviço para ' + AllTrim(cSegSepara) + ' !',1)
						Else
							If !lAutomato 
								cServico := DC5->DC5_SERVIC
							EndIf
							If !Empty(cServico) .AND. ChkTipServ(cServico, cTipoServ)
								lAchou := .T.
							EndIf
						EndIf
					Else
						lAchou := .T.
						lOk    := .F.
					EndIf
				EndDo
				If lOk
					If WMSQuestion(STR0023,WMSA15008) // Todos os itens marcados serao alterados, deseja confimar?
						(cAliasDCF)->(dbGoTop())
						While (cAliasDCF)->(!Eof())
							DCF->( dbGoto((cAliasDCF)->RECNODCF) )
							//Rodolfo - Limpo o DCF_ENDDES
							If Empty(DCF->DCF_CARGA)
								Reclock('DCF',.F.)
								DCF->DCF_ENDDES := ' '
								MsUnLock()
							EndIf
							oOrdServ:SetIdDCF(DCF->DCF_ID)
							oOrdServ:LoadData()
							If (oOrdServ:GetStServ() $ "1|2")
								If oOrdServ:GetServico() <> cServico
									oOrdServ:SetServico(cServico)
									oOrdServ:UpdateDCF()
									oOrdServ:UpdServic()
								EndIf
							EndIf
							(cAliasDCF)->( dbSkip())
						EndDo
					EndIf
				EndIf
			Else
				WmsMessage(STR0024,WMSA15009,1)// Hï¿½ ordens de serviï¿½o marcadas com tipo de serviï¿½o diferente.
				lRet := .F.
			EndIf
		Else
			WmsMessage(STR0025,WMSA15010,1)// Nenhuma ordem de serviï¿½o foi selecionada.
		EndIf
		(cAliasDCF)->(dbCloseArea())
	Else
		WmsMessage(STR0026,WMSA15011,1)// Parï¿½metro 'Status do Serviï¿½o' nï¿½o permite alteraï¿½ï¿½o.
		lRet := .F.
	EndIf
	RestArea(aAreaDCF)
	RefreshBrw()
Return lRet
/*---------------------------------------------------------*/
Static Function ChkTipServ(cServico,cTipoServ)
Local lRet     := .T.
Local oServico := WMSDTCServicoTarefa():New()
	// Verifica se o tipo de serviï¿½o do servico informado ï¿½ igual ao tipo de serviï¿½o das ordens de servico selecionadas
	oServico:SetServico(cServico)
	oServico:LoadData()
	If oServico:GetTipo() <> cTipoServ
		WmsMessage(STR0027,WMSA15012,1) // O tipo do serviï¿½o informado difere do tipo de serviï¿½o dos itens marcados.
		lRet := .F.
	EndIf
Return lRet
//-----------------------------------
/*{Protheus.doc}
Altera o tipo do unitizador na etiqueta do unitizador

@author Amanda Rosa Vieira
@version P12
@Since   26/06/2017
*/
//-----------------------------------
Static Function UpdTpUnit(cTpUnit)
Local lRet      := .T.
Local aAreaD0Y  := D0Y->(GetArea())
Local cAliasD0Y := GetNextAlias()
Local nStServ   := mv_par03
Default cTpUnit   := ""
	If nStServ == 1 .Or. nStServ == 2 .Or. nStServ == 4
		cQuery := " SELECT DISTINCT D0Y.R_E_C_N_O_ RECNOD0Y"
		cQuery +=   " FROM "+RetSqlName('DCF')+" DCF"
		cQuery +=  " INNER JOIN "+RetSqlName('D0Y')+" D0Y"
		cQuery +=     " ON D0Y.D0Y_FILIAL = '"+xFilial('D0Y')+"'"
		cQuery +=    " AND D0Y.D0Y_IDUNIT = DCF.DCF_UNIDES"
		cQuery +=    " AND D0Y.D0Y_TIPUNI = '"+Space(TamSX3('D0Y_TIPUNI')[1])+"'"
		cQuery +=    " AND D0Y.D_E_L_E_T_ = ' '"
		cQuery += " WHERE DCF.DCF_FILIAL = '"+xFilial("DCF")+"'"
		If mv_par01 == mv_par02
			cQuery += " AND DCF.DCF_SERVIC = '"+mv_par01+"'"
		Else
			cQuery += " AND DCF.DCF_SERVIC BETWEEN '"+mv_par01+"' AND '"+mv_par02+"'"
		EndIf
		If nStServ == 1         // Executa Somente Servicos ainda Nao Executados
			cQuery += " AND DCF.DCF_STSERV IN (' ','1')"
		ElseIf nStServ == 2     // Executa Somente Servicos Interrompidos
			cQuery += " AND DCF.DCF_STSERV = '2'"
		ElseIf nStServ == 4     // Executa Somente Servicos Aptos a Execucao (Nao Executados e Iterrompidos)
			cQuery += " AND DCF.DCF_STSERV IN ('1','2')"
		EndIf
		cQuery += " AND DCF.DCF_OK = '"+GetMark150()+"'"
		cQuery += " AND DCF.DCF_UNIDES <> '"+Space(TamSX3("DCF_UNIDES")[1])+"'"
		cQuery += " AND DCF.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasD0Y,.F.,.T.)
		If (cAliasD0Y)->(!Eof())
			If lAutomato .Or. ConPad1(,,, 'D0T',,, .F.)
				If !lAutomato
					cTpUnit := D0T->D0T_CODUNI
				EndIf
				If lAutomato .Or. WMSQuestion(STR0023,WMSA15014) // Todos os itens marcados serao alterados, deseja confimar?
					While (cAliasD0Y)->(!Eof())
						D0Y->( dbGoto((cAliasD0Y)->RECNOD0Y) )
						RecLock('D0Y', .F.)
						D0Y->D0Y_TIPUNI := cTpUnit
						D0Y->(MsUnLock())
						(cAliasD0Y)->( dbSkip())
					EndDo
				EndIf
			EndIf
		Else
			WmsMessage(STR0037,WMSA15015,1) //Nï¿½o hï¿½ ordens de serviï¿½o selecionadas com o tipo de unitizador indefinido.
		EndIf
		(cAliasD0Y)->(dbCloseArea())
	Else
		WmsMessage(STR0026,WMSA15015,1)// Parï¿½metro 'Status do Serviï¿½o' nï¿½o permite alteraï¿½ï¿½o.
		lRet := .F.
	EndIf
	RestArea(aAreaD0Y)
	RefreshBrw()
Return lRet


/*/{Protheus.doc} RetObslo
	(long_description)
	@type  Function
	@author user
	@since date
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function RetObslo(cDocto)
Local cRet	:= ''
Local cQuery := ''
Local cAliasQry := GetNextAlias()

cQuery := "SELECT CJ_ZZOBSLO "
cQuery += "  FROM " + RetSQLTab('SCJ')
cQuery += "  INNER JOIN " + RetSQLTab('SCK') + " ON CK_NUM = CJ_NUM AND CK_FILIAL = '" + xFilial('SCK') + "' "
cQuery += "  WHERE  "
cQuery += "  CJ_FILIAL = '" + xFilial('SCJ') + "' " 
cQuery += "  AND '" + cDocto + "' = CK_NUMPV "
cQuery += "  AND SCJ.D_E_L_E_T_ = ' '"
cQuery += "  AND SCK.D_E_L_E_T_ = ' '"

TcQuery cQuery new Alias ( cAliasQry )

If !(cAliasQry)->(EOF())
	cRet := (cAliasQry)->CJ_ZZOBSLO
EndIf

(cAliasQry)->(DbCloseArea())

Return cRet


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³DLQtdNorma³Autor  ³Fernando J. Siquini   ³ Data ³  06/30/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³ Retorna a Quantidade de Produtos (na 1a U.M.) definida na  ³±±
±±³          ³ Norma de Unitizacao.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Codigo do produto                                  ³±±
±±³          ³ ExpC2 - Armazem                                            ³±±
±±³          ³ ExpC3 - Codigo da estrutura fisica                         ³±±
±±³          ³ ExpC4 - Descricao do unitizador    (@)                     ³±±
±±³          ³ ExpL1 - .T. = Quantos unitizadores cabem em um endereco    ³±±
±±³          ³               blocado fracionado.                          ³±±
±±³          ³         .F. = Quantos produtos (na 1a.U.M.) cabem em um    ³±±
±±³          ³               unitizador.                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function DLQtdNorma(cProduto, cLocal, cEstruFis, cDesUni, lNUnit, cEndereco, cCodNorma)

Static lLastroPE  := ExistBlock("DLLASTRO")
Static lCamadaPE  := ExistBlock("DLCAMADA")
Static lQtdUnitPE := ExistBlock("DLQTDUNI")

Local nRet       := 0
Local aAreaAnt   := GetArea()
Local aAreaSB1   := SB1->(GetArea())
Local aAreaSB5   := SB5->(GetArea())
Local aAreaDC2   := DC2->(GetArea())
Local aAreaDC3   := DC3->(GetArea())
Local aTamSX3    := {}
Local cQuery     := ""
Local cAliasQry  := Nil
Local nLastro    := 0
Local nLastroPE  := 0
Local nCamada    := 0
Local nCamadaPE  := 0
Local nQtdUnit   := 1
Local nQtdUnitPE := 1
Local nPorcOcup  := 0
Local lChangeDC3 := .F.
Local lWmsNew    := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local lDC8SBEUni := (WmsX312120("DC8","DC8_NRUNIT") .And. WmsX312120("SBE","BE_NRUNIT"))
Local lNNRUni    := WmsX312120("NNR","NNR_AMZUNI")

Default lNUnit   := .T.
Default cEndereco:= ""
Default cCodNorma:= ""
Default cDesUni  := ""

	// Quando número de unitizadores é controlado pela estrutura física ou endereço
	cQuery := "SELECT DC3.DC3_CODNOR,"
	cQuery +=       " DC8.DC8_TPESTR,"
	cQuery +=   IIf(lNNRUni," CASE WHEN NNR.NNR_AMZUNI IS NULL THEN '2' ELSE NNR.NNR_AMZUNI END NNR_AMZUNI,"," 2 NNR_AMZUNI,")
	cQuery +=   IIf(lDC8SBEUni," CASE WHEN DC8.DC8_NRUNIT IS NULL THEN 0 ELSE DC8.DC8_NRUNIT END DC8_NRUNIT,"," 0 DC8_NRUNIT,")
	cQuery +=   IIf(lDC8SBEUni," CASE WHEN SBE.BE_NRUNIT IS NULL THEN 0 ELSE SBE.BE_NRUNIT END BE_NRUNIT,"," 0 BE_NRUNIT,")
	cQuery +=       " DC3.DC3_NUNITI"
	cQuery +=  " FROM "+RetSqlName("DC3")+" DC3"
	cQuery += " INNER JOIN "+RetSqlName("NNR")+" NNR"
	cQuery +=    " ON NNR.NNR_FILIAL = '"+xFilial("NNR")+"'"
	cQuery +=   " AND NNR.NNR_CODIGO = DC3.DC3_LOCAL"
	cQuery +=   " AND NNR.D_E_L_E_T_ = ' '"
	cQuery += " INNER JOIN "+RetSqlName("DC8")+" DC8"
	cQuery +=    " ON DC8.DC8_FILIAL = '"+xFilial("DC8")+"'"
	cQuery +=   " AND DC8.DC8_CODEST = DC3.DC3_TPESTR"
	cQuery +=   " AND DC8.D_E_L_E_T_ = ' '"
	cQuery +=  " LEFT JOIN "+RetSqlName("SBE")+" SBE"
	cQuery +=    " ON SBE.BE_FILIAL = '"+xFilial("SBE")+"'
	cQuery +=   " AND SBE.BE_LOCALIZ = '"+cEndereco+"'"
	cQuery +=   " AND SBE.BE_ESTFIS = DC3.DC3_TPESTR"
	cQuery +=   " AND SBE.BE_LOCAL = DC3.DC3_LOCAL"
	cQuery +=   " AND SBE.D_E_L_E_T_ = ' '"
	cQuery += " WHERE DC3.DC3_FILIAL = '"+xFilial("DC3")+"'
	cQuery +=   " AND DC3.DC3_CODPRO = '"+cProduto+"'"
	cQuery +=   " AND DC3.DC3_LOCAL = '"+cLocal+"'"
	cQuery +=   " AND DC3.DC3_TPESTR = '"+cEstruFis+"'"
	cQuery +=   " AND DC3.D_E_L_E_T_ = ' '"	
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
	aTamSX3 := TamSX3("DC3_NUNITI")
	TcSetField(cAliasQry,'DC3_NUNITI','N',aTamSX3[1],aTamSX3[2])
	TcSetField(cAliasQry,'DC8_NRUNIT','N',aTamSX3[1],aTamSX3[2])
	TcSetField(cAliasQry,'BE_NRUNIT' ,'N',aTamSX3[1],aTamSX3[2])
	If (cAliasQry)->(!Eof())
		lChangeDC3 := .T.
		If lNUnit
			// Quando armazém controla unitizador e a estrutura física não for 2-Picking ou 7-Produção
			// Irá verificar o número de unitizadores cadastrado na estrutura física e no endereço
			// Caso contrário irá verificar na sequencia de abastecimento do produto
			If lDC8SBEUni .And. (cAliasQry)->NNR_AMZUNI == '1' .And. !((cAliasQry)->DC8_TPESTR $ "2|7")
				If (cAliasQry)->DC8_NRUNIT > 0
					nQtdUnit := (cAliasQry)->DC8_NRUNIT
					If !Empty(cEndereco) .And. (cAliasQry)->BE_NRUNIT > 0
						nQtdUnit := (cAliasQry)->BE_NRUNIT
					EndIf
				EndIf
			Else
				If (cAliasQry)->DC3_NUNITI > 0
					nQtdUnit := (cAliasQry)->DC3_NUNITI
				EndIf
			EndIf
		EndIf
		If Empty(cCodNorma)
			cCodNorma := (cAliasQry)->DC3_CODNOR
		EndIf
	EndIf
	(cAliasQry)->(dbCloseArea())
	
	If lQtdUnitPE
		If ValType(nQtdUnitPE:=ExecBlock('DLQTDUNI',.F.,.F.,{cProduto,cLocal,cEstruFis,nQtdUnit,lNUnit}))=='N'
			nQtdUnit := nQtdUnitPE
		EndIf
	EndIf
	
	If lLastroPE .And. lCamadaPE .And. (ValType(nLastroPE:=ExecBlock('DLLASTRO',.F.,.F.,{cProduto,cLocal,cEstruFis}))=='N') .And. (ValType(nCamadaPE:=ExecBlock('DLCAMADA',.F.,.F.,{cProduto,cLocal,cEstruFis}))=='N')
		nLastro := nLastroPE
		nCamada := nCamadaPE
	Else
		If lChangeDC3
			DbSelectArea('DC2')
			DC2->(DbSetOrder(1)) //DC2_FILIAL+DC2_CODNOR
			If DC2->(MsSeek(xFilial('DC2')+cCodNorma, .F.))
				If lLastroPE .And. ValType(nLastroPE:=ExecBlock('DLLASTRO',.F.,.F.,{cProduto,cLocal,cEstruFis})) == 'N'
					nLastro := nLastroPE
				Else
					nLastro := DC2->DC2_LASTRO
				EndIf
				If lCamadaPE .And. ValType(nCamadaPE:=ExecBlock('DLCAMADA',.F.,.F.,{cProduto,cLocal,cEstruFis})) == 'N'
					nCamada := nCamadaPE
				Else
					nCamada := DC2->DC2_CAMADA
				EndIf
	
				If ValType(cDesUni)=='C'
					cDesUni := Posicione('D0T',1,xFilial('D0T')+DC2->DC2_CODUNI,'D0T_DESUNI')
				EndIf
	
				If !Empty(cEndereco)
					DCP->(DbSetOrder(1)) //DCP_FILIAL+DCP_LOCAL+DCP_ENDERE+DCP_ESTFIS+DCP_NORMA+DCP_CODPRO
					// --- Pesquisa se existe % de ocupacao cadastrado para este endereco/produto.
					If DCP->(MsSeek(xFilial('DCP')+cLocal+cEndereco+cEstruFis+cCodNorma+cProduto, .F.))
						nPorcOcup := DCP->DCP_PORCEN
					// --- Pesquisa se existe % de ocupacao cadastrado para este endereco, para qualquer produto.
					ElseIf DCP->(MsSeek(xFilial('DCP')+cLocal+cEndereco+cEstruFis+cCodNorma+CriaVar("DCP_CODPRO",.F.), .F.))
						nPorcOcup := DCP->DCP_PORCEN
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	
	nRet := nLastro*nCamada*nQtdUnit
	If nPorcOcup > 0
		nRet := Int(nRet * nPorcOcup/100)
	EndIf
	
	SB1->(DbSetOrder(1))
	SB5->(DbSetOrder(1))
	If SB5->(MsSeek(xFilial('SB5')+cProduto)) .And. SB1->(MsSeek(xFilial('SB1')+cProduto))
		If !(SB5->B5_UMIND=='1') .And. QtdComp(SB1->B1_CONV) <> QtdComp(0)
			nRet := ConvUm(cProduto, 0, nRet, 1)
		EndIf
	EndIf
	
	RestArea(aAreaDC3)
	RestArea(aAreaDC2)
	RestArea(aAreaSB5)
	RestArea(aAreaSB1)
	RestArea(aAreaAnt)
Return nRet


 /*/{Protheus.doc} GetEndereco
	Retorno endereço automaticamente
	@type  Function
	@author user
	@since date
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function GetEndereco(aDCF)
Local aRetorno := {}
Local  cQrySBE	 := ''
Local  cQryD12   := ''
Local  cAliasQry := GetNextAlias()
Local aEnd	:= {}
Local nI	:= 0
Local nX	:= 0


If SELECT('QRYSBE') > 0
	QRYSBE->(DbCloseArea())
EndIf

cQrySBE	:= " SELECT * FROM " + RetSqlName("SBE") + " SBE "
cQrySBE  += " INNER JOIN "  + RetSqlName("DC8") + " DC8 ON DC8_CODEST = BE_ESTFIS  AND DC8_TPESTR IN ('5') AND DC8.D_E_L_E_T_ = '' " 
cQrySBE	+= " WHERE BE_FILIAL = '" + xFilial('SBE') + "'
cQrySBE  += "   AND BE_CODZON IN ('000017','000016') " 
//cQrySBE  += "   AND BE_STATUS = '1' " 
cQrySBE	+= "   AND SBE.D_E_L_E_T_ = ''"
cQrySBE	+= "   ORDER BY BE_LOCALIZ "


TCQUERY cQrySBE Alias "QRYSBE"				    

dbSelectArea( 'QRYSBE' )
dbGoTop()

D14->(DbSetOrder(1))
While QRYSBE->( !Eof() ) 
	If !D14->(DbSeek(xFilial('D14') + QRYSBE->BE_LOCAL + QRYSBE->BE_LOCALIZ))
		Aadd(aEnd,{QRYSBE->BE_CODZON,; //Tipo
					'',; //Codigo da Norma
					0,; //NORMA
					QRYSBE->BE_LOCALIZ,; //Endereço
					QRYSBE->BE_ESTFIS; //Tipo Estrutura
					})
	EndIf
	QRYSBE->( DbSkip() )
EndDo
QRYSBE->(DbCloseArea())

For nI := 1 to Len(aDCF)
	DCF->(dbGoTo(aDCF[nI]))
	SB1->( DbSetOrder( 1 ))
	SB1->( DbSeek( xFilial( 'SB1' ) + DCF->DCF_CODPRO ))	

	DC5->( DbSetOrder( 1 ) )
	If DC5->( DbSeek( xFilial( 'DC5' ) + DCF->DCF_SERVIC )) .AND. DC5->DC5_OPERAC == '3' //DC5_OPERAC = 3	

	//	If !empty(DCF->DCF_ENDDES)
	//		aadd(aRetorno,DCF->DCF_ENDDES)
	//	Else
			For nX := 1 to Len(aEnd) //Varro o proximo endereço disponivel
				If (aEnd[nX][1] == '000017' .And. SB1->B1_XCTGPRD == '1') .Or. (aEnd[nX][1] == '000016' .And. SB1->B1_XCTGPRD <> '1') //Valida o tipo
					DC3->(DbSetOrder(2))
					DC3->(DbSeek(xFilial('DC3') + DCF->DCF_CODPRO + DCF->DCF_LOCAL + aEnd[nX][5]))
					DC2->(DbSetOrder(1))
					DC2->(DbSeek(xFilial('DC2') + DC3->DC3_CODNOR))			
					If Empty(aEnd[nX][2]) //aEnd[nX][3] == 0   .And. aEnd[nX][2] == DC3->DC3_CODNOR) //endereço nao utilizado ou se a norma nao suporta, incluo um novo
						aEnd[nX][2] := DC2->DC2_CODNOR
						aEnd[nX][3] := (DC2->DC2_LASTRO * DC2->DC2_CAMADA) - DCF->DCF_QTSEUM
						aadd(aRetorno,aEnd[nX][4])
						exit
					Else 
						If aEnd[nX][3] >= DCF->DCF_QTSEUM 
							aEnd[nX][3] := aEnd[nX][3] - DCF->DCF_QTSEUM 
							aadd(aRetorno,aEnd[nX][4])
							exit
						EndIf				
					EndIf
				EndIf
			Next
	//	EndIf
	Else //serviço diferente de separação retorno em branco para o sistema pedir o endereço
		aadd(aRetorno,'')
	EndIf
Next
Return aRetorno


/*/{Protheus.doc} RtTransp
	(long_description)
	@type  Function
	@author user
	@since date
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
User Function RtTransp()
Return POSICIONE("SC5",1,xFilial("SC5") + DCF->DCF_DOCTO,"C5_TRANSP")

User Function RtNmTran()
Return POSICIONE('SA4',1,xFilial('SA4') + POSICIONE("SC5",1,xFilial("SC5") + DCF->DCF_DOCTO,"C5_TRANSP") , 'A4_NOME')

User Function RtColet()
Return POSICIONE("SC5",1,xFilial("SC5") + DCF->DCF_DOCTO,"C5_XOBCOL")

User Function RtDtCole()
Return POSICIONE("SC5",1,xFilial("SC5") + DCF->DCF_DOCTO,"C5_XDTCOL")

User Function RtTpFret()
Local aArea       := GetArea()
Local cChave	  := POSICIONE('SCJ',1,xFilial('SCJ') + POSICIONE("SC5",1,xFilial("SC5") + DCF->DCF_DOCTO,"C5_XNUMCJ") , 'CJ_XTPFRET')
Local aCombo      := {}
Local nAtual      := 1
Local cDescri     := ""
Local cConteudo   := ""
Local cCampo    := "CJ_XTPFRET"
	
//Se o campo e o conteúdo estiverem em branco, ou a chave estiver em branco, não há descrição a retornar
If (Empty(cCampo) .And. Empty(cConteudo)) .Or. Empty(cChave)
	cDescri := ""
Else
	//Se tiver campo
	If !Empty(cCampo)
		aCombo := RetSX3Box(GetSX3Cache(cCampo, "X3_CBOX"),,,1)
			
		//Percorre as posições do combo
		For nAtual := 1 To Len(aCombo)
			//Se for a mesma chave, seta a descrição
			If cChave == aCombo[nAtual][2]
				cDescri := aCombo[nAtual][3]
			EndIf
		Next
			
	//Se tiver conteúdo
	ElseIf !Empty(cConteudo)
		aCombo := StrTokArr(cConteudo, ';')
			
		//Percorre as posições do combo
		For nAtual := 1 To Len(aCombo)
			//Se for a mesma chave, seta a descrição
			If cChave == SubStr(aCombo[nAtual], 1, At('=', aCombo[nAtual])-1)
				cDescri := SubStr(aCombo[nAtual], At('=', aCombo[nAtual])+1, Len(aCombo[nAtual]))
			EndIf
		Next
	EndIf
EndIf
	
RestArea(aArea)
Return cDescri

/*/{Protheus.doc} RestSC9
	(long_description)
	@type  Static Function
	@author user
	@since date
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function RestSC9(cId)
Local cQuery 	:= ''
Local lRet	 	:= .T.
Local cAliasQry := GetNextAlias()
Local nI		:= 0
Local aCampos	:= {}
/*
cQuery := "UPDATE " + RetSqlName('SC9')
cQuery += " SET D_E_L_E_T_ = ' ' "
cQuery += "  WHERE  "
cQuery += "  C9_FILIAL  = '" + xFilial('SC9') + "' " 
cQuery += "  AND '" + cId + "' = C9_IDDCF "
cQuery += "  AND D_E_L_E_T_ = '*'"


If (TCSqlExec(cQuery) < 0)
	Alert('Erro na recuperação do registro da SC9 ' +CRLF + TCSQLError())
	lRet := .F.
EndIf
*/


for nI := 1 to SC9->(Fcount())
	Aadd(aCampos,SC9->(FieldName(nI)))
next

cQuery := "SELECT *,R_E_C_N_O_ AS REC FROM " + RetSqlName('SZZ')
cQuery += "  WHERE  "
cQuery += "  ZZ_FILIAL  = '" + xFilial('SZZ') + "' " 
cQuery += "  AND '" + cId + "' = ZZ_IDDCF " //UTILIZAMOS O NUMLOTE PARA NAO TER Q CRIAR UM CAMPO NOVO
cQuery += "  AND D_E_L_E_T_ = ' '"

TCQUERY cQuery new Alias (cAliasQry)			    

If (cAliasQry)->( !Eof() ) 
	SX3->(dbSetOrder(2))
	RecLock('SC9',.T.)
	For nI := 1 to Len(aCampos)
		If SX3->(DbSeek('ZZ_' + SUBSTR(aCampos[nI],4,len(aCampos[nI]))))
			If Alltrim(aCampos[nI]) == 'C9_NUMLOTE'
				SC9->C9_NUMLOTE := ' '
			Else
				If SX3->X3_TIPO == 'D'
					SC9->&(aCampos[nI]) := STOD((cAliasQry)->&('ZZ_' + SUBSTR(aCampos[nI],4,len(aCampos[nI]))))
				Else
					SC9->&(aCampos[nI]) := (cAliasQry)->&('ZZ_' + SUBSTR(aCampos[nI],4,len(aCampos[nI])))
				EndIf
			EndIf
		EndIf
	Next
	//SC9->C9_XLOGWMS := UsrRetName( retcodusr() ) + ";" + DTOC(dDataBase) + ";" + Time()  + ";" + FUNNAME() + " Estorno de serviço;" + SC9->C9_BLWMS
	MsUnLock()
Else
	lRet := .F.
EndIf

If lRet
	SZZ->(DbGoTo((cAliasQry)->REC))
	Reclock('SZZ',.F.)
	DbDelete()
	MsUnLock()
EndIf

Return lRet



/*/{Protheus.doc} DeletaSZG
	Excluo os registros da SZG apos o estorno do serviço 25
	@type  Function
	@author user
	@since date
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function DeletaSZG(cPedido)
Local cQuery 	:= ''
Local cAliasQry := GetNextAlias()

cQuery := "SELECT R_E_C_N_O_ AS REC FROM " + RetSqlName('SZG')
cQuery += "  WHERE  "
cQuery += "  ZG_FILIAL  = '" + xFilial('SZG') + "' " 
cQuery += "  AND '" + cPedido + "' = ZG_DOCTO "
cQuery += "  AND D_E_L_E_T_ = ' '"

TCQUERY cQuery new Alias (cAliasQry)			    

While (cAliasQry)->( !Eof() ) 
	SZG->(DbGoTo((cAliasQry)->REC))
	RecLock('SZG',.F.)
	DbDelete()
	MsUnLock()
	(cAliasQry)->(DbSkip())
EndDo

Return 

Static Function QbrNorma()
Local aArea := GetArea()
Local cAliasQry := GetNextAlias()
Local cSrv		 := SuperGetMV('ES_SERVDIS',.T.,'019',cFilAnt)
Local cQuery    := ''

cQuery := "	SELECT R_E_C_N_O_ AS REC " 
cQuery += " FROM " + RetSqlName( "SC9" ) + " SC9 "
cQuery += " WHERE SC9.D_E_L_E_T_ = ' ' AND "
cQuery += "		SC9.C9_FILIAL =  '" +  xFilial('SC9') + "' AND " 		
cQuery += "     SC9.C9_SERVIC =  '" + cSrv + "'	AND "	  		
cQuery += "     SC9.C9_BLEST = '  '  "	  		

If Select(cAliasQry) > 0
    (cAliasQry)->(DbCloseArea())
EndIf

TcQuery cQuery new Alias ( cAliasQry )
If !(cAliasQry)->(Eof())
    //SC9->(DbGoTo((cAliasQry)->REC))
    //U_AjustaC9(SC9->C9_PEDIDO)
EndIf

RestArea(aArea)

Return Nil
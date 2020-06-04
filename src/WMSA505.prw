#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "WMSA505.CH"

#DEFINE WMSA50501 "WMSA50501"
#DEFINE WMSA50502 "WMSA50502"
#DEFINE WMSA50503 "WMSA50503"
#DEFINE WMSA50504 "WMSA50504"
#DEFINE WMSA50505 "WMSA50505"
#DEFINE WMSA50506 "WMSA50506"
#DEFINE WMSA50507 "WMSA50507"
#DEFINE WMSA50508 "WMSA50508"
#DEFINE WMSA50509 "WMSA50509"
#DEFINE WMSA50510 "WMSA50510"
#DEFINE WMSA50511 "WMSA50511"
#DEFINE WMSA50512 "WMSA50512"
#DEFINE WMSA50513 "WMSA50513"
#DEFINE WMSA50514 "WMSA50514"
#DEFINE WMSA50515 "WMSA50515"
#DEFINE WMSA50516 "WMSA50516"
#DEFINE WMSA50517 "WMSA50517"
#DEFINE WMSA50518 "WMSA50518"
#DEFINE WMSA50519 "WMSA50519"
#DEFINE WMSA50520 "WMSA50520"
#DEFINE WMSA50521 "WMSA50521"
#DEFINE WMSA50522 "WMSA50522"
#DEFINE WMSA50523 "WMSA50523"
#DEFINE WMSA50524 "WMSA50524"
#DEFINE WMSA50525 "WMSA50525"
#DEFINE WMSA50526 "WMSA50526"
#DEFINE WMSA50527 "WMSA50527"
#DEFINE WMSA50528 "WMSA50528"
#DEFINE WMSA50529 "WMSA50529"
#DEFINE WMSA50530 "WMSA50530"
#DEFINE WMSA50531 "WMSA50531"
#DEFINE WMSA50532 "WMSA50532"
#DEFINE WMSA50533 "WMSA50533"
#DEFINE WMSA50534 "WMSA50534"
#DEFINE WMSA50535 "WMSA50535"
#DEFINE WMSA50536 "WMSA50536"
//-----------------------------------------------------------
// Embarques
/*/{Protheus.doc} WMSA505
Separação de Requisições para o WMS

@author  Tiago Filipe da Silva
@version P12
@Since	02/04/14
@version 1.0
/*/
Static cAliasSD4  := ""
Static cAliasPRD  := ""
Static oTmpTabSD4 := Nil
Static oTmpTabPRD := Nil
Static oEstEnder  := Nil
//-----------------------------------------------------------
Function WMSA505()
Local aCoors := FWGetDialogSize(oMainWnd)
Local aColsSD4   := {}
Local aColsPRD   := {}
Local aColsSX3   := {}
Local aRegra     := StrTokArr(Posicione('SX3',2,'DCF_REGRA','X3CBox()'),';')
Local oFWLayerMAS
Local oPnlCapa , oPnlDetail
Local lMarcar    := .F.
Local nPos       := 0

Private aCamposSD4 := {}
Private aCamposPRD := {}
Private oDlgPrinc
Private oBrwSD4, oBrwPRD
	If !SuperGetMV("MV_WMSNEW", .F., .F.)
		Return WMSA500()
	EndIf

	cAliasSD4 := GetNextAlias()
	cAliasPRD := GetNextAlias()

	// Cria tabela temporária dos produtos acumulados e das requisições
	createTemp()

	// Pergunte
	If Pergunte('WMSA505',.T.)
		oEstEnder := WMSDTCEstoqueEndereco():New()
		// Carrega os dados na tabela temporária de requisições
		CargaTemp()

		// Trata a altura da janela de acordo com a resolução
		DEFINE MSDIALOG oDlgPrinc TITLE STR0001 FROM aCoors[1], aCoors [2] To aCoors[3], aCoors[4] PIXEL STYLE NOr(WS_VISIBLE,WS_POPUP) // Requisições Empenhadas

		// Cria conteiner para os browses
		oFWLayerMAS := FWLayer():New()
		oFWLayerMAS:Init(oDlgPrinc, .F., .T.)

		// Define painel Master
		oFWLayerMAS:AddLine('UP',50, .T.)
		oPnlCapa := oFWLayerMAS:GetLinePanel('UP')

		// Campos adicionais
		aColsSD4:= {;
		{buscarSX3('D4_OP',,aColsSX3)      ,{|| (cAliasSD4)->D4_OP}     ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Ordem de Producao
		{buscarSX3('DCF_DOCTO',,aColsSX3)  ,{|| (cAliasSD4)->D4_DOCTO}  ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Documento WMS
		{buscarSX3('D4_LOCAL',,aColsSX3)   ,{|| (cAliasSD4)->D4_LOCAL}  ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Armazem
		{buscarSX3('D4_COD',,aColsSX3)     ,{|| (cAliasSD4)->D4_COD}    ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Produto
		{buscarSX3('B1_DESC',,aColsSX3)    ,{|| (cAliasSD4)->D4_DESC}   ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Descricao Produto
		{buscarSX3('D4_LOTECTL',,aColsSX3) ,{|| (cAliasSD4)->D4_LOTECTL},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Lote
		{buscarSX3('D4_NUMLOTE',,aColsSX3) ,{|| (cAliasSD4)->D4_NUMLOTE},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Sub-Lote
		{buscarSX3('D4_DATA',,aColsSX3)    ,{|| (cAliasSD4)->D4_DATA}   ,'D',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Data Empenho
		{buscarSX3('D4_QUANT',,aColsSX3)   ,{|| (cAliasSD4)->D4_QUANT}  ,'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Quantidade Empenho
		{buscarSX3('D4_QTSEGUM',,aColsSX3) ,{|| (cAliasSD4)->D4_QTSEGUM},'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Quantidade 2 unidade Empenho
		{buscarSX3('D4_TRT',,aColsSX3)     ,{|| (cAliasSD4)->D4_TRT}    ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1};  // Sequencia Estrutura
		}

		oBrwSD4 := FWMarkBrowse():New()
		oBrwSD4:SetDescription(STR0001) // Requisições Empenhadas
		oBrwSD4:SetAlias(cAliasSD4) // Alias da tabela utilizada
		oBrwSD4:SetFields(aColsSD4)
		oBrwSD4:SetOwner(oPnlCapa)
		oBrwSD4:SetFieldMark('D4_MARK')
		oBrwSD4:SetAmbiente(.F.)
		oBrwSD4:SetWalkThru(.F.)
		oBrwSD4:SetAfterMark({|| AfterMark(),oBrwSD4:Refresh(.T.) }) // Função para o Check
		oBrwSD4:bAllMark := {|| SetMarkAll(oBrwSD4:Mark(),lMarcar := !lMarcar),oBrwSD4:Refresh(.T.)}
		oBrwSD4:SetMenuDef('')
		oBrwSD4:ForceQuitButton(.T.)
		oBrwSD4:AddLegend(cAliasSD4+"->D4_SITU == '1'",'RED'    ,STR0002) // Não Solicitadas
		oBrwSD4:AddLegend(cAliasSD4+"->D4_SITU == '2'",'BLUE'   ,STR0003) // Não iniciadas
		oBrwSD4:AddLegend(cAliasSD4+"->D4_SITU == '3'",'YELLOW' ,STR0004) // Em Andamento
		oBrwSD4:AddLegend(cAliasSD4+"->D4_SITU == '4'",'GREEN'  ,STR0005) // Finalizadas
		oBrwSD4:DisableDetails()
		oBrwSD4:DisableFilter()
		oBrwSD4:oBrowse:SetFixedBrowse(.T.)
		oBrwSD4:AddButton(STR0006,{|| WMSA505MNU("1")},,5) // Estornar
		oBrwSD4:AddButton(STR0007,{|| Selecao()}      ,,3) // Selecionar
		oBrwSD4:SetProfileID('1')

		// Define painel Detail
		oFWLayerMAS:AddLine('DOWN', 50, .T.)
		oPnlDetail := oFWLayerMAS:GetLinePanel('DOWN')

		For nPos := 1 To Len(aRegra)
			aRegra[nPos] := StrTokArr(aRegra[nPos],'=')
		Next
		bRegra := {|| nPos := AScan(aRegra,{|x| x[1] == (cAliasPRD)->D4_REGRA}), Iif(nPos > 0, aRegra[nPos,2], '')}

		// Campos adicionais
		aColsPRD:= {;
		{buscarSX3('D4_COD',,aColsSX3)            ,{|| (cAliasPRD)->D4_COD}    ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Codigo Produto
		{buscarSX3('B1_DESC',,aColsSX3)           ,{|| (cAliasPRD)->D4_DESC}   ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Descrição Produto
		{buscarSX3('D4_LOTECTL',,aColsSX3)        ,{|| (cAliasPRD)->D4_LOTECTL},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Lote
		{buscarSX3('D4_NUMLOTE',,aColsSX3)        ,{|| (cAliasPRD)->D4_NUMLOTE},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Sub-lote
		{buscarSX3('B5_SERVREQ',,aColsSX3)        ,{|| (cAliasPRD)->D4_SERVIC} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.T.,,,,,,,,1},; // Servico
		{buscarSX3('DCF_REGRA',,aColsSX3)         ,bRegra                      ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.T.,,,,,,,,1},; // Regra WMS
		{buscarSX3('D14_LOCAL',STR0008,aColsSX3)  ,{|| (cAliasPRD)->D4_LOCORI} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.T.,,,,,,,,1},; // Armazém Origem
		{buscarSX3('D14_ENDER',STR0009,aColsSX3)  ,{|| (cAliasPRD)->D4_ENDORI} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Endereço Origem
		{buscarSX3('D14_LOCAL',STR0010,aColsSX3)  ,{|| (cAliasPRD)->D4_LOCDES} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.T.,,,,,,,,1},; // Armazém Destino
		{buscarSX3('D14_ENDER',STR0011,aColsSX3)  ,{|| (cAliasPRD)->D4_ENDDES} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Endereço Destino
		{buscarSX3('D4_QUANT',,aColsSX3)          ,{|| (cAliasPRD)->D4_QUANT}  ,'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Qtdade sumarizada das requisições
		{buscarSX3('D4_QTSEGUM',,aColsSX3)        ,{|| (cAliasPRD)->D4_QTSEGUM},'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Qtdade da segunda unidade sumarizada
		{buscarSX3('D4_QUANT',STR0014,aColsSX3)   ,{|| (cAliasPRD)->D4_SLDPRD} ,'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Saldo do produto na produção
		{buscarSX3('D4_QTSEGUM',STR0015,aColsSX3) ,{|| (cAliasPRD)->D4_SLDPR2} ,'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Saldo da segunda unidade do produto na produção
		{buscarSX3('D4_QUANT',STR0016,aColsSX3)   ,{|| (cAliasPRD)->D4_QTDSOL} ,'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.T.,,,,,,,,1},; // Qtdade à solicitar do produto no WMS
		{buscarSX3('D4_QTSEGUM',STR0017,aColsSX3) ,{|| (cAliasPRD)->D4_QTDSO2} ,'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.T.,,,,,,,,1};  // Qtdade da segunda unidade à solicitar do produto no WMS
		}

		oBrwPRD := FWMarkBrowse():New()
		oBrwPRD:SetAlias(cAliasPRD)
		oBrwPRD:SetOwner(oPnlDetail)
		oBrwPRD:SetFields(aColsPRD)
		oBrwPRD:SetFieldMark('D4_MARK')
		oBrwPRD:bAllMark := {|| MarkAllPro(oBrwPRD:Mark(),lMarcar := !lMarcar), oBrwPRD:Refresh(.T.)}
		oBrwPRD:SetMenuDef('WMSA505')
		oBrwPRD:SetWalkThru(.F.)
		oBrwPRD:SetAmbiente(.F.)
		oBrwPRD:oBrowse:SetFixedBrowse(.T.)
		oBrwPRD:SetDescription(STR0018) // Produtos Requisição

		oBrwPRD:AddLegend(cAliasPRD+"->D4_HASSLD == .F.",'RED'  ,STR0021) // Sem Saldo
		oBrwPRD:AddLegend(cAliasPRD+"->D4_HASSLD == .T.",'GREEN',STR0022) // Com Saldo

		oBrwSD4:Activate()
		oBrwPRD:Activate()

		Activate MsDialog oDlgPrinc Center

		delTabTmp(cAliasSD4,oTmpTabSD4)
		delTabTmp(cAliasPRD,oTmpTabPRD)
		
		oEstEnder:Destroy()
	EndIf
Return(Nil)
//-------------------------------------------------------------------//
//-------------------------Função MenuDef----------------------------//
//-------------------------------------------------------------------//
Static Function MenuDef()
Local aRotina := {}

	ADD OPTION aRotina TITLE STR0023 ACTION 'AxPesqui'                     OPERATION 1 ACCESS 0 // Pesquisar
	ADD OPTION aRotina TITLE STR0024 ACTION 'VIEWDEF.WMSA505'              OPERATION 2 ACCESS 0 // Visualizar
	ADD OPTION aRotina TITLE STR0025 ACTION 'VIEWDEF.WMSA505'              OPERATION 4 ACCESS 0 // Alterar
	ADD OPTION aRotina TITLE STR0019 ACTION 'StaticCall(WMSA505,CalcMult)' OPERATION 4 ACCESS 0 // Calcula Multiplos
	ADD OPTION aRotina TITLE STR0020 ACTION 'WMSA505MNU("2")'              OPERATION 4 ACCESS 0 // Solicitar
Return aRotina
//--------------------------------------------------------------------//
//-------------------------Função ModelDef----------------------------//
//--------------------------------------------------------------------//
Static Function ModelDef()
Local aColsSX3 := {}
Local oStruct  := FWFormModelStruct():New()
Local oModel   := MPFormModel():New('WMSA505',,{|| .T.})
Local aRegra   := StrTokArr(Posicione('SX3',2,'DCF_REGRA','X3CBox()'),';')

	AAdd(aRegra," ")
	// Monta Struct da TEMP
	oStruct:AddTable(cAliasPRD, {'D4_LOCDES','D4_COD','D4_LOTECTL','D4_NUMLOTE'},'')
	oStruct:AddIndex(1,'1','D4_LOCDES+D4_COD+D4_LOTECTL+D4_NUMLOTE',buscarSX3('D14_LOCAL',STR0010,aColsSX3)  + '|' + buscarSX3('D4_COD',,aColsSX3) + '|' + buscarSX3('D4_LOTECTL',,aColsSX3) + '|' + buscarSX3('D4_NUMLOTE',,aColsSX3) ,'','',.T.) // Armazém Destino

	oStruct:AddField(buscarSX3('D4_LOTECTL',,aColsSX3)        ,aColsSX3[1],'D4_LOTECTL','C',aColsSX3[3],aColsSX3[4],Nil                                                                  ,{||.T.},Nil   ,.F.,,.T.,.F.,.F.) // Lote
	oStruct:AddField(buscarSX3('D4_COD',,aColsSX3)            ,aColsSX3[1],'D4_COD'    ,'C',aColsSX3[3],aColsSX3[4],Nil                                                                  ,{||.T.},Nil   ,.F.,,.T.,.F.,.F.) // Codigo Produto
	oStruct:AddField(buscarSX3('B1_DESC',,aColsSX3)           ,aColsSX3[1],'D4_DESC'   ,'C',aColsSX3[3],aColsSX3[4],Nil                                                                  ,{||.T.},Nil   ,.F.,,.T.,.F.,.F.) // Descrição Produto
	oStruct:AddField(buscarSX3('D4_NUMLOTE',,aColsSX3)        ,aColsSX3[1],'D4_NUMLOTE','C',aColsSX3[3],aColsSX3[4],Nil                                                                  ,{||.T.},Nil   ,.F.,,.T.,.F.,.F.) // Sub-lote
	oStruct:AddField(buscarSX3('B5_SERVREQ',,aColsSX3)        ,aColsSX3[1],'D4_SERVIC' ,'C',aColsSX3[3],aColsSX3[4],FwBuildFeature(STRUCT_FEATURE_VALID,"StaticCall(WMSA505,ValidField)"),{||.T.},Nil   ,.T.,,.F.,.F.,.F.) // Servico
	oStruct:AddField(buscarSX3('DCF_REGRA',,aColsSX3)         ,aColsSX3[1],'D4_REGRA'  ,'C',aColsSX3[3],aColsSX3[4],FwBuildFeature(STRUCT_FEATURE_VALID,"StaticCall(WMSA505,ValidField)"),{||.T.},aRegra,.F.,,.F.,.F.,.F.) // Regra WMS
	oStruct:AddField(buscarSX3('D14_LOCAL',STR0008,aColsSX3)  ,aColsSX3[1],'D4_LOCORI' ,'C',aColsSX3[3],aColsSX3[4],FwBuildFeature(STRUCT_FEATURE_VALID,"StaticCall(WMSA505,ValidField)"),{||.T.},Nil   ,.T.,,.F.,.F.,.F.) // Armazem Origem
	oStruct:AddField(buscarSX3('D14_ENDER',STR0009,aColsSX3)  ,aColsSX3[1],'D4_ENDORI' ,'C',aColsSX3[3],aColsSX3[4],FwBuildFeature(STRUCT_FEATURE_VALID,"StaticCall(WMSA505,ValidField)"),{||.T.},Nil   ,.F.,,.F.,.F.,.F.) // Endereço Origem
	oStruct:AddField(buscarSX3('D14_LOCAL',STR0010,aColsSX3)  ,aColsSX3[1],'D4_LOCDES' ,'C',aColsSX3[3],aColsSX3[4],FwBuildFeature(STRUCT_FEATURE_VALID,"StaticCall(WMSA505,ValidField)"),{||.T.},Nil   ,.T.,,.T.,.F.,.F.) // Armazem Destino
	oStruct:AddField(buscarSX3('D14_ENDER',STR0011,aColsSX3)  ,aColsSX3[1],'D4_ENDDES' ,'C',aColsSX3[3],aColsSX3[4],FwBuildFeature(STRUCT_FEATURE_VALID,"StaticCall(WMSA505,ValidField)"),{||.T.},Nil   ,.T.,,.F.,.F.,.F.) // Endereço Destino
	oStruct:AddField(buscarSX3('D4_QUANT',,aColsSX3)          ,aColsSX3[1],'D4_QUANT'  ,'N',aColsSX3[3],aColsSX3[4],Nil                                                                  ,{||.T.},Nil   ,.F.,,.F.,.F.,.F.) // Qtdade sumarizada das requisições
	oStruct:AddField(buscarSX3('D4_QTSEGUM',,aColsSX3)        ,aColsSX3[1],'D4_QTSEGUM','N',aColsSX3[3],aColsSX3[4],Nil                                                                  ,{||.T.},Nil   ,.F.,,.F.,.F.,.F.) // Qtdade da segunda unidade sumarizada
	oStruct:AddField(buscarSX3('D4_QUANT',STR0014,aColsSX3)   ,aColsSX3[1],'D4_SLDPRD' ,'N',aColsSX3[3],aColsSX3[4],Nil                                                                  ,{||.T.},Nil   ,.F.,,.F.,.F.,.F.) // Saldo do produto na produção
	oStruct:AddField(buscarSX3('D4_QTSEGUM',STR0015,aColsSX3) ,aColsSX3[1],'D4_SLDPR2' ,'N',aColsSX3[3],aColsSX3[4],Nil                                                                  ,{||.T.},Nil   ,.F.,,.F.,.F.,.F.) // Saldo da segunda unidade do produto na produção
	oStruct:AddField(buscarSX3('D4_QUANT',STR0016,aColsSX3)   ,aColsSX3[1],'D4_QTDSOL' ,'N',aColsSX3[3],aColsSX3[4],FwBuildFeature(STRUCT_FEATURE_VALID,"StaticCall(WMSA505,ValidField)"),{||.T.},Nil   ,.F.,,.F.,.F.,.F.) // Qtdade à solicitar do produto no WMS
	oStruct:AddField(buscarSX3('D4_QTSEGUM',STR0017,aColsSX3) ,aColsSX3[1],'D4_QTDSO2' ,'N',aColsSX3[3],aColsSX3[4],FwBuildFeature(STRUCT_FEATURE_VALID,"StaticCall(WMSA505,ValidField)"),{||.T.},Nil   ,.F.,,.F.,.F.,.F.) // Qtdade da segunda unidade à solicitar do produto no WMS
	oStruct:AddField(STR0073                                  ,STR0073    ,'D4_HASSLD' ,'L',1          ,0          ,Nil                                                                  ,{||.T.},Nil   ,.F.,,.F.,.F.,.F.) // Saldo Estoque

	oModel:AddFields('PKGMASTER', /*cOwner*/, oStruct)
	oModel:SetDescription(STR0026) // Requisicao
	oModel:GetModel('PKGMASTER'):SetDescription(STR0026) // Requisicao
	oModel:SetPrimaryKey({'D4_LOCDES','D4_COD','D4_LOTECTL','D4_NUMLOTE'})
Return oModel

//-------------------------------------------------------------------//
//-------------------------Função ViewDef----------------------------//
//-------------------------------------------------------------------//
Static Function ViewDef()
Local aColsSX3 := {}
Local oModel   := ModelDef()
Local oView    := FWFormView():New()
Local oStruct  := FWFormViewStruct():New()
Local aRegra   := StrTokArr(Posicione('SX3',2,'DCF_REGRA','X3CBox()'),';')

	oView:SetModel(oModel)

	AAdd(aRegra," ")
	//Monta Struct da TEMP
	oStruct:AddField('D4_COD'    ,'01',buscarSX3('D4_COD',,aColsSX3)            ,aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,Nil  ,.F.,Nil,Nil,Nil   ,Nil,Nil,.F.) // Codigo Produto
	oStruct:AddField('D4_DESC'   ,'02',buscarSX3('B1_DESC',,aColsSX3)           ,aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,Nil  ,.F.,Nil,Nil,Nil   ,Nil,Nil,.F.) // Descrição Produto
	oStruct:AddField('D4_LOTECTL','03',buscarSX3('D4_LOTECTL',,aColsSX3)        ,aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,Nil  ,.F.,Nil,Nil,Nil   ,Nil,Nil,.F.) // Lote
	oStruct:AddField('D4_NUMLOTE','04',buscarSX3('D4_NUMLOTE',,aColsSX3)        ,aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,Nil  ,.F.,Nil,Nil,Nil   ,Nil,Nil,.F.) // Sub-lote
	oStruct:AddField('D4_SERVIC' ,'05',buscarSX3('B5_SERVREQ',,aColsSX3)        ,aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,'DC5',.T.,Nil,Nil,Nil   ,Nil,Nil,.F.) // Servico
	oStruct:AddField('D4_REGRA'  ,'06',buscarSX3('DCF_REGRA',,aColsSX3)         ,aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,Nil  ,.T.,Nil,Nil,aRegra,10 ,Nil,.F.) // Regra WMS
	oStruct:AddField('D4_LOCORI' ,'07',buscarSX3('D14_LOCAL',STR0008,aColsSX3)  ,aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,'NNR',.T.,Nil,Nil,Nil   ,Nil,Nil,.F.) // Armazem WMS
	oStruct:AddField('D4_ENDORI' ,'08',buscarSX3('D14_ENDER',STR0009,aColsSX3)  ,aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,'SBE',.T.,Nil,Nil,Nil   ,Nil,Nil,.F.) // Endereço WMS
	oStruct:AddField('D4_LOCDES' ,'09',buscarSX3('D14_LOCAL',STR0010,aColsSX3)  ,aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,'NNR',.T.,Nil,Nil,Nil   ,Nil,Nil,.F.) // Armazem Produção
	oStruct:AddField('D4_ENDDES' ,'10',buscarSX3('D14_ENDER',STR0011,aColsSX3)  ,aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,'SBE',.T.,Nil,Nil,Nil   ,Nil,Nil,.F.) // Endereço Produção
	oStruct:AddField('D4_QUANT'  ,'11',buscarSX3('D4_QUANT',,aColsSX3)          ,aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,Nil  ,.F.,Nil,Nil,Nil   ,Nil,Nil,.F.) // Qtdade sumarizada das requisições
	oStruct:AddField('D4_QTSEGUM','12',buscarSX3('D4_QTSEGUM',,aColsSX3)        ,aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,Nil  ,.F.,Nil,Nil,Nil   ,Nil,Nil,.F.) // Qtdade da segunda unidade sumarizada
	oStruct:AddField('D4_SLDPRD' ,'13',buscarSX3('D4_QUANT',STR0014,aColsSX3)   ,aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,Nil  ,.F.,Nil,Nil,Nil   ,Nil,Nil,.F.) // Saldo do produto na produção
	oStruct:AddField('D4_SLDPR2' ,'14',buscarSX3('D4_QTSEGUM',STR0015,aColsSX3) ,aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,Nil  ,.F.,Nil,Nil,Nil   ,Nil,Nil,.F.) // Saldo da segunda unidade do produto na produção
	oStruct:AddField('D4_QTDSOL' ,'15',buscarSX3('D4_QUANT',STR0016,aColsSX3)   ,aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,Nil  ,.T.,Nil,Nil,Nil   ,Nil,Nil,.F.) // Qtdade à solicitar do produto no WMS
	oStruct:AddField('D4_QTDSO2' ,'16',buscarSX3('D4_QTSEGUM',STR0017,aColsSX3) ,aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,Nil  ,.F.,Nil,Nil,Nil   ,Nil,Nil,.F.) // Qtdade da segunda unidade à solicitar do produto no WMS

	oView:AddField("VIEW_PKG",oStruct,"PKGMASTER")
	oView:CreateHorizontalBox("TELA",100)
	oView:SetOwnerView("VIEW_PKG","TELA")
	oView:SetDescription(STR0027) // Requisicao WMS
	oView:SetCloseOnOk({||.T.})
Return oView
//---------------------------------------------------------------------------------//
//-------------------------Realiza validação do Produto----------------------------//
//---------------------------------------------------------------------------------//
Static Function ValidField()
Local lRet      := .T.
Local cField    := SubStr(ReadVar(),4)
Local cListDC8  := ""
Local oServico  := Nil
Local oEndereco := Nil
Local oEstFis   := Nil
Local nQtdSol   := 0
Local nSldPrd   := 0
Local nI        := 0
Local aBoxDC8   := {}

	oEstEnder:ClearData()
	oEstEnder:oProdLote:SetArmazem(FwFldGet("D4_LOCDES"))
	oEstEnder:oProdLote:SetProduto(FwFldGet("D4_COD"))
	oEstEnder:oProdLote:SetPrdOri(FwFldGet("D4_COD"))
	oEstEnder:oProdLote:SetLoteCtl(FwFldGet("D4_LOTECTL"))
	oEstEnder:oProdLote:SetNumLote(FwFldGet("D4_NUMLOTE"))
	oEstEnder:oProdLote:SetNumSer("")
	oEstEnder:oProdLote:LoadData()

	Do Case
		Case cField == "D4_SERVIC"
			oServico  := WMSDTCServicoTarefa():New()
			oServico:SetServico(FwFldGet("D4_SERVIC"))
			If oServico:LoadData()
				If !oServico:ChkSepara()
					WmsMessage(WmsFmtMsg(STR0028,{{"[VAR01]",oServico:GetServico()}}),WMSA50519,5,,,STR0064) // Serviço [VAR01] não é operação de separação! // Informe um serviço com tipo de operação de separação
					lRet := .F.
				EndIf
			Else
				WmsMessage(WmsFmtMsg(STR0029,{{"[VAR01]",oServico:GetServico()}}),WMSA50520,5,,,STR0070) // Serviço [VAR01] não cadastrado! // Informe um serviço válido. 
				lRet := .F.
			EndIf
			oServico:Destroy()
		Case cField == "D4_LOCORI"
			dbSelectArea("NNR")
			NNR->(dbSetOrder(1))
			If !NNR->(dbSeek(xFilial("NNR")+FwFldGet("D4_LOCORI")))
				WmsMessage(WmsFmtMsg(STR0030,{{"[VAR01]",FwFldGet("D4_LOCORI")}}),WMSA50521,5,,,STR0065) // Armazém [VAR01] não cadastrado! // Informe um armazém válido.
				lRet := .F.
			EndIf
			If lRet
				FWFldPut("D4_HASSLD",CalcEstoq(FwFldGet("D4_LOCORI"),FwFldGet("D4_ENDORI"),FwFldGet("D4_QUANT"),FwFldGet("D4_QTDSOL")))
			EndIf
		Case cField == "D4_ENDORI"
			oEndereco := WMSDTCEndereco():New()
			oEndereco:SetArmazem(FwFldGet("D4_LOCORI"))
			oEndereco:SetEnder(FwFldGet("D4_ENDORI"))
			If !Empty(FwFldGet("D4_ENDORI"))
				If oEndereco:LoadData()
					// Verifica estrutura física
					oEstFis := WMSDTCEstruturaFisica():New()
					oEstFis:SetEstFis(oEndereco:GetEstFis())
					If oEstFis:LoadData()
						aBoxDC8 := StrTokArr(Posicione("SX3",2,"DC8_TPESTR",'X3CBox()'),';')
						// Verifica se é armazém unitizado
						If WmsArmUnit(oEndereco:GetArmazem())
							If !(oEstFis:GetTipoEst() $ '2|5')
								cListDC8 := aBoxDC8[2] + "," + aBoxDC8[5]
								WmsMessage(WmsFmtMsg(STR0062,{{"[VAR01]",AllTrim(oEndereco:GetEnder())},{"[VAR02]",aBoxDC8[val(oEstFis:GetTipoEst())]}}),WMSA50518,5,,,WmsFmtMsg(STR0063,{{"[VAR01]",cListDC8}})) // Endereço origem [VAR01] com tipo de estrutura física [VAR02] não permitida. // Informe um endereço do tipo de estrutura física [VAR01].
								lRet := .F.
							EndIf
						Else
							For nI := 1 To 6
								cListDC8 += aBoxDC8[nI] + ","
							Next nI
							If !Empty(cListDC8)
								cListDC8 := Substr(cListDC8,1,Len(cListDC8) - 1)
							EndIf
							If !(oEstFis:GetTipoEst() $ '1|2|3|4|5|6')
								WmsMessage(WmsFmtMsg(STR0062,{{"[VAR01]",AllTrim(oEndereco:GetEnder())},{"[VAR02]",aBoxDC8[val(oEstFis:GetTipoEst())]}}),WMSA50517,5,,,WmsFmtMsg(STR0063,{{"[VAR01]",cListDC8}})) // Endereço origem [VAR01] com tipo de estrutura física [VAR02] não permitida.  // Informe um endereço do tipo de estrutura física [VAR01].
								lRet := .F.
							EndIf
						EndIf
					Else
						WmsMessage(WmsFmtMsg(STR0032,{{"[VAR01]",AllTrim(oEstFis:GetEstFis())}}),WMSA50522,5,,,STR0067) // Estrutura física [VAR01] não cadastrada! // Informe uma estrutura física válida.
						lRet := .F.
					EndIf
					If lRet
						FWFldPut("D4_HASSLD",CalcEstoq(FwFldGet("D4_LOCORI"),FwFldGet("D4_ENDORI"),FwFldGet("D4_QUANT"),FwFldGet("D4_QTDSOL")))
					EndIf
					oEstFis:Destroy()
				Else
					WmsMessage(WmsFmtMsg(STR0033,{{"[VAR01]",AllTrim(FwFldGet("D4_ENDORI"))},{"[VAR02]",AllTrim(FwFldGet("D4_LOCORI"))}}),WMSA50525,5,,,WmsFmtMsg(STR0068,{{"[VAR01]",FwFldGet("D4_LOCORI")}})) // Endereço [VAR01] não cadastrado no armazém [VAR02]! // Informe um endereço válido no armazém [VAR01].
					lRet := .F.
				EndIf
			EndIf
			oEndereco:Destroy()
		Case cField == "D4_LOCDES"
			dbSelectArea("NNR")
			NNR->(dbSetOrder(1))
			If !NNR->(dbSeek(xFilial("NNR")+FwFldGet("D4_LOCDES")))
				WmsMessage(WmsFmtMsg(STR0030,{{"[VAR01]",FwFldGet("D4_LOCORI")}}),WMSA50523,5,,,STR0065) // Armazém [VAR01] não cadastrado! // Informe um armazém válido.
				lRet := .F.
			EndIf
			If lRet
				FWFldPut("D4_HASSLD",CalcEstoq(FwFldGet("D4_LOCORI"),FwFldGet("D4_ENDORI"),FwFldGet("D4_QUANT"),FwFldGet("D4_QTDSOL")))
			EndIf
		Case cField == "D4_ENDDES"
			oEndereco := WMSDTCEndereco():New()
			oEndereco:SetArmazem(FwFldGet("D4_LOCDES"))
			oEndereco:SetEnder(FwFldGet("D4_ENDDES"))
			If oEndereco:LoadData()
				oEstFis := WMSDTCEstruturaFisica():New()
				oEstFis:SetEstFis(oEndereco:GetEstFis())
				If oEstFis:LoadData()
					aBoxDC8 := StrTokArr(Posicione("SX3",2,"DC8_TPESTR",'X3CBox()'),';')
					If !(oEstFis:GetTipoEst() == '7')
						cListDC8 := aBoxDC8[7]
						WmsMessage(WmsFmtMsg(STR0062,{{"[VAR01]",AllTrim(oEndereco:GetEnder())},{"[VAR02]",aBoxDC8[val(oEstFis:GetTipoEst())]}}),WMSA50529,5,,,WmsFmtMsg(STR0063,{{"[VAR01]",cListDC8}})) // Endereço origem [VAR01] com tipo de estrutura física [VAR02] não permitida. // Informe um endereço do tipo de estrutura física [VAR01].
						lRet := .F.
					EndIf
				Else
					WmsMessage(WmsFmtMsg(STR0032,{{"[VAR01]",AllTrim(oEstFis:GetEstFis())}}),WMSA50524,5,,,STR0067) // Estrutura física [VAR01] não cadastrada!
					lRet := .F.
				EndIf
				oEstFis:Destroy()
			Else
				WmsMessage(WmsFmtMsg(STR0033,{{"[VAR01]",AllTrim(FwFldGet("D4_ENDDES"))},{"[VAR02]",AllTrim(FwFldGet("D4_LOCDES"))}}),WMSA50526,5,,,WmsFmtMsg(STR0068,{{"[VAR01]",FwFldGet("D4_LOCDES")}})) // Endereço [VAR01] não cadastrado no armazém [VAR02]!
				lRet := .F.
			EndIf
			If lRet
				nSldPrd := 0
				// Busca o saldo do produto no endereço de produção
				// Mesmo com o produto com controle de lote e o lote não informado
				// Trará o saldo total do endereço 
				oEstEnder:oEndereco:SetArmazem(FwFldGet("D4_LOCDES"))
				oEstEnder:oEndereco:SetEnder(FwFldGet("D4_ENDDES"))
				oEstEnder:SetProducao(.T.)
				nSldPrd := oEstEnder:ConsultSld(.F.,.T.,.T.,.T.)

				FWFldPut('D4_SLDPRD',nSldPrd)
				FWFldPut('D4_SLDPR2',ConvUM(FwFldGet("D4_COD"), FwFldGet("D4_SLDPRD"), 0, 2))
				// Ajusta saldo à solicitar
				If (QtdComp(FwFldGet("D4_QUANT")) - QtdComp(FwFldGet("D4_SLDPRD"))) <= 0
					nQtdSol := 0
				Else
					nQtdSol := FwFldGet("D4_QUANT") - FwFldGet("D4_SLDPRD")
				EndIf
				FWFldPut('D4_QTDSOL',nQtdSol)
				FWFldPut('D4_QTDSO2',ConvUM(FwFldGet("D4_COD"), FwFldGet("D4_QTDSOL"), 0, 2))
				FWFldPut("D4_HASSLD",CalcEstoq(FwFldGet("D4_LOCORI"),FwFldGet("D4_ENDORI"),FwFldGet("D4_QUANT"),FwFldGet("D4_QTDSOL")))
			EndIf
			oEndereco:Destroy()
		Case cField == "D4_QTDSOL"
			FWFldPut('D4_QTDSO2',ConvUM(FwFldGet("D4_COD"), FwFldGet("D4_QTDSOL"), 0, 2))
			// Verifica se quantidade à solicitar empenhada não é menor que a informada 
			If (QtdComp(FwFldGet("D4_QUANT")) - QtdComp(FwFldGet("D4_SLDPRD"))) <= 0
				nQtdSol := 0
			Else
				nQtdSol := FwFldGet("D4_QUANT") - FwFldGet("D4_SLDPRD")
			EndIf
			// Verifica se quantidade informada não é menor que a quantidade que deve ser solicitada
			If QtdComp(nQtdSol) > 0 .And. QtdComp(FwFldGet("D4_QTDSOL")) == 0
				WmsMessage(STR0035,WMSA50527,5,,,STR0069) // Quantidade à solicitar não informada! // Informe a quantidade à solicitar válida.
				lRet := .F.
			ElseIf QtdComp(nQtdSol) == 0 .And. QtdComp(FwFldGet("D4_QTDSOL")) > 0
				WmsMessage(STR0074,WMSA50536,5,,,STR0075) // Quantidade requisitada atendida com o saldo em produção! // Efetue uma transferência manual.
				lRet := .F.
			EndIf
			// Valida estoque
			FWFldPut("D4_HASSLD",CalcEstoq(FwFldGet("D4_LOCORI"),FwFldGet("D4_ENDORI"),FwFldGet("D4_QUANT"),FwFldGet("D4_QTDSOL")))
	EndCase
Return lRet
//-----------------------------------------------------------
// Menu
/*/{Protheus.doc} WMSA505MNU
Menu das requisições

@author  Felipe Machado de Oliveira
@version P12
@Since	23/05/14
@version 1.0
/*/
//-----------------------------------------------------------
Function WMSA505MNU(cAcao)
Local aAreaAnt  := GetArea()
Local bFunc     := ""
Local lContinua := .T.
Local cQuery    := ""
Local cAliasQry := Nil
	If cAcao == "1" // Estornar
		bFunc += "Estornar()"
		// Verifica se há alguma requisição selecionada
		cQuery := "SELECT 1"
		cQuery +=  " FROM "+oTmpTabSD4:GetRealName()+" TSD4"
		cQuery += " INNER JOIN "+RetSqlName("SD4")+" SD4"
		cQuery +=    " ON SD4.D4_FILIAL = '"+xFilial("SD4")+"'"
		cQuery +=   " AND SD4.D4_LOCAL = TSD4.D4_LOCAL"
		cQuery +=   " AND SD4.D4_OP = TSD4.D4_OP"
		cQuery +=   " AND SD4.D4_TRT = TSD4.D4_TRT"
		cQuery +=   " AND SD4.D4_COD = TSD4.D4_COD"
		cQuery +=   " AND SD4.D4_LOTECTL = TSD4.D4_LOTECTL"
		cQuery +=   " AND SD4.D4_NUMLOTE = TSD4.D4_NUMLOTE"
		cQuery +=   " AND SD4.D4_IDDCF <> '"+Space(TamSX3("D4_IDDCF")[1])+"'"
		cQuery +=   " AND SD4.D_E_L_E_T_ = ' '"
		cQuery += " WHERE SD4.D4_FILIAL = '"+xFilial("SD4")+"'"
		cQuery +=   " AND TSD4.D4_MARK ='"+oBrwSD4:cMark+"'"
		cQuery +=   " AND TSD4.D_E_L_E_T_ = ' '"
		cQuery:= ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
		If (cAliasQry)->(Eof())
			WmsMessage(STR0040,WMSA50504,5/*MSG_HELP*/) // Não há itens selecionados. Favor verificar.
			lContinua := .F.
		EndIf
		(cAliasQry)->(dbCloseArea())
	ElseIf cAcao == "2" // Solicitar
		bFunc += "RequestReq()"
		// Verifica se há alguma requisição selecionada
		cQuery := "SELECT PRD.D4_COD,"
		cQuery +=       " PRD.D4_LOTECTL"
		cQuery +=  " FROM "+oTmpTabPRD:GetRealName()+" PRD"
		cQuery += " WHERE PRD.D4_MARK = '"+oBrwPRD:cMark+"'"
		cQuery +=  "  AND PRD.D_E_L_E_T_ = ' '"
		cQuery:= ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
		If (cAliasQry)->(Eof())
			WmsMessage(STR0040,WMSA50503,5/*MSG_HELP*/) // Não há itens selecionados. Favor verificar.
			lContinua := .F.
		EndIf
		(cAliasQry)->(dbCloseArea())
	EndIf
	If lContinua
		Processa( {|| ProcRegua(100), IncProc(STR0037),&bFunc ,IncProc(STR0037) } , STR0038, "..." + '...', .F.) // Aguarde... // Aguarde... // Processando...
	EndIf
	RestArea(aAreaAnt)
Return

//-----------------------------------------------------------
// Embarques
/*/{Protheus.doc} createTemp
Cria a tabela temporaria para as requisições empenhadas

@author  Tiago Filipe da Silva
@version P12
@Since	02/04/14
@version 1.0
/*/
//-----------------------------------------------------------
Static Function createTemp()
Local aColsSX3    := {}

	// Check da SD4
	AAdd(aCamposSD4,{'D4_MARK' ,'C',2,0})
	// Situação da SD4
	AAdd(aCamposSD4,{'D4_SITU' ,'C',1,0})
	// Ordem de Producao
	buscarSX3('D4_OP',,aColsSX3)
	AAdd(aCamposSD4,{'D4_OP' ,'C',aColsSX3[3],aColsSX3[4]})
	// Armazem
	buscarSX3('D4_LOCAL',,aColsSX3)
	AAdd(aCamposSD4,{'D4_LOCAL' ,'C',aColsSX3[3],aColsSX3[4]})
	// Produto
	buscarSX3('D4_COD',,aColsSX3)
	AAdd(aCamposSD4,{'D4_COD' ,'C',aColsSX3[3],aColsSX3[4]})
	// Descricao Produto
	buscarSX3('B1_DESC',,aColsSX3)
	AAdd(aCamposSD4,{'D4_DESC' ,'C',aColsSX3[3],aColsSX3[4]})
	// Lote
	buscarSX3('D4_LOTECTL',,aColsSX3)
	AAdd(aCamposSD4,{'D4_LOTECTL' ,'C',aColsSX3[3],aColsSX3[4]})
	// Sub-Lote
	buscarSX3('D4_NUMLOTE',,aColsSX3)
	AAdd(aCamposSD4,{'D4_NUMLOTE' ,'C',aColsSX3[3],aColsSX3[4]})
	// Data Empenho
	buscarSX3('D4_DATA',,aColsSX3)
	AAdd(aCamposSD4,{'D4_DATA' ,'D',aColsSX3[3],aColsSX3[4]})
	// Quantidade Empenho
	buscarSX3('D4_QUANT',,aColsSX3)
	AAdd(aCamposSD4,{'D4_QUANT' ,'N',aColsSX3[3],aColsSX3[4]})
	// Quantidade Segunda UM
	buscarSX3('D4_QTSEGUM',,aColsSX3)
	AAdd(aCamposSD4,{'D4_QTSEGUM' ,'N',aColsSX3[3],aColsSX3[4]})
	// Sequencia Estrutura
	buscarSX3('D4_TRT',,aColsSX3)
	AAdd(aCamposSD4,{'D4_TRT' ,'C',aColsSX3[3],aColsSX3[4]})
	// Documento
	buscarSX3('DCF_DOCTO',,aColsSX3)
	AAdd(aCamposSD4,{'D4_DOCTO' ,'C',aColsSX3[3],aColsSX3[4]})
	buscarSX3('D4_IDDCF',,aColsSX3)
	AAdd(aCamposSD4,{'D4_IDDCF' ,'C',aColsSX3[3],aColsSX3[4]})
	// Indice: Ordem de Produção,Sequencia, Local, Produto, Lote, Sub-Lote, Data Empenho, Codigo Lancamento
	criaTabTmp(aCamposSD4,{'D4_OP+D4_TRT+D4_LOCAL+D4_COD+D4_LOTECTL+D4_NUMLOTE+DTOS(D4_DATA)'},cAliasSD4,@oTmpTabSD4)
	//----------------
	// Check do Resumo
	AAdd(aCamposPRD,{'D4_MARK' ,'C',2,0})
	// Codigo Produto
	buscarSX3('D4_COD',,aColsSX3)
	AAdd(aCamposPRD,{'D4_COD'  ,'C',aColsSX3[3],aColsSX3[4]})
	// Descrição Produto
	buscarSX3('B1_DESC',,aColsSX3)
	AAdd(aCamposPRD,{'D4_DESC' ,'C',aColsSX3[3],aColsSX3[4]})
	// Lote
	buscarSX3('D4_LOTECTL',,aColsSX3)
	AAdd(aCamposPRD,{'D4_LOTECTL' ,'C',aColsSX3[3],aColsSX3[4]})
	// Sub-lote
	buscarSX3('D4_NUMLOTE',,aColsSX3)
	AAdd(aCamposPRD,{'D4_NUMLOTE' ,'C',aColsSX3[3],aColsSX3[4]})
	// Servico de requisicao
	buscarSX3('B5_SERVREQ',,aColsSX3)
	AAdd(aCamposPRD,{'D4_SERVIC' ,'C',aColsSX3[3],aColsSX3[4]})
	// Regra WMS
	buscarSX3('DCF_REGRA',,aColsSX3)
	AAdd(aCamposPRD,{'D4_REGRA' ,'C',aColsSX3[3],aColsSX3[4]})
	// Armazem origem
	buscarSX3('D14_LOCAL',,aColsSX3)
	AAdd(aCamposPRD,{'D4_LOCORI' ,'C',aColsSX3[3],aColsSX3[4]})
	// Endereço origem
	buscarSX3('D14_ENDER',,aColsSX3)
	AAdd(aCamposPRD,{'D4_ENDORI' ,'C',aColsSX3[3],aColsSX3[4]})
	// Armazem destino
	buscarSX3('D14_LOCAL',,aColsSX3)
	AAdd(aCamposPRD,{'D4_LOCDES' ,'C',aColsSX3[3],aColsSX3[4]})
	// Endereço destino
	buscarSX3('D14_ENDER',,aColsSX3)
	AAdd(aCamposPRD,{'D4_ENDDES' ,'C',aColsSX3[3],aColsSX3[4]})
	// Qtdade sumarizada das requisições
	buscarSX3('D4_QUANT',,aColsSX3)
	AAdd(aCamposPRD,{'D4_QUANT' ,'N',aColsSX3[3],aColsSX3[4]})
	// Qtdade da segunda unidade sumarizada
	buscarSX3('D4_QTSEGUM',,aColsSX3)
	AAdd(aCamposPRD,{'D4_QTSEGUM' ,'N',aColsSX3[3],aColsSX3[4]})
	// Saldo endereço destino
	buscarSX3('D4_QUANT',"Sld. Produção",aColsSX3)
	AAdd(aCamposPRD,{'D4_SLDPRD' ,'N',aColsSX3[3],aColsSX3[4]})
	// Saldo endereço destino 2um
	buscarSX3('D4_QTSEGUM',"Sld. Produção 2UM",aColsSX3)
	AAdd(aCamposPRD,{'D4_SLDPR2' ,'N',aColsSX3[3],aColsSX3[4]})
	// Qtdade solicitar
	buscarSX3('D4_QUANT',"Qtd. Solicitar",aColsSX3)
	AAdd(aCamposPRD,{'D4_QTDSOL' ,'N',aColsSX3[3],aColsSX3[4]})
	// Qtdade solicitar 2UM
	buscarSX3('D4_QTSEGUM',"Qtd. Solicitar 2UM",aColsSX3)
	AAdd(aCamposPRD,{'D4_QTDSO2' ,'N',aColsSX3[3],aColsSX3[4]})
	// Tem Saldo
	AAdd(aCamposPRD,{'D4_HASSLD' ,'L',1,0})
	
	// Indice: Produto, Lote, Sub-Lote
	criaTabTmp(aCamposPRD,{'D4_LOCDES+D4_COD+D4_LOTECTL+D4_NUMLOTE'},cAliasPRD,@oTmpTabPRD)
Return .T.

//-----------------------------------------------------------
// Embarques
/*/{Protheus.doc} CargaTemp
Carrega a tabela temporaria conforme o parametro e
determina a situação das requisições

@author  Tiago Filipe da Silva
@version P12
@Since	02/04/14
@version 1.0
/*/
//-----------------------------------------------------------
Static Function CargaTemp()
Local aAreaSD4   := SD4->(GetArea())
Local aArraySD4  := {}
Local cDocto     := ""
Local nSituSD4   := 0
Local nPos       := 0
Local cAliasQry  := ""

	cQuery := "SELECT SD4.R_E_C_N_O_ RECNOSD4"
	cQuery +=  " FROM " +RetSqlName("SD4")+ " SD4"
	cQuery += " WHERE SD4.D4_FILIAL = '"+xFilial("SD4")+"'"
	cQuery +=   " AND SD4.D4_OP BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'"
	cQuery +=   " AND SD4.D4_DATA BETWEEN '"+DtoS(MV_PAR03)+"' AND '"+DtoS(MV_PAR04)+ "'"
	cQuery +=   " AND SD4.D4_COD BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'"
	cQuery +=   " AND SD4.D4_QTDEORI = SD4.D4_QUANT"
	cQuery +=   " AND SD4.D4_QTDEORI > 0"
	cQuery +=   " AND NOT EXISTS( SELECT 1""
	cQuery +=                     " FROM "+RetSqlName("SDC")+" SDC"
	cQuery +=                    " WHERE SDC.DC_FILIAL = '"+xFilial("SDC")+"'"
	cQuery +=                      " AND SD4.D4_FILIAL = '"+xFilial("SD4")+"'"
	cQuery +=                      " AND SDC.DC_PRODUTO = SD4.D4_COD"
	cQuery +=                      " AND SDC.DC_LOCAL = SD4.D4_LOCAL"
	cQuery +=                      " AND SDC.DC_OP = SD4.D4_OP"
	cQuery +=                      " AND SDC.DC_TRT = SD4.D4_TRT"
	cQuery +=                      " AND SDC.DC_IDDCF = ' '""
	cQuery +=                      " AND SDC.D_E_L_E_T_ = ' ')"
	cQuery +=   " AND SD4.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
	TCSETFIELD( cAliasSD4,'D4_DATA','D')
	While(cAliasQry)->(!Eof())
		SD4->(dbGoTo((cAliasQry)->RECNOSD4))

		cDocto := ""
		// Retorna a situação conforme o status na DCF e o documento correspondente
		Situacao(@nSituSD4,@cDocto)

		// Verifica a se o parametro passado é 5 (Todos) ou se a situação da requisição é a mesma do parametro
		If MV_PAR07 == 5 .OR. nSituSD4 == MV_PAR07

			// Procura se a Ordem de Prod./Local/Produto/Lote/Sub-lote já existe no array
			nPos := aScan(aArraySD4, {|x| x[3]+x[13]+x[4]+x[5]+x[7]+x[8] == SD4->D4_OP+SD4->D4_TRT+SD4->D4_LOCAL+SD4->D4_COD+SD4->D4_LOTECTL+SD4->D4_NUMLOTE})

			If nPos == 0
				// Grava os dados na matriz para posteriormente gravar na tabela temporária
				dbSelectArea("SB1")
				SB1->(dbSetOrder(1))
				If SB1->(dbSeek(xFilial("SB1")+SD4->D4_COD))
					aAdd(aArraySD4,;
					{'',;
					NtoC(nSituSD4,10),;
					SD4->D4_OP,;
					SD4->D4_LOCAL,;
					SD4->D4_COD,;
					SB1->B1_DESC,;
					SD4->D4_LOTECTL,;
					SD4->D4_NUMLOTE,;
					SD4->D4_DATA,;
					SD4->D4_QUANT,;
					SD4->D4_QTSEGUM,;
					SD4->D4_TRT,;
					cDocto,;
					SD4->D4_IDDCF})
				EndIf
			Else
				// Atualiza a situacao da requisicao
				aArraySD4[nPos][2] :=  NtoC(nSituSD4,10)
			EndIf
		EndIf
		(cAliasQry)->(dbSkip())
	EndDo
	// Ordena as informações de acordo com o indice
	aSort(aArraySD4,,, { |x,y| y[3]+y[4]+y[5]+y[7]+y[8]+DTOS(y[9]) > x[3]+x[4]+x[5]+x[7]+x[8]+DTOS(x[9])})

	(cAliasQry)->(dbCloseArea())

	aArrayPRD := {}
	MntCargDad(cAliasSD4,aArraySD4,aCamposSD4)
	MntCargDad(cAliasPRD,aArrayPRD,aCamposPRD)
	RestArea(aAreaSD4)
Return .T.

//-----------------------------------------------------------
// Embarques
/*/{Protheus.doc} AfterMark
Função para carga das informações para o segundo browse

@author  Tiago Filipe da Silva
@version P12
@Since	07/04/14
@version 1.0
/*/
//-----------------------------------------------------------
Static Function AfterMark()
Local aArea      := (cAliasSD4)->(GetArea())
Local aArrayPRD  := {}
Local aTamSX3    := TamSX3("B8_SALDO")
Local nSituSD4   := 0
Local cDocto     := ""
Local cEndReq    := ""
Local cServReq   := ""
Local cQuery     := ""
Local cAliasQry  := ""
Local cAliasQr1  := ""
Local cAliasQr2  := ""
Local nPos       := 0
Local nI         := 0
Local nSldWMS    := 0
Local nSldPrd    := 0
Local nQtdSol    := 0
Local oServico   := Nil
Local lDesMark   := .F.
	cQuery := "SELECT SD4.R_E_C_N_O_ RECNOSD4,"
	cQuery +=       " TSD4.R_E_C_N_O_ RECNOTSD4"
	cQuery +=  " FROM "+RetSqlName("SD4")+" SD4"
	cQuery += " INNER JOIN "+oTmpTabSD4:GetRealName()+" TSD4"
	cQuery +=    " ON TSD4.D4_LOCAL = SD4.D4_LOCAL"
	cQuery +=   " AND TSD4.D4_OP = SD4.D4_OP"
	cQuery +=   " AND TSD4.D4_TRT = SD4.D4_TRT"
	cQuery +=   " AND TSD4.D4_COD = SD4.D4_COD"
	cQuery +=   " AND TSD4.D4_LOTECTL = SD4.D4_LOTECTL"
	cQuery +=   " AND TSD4.D4_NUMLOTE = SD4.D4_NUMLOTE"
	cQuery +=   " AND TSD4.D4_MARK = '"+oBrwSD4:cMark+"'"
	cQuery +=   " AND TSD4.D_E_L_E_T_ = ' '"
	cQuery += " WHERE SD4.D4_FILIAL = '"+xFilial("SD4")+"'"
	cQuery +=   " AND SD4.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY SD4.D4_COD,"
	cQuery +=          " SD4.D4_LOTECTL"
	cQuery:= ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
	Do While (cAliasQry)->(!Eof())
		(cAliasSD4)->(dbGoTo((cAliasQry)->RECNOTSD4))
		// Certifica-se que o registro está marcado
		If (cAliasSD4)->D4_MARK = oBrwSD4:cMark
			cQuery := "SELECT COUNT(TSD41.D4_COD) NCONT "
			cQuery +=  " FROM "+oTmpTabSD4:GetRealName()+" TSD41"
			cQuery += " WHERE TSD41.D4_LOCAL = '"+(cAliasSD4)->D4_LOCAL+"'"
			cQuery +=   " AND TSD41.D4_COD = '"+(cAliasSD4)->D4_COD+"'"
			cQuery +=   " AND TSD41.D4_LOTECTL <> '"+Space(TamSX3("D4_LOTECTL")[1])+"'"
			cQuery +=   " AND TSD41.D4_IDDCF = '"+Space(TamSX3("D4_IDDCF")[1])+"'"
			cQuery +=   " AND TSD41.D4_MARK = '"+oBrwSD4:cMark+"'"
			cQuery +=   " AND TSD41.D_E_L_E_T_ = ' '"
			cQuery:= ChangeQuery(cQuery)
			cAliasQr1 := GetNextAlias()
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQr1,.F.,.T.)
			If (cAliasQr1)->NCONT > 0
				cQuery := "SELECT TSD42.R_E_C_N_O_ RECNOTSD4"
				cQuery +=  " FROM "+oTmpTabSD4:GetRealName()+" TSD42"
				cQuery += " WHERE TSD42.D4_LOCAL = '"+(cAliasSD4)->D4_LOCAL+"'"
				cQuery +=   " AND TSD42.D4_COD = '"+(cAliasSD4)->D4_COD+"'"
				cQuery +=   " AND TSD42.D4_LOTECTL = '"+Space(TamSX3("D4_LOTECTL")[1])+"'"
				cQuery +=   " AND TSD42.D4_IDDCF = '"+Space(TamSX3("D4_IDDCF")[1])+"'"
				cQuery +=   " AND TSD42.D4_MARK = '"+oBrwSD4:cMark+"'"
				cQuery +=   " AND TSD42.D_E_L_E_T_ = ' '"
				cQuery:= ChangeQuery(cQuery)
				cAliasQr2 := GetNextAlias()
				dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQr2,.F.,.T.)
				Do While (cAliasQr2)->(!Eof())
					(cAliasSD4)->(dbGoTo((cAliasQr2)->RECNOTSD4))
					RecLock((cAliasSD4), .F.)
					(cAliasSD4)->D4_MARK := ''
					MsUnLock()
					lDesMark := .T.
					(cAliasQr2)->(dbSkip())
				EndDo
				(cAliasQr2)->(dbCloseArea())
			EndIf
			(cAliasQr1)->(dbCloseArea())
		EndIf
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
	// Apresenta mensagem de alerta quando foram marcados produtos com controle de lote com requisições com lote e sem lote informado.
	If lDesMark
		WmsMessage(STR0071,WMSA50530,5,,,STR0072) // Foram priorizadas requisições com lote informado, as demais requisições de produtos sem o lote serão desmarcadas // Para selecionar as requisições de produtos sem o lote, não marcar os produtos em que o lote está informado..
	EndIf
	// Reavalia os documentos selecionados.
	cQuery := "SELECT SD4.R_E_C_N_O_ RECNOSD4"
	cQuery +=  " FROM "+RetSqlName("SD4")+" SD4"
	cQuery += " INNER JOIN "+oTmpTabSD4:GetRealName()+" TSD4"
	cQuery +=    " ON TSD4.D4_LOCAL = SD4.D4_LOCAL"
	cQuery +=   " AND TSD4.D4_OP = SD4.D4_OP"
	cQuery +=   " AND TSD4.D4_TRT = SD4.D4_TRT"
	cQuery +=   " AND TSD4.D4_COD = SD4.D4_COD"
	cQuery +=   " AND TSD4.D4_LOTECTL = SD4.D4_LOTECTL"
	cQuery +=   " AND TSD4.D4_NUMLOTE = SD4.D4_NUMLOTE"
	cQuery +=   " AND TSD4.D4_MARK = '"+oBrwSD4:cMark+"'"
	cQuery +=   " AND TSD4.D_E_L_E_T_ = ' '"
	cQuery += " WHERE SD4.D4_FILIAL = '"+xFilial("SD4")+"'"
	cQuery +=   " AND SD4.D_E_L_E_T_ = ' '"
	cQuery:= ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
	Do While (cAliasQry)->(!Eof())
		SD4->(dbGoTo((cAliasQry)->RECNOSD4))
		// Retorna a situação conforme o status na DCF e SDB e o documento correspondente
		Situacao(@nSituSD4,@cDocto)

		nSldWMS := 0
		nSldPrd := 0
		nQtdSol := 0
		// Não há Empenho e não há solicitação no WMS,  1 - Nao solicitada
		If nSituSD4 == 1
			oEstEnder:ClearData()
			oEstEnder:oProdLote:SetArmazem(SD4->D4_LOCAL)
			oEstEnder:oProdLote:SetProduto(SD4->D4_COD)
			oEstEnder:oProdLote:SetPrdOri(SD4->D4_COD)
			oEstEnder:oProdLote:SetLoteCtl(SD4->D4_LOTECTL)
			oEstEnder:oProdLote:SetNumLote(SD4->D4_NUMLOTE)
			oEstEnder:oProdLote:SetNumSer("")
			oEstEnder:oProdLote:LoadData()
			oEstEnder:SetProducao(.F.)
			cServReq := oEstEnder:oProdLote:GetSerReq()
			If !Empty(cServReq)
				oServico := WMSDTCServicoTarefa():New()
				oServico:SetServico(cServReq)
				If !oServico:LoadData() .Or. !oServico:ChkSepara()
					cServReq := ""
				EndIf
				oServico:Destroy()
			EndIf
			cEndReq  := oEstEnder:oProdLote:GetEndReq()

			// Verifica se já existe o produto/lote/sublote no array, se existir, soma, caso contrario cria uma nova posicao
			nPos := aScan(aArrayPRD, {|x| x[10]+x[2]+x[4]+x[5] == SD4->D4_LOCAL+SD4->D4_COD+SD4->D4_LOTECTL+SD4->D4_NUMLOTE})
			// Atribui dados do endereço de produção
			oEstEnder:oEndereco:SetArmazem(SD4->D4_LOCAL)
			// Quando endereço produção informado
			If !Empty(cEndReq)
				nSldPrd := 0
				// Busca o saldo do produto no endereço de produção
				// Mesmo com o produto com controle de lote e o lote não informado
				// Trará o saldo total do endereço
				oEstEnder:oEndereco:SetEnder(cEndReq)
				oEstEnder:SetProducao(.T.)
				// Busca saldo do produto no endereço de produção
				nSldPrd := oEstEnder:ConsultSld(.F.,.T.,.T.,.T.)
			EndIf
			// Calcula quantidade à solicitar
			nQtdSol := SD4->D4_QUANT - nSldPrd
			If QtdComp(nSldPrd) < 0
				nQtdSol := 0
			EndIf
			// Cria uma nova posição com os valores
			If nPos == 0
				// Valida estoque
				aAdd(aArrayPRD,;
				{'',;
				oEstEnder:oProdLote:GetProduto(),;
				oEstEnder:oProdLote:GetDesc(),;
				oEstEnder:oProdLote:GetLoteCtl(),;
				oEstEnder:oProdLote:GetNumLote(),;
				cServReq,;
				"",;
				oEstEnder:oEndereco:GetArmazem(),;
				"",;
				oEstEnder:oEndereco:GetArmazem(),;
				cEndReq,;
				SD4->D4_QUANT,;
				0,;
				nSldPrd,;
				0,;
				nQtdSol,;
				0,;
				CalcEstoq(SD4->D4_LOCAL,Nil,SD4->D4_QUANT-nSldPrd,nQtdSol)})
			Else
				// Soma a quantidade do produto
				aArrayPRD[nPos][12] += SD4->D4_QUANT   // Qtdade sumarizada das requisições
				// Valida estoque
				aArrayPRD[nPos][18] := CalcEstoq(aArrayPRD[nPos][08],Nil,aArrayPRD[nPos][12]-nSldPrd,nQtdSol)
			EndIf
		EndIf
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
	// Ajusta quantidades
	For nI := 1 To Len(aArrayPRD)
		// Calcula saldo solicitar
		If QtdComp(aArrayPRD[nI][12]) - QtdComp(aArrayPRD[nI][14]) <= 0
			aArrayPRD[nI][16] := 0
		Else
			aArrayPRD[nI][16] := aArrayPRD[nI][12] - aArrayPRD[nI][14]
		EndIf
		//Ajusta calculo 2um
		aArrayPRD[nI][13] := ConvUM(aArrayPRD[nI][02], aArrayPRD[nI][12], 0, 2)
		aArrayPRD[nI][15] := ConvUM(aArrayPRD[nI][02], aArrayPRD[nI][14], 0, 2)
		aArrayPRD[nI][17] := ConvUM(aArrayPRD[nI][02], aArrayPRD[nI][16], 0, 2)
	Next nI

	// Ordena as informações de acordo com o indice
	aSort(aArrayPRD,,, { |x,y| y[10]+y[2]+y[4]+y[5] > x[10]+x[2]+x[4]+x[5] } )
	MntCargDad(cAliasPRD,aArrayPRD,aCamposPRD)
	// Atualiza browse
	oBrwPRD:Refresh(.T.)
	RestArea(aArea)
Return .T.

//--------------------------------------------------------------------
/*/{Protheus.doc} SetMarkAll
Função para marcar todas as requisições

@author Tiago Filipe da Silva
@since 08/04/14
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function SetMarkAll(cMarca,lMarcar)
Local aAreaSD4  := (cAliasSD4)->(GetArea())

	dbSelectArea(cAliasSD4)
	(cAliasSD4)->(dbGoTop())
	Do While (cAliasSD4)->(!Eof())
		RecLock((cAliasSD4), .F.)
		(cAliasSD4)->D4_MARK := IIf(lMarcar,cMarca,'')
		MsUnLock()
		(cAliasSD4)->(dbSkip())
	EndDo

	AfterMark()

	RestArea(aAreaSD4)
Return .T.

//--------------------------------------------------------------------
/*/{Protheus.doc} MarkAllPro
Função para marcar todas as requisições no segundo browse

@author Tiago Filipe da Silva
@since 08/04/14
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MarkAllPro(cMarca,lMarcar)
Local aAreaAnt := GetArea()

	dbSelectArea(cAliasPRD)
	(cAliasPRD)->(dbGoTop())
	While (cAliasPRD)->(!Eof())
		RecLock((cAliasPRD), .F.)
		(cAliasPRD)->D4_MARK := IIf(lMarcar,cMarca,'')
		MsUnLock()
		(cAliasPRD)->(dbSkip())
	EndDo

	RestArea(aAreaAnt)
Return .T.

//-----------------------------------------------------------
// Embarques
/*/{Protheus.doc} Situacao
Função para definição da situação das requisições

@author  Tiago Filipe da Silva
@version P12
@Since	07/04/14
@version 1.0
/*/
//-----------------------------------------------------------
Static Function Situacao(nSituSD4,cDocto)
Local aAreaDCF  := DCF->(GetArea())
Local aAreaSDC  := SDC->(GetArea())
Local aAreaSD4  := SD4->(GetArea())
Local cAliasDCF := GetNextAlias()
Local cAliasTMP := GetNextAlias()
Local lEmpenho  := .F.

Default cDocto := ""
	dbSelectArea("SDC")
	SDC->(dbSetOrder(1))
	lEmpenho := SDC->(dbSeek(xFilial("SDC")+SD4->D4_COD+SD4->D4_LOCAL+SD4->D4_OP+SD4->D4_TRT+SD4->D4_LOTECTL+SD4->D4_NUMLOTE))

	If Empty(SD4->D4_IDDCF)
		If lEmpenho
			// Ha Empenho de endereço não será considerado
			nSituSD4 := 0
		Else
			// Não há Empenho e não há solicitação no WMS,  1 - Nao solicitada
			nSituSD4 := 1
		EndIf
	Else
		dbSelectArea("DCF")
		DCF->(dbSetOrder(9))

		cQuery := "SELECT DCF.DCF_STSERV,"
		cQuery +=       " DCF.DCF_ID,"
		cQuery +=       " DCF.DCF_DOCTO,"
		cQuery +=       " DCF.DCF_SEQUEN"
		cQuery +=  " FROM "+RetSqlName("DCF")+" DCF"
		cQuery += " WHERE DCF.DCF_FILIAL = '"+xFilial("DCF")+"'"
		cQuery +=   " AND DCF.DCF_ID = '"+SD4->D4_IDDCF+"'"
		cQuery +=   " AND DCF.DCF_STSERV <> '0'"
		cQuery +=   " AND DCF.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasDCF,.F.,.T.)
		If (cAliasDCF)->(!Eof())
			cDocto := DCF->DCF_DOCTO

			If (cAliasDCF)->DCF_STSERV <> '3'
				// Solicitado no WMS mas não foi executado, 2 - Nao iniciado
				nSituSD4 := 2
			Else
				cAliasTMP := GetNextAlias()
				cQuery := " SELECT D12.D12_STATUS"
				cQuery +=   " FROM "+RETSQLNAME("D12")+" D12"
				cQuery +=  " WHERE D12.D12_FILIAL = '"+xFilial("D12")+" '"
				cQuery +=    " AND D12.D12_IDDCF IN (SELECT DCR.DCR_IDORI"
				cQuery +=                            " FROM "+RETSQLNAME("DCR")+" DCR"
				cQuery +=                           " WHERE DCR.DCR_FILIAL = '"+xFilial("DCR")+"'"
				cQuery +=                             " AND DCR.DCR_SEQUEN = '"+(cAliasDCF)->DCF_SEQUEN+"'"
				cQuery +=                             " AND DCR.DCR_IDDCF = '"+(cAliasDCF)->DCF_ID+"'"
				cQuery +=                             " AND DCR.D_E_L_E_T_ = ' ')"
				cQuery +=    " AND D12.D12_STATUS NOT IN ('0','1')" // Se é diferente de 'Executada'
				cQuery +=    " AND D12.D_E_L_E_T_ = ' '"
				cQuery := ChangeQuery(cQuery)
				dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasTMP,.F.,.T.)
				If (cAliasTMP)->(!Eof()) // Se algum ainda estiver diferente de 'Executada'
					nSituSD4 := 3        // 3-Em Andamento
				Else                     // Se todas já foram executadas
					nSituSD4 := 4        // 4-Finalizadas
				EndIf
				(cAliasTMP)->(dbCloseArea())
			EndIf
		EndIf
	EndIf
	RestArea(aAreaDCF)
	RestArea(aAreaSD4)
	RestArea(aAreaSDC)
Return .T.

//--------------------------------------------------------------------
/*/{Protheus.doc} RequestReq
Função de solicitacao das requisicoes

@author Tiago Filipe da Silva
@since 09/04/14
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function RequestReq()
Local aAreaAnt   := GetArea()
Local aAreaDCF   := DCF->(GetArea())
Local aResErro   := {}
Local aResOk     := {}
Local aTamSX3    := TamSx3("D4_QUANT")
Local cQuery     := ""
Local cAliasQry  := ""
Local cAliasQr1  := ""
Local cAliasQr2  := ""
Local cOp        := ""
Local cTrt       := ""
Local lRet       := .T.
Local lContinua  := .F.
Local oOrdServ   := Nil
Local oRegraConv := Nil
Local oOrdSerExe := Nil
Local nSldPrd    := 0
Local nQtdDif    := 0
Local nQtdReq    := 0
Local nQtdRat    := 0
Local nQtdEmp    := 0
Local nQtdEmp    := 0
Local nNewRecno  := 0
Local nX         := 0
Local dDtValid   := CtoD('  /  /  ')

	cQuery := "SELECT PRD.R_E_C_N_O_ RECNOPRD"
	cQuery +=  " FROM "+oTmpTabPRD:GetRealName()+" PRD"
	cQuery += " WHERE PRD.D4_MARK = '"+oBrwPRD:cMark+"'"
	cQuery +=  "  AND PRD.D_E_L_E_T_ = ' '"
	cQuery:= ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
	If (cAliasQry)->(!Eof())
		oOrdServ   := WMSDTCOrdemServicoCreate():New()
		oOrdSerExe := WMSDTCOrdemServicoExecute():New()
		oRegraConv := WMSBCCRegraConvocacao():New()
		Do While (cAliasQry)->(!Eof())
			nQtdReq   := 0
			lContinua := .T.
			(cAliasPRD)->(dbGoTo((cAliasQry)->RECNOPRD))
			// Verifica requisições
			cQuery := "SELECT SUM(SD4.D4_QUANT) D4_QUANT,"
			cQuery +=       " SUM(SD4.D4_QTDEORI) D4_QTDEORI,"
			cQuery +=       " SD4.D4_LOCAL,"
			cQuery +=       " SD4.D4_COD,"
			cQuery +=       " SD4.D4_LOTECTL,"
			cQuery +=       " SD4.D4_NUMLOTE"
			cQuery +=  " FROM " +RetSqlName("SD4")+ " SD4"
			cQuery += " INNER JOIN "+oTmpTabSD4:GetRealName()+" TSD4"
			cQuery +=    " ON SD4.D4_FILIAL = '"+xFilial("SD4")+"'"
			cQuery +=   " AND TSD4.D4_COD = SD4.D4_COD"
			cQuery +=   " AND TSD4.D4_LOCAL = SD4.D4_LOCAL"
			cQuery +=   " AND TSD4.D4_LOTECTL = SD4.D4_LOTECTL"
			cQuery +=   " AND TSD4.D4_NUMLOTE = SD4.D4_NUMLOTE"
			cQuery +=   " AND TSD4.D4_OP = SD4.D4_OP"
			cQuery +=   " AND TSD4.D4_TRT = SD4.D4_TRT"
			cQuery +=   " AND TSD4.D4_MARK = '"+oBrwSD4:cMark+"'"
			cQuery +=   " AND TSD4.D_E_L_E_T_ = ' '"
			cQuery +=  " LEFT JOIN "+RetSqlName("SDC")+" SDC"
			cQuery +=    " ON SDC.DC_FILIAL = '"+xFilial("SDC")+"'"
			cQuery +=   " AND SD4.D4_FILIAL = '"+xFilial("SD4")+"'"
			cQuery +=   " AND SDC.DC_PRODUTO = SD4.D4_COD"
			cQuery +=   " AND SDC.DC_LOCAL = SD4.D4_LOCAL"
			cQuery +=   " AND SDC.DC_OP = SD4.D4_OP"
			cQuery +=   " AND SDC.DC_TRT = SD4.D4_TRT"
			cQuery +=   " AND SDC.DC_IDDCF = SD4.D4_IDDCF"
			cQuery +=   " AND SDC.DC_IDDCF <> '"+Space(TamSX3("DC_IDDCF")[1])+"'"
			cQuery +=   " AND SDC.DC_QUANT IS NULL"
			cQuery +=   " AND SDC.D_E_L_E_T_ = ' '"
			cQuery += " WHERE SD4.D4_FILIAL = '"+xFilial("SD4")+"'"
			cQuery +=   " AND SD4.D4_LOCAL = '"+(cAliasPRD)->D4_LOCDES+"'"
			cQuery +=   " AND SD4.D4_COD = '"+(cAliasPRD)->D4_COD+"'"
			cQuery +=   " AND SD4.D4_LOTECTL = '"+(cAliasPRD)->D4_LOTECTL+"'"
			cQuery +=   " AND SD4.D4_NUMLOTE = '"+(cAliasPRD)->D4_NUMLOTE+"'"
			cQuery +=   " AND SD4.D_E_L_E_T_ = ' '"
			cQuery += " GROUP BY SD4.D4_LOCAL,"
			cQuery +=          " SD4.D4_COD,"
			cQuery +=          " SD4.D4_LOTECTL,"
			cQuery +=          " SD4.D4_NUMLOTE"
			cQuery := ChangeQuery(cQuery)
			cAliasQr1 := GetNextAlias()
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQr1,.F.,.T.)
			TcSetField(cAliasQr1,'D4_QUANT','N',aTamSX3[1],aTamSX3[2])
			TcSetField(cAliasQr1,'D4_QTDEORI','N',aTamSX3[1],aTamSX3[2])
			// Total requisições pendentes
			nQtdReq := (cAliasQr1)->D4_QUANT
			// Verifica se há requisições já baixadas
			If QtdComp((cAliasQr1)->D4_QUANT) <> QtdComp((cAliasQr1)->D4_QTDEORI)
				ResumoMsg(WMSA50511,aResErro,,,(cAliasPRD)->D4_COD,(cAliasPRD)->D4_LOTECTL,(cAliasPRD)->D4_NUMLOTE,,STR0061) // Há requisições que foram baixadas
				lContinua := .F.
			EndIf
			(cAliasQr1)->(dbCloseArea())
			// Verifica se serviço informado
			If Empty((cAliasPRD)->D4_SERVIC)
				ResumoMsg(WMSA50501,aResErro,,,(cAliasPRD)->D4_COD,(cAliasPRD)->D4_LOTECTL,(cAliasPRD)->D4_NUMLOTE,,STR0039) // Serviço WMS não informado
				lContinua := .F.
			EndIf
			If Empty((cAliasPRD)->D4_ENDDES)
				ResumoMsg(WMSA50505,aResErro,,,(cAliasPRD)->D4_COD,(cAliasPRD)->D4_LOTECTL,(cAliasPRD)->D4_NUMLOTE,,STR0042) // Endereço destino não informado
				lContinua := .F.
			EndIf
			// Verifica se houve alteração na quantidade requisição
			If QtdComp((cAliasPRD)->D4_QUANT) > 0 .And. QtdComp((cAliasPRD)->D4_QUANT) <> QtdComp(nQtdReq)
				ResumoMsg(WMSA50506,aResErro,,,(cAliasPRD)->D4_COD,(cAliasPRD)->D4_LOTECTL,(cAliasPRD)->D4_NUMLOTE,,STR0043) // Houve alteração na quantidade saldo requisição
				lContinua := .F.
			EndIf
			// Verifica se houve alteração no saldo do endereço de produção
			oEstEnder:ClearData()
			oEstEnder:oProdLote:SetArmazem((cAliasPRD)->D4_LOCDES)
			oEstEnder:oProdLote:SetProduto((cAliasPRD)->D4_COD)
			oEstEnder:oProdLote:SetPrdOri((cAliasPRD)->D4_COD)
			oEstEnder:oProdLote:SetLoteCtl((cAliasPRD)->D4_LOTECTL)
			oEstEnder:oProdLote:SetNumLote((cAliasPRD)->D4_NUMLOTE)
			oEstEnder:oProdLote:SetNumSer("")
			oEstEnder:oProdLote:LoadData()
			// Atribui dados do endereço de produção
			oEstEnder:oEndereco:SetArmazem((cAliasPRD)->D4_LOCDES)
			oEstEnder:oEndereco:SetEnder((cAliasPRD)->D4_ENDDES)
			oEstEnder:SetProducao(.T.)
			// Busca saldo do produto no endereço de produção
			If QtdComp((cAliasPRD)->D4_SLDPRD) <> QtdComp(oEstEnder:ConsultSld(.F.,.T.,.T.,.T.))
				// Dados do resumo
				ResumoMsg(WMSA50514,aResErro,,,(cAliasPRD)->D4_COD,(cAliasPRD)->D4_LOTECTL,(cAliasPRD)->D4_NUMLOTE,,STR0044) // Houve alteração na quantidade saldo da produção
				lContinua := .F.
			EndIf
			// Valida estoque
			If !CalcEstoq((cAliasPRD)->D4_LOCORI,(cAliasPRD)->D4_ENDORI,(cAliasPRD)->D4_QUANT-(cAliasPRD)->D4_SLDPRD,(cAliasPRD)->D4_QTDSOL)
				// Busca saldo do produto no endereço de produção
				If !oEstEnder:oProdLote:HasRastro() .Or. (oEstEnder:oProdLote:HasRastro() .And. !Empty(oEstEnder:oProdLote:GetLoteCtl()))
					// Dados do resumo
					ResumoMsg(WMSA50507,aResErro,,,(cAliasPRD)->D4_COD,(cAliasPRD)->D4_LOTECTL,(cAliasPRD)->D4_NUMLOTE,,WmsFmtMsg(STR0057,{{"[VAR01]",AllTrim((cAliasPRD)->D4_COD)},{"[VAR02]",AllTrim((cAliasPRD)->D4_LOCORI)},{"[VAR03]",AllTrim((cAliasPRD)->D4_ENDORI)}})) // Não há saldo para o produto [VAR01] no armazém [VAR02] e endereço [VAR03] para atender a requisição!
					lContinua := .F.
				Else
					// Dados do resumo
					ResumoMsg(WMSA50531,aResErro,,,(cAliasPRD)->D4_COD,(cAliasPRD)->D4_LOTECTL,(cAliasPRD)->D4_NUMLOTE,,WmsFmtMsg(STR0031,{{"[VAR01]",AllTrim((cAliasPRD)->D4_COD)},{"[VAR02]",AllTrim((cAliasPRD)->D4_LOCORI)}})) // Não há saldo de lote para o produto [VAR01] no armazém [VAR02] para atender a requisição!
					lContinua := .F.
				EndIf
			EndIf
			
			If lContinua
				//Se for informada quantidade à solicitar menor, divide SD4
				nQtdDif := 0
				If QtdComp((cAliasPRD)->D4_QUANT) > QtdComp(((cAliasPRD)->D4_SLDPRD + (cAliasPRD)->D4_QTDSOL))
					nQtdDif := (cAliasPRD)->D4_QUANT-((cAliasPRD)->D4_SLDPRD + (cAliasPRD)->D4_QTDSOL)
				EndIf
				If QtdComp((cAliasPRD)->D4_SLDPRD) > 0 .Or. nQtdDif > 0
					nSldPrd := (cAliasPRD)->D4_SLDPRD
					// Verifica requisições
					cQuery := "SELECT SD4.R_E_C_N_O_ RECNOSD4,"
					cQuery +=       " TSD4.R_E_C_N_O_ RECNOTSD4"
					cQuery +=  " FROM " +RetSqlName("SD4")+ " SD4"
					cQuery += " INNER JOIN "+oTmpTabSD4:GetRealName()+" TSD4"
					cQuery +=    " ON SD4.D4_FILIAL = '"+xFilial("SD4")+"'"
					cQuery +=   " AND TSD4.D4_COD = SD4.D4_COD"
					cQuery +=   " AND TSD4.D4_LOCAL = SD4.D4_LOCAL"
					cQuery +=   " AND TSD4.D4_LOTECTL = SD4.D4_LOTECTL"
					cQuery +=   " AND TSD4.D4_NUMLOTE = SD4.D4_NUMLOTE"
					cQuery +=   " AND TSD4.D4_OP = SD4.D4_OP"
					cQuery +=   " AND TSD4.D4_TRT = SD4.D4_TRT"
					cQuery +=   " AND TSD4.D4_MARK = '"+oBrwSD4:cMark+"'"
					cQuery +=   " AND TSD4.D_E_L_E_T_ = ' '"
					cQuery += " WHERE SD4.D4_FILIAL = '"+xFilial("SD4")+"'"
					cQuery +=   " AND SD4.D4_LOCAL = '"+(cAliasPRD)->D4_LOCDES+"'"
					cQuery +=   " AND SD4.D4_COD = '"+(cAliasPRD)->D4_COD+"'"
					cQuery +=   " AND SD4.D4_LOTECTL = '"+(cAliasPRD)->D4_LOTECTL+"'"
					cQuery +=   " AND SD4.D4_NUMLOTE = '"+(cAliasPRD)->D4_NUMLOTE+"'"
					cQuery +=   " AND SD4.D_E_L_E_T_ = ' '"
					cQuery := ChangeQuery(cQuery)
					cAliasQr2 := GetNextAlias()
					dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQr2,.F.,.T.)
					Do While (cAliasQr2)->(!Eof()) .And. nQtdDif > 0
						SD4->(dbGoTo((cAliasQr2)->RECNOSD4))
						If SD4->D4_QUANT > nQtdDif
							WmsDivSD4(SD4->D4_COD,;
									 (cAliasPRD)->D4_LOCDES,;
									 SD4->D4_OP,;
									 SD4->D4_TRT,;
									 SD4->D4_LOTECTL,;
									 SD4->D4_NUMLOTE,;
									 Nil,;
									 nQtdDif,;
									 Nil,;
									 (cAliasPRD)->D4_ENDDES,;
									 Nil,;
									 .F.,;
									 Nil,;
									 Nil,;
									 @nNewRecno)
							nQtdDif := 0
						Else
							nQtdDif -= SD4->D4_QUANT
							//Como toda a SD4 será desconsiderada por conta da falta, remove o registro da tabela temporária
							(cAliasSD4)->(dbGoTo((cAliasQr2)->RECNOTSD4))
							RecLock((cAliasSD4), .F.)
							(cAliasSD4)->(dbDelete())
							MsUnLock()
						EndIf
						(cAliasQr2)->(DbSkip())
					EndDo
					(cAliasQr2)->(DbGoTop())
					Do While (cAliasQr2)->(!Eof()) .And. nSldPrd > 0
						SD4->(dbGoTo((cAliasQr2)->RECNOSD4))
						nQtdRat := IIf(QtdComp(nSldPrd) >= QtdComp(SD4->D4_QUANT),SD4->D4_QUANT,nSldPrd)
						Do While nQtdRat > 0
							lContinua := .T.
							// Busca saldo do produto no endereço de produção
							// Quando controla lote e o lote não foi informado no
							// Empenho de requisição, irá buscar o lote mais antigo, priorizando
							// o lote que atende na completude
							oEstEnder:ClearData()
							oEstEnder:oProdLote:SetArmazem((cAliasPRD)->D4_LOCDES)
							oEstEnder:oProdLote:SetProduto((cAliasPRD)->D4_COD)
							oEstEnder:oProdLote:SetPrdOri((cAliasPRD)->D4_COD)
							oEstEnder:oProdLote:SetLoteCtl((cAliasPRD)->D4_LOTECTL)
							oEstEnder:oProdLote:SetNumLote((cAliasPRD)->D4_NUMLOTE)
							oEstEnder:oProdLote:SetNumSer("")
							oEstEnder:oProdLote:LoadData()
							// Atribui dados do endereço de produção
							oEstEnder:oEndereco:SetArmazem((cAliasPRD)->D4_LOCDES)
							oEstEnder:oEndereco:SetEnder((cAliasPRD)->D4_ENDDES)
							
							If oEstEnder:FindSldPrd(nQtdRat)
								// Gera empenho da quantidade saldo produção
								SD4->(dbGoTo((cAliasQr2)->RECNOSD4))
								WmsDivSD4(SD4->D4_COD,;
											oEstEnder:oEndereco:GetArmazem(),;
											SD4->D4_OP,;
											SD4->D4_TRT,;
											oEstEnder:oProdLote:GetLoteCtl(),;
											oEstEnder:oProdLote:GetNumLote(),;
											Nil,;
											oEstEnder:GetQuant(),;
											Nil,;
											oEstEnder:oEndereco:GetEnder(),;
											Nil,;
											.T.,;
											Nil,;
											Nil,;
											@nNewRecno)
								// Gera empenho no estoque por endereço
								SD4->(dbGoTo(nNewRecno))
								oEstEnder:UpdSaldo("499",.F. /*lEstoque*/,.F. /*lEntPrev*/,.F. /*lSaiPrev*/,.T. /*lEmpenho*/,.F. /*lBloqueio*/)
								// Empenha SB2 e SB8
								If Rastro(SD4->D4_COD) .And. Empty((cAliasPRD)->D4_LOTECTL)
									GravaEmp(SD4->D4_COD,;        // Produto
												SD4->D4_LOCAL,;   // Armazem
												SD4->D4_QUANT,;   // Quantidade
												Nil,;             // Quantidade 2 UM
												SD4->D4_LOTECTL,; // Lote
												SD4->D4_NUMLOTE,; // Sub-Lote
												Nil,;             // Endereço
												Nil,;             // Número de série
												SD4->D4_OP,;      // Ordem de produção
												SD4->D4_TRT,;     // Trt Op
												Nil,; // Pedido
												Nil,; // Seq. Pedido
												'SD4',; // Origem
												Nil,; // Op Origem
												Nil,; // Data Entrega
												Nil,; // aTravas
												Nil,; // Estorno
												Nil,; // Projeto
												.T.,; // Empenha SB2
												.F.,; // Grava SD4
												Nil,; // Consulta Vencidos
												.T.,; // Empenha SB8/SBF
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
								EndIf
								// Dados do resumo
								ResumoMsg(WMSA50512,aResOk,SD4->D4_OP,SD4->D4_TRT,SD4->D4_COD,SD4->D4_LOTECTL,SD4->D4_NUMLOTE,SD4->D4_QUANT,STR0045) // Quantidade empenhada
								nQtdRat -= SD4->D4_QUANT
								nSldPrd -= SD4->D4_QUANT
							Else
								ResumoMsg(WMSA50502,aResErro,,,(cAliasPRD)->D4_COD,(cAliasPRD)->D4_LOTECTL,(cAliasPRD)->D4_NUMLOTE,(cAliasPRD)->D4_QTDSOL,oEstEnder::GetErro())
								lContinua := .F.
							EndIf
						EndDo
						// Delete SD4 temporária pois foi empenhada
						If lContinua .And. (cAliasQr2)->RECNOSD4 == nNewRecno
							(cAliasSD4)->(dbGoTo((cAliasQr2)->RECNOTSD4))
							RecLock(cAliasSD4,.F.)
							(cAliasSD4)->(dbDelete())
							(cAliasSD4)->(MsUnLock())
						EndIf
						(cAliasQr2)->(dbSkip())
					EndDo
					(cAliasQr2)->(dbCloseArea())
				EndIf
				// Se ainda houver quantidade do produto requisitado, é criado a DCF
				If QtdComp((cAliasPRD)->D4_QTDSOL) > 0
					Begin Transaction
						// Dados serviço
						oOrdServ:oServico:SetServico((cAliasPRD)->D4_SERVIC)
						// Dados produto
						oOrdServ:oProdLote:SetArmazem((cAliasPRD)->D4_LOCDES)
						oOrdServ:oProdLote:SetProduto((cAliasPRD)->D4_COD)
						oOrdServ:oProdLote:SetPrdOri((cAliasPRD)->D4_COD)
						oOrdServ:oProdLote:SetLoteCtl((cAliasPRD)->D4_LOTECTL)
						oOrdServ:oProdLote:SetNumLote((cAliasPRD)->D4_NUMLOTE)
						// Dados endereço origem
						oOrdServ:oOrdEndOri:SetArmazem((cAliasPRD)->D4_LOCORI)
						oOrdServ:oOrdEndOri:SetEnder((cAliasPRD)->D4_ENDORI)
						// Dados endereço destino
						oOrdServ:oOrdEndDes:SetArmazem((cAliasPRD)->D4_LOCDES)
						oOrdServ:oOrdEndDes:SetEnder((cAliasPRD)->D4_ENDDES)
						// Dados gerais
						oOrdServ:SetOrigem("SD4")
						oOrdServ:SetRegra((cAliasPRD)->D4_REGRA)
						oOrdServ:SetQuant((cAliasPRD)->D4_QTDSOL)
						If oOrdServ:CreateDCF()
							// Verifica requisições
							cQuery := "SELECT SD4.R_E_C_N_O_ RECNOSD4"
							cQuery +=  " FROM " +RetSqlName("SD4")+ " SD4"
							cQuery += " INNER JOIN "+oTmpTabSD4:GetRealName()+" TSD4"
							cQuery +=    " ON SD4.D4_FILIAL = '"+xFilial("SD4")+"'"
							cQuery +=   " AND TSD4.D4_COD = SD4.D4_COD"
							cQuery +=   " AND TSD4.D4_LOCAL = SD4.D4_LOCAL"
							cQuery +=   " AND TSD4.D4_LOTECTL = SD4.D4_LOTECTL"
							cQuery +=   " AND TSD4.D4_NUMLOTE = SD4.D4_NUMLOTE"
							cQuery +=   " AND TSD4.D4_OP = SD4.D4_OP"
							cQuery +=   " AND TSD4.D4_TRT = SD4.D4_TRT"
							cQuery +=   " AND TSD4.D4_MARK = '"+oBrwSD4:cMark+"'"
							cQuery +=   " AND TSD4.D_E_L_E_T_ = ' '"
							cQuery += " WHERE SD4.D4_FILIAL = '"+xFilial("SD4")+"'"
							cQuery +=   " AND SD4.D4_LOCAL = '"+(cAliasPRD)->D4_LOCDES+"'"
							cQuery +=   " AND SD4.D4_COD = '"+(cAliasPRD)->D4_COD+"'"
							cQuery +=   " AND SD4.D4_LOTECTL = '"+(cAliasPRD)->D4_LOTECTL+"'"
							cQuery +=   " AND SD4.D4_NUMLOTE = '"+(cAliasPRD)->D4_NUMLOTE+"'"
							cQuery +=   " AND SD4.D_E_L_E_T_ = ' '"
							cQuery := ChangeQuery(cQuery)
							cAliasQr2 := GetNextAlias()
							dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQr2,.F.,.T.)
							If (cAliasQr2)->(!Eof())
								nSldPrd   := (cAliasPRD)->D4_QTDSOL
								Do While lRet .And. (cAliasQr2)->(!Eof()) .And. QtdComp(nSldPrd) > 0
									SD4->(dbGoTo((cAliasQr2)->RECNOSD4))
									RecLock('SD4',.F.)
									SD4->D4_IDDCF := oOrdServ:GetIdDCF()
									SD4->(MsUnLock())
									// Se for uma origem 
									If lRet .And. (cAliasPRD)->D4_LOCORI <> (cAliasPRD)->D4_LOCDES
										// Dados lote e sublote
										oOrdServ:oProdLote:SetLoteCtl(SD4->D4_LOTECTL)
										oOrdServ:oProdLote:SetNumLote(SD4->D4_NUMLOTE)
										// Dados Requisição
										oOrdServ:SetOp(SD4->D4_OP)
										oOrdServ:SetTrt(SD4->D4_TRT)
										oOrdServ:SetQuant(SD4->D4_QUANT)
										// Passa a referência da OS para a função
										WmsOrdSer(oOrdServ)
										lRet := WmsGeraDH1("WMSA505",.F.,.F.)
									EndIf
									If lRet
										nSldPrd -= SD4->D4_QUANT
										// Dados do resumo
										ResumoMsg(WMSA50515,aResOk,SD4->D4_OP,SD4->D4_TRT,SD4->D4_COD,SD4->D4_LOTECTL,SD4->D4_NUMLOTE,SD4->D4_QUANT,WmsFmtMsg(STR0046,{{"[VAR01]",AllTrim(SD4->D4_IDDCF)}})) // Ordem de serviço [VAR01] gerada
									EndIf
									(cAliasQr2)->(dbSkip())
								EndDo
								(cAliasQr2)->(DbGoTop())
								//Reserva para a quantidade à maior
								If QtdComp((nQtdReq - (cAliasPRD)->D4_SLDPRD)) < QtdComp((cAliasPRD)->D4_QTDSOL)
									// Ajusta primeira SD4
									SD4->(dbGoTo((cAliasQr2)->RECNOSD4))
									cOp      := SD4->D4_OP
									cTrt     := Soma1(WMaxTrtSD4(SD4->D4_OP,SD4->D4_COD))
									dDtValid := SD4->D4_DTVALID
									nQtdEmp  := (cAliasPRD)->D4_QTDSOL - (nQtdReq - (cAliasPRD)->D4_SLDPRD)
									GravaEmp(SD4->D4_COD,;        // Produto
												SD4->D4_LOCAL,;   // Armazem
												nQtdEmp,;         // Quantidade
												Nil,;             // Quantidade 2 UM
												SD4->D4_LOTECTL,; // Lote
												SD4->D4_NUMLOTE,; // Sub-Lote
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
												.T.,; // Empenha SB2
												.T.,; // Grava SD4
												Nil,; // Consulta Vencidos
												.T.,; // Empenha SB8/SBF
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
										If SD4->(dbSeek(xFilial("SD4")+(cAliasPRD)->D4_COD+cOp+cTrt+(cAliasPRD)->D4_LOTECTL+(cAliasPRD)->D4_NUMLOTE))
											RecLock('SD4',.F.)
											SD4->D4_QTDEORI := 0
											SD4->D4_DATA    := dDatabase
											SD4->D4_IDDCF   := oOrdServ:GetIdDCF()
											SD4->(MsUnLock())
											// Se for uma origem 
											If lRet .And. (cAliasPRD)->D4_LOCORI <> (cAliasPRD)->D4_LOCDES
												// Dados lote e sublote
												oOrdServ:oProdLote:SetLoteCtl(SD4->D4_LOTECTL)
												oOrdServ:oProdLote:SetNumLote(SD4->D4_NUMLOTE)
												// Dados Requisição
												oOrdServ:SetOp(SD4->D4_OP)
												oOrdServ:SetTrt(SD4->D4_TRT)
												oOrdServ:SetQuant(SD4->D4_QUANT)
												// Passa a referência da OS para a função
												WmsOrdSer(oOrdServ)
												lRet := WmsGeraDH1("WMSA505",.F.,.F.)
											EndIf
											// Dados do resumo
											ResumoMsg(WMSA50515,aResOk,SD4->D4_OP,SD4->D4_TRT,SD4->D4_COD,SD4->D4_LOTECTL,SD4->D4_NUMLOTE,SD4->D4_QUANT,WmsFmtMsg(STR0046,{{"[VAR01]",AllTrim(SD4->D4_IDDCF)}})) // Ordem de serviço [VAR01] gerada
										EndIf
									EndIf
								EndIf
							EndIf
							(cAliasQr2)->(dbCloseArea())
						Else
							ResumoMsg(WMSA50502,aResErro,,,(cAliasPRD)->D4_COD,(cAliasPRD)->D4_LOTECTL,(cAliasPRD)->D4_NUMLOTE,(cAliasPRD)->D4_QTDSOL,oOrdServ:GetErro())
							DisarmTransaction()
						EndIf
					End Transaction
				EndIf
			EndIf
			(cAliasQry)->(dbSkip())
		EndDo
		// Verifica as Ordens de servico geradas para execução automatica
		If Len(oOrdServ:aLibDCF) > 0
			For nX := 1 To Len(oOrdServ:aLibDCF)
				oOrdSerExe:SetIdDCF(oOrdServ:aLibDCF[nX])
				If oOrdSerExe:LoadData()
					oOrdSerExe:SetArrLib(oRegraConv:GetArrLib())
					oOrdSerExe:ExecuteDCF()
				EndIf
			Next nX
		EndIf
	
		If !Empty(oRegraConv:GetArrLib())
			oRegraConv:LawExecute()
		EndIf
		// Aviso
		oOrdServ:ShowWarnig()
		// Resumo problemas processo
		AvisoRes(oOrdServ,aResErro,aResOk)
		// Destroy classes
		oOrdServ:Destroy()
		oOrdSerExe:Destroy()
		oRegraConv:Destroy()
	EndIf
	(cAliasQry)->(dbCloseArea())
	// Carrega os dados na tabela temporária de requisições
	CargaTemp()
	AtualBrw()
	// Restaura area
	RestArea(aAreaDCF)
	RestArea(aAreaAnt)
Return lRet
//--------------------------------------------------------------------
/*/{Protheus.doc} CalcMult
Funcao para alteracao do Servico/End. Destino

@author Tiago Filipe da Silva
@since 10/04/14
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function CalcMult()
Local lRet     := .T.
Local oProduto := WMSDTCProdutoDadosGenericos():New()
	Do While (cAliasPRD)->(!Eof())
		oProduto:SetProduto((cAliasPRD)->D4_COD)
		If oProduto:LoadData()
			If oProduto:GetTipConv() == "D" .And. oProduto:ChkFatConv() .And. QtdComp((cAliasPRD)->D4_QTDSOL) > 0
				RecLock(cAliasPRD,.F.)
				(cAliasPRD)->D4_QTDSOL := NoRound(Round((cAliasPRD)->D4_QTDSOL / oProduto:GetConv(),0), 0) * oProduto:GetConv()
				(cAliasPRD)->D4_QTDSO2 := ConvUM((cAliasPRD)->D4_COD, (cAliasPRD)->D4_QTDSOL, 0, 2)
				(cAliasPRD)->(MsUnlock())
			EndIf
		EndIf
		(cAliasPRD)->(dbSkip())
	EndDo

	oBrwPRD:oBrowse:Refresh(.T.)
Return lRet
//--------------------------------------------------------------------
/*/{Protheus.doc} Estornar
Estorno das requisições selecionadas

@author Tiago Filipe da Silva
@since 15/04/14
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function Estornar()
Local aAreaDCF  := DCF->(GetArea())
Local aResErro  := {}
Local aResOk    := {}
Local aTamSX3   := TamSx3("D4_QUANT")
Local cQuery    := ""
Local cAliasQry := ""
Local cAliasQr1 := ""
Local cAliasQr2 := ""
Local cAliasDH1 := ""
Local cIdDCF    := ""
Local cCod      := ""
Local cOp       := ""
Local cTrt      := ""
Local cLoteCtl  := ""
Local cNumLote  := ""
Local nQtdReq   := 0
Local nQuant    := 0
Local nQtdOri   := 0
Local lEstorno  := .F.
Local lOutraOp  := .F.
Local oOrdSerDel:= WMSDTCOrdemServicoDelete():New()
	// Verifica se há alguma requisição selecionada
	cQuery := "SELECT SD4.R_E_C_N_O_ RECNOSD4"
	cQuery +=  " FROM "+RetSqlName("SD4")+" SD4"
	cQuery += " INNER JOIN "+oTmpTabSD4:GetRealName()+" TSD4"
	cQuery +=    " ON TSD4.D4_LOCAL = SD4.D4_LOCAL"
	cQuery +=   " AND TSD4.D4_OP = SD4.D4_OP"
	cQuery +=   " AND TSD4.D4_TRT = SD4.D4_TRT"
	cQuery +=   " AND TSD4.D4_COD = SD4.D4_COD"
	cQuery +=   " AND TSD4.D4_LOTECTL = SD4.D4_LOTECTL"
	cQuery +=   " AND TSD4.D4_NUMLOTE = SD4.D4_NUMLOTE"
	cQuery +=   " AND TSD4.D4_MARK = '"+oBrwSD4:cMark+"'"
	cQuery +=   " AND TSD4.D_E_L_E_T_ = ' '"
	cQuery += " WHERE SD4.D4_FILIAL = '"+xFilial("SD4")+"'"
	cQuery +=   " AND SD4.D4_IDDCF <> '"+Space(TamSX3("D4_IDDCF")[1])+"'"
	cQuery +=   " AND SD4.D4_QTDEORI > 0"
	cQuery +=   " AND SD4.D_E_L_E_T_ = ' '"
	cQuery:= ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
	TcSetField(cAliasQry,'D4_QUANT','N',aTamSX3[1],aTamSX3[2])
	TcSetField(cAliasQry,'D4_QTDEORI','N',aTamSX3[1],aTamSX3[2])
	Do While (cAliasQry)->(!Eof())
		SD4->(dbGoTo((cAliasQry)->RECNOSD4))

		lEstorno  := .F.
		lOutraOp  := .F.
		cCod      := SD4->D4_COD
		cOp       := SD4->D4_OP
		cTrt      := SD4->D4_TRT
		cLoteCtl  := SD4->D4_LOTECTL
		cNumLote  := SD4->D4_NUMLOTE
		cIdDCF    := SD4->D4_IDDCF
		nQuant    := SD4->D4_QUANT
		nQtdOri   := SD4->D4_QTDEORI
		// Carrega ordem de serviço
		oOrdSerDel:SetIdDCF(cIdDCF)
		If oOrdSerDel:LoadData()
			// Verifica se há mais de uma requisições para ordem de serviço
			cQuery := "SELECT 1"
			cQuery +=  " FROM " +RetSqlName("SD4")+ " SD4"
			cQuery += " WHERE SD4.D4_FILIAL = '"+xFilial("SD4")+"'"
			cQuery +=   " AND SD4.D4_IDDCF = '"+cIdDCF+"'"
			cQuery +=   " AND (SD4.D4_OP <> '"+cOp+"'"
			cQuery +=   " OR (SD4.D4_OP = '"+cOp+"' AND SD4.D4_TRT <> '"+cTrt+"'))"
			cQuery +=   " AND SD4.D4_QTDEORI > 0"
			cQuery +=   " AND SD4.D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			cAliasQr1 := GetNextAlias()
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQr1,.F.,.T.)
			If (cAliasQr1)->(!Eof())
				lOutraOp := .T.
			EndIf
			(cAliasQr1)->(dbCloseArea())
			
			Begin Transaction
				lEstorno := .F.
				If oOrdSerDel:GetStServ() == "3"
					If !lOutraOp
						If QtdComp(nQuant) == QtdComp(nQtdOri)
							If oOrdSerDel:CanDelete()
								If oOrdSerDel:DeleteDCF()
									If !(oOrdSerDel:oOrdEndOri:GetArmazem() == oOrdSerDel:oOrdEndDes:GetArmazem())
										cQuery := " SELECT R_E_C_N_O_ RECNODH1"
										cQuery +=   " FROM "+RetSqlName("DH1")+" DH1"
										cQuery +=  " WHERE DH1.DH1_FILIAL = '"+xFilial("DH1")+"'"
										cQuery +=    " AND DH1.DH1_IDDCF = '"+oOrdSerDel:GetIdDCF()+"'"
										cQuery +=    " AND DH1.D_E_L_E_T_ = ' '"
										cQuery +=  " ORDER BY DH1.R_E_C_N_O_"
										cQuery := ChangeQuery(cQuery)
										cAliasDH1 := GetNextAlias()
										DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDH1,.F.,.T.)
										While (cAliasDH1)->(!Eof())
											DH1->(dbGoTo((cAliasDH1)->RECNODH1))
											RecLock("DH1",.F.)
											DH1->(dbDelete())
											DH1->(MsUnlock())
											(cAliasDH1)->(dbSkip())
										EndDo
										(cAliasDH1)->(dbCloseArea())
										// Retira a reserva da SB2 da quantidade cancelada
										oOrdSerDel:UpdEmpSB2("-",oOrdSerAux:oProdLote:GetPrdOri(),oOrdSerAux:oOrdEndOri:GetArmazem(),oOrdSerAux:GetQuant())
									EndIf
									lEstorno := .T.
									// Dados do resumo
									ResumoMsg(WMSA50513,aResOk,cOp,cTrt,cCod,cLoteCtl,cNumLote,nQuant,WmsFmtMsg(STR0041,{{"[VAR01]",AllTrim(cIdDCF)}})) // Ordem de serviço [VAR01] excluída!
								EndIf
							EndIf
							If !lEstorno
								ResumoMsg(WMSA50534,aResErro,cOp,cTrt,cCod,cLoteCtl,cNumLote,nQuant,WmsFmtMsg(oOrdSerDel:GetErro(),{{"[VAR01]",AllTrim(cIdDCF)}}))
							EndIf
						Else
							ResumoMsg(WMSA50516,aResErro,cOp,cTrt,cCod,cLoteCtl,cNumLote,nQuant,WmsFmtMsg(STR0060,{{"[VAR01]",AllTrim(cIdDCF)}})) // A ordem de serviço [VAR01] não pode ser estornada, requisiçao já possui baixa!
						EndIf
					Else
						ResumoMsg(WMSA50510,aResErro,cOp,cTrt,cCod,cLoteCtl,cNumLote,nQuant,WmsFmtMsg(STR0047,{{"[VAR01]",AllTrim(cIdDCF)}})) // A ordem de serviço [VAR01] deverá ser estornada manualmente no WMS.
					EndIf
				Else
					If !lOutraOp
						If QtdComp(nQuant) == QtdComp(nQtdOri)
							If oOrdSerDel:CanDelete()
								If oOrdSerDel:DeleteDCF()
									lEstorno := .T.
									// Dados do resumo
									ResumoMsg(WMSA50533,aResOk,cOp,cTrt,cCod,cLoteCtl,cNumLote,nQuant,WmsFmtMsg(STR0041,{{"[VAR01]",AllTrim(cIdDCF)}})) // Ordem de serviço [VAR01] excluída!
								EndIf
							EndIf
							If !lEstorno
								ResumoMsg(WMSA50535,aResErro,cOp,cTrt,cCod,cLoteCtl,cNumLote,nQuant,WmsFmtMsg(oOrdSerDel:GetErro(),{{"[VAR01]",AllTrim(cIdDCF)}}))
							EndIf
						Else
							ResumoMsg(WMSA50516,aResErro,cOp,cTrt,cCod,cLoteCtl,cNumLote,nQuant,WmsFmtMsg(STR0060,{{"[VAR01]",AllTrim(cIdDCF)}})) // A ordem de serviço [VAR01] não pode ser estornada, requisiçao já possui baixa!
						EndIf
					Else
						// Verifica requisições
						cQuery := "SELECT SUM(SD4.D4_QUANT) D4_QUANT,"
						cQuery +=       " SUM(SD4.D4_QTDEORI) D4_QTDEORI"
						cQuery +=  " FROM " +RetSqlName("SD4")+ " SD4"
						cQuery += " INNER JOIN "+oTmpTabSD4:GetRealName()+" TSD4"
						cQuery +=    " ON TSD4.D4_LOCAL = SD4.D4_LOCAL"
						cQuery +=   " AND TSD4.D4_OP = SD4.D4_OP"
						cQuery +=   " AND TSD4.D4_TRT = SD4.D4_TRT"
						cQuery +=   " AND TSD4.D4_COD = SD4.D4_COD"
						cQuery +=   " AND TSD4.D4_LOTECTL = SD4.D4_LOTECTL"
						cQuery +=   " AND TSD4.D4_NUMLOTE = SD4.D4_NUMLOTE"
						cQuery +=   " AND TSD4.D4_MARK = '"+oBrwSD4:cMark+"'"
						cQuery +=   " AND TSD4.D_E_L_E_T_ = ' '"
						cQuery += " WHERE SD4.D4_FILIAL = '"+xFilial("SD4")+"'"
						cQuery +=   " AND SD4.D4_IDDCF = '"+cIdDCF+"'"
						cQuery +=   " AND SD4.D_E_L_E_T_ = ' '"
						cQuery := ChangeQuery(cQuery)
						cAliasQr1 := GetNextAlias()
						dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQr1,.F.,.T.)
						TcSetField(cAliasQr1,'D4_QUANT','N',aTamSX3[1],aTamSX3[2])
						TcSetField(cAliasQr1,'D4_QTDEORI','N',aTamSX3[1],aTamSX3[2])
						If (cAliasQr1)->D4_QUANT <> (cAliasQr1)->D4_QTDEORI
							ResumoMsg(WMSA50509,aResErro,cOp,cTrt,cCod,cLoteCtl,cNumLote,nQuant,WmsFmtMsg(STR0059,{{"[VAR01]",AllTrim(cIdDCF)}})) // A ordem de serviço [VAR01] não pode ser estornada, existem requisiçoes baixadas!
						Else
							lEstorno := .T.
							oOrdSerDel:SetQuant(oOrdSerDel:GetQuant() - nQuant)
							oOrdSerDel:SetQtdOri(oOrdSerDel:GetQtdOri() - nQuant)
							oOrdSerDel:UpdateDCF()
							If oOrdSerDel:ChkMovEst(.F.)
								lRet := oOrdSerDel:ReverseMO(nQuant)
								If lRet
									lRet := oOrdSerDel:ReverseMI(nQuant)
								EndIf
							EndIf
							// Verifica se existe movimentos para a ordem de serviço se não existir excluir a ordem de serviço
							If oOrdSerDel:GetQuant() == 0
								lEstorno := oOrdSerDel:CancelDCF()
							EndIf
							If lEstorno
								If !(oOrdSerDel:oOrdEndOri:GetArmazem() == oOrdSerDel:oOrdEndDes:GetArmazem())
									// Atualiza DH1
									cQuery := " SELECT R_E_C_N_O_ RECNODH1"
									cQuery +=   " FROM "+RetSqlName("DH1")+" DH1"
									cQuery +=  " WHERE DH1.DH1_FILIAL = '"+xFilial("DH1")+"'"
									cQuery +=    " AND DH1.DH1_IDDCF = '"+oOrdSerDel:GetIdDCF()+"'"
									If !Empty(oOrdSerDel:oProdLote:GetLoteCtl())
										cQuery +=  " AND DH1.DH1_LOTECT = '"+oOrdSerDel:oProdLote:GetLoteCtl()+"'"
									EndIf
									If !Empty(oOrdSerDel:oProdLote:GetNumLote())
										cQuery +=  " AND DH1.DH1_NUMLOT = '"+oOrdSerDel:oProdLote:GetNumLote()+"'"
									EndIf
									cQuery +=    " AND DH1.D_E_L_E_T_ = ' '"
									cQuery +=  " ORDER BY DH1.R_E_C_N_O_"
									cQuery := ChangeQuery(cQuery)
									cAliasDH1 := GetNextAlias()
									DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDH1,.F.,.T.)
									If (cAliasDH1)->(!Eof())
										nQtdReq := nQuant
										Do While (cAliasDH1)->(!Eof()) .And. nQtdReq > 0
											DH1->(dbGoTo((cAliasDH1)->RECNODH1))
											RecLock("DH1",.F.)
											If QtdComp(DH1->DH1_QUANT) <= QtdComp(nQtdReq)
												nQtdReq -= DH1->DH1_QUANT
												DH1->DH1_QUANT := 0
											Else
												DH1->DH1_QUANT -= nQtdReq
												nQtdReq := 0
											EndIf
											If DH1->DH1_QUANT <= 0
												DH1->(dbDelete())
											EndIf
											DH1->(MsUnlock())
											(cAliasDH1)->(dbSkip())
										EndDo
									EndIf
									(cAliasDH1)->(dbCloseArea())
									// Retira a reserva da SB2 da quantidade cancelada
									oOrdSerDel:UpdEmpSB2("-",oOrdSerDel:oProdLote:GetPrdOri(),oOrdSerDel:oOrdEndOri:GetArmazem(),nQuant)
								EndIf
							EndIf
							If !lEstorno
								ResumoMsg(WMSA50510,aResErro,cOp,cTrt,cCod,cLoteCtl,cNumLote,nQuant,oOrdSerDel:GetErro())
							Else
								// Dados do resumo
								ResumoMsg(WMSA50508,aResOk,cOp,cTrt,cCod,cLoteCtl,cNumLote,nQuant,WmsFmtMsg(STR0058,{{"[VAR01]",AllTrim(cIdDCF)}})) // Ordem Serviço [VAR01] alterada!
							EndIf
						EndIf
						(cAliasQr1)->(dbCloseArea())
					EndIf
				EndIf
				If lEstorno
					// Apaga a IDDCF da SD4
					cQuery := "SELECT SD4.R_E_C_N_O_ RECNOSD4"
					cQuery +=  " FROM " +RetSqlName("SD4")+ " SD4"
					cQuery += " WHERE SD4.D4_FILIAL = '"+xFilial("SD4")+"'"
					cQuery +=   " AND SD4.D4_COD = '"+cCod+"'"
					cQuery +=   " AND SD4.D4_OP = '"+cOp+"'"
					cQuery +=   " AND SD4.D4_TRT = '"+cTrt+"'"
					cQuery +=   " AND SD4.D4_LOTECTL = '"+oOrdSerDel:oProdLote:GetLoteCtl()+"'"
					cQuery +=   " AND SD4.D4_NUMLOTE = '"+oOrdSerDel:oProdLote:GetNumLote()+"'"
					cQuery +=   " AND SD4.D4_IDDCF = '"+cIdDCF+"'"
					cQuery +=   " AND SD4.D4_QTDEORI > 0"
					cAliasQr1 := GetNextAlias()
					dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQr1,.F.,.T.)
					Do While (cAliasQr1)->(!Eof())
						
						SD4->(dbGoTo((cAliasQr1)->RECNOSD4))
						
						RecLock('SD4',.F.)
						SD4->D4_IDDCF   := ' '
						SD4->(MsUnLock())
						
						// Verifica requisições
						cQuery := "SELECT SD4.R_E_C_N_O_ RECNOSD4"
						cQuery +=  " FROM " +RetSqlName("SD4")+ " SD4"
						cQuery += " WHERE SD4.D4_FILIAL = '"+xFilial("SD4")+"'"
						cQuery +=   " AND SD4.D4_IDDCF = '"+cIdDCF+"'"
						cQuery +=   " AND SD4.D4_QTDEORI = 0"
						cQuery +=   " AND NOT EXISTS (SELECT 1"
						cQuery +=                     " FROM " +RetSqlName("SD4")+ " SD4A"
						cQuery +=                    " WHERE SD4A.D4_FILIAL = '"+xFilial("SD4")+"'"
						cQuery +=                      " AND SD4A.D4_IDDCF = '"+cIdDCF+"'"
						cQuery +=                      " AND SD4A.D4_QTDEORI > 0"
						cQuery +=                      " AND SD4A.D_E_L_E_T_ = ' ')"
						cQuery +=   " AND SD4.D_E_L_E_T_ = ' '"
						cQuery := ChangeQuery(cQuery)
						cAliasQr2 := GetNextAlias()
						dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQr2,.F.,.T.)
						Do While (cAliasQr2)->(!Eof())
							// Ajusta primeira SD4
							SD4->(dbGoTo((cAliasQr2)->RECNOSD4))
							// Atualiza quantidade empenho de acordo com a quantidade requisitada
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
									.T.,;                     // Estorno
									Nil,;                     // Projeto
									.T.,;                     // Empenha SB2
									.T.,;                     // Grava SD4
									Nil,;                     // Consulta Vencidos
									.T.,;                     // Empenha SB8/SBF
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
							// Dados do resumo
							ResumoMsg(WMSA50532,aResOk,SD4->D4_OP,SD4->D4_TRT,SD4->D4_COD,SD4->D4_LOTECTL,SD4->D4_NUMLOTE,SD4->D4_QUANT,WmsFmtMsg(STR0041,{{"[VAR01]",AllTrim(SD4->D4_IDDCF)}})) // Ordem de serviço [VAR01] excluída!							
							// Elimina SD4
							RecLock('SD4',.F.)
							SD4->(dbDelete())
							SD4->(MsUnLock())
							
							(cAliasQr2)->(dbSkip())
						EndDo
						(cAliasQr2)->(dbCloseArea())
						(cAliasQr1)->(dbSkip())
					EndDo
					(cAliasQr1)->(dbCloseArea())
				EndIf
				(cAliasQry)->(dbSkip())
				If !lEstorno
					DisarmTransaction()
				EndIf
			End Transaction
		EndIf
	EndDo
	(cAliasQry)->(dbCloseArea())
	// Resumo problemas processo
	AvisoRes(oOrdSerDel,aResErro,aResOk)
	// Carrega os dados na tabela temporária de requisições
	CargaTemp()
	AtualBrw()
	// Restaura area
	RestArea(aAreaDCF)
Return Nil
//--------------------------------------------------------------------
/*/{Protheus.doc} Selecao
Função para chamada do Pergunte e atualização dos dados

@author Tiago Filipe da Silva
@since 16/04/14
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function Selecao()
	If Pergunte('WMSA505',.T.)
		CargaTemp()
		AtualBrw()
	EndIf
Return .T.
//--------------------------------------------------------------------
/*/{Protheus.doc} AtualBrw
Atualiza browses

@author Tiago Filipe da Silva
@since 16/04/14
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function AtualBrw()
	oBrwPRD:Refresh(.T.)
	oBrwSD4:Refresh(.T.)
Return .T.
//--------------------------------------------------------------------
/*/{Protheus.doc} ResumoMsg
Resumo

@author SQUAD WMS Logistica
@since 21/07/2017
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function ResumoMsg(cTitulo,aResumo,cOp,cTrt,cProduto,cLoteCtl,cNumLote,nQuant,cResumo)
Local lRet      := .T.
Local cMensagem := ""

Default cTitulo  := ""
Default cOp      := ""
Default cProduto := ""
Default cLoteCtl := ""
Default cNumLote := ""
Default nQuant   := 0
Default cResumo  := ""
	If !Empty(cTitulo)
		cMensagem += cTitulo +" - "
	EndIf
	If !Empty(cOp)
		cMensagem += WmsFmtMsg(STR0048,{{"[VAR01]",cOp}})+" | " // Ordem de produção [VAR01]
	EndIf
	If !Empty(cTrt)
		cMensagem += WmsFmtMsg(STR0049,{{"[VAR01]",cTrt}})+" | " // Sequência [VAR01]
	EndIf
	If !Empty(cProduto)
		cMensagem += WmsFmtMsg(STR0050,{{"[VAR01]",cProduto}})+" | " // Produto [VAR01]
	EndIf
	If !Empty(cLoteCtl)
		cMensagem += WmsFmtMsg(STR0051,{{"[VAR01]",cLoteCtl}})+" | " // Lote [VAR01]	
	EndIf
	If !Empty(cNumLote)
		cMensagem += WmsFmtMsg(STR0052,{{"[VAR01]",cNumLote}})+" | " // Sub-lote [VAR01]	
	EndIf
	If QtdComp(nQuant) > 0
		cMensagem += WmsFmtMsg(STR0053,{{"[VAR01]",NtoC(nQuant,10)}})+" | " // Quantidade [VAR01]
	EndIf
	cMensagem += AllTrim(cResumo)
	aAdd(aResumo,cMensagem)
Return lRet
//--------------------------------------------------------------------
/*/{Protheus.doc} AvisoRes
Monta aviso resumo

@author SQUAD WMS Logistica
@since 21/07/2017
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function AvisoRes(oOrdServ,aResErro,aResOk)
Local lRet := .T.
Local nI   := 0

Default aResErro := {}
Default aResOk   := {}
	
	oOrdServ:aWmsAviso := {}

	If !Empty(aResErro)
		aAdd(oOrdServ:aWmsAviso,Replicate("- ",70))
		aAdd(oOrdServ:aWmsAviso,STR0055) // RESUMO DA(S) DIVERGÊNCIA(S)
		aAdd(oOrdServ:aWmsAviso,Replicate("- ",70))
		For nI := 1 To Len(aResErro)
			aAdd(oOrdServ:aWmsAviso,aResErro[nI])
		Next nI
		aAdd(oOrdServ:aWmsAviso,"")
	EndIf
	// Resumo confirmações processo
	If !Empty(aResOk)
		aAdd(oOrdServ:aWmsAviso,Replicate("- ",70))
		aAdd(oOrdServ:aWmsAviso,STR0055) // RESUMO OP(S) INTEGRADA(S) WMS
		aAdd(oOrdServ:aWmsAviso,Replicate("- ",70))
		For nI := 1 To Len(aResOk)
			aAdd(oOrdServ:aWmsAviso,aResOk[nI])
		Next nI
		aAdd(oOrdServ:aWmsAviso,"")
	EndIf
	// Aviso
	oOrdServ:ShowWarnig()
Return lRet
//--------------------------------------------------------------------
/*/{Protheus.doc} CalcEstoq
Valida se há estoque disponível para atender a requisição

@author SQUAD WMS Logistica
@since 21/07/2017
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function CalcEstoq(cLocOri,cEndOri,nQuant,nQtdSol)
Local aTamSX3   := {}
Local cQuery    := ""
Local cAliasQr2 := ""
Local nSldWMS   := 0
Local nDifSol   := IIf(QtdComp(nQuant)<QtdComp(nQtdSol),nQtdSol - nQuant,0)

Default cLocOri  := ""
Default cEndOri  := ""
Default nQuant   := 0
	// Atribui dados endereço origem
	If !oEstEnder:oProdLote:HasRastro() .Or. (oEstEnder:oProdLote:HasRastro() .And. !Empty(oEstEnder:oProdLote:GetLoteCtl()))
		oEstEnder:oEndereco:SetArmazem(cLocOri)
		oEstEnder:oEndereco:SetEnder(cEndOri)
		oEstEnder:SetProducao(.F.)
		// Busca saldo produto no endereço WMS quando informado
		// Senão o saldo do produto no WMS
		nSldWMS := oEstEnder:ConsultSld(.F.,.T.,.T.,.T.)
	Else
		cQuery := "SELECT SUM(SB8.B8_SALDO - SB8.B8_EMPENHO) B8_SALDO"
		cQuery +=  " FROM "+RetSqlName("SB8")+ " SB8"
		cQuery += " WHERE SB8.B8_FILIAL = '"+xFilial("SB8")+"'"
		cQuery +=   " AND SB8.B8_LOCAL = '"+cLocOri+"'"
		cQuery +=   " AND SB8.B8_PRODUTO = '"+oEstEnder:oProdLote:GetProduto()+"'"
		cQuery +=   " AND SB8.D_E_L_E_T_ = ' '"
		cQuery += " GROUP BY SB8.B8_LOCAL,"
		cQuery +=          " SB8.B8_PRODUTO"
		cQuery := ChangeQuery(cQuery)
		cAliasQr2 := GetNextAlias()
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQr2,.F.,.T.)
		aTamSX3 := TamSX3("B8_SALDO")
		TcSetField(cAliasQr2,'B8_SALDO','N',aTamSX3[1],aTamSX3[2])
		If QtdComp((cAliasQr2)->B8_SALDO) >= QtdComp(nQuant)
			oEstEnder:oEndereco:SetArmazem(cLocOri)
			oEstEnder:oEndereco:SetEnder(cEndOri)
			oEstEnder:SetProducao(.F.)
			// Busca saldo produto no endereço WMS quando informado
			// Senão o saldo do produto no WMS
			nSldWMS := oEstEnder:ConsultSld(.F.,.T.,.T.,.T.)
		Else
			nSldWMS := (cAliasQr2)->B8_SALDO
		EndIf
	EndIf
	// Saldo WMS:
	// Quando produto controla lote e o lote estiver informado considera o saldo no WMS
	// Quando produto controla lote e o lote não estiver informado considera o empenho menos o saldo dos lotes
	// Estoque considera saldo WMS  >= empenho requisição + diferença à solicitar	
Return (QtdComp(nSldWMS) >= QtdComp(nQuant + nDifSol))
#INCLUDE "WMSA332.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE WMSA33201 "WMSA33201"
#DEFINE WMSA33202 "WMSA33202"
#DEFINE WMSA33203 "WMSA33203"
#DEFINE WMSA33204 "WMSA33204"
#DEFINE WMSA33205 "WMSA33205"
#DEFINE WMSA33206 "WMSA33206"
#DEFINE WMSA33207 "WMSA33207"
#DEFINE WMSA33208 "WMSA33208"
#DEFINE WMSA33209 "WMSA33209"
#DEFINE WMSA33210 "WMSA33210"
#DEFINE WMSA33211 "WMSA33211"
#DEFINE WMSA33212 "WMSA33212"
#DEFINE WMSA33213 "WMSA33213"
#DEFINE WMSA33214 "WMSA33214"
#DEFINE WMSA33215 "WMSA33215"
#DEFINE WMSA33216 "WMSA33216"
#DEFINE WMSA33217 "WMSA33217"
#DEFINE WMSA33218 "WMSA33218"
#DEFINE WMSA33219 "WMSA33219"
#DEFINE WMSA33220 "WMSA33220"
#DEFINE WMSA33221 "WMSA33221"
#DEFINE WMSA33222 "WMSA33222"
#DEFINE WMSA33223 "WMSA33223"
#DEFINE WMSA33224 "WMSA33224"
#DEFINE WMSA33225 "WMSA33225"
#DEFINE WMSA33226 "WMSA33226"
#DEFINE WMSA33227 "WMSA33227"
#DEFINE WMSA33228 "WMSA33228"
#DEFINE WMSA33229 "WMSA33229"
#DEFINE WMSA33230 "WMSA33230"
#DEFINE WMSA33231 "WMSA33231"
#DEFINE WMSA33232 "WMSA33232"
#DEFINE WMSA33233 "WMSA33233"
#DEFINE WMSA33234 "WMSA33234"

Static __bKeyF5   := Nil
Static __bKeyF9   := Nil
Static __bKeyF10  := Nil
Static __nRefresh := 4
Static __lRefresh := .F.
Static oMovimento := WMSBCCMovimentoServico():New()
Static lAutomato  := IsBlind()

//-------------------------------------------------------------------
/*/{Protheus.doc} WMSA332
Monitor de Serviço

@author Felipe Machado de Oliveira
@since 22/01/2014
@version P12
/*/
//-------------------------------------------------------------------
Function WMSA332()
Local nSeconds    := SuperGetMV('MV_WMSREFS', .F., 10 ) // Tempo em Segundos para Refresh da tela (Default = 10 segundos)
Private oBrowse     := Nil
Private aMensagem    := {}
	If !SuperGetMV("MV_WMSNEW", .F., .F.)
		Return WMSA331()
	EndIf
	If Pergunte('WMSA332', .T.)
		__nRefresh:= mv_par16 // Salva parametros do Pergunte

		__bKeyF5  := {|| RefreshBrw()}
		__bKeyF9  := {|| SaldoEnder(.T.)}
		__bKeyF10 := {|| HistLog()}

		D12->(dbSetOrder(1))

		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias('D12')
		oBrowse:SetDescription(STR0001) // Monitor de Serviços
		oBrowse:DisableDetails()
		oBrowse:SetWalkThru(.F.)
		oBrowse:SetAmbiente(.F.)

		oBrowse:SetFixedBrowse(.T.)
		oBrowse:SetFilterDefault("@"+MontFiltro())
		oBrowse:SetMenuDef("WMSA332")   // Nome do fonte onde esta a função MenuDef
		oBrowse:AddLegend( "D12_STATUS=='0'"                                 ,"WHITE" ,STR0094 )  // Estornado
		oBrowse:AddLegend( "D12_STATUS=='1'"                                 ,"GREEN" ,STR0020 )  // Executada
		oBrowse:AddLegend( "D12_STATUS=='2' .AND. D12_LOG == '2'"            ,"RED"   ,STR0021 )  // Interropida
		oBrowse:AddLegend( "D12_STATUS=='2' .AND. D12_LOG == '1'"            ,"ORANGE",STR0117 ) // Pendente Análise
		oBrowse:AddLegend( "D12_STATUS=='3' .AND. D12_QTDLID == D12_QTDMOV"  ,"VIOLET",STR0118 )  // Realizada
		oBrowse:AddLegend( "D12_STATUS=='3' .AND. D12_QTDLID <> D12_QTDMOV"  ,"YELLOW",STR0022 )  // Em Execução
		oBrowse:AddLegend( "D12_STATUS=='4'"                                 ,"BLUE"  ,STR0023 )  // A Executar
		oBrowse:AddLegend( "D12_STATUS=='-'"                                 ,"BLACK" ,STR0099 )  // Regra Convocação Pendente
		oBrowse:SetParam({|| SelFiltro() })
		oBrowse:SetTimer({|| RefreshBrw() }, Iif(nSeconds<=0, 3600, nSeconds) * 1000)
		oBrowse:SetIniWindow({||oBrowse:oTimer:lActive := (__nRefresh < 4)})

		SetKey(VK_F5 , __bKeyF5)
		SetKey(VK_F9,  __bKeyF9)
		SetKey(VK_F10, __bKeyF10)
		//Ponto de entrada utilizado para manipular oBrowse da rotina
		If ExistBlock("WM332BRW")
			ExecBlock("WM332BRW",.F.,.F.)
		EndIf
		oBrowse:Activate()

	EndIf
	SetKey(VK_F5 , Nil)
	SetKey(VK_F9 , Nil)
	SetKey(VK_F10, Nil)
Return Nil
/*--------------------------------------------------------------------------------
---MenuDef
---MenuDef
---Alexsander.Correa - 01/04/2015
----------------------------------------------------------------------------------*/
Static Function MenuDef()
Local aRotina1 := { { STR0006 , "StaticCall(WMSA332,Bloquear,'1')",2,0 },;  // Bloquear Atividade
					{ STR0061 , "StaticCall(WMSA332,Bloquear,'2')",2,0 },;  // Bloquear Tarefa
					{ STR0062 , "StaticCall(WMSA332,Bloquear,'3')",2,0 } }  // Bloquear Docto/Carga

Local aRotina2 := { { STR0004 , "StaticCall(WMSA332,Reiniciar,'1')",2,0 },; // Reiniciar Atividade
					{ STR0009 , "StaticCall(WMSA332,Reiniciar,'2')",2,0 },; // Reiniciar Tarefa
					{ STR0008 , "StaticCall(WMSA332,Reiniciar,'3')",2,0 } } // Reiniciar Docto/Carga

Local aRotina3 := { { STR0011 , "StaticCall(WMSA332,Estornar,'1')",2,0 },;  // Estornar Servico
					{ STR0058 , "StaticCall(WMSA332,Estornar,'2')",2,0 } }  // Estornar Docto/Carga
					
Local aRotina4 := { { STR0073 , "StaticCall(WMSA332,Finalizar,'1')",2,0 },; // Finalizar Atividade
					{ STR0074 , "StaticCall(WMSA332,Finalizar,'2')",2,0 },; // Finalizar Tarefa
					{ STR0075 , "StaticCall(WMSA332,Finalizar,'3')",2,0 },; // Finalizar Docto/Carga
					{ STR0128 , "StaticCall(WMSA332,Finalizar,'4')",2,0 } } // Finalizar Qtde a Menor

Local aRotina5 := {{ STR0085 , "StaticCall(WMSA332,Reprocess,'1')",2,0 },; // Reprocessar Documento
{ STR0086 , "StaticCall(WMSA332,Reprocess,'2')",2,0 } } // Reprocessar Todos

Private aRotina := {}

	Add OPTION aRotina TITLE STR0109 ACTION "AxPesqui"                              OPERATION 1 ACCESS 0 DISABLE MENU // Pesquisar
	Add OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.WMSA332"                       OPERATION 2 ACCESS 0 DISABLE MENU // Visualizar
	Add OPTION aRotina TITLE STR0007 ACTION "StaticCall(WMSA332,ImprimAtiv)"        OPERATION 2 ACCESS 0 DISABLE MENU // Imprimir Atividade
	Add OPTION aRotina TITLE STR0005 ACTION aRotina1                                OPERATION 2 ACCESS 0 DISABLE MENU // Bloquear
	Add OPTION aRotina TITLE STR0003 ACTION aRotina2                                OPERATION 2 ACCESS 0 DISABLE MENU // Reiniciar
	Add OPTION aRotina TITLE STR0010 ACTION aRotina3                                OPERATION 2 ACCESS 0 DISABLE MENU // Estornar
	Add OPTION aRotina TITLE STR0079 ACTION aRotina4                                OPERATION 2 ACCESS 0 DISABLE MENU // Finalizar
	Add OPTION aRotina TITLE STR0084 ACTION aRotina5                                OPERATION 2 ACCESS 0 DISABLE MENU // Reprocessar Regra
	Add OPTION aRotina TITLE STR0012 ACTION "StaticCall(WMSA332,UpdPriori)"         OPERATION 4 ACCESS 0 DISABLE MENU // Alterar Prioridade
	Add OPTION aRotina TITLE STR0013 ACTION "StaticCall(WMSA332,RecHumano)"         OPERATION 4 ACCESS 0 DISABLE MENU // Recurso Humano
	Add OPTION aRotina TITLE STR0063 ACTION "CBMonRF()"                             OPERATION 2 ACCESS 0 DISABLE MENU // Monitor
	Add OPTION aRotina TITLE STR0064 ACTION "StaticCall(WMSA332,Mensagem)"          OPERATION 2 ACCESS 0 DISABLE MENU // Mensagem
	Add OPTION aRotina TITLE STR0014 ACTION "StaticCall(WMSA332,SelFiltro)"         OPERATION 3 ACCESS 0 DISABLE MENU // Selecionar
	Add OPTION aRotina TITLE STR0100 ACTION "StaticCall(WMSA332,Inventario)"        OPERATION 3 ACCESS 0 DISABLE MENU // Gerar Inventario
	Add OPTION aRotina TITLE STR0129 ACTION "StaticCall(WMSA332,AlterEnder)"        OPERATION 4 ACCESS 0 DISABLE MENU // Alterar Movimento
	Add OPTION aRotina TITLE STR0119 ACTION "StaticCall(WMSA332,ValidaMov)"         OPERATION 2 ACCESS 0 DISABLE MENU // "Analisar Pendência"

	// Ponto de entrada utilizado para manipular as opções do array aRotina
	If ExistBlock("WMSA332M")
	ExecBlock("WMSA332M",.F.,.F.)
	EndIf
Return aRotina
/*--------------------------------------------------------------------------------
---ModelDef
---ModelDef
---Alexsander.Correa - 01/04/2015
----------------------------------------------------------------------------------*/
Static Function ModelDef()
Local oStruD12 := FWFormStruct(1,'D12',/*bAvalCampo*/,/*lViewUsado*/)
Local oStruDCR := FWFormStruct(1,'DCR',/*bAvalCampo*/,/*lViewUsado*/)
Local oModel   := MPFormModel():New('WMSA332',/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/)
Local aColsSX3 := {}

	buscarSX3('DCF_CARGA',,aColsSX3)
	oStruDCR:AddField( aColsSX3[1],aColsSX3[1],'DCR_VCARGA','C',aColsSX3[3],aColsSX3[4],NIL,NIL,NIL,NIL,NIL,NIL,.F.,.T. )
	buscarSX3('DCF_DOCTO',,aColsSX3)
	oStruDCR:AddField( aColsSX3[1],aColsSX3[1],'DCR_VDOCTO','C',aColsSX3[3],aColsSX3[4],NIL,NIL,NIL,NIL,NIL,NIL,.F.,.T. )
	buscarSX3('DCF_SERIE',,aColsSX3)
	oStruDCR:AddField( aColsSX3[1],aColsSX3[1],'DCR_VSERIE','C',aColsSX3[3],aColsSX3[4],NIL,NIL,NIL,NIL,NIL,NIL,.F.,.T. )
	buscarSX3('DCF_CLIFOR',,aColsSX3)
	oStruDCR:AddField( aColsSX3[1],aColsSX3[1],'DCR_VCLIFO','C',aColsSX3[3],aColsSX3[4],NIL,NIL,NIL,NIL,NIL,NIL,.F.,.T. )
	buscarSX3('DCF_LOJA',,aColsSX3)
	oStruDCR:AddField( aColsSX3[1],aColsSX3[1],'DCR_VLOJA' ,'C',aColsSX3[3],aColsSX3[4],NIL,NIL,NIL,NIL,NIL,NIL,.F.,.T. )

	oModel:AddFields('D12MASTER',/*cOwner*/,oStruD12 )
	oModel:GetModel('D12MASTER'):SetDescription( STR0001 ) // Monitor de Serviços
	oModel:SetPrimaryKey( {"D12_FILIAL","D12_STATUS","D12_PRIORI","D12_CARGA","D12_DOC","D12_SERIE","D12_CLIFOR","D12_LOJA","D12_SERVIC","D12_ORDTAR","D12_ORDATI"} )

	oModel:AddGrid("DCRGRID","D12MASTER",oStruDCR,,,,,{|oModelGrid| LoadGrid(oModelGrid) })
Return oModel
/*--------------------------------------------------------------------------------
---ViewDef
---ViewDef
---Alexsander.Correa - 01/04/2015
----------------------------------------------------------------------------------*/
Static Function ViewDef()
Local oStruD12 := FWFormStruct( 2, 'D12' )
Local oStruDCR := FWFormStruct( 2, 'DCR' )
Local oModel   := FWLoadModel( 'WMSA332' )
Local oView    := FWFormView():New()
Local aColsSX3 := {}

	oView:SetModel( oModel )

	buscarSX3('DCF_CARGA',,aColsSX3)
	oStruDCR:AddField( 'DCR_VCARGA','01',aColsSX3[1],aColsSX3[1],NIL,'C',aColsSX3[2],NIL,'',.F.,NIL,NIL,NIL,NIL,NIL,.T.,NIL)
	buscarSX3('DCF_DOCTO',,aColsSX3)
	oStruDCR:AddField( 'DCR_VDOCTO','02',aColsSX3[1],aColsSX3[1],NIL,'C',aColsSX3[2],NIL,'',.F.,NIL,NIL,NIL,NIL,NIL,.T.,NIL)
	buscarSX3('DCF_SERIE',,aColsSX3)
	oStruDCR:AddField( 'DCR_VSERIE','03',aColsSX3[1],aColsSX3[1],NIL,'C',aColsSX3[2],NIL,'',.F.,NIL,NIL,NIL,NIL,NIL,.T.,NIL)
	buscarSX3('DCF_CLIFOR',,aColsSX3)
	oStruDCR:AddField( 'DCR_VCLIFO','04',aColsSX3[1],aColsSX3[1],NIL,'C',aColsSX3[2],NIL,'',.F.,NIL,NIL,NIL,NIL,NIL,.T.,NIL)
	buscarSX3('DCF_LOJA',,aColsSX3)
	oStruDCR:AddField( 'DCR_VLOJA' ,'05',aColsSX3[1],aColsSX3[1],NIL,'C',aColsSX3[2],NIL,'',.F.,NIL,NIL,NIL,NIL,NIL,.T.,NIL)

	oStruDCR:SetProperty('DCR_IDORI'  ,MVC_VIEW_ORDEM,'06')
	oStruDCR:SetProperty('DCR_IDDCF'  ,MVC_VIEW_ORDEM,'07')
	oStruDCR:SetProperty('DCR_IDMOV'  ,MVC_VIEW_ORDEM,'08')
	oStruDCR:SetProperty('DCR_IDOPER' ,MVC_VIEW_ORDEM,'09')
	oStruDCR:SetProperty('DCR_QUANT'  ,MVC_VIEW_ORDEM,'10')
	oStruDCR:SetProperty('DCR_QTSEUM' ,MVC_VIEW_ORDEM,'11')
	oStruDCR:SetProperty('DCR_SEQUEN' ,MVC_VIEW_ORDEM,'12')

	oView:CreateHorizontalBox('UP'  , 60,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
	oView:CreateHorizontalBox('DOWN', 40,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )

	oView:AddField("D12VIEW", oStruD12, "D12MASTER" )
	oView:SetOwnerView('D12VIEW', 'UP')

	oView:AddGrid("DCRVIEW", oStruDCR, "DCRGRID")
	oView:EnableTitleView('DCRVIEW', STR0120) //"Detalhes do Movimento"
	oView:SetOwnerView("DCRVIEW", "DOWN")
Return oView
/*--------------------------------------------------------------------------------
---LoadGrid
---Carrega o modelo de dados
---Felipe Machado de Oliveira - 12/02/2016
----------------------------------------------------------------------------------*/
Static Function LoadGrid(oModelGrid)
Local oStructDCR := oModelGrid:GetStruct()
Local aCamposDCR := aClone(oStructDCR:GetFields())
Local cQuery := ""
Local cAliasQry := GetNextAlias()
Local aLinhas := {}
Local nX := 0
Local nReg := 0

	cQuery := "SELECT DCR.DCR_FILIAL,"
	cQuery +=       " DCR.DCR_IDORI,"
	cQuery +=       " DCR.DCR_IDDCF,"
	cQuery +=       " DCR.DCR_IDMOV,"
	cQuery +=       " DCR.DCR_IDOPER,"
	cQuery +=       " DCR.DCR_QUANT,"
	cQuery +=       " DCR.DCR_QTSEUM,"
	cQuery +=       " DCR.DCR_SEQUEN,"
	cQuery +=       " DCF.DCF_CARGA DCR_VCARGA,"
	cQuery +=       " DCF.DCF_DOCTO DCR_VDOCTO,"
	cQuery +=       " DCF.DCF_SERIE DCR_VSERIE,"
	cQuery +=       " DCF.DCF_CLIFOR DCR_VCLIFO,"
	cQuery +=       " DCF.DCF_LOJA DCR_VLOJA,"
	cQuery +=       " DCR.R_E_C_N_O_ DCR_RECNO"
	cQuery +=  " FROM "+RetSqlName("DCR")+" DCR"
	cQuery += " INNER JOIN "+RetSqlName("DCF")+" DCF"
	cQuery +=    " ON DCF.DCF_FILIAL = '"+xFilial("DCF")+"'"
	cQuery +=   " AND DCF.DCF_ID = DCR.DCR_IDDCF"
	cQuery +=   " AND DCF.D_E_L_E_T_ = ' '"
	cQuery += " WHERE DCR.DCR_FILIAL = '"+xFilial("DCR")+"'"
	cQuery +=   " AND DCR.DCR_IDMOV = '"+D12->D12_IDMOV+"'"
	cQuery +=   " AND DCR.DCR_IDOPER = '"+D12->D12_IDOPER+"'"
	cQuery +=   " AND DCR.DCR_IDORI = '"+D12->D12_IDDCF+"'"
	cQuery +=   " AND DCR.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .T., .T. )
	If (cAliasQry)->(Eof())
		aAdd(aLinhas,{++nReg,Array(Len(aCamposDCR))})
	Else
		Do While !(cAliasQry)->(Eof())

			aAdd(aLinhas,{++nReg,Array(Len(aCamposDCR))})

			For nX := 1 To Len(aCamposDCR)
				aLinhas[nReg][2][nX] := (cAliasQry)->&(aCamposDCR[nX][MODEL_FIELD_IDFIELD])
			Next nX

			(cAliasQry)->(dbSkip())
		EndDo
	EndIf
	(cAliasQry)->(dbCloseArea())
Return aLinhas
/*--------------------------------------------------------------------------------
---MontFiltro
---Filtra arq.de movimentos de distribuicao conforme parametros
---Alexsander.Correa - 01/04/2015
----------------------------------------------------------------------------------*/
Static Function MontFiltro()
Local cQuery   := ""
Local cQueryPE := ""
	cQuery := " D12_FILIAL = '"+xFilial("D12")+"'"
	If !(Empty(mv_par01) .And. Upper(mv_par02) == Replicate('Z', Len(mv_par02)))
		cQuery += " AND D12_SERVIC >= '"+mv_par01+"'"
		cQuery += " AND D12_SERVIC <= '"+mv_par02+"'"
	EndIf
	If !(Empty(mv_par03) .And. DtoS(mv_par04) == '20491231')
		cQuery += " AND D12_DTGERA >= '"+DToS(mv_par03)+"'"
		cQuery += " AND D12_DTGERA <= '"+DToS(mv_par04)+"'"
	EndIf

	If !(Empty(mv_par05) .And. Upper(mv_par06) == Replicate('Z', Len(mv_par06)))
		cQuery += " AND D12_CARGA >= '"+mv_par05+"'"
		cQuery += " AND D12_CARGA <= '"+mv_par06+"'"
	EndIf

	If !(Empty(mv_par07) .And. Upper(mv_par08) == Replicate('Z', Len(mv_par08)))
		cQuery += " AND D12_CODREC >= '"+mv_par07+"'"
		cQuery += " AND D12_CODREC <= '"+mv_par08+"'"
	EndIf
	If !(Empty(mv_par09) .And. Upper(mv_par10) == Replicate('Z', Len(mv_par10)))
		cQuery += " AND D12_DOC >= '"+mv_par09+"'"
		cQuery += " AND D12_DOC <= '"+mv_par10+"'"
	EndIf
	If !(Empty(mv_par11) .And. Upper(mv_par12) == Replicate('Z', Len(mv_par12)))
		cQuery += " AND D12_LOCORI >= '"+mv_par11+"'"
		cQuery += " AND D12_LOCORI <= '"+mv_par12+"'"
	EndIf
	If !(Empty(mv_par13) .And. Upper(mv_par14) == Replicate('Z', Len(mv_par14)))
		cQuery += " AND D12_PRODUT >= '"+mv_par13+"'"
		cQuery += " AND D12_PRODUT <= '"+mv_par14+"'"
	EndIf

	If mv_par15 == 2
		cQuery += " AND NOT D12_STATUS IN ('0','1')"
	EndIf
	If !(Empty(mv_par18) .And. Upper(mv_par19) == Replicate('Z', Len(mv_par19)))
		cQuery += " AND D12_CLIFOR >= '"+mv_par18+"'"
		cQuery += " AND D12_CLIFOR <= '"+mv_par19+"'"
	EndIF
	If !(Empty(mv_par20) .And. Upper(mv_par21) == Replicate('Z', Len(mv_par21)))
		cQuery += " AND D12_LOJA >= '"+mv_par20+"'"
		cQuery += " AND D12_LOJA <= '"+mv_par21+"'"
	EndIf
	If !Empty(mv_par22)
		cQuery += "AND D12_MAPSEP = '"+mv_par22+"'"
	EndIf
	cQuery += " AND D_E_L_E_T_ = ' '"
	// Ponto de Entrada WM330QRY para a alteracao da Query
	If ExistBlock('WM330QRY')
		If ValType(cQueryPE := ExecBlock('WM330QRY',.F.,.F.)) == 'C'
			cQuery += cQueryPE
		EndIf
	EndIf
Return cQuery
/*--------------------------------------------------------------------------------
---SelFiltro
---Seleciona um Novo Filtro ao Browse
---Alexsander.Correa - 01/04/2015
----------------------------------------------------------------------------------*/
Static Function SelFiltro()
	// Desativa teclas de atalho
	__bKeyF5  := SetKey(VK_F5 , Nil)
	__bKeyF9  := SetKey(VK_F9 , Nil)
	__bKeyF10 := SetKey(VK_F10, Nil)

	lRet := Pergunte('WMSA332', .T.)
	If lRet
	__nRefresh := mv_par16
		oBrowse:oTimer:lActive := (__nRefresh < 4)
		// Selecionar atividades conforme a parametrizacao do usuario.
		oBrowse:SetFilterDefault("@"+MontFiltro())
		oBrowse:Refresh()
	EndIf
	// Reativa teclas de atalho
	SetKey(VK_F5 , __bKeyF5)
	SetKey(VK_F9 , __bKeyF9)
	SetKey(VK_F10, __bKeyF10)
Return lRet
/*--------------------------------------------------------------------------------
---RefreshBrw
---Refaz o setFilterDefault do Browse, para atualização
---Alexsander.Correa - 01/04/2015
----------------------------------------------------------------------------------*/
Static Function RefreshBrw()
Local nPos := oBrowse:At()
	D12->(dbSetOrder(1))
	If __nRefresh == 1
		oBrowse:Refresh(.T.)
	ElseIf __nRefresh == 2
		oBrowse:Refresh(.F.)
		oBrowse:GoBottom()
	Else
		oBrowse:Refresh(.F.)
		oBrowse:GoTo(nPos)
	EndIf
Return .T.
/*--------------------------------------------------------------------------------
---TeclaAtalho
---Ativa/Desativa teclas de atalho e Refresh do Browse
---Alexsander.Correa - 01/04/2015
----------------------------------------------------------------------------------*/
Static Function TeclaAtalho(lAtiva)
	If !lAtiva
		__bKeyF5   := SetKey(VK_F5 , Nil)
		__bKeyF9   := SetKey(VK_F9 , Nil)
		__bKeyF10  := SetKey(VK_F10, Nil)
		If oBrowse:oTimer <> Nil
			__lRefresh := oBrowse:oTimer:lActive // Salva o status do timer
			// Desliga o Refresh automatico para nao desposicionar o cursor
			oBrowse:oTimer:lActive := .F.
		EndIf
	Else
		// Reativa as teclas de atalho
		SetKey(VK_F5 , __bKeyF5)
		SetKey(VK_F9 , __bKeyF9)
		SetKey(VK_F10, __bKeyF10)
		If oBrowse:oTimer <> Nil
			// Retorna o status do timer do browse
			oBrowse:oTimer:lActive := __lRefresh
		EndIf
	EndIf
Return Nil
/*--------------------------------------------------------------------------------
---Reiniciar
---Reinicia atividade que está pendente de execução.
---Alexsander.Correa - 01/04/2015
---cAcao, Caracter, "1" - Atividade
---                 "2" - Tarefa
---                 "3" - Carga/Doc
----------------------------------------------------------------------------------*/
Static Function Reiniciar(cAcao)
Local aAreaAnt  := GetArea()
Local aAreaD12  := D12->(GetArea())
Local cQuery    := ""
Local cAliasD12 := ""
Local cMensagem := ""
Local lRet      := .T.
Local lMantemCnt:= .T.
	//Grava opções selecionadas
	WmsOpc332("2")
	WmsAcao332(cAcao)
	TeclaAtalho(.F.) // Desativa teclas de atalho
	If oMovimento:GoToD12(D12->(Recno()))
		If cAcao == '1'
			If oMovimento:GetStatus() $ "0|1" // Executada/Manual
				WmsMessage(STR0031,WMSA33201) // Não é possível reiniciar a atividade pois a mesma ja foi finalizada.
				lRet := .F.
			ElseIf oMovimento:GetStatus() == "4" // A Executar
				WmsMessage(STR0034,WMSA33203) // A atividade não necessita ser reiniciada.
				lRet := .F.
			EndIf
			If lRet .And. !lAutomato
				__lRecHum := (!Empty(oMovimento:GetRecHum()) .And. WmsQuestion(STR0026)) // O Recurso Humano deve ser mantido?
				__lQtdConf   := (oMovimento:oMovServic:ChkConfer() .And. WmsQuestion(STR0036)) // Quantidade conferida deverá ser mantida?
			EndIf
		Else
			// Monta Query
			cQuery := MontaQuery(cAcao)
			cAliasD12 := GetNextAlias()
			dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasD12,.F.,.T.)
			If (cAliasD12)->(Eof())
				lRet := .F.
				If cAcao == "2"
					WmsMessage(STR0097,WMSA33224) // Tarefa não possui atividades a serem reiniciadas!
				ElseIf cAcao == "3"
					WmsMessage(STR0098,WMSA33225) // Carga/Documento não possui atividades a serem reiniciadas!
				EndIf
			EndIf
			If lRet .And. !lAutomato
				If (cAliasD12)->(!Eof())
					__lRecHum := WmsQuestion(STR0026) // O Recurso Humano deve ser mantido ?
				EndIf
				While (cAliasD12)->(!Eof())
					oMovimento:GoToD12((cAliasD12)->D12RECNO)
					If oMovimento:oMovServic:ChkConfer()
						lMantemCnt := WmsQuestion(STR0036) // Quantidade conferida deverá ser mantida?"
						Exit
					EndIf
					(cAliasD12)->(dbSkip())
				EndDo
				(cAliasD12)->(dbCloseArea())
			EndIf
			__lQtdConf := lMantemCnt
		EndIf
	EndIf
	If lRet
		aAreaAnt2 := GetArea()
		Processa( {|| ProcRegua(0), FWExecView(STR0082,"WMSA332A", MODEL_OPERATION_UPDATE ,, { || .T. } ,, ) } , STR0003+" "+IIf(cAcao=="1",STR0093,IIf(cAcao=="2",STR0092,STR0103)), STR0104 + '...', .F.) // Reiniciar //Atividade //Tarefa //Carga/Doc //Carregando tela de confirmação
		RestArea(aAreaAnt2)
	EndIf
	oMovimento:oOrdServ:aWmsAviso := aMensagem
	aMensagem    := {}
	// Exibe as mensages de erro nas movimentações
	// Aviso
	oMovimento:oOrdServ:ShowWarnig()

	TeclaAtalho(.T.)  // Reativa teclas de atalho
	oBrowse:Refresh() // Força Refresh
	RestArea(aAreaD12)
	RestArea(aAreaAnt)
Return lRet
/*--------------------------------------------------------------------------------
---Bloquear
---Bloqueia uma atividade que está pendente de execução.
---Alexsander.Correa - 01/04/2015
---cAcao, Caracter, "1" - Atividade
---                 "2" - Tarefa
---                 "3" - Carga/Doc
----------------------------------------------------------------------------------*/
Static Function Bloquear(cAcao)
Local aAreaAnt  := GetArea()
Local aAreaD12  := D12->(GetArea())
Local cQuery    := ""
Local cAliasD12 := ""
Local lRet      := .T.
	//Grava opções selecionadas
	WmsOpc332("1")
	WmsAcao332(cAcao)
	TeclaAtalho(.F.) // Desativa teclas de atalho
	If oMovimento:GoToD12(D12->(Recno()))
		If cAcao == '1'
			If oMovimento:GetStatus() $ '0|1'// Executa/Manual
				WmsMessage(STR0038,WMSA33205) // Não é possível bloquear a tarefa pois a mesma ja foi finalizada.
				lRet := .F.
			ElseIf oMovimento:GetStatus() == '2'
				WmsMessage(STR0030,WMSA33204) // A atividade não necessita ser bloqueada.
				lRet := .F.
			EndIf
		Else
			// Monta Query
			cQuery := MontaQuery(cAcao)
			cAliasD12 := GetNextAlias()
			dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasD12,.F.,.T.)
			If (cAliasD12)->(Eof())
				lRet := .F.
				If cAcao == "2"
					WmsMessage(STR0095,WMSA33224) // Tarefa não possui atividades a serem bloqueadas!
				ElseIf cAcao == "3"
					WmsMessage(STR0096,WMSA33225) // Carga/Documento não possui atividades a serem bloqueadas!
				EndIf
			EndIf
			(cAliasD12)->(dbCloseArea())
		EndIf
	EndIf
	If lRet
		aAreaAnt2 := GetArea()
		Processa( {|| ProcRegua(0), FWExecView(STR0082,"WMSA332A", MODEL_OPERATION_UPDATE ,, { || .T. } ,, ) } , STR0039+" "+IIf(cAcao=="1",STR0093,IIf(cAcao=="2",STR0092,STR0103)), STR0104 + '...', .F.) //Bloquear //Atividade //Tarefa //Carga/Doc  //Carregando tela de confirmação
		RestArea(aAreaAnt2)
	EndIf

	TeclaAtalho(.T.)  // Reativa teclas de atalho
	oBrowse:Refresh() // Força Refresh
	RestArea(aAreaD12)
	RestArea(aAreaAnt)
Return lRet

Static Function Estornar(cAcao)
	Processa( {|| ProcRegua(0), ProcEstorno(cAcao) } , STR0010+" "+IIf(cAcao=="1",STR0091,STR0103), STR0019+ '...', .F.) // Estornar //Serviço //Carga/Doc //Aguarde...
Return Nil
/*--------------------------------------------------------------------------------
---Estornar
---Estorna servicos.
---Alexsander.Correa - 01/04/2015
---cAcao, Caracter, "1" - Serviço
---                 "2" - Carga/Doc
----------------------------------------------------------------------------------*/
Function ProcEstorno(cAcao)
Local aAreaAnt  := GetArea()
Local aAreaD12  := D12->(GetArea())
Local aAreaDCF  := DCF->(GetArea())
Local cMensagem := ""
Local lRet      := .T.
Local cAliasNew := ""
Local cQuery    := ""
Local cDoctos   := ""
Local aDoctos   := {}
Local nPar16    := mv_par16
Local oOrdSerRev:= Nil
Local oOrdSerDel:= Nil
Local oOrdSerExe:= Nil
Local oRegraConv:= Nil
Local nX        := 0

Default cAcao   := '1'

	If !__lAutoma
	   TeclaAtalho(.F.) // Desativa teclas de atalho
	EndIf   
	If !oMovimento:GoToD12(D12->(Recno()))
		WmsMessage(STR0016+CRLF+STR0017,WMSA33216,1) // "Movimentação não encontrada para estorno."##"Pode ter sido excluída por outro processo."
		lRet := .F.
	EndIf
	
	If lRet .And. oMovimento:GetStatus() == '0'
		WmsMessage(STR0018,WMSA33216,1) // "Movimentação já estornada por outro processo."
		lRet := .F.
	EndIf
	
	If lRet
		If cAcao == '1'
			If oMovimento:GetStatus() == "1"  // Executada/Manual
				cMensagem := STR0041 // O serviço selecionado ja esta finalizado. Continuar com o Estorno?
			EndIf
			cMensagem := STR0042+CRLF // Estornar o servico selecionado?
			cMensagem += STR0091+": "+oMovimento:oMovServic:GetServico()+" - "+AllTrim(oMovimento:oMovServic:GetDesServ())+CRLF
			If oMovimento:IsMovUnit()
				cMensagem += AllTrim(RetTitle("D12_IDUNIT"))+": "+AllTrim(oMovimento:GetIdUnit())
			Else
				cMensagem += AllTrim(RetTitle("D12_PRODUT"))+": "+AllTrim(oMovimento:oMovPrdLot:GetProduto())
			EndIf
			If __lAutoma .OR. WmsQuestion(cMensagem)
				cQuery := "SELECT DISTINCT DCF.R_E_C_N_O_ RECNODCF,"
				cQuery +=       " DCF.DCF_DOCTO,"
				cQuery +=       " DCF.DCF_SERIE,"
				cQuery +=       " DCF.DCF_CLIFOR,"
				cQuery +=       " DCF.DCF_LOJA,"
				cQuery +=       " DCF.DCF_ID"
				cQuery +=  " FROM "+RetSqlName('DCF')+" DCF, "+RetSqlName('DCR')+" DCR"
				cQuery += " WHERE DCF.DCF_FILIAL = '"+xFilial("DCF")+"'"
				cQuery +=   " AND DCF.DCF_SERVIC = '"+oMovimento:oMovServic:GetServico()+"'"
				If !oMovimento:IsMovUnit()
					cQuery += " AND DCF.DCF_CODPRO = '"+oMovimento:oOrdServ:oProdLote:GetProduto()+"'"
				Else
					cQuery += " AND DCF.DCF_UNITIZ = '"+oMovimento:GetIdUnit()+"'"
				EndIf
				cQuery +=   " AND DCF.DCF_STSERV IN ('2','3')"
				cQuery +=   " AND DCF.D_E_L_E_T_ = ' '"
				cQuery +=   " AND DCR.DCR_FILIAL = '"+xFilial("DCR")+"'"
				cQuery +=   " AND DCR.DCR_IDMOV = '"+oMovimento:GetIdMovto()+"'"
				cQuery +=   " AND DCR.DCR_IDOPER = '"+oMovimento:GetIdOpera()+"'"
				cQuery +=   " AND DCR.DCR_IDORI  = '"+oMovimento:oOrdServ:GetIdDCF()+"'"
				cQuery +=   " AND DCR.DCR_IDDCF  = DCF.DCF_ID"
				cQuery +=   " AND DCR.DCR_SEQUEN = DCF.DCF_SEQUEN"
				cQuery +=   " AND DCR.D_E_L_E_T_ = ' '"
			Else
				lRet := .F.
			EndIf
		ElseIf cAcao == '2'
			cMensagem := STR0015+CRLF // Estornar o serviço do documento selecionado?
			cMensagem += STR0091+": "+oMovimento:oMovServic:GetServico()+" - "+AllTrim(oMovimento:oMovServic:GetDesServ())+CRLF
			cMensagem += STR0045+AllTrim(oMovimento:oOrdServ:GetDocto())+Iif(oMovimento:oOrdServ:GetOrigem() <> "SC9",Iif(!Empty(oMovimento:oOrdServ:GetSerie())," / "+oMovimento:oOrdServ:GetSerie(),""),"")
			If __lAutoma .OR. WmsQuestion(cMensagem)
				cAliasNew := GetNextAlias()
				cQuery := "SELECT DISTINCT DCF2.R_E_C_N_O_ RECNODCF,"
				cQuery +=                " DCF2.DCF_DOCTO,"
				cQuery += Iif(oMovimento:oOrdServ:GetOrigem()=="SC9","'"+Space(TamSx3("DCF_SERIE")[1])+"' DCF_SERIE,","DCF2.DCF_SERIE,")
				cQuery +=                " DCF2.DCF_CLIFOR,"
				cQuery +=                " DCF2.DCF_LOJA,"
				cQuery +=                " DCF2.DCF_ID"
				cQuery +=  " FROM "+RetSqlName('DCR')+" DCR1, "+RetSqlName('DCF')+" DCF1, "+RetSqlName('DCF')+" DCF2"
				cQuery += " WHERE DCR1.DCR_FILIAL = '"+xFilial("DCR")+"'"
				cQuery +=   " AND DCR1.DCR_IDMOV  = '"+oMovimento:GetIdMovto()+"'"
				cQuery +=   " AND DCR1.DCR_IDOPER = '"+oMovimento:GetIdOpera()+"'"
				cQuery +=   " AND DCR1.DCR_IDORI  = '"+oMovimento:oOrdServ:GetIdDCF()+"'"
				cQuery +=   " AND DCR1.D_E_L_E_T_ = ' '"
				cQuery +=   " AND DCF1.DCF_FILIAL = '"+xFilial("DCF")+"'"
				cQuery +=   " AND DCF1.DCF_ID = DCR1.DCR_IDDCF"
				cQuery +=   " AND DCF1.DCF_STSERV IN ('2','3')"
				cQuery +=   " AND DCF1.D_E_L_E_T_ = ' '"
				cQuery +=   " AND DCF2.DCF_FILIAL = '"+xFilial("DCF")+"'"
				cQuery +=   " AND DCF2.DCF_SERVIC = DCF1.DCF_SERVIC"
				cQuery +=   " AND DCF2.DCF_SEQUEN = DCR1.DCR_SEQUEN"
				cQuery +=   " AND DCF2.DCF_STSERV IN ('2','3')"
				If WmsCarga(oMovimento:oOrdServ:GetCarga())
					cQuery += " AND DCF2.DCF_CARGA = DCF1.DCF_CARGA"
				Else
					cQuery += " AND DCF2.DCF_DOCTO = DCF1.DCF_DOCTO"
					If oMovimento:oOrdServ:GetOrigem() != "SC9"
						cQuery += " AND DCF2.DCF_SERIE = DCF1.DCF_SERIE"
					EndIf
					cQuery += " AND DCF2.DCF_CLIFOR = DCF1.DCF_CLIFOR"
					cQuery += " AND DCF2.DCF_LOJA = DCF1.DCF_LOJA"
				EndIf
				cQuery +=   " AND DCF2.D_E_L_E_T_ = ' '"
			Else
				lRet := .F.
			EndIf
		Else
			lRet := .F. // Ação não prevista
		EndIf
	EndIf
	
	If lRet
		//***********************************************//
		//*** VALIDAÇÃO DE AGLUTINAÇÃO NOS MOVIMENTOS ***//
		//***********************************************//
		cAliasNew := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.F.,.T.)
		If (cAliasNew)->( Eof() )
			WmsMessage(STR0043,WMSA33211,1) // O Estorno não será realizado pois o sistema não encontrou a execução de serviços. // Ok
			lRet := .F.
		Else
			cDoctos  := Iif(cAcao == '1',STR0070,STR0071) // Serviço/Documento aglutinado, será necessário estornar os seguintes
			cDoctos  += CRLF+Trim(RetTitle('DCF_DOCTO'))+" - "+Trim(RetTitle('DCF_SERIE'))+" - "+Trim(RetTitle('DCF_CLIFOR'))+" - "+Trim(RetTitle('DCF_LOJA'))+':'
			While (cAliasNew)->(!Eof())
				If (aScan(aDoctos , {|x| x[1]+x[2]+x[3]+x[4]==(cAliasNew)->DCF_DOCTO+(cAliasNew)->DCF_SERIE+(cAliasNew)->DCF_CLIFOR+(cAliasNew)->DCF_LOJA})) == 0
					aAdd(aDoctos,{(cAliasNew)->DCF_DOCTO,(cAliasNew)->DCF_SERIE,(cAliasNew)->DCF_CLIFOR,(cAliasNew)->DCF_LOJA})
					cDoctos += CRLF+(cAliasNew)->DCF_DOCTO+" - "+(cAliasNew)->DCF_SERIE+" - "+(cAliasNew)->DCF_CLIFOR+" - "+(cAliasNew)->DCF_LOJA
				EndIf
				(cAliasNew)->( DbSkip() )
			EndDo
			If Len(aDoctos) > 1 .And. !__lAutoma
				If !WmsQuestion(cDoctos)
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf

	If lRet
		//************************************************//
		//*** ESTORNO DAS ORDENS DE SERVIÇO PRINCIPAIS ***//
		//************************************************//
		
		// Criação das tabelas temporárias para validação do unitizador
		WMSCTPENDU()
		
		// Posiciona no primeiro registro selecionado
		(cAliasNew)->( DbGoTop() )
		Begin Transaction
			oOrdSerRev := WMSDTCOrdemServicoReverse():New()
			While lRet .And. (cAliasNew)->(!Eof())
				oOrdSerRev:GoToDCF((cAliasNew)->RECNODCF)
				// Verifica se ordem de serviço pode ser estornada
				oOrdSerRev:SetEstSerA(mv_par17 == 1) // Indica se as O.S originadas da O.S estorna devem ser estornadas automaticamente
				If (lRet := oOrdSerRev:CanReverse())
					If !(lRet := oOrdSerRev:ReverseDCF())
						Disarmtransaction()
					EndIf
				Else
					Disarmtransaction()
				EndIf
				(cAliasNew)->(dbSkip())
			EndDo
			(cAliasNew)->( dbCloseArea() )
		End Transaction

		//*************************************************//
		//*** EXCLUSÃO DAS ORDENS DE SERVIÇO AUXILIARES ***//
		//*************************************************//
		// Verifica se há ordens de serviço  de reabastecimento originados
		// das ordem de serviço estornadas para efetuar o estorno.
		If lRet .And. Len(oOrdSerRev:aOrdReab) > 0
			oOrdSerDel := WMSDTCOrdemServicoDelete():New()
			For nX := 1 To Len(oOrdSerRev:aOrdReab)
				Begin Transaction
					oOrdSerDel:SetIdDCF(oOrdSerRev:aOrdReab[nX])
					If oOrdSerDel:LoadData()
						// Somente os serviços que não forem transferencia de devolução
						// Se for reabastecimento com origem preenchida, é executado
						// automático independente da configuração do serviço utilizado.
						oOrdSerDel:oServico:SetTpExec("2")
						If oOrdSerDel:CanDelete()
							oOrdSerDel:DeleteDCF()
						Else
							oOrdSerDel:SetIdOrig("")
							oOrdSerDel:UpdateDCF()
							AAdd(oOrdSerRev:aWmsAviso, WmsFmtMsg(STR0127,{{"[VAR01]",oOrdSerDel:GetDocto()+Iif(!Empty(oOrdSerDel:GetSerie()),"/"+AllTrim(oOrdSerDel:GetSerie()),'')},{"[VAR02]",oOrdSerDel:oProdLote:GetProduto()}}) + CRLF +oOrdSerDel:GetErro()) // SIGAWMS - OS [VAR01] - Produto: [VAR02]
						EndIf
					EndIf
				End Transaction
			Next nX
		EndIf

		//***************************************************//
		//*** EXECUÇÃO DAS ORDENS DE SERVIÇO DE DEVOLUÇÃO ***//
		//***************************************************//
		// Verifica as Ordens de servico geradas para execução automatica
		If lRet .And. Len(oOrdSerRev:aLibDCF) > 0
			oOrdSerExe := WMSDTCOrdemServicoExecute():New()
			oRegraConv := WMSBCCRegraConvocacao():New()
			For nX := 1 To Len(oOrdSerRev:aLibDCF)
				oOrdSerExe:SetIdDCF(oOrdSerRev:aLibDCF[nX])
				If oOrdSerExe:LoadData()
					oOrdSerExe:SetArrLib(oRegraConv:GetArrLib())
					oOrdSerExe:ExecuteDCF()
				EndIf
			Next nX
			If !Empty(oRegraConv:GetArrLib())
				oRegraConv:LawExecute()
			EndIf
			// Copiando as mensagens de aviso da execução para o array do objeto atual
			If !Empty(oOrdSerExe:aWmsAviso)
				AEval(oOrdSerExe:aWmsAviso, {|x| AAdd(oOrdSerRev:aWmsAviso,x)})
			EndIf
		EndIf
		// Aviso
		oOrdSerRev:ShowWarnig()
		// Ponto de Entrada DL150AEX - Apos Execucao/Estorno O.S.WMS.
		If ExistBlock("WM330AEX")
			ExecBlock("WM330AEX", .F., .F., {cAcao})
		EndIf
		
		// Exclusão das tabelas temporárias
		WMSDTPENDU()
	EndIf

	IF !__lAutoma
		TeclaAtalho(.T.)  // Reativa teclas de atalho		
		oBrowse:Refresh() // Força Refresh
	EndIf	
	RestArea(aAreaDCF)
	RestArea(aAreaD12)
	RestArea(aAreaAnt)
Return( Nil )
/*--------------------------------------------------------------------------------
---Finalizar
---Permiti finalizar os serviços de movimentação sem utilizar o coletor
---ou estiver com problemas.
---Alexsander.Correa - 01/04/2015
---cAcao, Caracter, "1" - Atividade
---                 "2" - Tarefa
---                 "3" - Carga/Doc
----------------------------------------------------------------------------------*/
Static Function Finalizar(cAcao)
Local aAreaAnt  := GetArea()
Local aAreaD12  := D12->(GetArea())
Local cQuery    := ""
Local cAliasD12 := ""
Local cMensagem := ""
Local lRet      := .T.
Local aAreaAnt2 := {}
	//Grava opções selecionadas
	WmsOpc332("4")
	WmsAcao332(cAcao)
	TeclaAtalho(.F.) // Desativa teclas de atalho
	If oMovimento:GoToD12(D12->(Recno()))
		If	cAcao $ "1|4"
			If oMovimento:GetStatus() $ '0|1'// Executa/Manual
				WmsMessage(STR0076,WMSA33222) // Atividade não necessita ser finalizada!
				lRet := .F.
			EndIf
			If cAcao == "4" // Valida se quantidade a menor pode ser finalizada
				If !WmsVpaMov(oMovimento,.F.,oMovimento:GetQtdLid())
					WmsMessage(oMovimento:GetErro(),WMSA33234)
					lRet := .F.
				EndIf
			EndIf
		Else
			// Monta Query
			cQuery := MontaQuery(cAcao)
			cAliasD12 := GetNextAlias()
			dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasD12,.F.,.T.)
			If (cAliasD12)->(Eof())
				lRet := .F.
				If cAcao == "2"
					WmsMessage(STR0080,WMSA33224) // Tarefa não possui atividades a serem finalizadas!
				ElseIf cAcao == "3"
					WmsMessage(STR0081,WMSA33225) // Carga/Documento não possui atividades a serem finalizadas!
				EndIf
			EndIf
			(cAliasD12)->(dbCloseArea())
		EndIf
	EndIf
	If lRet
		aAreaAnt2 := GetArea()
		Processa( {|| ProcRegua(0), FWExecView(STR0082,"WMSA332A", MODEL_OPERATION_UPDATE ,, { || .T. } ,, ) } , STR0079+" "+IIf(cAcao $ "1|4",STR0093,IIf(cAcao=="2",STR0092,STR0103)), STR0104 + '...', .F.) //Finalizar //Atividade //Tarefa // Carga/Doc //Carregando tela de confirmação
		RestArea(aAreaAnt2)
	EndIf
	oMovimento:oOrdServ:aWmsAviso := aMensagem
	aMensagem    := {}
	// Exibe as mensages de erro nas movimentações
	// Aviso
	oMovimento:oOrdServ:ShowWarnig()

	TeclaAtalho(.T.)  // Reativa teclas de atalho
	oBrowse:Refresh() // Força Refresh
	RestArea(aAreaD12)
	RestArea(aAreaAnt)
Return (Nil)
/*--------------------------------------------------------------------------------
---ImprimAtiv
---Executa relatorio WMSR310 - Monitor de Servico
---Alexsander.Correa - 01/04/2015
----------------------------------------------------------------------------------*/
Static Function ImprimAtiv()
Local aArea      := GetArea()
	TeclaAtalho(.F.) // Desativa teclas de atalho
	WmsR310()        // Executa relat.Monitor de Servicos
	TeclaAtalho(.T.) // Reativa teclas de atalho

	RestArea(aArea)
Return( Nil )
/*--------------------------------------------------------------------------------
---UpdPriori
---Atualiza prioridade
---Alexsander.Correa - 01/04/2015
----------------------------------------------------------------------------------*/
Static Function UpdPriori()
Local aAreaAnt  := GetArea()
Local aAreaD12  := D12->(GetArea())
Local cAliasD12 := GetNextAlias()
Local cQuery    := ""
Local aOpcao    := {}
Local aParams   := {}
Local cOpcao    := ""
Local cGrvPri   := ""
Local lProduto  := .F.

	TeclaAtalho(.F.)  // Desativa teclas de atalho
	If oMovimento:GoToD12(D12->(Recno()))
		If oMovimento:GetStatus() != '0'
			If !Empty(oMovimento:oOrdServ:GetCarga())
				AAdd(aOpcao,STR0044+oMovimento:oOrdServ:GetCarga()) // Carga :
			Else
				AAdd(aOpcao,STR0045+oMovimento:oOrdServ:GetDocto()+' - '+oMovimento:oOrdServ:GetSerie()) // Documento :
			EndIf
			AAdd(aOpcao,STR0072+oMovimento:oMovPrdLot:GetProduto()) // Produto :
			AAdd(aParams,{3,STR0046,1,aOpcao,100,'',.F.}) // Prioriza
			AAdd(aParams,{1,STR0047,SubStr(oMovimento:GetPriori(),1,2),PesqPict('D12','D12_PRIORI'),'','','',10,.T.}) // Prioridade "
			If ParamBox(aParams,STR0047,,,,,,,,,.F.,.F.) // Prioridade
				cOpcao := Substr(aOpcao[mv_par01],1,1)
				If cOpcao == 'P'
					lProduto := .T.
					If !Empty(oMovimento:oOrdServ:GetCarga())
						cOpcao := 'C'
					Else
						cOpcao := 'D'
					EndIf
				EndIf
				cQuery := "SELECT D12.R_E_C_N_O_ RECNOD12"
				cQuery +=  " FROM "+RetSqlName('D12')+" D12"
				cQuery += " WHERE D12_FILIAL = '"+xFilial("D12")+"'"
				cQuery +=   " AND D12_STATUS IN ('2','4')"
				cQuery +=   " AND D12_SERVIC = '"+oMovimento:oMovServic:GetServico()+"'"
				If lProduto
					cQuery += "AND D12_PRODUT = '"+oMovimento:oMovPrdLot:GetProduto()+"'"
				EndIf
				If WmsCarga(oMovimento:oOrdServ:GetCarga())
					cQuery += " AND D12_CARGA = '"+oMovimento:oOrdServ:GetCarga()+"'"
				Else
					cQuery += " AND D12_DOC = '"+oMovimento:oOrdServ:GetDocto()+"'"
					If oMovimento:oOrdServ:GetOrigem() <> "SC9"
						cQuery += " AND D12_SERIE = '"+oMovimento:oOrdServ:GetSerie()+"'"
					EndIf
					cQuery += " AND D12_CLIFOR = '"+oMovimento:oOrdServ:GetCliFor()+"'"
					cQuery += " AND D12_LOJA = '"+oMovimento:oOrdServ:GetLoja()+"'"
				EndIf
				cQuery += " AND D12.D_E_L_E_T_ = ' '"
				cQuery += " ORDER BY RECNOD12"
				cQuery := ChangeQuery(cQuery)
				DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasD12,.F.,.T.)
				If (cAliasD12)->(Eof())
					WmsMessage(STR0113,WMSA33229) // Não existem atividades pendentes para o ajuste da prioridade!
				Else
					While (cAliasD12)->(!Eof())
						If oMovimento:GoToD12((cAliasD12)->RECNOD12)
							cGrvPri := AllTrim(Substr(mv_par02,1,2)) + Substr(oMovimento:GetPriori(),3,Len(oMovimento:GetPriori()))
							oMovimento:SetPriori(cGrvPri)
							oMovimento:UpdateD12()
						EndIf
						(cAliasD12)->(dbSkip())
					EndDo
				EndIf
				(cAliasD12)->(dbCloseArea())
			EndIf
		EndIf
	EndIf
	TeclaAtalho(.T.)  // Reativa teclas de atalho
	oBrowse:Refresh() // Força Refresh
	RestArea(aAreaD12)
	RestArea(aAreaAnt)
Return( Nil )
/*--------------------------------------------------------------------------------
---RecHumano
---Recurso Humano.
---Alexsander.Correa - 01/04/2015
----------------------------------------------------------------------------------*/
Static Function RecHumano()
Local aAreaAnt   := GetArea()
Local aAreaD12   := D12->(GetArea())
Local cMensagem  := ""
Local lRet       := .T.
Local cCarga     := ""
Local cDocto     := ""
Local cServico   := ""
Local cDesSer    := ""
Local cRecHum    := Space(TamSx3("D12_RECHUM")[1])
Local oSize      := Nil
Local aPosObj    := {}
Local aItensRh   := {}
Local aRecnoRh   := {}
Local aHList     := {}
Local lNaoConv   := SuperGetMV("MV_WMSNREG", .F., .F.)
Local lMsgNaoC   := .F.
Local nOpca      := 0
Local nX         := 0
Local lMark      := .T.
Local oDlg       := Nil
Local oListBox   := Nil
Local oOk        := LoadBitmap( GetResources(), "LBOK")
Local oNo        := LoadBitmap( GetResources(), "LBNO")
Local lWM332Rhm  := ExistBlock('WM330RHM')
Local cQuery     := ""
Local cAliasD12  := GetNextAlias()
Local lCarga     := .F.
Local oRegraConv := WMSBCCRegraConvocacao():New()
Local oMovAux    := Nil

	TeclaAtalho(.F.)  // Desativa teclas de atalho

	If oMovimento:GoToD12(D12->(Recno()))
		If oMovimento:GetStatus() != '0'
			cCarga   := oMovimento:oOrdServ:GetCarga()
			cDocto   := oMovimento:oOrdServ:GetDocto() + Iif(oMovimento:oOrdServ:GetOrigem() <> "SC9",Iif(!Empty(oMovimento:oOrdServ:GetSerie())," / "+oMovimento:oOrdServ:GetSerie(),""),"")
			cServico := oMovimento:oMovServic:GetServico()
			cDesSer  := Tabela("L4", oMovimento:oMovServic:GetServico(), .F.)
			lCarga   := WmsCarga(oMovimento:oOrdServ:GetCarga())

			cQuery := "SELECT D12.R_E_C_N_O_ RECNOD12"
			cQuery +=  " FROM "+RetSqlName('D12')+" D12"
			cQuery += " WHERE D12.D12_FILIAL = '"+xFilial("D12")+"'"
			cQuery +=   " AND D12.D12_STATUS  IN ('2','4')"
			cQuery +=   " AND D12.D12_SERVIC = '"+oMovimento:oMovServic:GetServico()+"'"
			If WmsCarga(oMovimento:oOrdServ:GetCarga())
				cQuery += " AND D12.D12_CARGA  = '"+oMovimento:oOrdServ:GetCarga()+"'"
			Else
				cQuery += " AND D12.D12_DOC    = '"+oMovimento:oOrdServ:GetDocto()+"'"
				If oMovimento:oOrdServ:GetOrigem() <> "SC9"
					cQuery += " AND D12.D12_SERIE = '"+oMovimento:oOrdServ:GetSerie()+"'"
				EndIf
				cQuery += " AND D12.D12_CLIFOR = '"+oMovimento:oOrdServ:GetCliFor()+"'"
				cQuery += " AND D12.D12_LOJA   = '"+oMovimento:oOrdServ:GetLoja()+"'"
			EndIf
			cQuery += " AND D12.D_E_L_E_T_ = ' '"
			cQuery += " ORDER BY RECNOD12"
			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasD12,.F.,.T.)
			If (cAliasD12)->(Eof())
				WmsMessage(STR0114,WMSA33230) // Não existem atividades pendentes para o ajuste do recurso humano!
				lRet := .F.
			Else
				oMovAux := WMSDTCMovimentosServicoArmazem():New()
				While (cAliasD12)->(!Eof())
					oMovAux:GoToD12((cAliasD12)->RECNOD12)
					// Array ListBox
					AAdd(aItensRh,{.F., ;
					(oMovAux:oMovTarefa:GetTarefa() + " - " + oMovAux:oMovTarefa:GetDesTar()), ;
					(oMovAux:oMovTarefa:GetAtivid() + " - " + oMovAux:oMovTarefa:GetDesAti()), ;
					oMovAux:GetRecHum(), ;
					oMovAux:oMovEndOri:GetArmazem(), ;
					oMovAux:oMovEndOri:GetEnder(), ;
					oMovAux:oMovEndDes:GetArmazem(), ;
					oMovAux:oMovEndDes:GetEnder(), ;
					IIf (lCarga,"",oMovAux:oOrdServ:GetDocto()), ;
					oMovAux:oMovPrdLot:GetProduto(), ;
					oMovAux:oMovPrdLot:GetDesc(), ;
					(oMovAux:GetRhFunc() + " - " + Posicione("SRJ",1,xFilial("SRJ")+oMovAux:GetRhFunc(),"RJ_DESC")), ;
					oMovAux:GetQtdMov()})

					AAdd(aRecnoRh,oMovAux:GetRecno())
					(cAliasD12)->(dbSkip())
				EndDo
			EndIf
			(cAliasD12)->(dbCloseArea())
		Else
			lRet := .F.
		EndIF
	EndIf
	If lRet
		// Calcula as dimensoes dos objetos
		oSize := FwDefSize():New( .T. )  // Com enchoicebar

		// Cria Enchoice
		oSize:AddObject( "MASTER", 100, 85, .T., .F. ) // Adiciona enchoice
		oSize:AddObject( "DETAIL", 100, 60, .T., .T. ) // Adiciona enchoice

		// Dispara o cálculo
		oSize:Process()

		nOpca := 0

		DEFINE MSDIALOG oDlg TITLE STR0049;
		  FROM oSize:aWindSize[1],oSize:aWindSize[2];
		    TO oSize:aWindSize[3],oSize:aWindSize[4] PIXEL

		// Monta a Enchoice
		aPosObj := {;
		oSize:GetDimension("MASTER","LININI"),;
		oSize:GetDimension("MASTER","COLINI"),;
		oSize:GetDimension("MASTER","LINEND"),;
		oSize:GetDimension("MASTER","COLEND")}

		@ aPosObj[1], aPosObj[2] TO aPosObj[3], aPosObj[4] LABEL STR0049 OF oDlg PIXEL // Recursos Humanos

		// ---
		If WmsCarga(oMovimento:oOrdServ:GetCarga())
			@ aPosObj[1]+27,12 SAY RetTitle('D12_DOC') PIXEL
			@ aPosObj[1]+25,50 MSGET oGet2 VAR cDocto PIXEL WHEN .F.
		Else
			@ aPosObj[1]+27,12 SAY RetTitle('D12_CARGA') PIXEL
			@ aPosObj[1]+25,50 MSGET oGet4 VAR cCarga PIXEL WHEN .F.
		EndIf
		// ---
		@ aPosObj[1]+42,12 SAY RetTitle('D12_SERVIC') PIXEL
		@ aPosObj[1]+40,50 MSGET oGet5 VAR cServico PIXEL WHEN .F.
		@ aPosObj[1]+40,75 MSGET oGet6 VAR cDesSer  PIXEL WHEN .F.
		// ---
		@ aPosObj[1]+57,12 SAY RetTitle('D12_RECHUM') PIXEL
		@ aPosObj[1]+55,50 MSGET oGet7 VAR cRecHum PIXEL F3 "DCD"

		// ---
		AAdd( aHList, " ")
		AAdd( aHList, RetTitle("D12_TAREFA"))
		AAdd( aHList, RetTitle("D12_ATIVID"))
		AAdd( aHList, RetTitle("D12_RECHUM"))
		AAdd( aHList, RetTitle("D12_LOCORI"))
		AAdd( aHList, RetTitle("D12_ENDORI"))
		AAdd( aHList, RetTitle("D12_LOCDES"))
		AAdd( aHList, RetTitle("D12_ENDDES"))
		AAdd( aHList, RetTitle("D12_DOC"))
		AAdd( aHList, RetTitle("D12_PRODUT"))
		AAdd( aHList, RetTitle("B1_DESC"))
		AAdd( aHList, RetTitle("D12_RHFUNC"))
		AAdd( aHList, RetTitle("D12_QTDMOV"))

		// Carrega as informações a respeito do tamanho do objeto DETAIL
		aPosObj := {;
		oSize:GetDimension("DETAIL","LININI"),; // Pos.x
		oSize:GetDimension("DETAIL","COLINI"),; // Pos.y
		oSize:GetDimension("DETAIL","XSIZE" ),; // Size.x
		oSize:GetDimension("DETAIL","YSIZE" )}  // Size.y

		oListBox := TWBrowse():New(aPosObj[1],aPosObj[2],aPosObj[3],aPosObj[4],,aHList,,oDlg,,,,,,,,,,,,, "ARRAY", .T. )
		oListBox:SetArray(aItensRh)
		oListBox:bLine := { || {Iif(aItensRH[oListBox:nAT,1],oOk,oNo),;
		aItensRH[oListBox:nAT,2],;
		aItensRH[oListBox:nAT,3],;
		aItensRH[oListBox:nAT,4],;
		aItensRH[oListBox:nAT,5],;
		aItensRH[oListBox:nAT,6],;
		aItensRH[oListBox:nAT,7],;
		aItensRH[oListBox:nAT,8],;
		aItensRH[oListBox:nAT,9],;
		aItensRH[oListBox:nAT,10],;
		aItensRH[oListBox:nAT,11],;
		aItensRH[oListBox:nAT,12],;
		aItensRH[oListBox:nAT,13]}}
		oListBox:bLDblClick := { || (aItensRh[oListBox:nAt,1]:=!aItensRh[oListBox:nAt,1],oListBox:Refresh())}
		oListBox:bHeaderClick := { |oObj,nCol| IIF(nCol==1,MrkBrowse(@oListBox,@aItensRH,@lMark),Nil) }

		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 2,oDlg:End()},{|| nOpca := 1,oDlg:End()}) CENTERED
		// ---
		If nOpca == 2
			oRegraConv:oMovimento := oMovimento
			oRegraConv:oOrdServ   := oMovimento:oOrdServ
			oRegraConv:oMovServic := oMovimento:oMovServic
			oRegraConv:oMovTarefa := oMovimento:oMovTarefa
			oRegraConv:oMovPrdLot := oMovimento:oMovPrdLot
			oRegraConv:oMovEndOri := oMovimento:oMovEndOri
			oRegraConv:oMovEndDes := oMovimento:oMovEndDes
			For nX := 1 To Len(aItensRh)
				If aItensRh[nX,1]
					If oMovimento:GoToD12(aRecnoRh[nX]) .And. ;
					oMovimento:GetRecHum() <> cRecHum .And. ;
					oMovimento:GetStatus() $ '24'
						DCI->(DbSetOrder(2))
						If Empty(cRecHum) .Or. DCI->(dbSeek( xFilial('DCI')+cRecHum+oMovimento:GetRhFunc(),.T.))
							If !Empty(cRecHum)

								// Verifica se ha regras para convocacao para estas atividades.
								oRegraConv:aRetRegra := {}
								oRegraConv:SetRecHum(cRecHum)
								oRegraConv:SetArmazem(oMovimento:oMovEndOri:GetArmazem())
								If oRegraConv:LawRecHum()
									// Analisa se convocao ou nao
									If !oRegraConv:LawLimit()
										lMsgNaoC := .T.
										Loop
									EndIf
								Else
									// Convocar para esta atividade somente se encontrar regra definida para o operador.
									If lNaoConv
										lMsgNaoC := .T.
										Loop
									EndIf
									// Apesar de o operador(A) nao ter regra definida, preciso analisar se outro operador(B) reservou a rua,
									// se o operador(B) ja reservou a rua o operador(A) nao sera convocado ate que a rua seja liberada.
									If !oRegraConv:LawChkRua()
										lMsgNaoC := .T.
										Loop
									EndIf
								EndIf
							EndIf
							If lWM332Rhm
								ExecBlock('WM330RHM',.F.,.F.,{cRecHum})
							EndIf
							oMovimento:SetRecHum(cRecHum)
							oMovimento:UpdateD12()
						EndIf
					EndIf
				EndIf
			Next
			If lMsgNaoC
				WmsMessage(STR0072,WMSA33217,10,,{STR0088}) // Existem atividades que não foram atribuídas ao recurso humano devido limitação imposta pelas regras de convocação.
			EndIf
		EndIf
		If Len(cMensagem) > 0
			WmsMessage(cMensagem,WMSA33218,10,,{STR0088})
		EndIf
	EndIf
	TeclaAtalho(.T.)  // Reativa teclas de atalho
	oBrowse:Refresh() // Força Refresh
	RestArea(aAreaD12)
	RestArea(aAreaAnt)
Return( Nil )
/*--------------------------------------------------------------------------------
---MrkBrowse
---Marca/Desmarca Atividades
---Alexsander.Correa - 01/04/2015
----------------------------------------------------------------------------------*/
Static Function MrkBrowse(oListBox, aItensRh, lMark)
Local nX := 0
	For nX := 1 To Len(aItensRh)
		aItensRh[nX, 1] := lMark
	Next
	lMark := !lMark
	oListBox:Refresh()
Return( Nil )
/*--------------------------------------------------------------------------------
---HistLog
---Mostra Log de divergencia na conferencia
---Alexsander.Correa - 01/04/2015
----------------------------------------------------------------------------------*/
Static Function HistLog()
Local cWmsDoc  := SuperGetMV("MV_WMSDOC",.F.,"")
Local nTamDoc  := TamSX3('D12_DOC')[1]
Local nTamCar  := TamSX3('D12_CARGA')[1]
Local oDlg
Local oFont
Local cMemo    := ""
Local cSeekDCN := ""
Local cDocto   := ""
Local cCarga   := ""
Local cMapSep  := ""
Local cLogFile := ""

	TeclaAtalho(.F.)  // Desativa teclas de atalho
	If oMovimento:GoToD12(D12->(Recno()))
		If oMovimento:GetStatus() != '0'
		cDocto   := D12->D12_DOC
		cCarga   := D12->D12_CARGA
		cMapSep  := AllTrim(D12->D12_MAPSEP)
			// Mostra registro de Ocorrencias (DCN)
			If !Empty(oMovimento:GetOcorre())
				DbSelectArea("DCN")
				DCN->(DbSetOrder(2)) // DCN_FILIAL+DCN_PROD+DCN_LOCAL+DCN_NUMSEQ+DCN_DOC+DCN_SERIE+DCN_CLIFOR+DCN_LOJA+DCN_ITEM
				If DCN->(dbSeek(xFilial("DCN")+oMovimento:oMovPrdLot:GetProduto()+oMovimento:oMovEndOri:GetArmazem()))
					Do While DCN->(!EOF() .And. DCN_FILIAL+DCN_PROD+DCN_LOCAL+DCN_DOC+DCN_SERIE+DCN_CLIFOR+DCN_LOJA+DCN_ENDER==xFilial("DCN")+oMovimento:oMovPrdLot:GetProduto()+oMovimento:oMovEndOri:GetArmazem()+oMovimento:oOrdServ:GetDocto()+oMovimento:oOrdServ:GetSerie()+oMovimento:oOrdServ:GetCliFor()+oMovimento:oOrdServ:GetLoja()+oMovimento:oMovEndOri:GetEnder())
						If Empty(cMemo)
							cMemo += STR0056+CRLF // Ocorrencias Registradas:
						EndIf
						cMemo += DCN->DCN_NUMERO+" - "+DCN->DCN_OCORR+" - "
						cMemo += AllTrim(Posicione("DCM",1,xFilial("DCM")+DCN->DCN_OCORR,"DCM_DESCRI"))+CRLF
						cMemo += DCN->DCN_STATUS+" - "+AllTrim(Substr(x3FieldToCbox("DCN_STATUS",DCN->DCN_STATUS),4))+" / "
						cMemo += DToC(DCN->DCN_DTINI)+" - "+DCN->DCN_HRINI
						If !Empty(DCN->DCN_DTFIM)
							cMemo += " / "+DToC(DCN->DCN_DTFIM)+" - "+DCN->DCN_HRFIM
						EndIf
						cMemo += CRLF
						If !Empty(DCN->DCN_ACAO)
							cMemo += DCN->DCN_ACAO+" - "+AllTrim(Substr(x3FieldToCbox("DCN_ACAO",DCN->DCN_ACAO),4))+CRLF
						EndIf
						cMemo += Replicate("-",80)+CRLF
						DCN->(dbSkip())
					EndDo
				EndIf
			EndIf
			If WmsCarga(oMovimento:oOrdServ:GetCarga())
				If !Empty(cMapSep)
					cLogFile := "EX"+AllTrim(Padr(oMovimento:oOrdServ:GetCarga(),nTamCar))+".LOG"
				Else
					cLogFile := "RF"+AllTrim(Padr(oMovimento:oOrdServ:GetCarga(),nTamCar))+".LOG"
				EndIf
			Else
				cLogFile := "RF"+AllTrim(Padr(oMovimento:oOrdServ:GetDocto(),nTamDoc))+".LOG"
			EndIf
			// MV_WMSDOC - Define o diretorio onde serao armazenados os documentos/logs gerados pelo WMS.
			// Este parametro deve estar preenchido com um diretorio criado abaixo do RootPath.
			// Exemplo: Preencha o parametro com \WMS para o sistema mover o log de ocorrencias do diretorio
			// C:\MP8\SYSTEM p/o diretorio C:\MP8\WMS
			If !Empty(cWmsDoc)
				cWmsDoc := AllTrim(cWmsDoc)
				If Right(cWmsDoc,1)$"/\"
					cWmsDoc := Left(cWmsDoc,Len(cWmsDoc)-1)
				EndIf
				cLogFile := cWmsDoc+"\"+cLogFile
			EndIf
			If File(cLogFile) .Or. !Empty(cMemo)
				// MostraErro()
				DEFINE FONT oFont NAME "Courier New" SIZE 5,0
				cMemo += MemoRead(cLogFile)
				DEFINE MSDIALOG oDlg TITLE cLogFile FROM 3,0 TO 340,417 PIXEL
				@ 5,5 GET oMemo  VAR cMemo MEMO SIZE 200,145 OF oDlg PIXEL
				oMemo:bRClicked := {||AllwaysTrue()}
				oMemo:oFont:=oFont
				DEFINE SBUTTON  FROM 153,175 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL //Apaga
				ACTIVATE MSDIALOG oDlg CENTER
			EndIf
		EndIf
	EndIf
	TeclaAtalho(.T.)  // Reativa teclas de atalho
	oBrowse:Refresh() // Força Refresh

Return( Nil )
/*--------------------------------------------------------------------------------
---SaldoEnder
---Exibe Saldos dos enderecos origem e destino
---Alexsander.Correa - 01/04/2015
----------------------------------------------------------------------------------*/
Static Function SaldoEnder()
Local aAreaAnt  := GetArea()
Local aAreaD12  := D12->(GetArea())
Local lRadioF   := (SuperGetMV('MV_RADIOF')=='S')
Local cStatRF   := "1"
Local aItSld    := {}
Local nSaldoOri := 0
Local nSaldoDes := 0
Local oDlgSld
Local oLBxSld
Local oEstEnder := WMSDTCEstoqueEndereco():New()

	TeclaAtalho(.F.)  // Desativa teclas de atalho
	If oMovimento:GoToD12(D12->(Recno()))
		If oMovimento:GetStatus() != '0'
			oEstEnder:oEndereco:SetArmazem(oMovimento:oMovEndOri:GetArmazem())
			oEstEnder:oEndereco:SetEnder(oMovimento:oMovEndOri:GetEnder())
			oEstEnder:oProdLote:SetArmazem(oMovimento:oMovPrdLot:GetArmazem())
			oEstEnder:oProdLote:SetProduto(oMovimento:oMovPrdLot:GetProduto())
			oEstEnder:oProdLote:SetPrdOri(oMovimento:oMovPrdLot:GetPrdOri())
			nSaldoOri := oEstEnder:ConsultSld(.T.,.F.,.F.,.F.)
			AAdd(aItSld,{STR0051,oMovimento:oMovEndOri:GetArmazem(),oMovimento:oMovEndOri:GetEnder(),Transform(nSaldoOri,PesqPict("D12","D12_QTDMOV"))}) // Origem

			// Endereco Destino
			oEstEnder:oEndereco:SetArmazem(oMovimento:oMovEndDes:GetArmazem())
			oEstEnder:oEndereco:SetEnder(oMovimento:oMovEndDes:GetEnder())
			nSaldoDes := oEstEnder:ConsultSld(.T.,.F.,.F.,.F.)
			AAdd(aItSld,{STR0052,oMovimento:oMovEndDes:GetArmazem(),oMovimento:oMovEndDes:GetEnder(),Transform(nSaldoDes,PesqPict("D12","D12_QTDMOV"))}) // Destino

			// Exibe Saldos dos enderecos
			DEFINE MSDIALOG oDlgSld TITLE STR0053 FROM 3,0 TO 160,480 PIXEL // Saldos (c/Servicos WMS)
			@ 05, 04 SAY RetTitle('D12_PRODUT') PIXEL
			@ 05, 40 MSGET oGet1 VAR oMovimento:oMovPrdLot:GetProduto() PIXEL WHEN .F.
			@ 20, 04 LISTBOX oLBxSld VAR cVar FIELDS HEADER STR0054,RetTitle("D12_LOCORI"),RetTitle("D12_ENDORI"),STR0055 SIZE 235,45 OF oDlgSld PIXEL // Endereco"###"Saldo"

			oLBxSld:SetArray(aItSld)
			oLBxSld:bLine := {||{aItSld[oLBxSld:nAT,1],aItSld[oLBxSld:nAT,2],aItSld[oLBxSld:nAT,3],aItSld[oLBxSld:nAT,4]}}

			DEFINE SBUTTON  FROM 65,200 TYPE 1 ACTION oDlgSld:End() ENABLE OF oDlgSld PIXEL
			ACTIVATE MSDIALOG oDlgSld CENTER
		EndIf
	EndIf
	TeclaAtalho(.T.)  // Reativa teclas de atalho
	RestArea(aAreaD12)
	RestArea(aAreaAnt)
Return( Nil )
/*--------------------------------------------------------------------------------
---Mensagem
---Envia mensagens para coletores de radiofrequencia.
---Alexsander.Correa - 01/04/2015
----------------------------------------------------------------------------------*/
Static Function Mensagem()
Local oMemo
Local cMemo
Local oFont
Local oDlgMsg
Local cNumCol
	If D12->D12_STATUS != '0'
		TeclaAtalho(.F.)  // Desativa teclas de atalho
		DbSelectArea("D12")
		cCodOpe := D12->D12_RECHUM
		If Empty(cCodOpe)
			WmsMessage(STR0065,WMSA33219,1)// Atividade sem operador atribuído.
			TeclaAtalho(.T.)  // Reativa teclas de atalho
			Return
		EndIf
		cNumCol := RetNumCol(cCodOpe)
		If Empty(cNumCol)
			TeclaAtalho(.T.)  // Reativa teclas de atalho
			Return
		EndIf
		DEFINE FONT oFont NAME "Mono AS" SIZE 8,20
		DEFINE MSDIALOG oDlgMsg FROM 0,0 TO 100,300  Pixel TITLE OemToAnsi(STR0066+cNumCol) // Mensagem para o coletor
		@ 0,0 GET oMemo  VAR cMemo MEMO SIZE 150,30 OF oDlgMsg PIXEL
		TButton():New( 035,001, STR0068, oDlgMsg, {|| MemoWrite('VT'+cNumCol+'.MSG',cMemo),oDlgMsg:End()}, 38, 11,,, .F., .t., .F.,, .F.,,, .F. ) // Enviar
		TButton():New( 035,111, STR0069, oDlgMsg, {|| oDlgMsg:End()}, 38, 11,,, .F., .t., .F.,, .F.,,, .F. ) // Sair
		oMemo:oFont:=oFont

		ACTIVATE MSDIALOG oDlgMsg CENTERED
	EndIf
	TeclaAtalho(.T.)  // Reativa teclas de atalho
Return
/*--------------------------------------------------------------------------------
---RetNumCol
---Enva mensagens para coletores de radiofrequencia.
---Alexsander.Correa - 01/04/2015
---cCodOpe, Caracter, Código do operador
----------------------------------------------------------------------------------*/
Static Function RetNumCol(cCodOpe)
Local aAreaSav := GetArea()
Local cLinha   := Space(70)
Local cNumCol  := ""
Local cNomCol  := ""
Local cNomUsr  := ""
Local nX       := 0
Local aColetor := Directory("VT*.SEM")
Local nHTemp

Default cCodOpe := D12->D12_RECHUM

	// Procura o usuario nos coletores ativos
	cNomUsr  := UsrRetName(cCodOpe)
	aColetor := Directory("VT*.SEM")
	For nX := 1 to Len(aColetor)
		cLinha  := Memoread(aColetor[nX,1])
		cNomCol := Subs(cLinha,4,25)
		If AllTrim(cNomCol) == Alltrim(cNomUsr)
			cNumCol := Left(cLinha,3)
			Exit
		EndIf
	Next nX
	If Empty(cNumCol)
		WmsMessage(STR0067,WMSA33220,2) // Operador com RF desligado.
	EndIf
	RestArea(aAreaSav)
Return( cNumCol )
/*--------------------------------------------------------------------------------
---Reprocess
---Reprocessa a Regra de Convocação
---Alexsander.Correa - 01/04/2015
---nOpcao, numerico, "1" = De acordo com o documento
"2" = Todos os documentos
----------------------------------------------------------------------------------*/
Static Function Reprocess(nOpc)
	Processa({|| ProcRegua(0), ReprocDoc(nOpc) },STR0121+" "+IIf(nOpc=="1",STR0122,STR0123),STR0124 + '...',.F.) // Reprocessar # Documento#Todos # Aguarde
Return Nil
/*--------------------------------------------------------------------------------
---Reprocess
---Reprocessa a Regra de Convocação
---Alexsander.Correa - 01/04/2015
---nOpcao, numerico, "1" = De acordo com o documento
"2" = Todos os documentos
----------------------------------------------------------------------------------*/
Static Function ReprocDoc(nOpc)
Local aAreaAnt  := GetArea()
Local aAreaD12  := D12->(GetArea())
Local cQuery    := ''
Local cQueryPE  := ''
Local cAliasD12 := GetNextAlias()
Local oServico  := WMSDTCServicoTarefa():New()
Local oRegraConv:= WMSBCCRegraConvocacao():New()

Default nOpc := '2'

	TeclaAtalho(.F.)  // Desativa teclas de atalho
	// Força recarregar os parametros da query do WMSA332
	Pergunte('WMSA332', .F.)
	If nOpc == '1' // Monta a query para reprocessar de acordo com o documento
		oRegraConv:IniArrLib()
		If oMovimento:GoToD12(D12->(Recno()))
			cQuery := "SELECT D12.D12_LOCORI, D12_SERVIC, D12_ORDTAR, R_E_C_N_O_ RECNOD12 "
			cQuery +=  " FROM "+RetSqlName('D12')+" D12"
			cQuery += " WHERE D12.D12_FILIAL = '"+xFilial("D12")+"'"
			cQuery +=   " AND D12.D12_STATUS  = '-'"
			If !(Empty(mv_par01) .And. Upper(mv_par02) == Replicate('Z', Len(mv_par02)))
				cQuery += " AND D12.D12_SERVIC >= '"+mv_par01+"'"
				cQuery += " AND D12.D12_SERVIC <= '"+mv_par02+"'"
			EndIf
			If !(Empty(mv_par03) .And. DtoS(mv_par04) == '20491231')
				cQuery += " AND D12.D12_DTGERA >= '"+DToS(mv_par03)+"'"
				cQuery += " AND D12.D12_DTGERA <= '"+DToS(mv_par04)+"'"
			EndIf
			If WmsCarga(oMovimento:oOrdServ:GetCarga())
				cQuery += " AND D12.D12_CARGA  = '"+oMovimento:oOrdServ:GetCarga()+"'"
			Else
				cQuery += " AND D12.D12_DOC    = '"+oMovimento:oOrdServ:GetDocto()+"'"
				cQuery += " AND D12.D12_CLIFOR = '"+oMovimento:oOrdServ:GetCliFor()+"'"
				cQuery += " AND D12.D12_LOJA   = '"+oMovimento:oOrdServ:GetLoja()+"'"
			EndIf
			If !(Empty(mv_par07) .And. Upper(mv_par08) == Replicate('Z', Len(mv_par08)))
				cQuery += " AND D12.D12_CODREC >= '"+mv_par07+"'"
				cQuery += " AND D12.D12_CODREC <= '"+mv_par08+"'"
			EndIf
			If !(Empty(mv_par11) .And. Upper(mv_par12) == Replicate('Z', Len(mv_par12)))
				cQuery += " AND D12.D12_LOCORI >= '"+mv_par11+"'"
				cQuery += " AND D12.D12_LOCORI <= '"+mv_par12+"'"
			EndIf
			If !(Empty(mv_par13) .And. Upper(mv_par14) == Replicate('Z', Len(mv_par14)))
				cQuery += " AND D12.D12_PRODUT >= '"+mv_par13+"'"
				cQuery += " AND D12.D12_PRODUT <= '"+mv_par14+"'"
			EndIf
			If !(Empty(mv_par18) .And. Upper(mv_par19) == Replicate('Z', Len(mv_par19)))
				cQuery += " AND D12.D12_CLIFOR >= '"+mv_par18+"'"
				cQuery += " AND D12.D12_CLIFOR <= '"+mv_par19+"'"
			EndIF
			If !(Empty(mv_par20) .And. Upper(mv_par21) == Replicate('Z', Len(mv_par21)))
				cQuery += " AND D12.D12_LOJA >= '"+mv_par20+"'"
				cQuery += " AND D12.D12_LOJA <= '"+mv_par21+"'"
			EndIf
			If !Empty(mv_par22)
				cQuery += "AND D12.D12_MAPSEP = '"+mv_par22+"'"
			EndIf
			cQuery +=   " AND D12.D_E_L_E_T_ = ' '"
			// Ponto de Entrada WM330QRY para a alteracao da Query
			If ExistBlock('WM330QRY')
				If ValType(cQueryPE:=ExecBlock('WM330QRY',.F.,.F.)) == 'C'
					cQuery += cQueryPE
				EndIf
			EndIf
		EndIf
	ElseIf nOpc == '2' //Monta a query para reprocessar todos
		cQuery := "SELECT D12_LOCORI, D12_SERVIC, D12_ORDTAR, R_E_C_N_O_ RECNOD12 "
		cQuery +=  " FROM "+RetSqlName('D12')+" D12"
		cQuery += " WHERE D12.D12_FILIAL = '"+xFilial("D12")+"'"
		cQuery +=   " AND D12.D12_STATUS  = '-'"
		If !(Empty(mv_par01) .And. Upper(mv_par02) == Replicate('Z', Len(mv_par02)))
			cQuery += " AND D12.D12_SERVIC >= '"+mv_par01+"'"
			cQuery += " AND D12.D12_SERVIC <= '"+mv_par02+"'"
		EndIf
		If !(Empty(mv_par03) .And. DtoS(mv_par04) == '20491231')
			cQuery += " AND D12.D12_DTGERA >= '"+DToS(mv_par03)+"'"
			cQuery += " AND D12.D12_DTGERA <= '"+DToS(mv_par04)+"'"
		EndIf
		If !(Empty(mv_par05) .And. Upper(mv_par06) == Replicate('Z', Len(mv_par06)))
			cQuery += " AND D12.D12_CARGA >= '"+mv_par05+"'"
			cQuery += " AND D12.D12_CARGA <= '"+mv_par06+"'"
		EndIf
		If !(Empty(mv_par07) .And. Upper(mv_par08) == Replicate('Z', Len(mv_par08)))
			cQuery += " AND D12.D12_CODREC >= '"+mv_par07+"'"
			cQuery += " AND D12.D12_CODREC <= '"+mv_par08+"'"
		EndIf
		If !(Empty(mv_par09) .And. Upper(mv_par10) == Replicate('Z', Len(mv_par10)))
			cQuery += " AND D12.D12_DOC >= '"+mv_par09+"'"
			cQuery += " AND D12.D12_DOC <= '"+mv_par10+"'"
		EndIf
		If !(Empty(mv_par11) .And. Upper(mv_par12) == Replicate('Z', Len(mv_par12)))
			cQuery += " AND D12.D12_LOCORI >= '"+mv_par11+"'"
			cQuery += " AND D12.D12_LOCORI <= '"+mv_par12+"'"
		EndIf
		If !(Empty(mv_par13) .And. Upper(mv_par14) == Replicate('Z', Len(mv_par14)))
			cQuery += " AND D12.D12_PRODUT >= '"+mv_par13+"'"
			cQuery += " AND D12.D12_PRODUT <= '"+mv_par14+"'"
		EndIf
		If !(Empty(mv_par18) .And. Upper(mv_par19) == Replicate('Z', Len(mv_par19)))
			cQuery += " AND D12.D12_CLIFOR >= '"+mv_par18+"'"
			cQuery += " AND D12.D12_CLIFOR <= '"+mv_par19+"'"
		EndIF
		If !(Empty(mv_par20) .And. Upper(mv_par21) == Replicate('Z', Len(mv_par21)))
			cQuery += " AND D12.D12_LOJA >= '"+mv_par20+"'"
			cQuery += " AND D12.D12_LOJA <= '"+mv_par21+"'"
		EndIf
		If !Empty(mv_par22)
			cQuery += "AND D12.D12_MAPSEP = '"+mv_par22+"'"
		EndIf
		cQuery +=   " AND D12.D_E_L_E_T_ = ' '"
		// Ponto de Entrada WM330QRY para a alteracao da Query
		If ExistBlock('WM330QRY')
			If ValType(cQueryPE:=ExecBlock('WM330QRY',.F.,.F.)) == 'C'
				cQuery += cQueryPE
			EndIf
		EndIf
	EndIf
	If !Empty(cQuery) // Validação para quando escolhida opção por documento e não existirem registros na tela
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasD12,.F.,.T.)
		// Carrega os registros D12 no array privado aLibD12, para ser utilizado posteriormente pela função WmsExeDCF
		While (cAliasD12)->(!Eof())
			// Busca dados Servico
			oServico:SetServico((cAliasD12)->D12_SERVIC)
			oServico:SetOrdem((cAliasD12)->D12_ORDTAR)
			oServico:LoadData()
			AAdd(oRegraConv:GetArrLib(),{IIf(oServico:GetBlqSrv() == '1','2','4'),(cAliasD12)->RECNOD12,(cAliasD12)->D12_LOCORI,(cAliasD12)->D12_SERVIC,""})
			(cAliasD12)->(dbSkip())
		EndDo
		(cAliasD12)->(dbCloseArea())

	EndIf
	If !Empty(oRegraConv:GetArrLib())
		oRegraConv:LawExecute()
	Else
		WmsMessage(STR0087,WMSA33221,,,,STR0115)//Não existem registros aptos a reprocessar! //A opção de reprocessar regra de convocação só pode ser executada em registros sem status definido.
	EndIf
	TeclaAtalho(.T.)  // Reativa teclas de atalho
	oBrowse:Refresh() // Força Refresh
	RestArea(aAreaD12)
	RestArea(aAreaAnt)
Return
/*--------------------------------------------------------------------------------
---MontaQuery
---Monta Query
---Alexsander.Correa - 01/04/2015
---cAcao, Caracter, "1" - Atividade
---                 "2" - Tarefa
---                 "3" - Carga/Doc
----------------------------------------------------------------------------------*/
Static Function MontaQuery(cAcao)
Local cQuery := ""
Local cOpc   := WmsOpc332()
	cQuery := "SELECT D12.R_E_C_N_O_ D12RECNO"
	cQuery +=  " FROM "+RetSqlName('D12')+" D12"
	cQuery += " WHERE D12.D12_FILIAL = '"+xFilial("D12")+"'"
	cQuery +=   " AND D12.D12_SERVIC = '"+oMovimento:oMovServic:GetServico()+"'"
	// Avalia Status
	If cOpc == "1"
		cQuery +=   " AND D12.D12_STATUS IN ('3','4')"
	ElseIf cOpc == "2"
		cQuery +=   " AND D12.D12_STATUS IN ('2','3')"
	ElseIf cOpc == "4"
		cQuery +=   " AND D12.D12_STATUS IN ('2','3','4')"
	EndIf
	If cAcao == "2"
		cQuery += " AND D12.D12_TAREFA = '"+oMovimento:oMovServic:GetTarefa()+"'"
		cQuery += " AND D12.D12_ORDTAR = '"+oMovimento:oMovServic:GetOrdem()+"'"
		cQuery += " AND D12.D12_PRODUT = '"+oMovimento:oMovPrdLot:GetProduto()+"'"
		cQuery += " AND D12.D12_IDDCF = '"+oMovimento:oOrdServ:GetIdDCF()+"'"
	EndIf
	If !Empty(oMovimento:GetMapSep())
		cQuery += " AND D12.D12_MAPSEP = '"+oMovimento:GetMapSep()+"'"
	ElseIf !Empty(oMovimento:oOrdServ:GetCarga())
		cQuery += " AND D12.D12_CARGA = '"+oMovimento:oOrdServ:GetCarga()+"'"
	Else
		cQuery += " AND D12.D12_DOC = '"+oMovimento:oOrdServ:GetDocto()+"'"
		If oMovimento:oOrdServ:GetOrigem() <> "SC9"
			cQuery += " AND D12.D12_SERIE = '"+oMovimento:oOrdServ:GetSerie()+"'"
		EndIf
		cQuery += " AND D12.D12_CLIFOR = '"+oMovimento:oOrdServ:GetCliFor()+"'"
		cQuery += " AND D12.D12_LOJA = '"+oMovimento:oOrdServ:GetLoja()+"'"
	EndIf
	cQuery += " AND D12.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
Return cQuery

Static Function Inventario()
Local aAreaAnt := GetArea()
	If oMovimento:GoToD12(D12->(Recno()))
		If !(oMovimento:GetStatus() $ '0|1')
			FWExecView(STR0101,"WMSA332C", MODEL_OPERATION_INSERT,, { || .T. } ,, ) // Incluir
		Else
			WmsMessage(STR0116,WMSA33223) //Geração de inventário é permitida apenas para atividades pendentes.
		EndIf
	EndIf

	RestArea(aAreaAnt)
Return

Static Function AlterEnder()
Local aAreaAnt  := GetArea()
Local aAreaD12  := D12->(GetArea())
Local lRet      := .T.
Local aAreaAnt2 := {}
Local cMessage  := ""
	//Grava opções selecionadas
	WmsOpc332("6")
	WmsAcao332("1")
	TeclaAtalho(.F.) // Desativa teclas de atalho
	If oMovimento:GoToD12(D12->(Recno()))
		If !(oMovimento:ChkSitMov())
			WmsMessage(STR0105,WMSA33226,,,,STR0106) // Situação da movimentação não permite troca de endereço ou atividade já foi iniciada. // Apenas movimentações com situação '2=Com Problemas' ou '4=A Executar' permitem troca de endereço.
			lRet := .F.
		EndIf
		If lRet .And. !Empty(oMovimento:oOrdServ:GetIdOrig()) .And. oMovimento:oOrdServ:FindDCFOri() != "SC9"
			WmsMessage(STR0107,WMSA33227) // Não é permitido alterar o endereço de um movimento originado de outro serviço!
			lRet := .F.
		EndIf
		If lRet .And. oMovimento:oMovServic:ChkConfer()
			WmsMessage(STR0108,WMSA33228) // Serviço não permite alteração do endereço.
			lRet := .F.
		EndIf
		If lRet 
			If oMovimento:oMovServic:ChkSepara() .Or. oMovimento:oMovServic:ChkReabast() // Deve validar se o endereço origem está preenchido
				If !Empty(oMovimento:oOrdServ:oOrdEndOri:GetEnder()) .And. oMovimento:HasMoreMov()
					cMessage := STR0024 // "Esta movimentação foi originada de uma ordem de serviço WMS com endereço origem informado no documento de integração e possui outros movimentos para este mesmo endereço origem. "
					cMessage += STR0025 // "O endereço origem será apagado da ordem de serviço e do documento de integração. Confirma esta operação?"
					lRet := WmsQuestion(cMessage)
				EndIf
			ElseIf oMovimento:oMovServic:ChkRecebi() .Or. oMovimento:oMovServic:ChkTransf() // Deve validar se o endereço destino está preenchido
				If !Empty(oMovimento:oOrdServ:oOrdEndDes:GetEnder()) .And. oMovimento:HasMoreMov()
					cMessage := STR0027 // "Esta movimentação foi originada de uma ordem de serviço WMS com endereço destino informado no documento de integração e possui outros movimentos para este mesmo endereço destino. "
					cMessage += STR0028 // "O endereço destino será apagado da ordem de serviço e do documento de integração. Confirma esta operação?"
					lRet := WmsQuestion(cMessage)
				EndIf
			EndIf
		EndIf
	EndIf
	If lRet
		aAreaAnt2 := GetArea()
		Set Key VK_F4 TO WMSA332AF4()
		Processa({|| ProcRegua(0),FWExecView(STR0082,"WMSA332A",MODEL_OPERATION_UPDATE,,{||.T.},,)},STR0102,STR0104 + '...',.F.) // Alterar Endereço // Carregando tela de confirmação
		Set Key VK_F4 TO
		RestArea(aAreaAnt2)
	EndIf
	oMovimento:oOrdServ:aWmsAviso := aMensagem
	aMensagem    := {}
	// Exibe as mensages de erro nas movimentações
	// Aviso
	oMovimento:oOrdServ:ShowWarnig()
		
	TeclaAtalho(.T.)// Reativa teclas de atalho
	oBrowse:Refresh()// Força Refresh
	RestArea(aAreaD12)
	RestArea(aAreaAnt)
Return lRet

Static Function ValidaMov()
	If oMovimento:GoToD12(D12->(Recno()))
		// Criação das tabelas temporárias para validação do unitizador
		WMSCTPENDU()
		If oMovimento:GetStatus() == '2'
			If !oMovimento:ChkFinMov(,oMovimento:GetQtdMov())
				WmsMessage(oMovimento:GetErro(),WMSA33231)
			Else
				oMovimento:SetLog('2')
				oMovimento:UpdateD12()
				WmsMessage(STR0125,WMSA33232,,,,STR0126) //"Não existe log pendente de analise!" //"Reinicie a atividade!"
			EndIf
		Else
			WmsMessage(STR0125,WMSA33233) //"Não existe log pendente de analise!"
		EndIf
		// Exclusão das tabelas temporárias
		WMSDTPENDU()
	EndIf
Return

/*/{Protheus.doc} WmsReHu332
Função responsável por indicar se o Recurso Humano do movimento
deve ser mantido ao reiniciar uma atividade, tarefa ou documento
@author  guilherme.metzger
@since   20/08/2018
@version 1.0
@return  lRecHum, indica se deve manter Recurso Humano
/*/
Static __lRecHum := .F.
Function WmsReHu332(lRecHum)
	If ValType(lRecHum) == "L"
		__lRecHum := lRecHum
	EndIf
Return __lRecHum

/*/{Protheus.doc} WmsQtCf332
Função responsável por indicar se a Quantidade Conferida do movimento
deve ser mantida ao reiniciar uma atividade, tarefa ou documento
@author  guilherme.metzger
@since   20/08/2018
@version 1.0
@return  lConf, indica se deve manter a Quantidade Conferida
/*/
Static __lQtdConf := .F.
Function WmsQtCf332(lConf)
	If ValType(lConf) == "L"
		__lQtdConf := lConf
	EndIf
Return __lQtdConf

//------------------------------------------------------------------------------
// Retorna se a rotina está sendo chamada via automação ou customização
//------------------------------------------------------------------------------
Static __lAutoma := .F.
Function Wm332Autom(lAutoma)
	If lAutoma != Nil
		__lAutoma := lAutoma
	EndIf
Return __lAutoma

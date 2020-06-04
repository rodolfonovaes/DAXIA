#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "WMSA332A.CH"

#DEFINE CABECALHO "D12SERVIC/D12DESSER/D12_CARGA/D12_MAPSEP"
#DEFINE GRID "D12_TAREFA/D12DESTAR/D12_ATIVID/D12_DESATI/D12_RECHUM/D12NOMREC/D12_DATINI/D12_HORINI/D12_DATFIM/D12_HORFIM/D12_PRODUT/D12_LOTECT/D12_NUMLOT/D12_NUMSER/D12_DOC/D12_SERIE/D12_CLIFOR/D12_LOJA/D12_QTDMOV/D12_QTDMO2/D12_QTDLID/D12_QTDLI2/D12_LOCORI/D12_ENDORI/D12_IDUNIT/D12TIPORI/D12_LOCDES/D12_ENDDES/D12_UNIDES/D12TIPDES"

#DEFINE WMSA332A01 "WMSA332A01"
#DEFINE WMSA332A02 "WMSA332A02"
#DEFINE WMSA332A03 "WMSA332A03"
#DEFINE WMSA332A04 "WMSA332A04"
#DEFINE WMSA332A05 "WMSA332A05"
#DEFINE WMSA332A06 "WMSA332A06"
#DEFINE WMSA332A07 "WMSA332A07"
#DEFINE WMSA332A08 "WMSA332A08"
#DEFINE WMSA332A09 "WMSA332A09"
#DEFINE WMSA332A10 "WMSA332A10"
#DEFINE WMSA332A11 "WMSA332A11"
#DEFINE WMSA332A12 "WMSA332A12"
#DEFINE WMSA332A13 "WMSA332A13"
#DEFINE WMSA332A14 "WMSA332A14"
#DEFINE WMSA332A15 "WMSA332A15"
#DEFINE WMSA332A16 "WMSA332A16"
#DEFINE WMSA332A17 "WMSA332A17"
#DEFINE WMSA332A18 "WMSA332A18"
#DEFINE WMSA332A19 "WMSA332A19"
#DEFINE WMSA332A20 "WMSA332A20"
#DEFINE WMSA332A21 "WMSA332A21"
#DEFINE WMSA332A22 "WMSA332A22"
#DEFINE WMSA332A23 "WMSA332A23"
#Define CLRF  CHR(13)+CHR(10)

Static oMovimento := WMSBCCMovimentoServico():New()
Static lAutomato  := Wm332Autom()

// Esta função é só para o TDS reconhecer o fonte e poder gerar patch
Function WMSA332ADUMMY()
Return Nil
/*--------------------------------------------------------------------------------
---ModelDef
---Funcao generica MVC do model
---Felipe Machado de Oliveira - 11/02/2014
----------------------------------------------------------------------------------*/
Static Function ModelDef()
Local oStruD12  := FWFormStruct( 1, 'D12')
Local oStruGrid := FWFormStruct( 1, 'D12')
Local oModel    := MPFormModel():New('WMSA332A',{|oModel| BeforeCMdl(oModel) },{|oModel| PosVal(oModel) },{|oModel| GravaDados(oModel)} )
Local aColsSX3  := {}
Local cOp332    := WmsOpc332()

	// AddField
	// [01] C Titulo do campo
	// [02] C ToolTip do campo
	// [03] C identificador (ID) do Field
	// [04] C Tipo do campo
	// [05] N Tamanho do campo
	// [06] N Decimal do campo
	// [07] B Code-block de validação do campo
	// [08] B Code-block de validação When do campo
	// [09] A Lista de valores permitido do campo
	// [10] L Indica se o campo tem preenchimento obrigatório
	// [11] B Code-block de inicializacao do campo
	// [12] L Indica se trata de um campo chave
	// [13] L Indica se o campo não pode receber valor em uma operação de update.
	// [14] L Indica se o campo é virtual
	buscarSX3('D12_SERVIC',,@aColsSX3)
	oStruD12:AddField(aColsSX3[1], aColsSX3[1],'D12SERVIC','C',aColsSX3[3],aColsSX3[4],NIL,{||.F.},NIL,NIL,{ || D12->D12_SERVIC}                                               ,NIL,.F.,.T. )
	buscarSX3('D12_DESSER',,@aColsSX3)
	oStruD12:AddField(aColsSX3[1], aColsSX3[1],'D12DESSER','C',aColsSX3[3],aColsSX3[4],NIL,{||.F.},NIL,NIL,{ || Tabela('L4',D12->D12_SERVIC,.F.)}                              ,NIL,.F.,.T. )
	buscarSX3('D12_DESTAR',,@aColsSX3)
	oStruGrid:AddField(aColsSX3[1],aColsSX3[1],'D12DESTAR','C',aColsSX3[3],aColsSX3[4],NIL,{||.F.},NIL,NIL,{ || Tabela('L2',D12->D12_TAREFA,.F.) }                             ,NIL,.F.,.T. )
	buscarSX3('D12_NOMREC',,@aColsSX3)
	oStruGrid:AddField(aColsSX3[1],aColsSX3[1],'D12NOMREC','C',aColsSX3[3],aColsSX3[4],NIL,NIL    ,NIL,NIL,{ || Posicione('DCD',1,xFilial('DCD')+D12->D12_RECHUM,'D12_NOMREC')},NIL,NIL,.T. )
	buscarSX3('D0Y_TIPUNI',,@aColsSX3)
	oStruGrid:AddField(aColsSX3[1],aColsSX3[1],'D12TIPORI','C',aColsSX3[3],aColsSX3[4],NIL,{||.T.},NIL,NIL,{ || Posicione('D0Y',1,xFilial('D0Y')+D12->D12_IDUNIT,'D0Y_TIPUNI')},NIL,NIL,.T. )
	oStruGrid:AddField(aColsSX3[1],aColsSX3[1],'D12TIPDES','C',aColsSX3[3],aColsSX3[4],NIL,{||.T.},NIL,NIL,{ || Posicione('D0Y',1,xFilial('D0Y')+D12->D12_UNIDES,'D0Y_TIPUNI')},NIL,NIL,.T. )

	oStruGrid:AddField(STR0004 ,STR0004 ,'D12_RECNO','C',9,0,NIL,NIL,NIL,NIL,NIL,NIL,.F.,.T.) // Registro ## Registro

	oStruD12:SetProperty("*",MODEL_FIELD_OBRIGAT,.F.)
	oStruGrid:SetProperty("*",MODEL_FIELD_OBRIGAT,.F.)

	If cOp332 == "6"
		oStruGrid:SetProperty("D12_ENDORI",MODEL_FIELD_VALID,FWBuildFeature( STRUCT_FEATURE_VALID, "StaticCall(WMSA332A,ValidField,A,B,C)" ))
		oStruGrid:SetProperty("D12_ENDDES",MODEL_FIELD_VALID,FWBuildFeature( STRUCT_FEATURE_VALID, "StaticCall(WMSA332A,ValidField,A,B,C)" ))

		oStruGrid:SetProperty("D12_ENDORI",MODEL_FIELD_WHEN,FWBuildFeature( STRUCT_FEATURE_WHEN, "StaticCall(WMSA332A,WhenField,A,B)" ))
		oStruGrid:SetProperty("D12_IDUNIT",MODEL_FIELD_WHEN,FWBuildFeature( STRUCT_FEATURE_WHEN, "StaticCall(WMSA332A,WhenField,A,B)" ))
		oStruGrid:SetProperty("D12_ENDDES",MODEL_FIELD_WHEN,FWBuildFeature( STRUCT_FEATURE_WHEN, "StaticCall(WMSA332A,WhenField,A,B)" ))
		oStruGrid:SetProperty("D12_UNIDES",MODEL_FIELD_WHEN,FWBuildFeature( STRUCT_FEATURE_WHEN, "StaticCall(WMSA332A,WhenField,A,B)" ))
		oStruGrid:SetProperty("D12_LOTECT",MODEL_FIELD_WHEN,FWBuildFeature( STRUCT_FEATURE_WHEN, "StaticCall(WMSA332A,WhenField,A,B)" ))
		oStruGrid:SetProperty("D12_NUMLOT",MODEL_FIELD_WHEN,FWBuildFeature( STRUCT_FEATURE_WHEN, "StaticCall(WMSA332A,WhenField,A,B)" ))
	EndIf
	oStruGrid:SetProperty("D12_RECHUM",MODEL_FIELD_VALID,FWBuildFeature( STRUCT_FEATURE_VALID, "Vazio() .Or. ExistCpo('DCD')" ))
	
	oStruGrid:AddTrigger("D12_RECHUM","D12NOMREC" ,{|| .T. },{|| Posicione('DCD',1,xFilial('DCD')+M->D12_RECHUM,'DCD_NOMFUN')  })
	oStruGrid:AddTrigger("D12_IDUNIT","D12TIPORI" ,{|| .T. },{|| Posicione('D0Y',1,xFilial('D0Y')+M->D12_IDUNIT,'D0Y_TIPUNI')  })
	oStruGrid:AddTrigger("D12_UNIDES","D12TIPDES" ,{|| .T. },{|| Posicione('D0Y',1,xFilial('D0Y')+M->D12_UNIDES,'D0Y_TIPUNI')  })

	oModel:AddFields('D12MASTER',/*cOwner*/,oStruD12)
	oModel:GetModel('D12MASTER'):SetOnlyView()
	oModel:GetModel('D12MASTER'):SetPrimaryKey( { 'D12_FILIAL','D12_DOC','D12_CLIFOR','D12_LOJA','D12_CARGA' } )
	oModel:AddGrid('D12DETAIL','D12MASTER', oStruGrid,,,,,{|oModelGrid| LoadGrid(oModelGrid) })
	oModel:GetModel('D12DETAIL'):SetNoDeleteLine(.T.)
	oModel:GetModel('D12DETAIL'):SetNoInsertLine(.T.)
	oModel:SetActivate({|oModel| oModel:LoadValue('D12DETAIL', 'D12_STATUS', oModel:GetValue('D12DETAIL', 'D12_STATUS'))})
Return oModel
/*--------------------------------------------------------------------------------
---ViewDef
---Funcao generica MVC do model
---Felipe Machado de Oliveira - 11/02/2014
----------------------------------------------------------------------------------*/
Static Function ViewDef()
Local oModel    := FWLoadModel( 'WMSA332A' )
Local oStruD12  := FWFormStruct( 2, 'D12', { |cCampo| AllTrim( cCampo ) $ CABECALHO } ,/*lViewUsado*/ )
Local oStruGrid := FWFormStruct( 2, 'D12', { |cCampo| AllTrim( cCampo ) $ GRID } ,/*lViewUsado*/ )
Local oView     := FWFormView():New()
Local aColsSX3  := {}
Local cOp332    := WmsOpc332()
Local lTrocaEnd := cOp332 == "6"

	oStruGrid:SetProperty("*",MVC_VIEW_ORDEM,"ZZ")

	//AddField
	// [01] C Nome do Campo
	// [02] C Ordem
	// [03] C Titulo do campo
	// [04] C Descrição do campo
	// [05] A Array com Help
	// [06] C Tipo do campo
	// [07] C Picture
	// [08] B Bloco de Picture Var
	// [09] C Consulta F3
	// [10] L Indica se o campo é editável
	// [11] C Pasta do campo
	// [12] C Agrupamento do campo
	// [13] A Lista de valores permitido do campo (Combo)
	// [14] N Tamanho Maximo da maior opção do combo
	// [15] C Inicializador de Browse
	// [16] L Indica se o campo é virtual
	// [17] C Picture Variável
	buscarSX3('D12_SERVIC',,@aColsSX3)
	oStruD12:AddField( 'D12SERVIC' ,'08',aColsSX3[1],aColsSX3[1],NIL,'C',aColsSX3[2],NIL,'',.F.,NIL,NIL,NIL,NIL,NIL,.T.,NIL)
	buscarSX3('D12_DESSER',,@aColsSX3)
	oStruD12:AddField( 'D12DESSER' ,'09',aColsSX3[1],aColsSX3[1],NIL,'C',aColsSX3[2],NIL,'',.F.,NIL,NIL,NIL,NIL,NIL,.T.,NIL)
	buscarSX3('D12_DESTAR',,@aColsSX3)
	oStruGrid:AddField( 'D12DESTAR','11',aColsSX3[1],aColsSX3[1],NIL,'C',aColsSX3[2],NIL,'',.F.,NIL,NIL,NIL,NIL,NIL,.T.,NIL)
	buscarSX3('D12_NOMREC',,@aColsSX3)
	oStruGrid:AddField( 'D12NOMREC','15',aColsSX3[1],aColsSX3[1],NIL,'C',aColsSX3[2],NIL,'',.F.,NIL,NIL,NIL,NIL,NIL,.T.,NIL)
	buscarSX3('D0Y_TIPUNI',,@aColsSX3)
	oStruGrid:AddField( 'D12TIPORI',IIf(lTrocaEnd,"04","35"),aColsSX3[1],aColsSX3[1],NIL,'C',aColsSX3[2],NIL,'',Nil,NIL,NIL,NIL,NIL,NIL,Nil,NIL)
	oStruGrid:AddField( 'D12TIPDES',IIf(lTrocaEnd,"08","39"),aColsSX3[1],aColsSX3[1],NIL,'C',aColsSX3[2],NIL,'',Nil,NIL,NIL,NIL,NIL,NIL,Nil,NIL)

	oStruGrid:SetProperty("*" ,MVC_VIEW_CANCHANGE,.F.)
	If cOp332 $ "4|5"
		oStruGrid:SetProperty("D12_DATINI",MVC_VIEW_CANCHANGE,.T.)
		oStruGrid:SetProperty("D12_HORINI",MVC_VIEW_CANCHANGE,.T.)
		oStruGrid:SetProperty("D12_DATFIM",MVC_VIEW_CANCHANGE,.T.)
		oStruGrid:SetProperty("D12_HORFIM",MVC_VIEW_CANCHANGE,.T.)
		oStruGrid:SetProperty("D12_RECHUM",MVC_VIEW_CANCHANGE,.T.)
	ElseIf cOp332 == "6"
		oStruGrid:SetProperty("D12_ENDORI",MVC_VIEW_CANCHANGE,.T.)
		oStruGrid:SetProperty("D12_IDUNIT",MVC_VIEW_CANCHANGE,.T.)
		oStruGrid:SetProperty("D12_ENDDES",MVC_VIEW_CANCHANGE,.T.)
		oStruGrid:SetProperty("D12_UNIDES",MVC_VIEW_CANCHANGE,.T.)
		oStruGrid:SetProperty("D12_LOTECT",MVC_VIEW_CANCHANGE,.T.)
		oStruGrid:SetProperty("D12_NUMLOT",MVC_VIEW_CANCHANGE,.T.)
		oStruGrid:SetProperty("D12TIPORI" ,MVC_VIEW_CANCHANGE,.F.)
		oStruGrid:SetProperty("D12TIPDES" ,MVC_VIEW_CANCHANGE,.F.)
	EndIf
	
	oStruGrid:SetProperty("D12_LOCORI" ,MVC_VIEW_ORDEM,IIf(lTrocaEnd,"01","32"))
	oStruGrid:SetProperty("D12_ENDORI" ,MVC_VIEW_ORDEM,IIf(lTrocaEnd,"02","33"))
	oStruGrid:SetProperty("D12_IDUNIT" ,MVC_VIEW_ORDEM,IIf(lTrocaEnd,"03","34"))
	oStruGrid:SetProperty("D12_LOCDES" ,MVC_VIEW_ORDEM,IIf(lTrocaEnd,"05","36"))
	oStruGrid:SetProperty("D12_ENDDES" ,MVC_VIEW_ORDEM,IIf(lTrocaEnd,"06","37"))
	oStruGrid:SetProperty("D12_UNIDES" ,MVC_VIEW_ORDEM,IIf(lTrocaEnd,"07","38"))

	oStruGrid:SetProperty("D12_TAREFA" ,MVC_VIEW_ORDEM,"10")
	oStruGrid:SetProperty("D12_ATIVID" ,MVC_VIEW_ORDEM,"12")
	oStruGrid:SetProperty("D12_DESATI" ,MVC_VIEW_ORDEM,"13")
	oStruGrid:SetProperty("D12NOMREC"  ,MVC_VIEW_ORDEM,"15")
	oStruGrid:SetProperty("D12_DATINI" ,MVC_VIEW_ORDEM,"16")
	oStruGrid:SetProperty("D12_HORINI" ,MVC_VIEW_ORDEM,"17")
	oStruGrid:SetProperty("D12_DATFIM" ,MVC_VIEW_ORDEM,"18")
	oStruGrid:SetProperty("D12_HORFIM" ,MVC_VIEW_ORDEM,"19")
	oStruGrid:SetProperty("D12_DOC"    ,MVC_VIEW_ORDEM,"20")
	oStruGrid:SetProperty("D12_SERIE"  ,MVC_VIEW_ORDEM,"21")
	oStruGrid:SetProperty("D12_CLIFOR" ,MVC_VIEW_ORDEM,"22")
	oStruGrid:SetProperty("D12_LOJA"   ,MVC_VIEW_ORDEM,"23")
	oStruGrid:SetProperty("D12_PRODUT" ,MVC_VIEW_ORDEM,"24")
	oStruGrid:SetProperty("D12_LOTECT" ,MVC_VIEW_ORDEM,"25")
	oStruGrid:SetProperty("D12_NUMLOT" ,MVC_VIEW_ORDEM,"26")
	oStruGrid:SetProperty("D12_NUMSER" ,MVC_VIEW_ORDEM,"27")
	oStruGrid:SetProperty("D12_QTDMOV" ,MVC_VIEW_ORDEM,"28")
	oStruGrid:SetProperty("D12_QTDMO2" ,MVC_VIEW_ORDEM,"29")
	oStruGrid:SetProperty("D12_QTDLID" ,MVC_VIEW_ORDEM,"30")
	oStruGrid:SetProperty("D12_QTDLI2" ,MVC_VIEW_ORDEM,"31")

	oStruGrid:SetProperty("D12_RECHUM" ,MVC_VIEW_LOOKUP,"DCD")
	oStruGrid:SetProperty("D12_IDUNIT" ,MVC_VIEW_LOOKUP,"D0Y")
	oStruGrid:SetProperty("D12TIPORI"  ,MVC_VIEW_LOOKUP,"D0T")
	oStruGrid:SetProperty("D12_UNIDES" ,MVC_VIEW_LOOKUP,"D0Y")
	oStruGrid:SetProperty("D12TIPDES"  ,MVC_VIEW_LOOKUP,"D0T")
	oView:SetModel(oModel)
	oView:AddField('VIEW_D12',oStruD12,'D12MASTER')
	oView:AddGrid('VIEW_GRID',oStruGrid,'D12DETAIL')
	oView:CreateHorizontalBox('FIELDSD12',20)
	oView:CreateHorizontalBox('GRIDD12',80)

	oView:SetOwnerView('VIEW_D12','FIELDSD12')
	oView:SetOwnerView('VIEW_GRID','GRIDD12')

	oView:SetCloseOnOk({||.T.})
Return oView
/*--------------------------------------------------------------------------------
---LoadGrid
---Carrega o modelo de dados
---Felipe Machado de Oliveira - 04/11/2015
----------------------------------------------------------------------------------*/
Static Function LoadGrid(oModelGrid)
Local oStructD12 := oModelGrid:GetStruct()
Local aCamposD12 := aClone(oStructD12:GetFields())
Local cQuery     := ""
Local cAliasQry  := GetNextAlias()
Local aLinhas    := {}
Local nX         := 0
Local nReg       := 0
Local cHoraIni   := SubStr(Time(),1,TamSX3("D12_HORINI")[1])
Local cHoraFim   := SubStr(Time(),1,TamSX3("D12_HORFIM")[1])
Local cOp332     := WmsOpc332()
Local cAcao332   := WmsAcao332()
Local cRecHum    := ""
Local cIdUnit    := ""
Local cUniDes    := ""
Local lWM330RHM  := ExistBlock('WM330RHM')

	// Cria as temporárias da unitização - FORA DA TRANSAÇÃO
	WMSCTPENDU()
	// Cria tabela temporária da execução automática - FORA DA TRANSAÇÃO
	WMSCTPRGCV()
	oMovimento:GoToD12(D12->(Recno()))
	cQuery := "SELECT D12.D12_TAREFA,"
	cQuery +=       " D12.D12_ATIVID,"
	cQuery +=       " D12.D12_RECHUM,"
	cQuery +=       " D12.D12_DATINI,"
	cQuery +=       " D12.D12_HORINI,"
	cQuery +=       " D12.D12_DATFIM,"
	cQuery +=       " D12.D12_HORFIM,"
	cQuery +=       " D12.D12_DOC,"
	cQuery +=       " D12.D12_SERIE,"
	cQuery +=       " D12.D12_CLIFOR,"
	cQuery +=       " D12.D12_LOJA,"
	cQuery +=       " D12.D12_PRODUT,"
	cQuery +=       " D12.D12_LOTECT,"
	cQuery +=       " D12.D12_NUMLOT,"
	cQuery +=       " D12.D12_NUMSER,"
	cQuery +=       " D12.D12_QTDMOV,"
	cQuery +=       " D12.D12_QTDMO2,"
	cQuery +=       " D12.D12_LOCORI,"
	cQuery +=       " D12.D12_ENDORI,"
	cQuery +=       " D12.D12_IDUNIT,"
	cQuery +=       " D12.D12_LOCDES,"
	cQuery +=       " D12.D12_ENDDES,"
	cQuery +=       " D12.D12_UNIDES,"
	cQuery +=       " D12.D12_STATUS,"
	cQuery +=       " D12.D12_QTDLID,"
	cQuery +=       " D12.D12_QTDLI2,"
	cQuery +=       " D12.D12_RADIOF,"
	cQuery +=       " D12.R_E_C_N_O_ D12_RECNO"
	cQuery +=  " FROM "+RetSqlName('D12')+" D12"
	cQuery += " WHERE D12.D12_FILIAL = '"+xFilial("D12")+"'"
	If cAcao332 $ "1|4"
		cQuery +=   " AND D12.R_E_C_N_O_ = "+Str(oMovimento:GetRecno())
	Else
		cQuery +=   " AND D12.D12_SERVIC = '"+oMovimento:oMovServic:GetServico()+"'"
		// Avalia Status
		If cOp332 == "1"
			cQuery +=   " AND D12.D12_STATUS IN ('3','4')"
		ElseIf cOp332 == "2"
			cQuery +=   " AND D12.D12_STATUS IN ('2','3')"
		ElseIf cOp332 $ "4|5"
			cQuery +=   " AND D12.D12_STATUS IN ('2','3','4')"
		EndIf
		If cAcao332 == "2"
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
	EndIf
	cQuery += " AND D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY D12.D12_ORDTAR, D12.D12_ORDATI"
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .T., .T. )

	TCSetField(cAliasQry,"D12_DATINI", "D",8,0)
	TCSetField(cAliasQry,"D12_DATFIM", "D",8,0)

	If (cAliasQry)->(Eof())
		aAdd(aLinhas,{++nReg,Array(Len(aCamposD12))})

	Else
		Do While !(cAliasQry)->(Eof())

			aAdd(aLinhas,{++nReg,Array(Len(aCamposD12))})

			oMovimento:GoToD12((cAliasQry)->D12_RECNO)
			cRecHum := (cAliasQry)->D12_RECHUM
			cIdUnit := (cAliasQry)->D12_IDUNIT
			cUniDes := (cAliasQry)->D12_UNIDES

			For nX := 1 To Len(aCamposD12)
				If (cAliasQry)->(FieldPos(aCamposD12[nX][MODEL_FIELD_IDFIELD])) > 0 // Caso o campo exista no SELECT, do contrário é virtual
					aLinhas[nReg][2][nX] := (cAliasQry)->&(aCamposD12[nX][MODEL_FIELD_IDFIELD])
				ElseIf aCamposD12[nX][MODEL_FIELD_IDFIELD] $ ("D12_DESATI")
					aLinhas[nReg][2][nX] := Tabela("L3",(cAliasQry)->D12_ATIVID,.F.)
				ElseIf aCamposD12[nX][MODEL_FIELD_IDFIELD] $ ("D12DESTAR")
					aLinhas[nReg][2][nX] := Tabela('L4',oMovimento:oMovServic:GetServico(),.F.)
				EndIf

				If aCamposD12[nX][MODEL_FIELD_IDFIELD] $ ("D12_STATUS")
					If cOp332 == "1"
						aLinhas[nReg][2][nX] := "2"
					ElseIf cOp332 == "2"

						aLinhas[nReg][2][nX] := "4"
					ElseIf cOp332 $ "4|5"
						aLinhas[nReg][2][nX] := "1"
					EndIf
				ElseIf aCamposD12[nX][MODEL_FIELD_IDFIELD] $ ("D12_DATFIM")
					If cOp332 == "2"
						aLinhas[nReg][2][nX] := CtoD('  /  /  ')
					ElseIf cOp332 == "4"
						aLinhas[nReg][2][nX] := dDataBase
					ElseIf cOp332 == "5"
						aLinhas[nReg][2][nX] := IIf(!Empty(mv_par04),mv_par04,dDataBase)
					EndIf
				ElseIf aCamposD12[nX][MODEL_FIELD_IDFIELD] $ ("D12_HORFIM")
					If cOp332 == "2"
						aLinhas[nReg][2][nX] := ""
					ElseIf cOp332 == "4"
						aLinhas[nReg][2][nX] := cHoraFim
					ElseIf cOp332 == "5"
						aLinhas[nReg][2][nX] := IIf(!Empty(StrTran(mv_par06,":")),mv_par06,cHoraFim)
					EndIf
				ElseIf aCamposD12[nX][MODEL_FIELD_IDFIELD] $ ("D12_RECHUM")
					If cOp332 == "2" .And. !WmsReHu332()
						cRecHum := ""
						If lWM330RHM
							ExecBlock('WM330RHM',.F.,.F.,{ (cAliasQry)->D12_RECHUM })
						EndIf
					ElseIf cOp332 == "4" .And. Empty(aLinhas[nReg][2][nX])
						cRecHum := __cUserId
					ElseIf cOp332 == "5"
						If !Empty(mv_par02)
							cRecHum := mv_par02
						EndIf
					EndIf
					aLinhas[nReg][2][nX] := cRecHum
				ElseIf aCamposD12[nX][MODEL_FIELD_IDFIELD] $ ("D12NOMREC")
					aLinhas[nReg][2][nX] := Posicione('DCD',1,xFilial('DCD')+cRecHum,'DCD_NOMFUN')
				ElseIf aCamposD12[nX][MODEL_FIELD_IDFIELD] $ ("D12TIPORI")
					aLinhas[nReg][2][nX] := Posicione('D0Y',1,xFilial('D0Y')+cIdUnit,'D0Y_TIPUNI')
				ElseIf aCamposD12[nX][MODEL_FIELD_IDFIELD] $ ("D12TIPDES")
					aLinhas[nReg][2][nX] := Posicione('D0Y',1,xFilial('D0Y')+cUniDes,'D0Y_TIPUNI')
				ElseIf aCamposD12[nX][MODEL_FIELD_IDFIELD] $ ("D12_QTDLID")
					If cOp332 == "2" .And. ((oMovimento:oMovServic:ChkConfer() .And. !WmsQtCf332()) .Or. (!WmsReHu332() .And. !oMovimento:oMovServic:ChkConfer() .And. oMovimento:IsMovUnit()))
						aLinhas[nReg][2][nX] := 0
					ElseIf cOp332 $ "4|5"
						aLinhas[nReg][2][nX] := IIf(cAcao332 <> '4',oMovimento:GetQtdMov(),oMovimento:GetQtdLid())
					EndIf
				ElseIf aCamposD12[nX][MODEL_FIELD_IDFIELD] $ ("D12_QTDLI2")
					If cOp332 == "2" .And. ((oMovimento:oMovServic:ChkConfer() .And. !WmsQtCf332()) .Or. (!WmsReHu332() .And. !oMovimento:oMovServic:ChkConfer() .And. oMovimento:IsMovUnit()))
						aLinhas[nReg][2][nX] := 0
					ElseIf cOp332 $ "4|5"
						aLinhas[nReg][2][nX] := ConvUm(oMovimento:oMovPrdLot:GetProduto(),IIf(cAcao332 <> '4',oMovimento:GetQtdMov(),oMovimento:GetQtdLid()),0,2)
					EndIf
				ElseIf aCamposD12[nX][MODEL_FIELD_IDFIELD] $ ("D12_RADIOF")
					aLinhas[nReg][2][nX] := IIf(cOp332 $ "4|5","2",oMovimento:GetRadioF())
				ElseIf aCamposD12[nX][MODEL_FIELD_IDFIELD] $ ("D12_DATINI")
					If cOp332 == "4"
						aLinhas[nReg][2][nX] := dDataBase
					ElseIf cOp332 == "5"
						aLinhas[nReg][2][nX] := IIf(!Empty(mv_par03),mv_par03,dDataBase)
					EndIf
				ElseIf aCamposD12[nX][MODEL_FIELD_IDFIELD] $ ("D12_HORINI")
					If cOp332 == "4"
						aLinhas[nReg][2][nX] := cHoraIni
					ElseIf cOp332 == "5"
						aLinhas[nReg][2][nX] := IIf(!Empty(StrTran(mv_par05,":")),mv_par05,cHoraIni)
					EndIf
				EndIf
			Next nX

			(cAliasQry)->(dbSkip())
		EndDo
	EndIf
	(cAliasQry)->(dbCloseArea())

Return aLinhas
/*--------------------------------------------------------------------------------
---PosVal
---Pós validação do modelo de dados equivale ao TodoOk
---Felipe Machado de Oliveira - 11/02/2014
----------------------------------------------------------------------------------*/
Static Function PosVal(oModel)
Local lRet       := .T.
Local lConsMov   := .F.
Local nI         := 0
Local oModelGrid := oModel:GetModel('D12DETAIL')
Local cOp332     := WmsOpc332()
	If cOp332 $ "4|5"
		For nI := 1 To oModelGrid:Length()
			oModelGrid:GoLine(nI)
			If Empty(oModelGrid:GetValue("D12_RECHUM",nI))
				oModel:GetModel():SetErrorMessage(,,oModelGrid:GetId(),,WMSA332A01,WmsFmtMsg(STR0001,{{"[VAR01]",buscarSX3('D12_RECHUM')}})) // O campo [VAR01] não foi preenchido!
				lRet := .F.
				Exit
			EndIf
			If oModelGrid:GetValue("D12_DATINI",nI) > dDatabase .Or. oModelGrid:GetValue("D12_DATFIM",nI) > dDatabase
				oModel:GetModel():SetErrorMessage(,,oModelGrid:GetId(),,WMSA332A07,STR0019) // Data inicial e final não devem ser maiores que a data atual!
				lRet := .F.
				Exit
			EndIf
			If oModelGrid:GetValue("D12_DATINI",nI) > oModelGrid:GetValue("D12_DATFIM",nI)
				oModel:GetModel():SetErrorMessage(,,oModelGrid:GetId(),,WMSA332A02,STR0002) // Data inicial deve ser menor que data final!
				lRet := .F.
				Exit
			EndIf
			If oModelGrid:GetValue("D12_DATINI",nI) == oModelGrid:GetValue("D12_DATFIM",nI)
				If oModelGrid:GetValue("D12_HORINI",nI) > oModelGrid:GetValue("D12_HORFIM",nI)
					oModel:GetModel():SetErrorMessage(,,oModelGrid:GetId(),,WMSA332A03,STR0003) // Data inicial deve ser menor que data final!
					lRet := .F.
					oModelGrid:GoLine(nI)
					Exit
				EndIf
			EndIf
			If oModelGrid:GetValue("D12_DATINI",nI) == dDatabase .And. oModelGrid:GetValue("D12_HORINI",nI) > Time()
				oModel:GetModel():SetErrorMessage(,,oModelGrid:GetId(),,WMSA332A08,STR0020) // Hora inicial não deve ser maior que a hora atual!
				lRet := .F.
				Exit
			EndIf
			If oModelGrid:GetValue("D12_DATFIM",nI) == dDatabase .And. oModelGrid:GetValue("D12_HORFIM",nI) > Time()
				oModel:GetModel():SetErrorMessage(,,oModelGrid:GetId(),,WMSA332A09,STR0021) // Hora final não deve ser maior que a hora atual!
				lRet := .F.
				Exit
			EndIf
		Next nI
	ElseIf cOp332 == "6"
		For nI := 1 To oModelGrid:Length()
			oModelGrid:GoLine(nI)

			// Posiciona no movimento e chama o ChkEndDes ou ChkEndOri
			oMovimento:GoToD12(oModelGrid:GetValue("D12_RECNO"))
			oMovimento:SetQuant(oModelGrid:GetValue("D12_QTDMOV"))

			If (oMovimento:oMovServic:ChkRecebi(); // Endereçamento, Crossdocking
				.Or. oMovimento:oMovServic:ChkTransf()) // Transferencia // Desfragmentação(Transferencia)
				lConsMov := !(oMovimento:oMovEndDes:GetEnder() == oModelGrid:GetValue("D12_ENDDES") .And. oMovimento:GetIdUnit() == oModelGrid:GetValue("D12_UNIDES"))
				oMovimento:oMovEndDes:SetEnder(oModelGrid:GetValue("D12_ENDDES"))
				If !oMovimento:oMovEndDes:LoadData()
					oModel:GetModel():SetErrorMessage(,,oModelGrid:GetId(),,WMSA332A20,oMovimento:oMovEndDes:GetErro())
					lRet := .F.
				EndIf
				If lRet
					oMovimento:SetUniDes(oModelGrid:GetValue("D12_UNIDES"))
					oMovimento:SetTipUni(oModelGrid:GetValue("D12TIPDES"))
					If lConsMov .And. oMovimento:oMovEndDes:IsArmzUnit() .And. !oMovimento:DesNotUnit() .And. Empty(oMovimento:GetUniDes())
						If !(oMovimento:oMovEndDes:GetTipoEst() == 2 .Or. oMovimento:oMovEndDes:GetTipoEst() == 7 .Or. oMovimento:oMovEndDes:GetTipoEst() == 8)
							oModel:GetModel():SetErrorMessage(,,oModelGrid:GetId(),,WMSA332A16,STR0032,STR0031) // Unitizador destino não informado! // Informe o unitizador
							lRet := .F.
						Else
							oModel:GetModel():SetErrorMessage(,,oModelGrid:GetId(),,WMSA332A17,oMovimento:oMovEndDes:GetErro())
							lRet := .F.
						EndIf
					EndIf
					If lRet .And. !oMovimento:ChkEndDes(lConsMov)
						oModel:GetModel():SetErrorMessage(,,oModelGrid:GetId(),,WMSA332A04,oMovimento:GetErro())
						lRet := .F.
					EndIf
					If lRet
						If (oMovimento:oMovEndOri:GetArmazem()+oMovimento:oMovEndOri:GetEnder() == oMovimento:oMovEndDes:GetArmazem()+oMovimento:oMovEndDes:GetEnder())
							oModel:GetModel():SetErrorMessage  (,,oModelGrid:GetId(),,WMSA332A10,STR0027,STR0030) // Movimentações de endereçamento ou transferência não podem ter endereço origem e destino iguais! // Informe o endereço origem diferente do endereço destino.
							lRet := .F.
						EndIf
					EndIf 
				EndIf
			ElseIf (oMovimento:oMovServic:ChkSepara(); // Apanhe
				.Or. oMovimento:oMovServic:ChkReabast()) // (Re)Abastecimento
				//Valida se o endereço, lote ou sub-lote foi informado na inclusão do pedido de venda
				If !(lRet := WMSV030VTL(oMovimento,oModelGrid:GetValue("D12_LOTECT"),oModelGrid:GetValue("D12_NUMLOT"),oModelGrid:GetValue("D12_ENDORI")))
					oModel:GetModel():SetErrorMessage(,,oModelGrid:GetId(),,WMSA332A23,oMovimento:GetErro(),STR0036) //Estorne a O.S. WMS e altere o pedido de venda.
				EndIf
				//Valida se trata-se de um produto x componente e impede a alteração do lote e sub-lote
				If lRet .And. (!(oMovimento:oMovPrdLot:GetLoteCtl() == oModelGrid:GetValue("D12_LOTECT")) .Or. !(oMovimento:oMovPrdLot:GetNumLote() == oModelGrid:GetValue("D12_NUMLOT")));
				   .And. !(oMovimento:oMovPrdLot:GetProduto() == oMovimento:oMovPrdLot:GetPrdOri())
					oModel:GetModel():SetErrorMessage(,,oModelGrid:GetId(),,WMSA332A22,STR0037) //Para produtos componentes não é permitida a troca de lote.
					lRet := .F.
				EndIf	
				If lRet
					lConsMov := !(oMovimento:oMovEndOri:GetEnder() == oModelGrid:GetValue("D12_ENDORI") .And. oMovimento:GetIdUnit() == oModelGrid:GetValue("D12_IDUNIT") .And. oMovimento:oMovPrdLot:GetLoteCtl() == oModelGrid:GetValue("D12_LOTECT") .And. oMovimento:oMovPrdLot:GetNumLote() == oModelGrid:GetValue("D12_NUMLOT"))
					oMovimento:oMovEndOri:SetEnder(oModelGrid:GetValue("D12_ENDORI"))
					If !oMovimento:oMovEndOri:LoadData()
						oModel:GetModel():SetErrorMessage(,,oModelGrid:GetId(),,WMSA332A21,oMovimento:oMovEndOri:GetErro())
						lRet := .F.
					EndIf
				EndIf
				If lRet
					oMovimento:SetIdUnit(oModelGrid:GetValue("D12_IDUNIT"))
					oMovimento:SetTipUni(oModelGrid:GetValue("D12TIPORI"))
					oMovimento:oMovPrdLot:SetLoteCtl(oModelGrid:GetValue("D12_LOTECT"))
					oMovimento:oMovPrdLot:SetNumLote(oModelGrid:GetValue("D12_NUMLOT"))
					If lConsMov .And. oMovimento:oMovEndOri:IsArmzUnit() .And. !oMovimento:OriNotUnit() .And. Empty(oMovimento:GetIdUnit())
						If !(oMovimento:oMovEndOri:GetTipoEst() == 2 .Or. oMovimento:oMovEndOri:GetTipoEst() == 7 .Or. oMovimento:oMovEndOri:GetTipoEst() == 8)
							oModel:GetModel():SetErrorMessage(,,oModelGrid:GetId(),,WMSA332A18,STR0033,STR0031) // Unitizador origem não informado! // Informe o unitizador
							lRet := .F.
						EndIf
					EndIf
					If lRet .And. !oMovimento:ChkEndOri(!lConsMov)
						oModel:GetModel():SetErrorMessage(,,oModelGrid:GetId(),,WMSA332A11,oMovimento:GetErro(),STR0038) //Reavalie as informações alteradas.
						lRet := .F.
					EndIf
					If lRet
						If !oMovimento:oMovServic:ChkSepara() .And. (oMovimento:oMovEndOri:GetArmazem()+oMovimento:oMovEndOri:GetEnder() == oMovimento:oMovEndDes:GetArmazem()+oMovimento:oMovEndDes:GetEnder())
							oModel:GetModel():SetErrorMessage(,,oModelGrid:GetId(),,WMSA332A12,STR0028,STR0029) // Movimentações de reabastecimento  não podem ter endereço origem e destino iguais! //Informe um endereço destino diferente do endereço origem.
							lRet := .F.
						EndIf 
					EndIf
				EndIf
			EndIf
		Next nI
	EndIf
Return lRet

Static Function WhenField(oModel,cField)
Local lRet      := .F.
Local aAreaD12  := D12->(GetArea())
Local oMdlForm  := FWModelActive()
Local oMovAux   := WMSDTCMovimentosServicoArmazem():New()
Local lEstUnit  := .F.

	oMovAux:oMovServic:SetServico(oMdlForm:GetModel("D12MASTER"):GetValue("D12_SERVIC"))
	oMovAux:oMovServic:SetOrdem(oMdlForm:GetModel("D12MASTER"):GetValue("D12_ORDTAR"))
	oMovAux:oMovServic:LoadData()

	If !oMovAux:oMovServic:ChkConfer() // Caso serviço tenha operação de conferencia de entrada, conferencia de saida
		// Verifica se estrutura é unitizada
		If cField $ "D12_IDUNIT"
			oMovAux:oMovEndOri:SetArmazem(oModel:GetValue("D12_LOCORI"))
			oMovAux:oMovEndOri:SetEnder(oModel:GetValue("D12_ENDORI"))
			oMovAux:oMovEndOri:LoadData()
			// Se o novo endereço é unitizado, deve gravar o unitizador
			If oMovAux:oMovEndOri:IsArmzUnit() .And. !oMovAux:OriNotUnit()
				lEstUnit := .T.
			EndIf
		ElseIf cField $ "D12_UNIDES"
			oMovAux:oMovEndDes:SetArmazem(oModel:GetValue("D12_LOCDES"))
			oMovAux:oMovEndDes:SetEnder(oModel:GetValue("D12_ENDDES"))
			oMovAux:oMovEndDes:LoadData()
			// Se o novo endereço é unitizado, deve gravar o unitizador
			If oMovAux:oMovEndDes:IsArmzUnit() .And. !oMovAux:DesNotUnit()
				lEstUnit := .T.
			EndIf
		EndIf
		// Valida campo para permitir edição
		If cField == "D12_ENDORI" 
			lRet := oMovAux:oMovServic:ChkSepara() .Or. oMovAux:oMovServic:ChkReabast()
		ElseIf cField == "D12_LOTECT" 
			lRet := Rastro(oModel:GetValue("D12_PRODUT")) .And. (oMovAux:oMovServic:ChkSepara() .Or. oMovAux:oMovServic:ChkReabast())
		ElseIf cField == "D12_NUMLOT"
			lRet := Rastro(oModel:GetValue("D12_PRODUT"),"S") .And. (oMovAux:oMovServic:ChkSepara() .Or. oMovAux:oMovServic:ChkReabast())
		ElseIf cField == "D12_IDUNIT"
			lRet := lEstUnit .And. oMovAux:oMovServic:ChkSepara() .Or. oMovAux:oMovServic:ChkReabast()
		ElseIf cField == "D12_ENDDES"
			lRet := oMovAux:oMovServic:ChkRecebi() .Or. oMovAux:oMovServic:ChkTransf()
		ElseIf cField == "D12_UNIDES"
			lRet := lEstUnit .And. (oMovAux:oMovServic:ChkTransf() .Or. (oMovAux:oMovServic:ChkRecebi() .And. Empty(oModel:GetValue("D12_IDUNIT"))))
		EndIf
	EndIf
	oMovAux:Destroy()
	RestArea(aAreaD12)
Return lRet

Static Function ValidField(oModel,cField,xValue)
Local aAreaD12  := D12->(GetArea())
Local oView     := FwViewActive()
Local oMovAux   := WMSDTCMovimentosServicoArmazem():New()
Local lRet      := .T.

	// Posiciona no movimento e chama o ChkEndDes ou ChkEndOri
	oMovimento:GoToD12(oModel:GetValue("D12_RECNO"))
	oMovimento:SetQuant(oModel:GetValue("D12_QTDMOV"))
	
	If cField == "D12_ENDORI"
		oMovimento:oMovEndOri:SetEnder(xValue)
		If !oMovimento:ChkEndOri(,,.F.)
			oModel:GetModel():SetErrorMessage(oModel:GetId(),cField,,,WMSA332A13,oMovimento:GetErro()) 
			lRet := .F.
		EndIf
		If lRet
			If !oMovimento:oMovServic:ChkSepara() .And. (oMovimento:oMovEndOri:GetArmazem()+oMovimento:oMovEndOri:GetEnder() == oMovimento:oMovEndDes:GetArmazem()+oMovimento:oMovEndDes:GetEnder())
				oModel:GetModel():SetErrorMessage(oModel:GetId(),cField,,,WMSA332A05,STR0028,STR0029) // Movimentações de reabastecimento  não podem ter endereço origem e destino iguais! // Informe o endereço origem diferente do endereço destino.
				lRet := .F.
			EndIf 
		EndIf
		If lRet
			oMovAux:oMovEndOri:SetArmazem(oModel:GetValue("D12_LOCORI"))
			oMovAux:oMovEndOri:SetEnder(oModel:GetValue("D12_ENDORI"))
			oMovAux:oMovEndOri:LoadData()
			// Se o novo endereço é unitizado, deve gravar o unitizador
			If oMovAux:OriNotUnit()
				oModel:LoadValue("D12_IDUNIT","")
				oModel:LoadValue("D12TIPORI","")
			EndIf
			If !lAutomato
				oView:GetModel():LMODIFY := .T.
				oView:LMODIFY := .T.
				oView:Refresh("VIEW_GRID")
			EndIf
			oMovAux:Destroy()
		EndIf
	ElseIf cField == "D12_ENDDES"
		oMovimento:oMovEndDes:SetEnder(xValue)
		If !oMovimento:ChkEndDes(,.F.)
			oModel:GetModel():SetErrorMessage(oModel:GetId(),cField,,,WMSA332A06,oMovimento:GetErro())
			lRet := .F.
		EndIf
		If lRet
			If !oMovimento:oMovServic:ChkSepara() .And. (oMovimento:oMovEndOri:GetArmazem()+oMovimento:oMovEndOri:GetEnder() == oMovimento:oMovEndDes:GetArmazem()+oMovimento:oMovEndDes:GetEnder())
				oModel:GetModel():SetErrorMessage(oModel:GetId(),cField,,,WMSA332A14,STR0027,STR0030) // Movimentações de endereçamento ou transferência não podem ter endereço origem e destino iguais! // Informe o endereço destino diferente do endereço origem.
				lRet := .F.
			EndIf 
		EndIf
		If lRet
			oMovAux:oMovEndDes:SetArmazem(oModel:GetValue("D12_LOCDES"))
			oMovAux:oMovEndDes:SetEnder(oModel:GetValue("D12_ENDDES"))
			oMovAux:oMovEndDes:LoadData()
			// Se o novo endereço é unitizado, deve gravar o unitizador
			If oMovAux:DesNotUnit()
				oModel:LoadValue("D12_UNIDES","")
				oModel:LoadValue("D12TIPDES","")
			ElseIf Empty(oModel:GetValue("D12_UNIDES")) .And. oMovimento:IsMovUnit()
				oModel:LoadValue("D12_UNIDES",oModel:GetValue("D12_IDUNIT"))
				oModel:LoadValue("D12TIPDES",Posicione('D0Y',1,xFilial('D0Y')+oModel:GetValue("D12_UNIDES"),'D0Y_TIPUNI'))
			EndIf
			If !lAutomato
				oView:GetModel():LMODIFY := .T.
				oView:LMODIFY := .T.
				oView:Refresh("VIEW_GRID")
			EndIf
			oMovAux:Destroy()
		EndIf
	EndIf
	RestArea(aAreaD12)
Return lRet
//-------------------------------------------------------------------//
//------------Força a modificação do model para o commit-------------//
//-------------------------------------------------------------------//
Static Function BeforeCMdl(oModel)
	If oModel:GetOperation() == MODEL_OPERATION_UPDATE
		oModel:LMODIFY := .T.
	EndIf
Return .T.
/*--------------------------------------------------------------------------------
---GravaDados
---Finalização das movimentações
---Felipe Machado de Oliveira - 11/02/2014
----------------------------------------------------------------------------------*/
Static Function GravaDados(oModel)
Local oProcess := Nil
	If !lAutomato
		oProcess := MsNewProcess():New( { || Finalizar(oModel,oProcess) }, STR0005, STR0006 + "...", .F. ) // Finalizando // Aguarde iniciar o processamento
		oProcess:Activate()
	Else
		Finalizar(oModel,oProcess)
	EndIf
Return .T.

Static Function Finalizar(oModel,oProcess)
Local lRet       := .T.
Local lLog       := .F.
Local oModelGrid := oModel:GetModel('D12DETAIL')
Local cOp332     := WmsOpc332()
Local cAcao332   := WmsAcao332()
Local cNomUsua   := ""
Local cTrava     := ""
Local nTipoConv  := SuperGetMV('MV_TPCONVO', .F., 1) // 1=Por Atividade/2=Por Tarefa
Local nI         := 0
Local dDataFec   := DToS(WmsData())
Local oRegraConv := Nil
Local oEtiqUnit  := Nil

	If cOp332 $ "1|2"
		oRegraConv := WMSBCCRegraConvocacao():New()
		oRegraConv:oMovimento := oMovimento
		oRegraConv:oOrdServ   := oMovimento:oOrdServ
		oRegraConv:oMovServic := oMovimento:oMovServic
		oRegraConv:oMovTarefa := oMovimento:oMovTarefa
		oRegraConv:oMovPrdLot := oMovimento:oMovPrdLot
		oRegraConv:oMovEndOri := oMovimento:oMovEndOri
		oRegraConv:oMovEndDes := oMovimento:oMovEndDes
	EndIf

	aMensagem := {}
	If !lAutomato
		oProcess:SetRegua1( oModelGrid:Length() )
	EndIf
	If lRet := WMSTrava(1,@cTrava,oMovimento:oOrdServ:GetCarga(),oMovimento:oOrdServ:GetDocto(),"")
		For nI := 1 To oModelGrid:Length()
			Begin Transaction
				lLog := .F.
				lRet := .T.
				oModelGrid:GoLine(nI)
				// Posiciona no D12
				oMovimento:GoToD12(oModelGrid:GetValue("D12_RECNO"))
				If oMovimento:LockD12()
					// Reiniciar/ Bloquear / Finalizar / Troca Endereço não considerar movimentos já finalizados ou cancelados para atualização
					If !oMovimento:GetStatus() $ '0|1'
						cNomUsua := UsrRetName(oMovimento:GetRecHum())
						If !oMovimento:oMovServic:ChkConfer() .And. oMovimento:GetStatus() == "3" .And. !Empty(cNomUsua) .And. WmsUsrRot(cNomUsua) // Valida se usuário da movimentação está na convocação ativa.
							If !lAutomato
								oProcess:IncRegua2( WmsFmtMsg(STR0015 + "...",{{"[VAR01]",cNomUsua}})) // Atividade encontra-se em execução pelo usuário [VAR01].
							EndIf
							Aadd(aMensagem, WmsFmtMsg(STR0017,{{"[VAR01]",oMovimento:oOrdServ:GetDocto()+Iif(!Empty(oMovimento:oOrdServ:GetSerie()),"/"+AllTrim(oMovimento:oOrdServ:GetSerie()),'')},{"[VAR02]",oMovimento:oOrdServ:oProdLote:GetProduto()},{"[VAR03]",oMovimento:GetIdDCF()},{"[VAR04]",oMovimento:GetIdMovto()},{"[VAR05]",oMovimento:GetIdOpera()}}) + CLRF +WmsFmtMsg(STR0015,{{"[VAR01]",cNomUsua}})) // SIGAWMS - OS [VAR01] - Produto: [VAR02] - Id. OS: [VAR03] - Id. Movimento: [VAR04] - Id. Operação: [VAR05].
							lRet := .F.
						EndIf
						If lRet
							If !lAutomato
								oProcess:IncRegua1( WmsFmtMsg(STR0007 + "...",{{"[VAR01]",oMovimento:oOrdServ:GetDocto()}}) ) // Processando documento: [VAR01]
								oProcess:SetRegua2( 4 )
								oProcess:IncRegua2( WmsFmtMsg(STR0008 + "...",{{"[VAR01]",oMovimento:oMovPrdLot:GetProduto()},{"[VAR02]",AllTrim(Str(oMovimento:GetQtdMov()))}}) ) // Atualizando produto: [VAR01] quantidade: [VAR02]
							EndIf
							// Validações antes da atualização e finalização dos movimentos
							If cOp332 $ "4|5" .And. oModelGrid:GetValue("D12_QTDLID") > 0 .And. !oMovimento:ChkFinMov(aMensagem,oModelGrid:GetValue("D12_QTDLID"))
								lLog := .T.
								lRet := .F.
							EndIf
							// Valida se movimento possui dependencia
							If lRet .And. oMovimento:oOrdServ:ChkDepPend()
								Aadd(aMensagem, WmsFmtMsg(STR0017,{{"[VAR01]",oMovimento:oOrdServ:GetDocto()+Iif(!Empty(oMovimento:oOrdServ:GetSerie()),"/"+AllTrim(oMovimento:oOrdServ:GetSerie()),'')},{"[VAR02]",oMovimento:oOrdServ:oProdLote:GetProduto()},{"[VAR03]",oMovimento:GetIdDCF()},{"[VAR04]",oMovimento:GetIdMovto()},{"[VAR05]",oMovimento:GetIdOpera()}}) + CLRF + oMovimento:oOrdServ:GetErro()) // SIGAWMS - OS [VAR01] - Produto: [VAR02] - Id. OS: [VAR03] - Id. Movimento: [VAR04] - Id. Operação: [VAR05].
								lRet := .F.
							EndIf
							If lRet .And. cOp332 $ "4|5" .And. !StaticCall(WMSV001,ChkExecAnt,oMovimento,nTipoConv,dDataFec)
								Aadd(aMensagem, WmsFmtMsg(STR0017,{{"[VAR01]",oMovimento:oOrdServ:GetDocto()+Iif(!Empty(oMovimento:oOrdServ:GetSerie()),"/"+AllTrim(oMovimento:oOrdServ:GetSerie()),'')},{"[VAR02]",oMovimento:oOrdServ:oProdLote:GetProduto()},{"[VAR03]",oMovimento:GetIdDCF()},{"[VAR04]",oMovimento:GetIdMovto()},{"[VAR05]",oMovimento:GetIdOpera()}}) + CLRF + STR0022) // SIGAWMS - OS [VAR01] - Produto: [VAR02] - Id. OS: [VAR03] - Id. Movimento: [VAR04] - Id. Operação: [VAR05]. //Atividade anterior ainda não executada.
								lRet := .F.
							EndIf
							If lRet .And. cOp332 == "6" .And. !oMovimento:AllMovPend()
								Aadd(aMensagem, WmsFmtMsg(STR0017,{{"[VAR01]",oMovimento:oOrdServ:GetDocto()+Iif(!Empty(oMovimento:oOrdServ:GetSerie()),"/"+AllTrim(oMovimento:oOrdServ:GetSerie()),'')},{"[VAR02]",oMovimento:oOrdServ:oProdLote:GetProduto()},{"[VAR03]",oMovimento:GetIdDCF()},{"[VAR04]",oMovimento:GetIdMovto()},{"[VAR05]",oMovimento:GetIdOpera()}}) + CLRF + STR0034) // SIGAWMS - OS [VAR01] - Produto: [VAR02] - Id. OS: [VAR03] - Id. Movimento: [VAR04] - Id. Operação: [VAR05]. //Movimento possui atividade já executada.
								lRet := .F.
							EndIf
							// Verifica se for conferência de expedição, se foi concluída a separação
							If lRet .And. oMovimento:oMovServic:ChkConfer() .And. StaticCall(WMSV001,HasPrdMov,.T.)
								If oMovimento:oMovServic:ChkConfEnt()
									Aadd(aMensagem, WmsFmtMsg(STR0017,{{"[VAR01]",oMovimento:oOrdServ:GetDocto()+Iif(!Empty(oMovimento:oOrdServ:GetSerie()),"/"+AllTrim(oMovimento:oOrdServ:GetSerie()),'')},{"[VAR02]",oMovimento:oOrdServ:oProdLote:GetProduto()},{"[VAR03]",oMovimento:GetIdDCF()},{"[VAR04]",oMovimento:GetIdMovto()},{"[VAR05]",oMovimento:GetIdOpera()}}) + CLRF + STR0023) // SIGAWMS - OS [VAR01] - Produto: [VAR02] - Id. OS: [VAR03] - Id. Movimento: [VAR04] - Id. Operação: [VAR05].//Endereçamento não está encerrado para permitir a conferência.
								Else
									Aadd(aMensagem, WmsFmtMsg(STR0017,{{"[VAR01]",oMovimento:oOrdServ:GetDocto()+Iif(!Empty(oMovimento:oOrdServ:GetSerie()),"/"+AllTrim(oMovimento:oOrdServ:GetSerie()),'')},{"[VAR02]",oMovimento:oOrdServ:oProdLote:GetProduto()},{"[VAR03]",oMovimento:GetIdDCF()},{"[VAR04]",oMovimento:GetIdMovto()},{"[VAR05]",oMovimento:GetIdOpera()}}) + CLRF + STR0024) // SIGAWMS - OS [VAR01] - Produto: [VAR02] - Id. OS: [VAR03] - Id. Movimento: [VAR04] - Id. Operação: [VAR05].//Separação não está encerrada para permitir a conferência.
								EndIf
								lRet := .F.
							EndIf
	
							If lRet
								// Atualização do movimento
								oMovimento:SetLog('2')
								If cOp332 != "6"
									oMovimento:SetStatus(oModelGrid:GetValue("D12_STATUS"))
									oMovimento:SetPrAuto("2")
									oMovimento:SetDataIni(oModelGrid:GetValue("D12_DATINI"))
									oMovimento:SetHoraIni(oModelGrid:GetValue("D12_HORINI"))
									oMovimento:SetDataFim(oModelGrid:GetValue("D12_DATFIM"))
									oMovimento:SetHoraFim(oModelGrid:GetValue("D12_HORFIM"))
									oMovimento:SetRecHum(oModelGrid:GetValue("D12_RECHUM"))
									oMovimento:SetQtdLid(oModelGrid:GetValue("D12_QTDLID"))
									oMovimento:SetQtdLid2(oModelGrid:GetValue("D12_QTDLI2"))
									oMovimento:SetRadioF(oModelGrid:GetValue("D12_RADIOF"))
								EndIf
								oMovimento:UpdateD12(.F.)
								If !lAutomato
									oProcess:IncRegua2( WmsFmtMsg(STR0009 + "...",{{"[VAR01]",oMovimento:oMovPrdLot:GetProduto()},{"[VAR02]",AllTrim(Str(oMovimento:GetQtdMov()))}}) ) // Confirmando produto: [VAR01] quantidade: [VAR02]
								EndIf
								// Confirmação e atualização do estoque
								Do Case
									Case cOp332 $ "1|2"
										// Valida se quantidade para reiniciar não encontra-se em volume
										// Somente para processo de separação e ultima atividade
										// Libera o endereco se estiver travado pelo recurso humano, ao reiniciar a tarefa/atividade ou no bloqueio
										oRegraConv:SetRecHum(oMovimento:GetRecHum())
										oRegraConv:SetArmazem(oMovimento:oMovPrdLot:GetArmazem())
										oRegraConv:LawLibTar()
										If !lAutomato
											oProcess:IncRegua2( WmsFmtMsg(STR0010 + "...",{{"[VAR01]",oMovimento:oMovPrdLot:GetProduto()},{"[VAR02]",AllTrim(Str(oMovimento:GetQtdMov()))}}) ) // Liberando produto: [VAR01] quantidade: [VAR02]
										EndIf
								 	Case cOp332 $ "4|5"
								 		// Finalizar ou Apontar a movimentação
										If lRet
											If cOp332 == "4" .And. cAcao332 == "4"
												If WmsVpaMov(oMovimento,.F.,oMovimento:GetQtdLid()) // Valida processo quantidade a menor
													lRet := WmsGrvDif(oMovimento,.F.,oMovimento:GetQtdMov(),oMovimento:GetQtdLid())
												EndIf
											EndIf
											If cOp332 $ "4|5" .And. oMovimento:GetQtdLid() > 0 .And. oMovimento:IsUltAtiv()
												If oMovimento:IsUpdEst()
													If !lAutomato
														oProcess:IncRegua2( WmsFmtMsg(STR0011 + "...",{{"[VAR01]",oMovimento:oMovPrdLot:GetProduto()},{"[VAR02]",AllTrim(Str(oMovimento:GetQtdMov()))}}) ) // Registrando produto: [VAR01] quantidade: [VAR02]
													EndIf
													If oMovimento:oMovServic:ChkRecebi(); // Endereçamento, Cross Docking
														.Or. oMovimento:oMovServic:ChkTransf() // Transferencia // Desfragmentação(Transferencia)
														lRet := oMovimento:RecEnter()
													ElseIf oMovimento:oMovServic:ChkSepara(); // Apanhe
														.Or. oMovimento:oMovServic:ChkReabast() // (Re)Abastecimento
														lRet := oMovimento:RecExit()
													EndIf
												ElseIf oMovimento:oMovServic:ChkConfSai() // Conferência Saída
													If !lAutomato
														oProcess:IncRegua2( WmsFmtMsg(STR0012 + "...",{{"[VAR01]",oMovimento:oMovPrdLot:GetProduto()},{"[VAR02]",AllTrim(Str(oMovimento:GetQtdMov()))}}) ) // Conferindo produto: [VAR01] quantidade: [VAR02]
													EndIf
													// Valida se toda a quantidade do produtos foi separa para permitir a finalização da atividade
													// de conferencia e a liberação do pedido de venda quando parametrizado para liberar na conferÊncia de saída
													If !oMovimento:HasPrdSep()
														Aadd(aMensagem, WmsFmtMsg(STR0017,{{"[VAR01]",oMovimento:oOrdServ:GetDocto()+Iif(!Empty(oMovimento:oOrdServ:GetSerie()),"/"+AllTrim(oMovimento:oOrdServ:GetSerie()),'')},{"[VAR02]",oMovimento:oOrdServ:oProdLote:GetProduto()},{"[VAR03]",oMovimento:GetIdDCF()},{"[VAR04]",oMovimento:GetIdMovto()},{"[VAR05]",oMovimento:GetIdOpera()}}) + CLRF + STR0035) // SIGAWMS - OS [VAR01] - Produto: [VAR02] - Id. OS: [VAR03] - Id. Movimento: [VAR04] - Id. Operação: [VAR05]. // Conferência não será finalizada, separação não concluída!
														lRet := .F.
													EndIf
													If lRet .And. oMovimento:GetLibPed() == "2"
														lRet := WmsGrvConf()
													EndIf
												EndIf
											EndIf
										EndIf
									Case cOp332 == "6"
										If !lAutomato
											oProcess:IncRegua2( WmsFmtMsg(STR0013 + "...",{{"[VAR01]",oMovimento:oMovPrdLot:GetProduto()},{"[VAR02]",AllTrim(Str(oMovimento:GetQtdMov()))}}) ) // Alterando produto: [VAR01] quantidade: [VAR02]
										EndIf
										// Alterar endereço dependendo do serviço
										If (oMovimento:oMovServic:ChkRecebi().Or. oMovimento:oMovServic:ChkTransf()) // Endereçamento, Crossdocking // Transferencia // Desfragmentação(Transferencia)
											If!(oMovimento:oMovEndDes:GetEnder() == oModelGrid:GetValue("D12_ENDDES") .And. oMovimento:GetUniDes() == oModelGrid:GetValue("D12_UNIDES"))
												If !Empty(oModelGrid:GetValue("D12_UNIDES"))
													oEtiqUnit := WMSDTCEtiquetaUnitizador():New()
													oEtiqUnit:SetIdUnit(oModelGrid:GetValue("D12_UNIDES"))
													If oEtiqUnit:LoadData() .And. Empty(oEtiqUnit:GetTipUni())
														oEtiqUnit:SetTipUni(oModelGrid:GetValue("D12TIPDES"))
														oEtiqUnit:SetUsado('1')
														oEtiqUnit:UpdateD0Y(.F.)
													EndIf
												EndIf
												oMovimento:UpdEndDes(oModelGrid:GetValue("D12_ENDDES"),oModelGrid:GetValue("D12_UNIDES"),oModelGrid:GetValue("D12TIPDES"))
											EndIf
										ElseIf (oMovimento:oMovServic:ChkSepara() .Or. oMovimento:oMovServic:ChkReabast()) // Apanhe // (Re)Abastecimento
											If !(oMovimento:oMovPrdLot:GetLoteCtl() == oModelGrid:GetValue("D12_LOTECT")) .Or.!(oMovimento:oMovPrdLot:GetNumLote() == oModelGrid:GetValue("D12_NUMLOT")) .Or. !(oMovimento:GetIdUnit() == oModelGrid:GetValue("D12_UNIDES"))
												lRet := oMovimento:UpdLote(oModelGrid:GetValue("D12_LOTECT"),oModelGrid:GetValue("D12_NUMLOT"),oModelGrid:GetValue("D12_IDUNIT"),oModelGrid:GetValue("D12_ENDORI"))
											ElseIf oMovimento:oMovEndOri:GetEnder() != oModelGrid:GetValue("D12_ENDORI")
												oMovimento:UpdEndOri(oModelGrid:GetValue("D12_ENDORI"),oModelGrid:GetValue("D12_IDUNIT"),oModelGrid:GetValue("D12TIPORI"))
											EndIf
										EndIf
								EndCase
								// Caso tenha ocorrido algum erro
								If !lRet .And. !Empty(oMovimento:GetErro())
									Aadd(aMensagem, WmsFmtMsg(STR0017,{{"[VAR01]",oMovimento:oOrdServ:GetDocto()+Iif(!Empty(oMovimento:oOrdServ:GetSerie()),"/"+AllTrim(oMovimento:oOrdServ:GetSerie()),'')},{"[VAR02]",oMovimento:oOrdServ:oProdLote:GetProduto()},{"[VAR03]",oMovimento:GetIdDCF()},{"[VAR04]",oMovimento:GetIdMovto()},{"[VAR05]",oMovimento:GetIdOpera()}}) + CLRF + oMovimento:GetErro()) // SIGAWMS - OS [VAR01] - Produto: [VAR02] - Id. OS: [VAR03] - Id. Movimento: [VAR04] - Id. Operação: [VAR05].
								EndIf
							EndIf
						EndIf
						If !lRet
							If !lAutomato
								oProcess:IncRegua2( WmsFmtMsg(STR0016 + "...",{{"[VAR01]",oMovimento:oMovPrdLot:GetProduto()},{"[VAR02]",AllTrim(Str(oMovimento:GetQtdMov()))}}) ) // Problema no produto: [VAR01] quantidade: [VAR02]
							EndIf
							Disarmtransaction()
						Else
							If !lAutomato
								oProcess:IncRegua2( WmsFmtMsg(STR0014 + "...",{{"[VAR01]",oMovimento:oMovPrdLot:GetProduto()},{"[VAR02]",AllTrim(Str(oMovimento:GetQtdMov()))}}) ) // Finalizando produto: [VAR01] quantidade: [VAR02]
							EndIf
						EndIf
					EndIf
				EndIf
			End Transaction
			// Analise para liberar os pedidos de cross docking
			If lRet .And. oMovimento:oMovServic:ChkCross()
				oMovimento:UpdLibCrs()
			EndIf
			// Atualiza log
			If !lRet .And. lLog
				oMovimento:SetLog('1')
				oMovimento:SetStatus('2')
				oMovimento:UpdateD12(.F.)
			EndIf
			oMovimento:UnLockD12()
		Next nI
		// Retira trava para liberar uso desta carga / documento
		WMSTrava(0,cTrava)
	EndIf
	
	If !Empty(oMovimento:aPrdMont)
		For nI := 1 To Len(oMovimento:aPrdMont)
			Aadd(aMensagem,WmsFmtMsg(STR0025+CLRF+STR0026,{{"[VAR01]",oMovimento:aPrdMont[nI][3]},{"[VAR02]",cValtoChar(oMovimento:aPrdMont[nI][1])},{"[VAR03]",oMovimento:aPrdMont[nI][2]},{"[VAR04]",oMovimento:oMovPrdLot:GetProduto()},{"[VAR05]",oMovimento:oMovPrdLot:GetPrdOri()}})) // Realizada a montagem automática do produto [VAR01] de [VAR02] [VAR03]. Quantidades não multiplas do componente [VAR04] constam como saldo de produto [VAR05].
		Next nI
	EndIf
	// Destroy as temporárias da unitização - FORA DA TRANSAÇÃO
	WMSDTPENDU()
	// Destroy as temporárias da execução automática - FORA DA TRANSAÇÃO
	WMSDTPRGCV()
Return .T.

Function WMSA332AF4()
Local oView := FwViewActive()
Local oModel := oView:GetModel()
Local oModelGrd := oModel:GetModel("D12DETAIL")
Local cReadVar := ReadVar()
Local cFieldF4 := SubStr(cReadVar,4)
Local aAreaAnt
	If !Empty(cReadVar)
		If Upper(cFieldF4) $ "D12_ENDORI|D12_ENDDES"
			aAreaAnt := GetArea()
			F4Localiz(,,,"WMSA332A",oModelGrd:GetValue("D12_PRODUT"),If(Upper(cFieldF4)=="D12_ENDORI",oModelGrd:GetValue("D12_LOCORI"),oModelGrd:GetValue('D12_LOCDES')),oModelGrd:GetValue('D12_QTDMOV'),cReadVar)
			RestArea(aAreaAnt)
		EndIf
	
		oModelGrd:LoadValue(cFieldF4,&(cReadVar))
		oModelGrd:LoadValue("D12_LOTECT",&("M->D12_LOTECT"))
		oModelGrd:LoadValue("D12_NUMLOT",&("M->D12_NUMLOT"))
		oModelGrd:LoadValue("D12_IDUNIT",&("M->D12_IDUNIT"))
		
		oView:GetModel():LMODIFY := .T.
		oView:LMODIFY := .T.
		oView:Refresh("VIEW_GRID")
	EndIf
Return Nil
/*/{Protheus.doc} WmsOpc332
Função responsável por controlar a opção selecionada pelo usuário no monitor de serviço
@author amanda.vieira
@since 07/08/2018
@version 1.0
@return cOpc, opção escolhida pelo usuário
/*/
Static __cOpc := ""
Function WmsOpc332(cOpc)
	If ValType(cOpc) == "C"
		__cOpc := cOpc
	EndIf
Return __cOpc
/*/{Protheus.doc} WmsAcao332
Função responsável por controlar a ação selecionada pelo usuário no monitor de serviço
@author amanda.vieira
@since 07/08/2018
@version 1.0
@return cAcao, ação escolhida pelo usuário
/*/
Static __cAcao := ""
Function WmsAcao332(cAcao)
	If ValType(cAcao) == "C"
		__cAcao := cAcao
	EndIf
Return __cAcao
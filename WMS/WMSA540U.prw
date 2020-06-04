#INCLUDE "PROTHEUS.CH"   
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "WMSA540.CH"

User Function WMSA540U()
Local nTime := SuperGetMV('MV_WMSREFS', .F., 10) // Tempo em Segundos para Refresh da tela de Execucao de Servicos (Default = 10 segundos)
Local oBrowse
	// Permite efetuar validações, apresentar mensagem e abortar o programa quando desejado
	If !WMSChkPrg(FunName(),"1")
		Return Nil
	EndIf

	If Pergunte("WMSA540",.T.)
        
        U_GeraTbl()//Rodolfo - Gero tabela temporaria para substituir a D0E

		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias("D0D")         // Alias da tabela utilizada
		oBrowse:SetMenuDef("WMSA540U")   // Nome do fonte onde esta a função MenuDef
		oBrowse:SetDescription(STR0001) // Descrição do browse "Monitor de Distribuição da Separação
		oBrowse:DisableDetails()        // Desabilita detalhes do Browse
		oBrowse:SetAmbiente(.F.)        // Desabilita opção Ambiente do menu Ações Relacionadas
		oBrowse:SetWalkThru(.F.)        // Desabilita opção WalkThru do menu Ações Relacionadas
		oBrowse:SetFilterDefault("@"+Filtro())
		oBrowse:SetFixedBrowse(.T.)
		oBrowse:AddLegend("D0D->D0D_STATUS=='1'.And.D0D->D0D_QTDDIS==0", "RED"   , STR0002) // Pendente
		oBrowse:AddLegend("D0D->D0D_STATUS=='1'.And.D0D->D0D_QTDDIS>0" , "YELLOW", STR0003) // Em Andamento
		oBrowse:AddLegend("D0D->D0D_STATUS=='2'"                       , "GREEN" , STR0004) // Finalizada
		oBrowse:SetProfileID("D0D")
		oBrowse:SetParam({|| SelFiltro(oBrowse) })
		oBrowse:SetTimer({|| RefreshBrw(oBrowse) }, Iif(nTime<=0, 3600, nTime) * 1000)
		oBrowse:SetIniWindow({||oBrowse:oTimer:lActive := (MV_PAR07 < 4)})
	
		oBrowse:Activate()
	EndIf
Return
//-----------------------------------------------------------
// Função MenuDef
//-----------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
   ADD OPTION aRotina TITLE STR0005 ACTION "StaticCall(WMSA540U,DetDisSep)" OPERATION 2 ACCESS 0 // Monitor
Return aRotina

User Function WMSA540MNT()
Return DetDisSep()

Static Function DetDisSep()
Local oSize, oDlg, oLayer, oMaster, oPanel, oCombo, oTimer
Local aPosSize := {}
Local nTime    := SuperGetMV('MV_WMSREFS', .F., 10) // Tempo em Segundos para Refresh da tela de Execucao de Servicos (Default = 10 segundos)
Local nPos     := 0
Local cStatus  := ""
Local aBrowse	:= {}

	SX3->(DbSetOrder(1))
	SX3->(DbSeek('D0E'))
	While(SX3->X3_ARQUIVO = 'D0E')
		AADD(aBrowse ,{SX3->X3_TITULO,SX3->X3_CAMPO	,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_PICTURE})    
		SX3->(DbSkip())
	EndDo
	// Calcula as dimensoes dos objetos
	oSize := FwDefSize():New( .T. )  // Com enchoicebar

	// Cria Enchoice
	oSize:AddObject( "MASTER", 100, 60, .T., .F. ) // Adiciona enchoice
	oSize:AddObject( "DETAIL", 100, 60, .T., .T. ) // Adiciona enchoice

	// Dispara o calculo
	oSize:Process()
	// Desenha a dialog
	DEFINE MSDIALOG oDlg TITLE STR0001 FROM ;
	oSize:aWindSize[1],oSize:aWindSize[2] TO ;
 	oSize:aWindSize[3],oSize:aWindSize[4] PIXEL

	D0D->( dbSetOrder(1) )
	// Monta a Enchoice
	aPosSize := {oSize:GetDimension("MASTER","LININI"),;
					 oSize:GetDimension("MASTER","COLINI"),;
					 oSize:GetDimension("MASTER","LINEND"),;
					 oSize:GetDimension("MASTER","COLEND")}
   oMaster := MsMGet():New("D0D",D0D->(Recno()),2,,,,,aPosSize,,3,,,,oDlg)
   // Força a combo a ler de forma separada, pois o campo da tabela só tem as opções 1 e 2
   If (nPos:=AScan(oMaster:oBox:Cargo,{|oCmp| "D0D_STATUS" $ oCmp:cReadVar})) > 0
      oCombo := oMaster:oBox:Cargo[nPos]
      oCombo:aItems := {"1="+STR0002,"2="+STR0003,"3="+STR0004," "}
      oCombo:cReadVar := "cStatus"
      oCombo:bSetGet := {|u| Iif(ValType(u) <> 'U',cStatus:=u,Iif(D0D->D0D_STATUS=="1".And.D0D->D0D_QTDDIS==0,"1",Iif(D0D->D0D_STATUS=="1".And.D0D->D0D_QTDDIS>0,"2","3")))}
      oCombo:Refresh()
   EndIf

   aPosSize := {oSize:GetDimension("DETAIL","LININI"),; // Pos.x
                oSize:GetDimension("DETAIL","COLINI"),; // Pos.y
                oSize:GetDimension("DETAIL","XSIZE"),;  // Size.x
                oSize:GetDimension("DETAIL","YSIZE")}   // Size.y

	oPanel := TPanel():New(aPosSize[1],aPosSize[2],"",oDlg,,,,,,aPosSize[3],aPosSize[4],.F.,.F.)
	SX2->(dbSetOrder(1))
	SX2->(dbSeek("D0E"))
	oBrwD0E := FWMBrowse():New()
	oBrwD0E:SetOwner(oPanel)
	oBrwD0E:SetDescription(Capital(X2Nome())) // Itens da Distribuição
	oBrwD0E:SetAlias("D0EX")
	oBrwD0E:SetMenuDef('')
	oBrwD0E:SetProfileID("D0E")
	oBrwD0E:DisableDetails()
	oBrwD0E:SetFields(aBrowse) //TIVE Q COLOCAR ESSA ENCRENCA AQUI PRA FUNCIONAR TABELA TEMPORARIA
	oBrwD0E:SetTemporary(.T.) //TIVE Q COLOCAR ESSA ENCRENCA AQUI
	oBrwD0E:SetFixedBrowse(.T.)
	oBrwD0E:SetAmbiente(.F.)
	oBrwD0E:SetWalkThru(.F.)
	oBrwD0E:SetFilterDefault("@D0E_FILIAL='"+xFilial('D0E')+"' AND D0E_CODDIS='"+D0D->D0D_CODDIS+"' AND D0E_CARGA='"+D0D->D0D_CARGA+"' AND D0E_PEDIDO='"+D0D->D0D_PEDIDO+"'")
	oBrwD0E:AddLegend("D0EX->D0E_STATUS=='1'.And.D0EX->D0E_QTDDIS==0", "RED"   , STR0002) // Pendente
	oBrwD0E:AddLegend("D0EX->D0E_STATUS=='1'.And.D0EX->D0E_QTDDIS>0" , "YELLOW", STR0003) // Em Andamento
	oBrwD0E:AddLegend("D0EX->D0E_STATUS=='2'"                       , "GREEN" , STR0004) // Finalizada
	oBrwD0E:Activate()

	oTimer:= TTimer():New((Iif(nTime <= 0, 3600, nTime) * 1000),{|| BrwRefresh(oMaster,oBrwD0E) },oDlg)
	oTimer:Activate()

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpcA := 1,oDlg:End()},{|| nOpcA := 2,oDlg:End()})
Return Nil
//-----------------------------------------------------------
// Função ModelDef
//-----------------------------------------------------------
Static Function ModelDef()
Local oModel     := oModel := MPFormModel():New('WMSA540U')
Local oStructD0D := FWFormStruct(1,'D0D')
Local oStructD0E := FWFormStruct(1,'D0EX')
Local bStatus    := {||,Iif(D0EX->D0E_STATUS=='1'.And.D0EX->D0E_QTDDIS==0,'BR_VERMELHO',Iif(D0EX->D0E_STATUS=='2','BR_VERDE','BR_AMARELO'))}
   oStructD0E:AddField(STR0006,STR0007,'D0E_VSTATUS','C',11,0,,,,,bStatus,,,.T.) // Situação // Situação da Distribuição do Item

   oModel:AddFields('MdFieldD0D',,oStructD0D)

   oModel:AddGrid('MdGridD0E','MdFieldD0D',oStructD0E)
   
   oModel:SetRelation( 'MdGridD0E', {{'D0E_FILIAL',"xFilial('D0E')"},{'D0E_CODDIS','D0D_CODDIS'}} , D0EX->( IndexKey(1) ) )

   oModel:SetPrimaryKey({'D0D_FILIAL', 'D0D_CODDIS'})
   
   oModel:SetDescription(STR0001) // Monitor de Distribuição da Separação
Return oModel
//-----------------------------------------------------------
// Função ViewDef
//-----------------------------------------------------------
Static Function ViewDef()
Local oView      := FWFormView():New()
Local oModel     := FWLoadModel('WMSA540U')
Local cCmpFil	 := 'D0E_FILIAL|D0E_CODDIS|D0E_CARGA|D0E_PEDIDO|D0E_STATUS|D0E_LOCORI|D0E_ENDORI|D0E_PRDORI|D0E_PRODUT|D0E_LOTECT|D0E_QTDORI|D0E_QTDSEP|D0E_QTDDIS'
Local oStructD0D := FWFormStruct(2,'D0D')
Local oStructD0E := FWFormStruct( 2, 'D0EX', {|x| AllTrim( x ) + "|" $ cCmpFil } )

   oView:SetModel(oModel)
   
   oStructD0E:AddField('D0E_VSTATUS','01',STR0006,STR0007 + '.',{STR0007},'GET','@BMP',,,.F.,,,,,,.T.) // Situação da Distribuição do Item
   oStructD0E:RemoveField('D0E_STATUS')
   
   oView:AddField('VwFieldD0D',oStructD0D,'MdFieldD0D')
   
   oView:AddGrid('VwGridD0E',oStructD0E,'MdGridD0E')
   
   oView:CreateHorizontalBox('SUPERIOR',30)
   oView:CreateHorizontalBox('INFERIOR',70)
   
   oView:SetOwnerView('VwFieldD0D','SUPERIOR')
   oView:SetOwnerView('VwGridD0E','INFERIOR')
Return oView

Static Function Filtro()
Local cFiltro := ""
	cFiltro := " D0D_CARGA >= '"+MV_PAR01+"' AND D0D_CARGA <= '"+MV_PAR02+"'"
	cFiltro += " AND D0D_PEDIDO >= '"+MV_PAR03+"' AND D0D_PEDIDO <= '"+MV_PAR04+"'"
	cFiltro += " AND D0D_DATA >= '"+DTOS(MV_PAR05)+"' AND D0D_DATA <= '"+DTOS(MV_PAR06)+"'"
Return cFiltro

//-------------------------------------------------------------------//
//--------------------Seleção do filtro tecla F12--------------------//
//-------------------------------------------------------------------//
Static Function SelFiltro(oBrowse)
Local lRet := .T.

	If (lRet := Pergunte('WMSA540',.T.))
	   oBrowse:oTimer:lActive := (MV_PAR07 < 4)
		oBrowse:SetFilterDefault("@"+Filtro())
		oBrowse:Refresh(.T.)
	EndIf
Return lRet
//-------------------------------------------------------------------//
//------------Refresh do Browse para Recarregar a Tela---------------//
//-------------------------------------------------------------------//
Static Function RefreshBrw(oBrowse)
Local nPos := oBrowse:At()

	Pergunte('WMSA540', .F.)
	oBrowse:SetFilterDefault("@"+Filtro())
	If MV_PAR07 == 1
		oBrowse:Refresh(.T.)
	ElseIf MV_PAR07 == 2
		oBrowse:Refresh(.F.)
		oBrowse:GoBottom()
	Else
		oBrowse:Refresh(.F.)
		oBrowse:GoTo(nPos)
	EndIf
Return .T.
//-----------------------------------------------------------
// Função responsável por efetuar a atualização da tela
//-----------------------------------------------------------
Static Function BrwRefresh(oMaster,oBrwD0E)
Local aAreaD0D := D0D->(GetArea())
	// Força a releitura da situação da distribuição da separação
	D0D->( DbSeek(xFilial('D0D')+D0D->D0D_CODDIS+D0D->D0D_CARGA+D0D->D0D_PEDIDO) )
	oMaster:Refresh()
	D0EX->(dbSetOrder(1))
	oBrwD0E:Refresh()
	RestArea(aAreaD0D)
Return .T.


/*/{Protheus.doc} GeraTbl
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
User Function GeraTbl()
Local aStru         := {}
Local cQuery        := ''
Local cAliasD0E     := GetNextAlias()
Local cSegSepara	:= SuperGetMV('ES_SERVSEP',.T.,'025',cFilAnt)
Local n             := 0
If Select("D0EX") <= 0
    SX3->(DbSetOrder(1))
    SX3->(DbSeek('D0E'))
    While(SX3->X3_ARQUIVO = 'D0E')
        AADD(aStru ,{SX3->X3_CAMPO	,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})    
        SX3->(DbSkip())
    EndDo

    oTmpTable := FWTemporaryTable():New( "D0EX" )
    oTmpTable:SetFields( aStru )
    oTmpTable:AddIndex("indice1", {"D0E_FILIAL","D0E_CODDIS","D0E_LOCORI","D0E_PRODUT","D0E_LOTECT","D0E_NUMLOT"} )                                                   
    oTmpTable:Create()		
EndIf

//Apago os registros
D0EX->(DBGoTop())
While(!D0EX->(EOF()))
    Reclock('DOEX',.F.)
    D0EX->(DBDelete())
    MsUnlock()
    D0EX-(DbSkip())
EndDo

cQuery := "SELECT D0E_FILIAL ,D0E_PRODUT , D0E_LOCORI ,D0E_STATUS,D0E_QTDDIS, D0E_ENDORI,D0E_PRDORI, D12_ENDDES, D12_QTDMOV  ,D0E_LOTECT , D0E_QTDORI , D12_LOTECT,D0E_CODDIS,D0E_CARGA ,D0E_QTDSEP,D0E_QTDDIS,D0E_PEDIDO"		
cQuery +=  " FROM "+RetSqlName("D0E")+" D0E"
cQuery +=  " INNER JOIN  "+RetSqlName("D12")+" D12 ON D12_PRDORI = D0E_PRODUT AND D0E_PEDIDO = D12_DOC AND D12_LOTECT = D0E_LOTECT AND D12_CARGA = D0E_CARGA AND D0E_FILIAL = D12_FILIAL"
cQuery += " WHERE D0E.D0E_FILIAL = '"+xFilial("D0E")+"' "
cQuery +=   " AND D12.D12_SERVIC = '"+cSegSepara+"'"
cQuery +=   " AND D0E.D_E_L_E_T_ = ' ' AND D12.D_E_L_E_T_ = ' '"
cQuery += " AND D0E_CARGA >= '"+MV_PAR01+"' AND D0E_CARGA <= '"+MV_PAR02+"'"
cQuery += " AND D0E_PEDIDO >= '"+MV_PAR03+"' AND D0E_PEDIDO <= '"+MV_PAR04+"'"
cQuery +=   " ORDER BY D0E_CODDIS"
cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasD0E,.F.,.T.)

While !(cAliasD0E)->(Eof()) 
    Reclock('D0EX',.T.)
    D0EX->D0E_FILIAL   := (cAliasD0E)->D0E_FILIAL
    D0EX->D0E_CODDIS   := (cAliasD0E)->D0E_CODDIS
    D0EX->D0E_CARGA    := (cAliasD0E)->D0E_CARGA
    D0EX->D0E_PEDIDO   := (cAliasD0E)->D0E_PEDIDO
    D0EX->D0E_STATUS   := (cAliasD0E)->D0E_STATUS
    D0EX->D0E_LOCORI   := (cAliasD0E)->D0E_LOCORI
    D0EX->D0E_ENDORI   := (cAliasD0E)->D12_ENDDES
    D0EX->D0E_PRDORI   := (cAliasD0E)->D0E_PRDORI
    D0EX->D0E_PRODUT   := (cAliasD0E)->D0E_PRODUT
    D0EX->D0E_LOTECT   := (cAliasD0E)->D0E_LOTECT
    D0EX->D0E_QTDORI   := (cAliasD0E)->D12_QTDMOV //tabela temporaria pra gravar esse campo
    D0EX->D0E_QTDSEP   := (cAliasD0E)->D12_QTDMOV
    D0EX->D0E_QTDDIS   := (cAliasD0E)->D12_QTDMOV
    MsUnlock()
    (cAliasD0E)->(DbSkip())
EndDo

Return 
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GFEX010.CH"

// SONARQUBE - CA1003: Uso não permitido de chamada de API em LOOP
Static lPE101	:= ExistBlock("GFEX0101")
Static __nLogProc := 1
Static __lHidePrg := .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEX010SIM

Função para criar as simulações

@author Felipe Mendes
@since 05/07/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEX010()
	Local aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
	Private lAgr 	:= .F.
	Static cLogErro	:= ""

	FWExecView(STR0001,'GFEX010', 3, , {|| .T. },{|| .F.},,aButtons,{|| GFE010CLE(.F.)}) //"Frete Embarcador"

Return .T.

///------------------------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel
Local oStruNeg  := StrModNeg()   // Struct do campo "Considerar Negociação"
Local oStruAgr  := FWFormStruct( 1, "GWN", { |cCampo| BscStrGWN( cCampo ) } )    // Struct do grid "Agrupadores"
Local oStruDC   := FWFormStruct( 1, "GW1", { |cCampo| BscStrGW1( cCampo ) } )    // Struct do grid "Doc Carga"
Local oStruIt   := FWFormStruct( 1, "GW8", { |cCampo| BscStrGW8( cCampo ) } )    // Struct do grid "Item Carga"
Local oStruTr   := FWFormStruct( 1, "GWU", { |cCampo| BscStrGWU( cCampo ) } )    // Struct do grid "Trechos"
Local oStruCal1 := StrModCal1(1) // Struct do primeiro grid da aba de "Cálculos"
Local oStruCal2 := StrModCal2(1) // Struct do segundo  grid da aba de "Cálculos"
Local oStruCal3 := StrModCal3(1) // Struct do terceiro grid da aba de "Cálculos"
Local oStruOI1  := StrModOI1(1)  // Struct do primeiro grid da aba de "Outras informações"
Local oStruOI2  := StrModOI2(1)  // Struct do segundo  grid da aba de "Outras informações"
Local oStruTST  := FWFormModelStruct():New()
Local aAux := {}
Local lBlind := IsBlind()
/*Cria os campos virtuais para Integração*/
//oStruTST:AddField ("Integração" ,"Integração","INTEGRA" ,"C",01,/*nDECIMAL*/,{|A,B,C,D| FWINITCPO(A,B,C), LRETORNO := GFE010SIM(),FWCLOSECPO(A,B,C,LRETORNO),LRETORNO} /*bVALID*/,/*bWHEN*/,/*@aVALUES*/,.T.,/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)
oStruTST:AddField (STR0002 , STR0002, "INTEGRA", "C", 01, /*nDECIMAL*/, {|A,B,C,D| FWINITCPO(A,B,C), LRETORNO := GFE010SIM(),FWCLOSECPO(A,B,C,LRETORNO),LRETORNO} /*bVALID*/,/*bWHEN*/,/*@aVALUES*/,,/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/) //"Integração" ### "Integração"
/*Cria os campos virtuais na tela para o oStruAgr*/
oStruAgr:AddField (STR0003 ,STR0003  ,"GWN_DOC"  ,"C",15,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*@aVALUES*/,.T.,/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/) //"Documento" ### "Documento"
/*Cria os campos virtuais na tela para o oStruDC*/
oStruDC:AddField (STR0004, STR0004, "GW1_QTUNI","N",6 ,/*nDECIMAL*/,/*bVALID*/,/*bWHEN*/,/*@aVALUES*/,.T.,/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)//"Qtd Unitiz" ### "Qtd Unitiz"

//Gatilho responsavel por trazer o nome da cidade
aAux := FwStruTrigger(;
'GWU_CDTRP'                     					,; // Campo de Domínio (tem que existir no Model)
'GWU_NMCIDD'                  						,; // Campo de Contradomínio (tem que existir no Model)
'if(Empty(M->GWU_CDTRP),"",FwFldGet("GWU_NMCIDD"))' ,; // Regra de Preenchimento
.F.                          						,; // Se posicionara ou não antes da execução do gatilhos (Opcional)
															,; // Alias da tabela a ser posicionada (Obrigatório se lSeek = .T.)
															,; // Ordem da tabela a ser posicionada (Obrigatório se lSeek = .T.)
													,; // Chave de busca da tabela a ser posicionada (Obrigatório se lSeek = .T)
														)  // Condição para execução do gatilho (Opcional)
oStruTr:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4])

//Gatilho responsavel por trazer os documentos do romaneio informado
aAux := FwStruTrigger(;
'GWN_NRROM'                     					,; // Campo de Domínio (tem que existir no Model)
'GWN_NRROM'                   						,; // Campo de Contradomínio (tem que existir no Model)
'GFEX010ROM()'                                      ,; // Regra de Preenchimento
.F.                          						,; // Se posicionara ou não antes da execução do gatilhos (Opcional)
															,; // Alias da tabela a ser posicionada (Obrigatório se lSeek = .T.)
															,; // Ordem da tabela a ser posicionada (Obrigatório se lSeek = .T.)
													,; // Chave de busca da tabela a ser posicionada (Obrigatório se lSeek = .T)
														)  // Condição para execução do gatilho (Opcional)
oStruAgr:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4])

//Gatilho responsavel por trazer os itens e trechos do documento informado
aAux := FwStruTrigger(;
'GW1_CDTPDC'                     					,; // Campo de Domínio (tem que existir no Model)
'GW1_CDTPDC'                   						,; // Campo de Contradomínio (tem que existir no Model)
'GFEX010DOC(FwFldGet("GW1_CDTPDC"))'                ,; // Regra de Preenchimento
.F.                          						,; // Se posicionara ou não antes da execução do gatilhos (Opcional)
															,; // Alias da tabela a ser posicionada (Obrigatório se lSeek = .T.)
															,; // Ordem da tabela a ser posicionada (Obrigatório se lSeek = .T.)
													,; // Chave de busca da tabela a ser posicionada (Obrigatório se lSeek = .T)
'IIf(IsBlind(), .F., !lAgr)'						)  // Condição para execução do gatilho (Opcional)
oStruDC:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4])

//Gatilho responsavel por trazer os itens e trechos do documento informado
aAux := FwStruTrigger(;
'GW1_EMISDC'                     					,; // Campo de Domínio (tem que existir no Model)
'GW1_EMISDC'                   						,; // Campo de Contradomínio (tem que existir no Model)
'GFEX010DOC(FwFldGet("GW1_EMISDC"))'                ,; // Regra de Preenchimento
.F.                          						,; // Se posicionara ou não antes da execução do gatilhos (Opcional)
															,; // Alias da tabela a ser posicionada (Obrigatório se lSeek = .T.)
															,; // Ordem da tabela a ser posicionada (Obrigatório se lSeek = .T.)
													,; // Chave de busca da tabela a ser posicionada (Obrigatório se lSeek = .T)
'IIf(IsBlind(), .F., !lAgr)'                		)  // Condição para execução do gatilho (Opcional)
oStruDC:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4])

//Gatilho responsavel por trazer os itens e trechos do documento informado
aAux := FwStruTrigger(;
"GW1_SERDC"                     					,; // Campo de Domínio (tem que existir no Model)
"GW1_SERDC"                   						,; // Campo de Contradomínio (tem que existir no Model)
'GFEX010DOC(FwFldGet("GW1_SERDC"))'                 ,; // Regra de Preenchimento
.F.                          						,; // Se posicionara ou não antes da execução do gatilhos (Opcional)
															,; // Alias da tabela a ser posicionada (Obrigatório se lSeek = .T.)
															,; // Ordem da tabela a ser posicionada (Obrigatório se lSeek = .T.)
													,; // Chave de busca da tabela a ser posicionada (Obrigatório se lSeek = .T)
'IIf(IsBlind(), .F., !lAgr)'                		)  // Condição para execução do gatilho (Opcional)
oStruDC:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4])

//Gatilho responsavel por trazer os itens e trechos do documento informado
aAux := FwStruTrigger(;
"GW1_NRDC"                     				    	,; // Campo de Domínio (tem que existir no Model)
"GW1_NRDC"                   						,; // Campo de Contradomínio (tem que existir no Model)
'GFEX010DOC(FwFldGet("GW1_NRDC"))'                  ,; // Regra de Preenchimento
.F.                          						,; // Se posicionara ou não antes da execução do gatilhos (Opcional)
															,; // Alias da tabela a ser posicionada (Obrigatório se lSeek = .T.)
															,; // Ordem da tabela a ser posicionada (Obrigatório se lSeek = .T.)
													,; // Chave de busca da tabela a ser posicionada (Obrigatório se lSeek = .T)
'IIf(IsBlind(), .F., !lAgr)'              			)  // Condição para execução do gatilho (Opcional)
oStruDC:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4])

//Alterando atributos do strutc de Agrupadores
oStruAgr:SetProperty('GWN_CDTRP' , MODEL_FIELD_VALID , {|A,B,C,D| FWINITCPO(A,B,C), LRETORNO := GFEExistC("GU3",,M->GWN_CDTRP,"GU3->GU3_SIT=='1'") .OR. VAZIO(),FWCLOSECPO(A,B,C,LRETORNO),LRETORNO} )
oStruAgr:SetProperty('GWN_NRROM' , MODEL_FIELD_VALID , {|A,B,C,D| FWINITCPO(A,B,C), LRETORNO := GFEANRROM(),FWCLOSECPO(A,B,C,LRETORNO),LRETORNO} )
oStruAgr:SetProperty('GWN_CDTPOP', MODEL_FIELD_VALID , {|A,B,C,D| FWINITCPO(A,B,C), LRETORNO := GFEExistC("GV4",,M->GWN_CDTPOP,"GV4->GV4_SIT=='1'") .Or. VAZIO(),FWCLOSECPO(A,B,C,LRETORNO),LRETORNO} )
oStruAgr:SetProperty('GWN_CDTRP' , MODEL_FIELD_OBRIGAT,.F.)
oStruAgr:SetProperty('GWN_NRROM' , MODEL_FIELD_OBRIGAT,.F.)
oStruAgr:SetProperty('GWN_CDTPOP', MODEL_FIELD_OBRIGAT,.F.)
oStruAgr:SetProperty('GWN_DOC'   , MODEL_FIELD_OBRIGAT,.F.)

//Alterando atributos do strutc do Doc Carga
oStruAgr:SetProperty('GWN_NRROM' , MODEL_FIELD_INIT, Nil )
oStruDC:SetProperty( 'GW1_CDREM' , MODEL_FIELD_VALID  , {|A,B,C,D| FWINITCPO(A,B,C), LRETORNO := GFEExistC("GU3",,,"GU3->GU3_SIT=='1'"),FWCLOSECPO(A,B,C,LRETORNO),LRETORNO} )
oStruDC:SetProperty( 'GW1_CDDEST', MODEL_FIELD_VALID  , {|A,B,C,D| FWINITCPO(A,B,C), LRETORNO := GFEExistC("GU3",,,"GU3->GU3_SIT=='1'"),FWCLOSECPO(A,B,C,LRETORNO),LRETORNO} )
oStruDC:SetProperty( 'GW1_CDTPDC', MODEL_FIELD_OBRIGAT,.F.)
oStruDC:SetProperty( 'GW1_EMISDC', MODEL_FIELD_OBRIGAT,.F.)
oStruDC:SetProperty( 'GW1_NRDC'  , MODEL_FIELD_OBRIGAT,.F.)
oStruDC:SetProperty( 'GW1_CDREM' , MODEL_FIELD_OBRIGAT,.F.)
oStruDC:SetProperty( 'GW1_CDDEST', MODEL_FIELD_OBRIGAT,.F.)
oStruDC:SetProperty( 'GW1_TPFRET', MODEL_FIELD_OBRIGAT,.F.)
oStruDC:SetProperty( 'GW1_QTUNI' , MODEL_FIELD_OBRIGAT,.F.)
oStruDC:SetProperty( 'GW1_QTVOL' , MODEL_FIELD_OBRIGAT,.F.)

//Alterando atributos do strutc de Itens
oStruIt:SetProperty( 'GW8_ITEM'  , MODEL_FIELD_OBRIGAT,.F.)
oStruIt:SetProperty( 'GW8_CDCLFR', MODEL_FIELD_VALID  , {|A,B,C,D| FWINITCPO(A,B,C), LRETORNO := GFEExistC("GUB",,,"GUB->GUB_SIT=='1'") .Or. Vazio(),FWCLOSECPO(A,B,C,LRETORNO),LRETORNO} )
oStruIt:SetProperty( 'GW8_CDCLFR', MODEL_FIELD_OBRIGAT,.F.)

//Alterando atributos do strutc de Trechos
oStruTr:SetProperty( 'GWU_CDTRP' , MODEL_FIELD_VALID  , {|A,B,C,D| FWINITCPO(A,B,C), LRETORNO := GFEExistC("GU3",,,"(GU3->GU3_TRANSP=='1'.OR.GU3->GU3_AUTON=='1').AND.GU3->GU3_SIT=='1'") .OR. VAZIO(),FWCLOSECPO(A,B,C,LRETORNO),LRETORNO} )
oStruTr:SetProperty( 'GWU_CDTRP' , MODEL_FIELD_OBRIGAT,.F.)
// oStruTr:SetProperty( 'GWU_SERDC' , MODEL_FIELD_VALID  , {|A,B,C,D| FWINITCPO(A,B,C), LRETORNO := ExistCpo("SX5","01"+M->GWU_SERDC) .OR. VAZIO(),FWCLOSECPO(A,B,C,LRETORNO),LRETORNO})
oStruTr:SetProperty( 'GWU_SEQ'   , MODEL_FIELD_OBRIGAT,.F.)

If lBlind // Chamada Web Service ou Schedule
	oStruTr:SetProperty('GWU_NRCIDD',MODEL_FIELD_VALID, {||.T.})
	oStruTr:SetProperty('GWU_NMCIDD',MODEL_FIELD_VIRTUAL,.F.)
	oStruTr:SetProperty('GWU_UFD'   ,MODEL_FIELD_VIRTUAL,.F.)
	
	oStruDC:SetProperty('GW1_ENTNRC',MODEL_FIELD_VALID,{||.T.})
	oStruDC:SetProperty('GW1_ENTCID',MODEL_FIELD_VIRTUAL,.F.)
	oStruDC:SetProperty('GW1_ENTUF',MODEL_FIELD_VIRTUAL,.F.)
EndIf

// cID     Identificador do modelo
// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
// bPost   Code-Block de validação do formulário de edição
// bCommit Code-Block de persistência do formulário de edição
// bCancel Code-Block de cancelamento do formulário de edição
oModel := MPFormModel():New("GFEX010", /*bPre*/,{|| GFEX010POS() },/*bCommit*/, /*bCancel*/)

// cId          Identificador do modelo
// cOwner       Identificador superior do modelo
// oModelStruct Objeto com  a estrutura de dados
// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
// bPost        Code-Block de validação do formulário de edição
// bLoad        Code-Block de carga dos dados do formulário de edição
oModel:AddFields("GFEX010_01", Nil,oStruNeg ,/*bPre*/,/*bPost*/,/*bLoad*/)

oModel:AddGrid( 'DETAIL_01', 'GFEX010_01', oStruAgr  , {|oModel,nLinha,cOp| GFEX010DEL(oModel,nLinha,cOp)} , /**/, /*bPreVal*/ ,/*bPosVal*/ , /*BLoad*/ ) // Grid "Agrupadores"
oModel:AddGrid( 'DETAIL_02', 'GFEX010_01', oStruDC   , {|oModel,nLinha,cOp| GFEX010DE(oModel,nLinha,cOp)} , /**/, /*bPreVal*/ ,/*bPosVal*/ , /*BLoad*/ ) // Grid "Doc Carga"
oModel:AddGrid( 'DETAIL_03', 'GFEX010_01', oStruIt   , /**/ , /**/, /*bPreVal*/ ,/*bPosVal*/ , /*BLoad*/ ) // Grid "Item Carga"
oModel:AddGrid( 'DETAIL_04', 'GFEX010_01', oStruTr   , /**/ , /**/, /*bPreVal*/ ,/*bPosVal*/ , /*BLoad*/ ) // Grid "Trechos"
oModel:AddFields( 'SIMULA',  "GFEX010_01", oStruTST  , /**/ , /**/, /*bPreVal*/ ,/*bPosVal*/ , /*BLoad*/ ) // Grid Outas Informações 02

oModel:AddGrid( 'DETAIL_05', 'GFEX010_01', oStruCal1 , /**/ , /**/, /*bPreVal*/ ,/*bPosVal*/ , /*BLoad*/ ) // Grid Cálculos 01
oModel:AddGrid( 'DETAIL_06', 'DETAIL_05' , oStruCal2 , /**/ , /**/, /*bPreVal*/ ,/*bPosVal*/ , /*BLoad*/ ) // Grid Cálculos 02
oModel:AddGrid( 'DETAIL_07', 'DETAIL_05' , oStruCal3 , /**/ , /**/, /*bPreVal*/ ,/*bPosVal*/ , /*BLoad*/ ) // Grid Cálculos 03
oModel:AddGrid( 'DETAIL_08', 'DETAIL_05' , oStruOI1  , /**/ , /**/, /*bPreVal*/ ,/*bPosVal*/ , /*BLoad*/ ) // Grid Outas Informações 01
oModel:AddGrid( 'DETAIL_09', 'DETAIL_08' , oStruOI2  , /**/ , /**/, /*bPreVal*/ ,/*bPosVal*/ , /*BLoad*/ ) // Grid Outas Informações 02

If !lBlind // Chamada do usuário
	oModel:GetModel('DETAIL_05'):setNoInsertLine(.T.)
	oModel:GetModel('DETAIL_06'):setNoInsertLine(.T.)
	oModel:GetModel('DETAIL_07'):setNoInsertLine(.T.)
	
	oModel:GetModel('DETAIL_05'):setNoUpdateLine(.T.)
	oModel:GetModel('DETAIL_06'):setNoUpdateLine(.T.)
	oModel:GetModel('DETAIL_07'):setNoUpdateLine(.T.)
EndIf

If !lBlind // Chamada do usuário
	oModel:SetRelation('DETAIL_06',{{'C2_NRCALC' ,'C1_NRCALC'},'C1_VALFRT'},'C2_NRCALC'  )
	oModel:SetRelation('DETAIL_07',{{'C3_NRCALC' ,'C1_NRCALC'}/*,{'C3_CDTPOP','C2_CDTPOP'},{'C3_SEQ','C2_SEQ'},{'C3_CDCLFR','C2_CDCLFR'}*/},'C3_NRCALC' )
	oModel:SetRelation('DETAIL_08',{{'OI1_NRCALC','C1_NRCALC'}},'OI1_NRCALC')
	oModel:SetRelation('DETAIL_09',{{'OI2_NRROM' ,'OI1_NRROM'},{'OI2_NRTAB','OI1_NRTAB'},{'OI2_NRNEG','OI1_NRNEG'}},'OI2_NRROTA')
EndIf

oModel:SetDescription("Simulação de Fretes Completa") //"Simulação de Frete"
oModel:GetModel("GFEX010_01"):SetDescription(STR0005) //"Considerar Negocição"
oModel:GetModel('DETAIL_01'):SetDescription(STR0006) //"Agrupadores"
oModel:GetModel('DETAIL_02'):SetDescription(STR0007) //"Documentos de Frete"
oModel:GetModel('DETAIL_03'):SetDescription(STR0008) //"Itens de Carga"
oModel:GetModel('DETAIL_04'):SetDescription(STR0009) //"Trechos"
oModel:GetModel('DETAIL_05'):SetDescription(STR0010) //"Cálculos 01"
oModel:GetModel('SIMULA'):SetDescription(STR0011) //"DISPARA SIMULACAO"

oModel:GetModel('DETAIL_01'):SetOptional( .T. )
oModel:GetModel('DETAIL_05'):SetOptional( .T. )
oModel:GetModel('DETAIL_06'):SetOptional( .T. )
oModel:GetModel('DETAIL_07'):SetOptional( .T. )
oModel:GetModel('DETAIL_08'):SetOptional( .T. )
oModel:GetModel('DETAIL_09'):SetOptional( .T. )
 
If !lBlind // Chamada do usuário
	oModel:GetModel("DETAIL_01"):SetUniqueLine({'GWN_NRROM'})
	oModel:GetModel("DETAIL_02"):SetUniqueLine({'GW1_NRROM','GW1_CDTPDC','GW1_EMISDC','GW1_SERDC','GW1_NRDC'})
	
	/*Comentado para que não seja exibida a mensagem de linha duplicada
	ao carregar um romaneio que contenha um documento de carga com dois itens iguais(Nome do item e Descrição).
	
	O mesmo procedimento é aceito ao ser feita a simulação através dos ERP's.
	*/
	//oModel:GetModel("DETAIL_03"):SetUniqueLine({'GW8_EMISDC','GW8_SERDC','GW8_NRDC','GW8_CDTPDC','GW8_ITEM'})
	
	oModel:GetModel("DETAIL_04"):SetUniqueLine({'GWU_EMISDC','GWU_SERDC','GWU_NRDC','GWU_CDTPDC','GWU_SEQ'})
	oModel:GetModel("DETAIL_05"):SetUniqueLine({'C1_NRCALC'})
	oModel:GetModel("DETAIL_07"):SetUniqueLine({'C3_NRCALC','C3_CDTPOP','C3_SEQ','C3_CDCLFR','C3_COPFRT'})
	
	oModel:SetPrimaryKey({"TABNEG"})
EndIf	
Return oModel

//------------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oModel    := FWLoadModel("GFEX010")
Local oView     := Nil
Local oStruNeg  := StrViewNeg()
Local oStruAgr  := FWFormStruct( 2, "GWN", { |cCampo| BscStrGWN( cCampo ) } )    // Struct do grid "Agrupadores"
Local oStruDC   := FWFormStruct( 2, "GW1", { |cCampo| BscStrGW1( cCampo ) } )    // Struct do grid "Doc Carga"
Local oStruIt   := FWFormStruct( 2, "GW8", { |cCampo| BscStrGW8( cCampo ) } )    // Struct do grid "Item Carga"
Local oStruTr   := FWFormStruct( 2, "GWU", { |cCampo| BscStrGWU( cCampo ) } )    // Struct do grid "Trechos"
Local oStruCal1 := StrModCal1(2)
Local oStruCal2 := StrModCal2(2)
Local oStruCal3 := StrModCal3(2)
Local oStruOI1  := StrModOI1(2)
Local oStruOI2  := StrModOI2(2)

/*Coloca na View os campos do struct da GWN*/
oStruAgr:AddField("GWN_DOC" ,"" ,STR0003 ,"" ,{STR0003} ,"C" ,"@!",/*bPICTVAR*/,/*cLOOKUP*/,/*lCANCHANGE*/,/*cFOLDER*/,/*cGRUP*/,/*@aCOMBOVALUES*/,/*nMAXLENCOMBO*/," ",/*lVIRTUAL*/,/*cPICTVAR*/,/*lINSERTLIN*/) //"Documento" ### "Documento"

oStruAgr:SetProperty( "GWN_NRROM", MVC_VIEW_TITULO, STR0012) //"Agrupador"
oStruDC:SetProperty( "GW1_NRROM", MVC_VIEW_TITULO, STR0012) //"Agrupador"
oStruTr:SetProperty( "GWU_SEQ", MVC_VIEW_TITULO, STR0013) //"Trecho"
oStruAgr:SetProperty( "GWN_NRROM", MVC_VIEW_CANCHANGE, .T.)
oStruDC:SetProperty( "GW1_NRROM", MVC_VIEW_CANCHANGE, .T.)
oStruTr:SetProperty( "GWU_SEQ" , MVC_VIEW_CANCHANGE, .T. )

/*//////////////////////////////////////////////////////////////////
//Alterando Ordem dos Campos do Struct Agrupadores
/*//////////////////////////////////////////////////////////////////
oStruAgr:SetProperty( 'GWN_DOC'   , MVC_VIEW_ORDEM, '01')
oStruAgr:SetProperty( 'GWN_NRROM' , MVC_VIEW_ORDEM, '02')
oStruAgr:SetProperty( 'GWN_CDTRP' , MVC_VIEW_ORDEM, '03')
oStruAgr:SetProperty( 'GWN_DSTRP' , MVC_VIEW_ORDEM, '04')
oStruAgr:SetProperty( 'GWN_CDTPVC', MVC_VIEW_ORDEM, '05')
oStruAgr:SetProperty( 'GWN_CDCLFR', MVC_VIEW_ORDEM, '06')
oStruAgr:SetProperty( 'GWN_DSCLFR', MVC_VIEW_ORDEM, '07')
oStruAgr:SetProperty( 'GWN_CDTPOP', MVC_VIEW_ORDEM, '08')
oStruAgr:SetProperty( 'GWN_DISTAN', MVC_VIEW_ORDEM, '09')
oStruAgr:SetProperty( 'GWN_NRCIDD', MVC_VIEW_ORDEM, '10')
oStruAgr:SetProperty( 'GWN_NMCIDD', MVC_VIEW_ORDEM, '11')
oStruAgr:SetProperty( 'GWN_CEPD'  , MVC_VIEW_ORDEM, '12')

oStruAgr:RemoveField('GWN_PLACAD')
/*//////////////////////////////////////////////////////////////////
//Alterando Ordem dos Campos do Struct Documentos de Carga
/*//////////////////////////////////////////////////////////////////*/
oStruDC:SetProperty( 'GW1_NRROM'  , MVC_VIEW_ORDEM, '01')
oStruDC:SetProperty( 'GW1_EMISDC' , MVC_VIEW_ORDEM, '02')
oStruDC:SetProperty( 'GW1_NMEMIS' , MVC_VIEW_ORDEM, '03')
oStruDC:SetProperty( 'GW1_SERDC'  , MVC_VIEW_ORDEM, '04')
oStruDC:SetProperty( 'GW1_NRDC'   , MVC_VIEW_ORDEM, '05')
oStruDC:SetProperty( 'GW1_CDTPDC' , MVC_VIEW_ORDEM, '06')
oStruDC:SetProperty( 'GW1_CDREM'  , MVC_VIEW_ORDEM, '07')
oStruDC:SetProperty( 'GW1_NMREM'  , MVC_VIEW_ORDEM, '08')
oStruDC:SetProperty( 'GW1_CDDEST' , MVC_VIEW_ORDEM, '09')
oStruDC:SetProperty( 'GW1_NMDEST' , MVC_VIEW_ORDEM, '10')
oStruDC:SetProperty( 'GW1_ENTEND' , MVC_VIEW_ORDEM, '11')
oStruDC:SetProperty( 'GW1_ENTBAI' , MVC_VIEW_ORDEM, '12')
oStruDC:SetProperty( 'GW1_ENTNRC' , MVC_VIEW_ORDEM, '13')
If AScan(oStruDC:aFields,{|x| x[1] == "GW1_ENTCID"}) != 0
	oStruDC:SetProperty( 'GW1_ENTCID' , MVC_VIEW_ORDEM, '14')
EndIf

If AScan(oStruDC:aFields,{|x| x[1] == "GW1_ENTUF"}) != 0
	oStruDC:SetProperty( 'GW1_ENTUF'  , MVC_VIEW_ORDEM, '15')
EndIf
oStruDC:SetProperty( 'GW1_ENTCEP' , MVC_VIEW_ORDEM, '16')
If AScan(oStruDC:aFields,{|x| x[1] == "GW1_NRREG"}) != 0
	oStruDC:SetProperty( 'GW1_NRREG'  , MVC_VIEW_ORDEM, '17')
EndIf
oStruDC:SetProperty( 'GW1_TPFRET' , MVC_VIEW_ORDEM, '18')
oStruDC:SetProperty( 'GW1_ICMSDC' , MVC_VIEW_ORDEM, '19')
oStruDC:SetProperty( 'GW1_USO'    , MVC_VIEW_ORDEM, '20')
oStruDC:SetProperty( 'GW1_CARREG' , MVC_VIEW_ORDEM, '21')

If AScan(oStruDC:aFields,{|x| x[1] == "GW1_QTVOL"}) != 0
	oStruDC:SetProperty( 'GW1_QTVOL' , MVC_VIEW_ORDEM, '22')
EndIf
/*//////////////////////////////////////////////////////////////////
//Alterando Ordem dos Campos do Struct CAlculos 02
/*//////////////////////////////////////////////////////////////////*/
oStruCal2:SetProperty( "C2_NRCALC" , MVC_VIEW_ORDEM, '01')
oStruCal2:SetProperty( "C2_CDCLFR" , MVC_VIEW_ORDEM, '02')
oStruCal2:SetProperty( "C2_CDTPOP" , MVC_VIEW_ORDEM, '03')
oStruCal2:SetProperty( "C2_SEQ"    , MVC_VIEW_ORDEM, '04')
oStruCal2:SetProperty( "C2_CDEMIT" , MVC_VIEW_ORDEM, '05')
oStruCal2:SetProperty( "C2_NRTAB"  , MVC_VIEW_ORDEM, '06')
oStruCal2:SetProperty( "C2_NRNEG"  , MVC_VIEW_ORDEM, '07')
oStruCal2:SetProperty( "C2_NRROTA" , MVC_VIEW_ORDEM, '08')
oStruCal2:SetProperty( "C2_DTVAL"  , MVC_VIEW_ORDEM, '09')
oStruCal2:SetProperty( "C2_CDFXTV" , MVC_VIEW_ORDEM, '10')
oStruCal2:SetProperty( "C2_CDTPVC" , MVC_VIEW_ORDEM, '11')

oView := FWFormView():New()
// Objeto do model a se associar a view.
oView:SetModel(oModel)
// cFormModelID - Representa o ID criado no Model que essa FormField irá representar
// oStruct - Objeto do model a se associar a view.
// cLinkID - Representa o ID criado no Model ,Só é necessári o caso estamos mundando o ID no View.
oView:AddField( "GFEX010_01" , oStruNeg, /*cLinkID*/ )
oView:AddGrid('VIEW_01',oStruAgr,'DETAIL_01')
oView:AddGrid('VIEW_02',oStruDC ,'DETAIL_02')
oView:AddGrid('VIEW_03',oStruIt ,'DETAIL_03')
oView:AddGrid('VIEW_04',oStruTr ,'DETAIL_04')
oView:AddGrid('VIEW_05',oStruCal1,'DETAIL_05')
oView:AddGrid('VIEW_06',oStruCal2,'DETAIL_06')
oView:AddGrid('VIEW_07',oStruCal3,'DETAIL_07')
oView:AddGrid('VIEW_08',oStruOI1 ,'DETAIL_08')
oView:AddGrid('VIEW_09',oStruOI2 ,'DETAIL_09')

// cID		  	Id do Box a ser utilizado
// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. é a qtd de pixel exato)
// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas criações uma dentro da outra.
// lFixPixel	Determina que o valor passado no nPercHeight é na verdade a qtd de pixel a ser usada.
// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, é necessário informar o cIDSheet
// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.
oView:CreateHorizontalBox( "MASTER" , 10,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
oView:CreateHorizontalBox( "DETAIL" , 90,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
oView:CreateHorizontalBox( "DETAIL_AG" , 100,,,"IDFOLDER","IDSHEET01" )
oView:CreateHorizontalBox( "DETAIL_DC" , 100,,,"IDFOLDER","IDSHEET02" )
oView:CreateHorizontalBox( "DETAIL_IT" , 100,,,"IDFOLDER","IDSHEET03" )
oView:CreateHorizontalBox( "DETAIL_TR" , 100,,,"IDFOLDER","IDSHEET04" )
oView:CreateHorizontalBox( "DT_CAL01"  , 33 ,,,"IDFOLDER","IDSHEET05" )
oView:CreateHorizontalBox( "DT_CAL02"  , 33 ,,,"IDFOLDER","IDSHEET05" )
oView:CreateHorizontalBox( "DT_CAL03"  , 34 ,,,"IDFOLDER","IDSHEET05" )
oView:CreateHorizontalBox( "DT_OI1"    , 50 ,,,"IDFOLDER","IDSHEET06" )
oView:CreateHorizontalBox( "DT_OI2"    , 50 ,,,"IDFOLDER","IDSHEET06" )

oView:CreateFolder("IDFOLDER","DETAIL")
oView:AddSheet("IDFOLDER","IDSHEET01",STR0006) //"Agrupadores"
oView:AddSheet("IDFOLDER","IDSHEET02",STR0014) //"Documentos de Carga"
oView:AddSheet("IDFOLDER","IDSHEET03",STR0008) //"Itens de Carga"
oView:AddSheet("IDFOLDER","IDSHEET04",STR0013) //"Trecho"
oView:AddSheet("IDFOLDER","IDSHEET05",STR0015) //"Cálculos"
oView:AddSheet("IDFOLDER","IDSHEET06",STR0016) //"Outras Informações"

// Associa um View a um box
oView:SetOwnerView("GFEX010_01","MASTER")
oView:SetOwnerView("VIEW_01","DETAIL_AG")
oView:SetOwnerView("VIEW_02","DETAIL_DC")
oView:SetOwnerView("VIEW_03","DETAIL_IT")
oView:SetOwnerView("VIEW_04","DETAIL_TR")
oView:SetOwnerView("VIEW_05","DT_CAL01")
oView:SetOwnerView("VIEW_06","DT_CAL02")
oView:SetOwnerView("VIEW_07","DT_CAL03")
oView:SetOwnerView("VIEW_08","DT_OI1")
oView:SetOwnerView("VIEW_09","DT_OI2")

//Removendo campos chaves
oStruCal3:RemoveField("C3_NRCALC")
oStruCal2:RemoveField("C2_NRCALC")

oView:AddUserButton("Limpar","MAGIC_BMP",{|| GFE010CLE() }) //"Limpar"
oView:AddUserButton(STR0017,"MAGIC_BMP",{|| GFE010SIM() }) //"Simular"

Return oView

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} StrModNeg
Criação do objeto Struct
Uso restrito

@sample
StrModNeg()

@author Felipe M.
@since 14/07/10
@version 1.0
/*///------------------------------------------------------------------------------------------------
Static Function StrModNeg()

oStruct := FWFormModelStruct():New()
//-------------------------------------------------------------------
// Tabela
//-------------------------------------------------------------------
oStruct:AddTable( ;
'NEG'                             , ;       // [01] Alias da tabela
{ 'CONSNEG' }                     , ;       // [02] Array com os campos que correspondem a primary key
STR0018    )                        // [03] Descrição da tabela //"Considera Neg"

//-------------------------------------------------------------------
// Indices
//-------------------------------------------------------------------

oStruct:AddIndex( ;
01              , ;               // [01] Ordem do indice
'NEG'           , ;               // [02] ID
'CONSNEG'       , ;               // [03] Chave do indice
STR0018         , ;               // [04] Descrição do indice //"Considera Neg"
''              , ;               // [05] Expressão de lookUp dos campos de indice
''              , ;               // [06] Nickname do indice
.T.              )                // [07] Indica se o indice pode ser utilizado pela interface

//-------------------------------------------------------------------
// Campos
//-------------------------------------------------------------------
bRelac := &( ' { | oModel, cID, xValue | FwInitCpo( oModel, cID, xValue ), lRetorno := (' + '1' + '), FwCloseCpo( oModel, cID, xValue, .T.), lRetorno } ' )

oStruct:AddField( ;
STR0019                              , ;              // [01] Titulo do campo //"Considera Negociação?"
STR0019                              , ;              // [02] ToolTip do campo //"Considera Negociação?"
'CONSNEG'                            , ;              // [03] Id do Field
'C'			                         , ;              // [04] Tipo do campo
01                                   , ;              // [05] Tamanho do campo
0				                     , ;              // [06] Decimal do campo
NIL                                  , ;              // [07] Code-block de validação do campo
NIL       			                 , ;              // [08] Code-block de validação When do campo
{'1','2'}                            , ;              // [09] Lista de valores permitido do campo
NIL						             , ;              // [10] Indica se o campo tem preenchimento obrigatório
bRelac                 		         , ;              // [11] Code-block de inicializacao do campo
NIL                                  , ;              // [12] Indica se trata-se de um campo chave
NIL                                  , ;              // [13] Indica se o campo pode receber valor em uma operação de update.
.F.						              )               // [14] Indica se o campo é virtual


Return oStruct

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} StrVieNeg
Criação do objeto Struct
Uso restrito

@sample
StrVieNeg()

@author Felipe M.
@since 14/07/10
@version 1.0
/*///------------------------------------------------------------------------------------------------

Static Function StrViewNeg()
Local oStruct   := FWFormViewStruct():New()

oStruct:AddField( 			   ;
'CONSNEG'    				 , ;                // [01] Campo
'01'               			 , ;                // [02] Ordem
STR0019                      , ;                // [03] Titulo //"Considera Negociação?"
STR0019                      , ;                // [04] Descricao //"Considera Negociação?"
NIL                          , ;                // [05] Help
'COMBO'                      , ;                // [06] Tipo do campo   COMBO, Get ou CHECK
'@!'                         , ;                // [07] Picture
NIL                          , ;                // [08] PictVar
NIL                   		 , ;                // [09] F3
.T.	   	 					 , ;                // [10] Editavel
NIL               			 , ;                // [11] Folder
NIL               			 , ;                // [12] Group
{"1="+STR0020,"2="+STR0021}  , ;                // [13] Lista Combo //"Sim" ### "Não"
NIL                   		 , ;                // [14] Tam Max Combo
NIL                			 , ;                // [15] Inic. Browse
.F.                		    	)               // [16] Virtual

Return oStruct

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} StrModCal1
Criação do objeto Struct do Grid Cálculos
Uso restrito

@sample
StrModCal1()

@author Felipe M.
@since 14/07/10
@version 1.0
/*///------------------------------------------------------------------------------------------------
Static Function StrModCal1(nOp)
Local aCampos
Local nCont := 1

aCampos := {{STR0022 ,"C1_NRCALC"	,"C",16,0					 ,"@!"				  } ,; //"Número Cálculo"
			{STR0023 ,"C1_TPCALC"	,"C",10,0					 ,"@!"				  } ,; //"Tp Cálculo"
			{STR0024 ,"C1_TPFRT"    ,"C",01,0					 ,"@!" 				  } ,; //"Tp Frete"
			{STR0025 ,"C1_CDCOLT"	,"C",TamSX3("GU7_NMCID")[1],0,"@!"				  } ,; //"Cidade Coleta"
			{STR0026 ,"C1_CDCALC"	,"C",TamSX3("GU7_NMCID")[1],0,"@!"				  } ,; //"Cidade Cálculo"
			{STR0012 ,"C1_NRAGR"   	,"C",08,0                    ,"@!"				  } ,; //"Agrupador"
			{STR0027 ,"C1_VLPIS"    ,"N",12,2					 ,"@E 9,999,999.99"	  } ,; //"Valor PIS"
			{STR0028 ,"C1_VLCOF"   	,"N",12,2					 ,"@E 9,999,999.99"	  } ,; //"Valor COFINS"
			{STR0029 ,"C1_VLISS"   	,"N",12,2					 ,"@E 9,999,999.99"	  } ,; //"Valor ICMS/ISS"
			{STR0030 ,"C1_VALFRT"   ,"N",15,5					 ,"@E 9,999,999.99999"} ,; //"Valor Frete"
			{"Prazo de Entrega" ,"C1_DTPREN"  ,"D",8,0			 ,"@!"      		  } ,; //"Prazo de Entrega"
			{"Melhor Neg."      ,"C1_MENEG"   ,"C",1,0			 ,"@!"      		  }}   //"Melhor Negociação" 

//Se for 1 cria o Modelstruc se for 2 cria a viewstruc
If nOp == 1

	oStruct := FWFormModelStruct():New()

	//-------------------------------------------------------------------
	// Tabela
	//-------------------------------------------------------------------
	oStruct:AddTable(                      ;
	"Cal01"                              , ;       // [01] Alias da tabela
	{ "C1_NRCALC" }                      , ;       // [02] Array com os campos que correspondem a primary key
	STR0031                            )       // [03] Descrição da tabela //"Calculo01"

	//-------------------------------------------------------------------
	// Indices
	//-------------------------------------------------------------------
	oStruct:AddIndex( ;
	01              , ;               // [01] Ordem do indice
	"C1_NRCALC"     , ;               // [02] ID
	"C1_NRCALC"     , ;               // [03] Chave do indice
	STR0031         , ;               // [04] Descrição do indice //"Calculo01"
	''              , ;               // [05] Expressão de lookUp dos campos de indice
	''              , ;               // [06] Nickname do indice
	.T.              )                // [07] Indica se o indice pode ser utilizado pela interface

	//-------------------------------------------------------------------
	// Campos
	//-------------------------------------------------------------------

	While nCont < (len(aCampos) + 1)

		oStruct:AddField( ;
		aCampos[nCont][1]                    , ;              // [01] Titulo do campo
		aCampos[nCont][1]                    , ;              // [02] ToolTip do campo
		aCampos[nCont][2]                    , ;              // [03] Id do Field
		aCampos[nCont][3]		             , ;              // [04] Tipo do campo
		aCampos[nCont][4]                    , ;              // [05] Tamanho do campo
		aCampos[nCont][5]		             , ;              // [06] Decimal do campo
		{|| .T.}                             , ;              // [07] Code-block de validação do campo
		NIL                                  , ;              // [08] Code-block de validação When do campo
		{}                                   , ;              // [09] Lista de valores permitido do campo
		.F.						             , ;              // [10] Indica se o campo tem preenchimento obrigatório
		NIL                                  , ;              // [11] Code-block de inicializacao do campo
		.F.                                  , ;              // [12] Indica se trata-se de um campo chave
		.F.                                  , ;              // [13] Indica se o campo pode receber valor em uma operação de update.
		.F.						             )                // [14] Indica se o campo é virtual

		nCont++
	End

ElseIf nOp == 2

	oStruct := FWFormViewStruct():New()

	While nCont < (len(aCampos) + 1)

		oStruct:AddField( 			   ;
		aCampos[nCont][2]       	 , ;                // [01] Campo
		Alltrim(STR(nCont))   		 , ;                // [02] Ordem
		aCampos[nCont][1]  			 , ;                // [03] Titulo
		aCampos[nCont][1]            , ;                // [04] Descricao
		NIL                          , ;                // [05] Help
		'GET'                        , ;                // [06] Tipo do campo   COMBO, Get ou CHECK
		aCampos[nCont][6]            , ;                // [07] Picture
		NIL                          , ;                // [08] PictVar
		NIL                   		 , ;                // [09] F3
		.T.	   	 					 , ;                // [10] Editavel
		NIL               			 , ;                // [11] Folder
		NIL               			 , ;                // [12] Group
		NIL                          , ;                // [13] Lista Combo
		NIL                    		 , ;                // [14] Tam Max Combo
		NIL                			 , ;                // [15] Inic. Browse
		.F.                		    	)               // [16] Virtual

		nCont++
	End

EndIf

Return oStruct

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} StrModCal2
Criação do objeto Struct do segundo Grid Cálculos
Uso restrito

@sample
StrModCal2()

@author Felipe M.
@since 14/07/10
@version 1.0
/*///------------------------------------------------------------------------------------------------
Static Function StrModCal2(nOp)
Local aCampos
Local nCont := 1

aCampos := {{STR0022 ,   "C2_NRCALC"  , "C",  06, 0, "@!"    } ,; //"Número Cálculo"
			{STR0032 ,	"C2_CDCLFR"  , "C",  04, 0, "@!"    } ,; //"Class Frete"
			{STR0033 ,	"C2_CDTPOP"  , "C",  10, 0, "@!"    } ,; //"Tipo Operação"
			{STR0013 ,	"C2_SEQ"     , "C",  04, 0, "@!"    } ,; //"Trecho"
			{STR0034 ,	"C2_CDEMIT"  , "C",  TamSx3("GU3_CDEMIT")[1], 0, "@!"    } ,; //"Emit Tabela"
			{STR0035 ,	"C2_NRTAB"   , "C",  06, 0, "@!"	} ,; //"Nr tabela "
			{STR0036 ,	"C2_NRNEG"   , "C",  06, 0, "@!"	} ,; //"Nr Negoc"
			{STR0037 ,	"C2_NRROTA"  , "C",  16, 0, "@!"    } ,; //"Rota"
			{STR0038 ,	"C2_DTVAL"   , "D",  08, 0, ""	    } ,; //"Data Validade"
			{STR0039 ,	"C2_CDFXTV"  , "C",  04, 0, "@!"	} ,; //"Faixa"
			{STR0040 ,	"C2_CDTPVC"  , "C",  10, 0, "@!"    } }  //"Tipo Veículo"
//Se for 1 cria o Modelstruc se for 2 cria a viewstruc
If nOp == 1

	oStruct := FWFormModelStruct():New()

	//-------------------------------------------------------------------
	// Tabela
	//-------------------------------------------------------------------
	oStruct:AddTable(                      ;
	"Cal02"                                , ;       // [01] Alias da tabela
	{ "C2_CDCLFR" }                        , ;       // [02] Array com os campos que correspondem a primary key
	STR0041                            )       // [03] Descrição da tabela //"Calculo02"

	//-------------------------------------------------------------------
	// Indices
	//-------------------------------------------------------------------
	oStruct:AddIndex( ;
	01              , ;               // [01] Ordem do indice
	"C2_CDCLFR"     , ;               // [02] ID
	"C2_CDCLFR"     , ;               // [03] Chave do indice
	STR0041     , ;               // [04] Descrição do indice //"Calculo02"
	''              , ;               // [05] Expressão de lookUp dos campos de indice
	''              , ;               // [06] Nickname do indice
	.T.              )                // [07] Indica se o indice pode ser utilizado pela interface

	//-------------------------------------------------------------------
	// Campos
	//-------------------------------------------------------------------

	While nCont < (len(aCampos) + 1)

		oStruct:AddField( ;
		aCampos[nCont][1]                    , ;              // [01] Titulo do campo
		aCampos[nCont][1]                    , ;              // [02] ToolTip do campo
		aCampos[nCont][2]                    , ;              // [03] Id do Field
		aCampos[nCont][3]		             , ;              // [04] Tipo do campo
		aCampos[nCont][4]                    , ;              // [05] Tamanho do campo
		aCampos[nCont][5]		             , ;              // [06] Decimal do campo
		{|| .T.}                             , ;              // [07] Code-block de validação do campo
		NIL                                  , ;              // [08] Code-block de validação When do campo
		{}                                   , ;              // [09] Lista de valores permitido do campo
		.F.						             , ;              // [10] Indica se o campo tem preenchimento obrigatório
		NIL                                  , ;              // [11] Code-block de inicializacao do campo
		.F.                                  , ;              // [12] Indica se trata-se de um campo chave
		.F.                                  , ;              // [13] Indica se o campo pode receber valor em uma operação de update.
		.F.						             )                // [14] Indica se o campo é virtual

		nCont++
	End

ElseIf nOp == 2

	oStruct := FWFormViewStruct():New()

	While nCont < (len(aCampos) + 1)

		oStruct:AddField( 			   ;
		aCampos[nCont][2]       	 , ;                // [01] Campo
		Alltrim(STR(nCont))   		 , ;                // [02] Ordem
		aCampos[nCont][1]  			 , ;                // [03] Titulo
		aCampos[nCont][1]            , ;                // [04] Descricao
		NIL                          , ;                // [05] Help
		'GET'                        , ;                // [06] Tipo do campo   COMBO, Get ou CHECK
		aCampos[nCont][6]            , ;                // [07] Picture
		NIL                          , ;                // [08] PictVar
		NIL                   		 , ;                // [09] F3
		.T.	   	 					 , ;                // [10] Editavel
		NIL               			 , ;                // [11] Folder
		NIL               			 , ;                // [12] Group
		NIL                          , ;                // [13] Lista Combo
		NIL                    		 , ;                // [14] Tam Max Combo
		NIL                			 , ;                // [15] Inic. Browse
		.F.                		    	)               // [16] Virtual

		nCont++
	End

EndIf

Return oStruct

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} StrModCal3
Criação do objeto Struct do terceiro Grid Cálculos
Uso restrito

@sample
StrModCal3()

@author Felipe M.
@since 14/07/10
@version 1.0
/*///------------------------------------------------------------------------------------------------
Static Function StrModCal3(nOp)
Local aCampos
Local nCont := 1

aCampos := {{STR0022 , "C3_NRCALC"  , "C",  16, 0, "@!"  		       } ,; //"Número Cálculo"
			{STR0032 , "C3_CDCLFR"  , "C",  04, 0, "@!"  	           } ,; //"Class Frete"
			{STR0033 , "C3_CDTPOP"  , "C",  10, 0, "@!"  		       } ,; //"Tipo Operação"
			{STR0013 , "C3_SEQ"     , "C",  04, 0, "@!" 	    	   } ,; //"Trecho"
			{STR0042 , "C3_COPFRT"  , "C",  20, 0, "@!"                } ,; //"Componente"
			{STR0043 , "C3_CATVAL"  , "C",  20, 0, "@!"                } ,; //"Categoria"
			{STR0030 , "C3_VLFRT"   , "N",  15, 5, "@E 9,999,999.99999"} ,; //"Valor Frete"
			{STR0044 , "C3_QTDCALC" , "N",  15, 5, "@E 9,999,999.99999"} ,; //"Qtde Cálculo"
			{STR0045 , "C3_TOTFRT"  , "C",  01, 0, "@!"                } }  //"Total Frete"
//Se for 1 cria o Modelstruc se for 2 cria a viewstruc
If nOp == 1

	oStruct := FWFormModelStruct():New()

	//-------------------------------------------------------------------
	// Tabela
	//-------------------------------------------------------------------
	oStruct:AddTable(                      ;
	"Cal03"                                , ;       // [01] Alias da tabela
	{ "C3_COPFRT" }                        , ;       // [02] Array com os campos que correspondem a primary key
	STR0046                            )       // [03] Descrição da tabela //"Calculo03"

	//-------------------------------------------------------------------
	// Indices
	//-------------------------------------------------------------------
	oStruct:AddIndex( ;
	01              , ;               // [01] Ordem do indice
	"C3_COPFRT"     , ;               // [02] ID
	"C3_COPFRT"     , ;               // [03] Chave do indice
	STR0046         , ;               // [04] Descrição do indice //"Calculo03"
	''              , ;               // [05] Expressão de lookUp dos campos de indice
	''              , ;               // [06] Nickname do indice
	.T.              )                // [07] Indica se o indice pode ser utilizado pela interface

	//-------------------------------------------------------------------
	// Campos
	//-------------------------------------------------------------------

	While nCont < (len(aCampos) + 1)

		oStruct:AddField( ;
		aCampos[nCont][1]                    , ;              // [01] Titulo do campo
		aCampos[nCont][1]                    , ;              // [02] ToolTip do campo
		aCampos[nCont][2]                    , ;              // [03] Id do Field
		aCampos[nCont][3]		             , ;              // [04] Tipo do campo
		aCampos[nCont][4]                    , ;              // [05] Tamanho do campo
		aCampos[nCont][5]		             , ;              // [06] Decimal do campo
		NIL                                  , ;              // [07] Code-block de validação do campo
		NIL                                  , ;              // [08] Code-block de validação When do campo
		If(aCampos[nCont][2]=="C3_TOTFRT",{'1','2'},{})  , ;  // [09] Lista de valores permitido do campo
		NIL						             , ;              // [10] Indica se o campo tem preenchimento obrigatório
		NIL                                  , ;              // [11] Code-block de inicializacao do campo
		NIL                                  , ;              // [12] Indica se trata-se de um campo chave
		NIL                                  , ;              // [13] Indica se o campo pode receber valor em uma operação de update.
		.F.						             )                // [14] Indica se o campo é virtual

		nCont++
	End

ElseIf nOp == 2

	oStruct := FWFormViewStruct():New()

	While nCont < (len(aCampos) + 1)

			oStruct:AddField( 			   ;
		aCampos[nCont][2]       	 , ;                // [01] Campo
		Alltrim(STR(nCont))   		 , ;                // [02] Ordem
		aCampos[nCont][1]  			 , ;                // [03] Titulo
		aCampos[nCont][1]            , ;                // [04] Descricao
		NIL                          , ;                // [05] Help
		If(aCampos[nCont][2]=="C3_TOTFRT",'COMBO','GET'), ;   // [06] Tipo do campo   COMBO, Get ou CHECK
		aCampos[nCont][6]            , ;                // [07] Picture
		NIL                          , ;                // [08] PictVar
		NIL                   		 , ;                // [09] F3
		.T.	   	 					 , ;                // [10] Editavel
		NIL               			 , ;                // [11] Folder
		NIL               			 , ;                // [12] Group
		If(aCampos[nCont][2]=="C3_TOTFRT",{"1="+STR0020,"2="+STR0021},NIL) , ;   // [13] Lista Combo //"Sim" ### "Não"
		NIL                    		 , ;                // [14] Tam Max Combo
		NIL                			 , ;                // [15] Inic. Browse
		.F.                		    	)               // [16] Virtual

		nCont++
	End

EndIf

Return oStruct

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} StrModOI1
Criação do objeto Struct do primeiro Grid Outras Informações
Uso restrito

@sample
StrModOI1()

@author Felipe M.
@since 14/07/10
@version 1.0
/*///------------------------------------------------------------------------------------------------
Static Function StrModOI1(nOp)
Local aCampos
Local nCont := 1

aCampos := {{STR0012 ,	"OI1_NRROM"   , "C",  08, 0, "@!" } ,; //"Agrupador"
			{STR0047 ,	"OI1_NRTAB"   , "C",  06, 0, "@!" } ,; //"Nr da Tabela"
			{STR0048 ,	"OI1_NRNEG"   , "C",  06, 0, "@!" } ,; //"Negociacao"
			{STR0049 ,	"OI1_NRCALC"  , "C",  06, 0, "@!" } ,; //"Nr do Calculo"
			{STR0032 ,	"OI1_CDCLFR"  , "C",  16, 0, "@!" } ,; //"Class Frete"
			{STR0033 ,  "OI1_TPOP"    , "C",  10, 0, "@R" } ,; //"Tipo Operação"
			{STR0050 ,	"OI1_CDEMIT"  , "C",  TamSx3("GU3_CDEMIT")[1], 0, "@!" } ,; //"Emitente"
			{STR0051 ,	"OI1_VIGENC"  , "C",  01, 0, "@!" } ,; //"Vigencia?"
			{STR0052 ,	"OI1_FAIXA"   , "C",  01, 0, "@!" } ,; //"Faixa?"
			{STR0053 ,	"OI1_TPVEIC"  , "C",  01, 0, "@!" } ,; //"Tipo Veículo?"
			{STR0054 ,	"OI1_ROTA"    , "C",  01, 0, "@!" }}

//Se for 1 cria o Modelstruc se for 2 cria a viewstruc
If nOp == 1

	oStruct := FWFormModelStruct():New()

	//-------------------------------------------------------------------
	// Tabela
	//-------------------------------------------------------------------
	oStruct:AddTable(                      ;
	"Inf01"                                , ;       // [01] Alias da tabela
	{ "CDCLFR" }                           , ;       // [02] Array com os campos que correspondem a primary key
	STR0055                  )       // [03] Descrição da tabela //"Outras Informações 01"

	//-------------------------------------------------------------------
	// Indices
	//-------------------------------------------------------------------
	oStruct:AddIndex(             ;
	01                          , ;               // [01] Ordem do indice
	"CDCLFR"	                , ;               // [02] ID
	"CDCLFR"        			, ;               // [03] Chave do indice
	STR0055     , ;               // [04] Descrição do indice //"Outras Informações 01"
	''              			, ;               // [05] Expressão de lookUp dos campos de indice
	''              			, ;               // [06] Nickname do indice
	.T.              			  )               // [07] Indica se o indice pode ser utilizado pela interface

	//-------------------------------------------------------------------
	// Campos
	//-------------------------------------------------------------------

	While nCont < (len(aCampos) + 1)

		oStruct:AddField( ;
		aCampos[nCont][1]                    , ;              // [01] Titulo do campo
		aCampos[nCont][1]                    , ;              // [02] ToolTip do campo
		aCampos[nCont][2]                    , ;              // [03] Id do Field
		aCampos[nCont][3]		             , ;              // [04] Tipo do campo
		aCampos[nCont][4]                    , ;              // [05] Tamanho do campo
		aCampos[nCont][5]		             , ;              // [06] Decimal do campo
		NIL                                  , ;              // [07] Code-block de validação do campo
		NIL                                  , ;              // [08] Code-block de validação When do campo
			If(aCampos[nCont][2]$"OI1_VIGENC,OI1_FAIXA,OI1_TPVEIC,OI1_ROTA",{'1','2'},{})                    , ;              // [09] Lista de valores permitido do campo
		NIL						             , ;              // [10] Indica se o campo tem preenchimento obrigatório
		NIL                                  , ;              // [11] Code-block de inicializacao do campo
		NIL                                  , ;              // [12] Indica se trata-se de um campo chave
		NIL                                  , ;              // [13] Indica se o campo pode receber valor em uma operação de update.
		.F.						             )                // [14] Indica se o campo é virtual

		nCont++
	End

ElseIf nOp == 2

	oStruct := FWFormViewStruct():New()

	While nCont < (len(aCampos) + 1)

			oStruct:AddField( 			   ;
		aCampos[nCont][2]       	 , ;                // [01] Campo
		Alltrim(STR(nCont))   		 , ;                // [02] Ordem
		aCampos[nCont][1]  			 , ;                // [03] Titulo
		aCampos[nCont][1]            , ;                // [04] Descricao
		NIL                          , ;                // [05] Help
		If(aCampos[nCont][2]$"OI1_VIGENC,OI1_FAIXA,OI1_TPVEIC,OI1_ROTA",'COMBO','GET')         , ;                // [06] Tipo do campo   COMBO, Get ou CHECK
		aCampos[nCont][6]            , ;                // [07] Picture
		NIL                          , ;                // [08] PictVar
		NIL                   		 , ;                // [09] F3
		.F.	   	    				 , ;                // [10] Editavel
		NIL               			 , ;                // [11] Folder
		NIL               			 , ;                // [12] Group
		If(aCampos[nCont][2]$"OI1_VIGENC,OI1_FAIXA,OI1_TPVEIC,OI1_ROTA",{"1="+STR0020,"2="+STR0021},NIL) , ;                // [13] Lista Combo
		NIL                    		 , ;                // [14] Tam Max Combo
		NIL                			 , ;                // [15] Inic. Browse
		.F.                		    	)               // [16] Virtual

		nCont++
	End

EndIf

Return oStruct

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} StrModOI2
Criação do objeto Struct do primeiro Grid Outras Informações
Uso restrito

@sample
StrModOI1()

@author Felipe M.
@since 14/07/10
@version 1.0
/*///------------------------------------------------------------------------------------------------
Static Function StrModOI2(nOp)
Local aCampos
Local nCont := 1

aCampos := {{STR0012 ,	"OI2_NRROM" , "C",  08, 0, "@!"  } ,; //"Agrupador"
				{STR0047 ,	"OI2_NRTAB" , "C",  06, 0, "@!"  } ,; //"Nr da Tabela"
				{STR0048 ,	"OI2_NRNEG" , "C",  06, 0, "@!"  } ,; //"Negociacao"
				{STR0037 ,	"OI2_NRROTA", "C",  16, 0, "@!"  } ,; //"Rota"
				{STR0056 ,	"OI2_DESROT", "C", 155, 0, "@!"  } ,; //"Descrição"
				{STR0057 ,	"OI2_SELEC" , "C",  01, 0, ""    } }  //"Selecionada?"
//Se for 1 cria o Modelstruc se for 2 cria a viewstruc
If nOp == 1

	oStruct := FWFormModelStruct():New()

	//-------------------------------------------------------------------
	// Tabela
	//-------------------------------------------------------------------
	oStruct:AddTable(                      ;
	"Inf02"                                , ;       // [01] Alias da tabela
	{ "NRROTA" }                           , ;       // [02] Array com os campos que correspondem a primary key
	STR0058                  )       // [03] Descrição da tabela //"Outras Informações 02"

	//-------------------------------------------------------------------
	// Indices
	//-------------------------------------------------------------------
	oStruct:AddIndex(             ;
	01                          , ;               // [01] Ordem do indice
	"NRROTA"	                , ;               // [02] ID
	"NRROTA"        			, ;               // [03] Chave do indice
	STR0058     , ;               // [04] Descrição do indice //"Outras Informações 02"
	''              			, ;               // [05] Expressão de lookUp dos campos de indice
	''              			, ;               // [06] Nickname do indice
	.T.              			  )               // [07] Indica se o indice pode ser utilizado pela interface

	//-------------------------------------------------------------------
	// Campos
	//-------------------------------------------------------------------

	While nCont < (len(aCampos) + 1)

		oStruct:AddField( ;
		aCampos[nCont][1]                    , ;              // [01] Titulo do campo
		aCampos[nCont][1]                    , ;              // [02] ToolTip do campo
		aCampos[nCont][2]                    , ;              // [03] Id do Field
		aCampos[nCont][3]		             , ;              // [04] Tipo do campo
		aCampos[nCont][4]                    , ;              // [05] Tamanho do campo
		aCampos[nCont][5]		             , ;              // [06] Decimal do campo
		NIL                                  , ;              // [07] Code-block de validação do campo
		NIL                                  , ;              // [08] Code-block de validação When do campo
		If(aCampos[nCont][2]$"OI2_SELEC",{'1','2'},{}), ;     // [09] Lista de valores permitido do campo
		NIL						             , ;              // [10] Indica se o campo tem preenchimento obrigatório
		NIL                                  , ;              // [11] Code-block de inicializacao do campo
		NIL                                  , ;              // [12] Indica se trata-se de um campo chave
		NIL                                  , ;              // [13] Indica se o campo pode receber valor em uma operação de update.
		.F.						             )                // [14] Indica se o campo é virtual

		nCont++
	End

ElseIf nOp == 2

	oStruct := FWFormViewStruct():New()

	While nCont < (len(aCampos) + 1)

			oStruct:AddField( 			   ;
		aCampos[nCont][2]       	 , ;                					// [01] Campo
		Alltrim(STR(nCont))   		 , ;               						// [02] Ordem
		aCampos[nCont][1]  			 , ;                					// [03] Titulo
		aCampos[nCont][1]            , ;                					// [04] Descricao
		NIL                          , ;                					// [05] Help
		If(aCampos[nCont][2]$"OI2_SELEC",'COMBO','GET') , ;                 // [06] Tipo do campo   COMBO, Get ou CHECK
		aCampos[nCont][6]            , ;                					// [07] Picture
		NIL                          , ;                					// [08] PictVar
		NIL                   		 , ;                					// [09] F3
		.F.	   	 					 , ;                					// [10] Editavel
		NIL               			 , ;                					// [11] Folder
		NIL               			 , ;                					// [12] Group
			If(aCampos[nCont][2]$"OI2_SELEC",{"1="+STR0020,"2="+STR0021},NIL)  , ;        // [13] Lista Combo //"Sim" ### "Não"
		NIL                    		 , ;                					// [14] Tam Max Combo
		NIL                			 , ;                					// [15] Inic. Browse
		.F.                		    	)               					// [16] Virtual

		nCont++
	End

EndIf

Return oStruct

//---------------------------------------------------------------------------------------------------

Static Function GFE010CLE(lPergunta)
Local oModel	:= FWMODELACTIVE()
Local lRet		:= .T.
Local lReativa	:= .T. 
Default lPergunta := .T.

if lPergunta
	lReativa := MsgyesNo(STR0087) //"Deseja apagar todos os dados de simulação?"
EndIf

If lReativa
	oModel:Deactivate()
	oModel:Activate()
Else
	lRet := .F.
EndIf

Return lRet

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEX010SIM
Função que armazena os dados da simulação
Uso restrito

@sample
GFEX010SIM()

@author Felipe M.
@since 14/07/10
@version 1.0
/*///------------------------------------------------------------------------------------------------
Static Function GFE010SIM()
	Local nCont
	Local lRet := .T.
	Local oModelPai  
	Local oModelNeg  // oModel do campo "Considerar Negociação"
	Local oModelAgr  // oModel do grid "Agrupadores"
	Local oModelDC   // oModel do grid "Doc Carga"
	Local oModelIt   // oModel do grid "Item Carga"
	Local oModelTr   // oModel do grid "Trechos"
	Local oModelCal1 // oModel do primeiro grid da aba de "Cálculos"
	Local oModelCal2 // oModel do segundo  grid da aba de "Cálculos"
	Local oModelCal3 // oModel do terceiro grid da aba de "Cálculos"
	Local oModelOI1  // oModel do primeiro grid da aba de "Outras informações"
	Local oModelOI2  // oModel do segundo grid da aba de "Outras informações"
	Local nTotFrete  := 0, nCt1 := 1, nCt2 := 1, nCt3 := 1
	Local nLineCal01 := 1
	Local cSeek      := ''/*Variavel responsavel por guardar o valor da chave */, CDTPVC := ''
	Local lSelec     := .F.
	Local aRet := {}
	Local cSelTabFrt := SUPERGETMV("MV_ESCTBAT",.F.,"1") // Escolha da negociação
	Local aMelhorNeg := {}
	Local nX
	Local lBlind := IsBlind()
	Local lSeek := .F.
	Local iLogProc := 1
	Local lLog := IIF(SuperGetMv("MV_LOGCALC",,'1') == '2',.F., .T.)
	Local nQtdeUnit := 0
	Local nAux		:= 0
	Local lA410SmlFrt := IsInCallStack("A410SMLFRT")	//Simulação de Frete da rotina de Pedidos de Venda

	Private cTRBCCF, cTRBITE, cTRBTRE, cTRBTCF, cTRBUNC, cTRBDOC, cTRBAGRU   				 //variaveis utilizadas na rotina de calculo de frete
	Private cTRBPED, cTRBSTF, cTRBSIM, CTRBENT
	Private cArqCCF, cArqITE, cArqTRE, cArqTCF, cArqUNC, cArqGRU, cArqDOC, cArqAGR,  cArqSIM    //variaveis utilizadas na rotina de calculo de frete
	Private cTRBCal01
	Private cArqCal01 
	Private lTabTemp := .F.
	Private aTRBGRB
	Private idpGRB := 1 // posição do array de Documentos de carga
	Private idxGRB := 1 // Indice da array de Documentos de carga
	Private _aCmpGRB :={"NRGRUP",;
						"EMISDC",;
						"SERDC" ,;
						"NRDC"  ,;
						"CDTPDC",;
						"CDREM" ,;
						"CDDEST",;
						"ENTEND",;
						"ENTBAI",;
						"ENTNRC",;
						"ENTCEP",;
						"NRREG" ,;
						"TPFRET",;
						"USO"   ,;
						"CARREG",;
						"NRAGRU",;
						"QTVOL"}
	Private aTRBTCF
	Private idpTCF := 1 // posição do array cTRBTCF
	Private idxTCF := 1 // Indice da array cTRBTCF
	Private _aCmpTCF := {"NRCALC",; //1
						"CDCLFR",; //2
						"CDTPOP",; //3
						"SEQ"   ,; //4
						"DTVIGE",; //5
						"ITEM"  ,; //6
						"CDTRP" ,; //7
						"NRTAB" ,; //8
						"NRNEG" ,; //9
						"CDFXTV",; //10
						"CDTPVC",; //11
						"NRROTA",; //12
						"QTCALC",; //13
						"QTDE"  ,; //14
						"PESOR" ,; //15
						"PESCUB",; //16
						"QTDALT",; //17
						"VALOR" ,; //18
						"VOLUME",; //19
						"NRGRUP",; //20
						"CDEMIT",; //21
						"PEDROM",; //22
						"PESPED",; //23
						"PRAZO" ,;  //24
						"DELETE"}

	Private aTRBUNC := {} // Indice 1

	Private idpUNC := 1 // posição do array cTRBUNC
	Private idxUNC := 1 // Indice  da array cTRBUNC
	Private _aCmpUNC := {"NRCALC",; // 1
						"TIPO"  ,; // 2
						"FINALI",; // 3
						"DTPREN",; // 4
						"HRPREN",; // 5
						"TPTRIB",; // 6
						"BASICM",; // 7
						"PCICMS",; // 8
						"VLICMS",; // 9
						"ICMRET",; // 10
						"BASISS",; // 11
						"PCISS" ,; // 12
						"VLISS" ,; // 13
						"BAPICO",; // 14
						"VLPIS" ,; // 15
						"VLCOFI",; // 16
						"PCREIC",; // 17
						"VALTAB",; // 18
						"NRAGRU",; // 19
						"IDFRVI",; // 20
						"SEQTRE",; // 21
						"CALBAS",; // 22
						"ADICIS",; // 23
						"CHVGWU",; // 24
						"DELETE",; // 25
						"NRLCENT",;// 26
						"GRURAT"}  // 27 
	Private aTRBTRE := {} // Indice 1
	Private idpTRE := 1 // posição do array cTRBTRE
	Private idxTRE := 1 // Indice  da array cTRBTRE
	Private _aCmpTRE := {"EMISDC",; // 1
						"SERDC" ,; // 2
						"NRDC"  ,; // 3
						"CDTPDC",; // 4
						"SEQ"   ,; // 5
						"CDTRP" ,; // 6
						"NRCIDD",; // 7
						"CDTPVC",; // 8
						"PAGAR" ,; // 9
						"ORIGEM",; // 10
						"DESTIN",; // 11
						"NRGRUP",; // 12
						"NRCALC",; // 13
						"DELETE"}  // 14

	Private aTRBCCF3 := {} // Indice 3

	Private idpCCF := 1 // posição do array cTRBCCF
	Private idxCCF := 1 // Indice  da array cTRBCCF
	Private _aCmpCCF := {	"NRCALC",; // 1
							"CDCLFR",; // 2
							"CDTPOP",; // 3
							"SEQ"   ,; // 4
							"CDCOMP",; // 5
							"CATVAL",; // 6
							"QTDE"  ,; // 7
							"VALOR" ,; // 8
							"TOTFRE",; // 9
							"BASIMP",; // 10
							"BAPICO",; // 11
							"FREMIN",; // 12
							"IDMIN" ,; // 13
							"VLFRMI",; // 14
							"DELETE"}  // 15

		Private aTRBSIM := {} // Indice 1

		Private idpSIM := 1 // posição do array de Documentos de carga cTRBSIM
		Private idxSIM := 1 // Indice da array de Documentos de carga cTRBSIM

		Private _aCmpSIM :={"NRROM"  ,; //Numero do Romaneio
							"DOCS"   ,;
							"CDTRP"  ,;
							"NRTAB"  ,;
							"NRNEG"  ,;
							"NRCALC" ,;
							"CDCLFR" ,;
							"CDTPOP" ,;
							"CDFXTV" ,;
							"CDTPVC" ,;
							"NRROTA" ,;
							"DESROT" ,;
							"DTVALI" ,;
							"DTVALF" ,;
							"VLFRT"  ,;
							"PRAZO"  ,;
							"TPTAB"  ,;
							"EMIVIN" ,;
							"TABVIN" ,;
							"NRTAB1" ,;
							"ATRFAI" ,;
							"QTKGM3" ,;
							"UNIFAI" ,;
							"TPLOTA" ,;
							"DEMCID" ,;
							"QTFAIXA",;
							"TPVCFX" ,;
							"SELEC"  ,;
							"VALROT" ,;
							"VALFAI" ,;
							"VALTPVC",;
							"VALDATA",;
							"ROTSEL" ,;
							"ERRO"}	

	/*************************************************************/
/*************************************************************/

GFEX010POS()

oModelPai  := FWMODELACTIVE()
oModelNeg  := oModelPai:GetModel("GFEX010_01")
oModelAgr  := oModelPai:GetModel("DETAIL_01") 
oModelDC   := oModelPai:GetModel("DETAIL_02") 
oModelIt   := oModelPai:GetModel("DETAIL_03") 
oModelTr   := oModelPai:GetModel("DETAIL_04") 
oModelCal1 := oModelPai:GetModel("DETAIL_05") 
oModelCal2 := oModelPai:GetModel("DETAIL_06") 
oModelCal3 := oModelPai:GetModel("DETAIL_07") 
oModelOI1  := oModelPai:GetModel("DETAIL_08") 
oModelOI2  := oModelPai:GetModel("DETAIL_09")
 
aAgrFrt    := {} 								 // Array das informações do Agrupadores de frete
aAuxAgrFrt := {}								 // Array auxiliar para armazenar as informações no Array aAgrFrt

aDocCarg 	:= {}								 // Array das informações do Documento de frete
aAuxDocCarg := {}								 // Array auxiliar para armazenar as informações no Array aDocCarg

aTrchDoc 	:= {}								 // Array das informações do Trecho
aAuxTrchDoc := {}								 // Array auxiliar para armazenar as informações no Array aTrchDoc

aItDoc 	  := {}								     // Array das informações do Itens do Documento
aAuxItDoc := {}								 	 // Array auxiliar para armazenar as informações no Array aTrchDoc
//Limpando os dados dos grid caso haja informações de uma simulação anterior
oModelCal1:DeActivate(.T.)
oModelCal1:Activate()
oModelCal2:DeActivate(.T.)
oModelCal2:Activate()
oModelCal3:DeActivate(.T.)
oModelCal3:Activate()
oModelOI1:DeActivate(.T.)
oModelOI1:Activate()
oModelOI2:DeActivate(.T.)
oModelOI2:Activate()

If !lBlind
	oModelCal1:setNoUpdateLine(.F.)
	oModelCal2:setNoUpdateLine(.F.)
	oModelCal3:setNoUpdateLine(.F.)
EndIf	
If !empty(oModelCal1:GetValue('C1_NRCALC'))
	Help( ,, 'Help',, "Para fazer uma nova simulação todas as informações anteriores tem que ser limpas.", 1, 0 ) 
	GFE010CLE()
	RETURN .T.
EndIf
//Tabela de Calculo de frete do primeiro Grid de cálculo
aDBFCal01 := {{"NRCALC","C",16 ,0},; //Numero da Unidade de Calculo
			{"TIPO"  ,"C",01 ,0},; //Tipo (1=Normal, 6=Redespacho)
			{"TPFRET","C",01 ,0},; //Tipo de Frete
			{"ORIGEM","C",50 ,0},; //Origem
			{"DESTIN","C",50 ,0},; //Destino
			{"CALBAS","C",16 ,0},; //Nr Calculo Baseado
			{"VLPIS" ,"N",12 ,2} ,; //Valor PIS
			{"VLCOF" ,"N",12 ,2} ,; //Valor Cofins
			{"VLISS" ,"N",12 ,2} ,; //Valor ICMS/ISS
			{"NRAGRU","C",10 ,0},;  // Valor Frete
			{"DTPREN","D",8 ,0}} // Data de Entrega


cTRBCal01 := GFECriaTab({aDBFCal01,{"NRCALC"}})  //aqui

If GFEX010VAL(oModelAgr,oModelDC,oModelIt,oModelTr )

	//Armazenando o valor dos agrupadores de frete
	For nCont := 1 To oModelAgr:GetQtdLine()
		oModelAgr:GoLine( nCont )

		If !(oModelAgr:IsDeleted(nCont))
			aAuxAgrFrt := {}

			AADD(aAuxAgrFrt, oModelAgr:GetValue('GWN_NRROM'  ,nCont))       //Numero do Agrupador
			AADD(aAuxAgrFrt, oModelAgr:GetValue('GWN_CDTRP'  ,nCont))       //Transportador (GU3)
			AADD(aAuxAgrFrt, oModelAgr:GetValue('GWN_CDTPVC' ,nCont))       //Tipo de Veiculo (GV3)
			AADD(aAuxAgrFrt, oModelAgr:GetValue('GWN_CDCLFR' ,nCont))       //Classificacao de Frete
			AADD(aAuxAgrFrt, oModelAgr:GetValue('GWN_CDTPOP' ,nCont))       //Tipo de Operacao (GV4)
			AADD(aAuxAgrFrt, oModelAgr:GetValue('GWN_DISTAN' ,nCont))       //Distancia Percorrida
			AADD(aAuxAgrFrt, oModelAgr:GetValue('GWN_NRCIDD' ,nCont))       //Cidade Destino
			AADD(aAuxAgrFrt, oModelAgr:GetValue('GWN_CEPD'   ,nCont))       //CEP Destino
			AADD(aAuxAgrFrt, "0"                                    )       //Erro

			AADD(aAgrFrt, aAuxAgrFrt)
		 EndIf

	Next nCont

	//Armazenando o valor dos Documentos de frete
	For nCont := 1 To oModelDC:GetQtdLine()
		oModelDC:GoLine( nCont )

		If !(oModelDC:IsDeleted(nCont))

			aAuxDocCarg   := {}

			nQtdeUnit := oModelDC:GetValue('GW1_QTVOL'  , nCont)

			If nQtdeUnit == 0
				For nAux := 1 To oModelIt:GetQtdLine()
					If !(oModelIt:IsDeleted(nAux)) .And.;
						oModelIt:GetValue('GW8_EMISDC' , nAux) == oModelDC:GetValue('GW1_EMISDC' , nCont) .And.;
						oModelIt:GetValue('GW8_SERDC' , nAux)  == oModelDC:GetValue('GW1_SERDC' , nCont) .And.;
						oModelIt:GetValue('GW8_NRDC' , nAux)   == oModelDC:GetValue('GW1_NRDC' , nCont) .And.;
						oModelIt:GetValue('GW8_CDTPDC' , nAux) == oModelDC:GetValue('GW1_CDTPDC' , nCont)

						nQtdeUnit += oModelIt:GetValue('GW8_QTDE' , nAux) 	// Quantidade do Item
					EndIf
				Next nAux
			EndIf
			
			AADD(aAuxDocCarg, oModelDC:GetValue('GW1_EMISDC' , nCont)) //Emitente do Documento
			AADD(aAuxDocCarg, oModelDC:GetValue('GW1_SERDC'  , nCont)) //Serie do Documento
			AADD(aAuxDocCarg, oModelDC:GetValue('GW1_NRDC'   , nCont)) //Numero do Documento
			AADD(aAuxDocCarg, oModelDC:GetValue('GW1_CDTPDC' , nCont)) //Tipo do Documento
			AADD(aAuxDocCarg, oModelDC:GetValue('GW1_CDREM'  , nCont)) //Remetente do Documento
			AADD(aAuxDocCarg, oModelDC:GetValue('GW1_CDDEST' , nCont)) //Destinatario do Documento
			AADD(aAuxDocCarg, oModelDC:GetValue('GW1_ENTEND' , nCont)) //Endereco de Entrega
			AADD(aAuxDocCarg, oModelDC:GetValue('GW1_ENTBAI' , nCont)) //Bairro de entrega
			AADD(aAuxDocCarg, oModelDC:GetValue('GW1_ENTNRC' , nCont)) //Cidade de Entrega
			AADD(aAuxDocCarg, oModelDC:GetValue('GW1_ENTCEP' , nCont)) //CEP de Entrega
			AADD(aAuxDocCarg, oModelDC:GetValue('GW1_NRREG'  , nCont)) //Região de destino
			AADD(aAuxDocCarg, oModelDC:GetValue('GW1_TPFRET' , nCont)) //Tipo de Frete
			AADD(aAuxDocCarg, oModelDC:GetValue('GW1_ICMSDC' , nCont)) //ICMS?
			AADD(aAuxDocCarg, oModelDC:GetValue('GW1_USO'    , nCont)) //Finalidade da mercadoria
			AADD(aAuxDocCarg, oModelDC:GetValue('GW1_CARREG' , nCont)) //Número do carregamento
			AADD(aAuxDocCarg, oModelDC:GetValue('GW1_NRROM'  , nCont)) //Numero do Agrupador
			AADD(aAuxDocCarg, nQtdeUnit) //Quantidade de Volumes

			AADD(aDocCarg, aAuxDocCarg)

		 EndIf
	Next nCont

	//Armazenando o valor dos Trechos
	For nCont := 1 To oModelTr:GetQtdLine()
		oModelTr:GoLine( nCont )

		If !(oModelTr:IsDeleted(nCont))

			aAuxTrchDoc := {}
			
			AADD(aAuxTrchDoc, oModelTr:GetValue('GWU_EMISDC' ,nCont))       //Emitente do Documento
			AADD(aAuxTrchDoc, oModelTr:GetValue('GWU_SERDC'  ,nCont))       //Serie do Documento
			AADD(aAuxTrchDoc, oModelTr:GetValue('GWU_NRDC'   ,nCont))       //Numero do Documento
			AADD(aAuxTrchDoc, oModelTr:GetValue('GWU_CDTPDC' ,nCont))       //Tipo do Documento
			AADD(aAuxTrchDoc, oModelTr:GetValue('GWU_SEQ'    ,nCont))       //Sequencia do Trecho
			AADD(aAuxTrchDoc, oModelTr:GetValue('GWU_CDTRP'  ,nCont))       //Transportador do Trecho
			AADD(aAuxTrchDoc, oModelTr:GetValue('GWU_NRCIDD' ,nCont))       //Cidade Destino
			AADD(aAuxTrchDoc, oModelTr:GetValue('GWU_CDTPVC' ,nCont))       //Tipo de Veiculo do Trecho
			
			If lBlind .Or. lA410SmlFrt
				AADD(aAuxTrchDoc, If(Empty(oModelTr:GetValue('GWU_PAGAR',nCont)),'1',oModelTr:GetValue('GWU_PAGAR',nCont))) //Paga o trecho ou nao (sempre pagar '1')
			Else
				AADD(aAuxTrchDoc, '1') //Paga o trecho ou nao (sempre pagar '1')
			EndIf
			
			If GFXCP12117("GWU_NRCIDO")
				AADD(aAuxTrchDoc, oModelTr:GetValue('GWU_NRCIDO' ,nCont))       //Cidade de Origem do Trecho
				AADD(aAuxTrchDoc, oModelTr:GetValue('GWU_CEPO' 	,nCont))       //CEP de Origem do Trecho
				AADD(aAuxTrchDoc, oModelTr:GetValue('GWU_CEPD' 	,nCont))       //CEP de Destino do Trecho
				AADD(aAuxTrchDoc, oModelTr:GetValue('GWU_CDCLFR' ,nCont))       //Código da Classificação de Frete do Trecho
				AADD(aAuxTrchDoc, oModelTr:GetValue('GWU_CDTPOP' ,nCont))       //Código do Tipo de Operação do Trecho
			EndIf
			
			AADD(aTrchDoc, aAuxTrchDoc)

		EndIf
	Next nCont

	//Armazenando o valor dos Itens de carga
	For nCont := 1 To oModelIt:GetQtdLine()
		oModelIt:GoLine( nCont )

		If !(oModelIt:IsDeleted(nCont))

			aAuxItDoc := {}

			AADD(aAuxItDoc, oModelIt:GetValue('GW8_EMISDC' ,nCont)) //Emitente do Documento
			AADD(aAuxItDoc, oModelIt:GetValue('GW8_SERDC'  ,nCont)) //Serie do Documento
			AADD(aAuxItDoc, oModelIt:GetValue('GW8_NRDC'   ,nCont)) //Numero do Documento
			AADD(aAuxItDoc, oModelIt:GetValue('GW8_CDTPDC' ,nCont)) //Tipo do Documento
			AADD(aAuxItDoc, oModelIt:GetValue('GW8_ITEM'   ,nCont)) //Item
			AADD(aAuxItDoc, oModelIt:GetValue('GW8_CDCLFR' ,nCont)) //Classificacao de Frete
			AADD(aAuxItDoc, oModelIt:GetValue('GW8_TPITEM' ,nCont)) //Tipo de Item
			AADD(aAuxItDoc, oModelIt:GetValue('GW8_QTDE'   ,nCont)) //Quantidade do Item
			AADD(aAuxItDoc, oModelIt:GetValue('GW8_PESOR'  ,nCont)) //Peso do Item
			AADD(aAuxItDoc, oModelIt:GetValue('GW8_PESOC'  ,nCont)) //Peso Cubado
			AADD(aAuxItDoc, oModelIt:GetValue('GW8_QTDALT' ,nCont)) //Peso Cubado
			AADD(aAuxItDoc, oModelIt:GetValue('GW8_VALOR'  ,nCont)) //Valor do Item
			AADD(aAuxItDoc, oModelIt:GetValue('GW8_VOLUME' ,nCont)) //Volume ocupado (m3)
			AADD(aAuxItDoc, oModelIt:GetValue('GW8_TRIBP'  ,nCont)) //Trib PIS

			AADD(aItDoc, aAuxItDoc)
		 EndIf
	Next nCont

	//rodando a rotina do calculo de frete
	If Len(aDocCarg) != 0 .And. Len(aTrchDoc) != 0 .And. Len(aItDoc) != 0
		If lPE101
			__nLogProc := ExecBlock('GFEX0101',.F.,.F.)
		EndIf
				
		aRet := GFECLCFRT(aAgrFrt,aDocCarg,aTrchDoc,aItDoc,,.F.,__nLogProc,,FwFldGet('CONSNEG')=='1',/*iTpSimul*/,/*lCalcLote*/, __lHidePrg, lLog, /*lServ*/)
	EndIf
	//Função de retorno : aRet
	// [1] Cálculo Ok/ Cálculo com Erro
	// [2] Arquivo de log
	// [3] Texto do Log

	If !Empty(aRet)			
		
		If aRet[1]
			cLogErro	:= ""
			aTRBGRB 	:= aRet[05]
			aTRBTCF 	:= aRet[06]
			lTabTemp	:= aRet[07]
			aTRBUNC		:= aRet[08]
			aTRBTRE		:= aRet[09]
			aTRBCCF3	:= aRet[10]
			aTRBSIM		:= aRet[11]
			
			//Armazenar os valores dos grids que precisam de informações
			GFEXFB_1AREA(lTabTemp,cTRBUNC, @aTRBUNC) //dbSelectArea(cTRBUNC)
			GFEXFB_BORDER(lTabTemp,cTRBUNC,01,6) //dbSetOrder(1)
			GFEXFB_2TOP(lTabTemp, cTRBUNC, @aTRBUNC, 6) //dbGoTop()
			While !GFEXFB_3EOF(lTabTemp, cTRBUNC, @aTRBUNC, 6) //((cTRBUNC)->(Eof()))

				GFEXFB_1AREA(lTabTemp,cTRBTCF, @aTRBTCF) //dbSelectArea(cTRBTCF)
				GFEXFB_BORDER(lTabTemp,cTRBTCF,01,5) //dbSetOrder(1)
				 If GFEXFB_CSEEK(lTabTemp, cTRBTCF, @aTRBTCF, 5,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC, 6,"NRCALC")}) //dbSeek((cTRBUNC)->NRCALC)

					GFEXFB_1AREA(.F.,, @aTRBGRB)
					GFEXFB_BORDER(.F.,,03,4)
					GFEXFB_CSEEK(.F., , @aTRBGRB, 4,{GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 5,"NRGRUP")}) //dbSeek((cTRBTCF)->NRGRUP)

				 EndIf

				GFEXFB_1AREA(lTabTemp,cTRBTRE, @aTRBTRE) //dbSelectArea(cTRBTRE)
				GFEXFB_BORDER(lTabTemp,cTRBTRE,01,7) //dbSetOrder(1)
				If GFEXFB_CSEEK(lTabTemp, cTRBTRE, @aTRBTRE, 7,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC, 6,"NRCALC")}) == .F.
					GFEXFB_CSEEK(lTabTemp, cTRBTRE, @aTRBTRE, 7,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC, 6,"CALBAS")})
				EndIf

				RecLock(cTRBCal01,.T.)
				(cTRBCal01)->NRCALC  := GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC, 6,"NRCALC")
				(cTRBCal01)->TIPO    := GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC, 6,"TIPO")
				(cTRBCal01)->TPFRET  := GFEXFB_5CMP(.F.     ,        , @aTRBGRB, 4,"TPFRET")
				(cTRBCal01)->ORIGEM  := GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE, 7,"ORIGEM")
				(cTRBCal01)->DESTIN  := GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE, 7,"DESTIN")
				(cTRBCal01)->NRAGRU  := GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC, 6,"NRAGRU")
				(cTRBCal01)->CALBAS  := GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC, 6,"CALBAS")
				(cTRBCal01)->VLPIS   := GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC, 6,"VLPIS")
				(cTRBCal01)->VLCOF   := GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC, 6,"VLCOFI")
				(cTRBCal01)->VLISS   := GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC, 6,"VLISS") + GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC, 6,"VLICMS")
				(cTRBCal01)->DTPREN  := GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC, 6,"DTPREN")
				MsUnLock(cTRBCal01)

				GFEXFB_1AREA(lTabTemp,cTRBUNC, @aTRBUNC) //dbSelectArea(cTRBUNC)
				GFEXFB_8SKIP(lTabTemp, cTRBUNC, 6) //dbSkip()
			EndDo

			nCt1 := 1
			//aplicando os valores no Grid dos Cálculos
			dbSelectArea(cTRBCal01)
			dbGoTop()
			While !( (cTRBCal01)->( Eof() ) )

				 If nCt1 > 1
					If !lBlind // Chamada do Usuário
						oModelCal1:SetNoInsertLine(.F.)
					 EndIf
					oModelCal1:AddLine()
					If !lBlind // Chamada do Usuário
						oModelCal1:SetNoInsertLine(.T.)
					EndIf
				EndIf
				//Calculando to total do frete simulado
				nTotFrete := 0
				GFEXFB_1AREA(lTabTemp,cTRBTCF, @aTRBTCF) //dbSelectArea(cTRBTCF)
				GFEXFB_BORDER(lTabTemp,cTRBTCF,01,5) //dbSetOrder(1)
				If GFEXFB_CSEEK(lTabTemp, cTRBTCF, @aTRBTCF, 5,{Alltrim((cTRBCal01)->NRCALC)}) //dbSeek( Alltrim((cTRBCal01)->NRCALC) )
					GFEXFB_1AREA(lTabTemp,cTRBCCF, @aTRBCCF3) //dbSelectArea(cTRBCCF)
					GFEXFB_BORDER(lTabTemp,cTRBCCF,03,9) //dbSetOrder(3)
					If GFEXFB_CSEEK(lTabTemp, cTRBCCF, @aTRBCCF3, 9,{GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 5,"NRCALC")}) //dbSeek()
						While !GFEXFB_3EOF(lTabTemp, cTRBCCF, @aTRBCCF3, 9) .And. GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF3, 9,"NRCALC")  == GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 5,"NRCALC")
							If !Empty( GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF3, 9,"CDCLFR")+GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF3, 9,"CDTPOP") ) .And. GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF3, 9,"TOTFRE") == '1'
								nTotFrete := nTotFrete + GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF3, 9,"VALOR")
							Elseif Empty( GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF3, 9,"CDCLFR") + GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF3, 9,"CDTPOP") ) .And. GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF3, 9,"TOTFRE") == '1'
								nTotFrete := nTotFrete + GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF3, 9,"VALOR")
							EndIf
							GFEXFB_1AREA(lTabTemp,cTRBCCF, @aTRBCCF3) //dbSelectArea(cTRBCCF)
							GFEXFB_8SKIP(lTabTemp, cTRBCCF, 9) //dbSkip()
						EndDo
					EndIf
				EndIf

				oModelCal1:SetValue('C1_NRCALC' ,(cTRBCal01)->NRCALC )
				oModelCal1:SetValue('C1_TPCALC' ,(cTRBCal01)->TIPO   )
				oModelCal1:SetValue('C1_TPFRT'  ,(cTRBCal01)->TPFRET )
				oModelCal1:SetValue('C1_CDCOLT' ,POSICIONE("GU7",1,XFILIAL("GU7")+(cTRBCal01)->ORIGEM,"GU7_NMCID") )
				oModelCal1:SetValue('C1_CDCALC' ,POSICIONE("GU7",1,XFILIAL("GU7")+(cTRBCal01)->DESTIN,"GU7_NMCID") )
				oModelCal1:SetValue('C1_NRAGR'  ,Alltrim((cTRBCal01)->NRAGRU ))
				oModelCal1:SetValue('C1_VLPIS'  ,(cTRBCal01)->VLPIS)
				oModelCal1:SetValue('C1_VLCOF'  ,(cTRBCal01)->VLCOF)
				oModelCal1:SetValue('C1_VLISS'  ,(cTRBCal01)->VLISS)
				oModelCal1:SetValue('C1_VALFRT' ,nTotFrete)
				oModelCal1:SetValue('C1_DTPREN' , (cTRBCal01)->DTPREN)
				oModelCal1:SetValue('C1_MENEG'  , '2')
				
				If lBlind
					// Busca a melhor negociação de acordo com os parâmetros do GFE
					// Salva também a posição do model oModelCal1 para cópia no oModelMNeg
					// Somente Chamada Web Service
					If (nX := aScan(aMelhorNeg,{|x| x[1] == oModelCal1:GetValue('C1_TPCALC',nCt1) +;
										 oModelCal1:GetValue('C1_TPFRT' ,nCt1) +;
										 oModelCal1:GetValue('C1_CDCOLT',nCt1) +;
										 oModelCal1:GetValue('C1_CDCALC',nCt1) +;
										 oModelCal1:GetValue('C1_NRAGR' ,nCt1)})) > 0
										 
						If cSelTabFrt == "1" .And. oModelCal1:GetValue('C1_VALFRT',nCt1) < aMelhorNeg[nX][2] // Menor Valor
						
							aMelhorNeg[nX][2] := oModelCal1:GetValue('C1_VALFRT',nCt1)
							aMelhorNeg[nX][3] := oModelCal1:GetValue('C1_DTPREN',nCt1)
							aMelhorNeg[nX][4] := nCt1
							
						ElseIf cSelTabFrt == "2" .And. (oModelCal1:GetValue('C1_DTPREN',nCt1) < aMelhorNeg[nX][3];
														.Or. (oModelCal1:GetValue('C1_DTPREN',nCt1) == aMelhorNeg[nX][3];
																.And. oModelCal1:GetValue('C1_VALFRT',nCt1) < aMelhorNeg[nX][2]))// Menor Prazo
														
							aMelhorNeg[nX][2] := oModelCal1:GetValue('C1_VALFRT',nCt1)
							aMelhorNeg[nX][3] := oModelCal1:GetValue('C1_DTPREN',nCt1)
							aMelhorNeg[nX][4] := nCt1
						EndIf
					Else
						aAdd(aMelhorNeg,{oModelCal1:GetValue('C1_TPCALC',nCt1) +;
										 oModelCal1:GetValue('C1_TPFRT',nCt1)  +;
										 oModelCal1:GetValue('C1_CDCOLT',nCt1) +;
										 oModelCal1:GetValue('C1_CDCALC',nCt1) +;
										 oModelCal1:GetValue('C1_NRAGR',nCt1)  ,;
										 oModelCal1:GetValue('C1_VALFRT',nCt1) ,;
										 oModelCal1:GetValue('C1_DTPREN',nCt1) ,;
										 nCt1})	
					EndIf
				EndIf
				nCt1++

				nCt2 := 1
				GFEXFB_1AREA(lTabTemp,cTRBTCF, @aTRBTCF) //dbSelectArea(cTRBTCF)
				GFEXFB_BORDER(lTabTemp,cTRBTCF,01,5) //dbSetOrder(1)
				If GFEXFB_CSEEK(lTabTemp, cTRBTCF, @aTRBTCF, 5,{Alltrim((cTRBCal01)->NRCALC)}) //dbSeek( Alltrim((cTRBCal01)->NRCALC) )
					While !GFEXFB_3EOF(lTabTemp, cTRBTCF, @aTRBTCF, 5) .And. Alltrim( (cTRBCal01)->NRCALC ) == GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 5,"NRCALC")
						
						GFEXFB_1AREA(lTabTemp,cTRBTRE, @aTRBTRE) //dbSelectArea(cTRBTRE)
						GFEXFB_BORDER(lTabTemp,cTRBTRE,01,7) //dbSetOrder(1)
						If !GFEXFB_CSEEK(lTabTemp, cTRBTRE, @aTRBTRE, 7,{GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 5,"NRCALC")})
							GFEXFB_CSEEK(lTabTemp, cTRBTRE, @aTRBTRE, 7,{(cTRBCal01)->CALBAS})
						EndIf
						
						dbSelectArea("GV9")
						GV9->(dbSetOrder(1))
						GV9->(dbSeek(xFilial("GV9") + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 5,"CDTRP") + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 5,"NRTAB") +GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 5,"NRNEG")))
						
						lSeek := oModelCal2:SeekLine({  {'C2_NRCALC',GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 5,"NRCALC")},;
														{'C2_CDTPOP',If(GV9->(Found()),GV9->GV9_CDTPOP,GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 5,"CDTPOP"))},;
														{'C2_CDCLFR',If(GV9->(Found()),GV9->GV9_CDCLFR,GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 5,"CDCLFR"))},;
														{'C2_SEQ',GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE, 7,"SEQ")},;
														{'C2_CDEMIT',GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 5,"CDTRP")},;
														{'C2_NRTAB',GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 5,"NRTAB")},;
														{'C2_NRNEG',GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 5,"NRNEG")},;
														{'C2_NRROTA',GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 5,"NRROTA")},;
														{'C2_CDFXTV',GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 5,"CDFXTV")},;
														{'C2_CDTPVC',GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 5,"CDTPVC")}})
						
						 If nCt2 > 1
							If !lBlind // Chamada do Usuário
								oModelCal2:SetNoInsertLine(.F.)
							EndIf
							If !lSeek
								oModelCal2:AddLine()
							EndIf
							If !lBlind // Chamada do Usuário
									oModelCal2:SetNoInsertLine(.T.)
								EndIf
						  EndIf

						  lSelec := .F.
						
						oModelCal2:SetValue('C2_NRCALC'   ,GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 5,"NRCALC") )
						oModelCal2:SetValue('C2_CDTPOP'   ,If(GV9->(Found()),GV9->GV9_CDTPOP,GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 5,"CDTPOP")))
						oModelCal2:SetValue('C2_SEQ'      ,GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE, 7,"SEQ")    )
						oModelCal2:SetValue('C2_CDCLFR'   ,If(GV9->(Found()),GV9->GV9_CDCLFR,GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 5,"CDCLFR")))
						oModelCal2:SetValue('C2_CDEMIT'   ,GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 5,"CDTRP")  )
						oModelCal2:SetValue('C2_NRTAB'    ,GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 5,"NRTAB")  )
						oModelCal2:SetValue('C2_NRNEG'    ,GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 5,"NRNEG")  )
						oModelCal2:SetValue('C2_NRROTA'   ,GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 5,"NRROTA") )
						oModelCal2:SetValue('C2_DTVAL'    ,GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 5,"DTVIGE") )
						oModelCal2:SetValue('C2_CDFXTV'   ,GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 5,"CDFXTV") )
						oModelCal2:SetValue('C2_CDTPVC'   ,GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 5,"CDTPVC") )
						nCt2++

						nCt3 := 1

						GFEXFB_1AREA(lTabTemp,cTRBTCF, @aTRBTCF) //dbSelectArea(cTRBTCF)
						GFEXFB_8SKIP(lTabTemp, cTRBTCF, 5) //dbSkip()
					EndDo

					GFEXFB_1AREA(lTabTemp,cTRBCCF, @aTRBCCF3) //dbSelectArea(cTRBCCF)
					GFEXFB_BORDER(lTabTemp,cTRBCCF,03,9) //dbSetOrder(3)
					If GFEXFB_CSEEK(lTabTemp, cTRBCCF, @aTRBCCF3, 9,{Alltrim((cTRBCal01)->NRCALC)}) //dbSeek()
						While !GFEXFB_3EOF(lTabTemp, cTRBCCF, @aTRBCCF3, 9) .And. Alltrim((cTRBCal01)->NRCALC) == Alltrim(GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF3, 9,"NRCALC"))
							
							GFEXFB_1AREA(lTabTemp,cTRBTCF, @aTRBTCF) //dbSelectArea(cTRBTCF)
							GFEXFB_BORDER(lTabTemp,cTRBTCF,01,5) //(cTRBTCF)->(dbSetOrder(1))
							GFEXFB_CSEEK(lTabTemp, cTRBTCF, @aTRBTCF, 5,{GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF3, 9,"NRCALC"), GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF3, 9,"CDCLFR"), GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF3, 9,"CDTPOP"), GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF3, 9,"SEQ")}) //(cTRBTCF)->(dbSeek(GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF3, 9,"(NRCALC+CDCLFR+CDTPOP+SEQ)))
							dbSelectArea("GV9")
							GV9->(dbSetOrder(1))
							GV9->(dbSeek(xFilial("GV9") + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 5,"CDTRP") + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 5,"NRTAB") +GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 5,"NRNEG") ))
							
							lSeek := oModelCal3:SeekLine({  {'C3_NRCALC',GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 5,"NRCALC")},;
														{'C3_CDTPOP',If(GV9->(Found()),GV9->GV9_CDTPOP,GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 5,"CDTPOP"))},;
														{'C3_CDCLFR',If(GV9->(Found()),GV9->GV9_CDCLFR,GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 5,"CDCLFR"))},;
														{'C3_SEQ',GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE, 7,"SEQ")},;
														{'C3_COPFRT',GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF3, 9,"CDCOMP")}})
							 If nCt3 > 1
								If !lBlind // Chamada do Usuário
									oModelCal3:SetNoInsertLine(.F.)
								EndIf
								If !lSeek
									oModelCal3:AddLine()
								EndIf
								If !lBlind // Chamada do Usuário
									oModelCal3:SetNoInsertLine(.T.)
								EndIf
								EndIf
								
								
							oModelCal3:SetValue('C3_NRCALC'   ,GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF3, 9,"NRCALC"))
							oModelCal3:SetValue('C3_CDTPOP'   ,If(GV9->(Found()),GV9->GV9_CDTPOP, GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF3, 9,"CDTPOP")))
							oModelCal3:SetValue('C3_CDCLFR'   ,If(GV9->(Found()),GV9->GV9_CDCLFR, GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF3, 9,"CDCLFR")))
							oModelCal3:SetValue('C3_SEQ'      ,GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE, 7,"SEQ")   )
							oModelCal3:SetValue('C3_COPFRT'   ,GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF3, 9,"CDCOMP"))

							If Posicione("GV2",1,xFilial('GV2')+GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF3, 9,"CDCOMP"),"GV2_CATVAL") == "1"
								oModelCal3:SetValue('C3_CATVAL'   ,STR0060) //"Frete Unidade"

							ElseIf Posicione("GV2",1,xFilial('GV2')+GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF3, 9,"CDCOMP"),"GV2_CATVAL") == "2"
								oModelCal3:SetValue('C3_CATVAL'   ,STR0061) //"Frete Valor"

							ElseIf Posicione("GV2",1,xFilial('GV2')+GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF3, 9,"CDCOMP"),"GV2_CATVAL") == "3"
								oModelCal3:SetValue('C3_CATVAL'   ,STR0062) //"Taxas"

							ElseIf Posicione("GV2",1,xFilial('GV2')+GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF3, 9,"CDCOMP"),"GV2_CATVAL") == "4"
								oModelCal3:SetValue('C3_CATVAL'   ,STR0063) //"Pedagio"
							EndIf

							oModelCal3:SetValue('C3_VLFRT'    ,oModelCal3:GetValue('C3_VLFRT') +  GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF3, 9,"VALOR") )
							oModelCal3:SetValue('C3_QTDCALC'  ,oModelCal3:GetValue('C3_QTDCALC') +  GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF3, 9,"QTDE")  )
							oModelCal3:SetValue('C3_TOTFRT'   ,GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF3, 9,"TOTFRE"))
							nCt3++

							GFEXFB_1AREA(lTabTemp,cTRBCCF, @aTRBCCF3) //dbSelectArea(cTRBCCF)
							GFEXFB_8SKIP(lTabTemp, cTRBCCF, 9)
						EndDo
					EndIf
				EndIf

				If !(GFEXFB_FRECCOUNT(lTabTemp, cTRBSIM, @aTRBSIM) > 0) .AND. !lBlind//Se for uma chamada do WS, enviar apenas as informações do model oModelCal1 e oModelCal2

					nCt := 1
					nCt2 := 1
					GFEXFB_1AREA(lTabTemp,cTRBSIM, @aTRBSIM)
					GFEXFB_2TOP(lTabTemp, cTRBSIM, @aTRBSIM, 03)
					While !GFEXFB_3EOF(lTabTemp, cTRBSIM, @aTRBSIM, 03)
						 If Alltrim(GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM, 03,"NRCALC")) == Alltrim((cTRBCal01)->NRCALC) .Or. ;
						 	Alltrim(GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM, 03,"NRCALC")) == Alltrim((cTRBCal01)->CALBAS)

							If cSeek != GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM, 03,"NRROM") + ;
										GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM, 03,"NRTAB") + ;
										GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM, 03,"NRNEG") + ;
										GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM, 03,"NRCALC")

								If nCt2 > 1
									If !lBlind // Chamada do Usuário
										oModelOI1:SetNoInsertLine(.F.)
									EndIf
									oModelOI1:AddLine()
									If !lBlind // Chamada do Usuário
										oModelOI1:SetNoInsertLine(.T.)
									EndIf
									nCt := 1
								EndIf

								GFEXFB_1AREA(lTabTemp,cTRBTCF, @aTRBTCF) //dbSelectArea(cTRBTCF)
								GFEXFB_BORDER(lTabTemp,cTRBTCF,01,5) //dbSetOrder(1)
								GFEXFB_CSEEK(lTabTemp, cTRBTCF, @aTRBTCF, 5,{Alltrim((cTRBCal01)->NRCALC)}) //dbSeek( Alltrim((cTRBCal01)->NRCALC) )

								//Rotina para desbobrir se há faixa para a tabela
								CDTPVC := ''
								dbSelectArea("GV7")
								dbSetOrder(01)
								dbSeek(xFilial("GV7")+GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM, 03,"CDTRP")+GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM, 03,"NRTAB")+GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM, 03,"NRNEG"),.T.)
								While !Eof() .And. GV7->GV7_FILIAL == xFilial("GV7") .And. GV7->GV7_CDEMIT == GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM, 03,"CDTRP") .And.;
										GV7->GV7_NRTAB == GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM, 03,"NRTAB") .And. GV7->GV7_NRNEG == GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM, 03,"NRNEG")

									If !Empty(GV7->GV7_CDTPVC)
										CDTPVC := GV7->GV7_CDTPVC
									EndIf
									dbSelectArea("GV7")
									dbSkip()
								EndDo

								oModelOI1:SetValue('OI1_NRROM'  ,GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM, 03,"NRROM")  )
								oModelOI1:SetValue('OI1_NRTAB'  ,GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM, 03,"NRTAB")  )
								oModelOI1:SetValue('OI1_NRNEG'  ,GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM, 03,"NRNEG")  )
								oModelOI1:SetValue('OI1_NRCALC' ,GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM, 03,"NRCALC") )
								oModelOI1:SetValue('OI1_CDCLFR' ,GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM, 03,"CDCLFR") )
								oModelOI1:SetValue('OI1_TPOP'   ,GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM, 03,"CDTPOP") )
								oModelOI1:SetValue('OI1_CDEMIT' ,GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM, 03,"CDTRP")  )
								oModelOI1:SetValue('OI1_VIGENC' ,If(GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM, 03,"VALDATA")=="NAO","2","1"))
								oModelOI1:SetValue('OI1_TPVEIC' ,If(GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM, 03,"VALTPVC")=="SIM","1","2"))
								oModelOI1:SetValue('OI1_FAIXA'  ,If(GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM, 03,"VALFAI") =="SIM","1","2"))
								oModelOI1:SetValue('OI1_ROTA'   ,"2")


								nCt2 :=	nCt2 + 1
								cSeek := GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM, 03,"NRROM") + GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM, 03,"NRTAB") + GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM, 03,"NRNEG") + GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM, 03,"NRCALC")
							EndIf

							If GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM, 03,"EMIVIN") + GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM, 03,"TABVIN") == GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM, 03,"CDTRP") + GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM, 03,"NRTAB")

									If GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM, 03,"VALROT") == "SIM"
									oModelOI1:SetValue('OI1_ROTA'   ,"1")
								EndIf

								If nCt > 1
									If !lBlind // Chamada do Usuário
										oModelOI2:SetNoInsertLine(.F.)
									EndIf
									oModelOI2:AddLine()
									If !lBlind // Chamada do Usuário
										oModelOI2:SetNoInsertLine(.T.)
									EndIf
								EndIf

								oModelOI2:SetValue('OI2_NRROM'  ,GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM, 03,"NRROM")  )
								oModelOI2:SetValue('OI2_NRTAB'  ,GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM, 03,"NRTAB")  )
								oModelOI2:SetValue('OI2_NRNEG'  ,GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM, 03,"NRNEG")  )
								oModelOI2:SetValue('OI2_NRROTA' ,GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM, 03,"NRROTA") )
								oModelOI2:SetValue('OI2_DESROT' ,GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM, 03,"DESROT") )
								oModelOI2:SetValue('OI2_SELEC'  ,If(GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM, 03,"VALROT") == "SIM",'1','2' ))
								nCt := nCt + 1
							EndIf
						EndIf
						GFEXFB_1AREA(lTabTemp,cTRBSIM, @aTRBSIM)
						GFEXFB_8SKIP(lTabTemp, cTRBSIM, 03)
					EndDo
				EndIf

				dbSelectArea(cTRBCal01)
				dbSkip()
			EndDo
		Else
			cLogErro	:= aRet[02]	
		EndIf
	EndIf
	
	For nX := 1 to Len(aMelhorNeg)
		
		oModelCal1:GoLine(aMelhorNeg[nX][4])
		oModelCal1:SetValue('C1_MENEG' ,'1' )
		
	Next nX
	
	GFEDelTab(cTRBCal01)
	
	//Deletar as tabelas usadas na rotina do calculo de frete
	if lTabTemp
		
		GFEDelTab(cTRBCCF)//1
		GFEDelTab(cTRBITE)//2
		GFEDelTab(cTRBTRE)//3
		GFEDelTab(cTRBTCF)//4
		GFEDelTab(cTRBUNC)//5
		GFEDelTab(cTRBDOC)//7
		GFEDelTab(cTRBAGRU)//8
		GFEDelTab(cTRBPED)//9
		GFEDelTab(cTRBSTF)//10
		GFEDelTab(cTRBSIM)//11
		GFEDelTab(cTRBENT)//12

	Else
		IIF(aTRBTCF ==NIL,,aSize(aTRBTCF, 0))
		IIF(aTRBUNC ==NIL,,aSize(aTRBUNC, 0))
		IIF(aTRBTRE ==NIL,,aSize(aTRBTRE, 0))
		IIF(aTRBCCF3==NIL,,aSize(aTRBCCF3,0))
		IIF(aTRBSIM ==NIL,,aSize(aTRBSIM ,0))
		aTRBTCF := Nil
		aTRBUNC := Nil
		aTRBTRE := Nil
		aTRBCCF3:= Nil
		aTRBSIM := Nil
	EndIf
	// Os Grupos de Entrega sempre são controlados por array,
	// mesmo quando o cálculo é parametrizado para ser por tabtemp
	IIF(aTRBGRB ==NIL,,aSize(aTRBGRB, 0))
	aTRBGRB := Nil
EndIf

//setando o foco na primeira linha dos grids
oModelAgr:GoLine( 1 )
oModelDC:GoLine( 1 )
oModelIt:GoLine( 1 )
oModelTr:GoLine( 1 )
oModelCal1:GoLine( 1 )
oModelCal2:GoLine( 1 )
oModelCal3:GoLine( 1 )
oModelOI1:GoLine( 1 )
oModelOI2:GoLine( 1 )
If !lBlind
	oModelCal1:setNoUpdateLine(.T.)
	oModelCal2:setNoUpdateLine(.T.)
	oModelCal3:setNoUpdateLine(.T.)
EndIf

If !oModelPai:VldData()
	Help( ,, 'Help',, STR0064 + oModelPai:aErrorMessage[6], 1, 0 ) //"Problemas da Simulacao "
EndIf

oModelPai:lModify := .F.

Return lRet

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} BscStrGWN
Criação do objeto Struct
Uso restrito

@sample
BscStrGWN( cCampo )

@author Felipe M.
@since 14/07/10
@version 1.0
/*///------------------------------------------------------------------------------------------------
Static Function BscStrGWN( cCampo )
Local aCampos := {}
Local lRet   := .F.

aAdd( aCampos, 'GWN_NRROM ' )
aAdd( aCampos, 'GWN_CDTRP ' )
aAdd( aCampos, 'GWN_DSTRP ' )
aAdd( aCampos, 'GWN_CDTPVC' )
aAdd( aCampos, 'GWN_CDCLFR' )
aAdd( aCampos, 'GWN_DSCLFR' )
aAdd( aCampos, 'GWN_CDTPOP' )
aAdd( aCampos, 'GWN_DISTAN' )
aAdd( aCampos, 'GWN_NRCIDD' )
aAdd( aCampos, 'GWN_NMCIDD' )
aAdd( aCampos, 'GWN_CEPD  ' )
aAdd( aCampos, 'GWN_PLACAD' )

lRet := ( aScan( aCampos, { |x| PadR( cCampo, 10 ) == x } ) > 0 )

Return lRet

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} BscStrGW1
Criação do objeto Struct
Uso restrito

@sample
BscStrGW1( cCampo )

@author Felipe M.
@since 14/07/10
@version 1.0
/*///------------------------------------------------------------------------------------------------
Static Function BscStrGW1( cCampo )
Local aCampos := {}
Local lRet   := .F.

aAdd( aCampos, 'GW1_NRROM ' )
aAdd( aCampos, 'GW1_EMISDC' )
aAdd( aCampos, 'GW1_NMEMIS' )
aAdd( aCampos, 'GW1_SERDC ' )
aAdd( aCampos, 'GW1_NRDC  ' )
aAdd( aCampos, 'GW1_CDTPDC' )
aAdd( aCampos, 'GW1_CDREM ' )
aAdd( aCampos, 'GW1_NMREM ' )
aAdd( aCampos, 'GW1_CDDEST' )
aAdd( aCampos, 'GW1_NMDEST' )
aAdd( aCampos, 'GW1_ENTEND' )
aAdd( aCampos, 'GW1_ENTBAI' )
aAdd( aCampos, 'GW1_ENTNRC' )
aAdd( aCampos, 'GW1_ENTCID' )
aAdd( aCampos, 'GW1_ENTUF ' )
aAdd( aCampos, 'GW1_ENTCEP' )
aAdd( aCampos, 'GW1_NRREG ' )
aAdd( aCampos, 'GW1_TPFRET' )
aAdd( aCampos, 'GW1_ICMSDC' )
aAdd( aCampos, 'GW1_USO   ' )
aAdd( aCampos, 'GW1_CARREG' )
aAdd( aCampos, 'GW1_QTVOL ' )

lRet := ( aScan( aCampos, { |x| PadR( cCampo, 10 ) == x } ) > 0 )

Return lRet

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} BscStrGW8
Criação do objeto Struct
Uso restrito

@sample
BscStrGW8( cCampo )

@author Felipe M.
@since 14/07/10
@version 1.0
/*///------------------------------------------------------------------------------------------------
Static Function BscStrGW8( cCampo )
Local aCampos := {}
Local lRet   := .F.

aAdd( aCampos, 'GW8_EMISDC' )
aAdd( aCampos, 'GW8_SERDC ' )
aAdd( aCampos, 'GW8_NRDC  ' )
aAdd( aCampos, 'GW8_CDTPDC' )
aAdd( aCampos, 'GW8_ITEM  ' )
aAdd( aCampos, 'GW8_DSITEM' )
aAdd( aCampos, 'GW8_CDCLFR' )
aAdd( aCampos, 'GW8_DSCLFR' )
aAdd( aCampos, 'GW8_TPITEM' )
aAdd( aCampos, 'GW8_DSTPIT' )
aAdd( aCampos, 'GW8_QTDE  ' )
aAdd( aCampos, 'GW8_PESOR ' )
aAdd( aCampos, 'GW8_PESOC ' )
aAdd( aCampos, 'GW8_QTDALT' )
aAdd( aCampos, 'GW8_VALOR ' )
aAdd( aCampos, 'GW8_VOLUME' )
aAdd( aCampos, 'GW8_TRIBP ' )

lRet := ( aScan( aCampos, { |x| PadR( cCampo, 10 ) == x } ) > 0 )
Return lRet

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} BscStrGWU
Criação do objeto Struct
Uso restrito

@sample
BscStrGWU( cCampo )

@author Felipe M.
@since 14/07/10
@version 1.0
/*///------------------------------------------------------------------------------------------------
Static Function BscStrGWU( cCampo )
Local aCampos := {}
Local lRet   := .F.

aAdd( aCampos, 'GWU_EMISDC' )
aAdd( aCampos, 'GWU_SERDC ' )
aAdd( aCampos, 'GWU_NRDC  ' )
aAdd( aCampos, 'GWU_CDTPDC' )
aAdd( aCampos, 'GWU_SEQ   ' )
aAdd( aCampos, 'GWU_CDTRP ' )
aAdd( aCampos, 'GWU_NMTRP ' )
aAdd( aCampos, 'GWU_NRCIDD' )
aAdd( aCampos, 'GWU_NMCIDD' )
aAdd( aCampos, 'GWU_UFD   ' )
aAdd( aCampos, 'GWU_CDTPVC' )
aAdd( aCampos, 'GWU_DTPENT' )

If IsBlind() .Or. IsInCallStack("A410SMLFRT")
	aAdd( aCampos, 'GWU_PAGAR ' )
EndIf

If GFXCP12117("GWU_NRCIDO")
	aAdd( aCampos, 'GWU_NRCIDO' )
	aAdd( aCampos, 'GWU_NMCIDO' )
	aAdd( aCampos, 'GWU_CEPO  ' )
	aAdd( aCampos, 'GWU_CEPD  ' )
	aAdd( aCampos, 'GWU_CDCLFR' )
	aAdd( aCampos, 'GWU_DSCLFR' )
	aAdd( aCampos, 'GWU_CDTPOP' )
	aAdd( aCampos, 'GWU_DSTPOP' ) 
EndIf

lRet := ( aScan( aCampos, { |x| PadR( cCampo, 10 ) == x } ) > 0 )

Return lRet

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEX010VAL
Função que valida os dados antes da simulação
Uso restrito

@param  oModelDC   objeto do grid de Doc Carga
@param	oModelIt   objeto do grid de Itens
@param	oModelTr   objeto do grid de Trecho

@sample
GFEX010VAL(oModelDC,oModelIt,oModelTr)

@author Felipe M.
@since 14/07/10
@version 1.0
/*///------------------------------------------------------------------------------------------------
Static Function GFEX010VAL(oModelAgr,oModelDC,oModelIt,oModelTr)
Local lRet       := .T.
Local nCont      := 1, nContIt := 1, nContTr := 1, nContAgr := 1, nContDoc := 1
Local lItens     := .F., lTrecho := .F. ,lAgru := .F., lDoc := .F.
Local nLineItens := 0, nLineTrecho := 0, nLineAgr := 0
Local cCdtrecho  := ''
Local lDocVald   := .T.
Local nDocCont   := 0
Local lValDoc    := .F.
Local lValItem   := .F.
Local lValTre    := .F.
Local lVlDoc     := .F.
For nContAgr := 1 To oModelAgr:GetQtdLine()
	oModelAgr:GoLine(nContAgr)
	If !(oModelAgr:IsDeleted())

		For nDocCont := 1 to oModelDC:GetQtdLine()
			oModelDC:GoLine(nDocCont)
			If !(oModelDC:IsDeleted())
				If FwFldGet("GWN_NRROM",nContAgr) == FwFldGet("GW1_NRROM",nDocCont)

					For nContIt := 1 To oModelIt:GetQtdLine()
						oModelIt:GoLine(nContIt)

						If !(oModelIt:IsDeleted())
							If FwFldGet("GW8_CDTPDC",nContIt)  + FwFldGet("GW8_EMISDC",nContIt)  + FwFldGet("GW8_SERDC",nContIt)  + FwFldGet("GW8_NRDC",nContIt) == ;
								FwFldGet("GW1_CDTPDC",nDocCont) + FwFldGet("GW1_EMISDC",nDocCont) + FwFldGet("GW1_SERDC",nDocCont) + FwFldGet("GW1_NRDC",nDocCont)
								lValItem := .T.
							EndIf
						EndIf
					Next nContIt
					If !lValItem
						Help( ,, 'Help',, STR0065 + Alltrim(FwFldGet("GW1_NRDC")) + STR0066, 1, 0 ) //"O Documento de Carga " ### " não possui Itens informados."
						Return .F.
					EndIf
					lValItem := .F.

					For nContTr := 1 To oModelTr:GetQtdLine()
						oModelTr:GoLine(nContTr)

						If !(oModelTr:IsDeleted())
							If FwFldGet("GWU_CDTPDC",nContTr)  + FwFldGet("GWU_EMISDC",nContTr)  + FwFldGet("GWU_SERDC",nContTr)  + FwFldGet("GWU_NRDC",nContTr) == ;
								 FwFldGet("GW1_CDTPDC",nDocCont) + FwFldGet("GW1_EMISDC",nDocCont) + FwFldGet("GW1_SERDC",nDocCont) + FwFldGet("GW1_NRDC",nDocCont)
								lValTre := .T.
							EndIf
						EndIf
					Next nContTr
					If !lValTre
						Help( ,, 'Help',, STR0067 + Alltrim(FwFldGet("GW1_NRDC")) + STR0068, 1, 0 ) //"O Documento de Carga " ### " não possui Trechos informados."
						Return .F.
					EndIf
					lValTre := .F.

					lVlDoc := .T.
				EndIf
			EndIf
		Next nDocCont

		If !lVlDoc
			Help( ,, 'Help',, STR0069 + FwFldGet("GWN_NRROM",nContAgr) + STR0070, 1, 0 ) //"O Agrupador " ### " não possui Documento de Carga relacionados."
			Return .F.
		EndIf

	EndIf

	lVlDoc := .F.

Next nContAgr

If oModelDC:GetQtdLine() == 1
	If Empty(FwFldGet("GW1_EMISDC",oModelDC:GetLine() )) .And. Empty(FwFldGet("GW1_SERDC",oModelDC:GetLine() )) .And. Empty(FwFldGet("GW1_NRDC",oModelDC:GetLine() )) .And. Empty(FwFldGet("GW1_CDTPDC",oModelDC:GetLine() ))
		lDocVald := .F.
	Else
		lDocVald := .F.
		For nDocCont := 1 to oModelDC:GetQtdLine()
			oModelDC:GoLine(nDocCont)
			If !(oModelDC:IsDeleted())
				lDocVald := .T.
				Exit
			EndIf
		Next
	EndIf
EndIf

If !lDocVald
	Help( ,, 'Help',, STR0071, 1, 0 ) //"É necessário que haja informações na aba Documentos de Cargas"
	lRet := .F.
EndIf

//Validação dos Doc Cargas
For nContDoc := 1 to oModelDC:GetQtdLine()
	oModelDC:GoLine(nContDoc)
	If !(oModelDC:IsDeleted()) .And. lRet
		For nContAgr := 1 to oModelAgr:GetQtdLine()
			oModelAgr:GoLine(nContAgr)
			 If !(oModelAgr:IsDeleted())
				 If FwFldGet("GWN_NRROM",nContAgr) == FwFldGet("GW1_NRROM",nContDoc)
					lDoc := .T.
					nDocLn := nContDoc
				EndIf
			 EndIf
		Next nContAgr
		 If !lDoc
			Help( ,, 'Help',, STR0072, 1, 0 ) //"Um Documento de Carga não possui agrupador relacionado na aba 'Agrupadores' "
			Return .F.
		EndIf
		lDoc := .F.
	EndIf
Next nContDoc

//percorrendo o grid de Itens
While nContIt <= oModelIt:GetQtdLine()
	oModelIt:GoLine(nContIt) // Posicionando o grid na linha do contador

	If !(oModelIt:IsDeleted()) //Se não for uma linha deletada
		nCont := 1
		lItens := .F.
		//Varrendo o grid de Doc Carga
		While nCont <= oModelDC:GetQtdLine() .And. !lItens
			oModelDC:GoLine(nCont) // Posicionando o grid na linha do contador

			If !(oModelDC:IsDeleted()) .And. !lItens .And. ;
			 FwFldGet("GW8_CDTPDC",nContIt)+FwFldGet("GW8_EMISDC",nContIt)+FwFldGet("GW8_SERDC",nContIt)+FwFldGet("GW8_NRDC",nContIt) == ;
			 FwFldGet("GW1_CDTPDC",nCont)  +FwFldGet("GW1_EMISDC",nCont)  +FwFldGet("GW1_SERDC",nCont)  +FwFldGet("GW1_NRDC",nCont)
				lItens := .T.
			  EndIf
			 nCont++
		 EndDo
		 If !lItens .And. lRet
			 nLineItens := nContIt
			 Help( ,, 'Help',, STR0073 + Alltrim(Str(nLineItens)) + STR0074, 1, 0 ) //"O Item da linha " ### " não possui documento de carga relacionado na aba 'Documentos de Carga'"
				lRet := .F.
		 EndIf
	EndIf
	nContIt++
EndDo

//Varrendo o grid de Trecho
While nContTr <= oModelTr:GetQtdLine()
	oModelTr:GoLine(nContTr) // Posicionando o grid na linha do contador

	If !(oModelTr:IsDeleted()) //Se não for uma linha deletada
		nCont := 1
		lTrecho := .F.
		//Varrendo o grid de Doc Carga
		While nCont <= oModelDC:GetQtdLine()
			oModelDC:GoLine(nCont) // Posicionando o grid na linha do contador

			If !(oModelDC:IsDeleted()) .And. !lTrecho .And. ;
			 FwFldGet("GWU_CDTPDC",nContTr)+FwFldGet("GWU_EMISDC",nContTr)+FwFldGet("GWU_SERDC",nContTr)+FwFldGet("GWU_NRDC",nContTr) == ;
			 FwFldGet("GW1_CDTPDC",nCont)  +FwFldGet("GW1_EMISDC",nCont)  +FwFldGet("GW1_SERDC",nCont)  +FwFldGet("GW1_NRDC",nCont)
				lTrecho := .T.
			  EndIf
			 nCont++
		 EndDo

		 cCdtrecho := FwFldGet('GWU_NRCIDD',nContTr)+FwFldGet("GWU_NRDC",nContTr)
		 For nCont := 1  to oModelTr:GetQtdLine()
			oModelTr:GoLine(nCont)
			 If !(oModelTr:IsDeleted())
				If cCdtrecho ==  FwFldGet('GWU_NRCIDD',nCont)+FwFldGet("GWU_NRDC",nCont) .And. nContTr != nCont .And. lRet
					Help( ,, 'Help',, STR0075 + Alltrim(STR(nContTr)) + STR0076+ Alltrim(STR(nCont)), 1, 0 ) //"O Trecho da linha " ### " possui a mesma cidade do trecho "
						lRet := .F.
				EndIf
			EndIf
		Next nCont

		If !lTrecho .And. lRet
			 nLineTrecho := nContTr
			 Help( ,, 'Help',, STR0077 + Alltrim(STR(nLineTrecho)) + STR0078, 1, 0 ) //"O Trecho da linha " ### " não possui documento de carga relacionado na aba 'Documentos de Carga'"
				lRet := .F.
		 EndIf
	EndIf
	nContTr++
EndDo

oModelAgr:GetLine( 1 )
oModelDC:GetLine( 1 )
oModelIt:GetLine( 1 )
oModelTr:GetLine( 1 )

Return lRet

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEX010ROM
Função que traz todos os dados do romaneio caso seja informado um numero de romaneio valido
Uso restrito

@sample
GFEX010ROM()

@author Felipe M.
@since 14/07/10
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function GFEX010ROM()
Local oModelPai  := FWMODELACTIVE()
Local oModelAgr  := oModelPai:GetModel("DETAIL_01")  // oModel do grid "Agrupadores"
Local oModelDC   := oModelPai:GetModel("DETAIL_02")  // oModel do grid "Doc Carga"
Local oModelIt   := oModelPai:GetModel("DETAIL_03")  // oModel do grid "Item Carga"
Local oModelTr   := oModelPai:GetModel("DETAIL_04")  // oModel do grid "Trechos"
Local nContAgrup := 0
Local nRom       := 1
Local nDoc       := 1
Local nItem      := 1
Local nTrecho    := 1
Local aArea      := GetArea()
Local aAreaGWN   := GWN->( GetArea() )
Local nCntDc
Local lLoop      := .F.
Local nAtuLn     := oModelDC:GetLine()
Local nCount
Local nLine      := oModelAgr:GetLine()

lAgr := .T.

dbSelectArea("GWN")
dbSetOrder(1)
If dbseek(xFilial("GWN")+FwFldGet("GWN_NRROM")) .And. !IsBlind()

	If APMSGYESNO(STR0079 + CRLF + STR0080, STR0081) //"Foi encontrado um Romaneio com a chave informada." ### "Deseja trazer os documentos relacionados? Este processo irá apagar Documentos de Carga que não estejam relacionados a um Agrupador cadastrado no sistema." ### "Romaneio Encontrado"

		oModelDC:Deactivate()
		oModelDC:Activate()
		oModelIt:Deactivate()
		oModelIt:Activate()
		oModelTr:Deactivate()
		oModelTr:Activate()

		For nCount := 1 To oModelAgr:Length()
			 oModelAgr:GoLine(nCount)

			dbSelectArea("GWN")
			GWN->( dbSetOrder(1) )
			If GWN->( dbseek(xFilial("GWN") + oModelAgr:GetValue("GWN_NRROM")) )

				oModelAgr:SetValue('GWN_NRROM' ,GWN->GWN_NRROM )
				oModelAgr:SetValue('GWN_CDTRP' ,GWN->GWN_CDTRP )
				oModelAgr:SetValue('GWN_CDTPVC',GWN->GWN_CDTPVC)
				oModelAgr:SetValue('GWN_CDCLFR',GWN->GWN_CDCLFR)
				oModelAgr:SetValue('GWN_CDTPOP',GWN->GWN_CDTPOP)
				oModelAgr:SetValue('GWN_DISTAN',GWN->GWN_DISTAN)
				oModelAgr:SetValue('GWN_NRCIDD',GWN->GWN_NRCIDD)
				oModelAgr:SetValue('GWN_CEPD'  ,GWN->GWN_CEPD  )
				oModelAgr:SetValue('GWN_DOC'   ,"ROMANEIO"     )

				nRom := nRom + 1

				dbSelectArea("GW1")
				dbSetOrder(9)
				If dbSeek(xFilial("GW1")+FwFldGet("GWN_NRROM"))
					While !Eof() .And. xFilial("GW1")+FwFldGet("GWN_NRROM") == GW1->GW1_FILIAL + GW1->GW1_NRROM

						For nCntDc := 1 To oModelDC:GetQtdLine()
							oModelDC:GoLine(nCntDc)
							If !oModelDC:IsDeleted()
								If oModelDC:GetValue("GW1_CDTPDC") + oModelDC:GetValue("GW1_EMISDC") + oModelDC:GetValue("GW1_SERDC") + oModelDC:GetValue("GW1_NRDC") == ;
									GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC
									DbSelectArea("GW1")
									GW1->( dbSkip() )
									lLoop := .T.
									Exit
								EndIf
							EndIf
						Next nCntDc

						 If lLoop
							lLoop := .F.
							Loop
						 EndIf

						oModelDC:GoLine(nAtuLn)

						nDoc := oModelDC:GetQtdLine() + 1
						If (oModelDC:GetQtdLine() == 1 .And. !Empty(oModelDC:GetValue('GW1_NRROM',1)) ) .Or. oModelDC:GetQtdLine() > 1
							If oModelDC:AddLine() <> nDoc
								aError := oModelPai:GetErrorMessage()
								Alert(aError[6])
								lAgr := .F.
								Return .F.
							EndIf
						EndIf

						oModelDC:SetValue('GW1_EMISDC', GW1->GW1_EMISDC)
						oModelDC:SetValue('GW1_SERDC' , GW1->GW1_SERDC )
						oModelDC:SetValue('GW1_NRDC'  , GW1->GW1_NRDC  )
						oModelDC:SetValue('GW1_CDTPDC', GW1->GW1_CDTPDC)
						oModelDC:SetValue('GW1_CDREM' , GW1->GW1_CDREM )
						oModelDC:SetValue('GW1_CDDEST', GW1->GW1_CDDEST)
						oModelDC:SetValue('GW1_ENTEND', GW1->GW1_ENTEND)
						oModelDC:SetValue('GW1_ENTBAI', GW1->GW1_ENTBAI)
						oModelDC:SetValue('GW1_ENTNRC', GW1->GW1_ENTNRC)
						oModelDC:SetValue('GW1_ENTCEP', GW1->GW1_ENTCEP)
						oModelDC:SetValue('GW1_TPFRET', GW1->GW1_TPFRET)
						oModelDC:SetValue('GW1_ICMSDC', GW1->GW1_ICMSDC)
						oModelDC:SetValue('GW1_USO'   , GW1->GW1_USO   )
						oModelDC:SetValue('GW1_CARREG', GW1->GW1_CARREG)
						oModelDC:SetValue('GW1_NRROM' , GW1->GW1_NRROM )
						oModelDC:SetValue('GW1_QTVOL' , GW1->GW1_QTVOL )

						If oModelAgr:IsDeleted()
							oModelDC:DeleteLine()
						EndIf

						nDoc := nDoc + 1

						dbSelectArea("GWU")
						dbSetOrder(1)
						If dbseek(xFilial("GWU")+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC)
							While !Eof() .and. GW1->GW1_CDTPDC == GWU->GWU_CDTPDC ;
										 .and. GW1->GW1_EMISDC == GWU->GWU_EMISDC ;
									 .and. GW1->GW1_SERDC  == GWU->GWU_SERDC ;
									 .and. GW1->GW1_NRDC   == GWU->GWU_NRDC

								nTrecho := oModelTr:GetQtdLine() + 1
								If (oModelTr:GetQtdLine() == 1 .And. !Empty(oModelTr:GetValue('GWU_EMISDC',1))) .Or. oModelTr:GetQtdLine() > 1
									If oModelTr:AddLine() <> nTrecho
										aError := oModelPai:GetErrorMessage()
										Alert(aError[6])
										lAgr := .F.
										Return .F.
									EndIf
								EndIf

								oModelTr:SetValue('GWU_EMISDC' ,GWU->GWU_EMISDC)
								oModelTr:SetValue('GWU_SERDC'  ,GWU->GWU_SERDC )
								oModelTr:SetValue('GWU_NRDC'   ,GWU->GWU_NRDC  )
								oModelTr:SetValue('GWU_CDTPDC' ,GWU->GWU_CDTPDC)
								oModelTr:SetValue('GWU_SEQ'    ,GWU->GWU_SEQ   )
								oModelTr:SetValue('GWU_CDTRP'  ,GWU->GWU_CDTRP )
								oModelTr:SetValue('GWU_NRCIDD' ,GWU->GWU_NRCIDD)
								oModelTr:SetValue('GWU_CDTPVC' ,GWU->GWU_CDTPVC)
								oModelTr:SetValue('GWU_DTPENT' ,GWU->GWU_DTPENT)
								
								If GFXCP12117("GWU_NRCIDO")
									oModelTr:SetValue('GWU_NRCIDO' ,GWU->GWU_NRCIDO)
									oModelTr:SetValue('GWU_CEPO'   ,GWU->GWU_CEPO)
									oModelTr:SetValue('GWU_CEPD'   ,GWU->GWU_CEPD)
									oModelTr:SetValue('GWU_CDCLFR' ,GWU->GWU_CDCLFR)
									oModelTr:SetValue('GWU_CDTPOP' ,GWU->GWU_CDTPOP)
								EndIf

								If oModelAgr:IsDeleted()
									oModelTr:DeleteLine()
								EndIf

								nTrecho := nTrecho + 1

								dbSelectArea("GWU")
								dbSkip()
							EndDo
						EndIf

						dbSelectArea("GW8")
						dbSetOrder(1)
						If dbseek(xFilial("GW8")+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC)
							While !Eof() .and. GW1->GW1_CDTPDC == GW8->GW8_CDTPDC ;
											 .and. GW1->GW1_EMISDC == GW8->GW8_EMISDC ;
										 .and. GW1->GW1_SERDC  == GW8->GW8_SERDC ;
										 .and. GW1->GW1_NRDC   == GW8->GW8_NRDC

								 nItem := oModelIt:GetQtdLine() + 1
								If (oModelIt:GetQtdLine() == 1 .And. !Empty(oModelIt:GetValue('GW8_EMISDC',1))) .Or. oModelIt:GetQtdLine() > 1
									If oModelIt:AddLine() <> nItem
										aError := oModelPai:GetErrorMessage()
										Alert(aError[6])
										lAgr := .F.
										Return .F.
									EndIf
								EndIf

								oModelIt:SetValue('GW8_EMISDC',GW8->GW8_EMISDC)
								oModelIt:SetValue('GW8_SERDC' ,GW8->GW8_SERDC )
								oModelIt:SetValue('GW8_NRDC'  ,GW8->GW8_NRDC  )
								oModelIt:SetValue('GW8_CDTPDC',GW8->GW8_CDTPDC)
								oModelIt:SetValue('GW8_ITEM'  ,GW8->GW8_ITEM  )
								oModelIt:SetValue('GW8_DSITEM',GW8->GW8_DSITEM)
								oModelIt:SetValue('GW8_CDCLFR',GW8->GW8_CDCLFR)
								oModelIt:SetValue('GW8_TPITEM',GW8->GW8_TPITEM)
								oModelIt:SetValue('GW8_QTDE'  ,GW8->GW8_QTDE  )
								oModelIt:SetValue('GW8_PESOR' ,GW8->GW8_PESOR )
								oModelIt:SetValue('GW8_PESOC' ,GW8->GW8_PESOC )
								oModelIt:SetValue('GW8_QTDALT',GW8->GW8_QTDALT)
								oModelIt:SetValue('GW8_VALOR' ,GW8->GW8_VALOR )
								oModelIt:SetValue('GW8_VOLUME',GW8->GW8_VOLUME)
								oModelIt:SetValue('GW8_TRIBP' ,GW8->GW8_TRIBP )

								If oModelAgr:IsDeleted()
									oModelIt:DeleteLine()
								EndIf

								nItem := nItem + 1

								dbSelectArea("GW8")
								dbSkip()
							EndDo
						EndIf
						DbSelectArea("GW1")
						dbSkip()
					EndDo
				EndIf
			EndIf
		Next nCount

		oModelAgr:GoLine(nLine)

	EndIf
EndIf

/*oModelAgr:GoLine( 1 ) */
oModelDC:GoLine( 1 )
oModelIt:GoLine( 1 )
oModelTr:GoLine( 1 )

RestArea( aAreaGWN )
RestArea( aArea )

lAgr := .F.

Return .T.

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEX010DEL
Função que "deleta" e recupera os registros do agrupador
Uso restrito

@sample
GFEX010DEL()

@author Felipe M.
@since 14/07/10
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function GFEX010DEL(oModel,nLinha,cOp)
Local oViewPai
Local oModelPai  := FWMODELACTIVE()
Local oModelNeg  := oModelPai:GetModel("GFEX010_01") // oModel do campo "Considerar Negociação"
Local oModelAgr  := oModelPai:GetModel("DETAIL_01")  // oModel do grid "Agrupadores"
Local oModelDC   := oModelPai:GetModel("DETAIL_02")  // oModel do grid "Doc Carga"
Local oModelIt   := oModelPai:GetModel("DETAIL_03")  // oModel do grid "Item Carga"
Local oModelTr   := oModelPai:GetModel("DETAIL_04")  // oModel do grid "Trechos"
Local nContDC, nContTr, nContIt
Local aSaveLines := FWSaveRows()    //Salvando as linhas
Local lRefresh 	 := .F.

//Se estiver deletando
If cOp == "DELETE"

	//Armazenando o valor da chave
	cNRROM := oModelAgr:GetValue("GWN_NRROM")
	//procurando os doc carga do agrupador
	For nContDC := 1 to oModelDC:Length()
		oModelDC:GoLine( nContDC )
		If cNRROM == oModelDC:GetValue("GW1_NRROM")
			lRefresh := .T.
			cSeek := oModelDC:GetValue("GW1_CDTPDC")+oModelDC:GetValue("GW1_EMISDC")+oModelDC:GetValue("GW1_SERDC")+oModelDC:GetValue("GW1_NRDC")
			For nContTr := 1 to oModelTr:Length()
				oModelTr:GoLine( nContTr )
				If cSeek == oModelTr:GetValue("GWU_CDTPDC")+oModelTr:GetValue("GWU_EMISDC")+oModelTr:GetValue("GWU_SERDC")+oModelTr:GetValue("GWU_NRDC")
					oModelTr:DeleteLine()
				EndIf
			Next nContTr

			For nContIt := 1 to oModelIt:Length()
				oModelIt:GoLine( nContIt )
				If cSeek == oModelIt:GetValue("GW8_CDTPDC")+oModelIt:GetValue("GW8_EMISDC")+oModelIt:GetValue("GW8_SERDC")+oModelIt:GetValue("GW8_NRDC")
					oModelIt:DeleteLine()
				EndIf
			Next nContIt

			oModelDC:DeleteLine()
		EndIf
	Next nContDC
	oModelDC:GoLine( 1 )
	oModelIt:GoLine( 1 )
	oModelTr:GoLine( 1 )

ElseIf cOp == "UNDELETE" //Se estiver recuperando

	cNRROM := oModelAgr:GetValue("GWN_NRROM")
	For nContDC := 1 to oModelDC:Length()
		oModelDC:GoLine( nContDC )
		If cNRROM == oModelDC:GetValue("GW1_NRROM")

			lRefresh := .T.
			cSeek := oModelDC:GetValue("GW1_CDTPDC")+oModelDC:GetValue("GW1_EMISDC")+oModelDC:GetValue("GW1_SERDC")+oModelDC:GetValue("GW1_NRDC")
			For nContTr := 1 to oModelTr:Length()
				oModelTr:GoLine( nContTr )
				If cSeek == oModelTr:GetValue("GWU_CDTPDC")+oModelTr:GetValue("GWU_EMISDC")+oModelTr:GetValue("GWU_SERDC")+oModelTr:GetValue("GWU_NRDC")
					oModelTr:UnDeleteLine()
				EndIf
			Next nContTr

			For nContIt := 1 to oModelIt:Length()
				oModelIt:GoLine( nContIt )
				If cSeek == oModelIt:GetValue("GW8_CDTPDC")+oModelIt:GetValue("GW8_EMISDC")+oModelIt:GetValue("GW8_SERDC")+oModelIt:GetValue("GW8_NRDC")
					oModelIt:UnDeleteLine()
				EndIf
			Next nContIt

			oModelDC:UnDeleteLine()
		EndIf
	Next nContDC
	oModelDC:GoLine( 1 )
	oModelIt:GoLine( 1 )
	oModelTr:GoLine( 1 )
EndIf

If 	lRefresh
	oViewPai:=FwViewActive()
	oViewPai:Refresh('VIEW_01')
	oViewPai:Refresh('VIEW_02')
	oViewPai:Refresh('VIEW_03')
	oViewPai:Refresh('VIEW_04')
EndIf

	//setando o foco na primeira linha dos grids
//	oModelAgr:GoLine( 1 )
	oModelDC:GoLine( 1 )
	oModelIt:GoLine( 1 )
	oModelTr:GoLine( 1 )

FWRestRows( aSaveLines )   //Restaurando as linhas
Return .T.

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEX010RE
Função que elimina os doc cargas que não tem agrupador
Uso restrito

@sample
GFEX010RE()

@author Felipe M.
@since 16/11/10
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function GFEX010RE(cNrRomAdd)
Local lRet := .T.
Local oModelPai  := FWMODELACTIVE()
Local oModelNeg  := oModelPai:GetModel("GFEX010_01") // oModel do campo "Considerar Negociação"
Local oModelAgr  := oModelPai:GetModel("DETAIL_01")  // oModel do grid "Agrupadores"
Local oModelDC   := oModelPai:GetModel("DETAIL_02")  // oModel do grid "Doc Carga"
Local oModelIt   := oModelPai:GetModel("DETAIL_03")  // oModel do grid "Item Carga"
Local oModelTr   := oModelPai:GetModel("DETAIL_04")  // oModel do grid "Trechos"
Local aSaveLines := FWSaveRows()    //Salvando as linhas
Local aDocCarg := {}, aTrchDoc := {}, aItDoc := {} // Array para armazenar os registro dos grids
Local aAuxDocCarg := {}, aAuxTrchDoc := {}, aAuxItDoc := {}
Local nCont, nCont2, nCont3, nDoc := 1, nItem := 1, nTrecho := 1
Local aArea  := GetArea()
Local aAreaGWN:= GWN->( GetArea() )

//Armazenando o valor dos Documentos de frete
For nCont := 1 To oModelDC:GetQtdLine()
	oModelDC:GoLine( nCont )

	If !(oModelDC:IsDeleted(nCont))

		aAuxDocCarg   := {}

		AADD(aAuxDocCarg, oModelDC:GetValue('GW1_EMISDC' ,nCont))       //Emitente do Documento
		AADD(aAuxDocCarg, oModelDC:GetValue('GW1_SERDC'  ,nCont))       //Serie do Documento
		AADD(aAuxDocCarg, oModelDC:GetValue('GW1_NRDC'   ,nCont))       //Numero do Documento
		AADD(aAuxDocCarg, oModelDC:GetValue('GW1_CDTPDC' ,nCont))       //Tipo do Documento
		AADD(aAuxDocCarg, oModelDC:GetValue('GW1_CDREM'  ,nCont))       //Remetente do Documento
		AADD(aAuxDocCarg, oModelDC:GetValue('GW1_CDDEST' ,nCont))       //Destinatario do Documento
		AADD(aAuxDocCarg, oModelDC:GetValue('GW1_ENTEND' ,nCont))       //Endereco de Entrega
		AADD(aAuxDocCarg, oModelDC:GetValue('GW1_ENTBAI' ,nCont))       //Bairro de entrega
		AADD(aAuxDocCarg, oModelDC:GetValue('GW1_ENTNRC' ,nCont))       //Cidade de Entrega
		AADD(aAuxDocCarg, oModelDC:GetValue('GW1_ENTCEP' ,nCont))       //CEP de Entrega
		AADD(aAuxDocCarg, oModelDC:GetValue('GW1_NRREG'  ,nCont))       //Região de destino
		AADD(aAuxDocCarg, oModelDC:GetValue('GW1_TPFRET' ,nCont))       //Tipo de Frete
		AADD(aAuxDocCarg, oModelDC:GetValue('GW1_ICMSDC' ,nCont))       //ICMS?
		AADD(aAuxDocCarg, oModelDC:GetValue('GW1_USO'    ,nCont))       //Finalidade da mercadoria
		AADD(aAuxDocCarg, oModelDC:GetValue('GW1_CARREG' ,nCont))       //Número do carregamento
		AADD(aAuxDocCarg, oModelDC:GetValue('GW1_NRROM'  ,nCont))       //Numero do Agrupador
		AADD(aAuxDocCarg, oModelDC:GetValue('GW1_QTVOL'  ,nCont))       //Quantidade de Unitizadores

		AADD(aDocCarg, aAuxDocCarg)

	 EndIf
End

//Armazenando o valor dos Trechos
For nCont := 1 To oModelTr:GetQtdLine()
	oModelTr:GoLine( nCont )

	If !(oModelTr:IsDeleted(nCont))

		aAuxTrchDoc := {}

		AADD(aAuxTrchDoc, oModelTr:GetValue('GWU_EMISDC' ,nCont))       //Emitente do Documento
		AADD(aAuxTrchDoc, oModelTr:GetValue('GWU_SERDC'  ,nCont))       //Serie do Documento
		AADD(aAuxTrchDoc, oModelTr:GetValue('GWU_NRDC'   ,nCont))       //Numero do Documento
		AADD(aAuxTrchDoc, oModelTr:GetValue('GWU_CDTPDC' ,nCont))       //Tipo do Documento
		AADD(aAuxTrchDoc, oModelTr:GetValue('GWU_SEQ'    ,nCont))       //Sequencia do Trecho
		AADD(aAuxTrchDoc, oModelTr:GetValue('GWU_CDTRP'  ,nCont))       //Transportador do Trecho
		AADD(aAuxTrchDoc, oModelTr:GetValue('GWU_NRCIDD' ,nCont))       //Cidade Destino
		AADD(aAuxTrchDoc, oModelTr:GetValue('GWU_CDTPVC' ,nCont))       //Tipo de Veiculo do Trecho
		AADD(aAuxTrchDoc, oModelTr:GetValue('GWU_DTPENT' ,nCont))		 //Data de Previsão de Entrega do Trecho
		
		If GFXCP12117("GWU_NRCIDO")
			AADD(aAuxTrchDoc, oModelTr:GetValue('GWU_NRCIDO' ,nCont))		 //Número da Cidade de Origem do Trecho
			AADD(aAuxTrchDoc, oModelTr:GetValue('GWU_CEPO'   ,nCont))		 //CEP de Origem do Trecho
			AADD(aAuxTrchDoc, oModelTr:GetValue('GWU_CEPD'   ,nCont))		 //CEP de Destino do Trecho
			AADD(aAuxTrchDoc, oModelTr:GetValue('GWU_CDCLFR' ,nCont))		 //Código de Classificação de Frete do Trecho
			AADD(aAuxTrchDoc, oModelTr:GetValue('GWU_CDTPOP' ,nCont))		 //Código do Tipo de Operação do Trecho
		EndIf

		AADD(aTrchDoc, aAuxTrchDoc)

	EndIf
End

//Armazenando o valor dos Itens de carga
For nCont := 1 To oModelIt:GetQtdLine()
	oModelIt:GoLine( nCont )

	If !(oModelIt:IsDeleted(nCont))

		aAuxItDoc := {}

		AADD(aAuxItDoc, oModelIt:GetValue('GW8_EMISDC' ,nCont)) //Emitente do Documento
		AADD(aAuxItDoc, oModelIt:GetValue('GW8_SERDC'  ,nCont)) //Serie do Documento
		AADD(aAuxItDoc, oModelIt:GetValue('GW8_NRDC'   ,nCont)) //Numero do Documento
		AADD(aAuxItDoc, oModelIt:GetValue('GW8_CDTPDC' ,nCont)) //Tipo do Documento
		AADD(aAuxItDoc, oModelIt:GetValue('GW8_ITEM'   ,nCont)) //Item
		AADD(aAuxItDoc, oModelIt:GetValue('GW8_DSITEM' ,nCont)) //Descrição
		AADD(aAuxItDoc, oModelIt:GetValue('GW8_CDCLFR' ,nCont)) //Classificacao de Frete
		AADD(aAuxItDoc, oModelIt:GetValue('GW8_TPITEM' ,nCont)) //Tipo de Item
		AADD(aAuxItDoc, oModelIt:GetValue('GW8_DSITEM' ,nCont)) //Nome de Item
		AADD(aAuxItDoc, oModelIt:GetValue('GW8_QTDE'   ,nCont)) //Quantidade do Item
		AADD(aAuxItDoc, oModelIt:GetValue('GW8_PESOR'  ,nCont)) //Peso do Item
		AADD(aAuxItDoc, oModelIt:GetValue('GW8_PESOC'  ,nCont)) //Peso Cubado
		AADD(aAuxItDoc, oModelIt:GetValue('GW8_QTDALT' ,nCont)) //Peso Cubado
		AADD(aAuxItDoc, oModelIt:GetValue('GW8_VALOR'  ,nCont)) //Valor do Item
		AADD(aAuxItDoc, oModelIt:GetValue('GW8_VOLUME' ,nCont)) //Volume ocupado (m3)
		AADD(aAuxItDoc, oModelIt:GetValue('GW8_TRIBP'  ,nCont)) //Trib COFINS

		AADD(aItDoc, aAuxItDoc)
	 EndIf
End
// limpando e atualizando os grids
oModelDC:DeActivate(.T.)
oModelDC:Activate()
oModelIt:DeActivate(.T.)
oModelIt:Activate()
oModelTr:DeActivate(.T.)
oModelTr:Activate()
oViewPai:=FwViewActive()
oViewPai:Refresh('VIEW_02')
oViewPai:Refresh('VIEW_03')
oViewPai:Refresh('VIEW_04')

For nCont := 1 To oModelAgr:GetQtdLine()
	oModelAgr:GoLine( nCont )

	If !(oModelAgr:IsDeleted(nCont))

		For nCont2 := 1 To Len(aDocCarg)

			If aDocCarg[nCont2][16] == oModelAgr:GetValue("GWN_NRROM") .And. cNrRomAdd != oModelAgr:GetValue("GWN_NRROM")

				If nDoc > 1
					oModelDC:AddLine()
				EndIf

				oModelDC:SetValue('GW1_EMISDC',aDocCarg[nCont2][01])
				oModelDC:SetValue('GW1_SERDC' ,aDocCarg[nCont2][02])
				oModelDC:SetValue('GW1_NRDC'  ,aDocCarg[nCont2][03])
				oModelDC:SetValue('GW1_CDTPDC',aDocCarg[nCont2][04])
				oModelDC:SetValue('GW1_CDREM' ,aDocCarg[nCont2][05])
				oModelDC:SetValue('GW1_CDDEST',aDocCarg[nCont2][06])
				oModelDC:SetValue('GW1_ENTEND',aDocCarg[nCont2][07])
				oModelDC:SetValue('GW1_ENTBAI',aDocCarg[nCont2][08])
				oModelDC:SetValue('GW1_ENTNRC',aDocCarg[nCont2][09])
				oModelDC:SetValue('GW1_ENTCEP',aDocCarg[nCont2][10])
				oModelDC:SetValue('GW1_TPFRET',aDocCarg[nCont2][12])
				oModelDC:SetValue('GW1_ICMSDC',aDocCarg[nCont2][13])
				oModelDC:SetValue('GW1_USO'   ,aDocCarg[nCont2][14])
				oModelDC:SetValue('GW1_CARREG',aDocCarg[nCont2][15])
				oModelDC:SetValue('GW1_NRROM' ,aDocCarg[nCont2][16])
				oModelDC:SetValue('GW1_QTVOL' ,aDocCarg[nCont2][17])

				nDoc := nDoc + 1

				//Item
				For nCont3 := 1 to len(aItDoc)
					If  aDocCarg[nCont2][01]+aDocCarg[nCont2][02]+aDocCarg[nCont2][03]+aDocCarg[nCont2][04] == ;
						  aItDoc[nCont3][01]  +aItDoc[nCont3][02]  +aItDoc[nCont3][03]  +aItDoc[nCont3][04]

						If nItem > 1
							oModelIt:AddLine()
						EndIf
						oModelIt:SetValue('GW8_EMISDC',aItDoc[nCont3][01])
						oModelIt:SetValue('GW8_SERDC' ,aItDoc[nCont3][02])
						oModelIt:SetValue('GW8_NRDC'  ,aItDoc[nCont3][03])
						oModelIt:SetValue('GW8_CDTPDC',aItDoc[nCont3][04])
						oModelIt:SetValue('GW8_ITEM'  ,aItDoc[nCont3][05])
						oModelIt:SetValue('GW8_DSITEM',aItDoc[nCont3][06])
						oModelIt:SetValue('GW8_CDCLFR',aItDoc[nCont3][07])
						oModelIt:SetValue('GW8_TPITEM',aItDoc[nCont3][08])
						oModelIt:SetValue('GW8_QTDE'  ,aItDoc[nCont3][10])
						oModelIt:SetValue('GW8_PESOR' ,aItDoc[nCont3][11])
						oModelIt:SetValue('GW8_PESOC' ,aItDoc[nCont3][12])
						oModelIt:SetValue('GW8_QTDALT',aItDoc[nCont3][13])
						oModelIt:SetValue('GW8_VALOR' ,aItDoc[nCont3][14])
						oModelIt:SetValue('GW8_VOLUME',aItDoc[nCont3][15])
						oModelIt:SetValue('GW8_TRIBP' ,aItDoc[nCont3][16])
						nItem := nItem + 1

					EndIf
				Next nCont3

				//Trecho
				For nCont3 := 1 to len(aTrchDoc)
					If  aDocCarg[nCont2][01]+aDocCarg[nCont2][02]+aDocCarg[nCont2][03]+aDocCarg[nCont2][04] == ;
						 aTrchDoc[nCont3][01]+aTrchDoc[nCont3][02]+aTrchDoc[nCont3][03]+aTrchDoc[nCont3][04]

						 If nTrecho > 1
							oModelTr:AddLine()
						EndIf
						oModelTr:SetValue('GWU_EMISDC'	,aTrchDoc[nCont3][01])
						oModelTr:SetValue('GWU_SERDC' 	,aTrchDoc[nCont3][02])
						oModelTr:SetValue('GWU_NRDC'  	,aTrchDoc[nCont3][03])
						oModelTr:SetValue('GWU_CDTPDC'	,aTrchDoc[nCont3][04])
						oModelTr:SetValue('GWU_SEQ'   	,aTrchDoc[nCont3][05])
						oModelTr:SetValue('GWU_CDTRP' 	,aTrchDoc[nCont3][06])
						oModelTr:SetValue('GWU_NRCIDD'	,aTrchDoc[nCont3][07])
						oModelTr:SetValue('GWU_CDTPVC'	,aTrchDoc[nCont3][08])
						oModelTr:SetValue('GWU_DTPENT'	,aTrchDoc[nCont3][09])
						
						If GFXCP12117("GWU_NRCIDO")
							oModelTr:SetValue('GWU_NRCIDO'	,aTrchDoc[nCont3][10])
							oModelTr:SetValue('GWU_CEPO' 	,aTrchDoc[nCont3][12])
							oModelTr:SetValue('GWU_CEPD' 	,aTrchDoc[nCont3][13])
							oModelTr:SetValue('GWU_CDCLFR'	,aTrchDoc[nCont3][14])
							oModelTr:SetValue('GWU_CDTPOP'	,aTrchDoc[nCont3][15])
						EndIf
						
						nTrecho := nTrecho + 1

					EndIf
				Next nCont3
			EndIf
		Next nCont2
	EndIf
Next nCont

FWRestRows( aSaveLines )   //Restaurando as linhas

RestArea( aAreaGWN )
RestArea( aArea )
Return lRet

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEX010DOC
Função que traz todos os itens de um doc carga informado no grid
Uso restrito

@sample
GFEX010DOC()

@author Felipe M.
@since 14/07/10
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function GFEX010DOC(cRetorno)
Local oModelPai  := FWMODELACTIVE()
Local oModelNeg  := oModelPai:GetModel("GFEX010_01") // oModel do campo "Considerar Negociação"
Local oModelAgr  := oModelPai:GetModel("DETAIL_01")  // oModel do grid "Agrupadores"
Local oModelDC   := oModelPai:GetModel("DETAIL_02")  // oModel do grid "Doc Carga"
Local oModelIt   := oModelPai:GetModel("DETAIL_03")  // oModel do grid "Item Carga"
Local oModelTr   := oModelPai:GetModel("DETAIL_04")  // oModel do grid "Trechos"
Local nCount
Local nLine      := oModelDC:GetLine()

GW1->(dbSetOrder(1))
//lAgr é uma variavel flag utilizada para verificar se o update está sendo feito pelo gatilho de preenchimento do agrupador
If GW1->(dbSeek(xFilial('GW1')+FwFldGet("GW1_CDTPDC")+FwFldGet("GW1_EMISDC")+FwFldGet("GW1_SERDC")+FwFldGet("GW1_NRDC")) .And. !IsBlind())

	 If APMSGYESNO(STR0082 + CRLF + STR0083,STR0084) //"Foi encontrado um Documento de Carga com a chave informada." ### "Deseja trazer os itens relacionados? Este processo irá apagar trechos e itens que não estejam relacionados a um Documento de Carga cadastrado no sistema." ### "Documento de Carga"
		
		oModelIt:ClearData(.F.)
		oModelIt:Deactivate()
		oModelIt:Activate()
		oModelTr:ClearData(.F.)
		oModelTr:Deactivate()
		oModelTr:Activate()
		
		For nCount := 1 To oModelDC:Length()
			oModelDC:GoLine(nCount)
			GW1->( dbSetOrder(1) )
			If GW1->( dbSeek(xFilial('GW1')+FwFldGet("GW1_CDTPDC")+FwFldGet("GW1_EMISDC")+FwFldGet("GW1_SERDC")+FwFldGet("GW1_NRDC")) )
				oModelDC:SetValue('GW1_CDREM' ,GW1->GW1_CDREM )
				oModelDC:SetValue('GW1_CDDEST',GW1->GW1_CDDEST)
				oModelDC:SetValue('GW1_ENTEND',GW1->GW1_ENTEND)
				oModelDC:SetValue('GW1_ENTBAI',GW1->GW1_ENTBAI)
				oModelDC:SetValue('GW1_ENTNRC',GW1->GW1_ENTNRC)
				oModelDC:SetValue('GW1_ENTCEP',GW1->GW1_ENTCEP)
				oModelDC:SetValue('GW1_TPFRET',GW1->GW1_TPFRET)
				oModelDC:SetValue('GW1_ICMSDC',GW1->GW1_ICMSDC)
				oModelDC:SetValue('GW1_USO'   ,GW1->GW1_USO   )
				oModelDC:SetValue('GW1_CARREG',GW1->GW1_CARREG)
				oModelDC:SetValue('GW1_QTVOL' ,GW1->GW1_QTVOL)
				
				GW8->(dbSetOrder(1))
				If GW8->(dbseek(xFilial("GW8")+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC))
					While !Eof() .and. GW1->GW1_CDTPDC == GW8->GW8_CDTPDC ;
									 .and. GW1->GW1_EMISDC == GW8->GW8_EMISDC ;
								 .and. GW1->GW1_SERDC  == GW8->GW8_SERDC ;
								 .and. GW1->GW1_NRDC   == GW8->GW8_NRDC

						 If (oModelIt:GetQtdLine() == 1 .And. !Empty(oModelIt:GetValue('GW8_EMISDC',1))) .Or. oModelIt:GetQtdLine() > 1
							oModelIt:AddLine()
						EndIf
						oModelIt:SetValue('GW8_EMISDC',GW8->GW8_EMISDC)
						oModelIt:SetValue('GW8_SERDC' ,GW8->GW8_SERDC )
						oModelIt:SetValue('GW8_NRDC'  ,GW8->GW8_NRDC  )
						oModelIt:SetValue('GW8_CDTPDC',GW8->GW8_CDTPDC)
						oModelIt:SetValue('GW8_ITEM'  ,GW8->GW8_ITEM  )
						oModelIt:SetValue('GW8_DSITEM',GW8->GW8_DSITEM)
						oModelIt:SetValue('GW8_CDCLFR',GW8->GW8_CDCLFR)
						oModelIt:SetValue('GW8_TPITEM',GW8->GW8_TPITEM)
						oModelIt:SetValue('GW8_QTDE'  ,GW8->GW8_QTDE  )
						oModelIt:SetValue('GW8_PESOR' ,GW8->GW8_PESOR )
						oModelIt:SetValue('GW8_PESOC' ,GW8->GW8_PESOC )
						oModelIt:SetValue('GW8_QTDALT',GW8->GW8_QTDALT)
						oModelIt:SetValue('GW8_VALOR' ,GW8->GW8_VALOR )
						oModelIt:SetValue('GW8_VOLUME',GW8->GW8_VOLUME)
						oModelIt:SetValue('GW8_TRIBP' ,GW8->GW8_TRIBP )

						If oModelDC:IsDeleted()
							oModelIt:DeleteLine()
						EndIf

						GW8->(dbSkip())
						EndDo
				EndIf

				oModelIt:GoLine(1)

				GWU->(dbSetOrder(1))
				If GWU->(dbseek(xFilial("GWU")+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC))
					While !Eof() .and. GW1->GW1_CDTPDC == GWU->GWU_CDTPDC ;
									 .and. GW1->GW1_EMISDC == GWU->GWU_EMISDC ;
								 .and. GW1->GW1_SERDC  == GWU->GWU_SERDC ;
								 .and. GW1->GW1_NRDC   == GWU->GWU_NRDC

						If (oModelTr:GetQtdLine() == 1 .And. !Empty(oModelTr:GetValue('GWU_EMISDC',1))) .Or. oModelTr:GetQtdLine() > 1
							oModelTr:AddLine()
						EndIf

						oModelTr:SetValue('GWU_EMISDC' 	,GWU->GWU_EMISDC )
						oModelTr:SetValue('GWU_SERDC'  	,GWU->GWU_SERDC  )
						oModelTr:SetValue('GWU_NRDC'   	,GWU->GWU_NRDC   )
						oModelTr:SetValue('GWU_CDTPDC' 	,GWU->GWU_CDTPDC )
						oModelTr:SetValue('GWU_SEQ'    	,GWU->GWU_SEQ    )
						oModelTr:SetValue('GWU_CDTRP'  	,GWU->GWU_CDTRP  )
						oModelTr:SetValue('GWU_NRCIDD' 	,GWU->GWU_NRCIDD )
						oModelTr:SetValue('GWU_CDTPVC' 	,GWU->GWU_CDTPVC )
						oModelTr:SetValue('GWU_DTPENT' 	,GWU->GWU_DTPENT )
						
						If GFXCP12117("GWU_NRCIDO")
							oModelTr:SetValue('GWU_NRCIDO' 	,GWU->GWU_NRCIDO )
							oModelTr:SetValue('GWU_CEPO' 	,GWU->GWU_CEPO   )
							oModelTr:SetValue('GWU_CEPD' 	,GWU->GWU_CEPD   )
							oModelTr:SetValue('GWU_CDCLFR' 	,GWU->GWU_CDCLFR )
							oModelTr:SetValue('GWU_CDTPOP' 	,GWU->GWU_CDTPOP )

							If Empty( oModelTr:GetValue('GWU_CEPO'))
								oModelTr:SetValue('GWU_CEPO',  POSICIONE("GU3", 1, xFilial("GU3") + GW1->GW1_CDREM, "GU3_CEP"))
							EndIf
							If Empty( oModelTr:GetValue('GWU_CEPD'))
								oModelTr:SetValue('GWU_CEPD',  POSICIONE("GU3", 1, xFilial("GU3") + GW1->GW1_CDDEST, "GU3_CEP"))
							EndIf
						EndIf

						If oModelDC:IsDeleted()
							oModelTr:DeleteLine()
						EndIf
						GWU->(dbSkip())
					EndDo
				EndIf

				oModelTr:GoLine(1)

			EndIf

		Next nCount

		oModelDC:GoLine(nLine)

	EndIf
EndIf

Return cRetorno

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEX010DE
Função que "deleta" e recupera os registros do Doc Carga
Uso restrito

@sample
GFEX010DEL()

@author Felipe M.
@since 14/07/10
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function GFEX010DE(oModel,nLinha,cOp)
Local oViewPai
Local oModelPai  := FWMODELACTIVE()
Local oModelNeg  := oModelPai:GetModel("GFEX010_01") // oModel do campo "Considerar Negociação"
Local oModelAgr  := oModelPai:GetModel("DETAIL_01")  // oModel do grid "Agrupadores"
Local oModelDC   := oModelPai:GetModel("DETAIL_02")  // oModel do grid "Doc Carga"
Local oModelIt   := oModelPai:GetModel("DETAIL_03")  // oModel do grid "Item Carga"
Local oModelTr   := oModelPai:GetModel("DETAIL_04")  // oModel do grid "Trechos"
Local nContTr, nContIt, nContDc
Local nLineDc    := oModelDC:GetLine()
Local aSaveLines := FWSaveRows()    //Salvando as linhas
Local lRefresh 	 := .F.

cSeek := oModelDC:GetValue("GW1_CDTPDC")+oModelDC:GetValue("GW1_EMISDC")+oModelDC:GetValue("GW1_SERDC")+oModelDC:GetValue("GW1_NRDC")

//Se estiver deletando
If cOp == "DELETE"
	lRefresh := .T.
	//Armazenando o valor da chave
	For nContTr := 1 to oModelTr:Length()
		oModelTr:GoLine( nContTr )
		If cSeek == oModelTr:GetValue("GWU_CDTPDC")+oModelTr:GetValue("GWU_EMISDC")+oModelTr:GetValue("GWU_SERDC")+oModelTr:GetValue("GWU_NRDC")
			oModelTr:DeleteLine()
		EndIf
	Next nContTr

	For nContIt := 1 to oModelIt:Length()
		oModelIt:GoLine( nContIt )
		If cSeek == oModelIt:GetValue("GW8_CDTPDC")+oModelIt:GetValue("GW8_EMISDC")+oModelIt:GetValue("GW8_SERDC")+oModelIt:GetValue("GW8_NRDC")
			oModelIt:DeleteLine()
		EndIf
	Next nContIt

	oModelIt:GoLine( 1 )
	oModelTr:GoLine( 1 )

ElseIf cOp == "UNDELETE" //Se estiver recuperando
	lRefresh := .T.
	For nContTr := 1 to oModelTr:Length()
		oModelTr:GoLine( nContTr )
		If cSeek == oModelTr:GetValue("GWU_CDTPDC")+oModelTr:GetValue("GWU_EMISDC")+oModelTr:GetValue("GWU_SERDC")+oModelTr:GetValue("GWU_NRDC")
			oModelTr:UnDeleteLine()
		EndIf
	Next nContTr

	For nContIt := 1 to oModelIt:Length()
		oModelIt:GoLine( nContIt )
		If cSeek == oModelIt:GetValue("GW8_CDTPDC")+oModelIt:GetValue("GW8_EMISDC")+oModelIt:GetValue("GW8_SERDC")+oModelIt:GetValue("GW8_NRDC")
			oModelIt:UnDeleteLine()
		EndIf
	Next nContIt

	oModelIt:GoLine( 1 )
	oModelTr:GoLine( 1 )

ElseIf cOp == "SETVALUE"

	For nContDc := 1 To oModelDC:Length()
		oModelDC:GoLine(nContDc)
		If !oModelDC:IsDeleted() .And. nLineDc != nContDc
			If oModelDC:GetValue("GW1_EMISDC") == FwFldGet("GW1_EMISDC",nLineDc) .And. oModelDC:GetValue("GW1_SERDC") == FwFldGet("GW1_SERDC",nLineDc) .And. ;
				oModelDC:GetValue("GW1_CDTPDC") == FwFldGet("GW1_CDTPDC",nLineDc) .And. oModelDC:GetValue("GW1_NRDC") == FwFldGet("GW1_NRDC",nLineDc)
				Help( ,, 'Help',, "O Documento de Carga já foi informado na linha " + AllTrim(Str(nContDc)) + ".", 1, 0 ) //""
				oModelDC:GoLine(nLineDc)
				FWRestRows( aSaveLines )
				Return .F.
			EndIf
		EndIf
	Next nContDc

	oModelDC:GoLine(nLineDc)

EndIf

If 	lRefresh
	oViewPai:=FwViewActive()
	oViewPai:Refresh('VIEW_02')
	oViewPai:Refresh('VIEW_03')
	oViewPai:Refresh('VIEW_04')
EndIf

	//setando o foco na primeira linha dos grids
	oModelIt:GoLine( 1 )
	oModelTr:GoLine( 1 )

FWRestRows( aSaveLines )   //Restaurando as linhas
Return .T.

Static Function GFEANRROM()
Local oModelPai := FWMODELACTIVE()
Local oModelAgr := oModelPai:GetModel("DETAIL_01")
Local nCont     := 0
Local nNrRom    := FwFldGet("GWN_NRROM")
Local nQtdNrrom := 0

	For nCont := 1 To oModelAgr:GetQtdLine()
		oModelAgr:GoLine(nCont)
		If !oModelAgr:IsDeleted()
			If oModelAgr:GetValue("GWN_NRROM") == FwFldGet("GWN_NRROM")
				nQtdNrrom ++
			EndIf
		EndIf
	Next nCont

	If nQtdNrrom > 1
		Help( ,, 'Help',, STR0085, 1, 0 ) //"Agrupador informado já existe."
		Return .F.
	EndIf
Return .T.


/*
Validação do POST do model
*/
Function GFEX010POS()
	Local oModel 		:= FWModelActive()
	Local oModelGW1 	:= oModel:GetModel('DETAIL_02')
	Local oModelGWU 	:= oModel:GetModel('DETAIL_04')
	Local nCount, nLines
	Local lRet := .T.
	Local cNrCidd
	Local cNmCidd
	Local cUfd
	
	If IsBlind()
		dbSelectArea("GU7")
		
		nLines := oModelGW1:Length()
		
		For nCount := 1 To nLines
			oModelGW1:GoLine(nCount)
			
			cNrCidd 	:= oModelGW1:GetValue('GW1_ENTNRC')
			cNmCidd 	:= oModelGW1:GetValue('GW1_ENTCID')
			cUfd		:= oModelGW1:GetValue('GW1_ENTUF')
			
			GU7->( dbSetOrder(1) )
			
			If Empty(AllTrim(cNrCidd)) .Or. !GU7->( dbSeek( xFilial("GU7") + cNrCidd ))
				If !Empty(cNmCidd) .And. !Empty(cUfd)
					GU7->( dbSetOrder(3) )
					
					If GU7->( dbSeek( xFilial("GU7")+PadR(UPPER(cNmCidd),TamSx3("GU7_NMCID")[1])+ PadR(UPPER(cUfd),TamSx3("GU7_CDUF")[1]) ) )
						oModelGW1:LoadValue('GW1_ENTNRC',GU7->GU7_NRCID)	
					Else
						lRet := .F.
					EndIf				
				EndIf
			EndIf
			
			If !lRet
				Exit
			EndIf
			
		Next nCount
		
		If lRet
			nLines := oModelGWU:Length()
			
			For nCount := 1 To nLines
				oModelGWU:GoLine(nCount)
				
				cNrCidd := oModelGWU:GetValue('GWU_NRCIDD')
				cNmCidd := oModelGWU:GetValue('GWU_NMCIDD')
				cUfd	:= oModelGWU:GetValue('GWU_UFD')
				
				GU7->( dbSetOrder(01))
				
				If Empty(AllTrim(cNrCidd)) .Or. !GU7->( dbSeek( xFilial("GU7") + cNrCidd ))
					If Empty(cNmCidd) .Or. Empty(cUfd)
						lRet := .F.
					Else
						GU7->( dbSetOrder(03) )
						
						If GU7->( dbSeek( xFilial("GU7")+PadR(UPPER(cNmCidd),TamSx3("GU7_NMCID")[1])+ PadR(UPPER(cUfd),TamSx3("GU7_CDUF")[1]) ) )
							oModelGWU:LoadValue('GWU_NRCIDD',GU7->GU7_NRCID)	
						Else
							lRet := .F.
						EndIf				
					EndIf
				EndIf
				
				If !lRet
					Exit
				EndIf
				
			Next nCount
		EndIf
		
	EndIf
Return lRet

/*/{Protheus.doc} GFEX010Log
//Retorna log de erro
@author caio.y
@since 07/08/2017
@version undefined

@type function
/*/
Function GFEX010Log()

Return cLogErro

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEX010Slg
 Seta varíavel que exibe tela de log ao fim do processamento.
@author  rafael.voltz
@since   23/08/2018
@version version
/*/
//-------------------------------------------------------------------
Function GFEX010Slg(nExibeLog)

 __nLogProc := nExibeLog

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} GFEX010SBr
 Seta varíavel que exibe barra de progresso
@author  rafael.voltz
@since   23/08/2018
@version version
/*/
//-------------------------------------------------------------------
Function GFEX010SBr(lHidePrg)

 __lHidePrg := lHidePrg

Return

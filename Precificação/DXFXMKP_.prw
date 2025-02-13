#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "TOPCONN.CH"

 /*/{Protheus.doc} DXFXMKP
    cadastro de mkp de produto
    @type  Function
    @author user
    @since 12/06/2024
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function xDXFXMKP()
Local oBrwSZO

IF FWHASMVC()

	DBSELECTAREA("SB1")
	DBSETORDER(1)

	oBrwSZO := FWMBrowse():New()

	oBrwSZO:SetMenuDef('DXFXMKP')
	oBrwSZO:SetAlias('SB1')
	oBrwSZO:SetDescription("Cadastro de Markup de produto")
	oBrwSZO:DisableDetails()
	oBrwSZO:Activate()

ELSE
	Help(" ",1,"DXFXMKPMVC",,"Ambiente desatualizado, por favor atualizar com o ultimo pacote da lib ",1,0) // "Ambiente desatualizado, por favor atualizar com o ultimo pacote da lib "

ENDIF
	
Return

/*/
{Protheus.doc} ModelDef
Define o modelo de dados para o Cadastro

@protected         
@author 	Cicero Cruz
@since 		06/08/2019 
@version 	P12.1.23  
 
@param  NULL
@return NULL
*/  
STATIC FUNCTION ModelDef()

Local oMdlDef
Local oStCSB1 := FWFormStruct( 1, 'SB1', { |x| allTrim( x ) $ 'B1_COD,B1_DESC' }, /*lViewUsado*/ )
local oStruSZO	:= FWFormStruct( 1, 'SZO', { |x| allTrim( x ) $ 'ZO_FILIAL,ZO_PRODUTO,ZO_FAIXA, ZO_MARKUP' }/*bAvalCampo*/, /*lViewUsado*/ )
oMdlDef := MPFormModel():New('U_DXFXMKP', /*{ |olModel| cotaPreVld( olModel ) }*//* bPreValidacao*/,/*{ |oMdlDef| mkpTdOk( olModel ) }/*bPosValidacao*/, { |oMdlDef| mkpcommit( olModel ) }/*bCommit*/, /*bCancel*/ )
//oStCSZO:AddTrigger('SZO_ESTADO' , 'SZO_NOME', {|| .T.} , {|| FExeTrg('SZO_ESTADO' , 'SZO_NOME')})

oMdlDef:AddFields('SB1MASTER', /*cOwner*/, oStCSB1, /*bPre, bPos, bLoad*/ )
oMdlDef:AddGrid('SZODETAIL','SB1MASTER',oStruSZO,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner é para quem pertence

// Faz relaciomaneto entre os compomentes do model
//oMdlDef:SetRelation( 'SZODETAIL', { {'ZO_FILIAL','xFilial("SZO")'},{'B1_COD' ,'ZO_PRODUTO'} }, SZO->( IndexKey( 1 ) ) )
oMdlDef:SetRelation( 'SZODETAIL', { {'ZO_PRODUTO','B1_COD'}}, SZO->( IndexKey( 1 ) ) )

oMdlDef:getModel('SZODETAIL'):SetUniqueLine({"ZO_FILIAL","ZO_PRODUTO"})

oMdlDef:SetDescription("Cadastro de Markup de produto")

oMdlDef:GetModel('SB1MASTER'):SetDescription("Cadastro de Markup de produto")

//oMdlDef:SetPrimaryKey({})
oStCSB1:SetProperty('*'			, MODEL_FIELD_WHEN,{ || .F. })	
oStruSZO:SetProperty(  'ZO_FILIAL',  MODEL_FIELD_WHEN, { || .F. } )
//oStruSZO:SetProperty(  'ZO_FAIXA',  MODEL_FIELD_WHEN, { || .F. } )
oStruSZO:SetProperty(  'ZO_PRODUTO',  MODEL_FIELD_WHEN, { || .F. } )
oStruSZO:SetProperty(  'ZO_PRODUTO',  MODEL_FIELD_OBRIGAT, { || .F. } )

//oMdlDef:SetPrimaryKey({'SZO_FILIAL','SZO_CODSEG','SZO_CODPRO','SZO_CODMOD'})

oMdlDef:SetActivate( {|oMdlDef| SZOLoad( oMdlDef ) } )

RETURN (oMdlDef)

/*/
{Protheus.doc} ViewDef
Define a Interface de Cadastro

@protected
@author 	Cicero Cruz
@since 		06/08/2019
@version 	P12.1.23 
 
@param  NULL
@return NULL
*/
STATIC FUNCTION ViewDef()

Local oVieDef
Local oMdlDef := FWLoadModel('DXFXMKP')
Local oStCSB1 := FWFormStruct( 2, 'SB1', { |x| allTrim( x ) $ 'B1_COD,B1_DESC' }, /*lViewUsado*/ )
local oStruSZO	:= FWFormStruct( 2, 'SZO' ,{ |x| allTrim( x ) $ 'ZO_FILIAL,ZO_FAIXA, ZO_MARKUP' })

oVieDef := FWFormView():New()

oVieDef:SetModel(oMdlDef)
oVieDef:AddField('VIEW_SB1_C', oStCSB1, 'SB1MASTER')

oVieDef:CreateHorizontalBox('SUPERIOR', 100)

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oVieDef:AddGrid( 'VIEW_SZO', oStruSZO, 'SZODETAIL' )

oVieDef:SetOwnerView('VIEW_SB1_C', 'SUPERIOR') 
oVieDef:SetOwnerView( 'VIEW_SZO', 'INFERIOR' )   
//oVieDef:SetViewProperty("VIEW_SB1_C", "ONLYVIEW")
//Fecha a tela na confirmao
oVieDef:SetCloseOnOk({|| .T.})

RETURN (oVieDef)

/*/                                                                                      

{Protheus.doc} MenuDef
Definio do aRotina

@protected
@author 	Cicero Cruz
@since 		06/08/2019
@version 	P12.1.23
 
@param  	Null
@return 	aRotMnu 
*/
STATIC FUNCTION MenuDef()

Local aRotina := {}     

ADD OPTION aRotina TITLE 'Visualizar'   ACTION 'VIEWDEF.DXFXMKP'	OPERATION 2	ACCESS 0 	// 'Visualizar'
ADD OPTION aRotina TITLE 'Incluir'		ACTION 'VIEWDEF.DXFXMKP'	OPERATION 3	ACCESS 0 	// 'Incluir'
ADD OPTION aRotina TITLE 'Alterar'		ACTION 'VIEWDEF.DXFXMKP'	OPERATION 4	ACCESS 0 	// 'Alterar'
ADD OPTION aRotina TITLE 'Excluir'		ACTION 'VIEWDEF.DXFXMKP'	OPERATION 5	ACCESS 0 	// 'Excluir'

RETURN(aRotina)                                                                           

/*/
{Protheus.doc} FExeTrg
Execuo de Gatilhos

@protected
@author 	Cicero Cruz
@since 	27/07/2015 
@version 	P12 
 
@param  cCpoOri, 
		 cCpoDes
@return cRetTrg
*/

STATIC FUNCTION FExeTrg(cCpoOri, cCpoDes)

Local oMdlRef := FWModelActive()
Local oMdlSZO := oMdlRef:GetModel('SB1MASTER')
Local aConSX5	:= {}
Local cRetTrg := ''

DBSELECTAREA("SX5")

IF cCpoOri == 'SZO_ESTADO'
	aConSX5 := FWGetSX5( "12",TRIM( oMdlSZO:GetValue('SZO_ESTADO') ) )
	cRetTrg :=  aConSX5[1,4]	
ENDIF


Return cRetTrg

    
Return 



/*/{Protheus.doc} cotaLoad
Carrega a grid de itens com os canais do ADMV
@author DS2U ( SDA )
@since 01/08/2018
@version 1.0
@param olModel, object, Modelo de dados do MVC de cadastro de cotas por item
@type function
/*/
Static Function SZOLoad( olModel )

	local alArea		:= getArea()
	local nlOpc			:= olModel:getOperation()
	local olModelSB1	:= olModel:getModel('SB1MASTER' )
	local olModelSZO	:= olModel:getModel('SZODETAIL')
	local aMarkup		:= {}
	local nlx
	local alInfoSZO		:= {}
	local nlLine
	local olStruct
	local nlLinAdd		:= 0
	
	if ( nlOpc == 3 .or. nlOpc == 4 )
	
		dbSelectArea("SZO")
		SZO->( dbSetOrder( 1 ) ) // SZO_FILIAL, SZO_PEDCOM, SZO_ITEMPC, SZO_PROD, SZO_CANAL
		
		dbSelectArea("SB1")
		SB1->( dbSetOrder( 1 ) )
		
		if ( SB1->( dbSeek( xFilial("SB1") + SB1->B1_COD ) ) )
	
			olStruct	:= olModelSZO:getStruct()
			alInfoSZO	:= olStruct:getFields()
		
			olModelSB1:loadValue("B1_COD"	, SB1->B1_COD )
			olModelSB1:loadValue("B1_DESC"	, SB1->B1_DESC )
		
			aMarkup	:= getMKP(SB1->B1_COD) // Adiciona apenas os canais 1º linha, pois diferente disso, nao controla cotas
	
			// Ponteiro para varrer os canais do ADMV
			for nlx := 1 to len( aMarkup )
			
				nlLinAdd++
	
				if ( nlOpc == 3 .or. nlOpc == 4 )
			
					if (  nlLinAdd > 1 .or. nlOpc == 4 )
						nlLine := olModelSZO:AddLine()
						olModelSZO:goLine( nlLine )
					endif
					
					olModelSZO:loadValue( 'ZO_FILIAL', aMarkup[nlx][1] )	
					olModelSZO:loadValue( 'ZO_FAIXA', aMarkup[nlx][2] )	
					olModelSZO:loadValue( 'ZO_MARKUP', aMarkup[nlx][3] )	
						
				endif
					
			next nlx
			
		endif
	
	endif
	
	restArea( alArea )

Return .T.


Static Function getMKP(cProduto)
Local aRet := {}
Local cQuery	:= ''
Local cAliasQry := GetNextAlias()

cQuery := "SELECT * "
cQuery += "  FROM " + RetSQLTab('SZO')
cQuery += "  WHERE  "
cQuery += "  ZO_PRODUTO  = '" + cProduto + "'  "
cQuery += "  AND D_E_L_E_T_ = ' '"
cQuery += "  ORDER BY ZO_FILIAL , ZO_FAIXA"

TcQuery cQuery new Alias ( cAliasQry )

(cAliasQry)->(dbGoTop())

While !(cAliasQry)->(EOF())
	aadd(aRet,{(cAliasQry)->ZO_FILIAL,(cAliasQry)->ZO_FAIXA,(cAliasQry)->ZO_MARKUP})
	(cAliasQry)->(dbSkip())
EndDo

(cAliasQry)->(DbCloseArea())

Return aRet



/*/{Protheus.doc} cotaCommit
Responsavel por realizar a gravacao no banco de dados
@author DS2U (SDA)
@since 01/08/2018
@version 1.0
@return llRet, Se .T. validacao OK, se nao houve falha no processamento
@param olModel, object, Modelo de dados do MVC de cadastro de cotas por item
@type function
/*/
Static Function mkpCommit( olModel )

	local llRet			:= .T.
	local nlx
	local olModelSZO	:= olModel:getModel('SZODETAIL')
	local lReclock		:= .t.

	for nlx := 1 to olModelSZO:length()
		
		olModelSZO:goLine( nlx )

		SZO->(DbSetOrder(1))
		If SZO->(DbSeek(olModelSZO:getValue( "ZO_FILIAL" ) + olModelSZO:getValue( "ZO_PRODUTO" ) +  olModelSZO:getValue( "ZO_FAIXA" )))
			lReclock		:= .f.
		Else
			lReclock		:= .t.
		EndIf

		SB1->(DBSETORDER( 1 ))
		SB1->(DbSeek(Xfilial('SB1')+ olModelSZO:getValue( "ZO_PRODUTO" )))
		
		if ( recLock( "SZO", .F. ) )
		
			SZO->ZO_FILIAL	:= xFilial("SZO")
			SZO->ZO_PRODUTO	:= SB1->B1_COD
			SZO->ZO_DESC	:= SB1->B1_DESC
			SZO->ZO_FAIXA	:= olModelSZO:getValue( "ZO_FAIXA" )
			SZO->ZO_MARKUP	:= olModelSZO:getValue( "ZO_MARKUP" )
		
			SZO->( msUnLock() )
			
		endif
		
	next nlx


Return llRet

#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/
{Protheus.doc} DAXA010

@type function
Cadastro de Estados x Dispensa Policia Civil 

@author 	Cicero Cruz
@since 		06/08/2019
@version 	P12.1.23
 
@param  NULL
@return NULL
*/  
USER FUNCTION DAXA010()

Local oBrwZ00

IF FWHASMVC()

	DBSELECTAREA("Z00")
	DBSETORDER(1)

	oBrwZ00 := FWMBrowse():New()

	oBrwZ00:SetMenuDef('DAXA010')
	oBrwZ00:SetAlias('Z00')
	oBrwZ00:SetDescription("Cadastro de Estados x Dispensa Policia Civil ")
	oBrwZ00:DisableDetails()
	oBrwZ00:Activate()

ELSE
	Help(" ",1,"DAXA010MVC",,"Ambiente desatualizado, por favor atualizar com o ultimo pacote da lib ",1,0) // "Ambiente desatualizado, por favor atualizar com o ultimo pacote da lib "

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
Local oStCZ00 := FWFormStruct(1, 'Z00')

oMdlDef := MPFormModel():New('U_DAXA010')

oStCZ00:AddTrigger('Z00_ESTADO' , 'Z00_NOME', {|| .T.} , {|| FExeTrg('Z00_ESTADO' , 'Z00_NOME')})

oMdlDef:AddFields('Z00MASTER', /*cOwner*/, oStCZ00, /*bPre, bPos, bLoad*/ )

oMdlDef:SetDescription("Cadastro de Estados x Dispensa Policia Civil ")

oMdlDef:GetModel('Z00MASTER'):SetDescription("Estados x Dispensa Policia Civil ")

oMdlDef:SetPrimaryKey({})

//oMdlDef:SetPrimaryKey({'Z00_FILIAL','Z00_CODSEG','Z00_CODPRO','Z00_CODMOD'})

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
Local oMdlDef := FWLoadModel('DAXA010')
Local oStCZ00 := FWFormStruct(2, 'Z00')

oVieDef := FWFormView():New()

oVieDef:SetModel(oMdlDef)
oVieDef:AddField('VIEW_Z00_C', oStCZ00, 'Z00MASTER')

oVieDef:CreateHorizontalBox('SUPERIOR', 100)

oVieDef:SetOwnerView('VIEW_Z00_C', 'SUPERIOR')    

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

ADD OPTION aRotina TITLE 'Visualizar'   ACTION 'VIEWDEF.DAXA010'	OPERATION 2	ACCESS 0 	// 'Visualizar'
ADD OPTION aRotina TITLE 'Incluir'		ACTION 'VIEWDEF.DAXA010'	OPERATION 3	ACCESS 0 	// 'Incluir'
ADD OPTION aRotina TITLE 'Alterar'		ACTION 'VIEWDEF.DAXA010'	OPERATION 4	ACCESS 0 	// 'Alterar'
ADD OPTION aRotina TITLE 'Excluir'		ACTION 'VIEWDEF.DAXA010'	OPERATION 5	ACCESS 0 	// 'Excluir'

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
Local oMdlZ00 := oMdlRef:GetModel('Z00MASTER')

Local cRetTrg := ''

DBSELECTAREA("SX5")

IF cCpoOri == 'Z00_ESTADO'
	SX5->(DBSETORDER(1))
	IF SX5->( DBSEEK( xFilial('SX5') + "12" + TRIM( oMdlZ00:GetValue('Z00_ESTADO') ) ) )
		cRetTrg := Left(SX5->X5_DESCRI, TamSX3('Z00_NOME')[1])
	ENDIF
ENDIF


Return cRetTrg

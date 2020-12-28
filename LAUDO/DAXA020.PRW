#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'


// Definições de Tipos de mensagem
#Define MT_TDEFAULT 0 // Adiciona somente o botão default "Fechar"
#Define MT_TYESNO   1 // Adiciona os botões "Sim" e "Não", focando no "Sim"
#Define MT_TNOYES   2 // Adiciona os botões "Não" e "Sim", focando no "Não"

// Definições de Ícones da mensagem
#Define MT_ISUCCES  "FWSKIN_SUCCES_ICO.PNG" // Ícone Default Sucesso
#Define MT_IALERT   "FWSKIN_ALERT_ICO.PNG"  // Ícone Default Alerta
#Define MT_IERROR   "FWSKIN_ERROR_ICO.PNG"  // Ícone Default Erro
#Define MT_IINFO    "FWSKIN_INFO_ICO.PNG"   // Ícone Default Informação

/*/
{Protheus.doc} DAXA020
Cadastro de UF x Grupo de Tributação x Aliquota 
@type function
@author 	Cicero Cruz
@since 		07/08/2020
@version 	P12.1.17
@task       6553 
@param  NULL
@return NULL
*/  
USER FUNCTION DAXA020()

LOCAL oBrwQP1

IF FWHASMVC()

	SetKEY( VK_F5, {|| MsgInfo("Você pressionou Tecla F5")} )

    DBSELECTAREA("QP1")
	DBSETORDER(1)

	oBrwQP1 := FWMBrowse():New()

	oBrwQP1:SetMenuDef('DAXA020')
	oBrwQP1:SetAlias('QP1')
	oBrwQP1:SetDescription("Atualização DE-PARA Ensaios QIPxQIE")
	oBrwQP1:DisableDetails()
	oBrwQP1:Activate()

ELSE

	Help(" ",1,"DAXA020MVC",,"Ambiente desatualizado, por favor atualizar com o ultimo pacote da lib ",1,0) // "Ambiente desatualizado, por favor atualizar com o ultimo pacote da lib "

ENDIF
	
Return

/*/
{Protheus.doc} ModelDef
Define o modelo de dados para o Cadastro        
@author 	Cicero Cruz
@since 		06/08/2019 
@version 	P12.1.17  
@protected
@param  NULL
@return NULL
*/  
STATIC FUNCTION ModelDef()

Local oMdlDef
Local oStCQP1 := FWFormStruct(1, 'QP1')
//Local oEvent  := CLXA020():New()

oMdlDef := MPFormModel():New('U_DAXA020')

//oStCQP1:AddTrigger('QP1_UF' , 'QP1_NOME', {|| .T.} , {|| FExeTrg('QP1_UF' , 'QP1_NOME')})

oMdlDef:AddFields('QP1MASTER', /*cOwner*/, oStCQP1, /*bPre, bPos, bLoad*/ )

oStCQP1:SetProperty( 'QP1_ENSAIO',  MODEL_FIELD_WHEN, { || .F. } )
oStCQP1:SetProperty( 'QP1_DESCPO',  MODEL_FIELD_WHEN, { || .F. } )
oStCQP1:SetProperty(  'QP1_CARTA',  MODEL_FIELD_WHEN, { || .F. } )

oMdlDef:SetDescription("Cadastro De-Para QIE x QIP")

oMdlDef:GetModel('QP1MASTER'):SetDescription("Cadastro De-Para Ensaios QIP x QIE")

//oMdlDef:InstallEvent("CLXA020", /*cOwner*/, oEvent)

oMdlDef:SetPrimaryKey({})

RETURN (oMdlDef)

/*/
{Protheus.doc} ViewDef
Define a Interface de Cadastro
@author 	Cicero Cruz
@since 		06/08/2019
@version 	P12.1.17
@protected 
@param  NULL
@return NULL
*/
STATIC FUNCTION ViewDef()

Local oVieDef
Local oMdlDef := FWLoadModel('DAXA020')
Local oStCQP1 := FWFormStruct(2, 'QP1')

oVieDef := FWFormView():New()

oVieDef:SetModel(oMdlDef)
oVieDef:AddField('VIEW_QP1_C', oStCQP1, 'QP1MASTER')

oVieDef:CreateHorizontalBox('SUPERIOR', 100)

oVieDef:SetOwnerView('VIEW_QP1_C', 'SUPERIOR')    

oStCQP1:RemoveField( 'QP1_DESCIN' )
oStCQP1:RemoveField( 'QP1_DESCES' )
oStCQP1:RemoveField( 'QP1_TPCART' )
oStCQP1:RemoveField( 'QP1_QTDE'   )
oStCQP1:RemoveField( 'QP1_METODO' )
oStCQP1:RemoveField( 'QP1_TIPO'   )
oStCQP1:RemoveField( 'QP1_NIENSR' )

//Fecha a tela na confirmação
oVieDef:SetCloseOnOk({|| .T.})

RETURN (oVieDef)

/*/                                                                                      
{Protheus.doc} MenuDef
Rotina padrão para exibição de opções no Browse
@author 	Cicero Cruz
@since 		06/08/2019
@version 	P12.1.17
@protected
@param  	Null
@return 	aRotMnu, Array com os dados dos Botões 
*/
STATIC FUNCTION MenuDef()

Local aRotina := {}     

ADD OPTION aRotina TITLE 'Visualizar'   ACTION 'VIEWDEF.DAXA020'	OPERATION 2	ACCESS 0 	// 'Visualizar'
ADD OPTION aRotina TITLE 'Alterar'		ACTION 'VIEWDEF.DAXA020'	OPERATION 4	ACCESS 0 	// 'Alterar'

RETURN(aRotina)                                                                           

//-------------------------------------------------------------------
/*/{Protheus.doc} CLXA020
   Classe interna implementando o FWModelEvent
@type       class
@author     Cicero Odilio Cruz
@since      07/08/2020
@version    1.0
/*/
//-------------------------------------------------------------------
Class CLXA020 FROM FWModelEvent
    DATA   lRet         // Variável de Retorno

    Method New()                                                                            //Método que instancia a classe
    Method InTTS()                                                                          //Método que é chamado pelo MVC quando ocorrer as ações do commit Após as gravações porém antes do final da transação. Esse evento ocorre uma vez no contexto do modelo principal.
    Method Destroy()                                                                        //Método que desinstancia a classe, nào é necessario chamar pois é automático

    /* Métodos Possíveis
    Method After(oSubModel, cModelId, cAlias, lNewRecord)                                   //Método que é chamado pelo MVC quando ocorrer as ações do commit depois da gravação de cada submodelo (field ou cada linha de uma grid)
    Method Before(oSubModel, cModelId, cAlias, lNewRecord)                                  //Método que é chamado pelo MVC quando ocorrer as ações do commit antes da gravação de cada submodelo (field ou cada linha de uma grid)
    Method AfterTTS(oModel, cModelId)                                                       //Método que é chamado pelo MVC quando ocorrer as ações do  após a transação. Esse evento ocorre uma vez no contexto do modelo principal.
    Method BeforeTTS(oModel, cModelId)                                                      //Método que é chamado pelo MVC quando ocorrer as ações do commit antes da transação. Esse evento ocorre uma vez no contexto do modelo principal.
    Method InTTS(oModel, cModelId)                                                          //Método que é chamado pelo MVC quando ocorrer as ações do commit Após as gravações porém antes do final da transação. Esse evento ocorre uma vez no contexto do modelo principal.
    Method Activate(oModel, lCopy)                                                          //Método que é chamado pelo MVC quando ocorrer a ativação do Model. Esse evento ocorre uma vez no contexto do modelo principal.
    Method DeActivate(oModel)                                                               //Método que é chamado pelo MVC quando ocorrer a desativação do Model. Esse evento ocorre uma vez no contexto do modelo principal.
    Method ModelPreVld(oModel, cModelId)                                                    //Método que é chamado pelo MVC quando ocorrer as ações de pre validação do Model. Esse evento ocorre uma vez no contexto do modelo principal.
    Method ModelPosVld(oModel, cModelId)                                                    //Método que é chamado pelo MVC quando ocorrer as ações de pos validação do Model. Esse evento ocorre uma vez no contexto do modelo principal.
    Method GridPosVld(oSubModel, cModelID)                                                  //Método que é chamado pelo MVC quando ocorrer as ações de pós validação do Grid.
    Method GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue)  //Método que é chamado pelo MVC quando ocorrer as ações de pre validação da linha do Grid.
    Method GridLinePosVld(oSubModel, cModelID, nLine)                                       //Método que é chamado pelo MVC quando ocorrer as ações de pos validação da linha do Grid.
    Method FieldPreVld(oSubModel, cModelID, cAction, cId, xValue)                           //Método que é chamado pelo MVC quando ocorrer a ação de pré validação do Field.
    Method FieldPosVld(oSubModel, cModelID)                                                 //Método que é chamado pelo MVC quando ocorrer a ação de pós validação do Field.
    Method GetEvent(cIdEvent)                                                               //Método que retorna um evento superior da cadeia de eventos. Através do método InstallEvent, é possível encadear dois eventos que estão relacionados, como por exemplo um evento de negócio padrão e um evento localizado que complementa essa regra de negócio. Caso o evento localizado, necessite de atributos da classe superior, ele irá utilizar esse método para recuperá-lo.
    */
End Class

//--------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} :New
   Método de criação da classe
@type       method
@author     Cicero Odilio Cruz
@since      07/08/2020
@version    1.0
/*/
//--------------------------------------------------------------------------------------------------------------------------------------
Method New ()  Class CLXA020
    self:lRet        := .F.                       
Return

//--------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} :InTTS
   Método que é chamado pelo MVC quando ocorrer as ações do commit, após as gravações porém antes do final da transação. 
   Esse evento ocorre uma vez no contexto do modelo principal.
@type       method
@author     Cicero Odilio Cruz
@since      07/08/2020
@version    1.0
/*/
//--------------------------------------------------------------------------------------------------------------------------------------
Method InTTS(oModel, cModelId) Class CLXA020

RETURN


//--------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} :Destroy
   Método para desinstanciar da classe
@type       method
@author     Cicero Odilio Cruz
@since      07/08/2020
@version    1.0
/*/
//--------------------------------------------------------------------------------------------------------------------------------------
Method Destroy()  Class CLXA020       
    self:lRet        := Nil                   
RETURN


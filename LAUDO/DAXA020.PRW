#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'


// Defini��es de Tipos de mensagem
#Define MT_TDEFAULT 0 // Adiciona somente o bot�o default "Fechar"
#Define MT_TYESNO   1 // Adiciona os bot�es "Sim" e "N�o", focando no "Sim"
#Define MT_TNOYES   2 // Adiciona os bot�es "N�o" e "Sim", focando no "N�o"

// Defini��es de �cones da mensagem
#Define MT_ISUCCES  "FWSKIN_SUCCES_ICO.PNG" // �cone Default Sucesso
#Define MT_IALERT   "FWSKIN_ALERT_ICO.PNG"  // �cone Default Alerta
#Define MT_IERROR   "FWSKIN_ERROR_ICO.PNG"  // �cone Default Erro
#Define MT_IINFO    "FWSKIN_INFO_ICO.PNG"   // �cone Default Informa��o

/*/
{Protheus.doc} DAXA020
Cadastro de UF x Grupo de Tributa��o x Aliquota 
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

	SetKEY( VK_F5, {|| MsgInfo("Voc� pressionou Tecla F5")} )

    DBSELECTAREA("QP1")
	DBSETORDER(1)

	oBrwQP1 := FWMBrowse():New()

	oBrwQP1:SetMenuDef('DAXA020')
	oBrwQP1:SetAlias('QP1')
	oBrwQP1:SetDescription("Atualiza��o DE-PARA Ensaios QIPxQIE")
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

//Fecha a tela na confirma��o
oVieDef:SetCloseOnOk({|| .T.})

RETURN (oVieDef)

/*/                                                                                      
{Protheus.doc} MenuDef
Rotina padr�o para exibi��o de op��es no Browse
@author 	Cicero Cruz
@since 		06/08/2019
@version 	P12.1.17
@protected
@param  	Null
@return 	aRotMnu, Array com os dados dos Bot�es 
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
    DATA   lRet         // Vari�vel de Retorno

    Method New()                                                                            //M�todo que instancia a classe
    Method InTTS()                                                                          //M�todo que � chamado pelo MVC quando ocorrer as a��es do commit Ap�s as grava��es por�m antes do final da transa��o. Esse evento ocorre uma vez no contexto do modelo principal.
    Method Destroy()                                                                        //M�todo que desinstancia a classe, n�o � necessario chamar pois � autom�tico

    /* M�todos Poss�veis
    Method After(oSubModel, cModelId, cAlias, lNewRecord)                                   //M�todo que � chamado pelo MVC quando ocorrer as a��es do commit depois da grava��o de cada submodelo (field ou cada linha de uma grid)
    Method Before(oSubModel, cModelId, cAlias, lNewRecord)                                  //M�todo que � chamado pelo MVC quando ocorrer as a��es do commit antes da grava��o de cada submodelo (field ou cada linha de uma grid)
    Method AfterTTS(oModel, cModelId)                                                       //M�todo que � chamado pelo MVC quando ocorrer as a��es do  ap�s a transa��o. Esse evento ocorre uma vez no contexto do modelo principal.
    Method BeforeTTS(oModel, cModelId)                                                      //M�todo que � chamado pelo MVC quando ocorrer as a��es do commit antes da transa��o. Esse evento ocorre uma vez no contexto do modelo principal.
    Method InTTS(oModel, cModelId)                                                          //M�todo que � chamado pelo MVC quando ocorrer as a��es do commit Ap�s as grava��es por�m antes do final da transa��o. Esse evento ocorre uma vez no contexto do modelo principal.
    Method Activate(oModel, lCopy)                                                          //M�todo que � chamado pelo MVC quando ocorrer a ativa��o do Model. Esse evento ocorre uma vez no contexto do modelo principal.
    Method DeActivate(oModel)                                                               //M�todo que � chamado pelo MVC quando ocorrer a desativa��o do Model. Esse evento ocorre uma vez no contexto do modelo principal.
    Method ModelPreVld(oModel, cModelId)                                                    //M�todo que � chamado pelo MVC quando ocorrer as a��es de pre valida��o do Model. Esse evento ocorre uma vez no contexto do modelo principal.
    Method ModelPosVld(oModel, cModelId)                                                    //M�todo que � chamado pelo MVC quando ocorrer as a��es de pos valida��o do Model. Esse evento ocorre uma vez no contexto do modelo principal.
    Method GridPosVld(oSubModel, cModelID)                                                  //M�todo que � chamado pelo MVC quando ocorrer as a��es de p�s valida��o do Grid.
    Method GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue)  //M�todo que � chamado pelo MVC quando ocorrer as a��es de pre valida��o da linha do Grid.
    Method GridLinePosVld(oSubModel, cModelID, nLine)                                       //M�todo que � chamado pelo MVC quando ocorrer as a��es de pos valida��o da linha do Grid.
    Method FieldPreVld(oSubModel, cModelID, cAction, cId, xValue)                           //M�todo que � chamado pelo MVC quando ocorrer a a��o de pr� valida��o do Field.
    Method FieldPosVld(oSubModel, cModelID)                                                 //M�todo que � chamado pelo MVC quando ocorrer a a��o de p�s valida��o do Field.
    Method GetEvent(cIdEvent)                                                               //M�todo que retorna um evento superior da cadeia de eventos. Atrav�s do m�todo InstallEvent, � poss�vel encadear dois eventos que est�o relacionados, como por exemplo um evento de neg�cio padr�o e um evento localizado que complementa essa regra de neg�cio. Caso o evento localizado, necessite de atributos da classe superior, ele ir� utilizar esse m�todo para recuper�-lo.
    */
End Class

//--------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} :New
   M�todo de cria��o da classe
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
   M�todo que � chamado pelo MVC quando ocorrer as a��es do commit, ap�s as grava��es por�m antes do final da transa��o. 
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
   M�todo para desinstanciar da classe
@type       method
@author     Cicero Odilio Cruz
@since      07/08/2020
@version    1.0
/*/
//--------------------------------------------------------------------------------------------------------------------------------------
Method Destroy()  Class CLXA020       
    self:lRet        := Nil                   
RETURN


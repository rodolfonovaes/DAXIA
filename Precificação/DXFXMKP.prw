//Bibliotecas
#Include "Totvs.ch"
#Include "FWMVCDef.ch"
#INCLUDE "TOPCONN.CH"
#include "rwmake.ch"
#include "protheus.ch"

//Variveis Estaticas
Static cTitulo := "Cadastro de Markup de produto"
Static cTabPai := "SB1"
Static cTabFilho := "SZO"

/*/{Protheus.doc} User Function DXFXMKP
Cadastro de Markup de produto
@author Rodolfo Novaes de Sousa
@since 27/06/2024
@version 1.0
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/

User Function DXFXMKP()
	Local aArea   := FWGetArea()
	Local oBrowse
	Private aRotina := {}

	//Definicao do menu
	aRotina := MenuDef()

	//Instanciando o browse
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias(cTabPai)
	oBrowse:SetDescription(cTitulo)
	oBrowse:DisableDetails()

	//Ativa a Browse
	oBrowse:Activate()

	FWRestArea(aArea)
Return Nil

/*/{Protheus.doc} MenuDef
Menu de opcoes na funcao DXFXMKP
@author Rodolfo Novaes de Sousa
@since 27/06/2024
@version 1.0
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/

Static Function MenuDef()
	Local aRotina := {}

	//Adicionando opcoes do menu
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.DXFXMKP" OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir" ACTION "VIEWDEF.DXFXMKP" OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar" ACTION "U_UPDMKP" OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir" ACTION "VIEWDEF.DXFXMKP" OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE "Copiar" ACTION "VIEWDEF.DXFXMKP" OPERATION 9 ACCESS 0
	ADD OPTION aRotina TITLE "Replicar" ACTION "U_DXREPMKP()" OPERATION 9 ACCESS 0

Return aRotina

/*/{Protheus.doc} ModelDef
Modelo de dados na funcao DXFXMKP
@author Rodolfo Novaes de Sousa
@since 27/06/2024
@version 1.0
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/

Static Function ModelDef()
	Local oStruPai := FWFormStruct(1, cTabPai)
	Local oStruFilho := FWFormStruct(1,"SZO", {|cField| !(AllTrim(Upper(cField)) $ "ZO_DESC/ZO_PRODUTO") })//FWFormStruct(1, cTabFilho)
	Local aRelation := {}
	Local oModel
	Local bPre := Nil
	Local bPos := Nil
	Local bCancel := Nil


	//Cria o modelo de dados para cadastro
	oModel := MPFormModel():New("DXFXMKPM", bPre, bPos, /*bCommit { |oModel| mkpcommit( oModel ) }*/, bCancel)
	oModel:AddFields("SB1MASTER", /*cOwner*/, oStruPai)
	oModel:AddGrid("SZODETAIL","SB1MASTER",oStruFilho,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)
	oModel:SetDescription("Modelo de dados - " + cTitulo)
	oModel:GetModel("SB1MASTER"):SetDescription( "Dados de - " + cTitulo)
	oModel:GetModel("SZODETAIL"):SetDescription( "Grid de - " + cTitulo)
	//oModel:SetPrimaryKey({})
	oModel:SetOnlyQuery("SB1MASTER",.T.)

	//Fazendo o relacionamento
	//aAdd(aRelation, {"ZO_FILIAL", "FWxFilial('SZO')"} )
	aAdd(aRelation, {"ZO_PRODUTO", "B1_COD"})
	oModel:SetRelation("SZODETAIL", aRelation)
	
	//Definindo campos unicos da linha
	oModel:GetModel("SZODETAIL"):SetUniqueLine({'ZO_FILIAL','ZO_FAIXA'})
	//oStruFilho:SetProperty( 'ZO_PRODUTO',  MODEL_FIELD_WHEN, { || .F. } )
	//-- Adicionado campo na mão porque via updistr não estava alterando o uso do campo
	oStruFilho:AddField(FWX3Titulo("ZO_FILIAL")											,;	// 	[01]  C   Titulo do campo  
					 FWX3Titulo("ZO_FILIAL")									   		,;	// 	[02]  C   ToolTip do campo 
					 "ZO_FILIAL"														,;	// 	[03]  C   Id do Field
					 "C"																,;	// 	[04]  C   Tipo do campo
					 TAMSX3("ZO_FILIAL")[1]												,;	// 	[05]  N   Tamanho do campo
					 TAMSX3("ZO_FILIAL")[2]												,;	// 	[06]  N   Decimal do campo
					 {|| U_vlZOfil()}															,;	// 	[07]  B   Code-block de validação do campo
					 NIL																,;	// 	[08]  B   Code-block de validação When do campo
					 NIL																,;	//	[09]  A   Lista de valores permitido do campo
					 .T.																,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 NIL																,;	//	[11]  B   Code-block de inicializacao do campo
					 NIL																,;	//	[12]  L   Indica se trata-se de um campo chave
					 NIL																,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 .F.																)	// 	[14]  L   Indica se o campo é virtual

Return oModel

/*/{Protheus.doc} ViewDef
Visualizacao de dados na funcao DXFXMKP
@author Rodolfo Novaes de Sousa
@since 27/06/2024
@version 1.0
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/

Static Function ViewDef()
	Local oModel := FWLoadModel("DXFXMKP")
	Local oStruPai := FWFormStruct(2, cTabPai)
	Local oStruFilho := FWFormStruct(2,"SZO", {|cField| !(AllTrim(Upper(cField)) $ "ZO_DESC/ZO_PRODUTO") })
	Local oView

	//Cria a visualizacao do cadastro
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("VIEW_SB1", oStruPai, "SB1MASTER")
	oView:AddGrid("VIEW_SZO",  oStruFilho,  "SZODETAIL")

	//Partes da tela
	oView:CreateHorizontalBox("CABEC", 30)
	oView:CreateHorizontalBox("GRID", 70)
	oView:SetOwnerView("VIEW_SB1", "CABEC")
	oView:SetOwnerView("VIEW_SZO", "GRID")

	//Titulos
	oView:EnableTitleView("VIEW_SB1", "Cabecalho - SB1")
	oView:EnableTitleView("VIEW_SZO", "Grid - SZO")

	
	//-- Adicionado campo na mão porque via updistr não estava alterando o uso do campo
	oStruFilho:AddField("ZO_FILIAL"														,;	// [01]  C   Nome do Campo
					"00"																,;	// [02]  C   Ordem
					FWX3Titulo("ZO_FILIAL")												,;	// [03]  C   Titulo do campo//"Código"
					FWX3Titulo("ZO_FILIAL")												,;	// [04]  C   Descricao do campo//"Código"
					NIL																	,;	// [05]  A   Array com Help
					"C"																	,;	// [06]  C   Tipo do campo
					""																	,;	// [07]  C   Picture
					NIL																	,;	// [08]  B   Bloco de Picture Var
					"SM0"																,;	// [09]  C   Consulta F3
					.T.																	,;	// [10]  L   Indica se o campo é alteravel
					NIL																	,;	// [11]  C   Pasta do campo
					NIL																	,;	// [12]  C   Agrupamento do campo
					NIL																	,;	// [13]  A   Lista de valores permitido do campo (Combo)
					NIL																	,;	// [14]  N   Tamanho maximo da maior opção do combo
					NIL																	,;	// [15]  C   Inicializador de Browse
					.F.																	,;	// [16]  L   Indica se o campo é virtual
					NIL																	,;	// [17]  C   Picture Variavel
					NIL																	)	// [18]  L   Indica pulo de linha após o campo		

Return oView

#Include 'Protheus.ch'

User Function UPDMKP()
    Local cLinok 	:= "Allwaystrue"
    Local cTudook 	:= "Allwaystrue"
    Local nOpce 	:= 1 	//define modo de alteração para a enchoice
    Local nOpcg 	:= 3 	//define modo de alteração para o grid
    Local cFieldok 	:= "Allwaystrue"
    Local lRet 		:= .T.
    Local cMensagem := ""
    Local lVirtual  := .T. 	//Mostra campos virtuais se houver
    Local nFreeze	:= 0	
    Local nAlturaEnc:= 400	//Altura da Enchoice

    Private cCadastro	:= "Markup de produto"	
    Private aCols 		:= {}
    Private aHeader 	:= {}
    Private aCpoEnchoice:= {}
    Private aAltEnchoice:= {}
    Private cTitulo
    Private cAlias1 	:= "SB1"
    Private cAlias2 	:= "SZO"

	aCpoEnchoice:= {'B1_COD','B1_DESC'}
	aAltEnchoice:= {}
    
    // Verifica se o pedido já está liberado
    If SB1->B1_MSBLQL == '1'
        MsgStop("Este produto esta bloqueado")
    Else
        RegToMemory("SB1",.F.)
        RegToMemory("SZO",.F.)
    
        DefineCabec()
        DefineaCols(nOpcg)
        
        lRet:=Modelo3(cCadastro,cAlias1,cAlias2,aCpoEnchoice,cLinok,cTudook,nOpce,nOpcg,cFieldok,lVirtual,,aAltenchoice,nFreeze,,,nAlturaEnc)
        
        //retornará como true se clicar no botao confirmar
        if lRet

            Processa({||Gravar()},cCadastro,"Alterando os dados, aguarde...")
            
        else
            RollbackSx8()
        endif

    Endif

Return

 
Static Function DefineCabec()
    Local aSZO		:= {"ZO_FILIAL","ZO_FAIXA","ZO_MARKUP"}
    Local nUsado
	Local nX
    aHeader		:= {}
    aCpoEnchoice:= {}

    nUsado:=0
    
    //Monta a enchoice
    DbSelectArea("SX3")
    SX3->(DbSetOrder(1))
    dbseek(cAlias1)
    while SX3->(!eof()) .AND. X3_ARQUIVO == cAlias1
        IF X3USO(X3_USADO) .AND. CNIVEL >= X3_NIVEL
            AADD(ACPOENCHOICE,X3_CAMPO)
        endif
        dbskip()
    enddo

    //Monta o aHeader do grid conforme os campos definidos no array aSZO (apenas os campos que deseja)
    //Caso contrário, se quiser todos os campos é necessário trocar o "For" por While, para que este faça a leitura de toda a tabela
    DbSelectArea("SX3")
    SX3->(DbSetOrder(2))
    aHeader:={}
    For nX := 1 to Len(aSZO)
        If SX3->(DbSeek(aSZO[nX]))
			nUsado:=nUsado+1
			Aadd(aHeader, {TRIM(X3_TITULO), X3_CAMPO , X3_PICTURE, X3_TAMANHO, X3_DECIMAL,X3_VALID, X3_USADO  , X3_TIPO   , X3_ARQUIVO, X3_CONTEXT})
        Endif
    Next nX

 	 
Return
 
//Insere o conteudo no aCols do grid
Static function DefineaCols(nOpc)
Local nQtdcpo 	:= 0
Local i			:= 0
Local nCols 	:= 0
Local cQuery	:= ''
Local cAliasQry := GetNextAlias()
nQtdcpo 		:= len(aHeader)
aCols			:= {}

cQuery := "SELECT * "
cQuery += "  FROM " + RetSQLTab('SZO')
cQuery += "  WHERE  "
cQuery += "  ZO_PRODUTO = '" + SB1->B1_COD + "'  "
cQuery += "  AND SZO.D_E_L_E_T_ = ' '"

TcQuery cQuery new Alias ( cAliasQry )

(cAliasQry)->(dbGoTop())

While !(cAliasQry)->(EOF())
	aAdd(aCols,array(nQtdcpo+1))
	nCols++
	aCols[nCols,1] := (cAliasQry)->ZO_FILIAL
	aCols[nCols,2] := (cAliasQry)->ZO_FAIXA
	aCols[nCols,3] := (cAliasQry)->ZO_MARKUP
	aCols[nCols,nQtdcpo+1] := .F.
	(cAliasQry)->((DbSkip()))
EndDO

(cAliasQry)->(DbCloseArea())

If Len(aCols) == 0
	aCols := {Array(nQtdcpo+1)}
	aCols[1,nQtdcpo+1]:=.F.
	n     := 1
	For i:=1 to nQtdcpo
		aCols[1,i]:=CriaVar(aHeader[i,2])
	Next	
EndIf
Return
 

//Gravar o conteudo dos campos
Static Function Gravar()
	Local lReclock := .t.
    Local nPosFil 	:= aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="ZO_FILIAL"})
    Local nI

    Begin Transaction
        
        //Gravando dados do grid
        dbSelectArea("SZO")
        SZO->(dbSetOrder(1))	
        For nI := 1 To Len(aCols)
            If !(aCols[nI, Len(aHeader)+1])
                If SZO->(dbSeek( aCols[nI,nPosFil]+M->B1_COD +  aCols[nI,2]))
					lReclock := .f.
				Else
					lReclock := .t.
				EndIf

				RecLock("SZO",lReclock)

					//Grava apenas os campos contidos na variavel $cCamposSZO
					SZO->ZO_FILIAL := aCols[nI,1]
					SZO->ZO_PRODUTO := SB1->B1_COD
					SZO->ZO_FAIXA := aCols[nI,2]
					SZO->ZO_MARKUP := aCols[nI,3]

				SZO->(MsUnLock())
                
            Endif
        Next nI
        
    End Transaction
Return

User Function VldFaixa()
Local lRet := .t.
Local cFaixa := M->ZO_FAIXA

SZN->(DbSetOrder(1))
If !SZN->(DbSeek(xFilial('SZN') + cFaixa))
	lRet := .f.
	MsgInfo('Faixa invalida!')
EndIf

Return lRet


User Function vlZOfil()
Local lRet := .t.
Local aSM0  := FWLoadSM0()

If aScan( aSM0, {|x| AllTrim(x[2]) == Alltrim(M->ZO_FILIAL)} ) == 0
	msgInfo('Filial Incorreta!')
	lRet := .f.
EndIf


Return lRet

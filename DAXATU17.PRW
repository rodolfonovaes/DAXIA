#include "PROTHEUS.CH"


/*/{Protheus.doc} DAXATU17
Consulta Serasa Relato
@type  User Function
@author B. Vinicius
@since 19/08/2019
/*/User Function DAXATU17()           

Local nOpc := 0

Private oDlg
Private oCheckBox1
Private lCheckBox1 := .F.
Private oFolder1
Private oFolderPage1
Private oFolderPage2
Private oFolderPage3
Private oFolderPage4
Private oFolderPage5
Private oRadMenu1
Private nRadMenu1 := 1
Private oRadMenu2
Private nRadMenu2 := 1
Private oRadMenu3
Private nRadMenu3 := 1
Private oRadMenu4
Private nRadMenu4 := 1


  DEFINE MSDIALOG oDlg TITLE "Consulta SERASA" FROM 000, 000  TO 500, 900 COLORS 0, 16777215 PIXEL

    @ 040, 017 FOLDER oFolder1 SIZE 401, 182 OF oDlg ITEMS "Resumo de Opções","Opção de Consulta","Tipo de Concentre ( quando selecionado relato + concentre)","Quadro Social e Participações","Incluir Risk Scoring" COLORS 0, 14215660 PIXEL
    
    @ 015, 007 RADIO oRadMenu1 VAR nRadMenu1 ITEMS "Consultar Apenas Relato Completo","Consultar Relato Completo + Concentre Sintético","Consultar Relato Completo + Concentre Detalhado" SIZE 105, 034 OF oFolder1:aDialogs[2] COLOR 0, 16777215 PIXEL
    @ 016, 010 RADIO oRadMenu2 VAR nRadMenu2 ITEMS "Solicitação de S/N para CNPJ","Socilitação de resumo das ocorrências","Solicitação de concentre completo" SIZE 179, 031 OF oFolder1:aDialogs[3] COLOR 0, 16777215 PIXEL
    @ 015, 010 RADIO oRadMenu3 VAR nRadMenu3 ITEMS "Não gerar quadro social e não gerar participações","Gerar quadro social e não gerar participações","Gerar quadro social e gerar participações","Não gerar quadro social e gerar participações" SIZE 172, 061 OF oFolder1:aDialogs[4] COLOR 0, 16777215 PIXEL
    @ 012, 011 CHECKBOX oCheckBox1 VAR lCheckBox1 PROMPT "Incluir Risk Scoring" SIZE 084, 008 OF oFolder1:aDialogs[5] COLORS 0, 16777215 PIXEL
    @ 039, 019 RADIO oRadMenu4 VAR nRadMenu4 ITEMS "RiskScoring 22 Classes - Horizonte de 6 meses","RiskScoring 22 Classes - Horizonte de 12 meses","RiskScoring 3.0 22 Classes - Horizonte de 6 meses","RiskScoring 3.0 22 Classes - Horizonte de 12 meses" SIZE 145, 065 OF oFolder1:aDialogs[5] COLOR 0, 16777215 PIXEL
    @ 039, 019 RADIO oRadMenu4 VAR nRadMenu4 ITEMS "RiskScoring 22 Classes - Horizonte de 6 meses","RiskScoring 22 Classes - Horizonte de 12 meses","RiskScoring 3.0 22 Classes - Horizonte de 6 meses","RiskScoring 3.0 22 Classes - Horizonte de 12 meses" SIZE 145, 065 OF oFolder1:aDialogs[5] COLOR 0, 16777215 PIXEL

    @ 039, 019 RADIO oRadMenu4 VAR nRadMenu4 ITEMS "RiskScoring 22 Classes - Horizonte de 6 meses","RiskScoring 22 Classes - Horizonte de 12 meses","RiskScoring 3.0 22 Classes - Horizonte de 6 meses","RiskScoring 3.0 22 Classes - Horizonte de 12 meses" SIZE 145, 065 OF oFolder1:aDialogs[5] COLOR 0, 16777215 PIXEL

    @ 120, 300 BUTTON oButton1 PROMPT "Confirmar" SIZE 057, 026 OF oFolder1:aDialogs[5]  PIXEL ACTION ( nOpc := 1  , oDlg:End() )


  ACTIVATE MSDIALOG oDlg

  If nOpc == 1 .And. MsgYesNo("Confirma Consulta SERASA?")
        FWMsgRun(, {|| ProcSer() }, "Processando", "Processando a rotina...")
  Endif

Return

Static Function ProcSer()

Local aParam := {}
Local aQuadro := {}
Local oRestClient
Local cTipo := ""
Local cTpConcent  := "" // TIPO CONCENTRE
Local cTipoDoc := "" // TIPO DOCUMENTO

If nRadMenu1 == 1 // Relato Completo
    cTipo := "RELA"
Elseif nRadMenu1 == 2 // Relato Completo + Concentre Sintético
    cTipo := "CONC"
Elseif nRadMenu1 == 3 //Consultar Relato Completo + Concentre Detalhado
    cTipo := "IP2D"
Endif

// OPCAO APENAS PARA CONC E IP2D
If nRadMenu1 == 2 .Or. nRadMenu1 == 3

    If nRadMenu2 == 1  //Solicitação de S/N para CNPJ 
        cTpConcent := "1"
    Elseif nRadMenu2 == 2 //Socilitação de resumo das ocorrências
        cTpConcent := "2"
    Elseif nRadMenu2 == 3 //Solicitação de concentre completo
        cTpConcent := "3"
    Endif

Endif

If nRadMenu3== 1  //Não gerar quadro social e não gerar participações  
    cTipoDoc := "1"
Elseif nRadMenu3 == 2 //Gerar quadro social e não gerar participações
    cTipoDoc := "2"
Elseif nRadMenu3 == 3 //Gera quadro social e gera participações
    cTipoDoc := "3"
Elseif nRadMenu3 == 4 //Não Gera quadro social e gera participações
    cTipoDoc := "4"
Endif

    oRestClient := FWRest():New("https://mqlinuxext.serasa.com.br")
        //oRestClient:setPath("/Homologa/consultahttps?p=86259358123@daxi" + Escape(Space(8)) +  Escape("IP20RELAM2        08226826922N            03") )
 // oRestClient:setPath("/Homologa/consultahttps?p=86259358123@daxi" + Escape(Space(8)) +  Escape("IP20RELAM2        00006396022N            03") )
    //oRestClient:setPath("/Homologa/consultahttps?p=86259358123@daxi" + Escape(Space(8)) +  Escape("IP20RELAM2        0" + Left(SA1->A1_CGC,8) + "22N            03"))
   
    oRestClient:setPath("/Homologa/consultahttps?p=86259358123@daxi" + Escape(Space(8)) +  Escape("IP20" + cTipo + "M3        0" +   Left(SA1->A1_CGC,8) + "22N            0" + cTipoDoc+"3" + cTpConcent ) )
								
//	oRestClient:setPath("/Homologa/consultahttps?p=86259358123@daxia" +  Space(8)))
    //oRestClient:SetPostParams(Escape("IP20RELAS2 000010205N 232E C66M S CFP3"))
	//oRestClient:SetPostParams(Escape("IP20RELAM2        00006396022N            03"))

    If (oRestClient:Post())
		cResponse := oRestClient:getResult()

        cResponse := StrTran(cResponse,"#",CRLF + CRLF)
		lRet := .T.
		//Erro no POST
        // GRAVANDO RETORNO DA CONSULTA
        Reclock("Z02",.T.)
        
        Z02_CODIGO := GetSxeNum("Z02","Z02_CODIGO")
        Z02_FILIAL := FWxFilial("Z02")
        Z02_DATA := dDataBase
        Z02_HORA := Left(Time(),5)
        Z02_USER := UsrRetName(RetCodUsr())
        Z02_CONSUL := StrTran(cResponse,"#",CRLF)
        Z02_CLI := SA1->A1_COD
        Z02_LOJA := SA1->A1_LOJA
        
        Z02->(MsUnLock())

        U_LOGATU17(cResponse)

	Else
			cResponse := oRestClient:getResult()
			cStatus := oRestClient:GetLastError()
            MsgInfo('Consulta com Erro: ' + Alltrim(cResponse))
    Endif

Return


User Function LOGATU17(cMsg, cTitulo, nTipo, lEdit)
Local lRetMens := .F.
Local oDlgMens
Local oBtnOk, cTxtConf := ""
Local oBtnCnc, cTxtCancel := ""
Local oBtnSlv
Local oFntTxt
Local oMsg
Local ABUTTONS := {}

Default cMsg    := ""
Default cTitulo := "Log"
Default nTipo   := 1 //1=Ok; 2= Confirmar e Cancelar
Default lEdit   := .F.

//Definindo os textos dos botões
If(nTipo == 1)
	cTxtConf:='&Ok'
Else
	cTxtConf:='&Confirmar'
	cTxtCancel:='C&ancelar'
EndIf

//Criando a janela centralizada com os botões
DEFINE FONT oFntTxt NAME "MONO AS" SIZE 7,15   //6,15
DEFINE MSDIALOG oDlgMens TITLE cTitulo FROM 0,0  TO 550,1290 PIXEL
@ 5,5 GET oMsg VAR cMsg MEMO SIZE 610,243 OF oDlgMens PIXEL
If !lEdit
	oMsg:lReadOnly := .T.
EndIf

If (nTipo==1)
	@ 255, 080 BUTTON oBtnOk  PROMPT cTxtConf   SIZE 045, 015 ACTION oDlgMens:End() OF oDlgMens PIXEL
ElseIf(nTipo==2)
	@ 192, 240 BUTTON oBtnOk  PROMPT cTxtConf   SIZE 045, 015 ACTION (lRetMens:=.T., oDlgMens:End()) OF oDlgMens PIXEL
	@ 192, 290 BUTTON oBtnCnc PROMPT cTxtCancel SIZE 045, 015 ACTION (lRetMens:=.F., oDlgMens:End()) OF oDlgMens PIXEL
EndIf

oMsg:oFont:= oFntTxt

//Botão de Salvar em Txt
@ 255, 005 BUTTON oBtnSlv PROMPT "&Salvar em .txt" SIZE 045, 015 ACTION (fSalvArq(cMsg, cTitulo)) OF oDlgMens PIXEL
	ACTIVATE MSDIALOG oDlgMens CENTERED //ON INIT EnchoiceBar(oDlg,{|| MsgRun("Gerando Pedido...","",{|| CursorWait(),oDlg:End()}) } ,{||oDlg:End()},,aButtons)

Return lRetMens

//-------------------------------------------------------------------
/*/{Protheus.doc} fSalvArq
Salva arquivo de geração de etiqueta

@param cMSG, character, Texto a ser salvo
@param cSocio, character, Código do Sócio
@param cEnvio, character, Tipo de Envio 1-Correios 2-Retirada

@return True se salvou o arquivo, False se não

@author janaina.jesus
@since 12/03/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function fSalvArq(cMsg, cSocio, cEnvio)
	Local cFileNom := "NSOC.txt"
	Local lOk      := .T.
	 
	cFileNom := cGetFile( "Arquivo TXT *.txt | *.txt", "Arquivo .txt",,'',.T., GETF_LOCALHARD) //--Caminho do arquivo
	 
	If !Empty(cFileNom)
		If ! ExistDir(SubStr(cFileNom,1,RAt('\',cFileNom)))
	    	Alert("Diretório não existe: " + CRLF + SubStr(cFileNom, 1, RAt('\',cFileNom)) + "!")
			Return
		EndIf
	 
		If File(cFileNom) //--Verifico se o arquivo já existe
			lOk := MsgYesNo("Arquivo já existe, deseja substituir?", "Atenção")
		EndIf
		 
		If lOk
			If MemoWrite(cFileNom, cMsg)
				MsgInfo("Arquivo Gerado com Sucesso!")
			Else
				MsgAlert("Não foi possível criar o arquivo no local: "+ CRLF + cFileNom)
			EndIf
		 	
		EndIf
	EndIf
Return
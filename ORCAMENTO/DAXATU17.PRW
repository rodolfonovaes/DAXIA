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
@ 016, 010 RADIO oRadMenu2 VAR nRadMenu2 ITEMS "Solicitação de S/N para CNPJ","Socilitação de resumo das Ocorrencias","Solicitação de concentre completo" SIZE 179, 031 OF oFolder1:aDialogs[3] COLOR 0, 16777215 PIXEL
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
    Local cPassword := Alltrim(SupergetMV('ES_PASSSER',.F.,"D@xia12")) // Senha para utilizar o metodo
    Local cUser :=     Alltrim(SupergetMV('ES_USERSER',.F.,"45616634")) // Usuario para utilizar o metodo
    //Local cPassword := Alltrim(SupergetMV('ES_PASSSER',.F.,"D@xia12")) // Senha para utilizar o metodo
    //Local cUser :=     Alltrim(SupergetMV('ES_USERSER',.F.,"86259358")) // Usuario para utilizar o metodo

    If nRadMenu1 == 1 // Relato Completo
        cTipo := "RELA"
    Elseif nRadMenu1 == 2 // Relato Completo + Concentre Sintético
        cTipo := "CONC"
    Elseif nRadMenu1 == 3 //Consultar Relato Completo + Concentre Detalhado
        cTipo := "IP2D"
    Endif

// OPCAO APENAS PARA CONC E IP2D
    // If nRadMenu1 == 2 .Or. nRadMenu1 == 3

    If nRadMenu2 == 1  //Solicitação de S/N para CNPJ
        cTpConcent := "1"
    Elseif nRadMenu2 == 2 //Socilitação de resumo das Ocorrencias
        cTpConcent := "2"
    Elseif nRadMenu2 == 3 //Solicitação de concentre completo
        cTpConcent := "3"
    Endif

    // Endif

    If nRadMenu3== 1  //Não gerar quadro social e não gerar participações
        cTipoDoc := "0"
    Elseif nRadMenu3 == 2 //Gerar quadro social e não gerar participações
        cTipoDoc := "1"
    Elseif nRadMenu3 == 3 //Gera quadro social e gera participações
        cTipoDoc := "2"
    Elseif nRadMenu3 == 4 //Não Gera quadro social e gera participações
        cTipoDoc := "3"
    Endif

    //oRestClient := FWRest():New("https://mqlinuxext.serasa.com.br")
    oRestClient := FWRest():New("https://sitenet43.serasa.com.br")
    oRestClient:setPath("/Prod/consultahttps?p=" +  cUser + cPassword + Escape(Space(8)) +  Escape("IP20" + cTipo + "S2        0" +   Left(SA1->A1_CGC,8) + "22N            " + cTipoDoc + "3" + cTpConcent + Space(1) + Space(84) + Space(4) + Space(255) + Space(1) + Space(53) + Space(4) ) )
    //oRestClient:setPath("/Prod/consultahttps?p=" +  cUser + cPassword + Escape(Space(9)) +  Escape("IP20" + cTipo + "S2        0" +   Left(SA1->A1_CGC,8) + "22N            " + cTipoDoc + "3" + cTpConcent + "E" + Space(84) + "C66M" + Space(255) + "S" + Space(53) + "CPF3" ) )
    //oRestClient:setPath("/Homologa/consultahttps?p=" +  cUser + cPassword + Escape(Space(9)) +  Escape("IP20" + cTipo + "M3        0" +   Left(SA1->A1_CGC,8) + "22N            0" + cTipoDoc+"3" + cTpConcent ) )
    //consultahttps?p=LLLLLLLLSSSSSSSS        IP20RELAS2        00423692022N            232E                                                                                    C66M                                                                                                                                                                                                                                                               S                                                     CFP3

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

    cMSG := FormatSer(cMSG)

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


/*User Function CHKEXEC()

    IF alltrim(UsrRetName(RetCodUsr())) == "totvs.bsilva"

        Z02->(dbGoTo(150))
        U_LOGATU17(Z02->Z02_CONSUL)

    Endif

Return*/

Static Function FormatSer(cTexto)

    Local cFundacao := "FUNDACAO: "
    Local aAux := {}
    Local cRamoAtiv := "RAMO DE ATIVIDADE: "
    Local cCnpj := "CNPJ: "
    Local cNire := "NIRE: "
    Local cRazao := ""
    Local cFantasia := "NOME FANTASIA: "
    Local cTipoSocie := "TIPO DE SOCIEDADE: "
    Local cOpcTrib := "OPCAO TRIBUTARIA: "
    Local cEndereco := ""
    Local cBairro := ""
    Local cDDD := "DDD: "
    Local cMunEst := ""
    Local cCnae := "CNAE: "
    Local nVlrSocial := 0
    Local nVlrRealiz := 0
    Local cOrigem := ""
    Local cControle := ""
    Local cNatureza := ""
    Local aCGCSoc := {}
    Local aAcionNome := {}
    Local aCapTotSoc := {}
    Local aCapVotSoc := {}
    Local aAdmCGC := {}
    Local aAdmNome := {}
    Local aAdmEstCiv := {}
    Local cAux := ""
    Local dUltAtuSoc := "" // Ultima atualizacao controle societario
    Local dUltAdm := "" //Ultima atualizacao adminstrativo
    Local cSituacao := ""
    Local aConsultas := {}
    Local nX := 0
    Local aUltConsul := {}
    Local aPefinData := {}
    Local aModalidade := {}
    Local aAvalista := {}
    Local aValPefin := {}
    Local aContPefin := {}
    Local aOrigPefin := {}
    Local aModPefin := {}
    Local nTotPefin := 0
    Local aDatRefin := {}
    Local aModRefin := {}
    Local aAvaRefin := {}
    Local aContRefin := {}
    Local aOrigRefin := {}
    Local aValRefin := {}
    Local nTotRefin  := 0
    Local aQtdJudicial := {}
    Local aPerJudic := {}
    Local aDescJudic := {}
    Local aOrigJudic := {}
    Local aPracaJudic := {}
    Local aValJudic := {}
    Local aDataAcao := {}
    Local aNatAcao := {}
    Local aaValAcao := {}
    Local aValAcao := {}
    Local aDistAcao := {}
    Local aVaraAcao := {}
    Local aCidUFAcao := {}
    Local aDatProt := {}
    Local aValProt := {}
    Local aCartorio := {}
    Local aCidCart := {}
    Local cCapitSoc := "CAPITAL SOCIAL : "
    Local aDataCheque := {}
    Local aBcoCheque := {}
    Local aAgeCheque := {}
    Local aCtaCheque := {}
    Local aChqIni := {}
    Local aChqFim := {}
    Local aChqMot := {}
    Local cRegistro := ""
    Local cDtRegist := ""
    Local cInscr := ""
    Local cTelefone := ""
    Local cQtdFil := ""
    Local aDivVencDt := {}
    Local aDivVencMod := {}
    Local aDivVencVlr := {}
    Local aDivVencTit := {}
    Local aDivVencInst := {}
    Local aDivVencLoc := {}
    Local aDataFali := {}
    Local aDescFali := {}
    Local aOriFali := {}
    Local aCidFali := {}
    Local cQtdRefin := ""
    Local cQtdPefin := ""
    Local cQtdVenc := ""
    Local cQtdFalenc := ""
    Local cQtdAcao := ""
    Local cQtdProt := ""
    Local cQtdReChq := ""
    Local cVlrRefin := ""
    Local cVlrPefin := ""
    Local cVlrVenc := ""
    Local cVlrAcaoJd := ""
    Local cVlrProt := ""
    Local aAntecessoras := {}
    Local aEntSocie := {}
    Local aEntAdm := {}
    Local cCep := ""
    Local aCargoADM := {}
    Local aMandtoADM := {}

    aAux := Separa(cTexto,CRLF)

    //Buscando valores

    For nX := 1 To Len(aAux)

        //Situacao do CNPJ
        If Substr(aAux[nX],2,6) == "010000"
            cSituacao := Substr(aAux[nX],156,50)
        Endif

        // Data de fundacao
        If Substr(aAux[nX],2,6) == "010105"
            cFundacao += " " + Dtoc( Stod( SubStr(aAux[nX] , 8 , 8 )))
        Endif

        //Ramo de atividade
        If Substr(aAux[nX],2,6) == "010105"
            cRamoAtiv +=  Alltrim(Substr(aAux[nX],24,54))
        Endif

        //CNPJ da Empresa
        If Substr(aAux[nX],2,6) == "010101"
            cCnpj +=  Substr(aAux[nX],92,18)
        Endif

        //NIRE
        If Substr(aAux[nX],2,6) == "010102"
            cNire +=  Transform(Substr(aAux[nX],147,11),"@R 99.999.999.999")
        Endif

        //Opcao Tributaria
        If Substr(aAux[nX],2,6) == "010102"
            cOpcTrib +=  Substr(aAux[nX],218,30)
        Endif

        //Registro
        If Substr(aAux[nX],2,6) == "010101"
            cRegistro += Substr(aAux[nX],119,11)
        Endif

        //Data Registro
        If Substr(aAux[nX],2,6) == "010101"
            cDtRegist += Dtoc( Stod( Substr( aAux[nX],130,8)))
        Endif


        //Razao Social
        If Substr(aAux[nX],2,6) == "010102"
            cRazao += Alltrim(Substr(aAux[nX],8,70))
        Endif

        //Nome Fantasia
        If Substr(aAux[nX],2,6) == "010102"
            cFantasia += Alltrim(Substr(aAux[nX],87,60))
        Endif

        //Tipo de Sociedade
        If Substr(aAux[nX],2,6) == "010102"
            cTipoSocie += Alltrim(Substr(aAux[nX],158,60))
        Endif

        //Opcao Tributaria
            /*If Substr(aAux[nX],2,6) == "010102"
                cTipoSocie += Alltrim(Substr(aAux[nX],158,60))
    Endif*/
            
            //Endereço
    If Substr(aAux[nX],2,6) == "010103"
                cEndereco += Alltrim(Substr(aAux[nX],108,80))
    Endif

            //Bairro
    If Substr(aAux[nX],2,6) == "010103"
                cBairro += Alltrim(Substr(aAux[nX],78,30))
    Endif

            //Municipio / Estado
    If Substr(aAux[nX],2,6) == "010104"
                cMunEst += Alltrim(Substr(aAux[nX],8,30)) + " - " + Alltrim(Substr(aAux[nX],38,2))
    Endif

            //DDD
    If Substr(aAux[nX],2,6) == "010104"
                cTelefone += Alltrim(Substr(aAux[nX],50,12))
    Endif

        //CEP
    If Substr(aAux[nX],2,6) == "010104"
                cCep += Alltrim(Substr(aAux[nX],40,8))
    Endif

    If  Substr(aAux[nX],2,6)  == "571001"
        If Empty(cInscr)
                cInscr += cValToChar(Val(Substr(aAux[nX],8,15)))
        Endif
    Endif
        
        //Quantidade filiais
    If  Substr(aAux[nX],2,6)  == "010105"
              cQtdFil += cValToChar(Val(Substr(aAux[nX],99,6)))
    Endif
        
        // Antecessoras
    If  Substr(aAux[nX],2,6)  == "010116"
            aAdd( aAntecessoras , { Alltrim(Substr(aAux[nX],8,70)) , "   ate " + Dtoc(Stod(Substr(aAux[nX],79,8))) })
    Endif

            //Cnae
    If Substr(aAux[nX],2,6) == "010105"
                cCnae += Alltrim(Substr(aAux[nX],105,7))
    Endif

            //Valor do capital Social
    If Substr(aAux[nX],2,6) == "010108"
                nVlrSocial := Val(Substr(aAux[nX],16,13))
    Endif

            //Valor do capital Social
    If Substr(aAux[nX],2,6) == "010108"
                nVlrRealiz := Val(Substr(aAux[nX],29,13))
    Endif

        //Origem
    If Substr(aAux[nX],2,6) == "010108"
                cOrigem += Substr(aAux[nX],55,12)
    Endif

            //Controle
    If Substr(aAux[nX],2,6) == "010108"
                cControle += Substr(aAux[nX],67,12)
    Endif

            //Natureza
    If Substr(aAux[nX],2,6) == "010108"
                cNatureza += Substr(aAux[nX],79,12)
    Endif

        //Controle societario ultima atualizacao
    If Substr(aAux[nX],2,6) == "010108"
            dUltAtuSoc += Dtoc( Stod( Substr( aAux[nX],8,8)))
    Endif
            
        //Controle Societario CNPJ/CPF
    If Substr(aAux[nX],2,6) == "010109"
                aAdd(aCGCSoc,Substr(aAux[nX],9,9) + Iif( Substr(aAux[nX],8,1)  == "F", Substr(aAux[nX],22,2) , '' ))
    Endif

        //Controle Societario CNPJ/CPF
    If Substr(aAux[nX],2,6) == "010109"
                aAdd(aEntSocie, Dtoc(Stod(Substr(aAux[nX],105,8))))
    Endif

            //Controle Societario CNPJ/CPF
    If Substr(aAux[nX],2,6) == "010109"
                aAdd(aAcionNome,Alltrim(Substr(aAux[nX],24,65)))
    Endif

            //Controle Societario Capital Votante
    If Substr(aAux[nX],2,6) == "010109"
                aAdd(aCapVotSoc,cValToChar(Val(Substr(aAux[nX],114,04))))
    Endif

            //Controle Societario Capital total
    If Substr(aAux[nX],2,6) == "010109"
                aAdd(aCapTotSoc,cValToChar(Val(Substr(aAux[nX],101,04))))
    Endif

        //Controle Administrativo CNPJ/CPF            
    If Substr(aAux[nX],2,6) == "010111"
                aAdd(aAdmCGC,Alltrim(Substr(aAux[nX],9,9))  + Iif( Substr(aAux[nX],8,1)  == "F", Substr(aAux[nX],22,2) , '' ))
    Endif

    //Controle Administrativo Cargo
    If Substr(aAux[nX],2,6) == "010111"
            aAdd(aCargoADM,  Substr(aAux[nX],82,8))
    Endif

    //Controle Administrativo Mandato
    If Substr(aAux[nX],2,6) == "010111"
            aAdd(aMandtoADM, Iif( Substr(aAux[nX],123,8) == "99999999" , "INDET.", Dtoc( Stod( Substr( aAux[nX],8,8 )))))
    Endif

        //Entrada  
    If Substr(aAux[nX],2,6) == "010111"
                aAdd(aEntAdm, Substr(aAux[nX],119,2) + "/" + Substr(aAux[nX],115,4 ))
    Endif
            //Controle Administrativo Nome
    If Substr(aAux[nX],2,6) == "010111"
                aAdd(aAdmNome,Alltrim(Substr(aAux[nX],24,58)))
    Endif

            //Controle Administrativo Estado Civil
    If Substr(aAux[nX],2,6) == "010111"
                aAdd(aAdmEstCiv,Alltrim(Substr(aAux[nX],106,09)))
    Endif

        //Data ultima ADMINISTRACAO administrativo
    If Substr(aAux[nX],2,6) == "010110"
                dUltAdm := Dtoc( Stod( Substr( aAux[nX],8,8)))
    Endif

           /*  //Controle Administrativo Entrada Mandato
    If Substr(aAux[nX],2,6) == "010111"
                aAdd(aAdmEstCiv,Alltrim(Substr(aAux[nX],106,09)))
    Endif  */

        //Consultas realizadas
        /*
    If Substr(aAux[nX],2,6)== "030101"
            aAdd( aConsultas,{  "Ano/Mes " + Substr(aAux[nX],12,3) + "/" + Substr(aAux[nX],8,2) ,;
                                " Qtd por empresa " +  Substr( aAux[nX],15,3),;
                                 " Qtd por organizações bancarias " + Substr(aAux[nX],18,3)    })
    Endif */

        // Ultimas 5 consultas de clientes para aquele CNPJ

    If Substr(aAux[nX],2,6)== "030102"
            aAdd( aUltConsul,{   Substr(aAux[nX],16,35) ,;
                                " Data " + Dtoc( Stod( Substr(aAux[nX],8,8))) ,;
                                 " Qtd " + Substr(aAux[nX],51,4)    })
    Endif

        //Data Pefin
    If Substr(aAux[nX],2,6)== "040101"
            aAdd( aPefinData,  Dtoc( Stod( Substr(aAux[nX],26,8)))  )
    Endif
        
        //Quantidade pefin 
    If Substr(aAux[nX],2,6)== "040101"
        If Empty(cQtdPefin)
                cQtdPefin :=  cValToChar(Val(Substr(aAux[nX],8,9)))
        Endif
    Endif

        //Valor Pefin
    If Substr(aAux[nX],2,6)== "040101"
        If Empty(cVlrPefin)
                cVlrPefin :=  Alltrim( Transform( Val(Substr(aAux[nX],235,13)) , PesqPict("SE1","E1_VALOR")) )  
        Endif
    Endif

        // Modalidade
    If Substr(aAux[nX],2,6)== "040101"
            aAdd( aModPefin,  Substr(aAux[nX],34,12) )
    Endif

         // Avalista
    If Substr(aAux[nX],2,6)== "040101"
            aAdd( aAvalista,  IIf(Substr(aAux[nX],46,1)=="N",'Não','Sim')  )
    Endif

        // Avalista
    If Substr(aAux[nX],2,6)== "040101"
            aAdd( aValPefin,  Alltrim( Transform( Val(Substr(aAux[nX],47,13)) , PesqPict("SE1","E1_VALOR")) )  )
            nTotPefin += Val(Substr(aAux[nX],47,13))
    Endif

         // Contrato
    If Substr(aAux[nX],2,6)== "040101"
            aAdd( aContPefin,  Substr(aAux[nX],60,13) )
    Endif

           // Origem
    If Substr(aAux[nX],2,6)== "040101"
            aAdd( aOrigPefin, Substr(aAux[nX],76,20 ) )
    Endif

         // Data Refin
    If Substr(aAux[nX],2,6)== "040102"
            aAdd( aDatRefin, Dtoc( Stod( Substr(aAux[nX],26,8)))  )
    Endif

    If Substr(aAux[nX],2,6)== "040102"
        If Empty(cQtdRefin)
                cQtdRefin :=  cValToChar(Val(Substr(aAux[nX],8,9)))
        Endif
    Endif

        //Valor Refin
    If Substr(aAux[nX],2,6)== "040102"
        If Empty(cVlrRefin)
                cVlrRefin :=  Alltrim( Transform( Val(Substr(aAux[nX],235,13)) , PesqPict("SE1","E1_VALOR")) )  
        Endif
    Endif


         // Modalidade Refin
    If Substr(aAux[nX],2,6)== "040102"
            aAdd( aModRefin, Substr(aAux[nX],34,12)  )
    Endif

         // Avalista Refin
    If Substr(aAux[nX],2,6)== "040102"
            aAdd( aAvaRefin,  IIf(Substr(aAux[nX],46,1)=="N",'Não','Sim')  )
    Endif

          // Contrato  Refin
    If Substr(aAux[nX],2,6)== "040102"
            aAdd( aContRefin,  Substr(aAux[nX],60,13)  )
    Endif

           // Origem  Refin
    If Substr(aAux[nX],2,6)== "040102"
            aAdd( aOrigRefin,  Substr(aAux[nX],76,20)  )
    Endif

         // Avalista
    If Substr(aAux[nX],2,6)== "040102"
            aAdd( aValRefin,  Alltrim( Transform( Val(Substr(aAux[nX],47,13)) , PesqPict("SE1","E1_VALOR")) )  )
            nTotRefin += Val(Substr(aAux[nX],47,13))
    Endif

        
         // Quantidade Judicial
    If Substr(aAux[nX],2,6)== "040202"
            aAdd( aQtdJudicial, StrZero(Val(Substr(aAux[nX],8,9)),3))  
    Endif

        //Valor Protesto
    If Substr(aAux[nX],2,6)== "040202" .And. Substr(aAux[nX],17,8) == "PROTESTO" .And. Empty(cVlrProt)
             cVlrProt :=  Alltrim( Transform( Val(Substr(aAux[nX],98,13)) , PesqPict("SE1","E1_VALOR")) )
    Endif

    If Substr(aAux[nX],2,6)== "040202" .And. Substr(aAux[nX],17,14) == "DIVIDA VENCIDA" .And. Empty(cVlrVenc)
             cVlrVenc :=  Alltrim( Transform( Val(Substr(aAux[nX],98,13)) , PesqPict("SE1","E1_VALOR")) )
    Endif

          // Descrição Judicial
    If Substr(aAux[nX],2,6)== "040202"
            aAdd( aDescJudic, Substr(aAux[nX],17,20))       
    Endif
      
          // Periodo Judicial
    If Substr(aAux[nX],2,6)== "040202"
            aAdd( aPerJudic, Substr(aAux[nX],44,3) + "/" + Substr(aAux[nX],49,2) + " - " + Substr(aAux[nX],51,3) + "/" + Substr(aAux[nX],56,2) )       
    Endif

        //Valor Judicial
    If Substr(aAux[nX],2,6)== "040202"
          aAdd( aValJudic,  Alltrim( Transform( Val(Substr(aAux[nX],61,13)) , PesqPict("SE1","E1_VALOR")) )  )
    Endif
       
        //Origem Judicial
    If Substr(aAux[nX],2,6)== "040202"
          aAdd( aOrigJudic,  Substr(aAux[nX],74,20) )
    Endif

         //Praça Judicial
    If Substr(aAux[nX],2,6)== "040202"
          aAdd( aPracaJudic,  Substr(aAux[nX],94,3) )
    Endif
        
        //Quantidade
    If Substr(aAux[nX],2,6)== "040401"
        If Empty(cQtdAcao)
                cQtdAcao :=  cValToChar(Val(Substr(aAux[nX],8,9)))
        Endif
    Endif

        
         //Valor Acao
    If Substr(aAux[nX],2,6)== "040202" .And. Substr(aAux[nX],17,13) == "ACAO JUDICIAL" .And. Empty(cVlrAcaoJd)
             cVlrAcaoJd :=  Alltrim( Transform( Val(Substr(aAux[nX],98,13)) , PesqPict("SE1","E1_VALOR")) )
    Endif



        //Data Acao Judicial
    If Substr(aAux[nX],2,6)== "040401"
          aAdd( aDataAcao,  Dtoc( Stod( Substr(aAux[nX],17,8)))  )
    Endif


        //Natureza da ação
    If Substr(aAux[nX],2,6)== "040401"
          aAdd( aNatAcao,  Substr(aAux[nX],25,20) )
    Endif

        //Valor
    If Substr(aAux[nX],2,6)== "040401"
          aAdd( aValAcao, Alltrim( Transform( Val(Substr(aAux[nX],49,13)) , PesqPict("SE1","E1_VALOR"))))
    Endif
        
        //Distrito
    If Substr(aAux[nX],2,6)== "040401"
          aAdd( aDistAcao, Substr(aAux[nX],62,2) )
    Endif

        //Vara Civil
    If Substr(aAux[nX],2,6)== "040401"
          aAdd( aVaraAcao, Substr(aAux[nX],64,4) )
    Endif

        
        //Vara Civil
    If Substr(aAux[nX],2,6)== "040401"
          aAdd( aCidUFAcao, Substr(aAux[nX],68,30) )
    Endif
        
          //Quantidade
    If Substr(aAux[nX],2,6)== "040301"
        If Empty(cQtdProt)
                cQtdProt :=  cValToChar(Val(Substr(aAux[nX],8,9)))
        Endif
    Endif

        //Data Protesto
    If Substr(aAux[nX],2,6)== "040301"
             aAdd( aDatProt, Dtoc( Stod( Substr(aAux[nX],17,8)))  )
    Endif

        //Valor Protesto
    If Substr(aAux[nX],2,6)== "040301"
             aAdd( aValProt, Alltrim( Transform( Val(Substr(aAux[nX],28,13)) , PesqPict("SE1","E1_VALOR"))))
    Endif

         //Cartorio
    If Substr(aAux[nX],2,6)== "040301"
             aAdd( aCartorio , Substr(aAux[nX],41,2))
    Endif

         // Cidade / UF Cartorio
    If Substr(aAux[nX],2,6)== "040301"
             aAdd( aCidCart , Substr(aAux[nX],43,30))
    Endif
        
           //Quantidade
    If Substr(aAux[nX],2,6)== "041001"
        If Empty(cQtdReChq)
                cQtdReChq :=  cValToChar(Val(Substr(aAux[nX],8,9)))
        Endif
    Endif

        //Data Re-Cheque
    If Substr(aAux[nX],2,6) == "041001"
            aAdd( aDataCheque , Dtoc( Stod( Substr(aAux[nX],8,8))) ) 
    Endif

        //Banco
    If Substr(aAux[nX],2,6) == "041001"
            aAdd( aBcoCheque ,  Substr(aAux[nX],16,16) )
    Endif

        //Agencia Cheque
    If Substr(aAux[nX],2,6) == "041001"
            aAdd( aAgeCheque ,  Substr(aAux[nX],32,4) )
    Endif

        //Conta Cheque
    If Substr(aAux[nX],2,6) == "041001"
            aAdd( aCtaCheque , Substr(aAux[nX],37,6))
    Endif

        //Cheque Inicial
    If Substr(aAux[nX],2,6) == "041001"
            aAdd( aChqIni , Substr(aAux[nX],43,6))
    Endif

        //Cheque Final
    If Substr(aAux[nX],2,6) == "041001"
            aAdd( aChqFim , Substr(aAux[nX],49,6))
    Endif

        //Motivo
    If Substr(aAux[nX],2,6) == "041001"
            aAdd( aChqMot , Substr(aAux[nX],55,10))
    Endif

        //Dividas Vencidas Data
    If Substr(aAux[nX],2,6) == "040701"
            aAdd( aDivVencDt , Dtoc( Stod( Substr(aAux[nX],17,8))))
    Endif

         //Valor Dias Vencidos 
    If Substr(aAux[nX],2,6)== "040701"
        If Empty(cVlrVenc)
                cVlrVenc :=  Alltrim( Transform( Val(Substr(aAux[nX],235,13)) , PesqPict("SE1","E1_VALOR")) )
        Endif
    Endif

        //Quantidade dividas vencidas
    If Substr(aAux[nX],2,6) == "040701"
        If Empty(cQtdVenc)
                cQtdVenc :=  cValToChar(Val(Substr(aAux[nX],8,9)))
        Endif

    Endif

        // Dividas Vencidas Modalidade
    If Substr(aAux[nX],2,6) == "040701"
            aAdd( aDivVencMod ,  Substr(aAux[nX],25,15))
    Endif

          // Dividas Vencidas Valor
    If Substr(aAux[nX],2,6) == "040701"
            aAdd( aDivVencVlr ,  Alltrim( Transform( Val(Substr(aAux[nX],43,13)) , PesqPict("SE1","E1_VALOR"))))
    Endif

         // Dividas Vencidas Titulo
    If Substr(aAux[nX],2,6) == "040701"
            aAdd( aDivVencTit , Substr(aAux[nX],56,15))
    Endif

          // Dividas Vencidas Instituicao cobradora
    If Substr(aAux[nX],2,6) == "040701"
            aAdd( aDivVencInst , Substr(aAux[nX],71,15))
    Endif

           // Dividas Vencidas Local
    If Substr(aAux[nX],2,6) == "040701"
            aAdd( aDivVencLoc , Substr(aAux[nX],86,3)) 
    Endif

        //Data Falencia 
    If Substr(aAux[nX],2,6) == "040601"
            aAdd( aDataFali , Dtoc( Stod( Substr(aAux[nX],17,8))))
    Endif

        //Quantidade Falencia
    If Substr(aAux[nX],2,6) == "040601"
        If Empty(cQtdFalenc)
                cQtdFalenc :=  cValToChar(Val(Substr(aAux[nX],8,9)))
        Endif
    Endif


         //Descricao Falencia 
    If Substr(aAux[nX],2,6) == "040601"
            aAdd( aDescFali , Substr(aAux[nX],25,20))
    Endif

          //Origem Falencia 
    If Substr(aAux[nX],2,6) == "040601"
            aAdd( aOriFali ,  Substr(aAux[nX],46,8))
    Endif

        //Cidade Falencia 
    If Substr(aAux[nX],2,6) == "040601"
            aAdd( aCidFali ,  Substr(aAux[nX],54,30))
    Endif

Next

        // FORMATANDO OS TEXTOS

        cAux += Alltrim(cSituacao) + " - " + cCnpj + CRLF
        cAux += CRLF

        cAux += "IDENTIFICACAO / LOCALIZACAO  " + CRLF
        cAux += CRLF

        cAux += cCnpj + " " + cNire  + " - Registro: " + cRegistro  + ' Data Registro: ' + cDtRegist + " Inscricao Estadual: " + cInscr
        cAux += CRLF
        cAux += CRLF
       
        cAux += cRazao + CRLF
        cAux += CRLF
       
        cAux += cFantasia + CRLF
        cAux += CRLF
        
        cAux += cTipoSocie + CRLF
        cAux += CRLF

If Len(aAntecessoras) > 0
            cAux += "Antecessoras" 
            cAux += CRLF
            cAux += CRLF
    For nX := 1 To Len(aAntecessoras)
                cAux += aAntecessoras[nX][1] + " - " + aAntecessoras[nX][2]
                cAux += CRLF
                cAux += CRLF
    Next
Endif
       
       
        cAux += cOpcTrib + CRLF
        cAux += CRLF
        cAux += CRLF

        cAux += "Endereco: "
       // cAux += CRLF

        cAux += cEndereco + " - " + cBairro + " - " + cMunEst + " - " + cCep +  CRLF
        cAux += CRLF
       
        cAux += "Telefone: (" + Left(cTelefone,3) + ") " +  Substr(cTelefone,4) 
        cAux += CRLF
        cAux += CRLF
        cAux += cFundacao + CRLF
        cAux += CRLF
        
        cAux += cRamoAtiv + CRLF
        cAux += CRLF
        
        cAux += cCnae + CRLF
        cAux += CRLF
        cAux += CRLF

       cAux += "Consulta Filiais: " + cQtdFil
        
        cAux += CRLF
        cAux += CRLF 

        cAux += "CONTROLE SOCIETARIO (ATULIZACAO EM " + dUltAtuSoc + " ) ( VALORES EM R$ ) " + CRLF
        cAux += CRLF

        cAux+= cCapitSoc + " " +  Alltrim(Transform(nVlrSocial,PesqPict("SE1","E1_VALOR"))) 
        cAux+= "  CAPITAL REALIZADO: " + Alltrim(Transform(nVlrRealiz,PesqPict("SE1","E1_VALOR")))  

        cAux += CRLF
        cAux += CRLF

        cAux+= "ORIGEM: " + Alltrim(cOrigem) + " - " + "CONTROLE: " + cControle + " - " + " NATUREZA:" + cNatureza

        cAux+= CRLF
        cAux+= CRLF
         
For nX := 1 To Len(aCGCSoc)
            cAux += "CPF / CNPJ: " + aCGCSoc[nX] +;
                    " ACIONISTA / SOCIO: " + aAcionNome[nX] +;
                    " ENTRADA " + aEntSocie[nX] + ;
                    " CAP.VOTANTE % " + Iif(Val(aCapVotSoc[nX]) > 1000, "100",  Left(aCapVotSoc[nX],2) ) + ;
                    " CAP.TOTAL % " + Iif(Val(aCapTotSoc[nX]) > 1000 , "100",  Left(aCapTotSoc[nX],2) ) 

                    cAux += CRLF
                    cAux += CRLF
Next
       
        cAux += CRLF
        cAux += CRLF

        cAux += "ADMINISTRACAO (ATUALIZACAO EM " + dUltAdm + " )  " + CRLF
        cAux += CRLF

For nX := 1 To Len(aAdmCGC)
            cAux += "CNPJ: " + aAdmCGC[nX] +;
                    " ADMINISTRACAO: " + aAdmNome[nX] +;
                    " ESTADO CIVIL: " + aAdmEstCiv[nX] + ;
                    " ENTRADA: " + aEntAdm[nX] + ;
                    " CARGO: " + aCargoADM[nX] +  ;
                    " MANDATO: " + aMandtoADM[nX]
                    //" MANDATO "

                    cAux += CRLF
                    cAux += CRLF
Next
        
        cAux += CRLF
        cAux += CRLF

For nX := 1 To Len(aConsultas)
        cAux += aConsultas[nX][1] + " - " + aConsultas[nX][2] + " - " + aConsultas[nX][3]
        cAux += CRLF
        cAux += CRLF
Next

    cAux += "Cinco Ultimas Consultas"

    cAux += CRLF
    cAux += CRLF

For nX := 1 To Len(aUltConsul)
        cAux += aUltConsul[nX][1] + " - " + aUltConsul[nX][2] + " - " + aUltConsul[nX][3]
        cAux += CRLF
        cAux += CRLF
Next

    
    cAux += CRLF
    cAux += CRLF
    cAux += "Informações Sobre Anotações Negativas"
    cAux += CRLF
    cAux += CRLF

    cAux += "RESUMO"
    cAux += CRLF
    cAux += CRLF

For nX := 1 To  Len(aDescJudic)

        cAux += "Qtd: " + aQtdJudicial[nX] 
        cAux += "  Discriminacao: " + aDescJudic[nX]
        cAux += "  Periodo: " + aPerJudic[nX] 
        cAux += "  Valor: " + aValJudic[nX] 
        cAux += "  Origem: " + aOrigJudic[nX] 

        cAux += CRLF
        cAux += CRLF

Next
    

    cAux += "PEFIN"
    cAux += CRLF
    cAux += CRLF

If Len(aPefinData) > 0

    For nX := 1 To Len(aPefinData)
      
        cAux += "Data: " + aPefinData[nX] 
        cAux += " Modalidade: " + aModPefin[nX]
        cAux += " Avalista: " + aAvalista[nX] 
        cAux += " Valor: " + aValPefin[nX] 
        cAux += " Origem: " + aOrigPefin[nX] 

        cAux += CRLF
        cAux += CRLF

    Next

    cAux += "Total PEFIN: " + cVlrPefin + CRLF 
    cAux += CRLF
    cAux += "Total de Ocorrencias: " + cQtdPefin
    cAux += CRLF
    cAux += CRLF

Else
        
        cAux += "NADA CONSTA PARA O CNPJ CONSULTADO"
        cAux += CRLF
        cAux += CRLF

Endif

    cAux += CRLF
    cAux += CRLF
    cAux += "REFIN"
    cAux += CRLF
    cAux += CRLF

If Len(aDatRefin) > 0


    For nX := 1 To Len(aDatRefin)
      
        cAux += "Data: " + aDatRefin[nX] 
        cAux += " Modalidade: " + aModRefin[nX]
        cAux += " Avalista: " + aAvaRefin[nX] 
        cAux += " Valor: " + aValRefin[nX] 
        cAux += " Origem: " + aOrigRefin[nX] 

        cAux += CRLF
        cAux += CRLF

    Next

    
        cAux += "Total REFIN: " + cVlrRefin  + CRLF 
        cAux += CRLF
        cAux += "Total de Ocorrencias: " + cQtdRefin
        cAux += CRLF
        cAux += CRLF

    
Else

        cAux += "NADA CONSTA PARA O CNPJ CONSULTADO"
        cAux += CRLF
        cAux += CRLF
        
Endif

    cAux += "ACOES JUDICIAIS"
    cAux += CRLF
    cAux += CRLF

If Len(aDataAcao) > 0

    For nX := 1 To  Len(aDataAcao)
       
        cAux += "Data: " + aDataAcao[nX]
        cAux += "  Natureza: " + aNatAcao[nX]
        cAux += "  Valor:  " + aValAcao[nX]
        cAux += "  Distrito: " + aDistAcao[nX]
        cAux += "  Vara: " + aVaraAcao[nX]
        cAux += "  Cidade / UF " + aCidUFAcao[nX]

        cAux += CRLF
        cAux += CRLF

    Next

          cAux += "Total de Ocorrencias " + cQtdAcao 
          cAux += CRLF
          cAux += CRLF
          cAux += "Total Acoes Judicias: " + cVlrAcaoJd
          cAux += CRLF
          cAux += CRLF

Else

        cAux += "NADA CONSTA PARA O CNPJ CONSULTADO"
        cAux += CRLF
        cAux += CRLF

Endif

    cAux += "PROTESTOS"
    cAux += CRLF
    cAux += CRLF

If Len(aCartorio) > 0

    For nX := 1 To  Len(aCartorio)
     
        cAux += "Data: " + aDatProt[nX]
        cAux += "  Valor: " + aValProt[nX]
        cAux += "  Cartorio: " + aCartorio[nX]
        cAux += "  Cidade / UF : " + aCidCart[nX]

        cAux += CRLF
        cAux += CRLF

    Next

          cAux += "Total de Ocorrencias " + cQtdProt
          cAux += CRLF
          cAux += CRLF
          cAux += "Total Protestos " + cVlrProt
          cAux += CRLF
          cAux += CRLF

Else

        cAux += "NADA CONSTA PARA O CNPJ CONSULTADO"
        cAux += CRLF
        cAux += CRLF

Endif

    cAux += CRLF
    cAux += CRLF    

    cAux += "RECHEQUE"

    cAux += CRLF
    cAux += CRLF

If Len(aChqMot) > 0
    
    For nX := 1 To Len(aChqMot)

        cAux += "Data: " + aDataCheque[nX]
        cAux += "  Banco: " + aBcoCheque[nX]
        cAux += "  Agencia: " + aAgeCheque[nX]
        cAux += "  Conta: " + aCtaCheque[nX]
        cAux += "  Cheque Inicial: " + aChqIni[nX]
        cAux += "  Cheque Final: " + aChqFim[nX]
        cAux += "  Motivo: " + aChqMot[nX]

        cAux += CRLF
        cAux += CRLF

    Next

    cAux += "Total de Ocorrencias " + cQtdReChq

    cAux += CRLF
    cAux += CRLF
    
Else

        cAux += "NADA CONSTA PARA O CNPJ CONSULTADO"
        cAux += CRLF
        cAux += CRLF
Endif

    cAux += "Dividas vencidas"
    
    cAux += CRLF
    cAux += CRLF
If Len(aDivVencLoc) > 0

    For nX := 1 To Len(aDivVencInst)

        cAux += "Data: " + aDivVencDt[nX]
        cAux += "  Modalidade: " + aDivVencMod[nX]
        cAux += "  Valor: " + aDivVencVlr[nX]
        cAux += "  Titulo: " + aDivVencTit[nX]
        cAux += "  Insituicao Cobradora: " + aDivVencInst[nX]
        cAux += "   Local: " + aDivVencLoc[nX]

        cAux += CRLF
        cAux += CRLF

    Next

          cAux += "Total de Ocorrencias " + cQtdVenc
          cAux += CRLF
          cAux += CRLF
          cAux += "Total dividas vencidas " + cVlrVenc
          cAux += CRLF
          cAux += CRLF
        
Else

        cAux += "NADA CONSTA PARA O CNPJ CONSULTADO"
        cAux += CRLF
        cAux += CRLF


Endif

    cAux += "FALENCIA / REC. JUDICIAL"
    cAux += CRLF
    cAux += CRLF
    
If Len(aDataFali) > 0
            
    For nX := 1 To Len(aDataFali)

        cAux += "Data: " + aDataFali[nX]
        cAux += "  Tipo: " + aDescFali[nX]
        cAux += "  Origem: " + aOriFali[nX]
        cAux += "  Cidade: " + aCidFali[nX]

        cAux += CRLF
        cAux += CRLF
    
    Next

        cAux += "Total de Ocorrencias " + cQtdFalenc

Else
        
        cAux += "NADA CONSTA PARA O CNPJ CONSULTADO"
        cAux += CRLF
        cAux += CRLF

Endif

    cAux := Upper(cAux)

Return cAux

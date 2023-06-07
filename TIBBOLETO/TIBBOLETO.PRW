#include 'TOTVS.CH'
#include 'FWPRINTSETUP.CH'
#Include "RPTDEF.CH"

User Function TIBBOLETO(lShowPerg , cNumBor , cPrefixo , cTitulo , cCodCli , cLojCli , cBanco )
Local cPerg 	:= 'TIBBOLETO'
Local aAreaT 	:= GetArea()
Local lTela		:= .T.
Local cFilePdf	:= ""
Local cPDFGer  	:= GetNewPar("ES_PDFGER", GetSrvProfString("Startpath","") + "TIBBOLETO\")

Private  aTitCob := {}

Private	 xMVPar01
Private	 xMVPar02
Private	 xMVPar03
Private	 xMVPar04
Private	 xMVPar05
Private	 xMVPar06
Private	 xMVPar07
Private	 xMVPar08
Private	 xMVPar09
Private	 xMVPar10
Private	 xMVPar11
Private	 xMVPar12
Private	 xMVPar13
Private  lAPI	:= IsInCallStack('U_DXAPIBOL')

Default lShowPerg 	:= .T.
Default cNumBor		:= ""
Default cPrefixo	:= ""
Default cTitulo		:= ""
Default cCodCli		:= ""
Default cLojCli		:= ""
Default cBanco		:= ""

If ChkLib()


	xMVPar01	:= SE1->E1_NUMBOR
	xMVPar02	:= SE1->E1_NUMBOR
	xMVPar03	:= SE1->E1_PREFIXO
	xMVPar04	:= SE1->E1_PREFIXO
	xMVPar05	:= SE1->E1_NUM
	xMVPar06	:= SE1->E1_NUM
	xMVPar07	:= SE1->E1_CLIENTE
	xMVPar08	:= SE1->E1_LOJA
	xMVPar09	:= SE1->E1_CLIENTE
	xMVPar10	:= SE1->E1_LOJA
	xMVPar11	:= SE1->E1_PORTADO
	xMVPar13	:= cPDFGer //Sim		

	cFilePdf := PROCBOLETO( .F. )
	
Endif

RestArea(aAreaT)

Return cFilePDF

/*/{Protheus.doc} ChkLib
Retorna se o CNPJ do cliente esta liberado para utilizar este template ou nao
@author Giane
@since 03/03/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function ChkLib()

Local lRet := .T.
Local aHardLock  := {}  //Lista de hardlocks liberados para uso
Local aCNPJLib   := {}  //Lista de cnpjs liberados para uso

//HardLocks liberados para utilizar a rotina
aAdd(aHardLock, 2100013039)  //TotvsIbirapuera

//CNPJ's liberados para utilizar a rotina
aAdd(aCNPJLib, "        ")  //Empresa TESTE
aAdd(aCNPJLib, "21336335") 	//Empresa TESTE Cristian

aAdd(aCNPJLib, "20041743")  //NLMK - Cloud Totvs
aAdd(aCNPJLib, "00610829")  //AVE e SABOR
aAdd(aCNPJLib, "20966789")  //SOC. COM.
aAdd(aCNPJLib, "20490214")  //COM. IMP. MUNDIAL
aAdd(aCNPJLib, "21331902")  //COM. GERAL DE BEBIDAS
aAdd(aCNPJLib, "08604593")  //EUROTRONICS
aAdd(aCNPJLib, "01159496")  //SECUR
aAdd(aCNPJLib, "00845326")  //Grupo WECKERLE - WECKERLE
aAdd(aCNPJLib, "19860927")  //Grupo WECKERLE - LIBUS
aAdd(aCNPJLib, "44412435")  //Grupo Tessin
aAdd(aCNPJLib, "51366185")  //Grupo Tessin
aAdd(aCNPJLib, "44903516")  //Grupo Tessin
aAdd(aCNPJLib, "55131841")  //Grupo Tessin
aAdd(aCNPJLib, "04422405")  //Grupo Tessin
aAdd(aCNPJLib, "14626301")	//MIP FARMA
aAdd(aCNPJLib, "62300066")  //ACUMEL CARAMELOS
aAdd(aCNPJLib, "19760833") 	//TIEX
aAdd(aCNPJLib, "18209863")	//TIEX
aAdd(aCNPJLib, "21248667")  //TIEX
aAdd(aCNPJLib, "12187493")  //TIEX
aAdd(aCNPJLib, "18474495")  //TIEX
aAdd(aCNPJLib, "05692186")  //TIEX
aAdd(aCNPJLib, "20307337")  //TIEX
aAdd(aCNPJLib, "09628437")  //TIEX
aAdd(aCNPJLib, "04821800")  //TIEX
aAdd(aCNPJLib, "18466811")  //TIEX
aAdd(aCNPJLib, "12782020")  //TIEX
aAdd(aCNPJLib, "14411194")  //TIEX
aAdd(aCNPJLib, "05018227")  //TIEX
aAdd(aCNPJLib, "20199698")  //TIEX
aAdd(aCNPJLib, "22103098")  //TIEX
aAdd(aCNPJLib, "19879389")  //TIEX
aAdd(aCNPJLib, "20259079")  //TIEX
aAdd(aCNPJLib, "20259079")  //TIEX
aAdd(aCNPJLib, "20259079")  //TIEX
aAdd(aCNPJLib, "61618823")  //TIEX
aAdd(aCNPJLib, "12998292")  //TIEX
aAdd(aCNPJLib, "17026299")  //TIEX
aAdd(aCNPJLib, "06889658")  //TIEX
aAdd(aCNPJLib, "21794838")  //TIEX
aAdd(aCNPJLib, "22062496")  //TIEX
aAdd(aCNPJLib, "43607886")  //TIEX
aAdd(aCNPJLib, "44150910")  //Uniquimica
aAdd(aCNPJLib, "60910023")  //Iraja
aAdd(aCNPJLib, "47103106")	//0001-84 - ICA - Telecomunicaçãoes Ltda
aAdd(aCNPJLib, "04163433")	//0001-19 - Icatel Telemática Servicos e Comercio Ltda
aAdd(aCNPJLib, "44772937") 	//0001-50 - Telematica Sistemas Inteligentes Ltda
aAdd(aCNPJLib, "44045565") 	//CGA
aAdd(aCNPJLib, "13727162") 	//TAWCOPLAST 0001-78
aAdd(aCNPJLib, "19464930") 	//TRIAH
aAdd(aCNPJLib, "04507739") 	//GRANDPORT
aAdd(aCNPJLib, "19769981") 	//0001-64 - Granport Transporte
aAdd(aCNPJLib, "54437553")  //Multijuntas
aAdd(aCNPJLib, "02882381")  //Multijuntas
aAdd(aCNPJLib, "05676122")  //Multijuntas
aAdd(aCNPJLib, "03586087")  //Multijuntas
aAdd(aCNPJLib, "03342984") 	//Maxi Park
aAdd(aCNPJLib, "03478169") 	//Maxi Park
aAdd(aCNPJLib, "13843186") 	//Maxi Park
aAdd(aCNPJLib, "18737949") 	//Maxi Park
aAdd(aCNPJLib, "03080452") 	//Maxi Park
aAdd(aCNPJLib, "12319368") 	//Maxi Park
aAdd(aCNPJLib, "00712153") 	//Maxi Park
aAdd(aCNPJLib, "58925819") 	//Maxi Park
aAdd(aCNPJLib, "05790303") 	//Maxi Park
aAdd(aCNPJLib, "04961969") 	//Maxi Park
aAdd(aCNPJLib, "09598743") 	//Maxi Park
aAdd(aCNPJLib, "05800795") 	//Maxi Park
aAdd(aCNPJLib, "19799761") 	//Maxi Park
aAdd(aCNPJLib, "17774501") 	//SICES
aAdd(aCNPJLib, "58066036") 	//KIARTE
aAdd(aCNPJLib, "09471791") 	//K2 Comunicação
aAdd(aCNPJLib, "48791685") 	//CBS
aAdd(aCNPJLib, "21755120") 	//PIMENTA (PRINT)
aAdd(aCNPJLib, "10219302") 	//PIMENTA (BRUNO)
aAdd(aCNPJLib, "11312680") 	//PIMENTA (ARMANDO)
aAdd(aCNPJLib, "09337554") 	//MASTER CLEAR SERVICES
aAdd(aCNPJLib, "20677801") 	//MASTER CLEAR BRASIL
aAdd(aCNPJLib, "66759887") 	//KOYO
aAdd(aCNPJLib, "13707444") 	//CHRISTEYNS
aAdd(aCNPJLib, "10435340") 	//PLASTVINIL
aAdd(aCNPJLib, "24455993") 	//ROHA
aAdd(aCNPJLib, "13065231") 	//ARISTEC
aAdd(aCNPJLib, "14517997") 	//ARISTEC

// Valida autorização de execução
If aScan(aHardLock, LS_GetID()) <= 0					//Verifica o hardlock
	If aScan(aCNPJLib, SubStr(SM0->M0_CGC,1,8)) <= 0	//Verifica o cnpj
		//lRet := .F.
		//AVISO('ATENÇÃO','CNPJ não esta liberado para uso deste template de impressão de boletos!')
	EndIf
EndIf


Return lRet

/*/{Protheus.doc} PROCBOLETO
Seleciona na query boletos a serem impressos
@author Giane
@since 07/03/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function PROCBOLETO( lTela )
Local cSQl 			:= ''
Local nCont 		:= 0
Local lContinua 	:= .T.
Local cLayout		:= GetSrvProfString("Startpath","") + "TIBBOLETO\"
Local cImagem		:= ''
Local cQryEs		:= ''
Local nPosOrd 		:= 0
Local cFilePdf			:= ""

Private cAliasBOL	:= GetNextAlias()
//Private cArqCFG		:= GetSrvProfString("Startpath","") + "TIBBOLETO\TIBBOLETO.V01"
Private cArqCFG		:= "TIBBOLETO.V01"

Default lTela		:= .F.
lAPI := .T.

If lAPI	
	lTela := .F.
EndIF


If GetRemoteType() == 2 // REMOTE_LINUX
	cArqCFG := strtran(cArqCFG,"\","/",1,20)
EndIf

Conout('cArqCFG ' + cArqCFG)

If !File( cArqCFG )
	If !lAPI
		Help(" ",1,"TIBBOLETO",, "Arquivo de Configuração " + cArqCFG + " não encontrado!" + CRLF + CRLF + "Execute o Wizard de Configuração.",1,0)
	Else
		Conout("TIBBOLETO",, "Arquivo de Configuração " + cArqCFG + " não encontrado!" + CRLF + CRLF + "Execute o Wizard de Configuração.")
	EndIf

	lContinua := .F.
Else

	//copia o arquivo TIBBOLETO.V01 para a estação local, pois a funçao GetSrvProfString só funciona para
	//arquivos abaixo do \bin\smartclient ou local. Isso por causa de clientes no cloud que nao enxergam o \bin\smartclient
	If lTela
		cLocTemp := AllTrim(GetTempPath()) + If(Right(AllTrim(GetTempPath()), 1) == '\', '', '\')
	Else
		cLocTemp := '\bol_gerados\'//cArqCFG
	EndIf

	If lTela .And. !IsInCallStack('U_DAXAPIBOL')
		If!CpyS2T( cArqCFG, cLocTemp ,.F.)
			lContinua := .F.
			If !lAPI
				Help(" ",1,"TIBBOLETO",,	'Não foi possível transferir o arquivo de configuração do Servidor para sua estação de trabalho!'  + CRLF + CRLF + ' Tente reiniciar o computador. Caso o problema persista, entre em contato com o Administrador do sistema',1,0)
			Else
				Conout('Não foi possível transferir o arquivo de configuração do Servidor para sua estação de trabalho!'  + CRLF + CRLF + ' Tente reiniciar o computador. Caso o problema persista, entre em contato com o Administrador do sistema')
			EndIf

		Else
			cArqCFG := cLocTemp + "TIBBOLETO.V01"
		Endif
	EndIf
Endif


If lContinua

	SE1->(DBSETORDER(1))
	SE1->(dbgotop())

	cSQL:=" SELECT E1_PORTADO , E1_CLIENTE, E1_LOJA , E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_NOMCLI, E1_NUMBOR, SE1.R_E_C_N_O_ SE1REC FROM " + RETSQLName("SE1")  + " SE1 "
	cSQL+=" WHERE D_E_L_E_T_ = ' ' "
	cSQL+=" AND E1_NUMBOR >= " + VALTOSQL(XMVPar01) + " AND E1_NUMBOR <= " + VALTOSQL(XMVPar02)
	cSQL+=" AND E1_PREFIXO >=" + VALTOSQL(XMVPar03) + " AND E1_PREFIXO <=" + VALTOSQL(XMVPar04)
	cSQL+=" AND E1_NUM >=    " + VALTOSQL(XMVPar05) + " AND E1_NUM <=    " + VALTOSQL(XMVPar06)
	cSQL+=" AND E1_CLIENTE >=" + VALTOSQL(XMVPar07) + " AND E1_CLIENTE <=" + VALTOSQL(XMVPar09)
	cSQL+=" AND E1_LOJA >=   " + VALTOSQL(XMVPar08) + " AND E1_LOJA <=   " + VALTOSQL(XMVPar10)
	cSQL+=" AND E1_PORTADO ='" + XMVPar11 + "' "
	cSQL+=" AND E1_SALDO > 0 AND SE1.D_E_L_E_T_ <> '*'  AND E1_AGEDEP <> '' AND E1_CONTA <> '' "

	//Ponto de entrada para alterar, acrescentar dados na query
	//neste p.e. nao pode acrescentar ORDER BY
	If ExistBlock("TBOLQRY")
		SaveInter()
		cQryEs := ExecBlock("TBOLQRY",.F.,.F., cSQL )
		RestInter()
		If Valtype(cQryEs) == 'C' .And. !Empty(cQryEs)
			cSQL := cQryEs
		EndIf
	EndIf

	//caso no p.e. TBOLQRY tenha inserido um order by, retirar pois nao pode ser alterado
	nPosOrd := Rat("ORDER BY",UPPER(cSQL))
	If nPosOrd > 0
		cSQL := Left(cSQL,nPosOrd -1)
	Endif

	cSQL+=" ORDER BY E1_CLIENTE, E1_LOJA , E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO"

	cSql := ChangeQuery(cSql)

	DbUseArea(.T.,"TOPCONN",TCGenQry(,,cSQL),cAliasBOL,.F.,.T.)

	(cAliasBOL)->(DBEval( {|| nCont++  } ))
	(cAliasBOL)->(DBGotop())

	If nCont > 0
		If lTela
			cImagem := GetPvProfString(XMVPar11,"cBolImg","ERR", cArqCFG )
		Else
			cImagem := GetPvProfString(XMVPar11,"cBolImg","ERR", cArqCFG )
			//cImagem	:= GetPvProfString(XMVPar11,"cBolImg","ERR", "\TIBBOLETO.V01" )
		EndIf

		If cImagem == "ERR"
			If !lAPI
				Help(" ",1,"TIBBOLETO",, "Banco " + XMVPar11 + " não faz parte do template de impressão de boletos! " + CRLF + CRLF + "Não é possível continuar o processamento.",1,0)
			else
				Conout("Banco " + XMVPar11 + " não faz parte do template de impressão de boletos! " + CRLF + CRLF + "Não é possível continuar o processamento.")
			EndIf
		Else

		 	cLayout :=  cLayout + cImagem

			If GetRemoteType() == 2 // REMOTE_LINUX
				cLayout := strtran(cLayout,"\","/",1,20)
			EndIf

			If File(cLayout)
				cFilePdf	:= PrepBoleto(nCont,cArqCFG,cLayout,lTela) //Prepara dados BOLETOS
			Else
				If !lAPI
					Help(" ",1,"TIBBOLETO",, "Arquivo de imagem do boleto " + cLayout + " não encontrado!" + CRLF + CRLF + "Execute o Wizard de Configuração.",1,0)
				Else
					Conout("Arquivo de imagem do boleto " + cLayout + " não encontrado!" + CRLF + CRLF + "Execute o Wizard de Configuração.")
				EndIf
			Endif
		Endif

	Else
		If !lAPI
			Help(" ",1,"TIBBOLETO",, "Nenhum título foi encontrado para impressão de boleto!" + CRLF + CRLF + "Verifique se os títulos\borderôs estão de acordo com os filtros em tela e se pertencem ao banco filtrado",1,0)
		Else
			Conout("Nenhum título foi encontrado para impressão de boleto!" + CRLF + CRLF + "Verifique se os títulos\borderôs estão de acordo com os filtros em tela e se pertencem ao banco filtrado")
			Conout('query - ' + cSQL)
		EndIf
	Endif
Else
	Conout('TIBBOLETO - Titulo nao disponivel para impressao')
Endif

Return	cFilePdf


/*/{Protheus.doc} PrepBoleto
Prepara dados para impressao dos boletos
@author Giane
@since 07/03/2016
@version 1.0
@param nCont, numérico, (Descrição do parâmetro)
@param cArqCFG, caracter, (nome do arquivo de configuracao de boletos)
@param cLayout, caracter, (arquivo de imagem do boleto a ser impresso)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function PrepBoleto(nCont,cArqCFG,cLayout,lTela)

Local cTime				:= ''
Local cFilePdf			:= ''
Local cChave 			:= ''
Local cChvSEE			:= ''
Local nLNossoN			:= 0
Local lErrMsgSTop		:= .T.
Local lContinua			:= .T.
Local lTinhaNossoNro	:= .T.
Local lImp				:= .F.
Local cFileLog			:= GetSrvProfString("Startpath","") + "TIBBOLETO\LOG\TIBBOLETO_" + Dtos(Date()) + StrTran(Time(),":","") + ".LOG"
Local nHdlLog			:= 0
Local cPathPDF 			:= '\bol_gerados\'//xMVPar13     //GetNewPar("ES_PDFGER", GetSrvProfString("Startpath","") + "TIBBOLETO\")
Local cCodCli			:= ""
Local cLojCli			:= ""
Local cNum				:= ""
Local cQuebra			:= ""
Local cCposQ			:= ""
Local lFirst            := .t.
Local cStartPath 		:= GetSrvProfString("Startpath","")

Default lTela	 		:= .T.

Private cAliasSEE
Private oPrinter
Private cNossoNum		:= ''

ProcRegua(0)//ncont

If CriaLog(@nHdlLog,cFileLog)

	//verifica como sera a geracao de cada arquivo PDF, se todos os titulos do cliente+loja num PDF
	// ou se 1 PDF para cada titulo
	If lTela
		cQuebra := Upper( GetPvProfString(XMVPar11,"cQuebraPDF","CLIENTE", cArqCFG ) )
	Else
		cQuebra := Upper ( GetPvProfString(XMVPar11,"cQuebraPDF","TITULO", "\TIBBOLETO.V01" ) )
	EndIf
	Do While !(cAliasBOL)->(Eof())

		aTitCob := {}
		cCodCli	:= (cAliasBOL)->E1_CLIENTE
		cLojCli	:= (cAliasBOL)->E1_LOJA
		cNum	:= (cAliasBOL)->E1_NUM

		If cQuebra == 'TITULO'
			cChave := (cAliasBOL)->E1_CLIENTE + (cAliasBOL)->E1_LOJA + (cAliasBOL)->E1_PREFIXO+(cAliasBOL)->E1_NUM + (cAliasBOL)->E1_PARCELA + (cAliasBOL)->E1_TIPO
			cCposQ := '(cAliasBOL)->E1_CLIENTE + (cAliasBOL)->E1_LOJA + (cAliasBOL)->E1_PREFIXO + (cAliasBOL)->E1_NUM + (cAliasBOL)->E1_PARCELA + (cAliasBOL)->E1_TIPO '
			//nome do arquivo PDF
			//cFilePdf := "boleto_" + Upper( Alltrim((cAliasBOL)->E1_NOMCLI)) + Upper( Alltrim((cAliasBOL)->E1_PREFIXO))  + "_" + Upper( Alltrim((cAliasBOL)->E1_NUM))  + Upper( Alltrim((cAliasBOL)->E1_PARCELA))
			//cFilePdf := "boleto_" + Upper( Alltrim((cAliasBOL)->E1_NOMCLI)) + Upper( Alltrim((cAliasBOL)->E1_PREFIXO))  + "_" + Upper( Alltrim((cAliasBOL)->E1_NUM))  + Upper( Alltrim((cAliasBOL)->E1_PARCELA))
			cFilePdf := "bol" + AllTrim((cAliasBOL)->E1_PORTADO)  +"_" + ;
			AllTrim((cAliasBOL)->E1_NUM) + "_" + ;
			AllTrim(IIF(Empty((cAliasBOL)->E1_PARCELA), "U", (cAliasBOL)->E1_PARCELA)) + "_" +;
			AllTrim((cAliasBOL)->E1_CLIENTE) + AllTrim((cAliasBOL)->E1_LOJA) 
		Else
			cChave := (cAliasBOL)->E1_CLIENTE + (cAliasBOL)->E1_LOJA
			cCposQ := ' (cAliasBOL)->E1_CLIENTE + (cAliasBOL)->E1_LOJA '
			//nome do arquivo PDF
			cFilePdf := "Boleto-" + Upper(StrTran(StrTran(Alltrim((cAliasBOL)->E1_NOMCLI),".","")," ","_"))  + "-" + Upper( Alltrim((cAliasBOL)->E1_NUMBOR)) 
		Endif

		// Monta um arquivo PDF de acordo com a quebra


		If !lTela
			//cPathPDF	:= "\SYSTEM\TIBBOLETO\BOLETOS\" + cChave + "\"
			If GetRemoteType() == 2 // REMOTE_LINUX 
				cPathPDF := strtran(cPathPDF,"\","/",1,20)
			EndIf  
			ParsePath(@cPathPDF)
			If !ExistDir(cPathPdf)
				MontaDir(cPathPdf)
			EndIf
		Else
//			cPathPDF := GetSrvProfString("Startpath","") + 'spool\'
			If GetRemoteType() == 2 // REMOTE_LINUX 
				cPathPDF := strtran(cPathPDF,"\","/",1,20)
			EndIf  
			ParsePath(@cPathPDF)
			If !ExistDir(cPathPdf)
				MontaDir(cPathPdf)
			EndIf
			
		EndIf
		
//		oPrinter := FWMSPrinter():New(cFilePdf, IMP_PDF, .F., cPathPDF , !lTela,,,,.T.,,,.F.)  
//		oPrinter := FWMSPrinter():New(cFilePdf, IMP_PDF, .F., cPathPDF/*cCaminhosPDF*/,.T.,,,,.T.,,,.F.,)
		oPrinter := FWMSPrinter():New(cFilePdf,IMP_PDF,.F.,cPathPDF, .T.,,@oPrinter,,,,,.F.)   

/*		If lFirst    //cPathPDF = nil
			If lTela
				oPrinter:Setup()
				If oPrinter:nModalResult <> PD_OK
					FWrite(nHdlLog,"["+Time() + "] IMPRESSÃO CANCELADA PELO USUARIO! " + Chr(13) + Chr(10) )
					Exit
				Endif
			EndIf
			If TYPE("oPrinter:cPathPDF") <> "U" //guarda o path que o usuario escolheu no setup, para depois nao chamar mais o setup e gravar todos os PDFS no mesmo path
				 cPathPDF := oPrinter:cPathPDF
			Endif
			lFirst := .f.
		Else
			If TYPE("oPrinter:cPathPDF") <> "U" //joga path ja escolhido na variavel cpathpdf do printer
				oPrinter:cPathPDF := cPathPDF
			Endif
		Endif
*/
		If lTela .and. xMVPar12 == 1
			oPrinter:SetViewPdf(.T.)
		EndIf

		oPrinter:SetPortrait()
		oPrinter:SetPaperSize(9)
		oPrinter:SetDevice(IMP_PDF)
		oPrinter:cPathPDF := cStartPath  //oPrinter:Setup()

		Do While !(cAliasBOL)->(Eof()) .and. &cCposQ == cChave //(cAliasBOL)->E1_CLIENTE + (cAliasBOL)->E1_LOJA == cChave
			Conout('TIBBOLETO - Entrou no while do oPrinter')
			IncProc()

			SE1->(DbGoto((cAliasBOL)->SE1REC))

			If SE1->E1_PORTADO +  SE1->E1_AGEDEP + SE1->E1_CONTA <> cChvSEE

				//PEGA DADOS de parametros de banco SEE, caso o banco seja diferente do anterior

				If Select(cAliasSEE) > 0
					(cAliasSEE)->(DbCloseArea())
				Endif

				cAliasSEE := GetNextAlias()
				BeginSql Alias cAliasSEE

			       SELECT SEE.*, SEE.R_E_C_N_O_ REGSEE
			       FROM %table:SEE% SEE
			       WHERE
			       	SEE.EE_FILIAL  = %Exp:FwxFilial("SEE")%
			       	AND SEE.%NotDel% AND SEE.EE_CODIGO = %Exp:SE1->E1_PORTADO%
			      		AND SEE.EE_AGENCIA  = %Exp:SE1->E1_AGEDEP%
			      		AND SEE.EE_CONTA   = %Exp:SE1->E1_CONTA%
			      		
						//AND SEE.EE_CODCART <> %Exp:('')%

			        // Diferenciamos desta forma: PAGTO nao tem carteira na SEE, RECEBIMENTO tem campo carteira informado na SEE
			        // e portanto é a configuração p/imprimir os boletos EE_CODCART <> ''

				EndSql

				cChvSEE := SE1->E1_PORTADO +  SE1->E1_AGEDEP + SE1->E1_CONTA

			Endif

			If (cAliasSEE)->(!Eof())

				// ************************* VALIDA NOSSO NUMERO **********************
				lContinua := VldNossoN(cArqCFG, @cNossoNum, @nLNossoN, @lTinhaNossoNro, @lErrMsgSTop )
				//*********************************************************************

				If !lErrMsgSTop
					FWrite(nHdlLog,"["+Time() + "] Código da Empresa não está de acordo com o Convênio do banco! " + Chr(13)+Chr(10) + "Nenhum boleto sera impresso. Verifique os parametros do banco." + Chr(13) + Chr(10) )
					Conout('TIBBOLETO -' + "["+Time() + "] Código da Empresa não está de acordo com o Convênio do banco! " + Chr(13)+Chr(10) + "Nenhum boleto sera impresso. Verifique os parametros do banco." + Chr(13) + Chr(10))
					Exit
				Endif


				If lContinua

					Begin Transaction

						lImp := U_ImpBoleto(cLayout,cArqCFG,cNossoNum)

						If lImp
							If !lTinhaNossoNro
								//se imprimiu o boleto e nao havia configurado SEE:
								GrvSEE(cNossoNum,nLNossoN)
						    Endif

					    Else
					 		FWrite(nHdlLog,"["+Time() +"] Função de calculos do banco não foi encontrada! Boleto nao foi impresso para o título "+SE1->E1_NUM + Chr(13) + Chr(10) )
							Conout('TIBBOLETO - ' + "["+Time() +"] Função de calculos do banco não foi encontrada! Boleto nao foi impresso para o título "+SE1->E1_NUM)
					    Endif

						lAlgumTit := .T.

					End Transaction

				Else
					FWrite(nHdlLog,"["+Time() +"] Faixa de nosso numero incorreta para o título "+SE1->E1_NUM+", verifique os parametros do banco e o campo SE1->E1_NUMBCO." + Chr(13) + Chr(10) )
					Conout('TIBBOLETO - ' + "["+Time() +"] Faixa de nosso numero incorreta para o título "+SE1->E1_NUM+", verifique os parametros do banco e o campo SE1->E1_NUMBCO." )
					lErrMsgSTop := .F.
				Endif

			Else
				FWrite(nHdlLog,"["+Time() +'] Parâmetros de Banco não encontrado, ou codigo da carteira não preenchido.' + CHR(13) + CHR(10) + 'Banco ' + Alltrim(SE1->E1_PORTADO) + ', Agencia: ' + Alltrim(SE1->E1_AGEDEP) + ', Conta: ' + Alltrim(SE1->E1_CONTA) + Chr(13) + Chr(10) )
				Conout('TIBBOLETO - ' + "["+Time() +'] Parâmetros de Banco não encontrado, ou codigo da carteira não preenchido.' + CHR(13) + CHR(10) + 'Banco ' + Alltrim(SE1->E1_PORTADO) + ', Agencia: ' + Alltrim(SE1->E1_AGEDEP) + ', Conta: ' + Alltrim(SE1->E1_CONTA) )
				lErrMsgSTop := .F.
			Endif

			(cAliasBOL)->(DbSkip())
	  	Enddo

		If !lErrMsgSTop
			cFilePdf := ''
			Exit //significa que o problema foi na configuracao do banco, e nao vai imprimir nenhum boleto
		Endif

		oPrinter:Preview()

		cFilePrint := cPathPDF + cFilePdf + '.REL'
		File2Printer( cFilePrint, "PDF" ) 
		FErase( cFilePrint )     

		FreeObj(oPrinter)
		oPrinter := Nil

		//ponto de entrada utilizado após impressao de cada boleto por cliente
/*		If ExistBlock("TBOLEND") .And. xMVPar13 == 1
			cFilePdf	:= ExecBlock("TBOLEND",.F.,.F.,{cPathPDF, cFilePdf , cCodCli , cLojCli , lTela, cNum, aTitCob } )
		EndIf
*/
	EndDo

	FWrite(nHdlLog, '[' + DtoC(Date()) + ' - ' + Time() + '] FINALIZADA A IMPRESSÃO DE BOLETOS' + Chr(13) + Chr(10))

	FClose(nHdlLog)
	If lTela
		ShowLog(cFileLog)
	EndIf
Endif

(cAliasBOL)->(DbCloseArea())

If Select(cAliasSEE) > 0
	(cAliasSEE)->(DbCloseArea())
Endif

oPrinter := Nil

Return  cFilePdf

/*/{Protheus.doc} ImpBoleto
Imprime os dados nos boletos
@author Giane
@since 07/03/2016
@version 1.0
@param cLayout, caracter, (Arquivo de imagem do boleto a ser impresso)
@param cArqCFG, caracter, (Arquivo de configuracao dos boletos)
@param cNossoNum, caracter, (NossoNumero)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User function ImpBoleto( cLayout, cArqCFG, cNossoNum)

Local lRet		:= .F.
Local oFont6n	:= TFont():New("Arial",,-6 ,.T.)
Local oFont10	:= TFont():New("Arial",,-10,.F.)
Local oFont8n	:= TFont():New("Arial",,-8 ,.T.)
Local oFont10n	:= TFont():New("Arial",,-10,.T.)
Local oFont16n	:= TFont():New("Arial",,-16,.T.)
Local nLin 		:= 0
Local nCol		:= 0
Local nTam		:= 0
Local cCod		:= ''
Local cAbatDecre:= ''
Local cAbatAcres:= ''
Local nVlrAbat	:= 0
Local cCpo		:= ''
Local nHLin		:= 0
Local cMensagem	:= ''
Local cFuncBarra:= ''
Local cSecao	:= ''
Local lImpMunSac:= .F.
Local cEndSac	:= ''
Local nLinM		:= 0
Local nS		:= 0
Local aCpos		:= {}
Local cSacAva	:= ''
Local nx		:= 0
Local cNumTit		:= alltrim(SE1->E1_NUM)

Private aCODE		:= {'','',''} //private para que funcoes de usuarios possam utilizar os valores calculados
Private cAgencia 	:= ''
Private cConta	 	:= ''
Private nVlrTit     := 0
Private cParcela    := ''
Private dDtMovto	:= SE1->E1_EMISSAO

//Posiciona o SA1 (Cliente)
DbSelectArea("SA1")
DbSetOrder(1)
DbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA,.T.)

//Posiciona o SA6 (Bancos)
DbSelectArea("SA6")
DbSetOrder(1)
DbSeek(xFilial("SA6")+SE1->(E1_PORTADO+E1_AGEDEP+E1_CONTA),.T.)

cParcela := MontaParcela() //SERA UTILIZADO PARA COMPOR NUMERO DO TITULO EM ALGUNS BANCOS

//verifica como o numero do documento cNumTit deve ser impresso no boleto e monta a string cNumTit
aPicTit := StrTokArr ( GetPvProfString(XMVPar11,"cNumTitulo",'E1_NUM,E1_PARCELA', cArqCFG ), "," )

cCfgParc := GetPvProfString(XMVPar11,"cCfgParcela",'SIM', cArqCFG ) //se eh para usarmos o cParcela(SIM) ou usar o E1_PARCELA

For nx := 1 to len(aPicTit)

	If aPicTit[nx] == 'E1_PARCELA' .and. cCfgParc == 'SIM'
		cNumTit += cParcela
	Else
		If nx = 1 
			cNumTit:= ''
		EndIf
		
		cCpo := aPicTit[nx]
		cNumTit += SE1->&cCpo
	
	Endif

Next
//
cAgencia := U_EETabulacaoBanco(cArqCFG, "A")
cConta   := U_EETabulacaoBanco(cArqCFG, "C")

cSecao		:= XMVPar11+'PARTE1' //exemplo [001PARTE1], existe 1 para cada banco no TITBOLETO.V01

//Valor do abatimento
cAbatDecre := GetPvProfString(cSecao,"cE1_DECRESC",'N', cArqCFG )
cAbatAcres := GetPvProfString(cSecao,"cE1_ACRESC" ,'N', cArqCFG )
nVlrAbat := SomaAbat(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, "R", 1, , SE1->E1_CLIENTE, SE1->E1_LOJA)
If cAbatDecre == "S"
	nVlrAbat += SE1->E1_DECRESC
Endif
If cAbatAcres == "S"
	nVlrAbat -= SE1->E1_ACRESC
Endif
//valor titulo
nVlrTit := (SE1->E1_SALDO - nVlrAbat)

//nome da funcao que calcula linha digitavel, cod barras, do banco que esta sendo impresso
cFuncBarra := 'U_CaBar' + XMVPar11 + '(XMVPar11, cArqCFG, @cAgencia, @cConta, cNossoNum, nVlrTit, @cParcela, @dDtMovto, @cNumTit)'

If FindFunction('U_CaBar' + XMVPar11)
	aCODE := &(cFuncBarra)

	oPrinter:StartPage()

	//pega imagem do boleto do banco para imprimir os dados
	oPrinter:SayBitmap(05,05, cLayOut, 600, 800)

	/*
	********************************** SECAO CABEC *********************************
	  Alguns bancos como Brasi e Santander tem um cabeçalho antes da parte 1 e 2 do boleto
	*/

	cSecao		:= XMVPar11+'CABEC'

	//Linha Digitavel
	nLin := Val( GetPvProfString(cSecao,"nLinLinhaDigita",'0', cArqCFG ) )
	nCol := Val( GetPvProfString(cSecao,"nColLinhaDigita",'0', cArqCFG ) )
	If nLin > 0 .and. nCol > 0
		oPrinter:Say(nLin, nCol, aCODE[2], oFont16n)
	Endif

	//nosso numero
	nLin := Val( GetPvProfString(cSecao,"nLinNossoN",'0', cArqCFG ) )
	nCol := Val( GetPvProfString(cSecao,"nColNossoN",'0', cArqCFG ) )
	If nLin > 0 .and. nCol > 0
		oPrinter:Say(nLin, nCol, aCODE[3], oFont10n)
	Endif

	//Especie DOC
	cMensagem := Alltrim( GetPvProfString(cSecao,"cEspecieDoc",'', cArqCFG ))
	nLin := Val( GetPvProfString(cSecao,"nLinEspecieDoc",'0', cArqCFG ) )
	nCol := Val( GetPvProfString(cSecao,"nColEspecieDoc",'0', cArqCFG ) )
	If !Empty(cMensagem) .and. nLin > 0 .and. nCol > 0
		oPrinter:Say(nLin, nCol, cMensagem, oFont10n)
	Endif

	//Nome do cedente
	nLin := Val( GetPvProfString(cSecao,"nLinCedente",'0', cArqCFG ) )
	nCol := Val( GetPvProfString(cSecao,"nColCedente",'0', cArqCFG ) )
	nTam := Val( GetPvProfString(cSecao,"nTamCedente",'30', cArqCFG )	)

	If nLin > 0 .and. nCol > 0
		oPrinter:Say(nLin, nCol,  SubStr(SM0->M0_NOMECOM, 1, nTam), oFont10n)
	Endif

	//numero titulo
	nLin := Val( GetPvProfString(cSecao,"nLinNumTit",'0', cArqCFG ) )
	nCol := Val( GetPvProfString(cSecao,"nColNumTit",'0', cArqCFG ) )
	If nLin > 0 .and. nCol > 0
		oPrinter:Say(nLin, nCol, Alltrim(cNumTit), oFont10n)
	Endif

	//Vencto do titulo
	nLin := Val( GetPvProfString(cSecao,"nLinVencto",'0', cArqCFG ) )
	nCol := Val( GetPvProfString(cSecao,"nColVencto",'0', cArqCFG ) )
	If nLin > 0 .and. nCol > 0
		oPrinter:Say(nLin,nCol, Dtoc(SE1->E1_VENCTO), oFont10n)
	Endif

	//Agencia/conta-digito
	nLin := Val( GetPvProfString(cSecao,"nLinAgCta",'0', cArqCFG ) )
	nCol := Val( GetPvProfString(cSecao,"nColAgCta",'0', cArqCFG ) )
	If nLin > 0 .and. nCol > 0
		oPrinter:Say(nLin,nCol, cAgencia + "/" + cConta , oFont10n)
	Endif

	//Valor do titulo
	nLin := Val( GetPvProfString(cSecao,"nLinValTit",'0', cArqCFG ) )
	nCol := Val( GetPvProfString(cSecao,"nColValTit",'0', cArqCFG ) )
	If nLin > 0 .and. nCol > 0
		oPrinter:Say(nLin,nCol, TransForm(nVlrTit, "@E 999,999,999.99"), oFont10n)
	Endif

	//Dados do sacado
	aDadosSac := DadosSac(cArqCFG)
	//Nome do sacado
	nLin := Val( GetPvProfString(cSecao,"nLinNomSacado",'0', cArqCFG ) )
	nCol := Val( GetPvProfString(cSecao,"nColNomSacado",'0', cArqCFG ) )
	If nLin > 0 .and. nCol > 0
		oPrinter:Say(nLin, nCol,  aDadosSac[1], oFont10n)
	Endif


	/*
	********************************** SECOES PARTE1 E PARTE2 *********************************
	*/

	For nS := 1 to 2
		cSecao := XMVPar11 + 'PARTE' + Str(nS,1)

		//Linha Digitavel
		nLin := Val( GetPvProfString(cSecao,"nLinLinhaDigita",'0', cArqCFG ) )
		nCol := Val( GetPvProfString(cSecao,"nColLinhaDigita",'0', cArqCFG ) )
		If nLin > 0 .and. nCol > 0
			oPrinter:Say(nLin, nCol, aCODE[2], oFont16n)
		Endif

		//Local de pagamento	1
		cMensagem := Alltrim( GetPvProfString(cSecao,"cLocalPagamento1",'', cArqCFG ))
		nLin := Val( GetPvProfString(cSecao,"nLinLocalPagto1",'0', cArqCFG ) )
		nCol := Val( GetPvProfString(cSecao,"nColLocalPagto1",'0', cArqCFG ) )
		If !Empty(cMensagem) .and. nLin > 0 .and. nCol > 0
			oPrinter:Say(nLin, nCol,  cMensagem, oFont10n)
		Endif

		//Local de pagamento	2
		cMensagem := Alltrim( GetPvProfString(cSecao,"cLocalPagamento2",'', cArqCFG ))
		nLin := Val( GetPvProfString(cSecao,"nLinLocalPagto2",'0', cArqCFG ) )
		nCol := Val( GetPvProfString(cSecao,"nColLocalPagto2",'0', cArqCFG ) )
		If !Empty(cMensagem) .and. nLin > 0 .and. nCol > 0
			oPrinter:Say(nLin, nCol,  cMensagem, oFont10n)
		Endif

		//Vencto do titulo
		nLin := Val( GetPvProfString(cSecao,"nLinVencto",'0', cArqCFG ) )
		nCol := Val( GetPvProfString(cSecao,"nColVencto",'0', cArqCFG ) )
		If nLin > 0 .and. nCol > 0
			oPrinter:Say(nLin,nCol, Dtoc(SE1->E1_VENCTO), oFont10n)
		Endif

		//Nome do cedente
		nLin := Val( GetPvProfString(cSecao,"nLinCedente",'0', cArqCFG ) )
		nCol := Val( GetPvProfString(cSecao,"nColCedente",'0', cArqCFG ) )
		nTam := Val( GetPvProfString(cSecao,"nTamCedente",'30', cArqCFG )	)
		If nLin > 0 .and. nCol > 0
			oPrinter:Say(nLin, nCol,  CapitalAce(SubStr(SM0->M0_NOMECOM, 1, nTam)), oFont10n)
		Endif

		//CNPJ Cedente
		nLin := Val( GetPvProfString(cSecao,"nLinCNPJCedente",'0', cArqCFG ) )
		nCol := Val( GetPvProfString(cSecao,"nColCNPJCedente",'0', cArqCFG ) )
		If nLin > 0 .and. nCol > 0
			oPrinter:Say(nLin,nCol,   TransForm(SM0->M0_CGC, "@R 99.999.999/9999-99") , oFont10n)
		Endif

		//Endereço do cedente
		nLin := Val( GetPvProfString(cSecao,"nLinEndCedente",'0', cArqCFG ) )
		nCol := Val( GetPvProfString(cSecao,"nColEndCedente",'0', cArqCFG ) )
		If nLin > 0 .and. nCol > 0
			oPrinter:Say(nLin, nCol, CapitalAce(Alltrim( SM0->M0_ENDCOB)), oFont10n)
		Endif

		//Municipio + UF + cep Endereço do cedente
		nLin := Val( GetPvProfString(cSecao,"nLinMunCedente",'0', cArqCFG ) )
		nCol := Val( GetPvProfString(cSecao,"nColMunCedente",'0', cArqCFG ) )
		If nLin > 0 .and. nCol > 0
			oPrinter:Say(nLin, nCol, Alltrim( SM0->M0_CIDCOB) + " - " + SM0->M0_ESTCOB + " - CEP: " + Transform(SM0->M0_CEPCOB,"@R 99999-999") , oFont10n)
		Endif

		//agencia + conta
		nLin := Val( GetPvProfString(cSecao,"nLinAgCta",'0', cArqCFG ) )
		nCol := Val( GetPvProfString(cSecao,"nColAgCta",'0', cArqCFG ) )
		If nLin > 0 .and. nCol > 0
			oPrinter:Say(nLin,nCol, cAgencia + "/" + cConta , oFont10n)
		Endif

		//Emissao do titulo
		nLin := Val( GetPvProfString(cSecao,"nLinEmissao",'0', cArqCFG ) )
		nCol := Val( GetPvProfString(cSecao,"nColEmissao",'0', cArqCFG ) )
		If nLin > 0 .and. nCol > 0
			oPrinter:Say(nLin, nCol,  Dtoc(SE1->E1_EMISSAO), oFont10n)
		Endif

		//Numero do titulo
		nLin := Val( GetPvProfString(cSecao,"nLinNumTit",'0', cArqCFG ) )
		nCol := Val( GetPvProfString(cSecao,"nColNumTit",'0', cArqCFG ) )
		If nLin > 0 .and. nCol > 0
			oPrinter:Say(nLin, nCol,  Alltrim(cNumTit), oFont10n)
		Endif

		//Especie DOC
		cMensagem := Alltrim( GetPvProfString(cSecao,"cEspecieDoc",'', cArqCFG ))
		nLin := Val( GetPvProfString(cSecao,"nLinEspecieDoc",'0', cArqCFG ) )
		nCol := Val( GetPvProfString(cSecao,"nColEspecieDoc",'0', cArqCFG ) )
		If !Empty(cMensagem) .and. nLin > 0 .and. nCol > 0
			oPrinter:Say(nLin, nCol, cMensagem, oFont10n)
		Endif

		//Aceite
		cMensagem := Alltrim( GetPvProfString(cSecao,"cAceite",'', cArqCFG ))
		nLin := Val( GetPvProfString(cSecao,"nLinAceite",'0', cArqCFG ) )
		nCol := Val( GetPvProfString(cSecao,"nColAceite",'0', cArqCFG ) )
		If !Empty(cMensagem) .and. nLin > 0 .and. nCol > 0
			oPrinter:Say(nLin, nCol, cMensagem, oFont10n)
		Endif

		//Data do movimento
		nLin := Val( GetPvProfString(cSecao,"nLinDtMovto",'0', cArqCFG ) )
		nCol := Val( GetPvProfString(cSecao,"nColDtMovto",'0', cArqCFG ) )
		If nLin > 0 .and. nCol > 0
			oPrinter:Say(nLin, nCol,  Dtoc(dDtMovto), oFont10n)
		Endif

		//nosso numero
		nLin := Val( GetPvProfString(cSecao,"nLinNossoN",'0', cArqCFG ) )
		nCol := Val( GetPvProfString(cSecao,"nColNossoN",'0', cArqCFG ) )
		If nLin > 0 .and. nCol > 0
			oPrinter:Say(nLin, nCol, aCODE[3], oFont10n)
		Endif

		//Data da operação
		nLin := Val( GetPvProfString(cSecao,"nLinDtOperacao",'0', cArqCFG ) )
		nCol := Val( GetPvProfString(cSecao,"nColDtOperacao",'0', cArqCFG ) )
		If nLin > 0 .and. nCol > 0
			oPrinter:Say(nLin, nCol,  Dtoc(SE1->E1_EMISSAO), oFont10n)
		Endif

		//Cod Carteira
		nLin := Val( GetPvProfString(cSecao,"nLinCarteira",'0', cArqCFG ) )
		nCol := Val( GetPvProfString(cSecao,"nColCarteira",'0', cArqCFG ) )
		cCod := GetPvProfString(cSecao,"cCodCarteira",'', cArqCFG )
		If nLin > 0 .and. nCol > 0
			If Empty(cCod) .or. cCod=='0'
				cCod := (cAliasSEE)->EE_CODCART
			Endif
			oPrinter:Say(nLin, nCol,  cCod, oFont10n)
		Endif

		//Moeda/Especie  DOC
		cMensagem := Alltrim( GetPvProfString(cSecao,"cMoeda",'', cArqCFG ))
		nLin := Val( GetPvProfString(cSecao,"nLinMoeda",'0', cArqCFG ) )
		nCol := Val( GetPvProfString(cSecao,"nColMoeda",'0', cArqCFG ) )
		If !Empty(cMensagem) .and. nLin > 0 .and. nCol > 0
			oPrinter:Say(nLin, nCol, cMensagem, oFont10n)
		Endif

		//Valor do titulo
		nLin := Val( GetPvProfString(cSecao,"nLinValTit",'0', cArqCFG ) )
		nCol := Val( GetPvProfString(cSecao,"nColValTit",'0', cArqCFG ) )
		If nLin > 0 .and. nCol > 0
			oPrinter:Say(nLin,nCol, TransForm( nVlrTit, "@E 999,999,999.99"), oFont10n)
		Endif

		//Instrucoes da parte de baixo do boleto
		MontaMsg(cSecao, cArqCFG, nVlrTit, oFont10n)

		//Valor Cobrado
		nLin := Val( GetPvProfString(cSecao,"nLinVlrCobrado",'0', cArqCFG ) )
		nCol := Val( GetPvProfString(cSecao,"nColVlrCobrado",'0', cArqCFG ) )
		If nLin > 0 .and. nCol > 0
			oPrinter:Say(nLin, nCol, TransForm(nVlrTit, "@E 999,999,999.99"), oFont10n)
		Endif

		//Dados do sacado
		If nS == 1
			aDadosSac := DadosSac(cArqCFG)
		Endif

		//Nome do sacado
		nLin := Val( GetPvProfString(cSecao,"nLinNomSacado",'0', cArqCFG ) )
		nCol := Val( GetPvProfString(cSecao,"nColNomSacado",'0', cArqCFG ) )
		If nLin > 0 .and. nCol > 0
			oPrinter:Say(nLin, nCol,  aDadosSac[1], oFont10n)
		Endif


		//codigo + loja + nome do sacado(cliente)
		nLin := Val( GetPvProfString(cSecao,"nLinCodSacado",'0', cArqCFG ) )
		nCol := Val( GetPvProfString(cSecao,"nColCodSacado",'0', cArqCFG ) )
		If nLin > 0 .and. nCol > 0
		   	oPrinter:Say(nLin, nCol, aDadosSac[2] + " / " + aDadosSac[1], oFont8n)
		Endif


		//CNPJ sacado
		nLin := Val( GetPvProfString(cSecao,"nLinCNPJSacado",'0', cArqCFG ) )
		nCol := Val( GetPvProfString(cSecao,"nColCNPJSacado",'0', cArqCFG ) )
		If nLin > 0 .and. nCol > 0
			If SA1->A1_PESSOA == 'F'
				oPrinter:Say(nLin,nCol,   TransForm(aDadosSac[7], "@R 999.999.999-99") , oFont10n)
			Else
				oPrinter:Say(nLin,nCol,   TransForm(aDadosSac[7], "@R 99.999.999/9999-99") , oFont10n)
			Endif
		Endif

		lImpMunSac := .F.
		//Endereco sacado
		nLin := Val( GetPvProfString(cSecao,"nLinEndSacado",'0', cArqCFG ) )
		nCol := Val( GetPvProfString(cSecao,"nColEndSacado",'0', cArqCFG ) )
		//Mun. + Est + CEP
		nLinM := Val( GetPvProfString(cSecao,"nLinMunSacado",'0', cArqCFG ) )

		If nLin > 0 .and. nCol > 0
			If (nLin <> nLinM)
				cEndSac:= aDadosSac[3]
			Else //se as linhas do endereco e municipio do sacado forem iguais, concatena tudo pra nao ficar espaços em branco
				cEndSac:= CapitalAce(aDadosSac[3] + IIf(!Empty(aDadosSac[4]) ," - " + aDadosSac[4],"" ) + " - " + aDadosSac[5] + " - CEP: " + TransForm(aDadosSac[6], "@R 99999-999"))
				lImpMunSac := .T.
			Endif
			oPrinter:Say(nLin, nCol, cEndSac , oFont8n)
		Endif

		If !lImpMunSac
			//Mun. + Est + CEP
			nCol := Val( GetPvProfString(cSecao,"nColMunSacado",'0', cArqCFG ) )
			If nLinM > 0 .and. nCol > 0
				oPrinter:Say(nLinM, nCol, CapitalAce(aDadosSac[4] + IIf(!Empty(aDadosSac[5]),  " - " + aDadosSac[5],"") + " - CEP: " + TransForm(aDadosSac[6], "@R 99999-999")), oFont8n)
			Endif
		Endif

		//sacador/Avalista
		cSacAva := GetPvProfString(cSecao,"cNomSacador",'', cArqCFG )
		nLin := Val( GetPvProfString(cSecao,"nLinSacador",'0', cArqCFG ) )
		nCol := Val( GetPvProfString(cSecao,"nColSacador",'0', cArqCFG ) )
		If nLin > 0 .and. nCol > 0	.and. !Empty(cSacAva)
		   	oPrinter:Say(nLin, nCol, cSacAva, oFont8n)
		Endif


		//Impressao do codigo de barras
		nLin := Val( GetPvProfString(cSecao,"nLinCodBarra",'0', cArqCFG ) )
		nCol := Val( GetPvProfString(cSecao,"nColCodBarra",'0', cArqCFG ) )
		If nLin > 0 .and. nCol > 0
			oPrinter:FWMSBAR("INT25", nLin, nCol, aCODE[1], oPrinter, .F.,, .T., 0.020, 1, .F., "Arial", NIL, .F., 0.6, 1, .F.)
		Endif

		//Verifica se existem campos customizados a serem impressos que estão no arquivo de configuracao TIBBOLETO.V01
		CpoCustom(cArqCFG, cSecao, oPrinter, oFont10n)
	Next

	// Preenche array pra imprimir enviar no email de cobranca
	aAdd(aTitCob, {	SE1->E1_NUM,;
					SE1->E1_PREFIXO,;
					SE1->E1_PARCELA,;
					SE1->E1_PORTADO,;
					cAgencia,;
					cConta,;
					SE1->E1_VENCTO,;
					nVlrTit,;
					aCODE[2],;
					aCODE[3],;
					SE1->E1_EMISSAO})
										
	//ponto de entrada para imprimir qualquer outro conteudo customizado no boleto
	//deve retornar um array no formato {linha,coluna,conteudo a ser impresso}
	If ExistBlock("TBOLCPOS")
		SaveInter()
		aCpos := ExecBlock("TBOLCPOS",.F.,.F.,{cArqCFG, aCODE} )
		RestInter()
		If Valtype(aCpos) == 'A'
			ImpCpos(aCpos, oPrinter, oFont10n)
		EndIf
	EndIf

	oPrinter:EndPage()
	lRet := .T. //imprimiu o boleto

Endif

Return lRet


/*/{Protheus.doc} ImpCpos
Imprime campos customizados no boleto que retornaram do P.E. TBOLCPOS
@author Giane
@since 30/03/2016
@version 1.0
@param aCpos, array, (Array contendo linhas, colunas e conteudos a serem impressos)
@param oPrinter, objeto, (objeto oPrinter)
@param oFont, objeto, (objeto Tfont)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function ImpCpos(aCpos, oPrinter, oFont)
Local nLen := Len(aCpos)
Local nX	:= 0
Local nI	:= 0
Local lImp	:= .T.

For nX := 1 to nLen

	lImp := .T.

	If Len( aCpos[nX] ) >= 3 //aCpos deve ser sempre 3 elementos: linha, coluna e conteudo

		//elementos 1 e 2 devem ser numericos (linha e coluna)
		For nI := 1 to 2
			If Valtype( aCpos[nX,nI] ) <> 'N'
				lImp := .F.
			Endif
		Next

		If lImp
			//verifica se o elemento 3 é caracter
			If Valtype( aCpos[nX,3] ) <> 'C'
				lImp := .F.
			Endif
		Endif

		If lImp
			oPrinter:Say( aCpos[nX,1], aCpos[nX,2], aCpos[nX,3] , oFont)
		Endif

	Endif
Next

Return

/*/{Protheus.doc} CpoCustom
Funcao verifica se existem campos customizados no arq. TIBBOLETO.V01 a serem impressos
O usuário deve criar os campos como no exemplo abaixo no arq. TIBBOLETO.V01:

nLinCpoCustom1=200  ==> linha a ser impresso o campo customizado
nColCpoCustom1=56   ==> coluna a ser impresso o campo customizado

cCpoCustom1=pagar preferencial na CEF   ==> TEXTO A SER IMPRESSO NO BOLETO
  OU
cCpoCustom1=U_IMPTXT  ==>  FUNCAO A SER CHAMADA NO BOLETO, deve sempre ser user function e iniciar com U_

@author Giane
@since 31/03/2016
@version 1.0
@param cARQCFG, character, (Nome e caminho do arquivo de configuracao TIBBOLETO.V01)
@param cSecao, character, (Nome da secao no arq. de configuracao)
@param oPrinter, objeto, (objeto oprinter de impressao)
@param oFont, objeto, (objeto tfont a ser utilizado na impressao)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function CpoCustom(cArqCFG, cSecao, oPrinter, oFont)
Local nLin		:= 0
Local nCol		:= 0
Local nQtd		:= 20 //qtde maxima que podera ter campos customizados em cada secao do TIBBOLETO.V01
Local cCpoLin	:= ''
Local cCpoCol	:= ''
Local cCpoCus	:= ''
Local cConteudo:= ''
Local nX		:= 0
Local cTexto	:= ''
Local cFuncao	:= ''

For nX := 1 to nQtd

	cCpoCus := 'cCpoCustom' + Alltrim(Str(nX))
	cConteudo := Alltrim( GetPvProfString(cSecao,cCpoCus,'', cArqCFG ) )
	If !Empty(cConteudo)

		cCpoLin := 'nLinCpoCustom' + Alltrim(Str(nX))
		cCpoCol := 'nColCpoCustom' + Alltrim(Str(nX))

		nLin := Val( GetPvProfString(cSecao,cCpoLin,'0', cArqCFG ) )
		nCol := Val( GetPvProfString(cSecao,cCpoCol,'0', cArqCFG ) )
		If nLin > 0 .and. nCol > 0

			If Left(cConteudo,2) == 'U_'
				//caso seja uma user function a ser executada e retornar o conteudo a ser impresso:
				If FindFunction(cConteudo)
					cFuncao := Right(cConteudo, len(cConteudo) - 2)  //retira o U_

					If Right(cFuncao,2) == '()' //retira () do final, se houver
						cFuncao := Left(cFuncao, len(cFuncao) - 2 )
					Endif

					cTexto := ExecBlock(cFuncao,.F.,.F.,{cArqCFG} )
					If ValType(cTexto) <> "C"
						cTexto := ''
					Endif
				Endif
			Else
				cTexto := cConteudo
			Endif
			oPrinter:Say(nLin, nCol, cTexto , oFont)
		Endif
	Else
		//significa que nao existem mais campos customizados com conteudo a serem impressos, pois
		//os campos devem seguir um sequencial de 1 a 20, exemplo: cCpoCustom1, cCpoCustom2,...
		Exit
	Endif

Next

Return


/*/{Protheus.doc} VldNossoN
Valida nosso numero
@author Giane
@since 07/03/2016
@version 1.0
@param cArqCFG, character, (Descrição do parâmetro)
@param @cNossoNum, ${param_type}, (Nossonumero)
@param @nLNossoN, ${param_type}, (Digitos de nosso numero)
@param @lTinhaNossoNro, ${param_type}, (Variavel controle para gravar ou nao EE_FAXATU)
@param @lErrMsgSTop, ${param_type}, (Variavel controle mostrar mensagem ou nao)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function VldNossoN( cArqCFG, cNossoNum, nLNossoN, lTinhaNossoNro, lErrMsgSTop)

Local lRet			:= .T.
Local nCfgCodEmp	:= Val( GetPvProfString(XMVPar11,"nCfgCodEmp",'0', cArqCFG ) )
Local cCfgNossoN	:= "nCfgFxNossoN"
Local cEmpNossoN	:= ''
Local cFaxAtuSEE 	:= ""
Local Nx			:= 0
Local cDigitos		:= ''
Local nTCodEmp		:= 0
Local nPos			:= 0
Local aCodEmp		:= {}
Local nCod			:= 0

/***********************************************************************************************
 Atualmente o banco do Brasil possui duas opçoes de digitos para nosso numero 6 ou 7
 Qualquer bco que possua mais de 1 convenio, deve ter no TIBBOLETO.V01 as variaveis nCfgFxNossoN uma para
 cada convenio e nEmpNossoN também, no caso do banco do brasil nCfgFxNossoN1 e nCfgFxNossoN2, nEmpNossoN1,
 nEmpNossoN2. E a variavel nCfgCodEmp = 2, para os bancos que só tem 1 convenio:nCfgCodEmp =0
 *************************************************************************************************/

If nCfgCodEmp > 0

	For nX := 1 to nCfgCodEmp
		//nEmpNossoN representa qtde digitos do convenio (tamanho de EE_CODEMP)
		cEmpNossoN := "nEmpNossoN" + Alltrim(Str(nX)) //ex: nEmpNossoN1
		nCod := Val( GetPvProfString(XMVPar11,cEmpNossoN,'0', cArqCFG ))

		If nCod > 0
			aadd(aCodEmp, nCod )
		Endif

	Next

   nTCodEmp := Len(Alltrim((cAliasSEE)->EE_CODEMP))
   nPos := Ascan(aCodEmp,{|x| x ==  nTCodEmp } )
   If nPos > 0
   		cCfgNossoN :=  "nCfgFxNossoN" + Alltrim(Str(nPos)) //ex: cCfgNossoN1
	Else
		lRet := .F.
		// o código da Empresa não está de acordo com o Convênio do banco! Nenhum boleto sera impresso.
		lErrMsgSTop:= .F.
	Endif
Endif

If lRet
	nLNossoN := Val( GetPvProfString(XMVPar11,cCfgNossoN,'8', cArqCFG ) )

	If !Empty(SE1->E1_NUMBCO)
		If nLNossoN > TamSX3("E1_NUMBCO")[1]
			lRet := .F.
		Else
			cNossoNum := Alltrim(SE1->E1_NUMBCO)
			nLen := Len(cNossoNum)
			If nLen > nLNossoN
				cNossoNum := Right(cNossoNum,nLNossoN)
			Elseif nLen < nLNossoN
				cNossoNum := replicate("0",nLNossoN - nLen) + cNossoNum
			Endif
		Endif
		lTinhaNossoNro := .T.
	Endif

	//cNossoNum := SUBSTR(SE1->E1_NUMBCO,1,nLNossoN)

	If !Empty(cNossoNum) .AND. cNossoNum != Strzero(val(SEE->EE_FAXATU),nLNossoN) .AND. !lTinhaNossoNro 
		//cNossoNum		:= Strzero(val(SEE->EE_FAXATU),nLNossoN)
		cFaxAtuSEE 	:= Posicione("SEE",1,xFilial("SEE")+SE1->E1_PORTADO+SE1->E1_AGEDEP+SE1->E1_CONTA,"EE_FAXATU")
		cNossoNum 	:= Strzero(val(cFaxAtuSEE),nLNossoN)
		lTinhaNossoNro	:= .F.
	EndIf
	
	If Empty(cNossoNum) .OR. cNossoNum == replicate('0',nLNossoN ) //se ainda nao gerou nosso nro no titulo SE1
	
		//cNossoNum		:= Strzero(val((cAliasSEE)->EE_FAXATU),nLNossoN)
		cFaxAtuSEE 	:= Posicione("SEE",1,xFilial("SEE")+SE1->E1_PORTADO+SE1->E1_AGEDEP+SE1->E1_CONTA,"EE_FAXATU")
		cNossoNum 	:= Strzero(val(cFaxAtuSEE),nLNossoN)
		lTinhaNossoNro	:= .F.
		
		If Empty(cNossoNum)  .OR. cNossoNum == replicate('0',nLNossoN )
			// Faixa de nosso numero incorreta para o boleto "+SE1->E1_NUM+", por favor verifique
			lRet := .F. //nao imprime este boleto
		Endif
	
	Endif

Endif

Return lRet

/*/{Protheus.doc} MontaParcela
Efetua tratamento na parcela
@author Giane
@since 07/03/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function MontaParcela()

Local cRet := ''

DO CASE
	CASE ( SE1->E1_PARCELA == "A" .or. Val(SE1->E1_PARCELA) == 1 )
		cRet := "1"
	CASE (SE1->E1_PARCELA == "B".or. Val(SE1->E1_PARCELA) == 2 )
		cRet := "2"
	CASE (SE1->E1_PARCELA == "C" .or. Val(SE1->E1_PARCELA) == 3 )
		cRet := "3"
	CASE (SE1->E1_PARCELA == "D" .or. Val(SE1->E1_PARCELA) == 4 )
		cRet := "4"
	CASE (SE1->E1_PARCELA == "E"  .or. Val(SE1->E1_PARCELA) == 5 )
		cRet := "5"
	CASE (SE1->E1_PARCELA == "F" .or. Val(SE1->E1_PARCELA) == 6 )
		cRet := "6"
	CASE (SE1->E1_PARCELA == "G"  .or. Val(SE1->E1_PARCELA) == 7 )
		cRet := "7"
	CASE (SE1->E1_PARCELA == "H" .or. Val(SE1->E1_PARCELA) == 8 )
		cRet := "8"
	CASE (SE1->E1_PARCELA == "I" .or. Val(SE1->E1_PARCELA) == 9 )
		cRet := "9"
	OTHERWISE
		cRet := "0"
ENDCASE

Return cRet

/*/{Protheus.doc} GrvSEE
O titulo, campo E1_NUMBCO nao tinha o nosso numero, portanto o SEE deve ser atualizado
com o campo EE_FAXATU que esta sendo gerado agora no boleto
@author Giane
@since 07/03/2016
@version 1.0
@param cNossoNum, character, (NossoNumero)
@param nLNossoN, numérico, (Qtde correta de digitos do nosso numero)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GrvSEE(cNossoNum,nLNossoN)

If nLNossoN > TamSX3("EE_FAXATU")[1]
	nLNossoN := TamSX3("EE_FAXATU")[1]
Endif

SEE->(DbGoto( (cAliasSEE)->REGSEE ))

SEE->(RecLock("SEE",.f.))

SEE->EE_FAXATU:= StrZero(Val(cNossoNum)+1,nLNossoN)

SEE->(MsUnlock())

Return


/*

Os layouts dos bancos exigem uma determinada qtd de caracteres no formato da conta e da agencia.
Caso o usuário não tenha informado isto corretamente no, informado qtde MENOR de digitos apenas
seu cadastro, a função completa com zeros a esquerda.

ITAU   CONTA BANCARIA 5(C)   AGENCIA(4)
santander   CONTA BANCARIA 6(C)   AGENCIA(4)
bradesco   CONTA BANCARIA 7(C)   AGENCIA(4)
bco brasil  8(c)                        (4)
(bco 104)   6(c)                        (4)


(bco 399)   5(c)                        (4)
(bco 422)   9(c)                        5(c)

*/
User function EETabulacaoBanco(cArqCFG, pTipo)
Local cContAtu 	:= ALLTRIM( (cAliasSEE)->EE_CONTA )
Local cAgenAtu 	:= ALLTRIM( (cAliasSEE)->EE_AGENCIA )
Local nTamConta   := Len(cContAtu)
Local nTamAgencia := Len(cAgenAtu)
Local nDif 		:= 0
Local cStr 		:= ''
Local nCfgCta		:= Val( GetPvProfString(XMVPar11,"nCfgConta",'0', cArqCFG ) )//tamanho correto da conta
Local nCfgAgencia	:= Val( GetPvProfString(XMVPar11,"nCfgAgencia",'0', cArqCFG ) ) //tamanho correto da agencia
Local cRet			:= ''


If pTipo == 'C'
	nDif :=  nCfgCta	 - nTamConta

	If nDif > 0
		cStr := STRZERO(0, nDif)
		cRet := cStr + cContAtu
	Else
		cRet := cContAtu
	Endif
	
Else

	nDif :=  nCfgAgencia - nTamAgencia

	If nDif > 0
		cStr := STRZERO(0, nDif)
		cRet	:= cStr + cAgenAtu
	Else
		cRet := cAgenAtu
	Endif
Endif

If xMVPar11 == '237' //bradesco, formata a conta 999999-9 e agencia 9999-9

	If pTipo == 'A'
		cRet := cRet + '-' + (cAliasSEE)->EE_DVAGE 
	Endif
Endif

Return cRet

/*/{Protheus.doc} DadosSac
Monta Dados do sacado/cliente
@author Giane
@since 08/03/2016
@version 1.0
@param cArqCFG, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function DadosSac(cArqCFG)
Local aRet := {}
Local cCpo := GetPvProfString(XMVPar11,"cCfgNomCli",'A1_NOME', cArqCFG )	//se deve imprimir nome fantasia ou razao social

If  Empty(SA1->A1_ENDCOB)
	aRet := {  AllTrim( SA1->&cCpo )									,; // [1]Razão Social ou Nome Fantasia
				AllTrim(SA1->A1_COD ) + "-" + SA1->A1_LOJA           ,; // [2]Código
				AllTrim(SA1->A1_END ) + " " + Alltrim(SA1->A1_COMPLEM) + " " + IIf( !Empty(AllTrim(SA1->A1_BAIRRO)) ," - " + AllTrim(SA1->A1_BAIRRO),"") ,; // [3]Endereço
				AllTrim(SA1->A1_MUN )                                ,; // [4]Cidade
				SA1->A1_EST                                          ,; // [5]Estado
				SA1->A1_CEP                                          ,; // [6]CEP
				SA1->A1_CGC									         	,; // [7]CGC
				SA1->A1_PESSOA}	        								// [8]PESSOA
Else

	aRet := {  AllTrim( SA1->&cCpo )									,; // [1]Razão Social ou Nome Fantasia
				AllTrim(SA1->A1_COD ) + "-" + SA1->A1_LOJA           ,; // [2]Código
				AllTrim(SA1->A1_ENDCOB ) + " " + IIf( !Empty(AllTrim(SA1->A1_BAIRROC)) , "-" + AllTrim(SA1->A1_BAIRROC),""),; // [3]Endereço
				AllTrim(SA1->A1_MUNC )                                ,; // [4]Cidade
				SA1->A1_ESTC                                          ,; // [5]Estado
				SA1->A1_CEPC                                          ,; // [6]CEP
				SA1->A1_CGC									        	 ,; // [7]CGC
				SA1->A1_PESSOA}	        								// [8]PESSOA
Endif
Return aRet


/*/{Protheus.doc} MontaMsg
Monta as mensagens, verificando variaveis a serem substituidas
@author Giane
@since 08/03/2016
@version 1.0
@param cSecao, character, (Nome da secao no arquivo de configuracao de boletos)
@param cArqCFG, character, (Nome do arquivo de configuracao de boletos)
@param nVlrTit, numérico, (Valor do título com abatimentos)
@param oFont, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function MontaMsg(cSecao, cArqCFG, nVlrTit, oFont)
Local nLin := Val( GetPvProfString(cSecao,"nLinMensagem1",'0', cArqCFG ) ) //Linha que deve iniciar a impressao das mensagens
Local nCol := Val( GetPvProfString(cSecao,"nColMensagens",'0', cArqCFG ) ) //coluna que imprime todas as linhas de mensagens
Local nHLin := Val( GetPvProfString(cSecao,"nEspacoLinMens",'10', cArqCFG ) )
Local nPJuros := 0
Local nPMulta := 0
Local cVlrJuros := ''
Local cVlrMulta := ''
Local Nx := 0
Local cCpo := ''
Local cMensagem := ''

//pega os % de juros e multa informados para o banco, e ja calcula valor de juros e multa
nPJuros :=  GetPvProfString(cSecao,"nPercJuros",'0', cArqCFG )  //percentual de juros
nPMulta :=  GetPvProfString(cSecao,"nPercMulta",'0', cArqCFG )  //percentual de multa
cVlrJuros  := alltrim( TransForm( ((Val(nPJuros) * nVlrTit) / 100 ), "@E 9,999,999.99"))
cVlrMulta  := alltrim( TransForm( ((Val(nPMulta) * nVlrTit) / 100 ), "@E 9,999,999.99"))

If nLin > 0 .and. nCol > 0
	For Nx := 1 to 10        //10 eh fixo, o maximo de linhas de mensagens que poderia haver num boleto
		cCpo := "cMensagem" + Alltrim(Str(Nx))
		cMensagem := Alltrim( GetPvProfString(cSecao,cCpo,'', cArqCFG ) )
		If !Empty(cMensagem)

			//Verifica se existem variaveis de Juros e multa na mensagem, substitui pelos valores
			cMensagem := StrTran (cMensagem, "[nPercJuros]", nPJuros+"%")
			cMensagem := StrTran (cMensagem, "[nValJuros]", cVlrJuros)
			cMensagem := StrTran (cMensagem, "[nPercMulta]", nPMulta+"%")
			cMensagem := StrTran (cMensagem, "[nValMulta]", cVlrMulta)

			//verifica se existem campos do SE1 a serem impressos
			TransMsg(@cMensagem)

			//imprime a mensagem
			oPrinter:Say(nLin,nCol, cMensagem, oFont)
			nLin+= nHLin //soma a altura da linha, para a proxima mensagem
		Endif
	Next
Endif

Return

/*/{Protheus.doc} TransMsg
Esta função substitui o nome do campo da tabela SE1 pelo seu conteudo.
Para isto, colocar o nome do campo separado por "]" nas variaveis de  mensagens no arquivo TIBBOLETO.V01
Exemplo: cMensagem1=VENCIMENTO ORIGINAL ]E1_VENCTO]
Neste exemplo, o sistem ira substituir ]E1_VENCTO] pela data gravada no SE1->E1_VENCTO
@author Giane
@since 16/03/2016
@version 1.0
@param cMensagem, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function TransMsg(cMensagem)

Local aMsg		:= ''
Local nI		:= 0
Local cCpo		:= ''
Local cVlCpo	:= ''
Local cTipo	:= ''

aMsg := StrToKarr( cMensagem, "]")

For nI := 1 to len(aMsg)
	cCpo := Alltrim( aMsg[nI] )

	If Left(cCpo,3) == 'E1_'

		If SE1->(FieldPos(cCpo)) > 0
			cVlCpo := SE1->&cCpo
			cTipo := Valtype(cVlCpo)
			If cTipo == "D"
				cVlCpo := Dtoc(cVlCpo)
			ElseIf cTipo == "N"
				cVlCpo := Transform(cVlCpo,"@E 9,999,999.99")
			Endif
			cTipo := Valtype(cVlCpo)
			If cTipo == "C"
				cMensagem := StrTran (cMensagem, "]"+cCpo+"]", cVlCpo)
			Endif
		Endif

	Endif

Next

Return


/*/{Protheus.doc} Modulo10
Cálculo do Modulo 10, Fator 2 1
@author Giane
@since 08/03/2016
@version 1.0
@param cDado, character, (Sequencia numerica a ser calculado o digito)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function Modulo10(cDado)
Local cDIgit	:= ' ',cAux:=' '
Local nIndex	:= Len(cDado)
Local nFator	:= 1
Local nSoma	:= 0
Local nResto	:= 0
Local nTemp	:=0
Local cStrTemp:= ''
Local nAjud	:=0
Local lDois	:= .T.

Do While nIndex > 0
	cAux := substr(cDado,nIndex, 1)

	if lDois
		nFator:=2
		lDois := .F.
	else
		nFator:=1
		lDois := .T.
	endif

	nTemp := Val(cAux) * nFator
	cStrTemp := AllTrim(STR(nTemp))

	if nTemp < 10
		nSoma += nTemp
	endif

	if nTemp >= 10 .and. nTemp <= 99
		nAjud:= val( substr(cStrTemp,1,1)  )
		nSOma += nAjud
		nAjud:=val( substr(cStrTemp,2,1)  )
		nSOma += nAjud
	endif

	if nTemp > 100
		nAjud:=val( substr(cStrTemp,1,1)  )
		nSOma += nAjud
		nAjud:=val( substr(cStrTemp,2,1)  )
		nSOma += nAjud
		nAjud:=val( substr(cStrTemp,3,1)  )
		nSOma += nAjud
	endif


	nIndex -= 1
Enddo

nResto := (nSoma % 10)

cDigit := ALLTRIM( STR(10-nResto) )

if Val(cDigit) >= 10
	cDigit := '0'
endif

Return cDigit



/*/{Protheus.doc} Mod11B29
Cálculo do Modulo 11, Fator 2 ..a.. 9
@author Giane
@since 09/03/2016
@version 1.0
@param cData, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function Mod11B29(cData)
Local L := 0
Local D := 0
Local P := 0

L := Len(cdata)
D := 0
P := 1
While L > 0
	P := P + 1
	D := D + (Val(SubStr(cData, L, 1)) * P)
	If P = 9
		P := 1
	End
	L := L - 1
End
D := 11 - (mod(D,11))
If (D <= 1 .Or. D > 9)
	D := 1
End
Return(Str(D,1))

/*/{Protheus.doc} Mod11B92
Cálculo do Modulo 11, Fator 9 ..a.. 2
@author Giane
@since 11/03/2016
@version 1.0
@param cData, character, (String para calculo do DV)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function Mod11B92(cData)
Local L := 0
Local D := 0
Local P := 0

L := Len(cdata)
D := 0
P := 10
While L > 0
	P := P - 1
	D := D + (Val(SubStr(cData, L, 1)) * P)
	If P = 2
		P := 10
	End
	L := L - 1
End
D := mod(D,11)
If (D > 9 )
	D := P
End
Return(Str(D,1))

/*/{Protheus.doc} Mod1129E
Calculo DV modulo 11 base 2.. a 9, especifico para alguns bancos
@author Giane
@since 15/03/2016
@version 1.0
@param cNossNro, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function Mod1129E(cString,cTipo)

Local cDIgit	:= ' '
Local cAux		:=' '
Local nIndex	:= Len(cString)
Local nFator	:= 1
Local nSoma	:= 0
Local nResto	:= 0

Default cTipo := ''

while nIndex > 0
	cAux := substr(cString,nIndex, 1)
	nFator+=1

	if nFator > 9
		nFator:=2
	endif

	nSoma += Val(cAux) * nFator

	nIndex -= 1
End

nResto := (nSoma % 11)

cDigit := ' '

if nResto == 0
	cDigit := '1'
endif

If nResto == 1
	If Empty(cTipo)
		cDigit := '0'
	Else
		cDigit := cTipo
	Endif

Endif

if nResto != 1 .and. nResto != 0
	cDigit := Alltrim( Str(11-nResto) )
endif

return cDigit

/*/{Protheus.doc} CriaLog
(long_description)
@author Giane
@since 17/03/2016
@version 1.0
@param nHdlLog, numérico, (Numero do arquivo de Log criado)
@param cFileLog, character, (Nome do arquivo de logs)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function CriaLog(nHdlLog,cFileLog)
Local lRet 		:= .T.

If !ExistDir(GetSrvProfString("Startpath","") + "TIBBOLETO\LOG\")
	MontaDir(GetSrvProfString("Startpath","") + "TIBBOLETO\LOG\")
EndIf

nHdlLog  := MSFCreate(cFileLog,0)
If nHdlLog < 0
	Aviso('TIBBOLETO', 'PROBLEMAS NA CRIAÇÃO DO ARQUIVO DE LOG DE INCONSISTÊNCIAS!' + Chr(10) + Chr(13) + 'Código do erro: ' + StrZero(FError(),10), {'OK'}, 3)
	lRet := .F.
Else
	FWrite(nHdlLog, '[' + DtoC(Date()) + ' - ' + Time() + '] INICIANDO IMPRESSÃO DE BOLETOS' + Chr(13) + Chr(10))
Endif

Return lRet

/*/{Protheus.doc} ShowLog
Mostra Logs de impressao dos boletos
@author Giane
@since 17/03/2016
@version 1.0
@param cFileLog, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function ShowLog(cFileLog)

Local oDlg     := NIL
Local oFont    := NIL
Local cMemo    := ''
Local oMemo    := NIL

cMemo := MemoRead(cFileLog)
DEFINE FONT oFont NAME "Courier New" SIZE 5,0
DEFINE MSDIALOG oDlg TITLE 'LOG DE IMPRESSÃO DE BOLETOS' From 3,0 to 340,617 PIXEL
@ 5,5 GET oMemo  VAR cMemo MEMO SIZE 300,145 OF oDlg PIXEL

oMemo:bRClicked := {|| AllwaysTrue()}
oMemo:oFont:=oFont
DEFINE SBUTTON  FROM 153,280 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL //Apaga
ACTIVATE MSDIALOG oDlg CENTER

Return Nil

/*/{Protheus.doc} AjustaSX1
Perguntas necessarias ao filtro de impressao dos boletos
@author Giane
@since 03/03/2016
@version 1.0
@param cPerg, character, (Nome da pergunta no SX1)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function AjustaSX1(cPerg)
Local aHelp := {}

aHelp := {'Informe número inicial de Borderôs'}
PutSx1(cPerg, '01', 'Borderô De ?' , '', '', 'MV_CH1', 'C', TamSX3("E1_NUMBOR")[1], 0, 0,'G', 'NaoVazio()', '', '', '', 'MV_PAR01', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', aHelp, {}, {})

aHelp := {'Informe número final de Borderôs'}
PutSx1(cPerg, '02', 'Borderô Até ?' , '', '', 'MV_CH2', 'C', TamSX3("E1_NUMBOR")[1], 0, 0,'G', 'NaoVazio()', '', '', '', 'MV_PAR02', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', aHelp, {}, {})

aHelp := {'Informe prefixo inicial dos títulos'}
PutSx1(cPerg, '03', 'Prefixo De ?' , '', '', 'MV_CH3', 'C', TamSX3("E1_PREFIXO")[1], 0, 0,'G', '', '', '', '', 'MV_PAR03', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', aHelp, {}, {})

aHelp := {'Informe prefixo final dos títulos'}
PutSx1(cPerg, '04', 'Prefixo Ate ?' , '', '', 'MV_CH4', 'C', TamSX3("E1_PREFIXO")[1], 0, 0,'G', 'NaoVazio()', '', '', '', 'MV_PAR04', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', aHelp, {}, {})

aHelp := {'Informe numero do titulo inicial'}
PutSx1(cPerg, '05', 'Título De ?' , '', '', 'MV_CH5', 'C', TamSX3("E1_NUM")[1], 0, 0,'G', '', '', '', '', 'MV_PAR05', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', aHelp, {}, {})

aHelp := {'Informe numero do titulo final '}
PutSx1(cPerg, '06', 'Título Até ?' , '', '', 'MV_CH6', 'C', TamSX3("E1_NUM")[1], 0, 0,'G', 'NaoVazio()', '', '', '', 'MV_PAR06', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', aHelp, {}, {})

aHelp := {'Informe codigo inicial de cliente'}
PutSx1(cPerg, '07', 'Cliente De ?' , '', '', 'MV_CH7', 'C', TamSX3("E1_CLIENTE")[1], 0, 0,'G', '', 'SA1', '001', '', 'MV_PAR07', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', aHelp, {}, {})

aHelp := {'Informe codigo inicial da loja'}
PutSx1(cPerg, '08', 'Loja De ?' , '', '', 'MV_CH8', 'C', TamSX3("E1_LOJA")[1], 0, 0,'G', '', '', '002', '', 'MV_PAR08', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', aHelp, {}, {})

aHelp := {'Informe codigo fnal de cliente'}
PutSx1(cPerg, '09', 'Cliente Até ?' , '', '', 'MV_CH9', 'C', TamSX3("E1_CLIENTE")[1], 0, 0,'G', 'NaoVazio()', 'SA1', '001', '', 'MV_PAR09', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', aHelp, {}, {})

aHelp := {'Informe codigo final da loja'}
PutSx1(cPerg, '10', 'Loja Até ?' , '', '', 'MV_CHA', 'C', TamSX3("E1_LOJA")[1], 0, 0,'G', 'NaoVazio()', '', '002', '', 'MV_PAR10', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', aHelp, {}, {})

aHelp := {'Informe codigo do banco'}
PutSx1(cPerg, '11', 'Banco ?' , '', '', 'MV_CHB', 'C', TamSX3("E1_PORTADO")[1], 0, 0,'G', '', 'SA6', '007', '', 'MV_PAR11', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', aHelp, {}, {})

aHelp := {'Deseja visualizar/abrir os boletos','gerados?'}
PutSx1(cPerg, '12', 'Visualizar boletos?' , '', '', 'MV_CHC', 'N', 1, 0, 0,'C', '', '', '', '', 'MV_PAR12', 'Sim', 'Sim', 'Sim', '', 'Nao', 'Nao', 'Nao', '', '', '', '', '', '', '', '', '', aHelp, {}, {})

Return



STATIC Function GerarV01()

	Local cTexto := ""

	cTexto := "[001]"+CRLF
	cTexto += "cBolImg=bol001.jpg"+CRLF
	cTexto += "nCfgCodEmp=2"+CRLF
	cTexto += "nEmpNossoN1=7"+CRLF
	cTexto += "nCfgFxNossoN1=10"+CRLF
	cTexto += "nEmpNossoN2=6"+CRLF
	cTexto += "nCfgFxNossoN2=5"+CRLF
	cTexto += "nCfgAgencia=4"+CRLF
	cTexto += "nCfgConta=8"+CRLF
	cTexto += "cCfgNomCli=A1_NREDUZ"+CRLF
	cTexto += "cCodMoedaBarra=9"+CRLF
	cTexto += "dDtFatorVencto=07/10/1997"+CRLF
	cTexto += "cQuebraPDF=TITULO"+CRLF
	cTexto += "cNumTitulo=E1_PREFIXO,E1_NUM,E1_PARCELA"+CRLF
	cTexto += "cCfgParcela=NAO"+CRLF
	cTexto += ""+CRLF
	cTexto += "[001CABEC]"+CRLF
	cTexto += "nLinCedente=52"+CRLF
	cTexto += "nColCedente=39"+CRLF
	cTexto += "nTamCedente=30"+CRLF
	cTexto += "nLinNumTit=52"+CRLF
	cTexto += "nColNumTit=380"+CRLF
	cTexto += "nLinVencto=78"+CRLF
	cTexto += "nColVencto=272"+CRLF
	cTexto += "nLinAgCta=52"+CRLF
	cTexto += "nColAgCta=270"+CRLF
	cTexto += "nLinValTit=78"+CRLF
	cTexto += "nColValTit=390"+CRLF
	cTexto += "nLinNomSacado=78"+CRLF
	cTexto += "nColNomSacado=39"+CRLF
	cTexto += ""+CRLF
	cTexto += ""+CRLF
	cTexto += "[001PARTE1]"+CRLF
	cTexto += "nLinLinhaDigita=163"+CRLF
	cTexto += "nColLinhaDigita=210"+CRLF
	cTexto += "nLinCedente=202"+CRLF
	cTexto += "nColCedente=39"+CRLF
	cTexto += "nTamCedente=30"+CRLF
	cTexto += "nLinEndCedente=210"+CRLF
	cTexto += "ncolEndCedente=39"+CRLF
	cTexto += "nLinNossoN=224"+CRLF
	cTexto += "nColNossoN=450"+CRLF
	cTexto += "nLinVencto=180"+CRLF
	cTexto += "nColVencto=445"+CRLF
	cTexto += "nLinEmissao=224"+CRLF
	cTexto += "nColEmissao=50"+CRLF
	cTexto += "nLinNumTit=224"+CRLF
	cTexto += "nColNumTit=150"+CRLF
	cTexto += "nLinCNPJCedente=200"+CRLF
	cTexto += "nColCNPJCedente=325"+CRLF
	cTexto += "nLinCarteira=241"+CRLF
	cTexto += "nColCarteira=140"+CRLF
	cTexto += "cCodCarteira=0"+CRLF
	cTexto += "nLinAgCta=204"+CRLF
	cTexto += "nColAgCta=445"+CRLF
	cTexto += "cEspecieDoc=DM"+CRLF
	cTexto += "nLinEspecieDoc=224"+CRLF
	cTexto += "nColEspecieDoc=252"+CRLF
	cTexto += "cMoeda=R$"+CRLF
	cTexto += "nLinMoeda=241"+CRLF
	cTexto += "nColMoeda=200"+CRLF
	cTexto += "nLinValTit=239"+CRLF
	cTexto += "nColValTit=450"+CRLF
	cTexto += "cE1_DECRESC=S"+CRLF
	cTexto += "cE1_ACRESC=S"+CRLF
	cTexto += "nLinNomSacado=342"+CRLF
	cTexto += "nColNomSacado=45"+CRLF
	cTexto += "nLinCodSacado=0"+CRLF
	cTexto += "nColCodSacado=0"+CRLF
	cTexto += "nLinCNPJSacado=342"+CRLF
	cTexto += "nColCNPJSacado=400"+CRLF
	cTexto += "nLinEndSacado=351"+CRLF
	cTexto += "nColEndSacado=45"+CRLF
	cTexto += "nLinMunSacado=361"+CRLF
	cTexto += "nColMunSacado=45"+CRLF
	cTexto += "nLinMensagem1=258"+CRLF
	cTexto += "nColMensagens=45"+CRLF
	cTexto += "nEspacoLinMens=10"+CRLF
	cTexto += "nPercJuros=0"+CRLF
	cTexto += "nPercMulta=2"+CRLF
	cTexto += "cAceite=N"+CRLF
	cTexto += "nLinAceite=224"+CRLF
	cTexto += "nColAceite=325"+CRLF
	cTexto += "nLinDtMovto=224"+CRLF
	cTexto += "nColDtMovto=370"+CRLF
	cTexto += "cMensagem1=CALCULAR [nPercMulta] DE MULTA APÓS O VENCIMENTO"+CRLF
	cTexto += ""+CRLF
	cTexto += "[001PARTE2]"+CRLF
	cTexto += "nLinLinhaDigita=452"+CRLF
	cTexto += "nColLinhaDigita=210"+CRLF
	cTexto += "cLocalPagamento1=0"+CRLF
	cTexto += "cLocalPagamento2=0"+CRLF
	cTexto += "nLinLocalPagto1="+CRLF
	cTexto += "nColLocalPagto1=0"+CRLF
	cTexto += "nLinLocalPagto2=0"+CRLF
	cTexto += "nColLocalPagto2=0"+CRLF
	cTexto += "nLinVencto=472"+CRLF
	cTexto += "nColVencto=445"+CRLF
	cTexto += "nLinCedente=494"+CRLF
	cTexto += "nColCedente=39"+CRLF
	cTexto += "nLinCNPJCedente=494"+CRLF
	cTexto += "nColCNPJCedente=325"+CRLF
	cTexto += "nLinEndCedente=503"+CRLF
	cTexto += "ncolEndCedente=39"+CRLF
	cTexto += "nLinAgCta=494"+CRLF
	cTexto += "nColAgCta=445"+CRLF
	cTexto += "nLinEmissao=519"+CRLF
	cTexto += "nColEmissao=50"+CRLF
	cTexto += "nLinNumTit=519"+CRLF
	cTexto += "nColNumTit=150"+CRLF
	cTexto += "cEspecieDoc=DM"+CRLF
	cTexto += "nLinEspecieDoc=519"+CRLF
	cTexto += "nColEspecieDoc=252"+CRLF
	cTexto += "cAceite=N"+CRLF
	cTexto += "nLinAceite=519"+CRLF
	cTexto += "nColAceite=325"+CRLF
	cTexto += "nLinDtMovto=519"+CRLF
	cTexto += "nColDtMovto=370"+CRLF
	cTexto += "nLinNossoN=519"+CRLF
	cTexto += "nColNossoN=450"+CRLF
	cTexto += "nLinDtOperacao=0"+CRLF
	cTexto += "nColDtOperacao=0"+CRLF
	cTexto += "nLinCarteira=535"+CRLF
	cTexto += "nColCarteira=140"+CRLF
	cTexto += "cCodCarteira=0"+CRLF
	cTexto += "cMoeda=R$"+CRLF
	cTexto += "nLinMoeda=535"+CRLF
	cTexto += "nColMoeda=200"+CRLF
	cTexto += "nLinValTit=535"+CRLF
	cTexto += "nColValTit=450"+CRLF
	cTexto += "nPercJuros=0"+CRLF
	cTexto += "nPercMulta=2"+CRLF
	cTexto += "cMensagem1=CALCULAR [nPercMulta] DE MULTA APÓS O VENCIMENTO"+CRLF
	cTexto += "cMensagem2="+CRLF
	cTexto += "cMensagem3="+CRLF
	cTexto += "nLinMensagem1=550"+CRLF
	cTexto += "nColMensagens=45"+CRLF
	cTexto += "nEspacoLinMens=9"+CRLF
	cTexto += "nLinVlrCobrado=0"+CRLF
	cTexto += "nColVlrCobrado=0"+CRLF
	cTexto += "nLinCodSacado=630"+CRLF
	cTexto += "nColCodSacado=45"+CRLF
	cTexto += "nLinCNPJSacado=630"+CRLF
	cTexto += "nColCNPJSacado=400"+CRLF
	cTexto += "nLinEndSacado=640"+CRLF
	cTexto += "nColEndSacado=45"+CRLF
	cTexto += "nLinMunSacado=650"+CRLF
	cTexto += "nColMunSacado=45"+CRLF
	cTexto += "nLinCodBarra=56"+CRLF
	cTexto += "nColCodBarra=4"+CRLF
	cTexto += ""+CRLF
	cTexto += ""+CRLF
	cTexto += "[237]"+CRLF
	cTexto += "cBolImg=bol237.jpg"+CRLF
	cTexto += "nCfgCodEmp=0"+CRLF
	cTexto += "nCfgFxNossoN=11"+CRLF
	cTexto += "nCfgAgencia=4"+CRLF
	cTexto += "nCfgConta=7"+CRLF
	cTexto += "cCfgNomCli=CapitalAce(A1_NOME)"+CRLF
	cTexto += "cCodMoedaBarra=9"+CRLF
	cTexto += "dDtFatorVencto=07/10/1997"+CRLF
	cTexto += "cQuebraPDF=CLIENTE"+CRLF
	cTexto += "cNumTitulo=E1_NUM,E1_PARCELA"+CRLF
	cTexto += "cCfgParcela=SIM"+CRLF
	cTexto += "cCfgNossoN=8"+CRLF
	cTexto += ""+CRLF
	cTexto += "[237PARTE1]"+CRLF
	cTexto += "nLinLinhaDigita=45"+CRLF
	cTexto += "nColLinhaDigita=230"+CRLF
	cTexto += "nLinCedente=70"+CRLF
	cTexto += "nColCedente=45"+CRLF
	cTexto += "nTamCedente=30"+CRLF
	cTexto += "nLinEndCedente=0"+CRLF
	cTexto += "ncolEndCedente=0"+CRLF
	cTexto += "nLinNossoN=70"+CRLF
	cTexto += "nColNossoN=480"+CRLF
	cTexto += "nLinVencto=90"+CRLF
	cTexto += "nColVencto=320"+CRLF
	cTexto += "nLinEmissao=0"+CRLF
	cTexto += "nColEmissao=0"+CRLF
	cTexto += "nLinNumTit =90"+CRLF
	cTexto += "nColNumTit=45"+CRLF
	cTexto += "nLinCNPJCedente=90"+CRLF
	cTexto += "nColCNPJCedente=205"+CRLF
	cTexto += "nLinCarteira=0"+CRLF
	cTexto += "nColCarteira=0"+CRLF
	cTexto += "cCodCarteira=0"+CRLF
	cTexto += "nLinAgCta=70"+CRLF
	cTexto += "nColAgCta=290"+CRLF
	cTexto += "cEspecieDoc="+CRLF
	cTexto += "nLinEspecieDoc=0"+CRLF
	cTexto += "nColEspecieDoc=0"+CRLF
	cTexto += "cMoeda=R$"+CRLF
	cTexto += "nLinMoeda=70"+CRLF
	cTexto += "nColMoeda=400"+CRLF
	cTexto += "nLinValTit=90"+CRLF
	cTexto += "nColValTit=450"+CRLF
	cTexto += "cE1_DECRESC=S"+CRLF
	cTexto += "cE1_ACRESC=S"+CRLF
	cTexto += "nLinNomSacado=130"+CRLF
	cTexto += "nColNomSacado=45"+CRLF
	cTexto += "nLinCodSacado=0"+CRLF
	cTexto += "nColCodSacado=0"+CRLF
	cTexto += "nLinCNPJSacado=0"+CRLF
	cTexto += "nColCNPJSacado=0"+CRLF
	cTexto += "nLinEndSacado=0"+CRLF
	cTexto += "nColEndSacado=0"+CRLF
	cTexto += "nLinMunSacado=0"+CRLF
	cTexto += "nColMunSacado=0"+CRLF
	cTexto += "nLinMensagem1=0"+CRLF
	cTexto += "nColMensagens=0"+CRLF
	cTexto += "nEspacoLinMens=0"+CRLF
	cTexto += "nPercJuros=0.33"+CRLF
	cTexto += "nPercMulta=2.0"+CRLF
	cTexto += "cMensagem1=MORA DIA/COM. PERMANÊNCIA...  0.33 % AO DIA"+CRLF
	cTexto += "cMensagem2=APÓS VENCIMENTO COBRAR MULTA DE.... 2.00%"+CRLF
	cTexto += "cMensagem3=SUJEITO A PROTESTO APOS 5 DIAS DO VENCIMENTO"+CRLF
	cTexto += ""+CRLF
	cTexto += "[237PARTE2]"+CRLF
	cTexto += "nLinLinhaDigita=255"+CRLF
	cTexto += "nColLinhaDigita=230"+CRLF
	cTexto += "cLocalPagamento1=Pagável preferencialmente na rede Bradesco ou Bradesco Expresso."+CRLF
	cTexto += "cLocalPagamento2="+CRLF
	cTexto += "nLinLocalPagto1=280"+CRLF
	cTexto += "nColLocalPagto1=45"+CRLF
	cTexto += "nLinLocalPagto2=0"+CRLF
	cTexto += "nColLocalPagto2=0"+CRLF
	cTexto += "nLinVencto=280"+CRLF
	cTexto += "nColVencto=450"+CRLF
	cTexto += "nLinCedente=300"+CRLF
	cTexto += "nColCedente=45"+CRLF
	cTexto += "nLinCNPJCedente=0"+CRLF
	cTexto += "nColCNPJCedente=0"+CRLF
	cTexto += "nTamCedente=24"+CRLF
	cTexto += "nLinCNPJCedente=300"+CRLF
	cTexto += "nColCNPJCedente=170"+CRLF
	cTexto += "nLinEndCedente=300"+CRLF
	cTexto += "ncolEndCedente=250"+CRLF
	cTexto += "nLinAgCta=300"+CRLF
	cTexto += "nColAgCta=450"+CRLF
	cTexto += "nLinEmissao=320"+CRLF
	cTexto += "nColEmissao=45"+CRLF
	cTexto += "nLinNumTit =320"+CRLF
	cTexto += "nColNumTit=150"+CRLF
	cTexto += "cEspecieDoc=DM"+CRLF
	cTexto += "nLinEspecieDoc=320"+CRLF
	cTexto += "nColEspecieDoc=270"+CRLF
	cTexto += "cAceite=Não"+CRLF
	cTexto += "nLinAceite=320"+CRLF
	cTexto += "nColAceite=325"+CRLF
	cTexto += "nLinDtMovto=320"+CRLF
	cTexto += "nColDtMovto=360"+CRLF
	cTexto += "nLinNossoN=320"+CRLF
	cTexto += "nColNossoN=450"+CRLF
	cTexto += "nLinDtOperacao=0"+CRLF
	cTexto += "nColDtOperacao=0"+CRLF
	cTexto += "nLinCarteira=340"+CRLF
	cTexto += "nColCarteira=145"+CRLF
	cTexto += "cCodCarteira=0"+CRLF
	cTexto += "cMoeda=R$"+CRLF
	cTexto += "nLinMoeda=340"+CRLF
	cTexto += "nColMoeda=215"+CRLF
	cTexto += "nLinValTit=340"+CRLF
	cTexto += "nColValTit=480"+CRLF
	cTexto += "nPercJuros=0.33"+CRLF
	cTexto += "nPercMulta=2.0"+CRLF
	cTexto += "cMensagem1=Apos o vencimento cobrar Juros de 8% a.m."+CRLF
	cTexto += "cMensagem2=Após o vencimento cobrar Multa de 2% a.m."+CRLF
	cTexto += "cMensagem3=Sujeito a Protesto após 5 dias utéis."+CRLF
	cTexto += "nLinMensagem1=365"+CRLF
	cTexto += "nColMensagens=45"+CRLF
	cTexto += "nEspacoLinMens=10"+CRLF
	cTexto += "nLinVlrCobrado=0"+CRLF
	cTexto += "nColVlrCobrado=0"+CRLF
	cTexto += "nLinCodSacado=455"+CRLF
	cTexto += "nColCodSacado=45"+CRLF
	cTexto += "nLinCNPJSacado=455"+CRLF
	cTexto += "nColCNPJSacado=400"+CRLF
	cTexto += "nLinEndSacado=465"+CRLF
	cTexto += "nColEndSacado=45"+CRLF
	cTexto += "nLinMunSacado=475"+CRLF
	cTexto += "nColMunSacado=45"+CRLF
	cTexto += "nLinCodBarra=40"+CRLF
	cTexto += "nColCodBarra=4"+CRLF
	cTexto += ""+CRLF
	cTexto += ""+CRLF
	cTexto += ""+CRLF
	cTexto += ""+CRLF
	cTexto += "[341]"+CRLF
	cTexto += "cBolImg=bol341.jpg"+CRLF
	cTexto += "nCfgCodEmp=0"+CRLF
	cTexto += "nCfgFxNossoN=8"+CRLF
	cTexto += "nCfgAgencia=4"+CRLF
	cTexto += "nCfgConta=5"+CRLF
	cTexto += "cCfgNomCli=CapitalAce(A1_NOME)"+CRLF
	cTexto += "cCodMoedaBarra=9"+CRLF
	cTexto += "dDtFatorVencto=07/10/1997"+CRLF
	cTexto += "cQuebraPDF=TITULO"+CRLF
	cTexto += "cNumTitulo=E1_PREFIXO,E1_NUM,E1_PARCELA"+CRLF
	cTexto += "cCfgParcela=NAO"+CRLF
	cTexto += ""+CRLF
	cTexto += ""+CRLF
	cTexto += "[341PARTE1]"+CRLF
	cTexto += "nLinLinhaDigita=115"+CRLF
	cTexto += "nColLinhaDigita=197"+CRLF
	cTexto += "nLinCedente=137"+CRLF
	cTexto += "nColCedente=30"+CRLF
	cTexto += "nTamCedente=30"+CRLF
	cTexto += "nLinEndCedente=0"+CRLF
	cTexto += "ncolEndCedente=0"+CRLF
	cTexto += "nLinNossoN=137"+CRLF
	cTexto += "nColNossoN=500"+CRLF
	cTexto += "nLinVencto=176"+CRLF
	cTexto += "nColVencto=305"+CRLF
	cTexto += "nLinEmissao=0"+CRLF
	cTexto += "nColEmissao=0"+CRLF
	cTexto += "nLinNumTit =176"+CRLF
	cTexto += "nColNumTit=30"+CRLF
	cTexto += "nLinCNPJCedente=176"+CRLF
	cTexto += "nColCNPJCedente=188"+CRLF
	cTexto += "nLinCarteira=0"+CRLF
	cTexto += "nColCarteira=0"+CRLF
	cTexto += "cCodCarteira=0"+CRLF
	cTexto += "nLinAgCta=137"+CRLF
	cTexto += "nColAgCta=275"+CRLF
	cTexto += "cEspecieDoc="+CRLF
	cTexto += "nLinEspecieDoc=0"+CRLF
	cTexto += "nColEspecieDoc=0"+CRLF
	cTexto += "cMoeda=R$"+CRLF
	cTexto += "nLinMoeda=137"+CRLF
	cTexto += "nColMoeda=385"+CRLF
	cTexto += "nLinValTit=176"+CRLF
	cTexto += "nColValTit=505"+CRLF
	cTexto += "cE1_DECRESC=N"+CRLF
	cTexto += "cE1_ACRESC=N"+CRLF
	cTexto += "nLinNomSacado=215"+CRLF
	cTexto += "nColNomSacado=30"+CRLF
	cTexto += "nLinCodSacado=0"+CRLF
	cTexto += "nColCodSacado=0"+CRLF
	cTexto += "nLinCNPJSacado=0"+CRLF
	cTexto += "nColCNPJSacado=0"+CRLF
	cTexto += "nLinEndSacado=0"+CRLF
	cTexto += "nColEndSacado=0"+CRLF
	cTexto += "nLinMunSacado=0"+CRLF
	cTexto += "nColMunSacado=0"+CRLF
	cTexto += "nLinMensagem1=0"+CRLF
	cTexto += "nColMensagens=0"+CRLF
	cTexto += "nEspacoLinMens=0"+CRLF
	cTexto += "nPercJuros=0.002666"+CRLF
	cTexto += "nPercMulta=2.0"+CRLF
	cTexto += "cMensagem1=% AO DIA"+CRLF
	cTexto += "cMensagem2=APÓS VENCIMENTO COBRAR MULTA DE 2.00%"+CRLF
	cTexto += "cMensagem3=SUJEITO A PROTESTO APOS 5 DIAS UTEIS"+CRLF
	cTexto += ""+CRLF
	cTexto += ""+CRLF
	cTexto += "[341PARTE2]"+CRLF
	cTexto += "nPercJuros=0.002666"+CRLF
	cTexto += "nPercMulta=02.0"+CRLF
	cTexto += "nLinLinhaDigita=325"+CRLF
	cTexto += "nColLinhaDigita=197"+CRLF
	cTexto += "cLocalPagamento1=Pagável em qualquer banco até O vencimento e após O vencimento, somente no ITAÚ."+CRLF
	cTexto += "cLocalPagamento2="+CRLF
	cTexto += "nLinLocalPagto1=345"+CRLF
	cTexto += "nColLocalPagto1=30"+CRLF
	cTexto += "nLinLocalPagto2=0"+CRLF
	cTexto += "nColLocalPagto2=0"+CRLF
	cTexto += "nLinVencto=345"+CRLF
	cTexto += "nColVencto=510"+CRLF
	cTexto += "nLinCedente=365"+CRLF
	cTexto += "nColCedente=30"+CRLF
	cTexto += "nTamCedente=24"+CRLF
	cTexto += "nLinCNPJCedente=365"+CRLF
	cTexto += "nColCNPJCedente=150"+CRLF
	cTexto += "nLinEndCedente=365"+CRLF
	cTexto += "ncolEndCedente=235"+CRLF
	cTexto += "nLinAgCta=365"+CRLF
	cTexto += "nColAgCta=505"+CRLF
	cTexto += "nLinEmissao=385"+CRLF
	cTexto += "nColEmissao=30"+CRLF
	cTexto += "nLinNumTit =385"+CRLF
	cTexto += "nColNumTit=135"+CRLF
	cTexto += "cEspecieDoc=NF"+CRLF
	cTexto += "nLinEspecieDoc=385"+CRLF
	cTexto += "nColEspecieDoc=255"+CRLF
	cTexto += "cAceite=Não"+CRLF
	cTexto += "nLinAceite=385"+CRLF
	cTexto += "nColAceite=310"+CRLF
	cTexto += "nLinDtMovto=385"+CRLF
	cTexto += "nColDtMovto=345"+CRLF
	cTexto += "nLinNossoN=385"+CRLF
	cTexto += "nColNossoN=502"+CRLF
	cTexto += "nLinDtOperacao=0"+CRLF
	cTexto += "nColDtOperacao=0"+CRLF
	cTexto += "nLinCarteira=405"+CRLF
	cTexto += "nColCarteira=130"+CRLF
	cTexto += "cCodCarteira=0"+CRLF
	cTexto += "cMoeda=R$"+CRLF
	cTexto += "nLinMoeda=405"+CRLF
	cTexto += "nColMoeda=200"+CRLF
	cTexto += "nLinValTit=405"+CRLF
	cTexto += "nColValTit=508"+CRLF
	cTexto += "nPercJuros=0.002666"+CRLF
	cTexto += "nPercMulta=2.0"+CRLF
	cTexto += "cMensagem1=Apos o vencimento cobrar Juros de 8% a.m."+CRLF
	cTexto += "cMensagem2=Após o vencimento cobrar Multa de 2% a.m."+CRLF
	cTexto += "cMensagem3=Sujeito a Protesto após 5 dias utéis."+CRLF
	cTexto += "nLinMensagem1=430"+CRLF
	cTexto += "nColMensagens=30"+CRLF
	cTexto += "nEspacoLinMens=10"+CRLF
	cTexto += "nLinVlrCobrado=0"+CRLF
	cTexto += "nColVlrCobrado=0"+CRLF
	cTexto += "nLinCodSacado=523"+CRLF
	cTexto += "nColCodSacado=30"+CRLF
	cTexto += "nLinCNPJSacado=523"+CRLF
	cTexto += "nColCNPJSacado=400"+CRLF
	cTexto += "nLinEndSacado=533"+CRLF
	cTexto += "nColEndSacado=30"+CRLF
	cTexto += "nLinMunSacado=543"+CRLF
	cTexto += "nColMunSacado=30"+CRLF
	cTexto += "nLinCodBarra=46"+CRLF
	cTexto += "nColCodBarra=1"+CRLF
	cTexto += ""+CRLF
	cTexto += ""+CRLF
	cTexto += "[422]"+CRLF
	cTexto += "cBolImg=bol422.jpg"+CRLF
	cTexto += "nCfgCodEmp=0"+CRLF
	cTexto += "nCfgFxNossoN=8"+CRLF
	cTexto += "nCfgAgencia=5"+CRLF
	cTexto += "nCfgConta=9"+CRLF
	cTexto += "cCfgNomCli=A1_NOME"+CRLF
	cTexto += "cCodMoedaBarra=9"+CRLF
	cTexto += "dDtFatorVencto=07/10/1997"+CRLF
	cTexto += ""+CRLF
	cTexto += "[422PARTE1]"+CRLF
	cTexto += "nLinLinhaDigita=0"+CRLF
	cTexto += "nColLinhaDigita=0"+CRLF
	cTexto += "nLinCedente=60"+CRLF
	cTexto += "nColCedente=20"+CRLF
	cTexto += "nTamCedente=30"+CRLF
	cTexto += "nLinEndCedente=0"+CRLF
	cTexto += "ncolEndCedente=0"+CRLF
	cTexto += "nLinNossoN=60"+CRLF
	cTexto += "nColNossoN=360"+CRLF
	cTexto += "nLinVencto=60"+CRLF
	cTexto += "nColVencto=490"+CRLF
	cTexto += "nLinEmissao=80"+CRLF
	cTexto += "nColEmissao=20"+CRLF
	cTexto += "nLinNumTit =80"+CRLF
	cTexto += "nColNumTit=110"+CRLF
	cTexto += "nLinCarteira=80"+CRLF
	cTexto += "nColCarteira=320"+CRLF
	cTexto += "cCodCarteira=070"+CRLF
	cTexto += "nLinAgCta=80"+CRLF
	cTexto += "nColAgCta=360"+CRLF
	cTexto += "nLinValTit=80"+CRLF
	cTexto += "nColValTit=490"+CRLF
	cTexto += "cE1_DECRESC=N"+CRLF
	cTexto += "cE1_ACRESC=N"+CRLF
	cTexto += "nLinNomSacado=100"+CRLF
	cTexto += "nColNomSacado=20"+CRLF
	cTexto += "nLinCodSacado=120"+CRLF
	cTexto += "nColCodSacado=45"+CRLF
	cTexto += "nLinCNPJSacado=120"+CRLF
	cTexto += "nColCNPJSacado=360"+CRLF
	cTexto += "nLinEndSacado=130"+CRLF
	cTexto += "nColEndSacado=45"+CRLF
	cTexto += "nLinMunSacado=140"+CRLF
	cTexto += "nColMunSacado=45"+CRLF
	cTexto += "cMensagem1="+CRLF
	cTexto += "cMensagem2="+CRLF
	cTexto += "cMensagem3="+CRLF
	cTexto += "nLinMensagem1=150"+CRLF
	cTexto += "nColMensagens=45"+CRLF
	cTexto += "nEspacoLinMens=10"+CRLF
	cTexto += "nPercJuros=5"+CRLF
	cTexto += "nPercMulta=10"+CRLF
	cTexto += ""+CRLF
	cTexto += ""+CRLF
	cTexto += "[422PARTE2]"+CRLF
	cTexto += "nLinLinhaDigita=419"+CRLF
	cTexto += "nColLinhaDigita=193"+CRLF
	cTexto += "cLocalPagamento1=Até o vencimento pagável em qualquer banco"+CRLF
	cTexto += "cLocalPagamento2="+CRLF
	cTexto += "nLinLocalPagto1=439"+CRLF
	cTexto += "nColLocalPagto1=22"+CRLF
	cTexto += "nLinLocalPagto2=0"+CRLF
	cTexto += "nColLocalPagto2=0"+CRLF
	cTexto += "nLinVencto=439"+CRLF
	cTexto += "nColVencto=506"+CRLF
	cTexto += "nLinCedente=459"+CRLF
	cTexto += "nColCedente=22"+CRLF
	cTexto += "nLinAgCta=459"+CRLF
	cTexto += "nColAgCta=477"+CRLF
	cTexto += "nLinEmissao=479"+CRLF
	cTexto += "nColEmissao=22"+CRLF
	cTexto += "nLinNumTit =479"+CRLF
	cTexto += "nColNumTit=120"+CRLF
	cTexto += "cEspecieDoc=DM"+CRLF
	cTexto += "nLinEspecieDoc=479"+CRLF
	cTexto += "nColEspecieDoc=255"+CRLF
	cTexto += "cAceite=Não"+CRLF
	cTexto += "nLinAceite=479"+CRLF
	cTexto += "nColAceite=305"+CRLF
	cTexto += "nLinDtMovto=479"+CRLF
	cTexto += "nColDtMovto=350"+CRLF
	cTexto += "nLinNossoN=479"+CRLF
	cTexto += "nColNossoN=506"+CRLF
	cTexto += "nLinDtOperacao=498"+CRLF
	cTexto += "nColDtOperacao=22"+CRLF
	cTexto += "nLinCarteira=498"+CRLF
	cTexto += "nColCarteira=120"+CRLF
	cTexto += "cCodCarteira=070"+CRLF
	cTexto += "cMoeda=R$"+CRLF
	cTexto += "nLinMoeda=498"+CRLF
	cTexto += "nColMoeda=200"+CRLF
	cTexto += "nLinValTit=498"+CRLF
	cTexto += "nColValTit=505"+CRLF
	cTexto += "cMensagem1=NÃO RECEBER APÓS VENCIMENTO"+CRLF
	cTexto += "cMensagem2=VENCIMENTO ORIGINAL ]E1_VENCTO]"+CRLF
	cTexto += "cMensagem3="+CRLF
	cTexto += "nLinMensagem1=520"+CRLF
	cTexto += "nColMensagens=24"+CRLF
	cTexto += "nEspacoLinMens=10"+CRLF
	cTexto += "nLinVlrCobrado=597"+CRLF
	cTexto += "nColVlrCobrado=505"+CRLF
	cTexto += "nLinCodSacado=614"+CRLF
	cTexto += "nColCodSacado=24"+CRLF
	cTexto += "nLinCNPJSacado=614"+CRLF
	cTexto += "nColCNPJSacado=360"+CRLF
	cTexto += "nLinEndSacado=624"+CRLF
	cTexto += "nColEndSacado=24"+CRLF
	cTexto += "nLinMunSacado=634"+CRLF
	cTexto += "nColMunSacado=24"+CRLF
	cTexto += "nLinCodBarra=53"+CRLF
	cTexto += "nColCodBarra=2"+CRLF
	cTexto += ""+CRLF
	cTexto += "[033]"+CRLF
	cTexto += "cBolImg=bol033.jpg"+CRLF
	cTexto += "nCfgCodEmp=0"+CRLF
	cTexto += "nCfgFxNossoN=7"+CRLF
	cTexto += "nCfgAgencia=4"+CRLF
	cTexto += "nCfgConta=6"+CRLF
	cTexto += "cCfgNomCli=A1_NOME"+CRLF
	cTexto += "cCodMoedaBarra=9"+CRLF
	cTexto += "dDtFatorVencto=07/10/1997"+CRLF
	cTexto += ""+CRLF
	cTexto += "[033CABEC]"+CRLF
	cTexto += "nLinCedente=57"+CRLF
	cTexto += "nColCedente=39"+CRLF
	cTexto += "nTamCedente=30"+CRLF
	cTexto += "nLinNumTit=57"+CRLF
	cTexto += "nColNumTit=380"+CRLF
	cTexto += "nLinVencto=77"+CRLF
	cTexto += "nColVencto=270"+CRLF
	cTexto += "nLinAgCta=57"+CRLF
	cTexto += "nColAgCta=270"+CRLF
	cTexto += "nLinValTit=77"+CRLF
	cTexto += "nColValTit=390"+CRLF
	cTexto += "nLinNomSacado=77"+CRLF
	cTexto += "nColNomSacado=39"+CRLF
	cTexto += ""+CRLF
	cTexto += ""+CRLF
	cTexto += "[033PARTE1]"+CRLF
	cTexto += "nLinLinhaDigita=164"+CRLF
	cTexto += "nColLinhaDigita=210"+CRLF
	cTexto += "nLinCedente=204"+CRLF
	cTexto += "nColCedente=39"+CRLF
	cTexto += "nTamCedente=30"+CRLF
	cTexto += "nLinEndCedente=0"+CRLF
	cTexto += "ncolEndCedente=0"+CRLF
	cTexto += "nLinNossoN=224"+CRLF
	cTexto += "nColNossoN=450"+CRLF
	cTexto += "nLinVencto=180"+CRLF
	cTexto += "nColVencto=445"+CRLF
	cTexto += "nLinEmissao=226"+CRLF
	cTexto += "nColEmissao=50"+CRLF
	cTexto += "nLinNumTit=226"+CRLF
	cTexto += "nColNumTit=150"+CRLF
	cTexto += "nLinCNPJCedente=204"+CRLF
	cTexto += "nColCNPJCedente=325"+CRLF
	cTexto += "nLinCarteira=241"+CRLF
	cTexto += "nColCarteira=140"+CRLF
	cTexto += "cCodCarteira=0"+CRLF
	cTexto += "nLinAgCta=204"+CRLF
	cTexto += "nColAgCta=445"+CRLF
	cTexto += "cEspecieDoc=DM"+CRLF
	cTexto += "nLinEspecieDoc=225"+CRLF
	cTexto += "nColEspecieDoc=252"+CRLF
	cTexto += "cMoeda=R$"+CRLF
	cTexto += "nLinMoeda=241"+CRLF
	cTexto += "nColMoeda=200"+CRLF
	cTexto += "nLinValTit=239"+CRLF
	cTexto += "nColValTit=450"+CRLF
	cTexto += "cE1_DECRESC=N"+CRLF
	cTexto += "cE1_ACRESC=N"+CRLF
	cTexto += "nLinNomSacado=342"+CRLF
	cTexto += "nColNomSacado=43"+CRLF
	cTexto += "nLinCodSacado=0"+CRLF
	cTexto += "nColCodSacado=0"+CRLF
	cTexto += "nLinCNPJSacado=342"+CRLF
	cTexto += "nColCNPJSacado=400"+CRLF
	cTexto += "nLinEndSacado=352"+CRLF
	cTexto += "nColEndSacado=43"+CRLF
	cTexto += "nLinMunSacado=362"+CRLF
	cTexto += "nColMunSacado=43"+CRLF
	cTexto += "nLinMensagem1=258"+CRLF
	cTexto += "nColMensagens=45"+CRLF
	cTexto += "nEspacoLinMens=10"+CRLF
	cTexto += "nPercJuros=0"+CRLF
	cTexto += "nPercMulta=2.0"+CRLF
	cTexto += "cMensagem1=COBRAR MORA DIARIA DE [nValJuros]"+CRLF
	cTexto += "cMensagem2=COBRAR [nPercMulta] DE MULTA APÓS O VENCIMENTO"+CRLF
	cTexto += "cMensagem3=SUJEITO A PROTESTO APÓS VENCIMENTO"+CRLF
	cTexto += "cAceite=N"+CRLF
	cTexto += "nLinAceite=225"+CRLF
	cTexto += "nColAceite=325"+CRLF
	cTexto += "nLinDtMovto=225"+CRLF
	cTexto += "nColDtMovto=370"+CRLF
	cTexto += ""+CRLF
	cTexto += "[033PARTE2]"+CRLF
	cTexto += "nLinLinhaDigita=452"+CRLF
	cTexto += "nColLinhaDigita=210"+CRLF
	cTexto += "cLocalPagamento1=0"+CRLF
	cTexto += "cLocalPagamento2=0"+CRLF
	cTexto += "nLinLocalPagto1="+CRLF
	cTexto += "nColLocalPagto1=0"+CRLF
	cTexto += "nLinLocalPagto2=0"+CRLF
	cTexto += "nColLocalPagto2=0"+CRLF
	cTexto += "nLinVencto=472"+CRLF
	cTexto += "nColVencto=445"+CRLF
	cTexto += "nLinCedente=497"+CRLF
	cTexto += "nColCedente=39"+CRLF
	cTexto += "nLinCNPJCedente=497"+CRLF
	cTexto += "nColCNPJCedente=325"+CRLF
	cTexto += "nLinEndCedente=0"+CRLF
	cTexto += "ncolEndCedente=0"+CRLF
	cTexto += "nLinAgCta=497"+CRLF
	cTexto += "nColAgCta=445"+CRLF
	cTexto += "nLinEmissao=519"+CRLF
	cTexto += "nColEmissao=50"+CRLF
	cTexto += "nLinNumTit=519"+CRLF
	cTexto += "nColNumTit=150"+CRLF
	cTexto += "cEspecieDoc=DM"+CRLF
	cTexto += "nLinEspecieDoc=519"+CRLF
	cTexto += "nColEspecieDoc=252"+CRLF
	cTexto += "cAceite=N"+CRLF
	cTexto += "nLinAceite=519"+CRLF
	cTexto += "nColAceite=325"+CRLF
	cTexto += "nLinDtMovto=519"+CRLF
	cTexto += "nColDtMovto=370"+CRLF
	cTexto += "nLinNossoN=519"+CRLF
	cTexto += "nColNossoN=450"+CRLF
	cTexto += "nLinDtOperacao=0"+CRLF
	cTexto += "nColDtOperacao=0"+CRLF
	cTexto += "nLinCarteira=535"+CRLF
	cTexto += "nColCarteira=140"+CRLF
	cTexto += "cCodCarteira=0"+CRLF
	cTexto += "cMoeda=R$"+CRLF
	cTexto += "nLinMoeda=535"+CRLF
	cTexto += "nColMoeda=200"+CRLF
	cTexto += "nLinValTit=535"+CRLF
	cTexto += "nColValTit=450"+CRLF
	cTexto += "nPercJuros=0"+CRLF
	cTexto += "nPercMulta=2.0"+CRLF
	cTexto += "nLinMensagem1=553"+CRLF
	cTexto += "nColMensagens=45"+CRLF
	cTexto += "nEspacoLinMens=10"+CRLF
	cTexto += "cMensagem1=COBRAR MORA DIARIA DE [nValJuros]"+CRLF
	cTexto += "cMensagem2=COBRAR [nPercMulta] DE MULTA APÓS O VENCIMENTO"+CRLF
	cTexto += "cMensagem3=SUJEITO A PROTESTO APÓS VENCIMENTO"+CRLF
	cTexto += "nLinVlrCobrado=0"+CRLF
	cTexto += "nColVlrCobrado=0"+CRLF
	cTexto += "nLinNomSacado=633"+CRLF
	cTexto += "nColNomSacado=43"+CRLF
	cTexto += "nLinCodSacado=0"+CRLF
	cTexto += "nColCodSacado=0"+CRLF
	cTexto += "nLinCNPJSacado=632"+CRLF
	cTexto += "nColCNPJSacado=400"+CRLF
	cTexto += "nLinEndSacado=642"+CRLF
	cTexto += "nColEndSacado=43"+CRLF
	cTexto += "nLinMunSacado=652"+CRLF
	cTexto += "nColMunSacado=43"+CRLF
	cTexto += "nLinCodBarra=56"+CRLF
	cTexto += "nColCodBarra=4"+CRLF
	cTexto += ""+CRLF
	cTexto += "[399]"+CRLF
	cTexto += "cBolImg=bol399.jpg"+CRLF
	cTexto += "nCfgCodEmp=0"+CRLF
	cTexto += "nCfgFxNossoN=13"+CRLF
	cTexto += "nCfgAgencia=4"+CRLF
	cTexto += "nCfgConta=5"+CRLF
	cTexto += "cCfgNomCli=A1_NOME"+CRLF
	cTexto += "cCodMoedaBarra=9"+CRLF
	cTexto += "dDtFatorVencto=07/10/1997"+CRLF
	cTexto += ""+CRLF
	cTexto += ""+CRLF
	cTexto += "[399PARTE1]"+CRLF
	cTexto += "nLinLinhaDigita=33"+CRLF
	cTexto += "nColLinhaDigita=190"+CRLF
	cTexto += "cLocalPagamento1=PAGAR EM QUALQUER AGENCIA BANCARIA ATE O VENCIMENTO"+CRLF
	cTexto += "cLocalPagamento2=OU CANAIS ELETRONICOS DO HSBC"+CRLF
	cTexto += "nLinLocalPagto1=46"+CRLF
	cTexto += "nColLocalPagto1=84"+CRLF
	cTexto += "nLinLocalPagto2=54"+CRLF
	cTexto += "nColLocalPagto2=84"+CRLF
	cTexto += "nLinCedente=74"+CRLF
	cTexto += "nColCedente=21"+CRLF
	cTexto += "nTamCedente=30"+CRLF
	cTexto += "nLinEndCedente=87"+CRLF
	cTexto += "ncolEndCedente=21"+CRLF
	cTexto += "nLinMunCedente=97"+CRLF
	cTexto += "ncolMunCedente=21"+CRLF
	cTexto += "nLinNossoN=116"+CRLF
	cTexto += "nColNossoN=430"+CRLF
	cTexto += "nLinVencto=54"+CRLF
	cTexto += "nColVencto=460"+CRLF
	cTexto += "nLinEmissao=116"+CRLF
	cTexto += "nColEmissao=21"+CRLF
	cTexto += "nLinNumTit=116"+CRLF
	cTexto += "nColNumTit=76"+CRLF
	cTexto += "nLinCNPJCedente=74"+CRLF
	cTexto += "nColCNPJCedente=300"+CRLF
	cTexto += "nLinCarteira=131"+CRLF
	cTexto += "nColCarteira=76"+CRLF
	cTexto += "cCodCarteira=CNR"+CRLF
	cTexto += "nLinAgCta=75"+CRLF
	cTexto += "nColAgCta=441"+CRLF
	cTexto += "cEspecieDoc="+CRLF
	cTexto += "nLinEspecieDoc="+CRLF
	cTexto += "nColEspecieDoc="+CRLF
	cTexto += "cMoeda=REAL"+CRLF
	cTexto += "nLinMoeda=131"+CRLF
	cTexto += "nColMoeda=110"+CRLF
	cTexto += "nLinValTit=129"+CRLF
	cTexto += "nColValTit=452"+CRLF
	cTexto += "cE1_DECRESC=N"+CRLF
	cTexto += "cE1_ACRESC=N"+CRLF
	cTexto += "nLinNomSacado=244"+CRLF
	cTexto += "nColNomSacado=45"+CRLF
	cTexto += "nLinCodSacado=0"+CRLF
	cTexto += "nColCodSacado=0"+CRLF
	cTexto += "nLinCNPJSacado=244"+CRLF
	cTexto += "nColCNPJSacado=400"+CRLF
	cTexto += "nLinEndSacado=254"+CRLF
	cTexto += "nColEndSacado=45"+CRLF
	cTexto += "nLinMunSacado=264"+CRLF
	cTexto += "nColMunSacado=45"+CRLF
	cTexto += "nLinMensagem1=147"+CRLF
	cTexto += "nColMensagens=22"+CRLF
	cTexto += "nEspacoLinMens=10"+CRLF
	cTexto += "nPercJuros=0"+CRLF
	cTexto += "nPercMulta=0"+CRLF
	cTexto += "cAceite=NÃO"+CRLF
	cTexto += "nLinAceite=116"+CRLF
	cTexto += "nColAceite=210"+CRLF
	cTexto += "nLinDtMovto=116"+CRLF
	cTexto += "nColDtMovto=260"+CRLF
	cTexto += "cMensagem1="+CRLF
	cTexto += "nLinCodBarra=25"+CRLF
	cTexto += "nColCodBarra=2"+CRLF
	cTexto += ""+CRLF
	cTexto += "[399PARTE2]"+CRLF
	cTexto += "nLinLinhaDigita=385"+CRLF
	cTexto += "nColLinhaDigita=196"+CRLF
	cTexto += "cLocalPagamento1=PAGAR EM QUALQUER AGENCIA BANCARIA ATE O VENCIMENTO"+CRLF
	cTexto += "cLocalPagamento2=OU CANAIS ELETRONICOS DO HSBC"+CRLF
	cTexto += "nLinLocalPagto1=400"+CRLF
	cTexto += "nColLocalPagto1=84"+CRLF
	cTexto += "nLinLocalPagto2=410"+CRLF
	cTexto += "nColLocalPagto2=84"+CRLF
	cTexto += "nLinVencto=406"+CRLF
	cTexto += "nColVencto=460"+CRLF
	cTexto += "nLinCedente=426"+CRLF
	cTexto += "nColCedente=23"+CRLF
	cTexto += "nLinCNPJCedente=426"+CRLF
	cTexto += "nColCNPJCedente=300"+CRLF
	cTexto += "nLinEndCedente=438"+CRLF
	cTexto += "ncolEndCedente=23"+CRLF
	cTexto += "nLinMunCedente=448"+CRLF
	cTexto += "ncolMunCedente=23"+CRLF
	cTexto += "nLinAgCta=426"+CRLF
	cTexto += "nColAgCta=440"+CRLF
	cTexto += "nLinEmissao=468"+CRLF
	cTexto += "nColEmissao=23"+CRLF
	cTexto += "nLinNumTit=468"+CRLF
	cTexto += "nColNumTit=77"+CRLF
	cTexto += "cEspecieDoc="+CRLF
	cTexto += "nLinEspecieDoc="+CRLF
	cTexto += "nColEspecieDoc="+CRLF
	cTexto += "cAceite=NAO"+CRLF
	cTexto += "nLinAceite=468"+CRLF
	cTexto += "nColAceite=210"+CRLF
	cTexto += "nLinDtMovto=468"+CRLF
	cTexto += "nColDtMovto=260"+CRLF
	cTexto += "nLinNossoN=468"+CRLF
	cTexto += "nColNossoN=430"+CRLF
	cTexto += "nLinDtOperacao=0"+CRLF
	cTexto += "nColDtOperacao=0"+CRLF
	cTexto += "nLinCarteira=484"+CRLF
	cTexto += "nColCarteira=77"+CRLF
	cTexto += "cCodCarteira=CNR"+CRLF
	cTexto += "cMoeda=REAL"+CRLF
	cTexto += "nLinMoeda=484"+CRLF
	cTexto += "nColMoeda=112"+CRLF
	cTexto += "nLinValTit=481"+CRLF
	cTexto += "nColValTit=452"+CRLF
	cTexto += "cMensagem1="+CRLF
	cTexto += "cMensagem2="+CRLF
	cTexto += "cMensagem3="+CRLF
	cTexto += "nLinMensagem1=499"+CRLF
	cTexto += "nColMensagens=22"+CRLF
	cTexto += "nEspacoLinMens=10"+CRLF
	cTexto += "nLinVlrCobrado=0"+CRLF
	cTexto += "nColVlrCobrado=0"+CRLF
	cTexto += "nLinNomSacado=596"+CRLF
	cTexto += "nColNomSacado=45"+CRLF
	cTexto += "nLinCodSacado=0"+CRLF
	cTexto += "nColCodSacado=0"+CRLF
	cTexto += "nLinCNPJSacado=596"+CRLF
	cTexto += "nColCNPJSacado=400"+CRLF
	cTexto += "nLinEndSacado=606"+CRLF
	cTexto += "nColEndSacado=45"+CRLF
	cTexto += "nLinMunSacado=616"+CRLF
	cTexto += "nColMunSacado=45"+CRLF
	cTexto += "nLinCodBarra=54"+CRLF
	cTexto += "nColCodBarra=1"+CRLF
	cTexto += ""+CRLF
	cTexto += "[104]"+CRLF
	cTexto += "cBolImg=bol104.jpg"+CRLF
	cTexto += "nCfgCodEmp=0"+CRLF
	cTexto += "nCfgFxNossoN=15"+CRLF
	cTexto += "nCfgAgencia=4"+CRLF
	cTexto += "nCfgConta=6"+CRLF
	cTexto += "cCfgNomCli=CapitalAce(A1_NOME)"+CRLF
	cTexto += "cCodMoedaBarra=9"+CRLF
	cTexto += "dDtFatorVencto=07/10/1997"+CRLF
	cTexto += "cQuebraPDF=TITULO"+CRLF
	cTexto += ""+CRLF
	cTexto += "[104PARTE1]"+CRLF
	cTexto += "nLinLinhaDigita=33"+CRLF
	cTexto += "nColLinhaDigita=190"+CRLF
	cTexto += "cLocalPagamento1=PAGAR PREFERENCIALMENTE EM AGENCIA CEF"+CRLF
	cTexto += "cLocalPagamento2="+CRLF
	cTexto += "nLinLocalPagto1=53"+CRLF
	cTexto += "nColLocalPagto1=21"+CRLF
	cTexto += "nLinLocalPagto2="+CRLF
	cTexto += "nColLocalPagto2="+CRLF
	cTexto += "nLinCedente=74"+CRLF
	cTexto += "nColCedente=21"+CRLF
	cTexto += "nTamCedente=30"+CRLF
	cTexto += "nLinEndCedente=87"+CRLF
	cTexto += "ncolEndCedente=21"+CRLF
	cTexto += "nLinMunCedente=97"+CRLF
	cTexto += "ncolMunCedente=21"+CRLF
	cTexto += "nLinNossoN=116"+CRLF
	cTexto += "nColNossoN=430"+CRLF
	cTexto += "nLinVencto=53"+CRLF
	cTexto += "nColVencto=460"+CRLF
	cTexto += "nLinEmissao=116"+CRLF
	cTexto += "nColEmissao=23"+CRLF
	cTexto += "nLinNumTit=116"+CRLF
	cTexto += "nColNumTit=75"+CRLF
	cTexto += "nLinCNPJCedente=74"+CRLF
	cTexto += "nColCNPJCedente=300"+CRLF
	cTexto += "nLinCarteira=133"+CRLF
	cTexto += "nColCarteira=76"+CRLF
	cTexto += "cCodCarteira=RG"+CRLF
	cTexto += "nLinAgCta=74"+CRLF
	cTexto += "nColAgCta=462"+CRLF
	cTexto += "cEspecieDoc="+CRLF
	cTexto += "nLinEspecieDoc="+CRLF
	cTexto += "nColEspecieDoc="+CRLF
	cTexto += "cMoeda=RS"+CRLF
	cTexto += "nLinMoeda=133"+CRLF
	cTexto += "nColMoeda=120"+CRLF
	cTexto += "nLinValTit=133"+CRLF
	cTexto += "nColValTit=452"+CRLF
	cTexto += "cE1_DECRESC=N"+CRLF
	cTexto += "cE1_ACRESC=N"+CRLF
	cTexto += "nLinNomSacado=244"+CRLF
	cTexto += "nColNomSacado=23"+CRLF
	cTexto += "nLinCodSacado=0"+CRLF
	cTexto += "nColCodSacado=0"+CRLF
	cTexto += "nLinCNPJSacado=244"+CRLF
	cTexto += "nColCNPJSacado=400"+CRLF
	cTexto += "nLinEndSacado=254"+CRLF
	cTexto += "nColEndSacado=23"+CRLF
	cTexto += "nLinMunSacado=264"+CRLF
	cTexto += "nColMunSacado=23"+CRLF
	cTexto += "nLinMensagem1=147"+CRLF
	cTexto += "nColMensagens=22"+CRLF
	cTexto += "nEspacoLinMens=10"+CRLF
	cTexto += "cAceite=N"+CRLF
	cTexto += "nLinAceite=116"+CRLF
	cTexto += "nColAceite=210"+CRLF
	cTexto += "nLinDtMovto=116"+CRLF
	cTexto += "nColDtMovto=250"+CRLF
	cTexto += "nPercJuros=0.33"+CRLF
	cTexto += "nPercMulta=2.00"+CRLF
	cTexto += "cMensagem1=MORA JUROS DE 0.33% R$: [nValJuros] AO DIA "+CRLF
	cTexto += "cMensagem2=MULTA DE 2.00% R$: [nValMulta] APÓS ]E1_VENCTO]"+CRLF
	cTexto += "cMensagem3="+CRLF
	cTexto += "nLinCodBarra=25"+CRLF
	cTexto += "nColCodBarra=4"+CRLF
	cTexto += ""+CRLF
	cTexto += "[104PARTE2]"+CRLF
	cTexto += "nLinLinhaDigita=385"+CRLF
	cTexto += "nColLinhaDigita=196"+CRLF
	cTexto += "cLocalPagamento1=PAGAR PREFERENCIALMENTE EM AGENCIA CEF"+CRLF
	cTexto += "cLocalPagamento2="+CRLF
	cTexto += "nLinLocalPagto1=405"+CRLF
	cTexto += "nColLocalPagto1=21"+CRLF
	cTexto += "nLinLocalPagto2="+CRLF
	cTexto += "nColLocalPagto2="+CRLF
	cTexto += "nLinVencto=405"+CRLF
	cTexto += "nColVencto=460"+CRLF
	cTexto += "nLinCedente=426"+CRLF
	cTexto += "nColCedente=23"+CRLF
	cTexto += "nLinCNPJCedente=426"+CRLF
	cTexto += "nColCNPJCedente=300"+CRLF
	cTexto += "nLinEndCedente=439"+CRLF
	cTexto += "ncolEndCedente=23"+CRLF
	cTexto += "nLinMunCedente=448"+CRLF
	cTexto += "ncolMunCedente=23"+CRLF
	cTexto += "nLinAgCta=426"+CRLF
	cTexto += "nColAgCta=440"+CRLF
	cTexto += "nLinEmissao=468"+CRLF
	cTexto += "nColEmissao=24"+CRLF
	cTexto += "nLinNumTit=468"+CRLF
	cTexto += "nColNumTit=76"+CRLF
	cTexto += "cEspecieDoc="+CRLF
	cTexto += "nLinEspecieDoc="+CRLF
	cTexto += "nColEspecieDoc="+CRLF
	cTexto += "cAceite=N"+CRLF
	cTexto += "nLinAceite=468"+CRLF
	cTexto += "nColAceite=210"+CRLF
	cTexto += "nLinDtMovto=468"+CRLF
	cTexto += "nColDtMovto=250"+CRLF
	cTexto += "nLinNossoN=468"+CRLF
	cTexto += "nColNossoN=430"+CRLF
	cTexto += "nLinDtOperacao=0"+CRLF
	cTexto += "nColDtOperacao=0"+CRLF
	cTexto += "nLinCarteira=485"+CRLF
	cTexto += "nColCarteira=76"+CRLF
	cTexto += "cCodCarteira=RG"+CRLF
	cTexto += "cMoeda=R$"+CRLF
	cTexto += "nLinMoeda=485"+CRLF
	cTexto += "nColMoeda=120"+CRLF
	cTexto += "nLinValTit=485"+CRLF
	cTexto += "nColValTit=452"+CRLF
	cTexto += "nPercJuros=0.33"+CRLF
	cTexto += "nPercMulta=2.00"+CRLF
	cTexto += "cMensagem1=MORA JUROS DE 0.33% R$: [nValJuros] AO DIA "+CRLF
	cTexto += "cMensagem2=MULTA DE 2.00% R$: [nValMulta] APÓS ]E1_VENCTO]"+CRLF
	cTexto += "cMensagem3="+CRLF
	cTexto += "nLinMensagem1=499"+CRLF
	cTexto += "nColMensagens=22"+CRLF
	cTexto += "nEspacoLinMens=10"+CRLF
	cTexto += "nLinVlrCobrado=0"+CRLF
	cTexto += "nColVlrCobrado=0"+CRLF
	cTexto += "nLinNomSacado=596"+CRLF
	cTexto += "nColNomSacado=23"+CRLF
	cTexto += "nLinCodSacado=0"+CRLF
	cTexto += "nColCodSacado=0"+CRLF
	cTexto += "nLinCNPJSacado=596"+CRLF
	cTexto += "nColCNPJSacado=400"+CRLF
	cTexto += "nLinEndSacado=606"+CRLF
	cTexto += "nColEndSacado=23"+CRLF
	cTexto += "nLinMunSacado=616"+CRLF
	cTexto += "nColMunSacado=23"+CRLF
	cTexto += "nLinCodBarra=54"+CRLF
	cTexto += "nColCodBarra=4"+CRLF
	cTexto += ""+CRLF
	cTexto += "[021]"+CRLF
	cTexto += "cBolImg=bol021.jpg"+CRLF
	cTexto += "nCfgCodEmp=0"+CRLF
	cTexto += "nCfgFxNossoN=8"+CRLF
	cTexto += "nCfgAgencia=4"+CRLF
	cTexto += "nCfgConta=11"+CRLF
	cTexto += "cCfgNomCli=A1_NOME"+CRLF
	cTexto += "cCodMoedaBarra=9"+CRLF
	cTexto += "dDtFatorVencto=07/10/1997"+CRLF
	cTexto += "cTipoCobranca=2"+CRLF
	cTexto += ""+CRLF
	cTexto += "[021CABEC]"+CRLF
	cTexto += "nLinLinhaDigita=33"+CRLF
	cTexto += "nColLinhaDigita=190"+CRLF
	cTexto += "nLinCedente=53"+CRLF
	cTexto += "nColCedente=24"+CRLF
	cTexto += "nTamCedente=30"+CRLF
	cTexto += "nLinNossoN=74"+CRLF
	cTexto += "nColNossoN=280"+CRLF
	cTexto += "nLinVencto=95"+CRLF
	cTexto += "nColVencto=25"+CRLF
	cTexto += "nLinNumTit=95"+CRLF
	cTexto += "nColNumTit=100"+CRLF
	cTexto += "nLinAgCta=53"+CRLF
	cTexto += "nColAgCta=270"+CRLF
	cTexto += "cEspecieDoc=DUPLICATA"+CRLF
	cTexto += "nLinEspecieDoc=95"+CRLF
	cTexto += "nColEspecieDoc=180"+CRLF
	cTexto += "nLinValTit=95"+CRLF
	cTexto += "nColValTit=290"+CRLF
	cTexto += "nLinNomSacado=74"+CRLF
	cTexto += "nColNomSacado=24"+CRLF
	cTexto += ""+CRLF
	cTexto += "[021PARTE1]"+CRLF
	cTexto += "nLinLinhaDigita=149"+CRLF
	cTexto += "nColLinhaDigita=190"+CRLF
	cTexto += "cLocalPagamento1=PAGAR PREFERENCIALMENTE NA REDE BANESTES"+CRLF
	cTexto += "cLocalPagamento2="+CRLF
	cTexto += "nLinLocalPagto1=169"+CRLF
	cTexto += "nColLocalPagto1=23"+CRLF
	cTexto += "nLinLocalPagto2="+CRLF
	cTexto += "nColLocalPagto2="+CRLF
	cTexto += "nLinCedente=190"+CRLF
	cTexto += "nColCedente=23"+CRLF
	cTexto += "nTamCedente=30"+CRLF
	cTexto += "nLinEndCedente="+CRLF
	cTexto += "ncolEndCedente="+CRLF
	cTexto += "nLinMunCedente="+CRLF
	cTexto += "ncolMunCedente="+CRLF
	cTexto += "nLinNossoN=210"+CRLF
	cTexto += "nColNossoN=490"+CRLF
	cTexto += "nLinVencto=169"+CRLF
	cTexto += "nColVencto=490"+CRLF
	cTexto += "nLinEmissao=210"+CRLF
	cTexto += "nColEmissao=23"+CRLF
	cTexto += "nLinNumTit=210"+CRLF
	cTexto += "nColNumTit=79"+CRLF
	cTexto += "nLinCNPJCedente=190"+CRLF
	cTexto += "nColCNPJCedente=300"+CRLF
	cTexto += "nLinCarteira=227"+CRLF
	cTexto += "nColCarteira=85"+CRLF
	cTexto += "cCodCarteira="+CRLF
	cTexto += "nLinAgCta=190"+CRLF
	cTexto += "nColAgCta=460"+CRLF
	cTexto += "cEspecieDoc=Duplicata"+CRLF
	cTexto += "nLinEspecieDoc=210"+CRLF
	cTexto += "nColEspecieDoc=163"+CRLF
	cTexto += "cMoeda=R$"+CRLF
	cTexto += "nLinMoeda=227"+CRLF
	cTexto += "nColMoeda=115"+CRLF
	cTexto += "nLinValTit=227"+CRLF
	cTexto += "nColValTit=482"+CRLF
	cTexto += "cE1_DECRESC=N"+CRLF
	cTexto += "cE1_ACRESC=N"+CRLF
	cTexto += "nLinNomSacado=356"+CRLF
	cTexto += "nColNomSacado=30"+CRLF
	cTexto += "nLinCodSacado=0"+CRLF
	cTexto += "nColCodSacado=0"+CRLF
	cTexto += "nLinCNPJSacado=356"+CRLF
	cTexto += "nColCNPJSacado=400"+CRLF
	cTexto += "nLinEndSacado=371"+CRLF
	cTexto += "nColEndSacado=30"+CRLF
	cTexto += "nLinMunSacado=381"+CRLF
	cTexto += "nColMunSacado=30"+CRLF
	cTexto += "nLinMensagem1=248"+CRLF
	cTexto += "nColMensagens=22"+CRLF
	cTexto += "nEspacoLinMens=10"+CRLF
	cTexto += "nPercJuros=0"+CRLF
	cTexto += "nPercMulta=0"+CRLF
	cTexto += "cAceite=A"+CRLF
	cTexto += "nLinAceite=210"+CRLF
	cTexto += "nColAceite=215"+CRLF
	cTexto += "nLinDtMovto=210"+CRLF
	cTexto += "nColDtMovto=250"+CRLF
	cTexto += "cMensagem1="+CRLF
	cTexto += "nLinCodBarra=34"+CRLF
	cTexto += "nColCodBarra=4"+CRLF
	cTexto += "nLinVlrCobrado=325"+CRLF
	cTexto += "nColVlrCobrado=485"+CRLF
	cTexto += "cCpoCustom1=U_CDIASBACE"+CRLF
	cTexto += "nLinCpoCustom1=325"+CRLF
	cTexto += "nColCpoCustom1=40"+CRLF
	cTexto += ""+CRLF
	cTexto += "[021PARTE2]"+CRLF
	cTexto += "nLinLinhaDigita=476"+CRLF
	cTexto += "nColLinhaDigita=196"+CRLF
	cTexto += "cLocalPagamento1=PAGAR PREFERENCIALMENTE NA REDE BANESTES"+CRLF
	cTexto += "cLocalPagamento2="+CRLF
	cTexto += "nLinLocalPagto1=496"+CRLF
	cTexto += "nColLocalPagto1=25"+CRLF
	cTexto += "nLinLocalPagto2="+CRLF
	cTexto += "nColLocalPagto2="+CRLF
	cTexto += "nLinVencto=496"+CRLF
	cTexto += "nColVencto=490"+CRLF
	cTexto += "nLinCedente=517"+CRLF
	cTexto += "nColCedente=25"+CRLF
	cTexto += "nLinCNPJCedente=517"+CRLF
	cTexto += "nColCNPJCedente=300"+CRLF
	cTexto += "nLinEndCedente="+CRLF
	cTexto += "ncolEndCedente="+CRLF
	cTexto += "nLinMunCedente="+CRLF
	cTexto += "ncolMunCedente="+CRLF
	cTexto += "nLinAgCta=517"+CRLF
	cTexto += "nColAgCta=460"+CRLF
	cTexto += "nLinEmissao=536"+CRLF
	cTexto += "nColEmissao=25"+CRLF
	cTexto += "nLinNumTit=536"+CRLF
	cTexto += "nColNumTit=79"+CRLF
	cTexto += "cEspecieDoc=Duplicata"+CRLF
	cTexto += "nLinEspecieDoc=536"+CRLF
	cTexto += "nColEspecieDoc=166"+CRLF
	cTexto += "cAceite=A"+CRLF
	cTexto += "nLinAceite=536"+CRLF
	cTexto += "nColAceite=215"+CRLF
	cTexto += "nLinDtMovto=536"+CRLF
	cTexto += "nColDtMovto=250"+CRLF
	cTexto += "nLinNossoN=536"+CRLF
	cTexto += "nColNossoN=490"+CRLF
	cTexto += "nLinDtOperacao=0"+CRLF
	cTexto += "nColDtOperacao=0"+CRLF
	cTexto += "nLinCarteira=557"+CRLF
	cTexto += "nColCarteira=90"+CRLF
	cTexto += "cCodCarteira="+CRLF
	cTexto += "cMoeda=R$"+CRLF
	cTexto += "nLinMoeda=557"+CRLF
	cTexto += "nColMoeda=115"+CRLF
	cTexto += "nLinValTit=557"+CRLF
	cTexto += "nColValTit=482"+CRLF
	cTexto += "cMensagem1="+CRLF
	cTexto += "cMensagem2="+CRLF
	cTexto += "cMensagem3="+CRLF
	cTexto += "nLinMensagem1=575"+CRLF
	cTexto += "nColMensagens=22"+CRLF
	cTexto += "nEspacoLinMens=10"+CRLF
	cTexto += "nLinVlrCobrado=655"+CRLF
	cTexto += "nColVlrCobrado=485"+CRLF
	cTexto += "nLinNomSacado=683"+CRLF
	cTexto += "nColNomSacado=30"+CRLF
	cTexto += "nLinCodSacado=0"+CRLF
	cTexto += "nColCodSacado=0"+CRLF
	cTexto += "nLinCNPJSacado=683"+CRLF
	cTexto += "nColCNPJSacado=400"+CRLF
	cTexto += "nLinEndSacado=698"+CRLF
	cTexto += "nColEndSacado=30"+CRLF
	cTexto += "nLinMunSacado=713"+CRLF
	cTexto += "nColMunSacado=30"+CRLF
	cTexto += "nLinCodBarra=61"+CRLF
	cTexto += "nColCodBarra=4"+CRLF
	cTexto += "cCpoCustom1=U_CDIASBACE"+CRLF
	cTexto += "nLinCpoCustom1=655"+CRLF
	cTexto += "nColCpoCustom1=40"+CRLF
	cTexto += ""+CRLF
	cTexto += "[633]"+CRLF
	cTexto += "cBolImg=bol237.jpg"+CRLF
	cTexto += "nCfgCodEmp=0"+CRLF
	cTexto += "nCfgFxNossoN=12"+CRLF
	cTexto += "nCfgAgencia=4"+CRLF
	cTexto += "nCfgConta=7"+CRLF
	cTexto += "cCfgNomCli=A1_NOME"+CRLF
	cTexto += "cCodMoedaBarra=9"+CRLF
	cTexto += "dDtFatorVencto=07/10/1997"+CRLF
	cTexto += ""+CRLF
	cTexto += "[633PARTE1]"+CRLF
	cTexto += "nLinLinhaDigita=45"+CRLF
	cTexto += "nColLinhaDigita=230"+CRLF
	cTexto += "nLinCedente=70"+CRLF
	cTexto += "nColCedente=45"+CRLF
	cTexto += "nTamCedente=30"+CRLF
	cTexto += "nLinEndCedente=0"+CRLF
	cTexto += "ncolEndCedente=0"+CRLF
	cTexto += "nLinNossoN=70"+CRLF
	cTexto += "nColNossoN=480"+CRLF
	cTexto += "nLinVencto=90"+CRLF
	cTexto += "nColVencto=320"+CRLF
	cTexto += "nLinEmissao=0"+CRLF
	cTexto += "nColEmissao=0"+CRLF
	cTexto += "nLinNumTit =90"+CRLF
	cTexto += "nColNumTit=45"+CRLF
	cTexto += "nLinCNPJCedente=90"+CRLF
	cTexto += "nColCNPJCedente=205"+CRLF
	cTexto += "nLinCarteira=0"+CRLF
	cTexto += "nColCarteira=0"+CRLF
	cTexto += "cCodCarteira=0"+CRLF
	cTexto += "nLinAgCta=70"+CRLF
	cTexto += "nColAgCta=290"+CRLF
	cTexto += "cEspecieDoc="+CRLF
	cTexto += "nLinEspecieDoc=0"+CRLF
	cTexto += "nColEspecieDoc=0"+CRLF
	cTexto += "cMoeda=R$"+CRLF
	cTexto += "nLinMoeda=70"+CRLF
	cTexto += "nColMoeda=400"+CRLF
	cTexto += "nLinValTit=90"+CRLF
	cTexto += "nColValTit=450"+CRLF
	cTexto += "cE1_DECRESC=S"+CRLF
	cTexto += "cE1_ACRESC=S"+CRLF
	cTexto += "nLinNomSacado=130"+CRLF
	cTexto += "nColNomSacado=45"+CRLF
	cTexto += "nLinCodSacado=0"+CRLF
	cTexto += "nColCodSacado=0"+CRLF
	cTexto += "nLinCNPJSacado=0"+CRLF
	cTexto += "nColCNPJSacado=0"+CRLF
	cTexto += "nLinEndSacado=0"+CRLF
	cTexto += "nColEndSacado=0"+CRLF
	cTexto += "nLinMunSacado=0"+CRLF
	cTexto += "nColMunSacado=0"+CRLF
	cTexto += "nLinMensagem1=0"+CRLF
	cTexto += "nColMensagens=0"+CRLF
	cTexto += "nEspacoLinMens=0"+CRLF
	cTexto += "nPercJuros=0"+CRLF
	cTexto += "nPercMulta=0"+CRLF
	cTexto += ""+CRLF
	cTexto += "[633PARTE2]"+CRLF
	cTexto += "nLinLinhaDigita=255"+CRLF
	cTexto += "nColLinhaDigita=230"+CRLF
	cTexto += "cLocalPagamento1=Pagável em qualquer banco até o vencimento."+CRLF
	cTexto += "cLocalPagamento2="+CRLF
	cTexto += "nLinLocalPagto1=280"+CRLF
	cTexto += "nColLocalPagto1=45"+CRLF
	cTexto += "nLinLocalPagto2=0"+CRLF
	cTexto += "nColLocalPagto2=0"+CRLF
	cTexto += "nLinVencto=280"+CRLF
	cTexto += "nColVencto=450"+CRLF
	cTexto += "nLinCedente=300"+CRLF
	cTexto += "nColCedente=45"+CRLF
	cTexto += "nLinCNPJCedente=0"+CRLF
	cTexto += "nColCNPJCedente=0"+CRLF
	cTexto += "nLinAgCta=300"+CRLF
	cTexto += "nColAgCta=450"+CRLF
	cTexto += "nLinEmissao=320"+CRLF
	cTexto += "nColEmissao=45"+CRLF
	cTexto += "nLinNumTit =320"+CRLF
	cTexto += "nColNumTit=150"+CRLF
	cTexto += "cEspecieDoc=NF"+CRLF
	cTexto += "nLinEspecieDoc=320"+CRLF
	cTexto += "nColEspecieDoc=270"+CRLF
	cTexto += "cAceite=Não"+CRLF
	cTexto += "nLinAceite=320"+CRLF
	cTexto += "nColAceite=325"+CRLF
	cTexto += "nLinDtMovto=320"+CRLF
	cTexto += "nColDtMovto=360"+CRLF
	cTexto += "nLinNossoN=320"+CRLF
	cTexto += "nColNossoN=450"+CRLF
	cTexto += "nLinDtOperacao=0"+CRLF
	cTexto += "nColDtOperacao=0"+CRLF
	cTexto += "nLinCarteira=340"+CRLF
	cTexto += "nColCarteira=145"+CRLF
	cTexto += "cCodCarteira=0"+CRLF
	cTexto += "cMoeda=R$"+CRLF
	cTexto += "nLinMoeda=340"+CRLF
	cTexto += "nColMoeda=215"+CRLF
	cTexto += "nLinValTit=340"+CRLF
	cTexto += "nColValTit=480"+CRLF
	cTexto += "cMensagem1="+CRLF
	cTexto += "cMensagem2="+CRLF
	cTexto += "cMensagem3="+CRLF
	cTexto += "nLinMensagem1=365"+CRLF
	cTexto += "nColMensagens=45"+CRLF
	cTexto += "nEspacoLinMens=10"+CRLF
	cTexto += "nLinVlrCobrado=0"+CRLF
	cTexto += "nColVlrCobrado=0"+CRLF
	cTexto += "nLinCodSacado=455"+CRLF
	cTexto += "nColCodSacado=45"+CRLF
	cTexto += "nLinCNPJSacado=455"+CRLF
	cTexto += "nColCNPJSacado=400"+CRLF
	cTexto += "nLinEndSacado=465"+CRLF
	cTexto += "nColEndSacado=45"+CRLF
	cTexto += "nLinMunSacado=475"+CRLF
	cTexto += "nColMunSacado=45"+CRLF
	cTexto += "nLinCodBarra=40"+CRLF
	cTexto += "nColCodBarra=4"+CRLF
	cTexto += "cNomSacador=BANCO RENDIMENTO S.A."+CRLF
	cTexto += "nLinSacador=486"+CRLF
	cTexto += "nColSacador=100"+CRLF
	cTexto += ""+CRLF
	cTexto += "[090]"+CRLF
	cTexto += "cBolImg=bol090.jpg"+CRLF
	cTexto += "nCfgCodEmp=0"+CRLF
	cTexto += "nCfgFxNossoN=8"+CRLF
	cTexto += "nCfgAgencia=4"+CRLF
	cTexto += "nCfgConta=6"+CRLF
	cTexto += "cCfgNomCli=A1_NOME"+CRLF
	cTexto += "cCodMoedaBarra=9"+CRLF
	cTexto += "dDtFatorVencto=07/10/1997"+CRLF
	cTexto += "cQuebraPDF=TITULO"+CRLF
	cTexto += "cNumTitulo=E1_PREFIXO,E1_NUM,E1_PARCELA"+CRLF
	cTexto += "cCfgParcela=NAO"+CRLF
	cTexto += ""+CRLF
	cTexto += "[090CABEC]"+CRLF
	cTexto += "nLinCedente=88"+CRLF
	cTexto += "nColCedente=41"+CRLF
	cTexto += "nTamCedente=30"+CRLF
	cTexto += "nLinEndCedente=101"+CRLF
	cTexto += "ncolEndCedente=75"+CRLF
	cTexto += "nLinLinhaDigita=40"+CRLF
	cTexto += "nColLinhaDigita=170"+CRLF
	cTexto += "nLinVencto=65"+CRLF
	cTexto += "nColVencto=470"+CRLF
	cTexto += "nLinCNPJCedente=79"+CRLF
	cTexto += "nColCNPJCedente=355"+CRLF
	cTexto += "nLinAgCta=104"+CRLF
	cTexto += "nColAgCta=470"+CRLF
	cTexto += ""+CRLF
	cTexto += "[090PARTE1]"+CRLF
	cTexto += "nLinEmissao=132"+CRLF
	cTexto += "nColEmissao=52"+CRLF
	cTexto += "nLinNumTit=132"+CRLF
	cTexto += "nColNumTit=176"+CRLF
	cTexto += "cEspecieDoc=DM"+CRLF
	cTexto += "nLinEspecieDoc=132"+CRLF
	cTexto += "nColEspecieDoc=256"+CRLF
	cTexto += "cAceite=NAO"+CRLF
	cTexto += "nLinAceite=132"+CRLF
	cTexto += "nColAceite=310"+CRLF
	cTexto += "nLinDtMovto=132"+CRLF
	cTexto += "nColDtMovto=355"+CRLF
	cTexto += "nLinNossoN=132"+CRLF
	cTexto += "nColNossoN=470"+CRLF
	cTexto += "nLinCarteira=158"+CRLF
	cTexto += "nColCarteira=170"+CRLF
	cTexto += "cMoeda=R$"+CRLF
	cTexto += "nLinMoeda=158"+CRLF
	cTexto += "nColMoeda=206"+CRLF
	cTexto += "nLinValTit=158"+CRLF
	cTexto += "nColValTit=470"+CRLF
	cTexto += "nLinMensagem1=183"+CRLF
	cTexto += "nColMensagens=41"+CRLF
	cTexto += "nEspacoLinMens=10"+CRLF
	cTexto += "nPercJuros=0"+CRLF
	cTexto += "nPercMulta=2.0"+CRLF
	cTexto += "cMensagem1=DEPOSITO EM CONTA NÃO QUITA O BOLETO"+CRLF
	cTexto += "cMensagem2=PROTESTO AUTOMÁTICO APÓS 10 DIAS DE VENCIMENTO"+CRLF
	cTexto += "cE1_DECRESC=N"+CRLF
	cTexto += "cE1_ACRESC=N"+CRLF
	cTexto += "nLinNomSacado=302"+CRLF
	cTexto += "nColNomSacado=104"+CRLF
	cTexto += "nLinCodSacado="+CRLF
	cTexto += "nColCodSacado="+CRLF
	cTexto += "nLinCNPJSacado=302"+CRLF
	cTexto += "nColCNPJSacado=367"+CRLF
	cTexto += "nLinEndSacado=312"+CRLF
	cTexto += "nColEndSacado=104"+CRLF
	cTexto += "nLinMunSacado=322"+CRLF
	cTexto += "nColMunSacado=104"+CRLF
	cTexto += "nLinCedente=335"+CRLF
	cTexto += "nColCedente=104"+CRLF
	cTexto += "nTamCedente=30"+CRLF
	cTexto += "nLinCNPJCedente=335"+CRLF
	cTexto += "nColCNPJCedente=367"+CRLF
	cTexto += "nLinEndCedente=345"+CRLF
	cTexto += "ncolEndCedente=104"+CRLF
	cTexto += ""+CRLF
	cTexto += "[090PARTE2]"+CRLF
	cTexto += "nLinLinhaDigita=462"+CRLF
	cTexto += "nColLinhaDigita=170"+CRLF
	cTexto += "nLinVencto=483"+CRLF
	cTexto += "nColVencto=470"+CRLF
	cTexto += "nLinCedente=503"+CRLF
	cTexto += "nColCedente=41"+CRLF
	cTexto += "nTamCedente=30"+CRLF
	cTexto += "nLinCNPJCedente=494"+CRLF
	cTexto += "nColCNPJCedente=355"+CRLF
	cTexto += "nLinAgCta=519"+CRLF
	cTexto += "nColAgCta=470"+CRLF
	cTexto += "nLinEndCedente=517"+CRLF
	cTexto += "ncolEndCedente=75"+CRLF
	cTexto += "nLinEmissao=543"+CRLF
	cTexto += "nColEmissao=52"+CRLF
	cTexto += "nLinNumTit=543"+CRLF
	cTexto += "nColNumTit=176"+CRLF
	cTexto += "cEspecieDoc=DM"+CRLF
	cTexto += "nLinEspecieDoc=543"+CRLF
	cTexto += "nColEspecieDoc=256"+CRLF
	cTexto += "cAceite=NAO"+CRLF
	cTexto += "nLinAceite=543"+CRLF
	cTexto += "nColAceite=310"+CRLF
	cTexto += "nLinDtMovto=543"+CRLF
	cTexto += "nColDtMovto=355"+CRLF
	cTexto += "nLinNossoN=543"+CRLF
	cTexto += "nColNossoN=470"+CRLF
	cTexto += "nLinCarteira=565"+CRLF
	cTexto += "nColCarteira=170"+CRLF
	cTexto += "cMoeda=R$"+CRLF
	cTexto += "nLinMoeda=565"+CRLF
	cTexto += "nColMoeda=206"+CRLF
	cTexto += "nLinValTit=565"+CRLF
	cTexto += "nColValTit=470"+CRLF
	cTexto += "nLinMensagem1=588"+CRLF
	cTexto += "nColMensagens=41"+CRLF
	cTexto += "nEspacoLinMens=10"+CRLF
	cTexto += "nPercJuros=0"+CRLF
	cTexto += "nPercMulta=2.0"+CRLF
	cTexto += "cMensagem1=DEPOSITO EM CONTA NÃO QUITA O BOLETO"+CRLF
	cTexto += "cMensagem2=PROTESTO AUTOMÁTICO APÓS 10 DIAS DE VENCIMENTO"+CRLF
	cTexto += "cE1_DECRESC=N"+CRLF
	cTexto += "cE1_ACRESC=N"+CRLF
	cTexto += "nLinNomSacado=700"+CRLF
	cTexto += "nColNomSacado=114"+CRLF
	cTexto += "nLinCodSacado="+CRLF
	cTexto += "nColCodSacado="+CRLF
	cTexto += "nLinCNPJSacado=700"+CRLF
	cTexto += "nColCNPJSacado=410"+CRLF
	cTexto += "nLinEndSacado=710"+CRLF
	cTexto += "nColEndSacado=114"+CRLF
	cTexto += "nLinMunSacado=720"+CRLF
	cTexto += "nColMunSacado=114"+CRLF
	cTexto += "nLinCedente=734"+CRLF
	cTexto += "nColCedente=114"+CRLF
	cTexto += "nTamCedente=30"+CRLF
	cTexto += "nLinCodBarra=61"+CRLF
	cTexto += "nColCodBarra=4"+CRLF

Return cTexto

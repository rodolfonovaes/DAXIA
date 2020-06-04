#Include "Protheus.ch"
#INCLUDE 'APVT100.CH'
#INCLUDE 'WMSV001.CH'

#DEFINE WMSV00101 "WMSV00101"
#DEFINE WMSV00102 "WMSV00102"
#DEFINE WMSV00103 "WMSV00103"
#DEFINE WMSV00104 "WMSV00104"
#DEFINE WMSV00105 "WMSV00105"
#DEFINE WMSV00106 "WMSV00106"
#DEFINE WMSV00107 "WMSV00107"
#DEFINE WMSV00109 "WMSV00109"
#DEFINE WMSV00110 "WMSV00110"
#DEFINE WMSV00111 "WMSV00111"
#DEFINE WMSV00112 "WMSV00112"
#DEFINE WMSV00113 "WMSV00113"
#DEFINE WMSV00114 "WMSV00114"
#DEFINE WMSV00115 "WMSV00115"
#DEFINE WMSV00116 "WMSV00116"
#DEFINE WMSV00117 "WMSV00117"
#DEFINE WMSV00118 "WMSV00118"
#DEFINE WMSV00119 "WMSV00119"
#DEFINE WMSV00120 "WMSV00120"
#DEFINE WMSV00121 "WMSV00121"
#DEFINE WMSV00122 "WMSV00122"
#DEFINE WMSV00123 "WMSV00123"
#DEFINE WMSV00124 "WMSV00124"
#DEFINE WMSV00125 "WMSV00125"
#DEFINE WMSV00126 "WMSV00126"
#DEFINE WMSV00127 "WMSV00127"
#DEFINE WMSV00128 "WMSV00128"

Static __cFuncOpe := ""
Static __nRecPula := 0
Static lWMSCONV   := ExistBlock("WMSCONV")
Static lWMSV001MS := ExistBlock("WMSV001MS")
Static lWMSV001G  := ExistBlock("WMSV001G")
Static lWV001SCR  := ExistBlock("WV001SCR")


//------------------------------------------------------------
/*/{Protheus.doc} WMSV001
Identifica as funcoes do operador logado na radio frequencia
@author Alex Egydio
@since 18/09/2000
@version 1.0
/*/
//------------------------------------------------------------
User Function WMSV001U()

Local aTelaAnt     := {}
Local cSeekDCI     := ''
Local nX           := 0
Local nKey         := 0
Local cHelice      := ''
Local cHora        := ''
Local cAmPm        := STR0001  // am
Local cClock       := ''
Local lRadioF      := (SuperGetMV('MV_RADIOF', .F., 'N')=='S')
Local lSleep       := (SuperGetMV('MV_RFSLEEP', .F., 0)>0)
Local lSleeping    := .F.
Local nTimeIni     := 0
Local nIdle        := 0
Local nTimeSleep   := (SuperGetMV('MV_RFSLEEP', .F., 0)*60) // Tempo em MINUTOS para que o terminal comece a hibernar (Default=0)
Local nOrdemFunc   := 0
Local cUsuArma     := CriaVar('BE_LOCAL',.F.)
Local cUsuZona     := CriaVar('BE_CODZON',.F.)
Local cDescFunc    := ''
Local cMsgSem      := ''
Local dDataFec     := DToS(WmsData())
Local lRetPE       := .F.
Local nTipoConv    := SuperGetMV('MV_TPCONVO', .F., 1) // 1=Por Atividade/2=Por Tarefa
Local lPergFunc    := SuperGetMV('MV_WMSFUNC', .F., .F.) // Pergunta Função
Local lPrimFunc    := SuperGetMV('MV_WMSPFUN', .F., .F.) // Retorna busca sempre para primeira função do operador

Local cInternet    := ''

Private cReinAuto  := SuperGetMV('MV_REINAUT', .F., 'N') // Indica se permite convocar atividade com problemas/ Interrompida
Private lReinAuto  := (cReinAuto == 'S')
Private lPergAuto  := .F.
Private aFuncoesWMS:= {}
Private nIdleWake  := SuperGetMV('MV_RFIDLEW', .F., 1000) // Intervalo de tempo em MILISEGUNDOS em que o sistema ficara em PAUSA no modo ACORDADO (Default=1000)
Private nIdleSleep := SuperGetMV('MV_RFIDLES', .F., 5000) // Intervalo de tempo em MILISEGUNDOS em que o sistema ficara em PAUSA no modo HIBERNANDO (Default=5000)

Private oRegraConv := WMSBCCRegraConvocacao():New()
//Private oMovimento := WMSBCCMovimentoServico():New()
Private oMovimento := DAXWMSMovimentoServico():New() //RODOLFO 
Private oServico   := WMSDTCServicoTarefa():New()
Private cAntEndOri := "" // Para salvar o endereço origem anterior, para não solicitar novamente enquanto forem iguais
Public _aSeparaca := {}
Public _aCapacid  := {}

	If !SuperGetMV("MV_WMSNEW", .F., .F.)
		Return DLGV001()
	EndIf

	If Type("__cInterNet") <> "U"
		cInternet := __cInterNet
	EndIf
	__cInterNet := "AUTOMATICO"
	__nRecPula  := 0

	// Pesquisa quais funcoes o usuario exerce
	DCD->(DbSetOrder(1)) // DCD_FILIAL+DCD_CODFUN
	If DCD->(MsSeek(xFilial('DCD')+__cUserID, .F.))
		If DCD->DCD_STATUS == '3' // Recurso humano ausente
			WmsMessage(WmsFmtMsg(STR0002,{{"[VAR01]",CUSERNAME}}),WMSV00101) // Usuário [VAR01] informado como recurso humano ausente.
			Return Nil
		EndIf
	Else
		WmsMessage(WmsFmtMsg(STR0003,{{"[VAR01]",CUSERNAME}}),WMSV00102) // Usuário [VAR01] não cadastrado como recurso humano.
		Return Nil
	EndIf
	// Pesquisa quais funcoes o usuario exerce
	DCI->(DbSetOrder(1)) // DCI_FILIAL+DCI_CODFUN+STR(DCI_ORDFUN,2)+DCI_FUNCAO
	If DCI->(MsSeek(cSeekDCI:=xFilial('DCI')+__cUserID, .F.))
		While !DCI->(Eof()) .And. DCI->DCI_FILIAL+DCI->DCI_CODFUN == cSeekDCI .And. !Empty(DCI->DCI_FUNCAO)
			nOrdemFunc ++
			cDescFunc := Posicione("SRJ",1,xFilial("SRJ")+DCI->DCI_FUNCAO,"RJ_DESC")
			AAdd(aFuncoesWMS, {nOrdemFunc, DCI->DCI_FUNCAO, cDescFunc})
			DCI->(DbSkip())
		EndDo
	EndIf
	// Verifica se há funções
	If Len(aFuncoesWMS) == 0
		WmsMessage(WmsFmtMsg(STR0004,{{"[VAR01]",CUSERNAME}}),WMSV00103) // Usuario [VAR01] sem Funcoes Cadastradas... // Atencao
		Return Nil
	EndIf

	If SuperGetMV('MV_RFINFAZ', .F., 'S')=='S'
		// Solicita que o usuario informe sua localizacao
		WMSVTCabec(STR0005, .F., .F., .T.)   // Sua Localizacao?
		@ 02, 00 VTSay PadR(STR0006, VTMaxCol())  // Armazem'
		@ 03, 00 VTGet cUsuArma Valid ChkVldArm(cUsuArma) F3 'NNR'
		@ 05, 00 VTSay PadR(STR0007, VTMaxCol())  // Zona de Armazenagem
		@ 06, 00 VTGet cUsuZona Valid ChkVldZon(cUsuZona) F3 'DC4'
		VTRead
		If VTLastKey() == 27
			Return Nil
		EndIf
	EndIf
	// Atualiza a coluna "Rotina" do VTMONITOR
	cMsgSem := "WMSV001 - ["+ WmsFmtMsg(STR0030,{{"[VAR01]",If( Empty(cUsuArma),'??',cUsuArma )}}) // A [VAR01]"
	cMsgSem += WmsFmtMsg(STR0031,{{"[VAR01]",If( Empty(cUsuZona),'??????',cUsuZona )}}) // Z [VAR01]"
	cMsgSem += STR0032+"]" // Aguardando...
	VTAtuSem('SIGAACD', cMsgSem)

	// Inicializa variaveis utilizadas no While
	cClock   := 'SIGAWMS'
	cHelice  := ' '
	nTimeIni := Seconds() + nTimeSleep
	nIdle    := nIdleWake
	// Cria as temporárias da unitização - FORA DA TRANSAÇÃO
	WMSCTPENDU()
	// Cria tabela temporária da execução automática - FORA DA TRANSAÇÃO
	WMSCTPRGCV()
	// Atribui a Funcao de Funcoes a Combinacao de Teclas <CTRL> + <U>
	VTSetKey(21,{||DispFuncWMS(aFuncoesWMS)},STR0008)  // Funcoes Atrib.      '
	// Atribui a Funcao de DATA & HORA a Combinacao de Teclas <CTRL> + <D>
	VTSetKey(4, {||CtrlClock()}  ,STR0009) // Data/Hora'

	WMSVTCabec(AllTrim(CUSERNAME), .F., .F., .T.)
	@ Int(VTMaxRow()/2)  , 00 VtSay STR0011   // Aguarde Convocacao'
	If !Empty(cUsuArma) .Or. !Empty(cUsuZona)
		@ Int(VTMaxRow()/2)+1, 00 VtSay PadC('('+;
					WmsFmtMsg(STR0030,{{"[VAR01]",If(!Empty(cUsuArma),cUsuArma,'')}})+;
					If(!Empty(cUsuArma).And.!Empty(cUsuZona), ' ', '')+;
					WmsFmtMsg(STR0031,{{"[VAR01]",If(!Empty(cUsuZona),cUsuZona,'')}})+;
					')', VTMaxCol(), ' ')// A'#'Z'
	Else
		@ Int(VTMaxRow()/2)+1, 00 VtSay Space(VTMaxCol()) // Precisa desta linha a mais para correta montagem da tela
	EndIf
	WMSVTRodPe(cClock, .F.)
	// Looping para Aguarde de Convocacao
	Do While .T.
		Sleep(nIdle)
		VTLoadMsgMonit()
		// PE para exibir mensagens no coletor/RF
		If lWMSCONV
			lRetPE := ExecBlock("WMSCONV",.F.,.F.,{__cUserID})
			lRetPE := (If(ValType(lRetPE)=='L',lRetPE,.F.))
			If lRetPE
				Exit // Finaliza convocacao
			EndIf
		EndIf
		// Verifica se existe Convocacao para as funcoes do Usuario
		For nX := 1 To Len(aFuncoesWMS)
			If lPergFunc
				TrocarFunc(aFuncoesWMS)
				If VTLastKey() == 27
					__nOpcESC := 1 // FLAG de Abandono
					Exit
				EndIf
			Else
				__cFuncOpe := aFuncoesWMS[nX, 2]
			EndIf

			Do While Convocacao(__cFuncOpe, lRadioF, __cUserID, cUsuArma, cUsuZona, nTipoConv, dDataFec)
				If __nOpcESC == 1 // Abandono
					Exit
				EndIf
				nTimeIni := Seconds() + nTimeSleep
				nKey     := VTInkey()
				If lSleeping // Sai do modo de hibernacao
					nIdle     := nIdleWake
					lSleeping := .F.
					VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
				EndIf
				// Somente processar a proxima funcao RH nao encontrado atividades.
				// caso contrario reinicia primeira funcao RH.
				nX := 0
				// Quando parametrizado para sempre procurar os movimentos buscando a 
				// primeira função do operador
				If lPrimFunc
					Exit
				EndIf
			EndDo
			If __nOpcESC == 1 // Abandono
				Exit
			EndIf
			If (nKey:=VTInkey()) == 27
				Exit
			EndIf
		Next nX

		If __nOpcESC == 1 // Abandono
			Exit
		EndIf

		// Tratamento da Hibernacao
		If lSleep
			If !(nKey==0) // Reinicializa o contador se alguma tecla for pressionada
				nTimeIni := Seconds() + nTimeSleep
			EndIf
			If !lSleeping .And. (Seconds() > nTimeIni)
				VTAlert(,STR0012, .T., 1000, 3)  // Hibernando...'
				nIdle     := nIdleSleep
				lSleeping := .T.
				aTelaAnt  := VTSave(00, 00, VTMaxRow(), VTMaxCol())
				VTClear()
			ElseIf lSleeping .And. (nTimeIni >= Seconds())
				VTAlert(, STR0013, .T., 1000, 3) // Acordando...'
				nIdle     := nIdleWake
				lSleeping := .F.
				VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
			EndIf
		EndIf

		If !lSleeping
			// Monta a String para a visualizacao do Relogio no rodape
			cHora  := If(Val(Left(Time(), 2))>12.And.Val(Left(Time(), 2))<=23,StrZero(Val(Left(Time(), 2))-12, 2),Left(Time(), 2))
			cAmPm  := If(Val(Left(Time(), 2))>12.And.Val(Left(Time(), 2))<= 23,STR0014,STR0001) // pm'###'am'
			cClock := cHora + ':' + Subs(Time(), 4, 2) + ' ' + cAmPm

			// Monta o String da "helice"
			cHelice  := If(cHelice=='|','/',If(cHelice=='/','-',If(cHelice=='-','\',If(cHelice=='\','|','|'))))

			@ Int(VTMaxRow()/2), 18 VTSay cHelice
			WMSVTRodPe(cClock, .F.)
		EndIf

		If (nKey==27)
			If WMSVTAviso(WMSV00104,STR0015, {STR0016,STR0017}) == 1   // Finaliza Aguarde de Convocacao? // Sim // Nao
				Exit
			EndIf
			nTimeIni := Seconds() + nTimeSleep
		EndIf
	EndDo
	// Destroy as temporárias da unitização - FORA DA TRANSAÇÃO
	WMSDTPENDU()
	// Destroy as temporárias da execução automática - FORA DA TRANSAÇÃO
	WMSDTPRGCV()
	__cInterNet := cInternet
Return Nil
/*--------------------------------------------------------------------------------
---Convocacao
---Convoca o operador logado na radio frequencia para executar o
---Servico x Tarefa x Atividade.
---Alex Egydio - 18/09/2000
---cFuncao, Caracter, (Função para analise da convocação)
---lRadioF, Logico, (se utiliza radio frequencia)
---cRecHum, Caracter, (Recurso humano)
---cUsuArma, Caracter, (Armazem logado)
---cUsuZona, Caracter, (Zona de armazenagem logada)
---nTipoConv, Numerico, (Tipo convocação)
---dDataFec, Date, (Data de fechamento)
----------------------------------------------------------------------------------*/
Static __lConvoca := .F. // Determina se o D12 deve ser convocado
Static __nRecD12  := 0   // Determina qual o Recno() do D12 a ser convocado

Static Function Convocacao(cFuncao, lRadioF, cRecHum, cUsuArma, cUsuZona, nTipoConv, dDataFec)
Local aAreaAnt    := GetArea()
Local aTelaAnt    := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local lRet        := .F.
Local cAliasCnv   := GetNextAlias()
Local cQuery      := ""
Local cMsgSem     := ""
Local lRetPE      := .T.
Local cNumero     := ""
Local nCol        := 0
Local aRetPE      := {}
Local cFunExe     := ""
Local bFunExe     := Nil
Local lTrocaFunc  := .F.
Local cMens       := ""
Local cMensagem   := ""
Local cSegSepara  := SuperGetMV('ES_SERVSEP',.T.,'025',cFilAnt)
Local cPriSepara  := SuperGetMV('ES_SERVDIS',.T.,'019',cFilAnt)
Local cEndQua	:= SuperGetMV('ES_ENDQUA',.T.,'')
Local cEndRec	:= SuperGetMV('ES_ENDREC',.T.,'')

// Variaveis para solicitar dispositivo de movimentacao
Default cUsuArma  := ""
Default cUsuZona  := ""

Private cErro     := ""
Private cVolume   := ""  // Determina qual o volume informado
Private cCliLoja  := ""  // Cliente e loja
Private lRetAtiv  := .F.
Private lWMSDRMake:= .F. // Indica se a funcao executada eh RDMake
Private lWMSRDStat:= (SuperGetMV('MV_WMSRDST', .F., 'S')=='S') // Indica se o STATUS sera alterado pelo WMS quando forem executadas funcoes RDMake
Private aParConv  := {cFuncao, lRadioF, cRecHum, cUsuArma, cUsuZona, nTipoConv, dDataFec}
Private cAntRecHum:= "" // Para salvar o recurso humano anterior, caso o usuário abandone a tarefa
	// Limpa a FLAG da tecla ESC
	U_WOpcESC(0)

	VTSetKey(25,{||TrocarFunc(aFuncoesWMS,@lTrocaFunc)},"Trocar Funcao") // Trocar Funcao <CTRL> + <Y>
	// Deve verificar se existe alguma atividade para o usuário que ficou em andamento
	If __nRecD12 == 0
		__nRecD12 := DCD->DCD_ULTATV
	EndIf

	cQuery := QryValAtCv(cRecHum,cFuncao,cUsuArma,0,lReinAuto,.F.,.F.)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasCnv,.F.,.T.)

	While (cAliasCnv)->(!Eof())
		// Abandona a Verificacao da Convocacao
		If VTLastKey() == 27
			__nOpcESC := 1 // FLAG de Abandono
			Exit
		EndIf

		//Rodolfo - desprezar movimentos entre doca e qualidade
		If Alltrim((cAliasCnv)->D12_ENDORI) $ cEndQua .And. Alltrim((cAliasCnv)->D12_ENDDES) $ cEndRec
			(cAliasCnv)->(DbSkip())
			Loop		
		EndIf

		//Rodolfo - desprezar movimentos entre doca e qualidade
		If Alltrim((cAliasCnv)->D12_ENDORI) $ cEndRec .And. Alltrim((cAliasCnv)->D12_ENDDES) $ cEndQua
			(cAliasCnv)->(DbSkip())
			Loop		
		EndIf


		// verifica se o registro do D12 ja foi executado pelo processo de multi-tarefas
		nReg := aScan(oMovimento:GetArrCol(),{|x|x[1] == (cAliasCnv)->RECD12 })
		If nReg > 0
			(cAliasCnv)->(DbSkip())
			Loop
		EndIf
		// Se o movimento a ser convocado é o mesmo do último que ele "pulou", não convoca
		If __nRecPula == (cAliasCnv)->RECD12
			(cAliasCnv)->(DbSkip())
			Loop
		EndIf
		// Irá realizar o posicionamento da D12
		If !ChkAvalD12((cAliasCnv)->RECD12,cRecHum,cFuncao,cUsuArma,cUsuZona,nTipoConv,dDataFec)
			(cAliasCnv)->(dbSkip())
			Loop
		EndIf

		__lConvoca := .T.
		__nRecD12  := oMovimento:GetRecno()
		While __lConvoca // Para permitir multi-tarefa
			__lConvoca := .F. // Para forçar sair caso não use multi-tarefa
			__lDestino := .F.
			// Atribui a Funcao de HELP DE TECLAS a Combinacao de Teclas <CTRL> + <O>
			VTSetKey(15,{||GeraOcorre()},STR0010)  // Ocorrencias'

			// Neste ponto o D12 a ser excutado deve estar posicionado corretamente
			// Não precisa recarregar a função a executar e nem se é RF
			// Pois deve sempre executar uma mesma atividade
			// Posiciona o registro de movimentação
			oMovimento:GoToD12(__nRecD12)
			oMovimento:SetUsuArm(!Empty(cUsuArma))
			If oMovimento:LockD12()
				If IIf(!lReinAuto,oMovimento:GetStatus() $ "3|4",oMovimento:GetStatus() $ "2|3|4" ) .And. (Empty(oMovimento:GetRecHum()) .OR. oMovimento:GetRecHum()==cRecHum)// Verifica se conseguiu travar registro
					// --- Verifica se data do Protheus esta diferente da data do sistema.
					ChkDtAtu()
					// Salva o recurso humano anterior, caso ousuário abandone a tarefa
					cAntRecHum := oMovimento:GetRecHum()
					// Indica se a funcao executada eh RDMake
					lWMSDRMake := Upper(SubStr(oMovimento:oMovServic:GetFuncao(), 1, 2)) == 'U_'
					// Soh altera o Status se NAO for RDMake ou se for RDMake e a alteracao do Status (MV_WMSRDST) ficar a cargo o WMS
					U_WAltSts(!lWMSDRMake .Or. (lWMSDRMake.And.lWMSRDStat))
					// Limpa a FLAG da tecla ESC
					U_WOpcESC(0)
					// Carrega parâmetro para "Pular Atividade"
					U_WPulaAti()
					// Limpa o último movimento que pulou, pois convocou um outro movimento
					__nRecPula := 0
					// Seta D12_STATUS para Servico em Execucao
					If U_WAltSts()
						oMovimento:SetRecHum(cRecHum)
						oMovimento:SetStatus("3")
						oMovimento:SetDataIni(dDataBase)
						oMovimento:SetHoraIni(Time())
						oMovimento:SetDataFim(CTOD(""))
						oMovimento:SetHoraFim("")
						oMovimento:UpdateD12(.F.)
					EndIf
					//            1
					//  01234567890123456789
					// 0 ___Administrador___
					// 1 Executar Apanhe de
					// 2 produtos -
					// 3 Movimento Vertical
					// 4
					// 5
					// 6 ___________________
					// 7  Pressione <ENTER>
					lTrocaFunc := .F.
					While .T.
						cMensagem := WmsFmtMsg(STR0018,{{"[VAR01]",oMovimento:oMovTarefa:GetDesTar()},{"[VAR02]",oMovimento:oMovTarefa:GetDesAti()}})
						If lWMSV001MS
							cMens := ExecBlock('WMSV001MS', .F., .F.,{oMovimento:GetRecno()})
							If ValType(cMens) == 'C' .And. !Empty(cMens)
								cMensagem := cMens
							EndIf
						EndIf
						VTBeep(3)
						WmsMessage(cMensagem,WMSV00105) // Executar [VAR01] - [VAR02]
						Exit
					EndDo
					If !lTrocaFunc
						VTSetKey(25)
						// Abandona a Verificacao da Convocacao, se não possui nada para descarregar
						If VTLastKey() == 27
							If oMovimento:GetQtdLid() <= 0
								RedoRecHum(cAntRecHum)
								oMovimento:SetStatus("4")
								oMovimento:SetDataIni(CTOD(""))
								oMovimento:SetHoraIni("")
								oMovimento:SetDataFim(CTOD(""))
								oMovimento:SetHoraFim("")
							EndIf
							oMovimento:UpdateD12(.F.)
							U_WAltSts(.F.)
							If Len(oMovimento:GetArrCol()) == 0 .And. Len(oMovimento:GetArrConf()) == 0
								__nOpcESC := 1 // FLAG de Abandono
								Exit
							Else
								__lDestino := .T.
							EndIf
						EndIf
						lRet := (oMovimento:GetStatus() == "3")
						// Ponto de Entrada na Gravacao do Status de Servico Automatico
						If lWMSV001G
							ExecBlock('WMSV001G', .F., .F.,{oMovimento:oMovServic:GetFuncao()})
						EndIf
						// Dispara a funcao associada ao servico
						If (oMovimento:GetStatus() $ "3|4")
							// Atualiza a convocação do usuário para a ultima atividade
							// Somente se não cancelou a atividade atual e está levando para o destino
							If !__lDestino
								RecLock("DCD",.F.)
								DCD->DCD_DTULAL := dDataBase
								DCD->DCD_HRULAL := Time()
								DCD->DCD_ULTATV := __nRecD12
								DCD->DCD_STATUS := '2'
								DCD->(MsUnlock())
							EndIf
							// Atualiza a coluna "Rotina" do VTMONITOR
							cMsgSem := "WMSV001 - ["+ WmsFmtMsg(STR0030,{{"[VAR01]",If( Empty(cUsuArma),'??',cUsuArma )}}) // A [VAR01]"
							cMsgSem += WmsFmtMsg(STR0031,{{"[VAR01]",If( Empty(cUsuZona),'??????',cUsuZona )}}) // Z [VAR01]"
							cMsgSem += Upper(Alltrim(oMovimento:oMovServic:GetFuncao()))+"]"
							VTAtuSem('SIGAACD', cMsgSem)
							If oMovimento:oMovServic:ChkConfEnt()			// Conferência Entrada
								lRetAtiv := U_UWMSV074()
							ElseIf oMovimento:oMovServic:ChkConfSai()		// Conferência Expedição
								lRetAtiv := U_UWMSV076()
							ElseIf oMovimento:oMovServic:ChkRecebi();		// Armazenagem, Crossdocking
								.Or. oMovimento:oMovServic:ChkTransf()		// Transferencia // Desfragmentação
								lRetAtiv := U_UWMSV085()
							ElseIf oMovimento:oMovServic:ChkSepara();   	// Separacao Apanhe,ApanheVL,ApanheC1,ApanheC2
								.Or. oMovimento:oMovServic:ChkReabast()  	// (Re)Abastecimento
								lRetAtiv := U_UWMSV030()
							ElseIf lWMSDRMake
								If '()' $ oMovimento:oMovServic:GetFuncao()
									cFunExe := StrTran(oMovimento:oMovServic:GetFuncao(),'()','')
									cFunExe += "(oMovimento,'2')"
								EndIf
								cFunExe := "{|oMovimento| "+ cFunExe +"}"
								bFunExe := &(cFunExe)
								lRetAtiv := Eval(bFunExe,oMovimento)
								lRetAtiv := If(!(lRetAtiv==NIL).And.ValType(lRetAtiv)=='L', lRetAtiv, .T.)
							Else
								lRetAtiv := .T.
							EndIf
							// Atualiza a coluna "Rotina" do VTMONITOR
							cMsgSem := "WMSV001 - ["+ WmsFmtMsg(STR0030,{{"[VAR01]",If( Empty(cUsuArma),'??',cUsuArma )}}) // A [VAR01]
							cMsgSem += WmsFmtMsg(STR0031,{{"[VAR01]",If( Empty(cUsuZona),'??????',cUsuZona )}}) // Z [VAR01]
							cMsgSem += STR0032+"]" // Aguardando...
							VTAtuSem("SIGAACD", cMsgSem)
						EndIf
						// --- Verifica se data do Protheus esta diferente da data do sistema.
						ChkDtAtu()
						// Seta D12_STATUS para "Servico Executado"
						If cPriSepara <> oMovimento:oMovServic:GetServico() .And. U_WAltSts()
							Begin Transaction
								oMovimento:SetStatus(IIf(lRetAtiv,"1","2"))
								oMovimento:SetRecHum(cRecHum)
								oMovimento:SetDataFim(dDataBase)
								oMovimento:SetHoraFim(Time())
								If !Empty(oMovimento:GetErro()) .OR. !lRetAtiv
									oMovimento:SetPrAuto("1") // Permite reinicio automático
									oMovimento:cErro := ""
									oMovimento:SetAnomal("S")
								EndIf
								oMovimento:UpdateD12()
							End Transaction
						EndIf
						// Ponto de Entrada na Gravacao do Status de Servico Executado
						If lWMSV001G
							ExecBlock('WMSV001G', .F., .F.,{oMovimento:oMovServic:GetFuncao()})
						EndIf
						// Marca o usuário como livre
						RecLock("DCD",.F.)
						DCD->DCD_STATUS := "1"
						DCD->(MsUnlock())
					Else
						RedoRecHum(cAntRecHum)
						oMovimento:SetStatus("4")
						oMovimento:UpdateD12()
						U_WAltSts(.F.)
						__lConvoca := .F.
						lRet := .T.
					EndIf
				EndIf
				oMovimento:UnLockD12()
			EndIf
		EndDo
		VTSetKey(15)
		Exit // Se ocorreu convocação, sair do WHILE e processar a próxima função
	EndDo
	(cAliasCnv)->(DbCloseArea())

	If !lTrocaFunc
		If __nOpcESC == 1 .And. Len(oMovimento:GetArrCol()) > 0
			For nCol:= 1 To Len(oMovimento:GetArrCol())
				D12->(dbGoTo(oMovimento:GetArrCol()[nCol][1]))
				If D12->(!Eof()) .And. !(D12->D12_STATUS $ '0|1')
					Begin Transaction
						RecLock("D12",.F.)
						D12->D12_STATUS := '2'
						D12->D12_PRAUTO := '1'
						D12->D12_DATFIM := dDataBase
						D12->D12_HORFIM := Time()
						D12->(MsUnlock())
					End Transaction
				EndIf
			Next nCol
		EndIf
		oMovimento:IniArrCol()
		oMovimento:IniArrConf()
		If !Empty(oRegraConv:GetArrReg()) .And. oRegraConv:GetArrReg()[9]=='1'
			oRegraConv:SetRecHum(cRecHum)
			oRegraConv:SetFuncao(cFuncao)
			oRegraConv:SetRetAtiv(lRetAtiv)
			oRegraConv:LawLibRua()
		EndIf
	EndIf
	VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)

	RestArea(aAreaAnt)
Return lRet
/*--------------------------------------------------------------------------------
---ChkAvalD12
---Avalia se o D12 passado pode ser convocado para execução
---Jackson Patrick Werka - 01/04/2015
---nRecnoD12, numerico, (Recno da D12)
---cRecHum, Caracter, (Recurso humano)
---cFuncao, Caracter, (Função para analise da convocação)
---cUsuArma, Caracter, (Armazem logado)
---cUsuZona, Caracter, (Zona de armazenagem logada)
---nTipoConv, Numerico, (Tipo convocação)
---dDataFec, Date, (Data de fechamento)
----------------------------------------------------------------------------------*/
Static Function ChkAvalD12(nRecnoD12,cRecHum,cFuncao,cUsuArma,cUsuZona,nTipoConv,dDataFec)
Local aAreaAnt   := GetArea()
Local lRet       := .T.
Local lConvoca   := .F.
Local lNaoConv   := SuperGetMV("MV_WMSNREG", .F., .F.)
Local aRetPE     := {}
Local cNumero    := ""
Local cArmSBE    := ""
Local lPertenceZ := .F.
Local lWMSCOMP   := (SuperGetMV('MV_WMSCOMP', .F., 'F')=='T') // Se realiza a separação completa da carga ou pedido antes de permitir a convocacao de atividade reiniciada de outra carga.
Local lPrimAtiv  := .T.
Local lUltiAtiv  := .T.
Local cEndereco  := ""
Local cSegSepara  := SuperGetMV('ES_SERVSEP',.T.,'025',cFilAnt)
Default cRecHum   := __cUserID
Default cFuncao   := ""
Default cUsuArma  := ""
Default cUsuZona  := ""
Default nTipoConv := SuperGetMV("MV_TPCONVO", .F., 1) // 1=Por Atividade/2=Por Tarefa
Default dDataFec  := DtoS(WmsData())

	VTMsg(STR0069) // Analisando...
	// Posiciona o registro de movimentação
	If !oMovimento:GoToD12(nRecnoD12)
		lRet := .F.
	EndIf

	oMovimento:SetQuant(oMovimento:GetQtdMov())
	// Ignora movimentos cancelado e finalizados
	If lRet .And. oMovimento:GetStatus() $ "0|1"
		lRet := .F.
	EndIf
	// Valida bloqueio produto (B1_MSBLQL)
	If lRet .And. !oMovimento:IsMovUnit() .And. !WmsSB1Blq(oMovimento:oMovPrdLot:GetProduto())
		lRet := .F.
	EndIf
	// Não permite reiniciar movimentos sem recurso definido e que foram bloqueados
	If lRet .And. oMovimento:GetStatus() == "2" .And. oMovimento:GetPrAuto() == "2" .And. Empty(oMovimento:GetRecHum())
		lRet := .F.
	EndIf

	// Não deve convocar as atividades geradas a partir de um mapa de separação de quantidade fracionada,
	// pois se trata de um processo manual. Elas serão consideradas pelo programa WMSA360.
	If lRet .And. oMovimento:GetMapaTip() == "1"
		lRet := .F.
	EndIf

	// Ignora servicos jah atribuidos a outros usuarios
	If lRet .And. !Empty(oMovimento:GetRecHum()) .And. oMovimento:GetRecHum() <> cRecHum
		lRet := .F.
	EndIf
	// Se atividade já está atribuída ao usuário e a quantidade lida está igual a solicitada
	// e a situação da atividade está em andamento e possuiu outras atividades em andamento
	If lRet .And. ;
		oMovimento:GetRecHum() == cRecHum .And. ;
		oMovimento:GetStatus() == "3" .And. ;
		QtdComp(oMovimento:GetQtdMov()) <= QtdComp(oMovimento:GetQtdLid()) .And. ;
		oMovimento:HasUsrAtv(cRecHum,cFuncao,cUsuArma)
		lPrimAtiv := oMovimento:IsPriAtiv()
		lUltiAtiv := oMovimento:IsUltAtiv()
		// Solicita endereco destino
		If lPrimAtiv .And. !lUltiAtiv .And.  oMovimento:oMovTarefa:GetSolEnd() == "1"
			cEndereco := oMovimento:oMovEndOri:GetEnder()
		Else
			cEndereco := oMovimento:oMovEndDes:GetEnder()
		EndIf
		AAdd(oMovimento:GetArrCol(),{oMovimento:GetRecno(),;
							DtoS(dDataBase)+Time(),;
							oMovimento:oMovEndOri:GetArmazem(),;
							oMovimento:oMovEndOri:GetEnder(),;
							cEndereco,;
							oMovimento:oMovPrdLot:GetProduto(),;
							oMovimento:oMovPrdLot:GetLoteCtl(),;
							oMovimento:oMovPrdLot:GetNumLote(),;
							oMovimento:GetQtdMov(),;
							oMovimento:oOrdServ:GetCarga(),;
							oMovimento:oOrdServ:GetDocto(),;
							oMovimento:oOrdServ:GetCliFor(),;
							oMovimento:oOrdServ:GetLoja(),;
							lPrimAtiv,;
							lUltiAtiv,;
							oMovimento:GetIdUnit()})
		// Independente se é multiplo apanhe ou não, deve colocar o endereço no Array
		If AScan(oMovimento:GetArrConf(),{|x|x[1]+x[2]==oMovimento:oMovEndOri:GetArmazem()+cEndereco})==0
			AAdd(oMovimento:GetArrConf(),{oMovimento:oMovEndOri:GetArmazem(),cEndereco})
		EndIf
		lRet := .F.
	EndIf

	// Verifica se há pendencias da ultima tarefa lida para permitir ser realiza uma atividade anterior reiniciada
	If lRet .And. oMovimento:GetRecHum() == cRecHum .And. !Empty(__nRecD12)
		If PendDocAnt(cRecHum,cFuncao,cUsuZona)
			If !__lDestino .Or. (__lDestino .AND. lWMSCOMP)
				lRet := .F.
			EndIf
		EndIf
	EndIf
	// Verifica se for conferência de expedição, se foi separada alguma quantidade para permitir conferir
	If lRet .And. oMovimento:oMovServic:ChkConfSai() // Conferencia de expedição
		lRet := HasPrdSai()
	EndIf
	// Verifica se permite reiniciar tarefas, e questiona uma unica vez na secao se deseja reiniciar
	If lRet
		If !lPergAuto .And. lReinAuto .And. oMovimento:GetStatus() == "2" .And. oMovimento:GetPrAuto() == "1"
			If !(lReinAuto := WMSVTAviso(WMSV00110,STR0033, {STR0016,STR0017}) == 1)  // Existe tarefa anterior pendente. Reiniciar? // Sim // Nao
				lRet := .F.
			EndIf
			lPergAuto := .T. // Para não perguntar novamente quando solicionado que não quer reiniciar
		Else
			// Ignora atividades já iniciadas por outros usuarios
			If !(oMovimento:GetStatus() $ "3|4")
				If !(lReinAuto .And. oMovimento:GetStatus() == "2")
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf
	// Valida se movimento possui dependente
	If lRet .And. oMovimento:oOrdServ:ChkDepPend()
		lRet := .F.
	EndIf
	// Não convocar endereços bloqueados
	// Verifica situação do endereço origem  e destino
	If lRet
		If oMovimento:oMovServic:GetServico() <> cSegSepara .And. !oMovimento:ChkEndOri(.T.,.T.) 
			lRet := .F.
		EndIf
		// Verifica situação do endereço destino
		If lRet .And. !oMovimento:ChkEndDes(.T.)
			lRet := .F.
		EndIf
		// Quando problema de saldo e capacidade e bloqueio de endereço gera log e bloqueia o movimento
		If !lRet
			oMovimento:SetLog('1')
			oMovimento:SetPrAuto("1") // Permite reinicio automático
			oMovimento:SetStatus('2')
			oMovimento:UpdateD12()
		EndIf
		// Para servicos de reabastecimento valida se a quantidade saldo do endereço é maior que a capacidade
		If oMovimento:oMovServic:ChkReabast() .And. !oMovimento:ValCapReab()
			lRet := .F.
		EndIf
	EndIf
	// Quando for uma conferencia de saida libera os demais itens
	If lRet .And. lReinAuto .And. oMovimento:oMovServic:ChkConfer()
		// Quando for uma conferencia de saida libera os demais itens
		UpdSitLib()
	EndIf

	If lRet
		If ExistBlock('DLVACONV')
			ExecBlock('DLVACONV', .F., .F., {cRecHum, cFuncao, oMovimento:GetRecno()})
		EndIf
		// Regra para a convocacao dos Servicos x Tarefas x Atividades
		If ExistBlock('WMSV001A')
			lConvoca := ExecBlock('WMSV001A', .F., .F.,{cRecHum,cFuncao,oMovimento:oMovServic:GetServico(),oMovimento:oMovTarefa:GetTarefa(),oMovimento:oMovTarefa:GetAtivid(),oMovimento:oMovTarefa:GetOrdem(),oMovimento:oOrdServ:GetDocto(),lConvoca})
		Else
			If AllTrim(oMovimento:GetRhFunc()) == AllTrim(cFuncao)
				If !Empty(oMovimento:oMovTarefa:GetTarefa()) .And. !Empty(oMovimento:oMovTarefa:GetAtivid())
					lConvoca := ChkExecAnt(oMovimento,nTipoConv,dDataFec,cRecHum,(lReinAuto  .And. oMovimento:GetPrAuto() == "1"))
				EndIf
			EndIf
		EndIf
		// Ponto de Entrada Antes da Confirmacao da Convocacao para verificar saldo endereco origem.
		If ExistBlock('WMSV001B')
			aRetPE := ExecBlock('WMSV001B', .F., .F.,{cRecHum,cFuncao,oMovimento:oMovServic:GetServico(),oMovimento:oMovTarefa:GetTarefa(),oMovimento:oMovTarefa:GetAtivid(),oMovimento:oMovTarefa:GetOrdem(),oMovimento:oOrdServ:GetDocto(),lConvoca,oMovimento:oMovServic:GetFuncao()})
			If ValType(aRetPE) == 'A' .And. !Empty(aRetPE) .And. ValType(aRetPE[1])=='L'
				lConvoca := aRetPE[1]
			EndIf
		EndIf
	EndIf
	If lRet .And. lConvoca
		If Empty(oMovimento:GetRecHum())
			cNumero := Left(oMovimento:oOrdServ:GetDocto(),Len(SD7->D7_NUMERO))
			// Movimentacoes de CQ
			SD7->(DbSetOrder(3))
			If SD7->(MsSeek(xFilial('SD7')+oMovimento:oMovPrdLot:GetProduto()+oMovimento:oOrdServ:GetNumSeq()+cNumero))
				cArmSBE := SD7->D7_LOCAL
			Else
				cArmSBE := oMovimento:oMovEndOri:GetArmazem()
			EndIf
			// Verifica se ha regras para convocacao para estas atividades.
			oRegraConv:aRetRegra := {}
			oRegraConv:SetArmazem(cArmSBE)
			oRegraConv:SetRecHum(cRecHum)
			oRegraConv:oMovimento:GoToD12(oMovimento:GetRecno())
			// Verifica se ha regras para convocacao
			If oRegraConv:LawRecHum()
				// Analisa se convocao ou nao
				If !oRegraConv:LawLimit()
					lRet := .F.
				EndIf
			Else
				// Convocar para esta atividade somente se encontrar regra definida para o operador.
				If lNaoConv
					lRet := .F.
				EndIf
				// Apesar de o operador(A) nao ter regra definida, preciso analisar se outro operador(B) reservou a rua,
				// se o operador(B) ja reservou a rua o operador(A) nao sera convocado ate que a rua seja liberada.
				If lRet .And. !oRegraConv:LawChkRua()
					lRet := .F.
				EndIf
				// Ignora a Zona de Armazenagem diferente da escolhida na convocacao
				If lRet .And. !Empty(cUsuZona)
					// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					// ³ Verifica o Tipo de Servico (1-Entrada/2-Saida/3-Mov.Interno)          ³
					// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					SBE->(DbSetOrder(1)) // BE_FILIAL+BE_LOCAL+BE_LOCALIZ+BE_ESTFIS
					lPertenceZ := .F.
					If oMovimento:oMovServic:GetTipo() $ '2|3' // Saidas ou Mov. Internos: Considera a Zona referente ao Endereco/Zona de ORIGEM
						lPertenceZ := (oMovimento:oMovEndOri:GetCodZona() == cUsuZona)
					EndIf
					If !lPertenceZ
						If oMovimento:oMovServic:GetTipo() $ '1|3' // Entradas ou Mov. Internos: Considera a Zona referente ao Endereco/Zona de DESTINO
							lPertenceZ := (oMovimento:oMovEndDes:GetCodZona() == cUsuZona)
						EndIf
					EndIf
					If !lPertenceZ
						lRet := .F.
					EndIf
				EndIf
			EndIf
		EndIf
	Else
		lRet := .F.
	EndIf
	RestArea(aAreaAnt)
Return lRet
// -----------------------------------------------------------
/*/{Protheus.doc} WMSEnder
Apresenta o codigo do endereco na tela do coletor de dados
respeitando a configuracao do codigo do endereco.
@author Alex Egydio
@since 18/09/2000
@version 1.0
@param nLin, numérico, (número da linha)
@param nCol, numérico, (número da coluna)
@param cEndereco, character, (código do endereço)
@param cArmazem, character, (código do armazem)
@param nNivIni, numérico, (Nivel inicio)
@param nNivFim, numérico, (Nivel fim)
@param cCabec, character, (Descrição do cabeçalho)
/*/
// -----------------------------------------------------------
Static Function WMSEnder(nLin, nCol, cEndereco, cArmazem, nNivIni, nNivFim, cCabec)
Local aTelaAnt   := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local aCab       := {''}
Local aSize      := {VTMaxCol()}
Local aAreaAnt   := GetArea()
Local aAreaSBE   := SBE->(GetArea())
Local aAreaDC7   := DC7->(GetArea())
Local aEndereco  := {}
Local aNiveis    := {}
Local nX         := 1
Local nNivAtu    := 1
Local nParNivIni := SuperGetMV('MV_ENDINRF', .F., 0)
Local nParNivFim := SuperGetMV('MV_ENDFIRF', .F., 0)
Local nLenDesc   := 0
Local nLenEnd    := 0
Local nMaxLin    := 0
Local cSeekDC7   := ''
Local lCfgEnd    := .F.

Default nLin       := 0
Default nCol       := 0
Default cEndereco  := D12->D12_ENDORI
Default cArmazem   := D12->D12_LOCORI
Default nNivIni    := 0
Default nNivFim    := 0
Default cCabec     := STR0020 // Endereco


	cCabec := FWCutOff(cCabec,.T.)
	If ExistBlock('DVDISPEN')
		cEndereco := ExecBlock('DVDISPEN', .F., .F., {cEndereco})
	EndIf

	// Considera o Parametro MV_ENDINRF
	nNivIni := If(nParNivIni>0, nParNivIni, nParNivIni)

	// Considera o Parametro MV_ENDINRF
	nNivFim := If(nParNivFim>0, nParNivFim, nNivFim)

	DbSelectArea('DC7')
	DbSetOrder(1)

	DbSelectArea('SBE')
	DbSetOrder(1)
	If (lCfgEnd:=(MsSeek(xFilial('SBE')+cArmazem+cEndereco, .F.) .And. !Empty(BE_CODCFG) .And. DC7->(MsSeek(cSeekDC7:=xFilial('DC7')+SBE->BE_CODCFG, .F.))))
		nX      := 1
		nNivAtu := 1
		DbSelectArea('DC7')
		aAdd(aNiveis,{Upper(STR0006)+"*",cArmazem}) // Armazém
		Do While !Eof() .And. cSeekDC7==DC7_FILIAL+DC7_CODCFG
			If ((nNivIni+nNivFim)==0) .Or. ((nNivIni>0.And.nNivFim>0) .And. (nNivAtu>=nNivIni.And.nNivAtu<=nNivFim))
				aAdd(aNiveis, {AllTrim(DC7_DESEND), AllTrim(SubStr(cEndereco, nX, DC7_POSIC))})
			EndIf
			nX      += DC7_POSIC
			nNivAtu ++
			DbSkip()
		EndDo
		nLenDesc := 0
		nLenEnd  := 0
		For nX := 1 to Len(aNiveis)
			nLenEnd := If(Len(aNiveis[nX, 2])>nLenEnd, Len(aNiveis[nX, 2]), nLenEnd)
		Next nX
		nLenDesc := VTMaxCol()-1-nLenEnd
		For nX := 1 to Len(aNiveis)
			aAdd(aEndereco, {PadR(aNiveis[nX, 1], nLenDesc) + ' ' + PadR(aNiveis[nX, 2], nLenEnd)})
		Next nX
	EndIf

	VTClear()
	If lCfgEnd
		nMaxLin := IIf(Len(aEndereco) > 4,(VTMaxRow()-1),(VTMaxRow()-2))
		aCab := {PadC(cCabec, VTMaxCol(), '_')}
		WMSVTRodPe(, .F.)
		VTaBrowse(nLin, nCol, nMaxLin, VTMaxCol(), aCab, aEndereco, aSize)
	Else
		WMSVTCabec(cCabec,.F.,.F.,.T.)
		@ nLin+2, nCol VTSay PadR(STR0006, VTMaxCol()) // Armazem
		@ nLin+3, nCol VTSay PadR(cArmazem, VTMaxCol())
		@ nLin+4, nCol VTSay PadR(STR0020, VTMaxCol())  // Endereco
		@ nLin+5, nCol VTSay PadR(cEndereco, VTMaxCol())
		WMSVTRodPe()
	EndIf

	RestArea(aAreaDC7)
	RestArea(aAreaSBE)
	RestArea(aAreaAnt)
	VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
Return NIL
/*--------------------------------------------------------------------------------
---ChkVldArm
---Validacao do Armazem digitado no coletor de dados
---Jackson Patrick Werka - 01/04/2015
---cUsuArma, Caracter, (Armazem logado)
----------------------------------------------------------------------------------*/
Static Function ChkVldArm(cUsuArma)
Local lRet   :=.T.
Local lRetPE :=.T.

// Permite efetuar validacoes especificas na digitacao do armazem
If ExistBlock("WMSVLARM")
	lRetPE := ExecBlock("WMSVLARM",.F.,.F.,{cUsuArma})
	If Valtype(lRetPE) == "L"
		lRet := lRetPE
	EndIf
EndIf

Return lRet
/*--------------------------------------------------------------------------------
---ChkVldZon
---Valida a zona digitada no coletor de dados
---Jackson Patrick Werka - 01/04/2015
---cUsuZona, Caracter, (Zona de armazenagem logada)
----------------------------------------------------------------------------------*/
Static Function ChkVldZon(cUsuZona)
Local lRet :=.T.
	If !Empty(cUsuZona) .And. !ExistCpo('DC4', cUsuZona)
		lRet:=.F.
	EndIf
Return lRet
// -----------------------------------------------------------
/*/{Protheus.doc} GeraOcorre
Permite a digitacao de ocorrencias via VT100
@author Fernando J. Siquini
@since 04/12/2002
@version 1.0
/*/
// -----------------------------------------------------------
Static Function GeraOcorre()
Local aTelaAnt  := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local cOcorre   :=  CriaVar('DCM_OCORRE', .F.)
Local cNumOcor  := ""
Local cCodInv   := ""
Local cArmazem  := ""
Local cEndereco := ""
Local cBlqEnder := .F.
Local cQuery    := ""
Local cAliasD14 := Nil
Local nAviso    := 0
Local dData     := dDataBase
Local lGeraInvt := .F.
Local lOcorre   := .T.
	dbSelectArea("DCN")
	Do While .T.
		// Inicializa
		lOcorre   := .T.
		WMSVTCabec(AllTrim(CUSERNAME), .F., .F., .T.)
		@ 02, 00 VTSay 'Prod..: ' + oMovimento:oMovPrdLot:GetProduto()
		@ 03, 00 VTSay 'Doc...: ' + oMovimento:oOrdServ:GetDocto()+' '+oMovimento:oOrdServ:GetSerie()
		@ 04, 00 VTSay 'S/T/A.: ' + oMovimento:oMovServic:GetServico()+'/'+oMovimento:oMovTarefa:GetTarefa()+'/'+oMovimento:oMovTarefa:GetAtivid()
		@ 05, 00 VTSay PadR(STR0021, VTMaxCol())  // Ocorrencia'
		@ 06, 00 VTGet cOcorre Valid !Empty(cOcorre) .And. ChkValOcor(@cOcorre) F3 'DCM'
		VTRead
		If VTLastKey() == 27
			nAviso := WmsMessage(STR0022,WMSV00107,10,,{STR0023, STR0024, STR0025}) // Deseja: // Redigitar // Continuar // Abandonar
			If nAviso == 1 .Or. (nAviso == 2 .And. Empty(cOcorre))
				Loop
			ElseIf nAviso == 3
				Exit
			EndIf
			lOcorre := .F.
		EndIf
		If lOcorre
			DCM->(dbSetOrder(1))
			If DCM->(dbSeek(xFilial("DCM")+cOcorre))
				cBlqEnder := DCM->DCM_BLQEND // Bloqueia o endereço 1=Geral; 2=Entrada; 3=Saída
				lGeraInvt := DCM->DCM_GERAIN == "1" // Gera inventário mestre
	
				If cBlqEnder $ "123" .Or. lGeraInvt
					WmsEndOcor(@cArmazem,@cEndereco)
				EndIf
	
				If !Empty(cEndereco)
					// Ocorrencia bloqueia endereço
					If cBlqEnder $ "123"
						// Altera o status do endereço
						SBE->(dbSetOrder(1)) // BE_FILIAL+BE_LOCAL+BE_LOCALIZ
						If SBE->(dbSeek(xFilial("SBE")+cArmazem+cEndereco))
							RecLock("SBE",.F.)
							Do Case
								Case cBlqEnder == "1" // Geral
									SBE->BE_STATUS := "3" // Bloqueado
								Case cBlqEnder == "2" // Entrada
									SBE->BE_STATUS := "4" // Bloqueio Entrada
								Case cBlqEnder == "3" // Saída
									SBE->BE_STATUS := "5" // Bloqueio Saída
							EndCase
							SBE->(MsUnlock())
						EndIf
					EndIf
					// Ocorrencia gera inventario
					If lGeraInvt
						// Gera o inventário mestre
						lOcorre := WmsGerInvt(@cCodInv,cEndereco)
					EndIf
				EndIf
			EndIf
		EndIf
		// Gera ocorrencia
		If lOcorre
			cNumOcor := GetSX8Num('DCN', 'DCN_NUMERO')
			If __lSX8
				ConfirmSX8()
			EndIf
			oMovimento:LoadData()
			oMovimento:SetOcorre(cOcorre)
			oMovimento:SetNumOcor(cNumOcor)
			oMovimento:UpdateD12()
			// Verifica se é um movimento unitizado
			If oMovimento:IsMovUnit()
				cQuery := "SELECT D14.D14_CODUNI,"
				cQuery +=       " D14.D14_PRDORI,"
				cQuery +=       " D14.D14_PRODUT,"
				cQuery +=       " D14.D14_LOTECT,"
				cQuery +=       " D14.D14_NUMLOT,"
				cQuery +=       " D14.D14_NUMSER,"
				cQuery +=       " D14.D14_QTDSPR"
				cQuery +=  " FROM "+RetSqlName("D14")+" D14"
				cQuery += " WHERE D14.D14_FILIAL = '"+xFilial("D14")+"'"
				cQuery +=   " AND D14.D14_IDUNIT = '"+oMovimento:cIdUnitiz+"'"
				cQuery +=   " AND D14.D14_LOCAL  = '"+oMovimento:oMovEndOri:GetArmazem()+"'"
				cQuery +=   " AND D14.D14_ENDER  = '"+oMovimento:oMovEndOri:GetEnder()+"'"
				cQuery +=   " AND D14.D_E_L_E_T_ = ' '"
				cAliasD14 := GetNextAlias()
				DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasD14,.F.,.T.)
				aTamSX3 := TamSx3("D14_QTDSPR"); TcSetField(cAliasD14,'D14_QTDSPR','N',aTamSX3[1],aTamSX3[2])
				If (cAliasD14)->(!Eof())
					Do While (cAliasD14)->(!Eof())
						// Grava ocorrencia
						RecLock('DCN', .T.)
						DCN->DCN_FILIAL   := xFilial('DCN')
						DCN->DCN_NUMERO   := cNumOcor
						DCN->DCN_OCORR    := cOcorre
						DCN->DCN_STATUS   := '1'
						DCN->DCN_ACAO     := oMovimento:oMovServic:GetTipo() //1=Doc. Entrada;2=Doc. Saida;3=Movimento Interno
						DCN->DCN_DTINI    := dData
						DCN->DCN_HRINI    := Time()
						DCN->DCN_PROD     := (cAliasD14)->D14_PRODUT
						DCN->DCN_LOCAL    := oMovimento:oMovEndOri:GetArmazem()
						DCN->DCN_QUANT    := (cAliasD14)->D14_QTDSPR
						DCN->DCN_DOC      := oMovimento:oOrdServ:GetDocto()
						DCN->DCN_SERIE    := oMovimento:oOrdServ:GetSerie()
						DCN->DCN_CLIFOR   := oMovimento:oOrdServ:GetCliFor()
						DCN->DCN_LOJA     := oMovimento:oOrdServ:GetLoja()
						DCN->DCN_ITEM     := oMovimento:oOrdServ:GetSerie()
						DCN->DCN_LOTECTL  := (cAliasD14)->D14_LOTECT
						DCN->DCN_NUMLOT   := (cAliasD14)->D14_NUMLOT
						DCN->DCN_NUMSER   := (cAliasD14)->D14_NUMSER
						DCN->DCN_ENDER    := cEndereco
						DCN->DCN_NUMSEQ   := ProxNum()
						DCN->DCN_CODINV   := cCodInv
						DCN->(MsUnlock())
						
						(cAliasD14)->(dbSkip())
					EndDo
					(cAliasD14)->(dbCloseArea())
				EndIf
			Else
				// Grava ocorrencia
				RecLock('DCN', .T.)
				DCN->DCN_FILIAL   := xFilial('DCN')
				DCN->DCN_NUMERO   := cNumOcor
				DCN->DCN_OCORR    := cOcorre
				DCN->DCN_STATUS   := '1'
				DCN->DCN_ACAO     := oMovimento:oMovServic:GetTipo() //1=Doc. Entrada;2=Doc. Saida;3=Movimento Interno
				DCN->DCN_DTINI    := dData
				DCN->DCN_HRINI    := Time()
				DCN->DCN_PROD     := oMovimento:oMovPrdLot:GetProduto()
				DCN->DCN_LOCAL    := oMovimento:oMovEndOri:GetArmazem()
				DCN->DCN_QUANT    := oMovimento:GetQtdMov()
				DCN->DCN_DOC      := oMovimento:oOrdServ:GetDocto()
				DCN->DCN_SERIE    := oMovimento:oOrdServ:GetSerie()
				DCN->DCN_CLIFOR   := oMovimento:oOrdServ:GetCliFor()
				DCN->DCN_LOJA     := oMovimento:oOrdServ:GetLoja()
				DCN->DCN_ITEM     := oMovimento:oOrdServ:GetSerie()
				DCN->DCN_LOTECTL  := oMovimento:oMovPrdLot:GetLotectl()
				DCN->DCN_NUMLOT   := oMovimento:oMovPrdLot:GetNumLote()
				DCN->DCN_NUMSER   := oMovimento:oMovPrdLot:GetNumSer()
				DCN->DCN_ENDER    := cEndereco
				DCN->DCN_NUMSEQ   := ProxNum()
				DCN->DCN_CODINV   := cCodInv
				DCN->(MsUnlock())
			EndIf
		EndIf
		Exit
	EndDo
	VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
	VTKeyBoard(chr(27))
Return Nil
/*--------------------------------------------------------------------------------
---ChkValOcor
---Valida ocorrencia
---Fernando J. Siquini - 04/12/2002
---cOcorre, Caracter, (Código da ocorrencia)
----------------------------------------------------------------------------------*/
Static Function ChkValOcor(cOcorre)
	Local lRet := .T.
	If !Empty(cOcorre) .And. !DCM->(dbSeek(xFilial("DCM")+cOcorre))
		cOcorre := CriaVar('DCM_OCORRE', .F.)
		lRet := .F.
	EndIf
Return lRet
/*--------------------------------------------------------------------------------
---ChkExecAnt
---Verifica se a atividade anterior já foi executada para liberar
---a atividade atual para convocação.
---Jackson Patrick Werka - 08/10/2013
---oMovimento, objeto, (Classe WMSDTCMovimentosServicoArmazem)
---nTipoConv, numérico, (Tipo de convocação. Valor do parâmetro MV_TPCONVO)
---dDataFec, data, (Data do último fechamento de estoque)
---cRecHum, caracter, (Recurso humano que irá executar a tarefa. Usuário atual)
----------------------------------------------------------------------------------*/
Static Function ChkExecAnt(oMovimento,nTipoConv,dDataFec,cRecHum,lReinicia)
Local aAreaAnt  := GetArea()
Local lCarga    := WmsCarga(oMovimento:oOrdServ:GetCarga())
Local lRet      := .F.
Local lAchou    := .F.
Local lRetPE    := .F.
Local nRecOri   := oMovimento:GetRecno()
Local cQuery    := ""
Local cAliasNew := Nil

Default cRecHum   := ""
Default lReinicia := .T.

	If nTipoConv == 1 // Convocacao por ATIVIDADE (Default)
		// Verifica se a atividade atual é a primeira atividade

		If oMovimento:IsPriAtiv()
			lAchou := .F.
			lRet   := Iif(!lReinicia,(oMovimento:GetStatus() $"3|4"),(oMovimento:GetStatus() $ "2|3|4")) // Convoca se a atividade ainda nao foi executada
		Else
			// Não pode permitir convocar a atividade atual se alguma atividade
			// do movimento atual que seja anterior a mesma não foi executada
			cQuery := "SELECT DISTINCT D12.D12_FILIAL"
			cQuery +=  " FROM "+RetSqlName('D12')+" D12"
			cQuery += " WHERE D12.D12_FILIAL = '"+xFilial("D12")+"'"
			cQuery +=   " AND D12.D12_DOC = '"+oMovimento:oOrdServ:GetDocto()+"'"
			cQuery +=   " AND D12.D12_SERIE = '"+oMovimento:oOrdServ:GetSerie()+"'"
			cQuery +=   " AND D12.D12_CLIFOR = '"+oMovimento:oOrdServ:GetCliFor()+"'"
			cQuery +=   " AND D12.D12_LOJA = '"+oMovimento:oOrdServ:GetLoja()+"'"
			cQuery +=   " AND D12.D12_PRODUT = '"+oMovimento:oMovPrdLot:GetProduto()+"'"
			cQuery +=   " AND D12.D12_SERVIC = '"+oMovimento:oMovServic:GetServico()+"'"
			cQuery +=   " AND D12.D12_TAREFA = '"+oMovimento:oMovServic:GetTarefa()+"'"
			cQuery +=   " AND D12.D12_ORDTAR = '"+oMovimento:oMovServic:GetOrdem()+"'"
			cQuery +=   " AND D12.D12_IDMOV = '"+oMovimento:GetIdMovto()+"'"
			cQuery +=   " AND D12.D12_IDOPER < '"+oMovimento:GetIdOpera()+"'"
			cQuery +=   " AND D12.D12_STATUS IN ('2','3','4')"
			cQuery +=   " AND D12.D12_RADIOF = '1'"
			cQuery +=   " AND D12.D_E_L_E_T_ = ' '"
			cQuery += " UNION ALL"
			cQuery +=" SELECT DISTINCT D12.D12_FILIAL"
			cQuery +=  " FROM "+RetSqlName('D12')+" D12"
			cQuery += " INNER JOIN "+RetSqlName('DCR')+" DCR"
			cQuery +=    " ON DCR.DCR_FILIAL = '"+xFilial("DCR")+"'"
			cQuery +=   " AND DCR.DCR_IDDCF = '"+oMovimento:oOrdServ:GetIdDCF()+"'"
			cQuery +=   " AND DCR.DCR_IDORI <> DCR.DCR_IDDCF"
			cQuery +=   " AND DCR.DCR_IDMOV < '"+oMovimento:GetIdMovto()+"'"
			cQuery +=   " AND DCR.DCR_IDOPER < '"+oMovimento:GetIdOpera()+"'"
			cQuery +=   " AND DCR.D_E_L_E_T_ = ' '"
			cQuery += " WHERE D12.D12_FILIAL = '"+xFilial("D12")+"'"
			cQuery +=   " AND D12.D12_PRODUT = '"+oMovimento:oMovPrdLot:GetProduto()+"'"
			cQuery +=   " AND D12.D12_SERVIC = '"+oMovimento:oMovServic:GetServico()+"'"
			cQuery +=   " AND D12.D12_TAREFA = '"+oMovimento:oMovServic:GetTarefa()+"'"
			cQuery +=   " AND D12.D12_ORDTAR = '"+oMovimento:oMovServic:GetOrdem()+"'"
			If oMovimento:oMovServic:ChkRecebi()
				cQuery +=   " AND D12.D12_LOCDES = '"+oMovimento:oMovEndDes:GetArmazem()+"'"
				cQuery +=   " AND D12.D12_ENDDES = '"+oMovimento:oMovEndDes:GetEnder()+"'"
			Else
				cQuery +=   " AND D12.D12_LOCORI = '"+oMovimento:oMovEndOri:GetArmazem()+"'"
				cQuery +=   " AND D12.D12_ENDORI = '"+oMovimento:oMovEndOri:GetEnder()+"'"
			EndIf
			cQuery +=   " AND D12.D12_IDDCF = DCR.DCR_IDORI"
			cQuery +=   " AND D12.D12_IDMOV = DCR.DCR_IDMOV"
			cQuery +=   " AND D12.D12_IDOPER = DCR.DCR_IDOPER"
			cQuery +=   " AND D12.D12_STATUS IN ('2','3','4')"
			cQuery +=   " AND D12.D12_RADIOF = '1'"
			cQuery +=   " AND D12.D12_AGLUTI = '1'"
			cQuery +=   " AND D12.D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			cAliasNew := GetNextAlias()
			DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasNew,.F.,.T.)
			If (cAliasNew)->(!Eof())
				lRet   := .F. // Encontrou uma atividade anterior ainda não executada
				lAchou := .T.
			Else
				lAchou := .F.
				lRet   := Iif(!lReinicia,(oMovimento:GetStatus() $ "3|4"),(oMovimento:GetStatus() $ "2|3|4")) // Convoca se a atividade ainda nao foi executada
			EndIf
			(cAliasNew)->(dbCloseArea())
		EndIf
	ElseIf nTipoConv == 2 // Convocacao por TAREFA/PRODUTO
		// Não pode permitir convocar a atividade atual se alguma atividade
		// da tarefa atual, para o mesmo produto, que seja anterior a mesma não foi executada
		// ou se alguma atividade do movimento atual que seja anterior a mesma não foi executada
		cQuery := "SELECT DISTINCT D12.D12_FILIAL"
		cQuery +=  " FROM "+RetSqlName('D12')+" D12"
		cQuery += " WHERE D12.D12_FILIAL = '"+xFilial("D12")+"'"
		If lCarga
			cQuery += " AND D12.D12_CARGA = '"+oMovimento:oOrdServ:GetCarga()+"'"
		Else
			cQuery += " AND D12.D12_DOC = '"+oMovimento:oOrdServ:GetDocto()+"'"
			cQuery += " AND D12.D12_SERIE = '"+oMovimento:oOrdServ:GetSerie()+"'"
			cQuery += " AND D12.D12_CLIFOR = '"+oMovimento:oOrdServ:GetCliFor()+"'"
			cQuery += " AND D12.D12_LOJA = '"+oMovimento:oOrdServ:GetLoja()+"'"
		EndIf
		cQuery +=   " AND D12.D12_PRODUT = '"+oMovimento:oMovPrdLot:GetProduto()+"'"
		cQuery +=   " AND D12.D12_SERVIC = '"+oMovimento:oMovServic:GetServico()+"'"
		cQuery +=   " AND ((D12.D12_ORDTAR < '"+oMovimento:oMovServic:GetOrdem()+"')"
		cQuery +=   " OR (D12.D12_ORDTAR = '"+oMovimento:oMovServic:GetOrdem()+"'"
		cQuery +=   " AND D12.D12_IDMOV = '"+oMovimento:GetIdMovto()+"'"
		cQuery +=   " AND D12.D12_IDOPER < '"+oMovimento:GetIdOpera()+"'))"
		cQuery +=   " AND D12.D12_STATUS IN ('2','3','4')"
		cQuery +=   " AND D12.D_E_L_E_T_ = ' '"
		cQuery += " UNION ALL"
		cQuery +=" SELECT DISTINCT D12.D12_FILIAL"
		cQuery +=  " FROM "+RetSqlName('D12')+" D12"
		cQuery += " INNER JOIN "+RetSqlName('DCR')+" DCR"
		cQuery +=    " ON DCR.DCR_FILIAL = '"+xFilial("DCR")+"'"
		cQuery +=   " AND DCR.DCR_IDDCF = '"+oMovimento:oOrdServ:GetIdDCF()+"'"
		cQuery +=   " AND DCR.DCR_IDORI <> DCR.DCR_IDDCF"
		cQuery +=   " AND DCR.DCR_IDMOV < '"+oMovimento:GetIdMovto()+"'"
		cQuery +=   " AND DCR.DCR_IDOPER < '"+oMovimento:GetIdOpera()+"'"
		cQuery +=   " AND DCR.D_E_L_E_T_ = ' '"
		cQuery += " WHERE D12.D12_FILIAL = '"+xFilial("D12")+"'"
		cQuery +=   " AND D12.D12_PRODUT = '"+oMovimento:oMovPrdLot:GetProduto()+"'"
		cQuery +=   " AND D12.D12_SERVIC = '"+oMovimento:oMovServic:GetServico()+"'"
		cQuery +=   " AND (D12.D12_ORDTAR < '"+oMovimento:oMovServic:GetOrdem()+"'"
		cQuery +=   " OR (D12.D12_ORDTAR = '"+oMovimento:oMovServic:GetOrdem()+"' AND D12.D12_ORDATI < '"+oMovimento:oMovServic:GetOrdem()+"'))"
		If oMovimento:oMovServic:ChkRecebi()
			cQuery +=   " AND D12.D12_LOCDES = '"+oMovimento:oMovEndDes:GetArmazem()+"'"
			cQuery +=   " AND D12.D12_ENDDES = '"+oMovimento:oMovEndDes:GetEnder()+"'"
		Else
			cQuery +=   " AND D12.D12_LOCORI = '"+oMovimento:oMovEndOri:GetArmazem()+"'"
			cQuery +=   " AND D12.D12_ENDORI = '"+oMovimento:oMovEndOri:GetEnder()+"'"
		EndIf
		cQuery +=   " AND D12.D12_IDDCF = DCR.DCR_IDORI"
		cQuery +=   " AND D12.D12_IDMOV = DCR.DCR_IDMOV"
		cQuery +=   " AND D12.D12_IDOPER = DCR.DCR_IDOPER"
		cQuery +=   " AND D12.D12_STATUS IN ('2','3','4')"
		cQuery +=   " AND D12.D12_RADIOF = '1'"
		cQuery +=   " AND D12.D12_AGLUTI = '1'"
		cQuery +=   " AND D12.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasNew := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasNew,.F.,.T.)
		If (cAliasNew)->(!Eof())
			lRet   := .F. // Encontrou uma atividade anterior ainda não executada
			lAchou := .T.
		Else
			lAchou := .F.
			lRet   := Iif(!lReinicia,oMovimento:GetStatus() $ "3|4", oMovimento:GetStatus() $ "2|3|4") // Convoca se a atividade ainda nao foi executada
		EndIf
		(cAliasNew)->(dbCloseArea())
	Else // Convocacao por TAREFA COMPLETA
		// Não pode permitir convocar a atividade atual se alguma atividade da tarefa anterior
		// não foi executada, ou seja, se a tarefa anterior não foi completamente finalizada
		// ou se alguma atividade do movimento atual que seja anterior a mesma não foi executada
		cQuery := "SELECT DISTINCT D12.D12_FILIAL"
		cQuery +=  " FROM "+RetSqlName('D12')+" D12"
		cQuery += " WHERE D12_FILIAL = '"+xFilial("D12")+"'"
		If lCarga
			cQuery += " AND D12_CARGA = '"+oMovimento:oOrdServ:GetCarga()+"'"
		Else
			cQuery += " AND D12_DOC = '"+oMovimento:oOrdServ:GetDocto()+"'"
			If oMovimento:oOrdServ:GetOrigem() <> "SC9"
				cQuery += " AND D12_SERIE  = '"+oMovimento:oOrdServ:GetSerie()+"'"
			EndIf
			cQuery += " AND D12_CLIFOR = '"+oMovimento:oOrdServ:GetCliFor()+"'"
			cQuery += " AND D12_LOJA = '"+oMovimento:oOrdServ:GetLoja()+"'"
		EndIf
		cQuery +=   " AND D12_SERVIC = '"+oMovimento:oMovServic:GetServico()+"'"
		cQuery +=   " AND ((D12_ORDTAR < '"+oMovimento:oMovServic:GetOrdem()+"')"
		cQuery +=   " OR (D12_ORDTAR = '"+oMovimento:oMovServic:GetOrdem()+"'"
		cQuery +=   " AND D12_IDMOV = '"+oMovimento:GetIdMovto()+"'"
		cQuery +=   " AND D12_IDOPER < '"+oMovimento:GetIdOpera()+"'))"
		cQuery +=   " AND D12_STATUS IN ('2','3','4')"
		cQuery +=   " AND D12.D_E_L_E_T_ = ' '"
		cQuery += " UNION ALL"
		cQuery +=" SELECT DISTINCT D12.D12_FILIAL"
		cQuery +=  " FROM "+RetSqlName('D12')+" D12"
		cQuery += " INNER JOIN "+RetSqlName('DCR')+" DCR"
		cQuery +=    " ON DCR.DCR_FILIAL = '"+xFilial("DCR")+"'"
		cQuery +=   " AND DCR.DCR_IDDCF = '"+oMovimento:oOrdServ:GetIdDCF()+"'"
		cQuery +=   " AND DCR.DCR_IDORI <> DCR.DCR_IDDCF"
		cQuery +=   " AND DCR.DCR_IDMOV < '"+oMovimento:GetIdMovto()+"'"
		cQuery +=   " AND DCR.DCR_IDOPER < '"+oMovimento:GetIdOpera()+"'"
		cQuery +=   " AND DCR.D_E_L_E_T_ = ' '"
		cQuery += " WHERE D12.D12_FILIAL = '"+xFilial("D12")+"'"
		cQuery +=   " AND D12_SERVIC = '"+oMovimento:oMovServic:GetServico()+"'"
		cQuery +=   " AND (D12_ORDTAR < '"+oMovimento:oMovServic:GetOrdem()+"'"
		cQuery +=   " OR D12_ORDTAR = '"+oMovimento:oMovServic:GetOrdem()+"')"
		If oMovimento:oMovServic:ChkRecebi()
			cQuery +=   " AND D12.D12_LOCDES = '"+oMovimento:oMovEndDes:GetArmazem()+"'"
			cQuery +=   " AND D12.D12_ENDDES = '"+oMovimento:oMovEndDes:GetEnder()+"'"
		Else
			cQuery +=   " AND D12.D12_LOCORI = '"+oMovimento:oMovEndOri:GetArmazem()+"'"
			cQuery +=   " AND D12.D12_ENDORI = '"+oMovimento:oMovEndOri:GetEnder()+"'"
		EndIf
		cQuery +=   " AND D12.D12_IDDCF = DCR.DCR_IDORI"
		cQuery +=   " AND D12.D12_IDMOV = DCR.DCR_IDMOV"
		cQuery +=   " AND D12.D12_IDOPER = DCR.DCR_IDOPER"
		cQuery +=   " AND D12.D12_STATUS IN ('2','3','4')"
		cQuery +=   " AND D12.D12_RADIOF = '1'"
		cQuery +=   " AND D12.D12_AGLUTI = '1'"
		cQuery +=   " AND D12.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasNew := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasNew,.F.,.T.)
		If (cAliasNew)->(!Eof())
			lRet   := .F. // Encontrou uma atividade anterior ainda não executada
			lAchou := .T.
		Else
			lAchou := .F.
			lRet   := Iif(!lReinicia, oMovimento:GetStatus() $ "3|4", oMovimento:GetStatus() $ "2|3|4" ) // Convoca se a atividade ainda nao foi executada
		EndIf
		(cAliasNew)->(dbCloseArea())
	EndIf
	If ExistBlock('DLGVEXAN')
		lRetPE := ExecBlock('DLGVEXAN', .F., .F., {lRet, nRecOri, lAchou, cRecHum})
		If Valtype(lRetPE) == "L"
			lRet := lRetPE
		EndIf
	EndIf
	RestArea(aAreaAnt)
Return lRet
/*--------------------------------------------------------------------------------
---CtrlClock
---Relogio com Data e Hora do Sistema
---Fernando J. Siquini - 01/07/2003
---lAllwaysOn, Logico, (Indica se sempre ligado)
----------------------------------------------------------------------------------*/
Static Function CtrlClock(lAllwaysOn)
Local aTelaAnt   := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local aSemana    := {'Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab'}
Local aMeses     := {'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'}
Local cAmPm      := STR0001   // am'
Local cDiaSem    := ''
Local cDia       := ''
Local cMes       := ''
Local cAno       := ''
Local cHora      := ''
Local cMin       := ''
Local cSeg       := ''
Local cString1   := ''
Local cString2   := ''
Local nTimeIni   := Seconds()

Default lAllwaysOn := .F.

	WMSVTCabec(STR0027, .F., .F., .T.)   // Data/Hora
	Do While .T.
		cDiaSem := aSemana[Dow(dDataBase)]
		cDia    := StrZero(Day(dDataBase), 2)
		cMes    := aMeses[Month(dDataBase)]
		cAno    := StrZero(Year(dDataBase),4)
		cHora   := Left(Time(),2)
		cMin    := Subs(Time(),4,2)
		cSeg    := Right(Time(),2)
		cAmPm   := STR0001   // am
		If Val(cHora) > 12 .And. Val(cHora) <= 23
			cHora := StrZero(Val(cHora) - 12,2)
			cAmPm := STR0014  // pm
		EndIf
		cString1 := cDiaSem + ' ' + cDia + '/' + cMes + '/' + cAno
		cString2 := cHora + ':' + cMin + ':' + cSeg + ' ' + cAmPm
		@ Int(VTMaxRow()/2)  , 00 VTSay PadC(cString1, VTMaxCol())
		@ Int(VTMaxRow()/2)+1, 00 VTSay PadC(cString2, VTMaxCol())
		WMSVTRodPe(Nil, .F.)
		If VTInkey() == 13 .Or. If(!lAllwaysOn, (Seconds()-nTimeIni)>300, .T.)
			Exit
		EndIf
		Sleep(1000)
	EndDo
	VTInkey()
	VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
Return Nil
// -----------------------------------------------------------
/*/{Protheus.doc} WMSVTCabec
Exibe um Cabecalho Padrao de 20 caracteres na Linha ZERO
para a Tarefa a ser executada.
@author Fernando J. Siquini
@since 29/12/2002
@version 1.0
@param cCabec, character, (Titulo do cabecalho (se NIL considera o cCadastro))
@param lRolaUP, boleano, (Rola a tela anterior para Cima)
@param lRolaDW, boleano, (Rola a tela anterior para Baixo)
@param lClear, boleano, (Limpa a tela anterior)
/*/
// -----------------------------------------------------------
Static Function WMSVTCabec(cCabec, lRolaUP, lRolaDW, lClear)
Default cCabec     := STR0028 // Tarefa
Default lRolaUP    := .T.
Default lRolaDW    := .F.
Default lClear     := .F.
	If lClear
		VTclear() // Limpa a tela Anterior
	ElseIf lRolaDW
		WMSVTRolDW() // Rola a tela Anterior p/Baixo
	Else
		WMSVTRolUP() // Rola a tela Anterior p/Baixo
	EndIf
	cCabec := FWCutOff(cCabec,.T.)
	@ 0,0 VTSay PadC(cCabec, VTMaxCol(), '_')
Return Nil
// -----------------------------------------------------------
/*/{Protheus.doc} WMSVTRodPe
Exibe um Rodape Padrao de 20 caracteres nas Linhas CINCO
e SEIS com informacoes ao usuario
@author Fernando J. Siquini
@since 29/12/2002
@version 1.0
@param cRodaPe, character, (Conteudo Rodape (NIL considera "Pressione <ENTER>"))
@param lWait, boleano, (Espera a digitacao de alguma tecla? )
/*/
// -----------------------------------------------------------
Static Function WMSVTRodPe(cRodaPe, lWait)

Default cRodaPe    := STR0029 // Pressione <ENTER>'
Default lWait      := .T.
	cRodaPe := FWCutOff(cRodaPe,.T.)
	If VTRow() <= (VTMaxRow()-1)
		@ (VTMaxRow()-1), 00 VTSay Replicate('_', VTMaxCol())
	EndIf
	If VTRow() <= VTMaxRow()
		@ VTMaxRow(), 00 VTSay PadC(cRodaPe, VTMaxCol())
	EndIf
	If lWait
		VTInkey(0)
	EndIf
Return Nil
/*--------------------------------------------------------------------------------
---WMSVTRolUP
---Rola a tela atual para cima
---Fernando J. Siquini - 29/04/2002
----------------------------------------------------------------------------------*/
Static Function WMSVTRolUP()
Local nX := 0
	For nX := 1 to VTMaxRow()
		VTScroll(00, 00, VTMaxRow(), VTMaxCol(), 1)
	Next nX
Return Nil
/*--------------------------------------------------------------------------------
---WMSVTRolDW
---Rola a tela atual para Baixo
---Fernando J. Siquini - 29/04/2002
----------------------------------------------------------------------------------*/
Static Function WMSVTRolDW()
Local nX := 0
	For nX := 1 to VTMaxRow()
		VTScroll(00, 00, VTMaxRow(), VTMaxCol(), -1)
	Next nX
Return Nil
/*--------------------------------------------------------------------------------
---DispFuncWMS
---Lista de funções WMS
---Fernando J. Siquini - 31/05/2004
---aFuncoesWMS, Array
----------------------------------------------------------------------------------*/
Static Function DispFuncWMS(aFuncoesWMS)
Local aCab       := {'N.',STR0008}  // Funcoes Atrib.      '
Local aSize      := {Len(aCab[1]), Len(aCab[2])}
Local aTelaAnt   := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local aFuncoes   := {}
Local nX         := 0

	For nX := 1 to Len(aFuncoesWMS)
		aAdd(aFuncoes, {StrZero(aFuncoesWMS[nX, 1], 2), aFuncoesWMS[nX, 3]})
	Next nX

	If Len(aFuncoes) > 0
		VTClear()
		For nX := 1 to VTMaxRow()-1
			@ nX, 00 VTSay PadR('  |', VTMaxCol())
		Next nX
		WMSVTRodPe(, .F.)
		VTaBrowse(00, 00, Min(VTMaxRow()-1,Len(aFuncoes)+1), VTMaxCol(), aCab, aFuncoes, aSize)
	Else
		WMSVTAviso(WMSV00109, STR0035) // Nenhuma Funcao Cadastrada...
	EndIf

	VTRestore(00, 00, VTMaxRow()  , VTMaxCol(), aTelaAnt)
Return Nil
/*--------------------------------------------------------------------------------
---ChkDtAtu
---MV_WMSAtDt = Atualiza data do Protheus com data atual para gravacao da data
---no D12 para RF
---Fernando J. Siquini - 31/05/2004
----------------------------------------------------------------------------------*/
Static Function ChkDtAtu()
Local lWMSAtDt := (SuperGetMV('MV_WMSATDT', .F., 'S')=='S') // Indica se a data do Protheus deve ser atualizada se diferente da data do sistema
	If dDataBase # Date() .And. lWMSAtDt
		dDataBase := Date()
	EndIf
Return NIL
/*--------------------------------------------------------------------------------
---QryValAtCv
---Monta a Query que valida as atividades para convocação
---Jackson Patrick Werka - 01/04/2015
---cRecHum, caracter, (Recurso logado)
---cFuncao, caracter, (Função para analise de convocação)
---cUsuArma, caracter, (Armazem logado)
---nRecnoD12, númerico, (recno D12)
---lStBloq, logico, (Considera status bloqueado)
---lFiltraSer, logico
---lFiltraDoc, logico
---lFiltraPrd, logico (Considera dados da etiqueta bipada)
---cProduto, caracter, (Código do produto na etiqueta)
---nQtde, numerico, (Quantidade do produto na etiqueta)
---cLoteCtl, caracter, (Lote do produto na etiqueta)
---cNumLote, caracter, (Sub-Lote do produto na etiqueta)
---cEndDes, caracter, (Endreço destino)
---cUnitizDig, caracter, (Unitizador digitado na troca de atividade)
----------------------------------------------------------------------------------*/
Static Function QryValAtCv(cRecHum,cFuncao,cUsuArma,nRecnoD12,lStBloq,lFiltraSer,lFiltraDoc,lFiltraPrd,cProduto,nQtde,cLoteCtl,cNumLote,cNumSerie,cEndDes,cUnitizDig)
Local cRecHumVz := PadR("", TamSx3("D12_RECHUM")[1])
Local aAreaD12  := D12->(GetArea())
Local cQuery    := ""
Default lStBloq := .F.
Default lFiltraPrd := .F.
Default cProduto := ""
	D12->(dbGoTo(nRecnoD12))
	cQuery := "SELECT CASE"
	cQuery +=           " WHEN (D12.D12_STATUS = '3' AND D12.D12_RECHUM = '"+cRecHum+"' AND D12_QTDMOV <> D12_QTDLID) THEN 0"
	cQuery +=           " WHEN (D12.D12_STATUS = '2' AND D12.D12_RECHUM = '"+cRecHum+"')                              THEN 1"
	cQuery +=           " WHEN (D12.D12_STATUS = '4' AND D12.D12_RECHUM = '"+cRecHum+"')                              THEN 2"
	cQuery +=           " WHEN (D12.D12_STATUS = '3' AND D12.D12_RECHUM = '"+cRecHum+"' AND D12_QTDMOV = D12_QTDLID)  THEN 3"
	cQuery +=           " WHEN (D12.D12_STATUS = '4' AND D12.D12_RECHUM = '"+cRecHumVz+"')                            THEN 4"
	cQuery +=           " WHEN (D12.D12_STATUS = '3' AND D12.D12_RECHUM = '"+cRecHumVz+"')                            THEN 5"
	cQuery +=        " ELSE 99 "
	cQuery +=        " END AS ORDWMS,"
	cQuery +=        " D12.R_E_C_N_O_ RECD12 , D12_ENDORI , D12_ENDDES"
	cQuery +=   " FROM " + RetSqlName('D12')+" D12 "
	cQuery +=  " WHERE D12.D12_FILIAL = '"+xFilial("D12")+"'"
	// Verifica a versao e o paramentro que permite reabrir tarefa paralizadas
	If lStBloq
		cQuery += " AND D12.D12_STATUS IN ('2','3','4')"
	Else
		cQuery += " AND D12.D12_STATUS IN ('3','4')"
	EndIf
	If lFiltraSer .And. !lFiltraPrd
		cQuery += " AND D12.D12_SERVIC = '"+D12->D12_SERVIC+"'"
		cQuery += " AND D12.D12_TAREFA = '"+D12->D12_TAREFA+"'"
		cQuery += " AND D12.D12_ATIVID = '"+D12->D12_ATIVID+"'"
		cQuery += " AND D12.D12_ORDTAR = '"+D12->D12_ORDTAR+"'"
		cQuery += " AND D12.D12_ORDATI = '"+D12->D12_ORDATI+"'"
	EndIf
	cQuery += " AND D12.D12_RHFUNC = '"+cFuncao+"'"
	If !Empty(cUsuArma)
		cQuery += " AND D12.D12_LOCORI = '"+cUsuArma+"'"
	EndIf
	If lFiltraDoc
		If WmsCarga(D12->D12_CARGA)
			cQuery +=  " AND D12.D12_CARGA = '"+D12->D12_CARGA+"'"
		Else
			cQuery +=  " AND D12.D12_DOC    = '"+D12->D12_DOC+"'"
			cQuery +=  " AND D12.D12_CLIFOR = '"+D12->D12_CLIFOR+"'"
			cQuery +=  " AND D12.D12_LOJA   = '"+D12->D12_LOJA+"'"
		EndIf
	EndIf
	// Condições utilizadas quando é informado um produto diferente do convocado, função SeekAtivid.
	If lFiltraPrd
		cQuery += " AND D12.D12_PRODUT = '"+cProduto+"'"
		// Filta por quantidade informada na etiqueta
		If !Empty(nQtde)
			cQuery += " AND D12.D12_QTDMOV >= "+cValtoChar(nQtde)
		EndIf
		// Filtra pelo lote infomado na etiqueta
		If !Empty(cLoteCtl)
			cQuery += " AND D12.D12_LOTECT = '"+cLoteCtl+"'"
		EndIf
		// Filtra pelo sub-lote infomado na etiqueta
		If !Empty(cNumLote)
			cQuery += " AND D12.D12_NUMLOT = '"+cNumLote+"'"
		EndIf
		// Filtra pelo numero de série
		If !Empty(cNumSerie)
			cQuery += " AND D12.D12_NUMSER = '"+cNumSerie+"'"
		EndIf
		cQuery += " AND D12.D12_ENDORI = '"+D12->D12_ENDORI+"'"
	EndIf
	cQuery += " AND D12.D12_RADIOF = '1'"
	If !Empty(cEndDes)
		cQuery += " AND D12.D12_ENDDES = '"+cEndDes+"'"
	EndIf
	If nRecnoD12 <> 0
		cQuery += " AND D12.R_E_C_N_O_ <> "+AllTrim(Str(nRecnoD12))
	EndIf
	If !Empty(cUnitizDig)
		cQuery += " AND D12.D12_IDUNIT = '"+cUnitizDig+"'"
	EndIf
	If ExistBlock('DLV001WH')
		cQuery += ExecBlock('DLV001WH',.F.,.F.,{cRecHum,cFuncao})
	EndIf
	cQuery += " AND D12.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY ORDWMS, "

	If ExistBlock('DLV001ORD')
		cQuery += ExecBlock('DLV001ORD', .F., .F., {1})
	Else
		cQuery += SqlOrder(D12->(IndexKey(1))) // D12_FILIAL+D12_STATUS+D12_PRIORI+D12_CARGA+D12_DOC+D12_SERIE+D12_CLIFOR+D12_LOJA+D12_SERVIC+D12_ORDTAR+D12_ORDATI
	EndIf
	cQuery := ChangeQuery(cQuery)
	RestArea(aAreaD12)
Return cQuery
// -----------------------------------------------------------
/*/{Protheus.doc} WMSMultAti
Verifica se existe mais alguma atividade a ser executada no modo
multi-tarefa possibilitando ao usuário executar diversas
atividades sem ter a necessidade de finalizar a anterior.
@author Jackson Patrick Werka
@since 01/04/2015
@version 1.0
@param nRecnoD12, númerico, (recno da ordem de serviço WMS (D12))
/*/
// -----------------------------------------------------------
Static Function WMSMultAti(nRecnoD12)
Local aAreaAnt   := GetArea()
Local cAliasAtv  := GetNextAlias()
Local cFuncao    := aParConv[1]
Local cRecHum    := aParConv[3]
Local cUsuArma   := aParConv[4]
Local cUsuZona   := aParConv[5]
Local nTipoConv  := aParConv[6]
Local dDataFec   := aParConv[7]
Local cQuery     := ""
Local lConvoca   := .F.
	cQuery := QryValAtCv(cRecHum,cFuncao,cUsuArma,nRecnoD12,lReinAuto,.T.,.F.)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasAtv,.F.,.T.)
	While (cAliasAtv)->(!Eof())
		// verifica se o registro do D12 ja foi executado pelo processo de multi-tarefas
		If AScan(oMovimento:GetArrCol(),{|x|x[1] == (cAliasAtv)->RECD12 }) > 0
			(cAliasAtv)->(DbSkip())
			Loop
		EndIf
		// Não precisa avaliar as tabelas DC5 e DC6, pois deve ser a mesma atividade
		If !ChkAvalD12((cAliasAtv)->RECD12,cRecHum,cFuncao,cUsuArma,cUsuZona,nTipoConv,dDataFec)
			(cAliasAtv)->(DbSkip())
			Loop
		EndIf
		// Selecionar outra tarefa?
		If WMSVTAviso(WMSV00111,STR0034,{STR0016,STR0017},,2) == 1 // Tarefa // Selecionar outra tarefa? // Sim // Nao
			WMSConvD12(oMovimento:GetRecno())
			lConvoca := .T.
		EndIf
		Exit
	EndDo
	(cAliasAtv)->(DbCloseArea())
	If !lConvoca
		// Retorno registro atual
		oMovimento:GoToD12(nRecnoD12)
	Else
		// Seta D12_STATUS para Servico em Execucao
		If U_WAltSts()
			oMovimento:SetRecHum(cRecHum)
			oMovimento:SetStatus("3")
			oMovimento:SetDataIni(dDataBase)
			oMovimento:SetHoraIni(Time())
			oMovimento:SetDataFim(CTOD(""))
			oMovimento:SetHoraFim("")
			oMovimento:UpdateD12()
		EndIf
	EndIf
	RestArea(aAreaAnt)
Return lConvoca
// -----------------------------------------------------------
/*/{Protheus.doc} WMSMultApn
Verifica se existe mais alguma atividade a ser executada quando
o apanhe permite selecionar vários movimentos desde que não sejam
maior que a norma do produto, possibilitando ao usuário executar
diversas atividades sem ter a necessidade de finalizar a anterior.
@author Jackson Patrick Werka
@since 01/04/2015
@version 1.0
@param nRecnoD12, númerico, (recno da ordem de serviço WMS (D12))
/*/
// -----------------------------------------------------------
User Function MultApn(nRecnoD12)
Local aAreaD12  := D12->(GetArea())
Local aAreaAnt  := GetArea()
Local cAliasAtv := GetNextAlias()
Local cFuncao   := aParConv[1]
Local cRecHum   := aParConv[3]
Local cUsuArma  := aParConv[4]
Local cUsuZona  := aParConv[5]
Local nTipoConv := aParConv[6]
Local dDataFec  := aParConv[7]
Local cQuery    := ""
Local lConvoca  := .F.
Local lWmsDaEn  := SuperGetMV("MV_WMSDAEN",.F.,.F.) // Descarga apenas considerando o endereço sem o armazém

	cQuery := QryValAtCv(cRecHum,cFuncao,cUsuArma,nRecnoD12,lReinAuto,.T.,.T.)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasAtv,.F.,.T.)
	While (cAliasAtv)->(!Eof())
		// verifica se o registro do D12 ja foi executado pelo processo de multi-tarefas
		If AScan(oMovimento:GetArrCol(),{|x|x[1] == (cAliasAtv)->RECD12 }) > 0
			(cAliasAtv)->(DbSkip())
			Loop
		EndIf
		// Verificar se o endereço destino é o mesmo
		// Caso não seja irá procurar se existe outra atividade para o mesmo endereço
		// Obs.: Nessa quando os endereço de uma mesma carga ou documento irá pular
		//       desreitando a sequencia de convocação
		D12->(dbGoTo((cAliasAtv)->RECD12))
		If (IIf(lWmsDaEn,D12->D12_LOCDES,"")+D12->D12_ENDDES) <> ;
		   (IIf(lWmsDaEn,oMovimento:oMovEndDes:GetArmazem(),"")+oMovimento:oMovEndDes:GetEnder())
			(cAliasAtv)->(DbSkip())
			Loop
		EndIf
		// Não precisa avaliar as tabelas DC5 e DC6, pois deve ser a mesma atividade
		If !ChkAvalD12((cAliasAtv)->RECD12,cRecHum,cFuncao,cUsuArma,cUsuZona,nTipoConv,dDataFec)
			(cAliasAtv)->(DbSkip())
			Loop
		EndIf
		// Verifica se o D12 a ser convocado não é uma norma, neste caso força a descarga dos anteriores
		If QtdComp(oMovimento:GetQtdMov()) < QtdComp(DLQtdNorma(oMovimento:oMovPrdLot:GetProduto(),oMovimento:oMovEndOri:GetArmazem(),oMovimento:oMovEndOri:GetEstFis(),,.F.))
			WMSConvD12(oMovimento:GetRecno())
			lConvoca := .T.
		EndIf
		Exit
	EndDo
	(cAliasAtv)->(DbCloseArea())

	If !lConvoca
		// Retorno registro atual
		oMovimento:GoToD12(nRecnoD12)
	Else
		// Seta D12_STATUS para Servico em Execucao
		If U_WAltSts()
			oMovimento:SetRecHum(cRecHum)
			oMovimento:SetStatus("3")
			oMovimento:SetDataIni(dDataBase)
			oMovimento:SetHoraIni(Time())
			oMovimento:SetDataFim(CTOD(""))
			oMovimento:SetHoraFim("")
			oMovimento:UpdateD12()
		EndIf
	EndIf
	RestArea(aAreaAnt)
	RestArea(aAreaD12)
Return lConvoca
/*--------------------------------------------------------------------------------
---PendDocAnt
---Verifica se há atividades pendentes que podem ser realizadas
---pelo recurso
---Alexsander.correa - 22/08/2013
---cRecHum, caracter, (Recurso logado)
---cFuncao, caracter, (Função para analise de convocação)
---cUsuZona, caracter, (Armazem logado)
----------------------------------------------------------------------------------*/
Static Function PendDocAnt(cRecHum,cFuncao,cUsuZona)
Local lRet      := .F.
Local cAliasDCQ := GetNextAlias()
Local cAliasDoc := GetNextAlias()
Local aAreaD12  := D12->(GetArea())
Local cArmazem  := ""
Local cNumero   := ""
Local lContinua := .F.
Local cQuery    := ""
Local cCargaPed := ""
	// D12 da atividade anterior
	D12->(dbGoTo(__nRecD12))
	If D12->(!Eof())
		oServico:SetServico(D12->D12_SERVIC)
		oServico:SetOrdem(D12->D12_ORDTAR)
		oServico:LoadData()
		// Poderão ser utilizados os metodos de checagem pois a ordem da tarefa foi atribuída.
		If oServico:ChkSepara()
			If WmsCarga(oMovimento:oOrdServ:GetCarga())
				cCargaPed := oMovimento:oOrdServ:GetCarga()
			Else
				cCargaPed := oMovimento:oOrdServ:GetDocto()+oMovimento:oOrdServ:GetCliFor()+oMovimento:oOrdServ:GetLoja()
			EndIf
			// Verifica se a documento/carga é diferente do atual
			If cCargaPed <> Iif(WmsCarga(D12->D12_CARGA), D12->D12_CARGA,D12->D12_DOC+D12->D12_CLIFOR+D12->D12_LOJA)
				cNumero := Left(D12->D12_DOC,Len(SD7->D7_NUMERO))
				SD7->(DbSetOrder(3))
				If SD7->(MsSeek(xFilial('SD7')+D12->D12_PRODUT+D12->D12_NUMSEQ+cNumero))
					cArmazem := SD7->D7_LOCAL
				Else
					cArmazem := D12->D12_LOCORI
				EndIf
				// Verifica se possui regra de convocação exclusiva por documento/carga
				cQuery := " SELECT DCQ_FILIAL, DCQ_TPREGR, DCQ_DOCEXC "
				cQuery += " FROM " + RetSqlName('DCQ')
				cQuery += " WHERE DCQ_FILIAL = '"+xFilial("DCQ")+"'"
				cQuery += " AND DCQ_DOCEXC <> '2' "
				cQuery += " AND DCQ_LOCAL = '"+D12->D12_LOCORI+"' "
				cQuery += " AND (DCQ_CODFUN = ' ' OR DCQ_CODFUN = '"+cRecHum+"') "
				cQuery += " AND (DCQ_CODZON = ' ' OR DCQ_CODZON = '"+cUsuZona+"') "
				cQuery += " AND (DCQ_SERVIC = ' ' OR DCQ_SERVIC = '"+D12->D12_SERVIC+"') "
				cQuery += " AND D_E_L_E_T_ <> '*' "
				cQuery := ChangeQuery(cQuery)
				DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasDCQ,.F.,.T.)
				If (cAliasDCQ)->(!Eof())
					lContinua := .T.
				EndIf
				(cAliasDCQ)->(DbCloseArea())
				 If lContinua
					// Se possui regra verifica se o documento anterior possui pendencias
					cQuery := QryValAtCv(cRecHum,cFuncao,cArmazem,__nRecD12,.F.,.T.,.T.)
					DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasDoc,.F.,.T.)
					If (cAliasDoc)->(!Eof())
						lRet := .T.
					EndIf
					(cAliasDoc)->(dbCloseArea())
				EndIf
			EndIf
		EndIf
	EndIf
	RestArea(aAreaD12)
Return lRet

// ---------------------------------------------------------
/*/{Protheus.doc} WmsEndDes
Atualiza o campo logico __lDestino para permitir o controle de convocacao
de serviços antes interrompidos que devido prioridade são executados
no meio de outra carga

@author  Alexsander Burigo Corrêa
@version P11
@Since    30/08/13
@obs  Atualiza o campo logico __lDestino para permitir o controle de convocacao
de serviços antes interrompidos que devido prioridade são executados
no meio de outra carga
/*/
// ---------------------------------------------------------
Static __lDestino := .F. // Determina se o produto foi enviado para o destino
User Function WEndDes(lDestino)
	If ValType(lDestino) == "L"
		__lDestino := lDestino
	EndIf
Return __lDestino

// ---------------------------------------------------------
/*/{Protheus.doc} U_WAltSts
Responsável por atualizar a situação do D12 após a execução da
atividade Caso seja passado o valor ele vai "setar" o valor
Caso não seja passado vai retornar o último valor salvo
@author  Alexsander Burigo Corrêa
@version P11
@Since    30/08/13
@obs  Responsável por atualizar a situação do D12
/*/
// ---------------------------------------------------------
Static __lAltSts := .T.
User Function WAltSts(lAltSts)
Local lOldAltSts := __lAltSts
	If ValType(lAltSts) == "L"
		__lAltSts := lAltSts
	EndIf
Return lOldAltSts
// ---------------------------------------------------------
/*/{Protheus.doc} WMSConvD12
Seta a próxima atividade a ser convocada, sem ter a
necessidade de remontar o SQL da rotina de convocação
automática. Utilizada no multi-tarefa e também quando o D12
é desmembrado em várias movimentações para convocar o novo D12.
@author  Jackson Patrick Werka
@version P11
@Since    30/08/13
@obs  Seta a próxima atividade a ser convocada
@param nRecnoD12, númerico, (recno da ordem de serviço WMS (D12))
@param lConvD12, boleano, (Indica se convoca D12)
/*/
// ---------------------------------------------------------
Static Function WMSConvD12(nRecnoD12,lConvD12)
Default lConvD12 := .T.
	__nRecD12  := nRecnoD12
	__lConvoca := lConvD12
Return Nil
/*--------------------------------------------------------------------------------
---HasPrdSai
---Verifica quantidade do produto movimentado
---Somente permite iniciar a conferência, caso alguma atividade de movimentação
---tenha sido executada, disponiblizando assim itens para conferência
---Jackson Patrick Werka - 22/08/2013
----------------------------------------------------------------------------------*/
Static Function HasPrdSai(lConfTot)
Local aAreaD12  := D12->(GetArea())
Local aAreaDC5  := DC5->(GetArea())
Local lRet      := .F.
Local cQuery    := ""
Local cAliasQry := GetNextAlias()
Default lConfTot := .F.

	cQuery := "SELECT DISTINCT DCF.DCF_FILIAL"
	cQuery +=  " FROM "+RetSqlName("DCF")+" DCF, "+RetSqlName("DCR")+" DCR, "+RetSqlName("D12")+" D12"
	cQuery += " WHERE DCF.DCF_FILIAL = '"+xFilial("DCF")+"'"
	cQuery +=   " AND DCF.DCF_SERVIC = '"+oMovimento:oMovServic:GetServico()+"'"
	If WmsCarga(oMovimento:oOrdServ:GetCarga())
		cQuery += " AND DCF.DCF_CARGA = '"+oMovimento:oOrdServ:GetCarga()+"'"
	Else
		cQuery += " AND DCF.DCF_DOCTO = '"+oMovimento:oOrdServ:GetDocto()+"'"
	EndIf
	cQuery +=   " AND DCF.D_E_L_E_T_ = ' '"
	cQuery +=   " AND DCR.DCR_FILIAL = '"+xFilial("DCR")+"'"
	cQuery +=   " AND DCR.DCR_IDDCF  = DCF.DCF_ID"
	cQuery +=   " AND DCR.DCR_SEQUEN = DCF.DCF_SEQUEN"
	cQuery +=   " AND DCR.D_E_L_E_T_ = ' '"
	cQuery +=   " AND D12.D12_FILIAL = '"+xFilial("D12")+"'"
	cQuery +=   " AND D12.D12_SERVIC = DCF.DCF_SERVIC"
	cQuery +=   " AND D12.D12_IDDCF  = DCR.DCR_IDORI"
	cQuery +=   " AND D12.D12_IDMOV  = DCR.DCR_IDMOV"
	cQuery +=   " AND D12.D12_IDOPER = DCR.DCR_IDOPER"
	cQuery +=   " AND D12.D12_ORDTAR = '"+oMovimento:oMovServic:FindOrdAnt()+"'" // Assume a tarefa exatamante anterior
	cQuery +=   " AND D12.D12_ORDMOV IN ('3','4')"
	If lConfTot
		cQuery += " AND D12.D12_STATUS NOT IN ('0','1')"
	Else
		cQuery += " AND D12.D12_STATUS = '1'"
	EndIf
	cQuery +=   " AND D12.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	lRet := (cAliasQry)->(!Eof())
	(cAliasQry)->(DbCloseArea())

	RestArea(aAreaDC5)
	RestArea(aAreaD12)
Return lRet
// -----------------------------------------------------------
/*/{Protheus.doc} WMSValProd
Verifica se o codigo do produto é válido
@author Flavio Vicco
@since 01/08/2005
@version 1.0
@param cPrdOri, character, (Produto origem)
@param cProduto, character, (Produto)
@param cLoteCtl, character, (Lote do produto)
@param cNumLote, character, (Sub-lote do lote do produto)
@param nQtde, numérico, (Quantidade do produto)
@param cCodBar, character, (Código de barras)
@param lChkVol, Indica se valida se é volume
@param aVolume, array que retorna as informações do volume
@param lTrocaPrd, lógico, utilizado para informar a função WMSValProd trocou de produto convocado (referencia)
/*/
// -----------------------------------------------------------
Static Function WMSValProd(cProdOri,cProduto,cLoteCtl,cNumLote,nQtde,cCodBar,lChkVol,aVolume,lTrocaPrd)
Local aArea     := GetArea()
Local lRet      := .T.
Local aProduto  := {}
Local cCgPd     := ""
Local cLtSub    := ""
Local nQtdD02   := 0
Local nQtdDCV   := 0
Local lWmsNew   := SuperGetMv("MV_WMSNEW",.F.,.F.)
Local cEndDes   := ""

Default lChkVol := .F.
Default aVolume := {}

	VTClearBuffer()
	// Deve zerar estas informações, pois pode haver informação de outra etiqueta
	cProduto := Space(TamSx3("B8_PRODUTO")[1])
	cLoteCtl := Space(TamSx3("B8_LOTECTL")[1])
	cEndDes  := IIf(lWmsNew,Space(TamSx3("D12_ENDDES")[1]),"")
	nQtde    := 0.00

	aProduto := CBRetEtiEAN(cCodBar)
	If Len(aProduto) > 0
		cProduto := aProduto[1]
		nQtde    := 0 // Se nQtde = 0, solicita digitacao
		cLoteCtl := Padr(aProduto[3],TamSx3("B8_LOTECTL")[1])
		If ExistBlock("CBRETEAN")
			nQtde   := aProduto[2]
			cEndDes := IIf(lWmsNew .And. Len(aProduto) > 5,Padr(aProduto[6],TamSx3("D12_ENDDES")[1]),"")
		EndIf
	Else
		aProduto := CBRetEti(cCodBar, '01')
		If Len(aProduto) > 0
			cProduto := aProduto[1]
			nQtde    := aProduto[2]
			cLoteCtl := Padr(aProduto[16],TamSx3("B8_LOTECTL")[1])
			cNumLote := Padr(aProduto[17],TamSx3("B8_NUMLOTE")[1])
		EndIf
	EndIf
	// Verifica se encontrou produto
	If Empty(cProduto)
		// Caso não verifique se é volume retorna erro
		If !lChkVol
			WMSVTAviso(WMSV00112,STR0036) // Etiqueta invalida!
			VTKeyBoard(Chr(20))
			lRet := .F.
		Else
			// Verifica se é volume
			dbSelectArea("DCU")
			DCU->(dbSetOrder(1))
			If DCU->(dbSeek(xFilial("DCU")+AllTrim(cCodBar))) // Verifica se o codigo informado existe na tabela DCU
				While DCU->(!Eof()) .And. AllTrim(DCU->DCU_CODVOL) == AllTrim(cCodBar)
					dbSelectArea("DCV")
					DCV->(dbSetOrder(1))
					DCV->(dbSeek(xFilial("DCV")+DCU->DCU_CODMNT+DCU->DCU_CODVOL))
					While DCV->(!Eof()) .And. DCV->(DCV_FILIAL+DCV->DCV_CODMNT+DCV->DCV_CODVOL) == xFilial("DCV")+ DCU->(DCU_CODMNT+DCU->DCU_CODVOL)
						nQtdDCV  := DCV->DCV_QUANT
						//
						If cProduto <> DCV->DCV_CODPRO .Or. DCV->(DCV_CARGA+DCV_PEDIDO) <> cCgPd .Or. DCV->(DCV_LOTE+DCV_SUBLOTE) <> cLtSub
							cProduto := DCV->DCV_CODPRO
							cCgPd    := DCV->(DCV_CARGA+DCV_PEDIDO)
							cLtSub   := DCV->(DCV_LOTE+DCV_SUBLOTE)
							// Verifica se todos os produtos informados no volume estao na conferencia D02
							dbSelectArea("D02")
							D02->(dbSetOrder(2))
							If D02->(dbSeek(xFilial("D02")+DCV->DCV_CARGA+DCV->DCV_PEDIDO+DCV->DCV_PRDORI+DCV->DCV_CODPRO+DCV->DCV_LOTE+DCV->DCV_SUBLOT))
								nQtdD02 := D02->D02_QTSEPA
								// Adiciona produto
								aAdd(aVolume,{cProduto,nQtdD02,nQtdDCV,DCV->DCV_CARGA,DCV->DCV_PEDIDO,DCV->DCV_LOTE,DCV->DCV_SUBLOTE,DCV->DCV_ITEM,DCV->DCV_SEQUEN,DCV->DCV_PRDORI,DCV->DCV_CODVOL})
							EndIf
						Else
							aVolume[Len(aVolume)][3] += nQtdDCV
						EndIf
						DCV->(dbSkip())
					EndDo
					DCU->(dbSkip())
				EndDo
			EndIf
			If Empty(aVolume)
				WMSVTAviso(WMSV00118,STR0036) // Etiqueta invalida!
				VTKeyBoard(Chr(20))
				lRet := .F.
			EndIf
		EndIf
	EndIf
	If lRet
		// Se o produto origem para comparação for informado, confirma se é o mesmo
		If !Empty(cProdOri)
			If (!Empty(cEndDes) .And. cEndDes == oMovimento:oMovEndDes:GetEnder() .And. cProduto == cProdOri)  .or. (Empty(cEndDes) .And. cProduto == cProdOri)
				lRet := .T.
				If ExistBlock("DLV030VL") // Executado para efetuar a validação do produto digitado
					lRetPE:= ExecBlock('DLV030VL',.F.,.F.,{cProduto})
					lRet  := If(ValType(lRetPE)=="L",lRetPE,lRet)
				EndIf
				If !lRet
					WMSVTAviso(WMSV00113,WmsFmtMsg(STR0037,{{"[VAR01]",cProduto}})) // Produto [VAR01] não se encontra no documento atual.
					VTKeyBoard(Chr(20))
				EndIf
			ElseIf lWmsNew
				// Se o produto for diferente do origem, verifica se o produto
				// pode ser considerado, trocando o produto caso positivo.
				// ----------
				// Passa os dados do CBRetEtiEAN para posicionar no produto correto.
				If oMovimento:oMovServic:GetUpdAti() $ ("2|3")
					If !SeekAtivid(cProduto,nQtde,cLoteCtl,cNumLote,Nil,cEndDes,@lTrocaPrd)
						lRet := .F.
					EndIf
				Else
					WMSVTAviso(WMSV00122,WmsFmtMsg(STR0065,{{"[VAR01]",oMovimento:oMovServic:GetServico()}})) // Serviço [VAR01] não permite troca de produto na convocação
					VTKeyBoard(Chr(20))
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf
	If !lRet
		cCodBar := Space(128)
	EndIf
	RestArea(aArea)
Return (lRet)
// -----------------------------------------------------------
/*/{Protheus.doc} WMSValUnit
Validação do código do unitizador digitado no endereçamento 
e separação convocada 
@author felipe.m
@since 18/01/2018
@version 1.0
@param cUnitizDig, characters, código do unitizador digitado
@param cIdUnit, characters, código do unitizador do movimento
@return return, lógico
/*/
// -----------------------------------------------------------
Static Function WMSValUnit(cUnitizDig,cIdUnit)
Local lRet := .T.

	If Empty(cUnitizDig)
		lRet := .F.
	Else
		If !(cUnitizDig == cIdUnit)
			// ---------------------------------------------------------------------
			// Realiza a troca do unitizador caso o mesmo possua atividade pendente
			// ---------------------------------------------------------------------
			If oMovimento:oMovServic:ChkRecebi() .And. oMovimento:oMovServic:GetUpdAti() $ ("2|3")
				If !SeekAtivid(,,,,,,,cUnitizDig)
					lRet := .F.
				EndIf
			Else
				WMSVTAviso(WMSV00128,WmsFmtMsg(STR0071,{{"[VAR01]",cUnitizDig}})) // "O Unitizador [VAR01] não consta no documento atual."
				lRet := .F.
			EndIf
		EndIf
	EndIf
	If !lRet
		VTKeyBoard(chr(20))
	EndIf
Return(lRet)
// -----------------------------------------------------------
/*/{Protheus.doc} WmsValUM
Valida unidade de medida a quantidade da movimentação
@author Flavio Vicco
@since 01/08/2005
@version 1.0
@param nQtdTot, numérico, (quantidade total da movimentação na unidade selecionada)
@param cWmsUMI, character, (Tipo unidade configurada)
@param cUM, character, (Unidade de medida reduzida)
@param cProduto, character, (Produto)
@param cArmazem, character,(Armazem)
@param cEndereco, character, (Endereço)
@param nItem, numérico, (Indica o item selecionado da unidade de medida para situacao onde a quantidade já carregada)
/*/
// -----------------------------------------------------------
Static Function WmsValUM(nQtdTot,cWmsUMI,cProduto,cArmazem,cEndereco,nItem,lConf)
Local nQtdTot2   := 0
Local oProduto   := WMSDTCProdutoDadosGenericos():New()
Local oEndereco  := Nil
Local oSeqAbast  := Nil
Default cArmazem := ""
Default cProduto := ""
Default cEndereco:= ""
Default nQtdTot  := 0
Default nItem    := 0
Default lconf    := .F.

	cWmsUMI := "3"
	// Produto
	oProduto:SetProduto(cProduto)
	oProduto:LoadData()
	// Se o armazem estiver vazio, busca o armazem padrão.
	If Empty(cArmazem)
		cArmazem := oProduto:GetArmPadr()
	EndIf
	// Endereco
	If !lConf .And. !Empty(cArmazem) .And. !(Empty(cEndereco))
		oEndereco  := WMSDTCEndereco():New()
		oEndereco:SetArmazem(cArmazem)
		oEndereco:SetEnder(cEndereco)
		If oEndereco:LoadData()
			// Sequencia de abastecimento
			oSeqAbast  := WMSDTCSequenciaAbastecimento():New()
			oSeqAbast:SetArmazem(oEndereco:GetArmazem())
			oSeqAbast:SetProduto(oProduto:GetProduto())
			oSeqAbast:SetEstFis(oEndereco:GetEstFis())
			If oSeqAbast:LoadData(2)
				// Verifica unidade de medida
				cWmsUMI := IIf(Empty(oSeqAbast:GetUMMovto()),"1",oSeqAbast:GetUMMovto())
			EndIf
		EndIf
	EndIf
	// Verifica se na segunda unidade a quantidade é maior que 1 senão considera primeira unidade
	If cWmsUMI == "2"
		If Empty(oProduto:GetSegum())
			cWmsUMI := "1"
		Else
			nQtdTot2 := ConvUm(cProduto,nQtdTot,0,2)
			If QtdComp(nQtdTot2) < 1
				cWmsUMI := "1"
			Else
				nQtdTot := nQtdTot2
			EndIf
		EndIf
	EndIf
	// Considera a unidade de medida definida para o produto
	If cWmsUMI $ '1|2'
		nItem    := Iif(cWmsUMI == '1',3,2)
	ElseIf cWmsUMI == '3'
		nItem := 3
	EndIf
Return

// -----------------------------------------------------------
/*/{Protheus.doc} WmsMontPrd
Seleciona a unidade de medida
@author Flavio Vicco
@since 01/08/2005
@version 1.0
@param cWmsUMI, character
@param lConf, Lógico, (Indica que é conferência)
@param cDesTar, Character, (Descrição da atividade)
@param cArmazem, Character, (Armazém)
@param cEndereco, Character, (Endereco)
@param cProduto, Character, (Produto)
@param cLoteCtl, Character, (Lote)
@param cNumLote, Character, (Sub-lote)
@param cIdUnit, Character, (Unitizador)
/*/
// -----------------------------------------------------------
Static Function WmsMontPrd(cWmsUMI,lConf,cDesTar,cArmazem,cEndereco,cPrdOri,cProduto,cLoteCtl,cNumLote,cIdUnit)
Local lRet      := .T.
Local aTelaAnt  := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local lWmsLote  := SuperGetMV('MV_WMSLOTE',.F.,.F.) // Solicita a confirmacao do lote nas operacoes com RF
Local lDetProd  := SuperGetMV('MV_WMSVSTC',.F.,.F.) // Apresenta descricao do produto no coletor RF
Local oProdLote := WMSDTCProdutoLote():New()
Local oEndereco := WMSDTCEndereco():New()
Local nLin      := 1

Default cWmsUMI  := ""
Default lConf    := .F.
Default cLoteCtl := ""
Default cNumLote := ""
Default cIdUnit  := ""

	// Produto
	oProdLote:SetArmazem(cArmazem)
	oProdLote:SetPrdOri(cPrdOri)
	oProdLote:SetProduto(cProduto)
	oProdLote:SetLoteCtl(cLoteCtl)
	oProdLote:SetNumLote(cNumLote)
	oProdLote:SetNumSer("")
	oProdLote:LoadData()
	// Endereco
	oEndereco:SetArmazem(cArmazem)
	oEndereco:SetEnder(cEndereco)
	oEndereco:LoadData()
	//            1
	//  01234567890123456789
	// 0 _______Apanhe_______
	// 1 Pegue o produto
	// 2 WMS01
	// 3 PRODUTO WMS 01
	// 4
	// 5 Norma: L 10 x 10 C
	// 6 ___________________
	// 7 Pressione <ENTER>
	If lDetProd
		nLin := 1
		WMSVTCabec(cDesTar,.F.,.F.,.T.)
		@ nLin++,00 VTSay PadR(IIf(!lConf,STR0043,STR0056), VTMaxCol()) // Pegue o Produto // Dados do Produto
		@ nLin++,00 VTSay PadR(oProdLote:GetProdCol(),VTMaxCol())
		@ nLin++,00 VTSay PadR(SubStr(oProdLote:GetDesc(),1,VTMaxCol()),VTMaxCol())
		@ nLin++,00 VTSay PadR(SubStr(oProdLote:GetDesc(),VTMaxCol()+1,VTMaxCol()),VTMaxCol())
		@ nLin++,00 VTSay PadR(WmsDesNorma(oProdLote:GetProduto(),oEndereco:GetArmazem(),oEndereco:GetEstFis()),VTMaxCol())
		//Permite complementar a tela que solicita a coleta do produto
		If lWV001SCR
			ExecBlock("WV001SCR",.F.,.F.,{.T.,lConf,nLin})
		EndIf
		WMSVTRodPe()
	EndIf
	If !lConf
		//            1
		//  01234567890123456789
		// 0 _______Apanhe_______
		// 1 Pegue o Produto
		// 2 008
		// 3 Lote: AUTO000160
		// 4 Sub-Lote: 000160
		// 5 Unitizador
		// 6 000001
		// 7  Pressione <ENTER>
		If (cWmsUMI == "3" .And. !lDetProd) .Or. (lWmsLote .And. oProdLote:HasRastro())
			nLin := 1
			WMSVTCabec(cDesTar,.F.,.F.,.T.)
			@ nLin++,00 VTSay PadR(STR0043, VTMaxCol())  // Pegue o Produto'
			@ nLin++,00 VTSay PadR(oProdLote:GetProdCol(),VTMaxCol()) // aItens[nPos][2]
			If lWmsLote
				If oProdLote:HasRastro()
					@ nLin  ,00 VTSay PadR(STR0047,VTMaxCol()) // Lote:
					@ nLin++,06 VTSay PadR(oProdLote:GetLoteCtl(),VTMaxCol())
				EndIf
				If oProdLote:HasRastSub()
					@ nLin  ,00 VTSay PadR(STR0048,VTMaxCol()) // Sub-Lote:
					@ nLin++,10 VTSay PadR(oProdLote:GetNumLote(),VTMaxCol())
				EndIf
			EndIf
			If !Empty(cIdUnit)
				@ nLin++,00 VTSay PadR("Unitizador",VTMaxCol()) // Unitizador
				@ nLin++,00 VTSay PadR(cIdUnit,VTMaxCol())
			EndIf
			//Permite complementar a tela que solicita a coleta do produto
			If lWV001SCR
				ExecBlock("WV001SCR",.F.,.F.,{.F.,lConf,nLin})
			EndIf
			WMSVTRodPe()
		EndIf
	EndIf
	VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)

Return lRet

// -----------------------------------------------------------
/*/{Protheus.doc} WmsSelUM
Seleciona a unidade de medida
@author Flavio Vicco
@since 01/08/2005
@version 1.0
@param cWmsUMI, character
@param cUM, character
@param nQtdTot, numérico, (quantidade total da movimentação na unidade selecionada)
@param nItem, numérico, (Indica o item selecionado da unidade de medida)
@param cPictQt, character, (define apresentação do valor)
@param nQtdItem, numérico, (Quantidade selecionada do item da unidade de medida)
@param lConf, Lógico, (Indica que é conferência)
@param cDesTar, Character, (Descrição da atividade)
@param cArmazem, Character, (Armazém)
@param cEndereco, Character, (Endereco)
@param cProduto, Character, (Produto)
@param cLoteCtl, Character, (Lote)
@param cNumLote, Character, (Sub-lote)
/*/
// -----------------------------------------------------------
Static Function WmsSelUM(cWmsUMI,cUM,cDscUM,nQtdTot,nItem,cPictQt,nQtdItem,lConf,cDesTar,cArmazem,cEndereco,cPrdOri,cProduto,cLoteCtl,cNumLote)
Local lRet      := .T.
Local aCab      := {PadL(STR0045,15)+' '+STR0046}   // Qtde // UM
Local aTelaAnt  := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local aSize     := {VTMaxCol()}
Local aQtde     := {}
Local aUni      := {}
Local aQtdUni   := {}
Local lWmsNew   := SuperGetMv("MV_WMSNEW",.F.,.F.)
Local lWmsLote  := SuperGetMV('MV_WMSLOTE',.F.,.F.) // Solicita a confirmacao do lote nas operacoes com RF
Local lDetProd  := SuperGetMV('MV_WMSVSTC',.F.,.F.) // Apresenta descricao do produto no coletor RF
Local oProdLote := WMSDTCProdutoLote():New()
Local oEndereco := WMSDTCEndereco():New()
Local cD12Pict  := Iif(lWmsNew,PesqPict('D12','D12_QTDMOV'),"@E 999,999,999.99")
Local cD12Pict2 := Iif(lWmsNew,PesqPict('D12','D12_QTDMO2'),"@E 999,999,999.99")

Default lConf    := .F.
Default cDscUM   := ""
Default nQtdTot  := 0
Default nItem    := 0
Default nQtdItem := 0
Default cDesTar  := ""
Default cArmazem := RetFldProd(cProduto,"B1_LOCPAD")
Default cEndereco:= ""
Default cProduto := ""
Default cLoteCtl := ""
Default cNumLote := ""

	// Produto
	oProdLote:SetArmazem(cArmazem)
	oProdLote:SetPrdOri(cPrdOri)
	oProdLote:SetProduto(cProduto)
	oProdLote:SetLoteCtl(cLoteCtl)
	oProdLote:SetNumLote(cNumLote)
	oProdLote:SetNumSer("")
	oProdLote:LoadData()
	// Endereco
	oEndereco:SetArmazem(cArmazem)
	oEndereco:SetEnder(cEndereco)
	oEndereco:LoadData()

	WMSVTCabec(cDesTar,.F.,.F.,.T.)
	// Detalhamento Produto
	If cWmsUMI $ '1|2'
		nItem    := Iif(cWmsUMI == '1',3,2)
		cUM      := Iif(nItem==2,oProdLote:GetSegum(), oProdLote:GetUM())
		cDscUM   := Posicione('SAH',1,xFilial('SAH')+cUM,'AH_UMRES')
		cPictQt  := Iif(nItem==2,cD12Pict2,cD12Pict)
		nQtdItem := nQtdTot
	ElseIf cWmsUMI == '3'
		aQtdUni := WmsQtdUni(oProdLote:GetProduto(),oEndereco:GetArmazem(),oEndereco:GetEstFis(),nQtdTot)
		If !lConf
			aQtde := {}
			aItem:= {}
			If !Empty(aQtdUni[1,2])
				AAdd(aQtde,{PadL(Transform(aQtdUni[1,1],'@R 9999999999'),15)+' *'})
				AAdd(aItem,1)
			EndIf
			If !Empty(oProdLote:GetSegum()) .And. !Empty(aQtdUni[2,2])
				AAdd(aQtde,{PadL(Transform(aQtdUni[2,1],cD12Pict2),15)+' '+AllTrim(aQtdUni[2,2])})
				AAdd(aItem,2)
			EndIf
			AAdd(aQtde,{PadL(Transform(aQtdUni[3,1],cD12Pict),15)+' '+AllTrim(aQtdUni[3,2])})
			AAdd(aItem,3)
			//            1
			//  01234567890123456789
			// 0            Qtde UM
			// 1 -------------------
			// 2            1,00 *
			// 3            0,00 CX
			// 4            0,00 UN
			// 5 (*) PALETE PBRII
			// 6 ___________________
			// 7  Unidade p/ [VAR01]?
			Do While .T.
				nItem := 1
				If Len(aItem) > 1
					nItem    := ASCAN(aQtdUni, { |x| QtdComp(x[1]) > 0 })

					@ VTMaxRow()-2,0 VTSay PadR('(*) '+aQtdUni[1,2],VTMaxCol())
					WMSVTRodPe(PadR(WmsFmtMsg(STR0042,{{"[VAR01]",cDesTar}}),VTMaxCol()-1)+"?",.F.)   // Unidade p/ [VAR01]
					nItem := VTaBrowse(0,0,VTMaxRow()-3,VTMaxCol(),aCab,aQtde,aSize,,ASCAN(aItem,nItem))
					If (VTLastKey()==27)
						Exit
					EndIf
				EndIf
				If nItem > 0
					// Carrega o item selecionado de acordo com as unidades definidas.
					nItem    := aItem[nItem]
					cUM      := aQtdUni[nItem,2]
					cDscUM   := Iif(nItem==1,cDscUM,Posicione('SAH',1,xFilial('SAH')+cUM,'AH_UMRES'))
					cPictQt  := Iif(nItem==1,'@R 9999999999',Iif(nItem==2,cD12Pict2,cD12Pict))
					nQtdItem := aQtdUni[nItem,1]
				EndIf
				If nQtdItem <= 0
					WMSVTAviso(WMSV00114,STR0044) // Quantidade não pode ser igual a zero(0).
					Loop
				EndIf
				Exit
			EndDo
		Else
			Do While .T.
				//            1
				//  01234567890123456789
				// 0 UNIDADE
				// 1 -------------------
				// 2 PALETE PBRII    (*)
				// 3 CAIXA
				// 4 PECA
				// 5 ___________________
				// 6
				// 7 Unidade p/[VAR01]?
				aUni := {}
				aItem:= {}
				If !Empty(aQtdUni[1,2])
					AAdd(aUni, {AllTrim(aQtdUni[1,2])+IIf(!lConf," (*)","")})
					AAdd(aItem,1)
				EndIf
				If !Empty(oProdLote:GetSegum())
					AAdd(aUni, {Posicione('SAH',1,xFilial('SAH')+aQtdUni[2,2],'AH_UMRES')})
					AAdd(aItem,2)
				EndIf
				AAdd(aUni, {Posicione('SAH',1,xFilial('SAH')+aQtdUni[3,2],'AH_UMRES')})
				AAdd(aItem,3)
				nItem := 1
				If Len(aItem) > 1
					WMSVTRodPe(PadR(WmsFmtMsg(STR0042,{{"[VAR01]",cDesTar}}),VTMaxCol()-1)+"?",.F.)   // Unidade p/ [VAR01]'
					nItem  := VTaBrowse(0,0,VTMaxRow()-3,VTMaxCol(),{RetTitle("B1_UM")},aUni,aSize,,nItem)
					If (VTLastKey()==27)
						Exit
					EndIf
				EndIf
				If nItem > 0
					// Carrega o item selecionado de acordo com as unidades definidas.
					cDscUM := Alltrim(aUni[nItem,1])
					nItem := aItem[nItem]
					cUM    := aQtdUni[nItem,2]
					cPictQt  := Iif(nItem==1,'@R 9999999999',Iif(nItem==2,cD12Pict2,cD12Pict))
					Exit
				EndIf
				Exit
			EndDo
		EndIf
	Else
		nItem    := 3 // 1a UM
		cUM      := oProdLote:GetUM()
		cDscUM   := Posicione('SAH',1,xFilial('SAH')+cUM,'AH_UMRES')
		cPictQt  := cD12Pict
		nQtdItem := nQtdTot
	EndIf
	VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
Return lRet
// -----------------------------------------------------------
/*/{Protheus.doc} ControlESC
Controle Esc programas de coletor WMSV030, WMSV085
@author Flavio Vicco
@since 01/08/2005
@version 1.0
@param lAbandona, boleano, (Indica se abandona atividade)
@param lLevaDest, boleano, (Indica se leva para endereço destino)
@param lForcaEnc, boleano, (Indica se força encerramento)
/*/
// -----------------------------------------------------------
Static Function WmsCtrlESC(lForcaEnc)
Local lSaida      := .F.
Local lRetAnt     := .F.
Local aOpcoes     := {}
Local nOpcao      := 0
Local lPulaAtiv   := U_WPulaAti()
Local cCtrlEsc    := " "
Default lForcaEnc := .F.

	U_WOpcESC(0) // Limpa FLAG ESC
	If oMovimento:oMovServic:GetMltAti() <> "0" .And. !lForcaEnc // Se permite selecionar mais de uma atividade
		lRetAnt := .T.
	Else
		lSaida := .T.
	EndIf
	// Verifica se continua leitura
	If !lSaida .And. lRetAnt
		// Se possui mais de uma atividade no aColetor, ou se a primeira é diferente do D12 atual
		If Len(oMovimento:GetArrConf()) > 0 .Or. Len(oMovimento:GetArrCol()) > 1 .Or. (Len(oMovimento:GetArrCol()) == 1 .And. oMovimento:GetArrCol()[1,1] != oMovimento:GetRecno())
			aOpcoes := {}
			AAdd(aOpcoes,STR0049) // Bloquear Atividade
			AAdd(aOpcoes,STR0040) // Endereco Destino
			If lPulaAtiv
				AAdd(aOpcoes,STR0050) // Pular Atividade
			EndIf
			nOpcao := WMSVTAviso(WMSV00106,STR0041+" "+STR0051,aOpcoes,,2) // Opcoes -- Atencao! // Escolha uma ação a ser executada:
			If nOpcao == 1
				aOpcoes := {}
				AAdd(aOpcoes,STR0052) // Atividade Atual
				AAdd(aOpcoes,STR0053) // Todas Atividades
				nOpcao := WMSVTAviso(WMSV00115,STR0041+" "+ STR0054,aOpcoes) // Opcoes -- Atencao! // Escolha o tipo de bloqueio:
				If nOpcao == 1
					U_WOpcESC(2) // Bloqueia Atividade Atual
				ElseIf nOpcao == 2
					U_WOpcESC(1) // Bloqueia Todas Atividades
				EndIf
			ElseIf nOpcao == 2
				U_WEndDes(.T.) // Libera Atividade Atual e Envia Anteriores para Doca
			ElseIf nOpcao == 3
				U_WOpcESC(3) // Pular Atividade Atual
			EndIf
		Else
			lSaida := .T.
		EndIf
	EndIf
	// Verifica se aborta leitura se indicado que não continua
	If lSaida
		If lPulaAtiv .And. !lForcaEnc
			aOpcoes := {}
			AAdd(aOpcoes,STR0049) // Bloquear Atividade
			AAdd(aOpcoes,STR0050) // Pular Atividade
			nOpcao := WMSVTAviso(WMSV00127,STR0041+" "+STR0051,aOpcoes,,2) // Opcoes -- Atencao! // Escolha uma ação a ser executada:
			If nOpcao == 1
				U_WOpcESC(2) // Bloquear Atividade Atual
			ElseIf nOpcao == 2
				U_WOpcESC(3) // Pular Atividade Atual
			EndIf
		Else
			If WMSVTAviso(WMSV00116,WmsFmtMsg(STR0038,{{"[VAR01]",oMovimento:oMovTarefa:GetDesTar()}}),{STR0016,STR0017})==1 // Deseja interromper o [VAR01]? // Sim // Nao
				U_WOpcESC(2) // Bloquear Atividade Atual
			EndIf
		EndIf
	EndIf
	// Controle para remover a tecla ESC
	If VTLastKey() == 27
		VTClearBuffer()
		@ VTMaxRow()-1 , VTMaxCol() -1 VTGet cCtrlEsc
		VTKeyBoard(chr(13))
		VTRead()
	EndIf
Return (Nil)
/*--------------------------------------------------------------------------------
---UpdSitLib
---Libera os serviços de conferencia quando permitido o reinicio automatico
---Alexsander.Correa - 11/05/2015
----------------------------------------------------------------------------------*/
Static Function UpdSitLib()
Local cQuery    := ""
Local aAreaD12  := D12->(GetArea())
Local cAliasD12 := GetNextAlias()
	cQuery := "SELECT D12.R_E_C_N_O_ RECD12"
	cQuery +=   " FROM " + RetSqlName('D12')+" D12 "
	cQuery +=  " WHERE D12.D12_FILIAL = '"+xFilial("D12")+"'"
	// Verifica a versao e o paramentro que permite reabrir tarefa paralizadas
	cQuery += " AND D12.D12_STATUS IN ('2','3')"
	If oMovimento:oMovServic:ChkConfEnt()
		cQuery += " AND D12.D12_DOC = '"+oMovimento:oOrdServ:GetDocto()+"'"
		cQuery += " AND D12.D12_SERIE = '"+oMovimento:oOrdServ:GetSerie()+"'"
	Else
		If WmsCarga(oMovimento:oOrdServ:GetCarga())
			cQuery += " AND D12.D12_CARGA = '"+oMovimento:oOrdServ:GetCarga()+"'"
		Else
			cQuery += " AND D12.D12_DOC = '"+oMovimento:oOrdServ:GetDocto()+"'"
		EndIf
	EndIf
	cQuery += " AND D12.D12_SERVIC = '"+oMovimento:oMovServic:GetServico()+"'"
	cQuery += " AND D12.D12_TAREFA = '"+oMovimento:oMovTarefa:GetTarefa()+"'"
	cQuery += " AND D12.D12_ATIVID = '"+oMovimento:oMovTarefa:GetAtivid()+"'"
	cQuery += " AND D12.D12_ORDTAR = '"+oMovimento:oMovServic:GetOrdem()+"'"
	cQuery += " AND D12.D12_ORDATI = '"+oMovimento:oMovTarefa:GetOrdem()+"'"
	cQuery += " AND D12.D12_QTDLID = 0"
	cQuery += " AND D12.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasD12,.F.,.T.)
	Do While (cAliasD12)->(!Eof())
		D12->(dbGoTo((cAliasD12)->RECD12))
		If D12->(!Eof())
			RecLock("D12",.F.)
			D12->D12_STATUS := '4'
			D12->(MsUnlock())
		EndIf
		(cAliasD12)->(dbSkip())
	EndDo
	(cAliasD12)->(DbCloseArea())
	RestArea(aAreaD12)
Return Nil
// -----------------------------------------------------------
/*/{Protheus.doc} ControlESC
Busca a descrição da norma da doca para o produto
@author Alexsander.correa
@since 11/05/2015
@version 1.0
/*/
// -----------------------------------------------------------
Static Function WmsDesNorma(cProduto,cLocal,cTipEstr)
Local aAreaAnt  := GetArea()
Local cDesNorma := ""
Local cQuery    := ""
Local cAliasQry := GetNextAlias()

	cQuery := "SELECT DC3_ORDEM, DC2_LASTRO, DC2_CAMADA"
	cQuery +=  " FROM "+RetSqlName('DC3')+" DC3, "
	If Empty(cTipEstr)
		cQuery +=  RetSqlName('DC8')+" DC8, "
	EndIf
	cQuery +=  RetSqlName('DC2')+" DC2"
	cQuery += " WHERE DC3.DC3_FILIAL = '"+xFilial('DC3')+"'"
	cQuery +=   " AND DC3.DC3_LOCAL  = '"+cLocal+"'"
	cQuery +=   " AND DC3.DC3_CODPRO = '"+cProduto+"'"
	cQuery +=   " AND DC3.D_E_L_E_T_ = ' '"
	If (Empty(cTipEstr))
		cQuery +=   " AND DC8.DC8_FILIAL = '"+xFilial('DC8')+"'"
		cQuery +=   " AND DC8.DC8_CODEST = DC3.DC3_TPESTR"
		cQuery +=   " AND DC8.DC8_TPESTR = '5'" // Doca
		cQuery +=   " AND DC8.D_E_L_E_T_ = ' '"
	EndIf
	cQuery +=   " AND DC2.DC2_FILIAL = '"+xFilial('DC2')+"'"
	cQuery +=   " AND DC2.DC2_CODNOR = DC3.DC3_CODNOR"
	cQuery +=   " AND DC2.D_E_L_E_T_ = ' '"
	cQuery +=   " ORDER BY DC3.DC3_ORDEM DESC"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
	If (cAliasQry)->(!Eof())
		cDesNorma := "Norma: L "+AllTrim(Str((cAliasQry)->DC2_LASTRO))+" x "+AllTrim(Str((cAliasQry)->DC2_CAMADA))+" C" // Norma: L [VAR01] x [VAR02] C
	EndIf
	(cAliasQry)->(DbCloseArea())

	RestArea(aAreaAnt)
Return cDesNorma
/*/----------------------------------------------------------
Responsável por controlar a opção quando o usuário pressiona ESC
Caso seja passado o valor ele vai "setar" o valor
Caso não seja passado vai retornar o último valor salvo
0-Nenhum;1-Abandona Bloqueando Atividades;2-Bloqueia Atividade Atual;3-Pula Atividade Atual;
----------------------------------------------------------/*/
Static __nOpcESC := 0
User Function WOpcESC(nOpcESC)
	If ValType(nOpcESC) == "N"
		__nOpcESC := nOpcESC
	EndIf
Return __nOpcESC

/*/----------------------------------------------------------
Responsável por verificar as parametrizações, indicando ao usuário
se o sistema irá ativar a opção de "Pular Atividade" quando o usuário
pressionar ESC numa convocação.
----------------------------------------------------------/*/
Static __lPulaAtiv := Nil
User Function WPulaAti()
	If ValType(__lPulaAtiv) != "L"
		// Pega o valor do parâmetro
		__lPulaAtiv := SuperGetMV("MV_WMSPARF",.F.,.F.)
		// Verifica o parametro de ordem de sequencia
		If __lPulaAtiv
			If !("D12_SEQPRI" $ SuperGetMV("MV_WMSPRIO",.F.,""))
				WmsVTAViso(WMSV00117,STR0055) // Não é possível pular atividade. Parâmetro MV_WMSPRIO não contém campo D12_SEQPRI.
				__lPulaAtiv := .F.
			EndIf
		EndIf
	EndIf
Return __lPulaAtiv

/*/----------------------------------------------------------
Altera a prioridade da atividade atual gerando uma nova sequencia
de execução para apenas esta atividade de forma que a mesma seja
alocada no final da fila das atividades atribuidas para o usuário
----------------------------------------------------------/*/
Static Function WmsAltPri()
Local lRegDoc := .F.
Local cRegraPrio  // Prioridade de convocacao no WMS.

	// Carregando informações da regra
	oRegraConv:SetArmazem(oMovimento:oMovEndOri:GetArmazem())
	oRegraConv:SetRecHum(oMovimento:GetRecHum())
	oRegraConv:oMovimento:GoToD12(oMovimento:GetRecno())
	//Seleciona a área da D12 para encontrar a regra de prioridade.
	DbSelectArea('D12')
	D12->(dbGoTo(oMovimento:GetRecno()))
	cRegraPrio := &(SuperGetMV('MV_WMSPRIO', .F., '' ))
	lRegDoc    := oRegraConv:LawRecHum()
	oMovimento:SetSeqPrio(oMovimento:oOrdServ:NextSeqPri('MV_WMSSQPR','D12_SEQPRI')) // Proxima sequencia da execucao dos servicos
	oMovimento:SetPriori("ZZ"+IIf(Empty(cRegraPrio),'',cRegraPrio)+"ZZ")
	// Se não possui regra por documento exclusivo, libera o recurso humano
	If !lRegDoc .Or. (lRegDoc .And. oRegraConv:aRetRegra[17] == "2")
		oMovimento:SetRecHum(Space(TamSX3("D12_RECHUM")[1]))
	EndIf
	__nRecPula := oMovimento:GetRecno()
Return Nil
// -----------------------------------------------------------
/*/{Protheus.doc} SeekAtivid
Utilizado quando o produto informado no apanhe for diferente do
sugerido, verifica se ele existe na mesma sequencia de convocação.
@author felipe.m
@since 17/08/2015
@version 2.0
@param cProduto, characters, código do produto
@param nQtde, numeric, quantidade do produto (CBRetEti/CBRetEtiEAN)
@param cLoteCtl, characters, lote do produto (CBRetEti/CBRetEtiEAN)
@param cNumLote, characters, sub-lote do produto (CBRetEti/CBRetEtiEAN)
@param cNumSerie, characters, número de série do produto (CBRetEti/CBRetEtiEAN)
@param cEndDes, characters, endereço destino
@param lTrocaPrd, logical, se houve troca do produto
@param cUnitizDig, characters, unitizador digitado pelo operador
@return return, lógico
/*/
// -----------------------------------------------------------
Static Function SeekAtivid(cProduto,nQtde,cLoteCtl,cNumLote,cNumSerie,cEndDes,lTrocaPrd,cUnitizDig)
Local aTelaAnt   := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local aAreaD12   := D12->(GetArea())
Local cAliasAtv  := GetNextAlias()
Local cFuncao    := aParConv[1]
Local cRecHum    := aParConv[3]
Local cUsuArma   := aParConv[4]
Local cUsuZona   := aParConv[5]
Local nTipoConv  := aParConv[6]
Local dDataFec   := aParConv[7]
Local cQuery     := ""
Local lRet       := .T.
Local lFiltraPrd := .T.
Local aCab       := {}
Local aSize      := {}
Local aItens     := {}
Local nPos       := 1
Local lRegDoc    := .F.
Local cRecHumAnt := oMovimento:GetRecHum()
Local oRegraAux  := WMSBCCRegraConvocacao():New()
Local cRecnoAnt  := oMovimento:GetRecno()
Local cPermTroca := oMovimento:oMovServic:GetUpdAti()

	If !Empty(cUnitizDig)
		lFiltraPrd := .F.
	EndIf
	
	// Inicializa lTrocaPrd
	lTrocaPrd := .F.
	If lRet
		// Inicializa mensagens de erro
		oMovimento:SetErro("")
		// Posiciona registros
		oRegraAux:SetArmazem(oMovimento:oMovEndOri:GetArmazem())
		oRegraAux:SetRecHum(oMovimento:GetRecHum())
		oRegraAux:oMovimento:GoToD12(oMovimento:GetRecno())
		lRegDoc := oRegraAux:LawRecHum()
		// Se não possui regra por documento exclusivo, libera o recurso humano
		If !lRegDoc .Or. (lRegDoc .And. oRegraAux:aRetRegra[17] == "2")
			lRegDoc := .F.
		EndIf

		// Query para verificar se existe movimento com o produto informado lFiltraPrd, Dados do produto retornados do CBRetEtiEAN
		cQuery := QryValAtCv(cRecHum,cFuncao,cUsuArma,cRecnoAnt,lReinAuto,.T.,lRegDoc,lFiltraPrd,cProduto,nQtde,cLoteCtl,cNumLote,cNumSerie,cEndDes,cUnitizDig)
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasAtv,.F.,.T.)
		If (cAliasAtv)->(Eof())
			WmsMessage(WmsFmtMsg(STR0063,{{"[VAR01]",Iif(lFiltraPrd,STR0072,STR0073)}}),WMSV00120) // "[VAR01] informado não possui movimentações pendentes!"##"Produto"##"Unitizador"
			lRet := .F.
		Else
			While (cAliasAtv)->(!Eof())
				// verifica se o registro do D12 ja foi executado.
				If AScan(oMovimento:GetArrCol(),{|x|x[1] == (cAliasAtv)->RECD12 }) > 0
					(cAliasAtv)->(DbSkip())
					Loop
				EndIf
				// Não precisa avaliar as tabelas DC5 e DC6, pois deve ser a mesma atividade.
				If !ChkAvalD12((cAliasAtv)->RECD12,cRecHum,cFuncao,cUsuArma,cUsuZona,nTipoConv,dDataFec)
					(cAliasAtv)->(DbSkip())
					Loop
				EndIf

				// Adiciona no array o produto se repita.
				aAdd(aItens,{oMovimento:GetQtdMov(),;
							oMovimento:oMovEndDes:GetEnder(),;
							oMovimento:oMovEndDes:GetArmazem(),;
							oMovimento:oMovEndOri:GetEnder(),;
							oMovimento:oMovEndOri:GetArmazem(),;
							oMovimento:oOrdServ:GetDocto(),;
							oMovimento:oOrdServ:GetSerie(),;
							oMovimento:oMovPrdLot:GetProduto(),;
							oMovimento:oOrdServ:GetCliFor(),;
							oMovimento:oOrdServ:GetLoja(),;
							oMovimento:oMovPrdLot:GetLoteCtl(),;
							oMovimento:oMovPrdLot:GetNumLote(),;
							oMovimento:GetRecno()})

				(cAliasAtv)->(dbSkip())
			EndDo
			(cAliasAtv)->(dbCloseArea())

			If Len(aItens) > 1
				aCab  := {RetTitle("D12_QTDMOV"),RetTitle("D12_ENDDES"),RetTitle("D12_LOCDES"),RetTitle("D12_ENDORI"),RetTitle("D12_LOCDORI"),RetTitle("D12_DOC"),RetTitle("D12_SERIE"),RetTitle("D12_PRODUT"),RetTitle("D12_CLIFOR"),RetTitle("D12_LOJA"),RetTitle("D12_LOTECT"),RetTitle("D12_NUMLOT"),"Recno"}
				aSize := {9,TamSx3("D12_ENDDES")[1],TamSx3("D12_LOCDES")[1],TamSx3("D12_ENDORI")[1],TamSx3("D12_LOCORI")[1],TamSx3("D12_DOC")[1],TamSx3("D12_SERIE")[1],TamSx3("D12_PRODUT")[1],TamSx3("D12_CLIFOR")[1],TamSx3("D12_LOJA")[1],TamSx3("D12_LOTECT")[1],TamSx3("D12_NUMLOT")[1],10}
				WMSVTRodPe(, .F.)
				nPos  := VTaBrowse(0,0,(VTMaxRow()-2),VTMaxCol(),aCab,aItens,aSize)
				If VTLastKey() == 27
					lRet := .F.
				EndIf
			ElseIf Len(aItens) == 0
				WmsMessage(WmsFmtMsg(STR0063,{{"[VAR01]",Iif(lFiltraPrd,STR0072,STR0073)}}),WMSV00124) // "[VAR01] informado não possui movimentações pendentes!"##"Produto"##"Unitizador"
				lRet := .F.
			EndIf

			If lRet .And. (lRet := (IIf(cPermTroca == "3",WMSVTAviso(WMSV00119,STR0064,{STR0016,STR0017}) == 1,.T.))) // "Confirmar alteração da atividade?" // "Sim" // "Nao"
				// Retorna o status do movimento anterior para "A Executar"
				// Não precisa avaliar as tabelas DC5 e DC6, pois deve ser a mesma atividade.
				If ChkAvalD12(aItens[nPos][13],cRecHum,cFuncao,cUsuArma,cUsuZona,nTipoConv,dDataFec)
					oMovimento:GoToD12(cRecnoAnt)
					If oMovimento:GetQtdLid() <= 0
						// Se não possui regra por documento exclusivo, libera o recurso humano
						If (!lRegDoc .Or. (lRegDoc .And. oRegraAux:aRetRegra[17] == "2")) .And. Empty(cAntRecHum)
							oMovimento:SetRecHum(cAntRecHum)
						EndIf
						oMovimento:SetStatus("4")
						oMovimento:SetDataIni(CTOD(""))
						oMovimento:SetHoraIni("")
						oMovimento:SetDataFim(CTOD(""))
						oMovimento:SetHoraFim("")
					EndIf
					oMovimento:UpdateD12()
					// Reposiciona o movimento alterado
					WMSConvD12(aItens[nPos][13])
					oMovimento:GoToD12(aItens[nPos][13])
					cAntRecHum := oMovimento:GetRecHum()
					oMovimento:SetRecHum(cRecHumAnt)
					oMovimento:SetStatus("3") // Em Execução
					oMovimento:SetDataIni(dDataBase)
					oMovimento:SetHoraIni(Time())
					oMovimento:UpdateD12()
					lTrocaPrd := .T.
				Else
					WmsMessage(WmsFmtMsg(STR0070,{{"[VAR01]",Iif(lFiltraPrd,STR0072,STR0073)}}),WMSV00126) // "[VAR01] não está mais disponível para convocação!"##"Produto"##"Unitizador"
					lRet := .F.
				EndIf
			EndIf
			// Se apertar Esc, voltar ao produto convocado anteriormente
			If !lRet .Or. !lTrocaPrd
				// Retorno registro atual
				oMovimento:GoToD12(cRecnoAnt)
			EndIf
		EndIf
	EndIf
	VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
	RestArea(aAreaD12)
Return lRet
// -----------------------------------------------------------
/*/{Protheus.doc} WmsInfoPrd
Apresenta informações do produto
@author felipe.m
@since 17/08/2015
@version 1.0
/*/
// -----------------------------------------------------------
Static Function WMSInfoPrd()
Local aTelaAnt   := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local aAreaAnt   := GetArea()
Local cUM        := ''

	If Empty(oMovimento:oMovSeqAbt:GetNorma())
		// Busca UM Movimento na sequencia de abastecimento
		If oMovimento:oMovServic:HasOperac({'3','4'})
			oMovimento:oMovSeqAbt:SetArmazem(oMovimento:oMovEndOri:GetArmazem())
			oMovimento:oMovSeqAbt:SetProduto(oMovimento:oMovPrdLot:GetProduto())
			oMovimento:oMovSeqAbt:SetEstFis(oMovimento:oMovEndOri:GetEstFis())
		Else
			oMovimento:oMovSeqAbt:SetArmazem(oMovimento:oMovEndDes:GetArmazem())
			oMovimento:oMovSeqAbt:SetProduto(oMovimento:oMovPrdLot:GetProduto())
			oMovimento:oMovSeqAbt:SetEstFis(oMovimento:oMovEndDes:GetEstFis())
		EndIf
		oMovimento:oMovSeqAbt:LoadData(2)
	EndIf

	SAH->(dbSetOrder(1))
	If SAH->(dbSeek(xFilial('SAH')+IIf(oMovimento:oMovPrdLot:GetUMInd() == "1", oMovimento:oMovPrdLot:GetUM(),oMovimento:oMovPrdLot:GetSegum()), .F.))
		cUM := SAH->AH_UMRES
	EndIf

	WMSVTCabec(AllTrim(oMovimento:oMovPrdLot:GetProduto()), .F., .F., .T.)
	@ 01, 00 VTSay PadR(oMovimento:oMovPrdLot:GetDesc(), VTMaxCol())
	@ 02, 00 VTSay PadR(STR0057+AllTrim(cUM), VTMaxCol())	                                        // Unidade..:
	@ 03, 00 VTSay PadR(STR0058+AllTrim(Str(oMovimento:oMovSeqAbt:oNorma:GetLastro())), VTMaxCol()) // Lastro...:
	@ 04, 00 VTSay PadR(STR0059+AllTrim(Str(oMovimento:oMovSeqAbt:oNorma:GetCamada())), VTMaxCol()) // Camada...:
	@ 05, 00 VTSay PadR(STR0060+AllTrim(Str(oMovimento:oMovSeqAbt:GetNorma())), VTMaxCol())         // Cap.Max..:
	WMSVTRodPe()

	VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
	RestArea(aAreaAnt)
Return Nil
/*--------------------------------------------------------------------------------
---WmsEndOcor
---Pergunta o endereço na geração da ocorrência
---felipe.m 15/03/2016
----------------------------------------------------------------------------------*/
Static Function WmsEndOcor(cArmazem,cEndereco)
Local aAreaAnt := GetArea()
Local aTelaAnt := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local lRet := .T.
	cEndereco:= Space(TamSX3("D12_ENDORI")[1])

	WMSVTCabec(AllTrim(STR0021), .F., .F., .T.) //"Ocorrencia"
	@ 01, 00 VTSay PadR(STR0066, VTMaxCol()) //"Informe o endereco"
	@ 02, 00 VTGet cEndereco Valid ValEndInv(@cArmazem,cEndereco)
	VTRead
	
	VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
	RestArea(aAreaAnt)
Return lRet
/*--------------------------------------------------------------------------------
---WmsGerInvt
---Gera o inventário mestre CBA
---amanda.vieira 12/2015
----------------------------------------------------------------------------------*/
Static Function WmsGerInvt(cCodInv,cEndereco)
Local aAreaAnt := GetArea()
Local aTelaAnt := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local lRet := .T.
Local oModelCBA := Nil

	oModelCBA := FWLoadModel("WMSA332C")
	oModelCBA:SetOperation(3/*MODEL_OPERATION_INSERT*/)
	oModelCBA:Activate()

	oModelCBA:LoadValue("CBAMASTER","CBA_LOCALI",cEndereco)
	If oModelCBA:VldData()
		oModelCBA:CommitData()
		cCodInv := oModelCBA:GetValue("CBAMASTER","CBA_CODINV")
	EndIf
	oModelCBA:DeActivate()

	VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
	RestArea(aAreaAnt)
Return lRet
/*--------------------------------------------------------------------------------
---ValEndInv
---Validação do endereço informado na geração da ocorrência
---amanda.vieira 12/2015
----------------------------------------------------------------------------------*/
Static Function ValEndInv(cArmazem,cEndereco)
Local lRet := .T.

	If !Empty(cEndereco)
		oMovimento:SetEndInv(cEndereco)
		If oMovimento:VldEndInv()
			cArmazem := oMovimento:GetArmInv()
			lRet := .T.
		Else
			WmsMessage(oMovimento:GetErro(),WMSV00121)
			lRet := .F.
		EndIf
	EndIf

	If !(lRet)
		VTKeyBoard(Chr(20))
	EndIf

Return lRet
/*--------------------------------------------------------------------------------
---AlterAtiv
---Lista de funções WMS para alterar a convocação corrente
---felipe.m - 28/01/2016
---aFuncoesWMS, Array
----------------------------------------------------------------------------------*/
Static Function TrocarFunc(aFuncoesWMS,lTrocaFunc)
Local aCab      := {'N.',STR0008}  // Funcoes Atrib.      '
Local aSize     := {Len(aCab[1]), Len(aCab[2])}
Local aTelaAnt  := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local aFuncoes  := {}
Local nX        := 0
Local nFuncOper := 0

	For nX := 1 to Len(aFuncoesWMS)
		aAdd(aFuncoes, {StrZero(aFuncoesWMS[nX, 1], 2), aFuncoesWMS[nX, 3],aFuncoesWMS[nX, 2] })
	Next nX

	If Len(aFuncoes) > 0
		VTClear()
		For nX := 1 to VTMaxRow()-1
			@ nX, 00 VTSay PadR('  |', VTMaxCol())
		Next nX
		WMSVTRodPe(, .F.)
		nFuncOper := VTaBrowse(00, 00, Min(VTMaxRow()-1,Len(aFuncoes)+1), VTMaxCol(), aCab, aFuncoes, aSize)
		If nFuncOper > 0 .And. __cFuncOpe != aFuncoes[nFuncOper][3]
			__cFuncOpe := aFuncoes[nFuncOper][3]
			lTrocaFunc := .T.
		EndIf
	Else
		WMSVTAviso(WMSV00123, STR0035) // Nenhuma Funcao Cadastrada...
	EndIf

	VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
	If lTrocaFunc
		VTKeyBoard(Chr(13))
	EndIf
Return Nil

Static Function WMSVlPrdOr(cArmazem,cEndereco,cProduto,cLoteCtl,cNumLote,nQtdTot,cPrdOri)
Local lRet      := .T.
Local aTelaAnt  := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local aItens    := {}
Local aCab      := {RetTitle("D14_QTDEST"),RetTitle("D14_PRDORI") ,RetTitle("D14_PRODUT") , RetTitle("D14_LOTECT") ,RetTitle("D14_NUMLOT")}
Local aSize     := {9                     ,TamSx3("D14_PRDORI")[1],TamSx3("D14_PRDORI")[1], TamSx3("D14_LOTECT")[1],TamSx3("D14_NUMLOT")[1]}
Local cAliasD14 := Nil
Local cQuery    := ""
Local nPos      := 0
Default cLoteCtl := ""
Default cNumLote := ""
Default nQtdTot  := 0
Default cPrdOri  := ""

	cQuery := " SELECT D14_PRDORI,"
	cQuery +=        " D14_PRODUT,"
	cQuery +=        " (D14_QTDEST - (D14_QTDSPR + D14_QTDEMP + D14_QTDBLQ)) D14_QTDEST,"
	cQuery +=        " D14_LOTECT,"
	cQuery +=        " D14_NUMLOT"
	cQuery +=   " FROM "+RetSqlName("D14")
	cQuery +=  " WHERE D14_FILIAL = '"+xFilial("D14")+"'"
	cQuery +=    " AND D14_LOCAL  = '"+cArmazem+"'"
	cQuery +=    " AND D14_ENDER  = '"+cEndereco+"'"
	cQuery +=    " AND D14_PRODUT = '"+cProduto+"'"
	If !Empty(cLoteCtl)
		cQuery +=    " AND D14_LOTECT = '"+cLoteCtl+"'"
	EndIf
	If !Empty(cNumLote)
		cQuery +=    " AND D14_NUMLOT = '"+cNumLote+"'"
	EndIf
	cQuery +=    " AND (D14_QTDEST - (D14_QTDSPR + D14_QTDEMP + D14_QTDBLQ)) > 0"
	cQuery +=    " AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasD14  := GetNextAlias()
	dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasD14,.F.,.T.)
	Do While (cAliasD14)->(!Eof())
		Aadd(aItens,{(cAliasD14)->D14_QTDEST,;
					(cAliasD14)->D14_PRDORI,;
					(cAliasD14)->D14_PRODUT,;
					(cAliasD14)->D14_LOTECT,;
					(cAliasD14)->D14_NUMLOT})
		(cAliasD14)->(dbSkip())
	EndDo
	(cAliasD14)->(dbCloseArea())

	If Empty(aItens)
		WMSVTAviso(WMSV00125,WmsFmtMsg(STR0067,{{"[VAR01]",cProduto},{"[VAR02]",cEndereco}})) // Produto [VAR01] não encontrado no endereço [VAR02].
		lRet := .F.
	ElseIf Len(aItens) == 1
		nPos := 1
	Else
		WMSVTCabec(STR0068,.F.,.F.,.T.) // Produto Origem
		nPos := VTaBrowse(00, 00, Min(VTMaxRow()-1,Len(aItens)+1), VTMaxCol(), aCab, aItens, aSize)
		If VTLastKey() == 27
			lRet := .F.
		EndIf
	EndIf
	If lRet
		nQtdTot := aItens[nPos][1]
		// Atribui dados
		cPrdOri  := aItens[nPos][2]
		cLoteCtl := aItens[nPos][4]
		cNumLote := aItens[nPos][5]
	EndIf
	VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)

Return lRet

Static Function RedoRecHum(cAntRecHum)
Local lRet      := .T.
Local nRecnoD12 :=  oMovimento:GetRecno()
	// Verifica se ha regras para convocacao para estas atividades.
	oRegraConv:aRetRegra := {}
	oRegraConv:SetArmazem(oMovimento:oMovEndOri:GetArmazem())
	oRegraConv:SetRecHum(oMovimento:GetRecHum())
	oRegraConv:oMovimento:GoToD12(nRecnoD12)
	// Verifica se ha regras para convocacao
	If oRegraConv:LawRecHum()
		// Analisa se convocao ou nao
		If oRegraConv:RedoLawLim(cAntRecHum)
			// Atualiza recurso movimento corrente
			oRegraConv:oMovimento:GoToD12(nRecnoD12)
			oMovimento:SetRecHum(oRegraConv:oMovimento:GetRecHum())
		Else
			// Atualiza recurso movimento corrente
			oMovimento:SetRecHum(cAntRecHum)
		EndIf
	Else
		// Atualiza recurso movimento corrente
		oMovimento:SetRecHum(cAntRecHum)
	EndIf
Return lRet

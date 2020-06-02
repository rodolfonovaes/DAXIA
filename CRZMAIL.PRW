#INCLUDE "Rwmake.ch"
#INCLUDE "TbiConn.ch"
#include "protheus.ch"
#INCLUDE "AP5MAIL.CH"

#DEFINE ENTER Chr(10) + Chr (13) 
/*/{Protheus.doc} DMENMAIL
Teste de Envio de E-mail
@type function
@version 
@author Cícero Cruz
@since 05/03/2020
@return cRet, Retorno do Erro
/*/
USER FUNCTION DMENMAIL()
LOCAL cErro := ""
LOCAL cMsg  := "Olá," + ENTER 
LOCAL cMsg  += "Você esta recebendo o Laudo Lote.: 075452 Nota Fiscal.: 000000659/001 em Anexo. "
LOCAL _aFiles := {}

AADD( _aFiles,  {"Laudo Lote.: 075452 Nota Fiscal.: 000000659/001" , "\LAUDOS_DAXIA\000000659_075452.PDF"} )

U_CRZMail(									 "cicero.cruz@gmail.com", ;
											 					 "", ;
											 					 "", ;
                  "Laudo Lote.: 075452 Nota Fiscal.: 000000659/001", ;
														    _aFiles, ;
							                                   cMsg, ;
															    .T., ;
															 @cErro  )

RETURN cErro

/*====================================================================================================================+
| Funcao Estatica ....:   CRZMail()                                                                                  |
| Autor(es)...........:   Cicero Odilio Cruz - cicero.cruz@gmail.com                                                  |
| Data................:   23/12/2019                                                                                  |
| Descricao / Objetivo:   Envio de E-mail com o Laudo para o Cliente                                                  |
| Doc. Origem.........:   MIT044 - Envio de Laudo de Qualidade Juntamento com o NFE.                                  |
| Solicitante.........:   TOTVS Ibirapuera                                                                            |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                                                             |
| Parametros..........:   _cPara     (C): Destinatários                                                               |
|                         _cCc       (C): Destinatários                                                               |
|                         _cBCC      (C): Destinatários                                                               |
|                         _cTitulo   (C): Assunto do mail                                                             |
|                         _aAnexo    (A): Vetor de [x] contendo os arquivos a serem anexados no mail (colocar caminho |
|                                         - abaixo do \system\)                                                       |
|                         _cMsg      (C): Corpo da mensagem                                                           |                                                                              //
|                         _lAudit    (L):                                                                             |                                                                                 //
|                         _cMErro    (C): Mensagem de Erro passar por referência                                      |                                                            //
| Retorno.............:   lRet - Caso tenha encontrado o Lote                                                         |
| Obs.................:                                                                                               |
+====================================================================================================================*/
User Function CRZMail(_cPara, _cCc, _cBCC, _cTitulo, _aAnexo, _cMsg, _lAudit, _cMErro)
	Local oMail
	Local oMessage
	Local nRet
	Local nTimeout := GetMV("MV_RELTIME")	//Timeout no Envio de E-Mail;
	Local cServer  := GetMV("MV_RELSERV")	//Nome do Servidor de Envio de E-Mail utilizado nos relatorios;
	Local cEmail   := GetMV("MV_RELACNT")	//Conta a ser utilizada no envio de E-Mail para os relatorios;
	Local cEmailA  := GetMV("MV_RELAUSR")	//Usuario para Autenticacao no Servidor de E-Mail;
	Local cEmailFr := GetMV("MV_RELFROM")	//E-Mail utilizado no campo FROM no envio de relatorios por E-Mail;
	Local cPass    := GetMV("MV_RELPSW")	//Senha da Conta de E-Mail para envio de relatorios;
	Local lAuth    := GetMv("MV_RELAUTH")	//Servidor de E-Mail necessita de Autenticacao? Determina se o Servidor necessita de Autenticacao;
	Local cMailAud := GetMv("MV_MAILADT")	//Conta oculta de auditoria utilizada no envio de E-Mail para os relatorios;
	Local lUseSSL  := GetMv("MV_RELSSL")	//Define se o envio e recebimento de E-Mail na rotina SPED utilizara conexao segura (SSL);
	Local lUseTLS  := GetMv("MV_RELTLS")	//Informe se o servidor de SMTP possui conexao do tipo segura (SSL/TLS);
	Local _nPorta  := GetMv("MV_PORSMTP")	//Porta Default;
	LOCAL nStart   := Seconds()

	DEFAULT _cMErro  := ""	
	DEFAULT _cPara := ""
	DEFAULT _cCc   := ""
	DEFAULT _cBCC  := ""
	DEFAULT _cMsg  := ""
	DEFAULT _aAnexo  := {}
	DEFAULT _cTitulo := ""
	DEFAULT _lAudit  := ""

	/*IF dDatabase >= CTOD("15/04/2020")
		_cMErro += "CRZMAIL(001) Periodo de validação venceu, solicite um novo periodo para validar a rotina!!!" + ENTER
		RETURN .F.
	ENDIF*/

	//ProcRegua(15)
	
	//---------------------------------------------------------------------------------------------------------------------
	//ENVIAR EMAIL PARA TI QUANDO FOR AMBIENTE TESTE
	//if cEmpAnt <> "01" .and. cEmpAnt <> "02"
	//	_cPara := "cicero.cruz@gmail.com"
	//endif
	
	//---------------------------------------------------------------------------------------------------------------------
	//PREENCHENDO O EMAIL PARA RESPOSTA
	DbSelectArea("SX5")
	
	//if SX5->(DbSeek(xFilial("SX5")+"WK"+AllTrim(PswID())))
	cEmailFr := "faturamento.daxia@daxia.com.br" //AllTrim(SX5->X5_DESCSPA)
	//endif

	//---------------------------------------------------------------------------------------------------------------------
	//VALIDANDO OS PARAMETROS INFORMADOS
	If Empty(cServer) .OR. Empty(cEmail) .OR. Empty(cEmailA) .OR. Empty(cPass)
		_cMErro += "Verifique os parametros: MV_RELSERV, MV_RELACNT, MV_RELAUSR ou MV_RELPSW!!!" + ENTER
		Return(.F.)
	EndIf

	If Empty(Alltrim(_cPara))
		_cMErro += "CRZMAIL(002) Não foi informado um destinatário o Protheus exije ao menos um destinatário, corrija a Tabela de Clientes!!!" + ENTER
		Return(.F.)
	EndIf

	nPosArr := At("@", _cPara)
	If nPosArr <= 0
		_cMErro += "CRZMAIL(003) Destinatário inválido, corrija a Tabela de Clientes!!!" + ENTER
		Return(.F.)
	EndIf
	//---------------------------------------------------------------------------------------------------------------------
	//CASO O ENDERECO DO SERVER TENHA A PORTA INFORMADA, SEPARA OS CAMPOS
	If(At(":",cServer) > 0)
		_nPorta := Val(Substr(cServer,At(":",cServer)+1,Len(cServer)))
		cServer := Substr(cServer,0,At(":",cServer)-1)
	EndIf

	//---------------------------------------------------------------------------------------------------------------------
	//CRIA UMA INSTANCIA DA CLASSE TMAILMANAGER
	oMail := TMailManager():New()
	If(lUseSSL)
		oMail:SetUseSSL(lUseSSL)
	EndIf
	If(lUseTLS)
		oMail:SetUseTLS(lUseTLS)
	EndIf

	//---------------------------------------------------------------------------------------------------------------------
	//DEFINE AS CONFIGURACOES, DA CLASSE TMAILMANAGER, PARA REALIZAR UMA CONEXAO COM O SERVIDOR DE E-MAIL
	oMail:Init("",cServer,cEmail,cPass,0,_nPorta)

	//---------------------------------------------------------------------------------------------------------------------
	//DEFINE O TEMPO DE ESPERA PARA UMA CONEXAO ESTABELECIDA COM O SERVIDOR DE E-MAIL SMTP (SIMPLE MAIL TRANSFER PROTOCOL)
	If (nTimeout <= 0)
		//ConOut("[TIMEOUT] DISABLE")
		FwLogMsg("INFO", /*cTransactionId*/, "CRZMAILLOG001", FunName(), "", "01", "[TIMEOUT] DISABLE..." , 0, (nStart - Seconds()), {}) 
	Else
		//IncProc("[TIMEOUT] ENABLE()")
		//ConOut("[TIMEOUT] ENABLE()")

		nRet := oMail:SetSmtpTimeOut(nTimeout)

		If nRet != 0
			//ConOut("[TIMEOUT] Fail to set")
			FwLogMsg("INFO", /*cTransactionId*/, "CRZMAILLOG002", FunName(), "", "01", "[TIMEOUT]  Fail to set " , 0, (nStart - Seconds()), {}) 
			//ConOut("[TIMEOUT][ERROR] " + str(nRet,6) , oMail:GetErrorString(nRet))
			FwLogMsg("INFO", /*cTransactionId*/, "CRZMAILLOG003", FunName(), "", "01", "[TIMEOUT][ERROR] " + str(nRet,6) + " - " + oMail:GetErrorString(nRet) , 0, (nStart - Seconds()), {}) 
			_cMErro += "[TIMEOUT][ERROR] " + str(nRet,6) + " - " + oMail:GetErrorString(nRet) + ENTER
			oMail:SMTPDisconnect()
			Return(.F.)
		EndIf
	EndIf

	//---------------------------------------------------------------------------------------------------------------------
	//CONECTA COM O SERVIDOR DE E-MAIL SMTP (SIMPLE MAIL TRANSFER PROTOCOL)
	//IncProc("[SMTPCONNECT] connecting ...")
	//ConOut("[SMTPCONNECT] connecting ...")
	nRet := oMail:SmtpConnect()
	If nRet <> 0
		//ConOut("[SMTPCONNECT] Falha ao conectar")
		FwLogMsg("INFO", /*cTransactionId*/, "CRZMAILLOG004", FunName(), "", "01", "[SMTPCONNECT] Falha ao conectar" , 0, (nStart - Seconds()), {}) 
			
		//ConOut("[SMTPCONNECT][ERROR] " + str(nRet,6) , oMail:GetErrorString(nRet))
		FwLogMsg("INFO", /*cTransactionId*/, "CRZMAILLOG005", FunName(), "", "01", "[SMTPCONNECT][ERROR] " + str(nRet,6) + " - " + oMail:GetErrorString(nRet) , 0, (nStart - Seconds()), {}) 
			
		_cMErro += "[SMTPCONNECT][ERROR] " + str(nRet,6) + " - " + oMail:GetErrorString(nRet) + ENTER
		oMail:SMTPDisconnect()
		Return(.F.)
	Else
		//ConOut("[SMTPCONNECT] Sucesso ao conectar")
	EndIf

	//---------------------------------------------------------------------------------------------------------------------
	//REALIZA A AUTENTICACAO NO SERVIDOR DE E-MAIL SMTP (SIMPLE MAIL TRANSFER PROTOCOL) PARA ENVIO DE MENSAGENS
	If lAuth
		//IncProc("[AUTH] ENABLE")
		//ConOut("[AUTH] ENABLE")
		FwLogMsg("INFO", /*cTransactionId*/, "CRZMAILLOG006", FunName(), "", "01", "[AUTH] ENABLE" , 0, (nStart - Seconds()), {}) 
		
		//ConOut("[AUTH] TRY with ACCOUNT() and PASS()")
		FwLogMsg("INFO", /*cTransactionId*/, "CRZMAILLOG007", FunName(), "", "01", "[AUTH] TRY with ACCOUNT() and PASS()" , 0, (nStart - Seconds()), {}) 
		
		nRet := oMail:SMTPAuth(cEmailA,cPass)
		If nRet != 0
			//IncProc("[AUTH] FAIL TRY with ACCOUNT() and PASS()")
			//ConOut("[AUTH] FAIL TRY with ACCOUNT() and PASS()")
			FwLogMsg("INFO", /*cTransactionId*/, "CRZMAILLOG008", FunName(), "", "01", "[AUTH] FAIL TRY with ACCOUNT() and PASS()" , 0, (nStart - Seconds()), {}) 
		
			//ConOut("[AUTH][ERROR] " + str(nRet,6) , oMail:GetErrorString(nRet))
			FwLogMsg("INFO", /*cTransactionId*/, "CRZMAILLOG009", FunName(), "", "01", "[AUTH][ERROR] " + str(nRet,6) + oMail:GetErrorString(nRet) , 0, (nStart - Seconds()), {}) 
		
			//ConOut("[AUTH] TRY with USER() and PASS()")
			FwLogMsg("INFO", /*cTransactionId*/, "CRZMAILLOG010", FunName(), "", "01", "[AUTH] TRY with USER() and PASS()", 0, (nStart - Seconds()), {}) 
		
			_cMErro += "[AUTH][ERROR] " + str(nRet,6) + " - " + oMail:GetErrorString(nRet) + ENTER
			nRet := oMail:SMTPAuth(cEmailA,cPass)

			If nRet != 0
				//ConOut("[AUTH] FAIL TRY with USER() and PASS()")
				FwLogMsg("INFO", /*cTransactionId*/, "CRZMAILLOG011", FunName(), "", "01", "[AUTH] FAIL TRY with USER() and PASS()", 0, (nStart - Seconds()), {}) 
				//ConOut("[AUTH][ERROR] " + str(nRet,6) , oMail:GetErrorString(nRet))
				FwLogMsg("INFO", /*cTransactionId*/, "CRZMAILLOG012", FunName(), "", "01", "[AUTH][ERROR] " + str(nRet,6) + oMail:GetErrorString(nRet), 0, (nStart - Seconds()), {}) 
				_cMErro += "[AUTH][ERROR] " + str(nRet,6) + " - " + oMail:GetErrorString(nRet) + ENTER
				oMail:SMTPDisconnect()
				Return(.F.)
			Else
				//IncProc("[AUTH] SUCEEDED TRY with USER() and PASS()")
				//ConOut("[AUTH] SUCEEDED TRY with USER() and PASS()")
			EndIf
		Else
			//IncProc("[AUTH] SUCEEDED TRY with ACCOUNT and PASS")
			//ConOut("[AUTH] SUCEEDED TRY with ACCOUNT and PASS")
		EndIf
	Else
		//IncProc("[AUTH] DISABLE")
		//ConOut("[AUTH] DISABLE")
		FwLogMsg("INFO", /*cTransactionId*/, "CRZMAILLOG013", FunName(), "", "01", "[AUTH] DISABLE", 0, (nStart - Seconds()), {}) 
				
	EndIf

	//---------------------------------------------------------------------------------------------------------------------
	//CRIA UMA INSTANCIA DA CLASSE TMAILMANAGER
	//IncProc("[MESSAGE] Criando mail message")
	//ConOut("[MESSAGE] Criando mail message")
	
	oMessage := TMailMessage():New()
	oMessage:Clear()
	oMessage:cFrom    := cEmailFr
	oMessage:cTo      := _cPara
	oMessage:cCc      := _cCc
	oMessage:cBCC     := IIF(_lAudit, cMailAud, "") + IIF(!Empty(_cBCC), (";" + _cBCC),"")
	oMessage:cSubject := _cTitulo
	oMessage:cBody    := _cMsg

	For _nX := 1 to Len(_aAnexo)
		oMessage:AddAttHTag("Content-ID: <" + _aAnexo[_nX][01] + ">")	//Essa tag, é a referecia para o arquivo ser mostrado no corpo, o nome declarado nela deve ser o usado no HTML
//		oMessage:AddAttHTag("Content-Disposition: attachment; filename=" + _aAnexo[_nX][01])	//Essa tag, é a referecia para o arquivo ser mostrado no corpo, o nome declarado nela deve ser o usado no HTML
		oMessage:AttachFile(_aAnexo[_nX][02])							//Adiciona um anexo, nesse caso a imagem esta no root
	Next _nX
	oMessage:MsgBodyType("text/html")

	//---------------------------------------------------------------------------------------------------------------------
	//ENVIA E-MAIL ATRAVÉS DO PROTOCOLO SMTP
	//IncProc("[SEND] Sending ...")
	ConOut("[SEND] Sending ...")
	nRet := oMessage:Send(oMail)
	If nRet <> 0
		//ConOut("[SEND] Fail to send message")
		FwLogMsg("INFO", /*cTransactionId*/, "CRZMAILLOG014", FunName(), "", "01", "[SEND] Fail to send message", 0, (nStart - Seconds()), {}) 

		//ConOut("[SEND][ERROR] " + str(nRet,6) , oMail:GetErrorString(nRet))
		FwLogMsg("INFO", /*cTransactionId*/, "CRZMAILLOG015", FunName(), "", "01", "[SEND][ERROR] " + str(nRet,6) + oMail:GetErrorString(nRet), 0, (nStart - Seconds()), {}) 

		_cMErro += "[SEND][ERROR] " + str(nRet,6) + " - " + oMail:GetErrorString(nRet) + ENTER
		oMail:SMTPDisconnect()
		Return(.F.)
	Else
		//IncProc("[SEND] Success to send message")
		//ConOut("[SEND] Success to send message")
	EndIf

	//---------------------------------------------------------------------------------------------------------------------
	//FINALIZA A CONEXAO ENTRE A APLICACAO E O SERVIDOR DE E-MAIL SMTP (SIMPLE MAIL TRANSFER PROTOCOL)
	//IncProc("[DISCONNECT] smtp disconnecting ... ")
	//ConOut("[DISCONNECT] smtp disconnecting ... ")
	oMail:SMTPDisconnect()
	If nRet != 0
		//IncProc("[DISCONNECT] Fail smtp disconnecting ... ")
		//ConOut("[DISCONNECT] Fail smtp disconnecting ... ")
		FwLogMsg("INFO", /*cTransactionId*/, "CRZMAILLOG016", FunName(), "", "01", "[DISCONNECT] Fail smtp disconnecting ...", 0, (nStart - Seconds()), {}) 

		//ConOut("[DISCONNECT][ERROR] " + str(nRet,6) , oMail:GetErrorString(nRet))
		FwLogMsg("INFO", /*cTransactionId*/, "CRZMAILLOG017", FunName(), "", "01", "[DISCONNECT][ERROR] " + str(nRet,6) + " - " + oMail:GetErrorString(nRet) , 0, (nStart - Seconds()), {}) 

		_cMErro += "[DISCONNECT][ERROR] " + str(nRet,6) + " - " + oMail:GetErrorString(nRet) + ENTER
	Else
		//IncProc("[DISCONNECT] Success smtp disconnecting ... ")
		//ConOut("[DISCONNECT] Success smtp disconnecting ... ")
	EndIf

Return(.T.)

#INCLUDE 'Protheus.ch'
#INCLUDE 'Parmtype.ch'
#INCLUDE 'Fileio.ch'
#INCLUDE 'Ap5mail.ch'

/*/{Protheus.doc} TBOLEND
@type function
@author TOTVS IBIRAPUERA
@since 26/07/2016
@version 1.0
/*/
User Function TBolEnd()
Local cPathPDF		:= ParamIXB[1]
Local cFilePdf		:= ParamIXB[2]
Local cCodCli		:= ParamIXB[3]
Local cLojCli		:= ParamIXB[4]
Local lTela			:= ParamIXB[5]
Local cNumTit		:= ParamIXB[6]
Local aTitCob		:= ParamIXB[7]
Local aArea			:= GetArea()
Local aAreaSA1		:= SA1->(GetArea())
Local cUrl			:= ""
Local cRespJob		:= ""
Local cFileServer	:= ""
Local cRespJob		:= ""
Local cRoothPath	:= GetPvProfString(GetEnvServer(), 'RootPath', 'ERROR', GetADV97()) 
Local cMailCopy  	:= ALLTRIM(GetNewPar("ES_MAILCOP",""))

//-- Envio de e-mail ao cliente
SA1->(dbSetOrder(1))
If SA1->(MsSeek(xFilial("SA1") + cCodCli + cLojCli )) .And. lTela
//	SendMail(SA1->A1_EMAIL  , SA1->A1_NOME , cPathPDF + cFilePdf + ".pdf"  , cFilePdf + ".pdf", aTitCob)
	SendMail(ALLTRIM(SA1->A1_XEMAIL) + "," + cMailCopy  , SA1->A1_NOME , cPathPDF + cFilePdf + ".pdf"  , cFilePdf + ".pdf", aTitCob)
EndIf

//-- Transfere para URL
If !lTela
		
	cFileServer	:= GetPvProfString("HTTP", "PATH", "HTTP",  GetAdv97() )
	cRespJob	:= Upper(GetPvProfString("HTTP", "RESPONSEJOB", "HTTP",  GetAdv97() ) )
	cURL		:= GetPvProfString(cRespJob , "URLLOCATION", "HTTP",  GetAdv97() )	
	cURL		+= "/" + cFilePdf  + ".pdf"
	
	Sleep(3000)
	
	Copy File &(  cPathPDF + cFilePdf  + ".pdf") To &( "\web\ws\" +  cFilePdf + ".pdf")

EndIf

RestArea(aAreaSA1)
RestArea(aArea)	

Return cUrl

/*/{Protheus.doc} SendMail
@type function
@author TOTVS IBIRAPUERA
@since 26/07/2016
@version 1.0
@param cTo, character, 
@param cNomeCli, character, 
@param cFileBol, character, 
@param cFilePdf, character, 
/*/
Static Function SendMail(cTo , cNomeCli , cFileBol , cFilePdf, aTitCob)
Local nPrtServer    	:= Nil
Local oMessage      	:= NIL
Local cMailConta    	:= ""
Local cMailServer   	:= ""
Local cMailSenha    	:= ""
Local cMailCtaAut   	:= ""
Local lContinua     	:= .T., cListCopias := ""
Local nCount := 0, nI 	:= 0, nErro := 0, cNome := "", nIndc:= 0
Local aLstCliAlgumTit 	:= {}//clientens com algum titulos configurado para disparar email de cobranca                                     
Local nTemTitMarcado 	:= 0, cAVencer := '', cPendentes:=''
Local cParcNome 		:= ""
Local cNewNome  		:= ""                   
Local cNome     		:= ""
Local lTLS				:= .F.
Local lUsaSSl 			:= .F.
Local lRelAuth 			:= .F.
Local nIndChar 			:= 0
Local cTitMail 			:= "Aviso de cobrança eletrônica"
Local cPathHtml         := GetNewPar("ES_PAHTML","email_cobranca")
Local cPathAVencerHtml  := GetNewPar("ES_AVHTML","avencer.html")
Local cAVencMsg			:= ""
Local cAVencHtml 		:= ""   
Local cPDFGer  			:= GetSrvProfString("Startpath","") +  "TIBBOLETO\"

Private	oServer	

Default cTo				:= ""
Default cNomeCli		:= ""
Default cFileBol		:= ""  
Default cFilePDF		:= ""

//--Obtem a configuracao de e-mail:
cMailConta  := SuperGetMV("MV_RELFROM",.F.,"")                                                                                                                                                                                                                                  
cMailServer := SuperGetMV("MV_RELSERV",, '')                                                                                                                                                                                                                                      
cMailSenha  := SuperGetMV("MV_RELPSW" ,.F.,"") 
cMailCtaAut := SuperGetMV("MV_RELACNT",, '') 
nPrtServer  := SuperGetMV('MV_PORSMTP',, 587) 
lRelAuth 	:= SuperGetMV("MV_RELAUTH",.F., .F.)
lTLS	    := SuperGetMV("MV_RELTLS" ,.F.,.F.)
lUsaSSl     := SuperGetMV("MV_RELSSL",.F.,.F.)

If At(":",cMailServer) > 0 
	cMailServer	:= SubStr(cMailServer,1,At(":",cMailServer) - 1 )
EndIf

If GetRemoteType() == 2 // REMOTE_LINUX 
	cAVencHtml     := MemoRead( "/system/" + cPathHtml + "/" + AllTrim(cPathAVencerHtml) )  
Else
	cAVencHtml     := MemoRead( "\system\" + cPathHtml + "\" + AllTrim(cPathAVencerHtml) )  
EndIf

cAVencer := GridCorpoEmail(.T.,aTitCob)

cAVencMsg 	:= STRTRAN ( cAVencHtml , '[NOME DO CLIENTE]' , cNomeCli , 1 , 1 )
cAVencMsg 	:= STRTRAN ( cAVencMsg , '[TITULO]' , cAVencer , 1 , 1 )

//--Cria a conexão com o server STadmin	MP ( Envio de e-mail )
oServer := TMailManager():New()      

//cPrtServer:='587' 
oServer:SetUseTLS(lTLS)  //na Integral tive que ligar TSL para funcionar. No meu PC com esta linha não funciona SSL

oServer:SetUseSSL(lUsaSSl)

//oServer:Init('', cMailServer, cMailCtaAut, cMailSenha, 0, Val(cPrtServer))//25
nRet := oServer:Init('', cMailServer, cMailCtaAut, cMailSenha, 0, nPrtServer)//25

If nRet != 0
  cMsg := "Could not initialize SMTP server: " + oServer:GetErrorString( nRet )
  conout( cMsg )
  Return
Endif

nRet := oServer:SetSMTPTimeOut( 120 )
If NRet != 0
    cMsg := "Could not set " + cProtocol + " timeout to " + cValToChar( 180 )
    conout( cMsg )
Endif
//--Seta um tempo de time out com servidor de 1min  

If  oServer:SMTPConnect() <> 0       //180  

	Conout( "Ocorreu um problema ao determinar o Time-Out do servidor SMTP ou nao foi possível estabelecer a conexao com o mesmo." )
	lContinua := .F.          

Else
	If lRelAuth
		nErro := oServer:SmtpAuth(cMailConta, cMailSenha)
			
		If nErro <> 0
	        cMAilError := oServer:GetErrorString(nErro)
	        DEFAULT cMailError := '***UNKNOW***'
	        ConOut("Erro de Autenticacao " + Str(nErro,4) + '(' + cMAilError + ')')
	        oServer := Nil
	        Return
	    EndIf	
    Endif
EndIf

If lContinua
   	oMessage := TMailMessage():New()         
	//--Limpa o objeto
	oMessage:Clear()

	//--Popula com os dados de envio
	oMessage:cFrom 		:= cMailCtaAut	//cMailConta
	oMessage:cTo 		:= cTo			//"oswaldo.luiz@totvs.com.br"
	oMessage:cSubject   := cTitMail		//SuperGetMV('ES_TITMSG',,'Aviso de Cobrança Eletrônica')       
	oMessage:cBody 		:= cAVencMsg
    //-----------------------------------------------------------------------------------------------------------------
	//lembre-se de que aqui neste ponto todos os registros da array aTitulos fazem uso do mesmo layout.
    //-----------------------------------------------------------------------------------------------------------------

	 cNome :=  cFileBol                               

     If GetRemoteType() == 2 // REMOTE_LINUX 
	     cNewNome := strtran (cNome,"/SYSTEM/","*",1,1)//não sabemos como usuario informou a palavra no parametro, testamos por segurança os dois casos				     
	     cNewNome := strtran (cNome,"/system/","*",1,1)				     
     Else
	     cNewNome := strtran (cNome,"\SYSTEM\","*",1,1)//não sabemos como usuario informou a palavra no parametro, testamos por segurança os dois casos				     
	     cNewNome := strtran (cNome,"\system\","*",1,1)				     
     EndIf
 
     //cNome := "\system\" + GetNewPar("ES_PAHTML","email_cobranca") + "\" + GetNewPar("ES_PAHPDF","PDF_cobranca")  + "\" + cNome			     
    
    If CpyT2S( cNome , cPDFGer ) 	 
		cNome	:= cPDFGer + cFilePdf
	EndIf
	
     nRet := oMessage:AttachFile( cNome )
     If nRet <> 0
     	Conout( "Erro ao anexar arquivo ao e-mail " + cNome ) 
     Endif
 
    //--Envia o e-mail
	ConOut('Enviando mensagem  - Destinatario(s): ' + cNomeCli )
	nSend :=  oMessage:Send(oServer) 
	If nSend!= 0
		Conout( "Erro ao enviar o e-mail " + oServer:GetErrorString( nSend ) ) 	     
	EndIf
    
    oMessage := Nil
		                                                      
	//--Desconecta do servidor
	If oServer:SMTPDisconnect() != 0
		Conout( "Erro ao desconectar do servidor SMTP" )
	EndIf
	
EndIf                                                  

oMessage := Nil
oServer := Nil      

Return

Static FUnction GridCOrpoEMail (lAVencer, aLstTit)
					
Local cGrid 	:= ''
Local cNomBco 	:= ''
Local nY := 0

For nY:=1 to Len(aLstTit)
	
	If aLstTit[nY][4] == '001'
		cNomBco := 'Banco do Brasil'
	ElseIf aLstTit[nY][4] == '033'
		cNomBco := 'Santander'
	ElseIf aLstTit[nY][4] == '237'
		cNomBco := 'Bradesco'
	ElseIf aLstTit[nY][4] == '341'
		cNomBco := 'Itau'
	Endif
	
	cGrid += '<tr class="Text">' + Chr(13)+Chr(10)
	
	If !Empty(aLstTit[nY][3]) // Prefixo + Nr.Titulo + Parcela		                
		cGrid += '<td>' + aLstTit[nY][2] + " - " + aLstTit[nY][1] +  ' - Parcela ' + aLstTit[nY][3]+ '  </td>' + Chr(13)+Chr(10)
    Else
		cGrid += '<td>' + aLstTit[nY][2] + " - " + aLstTit[nY][1] + ' ' + aLstTit[nY][3]+ '  </td>' + Chr(13)+Chr(10)
    Endif

	cGrid += '<td>' + aLstTit[nY][10] + '  </td>' + Chr(13)+Chr(10) // Nosso Numero
    
	cGrid += '<td>' + aLstTit[nY][4] + ' - ' + cNomBco +  '  </td>' + Chr(13)+Chr(10) // Banco
	
	cGrid += '<td>' + aLstTit[nY][5] + '  </td>' + Chr(13)+Chr(10) // Agencia
	cGrid += '<td>' + aLstTit[nY][6] + '  </td>' + Chr(13)+Chr(10) // Conta
	cGrid += '<td>' + DtoC(aLstTit[nY][11]) + '  </td>' + Chr(13)+Chr(10) // Emissao
	cGrid += '<td>' + DtoC(aLstTit[nY][7]) + '  </td>' + Chr(13)+Chr(10) // Vencimento
	cGrid += '<td align="left">R$ ' + Transform(aLstTit[nY][8], PesqPict('SE1', 'E1_SALDO')) + '  </td>' + Chr(13)+Chr(10) // Valor
	cGrid += '<td>' + aLstTit[nY][9] + '</td>' + Chr(13)+Chr(10) // Linha Digitavel

	cGrid += '</tr>' + Chr(13)+Chr(10)

Next nY								

Return(cGrid)
#include 'totvs.ch'
#include "Fileio.ch"
#INCLUDE "TOPCONN.CH"		//Bibliotecas para Top Connect

/*/{Protheus.doc} DXWSTART
Integraï¿½ï¿½o da geraï¿½ï¿½o da revisao de especificaï¿½ï¿½o tecnica com o fluig
@author Rodolfo Novaes de Sousa
@since 23/04/2021
@version 1.0

@type function
/*/
User Function DXWSTART(cFile,cFileName,cProduto,nTipo)
	Local aArea       := GetArea() //Reservando a Area
	Local cMsg        := "" //Mensagem do Soap
	Local cURL        := "" //URL Magento
	Local cUser       := "" //Usuario Magento
	Local cPass       := "" //Senha Magento
	Local lRetURL     := .F. //Retorno do WSDL
	Local cResponse   := "" //Resposta
	Local cRespost    := "" //Resposta
	Local oXml        := Nil //Objeto XML
	Local cError      := ""  //Erros
	Local cWarning    := ""  //Avisos
    Local cFilCont    := Encode64(cFile )
    Local aFiles      := {} // O array receberï¿½ os nomes dos arquivos e do diretï¿½rio
    Local aSizes      := {} // O array receberï¿½ os tamanhos dos arquivos e do diretorio    
    Local aClientes   := {} // Lista dos clientes que receberao o email
    Local n           := 0
    Local cCompId     := Alltrim(SuperGetMV("ES_COMPID", .F.,"3",))
	Private oWSDL     := Nil //Objeto WSDL

	cURL  :=  Alltrim(SuperGetMV("ES_URFLUIG", .F.,"https://fluig.daxia.com.br:8443/webdesk/ECMWorkflowEngineService?wsdl"))  // "https://fluig.daxia.com.br:8443/webdesk/ECMWorkflowEngineService?wsdl"
	cUser :=  Alltrim(SuperGetMV("ES_USFLUIG", .F.,"admin_homolog",))
	cPass :=  Alltrim(SuperGetMV("ES_PSFLUIG", .F.,"Daxia@fluig2021",))

    //converto para base64 o anexo
    ADir(cFile, aFiles, aSizes)//Verifica o tamanho do arquivo, parï¿½metro exigido na FRead.

    If Len(aFiles) == 0
        Alert('Não foi gerado o arquivo PDF!')
        Return
    EndIF
    nHandle := fopen(cFile , FO_READWRITE + FO_SHARED )
    cString := ""
    FRead( nHandle, cString, aSizes[1] ) //Carrega na variï¿½vel cString, a string ASCII do arquivo.

    cFilCont := Encode64(cString) //Converte o arquivo para BASE64

    fclose(nHandle)

    //Cria uma cï¿½pia do arquivo utilizando cTexto em um processo inverso(Decode64) para validar a conversï¿½o.    
    nHandle := fcreate("C:\tmp\" + cFileName) 

    FWrite(nHandle, Decode64(cFilCont))
    fclose(nHandle)

    aClientes := RetClientes(cProduto,nTipo)

    cFileName := LimpaSpec(cFileName)
    
    //Montando mensagem de Requisiï¿½ï¿½o
    cMsg := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ws="http://ws.workflow.ecm.technology.totvs.com/">' +CRLF
    cMsg += '   <soapenv:Header/>'+CRLF
    cMsg += '   <soapenv:Body>'+CRLF
    cMsg += '      <ws:simpleStartProcess>'+CRLF
    cMsg += '         <username>' + cUser + '</username>'+CRLF
    cMsg += '         <password>' + cPass + '</password>'+CRLF
    cMsg += '         <companyId>' + cCompId + '</companyId>'+CRLF
    cMsg += '         <processId>NotificacaoRevisaodeEspecifTecnica</processId>'+CRLF
    cMsg += '         <comments>Pedido recebido pelo ERP ' + DTOC(dDataBase)+'</comments>'+CRLF
    cMsg += '         <attachments>'+CRLF
    cMsg += '           <item>'+CRLF
    cMsg += '               <attachmentSequence>1</attachmentSequence>'+CRLF
    cMsg += '               <attachments>'+CRLF
    cMsg += '                   <attach>false</attach>'+CRLF
    cMsg += '                   <descriptor>false</descriptor>'+CRLF
    cMsg += '                   <editing>false</editing>'+CRLF
    cMsg += '                   <fileName>'+cFileName+'</fileName>'+CRLF
    cMsg += '                   <fileSelected/>'+CRLF
    cMsg += '                   <fileSize>1024</fileSize>'+CRLF
    cMsg += '                   <filecontent>'+ cFilCont + '</filecontent>'+CRLF
    cMsg += '                   <principal>true</principal>'+CRLF
    cMsg += '               </attachments>'    +CRLF
    cMsg += '               <description>'+ cFileName + '</description>'+CRLF
    cMsg += '               <processInstanceId>1</processInstanceId>'+CRLF
    cMsg += '               <size>1024</size>'+CRLF
    cMsg += '               <version></version>'+CRLF
    cMsg += '           </item>'    +CRLF
    cMsg += '         </attachments>'    +CRLF
    cMsg += '         <cardData>'  +CRLF
    cMsg += '           <item>'    +CRLF
    cMsg += '               <item>codigo_produto</item>'    +CRLF
    cMsg += '               <item>'+cProduto+'</item>'       +CRLF
    cMsg += '            </item>'       +CRLF
    cMsg += '           <item>'    +CRLF
    cMsg += '               <item>descricao_produto</item>'    +CRLF
    cMsg += '               <item>![CDATA['+LimpaSpec(Posicione('SB1',1,xFilial('SB1') + cProduto, 'B1_DESC'))+']]</item>'       +CRLF
    cMsg += '            </item>'           +CRLF
    If Len(aClientes) > 0
        For n := 1 to Len(aClientes)
            cMsg += '           <item>'    +CRLF
            cMsg += '               <item>codigo_cliente___'+ Alltrim(STR(n))+'</item>'    +CRLF
            cMsg += '               <item>'+ aClientes[n][1]+'</item>'       +CRLF
            cMsg += '            </item>'  +CRLF
            cMsg += '           <item>'    +CRLF
            cMsg += '               <item>nome_cliente___'+ Alltrim(STR(n))+'</item>'    +CRLF
            cMsg += '               <item>'+ LimpaSpec(aClientes[n][2])+'</item>'       +CRLF
            cMsg += '            </item>'       +CRLF
            cMsg += '           <item>'    +CRLF
            cMsg += '               <item>email_cliente___'+ Alltrim(STR(n))+'</item>'    +CRLF
            cMsg += '               <item>'+ LimpaSpec(aClientes[n][3])+'</item>'       +CRLF
            cMsg += '            </item>'                +CRLF
        Next    
    Else
        cMsg += '           <item>'    +CRLF
        cMsg += '               <item>codigo_cliente___'+ '1' +'</item>'    +CRLF
        cMsg += '               <item>'+ 'CODIGO'+'</item>'       +CRLF
        cMsg += '            </item>'  +CRLF
        cMsg += '           <item>'    +CRLF
        cMsg += '               <item>nome_cliente___'+ '1'+'</item>'    +CRLF
        cMsg += '               <item>'+ 'CLIENTE'+'</item>'       +CRLF
        cMsg += '            </item>'       +CRLF
        cMsg += '           <item>'    +CRLF
        cMsg += '               <item>email_cliente___'+ '1' +'</item>'    +CRLF
        cMsg += '               <item>'+ 'rodolfo.novaes@totvs.com.br' +'</item>'       +CRLF
        cMsg += '            </item>'                +CRLF    
    EndIf
    cMsg += '         </cardData>'    +CRLF
    cMsg += '      </ws:simpleStartProcess>'+CRLF
    cMsg += '   </soapenv:Body>'+CRLF
    cMsg += '</soapenv:Envelope>'+CRLF

    memowrite('C:\TEMP\' + Alltrim(cProduto) + '.txt' ,cMsg)
    //Intanciando WSDL
    If (oWSDL == Nil)
        oWSDL := TWSDLManager():New()
        oWSDL:lSSLInsecure := .T.
        If (lRetURL := oWSDL:ParseURL(cURL))
            If (lRetURL := oWSDL:SetOperation( "simpleStartProcess" ))
                If (lRetURL := oWSDL:SendSoapMsg(cMsg))
                    cResponse := oWSDL:GetParsedResponse()
                    cRespost  := oWSDL:GetSoapResponse()
                    oXml      := XmlParser( cRespost, "_", @cError, @cWarning )
                Else
                    cError := oWSDL:cError
                    MemoWrite('c:\temp\XMLFLUIG.XML', cMsg)
                EndIf
            EndIf
        EndIf
    Else
        If (lRetURL := oWSDL:SendSoapMsg(cMsg))
            cResponse := oWSDL:GetParsedResponse()
            cRespost  := oWSDL:GetSoapResponse()
            oXml      := XmlParser( cRespost, "_", @cError, @cWarning )
        Else
            cError := oWSDL:cError
        EndIf
    EndIf

    If lRetURL
        MsgInfo('Integrado com o Fluig! ' + CRLF + cResponse )
    Else
        Alert('Erro na integraïção com o Fluig ' + cError)
    EndIF

	RestArea(aArea) //Restaurando a Area
Return



/*/{Protheus.doc} RetClientes()
    (long_description)
    @type  Static Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function RetClientes(cProduto,nTipo)
Local cQuery	:= ''
Local cAliasQry := GetNextAlias()
Local aRet		:= {}
Local dDataIni  := Stod(' ')
Local dDataFim  := Stod(' ')

//Pego os Clientes
cQuery := "SELECT DISTINCT SA1.A1_COD ,SA1.A1_LOJA , SA1.A1_NOME , SA1.A1_XMAILLD"
cQuery += "  FROM " + RetSQLTab('SD2') 
cQuery += "  INNER JOIN " + RetSQLTab('SA1') + " ON A1_COD = D2_CLIENTE AND A1_LOJA = D2_LOJA AND A1_XSITUA = '1' "
cQuery += "  WHERE  "
cQuery += "  D2_COD = '" + cProduto +"' "
cQuery += "  AND  D2_EMISSAO >= '" + DTOS(DaySub(dDataBase,90)) +"' "
cQuery += "  AND SD2.D_E_L_E_T_ = ' '"
cQuery += "  AND SA1.D_E_L_E_T_ = ' '"

TcQuery cQuery new Alias ( cAliasQry )
(cAliasQry)->(dbGoTop())

While !(cAliasQry)->(EOF()) 
    aadd(aRet,{(cAliasQry)->A1_COD + (cAliasQry)->A1_LOJA , LimpaSpec((cAliasQry)->A1_NOME) , IIF(EMPTY(GETMV('ES_MAILTST')),(cAliasQry)->A1_XMAILLD, GETMV('ES_MAILTST'))})
    (cAliasQry)->(DbSkip())
EndDo
Return aRet 


Static Function LimpaSpec(cConteudo)
Local cRet        := ''    
//Retirando caracteres
cConteudo := StrTran(cConteudo, "'", "")
cConteudo := StrTran(cConteudo, "#", "")
//cConteudo := StrTran(cConteudo, "%", "")
cConteudo := StrTran(cConteudo, "*", "")
cConteudo := StrTran(cConteudo, "&", "E")
cConteudo := StrTran(cConteudo, ">", "")
cConteudo := StrTran(cConteudo, "<", "")
cConteudo := StrTran(cConteudo, "!", "")
//cConteudo := StrTran(cConteudo, "@", "")
cConteudo := StrTran(cConteudo, "$", "")
cConteudo := StrTran(cConteudo, "(", "")
cConteudo := StrTran(cConteudo, ")", "")
cConteudo := StrTran(cConteudo, "_", "")
cConteudo := StrTran(cConteudo, "=", "")
cConteudo := StrTran(cConteudo, "+", "")
cConteudo := StrTran(cConteudo, "{", "")
cConteudo := StrTran(cConteudo, "}", "")
cConteudo := StrTran(cConteudo, "[", "")
cConteudo := StrTran(cConteudo, "]", "")
cConteudo := StrTran(cConteudo, "/", "")
cConteudo := StrTran(cConteudo, "?", "")
//cConteudo := StrTran(cConteudo, ".", "")
cConteudo := StrTran(cConteudo, "\", "")
cConteudo := StrTran(cConteudo, "|", "")
cConteudo := StrTran(cConteudo, ":", "")
cConteudo := StrTran(cConteudo, ";", "")
cConteudo := StrTran(cConteudo, '"', '')
cConteudo := StrTran(cConteudo, 'ï¿½', '')
cConteudo := StrTran(cConteudo, 'ï¿½', '')
cConteudo := StrTran(cConteudo, ",", "")
//cConteudo := StrTran(cConteudo, "-", "")
cConteudo := StrTran(cConteudo, "Á", "A")
cConteudo := StrTran(cConteudo, "É", "E")
cConteudo := StrTran(cConteudo, "Í", "I")
cConteudo := StrTran(cConteudo, "Ó", "O")
cConteudo := StrTran(cConteudo, "Ú", "U")
cConteudo := StrTran(cConteudo, "À", "A")
cConteudo := StrTran(cConteudo, "È", "E")
cConteudo := StrTran(cConteudo, "Ì", "I")
cConteudo := StrTran(cConteudo, "Ò", "O")
cConteudo := StrTran(cConteudo, "Ù", "U")
cConteudo := StrTran(cConteudo, "Ã", "A")
cConteudo := StrTran(cConteudo, "Õ", "O")

cConteudo := StrTran(cConteudo, "á", "a")
cConteudo := StrTran(cConteudo, "é", "e")
cConteudo := StrTran(cConteudo, "í", "i")
cConteudo := StrTran(cConteudo, "ó", "o")
cConteudo := StrTran(cConteudo, "ú", "u")
cConteudo := StrTran(cConteudo, "à", "a")
cConteudo := StrTran(cConteudo, "è", "e")
cConteudo := StrTran(cConteudo, "ì", "i")
cConteudo := StrTran(cConteudo, "ò", "o")
cConteudo := StrTran(cConteudo, "ù", "u")
cConteudo := StrTran(cConteudo, "ã", "a")
cConteudo := StrTran(cConteudo, "õ", "o")
   
//Definindo o conteï¿½do do campo
cRet := cConteudo

Return cRet

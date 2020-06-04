#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"
#INCLUDE "shash.ch"
#INCLUDE "json.ch"
#INCLUDE "aarray.ch"

/* ===============================================================================
WSDL Location    http://www.soawebservices.com.br/webservices/test-drive/serasa/concentre.asmx?wsdl
Gerado em        08/08/19 11:08:47
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _QJNUHLS ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSCONCENTRE
------------------------------------------------------------------------------- */

WSCLIENT WSCONCENTRE

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD Concentre

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   oWSCredenciais            AS SERASA_Credenciais
	WSDATA   cDocumento                AS string
	WSDATA   oWSAdicionais             AS SERASA_ArrayOfItemAdicional
	WSDATA   oWSConcentreResult        AS SERASA_Concentre

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSCONCENTRE
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.170117A-20190212] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
If val(right(GetWSCVer(),8)) < 1.040504
	UserException("O Código-Fonte Client atual requer a versão de Lib para WebServices igual ou superior a ADVPL WSDL Client 1.040504. Atualize o repositório ou gere o Código-Fonte novamente utilizando o repositório atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSCONCENTRE
	::oWSCredenciais     := SERASA_CREDENCIAIS():New()
	::oWSAdicionais      := SERASA_ARRAYOFITEMADICIONAL():New()
	::oWSConcentreResult := SERASA_CONCENTRE():New()
Return

WSMETHOD RESET WSCLIENT WSCONCENTRE
	::oWSCredenciais     := NIL 
	::cDocumento         := NIL 
	::oWSAdicionais      := NIL 
	::oWSConcentreResult := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSCONCENTRE
Local oClone := WSCONCENTRE():New()
	oClone:_URL          := ::_URL 
	oClone:oWSCredenciais :=  IIF(::oWSCredenciais = NIL , NIL ,::oWSCredenciais:Clone() )
	oClone:cDocumento    := ::cDocumento
	oClone:oWSAdicionais :=  IIF(::oWSAdicionais = NIL , NIL ,::oWSAdicionais:Clone() )
	oClone:oWSConcentreResult :=  IIF(::oWSConcentreResult = NIL , NIL ,::oWSConcentreResult:Clone() )
Return oClone

// WSDL Method Concentre of Service WSCONCENTRE

WSMETHOD Concentre WSSEND oWSCredenciais,cDocumento,oWSAdicionais WSRECEIVE oWSConcentreResult WSCLIENT WSCONCENTRE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<Concentre xmlns="SOAWebServices">'
cSoap += WSSoapValue("Credenciais", ::oWSCredenciais, oWSCredenciais , "Credenciais", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Documento", ::cDocumento, cDocumento , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Adicionais", ::oWSAdicionais, oWSAdicionais , "ArrayOfItemAdicional", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</Concentre>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"SOAWebServices/Concentre",; 
	"DOCUMENT","SOAWebServices",,,; 
	"http://www.soawebservices.com.br/webservices/test-drive/serasa/concentre.asmx")

::Init()
::oWSConcentreResult:SoapRecv( WSAdvValue( oXmlRet,"_CONCENTRERESPONSE:_CONCENTRERESULT","Concentre",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure Credenciais

WSSTRUCT SERASA_Credenciais
	WSDATA   cEmail                    AS string OPTIONAL
	WSDATA   cSenha                    AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SERASA_Credenciais
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SERASA_Credenciais
Return

WSMETHOD CLONE WSCLIENT SERASA_Credenciais
	Local oClone := SERASA_Credenciais():NEW()
	oClone:cEmail               := ::cEmail
	oClone:cSenha               := ::cSenha
Return oClone

WSMETHOD SOAPSEND WSCLIENT SERASA_Credenciais
	Local cSoap := ""
	cSoap += WSSoapValue("Email", ::cEmail, ::cEmail , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Senha", ::cSenha, ::cSenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure ArrayOfItemAdicional

WSSTRUCT SERASA_ArrayOfItemAdicional
	WSDATA   oWSItemAdicional          AS SERASA_ItemAdicional OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SERASA_ArrayOfItemAdicional
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SERASA_ArrayOfItemAdicional
	::oWSItemAdicional     := {} // Array Of  SERASA_ITEMADICIONAL():New()
Return

WSMETHOD CLONE WSCLIENT SERASA_ArrayOfItemAdicional
	Local oClone := SERASA_ArrayOfItemAdicional():NEW()
	oClone:oWSItemAdicional := NIL
	If ::oWSItemAdicional <> NIL 
		oClone:oWSItemAdicional := {}
		aEval( ::oWSItemAdicional , { |x| aadd( oClone:oWSItemAdicional , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT SERASA_ArrayOfItemAdicional
	Local cSoap := ""
	aEval( ::oWSItemAdicional , {|x| cSoap := cSoap  +  WSSoapValue("ItemAdicional", x , x , "ItemAdicional", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure Concentre

WSSTRUCT SERASA_Concentre
	WSDATA   oWSSinteseCadastral       AS SERASA_SinteseCadastral OPTIONAL
	WSDATA   nTotalOcorrencias         AS int
	WSDATA   cValorTotalOcorrencias    AS string OPTIONAL
	WSDATA   oWSAlertaDocumentos       AS SERASA_AlertaDeDocumentos OPTIONAL
	WSDATA   oWSPendenciasInternas     AS SERASA_PendenciasInternas OPTIONAL
	WSDATA   oWSRestricoesFinanceiras  AS SERASA_RestricoesFinanceiras OPTIONAL
	WSDATA   oWSPendenciasFinanceiras  AS SERASA_PendenciasFinanceiras OPTIONAL
	WSDATA   oWSPendenciasBacen        AS SERASA_PendenciasBacen OPTIONAL
	WSDATA   oWSProtestos              AS SERASA_Protestos OPTIONAL
	WSDATA   oWSAcoesJudiciais         AS SERASA_AcoesJudiciais OPTIONAL
	WSDATA   oWSAcheiRecheque          AS SERASA_AcheiRecheque OPTIONAL
	WSDATA   oWSConvemDevedores        AS SERASA_ConvemDevedores OPTIONAL
	WSDATA   oWSParticipacoesFalencias AS SERASA_ParticipacoesFalencias OPTIONAL
	WSDATA   oWSQSA                    AS SERASA_QSA OPTIONAL
	WSDATA   oWSParticipacoes          AS SERASA_Participacoes OPTIONAL
	WSDATA   oWSRiskScore              AS SERASA_RiskScore OPTIONAL
	WSDATA   cMensagem                 AS string OPTIONAL
	WSDATA   lStatus                   AS boolean
	WSDATA   oWSTransacao              AS SERASA_Transacao OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SERASA_Concentre
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SERASA_Concentre
Return

WSMETHOD CLONE WSCLIENT SERASA_Concentre
	Local oClone := SERASA_Concentre():NEW()
	oClone:oWSSinteseCadastral  := IIF(::oWSSinteseCadastral = NIL , NIL , ::oWSSinteseCadastral:Clone() )
	oClone:nTotalOcorrencias    := ::nTotalOcorrencias
	oClone:cValorTotalOcorrencias := ::cValorTotalOcorrencias
	oClone:oWSAlertaDocumentos  := IIF(::oWSAlertaDocumentos = NIL , NIL , ::oWSAlertaDocumentos:Clone() )
	oClone:oWSPendenciasInternas := IIF(::oWSPendenciasInternas = NIL , NIL , ::oWSPendenciasInternas:Clone() )
	oClone:oWSRestricoesFinanceiras := IIF(::oWSRestricoesFinanceiras = NIL , NIL , ::oWSRestricoesFinanceiras:Clone() )
	oClone:oWSPendenciasFinanceiras := IIF(::oWSPendenciasFinanceiras = NIL , NIL , ::oWSPendenciasFinanceiras:Clone() )
	oClone:oWSPendenciasBacen   := IIF(::oWSPendenciasBacen = NIL , NIL , ::oWSPendenciasBacen:Clone() )
	oClone:oWSProtestos         := IIF(::oWSProtestos = NIL , NIL , ::oWSProtestos:Clone() )
	oClone:oWSAcoesJudiciais    := IIF(::oWSAcoesJudiciais = NIL , NIL , ::oWSAcoesJudiciais:Clone() )
	oClone:oWSAcheiRecheque     := IIF(::oWSAcheiRecheque = NIL , NIL , ::oWSAcheiRecheque:Clone() )
	oClone:oWSConvemDevedores   := IIF(::oWSConvemDevedores = NIL , NIL , ::oWSConvemDevedores:Clone() )
	oClone:oWSParticipacoesFalencias := IIF(::oWSParticipacoesFalencias = NIL , NIL , ::oWSParticipacoesFalencias:Clone() )
	oClone:oWSQSA               := IIF(::oWSQSA = NIL , NIL , ::oWSQSA:Clone() )
	oClone:oWSParticipacoes     := IIF(::oWSParticipacoes = NIL , NIL , ::oWSParticipacoes:Clone() )
	oClone:oWSRiskScore         := IIF(::oWSRiskScore = NIL , NIL , ::oWSRiskScore:Clone() )
	oClone:cMensagem            := ::cMensagem
	oClone:lStatus              := ::lStatus
	oClone:oWSTransacao         := IIF(::oWSTransacao = NIL , NIL , ::oWSTransacao:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SERASA_Concentre
	Local oNode1
	Local oNode4
	Local oNode5
	Local oNode6
	Local oNode7
	Local oNode8
	Local oNode9
	Local oNode10
	Local oNode11
	Local oNode12
	Local oNode13
	Local oNode14
	Local oNode15
	Local oNode16
	Local oNode19
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_SINTESECADASTRAL","SinteseCadastral",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSSinteseCadastral := SERASA_SinteseCadastral():New()
		::oWSSinteseCadastral:SoapRecv(oNode1)
	EndIf
	::nTotalOcorrencias  :=  WSAdvValue( oResponse,"_TOTALOCORRENCIAS","int",NIL,"Property nTotalOcorrencias as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cValorTotalOcorrencias :=  WSAdvValue( oResponse,"_VALORTOTALOCORRENCIAS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode4 :=  WSAdvValue( oResponse,"_ALERTADOCUMENTOS","AlertaDeDocumentos",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode4 != NIL
		::oWSAlertaDocumentos := SERASA_AlertaDeDocumentos():New()
		::oWSAlertaDocumentos:SoapRecv(oNode4)
	EndIf
	oNode5 :=  WSAdvValue( oResponse,"_PENDENCIASINTERNAS","PendenciasInternas",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode5 != NIL
		::oWSPendenciasInternas := SERASA_PendenciasInternas():New()
		::oWSPendenciasInternas:SoapRecv(oNode5)
	EndIf
	oNode6 :=  WSAdvValue( oResponse,"_RESTRICOESFINANCEIRAS","RestricoesFinanceiras",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode6 != NIL
		::oWSRestricoesFinanceiras := SERASA_RestricoesFinanceiras():New()
		::oWSRestricoesFinanceiras:SoapRecv(oNode6)
	EndIf
	oNode7 :=  WSAdvValue( oResponse,"_PENDENCIASFINANCEIRAS","PendenciasFinanceiras",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode7 != NIL
		::oWSPendenciasFinanceiras := SERASA_PendenciasFinanceiras():New()
		::oWSPendenciasFinanceiras:SoapRecv(oNode7)
	EndIf
	oNode8 :=  WSAdvValue( oResponse,"_PENDENCIASBACEN","PendenciasBacen",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode8 != NIL
		::oWSPendenciasBacen := SERASA_PendenciasBacen():New()
		::oWSPendenciasBacen:SoapRecv(oNode8)
	EndIf
	oNode9 :=  WSAdvValue( oResponse,"_PROTESTOS","Protestos",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode9 != NIL
		::oWSProtestos := SERASA_Protestos():New()
		::oWSProtestos:SoapRecv(oNode9)
	EndIf
	oNode10 :=  WSAdvValue( oResponse,"_ACOESJUDICIAIS","AcoesJudiciais",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode10 != NIL
		::oWSAcoesJudiciais := SERASA_AcoesJudiciais():New()
		::oWSAcoesJudiciais:SoapRecv(oNode10)
	EndIf
	oNode11 :=  WSAdvValue( oResponse,"_ACHEIRECHEQUE","AcheiRecheque",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode11 != NIL
		::oWSAcheiRecheque := SERASA_AcheiRecheque():New()
		::oWSAcheiRecheque:SoapRecv(oNode11)
	EndIf
	oNode12 :=  WSAdvValue( oResponse,"_CONVEMDEVEDORES","ConvemDevedores",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode12 != NIL
		::oWSConvemDevedores := SERASA_ConvemDevedores():New()
		::oWSConvemDevedores:SoapRecv(oNode12)
	EndIf
	oNode13 :=  WSAdvValue( oResponse,"_PARTICIPACOESFALENCIAS","ParticipacoesFalencias",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode13 != NIL
		::oWSParticipacoesFalencias := SERASA_ParticipacoesFalencias():New()
		::oWSParticipacoesFalencias:SoapRecv(oNode13)
	EndIf
	oNode14 :=  WSAdvValue( oResponse,"_QSA","QSA",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode14 != NIL
		::oWSQSA := SERASA_QSA():New()
		::oWSQSA:SoapRecv(oNode14)
	EndIf
	oNode15 :=  WSAdvValue( oResponse,"_PARTICIPACOES","Participacoes",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode15 != NIL
		::oWSParticipacoes := SERASA_Participacoes():New()
		::oWSParticipacoes:SoapRecv(oNode15)
	EndIf
	oNode16 :=  WSAdvValue( oResponse,"_RISKSCORE","RiskScore",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode16 != NIL
		::oWSRiskScore := SERASA_RiskScore():New()
		::oWSRiskScore:SoapRecv(oNode16)
	EndIf
	::cMensagem          :=  WSAdvValue( oResponse,"_MENSAGEM","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::lStatus            :=  WSAdvValue( oResponse,"_STATUS","boolean",NIL,"Property lStatus as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	oNode19 :=  WSAdvValue( oResponse,"_TRANSACAO","Transacao",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode19 != NIL
		::oWSTransacao := SERASA_Transacao():New()
		::oWSTransacao:SoapRecv(oNode19)
	EndIf
Return

// WSDL Data Enumeration ItemAdicional

WSSTRUCT SERASA_ItemAdicional
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SERASA_ItemAdicional
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "Nenhum" )
	aadd(::aValueList , "QuadroDeSocios" )
	aadd(::aValueList , "Participacoes" )
	aadd(::aValueList , "RiskScoring" )
	aadd(::aValueList , "LimiteCredito" )
	aadd(::aValueList , "ClassificacaoRiscoCredito" )
Return Self

WSMETHOD SOAPSEND WSCLIENT SERASA_ItemAdicional
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SERASA_ItemAdicional
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT SERASA_ItemAdicional
Local oClone := SERASA_ItemAdicional():New()
	oClone:Value := ::Value
Return oClone

// WSDL Data Structure SinteseCadastral

WSSTRUCT SERASA_SinteseCadastral
	WSDATA   cDocumento                AS string OPTIONAL
	WSDATA   cNome                     AS string OPTIONAL
	WSDATA   cNomeMae                  AS string OPTIONAL
	WSDATA   cNomeFantasia             AS string OPTIONAL
	WSDATA   cDataNascimento           AS string OPTIONAL
	WSDATA   cDataFundacao             AS string OPTIONAL
	WSDATA   cSituacaoRFB              AS string OPTIONAL
	WSDATA   cSituacaoDescricaoRFB     AS string OPTIONAL
	WSDATA   cDataSituacaoRFB          AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SERASA_SinteseCadastral
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SERASA_SinteseCadastral
Return

WSMETHOD CLONE WSCLIENT SERASA_SinteseCadastral
	Local oClone := SERASA_SinteseCadastral():NEW()
	oClone:cDocumento           := ::cDocumento
	oClone:cNome                := ::cNome
	oClone:cNomeMae             := ::cNomeMae
	oClone:cNomeFantasia        := ::cNomeFantasia
	oClone:cDataNascimento      := ::cDataNascimento
	oClone:cDataFundacao        := ::cDataFundacao
	oClone:cSituacaoRFB         := ::cSituacaoRFB
	oClone:cSituacaoDescricaoRFB := ::cSituacaoDescricaoRFB
	oClone:cDataSituacaoRFB     := ::cDataSituacaoRFB
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SERASA_SinteseCadastral
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cDocumento         :=  WSAdvValue( oResponse,"_DOCUMENTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNome              :=  WSAdvValue( oResponse,"_NOME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNomeMae           :=  WSAdvValue( oResponse,"_NOMEMAE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNomeFantasia      :=  WSAdvValue( oResponse,"_NOMEFANTASIA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDataNascimento    :=  WSAdvValue( oResponse,"_DATANASCIMENTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDataFundacao      :=  WSAdvValue( oResponse,"_DATAFUNDACAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSituacaoRFB       :=  WSAdvValue( oResponse,"_SITUACAORFB","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSituacaoDescricaoRFB :=  WSAdvValue( oResponse,"_SITUACAODESCRICAORFB","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDataSituacaoRFB   :=  WSAdvValue( oResponse,"_DATASITUACAORFB","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure AlertaDeDocumentos

WSSTRUCT SERASA_AlertaDeDocumentos
	WSDATA   cNumeroMensagem           AS string OPTIONAL
	WSDATA   cTotalMensagens           AS string OPTIONAL
	WSDATA   cTipoDocumento            AS string OPTIONAL
	WSDATA   cNumeroDocumento          AS string OPTIONAL
	WSDATA   cMotivoOcorrencia         AS string OPTIONAL
	WSDATA   cDataOcorrencia           AS string OPTIONAL
	WSDATA   oWSTelefonesContato       AS SERASA_TelefonesContato OPTIONAL
	WSDATA   cMensagem                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SERASA_AlertaDeDocumentos
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SERASA_AlertaDeDocumentos
	::oWSTelefonesContato  := {} // Array Of  SERASA_TELEFONESCONTATO():New()
Return

WSMETHOD CLONE WSCLIENT SERASA_AlertaDeDocumentos
	Local oClone := SERASA_AlertaDeDocumentos():NEW()
	oClone:cNumeroMensagem      := ::cNumeroMensagem
	oClone:cTotalMensagens      := ::cTotalMensagens
	oClone:cTipoDocumento       := ::cTipoDocumento
	oClone:cNumeroDocumento     := ::cNumeroDocumento
	oClone:cMotivoOcorrencia    := ::cMotivoOcorrencia
	oClone:cDataOcorrencia      := ::cDataOcorrencia
	oClone:oWSTelefonesContato := NIL
	If ::oWSTelefonesContato <> NIL 
		oClone:oWSTelefonesContato := {}
		aEval( ::oWSTelefonesContato , { |x| aadd( oClone:oWSTelefonesContato , x:Clone() ) } )
	Endif 
	oClone:cMensagem            := ::cMensagem
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SERASA_AlertaDeDocumentos
	Local nRElem7, oNodes7, nTElem7
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cNumeroMensagem    :=  WSAdvValue( oResponse,"_NUMEROMENSAGEM","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTotalMensagens    :=  WSAdvValue( oResponse,"_TOTALMENSAGENS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTipoDocumento     :=  WSAdvValue( oResponse,"_TIPODOCUMENTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNumeroDocumento   :=  WSAdvValue( oResponse,"_NUMERODOCUMENTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cMotivoOcorrencia  :=  WSAdvValue( oResponse,"_MOTIVOOCORRENCIA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDataOcorrencia    :=  WSAdvValue( oResponse,"_DATAOCORRENCIA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNodes7 :=  WSAdvValue( oResponse,"_TELEFONESCONTATO","TelefonesContato",{},NIL,.T.,"O",NIL,NIL) 
	nTElem7 := len(oNodes7)
	For nRElem7 := 1 to nTElem7 
		If !WSIsNilNode( oNodes7[nRElem7] )
			aadd(::oWSTelefonesContato , SERASA_TelefonesContato():New() )
			::oWSTelefonesContato[len(::oWSTelefonesContato)]:SoapRecv(oNodes7[nRElem7])
		Endif
	Next
	::cMensagem          :=  WSAdvValue( oResponse,"_MENSAGEM","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure PendenciasInternas

WSSTRUCT SERASA_PendenciasInternas
	WSDATA   nTotalOcorrencias         AS int
	WSDATA   cOcorrenciaMaisAntiga     AS string OPTIONAL
	WSDATA   cOcorrenciaMaisRecente    AS string OPTIONAL
	WSDATA   cValorTotalOcorrencias    AS string OPTIONAL
	WSDATA   oWSPendenciasIternasDetalhe AS SERASA_PendenciasInternasDetalhe OPTIONAL
	WSDATA   cMensagem                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SERASA_PendenciasInternas
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SERASA_PendenciasInternas
	::oWSPendenciasIternasDetalhe := {} // Array Of  SERASA_PENDENCIASINTERNASDETALHE():New()
Return

WSMETHOD CLONE WSCLIENT SERASA_PendenciasInternas
	Local oClone := SERASA_PendenciasInternas():NEW()
	oClone:nTotalOcorrencias    := ::nTotalOcorrencias
	oClone:cOcorrenciaMaisAntiga := ::cOcorrenciaMaisAntiga
	oClone:cOcorrenciaMaisRecente := ::cOcorrenciaMaisRecente
	oClone:cValorTotalOcorrencias := ::cValorTotalOcorrencias
	oClone:oWSPendenciasIternasDetalhe := NIL
	If ::oWSPendenciasIternasDetalhe <> NIL 
		oClone:oWSPendenciasIternasDetalhe := {}
		aEval( ::oWSPendenciasIternasDetalhe , { |x| aadd( oClone:oWSPendenciasIternasDetalhe , x:Clone() ) } )
	Endif 
	oClone:cMensagem            := ::cMensagem
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SERASA_PendenciasInternas
	Local nRElem5, oNodes5, nTElem5
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nTotalOcorrencias  :=  WSAdvValue( oResponse,"_TOTALOCORRENCIAS","int",NIL,"Property nTotalOcorrencias as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cOcorrenciaMaisAntiga :=  WSAdvValue( oResponse,"_OCORRENCIAMAISANTIGA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cOcorrenciaMaisRecente :=  WSAdvValue( oResponse,"_OCORRENCIAMAISRECENTE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cValorTotalOcorrencias :=  WSAdvValue( oResponse,"_VALORTOTALOCORRENCIAS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNodes5 :=  WSAdvValue( oResponse,"_PENDENCIASITERNASDETALHE","PendenciasInternasDetalhe",{},NIL,.T.,"O",NIL,NIL) 
	nTElem5 := len(oNodes5)
	For nRElem5 := 1 to nTElem5 
		If !WSIsNilNode( oNodes5[nRElem5] )
			aadd(::oWSPendenciasIternasDetalhe , SERASA_PendenciasInternasDetalhe():New() )
			::oWSPendenciasIternasDetalhe[len(::oWSPendenciasIternasDetalhe)]:SoapRecv(oNodes5[nRElem5])
		Endif
	Next
	::cMensagem          :=  WSAdvValue( oResponse,"_MENSAGEM","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure RestricoesFinanceiras

WSSTRUCT SERASA_RestricoesFinanceiras
	WSDATA   nTotalOcorrencias         AS int
	WSDATA   cOcorrenciaMaisAntiga     AS string OPTIONAL
	WSDATA   cOcorrenciaMaisRecente    AS string OPTIONAL
	WSDATA   cValorTotalOcorrencias    AS string OPTIONAL
	WSDATA   oWSRestricoesFinanceirasDetalhe AS SERASA_RestricaoFinanceiraDetalhe OPTIONAL
	WSDATA   cMensagem                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SERASA_RestricoesFinanceiras
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SERASA_RestricoesFinanceiras
	::oWSRestricoesFinanceirasDetalhe := {} // Array Of  SERASA_RESTRICAOFINANCEIRADETALHE():New()
Return

WSMETHOD CLONE WSCLIENT SERASA_RestricoesFinanceiras
	Local oClone := SERASA_RestricoesFinanceiras():NEW()
	oClone:nTotalOcorrencias    := ::nTotalOcorrencias
	oClone:cOcorrenciaMaisAntiga := ::cOcorrenciaMaisAntiga
	oClone:cOcorrenciaMaisRecente := ::cOcorrenciaMaisRecente
	oClone:cValorTotalOcorrencias := ::cValorTotalOcorrencias
	oClone:oWSRestricoesFinanceirasDetalhe := NIL
	If ::oWSRestricoesFinanceirasDetalhe <> NIL 
		oClone:oWSRestricoesFinanceirasDetalhe := {}
		aEval( ::oWSRestricoesFinanceirasDetalhe , { |x| aadd( oClone:oWSRestricoesFinanceirasDetalhe , x:Clone() ) } )
	Endif 
	oClone:cMensagem            := ::cMensagem
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SERASA_RestricoesFinanceiras
	Local nRElem5, oNodes5, nTElem5
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nTotalOcorrencias  :=  WSAdvValue( oResponse,"_TOTALOCORRENCIAS","int",NIL,"Property nTotalOcorrencias as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cOcorrenciaMaisAntiga :=  WSAdvValue( oResponse,"_OCORRENCIAMAISANTIGA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cOcorrenciaMaisRecente :=  WSAdvValue( oResponse,"_OCORRENCIAMAISRECENTE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cValorTotalOcorrencias :=  WSAdvValue( oResponse,"_VALORTOTALOCORRENCIAS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNodes5 :=  WSAdvValue( oResponse,"_RESTRICOESFINANCEIRASDETALHE","RestricaoFinanceiraDetalhe",{},NIL,.T.,"O",NIL,NIL) 
	nTElem5 := len(oNodes5)
	For nRElem5 := 1 to nTElem5 
		If !WSIsNilNode( oNodes5[nRElem5] )
			aadd(::oWSRestricoesFinanceirasDetalhe , SERASA_RestricaoFinanceiraDetalhe():New() )
			::oWSRestricoesFinanceirasDetalhe[len(::oWSRestricoesFinanceirasDetalhe)]:SoapRecv(oNodes5[nRElem5])
		Endif
	Next
	::cMensagem          :=  WSAdvValue( oResponse,"_MENSAGEM","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure PendenciasFinanceiras

WSSTRUCT SERASA_PendenciasFinanceiras
	WSDATA   nTotalOcorrencias         AS int
	WSDATA   cOcorrenciaMaisAntiga     AS string OPTIONAL
	WSDATA   cOcorrenciaMaisRecente    AS string OPTIONAL
	WSDATA   cValorTotalOcorrencias    AS string OPTIONAL
	WSDATA   oWSPendenciasFinanceirasDetalhe AS SERASA_PendenciasFinanceirasDetalhe OPTIONAL
	WSDATA   cMensagem                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SERASA_PendenciasFinanceiras
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SERASA_PendenciasFinanceiras
	::oWSPendenciasFinanceirasDetalhe := {} // Array Of  SERASA_PENDENCIASFINANCEIRASDETALHE():New()
Return

WSMETHOD CLONE WSCLIENT SERASA_PendenciasFinanceiras
	Local oClone := SERASA_PendenciasFinanceiras():NEW()
	oClone:nTotalOcorrencias    := ::nTotalOcorrencias
	oClone:cOcorrenciaMaisAntiga := ::cOcorrenciaMaisAntiga
	oClone:cOcorrenciaMaisRecente := ::cOcorrenciaMaisRecente
	oClone:cValorTotalOcorrencias := ::cValorTotalOcorrencias
	oClone:oWSPendenciasFinanceirasDetalhe := NIL
	If ::oWSPendenciasFinanceirasDetalhe <> NIL 
		oClone:oWSPendenciasFinanceirasDetalhe := {}
		aEval( ::oWSPendenciasFinanceirasDetalhe , { |x| aadd( oClone:oWSPendenciasFinanceirasDetalhe , x:Clone() ) } )
	Endif 
	oClone:cMensagem            := ::cMensagem
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SERASA_PendenciasFinanceiras
	Local nRElem5, oNodes5, nTElem5
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nTotalOcorrencias  :=  WSAdvValue( oResponse,"_TOTALOCORRENCIAS","int",NIL,"Property nTotalOcorrencias as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cOcorrenciaMaisAntiga :=  WSAdvValue( oResponse,"_OCORRENCIAMAISANTIGA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cOcorrenciaMaisRecente :=  WSAdvValue( oResponse,"_OCORRENCIAMAISRECENTE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cValorTotalOcorrencias :=  WSAdvValue( oResponse,"_VALORTOTALOCORRENCIAS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNodes5 :=  WSAdvValue( oResponse,"_PENDENCIASFINANCEIRASDETALHE","PendenciasFinanceirasDetalhe",{},NIL,.T.,"O",NIL,NIL) 
	nTElem5 := len(oNodes5)
	For nRElem5 := 1 to nTElem5 
		If !WSIsNilNode( oNodes5[nRElem5] )
			aadd(::oWSPendenciasFinanceirasDetalhe , SERASA_PendenciasFinanceirasDetalhe():New() )
			::oWSPendenciasFinanceirasDetalhe[len(::oWSPendenciasFinanceirasDetalhe)]:SoapRecv(oNodes5[nRElem5])
		Endif
	Next
	::cMensagem          :=  WSAdvValue( oResponse,"_MENSAGEM","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure PendenciasBacen

WSSTRUCT SERASA_PendenciasBacen
	WSDATA   nTotalOcorrencias         AS int
	WSDATA   cOcorrenciaMaisAntiga     AS string OPTIONAL
	WSDATA   cOcorrenciaMaisRecente    AS string OPTIONAL
	WSDATA   cBanco                    AS string OPTIONAL
	WSDATA   cAgencia                  AS string OPTIONAL
	WSDATA   cNomeFantasiaBanco        AS string OPTIONAL
	WSDATA   oWSPendenciasBacenDetalhe AS SERASA_PendenciaBacenDetalhe OPTIONAL
	WSDATA   cMensagem                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SERASA_PendenciasBacen
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SERASA_PendenciasBacen
	::oWSPendenciasBacenDetalhe := {} // Array Of  SERASA_PENDENCIABACENDETALHE():New()
Return

WSMETHOD CLONE WSCLIENT SERASA_PendenciasBacen
	Local oClone := SERASA_PendenciasBacen():NEW()
	oClone:nTotalOcorrencias    := ::nTotalOcorrencias
	oClone:cOcorrenciaMaisAntiga := ::cOcorrenciaMaisAntiga
	oClone:cOcorrenciaMaisRecente := ::cOcorrenciaMaisRecente
	oClone:cBanco               := ::cBanco
	oClone:cAgencia             := ::cAgencia
	oClone:cNomeFantasiaBanco   := ::cNomeFantasiaBanco
	oClone:oWSPendenciasBacenDetalhe := NIL
	If ::oWSPendenciasBacenDetalhe <> NIL 
		oClone:oWSPendenciasBacenDetalhe := {}
		aEval( ::oWSPendenciasBacenDetalhe , { |x| aadd( oClone:oWSPendenciasBacenDetalhe , x:Clone() ) } )
	Endif 
	oClone:cMensagem            := ::cMensagem
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SERASA_PendenciasBacen
	Local nRElem7, oNodes7, nTElem7
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nTotalOcorrencias  :=  WSAdvValue( oResponse,"_TOTALOCORRENCIAS","int",NIL,"Property nTotalOcorrencias as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cOcorrenciaMaisAntiga :=  WSAdvValue( oResponse,"_OCORRENCIAMAISANTIGA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cOcorrenciaMaisRecente :=  WSAdvValue( oResponse,"_OCORRENCIAMAISRECENTE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cBanco             :=  WSAdvValue( oResponse,"_BANCO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cAgencia           :=  WSAdvValue( oResponse,"_AGENCIA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNomeFantasiaBanco :=  WSAdvValue( oResponse,"_NOMEFANTASIABANCO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNodes7 :=  WSAdvValue( oResponse,"_PENDENCIASBACENDETALHE","PendenciaBacenDetalhe",{},NIL,.T.,"O",NIL,NIL) 
	nTElem7 := len(oNodes7)
	For nRElem7 := 1 to nTElem7 
		If !WSIsNilNode( oNodes7[nRElem7] )
			aadd(::oWSPendenciasBacenDetalhe , SERASA_PendenciaBacenDetalhe():New() )
			::oWSPendenciasBacenDetalhe[len(::oWSPendenciasBacenDetalhe)]:SoapRecv(oNodes7[nRElem7])
		Endif
	Next
	::cMensagem          :=  WSAdvValue( oResponse,"_MENSAGEM","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure Protestos

WSSTRUCT SERASA_Protestos
	WSDATA   nTotalOcorrencias         AS int
	WSDATA   cOcorrenciaMaisAntiga     AS string OPTIONAL
	WSDATA   cOcorrenciaMaisRecente    AS string OPTIONAL
	WSDATA   cValorTotalOcorrencias    AS string OPTIONAL
	WSDATA   oWSProtestosDetalhe       AS SERASA_ProtestoDetalhe OPTIONAL
	WSDATA   cMensagem                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SERASA_Protestos
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SERASA_Protestos
	::oWSProtestosDetalhe  := {} // Array Of  SERASA_PROTESTODETALHE():New()
Return

WSMETHOD CLONE WSCLIENT SERASA_Protestos
	Local oClone := SERASA_Protestos():NEW()
	oClone:nTotalOcorrencias    := ::nTotalOcorrencias
	oClone:cOcorrenciaMaisAntiga := ::cOcorrenciaMaisAntiga
	oClone:cOcorrenciaMaisRecente := ::cOcorrenciaMaisRecente
	oClone:cValorTotalOcorrencias := ::cValorTotalOcorrencias
	oClone:oWSProtestosDetalhe := NIL
	If ::oWSProtestosDetalhe <> NIL 
		oClone:oWSProtestosDetalhe := {}
		aEval( ::oWSProtestosDetalhe , { |x| aadd( oClone:oWSProtestosDetalhe , x:Clone() ) } )
	Endif 
	oClone:cMensagem            := ::cMensagem
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SERASA_Protestos
	Local nRElem5, oNodes5, nTElem5
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nTotalOcorrencias  :=  WSAdvValue( oResponse,"_TOTALOCORRENCIAS","int",NIL,"Property nTotalOcorrencias as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cOcorrenciaMaisAntiga :=  WSAdvValue( oResponse,"_OCORRENCIAMAISANTIGA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cOcorrenciaMaisRecente :=  WSAdvValue( oResponse,"_OCORRENCIAMAISRECENTE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cValorTotalOcorrencias :=  WSAdvValue( oResponse,"_VALORTOTALOCORRENCIAS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNodes5 :=  WSAdvValue( oResponse,"_PROTESTOSDETALHE","ProtestoDetalhe",{},NIL,.T.,"O",NIL,NIL) 
	nTElem5 := len(oNodes5)
	For nRElem5 := 1 to nTElem5 
		If !WSIsNilNode( oNodes5[nRElem5] )
			aadd(::oWSProtestosDetalhe , SERASA_ProtestoDetalhe():New() )
			::oWSProtestosDetalhe[len(::oWSProtestosDetalhe)]:SoapRecv(oNodes5[nRElem5])
		Endif
	Next
	::cMensagem          :=  WSAdvValue( oResponse,"_MENSAGEM","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure AcoesJudiciais

WSSTRUCT SERASA_AcoesJudiciais
	WSDATA   cOcorrenciaMaisAntiga     AS string OPTIONAL
	WSDATA   cOcorrenciaMaisRecente    AS string OPTIONAL
	WSDATA   nTotalOcorrencias         AS int
	WSDATA   cValorTotalOcorrencias    AS string OPTIONAL
	WSDATA   oWSAcoesJudiciaisDetalhe  AS SERASA_AcaoJudiciailDetalhe OPTIONAL
	WSDATA   cMensagem                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SERASA_AcoesJudiciais
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SERASA_AcoesJudiciais
	::oWSAcoesJudiciaisDetalhe := {} // Array Of  SERASA_ACAOJUDICIAILDETALHE():New()
Return

WSMETHOD CLONE WSCLIENT SERASA_AcoesJudiciais
	Local oClone := SERASA_AcoesJudiciais():NEW()
	oClone:cOcorrenciaMaisAntiga := ::cOcorrenciaMaisAntiga
	oClone:cOcorrenciaMaisRecente := ::cOcorrenciaMaisRecente
	oClone:nTotalOcorrencias    := ::nTotalOcorrencias
	oClone:cValorTotalOcorrencias := ::cValorTotalOcorrencias
	oClone:oWSAcoesJudiciaisDetalhe := NIL
	If ::oWSAcoesJudiciaisDetalhe <> NIL 
		oClone:oWSAcoesJudiciaisDetalhe := {}
		aEval( ::oWSAcoesJudiciaisDetalhe , { |x| aadd( oClone:oWSAcoesJudiciaisDetalhe , x:Clone() ) } )
	Endif 
	oClone:cMensagem            := ::cMensagem
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SERASA_AcoesJudiciais
	Local nRElem5, oNodes5, nTElem5
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cOcorrenciaMaisAntiga :=  WSAdvValue( oResponse,"_OCORRENCIAMAISANTIGA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cOcorrenciaMaisRecente :=  WSAdvValue( oResponse,"_OCORRENCIAMAISRECENTE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nTotalOcorrencias  :=  WSAdvValue( oResponse,"_TOTALOCORRENCIAS","int",NIL,"Property nTotalOcorrencias as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cValorTotalOcorrencias :=  WSAdvValue( oResponse,"_VALORTOTALOCORRENCIAS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNodes5 :=  WSAdvValue( oResponse,"_ACOESJUDICIAISDETALHE","AcaoJudiciailDetalhe",{},NIL,.T.,"O",NIL,NIL) 
	nTElem5 := len(oNodes5)
	For nRElem5 := 1 to nTElem5 
		If !WSIsNilNode( oNodes5[nRElem5] )
			aadd(::oWSAcoesJudiciaisDetalhe , SERASA_AcaoJudiciailDetalhe():New() )
			::oWSAcoesJudiciaisDetalhe[len(::oWSAcoesJudiciaisDetalhe)]:SoapRecv(oNodes5[nRElem5])
		Endif
	Next
	::cMensagem          :=  WSAdvValue( oResponse,"_MENSAGEM","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure AcheiRecheque

WSSTRUCT SERASA_AcheiRecheque
	WSDATA   cOcorrenciaMaisAntiga     AS string OPTIONAL
	WSDATA   cOcorrenciaMaisRecente    AS string OPTIONAL
	WSDATA   nTotalOcorrencias         AS int
	WSDATA   cValorTotalOcorrencias    AS string OPTIONAL
	WSDATA   oWSAcheiRechequeDetalhe   AS SERASA_AcheiRechequeDetalhe OPTIONAL
	WSDATA   cMensagem                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SERASA_AcheiRecheque
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SERASA_AcheiRecheque
	::oWSAcheiRechequeDetalhe := {} // Array Of  SERASA_ACHEIRECHEQUEDETALHE():New()
Return

WSMETHOD CLONE WSCLIENT SERASA_AcheiRecheque
	Local oClone := SERASA_AcheiRecheque():NEW()
	oClone:cOcorrenciaMaisAntiga := ::cOcorrenciaMaisAntiga
	oClone:cOcorrenciaMaisRecente := ::cOcorrenciaMaisRecente
	oClone:nTotalOcorrencias    := ::nTotalOcorrencias
	oClone:cValorTotalOcorrencias := ::cValorTotalOcorrencias
	oClone:oWSAcheiRechequeDetalhe := NIL
	If ::oWSAcheiRechequeDetalhe <> NIL 
		oClone:oWSAcheiRechequeDetalhe := {}
		aEval( ::oWSAcheiRechequeDetalhe , { |x| aadd( oClone:oWSAcheiRechequeDetalhe , x:Clone() ) } )
	Endif 
	oClone:cMensagem            := ::cMensagem
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SERASA_AcheiRecheque
	Local nRElem5, oNodes5, nTElem5
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cOcorrenciaMaisAntiga :=  WSAdvValue( oResponse,"_OCORRENCIAMAISANTIGA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cOcorrenciaMaisRecente :=  WSAdvValue( oResponse,"_OCORRENCIAMAISRECENTE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nTotalOcorrencias  :=  WSAdvValue( oResponse,"_TOTALOCORRENCIAS","int",NIL,"Property nTotalOcorrencias as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cValorTotalOcorrencias :=  WSAdvValue( oResponse,"_VALORTOTALOCORRENCIAS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNodes5 :=  WSAdvValue( oResponse,"_ACHEIRECHEQUEDETALHE","AcheiRechequeDetalhe",{},NIL,.T.,"O",NIL,NIL) 
	nTElem5 := len(oNodes5)
	For nRElem5 := 1 to nTElem5 
		If !WSIsNilNode( oNodes5[nRElem5] )
			aadd(::oWSAcheiRechequeDetalhe , SERASA_AcheiRechequeDetalhe():New() )
			::oWSAcheiRechequeDetalhe[len(::oWSAcheiRechequeDetalhe)]:SoapRecv(oNodes5[nRElem5])
		Endif
	Next
	::cMensagem          :=  WSAdvValue( oResponse,"_MENSAGEM","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ConvemDevedores

WSSTRUCT SERASA_ConvemDevedores
	WSDATA   nTotalOcorrencias         AS int
	WSDATA   cOcorrenciaMaisAntiga     AS string OPTIONAL
	WSDATA   cOcorrenciaMaisRecente    AS string OPTIONAL
	WSDATA   cValorTotalOcorrencias    AS string OPTIONAL
	WSDATA   oWSConvemDevedoresDetalhe AS SERASA_ConvemDevedoreDetalhe OPTIONAL
	WSDATA   cMensagem                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SERASA_ConvemDevedores
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SERASA_ConvemDevedores
	::oWSConvemDevedoresDetalhe := {} // Array Of  SERASA_CONVEMDEVEDOREDETALHE():New()
Return

WSMETHOD CLONE WSCLIENT SERASA_ConvemDevedores
	Local oClone := SERASA_ConvemDevedores():NEW()
	oClone:nTotalOcorrencias    := ::nTotalOcorrencias
	oClone:cOcorrenciaMaisAntiga := ::cOcorrenciaMaisAntiga
	oClone:cOcorrenciaMaisRecente := ::cOcorrenciaMaisRecente
	oClone:cValorTotalOcorrencias := ::cValorTotalOcorrencias
	oClone:oWSConvemDevedoresDetalhe := NIL
	If ::oWSConvemDevedoresDetalhe <> NIL 
		oClone:oWSConvemDevedoresDetalhe := {}
		aEval( ::oWSConvemDevedoresDetalhe , { |x| aadd( oClone:oWSConvemDevedoresDetalhe , x:Clone() ) } )
	Endif 
	oClone:cMensagem            := ::cMensagem
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SERASA_ConvemDevedores
	Local nRElem5, oNodes5, nTElem5
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nTotalOcorrencias  :=  WSAdvValue( oResponse,"_TOTALOCORRENCIAS","int",NIL,"Property nTotalOcorrencias as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cOcorrenciaMaisAntiga :=  WSAdvValue( oResponse,"_OCORRENCIAMAISANTIGA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cOcorrenciaMaisRecente :=  WSAdvValue( oResponse,"_OCORRENCIAMAISRECENTE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cValorTotalOcorrencias :=  WSAdvValue( oResponse,"_VALORTOTALOCORRENCIAS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNodes5 :=  WSAdvValue( oResponse,"_CONVEMDEVEDORESDETALHE","ConvemDevedoreDetalhe",{},NIL,.T.,"O",NIL,NIL) 
	nTElem5 := len(oNodes5)
	For nRElem5 := 1 to nTElem5 
		If !WSIsNilNode( oNodes5[nRElem5] )
			aadd(::oWSConvemDevedoresDetalhe , SERASA_ConvemDevedoreDetalhe():New() )
			::oWSConvemDevedoresDetalhe[len(::oWSConvemDevedoresDetalhe)]:SoapRecv(oNodes5[nRElem5])
		Endif
	Next
	::cMensagem          :=  WSAdvValue( oResponse,"_MENSAGEM","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ParticipacoesFalencias

WSSTRUCT SERASA_ParticipacoesFalencias
	WSDATA   nTotalOcorrencias         AS int
	WSDATA   cOcorrenciaMaisAntiga     AS string OPTIONAL
	WSDATA   cOcorrenciaMaisRecente    AS string OPTIONAL
	WSDATA   cValorTotalOcorrencias    AS string OPTIONAL
	WSDATA   oWSParticipacoesFalenciasDetalhe AS SERASA_ParticipacaoFalenciaDetalhe OPTIONAL
	WSDATA   cMensagem                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SERASA_ParticipacoesFalencias
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SERASA_ParticipacoesFalencias
	::oWSParticipacoesFalenciasDetalhe := {} // Array Of  SERASA_PARTICIPACAOFALENCIADETALHE():New()
Return

WSMETHOD CLONE WSCLIENT SERASA_ParticipacoesFalencias
	Local oClone := SERASA_ParticipacoesFalencias():NEW()
	oClone:nTotalOcorrencias    := ::nTotalOcorrencias
	oClone:cOcorrenciaMaisAntiga := ::cOcorrenciaMaisAntiga
	oClone:cOcorrenciaMaisRecente := ::cOcorrenciaMaisRecente
	oClone:cValorTotalOcorrencias := ::cValorTotalOcorrencias
	oClone:oWSParticipacoesFalenciasDetalhe := NIL
	If ::oWSParticipacoesFalenciasDetalhe <> NIL 
		oClone:oWSParticipacoesFalenciasDetalhe := {}
		aEval( ::oWSParticipacoesFalenciasDetalhe , { |x| aadd( oClone:oWSParticipacoesFalenciasDetalhe , x:Clone() ) } )
	Endif 
	oClone:cMensagem            := ::cMensagem
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SERASA_ParticipacoesFalencias
	Local nRElem5, oNodes5, nTElem5
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nTotalOcorrencias  :=  WSAdvValue( oResponse,"_TOTALOCORRENCIAS","int",NIL,"Property nTotalOcorrencias as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cOcorrenciaMaisAntiga :=  WSAdvValue( oResponse,"_OCORRENCIAMAISANTIGA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cOcorrenciaMaisRecente :=  WSAdvValue( oResponse,"_OCORRENCIAMAISRECENTE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cValorTotalOcorrencias :=  WSAdvValue( oResponse,"_VALORTOTALOCORRENCIAS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNodes5 :=  WSAdvValue( oResponse,"_PARTICIPACOESFALENCIASDETALHE","ParticipacaoFalenciaDetalhe",{},NIL,.T.,"O",NIL,NIL) 
	nTElem5 := len(oNodes5)
	For nRElem5 := 1 to nTElem5 
		If !WSIsNilNode( oNodes5[nRElem5] )
			aadd(::oWSParticipacoesFalenciasDetalhe , SERASA_ParticipacaoFalenciaDetalhe():New() )
			::oWSParticipacoesFalenciasDetalhe[len(::oWSParticipacoesFalenciasDetalhe)]:SoapRecv(oNodes5[nRElem5])
		Endif
	Next
	::cMensagem          :=  WSAdvValue( oResponse,"_MENSAGEM","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure QSA

WSSTRUCT SERASA_QSA
	WSDATA   oWSSocios                 AS SERASA_Socio OPTIONAL
	WSDATA   oWSAdministradores        AS SERASA_Administrador OPTIONAL
	WSDATA   cMensagens                AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SERASA_QSA
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SERASA_QSA
	::oWSSocios            := {} // Array Of  SERASA_SOCIO():New()
	::oWSAdministradores   := {} // Array Of  SERASA_ADMINISTRADOR():New()
	::cMensagens           := {} // Array Of  ""
Return

WSMETHOD CLONE WSCLIENT SERASA_QSA
	Local oClone := SERASA_QSA():NEW()
	oClone:oWSSocios := NIL
	If ::oWSSocios <> NIL 
		oClone:oWSSocios := {}
		aEval( ::oWSSocios , { |x| aadd( oClone:oWSSocios , x:Clone() ) } )
	Endif 
	oClone:oWSAdministradores := NIL
	If ::oWSAdministradores <> NIL 
		oClone:oWSAdministradores := {}
		aEval( ::oWSAdministradores , { |x| aadd( oClone:oWSAdministradores , x:Clone() ) } )
	Endif 
	oClone:cMensagens           := IIf(::cMensagens <> NIL , aClone(::cMensagens) , NIL )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SERASA_QSA
	Local nRElem1, oNodes1, nTElem1
	Local nRElem2, oNodes2, nTElem2
	Local oNodes3 :=  WSAdvValue( oResponse,"_MENSAGENS","string",{},NIL,.T.,"S",NIL,"a") 
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_SOCIOS","Socio",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSSocios , SERASA_Socio():New() )
			::oWSSocios[len(::oWSSocios)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
	oNodes2 :=  WSAdvValue( oResponse,"_ADMINISTRADORES","Administrador",{},NIL,.T.,"O",NIL,NIL) 
	nTElem2 := len(oNodes2)
	For nRElem2 := 1 to nTElem2 
		If !WSIsNilNode( oNodes2[nRElem2] )
			aadd(::oWSAdministradores , SERASA_Administrador():New() )
			::oWSAdministradores[len(::oWSAdministradores)]:SoapRecv(oNodes2[nRElem2])
		Endif
	Next
	aEval(oNodes3 , { |x| aadd(::cMensagens ,  x:TEXT  ) } )
Return

// WSDL Data Structure Participacoes

WSSTRUCT SERASA_Participacoes
	WSDATA   oWSParticipacao           AS SERASA_ArrayOfParticipante OPTIONAL
	WSDATA   oWSParticipacaoSocietaria AS SERASA_ArrayOfParticipado OPTIONAL
	WSDATA   cMensagem                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SERASA_Participacoes
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SERASA_Participacoes
Return

WSMETHOD CLONE WSCLIENT SERASA_Participacoes
	Local oClone := SERASA_Participacoes():NEW()
	oClone:oWSParticipacao      := IIF(::oWSParticipacao = NIL , NIL , ::oWSParticipacao:Clone() )
	oClone:oWSParticipacaoSocietaria := IIF(::oWSParticipacaoSocietaria = NIL , NIL , ::oWSParticipacaoSocietaria:Clone() )
	oClone:cMensagem            := ::cMensagem
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SERASA_Participacoes
	Local oNode1
	Local oNode2
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_PARTICIPACAO","ArrayOfParticipante",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSParticipacao := SERASA_ArrayOfParticipante():New()
		::oWSParticipacao:SoapRecv(oNode1)
	EndIf
	oNode2 :=  WSAdvValue( oResponse,"_PARTICIPACAOSOCIETARIA","ArrayOfParticipado",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode2 != NIL
		::oWSParticipacaoSocietaria := SERASA_ArrayOfParticipado():New()
		::oWSParticipacaoSocietaria:SoapRecv(oNode2)
	EndIf
	::cMensagem          :=  WSAdvValue( oResponse,"_MENSAGEM","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure RiskScore

WSSTRUCT SERASA_RiskScore
	WSDATA   oWSPessoaFisica           AS SERASA_PessoaFisicaScore OPTIONAL
	WSDATA   oWSPessoaJuridica         AS SERASA_PessoaJuridicaScore OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SERASA_RiskScore
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SERASA_RiskScore
Return

WSMETHOD CLONE WSCLIENT SERASA_RiskScore
	Local oClone := SERASA_RiskScore():NEW()
	oClone:oWSPessoaFisica      := IIF(::oWSPessoaFisica = NIL , NIL , ::oWSPessoaFisica:Clone() )
	oClone:oWSPessoaJuridica    := IIF(::oWSPessoaJuridica = NIL , NIL , ::oWSPessoaJuridica:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SERASA_RiskScore
	Local oNode1
	Local oNode2
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_PESSOAFISICA","PessoaFisicaScore",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSPessoaFisica := SERASA_PessoaFisicaScore():New()
		::oWSPessoaFisica:SoapRecv(oNode1)
	EndIf
	oNode2 :=  WSAdvValue( oResponse,"_PESSOAJURIDICA","PessoaJuridicaScore",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode2 != NIL
		::oWSPessoaJuridica := SERASA_PessoaJuridicaScore():New()
		::oWSPessoaJuridica:SoapRecv(oNode2)
	EndIf
Return

// WSDL Data Structure Transacao

WSSTRUCT SERASA_Transacao
	WSDATA   lStatus                   AS boolean
	WSDATA   cCodigoStatus             AS string OPTIONAL
	WSDATA   cCodigoStatusDescricao    AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SERASA_Transacao
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SERASA_Transacao
Return

WSMETHOD CLONE WSCLIENT SERASA_Transacao
	Local oClone := SERASA_Transacao():NEW()
	oClone:lStatus              := ::lStatus
	oClone:cCodigoStatus        := ::cCodigoStatus
	oClone:cCodigoStatusDescricao := ::cCodigoStatusDescricao
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SERASA_Transacao
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::lStatus            :=  WSAdvValue( oResponse,"_STATUS","boolean",NIL,"Property lStatus as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::cCodigoStatus      :=  WSAdvValue( oResponse,"_CODIGOSTATUS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCodigoStatusDescricao :=  WSAdvValue( oResponse,"_CODIGOSTATUSDESCRICAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure TelefonesContato

WSSTRUCT SERASA_TelefonesContato
	WSDATA   cTelefone                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SERASA_TelefonesContato
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SERASA_TelefonesContato
Return

WSMETHOD CLONE WSCLIENT SERASA_TelefonesContato
	Local oClone := SERASA_TelefonesContato():NEW()
	oClone:cTelefone            := ::cTelefone
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SERASA_TelefonesContato
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cTelefone          :=  WSAdvValue( oResponse,"_TELEFONE","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure PendenciasInternasDetalhe

WSSTRUCT SERASA_PendenciasInternasDetalhe
	WSDATA   cDataOcorrencia           AS string OPTIONAL
	WSDATA   cModalidade               AS string OPTIONAL
	WSDATA   cAvalista                 AS string OPTIONAL
	WSDATA   cTipoMoeda                AS string OPTIONAL
	WSDATA   cValor                    AS string OPTIONAL
	WSDATA   cContrato                 AS string OPTIONAL
	WSDATA   cOrigem                   AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SERASA_PendenciasInternasDetalhe
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SERASA_PendenciasInternasDetalhe
Return

WSMETHOD CLONE WSCLIENT SERASA_PendenciasInternasDetalhe
	Local oClone := SERASA_PendenciasInternasDetalhe():NEW()
	oClone:cDataOcorrencia      := ::cDataOcorrencia
	oClone:cModalidade          := ::cModalidade
	oClone:cAvalista            := ::cAvalista
	oClone:cTipoMoeda           := ::cTipoMoeda
	oClone:cValor               := ::cValor
	oClone:cContrato            := ::cContrato
	oClone:cOrigem              := ::cOrigem
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SERASA_PendenciasInternasDetalhe
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cDataOcorrencia    :=  WSAdvValue( oResponse,"_DATAOCORRENCIA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cModalidade        :=  WSAdvValue( oResponse,"_MODALIDADE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cAvalista          :=  WSAdvValue( oResponse,"_AVALISTA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTipoMoeda         :=  WSAdvValue( oResponse,"_TIPOMOEDA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cValor             :=  WSAdvValue( oResponse,"_VALOR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cContrato          :=  WSAdvValue( oResponse,"_CONTRATO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cOrigem            :=  WSAdvValue( oResponse,"_ORIGEM","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure RestricaoFinanceiraDetalhe

WSSTRUCT SERASA_RestricaoFinanceiraDetalhe
	WSDATA   cDocumentoCredor          AS string OPTIONAL
	WSDATA   cNomeCredor               AS string OPTIONAL
	WSDATA   cDataOcorrencia           AS string OPTIONAL
	WSDATA   cNatureza                 AS string OPTIONAL
	WSDATA   cNaturezaDescricao        AS string OPTIONAL
	WSDATA   cPraca                    AS string OPTIONAL
	WSDATA   cCidade                   AS string OPTIONAL
	WSDATA   cUF                       AS string OPTIONAL
	WSDATA   cPrincipal                AS string OPTIONAL
	WSDATA   cDataHoraInclusao         AS string OPTIONAL
	WSDATA   cModalidade               AS string OPTIONAL
	WSDATA   cModalidadeDescricao      AS string OPTIONAL
	WSDATA   cDistribuidor             AS string OPTIONAL
	WSDATA   cVara                     AS string OPTIONAL
	WSDATA   cProcesso                 AS string OPTIONAL
	WSDATA   cValor                    AS string OPTIONAL
	WSDATA   cContrato                 AS string OPTIONAL
	WSDATA   cOrigem                   AS string OPTIONAL
	WSDATA   cSigla                    AS string OPTIONAL
	WSDATA   cSubJudice                AS string OPTIONAL
	WSDATA   cSubJudiceDescricao       AS string OPTIONAL
	WSDATA   cDataSubJudice            AS string OPTIONAL
	WSDATA   cTipoAnotacao             AS string OPTIONAL
	WSDATA   cTipoAnotacaoDescricao    AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SERASA_RestricaoFinanceiraDetalhe
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SERASA_RestricaoFinanceiraDetalhe
Return

WSMETHOD CLONE WSCLIENT SERASA_RestricaoFinanceiraDetalhe
	Local oClone := SERASA_RestricaoFinanceiraDetalhe():NEW()
	oClone:cDocumentoCredor     := ::cDocumentoCredor
	oClone:cNomeCredor          := ::cNomeCredor
	oClone:cDataOcorrencia      := ::cDataOcorrencia
	oClone:cNatureza            := ::cNatureza
	oClone:cNaturezaDescricao   := ::cNaturezaDescricao
	oClone:cPraca               := ::cPraca
	oClone:cCidade              := ::cCidade
	oClone:cUF                  := ::cUF
	oClone:cPrincipal           := ::cPrincipal
	oClone:cDataHoraInclusao    := ::cDataHoraInclusao
	oClone:cModalidade          := ::cModalidade
	oClone:cModalidadeDescricao := ::cModalidadeDescricao
	oClone:cDistribuidor        := ::cDistribuidor
	oClone:cVara                := ::cVara
	oClone:cProcesso            := ::cProcesso
	oClone:cValor               := ::cValor
	oClone:cContrato            := ::cContrato
	oClone:cOrigem              := ::cOrigem
	oClone:cSigla               := ::cSigla
	oClone:cSubJudice           := ::cSubJudice
	oClone:cSubJudiceDescricao  := ::cSubJudiceDescricao
	oClone:cDataSubJudice       := ::cDataSubJudice
	oClone:cTipoAnotacao        := ::cTipoAnotacao
	oClone:cTipoAnotacaoDescricao := ::cTipoAnotacaoDescricao
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SERASA_RestricaoFinanceiraDetalhe
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cDocumentoCredor   :=  WSAdvValue( oResponse,"_DOCUMENTOCREDOR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNomeCredor        :=  WSAdvValue( oResponse,"_NOMECREDOR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDataOcorrencia    :=  WSAdvValue( oResponse,"_DATAOCORRENCIA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNatureza          :=  WSAdvValue( oResponse,"_NATUREZA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNaturezaDescricao :=  WSAdvValue( oResponse,"_NATUREZADESCRICAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cPraca             :=  WSAdvValue( oResponse,"_PRACA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCidade            :=  WSAdvValue( oResponse,"_CIDADE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cUF                :=  WSAdvValue( oResponse,"_UF","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cPrincipal         :=  WSAdvValue( oResponse,"_PRINCIPAL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDataHoraInclusao  :=  WSAdvValue( oResponse,"_DATAHORAINCLUSAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cModalidade        :=  WSAdvValue( oResponse,"_MODALIDADE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cModalidadeDescricao :=  WSAdvValue( oResponse,"_MODALIDADEDESCRICAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDistribuidor      :=  WSAdvValue( oResponse,"_DISTRIBUIDOR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cVara              :=  WSAdvValue( oResponse,"_VARA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cProcesso          :=  WSAdvValue( oResponse,"_PROCESSO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cValor             :=  WSAdvValue( oResponse,"_VALOR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cContrato          :=  WSAdvValue( oResponse,"_CONTRATO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cOrigem            :=  WSAdvValue( oResponse,"_ORIGEM","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSigla             :=  WSAdvValue( oResponse,"_SIGLA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSubJudice         :=  WSAdvValue( oResponse,"_SUBJUDICE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSubJudiceDescricao :=  WSAdvValue( oResponse,"_SUBJUDICEDESCRICAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDataSubJudice     :=  WSAdvValue( oResponse,"_DATASUBJUDICE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTipoAnotacao      :=  WSAdvValue( oResponse,"_TIPOANOTACAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTipoAnotacaoDescricao :=  WSAdvValue( oResponse,"_TIPOANOTACAODESCRICAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure PendenciasFinanceirasDetalhe

WSSTRUCT SERASA_PendenciasFinanceirasDetalhe
	WSDATA   cDocumentoCredor          AS string OPTIONAL
	WSDATA   cNomeCredor               AS string OPTIONAL
	WSDATA   cDataOcorrencia           AS string OPTIONAL
	WSDATA   cNatureza                 AS string OPTIONAL
	WSDATA   cNaturezaDescricao        AS string OPTIONAL
	WSDATA   cPraca                    AS string OPTIONAL
	WSDATA   cPrincipal                AS string OPTIONAL
	WSDATA   cDataHoraInclusao         AS string OPTIONAL
	WSDATA   cModalidade               AS string OPTIONAL
	WSDATA   cModalidadeDescricao      AS string OPTIONAL
	WSDATA   cDistribuidor             AS string OPTIONAL
	WSDATA   cVara                     AS string OPTIONAL
	WSDATA   cProcesso                 AS string OPTIONAL
	WSDATA   cValor                    AS string OPTIONAL
	WSDATA   cContrato                 AS string OPTIONAL
	WSDATA   cOrigem                   AS string OPTIONAL
	WSDATA   cSigla                    AS string OPTIONAL
	WSDATA   cSubJudice                AS string OPTIONAL
	WSDATA   cSubJudiceDescricao       AS string OPTIONAL
	WSDATA   cDataSubJudice            AS string OPTIONAL
	WSDATA   cTipoAnotacao             AS string OPTIONAL
	WSDATA   cTipoAnotacaoDescricao    AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SERASA_PendenciasFinanceirasDetalhe
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SERASA_PendenciasFinanceirasDetalhe
Return

WSMETHOD CLONE WSCLIENT SERASA_PendenciasFinanceirasDetalhe
	Local oClone := SERASA_PendenciasFinanceirasDetalhe():NEW()
	oClone:cDocumentoCredor     := ::cDocumentoCredor
	oClone:cNomeCredor          := ::cNomeCredor
	oClone:cDataOcorrencia      := ::cDataOcorrencia
	oClone:cNatureza            := ::cNatureza
	oClone:cNaturezaDescricao   := ::cNaturezaDescricao
	oClone:cPraca               := ::cPraca
	oClone:cPrincipal           := ::cPrincipal
	oClone:cDataHoraInclusao    := ::cDataHoraInclusao
	oClone:cModalidade          := ::cModalidade
	oClone:cModalidadeDescricao := ::cModalidadeDescricao
	oClone:cDistribuidor        := ::cDistribuidor
	oClone:cVara                := ::cVara
	oClone:cProcesso            := ::cProcesso
	oClone:cValor               := ::cValor
	oClone:cContrato            := ::cContrato
	oClone:cOrigem              := ::cOrigem
	oClone:cSigla               := ::cSigla
	oClone:cSubJudice           := ::cSubJudice
	oClone:cSubJudiceDescricao  := ::cSubJudiceDescricao
	oClone:cDataSubJudice       := ::cDataSubJudice
	oClone:cTipoAnotacao        := ::cTipoAnotacao
	oClone:cTipoAnotacaoDescricao := ::cTipoAnotacaoDescricao
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SERASA_PendenciasFinanceirasDetalhe
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cDocumentoCredor   :=  WSAdvValue( oResponse,"_DOCUMENTOCREDOR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNomeCredor        :=  WSAdvValue( oResponse,"_NOMECREDOR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDataOcorrencia    :=  WSAdvValue( oResponse,"_DATAOCORRENCIA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNatureza          :=  WSAdvValue( oResponse,"_NATUREZA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNaturezaDescricao :=  WSAdvValue( oResponse,"_NATUREZADESCRICAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cPraca             :=  WSAdvValue( oResponse,"_PRACA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cPrincipal         :=  WSAdvValue( oResponse,"_PRINCIPAL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDataHoraInclusao  :=  WSAdvValue( oResponse,"_DATAHORAINCLUSAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cModalidade        :=  WSAdvValue( oResponse,"_MODALIDADE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cModalidadeDescricao :=  WSAdvValue( oResponse,"_MODALIDADEDESCRICAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDistribuidor      :=  WSAdvValue( oResponse,"_DISTRIBUIDOR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cVara              :=  WSAdvValue( oResponse,"_VARA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cProcesso          :=  WSAdvValue( oResponse,"_PROCESSO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cValor             :=  WSAdvValue( oResponse,"_VALOR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cContrato          :=  WSAdvValue( oResponse,"_CONTRATO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cOrigem            :=  WSAdvValue( oResponse,"_ORIGEM","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSigla             :=  WSAdvValue( oResponse,"_SIGLA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSubJudice         :=  WSAdvValue( oResponse,"_SUBJUDICE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSubJudiceDescricao :=  WSAdvValue( oResponse,"_SUBJUDICEDESCRICAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDataSubJudice     :=  WSAdvValue( oResponse,"_DATASUBJUDICE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTipoAnotacao      :=  WSAdvValue( oResponse,"_TIPOANOTACAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTipoAnotacaoDescricao :=  WSAdvValue( oResponse,"_TIPOANOTACAODESCRICAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure PendenciaBacenDetalhe

WSSTRUCT SERASA_PendenciaBacenDetalhe
	WSDATA   cDataOcorrencia           AS string OPTIONAL
	WSDATA   cBanco                    AS string OPTIONAL
	WSDATA   cAgencia                  AS string OPTIONAL
	WSDATA   cQuantidadeCCFBanco       AS string OPTIONAL
	WSDATA   cPraca                    AS string OPTIONAL
	WSDATA   cNomeBanco                AS string OPTIONAL
	WSDATA   cCidade                   AS string OPTIONAL
	WSDATA   cNatureza                 AS string OPTIONAL
	WSDATA   cNaturezaDescricao        AS string OPTIONAL
	WSDATA   cDataHoraInclusao         AS string OPTIONAL
	WSDATA   cEstado                   AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SERASA_PendenciaBacenDetalhe
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SERASA_PendenciaBacenDetalhe
Return

WSMETHOD CLONE WSCLIENT SERASA_PendenciaBacenDetalhe
	Local oClone := SERASA_PendenciaBacenDetalhe():NEW()
	oClone:cDataOcorrencia      := ::cDataOcorrencia
	oClone:cBanco               := ::cBanco
	oClone:cAgencia             := ::cAgencia
	oClone:cQuantidadeCCFBanco  := ::cQuantidadeCCFBanco
	oClone:cPraca               := ::cPraca
	oClone:cNomeBanco           := ::cNomeBanco
	oClone:cCidade              := ::cCidade
	oClone:cNatureza            := ::cNatureza
	oClone:cNaturezaDescricao   := ::cNaturezaDescricao
	oClone:cDataHoraInclusao    := ::cDataHoraInclusao
	oClone:cEstado              := ::cEstado
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SERASA_PendenciaBacenDetalhe
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cDataOcorrencia    :=  WSAdvValue( oResponse,"_DATAOCORRENCIA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cBanco             :=  WSAdvValue( oResponse,"_BANCO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cAgencia           :=  WSAdvValue( oResponse,"_AGENCIA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cQuantidadeCCFBanco :=  WSAdvValue( oResponse,"_QUANTIDADECCFBANCO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cPraca             :=  WSAdvValue( oResponse,"_PRACA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNomeBanco         :=  WSAdvValue( oResponse,"_NOMEBANCO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCidade            :=  WSAdvValue( oResponse,"_CIDADE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNatureza          :=  WSAdvValue( oResponse,"_NATUREZA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNaturezaDescricao :=  WSAdvValue( oResponse,"_NATUREZADESCRICAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDataHoraInclusao  :=  WSAdvValue( oResponse,"_DATAHORAINCLUSAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cEstado            :=  WSAdvValue( oResponse,"_ESTADO","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ProtestoDetalhe

WSSTRUCT SERASA_ProtestoDetalhe
	WSDATA   cDataOcorrencia           AS string OPTIONAL
	WSDATA   cCartorio                 AS string OPTIONAL
	WSDATA   cNatureza                 AS string OPTIONAL
	WSDATA   cValor                    AS string OPTIONAL
	WSDATA   cPraca                    AS string OPTIONAL
	WSDATA   cCidade                   AS string OPTIONAL
	WSDATA   cEstado                   AS string OPTIONAL
	WSDATA   cSubJudice                AS string OPTIONAL
	WSDATA   cSubJudiceDescricao       AS string OPTIONAL
	WSDATA   cDataCarta                AS string OPTIONAL
	WSDATA   cDataHoraInclusao         AS string OPTIONAL
	WSDATA   cDistribuidor             AS string OPTIONAL
	WSDATA   cVara                     AS string OPTIONAL
	WSDATA   cProcesso                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SERASA_ProtestoDetalhe
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SERASA_ProtestoDetalhe
Return

WSMETHOD CLONE WSCLIENT SERASA_ProtestoDetalhe
	Local oClone := SERASA_ProtestoDetalhe():NEW()
	oClone:cDataOcorrencia      := ::cDataOcorrencia
	oClone:cCartorio            := ::cCartorio
	oClone:cNatureza            := ::cNatureza
	oClone:cValor               := ::cValor
	oClone:cPraca               := ::cPraca
	oClone:cCidade              := ::cCidade
	oClone:cEstado              := ::cEstado
	oClone:cSubJudice           := ::cSubJudice
	oClone:cSubJudiceDescricao  := ::cSubJudiceDescricao
	oClone:cDataCarta           := ::cDataCarta
	oClone:cDataHoraInclusao    := ::cDataHoraInclusao
	oClone:cDistribuidor        := ::cDistribuidor
	oClone:cVara                := ::cVara
	oClone:cProcesso            := ::cProcesso
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SERASA_ProtestoDetalhe
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cDataOcorrencia    :=  WSAdvValue( oResponse,"_DATAOCORRENCIA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCartorio          :=  WSAdvValue( oResponse,"_CARTORIO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNatureza          :=  WSAdvValue( oResponse,"_NATUREZA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cValor             :=  WSAdvValue( oResponse,"_VALOR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cPraca             :=  WSAdvValue( oResponse,"_PRACA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCidade            :=  WSAdvValue( oResponse,"_CIDADE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cEstado            :=  WSAdvValue( oResponse,"_ESTADO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSubJudice         :=  WSAdvValue( oResponse,"_SUBJUDICE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSubJudiceDescricao :=  WSAdvValue( oResponse,"_SUBJUDICEDESCRICAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDataCarta         :=  WSAdvValue( oResponse,"_DATACARTA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDataHoraInclusao  :=  WSAdvValue( oResponse,"_DATAHORAINCLUSAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDistribuidor      :=  WSAdvValue( oResponse,"_DISTRIBUIDOR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cVara              :=  WSAdvValue( oResponse,"_VARA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cProcesso          :=  WSAdvValue( oResponse,"_PROCESSO","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure AcaoJudiciailDetalhe

WSSTRUCT SERASA_AcaoJudiciailDetalhe
	WSDATA   cDataOcorrencia           AS string OPTIONAL
	WSDATA   cVaraCivil                AS string OPTIONAL
	WSDATA   cDistribuidor             AS string OPTIONAL
	WSDATA   cNatureza                 AS string OPTIONAL
	WSDATA   cValor                    AS string OPTIONAL
	WSDATA   cPraca                    AS string OPTIONAL
	WSDATA   cCidade                   AS string OPTIONAL
	WSDATA   cEstado                   AS string OPTIONAL
	WSDATA   cPrincipal                AS string OPTIONAL
	WSDATA   cSubJudice                AS string OPTIONAL
	WSDATA   cSubJudiceDescricao       AS string OPTIONAL
	WSDATA   cDataHoraInclusao         AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SERASA_AcaoJudiciailDetalhe
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SERASA_AcaoJudiciailDetalhe
Return

WSMETHOD CLONE WSCLIENT SERASA_AcaoJudiciailDetalhe
	Local oClone := SERASA_AcaoJudiciailDetalhe():NEW()
	oClone:cDataOcorrencia      := ::cDataOcorrencia
	oClone:cVaraCivil           := ::cVaraCivil
	oClone:cDistribuidor        := ::cDistribuidor
	oClone:cNatureza            := ::cNatureza
	oClone:cValor               := ::cValor
	oClone:cPraca               := ::cPraca
	oClone:cCidade              := ::cCidade
	oClone:cEstado              := ::cEstado
	oClone:cPrincipal           := ::cPrincipal
	oClone:cSubJudice           := ::cSubJudice
	oClone:cSubJudiceDescricao  := ::cSubJudiceDescricao
	oClone:cDataHoraInclusao    := ::cDataHoraInclusao
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SERASA_AcaoJudiciailDetalhe
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cDataOcorrencia    :=  WSAdvValue( oResponse,"_DATAOCORRENCIA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cVaraCivil         :=  WSAdvValue( oResponse,"_VARACIVIL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDistribuidor      :=  WSAdvValue( oResponse,"_DISTRIBUIDOR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNatureza          :=  WSAdvValue( oResponse,"_NATUREZA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cValor             :=  WSAdvValue( oResponse,"_VALOR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cPraca             :=  WSAdvValue( oResponse,"_PRACA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCidade            :=  WSAdvValue( oResponse,"_CIDADE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cEstado            :=  WSAdvValue( oResponse,"_ESTADO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cPrincipal         :=  WSAdvValue( oResponse,"_PRINCIPAL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSubJudice         :=  WSAdvValue( oResponse,"_SUBJUDICE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSubJudiceDescricao :=  WSAdvValue( oResponse,"_SUBJUDICEDESCRICAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDataHoraInclusao  :=  WSAdvValue( oResponse,"_DATAHORAINCLUSAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure AcheiRechequeDetalhe

WSSTRUCT SERASA_AcheiRechequeDetalhe
	WSDATA   cDataOcorrencia           AS string OPTIONAL
	WSDATA   cBanco                    AS string OPTIONAL
	WSDATA   cAgencia                  AS string OPTIONAL
	WSDATA   cContaCorrente            AS string OPTIONAL
	WSDATA   cNatureza                 AS string OPTIONAL
	WSDATA   cValor                    AS string OPTIONAL
	WSDATA   cPraca                    AS string OPTIONAL
	WSDATA   cCidade                   AS string OPTIONAL
	WSDATA   cEstado                   AS string OPTIONAL
	WSDATA   cNomeBanco                AS string OPTIONAL
	WSDATA   cNumeroCheque             AS string OPTIONAL
	WSDATA   cDataHoraInclusao         AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SERASA_AcheiRechequeDetalhe
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SERASA_AcheiRechequeDetalhe
Return

WSMETHOD CLONE WSCLIENT SERASA_AcheiRechequeDetalhe
	Local oClone := SERASA_AcheiRechequeDetalhe():NEW()
	oClone:cDataOcorrencia      := ::cDataOcorrencia
	oClone:cBanco               := ::cBanco
	oClone:cAgencia             := ::cAgencia
	oClone:cContaCorrente       := ::cContaCorrente
	oClone:cNatureza            := ::cNatureza
	oClone:cValor               := ::cValor
	oClone:cPraca               := ::cPraca
	oClone:cCidade              := ::cCidade
	oClone:cEstado              := ::cEstado
	oClone:cNomeBanco           := ::cNomeBanco
	oClone:cNumeroCheque        := ::cNumeroCheque
	oClone:cDataHoraInclusao    := ::cDataHoraInclusao
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SERASA_AcheiRechequeDetalhe
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cDataOcorrencia    :=  WSAdvValue( oResponse,"_DATAOCORRENCIA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cBanco             :=  WSAdvValue( oResponse,"_BANCO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cAgencia           :=  WSAdvValue( oResponse,"_AGENCIA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cContaCorrente     :=  WSAdvValue( oResponse,"_CONTACORRENTE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNatureza          :=  WSAdvValue( oResponse,"_NATUREZA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cValor             :=  WSAdvValue( oResponse,"_VALOR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cPraca             :=  WSAdvValue( oResponse,"_PRACA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCidade            :=  WSAdvValue( oResponse,"_CIDADE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cEstado            :=  WSAdvValue( oResponse,"_ESTADO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNomeBanco         :=  WSAdvValue( oResponse,"_NOMEBANCO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNumeroCheque      :=  WSAdvValue( oResponse,"_NUMEROCHEQUE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDataHoraInclusao  :=  WSAdvValue( oResponse,"_DATAHORAINCLUSAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ConvemDevedoreDetalhe

WSSTRUCT SERASA_ConvemDevedoreDetalhe
	WSDATA   cDataOcorrencia           AS string OPTIONAL
	WSDATA   cNatureza                 AS string OPTIONAL
	WSDATA   cNaturezaDescricao        AS string OPTIONAL
	WSDATA   cValor                    AS string OPTIONAL
	WSDATA   cPraca                    AS string OPTIONAL
	WSDATA   cEstado                   AS string OPTIONAL
	WSDATA   cNomeCredor               AS string OPTIONAL
	WSDATA   cContrato                 AS string OPTIONAL
	WSDATA   cDocumentoCredor          AS string OPTIONAL
	WSDATA   cPrincipal                AS string OPTIONAL
	WSDATA   cDataHoraInclusao         AS string OPTIONAL
	WSDATA   cMensagemSubJudice        AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SERASA_ConvemDevedoreDetalhe
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SERASA_ConvemDevedoreDetalhe
Return

WSMETHOD CLONE WSCLIENT SERASA_ConvemDevedoreDetalhe
	Local oClone := SERASA_ConvemDevedoreDetalhe():NEW()
	oClone:cDataOcorrencia      := ::cDataOcorrencia
	oClone:cNatureza            := ::cNatureza
	oClone:cNaturezaDescricao   := ::cNaturezaDescricao
	oClone:cValor               := ::cValor
	oClone:cPraca               := ::cPraca
	oClone:cEstado              := ::cEstado
	oClone:cNomeCredor          := ::cNomeCredor
	oClone:cContrato            := ::cContrato
	oClone:cDocumentoCredor     := ::cDocumentoCredor
	oClone:cPrincipal           := ::cPrincipal
	oClone:cDataHoraInclusao    := ::cDataHoraInclusao
	oClone:cMensagemSubJudice   := ::cMensagemSubJudice
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SERASA_ConvemDevedoreDetalhe
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cDataOcorrencia    :=  WSAdvValue( oResponse,"_DATAOCORRENCIA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNatureza          :=  WSAdvValue( oResponse,"_NATUREZA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNaturezaDescricao :=  WSAdvValue( oResponse,"_NATUREZADESCRICAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cValor             :=  WSAdvValue( oResponse,"_VALOR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cPraca             :=  WSAdvValue( oResponse,"_PRACA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cEstado            :=  WSAdvValue( oResponse,"_ESTADO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNomeCredor        :=  WSAdvValue( oResponse,"_NOMECREDOR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cContrato          :=  WSAdvValue( oResponse,"_CONTRATO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDocumentoCredor   :=  WSAdvValue( oResponse,"_DOCUMENTOCREDOR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cPrincipal         :=  WSAdvValue( oResponse,"_PRINCIPAL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDataHoraInclusao  :=  WSAdvValue( oResponse,"_DATAHORAINCLUSAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cMensagemSubJudice :=  WSAdvValue( oResponse,"_MENSAGEMSUBJUDICE","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ParticipacaoFalenciaDetalhe

WSSTRUCT SERASA_ParticipacaoFalenciaDetalhe
	WSDATA   cDataOcorrencia           AS string OPTIONAL
	WSDATA   cNatureza                 AS string OPTIONAL
	WSDATA   cNaturezaDescricao        AS string OPTIONAL
	WSDATA   cQualificacao             AS string OPTIONAL
	WSDATA   cVaraCivil                AS string OPTIONAL
	WSDATA   cDocumentoCredor          AS string OPTIONAL
	WSDATA   cNomeCredor               AS string OPTIONAL
	WSDATA   cDataHoraInclusao         AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SERASA_ParticipacaoFalenciaDetalhe
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SERASA_ParticipacaoFalenciaDetalhe
Return

WSMETHOD CLONE WSCLIENT SERASA_ParticipacaoFalenciaDetalhe
	Local oClone := SERASA_ParticipacaoFalenciaDetalhe():NEW()
	oClone:cDataOcorrencia      := ::cDataOcorrencia
	oClone:cNatureza            := ::cNatureza
	oClone:cNaturezaDescricao   := ::cNaturezaDescricao
	oClone:cQualificacao        := ::cQualificacao
	oClone:cVaraCivil           := ::cVaraCivil
	oClone:cDocumentoCredor     := ::cDocumentoCredor
	oClone:cNomeCredor          := ::cNomeCredor
	oClone:cDataHoraInclusao    := ::cDataHoraInclusao
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SERASA_ParticipacaoFalenciaDetalhe
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cDataOcorrencia    :=  WSAdvValue( oResponse,"_DATAOCORRENCIA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNatureza          :=  WSAdvValue( oResponse,"_NATUREZA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNaturezaDescricao :=  WSAdvValue( oResponse,"_NATUREZADESCRICAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cQualificacao      :=  WSAdvValue( oResponse,"_QUALIFICACAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cVaraCivil         :=  WSAdvValue( oResponse,"_VARACIVIL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDocumentoCredor   :=  WSAdvValue( oResponse,"_DOCUMENTOCREDOR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNomeCredor        :=  WSAdvValue( oResponse,"_NOMECREDOR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDataHoraInclusao  :=  WSAdvValue( oResponse,"_DATAHORAINCLUSAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure Socio

WSSTRUCT SERASA_Socio
	WSDATA   oWSPessoa                 AS SERASA_TipoSocio
	WSDATA   cDocumento                AS string OPTIONAL
	WSDATA   cNome                     AS string OPTIONAL
	WSDATA   cCapital                  AS string OPTIONAL
	WSDATA   cRestricoes               AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SERASA_Socio
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SERASA_Socio
Return

WSMETHOD CLONE WSCLIENT SERASA_Socio
	Local oClone := SERASA_Socio():NEW()
	oClone:oWSPessoa            := IIF(::oWSPessoa = NIL , NIL , ::oWSPessoa:Clone() )
	oClone:cDocumento           := ::cDocumento
	oClone:cNome                := ::cNome
	oClone:cCapital             := ::cCapital
	oClone:cRestricoes          := ::cRestricoes
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SERASA_Socio
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_PESSOA","TipoSocio",NIL,"Property oWSPessoa as tns:TipoSocio on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSPessoa := SERASA_TipoSocio():New()
		::oWSPessoa:SoapRecv(oNode1)
	EndIf
	::cDocumento         :=  WSAdvValue( oResponse,"_DOCUMENTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNome              :=  WSAdvValue( oResponse,"_NOME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCapital           :=  WSAdvValue( oResponse,"_CAPITAL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cRestricoes        :=  WSAdvValue( oResponse,"_RESTRICOES","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure Administrador

WSSTRUCT SERASA_Administrador
	WSDATA   oWSPessoa                 AS SERASA_TipoAdministrador
	WSDATA   cDocumento                AS string OPTIONAL
	WSDATA   cNome                     AS string OPTIONAL
	WSDATA   cCargo                    AS string OPTIONAL
	WSDATA   cRestricoes               AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SERASA_Administrador
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SERASA_Administrador
Return

WSMETHOD CLONE WSCLIENT SERASA_Administrador
	Local oClone := SERASA_Administrador():NEW()
	oClone:oWSPessoa            := IIF(::oWSPessoa = NIL , NIL , ::oWSPessoa:Clone() )
	oClone:cDocumento           := ::cDocumento
	oClone:cNome                := ::cNome
	oClone:cCargo               := ::cCargo
	oClone:cRestricoes          := ::cRestricoes
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SERASA_Administrador
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_PESSOA","TipoAdministrador",NIL,"Property oWSPessoa as tns:TipoAdministrador on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSPessoa := SERASA_TipoAdministrador():New()
		::oWSPessoa:SoapRecv(oNode1)
	EndIf
	::cDocumento         :=  WSAdvValue( oResponse,"_DOCUMENTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNome              :=  WSAdvValue( oResponse,"_NOME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCargo             :=  WSAdvValue( oResponse,"_CARGO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cRestricoes        :=  WSAdvValue( oResponse,"_RESTRICOES","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ArrayOfParticipante

WSSTRUCT SERASA_ArrayOfParticipante
	WSDATA   oWSParticipante           AS SERASA_Participante OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SERASA_ArrayOfParticipante
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SERASA_ArrayOfParticipante
	::oWSParticipante      := {} // Array Of  SERASA_PARTICIPANTE():New()
Return

WSMETHOD CLONE WSCLIENT SERASA_ArrayOfParticipante
	Local oClone := SERASA_ArrayOfParticipante():NEW()
	oClone:oWSParticipante := NIL
	If ::oWSParticipante <> NIL 
		oClone:oWSParticipante := {}
		aEval( ::oWSParticipante , { |x| aadd( oClone:oWSParticipante , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SERASA_ArrayOfParticipante
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_PARTICIPANTE","Participante",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSParticipante , SERASA_Participante():New() )
			::oWSParticipante[len(::oWSParticipante)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfParticipado

WSSTRUCT SERASA_ArrayOfParticipado
	WSDATA   oWSParticipado            AS SERASA_Participado OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SERASA_ArrayOfParticipado
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SERASA_ArrayOfParticipado
	::oWSParticipado       := {} // Array Of  SERASA_PARTICIPADO():New()
Return

WSMETHOD CLONE WSCLIENT SERASA_ArrayOfParticipado
	Local oClone := SERASA_ArrayOfParticipado():NEW()
	oClone:oWSParticipado := NIL
	If ::oWSParticipado <> NIL 
		oClone:oWSParticipado := {}
		aEval( ::oWSParticipado , { |x| aadd( oClone:oWSParticipado , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SERASA_ArrayOfParticipado
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_PARTICIPADO","Participado",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSParticipado , SERASA_Participado():New() )
			::oWSParticipado[len(::oWSParticipado)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure PessoaFisicaScore

WSSTRUCT SERASA_PessoaFisicaScore
	WSDATA   cModelo                   AS string OPTIONAL
	WSDATA   cCalculado                AS string OPTIONAL
	WSDATA   cPontuacao                AS string OPTIONAL
	WSDATA   cClasse                   AS string OPTIONAL
	WSDATA   nPercentualInadimplentes  AS int
	WSDATA   nPercentualRisco          AS decimal
	WSDATA   cDescricao                AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SERASA_PessoaFisicaScore
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SERASA_PessoaFisicaScore
Return

WSMETHOD CLONE WSCLIENT SERASA_PessoaFisicaScore
	Local oClone := SERASA_PessoaFisicaScore():NEW()
	oClone:cModelo              := ::cModelo
	oClone:cCalculado           := ::cCalculado
	oClone:cPontuacao           := ::cPontuacao
	oClone:cClasse              := ::cClasse
	oClone:nPercentualInadimplentes := ::nPercentualInadimplentes
	oClone:nPercentualRisco     := ::nPercentualRisco
	oClone:cDescricao           := ::cDescricao
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SERASA_PessoaFisicaScore
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cModelo            :=  WSAdvValue( oResponse,"_MODELO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCalculado         :=  WSAdvValue( oResponse,"_CALCULADO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cPontuacao         :=  WSAdvValue( oResponse,"_PONTUACAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cClasse            :=  WSAdvValue( oResponse,"_CLASSE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nPercentualInadimplentes :=  WSAdvValue( oResponse,"_PERCENTUALINADIMPLENTES","int",NIL,"Property nPercentualInadimplentes as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nPercentualRisco   :=  WSAdvValue( oResponse,"_PERCENTUALRISCO","decimal",NIL,"Property nPercentualRisco as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cDescricao         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure PessoaJuridicaScore

WSSTRUCT SERASA_PessoaJuridicaScore
	WSDATA   cModelo                   AS string OPTIONAL
	WSDATA   cCalculado                AS string OPTIONAL
	WSDATA   cPontuacao                AS string OPTIONAL
	WSDATA   cClasse                   AS string OPTIONAL
	WSDATA   nPercentualInadimplentes  AS int
	WSDATA   nPercentualRisco          AS decimal
	WSDATA   cDescricao                AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SERASA_PessoaJuridicaScore
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SERASA_PessoaJuridicaScore
Return

WSMETHOD CLONE WSCLIENT SERASA_PessoaJuridicaScore
	Local oClone := SERASA_PessoaJuridicaScore():NEW()
	oClone:cModelo              := ::cModelo
	oClone:cCalculado           := ::cCalculado
	oClone:cPontuacao           := ::cPontuacao
	oClone:cClasse              := ::cClasse
	oClone:nPercentualInadimplentes := ::nPercentualInadimplentes
	oClone:nPercentualRisco     := ::nPercentualRisco
	oClone:cDescricao           := ::cDescricao
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SERASA_PessoaJuridicaScore
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cModelo            :=  WSAdvValue( oResponse,"_MODELO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCalculado         :=  WSAdvValue( oResponse,"_CALCULADO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cPontuacao         :=  WSAdvValue( oResponse,"_PONTUACAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cClasse            :=  WSAdvValue( oResponse,"_CLASSE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nPercentualInadimplentes :=  WSAdvValue( oResponse,"_PERCENTUALINADIMPLENTES","int",NIL,"Property nPercentualInadimplentes as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nPercentualRisco   :=  WSAdvValue( oResponse,"_PERCENTUALRISCO","decimal",NIL,"Property nPercentualRisco as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cDescricao         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Enumeration TipoSocio

WSSTRUCT SERASA_TipoSocio
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SERASA_TipoSocio
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "NaoInformado" )
	aadd(::aValueList , "Fisica" )
	aadd(::aValueList , "Juridica" )
Return Self

WSMETHOD SOAPSEND WSCLIENT SERASA_TipoSocio
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SERASA_TipoSocio
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT SERASA_TipoSocio
Local oClone := SERASA_TipoSocio():New()
	oClone:Value := ::Value
Return oClone

// WSDL Data Enumeration TipoAdministrador

WSSTRUCT SERASA_TipoAdministrador
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SERASA_TipoAdministrador
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "NaoInformado" )
	aadd(::aValueList , "Fisica" )
	aadd(::aValueList , "Juridica" )
Return Self

WSMETHOD SOAPSEND WSCLIENT SERASA_TipoAdministrador
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SERASA_TipoAdministrador
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT SERASA_TipoAdministrador
Local oClone := SERASA_TipoAdministrador():New()
	oClone:Value := ::Value
Return oClone

// WSDL Data Structure Participante

WSSTRUCT SERASA_Participante
	WSDATA   cDocumentoEmpresa         AS string OPTIONAL
	WSDATA   cEmpresa                  AS string OPTIONAL
	WSDATA   cCidade                   AS string OPTIONAL
	WSDATA   cEstado                   AS string OPTIONAL
	WSDATA   oWSPessoa                 AS SERASA_TipoParticipante
	WSDATA   cDocumento                AS string OPTIONAL
	WSDATA   cNome                     AS string OPTIONAL
	WSDATA   cVinculo                  AS string OPTIONAL
	WSDATA   cVinculoDescricao         AS string OPTIONAL
	WSDATA   cCapital                  AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SERASA_Participante
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SERASA_Participante
Return

WSMETHOD CLONE WSCLIENT SERASA_Participante
	Local oClone := SERASA_Participante():NEW()
	oClone:cDocumentoEmpresa    := ::cDocumentoEmpresa
	oClone:cEmpresa             := ::cEmpresa
	oClone:cCidade              := ::cCidade
	oClone:cEstado              := ::cEstado
	oClone:oWSPessoa            := IIF(::oWSPessoa = NIL , NIL , ::oWSPessoa:Clone() )
	oClone:cDocumento           := ::cDocumento
	oClone:cNome                := ::cNome
	oClone:cVinculo             := ::cVinculo
	oClone:cVinculoDescricao    := ::cVinculoDescricao
	oClone:cCapital             := ::cCapital
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SERASA_Participante
	Local oNode5
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cDocumentoEmpresa  :=  WSAdvValue( oResponse,"_DOCUMENTOEMPRESA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cEmpresa           :=  WSAdvValue( oResponse,"_EMPRESA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCidade            :=  WSAdvValue( oResponse,"_CIDADE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cEstado            :=  WSAdvValue( oResponse,"_ESTADO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode5 :=  WSAdvValue( oResponse,"_PESSOA","TipoParticipante",NIL,"Property oWSPessoa as tns:TipoParticipante on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode5 != NIL
		::oWSPessoa := SERASA_TipoParticipante():New()
		::oWSPessoa:SoapRecv(oNode5)
	EndIf
	::cDocumento         :=  WSAdvValue( oResponse,"_DOCUMENTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNome              :=  WSAdvValue( oResponse,"_NOME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cVinculo           :=  WSAdvValue( oResponse,"_VINCULO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cVinculoDescricao  :=  WSAdvValue( oResponse,"_VINCULODESCRICAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCapital           :=  WSAdvValue( oResponse,"_CAPITAL","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure Participado

WSSTRUCT SERASA_Participado
	WSDATA   oWSPessoa                 AS SERASA_TipoParticipado
	WSDATA   cDocumentoEmpresa         AS string OPTIONAL
	WSDATA   cEmpresa                  AS string OPTIONAL
	WSDATA   cPercentual               AS string OPTIONAL
	WSDATA   cEstado                   AS string OPTIONAL
	WSDATA   cDataInicioParticipacao   AS string OPTIONAL
	WSDATA   cDataUltimaAtualizacao    AS string OPTIONAL
	WSDATA   cRestricoes               AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SERASA_Participado
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SERASA_Participado
Return

WSMETHOD CLONE WSCLIENT SERASA_Participado
	Local oClone := SERASA_Participado():NEW()
	oClone:oWSPessoa            := IIF(::oWSPessoa = NIL , NIL , ::oWSPessoa:Clone() )
	oClone:cDocumentoEmpresa    := ::cDocumentoEmpresa
	oClone:cEmpresa             := ::cEmpresa
	oClone:cPercentual          := ::cPercentual
	oClone:cEstado              := ::cEstado
	oClone:cDataInicioParticipacao := ::cDataInicioParticipacao
	oClone:cDataUltimaAtualizacao := ::cDataUltimaAtualizacao
	oClone:cRestricoes          := ::cRestricoes
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SERASA_Participado
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_PESSOA","TipoParticipado",NIL,"Property oWSPessoa as tns:TipoParticipado on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSPessoa := SERASA_TipoParticipado():New()
		::oWSPessoa:SoapRecv(oNode1)
	EndIf
	::cDocumentoEmpresa  :=  WSAdvValue( oResponse,"_DOCUMENTOEMPRESA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cEmpresa           :=  WSAdvValue( oResponse,"_EMPRESA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cPercentual        :=  WSAdvValue( oResponse,"_PERCENTUAL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cEstado            :=  WSAdvValue( oResponse,"_ESTADO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDataInicioParticipacao :=  WSAdvValue( oResponse,"_DATAINICIOPARTICIPACAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDataUltimaAtualizacao :=  WSAdvValue( oResponse,"_DATAULTIMAATUALIZACAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cRestricoes        :=  WSAdvValue( oResponse,"_RESTRICOES","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Enumeration TipoParticipante

WSSTRUCT SERASA_TipoParticipante
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SERASA_TipoParticipante
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "NaoInformado" )
	aadd(::aValueList , "Fisica" )
	aadd(::aValueList , "Juridica" )
Return Self

WSMETHOD SOAPSEND WSCLIENT SERASA_TipoParticipante
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SERASA_TipoParticipante
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT SERASA_TipoParticipante
Local oClone := SERASA_TipoParticipante():New()
	oClone:Value := ::Value
Return oClone

// WSDL Data Enumeration TipoParticipado

WSSTRUCT SERASA_TipoParticipado
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SERASA_TipoParticipado
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "NaoInformado" )
	aadd(::aValueList , "Fisica" )
	aadd(::aValueList , "Juridica" )
Return Self

WSMETHOD SOAPSEND WSCLIENT SERASA_TipoParticipado
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SERASA_TipoParticipado
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT SERASA_TipoParticipado
Local oClone := SERASA_TipoParticipado():New()
	oClone:Value := ::Value
Return oClone



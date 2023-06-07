#include "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE  'totvs.ch' 
#include "Fileio.ch"
#include "TopConn.ch"
#INCLUDE "FWPrintSetup.ch"
#include "ap5mail.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"		//Biblioteca para abertura de Empresas
#INCLUDE "APWIZARD.CH"		//Biblioteca para montagem de wizard (configuracao deste software)
#INCLUDE "MSOLE.CH"

#DEFINE OPC 5

User Function DXAPIBOL()
Return

WsRestful PDFBOL Description "Lista de BOLETOS" Format APPLICATION_JSON
    WSDATA nf                   AS STRING   OPTIONAL
    WSDATA parcela              AS STRING   OPTIONAL
    WSDATA cgc                  AS STRING   OPTIONAL
	WsMethod GET Description "Retorna lista de PDF BOLETOS" WsSyntax "/GET/{method}"
End WsRestful
 
 
 
//-------------------------------------------------------------------
/*/{Protheus.doc} GET / cliente
Retorna a lista de clientes disponíveis.
 
@param  SearchKey       , caracter, chave de pesquisa utilizada em diversos campos
        Page            , numerico, numero da pagina
        PageSize        , numerico, quantidade de registros por pagina
        byId            , logico, indica se deve filtrar apenas pelo codigo
 
@return cResponse       , caracter, JSON contendo a lista de clientes
 
@author rafael.goncalves
@since      Mar|2020
@version    12.1.27
/*/
//-------------------------------------------------------------------
WSMETHOD GET WSRECEIVE  nf,parcela, cgc WSSERVICE PDFBOL
    lRet := PDFBOL( self )
Return( lRet )
 
Static Function PDFBOL( oSelf )
    Local aPDF  := {}
    Local cJsonCli      := ''
    Local oJsonPDF      := JsonObject():New()
    Local cSearch       := ''
    Local cWhere        := " "
    Local nCount        := 0
    Local nStart        := 1
    Local nReg          := 0
    Local nAux          := 0
    Local cAliasSE1     := GetNextAlias()
    Local cJSONRet      := ''
    Local cFileCont     := ''
    Local cErrPDF       := ''
    Local oFile
    Local cFilCont      := ""
    Local aFiles      := {} // O array receberï¿½ os nomes dos arquivos e do diretï¿½rio
    Local aSizes      := {} // O array receberï¿½ os tamanhos dos arquivos e do diretorio          
    Local lRet          := .T.
    Private _aTitulos   := {}
    Default oself:cgc       := ' '
    Default oself:nf        := ' '
    Default oself:parcela        := ' '

    PRIVATE cEmpProc	:= '01' as character
    PRIVATE cFilProc	:= '0103' as character

    //If Select("SX2") == 0
        //Preparando o ambiente
    PREPARE ENVIRONMENT EMPRESA cEmpProc Filial cFilProc modulo 'FAT'
   // EndIf    
 
    // Tratativas para realizar os filtros
    If !Empty(oself:cgc) //se tiver chave de busca no request
        cSearch := Upper( oself:cgc )
        cWhere += " AND SA1.A1_CGC = '" + cSearch + "'"        
    EndIf

    cWhere += " AND SE1.E1_NUM = '" + Alltrim(Upper( oself:nf )) + "' AND SE1.E1_PARCELA = '" + Alltrim(Upper( oself:parcela )) + "' AND E1_PORTADO <> ' ' AND E1_SALDO > 0 "
    cWhere := '%'+cWhere+'%' //monta a expressao where
 
    // Realiza a query para selecionar clientes
    BEGINSQL Alias cAliasSE1
        SELECT SA1.* , SE1.*, SE1.R_E_C_N_O_ AS REC
        FROM    %table:SE1% SE1
        INNER JOIN    %table:SA1% SA1 ON A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA
        WHERE   SA1.%NotDel% AND SE1.%NotDel%
        %exp:cWhere%
        ORDER BY E1_NUM
    ENDSQL
 
 
    conout('query BOLETO ' + getlastquery()[2])
    //-------------------------------------------------------------------
    // Alimenta array de clientes
    //-------------------------------------------------------------------
    While ( cAliasSE1 )->( ! Eof() )
     //Transformo em base64 o arquivo
        cArquivo := "bol"+ AllTrim(( cAliasSE1 )->E1_PORTADO)+ "_" + ;
        AllTrim(( cAliasSE1 )->E1_NUM) + "_" + ;
        AllTrim(IIF(Empty(( cAliasSE1 )->E1_PARCELA), "U", ( cAliasSE1 )->E1_PARCELA)) + "_" +;
        AllTrim(( cAliasSE1 )->E1_CLIENTE) + AllTrim(( cAliasSE1 )->E1_LOJA) + ".pdf"     
        ADir('\bol_gerados\' + cArquivo, aFiles, aSizes)//Verifica o tamanho do arquivo, parï¿½metro exigido na FRead.

        If Len(aFiles) == 0
            
            cArquivo := GeraBol(( cAliasSE1 )->REC)

            ADir('\bol_gerados\' + cArquivo, aFiles, aSizes)//Verifica o tamanho do arquivo, parï¿½metro exigido na FRead.

            If Empty(cArquivo)
                //Alert('Não foi gerado o arquivo PDF!')
                cJSONRet += '{'
                cJSONRet += '"status":"Erro ao gerar o boleto", ' + CRLF
                //cJSONRet += '"mensagem":  "' + cResult + CRLF
                cJSONRet += '} ' + CRLF    
                SetRestFault(400, FwNoAccent(cJSONRet))                
                Return
            EndIf
        EndIF

        ADir('\bol_gerados\' + cArquivo, aFiles, aSizes)//Verifica o tamanho do arquivo, parï¿½metro exigido na FRead.
        nHandle := fopen('\bol_gerados\' + cArquivo , FO_READWRITE + FO_SHARED )
        cString := ""
        FRead( nHandle, cString, aSizes[1] ) //Carrega na variï¿½vel cString, a string ASCII do arquivo.

        cFilCont := Encode64(cString) //Converte o arquivo para BASE64

        fclose(nHandle) 

        aAdd( aPDF , JsonObject():New() )
        aPDF[Len(aPdf)]['cgc']       := ( cAliasSE1 )->A1_CGC
        aPDF[Len(aPdf)]['nf']        := Alltrim(( cAliasSE1 )->E1_NUM) + "_" + AllTrim(IIF(Empty(( cAliasSE1 )->E1_PARCELA), "U", ( cAliasSE1 )->E1_PARCELA))
        aPDF[Len(aPdf)]['pdfboleto']  := cFilCont  
        ( cAliasSE1 )->( DBSkip() )
    End
    ( cAliasSE1 )->( DBCloseArea() )

    If Len(aPDF) > 0 .aND. lRet
        oJsonPDF['PDFBOL'] := aPDF
    Else
        If empty(cJSONRet)
            cJSONRet += '{'
            cJSONRet += '"status":"sem resultados", ' + CRLF
            cJSONRet += '"mensagem": busca não retornou resultados "' + CRLF
            cJSONRet += '} ' + CRLF    
            SetRestFault(400, FwNoAccent(cJSONRet))
        EndIf
    EndIf
 
    //-------------------------------------------------------------------
    // Serializa objeto Json
    //-------------------------------------------------------------------
    cJsonCli:= FwJsonSerialize( oJsonPDF )
 
    //-------------------------------------------------------------------
    // Elimina objeto da memoria
    //-------------------------------------------------------------------
    FreeObj(oJsonPDF)
    oself:SetResponse( cJsonCli ) //-- Seta resposta
    RpcClearEnv()

Return .T.

Static Function GeraBol(nRecE1)
Local cRet := ''
Local cNomArq := ''
Local aFiles      := {} // O array receberï¿½ os nomes dos arquivos e do diretï¿½rio
Local aSizes      := {} // O array receberï¿½ os tamanhos dos arquivos e do diretorio     

SE1->(DbGoTo(nRecE1))

cRet := U_TIBBOLETO()

If !empty(cRet)
    cRet += '.pdf'
EndIf
Return cRet

 /*/{Protheus.doc} nomeFunction
    (long_description)
    @type  Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function BolBrad(nRecE1)
Local cRet := ''
Local cNomArq := ''
Local aFiles      := {} // O array receberï¿½ os nomes dos arquivos e do diretï¿½rio
Local aSizes      := {} // O array receberï¿½ os tamanhos dos arquivos e do diretorio     

SE1->(DbGoTo(nRecE1))

cNomArq := "bol237_" + ;
AllTrim(SE1->E1_NUM) + "_" + ;
AllTrim(IIF(Empty(SE1->E1_PARCELA), "U", SE1->E1_PARCELA)) + "_" +;
AllTrim(SE1->E1_CLIENTE) + AllTrim(SE1->E1_LOJA) + ".pdf"

ADir('\bol_gerados\' + cNomArq, aFiles, aSizes)//Verifica o tamanho do arquivo, parï¿½metro exigido na FRead.

If Len(aFiles) == 0

    SA6->(dbSetOrder(1))
    If SA6->(dbSeek(xFilial("SA6")+SE1->E1_PORTADO+SE1->E1_AGEDEP+SE1->E1_CONTA))
        SEE->(dbSetOrder(3))
    //		If SEE->(dbSeek(xFilial("SEE")+SA6->(A6_COD+A6_AGENCIA+A6_NUMCON)+PadL(ALLTRIM(MV_PAR10),3,"0")))
        If SEE->(dbSeek(xFilial("SEE")+SA6->(A6_COD+A6_AGENCIA+A6_NUMCON)+'09'))

            cXCodBco := "237-2"
            cXNomeBco := "BANCO BRADESCO"
            cXLogoBco := "BRADESCO.BMP"
            nXTxJurBco := 0.2  //Juros de 1% ao mes que sao 0,03333% ao dia  
                                
            cXFunDigNN := "BraMod11(_cCart+_cNumero)"
            cXFunCodBar := "BraCodBar()"

            AddTitulo()
            //Chama a impressao
            cRet := ChamaImp()
        ElseIF SEE->(dbSeek(xFilial("SEE")+SA6->(A6_COD+A6_AGENCIA+A6_NUMCON)))
            cXCodBco := "237-2"
            cXNomeBco := "BANCO BRADESCO"
            cXLogoBco := "BRADESCO.BMP"
            nXTxJurBco := 0.2  //Juros de 1% ao mes que sao 0,03333% ao dia  
                                
            cXFunDigNN := "BraMod11(_cCart+_cNumero)"
            cXFunCodBar := "BraCodBar()"

            AddTitulo()
            //Chama a impressao
            cRet := ChamaImp()            
        EndIf
    EndIF
Else
    cRet := cNomArq
EndIf
Return cRet




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AddTitulo ºAutor  ³Stanko              º Data ³  01/10/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Adiciona o titulo a ser impresso no vetor principal        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function AddTitulo()
_aTitulos := {}
_nCont := 1
Aadd(_aTitulos,{"","",0,"","","","","","","","","","","","","",0,0,"","",0})

nVlrAbat   :=  SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
nVlrAbat   += SE1->E1_SALDO * SE1->E1_DESCFIN/100
nValor 	   := (SE1->E1_SALDO-nVlrAbat)
lVenc 	   := .F.
dVencto    := SE1->E1_VENCTO
nMulta     := 0
nMora      := 0
_cCart   := 	Alltrim(SEE->EE_CARTEIR)

_cNum := SE1->E1_PREFIXO+" "+SE1->E1_NUM+" "+SE1->E1_PARCELA
_aTitulos[_nCont][01] := SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA           // Prexifo+Numero+Parcela do Titulo
_aTitulos[_nCont][02] := dVencto   												 // Vencimento
_aTitulos[_nCont][03] := nValor                                                 // Valor
_aTitulos[_nCont][04] := SE1->E1_NUMBCO   										//  Nosso Numero

cDigAgen   :=  ALLTRIM(SA6->A6_DVAGE)
cDigCon := ALLTRIM(SA6->A6_DVCTA)

_aTitulos[_nCont][05] := SE1->E1_AGEDEP+cDigAgen   							// Agencia
_aTitulos[_nCont][06] := right(Alltrim(SEE->EE_CONTA),9)  					// Codigo do Cedente RIGHT(Alltrim(SEE->EE_CONTA),9)
_aTitulos[_nCont][07] := _cCart      											// Carteira
_aTitulos[_nCont][08] := StrZero(Day(SE1->E1_EMISSAO),2)+"/"+StrZero(Month(SE1->E1_EMISSAO),2)+"/"+StrZero(Year(SE1->E1_EMISSAO),4)
_aTitulos[_nCont][16] := SE1->E1_CONTA+cDigCon 	  							// Numero da Conta Corrente
_aTitulos[_nCont][17] := SE1->E1_SALDO-nVlrAbat                           //SE1->E1_SALDO
_aTitulos[_nCont][18] := nMulta + nMora
_aTitulos[_nCont][19] := SE1->E1_PEDIDO
_aTitulos[_nCont][20] := SE1->E1_VEND1                                     
_aTitulos[_nCont][21] := SE1->E1_DECRESC




// Obtem dados do cliente
SA1->(DbSetOrder(1))
If SA1->(DbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA))
	_aTitulos[_nCont][09] := SA1->A1_COD+" - "+SA1->A1_NOME
	
	IF .NOT. Empty(Alltrim(SA1->A1_ENDCOB))
		_aTitulos[_nCont][10] := Alltrim(SA1->A1_ENDCOB) + "-" + AllTrim(SA1->A1_BAIRROC)
		_aTitulos[_nCont][11] := SA1->A1_MUNC
		_aTitulos[_nCont][12] := SA1->A1_ESTC
		_aTitulos[_nCont][13] := SA1->A1_CEPC
	ELSE
		_aTitulos[_nCont][10] := SA1->A1_END
		_aTitulos[_nCont][11] := SA1->A1_MUN
		_aTitulos[_nCont][12] := SA1->A1_EST
		_aTitulos[_nCont][13] := SA1->A1_CEP
	ENDIF
	_aTitulos[_nCont][14] := SA1->A1_CGC
	_aTitulos[_nCont][15] := StrZero(Day(dDatabase),2)+"/"+StrZero(Month(dDatabase),2)+"/"+StrZero(Year(dDatabase),4)
Endif
_nCont += 1

Return Nil





/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ChamaImp  ºAutor  ³Stanko              º Data ³  01/10/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Prepara a Impresso									      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ChamaImp()
Local nX		:= 0
LOCAL lAdjustToLegacy := .T.
LOCAL lDisableSetup   := .T.
Private _cBarra  := SPACE(44)
Private _cLinhaD := ""

Private _nLinha  := 0
Private _nEspLin := 0
Private _nPosHor := 0
Private _nPosVer := 0
Private _nTxtBox := 0
Private _nTxtBox2:= 0
Private cPathServG := "\bol_gerados\"

//Nome: BOL104_NUMERO_PARCELA+_CLIENTE+LOJA
cNomArq := "bol237_" + ;
AllTrim(SE1->E1_NUM) + "_" + ;
AllTrim(IIF(Empty(SE1->E1_PARCELA), "U", SE1->E1_PARCELA)) + "_" +;
AllTrim(SE1->E1_CLIENTE) + AllTrim(SE1->E1_LOJA) + ".pdf"

//oPrint   := FWMSPrinter():New(cNomArq, IMP_SPOOL, .F.,         , .T.)
oPrint := FWMSPrinter():New( cNomArq, IMP_PDF, lAdjustToLegacy, cPathServG, lDisableSetup, , , , , , .F., .F. )

oPrint:SetPortrait()
oPrint:SETPAPERSIZE(1)

oPrint:SETPAPERSIZE(9)


For nX := 1 to len(_aTitulos)
	_nCont := nX
	_nLinha  := 1
	                      
	_cBarra  := SPACE(44)
	_cLinhaD := ""
	
	// ajuste para papel A4
	
	oPrint:StartPage()
	
	ImpBlt( 1, .F.)
	ImpBlt( 2, .T.)
	ImpBlt( 3, .T.)
	
	oPrint:EndPage()
	
Next

	
//oPrint:setup()                                 
oPrint:Print()
//Copia PDF - TEMP para o Server (pasta Gerados)

FreeObj(oPrint)
oPrint := Nil

Return cNomArq


     

Static Function ImpBlt(_nVia, _lSepara) 

LOCAL cContaDig := ""
Local cAgeDig   := ""
LOCAL _oFntLinha
LOCAL _cTxtRodape:=""
LOCAL _nMoraDia      

cXEmpresa := AllTrim(SM0->M0_NOMECOM)+"  - "+"CNPJ "+Transform(SM0->M0_CGC,"@R 99.999.999/9999-99")+"  -  "+ALLTRIM(SM0->M0_ENDCOB)+" - "+ALLTRIM(SM0->M0_CIDCOB)+"/"+ALLTRIM(SM0->M0_ESTCOB) 

oFont06  := TFont():New( "Arial",,06,,.F.,,,,,.F. )
oFont06B := TFont():New( "Arial",,06,,.T.,,,,,.F. )
oFont07  := TFont():New( "Arial",,07,,.F.,,,,,.F. )
oFont07B := TFont():New( "Arial",,07,,.T.,,,,,.F. )
oFont08  := TFont():New( "Arial",,08,,.F.,,,,,.F. )
oFont08B := TFont():New( "Arial",,08,,.T.,,,,,.F. )
oFont09  := TFont():New( "Arial",,09,,.F.,,,,,.F. )
oFont09B := TFont():New( "Arial",,09,,.T.,,,,,.F. )
oFont10  := TFont():New( "Arial",,10,,.F.,,,,,.F. )
oFont10B := TFont():New( "Arial",,10,,.T.,,,,,.F. )
oFont11  := TFont():New( "Arial",,11,,.F.,,,,,.F. )
oFont11B := TFont():New( "Arial",,11,,.T.,,,,,.F. )
oFont12  := TFont():New( "Arial",,12,,.F.,,,,,.F. )
oFont12B := TFont():New( "Arial",,12,,.T.,,,,,.F. )
oFont13  := TFont():New( "Arial",,13,,.F.,,,,,.F. )
oFont13B := TFont():New( "Arial",,13,,.T.,,,,,.F. )
oFont14  := TFont():New( "Arial",,14,,.F.,,,,,.F. )
oFont14B := TFont():New( "Arial",,14,,.T.,,,,,.F. )
oFont15  := TFont():New( "Arial",,15,,.F.,,,,,.F. )
oFont15B := TFont():New( "Arial",,15,,.T.,,,,,.F. )
oFont16  := TFont():New( "Arial",,16,,.F.,,,,,.F. )
oFont16B := TFont():New( "Arial",,16,,.T.,,,,,.F. )
oFont17  := TFont():New( "Arial",,17,,.F.,,,,,.F. )
oFont17B := TFont():New( "Arial",,17,,.T.,,,,,.F. )
oFont18  := TFont():New( "Arial",,18,,.F.,,,,,.F. )
oFont18B := TFont():New( "Arial",,18,,.T.,,,,,.F. )
oFont19  := TFont():New( "Arial",,19,,.F.,,,,,.F. )
oFont19B := TFont():New( "Arial",,19,,.T.,,,,,.F. )
oFont20  := TFont():New( "Arial",,20,,.F.,,,,,.F. )
oFont20B := TFont():New( "Arial",,20,,.T.,,,,,.F. )
oFont21  := TFont():New( "Arial",,21,,.F.,,,,,.F. )
oFont21B := TFont():New( "Arial",,21,,.T.,,,,,.F. )
oFont22  := TFont():New( "Arial",,22,,.F.,,,,,.F. )
oFont22B := TFont():New( "Arial",,22,,.T.,,,,,.F. )
oFont23  := TFont():New( "Arial",,23,,.F.,,,,,.F. )
oFont23B := TFont():New( "Arial",,23,,.T.,,,,,.F. )
oFont24  := TFont():New( "Arial",,24,,.F.,,,,,.F. )
oFont24B := TFont():New( "Arial",,24,,.T.,,,,,.F. )
oFont25  := TFont():New( "Arial",,25,,.F.,,,,,.F. )
oFont25B := TFont():New( "Arial",,25,,.T.,,,,,.F. )
oFont26  := TFont():New( "Arial",,26,,.F.,,,,,.F. )
oFont26B := TFont():New( "Arial",,26,,.T.,,,,,.F. )
oFont27  := TFont():New( "Arial",,27,,.F.,,,,,.F. )
oFont27B := TFont():New( "Arial",,27,,.T.,,,,,.F. )
oFont28  := TFont():New( "Arial",,28,,.F.,,,,,.F. )
oFont28B := TFont():New( "Arial",,28,,.T.,,,,,.F. )
oFont29  := TFont():New( "Arial",,29,,.F.,,,,,.F. )
oFont29B := TFont():New( "Arial",,29,,.T.,,,,,.F. )
oFont30  := TFont():New( "Arial",,30,,.F.,,,,,.F. )
oFont30B := TFont():New( "Arial",,30,,.T.,,,,,.F. )



// Posicionamento Horizontal
_nPosHor := 1
_nEspLin := 70
	
// Posicionamento Vertical
_nPosVer := 80
	
// Posicionamento do Texto Dentro do Box
_nTxtBox := 19
_nTxtBox2:= 20

cAgeDig   := ALLTRIM(SA6->A6_AGENCIA) + ALLTRIM(SA6->A6_DVAGE)
cContaDig := "00" + SUBS(SA6->A6_NUMCON,1,5) + SA6->A6_DVCTA //PadL( ALLTRIM(SA6->A6_NUMCON)  + ALLTRIM(SA6->A6_DVCTA), 8, "0")
//_cBarra:=""

_oFntLinha:=oFont11B

IF _lSepara
	_nLinha  += 2
	oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin)+40,_nPosVer,Replicate("- ",140),ofont12,100)
	_nLinha  += 1
   //_nEspLin:=70
ENDIF

IF _nVia == 1 //_VIA_BANCO
	_oFntLinha:=oFont13B
	
	cTexto :="Arquivo da Empresa"
	_cTxtRodape:="Autenticação Mecânica"

	// Monta codigo de barras do titulo
	&(cXFunCodBar)  //MeuCodBar

	// Monta Linha digitavel
	MinhaLinha()

ELSEIF _nVia == 2 //_VIA_EMPRESA
	cTexto :="Recibo do Pagador"         
	_cTxtRodape:="Autenticação Mecânica"
	
ELSEIF _nVia == 3 //_VIA_SACADO                                
	 cTexto := _clinhaD //"Recibo do Sacado"
	_cTxtRodape:="Autenticação Mecânica / FICHA DE COMPENSAÇÃO"
ENDIF

If !File(cXLogoBco)
	oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+20,_nPosVer,cXNomeBco,ofont13B,100)
Else
	oPrint:SayBitmap(_nPosHor+((_nLinha-1)*_nEspLin)+_nPosVer,0005,cXLogoBco,0350,0089)
EndIf

oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin)+40, _nTxtBox+720,"|"+cXCodBco+"|",oFont18B,100)
                 	
// Linha Digitavel
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+0025,_nPosVer+1400,cTexto,_oFntLinha,100,,,1)

	
// Box Local de Pagto
_nLinha  += 1
_nPosHor := 1
oPrint:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer    ,_nPosHor+(_nLinha*_nEspLin),_nPosVer+1650)
oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox    ,_nPosVer+0010,"Local de Pagamento",ofont10,100)
oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox2+33 ,_nPosVer+0010,"Pagável preferencialmente nas agências do Banco Bradesco e Bradesco Expresso.",ofont09,100)

// Box Vencimento
oPrint:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+1650,_nPosHor+(_nLinha*_nEspLin),_nPosVer+2230)
oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1660,"Vencimento",ofont10,100)
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox2+30,_nPosVer+2060,StrZero(Day(_aTitulos[_nCont][02]),2)+"/"+StrZero(Month(_aTitulos[_nCont][02]),2)+"/"+StrZero(Year(_aTitulos[_nCont][02]),4),ofont12B,100,,,1)

// Box Cedente
_nLinha  += 1
oPrint:Box(_nPosHor+((_nLinha-1)*_nEspLin) - 1,_nPosVer,_nPosHor+(_nLinha*_nEspLin),_nPosVer+1650)
oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0010,"Beneficiário",ofont10,100)
oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin+30)+_nTxtBox2,_nPosVer+0010,cXEmpresa,ofont10,100)

// Box Agencia/Codigo Cedente
oPrint:Box(_nPosHor+((_nLinha-1)*_nEspLin) - 1,_nPosVer+1650,_nPosHor+(_nLinha*_nEspLin),_nPosVer+2230)
oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1660,"Agência/Código Beneficiário",ofont10,100)

If SEE->EE_XNUMBCO == "001"                                                    
 oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin+30)+_nTxtBox2,_nPosVer+2200,transform(cAgeDig,"@R 9999-9")+"/"+Substr(cContaDig,3,5)+"-"+Substr(cContaDig,8,1),ofont12B,100,,,1)

ElseIf SEE->EE_XNUMBCO == "104"                                                    
 oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin+30)+_nTxtBox2,_nPosVer+2200,"0267.870.00000370-5",ofont12B,100,,,1)

ElseIf SEE->EE_XNUMBCO == "033"                                                              
 oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin+30)+_nTxtBox2,_nPosVer+2200,ALLTRIM(SA6->A6_AGENCIA)+"/"+ALLTRIM(SEE->EE_CODEMP),ofont12B,100,,,1)

Else
 oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin+30)+_nTxtBox2,_nPosVer+1960,transform(cAgeDig,"@R 9999-9")+"/"+transform(cContaDig,"@R 9999999-X"),ofont12B,100,,,1)
EndIf  

// Box Data do documento
_nLinha  += 1
oPrint:Box(_nPosHor+((_nLinha-1)*_nEspLin) - 1,_nPosVer,_nPosHor+(_nLinha*_nEspLin),_nPosVer+0420)
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0010,"Data do documento",ofont08,100)
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox2+30,_nPosVer+0100,_aTitulos[_nCont][08],ofont08,100)

// Box Numero do Documento
oPrint:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+0420,_nPosHor+(_nLinha*_nEspLin),_nPosVer+0790)
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0430,"N° do documento",ofont08,100)
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox2+30,_nPosVer+0530,_aTitulos[_nCont][01],ofont08,100)

// Box Especie Doc
oPrint:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+0790,_nPosHor+(_nLinha*_nEspLin),_nPosVer+1050)
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0800,"Espécie Doc",ofont08,100)
oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox2+30,_nPosVer+0900,"DM",ofont08,100)

// Box Aceite
oPrint:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+1050,_nPosHor+(_nLinha*_nEspLin),_nPosVer+1170)
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1060,"Aceite",ofont08,100)
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox2+30,_nPosVer+1080,"Não",ofont08,100)


// Box Data do Processamento
oPrint:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+1170,_nPosHor+(_nLinha*_nEspLin),_nPosVer+1650)
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1180,"Data do Processamento",ofont08,100)
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox2+30,_nPosVer+1280,_aTitulos[_nCont][15],ofont08,100)

// Box Cart./nosso numero
oPrint:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+1650,_nPosHor+(_nLinha*_nEspLin),_nPosVer+2230)
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1660,"Nosso Número",ofont08,100)           

If SEE->EE_XNUMBCO == "001"                                                    
	cAux := Substr(SEE->EE_CODEMP,1,7)+StrZero(Val(Substr(_aTitulos[_nCont][04],1,Len(AllTrim(_aTitulos[_nCont][04]))-1)),10)
	oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox2+30,_nPosVer+1960,cAux,ofont08B,100)	

ElseIf SEE->EE_XNUMBCO == "033"                                                    
	oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox2+30,_nPosVer+1960,Transform((AllTrim(_aTitulos[_nCont][04])),"@R 99999999999-X"),ofont08B,100)

ElseIf SEE->EE_XNUMBCO == "237"                                                    
	oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox2+30,_nPosVer+1960,"09" + "/"+Transform((AllTrim(_aTitulos[_nCont][04])),"@R 99999999999-X"),ofont12B,100)

Else
	oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox2+30,_nPosVer+2060,Transform(_aTitulos[_nCont][04],"@R 99999999999-X"),ofont12B,100)
EndIf	


_nLinha  += 1
                   

	// Box Uso do Banco
	oPrint:Box(_nPosHor+((_nLinha-1)*_nEspLin) - 1,_nPosVer,_nPosHor+(_nLinha*_nEspLin),_nPosVer+0420)
	oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0010,"Uso do Banco",ofont08,100)
	oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox2+30,_nPosVer+0050,"",ofont08,100)

	// Box Carteira
	oPrint:Box(_nPosHor+((_nLinha-1)*_nEspLin) -1 ,_nPosVer+0420,_nPosHor+(_nLinha*_nEspLin),_nPosVer+0552)
	oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0430,"Carteira",ofont08,100)
	oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox2+30,_nPosVer+0480,_aTitulos[_nCont][07],ofont08,100)


/*If SEE->EE_XNUMBCO == "033"

	oPrint:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer,_nPosHor+(_nLinha*_nEspLin),_nPosVer+0420)
	oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0010,"Carteira",ofont08,100)
	oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox2+30,_nPosVer+0050,"101 - RAPIDA COM REGISTRO",ofont08,100)


Else

	// Box Uso do Banco
	oPrint:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer,_nPosHor+(_nLinha*_nEspLin),_nPosVer+0420)
	oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0010,"Uso do Banco",ofont08,100)
	oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox2+30,_nPosVer+0050,"",ofont08,100)

	// Box Carteira
	oPrint:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+0420,_nPosHor+(_nLinha*_nEspLin),_nPosVer+0552)
	oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0430,"Carteira",ofont08,100)
	oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox2+30,_nPosVer+0480,_aTitulos[_nCont][07],ofont08,100)

EndIf	*/
	
// Box Espécie Moeda
oPrint:Box(_nPosHor+((_nLinha-1)*_nEspLin) - 1,_nPosVer+0552,_nPosHor+(_nLinha*_nEspLin),_nPosVer+0790)
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0562,"Espécie moeda",ofont08,100)
oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox2+30,_nPosVer+0662,"R$",ofont08,100)

// Box Quantidade
oPrint:Box(_nPosHor+((_nLinha-1)*_nEspLin) -1,_nPosVer+0790,_nPosHor+(_nLinha*_nEspLin),_nPosVer+1170)
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0800,"Quantidade",ofont08,100)

// Box Valor
oPrint:Box(_nPosHor+((_nLinha-1)*_nEspLin)-1,_nPosVer+1170,_nPosHor+(_nLinha*_nEspLin),_nPosVer+1650)
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1180,"Valor",ofont08,100)

// Box Valor do documento
oPrint:Box(_nPosHor+((_nLinha-1)*_nEspLin) - 1 ,_nPosVer+1650,_nPosHor+(_nLinha*_nEspLin),_nPosVer+2230)
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1660,"1(=) Valor do documento",ofont08,100)
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox2+30,_nPosVer+2050,transform(_aTitulos[_nCont][17],"@E 999,999,999.99"),ofont12B,100,,,1)

_nLinha  += 1


// Box Instrucoes
oPrint:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer,_nPosHor+(_nLinha*_nEspLin)+4*_nEspLin,_nPosVer+1650)
oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+10,_nPosVer+0010,"Instruções (Texto de responsabilidade do Beneficiário)",ofont08,100)

//MENSAGENS
//_nMoraDia:=Round((_aTitulos[_nCont][17]*nXTxJurBco)/30,2)
oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+50 ,_nPosVer+0010,"Após o vencimento, cobrar juros de 6% ao mês.",ofont09,100)
//oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+100 ,_nPosVer+0010,"Após o vencimento cobrar multa de 2%.",ofont09,100)
//oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+150,_nPosVer+0010,"Sujeito a Protesto após o vencimento.",ofont09,100)

// Box Desconto / Abatimento
oPrint:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+1650,_nPosHor+(_nLinha*_nEspLin),_nPosVer+2230)
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1660,"2(-) Desconto/abatimento",ofont08,100)
     
//nao mostra desconto 0
If SEE->EE_XNUMBCO $ "001/237"
	If  _aTitulos[_nCont][21] > 0                                                    
		oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox2+30,_nPosVer+2200,transform(_aTitulos[_nCont][21],"@E 999,999,999.99"),ofont08B,100,,,1)
	EndIf	
Else
	oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox2+30,_nPosVer+2200,transform(_aTitulos[_nCont][21],"@E 999,999,999.99"),ofont08B,100,,,1)
EndIf		




// Box Outras deducoes
_nLinha  += 1
oPrint:Box(_nPosHor+((_nLinha-1)*_nEspLin) - 1,_nPosVer+1650,_nPosHor+(_nLinha*_nEspLin),_nPosVer+2230)
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1660,"3(-) Outras deduções",ofont08,100)

//oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0010,"*** Valores Expressos em R$ ***",ofont09B,100)

// Box Mora / Multa
_nLinha  += 1
oPrint:Box(_nPosHor+((_nLinha-1)*_nEspLin) - 1,_nPosVer+1650,_nPosHor+(_nLinha*_nEspLin),_nPosVer+2230)
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1660,"4(+) Mora/Multa",ofont08,100)   
//oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+30,_nPosVer+2000,transform(_aTitulos[_nCont][18],"@E 999,999,999.99"),ofont08B,100)

//oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+0010,"Após o vencimento cobrar multa de R$  "+transform(_aTitulos[_nCont][17]*0.02,"@E 9,999,999.99"),ofont09B,100)
//oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+0010,"Pagavel em qualquer banco até o vencimento",ofont09B,100)

// Box Outros acrescimos                                                     '
_nLinha  += 1
oPrint:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+1650,_nPosHor+(_nLinha*_nEspLin),_nPosVer+2230)
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1660,"5(+) Outros Acréscimos",ofont08,100)
//oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin)-50+_nTxtBox+10,_nPosVer+0010,"Apos 3 dias uteis será enviado ao cartorio",ofont09B,100)



//oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin)-50+_nTxtBox+10,_nPosVer+0010,"Mora Diária de R$ "+transform((_aTitulos[_nCont][17]*0.03)/30,"@E 9,999,999.99"),ofont09B,100)
//oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+10,_nPosVer+0010,"Apos o vencimento juros de 0,33% ao dia (R$ "+AllTrim(Transform(_aTitulos[_nCont][17]*0.0033,"@E 9,999,999.99"))+")",ofont09B,100)

// Box Valor cobrado
_nLinha  += 1
oPrint:Box(_nPosHor+((_nLinha-1)*_nEspLin) - 1,_nPosVer+1650,_nPosHor+(_nLinha*_nEspLin),_nPosVer+2230)
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1660,"6(=) Valor cobrado",ofont08,100)
//oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+30,_nPosVer+2000,transform(_aTitulos[_nCont][3],"@E 999,999,999.99"),ofont08B,100)


// Box Sacado
_nLinha  += 1
oPrint:Box(_nPosHor+((_nLinha-1)*_nEspLin) - 2,_nPosVer,_nPosHor+(_nLinha*_nEspLin)+_nEspLin,_nPosVer+2225)
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0010,"Pagador:",ofont08,100)
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox2,_nPosVer+0150,_aTitulos[_nCont][09],ofont08,100) // Nome Sacado
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox2,_nPosVer+1400,IIF(SA1->A1_PESSOA = 'J',"CNPJ: "+Transform(_aTitulos[_nCont][14],"@R 99.999.999/9999-99"),"CPF: "+Transform(_aTitulos[_nCont][14],"@R 999.999.999-99")),ofont08,100) // CNPJ Sacado
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox2+0030,_nPosVer+0150,_aTitulos[_nCont][10],ofont08,100) // End. Sacado
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox2+0060,_nPosVer+0150,Transform(_aTitulos[_nCont][13],"@R 99999-999"),ofont08,100) // CEP Sacado
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox2+0060,_nPosVer+0550,_aTitulos[_nCont][11],ofont08,100) // Cidade Sacado
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox2+0060,_nPosVer+1000,_aTitulos[_nCont][12],ofont08,100) // Estado Sacado
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+0115,_nPosVer+0010,"Sacador/Avalista:",ofont08,100)
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+0115,_nPosVer+1660,"Código de Baixa:",ofont08,100)
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+0150,_nPosVer+1700,_cTxtRodaPe,ofont08,100,,,1)

// Imprime codigo de barras
//MSBAR("INT25",14.2,0.5,_cbarra,oPrint,.F.,,.T.,0.02,1,NIL,NIL,NIL,.F.)  //0.0135
   
If _nVia == 3 //_VIA_BANCO
//	MsBar("INT25",26.5,2,_cbarra,oPrint,.F.,Nil,Nil,0.028,1.8,Nil,Nil,"A",.F.)  	    // folha A4 - driver windows 2000 server
//      MSBAR(cTypeBar,nRow ,nCol,cCode       ,oPrint,lCheck,Color,lHorz,nWidth,nHeigth,lBanner,cFont,cMode,lPrint,nPFWidth,nPFHeigth)
//      MSBAR("INT25" ,26   ,1.5 ,CB_RN_NN[1] ,oPrint,.F.   ,     ,     ,      ,1.2    ,       ,     ,     ,.F.)            // exemplo zana 
	//MsBar("INT25" ,27   ,2   ,_cbarra     ,oPrint,.F.   ,     ,     ,      ,1.2    ,       ,     ,     ,.F.)  	    // folha A4 - driver windows 2000 server
    oPrint:FWMSBAR("INT25",62,2.5,_cbarra,oPrint,.F., ,.T.,0.028,0.6,NIL,NIL,NIL,.F.,2/*nPFWidth*/,2/*nPFHeigth*/,.F./*lCmtr2Pix*/)

EndIf	


IF File(cXLogoBco)
	// Imprime Logotipo do Banco
	oPrint:Saybitmap(0015,0060,cXLogoBco,0080,0070)

	// Imprime Logotipo do Banco
	oPrint:Saybitmap(0515,0060,cXLogoBco,0080,0070)

	// Imprime Logotipo do Banco
	oPrint:Saybitmap(0690,1850,cXLogoBco,0180,0180)

	// Imprime Logotipo do Banco
	oPrint:Saybitmap(2105,0060,cXLogoBco,0080,070)
ENDIF
	
Return (.T.)













Static FUNCTION MinhaLinha()

Local _nI   := 1
Local _nAux := 0
_cLinhaD     := ""
_nDigito    := 0
_cCampo     := ""
Fator      := CTOD("07/10/1997")
/*
Primeiro Campo
Posicao  Tam       Descricao
01 a 03   03   Codigo de Compensacao do Banco (237)
04 a 04   01   Codigo da Moeda (Real => 9, Outras => 0)
05 a 09   05   Pos 1 a 5 do campo Livre(Pos 1 a 4 Dig Agencia + Pos 1 Dig Carteira)
10 a 10   01   Digito Auto Correcao (DAC) do primeiro campo

 9 000.000001 00100.030568 2 54100000087659
Segundo Campo
11 a 20   10   Pos 6 a 15 do campo Livre(Pos 2 Dig Carteira + Pos 1 a 9 Nosso Num)
21 a 21   01   Digito Auto Correcao (DAC) do segundo campo

Terceiro Campo
22 a 31   10   Pos 16 a 25 do campo Livre(Pos 10 a 11 Nosso Num + Pos 1 a 8 Conta Corrente + "0")
32 a 32   01   Digito Auto Correcao (DAC) do terceiro campo

Quarto Campo
33 a 33   01   Digito Verificador do codigo de barras

Quinto Campo
34 a 37   04   Fator de Vencimento
38 a 47   10   Valor
*/

// Calculo do Primeiro Campo
_cCampo := ""
_cCampo := Subs(_cBarra,1,4)+Subs(_cBarra,20,5)
// Calculo do digito do Primeiro Campo
DigitoLin(2)
_cLinhaD += Subs(_cCampo,1,5)+"."+Subs(_cCampo,6,4)+Alltrim(Str(_nDigito))

// Insere espaco
_cLinhaD += " "

// Calculo do Segundo Campo
_cCampo := ""
_cCampo := Subs(_cBarra,25,10)
// Calculo do digito do Segundo Campo
DigitoLin(1)
_cLinhaD += Subs(_cCampo,1,5)+"."+Subs(_cCampo,6,5)+Alltrim(Str(_nDigito))

// Insere espaco
_cLinhaD += " "

// Calculo do Terceiro Campo
_cCampo := ""
_cCampo := Subs(_cBarra,35,10)
// Calculo do digito do Terceiro Campo
DigitoLin(1)
_cLinhaD += Subs(_cCampo,1,5)+"."+Subs(_cCampo,6,5)+Alltrim(Str(_nDigito))

// Insere espaco
_cLinhaD += " "

// Calculo do Quarto Campo
_cCampo := ""
_cCampo := Subs(_cBarra,5,1)
_cLinhaD += _cCampo

// Insere espaco
_cLinhaD += " "

// Calculo do Quinto Campo
_cCampo := ""
_cCampo := Subs(_cBarra,6,4)+Subs(_cBarra,10,10)
_cLinhaD += _cCampo

Return(.T.)





Static Function DigitoLin (_nCnt)

Local _nI   := 1
Local _nAux := 0
Local _nInt := 0
_nDigito    := 0

For _nI := 1 to Len(_cCampo)
	
	_nAux := Val(Substr(_cCampo,_nI,1)) * _nCnt
	If _nAux >= 10
		_nAux:= (Val(Substr(Str(_nAux,2),1,1))+Val(Substr(Str(_nAux,2),2,1)))
	Endif
	
	_nCnt += 1
	If _nCnt > 2
		_nCnt := 1
	Endif
	_nDigito += _nAux
	
Next _nI

If (_nDigito%10) > 0
	_nInt    := Int(_nDigito/10) + 1
Else
	_nInt    := Int(_nDigito/10)
Endif

_nInt    := _nInt * 10
_nDigito := _nInt - _nDigito

Return()









/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BraMod11  ºAutor  ³Stanko              º Data ³  01/10/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Modelo 11 - Bradesco                                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function BraMod11(cData) //Modulo 11 com base 7

LOCAL L, D, P := 0
L := Len(cdata)
D := 0
P := 1
DV:= " "

While L > 0
	P := P + 1
	D := D + (Val(SubStr(cData, L, 1)) * P)
	If P = 7   //Volta para o inicio, ou seja comeca a multiplicar por 2,3,4...
		P := 1
	End
	L := L - 1
End

if D >=11
	_nResto := mod(D,11)  //Resto da Divisao
	//D := 11 - (mod(D,11)) // Diferenca 11 (-) Resto da Divisao
	D := 11 - _nResto
	DV:=STR(D)
endif //renato

If _nResto == 0
	DV := "0"
End
If _nResto == 1
	DV := "P"
End

Return(DV)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BraCodBar ºAutor  ³Stanko              º Data ³  01/10/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Codigo de Barras - Bradesco                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function BraCodBar()
Local _nAgen   := ""
Local _nCntCor := ""
Local _nI      := 0
Local Fator      := CTOD("07/10/1997")
/*
- Posicoes fixas padrao Banco Central
Posicao  Tam       Descricao
01 a 03   03   Codigo de Compensacao do Banco (237)
04 a 04   01   Codigo da Moeda (Real => 9, Outras => 0)
05 a 05   01   Digito verificador do codigo de barras
06 a 19   14   Valor Nominal do Documento sem ponto

- Campo Livre Padrao Bradesco
Posicao  Tam       Descricao
20 a 23   03   Agencia Cedente sem digito verificador
24 a 25   02   Carteira
25 A 36   11   Nosso Numero sem digito verificador
37 A 43   07   Conta Cedente sem digiro verificador
44 A 44   01   Zero
*/

// Monta numero da Agencia sem dv e com 4 caracteres
// Retira separador de digito se houver
For _nI := 1 To Len(_aTitulos[_nCont][05])
	If Subs(_aTitulos[_nCont][05],_nI,1) $ "0/1/2/3/4/5/6/7/8/9/"
		_nAgen += Subs(_aTitulos[_nCont][05],_nI,1)
	Endif
Next _nI
// retira o digito verificador
_nAgen := StrZero(Val(Subs(Alltrim(_nAgen),1,Len(_nAgen)-1)),4)

// Monta numero da Conta Corrente sem dv e com 7 caracteres
// Retira separador de digito se houver
For _nI := 1 To Len(_aTitulos[_nCont][16])
	If Subs(_aTitulos[_nCont][16],_nI,1) $ "0/1/2/3/4/5/6/7/8/9/"
		_nCntCor += Subs(_aTitulos[_nCont][16],_nI,1)
	Endif
Next _nI
// retira o digito verificador
_nCntCor := StrZero(Val(Subs(Alltrim(_nCntCor),1,Len(_nCntCor)-1)),7)

//_nCntCor := StrZero(Val(Subs(Alltrim(_nCntCor),1,Len(_nCntCor)-1)),7)

_cCampo := ""
// Pos 01 a 03 - Identificacao do Banco
_cCampo += "237"
// Pos 04 a 04 - Moeda
_cCampo += "9"
// Pos 06 a 09 - Fator de vencimento
_cCampo += Str((_aTitulos[_nCont][02] - Fator),4)
// Pos 10 a 19 - Valor
_cCampo += StrZero(Int(_aTitulos[_nCont][03]*100),10)
// Pos 20 a 23 - Agencia
_cCampo += _nAgen
// Pos 24 a 25 - Carteira
_cCampo += _aTitulos[_nCont][07]
// Pos 26 a 36 - Nosso Numero
_cCampo += Subs(_aTitulos[_nCont][04],1,11)
// Pos 37 a 43 - Conta do Cedente
_cCampo += _nCntCor
// Pos 44 a 44 - Zero
_cCampo += "0"
_cDigitbar := BraDg11()

// Monta codigo de barras com digito verificador
_cBarra := Subs(_cCampo,1,4)+_cDigitbar+Subs(_cCampo,5,43)

Return()




/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ BraDg11   º Autor ³ Stanko             º Data ³  23/08/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Calculo do Digito Verificador Codigo de Barras - MOD(11)   º±±
±±º          ³ Pesos (2 a 9)                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function BraDg11()

Local _nCnt   := 0
Local _nPeso  := 2
Local _nJ     := 1
Local _nResto := 0

For _nJ := Len(_cCampo) To 1 Step -1
	_nCnt  := _nCnt + Val(SUBSTR(_cCampo,_nJ,1))*_nPeso
	_nPeso :=_nPeso+1
	if _nPeso > 9
		_nPeso := 2
	endif
Next _nJ

_nResto:=(_ncnt%11)

_nResto:=11 - _nResto

if _nResto == 0 .or. _nResto==1 .or. _nResto > 9
	_nDigbar:='1'
else
	_nDigbar:=Str(_nResto,1)
endif

Return(_nDigbar)




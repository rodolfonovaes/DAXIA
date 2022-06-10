#include "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE  'totvs.ch' 
#DEFINE OPC 5

User Function DXAPIXML()
Return

WsRestful XMLNF Description "Lista de XML" Format APPLICATION_JSON
    WSDATA nf                   AS STRING   OPTIONAL
    WSDATA cgc                  AS STRING   OPTIONAL
	WsMethod GET Description "Retorna lista de XML" WsSyntax "/GET/{method}"
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
WSMETHOD GET WSRECEIVE  nf, cgc WSSERVICE XMLNF
    lRet := XMLNF( self )
Return( lRet )
 
Static Function XMLNF( oSelf )
    Local aXML  := {}
    Local cJsonCli      := ''
    Local oJsonCli      := JsonObject():New()
    Local cSearch       := ''
    Local cWhere        := " "
    Local nCount        := 0
    Local nStart        := 1
    Local nReg          := 0
    Local nAux          := 0
    Local cAliasSF2     := GetNextAlias()
    Local cJSONRet      := ''
    Local cFileCont     := ''
    Local cErrXml       := ''
    Local oFile
    

    Default oself:cgc       := ' '
    Default oself:nf        := ' '
 
    // Tratativas para realizar os filtros
    If !Empty(oself:cgc) //se tiver chave de busca no request
        cSearch := Upper( oself:cgc )
        cWhere += " AND SA1.A1_CGC = '" + cSearch + "'"        
    EndIf

    cWhere += " AND SF2.F2_DOC = '" + Alltrim(Upper( oself:nf )) + "' 
    cWhere := '%'+cWhere+'%' //monta a expressao where
 
    // Realiza a query para selecionar clientes
    BEGINSQL Alias cAliasSF2
        SELECT SA1.* , SF2.*
        FROM    %table:SF2% SF2
        INNER JOIN    %table:SA1% SA1 ON A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA
        WHERE   SA1.%NotDel% AND SF2.%NotDel%
        %exp:cWhere%
        ORDER BY F2_DOC
    ENDSQL
 
 
 
    //-------------------------------------------------------------------
    // Alimenta array de clientes
    //-------------------------------------------------------------------
    While ( cAliasSF2 )->( ! Eof() )
        cFilAnt := ( cAliasSF2 )->F2_FILIAL
        Opensm0(cempant+cfilant, .T.)
        Openfile(cempant+cfilant)

        nAux++
        cFileName   :=  '/XML_API/' + Alltrim(( cAliasSF2 )->A1_CGC)+'_' + Alltrim(( cAliasSF2 )->F2_DOC) + '.xml'
        cFilCont    := U_zSpedXML(( cAliasSF2 )->F2_DOC,( cAliasSF2 )->F2_SERIE, cFileName , .f. , @cErrXml)

        If empty(cErrXml)
            oFile := FwFileReader():New(cFileName)
            If (oFile:Open())
                cFile := oFile:FullRead() // EFETUA A LEITURA DO ARQUIVO

                // RETORNA O ARQUIVO PARA DOWNLOAD
                oself:SetHeader("Content-Disposition", "attachment; filename=" + cFileName)
                oself:SetResponse(cFile)           
            Else
                cJSONRet += '{'
                cJSONRet += '"status":"Erro na leitura do XML", ' + CRLF
                cJSONRet += '"mensagem": ' +  CRLF
                cJSONRet += '} ' + CRLF    
                SetRestFault(400, FwNoAccent(cJSONRet))                 
            EndIf
            aAdd( aXML , JsonObject():New() )
            aXML[nAux]['cgc']       := ( cAliasSF2 )->A1_CGC
            aXML[nAux]['nf']        := ( cAliasSF2 )->F2_DOC
            aXML[nAux]['xml']       := cFilCont
        Else
            cJSONRet += '{'
            cJSONRet += '"status":"Erro na geração do XML", ' + CRLF
            cJSONRet += '"mensagem": ' + cErrXml + CRLF
            cJSONRet += '} ' + CRLF    
            SetRestFault(400, FwNoAccent(cJSONRet))            
        EndIf
            
        ( cAliasSF2 )->( DBSkip() )
    End
    ( cAliasSF2 )->( DBCloseArea() )

    If Len(aXML) > 0
        oJsonCli['XMLNF'] := aXML
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
    cJsonCli:= FwJsonSerialize( oJsonCli )
 
    //-------------------------------------------------------------------
    // Elimina objeto da memoria
    //-------------------------------------------------------------------
    FreeObj(oJsonCli)
    //oself:SetResponse( cJsonCli ) //-- Seta resposta

Return .T.

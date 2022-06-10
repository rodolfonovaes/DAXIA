#include "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE  'totvs.ch' 
#include "Fileio.ch"
#DEFINE OPC 5

User Function DXAPILAU()
Return

WsRestful PDFLAU Description "Lista de PDF Laudo" Format APPLICATION_JSON
    WSDATA nf                   AS STRING   OPTIONAL
    WSDATA cgc                  AS STRING   OPTIONAL
	WsMethod GET Description "Retorna lista de PDF Laudo" WsSyntax "/GET/{method}"
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
WSMETHOD GET WSRECEIVE  nf, cgc WSSERVICE PDFLAU
    lRet := PDFLAU( self )
Return( lRet )
 
Static Function PDFLAU( oSelf )
    Local aPDF  := {}
    Local cJsonCli      := ''
    Local oJsonPDF      := JsonObject():New()
    Local cSearch       := ''
    Local cWhere        := " "
    Local nCount        := 0
    Local nStart        := 1
    Local nReg          := 0
    Local nAux          := 0
    Local cAliasSD2     := GetNextAlias()
    Local cJSONRet      := ''
    Local cFileCont     := ''
    Local cErrPDF       := ''
    Local oFile
    Local cFilCont      := ""
    Local aFiles        := {} // O array receberï¿½ os nomes dos arquivos e do diretï¿½rio
    Local aSizes        := {} // O array receberï¿½ os tamanhos dos arquivos e do diretorio          
    Local cResult       := ''
    Default oself:cgc       := ' '
    Default oself:nf        := ' '
 
    // Tratativas para realizar os filtros
    If !Empty(oself:cgc) //se tiver chave de busca no request
        cSearch := Upper( oself:cgc )
        cWhere += " AND SA1.A1_CGC = '" + cSearch + "'"        
    EndIf

    cWhere += " AND SD2.D2_DOC = '" + Alltrim(Upper( oself:nf )) + "' 
    cWhere := '%'+cWhere+'%' //monta a expressao where
 
    // Realiza a query para selecionar clientes
    BEGINSQL Alias cAliasSD2
        SELECT DISTINCT A1_CGC ,D2_FILIAL, D2_DOC , D2_SERIE , D2_LOTECTL , D2_ITEM
        FROM    %table:SD2% SD2
        INNER JOIN    %table:SA1% SA1 ON A1_COD = D2_CLIENTE AND A1_LOJA = D2_LOJA
        WHERE   SA1.%NotDel% AND SD2.%NotDel%
        %exp:cWhere%
        ORDER BY D2_DOC
    ENDSQL
 
 
    conout('query PDF ' + getlastquery()[2])
    //-------------------------------------------------------------------
    // Alimenta array de clientes
    //-------------------------------------------------------------------
    While ( cAliasSD2 )->( ! Eof() )
        cFilAnt := ( cAliasSD2 )->D2_FILIAL
        Opensm0(cempant+cfilant, .T.)
        Openfile(cempant+cfilant)

        nAux++
        cResult := U_DAXR050( { (cAliasSD2)->D2_DOC, (cAliasSD2)->D2_SERIE, (cAliasSD2)->D2_LOTECTL, (cAliasSD2)->D2_ITEM }, .T. )
        cFileName := ALLTRIM((cAliasSD2)->D2_DOC)+"_"+ALLTRIM((cAliasSD2)->D2_ITEM)+"_"+ALLTRIM((cAliasSD2)->D2_LOTECTL) + ".pdf"
        IF  SUBSTR( cResult, 1, 5 ) == "ERRO:"
            cJSONRet += '{'
            cJSONRet += '"status":"Erro ao gerar o laudo", ' + CRLF
            cJSONRet += '"mensagem":  "' + cResult + CRLF
            cJSONRet += '} ' + CRLF    
            SetRestFault(400, FwNoAccent(cJSONRet))
        ELSE        
        /*  oFile := FwFileReader():New('/DANFE_API/' + cFileName)
            If (oFile:Open())
                cFile := oFile:FullRead() // EFETUA A LEITURA DO ARQUIVO

                // RETORNA O ARQUIVO PARA DOWNLOAD
                //oself:SetHeader("Content-Disposition", "attachment; filename=" +'/DANFE_API/' + cFileName)
                oself:SetHeader("Content-Disposition", "attachment; filename="+Alltrim('/DANFE_API/'+cFileName) )
                oself:SetContentType("application/pdf") 
                oself:SetResponse(cFile)           
            Else
                cJSONRet += '{'
                cJSONRet += '"status":"Erro na leitura do PDF", ' + CRLF
                cJSONRet += '"mensagem": ' +  CRLF
                cJSONRet += '} ' + CRLF    
                SetRestFault(400, FwNoAccent(cJSONRet))                 
            EndIf*/

            //Transformo em base64 o arquivo
            ADir('\LAUDOS_DAXIA\' + cFileName, aFiles, aSizes)//Verifica o tamanho do arquivo, parï¿½metro exigido na FRead.

            If Len(aFiles) == 0
                //Alert('Não foi gerado o arquivo PDF!')
                Return
            EndIF

            nHandle := fopen('\LAUDOS_DAXIA\' + cFileName , FO_READWRITE + FO_SHARED )
            cString := ""
            FRead( nHandle, cString, aSizes[1] ) //Carrega na variï¿½vel cString, a string ASCII do arquivo.

            cFilCont := Encode64(cString) //Converte o arquivo para BASE64

            fclose(nHandle) 

            aAdd( aPDF , JsonObject():New() )
            aPDF[nAux]['cgc']       := ( cAliasSD2 )->A1_CGC
            aPDF[nAux]['nf']        := ( cAliasSD2 )->D2_DOC
            aPDF[nAux]['pdflaudo']       := cFilCont
        EndIf
            
        ( cAliasSD2 )->( DBSkip() )
    End
    ( cAliasSD2 )->( DBCloseArea() )

    If Len(aPDF) > 0
        oJsonPDF['PDFLAU'] := aPDF
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

Return .T.

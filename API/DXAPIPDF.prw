#include "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE  'totvs.ch' 
#include "Fileio.ch"
#DEFINE OPC 5

User Function DXAPIPDF()
Return

WsRestful PDFNF Description "Lista de PDF" Format APPLICATION_JSON
    WSDATA nf                   AS STRING   OPTIONAL
    WSDATA cgc                  AS STRING   OPTIONAL
	WsMethod GET Description "Retorna lista de PDF NF" WsSyntax "/GET/{method}"
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
WSMETHOD GET WSRECEIVE  nf, cgc WSSERVICE PDFNF
    lRet := PDFNF( self )
Return( lRet )
 
Static Function PDFNF( oSelf )
    Local aPDF  := {}
    Local cJsonCli      := ''
    Local oJsonPDF      := JsonObject():New()
    Local cSearch       := ''
    Local cWhere        := " "
    Local nCount        := 0
    Local nStart        := 1
    Local nReg          := 0
    Local nAux          := 0
    Local cAliasSF2     := GetNextAlias()
    Local cJSONRet      := ''
    Local cFileCont     := ''
    Local cErrPDF       := ''
    Local oFile
    Local cFilCont      := ""
    Local aFiles      := {} // O array receberï¿½ os nomes dos arquivos e do diretï¿½rio
    Local aSizes      := {} // O array receberï¿½ os tamanhos dos arquivos e do diretorio          

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
 
 
    conout('query PDF ' + getlastquery()[2])
    //-------------------------------------------------------------------
    // Alimenta array de clientes
    //-------------------------------------------------------------------
    While ( cAliasSF2 )->( ! Eof() )
        cFilAnt := ( cAliasSF2 )->F2_FILIAL
        Opensm0(cempant+cfilant, .T.)
        Openfile(cempant+cfilant)

        nAux++
        cFileName   :=  Alltrim(( cAliasSF2 )->A1_CGC)+'_' + Alltrim(( cAliasSF2 )->F2_DOC) + '.pdf'
        U_zGerDanfe(( cAliasSF2 )->F2_DOC,( cAliasSF2 )->F2_SERIE,'\DANFE_API\', cFileName )

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
        ADir('\DANFE_API\' + cFileName, aFiles, aSizes)//Verifica o tamanho do arquivo, parï¿½metro exigido na FRead.

        If Len(aFiles) == 0
            //Alert('Não foi gerado o arquivo PDF!')
            Return
        EndIF

        nHandle := fopen('\DANFE_API\' + cFileName , FO_READWRITE + FO_SHARED )
        cString := ""
        FRead( nHandle, cString, aSizes[1] ) //Carrega na variï¿½vel cString, a string ASCII do arquivo.

        cFilCont := Encode64(cString) //Converte o arquivo para BASE64

        fclose(nHandle) 

        aAdd( aPDF , JsonObject():New() )
        aPDF[nAux]['cgc']       := ( cAliasSF2 )->A1_CGC
        aPDF[nAux]['nf']        := ( cAliasSF2 )->F2_DOC
        aPDF[nAux]['pdf']       := cFilCont
            
        ( cAliasSF2 )->( DBSkip() )
    End
    ( cAliasSF2 )->( DBCloseArea() )

    If Len(aPDF) > 0
        oJsonPDF['PDFNF'] := aPDF
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

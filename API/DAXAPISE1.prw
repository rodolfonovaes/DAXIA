#include "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE  'totvs.ch' 
#DEFINE OPC 5

User Function DAXAPISE1()
Return

WsRestful PosFinanceira Description "Lista de Posição Financeira" Format APPLICATION_JSON
    WSDATA page                     AS INTEGER  OPTIONAL
    WSDATA pageSize                 AS INTEGER  OPTIONAL
    WSDATA nfIni                    AS STRING   OPTIONAL
    WSDATA nFFim                    AS STRING   OPTIONAL
    WSDATA emissaoIni               AS STRING   OPTIONAL
    WSDATA emissaoFim               AS STRING   OPTIONAL    
    WSDATA vencIni                  AS STRING   OPTIONAL
    WSDATA vencFim                  AS STRING   OPTIONAL      
    WSDATA pedIni                   AS STRING   OPTIONAL
    WSDATA pedFim                   AS STRING   OPTIONAL      
    WSDATA bolIni                   AS STRING   OPTIONAL
    WSDATA bolFim                   AS STRING   OPTIONAL    
    WSDATA status                   AS STRING   OPTIONAL
    WSDATA loja                     AS STRING   OPTIONAL
    WSDATA cgc                      AS STRING   OPTIONAL
	WsMethod GET Description "Retorna lista de Posição Financeira" WsSyntax "/GET/{method}"
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
WSMETHOD GET WSRECEIVE  page, pageSize, nfIni,nFFim,emissaoIni,emissaoFim,vencIni,vencFim,pedIni,pedFim,bolIni,bolFim,status,loja,cgc WSSERVICE PosFinanceira
    lRet := PosFin( self )
Return( lRet )
 
Static Function PosFin( oSelf )
    Local aListFin  := {}
    Local cJsonCli      := ''
    Local oJsonCli  := JsonObject():New()
    Local cSearch       := ''
    Local cWhere        := " "
    Local nCount        := 0
    Local nStart        := 1
    Local nReg          := 0
    Local nAux          := 0
    Local cAliasSE1     := GetNextAlias()
    Local cJSONRet      := ''

    Default oself:page      := 1
    Default oself:pageSize  := 20
    Default oself:nfIni     := ' '
    Default oself:nFFim     := 'ZZZZZ'
    Default oself:emissaoIni:= Dtos(dDataBase)
    Default oself:emissaoFim:= Dtos(dDataBase)
    Default oself:vencIni   := Dtos(dDataBase)
    Default oself:vencFim   := Dtos(dDataBase)
    Default oself:pedIni    := '  '
    Default oself:pedFim    := 'ZZZZZZZZ'
    Default oself:bolIni    := '  '
    Default oself:bolFim    := 'ZZZZZZZ'
    Default oself:status    := ''
    Default oself:loja      := ''
    Default oself:cgc       := ''
 
    // Tratativas para realizar os filtros
    If !Empty(oself:cgc) //se tiver chave de busca no request
        cSearch := Upper( oself:cgc )
        cWhere += " AND SA1.A1_CGC LIKE '" + cSearch + "%'"        
    EndIf


    cWhere += " AND SE1.E1_NUM BETWEEN '" + Alltrim(Upper( oself:nfIni )) + "' AND  '"  + Alltrim(Upper( oself:nfFim )) + "' "

    cWhere += " AND SE1.E1_EMISSAO BETWEEN '" + Alltrim(Upper( oself:emissaoIni )) + "' AND  '"  + Alltrim(Upper( oself:emissaoFim )) + "' "

    cWhere += " AND SE1.E1_VENCTO BETWEEN '" + Alltrim(Upper( oself:vencIni )) + "' AND  '"  + Alltrim(Upper( oself:vencFim )) + "' "            

    cWhere += " AND SE1.E1_PEDIDO BETWEEN '" + Alltrim(Upper( oself:pedIni )) + "' AND  '"  + Alltrim(Upper( oself:pedFim )) + "' "                        

    cWhere += " AND SE1.E1_NUMBOL BETWEEN '" + Alltrim(Upper( oself:bolIni )) + "' AND  '"  + Alltrim(Upper( oself:bolFim )) + "' "                                    

    If !empty(oself:loja)
        cWhere += " AND SA1.A1_LOJA IN (" + Alltrim(Upper( oself:loja ))   + ") "  
    EndIf                                          
 
    If !empty(oself:status)
        Do Case
            Case oself:status == 'B' //BAIXADO E RELIQUIDADO
                cWhere += " AND SE1.E1_STATUS = 'B' "  
            Case oself:status == 'A' //TITULO EM ABERTO E NÃO VENCIDO 
                cWhere += " AND SE1.E1_STATUS = 'A' AND SE1.E1_VENCREA >= '" + Dtos(dDatabase) + "' "
            Case oself:status == 'V' //TITULO VENCIDO EM ATÉ 5 DIAS CORRIDOS
                cWhere += " AND SE1.E1_STATUS = 'A' AND DATEDIFF(day, SUBSTRING(SE1.E1_VENCREA,1,4)+'-'+SUBSTRING(SE1.E1_VENCREA,5,2)+'-'+SUBSTRING(SE1.E1_VENCREA,7,2),'" + SUBSTR(DTOS(dDatabase),1,4) +"-"+ SUBSTR(DTOS(dDatabase),5,2) + "-"+ SUBSTR(DTOS(dDatabase),7,2) +"' )  <= 5  AND SE1.E1_VENCREA < '" + Dtos(dDatabase) + "' "
            Case oself:status == 'C' //TITULO EM VENCIDO ACIMA DE 5 DIAS DA DATA DE VENCIMENTO
                cWhere += " AND SE1.E1_STATUS = 'A' AND DATEDIFF(day, SUBSTRING(SE1.E1_VENCREA,1,4)+'-'+SUBSTRING(SE1.E1_VENCREA,5,2)+'-'+SUBSTRING(SE1.E1_VENCREA,7,2),'" + SUBSTR(DTOS(dDatabase),1,4) +"-"+ SUBSTR(DTOS(dDatabase),5,2) + "-"+ SUBSTR(DTOS(dDatabase),7,2) +"' )  > 5   AND SE1.E1_VENCREA < '" + Dtos(dDatabase) + "' "
        EndCase    
        
    EndIf 

 
    cWhere := '%'+cWhere+'%' //monta a expressao where
 
    // Realiza a query para selecionar clientes
    BEGINSQL Alias cAliasSE1
        SELECT SA1.* , SE1.*,
            (SELECT COUNT(*)
            FROM    %table:SE1% SE1P
            WHERE   SE1P.%NotDel%
            AND SE1P.E1_NUM = SE1.E1_NUM
            AND SE1P.E1_PREFIXO = SE1.E1_PREFIXO
            AND SE1P.E1_CLIENTE = SE1.E1_CLIENTE
            AND SE1P.E1_LOJA = SE1.E1_LOJA) AS NUMPARC
        FROM    %table:SE1% SE1
        INNER JOIN    %table:SA1% SA1 ON A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA
        WHERE   SA1.%NotDel% AND SE1.%NotDel% 
        %exp:cWhere%
        ORDER BY E1_NUM
    ENDSQL
 
    If ( cAliasSE1 )->( ! Eof() )
        //-------------------------------------------------------------------
        // Identifica a quantidade de registro no alias temporário
        //-------------------------------------------------------------------
        COUNT TO nRecord
        //-------------------------------------------------------------------
        // nStart -> primeiro registro da pagina
        // nReg -> numero de registros do inicio da pagina ao fim do arquivo
        //-------------------------------------------------------------------
        If oself:page > 1
            nStart := ( ( oself:page - 1 ) * oself:pageSize ) + 1
            nReg := nRecord - nStart + 1
        Else
            nReg := nRecord
        EndIf
 
        //-------------------------------------------------------------------
        // Posiciona no primeiro registro.
        //-------------------------------------------------------------------
        ( cAliasSE1 )->( DBGoTop() )
 
        //-------------------------------------------------------------------
        // Valida a exitencia de mais paginas
        //-------------------------------------------------------------------
        If nReg  > oself:pageSize
            oJsonCli['hasNext'] := .T.
        Else
            oJsonCli['hasNext'] := .F.
        EndIf
    Else
        //-------------------------------------------------------------------
        // Nao encontrou registros
        //-------------------------------------------------------------------
        oJsonCli['hasNext'] := .F.
    EndIf
 
    //-------------------------------------------------------------------
    // Alimenta array de clientes
    //-------------------------------------------------------------------
    While ( cAliasSE1 )->( ! Eof() )
        nCount++
        If nCount >= nStart
            nAux++
        
            aAdd( aListFin , JsonObject():New() )
            aListFin[nAux]['filial']    := ( cAliasSE1 )->E1_FILIAL
            aListFin[nAux]['prefixo']   := ( cAliasSE1 )->E1_PREFIXO
            aListFin[nAux]['num']       := ( cAliasSE1 )->E1_NUM
            aListFin[nAux]['parcela']   := IIF(!empty(( cAliasSE1 )->E1_PARCELA),Alltrim(( cAliasSE1 )->E1_PARCELA) + '/' + Alltrim(Str(( cAliasSE1 )->NUMPARC)),'')
            aListFin[nAux]['tipo']      := ( cAliasSE1 )->E1_TIPO
            aListFin[nAux]['portador']  := ( cAliasSE1 )->E1_PORTADO
            aListFin[nAux]['cliente']   := ( cAliasSE1 )->E1_CLIENTE
            aListFin[nAux]['loja']      := ( cAliasSE1 )->E1_LOJA
            aListFin[nAux]['nomcli']    := ( cAliasSE1 )->E1_NOMCLI
            aListFin[nAux]['emissao']   := DTOC(STOD(( cAliasSE1 )->E1_EMISSAO))
            aListFin[nAux]['vencrea']   := DTOC(STOD(( cAliasSE1 )->E1_VENCREA))
            aListFin[nAux]['vencto']    := DTOC(STOD(( cAliasSE1 )->E1_VENCTO))
            aListFin[nAux]['valor']     := Transform(( cAliasSE1 )->E1_VALOR,PesqPict("SE1","E1_VALOR"))
            aListFin[nAux]['numbco']    := ( cAliasSE1 )->E1_NUMBCO
            aListFin[nAux]['saldo']     := Transform(( cAliasSE1 )->E1_SALDO,PesqPict("SE1","E1_VALOR"))
            aListFin[nAux]['multa']     := Transform(( cAliasSE1 )->E1_MULTA,PesqPict("SE1","E1_VALOR"))
            aListFin[nAux]['juros']     := Transform(( cAliasSE1 )->E1_JUROS,PesqPict("SE1","E1_JUROS"))
            aListFin[nAux]['vencori']   := DTOC(STOD(( cAliasSE1 )->E1_VENCORI))
            aListFin[nAux]['valjur']    := Transform(( cAliasSE1 )->E1_VALJUR,PesqPict("SE1","E1_VALJUR"))
            aListFin[nAux]['porcjur']   := Transform(( cAliasSE1 )->E1_PORCJUR,PesqPict("SE1","E1_PORCJUR"))
            aListFin[nAux]['pedido']    := ( cAliasSE1 )->E1_PEDIDO
            aListFin[nAux]['boleto']    := IIF(Empty(( cAliasSE1 )->E1_NUMBCO), .F. , .T.)
            
            Do Case
                Case ( cAliasSE1 )->E1_STATUS == 'B'
                    aListFin[nAux]['status']   := 'PAGO'    
                Case ( cAliasSE1 )->E1_STATUS == 'A' .And. STOD(( cAliasSE1 )->E1_VENCREA) >= dDataBase
                    aListFin[nAux]['status']   := 'ABERTO'    
                Case ( cAliasSE1 )->E1_STATUS == 'A' .And. DateDiffDay(STOD(( cAliasSE1 )->E1_VENCREA),dDataBase) <= 5
                    aListFin[nAux]['status']   := 'VENCIDO'    
                Case ( cAliasSE1 )->E1_STATUS == 'A' .And. DateDiffDay(STOD(( cAliasSE1 )->E1_VENCREA),dDataBase) > 5
                    aListFin[nAux]['status']   := 'CARTORIO'                        
            EndCase

            aListFin[nAux]['codbar']    := ( cAliasSE1 )->E1_CODBAR
            aListFin[nAux]['numbol']    := ( cAliasSE1 )->E1_NUMBOL
            aListFin[nAux]['cgc']       := ( cAliasSE1 )->A1_CGC

            If Len(aListFin) >= oself:pageSize
                Exit
            EndIf
        EndIf
        ( cAliasSE1 )->( DBSkip() )
    End
    ( cAliasSE1 )->( DBCloseArea() )

    If Len(aListFin) > 0
        oJsonCli['posfin'] := aListFin
    Else
        cJSONRet += '{'
        cJSONRet += '"status":"sem resultados", ' + CRLF
        cJSONRet += '"mensagem": busca não retornou resultados "' + CRLF
        cJSONRet += '} ' + CRLF    
        SetRestFault(400, FwNoAccent(cJSONRet))
    EndIf
 
    //-------------------------------------------------------------------
    // Serializa objeto Json
    //-------------------------------------------------------------------
    cJsonCli:= FwJsonSerialize( oJsonCli )
 
    //-------------------------------------------------------------------
    // Elimina objeto da memoria
    //-------------------------------------------------------------------
    FreeObj(oJsonCli)
    oself:SetResponse( cJsonCli ) //-- Seta resposta
Return .T.

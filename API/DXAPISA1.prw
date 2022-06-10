#include "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE  'totvs.ch' 
#DEFINE OPC 5

User Function DAXAPISA1()
Return

WsRestful Cliente Description "Importacao de Clientes" Format APPLICATION_JSON
    WSDATA page                 AS INTEGER  OPTIONAL
    WSDATA pageSize             AS INTEGER  OPTIONAL
    WSDATA cgc           AS STRING   OPTIONAL
    WSDATA byId                 AS BOOLEAN  OPTIONAL
	WsMethod GET Description "Retorna lista dos Clientes" WsSyntax "/GET/{method}"
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
WSMETHOD GET WSRECEIVE cgc, page, pageSize WSSERVICE Cliente
    lRet := Customers( self )
Return( lRet )
 
Static Function Customers( oSelf )
    Local aListCli  := {}
    Local cJsonCli      := ''
    Local oJsonCli  := JsonObject():New()
    Local cSearch       := ''
    Local cWhere        := "AND SA1.A1_FILIAL = '"+xFilial('SA1')+"'"
    Local nCount        := 0
    Local nStart        := 1
    Local nReg          := 0
    Local nAux          := 0
    Local cAliasSA1     := GetNextAlias()
 
    Default oself:cgc     := ''
    Default oself:page      := 1
    Default oself:pageSize  := 20
    Default oself:byId      :=.F.
 
    // Tratativas para realizar os filtros
    If !Empty(oself:cgc) //se tiver chave de busca no request
        cSearch := Upper( oself:cgc )
        If oself:byId //se filtra somente por ID
            cWhere += " AND SA1.A1_CGC LIKE '" + cSearch + "%'"
        EndIf
    EndIf
 
    dbSelectArea('SA1')
    DbSetOrder(1)
    If SA1->( Columnpos('A1_MSBLQL') > 0 ) //verifica se o campo de controle de bloqueio existe, se sim filtra esse caso
        cWhere += " AND SA1.A1_MSBLQL <> '1'"
    EndIf
 
    cWhere := '%'+cWhere+'%' //monta a expressao where
 
    // Realiza a query para selecionar clientes
    BEGINSQL Alias cAliasSA1
        SELECT *
        FROM    %table:SA1% SA1
        WHERE   SA1.%NotDel%
        %exp:cWhere%
        ORDER BY A1_COD
    ENDSQL
 
    If ( cAliasSA1 )->( ! Eof() )
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
        ( cAliasSA1 )->( DBGoTop() )
 
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
    While ( cAliasSA1 )->( ! Eof() )
        nCount++
        If nCount >= nStart
            nAux++
            aAdd( aListCli , JsonObject():New() )
            aListCli[nAux]['codigo']    := ( cAliasSA1 )->A1_COD
            aListCli[nAux]['loja']      := ( cAliasSA1 )->A1_LOJA
            aListCli[nAux]['nome']      := Alltrim( EncodeUTF8( ( cAliasSA1 )->A1_NOME ) )
            aListCli[nAux]['nreduz']    := Alltrim( EncodeUTF8( ( cAliasSA1 )->A1_NREDUZ ) )
            aListCli[nAux]['municipio'] := Alltrim( EncodeUTF8( ( cAliasSA1 )->A1_MUN ) )
            aListCli[nAux]['email']     := Alltrim( EncodeUTF8( ( cAliasSA1 )->A1_EMAIL ) )
            aListCli[nAux]['xmailld']   := Alltrim( EncodeUTF8( ( cAliasSA1 )->A1_XMAILLD ) )
            aListCli[nAux]['inscri']    := Alltrim( EncodeUTF8( ( cAliasSA1 )->A1_INSCR ) )
            aListCli[nAux]['grpven']    := Alltrim( EncodeUTF8( ( cAliasSA1 )->A1_GRPVEN ) )
            aListCli[nAux]['cgc']    := Alltrim( EncodeUTF8( ( cAliasSA1 )->A1_CGC ) )
            
            If Len(aListCli) >= oself:pageSize
                Exit
            EndIf
        EndIf
        ( cAliasSA1 )->( DBSkip() )
    End
    ( cAliasSA1 )->( DBCloseArea() )
    oJsonCli['clients'] := aListCli
 
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

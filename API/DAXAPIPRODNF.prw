#include "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE  'totvs.ch' 
#DEFINE OPC 5

User Function DAXAPIPRODNF()
Return

WsRestful ProdNF Description "Lista de Produtos" Format APPLICATION_JSON
	WSDATA nota As String
	WSDATA filial As String
	WsMethod GET Description "Retorna lista dos produtos" WsSyntax "/GET/{method}"
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
WsMethod GET WSRECEIVE nota,  WSSERVICE ProdNF

Local _aArea 	 	:= GetArea()
Local _cQuery 		:= ""
Local _cNextAlias 	:= GetNextAlias()
Local _cXml 		:= ''
Local _cnota		:= Iif(ValType(Self:nota) <> 'U',Self:nota,'')
Local _cfilial		:= Iif(ValType(Self:filial) <> 'U',Self:filial,'')
Local cJsonRet		:= ''

::SetContentType('application/xml')

_cQuery := " SELECT * " + CRLF
_cQuery += " FROM " + RetSqlName("SD2") + " SD2 " + CRLF
_cQuery += " WHERE " + CRLF
_cQuery += " SD2.D2_FILIAL = '" + xFilial('SD2',_cfilial) + "' " + CRLF
If !Empty(_cnota)
	_cQuery += " AND SD2.D2_DOC = '" + AllTrim(_cnota) + "' " + CRLF
EndIf
_cQuery += " AND SD2.D_E_L_E_T_ = '' " + CRLF
_cQuery := ChangeQuery(_cQuery)

If Select(_cNextAlias) > 0
	dbSelectArea(_cNextAlias)
	dbCloseArea()
EndIf

dbUseArea(.T.,'TOPCONN',TCGENQRY(,,_cQuery),_cNextAlias,.T.,.T.)
dbSelectArea(_cNextAlias)
If !(_cNextAlias)->(Eof()) .And. !(_cNextAlias)->(Bof())
	
	cJsonRet := '{'
	cJsonRet += '	"ProdutosList" : [ '

	While !(_cNextAlias)->(Eof())
		cJsonRet +=	'{'
		cJsonRet += '"DocNF": "'      + AllTrim((_cNextAlias)->D2_DOC) + '",'
        cJsonRet += '"CliNF": "'      + AllTrim((_cNextAlias)->D2_CLIENTE) + '",'
        cJsonRet += '"LojaNF": "'      + AllTrim((_cNextAlias)->D2_LOJA) + '",'
		cJsonRet += '"ProdNF": "' + AllTrim(STRTRAN((_cNextAlias)->D2_COD,'"',''))   + '",'
		cJsonRet += ' },'
		(_cNextAlias)->(dbSkip())
	EndDo

	cJsonRet := substr( Alltrim(cJsonRet) , 1 , len(Alltrim(cJsonRet)) -1 )
	cJsonRet += '	]'
	cJsonRet += '}'
	cJsonRet := StrTran(cJsonRet,Chr(129),"")
	cJsonRet := StrTran(cJsonRet,Chr(141),"")
	cJsonRet := StrTran(cJsonRet,Chr(143),"")
	cJsonRet := StrTran(cJsonRet,Chr(144),"")
	cJsonRet := StrTran(cJsonRet,Chr(157),"")
	cJsonRet := StrTran(cJsonRet,Chr(9),"")
	cJsonRet := StrTran(cJsonRet,Chr(10),"")
	cJsonRet := StrTran(cJsonRet,Chr(13),"")
	conout("WSREST - " + cJsonRet)
	cJsonRet := FwCutOff(cJsonRet,.F.)		
	::SetResponse(FwNoAccent(cJsonRet))	

	//Conout(_cXml)
Else
	cJsonRet := '{'
	cJsonRet += '	"ProdutosList" : [ '
	cJsonRet += '	"VAZIO" '
	cJsonRet += '	]'
	cJsonRet += '}'	
	::SetResponse(FwNoAccent(cJsonRet))	
EndIf

RestArea(_aArea)

Return(.T.)

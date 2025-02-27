#INCLUDE "PROTHEUS.CH"

/*
Descri��o: O ponto de entrada 'A680WMSO', permite informar o c�digo do servi�o, endere�o e estrutura f�sica
quando o produto a ser produzido possuir integra��o com o m�dulo WMS.
Ao passar essas informa��es por interm�dio do PE, automaticamente ser� inibida a visualiza��o da tela 
que solicita a digita��o dessas informa��es.
Localiza��o: Executado na fun��o A680GeraD3( ), que � respons�vel por realizar as atualiza��es do apontamento
de produ��o.
Programa Fonte: MATA680.PRX
Retorno: aRet(vetor)

Retorno esperado do RDMAKE: 
Array[1] = Servi�o
Array[2] = Endere�o
Array[3] = Estrutura
*/

User Function A680WMSO()

Local _cProduto   := PARAMIXB[1]
Local _cOp        := PARAMIXB[2]
Local _cIdMov     := PARAMIXB[3]
Local _aRet       := {}

//-- If Trim(Upper(_cProduto))=='PROD-WMS'

//-- Customiza��es do Cliente   

AAdd( _aRet, PadR('005',TamSX3('DB_SERVIC')[1]))

//-- Servi�o   

//-- AAdd( _aRet, PadR('Q1',TamSX3('DB_LOCALIZ')[1]))
AAdd( _aRet, PadR('PRODUCAO',TamSX3('DB_LOCALIZ')[1]))

//-- Endere�o   

//-- AAdd( _aRet, PadR('000003',TamSX3('DB_ESTFIS')[1]))
AAdd( _aRet, PadR('000006',TamSX3('DB_ESTFIS')[1]))

//-- Estrutura F�sica

//-- EndIf

Return(_aRet)


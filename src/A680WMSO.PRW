#INCLUDE "PROTHEUS.CH"

/*
Descrição: O ponto de entrada 'A680WMSO', permite informar o código do serviço, endereço e estrutura física
quando o produto a ser produzido possuir integração com o módulo WMS.
Ao passar essas informações por intermédio do PE, automaticamente será inibida a visualização da tela 
que solicita a digitação dessas informações.
Localização: Executado na função A680GeraD3( ), que é responsável por realizar as atualizações do apontamento
de produção.
Programa Fonte: MATA680.PRX
Retorno: aRet(vetor)

Retorno esperado do RDMAKE: 
Array[1] = Serviço
Array[2] = Endereço
Array[3] = Estrutura
*/

User Function A680WMSO()

Local _cProduto   := PARAMIXB[1]
Local _cOp        := PARAMIXB[2]
Local _cIdMov     := PARAMIXB[3]
Local _aRet       := {}

//-- If Trim(Upper(_cProduto))=='PROD-WMS'

//-- Customizações do Cliente   

AAdd( _aRet, PadR('005',TamSX3('DB_SERVIC')[1]))

//-- Serviço   

//-- AAdd( _aRet, PadR('Q1',TamSX3('DB_LOCALIZ')[1]))
AAdd( _aRet, PadR('PRODUCAO',TamSX3('DB_LOCALIZ')[1]))

//-- Endereço   

//-- AAdd( _aRet, PadR('000003',TamSX3('DB_ESTFIS')[1]))
AAdd( _aRet, PadR('000006',TamSX3('DB_ESTFIS')[1]))

//-- Estrutura Física

//-- EndIf

Return(_aRet)


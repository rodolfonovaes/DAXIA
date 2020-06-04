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

Local cSrv		 := SuperGetMV('ES_SERVCON',.T.,'003',cFilAnt)
Local cSrvPrd    := SuperGetMV('ES_SERVPRD',.T.,'030',cFilAnt)

//-- If Trim(Upper(_cProduto))=='PROD-WMS'

//-- Customizações do Cliente   
//-- Serviço 

SB1->(DBSetOrder(1))
If SB1->(DBSeek(xFilial('SB1') + _cProduto))
    If SB1->B1_TIPO == 'PI'
        AAdd( _aRet, PadR(cSrvPrd,TamSX3('DB_SERVIC')[1]))
    Else
        AAdd( _aRet, PadR(cSrv,TamSX3('DB_SERVIC')[1]))
    EndIf
Else
    AAdd( _aRet, PadR(cSrv,TamSX3('DB_SERVIC')[1]))
EndIf
/*    
SB5->(DbSetOrder(1))
If SB5->(DbSeek(xFilial('SB5') + _cProduto))
    If !empty(SB5->B5_SERVENT)
        AAdd ( _aRet, PadR(SB5->B5_SERVENT,TamSX3('DB_SERVIC')[1]))
    Else
        AAdd( _aRet, PadR(cSrv,TamSX3('DB_SERVIC')[1]))
    EndIf
Else
    AAdd( _aRet, PadR(cSrv,TamSX3('DB_SERVIC')[1]))
EndIf
*/
//-- Endereço  
//-- AAdd( _aRet, PadR('Q1',TamSX3('DB_LOCALIZ')[1]))
AAdd( _aRet, PadR('WIP',TamSX3('DB_LOCALIZ')[1]))

//-- Estrutura Física
//-- AAdd( _aRet, PadR('000003',TamSX3('DB_ESTFIS')[1]))
AAdd( _aRet, PadR('000006',TamSX3('DB_ESTFIS')[1]))

//-- EndIf

Return(_aRet)


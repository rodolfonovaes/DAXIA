#Include 'PROTHEUS.CH'
#Include 'RWMAKE.CH'
//------------------------------------------------------------------------------------//
//Empresa...: TIB - IBIRAPUERA
//Projeto...: Ponto de Entrada - Operação após Liberar / Rejeitar WMS
//Funcao....: A175GRV
//Autor.....: DANIEL EVANDRO BUSO
//Data......: 10/10/2019
//Uso.......: Gravar informações nos campos da tabela SB8 - B8_NFABRIC / B8_XPAISOR
//Versao....: 12
//------------------------------------------------------------------------------------//
User Function A175GRV()

Local _cQUpd   := ""
Local _nStatus := 0

	  _cQUpd := "UPDATE "+RetSqlName("SB8")+" SET B8_NFABRIC=SB8.B8_NFABRIC, B8_XPAISOR=SB8.B8_XPAISOR"
	  _cQUpd += "  FROM "+RetSqlName("SB8")+" A "
	  _cQUpd += " INNER JOIN "+RetSqlName("SB8")+" SB8 ON SB8.B8_FILIAL=A.B8_FILIAL "
	  _cQUpd += "   AND SB8.B8_PRODUTO=A.B8_PRODUTO AND SB8.B8_LOCAL=A.B8_LOCAL "
	  _cQUpd += "   AND SB8.D_E_L_E_T_<> '*' AND SB8.B8_NFABRIC <> '' AND SB8.B8_XPAISOR <> ''"
	  _cQUpd += " WHERE SB8.B8_FILIAL  = '" + SB8->B8_FILIAL  +"'"
	  _cQUpd += "   AND SB8.B8_PRODUTO = '" + SB8->B8_PRODUTO +"'"
	  _cQUpd += "   AND SB8.B8_LOTECTL = '" + SB8->B8_LOTECTL +"'"
	  _cQUpd += "   AND A.D_E_L_E_T_  <> '*' "
	  _cQUpd += "   AND A.B8_XFABRIC   = ''  "
	  _nStatus := TcSqlExec(_cQUpd)
	
	  If (_nStatus < 0)
	     Alert('Erro no update')
	  EndIf
	  
Return(Nil)
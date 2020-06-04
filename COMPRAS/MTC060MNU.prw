#Include 'PROTHEUS.CH'
#Include 'RWMAKE.CH'
//------------------------------------------------------------------------------------//
//Empresa...: DAXIA                                                                   //
//Autor.....: TOTVS IBIRAPUERA                                                        //
//Data......: 16/01/2020                                                              //
//Uso.......: Gravar descrição do produto na tabela SB8                               // 
//Chamado...: Ponto de Entrada na rotina de Consulta Saldos por Lote - MATC060        //
//------------------------------------------------------------------------------------//
User Function MTC060MNU
Local cQuery
Local nRet

cQuery := "UPDATE SB8010 SET B8_XDPROD = SB1.B1_DESC FROM SB8010 SB8 "
cQuery += "JOIN SB1010 AS SB1 ON SB1.B1_COD = SB8.B8_PRODUTO AND SB1.D_E_L_E_T_ = ' ' "
cQuery += "WHERE SB8.B8_XDPROD < '0' AND SB8.D_E_L_E_T_ = ' ' "
nRet   := TCSQLEXEC(cQuery)

Return
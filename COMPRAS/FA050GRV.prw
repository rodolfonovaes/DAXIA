#INCLUDE "rwmake.ch"      //Abertura de biblioteca
#INCLUDE "topconn.ch"

/*
FA050GRV
Ponto de entrada na inclusao do titulos a pagar onde irá gravar o historico do titulo PAI (E2_HIST) no histórico do(s) título(s) FILHOS (E2_HIST).

@author 	Rossana Barbosa
@since		10/08/2019
@version 	1.0
*/

User Function FA050GRV

	Local 	a_AreaATU   := GetArea()
	Local 	a_AreaSE2   := SE2->(GetArea())
	Local 	c_UpdQuery  := ""
	Private c_Hist      := ""
	Private c_Prefixo   := ""
	Private c_Num       := ""
	Private c_Parcela   := ""
	Private c_Tipo      := ""
	Private c_Fornece   := ""
	Private c_Loja      := ""

	c_Hist := SE2->E2_HIST  		//Agregando o conteudo do campo posicionado E2_CC do titulo principal(pai) para a variavel _cCC

	//Atualiza com o mesmo cento de custo do PAI os titulos FILHOS (Taxas - Retencoes dos Impostos)
	c_Prefixo	:= SE2->E2_PREFIXO	
	c_Num		:= SE2->E2_NUM     
	c_Parcela	:= SE2->E2_PARCELA
	c_Tipo		:= SE2->E2_TIPO
	c_Fornece	:= SE2->E2_FORNECE
	c_Loja		:= SE2->E2_LOJA

	c_Chave := c_Prefixo+c_Num+c_Parcela+c_Tipo+c_Fornece+c_Loja  

	DbSelectArea("SE2")
	DbSetOrder(1)
	DbGoTop()
	c_UpdQuery := " UPDATE " + RetSqlName("SE2") + " SET E2_HIST = '" + c_Hist + "'"
	c_UpdQuery += " WHERE D_E_L_E_T_ = '' "
	c_UpdQuery += " AND E2_PREFIXO = '" + c_Prefixo + "'"
	c_UpdQuery += " AND E2_NUM = '" + c_Num + "'"            
	c_UpdQuery += " AND E2_HIST = '' "
	c_UpdQuery += " AND E2_TITPAI = '" + c_Chave + "'"

	TcSqlExec(c_UpdQuery)
	
	RestArea(a_AreaATU)                
	RestArea(a_AreaSE2)

Return Nil

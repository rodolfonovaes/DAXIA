#include "totvs.ch" 

/*/{Protheus.doc} MT410ROD
Ponto de entrada para maniplar valores do Rodape do Pedido de Venda

@author 	Rodolfo
@since 	29/10/2019
@return 	Nil
/*/

User Function MT410ROD()

Local nX			:=  0
Local nPosValor	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_VALOR" })
Local nPosQtd		:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_QTDVEN" })
Local nPosDel 	:= Len(aHeader) + 1
Local nPosTES 	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_TES" })
Local nPosBLQ	:= aScan(aHeader ,{|x| AllTrim(x[2]) == "C6_BLQ" })
Local nPosMoeda	:= aScan(aHeader ,{|x| AllTrim(x[2]) == "C6_XMOEDA" })

// Parametros recebidos no Ponto de Entrada
Private oObjPed	:= ParamIxb[1]
Private c410Cli	:= ParamIxb[2]
Private n410VlBru	:= ParamIxb[3]
Private n410Desc	:= ParamIxb[4]
Private n410VlLiq	:= ParamIxb[5]
Private nTotItens	:=	0		// Total dos itens com estoque para faturar

// Protecao para os campos que nao estao sendo utilizados 

  
// Avalia os itens com condicao de faturamento
// Incrimenta no rodape da Tela o valor logo apos o nome do cliente
If nPosMoeda > 0 //Tratamento para qdo acessar pelo pelo perfil vendedor que nao tem esse campo 
	For nX := 1 To Len(aCols)
		IF aCols[nX][nPosDel] == .F. //.And. aCols[nX][nPosBLQ] <> 'R'
			//nTotItens += aCols[nX][nPosValor]
			nTotItens += xMoeda(aCols[nX][nPosValor],Val(aCols[nX][nPosMoeda]),1,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2'))
		Endif	
	Next nX
EndIf
n410VlLiq := nTotItens
n410VlBru := nTotItens
// Prepara mensagem para o rodape

SA1->( dbSetOrder(1) )
If SA1->( MsSeek( xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI) ) 
	//c410Cli	:= "Tot Disp:  " + AllTrim( Transform(nTotItens,"@E 999,999,999.99") ) + "  " + Left(SA1->A1_NOME,40)
    c410Cli	:= Left(SA1->A1_NOME,40)
Endif

Eval( oObjPed, c410Cli, n410VlBru, n410Desc, n410VlLiq ) 

Return
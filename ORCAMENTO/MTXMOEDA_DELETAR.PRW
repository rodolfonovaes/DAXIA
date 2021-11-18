*********************************************************************************************************************
#Include 'Protheus.ch'

//Amorim - Ponto de entrada para considerar a taxa de data de emissão do documento de entrada e não a taxa do pedido de compra

Function MT103TXPC()
Local nRet := 0
Local nPosVal
Local nPosTot
Local nX
Local nRecSC7

nPosVal := AScan(aHeader,{|x| AllTrim(x[2]) == 'D1_VUNIT'})
nPosTot := AScan(aHeader,{|x| AllTrim(x[2]) == 'D1_TOTAL'})

nPosPC := AScan(aHeader,{|x| AllTrim(x[2]) == 'D1_PEDIDO'})
nItemPc := AScan(aHeader,{|x| AllTrim(x[2]) == 'D1_ITEMPC'})

DbSelectArea("SM2")
// DbSeek(dDataBase,.T.)
DbSeek(DDEMISSAO,.T.) //09/10/18 puxar pela data de emissão e não database
//nRet := SM2->M2_MOEDA2 //Taxa do dia na moeda 2 -- Comentei a Linha, pois vai trazer o valor da moeda do pedido. Estava trazendo sempre dólar

IF SC7->C7_MOEDA = 1
NRET:= 1
ENDIF

IF SC7->C7_MOEDA = 2
NRET:= SM2->M2_MOEDA2
ENDIF

IF SC7->C7_MOEDA = 3
NRET:= SM2->M2_MOEDA3
ENDIF

IF SC7->C7_MOEDA = 4
NRET:= SM2->M2_MOEDA4
ENDIF

IF SC7->C7_MOEDA = 5
NRET:= SM2->M2_MOEDA5
ENDIF

IF SC7->C7_MOEDA = 6
NRET:= SM2->M2_MOEDA6
ENDIF

IF SC7->C7_MOEDA = 7
NRET:= SM2->M2_MOEDA7
ENDIF

IF SC7->C7_MOEDA = 8
NRET:= SM2->M2_MOEDA8
ENDIF

nRecSC7 := SC7->(RecNo())


For nX := 1 to len(aCols)
N := nX

SC7->(dbSetOrder(14))
SC7->(DbSeek(xFilial("SC7")+aCols[N, nPosPC]+aCols[N, nItemPc],.T.))

// aCols[N, nPosVal] := xMoeda(SC7->C7_PRECO,SC7->C7_MOEDA,1,dDataBase)
aCols[N, nPosVal] := xMoeda(SC7->C7_PRECO,SC7->C7_MOEDA,1,ddemissao,6) // alterado 09/10/18 puxar pela data de emissão e não database
A103Trigger('D1_VUNIT')

// aCols[N, nPosTot] := xMoeda(SC7->C7_TOTAL,SC7->C7_MOEDA,1,dDataBase)
aCols[N, nPosTot] := xMoeda(SC7->C7_TOTAL,SC7->C7_MOEDA,1,ddemissao,6)// alterado 09/10/18 puxar pela data de emissão e não database
A103Trigger('D1_TOTAL')

Next

SC7->(MsGoto(nRecSC7))

Return nRet
*********************************************************************************************************************

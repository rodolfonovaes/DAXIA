#Include 'Protheus.ch'
#Include "RWMAKE.CH"
/*
Exemplo de Ponto de Entrada para substituição de Regra
de Avaliação de Crédito.
PARAMIXB : 01 - Codigo do Cliente
02 - Loja do Cliente
03 - Valor da Operacao
04 - Moeda
05 - Pedido de Venda
*/
User Function MAAVCRPR()

Local lRet := .F.
Local aAreaSA1 := GetArea()
Local aDados := PARAMIXB

lRet := aDados[7]

If !Empty( SC5->C5_CONDPAG ) .And. SC5->C5_CONDPAG == 'ANT'
    lRet := .F.
EndIf

DbSelectArea("SA1")
SA1->(DbSetOrder(1))
If lRet .And. SA1->(DbSeek(xFilial("SA1")+aDados[1]+aDados[2] ) )

    If SA1->A1_CLASSE == "D" .AND. SC5->C5_XVLTOT > SuperGetMV('ES_PEDIDOD',.T.,0)
        lRet := .F.
    ElseIf SA1->A1_CLASSE == "E" .AND. SC5->C5_XVLTOT > SuperGetMV('ES_PEDIDOE',.T.,0)
        lRet := .F.    
    Endif

Endif
RestArea(aAreaSA1)

Return lRet

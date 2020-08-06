
#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATA450.CH"

/*/{Protheus.doc} MT450COLS()
    Conversao de valores para reais na tela de liberação de credito
    @type  Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function MT450COLS()
Local aHeader := PARAMIXB[1]
Local aRet    := PARAMIXB[2]
Local n       := 0
Local aArea   := GetArea()
Local cPedido := SC9->C9_PEDIDO
Local cItem   := SC9->C9_ITEM
Local nTotal  := 0
Local nValor  := 0
Local nPosPed := aScan(aRet,{|x| AllTrim(x[1])=="Pedido Atual"})
Local nPosIt  := aScan(aRet,{|x| AllTrim(x[1])=="Item Pedido Atual"})

SC6->(DbSetOrder(1))
If SC6->(DbSeek(xFilial('SC6') + cPedido))  
    While SC6->C6_NUM == cPedido
        If !Empty(SC6->C6_XMOEDA)
            nValor := xMoeda(SC6->C6_VALOR,Val(SC6->C6_XMOEDA),1,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2'))
            nValor += SC6->C6_XVLIPI
        Else
            nValor := SC6->C6_VALOR
        EndIf
        If cItem == SC6->C6_ITEM
            If nPosIt > 0 
                aRet[nPosIt,2] := Transform( nValor, "@E 999,999,999,999.99" )
                aRet[nPosIt,3] := Transform( nValor, "@E 999,999,999,999.99" )
            EndIf
        EndIf
        nTotal += nValor
        SC6->(DbSkip())
    EndDo
    If nPosPed > 0        
        aRet[nPosPed,2] := Transform( nTotal, "@E 999,999,999,999.99" )
        aRet[nPosPed,3]  := Transform( nTotal, "@E 999,999,999,999.99" )    
    EndIf
EndIf
RestArea(aArea)
Return aRet
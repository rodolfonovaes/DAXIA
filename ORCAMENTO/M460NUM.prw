#Include "PROTHEUS.CH"


User Function M460NUM()
Local cQuery   := ''
Local aArea := GetArea()
Local cAliasTrb := ''
Local nPrcVen   := 0
Local nTotal    := 0
Local aSC5          := {}
Local aItemSC6      := {}
Local aItens        := {}
Local lAtualiza     := .F.
Local lRet          := .T.


SC6->(DbSetOrder(1))
If SC6->(DbSeek(xFilial('SC6') + SC5->C5_NUM)) .And. Empty(SC5->C5_NOTA)
    While(SC6->(C6_FILIAL + C6_NUM) == xFilial('SC6') + SC5->C5_NUM)
        DbSelectArea('SC9')
        SC9->(DbSetOrder(01)) //C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO

        If Posicione('DA1',1,xfilial('DA1') + SUPERGETMV('ES_DAXTAB',.T.,'001',cFilAnt) + SC6->C6_PRODUTO ,'DA1_MOEDA') == 2  .And. ;
            SC9->(DbSeek(FWxFilial('SC9') + PadR(SC5->C5_NUM, TamSX3('C9_PEDIDO')[01]))) .And.  SC9->C9_BLEST 	== "  " .And. SC9->C9_BLCRED	== "  "

            SM2->(dbSetOrder(1))
            SM2->(dbSeek(dDataBase))

            If SM2->M2_MOEDA2 == 0
                Alert('Não existe cotação de dolar cadastrada para o dia ' + DTOC(dDataBase))
                lRet := .F.
                Exit
            EndIf

            lAtualiza := .T.
            cQuery := "SELECT * "
            cQuery += "  FROM " + RetSQLTab('SCK')
            cQuery += "  WHERE  "
            cQuery += "  CK_FILIAL = '" + xFilial('SCK') + "' AND CK_NUMPV = '" + SC5->C5_NUM + "' AND CK_PRODUTO = '" + SC6->C6_PRODUTO  + "' "
            cQuery += "  AND SCK.D_E_L_E_T_ = ' '"

            If Select(cAliasTrb) > 0 .And. !empty(cAliasTrb)
                (cAliasTrb)->(DbCloseArea())
            EndIf

            cQuery    := ChangeQuery(cQuery)
            cAliasTrb := GetNextAlias()

            DbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), cAliasTrb, .F., .T.)

            If (cAliasTrb)->(!EOF())
                IF (cAliasTrb)->CK_XFIXA <> 'S'
                    nPrcVen := xMoeda((cAliasTrb)->CK_PRCVEN,2,1,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2'))   
                Else
                    nPrcVen := round((cAliasTrb)->CK_XTAXA * (cAliasTrb)->CK_PRCVEN,6)
                EndIf

                SC9->(DbSetOrder(1))
                If SC9->(DbSeek(xFilial('SC9') + SC6->(C6_NUM  + C6_ITEM ) ))
                    While(SC9->(C9_FILIAL+C9_PEDIDO+C9_ITEM) == xFilial('SC9')+SC6->(C6_NUM  + C6_ITEM ) )
                        If SC9->C9_PRODUTO == SC6->C6_PRODUTO
                            Reclock('SC9',.F.)
                            SC9->C9_PRCVEN := nPrcVen
                            MsUnlock()
                            SC9->(DbSkip())
                        EndIf
                    EndDo
                EndIf  

            EndIf
        EndIf
        SC6->(DbSkip())
    EndDo
EndIf
RestArea(aArea)
Return lRet
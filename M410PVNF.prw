#Include "PROTHEUS.CH"


User Function M410PVNF()
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
Local nQtdAux       := 0

SC6->(DbSetOrder(1))
If SC6->(DbSeek(xFilial('SC6') + SC5->C5_NUM)) .And. Empty(SC5->C5_NOTA)
    aItens      := {}
    aItemSC6    := {}
    While(SC6->(C6_FILIAL + C6_NUM) == xFilial('SC6') + SC5->C5_NUM) .And. lRet

        //Verifico se foi faturado parcialmente
        DbSelectArea('SC9')
        SC9->(DbSetOrder(01)) //C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO     
        If SC9->(DbSeek(xFilial('SC9') + SC6->(C6_NUM + C6_ITEM)))
            nQtdAux := 0
            While(xFilial('SC9') + SC6->(C6_NUM + C6_ITEM) == SC9->(C9_FILIAL + C9_PEDIDO + C9_ITEM))
                nQtdAux += SC9->C9_QTDLIB
                If SC9->C9_BLEST <> '  ' .Or. SC9->C9_BLCRED <> '  '
              //      lRet := .F.
                EndIf
                SC9->(DbSkip())
            EndDo

            If nQtdAux <> (SC6->C6_QTDVEN - SC6->C6_QTDENT) .And. POSICIONE('SCJ',1,xFilial('SCJ') + SC5->C5_XNUMCJ,'CJ_XFATPAR') == '2'
                lRet := .F.
                Alert('Não è Permitido o faturamento parcial!')
            Else
                LoadPeso()
            EndIf
        EndIf

        DbSelectArea('SC9')
        SC9->(DbSetOrder(01)) //C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO

        If Posicione('DA1',1,xfilial('DA1') + SUPERGETMV('ES_DAXTAB',.T.,'001',cFilAnt) + SC6->C6_PRODUTO ,'DA1_MOEDA') == 2 .And. ;
            SC9->(DbSeek(FWxFilial('SC9') + PadR(SC5->C5_NUM, TamSX3('C9_PEDIDO')[01]))) .And.  SC9->C9_BLEST 	== "  " .And. SC9->C9_BLCRED	== "  " .And. lRet

            SM2->(dbSetOrder(1))
            SM2->(dbSeek(dDataBase))

            If SM2->M2_MOEDA2 == 0
                Alert('Não existe cotação de dolar cadastrada para o dia ' + DTOC(dDataBase))
                lRet := .F.
                Exit
            EndIf

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

Static Function LoadPeso()
Local nPesBrut  := 0
Local nPesLiq   := 0
Local nVolume   := 0

DBselectarea('SC9')
SC9->(DBselectarea(1))
If SC9->(DbSeek(xFilial('SC9') + SC5->C5_NUM ))
    While SC9->(C9_FILIAL + C9_PEDIDO) == xFilial('SC9') + SC5->C5_NUM
        If  Empty(SC9->C9_BLEST) .And. Empty(SC9->C9_BLCRED)
            SB1->(dbSetOrder(1))
            If SB1->(DbSeek(xFilial('SB1') + SC9->C9_PRODUTO ))
                nPesBrut += (SC9->C9_QTDLIB * SB1->B1_PESBRU)
                nPesLiq += (SC9->C9_QTDLIB* SB1->B1_PESO)
                nVolume += IIF(SB1->B1_CONV > 0 ,SC9->C9_QTDLIB / SB1->B1_CONV ,SC9->C9_QTDLIB)
            EndIf    
        EndIf
        SC9->(DbSkip())
    EndDo
EndIf
Reclock('SC5',.F.)
SC5->C5_PESOL     := nPesLiq
SC5->C5_PBRUTO    := nPesBrut
SC5->C5_VOLUME1   := nVolume
SC5->C5_ESPECI1   := 'VOLUMES'
MsUnlock()
Return
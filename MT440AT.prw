#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} MT440AT
valida se usuario tem privilegio para aprovar pedido de venda com margem negativa
@author Rodolfo
@since 03/10/2019
@version 1.0
@return ${lRet}, ${Deve ser retorna .T.() ou .F.}
/*/ 

User Function MT440AT()  
Local lRet     := .F.
Local nMargem   := 0
Local nItens    := 0
Local nFx1Ini    := Val(Separa(GETMV('ES_LIBFX1'),'|')[1])
Local nFx1Fim    := Val(Separa(GETMV('ES_LIBFX1'),'|')[2])
Local nFx2Ini    := Val(Separa(GETMV('ES_LIBFX2'),'|')[1])
Local nFx2Fim    := Val(Separa(GETMV('ES_LIBFX2'),'|')[2])
Local nFx3Ini    := Val(Separa(GETMV('ES_LIBFX3'),'|')[1])
Local nFx3Fim    := Val(Separa(GETMV('ES_LIBFX3'),'|')[2])
Local nFx4Ini    := Val(Separa(GETMV('ES_LIBFX4'),'|')[1])
Local nFx4Fim    := Val(Separa(GETMV('ES_LIBFX4'),'|')[2])
Local aArea      := GetArea()
Local nRecC5     := SC5->(Recno())
Local cTesLib  := SuperGetMv('ES_TESLIB',.T.,'')
Local cOpLib     := SuperGetMv('ES_OPZERPE',.t.,'')

If SC5->C5_XTPOPER $ cOpLib
    RestArea(aArea)
    Return .T.
EndIf

DbSelectArea('SC6')
SC6->(DbSetOrder(1))
If SC6->(DbSeek(xFilial('SC6') + SC5->C5_NUM ))
    While SC6->C6_FILIAL + SC6->C6_NUM == SC5->(C5_FILIAL + C5_NUM)
        nMargem += SC6->C6_XMGBRUT
        nItens ++
        If SC6->C6_TES $ cTesLib
            lRet := .T.
        EndIf
        SC6->(DbSkip())
    EndDo
EndIf

nMargem := nMargem / nItens

DbSelectArea('SZE')
SZE->(DbSetOrder(1))
If SZE->(DbSeek(xFilial('SZE') + Alltrim(RetCodUsr())))
    If SZE->ZE_FAIXA == '1' .And. nMargem <= nFx1Ini .And. nMargem >= nFx1Fim
        lRet := .T.
    ElseIf SZE->ZE_FAIXA == '2' .And. nMargem <= nFx2Ini .And. nMargem >= nFx2Fim
        lRet := .T.
    ElseIf SZE->ZE_FAIXA == '3' .And. nMargem <= nFx3Ini .And. nMargem >= nFx3Fim
        lRet := .T.
    ElseIf SZE->ZE_FAIXA == '4' .And. nMargem <= nFx4Ini .And. nMargem >= nFx4Fim
        lRet := .T.        
    EndIf
Else
    Alert('Usuario não cadastrado na tabela de liberação comercial!')
EndIf

If SC5->C5_TIPO <> 'N'
    lRet := .T.
EndIf

SC5->(DbGoTo(nRecC5))

SC9->(DbSetOrder(1))
If SC9->(DbSeek(xFilial('SC9') + SC5->C5_NUM))
    While(xFilial('SC9') + SC5->C5_NUM == SC9->(C9_FILIAL + C9_PEDIDO))
        If SC9->(FieldPos('C9_XBLMRG')) > 0
            Reclock('SC9',.F.)
            SC9->C9_XBLMRG := Iif(lRet,'01','10')
            MsUnlock()
        EndIf
        SC9->(DbSkip())
    EndDo
EndIf

If !lRet .And. SZE->(DbSeek(xFilial('SZE') + Alltrim(RetCodUsr()))) 
    Alert('Usuario não apto a liberar pedidos com esta margem : ' + Alltrim(STR(nMargem)))
EndIf

RestArea(aArea)
Return lRet
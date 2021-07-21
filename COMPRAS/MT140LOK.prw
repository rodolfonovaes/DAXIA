#include "protheus.ch"
#define CRLF	Chr(13)+Chr(10)

User Function MT140LOK()
Local lRet		:= .T.
Local lRet		:= .T.
Local aArea		:= GetArea()
Local nPosCCu	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_CC"})
Local nPosConta	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_CONTA"}) // 1=Sim;2=Nao
Local nPosClvl	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_CLVL"}) // 1=Sim;2=Nao
Local nPosItem	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_ITEMCTA"}) // 1=Sim;2=Nao
Local cCCusto	:= aCols[n][nPosCCu]
Local cConta    := aCols[n][nPosConta]
Local cClvl     := aCols[n][nPosClvl]
Local cItem     := aCols[n][nPosItem]
local lCc       := .F.
Local lItem     := .F.
Local lClvl     := .F.

If aCols[n][len(aCols[n])] .Or. l140Auto
    RestArea(aArea)
    Return .T.
EndIf

CT1->(DbSetOrder(1))
If CT1->(DbSeek(xFilial('CT1') + cConta))
    If CT1->CT1_CCOBRG == '1'
        lCc := .T.
    EndIf
    If CT1->CT1_ITOBRG == '1'
        lItem := .T.
    EndIf
    If CT1->CT1_CLOBRG == '1'
        lClvl := .T.
    EndIf
EndIf
// Valida se é Rotina Automática
If lRet .And. !l140Auto .And. nPosCCu > 0 .And. nPosConta > 0 .And. nPosClvl > 0 .And. nPosItem > 0
	
    If (lCc .And. Empty(cCCusto)) 
        lRet := .F.
        Help('', 1, 'MT140LOK01',, 'Centro de custo obrigatorio para essa conta contabil.', 1, 0)
    EndIf

    If    (lItem .And. Empty(cItem)) 
        lRet := .F.
        Help('', 1, 'MT140LOK02',, 'Item obrigatorio para essa conta contabil.', 1, 0)
    EndIf

    If (lClvl .And. Empty(cClvl))
        lRet := .F.
        Help('', 1, 'MT140LOK03',, 'Classe de valor obrigatorio para essa conta contabil. ', 1, 0)
    EndIf 
	
EndIf

RestArea(aArea)
Return lRet

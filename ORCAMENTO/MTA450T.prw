#include 'protheus.ch'
#include 'parmtype.ch'
//Atualizo os campos da SC5
user function MTA450T()
Local aArea := GetArea()
Reclock('SC5',.F.)
SC5->C5_XBLWMS  := SC9->C9_BLWMS
SC5->C5_BLEST   := SC9->C9_BLEST
SC5->C5_BLCRED  := SC9->C9_BLCRED
MsUnlock()

SA1->(DbSetOrder(1))
If SA1->(DbSeek(xFilial('SA1') + SC5->(C5_CLIENTE + C5_LOJACLI)))
    RecLock('SA1', .F.)
    SA1->A1_SALPEDL := SC5->C5_XVLTOT
    MsUnlock()
EndIf

Restarea(aArea)
Return

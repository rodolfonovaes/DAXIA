#include 'protheus.ch'
#include 'parmtype.ch'
//Atualizo os campos da SC5
user function MTA450T()

Reclock('SC5',.F.)
SC5->C5_XBLWMS  := SC9->C9_BLWMS
SC5->C5_BLEST   := SC9->C9_BLEST
SC5->C5_BLCRED  := SC9->C9_BLCRED
MsUnlock()

Return
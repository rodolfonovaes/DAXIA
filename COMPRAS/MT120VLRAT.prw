#Include 'Protheus.ch'

User Function MT120VLRAT()

Local lRet                  :=  .T.
Local aColsSCH              := ParamIXB[1]
Local aHeaderSCH            := ParamIXB[2]
Local nLinha                := ParamIXB[3]
Local nPosConta             := aScan(aOrigHeader,{|x| AllTrim(x[2]) == "C7_CONTA"}) 
Local cConta                := aOrigAcols[nOrigN][nPosConta]
Local nPosCC                := aScan(aHeaderSCH,{|x| AllTrim(x[2]) == "CH_CC"}) 
Local nPosItem              := aScan(aHeaderSCH,{|x| AllTrim(x[2]) == "CH_ITEMCTA"}) 
Local nPosClvl              := aScan(aHeaderSCH,{|x| AllTrim(x[2]) == "CH_CLVL"})     
Local cCc                   := aColsSCH[nLinha][nPosCC]
Local cItem                 := aColsSCH[nLinha][nPosItem]
Local cClvl                 := aColsSCH[nLinha][nPosClvl]

local lCc       := .F.
Local lItem     := .F.
Local lClvl     := .F.

If l120Auto 
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


If (lCc .And. Empty(cCc)) 
    lRet := .F.
    Help('', 1, 'MT120VLRAT',, 'Centro de custo obrigatorio para essa conta contabil.', 1, 0)
EndIf

If    (lItem .And. Empty(cItem)) 
    lRet := .F.
    Help('', 1, 'MT120VLRAT',, 'Item obrigatorio para essa conta contabil.', 1, 0)
EndIf

If (lClvl .And. Empty(cClvl))
    lRet := .F.
    Help('', 1, 'MT120VLRAT',, 'Classe de valor obrigatorio para essa conta contabil. ', 1, 0)
EndIf
Return (lRet)
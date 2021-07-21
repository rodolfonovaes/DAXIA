/*/{Protheus.doc} MT103LOK()
    (long_description)
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
User Function MT103LOK()
Local lRet := .t.
Local nPCC	    := 0
Local nPConta	:= 0
Local nPItemCta := 0
Local nPCLVL	:= 0
Local nPosRat	:= 0
Local cCCusto	:= ''
Local cConta    := ''
Local cClvl     := ''
Local cItem     := '']
Local cRateio	:= ''
local lCc       := .F.
Local lItem     := .F.
Local lClvl     := .F.

If l103Auto
    Return .T.
EndIf

If IsInCallStack('NfeRatLOk')
    nPConta	    := aScan(aOrigHeader,{|x| AllTrim(x[2]) == "D1_CONTA"} )
    nPItemCta   := aScan(aHeader,{|x| AllTrim(x[2]) == "DE_ITEMCTA"} )
    nPCLVL	    := Ascan(aHeader,{|x| AllTrim(x[2]) == "DE_CLVL"} )   
    nPCC	    := aScan(aHeader,{|x| AllTrim(x[2]) == "DE_CC"} ) 
    cCCusto	    := aCols[n][nPCC]
    cConta      := aOrigAcols[nOrigN][nPConta]
    cClvl       := aCols[n][nPCLVL]
    cItem       := aCols[n][nPItemCta]    
Else
    nPConta	    := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_CONTA"} )
    nPItemCta   := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_ITEMCTA"} )
    nPCLVL	    := Ascan(aHeader,{|x| AllTrim(x[2]) == "D1_CLVL"} )   
    nPCC	    := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_CC"} ) 
    cCCusto	    := aCols[n][nPCC]
    cConta      := aCols[nOrigN][nPConta]
    cClvl       := aCols[n][nPCLVL]
    cItem       := aCols[n][nPItemCta]    
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

If (lCc .And. Empty(cCCusto)) 
    lRet := .F.
    Help('', 1, 'MT103LOK01',, 'Centro de custo obrigatorio para essa conta contabil.', 1, 0)
EndIf

If    (lItem .And. Empty(cItem)) 
    lRet := .F.
    Help('', 1, 'MT103LOK02',, 'Numero de processo obrigatorio para essa conta contabil.', 1, 0)
EndIf

If (lClvl .And. Empty(cClvl))
    lRet := .F.
    Help('', 1, 'MT103LOK03',, 'Classe de valor obrigatorio para essa conta contabil. ', 1, 0)
EndIf

Return lRet
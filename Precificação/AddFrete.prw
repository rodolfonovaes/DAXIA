 /*/{Protheus.doc} AddExc
    Retorna valores de frete e de exceções para o preço de venda
    @type  Function
    @author user
    @since 05/06/2024
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function AddFrete()
Local aArea     := GetArea()
Local cNumTab   := ''
Local cTransp   := ''
Local cUf       := ''
Local cUfDest   := ''
Local nExcec    := M->CJ_ZZNEGOC
Local nFrete    := M->CJ_XVLFRETE
Local nIcmFrete := 0
local nPosOri   := TMP1->(Recno())
Local nQtd      := 0
Local nRet      := 0
Local nTotIcFrt := 0

DbSelectArea("TMP1")
TMP1->(DbGotop())  
Do While TMP1->(!eof())
	if !TMP1->CK_FLAG .and. !empty(TMP1->CK_PRODUTO)   
        nQtd +=TMP1->CK_QTDVEN
	Endif
	TMP1->(DbSkip())
Enddo

nRet := (nExcec + nFrete) / nQtd

//ICMS FRETE
If M->CJ_XTPFRET $ "1|2|4"
    cTransp := M->CJ_XTRANSP
    IF  M->CJ_XTPFRET == '1'
        cNumTab	:= M->CJ_XTBGFE
    EndIf
    cUfDest    := SA1->A1_EST

    do case
        Case cFilAnt == '0101'
            cUf := 'SP'  
        Case cFilAnt == '0102'
            cUf := 'SC'
        Case cFilAnt == '0103'
            cUf := 'SP'
        Case cFilAnt == '0104'
            cUf := 'PE'     
        Case cFilAnt == '0105'
            cUf := 'SP'			     
    EndCase			


    SA4->(DbSetOrder(1))
    If SA4->(DbSeek(xFilial('SA4') + cTransp))
        GU3->(DbSetOrder(11))
        If GU3->(DbSeek(xFilial('GU3') + SA4->A4_CGC))
            GV9->(DbSetOrder(1))
            If GV9->(DBSeek(xFilial('GV9') + GU3->GU3_CDEMIT + IIF(empty(cNumTab),'',cNumTab))) 
                If GV9->GV9_ADICMS == '1'
                    GUR->(DbSetOrder(1))
                    If GUR->(DBSeek(xFilial('GUR') + cUf + cUfDest))
                        nIcmFrete := GUR->GUR_PCICMS
                    EndIf
                EndIf
            EndIf
        EndIf
    EndIf
EndIf

nTotIcFrt := ((nFrete * nIcmFrete)/100)
nRet += nTotIcFrt

DbSelectArea("TMP1")
TMP1->(DbGotop())  
Do While TMP1->(!eof())
    if !TMP1->CK_FLAG .and. !empty(TMP1->CK_PRODUTO) .and. nPosOri != TMP1->(Recno())
        TMP1->CK_PRUNIT := TMP1->CK_XPRCUNI + nRet                
    Endif
    TMP1->(DbSkip())
Enddo

TMP1->(DbGoto(nPosOri))

RestArea(aArea)
Return nRet



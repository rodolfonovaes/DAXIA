 /*/{Protheus.doc} DXGETDSC
    Retorna o desconto de acordo com a tabela de desconto progressivo SZP
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
User Function DXGETDSC(cTipo)
Local aArea     := GetArea()
Local aSKU      := {}
local nSKU      := 0
local nPosOri   := TMP1->(Recno())
Local nPerDsc   := 0
Local nValor    := 0
Local nPDesc    := 0
Local nVlDesc   := 0
Local nPrcVen	:= 0
Local nRet      := 0
Local lAchou    := .f.
//AxCadastro('SZP','')
DbSelectArea("TMP1")
TMP1->(DbGotop())  //TMP1 eh o arquivo temporario usado pela rotina padrao MATA415 onde tem os itens do orcamento
Do While TMP1->(!eof())
	if !TMP1->CK_FLAG .and. !empty(TMP1->CK_PRODUTO)   //ITEM do orcamento nao ta deletado
		If ascan(aSKU,Alltrim(TMP1->CK_PRODUTO)) == 0
            aadd(aSKU,Alltrim(TMP1->CK_PRODUTO))
        EndIf
	Endif
	TMP1->(DbSkip())
Enddo

nSKU := Len(aSKU)

If nSKU > 0
    SZP->(DbSetOrder(1))
    SZP->(DbGoTop())
    While (SZP->(!EOF())) .And. !lAchou
        If Alltrim(SZP->ZP_OPER) == '1'
            IF nSKU == SZP->ZP_QTD
                nPerDsc := SZP->ZP_DESC / 100
                lAchou    := .T.
            EndIf
        ElseIf Alltrim(SZP->ZP_OPER)  == '2'
            IF nSKU >= SZP->ZP_QTD
                nPerDsc := SZP->ZP_DESC / 100
                lAchou    := .T.
            EndIf        
        EndIf        
        SZP->(DbSkip())
    EndDo
EndIf



DbSelectArea("TMP1")
TMP1->(DbGotop())  //TMP1 eh o arquivo temporario usado pela rotina padrao MATA415 onde tem os itens do orcamento
Do While TMP1->(!eof())
    if !TMP1->CK_FLAG .and. !empty(TMP1->CK_PRODUTO)   //ITEM do orcamento nao ta deletado
        TMP1->CK_XDESCON := nPerDsc
        nPDesc    := nPerDsc 
        TMP1->CK_PRCVEN  := TMP1->CK_XPRCVEN * (1 - nPerDsc)
        RunTrigger(2, val(TMP1->CK_ITEM), nil, nil, "CK_PRCVEN")  
        TMP1->CK_VALOR := Round(TMP1->CK_QTDVEN*TMP1->CK_PRCVEN,6)                   
    Endif
    TMP1->(DbSkip())
Enddo


TMP1->(DbGoto(nPosOri))

If cTipo == 'P'
    nRet := nPerDsc
Else
    nRet := nPerDsc
EndIf

RestArea(aArea)
Return nRet



 /*/{Protheus.doc} DXGETMKP
    Retorna o markup
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
User Function DXGETMKP(cProduto,nQtd)
Local aArea     := GetArea()
Local nMarkup   := 0    
Local nNorma    := 0
Local cLocal    := Supergetmv('ES_LOCNORMA',.t.,'01')
Local lAchou    := .f.
Local nPercNor  := 0
Local cFaixa    := ''


If nQtd == 0
    Return 0
EndIf

SB1->(DbSetOrder(1))
If SB1->(DbSeek(xFilial('SB1') + cProduto))
    //obtenho a norma
    DC3->(DbSetOrder(2))
    If DC3->(DbSeek(xFilial('DC3') + cProduto + cLocal))
        DC2->(DbSetOrder(1))
        DC2->(DbSeek(xFilial('DC2') + DC3->DC3_CODNOR))			
        nNorma :=  (DC2->DC2_LASTRO * DC2->DC2_CAMADA) * SB1->B1_CONV
    EndIf
EndIf
//percentual da norma
nPercNor :=  round((nQtd * 100) / nNorma ,2)

//verifico a faixa em que a norma se enquadra
SZN->(DbSetOrder(1))
SZN->(DbGoTop())
IF SZN->(DbSeek(xFilial('SZN') ))
    While SZN->(!EOF()) .and. !lAchou .And. SZN->ZN_FILIAL == xFilial('SZN') '
        If nPercNor >= SZN->ZN_VLINI .And. nPercNor <= SZN->ZN_VLFIM
            cFaixa := SZN->ZN_FAIXA
            lAchou := .t.
        EndIf
        
        SZN->(DbSkip())
    EndDo
EndIF
If !lAchou 
    //MsgInfo('Não encontou markup!')
Else
    SZO->(DbSetOrder(1))
    If SZO->(DbSeek(xFilial('SZO') + cProduto + cFaixa))
        nMarkup := SZO->ZO_MARKUP
    Else
        //MsgInfo('Não encontou markup!')
    EndIf
EndIf

//Verifico o markup cadastrado para o produto/faixa


RestArea(aArea)
Return nMarkup

 /*/{Protheus.doc} AxCadSZN
    (long_description)
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
User Function AxCadSZN()
AxCadastro('SZN','Faixa x Norma')    
Return 

User Function AxCadSZO()
AxCadastro('SZO','Produtos x Markup')    
Return 

User Function AxCadSZP()
AxCadastro('SZP','Desconto Progressivo - por qtd')    
Return 


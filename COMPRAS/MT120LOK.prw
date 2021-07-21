/*
MT120LOK - Validações Específicas de Usuário
Descrição:	Function A120LinOk() responsável pela validação de cada linha da GetDados do Pedido de Compras / Autorização de Entrega.
			EM QUE PONTO : O ponto se encontra no final da função e deve ser utilizado para validações especificas do usuario onde será controlada pelo 
			retorno do ponto de entrada oqual se for .F. o processo será interrompido e se .T. será validado.
Partage:	Validar a digitação do centro de custo no item ou no rateio do item.

@author 	Rossana Barbosa
@since		02/08/2017
@version 	1.0
*/

User Function MT120LOK()
Local lRet		:= .T.
Local aArea		:= GetArea()
Local nPosCCu	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C7_CC"})
Local nPosRat	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C7_RATEIO"}) // 1=Sim;2=Nao
Local nPosConta	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C7_CONTA"}) // 1=Sim;2=Nao
Local nPosClvl	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C7_CLVL"}) // 1=Sim;2=Nao
Local nPosItem	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C7_ITEMCTA"}) // 1=Sim;2=Nao
Local cCCusto	:= aCols[n][nPosCCu]
Local cRateio	:= aCols[n][nPosRat]
Local cConta    := aCols[n][nPosConta]
Local cClvl     := aCols[n][nPosClvl]
Local cItem     := aCols[n][nPosItem]
local lCc       := .F.
Local lItem     := .F.
Local lClvl     := .F.

If l120Auto
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

If cRateio=="2" 
    If (lCc .And. Empty(cCCusto)) 
        lRet := .F.
        Help('', 1, 'MT120LOK',, 'Centro de custo obrigatorio para essa conta contabil.', 1, 0)
    EndIf

    If    (lItem .And. Empty(cItem)) 
        lRet := .F.
        Help('', 1, 'MT120LOK',, 'Item obrigatorio para essa conta contabil.', 1, 0)
    EndIf

    If (lClvl .And. Empty(cClvl))
        lRet := .F.
        Help('', 1, 'MT120LOK',, 'Classe de valor obrigatorio para essa conta contabil. ', 1, 0)
    EndIf    
EndIf

RestArea(aArea)
Return lRet
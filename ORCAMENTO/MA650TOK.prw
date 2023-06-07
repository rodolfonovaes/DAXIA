#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} MA650TOK
Ponto de Entrada para validar inclusao de OP
@type function
@author Rodolfo
@since 10/09/2022
@version 1.0
/*/User Function MA650TOK()

Local lRet := .T.

lRet := ValidComp()
//Comentado para utilizar na rotina que firma ops previstas

Return lRet

//Valida se a estrutura tem saldo em todos componentes
Static Function ValidComp()

    Local aArea := GetArea()
	Local lRet := .T.

    SB1->(dbSetOrder(1))
    If SB1->(dbSeek( FWxFilial("SB1") + M->C2_PRODUTO )) .And. SB1->B1_XTPCOMP == '2' .And. Empty(M->C2_XNOMFOR)
        Alert('Favor preencher o campo de codigo e loja do fornecedor')
        lRet := .F.
    EndIf
	
    RestArea(aArea)

Return lRet

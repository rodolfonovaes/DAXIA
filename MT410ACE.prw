#include 'rwmake.ch'
/*/{Protheus.doc} Mt410Ace
Ponto de entrada para validar acesso do usuario na rotina
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
User Function Mt410Ace()
Local lContinua := .T.  
Local nOpc  := PARAMIXB [1] 

If nOpc == 4 .And. !Empty(SC5->C5_XNUMCJ)// nao permito usuario alterar pedido vindo de orçamento
    lContinua := MsgYesNo('O pedido voltará ao status de não liberado caso prossiga com a alteração, deseja continuar?')
EndIf   

Return(lContinua)
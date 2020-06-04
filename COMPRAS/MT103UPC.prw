#Include 'Protheus.ch'
/*/{Protheus.doc} MT103UPC
Atualiza o preço de venda na geração do documento de entrada
@author Rodolfo
@since 19/09/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function MT103UPC()
Local nValor := SD1->D1_CUSTO
Return nValor
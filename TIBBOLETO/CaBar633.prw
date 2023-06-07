#Include 'Totvs.ch'

/*/{Protheus.doc} CaBar633
BANCO RENDIMENTOS - Calcula cod.barras, linha digitavel, DACs e nosso numero
@author Giane
@since 01/04/2016
@version 1.0
@param cBanco, character, (Codigo do Banco)
@param cArqCFG, character, (Nome do arquivo de configuracao de boletos)
@param cAgencia, character, (codigo da agencia)
@param cConta, character, (codigo da conta)
@param cNossoNum, character, (NossoNumero)
@param nVlrTit, numeric, (valor do titulo)
@param cParcela, character, (parcela do titulo)
@param dDtMovto, data, (data de processamento)
@param cNumTit, character, (Numero do titulo)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function CaBar633(cBanco, cArqCFG, cAgencia, cConta, cNossoNum, nVlrTit, cParcela, dDtMovto, cNumTit)
Local aRet := {}

//chama a funcao de calculo do bradesco, pois o bco rendimentos usa o mesmo layout do bradesco
aRet := U_CaBar237(cBanco, cArqCFG, cAgencia, @cConta, @cNossoNum, nVlrTit, @cParcela, dDtMovto, @cNumTit)

Return({aRet[1], aRet[2], aRet[3]})


#Include 'Protheus.ch'
// Ponto de entrada para informar condição de pagamento e tes, solicitado pelo gabriel

User function A116TECT()

Local oXML := Paramixb[1]
Local aRet   := {}


aadd(aRet,SF4->F4_CODIGO)
aadd(aRet,SE4->E4_CODIGO)

Return aRet
#INCLUDE "PROTHEUS.CH"
/*/{Protheus.doc} FISTRFNFE
Ponto de Entrada para adicionar campos no NFE-Sefaz
@type  User Function
@author B. Vinicius 
@since 20/12/2019
/*/User Function FISTRFNFE()

aAdd( aRotina, {"Boleto Itau","U_CLSBol341()"       	,0,6,0,.F.})
aAdd( aRotina, {"Boleto Bradesco","U_BLTGEN()"       	,0,6,0,.F.})
aAdd( aRotina, {"Laudo","U_DAXR050()"               	 ,0,6,0,.F.})

Return
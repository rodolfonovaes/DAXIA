#INCLUDE "PROTHEUS.CH"


/*/{Protheus.doc} MA030ROT
Adiciona informacoes no menu do cadastro de cliente
@type  User Function
@author B. Vinicius
@since 24/01/2020
/*/User Function MA030ROT()

Local aRotina := {}

Aadd(aRotina,{'Histórico Serasa',"U_DAXATU09()"							, 0, 6, 0, NIL})
Aadd(aRotina,{'Consulta Serasa',"U_DAXATU17()"							, 0, 6, 0, NIL})

Return aRotina

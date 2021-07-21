#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOPCONN.CH'

/*
TITICMST - Validações Específicas de Usuário
Descrição:	PE para alteraracao da natureza financeira do titulo do DIFAL gerado pelo faturamento
@author 	Rossana Barbosa
@since		14/05/2021
@version 	1.0
*/

User Function TITICMST 

Local cOrigem  := PARAMIXB[1] //Nome da rotina que está sendo executada
Local cTipoImp := PARAMIXB[2] //Tipo do imposto contido na guia de recolhimento.
Local lDifal   := PARAMIXB[3] //Verifica se o titulo a ser gravado no momento, trata-se de DIFAL (.T.) ou não (.F.)
Local cNumDoc  := SF2->F2_DOC

/*
Importante
Este ponto de entrada deve ser utilizado somente para alteração do número, data de vencimento e natureza do título.
Não recomendamos a alteração de nenhum outro campo da tabela SE2, pois a rastreabilidade dos títulos pode ser prejudicada ocasionando problemas em exclusões de títulos, GNRE's ou em arquivos magnéticos.

//EXEMPLO 1 (cOrigem)
If AllTrim(cOrigem)='MATA954' //Apuracao de ISS
SE2->E2_NUM := SE2->(Soma1(E2_NUM,Len(E2_NUM)))
SE2->E2_VENCTO := DataValida(dDataBase+30,.T.)
SE2->E2_VENCREA := DataValida(dDataBase+30,.T.)
EndIf

//EXEMPLO 2 (cTipoImp)
If AllTrim(cTipoImp)='1' // ICMS ST
SE2->E2_NUM := SE2->(Soma1(E2_NUM,Len(E2_NUM)))
SE2->E2_VENCTO := DataValida(dDataBase+30,.T.)
SE2->E2_VENCREA := DataValida(dDataBase+30,.T.)
EndIf
*/

If lDifal // DIFAL
SE2->E2_NATUREZ  := "204008"
SE2->E2_HIST     := "REF. DIFAL DA NF.: "+ cNumDoc
EndIf

Return {SE2->E2_NUM,SE2->E2_VENCTO}


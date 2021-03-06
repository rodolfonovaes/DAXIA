/*
+=======================================================================================+
| Funcao Estatica ....:   QE215ROT()                                                    |
| Autor(es)...........:   Cicero Odilio Cruz - cicero.cruz@gmail.com                    |
| Data................:   15/08/2020                                                    |
| Descricao / Objetivo:   Op��o para Importa��o de Dados de uma Filial para Outra       |
|                                                                                       |
| Doc. Origem.........:   MIT044 - REPLICA��O DE DADOS INSPE��O ENTRE EMPRESAS-FILIAIS  |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Parametros..........:   << Sem Parametros >>                                          |
| Retorno.............:   << Sem Retorno >>                                             |
| Obs.................:                                                                 |
+=======================================================================================+
*/
USER FUNCTION QE215ROT()

LOCAL aRotAdic  := {}

//IF __cUserId == "000014"
//    Aadd( aRotAdic, {"Gerar Inspe��o", "U_DAXCINSP", 0, 5} )
//ENDIF

Aadd( aRotAdic, {"Importar Medi��es", "U_DAXIINSP",  0, 5} )

RETURN aRotAdic

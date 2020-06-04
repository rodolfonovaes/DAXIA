#Include "Protheus.CH"
#Include "RWMake.CH"
/*======================================================================================+
| Programa............:   MA415MNU.prw                                                  |
| Autores ............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   24/09/2019                                                    |
| Descricao / Objetivo:   Ponto de entrada que realiza a criacao de novas opcoes no bo- |
|                         tao [Outras Acoes] - rotina Orcamentos/MATA415.               |
| Doc. Origem.........:   MIT044                                                        |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
User Function MA415MNU()
Local aArea  := GetArea()


aAdd( aRotina, { "*Imprimir", "U_DX_RELORC()", 0 , 7, 0, Nil } )   // Relatorio Grafico de Orcamentos
aAdd( aRotina, { "Consulta de Orçamentos", "U_DAXATU06()", 0 , 6, 0, Nil } )   // Consulta de Orçamentos

RestArea( aArea )
Return( aRotina )

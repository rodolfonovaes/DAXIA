#Include "Protheus.CH"
#Include "RWMake.CH"
/*======================================================================================+
| Programa............:   MA416COR.prw                                                  |
| Autores ............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   21/09/2019                                                    |
| Descricao / Objetivo:   Ponto de entrada que realiza a criacao de novas legendas da   |
|                         rotina de Efetivacao/Baixa de Orcamentos (MATA416).           |
| Doc. Origem.........:   MIT044                                                        |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
User Function MA416COR()
Local aArea   := GetArea()
Local aCores  := ParamIXB

aAdd( aCores, { "SCJ->CJ_STATUS=='P'" , "BR_VIOLETA" } ) // Orcamento Perdido
aAdd( aCores, { "SCJ->CJ_STATUS=='R'" , "BR_CINZA" } ) // PERDA POR ELIMINAÇÂO DE RESIDUOS

RestArea( aArea )
Return( aCores )

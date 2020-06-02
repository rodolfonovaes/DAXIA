#Include "Protheus.CH"
#Include "RWMake.CH"
/*======================================================================================+
| Programa............:   MA415LEG.prw                                                  |
| Autores ............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   21/09/2019                                                    |
| Descricao / Objetivo:   Ponto de entrada que realiza a criacao de novas legendas da   |
|                         rotina de Orcamentos (MATA415).                               |
| Doc. Origem.........:   MIT044                                                        |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
User Function MA415LEG()
Local aArea  := GetArea()
Local aLeg   := ParamIXB

aAdd( aLeg, { "BR_VIOLETA" , "*Orcamento Perdido"  } ) // Orcamento Perdido

RestArea( aArea )
Return( aLeg )



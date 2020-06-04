#Include "Protheus.CH"
#Include "RWMake.CH"
/*======================================================================================+
| Programa............:   ACD025GR.prw                                                  |
| Autores ............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   21/10/2019                                                    |
| Descricao / Objetivo:   Ponto de entrada ACD025GR.                                    |
| Doc. Origem.........:   MIT044 - R01PT - Especificacao de Personalizacao - Apontamen- |
|                         to PCP MOD2 - item 20.                                        |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
User Function ACD025Gr()
Local aArea := GetArea()

Private cOper_      := PARAMIXB[ 1 ]

/*------------------------------------------------------------+
| Execucao da funcao U_SB8VALID                               |
+------------------------------------------------------------*/
iIf( FindFunction( "U_SB8VALID" ), u_SB8Valid(), WMSVTAviso( "*U_SB8VALID", "U_SB8VALID inexistente." ) )

RestArea( aArea )
Return( Nil )
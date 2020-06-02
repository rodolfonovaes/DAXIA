#Include "Protheus.CH"
#Include "RWMake.CH"
/*======================================================================================+
| Programa............:   M410LDEL.prw                                                  |
| Autores ............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   13/08/2019                                                    |
| Descricao / Objetivo:   Ponto de entrada que realiza o tratamento de exclusao/recu-   |
|                         peracao dos itens do aCols do Pedido de Vendas.               |
| Doc. Origem.........:   MIT044 - Motivos de Perda do Orcamento.                       |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
User Function M410LDEL()
Local aArea := GetArea()
Local lRet  := .F.

lRet := iIf( FindFunction( "U_DELITEM" ),u_DelItem(), .F. )  // Funcao no programa-fonte DX_PRDORC.prw

RestArea( aArea )
Return( lRet )

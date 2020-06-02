#Include "Protheus.CH"
#Include "RWMake.CH"
/*======================================================================================+
| Programa............:   M410INIC.prw                                                  |
| Autores ............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   25/09/2019                                                    |
| Descricao / Objetivo:   Ponto de entrada M410INIC.                                    |
| Doc. Origem.........:   MIT044                                                        |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
User Function M410INIC()
Local aArea := GetArea()

/*----------------------------------------------------------+
| Verifica se o pedido de vendas e' originado do orcamento. | 
| Se e', forca a gravacao do campo C5_LOJACLI com o con-    |
| teudo do campo SCJ->CJ_LOJA.                              |
+----------------------------------------------------------*/
If IsInCallStack( "MATA416" )
   M->C5_LOJACLI := SCJ->CJ_LOJA
   M->C5_ZZOBSLA := SCJ->CJ_ZZOBSLA
   M->D2_ZZOUTTX := SCJ->CJ_ZZOUTXT
EndIf


RestArea( aArea )
Return( Nil )
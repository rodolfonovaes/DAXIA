//+------------------------------------------------------------------+
//| Rotina | M410INIC | Autor: Daniel Evandro Buso | Data | 09.09.19 |
//+------------------------------------------------------------------+
//| Descr. | PONTO DE ENTRADA, COPIA AS INFORMAÇÕES DO CAMPO         |
//|        | CJ_ZZOBSLA PARA C5_ZZOBSLA E                            |
//|        | CJ_ZZOUTXT PARA D2_ZZOUTXT			   					 |
//+------------------------------------------------------------------+
//| Uso    |                                                         |
//|        |                                                         |
//+------------------------------------------------------------------+

User Function M410INIC()

Local _aArea := GetArea()
      DBSELECTAREA("SCJ")   

                    M->C5_ZZOBSLA := SCJ->CJ_ZZOBSLA
                    M->D2_ZZOUTTX := SCJ->CJ_ZZOUTXT
                    
      RestArea(_aArea)
Return ()
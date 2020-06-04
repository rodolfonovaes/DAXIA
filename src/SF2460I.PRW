//+------------------------------------------------------------------+
//| Rotina | SF2460I  | Autor: Daniel Evandro Buso | Data | 09.09.19 |
//+------------------------------------------------------------------+
//| Descr. | PONTO DE ENTRADA, COPIA AS INFORMAÇÕES DO CAMPO         |
//|        | C5_ZZOUTXT PARA D2_ZZOUTTX                              |
//+------------------------------------------------------------------+
//| Uso    |                                                         |
//|        |                                                         |
//+------------------------------------------------------------------+

User Function SF2460I()

Local _aArea := GetArea()
      DBSELECTAREA("SD2")   

                    M->C5_ZZOUTXT := SD2->D2_ZZOUTTX
                    
      RestArea(_aArea)
Return ()
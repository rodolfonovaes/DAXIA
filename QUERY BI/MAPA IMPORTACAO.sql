SELECT DISTINCT W2_PO_NUM AS NUM_PO,
                W2_NR_PRO AS DOCUMENTO,
                W2_FORN AS FORNECEDOR,
                A2_NOME AS NOME_FORNECEDOR,
                YA_DESCR AS PAIS,
                Y5_NOME AS NOME_DESPACHANTE,
                W6_HOUSE AS HBL,
                W2_INCOTER AS INCOTERM,
                YR_CID_ORI AS PORTO_ORIGEM,
                CASE
                    WHEN W6_AGENTE IS NULL THEN W2_AGENTE
                    ELSE W6_AGENTE
                END AS AGENTE,
                CASE
                    WHEN W6_AGENTE IS NULL THEN Y4_NOME
                    ELSE
                           (SELECT Y4_NOME
                            FROM SY4010 SY4
                            WHERE Y4_FILIAL = '01  '
                              AND Y4_COD = W6_AGENTE
                              AND SY4.D_E_L_E_T_ = ' ' )
                END AS AGENTE_NOME,
                W6_VLFRECC AS VLFRETE,
                DATEDIFF(DAY, CONVERT(VARCHAR, CONVERT(DATE, W6_DT_ETD), 103), CONVERT(VARCHAR, CONVERT(DATE, W6_DT_ETA), 103)) AS TRANSIT_TIME,
                W6_FREETIM AS FREE_TIME,
                W3_COD_I AS COD_PRODUTO,
                B1_DESC AS DESCRICAO_PRODUTO,
                W7_PESO * W7_QTDE AS VOLUME,
                CASE
                    WHEN W6_CONTA20 > 0 THEN W6_CONTA20
                    WHEN W6_CONTA40 > 0 THEN W6_CONTA40
                    WHEN W6_CON40HC > 0 THEN W6_CON40HC
                    WHEN W6_OUTROS > 0 THEN W6_OUTROS
                END AS QTD_CONTAINER,
                CASE
                    WHEN W6_CONTA20 > 0 THEN '20'
                    WHEN W6_CONTA40 > 0 THEN '40'
                    WHEN W6_CON40HC > 0 THEN 'HC'
                    WHEN W6_OUTROS > 0 THEN 'OUTROS'
                END AS TIPO_CONTAINER,
                W6_DEST AS PORTO_DEST,
                W6_XTERMIN AS TERMINAL,
                W7_PRECO AS VALOR_UNITARIO,
                W7_QTDE * W7_PRECO AS VALOR_PROCESSO_US,
                W2_FOB_TOT AS VALOR_TOTAL,
                W2_PO_DT AS EMISSAO_PO,
                CASE
                    WHEN B1_ANUENTE = '1' THEN 'Sim'
                    ELSE 'Não'
                END AS ANUENTE,
                W6_DT_ETD AS ETD,
                W6_DT_ETA AS ETA,
                W6_DT_ENTR AS ESTOQUE,
                DATEDIFF(DAY, CONVERT(VARCHAR, CONVERT(DATE, W2_PO_DT), 103), CONVERT(VARCHAR, CONVERT(DATE, W6_DT_ETD), 103)) AS BOOK,
                DATEDIFF(DAY, CONVERT(VARCHAR, CONVERT(DATE, W6_DT_ETD), 103), CONVERT(VARCHAR, CONVERT(DATE, W6_DT_ETA), 103)) AS TRANSIT_TIME,
                DATEDIFF(DAY, CONVERT(VARCHAR, CONVERT(DATE, W6_DT_ETA), 103), CONVERT(VARCHAR, CONVERT(DATE, W6_DT_ENTR), 103)) AS DIAS_DESEMBARACO,
                DATEDIFF(DAY, CONVERT(VARCHAR, CONVERT(DATE, W2_PO_DT), 103), CONVERT(VARCHAR, CONVERT(DATE, W6_DT_ETD), 103)) + DATEDIFF(DAY, CONVERT(VARCHAR, CONVERT(DATE, W6_DT_ETD), 103), CONVERT(VARCHAR, CONVERT(DATE, W6_DT_ETA), 103)) + DATEDIFF(DAY, CONVERT(VARCHAR, CONVERT(DATE, W6_DT_ETA), 103), CONVERT(VARCHAR, CONVERT(DATE, W6_DT_ENTR), 103)) AS TRANSITO_TOTAL,
                (
                   (SELECT SUM(ZH_VALOR)
                    FROM SZH010 SZH
                    WHERE ZH_PO_NUM = SW2.W2_PO_NUM
                      AND REPLICATE('0',(4 -LEN(ZH_NR_CONT)))+CAST(ZH_NR_CONT AS VARCHAR(4)) = SW7.W7_POSICAO
                      AND ZH_FILIAL = '0103'
                      AND SZH.D_E_L_E_T_ = ' '
                      AND ZH_PO_NUM = SW2.W2_PO_NUM
                      AND ZH_DESPESA IN
                        (SELECT ZH_DESPESA
                         FROM SZH010
                         WHERE SZH.D_E_L_E_T_ = ' '
                           AND ZH_DESPESA BETWEEN '101' AND '899'
                           AND ZH_DESPESA NOT IN
                             (SELECT ZH_DESPESA
                              FROM SZH010
                              WHERE SZH.D_E_L_E_T_ = ' '
                                AND ZH_DESPESA BETWEEN '201' AND '299'
                                AND ZH_DESPESA NOT IN ('104'))) )/W7_QTDE) + W7_II AS CUSTO_ESTIMADO,

  (SELECT TOP 1((SUM(EI2_FOB_R+EI2_DESPES+EI2_VLDEII) / SM2.M2_MOEDA2) / SUM(EI2_QUANT))
   FROM EI2010 EI2
   INNER JOIN SM2010 SM2 ON M2_DATA = SW6.W6_DTREG_D
   WHERE W2_PO_NUM = EI2_PO_NUM
     AND EI2_POSICA = SW7.W7_POSICAO
     AND EI2.D_E_L_E_T_ = ''
     AND EI2_FILIAL = '0103'
   GROUP BY M2_MOEDA2)AS CUSTO_EFETIVO,
                (SUM(EI2_FOB_R+EI2_DESPES+EI2_VLDEII) / SUM(EI2_QUANT)) + (SUM((EI2_FOB_R/EI1_FOB_R) * E2_VALLIQ)-SUM(EI2_FOB_R))/SUM(EI2_QUANT) CUSTO_REAL,
                ((
                    (SELECT TOP 1((SUM(EI2_FOB_R+EI2_DESPES+EI2_VLDEII) / SM2.M2_MOEDA2) / SUM(EI2_QUANT))
                     FROM EI2010 EI2
                     INNER JOIN SM2010 SM2 ON M2_DATA = SW6.W6_DTREG_D
                     WHERE W2_PO_NUM = EI2_PO_NUM
                       AND EI2_POSICA = SW7.W7_POSICAO
                       AND EI2.D_E_L_E_T_ = ''
                       AND EI2_FILIAL = '0103'
                     GROUP BY M2_MOEDA2) - ((
                                               (SELECT SUM(ZH_VALOR)
                                                FROM SZH010 SZH
                                                WHERE ZH_PO_NUM = SW2.W2_PO_NUM
                                                  AND REPLICATE('0',(4 -LEN(ZH_NR_CONT)))+CAST(ZH_NR_CONT AS VARCHAR(4)) = SW7.W7_POSICAO
                                                  AND ZH_FILIAL = '0103'
                                                  AND SZH.D_E_L_E_T_ = ' '
                                                  AND ZH_PO_NUM = SW2.W2_PO_NUM
                                                  AND ZH_DESPESA IN
                                                    (SELECT ZH_DESPESA
                                                     FROM SZH010
                                                     WHERE SZH.D_E_L_E_T_ = ' '
                                                       AND ZH_DESPESA BETWEEN '101' AND '899'
                                                       AND ZH_DESPESA NOT IN
                                                         (SELECT ZH_DESPESA
                                                          FROM SZH010
                                                          WHERE SZH.D_E_L_E_T_ = ' '
                                                            AND ZH_DESPESA BETWEEN '201' AND '299'
                                                            AND ZH_DESPESA NOT IN ('104'))) )/W7_QTDE) + W7_II)) / ((
                                                                                                                       (SELECT SUM(ZH_VALOR)
                                                                                                                        FROM SZH010 SZH
                                                                                                                        WHERE ZH_PO_NUM = SW2.W2_PO_NUM
                                                                                                                          AND REPLICATE('0',(4 -LEN(ZH_NR_CONT)))+CAST(ZH_NR_CONT AS VARCHAR(4)) = SW7.W7_POSICAO
                                                                                                                          AND ZH_FILIAL = '0103'
                                                                                                                          AND SZH.D_E_L_E_T_ = ' '
                                                                                                                          AND ZH_PO_NUM = SW2.W2_PO_NUM
                                                                                                                          AND ZH_DESPESA IN
                                                                                                                            (SELECT ZH_DESPESA
                                                                                                                             FROM SZH010
                                                                                                                             WHERE SZH.D_E_L_E_T_ = ' '
                                                                                                                               AND ZH_DESPESA BETWEEN '101' AND '899'
                                                                                                                               AND ZH_DESPESA NOT IN
                                                                                                                                 (SELECT ZH_DESPESA
                                                                                                                                  FROM SZH010
                                                                                                                                  WHERE SZH.D_E_L_E_T_ = ' '
                                                                                                                                    AND ZH_DESPESA BETWEEN '201' AND '299'
                                                                                                                                    AND ZH_DESPESA NOT IN ('104'))) )/W7_QTDE) + W7_II)) * 100 AS VARIACAO,
                W6_DTRECDO AS RECEB_DOCTO,
                W2_TAB_PC AS TAB_PRE_CALCULO
FROM SW2010 SW2
INNER JOIN SW3010 SW3 ON W2_PO_NUM = W3_PO_NUM
INNER JOIN SY5010 SY5 ON Y5_COD = W2_DESP
AND SY5.D_E_L_E_T_ = ' '
INNER JOIN SYR010 SYR ON YR_ORIGEM = W2_ORIGEM
AND SYR.D_E_L_E_T_ = ' '
LEFT JOIN SW6010 SW6 ON W2_PO_NUM = W6_PO_NUM
AND W6_DT_ENTR BETWEEN '20210805' AND '20241231'
AND W6_DT_EMB BETWEEN '20210805' AND '20241231'
AND SW6.D_E_L_E_T_ = ''
AND W6_FILIAL = '0103'
AND W6_DEST BETWEEN '   ' AND 'ZZZ'
LEFT JOIN SW9010 SW9 ON W2_PO_NUM = W9_HAWB
AND W9_FILIAL = '0103'
LEFT JOIN SW8010 SW8 ON W2_PO_NUM = W8_PO_NUM
AND SW8.D_E_L_E_T_ = ''
AND W8_FILIAL = '0103'
LEFT JOIN SF1010 SF1 ON W2_PO_NUM = F1_HAWB
AND SF1.D_E_L_E_T_ = ''
LEFT JOIN SW7010 SW7 ON W2_PO_NUM = W7_PO_NUM
AND W3_COD_I = W7_COD_I
AND SW7.D_E_L_E_T_ = ''
AND W7_FILIAL = '0103'
INNER JOIN SB1010 SB1 ON W3_COD_I = B1_COD
INNER JOIN SA2010 SA2 ON A2_COD = W2_FORN
AND A2_LOJA = W2_FORLOJ
INNER JOIN SYA010 SYA ON YA_CODGI = SA2.A2_PAIS
AND SYA.D_E_L_E_T_ = ' '
INNER JOIN SY4010 SY4 ON Y4_FILIAL = '01  '
AND Y4_COD = W2_AGENTE
AND SY4.D_E_L_E_T_ = ' '
LEFT JOIN EI2010 EI2 ON EI2_FILIAL = '0103'
AND W2_PO_NUM = EI2_PO_NUM
AND EI2_PRODUT = W3_COD_I
AND EI2.D_E_L_E_T_ = ' '
LEFT JOIN SE2010 SE2 ON E2_FILIAL = '0103'
AND SUBSTRING(E2_HIST, 4, CHARINDEX (':', E2_HIST, 3) - 4 - 2) = SUBSTRING(EI2_HAWB, 1, LEN(TRIM(EI2_HAWB)))
AND SE2.E2_TIPO = 'INV'
AND SE2.D_E_L_E_T_ = ' '
LEFT JOIN EI1010 EI1 ON EI1_FILIAL = '0103'
AND EI1_HAWB = EI2_HAWB
AND EI1_DOC = EI2_DOC
AND EI1.D_E_L_E_T_=''
WHERE SW2.D_E_L_E_T_ = ''
  AND SB1.D_E_L_E_T_ = ''
  AND SA2.D_E_L_E_T_ = ''
  AND W2_FILIAL = '0103'
  AND B1_FILIAL = '    '
  AND W2_PO_NUM BETWEEN '                    ' AND 'ZZZZZZZ             '
  AND W2_PO_DT BETWEEN '20210805' AND '20241231'
  AND W2_AGENTE BETWEEN '   ' AND 'ZZZ'
  AND W2_FORN BETWEEN '      ' AND 'ZZZZZZ'
  AND W3_COD_I BETWEEN '               ' AND 'ZZZZZZZZZZ     '
  AND A2_PAIS BETWEEN '   ' AND 'ZZZ'
GROUP BY W2_PO_NUM,
         W6_FREETIM,
         W2_ORIGEM,
         A2_PAIS,
         A2_NOME,
         W2_DESP,
         W2_NR_PRO,
         W2_FRETNEG,
         W6_XFT,
         W2_FOB_TOT,
         F1_RECBMTO,
         B1_DESC,
         W7_II,
         W2_INCOTER,
         W3_COD_I,
         W6_VLFRECC,
         W6_DT_HAWB,
         W7_POSICAO,
         W2_FORLOJ,
         W6_DT_ENTR,
         W2_FORN,
         Y5_NOME,
         W6_HOUSE,
         W2_AGENTE,
         W9_FRETEIN,
         Y4_NOME,
         W8_DESC_DI,
         W7_PESO,
         W6_CONTA20,
         W6_CONTA40,
         W6_CON40HC,
         W6_OUTROS,
         W6_DEST,
         W7_PRECO_R,
         W2_PO_DT,
         W2_DT_PRO,
         B1_ANUENTE,
         W6_DT_ETD,
         W6_DT_EMB,
         W6_DT_ETA,
         W6_DTREG_D,
         W6_DTREG_D,
         W6_DEST,
         W7_QTDE,
         W7_PRECO,
         EI2_HAWB,
         EI2_POSICA,
         W6_XTERMIN,
         W6_DTRECDO,
         W6_XPRENTR,
         W6_AGENTE,
         YA_DESCR,
         YR_CID_ORI,
         W2_TAB_PC
ORDER BY NUM_PO,
         EMISSAO_PO DESC
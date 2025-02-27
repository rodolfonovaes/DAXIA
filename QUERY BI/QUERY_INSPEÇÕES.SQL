SELECT	DISTINCT	              QEK_FILIAL AS FILIAL,               QEK_TIPONF AS TIPO_NOTA,             QEK_FORNEC AS FORNECEDOR,              QEK_LOJFOR AS LOJA,              QEK_PRODUT AS PRODUTO, 
			               QEK_REVI AS REVISAO,            QEK_DTENTR AS DATA_ENTRADA,           QEK_HRENTR AS HORA_ENTRADA,          QEK_LOTE AS LOTE_DAXIA,        QEK_UNIMED AS UNIDADE_MEDIDA, 
			        QEK_TAMLOT AS TAMANHO_LOTE,  		QEK_TAMAMO AS TAMANHO_AMOSTRA,            QEK_DIASAT AS DIAS_ATRASO,     QEK_PEDIDO AS PEDIDO_COMPRA,    QEK_ITEMPC AS ITEM_PEDIDO_COMPRA,
			     QEK_DOCENT AS LOTE_FORNECEDOR,     QEK_NTFISC AS NOTA_FISCAL_ENTRADA,     QEK_SERINF AS SERIE_NOTA_ENTRADA, QEK_DTNFIS AS DATA_NOTA_ENTRADA,    QEK_ITEMNF AS  ITEM_NOTA_ENTRADA, 
			        QEK_TIPDOC AS TIPO_ENTRADA,              QEK_NUMSEQ AS ID_ENTRADA, QEK_CERFOR AS CERTIFICADO_FORNECEDOR,         QEK_TES AS TIPO_ENTRADA,             QEK_PRECO AS PRECO_ITEM, 
			         QEK_NNC AS NOTIFICACAO_NC,              QER_LABOR AS LABORATÕRIO,                 QER_ENSAIO AS ENSAIO,      QER_DTMEDI AS DATA_MEDICAO,          QER_HRMEDI AS HORA_MEDICAO, 
				QER_FILMAT AS FILIAL_ENSAIADOR,        QER_ENSR AS ANALISTA_ENSAIADOR, 	            QER_RESULT AS RESULTADO,	    QER_DTINI AS DATA_INICIO,           QER_HRINI AS HORA_INICIO,  
				         QER_DTFIM AS DATA_FIM,                 QER_HRFIM AS HORA_FIM,  CASE WHEN QEQ_CODMED IS NULL 
																							 THEN QES_MEDICA
																							 ELSE QEQ_MEDICA END AS MEDICAO
FROM			QEK010 QEK (NOLOCK)
LEFT OUTER JOIN QER010 QER (NOLOCK) ON		QER.QER_FILIAL = QEK.QEK_FILIAL  
										AND QER.QER_PRODUT = QEK.QEK_PRODUT  
										AND QER.QER_REVI   = QEK.QEK_REVI  
										AND QER.QER_FORNEC = QEK.QEK_FORNEC  
										AND QER.QER_LOJFOR = QEK.QEK_LOJFOR  
										AND QER.QER_NTFISC = QEK.QEK_NTFISC
										AND QER.QER_SERINF = QEK.QEK_SERINF			  
										AND QER.QER_ITEMNF = QEK.QEK_ITEMNF 
										AND QER.QER_TIPONF = QEK.QEK_TIPONF  
										AND QER.QER_DTENTR = QEK.QEK_DTENTR  
										AND QER.QER_LOTE   = QEK.QEK_LOTE
										AND QER.QER_NUMSEQ = QEK.QEK_NUMSEQ
										AND QER.D_E_L_E_T_ = ' '
LEFT OUTER JOIN QEQ010 QEQ (NOLOCK) ON		QEQ.QEQ_FILIAL = QER.QER_FILIAL 
										AND QEQ.QEQ_CODMED = QER.QER_CHAVE	
										AND QEQ.D_E_L_E_T_ = ' '
LEFT OUTER JOIN QES010 QES (NOLOCK) ON		QES.QES_FILIAL = QER.QER_FILIAL 
										AND QES.QES_CODMED = QER.QER_CHAVE	
										AND QES.D_E_L_E_T_ = ' '
WHERE			QEK.D_E_L_E_T_ = ' ' 
			AND QEK_ORIGEM <> 'INVENT' -- Excluo as tentativas infrutiferas de importação de dados
UNION
( SELECT DISTINCT        QPK_FILIAL AS FILIAL,                    '  ' AS TIPO_NOTA,                   '000677' AS FORNECEDOR, CASE  WHEN QPK_FILIAL = '0101'  THEN '0001'
																														              WHEN QPK_FILIAL = '0102'  THEN '0002'
																														              WHEN QPK_FILIAL = '0103'  THEN '0006'
																														              ELSE '0007' END                AS LOJA,           QPK_PRODUT AS PRODUTO, 
			               QPK_REVI AS REVISAO,            QPK_DTPROD AS DATA_ENTRADA,                    ' '  AS HORA_ENTRADA,                       QPK_LOTE AS LOTE_DAXIA,        QPK_UM AS UNIDADE_MEDIDA, 
		  CAST(QPK_TAMLOT AS VARCHAR)  AS TAMANHO_LOTE,   CAST(QPK_TAMLOT AS VARCHAR) AS TAMANHO_AMOSTRA,  0 AS DIAS_ATRASO,                          '' AS PEDIDO_COMPRA,        '' AS ITEM_PEDIDO_COMPRA,
			       QPK_LOTE AS LOTE_FORNECEDOR,            ' ' AS NOTA_FISCAL_ENTRADA,               ' ' AS SERIE_NOTA_ENTRADA,              QPK_DTPROD AS DATA_NOTA_ENTRADA,       ' ' AS  ITEM_NOTA_ENTRADA, 
			              'OP' AS TIPO_ENTRADA,                      '' AS ID_ENTRADA,    QPK_CERQUA AS CERTIFICADO_FORNECEDOR,                           '' AS TIPO_ENTRADA,                0.0 AS PRECO_ITEM, 
			             '' AS NOTIFICACAO_NC,              QPR_LABOR AS LABORATÕRIO,                    QPR_ENSAIO AS ENSAIO,      QPR_DTMEDI AS DATA_MEDICAO,          QPR_HRMEDI AS HORA_MEDICAO, 
				QPR_FILMAT AS FILIAL_ENSAIADOR,        QPR_ENSR AS ANALISTA_ENSAIADOR, 	               CASE WHEN QPR_RESULT = 'A' THEN 'APROVADO' 
																											WHEN QPR_RESULT = 'R' THEN 'REPROVADO'
																											WHEN QPR_RESULT = 'T' THEN 'TOLERANCIA' END AS RESULTADO,	    QPR_DTINI AS DATA_INICIO,           QPR_HRINI AS HORA_INICIO,  
				         QPR_DTFIM AS DATA_FIM,                 QPR_HRFIM AS HORA_FIM,  CASE WHEN QPQ_CODMED IS NULL 
																						 THEN QPS_MEDICA
																							 ELSE QPQ_MEDICA END AS MEDICAO
FROM			QPK010 QPK (NOLOCK)
LEFT OUTER JOIN QPR010 QPR (NOLOCK) ON		QPR.QPR_FILIAL = QPK.QPK_FILIAL  
										AND QPR.QPR_PRODUT = QPK.QPK_PRODUT  
										AND QPR.QPR_REVI   = QPK.QPK_REVI  
										AND QPR.QPR_LOTE   = QPK.QPK_LOTE
										AND QPR.QPR_OP     = QPK.QPK_OP
										AND QPR.D_E_L_E_T_ = ' '
LEFT OUTER JOIN QPQ010 QPQ (NOLOCK) ON		QPQ.QPQ_FILIAL = QPR.QPR_FILIAL 
										AND QPQ.QPQ_CODMED = QPR.QPR_CHAVE	
										AND QPQ.D_E_L_E_T_ = ' '
LEFT OUTER JOIN QPS010 QPS (NOLOCK) ON		QPS.QPS_FILIAL = QPR.QPR_FILIAL 
										AND QPS.QPS_CODMED = QPR.QPR_CHAVE	
										AND QPS.D_E_L_E_T_ = ' '
WHERE			QPK.D_E_L_E_T_ = ' '  AND QPK.QPK_LOTE > '076069' ) -- Excluo as tentativas infrutiferas de importação de dados
ORDER BY LOTE_DAXIA, DATA_ENTRADA, DATA_MEDICAO

--Nome analista ensaiador
--QAA_NOME AS NOME_USR_RESP, usado tambem para COD_USR_DIGIT
SELECT QAA_NOME 
FROM QAA010 QAA 
WHERE QAA.QAA_FILIAL = --QEK_FILIAL
AND  QAA.QAA_MAT = --QER_ENSR
AND QAA.D_E_L_E_T_ = '' 

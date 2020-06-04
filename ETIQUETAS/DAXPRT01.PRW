#Include 'Protheus.ch'
#Include "topconn.ch"
#INCLUDE "TBICONN.CH" // BIBLIOTECA
#Include "rwmake.ch"
/*======================================================================================+
| Programa............:   DAXETQ02.prw                                                  |
| Autores ............:   daniel.buso@totvs.com.br                            			|
| Data................:   22/10/2019                                                    |
| Descricao / Objetivo:   ImpressÃ£o das Etiquetas por Lotes                             |
| Doc. Origem.........:                                                                 |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
 
User Function DAXPRT01()

Private cPorta   	:= "LPT1"
Private cModelo  	:= "ZT230"
Private aItens   	:= {}
Private cProd    	:= ""
Private VQetiq		:= 0 
Private nX

_nConv   := GETADVFVAL("SB1","B1_CONV",xFilial("SB1")+TRBOP->B8_PRODUTO,1,0)
_nQtdOri := TRBOP->B8_QTDORI

If GETADVFVAL("SB1","B1_TIPCONV",xFilial("SB1")+TRBOP->B8_PRODUTO,1,"")=="M"
   VQetiq := (_nQtdOri*_nConv)
ElseIf GETADVFVAL("SB1","B1_TIPCONV",xFilial("SB1")+TRBOP->B8_PRODUTO,1,"")=="D"
   VQetiq := (_nQtdOri/_nConv)
EndIf

If VQetiq < 1
	VQetiq := 1
EndIf

While .T.

		lOk      	:= .F.
		VMensagem 	:= Space(130)
		Vcont 		:= 0

		@ 150,10 to 350,510 DIALOG oDlg TITLE "IMPRESSAO DA ETIQUETAS - LOTES"
        @ 017,020 Say "Qtde. Etiquetas:"
        @ 015,075 Get VQetiq                SIZE 30,20 Pict "9999"
        @ 037,020 Say "Mensagem:"
        @ 035,075 Get VMensagem             SIZE 150,20 Picture "@!"
        @ 065,070 BUTTON "_Confirmar" SIZE 40,12 ACTION  (Close(oDlg),lOk := .T.)
        @ 065,115 BUTTON "C_ancelar"  SIZE 40,12 ACTION  (Close(oDlg),lOk := .F.)
	
        ACTIVATE DIALOG oDlg CENTERED
	
		If lOk	
		   EtiqSql()
		Else
		   Exit
		EndIf
		
End()
Return .T.

//+------------------+-------------------------------------------------------+
//| Nome             | EtiqSql												 |
//+------------------+-------------------------------------------------------+
//| Data de Criacao  | 29/09/2019											 | 	
//+------------------+--------------------------------------------------------
 
Static Function EtiqSql()
Local cQuery 	:= ""
Local lRet   	:= .T.
Local cUsuario 	:= ''
Local cQrq	 	:= ''
	If Select("TRBET") <> 0
	   dbSelectArea("TRBET")
	   dbCloseArea()
	EndIf
	/*
	cQuery := "SELECT DISTINCT B8_LOTECTL, B8_LOTEFOR, B8_PRODUTO, B1_DESC, B1_UM, B8_LOCAL, B8_ORIGEM, B8_QTDORI, B8_DFABRIC, B8_DTVALID, B8_DATA, BZ_XMAT, QAA_NOME, B1_XMSGETQ, B1_PESO, QAA_XCRQ, B1_CONV, B1_CODBAR, B8_XPAISOR, B1_TIPCONV, B8_XCFABRI, B8_XLFABRI, A2_NOME, A2_END, A2_BAIRRO, A2_MUN, A2_EST, A2_CEP, A2_CGC, A2_INSCR, A2_COD , A2_LOJA ,"
	cQuery += "ISNULL(CONVERT(VARCHAR(200), CONVERT(VARBINARY(200), B1_XMSGETQ)),'') AS B1_XMSGETQ"
	cQuery += "  FROM " + RetSqlName("SB8") + " SB8 "
	cQuery += " INNER JOIN "  + RetSqlName("SB1") + " SB1 ON B1_COD     = B8_PRODUTO AND SB1.D_E_L_E_T_ = '' "
	cQuery += "  LEFT JOIN "  + RetSqlName("SA2") + " SA2 ON A2_COD     = B8_XCFABRI AND A2_LOJA = B8_XLFABRI AND SA2.D_E_L_E_T_ = ''"
	cQuery += "  LEFT JOIN "  + RetSqlName("SBZ") + " SBZ ON BZ_FILIAL  = B8_FILIAL  AND BZ_COD  = B8_PRODUTO AND SBZ.D_E_L_E_T_ = ''"
	cQuery += "  LEFT JOIN "  + RetSqlName("QAA") + " QAA ON QAA_FILIAL = BZ_FILIAL  AND BZ_XMAT = QAA_MAT AND QAA.D_E_L_E_T_ = '' "
	cQuery += " WHERE B8_PRODUTO = '"+TRBOP->B8_PRODUTO+"' AND B8_LOTECTL = '"+TRBOP->B8_LOTECTL+"' AND SB8.D_E_L_E_T_ = ''" 
	cQuery += " ORDER BY B8_LOTECTL, B8_LOTEFOR, B8_PRODUTO, B8_DATA"
	
	TCQuery cQuery New Alias "TRBET"
	TRBET->(DBGoTop())
	
	dbSelectArea("TRBET")
	TRBET->(dbGoTop())
	
	If TRBET->(Eof())
	   Alert( "Informacoes da Etiqueta nao encontradas" )
	   Return .F.
	Endif
	*/

	SB8->(DbSetOrder(3))
	If lRet .And. !SB8->(DbSeek(xFilial('SB8') + PADR(TRBOP->B8_PRODUTO,TAMSX3('B8_PRODUTO')[1]) + PADR(TRBOP->LOCAL,TAMSX3('B8_LOCAL')[1]) + PADR(TRBOP->B8_LOTECTL,TAMSX3('B8_LOTECTL')[1])))
		If !SB8->(DbSeek(xFilial('SB8') + PADR(TRBOP->B8_PRODUTO,TAMSX3('B8_PRODUTO')[1]) + PADR(TRBOP->LOCAL,TAMSX3('B8_LOCAL')[1]) ))
			Alert('Saldo por lote não encontrado ou lote não empenhado!')
			lRet := .F.	
		EndIf
	EndIf

	SB1->(DbSetOrder(1))
	If !SB1->(DbSeek(xFilial('SB1') + TRBOP->B8_PRODUTO))
		Alert('Produto não encontrado!')
		lRet := .F.
	EndIf

	SA2->(DbSetOrder(1))
	If !SA2->(DbSeek(xFilial('SA2') + TRBOP->B8_XCFABRI))
		Alert('Fabricante não encontrado!')
		//lRet := .F.
	EndIf

	SBZ->(DbSetOrder(1))
	If lRet .And. !SBZ->(DbSeek(xFilial('SBZ') + TRBOP->B8_PRODUTO ))
		Alert('Indicador de produto não encontrado!')
		lRet := .F.	
	EndIf	

	QAA->(DbSetOrder(1))
	If lRet .And. !QAA->(DbSeek(xFilial('QAA') + SBZ->BZ_XMAT ))
		cUsuario := ''
		cQrq	 := ''
	Else
		cUsuario := QAA->QAA_NOME
		cQrq	 := QAA->QAA_XCRQ
	EndIf		
	
	If lRet
		AADD(aItens,{ ;
		TRBOP->B8_PRODUTO,; 			//1
		SB1->B1_DESC,;					//2
		DTOS(SB8->B8_DFABRIC),;				//3
		DTOS(SB8->B8_DTVALID),;				//4
		SB8->B8_LOTECTL,;				//5
		TRBOP->B8_LOTEFOR,;				//6
		'1',;							//7
		SB8->B8_XPAISOR,;				//8
		Substr(cUsuario,1,15),;				//9
		cQrq,;							//10
		xFilial('SA2') + SA2->A2_COD + SA2->A2_LOJA,; //111
		SB8->B8_LOTEFOR})				//12
		
		// 1 - Codigo
		// 2 - Descrição do produto
		// 3 - Fabricacao
		// 4 - Validade
		// 5 - Lote DA
		// 6 - Lote Forn
		// 7 - Xmantem
		// 8 - Origem
		// 9 - Resp Tecnico
		// 10 - CRQ
		// 11 - Chave do fornecedor
		// 12 - Lotefor
		U_DaxEtq(aItens)
	EndIf
	
Return lRet
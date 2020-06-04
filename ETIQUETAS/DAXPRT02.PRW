	#Include 'Protheus.ch'
#Include "topconn.ch"
#INCLUDE "TBICONN.CH" // BIBLIOTECA
#Include "rwmake.ch"
/*======================================================================================+
| Programa............:   DAXETQ02.prw                                                  |
| Autores ............:   daniel.buso@totvs.com.br                            			|
| Data................:   22/10/2019                                                    |
| Descricao / Objetivo:   ImpressÃ£o das Etiquetas por OPÂ´s                              |
| Doc. Origem.........:                                                                 |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
 
User Function DAXPRT02()
Private aItens   	:= {}
Private cProd    	:= ""
Private VQetiq		:= 0 

_nConv   := GETADVFVAL("SB1","B1_CONV",xFilial("SB1")+TRBLO->C2_PRODUTO,1,0)
_nQtdOri := TRBLO->C2_QUANT

If GETADVFVAL("SB1","B1_TIPCONV",xFilial("SB1")+TRBLO->C2_PRODUTO,1,"")=="M"
   VQetiq := (_nQtdOri*_nConv)
ElseIf GETADVFVAL("SB1","B1_TIPCONV",xFilial("SB1")+TRBLO->C2_PRODUTO,1,"")=="D"
   VQetiq := (_nQtdOri/_nConv)
EndIf

If VQetiq < 1
	VQetiq := 1
EndIf

While .T.

		lOk      	:= .F.
		VMensagem 	:= Space(90)
		Vcont 		:= 0

		@ 150,10 to 350,510 DIALOG oDlg TITLE "IMPRESSAO DAS ETIQUETAS - OP s"
        @ 017,020 Say "Qtde. Etiquetas:"
        @ 015,075 Get VQetiq                SIZE 30,20 Pict "9999"
        @ 037,020 Say "Mensagem:"
        @ 035,075 Get VMensagem             SIZE 150,20 Picture "@!"
        @ 065,070 BUTTON "_Confirmar" SIZE 40,12 ACTION  (Close(oDlg),lOk := .T.)
        @ 065,115 BUTTON "C_ancelar"  SIZE 40,12 ACTION  (Close(oDlg),lOk := .F.)
	
        ACTIVATE DIALOG oDlg  CENTERED
	
		If lOk	
		   EtiqSql2()
		Else
		   Exit
		EndIf
		
Enddo
Return .T.

//+------------------+-------------------------------------------------------+
//| Nome             | EtiqSql2												 |
//+------------------+-------------------------------------------------------+
//| Data de Criacao  | 29/09/2019											 | 	
//+------------------+--------------------------------------------------------
 
Static Function EtiqSql2()
Local lRet     := .T.
Local cUsuario	:= ''
Local cQrq		:= ''
Private cPorta   	:= "LPT1"
Private cModelo  	:= "ZT230"

	If Select("TRBET2") <> 0
	   dbSelectArea("TRBET2")
	   dbCloseArea()
	EndIf
	
	SB1->(DbSetOrder(1))
	If !SB1->(DbSeek(xFilial('SB1') + TRBLO->C2_PRODUTO))
		Alert('Produto não encontrado!')
		lRet := .F.
	EndIf

	SD4->(DbSetOrder(2))
	If lRet .And. !SD4->(DbSeek(xFilial('SD4') +  TRBLO->C2_NUM + TRBLO->C2_ITEM + TRBLO->C2_SEQUEN))
		Alert('Requisições Empenhadas não encontradas!')
		lRet := .F.	
	Else
		While Alltrim(xFilial('SD4') + TRBLO->C2_NUM + TRBLO->C2_ITEM + PADR(TRBLO->C2_SEQUEN,TAMSX3('D4_OP')[1]))  == Alltrim(SD4->(D4_FILIAL + D4_OP ))
			SB1->(DbSetOrder(1))
			If SB1->(DbSeek(xFilial('SB1') + SD4->D4_COD)) .And. !Empty(SB1->B1_XTPCOMP)
				Exit
			EndIf
			SD4->(DbSkip())
		Enddo

		If Empty(SB1->B1_XTPCOMP) //se não encontrar nenhuma preenchida , eu reposiciono na D4
			SD4->(DbSeek(xFilial('SD4') +  TRBLO->C2_NUM + TRBLO->C2_ITEM + TRBLO->C2_SEQUEN ))
		EndIf

	EndIf

	SB8->(DbSetOrder(3))
	If lRet .And. !SB8->(DbSeek(xFilial('SB8') + SD4->D4_COD + SD4->D4_LOCAL + SD4->D4_LOTECTL))
		If !SB8->(DbSeek(xFilial('SB8') + SD4->D4_COD + SD4->D4_LOCAL))
			Alert('Saldo por lote não encontrado ou lote não empenhado!')
			lRet := .F.	
		EndIf
	EndIf

	SBZ->(DbSetOrder(1))
	If lRet .And. !SBZ->(DbSeek(xFilial('SBZ') + TRBLO->C2_PRODUTO ))
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

	SG2->(DbSetOrder(1))
	If lRet .And. !SG2->(DbSeek(xFilial('SG2') + TRBLO->C2_PRODUTO ))
		Alert('Roteiro de Operações não encontrado!')
		lRet := .F.	
	EndIf	

	If lRet
		If SG2->G2_XMAMTEM == '1' .And. SB1->B1_XTPCOMP == '1'
			SB1->(DbSeek(xFilial('SB1') + TRBLO->C2_PRODUTO))
			AADD(aItens,{		TRBLO->C2_PRODUTO, ; 	//1 - Codigo
								SB1->B1_DESC, ;    		//2 - Descrição
								DTOS(SB8->B8_DFABRIC), ;		//3 - Fabricacao
								DTOS(SB8->B8_DTVALID), ;		//4 - Validade
								TRBLO->C2_XLOTE,; 		//5 - Lote DA
								Alltrim(TRBLO->C2_NUM) + '/'+ Alltrim(STR(Year( TRBLO->C2_EMISSAO) )) + IIF(!Empty(SB8->B8_LOTEFOR),'(' + Alltrim(SB8->B8_LOTEFOR) + ')','') ,; //6 - Lote Forn
								SG2->G2_XMAMTEM,;		//7 - XMANTEM
								SB8->B8_XPAISOR,; 		// 8 - Origem
								SUBSTR(cUsuario,1,15), ; // 9 - Resp Tecnico
								cQrq, ; 				// 10 - CRQ
								'',;					// 11 - chave SA2
								SB8->B8_LOTEFOR}) 		// 12 - chave fornecedor
													
		ElseIf SG2->G2_XMAMTEM == '2' .And. SB1->B1_XTPCOMP == '2'
			SB1->(DbSeek(xFilial('SB1') + TRBLO->C2_PRODUTO))	
			AADD(aItens,{		TRBLO->C2_PRODUTO, ; 	//1 - Codigo
								SB1->B1_DESC, ;    	//2 - Descrição
								DTOS(SB8->B8_DFABRIC), ;	//3 - Fabricacao
								DTOS(SB8->B8_DFABRIC + SB1->B1_PRVALID) , ;	//4 - Validade
								TRBLO->C2_XLOTE,; 		//5 - Lote DA
								Alltrim(TRBLO->C2_NUM) + '/'+ Alltrim(STR(Year( TRBLO->C2_EMISSAO) )) + IIF(!Empty(SB8->B8_LOTEFOR),'(' + Alltrim(SB8->B8_LOTEFOR) + ')','') ,; //6 - Lote Forn
								SG2->G2_XMAMTEM,;//7 - XMANTEM
								SB8->B8_XPAISOR,; // 8 - Origem
								SUBSTR(cUsuario,1,15), ; // 9 - Resp Tecnico
								cQrq, ; // 10 - CRQ
								'',;// 11 - chave SA2
								SB8->B8_LOTEFOR}) // 12 - chave fornecedor						
		ElseIf SG2->G2_XMAMTEM == '3' //.And. Empty(SB1->B1_XTPCOMP)

		
			SB1->(DbSeek(xFilial('SB1') + TRBLO->C2_PRODUTO))	
			AADD(aItens,{		TRBLO->C2_PRODUTO, ; 		//1 - Codigo 
								SB1->B1_DESC, ;    	//2 - Descrição
								DTOS(TRBLO->C2_EMISSAO), ;	//3 - Fabricacao
								DTOS(TRBLO->C2_EMISSAO + SB1->B1_PRVALID) , ;	//4 - Validade
								TRBLO->C2_XLOTE,; 		//5 - Lote DA 
								Alltrim(TRBLO->C2_NUM) + '/'+ Alltrim(STR(Year( TRBLO->C2_EMISSAO) )) /*+ IIF(!Empty(SB8->B8_LOTEFOR),'(' + Alltrim(SB8->B8_LOTEFOR) + ')','')*/ ,; //6 - Lote Forn
								SG2->G2_XMAMTEM,;//7 - XMANTEM
								'BRASIL',; // 8 - Origem
								SUBSTR(cUsuario,1,15), ; // 9 - Resp Tecnico
								cQrq, ; // 10 - CRQ
								'',;// 11 - chave SA2
								SB8->B8_LOTEFOR}) // 12 - chave fornecedor													 
		EndIf			
		If Len(aItens) > 0
			U_DaxEtq(aItens)
		Else
			Alert('Não foi possivel imprimir a etiqueta, favor verificar os cadastros.' + CRLF + ' G2_XMANTEM = ' + SG2->G2_XMAMTEM + 'B1_XTPCOMP = ' + SB1->B1_XTPCOMP)
		EndIf
	EndIf
	
Return lRet

//+------------------+-------------------------------------------------------+
//|Nome              | DaxEtq												 |
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
//+------------------+-------------------------------------------------------+
//| Data de Criacao  | 29/09/2019 											 |
//+------------------+--------------------------------------------------------
User Function DaxEtq(aItens)
Local  nY
Local  nLinha := 0
Local  nInterval	:= -6 
Local  nCol1		:= 30
Local  nCol2		:= 60
Local  nCol3		:= 110
Local  cFont		:= "030,030"
Local  cFont2		:= "035,028"

SB1->(DbSetOrder(1))
SB1->(DbSeek(xFilial('SB1') + aItens[1,1]))

For nY := 1 to VQetiq

	MSCBPRINTER(cModelo, cPorta,,,.F.,,,,,,.F.,)
	MSCBCHKSTATUS(.F.)
	MSCBBEGIN(1,6)
	nLinha := 100

	MSCBSay(nLinha,nCol1,'Codigo:'	,"R","0",cFont)
	MSCBSay(nLinha,nCol2, aItens[1,01],"R","0",cFont2)
	nLinha += nInterval
	MSCBSay(nLinha,nCol1,'Produto:'	,"R","0",cFont)
	MSCBSay(nLinha,nCol2,aItens[1,02],"R","0",cFont2)
	nLinha += nInterval
	MSCBSay(nLinha,nCol1,'Fabricacao:                       Validade:                       Lote DA:',"R","0",cFont)
	MSCBSay(nLinha,nCol2,+substr(aItens[1,03],7,2)+"/"+substr(aItens[1,03],5,2)+"/"+substr(aItens[1,03],1,4),"R","0",cFont2) //FABRICACAO
	MSCBSay(nLinha,nCol3,+substr(aItens[1,04],7,2)+"/"+substr(aItens[1,04],5,2)+"/"+substr(aItens[1,04],1,4),"R","0",cFont2) //VALIDADE
	MSCBSay(nLinha,160,aItens[1,05],"R","0",cFont2) //LOTE DA
	MSCBSay(nLinha,180,'Lote : ' + aItens[1,06],"R","0",cFont2) //Lote Forn
	
	//LOTE FORNECEDOR
	//If aItens[1,7] $ '1|2'
	//	MSCBSay(nLinha,168,'('+AllTrim(aItens[1,12])+')',"R","0","030,020")
	//Endif
	nLinha += nInterval
	MSCBSay(nLinha,nCol1,'Origem:                                          Peso Liquido:'	,"R","0",cFont)
	MSCBSay(nLinha,nCol2,aItens[1,8],"R","0",cFont2)
	
	//B1_CONV E PESO LIQUIDO 
	If SB1->B1_CONV <> 0 
		MSCBSay(nLinha,140, Alltrim(Transform(SB1->B1_CONV,"@E 999,999.99")) + ' KG' ,"R","0",cFont2)
	Else 
		MSCBSay(nLinha,140, Alltrim(Transform(SB1->B1_PESO,"@E 999,999.99")) + ' KG' ,"R","0",cFont2)
	Endif
	nLinha += nInterval
	MSCBSay(nLinha,nCol1,'Distribuidor:'	,"R","0",cFont)
	MSCBSay(nLinha,nCol2,'              DAXIA DOCE AROMA INDUSTRIA E COMERCIO LTDA'	,"R","0",cFont2)
	MSCBSay(nLinha,165,'Tec. Resp.:' + aItens[1,09],"R","0",cFont2) //RESPONSAVEL TECNICO
	MSCBSay(nLinha,230,'- CRQ: '+aItens[1,10],"R","0",cFont2) //CRQ
	nLinha += nInterval
	//MENSAGENS 2 LINHAS - IMPRESSAO NEGRITO
	MSCBSay(nLinha,nCol1,substr(SB1->B1_XMSGETQ,1,90),"R","0",cFont2)
	nLinha += nInterval
	MSCBSay(nLinha,nCol1,substr(SB1->B1_XMSGETQ,91,90),"R","0",cFont2)
	nLinha += nInterval
	MSCBSay(nLinha,nCol1,substr(SB1->B1_XMSGETQ,181,90),"R","0",cFont2)
	nLinha += nInterval			
	//MENSAGEM JUNTO COM A QUANTIDADE	
	MSCBSay(nLinha,nCol1,Substr(VMensagem,1,90),"R","0",cFont2)
	
	//QTCODE
	MSCBWRITE("^FT101,408^BQN,4,8^FH\^FDMA,"+AllTrim(SB1->B1_CODBAR)+"|"+AllTrim(aItens[1,05])+"|"+Alltrim(Transform(SB1->B1_CONV,"@E 9,999.99"))+"^FS")
	
	//ULTIMA LINHA INFORMACOES DA EMPRESA
	If !Empty(aItens[1,11])
		SA2->(DbSetOrder(1))
		If SA2->(DbSeek(aItens[1,11]))
			MSCBSay(013,nCol1, SM0->M0_NOMECOM+' / '+'CNPJ '+SM0->M0_CGC+ ' / ' + 'IE: '+SM0->M0_INSC+' / '+SM0->M0_ENDENT+' - '+AllTrim(SM0->M0_CIDENT)+'/'+SM0->M0_ESTENT+' - '+SM0->M0_CEPENT,"R","0","015,015")
			MSCBSay(008,nCol1, 'FAB POR: CNPJ: '+AllTrim(Transform(SA2->A2_CGC, "@R 99.999.999/9999-99"))+' / '+AllTrim(SA2->A2_NOME)+' / '+'IE: '+AllTrim(Transform(SA2->A2_INSCR, "@R 999.999.999.999"))+' - '+AllTrim(SA2->A2_END)+' '+AllTrim(SA2->A2_BAIRRO)+' - '+AllTrim(SA2->A2_MUN)+'/'+AllTrim(SA2->A2_EST)+' - '+AllTrim(Transform(SA2->A2_CEP, "@R 99999-999")),"R","0","015,015")
		Else
			MSCBSay(013,nCol1, SM0->M0_NOMECOM+' / '+'CNPJ '+SM0->M0_CGC+ ' / ' + 'IE: '+SM0->M0_INSC+' / '+SM0->M0_ENDENT+' - '+AllTrim(SM0->M0_CIDENT)+'/'+SM0->M0_ESTENT+' - '+SM0->M0_CEPENT,"R","0","015,015")
			MSCBSay(008,nCol1, 'FAB POR: CNPJ: '+AllTrim(Transform(SM0->M0_CGC, "@R 99.999.999/9999-99"))+' / '+AllTrim(SM0->M0_NOMECOM)+' / '+'IE: '+AllTrim(Transform(SM0->M0_INSC, "@R 999.999.999.999"))+' - '+AllTrim(SM0->M0_ENDENT)+' '+AllTrim(SM0->M0_BAIRENT)+' - '+AllTrim(SM0->M0_CIDENT)+'/'+AllTrim(SM0->M0_ESTENT)+' - '+AllTrim(Transform(SM0->M0_CEPENT, "@R 99999-999")),"R","0","015,015")		
		EndIf
	Else	
		MSCBSay(013,nCol1, SM0->M0_NOMECOM+' / '+'CNPJ '+SM0->M0_CGC+ ' / ' + 'IE: '+SM0->M0_INSC+' / '+SM0->M0_ENDENT+' - '+AllTrim(SM0->M0_CIDENT)+'/'+SM0->M0_ESTENT+' - '+SM0->M0_CEPENT,"R","0","015,015")
		MSCBSay(008,nCol1, 'FAB POR: CNPJ: '+AllTrim(Transform(SM0->M0_CGC, "@R 99.999.999/9999-99"))+' / '+AllTrim(SM0->M0_NOMECOM)+' / '+'IE: '+AllTrim(Transform(SM0->M0_INSC, "@R 999.999.999.999"))+' - '+AllTrim(SM0->M0_ENDENT)+' '+AllTrim(SM0->M0_BAIRENT)+' - '+AllTrim(SM0->M0_CIDENT)+'/'+AllTrim(SM0->M0_ESTENT)+' - '+AllTrim(Transform(SM0->M0_CEPENT, "@R 99999-999")),"R","0","015,015")
	EndIf

	MSCBEND()
	MSCBCLOSEPRINTER()

Next nY

Return()

/*/{Protheus.doc} QbPalavra(cLinha)

	(long_descriaLinhas
	@type  Static Function
	@author user
	@since date
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function QbPalavra(cLinha)
Local aRet 		:= {}
Local cAux		:= ''
Local cPalavra	:= ''
Local n			:= 0
Local nTam		:= 0
Local nI		:= 0
Local aLinhas	:= {}

While Len(cAux) <= 90
	cPalavra 	:= ''
	n			:= 1
	While SUBSTR(cLinha,n,1) <> ' '
		cPalavra += SUBSTR(cLinha,n,1)
		n++
	EndDo
	If Len(cAux + cPalavra) > 90
		Exit
	Else
		cAux += ' ' + cPalavra
	EndIf
EndDo

aadd(aLinhas,cAux)


While Len(cAux) <= 90
	cPalavra 	:= ''
	n			:= 1
	While SUBSTR(cLinha,n,1) <> ' '
		cPalavra += SUBSTR(cLinha,n,1)
		n++
	EndDo
	If Len(cAux + cPalavra) > 90
		Exit
	Else
		cAux += ' ' + cPalavra
	EndIf
EndDo
aadd(aLinhas,cAux)

Return aLinhas
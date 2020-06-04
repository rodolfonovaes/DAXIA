#INCLUDE 'PROTHEUS.CH'         

USER FUNCTION DMMDF002() // FUNÇÃO DUMMY
LOCAL cMsg  := ""
LOCAL cTipo := FWInputBox("Informe a Tipo de Mensagem R-Remessa e N-Normal", "")

DBSELECTAREA("SA1")
DBSETORDER(1)
DBSELECTAREA("SC5")
DBSETORDER(1)
// POSICIONO A NOTA FISCAL
DBSELECTAREA("SC5")
DBSETORDER(1)
IF DBSEEK(xFilial("SC5")+"000798")
	cMsg := U_DAXF002(cTipo)
ENDIF

RETURN cMsg
/*
+==========================================================================================+
| Programa............:   DAXF002                                                          |
| Autor(es)...........:   Cicero Odilio Cruz                                               |
| Data................:   20/10/2019                                                       |
| Descricao / Objetivo:   Implementa Mensagem no caso da Venda por Conta e Ordem           |
|						  NOTA NORMAL (Tipo N - Venda  ) FORMULA 149                       | 
|						  NOTA NORMAL (Tipo R - Normal ) FORMULA 154                       |
| Doc. Origem.........:   N/A                                                              |
| Solicitante.........:   TOTVS Ibirapuera                                                 |
| Uso.................:   Módulo Faturamento - Nota Fiscal de Saída                        |
| Obs.................:                                                                    |
+==========================================================================================+
*/ 
USER FUNCTION DAXF002(cMsgTp)
LOCAL aArea     := GetArea()
LOCAL aAreaSC5  := SC5->(GetArea())
LOCAL aAreaSA1  := SA1->(GetArea())
LOCAL cMsg  	:= " "
LOCAL cNome 	:= " "
LOCAL cEnd  	:= " "
LOCAL cMun		:= " "
LOCAL cEst		:= " "
LOCAL cInscr	:= " "
LOCAL cCNPJ		:= " "
LOCAL cPedRef   := SC5->C5_XPEDVIN
LOCAL cCGCPict	:= PesqPict("SA1","A1_CGC")

DEFAULT cMsgTp := "N"

IF !EMPTY(ALLTRIM(cPedRef)) 
	DBSELECTAREA("SC5") // POSIONAR O PEDIDO DE VENDA REFERENCIA PARA  BUSCAR OS DADOS DELES
	DBSETORDER(1)   //Filial + Ped. Venda
	IF !DbSeek(xFilial("SC5")+cPedRef) // SP001: CASO NÃO ENCONTRAR O PEDIDO REFERENCIA
		Help( ,, "Help",,"DAXF002 (001) Dados do Pedido de Venda Remessa ("+cPedRef+") não encontrados!", 1, 0 ) 
		RETURN cMsg
	ELSEIF SD2->D2_ITEM == "01" // MENSAGEM SÓ PARA O PRIMEIRO ITEM
	
		cNome 	:= POSICIONE( "SA1", 1, xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI, ALLTRIM("A1_NOME")  ) 
		cEnd  	:= POSICIONE( "SA1", 1, xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI, ALLTRIM("A1_END")   ) 
		cMun	:= POSICIONE( "SA1", 1, xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI, ALLTRIM("A1_MUN")   ) 
		cEst	:= POSICIONE( "SA1", 1, xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI, ALLTRIM("A1_EST")   ) 
		cInscr	:= POSICIONE( "SA1", 1, xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI, ALLTRIM("A1_INSCR") ) 
		cCNPJ	:= POSICIONE( "SA1", 1, xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI, ALLTRIM("A1_CGC")   ) 

		IF cMsgTp == "N"
		
			cMsg  := "Mercadoria enviada para a empresa "
			cMsg  += ALLTRIM(cNome)
			cMsg  += ", localizada a " 
			cMsg  += ALLTRIM(cEnd)
			cMsg  += " - " 
			cMsg  += ALLTRIM(cMun)
			cMsg  += " - " 
			cMsg  += ALLTRIM(cEst)
			cMsg  += " - IE: " 
			cMsg  += ALLTRIM(cInscr)
			cMsg  += " - CNPJ:" 
			cMsg  +=  Transform( cCNPJ, cCgcPict )	
			cMsg  += " por sua conta e ordem."

		ELSEIF cMsgTp == "R"

			cMsg  := "REMESSA POR ORDEM DE: " 
			cMsg  += ALLTRIM(cNome)
			cMsg  += ", " 
			cMsg  += ALLTRIM(cEnd)
			cMsg  += " - " 
			cMsg  += ALLTRIM(cMun)
			cMsg  += " - " 
			cMsg  += ALLTRIM(cEst)
			cMsg  += " - IE: " 
			cMsg  += ALLTRIM(cInscr)
			cMsg  += " - CNPJ:" 
			cMsg  += Transform( cCNPJ, cCgcPict )	
			cMsg  += " - venda de mercadoria de terceiros e remessa por conta do Adquirente."

		ENDIF

	ENDIF
ENDIF

RestArea(aAreaSA1)
RestArea(aAreaSC5)
RestArea(aArea)
RETURN cMsg

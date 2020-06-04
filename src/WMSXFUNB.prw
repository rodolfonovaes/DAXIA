#INCLUDE "PROTHEUS.CH"
#INCLUDE "WMSXFUNB.CH"
#define CLRF  Chr(13)+Chr(10)
/*
+---------+--------------------------------------------------------------------+
|Fun��o   | WMSXFUNB                                                           |
+---------+--------------------------------------------------------------------+
|Autor    | Jackson Patrick Werka                                              |
+---------+--------------------------------------------------------------------+
|Data     | 21/03/2014                                                         |
+---------+--------------------------------------------------------------------+
|Objetivo | Esta fun��o tem por objetivo reunir todas as informa��es relativas |
|         | a ordens de servi�o no WMS, como cria��o, avalia��o, exclus�o,     |
|         | estorno, entre outras funcionalidades que estejam relacionadas com |
|         | as ordens de servi�o WMS.                                          |
+---------+--------------------------------------------------------------------+

*/

Static lMntVol := SuperGetMV('MV_WMSVEMB',.F.,.F.)

/*------------------------------------------------------------------------------
------------------------------------------------------------------------------*/
Function WmsTipServ(cServico)
Local aAreaAnt := GetArea()
Local aAreaDC5 := DC5->(GetArea())
Local cTipServ := ""

	DbSelectArea("DC5")
	DC5->(DbSetOrder(1))
	If DC5->(MsSeek(xFilial("DC5")+cServico))
		cTipServ := DC5->DC5_TIPO
	EndIf

RestArea(aAreaDC5)
RestArea(aAreaAnt)
Return cTipServ

/*------------------------------------------------------------------------------
------------------------------------------------------------------------------*/
Function WmsPosDCF(cIdDCF)
Local aAreaAnt  := GetArea()
Local cQuery    := ""
Local cAliasDCF := ""
Local lRet      := .F.

DbSelectArea("DCF")
//-- Se o identificador da OS for diferente do posicionado
If !Empty(cIdDCF)
	If DCF->DCF_ID == cIdDCF
		lRet := .T.
	Else
		cAliasDCF := GetNextAlias()
		cQuery := "SELECT DCF.R_E_C_N_O_ RECNODCF"
		cQuery +=  " FROM "+RetSqlName("DCF")+" DCF"
		cQuery += " WHERE DCF.DCF_FILIAL = '"+xFilial("DCF")+"'"
		cQuery +=   " AND DCF.DCF_ID     = '"+cIdDCF+"'"
		cQuery +=   " AND DCF.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasDCF,.F.,.T.)
		If (cAliasDCF)->(!Eof())
			DCF->(DbGoTo((cAliasDCF)->RECNODCF))
			lRet := .T.
		EndIf
		(cAliasDCF)->(DbCloseArea())
	EndIf
EndIf

RestArea(aAreaAnt)
Return lRet

/*------------------------------------------------------------------------------
------------------------------------------------------------------------------*/
Function WmsAvalDCF(cAcao,cIdDCF,lExibeMsg)
Local aAreaAnt  := GetArea()
Local lRet      := .F.
Local nWmsVlEP  := SuperGetMV("MV_WMSVLEP",.F.,1)   // Tratamento da OS WMS no estorno da libera��o do pedido
Local cStatInte := SuperGetMV('MV_RFSTINT',.F.,'3') // DB_STATUS indincando Atividade Interrompida (Em execu��o)
Local lEstPed   := .F.

Default cIdDCF    := ""
Default lExibeMsg := WmsMsgExibe()

//-- Caso a DCF n�o esteja posicionada corretamente
If !Empty(cIdDCF)
	If !WmsPosDCF(cIdDCF)
		WmsMessage("SIGAWMS - "+STR0001+AllTrim(cIdDCF)+".","WmsAvalDCF",1,lExibeMsg) //"N�o foi poss�vel encontrar a OS pelo identificador "
		RestArea(aAreaAnt)
		Return lRet
	EndIf
EndIf

If cAcao == '1' //-- Alterar
	//-- Falta definir ainda
ElseIf cAcao == '2' //-- Excluir
	If !(lRet:=DCF->DCF_STSERV $ "1|2")
		If Type("lEstPedDAK")=='L'
			lEstPed := lEstPedDAK
		EndIf
		// Assume valor padr�o caso o par�metro tenha sido preenchido de forma inconsistente
		If nWmsVlEP < 1 .Or. nWmsVlEP > 3
			nWmsVlEP := 1
		EndIf
		// Se n�o estiver sendo chamado da rotina de gera��o das notas fiscais de sa�da
		If (IsInCallStack("Mata460a") .Or. (IsInCallStack("WmsAvalDAK") .And. lEstPed)) .And. nWmsVlEP <> 1
			//Verifica se alguma das atividades est� em andamento pelo WMS
			If WmsChkSDB("1",,,"('"+cStatInte+"')")
				cMensagem := "SIGAWMS - OS "+AllTrim(DCF->DCF_DOCTO)+Iif(!Empty(DCF->DCF_SERIE),"/"+AllTrim(SerieNfId("DCF",2,"DCF_SERIE")),"")+STR0013+AllTrim(DCF->DCF_CODPRO)+CLRF
				cMensagem += STR0020+CRLF // "Existem atividades em andamento para esta ordem de servi�o."
				cMensagem += STR0021      // "Finalize as atividades ou estorne o processo WMS manualmente."
				WmsMessage(cMensagem,"WmsAvalDCF",1,lExibeMsg)
			Else
				// STR0019
				// Confirma o estorno da libera��o do pedido sem estornar o processo WMS manualmente?
				// Em caso positivo, a ordem de servi�o WMS ser� cancelada e o saldo dos produtos ser�
				// mantido na doca sem empenho, aguardando a sua utiliza��o por outro pedido.
				If nWmsVlEP == 2 .Or. (nWmsVlEP == 3 .And. (!lWmsPergEP .Or. WmsMessage(STR0019,"WmsAvalDCF",3)))
					lRet       := .T.
					lWmsPergEP := .F. // Pegunta apenas uma vez
				EndIf
			EndIf
		Else
			//Verifica se a ordem de servi�o possui servi�o com execu��o autom�tica
			If WmsVldSrv('4',DCF->DCF_SERVIC)
				//Verifica se alguma das atividades est� em andamento ou finalizada pelo WMS
				lRet := !WmsChkSDB("1")
				If !lRet
					cMensagem := "SIGAWMS - OS "+AllTrim(DCF->DCF_DOCTO)+Iif(!Empty(DCF->DCF_SERIE),"/"+AllTrim(SerieNfId("DCF",2,"DCF_SERIE")),"")+STR0013+AllTrim(DCF->DCF_CODPRO)+CLRF
					cMensagem += STR0002+CLRF //"Existem atividades em andamento ou finalizadas para esta"
					cMensagem += STR0003+CLRF //"ordem de servi�o pelo processo WMS."
					cMensagem += STR0005 //"Dever� ser estornado o processo WMS manualmente."
					WmsMessage(cMensagem,"WmsAvalDCF",1,lExibeMsg)
				EndIf
			Else
				cMensagem := "SIGAWMS - OS "+AllTrim(DCF->DCF_DOCTO)+Iif(!Empty(DCF->DCF_SERIE),"/"+AllTrim(SerieNfId("DCF",2,"DCF_SERIE")),"")+STR0013+AllTrim(DCF->DCF_CODPRO)+CLRF
				cMensagem += STR0004+CLRF //"A ordem de servi�o j� foi executada pelo processo WMS."
				cMensagem += STR0005 //"Dever� ser estornado o processo WMS manualmente."
				WmsMessage(cMensagem,"WmsAvalDCF",1,lExibeMsg)
			EndIf
		EndIf
	EndIf
ElseIf cAcao == '3' //-- Estornar
	If !(lRet:=DCF->DCF_STSERV $ '2|3')
		cMensagem := "SIGAWMS - OS "+AllTrim(DCF->DCF_DOCTO)+Iif(!Empty(DCF->DCF_SERIE),"/"+AllTrim(SerieNfId("DCF",2,"DCF_SERIE")),"")+STR0013+AllTrim(DCF->DCF_CODPRO)+CLRF
		cMensagem += STR0006 //"A situa��o da OS n�o permite estorno."
		WmsMessage(cMensagem,"WmsAvalDCF",1,lExibeMsg)
	EndIf
EndIf

RestArea(aAreaAnt)
Return lRet

/*
+----------+----------+-------+------------------------------+------+----------+
|Fun��o    |WmsCriaDCF| Autor |Jackson Patrick Werka         | Data |21.03.2014|
+----------+----------+-------+------------------------------+------+----------+
|Descri��o |Gravar dados no Arquivo DCF                                        |
+----------+-------------------------------------------------------------------+
|Sintaxe   |WmsCriaDCF(ExpC1,ExpN1,ExpC2,ExpL1)                                |
+----------+-------------------------------------------------------------------+
|Parametros|ExpC1 = Alias Origem do Lancamento a ser gravado no DCF.           |
|          |        (DCF, DBN, SC9 ou SDA)                                     |
|          |        E necessario que o ponteiro deste alias esteja posicionado |
|          |        no registro correto.                                       |
|          |ExpN1 = Tipo de apanhe (1=Produto/2=Cliente).                      |
|          |ExpC2 = Codigo do servico a ser gerado.                            |
|          |        Se NAO for passado a funcao ira utilizar o servico         |
|          |        constante no respectivo campo de servico.                  |
|          |        Se passado, o sistema ira gerar um DCF utilizando o        |
|          |        servico passado. Se o servico passado estiver em           |
|          |        branco (diferente de NIL) o DCF sera gerado SEM            |
|          |        servico, devendo ser "definido" posteriormente pela        |
|          |        rotina de O.S. manual.                                     |
|          |ExpA1 = Vetor contendo dados para gera��o e execu��o da            |
|          |        O.S.WMS sem atualizar o estoque.                           |
|          |ExpN2 = Nr.do novo registro(DCF) gerado pela funcao, na            |
|          |        geracao e execucao da O.S.WMS sem atualizar estoque.       |
+----------+-------------------------------------------------------------------+
|Uso       | EST/PCP/FAT/COM/OMS/WMS                                           |
+----------+-------------------------------------------------------------------+*/
Function WmsCriaDCF(cAliasOrig, nTpApanhe, cServPad, aParam, nPosDCF )

Local aAreaAnt  := GetArea()
Local aAreaAux  := {}
Local aAreaDCF  := {}
Local cServico  := ''
Local cDoc      := ''
Local cSerie    := ''
Local cProduto  := ''
Local cCliFor   := ''
Local cLoja     := ''
Local cStServ   := ''
Local cOrigem   := ''
Local cNumSeq   := ''
Local cSequen   := ''
Local cArmazem  := ''
Local cEstrFis  := ''
Local cRegra    := ''
Local cEndere   := ''
Local cLoteCtl  := ''
Local cNumLote  := ''
Local cPriori   := ''
Local cCodFun   := ''
Local cCarga    := ''
Local cUnitiz   := ''
Local cNorma    := ''
Local cSeekSD1  := ''
Local cSeekSD3  := ''
Local dData     := CtoD('  /  /  ')
Local lRet      := IntWMS()
Local lRetPE    := .F.
Local nQuant    := 0
Local nQuant2UM := 0
Local cIdDCF    := 0
Local lInclusao := .T.
Local lA240Arm  := .F.
Local lA240End  := .F.

Default cAliasOrig := ''
Default nTpApanhe  := 2
Default cServPad   := Nil
Default aParam     := {}
Default nPosDCF    := 0

If lRet
	If cAliasOrig == 'DBN'
		//�����������������������������������������������������������������������Ŀ
		//� Utiliza os Dados da Carga Unitizada (DBN)                             �
		//�������������������������������������������������������������������������
		DbSelectArea('DBN')
		cServico := DBN->DBN_SERVIC
		cDoc     := DBN->DBN_PEDIDO
		cSerie   := DBN->DBN_ITEM
		dData    := DBN->DBN_DATA
		cProduto := DBN->DBN_CODPRO
		cCliFor  := DBN->DBN_CODCLI
		cLoja    := DBN->DBN_LOJA
		cStServ  := DBN->DBN_STSERV
		nQuant   := DBN->DBN_QTDE
		cOrigem  := 'DBN'
		cArmazem   := DBN->DBN_LOCAL
		SC9->(DbSetOrder(1))
		SC9->(DbSeek(xFilial('SC9')+cDoc+cSerie+cSequen+cProduto))
		cRegra   := SC9->C9_REGWMS
		cLoteCtl := SC9->C9_LOTECTL
		cNumLote := SC9->C9_NUMLOTE
		cEndere  := SC9->C9_ENDPAD
		cCarga   := DBN->DBN_CARGA
		cUnitiz  := DBN->DBN_UNITIZ
		//-- Recebe as variaveis de Endereco e Estrutura Fisica do OMSA200
		If !(Type('cOMS200End')=='U') .And. !Empty(cOMS200End)
			cEndere := cOMS200End
		EndIf
		If !Empty(aParam)
			cServico := aParam[1]
			nQuant   := aParam[2]
		EndIf
	ElseIf cAliasOrig == 'SC9'
		//�����������������������������������������������������������������������Ŀ
		//� Utiliza os Dados do Pedido de Vendas Liberado                         �
		//�������������������������������������������������������������������������
		DbSelectArea('SC9')
		cServico := SC9->C9_SERVIC
		cDoc     := SC9->C9_PEDIDO
		cSerie   := SC9->C9_ITEM
		dData    := SC9->C9_DATALIB
		cProduto := SC9->C9_PRODUTO
		cStServ  := SC9->C9_STSERV
		nQuant   := SC9->C9_QTDLIB
		cOrigem  := 'SC9'
		cArmazem   := SC9->C9_LOCAL
		cRegra   := SC9->C9_REGWMS
		// Verifica informacoes de lote/sub-lote
		If Empty(cRegra) .And. !Empty(SC9->C9_LOTECTL+SC9->C9_NUMLOTE)
			cRegra := "1"
		EndIf
		cLoteCtl := SC9->C9_LOTECTL
		cNumLote := SC9->C9_NUMLOTE
		cCarga   := SC9->C9_CARGA
		//�����������������������������������������������������������������������Ŀ
		//� Posicionar o Cabecalho do Pedido (SC5)                                �
		//�������������������������������������������������������������������������
		SC5->(DbSetOrder(1))
		If SC5->(DbSeek(xFilial('SC5')+SC9->C9_PEDIDO, .F.))
			cCliFor := SC5->C5_CLIENTE
			cLoja   := SC5->C5_LOJACLI
		EndIf
		cEndere  := SC9->C9_ENDPAD
		If !Empty(aParam)
			cServico := aParam[1]
			nQuant   := aParam[2]
		EndIf
	ElseIf cAliasOrig == 'SDA'
		//�����������������������������������������������������������������������Ŀ
		//� Utiliza os Dados do Arquivo de Produtos a Distribuir (SDA)            �
		//�������������������������������������������������������������������������
		DbSelectArea('SDA')
		cServico := '' //-- Utiliza dados do Arquivo Origem (DA_ORIGEM)
		cDoc     := SDA->DA_DOC
		cSerie   := SDA->DA_SERIE
		dData    := SDA->DA_DATA
		cProduto := SDA->DA_PRODUTO
		cCliFor  := SDA->DA_CLIFOR
		cLoja    := SDA->DA_LOJA
		cStServ  := '' //-- Utiliza dados do Arquivo Origem (DA_ORIGEM)
		nQuant   := (SDA->DA_SALDO-SDA->DA_EMPENHO)
		cOrigem  := SDA->DA_ORIGEM
		cNumSeq  := SDA->DA_NUMSEQ
		cArmazem := SDA->DA_LOCAL
		cRegra   := SDA->DA_REGWMS
		cLoteCtl := SDA->DA_LOTECTL
		cNumLote := SDA->DA_NUMLOTE

		If !Empty(aParam) .And. QtdComp(aParam[2]) > QtdComp(0)
			cServico := aParam[1]
			nQuant   := aParam[2]
			cEndere  := aParam[3]
		//�����������������������������������������������������������������������Ŀ
		//� Define o codigo de Servico e o Status                                 �
		//�������������������������������������������������������������������������
		ElseIf cOrigem == 'SD1'
			DbSelectArea('SD1')
			aAreaAux := GetArea()
			SD1->(DbSetOrder(1)) //-- D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
			If SD1->(DbSeek(cSeekSD1:=xFilial('SD1')+cDoc+cSerie+cCliFor+cLoja+cProduto, .F.))
				Do While SD1->(!Eof()) .And. cSeekSD1 == SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_COD
					If cNumSeq == SD1->D1_NUMSEQ
						cServico := SD1->D1_SERVIC
						cStServ  := SD1->D1_STSERV
						cEndere  := SD1->D1_ENDER
						cNorma := SD1->D1_CODNOR
						Exit
					EndIf
					SD1->(DbSkip())
				EndDo
			EndIf
			RestArea(aAreaAux)
		ElseIf cOrigem == 'SD2'
			If !(cServPad==Nil)
				cServico := cServPad
				cStServ  := '1'
			Else
				//-- Pesquisa Servico Padrao p/ Entradas ref. excl. Nota Fiscal de Saida
				SB5->(DbSetOrder(1))
				If SB5->(DbSeek(xFilial('SB5')+cProduto, .F.) .And. !Empty(B5_SERVENT))
					cServico   := SB5->B5_SERVENT
				Else
					cServPad := CriaVar('DCF_SERVIC')
				EndIf
				cStServ  := '1'
			EndIf
			// Se o processo de sa�da n�o � feito pelo WMS, o saldo de um mesmo produto � consumido de endere�os diferentes e
			// na exclusao da NF de sa�da for selecionada a op��o de redistribuir produtos, o sistema tentar� gerar duas DCFs
			// com a mesma chave. Neste caso, dever� avaliar se j� existe uma OS com a chave informada e apenas increment�-la.
			If WmsChkDCF(cOrigem,,,cServico,'1',,cDoc,cSerie,cCliFor,cLoja,cArmazem,cProduto,cLoteCtl,cNumLote,cNumSeq,,@nPosDCF,'1')
				DCF->(DbGoTo(nPosDCF))
				lInclusao := .F.
			EndIf
		ElseIf cOrigem == 'SD3'
			lA240Arm := !(Type('cA240Arm') == 'U') .And. !Empty(cA240Arm)
			lA240End := !(Type('cA240End') == 'U') .And. !Empty(cA240End)
			DbSelectArea('SD3')
			aAreaAux := GetArea()
			SD3->(DbSetOrder(3))
			If DbSeek(cSeekSD3:=xFilial('SD3')+cProduto+cArmazem+cNumSeq, .F.)
				Do While SD3->(!Eof()) .And. cSeekSD3 == SD3->D3_FILIAL+SD3->D3_COD+SD3->D3_LOCAL+SD3->D3_NUMSEQ
					If !Empty(SD3->D3_SERVIC)
						cServico := SD3->D3_SERVIC
						cStServ  := SD3->D3_STSERV
						cArmazem := SD3->D3_LOCAL
						cEndere  := SD3->D3_LOCALIZ
						//-- Recebe as variaveis de Endereco e Estrutura Fisica dos MATA240 e MATA241
						If lA240Arm
							cArmazem := cA240Arm
						EndIf
						If lA240End
							cEndere := cA240End
						EndIf
						Exit
					EndIf
					SD3->(DbSkip())
				EndDo
			EndIf
			RestArea(aAreaAux)
		ElseIf cOrigem == 'SCM'
			DbSelectArea('SCM')
			aAreaAux := GetArea()
			SCM->(DbSetOrder(9))
			If SCM->(DbSeek(xFilial('SCM')+cDoc+cNumSeq, .F.))
				cServico := SCM->CM_SERVIC
				cStServ  := SCM->CM_STSERV
				cEndere  := SCM->CM_ENDER
			EndIf
			RestArea(aAreaAux)
		ElseIf cOrigem == 'SCN'
			DbSelectArea('SCN')
			aAreaAux := GetArea()
			SCN->(DbSetOrder(6))
			If SCN->(DbSeek(xFilial('SCN')+DtoS(dData)+cNumSeq, .F.))
				cServico := SCN->CN_SERVIC
				cStServ  := SCN->CN_STSERV
				cEndere  := SCN->CN_ENDER
			EndIf
			RestArea(aAreaAux)
		EndIf
	ElseIf cAliasOrig == 'SD1'
		//�����������������������������������������������������������������������Ŀ
		//� Utiliza os Dados do Arquivo de Nota Fiscal de Entrada (SD1)           �
		//�������������������������������������������������������������������������
		DbSelectArea('SD1')
		cServico := SD1->D1_SERVIC
		cDoc     := SD1->D1_DOC
		cSerie   := SD1->D1_SERIE
		dData    := SD1->D1_DTDIGIT
		cProduto := SD1->D1_COD
		cCliFor  := SD1->D1_FORNECE
		cLoja    := SD1->D1_LOJA
		cStServ  := SD1->D1_STSERV
		nQuant   := SD1->D1_QUANT
		cOrigem  := 'SD1'
		cNumSeq  := SD1->D1_NUMSEQ
		cArmazem := SD1->D1_LOCAL
		cRegra   := SD1->D1_REGWMS
		cEndere  := SD1->D1_ENDER
		cLoteCtl := SD1->D1_LOTECTL
		cNumLote := SD1->D1_NUMLOTE
		cNorma := SD1->D1_CODNOR
	ElseIf cAliasOrig == 'SD3'
		//�����������������������������������������������������������������������Ŀ
		//� Utiliza os Dados do Arquivo de Movimentacoes Internas (SD3)           �
		//�������������������������������������������������������������������������
		DbSelectArea('SD3')
		cServico := SD3->D3_SERVIC
		cDoc     := SD3->D3_DOC
		dData    := SD3->D3_EMISSAO
		cProduto := SD3->D3_COD
		cStServ  := SD3->D3_STSERV
		nQuant   := SD3->D3_QUANT
		cOrigem  := 'SD3'
		cNumSeq  := SD3->D3_NUMSEQ
		cArmazem := SD3->D3_LOCAL
		cRegra   := SD3->D3_REGWMS
		cEndere  := SD3->D3_LOCALIZ
		cLoteCtl := SD3->D3_LOTECTL
		cNumLote := SD3->D3_NUMLOTE
		//-- Recebe as variaveis de Endereco e Estrutura Fisica dos MATA240 e MATA241
		If !(Type('cA240Arm')=='U') .And. !Empty(cA240Arm)
			cArmazem := cA240Arm
		EndIf
		If !(Type('cA240End')=='U') .And. !Empty(cA240End)
			cEndere := cA240End
		EndIf
	ElseIf cAliasOrig == 'SDB'
		//�����������������������������������������������������������������������Ŀ
		//� Utiliza os Dados do Arquivo de Movimentacoes de Enderecamento (SDB)   �
		//�������������������������������������������������������������������������
		DbSelectArea('SDB')
		cServico := SDB->DB_SERVIC
		cDoc     := SDB->DB_DOC
		cSerie   := SDB->DB_SERIE
		dData    := SDB->DB_DATA
		cProduto := SDB->DB_PRODUTO
		cCliFor  := SDB->DB_CLIFOR
		cLoja    := SDB->DB_LOJA
		cStServ  := '1'
		nQuant   := SDB->DB_QUANT
		cOrigem  := 'SDB'
		cNumSeq  := SDB->DB_NUMSEQ
		cArmazem := SDB->DB_LOCAL
		cRegra   := SDB->DB_REGWMS
		cEndere  := SDB->DB_ENDDES
		cLoteCtl := SDB->DB_LOTECTL
		cNumLote := SDB->DB_NUMLOTE
		cCarga   := SDB->DB_CARGA
		cUnitiz  := SDB->DB_UNITIZ
	ElseIf cAliasOrig == 'SD2'
		//�����������������������������������������������������������������������Ŀ
		//� Utiliza os Dados do Arquivo de ITENS DA NOTA FISCAL DE SAIDA(SD2)     �
		//�������������������������������������������������������������������������
		DbSelectArea('SD2')
		cServico := SD2->D2_SERVIC
		cDoc     := SD2->D2_DOC
		cSerie   := SD2->D2_SERIE
		dData    := SD2->D2_EMISSAO
		cProduto := SD2->D2_COD
		cCliFor  := SD2->D2_CLIENTE
		cLoja    := SD2->D2_LOJA
		cStServ  := SD2->D2_STSERV
		nQuant   := SD2->D2_QUANT
		cOrigem  := 'SD2'
		cNumSeq  := SD2->D2_NUMSEQ
		cArmazem := SD2->D2_LOCAL
		cRegra   := SD2->D2_REGWMS
		cLoteCtl := SD2->D2_LOTECTL
		cNumLote := SD2->D2_NUMLOTE
	ElseIf cAliasOrig == 'DCF' .Or. cAliasOrig == 'SD4'
		cProduto := aParam[01]
		cArmazem := aParam[02]
		cDoc     := aParam[03]
		cSerie   := aParam[04]
		cNumSeq  := aParam[05]
		nQuant   := aParam[06]
		dData    := aParam[07]
		cServico := aParam[09]
		cCliFor  := aParam[12]
		cLoja    := aParam[13]
		cOrigem  := aParam[17]
		cRegra   := aParam[22]
		cCarga   := aParam[23]
		cEndere  := aParam[26]
	EndIf
EndIf
If !Empty(cEndere)
	cEstrFis := Posicione('SBE',1,xFilial('SBE')+cArmazem+cEndere,'BE_ESTFIS')
Else
	cEstrFis := CriaVar('DCF_ESTFIS')
EndIf

lRet := (lRet.And.If(!(cServPad==Nil),.T.,!Empty(cServico))) //-- O Servico (ou Servico Padrao) deve estar preenchido
lRet := (lRet.And.QtdComp(nQuant)>QtdComp(0)) //-- Deve haver Quantidade maior que ZERO

If ExistBlock('DLANTDCF')
	lRet := If(ValType(lRetPE:=ExecBlock('DLANTDCF',.F.,.F.,{cAliasOrig, cOrigem, cServico, cDoc, cSerie, cCliFor, cLoja, cProduto, cArmazem, cNumSeq}))=='L',lRetPE,lRet)
	//-- Parametros do Ponto de Entrada DLANTDCF
	//-- aParam[01] = C, 03, ##, Alias do Arquivo que disparou a Execucao do Servico
	//-- aParam[02] = C, 03, ##, Alias do Arquivo onde o Servico esta gravado
	//-- aParam[03] = C, 06, ##, Servico
	//-- aParam[04] = C, 06, ##, Documento
	//-- aParam[05] = C, 03, ##, Serie
	//-- aParam[06] = C, 06, ##, Cliente/Fornecedor
	//-- aParam[07] = C, 02, ##, Loja
	//-- aParam[08] = C, 15, ##, Produto
	//-- aParam[09] = C, 02, ##, Armazem
	//-- aParam[10] = C, 06, ##, Numero Sequencial
EndIf

If lRet
	cServico := If(!(cServPad==Nil),cServPad,cServico)
EndIf

//���������������������������������������������������������������������������Ŀ
//�Efetua a Gravacao do Servico no DCF                                        �
//�����������������������������������������������������������������������������
If lRet
	DbSelectArea('DCF')
	aAreaDCF := GetArea()
	//-- Adequacao ao tamanho das variaveis com o tamanho dos campos do DCF
	cServico := PadR(cServico, Len(DCF->DCF_SERVIC))
	cDoc     := PadR(cDoc    , Len(DCF->DCF_DOCTO))
	cSerie   := PadR(cSerie  , Len(DCF->DCF_SERIE))
	cCliFor  := PadR(cCliFor , Len(DCF->DCF_CLIFOR))
	cLoja    := PadR(cLoja   , Len(DCF->DCF_LOJA))
	cProduto := PadR(cProduto, Len(DCF->DCF_CODPRO))
	cOrigem  := PadR(cOrigem , Len(DCF->DCF_ORIGEM))
	cNumSeq  := PadR(cNumSeq , Len(DCF->DCF_NUMSEQ))
	cArmazem := PadR(cArmazem, Len(DCF->DCF_LOCAL))
	cEstrFis := PadR(cEstrFis, Len(DCF->DCF_ESTFIS))
	cRegra   := PadR(cRegra  , Len(DCF->DCF_REGRA))
	cEndere  := PadR(cEndere , Len(DCF->DCF_ENDER))
	cLoteCtl := PadR(cLoteCtl, Len(DCF->DCF_LOTECT))
	cNumLote := PadR(cNumLote, Len(DCF->DCF_NUMLOT))
	cPriori  := PadR(cPriori , Len(DCF->DCF_PRIORI))
	cCodFun  := PadR(cCodFun , Len(DCF->DCF_CODFUN))
	cCarga   := PadR(cCarga  , Len(DCF->DCF_CARGA))
	cUnitiz  := PadR(cUnitiz , Len(DCF->DCF_UNITIZ))
	cNorma   := PadR(cNorma  , Len(DCF->DCF_CODNOR))

	Begin Transaction
		nQuant2UM := ConvUm(cProduto,nQuant,0,2)
		cIdDCF    := WMSProxSeq("MV_DOCSEQ","DCF_ID")
		If Empty(cNumSeq)
			cNumSeq := WMSProxSeq("MV_DOCSEQ","DCF_NUMSEQ")
		EndIf
		RecLock('DCF', lInclusao)
		If lInclusao
			DCF->DCF_FILIAL := xFilial('DCF')
			DCF->DCF_SERVIC := cServico
			DCF->DCF_DOCTO  := cDoc
			DCF->DCF_SERIE  := cSerie
			DCF->DCF_CLIFOR := cCliFor
			DCF->DCF_LOJA   := cLoja
			DCF->DCF_CODPRO := cProduto
			DCF->DCF_DATA   := dData
			DCF->DCF_STSERV := '1'
			DCF->DCF_QUANT  := nQuant
			DCF->DCF_QTSEUM := nQuant2UM
			DCF->DCF_ORIGEM := cOrigem
			DCF->DCF_NUMSEQ := cNumSeq
			DCF->DCF_LOCAL  := cArmazem
			DCF->DCF_ESTFIS := cEstrFis
			DCF->DCF_REGRA  := cRegra
			DCF->DCF_ENDER  := cEndere
			DCF->DCF_LOTECT := cLoteCtl
			DCF->DCF_NUMLOT := cNumLote
			DCF->DCF_PRIORI := cPriori
			DCF->DCF_CODFUN := cCodFun
			DCF->DCF_CARGA  := cCarga
			DCF->DCF_UNITIZ := cUnitiz
			DCF->DCF_CODNOR := cNorma
			DCF->DCF_STRADI := Iif(cOrigem == 'DCF',Replicate('0',Len(DCF->DCF_SERVIC)),Space(Len(DCF->DCF_SERVIC)))
			DCF->DCF_ID     := cIdDCF
		Else
			// Deve atribuir e n�o incrementar porque no caso de SDA com origem em SD2
			// a WMSCriaDCF � chamada diversas vezes, mas sempre com o valor atualizado.
			DCF->DCF_QUANT  := nQuant
			DCF->DCF_QTSEUM := nQuant2UM
		EndIf
		DCF->(MsUnLock())

		//Grava IDDCF na SDA
		If cAliasOrig == 'SDA'
			RecLock('SDA', .F.)
			SDA->DA_IDDCF := DCF->DCF_ID
			MsUnLock()
		EndIf
		//Grava IDDCF na SC9
		If cAliasOrig == 'SC9'
			RecLock('SC9', .F.)
			SC9->C9_STSERV := DCF->DCF_STSERV
			SC9->C9_IDDCF  := DCF->DCF_ID
			MsUnLock()
		EndIf
	End Transaction
	//-- Garante que o DCF ficara posicionado no registro gerado, algumas rotinas recebem nposdcf como referencia
	nPosDCF := DCF->(Recno())

	//���������������������������������������������������������������������������Ŀ
	//�Ponto de Entrada DLATUDCF apos as gravacoes                                �
	//�����������������������������������������������������������������������������
	If ExistBlock('DLATUDCF')
		ExecBlock('DLATUDCF',.F.,.F.,{cAliasOrig, cOrigem, cServico, cDoc, cSerie, cCliFor, cLoja, cProduto, cArmazem, cNumSeq, nQuant})
		//-- Parametros do Ponto de Entrada DLATUDCF
		//-- aParam[01] = C, 03, ##, Alias do Arquivo que disparou a Execucao do Servico
		//-- aParam[02] = C, 03, ##, Alias do Arquivo onde o Servico esta gravado
		//-- aParam[03] = C, 06, ##, Servico
		//-- aParam[04] = C, 06, ##, Documento
		//-- aParam[05] = C, 03, ##, Serie
		//-- aParam[06] = C, 06, ##, Cliente/Fornecedor
		//-- aParam[07] = C, 02, ##, Loja
		//-- aParam[08] = C, 15, ##, Produto
		//-- aParam[09] = C, 02, ##, Armazem
		//-- aParam[10] = C, 06, ##, Numero Sequencial
		//-- aParam[11] = N,   , ##, Quantidade
	EndIf
	RestArea(aAreaDCF)
EndIf

//���������������������������������������������������������������������������Ŀ
//�Retorna a Integridade do Sistema                                           �
//�����������������������������������������������������������������������������
RestArea(aAreaAnt)
Return lRet

/*------------------------------------------------------------------------------
Estorna todas as DCFs , inclusive as DCFs origem
------------------------------------------------------------------------------*/
Function WmsEstAll(cAcao,lEstSrvAut,aDocOri,lExibeMsg)
Static lDLGA150D := ExistBlock('DLGA150D')
Local aAreaAnt   := GetArea()
Local aAreaDCF   := DCF->(GetArea())
Local lRet       := .T.
Local lRetPE     := .F.
Local lDocOri    := .F.
Local lDelDoc    := .F.
Local nCntFor    := 0
Default cAcao     := '1'
Default lExibeMsg := WmsMsgExibe()

If cAcao == '1'

	If !(lRet := WmsAvalDCF('3',/*cIdDCF*/,lExibeMsg))
		RestArea(aAreaAnt)
		Return lRet
	EndIf

	lDocOri  := WmsDocOri('1') //-- Verifica se habilita estorno dos itens do dcf com referencia ao documento original
	If lDocOri .And. Empty(DCF->DCF_DOCORI)
		lDelDoc := .T.
	EndIf
	//-- Ponto de Entrada DLGA150D (Antes do Estorno do Servico)
	//-- Parametros Passados:
	//-- PARAMIXB[1] = Produto
	//-- PARAMIXB[2] = Local
	//-- PARAMIXB[3] = Documento
	//-- PARAMIXB[4] = Serie
	//-- PARAMIXB[5] = Recno no DCF
	If lDLGA150D
		lRetPE := ExecBlock('DLGA150D', .F., .F., {DCF->DCF_CODPRO, DCF->DCF_LOCAL, DCF->DCF_DOCTO, DCF->DCF_SERIE, DCF->(Recno())})
		If ValType(lRetPE)=='L'
			lRet := lRetPE
		EndIf
	EndIf

	If lRet
		lRet := WmsEstDCF(/*cIdDCF*/,lExibeMsg)
		DCF->(RestArea(aAreaDCF)) // Restaura a �rea anterior DCF
		If lRet .And. lEstSrvAut
			If lDelDoc
				If WmsCarga(DCF->DCF_CARGA)
					If aScan(aDocOri,{|x|x[3]==DCF->DCF_CARGA})==0
						AAdd(aDocOri,{'','',DCF->DCF_CARGA})
					EndIf
				Else
					If aScan(aDocOri,{|x|x[1]+x[2]==DCF->DCF_DOCTO+DCF->DCF_SERIE})==0
						AAdd(aDocOri,{DCF->DCF_DOCTO,DCF->DCF_SERIE,''})
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

ElseIf cAcao == '2'
	For nCntFor := 1 To Len(aDocOri)
		//-- Estorna todos os documentos com referencia a carga ou documento original
		lRet := WmsEstOri(aDocOri[nCntFor,3],aDocOri[nCntFor,1],aDocOri[nCntFor,2])
		If !lRet
			Exit
		EndIf
	Next
EndIf

RestArea(aAreaAnt)
Return lRet

/*------------------------------------------------------------------------------
------------------------------------------------------------------------------*/
Function WmsEstDCF(cIdDCF,lExibeMsg)
Static lDLA220E := ExistBlock("DLA220E")
Local aAreaAnt   := GetArea()
Local aAreaDCF   := {}
Local aAreaSDB   := {}
Local cQuery     := ""
Local cAliasSDB  := ""
Local cAliasSD3  := ""
Local cAliasQry  := ""
Local cAliasSDD  := ""
Local dDataFec   := DToS(WmsData())
Local cTipServ   := ""
Local aCusto     := {}
Local aCM        := {}
Local dDtValid   := CtoD('  /  /  ')
Local cSeekSB8   := ""
Local cSeekSD1   := ""
Local cSeekSD3   := ""
Local cNumSD1    := ""
Local cNumero    := ""
Local lCQ        := .F.
Local lAchouD1   := .F.
Local nEmpenho   := 0
Local nEmpenho2  := 0
Local nBaixa     := 0
Local nBaixa2    := 0
Local nQtde      := 0
Local nRegOrigD3 := 0
Local nRegDestD3 := 0
Local lEmpPrev   := If(SuperGetMV("MV_QTDPREV")== "S",.T.,.F.)
Local nTipoRegra := 3
Local xRegra     := CtoD('  /  /  ')
Local cFunExe    := ""
Local lRet       := .T.
Local cLocalCQ   := SuperGetMV('MV_CQ', .F., '98')

Private aParam150  := Array(34)
Private lWmsMovPkg := .F.

Default cIdDCF    := ""
Default lExibeMsg := WmsMsgExibe()

	cTipServ := WmsTipServ(DCF->DCF_SERVIC)

	Begin Transaction

	If DCF->DCF_ORIGEM $ "SC9*DBN"
		// Estorna Mont. de Volumes e Conf. Expedi��o
		WMSEstVlCf()
		// Estorna libera��o de pedidos
		nTipoRegra := Iif(Empty(DCF->DCF_REGRA),nTipoRegra,Val(DCF->DCF_REGRA))
		xRegra     := Iif(nTipoRegra==1,DCF->DCF_LOTECT,xRegra)
		lRet := WmsEstSC9(DCF->DCF_CARGA,DCF->DCF_DOCTO,DCF->DCF_SERIE,DCF->DCF_CODPRO,DCF->DCF_SERVIC,DCF->DCF_QUANT,DCF->DCF_QTSEUM,DCF->DCF_LOCAL,DCF->DCF_ENDER,DCF->DCF_ID,nTipoRegra,xRegra)
	EndIf

	If lRet
		//-- Estornando as movimenta��es de estoque
		cAliasSDB := GetNextAlias()
		cQuery := "SELECT SDB.R_E_C_N_O_ RECNOSDB, SDB.DB_ESTORNO, SDB.DB_DATA, SDB.DB_ATUEST ATUEST"
		cQuery +=  " FROM "+RetSqlName("SDB")+" SDB"
		cQuery += " WHERE SDB.DB_FILIAL  = '"+xFilial("SDB")+"'"
		cQuery +=   " AND SDB.DB_SERVIC  = '"+DCF->DCF_SERVIC+"'"
		cQuery +=   " AND SDB.DB_PRODUTO = '"+DCF->DCF_CODPRO+"'"
		cQuery +=   " AND SDB.DB_LOCAL   = '"+DCF->DCF_LOCAL+"'"
		cQuery +=   " AND SDB.DB_IDDCF   = '"+DCF->DCF_ID+"'"
		cQuery +=   " AND SDB.DB_TM     <= '500'"
		cQuery +=   " AND SDB.DB_ESTORNO = ' '"
		cQuery +=   " AND SDB.DB_ATUEST  = 'S'"
		cQuery +=   " AND SDB.D_E_L_E_T_ = ' '"
		cQuery += " UNION ALL "
		cQuery += "SELECT SDB.R_E_C_N_O_ RECNOSDB, SDB.DB_ESTORNO, SDB.DB_DATA, SDB.DB_ATUEST ATUEST"
		cQuery +=  " FROM "+RetSqlName("SDB")+" SDB"
		cQuery += " WHERE SDB.DB_FILIAL  = '"+xFilial("SDB")+"'"
		cQuery +=   " AND SDB.DB_SERVIC  = '"+DCF->DCF_SERVIC+"'"
		cQuery +=   " AND SDB.DB_PRODUTO = '"+DCF->DCF_CODPRO+"'"
		cQuery +=   " AND SDB.DB_LOCAL   = '"+DCF->DCF_LOCAL+"'"
		cQuery +=   " AND SDB.DB_ATUEST  = 'N'"
		cQuery +=   " AND SDB.DB_ESTORNO = ' '"
		cQuery +=   " AND SDB.D_E_L_E_T_ = ' '"
		cQuery +=   " AND EXISTS (SELECT 1 "
		cQuery +=                 " FROM "+RetSqlName("DCR")+" DCR"
		cQuery +=                " WHERE DCR.DCR_FILIAL = '"+xFilial("DCR")+"'"
		cQuery +=                  " AND DCR.DCR_IDDCF  = '"+DCF->DCF_ID+"'"
		cQuery +=                  " AND DCR.DCR_IDORI  = SDB.DB_IDDCF"
		cQuery +=                  " AND DCR.DCR_IDMOV  = SDB.DB_IDMOVTO"
		cQuery +=                  " AND DCR.DCR_IDOPER = SDB.DB_IDOPERA"
		cQuery +=                  " AND DCR.D_E_L_E_T_ = ' ')"
		cQuery +=   " ORDER BY ATUEST DESC "
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSDB,.F.,.T.)

		While (cAliasSDB)->(!Eof())
			SDB->(DbGoTo((cAliasSDB)->RECNOSDB))
			If SDB->DB_ATUEST == 'N'
				//-- Estorna somente movimenta��es de RF
				DbSelectArea('DCR')
				If DCR->(DbSeek(xFilial("DCR")+SDB->DB_IDDCF+DCF->DCF_ID+SDB->DB_IDMOVTO+SDB->DB_IDOPERA,.F.))
					RecLock('SDB',.F.)
					If QtdComp(SDB->DB_QUANT - DCR->DCR_QUANT) == QtdComp(0)
						SDB->DB_ESTORNO := 'S'
					Else
						SDB->DB_QUANT   := SDB->DB_QUANT   - DCR->DCR_QUANT
						SDB->DB_QTSEGUM := SDB->DB_QTSEGUM - DCR->DCR_QTSEUM
					EndIf
					SDB->(MsUnlock())
					//-- Elimina registro da DCR
					RecLock("DCR",.F.)
					DCR->(DbDelete())
					DCR->(MsUnlock())
				Else
					lRet := .F.
					cMensagem := "SIGAWMS - OS "+AllTrim(DCF->DCF_DOCTO)+Iif(!Empty(DCF->DCF_SERIE),"/"+AllTrim(SerieNfId("DCF",2,"DCF_SERIE")),"")+STR0013+AllTrim(DCF->DCF_CODPRO)+CLRF
					cMensagem += STR0007+CLRF //"N�o foi poss�vel encontrar a movimenta��o relacionada (DCR)."
					cMensagem += RetTitle("DCF_ID")+": "+DCF->DCF_ID+CLRF
					cMensagem += RetTitle("DB_IDMOVTO")+": "+SDB->DB_IDMOVTO
					WmsMessage(cMensagem,"WmsEstDCF",1,lExibeMsg)
					Exit
				EndIf
			Else
				If DtoS(SDB->DB_DATA) > dDataFec
					If GetVersao(.F.) >= '12' .AND. DCF->DCF_ORIGEM == 'SD4'
						WmsAtuSD4(SDB->DB_LOCAL,SDB->DB_PRODUTO,SDB->DB_LOTECTL,SDB->DB_NUMLOTE,,SDB->DB_LOCALIZ,SDB->DB_QUANT,SDB->DB_IDDCF,.T.)
					EndIf
					//Verifica a fun��o executada pelo servi�o/tarefa
					WmsFunExe('1',SDB->DB_SERVIC,SDB->DB_TAREFA,@cFunExe)
					//-- Estorna movimenta��es de estoque
					If cTipServ $ "2�3" .And. !('DLTRANSFER' $ Upper(cFunExe))
						//-- Preenche array aParam150 a ser utilizado pela WmsMovEst
						aParam150[01] := SDB->DB_PRODUTO    //-- Produto
						aParam150[03] := SDB->DB_DOC        //-- Documento
						aParam150[04] := SDB->DB_SERIE      //-- S�rie
						aParam150[05] := SDB->DB_NUMSEQ     //-- Sequencial
						aParam150[08] := Time()             //-- Hora Inicio da Execucao de Servicos
						aParam150[09] := SDB->DB_SERVIC     //-- Servico
						aParam150[10] := SDB->DB_TAREFA     //-- Tarefa
						aParam150[11] := SDB->DB_ATIVID     //-- Atividade
						aParam150[17] := SDB->DB_ORIGEM     //-- Origem do Lancamento
						aParam150[23] := SDB->DB_CARGA      //-- Carga
						aParam150[24] := SDB->DB_UNITIZ     //-- Unitizador
						aParam150[28] := SDB->DB_ORDTARE    //-- Ordem da Tarefa
						aParam150[29] := SDB->DB_ORDATIV    //-- Ordem da Atividade
						aParam150[32] := SDB->DB_IDDCF   //-- Identificador do DCF
						aParam150[34] := SDB->DB_IDMOVTO //-- Identificador do SDB DB_IDMOVTO
						//-- Processa o destino para a origem
						aParam150[25] := SDB->DB_LOCAL
						aParam150[27] := SDB->DB_ESTFIS
						aParam150[26] := SDB->DB_LOCALIZ
						//-- Procura registro correspondente no SD3
						aAreaSDB := GetArea() //-- Salva a �rea anterior
						cAliasSD3 := GetNextAlias()
						cQuery := "SELECT SD3.R_E_C_N_O_ RECNOSD3"
						cQuery +=  " FROM "+RetSqlName('SD3')+" SD3"
						cQuery += " WHERE SD3.D3_FILIAL  = '"+xFilial('SD3')+"'"
						cQuery +=   " AND SD3.D3_NUMSEQ  = '"+SDB->DB_NUMSEQ+"'"
						cQuery +=   " AND SD3.D3_CHAVE   = 'E0'"
						cQuery +=   " AND SD3.D3_COD     = '"+SDB->DB_PRODUTO+"'"
						cQuery +=   " AND SD3.D3_LOTECTL = '"+SDB->DB_LOTECTL+"'"
						cQuery +=   " AND SD3.D3_NUMLOTE = '"+SDB->DB_NUMLOTE+"'"
						cQuery +=   " AND SD3.D3_NUMSERI = '"+SDB->DB_NUMSERI+"'"
						cQuery +=   " AND SD3.D3_QUANT   = "+Str(SDB->DB_QUANT)
						cQuery +=   " AND SD3.D3_ESTORNO = ' '"
						cQuery +=   " AND SD3.D_E_L_E_T_ = ' '"
						cQuery := ChangeQuery(cQuery)
						DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSD3,.F.,.T.)
						If (cAliasSD3)->(!Eof())
							nRegOrigD3 := (cAliasSD3)->RECNOSD3
							SD3->(DbGoTo(nRegOrigD3))
						Else
							lRet := .F.
							cMensagem := "SIGAWMS - OS "+AllTrim(DCF->DCF_DOCTO)+Iif(!Empty(DCF->DCF_SERIE),"/"+AllTrim(SerieNfId("DCF",2,"DCF_SERIE")),"")+STR0013+AllTrim(DCF->DCF_CODPRO)+CLRF
							cMensagem += STR0008+CLRF //"N�o foi poss�vel encontrar a movimenta��o origem (SD3)."
							cMensagem += RetTitle("DCF_ID")+": "+DCF->DCF_ID+CLRF
							cMensagem += RetTitle("DB_NUMSEQ")+": "+SDB->DB_NUMSEQ
							WmsMessage(cMensagem,"WmsEstDCF",1,lExibeMsg)
						EndIf
						(cAliasSD3)->(DbCloseArea())
						If !lRet
							Exit
						EndIf
						//-- Processa a origem para o destino
						cAliasQry := GetNextAlias()
						cQuery := "SELECT SDB.R_E_C_N_O_ RECNOSDB"
						cQuery +=  " FROM "+RetSqlName('SDB')+" SDB"
						cQuery += " WHERE SDB.DB_FILIAL  = '"+xFilial('SDB')+"'"
						cQuery +=   " AND SDB.DB_PRODUTO = '"+SDB->DB_PRODUTO+"'"
						cQuery +=   " AND SDB.DB_DOC     = '"+SDB->DB_DOC    +"'"
						cQuery +=   " AND SDB.DB_SERIE   = '"+SDB->DB_SERIE  +"'"
						cQuery +=   " AND SDB.DB_CLIFOR  = '"+SDB->DB_CLIFOR +"'"
						cQuery +=   " AND SDB.DB_LOJA    = '"+SDB->DB_LOJA   +"'"
						cQuery +=   " AND SDB.DB_SERVIC  = '"+SDB->DB_SERVIC +"'"
						cQuery +=   " AND SDB.DB_NUMSEQ  = '"+SDB->DB_NUMSEQ +"'"
						cQuery +=   " AND SDB.DB_IDDCF   = '"+SDB->DB_IDDCF  +"'"
						cQuery +=   " AND SDB.DB_IDMOVTO = '"+SDB->DB_IDMOVTO+"'"
						cQuery +=   " AND SDB.DB_TM      > '500'"
						cQuery +=   " AND SDB.DB_ESTORNO = ' '"
						cQuery +=   " AND SDB.DB_DATA    > '"+dDataFec+"'"
						cQuery +=   " AND SDB.DB_ATUEST  = 'S'"
						cQuery +=   " AND SDB.D_E_L_E_T_ = ' '"
						DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
						If (cAliasQry)->(!Eof())
							SDB->(DbGoTo((cAliasQry)->RECNOSDB))
						Else
							lRet := .F.
							cMensagem := "SIGAWMS - OS "+AllTrim(DCF->DCF_DOCTO)+Iif(!Empty(DCF->DCF_SERIE),"/"+AllTrim(SerieNfId("DCF",2,"DCF_SERIE")),"")+STR0013+AllTrim(DCF->DCF_CODPRO)+CLRF
							cMensagem += STR0009+CLRF //"N�o foi poss�vel encontrar a movimenta��o origem (SDB)."
							cMensagem += RetTitle("DCF_ID")+": "+DCF->DCF_ID+CLRF
							cMensagem += RetTitle("DB_IDMOVTO")+": "+SDB->DB_IDMOVTO+CLRF
							cMensagem += RetTitle("DB_NUMSEQ")+": "+SDB->DB_NUMSEQ
							WmsMessage(cMensagem,"WmsEstDCF",1,lExibeMsg)
						EndIf
						(cAliasQry)->(DbCloseArea())
						If !lRet
							Exit
						EndIf

						aParam150[06] := SDB->DB_QUANT
						aParam150[18] := SDB->DB_LOTECTL
						aParam150[19] := SDB->DB_NUMLOTE
						aParam150[02] := SDB->DB_LOCAL
						aParam150[21] := SDB->DB_ESTFIS
						aParam150[20] := SDB->DB_LOCALIZ

						//-- Procura registro correspondente no SD3
						cAliasSD3 := GetNextAlias()
						cQuery := "SELECT SD3.R_E_C_N_O_ RECNOSD3"
						cQuery +=  " FROM "+RetSqlName('SD3')+" SD3"
						cQuery += " WHERE SD3.D3_FILIAL  = '"+xFilial('SD3')+"'"
						cQuery +=   " AND SD3.D3_NUMSEQ  = '"+SDB->DB_NUMSEQ+"'"
						cQuery +=   " AND SD3.D3_CHAVE   = 'E9'"
						cQuery +=   " AND SD3.D3_COD     = '"+SDB->DB_PRODUTO+"'"
						cQuery +=   " AND SD3.D3_LOTECTL = '"+SDB->DB_LOTECTL+"'"
						cQuery +=   " AND SD3.D3_NUMLOTE = '"+SDB->DB_NUMLOTE+"'"
						cQuery +=   " AND SD3.D3_NUMSERI = '"+SDB->DB_NUMSERI+"'"
						cQuery +=   " AND SD3.D3_QUANT   = "+Str(SDB->DB_QUANT)
						cQuery +=   " AND SD3.D3_ESTORNO = ' '"
						cQuery +=   " AND SD3.D_E_L_E_T_ = ' '"
						cQuery := ChangeQuery(cQuery)
						DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSD3,.F.,.T.)
						If (cAliasSD3)->(!Eof())
							nRegDestD3 := (cAliasSD3)->RECNOSD3
							SD3->(DbGoTo(nRegDestD3))
						Else
							lRet := .F.
							cMensagem := "SIGAWMS - OS "+AllTrim(DCF->DCF_DOCTO)+Iif(!Empty(DCF->DCF_SERIE),"/"+AllTrim(SerieNfId("DCF",2,"DCF_SERIE")),"")+STR0013+AllTrim(DCF->DCF_CODPRO)+CLRF
							cMensagem += STR0010+CLRF //"N�o foi poss�vel encontrar a movimenta��o destino (SD3)."
							cMensagem += RetTitle("DCF_ID")+": "+DCF->DCF_ID+CLRF
							cMensagem += RetTitle("DB_NUMSEQ")+": "+SDB->DB_NUMSEQ
							WmsMessage(cMensagem,"WmsEstDCF",1,lExibeMsg)
						EndIf
						(cAliasSD3)->(DbCloseArea())
						If !lRet
							Exit
						EndIf
						//Se for movimenta��o sa�da e a origem foi um endere�o de picking, marca para n�o validar capacidade
						If cTipServ == '2' .And. DLTipoEnd(SDB->DB_ESTFIS) == 2 //2=Picking
							lWmsMovPkg := .T.
						Else
							lWmsMovPkg := .F.
						EndIf

						RestArea(aAreaSDB) //-- Restaura a �rea anterior
						aAreaDCF := DCF->(GetArea()) //-- A fun��o mata260 desposiciona a DCF, deve salvar a �rea anterior
						lRet := WmsMovEst(aParam150, .T. /*Estorno*/, nRegOrigD3, nRegDestD3, Val(cTipServ))
						If !lRet
							Exit
						EndIf
						DCF->(RestArea(aAreaDCF)) // Restaura a �rea anterior DCF
					ElseIf cTipServ == "1" .Or. (cTipServ == "3" .And. 'DLTRANSFER' $ Upper(cFunExe))
						If !VldEstEnt(SDB->DB_DOC,SDB->DB_SERIE,SDB->DB_LOCAL,SDB->DB_LOCALIZ,SDB->DB_PRODUTO,SDB->DB_NUMSERI,SDB->DB_LOTECTL,SDB->DB_NUMLOTE,SDB->DB_QUANT)
							lRet := .F.
							Exit
						EndIf
						//-- Atualiza SDB
						RecLock('SDB',.F.)
						Replace DB_ESTORNO WITH 'S'
						SDB->(MsUnlock())
						//-- Cria SDB de estorno
						CriaSDB(DB_PRODUTO,;             //Produto
								DB_LOCAL,;                 //Local
								DB_QUANT,;                 //Quantidade
								DB_LOCALIZ,;               //Localiza
								DB_NUMSERI,;               //Numero Serie
								DB_DOC,;                   //Documento
								DB_SERIE,;                 //Serie
								DB_CLIFOR,;                //Cliente-fornecedor
								DB_LOJA,;                  //Loja
								DB_TIPONF,;                //Tipo Nota-fiscal
								DB_ORIGEM,;                //Origem
								dDataBase,;                //Data
								DB_LOTECTL,;               //Lote
								DB_NUMLOTE,;               //Sub-lote
								DB_NUMSEQ,;                //Numero sequencial
								'501',;                    //TM
								'D',;                      //Tipo
								DB_ITEM,;                  //Item
								.T.,;                      //Flag Estorno
								If(DB_EMPENHO>0,DB_QUANT,0),; //Quantidade Empenho
								DB_QTSEGUM,;               //Quantidade 2 UM
								If(DB_EMPENHO>0,DB_QTSEGUM,0),;  //Quantidade Empenho 2 UM
								DB_ESTFIS,;                //Estrutura Fisica
								DB_SERVIC,;                //Servico
								DB_TAREFA,;                //Tarefa
								DB_ATIVID,;                //Atividade
								DB_ANOMAL,;                //Anomalia
								DB_ESTDES,;                //Estrutura Destino
								DB_ENDDES,;                //Endereco Destino
								Time(),;                   //Hora Inicio
								DB_ATUEST,;                //Flag Atualiza Estoque
								DB_CARGA,;                 //Carga
								DB_UNITIZ,;                //Unitiza
								DB_ORDTARE,;               //Ordem Tarefa
								DB_ORDATIV,;               //Ordem Atividade
								DB_RHFUNC,;                //Recurso Humano
								DB_RECFIS,;                //Recurso Fisico
								DB_SEQCAR,;                //Sequencia Carga
								DB_IDDCF,;                 //Identificador DCF
								Nil,;                      //
								DB_IDMOVTO)                //Identificador Movimento
						//��������������������������������������������������������������Ŀ
						//� Soma saldo classificar no arquivo de saldos em estoque (SB2) �
						//����������������������������������������������������������������
						dbSelectArea('SB2')
						dbSetOrder(1)
						If MsSeek(xFilial('SB2')+SDB->DB_PRODUTO+SDB->DB_LOCAL, .F.)
							RecLock('SB2', .F.)
							Replace B2_QACLASS With (B2_QACLASS+SDB->DB_QUANT)
							SB2->(MsUnlock())
						EndIf
						//��������������������������������������������������������������Ŀ
						//� Baixa saldo empenhado no arquivo de saldos por sub-lote (SB8)�
						//����������������������������������������������������������������
						If Rastro(SDB->DB_PRODUTO)
							If Rastro(SDB->DB_PRODUTO, 'S')
								dbSelectArea('SB8')
								dbSetOrder(3)
								If MsSeek(xFilial('SB8')+SDB->DB_PRODUTO+SDB->DB_LOCAL+SDB->DB_LOTECTL+SDB->DB_NUMLOTE, .F.)
									RecLock('SB8', .F.)
									Replace B8_QACLASS With (B8_QACLASS+SDB->DB_QUANT)
									Replace B8_QACLAS2 With (B8_QACLAS2+SDB->DB_QTSEGUM)
									SB8->(MsUnlock())
								EndIf
							Else
								nEmpenho  := SDB->DB_QUANT
								nEmpenho2 := SDB->DB_QTSEGUM
								dbSelectArea('SB8')
								dbSetOrder(3)
								dbSelectArea('SD5')
								dbSetOrder(3)
								If MsSeek(cSeekSD5:=xFilial('SD5')+SDB->DB_NUMSEQ+SDB->DB_PRODUTO+SDB->DB_LOCAL+SDB->DB_LOTECTL, .F.)
									While SD5->(!Eof() .And. nEmpenho>0 .And. SD5->D5_FILIAL+SD5->D5_NUMSEQ+SD5->D5_PRODUTO+SD5->D5_LOCAL+SD5->D5_LOTECTL == cSeekSD5)
										dbSelectArea('SB8')
										If MsSeek(xFilial('SB8')+SD5->D5_PRODUTO+SD5->D5_LOCAL+SD5->D5_LOTECTL+SD5->D5_NUMLOTE, .F.)
											nBaixa  := Min(SB8Saldo(,,,,,lEmpPrev), nEmpenho)
											nBaixa2 := Min(SB8Saldo(,,,.T.,,lEmpPrev), nEmpenho2)
											Reclock('SB8', .F.)
											Replace B8_QACLASS With (B8_QACLASS+nBaixa)
											Replace B8_QACLAS2 With (B8_QACLAS2+nBaixa2)
											SB8->(MsUnlock())
											nEmpenho  -= nBaixa
											nEmpenho2 -= nBaixa2
										EndIf
										dbSelectArea('SD5')
										DbSkip()
									EndDo
								EndIf
								dbSelectArea('SB8')
								dbSetOrder(3)
								If MsSeek(cSeekSB8:=xFilial('SB8')+SDB->DB_PRODUTO+SDB->DB_LOCAL+SDB->DB_LOTECTL, .F.)
									While SB8->(!Eof() .And. nEmpenho>0 .And. SB8->B8_FILIAL+SB8->B8_PRODUTO+SB8->B8_LOCAL+SB8->B8_LOTECTL == cSeekSB8)
										nBaixa  := Min(SB8Saldo(,,,,,lEmpPrev), nEmpenho)
										nBaixa2 := Min(SB8Saldo(,,,.T.,,lEmpPrev), nEmpenho2)
										Reclock('SB8', .F.)
										Replace B8_QACLASS With (B8_QACLASS+nBaixa)
										Replace B8_QACLAS2 With (B8_QACLAS2+nBaixa2)
										SB8->(MsUnlock())
										nEmpenho  -= nBaixa
										nEmpenho2 -= nBaixa2
										SB8->(DbSkip())
									EndDo
								EndIf
							EndIf
							//-- Libera quantidade estornada da quarentena
							cAliasSDD  := GetNextAlias()
							cQuery := "SELECT SDD.R_E_C_N_O_ RECNOSDD"
							cQuery +=  " FROM "+RetSqlName('SDD')+" SDD "
							cQuery += " WHERE SDD.DD_FILIAL  = '"+xFilial('SDD')+"'"
							cQuery +=   " AND SDD.DD_DOC     = '"+SDB->DB_DOC+"'"
							cQuery +=   " AND SDD.DD_PRODUTO = '"+SDB->DB_PRODUTO+"'"
							cQuery +=   " AND SDD.DD_LOCAL   = '"+SDB->DB_LOCAL  +"'"
							cQuery +=   " AND SDD.DD_LOTECTL = '"+SDB->DB_LOTECTL+"'"
							cQuery +=   " AND SDD.DD_NUMLOTE = '"+SDB->DB_NUMLOTE+"'"
							cQuery +=   " AND SDD.DD_LOCALIZ = '"+SDB->DB_LOCALIZ+"'"
							cQuery +=   " AND SDD.D_E_L_E_T_ = ' '"
							cQuery := ChangeQuery(cQuery)
							DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSDD,.F.,.T.)
							If (cAliasSDD)->(!Eof())
								SDD->(dbGoto((cAliasSDD)->RECNOSDD))
								If SDD->DD_SALDO > 0
									RecLock('SDD', .F. ) // Trava para gravacao
									SDD->DD_QUANT := SDB->DB_QUANT
									SDD->(MsUnlock())
									ProcSDD(.T.)
								EndIf
								//Realiza acerto na quantidade origem
								RecLock('SDD', .F. ) // Trava para gravacao
								SDD->DD_QTDORIG -= SDB->DB_QUANT
								SDD->(MsUnlock())

								If SDD->DD_SALDO <= 0 .AND. SDD->DD_SALDO2 <= 0 .AND. SDD->DD_QTDORIG <= 0
									RecLock('SDD', .F. ) // Trava para gravacao
									SDD->(DbDelete())
									SDD->(MsUnlock())
								EndIf
							EndIf
							(cAliasSDD)->(DbCloseArea())
						EndIf
						//��������������������������������������������������������������Ŀ
						//� Verifica se o Produto possui CQ                              �
						//����������������������������������������������������������������
						dbSelectArea('SD7')
						dbSetOrder(3)
						cNumero := Left(SDB->DB_DOC,Len(SD7->D7_NUMERO))
						If MsSeek(xFilial('SD7')+SDB->DB_PRODUTO+SDB->DB_NUMSEQ+cNumero, .F.)
							lCQ      := .T.
							cSeekSD1 := xFilial('SD1')+SD7->D7_PRODUTO+SD7->D7_DOC+SD7->D7_SERIE+SD7->D7_FORNECE+SD7->D7_LOJA
						Else
							cSeekSD1 := xFilial('SD1')+SDB->DB_PRODUTO+SDB->DB_DOC+SDB->DB_SERIE+SDB->DB_CLIFOR+SDB->DB_LOJA
						EndIf
						cNumSD1 := If(lCQ,'SD7->D7_NUMERO==SD1->D1_NUMCQ', 'SDB->DB_NUMSEQ==SD1->D1_NUMSEQ')
						//��������������������������������������������������������������Ŀ
						//� Caso item da NF seja p/OP, grava o numero da OP na requisicao�
						//����������������������������������������������������������������
						dbSelectArea('SD1')
						dbSetOrder(2)
						MsSeek(cSeekSD1, .F.)
						If &cNumSD1 .And. !Empty(SD1->D1_OP) .And. !(SDB->DB_LOCAL == cLocalCQ)
							lAchouD1 := .T.
						EndIf
						If lAchouD1
							dbSelectArea('SB1')
							dbSetOrder(1)
							MsSeek(xFilial('SB1')+SDB->DB_PRODUTO, .F.)
							dbSelectArea('SD3')
							dbSetOrder(2)
							If MsSeek(cSeekSD3:=xFilial('SD3')+SDB->DB_DOC+SDB->DB_PRODUTO, .F.)
								Do While !Eof() .And. D3_FILIAL+D3_DOC+D3_PRODUTO == cSeekSD3
									If D3_CF=='RE5' .And. !Empty(D3_OP) .And. SDB->DB_NUMSEQ+SDB->DB_LOTECTL == D3_NUMSEQ+D3_LOTECTL .And. !(D3_ESTORNO=='S') .And. QtdComp(SDB->DB_QUANT)==QtdComp(D3_QUANT)
										RecLock('SD3', .F.) //-- Estorno do RE5
										Replace D3_ESTORNO With 'S'
										SD3->(MsUnlock())
										dDtValid := D3_DTVALID
										Exit
									EndIf
									DbSkip()
								EndDo
								//��������������������������������������������������������������Ŀ
								//� Caso item da NF seja p/OP, grava o numero da OP na requisicao�
								//����������������������������������������������������������������
								RecLock('SD3', .T.)  //-- Cria DE5
								Replace D3_FILIAL  With xFilial('SD3')
								Replace D3_COD     With SDB->DB_PRODUTO
								Replace D3_QUANT   With SDB->DB_QUANT
								Replace D3_CF      With 'DE5'
								Replace D3_CHAVE   With 'E9'
								Replace D3_LOCAL   With SDB->DB_LOCAL
								Replace D3_DOC     With If(lCQ,SD7->D7_NUMERO,SDB->DB_DOC)
								Replace D3_EMISSAO With dDataBase
								Replace D3_UM      With SB1->B1_UM
								Replace D3_GRUPO   With SB1->B1_GRUPO
								Replace D3_NUMSEQ  With If(lCQ,SD7->D7_NUMSEQ,SDB->DB_NUMSEQ)
								Replace D3_QTSEGUM With If(lCQ,SD7->D7_QTSEGUM,SDB->DB_QTSEGUM)
								Replace D3_SEGUM   With SB1->B1_SEGUM
								Replace D3_TM      With '499'
								Replace D3_TIPO    With SB1->B1_TIPO
								Replace D3_CONTA   With SB1->B1_CONTA
								Replace D3_USUARIO With CUSERNAME
								Replace D3_OP      With SD1->D1_OP
								Replace D3_NUMLOTE With SDB->DB_NUMLOTE
								Replace D3_LOTECTL With SDB->DB_LOTECTL
								Replace D3_LOCALIZ With SDB->DB_LOCALIZ
								Replace D3_IDENT   With SDB->DB_NUMSEQ
								Replace D3_DTVALID With dDtValid
								Replace D3_ESTORNO With 'S'
								SD3->(MsUnlock())
								//��������������������������������������������������������������Ŀ
								//� Array com os custos medios do produto                        �
								//����������������������������������������������������������������
								aCM := If(If(lCQ,SD7->D7_ORIGLAN=='CP',SDB->DB_ORIGEM=='SD1'),PegaCMD1(),PegaCMD3())
								//��������������������������������������������������������������Ŀ
								//� Grava o custo da movimentacao                                �
								//����������������������������������������������������������������
								aCusto := GravaCusD3(aCM)
								//��������������������������������������������������������������Ŀ
								//� Estorna o Empenho do SD4                                     �
								//����������������������������������������������������������������
								dbSelectArea('SD4')
								dbSetOrder(1)
								If MsSeek(xFilial('SD4')+SD1->D1_COD+SD1->D1_OP, .F.)
									nQtde := Min(D4_QUANT, SD1->D1_QUANT)
									RecLock('SD4',.F.)
									Replace D4_QUANT   With (D4_QUANT+nQtde)
									Replace D4_QTSEGUM With (D4_QTSEGUM+ConvUM(D4_COD, nQtde, 0, 2))
									SD4->(MsUnlock())
									dbSelectArea('SB2')
									dbSetOrder(1)
									If MsSeek(xFilial('SB2')+SD4->D4_COD+SD4->D4_LOCAL, .F.)
										nQtde := If(nQtde==NIL,SD1->D1_QUANT,nQtde)
										RecLock('SB2', .F.)
										Replace B2_QEMP  With (B2_QEMP+nQtde)
										Replace B2_QEMP2 With (B2_QEMP2+ConvUM(B2_COD, nQtde, 0, 2))
										SB2->(MsUnlock())
									EndIf
								EndIf
								//��������������������������������������������������������������Ŀ
								//� Atualiza o saldo atual (VATU) com os dados do SD3            �
								//����������������������������������������������������������������
								B2AtuComD3(aCusto)
								//��������������������������������������������������������������Ŀ
								//� Acerta custo da OP relacionada na NF de Entrada              �
								//����������������������������������������������������������������
								C2AtuComD3(aCusto)
								EndIf
						EndIf
						//��������������������������������������������������������������Ŀ
						//� Soma saldo no arquivo de Saldos a classificar   (SDA)        �
						//����������������������������������������������������������������
						dbSelectArea('SDA')
						dbSetOrder(1)
						If MsSeek(xFilial('SDA')+SDB->DB_PRODUTO+SDB->DB_LOCAL+SDB->DB_NUMSEQ, .F.)
							RecLock('SDA',.F.)
							Replace DA_SALDO   With (DA_SALDO+SDB->DB_QUANT)
							Replace DA_QTSEGUM With (DA_QTSEGUM+SDB->DB_QTSEGUM)
							Replace DA_EMPENHO With (DA_EMPENHO+SDB->DB_EMPENHO)
							Replace DA_EMP2    With (DA_EMP2+SDB->DB_EMP2)
							SDA->(MsUnlock())
						EndIf
						//��������������������������������������������������������������Ŀ
						//� Baixa Saldo no SBF baseado no movimento                      �
						//����������������������������������������������������������������
						GravaSBF('SDB')
					EndIf
				Else
					lRet := .F.
					cMensagem := "SIGAWMS - OS "+AllTrim(DCF->DCF_DOCTO)+Iif(!Empty(DCF->DCF_SERIE),"/"+AllTrim(SerieNfId("DCF",2,"DCF_SERIE")),"")+STR0013+AllTrim(DCF->DCF_CODPRO)+CLRF
					cMensagem += STR0011 //"Existem movimentos com data anterior � data de fechamento de estoque."
					WmsMessage(cMensagem,"WmsEstDCF",0,lExibeMsg)
					Exit
				EndIf
			EndIf
			(cAliasSDB)->(DbSkip())
		EndDo
		(cAliasSDB)->(DbCloseArea())
	EndIf

	If lRet
		//-- Altera o Status para NAO EXECUTADO no DCF
		DLA150Stat('1')
		If lDLA220E
			ExecBlock("DLA220E",.F.,.F.)
		EndIf
	EndIf

	If !lRet
		DisarmTransaction()
	EndIf
	End Transaction

RestArea(aAreaAnt)
Return lRet

/*------------------------------------------------------------------------------
------------------------------------------------------------------------------*/
Function WmsEstOri(cCarga,cDocto,cSerie,lExibeMsg)
Static lDLGA150D := ExistBlock("DLGA150D")
Local aAreaAnt := GetArea()
Local aAreaDCF := {}
Local cSeekDCF := ''
Local cCompDCF := ''
Local lRet     := .T.
Local lRetPE   := .F.

Default lExibeMsg := WmsMsgExibe()

	//-- Verifica se o processo eh por carga ou documento/serie
	If WmsCarga(cCarga)
		cCarga   := PadR(cCarga, Len(DCF->DCF_DOCORI))
		cSeekDCF := xFilial('DCF') + cCarga
		cCompDCF := "DCF_FILIAL+DCF_DOCORI"
	Else
		cDocto   := PadR(cDocto, Len(DCF->DCF_DOCORI))
		cSerie   := PadR(cSerie, Len(DCF->DCF_SERORI))
		cSeekDCF := xFilial('DCF') + cDocto + cSerie
		cCompDCF := "DCF_FILIAL+DCF_DOCORI+DCF_SERORI"
	EndIf

	//-- Estorna todos os documentos com referencia a carga ou documento original
	DCF->(DbSetOrder(7)) //DCF_FILIAL+DCF_DOCORI+DCF_SERORI
	DCF->(DbSeek(cSeekDCF))
	While lRet .And. DCF->(!Eof() .And. &cCompDCF==cSeekDCF)
		//-- Verifica status do servico
		If !WmsAvalDCF('3',,.F.)
			DCF->(DbSkip())
			Loop
		EndIf
		//-- Verifica se alguma atividade do servi�o j� foi executada
		If WmsChkSDB('4')
			DCF->(DbSkip())
			Loop
		EndIf
		//-- Ponto de Entrada DLGA150D (Antes do Estorno do Servico)
		//-- Parametros Passados:
		//-- PARAMIXB[1] = Produto
		//-- PARAMIXB[2] = Local
		//-- PARAMIXB[3] = Documento
		//-- PARAMIXB[4] = Serie
		//-- PARAMIXB[5] = Recno no DCF
		If lDLGA150D
			lRetPE := ExecBlock('DLGA150D', .F., .F., {DCF->DCF_CODPRO, DCF->DCF_LOCAL, DCF->DCF_DOCTO, DCF->DCF_SERIE, DCF->(Recno())})
			If ValType(lRetPE)=='L'
				lRet := lRetPE
			EndIf
		EndIf

		If lRet
			aAreaDCF := DCF->(GetArea()) // Guarda a �rea anterior da DCF
			lRet := WmsEstDCF(,lExibeMsg)
			DCF->(RestArea(aAreaDCF)) // Restaura a �rea anterior DCF
		EndIf

		If lRet
			//-- Estorna fisicamente a ordem de servico
			RecLock('DCF',.F.,.T.)
			DCF->(DbDelete())
			MsUnlock()
		EndIf
	EndDo

RestArea(aAreaAnt)
Return lRet

/*/-----------------------------------------------------------------------------
Atualiza campos endere�o e estrutura f�sica da tabela DCF quando informados
na Montagem de Carga ou Execu��o de Servi�os
-----------------------------------------------------------------------------/*/
Function WmsEndDCF(cEndereco,lEndVazio)
Local aArea      := GetArea()
Local cQuery     := ''
Local cAliasQry  := GetNextAlias()
Local lWmsNew    := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local oOrdServ   := Iif(lWmsNew,WMSDTCOrdemServico():New(),Nil)

Default lEndVazio := .T. //-- Atualiza somente OS sem informa��o de endere�o ou atualiza tudo

	cQuery := "SELECT R_E_C_N_O_ RECNODCF"
	cQuery +=  " FROM "+RetSqlName('DCF')+" DCF"
	cQuery += " WHERE DCF_FILIAL = '"+xFilial('DCF')+"'"
	cQuery +=   " AND DCF_DOCTO  = '"+SC9->C9_PEDIDO+"'"
	cQuery +=   " AND DCF_SERIE  = '"+SC9->C9_ITEM+"'"
	cQuery +=   " AND DCF_CLIFOR = '"+SC9->C9_CLIENTE+"'"
	cQuery +=   " AND DCF_LOJA   = '"+SC9->C9_LOJA+"'"
	cQuery +=   " AND DCF_CODPRO = '"+SC9->C9_PRODUTO+"'"
	cQuery +=   " AND DCF_ORIGEM = 'SC9'"
	cQuery +=   " AND DCF_STSERV IN ('1','2')"
	If lEndVazio
		cQuery += " AND DCF_ENDER  = ' '"
		cQuery += " AND DCF_ESTFIS = ' '"
	EndIf
	cQuery +=   " AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)

	While (cAliasQry)->(!Eof())
		If !lWmsNew
			DCF->(DbGoTo((cAliasQry)->RECNODCF))
			RecLock('DCF')
			DCF->DCF_ENDER  := cEndereco
			DCF->DCF_ESTFIS := Posicione('SBE',1,xFilial('SBE')+DCF->DCF_LOCAL+cEndereco,'BE_ESTFIS')
			MsUnlock()
		Else
			oOrdServ:GoToDCF((cAliasQry)->RECNODCF)
			oOrdServ:oOrdEndDes:SetEnder(cEndereco)
			oOrdServ:oOrdEndDes:LoadData()
			oOrdServ:UpdateDCF()
		EndIf
		(cAliasQry)->(DbSkip())
	EndDo

	(cAliasQry)->(DbCloseArea())
RestArea(aArea)
Return
/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � WmsChkDCF � Autor � Alex Egydio            �Data�29.08.2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Procura uma ordem de servico no WMS                        ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC01 - Alias do arquivo que gerou a O.S.WMS              ���
���          � ExpC02 - Carga                                             ���
���          � ExpC03 - Unitizador                                        ���
���          � ExpC04 - Servico                                           ���
���          � ExpC05 - Status da O.S.WMS a ser pesquisada                ���
���          � ExpN06 - Tipo de apanhe 1=Por Cliente / 2=Por Produto      ���
���          � ExpC07 - Documento                                         ���
���          � ExpC08 - Serie                                             ���
���          � ExpC09 - Cliente                                           ���
���          � ExpC10 - Loja                                              ���
���          � ExpC11 - Armazem                                           ���
���          � ExpC12 - Produto                                           ���
���          � ExpC13 - Lote                                              ���
���          � ExpC14 - Sub-Lote                                          ���
���          � ExpC15 - Sequencia                                         ���
���          � ExpC16 - Item                                              ���
���          � ExpN17 - Nr.do registro(DCF) encontrado pela funcao   (@)  ���
�������������������������������������������������������������������������Ĵ��
��� Retorno  � .T./.F. = O.S.WMS Encontrada/nao Encontrada                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
Function WmsChkDCF(cOrigem,cCarga,cUnitiz,cServico,cStServ,nTpApanhe,cDocto,cSerie,cCliFor,cLoja,cArmazem,cProduto,cLoteCtl,cNumLote,cNumSeq,cIdDCF,nPosDCF,cAcao,nQuant)
Local aAreaAnt := GetArea()
Local lRet     := .F.
Local cStatus  := "" //Utilizado para guardar o status no formato SQL
Local nX       := 0

Local cAliasQry := "DCF"
Local cQuery    := ""

Default cCarga   := ""
Default cUnitiz  := ""
Default cStServ  := ""
Default nTpApanhe:= 1
Default cSerie   := ""
Default cCliFor  := ""
Default cLoja    := ""
Default cLoteCtl := ""
Default cNumLote := ""
Default cNumSeq  := ""
Default nPosDCF  := 0
Default cAcao    := "1"
Default nQuant   := 0
Default cIdDCF   := ""

//Transforma o Status no formato SQL
If !Empty(cStServ)
	If At(cStServ,"'") > 0 //Se possui aspas simples deve estar no formato SQL
		cStatus = cStServ
	ElseIf Len(cStServ) == 1 //Se possui s� um digito, coloca aspas no mesmo
		cStatus := "'"+cStServ+"'"
	Else
		//Vai quebrando as situa��es e colocando aspas
		For nX = 0 To Len(cStServ)
			If IsDigit(SubStr(cStServ,nX+1,1))
				If Len(cStatus) > 0
					cStatus += ",'"+SubStr(cStServ,nX+1,1)+"'"
				Else
					cStatus += "'"+SubStr(cStServ,nX+1,1)+"'"
				EndIf
			EndIf
		Next
	EndIf
EndIf

If cAcao == "1"
	If !IntWMS(cProduto) .Or. (Empty(cServico) .And. cOrigem != "SD2")
		Return(.F.)
	EndIf

	cAliasQry := GetNextAlias()
	cQuery := "SELECT DCF.R_E_C_N_O_ RECDCF"
	cQuery +=  " FROM "+RetSqlName('DCF')+" DCF"
	cQuery += " WHERE DCF_FILIAL = '"+xFilial("DCF")+"'"
	cQuery +=   " AND DCF_SERVIC = '"+cServico+"'"
	cQuery +=   " AND DCF_LOCAL  = '"+cArmazem+"'"
	cQuery +=   " AND DCF_CODPRO = '"+cProduto+"'"
	If WmsCarga(cCarga)
		cQuery += " AND DCF_CARGA = '"+cCarga+"'"
	Else
		cQuery += " AND DCF_DOCTO  = '"+cDocto+"'"
		cQuery += " AND DCF_SERIE  = '"+cSerie+"'"
		cQuery += " AND DCF_CLIFOR = '"+cCliFor+"'"
		cQuery += " AND DCF_LOJA   = '"+cLoja+"'"
	EndIf
	If !Empty(cNumSeq)
		cQuery += " AND DCF_NUMSEQ = '"+cNumSeq+"'"
	Else
		If !Empty(cIdDCF)
			cQuery += " AND DCF_ID = '"+cIdDCF+"'"
		EndIf
	EndIf
	If !Empty(cStatus)
		 cQuery += " AND DCF_STSERV IN ("+cStatus+")"
	EndIf
	cQuery +=   " AND DCF.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	If (cAliasQry)->(!Eof())
		While (cAliasQry)->(!Eof())
			DCF->(DbGoTo((cAliasQry)->RECDCF))
			If Iif(!Empty(cLoteCtl) .And. !Empty(DCF->DCF_LOTECT),DCF->DCF_LOTECT == cLoteCtl,.T.) .And.;
				Iif(!Empty(cNumLote) .And. !Empty(DCF->DCF_NUMLOT),DCF->DCF_NUMLOT == cNumLote,.T.)
				//-- Garante que o dcf ficara posicionado no registro gerado, algumas rotinas recebem nposdcf como referencia
				nPosDCF := DCF->(Recno())
				lRet := .T.
				Exit
			EndIf
			(cAliasQry)->(DbSkip())
		EndDo
	Else
		lRet := .F.
	EndIf
	(cAliasQry)->(DbCloseArea())
ElseIf cAcao == "2"
	If !IntWMS(cProduto)
		Return(.F.)
	EndIf
	cAliasQry := GetNextAlias()
	cQuery := " SELECT DCF.R_E_C_N_O_ RECDCF"
	cQuery += " FROM " + RetSqlName('DCF')+" DCF"
	cQuery += " WHERE DCF_FILIAL   = '"+xFilial("DCF")+"'"
	cQuery += " AND DCF_CODPRO     = '"+cProduto+"'"
	cQuery += " AND DCF_DOCTO      = '"+cDocto+"'"
	cQuery += " AND DCF_SERIE      = '"+cSerie+"'"
	cQuery += " AND DCF_CLIFOR     = '"+cCliFor+"'"
	cQuery += " AND DCF_LOJA       = '"+cLoja+"'"
	cQuery += " AND DCF_NUMSEQ     = '"+cNumSeq+"'"
	cQuery += " AND DCF.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY DCF_FILIAL, DCF_CODPRO, DCF_DOCTO, DCF_SERIE, DCF_CLIFOR, DCF_LOJA, DCF_NUMSEQ"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
	If (cAliasQry)->(!Eof())
		lRet := .T.
		DCF->(MsGoTo((cAliasQry)->RECDCF))
	EndIf
	If lRet
		//-- Garante que o dcf ficara posicionado no registro gerado, algumas rotinas recebem nposdcf como referencia
		nPosDCF := DCF->(Recno())
	EndIf
	(cAliasQry)->(DbCloseArea())
ElseIf cAcao == "3"
	//-- Soma Saldos de Lotes/Sub-Lotes selecionados na liberacao do Pedido
	If IntWMS(cProduto) .And. !Empty(cLoteCtl+cNumLote)
		lRet := .T.
		cAliasQry := GetNextAlias()
		cQuery := " SELECT DCF_QUANT"
		cQuery += " FROM " + RetSqlName('DCF')+" DCF"
		cQuery += " WHERE DCF_FILIAL   = '"+xFilial("DCF")+"'"
		cQuery += " AND DCF_LOCAL      = '"+cArmazem+"'"
		cQuery += " AND DCF_CODPRO     = '"+cProduto+"'"
		cQuery += " AND DCF_LOTECT     = '"+cLoteCtl+"'"
		cQuery += " AND DCF_NUMLOT     = '"+cNumLote+"'"
		cQuery += " AND DCF_ORIGEM     = '"+cOrigem +"'"
		cQuery += " AND DCF_STSERV     IN ('1','2')"
		cQuery += " AND DCF.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
		While (cAliasQry)->(!Eof())
			nQuant += (cAliasQry)->DCF_QUANT
			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(DbCloseArea())
	EndIf
ElseIf cAcao == "4"
	//-- Verifica se existem ordens de servi�o executadas para o pedido
	cAliasQry := GetNextAlias()
	cQuery := "SELECT R_E_C_N_O_ RECNODCF"
	cQuery +=  " FROM "+RetSqlName('DCF')+" DCF"
	cQuery += " WHERE DCF_FILIAL = '"+xFilial('DCF')+"'"
	cQuery +=   " AND DCF_DOCTO  = '"+cDocto+"'"
	cQuery +=   " AND DCF_ORIGEM = '"+cOrigem+"'"
	cQuery +=   " AND DCF_STSERV IN ("+cStatus+")"
	cQuery +=   " AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)

	If (cAliasQry)->(!Eof())
		lRet := .T.
		//-- A mensagem s� serve para quando a fun��o � chamada para verificar se existe OS executada
		If cStServ == '3'
			WmsMessage(STR0012,"WmsChkDCF") //"Existem uma ou mais ordens de servi�o executadas. Ao informar destino do Servi�o WMS estas ordens de servi�o n�o sofrer�o altera��o"
		EndIf
	EndIf
	(cAliasQry)->(DbCloseArea())
EndIf

RestArea(aAreaAnt)
Return(lRet)
/*
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �WmsDelDCF| Autor � Alex Egydio                �Data�23.10.2006���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Estorno de movtos do wms, baseado nos campos _IDDCF          ���
���������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 - 1 = Acao tomada no faturamento                       ���
���          �             Executado por MaAvalSC9 com evento 2 e 8         ���
���          �         2 = Acao tomada no estorno do wms                    ���
���          �             Executado por DLA220Esto                         ���
���          � ExpC2 - Select utilizada na funcao dla220esto                ���
���          � ExpA1 - Vetor contendo os registros do SC9                   ���
���          � ExpL1 - Flag que determina se ha empenhos                    ���
���          � ExpA2 - Registros do arquivo DBN                             ���
���          � ExpA3 - Registros do arquivo DCF (preenchido pela funcao)    ���
���          � ExpL2 - .T. = Gravar DB_STATUS com "F", pois foi faturado.   ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������*/
Function WmsDelDCF(cAcao,cOrigem,cIdDCF,lExibeMsg,aRecDBN,aRecDCF)
Static lWMSXDCF  := ExistBlock("WMSXDCF")
Local aAreaAnt   := GetArea()
Local cServico   := ""
Local cCarga     := ""
Local cDocto     := ""
Local cSerie     := ""
Local cCliFor    := ""
Local cLoja      := ""
Local cArmazem   := ""
Local cProduto   := ""
Local cLoteCtl   := ""
Local cNumLote   := ""
Local cNumSeq    := ""
Local cAliasSDB  := ""
Local cQuery     := ""
Local nQuant     := 0
Local nQtdDel    := 0
Local nQtdDel2UM := 0
Local nQtdDelDCF := 0
Local cSeekDCF   := ""
Local cIdMovto   := ""
Local lRet       := .F.
Local n1Cnt      := 0
Local nRecDCF    := 0
Local cMensagem  := ""

Default cIdDCF    := ""
Default lExibeMsg := WmsMsgExibe()

If cAcao == "1"
	//-- Se foi passado o ID DCF deve pesquisar por ele para encontrar o OS
	If !Empty(cIdDCF)
		If !WmsPosDCF(cIdDCF)
			WmsMessage("SIGAWMS - "+STR0001+AllTrim(cIdDCF)+".","WmsDelDCF",1,lExibeMsg) //"N�o foi poss�vel encontrar a OS pelo identificador "
			RestArea(aAreaAnt)
			Return .F.
		EndIf
		nQuant := DCF->DCF_QUANT
	Else
		If cOrigem == "SC9"
			cServico := SC9->C9_SERVIC
			cCarga   := SC9->C9_CARGA
			cDocto   := SC9->C9_PEDIDO
			cSerie   := SC9->C9_ITEM
			cCliFor  := SC9->C9_CLIENTE
			cLoja    := SC9->C9_LOJA
			cArmazem := SC9->C9_LOCAL
			cProduto := SC9->C9_PRODUTO
			cLoteCtl := SC9->C9_LOTECTL
			cNumLote := SC9->C9_NUMLOTE
			cIdDCF   := SC9->C9_IDDCF
			nQuant   := SC9->C9_QTDLIB
			//-- Verifica se o pedido gera OS na carga, caso contr�rio n�o considera a carga
			If !Empty(cCarga)
				SC5->(DbSetOrder(1))
				If SC5->(MsSeek(xFilial("SC5")+SC9->C9_PEDIDO)) .And. SC5->C5_GERAWMS == "1"
					cCarga := "" //Limpa a carga, pois a OS foi gerada no pedido
				EndIf
			EndIf
		ElseIf cOrigem == "SD1"
			cServico := SD1->D1_SERVIC
			cDocto   := SD1->D1_DOC
			cSerie   := SD1->D1_SERIE
			cCliFor  := SD1->D1_FORNECE
			cLoja    := SD1->D1_LOJA
			cArmazem := SD1->D1_LOCAL
			cProduto := SD1->D1_COD
			cLoteCtl := SD1->D1_LOTECTL
			cNumLote := SD1->D1_NUMLOTE
			cNumSeq  := SD1->D1_NUMSEQ
			nQuant   := SD1->D1_QUANT
		ElseIf cOrigem == "SD2"
			cServico := SD2->D2_SERVIC
			cDocto   := SD2->D2_DOC
			cSerie   := SD2->D2_SERIE
			cCliFor  := SD2->D2_CLIENTE
			cLoja    := SD2->D2_LOJA
			cArmazem := SD2->D2_LOCAL
			cProduto := SD2->D2_COD
			cLoteCtl := SD2->D2_LOTECTL
			cNumLote := SD2->D2_NUMLOTE
			cNumSeq  := SD2->D2_NUMSEQ
			nQuant   := SD2->D2_QUANT
		ElseIf cOrigem == "SD3"
			cServico := SD3->D3_SERVIC
			cDocto   := SD3->D3_DOC
			cArmazem := SD3->D3_LOCAL
			cProduto := SD3->D3_COD
			cLoteCtl := SD3->D3_LOTECTL
			cNumLote := SD3->D3_NUMLOTE
			cNumSeq  := SD3->D3_NUMSEQ
			nQuant   := SD3->D3_QUANT
		EndIf
		//Verifica se encontra a ordem de servi�o
		If !WmsChkDCF(cOrigem,cCarga,,cServico,/*Status*/,,cDocto,cSerie,cCliFor,cLoja,cArmazem,cProduto,cLoteCtl,cNumLote,cNumSeq,cIdDCF)
			RestArea(aAreaAnt)
			Return .T. //N�o existe ordem de servi�o
		EndIf
	EndIf
	nQtdDelDCF := nQuant
	//Verifica se o servi�o j� foi executado
	If DCF->DCF_STSERV == "3"
		// A regra abaixo deve ser executada por tarefa para que no estorno da libera��o do pedido
		// ou altera��o de suas quantidades, todas as tarefas do servi�o sejam estornadas corretamente
		DC5->(DbSetOrder(1))
		DC5->(DbSeek(xFilial('DC5')+DCF->DCF_SERVIC))
		While !DC5->(Eof()) .And. xFilial('DC5')+DCF->DCF_SERVIC == DC5->DC5_FILIAL+DC5->DC5_SERVIC
			//S� considera para estorno autom�tico movimentos que n�o atualizam estoque
			//Pois se for movimentado algo, deve ser estornado manual a OS antes
			cQuery := "SELECT SDB.DB_IDMOVTO, SDB.DB_ORDATIV, SDB.R_E_C_N_O_ RECNOSDB"
			cQuery +=  " FROM "+RetSqlName("SDB")+" SDB"
			cQuery += " WHERE SDB.DB_FILIAL  = '"+xFilial("SDB")+"'"
			cQuery +=   " AND SDB.DB_SERVIC  = '"+DCF->DCF_SERVIC+"'"
			cQuery +=   " AND SDB.DB_TAREFA  = '"+DC5->DC5_TAREFA+"'"
			cQuery +=   " AND SDB.DB_PRODUTO = '"+DCF->DCF_CODPRO+"'"
			cQuery +=   " AND SDB.DB_LOCAL   = '"+DCF->DCF_LOCAL+"'"
			cQuery +=   " AND SDB.DB_ATUEST  = 'N'"
			cQuery +=   " AND SDB.DB_ESTORNO = ' '"
			cQuery +=   " AND SDB.D_E_L_E_T_ = ' '"
			cQuery +=   " AND EXISTS (SELECT 1 "
			cQuery +=                 " FROM "+RetSqlName("DCR")+" DCR"
			cQuery +=                " WHERE DCR.DCR_FILIAL = '"+xFilial("DCR")+"'"
			cQuery +=                  " AND DCR.DCR_IDDCF  = '"+DCF->DCF_ID+"'"
			cQuery +=                  " AND DCR.DCR_IDORI  = SDB.DB_IDDCF"
			cQuery +=                  " AND DCR.DCR_IDMOV  = SDB.DB_IDMOVTO"
			cQuery +=                  " AND DCR.DCR_IDOPER = SDB.DB_IDOPERA"
			cQuery +=                  " AND DCR.D_E_L_E_T_ = ' ')"
			cQuery += " ORDER BY SDB.DB_IDMOVTO, SDB.DB_ORDATIV"
			cQuery := ChangeQuery(cQuery)
			cAliasSDB := GetNextAlias()
			DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSDB,.F.,.T.)
			While (cAliasSDB)->(!Eof())
				SDB->(DbGoTo((cAliasSDB)->RECNOSDB))
				//Se o lote for preenchido e for diferente, n�o exclui
				If Iif(!Empty(cLoteCtl) .And. !Empty(SDB->DB_LOTECTL),SDB->DB_LOTECTL != cLoteCtl,.F.) .Or.;
					Iif(!Empty(cNumLote) .And. !Empty(SDB->DB_NUMLOTE),SDB->DB_NUMLOTE != cNumLote,.F.)
					(cAliasSDB)->(DbSkip())
					Loop
				EndIf
				//S� pode deletar a quantidade do movimento quando encontrar o pr�ximo
				If Iif(!Empty(cIdMovto),cIdMovto != SDB->DB_IDMOVTO,.F.)
					//Diminuindo a quantidade deletada
					nQuant -= nQtdDel
					If QtdComp(nQuant) <= QtdComp(0)
						Exit
					EndIf
				EndIf
				//-- Estorna somente movimenta��es de RF
				DbSelectArea("DCR")
				If DCR->(DbSeek(xFilial("DCR")+SDB->DB_IDDCF+DCF->DCF_ID+SDB->DB_IDMOVTO+SDB->DB_IDOPERA,.F.))
					If cIdMovto != SDB->DB_IDMOVTO
						If QtdComp(DCR->DCR_QUANT) <= QtdComp(nQuant)
							nQtdDel    := DCR->DCR_QUANT
							nQtdDel2UM := DCR->DCR_QTSEUM
						Else
							nQtdDel    := nQuant
							nQtdDel2UM := ConvUm(SDB->DB_PRODUTO,nQuant,0,2)
						EndIf
						cIdMovto := SDB->DB_IDMOVTO
					EndIf
					RecLock("SDB",.F.)
					If QtdComp(SDB->DB_QUANT - nQtdDel) == QtdComp(0)
						SDB->DB_ESTORNO := 'S'
					Else
						SDB->DB_QUANT   -= nQtdDel
						SDB->DB_QTSEGUM -= nQtdDel2UM
					EndIf
					SDB->(MsUnlock())
					//-- Elimina registro da DCR
					RecLock("DCR",.F.)
					If QtdComp(DCR->DCR_QUANT - nQtdDel) == QtdComp(0)
						DCR->(DbDelete())
					Else
						DCR->DCR_QUANT  -= nQtdDel
						DCR->DCR_QTSEUM -= nQtdDel2UM
					EndIf
					DCR->(MsUnlock())
				Else
					lRet := .F.
					cMensagem := "SIGAWMS - OS "+AllTrim(DCF->DCF_DOCTO)+Iif(!Empty(DCF->DCF_SERIE),"/"+AllTrim(DCF->DCF_SERIE),"")+STR0013+AllTrim(DCF->DCF_CODPRO)+CLRF
					cMensagem += STR0007+CLRF //"N�o foi poss�vel encontrar a movimenta��o relacionada (DCR)."
					cMensagem += RetTitle("DCF_ID")+": "+DCF->DCF_ID+CLRF
					cMensagem += RetTitle("DB_IDMOVTO")+": "+SDB->DB_IDMOVTO
					WmsMessage(cMensagem,"WmsDelDCF",1,lExibeMsg)
					Exit
				EndIf
				(cAliasSDB)->(DbSkip())
			EndDo
			(cAliasSDB)->(DbCloseArea())
			// Restaura as vari�veis para estornar a pr�xima tarefa
			nQuant   := nQtdDelDCF
			cIdMovto := ""
			DC5->(DbSkip())
		EndDo
	EndIf
	RecLock("DCF",.F.)
	//Diminuindo a quantidade ou excluindo a ordem de servi�o
	If QtdComp(DCF->DCF_QUANT) > QtdComp(nQtdDelDCF)
		DCF->DCF_QUANT  := DCF->DCF_QUANT - nQtdDelDCF
		DCF->DCF_QTSEUM := ConvUm(DCF->DCF_CODPRO,DCF->DCF_QUANT,0,2)
	Else
		If lWMSXDCF
			ExecBlock("WMSXDCF", .F., .F.)
		EndIf
		DCF->(DbDelete())
	EndIf
	DCF->(MsUnlock())
	If cOrigem == "SC9"
		// Estorna Mont. de Volumes e Conf. Expedi��o
		WMSEstVlCf(SC9->C9_SEQUEN)
		//Se exclui a ordem de servi�o, deve excluir o IDDCF da origem
		RecLock("SC9",.F.)
		SC9->C9_IDDCF  := ""
		SC9->C9_STSERV := ""
		SC9->(MsUnlock())
	EndIf
ElseIf cAcao=='2'
	//-- N�o � mais utilizado por nenhum processo
ElseIf cAcao=='3'
	//-- N�o � mais utilizado por nenhum processo
ElseIf cAcao=='4'
	lRet := .T.
	//-- Executado por OsAvalDAK
	For n1Cnt := 1 to Len(aRecDBN)
		DBN->(DbGoto(aRecDBN[n1Cnt]))
		If !Empty(DBN->DBN_SERVIC)
			DCF->(DbSetOrder(4))
			If DCF->(MsSeek(cSeekDCF := xFilial('DCF')+DBN->DBN_SERVIC+DBN->DBN_CARGA+DBN->DBN_UNITIZ))
				While DCF->(!Eof() .And. DCF->DCF_FILIAL+DCF->DCF_SERVIC+DCF->DCF_CARGA+DCF->DCF_UNITIZ==cSeekDCF)
					If DCF->DCF_STSERV=='1'
						lRet := .T.
						nRecDCF:=DCF->(Recno())
						If ASCan(aRecDCF,nRecDCF)==0
							aAdd(aRecDCF,nRecDCF)
						EndIf
					Else
						lRet:=.F.
						Exit
					EndIf
					DCF->(DbSkip())
				EndDo
				If !lRet
					Exit
				EndIf
			EndIf
			If WmsVldSrv('3',@cServico,,,DBN->DBN_CODPRO)
				If DCF->(MsSeek(cSeekDCF := xFilial('DCF')+cServico+DBN->DBN_CARGA+DBN->DBN_UNITIZ))
					While DCF->(!Eof() .And. DCF->DCF_FILIAL+DCF->DCF_SERVIC+DCF->DCF_CARGA+DCF->DCF_UNITIZ==cSeekDCF)
						If DCF->DCF_STSERV=='1'
							lRet :=.T.
							nRecDCF:=DCF->(Recno())
							If ASCan(aRecDCF,nRecDCF)==0
								aAdd(aRecDCF,nRecDCF)
							EndIf
						Else
							lRet:=.F.
							Exit
						EndIf
						DCF->(DbSkip())
					EndDo
					If !lRet
						Exit
					EndIf
				EndIf
			EndIf
		EndIf
	Next

ElseIf cAcao=='5'
	//-- N�o � mais utilizado por nenhum processo
EndIf
RestArea(aAreaAnt)
Return(lRet)

//----------------------------------------------------------
// Fun��o que verifica se existe (e exclui) servi�o WMS de confer�ncia relacionado
// a uma nota de entrada (SD1).
// Esta verifica��o � necess�ria, pois quando a nota � originada de uma pr�-nota, onde foi
// informado servi�o WMS de confer�ncia, ao realizar a classifica��o da mesma informado um
// servi�o de recebimento, os dados referentes ao servi�o de confer�ncia se perdem.
// Sendo assim, na exclus�o ou altera��o da pr�-nota, a OS original de confer�ncia n�o �
// exclu�da, permitindo ao usu�rio efetuar opera��es indevidas com este registro.
//
// Esta fun��o foi criada devido a uma exce��o e � chamada somente
// pela pela rotina Documento de Entrada (MATA103) - Chamado TQRQCF
//----------------------------------------------------------
Function WMSDelConf()
Local aArea     := GetArea()
Local cQuery    := ''
Local cAliasQry := GetNextAlias()

cQuery := "SELECT DCF.R_E_C_N_O_ RECNODCF"
cQuery +=  " FROM "+RetSqlName('DCF')+" DCF"
cQuery += " WHERE DCF.DCF_FILIAL = '"+xFilial("DCF")+"'"
cQuery +=   " AND DCF.DCF_LOCAL  = '"+SD1->D1_LOCAL +"'"
cQuery +=   " AND DCF.DCF_DOCTO  = '"+SD1->D1_DOC +"'"
cQuery +=   " AND DCF.DCF_SERIE  = '"+SD1->D1_SERIE +"'"
cQuery +=   " AND DCF.DCF_CLIFOR = '"+SD1->D1_FORNECE+"'"
cQuery +=   " AND DCF.DCF_LOJA   = '"+SD1->D1_LOJA+"'"
cQuery +=   " AND DCF.DCF_CODPRO = '"+SD1->D1_COD+"'"
cQuery +=   " AND EXISTS (SELECT 1"
cQuery +=                " FROM "+RetSqlName('DC5')+" DC5"
cQuery +=               " WHERE DC5.DC5_FILIAL  = '"+xFilial('DC5')+"'"
cQuery +=                  " AND DC5.DC5_SERVIC = DCF.DCF_SERVIC"
cQuery +=                  " AND DC5.DC5_TIPO   = '1'"
cQuery +=                  " AND DC5.DC5_FUNEXE = '000005'"
cQuery +=                  " AND DC5.D_E_L_E_T_ = ' ')"
cQuery +=   " AND DCF.D_E_L_E_T_ = ' '"
cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)

If (cAliasQry)->(!Eof())
	While (cAliasQry)->(!Eof())
		DCF->(DbGoTo((cAliasQry)->RECNODCF))
		If Iif(!Empty(SD1->D1_LOTECTL) .And. !Empty(DCF->DCF_LOTECT),DCF->DCF_LOTECT == SD1->D1_LOTECTL,.T.) .And.;
			Iif(!Empty(SD1->D1_NUMLOTE) .And. !Empty(DCF->DCF_NUMLOT),DCF->DCF_NUMLOT == SD1->D1_NUMLOTE,.T.)
			//Se achar a OS correspondente chama a fun��o de exclus�o da DCF
			WmsDelDCF('1',,DCF->DCF_ID)
			Exit
		EndIf
		(cAliasQry)->(DbSkip())
	EndDo
EndIf
(cAliasQry)->(DbCloseArea())

RestArea(aArea)
Return

//-----------------------------------
/*{Protheus.doc}
Valida o saldo dos endere�os no estorno de um servi�o de entrada

@param   cDocto      C�digo do documento
@param   cSerie      Serie do documento
@param   cLocal      C�digo do armaz�m
@param   cEndereco   C�digo do endere�o
@param   cProduto    C�digo do produto
@param   cNumSerie   N�mero de s�rie
@param   cLote       C�digo do lote
@param   cSubLote    C�digo do sublote
@param   nQuant      Quantidade da movimenta��o

@author  Guilherme Alexandre Metzger
@version P11
@since   28/10/14
*/
//-----------------------------------
Static Function VldEstEnt(cDocto,cSerie,cLocal,cEndereco,cProduto,cNumSerie,cLote,cSubLote,nQuant)
Local lRet      := .T.
Local nSaldoSBF := 0
Local nSaldoRF  := 0
Local cMensagem := ''

//Consulta os saldos de endere�o e pendente RF
nSaldoSBF := WmsSaldoSBF(cLocal,cEndereco,cProduto,cNumSerie,cLote,cSubLote,.F.,.F.,.F.,.F.,'1',.F.)
nSaldoRF  := WmsSaldoSBF(cLocal,cEndereco,cProduto,cNumSerie,cLote,cSubLote,.F.,.T.,.F.,.T.,'3')

If QtdComp(nQuant) > QtdComp(nSaldoSBF + nSaldoRF)
	//SIGAWMS - OS '#####'/'#####' - Produto: '#####'
	//O estorno n�o pode ser efetuado, pois o saldo do endere�o '#####' est� comprometido.
	//Quantidade para estorno de '###,##'
	//Endere�o possui saldo de '###,##'
	//Movimenta��es WMS pendentes de sa�da de '###,##'
	cMensagem := "SIGAWMS - OS "+AllTrim(cDocto)+Iif(!Empty(cSerie),"/"+AllTrim(SubStr(cSerie,1,3)),"")+STR0013+AllTrim(cProduto)+CLRF
	cMensagem += STR0014+AllTrim(cEndereco)+STR0015
	cMensagem += CLRF+STR0016+AllTrim(Transf(nQuant,PesqPictQt('DB_QUANT',14)))
	If nSaldoSBF > 0
		cMensagem += CLRF+STR0017+AllTrim(Transf(nSaldoSBF,PesqPictQt('DB_QUANT',14)))
	EndIf
	If nSaldoRF < 0 //Saldo de sa�da sempre ser� retornado negativo
		cMensagem += CLRF+STR0018+AllTrim(Transf(nSaldoRF*(-1),PesqPictQt('DB_QUANT',14)))
	EndIf
	WmsMessage(cMensagem,,1)
	lRet := .F.
EndIf

Return lRet

//----------------------------------------------------------
/*{Protheus.doc} VldEstDCF
Valida��es no estorno de ordem de servi�o

@param cMsg    Mensagem de alerta recebida por refer�ncia
               caso o estorno n�o possa ser executado

@author  Guilherme A. Metzger
@version P11
@since   07/03/2016
*/
//----------------------------------------------------------
Function VldEstDCF(cMsg)
Local aAreaAnt    := GetArea()
Local cAliasSC9   := ""
Local cAliasD0H   := ""
Local cAliasD0I   := ""
Local cQuery      := ""
Local cCodCofExp  := ""
Local cCodMntVol  := ""
Local oCofExpItem := Nil
Local oMntVolItem := Nil
Local lRet        := .T.

	// Verifica se alguma atividade da O.S. est� em execu��o
	If !DLA150ChDb(DCF->DCF_DOCTO,DCF->DCF_SERIE,DCF->DCF_CLIFOR,DCF->DCF_LOJA,DCF->DCF_SERVIC,DCF->DCF_ID)
		cMsg := WmsFmtMsg(STR0022,{{"[VAR01]",DCF->DCF_DOCTO},{"[VAR02]",DCF->DCF_SERIE}}) // "Existem atividades em execu��o para o documento: [VAR01] s�rie: [VAR02]"
		RestArea(aAreaAnt)
		Return .F.
	EndIf

	If WmsTipServ(DCF->DCF_SERVIC) == '2' // Sa�da
		// Verifica se existe item faturado para o documento
		cQuery := "SELECT C9_PEDIDO, C9_ITEM"
		cQuery +=  " FROM "+RetSqlName('SC9')+" SC9"
		cQuery += " WHERE C9_FILIAL  =  '"+xFilial('SC9')+"'"
		cQuery +=   " AND C9_IDDCF   =  '"+DCF->DCF_ID+"'"
		cQuery +=   " AND C9_NFISCAL <> ' '"
		cQuery +=   " AND D_E_L_E_T_ =  ' '"
		cAliasSC9 := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSC9,.F.,.T.)
		If !(cAliasSC9)->(Eof())
			cMsg := STR0023 + AllTrim((cAliasSC9)->C9_PEDIDO) + '/' + AllTrim((cAliasSC9)->C9_ITEM)
			lRet := .F.
		EndIf
		(cAliasSC9)->(DbCloseArea())
		// Verifica se existe endere�amento para o documento
		If lRet
			D00->(DbSetOrder(1)) // D00_FILIAL+D00_CARGA+D00_PEDIDO+D00_CODEND
			If D00->(DbSeek(xFilial("D00")+DCF->DCF_CARGA+AllTrim(DCF->DCF_DOCTO)))
				cMsg := WmsFmtMsg(STR0024,{{"[VAR01]",DCF->DCF_DOCTO},{"[VAR02]",DCF->DCF_SERIE}}) // "Existe endere�amento para o documento: [VAR01] s�rie: [VAR02]"
				lRet := .F.
			EndIf
		EndIf
		// Verifica se existe confer�ncia de expedi��o para o item do documento
		If lRet .And. Posicione('DC5',1,xFilial('DC5')+DCF->DCF_SERVIC,'DC5_COFEXP') == '1'
			cQuery := "SELECT D0H.D0H_CODEXP"
			cQuery +=  " FROM "+RetSqlName("D0H")+" D0H"
			cQuery += " WHERE D0H.D0H_FILIAL = '"+xFilial("D0H")+"'"
			cQuery +=   " AND D0H.D0H_IDDCF = '"+DCF->DCF_ID+"'"
			cQuery +=   " AND D0H.D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			cAliasD0H := GetNextAlias()
			dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasD0H,.F.,.T.)
			If !(cAliasD0H)->(Eof())
				cCodCofExp := (cAliasD0H)->D0H_CODEXP
			EndIf
			(cAliasD0H)->(dbCloseArea())
			// Valida montagem de volume
			oCofExpItem := WMSDTCConferenciaExpedicaoItens():New()
			oCofExpItem:SetCarga(DCF->DCF_CARGA)
			oCofExpItem:SetPedido(DCF->DCF_DOCTO)
			oCofExpItem:SetPrdOri(DCF->DCF_CODPRO)
			oCofExpItem:SetProduto(DCF->DCF_CODPRO)
			If !Empty(cCodCofExp)
				oCofExpItem:SetCodExp(cCodCofExp)
			Else
				// Busca o codigo da montagem de volume
				oCofExpItem:SetCodExp(oCofExpItem:oConfExp:FindCodExp())
			EndIf
			If oCofExpItem:LoadData() .And. oCofExpItem:GetStatus() != "1"
				cMsg := WmsFmtMsg(STR0024,{{"[VAR01]",DCF->DCF_DOCTO},{"[VAR02]",DCF->DCF_SERIE}}) // "Existe confer�ncia de expedi��o para o documento: [VAR01] s�rie: [VAR02]"
				lRet := .F.
			EndIf
		EndIf
		// Verifica se existe montagem de volumes para o item do documento
		If lRet
			cQuery := "SELECT D0I.D0I_CODMNT"
			cQuery +=  " FROM "+RetSqlName("D0I")+" D0I"
			cQuery += " WHERE D0I.D0I_FILIAL = '"+xFilial("D0I")+"'"
			cQuery +=   " AND D0I.D0I_IDDCF = '"+DCF->DCF_ID+"'"
			cQuery +=   " AND D0I.D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			cAliasD0I := GetNextAlias()
			dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasD0I,.F.,.T.)
			If !(cAliasD0I)->(Eof())
				cCodMntVol := (cAliasD0I)->D0I_CODMNT
			EndIf
			(cAliasD0I)->(dbCloseArea())
			// Valida montagem de volume
			oMntVolItem := WMSDTCMontagemVolumeItens():New()
			oMntVolItem:SetCarga(DCF->DCF_CARGA)
			oMntVolItem:SetPedido(DCF->DCF_DOCTO)
			oMntVolItem:SetPrdOri(DCF->DCF_CODPRO)
			oMntVolItem:SetProduto(DCF->DCF_CODPRO)
			If !Empty(cCodMntVol)
				oMntVolItem:SetCodMnt(cCodMntVol)
			Else
				// Busca o codigo da montagem de volume
				oMntVolItem:SetCodMnt(oMntVolItem:oMntVol:FindCodMnt())
			EndIf
			If oMntVolItem:LoadData() .And. oMntVolItem:GetStatus() != "1"
				cMsg := WmsFmtMsg(STR0026,{{"[VAR01]",DCF->DCF_DOCTO},{"[VAR02]",DCF->DCF_SERIE}}) // "Existem volumes montados para o documento: [VAR01] s�rie: [VAR02]"
				lRet := .F.
			EndIf
		EndIf
	EndIf

RestArea(aAreaAnt)
Return lRet

//----------------------------------------------------------
/*{Protheus.doc} WMSEstVlCf
Estorno de montagem de volumes e confer�ncia de expedi��o

@author  Guilherme A. Metzger
@version P11
@since   07/04/2016
*/
//----------------------------------------------------------
Static Function WMSEstVlCf(cSequen)
Local aAreaSC9  := SC9->(GetArea())
Local oConfExp  := Nil
Local oMntVol   := Nil

Default cSequen := ""

	// Estorna os dados da montagem de volumes
	If lMntVol
		oMntVol := WMSDTCMontagemVolume():New()
		oMntVol:SetCarga(DCF->DCF_CARGA)
		oMntVol:SetPedido(DCF->DCF_DOCTO)
		oMntVol:SetCodMnt(oMntVol:FindCodMnt())
		If oMntVol:LoadData()
			If !Empty(cSequen)
				WmsEstVol(oMntVol:GetCodMnt(),SC9->C9_CARGA,SC9->C9_PEDIDO,SC9->C9_PRODUTO,SC9->C9_LOTECTL,SC9->C9_NUMLOTE,SC9->C9_QTDLIB,SC9->C9_IDDCF)
			Else
				// Faz a busca para encontrar lote, sublote e quantidade
				// corretos de cada sequ�ncia de libera��o do pedido
				SC9->(DbSetOrder(9)) // C9_FILIAL+C9_IDDCF
				SC9->(DbSeek(xFilial('SC9')+DCF->DCF_ID))
				While !SC9->(Eof()) .And. (xFilial('SC9')+DCF->DCF_ID == SC9->C9_FILIAL+SC9->C9_IDDCF)
					WmsEstVol(oMntVol:GetCodMnt(),SC9->C9_CARGA,SC9->C9_PEDIDO,SC9->C9_PRODUTO,SC9->C9_LOTECTL,SC9->C9_NUMLOTE,SC9->C9_QTDLIB,SC9->C9_IDDCF)
					SC9->(DbSkip())
				EndDo
			EndIf
		EndIf
	EndIf

	// Estorna os dados da confer�ncia de expedi��o
	If Posicione('DC5',1,xFilial('DC5')+DCF->DCF_SERVIC,'DC5_COFEXP') == '1'
		oConfExp := WMSDTCConferenciaExpedicao():New()
		oConfExp:SetCarga(DCF->DCF_CARGA)
		oConfExp:SetPedido(DCF->DCF_DOCTO)
		oConfExp:SetCodExp(oConfExp:FindCodExp())
		If oConfExp:LoadData()
			If !Empty(cSequen)
				// Se a sequ�ncia vier preenchida j� estar� posicionado na SC9 correta
				WmsConfEst(oConfExp:GetCodExp(),SC9->C9_CARGA,SC9->C9_PEDIDO,SC9->C9_PRODUTO,SC9->C9_LOTECTL,SC9->C9_NUMLOTE,SC9->C9_QTDLIB,SC9->C9_IDDCF)
			Else
				// Faz a busca para encontrar lote, sublote e quantidade
				// corretos de cada sequ�ncia de libera��o do pedido
				SC9->(DbSetOrder(9)) // C9_FILIAL+C9_IDDCF
				SC9->(DbSeek(xFilial('SC9')+DCF->DCF_ID))
				While !SC9->(Eof()) .And. (xFilial('SC9')+DCF->DCF_ID == SC9->C9_FILIAL+SC9->C9_IDDCF)
					WmsConfEst(oConfExp:GetCodExp(),SC9->C9_CARGA,SC9->C9_PEDIDO,SC9->C9_PRODUTO,SC9->C9_LOTECTL,SC9->C9_NUMLOTE,SC9->C9_QTDLIB,SC9->C9_IDDCF)
					SC9->(DbSkip())
				EndDo
			EndIf
		EndIf
	EndIf

RestArea(aAreaSC9)
Return

//----------------------------------------------------------
/*{Protheus.doc} WmsAvalDAK
Avalia se pode excluir ou estornar pedidos de uma carga verificando se
os servi�os WMS j� foram executados para aqueles pedidos.
Somente poder� estornar direto caso o parametro MV_OMSESTP esteja como .T.
Pois neste caso quando exclu�do um item ou parte dele da carga a libera��o
do pedido de venda � estornada, voltando o processo ao in�cio

@author  Jackson Patrick Werka
@version P11
@since   07/04/2016
*/
//----------------------------------------------------------
Function WmsAvalDAK(cCarga,cSeqCar,cSeqEnt,cPedido,cItem,cSeqLib,nIndex,lEstPed,nQtdEst)
Local aAreaAnt  := GetArea()
Local aAreaSC9  := SC9->(GetArea())
Local lRet      := .T.
Local cSeekSC9  := ""
Local cWhileSC9 := ""
Local lWmsNew   := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local oOrdSerDel:= IIf(lWmsNew,WMSDTCOrdemServicoDelete():New(),Nil)

Default nIndex  := 5
Default lEstPed := .F.
Default nQtdEst := SC9->C9_QTDLIB

Private lWmsPergEP := .T.
Private lEstPedDAK := lEstPed

	// Se enviou a chave unica pesquisa pela chave unica
	If !Empty(cPedido) .And. !Empty(cItem) .And. !Empty(cSeqLib)
		nIndex := 1
	EndIf

	cCarga  := Iif(cCarga  == Nil,CriaVar("C9_CARGA") ,PadR(cCarga, TamSx3("C9_CARGA")[1]))
	cSeqCar := Iif(cSeqCar == Nil,CriaVar("C9_SEQCAR"),PadR(cSeqCar,TamSx3("C9_SEQCAR")[1]))
	cSeqEnt := Iif(cSeqEnt == Nil,CriaVar("C9_SEQENT"),PadR(cSeqEnt,TamSx3("C9_SEQENT")[1]))
	cPedido := Iif(cPedido == Nil,CriaVar("C9_PEDIDO"),PadR(cPedido,TamSx3("C9_PEDIDO")[1]))
	cItem   := Iif(cItem   == Nil,CriaVar("C9_ITEM")  ,PadR(cItem,  TamSx3("C9_ITEM")[1]))
	cSeqLib := Iif(cSeqLib == Nil,CriaVar("C9_SEQUEN"),PadR(cSeqLib,TamSx3("C9_SEQUEN")[1]))

	SC5->(DbSetOrder(1)) //C5_FILIAL+C5_NUM
	SC9->(DbSetOrder(nIndex))
	If nIndex == 5
		cSeekSC9  := xFilial('SC9')+cCarga+cSeqCar+Iif(Empty(cSeqEnt),"",cSeqEnt)
		cWhileSC9 := "C9_FILIAL+C9_CARGA+C9_SEQCAR"+Iif(Empty(cSeqEnt),"","+C9_SEQENT")
	Else
		cSeekSC9  := xFilial('SC9')+cPedido+cItem+Iif(Empty(cSeqLib),"",cSeqLib)
		cWhileSC9 := "C9_FILIAL+C9_PEDIDO+C9_ITEM"+Iif(Empty(cSeqLib),"","+C9_SEQUEN")
	EndIf
	If SC9->(MsSeek(cSeekSC9))
		While SC9->( !Eof() .And. &cWhileSC9 == cSeekSC9 )
			If IntWMS(SC9->C9_PRODUTO) .And. !Empty(SC9->C9_SERVIC) .And.;
				(Empty(cPedido) .Or. (!Empty(cPedido) .And. SC9->C9_PEDIDO == cPedido))
				If lEstPed .Or. (SC5->(MsSeek(xFilial('SC5')+SC9->C9_PEDIDO,.F.)) .And. SC5->C5_GERAWMS <> "1")
					//-- Procura ordem de servico do wms ja executada
					If !lWmsNew
						If !(lRet := WmsAvalSC9())
							Exit
						EndIf
					Else
						oOrdSerDel:SetIdDCF(SC9->C9_IDDCF)
						If oOrdSerDel:LoadData()
							oOrdSerDel:SetHasEst(lEstPed)
							If !oOrdSerDel:CanCancel(nQtdEst)
								WmsMessage(oOrdSerDel:GetErro(),"WmsAvalDAK",1)
								lRet := .F.
								Exit
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
			SC9->(DbSkip())
		EndDo
	EndIf

RestArea(aAreaSC9)
RestArea(aAreaAnt)
Return lRet

//------------------------------------------------------------------------------
Function WmsAvalSC5(cAcao)
Local aAreaAnt  := GetArea()
Local lRet      := .T.
Local nCntFor   := 1
Local nMaxArray := 1
Local nPosProd  := 1
Local nPosServ  := 1
Local nPosDest  := 1
Local lHasWMSIt := .F.

	// Por hora s� existe a a��o 1, por isso n�o trata
	If M->C5_TPCARGA == "2" .And. !(M->C5_GERAWMS == "1")
		// Descobre a posi��o dos campos no aHeader
		nPosProd  := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRODUTO"})
		nPosServ  := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_SERVIC" })
		nPosDest  := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_ENDPAD" })
		nMaxArray := Len(aCols)
		// Verifica ao menos um dos itens do pedido possui controle WMS
		For nCntFor := 1 To nMaxArray
			If !aCols[nCntFor][Len(aCols[nCntFor])] .And. IntWMS(aCols[nCntFor][nPosProd]) .And.;
				!Empty(aCols[nCntFor][nPosServ]) .And. !Empty(aCols[nCntFor][nPosDest])
				lHasWMSIt := .T.
				Exit
			EndIf
		Next nCntFor
		// Se possui produto WMS, apresenta a mensagem e retorna falso
		If lHasWMSIt
			WmsMessage(STR0027,"WmsAvalSC5",1) //"N�o ser� gerado ordem de servi�o WMS. Pedido n�o utiliza carga."
			lRet := .F.
		EndIf
	EndIf

RestArea(aAreaAnt)
Return lRet

//----------------------------------------------------------
/*{Protheus.doc} WmsAvalSC6
Valida��o de estorno da libera��o do pedido de venda
@author  felipe.m
@version P11
@since   09/08/2016
*/
//----------------------------------------------------------
Function WmsAvalSC6(cAcao,cAliasSC6,aCols,nLin,aHeader,lAltera,nQtdEst)
Local aAreaAnt   := GetArea()
Local lRet       := .T.
Local lWmsNew    := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local oSaldoWMS  := Nil // S� inst�ncia em caso de uso
Local oOrdSerDel := Nil // S� inst�ncia em caso de uso
Local nCol       := 0
Local cItemSC6   := ""
Local cProduto   := ""
Local cLoteCtl   := ""
Local cNumLote   := ""
Local cServico   := ""
Local cArmazem   := ""
Local cEndOrig   := ""
Local cEndDest   := ""
Local nSaldo     := 0
Local nQtdLib    := 0
Local aBoxDC8    := {}

Default cAliasSC6 := "SC6"
Default nQtdEst := SC9->C9_QTDLIB
// Vari�vel de controle do MATA410(Pedido de venda)
Default lAltera := .T.

	Do Case
		Case cAcao == "1" // Chamado via mata410 - Inclus�o/Altera��o de linha (LinhaOK)
			cItemSC6 := Iif((nCol := aScan(aHeader,{|x|Alltrim(x[2])=='C6_ITEM'}))   >0,aCols[nLin,nCol],CriaVar('C6_ITEM',   .F.))
			cServico := Iif((nCol := aScan(aHeader,{|x|Alltrim(x[2])=='C6_SERVIC'})) >0,aCols[nLin,nCol],CriaVar('C6_SERVIC', .F.))
			cArmazem := Iif((nCol := aScan(aHeader,{|x|Alltrim(x[2])=='C6_LOCAL'}))  >0,aCols[nLin,nCol],CriaVar('C6_LOCAL',  .F.))
			cEndOrig := Iif((nCol := aScan(aHeader,{|x|Alltrim(x[2])=='C6_LOCALIZ'}))>0,aCols[nLin,nCol],CriaVar('C6_LOCALIZ',.F.))
			cEndDest := Iif((nCol := aScan(aHeader,{|x|Alltrim(x[2])=='C6_ENDPAD'})) >0,aCols[nLin,nCol],CriaVar('C6_ENDPAD', .F.))
			// Valida a informa��o ou n�o do c�digo do servi�o WMS
			If !lWmsNew
				// No WMS atual n�o pode informar servi�o e endere�o origem ao mesmo tempo
				If !Empty(cEndOrig) .And. !Empty(cServico)
					WmsMessage(STR0032,"WmsAvalSC6",1) //"N�o informar servi�o WMS para itens com endere�o informado."
					lRet := .F.
				EndIf
			Else
				// No WMS novo � obrigat�rio informar o c�digo do servi�o
				If Empty(cServico)
					WmsMessage(STR0025,"WmsAvalSC6",1) //"� necess�rio informar o c�digo do servi�o para produtos que controlam WMS."
					lRet := .F.
				EndIf
			EndIf
			// Valida o servi�o informado se � do tipo expedi��o
			If lRet .And. !Empty(cServico)
				DC5->(DbSetOrder(1))
				DC5->(MsSeek(xFilial("DC5")+cServico))
				If DC5->DC5_TIPO != "2"
					WmsMessage(STR0028,"WmsAvalSC6",1) // Na inclus�o de um pedido de venda somente servi�os WMS do tipo sa�da podem ser utilizados.
					lRet := .F.
				EndIf
				If lRet
					lRet := VldSerTMS(cServico)
				EndIf
			EndIf
			// Se informou o endere�o destino deve validar se o mesmo � do tipo box/doca.
			If lRet .And. !Empty(cEndDest)
				SBE->(dbSetOrder(1))
				If SBE->(!DbSeek(xFilial('SBE')+cArmazem+cEndDest, .F.))
					WmsMessage(STR0033,"WmsAvalSC6",1) //"Endere�o n�o cadastrado (SBE)."
					lRet := .F.
				Else
					If DLTipoEnd(SBE->BE_ESTFIS) != 5
						WmsMessage(STR0034,"WmsAvalSC6",1) //"Para servi�os de sa�da somente endere�os de estrutura do tipo box/doca podem ser utilizados."
						lRet := .F.
					EndIf
				EndIf
			EndIf
			// Se est� alterando o pedido de venda valida se tem servi�o WMS j� executado
			If lRet .And. lAltera
				lRet := WmsChkSC9(M->C5_CLIENTE,M->C5_LOJACLI,M->C5_NUM,cItemSC6,nQtdEst)
			EndIf
			// Para o novo WMS quando informado o endere�o deve validar o saldo
			If lRet .And. lWmsNew .And. !Empty(cEndOrig)
				If !FwIsInCallStack("WMSV083PED") .And. WmsArmUnit(cArmazem)
					oEndereco := WMSDTCEndereco():New()
					oEndereco:SetArmazem(cArmazem)
					oEndereco:SetEnder(cEndOrig)
					If oEndereco:LoadData()
						If (oEndereco:GetTipoEst() != 2 .And. oEndereco:GetTipoEst() != 5)
							aBoxDC8 := StrTokArr(Posicione("SX3",2,"DC8_TPESTR",'X3CBox()'),';')
							WmsMessage(WmsFmtMsg(STR0035,{{"[VAR01]",aBoxDC8[oEndereco:GetTipoEst()]}}),"WmsAvalSC6",1,,,WmsFmtMsg(STR0036,{{"[VAR01]",aBoxDC8[2]},{"[VAR02]",aBoxDC8[5]}})) // "N�o � permitido informar o endere�o origem com estrutura f�sica [VAR01], quando o armaz�m controla unitizador (C6_LOCALIZ)."##"Informe um endere�o do tipo [picking] ou [doca]."
							lRet := .F.
						EndIf
					EndIf
				EndIf

				If lRet
					cProduto := Iif((nCol := aScan(aHeader,{|x|Alltrim(x[2])=='C6_PRODUTO'}))>0,aCols[nLin,nCol],CriaVar('C6_PRODUTO',.F.))
					cLoteCtl := Iif((nCol := aScan(aHeader,{|x|Alltrim(x[2])=='C6_LOTECTL'}))>0,aCols[nLin,nCol],CriaVar('C6_LOTECTL',.F.))
					cNumLote := Iif((nCol := aScan(aHeader,{|x|Alltrim(x[2])=='C6_NUMLOTE'}))>0,aCols[nLin,nCol],CriaVar('C6_NUMLOTE',.F.))
					nQtdLib  := Iif((nCol := aScan(aHeader,{|x|Alltrim(x[2])=='C6_QTDLIB'})) >0,aCols[nLin,nCol],CriaVar('C6_QTDLIB', .F.))

					If (Rastro(cProduto,"S") .And. (Empty(cNumLote) .Or. Empty(cLoteCtl))) .Or. (Rastro(cProduto,"L") .And. Empty(cLoteCtl))
						WmsMessage(STR0029,,,,,STR0030) //S� � poss�vel informar o endere�o de um produto com controle de rastro se o lote estiver preenchido.//Informe o lote/sub-lote do produto ou n�o informe o endere�o (C6_LOCALIZ).
						lRet := .F.
					EndIf
				EndIf

				If lRet .And. QtdComp(nQtdLib) > 0
					oSaldoWMS := WMSDTCEstoqueEndereco():New()
					nSaldo := oSaldoWMS:GetSldWMS(cProduto,cArmazem,cEndOrig,cLoteCtl,cNumLote,/*cNumSerie*/ Nil)
					If QtdComp(nSaldo) < QtdComp(nQtdLib)
						Help(" ",1,"SALDOLOCLZ")
						lRet := .F.
					EndIf
				EndIf
			EndIf

		Case cAcao == "2" // Chamado via mata410 - Exclus�o de linha
			cItemSC6 := Iif((nCol := aScan(aHeader,{|x|Alltrim(x[2])=='C6_ITEM'}))>0,aCols[nLin,nCol],CriaVar('C6_ITEM',.F.))

			If lAltera
				lRet := WmsChkSC9(M->C5_CLIENTE,M->C5_LOJACLI,M->C5_NUM,cItemSC6,nQtdEst)
			EndIf

		Case cAcao == "3" // Chamado via mata410 - Confirma��o inclus�o (TudoOK)
			cItemSC6 := Iif((nCol := aScan(aHeader,{|x|Alltrim(x[2])=='C6_ITEM'}))>0,aCols[nLin,nCol],CriaVar('C6_ITEM',.F.))

			If lAltera
				lRet := WmsChkSC9(M->C5_CLIENTE,M->C5_LOJACLI,M->C5_NUM,cItemSC6,nQtdEst)
			EndIf

			If lRet .And. lWmsNew
				cArmazem := Iif((nCol := aScan(aHeader,{|x|Alltrim(x[2])=='C6_LOCAL'}))  >0,aCols[nLin,nCol],CriaVar('C6_LOCAL',  .F.))
				cEndOrig := Iif((nCol := aScan(aHeader,{|x|Alltrim(x[2])=='C6_LOCALIZ'}))>0,aCols[nLin,nCol],CriaVar('C6_LOCALIZ',.F.))

				If !Empty(cEndOrig)
					nQtdLib  := Iif((nCol := aScan(aHeader,{|x|Alltrim(x[2])=='C6_QTDLIB'})) >0,aCols[nLin,nCol],CriaVar('C6_QTDLIB', .F.))

					If QtdComp(nQtdLib) > 0
						cProduto := Iif((nCol := aScan(aHeader,{|x|Alltrim(x[2])=='C6_PRODUTO'}))>0,aCols[nLin,nCol],CriaVar('C6_PRODUTO',.F.))
						cLoteCtl := Iif((nCol := aScan(aHeader,{|x|Alltrim(x[2])=='C6_LOTECTL'}))>0,aCols[nLin,nCol],CriaVar('C6_LOTECTL',.F.))
						cNumLote := Iif((nCol := aScan(aHeader,{|x|Alltrim(x[2])=='C6_NUMLOTE'}))>0,aCols[nLin,nCol],CriaVar('C6_NUMLOTE',.F.))
						oSaldoWMS := Iif(oSaldoWMS==Nil,WMSDTCEstoqueEndereco():New(),oSaldoWMS)
						nSaldo := oSaldoWMS:GetSldWMS(cProduto,cArmazem,cEndOrig,cLoteCtl,cNumLote,/*cNumSerie*/ Nil)
						If QtdComp(nSaldo) < QtdComp(nQtdLib)
							Help(" ",1,"SALDOLOCLZ")
							lRet := .F.
						EndIf
					EndIf
				EndIf
			EndIf


		Case cAcao == "4" //Chamado via mata461(Faturamento) e mata455(Libera��o do Estoque)
			// J� vem posicionado no SC9 correto
			If !lWmsNew
				lRet := WmsAvalSC9()
			Else
			   oOrdSerDel := WMSDTCOrdemServicoDelete():New()
				oOrdSerDel:SetIdDCF(SC9->C9_IDDCF)
				If oOrdSerDel:LoadData()
					oOrdSerDel:SetHasEst(.T.)
					If !(lRet := oOrdSerDel:CanCancel(nQtdEst)) .And. !Empty(oOrdSerDel:GetErro())
						WmsMessage(oOrdSerDel:GetErro(),"WmsAvalSC6",1)
					EndIf
				EndIf
			EndIf

	EndCase

RestArea(aAreaAnt)
Return lRet

//------------------------------------------------------------------------------
Static Function WmsChkSC9(cCliente,cLoja,cPedido,cItem,nQtdEst)
Local aAreaSC9   := SC9->(GetArea())
Local lRet       := .T.
Local lWmsNew    := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local oOrdSerDel := Iif(lWmsNew,WMSDTCOrdemServicoDelete():New(),Nil)

	// Posiciona em todas as sequencias SC9 referentes ao SC6
	SC9->(dbSetOrder(2)) //-- C9_FILIAL+C9_CLIENTE+C9_LOJA+C9_PEDIDO+C9_ITEM
	If SC9->(MsSeek(xFilial("SC9")+cCliente+cLoja+cPedido+cItem))
		Do While lRet .And. SC9->(!Eof()) .And. SC9->(C9_FILIAL+C9_CLIENTE+C9_LOJA+C9_PEDIDO+C9_ITEM) == xFilial("SC9")+cCliente+cLoja+cPedido+cItem
			If Empty(SC9->C9_NFISCAL) .And. !Empty(SC9->C9_SERVIC)
				If !lWmsNew
					If !(lRet := WmsAvalSC9())
						Exit
					EndIf
				Else
					oOrdSerDel:SetIdDCF(SC9->C9_IDDCF)
					If oOrdSerDel:LoadData()
						oOrdSerDel:SetHasEst(.T.)
						If !(lRet := oOrdSerDel:CanCancel(nQtdEst)) .And. !Empty(oOrdSerDel:GetErro())
							WmsMessage(oOrdSerDel:GetErro(),"WmsChkSC9",1)
							Exit
						EndIf
					EndIf
				EndIf
			EndIf
			SC9->(DbSkip())
		EndDo
	EndIf

RestArea(aAreaSC9)
Return lRet

//------------------------------------------------------------------------------
Static Function VldSerTMS(cServico)
Local aAreaAnt := GetArea()
Local lRet     := .T.
Local cQuery   := ""
Local cAliasQry:= GetNextAlias()

	cQuery := "SELECT DISTINCT DC5.DC5_SERVIC"
	cQuery +=  " FROM "+RetSqlName("DC5")+" DC5"
	cQuery += " WHERE DC5.DC5_FILIAL = '"+xFilial("DC5")+"'"
	cQuery +=   " AND DC5.DC5_SERVIC = '"+cServico+"'"
	cQuery +=   " AND DC5.DC5_TIPTRA <>'"+Criavar("DC5_TIPTRA",.F.)+"'"
	cQuery +=    "AND DC5.D_E_L_E_T_ = ' '"
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
	If (cAliasQry)->(!Eof())
		Help(' ',1, 'A410SERTMS')
		lRet := .F.
	EndIf
	(cAliasQry)->(dbCloseArea())

RestArea(aAreaAnt)
Return lRet

//----------------------------------------------------------
/*{Protheus.doc} WmsChkSC6
Valida a inclus�o e altera��o de pedidos.
@author  amanda.vieira
@version P11
@since   30/11/2016
*/
//----------------------------------------------------------
Function WmsChkSC6(cAcao,cLocaliza,cProduto,cLoteCtl,cNumLote)
Local lRet    := .T.
Default cAcao := "1"

	Do Case
		Case cAcao == "1" //Chamado do programa mata 410, ao incluir ou alterar um pedido.
			//Se o produto controla rastro e encontra-se informado o endere�o, ent�o � necess�rio informar o lote/sub-lote que ser� ser utilizado
			If !Empty(cLocaliza)
				If (Rastro(cProduto,"S") .And. (Empty(cNumLote) .Or. Empty(cLoteCtl))) .Or. (Rastro(cProduto,"L") .And. Empty(cLoteCtl))
					WmsMessage(STR0029,,,,,STR0030) //S� � poss�vel informar o endere�o de um produto com controle de rastro se o lote estiver preenchido.//Informe o lote/sub-lote do produto ou n�o informe o endere�o (C6_LOCALIZ).
					lRet := .F.
				EndIf
			EndIf
	EndCase
Return lRet
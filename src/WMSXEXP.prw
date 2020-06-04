#INCLUDE "PROTHEUS.CH"
#INCLUDE "WMSXEXP.CH"
#DEFINE CLRF  CHR(13)+CHR(10)

Static lMntVol   := SuperGetMV('MV_WMSVEMB',.F.,.F.)
Static lDLVESTC9 := ExistBlock("DLVESTC9")
Static lWMSQMSEP := ExistBlock("WMSQMSEP")

/*-----------------------------------------------------------------------------
Tem por objetivo atualizar a quantidade liberada no pedido de venda de acordo com
o apanhe no WMS, atualizando informações na SC9 e gerando o empenho para a SDC
-----------------------------------------------------------------------------*/
Function WmsAtuSC9(cCarga,cPedido,cItem,cProduto,cServico,cLoteCtl,cNumLote,cNumSerie,nQuant,nQuant2UM,cLocal,cEndereco,cIdDCF,nTipoRegra,xRegra,lWmsLibSC9,lGeraEmp)
Local lRet       := .T.
Local lWmsNew    := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local lWmsAglu   := SuperGetMV('MV_WMSAGLU',.F.,.F.) .Or. lWmsNew //-- Aglutina itens da nota fiscal de saida com mesmo Lote e Sub-Lote
Local lLote      := Rastro(cProduto)
Local lSLote     := Rastro(cProduto,'S')
Local aAreaAnt   := GetArea()
Local aCopySC9   := {}
Local cWhere     := ""
Local cAliasSC9  := GetNextAlias()
Local cAliasSDC  := Nil
Local cAliasSB8  := Nil
Local cSeqSC9    := ""
Local cOrigem    := "SC6"
Local cNewSeq    := ""
Local cMensagem  := ""
Local nQtdLib    := 0
Local nQtdLib2UM := 0
Local nDifLib    := 0
Local nDifLib2UM := 0
Local nQtdLibTot := 0
Local nCnt       := 0
Local dDtValid   := CtoD('  /  /  ')

Default cNumSerie  := Space(Len(SC9->C9_NUMSERI))
Default cIdDCF     := ""
Default nQuant2UM  := ConvUM(cProduto, nQuant, 0, 2)
Default nTipoRegra := 3
Default xRegra     := dDtValid
Default lWmsLibSC9 := .T.
Default lGeraEmp   := .T.

	// Parâmetro Where
	cWhere := "%"
	If !lWmsNew
		If lLote .And. nTipoRegra == 1 .And. !Empty(xRegra)
			cWhere += " AND SC9.C9_LOTECTL = '"+xRegra+"'"
		EndIf
	Else
		cWhere += " AND SC9.C9_LOTECTL = '"+cLoteCtl+"'"
		cWhere += " AND SC9.C9_NUMLOTE = '"+cNumLote+"'"
	EndIf	
	cWhere += "%"
	If WmsCarga(cCarga)
		BeginSql Alias cAliasSC9
			SELECT SC9.C9_SEQUEN,
					SC9.R_E_C_N_O_ RECNOSC9
			FROM %Table:SC9% SC9
			WHERE SC9.C9_FILIAL = %xFilial:SC9%
			AND SC9.C9_CARGA = %Exp:cCarga%
			AND SC9.C9_PRODUTO = %Exp:cProduto%
			AND SC9.C9_SERVIC = %Exp:cServico%
			AND SC9.C9_IDDCF = %Exp:cIdDCF%
			AND SC9.C9_BLWMS = '01'
			AND SC9.C9_NFISCAL = '  '
			AND SC9.%NotDel%
			%Exp:cWhere%
			ORDER BY C9_SEQUEN
		EndSql
	Else
		BeginSql Alias cAliasSC9
			SELECT SC9.C9_SEQUEN,
					SC9.R_E_C_N_O_ RECNOSC9
			FROM %Table:SC9% SC9
			WHERE SC9.C9_FILIAL = %xFilial:SC9%
			AND SC9.C9_PEDIDO = %Exp:cPedido%
			AND SC9.C9_ITEM = %Exp:cItem%
			AND SC9.C9_PRODUTO = %Exp:cProduto%
			AND SC9.C9_SERVIC = %Exp:cServico%
			AND SC9.C9_IDDCF = %Exp:cIdDCF%
			AND SC9.C9_BLWMS = '01'
			AND SC9.C9_NFISCAL = '  '
			AND SC9.%NotDel%
			%Exp:cWhere%
			ORDER BY C9_SEQUEN
		EndSql
	EndIf
	Do While lRet .And. (cAliasSC9)->(!Eof()) .And. QtdComp(nQuant) > 0

		SC9->(dbGoTo((cAliasSC9)->RECNOSC9)) //-- Posiciona no registro do SC9 correspondente
		RecLock("SC9", .F.)
		SC9->(dbGoTo((cAliasSC9)->RECNOSC9)) //-- Força a releitura do registro SC9 correspondente
		If SC9->(Eof()) //-- Pode ser que o RECNO tenha sido deletado
			(cAliasSC9)->(dbSkip())
			Loop
		EndIf
		//-- Quando é por carga, porém a OS é gerada no pedido
		cCarga   := SC9->C9_CARGA
		//-- Pode ser que tenha sido por carga, então não tinha o pedido
		cPedido  := SC9->C9_PEDIDO
		cItem    := SC9->C9_ITEM
		cSeqSC9  := SC9->C9_SEQUEN
		nQtdLib  := SC9->C9_QTDLIB
		//-- Se não libera o SC9, deve verificar se o saldo desta sequencia não está todo empenhado
		If !lWmsLibSC9 .And. (!lLote .Or. (lLote .And. !Empty(SC9->C9_LOTECTL)))
			cAliasSDC := GetNextAlias()
			BeginSql Alias cAliasSDC
				SELECT SDC.DC_QUANT
				FROM %Table:SDC% SDC
				WHERE SDC.DC_FILIAL = %xFilial:SDC% 
				AND SDC.DC_PRODUTO = %Exp:cProduto%
				AND SDC.DC_LOCAL = %Exp:cLocal%
				AND SDC.DC_ORIGEM = %Exp:cOrigem%
				AND SDC.DC_PEDIDO = %Exp:cPedido%
				AND SDC.DC_ITEM = %Exp:cItem%
				AND SDC.DC_SEQ = %Exp:cSeqSC9%
				AND SDC.DC_LOTECTL = %Exp:SC9->C9_LOTECTL%
				AND SDC.DC_NUMLOTE = %Exp:SC9->C9_NUMLOTE%
				AND SDC.DC_LOCALIZ = %Exp:cEndereco%
				AND SDC.DC_NUMSERI = %Exp:SC9->C9_NUMSERI%
				AND SDC.%NotDel%
			EndSql
			If (cAliasSDC)->(!Eof())
				nQtdLib -= (cAliasSDC)->DC_QUANT
			EndIf
			(cAliasSDC)->(dbCloseArea())
			If QtdComp(nQtdLib) <= QtdComp(0)
				(cAliasSC9)->(DbSkip())
				Loop
			EndIf
		EndIf
		//-- Joga toda a quantidade liberada deste apanhe na 1a sequencia disponivel do SC9
		If QtdComp(nQtdLib) > QtdComp(nQuant)
			nQtdLib    := nQuant
			nQtdLib2UM := ConvUM(cProduto, nQtdLib, 0, 2)
			nDifLib    := SC9->C9_QTDLIB - nQtdLib
			nDifLib2UM := ConvUM(cProduto, nDifLib, 0, 2)
		Else
			nQtdLib    := Min(nQtdLib,nQuant)
			nQtdLib2UM := ConvUM(cProduto, nQtdLib, 0, 2)
			nDifLib    := 0
			nDifLib2UM := 0
		EndIf
		//-- Aglutina itens da nota fiscal de saida com mesmo Lote e Sub-Lote
		If lWmsAglu .And. cSeqSC9 != "01" .And.;
		WmsAgluSC9(cCarga,cPedido,cItem,cProduto,cLoteCtl,cNumLote,cNumSerie,nQtdLib,nQtdLib2UM,cLocal,cEndereco,cIdDCF,lWmsLibSC9,lGeraEmp,cSeqSC9)
			//-- Deve diminuir a quantidade da SC9 atual apenas
			SC9->C9_QTDLIB  -= nQtdLib
			SC9->C9_QTDLIB2 -= nQtdLib2UM
			If QtdComp(SC9->C9_QTDLIB) <= 0
				SC9->(DbDelete())
			EndIf
			SC9->(MsUnlock())
		Else
			If lWmsLibSC9 .Or.;
				lLote .And. SC9->C9_LOTECTL != cLoteCtl .Or.;
				lSLote .And. SC9->C9_NUMLOTE != cNumLote
				//-- Guarda o conteudo dos campos do SC9 em uma variavel
				If QtdComp(nDifLib) > 0
					For nCnt := 1 To SC9->(FCount())
						AAdd(aCopySC9, SC9->(FieldGet(nCnt)))
					Next nCnt
				EndIf
				//Se controla rastro e não tem a data de validade, deve buscar a mesma
				If lLote
					cAliasSB8 := GetNextAlias()
					If lSLote
						BeginSql Alias cAliasSB8
							SELECT SB8.B8_DTVALID
							FROM %Table:SB8% SB8
							WHERE SB8.B8_FILIAL = %xFilial:SB8%
							AND SB8.B8_PRODUTO = %Exp:cProduto%
							AND SB8.B8_LOCAL = %Exp:cLocal%
							AND SB8.B8_LOTECTL = %Exp:cLoteCtl%
							AND SB8.B8_NUMLOTE = %Exp:cNumLote%
							AND SB8.%NotDel%
						EndSql
					Else
						BeginSql Alias cAliasSB8
							SELECT SB8.B8_DTVALID
							FROM %Table:SB8% SB8
							WHERE SB8.B8_FILIAL = %xFilial:SB8%
							AND SB8.B8_PRODUTO = %Exp:cProduto%
							AND SB8.B8_LOCAL = %Exp:cLocal%
							AND SB8.B8_LOTECTL = %Exp:cLoteCtl%
							AND SB8.%NotDel%
						EndSql
					EndIf
					TcSetField(cAliasSB8,'B8_DTVALID','D')
					If (cAliasSB8)->(!Eof())
						dDtValid := (cAliasSB8)->B8_DTVALID
					EndIf
					(cAliasSB8)->(dbCloseArea())
				EndIf
				SC9->C9_QTDLIB  := nQtdLib
				SC9->C9_QTDLIB2 := nQtdLib2UM
				SC9->C9_LOTECTL := cLoteCtl
				SC9->C9_NUMLOTE := cNumLote
				SC9->C9_DTVALID := dDtValid
				SC9->C9_LOCAL   := cLocal
				SC9->C9_POTENCI := 0
				SC9->C9_QTDRESE := Min(nQuant,SC9->C9_QTDRESE)
				SC9->C9_DATALIB := dDataBase
				SC9->C9_IDDCF   := cIdDCF
				SC9->C9_BLWMS   := Iif(lWmsLibSC9,"05","01")
				SC9->(MsUnlock())
				//-- Se restou quantidade a ser liberada
				If QtdComp(nDifLib) > 0
					//-- Pega a sequencia máxima da SC9
					cNewSeq := MaxSeqSC9(cPedido,cItem,cProduto)
					cNewSeq := Soma1(cNewSeq,Len(SC9->C9_SEQUEN))
					RecLock("SC9", .T.)
					For nCnt := 1 To Len(aCopySC9)
						FieldPut(nCnt, aCopySC9[nCnt])
					Next nCnt
					SC9->C9_SEQUEN  := cNewSeq
					SC9->C9_QTDLIB  := nDifLib
					SC9->C9_QTDLIB2 := nDifLib2UM
					SC9->C9_BLWMS   := "01"
					SC9->(MsUnlock())
				EndIf
			EndIf
			If lGeraEmp
				//-- Deve gerar o empenho para a quantidade liberada
				lRet := WmsAtuSDC("SC6",/*cOp*/,/*cTrt*/,cPedido,cItem,cSeqSC9,cProduto,cLoteCtl,cNumLote,cNumSerie,nQtdLib,nQtdLib2UM,cLocal,cEndereco,cIdDCF,1)
			EndIf
		EndIf
		//-- Diminui da quantidade total a quantidade liberada
		nQuant -= nQtdLib
		nQtdLibTot += nQtdLib

		(cAliasSC9)->(DbSkip())
	EndDo
	(cAliasSC9)->(DbCloseArea())

	If lRet .And. QtdComp(nQuant) > 0
		//Não foi possível liberar toda a quantidade solicitada do pedido de venda.
		//Pedido: 000000 - Item: 000 - ID DCF: 000000
		//Qtd Solicitada: 999.999,000
		//Qtd Liberada: 999.999,000
		cMensagem := STR0001+CLRF // "Não foi possível liberar toda a quantidade solicitada do pedido de venda."
		If WmsCarga(cCarga)
			cMensagem += Trim(RetTitle("C9_CARGA"))+": "+cCarga+" - "+Trim(RetTitle("DCF_ID"))+": "+cIdDCF+CLRF
		Else
			cMensagem += Trim(RetTitle("C9_PEDIDO"))+": "+cPedido+" - "+Trim(RetTitle("C9_ITEM"))+": "+cItem+" - "+Trim(RetTitle("DCF_ID"))+": "+cIdDCF+CLRF
		EndIf
		cMensagem += STR0002+AllTrim(Transf((nQuant+nQtdLibTot),PesqPictQt('C9_QTDLIB',14)))+CLRF //"Qtd Solicitada: "
		cMensagem += STR0003+AllTrim(Transf(nQtdLibTot,PesqPictQt('C9_QTDLIB',14))) // "Qtd Liberada: "
		WmsMessage(cMensagem,"WmsAtuSC9",1)
		lRet := .F.
	EndIf

RestArea(aAreaAnt)
Return lRet

/*-----------------------------------------------------------------------------
Tem por objetivo dividir uma quantidade liberada no pedido de venda, atualizando
informações na SC9 e atualizando o empenho na SDC
-----------------------------------------------------------------------------*/
Function WmsDivSC9(cCarga,cPedido,cItem,cProduto,cServico,cLoteCtl,cNumLote,cNumSerie,nQuant,nQuant2UM,cLocal,cEndereco,cIdDCF,lWmsLibSC9,lGeraEmp,cBlqWMS,nRecSC9,cRomaneio,cSeqSC9,lLotVazio,nNewRecno,dDtValid)
Local lRet       := .T.
Local lIntWMS    := IntWMS(cProduto,.T.)
Local aAreaAnt   := GetArea()
Local aCopySC9   := {}
Local cLoteCtAux := ""
Local cNumLotAux := ""
Local cAliasSC9  := Nil
Local nCnt       := 0
Local nQtdLib    := 0
Local nQtdLib2UM := 0

Default cCarga     := Space(Len(SC9->C9_CARGA))
Default cPedido    := Space(Len(SC9->C9_PEDIDO))
Default cItem      := Space(Len(SC9->C9_ITEM))
Default cProduto   := Space(Len(SC9->C9_PRODUTO))
Default cLoteCtl   := Space(Len(SC9->C9_LOTECTL))
Default cNumLote   := Space(Len(SC9->C9_NUMLOTE))
Default cNumSerie  := Space(Len(SC9->C9_NUMSERI))
Default cIdDCF     := ''
Default nQuant2UM  := ConvUM(cProduto, nQuant, 0, 2)
Default lWmsLibSC9 := .T.
Default lGeraEmp   := .T.
Default cBlqWMS    := Iif(lWmsLibSC9,"01","05")
Default nRecSC9    := 0
Default cRomaneio  := ''
Default cSeqSC9    := ''
Default lLotVazio  := .F.
Default nNewRecno  := SC9->(Recno())
Default dDtValid   := nil 

	cAliasSC9 := GetNextAlias()
	If nRecSC9 == 0
		If !Empty(cLoteCtl) .And. !lLotVazio
			cLoteCtAux := cLoteCtl
			cNumLotAux := cNumLote
		EndIf
		If lLotVazio
			cLoteCtAux := ""
			cNumLotAux := ""
		EndIf
		If WmsCarga(cCarga)
			BeginSql Alias cAliasSC9
				SELECT SC9.C9_SEQUEN,
						SC9.R_E_C_N_O_ RECNOSC9
				FROM %Table:SC9% SC9
				WHERE SC9.C9_FILIAL = %xFilial:SC9%
				AND SC9.C9_CARGA = %Exp:cCarga%
				AND SC9.C9_PRODUTO = %Exp:cProduto%
				AND SC9.C9_SERVIC = %Exp:cServico%
				AND SC9.C9_LOTECTL = %Exp:cLoteCtAux%
				AND SC9.C9_NUMLOTE = %Exp:cNumLotAux%
				AND SC9.C9_IDDCF = %Exp:cIdDCF%
				AND SC9.C9_BLWMS = %Exp:cBlqWMS%
				AND SC9.C9_NFISCAL = '  '
				AND SC9.%NotDel%
				ORDER BY C9_SEQUEN
			EndSql
		Else
			BeginSql Alias cAliasSC9
				SELECT SC9.C9_SEQUEN,
						SC9.R_E_C_N_O_ RECNOSC9
				FROM %Table:SC9% SC9
				WHERE SC9.C9_FILIAL = %xFilial:SC9%
				AND SC9.C9_PEDIDO = %Exp:cPedido%
				AND SC9.C9_ITEM = %Exp:cItem%
				AND SC9.C9_PRODUTO = %Exp:cProduto%
				AND SC9.C9_SERVIC = %Exp:cServico%
				AND SC9.C9_LOTECTL = %Exp:cLoteCtAux%
				AND SC9.C9_NUMLOTE = %Exp:cNumLotAux%
				AND SC9.C9_IDDCF = %Exp:cIdDCF%
				AND SC9.C9_BLWMS = %Exp:cBlqWMS%
				AND SC9.C9_NFISCAL = '  '
				AND SC9.%NotDel%
				ORDER BY C9_SEQUEN
			EndSql
		EndIf
	Else
		BeginSql Alias cAliasSC9
			SELECT SC9.C9_SEQUEN,
					SC9.R_E_C_N_O_ RECNOSC9
			FROM %Table:SC9% SC9
			WHERE SC9.C9_FILIAL = %xFilial:SC9%
			AND SC9.R_E_C_N_O_ = %Exp:nRecSC9%
			AND SC9.%NotDel%
		EndSql
	EndIf
	Do While lRet .And. (cAliasSC9)->(!Eof()) .And. QtdComp(nQuant) > 0
		SC9->(DbGoTo((cAliasSC9)->RECNOSC9))
		
		RecLock("SC9", .F.)
		//-- Pode ser que tenha sido por carga, então não tinha o pedido
		cPedido    := SC9->C9_PEDIDO
		cItem      := SC9->C9_ITEM
		cSeqSC9    := SC9->C9_SEQUEN
		nQtdLib    := SC9->C9_QTDLIB
		nQtdLib2UM := SC9->C9_QTDLIB2
		//-- Verifica se a quantidade liberada nesta sequencia é menor ou igual ao solicitado
		If QtdComp(nQtdLib) <= QtdComp(nQuant)
			//-- Só liberar esta sequencia da SC9, não há o que dividir
			SC9->C9_SERVIC := cServico
			SC9->C9_IDDCF  := cIdDCF
			If lIntWms
				SC9->C9_BLWMS  := Iif(lWmsLibSC9,"05","01")
			Else
				SC9->C9_BLWMS  := ""
			EndIf
			If SC9->C9_LOTECTL <> cLoteCtl
				SC9->C9_LOTECTL := cLoteCtl
				SC9->C9_NUMLOTE := cNumLote
				If dDtValid <> nil
					SC9->C9_DTVALID := dDtValid
				EndIf
			EndIf
			SC9->C9_ROMEMB := cRomaneio
			SC9->(MsUnlock())
		Else
			nQtdLib    := Min(nQtdLib,nQuant)
			nQtdLib2UM := ConvUM(cProduto, nQtdLib, 0, 2)
			// Efetua cópia da SC9
			For nCnt := 1 To SC9->(FCount())
				AAdd(aCopySC9, SC9->(FieldGet(nCnt)))
			Next nCnt
			// Atualiza informações
			SC9->C9_QTDLIB  -= nQtdLib
			SC9->C9_QTDLIB2 -= nQtdLib2UM
			SC9->(MsUnlock())
			//-- Estorna o empenho extra gerado para esta sequencia original
			If lGeraEmp
				lRet := WmsAtuSDC("SC6",/*cOp*/,/*cTrt*/,cPedido,cItem, cSeqSC9 ,cProduto,cLoteCtl,cNumLote,cNumSerie,nQtdLib,nQtdLib2UM,cLocal,cEndereco,cIdDCF,1,.T.)
			EndIf
			If lRet
				//-- Pega a sequencia máxima da SC9
				cSeqSC9 := MaxSeqSC9(cPedido,cItem,cProduto)
				cSeqSC9 := Soma1(cSeqSC9,Len(SC9->C9_SEQUEN))
			
				RecLock("SC9", .T.)
				For nCnt := 1 To Len(aCopySC9)
					FieldPut(nCnt, aCopySC9[nCnt])
				Next nCnt
				SC9->C9_SEQUEN  := cSeqSC9
				SC9->C9_QTDLIB  := nQtdLib
				SC9->C9_QTDLIB2 := nQtdLib2UM
				SC9->C9_IDDCF   := cIdDCF
				SC9->C9_SERVIC  := cServico
				If SC9->C9_LOTECTL <> cLoteCtl
					SC9->C9_LOTECTL := cLoteCtl
					SC9->C9_NUMLOTE := cNumLote
					If dDtValid <> nil
						SC9->C9_DTVALID := dDtValid
					EndIf
				EndIf
				If lIntWms
					SC9->C9_BLWMS  := Iif(lWmsLibSC9,"05","01")
				Else
					SC9->C9_BLWMS  := ""
				EndIf
				SC9->C9_ROMEMB := cRomaneio
				SC9->(MsUnlock())
				
				nNewRecno := SC9->(Recno())
				//-- Deve gerar o empenho para a quantidade dividida
				If lGeraEmp
					lRet := WmsAtuSDC("SC6",/*cOp*/,/*cTrt*/,cPedido,cItem, cSeqSC9 ,cProduto,cLoteCtl,cNumLote,cNumSerie,nQtdLib,nQtdLib2UM,cLocal,cEndereco,cIdDCF,1)
				EndIf
			EndIf
		EndIf
		nQuant -= nQtdLib
		(cAliasSC9)->(dbSkip())
	EndDo
	(cAliasSC9)->(dbCloseArea())
	RestArea(aAreaAnt)
Return lRet
/*-----------------------------------------------------------------------------
Tem por objetivo estornar a quantidade liberada no pedido de venda de acordo com
a OS WMS, atualizando informações no SC9 e excluindo o empenho para a SDC.
No estorno sempre vai tentar aglutinar novamente a liberação no SC9
-----------------------------------------------------------------------------*/
Function WmsEstSC9(cCarga,cPedido,cItem,cProduto,cServico,nQuant,nQuant2UM,cLocal,cEndereco,cIdDCF,nTipoRegra,xRegra,lEstEmp)
Local lRet       := .T.
Local lLote      := .F.
Local aAreaAnt   := GetArea()
Local aCopySC9   := {}
Local cWhere     := ""
Local cAliasSC9  := Nil
Local cSeqSC9    := ""
Local cLoteCtl   := ""
Local cNumLote   := ""
Local nQtdLib    := 0
Local nQtdLib2UM := 0
Local nDifLib    := 0
Local nDifLib2UM := 0
Local nQtdLibTot := 0
Local nCnt       := 0
Local dDtValid   := CtoD('  /  /  ')

Default cIdDCF     := ''
Default nQuant2UM  := ConvUM(cProduto, nQuant, 0, 2)
Default nTipoRegra := 3
Default xRegra     := dDtValid
Default lEstEmp    := .T.
	
	dbSelectArea("SC9")
	lLote := Rastro(cProduto)
	// Parâmetro Where
	cWhere := "%"
	If lLote .And. nTipoRegra == 1 .And. !Empty(xRegra)
		cWhere += " AND SC9.C9_LOTECTL = '"+xRegra+"'"
	EndIf
	cWhere += "%"
	cAliasSC9  := GetNextAlias()
	If WmsCarga(cCarga)
		BeginSql Alias cAliasSC9
			SELECT SC9.C9_BLWMS,
					SC9.C9_SEQUEN,
					SC9.R_E_C_N_O_ RECNOSC9
			FROM %Table:SC9% SC9
			WHERE SC9.C9_FILIAL  = %xFilial:SC9%
			AND SC9.C9_CARGA  = %Exp:cCarga%
			AND SC9.C9_PRODUTO = %Exp:cProduto%
			AND SC9.C9_SERVIC = %Exp:cServico%
			AND SC9.C9_IDDCF = %Exp:cIdDCF%
			AND SC9.C9_NFISCAL = '  '
			AND SC9.%NotDel%
			%Exp:cWhere%
			ORDER BY SC9.C9_BLWMS DESC,
						SC9.C9_SEQUEN
		EndSql
	Else
		BeginSql Alias cAliasSC9
			SELECT SC9.C9_BLWMS,
					SC9.C9_SEQUEN,
					SC9.R_E_C_N_O_ RECNOSC9
			FROM %Table:SC9% SC9
			WHERE SC9.C9_FILIAL  = %xFilial:SC9%
			AND C9_PEDIDO = %Exp:cPedido%
			AND C9_ITEM = %Exp:cItem%
			AND SC9.C9_PRODUTO = %Exp:cProduto%
			AND SC9.C9_SERVIC = %Exp:cServico%
			AND SC9.C9_IDDCF = %Exp:cIdDCF%
			AND SC9.C9_NFISCAL = '  '
			AND SC9.%NotDel%
			%Exp:cWhere%
			ORDER BY SC9.C9_BLWMS DESC,
						SC9.C9_SEQUEN
		EndSql
	EndIf
	If (cAliasSC9)->(!Eof())
		Do While lRet .And. (cAliasSC9)->(!Eof()) .And. QtdComp(nQuant) > 0
	
			SC9->(DbGoTo((cAliasSC9)->RECNOSC9)) //-- Posiciona no registro do SC9 correspondente
			RecLock("SC9", .F.)
	
			//-- Quando é por carga, porém a OS é gerada no pedido
			cCarga   := SC9->C9_CARGA
			//-- Pode ser que tenha sido por carga, então não tinha o pedido
			cPedido  := SC9->C9_PEDIDO
			cItem    := SC9->C9_ITEM
			cSeqSC9  := SC9->C9_SEQUEN
			nQtdLib  := SC9->C9_QTDLIB
			cLoteCtl := SC9->C9_LOTECTL
			cNumLote := SC9->C9_NUMLOTE
			dDtValid := SC9->C9_DTVALID
			//-- Joga toda a quantidade liberada deste apanhe na 1a sequencia disponivel do SC9
			If QtdComp(nQtdLib) > QtdComp(nQuant)
				nQtdLib    := nQuant
				nQtdLib2UM := ConvUM(cProduto, nQtdLib, 0, 2)
				nDifLib    := SC9->C9_QTDLIB - nQtdLib
				nDifLib2UM := ConvUM(cProduto, nDifLib, 0, 2)
			Else
				nQtdLib    := Min(nQtdLib,nQuant)
				nQtdLib2UM := ConvUM(cProduto, nQtdLib, 0, 2)
				nDifLib    := 0
				nDifLib2UM := 0
			EndIf
	
			//-- Estorna o empenho gerado para esta sequencia
			If lEstEmp
				lRet := WmsAtuSDC("SC6",/*cOp*/,/*cTrt*/,cPedido,cItem,cSeqSC9,cProduto,cLoteCtl,cNumLote,SC9->C9_NUMSERI,nQtdLib,nQtdLib2UM,cLocal,cEndereco,cIdDCF,1,.T.)
			EndIf
			
			If lRet
				cLoteCtl := Iif((nTipoRegra == 1 .And. !Empty(xRegra)),cLoteCtl,Space(Len(SC9->C9_LOTECTL)))
				cNumLote := Iif((nTipoRegra == 1 .And. !Empty(xRegra)),cNumLote,Space(Len(SC9->C9_NUMLOTE)))
				dDtValid := Iif((nTipoRegra == 1 .And. !Empty(xRegra)),dDtValid,CtoD('  /  /  '))
				//-- Aglutina itens da nota fiscal de saida com mesmo Lote e Sub-Lote
				If cSeqSC9 != "01" .And.;
				WmsAgluSC9(cCarga,cPedido,cItem,cProduto,cLoteCtl,cNumLote,Nil,nQtdLib,nQtdLib2UM,cLocal,cEndereco,cIdDCF,.F.,.F.)
					//-- Deve diminuir a quantidade da SC9 atual apenas
					SC9->C9_QTDLIB  -= nQtdLib
					SC9->C9_QTDLIB2 -= nQtdLib2UM
					If QtdComp(SC9->C9_QTDLIB) <= 0
						SC9->(DbDelete())
					EndIf
					SC9->(MsUnlock())
				Else
					//-- Guarda o conteudo dos campos do SC9 em uma variavel
					If QtdComp(nDifLib) > 0
						For nCnt := 1 To SC9->(FCount())
							AAdd(aCopySC9, SC9->(FieldGet(nCnt)))
						Next nCnt
					EndIf
					SC9->C9_BLWMS   := '01'
					SC9->C9_LOTECTL := cLoteCtl
					SC9->C9_NUMLOTE := cNumLote
					SC9->C9_DTVALID := dDtValid
					SC9->(MsUnlock())
					//-- Se restou quantidade a ser liberada
					If QtdComp(nDifLib) > 0
						//-- Pega a sequencia máxima da SC9
						cSeqSC9 := MaxSeqSC9(cPedido,cItem,cProduto)
						RecLock("SC9", .T.)
						For nCnt := 1 To Len(aCopySC9)
							FieldPut(nCnt, aCopySC9[nCnt])
						Next nCnt
						SC9->C9_SEQUEN  := Soma1(cSeqSC9,Len(SC9->C9_SEQUEN))
						SC9->C9_QTDLIB  := nDifLib
						SC9->C9_QTDLIB2 := nDifLib2UM
						SC9->(MsUnlock())
					EndIf
				EndIf
				//-- Diminui da quantidade total a quantidade liberada
				nQuant -= nQtdLib
				nQtdLibTot += nQtdLib
			EndIf
			(cAliasSC9)->(DbSkip())
		EndDo
	Else
		lRet := .F.
	EndIf
	(cAliasSC9)->(DbCloseArea())
	RestArea(aAreaAnt)
Return lRet
/*-----------------------------------------------------------------------------
Pega qual é máxima sequencia de um item do pedido liberado SC9
-----------------------------------------------------------------------------*/
Static Function MaxSeqSC9(cPedido,cItem,cProduto)
Local aAreaAnt  := GetArea()
Local cAliasSeq := GetNextAlias()
Local cSeqSC9   := "01"

	BeginSql Alias cAliasSeq
		SELECT MAX(SC9.C9_SEQUEN) MAXSC9SEQ
		FROM %Table:SC9% SC9
		WHERE SC9.C9_FILIAL = %xFilial:SC9%
		AND SC9.C9_PEDIDO = %Exp:cPedido%
		AND SC9.C9_ITEM = %Exp:cItem%
		AND SC9.C9_PRODUTO = %Exp:cProduto%
		AND SC9.%NotDel%
	EndSql
	If (cAliasSeq)->(!Eof())
		cSeqSC9 := (cAliasSeq)->MAXSC9SEQ
	EndIf
	(cAliasSeq)->(DbCloseArea())
	RestArea(aAreaAnt)
Return cSeqSC9
/*-----------------------------------------------------------------------------
Tem por objetivo aglutinar as quantidades liberadas de um pedido de venda de
acordo com as liberações do WMS, pois o WMS pode fazer várias liberações conforme
a norma do produto, isto geraria vários itens na nota fiscal de saída.
A aglutinação é justamente para sumarizar estes itens na nota fiscal de saída.
-----------------------------------------------------------------------------*/
Function WmsAgluSC9(cCarga,cPedido,cItem,cProduto,cLoteCtl,cNumLote,cNumSerie,nQuant,nQuant2UM,cLocal,cEndereco,cIdDCF,lWmsLibSC9,lGeraEmp,cSeqSC9,lDesSeqSC9)
Local lRet      := .F.
Local aAreaAnt  := GetArea()
Local aAreaSC9  := SC9->(GetArea())
Local aAreaSDC  := SDC->(GetArea())
Local cAliasSC9 := GetNextAlias()
Local cWhere    := ""
Local cLibSC9   := ""

Default cNumSerie  := Space(Len(SC9->C9_NUMSERI))
Default cIdDCF     := ""
Default cSeqSC9    := ""
Default nQuant2UM  := ConvUM(cProduto, nQuant, 0, 2)
Default lWmsLibSC9 := .T.
Default lGeraEmp   := .T.
Default lDesSeqSC9 := .F.  //Indica se deve desconsiderar da query a sequência de SC9 passada por parâmetro
	// Parâmetro Where
	cWhere := "%"
	If !Empty(cSeqSC9)
		If lDesSeqSC9
			cWhere += " AND SC9.C9_SEQUEN <> '"+cSeqSC9+"'"
		Else
			cWhere += " AND SC9.C9_SEQUEN < '"+cSeqSC9+"'"
		EndIf
	EndIf
	cWhere += "%"
	cLibSC9 := Iif(lWmsLibSC9,"05","01")
	BeginSql Alias cAliasSC9
		SELECT SC9.C9_SEQUEN,
				SC9.R_E_C_N_O_ RECNOSC9
		FROM %Table:SC9% SC9
		WHERE SC9.C9_FILIAL = %xFilial:SC9%
		AND SC9.C9_CARGA = %Exp:cCarga%
		AND SC9.C9_PEDIDO = %Exp:cPedido%
		AND SC9.C9_ITEM = %Exp:cItem%
		AND SC9.C9_PRODUTO = %Exp:cProduto%
		AND SC9.C9_LOTECTL = %Exp:cLoteCtl%
		AND SC9.C9_NUMLOTE = %Exp:cNumLote%
		AND SC9.C9_IDDCF = %Exp:cIdDCF%
		AND SC9.C9_BLWMS = %Exp:cLibSC9%
		AND SC9.C9_NFISCAL = '  '
		AND SC9.%NotDel%
		%Exp:cWhere%
		ORDER BY C9_SEQUEN
	EndSql
	If (cAliasSC9)->(!Eof())
		//Conseguiu achar um registro na SC9 compativel, apenas soma a quantidade ao mesmo
		//-- Efetua o Travamento nos Registros do SC9
		SC9->(DbGoTo((cAliasSC9)->RECNOSC9))
		RecLock("SC9", .F.)
		cSeqSC9 := (cAliasSC9)->C9_SEQUEN
		SC9->C9_QTDLIB  += nQuant
		SC9->C9_QTDLIB2 += nQuant2UM
		If !lWmsLibSC9
			If !Empty(SC9->C9_ROMEMB)
				SC9->C9_ROMEMB := PadR("",  TamSx3("C9_ROMEMB")[1])
			EndIf
		EndIf
		SC9->(MsUnlock())
		lRet := .T.
		//-- Deve gerar o empenho para a quantidade liberada
		If lGeraEmp
			lRet := WmsAtuSDC("SC6",/*cOp*/,/*cTrt*/,cPedido,cItem,cSeqSC9,cProduto,cLoteCtl,cNumLote,cNumSerie,nQuant,nQuant2UM,cLocal,cEndereco,cIdDCF,1)
		EndIf
	EndIf
	(cAliasSC9)->(DbCloseArea())

	RestArea(aAreaSDC)
	RestArea(aAreaSC9)
	RestArea(aAreaAnt)
Return lRet

/*-----------------------------------------------------------------------------
Tem por objetivo atualizar a quantidade empenhada a partir de um pedido
de venda ou a partir de uma ordem de produção, dependendo do índice passado.
Pode também efetuar o estorno de um registro na SDC caso seja solicitado
-----------------------------------------------------------------------------*/
Function WmsAtuSDC(cOrigem,cOp,cTrt,cPedido,cItem,cSeqSC9,cProduto,cLoteCtl,cNumLote,cNumSerie,nQuant,nQuant2UM,cLocal,cEndereco,cIdDCF,nIndex,lEstorno)
Local lRet       := .T.
Local lCriaSDC   := .T.
Local lWmsNew    := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local aAreaAnt   := GetArea()
Local cAliasSDC  := GetNextAlias()
Local nQtdOri    := 0

Default nQuant2UM := ConvUM(cProduto, nQuant, 0, 2)
Default cOp       := CriaVar('DC_OP'     , .F.)
Default cTrt      := CriaVar('DC_TRT'    , .F.)
Default cPedido   := CriaVar('DC_PEDIDO' , .F.)
Default cItem     := CriaVar('DC_ITEM'   , .F.)
Default cSeqSC9   := CriaVar('DC_SEQ'    , .F.)
Default nIndex    := 1
Default lEstorno  := .F.

	DbSelectArea("SDC")
	
	If nIndex == 2
		BeginSql Alias cAliasSDC
			SELECT SDC.R_E_C_N_O_ RECNOSDC
			FROM %Table:SDC% SDC
			WHERE SDC.DC_FILIAL = %xFilial:SDC%
			AND SDC.DC_PRODUTO = %Exp:cProduto%
			AND SDC.DC_LOCAL = %Exp:cLocal%
			AND SDC.DC_OP = %Exp:cOp%
			AND SDC.DC_TRT = %Exp:cTrt%
			AND SDC.DC_LOTECTL = %Exp:cLoteCtl%
			AND SDC.DC_NUMLOTE = %Exp:cNumLote%
			AND SDC.DC_LOCALIZ = %Exp:cEndereco%
			AND SDC.DC_NUMSERI = %Exp:cNumSerie%
			AND SDC.%NotDel%
		EndSql
	Else
		BeginSql Alias cAliasSDC
			SELECT SDC.R_E_C_N_O_ RECNOSDC
			FROM %Table:SDC% SDC
			WHERE SDC.DC_FILIAL = %xFilial:SDC%
			AND SDC.DC_PRODUTO = %Exp:cProduto%
			AND SDC.DC_LOCAL = %Exp:cLocal%
			AND SDC.DC_ORIGEM = %Exp:cOrigem%
			AND SDC.DC_PEDIDO = %Exp:cPedido%
			AND SDC.DC_ITEM = %Exp:cItem%
			AND SDC.DC_SEQ = %Exp:cSeqSC9%
			AND SDC.DC_LOTECTL = %Exp:cLoteCtl%
			AND SDC.DC_NUMLOTE = %Exp:cNumLote%
			AND SDC.DC_LOCALIZ = %Exp:cEndereco%
			AND SDC.DC_NUMSERI = %Exp:cNumSerie%
			AND SDC.%NotDel%
		EndSql
	EndIf
	If (cAliasSDC)->(!Eof())
		SDC->(dbGoTo((cAliasSDC)->RECNOSDC))
		If !lEstorno
			RecLock("SDC", .F.)
			SDC->DC_QUANT   += nQuant
			SDC->DC_QTSEGUM += nQuant2UM
			SDC->(MsUnlock())
			lCriaSDC := .F.
		Else
			lCriaSDC := .T.
		EndIf
		If !lWmsNew
			//-- Atualiza o empenho nas outras tabelas (SBF,SB8)
			GravaEmp(cProduto,cLocal,nQuant,nQuant2UM,cLoteCtl,cNumLote,cEndereco,cNumSerie,cOp,Iif(nIndex==1,cSeqSC9,cTrt),cPedido,cItem,cOrigem,/*cOpOrig*/,/*dEntrega*/,/*aTravas*/,lEstorno,.F.,.F.,IIf(lEstorno .AND. nIndex == 2,.T.,.F.),.T.,.T.,lCriaSDC,.F.,cIdDCF,/*aSalvCols*/,/*nSG1*/,/*lOpEncer*/,/*cTpOp*/,/*cCAT83*/)
		Else 
			If lEstorno
				RecLock("SDC", .F.)
				If SDC->DC_QUANT - nQuant > 0
					SDC->DC_QUANT   -= nQuant
					SDC->DC_QTSEGUM -= nQuant2UM
				Else
					SDC->(dbDelete())
				EndIf
				SDC->(MsUnlock())
			EndIf
		EndIf
	Else //-- Deve criar um novo registro de SDC
		If !lEstorno
			If !lWmsNew
				GravaEmp(cProduto,cLocal,nQuant,nQuant2UM,cLoteCtl,cNumLote,cEndereco,cNumSerie,cOp,Iif(nIndex==1,cSeqSC9,cTrt),cPedido,cItem,cOrigem,/*cOpOrig*/,/*dEntrega*/,/*aTravas*/,.F.,.F.,.F.,.F.,.T.,.T.,/*lCriaSDC*/.T.,.F.,cIdDCF,/*aSalvCols*/,/*nSG1*/,/*lOpEncer*/,/*cTpOp*/,/*cCAT83*/)
			Else
				nQtdOri := Iif(cOrigem=="SC6",Posicione("DCF",9,xFilial("DCF") + cIdDCF ,"DCF_QUANT"),nQuant)
				Reclock("SDC",.T.)
				SDC->DC_FILIAL   := xFilial("SDC")
				SDC->DC_ORIGEM   := cOrigem
				SDC->DC_PRODUTO  := cProduto
				SDC->DC_LOCAL    := cLocal
				SDC->DC_LOTECTL  := cLoteCtl
				SDC->DC_NUMLOTE  := cNumLote
				SDC->DC_LOCALIZ  := cEndereco
				SDC->DC_NUMSERI  := cNumSerie
				SDC->DC_QTDORIG  := nQtdOri
				SDC->DC_QUANT    := nQuant
				SDC->DC_QTSEGUM  := nQuant2UM
				SDC->DC_PEDIDO   := cPedido
				SDC->DC_ITEM     := cItem
				SDC->DC_OP       := cOp
				SDC->DC_TRT      := Iif(nIndex==1,cSeqSC9,cTrt)
				SDC->DC_SEQ      := Iif(nIndex==1,cSeqSC9,cTrt)
				SDC->DC_IDDCF    := cIdDCF
				SDC->(MsUnlock())
			EndIf
		EndIf
	EndIf
	(cAliasSDC)->(dbCloseArea())
	RestArea(aAreaAnt)
Return lRet
/*-----------------------------------------------------------------------------
Tem por objetivo gerar o empenho para a SDC com base na requisicao empenhada (SD4)
da ordem de produto (SC2)
-----------------------------------------------------------------------------*/
Function WmsAtuSD4(cLocal,cProduto,cLoteCtl,cNumLote,cNumSerie,cEndereco,nQuant,cIdDCF,lEstorno,lMantLote)
Local lRet        := .T.
Local lWmsNew     := SuperGetMv("MV_WMSNEW",.F.,.F.)
Local lHasSDC     := .F.
Local lOk         := .F.
Local lRastro     := .F.
Local aAreaSDC    := {}
Local cAliasSD4   := Nil
Local cAliasQry   := Nil
Local cOp         := ""
Local cTrt        := ""
Local cTrtSD4     := ""
Local cPrdPai     := ""
Local cRoteiro
Local cLoteCtlAnt := ""
Local cNumLoteAnt := ""
Local nQtdReq     := 0
Local nQtdEmp     := 0
Local nQtdSDC     := 0
Local nQtdSDC2UM  := 0
Local dDataOp     := ""
Local dDtValid    := CtoD('  /  /  ')
Default cNumSerie := ""
Default lMantLote := .F.

	If Empty(cIdDCF) .OR. QtdComp(nQuant) == QtdComp(0) .OR. Empty(cEndereco)
		Return .F.
	EndIf
	cAliasSD4  := GetNextAlias()
	BeginSql Alias cAliasSD4
		SELECT SD4.R_E_C_N_O_ RECNOSD4
		FROM %Table:SD4% SD4
		WHERE SD4.D4_FILIAL  = %xFilial:SD4%
		AND SD4.D4_LOCAL = %Exp:cLocal%
		AND SD4.D4_COD = %Exp:cProduto%
		AND (SD4.D4_LOTECTL = '  '
			OR SD4.D4_LOTECTL = %Exp:cLoteCtl% )
		AND (SD4.D4_NUMLOTE = '  '
			OR SD4.D4_NUMLOTE = %Exp:cNumLote% )
		AND SD4.D4_IDDCF = %Exp:cIdDCF%
		AND SD4.D4_QTDEORI > 0
		AND SD4.%NotDel%
	EndSql
	Do While lRet .And. (cAliasSD4)->(!Eof()) .And. QtdComp(nQuant) > 0
		dbSelectArea("SD4")
		SD4->(dbGoTo((cAliasSD4)->RECNOSD4))
		//
		cOp         := PadR(SD4->D4_OP, Len(SD4->D4_OP))
		cTrt        := PadR(SD4->D4_TRT, Len(SD4->D4_TRT))
		cPrdPai     := PadR(SD4->D4_PRODUTO,Len(SD4->D4_PRODUTO))
		cRoteiro    := PadR(SD4->D4_ROTEIRO,Len(SD4->D4_ROTEIRO))
		cLoteCtlAnt := PadR(IIf(lMantLote,SD4->D4_LOTECTL,""),Len(SD4->D4_LOTECTL))
		cNumLoteAnt := PadR(IIf(lMantLote,SD4->D4_NUMLOTE,""),Len(SD4->D4_NUMLOTE))
		// Carrega data validade
		If lMantLote
			DbSelectArea('SB8')
			SB8->(DbSetOrder(3)) //B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL+B8_NUMLOTE+DTOS(B8_DTVALID)
			If SB8->(DbSeek(xFilial('SB8')+cProduto+cLocal+cLoteCtl+cNumLote))
				dDtValid := SB8->B8_DTVALID
			EndIf
		Else
			dDtValid    := CtoD('  /  /  ')
		EndIf
		lOk         := .F.
		lRastro     := Rastro(cProduto)

		aAreaSDC   := SDC->(GetArea())
		//Busca quantidade ja empenhada para a op
		nQtdEmp := 0
		nQtdReq := SD4->D4_QUANT
		
		cAliasSDC := GetNextAlias()
		BeginSql Alias cAliasSDC
			SELECT SDC.DC_QUANT
			FROM %Table:SDC% SDC
			WHERE SDC.DC_FILIAL = %xFilial:SDC%
			AND SDC.DC_PRODUTO = %Exp:cProduto% 
			AND SDC.DC_LOCAL = %Exp:cLocal%
			AND SDC.DC_OP = %Exp:cOp%
			AND SDC.DC_TRT = %Exp:cTrt%
			AND SDC.DC_LOTECTL = %Exp:cLoteCtl%
			AND SDC.DC_NUMLOTE = %Exp:cNumLote%
			AND SDC.DC_LOCALIZ = %Exp:cEndereco%
			AND SDC.DC_NUMSERI = %Exp:cNumSerie%
			AND SDC.%NotDel%
		EndSql
		If (cAliasSDC)->(!Eof())
			lHasSDC := .T.
			nQtdEmp := (cAliasSDC)->DC_QUANT
		EndIf
		(cAliasSDC)->(dbCloseArea())
		//Empenho SC2 - Tratamento do endereço
		If !lEstorno
			If QtdComp(nQtdEmp) != QtdComp(nQtdReq)
				If QtdComp(nQtdEmp + nQuant) <= QtdComp(nQtdReq)
					nQtdSDC    := nQuant
					nQtdSDC2UM := ConvUM(cProduto, nQtdSDC, 0, 2)
					//-- Deve gerar o empenho para a quantidade liberada
				Else
					nQtdSDC    := QtdComp(nQtdReq-nQtdEmp)
					nQtdSDC2UM := ConvUM(cProduto, nQtdSDC, 0, 2)
				EndIf
				lOk := .T.
			EndIf
		Else
			If lHasSDC
				If QtdComp(nQtdEmp) > QtdComp(0)
					If QtdComp(nQtdEmp) >= QtdComp(nQuant)
						nQtdSDC    := nQuant
						nQtdSDC2UM := ConvUM(cProduto, nQtdSDC, 0, 2)
					Else
						nQtdSDC    := QtdComp(nQtdEmp)
						nQtdSDC2UM := ConvUM(cProduto, nQtdSDC, 0, 2)
					EndIf
					lOk := .T.
				EndIf
			ElseIf lWmsNew
				nQtdEmp    := nQuant
				nQtdSDC    := nQuant
				nQtdSDC2UM := ConvUM(cProduto, nQtdSDC, 0, 2)
				lOk := .T.
			EndIf
		EndIf
		//Grava Empenho
		If lOk
			lRet := WmsAtuSDC("SC2",cOp,cTrt,/*cPedido*/,/*cItem*/,/*cSeqSC9*/,cProduto,cLoteCtl,cNumLote,cNumSerie,nQtdSDC,nQtdSDC2UM,cLocal,cEndereco,cIdDCF,2,lEstorno)
			dDataOp := SD4->D4_DATA

			If Rastro(cProduto)
				If !lEstorno
					//Atualiza registro corrente para quantidade lida no coletor
					dbSelectArea("SD4")
					cAliasQry := GetNextAlias()
					BeginSql Alias cAliasQry
						SELECT SD4.D4_QUANT
						FROM %Table:SD4% SD4
						WHERE SD4.D4_FILIAL  = %xFilial:SD4%
						AND SD4.D4_COD = %Exp:cProduto%
						AND SD4.D4_OP = %Exp:cOp%
						AND SD4.D4_TRT = %Exp:cTrt%
						AND SD4.D4_LOTECTL = %Exp:cLoteCtl%
						AND SD4.D4_NUMLOTE = %Exp:cNumLote%
						AND SD4.%NotDel%
					EndSql
					If (cAliasQry)->(!Eof())
						nQtdSDC += SD4->D4_QUANT
					Else
						SD4->(dbGoTo((cAliasSD4)->RECNOSD4))
					EndIf
					(cAliasQry)->(dbCloseArea())
					
					RecLock("SD4", .F.)
					SD4->D4_LOTECTL := cLoteCtl
					SD4->D4_NUMLOTE := cNumLote
					SD4->D4_DTVALID := dDtValid
					SD4->D4_QUANT   := nQtdSDC
					SD4->D4_QTSEGUM := ConvUM(cProduto, SD4->D4_QUANT, 0, 2)
					SD4->D4_QTDEORI := SD4->D4_QUANT
					SD4->(MsUnlock())

					//Cria novo registro enquanto houver saldo
					If QtdComp(nQtdEmp+nQuant) < QtdComp(nQtdReq)
						dbSelectArea("SD4")
						cAliasQry := GetNextAlias()
						BeginSql Alias cAliasQry
							SELECT SD4.R_E_C_N_O_ RECNOSD4
							FROM %Table:SD4% SD4
							WHERE SD4.D4_FILIAL  = %xFilial:SD4%
							AND SD4.D4_COD = %Exp:cProduto%
							AND SD4.D4_OP = %Exp:cOp%
							AND SD4.D4_TRT = %Exp:cTrt%
							AND SD4.D4_LOTECTL = %Exp:cLoteCtlAnt%
							AND SD4.D4_NUMLOTE = %Exp:cNumLoteAnt%
							AND SD4.%NotDel%
						EndSql
						If (cAliasQry)->(!Eof())
							SD4->(dbGoTo((cAliasQry)->RECNOSD4))
							RecLock("SD4", .F.)
						Else
							RecLock("SD4", .T.)
						EndIf
						//-- Pega a sequencia máxima da SD4
						cTrtSD4 := WMaxTrtSD4(cOp,cProduto)
						cTrtSD4 := Soma1(cTrtSD4)
						
						SD4->D4_FILIAL  := xFilial("SD4")
						SD4->D4_COD     := cProduto
						SD4->D4_LOCAL   := cLocal
						SD4->D4_OP      := cOp
						SD4->D4_TRT     := cTrtSD4
						SD4->D4_LOTECTL := cLoteCtlAnt
						SD4->D4_NUMLOTE := cNumLoteAnt
						SD4->D4_DTVALID := dDtValid
						SD4->D4_DATA    := dDataOp
						SD4->D4_QUANT   := QtdComp(nQtdReq -(nQtdEmp+nQuant))
						SD4->D4_QTSEGUM := ConvUM(cProduto, SD4->D4_QUANT, 0, 2)
						SD4->D4_QTDEORI := SD4->D4_QUANT
						SD4->D4_PRODUTO := cPrdPai
						SD4->D4_ROTEIRO := cRoteiro
						SD4->D4_IDDCF   := cIdDCF
						SD4->(MsUnlock())

						(cAliasQry)->(dbCloseArea)
					EndIf
				Else
					//Atualiza registro corrente para quantidade lida no coletor
					RecLock("SD4", .F.)
					If QtdComp(SD4->D4_QUANT - nQtdSDC ) == QtdComp(0)
						SD4->( dbDelete())
					Else
						SD4->D4_LOTECTL := cLoteCtl
						SD4->D4_NUMLOTE := cNumLote
						SD4->D4_DTVALID := dDtValid
						SD4->D4_QUANT   -= nQtdSDC
						SD4->D4_QTSEGUM := ConvUM(cProduto, SD4->D4_QUANT, 0, 2)
						SD4->D4_QTDEORI := SD4->D4_QUANT
					EndIf
					SD4->(MsUnlock())
					//Cria novo registro enquanto houver saldo
					If QtdComp(nQtdEmp-nQuant) < QtdComp(nQtdReq)
						dbSelectArea("SD4")
						cAliasQry := GetNextAlias()
						BeginSql Alias cAliasQry
							SELECT SD4.R_E_C_N_O_ RECNOSD4
							FROM %Table:SD4% SD4
							WHERE SD4.D4_FILIAL  = %xFilial:SD4%
							AND SD4.D4_COD = %Exp:cProduto%
							AND SD4.D4_OP = %Exp:cOp%
							AND SD4.D4_TRT = %Exp:cTrt%
							AND SD4.D4_LOTECTL = %Exp:cLoteCtlAnt%
							AND SD4.D4_NUMLOTE = %Exp:cNumLoteAnt%
							AND SD4.%NotDel%
						EndSql
						If (cAliasQry)->(!Eof())
							SD4->(dbGoTo((cAliasQry)->RECNOSD4))
							RecLock("SD4", .F.)
						Else
							RecLock("SD4", .T.)
						EndIf
						SD4->D4_FILIAL  := xFilial("SD4")
						SD4->D4_COD     := cProduto
						SD4->D4_LOCAL   := cLocal
						SD4->D4_OP      := cOp
						SD4->D4_TRT     := cTrt
						SD4->D4_LOTECTL := cLoteCtlAnt
						SD4->D4_NUMLOTE := cNumLoteAnt
						SD4->D4_DTVALID := dDtValid
						SD4->D4_DATA    := dDataOp
						SD4->D4_QUANT   += nQuant
						SD4->D4_QTSEGUM := ConvUM(cProduto, SD4->D4_QUANT, 0, 2)
						SD4->D4_QTDEORI := SD4->D4_QUANT
						SD4->D4_PRODUTO := cPrdPai
						SD4->D4_ROTEIRO := cRoteiro
						SD4->D4_IDDCF   := cIdDCF
						SD4->(MsUnlock())
						
						(cAliasQry)->(dbCloseArea())
					EndIf
				EndIf
			EndIf
			nQuant -= nQtdSDC
		EndIf
		RestArea(aAreaSDC)
		(cAliasSD4)->(dbSkip())
	EndDo
	(cAliasSD4)->(dbCloseArea())
Return lRet
/*-----------------------------------------------------------------------------
Tem por objetivo avaliar se o registro da SC9 pode ser estornado.
Avalia se não foi executado a ordem de serviço ou se foi executado, se os
movimentos de separação não foram executados.
Se a ordem de serviço já foi executada, somente permite estornar se a execução
do serviço é automática, caso contrário deverá ser estornado manual antes no WMS
A tabela SC9 deve pode estar posicionada para efetuar a validação
-----------------------------------------------------------------------------*/
Function WmsAvalSC9(cAcao,cPedido,cItem,cSeqSC9,cProduto)
Local lRet       := .T.
Local aAreaAnt   := GetArea()
Local aAreaSC5   := SC5->(GetArea())
Local aAreaSC9   := SC9->(GetArea())
Local cCarga     := ""
Local cMensagem  := ""
Local cAliasSC9  := Nil
Local cAliasSC5  := Nil

Default cAcao    := "1"
Default cPedido  := ""
Default cItem    := ""
Default cSeqSC9  := ""
Default cProduto := ""

	If !Empty(cPedido+cItem+cSeqSC9+cProduto)
		cAliasSC9 := GetNextAlias()
		BeginSql Alias cAliasSC9
			SELECT SC9.R_E_C_N_O_ RECNOSC9
			FROM %Table:SC9% SC9
			WHERE SC9.C9_FILIAL = %xFilial:SC9% 
			AND SC9.C9_PEDIDO = %Exp:cPedido%
			AND SC9.C9_ITEM = %Exp:cItem%
			AND SC9.C9_SEQUEN = %Exp:cSeqSC9%
			AND SC9.C9_PRODUTO = %Exp:cProduto%
			AND SC9.%NotDel%
		EndSql
		If (cAliasSC9)->(!Eof())
			SC9->(dbGoTo((cAliasSC9)->RECNOSC9))
		Else
			lRet := .F.
		EndIf
		(cAliasSC9)->(dbCloseArea())
	EndIf
	If cAcao == "1"
		//-- Verifica se o pedido gera OS na carga, caso contrário não considera a carga
		cCarga := SC9->C9_CARGA
		If !Empty(cCarga)
			cAliasSC5 := GetNextAlias()
			BeginSql Alias cAliasSC5
				SELECT SC5.C5_GERAWMS
				FROM %Table:SC5% SC5
				WHERE SC5.C5_FILIAL = %xFilial:SC5%
				AND SC5.C5_NUM = %Exp:SC9->C9_PEDIDO%
				AND SC5.C5_GERAWMS = '1'
				AND SC5.%NotDel%
			EndSql
			If (cAliasSC5)->(!Eof()) .And. (cAliasSC5)->C5_GERAWMS == "1"
				cCarga := "" //Limpa a carga, pois a OS foi gerada no pedido
			EndIf
			(cAliasSC5)->(dbCloseArea())
		EndIf
		//Somente valida se tiver a informação de DCF na tabela 
		If !Empty(SC9->C9_IDDCF)
			//-- Verifica se a ordem de serviço foi executada
			If WmsChkDCF("SC9",cCarga,,SC9->C9_SERVIC,/*Status*/"3",,SC9->C9_PEDIDO,SC9->C9_ITEM,SC9->C9_CLIENTE,SC9->C9_LOJA,SC9->C9_LOCAL,SC9->C9_PRODUTO,SC9->C9_LOTECTL,SC9->C9_NUMLOTE,/*NumSeq*/,SC9->C9_IDDCF)
				//Se já tem algo faturado, deve checar se tudo desta OS está finalizado
				//Se o pedido já está liberado pelo WMS, libera o mesmo para estorno
				If !Empty(SC9->C9_NFISCAL)
					If WmsChkSDB('1',,,"('2','3','4')")
						cMensagem := WmsFmtMsg(STR0004,{{"[VAR01]",AllTrim(DCF->DCF_DOCTO)+Iif(!Empty(DCF->DCF_SERIE),"/"+AllTrim(DCF->DCF_SERIE),"")},{"[VAR02]",AllTrim(DCF->DCF_CODPRO)}}) + CLRF // "SIGAWMS - OS [VAR01] - Produto: [VAR02]"
						cMensagem += STR0005+CLRF //"Existem atividades em andamento ou pendentes para esta"
						cMensagem += STR0006+CLRF //"ordem de serviço pelo processo WMS."
						cMensagem += STR0007 //"Deverá ser finalizado o processo WMS primeiro."
						WmsMessage(cMensagem,"WmsAvalSC9")
						lRet := .F.
					Else
						//Apaga o campo serviço e IDDCF deste item da SC9, para não estornar a OS
						RecLock('SC9',.F.)
						SC9->C9_IDDCF  := ""
						SC9->C9_STSERV := ""
						SC9->C9_SERVIC := ""
						MsUnlock()
					EndIf
				Else
					If lMntVol .And. WmsChkVol(SC9->C9_CARGA,SC9->C9_PEDIDO,SC9->C9_PRODUTO,SC9->C9_LOTECTL,SC9->C9_NUMLOTE)
						cMensagem := WmsFmtMsg(STR0004,{{"[VAR01]",AllTrim(DCF->DCF_DOCTO)+Iif(!Empty(DCF->DCF_SERIE),"/"+AllTrim(DCF->DCF_SERIE),"")},{"[VAR02]",AllTrim(DCF->DCF_CODPRO)}}) + CLRF // "SIGAWMS - OS [VAR01] - Produto: [VAR02]"
						cMensagem += STR0008+CRLF // "Existem volumes montados para esta ordem de serviço."
						cMensagem += STR0009 // "Os volumes deverão ser estornados manualmente."
						WmsMessage(cMensagem,"WmsAvalSC9")
						lRet := .F.
					ElseIf WmsChkConf(SC9->C9_CARGA,SC9->C9_PEDIDO,SC9->C9_PRODUTO,SC9->C9_LOTECTL,SC9->C9_NUMLOTE,SC9->C9_SERVIC)
						cMensagem := WmsFmtMsg(STR0004,{{"[VAR01]",AllTrim(DCF->DCF_DOCTO)+Iif(!Empty(DCF->DCF_SERIE),"/"+AllTrim(DCF->DCF_SERIE),"")},{"[VAR02]",AllTrim(DCF->DCF_CODPRO)}}) + CLRF // "SIGAWMS - OS [VAR01] - Produto: [VAR02]"
						cMensagem += STR0010+CRLF // "A conferência de expedição desta ordem de serviço já foi iniciada."
						cMensagem += STR0011 // "A conferência deverá ser estornada manualmente."
						WmsMessage(cMensagem,"WmsAvalSC9")
						lRet := .F.
					Else
						lRet := WmsAvalDCF("2")
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf	
	RestArea(aAreaSC9)
	RestArea(aAreaSC5)
	RestArea(aAreaAnt)
Return lRet

/*-----------------------------------------------------------------------------
Tem por objetivo estornar a quantidade liberada no pedido de venda de acordo com
a liberação do volume, atualizando informações no SC9 e excluindo o empenho para 
a SDC. No estorno sempre vai tentar aglutinar novamente a liberação no SC9
-----------------------------------------------------------------------------*/
Function WmsEstVC9(cPedido,cItem,cSeqSC9,cProduto,nQuant,nQuant2UM,lGeraEmp,cSequen)
Local lRet      := .T.
Local lWmsNew   := SuperGetMv("MV_WMSNEW",.F.,.F.)
Local lWmsAglu  := SuperGetMV('MV_WMSAGLU',.F.,.F.) .Or. lWmsNew // Aglutina itens da nota fiscal de saida com mesmo Lote e Sub-Lote
Local aAreaAnt  := GetArea()
Local cAliasSC9 := GetNextAlias()

Default nQuant2UM := ConvUM(cProduto, nQuant, 0, 2)
Default lGeraEmp  := .T.
Default cSequen   := cSeqSC9

	BeginSql Alias cAliasSC9
		SELECT SC9.R_E_C_N_O_ RECNOSC9
		FROM %Table:SC9% SC9
		WHERE SC9.C9_FILIAL = %xFilial:SC9% 
		AND SC9.C9_PEDIDO = %Exp:cPedido%
		AND SC9.C9_ITEM = %Exp:cItem%
		AND SC9.C9_SEQUEN = %Exp:cSeqSC9%
		AND SC9.C9_PRODUTO = %Exp:cProduto%
		AND SC9.%NotDel%
	EndSql
	If (cAliasSC9)->(!Eof())
		SC9->(dbGoTo((cAliasSC9)->RECNOSC9))
		// Aglutina itens da nota fiscal de saida com mesmo Lote e Sub-Lote
		If lWmsAglu .And. cSeqSC9 != "01" .And.;
			WmsAgluSC9(SC9->C9_CARGA,cPedido,cItem,cProduto,SC9->C9_LOTECTL,SC9->C9_NUMLOTE,Nil,nQuant,nQuant2UM,SC9->C9_LOCAL,SC9->C9_ENDPAD,SC9->C9_IDDCF,.F.,lGeraEmp,@cSequen)
			// Deve diminuir a quantidade da SC9 atual apenas
			RecLock("SC9", .F.)
			SC9->C9_QTDLIB  -= nQuant
			SC9->C9_QTDLIB2 -= nQuant2UM
			If QtdComp(SC9->C9_QTDLIB) <= 0
				SC9->(DbDelete())
			EndIf
			SC9->(MsUnlock())
			// Estorna o empenho gerado para esta sequencia
			If lGeraEmp
				lRet := WmsAtuSDC("SC6",/*cOp*/,/*cTrt*/,cPedido,cItem,cSeqSC9,cProduto,SC9->C9_LOTECTL,SC9->C9_NUMLOTE,SC9->C9_NUMSERI,nQuant,nQuant2UM,SC9->C9_LOCAL,SC9->C9_ENDPAD,SC9->C9_IDDCF,1,.T.)
			EndIf
		Else
			// Se for estorno de volume ou item do volume, pode ser que corresponda apenas a
			// uma fração da quantidade liberada na SC9 e, portanto, deve dividir e bloquear
			// apenas a quantidade estornada, mantendo o restante liberado.
			// Obs.: A função WmsDivSC9() já está preparada para realizar o bloqueio total
			// do registro caso a quantidade a estornar seja igual a quantidade liberada.
			lRet := WmsDivSC9(SC9->C9_CARGA,SC9->C9_PEDIDO,SC9->C9_ITEM,SC9->C9_PRODUTO,SC9->C9_SERVIC,SC9->C9_LOTECTL,SC9->C9_NUMLOTE,SC9->C9_NUMSERI,nQuant,,SC9->C9_LOCAL,SC9->C9_ENDPAD,SC9->C9_IDDCF,.F.,,,SC9->(Recno()))
		EndIf
	EndIf
	(cAliasSC9)->(dbCloseArea())
	RestArea(aAreaAnt)
Return lRet
/*-----------------------------------------------------------------------------
Tem por objetivo integrar com o WMS as liberações de pedidos de venda
-----------------------------------------------------------------------------*/
Function WmsIntPed(nRecnoSC9)
Local lRet     := .T.
Local lWmsNew  := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local aAreaSC9 := SC9->(GetArea())
Local aLibDCF  := WmsLibDCF() // Busca referencia do array WMS
Local oOrdServ := WmsOrdSer() // Busca referencia do objeto WMS
Local nPosDCF  := 0

	SC9->(dbGoTo(nRecnoSC9))
	If !lWmsNew
		WmsCriaDCF('SC9',,,,@nPosDCF)
		//-- Verifica se a execucao do servico de wms sera automatica
		If Empty(nPosDCF)
			lRet := .F.
		ElseIf WmsVldSrv('4',SC9->C9_SERVIC)
			AAdd(aLibDCF,nPosDCF)
		EndIf
	Else
		If oOrdServ == Nil
			oOrdServ := WMSDTCOrdemServicoCreate():New()
			WmsOrdSer(oOrdServ) // Atualiza referencia do objeto WMS
		EndIf
		oOrdServ:SetDocto(SC9->C9_PEDIDO)
		oOrdServ:SetSerie(SC9->C9_ITEM)
		oOrdServ:SetSeqSC9(SC9->C9_SEQUEN)
		oOrdServ:oProdLote:SetProduto(SC9->C9_PRODUTO)
		oOrdServ:SetOrigem('SC9')
		If !oOrdServ:CreateDCF()
			WmsMessage(oOrdServ:GetErro(),"WmsIntPed",1)
			lRet := .F.
		EndIf
	EndIf
	RestArea(aAreaSC9)
Return lRet
/*-----------------------------------------------------------------------------
Tem por objetivo executar as ordens de serviço geradas na integração com o WMS
-----------------------------------------------------------------------------*/
Function WmsAvalExe()
   WmsExeServ()
Return Nil
/*
Equilazação dos itens da conferencia de expedição que possuem volume,
para manter a relação das sequencias liberadas do SC9 e possibilitar
o estorno parcial da liberação.
*/
Function WmsEqizSeq(lEstorno,cPedido,cItem,cProduto)
Local lRet := .T.
Local aAreaAnt := GetArea()
Local aNewD04 := {}
Local cAliasQry := Nil
Local cMaxSeq   := ""
Local nQtdResto := 0
Local nQtdConf  := 0
Local nRecnoD04 := 0
	
	If !lEstorno
		// Traz a relação entre DCV e D04 para ajustar as sequencias do D04
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT DCV.DCV_PEDIDO,
					DCV.DCV_ITEM,
					DCV.DCV_SEQUEN,
					DCV.DCV_CODPRO,
					SUM(DCV.DCV_QUANT) DCV_QUANT,
					D04.R_E_C_N_O_ D04_RECNO,
					D04.D04_PEDIDO,
					D04.D04_ITEM,
					D04.D04_SEQUEN,
					D04.D04_CODPRO,
					D04.D04_QTCONF
			FROM %Table:DCV% DCV
			LEFT JOIN %Table:D04% D04
			ON D04.D04_FILIAL = %xFilial:D04%
			AND DCV.DCV_FILIAL = %xFilial:DCV%
			AND D04.D04_PEDIDO = DCV.DCV_PEDIDO
			AND D04.D04_ITEM = DCV.DCV_ITEM
			AND D04.D04_SEQUEN = DCV.DCV_SEQUEN
			AND D04.D04_CODPRO = DCV.DCV_CODPRO
			AND D04.%NotDel%
			WHERE DCV.DCV_FILIAL = %xFilial:DCV%
			AND DCV.DCV_PEDIDO = %Exp:cPedido%
			AND DCV.DCV_ITEM = %Exp:cItem%
			AND DCV.DCV_PRDORI = %Exp:cProduto%
			AND DCV.%NotDel%
			GROUP BY DCV.DCV_PEDIDO,
					DCV.DCV_ITEM,
					DCV.DCV_SEQUEN,
					DCV.DCV_CODPRO,
					DCV.DCV_QUANT,
					D04.R_E_C_N_O_,
					D04.D04_PEDIDO,
					D04.D04_ITEM,
					D04.D04_SEQUEN,
					D04.D04_CODPRO,
					D04.D04_QTCONF
			ORDER BY DCV.DCV_PEDIDO,
					DCV.DCV_ITEM,
					DCV.DCV_SEQUEN,
					DCV.DCV_CODPRO
		EndSql
		Do While (cAliasQry)->(!Eof())
			// Caso exista uma D04 com a sequencia
			If !Empty((cAliasQry)->D04_RECNO)
				// Ajusta as quantidades referentes a sequencia liberada
				If ( (cAliasQry)->DCV_QUANT < (cAliasQry)->D04_QTCONF )
					nQtdResto := (cAliasQry)->D04_QTCONF - (cAliasQry)->DCV_QUANT
					// Quebra a quantidade referente ao sequen correspondente
					D04->(dbGoto((cAliasQry)->D04_RECNO))
					RecLock("D04",.F.)
					D04->D04_QTCONF -= nQtdResto
					D04->(MsUnlock())
					
					If nQtdResto > 0
						cMaxSeq := GetMaxSeq(cAliasQry)
						// Cria uma cópia do registro com um novo sequen
						WmsCopyReg("D04")
						D04->D04_SEQUEN := Soma1(cMaxSeq) // Adiciona +1 na sequencia para não haver chave duplicada
						D04->D04_QTCONF := nQtdResto
						D04->(MsUnlock())
						// Adiciona o registro no array com novas sequencias da conferencia para atualização posterior
						aAdd(aNewD04,{D04->D04_PEDIDO,D04->D04_ITEM,D04->D04_SEQUEN,D04->D04_CODPRO,D04->D04_QTCONF,D04->(Recno())})
					EndIf
				EndIf
			Else
				// Quando existir uma sequencia na DCV que não está no D04, analiza com base nos registros novos criados
				If Len(aNewD04) > 0
					nPosReg := aScan(aNewD04,{|x| x[1]+x[2]+x[4] == (cAliasQry)->DCV_PEDIDO+(cAliasQry)->DCV_ITEM+(cAliasQry)->DCV_CODPRO})
					
					If nPosReg > 0
						nQtdConf  := aNewD04[nPosReg][5]
						nRecnoD04 := aNewD04[nPosReg][6]
						
						// Substitui o sequen e a quantidade e caso fique alguma coisa, atualiza o array
						If ( (cAliasQry)->DCV_QUANT < nQtdConf )
							nQtdResto := nQtdConf - (cAliasQry)->DCV_QUANT
							// Quebra a quantidade referente ao sequen correspondente
							D04->(dbGoto(nRecnoD04))
							RecLock("D04",.F.)
							D04->D04_QTCONF -= nQtdResto
							If D04->D04_SEQUEN != (cAliasQry)->DCV_SEQUEN
								D04->D04_SEQUEN := (cAliasQry)->DCV_SEQUEN // Certifica que o sequen fique igual ao DCV
							EndIf
							D04->(MsUnlock())
							
							If nQtdResto > 0
								cMaxSeq := GetMaxSeq(cAliasQry)
								// Cria uma cópia do registro com um novo sequen
								WmsCopyReg("D04")
								D04->D04_SEQUEN := Soma1(cMaxSeq) // Adiciona +1 na sequencia para não haver chave duplicada
								D04->D04_QTCONF := nQtdResto
								D04->(MsUnlock())
								
								// Atualiza o registro no array com novas sequencias da conferencia para atualização posterior, caso houver
								aNewD04[nPosReg][1] := D04->D04_PEDIDO
								aNewD04[nPosReg][2] := D04->D04_ITEM
								aNewD04[nPosReg][3] := D04->D04_SEQUEN
								aNewD04[nPosReg][4] := D04->D04_CODPRO
								aNewD04[nPosReg][5] := D04->D04_QTCONF
								aNewD04[nPosReg][6] := D04->(Recno())
							EndIf
						ElseIf ( (cAliasQry)->DCV_QUANT == nQtdConf )
							// Quando não há mais o que quebrar, certifica que a ultima sequencia está atualizada
							D04->(dbGoto(nRecnoD04))
							If D04->D04_SEQUEN != (cAliasQry)->DCV_SEQUEN
								RecLock("D04",.F.)
								D04->D04_SEQUEN := (cAliasQry)->DCV_SEQUEN // Certifica que o sequen fique igual ao DCV
								D04->(MsUnlock())
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(dbCloseArea())
	Else
		// Traz a relação entre DCV e D04 para ajustar as sequencias do D04 quando estorna a liberação da DCV
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT DCV.DCV_PEDIDO,
					DCV.DCV_ITEM,
					DCV.DCV_SEQUEN,
					DCV.DCV_CODPRO,
					SUM(DCV.DCV_QUANT) DCV_QUANT,
					D04.R_E_C_N_O_ D04_RECNO,
					D04.D04_PEDIDO,
					D04.D04_ITEM,
					D04.D04_SEQUEN,
					D04.D04_CODPRO,
					D04.D04_QTCONF
			FROM %Table:D04% D04
			LEFT JOIN %Table:DCV% DCV
			ON DCV.DCV_FILIAL = %xFilial:DCV%
			AND D04.D04_FILIAL = %xFilial:D04%
			AND DCV.DCV_PEDIDO = D04.D04_PEDIDO"
			AND DCV.DCV_ITEM = D04.D04_ITEM"
			AND DCV.DCV_SEQUEN = D04.D04_SEQUEN"
			AND DCV.DCV_CODPRO = D04.D04_CODPRO"
			AND DCV.%NotDel%
			WHERE D04.D04_FILIAL = %xFilial:D04%
			AND D04.D04_PEDIDO = %Exp:cPedido%
			AND D04.D04_ITEM = %Exp:cItem%
			AND D04.D04_PRDORI = %Exp:cProduto%
			AND D04.%NotDel%
			GROUP BY D04.D04_PEDIDO,
						D04.D04_ITEM,
						D04.D04_SEQUEN,
						D04.D04_CODPRO,
						D04.D04_QTCONF,
						D04.R_E_C_N_O_,
						DCV.DCV_PEDIDO,
						DCV.DCV_ITEM,
						DCV.DCV_SEQUEN,
						DCV.DCV_CODPRO,
						DCV.DCV_QUANT
			ORDER BY D04.D04_PEDIDO,
						D04.D04_ITEM,
						D04.D04_SEQUEN,
						D04.D04_CODPRO
		EndSql
		Do While (cAliasQry)->(!Eof())
			// Caso ainda exista um DCV com o mesmo sequen
			If !Empty((cAliasQry)->DCV_SEQUEN)
				If (cAliasQry)->DCV_QUANT > (cAliasQry)->D04_QTCONF
					nQtdResto := (cAliasQry)->DCV_QUANT - (cAliasQry)->D04_QTCONF
					// Atualiza a quantidade referente ao sequen correspondente
					D04->(dbGoto((cAliasQry)->D04_RECNO))
					RecLock("D04",.F.)
					D04->D04_QTCONF += nQtdResto
					D04->(MsUnlock())
				ElseIf (cAliasQry)->DCV_QUANT < (cAliasQry)->D04_QTCONF
					nQtdResto := (cAliasQry)->D04_QTCONF - (cAliasQry)->DCV_QUANT
					// Atualiza a quantidade referente ao sequen correspondente
					D04->(dbGoto((cAliasQry)->D04_RECNO))
					RecLock("D04",.F.)
					D04->D04_QTCONF -= nQtdResto
					D04->(MsUnlock())
				EndIf
			Else
				// Exclui a D04 quando não existe a sequencia na DCV
				D04->(dbGoto((cAliasQry)->D04_RECNO))
				RecLock("D04",.F.)
				D04->(dbDelete())
				D04->(MsUnlock())
			EndIf
			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(dbCloseArea())
	EndIf
	RestArea(aAreaAnt)
Return lRet

Static Function GetMaxSeq(cAliasQry)
Local aAreaAnt  := GetArea()
Local cSeq      := ""
Local cAliasD04 := GetNextAlias()
	BeginSql Alias cAliasD04
		SELECT MAX(D04.D04_SEQUEN) D04_SEQUEN
		FROM %Table:D04% D04
		WHERE D04.D04_FILIAL = %xFilial:D04%
		AND D04.D04_PEDIDO = %Exp:(cAliasQry)->D04_PEDIDO%
		AND D04.D04_ITEM = %Exp:(cAliasQry)->D04_ITEM%
		AND D04.D04_CODPRO = %Exp:(cAliasQry)->D04_CODPRO%
		AND D04.%NotDel%
	EndSql
	If (cAliasD04)->(!Eof())
		cSeq := (cAliasD04)->D04_SEQUEN
	EndIf
	(cAliasD04)->(dbCloseArea())
	RestArea(aAreaAnt)
Return cSeq

Function WmsAvalSD2(nRecnoSD2)
Local lRet       := .T.
Local aAreaSD2   := SD2->(GetArea())
Local oOrdSerRev := Nil
Local cAliasSC9  := Nil

	If !Empty(nRecnoSD2) .And. nRecnoSD2 > 0
		SD2->(dbGoTo(nRecnoSD2))
		cAliasSC9 := GetNextAlias()
		BeginSql Alias cAliasSC9
			SELECT SC9.C9_IDDCF,
					SC9.C9_SEQUEN
			FROM %Table:SC9% SC9
			WHERE SC9.C9_FILIAL = %xFilial:SC9%
			AND SC9.C9_PEDIDO = %Exp:SD2->D2_PEDIDO%
			AND SC9.C9_ITEM = %Exp:SD2->D2_ITEMPV%
			AND SC9.C9_PRODUTO = %Exp:SD2->D2_COD%
			AND SC9.C9_NFISCAL = %Exp:SD2->D2_DOC%
			AND SC9.C9_IDDCF > '0'
			AND SC9.%NotDel%
		EndSql
		If (cAliasSC9)->(!Eof())
			oOrdSerRev := WMSDTCOrdemServicoReverse():New()
			oOrdSerRev:SetIdDCF((cAliasSC9)->C9_IDDCF)
			If oOrdSerRev:LoadData()
				oOrdSerRev:SetHasCart(.T.)
				If !oOrdSerRev:CanReverse()	
					WmsMessage(oOrdSerRev:GetErro(),,1)
					lRet := .F.
				EndIf
			EndIf
		EndIf
		(cAliasSC9)->(dbCloseArea())
	EndIf
	RestArea(aAreaSD2)
Return lRet

Function WmsUndoPed(nRecnoSC9,lEstPed,cNFiscal,nQuant)
Local lRet      := .T.
Local lWmsNew   := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local oEstEnder := Iif(lWmsNew,WMSDTCEstoqueEndereco():New(),Nil)
Local oOrdServ  := Iif(lWmsNew,WMSDTCOrdemServico():New(),Nil)

Default lEstPed   := .T.
Default cNFiscal  := ""

	If !lWmsNew
		lRet := WmsDelDCF("1","SC9")
	Else
		If !Empty(cNFiscal)
			oEstEnder:UndoFatur(nRecnoSC9,!lEstPed,cNFiscal, SD2->D2_NUMSEQ)
			If lEstPed
				lRet := oOrdServ:CancelSC9(lEstPed,nRecnoSC9,nQuant,.T. /*lPedFat*/)
			EndIf
		Else
			lRet := oOrdServ:CancelSC9(lEstPed,nRecnoSC9,nQuant)
		EndIf
	EndIf
Return lRet
//----------------------------------------------------------------------------
/*/{Protheus.doc} WmsSeqSC9
Chamada por MaDelNfs (mata521) na exclusão da nota fiscal 'Apto a Faturar'
para atualizar a chave da SC9 nas tabelas DCV, D04 e SDC.
@author felipe.m
@since 29/12/2017
@version 1.0
/*/
//----------------------------------------------------------------------------
Function WmsSeqSC9(nRecSC9,cSeqSC9)
Local lRet      := .T.
Local aAreaAnt  := GetArea()
Local cAliasQry := Nil
	If !(nRecSC9 == SC9->(Recno()))
		SC9->(dbGoTo(nRecSC9))
	EndIf
	// Procura os itens de volumes com a chave da SC9 antiga
	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT DCV.R_E_C_N_O_ RECNODCV
		FROM %Table:DCV% DCV
		WHERE DCV.DCV_FILIAL = %xFilial:DCV%
		AND DCV.DCV_PEDIDO = %Exp:SC9->C9_PEDIDO%
		AND DCV.DCV_ITEM = %Exp:SC9->C9_ITEM%
		AND DCV.DCV_SEQUEN = %Exp:cSeqSC9%
		AND DCV.DCV_PRDORI = %Exp:SC9->C9_PRODUTO%
		AND DCV.%NotDel%
	EndSql
	Do While (cAliasQry)->(!Eof())
		DCV->(dbGoTo((cAliasQry)->RECNODCV))
		RecLock("DCV",.F.)
		DCV->DCV_SEQUEN := SC9->C9_SEQUEN // Substitui a nova liberação
		DCV->(MsUnlock())
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
	// Procura os intes da conferência de expedição com a chave da SC9 antiga
	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT D04.R_E_C_N_O_ RECNOD04
		FROM %Table:D04% D04
		WHERE D04.D04_FILIAL = %xFilial:D04%
		AND D04.D04_PEDIDO = %Exp:SC9->C9_PEDIDO%
		AND D04.D04_ITEM = %Exp:SC9->C9_ITEM%
		AND D04.D04_SEQUEN = %Exp:cSeqSC9%
		AND D04.D04_PRDORI = %Exp:SC9->C9_PRODUTO%
		AND D04.%NotDel%
	EndSql
	Do While (cAliasQry)->(!Eof())
		D04->(dbGoTo((cAliasQry)->RECNOD04))
		RecLock("D04",.F.)
		D04->D04_SEQUEN := SC9->C9_SEQUEN // Substitui a nova liberação
		D04->(MsUnlock())
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT SDC.R_E_C_N_O_ RECNOSDC
		FROM %Table:SDC% SDC
		WHERE SDC.DC_FILIAL = %xFilial:SDC%
		AND SDC.DC_LOCAL = %Exp:SC9->C9_LOCAL%
		AND SDC.DC_ORIGEM = 'SC6'
		AND SDC.DC_PEDIDO = %Exp:SC9->C9_PEDIDO%
		AND SDC.DC_ITEM = %Exp:SC9->C9_ITEM%
		AND SDC.DC_SEQ = %Exp:cSeqSC9%
		AND SDC.DC_LOTECTL = %Exp:SC9->C9_LOTECTL%
		AND SDC.DC_NUMLOTE = %Exp:SC9->C9_NUMLOTE%
		AND SDC.DC_NUMSERI = %Exp:SC9->C9_NUMSERI%
		AND SDC.%NotDel%
	EndSql
	Do While (cAliasQry)->(!Eof())		
		SDC->(dbGoTo((cAliasQry)->RECNOSDC))
		RecLock("SDC",.F.)
		SDC->DC_SEQ := SC9->C9_SEQUEN // Substitui a nova liberação
		SDC->(MsUnlock())
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
	RestArea(aAreaAnt)
Return lRet
//---------------------------------------------------------
/*/{Protheus.doc} WmsVpaMov
Valida se permite alterar a quantidade
@author SQUAD WMS Protheus
@since 09/01/2018
@version 1.0
@param oMovimento objeto
@param lQtdMaior, Logico, (Consideração de quantidade maior que a original)
@param nQuant, Numerico, (Quantidade movimento)
@obs É necessário instânciar a classe de movimentos serviço
armazém como oMovimento ja carregado antes de chamar a função.
/*/
//---------------------------------------------------------
Function WmsVpaMov(oMovimento,lQtdMaior,nQuant)
Local lRet      := .T.
Local nPerToler := SuperGetMV('MV_WMSQSEP',.F., 0 ) / 100 // Permite Qtde a maior Separac. / Reabast. RF
Local nQtdToler := 0
Local nQtdMaior := 0
Local oEstEnder := oMovimento:oEstEnder
Local nPerTolPE := 0

Default nQuant  := 0

	If !oMovimento:oMovServic:ChkSepara()
		oMovimento:SetErro(STR0012) // Ação permitida somente para serviços de separação!
		lRet := .F.	
	EndIf
	If lRet .And. !lQtdMaior .And. oMovimento:oMovServic:ChkSepara() .And. !(oMovimento:oOrdServ:GetOrigem() == 'SC9')
		oMovimento:SetErro(STR0019) // Ação permitida somente para separação de pedidos de venda! 
		lRet := .F.
	EndIf
	If lRet .And. !oMovimento:IsPriAtiv()
		oMovimento:SetErro(STR0013) // Ação permitida somente na primeira atividade!
		lRet := .F.
	EndIf
	If lRet .And. !(oMovimento:oOrdServ:oProdLote:GetProduto() == oMovimento:oMovPrdLot:GetProduto())
		oMovimento:SetErro(WmsFmtMsg(STR0014,{{"[VAR01]",oMovimento:oMovPrdLot:GetProduto()},{"[VAR02]",oMovimento:oOrdServ:oProdLote:GetProduto()}})) //Produto: [VAR01] é componente do produto: [VAR02] e não pode ter a quantidade alterada!
		lRet := .F.
	EndIf
	If lRet
		// Verifica se o movimento está aglutinado
		If oMovimento:GetAgluti() == "1"
			oMovimento:SetErro(STR0015) //Atividade está aglutinada, não permite separar quantidade diferente da solicitada.
			lRet := .F.
		// Verifica se a tarefa possui outras atividades que estão aglutinadas
		ElseIf HasOthAgl(oMovimento)
			oMovimento:SetErro(STR0018) //Atividade posterior está aglutinada, não permite separar quantidade diferente da solicitada.
			lRet := .F.
		EndIf
	EndIf
	If lRet .And. lQtdMaior
		// Permite configurar um percentual de tolerância para separação a maior
		If lWMSQMSEP
			nPerTolPE := ExecBlock("WMSQMSEP",.F.,.F.,{oMovimento})
			If ValType(nPerTolPE) == "N"
				nPerToler := nPerTolPE / 100
			EndIf
		EndIf
		// Caso um outro movimento já tenha separado uma quantidade diferente, calcula com esta quantidade já
		nQtdToler := oMovimento:oOrdServ:GetQtdOri() * nPerToler
		nQtdMaior := oMovimento:oOrdServ:GetQuant() - oMovimento:oOrdServ:GetQtdOri()
		If QtdComp(nQtdMaior+nQuant) > QtdComp(nQtdToler)
			oMovimento:SetErro(STR0016) //Total ultrapassa a quantidade de tolerância a maior para a ordem de serviço.
			lRet := .F.
		EndIf
		If lRet
			// Verifica saldo do endereço origem quando quantidade solicita a maior
			oEstEnder:oEndereco:SetArmazem(oMovimento:oMovEndOri:GetArmazem())
			oEstEnder:oEndereco:SetEnder(oMovimento:oMovEndOri:GetEnder())
			oEstEnder:oProdLote:SetArmazem(oMovimento:oMovPrdLot:GetArmazem())
			oEstEnder:oProdLote:SetPrdOri(oMovimento:oMovPrdLot:GetPrdOri())     // Produto Origem
			oEstEnder:oProdLote:SetProduto(oMovimento:oMovPrdLot:GetProduto())
			oEstEnder:oProdLote:SetLoteCtl(oMovimento:oMovPrdLot:GetLoteCtl())
			oEstEnder:oProdLote:SetNumLote(oMovimento:oMovPrdLot:GetNumLote())
			oEstEnder:oProdLote:SetNumSer(oMovimento:oMovPrdLot:GetNumSer())
			oEstEnder:LoadData()
			nSaldoPrd := oEstEnder:GetQtdEst() - (oEstEnder:GetQtdSpr()+ oEstEnder:GetQtdEmp() + oEstEnder:GetQtdBlq() )
			// Utiliza soma pois somente as saídas retorna saldo negativo
			If (QtdComp(nSaldoPrd) < QtdComp(nQuant))
				oMovimento:SetErro(WmsFmtMsg(STR0017,{{"[VAR01]",Transf(nSaldoPrd,PesqPictQt('D12_QTDMOV',14))}})) // Endereço não possui saldo de estoque suficiente. Saldo disponível: [VAR01]
				lRet := .F.
			EndIf
		EndIf
	EndIf
Return lRet
//---------------------------------------------------------
/*/{Protheus.doc} WmsMovApl
Atualiza liberação do pedido
@author SQUAD WMS Protheus
@since 09/01/2018
@version 1.0
@param oMovimento objeto
@param nQtdOrig, Numerico, (Quantidade original)
@param nQtdMvto, Numerico, (Quantidade movimento)
@obs É necessário instânciar a classe de movimentos serviço
armazém como oMovimento ja carregado antes de chamar a função.
/*/
//---------------------------------------------------------
Function WmsMovApl(oMovimento,nQtdOrig,nQtdMvto) //WMSV030ALP
Local lRet      := .T.
Local lDlEstC9  := .T.
Local lDelSC9   := .F.
Local lQtdMaior := QtdComp(nQtdOrig) < QtdComp(nQtdMvto)
Local aAreaAnt  := GetArea()
Local aAreaSB2  := SB2->(GetArea())
Local aAreaSC9  := SC9->(GetArea())
Local aLocaliz  := {}
Local aDlEstC9  := {}
Local cAliasSC9 := Nil
Local cAliasSUM := Nil
Local nQuant    := Iif(lQtdMaior,nQtdMvto-nQtdOrig,nQtdOrig-nQtdMvto)
Local nQtAbat   := 0
	// P.E. para manipular o estorno da liberação do pedido
	// O retorno deve ser .T. para que o processo não tome o padrão
	If lDLVESTC9
		aDlEstC9 := ExecBlock("DLVESTC9",.F.,.F.,{lDlEstC9,{oMovimento:GetRecno()},nQtdOrig,nQtdMvto,.F.})
		If ValType(aDlEstC9) == "A" .And. Len(aDlEstC9) >= 2
			lDlEstC9 := aDlEstC9[1]
			lRet     := aDlEstC9[2]
		EndIf
	EndIf

	If lDlEstC9
		// Localiza Liberações do Pedido e subtrai a diferença
		cAliasSC9 := GetNextAlias()
		BeginSql Alias cAliasSC9
			SELECT SC9.R_E_C_N_O_ RECNOSC9
			FROM %Table:SC9% SC9
			WHERE SC9.C9_FILIAL = %xFilial:SC9%
			AND SC9.C9_IDDCF = %Exp:oMovimento:GetIdDCF()%
			AND SC9.C9_LOCAL = %Exp:oMovimento:oMovPrdLot:GetArmazem()%
			AND SC9.C9_PRODUTO = %Exp:oMovimento:oMovPrdLot:GetProduto()%
			AND SC9.C9_LOTECTL = %Exp:oMovimento:oMovPrdLot:GetLoteCtl()%
			AND SC9.C9_NUMLOTE = %Exp:oMovimento:oMovPrdLot:GetNumLote()%
			AND SC9.C9_BLWMS = '01'
			AND SC9.C9_BLEST = '  '
			AND SC9.C9_BLCRED = '  '
			AND SC9.D_E_L_E_T_ = ' '
		EndSql
		Do While (cAliasSC9)->(!Eof()) .And. QtdComp(nQuant) > 0
			SC9->(DbGoTo((cAliasSC9)->RECNOSC9))
			nQtAbat := 0
			If lQtdMaior .OR. QtdComp(SC9->C9_QTDLIB) >= QtdComp(nQuant)
				nQtAbat := nQuant
				nQuant  := 0
			Else
				nQtAbat := SC9->C9_QTDLIB
				nQuant  -= nQtAbat
			EndIf
			// Itens Pedidos de Vendas
			SC6->(DbSetOrder(1))
			SC6->(MsSeek(xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM))
			// 2.Estorno do SC9 / Estorno da Liberacao de 6.Estoque/4.Credito do SC9 / WMS
			aLocaliz := {{ "","","","",SC9->C9_QTDLIB,,Ctod(""),"","","",SC9->C9_LOCAL,0}}
			MaAvalSC9("SC9",2,aLocaliz,Nil,Nil,Nil,Nil,Nil,Nil,,.F.,,.F.)
			//-- Atualiza quantidade liberada
			RecLock("SC9",.F.)
			SC9->C9_BLEST   := " "
			SC9->C9_BLCRED  := " "
			SC9->C9_QTDLIB  := Iif(lQtdMaior,(SC9->C9_QTDLIB + nQtAbat),(SC9->C9_QTDLIB - nQtAbat))
			SC9->C9_QTDLIB2 := ConvUm(SC9->C9_PRODUTO,SC9->C9_QTDLIB,0,2)
			If QtdComp(SC9->C9_QTDLIB) <= 0
				lDelSC9 := .T.
				SC9->(DbDelete())
			EndIf
			SC9->(MsUnlock())
			SC9->(DbCommit()) //-- Força enviar para o banco a atualização da SC9
			RecLock("SC6",.F.)
			// Atualiza item do pedido de venda
			SC6->C6_QTDLIB  := SC9->C9_QTDLIB
			SC6->C6_QTDLIB2 := SC9->C9_QTDLIB2
			If lQtdMaior
				//-- Deve calcular tudo o que já possui liberado do pedido de venda
				cAliasSUM  := GetNextAlias()
				BeginSql Alias cAliasSUM
					SELECT SUM(SC9.C9_QTDLIB) SUM_QTDLIB
					FROM %Table:SC9% SC9
					WHERE SC9.C9_FILIAL = %xFilial:SC9%
					AND SC9.C9_PEDIDO = %Exp:SC9->C9_PEDIDO%
					AND SC9.C9_ITEM = %Exp:SC9->C9_ITEM%
					AND SC9.%NotDel%
				EndSql
				If QtdComp((cAliasSUM)->SUM_QTDLIB) > QtdComp(SC6->C6_QTDVEN)
					SC6->C6_QTDVEN := (cAliasSUM)->SUM_QTDLIB
					SC6->C6_UNSVEN := ConvUM(SC6->C6_PRODUTO,SC6->C6_QTDVEN,0,2)
				EndIf
				(cAliasSUM)->(DbCloseArea())
			EndIf
			SC6->(MsUnlock())
			//-- Atualiza Credito
			If !lDelSC9
				aLocaliz := {{ "","","","",SC9->C9_QTDLIB,,Ctod(""),"","","",SC9->C9_LOCAL,0}}
				MaAvalSC9("SC9",1,aLocaliz,Nil,Nil,Nil,Nil,Nil,Nil,,.F.,,.F.)
			EndIf
			(cAliasSC9)->(DbSkip())
		EndDo
		(cAliasSC9)->(DbCloseArea())
	EndIf

	RestArea(aAreaSB2)
	RestArea(aAreaSC9)
	RestArea(aAreaAnt)
Return lRet
//---------------------------------------------------------
/*/{Protheus.doc} WmsAQtdMov
Ajusta quantidade movimento
@author SQUAD WMS Protheus
@since 26/05/2015
@version 1.0
@param oMovimento objeto
@param ltarAtual, Logico, (Atualização por tarefa)
@param lQtdMaior, Logico, (Consideração de quantidade maior que a original)
@param nQtdOrig, Numerico, (Quantidade original)
@param nQtdMvto, Numerico, (Quantidade movimento)
@obs É necessário instânciar a classe de movimentos serviço
armazém como oMovimento ja carregado antes de chamar a função.
/*/
//---------------------------------------------------------
Function WmsAQtdMov(oMovimento,lTarAtual, nQtdOrig, nQtdMvto) //WMSV030ASC
Local lRet      := .T.
Local oMovAux1  := WMSDTCMovimentosServicoArmazem():New()
Local oRelacMov := WMSDTCRelacionamentoMovimentosServicoArmazem():New()
Local cAliasD12 := GetNextAlias()

	If lTarAtual
		BeginSql Alias cAliasD12
			SELECT D12.R_E_C_N_O_ RECNOD12
			FROM %Table:D12% D12
			WHERE D12.D12_FILIAL = %xFilial:D12%
			AND D12.D12_DOC = %Exp:oMovimento:oOrdServ:GetDocto()%
			AND D12.D12_SERIE = %Exp:oMovimento:oOrdServ:GetSerie()%
			AND D12.D12_CLIFOR = %Exp:oMovimento:oOrdServ:GetCliFor()%
			AND D12.D12_LOJA = %Exp:oMovimento:oOrdServ:GetLoja()%
			AND D12.D12_PRODUT = %Exp:oMovimento:oMovPrdLot:GetProduto()%
			AND D12.D12_SERVIC = %Exp:oMovimento:oMovServic:GetServico()%
			AND D12.D12_LOTECT = %Exp:oMovimento:oMovPrdLot:GetLoteCtl()%
			AND D12.D12_NUMLOT = %Exp:oMovimento:oMovPrdLot:GetNumLote()%
			AND D12.D12_TAREFA = %Exp:oMovimento:oMovServic:GetTarefa()%
			AND D12.D12_IDMOV = %Exp:oMovimento:GetIdMovto()%
			AND D12.%NotDel%
		EndSql
	Else
		BeginSql Alias cAliasD12
			SELECT D12.R_E_C_N_O_ RECNOD12
			FROM %Table:D12% D12
			WHERE D12.D12_FILIAL = %xFilial:D12%
			AND D12.D12_DOC = %Exp:oMovimento:oOrdServ:GetDocto()%
			AND D12.D12_SERIE = %Exp:oMovimento:oOrdServ:GetSerie()%
			AND D12.D12_CLIFOR = %Exp:oMovimento:oOrdServ:GetCliFor()%
			AND D12.D12_LOJA = %Exp:oMovimento:oOrdServ:GetLoja()%
			AND D12.D12_PRODUT = %Exp:oMovimento:oMovPrdLot:GetProduto()%
			AND D12.D12_SERVIC = %Exp:oMovimento:oMovServic:GetServico()%
			AND D12.D12_LOTECT = %Exp:oMovimento:oMovPrdLot:GetLoteCtl()%
			AND D12.D12_NUMLOT = %Exp:oMovimento:oMovPrdLot:GetNumLote()%
			AND D12.D12_ORDTAR > %Exp:oMovimento:oMovServic:GetOrdem()%
			AND D12.%NotDel%
		EndSql
	EndIf
	// Subtrai quantidade cortada do D12
	Do While (cAliasD12)->(!Eof())
		oMovAux1:GoToD12((cAliasD12)->RECNOD12)
		oMovAux1:SetQtdMov(oMovAux1:GetQtdMov() + (nQtdMvto-nQtdOrig))
		// Se zerar estorna o registro do D12
		If QtdComp(oMovAux1:GetQtdMov()) <= QtdComp(0)
			oMovAux1:SetStatus('0')
			oMovAux1:SetPrAuto(oMovimento:GetPrAuto())
			oMovAux1:SetDataIni(oMovimento:GetDataIni())
			oMovAux1:SetHoraIni(oMovimento:GetHoraIni())
			oMovAux1:SetDataFim(oMovimento:GetDataFim())
			oMovAux1:SetHoraFim(oMovimento:GetHoraFim())
			oMovAux1:SetRecHum(oMovimento:GetRecHum())
			oMovAux1:SetRadioF(oMovimento:GetRadioF())
		EndIf
		oMovAux1:UpdateD12()
		// Atualiza DCR
		oRelacMov:SetIdOrig(oMovAux1:GetIdDCF())
		oRelacMov:SetIdDCF(oMovAux1:oOrdServ:GetIdDCF())
		oRelacMov:SetSequen(oMovAux1:oOrdServ:GetSequen())
		oRelacMov:SetIdMovto(oMovAux1:GetIdMovto())
		oRelacMov:SetIdOpera(oMovAux1:GetIdOpera())
		oRelacMov:LoadData()
		oRelacMov:SetQuant(oMovAux1:GetQtdMov())
		oRelacMov:SetQuant2(oMovAux1:GetQtdMov2())
		oRelacMov:UpdQtdDCR()
		(cAliasD12)->(DbSkip())
	EndDo
	(cAliasD12)->(DbCloseArea())
Return lRet
//---------------------------------------------------------
/*/{Protheus.doc} WmsAtmMov
Atualização das movimentações:
	Montagem de Volume
	Distribuição Separação
	Conferencia Expedição
(long_description)
@author felipe.m
@since 26/05/2015
@version 1.0
@param oMovimento objeto
@param nQtdOrig, Numerico, (Quantidade original)
@param nQtdMvto, Numerico, (Quantidade movimento)
@obs É necessário instânciar a classe de movimentos serviço
armazém como oMovimento ja carregado antes de chamar a função.
/*/
//---------------------------------------------------------
Function WmsAtmMov(oMovimento,nQtdOrig,nQtdMvto) //WMSV030ATM
Local lRet := .T.
Local oMntVolItem := WMSDTCMontagemVolumeItens():New()
Local oDisSepItem := WMSDTCDistribuicaoSeparacaoItens():New()
Local oConExpItem := WMSDTCConferenciaExpedicaoItens():New()
Local lQtdMaior   := QtdComp(nQtdOrig) < QtdComp(nQtdMvto)

	// Atualiza Montagem Volume
	oMntVolItem:SetCarga(oMovimento:oOrdServ:GetCarga())
	oMntVolItem:SetPedido(oMovimento:oOrdServ:GetDocto())
	oMntVolItem:SetPrdOri(oMovimento:oMovPrdLot:GetPrdOri())
	oMntVolItem:SetProduto(oMovimento:oMovPrdLot:GetProduto())
	oMntVolItem:SetLoteCtl(oMovimento:oMovPrdLot:GetLoteCtl())
	oMntVolItem:SetNumLote(oMovimento:oMovPrdLot:GetNumLote())
	// Busca o codigo da montagem do volume
	oMntVolItem:SetCodMnt(oMntVolItem:oMntVol:FindCodMnt())
	If oMntVolItem:LoadData()
		If lQtdMaior
			oMntVolItem:SetQtdOri(oMntVolItem:GetQtdOri()+(nQtdMvto-nQtdOrig))
			lRet := oMntVolItem:UpdateDCT() // Se está separando a mais atualiza
		Else
			lRet := oMntVolItem:RevMntVol((nQtdOrig-nQtdMvto),0) // Senão estorna a quantidade a menor
		EndIf
		// Atualiza o status para da DCV para liberado
		If lRet .And. oMntVolItem:oMntVol:GetLibPed() == "6" .And. oMntVolItem:oMntVol:GetStatus() == "3"
			oMntVolItem:oMntVol:LiberSC9()
		EndIf
		If !lRet
			oMovimento:cErro := oMntVolItem:GetErro()
		EndIf
	EndIf
	If lRet
		// Atualiza Distribuição Separação
		oDisSepItem:oDisSep:SetCarga(oMovimento:oOrdServ:GetCarga())
		oDisSepItem:oDisSep:SetPedido(oMovimento:oOrdServ:GetDocto())
		oDisSepItem:SetPrdOri(oMovimento:oMovPrdLot:GetPrdOri())
		oDisSepItem:oDisPrdLot:SetProduto(oMovimento:oMovPrdLot:GetProduto())
		oDisSepItem:oDisPrdLot:SetLoteCtl(oMovimento:oMovPrdLot:GetLoteCtl())
		oDisSepItem:oDisPrdLot:SetNumLote(oMovimento:oMovPrdLot:GetNumLote())
		oDisSepItem:oDisPrdLot:SetNumSer(oMovimento:oMovPrdLot:GetNumSer())
		oDisSepItem:oDisEndOri:SetArmazem(oMovimento:oMovEndDes:GetArmazem())
		oDisSepItem:oDisSep:oDisEndDes:SetArmazem(oMovimento:oMovEndDes:GetArmazem())
		oDisSepItem:oDisEndOri:SetArmazem(oMovimento:oMovEndDes:GetArmazem())
		// Busca o codigo da distribuição da separação
		oDisSepItem:SetCodDis(oDisSepItem:oDisSep:FindCodDis())
		If oDisSepItem:LoadData()
			If lQtdMaior
				oDisSepItem:SetQtdOri(oDisSepItem:GetQtdOri()+(nQtdMvto-nQtdOrig))
				lRet := oDisSepItem:UpdateD0E() // Se está separando a mais atualiza
			Else
				lRet := oDisSepItem:RevDisSep((nQtdOrig-nQtdMvto),0) // Senão estorna a quantidade a menor
			EndIf
			If !lRet
				oMovimento:cErro := oDisSepItem:GetErro()
			EndIf
		EndIf
	EndIf
	If lRet
		// Atualiza Conferencia Expedição
		oConExpItem:SetCarga(oMovimento:oOrdServ:GetCarga())
		oConExpItem:SetPedido(oMovimento:oOrdServ:GetDocto())
		oConExpItem:SetPrdOri(oMovimento:oMovPrdLot:GetPrdOri())
		oConExpItem:SetProduto(oMovimento:oMovPrdLot:GetProduto())
		oConExpItem:SetLoteCtl(oMovimento:oMovPrdLot:GetLoteCtl())
		oConExpItem:SetNumLote(oMovimento:oMovPrdLot:GetNumLote())
		// Busca o codigo da conferencia de expedicao
		oConExpItem:SetCodExp(oConExpItem:oConfExp:FindCodExp())
		If oConExpItem:LoadData()
			If lQtdMaior
				oConExpItem:SetQtdOri(oConExpItem:GetQtdOri()+(nQtdMvto-nQtdOrig))
				lRet := oConExpItem:UpdateD02() // Se está separando a mais atualiza
			Else
				lRet := oConExpItem:RevConfExp((nQtdOrig-nQtdMvto),0) // Senão estorna a quantidade a menor
			EndIf
			//Se o status da conferência encontra-se como "3-Conferido" e o serviço WMS está parametrizado para liberar na conferência de expedição, então libera SC9
			If lRet .And. oConExpItem:oConfExp:GetLibPed() == "3"  .And. oConExpItem:oConfExp:GetStatus() == "3"
				WMSV102LIB(1,oConExpItem:GetCodExp(),oConExpItem:GetCarga(),oConExpItem:GetPedido())
			EndIf
			If !lRet
				oMovimento:cErro := oConExpItem:GetErro()
			EndIf
		EndIf
	EndIf
Return lRet
//---------------------------------------------------------
/*/{Protheus.doc} WmsGrvDif
Grava quantidade movimento diferente
@author SQUAD WMS Protheus
@since 26/05/2015
@version 1.0
@param oMovimento objeto
@param lQtdMaior, Logico, (Consideração de quantidade maior que a original)
@param nQtdOrig, Numerico, (Quantidade original)
@param nQtdMvto, Numerico, (Quantidade movimento)
@obs É necessário instânciar a classe de movimentos serviço
armazém como oMovimento ja carregado antes de chamar a função.
/*/
//---------------------------------------------------------
Function WmsGrvDif(oMovimento,lQtdMaior,nQtdOrig,nQtdMvto)
Local lRet := .T.
	// Atualiza liberação do pedido
	If oMovimento:oOrdServ:GetOrigem() == "SC9"
		lRet := WmsMovApl(oMovimento,nQtdOrig,nQtdMvto)
	EndIf
	If lRet
		// Subtrai quantidade cortada do DCF
		If oMovimento:oOrdServ:GetQtdOri() == 0
			oMovimento:oOrdServ:SetQtdOri(oMovimento:oOrdServ:GetQuant())
		EndIf
		oMovimento:oOrdServ:SetQuant( oMovimento:oOrdServ:GetQuant() + (nQtdMvto-nQtdOrig) )
		If lRet
			// Ajusta quantidade movimento
			lRet := WmsAQtdMov(oMovimento,.T., nQtdOrig, nQtdMvto)
		EndIf
		If lRet
			// Ajusta estoque por endereço
			oMovimento:SetQtdMov(Abs(nQtdOrig-nQtdMvto))
			If lQtdMaior
				oMovimento:MakeOutput()
				oMovimento:MakeInput()
			Else
				oMovimento:HitMovEst()
			EndIf
			oMovimento:SetQtdMov(nQtdMvto)
			// Ajusta quantidade movimento
			lRet := WmsAQtdMov(oMovimento,.F., nQtdOrig, nQtdMvto)
		EndIf
		If lRet
			// Atualização das movimentações:
			// Montagem de Volume
			// Distribuição Separação
			// Conferencia Expedição
			lRet := WmsAtmMov(oMovimento,nQtdOrig,nQtdMvto)
		EndIf
		If lRet
			If QtdComp(oMovimento:oOrdServ:GetQuant()) <= 0
				oMovimento:oOrdServ:SetStServ('0')
				oMovimento:SetDataFim(dDataBase)
				oMovimento:SetHoraFim(Time())
			EndIf
			oMovimento:oOrdServ:UpdateDCF()
		EndIf
	EndIf
Return lRet

Static Function HasOthAgl(oMovimento)
Local lRet      := .F.
Local aAreaAnt  := GetArea()
Local cAliasQry := GetNextAlias()

	BeginSql Alias cAliasQry
		SELECT 1
		FROM %Table:DCR% DCR
		INNER JOIN %Table:D12% D12
		ON D12.D12_FILIAL = %xFilial:D12%
		AND D12.D12_IDDCF = DCR.DCR_IDORI
		AND D12.D12_IDMOV = DCR.DCR_IDMOV
		AND D12.D12_IDOPER = DCR.DCR_IDOPER
		AND D12.D12_AGLUTI = '1'
		AND D12.%NotDel%
		WHERE DCR.DCR_FILIAL = %xFilial:DCR%
		AND DCR.DCR_IDDCF = %Exp:oMovimento:GetIdDCF()%
		AND DCR.%NotDel%
	EndSql
	lRet := (cAliasQry)->(!Eof())
	(cAliasQry)->(DbCloseArea())
	RestArea(aAreaAnt)
Return lRet
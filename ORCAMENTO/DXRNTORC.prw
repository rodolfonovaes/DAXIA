#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#include "FWMVCDEF.CH"
#INCLUDE "MATXDEF.CH"
User Function DXRNTORC(cTipo)
Local nFrete 		:= SCJ->CJ_XVLFRETE
Local cCodCli		:= SCJ->CJ_CLIENTE
Local cLoja			:= SCJ->CJ_LOJA
Local cConPag		:= SCJ->CJ_CONDPAG
Local nMoedaC		:= 1
Local nMoedaV		:= 1
Local nVlrPis 		:= 0
Local nVlrCof		:= 0
Local cTES			:= ''
Local nValDesc		:= 0
Local nItem			:= 0
Local nValMerc		:= 0
Local nAcresFin		:= 0
Local nPrcVen		:= 0
Local nQtdVen		:= 0
Local nItens		:= 0
Local nDesconto		:= 0
Local nQtdPeso		:= 0
Local cQuery 		:= ''
Local cCodProd		:= ''
Local nCustd  		:= 0
Local nPrcLista		:= 0
Local nAliqICM  	:= 0
Local nAliqICMP  	:= 0
Local nAliqPIS  	:= 0
Local nAliqCOF  	:= 0
Local nAliqIPI  	:= 0
Local nAliqST   	:= 0
Local nVlrPis		:= 0
Local nVlrCof		:= 0
Local nVlrIcm		:= 0
Local nVlrIcmP		:= 0
Local nVlrIpi		:= 0
Local cAliasQry 	:= GetNextAlias()
Local nRecVenIpi	:= 0
Local nIpi			:= 0
Local nRecVen		:= 0
Local nCustRep		:= 0
Local nGerBrut		:= 0
Local nPis			:= 0
Local nCofins		:= 0
Local nIcms			:= 0
Local nIcmsP		:= 0
Local nComis		:= 0
Local nDespFin		:= 0
Local nFrete		:= 0
Local nPComis		:= 0
Local nVComis		:= 0
Local nDsr			:= 0
Local nPDsr			:= 0
Local nMgBruta		:= 0
Local nMgLiq		:= 0
Local nPMgLiq		:= 0
Local nResult		:= 0
Local nVlrNeg		:= 0
Local nNegociado	:= 0 
Local nVlrBase		:= 0
Local nPCustFin		:= SupergetMV('ES_CUSTFIN',.T.,2.5)
Local cCondPag		:= SCJ->CJ_CONDPAG
Local nExcecoes		:= 0
Local nPMgBrut		:= 0 
Local nPFrete		:= 0
Local nPPalet		:= 0
Local aRet			:= {}
Local aRelImp		:= {}
Local cLogRef		:= {}
Local aItens		:= {}
Local nDifal		:= 0
Local nAliqDif		:= 0
Local nTotDifal		:= 0
Local nAliqFecp		:= 0 
Local nAlqDif		:= 0
Local nPos			:= 0
Local nLinha		:= SCK->(Recno())
Local cQuery		:= GetNextAlias()
Local nSuframa		:= 0
Local nCustFin		:= 0
Local nAux			:= 0
LOcal nTotPPis 		:= 0
LOcal nTotPCof 		:= 0
LOcal nTotPicm 		:= 0
LOcal nTotPDif 		:= 0
LOcal nTotPicm 		:= 0
Local nTotPComis 	:= 0
Local nTotPDsr 		:= 0
Local nTotPDsr 		:= 0
Local nTotMgLiq		:= 0
Local nTotDespFin	:= 0
Local nTotFrete		:= 0
Local lSZL			:= .F.
Local nRef			:= 0
Local nTMP1Bkp		:= 0

SA1->(DbSetOrder(1)) //--A1_FILIAL+A1_COD+A1_LOJA
SA1->(DbSeek(FwxFilial('SA1') + cCodCli + cLoja))
//MaFisSave()
//MaFisEnd()
MaFisIni( cCodCli ,;		// 1-Codigo Cliente/Fornecedor
			cLoja ,;	// 2-Loja do Cliente/Fornecedor
			"C",;										// 3-C:Cliente , F:Fornecedor
			"N",;										// 4-Tipo da NF
			SA1->A1_TIPO,;							    // 5-Tipo do Cliente/Fornecedor
			aRelImp,;
			NIL,;
			NIL,;
			'SB1',;
			"MATA461",;
			Nil,;
			Nil,;
			Nil,;
			Nil,;
			Nil,;
			Nil,;
			Nil,;
			,,,,cCodCli,cLoja,,, nil)

dbSelectArea("SCK")
SCK->(DbSetOrder(1))
SCK->(DbSeek(SCJ->(CJ_FILIAL + CJ_NUM) ))
While !SCK->(EOF()) .And. SCJ->(CJ_FILIAL + CJ_NUM) == SCK->(CK_FILIAL + CK_NUM)

	nMoedaC		:=  1
	nMoedaV		:=  1
	cCodProd 	:= 	SCK->CK_PRODUTO
	nQtdVen 	:=  SCK->CK_QTDVEN
	
	If cTipo $ '3' .Or. cTipo == '2' 
		if cTipo == '2'
			DbSelectArea('SZC')	
			SZC->(DbSetOrder(1))
			If SZC->(DbSeek(xFilial('SZC') + SCJ->CJ_NUM + '1'))
				nRecVenIpi 	+= SZC->ZC_RECEITA
				nIpi	   	+= SZC->ZC_IPI
				nRecVen		+= SZC->ZC_RECSIPI
				nCustRep	+= SZC->ZC_CUSTD
				nGerBrut	+= SZC->ZC_GBRTCX
				nPis		+= SZC->ZC_PIS
				//nAliqPIS	+= SZC->ZC_PPIS
				nCofins		+= SZC->ZC_COFINS
				nAliqCOF	+= SZC->ZC_PCOFINS
				nIcms		+= SZC->ZC_ICMS
				//nAliqICM	+= SZC->ZC_PICMS
				nTotDifal	+= SZC->ZC_ICMSP
				//nAliqICMP	+= SZC->ZC_PICMSP
				nComis		+= SZC->ZC_COMIS
				//nPComis		+= SZC->ZC_PCOMIS
				nTotDespFin	+= SZC->ZC_DESPFIN
				nTotFrete	+= SZC->ZC_FRETE
				nExcecoes	+= SZC->ZC_PALET
				nMgBruta 	+= SZC->ZC_RECEITA - SZC->ZC_CUSTD
				nTotMgLiq	+= nRecVen - nCustRep - nPis - nCofins - nIcms - nTotDifal - nTotFrete - nExcecoes - nTotDespFin
				nDsr		+= SZC->ZC_DSR
				nItens		+= SZC->ZC_ITENS
				aItens		:= {}
				lSZL		:= .T.
				Exit
			EndIf
		EndIf

		DA1->(DbSetOrder(1))
		If DA1->(DbSeek(xFilial('DA1') + SUPERGETMV('ES_DAXTAB',.T.,'001',cFilAnt) + cCodProd))	.And. !empty(cConPag)
			SBZ->(DbSetOrder(1)) //--B1_FILIAL+B1_COD
			SBZ->(DbSeek(FwxFilial('SBZ')+cCodProd))

			If SBZ->BZ_MCUSTD == '2'
				nMoedaC	:= 2
			If DA1->DA1_MOEDA == 2
				nMoedaV	:= 2
			EndIf

			EndIf
			//nPrcVen			:= SCK->CK_PRCVEN	* nQtdVen//xMoeda(DA1->DA1_XCUSTD,nMoedaC,nMoedaV,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2'))
			nPrcVen			:= xMoeda(DA1->DA1_XCUSTD,nMoedaC,1,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2')) * nQtdVen //transformo em real
			nPrcLista		:= nPrcVen
			nNegociado		:= SCK->CK_PRCVEN * SCK->CK_QTDVEN
			nVlrBase		:= xMoeda(SCK->CK_PRCVEN,VAL(SCK->CK_MOEDA),1,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2')) * SCK->CK_QTDVEN//transformo em real
			Aadd(aItens,{SCK->(Recno()),nPrcVen,nNegociado})
		EndIf
	ElseIf cTipo == '4'
		nPrcVen := Posicione('SB2',1,xFilial('SB2') + cCodProd,'B2_CM1') * nQtdVen
		SBZ->(DbSetOrder(1)) //--B1_FILIAL+B1_COD
		SBZ->(DbSeek(FwxFilial('SBZ')+cCodProd))

		If SBZ->BZ_MCUSTD == '2'
			nMoedaC	:= 2
		If DA1->DA1_MOEDA == 2
			nMoedaV	:= 2
		EndIf

		EndIf
		//nPrcVen			:= SCK->CK_PRCVEN	* nQtdVen//xMoeda(DA1->DA1_XCUSTD,nMoedaC,nMoedaV,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2'))
		nPrcVen			:= xMoeda(nPrcVen,nMoedaC,1,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2')) 
		nPrcLista		:= nPrcVen			
		nPrcLista := nPrcVen
		nNegociado		:= SCK->CK_PRCVEN * SCK->CK_QTDVEN
		nVlrBase		:= xMoeda(SCK->CK_PRCVEN,VAL(SCK->CK_MOEDA),1,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2')) * SCK->CK_QTDVEN //transformo em real
		Aadd(aItens,{SCK->(Recno()),nPrcVen,nNegociado})
	ElseIf cTipo == '5' //chamado pelo A415TDOK
		DA1->(DbSetOrder(1))
		If DA1->(DbSeek(xFilial('DA1') + SUPERGETMV('ES_DAXTAB',.T.,'001',cFilAnt) + cCodProd))	.And. !empty(cConPag)
			SBZ->(DbSetOrder(1)) //--B1_FILIAL+B1_COD
			SBZ->(DbSeek(FwxFilial('SBZ')+cCodProd))

			If SBZ->BZ_MCUSTD == '2'
				nMoedaC	:= 2
			If DA1->DA1_MOEDA == 2
				nMoedaV	:= 2
			EndIf

			EndIf
			nPrcVen			:= xMoeda(DA1->DA1_XCUSTD,nMoedaC,1,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2')) * nQtdVen //transformo em real
			nPrcLista		:= nPrcVen	
			nNegociado		:= SCK->CK_PRCVEN * SCK->CK_QTDVEN
			nVlrBase		:= xMoeda(SCK->CK_PRCVEN,VAL(SCK->CK_MOEDA),1,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2')) * SCK->CK_QTDVEN//transformo em real
			Aadd(aItens,{SCK->(Recno()),nPrcVen,nNegociado})
		EndIf
	ElseIF cTipo $ 'ITORIG|ITATUAL'
	//	While nSeleciona <> Val(SCK->CK_ITEM)
	//		SCK->(DbSkip())
//		EndDo
		cCodProd 	:= 	SCK->CK_PRODUTO
		nQtdVen 	:=  SCK->CK_QTDVEN	

		DbSelectArea('SZL')	
		SZL->(DbSetOrder(1))
		If cTipo == 'ITORIG' 
			nTMP1Bkp := SCK->(Recno())
			SCK->(DbGoTo(nRecTMP1))
			IF SZL->(DbSeek(xFilial('SZL') + SCJ->CJ_NUM + SCK->CK_ITEM + SCK->CK_PRODUTO))
				nRecVenIpi 	+= SZL->ZL_RECEITA
				nIpi	   	+= SZL->ZL_IPI
				nRecVen		+= SZL->ZL_RECSIPI
				nCustRep	+= SZL->ZL_CUSTD
				nGerBrut	+= SZL->ZL_GBRTCX
				nPis		+= SZL->ZL_PIS
				nCofins		+= SZL->ZL_COFINS
				nAliqCOF	+= SZL->ZL_PCOFINS
				nIcms		+= SZL->ZL_ICMS
				nTotDifal	+= SZL->ZL_ICMSP
				nComis		+= SZL->ZL_COMIS
				nTotDespFin	+= SZL->ZL_DESPFIN
				nTotFrete	+= SZL->ZL_FRETE
				nExcecoes	+= SZL->ZL_PALET
				nMgBruta 	+= SZL->ZL_RECEITA - SZL->ZL_CUSTD
				nTotMgLiq	+= nRecVen - nCustRep - nPis - nCofins - nIcms - nTotDifal - nTotFrete - nExcecoes - nTotDespFin
				nDsr		+= SZL->ZL_DSR
				nItens		+= SZL->ZL_ITENS
				aItens		:= {}
				lSZL := .T.
				Exit
			EndIf
			SCK->(dbGoTo(nTMP1Bkp))
		EndIf
		
		DA1->(DbSetOrder(1))
		If DA1->(DbSeek(xFilial('DA1') + SUPERGETMV('ES_DAXTAB',.T.,'001',cFilAnt) + cCodProd))	.And. !empty(cConPag)
			SBZ->(DbSetOrder(1)) //--B1_FILIAL+B1_COD
			SBZ->(DbSeek(FwxFilial('SBZ')+cCodProd))

			If SBZ->BZ_MCUSTD == '2'
				nMoedaC	:= 2
			If DA1->DA1_MOEDA == 2
				nMoedaV	:= 2
			EndIf

			EndIf
			//nPrcVen			:= SCK->CK_PRCVEN	* nQtdVen//xMoeda(DA1->DA1_XCUSTD,nMoedaC,nMoedaV,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2'))
			nPrcLista			:= xMoeda(DA1->DA1_XCUSTD,nMoedaC,1,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2')) * nQtdVen //converto para real
			nPrcVen				:= nPrcLista
			nNegociado			:= SCK->CK_PRCVEN * SCK->CK_QTDVEN
			nVlrBase			:= xMoeda(SCK->CK_PRCVEN,VAL(SCK->CK_MOEDA),1,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2')) * SCK->CK_QTDVEN //transformo em real
			Aadd(aItens,{SCK->(Recno()),nPrcVen,SCK->CK_PRCVEN * SCK->CK_QTDVEN})
		EndIf	
	EndIf

	cTES 		:= SCK->CK_TES
	nValDesc	:= 0

//	If cTipo == 'ITEM'
//			nItem := 1//
	//EndIf
		
	SB1->(DbSetOrder(1)) //--B1_FILIAL+B1_COD
	SB1->(DbSeek(FwxFilial('SB1')+cCodProd))

	SF4->(dbSetOrder(1))
	SF4->(DbSeek(xFilial('SF4') + cTES))
	nAcresFin := A410Arred((nPrcVen*SE4->E4_ACRSFIN)/100, 'D2_PRCVEN')
	nValMerc  := nPrcVen
	nDesconto := A410Arred(nPrcLista, 'D2_DESCON') - nValMerc

	nDesconto := Max(0,nDesconto)
	nPrcLista += nAcresFin
	nValMerc  += nDesconto

	aRelImp := MaFisRelImp('MT100', {"SF2", "SD2", "SF3", "SFT"})

	cLogRef := ''
	For nRef := 1 To Len(aRelImp)
		cLogRef += aRelImp[nRef, 01] + CRLF
		cLogRef += aRelImp[nRef, 01] + CRLF
		cLogRef += aRelImp[nRef, 03] + CRLF
	Next nRef
	MemoWrite('C:\TOTVS\RELIMP.txt', cLogRef)


	//If !MaFisFound('NF')
	//	MaFisSave()
	//	MaFisEnd()
	//EndIf

	// ------------------------------------
	// AGREGA OS ITENS PARA A FUNCAO FISCAL
	// ------------------------------------
	MaFisAdd(	cCodProd,;  	    // 1-Codigo do Produto ( Obrigatorio )
				cTES,;	   	        // 2-Codigo do TES ( Opcional )
				nQtdVen,;  	        // 3-Quantidade ( Obrigatorio )
				nVlrBase,;		  	// 4-Preco Unitario ( Obrigatorio )
				nDesconto,;  		// 5-Valor do Desconto ( Opcional )
				"",;	   			// 6-Numero da NF Original ( Devolucao/Benef )
				"",;				// 7-Serie da NF Original ( Devolucao/Benef )
				0,;					// 8-RecNo da NF Original no arq SD1/SD2
				0,;					// 9-Valor do Frete do Item ( Opcional )
				0,;					// 10-Valor da Despesa do item ( Opcional )
				0,;					// 11-Valor do Seguro do item ( Opcional )
				0,;					// 12-Valor do Frete Autonomo ( Opcional )
				nVlrBase,;	// 13-Valor da Mercadoria ( Obrigatorio )
				0,;					// 14-Valor da Embalagem ( Opiconal )
				SB1->(Recno()),SF4->(Recno()) , , , , , , , , , , , ,;
				SCK->CK_CLASFIS) // 28-Classificacao fiscal)


	MaFisSave()

	SCK->(DbSkip())
EndDo

SCK->(DbSetOrder(1))
SCK->(DbSeek(SCJ->(CJ_FILIAL + CJ_NUM) ))
While SCJ->(CJ_FILIAL + CJ_NUM) == SCK->(CK_FILIAL + CK_NUM) .And. !lSZL
	IF Len(aItens) > 0 //.And. !Val(SCK->CK_XMOTIVO) > 1
		nVlrPis  := 0
		nAliqPIS := 0
		nVlrCof  := 0
		nAliqCOF := 0
		nVlrIcm	 := 0
		nAliqICM := 0
		nMgLiq	 := 0
		nDifal   := 0
		nFrete   := 0 
		nDespFin := 0

		//TRATAMENTO PARA PEDIDO DE AMOSTRA MOSTRAR TUDO ZERADO
		If SCJ->CJ_XTPOPER $ SUPERGETMV('ES_OPZEROR',.T.,'')
			nRecVenIpi 	+= 0
			nIpi	   	+= 0
			nRecVen		+= 0
			nCustRep	+= 0
			nGerBrut	+= 0
			nPis		+= 0
			nCofins		+= 0
			nAliqCOF	+= 0
			nIcms		+= 0
			nTotDifal	+= 0
			nComis		+= 0
			nTotDespFin	+= 0
			nTotFrete	+= 0
			nExcecoes	+= 0
			nMgBruta 	+= 0
			nTotMgLiq	+= nRecVen - nCustRep - nPis - nCofins - nIcms - nTotDifal - nTotFrete - nExcecoes - nTotDespFin
			nDsr		+= 0
			nItens		+= 0
			aItens		:= {}
			Exit		
		EndIf			

		If cTipo $ 'ITORIG|ITATUAL' 
			nItem := nSeleciona
			nPos := aScan(aItens,{|x| x[1]==nRecTMP1})
			SCK->(DbGoTo(aItens[nPos][1]))
			nPrcVen		:= aItens[nPos][2]
			nNegociado	:= aItens[nPos][3]
		Else
			nItens++
			nItem++			
			nPrcVen		:= aItens[nItem][2]
			nNegociado	:= aItens[nItem][3]
		EndIf
		

		SB1->(DbSetOrder(1)) //--B1_FILIAL+B1_COD
		SB1->(DbSeek(FwxFilial('SB1')+SCK->CK_PRODUTO))		
		// ------------------------------------
		// CALCULO DO ISS
		// ------------------------------------
		SF4->(DbSeek(FwxFilial('SF4')+SCK->CK_TES))
	/*	If SA1->A1_INCISS == "N"
			If SF4->F4_ISS=="S"
				nPrcLista := a410Arred(nPrcLista/(1-(MaAliqISS(nItem)/100)), 'D2_PRCVEN')
				nValMerc  := a410Arred(nValMerc/(1-(MaAliqISS(nItem)/100)), 'D2_PRCVEN')
				MaFisAlt('IT_PRCUNI', nPrcLista, nItem)
				MaFisAlt('IT_VALMERC', nValMerc, nItem)
			EndIf
		EndIf*/

		// ------------------------------------
		// VERIFICA O PESO P/ CALCULO DO FRETE
		// ------------------------------------
		nQtdPeso := nQtdVen * SB1->B1_PESO

	/*	If !MaFisFound('NF')
			MaFisAlt("IT_PESO"   , nQtdPeso , nItem)
			MaFisAlt("IT_PRCUNI" , nPrcLista, nItem)
			MaFisAlt("IT_VALMERC", nValMerc , nItem)

			// ------------------------------------------
			// INDICA OS VALORES DO CABECALHO
			// ------------------------------------------
			MaFisAlt("NF_FRETE"   , nFrete)
			MaFisAlt("NF_SEGURO"  , nSeguro)
			MaFisAlt("NF_AUTONOMO", nFrtAut)
			MaFisAlt("NF_DESPESA" , nDespes)
			MaFisAlt("NF_DESCONTO", MaFisRet(,"NF_DESCONTO")+MaFisRet(,"NF_VALMERC")*nPdescab/100)
			MaFisAlt("NF_DESCONTO", MaFisRet(,"NF_DESCONTO")+nDescont)
			MaFisWrite(1)
		EndIf*/

		nNegociado 	:= xMoeda(nNegociado,VAL(SCK->CK_MOEDA),1,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2')) //converto pra real

		//IPI
		nVlrIpi  := MaFisRet(nItem,"IT_VALIPI")
		nAliqIpi := MaFisRet(nItem,"IT_ALIQIPI")
		nVlrIpi := ((nNegociado * nAliqIpi)/100)

		nVlrBase := nNegociado + nVlrIpi

		//ICMS Partilha
		//nVlrIcmP  := MaFisRet(nItem,"IT_DIFAL")
		If SA1->A1_CONTRIB == '2'
			nDifal := MaFisRet(nItem,"IT_DIFAL") 
			nAliqDif := ((nVlrBase * nDifal)/100)
			nAliqFecp	:= POSICIONE('CFC',1,xFilial('CFC') + SM0->M0_ESTCOB + SA1->A1_EST,'CFC_ALQFCP')
			nDifal := nDifal + ((nVlrBase * nAliqFecp)/100)			
		EndIf

		//valor TOTAL com impostos de cada item
		nVlrIt  := MaFisRet(nItem,"IT_TOTAL")

		If nSuframa > 0 .And. SA1->A1_CALCSUF $ 'S'
			nVlrPis  := 0
			nAliqPIS := 0
			nVlrCof  := 0
			nAliqCOF := 0
		Else		
			If nVlrPis == 0 
				nVlrPis  := MaFisRet(nItem,"IT_VALPS2")
				nAliqPIS := MaFisRet(nItem,"IT_ALIQPS2")

				If nVlrPis == 0 .And. nAliqPIS > 0
					nVlrPis := ((nNegociado * nAliqPIS)/100)
				EndIf
			Endif

			If nVlrCof == 0 
				nVlrCof  := MaFisRet(nItem,"IT_VALCF2")
				nAliqCOF := MaFisRet(nItem,"IT_ALIQCF2")

				If  nVlrCof == 0 .And. nAliqCOF > 0
					nVlrCof := ((nNegociado * nAliqCOF)/100)
				EndIf
			Endif
		EndIf
		nTotPPis += nAliqPIS
		nTotPCof += nAliqCOF

		
		If SB1->B1_ORIGEM $ '3|5'
			If Select(cAliasQry) > 0
				(cAliasQry)->(DbCloseArea())
			EndIf
			cQuery := 'SELECT MAX(CFD_PERVEN), CFD_ORIGEM '
			cQuery += "  FROM " + RetSQLTab('CFD')
			cQuery += "  WHERE  "
			cQuery += "  CFD_FILIAL = '" + xFilial('CFD') + "' " 
			cQuery += "  AND '" + SCK->CK_PRODUTO + "' = CFD_COD "
			cQuery += "  AND D_E_L_E_T_ = ' '"
			cQuery += "  GROUP BY CFD_PERVEN, CFD_ORIGEM "
			cQuery += "  ORDER BY SUBSTRING(CFD_PERVEN,3,4) DESC , SUBSTRING(CFD_PERVEN,1,2) DESC "

			TcQuery cQuery new Alias ( cAliasQry )

			If !(cAliasQry)->(EOF()) .And. SM0->M0_ESTCOB <> SA1->A1_EST
				If (cAliasQry)->CFD_ORIGEM == '3'
					//Beneficio de isenção do suframa é apenas para produtos nacionais
					nAliqICM  := 4 //Aliquota para importado
					If nAliqCOF == 0
						nAliqCOF := MaFisRet(nItem,"IT_ALIQCOF")
					EndIf

					If  nVlrCof == 0 .And. nAliqCOF > 0
						nVlrCof := ((nNegociado * nAliqCOF)/100)
					EndIf	

					If nAliqPIS == 0 
						nAliqPIS := MaFisRet(nItem,"IT_ALIQPIS")
					EndIf
					If nVlrPis == 0 .And. nAliqPIS > 0
						nVlrPis := ((nNegociado * nAliqPIS)/100)
					EndIf											
				Else
					nAliqICM := MaFisRet(nItem,"IT_ALIQICM")						
				EndIf
			Else
				nAliqICM := MaFisRet(nItem,"IT_ALIQICM")
			EndIf
			nVlrIcm := ((nVlrBase * nAliqICM)/100)
			(cAliasQry)->(DbCloseArea())		
		EndIf
		nSuframa := MaFisRet(nItem,"IT_DESCZF")
		If nSuframa > 0 .And. SA1->A1_CALCSUF $ 'S|I'
			nVlrIcm := 0
			nAliqICM := 0
			If SB1->B1_ORIGEM $ '3|5'
				If Select(cAliasQry) > 0
					(cAliasQry)->(DbCloseArea())
				EndIf
				cQuery := 'SELECT MAX(CFD_PERVEN), CFD_ORIGEM '
				cQuery += "  FROM " + RetSQLTab('CFD')
				cQuery += "  WHERE  "
				cQuery += "  CFD_FILIAL = '" + xFilial('CFD') + "' " 
				cQuery += "  AND '" + SCK->CK_PRODUTO + "' = CFD_COD "
				cQuery += "  AND D_E_L_E_T_ = ' '"
				cQuery += "  GROUP BY CFD_PERVEN, CFD_ORIGEM "
				cQuery += "  ORDER BY SUBSTRING(CFD_PERVEN,3,4) DESC , SUBSTRING(CFD_PERVEN,1,2) DESC "

				TcQuery cQuery new Alias ( cAliasQry )

				If !(cAliasQry)->(EOF())
					If (cAliasQry)->CFD_ORIGEM == '3'
						//Beneficio de isenção do suframa é apenas para produtos nacionais
						nAliqICM  := 4 //Aliquota para importado
						If nAliqCOF == 0
							nAliqCOF := MaFisRet(nItem,"IT_ALIQCOF")
						EndIf

						If  nVlrCof == 0 .And. nAliqCOF > 0
							nVlrCof := ((nNegociado * nAliqCOF)/100)
						EndIf	

						If nAliqPIS == 0 
							nAliqPIS := MaFisRet(nItem,"IT_ALIQPIS")
						EndIf
						If nVlrPis == 0 .And. nAliqPIS > 0
							nVlrPis := ((nNegociado * nAliqPIS)/100)
						EndIf											
					Else
						nAliqICM := 0//MaFisRet(nItem,"IT_ALIQICM")						
					EndIf
				Else
					nAliqICM := 0//MaFisRet(nItem,"IT_ALIQICM")
				EndIf
				nVlrIcm := ((nVlrBase * nAliqICM)/100)
				(cAliasQry)->(DbCloseArea())
			ElseIf SB1->B1_ORIGEM == '6' //IMPORTADO SEM SIMILAR NACIONAL
				nAliqICM	:= MaFisRet(nItem,"IT_ALIQICM")
				nVlrIcm := ((nVlrBase * nAliqICM)/100)		
			ElseIf SB1->B1_ORIGEM == '2' //Importado	
				nAliqICM	:= MaFisRet(nItem,"IT_ALIQICM")
				nVlrIcm := ((nVlrBase * nAliqICM)/100)								
			Else
				nAliqICM := 0//MaFisRet(nItem,"IT_ALIQICM")
			EndIf
		Else
			//ICMS
			If nAliqICM == 0
				nAliqICM := MaFisRet(nItem,"IT_ALIQICM")
			EndIf
			If SF4->F4_BASEICM > 0
				nAliqICM := Round((SF4->F4_BASEICM * nAliqICM) / 100,2)
				nVlrIcm := ((nVlrBase * nAliqICM)/100)
			Else		
				If  nAliqICM > 0
					nVlrIcm := ((nVlrBase * nAliqICM)/100)
				EndIf		
			EndIf	
		EndIf


		//TRATAMENTO PARA IPI
		If SA1->A1_CONTRIB == '2' .And. nVlrIpi > 0
			nAliqIcm := (nVlrIcm / nVlrBase) * 100
			nVlrIcm  := ((nVlrBase * nAliqIcm)/100)
		EndIf

		If SA1->A1_CONTRIB == '2' .And. nVlrIpi > 0
			nAliqDif := (nDifal / nNegociado) * 100
			nDifal   := ((nNegociado * nAliqDif)/100)
		Else
			nAliqDif := 18 + nAliqFecp - nAliqICM
		EndIf

		If SA1->A1_CONTRIB == '1' .And. nVlrIcm > 0 // contribuinte
			nVlrIcm  := ((nNegociado * nAliqIcm)/100)
		ElseIf SA1->A1_CONTRIB == '1' 
			nAliqICM	:= MaFisRet(nItem,"IT_ALIQICM") //ajuste 07/07 - nao estava retornando icms corretamente quando o cliente era suframa
			nVlrIcm := ((nVlrBase * nAliqICM)/100)		
		EndIf		

		nTotPicm += nAliqICM
		nTotPDif += nAliqDif

		nCustFin := RetCfin(cCondPag,nPCustFin)
		nAux := ((nNegociado + nVlrIpi) * nCustFin )/100 
		If SA1->A1_CONTRIB == '2' .And. nVlrIpi > 0
			nCustFin := ((nAux / nNegociado ) * 100)
			nDespFin := (nNegociado  * nCustFin )/100 
		Else
			nDespFin := ((nNegociado + nVlrIpi) * nCustFin )/100 
		EndIf

		nTotDespFin += nDespFin
		nFrete		:= SCK->CK_XVLFRET 
		nTotFrete	+= nFrete
		nExcecoes	+= SCK->CK_XPALET //Exceções

		nTotDifal	+= nDifal
		nVlrNeg		+= nNegociado 
		
		nRecVenIpi 	+= nNegociado + nVlrIpi
		nIpi	   	+= nVlrIpi
		nRecVen		+= nNegociado
		nCustRep	+= nPrcVen 
		nGerBrut	+= nNegociado - nPrcVen
		nPis		+= nVlrPis
		nCofins		+= nVlrCof
		nIcms		+= nVlrIcm
	//	nIcmsP		+= nVlrIcmP
		nMgBruta 	+= nNegociado - nPrcVen
		//nMgLiq		+= nNegociado - nVlrPis - nVlrCof - nVlrIcm - nDifal - nFrete - nExcecoes - nDespFin
		nMgLiq		:= (nNegociado - nPrcVen) - nVlrPis - nVlrCof - nVlrIcm - nDifal - SCK->CK_XVLFRET - SCK->CK_XPALET - nDespFin
		//nMgLiq		:= nNegociado - nVlrPis - nVlrCof - nVlrIcm - nDifal - SCK->CK_XVLFRET - SCK->CK_XPALET - nDespFin
		nTotMgLiq	+= nMgLiq
		nPMgLiq		:= round((nMgLiq * 100) / nNegociado ,2)
		//nPMgLiq		+= round((nVlrNeg - nPrcVen * 100) / nRecVen ,2) - nAliqPIS - nAliqCOF - nAliqICM - (18 + nAliqFecp - nAliqICM)- round((nDespFin * 100) / nRecVen ,2) - round((nFrete * 100) / nVlrNeg ,2)  - round((nExcecoes * 100) / nVlrNeg ,2) 
		
		If cTipo $ '3|ITORIG|ITATUAL' .Or. (IsinCallStack('MATA416'))
			If SB1->B1_XCOMIS == '2'
				SCK->CK_COMIS1 := SB1->B1_COMIS
				nComis		+= nNegociado * (SB1->B1_COMIS / 100)
			Else
				SA3->(DbSetOrder(1))
				IF SA3->(DbSeek(xFilial('SA3')+ SCJ->CJ_XVEND)) .And. SA3->A3_XTIPO = '2'
					If INCLUI .Or. ALTERA 
						SCK->CK_COMIS1 := SA3->A3_COMIS
					EndIf
					nComis		+= nNegociado * (SA3->A3_COMIS / 100)
				Else
					If INCLUI .Or. ALTERA 
						SCK->CK_COMIS1  := RetComis(nPMgLiq,SCK->CK_PRODUTO)
					EndIf
					nComis		+= nNegociado * (RetComis(nPMgLiq,SCK->CK_PRODUTO) / 100)
				EndIf
			EndIf
			If INCLUI .OR. ALTERA
				SCK->CK_XMGBRUT := nPMgLiq
				If SCJ->CJ_XTPOPER $ SUPERGETMV('ES_OPZEROR',.T.,'') 
					SCK->CK_XMGBRUT	:= 0
				EndIf				
			EndIf
			
		ElseIf cTipo $ '2|3|4'
			If SB1->B1_XCOMIS == '2'
				//SCK->CK_COMIS1 := SB1->B1_COMIS
				nComis		+= nNegociado * (SB1->B1_COMIS / 100)
			Else		
				SA3->(DbSetOrder(1))
				IF SA3->(DbSeek(xFilial('SA3')+ SCJ->CJ_XVEND)) .And. SA3->A3_XTIPO = '2'
					nComis		+= nNegociado * (SA3->A3_COMIS / 100)
				Else
					nComis		+= nNegociado * (RetComis(nPMgLiq,SCK->CK_PRODUTO) / 100)
				EndIf	
			EndIf
		EndIf

		If cTipo $ 'SCJ'
			GetDRefresh()
		EndIf

		DbSelectArea('SZD')
		SZD->(Dbsetorder(1))
		If SZD->(DbSeek(xFilial('SZD') + Alltrim(Str(year(dDatabase))) + PadL(Alltrim(STR(Month(dDataBase))),2,'0')))
			nPDsr		:= SZD->ZD_PDSR / 100
		EndIf

		If SA3->A3_XTIPO <> '2'
			nPDsr := RetComis(nPMgLiq,SCK->CK_PRODUTO) * nPDsr
			nDsr += nNegociado * (nPDsr / 100)
		Else
			nPDsr	:= 0
			nDsr	:= 0
		EndIf
		//SCK->CK_COMIS1  := RetComis(nPMgLiq)  
		
		nTotPDsr += nPDsr

		If cTipo $ 'ITORIG|ITATUAL'
			SCK->(DbGoBottom())
		EndIf
	EndIf
	SCK->(DbSkip())
EndDo

If nItens == 0
	If cTipo $ 'ITORIG|ITATUAL'
		nItens := 1
	Else
		SCK->(DbGoTop())
		While !SCK->(EOF())
			nItens++
			SCK->(DbSkip())
		EndDo
	EndIf
EndIf
aadd(aRet,{ROUND(nRecVenIpi,2),0})  //Receita de Vendas Com IPI 1
aadd(aRet,{nIpi ,0})  //IPI 2 
aadd(aRet,{ROUND(nRecVen ,2),100} )  //Receita de Vendas Sem IPI 3 
aadd(aRet,{ROUND(nCustRep ,2) 	, round((nCustRep * 100) / nRecVen ,2)})  //Custo de reposição 4
aadd(aRet,{ROUND(nGerBrut ,2) 	, round((nGerBrut * 100) / nRecVen ,2)})  //Geração bruta de caixa 5
aadd(aRet,{ROUND(nPis ,2) 		, round((nPis * 100) / nRecVen ,2)})  //PIS 6 
aadd(aRet,{ROUND(nCofins ,2) 	, round((nCofins * 100) / nRecVen ,2)})  //Cofins 7 
aadd(aRet,{ROUND(nIcms ,2) 		, round((nIcms * 100) / nRecVen ,2)})  //ICMS 8 
aadd(aRet,{ROUND(nTotDifal ,2) 	, round((nTotDifal * 100) / nRecVen ,2) })  //ICMS Partilha 9    18 % - aliq icms 
aadd(aRet,{ROUND(nTotDespFin ,2) 	, round((nTotDespFin * 100) / nRecVen ,2)})  //Despesas Financeiras 10
aadd(aRet,{ROUND(nTotFrete ,2) 	, round((nTotFrete * 100) / nRecVen ,2)})  //Frete 11
aadd(aRet,{ROUND(nExcecoes ,2) 	, round((nExcecoes * 100) / nRecVen ,2)})  //Paletização 12
nPFrete	:=  round((nFrete * 100) / nRecVen ,2) 
nPPalet :=  round((nExcecoes * 100) / nRecVen ,2) 
//aadd(aRet,{ROUND(nMgLiq / nItens,3) ,round((nGerBrut * 100) / nRecVen ,2) - nAliqPIS - nAliqCOF - nAliqICM - (18 + nAliqFecp - nAliqICM)- round((nDespFin * 100) / nRecVen ,2) - nPFrete - nPPalet })  //Margem 13
aadd(aRet,{ROUND(nTotMgLiq ,2) 	,round((nTotMgLiq * 100) / nRecVen ,2) })  //Margem 13
aadd(aRet,{NOROUND(nComis ,2) 	, round((nComis * 100) / nRecVen ,2)})  //Comissoes sem DSR 14
aadd(aRet,{NOROUND(nDsr ,2)   	, round((nDsr * 100) / nRecVen ,2)})  //DSR 15
aadd(aRet,{NOROUND(NOROUND(nComis ,2) + NOROUND(nDsr ,2),2) ,round(((nComis + nDsr) * 100) / nRecVen ,2)})   //Comissoes Com DSR 16
nResult	:= nTotMgLiq - (NOROUND(NOROUND(nComis ,2) + NOROUND(nDsr ,2),2) ) 
aadd(aRet,{ ROUND(nResult,2) 	, round((nResult * 100) / nRecVen ,2) })  //Resultado 117
MafisEnd()
SCK->(DbGoTo(nLinha))
Return aRet


User Function RntOrcDx()                        
Local oSay1
Local oSay10
Local oSay2
Local oSay3
Local oSay4
Local oSay5
Local oSay6
Local oSay7
Local oSay8
Local oSay9
Local nCol1	:= 6
Local nCol2	:= 190
Local nCol3	:= 350
Local nCol4	:= 520
Local aCol2	:= {}
Local aCol3	:= {}
Local aCol4	:= {}
Private oFont16n:= TFont():New(,9,14,.T.,.T.,5,.T.,5,.T.,.F.)
Static oDlg
aSize := MsAdvSize(.F.)

	If Select('TMP1') <> 0
		return
	EndIf

  //DEFINE MSDIALOG oDlg TITLE "Margem de Rentabilidade" FROM 000, 000  TO 800, 1500 COLORS 0, 16777215 PIXEL
   DEFINE MSDIALOG oDlg TITLE "Margem de Rentabilidade" FROM aSize[7], 000  TO 8000, 1500 COLORS 0, 16777215 PIXEL

    @ 006, nCol1 SAY oSay1 PROMPT "ORÇAMENTO " + Alltrim(SCJ->CJ_NUM) SIZE 100, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 006, 062 SAY oSay4 PROMPT "Vendedor " + Posicione('SA3',1,Xfilial('SA3') + SCJ->CJ_XVEND , 'A3_NOME') SIZE 150, 024 OF oDlg COLORS 0, 16777215 PIXEL
    @ 026, nCol1 SAY oSay5 PROMPT "Analise da Rentabilidade" FONT oFont16n SIZE 150, 24 OF oDlg COLORS 0, 16777215 PIXEL
    @ 015, nCol2 - 30 SAY oSay7 PROMPT "Analise Com Custo Padrao Na Entrada do Pedido" FONT oFont16n SIZE 150, 24 OF oDlg COLORS 0, 16777215 PIXEL
	@ 030, nCol2 SAY oSay7 PROMPT "$" SIZE 100, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 030, nCol2 + 60 SAY oSay7 PROMPT "%" SIZE 100, 024 OF oDlg COLORS 0, 16777215 PIXEL
	
    @ 015, nCol3 - 30 SAY oSay9 PROMPT "Analise Com Custo Padrao Atual" FONT oFont16n SIZE 150, 24 OF oDlg COLORS 0, 16777215 PIXEL
	@ 030, nCol3 SAY oSay7 PROMPT "$" SIZE 100, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 030, nCol3 + 60 SAY oSay7 PROMPT "%" SIZE 100, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 015, nCol4 - 30 SAY oSay9 PROMPT "Analise Alternativa CM de Estoque Atual" FONT oFont16n SIZE 150, 24 OF oDlg COLORS 0, 16777215 PIXEL
	@ 030, nCol4 SAY oSay7 PROMPT "$" SIZE 100, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 030, nCol4 + 60 SAY oSay7 PROMPT "%" SIZE 100, 024 OF oDlg COLORS 0, 16777215 PIXEL	
	
	//Primeira Coluna
    @ 050, nCol1  SAY oSay10 PROMPT "(+) Receita de vendas (com IPI)" FONT oFont16n SIZE 150, 24 OF oDlg COLORS 0, 16777215 PIXEL
	@ 060, nCol1  SAY oSay10 PROMPT "(-) IPI" SIZE 061, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 070, nCol1  SAY oSay10 PROMPT "(=) Receita de vendas (sem IPI)" FONT oFont16n SIZE 150, 24 OF oDlg COLORS 0, 16777215 PIXEL
	@ 080, nCol1  SAY oSay10 PROMPT "(-) Custo de Reposição (Sem Impostos Recuperaveis)" SIZE 150, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 090, nCol1  SAY oSay10 PROMPT "(=) Geração Bruta de Caixa" FONT oFont16n SIZE 150, 24 OF oDlg COLORS 0, 16777215 PIXEL
	@ 110, nCol1  SAY oSay10 PROMPT "(-) Pis" SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 120, nCol1  SAY oSay10 PROMPT "(-) Cofins" SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 130, nCol1  SAY oSay10 PROMPT "(-) ICMS" SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 140, nCol1  SAY oSay10 PROMPT "(-) ICMS Partilha" SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 150, nCol1  SAY oSay10 PROMPT "(-) Despesas Financeiras" SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 160, nCol1  SAY oSay10 PROMPT "(-) Custo de Frete" SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 170, nCol1  SAY oSay10 PROMPT "(-) Custo de Palete" SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 180, nCol1  SAY oSay10 PROMPT "(=) Margem"  FONT oFont16n SIZE 150, 50 OF oDlg COLORS 0, 16777215 PIXEL
	@ 190, nCol1  SAY oSay10 PROMPT "(-) Comissão de vendas sem DSR"  SIZE 150, 50 OF oDlg COLORS 0, 16777215 PIXEL
	@ 200, nCol1  SAY oSay10 PROMPT "(-) DSR sobre comissão de vendas"  SIZE 150, 50 OF oDlg COLORS 0, 16777215 PIXEL
	@ 210, nCol1  SAY oSay10 PROMPT "(=) Comissão com DSR"  FONT oFont16n SIZE 150, 50 OF oDlg COLORS 0, 16777215 PIXEL
	@ 230, nCol1  SAY oSay10 PROMPT "(=) Resultado Financeiro" FONT oFont16n SIZE 150, 50 OF oDlg COLORS 0, 16777215 PIXEL

	//Segunda Coluna
	aCol2 := U_DxRntOrc('2')
	aCol3 := U_DxRntOrc('3')
	aCol4 := U_DxRntOrc('4')

	/*
	1//Receita de Vendas Com IPI
	2//IPI
	3//Receita de Vendas Sem IPI
	4//Custo de reposição
	5//Geração bruta de caixa
	6//PIS
	7//Cofins
	8//ICMS
	9//ICMS Partilha
	10//Comissoes sem DSR
	11//Despesas Financeiras
	12//Frete
	13//Resultado	
	*/
    @ 050, nCol2 SAY oSay10 PROMPT Alltrim(Transform( aCol2[1,1], "@E 999,999,999,999.99" )) FONT oFont16n  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //Receita de vendas (com IPI)
	@ 060, nCol2 SAY oSay10 PROMPT Alltrim(Transform( aCol2[2,1], "@E 999,999,999,999.99" ))  SIZE 061, 024 OF oDlg COLORS 0, 16777215 PIXEL // IPI
	@ 070, nCol2 SAY oSay10 PROMPT Alltrim(Transform( aCol2[3,1], "@E 999,999,999,999.99" ))  FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL // Receita de vendas (sem IPI)
	@ 080, nCol2 SAY oSay10 PROMPT Alltrim(Transform( aCol2[4,1], "@E 999,999,999,999.99" ))  SIZE 150, 024 OF oDlg COLORS 0, 16777215 PIXEL //Custo de Reposição (Sem Impostos Recuperaveis)
	@ 090, nCol2 SAY oSay10 PROMPT Alltrim(Transform( aCol2[5,1], "@E 999,999,999,999.99" ))  FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //Geração Bruta de Caixa
	@ 110, nCol2 SAY oSay10 PROMPT Alltrim(Transform( aCol2[6,1], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //Pis
	@ 120, nCol2 SAY oSay10 PROMPT Alltrim(Transform( aCol2[7,1], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //cofins
	@ 130, nCol2 SAY oSay10 PROMPT Alltrim(Transform( aCol2[8,1], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //ICMS
	@ 140, nCol2 SAY oSay10 PROMPT Alltrim(Transform( aCol2[9,1], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //ICMS PARTILHA
	@ 150, nCol2 SAY oSay10 PROMPT Alltrim(Transform( aCol2[10,1], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //DESPESAS FINANCEIRAS
	@ 160, nCol2 SAY oSay10 PROMPT Alltrim(Transform( aCol2[11,1], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //CUSTO DE FRETE
	@ 170, nCol2 SAY oSay10 PROMPT Alltrim(Transform( aCol2[12,1], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //CUSTO DE Palete
	@ 180, nCol2 SAY oSay10 PROMPT Alltrim(Transform( aCol2[13,1], "@E 999,999,999,999.99" ))  FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //Margem
	@ 190, nCol2 SAY oSay10 PROMPT Alltrim(Transform( aCol2[14,1], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //Comissão s DSR
	@ 200, nCol2 SAY oSay10 PROMPT Alltrim(Transform( aCol2[15,1], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //DSR
	@ 210, nCol2 SAY oSay10 PROMPT Alltrim(Transform( aCol2[16,1], "@E 999,999,999,999.99" ))  FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //Comissão c DSR
	@ 230, nCol2 SAY oSay10 PROMPT Alltrim(Transform( aCol2[17,1], "@E 999,999,999,999.99" ))  FONT oFont16n  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //RESULTADO FINANCEIRO
	
	@ 070, nCol2 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol2[3,2], "@E 999,999,999,999.99" ))  FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL	//Custo de Reposição (Sem Impostos Recuperaveis)
	@ 080, nCol2 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol2[4,2], "@E 999,999,999,999.99" ))  SIZE 150, 024 OF oDlg COLORS 0, 16777215 PIXEL	//Custo de Reposição (Sem Impostos Recuperaveis)
	@ 090, nCol2 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol2[5,2], "@E 999,999,999,999.99" ))  FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL	//geração bruta de caixa
	@ 110, nCol2 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol2[6,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL	//pis
	@ 120, nCol2 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol2[7,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL	//cofins
	@ 130, nCol2 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol2[8,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL	//ICMS
	@ 140, nCol2 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol2[9,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL	//ICMS PARTILHA
	@ 150, nCol2 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol2[10,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL	//DESPESAS FINANCEIRAS
	@ 160, nCol2 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol2[11,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL	//CUSTO DE FRETE
	@ 170, nCol2 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol2[12,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL	//CUSTO DE Palete
	@ 180, nCol2 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol2[13,2], "@E 999,999,999,999.99" ))  FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //Margem
	@ 190, nCol2 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol2[14,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //Comissão s DSR
	@ 200, nCol2 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol2[15,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //DSR
	@ 210, nCol2 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol2[16,2], "@E 999,999,999,999.99" ))  FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //Comissão c DSR
	@ 230, nCol2 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol2[17,2], "@E 999,999,999,999.99" ))  FONT oFont16n  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //RESULTADO FINANCEIRO


	//Terceira coluna
    @ 050, nCol3 SAY oSay10 PROMPT Alltrim(Transform( aCol3[1,1], "@E 999,999,999,999.99" )) FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 060, nCol3 SAY oSay10 PROMPT Alltrim(Transform( aCol3[2,1], "@E 999,999,999,999.99" ))  SIZE 061, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 070, nCol3 SAY oSay10 PROMPT Alltrim(Transform( aCol3[3,1], "@E 999,999,999,999.99" ))  FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 080, nCol3 SAY oSay10 PROMPT Alltrim(Transform( aCol3[4,1], "@E 999,999,999,999.99" ))  SIZE 150, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 090, nCol3 SAY oSay10 PROMPT Alltrim(Transform( aCol3[5,1], "@E 999,999,999,999.99" ))  FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 110, nCol3 SAY oSay10 PROMPT Alltrim(Transform( aCol3[6,1], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 120, nCol3 SAY oSay10 PROMPT Alltrim(Transform( aCol3[7,1], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 130, nCol3 SAY oSay10 PROMPT Alltrim(Transform( aCol3[8,1], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 140, nCol3 SAY oSay10 PROMPT Alltrim(Transform( aCol3[9,1], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 150, nCol3 SAY oSay10 PROMPT Alltrim(Transform( aCol3[10,1], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 160, nCol3 SAY oSay10 PROMPT Alltrim(Transform( aCol3[11,1], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 170, nCol3 SAY oSay10 PROMPT Alltrim(Transform( aCol3[12,1], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 180, nCol3 SAY oSay10 PROMPT Alltrim(Transform( aCol3[13,1], "@E 999,999,999,999.99" ))  FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //Margem
	@ 190, nCol3 SAY oSay10 PROMPT Alltrim(Transform( aCol3[14,1], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //Comissão s DSR
	@ 200, nCol3 SAY oSay10 PROMPT Alltrim(Transform( aCol3[15,1], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //DSR
	@ 210, nCol3 SAY oSay10 PROMPT Alltrim(Transform( aCol3[16,1], "@E 999,999,999,999.99" )) FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //Comissão c DSR
	@ 230, nCol3 SAY oSay10 PROMPT Alltrim(Transform( aCol3[17,1], "@E 999,999,999,999.99" ))  FONT oFont16n  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //RESULTADO FINANCEIRO

	@ 070, nCol3 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol3[3,2], "@E 999,999,999,999.99" ))  FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 080, nCol3 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol3[4,2], "@E 999,999,999,999.99" ))  SIZE 150, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 090, nCol3 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol3[5,2], "@E 999,999,999,999.99" ))  FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 110, nCol3 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol3[6,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 120, nCol3 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol3[7,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 130, nCol3 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol3[8,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 140, nCol3 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol3[9,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 150, nCol3 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol3[10,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 160, nCol3 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol3[11,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 170, nCol3 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol3[12,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 180, nCol3 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol3[13,2], "@E 999,999,999,999.99" ))  FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //Margem
	@ 190, nCol3 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol3[14,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //Comissão s DSR
	@ 200, nCol3 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol3[15,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //DSR
	@ 210, nCol3 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol3[16,2], "@E 999,999,999,999.99" )) FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //Comissão c DSR
	@ 230, nCol3 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol3[17,2], "@E 999,999,999,999.99" ))  FONT oFont16n  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //RESULTADO FINANCEIRO

	//Terceira coluna
    @ 050, nCol4 SAY oSay10 PROMPT Alltrim(Transform( aCol4[1,1], "@E 999,999,999,999.99" )) FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL 
	@ 060, nCol4 SAY oSay10 PROMPT Alltrim(Transform( aCol4[2,1], "@E 999,999,999,999.99" ))  SIZE 061, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 070, nCol4 SAY oSay10 PROMPT Alltrim(Transform( aCol4[3,1], "@E 999,999,999,999.99" ))  FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 080, nCol4 SAY oSay10 PROMPT Alltrim(Transform( aCol4[4,1], "@E 999,999,999,999.99" ))  SIZE 150, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 090, nCol4 SAY oSay10 PROMPT Alltrim(Transform( aCol4[5,1], "@E 999,999,999,999.99" ))  FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 110, nCol4 SAY oSay10 PROMPT Alltrim(Transform( aCol4[6,1], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 120, nCol4 SAY oSay10 PROMPT Alltrim(Transform( aCol4[7,1], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 130, nCol4 SAY oSay10 PROMPT Alltrim(Transform( aCol4[8,1], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 140, nCol4 SAY oSay10 PROMPT Alltrim(Transform( aCol4[9,1], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 150, nCol4 SAY oSay10 PROMPT Alltrim(Transform( aCol4[10,1], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 160, nCol4 SAY oSay10 PROMPT Alltrim(Transform( aCol4[11,1], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 170, nCol4 SAY oSay10 PROMPT Alltrim(Transform( aCol4[12,1], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 180, nCol4 SAY oSay10 PROMPT Alltrim(Transform( aCol4[13,1], "@E 999,999,999,999.99" ))  FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //Margem
	@ 190, nCol4 SAY oSay10 PROMPT Alltrim(Transform( aCol4[14,1], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //Comissão s DSR
	@ 200, nCol4 SAY oSay10 PROMPT Alltrim(Transform( aCol4[15,1], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //DSR
	@ 210, nCol4 SAY oSay10 PROMPT Alltrim(Transform( aCol4[16,1], "@E 999,999,999,999.99" )) FONT oFont16n  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //Comissão c DSR
	@ 230, nCol4 SAY oSay10 PROMPT Alltrim(Transform( aCol4[17,1], "@E 999,999,999,999.99" ))  FONT oFont16n  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //RESULTADO FINANCEIRO

	@ 070, nCol4 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol4[3,2], "@E 999,999,999,999.99" ))  FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 080, nCol4 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol4[4,2], "@E 999,999,999,999.99" ))  SIZE 150, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 090, nCol4 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol4[5,2], "@E 999,999,999,999.99" ))  FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 110, nCol4 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol4[6,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 120, nCol4 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol4[7,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 130, nCol4 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol4[8,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 140, nCol4 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol4[9,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 150, nCol4 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol4[10,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 160, nCol4 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol4[11,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 170, nCol4 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol4[12,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 180, nCol4 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol4[13,2], "@E 999,999,999,999.99" ))  FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //Margem
	@ 190, nCol4 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol4[14,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //Comissão s DSR
	@ 200, nCol4 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol4[15,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //DSR
	@ 210, nCol4 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol4[16,2], "@E 999,999,999,999.99" )) FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //Comissão c DSR
	@ 230, nCol4 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol4[17,2], "@E 999,999,999,999.99" ))  FONT oFont16n  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //RESULTADO FINANCEIRO		

  ACTIVATE MSDIALOG oDlg CENTERED

Return



Static Function RetCfin(cCondPag, nPrcFin)
Local nRet	:= 0
Local nParc	:= 0
Local nInt	:= 0
Local nDow	:= 0
Local nCarencia	:= 0
Local nDias	:= 0
Local nI	:= 0
Local nMesIni	:= 0
Local dData	:= dDataBase
Local aDatas	:= {}
Local cData		:= ''
Local cParc	:= ''
Local cAux	:= ''
Local aAux	:= {}
Local nAux	:= 0

SE4->(DbSetOrder(1))
IF SE4->(DbSeek(xFilial('SE4') + cCondPag))
	If SE4->E4_TIPO == '1'
		cParc := Alltrim(STRTRAN(SE4->E4_COND,',','+'))
		nParc	:= Len(Separa(cParc,'+'))
	ElseIf SE4->E4_TIPO == '3'
		aAux := Separa(SE4->E4_COND,',')
		nParc	:= Val(aAux[1])
		nCarencia	:= Val(aAux[2])

		dData 	+= nCarencia
		nDias 	:= nCarencia
		nAux	:= 3

		//Verifico qual data vai ser a primeira parcela
		For nI := 3 to Len(aAux)
			If Day(dData) <= Val(aAux[nI])
				nAux := nI
				Exit
			EndIf
		Next

		For nI := 1 To nParc
			While Day(dData) <> Val(aAux[nAux])
				dData++
				nDias++
			EndDo

			cParc	+= Str(nDias) + '+'

			If nAux == Len(aAux)
				nAux := 3
			Else
				nAux++
			EndIf
		Next
		cParc := Substr(cParc,1,Len(cParc)-1)
	ElseIf SE4->E4_TIPO == '4'
		nParc	:= Val(Separa(SE4->E4_COND,',')[1])
		nInt	:= Val(Separa(SE4->E4_COND,',')[2])
		nDow	:= Val(Separa(SE4->E4_COND,',')[3])
		
		//Verifico quando cai a primeira parcela
		While Dow(dData) <> nDow
			dData++
			nDias++
		EndDo

		cParc := STR(nDias) + '+'

		//somo os outros dias
		For nI := 2 to nParc
			nDias += nInt
			cParc	+= Str(nDias) + '+'
		Next
		cParc := Substr(cParc,1,Len(cParc)-1)
	ElseIf SE4->E4_TIPO == '6'
		aAux 		:= Separa(SE4->E4_COND,',')
		nParc		:= Val(aAux[1])
		nCarencia	:= Val(aAux[2])
		nDow		:= Val(aAux[3])
		nIntervalo	:= Val(aAux[4])

		dData 	+= nCarencia
		nDias	+= nCarencia
		//Verifico quando cai a primeira parcela
		While Dow(dData) <> nDow
			dData++
			nDias++
		EndDo
		
		cParc	+= Str(nDias) + '+'
		For nI := 2 To nParc
			dData += nIntervalo
			nDias += nIntervalo

			While DOW(dData) <> nDow
				dData++
				nDias++
			EndDo

			cParc	+= Str(nDias) + '+'
		Next
		cParc := Substr(cParc,1,Len(cParc)-1)		
	ElseIf SE4->E4_TIPO == '7'
		aDatas := Separa(SE4->E4_COND,',')
		nParc := Val(aDatas[1])
		aDel(aDatas,1)

		nMesIni := Month(dData)

		If day(dData) > Val(aDatas[nMesIni])
			nMesIni++
			dData := MonthSum(dData,1)
		EndIF

		cData := Dtos(dData)
		cData := Substr(cData,1,6) + aDatas[1]
		dData	:= STOD(cData)
		cParc := Alltrim(Str(DateDiffDay(dDataBase,dData))) + '+'
				
		For nI := 2 to nParc
			dData := MonthSum(dData,1) //acrescento 1 mes
			cData := Dtos(dData) 
			cData := Substr(cData,1,6) + aDatas[nI] //altero para o dia de vencimento parametrizado
			dData	:= STOD(cData)
			cParc += Alltrim(Str(DateDiffDay(dDataBase,dData))) + '+'
		next
		cParc := Substr(cParc,1,Len(cParc)-1)
	ElseIf SE4->E4_TIPO == '8'
		//Obtenho as parcelas
		For nI := 2 to Len(SE4->E4_COND) // começo no 2 pra pular o primeiro [
			If SUBSTR(SE4->E4_COND,nI,1) == ']'
				Exit //saio qdo achar o fim
			EndIf
			cAux += SUBSTR(SE4->E4_COND,nI,1)
		Next

		cParc := Alltrim(STRTRAN(cAux,',','+'))
		nParc	:= Len(Separa(cParc,'+'))
	EndIf

	If &cParc == 0
		nRet	:= 0
	Else
		nRet := ((nPrcFin / 30) * Round(((&cParc)/nParc),0)) 
	EndIf
EndIf

Return nRet



/*/{Protheus.doc} RetComis
	Calcula o % da comissao com base na margem liquida
	@type  Function
	@author user
	@since date
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function RetComis(nMargem,cProduto)
Local cQuery := ''
Local cAliasQry := GetNextAlias()
Local nRet	:= 0
Local aArea	:= GetArea()

SB1->(DbSetOrder(1))
If SB1->(DbSeek(xFilial('SB1') + cProduto))
	If SB1->B1_XCOMIS == '2'
		RestArea(aArea)
		Return SB1->B1_COMIS
	EndIf
EndIf

cQuery := "SELECT * "
cQuery += "  FROM " + RetSQLTab('SZ9')
cQuery += "  WHERE  "
cQuery += "  Z9_FILIAL = '" + xFilial('SZ9') + "' " 
cQuery += "  AND " + Str(nMargem) + " >= Z9_MGINI "
cQuery += "  AND " + Str(nMargem) + " <= Z9_MGFIM "
cQuery += "  AND D_E_L_E_T_ = ' '"

TcQuery cQuery new Alias ( cAliasQry )

If !(cAliasQry)->(EOF())
	nRet := (cAliasQry)->Z9_COMISS
EndIf

SA3->(DbSetOrder(1))
If IsInCallStack('MATA410') .And. SA3->(DbSeek(xFilial('SA3') + SC5->C5_VEND1))
	//Verifico se é PJ
	If SA3->A3_XTIPO == '2'
		nRet := SA3->A3_COMIS
	EndIF
EndIf

(cAliasQry)->(DbCloseArea())
RestArea(aArea)
Return nRet




//--------------------------------------------------------------
/*/{Protheus.doc} Dx	
Description                                                     
                                                                
@param xParam Parameter Description                             
@return xRet Return Description                                 
@author  -                                               
@since 29/08/2019                                                   
/*/                                                             
//--------------------------------------------------------------
User Function OrcRntIt()                        
Local oSay1
Local oSay10
Local oSay4
Local oSay5
Local oSay7
Local nCol1	:= 6
Local nCol2	:= 190
Local nCol3	:= 350
Local aCol2	:= {}
Local aHeader	:= {'Item','Produto','Quantidade','Descrição','Resultado','Valor'}
Local aItens	:= {}
Local nLinha	:= 0 
Local nPerDsr	:= 0
Local nResult	:= 0
Local nVlResult	:= 0
Private oFont16n:= TFont():New(,9,14,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont16:= TFont():New(,9,14,.F.,.F.,5,.T.,5,.T.,.F.)
Private	nSeleciona	:= 0
Private nRecTMP1	:= 0
Static oDlg

If Select('TMP1') <> 0
	return
EndIf

aSize := MsAdvSize(.F.)

MafisEnd()

DbSelectArea('SZD')
SZD->(Dbsetorder(1))
If SZD->(DbSeek(xFilial('SZD') + Alltrim(Str(year(dDataBase))) + PadL(Alltrim(STR(Month(dDataBase))),2,'0')))
    nPerDsr		:= SZD->ZD_PDSR / 100    
EndIf

If Posicione('SA3',1,xFilial('SA3') + SCJ->CJ_XVEND ,'A3_XTIPO') == '2' 
		nPerDsr := 0
EndIf

SCK->(DbSetOrder(1))
SCK->(DbSeek(SCJ->(CJ_FILIAL + CJ_NUM) ))
While !SCK->(EOF()) .And. SCJ->(CJ_FILIAL + CJ_NUM) == SCK->(CK_FILIAL + CK_NUM)
	
			//TRATAMENTO PARA PEDIDO DE AMOSTRA MOSTRAR TUDO ZERADO
	If SCJ->CJ_XTPOPER $ SUPERGETMV('ES_OPZEROR',.T.,'') 
		nResult	:= 0
	//ElseIf Posicione('SA3',1,xFilial('SA3') + SCJ->CJ_XVEND ,'A3_XTIPO') <> '2' 
	//	nResult :=  Round(SCK->CK_XMGBRUT - SCK->CK_COMIS1,2)
	Else
		nResult :=  Round(SCK->CK_XMGBRUT - (SCK->CK_COMIS1 * nPerDsr) - SCK->CK_COMIS1,2)
		nVlResult := xMoeda((SCK->CK_PRCVEN * SCK->CK_QTDVEN),Val(SCK->CK_MOEDA),1,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2')) * (nResult / 100)
		//nResult := Round(SCK->CK_XMGBRUT,2)// Round(SCK->CK_XMGBRUT - SCK->CK_COMIS1,2)
	EndIf
	aadd(aItens,{SCK->CK_ITEM,;
						SCK->CK_PRODUTO,;
						STR(SCK->CK_QTDVEN),;
						allTrim(SCK->CK_DESCRI),;
						Alltrim(Transform(nResult, "@E 999,999,999.99" )) + ' %',;
						Transform(nVlResult, "@E 999,999,999.99" ) ,;
						SCK->(Recno());
				})
	
	SCK->(dbSkip())
EndDo

If Len(aItens) > 0
	nSeleciona := TmsF3Array(aHeader, aItens, 'Selecione o item' ) 
	If nSeleciona > 0
		nRecTMP1 := aItens[nSeleciona][7]
		aCol2 := U_DXRNTORC('ITORIG')
		aCol3 := U_DXRNTORC('ITATUAL')
	Else
		//Alert('Cancelado pelo usuario')
		SCK->(DbGoTo(nLinha))
		Return
	EndIf
EndIf 	
	
//DEFINE MSDIALOG oDlg TITLE "Margem de Rentabilidade " + AllTrim(aItens[nSeleciona][3]) FROM 000, 000  TO 800, 750 COLORS 0, 16777215 PIXEL
//DEFINE MSDIALOG oDlg TITLE "Margem de Rentabilidade " + AllTrim(aItens[nSeleciona][3]) FROM aSize[7], 000  TO 600, 750 COLORS 0, 16777215 PIXEL
   DEFINE MSDIALOG oDlg TITLE "Margem de Rentabilidade "+ AllTrim(aItens[nSeleciona][3]) FROM aSize[7], 000  TO 600, 1000 COLORS 0, 16777215 PIXEL


@ 006, nCol1 SAY oSay1 PROMPT "ORÇAMENTO " + Alltrim(SCJ->CJ_NUM) SIZE 100, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 006, 062 SAY oSay4 PROMPT "Vendedor " + Posicione('SA3',1,Xfilial('SA3') + SCJ->CJ_XVEND , 'A3_NOME') SIZE 150, 024 OF oDlg COLORS 0, 16777215 PIXEL
@ 026, nCol1 SAY oSay5 PROMPT "Analise da Rentabilidade" FONT oFont16n SIZE 150, 24 OF oDlg COLORS 0, 16777215 PIXEL
@ 015, nCol2 - 30 SAY oSay7 PROMPT "Analise com Custo Padrão na Entrada do Pedido" FONT oFont16n SIZE 150, 24 OF oDlg COLORS 0, 16777215 PIXEL
@ 015, nCol3 - 30 SAY oSay9 PROMPT "Analise Com Custo Padrao Atual" FONT oFont16n SIZE 150, 24 OF oDlg COLORS 0, 16777215 PIXEL
@ 030, nCol2 SAY oSay7 PROMPT "$" SIZE 100, 024 OF oDlg COLORS 0, 16777215 PIXEL
@ 030, nCol2 + 60 SAY oSay7 PROMPT "%" SIZE 100, 024 OF oDlg COLORS 0, 16777215 PIXEL


//Primeira Coluna
@ 050, nCol1  SAY oSay10 PROMPT "(+) Receita de vendas (com IPI)" FONT oFont16n SIZE 150, 24 OF oDlg COLORS 0, 16777215 PIXEL
@ 060, nCol1  SAY oSay10 PROMPT "(-) IPI" SIZE 061, 024 OF oDlg COLORS 0, 16777215 PIXEL
@ 070, nCol1  SAY oSay10 PROMPT "(=) Receita de vendas (sem IPI)" FONT oFont16n SIZE 150, 24 OF oDlg COLORS 0, 16777215 PIXEL
@ 080, nCol1  SAY oSay10 PROMPT "(-) Custo de Reposição (Sem Impostos Recuperaveis)" SIZE 150, 024 OF oDlg COLORS 0, 16777215 PIXEL
@ 090, nCol1  SAY oSay10 PROMPT "(=) Geração Bruta de Caixa" FONT oFont16n SIZE 150, 24 OF oDlg COLORS 0, 16777215 PIXEL
@ 110, nCol1  SAY oSay10 PROMPT "(-) Pis" SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
@ 120, nCol1  SAY oSay10 PROMPT "(-) Cofins" SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
@ 130, nCol1  SAY oSay10 PROMPT "(-) ICMS" SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
@ 140, nCol1  SAY oSay10 PROMPT "(-) ICMS Partilha" SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
@ 150, nCol1  SAY oSay10 PROMPT "(-) Despesas Financeiras" SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
@ 160, nCol1  SAY oSay10 PROMPT "(-) Custo de Frete" SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
@ 170, nCol1  SAY oSay10 PROMPT "(-) Custo de Palete" SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
@ 180, nCol1  SAY oSay10 PROMPT "(=) Margem"  FONT oFont16n SIZE 150, 50 OF oDlg COLORS 0, 16777215 PIXEL
@ 190, nCol1  SAY oSay10 PROMPT "(-) Comissão de vendas sem DSR"  SIZE 150, 50 OF oDlg COLORS 0, 16777215 PIXEL
@ 200, nCol1  SAY oSay10 PROMPT "(-) DSR sobre comissão de vendas"  SIZE 150, 50 OF oDlg COLORS 0, 16777215 PIXEL
@ 210, nCol1  SAY oSay10 PROMPT "(=) Comissão com DSR" FONT oFont16n SIZE 150, 50 OF oDlg COLORS 0, 16777215 PIXEL
@ 230, nCol1  SAY oSay10 PROMPT "(=) Resultado Financeiro" FONT oFont16n SIZE 150, 50 OF oDlg COLORS 0, 16777215 PIXEL

	/*
1//Receita de Vendas Com IPI
2//IPI
3//Receita de Vendas Sem IPI
4//Custo de reposição
5//Geração bruta de caixa
6//PIS
7//Cofins
8//ICMS
9//ICMS Partilha
10//Comissoes sem DSR
11//Despesas Financeiras
12//Frete
13//Resultado	
*/

  @ 050, nCol2 SAY oSay10 PROMPT Alltrim(Transform( aCol2[1,1], "@E 999,999,999,999.99" )) FONT oFont16n  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //Receita de vendas (com IPI)
	@ 060, nCol2 SAY oSay10 PROMPT Alltrim(Transform( aCol2[2,1], "@E 999,999,999,999.99" ))  SIZE 061, 024 OF oDlg COLORS 0, 16777215 PIXEL // IPI
	@ 070, nCol2 SAY oSay10 PROMPT Alltrim(Transform( aCol2[3,1], "@E 999,999,999,999.99" ))  FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL // Receita de vendas (sem IPI)
	@ 080, nCol2 SAY oSay10 PROMPT Alltrim(Transform( aCol2[4,1], "@E 999,999,999,999.99" ))  SIZE 150, 024 OF oDlg COLORS 0, 16777215 PIXEL //Custo de Reposição (Sem Impostos Recuperaveis)
	@ 090, nCol2 SAY oSay10 PROMPT Alltrim(Transform( aCol2[5,1], "@E 999,999,999,999.99" ))  FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //Geração Bruta de Caixa
	@ 110, nCol2 SAY oSay10 PROMPT Alltrim(Transform( aCol2[6,1], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //Pis
	@ 120, nCol2 SAY oSay10 PROMPT Alltrim(Transform( aCol2[7,1], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //cofins
	@ 130, nCol2 SAY oSay10 PROMPT Alltrim(Transform( aCol2[8,1], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //ICMS
	@ 140, nCol2 SAY oSay10 PROMPT Alltrim(Transform( aCol2[9,1], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //ICMS PARTILHA
	@ 150, nCol2 SAY oSay10 PROMPT Alltrim(Transform( aCol2[10,1], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //DESPESAS FINANCEIRAS
	@ 160, nCol2 SAY oSay10 PROMPT Alltrim(Transform( aCol2[11,1], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //CUSTO DE FRETE
	@ 170, nCol2 SAY oSay10 PROMPT Alltrim(Transform( aCol2[12,1], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //CUSTO DE Palete
	@ 180, nCol2 SAY oSay10 PROMPT Alltrim(Transform( aCol2[13,1], "@E 999,999,999,999.99" ))  FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //Margem
	@ 190, nCol2 SAY oSay10 PROMPT Alltrim(Transform( aCol2[14,1], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //Comissão s DSR
	@ 200, nCol2 SAY oSay10 PROMPT Alltrim(Transform( aCol2[15,1], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //DSR
	@ 210, nCol2 SAY oSay10 PROMPT Alltrim(Transform( aCol2[16,1], "@E 999,999,999,999.99" ))  FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //Comissão c DSR
	@ 230, nCol2 SAY oSay10 PROMPT Alltrim(Transform( aCol2[17,1], "@E 999,999,999,999.99" ))  FONT oFont16n  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //RESULTADO FINANCEIRO
	
	@ 070, nCol2 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol2[3,2], "@E 999,999,999,999.99" ))  FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL	//Custo de Reposição (Sem Impostos Recuperaveis)
	@ 080, nCol2 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol2[4,2], "@E 999,999,999,999.99" ))  SIZE 150, 024 OF oDlg COLORS 0, 16777215 PIXEL	//Custo de Reposição (Sem Impostos Recuperaveis)
	@ 090, nCol2 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol2[5,2], "@E 999,999,999,999.99" ))  FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL	//geração bruta de caixa
	@ 230, nCol2 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol2[17,2], "@E 999,999,999,999.99" ))  FONT oFont16n  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //RESULTADO FINANCEIRO
	@ 110, nCol2 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol2[6,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL	//pis
	@ 120, nCol2 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol2[7,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL	//cofins
	@ 130, nCol2 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol2[8,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL	//ICMS
	@ 140, nCol2 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol2[9,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL	//ICMS PARTILHA
	@ 150, nCol2 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol2[10,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL	//DESPESAS FINANCEIRAS
	@ 160, nCol2 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol2[11,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL	//CUSTO DE FRETE
	@ 170, nCol2 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol2[12,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL	//CUSTO DE Palete
	@ 180, nCol2 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol2[13,2], "@E 999,999,999,999.99" ))  FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //Margem
	@ 190, nCol2 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol2[14,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //Comissão s DSR
	@ 200, nCol2 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol2[15,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //DSR
	@ 210, nCol2 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol2[16,2], "@E 999,999,999,999.99" ))  FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //Comissão c DSR


	//Terceira coluna
    @ 050, nCol3 SAY oSay10 PROMPT Alltrim(Transform( aCol3[1,1], "@E 999,999,999,999.99" )) FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 060, nCol3 SAY oSay10 PROMPT Alltrim(Transform( aCol3[2,1], "@E 999,999,999,999.99" ))  SIZE 061, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 070, nCol3 SAY oSay10 PROMPT Alltrim(Transform( aCol3[3,1], "@E 999,999,999,999.99" ))  FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 080, nCol3 SAY oSay10 PROMPT Alltrim(Transform( aCol3[4,1], "@E 999,999,999,999.99" ))  SIZE 150, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 090, nCol3 SAY oSay10 PROMPT Alltrim(Transform( aCol3[5,1], "@E 999,999,999,999.99" ))  FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 110, nCol3 SAY oSay10 PROMPT Alltrim(Transform( aCol3[6,1], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 120, nCol3 SAY oSay10 PROMPT Alltrim(Transform( aCol3[7,1], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 130, nCol3 SAY oSay10 PROMPT Alltrim(Transform( aCol3[8,1], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 140, nCol3 SAY oSay10 PROMPT Alltrim(Transform( aCol3[9,1], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 150, nCol3 SAY oSay10 PROMPT Alltrim(Transform( aCol3[10,1], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 160, nCol3 SAY oSay10 PROMPT Alltrim(Transform( aCol3[11,1], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 170, nCol3 SAY oSay10 PROMPT Alltrim(Transform( aCol3[12,1], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 180, nCol3 SAY oSay10 PROMPT Alltrim(Transform( aCol3[13,1], "@E 999,999,999,999.99" ))  FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //Margem
	@ 190, nCol3 SAY oSay10 PROMPT Alltrim(Transform( aCol3[14,1], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //Comissão s DSR
	@ 200, nCol3 SAY oSay10 PROMPT Alltrim(Transform( aCol3[15,1], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //DSR
	@ 210, nCol3 SAY oSay10 PROMPT Alltrim(Transform( aCol3[16,1], "@E 999,999,999,999.99" )) FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //Comissão c DSR
	@ 230, nCol3 SAY oSay10 PROMPT Alltrim(Transform( aCol3[17,1], "@E 999,999,999,999.99" ))  FONT oFont16n  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //RESULTADO FINANCEIRO

	@ 070, nCol3 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol3[3,2], "@E 999,999,999,999.99" ))  FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 080, nCol3 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol3[4,2], "@E 999,999,999,999.99" ))  SIZE 150, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 090, nCol3 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol3[5,2], "@E 999,999,999,999.99" ))  FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 110, nCol3 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol3[6,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 120, nCol3 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol3[7,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 130, nCol3 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol3[8,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 140, nCol3 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol3[9,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 150, nCol3 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol3[10,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 160, nCol3 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol3[11,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 170, nCol3 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol3[12,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 180, nCol3 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol3[13,2], "@E 999,999,999,999.99" ))  FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //Margem
	@ 190, nCol3 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol3[14,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //Comissão s DSR
	@ 200, nCol3 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol3[15,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //DSR
	@ 210, nCol3 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol3[16,2], "@E 999,999,999,999.99" )) FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //Comissão c DSR
	@ 230, nCol3 + 60 SAY oSay10 PROMPT Alltrim(Transform( aCol3[17,2], "@E 999,999,999,999.99" ))  FONT oFont16n  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //RESULTADO FINANCEIRO	
ACTIVATE MSDIALOG oDlg CENTERED

SCK->(DbGoTo(nLinha))
Return

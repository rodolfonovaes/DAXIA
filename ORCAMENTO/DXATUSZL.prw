#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#include "FWMVCDEF.CH"
#INCLUDE "MATXDEF.CH"
User Function DXATUSZL()

Processa({|| Processo()},"Processando Registros","Atualizando historico , Aguarde...")

Return

Static Function Processo()
Local aDadosIt    := {}
Local nMargem    := 0
Local nItens     := 0
Local cItem     := '01'
Local aArea      := GetArea()
Local nItens    := 0
Local lReclock  := .T.
Local cQuery    := ''
Local cAliasQry := GetNextAlias()
Private nRecTMP1	:= 0
Private	nSeleciona	:= 0
Private dDataEft    := STOD(' ')


cQuery := "	SELECT R_E_C_N_O_ AS REC " 
cQuery += " FROM " + RetSqlName( "SCJ" ) + " SCJ "
cQuery += " WHERE SCJ.D_E_L_E_T_ = ' ' AND  "
cQuery += "		SCJ.CJ_FILIAL =  '" +  xFilial('SCJ') + "' AND CJ_STATUS = 'B' AND " 
cQuery += "     SCJ.CJ_FILIAL + CJ_NUM NOT IN "	  		
cQuery += "     (SELECT ZL_FILIAL + ZL_NUM FROM SZL010 WHERE D_E_L_E_T_ = ' ') "	  		

ProcRegua(12687)

If Select(cAliasQry) > 0
    (cAliasQry)->(DbCloseArea())
EndIf

SCK->(DbSetOrder(1))
TcQuery cQuery new Alias ( cAliasQry )
While !(cAliasQry)->(Eof())	
	IncProc()
	nSeleciona	:= 0
	cItem     := '01'
    SCJ->(DbGoTo((cAliasQry)->REC))
    SCK->(DbSeek(xFilial('SCK') + SCJ->CJ_NUM))
    While SCJ->(CJ_FILIAL + CJ_NUM ) == SCK->(CK_FILIAL+ CK_NUM)
        If !Val(SCK->CK_XMOTIVO) > 1
            nSeleciona++

            nRecTMP1 := SCK->(Recno())
            dDataEft :=  retdata()
            aDadosIt := Rentab('ITATUAL')
            SZL->(DbSetOrder(1))
            If !SZL->(DbSeek(xFilial('SZL') + SCJ->CJ_NUM + cItem + SCK->CK_PRODUTO ))
                Reclock('SZL',.T.)
                SZL->ZL_FILIAL  := xFilial('SZL')
                SZL->ZL_NUM     := SCJ->CJ_NUM
                SZL->ZL_ITEM     := cItem 
                SZL->ZL_PRODUTO  := SCK->CK_PRODUTO 
                SZL->ZL_DATA    := dDataEft
                SZL->ZL_TIPO    := '1' //efetivação
                SZL->ZL_RECEITA := aDadosIt[1,1]
                SZL->ZL_IPI     := aDadosIt[2,1]
                SZL->ZL_RECSIPI := aDadosIt[3,1]
                SZL->ZL_CUSTD   := aDadosIt[4,1]
                SZL->ZL_GBRTCX  := aDadosIt[5,1]
                SZL->ZL_PIS     := aDadosIt[6,1]
                SZL->ZL_COFINS  := aDadosIt[7,1]
                SZL->ZL_ICMS    := aDadosIt[8,1]
                SZL->ZL_ICMSP   := aDadosIt[9,1]
                SZL->ZL_DESPFIN := aDadosIt[10,1]
                SZL->ZL_FRETE   := aDadosIt[11,1]
                SZL->ZL_COMIS   := aDadosIt[14,1]
                SZL->ZL_DSR     := aDadosIt[15,1]
                SZL->ZL_RESULT  := aDadosIt[17,1]
                SZL->ZL_PPIS    := aDadosIt[6,2]
                SZL->ZL_PCOFINS := aDadosIt[7,2]
                SZL->ZL_PICMS   := aDadosIt[8,2]
                SZL->ZL_PICMSP  := aDadosIt[9,2]
                SZL->ZL_PCOMIS  := aDadosIt[14,2]
                SZL->ZL_PDESPFI := aDadosIt[10,2]
                SZL->ZL_PALET   := aDadosIt[12,1]
                SZL->ZL_PFRETE  := ROUND(aDadosIt[11,2],6)
                SZL->ZL_PDSR    := aDadosIt[15,2]   
                MsUnlock()
                cItem := Soma1(cItem)  
				aDadosIt := {}  
            EndIf 
        EndIf
        SCK->(DbSkip())
    EndDo
    (cAliasQry)->(DbSkip())
EndDo
alert('foi!')
Return



Static Function Rentab(cTipo)
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
Local nPCustFin		:= 2// SupergetMV('ES_CUSTFIN',.T.,2.5)
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
Local nTMP1Bkp		:= 0


SE4->(DbSetOrder(1)) //--E4_FILIAL+E4_CODIGO
SE4->(DbSeek(FwxFilial('SE4')+cCondPag))

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
SCK->(DbSeek(xFilial('SCK') + SCJ->CJ_NUM))
While SCJ->(CJ_FILIAL + CJ_NUM ) == SCK->(CK_FILIAL+ CK_NUM)
	//IF !TMP1->CK_FLAG //.And. !Val(TMP1->CK_XMOTIVO) > 1
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
				//AQUI INCLUIR A BUSCA NA SZ4
				nPrcVen			:= xMoeda(RetCusto(),nMoedaC,1,dDataEft,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDataEft,'M2_MOEDA2')) * nQtdVen //transformo em real
				nPrcLista		:= nPrcVen
				nNegociado		:= SCK->CK_PRCVEN * SCK->CK_QTDVEN
				nVlrBase		:= xMoeda(SCK->CK_PRCVEN,VAL(SCK->CK_MOEDA),1,dDataEft,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDataEft,'M2_MOEDA2')) * SCK->CK_QTDVEN//transformo em real
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
			//nPrcVen			:= TMP1->CK_PRCVEN	* nQtdVen//xMoeda(DA1->DA1_XCUSTD,nMoedaC,nMoedaV,dDataEft,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDataEft,'M2_MOEDA2'))
			nPrcVen			:= xMoeda(nPrcVen,nMoedaC,1,dDataEft,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDataEft,'M2_MOEDA2')) 
			nPrcLista		:= nPrcVen			
			nPrcLista := nPrcVen
			nNegociado		:= SCK->CK_PRCVEN * SCK->CK_QTDVEN
			nVlrBase		:= xMoeda(SCK->CK_PRCVEN,VAL(SCK->CK_MOEDA),1,dDataEft,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDataEft,'M2_MOEDA2')) * SCK->CK_QTDVEN //transformo em real
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
				nPrcVen			:= xMoeda(RetCusto(),nMoedaC,1,dDataEft,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDataEft,'M2_MOEDA2')) * nQtdVen //transformo em real
				nPrcLista		:= nPrcVen	
				nNegociado		:= SCK->CK_PRCVEN * SCK->CK_QTDVEN
				nVlrBase		:= xMoeda(SCK->CK_PRCVEN,VAL(SCK->CK_MOEDA),1,dDataEft,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDataEft,'M2_MOEDA2')) * SCK->CK_QTDVEN//transformo em real
				Aadd(aItens,{SCK->(Recno()),nPrcVen,nNegociado})
			EndIf
		ElseIF cTipo $ 'ITORIG|ITATUAL'
		//	While nSeleciona <> Val(TMP1->CK_ITEM)
		//		TMP1->(DbSkip())
	//		EndDo
			cCodProd 	:= 	SCK->CK_PRODUTO
			nQtdVen 	:=  SCK->CK_QTDVEN	

			DbSelectArea('SZL')	
			SZL->(DbSetOrder(1))
			If cTipo == 'ITORIG' 
				//nTMP1Bkp := SCK->(Recno())
				//SCK->(DbGoTo(nRecTMP1))
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
				//SCK->(dbGoTo(nTMP1Bkp))
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
				//nPrcVen			:= TMP1->CK_PRCVEN	* nQtdVen//xMoeda(DA1->DA1_XCUSTD,nMoedaC,nMoedaV,dDataEft,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDataEft,'M2_MOEDA2'))
				nPrcLista			:= xMoeda(RetCusto(),val(SCK->CK_MOEDA),1,dDataEft,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDataEft,'M2_MOEDA2')) * nQtdVen //converto para real
				nPrcVen				:= nPrcLista
				nNegociado			:= SCK->CK_PRCVEN * SCK->CK_QTDVEN
				nVlrBase			:= xMoeda(SCK->CK_PRCVEN,VAL(SCK->CK_MOEDA),1,dDataEft,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDataEft,'M2_MOEDA2')) * SCK->CK_QTDVEN //transformo em real
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
	//EndIf
	SCK->(DbSkip())
EndDo


SCK->(DbSeek(xFilial('SCK') + SCJ->CJ_NUM))
While SCJ->(CJ_FILIAL + CJ_NUM ) == SCK->(CK_FILIAL+ CK_NUM)
	IF  Len(aItens) > 0 //.And. !Val(TMP1->CK_XMOTIVO) > 1
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

		nNegociado 	:= xMoeda(nNegociado,VAL(SCK->CK_MOEDA),1,dDataEft,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDataEft,'M2_MOEDA2')) //converto pra real

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
		//nMgLiq		:= nNegociado - nVlrPis - nVlrCof - nVlrIcm - nDifal - TMP1->CK_XVLFRET - TMP1->CK_XPALET - nDespFin
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
					nComis		+= nNegociado * (SA3->A3_COMIS / 100)
				Else
					nComis		+= nNegociado * (RetComis(nPMgLiq,SCK->CK_PRODUTO) / 100)
				EndIf
			EndIf

			
		ElseIf cTipo $ '2|3|4'
			If SB1->B1_XCOMIS == '2'
				//TMP1->CK_COMIS1 := SB1->B1_COMIS
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
		If SZD->(DbSeek(xFilial('SZD') + Alltrim(Str(year(dDataEft))) + PadL(Alltrim(STR(Month(dDataEft))),2,'0')))
			nPDsr		:= SZD->ZD_PDSR / 100
		EndIf

		If SA3->A3_XTIPO <> '2'
			nPDsr := RetComis(nPMgLiq,SCK->CK_PRODUTO) * nPDsr
			nDsr += nNegociado * (nPDsr / 100)
		Else
			nPDsr	:= 0
			nDsr	:= 0
		EndIf
		//TMP1->CK_COMIS1  := RetComis(nPMgLiq)  
		
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
SCK->(DbGoTo(nRecTMP1))
Return aRet



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



Static Function retdata()
Local dData := STOD(' ')
Local cQuery	:= ''
Local cAliasQry := GetNextAlias()

cQuery := "SELECT C5_EMISSAO "
cQuery += "  FROM " + RetSQLTab('SC5')
cQuery += "  WHERE  "
cQuery += "  C5_FILIAL = '" + xFilial('SC5') + "' AND C5_XNUMCJ = '" + SCK->CK_NUM + "'  "
cQuery += "  AND D_E_L_E_T_ = ' '"

TcQuery cQuery new Alias ( cAliasQry )

(cAliasQry)->(dbGoTop())

If !(cAliasQry)->(EOF())
	dData := STOD((cAliasQry)->C5_EMISSAO)
EndIf

(cAliasQry)->(DbCloseArea())

Return dData


Static Function RetCusto()
Local nRet := 0
Local cQuery	:= ''
Local cAliasQry := GetNextAlias()

cQuery := "SELECT Z4_CHOMOLO "
cQuery += "  FROM " + RetSQLTab('SZ4')
cQuery += "  WHERE  "
cQuery += "  Z4_FILIAL = '" + xFilial('SZ4') + "' AND Z4_DATA <= '" + DTOS(dDataEft) + "'  AND Z4_COD = '" + SCK->CK_PRODUTO + "' "
cQuery += "  AND D_E_L_E_T_ = ' ' AND Z4_DESCART <> 'S' "
cQuery += "  ORDER BY Z4_DATA DESC"

TcQuery cQuery new Alias ( cAliasQry )

(cAliasQry)->(dbGoTop())

If !(cAliasQry)->(EOF())
	nRet := (cAliasQry)->Z4_CHOMOLO
EndIf

(cAliasQry)->(DbCloseArea())

Return nRet


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


User Function AXCADZZD()
AxCadastro('ZZD','Cadastro de Categorias')
Return
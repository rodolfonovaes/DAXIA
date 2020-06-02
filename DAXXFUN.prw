#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#include "FWMVCDEF.CH"
#INCLUDE "MATXDEF.CH"
 /*/{Protheus.doc} DaxNmCli
    (long_description)
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
User FUnction DaxNmCli()
Local cRet  := ''
Local cCli  := ''
Local cLoja := ''
Local aArea := GetArea()

If IsInCallStack('A010CONSUL')
    SC5->(DbSetOrder(1))
    If SC5->(DbSeek(XFILIAL('SC5') + SC6->C6_NUM))
        cCli    := SC5->C5_CLIENTE
        cLoja   := SC5->C5_LOJACLI
    EndIf
ElseIf IsInCallStack('MATA416')
	cCli    := M->C5_CLIENTE
    cLoja   := M->C5_LOJACLI
Else
    If INCLUI
        cCli    := M->C5_CLIENTE
        cLoja   := M->C5_LOJACLI
    Else
        cCli    := SC5->C5_CLIENTE
        cLoja   := SC5->C5_LOJACLI
    EndIf
EndIf

If !Empty(cCli)
    cRet    := POSICIONE("SA1",1,XFILIAL("SA1")+cCli+cLoja,"A1_NOME")
EndIf
RestArea(aArea)
return cRet


User Function UsrTaxa()
Local lRet  := .F.
Local cUsers  := SupergetMV('ES_USRTXFI',.T.,'administrador|totvs.rnovaes')
Local cCodTab := SUPERGETMV('ES_DAXTAB',.T.,'001')

If POSICIONE('SE4',1,xFilial('SE4') + M->CJ_CONDPAG ,'E4_XTXFIX') == '1'.Or. at(UPPER(Alltrim(UsrRetName( retcodusr() ))),UPPER(cUsers)) > 0 
    If POSICIONE('DA1',1,xFilial('DA1') + cCodTab + ("TMP1")->CK_PRODUTO,'DA1_MOEDA') == 2 //dolar
        lRet := .T.
    EndIf
EndIf
Return lRet

User Function RetCot()
Local nCot := 0

dbselectarea('SM2')
SM2->(Dbsetorder(1))
If SM2->(DbSeek(DTOS(dDataBase)))
    nCot := SM2->M2_MOEDA2
EndIf

Return nCot

//Atualiza frete a partir do gatilho do CJ_XTRANSP
User Function RetFrete()
Local nValor    := 0
Local nLinha	:= TMP1->(Recno())
Local nVlKg		:= 0
Local nItens	:= 0
Local aArea		:= GetArea()
Local cVariavel	:= ReadVar()
Local nValDigit := M->CJ_XVLFRET
Local nTotQtd	:= 0

If !Empty(M->CJ_XTRANSP)
    SZ5->(DbSetOrder(1))
    If SZ5->(DbSeek(xFilial('SZ5') + cFilAnt + M->CJ_XTRANSP))
        nValor := SZ5->Z5_FRETE
    	nVlKg  := SZ5->Z5_VALOR
    EndIf
EndIf

dbSelectArea("TMP1")
dbGoTop()

While !Eof()
	If  !("TMP1")->CK_FLAG .And. !Val(TMP1->CK_XMOTIVO) > 1
		nItens++
		nTotQtd += TMP1->CK_QTDVEN
	EndIf
	("TMP1")->(DbSkip())
EndDo

dbSelectArea("TMP1")
dbGoTop()
IF !empty(("TMP1")->CK_PRODUTO)
	While !Eof()
		If (cVariavel == 'M->CJ_XVLFRET' .And.  !("TMP1")->CK_FLAG .And. !Val(TMP1->CK_XMOTIVO) > 1 ) .Or. (IsinCallStack('U_A415LIOK') .And. M->CJ_XTPFRET == '2') //Valor digitado na mão ou chamado na pos validação
			nValor := nValDigit
			TMP1->CK_XVLFRET := nValDigit * (TMP1->CK_QTDVEN / nTotQtd )
			U_ClcComis()
		Else
			If  !("TMP1")->CK_FLAG .And. !Val(TMP1->CK_XMOTIVO) > 1
				SB1->(dbSetOrder(1))
				If SB1->(DbSeek(xFilial('SB1') + ("TMP1")->CK_PRODUTO )) .And. SB1->B1_PESBRU > 0
					nValor += (("TMP1")->CK_QTDVEN * SB1->B1_PESBRU) * nVlKg
					TMP1->CK_XVLFRET := (SZ5->Z5_FRETE / nItens) + (("TMP1")->CK_QTDVEN * SB1->B1_PESBRU) * nVlKg
				EndIf
				U_ClcComis()
			EndIf
		EndIf
		("TMP1")->(DbSkip())
	EndDo
	
EndIf
TMP1->(DbGoTo(nLinha))
If M->CJ_XTPFRET <> '2'
	M->CJ_XVLFRETE := nValor
Else
	nValor	:= nValDigit
EndIf

GETDREFRESH()	   
oGetDad:Refresh()
RestArea(aArea)
Return nValor


User Function RetMoeda()
Local cRet := '1'

If POSICIONE('DA1',1,xFilial('DA1') + SUPERGETMV('ES_DAXTAB',.T.,'001',cFilAnt) + ("TMP1")->CK_PRODUTO,'DA1_MOEDA') == 2
    cRet := '2'
EndIf

Return cRet


User Function UpdDA1()
Local cQuery := ''
Local cAliasQry := GetNextAlias()

cQuery := "SELECT DA1.R_E_C_N_O_ AS REC "
cQuery += "  FROM " + RetSQLTab('SB1')
cQuery += "  INNER JOIN " + RetSQLTab('DA1') + " ON B1_COD = DA1_CODPRO AND DA1_FILIAL = '" + xFilial('DA1') + "' "
cQuery += "  WHERE  "
cQuery += "  B1_FILIAL = '" + xFilial('SB1') + "' AND B1_XMOEDA = '2'  "
cQuery += "  AND SB1.D_E_L_E_T_ = ' '"
cQuery += "  AND DA1.D_E_L_E_T_ = ' '"

TcQuery cQuery new Alias ( cAliasQry )

(cAliasQry)->(dbGoTop())

If !(cAliasQry)->(EOF())
    While(!(cAliasQry)->(EOF()))
        DA1->(DbGoTo((cAliasQry)->REC))
        Reclock('DA1',.F.)
        DA1->DA1_MOEDA := 2
        //TODO VALIDAR COM O DANIEL SE EH SOH ISSO
        MsUnlock()
        (cAliasQry)->(DbSkip())
    EndDo
EndIf
(cAliasQry)->(DbCloseArea())
Return


User Function CpyDA1()
Local bCampo      := {|x| FieldName(x)}
local cNewTab	  := GETSX8NUM("DA0","DA0_CODTAB")        
local cOldTab     := DA0->DA0_CODTAB
local nCountA	  := 1
local nCountB	  := 1
Local cAliasQry   := GetNextAlias()
Local aParam      := {}
Local aRet        := {}
local cCpoDA0	:= ' '
local cCpoDA1	:= ' '
Local cFilBkp   := cFilAnt

aAdd(aParam, {1, "Filial Destino"   , CriaVar('DA0_FILIAL',.F.) ,  ,, 'SM0',, 60, .F.} )

If ParamBox(aParam,'Parâmetros',aRet)

    for nCountA := 1 to DA0->(Fcount())
        if nCountA < DA0->(Fcount())
            cCpoDA0 += DA0->(FieldName(nCountA)) + ' , '
        else
            cCpoDA0 += DA0->(FieldName(nCountA))
        endif
    next

    for nCountA := 1 to DA1->(Fcount())
        if nCountA < DA1->(Fcount())
            cCpoDA1 += DA1->(FieldName(nCountA)) + ' , '
        else
            cCpoDA1 += DA1->(FieldName(nCountA))
        endif
    next    

	cQuery := "	SELECT " + cCpoDA0
	cQuery += " FROM " + RetSqlName( "DA0" ) + " DA0 "
	cQuery += " WHERE DA0.D_E_L_E_T_ = ' ' AND "
	cQuery += "		DA0.DA0_FILIAL =  '" +  xFilial('DA0') + "' AND " 
	cQuery += "     DA0.DA0_CODTAB =  '" + cOldTab + "'	"	  		


    If Select(cAliasQry) > 0
        (cAliasQry)->(DbCloseArea())
    EndIf

    TcQuery cQuery new Alias ( cAliasQry )

   begin transaction
    if !(cAliasQry)->(Eof())	
        cFilAnt := aRet[1]

        RecLock('DA0', .T.)
        For nCountA := 1 To DA0->(FCount())
            if DA0->(Eval(bCampo, nCountA)) == 'DA0_CODTAB'
                DA0->DA0_CODTAB := cNewTab
            Elseif DA0->(Eval(bCampo, nCountA)) == 'DA0_FILIAL'
                DA0->DA0_FILIAL := xFilial('DA0')                
            else
                if (cAliasQry)->(Eval(bCampo, nCountA)) == DA0->(Eval(bCampo, nCountA))
                    DA0->(FieldPut(nCountA,(cAliasQry)->&(Eval(bCampo, nCountA))))
                endif
            endif
        Next nCountA
        msunlock()
    Else
        Alert('Erro na gravação!')
        Disarmtransaction()
        Return
    endif

	cQuery := "	SELECT " + cCpoDA1
	cQuery += " FROM " + RetSqlName( "DA1" ) + " DA1 "
	cQuery += " WHERE DA1.D_E_L_E_T_ = ' ' AND "
	cQuery += "		DA1.DA1_FILIAL =  '" +  xFilial('DA1') + "' AND " 
	cQuery += "     DA1.DA1_CODTAB =  '" + cOldTab + "'	"	  		

    If Select(cAliasQry) > 0
        (cAliasQry)->(DbCloseArea())
    EndIf

    TcQuery cQuery new Alias ( cAliasQry )

    if !(cAliasQry)->(Eof())	
        While !(cAliasQry)->(Eof())	
            RecLock('DA1', .T.)
            For nCountA := 1 To DA1->(FCount())
                if DA1->(Eval(bCampo, nCountA)) == 'DA1_CODTAB'
                    DA1->DA1_CODTAB := cNewTab
                Elseif DA1->(Eval(bCampo, nCountA)) == 'DA1_FILIAL'
                    DA1->DA1_FILIAL := xFilial('DA1')                       
                else
                    if (cAliasQry)->(Eval(bCampo, nCountA)) == DA1->(Eval(bCampo, nCountA))
                        DA1->(FieldPut(nCountA,(cAliasQry)->&(Eval(bCampo, nCountA))))
                    endif
                endif
            Next nCountA
            msunlock()
            (cAliasQry)->(DbSkip())
        EndDo
    endif
    ConfirmSX8()
    End transaction

    cFilAnt := cFilBkp
    MsgInfo('Tabela copiada com sucesso!')
EndIf


Return


User Function DA1LOG()
Local cCampo    := ''
Local cCmpSZ6   := ''
Local nCountA   := 0
Local aArea     := GetArea()
Local cTabela   := DA0->DA0_CODTAB


DA1->(DbSetOrder(1))
If DA1->(DbSeek(xFilial('DA1') + cTabela))
    While xFilial('DA1') + cTabela == DA1->(DA1_FILIAL + DA1_CODTAB)
        Reclock('SZ6',.T.)
        SZ6->Z6_FILIAL  := xFilial('SZ6')
        SZ6->Z6_DATA := dDataBase
        SZ6->Z6_HORA    := Substr(Time(),1,5)
        SZ6->Z6_USER    := UsrRetName(RetCodUsr())

        For nCountA := 1 to DA1->(Fcount())
            cCampo := DA1->(FieldName(nCountA))
            cCmpSZ6 := StrTran(cCampo,'DA1_','Z6_')

            If FieldPos(cCmpSZ6) > 0
                SZ6->&(cCmpSZ6) := DA1->&(cCampo)
            EndIf
        Next

        MsUnlock()
        DA1->(DbSkip())
    EndDo
EndIf
RestArea(aArea)
Return



User Function CalcPrc()
Local nValor := 0
Local oModel    := FWModelActive()
Local oDetail   := oModel:GetModel("DA1DETAIL")
Local nMargem   := oDetail:GetValue('DA1_XMARG') 
Local nBase     := oDetail:GetValue("DA1_PRCBAS")
If nMargem > 0 .And. nBase > 0 
    nValor  := Round(((nMargem / 100) + 1 ) * nBase,2)
EndIF

Return nValor


User Function DaxImp(cAlias, nValOld,aPrcIcm,cProduto)

Local nItem       := 0
Local nQtdPeso    := 0
Local nValMerc    := 0
Local nValDesc    := 0
Local nPrcLista   := 0
Local nPrcVen     := 0
Local nAcresFin   := 0
Local nDesconto   := 0
Local aRet        := {}
Local aArea       := GetArea()
Local aAreaSA1    := SA1->(GetArea())
Local aAreaSC5    := SC5->(GetArea())
Local aAreaSC6    := SC6->(GetArea())
Local nQtdVen     := 0
Local cTES        := SupergetMV('ES_TESPAD',.T.,'')
Local lContinua   := .F.

Local nFrete 	:= 0
Local nExcecoes	:= 0
Local nSeguro	:= 0
Local nFrtAut	:= 0
Local nDespes	:= 0
Local nPdescab	:= 0
Local nDescont	:= 0

Local nCustFin	:= 0
Local nPCustFin	:= SupergetMV('ES_CUSTFIN',.T.,2.5)
Local nRet		:= 0

Local cCodProd  := ""
Local nValProd  := 0
Local cCodCli   := ""
Local cLoja     := ""
Local cCliEntr  := ""
Local cLojaEntr := ""
Local cCondPag  := ""
Local nAliqICM  := 0
Local nAliqPIS  := 0
Local nAliqCOF  := 0
Local nAliqIPI  := 0
Local nAliqST   := 0
Local nVlrPis	:= 0
Local nVlrCof	:= 0
Local nVlrIcm	:= 0
Local nIpi		:= 0

Local nPProduto	 := 0
Local nPTes		 := 0
Local nPItem	 := 0
Local nPQtdVen	 := 0
Local nPValor	 := 0
Local nPPrj		 := 0
Local nPTsk		 := 0
Local nPEDT		 := 0
Local nPQtdLib	 := 0
Local nPContrat  := 0
Local nPItemCon  := 0
Local nPNfOrig   := 0
Local nPSerOrig  := 0
Local nPItOrig   := 0
Local nPNumOrc   := 0
Local nPReserva  := 0
Local nPLocal    := 0
Local nPPrcVen   := 0
Local nVlrSt	 := 0
Local nPPrUnit   := 0
Local nPLoteCtl 	:= 0 
Local nPNumLote 	:= 0 
Local lIpi 		 	:= SupergetMV('ES_CALCIPI',.T.,.F.)
Local lIcms		 	:= SupergetMV('ES_CALCICM',.T.,.F.)
Local lPis 		 	:= SupergetMV('ES_CALCPIS',.T.,.F.)
Local lCof 		 	:= SupergetMV('ES_CALCCOF',.T.,.F.)
Local lIcmsSt		:= SupergetMV('ES_CALCST',.T.,.F.)
Local cCliPad		:= SupergetMV('ES_CLIPAD',.T.,'')
Local cMoeda		:= 'R$ '
Local cMCustd		:= 'R$ '
Local nMoedaC		:= 1
Local nMoedaV		:= 1
Local oModel		
Local oMdlDA1
Local nMargem		:= 0
Local nDifal		:= 0
Local nAliqDif		:= 0
Local nSuframa		:= 0
Local cQuery		:= ''
Local cAliasQry		:= GetNextAlias()
Local cClasFis		:= ''
Local nAliqFecp		:= 0 
Local nMgLiq		:= 0
Local nPMgLiq		:= 0
Default nValOld		:= 0

Default cAlias    := 'SCJ'

If cAlias == 'DA1'
	oModel	:= FWModelActive()
	oMdlDA1 := oModel:GetModel('DA1DETAIL')

	SA1->(DbSetOrder(1))
	SA1->(DbSeek(xFilial('SA1') + cCliPad))
    cCodCli   := SA1->A1_COD
    cLoja     := SA1->A1_LOJA
    cCliEntr  := SA1->A1_COD
    cLojaEntr := SA1->A1_LOJA
    cCondPag  := oModel:GetModel('DA0MASTER'):GetValue('DA0_CONDPG')
	nMargem	  := oMdlDA1:GetValue('DA1_XMARG')
	nItem		:= 1
ElseIf cAlias == 'SCJ' .And. !ISINCALLSTACK('OMSA010')
    cCodCli   := M->CJ_CLIENTE
    cLoja     := M->CJ_LOJA
    cCliEntr  := M->CJ_CLIENT
    cLojaEntr := M->CJ_LOJAENT
    cCondPag  := M->CJ_CONDPAG
	nItem		:= 1// Val(TMP1->CK_ITEM)
	U_ClearMot()
ElseIf cAlias == 'UPD' 
    cCodCli   := SCJ->CJ_CLIENTE
    cLoja     := SCJ->CJ_LOJA
    cCliEntr  := SCJ->CJ_CLIENT
    cLojaEntr := SCJ->CJ_LOJAENT
    cCondPag  := SCJ->CJ_CONDPAG
	nItem		:= 1// Val(TMP1->CK_ITEM)
ElseIf cAlias == 'SC5' .And. !ISINCALLSTACK('OMSA010')
    cCodCli   := M->C5_CLIENTE
    cLoja     := M->C5_LOJACLI
    cCliEntr  := M->C5_CLIENT
    cLojaEntr := M->C5_LOJAENT
    cCondPag  := M->C5_CONDPAG
	nItem		:= Val(aCols[n][aScan(aHeader,{|x| AllTrim(x[2]) == "C6_ITEM"})])
ElseIf cAlias == 'SIM'
    cCodCli   := MV_PAR01
    cLoja     := MV_PAR02
    cCliEntr  := MV_PAR01
    cLojaEntr := MV_PAR02
    cCondPag  := MV_PAR03
	nItem		:= 1
ElseIf cAlias == 'SBZ'
	SA1->(DbSetOrder(1))
	SA1->(DbSeek(xFilial('SA1') + cCliPad))
    cCodCli   := SA1->A1_COD
    cLoja     := SA1->A1_LOJA
    cCliEntr  := SA1->A1_COD
    cLojaEntr := SA1->A1_LOJA
    cCondPag  := '001'
	nItem		:= 1	
EndIf

SA1->(DbSetOrder(1)) //--A1_FILIAL+A1_COD+A1_LOJA
SA1->(DbSeek(FwxFilial('SA1')+If(Empty(cCliEntr) .And. Empty(cLojaEntr), cCliEntr + cLojaEntr, cCodCli + cLoja)))

SE4->(DbSetOrder(1)) //--E4_FILIAL+E4_CODIGO
SE4->(DbSeek(FwxFilial('SE4')+cCondPag))

//Incluso para ver se acaba com a zica de ficar carregando valor errado qdo muda de orçamento
MaFisSave()
MaFisEnd()
//
If !MaFisFound('NF')


	MaFisIni( cCodCli ,;		// 1-Codigo Cliente/Fornecedor
				cLoja ,;	// 2-Loja do Cliente/Fornecedor
				"C",;										// 3-C:Cliente , F:Fornecedor
				"N",;										// 4-Tipo da NF
				SA1->A1_TIPO,;							    // 5-Tipo do Cliente/Fornecedor
				NIL,;
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
EndIf

If cAlias == 'DA1'
	oModel	:= FWModelActive()
	oMdlDA1 := oModel:GetModel('DA1DETAIL')

	cCodProd 	:= oMdlDA1:GetValue('DA1_CODPRO')	
	nValOld		:= oMdlDA1:GetValue('DA1_PRCVEN')	
	nQtdVen 	:= 1

	If !empty(cCondPag) 
	/*	If Valtype(oMdlDA1:GetValue('DA1_XCUSTD')	) == 'N' .And. oMdlDA1:GetValue('DA1_XCUSTD') > 0
			nPRcVen	 := oMdlDA1:GetValue('DA1_XCUSTD')
			nPrcLista 	:= oMdlDA1:GetValue('DA1_XCUSTD')	
		Else	
			nPrcVen	:= POSICIONE('SBZ',1,xFilial('SBZ')+cCodProd,'BZ_CUSTD')
			nPrcLista	:= POSICIONE('SBZ',1,xFilial('SBZ')+cCodProd,'BZ_CUSTD')
		EndIf*/

		SBZ->(DbSetOrder(1)) //--B1_FILIAL+B1_COD
		SBZ->(DbSeek(FwxFilial('SBZ')+cCodProd))

		If SBZ->BZ_MCUSTD == '2'
			cMCustd	:= 'U$ '
			nMoedaC	:= 2
		EndIf
		If oMdlDA1:GetValue('DA1_MOEDA') == 2
			cMoeda	:= 'U$ '
			nMoedaV	:= 2
		EndIf
		
		nPrcVen		:= xMoeda(DA1->DA1_XCUSTD,nMoedaC,nMoedaV,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2'))
		nPrcLista	:= nPrcVen
		nCustFin := RetCfin(cCondPag,nPCustFin)
		lContinua 	:= .T.	
	EndIf	

	nValMerc  	:= nPrcVen * nQtdVen
	nValDesc	:= 0
	
	
ElseIf cAlias == 'SCJ'
	nSeguro		:= M->CJ_SEGURO
	nFrtAut		:= M->CJ_FRETAUT
	nDespes		:= M->CJ_DESPESA
	nPdescab	:= M->CJ_PDESCAB
	nDescont	:= M->CJ_DESCONT	
	
	cCodProd 	:= TMP1->CK_PRODUTO	
	nValOld		:= TMP1->CK_PRUNIT	

	SB1->(DbSetOrder(1)) //--B1_FILIAL+B1_COD
	SB1->(DbSeek(FwxFilial('SB1')+cCodProd))

	If !Empty(M->CJ_XTPOPER)	
		TMP1->CK_OPER := M->CJ_XTPOPER
		TMP1->CK_TES  := MaTesInt(2,M->CJ_XTPOPER,M->CJ_CLIENTE,M->CJ_LOJA,"C",cCodProd,"CK_TES")                          
	EndIf

	//nQtdVen 	:= TMP1->CK_QTDVEN
	nQtdVen := 100 //tratamento pois o IT_DIFAL retorna somente 2 casas decimais, dando diferença no final do calculo
	If nQtdVen == 0
		nQtdVen := 1
	EndIf

	DA1->(DbSetOrder(1))
	If DA1->(DbSeek(xFilial('DA1') + SUPERGETMV('ES_DAXTAB',.T.,'001',cFilAnt) + cCodProd))	.And. !empty(cCondPag)
		SBZ->(DbSetOrder(1)) //--B1_FILIAL+B1_COD
		SBZ->(DbSeek(FwxFilial('SBZ')+cCodProd))

		If SBZ->BZ_MCUSTD == '2'
			cMCustd	:= 'U$ '
			nMoedaC	:= 2

		EndIF
		If DA1->DA1_MOEDA == 2
			cMoeda	:= 'U$ '
			nMoedaV	:= 2
			If ALLTRIM(POSICIONE('SE4',1,xFilial('SE4') + cCondPag , 'E4_COND')) == '00'
				TMP1->CK_XFIXA := 'S'
				TMP1->CK_XDTTX	:= dDataBase
				TMP1->CK_XTAXA	:= Posicione('SM2',1,dDataBase,'M2_MOEDA2')
			EndIf
		Else
			TMP1->CK_XFIXA := 'N'
			TMP1->CK_XDTTX	:= Stod(' ')
			TMP1->CK_XTAXA	:= 0
		EndIf

		
		nPrcVen		:= xMoeda(DA1->DA1_XCUSTD,nMoedaC,nMoedaV,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2'))
		nPrcLista		:= nPrcVen
		//nPRcVen	 := a415Tabela(cCodProd,M->CJ_TABELA,1)  
		nCustFin := RetCfin(cCondPag,nPCustFin)
		//nPrcLista 	:= a415Tabela(cCodProd,M->CJ_TABELA,1)   
		nMargem	  := DA1->DA1_XMARG
		cClasFis := TMP1->CK_CLASFIS
		lContinua 	:= .T.	
	Else
		Alert('Produto ' + Alltrim(Posicione('SB1',1,xFilial('SB1')  + cCodProd , 'B1_DESC'))+ ' sem valor cadastrado na tabela de preço!')
	EndIf	

	nValMerc  	:= nPrcVen * nQtdVen
	//nValMerc	:= A410Arred(xMoeda(DA1->DA1_XCUSTD,nMoedaC,1,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2')), 'D2_TOTAL')
	//nValMerc	:= nValMerc * TMP1->CK_QTDVEN
	cTES 		:= TMP1->CK_TES
	nValDesc	:= TMP1->CK_VALDESC
	//nExcecoes	:= TMP1->CK_XPALET
	//nFrete		:= TMP1->CK_XVLFRET
ElseIf cAlias == 'UPD' //ATUALIZA ORÇAMENTOS A PARTIR DA ATUALIZACAO DE PEDIDO DE VENDA
	nSeguro		:= SCJ->CJ_SEGURO
	nFrtAut		:= SCJ->CJ_FRETAUT
	nDespes		:= SCJ->CJ_DESPESA
	nPdescab	:= SCJ->CJ_PDESCAB
	nDescont	:= SCJ->CJ_DESCONT	
	
	cCodProd 	:= SCK->CK_PRODUTO	
	nValOld		:= SCK->CK_PRUNIT	

	SB1->(DbSetOrder(1)) //--B1_FILIAL+B1_COD
	SB1->(DbSeek(FwxFilial('SB1')+cCodProd))

	nQtdVen 	:= SCK->CK_QTDVEN

	DA1->(DbSetOrder(1))
	If DA1->(DbSeek(xFilial('DA1') + SUPERGETMV('ES_DAXTAB',.T.,'001',cFilAnt) + cCodProd))	.And. !empty(cCondPag)
		SBZ->(DbSetOrder(1)) //--B1_FILIAL+B1_COD
		SBZ->(DbSeek(FwxFilial('SBZ')+cCodProd))

		If SBZ->BZ_MCUSTD == '2'
			cMCustd	:= 'U$ '
			nMoedaC	:= 2

		EndIF
		If DA1->DA1_MOEDA == 2
			cMoeda	:= 'U$ '
			nMoedaV	:= 2
		EndIf
		
		nPrcVen		:= xMoeda(DA1->DA1_XCUSTD,nMoedaC,nMoedaV,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2'))
		nPrcLista		:= nPrcVen
		//nPRcVen	 := a415Tabela(cCodProd,M->CJ_TABELA,1)  
		nCustFin := RetCfin(cCondPag,nPCustFin)
		//nPrcLista 	:= a415Tabela(cCodProd,M->CJ_TABELA,1)   
		nMargem	  	:= DA1->DA1_XMARG
		cClasFis 	:= SCK->CK_CLASFIS
		lContinua 	:= .T.	
	EndIf	

	nValMerc  	:= nPrcVen * nQtdVen
	cTES 		:= SCK->CK_TES
	nValDesc	:= SCK->CK_VALDESC

ElseIf cAlias == 'SC5'
	nFrete 		:= M->C5_FRETE
	nSeguro		:= M->C5_SEGURO
	nFrtAut		:= M->C5_FRETAUT
	nDespes		:= M->C5_DESPESA
	nPdescab	:= M->C5_PDESCAB
	nDescont	:= M->C5_DESCONT
	
	nPProduto	 := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
	nPTes		 := aScan(aHeader,{|x| AllTrim(x[2])=="C6_TES"})
	nPItem	 	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEM"})
	nPQtdVen	 := aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN"})
	nPValor	 	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALOR"})
	nPPrj		 := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PROJPMS"})
	nPTsk		 := aScan(aHeader,{|x| AllTrim(x[2])=="C6_TASKPMS"})
	nPEDT		 := aScan(aHeader,{|x| AllTrim(x[2])=="C6_EDTPMS"})
	nPQtdLib	 := aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDLIB"})
	nPContrat  	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_CONTRAT"})
	nPItemCon  	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEMCON"})
	nPNfOrig   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_NFORI"})
	nPSerOrig  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_SERIORI"})
	nPItOrig   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEMORI"})
	nPNumOrc   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_NUMORC"})
	nPReserva  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_RESERVA"})
	nPLocal    := aScan(aHeader,{|x| AllTrim(x[2])=="C6_LOCAL"})
	nPPrcVen   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRCVEN"})
	nPPrUnit   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRUNIT"})	
	nPLoteCtl 	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_LOTECTL"})
	nPNumLote 	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_NUMLOTE"}) 

	cCodProd 	:= aCols[n][nPProduto]
	nValOld		:= aCols[n][nPPrcVen]
	//nPrcVen		:= A410Tabela(aCols[n][nPProduto],M->C5_TABELA,n,1/*aCols[n][nPQtdVen]*/,cCliEntr,cLojaEntr,If(nPLoteCtl>0,aCols[n][nPLoteCtl],""),If(nPNumLote>0,aCols[n][nPNumLote],"")	)

	
	DA1->(DbSetOrder(1))
	If DA1->(DbSeek(xFilial('DA1') + M->C5_TABELA + cCodProd))	.And. !empty(cCondPag)
		//nPrcVen		:= IIf(DA1->DA1_MOEDA == 2,xMoeda(DA1->DA1_PRCVEN,2,1,dDataBase,TamSx3("C6_PRCVEN")[2]),DA1->DA1_PRCVEN)8
		SBZ->(DbSetOrder(1)) //--B1_FILIAL+B1_COD
		SBZ->(DbSeek(FwxFilial('SBZ')+cCodProd))

		If SBZ->BZ_MCUSTD == '2'
			cMCustd	:= 'U$ '
			nMoedaC	:= 2
		EndIf
		//nPrcVen		:= IIf(DA1->DA1_MOEDA == 2,xMoeda(DA1->DA1_PRCVEN,2,1,dDataBase,TamSx3("C6_PRCVEN")[2]),DA1->DA1_PRCVEN)
		If DA1->DA1_MOEDA == 2
			cMoeda	:= 'U$ '
			nMoedaV	:= 2
		EndIf

		
		nPrcVen		:= xMoeda(DA1->DA1_XCUSTD,nMoedaC,nMoedaV,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2'))
		nPrcLista		:= nPrcVen
		nCustFin	:= RetCfin(cCondPag,nPCustFin)
		nMargem	  := DA1->DA1_XMARG
		lContinua 	:= .T.	
	Else
		Alert('Produto ' + Alltrim(Posicione('SB1',1,xFilial('SB1')  + cCodProd , 'B1_DESC'))+ ' sem valor cadastrado na tabela de preço!')	
	EndIf	
	
	//nPrcVen   	:= M->C6_PRCVEN	
	
	cTES 		:= aCols[n][aScan(aHeader,{|x| AllTrim(x[2]) == "C6_TES"})]
	nValDesc	:= aCols[n][aScan(aHeader,{|x| AllTrim(x[2]) == "C6_VALDESC"})]
	
	nValMerc  	:= nPRcVen
	nQtdVen 	:= 1//M->C6_QTDVEN

ElseIf cAlias == 'SIM'
	cCodProd 	:= MV_PAR05
	DA1->(DbSetOrder(1))
	if DA1->(DbSeek(xFilial('DA1') + DA0->DA0_CODTAB + cCodProd))
	
	
		SBZ->(DbSetOrder(1)) //--B1_FILIAL+B1_COD
		SBZ->(DbSeek(FwxFilial('SBZ')+cCodProd))

		If SBZ->BZ_MCUSTD == '2'
			cMCustd	:= 'U$ '
			nMoedaC	:= 2
		EndIf
		//nPrcVen		:= IIf(DA1->DA1_MOEDA == 2,xMoeda(DA1->DA1_PRCVEN,2,1,dDataBase,TamSx3("C6_PRCVEN")[2]),DA1->DA1_PRCVEN)
		If DA1->DA1_MOEDA == 2
			cMoeda	:= 'U$ '
			nMoedaV	:= 2
		EndIf

		nPrcVen		:= xMoeda(DA1->DA1_XCUSTD,nMoedaC,nMoedaV,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2'))
		//nPrcVen		:= DA1->DA1_XCUSTD
		nCustFin	:= RetCfin(cCondPag,nPCustFin)
		cTES 		:= MV_PAR04
		nValMerc  	:= nPRcVen
		nQtdVen 	:= 1//M->C6_QTDVEN
		nMargem	    := DA1->DA1_XMARG
		lContinua	:= .T.
	Else
		Alert('Produto ' + Alltrim(Posicione('SB1',1,xFilial('SB1')  + cCodProd , 'B1_DESC'))+ ' sem valor cadastrado na tabela de preço!')	
	EndIf
ElseIf cAlias == 'SBZ'
	If !ISINCALLSTACK('U_DAXJOB01')
		cCodProd 	:= M->BZ_COD
		If M->BZ_MCUSTD == '2'
			cMCustd	:= 'U$ '
			nMoedaC	:= 2
		EndIf			
	Else
		cCodProd	:= cProduto
		SBZ->(DbSetOrder(1))
		SBZ->(DbSeek(xFilial('SBZ') + cCodProd))

		If SBZ->BZ_MCUSTD == '2'
			cMCustd	:= 'U$ '
			nMoedaC	:= 2
		EndIf		
	EndIf
	SB1->(DbSetOrder(1)) //--B1_FILIAL+B1_COD
	SB1->(DbSeek(FwxFilial('SB1')+cCodProd))

	If SB1->B1_XMOEDVE == '2'
		cMoeda	:= 'U$ '
		nMoedaV	:= 2
	EndIf

	If !ISINCALLSTACK('U_DAXJOB01')
		nPrcVen		:= xMoeda(M->BZ_CUSTD,nMoedaC,nMoedaV,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2'))
		nMargem	    := M->BZ_MARKUP
	Else
		nPrcVen		:= xMoeda(SBZ->BZ_CUSTD,nMoedaC,nMoedaV,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2'))
		nMargem	    := SBZ->BZ_MARKUP
	EndIf
	nCustFin	:= RetCfin(cCondPag,nPCustFin)
	nValMerc  	:= nPRcVen
	nQtdVen 	:= 1
	
	lContinua	:= .T.

EndIf

If lContinua

	SB1->(DbSetOrder(1)) //--B1_FILIAL+B1_COD
	SB1->(DbSeek(FwxFilial('SB1')+cCodProd))
	
	SF4->(DbSeek(FwxFilial('SF4')+cTES))

	nAcresFin := A410Arred((nPrcVen*SE4->E4_ACRSFIN)/100, 'D2_PRCVEN')
	nValMerc  += A410Arred(nAcresFin*nQtdVen, 'D2_TOTAL')
	nDesconto := A410Arred(nPrcLista*nQtdVen, 'D2_DESCON') - nValMerc

	nDesconto := Max(0,nDesconto)
	nPrcLista += nAcresFin
	nValMerc  += nDesconto

	// ------------------------------------
	// AGREGA OS ITENS PARA A FUNCAO FISCAL
	// ------------------------------------
	MaFisAdd(	cCodProd,;  	    // 1-Codigo do Produto ( Obrigatorio )
			cTES,;	   	        // 2-Codigo do TES ( Opcional )
			nQtdVen,;  	        // 3-Quantidade ( Obrigatorio )
			nValMerc,;		  	// 4-Preco Unitario ( Obrigatorio )
			nDesconto,;  		// 5-Valor do Desconto ( Opcional )
			"",;	   			// 6-Numero da NF Original ( Devolucao/Benef )
			"",;				// 7-Serie da NF Original ( Devolucao/Benef )
			0,;					// 8-RecNo da NF Original no arq SD1/SD2
			0,;					// 9-Valor do Frete do Item ( Opcional )
			0,;					// 10-Valor da Despesa do item ( Opcional )
			0,;					// 11-Valor do Seguro do item ( Opcional )
			0,;					// 12-Valor do Frete Autonomo ( Opcional )
			nValMerc,;	// 13-Valor da Mercadoria ( Obrigatorio )
			0,;					// 14-Valor da Embalagem ( Opiconal )
			SB1->(Recno()),SF4->(Recno()) , , , , , , , , , , , ,;
			cClasFis) // 28-Classificacao fiscal)

	If !MaFisFound('NF')
		// ------------------------------------
		// CALCULO DO ISS
		// ------------------------------------
		
		If SA1->A1_INCISS == "N"
			If SF4->F4_ISS=="S"
				nPrcLista := a410Arred(nPrcLista/(1-(MaAliqISS(nItem)/100)), 'D2_PRCVEN')
				nValMerc  := a410Arred(nValMerc/(1-(MaAliqISS(nItem)/100)), 'D2_PRCVEN')
				MaFisAlt('IT_PRCUNI', nPrcLista, nItem)
				MaFisAlt('IT_VALMERC', nValMerc, nItem)
			EndIf
		EndIf

		// ------------------------------------
		// VERIFICA O PESO P/ CALCULO DO FRETE
		// ------------------------------------
		nQtdPeso := nQtdVen * SB1->B1_PESO

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
		
	EndIf

	//valor TOTAL com impostos de cada item
	nVlrIt  := MaFisRet(nItem,"IT_TOTAL")

	If lPis
		nVlrPis  := MaFisRet(nItem,"IT_VALPS2")
		nAliqPIS := MaFisRet(nItem,"IT_ALIQPS2")
	EndIf

	If lCof
		nVlrCof  := MaFisRet(nItem,"IT_VALCF2")
		nAliqCOF := MaFisRet(nItem,"IT_ALIQCF2")
	EndIf

	If nVlrPis == 0 .And. SF4->F4_CSTPIS <> '06'
		nVlrPis  := MaFisRet(nItem,"IT_VALPIS")
		nAliqPIS := MaFisRet(nItem,"IT_ALIQPIS")

		If nVlrPis == 0 .And. nAliqPIS > 0
			nVlrPis := ((nValMerc * nAliqPIS)/100)
		EndIf
	Endif

	If nVlrCof == 0 .And. lCof
		nVlrCof  := MaFisRet(nItem,"IT_VALCF2")
		nAliqCOF := MaFisRet(nItem,"IT_ALIQCF2")

		If  nVlrCof == 0 .And. nAliqCOF > 0
			nVlrCof := ((nValMerc * nAliqCOF)/100)
		EndIf

		If  nVlrCof == 0 .And. cAlias == 'SBZ'
			nVlrCof  := MaFisRet(nItem,"IT_VALCOF")
			nAliqCOF := MaFisRet(nItem,"IT_ALIQCOF")		
			nVlrCof := ((nValMerc * nAliqCOF)/100)
		EndIf		
	Endif

	nDifal 		:= MaFisRet(nItem,"IT_DIFAL")
	nAliqFecp	:= POSICIONE('CFC',1,xFilial('CFC') + SM0->M0_ESTCOB + SA1->A1_EST,'CFC_ALQFCP')
	nAliqDif 	:= Round(((nDifal  /nValMerc  ) * 100),2)

	//Tratamento para Suframa
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
			cQuery += "  AND '" + cCodProd + "' = CFD_COD "
			cQuery += "  AND D_E_L_E_T_ = ' '"
			cQuery += "  GROUP BY CFD_PERVEN, CFD_ORIGEM "

			TcQuery cQuery new Alias ( cAliasQry )

			If !(cAliasQry)->(EOF())
				If (cAliasQry)->CFD_ORIGEM == '3'
					//Beneficio de isenção do suframa é apenas para produtos nacionais
					nAliqICM  := 4 //Aliquota para importado
					If nAliqCOF == 0
						nAliqCOF := MaFisRet(nItem,"IT_ALIQCOF")
					EndIf

					If  nVlrCof == 0 .And. nAliqCOF > 0
						nVlrCof := ((nValMerc * nAliqCOF)/100)
					EndIf	

					If nAliqPIS == 0 
						nAliqPIS := MaFisRet(nItem,"IT_ALIQPIS")
					EndIf
					If nVlrPis == 0 .And. nAliqPIS > 0
						nVlrPis := ((nValMerc * nAliqPIS)/100)
					EndIf											
				Else
					nAliqICM := MaFisRet(nItem,"IT_ALIQICM")						
				EndIf
			Else
				nAliqICM := MaFisRet(nItem,"IT_ALIQICM")
			EndIf
			nVlrIcm := ((nValMerc * nAliqICM)/100)
			(cAliasQry)->(DbCloseArea())
		Else
			nAliqICM := MaFisRet(nItem,"IT_ALIQICM")
		EndIf	
	ElseIf SB1->B1_ORIGEM $ '3|5'
		If Select(cAliasQry) > 0
			(cAliasQry)->(DbCloseArea())
		EndIf
		cQuery := 'SELECT MAX(CFD_PERVEN), CFD_ORIGEM '
		cQuery += "  FROM " + RetSQLTab('CFD')
		cQuery += "  WHERE  "
		cQuery += "  CFD_FILIAL = '" + xFilial('CFD') + "' " 
		cQuery += "  AND '" + cCodProd + "' = CFD_COD "
		cQuery += "  AND D_E_L_E_T_ = ' '"
		cQuery += "  GROUP BY CFD_PERVEN, CFD_ORIGEM "

		TcQuery cQuery new Alias ( cAliasQry )

		If !(cAliasQry)->(EOF()) .And. SM0->M0_ESTCOB <> SA1->A1_EST
			If (cAliasQry)->CFD_ORIGEM == '3'
				//Beneficio de isenção do suframa é apenas para produtos nacionais
				nAliqICM  := 4 //Aliquota para importado
				If nAliqCOF == 0
					nAliqCOF := MaFisRet(nItem,"IT_ALIQCOF")
				EndIf

				If  nVlrCof == 0 .And. nAliqCOF > 0
					nVlrCof := ((nValMerc * nAliqCOF)/100)
				EndIf	

				If nAliqPIS == 0 
					nAliqPIS := MaFisRet(nItem,"IT_ALIQPIS")
				EndIf
				If nVlrPis == 0 .And. nAliqPIS > 0
					nVlrPis := ((nValMerc * nAliqPIS)/100)
				EndIf											
			Else
				nAliqICM := MaFisRet(nItem,"IT_ALIQICM")						
			EndIf

		Else
			nAliqICM := MaFisRet(nItem,"IT_ALIQICM")					
		EndIf
		(cAliasQry)->(DbCloseArea())
	Else
		//ICMS
		//nVlrIcm  := MaFisRet(nItem,"IT_VALICM")
		nAliqICM := MaFisRet(nItem,"IT_ALIQICM")
	EndIf
	If SF4->F4_BASEICM > 0
		nAliqICM := Round((SF4->F4_BASEICM * nAliqICM) / 100,2)
		nVlrIcm := ((nValMerc * nAliqICM)/100)
	Else		
		If  nAliqICM > 0
			nVlrIcm := ((nValMerc * nAliqICM)/100)
		EndIf		
	EndIf	

	If SA1->A1_CONTRIB == '2' .And. MaFisRet(nItem,"IT_VALIPI") > 0
		nAliqDif := (nDifal / nValMerc) * 100
		nDifal   := ((nValMerc * nAliqDif)/100)
	Else
		nAliqDif := 18 + nAliqFecp - nAliqICM
	EndIf

	If  ALLTRIM(SB1->B1_GRTRIB) $ SupergetMV('ES_GRTRIB',.T.,'') //produtos com isanção de pis nem cofins
		nAliqPIS := 0
		nAliqCOF := 0
	EndIf

	nRet := nPrcVen * ((1/(100 - (18 + nAliqPIS + nAliqCOF + nMargem ))) * 100) // calculo com base 18
	nRet := (nRet * (100 - 18 - nAliqPIS - nAliqCOF)) / (100 - nAliqICM - nAliqPIS - nAliqCOF - nAliqDif)  //tratamento para base reduzida
	
	If cAlias == 'DA1' 
		oMdlDA1:LoadValue('DA1_XPRCM0',(nRet * (100 - nAliqICM - nAliqPIS - nAliqCOF)) / (100 - 0 - nAliqPIS - nAliqCOF) )
		oMdlDA1:LoadValue('DA1_XPRCM4',(nRet * (100 - nAliqICM - nAliqPIS - nAliqCOF)) / (100 - 4 - nAliqPIS - nAliqCOF) )
		oMdlDA1:LoadValue('DA1_XPRCM7',(nRet * (100 - nAliqICM - nAliqPIS - nAliqCOF)) / (100 - 7 - nAliqPIS - nAliqCOF))
		oMdlDA1:LoadValue('DA1_XPCM12',(nRet * (100 - nAliqICM - nAliqPIS - nAliqCOF)) / (100 - 12 - nAliqPIS - nAliqCOF) )
		oMdlDA1:LoadValue('DA1_XPCM18',(nRet * (100 - nAliqICM - nAliqPIS - nAliqCOF)) / (100 - 18 - nAliqPIS - nAliqCOF) )
		oMdlDA1:LoadValue('DA1_XPCM17',(nRet * (100 - nAliqICM - nAliqPIS - nAliqCOF)) / (100 - 17 - nAliqPIS - nAliqCOF) )
		oMdlDA1:LoadValue('DA1_XPCM19',(nRet * (100 - nAliqICM - nAliqPIS - nAliqCOF)) / (100 - 19 - nAliqPIS - nAliqCOF) )
	ElseIf	cAlias == 'SBZ' 
		aPrcIcm := {}	
		aadd(aPrcIcm,(nRet * (100 - nAliqICM - nAliqPIS - nAliqCOF)) / (100 - 0 - nAliqPIS - nAliqCOF))
		aadd(aPrcIcm,(nRet * (100 - nAliqICM - nAliqPIS - nAliqCOF)) / (100 - 4 - nAliqPIS - nAliqCOF))
		aadd(aPrcIcm,(nRet * (100 - nAliqICM - nAliqPIS - nAliqCOF)) / (100 - 7 - nAliqPIS - nAliqCOF))
		aadd(aPrcIcm,(nRet * (100 - nAliqICM - nAliqPIS - nAliqCOF)) / (100 - 12 - nAliqPIS - nAliqCOF))
		aadd(aPrcIcm,(nRet * (100 - nAliqICM - nAliqPIS - nAliqCOF)) / (100 - 18 - nAliqPIS - nAliqCOF))
		aadd(aPrcIcm,(nRet * (100 - nAliqICM - nAliqPIS - nAliqCOF)) / (100 - 17 - nAliqPIS - nAliqCOF))
		aadd(aPrcIcm,(nRet * (100 - nAliqICM - nAliqPIS - nAliqCOF)) / (100 - 19 - nAliqPIS - nAliqCOF))
	EndIf
	
	If SA1->A1_CONTRIB == '2' .And. nDifal > 0 //tratamento para difal
		nAliqICM	:= 18
	EndIf		

	If nAliqICM + ((nDifal / nValMerc) * 100) > 19 .And. SA1->A1_CONTRIB == '2' 
		nAliqICM := 19
	EndIf

	Do Case
		Case nAliqICM == 0
			nRet := DA1->DA1_XPRCM0
		Case nAliqICM == 4
			nRet := DA1->DA1_XPRCM4
		Case nAliqICM == 7
			nRet := DA1->DA1_XPRCM7
		Case nAliqICM == 12
			nRet := DA1->DA1_XPCM12
		Case nAliqICM == 18
			nRet := DA1->DA1_XPCM18				
		Case nAliqICM == 17
			nRet := DA1->DA1_XPCM17
		Case nAliqICM == 19
			//nRet := DA1->DA1_XPCM19 Retirado pois no caso de aliquota 19 faz o calculo denovo 
	EndCase								

	If nCustFin > 0
		nRet := nRet + (nRet * (nCustFin / 100)) //Aplico o custo financeiro
	EndIf

	If cAlias == 'UPD'// Atualizo a margem do pedido
		If Round(nRet,2) <> Round(SCK->CK_PRUNIT,2)		
			nMgLiq		:= ((SCK->CK_PRCVEN * nQtdVen) - (nPrcVen * nQtdVen)) - nVlrPis - nVlrCof - nVlrIcm - nDifal - SCK->CK_XVLFRET - SCK->CK_XPALET - nCustFin
			nPMgLiq		:= round((nMgLiq * 100) / SCK->CK_PRCVEN ,2)		
			Reclock('SCK',.F.)
			SCK->CK_XMGBRUT	:= nPMgLiq
			SCK->CK_COMIS1	:= RetComis(nPMgLiq,SCK->CK_PRODUTO)
			MsUnlock()
		EndIf
	EndIf

	If cAlias == 'SIM'
		MsgInfo('Valor para o produto ' + Alltrim(POSICIONE('SB1',1,xFilial('SB1')+MV_PAR05,'B1_DESC')) + CRLF + ;
		'Custo Standard ' + cMCustd +  Alltrim(Transform( nPrcVen, "@E 999,999,999,999.99" ))+ CRLF + ;
		'Custo Financeiro  ' +  Alltrim(Transform( nCustFin, "@E 999,999,999.999999" )) + ' %'+ CRLF + ;
		'% ICMS ' +  Alltrim(Transform( nAliqICM, "@E 999,999,999.999999" ))+ CRLF + ;
		'% PIS  ' +  Alltrim(Transform( nAliqPIS, "@E 999,999,999.999999" ))+ CRLF + ;
		'% COFINS ' +  Alltrim(Transform( nAliqCOF, "@E 999,999,999.999999" ))+ CRLF + ;
		'Preço de venda ' + cMoeda +  Alltrim(Transform( nRet, "@E 999,999,999,999.99" )))
	EndIf
EndIf

/*
If cAlias == 'SCJ'
	GETDREFRESH()	   
	oGetDad:Refresh()
EndIf*/
If cAlias == 'SCJ'
	If TMP1->CK_PRCVEN == 0
		TMP1->CK_PRCVEN := nRet
	EndIf
	TMP1->CK_CLASFIS := CodSitTri()
	U_UpdTotal() //Atualizo total do rodapé
EndIf

MaFisEnd()
RestArea(aArea)
RestArea(aAreaSA1)
RestArea(aAreaSC5)
RestArea(aAreaSC6)


Return IIF(nRet > 0 , nRet , nValOld)


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


User Function SimPrc()
Local aParam      := {}
Local aRet        := {}
Local nRet		  := 0

aAdd(aParam, {1, "Cliente"   	, CriaVar('A1_COD',.F.)  ,  ,, 'SA1',, 60, .F.} )
aAdd(aParam, {1, "Loja"   		, CriaVar('A1_LOJA',.F.) ,  ,, ,, 60, .F.} )
aAdd(aParam, {1, "Cond. Pgto."  , CriaVar('E4_CODIGO',.F.)  ,  ,, 'SE4',, 60, .F.} )
aAdd(aParam, {1, "TES"  		, CriaVar('F4_CODIGO',.F.)  ,  ,, 'SF4',, 60, .F.} )
aAdd(aParam, {1, "Produto" 		, CriaVar('B1_COD',.F.)  ,  ,, 'SB1',, 60, .F.} )

If ParamBox(aParam,'Parâmetros',aRet)
	U_DaxImp('SIM')
EndIF


Return



User Function ClcComis()
Local nRet		:= 0
Local nMargem	:= 0
Local nPrcVen	:= TMP1->CK_PRCVEN * TMP1->CK_QTDVEN
Local nCustd	:= 0
Local cQuery	:= ''
Local cAliasQry := GetNextAlias()
Local aFerias	:= {}
Local aArea		:= GetArea()
Local nMoedaC	:= 1
Local nMoedaV	:= 1
Local nPDsr		:= 0
Local nPCustFin		:= SupergetMV('ES_CUSTFIN',.T.,2.5)

SA3->(DbSetOrder(1))
IF empty(M->CJ_XVEND) .Or. !SA3->(DbSeek(xFilial('SA3')+ M->CJ_XVEND))
	RestArea(aArea)
	Return 0
EndIf

//Verifico se tem comissao especifica pro produto
SB1->(DbSetOrder(1))
If SB1->(Dbseek(xFilial('SB1') +  ("TMP1")->CK_PRODUTO)) 
	If SB1->B1_XCOMIS == '2'
		RestArea(aArea)
		Return SB1->B1_COMIS
	Endif
	If SB1->B1_XMOEDVE == '2'
		nMoedaV	:= 2
	EndIf	
EndIf

//Comissao padrao
SBZ->(dbSetOrder(1))
If SBZ->(dbseek(xFilial('SBZ') +("TMP1")->CK_PRODUTO))
	nCustd := SBZ->BZ_CUSTD * TMP1->CK_QTDVEN
	If SBZ->BZ_MCUSTD == '2'
		cMCustd	:= 'U$ '
		nMoedaC	:= 2
	EndIf		
EndIF

DA1->(DbSetOrder(1))
If DA1->(DbSeek(xFilial('DA1') + SUPERGETMV('ES_DAXTAB',.T.,'001',cFilAnt) + ("TMP1")->CK_PRODUTO))
	nCustd		:= xMoeda(DA1->DA1_XCUSTD,nMoedaC,1,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2')) * TMP1->CK_QTDVEN
EndIf

nPrcVen 	:= xMoeda(nPrcVen,VAL(TMP1->CK_MOEDA),1,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2')) //converto pra real

nMargem := nPrcVen - nCustd - RetImp(nPrcVen) - TMP1->CK_XVLFRET - TMP1->CK_XPALET - (((nPrcVen + Round((TMP1->CK_XVLIPI * nPrcVen) / 100,2)) *  RetCfin(M->CJ_CONDPAG,nPCustFin) )/100 ) //valor do preço
nMargem	:= Round((nMargem * 100) / nPrcVen,2) // percentual

nRet := RetComis(nMargem,TMP1->CK_PRODUTO)

//Verifico se é PJ
If SA3->A3_XTIPO == '2'
	TMP1->CK_COMIS1 := SA3->A3_COMIS
	nRet := SA3->A3_COMIS
EndIF

//Verifico se esta de ferias
aFerias := CheckFeria(cFilAnt, SA3->A3_NUMRA, dDataBase, dDataBase)
If aFerias[1] .Or. aFerias[2] .Or. aFerias[3] .Or. aFerias[4]
	RestArea(aArea)
	nRet := 0
EndIf

If INCLUI .OR. ALTERA
	TMP1->CK_XMGBRUT	:= nMargem
	If M->CJ_XTPOPER $ SUPERGETMV('ES_OPZEROR',.T.,'') 
		TMP1->CK_XMGBRUT	:= 0
		nRet				:= 0
	EndIf	
EndIf
//sssssssss
TMP1->CK_COMIS1 := nRet
RestArea(aArea)
Return nRet

/*/{Protheus.doc} RetImp
	retorna soma do ICMS PIS COFINS
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
Static Function RetImp(nCustd)
Local nFrete 		:= M->C5_FRETE
Local nSeguro		:= M->C5_SEGURO
Local nFrtAut		:= M->C5_FRETAUT
Local nDespes		:= M->C5_DESPESA
Local nPdescab		:= M->C5_PDESCAB
Local nDescont		:= M->C5_DESCONT
Local cCodCli		:= M->C5_CLIENTE
Local cLoja			:= M->C5_LOJACLI
Local nVlrIcm 		:= 0
Local nVlrPis 		:= 0
Local nVlrCof		:= 0
Local nAliqIpi		:= 0
Local nVlrIpi		:= 0
Local cTES			:= ''
Local nValDesc		:= 0
Local nItem			:= 0
Local nValMerc		:= 0
Local nQtdVen		:= 0
Local nDifal		:= 0
Local nRet			:= 0
Local n				:= 0 //PARAMIXB
Local cCodProd 		:= ("TMP1")->CK_PRODUTO
Local aArea			:= GetArea()
Local nSuframa		:= 0
Local cAliasQry		:= GetNextAlias()
Local cQuery		:= ''
Local nAliqFecp		:= 0
Local nAliqDif		:= 0
Local cClasFis		:= TMP1->CK_CLASFIS
If IsInCallStack('MATA415')
	nFrete 			:= 0
	nSeguro			:= 0
	nFrtAut			:= 0
	nDespes			:= 0
	nPdescab		:= 0
	nDescont		:= 0
	cCodCli			:= M->CJ_CLIENTE
	cLoja			:= M->CJ_LOJA
EndIf

nPrcVen			:= nCustd
nPrcLista		:= nPrcVen

cTES 		:= ("TMP1")->CK_TES
nValDesc	:= 0
nItem		:= 1//Iif(Valtype(("TMP1")->CK_ITEM) == 'C' , Val( ("TMP1")->CK_ITEM),  ("TMP1")->CK_ITEM)
	
nValMerc  	:= nPRcVen
nQtdVen 	:=  ("TMP1")->CK_QTDVEN

SB1->(DbSetOrder(1)) //--B1_FILIAL+B1_COD
SB1->(DbSeek(FwxFilial('SB1')+cCodProd))

nAcresFin := A410Arred((nPrcVen*SE4->E4_ACRSFIN)/100, 'D2_PRCVEN')
//nValMerc  += A410Arred(nAcresFin*nQtdVen, 'D2_TOTAL')
//nDesconto := A410Arred(nPrcLista*nQtdVen, 'D2_DESCON') - nValMerc
nValMerc  += A410Arred(nAcresFin, 'D2_TOTAL')
nDesconto := A410Arred(nPrcLista, 'D2_DESCON') - nValMerc

nDesconto := Max(0,nDesconto)
nPrcLista += nAcresFin
nValMerc  += nDesconto

SA1->(DbSetOrder(1)) //--A1_FILIAL+A1_COD+A1_LOJA
SA1->(DbSeek(FwxFilial('SA1') + cCodCli + cLoja))

If !MaFisFound('NF')
	MaFisSave()
	MaFisEnd()

	MaFisIni( cCodCli ,;		// 1-Codigo Cliente/Fornecedor
				cLoja ,;	// 2-Loja do Cliente/Fornecedor
				"C",;										// 3-C:Cliente , F:Fornecedor
				"N",;										// 4-Tipo da NF
				SA1->A1_TIPO,;							    // 5-Tipo do Cliente/Fornecedor
				NIL,;
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
EndIf


SF4->(DbSeek(FwxFilial('SF4')+cTES))

// ------------------------------------
// AGREGA OS ITENS PARA A FUNCAO FISCAL
// ------------------------------------

MaFisAdd(	cCodProd,;  	    // 1-Codigo do Produto ( Obrigatorio )
		cTES,;	   	        // 2-Codigo do TES ( Opcional )
		nQtdVen,;  	        // 3-Quantidade ( Obrigatorio )
		nValMerc,;		  	// 4-Preco Unitario ( Obrigatorio )
		nDesconto,;  		// 5-Valor do Desconto ( Opcional )
		"",;	   			// 6-Numero da NF Original ( Devolucao/Benef )
		"",;				// 7-Serie da NF Original ( Devolucao/Benef )
		0,;					// 8-RecNo da NF Original no arq SD1/SD2
		0,;					// 9-Valor do Frete do Item ( Opcional )
		0,;					// 10-Valor da Despesa do item ( Opcional )
		0,;					// 11-Valor do Seguro do item ( Opcional )
		0,;					// 12-Valor do Frete Autonomo ( Opcional )
		nValMerc,;	// 13-Valor da Mercadoria ( Obrigatorio )
		0,;					// 14-Valor da Embalagem ( Opiconal )
		SB1->(Recno()),SF4->(Recno()) , , , , , , , , , , , ,;
		cClasFis) // 28-Classificacao fiscal)

// ------------------------------------
// CALCULO DO ISS
// ------------------------------------
SF4->(DbSeek(FwxFilial('SF4')+cTES))
If SA1->A1_INCISS == "N"
	If SF4->F4_ISS=="S"
		nPrcLista := a410Arred(nPrcLista/(1-(MaAliqISS(nItem)/100)), 'D2_PRCVEN')
		nValMerc  := a410Arred(nValMerc/(1-(MaAliqISS(nItem)/100)), 'D2_PRCVEN')
		MaFisAlt('IT_PRCUNI', nPrcLista, nItem)
		MaFisAlt('IT_VALMERC', nValMerc, nItem)
	EndIf
EndIf

// ------------------------------------
// VERIFICA O PESO P/ CALCULO DO FRETE
// ------------------------------------
nQtdPeso := nQtdVen * SB1->B1_PESO

If !MaFisFound('NF')
	MaFisAlt("IT_PESO"   , nQtdPeso , nItem)
	MaFisAlt("IT_PRCUNI" , nPrcLista, nItem)
	MaFisAlt("IT_VALMERC", nValMerc , nItem)

	// ------------------------------------------
	// INDICA OS VALORES DO CABECALHO
	// ------------------------------------------
//	MaFisAlt("NF_FRETE"   , nFrete)
	MaFisAlt("NF_SEGURO"  , nSeguro)
	MaFisAlt("NF_AUTONOMO", nFrtAut)
	MaFisAlt("NF_DESPESA" , nDespes)
	MaFisAlt("NF_DESCONTO", MaFisRet(,"NF_DESCONTO")+MaFisRet(,"NF_VALMERC")*nPdescab/100)
	MaFisAlt("NF_DESCONTO", MaFisRet(,"NF_DESCONTO")+nDescont)
	MaFisWrite(1)
EndIf

nVlrIpi  := MaFisRet(nItem,"IT_VALIPI")
nAliqIpi := MaFisRet(nItem,"IT_ALIQIPI")
nVlrIpi := ((nValMerc * nAliqIpi)/100)

//TRATAMENTO PARA IPI
If SA1->A1_CONTRIB == '2'// .And. nVlrIpi > 0
	nAliqIcm := (nVlrIcm / nValMerc) * 100
	nVlrIcm  := (((nValMerc + nVlrIpi) * nAliqIcm)/100)
	
	nAliqFecp	:= POSICIONE('CFC',1,xFilial('CFC') + SM0->M0_ESTCOB + SA1->A1_EST,'CFC_ALQFCP')

	nDifal	:= MAFISRET(nItem,"IT_DIFAL")

	nDifal := nDifal + (((nValMerc + nVlrIpi) * nAliqFecp)/100)
	nAliqDif := ((nDifal / nValMerc) * 100)	
EndIf

nSuframa := MaFisRet(nItem,"IT_DESCZF")
		
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
			nVlrPis := ((nValMerc * nAliqPIS)/100)
		EndIf
	Endif

	If nVlrCof == 0 
		nVlrCof  := MaFisRet(nItem,"IT_VALCF2")
		nAliqCOF := MaFisRet(nItem,"IT_ALIQCF2")

		If  nVlrCof == 0 .And. nAliqCOF > 0
			nVlrCof := ((nValMerc * nAliqCOF)/100)
		EndIf
	Endif
EndIf

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
		cQuery += "  AND '" + TMP1->CK_PRODUTO + "' = CFD_COD "
		cQuery += "  AND D_E_L_E_T_ = ' '"
		cQuery += "  GROUP BY CFD_PERVEN, CFD_ORIGEM "

		TcQuery cQuery new Alias ( cAliasQry )

		If !(cAliasQry)->(EOF())
			If (cAliasQry)->CFD_ORIGEM == '3'
				//Beneficio de isenção do suframa é apenas para produtos nacionais
				nAliqICM  := 4 //Aliquota para importado
				If nAliqCOF == 0
					nAliqCOF := MaFisRet(nItem,"IT_ALIQCOF")
				EndIf

				If  nVlrCof == 0 .And. nAliqCOF > 0
					nVlrCof := ((nValMerc * nAliqCOF)/100)
				EndIf	

				If nAliqPIS == 0 
					nAliqPIS := MaFisRet(nItem,"IT_ALIQPIS")
				EndIf
				If nVlrPis == 0 .And. nAliqPIS > 0
					nVlrPis := ((nValMerc * nAliqPIS)/100)
				EndIf											
			ElseIf SA1->A1_CALCSUF $ 'I'
				nAliqICM := MaFisRet(nItem,"IT_ALIQICM")						
			EndIf
		ElseIf SA1->A1_CALCSUF $ 'I'
			nAliqICM := 0//MaFisRet(nItem,"IT_ALIQICM")
		EndIf
		nVlrIcm := ((nValMerc * nAliqICM)/100)
		(cAliasQry)->(DbCloseArea())
	ElseIf SB1->B1_ORIGEM $ '6|2' //IMPORTADO SEM SIMILAR NACIONAL
		nAliqICM	:= MaFisRet(nItem,"IT_ALIQICM")
		nVlrIcm := ((nValMerc * nAliqICM)/100)						
	EndIf
ElseIf SB1->B1_ORIGEM $ '3|5'
	If Select(cAliasQry) > 0
		(cAliasQry)->(DbCloseArea())
	EndIf
	cQuery := 'SELECT MAX(CFD_PERVEN), CFD_ORIGEM '
	cQuery += "  FROM " + RetSQLTab('CFD')
	cQuery += "  WHERE  "
	cQuery += "  CFD_FILIAL = '" + xFilial('CFD') + "' " 
	cQuery += "  AND '" + cCodProd + "' = CFD_COD "
	cQuery += "  AND D_E_L_E_T_ = ' '"
	cQuery += "  GROUP BY CFD_PERVEN, CFD_ORIGEM "

	TcQuery cQuery new Alias ( cAliasQry )

	If !(cAliasQry)->(EOF()) .And. SM0->M0_ESTCOB <> SA1->A1_EST
		If (cAliasQry)->CFD_ORIGEM == '3'
			//Beneficio de isenção do suframa é apenas para produtos nacionais
			nAliqICM  := 4 //Aliquota para importado
			If nAliqCOF == 0
				nAliqCOF := MaFisRet(nItem,"IT_ALIQCOF")
			EndIf

			If  nVlrCof == 0 .And. nAliqCOF > 0
				nVlrCof := ((nValMerc * nAliqCOF)/100)
			EndIf	

			If nAliqPIS == 0 
				nAliqPIS := MaFisRet(nItem,"IT_ALIQPIS")
			EndIf
			If nVlrPis == 0 .And. nAliqPIS > 0
				nVlrPis := ((nValMerc * nAliqPIS)/100)
			EndIf											
		Else
			nAliqICM := MaFisRet(nItem,"IT_ALIQICM")						
		EndIf
	Else
		nAliqICM := MaFisRet(nItem,"IT_ALIQICM")
		nVlrIcm := ((nValMerc * nAliqICM)/100)					
	EndIf
	(cAliasQry)->(DbCloseArea())		
Else
	//ICMS
	//nVlrIcm  := MaFisRet(nItem,"IT_VALICM")
	nAliqICM := MaFisRet(nItem,"IT_ALIQICM")
EndIf

If SF4->F4_BASEICM > 0
	nAliqICM := Round((SF4->F4_BASEICM * nAliqICM) / 100,2)
	nVlrIcm := ((nValMerc * nAliqICM)/100)
Else		
	If  nAliqICM > 0
		nVlrIcm := ((nValMerc * nAliqICM)/100)
	EndIf		
EndIf	

If SA1->A1_CONTRIB == '1' .And. nVlrIcm > 0 // contribuinte
	nVlrIcm  := ((nValMerc * nAliqIcm)/100)
EndIf		

//valor TOTAL com impostos de cada item
nVlrIt  := MaFisRet(nItem,"IT_TOTAL")

nRet	:= nVlrIcm + nVlrPis + nVlrCof + nDifal

//Atribuo os valores na grid
TMP1->CK_XVLIPI := nAliqIpi	
TMP1->CK_XVLICMP := nAliqDif
TMP1->CK_XVLICM := nAliqICM
TMP1->CK_XVLPIS := nAliqPIS
TMP1->CK_XVLCOF := nAliqCOF

MAFISEND()

RestArea(aArea)
//MaFisEnd()
//MaFisRestore()
 Return nRet


User Function AxCadZ9()
AxCadastro('SZ9','Faixa de comissionamento')
Return

User Function AxCadZD()
AxCadastro('SZD','Cadastro de DSR')
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CheckFeria

Verifica se há inconsistencia de Férias

Retorna Verdadeiro caso exista inconsitencia de alocação na data informada

@param  cFilFun	String	Filial do funcionário
@param  cMat		String	Matricula do Funcionario
@param  dDataIni	Data	Data inicial de alocação
@param  dDataFim	Data	Data Final de alocação
	
@owner  rogerio.souza
@author  rogerio.souza
@version V11
@since   04/06/2013 
@return aRet Array, aRet[1] - Ferias programadas.
					aRet[2]	- Ferias programadas 2.
					aRet[3] - Ferias programadas 3.
					aRet[4] - Ferias processada.
/*/
//-------------------------------------------------------------------
Static Function CheckFeria(cFilFun, cMat, dDataIni, dDataFim)
	Local aRet 	:= {.F.,.F.,.F.,.F.} 
	Local aArea := GetArea()
	Local cAliasSRF := GetNextAlias()
	Local cAliasSR8 := GetNextAlias()  
	Local cFilRCM	:= xFilial('RCM',cFilFun)
	Local cFilSRF	:= xFilial('SRF',cFilFun)
	Local cFilSR8	:= xFilial('SR8',cFilFun)
	
	//Verifica se funcionário possui férias programadas	
	BeginSQL alias cAliasSRF			
		SELECT 	
			SRF.RF_DATAINI, 
			SRF.RF_DFEPRO1,
			SRF.RF_DATINI2,
			SRF.RF_DFEPRO2,
			SRF.RF_DATINI3,
			SRF.RF_DFEPRO3
			
 		FROM %table:SRF% SRF 
 		WHERE 
			SRF.%notDel%
 			AND SRF.RF_FILIAL = %exp:cFilSRF% 				
 			AND SRF.RF_MAT = %exp:cMat%
 			AND ( 	
 					(
 						%exp:dDataIni% >= SRF.RF_DATAINI OR
						%exp:dDataFim% <= SRF.RF_DATAINI 				
					) OR (					
						%exp:dDataIni% >= SRF.RF_DATINI2 OR	
						%exp:dDataFim% <= SRF.RF_DATINI2  					
					) OR ( 	
						%exp:dDataIni% >= SRF.RF_DATINI3 OR
						%exp:dDataFim% <= SRF.RF_DATINI3 
 					)
 				) 	 			
	EndSQL	

	While (cAliasSRF)->(!Eof())
	
		If !Empty((cAliasSRF)->RF_DATAINI) .AND.;
			DTOS(dDataIni) >= (cAliasSRF)->RF_DATAINI .AND. DTOS(dDataIni) <= DTOS((STOD((cAliasSRF)->RF_DATAINI) + ((cAliasSRF)->RF_DFEPRO1-1))) .OR.;
			DTOS(dDataFim) >= (cAliasSRF)->RF_DATAINI .AND. DTOS(dDataFim) <= DTOS((STOD((cAliasSRF)->RF_DATAINI) + ((cAliasSRF)->RF_DFEPRO1-1))) .OR.;
			DTOS(dDataIni) <= (cAliasSRF)->RF_DATAINI .AND. DTOS(dDataFim) >= DTOS((STOD((cAliasSRF)->RF_DATAINI) + ((cAliasSRF)->RF_DFEPRO1-1)))
				
			aRet[1] := .T.
			Exit
								
		ElseIf  !Empty((cAliasSRF)->RF_DATINI2) .AND.;
			DTOS(dDataIni) >= (cAliasSRF)->RF_DATINI2 .AND. DTOS(dDataIni) <= DTOS((STOD((cAliasSRF)->RF_DATINI2) + ((cAliasSRF)->RF_DFEPRO2-1))) .OR.;
			DTOS(dDataFim) >= (cAliasSRF)->RF_DATINI2 .AND. DTOS(dDataFim) <= DTOS((STOD((cAliasSRF)->RF_DATINI2) + ((cAliasSRF)->RF_DFEPRO2-1))) .OR.;
			DTOS(dDataIni) <= (cAliasSRF)->RF_DATINI2 .AND. DTOS(dDataFim) >= DTOS((STOD((cAliasSRF)->RF_DATINI2) + ((cAliasSRF)->RF_DFEPRO2-1)))
			
			aRet[2] := .T.
			Exit
						
		ElseIf  !Empty((cAliasSRF)->RF_DATINI3) .AND.;
			DTOS(dDataIni) >= (cAliasSRF)->RF_DATINI3 .AND. DTOS(dDataIni) <= DTOS((STOD((cAliasSRF)->RF_DATINI3) + ((cAliasSRF)->RF_DFEPRO3-1))) .OR.;
			DTOS(dDataFim) >= (cAliasSRF)->RF_DATINI3 .AND. DTOS(dDataFim) <= DTOS((STOD((cAliasSRF)->RF_DATINI3) + ((cAliasSRF)->RF_DFEPRO3-1))) .OR.;
			DTOS(dDataIni) <= (cAliasSRF)->RF_DATINI3 .AND. DTOS(dDataFim) >= DTOS((STOD((cAliasSRF)->RF_DATINI3) + ((cAliasSRF)->RF_DFEPRO3-1)))
			
			aRet[3] := .T.
			Exit
						
		EndIf

		(cAliasSRF)->(DbSkip())
	EndDo

	(cAliasSRF)->(DbCloseArea())
	
	//Verifica se funcionário possui férias processadas, caso não exista férias programadas no período
	BeginSQL alias cAliasSR8		
		SELECT 	COUNT(*) NUM
 		FROM %table:SR8% SR8
 		INNER JOIN %table:RCM% RCM 
 		ON  RCM.RCM_FILIAL 	= %exp:cFilRCM% 
 		AND RCM.RCM_TIPO	= SR8.R8_TIPOAFA
 		AND RCM.RCM_TIPOAF	= 4
 		WHERE 
			SR8.%notDel%
			AND RCM.%notDel%
 			AND SR8.R8_FILIAL = %exp:cFilSR8% 				
 			AND SR8.R8_MAT = %exp:cMat%
 			AND ((NOT (%exp:dDataIni% > SR8.R8_DATAFIM OR %exp:dDataFim% < SR8.R8_DATAINI)) OR
       			 (%exp:dDataFim%>=SR8.R8_DATAINI AND SR8.R8_DATAFIM = '')
	            )
	EndSQL	

	If (cAliasSR8)->(!Eof()) .AND. (cAliasSR8)->NUM > 0
	//	aRet[4] := .T.
	EndIf
		
	(cAliasSR8)->(DbCloseArea())
			
	RestArea(aArea)		
	
Return aRet


//--------------------------------------------------------------
/*/{Protheus.doc} DaxRenta
Description                                                     
                                                                
@param xParam Parameter Description                             
@return xRet Return Description                                 
@author  -                                               
@since 29/08/2019                                                   
/*/                                                             
//--------------------------------------------------------------
User Function DaxRenta()                        
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

If Select('TMP1') == 0
	return
EndIf

If IsInCallStack('MATA415') .And. Empty(TMP1->CK_PRODUTO) .And. TMP1->CK_ITEM == '01'
	Alert('Informe ao menos um item para exibir a margem de rentabilidade.')
	Return
EndIf

  //DEFINE MSDIALOG oDlg TITLE "Margem de Rentabilidade" FROM 000, 000  TO 800, 1500 COLORS 0, 16777215 PIXEL
   DEFINE MSDIALOG oDlg TITLE "Margem de Rentabilidade" FROM aSize[7], 000  TO 8000, 1500 COLORS 0, 16777215 PIXEL

    @ 006, nCol1 SAY oSay1 PROMPT "ORÇAMENTO " + Alltrim(M->CJ_NUM) SIZE 100, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 006, 062 SAY oSay4 PROMPT "Vendedor " + Posicione('SA3',1,Xfilial('SA3') + M->CJ_XVEND , 'A3_NOME') SIZE 150, 024 OF oDlg COLORS 0, 16777215 PIXEL
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
	aCol2 := U_Rentab('2')
	aCol3 := U_Rentab('3')
	aCol4 := U_Rentab('4')

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

User Function Rentab(cTipo)
Local nFrete 		:= M->CJ_XVLFRETE
Local cCodCli		:= M->CJ_CLIENTE
Local cLoja			:= M->CJ_LOJA
Local cConPag		:= M->CJ_CONDPAG
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
Local cCondPag		:= M->CJ_CONDPAG
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
Local nLinha		:= TMP1->(Recno())
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

dbSelectArea("TMP1")
TMP1->(DbGoTop())
While !TMP1->(EOF())
	IF !TMP1->CK_FLAG //.And. !Val(TMP1->CK_XMOTIVO) > 1
		nMoedaC		:=  1
		nMoedaV		:=  1
		cCodProd 	:= 	TMP1->CK_PRODUTO
		nQtdVen 	:=  TMP1->CK_QTDVEN
		
		If cTipo $ '3' .Or. cTipo == '2' 
			if cTipo == '2'
				DbSelectArea('SZC')	
				SZC->(DbSetOrder(1))
				If SZC->(DbSeek(xFilial('SZC') + M->CJ_NUM + '1'))
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
				//nPrcVen			:= TMP1->CK_PRCVEN	* nQtdVen//xMoeda(DA1->DA1_XCUSTD,nMoedaC,nMoedaV,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2'))
				nPrcVen			:= xMoeda(DA1->DA1_XCUSTD,nMoedaC,1,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2')) * nQtdVen //transformo em real
				nPrcLista		:= nPrcVen
				nNegociado		:= TMP1->CK_PRCVEN * TMP1->CK_QTDVEN
				nVlrBase		:= xMoeda(TMP1->CK_PRCVEN,VAL(TMP1->CK_MOEDA),1,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2')) * TMP1->CK_QTDVEN//transformo em real
				Aadd(aItens,{TMP1->(Recno()),nPrcVen,nNegociado})
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
			//nPrcVen			:= TMP1->CK_PRCVEN	* nQtdVen//xMoeda(DA1->DA1_XCUSTD,nMoedaC,nMoedaV,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2'))
			nPrcVen			:= xMoeda(nPrcVen,nMoedaC,1,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2')) 
			nPrcLista		:= nPrcVen			
			nPrcLista := nPrcVen
			nNegociado		:= TMP1->CK_PRCVEN * TMP1->CK_QTDVEN
			nVlrBase		:= xMoeda(TMP1->CK_PRCVEN,VAL(TMP1->CK_MOEDA),1,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2')) * TMP1->CK_QTDVEN //transformo em real
			Aadd(aItens,{TMP1->(Recno()),nPrcVen,nNegociado})
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
				nNegociado		:= TMP1->CK_PRCVEN * TMP1->CK_QTDVEN
				nVlrBase		:= xMoeda(TMP1->CK_PRCVEN,VAL(TMP1->CK_MOEDA),1,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2')) * TMP1->CK_QTDVEN//transformo em real
				Aadd(aItens,{TMP1->(Recno()),nPrcVen,nNegociado})
			EndIf
		ElseIF cTipo $ 'ITORIG|ITATUAL'
		//	While nSeleciona <> Val(TMP1->CK_ITEM)
		//		TMP1->(DbSkip())
	//		EndDo
			cCodProd 	:= 	TMP1->CK_PRODUTO
			nQtdVen 	:=  TMP1->CK_QTDVEN	

			DbSelectArea('SZL')	
			SZL->(DbSetOrder(1))
			If cTipo == 'ITORIG' 
				nTMP1Bkp := TMP1->(Recno())
				TMP1->(DbGoTo(nRecTMP1))
				IF SZL->(DbSeek(xFilial('SZL') + M->CJ_NUM + TMP1->CK_ITEM + TMP1->CK_PRODUTO))
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
				TMP1->(dbGoTo(nTMP1Bkp))
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
				//nPrcVen			:= TMP1->CK_PRCVEN	* nQtdVen//xMoeda(DA1->DA1_XCUSTD,nMoedaC,nMoedaV,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2'))
				nPrcLista			:= xMoeda(DA1->DA1_XCUSTD,nMoedaC,1,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2')) * nQtdVen //converto para real
				nPrcVen				:= nPrcLista
				nNegociado			:= TMP1->CK_PRCVEN * TMP1->CK_QTDVEN
				nVlrBase			:= xMoeda(TMP1->CK_PRCVEN,VAL(TMP1->CK_MOEDA),1,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2')) * TMP1->CK_QTDVEN //transformo em real
				Aadd(aItens,{TMP1->(Recno()),nPrcVen,TMP1->CK_PRCVEN * TMP1->CK_QTDVEN})
			EndIf	
		EndIf

		cTES 		:= TMP1->CK_TES
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
					TMP1->CK_CLASFIS) // 28-Classificacao fiscal)


		MaFisSave()
	EndIf
	TMP1->(DbSkip())
EndDo


TMP1->(DbGoTop())
While !TMP1->(EOF()) .And. !lSZL
	IF !TMP1->CK_FLAG .And. Len(aItens) > 0 //.And. !Val(TMP1->CK_XMOTIVO) > 1
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
		If M->CJ_XTPOPER $ SUPERGETMV('ES_OPZEROR',.T.,'')
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
			TMP1->(DbGoTo(aItens[nPos][1]))
			nPrcVen		:= aItens[nPos][2]
			nNegociado	:= aItens[nPos][3]
		Else
			nItens++
			nItem++			
			nPrcVen		:= aItens[nItem][2]
			nNegociado	:= aItens[nItem][3]
		EndIf
		

		SB1->(DbSetOrder(1)) //--B1_FILIAL+B1_COD
		SB1->(DbSeek(FwxFilial('SB1')+TMP1->CK_PRODUTO))		
		// ------------------------------------
		// CALCULO DO ISS
		// ------------------------------------
		SF4->(DbSeek(FwxFilial('SF4')+TMP1->CK_TES))
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

		nNegociado 	:= xMoeda(nNegociado,VAL(TMP1->CK_MOEDA),1,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2')) //converto pra real

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
			cQuery += "  AND '" + TMP1->CK_PRODUTO + "' = CFD_COD "
			cQuery += "  AND D_E_L_E_T_ = ' '"
			cQuery += "  GROUP BY CFD_PERVEN, CFD_ORIGEM "

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
				cQuery += "  AND '" + TMP1->CK_PRODUTO + "' = CFD_COD "
				cQuery += "  AND D_E_L_E_T_ = ' '"
				cQuery += "  GROUP BY CFD_PERVEN, CFD_ORIGEM "

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
		nFrete		:= TMP1->CK_XVLFRET 
		nTotFrete	+= nFrete
		nExcecoes	+= TMP1->CK_XPALET //Exceções

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
		nMgLiq		:= (nNegociado - nPrcVen) - nVlrPis - nVlrCof - nVlrIcm - nDifal - TMP1->CK_XVLFRET - TMP1->CK_XPALET - nDespFin
		//nMgLiq		:= nNegociado - nVlrPis - nVlrCof - nVlrIcm - nDifal - TMP1->CK_XVLFRET - TMP1->CK_XPALET - nDespFin
		nTotMgLiq	+= nMgLiq
		nPMgLiq		:= round((nMgLiq * 100) / nNegociado ,2)
		//nPMgLiq		+= round((nVlrNeg - nPrcVen * 100) / nRecVen ,2) - nAliqPIS - nAliqCOF - nAliqICM - (18 + nAliqFecp - nAliqICM)- round((nDespFin * 100) / nRecVen ,2) - round((nFrete * 100) / nVlrNeg ,2)  - round((nExcecoes * 100) / nVlrNeg ,2) 
		
		If cTipo $ '3|ITORIG|ITATUAL' .Or. (IsinCallStack('MATA416'))
			If SB1->B1_XCOMIS == '2'
				TMP1->CK_COMIS1 := SB1->B1_COMIS
				nComis		+= nNegociado * (SB1->B1_COMIS / 100)
			Else
				SA3->(DbSetOrder(1))
				IF SA3->(DbSeek(xFilial('SA3')+ M->CJ_XVEND)) .And. SA3->A3_XTIPO = '2'
					If INCLUI .Or. ALTERA 
						TMP1->CK_COMIS1 := SA3->A3_COMIS
					EndIf
					nComis		+= nNegociado * (SA3->A3_COMIS / 100)
				Else
					If INCLUI .Or. ALTERA 
						TMP1->CK_COMIS1  := RetComis(nPMgLiq,TMP1->CK_PRODUTO)
					EndIf
					nComis		+= nNegociado * (RetComis(nPMgLiq,TMP1->CK_PRODUTO) / 100)
				EndIf
			EndIf
			If INCLUI .OR. ALTERA
				TMP1->CK_XMGBRUT := nPMgLiq
				If M->CJ_XTPOPER $ SUPERGETMV('ES_OPZEROR',.T.,'') 
					TMP1->CK_XMGBRUT	:= 0
				EndIf				
			EndIf
			
		ElseIf cTipo $ '2|3|4'
			If SB1->B1_XCOMIS == '2'
				//TMP1->CK_COMIS1 := SB1->B1_COMIS
				nComis		+= nNegociado * (SB1->B1_COMIS / 100)
			Else		
				SA3->(DbSetOrder(1))
				IF SA3->(DbSeek(xFilial('SA3')+ M->CJ_XVEND)) .And. SA3->A3_XTIPO = '2'
					nComis		+= nNegociado * (SA3->A3_COMIS / 100)
				Else
					nComis		+= nNegociado * (RetComis(nPMgLiq,TMP1->CK_PRODUTO) / 100)
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
			nPDsr := RetComis(nPMgLiq,TMP1->CK_PRODUTO) * nPDsr
			nDsr += nNegociado * (nPDsr / 100)
		Else
			nPDsr	:= 0
			nDsr	:= 0
		EndIf
		//TMP1->CK_COMIS1  := RetComis(nPMgLiq)  
		
		nTotPDsr += nPDsr

		If cTipo $ 'ITORIG|ITATUAL'
			TMP1->(DbGoBottom())
		EndIf
	EndIf
	TMP1->(DbSkip())
EndDo

If nItens == 0
	If cTipo $ 'ITORIG|ITATUAL'
		nItens := 1
	Else
		TMP1->(DbGoTop())
		While !TMP1->(EOF())
			nItens++
			TMP1->(DbSkip())
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
TMP1->(DbGoTo(nLinha))
Return aRet

User Function DAXDA0()
Local nOpc := 4
Local cCodTab := SUPERGETMV('ES_DAXTAB',.T.,'001')
Local cProduto := ''
Local nPrcVen := ''
Local nCustd	:= 0
Local cAtivo := "1"
Local cItem  := ""
Local aCab	:= {}
Local aItem	:= {}
Local aItens	:= {}
Local aPrcIcm	:= {}
Local lInclui	:= .T.
PRIVATE lMsErroAuto := .F.

If Posicione('SB1',1,xFilial('SB1') + cProduto ,'B1_TIPO') $ 'ME|PA'
	DA1->(DbSetOrder(3))
	If DA1->(DbSeek(xFilial('DA1') + cCodTab))
		While (DA1->(DA1_FILIAL + DA1_CODTAB) == xFilial('DA1') + cCodTab)
			cItem := DA1->DA1_ITEM
			aItem := {}
			If DA1->DA1_CODPRO == cProduto
				nPrcVen := U_DaxImp('SBZ', DA1->DA1_PRCVEN,@aPrcIcm)
				lInclui := .F.
				aAdd(aItem,{"LINPOS","DA1_ITEM", cItem})
				Aadd(aItem,{"AUTDELETA","N",Nil})	
				Aadd(aItem,{"DA1_CODPRO", cProduto, NIL})
				Aadd(aItem,{"DA1_XCUSTD", M->BZ_CUSTD, NIL})
				Aadd(aItem,{"DA1_XMARG", 2.5, NIL})//TODO
				Aadd(aItem,{"DA1_XPRCM0", aPrcIcm[1], NIL})//TODO
				Aadd(aItem,{"DA1_XPRCM4", aPrcIcm[2], NIL})//TODO
				Aadd(aItem,{"DA1_XPRCM7", aPrcIcm[3], NIL})//TODO
				Aadd(aItem,{"DA1_XPCM12", aPrcIcm[4], NIL})//TODO
				Aadd(aItem,{"DA1_XPCM18", aPrcIcm[5], NIL})//TODO
				Aadd(aItem,{"DA1_XPCM17", aPrcIcm[6], NIL})//TODO
				Aadd(aItem,{"DA1_XPCM19", aPrcIcm[7], NIL})//TODO
				Aadd(aItem,{"DA1_PRCVEN", nPrcVen, NIL})
					
			Else	
				aAdd(aItem,{"LINPOS","DA1_ITEM", cItem})
				Aadd(aItem,{"AUTDELETA","N",Nil})	
				Aadd(aItem,{"DA1_CODPRO", DA1->DA1_CODPRO, NIL})
				Aadd(aItem,{"DA1_PRCVEN", DA1->DA1_PRCVEN, NIL})									
			EndIf
				
			aadd(aItens,aItem)	
			DA1->(DbSkip())
		EndDo

		If lInclui //Inclui nova linha
			aItem := {}
			cItem := Soma1(cItem)
			nPrcVen := U_DaxImp('SBZ', M->BZ_CUSTD,@aPrcIcm)
			aAdd(aItem,{"DA1_ITEM", cItem,NIL})	
			Aadd(aItem,{"DA1_CODPRO", cProduto, NIL}) 
			Aadd(aItem,{"DA1_XCUSTD", M->BZ_CUSTD, NIL})
			Aadd(aItem,{"DA1_XMARG", 2.5, NIL})
			Aadd(aItem,{"DA1_XPRCM0", aPrcIcm[1], NIL})
			Aadd(aItem,{"DA1_XPRCM4", aPrcIcm[2], NIL})
			Aadd(aItem,{"DA1_XPRCM7", aPrcIcm[3], NIL})
			Aadd(aItem,{"DA1_XPCM12", aPrcIcm[4], NIL})
			Aadd(aItem,{"DA1_XPCM18", aPrcIcm[5], NIL})
			Aadd(aItem,{"DA1_XPCM17", aPrcIcm[6], NIL})
			Aadd(aItem,{"DA1_XPCM19", aPrcIcm[7], NIL})
			Aadd(aItem,{"DA1_PRCVEN", nPrcVen, NIL})
			aadd(aItens,aItem)			
		EndIf
		
	EndIf

	aAdd(aCab,{"DA0_CODTAB", cCodTab, NIL})

	Omsa010(aCab,aItens,nOpc)
	If lMsErroAuto 
		lRet := .F.
		DisarmTransaction()
		Mostraerro()
	EndIf 
EndIf

Return

//--------------------------------------------------------------
/*/{Protheus.doc} Dx	
Description                                                     
                                                                
@param xParam Parameter Description                             
@return xRet Return Description                                 
@author  -                                               
@since 29/08/2019                                                   
/*/                                                             
//--------------------------------------------------------------
User Function DxRentIt()                        
Local oSay1
Local oSay10
Local oSay4
Local oSay5
Local oSay7
Local nCol1	:= 6
Local nCol2	:= 190
Local nCol3	:= 350
Local aCol2	:= {}
Local aHeader	:= {'Item','Produto','Descrição','Resultado'}
Local aItens	:= {}
Local nLinha	:= 0 
Local nPerDsr	:= 0
Local nResult	:= 0
Private oFont16n:= TFont():New(,9,14,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont16:= TFont():New(,9,14,.F.,.F.,5,.T.,5,.T.,.F.)
Private	nSeleciona	:= 0
Private nRecTMP1	:= 0
Static oDlg


If Select('TMP1') == 0
	return
EndIf

nLinha := TMP1->(Recno())
aSize := MsAdvSize(.F.)
If Empty(TMP1->CK_PRODUTO) .And. TMP1->CK_ITEM == '01'
	Alert('Informe ao menos um item para exibir a margem de rentabilidade.')
	Return
EndIf

MafisEnd()

DbSelectArea('SZD')
SZD->(Dbsetorder(1))
If SZD->(DbSeek(xFilial('SZD') + Alltrim(Str(year(dDatabase))) + PadL(Alltrim(STR(Month(dDataBase))),2,'0')))
    nPerDsr		:= SZD->ZD_PDSR / 100    
EndIf

If Posicione('SA3',1,xFilial('SA3') + M->CJ_XVEND ,'A3_XTIPO') == '2' 
		nPerDsr := 0
EndIf

TMP1->(dbGoTop())
While !TMP1->(EOF())
	If !TMP1->CK_FLAG //.And. !Val(TMP1->CK_XMOTIVO) > 1
				//TRATAMENTO PARA PEDIDO DE AMOSTRA MOSTRAR TUDO ZERADO
		If M->CJ_XTPOPER $ SUPERGETMV('ES_OPZEROR',.T.,'') 
			nResult	:= 0
		//ElseIf Posicione('SA3',1,xFilial('SA3') + M->CJ_XVEND ,'A3_XTIPO') <> '2' 
		//	nResult :=  Round(TMP1->CK_XMGBRUT - TMP1->CK_COMIS1,2)
		Else
			nResult :=  Round(TMP1->CK_XMGBRUT - (TMP1->CK_COMIS1 * nPerDsr) - TMP1->CK_COMIS1,2)
			//nResult := Round(TMP1->CK_XMGBRUT,2)// Round(TMP1->CK_XMGBRUT - TMP1->CK_COMIS1,2)
		EndIf
		aadd(aItens,{TMP1->CK_ITEM,;
							TMP1->CK_PRODUTO,;
							TMP1->CK_DESCRI,;
							Alltrim(Transform(nResult, "@E 999,999,999.99" )) + ' %',;
							TMP1->(Recno());
					})
	EndIf
	TMP1->(dbSkip())
EndDo

If Len(aItens) > 0
	nSeleciona := TmsF3Array(aHeader, aItens, 'Selecione o item' ) 
	If nSeleciona > 0
		nRecTMP1 := aItens[nSeleciona][5]
		aCol2 := U_Rentab('ITORIG')
		aCol3 := U_Rentab('ITATUAL')
	Else
		//Alert('Cancelado pelo usuario')
		TMP1->(DbGoTo(nLinha))
		Return
	EndIf
EndIf 	
	
//DEFINE MSDIALOG oDlg TITLE "Margem de Rentabilidade " + AllTrim(aItens[nSeleciona][3]) FROM 000, 000  TO 800, 750 COLORS 0, 16777215 PIXEL
//DEFINE MSDIALOG oDlg TITLE "Margem de Rentabilidade " + AllTrim(aItens[nSeleciona][3]) FROM aSize[7], 000  TO 600, 750 COLORS 0, 16777215 PIXEL
   DEFINE MSDIALOG oDlg TITLE "Margem de Rentabilidade "+ AllTrim(aItens[nSeleciona][3]) FROM aSize[7], 000  TO 600, 1000 COLORS 0, 16777215 PIXEL


@ 006, nCol1 SAY oSay1 PROMPT "ORÇAMENTO " + Alltrim(M->CJ_NUM) SIZE 100, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 006, 062 SAY oSay4 PROMPT "Vendedor " + Posicione('SA3',1,Xfilial('SA3') + M->CJ_XVEND , 'A3_NOME') SIZE 150, 024 OF oDlg COLORS 0, 16777215 PIXEL
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

TMP1->(DbGoTo(nLinha))
Return



//--------------------------------------------------------------
/*/{Protheus.doc} DxRentIt
Description                                                     
                                                                
@param xParam Parameter Description                             
@return xRet Return Description                                 
@author  -                                               
@since 29/08/2019                                                   
/*/                                                             
//--------------------------------------------------------------
User Function PdRentIt()                        
Local oSay1
Local oSay10
Local oSay4
Local oSay5
Local oSay7
Local nCol1	:= 6
Local nCol2	:= 190
Local nCol3	:= 350
Local aCol2	:= {}
Local aCol2	:= {}
Local aHeader	:= {'Item','Produto','Quantidade','Descrição','Resultado','Valor'}
Local aItens	:= {}
Local nLinha	:= 0 
Local nPerDsr	:= 0
Local nPResult	:= 0
Local nVlResult	:= 0
Private oFont16n:= TFont():New(,9,14,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont16:= TFont():New(,9,14,.F.,.F.,5,.T.,5,.T.,.F.)
Private	nSeleciona	:= 0
Private nRecSC6	:= 0
Private lSZL	:= .F.
Static oDlg
aSize := MsAdvSize(.F.)

If !IsinCallStack('MATA410') .And. !IsinCallStack('MATA440')
	Return //tratamento para não chamar a partir do orçamento
EndIf

nLinha := SC5->(Recno())
DbSelectArea('SZD')
SZD->(Dbsetorder(1))
If SZD->(DbSeek(xFilial('SZD') + Alltrim(Str(year(dDatabase))) + PadL(Alltrim(STR(Month(dDataBase))),2,'0')))
    nPerDsr		:= SZD->ZD_PDSR / 100    
EndIf

If Posicione('SA3',1,xFilial('SA3') + SC5->C5_VEND1 ,'A3_XTIPO') == '2' 
	nPerDsr := 0
EndIf

MafisEnd()

DbSelectArea('SC6')
SC6->(DbSetOrder(1))
If SC6->(dbseek(SC5->C5_FILIAL + SC5->C5_NUM))
	While SC5->C5_FILIAL + SC5->C5_NUM == SC6->(C6_FILIAL + C6_NUM)
			DbSelectArea('SZL')	
			SZL->(DbSetOrder(1))

			nPResult	:= noRound(SC6->C6_XMGBRUT - (SC6->C6_COMIS1 * nPerDsr) - SC6->C6_COMIS1,2) 
			nVlResult   := xMoeda((SC6->C6_PRCVEN * SC6->C6_QTDVEN),Val(SC6->C6_XMOEDA),1,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2'))

			If SZL->(DbSeek(xFilial('SZL') + SC5->C5_XNUMCJ + SC6->C6_ITEM + SC6->C6_PRODUTO))
				lSZL := .T.
			EndIf

			aadd(aItens,{SC6->C6_ITEM,;
								SC6->C6_PRODUTO,;
								STR(SC6->C6_QTDVEN),;
								Alltrim(Posicione('SB1',1,xFilial('SB1') + SC6->C6_PRODUTO ,'B1_DESC')),;
								Iif( SC5->C5_XTPOPER $ SUPERGETMV('ES_OPZERPE',.T.,''),'0%', Transform( nPResult, "@E 999,999,999.99" ) + ' %'),;
								Transform( NOROUND((nVlResult * (nPResult / 100)  ) ,2), "@E 999,999,999.99" ),;
								SC6->(Recno());
						})
		SC6->(dbSkip())
	EndDo
EndIf

If Len(aItens) > 0
	nSeleciona := TmsF3Array(aHeader, aItens, 'Selecione o item' ) 
	If nSeleciona > 0
		nRecSC6 := aItens[nSeleciona][7]
		aCol2 := U_PedRent('ITORIG')
		aCol3 := U_PedRent('ITATUAL')
	Else
		//Alert('Cancelado pelo usuario')
		SC5->(DbGoTo(nLinha))
		Return
	EndIf
EndIf 	
	
//DEFINE MSDIALOG oDlg TITLE "Margem de Rentabilidade " + AllTrim(aItens[nSeleciona][3]) FROM 000, 000  TO 800, 750 COLORS 0, 16777215 PIXEL
DEFINE MSDIALOG oDlg TITLE "Margem de Rentabilidade " + AllTrim(aItens[nSeleciona][3]) FROM aSize[7], 000  TO 600, 1000 COLORS 0, 16777215 PIXEL


@ 006, nCol1 SAY oSay1 PROMPT "PEDIDO " + Alltrim(SC5->C5_NUM) SIZE 100, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 006, 062 SAY oSay4 PROMPT "Vendedor " + Posicione('SA3',1,Xfilial('SA3') + SC5->C5_VEND1 , 'A3_NOME') SIZE 150, 024 OF oDlg COLORS 0, 16777215 PIXEL
@ 026, nCol1 SAY oSay5 PROMPT "Analise da Rentabilidade" FONT oFont16n SIZE 150, 24 OF oDlg COLORS 0, 16777215 PIXEL
@ 015, nCol2 - 30 SAY oSay7 PROMPT "Analise com Custo Padrão na Entrada do Pedido" FONT oFont16n SIZE 150, 24 OF oDlg COLORS 0, 16777215 PIXEL
@ 015, nCol3 - 30 SAY oSay9 PROMPT "Analise Com Custo Padrao Atual" FONT oFont16n SIZE 150, 24 OF oDlg COLORS 0, 16777215 PIXEL
@ 030, nCol2 + 20 SAY oSay7 PROMPT "$" SIZE 100, 024 OF oDlg COLORS 0, 16777215 PIXEL
@ 030, nCol2 + 70 SAY oSay7 PROMPT "%" SIZE 100, 024 OF oDlg COLORS 0, 16777215 PIXEL


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
@ 050, nCol2 SAY oSay10 PROMPT Transform( aCol2[1,1], "@E 999,999,999,999.99" ) FONT oFont16n  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //Receita de vendas (com IPI)
@ 060, nCol2 SAY oSay10 PROMPT PADL(Transform( aCol2[2,1], "@E 999,999,999,999.99" ),20)  SIZE 092, 024  OF oDlg COLORS 0, 16777215 PIXEL // IPI
@ 080, nCol2 SAY oSay10 PROMPT Transform( aCol2[4,1], "@E 999,999,999,999.99" )  SIZE 150, 024 OF oDlg COLORS 0, 16777215 PIXEL //Custo de Reposição (Sem Impostos Recuperaveis)
@ 070, nCol2 SAY oSay10 PROMPT Transform( aCol2[3,1], "@E 999,999,999,999.99" )  FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL // Receita de vendas (sem IPI)
@ 090, nCol2 SAY oSay10 PROMPT Transform( aCol2[5,1], "@E 999,999,999,999.99" )  FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //Geração Bruta de Caixa
@ 110, nCol2 SAY oSay10 PROMPT Transform( aCol2[6,1], "@E 999,999,999,999.99" )  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //Pis
@ 120, nCol2 SAY oSay10 PROMPT Transform( aCol2[7,1], "@E 999,999,999,999.99" )  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //cofins
@ 130, nCol2 SAY oSay10 PROMPT Transform( aCol2[8,1], "@E 999,999,999,999.99" )  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //ICMS
@ 140, nCol2 SAY oSay10 PROMPT Transform( aCol2[9,1], "@E 999,999,999,999.99" )  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //ICMS PARTILHA
@ 150, nCol2 SAY oSay10 PROMPT Transform( aCol2[10,1], "@E 999,999,999,999.99" )  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //DESPESAS FINANCEIRAS
@ 160, nCol2 SAY oSay10 PROMPT Transform( aCol2[11,1], "@E 999,999,999,999.99" )  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //CUSTO DE FRETE
@ 170, nCol2 SAY oSay10 PROMPT Transform( aCol2[12,1], "@E 999,999,999,999.99" )  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //CUSTO DE Palete
@ 180, nCol2 SAY oSay10 PROMPT Transform( aCol2[13,1], "@E 999,999,999,999.99" )  FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //Margem
@ 190, nCol2 SAY oSay10 PROMPT Transform( aCol2[14,1], "@E 999,999,999,999.99" )  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //Comissão s DSR
@ 200, nCol2 SAY oSay10 PROMPT Transform( aCol2[15,1], "@E 999,999,999,999.99" )  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //DSR
@ 210, nCol2 SAY oSay10 PROMPT Transform( aCol2[16,1], "@E 999,999,999,999.99" ) FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //Comissão c DSR
@ 230, nCol2 SAY oSay10 PROMPT Transform( aCol2[17,1], "@E 999,999,999,999.99" )  FONT oFont16n  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //RESULTADO FINANCEIRO

@ 070, nCol2 + 50 SAY oSay10 PROMPT Transform( aCol2[3,2], "@E 999,999,999,999.99" )  FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL	//Receita de vendas
@ 080, nCol2 + 50 SAY oSay10 PROMPT Transform( aCol2[4,2], "@E 999,999,999,999.99" )  SIZE 150, 024 OF oDlg COLORS 0, 16777215 PIXEL	//Custo de Reposição (Sem Impostos Recuperaveis)
@ 090, nCol2 + 50 SAY oSay10 PROMPT Transform( aCol2[5,2], "@E 999,999,999,999.99" )  FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL	//geração bruta de caixa
@ 110, nCol2 + 50 SAY oSay10 PROMPT Transform( aCol2[6,2], "@E 999,999,999,999.99" )  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL	//pis
@ 120, nCol2 + 50 SAY oSay10 PROMPT Transform( aCol2[7,2], "@E 999,999,999,999.99" )  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL	//cofins
@ 130, nCol2 + 50 SAY oSay10 PROMPT Transform( aCol2[8,2], "@E 999,999,999,999.99" )  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL	//ICMS
@ 140, nCol2 + 50 SAY oSay10 PROMPT Transform( aCol2[9,2], "@E 999,999,999,999.99" )  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL	//ICMS PARTILHA
@ 150, nCol2 + 50 SAY oSay10 PROMPT Transform( aCol2[10,2], "@E 999,999,999,999.99" )  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL	//DESPESAS FINANCEIRAS
@ 160, nCol2 + 50 SAY oSay10 PROMPT Transform( aCol2[11,2], "@E 999,999,999,999.99" )  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL	//CUSTO DE FRETE
@ 170, nCol2 + 50 SAY oSay10 PROMPT Transform( aCol2[12,2], "@E 999,999,999,999.99" )  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL	//CUSTO DE PALETE	
@ 180, nCol2 + 50 SAY oSay10 PROMPT Transform( aCol2[13,2], "@E 999,999,999,999.99" )  FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //Margem
@ 190, nCol2 + 50 SAY oSay10 PROMPT Transform( aCol2[14,2], "@E 999,999,999,999.99" )  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //Comissão s DSR
@ 200, nCol2 + 50 SAY oSay10 PROMPT Transform( aCol2[15,2], "@E 999,999,999,999.99" )  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //DSR
@ 210, nCol2 + 50 SAY oSay10 PROMPT Transform( aCol2[16,2], "@E 999,999,999,999.99" ) FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //Comissão c DSR
@ 230, nCol2 + 50 SAY oSay10 PROMPT Transform( aCol2[17,2], "@E 999,999,999,999.99" )  FONT oFont16n  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //RESULTADO FINANCEIRO


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

SC5->(DbGoTo(nLinha))
Return


/*/{Protheus.doc} UpdFrete 
atualiza frete, chamado no gatilho do CK_QTDVEN                                                     
                                                                
@param xParam Parameter Description                             
@return xRet Return Description                                 
@author  -                                               
@since 29/08/2019                                                   
/*/ 
User Function UpdFrete()
Local nFrete 	:= 0
Local nVlKg     := 0
Local aArea     := GetArea()
local nLinha	:= TMP1->(Recno())
Local nRet		:= 0
Local nTotItens	:= 0
Local nTotPeso	:= 0

SZ5->(DbSetOrder(1))
If SZ5->(DbSeek(xFilial('SZ5') + cFilAnt + M->CJ_XTRANSP))
	nFrete	:= SZ5->Z5_FRETE
    nVlKg := SZ5->Z5_VALOR
EndIf

dbSelectArea("TMP1")
dbGoTop()
While !Eof()
	IF TMP1->CK_UM == 'KG' .And. !("TMP1")->CK_FLAG .And. !Val(TMP1->CK_XMOTIVO) > 1
		nTotItens ++
		nTotPeso	+= TMP1->CK_QTDVEN
	EndIf
	TMP1->(DbSkip())
End


dbSelectArea("TMP1")
dbGoTop()
While !Eof()
    If  !("TMP1")->CK_FLAG .And. !Val(TMP1->CK_XMOTIVO) > 1
        SB1->(dbSetOrder(1))
        If SB1->(DbSeek(xFilial('SB1') + ("TMP1")->CK_PRODUTO )) .And. SB1->B1_PESBRU > 0
            nFrete += (("TMP1")->CK_QTDVEN * SB1->B1_PESBRU) * nVlKg 
			TMP1->CK_XVLFRET :=  ((("TMP1")->CK_QTDVEN * SB1->B1_PESBRU) * nVlKg) + (SZ5->Z5_FRETE / nTotItens)
			If nLinha == TMP1->(Recno())
				If M->CJ_XTPFRET == '2' //CIF - DIGITADO NA MAO
					nRet	:= M->CJ_XVLFRET * (TMP1->CK_QTDVEN / nTotPeso )
				Else
					nRet	:=  ((("TMP1")->CK_QTDVEN * SB1->B1_PESBRU) * nVlKg) + (SZ5->Z5_FRETE / nTotItens)
				EndIf
			EndIf
			U_ClcComis()
        EndIf
    EndIf
    ("TMP1")->(DbSkip())
EndDo

If M->CJ_XTPFRET <> '2'
	M->CJ_XVLFRETE := nFrete
EndIf

TMP1->(DbGoTo(nLinha))

GETDREFRESH()	   
oGetDad:Refresh()

RestArea(aArea) 
Return nRet



User Function VldTab(cCodProd)
Local lRet	:= .T.
Local aArea	:= GetArea()
DA1->(DbSetOrder(1))
If !DA1->(DbSeek(xFilial('DA1') + SUPERGETMV('ES_DAXTAB',.T.,'001',cFilAnt) + cCodProd))
	Alert('Produto ' + Alltrim(Posicione('SB1',1,xFilial('SB1')  + cCodProd , 'B1_DESC'))+ ' sem valor cadastrado na tabela de preço!')
	lRet	:= .F.
EndIf
RestArea(aArea)
Return lRet


User Function AXCADSZE()

AXCADASTRO('SZE','Usuarios - Liberação Comercial')

Return

User Function AXCADCFD()

AXCADASTRO('CFD','Ficha de conteudo de importação')

Return

 /*/{Protheus.doc} OrcTrigger
	Roda os gatilhos para atualizar o preço qdo atualizar condição de pagamento
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
User Function OrcTrigger(cCondPag)
Local nIt    
Local aArea := GetArea()  
DbSelectArea("TMP1")
TMP1->(DbGotop())  //TMP1 eh o arquivo temporario usado pela rotina padrao MATA415 onde tem os itens do orcamento
nIt := 0
Do While TMP1->(!eof())
	nIt++
	if !TMP1->CK_FLAG .and. !empty(TMP1->CK_PRODUTO)   //ITEM do orcamento nao ta deletado
		
	//	If ExistTrigger("CK_PRODUTO")
	//		RunTrigger(2, VAL(TMP1->CK_ITEM), nil, nil, "CK_PRODUTO") 
	//	Endif
		MAFISEND()
		TMP1->CK_PRUNIT := U_DAXIMP('SCJ')
		
	/*	TMP1->CK_VALOR := a410Arred(TMP1->CK_QTDVEN * TMP1->CK_PRCVEN,"CK_VALOR")
		If (  TMP1->(FieldPos("CK_PRUNIT")) > 0 .And.;
			TMP1->(FieldPos("CK_DESCONT")) > 0 .And.;
			TMP1->(FieldPos("CK_VALDESC")) > 0)
			nAnterior       := TMP1->CK_PRCVEN // Para compatibilizar com A415Descon
			TMP1->CK_PRCVEN := TMP1->CK_PRCVEN // Para compatibilizar com A415Descon
			If TMP1->CK_DESCONT > 0
				TMP1->CK_DESCONT := 0  // Para compatibilizar com A415Descon
				TMP1->CK_VALDESC := 0
			EndIf
		EndIf	*/
	
	Endif
	TMP1->(DbSkip())
Enddo
TMP1->(DbGotop())

//A415Total()

GetDRefresh()

RestArea(aArea)
Return cCondPag


/*/{Protheus.doc} LimpaExc
	(long_description)
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
User Function LimpaExc()
Local cRet	:= M->CJ_ZZEXCEC
Local aArea := GetArea()  


//Limpo os campos
M->CJ_ZZOBSLO := Space(TAMSX3('CJ_ZZOBSLO')[1])
M->CJ_ZZSELO  := 'N'
M->CJ_ZZLAUDO := 'N'
M->CJ_ZZOBSLA := Space(TAMSX3('CJ_ZZOBSLA')[1])
M->CJ_ZZPALE  := '1'
M->CJ_ZZOBSPA := Space(60)
M->CJ_ZZOUTRO := 'N'
M->CJ_ZZOUTXT := Space(TAMSX3('CJ_ZZOUTXT')[1])
M->CJ_ZZNEGOC := 0


If cRet == 'N'
	TMP1->(DbGotop())
	Do While TMP1->(!eof())
		if !TMP1->CK_FLAG .and. !empty(TMP1->CK_PRODUTO)   //ITEM do orcamento nao ta deletado
			TMP1->CK_XPALET := 0
			U_ClcComis()
		Endif
		TMP1->(DbSkip())
	Enddo
	TMP1->(DbGotop())
EndIf
GetDRefresh()

RestArea(aArea)
Return cRet 



 /*/{Protheus.doc} IsNegoci()
	Valida se pode atualizar preço de venda
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
User Function IsNegoci()
lRet	:= .T.

If TMP1->CK_PRCVEN > 0
	lRet := .F.
EndIf

Return lRet

/*/{Protheus.doc} GatPrcCK
Gatilho que atualiza todos os preços dos itens, de acordo com a tabela de preços do cliente, caso o cliente seja alterado
@author Giane
@since 22/09/2015
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function GatPrcCK()
Local nIt    
Local aArea := GetArea()    
Local cVariavel := ReadVar()
Local nAnterior:= 0  
Local cOperRem	:= SupergetMV('ES_OPEREM',.T.,'06|07')
Private CK_DESCONT := 0   

If M->CJ_XTPOPER $ cOperRem
	M->CJ_TPCARGA := '2'
Else
	If M->CJ_XTPFRET $ '1|3'
		M->CJ_TPCARGA := '1'
	Else
		M->CJ_TPCARGA := '2'
	EndIf	
EndIf


DbSelectArea("TMP1")
TMP1->(DbGotop())  //TMP1 eh o arquivo temporario usado pela rotina padrao MATA415 onde tem os itens do orcamento
nIt := 0
Do While TMP1->(!eof())
	nIt++
	if !TMP1->CK_FLAG .and. !empty(TMP1->CK_PRODUTO)   //ITEM do orcamento nao ta deletado
		TMP1->CK_OPER := M->CJ_XTPOPER
		TMP1->CK_TES  := MaTesInt(2,M->CJ_XTPOPER,M->CJ_CLIENTE,M->CJ_LOJA,"C",TMP1->CK_PRODUTO,"CK_TES")     
		TMP1->CK_CLASFIS := CodSitTri()
		  
		TMP1->CK_PRUNIT := U_DAXIMP('SCJ')
	
	Endif
	TMP1->(DbSkip())
Enddo
TMP1->(DbGotop())

//A415Total()

GetDRefresh()

RestArea(aArea)
Return &cVariavel


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


 /*/{Protheus.doc} Moeda2
	Converte o valor para a segunda moeda caso necessario
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
User Function Moeda2(nValor)
Local nRet	:= 0
Local cCodProd	:= TMP1->CK_PRODUTO
Local nMoedaC	:= 1


DA1->(DbSetOrder(1))
If DA1->(DbSeek(xFilial('DA1') + SUPERGETMV('ES_DAXTAB',.T.,'001',cFilAnt) + cCodProd))	.And. DA1->DA1_MOEDA == 2
	SBZ->(DbSetOrder(1)) //--B1_FILIAL+B1_COD
	SBZ->(DbSeek(FwxFilial('SBZ')+cCodProd))

	If SBZ->BZ_MCUSTD == '2'
		nMoedaC	:= 2
	EndIf

	nRet			:= xMoeda(nValor,nMoedaC,2,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2'))
EndIf
Return nRet

//Limpa os valores de frete
User FUnction LimpFret()
Local aArea:= GetArea()
dbSelectArea("TMP1")
dbGoTop()

While !Eof()
	If  !("TMP1")->CK_FLAG
		TMP1->CK_XVLFRET := 0
		U_ClcComis()
	EndIf
	("TMP1")->(DbSkip())
EndDo

TMP1->(DbGoTop())
GETDREFRESH()	   
oGetDad:Refresh()
RestArea(aArea)
Return 0




User Function PedRent(cTipo)
Local nFrete 		:= 0
Local cCodCli		:= SC5->C5_CLIENTE
Local cLoja			:= SC5->C5_LOJACLI
Local cCondPag		:= SC5->C5_CONDPAG
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
Local nLinha		:= SC5->(Recno())
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
Local cFilBkp		:= cFilAnt
Local lAtual		:= .T. //indica que ira mostrar os dados atuais qdo for pesquisa por item 
Local lSZL			:= .F.
		
cFilAnt := SC5->C5_FILIAL //tratamento para qdo acessar a partir de outra filial

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

dbSelectArea("SC6")
SC6->(DbSetOrder(1))
If SC6->(DbSeek(xFilial('SC6') + SC5->C5_NUM))
	While xFilial('SC6') + SC5->C5_NUM == SC6->(C6_FILIAL + C6_NUM)
		nMoedaC		:=  1
		nMoedaV		:=  1
		cCodProd 	:= 	SC6->C6_PRODUTO
		nQtdVen 	:=  SC6->C6_QTDVEN
		
		//TRATAMENTO PARA PEDIDO DE AMOSTRA MOSTRAR TUDO ZERADO
		If POSICIONE('SCJ',1,xFilial('SCJ') + SC5->C5_XNUMCJ , 'CJ_XTPOPER') $ SUPERGETMV('ES_OPZERPE',.T.,'')
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


		If cTipo == '2' 

			DbSelectArea('SZC')	
			SZC->(DbSetOrder(1))
			If SZC->(DbSeek(xFilial('SZC') + SC5->C5_XNUMCJ + '1'))
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
				Exit
			EndIf
		ElseIf cTipo $ '3' 
			DA1->(DbSetOrder(1))
			If DA1->(DbSeek(xFilial('DA1') + SUPERGETMV('ES_DAXTAB',.T.,'001',cFilAnt) + cCodProd))	.And. !empty(cCondPag)
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
				nNegociado		:= SC6->C6_PRCVEN * SC6->C6_QTDVEN
				nVlrBase		:= xMoeda(SC6->C6_PRCVEN,VAL(SC6->C6_XMOEDA),1,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2')) * SC6->C6_QTDVEN//transformo em real
				Aadd(aItens,{SC6->(Recno()),nPrcVen,nNegociado})
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
			//nPrcVen			:= TMP1->CK_PRCVEN	* nQtdVen//xMoeda(DA1->DA1_XCUSTD,nMoedaC,nMoedaV,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2'))
			nPrcVen			:= xMoeda(nPrcVen,nMoedaC,1,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2')) 
			nPrcLista		:= nPrcVen			
			nPrcLista := nPrcVen
			nNegociado		:= SC6->C6_PRCVEN * SC6->C6_QTDVEN
			nVlrBase		:=  xMoeda(SC6->C6_PRCVEN,VAL(SC6->C6_XMOEDA),1,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2')) * SC6->C6_QTDVEN //transformo em real
			Aadd(aItens,{SC6->(Recno()),nPrcVen,nNegociado})
		ElseIF cTipo $ 'ITORIG|ITATUAL'

			DbSelectArea('SZL')	
			SZL->(DbSetOrder(1))
			If cTipo == 'ITORIG' 
				SC6->(DbGoTo(nRecSC6))
				IF SZL->(DbSeek(xFilial('SZL') + SC5->C5_XNUMCJ + SC6->C6_ITEM + SC6->C6_PRODUTO))
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
			EndIf
		//	While nSeleciona <> Val(TMP1->CK_ITEM)
		//		TMP1->(DbSkip())
	//		EndDo
			cCodProd 	:= 	SC6->C6_PRODUTO
			nQtdVen 	:=  SC6->C6_QTDVEN	
			DA1->(DbSetOrder(1))
			If DA1->(DbSeek(xFilial('DA1') + SUPERGETMV('ES_DAXTAB',.T.,'001',cFilAnt) + cCodProd))	.And. !empty(cCondPag)
				SBZ->(DbSetOrder(1)) //--B1_FILIAL+B1_COD
				SBZ->(DbSeek(FwxFilial('SBZ')+cCodProd))

				If SBZ->BZ_MCUSTD == '2'
					nMoedaC	:= 2
				If DA1->DA1_MOEDA == 2
					nMoedaV	:= 2
				EndIf

				EndIf
				//nPrcVen			:= TMP1->CK_PRCVEN	* nQtdVen//xMoeda(DA1->DA1_XCUSTD,nMoedaC,nMoedaV,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2'))
				nPrcLista			:= xMoeda(DA1->DA1_XCUSTD,nMoedaC,1,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2')) * nQtdVen //converto para real
				nPrcVen				:= nPrcLista
				nNegociado			:= SC6->C6_PRCVEN * SC6->C6_QTDVEN
				nVlrBase			:= xMoeda(SC6->C6_PRCVEN,VAL(SC6->C6_XMOEDA),1,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2')) * SC6->C6_QTDVEN //transformo em real
				Aadd(aItens,{SC6->(Recno()),nPrcVen,SC6->C6_PRCVEN * SC6->C6_QTDVEN})
			EndIf	
		EndIf

		cTES 		:= SC6->C6_TES
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
					) // 28-Classificacao fiscal)


		MaFisSave()
		SC6->(DbSkip())
	EndDo
EndIf

dbSelectArea("SC6")
SC6->(DbSetOrder(1))
If SC6->(DbSeek(xFilial('SC6') + SC5->C5_NUM)) .And. !lSZL
	While xFilial('SC6') + SC5->C5_NUM == SC6->(C6_FILIAL + C6_NUM)
		IF Len(aItens) > 0
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

			If cTipo $ 'ITORIG|ITATUAL' 
				nItem := nSeleciona
				nPos := aScan(aItens,{|x| x[1]==nRecSC6})
				SC6->(DbGoTo(aItens[nPos][1]))
				nPrcVen		:= aItens[nPos][2]
				nNegociado	:= aItens[nPos][3]
			Else
				nItens++
				nItem++			
				nPrcVen		:= aItens[nItem][2]
				nNegociado	:= aItens[nItem][3]
			EndIf
			

			SB1->(DbSetOrder(1)) //--B1_FILIAL+B1_COD
			SB1->(DbSeek(FwxFilial('SB1')+SC6->C6_PRODUTO))		
			// ------------------------------------
			// CALCULO DO ISS
			// ------------------------------------
			SF4->(DbSeek(FwxFilial('SF4')+SC6->C6_TES))

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

			nNegociado 	:= xMoeda(nNegociado,VAL(SC6->C6_XMOEDA),1,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2')) //converto pra real

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
				cQuery += "  AND '" + SC6->C6_PRODUTO + "' = CFD_COD "
				cQuery += "  AND D_E_L_E_T_ = ' '"
				cQuery += "  GROUP BY CFD_PERVEN, CFD_ORIGEM "

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
					cQuery += "  AND '" + SC6->C6_PRODUTO + "' = CFD_COD "
					cQuery += "  AND D_E_L_E_T_ = ' '"
					cQuery += "  GROUP BY CFD_PERVEN, CFD_ORIGEM "

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
			nFrete		:= SC6->C6_XVLFRET 
			nTotFrete	+= nFrete
			nExcecoes	+= SC6->C6_XPALET //Exceções

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
			nMgLiq		:= (nNegociado - nPrcVen) - nVlrPis - nVlrCof - nVlrIcm - nDifal - SC6->C6_XVLFRET - SC6->C6_XPALET - nDespFin
			//nMgLiq		:= nNegociado - nVlrPis - nVlrCof - nVlrIcm - nDifal - TMP1->CK_XVLFRET - TMP1->CK_XPALET - nDespFin
			nTotMgLiq	+= nMgLiq
			nPMgLiq		:= round((nMgLiq * 100) / nNegociado ,2)
			//nPMgLiq		+= round((nVlrNeg - nPrcVen * 100) / nRecVen ,2) - nAliqPIS - nAliqCOF - nAliqICM - (18 + nAliqFecp - nAliqICM)- round((nDespFin * 100) / nRecVen ,2) - round((nFrete * 100) / nVlrNeg ,2)  - round((nExcecoes * 100) / nVlrNeg ,2) 
			
			nComis		+= nNegociado * (RetComis(nPMgLiq,SC6->C6_PRODUTO) / 100)

			nPComis		+= RetComis(nPMgLiq,SC6->C6_PRODUTO)
			nTotPComis  += RetComis(nPMgLiq,SC6->C6_PRODUTO)

			DbSelectArea('SZD')
			SZD->(Dbsetorder(1))
			If SZD->(DbSeek(xFilial('SZD') + Alltrim(Str(year(dDatabase))) + PadL(Alltrim(STR(Month(dDataBase))),2,'0'))) .And. nPComis > 0
				nPDsr		:= SZD->ZD_PDSR / 100
			EndIf

			If Posicione('SA3',1,xFilial('SA3') + SC5->C5_VEND1 ,'A3_XTIPO') == '2' 
				nPDsr := 0
			EndIf

			If !(cTipo == '2') .And. nPComis > 0
				nPDsr := nPComis * nPDsr
				nDsr += nNegociado * (nPDsr / 100)
			EndIf

			nTotPDsr += nPDsr

			If cTipo $ 'ITORIG|ITATUAL'
				SC6->(DbGoBottom())
			EndIf
		EndIf
		SC6->(DbSkip())
	EndDo
EndIf

If nItens == 0
	If cTipo $ 'ITORIG|ITATUAL'
		nItens := 1
	EndIf
EndIf
MafisEnd()
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
nResult	:= nTotMgLiq - (nComis + nDsr ) 
aadd(aRet,{ ROUND(nResult,2) 	, round((nResult * 100) / nRecVen ,2) })  //Resultado 117

SC5->(DbGoTo(nLinha))

cFilAnt := cFilBkp

Return aRet





//--------------------------------------------------------------
/*/{Protheus.doc} DaxRenta
Description                                                     
                                                                
@param xParam Parameter Description                             
@return xRet Return Description                                 
@author  -                                               
@since 29/08/2019                                                   
/*/                                                             
//--------------------------------------------------------------
User Function PdRent()                        
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
Local nCol2	:= 200
Local nCol3	:= 370
Local nCol4	:= 540
Local aCol2	:= {}
Local aCol3	:= {}
Local aCol4	:= {}
Private oFont16n:= TFont():New(,9,14,.T.,.T.,5,.T.,5,.T.,.F.)
Static oDlg
aSize := MsAdvSize(.F.)

If  !IsinCallStack('MATA410') .And. !IsinCallStack('MATA440')
	Return
EndIf

  //DEFINE MSDIALOG oDlg TITLE "Margem de Rentabilidade" FROM 000, 000  TO 800, 1500 COLORS 0, 16777215 PIXEL
   DEFINE MSDIALOG oDlg TITLE "Margem de Rentabilidade" FROM aSize[7], 000  TO 8000, 1500 COLORS 0, 16777215 PIXEL

    @ 006, nCol1 SAY oSay1 PROMPT "PEDIDO " + Alltrim(SC5->C5_NUM) SIZE 100, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 006, 062 SAY oSay4 PROMPT "Vendedor " + Posicione('SA3',1,Xfilial('SA3') + SC5->C5_VEND1 , 'A3_NOME') SIZE 150, 024 OF oDlg COLORS 0, 16777215 PIXEL
    @ 026, nCol1 SAY oSay5 PROMPT "Analise da Rentabilidade" FONT oFont16n SIZE 150, 24 OF oDlg COLORS 0, 16777215 PIXEL
    @ 015, nCol2 - 30 SAY oSay7 PROMPT "Analise Com Custo Padrao Na Entrada do Pedido" FONT oFont16n SIZE 150, 24 OF oDlg COLORS 0, 16777215 PIXEL
	@ 030, nCol2 SAY oSay7 PROMPT "$" SIZE 100, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 030, nCol2 + 50 SAY oSay7 PROMPT "%" SIZE 100, 024 OF oDlg COLORS 0, 16777215 PIXEL
	
    @ 015, nCol3 - 30 SAY oSay9 PROMPT "Analise Com Custo Padrao Atual" FONT oFont16n SIZE 150, 24 OF oDlg COLORS 0, 16777215 PIXEL
	@ 030, nCol3 SAY oSay7 PROMPT "$" SIZE 100, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 030, nCol3 + 50 SAY oSay7 PROMPT "%" SIZE 100, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 015, nCol4 - 30 SAY oSay9 PROMPT "Analise Alternativa CM de Estoque Atual" FONT oFont16n SIZE 150, 24 OF oDlg COLORS 0, 16777215 PIXEL
	@ 030, nCol4 SAY oSay7 PROMPT "$" SIZE 100, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 030, nCol4 + 50 SAY oSay7 PROMPT "%" SIZE 100, 024 OF oDlg COLORS 0, 16777215 PIXEL	
	
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
	aCol2 := U_PedRent('2')
	aCol3 := U_PedRent('3')
	aCol4 := U_PedRent('4')

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
	
	@ 070, nCol2 + 50 SAY oSay10 PROMPT Alltrim(Transform( aCol2[3,2], "@E 999,999,999,999.99" ))  FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL	//Custo de Reposição (Sem Impostos Recuperaveis)
	@ 080, nCol2 + 50 SAY oSay10 PROMPT Alltrim(Transform( aCol2[4,2], "@E 999,999,999,999.99" ))  SIZE 150, 024 OF oDlg COLORS 0, 16777215 PIXEL	//Custo de Reposição (Sem Impostos Recuperaveis)
	@ 090, nCol2 + 50 SAY oSay10 PROMPT Alltrim(Transform( aCol2[5,2], "@E 999,999,999,999.99" ))  FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL	//geração bruta de caixa
	@ 110, nCol2 + 50 SAY oSay10 PROMPT Alltrim(Transform( aCol2[6,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL	//pis
	@ 120, nCol2 + 50 SAY oSay10 PROMPT Alltrim(Transform( aCol2[7,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL	//cofins
	@ 130, nCol2 + 50 SAY oSay10 PROMPT Alltrim(Transform( aCol2[8,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL	//ICMS
	@ 140, nCol2 + 50 SAY oSay10 PROMPT Alltrim(Transform( aCol2[9,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL	//ICMS PARTILHA
	@ 150, nCol2 + 50 SAY oSay10 PROMPT Alltrim(Transform( aCol2[10,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL	//DESPESAS FINANCEIRAS
	@ 160, nCol2 + 50 SAY oSay10 PROMPT Alltrim(Transform( aCol2[11,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL	//CUSTO DE FRETE
	@ 170, nCol2 + 50 SAY oSay10 PROMPT Alltrim(Transform( aCol2[12,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL	//CUSTO DE Palete
	@ 180, nCol2 + 50 SAY oSay10 PROMPT Alltrim(Transform( aCol2[13,2], "@E 999,999,999,999.99" ))  FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //Margem
	@ 190, nCol2 + 50 SAY oSay10 PROMPT Alltrim(Transform( aCol2[14,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //Comissão s DSR
	@ 200, nCol2 + 50 SAY oSay10 PROMPT Alltrim(Transform( aCol2[15,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //DSR
	@ 210, nCol2 + 50 SAY oSay10 PROMPT Alltrim(Transform( aCol2[16,2], "@E 999,999,999,999.99" ))  FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //Comissão c DSR
	@ 230, nCol2 + 50 SAY oSay10 PROMPT Alltrim(Transform( aCol2[17,2], "@E 999,999,999,999.99" ))  FONT oFont16n  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //RESULTADO FINANCEIRO


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

	@ 070, nCol3 + 50 SAY oSay10 PROMPT Alltrim(Transform( aCol3[3,2], "@E 999,999,999,999.99" ))  FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 080, nCol3 + 50 SAY oSay10 PROMPT Alltrim(Transform( aCol3[4,2], "@E 999,999,999,999.99" ))  SIZE 150, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 090, nCol3 + 50 SAY oSay10 PROMPT Alltrim(Transform( aCol3[5,2], "@E 999,999,999,999.99" ))  FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 110, nCol3 + 50 SAY oSay10 PROMPT Alltrim(Transform( aCol3[6,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 120, nCol3 + 50 SAY oSay10 PROMPT Alltrim(Transform( aCol3[7,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 130, nCol3 + 50 SAY oSay10 PROMPT Alltrim(Transform( aCol3[8,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 140, nCol3 + 50 SAY oSay10 PROMPT Alltrim(Transform( aCol3[9,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 150, nCol3 + 50 SAY oSay10 PROMPT Alltrim(Transform( aCol3[10,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 160, nCol3 + 50 SAY oSay10 PROMPT Alltrim(Transform( aCol3[11,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 170, nCol3 + 50 SAY oSay10 PROMPT Alltrim(Transform( aCol3[12,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 180, nCol3 + 50 SAY oSay10 PROMPT Alltrim(Transform( aCol3[13,2], "@E 999,999,999,999.99" ))  FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //Margem
	@ 190, nCol3 + 50 SAY oSay10 PROMPT Alltrim(Transform( aCol3[14,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //Comissão s DSR
	@ 200, nCol3 + 50 SAY oSay10 PROMPT Alltrim(Transform( aCol3[15,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //DSR
	@ 210, nCol3 + 50 SAY oSay10 PROMPT Alltrim(Transform( aCol3[16,2], "@E 999,999,999,999.99" )) FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //Comissão c DSR
	@ 230, nCol3 + 50 SAY oSay10 PROMPT Alltrim(Transform( aCol3[17,2], "@E 999,999,999,999.99" ))  FONT oFont16n  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //RESULTADO FINANCEIRO

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

	@ 070, nCol4 + 50 SAY oSay10 PROMPT Alltrim(Transform( aCol4[3,2], "@E 999,999,999,999.99" ))  FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 080, nCol4 + 50 SAY oSay10 PROMPT Alltrim(Transform( aCol4[4,2], "@E 999,999,999,999.99" ))  SIZE 150, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 090, nCol4 + 50 SAY oSay10 PROMPT Alltrim(Transform( aCol4[5,2], "@E 999,999,999,999.99" ))  FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 110, nCol4 + 50 SAY oSay10 PROMPT Alltrim(Transform( aCol4[6,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 120, nCol4 + 50 SAY oSay10 PROMPT Alltrim(Transform( aCol4[7,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 130, nCol4 + 50 SAY oSay10 PROMPT Alltrim(Transform( aCol4[8,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 140, nCol4 + 50 SAY oSay10 PROMPT Alltrim(Transform( aCol4[9,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 150, nCol4 + 50 SAY oSay10 PROMPT Alltrim(Transform( aCol4[10,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 160, nCol4 + 50 SAY oSay10 PROMPT Alltrim(Transform( aCol4[11,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 170, nCol4 + 50 SAY oSay10 PROMPT Alltrim(Transform( aCol4[12,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL
	@ 180, nCol4 + 50 SAY oSay10 PROMPT Alltrim(Transform( aCol4[13,2], "@E 999,999,999,999.99" ))  FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //Margem
	@ 190, nCol4 + 50 SAY oSay10 PROMPT Alltrim(Transform( aCol4[14,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //Comissão s DSR
	@ 200, nCol4 + 50 SAY oSay10 PROMPT Alltrim(Transform( aCol4[15,2], "@E 999,999,999,999.99" ))  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //DSR
	@ 210, nCol4 + 50 SAY oSay10 PROMPT Alltrim(Transform( aCol4[16,2], "@E 999,999,999,999.99" )) FONT oFont16n SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //Comissão c DSR
	@ 230, nCol4 + 50 SAY oSay10 PROMPT Alltrim(Transform( aCol4[17,2], "@E 999,999,999,999.99" ))  FONT oFont16n  SIZE 092, 024 OF oDlg COLORS 0, 16777215 PIXEL //RESULTADO FINANCEIRO		

  ACTIVATE MSDIALOG oDlg CENTERED

Return


/*/{Protheus.doc} A415Total
Calcula os totais do rodape do orçamento
@author Giane
@since 22/09/2015
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function UpdTotal()

Local aArea   	:= GetArea()
Local aAreaTmp1	:= TMP1->(GetArea())
Local nTotVal 	:= 0
Local nTotDesc	:= 0
Local nPerDesc  := M->CJ_DESC4
Local nVlAux	:= 0
Local nValIpi	:= 0
Local nX  := 0
Local aControl
Local oWnd
Local cVariavel := ReadVar()

oWnd:= GetWndDefault()
aControl := oWnd:aControls

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Soma o os valores e os descontos, mostrando-os na tela³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("TMP1")
dbGotop()
While ( !Eof() )
	If ( !TMP1->CK_FLAG ) //  .And. !Val(TMP1->CK_XMOTIVO) > 1
		IF TMP1->CK_XFIXA == 'S' .And. TMP1->CK_MOEDA == '2'
			nVlAux  :=  (TMP1->CK_PRCVEN * TMP1->CK_QTDVEN) * TMP1->CK_XTAXA
		Else
			nVlAux  :=  xMoeda(A410Arred((TMP1->CK_PRCVEN * TMP1->CK_QTDVEN),"CK_VALOR"),Val(TMP1->CK_MOEDA),1,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2'))
		EndIf
		nValIpi := ((nVlAux * TMP1->CK_XVLIPI)/100)
		nTotVal += nVlAux + nValIpi
		If (TMP1->CK_PRUNIT > TMP1->CK_PRCVEN)
			nVlAux := A410Arred((TMP1->CK_PRUNIT * TMP1->CK_QTDVEN),"CK_VALOR") - A410Arred((TMP1->CK_PRCVEN * TMP1->CK_QTDVEN),"CK_VALOR")
			nTotDesc += xMoeda(nVlAux,Val(TMP1->CK_MOEDA),1,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2'))
		Else
			nTotDesc += xMoeda(TMP1->CK_VALDESC,Val(TMP1->CK_MOEDA),1,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2'))
		EndIf
	EndIf
	dbSelectArea("TMP1")
	dbSkip()
EndDo
nTotDesc += M->CJ_DESCONT
nTotVal  -= M->CJ_DESCONT
nTotDesc += A410Arred(nTotVal*M->CJ_PDESCAB/100,"C6_VALOR")
nTotVal  -= A410Arred(nTotVal*M->CJ_PDESCAB/100,"C6_VALOR")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calcula o Desconto por Total                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nTotVal > 0 .And. FtRegraDesc(4,nTotVal+nTotDesc,@M->CJ_DESC4) <> nPerDesc
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Soma o os valores e os descontos, mostrando-os na tela³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nTotVal := 0
	nTotDesc:= 0
	dbSelectArea("TMP1")
	dbGotop()
	While ( !Eof() )
		If ( !TMP1->CK_FLAG ) //.And. !Val(TMP1->CK_XMOTIVO) > 1
			IF TMP1->CK_XFIXA == 'S' .And. TMP1->CK_MOEDA == '2'
				nTotVal  += (TMP1->CK_PRCVEN * TMP1->CK_QTDVEN) * TMP1->CK_XTAXA
			Else
				nTotVal  += xMoeda(A410Arred((TMP1->CK_PRCVEN * TMP1->CK_QTDVEN),"CK_VALOR"),Val(TMP1->CK_MOEDA),1,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2'))
			EndIf
			If (TMP1->CK_PRUNIT > TMP1->CK_PRCVEN)
				nVlAux := A410Arred((TMP1->CK_PRUNIT * TMP1->CK_QTDVEN),"CK_VALOR") - A410Arred((TMP1->CK_PRCVEN * TMP1->CK_QTDVEN),"CK_VALOR")
				nTotDesc += xMoeda(nVlAux,Val(TMP1->CK_MOEDA),1,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2'))				
			Else
				nTotDesc += xMoeda(TMP1->CK_VALDESC,Val(TMP1->CK_MOEDA),1,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2'))
			EndIf
		EndIf
		dbSelectArea("TMP1")
		dbSkip()
	EndDo
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Soma as variaveis da Enchoice                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTotVal += M->CJ_FRETE
nTotVal += M->CJ_SEGURO
nTotVal += M->CJ_DESPESA
nTotVal += M->CJ_FRETAUT

For nX := 1 To Len(aControl)
	If ValType(aControl[nX]) <> "U" .AND. ValType(aControl[nX]:Cargo)=="C"
		Do Case
		Case ( "Total" $ aControl[nX]:Cargo )
			aControl[nX]:SetText(nTotVal)
		Case ( "Total do Orçamento" $ aControl[nX]:Cargo  )
			aControl[nX]:SetText(nTotVal)			
		Case ( "Desconto" $ aControl[nX]:Cargo  )
			aControl[nX]:SetText(nTotDesc)
		Case ( "Valor" $ aControl[nX]:Cargo )
			aControl[nX]:SetText(nTotVal+nTotDesc)
		EndCase
	EndIf
Next nX

If SCJ->(FieldPos('CJ_XVLTOT')) > 0
	M->CJ_XVLTOT := nTotVal
EndIf

RestArea(aAreaTmp1)
RestArea(aArea)
Return(&cVariavel)

/*/{Protheus.doc} EditCom
	Verifica se pode editar comissao , utilizado no when do campo CK_COMIS1
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
User Function EditCom()
Local lRet := .F.
Local cUsers := SupergetMV('ES_USCOMIS',.T.,'')

SA3->(DbSetOrder(1))
IF !empty(M->CJ_XVEND) .And. SA3->(DbSeek(xFilial('SA3')+ M->CJ_XVEND))
	//Verifico se é PJ
	If SA3->A3_XTIPO == '2' .And. at(UPPER(Alltrim(UsrRetName( retcodusr() ))),UPPER(cUsers)) > 0 
		lRet := .T.
	EndIF
EndIf

Return lRet

/*/{Protheus.doc} CodSitTri
	Copia da função da IMPXFIS.prw para retornar codigo fiscal
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
Static Function CodSitTri()
Local	cSX6FilAnt	:= ''
Local   aSX6 		:= GParMxFis(@cSX6FilAnt) // Parametros
Local 	aPos 	    := GFPMxFis(aSX6)  // FieldPos
Local	cProduto	:=	""
Local	cOrigem 	:=	""
Local	cSitTrib	:=	""
Local	nXProd		:=	0
Local	nPosVal	:=	0
Local	nPosQtdVen	:=	0
Local  dEmissao 	:= CtoD("//")
Local  cCpoProd 	:= ""
Local 	cVarProd 	:= ""
Local 	cVarEmis 	:= ""
Local	nPosC6_TES	:= 0

//Se o preco de venda for menor que o preço de pauta não aplica a redução
//Atende ao Decreto Nº 51703 DE 31/07/2014 PARA RS
If Type("aHeader") <> "U"
	nPosVal    := aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALOR"})
	nPosQtdVen := aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN"})
	nPosC6_TES := aScan(aHeader,{|x| AllTrim(x[2])=="C6_TES"})
EndIf

If aSX6[MV_FISAUCF] .And. FindFunction( "XFciGetOrigem" )
	
	If IsInCallStack( "MATA410" ) // Pedido de venda
		cCpoProd := "C6_PRODUTO"
		cVarProd := "M->C6_PRODUTO"
		dEmissao := M->C5_EMISSAO
	ElseIf IsInCallStack( "MATA415" ) // Orçamento
		cCpoProd := "CK_PRODUTO"
		cVarProd := "M->CK_PRODUTO"
		dEmissao := M->CJ_EMISSAO
	ElseIf IsInCallStack( "FATA300" ) // Oportunidade
		cCpoProd := "ADZ_PRODUT"
		cVarProd := "M->ADZ_PRODUT"
		dEmissao := M->ADY_DATA
	EndIf
	
	If !Empty(cCpoProd) .And. !Empty(cVarProd) .And. !Empty(dEmissao)

		If SX7->X7_CAMPO $ cCpoProd .And. Type(cVarProd) <> "U"
			cProduto := &(cVarProd)
		Elseif Type('aCols')=='A' .And. Type('aHeader')=='A'
			nXProd := aScan(aHeader,{|x| AllTrim(x[2]) == cCpoProd})
			cProduto := aCols[n,nXProd]
		EndIf
		
		cOrigem  := XFciGetOrigem( cProduto , dEmissao )[1]

	EndIf
Endif

If IsInCallStack("MATA415") .And. Empty(cOrigem) .And. (ReadVar() $ "M->CK_PRODUTO|M->CK_OPER|M->CK_TES|M->CJ_XTPOPER")
	cProduto := TMP1->CK_PRODUTO
	If ReadVar() $ "M->CK_PRODUTO" .And. cProduto == SB1->B1_COD .And. TMP1->CK_TES <> SF4->F4_CODIGO
		SF4->(dbSetOrder(1))
		SF4->(MsSeek(xFilial("SF4") + TMP1->CK_TES))
	EndIf
EndIf

If !Empty(cProduto)
	dbSelectArea("SB1")
	dbSetOrder(1)
	MsSeek(xFilial("SB1") + cProduto)
EndIf

If SB1->B1_TS <> "   " .And. nPosC6_TES > 0 .And. SB1->B1_TS == aCols[n,nPosC6_TES]
	dbSelectArea("SF4")
	dbSetOrder(1)
	MsSeek(xFilial("SF4") + SB1->B1_TS)
ElseIf nPosC6_TES > 0 .And. !Empty(aCols[n,nPosC6_TES])
	dbSelectArea("SF4")
	dbSetOrder(1)
	MsSeek(xFilial("SF4") + aCols[n,nPosC6_TES])	
EndIf

If aPos[FP_F4_RDBSICM] .And. ((SF4->F4_RDBSICM == "2") .And. Type('aCols')=='A' .And. ((aCols[n][nPosVal] / aCols[n][nPosQtdVen]) < SB1->B1_INT_ICM))				
	cSitTrib:= "00"
Else
	cSitTrib:= SF4->F4_SITTRIB
EndIf

If Empty(cOrigem)
	If aSX6[MV_ARQPROP] == .T. .And. aSX6[MV_ARQPROD]<>"SBZ"
		cOrigem := SB1->B1_ORIGEM
	Elseif aSX6[MV_ARQPROD]=="SBZ"
		cOrigem := Iif( !Empty( SBZ->BZ_ORIGEM ) , SBZ->BZ_ORIGEM , SB1->B1_ORIGEM )
	Else
		cOrigem := SB1->B1_ORIGEM
	Endif
Endif	     
	
//para produtos integrados com WMS, se a TES movimentar estoque carrega o Serviço,Endereço de Saida
If IsInCallStack( "MATA410" )
	nPosCod    := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
	nPosCodTes := aScan(aHeader,{|x| AllTrim(x[2])=="C6_TES"})
	nPosSer    := aScan(aHeader,{|x| AllTrim(x[2])=="C6_SERVIC"})
	nPosEnd    := aScan(aHeader,{|x| AllTrim(x[2])=="C6_ENDPAD"})

	If nPosSer > 0 .And. IntDl(aCols[n][nPosCod]) .And. !Empty(aCols[n][nPosCodTes])
		SF4->(dbSetOrder(1))
		SF4->(MsSeek(xFilial("SF4")+aCols[n][nPosCodTes]))
		If SF4->(!Eof()) .And. SF4->F4_ESTOQUE == "S"
			SB5->(dbSetOrder(1))
			If SB5->(MsSeek(xFilial("SB5")+aCols[n][nPosCod])) .And. Empty(aCols[n][nPosSer])
				If SB5->(FieldPos("B5_SERVSAI")) > 0
					aCols[n][nPosSer] := SB5->B5_SERVSAI
				EndIf
				If SB5->(FieldPos("B5_ENDSAI")) > 0
					aCols[n][nPosEnd] := SB5->B5_ENDSAI
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

Return cOrigem + cSitTrib



/*/{Protheus.doc} RetXnome
	Retorna o nome do cliente ou fornecedor na MATA410
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
User Function RetXnome()
Local cTab	:= 'SA1'
Local cCampo	:= 'A1_NOME'
Local cRet	:= ''

If M->C5_TIPO $ 'D|B'
	cTab	:= 'SA2'
	cCampo	:= 'A2_NOME'
EndIf

&(cTab)->(DbSetOrder(1))
&(cTab)->(DbSeek(xFilial(cTab) + M->C5_CLIENTE + M->C5_LOJACLI))

cRet := &(cTab+'->'+cCampo)

Return cRet


 /*/{Protheus.doc} ClearMot()
	Limpo os motivos no momento da copia
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
User Function ClearMot()
Local cVariavel := ReadVar()
Local aArea		:= GetArea()
Local nPos		:= TMP1->(Recno())
If IsInCallStack('A415Copia')
	TMP1->(DbGotop())
	Do While TMP1->(!eof())
		if !TMP1->CK_FLAG 
			TMP1->CK_XMOTIVO := '000000'
			TMP1->CK_XJUSTIF := ''
			TMP1->CK_PRCVEN := TMP1->CK_PRUNIT
			TMP1->CK_VALOR  := Round(TMP1->CK_QTDVEN*TMP1->CK_PRCVEN,6)
		Endif
		TMP1->(DbSkip())
	Enddo
	TMP1->(DbGoTo(nPos))
	GETDREFRESH()	   
	oGetDad:Refresh()	
EndIf

RestArea(aArea)
Return .T.


/*/{Protheus.doc} VldQuant
	Valida se a quantidade é multipla da segunda unidade do produto
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
User Function VldQuant(nQuant)
Local lRet	:= .T.

SB1->(DbSetOrder(1))
If SB1->(DbSeek(xFilial('SB1') + TMP1->CK_PRODUTO)) .And. !Empty(SB1->B1_SEGUM) .And. SB1->B1_CONV > 0
	If Mod(nQuant,SB1->B1_CONV) > 0 
		Alert('Valor Invalido!' + CRLF + 'Favor informar um numero multiplo de ' + Alltrim(Str(SB1->B1_CONV)))
		lRet := .F.
	EndIf
EndIf

Return lRet


 /*/{Protheus.doc} VldTransp
	(long_description)
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
User Function VldTransp(cTransp)
Local lRet := .T.

If M->CJ_XTPFRET == '3' .And. Empty(cTransp)
	Alert('Favor informar transportadora!')
	lRet := .F.
EndIf
Return lRet



User Function DaxLib(lJob)
Local lRet 		:= .T.
Local cPedido	:= SC9->C9_PEDIDO
Default lJob	:= .F.
/*
SC5->(DbSetOrder(1))
If SC5->(DbSeek(xFilial('SC5') + SC9->C9_PEDIDO))
	SCJ->(DbSetOrder(1))
	If SCJ->(DbSeek((xFilial('SCJ') + SC5->C5_XNUMCJ)))
		If SCJ->CJ_XFATPAR == '2'//Não Permite faturamento parcial
			SC6->(DbSetOrder(1))
			If SC6->(DbSeek(xFilial('SC6') + SC9->(C9_PEDIDO + C9_ITEM + C9_PRODUTO )))
				If (SC9->C9_BLEST <> '  ' .Or. SumQtd() < SC6->C6_QTDVEN) .And. Empty(SC9->C9_IDDCF)
					//Se não liberou total , altero o pedido de venda pra voltar ao status de não liberado
					lRet := .F.
					SC9->(DbSetOrder(1))
					If SC9->(DbSeek(xFilial('SC9') + cPedido))
						While SC9->(C9_FILIAL + C9_PEDIDO) == xFilial('SC9') + cPedido
							RecLock('SC9',.F.)
							SC9->C9_BLEST := '02'
							SC9->C9_BLWMS := '01'
							SC9->C9_XLOGEST := UsrRetName( retcodusr() ) + ";" + DTOC(dDataBase) + ";" + Time()  + ";" + FUNNAME() + " U_DaxLib;" + SC9->C9_BLEST
							SC9->C9_XLOGWMS := UsrRetName( retcodusr() ) + ";" + DTOC(dDataBase) + ";" + Time()  + ";" + FUNNAME() + " U_DaxLib;" + SC9->C9_BLWMS
							MsUnlock()
							SC9->(DbSkip())
						EndDo
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
EndIf*/
Return lRet


Static Function SumQtd()
Local nQtd := 0
Local cQuery	:= ''
Local cAliasQry := GetNextAlias()

cQuery := "SELECT SUM(C9_QTDLIB) AS QTD "
cQuery += "  FROM " + RetSQLTab('SC9')
cQuery += "  WHERE  "
cQuery += "  C9_FILIAL = '" + xFilial('SC9') + "' AND C9_PEDIDO = '" + SC9->C9_PEDIDO + "'  "
cQuery += " AND C9_ITEM = '" + SC9->C9_ITEM + "'  "
cQuery += " AND C9_PRODUTO = '" + SC9->C9_PRODUTO + "'  "
cQuery += "  AND SC9.D_E_L_E_T_ = ' '"

TcQuery cQuery new Alias ( cAliasQry )

(cAliasQry)->(dbGoTop())

If !(cAliasQry)->(EOF())
	nQtd := (cAliasQry)->QTD
EndIf

(cAliasQry)->(DbCloseArea())

Return nQtd
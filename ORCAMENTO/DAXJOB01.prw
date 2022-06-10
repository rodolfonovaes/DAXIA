#INCLUDE "TOPCONN.CH"	
#INCLUDE "TBICONN.CH" 
#INCLUDE "PROTHEUS.CH"
 /*/{Protheus.doc} DaxJob01
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
User Function DaxJob01()
Local aParam      := {}
Local aParMoeda 	:= {}
Local aRetMoeda   := {}
Local aRet        := {}
Local aArea	:= GetArea()
PRIVATE lEnd

aAdd(aParam, {1, "De"   , CriaVar('B1_COD',.F.) ,  ,, 'SB1',, 60, .F.} )
aAdd(aParam, {1, "Até"   , CriaVar('B1_COD',.F.) ,  ,, 'SB1',, 60, .F.} )

If POSICIONE('SM2',1,dDatabase,'M2_MOEDA2') > 0 
	SBZ->(DbSetOrder(1))
	If IsInCallStack('U_AVCADGE')
		Processa({|| U_DAXTAB({'     ','ZZZZZZ'})},"Processando Registros","Atualizando tabela de preço da " + ALLTRIM(FWFilialName())+", Aguarde...")
	ELse
		If ParamBox(aParam,'Tabela de Preço',aRet) 
			Processa({|| U_DAXTAB(aRet)},"Processando Registros","Atualizando tabela de preço, Aguarde...")
		Else    
			Alert('Cancelado pelo usuario')
		EndIf
	EndIF
Else    
	aAdd(aParMoeda, {1, "Dolar"   , 0.123456 ,  ,, ,, 60, .T.} )
    Alert('Favor cadastrar a cotação do dolar para o dia.')
	If ParamBox(aParMoeda,'Tabela de Preço',aRetMoeda) 
		SM2->(DbSetOrder(1))
		If SM2->(DbSeek(dDataBase))
			RecLock('SM2',.F.)
			SM2->M2_MOEDA2 := aRetMoeda[1]
			MsUnlock()
		EndIF
		Processa({|| U_DAXTAB({'     ','ZZZZZZ'})},"Processando Registros","Atualizando tabela de preço, Aguarde...")
	EndIf
EndIf
RestArea(aArea)
Return(.T.)


 /*/{Protheus.doc} UpdDA1
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
User Function DAXTAB(aRet)
Local nOpc := 4
Local cCodTab := SUPERGETMV('ES_DAXTAB',.T.,'001')
Local nPCustFin := SUPERGETMV('ES_CUSTFIN',.T.,2.5)
Local cProduto := ''
Local nPrcVen := ''
Local nCustd	:= 0
Local cAtivo := "1"
Local cItem  := ""
Local cQuery    := ""
Local aCab	:= {}
Local aItem	:= {}
Local aItemNovo	:= {}
Local aItensNovo	:= {}
Local aItens	:= {}
Local aPrcIcm	:= {}
Local lInclui	:= .T.
Local cAliasQry := GetNextAlias()
Local cCondPag  := '001'
Local n         := 0
Local dDataDe   := Posicione('DA0',1,xFilial('DA0') + cCodTab,'DA0_DATDE')
Local aArea	:= GetArea()
Local nVlrOri   := 0
Local cProd     := ''
Local nCusto    := 0
PRIVATE lMsErroAuto := .F.
/*
GETMV('ES_DTDA0')
RecLock( "SX6" , .F. )
SX6->X6_CONTEUD	:= DTOS(dDataBase)
SX6->( MsUnLock() )
*/
Conout('DAXTAB - Inicio do processo - ' + time())
//Atualizo MP e PI
UpdPA(aRet)

cQuery := "	SELECT DISTINCT BZ_COD, BZ_CUSTD ,BZ_MARKUP, B1_XMOEDVE ,B1_TIPO ,ROW_NUMBER() OVER(ORDER BY BZ_COD) AS QTD ,SBZ.R_E_C_N_O_ AS REC " 
cQuery += " FROM " + RetSqlName( "SBZ" ) + " SBZ "
cQuery += " INNER JOIN " + RetSqlName( "SB1" ) + " SB1 "
cQuery += " ON SB1.B1_COD = SBZ.BZ_COD AND SB1.D_E_L_E_T_ = ' ' AND B1_FILIAL = '" + xFilial('SB1') + "' "
cQuery += " WHERE SBZ.D_E_L_E_T_ = ' ' AND "
cQuery += "		SBZ.BZ_FILIAL =  '" +  xFilial('SBZ') + "' AND " 
cQuery += "     SBZ.BZ_COD >=  '" + aRet[1] + "'	AND "	  		
cQuery += "     SBZ.BZ_COD <=  '" + aRet[2] + "'	AND "	  		
//cQuery += "     SBZ.BZ_CUSTD > 0  AND "	  		
cQuery += "     (SB1.B1_TIPO = 'ME' OR  "	  		
cQuery += "     SB1.B1_TIPO = 'PA'  OR  SB1.B1_TIPO = 'PI') AND "
cQuery += "     SB1.B1_MSBLQL = '2'   "		  		
cQuery += "     GROUP BY BZ_COD,BZ_CUSTD,BZ_MARKUP,B1_XMOEDVE , B1_TIPO ,SBZ.R_E_C_N_O_ "

If Select(cAliasQry) > 0
    (cAliasQry)->(DbCloseArea())
EndIf

TcQuery cQuery new Alias ( cAliasQry )
If !(cAliasQry)->(Eof())	
    
    (cAliasQry)->(DbGoBottom())
    ProcRegua((cAliasQry)->QTD)
    (cAliasQry)->(DbGoTop())

    While !(cAliasQry)->(Eof())	
		Conout('DAXTAB - Incluindo produto no array - ' +Alltrim((cAliasQry)->BZ_COD) + " - " + time())
        DA1->(DbSetOrder(1))
        IncProc()
		IF lEnd
        	MsgStop("Cancelado pelo usuário", "Atenção")
    	ENDIF
        If aScan(aItens,{|x| AllTrim(x[1][2])==Alltrim((cAliasQry)->BZ_COD)}) == 0
            If DA1->(DbSeek(xFilial('DA1') + cCodTab + (cAliasQry)->BZ_COD))          
                cItem := DA1->DA1_ITEM
                aItem := {}
                nPrcVen := U_DaxImp('SBZ', DA1->DA1_PRCVEN,@aPrcIcm,(cAliasQry)->BZ_COD)
                lInclui := .F.
                Aadd(aItem,{"DA1_CODPRO", Alltrim((cAliasQry)->BZ_COD), NIL})
                aAdd(aItem,{"LINPOS","DA1_ITEM", cItem})              
                Aadd(aItem,{"AUTDELETA","N",Nil})	                
                Aadd(aItem,{"DA1_XCUSTD", (cAliasQry)->BZ_CUSTD, NIL})
                Aadd(aItem,{"DA1_XMARG" , (cAliasQry)->BZ_MARKUP, NIL})//TODO
                Aadd(aItem,{"DA1_XPRCM0", aPrcIcm[1], NIL})//TODO
                Aadd(aItem,{"DA1_XPRCM4", aPrcIcm[2], NIL})//TODO
                Aadd(aItem,{"DA1_XPRCM7", aPrcIcm[3], NIL})//TODO
                Aadd(aItem,{"DA1_XPCM12", aPrcIcm[4], NIL})//TODO
                Aadd(aItem,{"DA1_XPCM18", aPrcIcm[5], NIL})//TODO
                Aadd(aItem,{"DA1_XPCM17", aPrcIcm[6], NIL})//TODO
                Aadd(aItem,{"DA1_XPCM19", aPrcIcm[7], NIL})//TODO
                Aadd(aItem,{"DA1_MOEDA", Val( (cAliasQry)->B1_XMOEDVE), NIL})	
                Aadd(aItem,{"DA1_PRCVEN", nPrcVen, NIL})							
                Aadd(aItem,{"DA1_XCFIN", RetCfin(cCondPag,nPCustFin), NIL})
                aadd(aItens,aItem)
            Else   
                aItemNovo := {}
                nPrcVen := U_DaxImp('SBZ', (cAliasQry)->BZ_CUSTD,@aPrcIcm,(cAliasQry)->BZ_COD)	
                Aadd(aItemNovo,{"DA1_CODPRO", Alltrim((cAliasQry)->BZ_COD), NIL}) 
                aAdd(aItemNovo,{"DA1_ITEM"  , '  ',NIL})
                Aadd(aItemNovo,{"DA1_XCUSTD", (cAliasQry)->BZ_CUSTD, NIL})
                Aadd(aItemNovo,{"DA1_XMARG" , (cAliasQry)->BZ_MARKUP, NIL})
                Aadd(aItemNovo,{"DA1_XPRCM0", aPrcIcm[1], NIL})
                Aadd(aItemNovo,{"DA1_XPRCM4", aPrcIcm[2], NIL})
                Aadd(aItemNovo,{"DA1_XPRCM7", aPrcIcm[3], NIL})
                Aadd(aItemNovo,{"DA1_XPCM12", aPrcIcm[4], NIL})
                Aadd(aItemNovo,{"DA1_XPCM18", aPrcIcm[5], NIL})
                Aadd(aItemNovo,{"DA1_XPCM17", aPrcIcm[6], NIL})
                Aadd(aItemNovo,{"DA1_XPCM19", aPrcIcm[7], NIL})
                Aadd(aItemNovo,{"DA1_MOEDA" , Val( (cAliasQry)->B1_XMOEDVE), NIL})	
                Aadd(aItemNovo,{"DA1_PRCVEN", nPrcVen, NIL})
                Aadd(aItemNovo,{"DA1_XCFIN" , RetCfin(cCondPag,nPCustFin), NIL})
                aadd(aItensNovo,aItemNovo)			
            EndIf
        EndIf

		If xFilial('SBZ') == '0103' .And. Alltrim((cAliasQry)->B1_TIPO) == 'PA'
			SBZ->(DbGoTo((cAliasQry)->REC))
			nVlrOri := SBZ->BZ_CUSTD
			cProd   := SBZ->BZ_COD

			SBZ->(DbSetOrder(1))
			If SBZ->(DbSeek('0102'+cProd))
				If SBZ->BZ_MCUSTD  == '1'
					nCusto := nVlrOri + SuperGetMV('ES_CUSADDR',.F.,0.23,'0102')
				Else
					nCusto := nVlrOri + SuperGetMV('ES_CUSADDD',.F.,0.05,'0102')
				EndIF
				RecLock('SBZ', .F.)
				SBZ->BZ_CUSTD := nCusto
				MsUnlock()
			EndIf

			If SBZ->(DbSeek('0104'+cProd))
				If SBZ->BZ_MCUSTD  == '1'
					nCusto := nVlrOri + SuperGetMV('ES_CUSADDR',.F.,0.40,'0104')
				Else
					nCusto := nVlrOri + SuperGetMV('ES_CUSADDD',.F.,0.08,'0104')
				EndIF
				RecLock('SBZ', .F.)
				SBZ->BZ_CUSTD := nCusto
				MsUnlock()
			EndIf    			
		EndIf
        (cAliasQry)->(DbSkip())   
    EndDo

    (cAliasQry)->(DbCloseArea()) 

    aAdd(aCab,{"DA0_CODTAB" , cCodTab   , NIL})
    aAdd(aCab,{"DA0_DATDE"  , dDataDe , NIL})
    aAdd(aCab,{"DA0_DATATE" , dDatabase , NIL})

    cQuery := "	SELECT MAX(DA1_ITEM) AS ITEM " 
    cQuery += " FROM " + RetSqlName( "DA1" ) + " DA1 "
    cQuery += " WHERE DA1.D_E_L_E_T_ = ' ' AND "
    cQuery += "		DA1.DA1_FILIAL =  '" +  xFilial('DA1') + "' AND " 
    cQuery += "     DA1.DA1_CODTAB =  '" + cCodTab + "'	 "	  		

    If Select(cAliasQry) > 0
        (cAliasQry)->(DbCloseArea())
    EndIf

    TcQuery cQuery new Alias ( cAliasQry )
    If !(cAliasQry)->(Eof())	
        cItem := (cAliasQry)->ITEM
    EndIf

    For n := 1 to len(aItensNovo)
        cItem   := Soma1(cItem)
        aItensNovo[n][2][2] := cItem
        aadd(aItens,aItensNovo[n])
    Next

    If Len(aItens) > 0
    
        begin transaction
        IncProc('Atualizando Registros')
		Conout('DAXTAB - Atualizando produtos Omsa010 - ' + time())
        Omsa010(aCab,aItens,nOpc)
        If lMsErroAuto 
            DisarmTransaction()
            Mostraerro()
        Else
			If !IsInCallStack('U_AVCADGE')
            	MsgInfo('Tabela Atualizada!')
			EndIf
        EndIf
        End transaction 
		Conout('DAXTAB - Registros atualizados na tabela  - ' + time())
        (cAliasQry)->(DbCloseArea())

        If IsInCallStack('U_AVCADGE') .Or. MsgYesNo('Deseja atualizar os orçamentos?') 
            UpdOrca(aItens,aRet)
        EndIf
    EndIf
Else
	If !IsInCallStack('U_AVCADGE')
    	MsgInfo('Não foram encontrados dados para a pesquisa!')
	EndIf
EndIf
RestArea(aArea)
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
Local aArea	:= GetArea()

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

	If &cParc == 0 .Or. Empty(cParc)
		nRet	:= 0
	Else
		nRet := ((nPrcFin / 30) * Round(((&cParc)/nParc),0)) 
	EndIf
EndIf
RestArea(aArea)
Return nRet



Static Function UpdOrca(aItens,aRet)
local n         := 0
Local cCodAnt   := ''
Local nPos      := 0
Local cAliasQry := GetNextAlias()
Local cQuery    := ''
Local nAtu      := 0
Local nValor    := 0
Local aArea	:= GetArea()

cQuery := "	SELECT CK_PRODUTO, SCK.R_E_C_N_O_ AS REC  , CJ_CONDPAG" 
cQuery += " FROM " + RetSqlName( "SCK" ) + " SCK "
cQuery += " INNER JOIN " + RetSqlName( "SCJ" ) + " SCJ "
cQuery += " ON SCJ.CJ_NUM = SCK.CK_NUM AND SCJ.D_E_L_E_T_ = ' ' AND CJ_FILIAL = '" + xFilial('SCJ') + "' "
cQuery += " INNER JOIN " + RetSqlName( "DA1" ) + " DA1 "
cQuery += " ON DA1.DA1_CODPRO = SCK.CK_PRODUTO AND DA1.D_E_L_E_T_ = ' ' AND DA1_FILIAL = '" + xFilial('DA1') + "' "
cQuery += " WHERE SCK.D_E_L_E_T_ = ' ' AND "
cQuery += "		SCK.CK_FILIAL =  '" +  xFilial('SCK') + "'  AND " 
cQuery += "		SCJ.CJ_STATUS = 'A' AND " 
cQuery += "     SCK.CK_PRODUTO >=  '" + aRet[1] + "'	AND "	  		
cQuery += "     SCK.CK_PRODUTO <=  '" + aRet[2] + "'  "	  
cQuery += "     ORDER BY CK_PRODUTO "

aSort( aItens,,, { | x, y | x[1][2] < y[1][2] } )

If Select(cAliasQry) > 0
    (cAliasQry)->(DbCloseArea())
EndIf

TcQuery cQuery new Alias ( cAliasQry )
ProcRegua(Len(aItens))

Begin transaction 
If !(cAliasQry)->(EOF())
    While !(cAliasQry)->(EOF())
        IncProc()
        SCK->(DbGoTo((cAliasQry)->REC))
        SCJ->(DbSetOrder(1))
        If SCJ->(DbSeek(xFilial('SCJ') + SCK->CK_NUM))
            nValor  := U_DaxImp('UPD')
            If Round(nValor,6) <> Round(SCK->CK_PRUNIT,6)
                UpdMargem((cAliasQry)->REC)
                Reclock('SCK',.F.)
                SCK->CK_PRUNIT := nValor
                MsUnlock()
                nAtu++
            EndIf
        EndIf
        (cAliasQry)->(DbSkip())
    EndDo
EndIf
End transaction
If !IsInCallStack('U_AVCADGE')
	MsgInfo(Alltrim(STR(nAtu)) + ' itens de orçamentos atualizados!')
EndIf

RestArea(aArea)
Return  


//Atualizo os PA
Static Function UpdPA(aRet)
Local cAliasQry := GetNextAlias()
Local cQuery    := ''
Local nValor    := 0
Local cProduto  := ''
Local cProdPi   := ''
Local nI        := 0
Local aAux      := {}
Local aAreaSBZ	:= SBZ->(GetArea())
Private cPilha  := ''
Private nChamadas := 0 


Conout('DAXTAB - Atualizando PA - ' + time())

cQuery := "	SELECT CONVERT(INT,G1_NIV) AS NIVEL , BZ_COD , SBZ.R_E_C_N_O_ AS BZREC " 
cQuery += " FROM " + RetSqlName( "SBZ" ) + " SBZ "
cQuery += " INNER JOIN " + RetSqlName( "SG1" ) + " SG1 "
cQuery += " ON SBZ.BZ_COD = SG1.G1_COMP AND SBZ.D_E_L_E_T_ = ' ' AND G1_FILIAL = '" + xFilial('SG1') + "' "
cQuery += " WHERE SG1.D_E_L_E_T_ = ' ' AND SBZ.D_E_L_E_T_ = ' ' AND "
cQuery += "		SBZ.BZ_FILIAL =  '" +  xFilial('SBZ') + "' AND " 
cQuery += "     SBZ.BZ_COD >=  '" + aRet[1] + "'	AND "	  		
cQuery += "     SBZ.BZ_COD <=  '" + aRet[2] + "'	 "	  				  		
cQuery += "     UNION ALL "
cQuery += "	SELECT 0 AS NIVEL , BZ_COD ,SBZ.R_E_C_N_O_ AS BZREC " 
cQuery += " FROM " + RetSqlName( "SBZ" ) + " SBZ "
cQuery += " INNER JOIN " + RetSqlName( "SG1" ) + " SG1 "
cQuery += " ON SBZ.BZ_COD = SG1.G1_COD AND SBZ.D_E_L_E_T_ = ' ' AND G1_FILIAL = '" + xFilial('SG1') + "' "
cQuery += " WHERE SG1.D_E_L_E_T_ = ' ' AND SBZ.D_E_L_E_T_ = ' ' AND "
cQuery += "		SBZ.BZ_FILIAL =  '" +  xFilial('SBZ') + "' AND " 
cQuery += "     SBZ.BZ_COD >=  '" + aRet[1] + "'	AND "	  		
cQuery += "     SBZ.BZ_COD <=  '" + aRet[2] + "'	 "	  				  		
cQuery += "     ORDER BY NIVEL DESC "

If Select(cAliasQry) > 0
    (cAliasQry)->(DbCloseArea())
EndIf

TcQuery cQuery new Alias ( cAliasQry )
If !(cAliasQry)->(Eof())	
    
    (cAliasQry)->(DbGoBottom())
    ProcRegua(Reccount())
    (cAliasQry)->(DbGoTop())

    While !(cAliasQry)->(Eof())	
		Conout('DAXTAB - Atualizando PA do  - '+  Alltrim((cAliasQry)->BZ_COD) +" - "  + time())
        IncProc()
		IF lEnd
        	MsgStop("Cancelado pelo usuário", "Atenção")
    	ENDIF
        nValor := 0
        cProduto := (cAliasQry)->BZ_COD
        
        aAux := U_RetG1(cProduto,'MP|ME')

        For nI := 1 to Len(aAux)
            nValor += aAux[nI,5]
        Next

        aAux := U_RetG1(cProduto,'EM')

        For nI := 1 to Len(aAux)
            nValor += aAux[nI,5]
        Next

        aAux := U_RetG1(cProduto,'GG')

        For nI := 1 to Len(aAux)
            nValor += aAux[nI,5]
        Next

        aAux := U_RetG1(cProduto,'PI')

        For nI := 1 to Len(aAux)
            nValor += aAux[nI,5]
        Next


        aAux := U_RetG1(cProduto,'PA')

        For nI := 1 to Len(aAux)
            nValor += aAux[nI,5]
        Next      

        aAux := U_RetG1(cProduto,'BN')

        For nI := 1 to Len(aAux)
            nValor += aAux[nI,5]
        Next       

        aAux := U_RetG1(cProduto,'SV')

        For nI := 1 to Len(aAux)
            nValor += aAux[nI,5]
        Next    		        

        SBZ->(DbGoTo((cAliasQry)->BZREC))  
        If !SBZ->BZ_XTIPO $ 'MP|ME|EM|GG|SV|BN'
            Reclock('SBZ',.F.)
            SBZ->BZ_CUSTD := xMoeda(nValor,1,Val(SBZ->BZ_MCUSTD),dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2')) //converto de real para a moeda da SBZ
            MsUnlock()
        EndIf

        SG1->(DbSetOrder(2))
        If SG1->(DbSeek(xFilial('SG1') + cProduto))
            While SG1->(G1_FILIAL + G1_COMP) == xFilial('SG1') + cProduto
                Reclock('SG1',.F.)
                SG1->G1_XVALOR :=  xMoeda(nValor,1,Val(SBZ->BZ_MCUSTD),dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2')) * SG1->G1_QUANT
                MsUnlock()
                SG1->(DbSkip())
            EndDo
        EndIf
		Conout('DAXTAB - Fim da Atualizacao PA do  - '+  Alltrim((cAliasQry)->BZ_COD) + " - " + time())
        (cAliasQry)->(DbSkip())
    EndDo
    
EndIf

Conout('DAXTAB - Fim da atualização PA - ' + time())
RestArea(aAreaSBZ)
Return 



//Função recursiva para retornar o valor das arvores dos PI ARVORES SOMOS NOZES
Static Function somaPI(cProd)
Local nRet      := 0
Local aProds    := {}
Local nI        := 0
Local nAux      := 0
Local aArea	:= GetArea()
cPilha += cProd + CRLF

SG1->(DbSetOrder(1))
If SG1->(DbSeek(xFilial('SG1') + cProd))
    If len(cProd) > TAMSX3('G1_COD')[1]
        While SG1->(G1_FILIAL + G1_COD + G1_COMP) == xFilial('SG1') + cProd
               // If !Posicione('SB1',1,xFilial('SB1') + SG1->G1_COMP,'B1_TIPO') $ 'MP|GG'
               //     aadd(aProds,{cProd + SG1->G1_COMP,SG1->(RECNO()) })
               // Else
                    aadd(aProds, {SG1->G1_COMP,SG1->(RECNO()),Posicione('SB1',1,xFilial('SB1') + SG1->G1_COMP,'B1_TIPO') })
               // EndIf
                SBZ->(DbSetOrder(1))
                If SBZ->(DbSeek(xFilial('SBZ') + SG1->G1_COMP))
                    nRet += SG1->G1_QUANT * xMoeda(SBZ->BZ_CUSTD,Val(SBZ->BZ_MCUSTD),1,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2'))
                EndIf
            //EndIf
            SG1->(DbSkip())
        Enddo
    Else
        While SG1->(G1_FILIAL + G1_COD ) == xFilial('SG1') + cProd
                //If !Posicione('SB1',1,xFilial('SB1') + SG1->G1_COMP,'B1_TIPO') $ 'MP|GG'
                //    aadd(aProds,{cProd + SG1->G1_COMP,SG1->(RECNO()) })
                //Else
                    aadd(aProds, {SG1->G1_COMP,SG1->(RECNO()) ,Posicione('SB1',1,xFilial('SB1') + SG1->G1_COMP,'B1_TIPO')})
                //EndIf
            
                SBZ->(DbSetOrder(1))
                If SBZ->(DbSeek(xFilial('SBZ') + SG1->G1_COMP))
                    nRet += SG1->G1_QUANT * xMoeda(SBZ->BZ_CUSTD,Val(SBZ->BZ_MCUSTD),1,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2'))
                EndIf
            //EndIf
            SG1->(DbSkip())
        Enddo   
    EndIf
EndIf

For nI := 1 to Len(aProds)
    If aProds[nI,3] $ 'PI'
        nAux := somaPI(cProd + aProds[nI,1])
    Else
        nAux := somaPI(aProds[nI,1])
    EndIf
    nRet += nAux
    
    nChamadas++

    SG1->(DbGoTo(aProds[nI,2]))
    Reclock('SG1',.F.)
    SG1->G1_XVALOR := nAux
    MsUnlock()    
Next

RestArea(aArea)
Return nRet



Static Function UpdMargem(nRecCK)
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
Local nSCKBkp		:= 0
Local nSeleciona    := 0
Local nAux          := 0
Local aArea	:= GetArea()

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

dbSelectArea('SCK')
SCK->(DbSeek(xFilial('SCK') + SCJ->CJ_NUM))
While SCK->(CK_FILIAL + CK_NUM) == SCJ->(CJ_FILIAL + CJ_NUM)
    nAux++
    If SCK->(Recno()) == nRecCK
        nSeleciona := nAux
    EndIf
    nMoedaC		:=  1
    nMoedaV		:=  1
    cCodProd 	:= 	SCK->CK_PRODUTO
    nQtdVen 	:=  SCK->CK_QTDVEN
    
    cCodProd 	:= 	SCK->CK_PRODUTO
    nQtdVen 	:=  SCK->CK_QTDVEN	
    
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
        nPrcLista			:= xMoeda(DA1->DA1_XCUSTD,nMoedaC,1,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2')) * nQtdVen //converto para real
        nPrcVen				:= nPrcLista
        nNegociado			:= SCK->CK_PRCVEN * SCK->CK_QTDVEN
        nVlrBase			:= xMoeda(SCK->CK_PRCVEN,VAL(SCK->CK_MOEDA),1,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2')) * SCK->CK_QTDVEN //transformo em real
        Aadd(aItens,{SCK->(Recno()),nPrcVen,SCK->CK_PRCVEN * SCK->CK_QTDVEN})
    EndIf	

    cTES 		:= SCK->CK_TES
    nValDesc	:= 0

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

dbSelectArea('SCK')
SCK->(DbSeek(xFilial('SCK') + SCJ->CJ_NUM))
While SCK->(CK_FILIAL + CK_NUM) == SCJ->(CJ_FILIAL + CJ_NUM)
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


        nItem := nSeleciona
        nPos := aScan(aItens,{|x| x[1]==nRecCK})
		If nPos == 0
			loop
		Else
        	SCK->(DbGoTo(aItens[nPos][1]))
		EndIf
        nPrcVen		:= aItens[nPos][2]
        nNegociado	:= aItens[nPos][3]

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
		//nMgLiq		:= nNegociado - nVlrPis - nVlrCof - nVlrIcm - nDifal - SCK->CK_XVLFRET - SCK->CK_XPALET - nDespFin
		nTotMgLiq	+= nMgLiq
		nPMgLiq		:= round((nMgLiq * 100) / nNegociado ,2)
		//nPMgLiq		+= round((nVlrNeg - nPrcVen * 100) / nRecVen ,2) - nAliqPIS - nAliqCOF - nAliqICM - (18 + nAliqFecp - nAliqICM)- round((nDespFin * 100) / nRecVen ,2) - round((nFrete * 100) / nVlrNeg ,2)  - round((nExcecoes * 100) / nVlrNeg ,2) 
		
        SA3->(DbSetOrder(1))
        IF SA3->(DbSeek(xFilial('SA3')+ SCJ->CJ_XVEND)) .And. SA3->A3_XTIPO = '2'
            Reclock('SCK',.F.)
            SCK->CK_COMIS1 := SA3->A3_COMIS
            MsUnlock()
            nComis		+= nNegociado * (SA3->A3_COMIS / 100)
        Else
            Reclock('SCK',.F.)
            SCK->CK_COMIS1  := RetComis(nPMgLiq)
            MsUnlock()
            nComis		+= nNegociado * (RetComis(nPMgLiq) / 100)
        EndIf

        Reclock('SCK',.F.)
        SCK->CK_XMGBRUT := nPMgLiq
        If SCJ->CJ_XTPOPER $ SUPERGETMV('ES_OPZEROR',.T.,'') 
            SCK->CK_XMGBRUT	:= 0
        EndIf				
        MsUnlock()
        
		DbSelectArea('SZD')
		SZD->(Dbsetorder(1))
		If SZD->(DbSeek(xFilial('SZD') + Alltrim(Str(year(dDatabase))) + PadL(Alltrim(STR(Month(dDataBase))),2,'0')))
			nPDsr		:= SZD->ZD_PDSR / 100
		EndIf

		If SA3->A3_XTIPO <> '2'
			nPDsr := RetComis(nPMgLiq) * nPDsr
			nDsr += nNegociado * (nPDsr / 100)
		Else
			nPDsr	:= 0
			nDsr	:= 0
		EndIf
		//SCK->CK_COMIS1  := RetComis(nPMgLiq)  
		
		nTotPDsr += nPDsr
		Exit //sai do loop
	EndIf
	SCK->(DbSkip())
EndDo

MafisEnd()
RestArea(aArea)
Return



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
Static Function RetComis(nMargem)
Local cQuery := ''
Local cAliasQry := GetNextAlias()
Local nRet	:= 0
Local aArea	:= GetArea()

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

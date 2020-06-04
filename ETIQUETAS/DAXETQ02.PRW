#Include "Protheus.CH"
#Include "topconn.ch"
/*======================================================================================+
| Programa............:   DAXETQ02.prw                                                  |
| Autores ............:   daniel.buso@totvs.com.br                            			|
| Data................:   22/10/2019                                                    |
| Descricao / Objetivo:   Browser para consultar Etiquetas por Lotes                    |
| Doc. Origem.........:                                                                 |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
User function DAXETQ02()
	  Local cArqTrb, cIndice1, cIndice2, cIndice3, cIndice4
	  Local cQuery
	Default nAlign 	:= 1 //Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
	Private oBrowse
	Private aRotina		:= MenuDef()
	Private cCadastro 	:= "ETIQUETAS POR LOTES"
	Private aCampos	:= {}, aSeek := {}, aDados := {}, aValores := {}, aFieFilter := {}
	
	//Array contendo os campos da tabela tempor�ria
	AADD(aCampos,{"B8_LOTECTL"		,"C", 15, 0})
	AADD(aCampos,{"B8_LOTEFOR"	   	,"C", 30, 0})
	AADD(aCampos,{"B8_PRODUTO"		,"C", 15, 0})
	AADD(aCampos,{"B1_DESC"			,"C", 40, 0})
	AADD(aCampos,{"B8_QTDORI"		,"N", 14, 2})
	AADD(aCampos,{"B8_SALDO"		,"N", 14, 2})
	AADD(aCampos,{"B1_UM"			,"C", 02, 0})
	AADD(aCampos,{"B8_LOCAL"		,"C", 20, 0})
	AADD(aCampos,{"A2_NOME"			,"C", 40, 0})
	AADD(aCampos,{"B8_ORIGLAN"		,"C",  2, 0})
	AADD(aCampos,{"B8_DFABRIC"		,"D",  8, 0})
	AADD(aCampos,{"B8_DTVALID"		,"D",  8, 0})
	AADD(aCampos,{"B8_DATA"			,"D",  8, 0})
	AADD(aCampos,{"BZ_XMAT"			,"C", 12, 0})
	AADD(aCampos,{"QAA_NOME"		,"C", 30, 0})
	AADD(aCampos,{"B8_XCFABRI"		,"C", 6, 0})
	AADD(aCampos,{"LOCAL"			,"C", 20, 0})
	
	//Antes de criar a tabela, verificar se a mesma j� foi aberta
	If (Select("TRBOP") <> 0)
		dbSelectArea("TRBOP")
		TRBOP->(dbCloseArea ())
	Endif
	
	//Criar tabela tempor�ria
	cArqTrb   := CriaTrab(aCampos,.T.)
	
	//Definir indices da tabela
	cIndice1 := Alltrim(CriaTrab(,.F.))
	cIndice2 := cIndice1
	cIndice3 := cIndice1
	cIndice4 := cIndice1
	cIndice5 := cIndice1
	cIndice1 := Left(cIndice1,5)+Right(cIndice1,2)+"A"
	cIndice2 := Left(cIndice2,5)+Right(cIndice2,2)+"B"
	cIndice3 := Left(cIndice3,5)+Right(cIndice3,2)+"C"
	cIndice4 := Left(cIndice4,5)+Right(cIndice4,2)+"D"
	cIndice5 := Left(cIndice5,5)+Right(cIndice5,2)+"E"
		
	If File(cIndice1+OrdBagExt())
		FErase(cIndice1+OrdBagExt())
	EndIf

	If File(cIndice2+OrdBagExt())
		FErase(cIndice2+OrdBagExt())
	EndIf

	If File(cIndice3+OrdBagExt())
		FErase(cIndice3+OrdBagExt())
	EndIf

	If File(cIndice4+OrdBagExt())
		FErase(cIndice4+OrdBagExt())
	EndIf

	If File(cIndice5+OrdBagExt())
		FErase(cIndice5+OrdBagExt())
	EndIf			
	//Criar e abrir a tabela
	dbUseArea(.T.,,cArqTrb,"TRBOP",Nil,.F.)
	
	/*Criar indice*/
	IndRegua("TRBOP", cIndice1, "B8_LOTECTL"	,,, "Indice Lote DA")
	IndRegua("TRBOP", cIndice2, "B8_LOTEFOR"	,,, "Indice Lote For")
	IndRegua("TRBOP", cIndice3, "B8_PRODUTO"	,,, "Indice Produto")
	IndRegua("TRBOP", cIndice4, "B8_DATA"		,,, "Indice Data Entrada")
	IndRegua("TRBOP", cIndice5, "B8_SALDO"		,,, "Indice Saldo")
	
	dbClearIndex()
	dbSetIndex(cIndice1+OrdBagExt())
	dbSetIndex(cIndice2+OrdBagExt())
	dbSetIndex(cIndice3+OrdBagExt())
	dbSetIndex(cIndice4+OrdBagExt())
	dbSetIndex(cIndice5+OrdBagExt())	
		
	//popular a tabela
	cArq := CriaTrab(aCampos,.F.)
	dbCreate(cArq,aCampos,"DBFCDX")

	cQuery := "SELECT B8_LOTECTL, B8_LOTEFOR, B8_PRODUTO, B1_DESC, B1_UM, B8_QTDORI,B8_XCFABRI, B8_LOCAL AS LOCAL,  B8_SALDO AS SALDO,"
	cQuery += "  CASE WHEN QEK_FORNEC IS NULL AND B8_CLIFOR = '' THEN 'DAXIA DOCE AROMA INDUSTRIA E COMERCIO LTDA'"
	cQuery += "       WHEN QEK_FORNEC IS NULL AND B8_CLIFOR IS NOT NULL THEN (SELECT A2_NOME FROM " + RetSqlName("SA2") + " WHERE A2_COD = B8_CLIFOR AND A2_LOJA = B8_LOJA AND  SA2.D_E_L_E_T_ = '')"
    cQuery += "  ELSE A2_NOME END A2_NOME,"
	cQuery += "       B8_ORIGLAN, B8_DFABRIC, B8_DTVALID, B8_DATA, BZ_XMAT, QAA_NOME,"
	cQuery += "	 CASE WHEN B8_LOCAL = '98' THEN 'PENDENTE' ELSE 'LIBERADO' END B8_LOCAL"
	cQuery += "  FROM " + RetSqlName("SB8") + " SB8 "
	cQuery += " INNER JOIN "  + RetSqlName("SB1") + " SB1 ON B1_COD     = B8_PRODUTO AND SB1.D_E_L_E_T_ = '' "
	cQuery += "  LEFT JOIN "  + RetSqlName("QEK") + " QEK ON QEK_PRODUT = B8_PRODUTO AND QEK_LOTE = B8_LOTECTL AND QEK.D_E_L_E_T_=''"
	cQuery += "  LEFT JOIN "  + RetSqlName("SA2") + " SA2 ON A2_COD     = QEK_FORNEC AND A2_LOJA = QEK_LOJFOR AND SA2.D_E_L_E_T_ = ''"
	cQuery += "  LEFT JOIN "  + RetSqlName("SBZ") + " SBZ ON BZ_FILIAL  = B8_FILIAL  AND BZ_COD  = B8_PRODUTO AND SBZ.D_E_L_E_T_ = ''"
	cQuery += "  LEFT JOIN "  + RetSqlName("QAA") + " QAA ON QAA_FILIAL = BZ_FILIAL  AND BZ_XMAT = QAA_MAT AND QAA.D_E_L_E_T_ = '' "
	cQuery += " WHERE "
	cQuery += "    SB8.D_E_L_E_T_ = ''" 
	cQuery += " ORDER BY B8_LOTECTL, B8_LOTEFOR, B8_PRODUTO, B8_DATA"
	
	TCQUERY cQuery New Alias "TMPOP"
	
	Dbselectarea("TMPOP")
	dbGoTop()
	While TMPOP->(!EOF())
		dbSelectArea("TRBOP")
		RecLock("TRBOP",.T.) 
		TRBOP->B8_LOTECTL	:= TMPOP->B8_LOTECTL
		TRBOP->B8_LOTEFOR	:= TMPOP->B8_LOTEFOR
		TRBOP->B8_PRODUTO	:= TMPOP->B8_PRODUTO
		TRBOP->B1_DESC		:= TMPOP->B1_DESC
		TRBOP->B8_QTDORI	:= TMPOP->B8_QTDORI
		TRBOP->B8_SALDO		:= TMPOP->SALDO
		TRBOP->B1_UM		:= TMPOP->B1_UM
		TRBOP->B8_LOCAL		:= TMPOP->B8_LOCAL
		TRBOP->A2_NOME		:= TMPOP->A2_NOME
		TRBOP->B8_ORIGLAN	:= TMPOP->B8_ORIGLAN
		TRBOP->B8_DFABRIC	:= STOD(TMPOP->B8_DFABRIC)
		TRBOP->B8_DTVALID	:= STOD(TMPOP->B8_DTVALID)
		TRBOP->B8_DATA		:= STOD(TMPOP->B8_DATA)
		TRBOP->BZ_XMAT		:= TMPOP->BZ_XMAT
		TRBOP->QAA_NOME		:= TMPOP->QAA_NOME
		TRBOP->B8_XCFABRI	:= TMPOP->B8_XCFABRI
		TRBOP->LOCAL		:= TMPOP->LOCAL
		MsUnlock()
	TMPOP->(dbSkip())
	EndDo
	TMPOP->(dbCloseArea())
    
	dbSelectArea("TRBOP")
	TRBOP->(DbGoTop())

	//Campos que ir�o compor o combo de pesquisa na tela principal
	Aadd(aSeek,{"Lote DA"  		, {{"","C",15,0, "B8_LOTECTL" 	,"@!"}}, 1, .T. } )
	Aadd(aSeek,{"Lote FOR" 		, {{"","C",18,0, "B8_LOTEFOR" 	,"@!"}}, 2, .T. } )
	Aadd(aSeek,{"Produto"  		, {{"","C",15,0, "B8_PRODUTO" 	,"@!"}}, 3, .T. } )
	Aadd(aSeek,{"Data Entrada"  , {{"","D",08,0, "B8_DATA" 		,"@D"}}, 4, .T. } )
	//Aadd(aSeek,{"Saldo"  		, {{"","N",14,2, "B8_SALDO"		,}}, 5, .T. } )
	
	//Campos que ir�o compor a tela de filtro
	Aadd(aFieFilter,{"B8_LOTECTL"	, "Lote DA"   		, "C", 15, 0,"@!"})
	Aadd(aFieFilter,{"B8_LOTEFOR"	, "Lote For"		, "C", 18, 0,"@!"})
	Aadd(aFieFilter,{"B8_PRODUTO"	, "Produto" 		, "C", 15, 0,"@!"})
	Aadd(aFieFilter,{"B8_DATA"		, "Data Entrada" 	, "D", 08, 0,"@D"})
	Aadd(aFieFilter,{"B8_SALDO"		, "Saldo" 			, "N", 14, 2,"@E 9,999,999.99"})
	
	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( "TRBOP" )
	oBrowse:SetDescription( cCadastro )
	oBrowse:SetSeek(.T.,aSeek)
	oBrowse:SetTemporary(.T.)
	oBrowse:SetLocate()
	oBrowse:SetUseFilter(.T.)
	oBrowse:SetDBFFilter(.T.)
	oBrowse:SetFilterDefault( "" ) //Exemplo de como inserir um filtro padr�o >>> "TR_ST == 'A'"
	//oBrowse:SetFilterDefault("TRBOP->B8_LOTECTL='"+MV_PAR01+"' .And. TRBOP->B8_LOTEFOR='"+MV_PAR02+"'")
	oBrowse:SetFieldFilter(aFieFilter)
	oBrowse:DisableDetails()
	
	//Detalhes das colunas que ser�o exibidas
	oBrowse:SetColumns(MontaColunas("B8_LOTECTL"	,"Lote DA"			,01,"@!",0,010,0))
	oBrowse:SetColumns(MontaColunas("B8_LOTEFOR"	,"Lote FOR"			,02,"@!",1,010,0))
	oBrowse:SetColumns(MontaColunas("B8_PRODUTO"	,"Produto"			,03,"@!",1,010,0))
	oBrowse:SetColumns(MontaColunas("B1_DESC"		,"Descricao"		,04,"@!",1,020,0))
	oBrowse:SetColumns(MontaColunas("B8_QTDORI"		,"Quantidade"		,05,"@E 9,999,999.99",1,010,0))
	oBrowse:SetColumns(MontaColunas("B8_SALDO"		,"Saldo"			,06,"@E 9,999,999.99",1,010,0))
	oBrowse:SetColumns(MontaColunas("B1_UM"			,"UM"				,07,"@!",1,005,0))
	oBrowse:SetColumns(MontaColunas("B8_LOCAL"		,"Status"			,08,"@!",1,010,0))
	oBrowse:SetColumns(MontaColunas("A2_NOME"		,"Fornecedor"		,09,"@!",1,020,0))
	oBrowse:SetColumns(MontaColunas("B8_ORIGLAN"	,"Origem"			,10,"@!",1,005,0))
	oBrowse:SetColumns(MontaColunas("B8_DFABRIC"	,"Fabricacao"		,11,"@!",1,010,0))
	oBrowse:SetColumns(MontaColunas("B8_DTVALID"	,"Validade"			,12,"@!",1,010,0))
	oBrowse:SetColumns(MontaColunas("B8_DATA"		,"Entrada"			,13,"@!",1,010,0))	
	oBrowse:SetColumns(MontaColunas("BZ_XMAT"		,"Responsavel"		,14,"@!",1,010,0))
	oBrowse:SetColumns(MontaColunas("QAA_NOME"		,"Nome Resp."		,15,"@!",1,020,0))		
	oBrowse:Activate()
	
	If !Empty(cArqTrb)
		Ferase(cArqTrb+GetDBExtension())
		Ferase(cArqTrb+OrdBagExt())
		cArqTrb := ""
		TRBOP->(DbCloseArea())
		delTabTmp('TRBOP')
    	dbClearAll()
	Endif
return(Nil)

//------------------------------------------------------------------------------------//
//Rotina para montagem de colunas
//------------------------------------------------------------------------------------//
Static Function MontaColunas(cCampo,cTitulo,nArrData,cPicture,nAlign,nSize,nDecimal)
	Local aColumn
	Local bData 	:= {||}
	Default nAlign 	:= 1 //Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
	
	If nArrData > 0
		bData := &("{||" + cCampo +"}") //&("{||oBrowse:DataArray[oBrowse:At(),"+STR(nArrData)+"]}")
	EndIf

	aColumn := {cTitulo,bData,,cPicture,nAlign,nSize,nDecimal,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}}

	Return {aColumn}

//------------------------------------------------------------------------------------//
//Rotina MENUDEF
//------------------------------------------------------------------------------------//
Static Function MenuDef()
	//Local aArea		:= GetArea()
	Local aRotina 	:= {}
	Local aRotina1  := {}
	
	AADD(aRotina1, {"Etiqueta por LOTES" , "U_DAXPRT01()"		, 0, 6, 0, Nil })
	AADD(aRotina,  {"Pesquisar"			 , "PesqBrw"		, 0, 1, 0, .T. })
	AADD(aRotina,  {"Imprimir" 			 , aRotina1         , 0, 4, 0, Nil })
	
Return( aRotina )

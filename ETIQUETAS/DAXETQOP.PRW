#Include "Protheus.CH"
#Include "topconn.ch"
/*======================================================================================+
| Programa............:   DAXETQ02.prw                                                  |
| Autores ............:   daniel.buso@totvs.com.br                            			|
| Data................:   22/10/2019                                                    |
| Descricao / Objetivo:   Browser para consultar Etiquetas por OP´s                     |
| Doc. Origem.........:                                                                 |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                  |
+======================================================================================*/
User function DAXETQOP()
  	Local cArqTrb, cIndice1, cIndice2, cIndice3, cIndice4
	Local cQuery3
	Local bKeyF5     := SetKey(VK_F5)
	Private oBrowse
	Private aRotina		:= MenuDefOp()
	Private cCadastro	:= "ETIQUETAS POR OPs"
	Private aCampos		:= {}, aSeek := {}, aDados := {}, aValores := {}, aFieFilter := {}
	
	//Array contendo os campos da tabela tempor�ria

    aAdd(aCampos,{"C2_FILIAL"				 ,"C",06,0})
	aAdd(aCampos,{"C2_NUM" 					 ,"C",06,0})
	aAdd(aCampos,{"C2_ITEM" 				 ,"C",02,0})
	aAdd(aCampos,{"C2_SEQUEN"				 ,"C",03,0})
	aAdd(aCampos,{"C2_PRODUTO" 				 ,"C",15,0})
	aAdd(aCampos,{"B1_DESC" 				 ,"C",50,0})
	aAdd(aCampos,{"C2_XLOTE" 				 ,"C",15,0})
	aAdd(aCampos,{"C2_QUANT"				 ,"N",12,2})
	aAdd(aCampos,{"B1_UM"					 ,"C",02,0})
	aAdd(aCampos,{"C2_DATPRI" 				 ,"D",08,0})
	aAdd(aCampos,{"C2_DATPRF" 				 ,"D",08,0})
	aAdd(aCampos,{"C2_EMISSAO" 				 ,"D",08,0})
	aAdd(aCampos,{"C2_LOCAL" 				 ,"C",02,0})
	aAdd(aCampos,{"C2_ROTEIRO" 				 ,"C",TAMSX3('C2_ROTEIRO')[1],0})
	
	//Antes de criar a tabela, verificar se a mesma j� foi aberta
	If (Select("TRBLO") <> 0)
		dbSelectArea("TRBLO")
		TRBLO->(dbCloseArea ())
	Endif
	
	//Criar tabela tempor�ria
	cArqTrb   := CriaTrab(aCampos,.T.)
	
	//Definir indices da tabela
	cIndice1 := Alltrim(CriaTrab(,.F.))
	cIndice2 := cIndice1
	cIndice3 := cIndice1
	cIndice4 := cIndice1

	cIndice1 := Left(cIndice1,5)+Right(cIndice1,2)+"A"
	cIndice2 := Left(cIndice2,5)+Right(cIndice2,2)+"B"
	cIndice3 := Left(cIndice3,5)+Right(cIndice3,2)+"C"
	cIndice4 := Left(cIndice4,5)+Right(cIndice4,2)+"D"
	
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
	
	//Criar e abrir a tabela
	dbUseArea(.T.,,cArqTrb,"TRBLO",Nil,.F.)
	
	/*Criar indice*/
	IndRegua("TRBLO", cIndice1, "C2_NUM"		,,, "Indice Numero")
	IndRegua("TRBLO", cIndice2, "C2_ITEM"		,,, "Indice Item")
	IndRegua("TRBLO", cIndice3, "C2_SEQUEN"		,,, "Indice Sequencia")
	IndRegua("TRBLO", cIndice4, "C2_PRODUTO"	,,, "Indice Produtos")
	
	dbClearIndex()
	dbSetIndex(cIndice1+OrdBagExt())
	dbSetIndex(cIndice2+OrdBagExt())
	dbSetIndex(cIndice3+OrdBagExt())
	dbSetIndex(cIndice4+OrdBagExt())
	
	LoadTable(.F.)

	//Campos que ir�o compor o combo de pesquisa na tela principal
	Aadd(aSeek,{"Numero"  	, {{"","C",06,0, "C2_NUM"     ,"@!"}}, 1, .T. } )
	Aadd(aSeek,{"Item"  	, {{"","C",02,0, "C2_ITEM"    ,"@!"}}, 2, .T. } )
	Aadd(aSeek,{"Sequencia" , {{"","C",03,0, "C2_SEQUEN"  ,"@!"}}, 3, .T. } )
	Aadd(aSeek,{"Produto" 	, {{"","C",15,0, "C2_PRODUTO" ,"@!"}}, 4, .T. } )
	
	//Campos que ir�o compor a tela de filtro
	Aadd(aFieFilter,{"C2_NUM"		, "Numero"   	, "C", 06, 0,"@!"})
	Aadd(aFieFilter,{"C2_ITEM"		, "Item"		, "C", 02, 0,"@!"})
	Aadd(aFieFilter,{"C2_SEQUEN"	, "Sequencia" 	, "C", 03, 0,"@!"})
	Aadd(aFieFilter,{"C2_PRODUTO"	, "Produto" 	, "C", 15, 0,"@!"})
	
	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( "TRBLO" )
	oBrowse:SetDescription( cCadastro )
	oBrowse:SetSeek(.T.,aSeek)
	oBrowse:SetTemporary(.T.)
	oBrowse:SetLocate()
	oBrowse:SetUseFilter(.T.)
	oBrowse:SetDBFFilter(.T.)
	oBrowse:SetFilterDefault( "" ) //Exemplo de como inserir um filtro padr�o >>> "TR_ST == 'A'"
	oBrowse:SetFieldFilter(aFieFilter)
	oBrowse:DisableDetails()
	
	//Legenda da grade, � obrigat�rio carregar antes de montar as colunas
	//oBrowse3:AddLegend("TR_ST=='A'","GREEN" 	,"Grupo Administradores")
	//oBrowse3:AddLegend("TR_ST=='C'","BLUE"no  	,"Grupo Cont�bil")
	//oBrowse3:AddLegend("TR_ST=='R'","RED"  	,"Grupo RH")
	
	//Detalhes das colunas que ser�o exibidas
	oBrowse:SetColumns(MontaColunas3("C2_FILIAL"	,"FILIAL"		,01,"@!"))
	oBrowse:SetColumns(MontaColunas3("C2_NUM"		,"OP"			,02,"@!",0,010,0))
	oBrowse:SetColumns(MontaColunas3("C2_ITEM"		,"Item"			,03,"@!",0,005,0))
	oBrowse:SetColumns(MontaColunas3("C2_SEQUEN"	,"Sequencia"	,04,"@!",0,005,0))
	oBrowse:SetColumns(MontaColunas3("C2_PRODUTO"	,"Produto"		,05,"@!",0,010,0))	
	oBrowse:SetColumns(MontaColunas3("B1_DESC"		,"Descricao"    ,06,"@!",0,020,0))
	oBrowse:SetColumns(MontaColunas3("C2_XLOTE"		,"Lote"			,07,"@!",0,010,0))
	oBrowse:SetColumns(MontaColunas3("C2_QUANT"		,"Quantidde"	,08,"@E 9,999,999.99",0,010,0))
	oBrowse:SetColumns(MontaColunas3("B1_UM"		,"UM"			,08,"@!",0,005,0))
	oBrowse:SetColumns(MontaColunas3("C2_DATPRI"	,"Dt. Inicio"	,09,"@!",0,010,0))
	oBrowse:SetColumns(MontaColunas3("C2_DATPRF"	,"Dt. Entrega"	,10,"@!",0,010,0))

	SetKey (VK_F5 , {|| Processa({|lEnd| LoadTable(.T.)},'Impressao de etiquetas','Atualizando registros...',.T.)}) // Selecionando Servicos...

	oBrowse:Activate()	
	If !Empty(cArqTrb)
		Ferase(cArqTrb+GetDBExtension())
		Ferase(cArqTrb+OrdBagExt())
		cArqTrb := ""
		TRBLO->(DbCloseArea())
		delTabTmp('TRB')
    	dbClearAll()
	Endif

return(Nil)

//------------------------------------------------------------------------------------//
//Rotina para montagem de Colunas
//------------------------------------------------------------------------------------//
Static Function MontaColunas3(cCampo,cTitulo,nArrData,cPicture,nAlign,nSize,nDecimal)
	Local   aColumn
	Local   bData 	:= {||}
	Default nAlign 	:= 1
	
	If nArrData > 0
		bData := &("{||" + cCampo +"}") //&("{||oBrowse3:DataArray[oBrowse3:At(),"+STR(nArrData)+"]}")
	EndIf

	aColumn := {cTitulo,bData,,cPicture,nAlign,nSize,nDecimal,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}}
Return {aColumn}

//------------------------------------------------------------------------------------//
//Rotina MENUDEF
//------------------------------------------------------------------------------------//
Static Function MenuDefOp()
	//Local aArea		:= GetArea()
	Local aRotina 	:= {}
	Local aRotina1  := {}
	
	AADD(aRotina1,  {"Etiqueta por OP"		, "U_DAXPRT02()"	, 0, 6, 0, Nil })
	AADD(aRotina,   {"Pesquisar"			, "PesqBrw"			, 0, 1, 0, .T. })
	AADD(aRotina,   {"Imprimir" 			, aRotina1          , 0, 4, 0, Nil })
	
Return( aRotina )


/*/{Protheus.doc} LoadTable()
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
Static Function LoadTable(lRefresh)
Local cArq	:= ''
Local cQuery3	:= ''
//popular a tabela

dbSelectArea("TRBLO")
TRBLO->(DbGoTop())
While TRBLO->(!EOF())
	RecLock('TRBLO',.F.)
	TRBLO->(DbDelete())
	MsUnlock()
	TRBLO->(DbSkip())
EndDo


cArq := CriaTrab(aCampos,.F.)
dbCreate(cArq,aCampos,"DBFCDX")

cQuery3 := " SELECT C2_FILIAL, C2_NUM, C2_ITEM,C2_SEQUEN, C2_PRODUTO, C2_ROTEIRO , B1_DESC, C2_XLOTE, C2_QUANT, C2_DATPRI, C2_DATPRF, B1_UM ,C2_EMISSAO , C2_LOCAL"
cQuery3 += "   FROM " + RetSqlName("SC2") + " SC2 "	
cQuery3 += "  INNER JOIN "  + RetSqlName("SB1") + " SB1 ON B1_COD = C2_PRODUTO AND SB1.D_E_L_E_T_ = '' "
cQuery3 += "  WHERE SC2.D_E_L_E_T_ = ''"
cQuery3 += "  ORDER BY C2_NUM, C2_ITEM,C2_SEQUEN, C2_PRODUTO"

TCQUERY cQuery3 New Alias "TMPLO"
	
Dbselectarea("TMPLO")
dbGoTop()
While TMPLO->(!EOF())
	dbSelectArea("TRBLO")
	RecLock("TRBLO",.T.) 
	TRBLO->C2_FILIAL 				:= TMPLO->C2_FILIAL
	TRBLO->C2_NUM 					:= TMPLO->C2_NUM
	TRBLO->C2_ITEM 					:= TMPLO->C2_ITEM
	TRBLO->C2_SEQUEN 				:= TMPLO->C2_SEQUEN
	TRBLO->C2_PRODUTO   			:= TMPLO->C2_PRODUTO
	TRBLO->B1_DESC 					:= TMPLO->B1_DESC
	TRBLO->C2_XLOTE	      			:= TMPLO->C2_XLOTE
	TRBLO->C2_QUANT 				:= TMPLO->C2_QUANT
	TRBLO->B1_UM	 				:= TMPLO->B1_UM
	TRBLO->C2_DATPRI  				:= STOD(TMPLO->C2_DATPRI)
	TRBLO->C2_DATPRF 				:= STOD(TMPLO->C2_DATPRF)
	TRBLO->C2_EMISSAO 				:= STOD(TMPLO->C2_EMISSAO)
	TRBLO->C2_LOCAL 				:= TMPLO->C2_LOCAL
	TRBLO->C2_ROTEIRO 				:= TMPLO->C2_ROTEIRO
	MsUnlock()
	TMPLO->(dbSkip())
EndDo
TMPLO->(dbCloseArea())

dbSelectArea("TRBLO")
TRBLO->(DbGoTop())

If lRefresh
	oBrowse:Refresh()
EndIf
Return 
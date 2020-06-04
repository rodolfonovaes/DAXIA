#INCLUDE "DLGV102.ch" 
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APVT100.CH"

Static __lRastro  := AllTrim(SuperGetMV("MV_RASTRO",.F.,"N")) == "S"
Static __cWmsUMI  := AllTrim(SuperGetMV('MV_WMSUMI',.F.,'0'))
Static __lWmsLote := SuperGetMV("MV_WMSLOTE",.F.,.F.)
Static __nOpc     := 0
Static __lLote    := .F.
Static __lSubLote := .F.
Static __dDtIni   := Date()
Static __cHrIni   := Time()

//----------------------------------------------------------
/*/{Protheus.doc} DLGV102 - Conferência de Expedição
Permite que os produtos de um pedido de venda, carga ou
nota fiscal sejam conferidos.

@author  Evaldo Cevinscki Jr.
@version P11
@since   24/07/12
/*/
//----------------------------------------------------------
User Function LGV102()
Local cKey09  := VtDescKey(09)
Local cKey22  := VtDescKey(22)
Local bkey09  := VTSetKey(09)
Local bkey22  := VTSetKey(22)
Local aTela   := {}
Local lRet    := .T.
Local cCodOpe := __cUserID
	
	If SuperGetMv("MV_WMSNEW",.F.,.F.)
		Return U_XWMSV102()
	EndIf
	
	While lRet
		If Empty(cCodOpe)
			WmsMessage(STR0001) // Operador nao cadastrado
			lRet := .F.
		EndIf
		If lRet
			aTela := VtSave()
			VTClear()
	
			If FunName() == "DLGV102"
				@ 0,0 VTSay STR0003 // Selecione:
				__nOpc := VTaChoice(2,0,5,VTMaxCol(),{STR0004,STR0005,STR0023,STR0006}) // Confere Carga // Confere Pedido // Confere Carga/Pedido // Confere Nota
			ElseIf FunName() == "DLGV102A"
				__nOpc := 1  // Confere Carga
			ElseIf FunName() == "DLGV102B"
				__nOpc := 2  // Confere Pedido
			ElseIf FunName() == "DLGV102C"
				__nOpc := 3  // Confere Carga/Pedido
			ElseIf FunName() == "DLGV102D"
				__nOpc := 4  // Confere Nota
			EndIf
			VtClearBuffer()
	
			// Tela de conferência
			If __nOpc <> 0
				DLGV1021()
			EndIf
	
			If VtLastKey() == 27
				VtRestore(,,,,aTela)
				lRet := .F.
			EndIf
	
			// Restaura teclas
			VTSetKey(09,bkey09,cKey09)
			VTSetKey(22,bkey22,cKey22)
			VtRestore(,,,,aTela)
		Else
			VtKeyboard(Chr(20))
		EndIf
	EndDo

Return ( lRet )

//----------------------------------------------------------
//Função para ser chamada direto do menu e ir direto para
//a tela de Conferência de Carga
//----------------------------------------------------------
Static Function DLGV102A()

	DLGV102()

Return Nil

//----------------------------------------------------------
//Função para ser chamada direto do menu e ir direto para
//a tela de Conferência de Pedido
//----------------------------------------------------------
Static Function DLGV102B()

	DLGV102()

Return Nil

//----------------------------------------------------------
//Função para ser chamada direto do menu e ir direto para
//a tela de Conferência de Carga/Pedido
//----------------------------------------------------------
Static Function DLGV102C()

	DLGV102()

Return Nil

//----------------------------------------------------------
//Função para ser chamada direto do menu e ir direto para
//a tela de Conferência de Nota
//----------------------------------------------------------
Static Function DLGV102D()

	DLGV102()

Return Nil

//----------------------------------------------------------
/*/{Protheus.doc} DLGV1021
Tela de Conferência de Expedição

@author  Evaldo Cevinscki Jr.
@version P11
@since   24/07/12
/*/
//----------------------------------------------------------
Static Function DLGV1021()
Local aTela      := VTSave()
Local cKey15     := VtDescKey(15)
Local bkey15     := VTSetKey(15)
Local cKey24     := VtDescKey(24)
Local bkey24     := VTSetKey(24)   //trocar por 24 ctrl+x
Local nLin       := 0
Local lEsc       := .F.
Local cPrdAnt    := ''
Local cDscUM     := ''
Local nItem      := 0
Local xCodExp    := Nil
Local cCodExp    := ""
Local cCarga     := Space(Len(D02->D02_CARGA))
Local cPedido    := Space(Len(D02->D02_PEDIDO))
Local cNota      := Space(Len(SC9->C9_NFISCAL))
Local cProduto   := Space(Len(D02->D02_CODPRO))
Local cLote      := Space(Len(D02->D02_LOTE))
Local cSubLote   := Space(Len(D02->D02_SUBLOT))
Local lUsaInCof  := .F.
Local nQtd       := 0
Local nQtdNorma  := 0
Local lDV102FCE  := ExistBlock("DV102FCE")
Local cWmsUMIAux := AllTrim(SuperGetMV('MV_WMSUMI',.F.,'0')) // Valor oficial do parâmetro
	
	If !(__cWmsUMI $ '0ú1ú2ú3ú4ú5')
		WmsAviso(STR0002) // Parâmetro MV_WMSUMI com informação inválida...
		Return .F.
	EndIf
	
	While !lEsc
	
		__lLote     := .F.
		__lSubLote  := .F.
		lEsc      := .F.
		xCodExp   := Nil
		cCodExp   := ""
		cCarga    := Space(Len(D02->D02_CARGA))
		cPedido   := Space(Len(D02->D02_PEDIDO))
		cNota     := Space(Len(SC9->C9_NFISCAL))
		__cWmsUMI := cWmsUMIAux
		lUsaInCof := .F.
	
		VTClear()
		VTClearBuffer()
		DLVTCabec(STR0007, .F., .F., .T.) // Conferencia
		If __nOpc == 1
			@ 02, 00 VTSay PadR(STR0008, VTMaxCol())   // Carga
			@ 03, 00 VTGet cCarga Valid !Empty(cCarga) .And. DLGV102CAR(@xCodExp,cCarga)
		ElseIf __nOpc == 2
			@ 02, 00 VTSay PadR(STR0009, VTMaxCol())   // Pedido
			@ 03, 00 VTGet cPedido Valid !Empty(cPedido) .And. DLGV102PED(@xCodExp,cCarga,cPedido)
		ElseIf __nOpc == 3
			@ 02, 00 VTSay PadR(STR0008, VTMaxCol())   // Carga
			@ 03, 00 VTGet cCarga Valid !Empty(cCarga) .And. DLGV102CAR(@xCodExp,cCarga)
			@ 04, 00 VTSay PadR(STR0009, VTMaxCol())   // Pedido
			@ 05, 00 VTGet cPedido Valid !Empty(cPedido) .And. DLGV102PED(@xCodExp,cCarga,cPedido)
		Else
			@ 02, 00 VTSay PadR(STR0010, VTMaxCol())   // Nota
			@ 03, 00 VTGet cNota Valid !Empty(cNota) .And. DLGV102NF(cNota,@xCodExp,@cCarga,@cPedido)
		EndIf
		VTRead
	
		If VTLastKey() == 27
			Exit
		EndIf
	
		// Trata os códigos de conferência de expedição caso
		// o usuário escolha conferência apenas por Carga
		If ValType(xCodExp) == 'A'
			If Len(xCodExp) == 1
				cCodExp := xCodExp[1]
			Else
				AEval(xCodExp,{|x| cCodExp := cCodExp+Iif(Empty(cCodExp),"",",")+"'"+x+"'"})
				lUsaInCof := .T.
			EndIf
		Else
			cCodExp := xCodExp
		EndIf
	
		VTSetKey(24,{|| DLGEST102(cCodExp,cCarga,cPedido,cNota,lUsaInCof) }, STR0038) // Ctrl+X // Estorno
		VTSetKey(15,{|| DLGV102CON(cCodExp,cCarga,cPedido,cNota,lUsaInCof)}, STR0050) // Ctrl+O // Conferencias
	
		While .T.
	
			cProduto := Space(Len(D02->D02_CODPRO))
			cLote    := Space(Len(D02->D02_LOTE))
			cSubLote := Space(Len(D02->D02_SUBLOT))
			nQtd     := 0
			nLin     := 4
			__lLote    := .F.
			__lSubLote := .F.
	
			VTClear()
			DLVTCabec(STR0007, .F., .F., .T.) // Conferência
			If __nOpc == 1
				@ 1,0 VtSay STR0008+cCarga  // Carga:
			ElseIf __nOpc == 2
				@ 1,0 VtSay STR0009+cPedido // Pedido:
			ElseIf __nOpc == 3
				@ 1,0 VtSay "C/P: "+cCarga+" / "+cPedido // C/P: '#####' / '#####'
			Else
				@ 1,0 VtSay STR0010+cNota   // Nota:
			EndIf
			@ 02, 00 VTSay PadR(STR0016, VTMaxCol()) //"Produto:"
			@ 03, 00 VTGet cProduto Picture "@!" Valid !Empty(cProduto) .And. DLG102PROD(.F.,cCodExp,cCarga,cPedido,@cProduto,@nQtd,@cLote,@cSubLote,lUsaInCof)
			VTRead
	
			If VTLastKey() == 27
				Exit
			EndIf
	
			__dDtIni := Date()
			__cHrIni := Time()
	
			// Quando a quantidade, lote e sublote forem retornados pela função
			// de validação do produto não solicita essas informações ao usuário
			If nQtd == 0
				If __lRastro .And. __lWmsLote
					If __lLote
						@ 04, 00 VTSay PadR(STR0017+Iif(__lSubLote,STR0018,""), VTMaxCol()) // Lote: '#####' SubLote: '#####'
						@ 05, 00 VTGet cLote Picture "@!" Valid !Empty(cLote) .And. DLG102VLLT(.F.,cCodExp,cCarga,cPedido,cProduto,cLote,lUsaInCof)
						nLin := 6
						If __lSubLote
							@ 05, 11 VTSay "/" Picture "@!"
							@ 05, 13 VTGet cSubLote Picture "@!" Valid !Empty(cSubLote) .And. DLG102VLSL(.F.,cCodExp,cCarga,cPedido,cProduto,cLote,cSubLote,lUsaInCof)
						EndIf
						VTRead
					EndIf
				EndIf
	
				If VTLastKey() == 27
					Exit
				EndIf
	
				//Realiza as validações necessárias para tratar a quantidade de acordo com o parâmetro MV_WMSUMI
				DLG102QTDE(cCarga,cPedido,cProduto,cLote,cSubLote,@cPrdAnt,@cDscUM,@nItem,@nQtdNorma)
	
				@ nLin  , 00 VTSay PadR(STR0019 + cDscUM + ':', VTMaxCol())
				@ nLin+1, 00 VTGet nQtd Picture PesqPict('D04','D04_QTCONF') When VTLastKey()==05 .Or. Empty(nQtd) Valid !Empty(nQtd) .And. DLG102VLQT(.F.,cCodExp,cCarga,cPedido,cProduto,cLote,cSubLote,nQtd,nItem,nQtdNorma,lUsaInCof) //Picture "@E 999,999,999.99"
				VTRead
			EndIf
	
			If VTLastKey() == 27
				lEsc  := .T.
				If nQtd > 0
					VTClear()
					DLVTCabec(STR0007, .F., .F., .T.)         // Conferencia
					@ 01, 00 VTSay PadR(STR0020, VTMaxCol())  // Em andamento!
					@ 02, 00 VTSay " ------------------ "
					If __nOpc == 1
						@ 03, 00 VTSay PadR(STR0008+cCarga , VTMaxCol()) // Carga:
					ElseIf __nOpc == 2
						@ 03, 00 VTSay PadR(STR0009+cPedido, VTMaxCol()) // Pedido:
					ElseIf __nOpc == 3
						@ 03, 00 VTSay PadR(STR0008+cCarga , VTMaxCol()) // Carga:
						@ 04, 00 VTSay PadR(STR0009+cPedido, VTMaxCol()) // Pedido:
					Else
						@ 03, 00 VTSay PadR(STR0010+cNota  , VTMaxCol()) // Nota:
					EndIf
					DLVTRodaPe()
				EndIf
				Exit
			EndIf
	
			If DLG102GRAV(cCodExp,cCarga,cPedido,cProduto,cLote,cSubLote,nQtd,nItem,nQtdNorma,lUsaInCof)
				lEsc := .T.
				VTClear()
				DLVTCabec(STR0007, .F., .F., .T.)         // Conferencia
				@ 01, 00 VTSay PadR(STR0022, VTMaxCol())  // Finalizada
				@ 02, 00 VTSay " ------------------ "
				If __nOpc == 1
					@ 03, 00 VTSay PadR(STR0008+cCarga , VTMaxCol()) // Carga:
				ElseIf __nOpc == 2
					@ 03, 00 VTSay PadR(STR0009+cPedido, VTMaxCol()) // Pedido:
				ElseIf __nOpc == 3
					@ 03, 00 VTSay PadR(STR0008+cCarga , VTMaxCol()) // Carga:
					@ 04, 00 VTSay PadR(STR0009+cPedido, VTMaxCol()) // Pedido:
				Else
					@ 03, 00 VTSay PadR(STR0010+cNota  , VTMaxCol()) // Nota:
				EndIf
				DLVTRodaPe()
				// Ponto de entrada genérico na finalização da conferência de expedição
				// Permitirá, por exemplo, que o cliente inclua informações adicionais
				// no pedido de venda antes de gerar o documento de saída
				If lDV102FCE
					ExecBlock("DV102FCE",.F.,.F.,{cCodExp,cCarga,cPedido})
				EndIf
				Exit
			EndIf
		EndDo
	
	EndDo

//Restaura teclas
VTSetKey(15,bkey15,cKey15)
VTSetKey(24,bkey24,cKey24)
VtRestore(,,,,aTela)

Return Nil

//----------------------------------------------------------
/*/{Protheus.doc} DLGV102CAR
Verifica se a carga informada é valida

@return  lRet     Indica se a carga informada é válida
@version P11
@since   10/09/15
/*/
//----------------------------------------------------------
Static Function DLGV102CAR(xCodExp,cCarga)
Local aAreaAnt  := GetArea()
Local lRet      := .T.
Local cQuery    := ""
Local cAliasQry := ""

	DAK->(DbSetOrder(1)) // DAK_FILIAL+DAK_COD+DAK_SEQCAR
	If !DAK->(DbSeek(xFilial("DAK")+cCarga))
		WmsMessage(STR0024) // Carga inválida!
		lRet := .F.
	Else
		cQuery := "SELECT D01_STATUS, D01_CODEXP"
		cQuery +=  " FROM "+RetSqlName('D01')+" D01A"
		cQuery += " WHERE D01A.D01_CARGA  = '"+cCarga+"'"
		cQuery +=   " AND D01A.D_E_L_E_T_ = ' '"
		cQuery +=   " AND D01A.D01_CODEXP = (SELECT MAX(D01B.D01_CODEXP)"
		cQuery +=                            " FROM "+RetSqlName('D01')+" D01B"
		cQuery +=                           " WHERE D01B.D01_FILIAL  = D01A.D01_FILIAL"
		cQuery +=                              " AND D01B.D01_CARGA  = D01A.D01_CARGA"
		cQuery +=                              " AND D01B.D01_PEDIDO = D01A.D01_PEDIDO"
		cQuery +=                              " AND D01B.D_E_L_E_T_ = ' ')"
		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
		If !(cAliasQry)->(Eof())
			// Seta variável como array vazio, caso contrário o AAdd não funciona
			xCodExp := {}
			While !(cAliasQry)->(Eof())
				// Preenche a variável cCodExp com todos os códigos
				// de conferência disponíveis para a carga
				If (cAliasQry)->D01_STATUS != '3'
					AAdd(xCodExp, (cAliasQry)->D01_CODEXP)
				EndIf
				(cAliasQry)->(DbSkip())
			EndDo
			If Empty(xCodExp)
				WmsMessage(STR0012) // A conferência desta carga já está finalizada!
				lRet := .F.
			EndIf
		Else
			WmsMessage(STR0011) // Não existe conferência para a carga informada!
			lRet := .F.
		EndIf
		(cAliasQry)->(DbCloseArea())
	EndIf

	If !lRet
		VTKeyBoard(Chr(20))
	EndIf

RestArea(aAreaAnt)
Return lRet

//----------------------------------------------------------
/*/{Protheus.doc} DLGV102PED
Verifica se o pedido informado é válido

@return  lRet  Indica se o pedido informado é válido
@version P11
@since   10/09/15
/*/
//----------------------------------------------------------
Static Function DLGV102PED(xCodExp,cCarga,cPedido,lValNota)
Local aAreaAnt  := GetArea()
Local lRet      := .T.
Local cQuery    := ""
Local cAliasQry := ""

Default lValNota := .F.

	SC6->(DbSetOrder(1))
	If !(SC6->(DbSeek(xFilial('SC6')+cPedido)))
		WmsMessage(STR0028) // Pedido inválido!
		lRet := .F.
	Else
		cQuery := "SELECT D01_STATUS, D01_CODEXP"
		cQuery +=  " FROM "+RetSqlName('D01')+" D01A"
		cQuery += " WHERE D01A.D01_FILIAL = '"+xFilial('D01')+"'"
		cQuery +=   " AND D01A.D01_CARGA  = '"+cCarga+"'"
		cQuery +=   " AND D01A.D01_PEDIDO = '"+cPedido+"'"
		cQuery +=   " AND D01A.D_E_L_E_T_ = ' '"
		cQuery +=   " AND D01A.D01_CODEXP = (SELECT MAX(D01B.D01_CODEXP)"
		cQuery +=                            " FROM "+RetSqlName('D01')+" D01B"
		cQuery +=                           " WHERE D01B.D01_FILIAL  = D01A.D01_FILIAL"
		cQuery +=                              " AND D01B.D01_CARGA  = D01A.D01_CARGA"
		cQuery +=                              " AND D01B.D01_PEDIDO = D01A.D01_PEDIDO"
		cQuery +=                              " AND D01B.D_E_L_E_T_ = ' ')"
		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
		If (cAliasQry)->(Eof())
			If !lValNota
				If Empty(cCarga)
					WmsMessage(STR0054) // Não existe conferência para o pedido informado!
				Else 
					WmsMessage(STR0055) // Não existe conferência para o pedido informado ou o pedido está vinculado a uma carga!
				EndIf
			Else
				WmsMessage(STR0056) // Não existe conferência para o pedido faturado pela nota fiscal informada!
			EndIf
			lRet := .F.
		Else
			If (cAliasQry)->D01_STATUS != '3'
				xCodExp := (cAliasQry)->D01_CODEXP
			Else
				If !lValNota
					WmsMessage(STR0014) // A conferência deste pedido já está finalizada!
				Else 
					WmsMessage(STR0057) // A conferência do pedido faturado pela nota fiscal já está finalizada!
				EndIf
				lRet := .F.
			EndIf
		EndIf
		(cAliasQry)->(DbCloseArea())
	EndIf

	If !lRet
		VTKeyBoard(Chr(20))
	EndIf

RestArea(aAreaAnt)
Return lRet

//----------------------------------------------------------
/*/{Protheus.doc} DLG102PROD
Verifica se o código de produto informado é válido

@return  lRet  Indica se o código de produto informado é válido
@author  Evaldo Cevinscki Jr.
@version P11
@since   25/07/12
/*/
//----------------------------------------------------------
Static Function DLG102PROD(lEstorno,cCodExp,cCarga,cPedido,cProduto,nQtd,cLote,cSubLote,lUsaInCof)
Local lRet     := .T.
Local nQtSepa  := 0
Local nQtConf  := 0
	// Validações genéricas referentes ao código do produto
	lRet := DLVValProd(@cProduto,@cLote,@cSubLote,@nQtd)
	// Validações relacionadas à conferência do produto
	If lRet
		If QtdPrdCof(cCodExp,cCarga,cPedido,cProduto,cLote,cSubLote,@nQtSepa,@nQtConf,lUsaInCof)
			If !lEstorno .And. QtdComp(nQtConf) > 0 .And. QtdComp(nQtSepa) == QtdComp(nQtConf)
				WmsMessage(STR0025) // A conferência deste produto já foi finalizada!
				lRet := .F.
			ElseIf lEstorno .And. QtdComp(nQtConf) == 0
				WmsMessage(STR0026) // A conferência deste produto não foi iniciada!
				lRet := .F.
			EndIf
		Else
			WmsMessage(STR0027) // Produto não encontrado na conferência!
			lRet := .F.
		EndIf
	EndIf
	// Indica se o produto controla lote/sublote
	If lRet
		If Rastro(cProduto)
			__lLote := .T.
		EndIf
		If Rastro(cProduto,'S')
			__lSubLote := .T.
		EndIf
	EndIf
	If !lRet
		cProduto := Space(128)
		VTKeyBoard(Chr(20))
	EndIf
Return lRet

//----------------------------------------------------------
/*/{Protheus.doc} DLG102VLLT
Verifica se o lote informado é válido

@return     lRet  Indica se o lote é válido
@author     Guilherme Alexandre Metzger
@version    P11
@since      07/11/14
/*/
//----------------------------------------------------------
Static Function DLG102VLLT(lEstorno,cCodExp,cCarga,cPedido,cProduto,cLote,lUsaInCof)
Local lRet    := .T.
Local nQtSepa := 0
Local nQtConf := 0

	SB8->(DbSetOrder(5)) // B8_FILIAL+B8_PRODUTO+B8_LOTECTL+B8_NUMLOTE+DTOS(B8_DTVALID)
	If !(SB8->(DbSeek(xFilial('SB8')+cProduto+cLote)))
		WmsMessage(STR0071) // Lote inválido!
		lRet := .F.
	Else
		If QtdPrdCof(cCodExp,cCarga,cPedido,cProduto,cLote,,@nQtSepa,@nQtConf,lUsaInCof)
			If !lEstorno .And. QtdComp(nQtConf) > 0 .And. QtdComp(nQtSepa) == QtdComp(nQtConf)
				WmsMessage(STR0039) // A conferência deste lote já foi finalizada!
				lRet := .F.
			ElseIf lEstorno .And. QtdComp(nQtConf) == 0
				WmsMessage(STR0040) // A conferência deste lote não foi iniciada!
				lRet := .F.
			EndIf
		Else
			WmsMessage(STR0041) // Lote não encontrado na conferência!
			lRet := .F.
		EndIf
	EndIf

Return lRet

//----------------------------------------------------------
/*/{Protheus.doc} DLG102VLSL
Verifica se o sublote informado é válido

@return     lRet  Indica se o lote é válido
@author     Guilherme Alexandre Metzger
@version    P11
@since      07/11/14
/*/
//----------------------------------------------------------
Static Function DLG102VLSL(lEstorno,cCodExp,cCarga,cPedido,cProduto,cLote,cSubLote,lUsaInCof)
Local lRet    := .T.
Local nQtSepa := 0
Local nQtConf := 0

	SB8->(DbSetOrder(5)) // B8_FILIAL+B8_PRODUTO+B8_LOTECTL+B8_NUMLOTE+DTOS(B8_DTVALID)
	If !(SB8->(DbSeek(xFilial('SB8')+cProduto+cLote)))
		WmsMessage(STR0074) //Sublote inválido!
		lRet := .F.
	Else
		If QtdPrdCof(cCodExp,cCarga,cPedido,cProduto,cLote,cSubLote,@nQtSepa,@nQtConf,lUsaInCof)
			If !lEstorno .And. QtdComp(nQtConf) > 0 .And. QtdComp(nQtSepa) == QtdComp(nQtConf)
				WmsMessage(STR0051) // A conferência deste sublote já foi finalizada!
				lRet := .F.
			ElseIf lEstorno .And. QtdComp(nQtConf) == 0
				WmsMessage(STR0052) // A conferência deste sublote não foi iniciada!
				lRet := .F.
			EndIf
		Else
			WmsMessage(STR0053) // "Sublote não encontrado na conferência!"
			lRet := .F.
		EndIf
	EndIf

Return lRet

//----------------------------------------------------------
/*/{Protheus.doc} QtdPrdCof
Busca o saldo pendente de conferência para o produto/lote/sublote

@return     nSaldo   Saldo pendente de conferência
@version    P11
@since      10/09/15
/*/
//----------------------------------------------------------
Static Function QtdPrdCof(cCodExp,cCarga,cPedido,cProduto,cLote,cSubLote,nQtSepa,nQtConf,lUsaInCof)
Local aAreaAnt   := GetArea()
Local lRet       := .F.
Local cQuery     := ""
Local cAliasQry  := GetNextAlias()
Local aTamSX3Sep := TamSX3("D02_QTSEPA")
Local aTamSX3Cof := TamSX3("D02_QTCONF")

	cQuery := "SELECT SUM(D02_QTSEPA) D02_QTSEPA, SUM(D02_QTCONF) D02_QTCONF"
	cQuery +=  " FROM " + RetSqlName('D02')
	cQuery += " WHERE D02_FILIAL = '"+xFilial('D02')+"'"
	If lUsaInCof
		cQuery += " AND D02_CODEXP IN ("+cCodExp+")"
	Else 
		cQuery += " AND D02_CODEXP = '"+cCodExp+"'"
	EndIf
	cQuery +=    " AND D02_CARGA  = '"+cCarga+"'"
	If __nOpc != 1
		cQuery += " AND D02_PEDIDO = '"+cPedido+"'"
	EndIf
	cQuery +=    " AND D02_CODPRO = '"+cProduto+"'"
	If !Empty(cLote)
		cQuery += " AND D02_LOTE   = '"+cLote+"'"
	EndIf
	If !Empty(cSubLote)
		cQuery += " AND D02_SUBLOT = '"+cSubLote+"'"
	EndIf
	cQuery +=    " AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	TcSetField(cAliasQry,'D02_QTSEPA','N',aTamSX3Sep[1],aTamSX3Sep[2])
	TcSetField(cAliasQry,'D02_QTCONF','N',aTamSX3Cof[1],aTamSX3Cof[2])
	If !(cAliasQry)->(Eof())
		nQtSepa := (cAliasQry)->D02_QTSEPA
		nQtConf := (cAliasQry)->D02_QTCONF
		lRet    := QtdComp(nQtSepa+nQtConf) > 0
	EndIf
	(cAliasQry)->(DbCloseArea())

RestArea(aAreaAnt)
Return lRet

//----------------------------------------------------------
/*/{Protheus.doc} DLGV102CON
Monta consulta de produtos na conferência de expedição

@author  Evaldo Cevinscki Jr.
@version P11
@since   27/07/12
/*/
//----------------------------------------------------------
Static Function DLGV102CON(cCodExp,cCarga,cPedido,cNota,lUsaInCof)
Local aTela     := VTSave()
Local aArea     := GetArea()
Local aProds    := {}
Local cQuery    := ''
Local cAliasQry := GetNextAlias()

	DLVTCabec("Consulta "+STR0007, .F., .F., .T.) //"Conferencia"
	// Seleciona os produtos pertencentes à conferência
	cQuery := "SELECT D02_CODPRO, D02_LOTE, D02_SUBLOT, D02_QTCONF, D02_STATUS"
	cQuery +=  " FROM "+RetSqlName('D02')+" D02"
	cQuery += " WHERE D02_FILIAL = '"+xFilial('D02')+"'"
	If lUsaInCof
		cQuery += " AND D02_CODEXP IN ("+cCodExp+")"
	Else
		cQuery += " AND D02_CODEXP = '"+cCodExp+"'"
	EndIf
	cQuery +=    " AND D02_CARGA  = '"+cCarga+"'"
	If __nOpc != 1
		cQuery += " AND D02_PEDIDO = '"+cPedido+"'"
	EndIf
	cQuery +=    " AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	// Carrega os produtos no array para apresentar em tela
	While !(cAliasQry)->(Eof())
		AAdd(aProds,{Iif((cAliasQry)->D02_STATUS <> "3","*",""),(cAliasQry)->D02_CODPRO,(cAliasQry)->D02_LOTE,(cAliasQry)->D02_SUBLOT,(cAliasQry)->D02_QTCONF})
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
	VTClear()
	If __nOpc == 1
		@ 0,0 VtSay STR0032 // Conferencia Carga
		@ 1,0 VtSay STR0008+cCarga  // Carga:
	ElseIf __nOpc == 2
		@ 0,0 VtSay STR0033 // Conferencia Pedido
		@ 1,0 VtSay STR0009+cPedido // Pedido:
	ElseIf __nOpc == 3
		@ 0,0 VtSay STR0033 // Conf. Carga/Pedido
		@ 1,0 VtSay "C/P: "+cCarga+" / "+cPedido // C/P: '#####' / '#####'
	Else
		@ 0,0 VtSay STR0034 // Conferencia Nota
		@ 1,0 VtSay STR0010+cNota   // Nota: 
	EndIf
	// Apresenta browse com os produtos da conferência
	VTaBrowse(2,,,,{" ",STR0035,STR0017,STR0018,STR0037},aProds,{1,15,10,6,12})  // Produto // Lote // SubLote // Qtd.Conf.
	VtRestore(,,,,aTela)

RestArea(aArea)
Return .T.

//----------------------------------------------------------
/*/{Protheus.doc} DLGEST102
Tela de estorno da conferência de expedição

@author  Evaldo Cevinscki Jr.
@version P11
@since   27/07/12
/*/
//----------------------------------------------------------
Static Function DLGEST102(cCodExp,cCarga,cPedido,cNota,lUsaInCof)
Local aArea     := GetArea()
Local aTela     := VTSave()
Local cPrdAnt   := ''
Local cDscUM    := ''
Local nItem     := 0
Local nQtd      := 0
Local nQtdNorma := 0
Local cProduto  := ""
Local cLote     := ""
Local cSubLote  := ""
Local lEsc      := .F.

	While .T.

		cProduto  := Space(128)
		cLote     := Space(Len(D02->D02_LOTE))
		cSubLote  := Space(Len(D02->D02_SUBLOT))
		nQtd      := 0
		nLin      := 4
		__lLote     := .F.
		__lSubLote  := .F.

		VTClear()
		DLVTCabec(STR0038, .F., .F., .T.) // Estorno Conferencia
		If !Empty(cCarga)
			@ 01, 00 VTSay PadR(STR0008+cCarga , VTMaxCol())   // Carga:
		ElseIf !Empty(cPedido)
			@ 01, 00 VTSay PadR(STR0009+cPedido, VTMaxCol())   // Pedido:
		ElseIf !Empty(cNota)
			@ 01, 00 VTSay PadR(STR0010+cNota  , VTMaxCol())   // Nota:
		EndIf
		@ 02, 00 VTSay PadR(STR0016, VTMaxCol()) // Produto:
		@ 03, 00 VTGet cProduto Picture "@!" Valid !Empty(cProduto) .And. DLG102PROD(.T.,cCodExp,cCarga,cPedido,@cProduto,@nQtd,@cLote,@cSubLote,lUsaInCof)
		VTRead

		If VTLastKey() == 27
			Exit
		EndIf

		//Solicita quantidade se não retorna valor referente a consulta de etiquetas EAN (DLG102PROD())
		If nQtd == 0
			If __lRastro .And. __lWmsLote
				If __lLote
					@ 04, 00 VTSay PadR(STR0017+Iif(__lSubLote,STR0018,""), VTMaxCol()) // Lote: '#####' / Sub-Lote: '#####'
					@ 05, 00 VTGet cLote Picture "@!" Valid !Empty(cLote) .And. DLG102VLLT(.T.,cCodExp,cCarga,cPedido,cProduto,cLote,lUsaInCof)
					nLin := 6
					If __lSubLote
						@ 05, 11 VTSay "/"
						@ 05, 13 VTGet cSubLote Picture "@!" Valid !Empty(cSubLote) .And. DLG102VLSL(.T.,cCodExp,cCarga,cPedido,cProduto,cLote,cSubLote,lUsaInCof)
					EndIf
					VTRead
				EndIf
			EndIf

			If VTLastKey() == 27
				Exit
			EndIf

			// Realiza as validações necessárias para tratar a quantidade de acordo com o parâmetro MV_WMSUMI
			DLG102QTDE(cCarga,cPedido,cProduto,cLote,cSubLote,@cPrdAnt,@cDscUM,@nItem,@nQtdNorma)

			@ nLin, 00 VTSay PadR(AllTrim(STR0019) + AllTrim(cDscUM) + ':', VTMaxCol())
			@ nLin+1, 00 VTGet nQtd Picture PesqPict('D04','D04_QTCONF') Valid !Empty(nQtd) .And. DLG102VLQT(.T.,cCodExp,cCarga,cPedido,cProduto,cLote,cSubLote,nQtd,nItem,nQtdNorma,lUsaInCof)
			VTRead

			If VTLastKey() == 27
				Exit
			EndIf
		EndIf

		cMsg := STR0045 + CRLF // Confirma o estorno?
		If !Empty(cCarga)
			cMsg  += STR0008  + AllTrim(cCarga)  + CRLF // Carga
		ElseIf !Empty(cPedido)
			cMsg += STR0009   + AllTrim(cPedido) + CRLF // Pedido
		ElseIf !Empty(cNota)
			cMsg += STR0010   + AllTrim(cNota)   + CRLF // Nota
		EndIf
		cMsg += STR0021  +  AllTrim(cProduto) + CRLF
		If !Empty(cLote)
			cMsg += STR0017+" "+AllTrim(cLote) + CRLF
		EndIf
		cMsg += STR0019+" "+AllTrim(Str(nQtd))

		VTClear()
		DLVTCabec(STR0044, .F., .F., .T.) // Atenção
		If VtYesNo(AllTrim(cMsg),STR0044)
			If DLG102GRVE(cCodExp,cCarga,cPedido,cProduto,cLote,cSubLote,nQtd,nItem,nQtdNorma,lUsaInCof)
				Exit
			EndIf
		EndIf
	EndDo

RestArea(aArea)
VtRestore(,,,,aTela)
Return Nil

//----------------------------------------------------------
/*/{Protheus.doc} DLG102GRAV
Gravação da conferência de expedição

@return  lFinal   Indica se a gravação foi completada
@author  Evaldo Cevinscki Jr.
@version P11
@since   18/07/12
/*/
//----------------------------------------------------------
Static Function DLG102GRAV(cCodExp,cCarga,cPedido,cProduto,cLote,cSubLote,nQtd,nItem,nQtdNorma,lUsaInCof)
Local aAreaAnt   := GetArea()
Local aTela      := VTSave()
Local lRet       := .F.
Local lFinal     := .T.
Local nQtdRes    := 0
Local nQtdConf   := 0
Local nSaldo     := 0
Local cQuery     := ''
Local cAliasD02  := ''
Local cAliasSC9  := ''
Local cCodOpe    := __cUserID
Local cLibPed    := '3'
Local cCodExpAux := ''
Local bSeekD01   := {||xFilial('D01')+cCarga+Iif(__nOpc == 1,'',cPedido)}
Local cCompD01   := "D01->D01_FILIAL+D01->D01_CARGA"+Iif(__nOpc == 1,'',"+D01->D01_PEDIDO")

	VTClear()
		
	//Como o sistema trabalha sempre na 1a.UM
	If __cWmsUMI $ '0ú1'
		nQtdRes := nQtd
	ElseIf __cWmsUMI == '2'
		//-- Converter de 2a.UM p/ 1a.UM
		nQtdRes := ConvUm(cProduto,0,nQtd,1)
	ElseIf __cWmsUMI $ '3ú5'
		//-- O nItem corresponde ao item selecionado pela funcao VTaBrowse quando cWmsUMI == '3' ou cWmsUMI == '5'
		//-- Converter de U.M.I. p/ 1a.UM
		If nItem == 1
			nQtdRes := (nQtd*nQtdNorma)
		//-- Converter de 2a.UM p/ 1a.UM
		ElseIf nItem == 2
			nQtdRes := ConvUm(cProduto,0,nQtd,1)
		ElseIf nItem == 3
			nQtdRes := nQtd
		EndIf
	EndIf
	
	Begin Transaction
		cQuery := "SELECT R_E_C_N_O_ RECNOD02"
		cQuery +=  " FROM " + RetSqlName('D02')
		cQuery += " WHERE D02_FILIAL = '"+xFilial('D02')+"'"
		If lUsaInCof
			cQuery += " AND D02_CODEXP IN ("+cCodExp+")"
		Else
			cQuery += " AND D02_CODEXP = '"+cCodExp+"'"
		EndIf
		cQuery +=    " AND D02_CARGA  = '"+cCarga+"'"
		If __nOpc != 1
			cQuery += " AND D02_PEDIDO = '"+cPedido+"'"
		EndIf
		cQuery +=    " AND D02_CODPRO = '"+cProduto+"'"
		If !Empty(cLote)
			cQuery += " AND D02_LOTE   = '"+cLote+"'"
		EndIf
		If !Empty(cSubLote)
			cQuery += " AND D02_SUBLOT = '"+cSubLote+"'"
		EndIf
		cQuery +=    " AND D02_QTCONF < D02_QTSEPA"
		cQuery +=    " AND D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasD02 := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasD02,.F.,.T.)
		While !(cAliasD02)->(Eof()) .And. QtdComp(nQtdRes) > 0
			// Posiciona na D02
			D02->(DbGoTo((cAliasD02)->RECNOD02))
			// Calcula a quantidade que será incrementada a conferência
			// deste registro
			nSaldo := QtdComp(D02->D02_QTSEPA - D02->D02_QTCONF)
			If QtdComp(nQtdRes) > QtdComp(nSaldo)
				nQtdConf := nSaldo
			Else
				nQtdConf := nQtdRes
			EndIf
			nQtdRes -= nQtdConf
			// Deve buscar as informações da D02 corrente
			// para o caso de estar conferindo somente por carga
			cCodExpAux := D02->D02_CODEXP
			cCarga     := D02->D02_CARGA
			cPedido    := D02->D02_PEDIDO
			// Caso esteja parametrizado para não solicitar lote e
			// sublote nas telas de RF e o produto controlar lote
			cLote      := D02->D02_LOTE
			cSubLote   := D02->D02_SUBLOT
			// Atualiza quantidade conferida D02
			RecLock('D02',.F.)
			D02->D02_QTCONF += nQtdConf
			D02->D02_STATUS := Iif(QtdComp(D02->D02_QTCONF)==QtdComp(D02->D02_QTSEPA),'3','2')
			D02->(MsUnlock())
			// Cria/Atualiza quantidade conferida D04
			D04->(DbSetOrder(1)) // D04_FILIAL+D04_CODEXP+D04_CARGA+D04_PEDIDO+D04_CODOPE+D04_PRDORI+D04_CODPRO+D04_LOTE+D04_SUBLOT
			If !D04->(DbSeek(xFilial('D04')+cCodExpAux+cCarga+cPedido+cCodOpe+cProduto+cProduto+cLote+cSubLote))
				RecLock('D04',.T.)
				D04->D04_FILIAL  := xFilial('D04')
				D04->D04_CODEXP  := cCodExpAux
				D04->D04_CARGA   := cCarga
				D04->D04_PEDIDO  := cPedido
				D04->D04_CODOPE  := cCodOpe
				D04->D04_PRDORI  := cProduto
				D04->D04_CODPRO  := cProduto
				D04->D04_LOTE    := cLote
				D04->D04_SUBLOTE := cSubLote
				D04->D04_QTCONF  := nQtdConf
				D04->D04_DTINI   := __dDtIni
				D04->D04_HRINI   := __cHrIni
				D04->D04_DTFIM   := Date()
				D04->D04_HRFIM   := Time()
			Else
				RecLock('D04',.F.)
				D04->D04_QTCONF += nQtdConf
				D04->D04_DTFIM  := Date()
				D04->D04_HRFIM  := Time()
			EndIf
			D04->(MsUnlock())
			// Cria registro na D03
			D03->(DbSetOrder(1)) // D03_FILIAL+D03_CODEXP+D03_CARGA+D03_PEDIDO+D03_CODOPE
			If !D03->(DbSeek(xFilial('D03')+cCodExpAux+cCarga+cPedido+cCodOpe))
				RecLock('D03',.T.)
				D03->D03_FILIAL := xFilial('D03')
				D03->D03_CODEXP := cCodExpAux
				D03->D03_CARGA  := cCarga
				D03->D03_PEDIDO := cPedido
				D03->D03_CODOPE := cCodOpe
				D03->D03_DTINI  := __dDtIni
				D03->D03_HRINI  := __cHrIni
				D03->D03_DTFIM  := Date()
				D03->D03_HRFIM  := Time()
				D03->(MsUnlock())
			Else
				RecLock('D03',.F.)
				D03->D03_DTFIM  := Date()
				D03->D03_HRFIM  := Time()
				D03->(MsUnlock())
			EndIf
			// Atualiza status da D01
			D01->(DbSetOrder(1)) // D01_FILIAL+D01_CODEXP+D01_CARGA+D01_PEDIDO
			If D01->(DbSeek(xFilial('D01')+cCodExpAux+cCarga+cPedido))
				RecLock('D01',.F.)
				D01->D01_QTCONF += nQtdConf
				D01->D01_STATUS := '2'
				D01->(MsUnlock())
				cLibPed := D01->D01_LIBPED
			EndIf
			// Deve verificar se tudo que foi conferido bate
			// com o total liberado do pedido
			lFinal := DLG102VLDF(cCodExp,cCarga,cPedido,lUsaInCof,.T.)
			// Efetua liberação do pedido, caso esteja configurado
			// para retirar bloqueio WMS na conferência de expedição
			If lFinal
				D01->(DbSetOrder(2)) // D01_FILIAL+D01_CARGA+D01_PEDIDO+D01_CODEXP
				D01->(DbSeek(Eval(bSeekD01)))
				While !D01->(Eof()) .And. (Eval(bSeekD01) == &cCompD01)
					RecLock('D01',.F.)
					D01->D01_STATUS := '3' // Conferido
					D01->(MsUnlock())
					D01->(DbSkip())
				EndDo
				If cLibPed == '3' // Conferência de expedição
					cQuery := "SELECT SC9.R_E_C_N_O_ RECNOSC9"
					cQuery +=  " FROM "+RetSqlName('SC9')+" SC9,"+RetSqlName('D0H')+" D0H"
					cQuery += " WHERE SC9.C9_FILIAL  = '"+xFilial('SC9')+"'"
					cQuery +=   " AND D0H.D0H_FILIAL = '"+xFilial("D0H")+"'"
					If lUsaInCof
						cQuery += " AND D0H.D0H_CODEXP IN ("+cCodExp+")"
					Else
						cQuery += " AND D0H.D0H_CODEXP = '"+cCodExp+"'"
					EndIf
					If __nOpc == 1 // Se for conferência por carga, libera a carga toda
						cQuery += " AND SC9.C9_CARGA   = '"+cCarga+"'"
					Else
						cQuery += " AND SC9.C9_PEDIDO  = '"+cPedido+"'"
					EndIf
					cQuery +=   " AND SC9.C9_IDDCF   = D0H.D0H_IDDCF"
					cQuery +=   " AND SC9.C9_BLEST   = ' '"
					cQuery +=   " AND SC9.C9_BLCRED  = ' '"
					cQuery +=   " AND SC9.C9_NFISCAL = ' '"
					cQuery +=   " AND SC9.D_E_L_E_T_ = ' '"
					cQuery +=   " AND D0H.D_E_L_E_T_ = ' '"
					cQuery := ChangeQuery(cQuery)
					cAliasSC9 := GetNextAlias()
					DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSC9,.F.,.T.)
					While (cAliasSC9)->(!Eof())
						// Posiciona no registro correspondente
						SC9->(DbGoTo((cAliasSC9)->RECNOSC9))
						// Retira o bloqueio WMS
						RecLock('SC9',.F.)
						If     SC9->C9_BLWMS == '01'
							SC9->C9_BLWMS := '05'
						ElseIf SC9->C9_BLWMS == '02'
							SC9->C9_BLWMS := '06'
						ElseIf SC9->C9_BLWMS == '03'
							SC9->C9_BLWMS := '07'
						EndIf
						SC9->C9_XLOGWMS := UsrRetName( retcodusr() ) + ";" + DTOC(dDataBase) + ";" + Time()  + ";" + FUNNAME() + ";" + SC9->C9_BLWMS
						SC9->(MsUnlock())
						(cAliasSC9)->(DbSkip())
					EndDo
					(cAliasSC9)->(DbCloseArea())
				EndIf
			EndIf
			(cAliasD02)->(DbSkip())
		EndDo
		(cAliasD02)->(DbCloseArea())
	End Transaction
	
	// Verifica se toda a carga está conferida (caso seja conferência de carga/pedido)
	If !Empty(cCarga) .And. lFinal
		lFinal := DLG102VLDF(cCodExp,cCarga,cPedido,lUsaInCof,.F.)
	EndIf
	
	If VTLastKey() == 27
		Return lRet
	EndIf
	
	VtRestore(,,,,aTela)

RestArea(aAreaAnt)
Return lFinal

//----------------------------------------------------------
/*/{Protheus.doc} DLG102GRVE
Gravação do estorno da conferência

@author  Guilherme Alexandre Metzger
@version P11
@since   19/05/14
/*/
//----------------------------------------------------------
Static Function DLG102GRVE(cCodExp,cCarga,cPedido,cProduto,cLote,cSubLote,nQtde,nItem,nQtdNorma,lUsaInCof)
Local aAreaAnt  := GetArea()
Local nQtd      := 0
Local nQtdEst   := 0
Local cCodOpe   := __cUserID
Local cLibPed   := "3"
Local cQuery    := ""
Local cAliasD04 := ""
Local cAliasSC9 := ""

	D01->(DbSetOrder(1)) // D01_FILIAL+D01_CODEXP+D01_CARGA+D01_PEDIDO
	D02->(DbSetOrder(1)) // D02_FILIAL+D02_CODEXP+D02_CARGA+D02_PEDIDO+D02_PRDORI+D02_CODPRO+D02_LOTE+D02_SUBLOT
	D03->(DbSetOrder(1)) // D03_FILIAL+D03_CODEXP+D03_CARGA+D03_PEDIDO+D03_CODOPE
	D04->(DbSetOrder(1)) // D04_FILIAL+D04_CODEXP+D04_CARGA+D04_PEDIDO+D04_CODOPE+D04_PRDORI+D04_CODPRO+D04_LOTE+D04_SUBLOT
	SC9->(DbSetOrder(1)) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO

	//Como o sistema trabalha sempre na 1a.UM
	If __cWmsUMI $ '0ú1'
		nQtd := nQtde
	ElseIf __cWmsUMI == '2'
		//-- Converter de 2a.UM p/ 1a.UM
		nQtd := ConvUm(cProduto,0,nQtde,1)
	ElseIf __cWmsUMI $ '3ú5'
		//-- O nItem corresponde ao item selecionado pela funcao VTaBrowse quando cWmsUMI == '3' ou cWmsUMI == '5'
		//-- Converter de U.M.I. p/ 1a.UM
		If nItem == 1
			nQtd := (nQtde*nQtdNorma)
		//-- Converter de 2a.UM p/ 1a.UM
		ElseIf nItem == 2
			nQtd := ConvUm(cProduto,0,nQtde,1)
		ElseIf nItem == 3
			nQtd := nQtde
		EndIf
	EndIf
	
	Begin Transaction
		cQuery := "SELECT R_E_C_N_O_ RECNOD04"
		cQuery +=  " FROM " + RetSqlName('D04')
		cQuery += " WHERE D04_FILIAL = '"+xFilial('D04')+"'"
		If lUsaInCof
			cQuery += " AND D04_CODEXP IN ("+cCodExp+")"
		Else
			cQuery += " AND D04_CODEXP = '"+cCodExp+"'"
		EndIf
		cQuery +=    " AND D04_CARGA  = '"+cCarga+"'"
		If __nOpc != 1
			cQuery += " AND D04_PEDIDO = '"+cPedido+"'"
		EndIf
		cQuery +=    " AND D04_CODPRO = '"+cProduto+"'"
		If !Empty(cLote)
			cQuery += " AND D04_LOTE   = '"+cLote+"'"
		EndIf
		If !Empty(cSubLote)
			cQuery += " AND D04_SUBLOT = '"+cSubLote+"'"
		EndIf
		cQuery +=    " AND D04_CODOPE = '"+cCodOpe+"'"
		cQuery +=    " AND D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasD04 := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasD04,.F.,.T.)
		// Percorre a D04 decrementando a quantidade a estornar
		// e deletando os registros caso a quantidade conferida
		// chegue a 0 (zero)
		While !(cAliasD04)->(Eof()) .And. QtdComp(nQtd) > 0
			// Posiciona no registro correspondente
			D04->(DbGoTo((cAliasD04)->RECNOD04))
			// Deve buscar as informações da D04 corrente
			// para o caso de estar conferindo somente por carga
			cCodExpAux := D04->D04_CODEXP
			cCarga     := D04->D04_CARGA
			cPedido    := D04->D04_PEDIDO
			// Caso esteja parametrizado para não solicitar lote e
			// sublote nas telas de RF e o produto controlar lote
			cLote      := D04->D04_LOTE
			cSubLote   := D04->D04_SUBLOT
			// Trata a quantidade a estornar
			If QtdComp(nQtd) > QtdComp(D04->D04_QTCONF)
				nQtdEst := D04->D04_QTCONF
			Else
				nQtdEst := nQtd
			EndIf
			nQtd -= nQtdEst
			// Caso a quantidade a estornar seja igual a quantidade
			// conferida do registro, procede com o delete
			If QtdComp(D04->D04_QTCONF) == QtdComp(nQtdEst)
				RecLock("D04",.F.)
				D04->(DbDelete())
				D04->(MsUnlock())
			Else
				RecLock("D04",.F.)
				D04->D04_QTCONF -= nQtdEst
				D04->(MsUnlock())
			EndIf
			// Se não existir mais nenhum registro referente ao operador na conferência
			If !D04->(DbSeek(xFilial("D04")+cCodExpAux+cCarga+cPedido+cCodOpe))
				If D03->(DbSeek(xFilial("D03")+cCodExpAux+cCarga+cPedido+cCodOpe))
					RecLock("D03",.F.)
					D03->(DbDelete())
					D03->(MsUnlock())
				EndIf
			EndIf
			// Atualiza produtos na conferência de carga/pedido
			If D02->(DbSeek(xFilial("D02")+cCodExpAux+cCarga+cPedido+cProduto+cProduto+cLote+cSubLote))
				RecLock("D02",.F.)
				D02->D02_QTCONF -= nQtdEst
				D02->D02_STATUS := Iif(QtdComp(D02->D02_QTCONF)==0,'1','2')
				D02->(MsUnlock())
			EndIf
			// Atualiza o status do registro na tabela de documentos
			// na conferência de carga/pedido
			If D01->(DbSeek(xFilial("D01")+cCodExpAux+cCarga+cPedido))
				RecLock("D01",.F.)
				D01->D01_QTCONF -= nQtdEst
				D01->D01_STATUS := Iif(QtdComp(D01->D01_QTCONF)==0,'1','2')
				D01->(MsUnlock())
				cLibPed := D01->D01_LIBPED
			EndIf
			// Trata o bloqueio WMS na liberação do pedido
			If D01->D01_STATUS == '1' .And. cLibPed $ "34"
				cQuery := "SELECT SC9.R_E_C_N_O_ RECNOSC9"
				cQuery +=  " FROM "+RetSqlName('SC9')+" SC9,"+RetSqlName('D0H')+" D0H"
				cQuery += " WHERE SC9.C9_FILIAL  = '"+xFilial('SC9')+"'"
				cQuery +=   " AND D0H.D0H_FILIAL = '"+xFilial("D0H")+"'"
				If lUsaInCof
					cQuery += " AND D0H.D0H_CODEXP IN ("+cCodExp+")"
				Else
					cQuery += " AND D0H.D0H_CODEXP = '"+cCodExp+"'"
				EndIf
				If __nOpc == 1 // Se for conferência por carga, libera a carga toda
					cQuery += " AND SC9.C9_CARGA   = '"+cCarga+"'"
				Else
					cQuery += " AND SC9.C9_PEDIDO  = '"+cPedido+"'"
				EndIf
				cQuery +=   " AND SC9.C9_IDDCF   = D0H.D0H_IDDCF"
				cQuery +=   " AND SC9.C9_BLEST   = ' '"
				cQuery +=   " AND SC9.C9_BLCRED  = ' '"
				cQuery +=   " AND SC9.C9_NFISCAL = ' '"
				cQuery +=   " AND SC9.D_E_L_E_T_ = ' '"
				cQuery +=   " AND D0H.D_E_L_E_T_ = ' '"
				cQuery := ChangeQuery(cQuery)
				cAliasSC9 := GetNextAlias()
				DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSC9,.F.,.T.)
				While (cAliasSC9)->(!Eof())
					// Posiciona no registro correspondente
					SC9->(DbGoTo((cAliasSC9)->RECNOSC9))
					// Coloca o bloqueio WMS
					RecLock("SC9",.F.)
					If     SC9->C9_BLWMS == "05"
						SC9->C9_BLWMS := "01"
					ElseIf SC9->C9_BLWMS == "06"
						SC9->C9_BLWMS := "02"
					ElseIf SC9->C9_BLWMS == "07"
						SC9->C9_BLWMS := "03"
					EndIf
					SC9->(MsUnlock())
					(cAliasSC9)->(DbSkip())
				 EndDo
				 (cAliasSC9)->(DbCloseArea())
			EndIf
			(cAliasD04)->(DbSkip())
		EndDo
		(cAliasD04)->(DbCloseArea())
	End Transaction

RestArea(aAreaAnt)
Return .T.

//----------------------------------------------------------
/*/{Protheus.doc} DLGV102NF
Valida informações da nota fiscal

@return  lRet  Indica se a nota fiscal informada é válida
@author  Evaldo Cevinscki Jr.
@version P11
@since   27/07/12
/*/
//----------------------------------------------------------
Static Function DLGV102NF(cNota,xCodExp,cCarga,cPedido)
Local aAreaAnt  := GetArea()
Local lRet      := .T.
Local cQuery    := ''
Local cAliasSC9 := GetNextAlias()
Local nCont     := 0
Local aTamSx3   := {}
Local nSumNota  := 0

	cQuery := "SELECT DISTINCT C9_PEDIDO, C9_CARGA"
	cQuery +=  " FROM " +RetSqlName('SC9')
	cQuery += " WHERE C9_FILIAL  = '"+xFilial('SC9')+"'"
	cQuery +=    " AND C9_NFISCAL = '"+cNota+"'"
	cQuery +=    " AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T., "TOPCONN",TcGenQry(,,cQuery),cAliasSC9,.F.,.T.)

	If !(cAliasSC9)->(Eof())
		// Verifica se existe mais de um documento vinculado à nota
		// Atualmente a conferência funciona somente para notas com
		// um documento vinculado, ou seja, relacionamento 1 - 1
		While !(cAliasSC9)->(Eof())
			cCarga  := (cAliasSC9)->C9_CARGA
			cPedido := (cAliasSC9)->C9_PEDIDO
			nCont++
			If nCont > 1
				Exit
			EndIf
			(cAliasSC9)->(DbSkip())
		EndDo
		(cAliasSC9)->(DbCloseArea())
		// Se passar pela primeira validação, deve validar ainda se 
		// todos os itens do pedido estão faturados
		If nCont == 1
			cQuery := "SELECT SUM(C9_QTDLIB) C9_QTDLIB"
			cQuery +=  " FROM " +RetSqlName('SC9')
			cQuery += " WHERE C9_FILIAL   = '"+xFilial('SC9')+"'"
			cQuery +=    " AND C9_CARGA   = '"+cCarga+"'"
			cQuery +=    " AND C9_PEDIDO  = '"+cPedido+"'"
			cQuery +=    " AND C9_NFISCAL = '"+cNota+"'"
			cQuery +=    " AND D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			cAliasSC9 := GetNextAlias()
			DbUseArea(.T., "TOPCONN",TcGenQry(,,cQuery),cAliasSC9,.F.,.T.)
			aTamSx3 := TamSx3('C9_QTDLIB')
			TcSetField(cAliasSC9,'C9_QTDLIB','N',aTamSx3[1],aTamSx3[2])
			nSumNota := (cAliasSC9)->C9_QTDLIB
			// Chama a validação do pedido para preencher o código de expedição
			If (lRet := DLGV102PED(@xCodExp,cCarga,cPedido,.T.))
				D01->(DbSetOrder(1)) // D01_FILIAL+D01_CODEXP+D01_CARGA+D01_PEDIDO
				D01->(DbSeek(xFilial('D01')+xCodExp+cCarga+cPedido))
				If QtdComp(D01->D01_QTORIG) != QtdComp(nSumNota)
					WmsMessage(STR0058) // Conferência indisponível para notas parcialmente faturada do pedido!
					lRet := .F.
				EndIf
			EndIf
			(cAliasSC9)->(DbCloseArea())
		Else
			WmsMessage(STR0059) // Conferência indisponível para notas com mais de um documento vinculado!
			lRet := .F.
		EndIf
	Else
		WmsMessage(STR0046) // Nota nao encontrada!
		lRet := .F.
	EndIf

	If !lRet
		cCarga  := Space(Len(D02->D02_CARGA))
		cPedido := Space(Len(D02->D02_PEDIDO))
		VTKeyBoard(Chr(20))
	EndIf

RestArea(aAreaAnt)
Return lRet

//----------------------------------------------------------
/*/{Protheus.doc} DLG102VLQT
Validação de quantidade informada na conferência

@return  lRet  Indica se a quantidade informada é válida
@author  Guilherme Alexandre Metzger
@version P11
@since   04/11/14
/*/
//----------------------------------------------------------
Static Function DLG102VLQT(lEstorno,cCodExp,cCarga,cPedido,cProduto,cLote,cSubLote,nQtde,nItem,nQtdNorma,lUsaInCof)
Local aAreaAnt  := GetArea()
Local lRet      := .T.
Local nQuant    := 0
Local cQuery    := ''
Local cAliasQry := GetNextAlias()
//Quantidade de tolerância para cálculos com a 1UM. Usado quando o fator de conversão gera um dízima periódica
Local nToler1UM := QtdComp(SuperGetMV("MV_NTOL1UM",.F.,0))

	//Como o sistema trabalha sempre na 1a.UM
	If __cWmsUMI $ '0ú1'
		nQuant := nQtde
	ElseIf __cWmsUMI == '2'
		//-- Converter de 2a.UM p/ 1a.UM
		nQuant := ConvUm(cProduto,0,nQtde,1)
	ElseIf __cWmsUMI $ '3ú5'
		//-- O nItem corresponde ao item selecionado pela funcao VTaBrowse quando cWmsUMI == '3' ou cWmsUMI == '5'
		//-- Converter de U.M.I. p/ 1a.UM
		If nItem == 1
			nQuant := (nQtde*nQtdNorma)
		//-- Converter de 2a.UM p/ 1a.UM
		ElseIf nItem == 2
			nQuant := ConvUm(cProduto,0,nQtde,1)
		Else
			nQuant := nQtde
		EndIf
	EndIf

	If !lEstorno
		cQuery := "SELECT SUM(D02_QTSEPA) D02_QTSEPA, SUM(D02_QTCONF) D02_QTCONF"
		cQuery +=  " FROM " + RetSqlName('D02')
		cQuery += " WHERE D02_FILIAL = '"+xFilial('D02')+"'"
		If lUsaInCof
			cQuery += " AND D02_CODEXP IN ("+cCodExp+")"
		Else
			cQuery += " AND D02_CODEXP = '"+cCodExp+"'"
		EndIf
		cQuery +=    " AND D02_CARGA  = '"+cCarga+"'"
		If __nOpc != 1
			cQuery += " AND D02_PEDIDO = '"+cPedido+"'"
		EndIf
		cQuery +=    " AND D02_CODPRO = '"+cProduto+"'"
		If !Empty(cLote)
			cQuery += " AND D02_LOTE   = '"+cLote+"'"
		EndIf
		If !Empty(cSubLote)
			cQuery += " AND D02_SUBLOT = '"+cSubLote+"'"
		EndIf
		cQuery +=    " AND D02_STATUS IN ('1','2')"
		cQuery +=    " AND D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
		If !(cAliasQry)->(Eof())
			If QtdComp(nQuant) <> QtdComp((cAliasQry)->D02_QTSEPA)
				lRet := .F.
				WmsMessage('Quantidade Invalida!') 
			EndIf
			If lRet .And. QtdComp((cAliasQry)->D02_QTCONF+nQuant) > QtdComp((cAliasQry)->D02_QTSEPA) .And.;
				QtdComp(Abs((cAliasQry)->D02_QTSEPA-((cAliasQry)->D02_QTCONF + nQuant))) > QtdComp(nToler1UM)
				WmsMessage(STR0029) // Quantidade maior que separada!
				lRet := .F.
			EndIf
		EndIf
		(cAliasQry)->(DbCloseArea())
	Else
		cQuery := "SELECT SUM(D04_QTCONF) AS D04_QTCONF"
		cQuery +=  " FROM "+RetSqlName('D04')+" D04"
		cQuery += " WHERE D04_FILIAL = '"+xFilial('D04')+"'"
		If lUsaInCof
			cQuery += " AND D04_CODEXP IN ("+cCodExp+")"
		Else
			cQuery += " AND D04_CODEXP = '"+cCodExp+"'"
		EndIf
		cQuery +=    " AND D04_CARGA  = '"+cCarga+"'"
		If __nOpc != 1
			cQuery += " AND D04_PEDIDO = '"+cPedido+"'"
		EndIf
		cQuery +=    " AND D04_CODPRO = '"+cProduto+"'"
		If !Empty(cLote)
			cQuery += " AND D04_LOTE   = '"+cLote+"'"
		EndIf
		If !Empty(cSubLote)
			cQuery += " AND D04_SUBLOT = '"+cSubLote+"'"
		EndIf
		cQuery +=    " AND D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
		If (cAliasQry)->(!Eof())
			If QtdComp(nQuant) > QtdComp((cAliasQry)->D04_QTCONF) .And.;
				QtdComp(Abs((cAliasQry)->D04_QTCONF-nQuant)) > QtdComp(nToler1UM)
				WmsMessage(STR0049) // Quantidade maior que conferida!
				lRet := .F.
			EndIf
		EndIf
		(cAliasQry)->(DbCloseArea())
	EndIf

	If !lRet
		VTKeyBoard(Chr(20))
	EndIf

RestArea(aAreaAnt)
Return lRet

//----------------------------------------------------------
/*/{Protheus.doc} DLG102QTDE
Realiza as validações necessárias para tratar a quantidade
de acordo com o parâmetro MV_WMSUMI

@author  Guilherme Alexandre Metzger
@version P11
@since   24/10/14
/*/
//----------------------------------------------------------
Static Function DLG102QTDE(cCarga,cPedido,cProduto,cLote,cSubLote,cPrdAnt,cDscUM,nItem,nQtdNorma)
Local aUNI      := {}
Local aTelaAnt  := {}
Local cUM       := ''
Local cMsg      := ''
Local cLocal    := ''
Local cEstFis   := ''

	// Força selecionar unidade de medida se informou produto
	// diferente ou a cada leitura do codigo do produto
	If cProduto <> cPrdAnt .Or. SuperGetMV('MV_WMSCONF',.F.,.F.)
		__cWmsUMI := AllTrim(SuperGetMV('MV_WMSUMI',.F.,'0'))
		nItem   := 0
	EndIf
	SB1->(DbSetOrder(1))
	SB1->(MsSeek(xFilial('SB1')+cProduto))
	cPrdAnt := cProduto

	While .T.
		// Se parametro MV_WMSUMI = 4, utilizar U.M.I. informada no SB5
		If __cWmsUMI == '4'
			SB5->(DbSetOrder(1))
			SB5->(MsSeek(xFilial('SB5')+cProduto))
			__cWmsUMI := SB5->B5_UMIND
			If !(__cWmsUMI$'1ú2')
				__cWmsUMI := '0'
			EndIf
		EndIf

		If __cWmsUMI $ '2ú3ú5' .And. Empty(SB1->B1_SEGUM)
			__cWmsUMI := '1'
		EndIf

		// Se parametro MV_WMSUMI = 3 ou 5, permite a escolha da U.M. com a qual irá trabalhar
		If __cWmsUMI $ '3ú5'
			If nItem == 0
				nQtdNorma := DLG102NORM(cCarga,cPedido,cProduto,cLote,cSubLote,@cDscUM,@cLocal,@cEstFis)
				If nQtdNorma == 0
					cMsg := WmsFmtMsg(STR0077,{{'[VAR01]',cProduto},{'[VAR02]',cLocal+'/'+cEstFis}})
					WmsMessage(cMsg) //MV_WMSUMI 3 -> 4 Sem norma para Produto: [VAR01] Armazém/Estrutura: [VAR02]
					__cWmsUMI := '4'
					Loop
				EndIf
				nItem := 3
				AAdd(aUNI,{cDscUM})
				AAdd(aUNI,{Posicione('SAH',1,xFilial('SAH')+SB1->B1_SEGUM,'AH_UMRES')})
				AAdd(aUNI,{Posicione('SAH',1,xFilial('SAH')+SB1->B1_UM,   'AH_UMRES')})
				//--            1
				//--  01234567890123456789
				//--0 UNIDADE
				//--1 -------------------
				//--2 PALETE PBRII
				//--3 CAIXA
				//--4 PECA
				//--5 ___________________
				//--6
				//--7  Unidade p/ Confer?
				aTelaAnt := VTSave(00, 00, VTMaxRow(), VTMaxCol())
				DLVTCabec()
				DLVTRodaPe(STR0062,.F.) //Unidade p/ Conf.?
				nItem := VTaBrowse(0,0,VTMaxRow()-3,VTMaxCol(),{STR0063},aUNI,{VTMaxCol()},,nItem) //Unidade
				VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
				If nItem <= 0
					nItem = 3
				EndIf
				cDscUM := aUNI[nItem,1]
			EndIf
		Else
			If __cWmsUMI $ '0ú1'
				cUM := SB1->B1_UM
			ElseIf __cWmsUMI == '2'
				cUM := SB1->B1_SEGUM
			EndIf
			SAH->(DbSetOrder(1))
			SAH->(MsSeek(xFilial('SAH')+cUM))
			cDscUM := PadR(SAH->AH_UMRES,VTMaxCol())
		EndIf
		Exit
	EndDo

Return

//----------------------------------------------------------
/*/{Protheus.doc} DLG102NORM
Busca a quantidade do produto equivalente a uma norma

@return  nQtdNorma   Quantidade do produto equivalente a uma norma
@author  Guilherme Alexandre Metzger
@version P11
@since   24/10/14
/*/
//----------------------------------------------------------
Static Function DLG102NORM(cCarga,cPedido,cProduto,cLote,cSubLote,cDscUM,cLocal,cEstFis)
Local aAreaAnt  := GetArea()
Local cQuery    := ''
Local cAliasQry := GetNextAlias()
Local nQtdNorma := 0

	cQuery := "SELECT DISTINCT C9_LOCAL, BE_ESTFIS"
	cQuery +=  " FROM "+RetSqlName('SC9')+" SC9, "+RetSqlName('SBE')+" SBE"
	cQuery += " WHERE C9_FILIAL  = '"+xFilial('SC9')+"'"
	cQuery +=   " AND BE_FILIAL  = '"+xFilial('SBE')+"'"
	cQuery +=   " AND C9_CARGA   = '"+cCarga+"'"
	cQuery +=   " AND C9_PRODUTO = '"+cProduto+"'"
	cQuery +=   " AND BE_LOCAL   = C9_LOCAL"
	cQuery +=   " AND BE_LOCALIZ = C9_ENDPAD"
	cQuery +=   " AND SC9.D_E_L_E_T_ = ' '"
	cQuery +=   " AND SBE.D_E_L_E_T_ = ' '"
	If __nOpc != 1
		cQuery += " AND C9_PEDIDO  = '"+cPedido+"'"
	EndIf
	If !Empty(cLote)
		cQuery += " AND C9_LOTECTL = '"+cLote+"'"
	EndIf
	If !Empty(cSubLote)
		cQuery += " AND C9_NUMLOTE = '"+cSubLote+"'"
	EndIf
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T., "TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	If (cAliasQry)->(!Eof())
		cLocal    := (cAliasQry)->C9_LOCAL
		cEstFis   := (cAliasQry)->BE_ESTFIS
		nQtdNorma := DLQtdNorma(cProduto,cLocal,cEstFis,@cDscUM,.F.)
	EndIf
	(cAliasQry)->(DbCloseArea())

RestArea(aAreaAnt)
Return nQtdNorma

//----------------------------------------------------------
/*/{Protheus.doc} DLG102VLDF
Verifica se toda a quantidade liberada de toda a carga/pedido
foi conferida

@return  lFinal   Indica se a conferência chegou ao final
@author  Guilherme A. Metzger
@version P11
@since   11/09/15
/*/
//----------------------------------------------------------
Static Function DLG102VLDF(cCodExp,cCarga,cPedido,lUsaInCof,lVldSep)
Local aAreaAnt  := GetArea()
Local lFinal    := .T.
Local cQuery    := ""
Local cAliasD02 := GetNextAlias()
Local cAliasSC9 := GetNextAlias()
Local cAliasSDB := GetNextAlias()
Local cStatProb := SuperGetMV('MV_RFSTPRO', .F., '2') // DB_STATUS indincando Atividade com Problemas
Local cStatInte := SuperGetMV('MV_RFSTINT', .F., '3') // DB_STATUS indincando Atividade Interrompida
Local cStatAExe := SuperGetMV('MV_RFSTAEX', .F., '4') // DB_STATUS indincando Atividade A Executar

Default cPedido := ""

	// Realiza somatória da quantidade liberada da carga/pedido
	cQuery := "SELECT SUM(C9_QTDLIB) C9_QTDLIB"
	cQuery +=  " FROM "+RetSqlName('SC9')+" SC9, "+RetSqlName('D0H')+" D0H"
	cQuery += " WHERE SC9.C9_FILIAL  = '"+xFilial("SC9")+"'"
	cQuery +=    " AND D0H.D0H_FILIAL = '"+xFilial("D0H")+"'"
	If lUsaInCof
		cQuery += " AND D0H.D0H_CODEXP IN ("+cCodExp+")"
	Else
		cQuery += " AND D0H.D0H_CODEXP = '"+cCodExp+"'"
	EndIf
	cQuery +=    " AND SC9.C9_CARGA   = '"+cCarga+"'"
	If __nOpc != 1
		cQuery += " AND SC9.C9_PEDIDO = '"+cPedido+"'"
	EndIf
	cQuery +=    " AND SC9.C9_IDDCF   = D0H.D0H_IDDCF"
	cQuery +=    " AND SC9.C9_QTDLIB  > 0"
	cQuery +=    " AND SC9.D_E_L_E_T_ = ' '"
	cQuery +=    " AND D0H.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasSC9,.F.,.T.)

	// Realiza somatória da quantidade conferida da carga/pedido
	cQuery := "SELECT SUM(D02_QTCONF) D02_QTCONF"
	cQuery +=  " FROM " + RetSqlName('D02')
	cQuery += " WHERE D02_FILIAL = '"+xFilial('D02')+"'"
	If lUsaInCof
		cQuery += " AND D02_CODEXP IN ("+cCodExp+")"
	Else
		cQuery += " AND D02_CODEXP = '"+cCodExp+"'"
	EndIf
	cQuery +=    " AND D02_CARGA  = '"+cCarga+"'"
	If __nOpc != 1
		cQuery += " AND D02_PEDIDO = '"+cPedido+"'"
	EndIf
	cQuery +=    " AND D02_QTSEPA > 0"
	cQuery +=    " AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasD02,.F.,.T.)
	lFinal := QtdComp((cAliasSC9)->C9_QTDLIB) == QtdComp((cAliasD02)->D02_QTCONF)
	(cAliasD02)->(DbCloseArea())
	(cAliasSC9)->(DbCloseArea())
	
	If lFinal .And. lVldSep
		cQuery := "SELECT R_E_C_N_O_ RECNOSDB"
		cQuery +=  " FROM " + RetSqlName('SDB')
		cQuery += " WHERE DB_FILIAL  = '"+xFilial('SDB')+"'"
		cQuery +=   " AND DB_CARGA   = '"+cCarga+"'"
		If __nOpc != 1
			cQuery += " AND DB_DOC   = '"+cPedido+"'"
		EndIf
		cQuery +=   " AND DB_STATUS IN ('"+cStatProb+"','"+cStatInte+"','"+cStatAExe+"')"
		cQuery +=   " AND DB_ESTORNO = ' '"
		cQuery +=   " AND DB_ATUEST  = 'N'"
		cQuery +=   " AND D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasSDB,.F.,.T.)
		If !(cAliasSDB)->(Eof())
			// Existe separação pendente para o documento. Selecione uma opção:
			If WmsMessage(STR0031,STR0007,,,{STR0042,STR0043}) != 2 // Aguardar Separação // Final. Conferência
				lFinal := .F.
			EndIf
		EndIf
	EndIf
	

RestArea(aAreaAnt)
Return lFinal
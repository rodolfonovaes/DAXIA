#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FIVEWIN.CH'
#INCLUDE 'WMSV085.CH'
#INCLUDE 'APVT100.CH'

#DEFINE WMSV08501 "WMSV08501"
#DEFINE WMSV08502 "WMSV08502"
#DEFINE WMSV08503 "WMSV08503"
#DEFINE WMSV08504 "WMSV08504"
#DEFINE WMSV08505 "WMSV08505"
#DEFINE WMSV08506 "WMSV08506"
#DEFINE WMSV08507 "WMSV08507"
#DEFINE WMSV08508 "WMSV08508"
#DEFINE WMSV08509 "WMSV08509"
#DEFINE WMSV08510 "WMSV08510"
#DEFINE WMSV08511 ""
#DEFINE WMSV08512 ""
#DEFINE WMSV08513 "WMSV08513"
#DEFINE WMSV08514 "WMSV08514"
#DEFINE WMSV08515 "WMSV08515"
#DEFINE WMSV08516 "WMSV08516"
#DEFINE WMSV08517 "WMSV08517"
#DEFINE WMSV08518 ""
#DEFINE WMSV08519 ""
#DEFINE WMSV08520 ""
#DEFINE WMSV08521 "WMSV08521"
#DEFINE WMSV08522 "WMSV08522"
#DEFINE WMSV08523 ""
#DEFINE WMSV08524 "WMSV08524"
//-----------------------------------------------------------
/*/{Protheus.doc} WMSV085
Recebimento de mercadorias c/Separacao p/NF
@author Fernando Joly Siquini
@since 25/04/2002
@version 1.0
/*/
//-----------------------------------------------------------
Static lDV080INI := ExistBlock("DV080INI") // Executado antes do inicio da atividade, permite validação
Static lDV080ENO := ExistBlock("DV080ENO") // Executado para definir o endereço origem
Static lDV080ORI := ExistBlock("DV080ORI") // Executado após informado o endereço origem, válido ou não
Static lDV080END := ExistBlock("DV080END") // Executado para definir o endereço destino
Static lWMV080VL := ExistBlock("WMV080VL") // Executado para efetuar as validações dos campos endereço/unitizador
Static lDV080SED := ExistBlock("DV080SED") // Executado para suprimir o envio para o destino e todo o processo de finalização
Static lDV080DST := ExistBlock("DV080DST") // Executado para substituir a tela padrão de endereço destino
Static lDV080OPC := ExistBlock("DV080OPC") // Executado para substituir a tela de troca de endereço
Static lDV080DES := ExistBlock("DV080DES") // Executado após a movimentação de estoque e finalização da atividade
Static lDV080EST := ExistBlock("DV080EST") // Executado para indicar se deve ou não movimentar estoque
Static lDVATUEST := ExistBlock("WMSV085END") // Executado para indicar se deve ou não movimentar estoque - Não utilizar mais

User Function UWMSV085()

Local aAreaAnt  := GetArea()
Local aSavKey   := VTKeys() // Salva todas as teclas de atalho anteriores
Local cArmazem  := ""
Local cEndereco := ''
Local cConfirma := ''
Local lRet      := .T.
Local lRetPE    := .T.
Local cRetPE    := ''
// 0=Permanece como antes ate a proxima versao
Local nQtdTot   := 0
Local lPrimAtiv := ""
Local lUltiAtiv := ""
Local lMultAtiv := .F. // Multiplas atividades solicitando se deseja realizar outra atividade
Local cIdUnit   := ""
Local cMsg      := ""

	U_WAltSts(.F.)
	If WmsEndDEs()
		// Deve descarregar as atividades pendentes
		lRet := DesMulAtiv(@cArmazem,@cEndereco,@cIdUnit)
		// Restaura as teclas de atalho anteriores
		VTKeys(aSavKey)
		RestArea(aAreaAnt)
		Return lRet
	EndIf

	lPrimAtiv := oMovimento:IsPriAtiv()
	lUltiAtiv := oMovimento:IsUltAtiv()

	If lRet
		// Atribui a Funcao de ENDERECO a Combinacao de Teclas <CTRL> + <E>
		VTSetKey(5, {|| WMSEnder(00, 00, cEndereco, cArmazem)},STR0001)   // Endereco
		// Atribui a Funcao de INFORMACAO DO PRODUTO a Combinacao de Teclas <CTRL> + <I>
		VTSetKey(9, {|| WMSInfoPrd()} ,STR0002)   // Inf.Produto
		// Execblock apos a confirmacao do endereco
		If lDV080INI
			lRetPE := ExecBlock('DV080INI', .F., .F., {cConfirma, cEndereco})
			If ValType(lRetPE) == 'L'
				lRet := lRetPE
			EndIf
		EndIf
	EndIf

	// Informa o Endereco de Origem
	If lRet
		If (oMovimento:GetQtdMov() - oMovimento:GetQtdLid()) > 0
			// Direciona RH para o Endereco Origem
			If !lPrimAtiv .And. oMovimento:oMovTarefa:GetSolEnd() == "2"
				// Usa endereco DESTINO se nao eh primeira atividade.
				cArmazem := oMovimento:oMovEndDes:GetArmazem()
				cEndereco := oMovimento:oMovEndDes:GetEnder()
				cIdUnit := oMovimento:GetUniDes() // Unitizador destino
			Else
				cArmazem := oMovimento:oMovEndOri:GetArmazem()
				cEndereco := oMovimento:oMovEndOri:GetEnder()
				cIdUnit := oMovimento:GetIdUnit() // Unitizador origem
			EndIf
			If lDV080ENO
				cRetPE := ExecBlock('DV080ENO', .F., .F.)
				cEndereco := Iif(ValType(cRetPE)=="C",cRetPE,cEndereco)
			EndIf

			// Verifica se o movimento anterior é do mesmo endereço origem e não solicita novamente
			If !(Alltrim(cAntEndOri) == AllTrim(oMovimento:oMovEndOri:GetEnder()))
				Do While lRet .And. U_WOpcESC() == 0 .And. !WmsEndDes()
					WMSEnder(00, 00, cEndereco, cArmazem,,,STR0003) // Va p/o Endereco
					If (VTLastKey()==27)
						WmsCtrlESC()
						Loop
					EndIf
					Exit
				EndDo

				// Solicita confirmacao do Endereco de Origem
				Do While lRet .And. U_WOpcESC() == 0 .And. !WmsEndDes()
					// Insere espaços no campo de confimação
					cConfirma := Space(Len(cEndereco))
					// 01234567890123456789
					// 0 __Va p/o Endereco___
					// 1
					// 2 Endereco
					// 3 DOCA
					// 4
					// 5 Confirme !
					// 6 DOCA
					// 7
					WMSVTCabec(STR0003,.F.,.F.,.T.) // Va p/o Endereco
					@ 01, 00 VTSay PadR(STR0054, VTMaxCol()) // Armazem
					@ 02, 00 VTSay PadR(cArmazem, VTMaxCol())
					@ 03, 00 VTSay PadR(STR0001, VTMaxCol())  // Endereco
					@ 04, 00 VTSay PadR(cEndereco, VTMaxCol())
					@ 05, 00 VTSay PadR(STR0007, VTMaxCol())  // Confirme!
					@ 06, 00 VTGet cConfirma Pict '@!' Valid ValEndereco(@cConfirma, cEndereco, 1)
					VTRead
					If (VTLastKey()==27)
						WmsCtrlESC()
						Loop
					EndIf
					// Execblock apos a confirmacao do endereco
					If lDV080ORI
						lRetPE := ExecBlock('DV080ORI', .F., .F., {cConfirma, cEndereco, lRet})
						If ValType(lRetPE) == 'L'
							lRet := lRetPE
						EndIf
					EndIf
					cAntEndOri := oMovimento:oMovEndOri:GetEnder()
					Exit
				EndDo
			EndIf

			 // Se não pulou ou bloqueou a atividade, nem escolheu descarregar, processa a atividade
			If lRet .And. U_WOpcESC() == 0 .And. !WmsEndDes()
				If oMovimento:IsMovUnit()
					// Requisita a confirmação do código do unitizador quando for unitizador completo
					lRet := RequestUni(.T.,1,.T.)
				Else
					// Carrega quantidade sempre na primeira unidade
					// Retorna unidade de medida e quantidade saldo convertida
					nQtdTot := oMovimento:GetQtdMov() - oMovimento:GetQtdLid()
					// Solicita quantidade lida.
					lRet := RequestUM(nQtdTot,.T.,1)
				EndIf
			EndIf
		Else
			If oMovimento:IsMovUnit()
				cMsg := WmsFmtMsg(STR0049,{{"[VAR01]",oMovimento:GetIdUnit()}}) // "Unitizador [VAR01] já coletado. Faltando apenas finalizar atividade."
			Else
				cMsg := WmsFmtMsg(STR0050,{{"[VAR01]",oMovimento:oMovPrdLot:GetProdCol()}}) // "Produto [VAR01] "
				If !Empty(oMovimento:oMovPrdLot:GetLoteCtl())
					cMsg += WmsFmtMsg(STR0051,{{"[VAR01]",oMovimento:oMovPrdLot:GetLoteCtl()}}) // "Lote [VAR01] "
				EndIf
				If !Empty(oMovimento:oMovPrdLot:GetNumLote())
					cMsg += WmsFmtMsg(STR0052,{{"[VAR01]",oMovimento:oMovPrdLot:GetNumLote()}}) // "Sub-Lote [VAR01] "
				EndIf
				cMsg += WmsFmtMsg(STR0053,{{"[VAR01]",Transform(oMovimento:GetQtdMov(),PesqPict("D12","D12_QTDMOV"))}}) // "Qtd [VAR01] já coletado. Faltando apenas finalizar atividade."
			EndIf
			WMSVTAviso(WMSV08513,cMsg) // "Produto [VAR01] Lote [VAR01] Sub-Lote [VAR01] Qtd [VAR01] já endereçada. Faltando apenas finalizar atividade."##"Unitizador [VAR01] já endereçado. Faltando apenas finalizar atividade."
		EndIf

		If lRet
			// Se quer bloquear a atividade atual ou todas as outras
			If U_WOpcESC() == 1 .Or. U_WOpcESC() == 2
				oMovimento:SetStatus("2")
				oMovimento:SetPrAuto("1") // Permite reinicio automático
				oMovimento:SetDataFim(dDataBase)
				oMovimento:SetHoraFim(Time())
				oMovimento:UpdateD12()
			// Se quer pular apenas esta atividade ou descarregar as outras
			ElseIf U_WOpcESC() == 3 .Or. WmsEndDes()
				If U_WOpcESC() == 3
					WMSAltPri() // Altera a prioridade da atividade atual
				EndIf
				oMovimento:SetStatus("4")
				oMovimento:UpdateD12()
			EndIf
			// Se não pulou ou bloqueou a atividade, nem escolheu descarregar, coloca a mesma na pilha
			If U_WOpcESC() == 0 .And. !WmsEndDes()
				// Solicita endereco destino
				If lPrimAtiv .And. !lUltiAtiv .And. oMovimento:oMovTarefa:GetSolEnd() == "1"
				// Usa endereco ORIGEM se eh primeira atividade.
					// Solicita mesmo endereco, pois trata-se do 1o movto.
					cArmazem := oMovimento:oMovEndOri:GetArmazem()
					cEndereco := oMovimento:oMovEndOri:GetEnder()
					cIdUnit := oMovimento:GetIdUnit() // Unitizador origem
				Else
					cArmazem := oMovimento:oMovEndDes:GetArmazem()
					cEndereco := oMovimento:oMovEndDes:GetEnder()
					cIdUnit := oMovimento:GetUniDes() // Unitizador destino
				EndIf
				// PE para selecionar endereco destino
				If lDV080END
					cRetPE := ExecBlock("DV080END", .F., .F.)
					cEndereco := Iif(ValType(cRetPE)=="C",cRetPE,cEndereco)
				EndIf
	
				// Grava array com os dados para enderecamento no final
				AAdd(oMovimento:GetArrCol(),;
								{oMovimento:GetRecno(),;
								DtoS(dDataBase)+Time(),;
								oMovimento:oMovEndOri:GetArmazem(),;
								oMovimento:oMovEndOri:GetEnder(),;
								cEndereco,;
								oMovimento:oMovPrdLot:GetProduto(),;
								oMovimento:oMovPrdLot:GetLoteCtl(),;
								oMovimento:oMovPrdLot:GetNumLote(),;
								oMovimento:GetQtdMov(),;
								oMovimento:oOrdServ:GetCarga(),;
								oMovimento:oOrdServ:GetDocto(),;
								oMovimento:oOrdServ:GetCliFor(),;
								oMovimento:oOrdServ:GetLoja(),;
								lPrimAtiv,;
								lUltiAtiv,;
								oMovimento:GetIdUnit()})
			EndIf
			// Limpa as opções do ESC quando tratar apenas da atividade atual
			If U_WOpcESC() == 2 .Or. U_WOpcESC() == 3
				U_WOpcESC(0)
			EndIf
		EndIf
	EndIf

	// Se deu erro, bloqueia a atividade atual
	If !lRet
		oMovimento:SetStatus("2")
		oMovimento:SetPrAuto("1") // Permite reinicio automático
		oMovimento:SetDataFim(dDataBase)
		oMovimento:SetHoraFim(Time())
		oMovimento:UpdateD12()
	EndIf
	lRet := .T.

	// Se não escolheu levar para o destino, deve verificar se existem outras atividades
	If U_WOpcESC() == 0 .And. !WmsEndDes()
		// Verifica se tem mais registro com o mesmo tarefa
		// Verifica se a atividade nesta ordem permite multiplos movimentos
		If oMovimento:oMovServic:GetMltAti() == "2" .And. oMovimento:oMovTarefa:ChkPerMult()
			If WMSMultAti(oMovimento:GetRecno())
				lMultAtiv := .T.
			EndIf
		EndIf
	EndIf
	// Senão deve descarregar os registros pendentes
	If U_WOpcESC() == 0 .And. !lMultAtiv .And. Len(oMovimento:GetArrCol()) > 0
		If Len(oMovimento:GetArrCol()) > 1 .Or. WmsEndDes()
			// Passa por referencia o armazém e endereço por causa da tecla de atalho <CTRL> + <E>
			lRet := DesMulAtiv(@cArmazem,@cEndereco,@cIdUnit)
		Else
			lRet := DesUmaAtiv(@cArmazem,@cEndereco,lPrimAtiv,lUltiAtiv,@cIdUnit)
		EndIf
		// Deverá inicializar a validação da endereço origem preenchido
		cAntEndOri := ""
	EndIf
	// Se deu erro, bloqueia a atividade atual
	If !lRet .And. U_WOpcESC() == 0
		oMovimento:SetStatus("2")
		oMovimento:SetPrAuto("1") // Permite reinicio automático
		oMovimento:SetDataFim(dDataBase)
		oMovimento:SetHoraFim(Time())
		oMovimento:UpdateD12()
	EndIf

	VTClear()
	VTKeyBoard(Chr(13)) // Tecla ENTER
	VTInkey(0)
	VTClearBuffer()
	// Restaura as teclas de atalho anteriores
	VTKeys(aSavKey)
	RestArea(aAreaAnt)
Return lRet
/*--------------------------------------------------------------------------------
---ValEndereco
---Valida o Endereco/Unitizador Digitado
---Fernando Joly Siquini - 24/12/200
---cConfirma, caracter, (Unidade de medida)
---cSistema, caracter, (Quantidade digitada)
---nTipo, numerico, (Tipo de validação - 1-Endereço origem
                                         2-Endereço destino)
----------------------------------------------------------------------------------*/
Static Function ValEndereco(cConfirma, cSistema, nTipo)
Local lRet         := (cConfirma==cSistema)
Local lPrimAtiv    := oMovimento:IsPriAtiv()

	//-----------------------------------------------------------
	// Ponto de entrada para validacao do Endereco/Unitizador
	// Parametros passados no Ponto de Entrada:
	// PARAMIXB[01] = Endereco/Unitizador Digitado
	// PARAMIXB[02] = Endereco/Unitizador designado pelo sistema
	// PARAMIXB[03] = Tipo de Validacao, onde:
	//                1-Endereco origem
	//                2-Endereco Destino
	// Retorno: O retorno DEVE OBRIGATORIAMENTE ser logigo,
	//          onde TRUE confirma a validacao e FALSE pede
	//          nova digitacao.
	// Obs.: Esta posicionado no registro referente ao servico
	//       no arquivo D12.
	//----------------------------------------------------------

	//Rodolfo - Ajuste para pegar o BE_XID
	SBE->(DbSetOrder(11))
	If SBE->(DbSeek(xFilial('SBE') + oMovimento:oMovEndOri:GetArmazem() + cConfirma))
		cConfirma := SBE->BE_LOCALIZ
	EndIf

	If lWMV080VL
		lRet := ExecBlock('WMV080VL', .F., .F., {cConfirma, cSistema, nTipo})
		If !lRet
			cConfirma := Space(Len(cSistema))
		EndIf
	Else
		// Indereço informado diferente do sistema
		// Verifica se é a primeira atividade e solicita se deseja alterar o endereço destino
		If !lRet .And. !Empty(cConfirma) .And. lPrimAtiv .And. nTipo == 2 .And. oMovimento:oMovServic:ChkUpdEnd() .And. (Empty(oMovimento:oOrdServ:GetIdOrig()) .Or. oMovimento:oOrdServ:FindDCFOri() == "SC9")
			lRet := AlterarEnd(@cConfirma)
		Else
			If !lRet
				If nTipo == 1
					WMSVTAviso(WMSV08506,WmsFmtMsg(STR0018,{{"[VAR01]",cConfirma}})) // Endereco origem [VAR01] incorreto.
				ElseIf nTipo == 2
					WMSVTAviso(WMSV08507,WmsFmtMsg(STR0019,{{"[VAR01]",cConfirma}})) // Endereco destino [VAR01] incorreto.
				EndIf
				VTKeyBoard(chr(20))
			EndIf
		EndIf
	EndIf
Return lRet
/*--------------------------------------------------------------------------------
---RequestUni
---Solicita o código do unitizador
---felipe.m - 09/05/2017
---lShowUnit - Mostra ou não o unitizador a ser pego
---nTipo - 1=Unitizador Origem;2=Unitizador Destino
----------------------------------------------------------------------------------*/
Static Function RequestUni(lShowUnit,nTipo,lAtzQtdLid)
Local aTelaAnt    := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local lRet        := .T.
Local cIdUnit     := ""
Local cConfirma   := ""
Local lRequest    := .T.
Default lShowUnit := .T.
Default nTipo     := 1

	If nTipo == 1
		cIdUnit := oMovimento:GetIdUnit()
	ElseIf nTipo == 2
		// Quando solicita unitizador destino, não confirma quando são iguais
		If (oMovimento:GetIdUnit() == oMovimento:GetUniDes()) .Or. Empty(oMovimento:GetUniDes())
			lRequest := .F.
		EndIf
		cIdUnit := oMovimento:GetUniDes()
	EndIf

	If lRequest
		If lShowUnit
			// Informa o unitizador a ser pego
			Do While lRet .And. U_WOpcESC() == 0 .And. !WmsEndDes()
				WMSVTCabec(STR0008, .F., .F., .T.)   // Pegue o Unitizador
				@ 02, 00 VTSay PadR(cIdUnit, VTMaxCol())
				WMSVTRodPe()
				If (VTLastKey()==27)
					WmsCtrlESC()
					Loop
				EndIf
				Exit
			EndDo
		EndIf
		//            1
		//  01234567890123456789
		// 0 ___Endereçamento___
		// 1
		// 2 Unitizador
		// 3 000006
		// 4 Confirme
		// 5 000006
		// 6
		// 7
		// Solicita confirmacao do Unitizador
		Do While lRet .And. U_WOpcESC() == 0 .And. !WmsEndDes()
			cConfirma := Space(Len(cIdUnit))
			WMSVTCabec(oMovimento:oMovTarefa:GetDesTar(),.F.,.F.,.T.)
			@ 02, 00 VTSay PadR(STR0009, VTMaxCol())  // Unitizador
			@ 03, 00 VTSay PadR(cIdUnit, VTMaxCol())
			@ 05, 00 VTSay PadR(STR0007, VTMaxCol())  // Confirme!
			@ 06, 00 VTGet cConfirma Pict '@!' Valid WMSValUnit(cConfirma, cIdUnit)
			VTRead()
			If (VTLastKey()==27)
				WmsCtrlESC()
				Loop
			EndIf
			Exit
		EndDo
	EndIf

	If lRet .And. lAtzQtdLid // Quando está sendo chamado da descarga multi-tarefa não pode atualizar
		// Grava a quantidade lida para o movimento
		oMovimento:SetQtdLid(oMovimento:GetQtdLid() + 1)
		oMovimento:UpdateD12()
	EndIf
	VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
Return lRet
/*--------------------------------------------------------------------------------
---RequestUM
---Solicita a quantidade quando MV_WMSUMI igual a 3
---Alex Egydio - 17/02/2005
---nQtdTot, numerico, (Quantidade digitada)
---lAtzQtdLid, Logico, (Indica se atualiza a quantidade lida)
---nTipo, numérico, (1=Origem;2=Destino, unilizado para o unitizador)
----------------------------------------------------------------------------------*/
Static Function RequestUM(nQtdTot,lAtzQtdLid,nTipo)
Local nItem     := 0
Local cUM       := ""
Local cPictQt   := ""
Local cLoteCtl  := ""
Local cSubLote  := ""
Local cProduto  := ""
Local lRet      := .T.
Local lEncerra  := .F.
Local nProxLin  := 0
Local cCodBar   := ""
Local lTrocaPrd := .F.
Local nQtde     := 0
Local nQtdNorma := 0
Local nQtdItem  := 0
Local lFirst    := .T.
Local lWmsLote  := SuperGetMV('MV_WMSLOTE',.F.,.F.) // Solicita a confirmacao do lote nas operacoes com RF
Local lRfNNorm  := SuperGetMV('MV_RFNNORM',.F.,.F.) // Permite mover quantidades abaixo da norma nas operacoes com radio frequencia
Local lMntPrd   := .F.
Local cWmsUMI   := ""

	If lRfNNorm .And. lAtzQtdLid
		// Atribui funcao para executar endereçamento com qtde a menor a combinacao de teclas <CTRL> + <R>
		VTSetKey(18,{||(lEncerra:=EndParcial(cWmsUMI))},STR0035) // Ctrl+R // Ender Parcial
	EndIf

	While U_WOpcESC() == 0 .And. !WmsEndDes()
		If nQtdTot <= 0
			VtBeep(3)
			Exit
		EndIf
		If !lMntPrd
			// Carrega unidade de medida, simbolo da unidade e quantidade na unidade
			WmsValUM(@nQtdTot,;                               // Quantidade movimento
						@cWmsUMI,;                            // Unidade parametrizada
						oMovimento:oMovPrdLot:GetProduto(),;  // Produto
						oMovimento:oMovEndDes:GetArmazem(),;  // Armazem
						oMovimento:oMovEndDes:GetEnder())     // Endereço
			// Monta tela produto
			WmsMontPrd(cWmsUMI,;                              // Unidade parametrizada
						.F.,;                                 // Indica se é uma conferência
						oMovimento:oMovTarefa:GetDesTar(),;   // Descrição da tarefa
						oMovimento:oMovEndDes:GetArmazem(),;  // Armazem
						oMovimento:oMovEndDes:GetEnder(),;    // Endereço
						oMovimento:oMovPrdLot:GetPrdOri(),;   // Produto Origem
						oMovimento:oMovPrdLot:GetProduto(),;  // Produto
						oMovimento:oMovPrdLot:GetLoteCtl(),;  // Lote
						oMovimento:oMovPrdLot:GetNumLote(),;  // sub-lote
						oMovimento:GetIdUnit())               // Unitizador
			// Quando Utilizada a tecla para endereço parcial
			If lEncerra
				Exit
			EndIf
			If (VTLastKey()==27)
				WmsCtrlESC(!lAtzQtdLid)
				Loop
			EndIf
			lMntPrd := .T.
		EndIf

		// Seleciona unidade de medida
		WmsSelUM(cWmsUMI,;                           // Unidade parametrizada
				@cUM,;                                // Unidade medida reduzida
				Nil,;                                 // Descrição unidade medida
				nQtdTot,;                             // Quantidade movimento
				@nItem,;                              // Item seleção unidade
				@cPictQt,;                            // Mascara unidade medida
				@nQtdItem,;                           // Quantidade no item seleção unidade
				Nil,;                                 // Indica se é uma conferência
				oMovimento:oMovTarefa:GetDesTar(),;   // Descrição da tarefa
				oMovimento:oMovEndDes:GetArmazem(),;  // Armazem
				oMovimento:oMovEndDes:GetEnder(),;    // Endereço
				oMovimento:oMovPrdLot:GetPrdOri(),;   // Produto Origem
				oMovimento:oMovPrdLot:GetProduto(),;  // Produto
				oMovimento:oMovPrdLot:GetLoteCtl(),;  // Lote
				oMovimento:oMovPrdLot:GetNumLote())   // sub-lote
		// Quando Utilizada a tecla para endereço parcial
		If lEncerra
			Exit
		EndIf
		If (VTLastKey()==27)
			WmsCtrlESC(!lAtzQtdLid)
			Loop
		EndIf

		If nItem == 1 .And. nQtdItem < 1
			WMSVTAviso(WMSV08514,STR0032) // Para endereçamento com unitizador a quantidade não pode ser menor que um.
			lFirst := .T.
			Loop
		EndIf
		// Quando o movimento possui código do produto e código do unitizador informado,
		// caracteriza uma movimentação de unitizador parcial
		If !Empty(oMovimento:GetIdUnit())
			// Requisita a confirmação do código do unitizador
			lRet := RequestUni(.F.,nTipo,.F./*lAtzQtdLid*/)

			If lEncerra
				Exit
			EndIf
			If VTLastKey()==27
				WmsCtrlESC(!lAtzQtdLid)
				Loop
			EndIf
		EndIf
		//            1
		//  01234567890123456789
		// 0 ___Endereçamento___
		// 1 Pegue o Produto
		// 2 PA1
		// 3 PA1
		// 4 Lote
		// 5 AUTO000636
		// 6 Qtde 240 UM
		// 7     240.00
		// Mantém os dados do produto após a troca, pois passou pelo CBRetEti e CBRetEtiEAN
		cCodBar  := Iif(!lTrocaPrd,Space(128),cCodBar)
		cProduto := Iif(!lTrocaPrd,Space(Len(D12->D12_PRODUT)),cProduto)
		cLoteCtl := Iif(!lTrocaPrd,Space(Len(D12->D12_LOTECT)),cLoteCtl)
		cSubLote := Iif(!lTrocaPrd,Space(Len(D12->D12_NUMLOT)),cSubLote)
		nQtde    := Iif(!lTrocaPrd,0,nQtde)
		lTrocaPrd:= .F.
		WMSVTCabec(oMovimento:oMovTarefa:GetDesTar(),.F.,.F.,.T.)
		nProxLin := 1
		@ nProxLin++,00 VTSay PadR(STR0012, VTMaxCol())  // Pegue o Produto
		@ nProxLin++,00 VTSay oMovimento:oMovPrdLot:GetProdCol()
		@ nProxLin++,00 VTGet cCodBar Picture PesqPict('D12','D12_PRODUT') When Empty(cCodBar) Valid WMSValProd(oMovimento:oMovPrdLot:GetProduto(),@cProduto,@cLoteCtl,@cSubLote,@nQtde,@cCodBar,,,@lTrocaPrd)
		VTRead()
		// Quando Utilizada a tecla para endereço parcial
		If lEncerra
			Exit
		EndIf
		If VTLastKey()==27
			WmsCtrlESC(!lAtzQtdLid)
			Loop
		EndIf
		If lTrocaPrd
			// Chama novamente para carregar os dados do novo produto caso tenha trocado
			cUM      := ""
			nItem    := 0
			cPictQt  := ""
			nQtdItem := 0
			nQtdTot  := oMovimento:GetQtdMov() - oMovimento:GetQtdLid()
			lMntPrd  := .F.
			Loop
		EndIf
		If lWmsLote
			If oMovimento:oMovPrdLot:HasRastro()
				@ nProxLin,00 VTSay PadR(STR0045,VTMaxCol()) // Lote
				@ nProxLin++,06 VTGet cLoteCtl Picture PesqPict('D12','D12_LOTECT') When VTLastKey()==05 .Or. Empty(cLoteCtl) Valid ValidaLote(cLoteCtl,oMovimento:oMovPrdLot:GetLoteCtl())
			EndIf
			If oMovimento:oMovPrdLot:HasRastSub()
				@ nProxLin,00 VTSay PadR(STR0046,VTMaxCol()) // Sub-Lote
				@ nProxLin++,10 VTGet cSubLote Picture PesqPict('D12','D12_NUMLOT') When VTLastKey()==05 .Or. Empty(cSubLote) Valid ValSubLote(cSubLote,oMovimento:oMovPrdLot:GetNumLote())
			EndIf
		EndIf
		@ nProxLin++, 00 VTSay PadR(STR0016+' '+AllTrim(Str(nQtdItem))+' '+cUM, VTMaxCol()) // Qtde
		@ nProxLin++, 00 VTGet nQtde Picture cPictQt When VTLastKey()==05 .Or. Empty(nQtde) Valid !Empty(nQtde)
		VTRead()
		// Quando Utilizada a tecla para endereço parcial
		If lEncerra
			Exit
		EndIf
		If VTLastKey()==27
			WmsCtrlESC(!lAtzQtdLid)
			Loop
		EndIf
		// Processar validacoes quando etiqueta = Produto/Lote/Sub-Lote/Qtde
		If !(Iif(Empty(cLoteCtl),.T.,ValidaLote(cLoteCtl,oMovimento:oMovPrdLot:GetLoteCtl()))) .Or. ;
			!(Iif(Empty(cSubLote),.T.,ValSubLote(cSubLote,oMovimento:oMovPrdLot:GetNumLote())))
			lRet := .F.
			Loop
		EndIf

		If !(cWmsUMI == "2") // Se não está na 2a UM deve converter para a 1a UM
			// Converter de U.M.I. p/ 1a.UM
			If nItem == 1
				nQtdNorma:= DLQtdNorma(oMovimento:oMovPrdLot:GetProduto(),oMovimento:oMovEndDes:GetArmazem(),oMovimento:oMovEndDes:GetEstFis(),,.F.)
				nQtde    := (nQtde*nQtdNorma)
			// Converter de 2a.UM p/ 1a.UM
			ElseIf nItem == 2
				nQtde := ConvUm(oMovimento:oMovPrdLot:GetProduto(),0,nQtde,1)
			EndIf
		EndIf

		If QtdComp(nQtdTot - nQtde) < 0
			WMSVTAviso(WMSV08505,STR0015)   // Ultrapassou o total!
		Else
			// Desconta quantidade lida
			nQtdTot -= nQtde
			If lAtzQtdLid // Quando está sendo chamado da descarga multi-tarefa não pode atualizar
				// Grava a quantidade lida para o movimento
				oMovimento:SetQtdLid(oMovimento:GetQtdLid() + Iif(cWmsUMI == '2',ConvUm(oMovimento:oMovPrdLot:GetProduto(),0,nQtde,1),nQtde))
				oMovimento:UpdateD12()
			EndIf
		EndIf
	EndDo
	VTSetKey(18) // Ctrl+R
Return(lRet)
/*--------------------------------------------------------------------------------
---DesUmaAtiv
---Função para efetuar a descarga de apenas um movimento
---Jackson Patrick Werka - 01/04/2015
---cArmazem, character, (Armazem)
---cEndereco, character, (Endereco)
---lPrimAtiv, Logico, (Indica se é a primeira atividade)
---lUltiAtiv, Logico, (Indica se é a ultima atividade)
----------------------------------------------------------------------------------*/
Static Function DesUmaAtiv(cArmazem,cEndereco,lPrimAtiv,lUltiAtiv,cIdUnit)
Local aAreaAnt  := GetArea()
Local lRet      := .T.
Local lRetPE    := .F.
	If lDV080SED
		lRetPE := ExecBlock('DV080SED', .F., .F., {lRet})
		lRet := Iif(ValType(lRetPE)=="L",lRetPE,lRet)
	EndIf
	If lRet
		lRet := RequestEnd(cArmazem,cEndereco,lPrimAtiv,lUltiAtiv)
		If lRet
			lRet := RequestUni(.F.,2,.F.)
		EndIf
		If lRet
			lRet := FinalAtiv(lUltiAtiv,Len(oMovimento:GetArrCol()))
		EndIf
	EndIf
	RestArea(aAreaAnt)
Return lRet
/*--------------------------------------------------------------------------------
---DesMulAtiv
---Função para efetuar a descarga dos movimentos quando for multi-tarefa
---Jackson Patrick Werka - 01/04/2015
---cArmazem, character, (Armazem)
---cEndereco, character, (Endereco)
----------------------------------------------------------------------------------*/
Static Function DesMulAtiv(cArmazem,cEndereco,cIdUnit)
Local aAreaAnt  := GetArea()
Local lRet      := .T.
Local nCntEnd   := 0
Local nCntMov   := 0
Local aConfDes  := {}
Local aColetorx := oMovimento:GetArrCol()
Local cProduto  := ''
Local cLoteCtl  := ''
Local cSubLote  := ''
Local lPrimAtiv := .F.
Local lUltiAtiv := .F.
Local cEnderAnt := ""
Local cIdUnitAnt:= ""

	If Len(aColetorx) > 1
		aConfDes := oMovimento:OrdColetor()
	Else
		aConfDes := AClone(oMovimento:GetArrCol())
	EndIf
	For nCntEnd := 1 To Len(aConfDes)
		cArmazem  := aConfDes[nCntEnd,3]
		cEndereco := aConfDes[nCntEnd,5]
		cProduto  := aConfDes[nCntEnd,6]
		cLoteCtl  := aConfDes[nCntEnd,7]
		cSubLote  := aConfDes[nCntEnd,8]
		lPrimAtiv := aConfDes[nCntEnd,14]
		lUltiAtiv := aConfDes[nCntEnd,15]
		cIdUnit   := aConfDes[nCntEnd,16]
		
		//Posiciona D12
		oMovimento:GoToD12(aConfDes[nCntEnd,1])
		
		// Confirma endereço destino
		If !(cEnderAnt == cEndereco)
			lRet := RequestEnd(cArmazem,cEndereco,lPrimAtiv,lUltiAtiv)
			If lRet
				cEnderAnt := oMovimento:oMovEndDes:GetEnder()
			EndIf
		EndIf
		// Caso movimenta o unitizador completo
		If oMovimento:IsMovUnit()
			// Confirma unitizador destino
			If !(cIdUnitAnt == cIdUnit)
				lRet := RequestUni(.F.,2,.F.)
				If lRet
					cIdUnitAnt := cIdUnit
				EndIf
			EndIf
		Else
			// Deve pesquisar se tem mais algum registro indicando outro produto
			If lRet .And. oMovimento:oMovServic:GetMltAti() == "2"
				If Len(aConfDes) > 1
					oMovimento:GoToD12(aConfDes[nCntEnd,1]) // Posiciona no D12 para validar o produto
					nQtdTot := aConfDes[nCntEnd,9]
					// Solicita quantidade lida.
					lRet := RequestUM(nQtdTot,.F.,2)
				EndIf
			EndIf
		EndIf

		If lRet
			For nCntMov := Len(aColetorx) To 1 Step -1
				// Se a movimentação é para o mesmo endereço destino
				If aColetorx[nCntMov,3]+aColetorx[nCntMov,5]+aColetorx[nCntMov,6]+aColetorx[nCntMov,7]+aColetorx[nCntMov,8] == cArmazem+cEndereco+cProduto+cLoteCtl+cSubLote
					// Posiciona o registro de movimentação
					oMovimento:GoToD12(aColetorx[nCntMov,1])
					lRet := FinalAtiv(lUltiAtiv,nCntMov)
				EndIf
			Next nCntMov
		EndIf
		If U_WOpcESC() > 0
			// Neste caso, sempre vai forçar bloquear todas as atividades que ficaram pendentes
			If U_WOpcESC() == 2
				U_WOpcESC(1)
			EndIf
			Exit
		EndIf
	Next nCntEnd
	RestArea(aAreaAnt)
Return lRet
/*--------------------------------------------------------------------------------
---FinalAtiv
---Função para efetuar a finalização das atividades movimentando o estoque
---Jackson Patrick Werka - 01/04/2015
---lUltiAtiv, Logico, (Indica se é a ultima atividade)
---lPosCol, numerico
----------------------------------------------------------------------------------*/
Static Function FinalAtiv(lUltiAtiv,lPosCol)
Local aAreaAnt   := GetArea()
Local lRet       := .T.
Local lRetPE     := .T.
Local lAtuEst    := .T.
Local nLenVet    := 0
Local dDVldSB8	 := dDataBase
Local dDFabSB8	 := dDataBase
Local cLotForn	 := ''
Local cNomFabr	 := ''
Local cPaisOri	 := ''
Local cXCFABRI	 := ''
Local cXLFABRI	 := ''
Local cCliFor    := ''
Local cLoja      := ''
Local cXDProd    := ''
Default lUltiAtiv := .T.
Default lPosCol   := 1

	If lDVATUEST // Não utilizar mais
		lRetPE := ExecBlock("WMSV085END",.F.,.F.)
		lAtuEst:= Iif(ValType(lRetPE)=="L",lRetPE,lAtuEst)
	EndIf
	If lDV080EST
		lRetPE := ExecBlock("DV080EST",.F.,.F., {oMovimento:GetRecno()})
		lAtuEst:= Iif(ValType(lRetPE)=="L",lRetPE,lAtuEst)
	EndIf

	If lRet := oMovimento:LockD12()
		If oMovimento:GetStatus() == "3" // Verifica se conseguiu travar registro
			Begin Transaction
				If lAtuEst .And. oMovimento:IsUpdEst()
					// Confirma o movimento de distribuicao atualizando o estoque.
					If oMovimento:IsUpdEst()
						WMSVTCabec(oMovimento:oMovTarefa:GetDesTar(),.F.,.F.,.T.)
						VTMsg(STR0036) // Processando...
						lRet := oMovimento:RecEnter()
						If !lRet
							WMSVTAviso(WMSV08504,STR0011)  // Problemas no endereçamento!
						Else
							If !Empty(oMovimento:aPrdMont)
								nLenVet := Len(oMovimento:aPrdMont)
								WMSVTAviso(WMSV08522,WmsFmtMsg(STR0043,{{"[VAR01]",cValtoChar(oMovimento:aPrdMont[nLenVet][1])},{"[VAR02]",oMovimento:aPrdMont[nLenVet][2]},{"[VAR03]",oMovimento:aPrdMont[nLenVet][3]}})) // "Realizada a montagem de [VAR01] [VAR02] do produto [VAR03]!"
							EndIf
						EndIf
					EndIf
				EndIf
				If lRet
					// Atualiza o D12 para finalizado
					oMovimento:SetStatus("1")
					oMovimento:SetDataFim(dDataBase)
					oMovimento:SetHoraFim(Time())
					oMovimento:UpdateD12()
				EndIf
				If lRet
					If !Empty(oMovimento:GetArrCol())
						ADel(oMovimento:GetArrCol(),lPosCol) // Apaga do array o registro que ja foi movimentado
						ASize(oMovimento:GetArrCol(),Len(oMovimento:GetArrCol())-1)   // Exclui fisicamente o registro do array
					EndIf
				Else
					DisarmTransaction()
				EndIf
			End Transaction
			// Analise para liberar os pedidos de cross docking
			If lRet .And. oMovimento:oMovServic:ChkCross()
				oMovimento:UpdLibCrs()
			EndIf
			
			//If lDV080DES//Rodolfo- seria aqui o ajuste?
			  // ExecBlock('DV080DES', .F., .F.,{lRet,oMovimento:GetRecno()})
			//EndIf
			//RODOLFO - Atualização de campos customizados da SB8
			SB8->(DbSetOrder(3))
			If SB8->(DbSeek(xFilial('SB8') +  oMovimento:oMovPrdLot:GetProduto() + oMovimento:oMovEndOri:GetArmazem() + oMovimento:oMovPrdLot:GetLoteCtl()))
				dDVldSB8 := SB8->B8_DTVALID
				dDFabSB8 := SB8->B8_DFABRIC
				cLotForn := SB8->B8_LOTEFOR
				cNomFabr := SB8->B8_NFABRIC
				cPaisOri := SB8->B8_XPAISOR
				cXCFABRI := SB8->B8_XCFABRI
				cXLFABRI := SB8->B8_XLFABRI
				cCliFor  := SB8->B8_CLIFOR
				cLoja    := SB8->B8_LOJA
				cXDProd  := SB8->B8_XDPROD
				If SB8->(DbSeek(xFilial('SB8') + oMovimento:oMovPrdLot:GetProduto() + oMovimento:oMovEndDes:GetArmazem() + oMovimento:oMovPrdLot:GetLoteCtl()))
					Reclock('SB8',.F.)
					Replace SB8->B8_DTVALID With dDVldSB8
					Replace SB8->B8_DFABRIC With dDFabSB8
					Replace SB8->B8_NFABRIC With cNomFabr
					Replace SB8->B8_LOTEFOR With cLotForn 
					Replace SB8->B8_XPAISOR With cPaisOri
					Replace SB8->B8_XCFABRI With cXCFABRI
					Replace SB8->B8_XLFABRI With cXLFABRI	
					Replace SB8->B8_CLIFOR  With cCliFor
					Replace SB8->B8_LOJA    With cLoja
					Replace SB8->B8_XDPROD  With cXDProd   									
					Msunlock()
				EndIf
			EndIf
			//RODOLFO - Fim do ajuste
		EndIf
		oMovimento:UnLockD12()
	EndIf
	RestArea(aAreaAnt)
Return lRet
/*--------------------------------------------------------------------------------
---RequestEnd
---Solicita o endereco de destino
---Jackson Patrick Werka - 01/04/2015
---cArmazem, character, (Armazem)
---cEndereco, character, (Endereco)
---lPrimAtiv, Logico, (Indica se é a primeira atividade)
---lUltiAtiv, Logico, (Indica se é a ultima atividade)
----------------------------------------------------------------------------------*/
Static Function RequestEnd(cArmazem,cEndereco,lPrimAtiv,lUltiAtiv)
Local aTelaAnt  := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local lRet      := .T.
Local lRetPE    := .F.
Local cConfirma := ""

Default lPrimAtiv := .F.
Default lUltiAtiv := .F.

	// Ponto de entrada para elaborar a selecao do endereco de destino do endereçamento.
	If lDV080DST
		lRetPE := ExecBlock('DV080DST', .F., .F.)
		lRet := Iif(ValType(lRetPE)=="L",lRetPE,lRet)
	Else
		WMSEnder(00, 00, cEndereco, cArmazem,,,STR0010)  // Leve p/o Endereco
		If (VTLastKey()==27) .And. (WMSVTAviso(WMSV08501,STR0044, {STR0005,STR0006})==1) // Deseja interromper o enderecamento? // Sim // Nao
			U_WOpcESC(1) // Bloquear Todas Atividades
			lRet := .F.
		EndIf

		If lRet
			// Confirma Endereco
			While .T.
				cConfirma := PadR("",TamSx3("D12_ENDDES")[1])
				//  01234567890123456789
				// 0 Leve para o Endereco
				// 1
				// 2 Endereco
				// 3 R01P01N01
				// 4
				// 5 Confirme !
				// 6 R01P01N01
				// 7
				WMSVTCabec(STR0010,.F.,.F.,.T.) // Leve para o Endereco
				@ 01, 00 VTSay PadR(STR0054, VTMaxCol()) // Armazem
				@ 02, 00 VTSay PadR(cArmazem, VTMaxCol())
				@ 03, 00 VTSay PadR(STR0001, VTMaxCol())  // Endereco
				@ 04, 00 VTSay PadR(cEndereco, VTMaxCol())
				@ 05, 00 VTSay PadR(STR0007, VTMaxCol())  // Confirme !
				@ 06, 00 VTGet cConfirma Pict '@!' Valid ValEndereco(@cConfirma, cEndereco, 2)
				VTRead
				If (VTLastKey()==27)
					If WMSVTAviso(WMSV08502,STR0044, {STR0005,STR0006})==1   // Deseja interromper o Enderecamento? // Sim // Nao
						U_WOpcESC(1) // Bloquear Todas Atividades
						lRet := .F.
					Else
						Loop
					EndIf
				EndIf
				Exit
			EndDo
		EndIf
	EndIf

	VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
Return lRet
/*--------------------------------------------------------------------------------
---AlterarEnd
---Substitui o endereco de destino
---Alex Egydio - 23/11/2006
---cEndDest, character, (Endereco informado)
----------------------------------------------------------------------------------*/
Static Function AlterarEnd(cEndDest)
Local aTelaAnt  := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local aConfDes  := oMovimento:GetArrCol()
Local oMovAux   := WMSBCCMovimentoServico():New()
Local cOldEnd   := oMovimento:oMovEndDes:GetEnder()
Local oEtiqUnit := Nil
Local nCntEnd   := 0

Local lRet      := .T.
// Variavel definida no ponto de entrada WMV080VL quando eh feita a leitura de ID de endereco.
Private cV080End:= ''
	// Inicializa variavel de erro
	oMovimento:SetErro("")
	If lDV080OPC
		cEndDest := ExecBlock('DV080OPC', .F., .F., {oMovimento:oMovEndDes:GetEnder()})
	EndIf

	If !Empty(cV080End) .And. Empty(cEndDest)
		cEndDest := cV080End
	EndIf
	
	If Empty(cEndDest)
		WMSVTAviso(WMSV08508,STR0056) // Endereço destino não informado
		VTKeyBoard(chr(20))
		lRet := .F.
	EndIf
	
	If lRet
		If Len(aConfDes) == 1  .And. !Empty(oMovimento:oOrdServ:oOrdEndDes:GetEnder()) .And. oMovimento:HasMoreMov()
			WMSVTAviso(WMSV08524,STR0047) // Movimento originado de uma OS WMS com endereco destino informado e possui outros movimentos para este mesmo endereco destino.
		EndIf
		If WMSVTAviso(WMSV08510,STR0023,{STR0005,STR0006}) == 1   // Substitui o Endereco? // Sim // Nao
			// Atualiza o endereco destino nos documentos
			// Na convocacao com Radio Frequencia não é passada a quantidade pois ja sera considerada no calculo de saldo estoque por endereço
			//Busca os endereços que deverão ser alterados
			If !Empty(aConfDes) 
				Begin Transaction
					For nCntEnd := 1 To Len(aConfDes)
						If oMovimento:oMovEndDes:GetEnder() == aConfDes[nCntEnd,5]
							//Posiciona D12
							oMovAux:GoToD12(aConfDes[nCntEnd,1])
							oMovAux:oMovEndDes:SetEnder(cEndDest)
							oMovAux:SetQuant(oMovAux:GetQtdMov())
							If !oMovAux:ChkEndDes()
								If Len(aConfDes) > 1
									WMSVTAviso(WMSV08503,WmsFmtMsg(STR0055,{{"[VAR01]",cEndDest}})) // Quantidade dos múltiplos movimentos não suportada pelo endereço [VAR01], alteração não realiza
								Else
									WMSVTAviso(WMSV08521,oMovAux:GetErro())
								EndIf
								VTKeyBoard(chr(20))
								lRet := .F.
							Else
								// Atribui novamente o endereço destino original
								// Para efetuar a busca das atividades a serem alteradas
								// o endereço destino
								oMovAux:oMovEndDes:SetEnder(cOldEnd)
								oMovAux:oMovEndDes:LoadData()
								If oMovAux:IsMovUnit()
									//Carrega informação do tipo do unitizador
									oEtiqUnit  := WMSDTCEtiquetaUnitizador():New()
									oEtiqUnit:SetIdUnit(oMovAux:GetIdUnit())
									oEtiqUnit:LoadData(1)
									//Altera endereço destino
									oMovAux:UpdEndDes(cEndDest,oEtiqUnit:GetIdUnit(),oEtiqUnit:GetTipUni())
								Else
									//Altera endereço destino
									oMovAux:UpdEndDes(cEndDest)
								EndIf
							EndIf
						EndIf
						If !lRet
							Exit
						EndIf
					Next
					If !lRet
						DisarmTransaction()
					EndIf
				End Transaction
				// Recarrega as informações do movimento
				oMovimento:LoadData()
			EndIf
		Else
			lRet := .F.
		EndIf
	EndIf
	// Favor nao alterar!!!
	// Eh obrigatorio q a funcao saia com este restarea ativo!!!
	VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
Return lRet
/*--------------------------------------------------------------------------------
---EndParcial
---Permitir dividir a quantidade a endereçar
---Alex Egydio - 23/11/2006
---cWmsUMI, character, (Unidade de medida)
----------------------------------------------------------------------------------*/
Static Function EndParcial(cWmsUMI)
Local aAreaAnt  := GetArea()
Local aTelaAnt  := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local lRet      := .F.
Local nQtdTotal := 0
Local nQtdLida  := 0
Local cPictQt   := ""
Local oRelacMov := WMSDTCRelacionamentoMovimentosServicoArmazem():New()
Local oMovNew   := WMSDTCMovimentosServicoArmazem():New()
Local cIdMovto  := ""

	nQtdTotal := Iif(cWmsUMI=='2',oMovimento:GetQtdMov2(),oMovimento:GetQtdMov())
	nQtdLida  := Iif(cWmsUMI=='2',oMovimento:GetQtdLid2(),oMovimento:GetQtdLid())
	cPictQt   := Iif(cWmsUMI=='2',PesqPict("D12","D12_QTDMO2"),PesqPict("D12","D12_QTDMOV"))

	If (nQtdTotal-nQtdLida) > 0 // Se endereçou tudo não há o que quebrar no movimento
		// Caso não informada a quantidade
		WMSVTCabec(oMovimento:oMovTarefa:GetDesTar(),.F.,.F.,.T.)
		@ 01, 00 VTSay PadR(STR0014, VTMaxCol()) // Quantidade
		@ 02, 00 VTSay PadR(STR0033, VTMaxCol()) // Total
		@ 03, 00 VTSay PadR(Transform(nQtdTotal,cPictQt), VTMaxCol())
		@ 04, 00 VTSay PadR(STR0034, VTMaxCol()) // Endereçada
		@ 05, 00 VTSay PadR(Transform(nQtdLida,cPictQt), VTMaxCol())
		WMSVTRodPe()

		If WMSVTAviso(WMSV08509,STR0021,{STR0005,STR0006})==1 // Endereçar atividade com quantidade parcial? // Sim // Nao
			// Verifica se o movimento não está aglutinado
			If 	oMovimento:GetAgluti() == "2"
				nQtdDif  := oMovimento:GetQtdMov() - oMovimento:GetQtdLid()
				nQtdDif2 := oMovimento:GetQtdMov2() - oMovimento:GetQtdLid2()
				cPriori  := oMovimento:GetPriori()
				cSeqPri  := oMovimento:GetSeqPrio()
				// Atualiza o D12 posicionado com a quantidade informada pelo operador.
				oMovimento:SetQtdMov(oMovimento:GetQtdLid())
				oMovimento:SetQtdMov2(oMovimento:GetQtdLid2())
				oMovimento:UpdateD12()
				// Atualiza quantidade da DCR
				oRelacMov:SetIdOrig(oMovimento:GetIdDCF())
				oRelacMov:SetIdDCF(oMovimento:oOrdServ:GetIdDCF())
				oRelacMov:SetSequen(oMovimento:oOrdServ:GetSequen())
				oRelacMov:SetIdMovto(oMovimento:GetIdMovto())
				oRelacMov:SetIdOpera(oMovimento:GetIdOpera())
				oRelacMov:LoadData()
				oRelacMov:SetQuant(oMovimento:GetQtdLid())
				oRelacMov:SetQuant2(oMovimento:GetQtdLid2())
				oRelacMov:UpdateDCR()
				// Cria novo D12 com o restante da quantidade para posterior convocacao pelo radio frequencia.
				oMovNew:oOrdServ:SetIdDCF(oMovimento:GetIdDCF())
				oMovNew:oOrdServ:LoadData()
				oMovNew:SetRadioF(oMovimento:GetRadioF())
				// Atribui dados servico
				oMovNew:oMovServic:SetServico(oMovimento:oMovServic:GetServico())
				oMovNew:oMovServic:SetOrdem(oMovimento:oMovServic:GetOrdem())
				oMovNew:oMovServic:LoadData()
				// Atribui dados Atividade
				oMovNew:oMovTarefa:SetTarefa(oMovimento:oMovTarefa:GetTarefa())
				oMovNew:oMovTarefa:SetOrdem(oMovimento:oMovTarefa:GetOrdem())
				oMovNew:oMovTarefa:LoadData()
				// Atribui dados Produto/Lote
				oMovNew:oMovPrdLot:SetPrdOri(oMovimento:oMovPrdLot:GetPrdOri())
				oMovNew:oMovPrdLot:SetProduto(oMovimento:oMovPrdLot:GetProduto())
				oMovNew:oMovPrdLot:SetLoteCtl(oMovimento:oMovPrdLot:GetLoteCtl())
				oMovNew:oMovPrdLot:SetNumLote(oMovimento:oMovPrdLot:GetNumLote())
				oMovNew:oMovPrdLot:SetNumSer(oMovimento:oMovPrdLot:GetNumSer())
				oMovNew:oMovPrdLot:LoadData()
				// Atribui dados endereço origem
				oMovNew:oMovEndOri:SetArmazem(oMovimento:oMovEndOri:GetArmazem())
				oMovNew:oMovEndOri:SetEnder(oMovimento:oMovEndOri:GetEnder())
				oMovNew:oMovEndOri:LoadData()
				// Atribui dados endereço destino
				oMovNew:oMovEndDes:SetArmazem(oMovimento:oMovEndDes:GetArmazem())
				oMovNew:oMovEndDes:SetEnder(oMovimento:oMovEndDes:GetEnder())
				oMovNew:oMovEndDes:LoadData()
				// Atribui dados gerais movimento serviço
				cIdMovto := GetSX8Num('D12', 'D12_IDMOV')
				ConfirmSx8()
				oMovNew:SetIdMovto(cIdMovto)
				oMovNew:SetQtdMov(nQtdDif)
				oMovNew:SetQtdMov2(nQtdDif2)
				oMovNew:SetPriori(cPriori)
				oMovNew:SetSeqPrio(cSeqPri)
				oMovNew:SetStatus("4")
				oMovNew:SetRhFunc(oMovimento:GetRhFunc())
				oMovNew:SetRecHum(oMovimento:GetRecHum())
				oMovNew:SetRecFis(oMovimento:GetRecFis())
				oMovNew:SetAtuEst(oMovimento:GetAtuEst())
				oMovNew:SetDataIni(CtoD(""))
				oMovNew:SetHoraIni("")
				oMovNew:SetDataFim(CtoD(""))
				oMovNew:SetHoraFim("")
				oMovNew:cOrdMov := oMovimento:cOrdMov
				// Atribui dados das atividades e cria as movimentações
				oMovNew:RecordD12()
				// Seta o D12 para ser convocado logo em seguida do movimento dividido
				//WMSConvD12(oMovNew:GetRecno())
				VTKeyBoard(Chr(27)) // Tecla ESC
				lRet := .T.
			Else
				WMSVTAviso(WMSV08515,STR0037) // Atividade está aglutinada, não permite movimentar parcial.
				lRet := .F.
			EndIf
		EndIf
	EndIf
	VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
	RestArea(aAreaAnt)
Return lRet
/*--------------------------------------------------------------------------------
---ValidaLote
---Permitir dividir a quantidade a endereçar
---Alexsande.Correa - 01/04/2015
---cLoteDig, Carater, (Lote digitado)
---cLoteCtl, Caracter, (Lote original)
----------------------------------------------------------------------------------*/
Static Function ValidaLote(cLoteDig,cLoteCtl)
Local lRet := .T.
	If	Empty(cLoteDig)
		lRet := .F.
	Else
		If	!(cLoteDig == cLoteCtl)
			WMSVTAviso(WMSV08516,WmsFmtMsg(STR0038,{{"[VAR01]",cLoteDig}})) // O Lote [VAR01] não consta no documento atual.
			VTKeyBoard(chr(20))
			lRet := .F.
		EndIf
	EndIf
Return(lRet)
/*--------------------------------------------------------------------------------
---ValSubLote
---Permitir dividir a quantidade a endereçar
---Alexsande.Correa - 01/04/2015
---cSLoteDig, Carater, (Sub-lote digitado)
---cSubLote, Caracter, (Sub-lote original)
----------------------------------------------------------------------------------*/
Static Function ValSubLote(cSLoteDig,cSubLote)
Local lRet := .T.
	If	Empty(cSLoteDig)
		lRet := .F.
	Else
		If	!(cSLoteDig == cSubLote)
			WMSVTAviso(WMSV08517,WmsFmtMsg(STR0039,{{"[VAR01]",cSLoteDig}})) // O Sub-Lote [VAR01] não consta no documento atual.
			VTKeyBoard(chr(20))
			lRet := .F.
		EndIf
	EndIf
Return(lRet)



/*/{Protheus.doc} QbrString
	quebra string do codigo de barras do produto
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
Static Function QbrString(nOpc,cString)

Local aDados := Separa(cString,"|")
Local cRet := {}
Local nTam := Len(cString)

If Len(aDados) > 0 .And. Len(aDados) >= nOpc
	cRet := aDados[nOpc]
Endif

cRet := Padr(cRet,nTam)

Return cRet


// -----------------------------------------------------------
/*/{Protheus.doc} WMSValProd
Verifica se o codigo do produto é válido
@author Flavio Vicco
@since 01/08/2005
@version 1.0
@param cPrdOri, character, (Produto origem)
@param cProduto, character, (Produto)
@param cLoteCtl, character, (Lote do produto)
@param cNumLote, character, (Sub-lote do lote do produto)
@param nQtde, numérico, (Quantidade do produto)
@param cCodBar, character, (Código de barras)
@param lChkVol, Indica se valida se é volume
@param aVolume, array que retorna as informações do volume
@param lTrocaPrd, lógico, utilizado para informar a função WMSValProd trocou de produto convocado (referencia)
/*/
// -----------------------------------------------------------
Static Function WMSValProd(cProdOri,cProduto,cLoteCtl,cNumLote,nQtde,cCodBar,lChkVol,aVolume,lTrocaPrd)
Local aArea     := GetArea()
Local lRet      := .T.
Local aProduto  := {}
Local cCgPd     := ""
Local cLtSub    := ""
Local nQtdD02   := 0
Local nQtdDCV   := 0
Local lWmsNew   := SuperGetMv("MV_WMSNEW",.F.,.F.)
Local cEndDes   := ""

Default lChkVol := .F.
Default aVolume := {}

	VTClearBuffer()
	// Deve zerar estas informações, pois pode haver informação de outra etiqueta
	cProduto := Space(TamSx3("B8_PRODUTO")[1])
	cLoteCtl := Space(TamSx3("B8_LOTECTL")[1])
	cEndDes  := IIf(lWmsNew,Space(TamSx3("D12_ENDDES")[1]),"")
	nQtde    := 0.00

	//Rodolfo - Ajuste para ler QRCODE DAXIA
	cProduto := PADR(QbrString(1,cCodBar),TamSx3("B8_PRODUTO")[1])
	cLoteCtl := PADR(QbrString(2,cCodBar),TamSx3("B8_LOTECTL")[1])
	nQtde 	 := 0 //Val(QbrString(3,cCodBar))
	cCodBar  := cProduto
	// Verifica se encontrou produto
	If Empty(cProduto)
		// Caso não verifique se é volume retorna erro
		If !lChkVol
			WMSVTAviso("WMSV00112","Etiqueta invalida!") // Etiqueta invalida!
			VTKeyBoard(Chr(20))
			lRet := .F.
		Else
			// Verifica se é volume
			dbSelectArea("DCU")
			DCU->(dbSetOrder(1))
			If DCU->(dbSeek(xFilial("DCU")+AllTrim(cCodBar))) // Verifica se o codigo informado existe na tabela DCU
				While DCU->(!Eof()) .And. AllTrim(DCU->DCU_CODVOL) == AllTrim(cCodBar)
					dbSelectArea("DCV")
					DCV->(dbSetOrder(1))
					DCV->(dbSeek(xFilial("DCV")+DCU->DCU_CODMNT+DCU->DCU_CODVOL))
					While DCV->(!Eof()) .And. DCV->(DCV_FILIAL+DCV->DCV_CODMNT+DCV->DCV_CODVOL) == xFilial("DCV")+ DCU->(DCU_CODMNT+DCU->DCU_CODVOL)
						nQtdDCV  := DCV->DCV_QUANT
						//
						If cProduto <> DCV->DCV_CODPRO .Or. DCV->(DCV_CARGA+DCV_PEDIDO) <> cCgPd .Or. DCV->(DCV_LOTE+DCV_SUBLOTE) <> cLtSub
							cProduto := DCV->DCV_CODPRO
							cCgPd    := DCV->(DCV_CARGA+DCV_PEDIDO)
							cLtSub   := DCV->(DCV_LOTE+DCV_SUBLOTE)
							// Verifica se todos os produtos informados no volume estao na conferencia D02
							dbSelectArea("D02")
							D02->(dbSetOrder(2))
							If D02->(dbSeek(xFilial("D02")+DCV->DCV_CARGA+DCV->DCV_PEDIDO+DCV->DCV_PRDORI+DCV->DCV_CODPRO+DCV->DCV_LOTE+DCV->DCV_SUBLOT))
								nQtdD02 := D02->D02_QTSEPA
								// Adiciona produto
								aAdd(aVolume,{cProduto,nQtdD02,nQtdDCV,DCV->DCV_CARGA,DCV->DCV_PEDIDO,DCV->DCV_LOTE,DCV->DCV_SUBLOTE,DCV->DCV_ITEM,DCV->DCV_SEQUEN,DCV->DCV_PRDORI,DCV->DCV_CODVOL})
							EndIf
						Else
							aVolume[Len(aVolume)][3] += nQtdDCV
						EndIf
						DCV->(dbSkip())
					EndDo
					DCU->(dbSkip())
				EndDo
			EndIf
			If Empty(aVolume)
				WMSVTAviso(WMSV00118,STR0036) // Etiqueta invalida!
				VTKeyBoard(Chr(20))
				lRet := .F.
			EndIf
		EndIf
	EndIf
	If lRet
		// Se o produto origem para comparação for informado, confirma se é o mesmo
		If !Empty(cProdOri)
			If (!Empty(cEndDes) .And. cEndDes == oMovimento:oMovEndDes:GetEnder() .And. cProduto == cProdOri)  .or. (Empty(cEndDes) .And. cProduto == cProdOri)
				lRet := .T.
				If ExistBlock("DLV030VL") // Executado para efetuar a validação do produto digitado
					lRetPE:= ExecBlock('DLV030VL',.F.,.F.,{cProduto})
					lRet  := If(ValType(lRetPE)=="L",lRetPE,lRet)
				EndIf
				If !lRet
					WMSVTAviso("Produto",WmsFmtMsg("não se encontra no documento atual.",{{"[VAR01]",cProduto}})) // Produto [VAR01] não se encontra no documento atual.
					VTKeyBoard(Chr(20))
				EndIf
			ElseIf lWmsNew
				// Se o produto for diferente do origem, verifica se o produto
				// pode ser considerado, trocando o produto caso positivo.
				// ----------
				// Passa os dados do CBRetEtiEAN para posicionar no produto correto.
				If oMovimento:oMovServic:GetUpdAti() $ ("2|3")
					If !SeekAtivid(cProduto,nQtde,cLoteCtl,cNumLote,Nil,cEndDes,@lTrocaPrd)
						lRet := .F.
					EndIf
				Else
					WMSVTAviso("Serviço",WmsFmtMsg("não permite troca de produto na convocação",{{"[VAR01]",oMovimento:oMovServic:GetServico()}})) // Serviço [VAR01] não permite troca de produto na convocação
					VTKeyBoard(Chr(20))
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf
	If !lRet
		cCodBar := Space(128)
	EndIf
	RestArea(aArea)
Return (lRet)
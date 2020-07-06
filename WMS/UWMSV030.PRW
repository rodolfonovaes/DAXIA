#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FIVEWIN.CH'
#INCLUDE 'WMSV030.CH'
#INCLUDE 'APVT100.CH'

#DEFINE WMSV03001 "WMSV03001"
#DEFINE WMSV03002 "WMSV03002"
#DEFINE WMSV03003 "WMSV03003"
#DEFINE WMSV03004 "WMSV03004"
#DEFINE WMSV03005 "WMSV03005"
#DEFINE WMSV03006 ""
#DEFINE WMSV03007 "WMSV03007"
#DEFINE WMSV03008 ""
#DEFINE WMSV03009 ""
#DEFINE WMSV03010 "WMSV03010"
#DEFINE WMSV03011 "WMSV03011"
#DEFINE WMSV03012 ""
#DEFINE WMSV03013 "WMSV03013"
#DEFINE WMSV03014 ""
#DEFINE WMSV03015 "WMSV03015"
#DEFINE WMSV03016 "WMSV03016"
#DEFINE WMSV03017 "WMSV03017"
#DEFINE WMSV03018 "WMSV03018"
#DEFINE WMSV03019 ""
#DEFINE WMSV03020 ""
#DEFINE WMSV03021 ""
#DEFINE WMSV03022 "WMSV03022"
#DEFINE WMSV03023 "WMSV03023"
#DEFINE WMSV03024 "WMSV03024"
#DEFINE WMSV03025 "WMSV03025"
#DEFINE WMSV03026 ""
#DEFINE WMSV03027 ""
#DEFINE WMSV03028 ""
#DEFINE WMSV03029 ""
#DEFINE WMSV03030 "WMSV03030"
#DEFINE WMSV03031 "WMSV03031"
#DEFINE WMSV03032 ""
#DEFINE WMSV03033 ""
#DEFINE WMSV03034 ""
#DEFINE WMSV03035 "WMSV03035"
#DEFINE WMSV03036 "WMSV03036"
#DEFINE WMSV03037 "WMSV03037"
#DEFINE WMSV03038 "WMSV03038"
#DEFINE WMSV03039 "WMSV03039"
//-------------------------------------------------------------
/*/{Protheus.doc} WMSV030
Apanhe / Abastecimento de mercadorias
@author Fernando Joly Siquini
@since 18/09/2001
@version 1.0
/*/
//-------------------------------------------------------------
Static lDV030EN1 := ExistBlock("DV030EN1") // Utilizado para confirmar o endereço de origem
Static lDV030CO1 := ExistBlock("DV030CO1") // Executado após informado o endereço origem, válido ou não
Static lDV030CON := ExistBlock("DV030CON") // Executado após a confirmação do endereço origem válido
Static lDV030CO3 := ExistBlock("DV030CO3") // Executado antes do inicio da atividade, permite validação
Static lDV030DOC := ExistBlock("DV030DOC") // Executado antes da solicitação do endereço da atividade
Static lDV030ENO := ExistBlock("DV030ENO") // Executado para definir o endereço origem
Static lDV030END := ExistBlock("DV030END") // Executado para definir o endereço destino
Static lDV030DES := ExistBlock("DV030DES") // Executado para substituir a tela padrão de endereço destino
Static lDV030SDB := ExistBlock("DV030SDB") // Executado após a alteração da situação na tabela D12
Static lDV030CO6 := ExistBlock("DV030CO6") // Executado após a informação da quantidade, antes da validação
Static lDV030CO4 := ExistBlock("DV030CO4")
Static lDV030SEP := ExistBlock("DV030SEP")
Static lDV030LOT := ExistBlock("DV030LOT") // Utilizado para tratar o número do lote na validação do mesmo
Static lDV030EST := ExistBlock("DV030EST") // Executado para indicar se deve ou não movimentar estoque
Static lDLGV040  := ExistBlock("DLGV040")
Static lDLVENDER := ExistBlock("DLVENDER")
Static lWMSQMSEP := ExistBlock("WMSQMSEP")

User Function UWMSV030()
Local aAreaAnt  := GetArea()
Local aSavKey   := VTKeys() // Salva todas as teclas de atalho anteriores
Local lRet      := .T.
Local cArmazem  := ""
Local cEndereco := ""
Local cConfirma := ""
Local cIdUnit   := ""
// Apresenta a descrição detalhada do endereço nas telas de coletor RF
Local lWmsApan  := SuperGetMV('MV_WMSAPAN',.F.,.T.)
Local lRetPE    := .T.
Local aRetPE    := {.F.}
Local cRetPE    := ""
Local nQtdTot   := 0
Local lNorma    := .T.
Local lPrimAtiv := ""
Local lUltiAtiv := ""
Local lMultAtiv := .F. // Multiplas atividades solicitando se deseja realizar outra atividade
Local lMultApan := .F. // Multiplas atividades automatica desde que menor que a norma
Local lAtPerMul := .T. // Indica se a atividade permite multiplos movimentos
Local cMsg      := ""
Local cPriSepara  	:= SuperGetMV('ES_SERVDIS',.T.,'019',cFilAnt)
Local cSegSepara	:= SuperGetMV('ES_SERVSEP',.T.,'025',cFilAnt)

Private lCtrlFOk  := .F.
Private oEstEnder := WMSDTCEstoqueEndereco():New()

	U_WAltSts(.F.)
	If /*cPriSepara <> oMovimento:oMovServic:GetServico() .And.*/ U_WEndDEs() // RODOLFO - Ajuste para não sair quando for pegar o proximo apanhe
		// Deve descarregar as atividades pendentes
		lRet := DesMulAtiv(@cArmazem,@cEndereco,@cIdUnit)
		// Restaura as teclas de atalho anteriores
		VTKeys(aSavKey)
		RestArea(aAreaAnt)
		Return lRet
	EndIf

	lPrimAtiv := oMovimento:IsPriAtiv()
	lUltiAtiv := oMovimento:IsUltAtiv()
	// Define regras para solicitar o dispositivo de movimentacao

	// Atribui a Funcao de INFORMACAO DA CARGA a Combinacao de Teclas <CTRL> + <G>
	VTSetKey(7,{|| WMSInfo()},STR0023) // Ctrl+G // Info.Carga"

	// Verifica se a atividade nesta ordem permite multiplos movimentos
	lAtPerMul := oMovimento:oMovTarefa:ChkPerMult()
	// Visualizar a unitizacao da carga
	If lDLGV040
		ExecBlock('DLGV040',.F.,.F.,{oMovimento:oOrdServ:GetCarga()})
	EndIf

	DbSelectArea('D12')
	D12->(DbSetOrder(5)) // D12_FILIAL+D12_DOC+D12_SERIE+D12_CLIFOR+D12_LOJA+DB_SERIVC+D12_TAREFA

	If lDV030CO3
		lRetPE:= ExecBlock('DV030CO3', .F., .F., {oMovimento:oMovPrdLot:GetProduto()})
		lRet  := If(ValType(lRetPE)=="L",lRetPE,lRet)
	EndIf

	If lRet
		If lDV030DOC
			ExecBlock('DV030DOC', .F., .F., {oMovimento:oMovServic:GetFuncao()})
		EndIf
		If oMovimento:oMovServic:ChkSepara()
			// Analise o armazem origem para determinar se a norma foi atingida quan possui multiplos apanhes
			cArmazem  := oMovimento:oMovEndOri:GetArmazem()
			// Verifica a quantidade do movimento para verificar se não é maior ou igual a uma norma
			If oMovimento:oMovServic:GetMltAti() == "1" // Quando possui multiplas atividades automatica até a norma
				lNorma := (oMovimento:GetQtdMov() >= DLQtdNorma(oMovimento:oMovPrdLot:GetProduto(),cArmazem,oMovimento:oMovEndOri:GetEstFis(),,.F.))
			EndIf
		EndIf
		If (oMovimento:GetQtdMov() - oMovimento:GetQtdLid()) > 0
			// Direciona RH para o Endereco Origem
			// Quando não é a primeira atividade analisa qual solicitação de endereço
			// 0=Origem/Destino
			// 1=Origem/Origem
			// 2=Destino/Destino
			If !lPrimAtiv .And. oMovimento:oMovTarefa:GetSolEnd() == "2"
				cArmazem  := oMovimento:oMovEndDes:GetArmazem()
				cEndereco := oMovimento:oMovEndDes:GetEnder()
				cIdUnit   := oMovimento:GetUniDes()
			Else
				cArmazem  := oMovimento:oMovEndOri:GetArmazem()
				cEndereco := oMovimento:oMovEndOri:GetEnder()
				cIdUnit   := oMovimento:GetIdUnit()
			EndIf
			If lDV030ENO
				cRetPE    := ExecBlock("DV030ENO", .F., .F.)
				cEndereco := Iif(ValType(cRetPE)=="C",cRetPE,cEndereco)
			EndIf
			// Verifica se o movimento anterior é do mesmo endereço origem e não solicita novamente
			If (Alltrim(cAntEndOri) != AllTrim(oMovimento:oMovEndOri:GetEnder()))
				// Solicita endereco origem se parametrizado.
				If lWmsApan
					Do While lRet .And. U_WOpcESC() == 0 .And. !U_WEndDes()
						WMSEnder(00, 00, cEndereco, cArmazem,,,STR0003) // Va para o Endereco
						If (VTLastKey()==27)
							WmsCtrlESC()
							Loop
						EndIf
						Exit
					EndDo
				EndIf

				// Confirma Endereco
				//Do While lRet .And. U_WOpcESC() == 0 .And. (!U_WEndDes() .Or. cPriSepara == oMovimento:oMovServic:GetServico() .Or. cSegSepara == oMovimento:oMovServic:GetServico()) // ajuste para passar
				Do While lRet .And. U_WOpcESC() == 0 .And. !U_WEndDes()
					cConfirma := Space(Len(cEndereco))
					// Direciona RH para o Endereco Origem
					If lDV030EN1
					//	cRetPE    := ExecBlock("DV030EN1", .F., .F.,{cEndereco})
					//	cConfirma := Iif(ValType(cRetPE)=="C",cRetPE,cConfirma)
					EndIf
					WMSVTCabec(STR0003,.F.,.F.,.T.)   // Va para o Endereco
					@ 01, 00 VTSay PadR(STR0080, VTMaxCol()) // Armazem
					@ 02, 00 VTSay PadR(cArmazem, VTMaxCol())
					@ 03, 00 VTSay PadR(STR0007, VTMaxCol()) // Endereco
					@ 04, 00 VTSay PadR(cEndereco, VTMaxCol())
					@ 05, 00 VTSay PadR(STR0008, VTMaxCol()) // Confirme !
					@ 06, 00 VTGet cConfirma Pict '@!' Valid ValEndereco(@cConfirma, cEndereco,cArmazem)
					VTRead
					If (VTLastKey()==27)
						WmsCtrlESC()
						Loop
					EndIf

					// Execblock no WHILE da confirmacao do endereco
					If lDV030CO1
						lRetPE:= ExecBlock('DV030CO1', .F., .F., {oMovimento:oMovPrdLot:GetProduto(), cEndereco, lRet})
						lRet  := Iif(ValType(lRetPE)=="L",lRetPE,lRet)
					EndIf
					cAntEndOri := oMovimento:oMovEndOri:GetEnder()
					Exit
				EndDo
			EndIf
			// Se não pulou ou bloqueou a atividade, nem escolheu descarregar, processa a atividade
			If lRet .And. U_WOpcESC() == 0 .And. !U_WEndDes()
				// Execblock apos a confirmacao do endereco
				If lRet .And. lDV030CON
					aRetPE := ExecBlock('DV030CON')
					If ValType(aRetPE) != 'A'
						aRetPE := {.F.}
					EndIf
				EndIf
				// Solicita código do unitizador quando for unitizador completo
				If lRet
					// Carrega quantidade sempre na primeira unidade
					// Retorna unidade de medida e quantidade saldo convertida
					nQtdTot := oMovimento:GetQtdMov() - oMovimento:GetQtdLid()
					// Solicita quantidade lida.
					lRet := RequestUM(nQtdTot,lPrimAtiv,lUltiAtiv,.T.,.F.,1)
				EndIf
			EndIf
		Else
			cMsg := WmsFmtMsg(STR0041,{{"[VAR01]",AllTrim(oMovimento:oMovPrdLot:GetProduto())}})+" "
			If !Empty(oMovimento:oMovPrdLot:GetLoteCtl())
				cMsg += WmsFmtMsg(STR0057,{{"[VAR01]",AllTrim(oMovimento:oMovPrdLot:GetLoteCtl())}})+" "
			EndIf
			cMsg += WmsFmtMsg(STR0058,{{"[VAR01]",Str(oMovimento:GetQtdMov())}})
			WMSVTAviso(WMSV03018,cMsg) // Produto [VAR01] // Lote [VAR01] // == qtd [VAR01] já coletado. Faltando apenas finalizar atividade.
		EndIf

		If lRet
			// Se quer bloquear a atividade atual ou todas as outras
			If U_WOpcESC() == 1 .Or. U_WOpcESC() == 2
				oMovimento:SetStatus("2")
				oMovimento:SetPrAuto("1") // Permite reinicio automático
				oMovimento:SetDataFim(dDataBase)
				oMovimento:SetHoraFim(Time())
				oMovimento:UpdateD12()
				// Ponto de entrada para manipular o status da D12
		//		If lDV030SDB
		//			ExecBlock("DV030SDB",.F.,.F.,{lCtrlFOk})
		//		EndIf
			// Se quer pular apenas esta atividade ou descarregar as outras
			ElseIf U_WOpcESC() == 3 .Or. U_WEndDes()
				If U_WOpcESC() == 3
					WMSAltPri() // Altera a prioridade da atividade atual
				EndIf
				oMovimento:SetStatus("4")
				oMovimento:UpdateD12()
				// Ponto de entrada para manipular o status da D12
		//		If lDV030SDB
		//			ExecBlock("DV030SDB",.F.,.F.,{lCtrlFOk})
		//		EndIf
			EndIf
			// Se não pulou ou bloqueou a atividade, nem escolheu descarregar, coloca a mesma na pilha
			// Caso tenha pressionado CTRL-R e cancelado a quantidade toda não leva para o destino
			If U_WOpcESC() == 0 .And. !U_WEndDes() .And. QtdComp(oMovimento:GetQtdMov()) > 0
				// Endereco de destino
				If lPrimAtiv .And. !lUltiAtiv .And. oMovimento:oMovTarefa:GetSolEnd() == "1"
					cArmazem  := oMovimento:oMovEndOri:GetArmazem()
					cEndereco := oMovimento:oMovEndOri:GetEnder()
					cIdUnit   := oMovimento:GetIdUnit()
				Else
					cArmazem  := oMovimento:oMovEndDes:GetArmazem()
					cEndereco := oMovimento:oMovEndDes:GetEnder()
					cIdUnit   := oMovimento:GetUniDes()
				EndIf
				If lDV030END
					cRetPE    := ExecBlock('DV030END', .F., .F.)
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
		EndIf
	EndIf

	// Se deu erro, bloqueia a atividade atual
	If !lRet
		oMovimento:SetStatus("2")
		oMovimento:SetPrAuto("1") // Permite reinicio automático
		oMovimento:SetDataFim(dDataBase)
		oMovimento:SetHoraFim(Time())
		oMovimento:UpdateD12()
		// Ponto de entrada para manipular o status da D12
	//	If lDV030SDB
	//		ExecBlock("DV030SDB",.F.,.F.,{lCtrlFOk})
	//	EndIf
	EndIf
	lRet := .T.

	// Se não escolheu levar para o destino, deve verificar se existem outras atividades
	If (U_WOpcESC() == 0 .Or. U_WOpcESC() == 2 .Or. U_WOpcESC() == 3) .And. !U_WEndDes()
		// Verifica se tem mais registro com o mesmo tarefa
		// Quando o serviço realiza multiplas atividades, se é automatica até a norma (lMultApan)
		// ou se pergunta se deseja realizar mais atividades simultaneamente (lMultAtiv)
		If oMovimento:oMovServic:GetMltAti() == "2" .And. lAtPerMul
			If WMSMultAti(oMovimento:GetRecno()) // D12->(Recno()))
				lMultAtiv := .T.
			EndIf
		Else
			// Se o que está separando não é uma norma deve verificar se existe um outro registro
			// no D12 que atenda a quantidade e possa ser separado colocando o mesmo na lista
			If !lNorma .And. oMovimento:oMovServic:GetMltAti() == "1" .And. lAtPerMul
				If U_MultApn(oMovimento:GetRecno()) // D12->(Recno())) //Rodolfo - Ajuste para chamar a função do WMSV001U
					lMultApan := .T.
				EndIf
				// Independente se é multiplo apanhe ou não, deve colocar o endereço no Array
				If AScan(oMovimento:GetArrConf(),{|x|x[1]+x[2]==cArmazem+cEndereco})==0 .And.  U_WOpcESC() == 0
					AAdd(oMovimento:GetArrConf(),{cArmazem,cEndereco})
				EndIf
			EndIf
		EndIf
	EndIf
	// Limpa as opções do ESC quando tratar apenas da atividade atual
	If U_WOpcESC() == 2 .Or. U_WOpcESC() == 3
		U_WOpcESC(0)
	EndIf
	// Se está ativado o multi-tarefa e não vai selecionar uma próxima tarefa OU
	// Se está ativado o RFENDDE e não tem mais atividades do documento
	If U_WOpcESC() == 0 .And. !lMultAtiv .And. !lMultApan .And. Len(oMovimento:GetArrCol()) > 0
		// Passa por referencia o armazém e endereço por causa da tecla de atalho <CTRL> + <E>
		If Len(oMovimento:GetArrCol()) > 1 .Or. U_WEndDes()
			lRet := DesMulAtiv(@cArmazem,@cEndereco,@cIdUnit)
		Else
			lRet := DesUmaAtiv(@cArmazem,@cEndereco,lPrimAtiv,lUltiAtiv)
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
		// Ponto de entrada para manipular o status da D12
	//	If lDV030SDB
	//		ExecBlock("DV030SDB",.F.,.F.,{lCtrlFOk})
	//	EndIf
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
---ValidPrdLot
---Valida o produto informado é valido
---Jackson Patrick Werka - 01/04/2015
---cProdOri, character, (Produto origem)
---cProduto, character, (Produto informado)
---cLoteCtl, character, (Lote etiqueta)
---cSubLote, character, (Sub-lote etiqueta)
---nQtde, numerico, (Quantidade etiqueta)
---nQtdTot, numerico, (Quantidade total)
---cCodBar, character, (Codigo de barras)
----------------------------------------------------------------------------------*/
Static Function ValidPrdLot(cProdOri,cProduto,cLoteCtl,cSubLote,nQtde,nQtdTot,cCodBar,lTrocaPrd)
Local lRet      := .T.
Local aRetPE    := {}
Local cCodBarBkp	:= ''
	lRet := !Empty(cCodBar)

	If lRet //Rodolfo - Ajuste para ler QRCODE DAXIA
		cProduto := Alltrim(QbrString(1,cCodBar))
		cLoteCtl := Alltrim(QbrString(2,cCodBar))
		nQtde 	 := Val(QbrString(3,cCodBar))
		cCodBarBkp := cCodBar
		cCodBar	 := cProduto
	EndIf

	If lRet .And. ExistBlock("DV030PRD") // Executado na validação do produto para retornar as informações
		aRetPE := ExecBlock('DV030PRD',.F.,.F.,{cCodBar})
		If ValType(aRetPE)=="A" .And. Len(aRetPE)==4
			cProduto := Padr(aRetPE[1],TamSx3("D12_PRODUT")[1])
			cLoteCtl := Padr(aRetPE[2],TamSx3("D12_LOTECT")[1])
			cSubLote := Padr(aRetPE[4],TamSx3("D12_NUMLOT")[1])
			nQtde    := aRetPE[3]
			nQtdTot  := aRetPE[3]
		EndIf
	EndIf
	If lRet
		// Passa o cPrdoOri em branco para validar se o produto informado existe no documento atual
		lRet := WMSValProd(cProdOri,@cProduto,@cLoteCtl,@cSubLote,@nQtde,@cCodBar,,,@lTrocaPrd)
		If lRet 
			_cLote := Padr(Alltrim(QbrString(2,cCodBarBkp)),TamSx3("D12_LOTECT")[1])
			_nQuant := Val(QbrString(3,cCodBarBkp))
		EndIf
	EndIf
Return(lRet)
/*--------------------------------------------------------------------------------
---RequestUM
---Solicita a quantidade quando MV_WMSUMI igual a 3
---Alex Egydio - 17/02/2005
---nQtdTot, numerico, (Quantidade digitada)
---lPrimAtiv, Logico, (Indica se é a primeira atividade)
---lUltiAtiv, Logico, (Indica se é a ultima atividade)
---lAtzQtdLid, Logico, (Indica se atualiza a quantidade lida)
---lConEndPrd, Logico, (Indica se confirma o produto no endereço destino, utilizado nas multiplas atividades)
---nTipo, numérico, (1=Origem;2=Destino, unilizado para o unitizador)
----------------------------------------------------------------------------------*/
Static Function RequestUM(nQtdTot,lPrimAtiv,lUltiAtiv,lAtzQtdLid,lConEndPrd,nTipo)
Local nItem     := 0
Local cUM       := ""
Local cPictQt   := ""
Local cLoteCtl  := ""
Local cSubLote  := ""
Local cProduto  := ""
Local cCliLoja  := ""
Local lRet      := .T.
Local lEncerra  := .F.
Local nProxLin  := 0
Local cCodEtq   := ""
Local cEtqAnt   := ""
Local nQtde     := 0
Local nQtdNorma := 0
Local nQtdItem  := 0
Local cWmsUMI   := ""
Local nInfLote  := 0 // Esta variável controla a troca de lote, só pode na 1ª vez
Local lWmsLote  := SuperGetMV('MV_WMSLOTE',.F.,.F.) // Solicita a confirmacao do lote nas operacoes com RF
Local lWmsApan  := SuperGetMV('MV_WMSAPAN',.F.,.T.) // Apresenta a descrição detalhada do endereço nas telas de coletor RF
Local lWmsFSep  := SuperGetMV('MV_WMSFSEP',.F.,.F.) // Finaliza Separac. / Reabast. RF
Local nToler    := SuperGetMV('MV_WMSQSEP',.F., 0 ) // Percentual de tolerancia Qtde a maior Separac. / Reabast. RF quando maior que zero
Local aRetPE    := Nil
Local lGrvLid   := .F.
Local cCodBar   := ""
Local lTrocaPrd := .F.
Local lMntPrd   := .F.
Private _cLote	:= ''
Private _nQuant	:= 0
Default lConEndPrd := .F.

	If lPrimAtiv .And. lWmsFSep .And. lAtzQtdLid
		// Atribui funcao para encerrar separacao/reabast. com qtde a menor a combinacao de teclas <CTRL> + <R>
		VTSetKey( 18,{||(lEncerra:=AlteraQtd(.F.,cWmsUMI))},STR0030) // Ctrl+R // Finalizar
	EndIf

	While U_WOpcESC() == 0 .And. (!U_WEndDes() .Or. lConEndPrd)
		If nQtdTot <= 0
			VtBeep(3)
			Exit
		EndIf

		If !lMntPrd
			// Carrega unidade de medida, simbolo da unidade e quantidade na unidade
			WmsValUM(@nQtdTot,;                              // Quantidade movimento
						@cWmsUMI,;                            // Unidade parametrizada
						oMovimento:oMovPrdLot:GetProduto(),;  // Produto
						oMovimento:oMovEndOri:GetArmazem(),;  // Armazem
						oMovimento:oMovEndOri:GetEnder())     // Endereço
			// Monta tela produto
			WmsMontPrd(cWmsUMI,;                            // Unidade parametrizada
						.F.,;                                 // Indica se é uma conferência
						oMovimento:oMovTarefa:GetDesTar(),;   // Descrição da tarefa
						oMovimento:oMovEndOri:GetArmazem(),;  // Armazem
						oMovimento:oMovEndOri:GetEnder(),;    // Endereço
						oMovimento:oMovPrdLot:GetPrdOri(),;   // Produto Origem
						oMovimento:oMovPrdLot:GetProduto(),;  // Produto
						oMovimento:oMovPrdLot:GetLoteCtl(),;  // Lote
						oMovimento:oMovPrdLot:GetNumLote(),;  // Sub-lote
						oMovimento:GetIdUnit())               // Id Unitizador
			// Quando utilizada tecla AlteraQtd
			If lEncerra
				lCtrlFOk := .T.
				Exit
			EndIf

			If (VTLastKey()==27)
				WmsCtrlESC(!lAtzQtdLid .Or. (nInfLote>0))
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
				oMovimento:oMovEndOri:GetArmazem(),;  // Armazem
				oMovimento:oMovEndOri:GetEnder(),;    // Endereço
				oMovimento:oMovPrdLot:GetPrdOri(),;   // Produto Origem
				oMovimento:oMovPrdLot:GetProduto(),;  // Produto
				oMovimento:oMovPrdLot:GetLoteCtl(),;  // Lote
				oMovimento:oMovPrdLot:GetNumLote())   // sub-lote
		// Quando utilizada tecla AlteraQtd
		If lEncerra
			lCtrlFOk := .T.
			Exit
		EndIf

		If (VTLastKey()==27)
			WmsCtrlESC(!lAtzQtdLid .Or. (nInfLote>0))
			Loop
		EndIf

		If nItem <= 0
			Loop
		EndIf
		// Quando o movimento possui código do produto e código do unitizador informado,
		// caracteriza uma movimentação de unitizador parcial
		If !Empty(oMovimento:GetIdUnit())
			// Requisita a confirmação do código do unitizador
			lRet := RequestUni(.F.,nTipo)

			If lEncerra
				Exit
			EndIf
			If VTLastKey()==27
				WmsCtrlESC(!lAtzQtdLid)
				Loop
			EndIf
		EndIf
		// Leitura da etiqueta avulsa qd o produto for a granel
		If oMovimento:oMovServic:ChkSepara()
			// Produto a granel
			// O conteudo de B5_TIPUNIT indica se o produto e a granel ou nao.
			// Se o conteudo for igual a zero o produto eh a granel.
			// Solicita a leitura da etiqueta avulsa
			If UsaCB0('01') .And. !CBProdUnit(oMovimento:oMovPrdLot:GetProduto())
				aTelaAnt := VTSave(00, 00, VTMaxRow(), VTMaxCol())
				cEtqAnt := cCodEtq
				cCodEtq := Space(10)
				WMSVTCabec(oMovimento:oMovTarefa:GetDesTar(),.F.,.F.,.T.)
				@ 02, 00 VTSay PadR(STR0049, VTMaxCol()) // Etiqueta'
				@ 03, 00 VTGet cCodEtq Pict '@!' Valid WmsVldEtq(cCodEtq) When VTLASTKEY()==05 .Or. Empty(cCodEtq)
				VTRead
				If (VTLastKey() == 27)
					cCodEtq := cEtqAnt
				Else
					lRet:=.T.
				EndIf
				VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
			EndIf
		EndIf
		//            1
		//  01234567890123456789
		//---0 _______Apanhe_______
		//---1 Pegue o Produto
		//---2 PA1
		//---3 PA1
		//---4 Lote
		//---5 AUTO000636
		//---6 Qtde 240 UM
		//---7     240.00
		// Mantém os dados do produto após a troca, pois passou pelo CBRetEti e CBRetEtiEAN
		cCodBar     := Iif(!lTrocaPrd,Space(128),cCodBar)
		cProduto    := Iif(!lTrocaPrd,PadR("",TamSx3("D12_PRODUT")[1]),cProduto)
		cLoteCtl    := Iif(!lTrocaPrd,PadR("",TamSx3("D12_LOTECT")[1]),cLoteCtl)
		cSubLote    := Iif(!lTrocaPrd,PadR("",TamSx3("D12_NUMLOT")[1]),cSubLote)
		nQtde       := Iif(!lTrocaPrd,0,nQtde)
		lTrocaPrd   := .F.
		cLoteOri    := oMovimento:oMovPrdLot:GetLoteCtl()
		cSubLoteOri := oMovimento:oMovPrdLot:GetNumLote()
		WMSVTCabec(oMovimento:oMovTarefa:GetDesTar(),.F.,.F.,.T.)
		nProxLin := 1
		@ nProxLin++, 00 VTSay PadR(STR0009, VTMaxCol()) // Pegue o Produto
		@ nProxLin++, 00 VTSay oMovimento:oMovPrdLot:GetProdCol()
		@ nProxLin++, 00 VTSay PadR(SubStr(Posicione('SB1',1,xFilial('SB1')+oMovimento:oMovPrdLot:GetProdCol() ,'B1_DESC' ),1,VTMaxCol()),VTMaxCol())// RODOLFO - Descrição do produto
		@ nProxLin++, 00 VTGet cCodBar Picture PesqPict("D12","D12_PRODUT") When Empty(cCodBar) Valid ValidPrdLot(oMovimento:oMovPrdLot:GetProduto(),@cProduto,@cLoteCtl,@cSubLote,@nQtde,@nQtdTot,@cCodBar,@lTrocaPrd)
		VTRead()
		// Quando utilizada tecla AlteraQtd
		If lEncerra
			lCtrlFOk := .T.
			Exit
		EndIf
		If (VTLastKey()==27)
			WmsCtrlESC(!lAtzQtdLid .Or. (nInfLote>0))
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

		// Habilita a escolha do código do volume
		// Quando a montagem de volume for "1", durante a separação
		If lUltiAtiv .And. oMovimento:ChkMntVol("1")
			If oMovimento:ValMntExc()
				// Ctrl+V
				VTSetKey(22,{|| MntVolume()},STR0059) // Volume
				If Empty(cVolume) .Or. !(Alltrim(cCliLoja) == Alltrim(oMovimento:oOrdServ:GetClifor()+oMovimento:oOrdServ:GetLoja()))
					MntVolume()
					cCliLoja := oMovimento:oOrdServ:GetClifor()+oMovimento:oOrdServ:GetLoja()
				EndIf
			Else
				WMSVTAviso(WMSV03035,WmsFmtMsg(STR0070,{{"[VAR01]",oMovimento:oMovServic:GetServico()}}))  // Serviço [VAR01] possui montagem de volume durante a separação e movimento aglutinado viola a regra de montagem exclusiva. Montagem de volume deverá ser manual e posterior a separação.
			EndIf
		EndIf

		//Rodolfo
		cLoteCtl := _cLote
		//nQtde	 := nQtdItem

		If lWmsLote .And. oMovimento:oMovPrdLot:HasRastro()
			@ nProxLin,00 VTSay PadR(STR0018,VTMaxCol()) // Lote
			@ nProxLin++,06 VTGet cLoteCtl Picture PesqPict("D12","D12_LOTECT") When /*VTLastKey()==05 .Or. Empty(cLoteCtl)*/ Valid ValidaLote(@cLoteCtl,@cLoteOri,@cSubLoteOri,@nQtdTot,(!lAtzQtdLid .Or. (nInfLote>0)),@cWmsUMI,@nItem,nProxLin)
		EndIf
		// Se tiver espaço na tela suficiente ele mostra o sub-lote na mesma tela
		If lWmsLote .And. oMovimento:oMovPrdLot:HasRastSub()
			@ nProxLin,00 VTSay PadR(STR0027,VTMaxCol()) // Sub-Lote
			@ nProxLin++,10 VTGet cSubLote Picture PesqPict('D12','D12_NUMLOT') When VTLastKey()==05 .Or. Empty(cSubLote) Valid ValSubLote(cSubLote,cSubLoteOri)
		EndIf
		@ nProxLin++, 00 VTSay PadR('Qtd'+' '+AllTrim(Str(nQtdItem))+' '+cUM, VTMaxCol()) // Qtde
		@ nProxLin++, 00 VTGet nQtde Picture cPictQt When /*VTLastKey()==05 .Or. Empty(nQtde)*/ Valid !Empty(nQtde)

		VTKeyBoard(Chr(13)) //-- Tecla ENTER
		
		VTRead()
		// Quando utilizada tecla AlteraQtd
		If lEncerra
			lCtrlFOk := .T.
			Exit
		EndIf
		If (VTLastKey()==27)
			WmsCtrlESC(!lAtzQtdLid .Or. (nInfLote>0))
			Loop
		EndIf
		//-- Processar validacoes quando etiqueta = Produto/Lote/Sub-Lote/Qtde
		If !(Iif(Empty(cLoteCtl),.T.,ValidaLote(cLoteCtl,cLoteOri,,(!lAtzQtdLid .Or. (nInfLote>0))))) .Or. ;
			!(Iif(Empty(cSubLote),.T.,ValSubLote(cSubLote,cSubLoteOri)))
			lRet := .F.
			Loop
		EndIf
		// Já informou o lote
		// Deve fazer assim, pois não pode permitir alterar na segunda vez que o usuário
		// informar uma outra quantidade, pois o apanhe pode ser feito parcial
		nInfLote++

		If !(cWmsUMI == '2') // Se não está na 2a UM deve converter para a 1a UM
			// Converter de U.M.I. p/ 1a.UM
			If nItem == 1
				nQtdNorma:= DLQtdNorma(oMovimento:oMovPrdLot:GetProduto(),oMovimento:oMovEndOri:GetArmazem(),oMovimento:oMovEndOri:GetEstFis(),,.F.)
				nQtde    := (nQtde*nQtdNorma)
			// Converter de 2a.UM p/ 1a.UM
			ElseIf nItem == 2
				nQtde := ConvUm(oMovimento:oMovPrdLot:GetProduto(),0,nQtde,1)
			EndIf
		EndIf

		If lDV030CO6
			aRetPE := ExecBlock('DV030CO6',.F.,.F.,{nQtdTot, nQtde})
			If ValType(aRetPE) == 'A'
				nQtdTot := aRetPE[1]
			EndIf
		EndIf
		lGrvLid := .T.
		If QtdComp(nQtdTot - nQtde) < 0
			If nToler <= 0 .And. !lWMSQMSEP
				WMSVTAviso(WMSV03030,STR0061) // Não possui percentual de tolerancia de separação a maior cadastrado.
				lGrvLid := .F.
			ElseIf !lPrimAtiv
				WMSVTAviso(WMSV03031,STR0062) // Somente na primeira atividade poderá ser separado uma quantidade maior que a solicitada.
				lGrvLid := .F.
			ElseIf !AlteraQtd(.T.,cWmsUMI,Iif(cWmsUMI=='2',ConvUm(oMovimento:oMovPrdLot:GetProduto(),0,((nQtdTot- nQtde)*(-1)),1),((nQtdTot- nQtde)*(-1))))
				lGrvLid := .F.
			EndIf
			If !lGrvLid
				nInfLote--
			Else
				nQtdTot -= nQtde
			EndIf
		Else
			// Desconta quantidade lida
			nQtdTot -= nQtde
		EndIf
		If lRet .And. lGrvLid .And. lAtzQtdLid // Quando está sendo chamado da descarga multi-tarefa não pode atualizar
			// Grava etiqueta avulsa
			If lPrimAtiv
				// Produto a granel grava etiqueta avulsa
				If !Empty(cCodEtq) .And. nQtde > 0
					CBGrvEti('01',{oMovimento:oMovPrdLot:GetProduto(),nQtde,oMovimento:oMovPrdLot:GetRecHum(),,,,,,oMovimento:oMovEndOri:GetEnder(),oMovimento:oMovEndOri:GetArmazem(),,oMovimento:GetNumSeq(),,,,oMovimento:oMovPrdLot:GetLoteCtl(),oMovimento:oMovPrdLot:GetNumLote(),,,,oMovimento:GetUnitiz(),,oMovimento:oMovPrdLot:GetNumSer(),oMovimento:GetOrigem()},cCodEtq)
				EndIf
			EndIf
			// Grava quantidade montagem
			// Quando a montagem de volume for "1", durante a separação
			If lUltiAtiv .And. oMovimento:ChkMntVol("1") .And. oMovimento:ValMntExc()
				If !WmsV081VlV(cVolume,oMovimento:oOrdServ:GetCarga(),oMovimento:oOrdServ:GetDocto(),oMovimento:oMovEndDes:GetArmazem(),oMovimento:oMovEndDes:GetEnder())
					MntVolume()
				EndIf
				lRet := oMovimento:UpdMntVol(Iif(cWmsUMI == '2',ConvUm(oMovimento:oMovPrdLot:GetProduto(),0,nQtde,1),nQtde),cVolume)
			EndIf
			// Grava a quantidade lida para o movimento
			oMovimento:SetQtdLid(oMovimento:GetQtdLid() + Iif(cWmsUMI == '2',ConvUm(oMovimento:oMovPrdLot:GetProduto(),0,nQtde,1),nQtde))
			oMovimento:UpdateD12()
		EndIf
	EndDo
	VTSetKey(18) // Ctrl+F
	VTSetKey(22) // Ctrl+V
Return (lRet)
/*--------------------------------------------------------------------------------
---WmsVldEtq
---Valida a etiqueta.
---Alex Egydio - 04/12/2007
---cCodEtq, character, (Código da etiqueta)
---lHelp, Logico, (Indica se mostra help)
----------------------------------------------------------------------------------*/
Static Function WmsVldEtq(cCodEtq,lHelp)
Local aAreaAnt := GetArea()
Local lRet     := Empty(CBRetEti(cCodEtq,'01'))

Default lHelp  := .T.

	If !lRet .And. lHelp
		WMSVTAviso(WMSV03022,STR0050) // Etiqueta ja informada!
		VTKeyBoard(chr(20))
	EndIf

	RestArea(aAreaAnt)
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
Static Function DesUmaAtiv(cArmazem,cEndereco,lPrimAtiv,lUltiAtiv)
Local aAreaAnt  := GetArea()
Local lRet      := .T.
	lRet := RequestEnd(cArmazem,cEndereco)
	If lRet
		lRet := RequestUni(.F.,2)
	EndIf
	If lRet
		// Força a releitura da situação do D12
		lRet := FinalAtiv(lUltiAtiv,Len(oMovimento:GetArrCol()))
	EndIf
	If U_WEndDes()
		oMovimento:IniArrConf()
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
Local nQtdTot   := 0
Local nCntEnd   := 0
Local nCntMov   := 0
Local aEndDest  := {}
Local cProduto  := ''
Local cLoteCtl  := ''
Local cSubLote  := ''
Local cEndAnt   := ''
Local lRet      := .T.
Local lPrimAtiv := .F.
Local lUltiAtiv := .F.
Local lEfetDesc := .F.
Local lWmsDaEn  := SuperGetMV("MV_WMSDAEN",.F.,.F.) // Descarga apenas considerando o endereço sem o armazém

	If oMovimento:oMovServic:GetMltAti() == "2"
		If Len(oMovimento:GetArrCol()) > 1
			aEndDest := oMovimento:OrdColetor()
		Else
			aEndDest := AClone(oMovimento:GetArrCol())
		EndIf
	Else
		aEndDest := AClone(oMovimento:GetArrConf())
		If lWmsDaEn
			ASort(aEndDest,,,{|x,y| x[1]+x[2]<y[1]+y[2]})
		EndIf
	EndIf

	For nCntEnd := 1 To Len(aEndDest)
		If oMovimento:oMovServic:GetMltAti() == "2"
			cArmazem  := aEndDest[nCntEnd,3]
			cEndereco := aEndDest[nCntEnd,5]
			cProduto  := aEndDest[nCntEnd,6]
			cLoteCtl  := aEndDest[nCntEnd,7]
			cSubLote  := aEndDest[nCntEnd,8]
			cIdUnit   := aEndDest[nCntEnd,16]
		Else
			cArmazem  := aEndDest[nCntEnd,1]
			cEndereco := aEndDest[nCntEnd,2]
		EndIf

		If lWmsDaEn
			If !(cEndereco == cEndAnt)
				lRet := RequestEnd(cArmazem,cEndereco)
				cEndAnt := cEndereco
			EndIf
		Else
			lRet := RequestEnd(cArmazem,cEndereco)
		EndIf
		
		// Deve pesquisar se tem mais algum registro indicando outro produto
		If lRet .And. oMovimento:oMovServic:GetMltAti() == "2"
			If Len(aEndDest) > 1
				oMovimento:GoToD12(aEndDest[nCntEnd,1])
				lPrimAtiv := aEndDest[nCntEnd,14]
				// Carrega quantidade sempre na primeira unidade
				// Retorna unidade de medida e quantidade saldo convertida
				nQtdTot := aEndDest[nCntEnd,9]
				// Solicita quantidade lida.
				lRet := RequestUM(nQtdTot,lPrimAtiv,lUltiAtiv,.F.,.T.,2)
			EndIf
		EndIf

		If lRet
			For nCntMov := Len(oMovimento:GetArrCol()) To 1 Step -1
				lUltiAtiv := oMovimento:GetArrCol()[nCntMov,15]
				lEfetDesc := .F.
				// Se a movimentação é para o mesmo endereço destino
				If oMovimento:oMovServic:GetMltAti() == "2"
					If oMovimento:GetArrCol()[nCntMov,3]+oMovimento:GetArrCol()[nCntMov,5]+oMovimento:GetArrCol()[nCntMov,6]+oMovimento:GetArrCol()[nCntMov,7]+oMovimento:GetArrCol()[nCntMov,8] == cArmazem+cEndereco+cProduto+cLoteCtl+cSubLote
						lEfetDesc := .T.
					EndIf
				Else
					If oMovimento:GetArrCol()[nCntMov,3]+oMovimento:GetArrCol()[nCntMov,5] == cArmazem+cEndereco
						lEfetDesc := .T.
					EndIf
				EndIf

				If lEfetDesc
					// Posiciona o registro de movimentação
					oMovimento:GoToD12(oMovimento:GetArrCol()[nCntMov,1])
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
	oMovimento:IniArrConf()
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

Default lUltiAtiv := .T.
Default lPosCol   := 1

	If lDV030EST
		lRetPE := ExecBlock("DV030EST",.F.,.F.)
		lAtuEst:= Iif(ValType(lRetPE)=="L",lRetPE,lAtuEst)
	EndIf

	If lRet := oMovimento:LockD12()
		If oMovimento:GetStatus() == "3" // Verifica se conseguiu travar registro
			Begin Transaction
				If lAtuEst .And. oMovimento:IsUpdEst()
					// Confirma o movimento de distribuicao atualizando o estoque.
					If oMovimento:IsUpdEst()
						WMSVTCabec(oMovimento:oMovTarefa:GetDesTar(),.F.,.F.,.T.)
						VTMsg(STR0022) // Processando...
						lRet := oMovimento:RecExit()
						If !lRet
							WMSVTAviso(WMSV03023,WmsFmtMsg(STR0014,{{"[VAR01]",oMovimento:oMovTarefa:GetDesTar()}}))  // Problemas no [VAR01]
						//Else // Rodolfo
						//	VldSegSep()// RODOLFO - valida se grava a segunda separação, antigo ponto de entrada DV030SDB
						EndIf
					EndIf
				EndIf
				If lRet
					// Atualiza o SDB para finalizado
					oMovimento:SetStatus("1")
					oMovimento:SetDataFim(dDataBase)
					oMovimento:SetHoraFim(Time())
					oMovimento:UpdateD12()
					// P.E. para manipular o status da D12
					If lDV030SDB
						ExecBlock("DV030SDB",.F.,.F.,{lCtrlFOk}) // ExecBlock("DV030D12",.F.,.F.,{lCtrlFOk})
					EndIf
				EndIf
				 // Retira do Array a movimentação, mesmo que não tenha movimentado
				If !Empty(oMovimento:GetArrCol())
					ADel(oMovimento:GetArrCol(),lPosCol) // Apaga do array o registro que ja foi movimentado
					ASize(oMovimento:GetArrCol(),Len(oMovimento:GetArrCol())-1)   // Exclui fisicamente o registro do array
				EndIf
				If !lRet
					DisarmTransaction()
				EndIf
			End Transaction
		EndIf

		oMovimento:UnLockD12()
	EndIf
	RestArea(aAreaAnt)
Return lRet
/*--------------------------------------------------------------------------------
---RequestEnd
---Vetor contendo o endereco de destino
---Alex Egydio - 12/05/2006
---cArmazem, Caracter, (Armazem)
---cEndereco, Caracter, (Endereço)
----------------------------------------------------------------------------------*/
Static Function RequestEnd(cArmazem,cEndereco)
Local aTelaAnt  := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local lWmsApan  := SuperGetMV('MV_WMSAPAN',.F.,.T.) // Apresenta a descrição detalhada do endereço nas telas de coletor RF
Local lRet      := .T.
Local lRetPE    := .F.
Local cRetPE    := ""
Local cConfirma := ""
Local cSegSepara  := SuperGetMV('ES_SERVSEP',.T.,'025',cFilAnt)

	// Ponto de entrada para elaborar a selecao do endereco de destino do apanhe.
	If lDV030DES
		lRetPE := ExecBlock('DV030DES',.F.,.F.)
		lRet   := Iif(ValType(lRetPE)=="L",lRetPE,lRet)
	Else
		If lWmsApan
			WMSEnder(00, 00, cEndereco, cArmazem,,,STR0013) // Leve para o Endereco

			If (VTLastKey()==27) .And. (WMSVTAviso(WMSV03001,WmsFmtMsg(STR0004,{{"[VAR01]",oMovimento:oMovTarefa:GetDesTar()}}),{STR0005,STR0006})==1)  // Deseja interromper o [VAR01]? // Sim // Nao
				U_WOpcESC(1) // Bloquear Todas Atividades
				lRet := .F.
			EndIf
		EndIf
		// Confirma Endereco
		If lRet
			Do While .T.
				If lDV030CO4
					cRetPE   := ExecBlock('DV030CO4', .F., .F., {cEndereco})
					cConfirma:= Iif(ValType(cRetPE)=="C",cRetPE,cEndereco)
				Else
					cConfirma := Space(Len(cEndereco))
				EndIf
				WMSVTCabec(STR0013,.F.,.F.,.T.)   // Leve para o Endereco
				@ 01, 00 VTSay PadR(STR0080, VTMaxCol()) // Armazem
				@ 02, 00 VTSay PadR(cArmazem, VTMaxCol())
				@ 03, 00 VTSay PadR(STR0007, VTMaxCol()) // Endereco
				@ 04, 00 VTSay PadR(cEndereco, VTMaxCol())
				@ 05, 00 VTSay PadR(STR0008, VTMaxCol()) // Confirme!
				@ 06, 00 VTGet cConfirma Pict '@!'  Valid ValEndereco(@cConfirma, cEndereco,cArmazem)
				VTRead
				If (VTLastKey()==27)
					If WMSVTAviso(WMSV03007,WmsFmtMsg(STR0004,{{"[VAR01]",oMovimento:oMovTarefa:GetDesTar()}}),{STR0005,STR0006})==1 // Deseja interromper o [VAR01]? //---Sim // Nao
						U_WOpcESC(1) // Bloquear Todas Atividades
						lRet := .F.
					Else
						Loop
					EndIf
				EndIf
				Exit
			EndDo
			//If oMovimento:oMovServic:GetServico() <> cSegSepara //Rodolfo
				U_WEndDes(.T.) // Sinaliza para a convocação que levou para o destino
			//EndIf
		EndIf
	EndIf

	VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
Return lRet
/*--------------------------------------------------------------------------------
---ValEndereco
---Valida o codigo do endereco
---Alex Egydio - 20/09/2001
---cConfirma, Caracter, (Endereço digitado)
---cEndereco, Caracter, (Endereço sugerido pelo sistema)
----------------------------------------------------------------------------------*/
Static Function ValEndereco(cConfirma, cEndereco,cArmazem)
Local lRet := .T.
Local cSrv		:= SuperGetMV('ES_SERVDIS',.T.,'019',cFilAnt)
Local cSegSepara	 := SuperGetMV('ES_SERVSEP',.T.,'025',cFilAnt)
Default cArmazem := '01'

	If Empty(cConfirma)
		lRet := .F.
	Else
		//Rodolfo - Ajuste para pegar o BE_XID
		SBE->(DbSetOrder(11))
		If SBE->(DbSeek(xFilial('SBE') + cArmazem + cConfirma))
			//cEndereco := SBE->BE_LOCALIZ
			cConfirma := SBE->BE_LOCALIZ
		EndIf

		If(oMovimento:oMovServic:GetServico() == cSrv .Or. oMovimento:oMovServic:GetServico() == cSegSepara) .And. Alltrim(cConfirma) <> Alltrim(cEndereco)
			//WMSVTAviso(WMSV03024,STR0019) // Endereco Incorreto
			//VTKeyBoard(chr(20))		
			lRet := .F.
		EndIf

		lRet := (AllTrim(cConfirma)==Alltrim(cEndereco))

		If !lRet
			WMSVTAviso(WMSV03024,STR0019) // Endereco Incorreto
			VTKeyBoard(chr(20))
		EndIf
	EndIf
Return lRet
/*--------------------------------------------------------------------------------
---RequestUni
---Solicita o código do unitizador
---Amanda Rosa Vieira - 23/05/2017
---lShowUnit - Mostra ou não o unitizador a ser pego
---nTipo - 1=Unitizador Origem;2=Unitizador Destino
----------------------------------------------------------------------------------*/
Static Function RequestUni(lShowUnit,nTipo)
Local aTelaAnt  := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local lRet      := .T.
Local cIdUnit   := ""
Local cConfirma := ""
Local lRequest  := .T.
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
			Do While lRet .And. U_WOpcESC() == 0 .And. !U_WEndDes()
				WMSVTCabec(STR0071, .F., .F., .T.)   // Pegue o Unitizador
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
		// 0 ___Separação___
		// 1
		// 2 Unitizador
		// 3 000006
		// 4 Confirme
		// 5 000006
		// 6
		// 7
		// Solicita confirmacao do Unitizador
		Do While lRet .And. U_WOpcESC() == 0 .And. !U_WEndDes()
			cConfirma := Space(Len(cIdUnit))
			WMSVTCabec(oMovimento:oMovTarefa:GetDesTar(),.F.,.F.,.T.)
			@ 02, 00 VTSay PadR(STR0072, VTMaxCol())  // Unitizador
			@ 03, 00 VTSay PadR(cIdUnit, VTMaxCol())
			@ 05, 00 VTSay PadR(STR0008, VTMaxCol())  // Confirme!
			@ 06, 00 VTGet cConfirma Pict '@!' Valid WMSValUnit(cConfirma, cIdUnit)
			VTRead()
			If (VTLastKey()==27)
				WmsCtrlESC()
				Loop
			EndIf
			Exit
		EndDo
	EndIf
	VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
Return lRet

/*--------------------------------------------------------------------------------
---WMSInfo
---Informacoes ref. ao docto. <Ctrl+G>
---Flavio Luiz Vicco - 04/10/2006
----------------------------------------------------------------------------------*/
Static Function WMSInfo()
Local aAreaAnt  := GetArea()
Local aTelaAnt  := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local lWmsCarga := WmsCarga(oMovimento:oOrdServ:GetCarga())
Local cCarga    := ""
Local cPedido   := ""
Local cCliente  := ""
Local cLoja     := ""
Local cVarVolum := ""
Local cIdUnit   := ""
Local cNReduz   := ""

	Do Case
		Case oMovimento:oOrdServ:GetOrigem() $ "SC9"
			cVarVolum := cVolume                         // Volume.: [VAR01]
			cIdUnit   := oMovimento:GetIdUnit()          // Unitiz.: [VAR01]
			cCarga    := oMovimento:oOrdServ:GetCarga()  // Carga..: [VAR01]
			cPedido   := oMovimento:oOrdServ:GetDocto()  // Pedido.: [VAR01]
			cCliente  := oMovimento:oOrdServ:GetCliFor() // Cliente: [VAR01]
			cLoja     := oMovimento:oOrdServ:GetLoja()   // Loja...: [VAR01]
			cNReduz   := Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja,"A1_NREDUZ") // NReduz.: [VAR01]
			cNReduz   := WmsFmtMsg(STR0069,{{"[VAR01]",cNReduz}})

			WMSVTAviso(oMovimento:oMovTarefa:GetDesTar(),;                                          //APANHE POR PRODUTO
			Iif(Empty(cVarVolum),"",Padr(WmsFmtMsg(STR0054,{{"[VAR01]",cVarVolum}}),VTMaxCol()) )+; //Volume.: 0000000001
			Iif(Empty(cIdUnit)  ,"",Padr(WmsFmtMsg(STR0026,{{"[VAR01]",cIdUnit}})  ,VTMaxCol()) )+; //Unitiz.: 000004
			Iif(Empty(cCarga)   ,"",Padr(WmsFmtMsg(STR0025,{{"[VAR01]",cCarga}})   ,VTMaxCol()) )+; //Carga..: 000001
			Iif(lWmsCarga       ,"",Padr(WmsFmtMsg(STR0037,{{"[VAR01]",cPedido}})  ,VTMaxCol()) )+; //Pedido.: 000002
			Iif(Empty(cCliente) ,"",Padr(WmsFmtMsg(STR0038,{{"[VAR01]",cCliente}}) ,VTMaxCol()) )+; //Cliente: 000003
			Iif(Empty(cLoja)    ,"",Padr(WmsFmtMsg(STR0068,{{"[VAR01]",cLoja}})    ,VTMaxCol()) )+; //Loja...: 01
			Iif(Empty(cNReduz)  ,"",SubStr(cNReduz,1,VTMaxCol()-1)                              )+; //NReduz.: CLIENTE
			Iif(Empty(cNReduz)  ,"",SubStr(cNReduz,VTMaxCol(),VTMaxCol()-1)                     ) ) //PADRAO
		OtherWise
			WMSVTAviso(oMovimento:oMovTarefa:GetDesTar(),; //WMSV03010,;
			Padr(WmsFmtMsg(STR0024,{{"[VAR01]",oMovimento:oOrdServ:GetDocto()}}),VTMaxCol())+; // Docto..: [VAR01]
			If(Empty(cVolume),"",Padr(WmsFmtMsg(STR0054,{{"[VAR01]",cVolume}}),VTMaxCol()) ))  // Volume.: [VAR01]
	EndCase
	VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
	RestArea(aAreaAnt)
Return Nil
/*--------------------------------------------------------------------------------
---AlteraQtd
---Atualiza O.S.WMS DCF com quantidade informada pelo operador. <Ctrl+F>
---Flavio Luiz Vicco - 04/10/2006
---lQtdMaior, Logico, (Indica se a quantidade é a maior)
---cWmsUMI, Caracter, (Unidade de medida)
---nQuant, Numerico, (Quantidade informada)
---lEncAtiv, Logico, (Indica se encerra atividade)
----------------------------------------------------------------------------------*/
Static Function AlteraQtd(lQtdMaior,cWmsUMI,nQuant)
Local aAreaAnt  := GetArea()
Local aTelaAnt  := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local lRet      := .T.
Local lRetPE    := Nil
Local nQtdMvto  := 0
Local nQtdOrig  := oMovimento:GetQtdMov()

Default nQuant  := 0
	// Valida se permite alterar a quantidade 
	If !WmsVpaMov(oMovimento,lQtdMaior,nQuant)
		WMSVTAviso(WMSV03025,oMovimento:GetErro())
		lRet := .F.
	EndIf
	If lRet
		nQtdMvto := Iif(lQtdMaior,oMovimento:GetQtdMov()+nQuant,oMovimento:GetQtdLid())
		WMSVTCabec(oMovimento:oMovTarefa:GetDesTar(), .F., .F., .T.)
		@ 01, 00 VTSay PadR(STR0010, VTMaxCol()) // Quantidade
		@ 02, 00 VTSay PadR(STR0031, VTMaxCol()) // Total"
		// Apresenta para o usuário, as quantidades na segunda medida
		If ( cWmsUMI== "2" )
			@ 03, 00 VTSay PadR(Transform(oMovimento:GetQtdMov2(),PesqPict("D12","D12_QTDMO2")), VTMaxCol())
			@ 04, 00 VTSay PadR(STR0032, VTMaxCol()) // Separada
			@ 05, 00 VTSay PadR(Transform(ConvUm(oMovimento:oMovPrdLot:GetProduto(),nQtdMvto,0,2), PesqPict("D12","D12_QTDMO2")), VTMaxCol())
		Else
			@ 03, 00 VTSay PadR(Transform(oMovimento:GetQtdMov(),PesqPict("D12","D12_QTDMOV")), VTMaxCol())
			@ 04, 00 VTSay PadR(STR0032, VTMaxCol()) // Separada
			@ 05, 00 VTSay PadR(Transform(nQtdMvto, PesqPict("D12","D12_QTDMOV")), VTMaxCol())
		EndIf
		WMSVTRodPe()

		If WMSVTAviso(WMSV03015,Iif(lQtdMaior,STR0036,STR0033),{STR0005,STR0006})==1 // Separar quantidade superior? // Finalizar atividade com quantidade inferior? // Sim // Nao
			Begin Transaction
				lRet := WmsGrvDif(oMovimento,lQtdMaior,nQtdOrig,nQtdMvto)
				If !lRet
					DisarmTransaction()
				EndIf
			End Transaction
			If lRet .And. lDV030SEP
				lRetPE := Execblock("DV030SEP",.F.,.F.,{nQtdOrig,nQtdMvto})
				If ValType(lRetPE) == "L"
					lRet := lRetPE
				EndIf
			EndIf
			If lRet .And. !lQtdMaior
				VTKeyBoard(chr(27))
			EndIf
		Else
			lRet := .F.
		EndIf
	EndIf
	VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
	RestArea(aAreaAnt)
Return lRet
/*--------------------------------------------------------------------------------
---ValidaLote
---Verifica se o lote digitado na conferencia pertence ao lote do documento
---Flavio Luiz Vicco - 01/12/2009
---cLoteCtl, Caracter, (Lote digitado)
---cLoteOri, Caracter, (Lote do documento)
---nQtdTot, Numerico, (Quantidade total)
---lForceLote, Logico. (Indica se força o lote)
----------------------------------------------------------------------------------*/
Static Function ValidaLote(cLoteCtl,cLoteOri,cSubLoteOri,nQtdTot,lForceLote,cWmsUMI,nItem,nProxLin)
Local aTela     := VtSave()
Local aCab      := {STR0018,STR0027,STR0042} // Lote // Sub-Lote // Quant.
Local aLotes    := {{oMovimento:oMovPrdLot:GetLoteCtl(),oMovimento:oMovPrdLot:GetNumLote(),oMovimento:GetQtdMov(),oMovimento:GetRecno()}}
Local aSize     := {TamSx3("D12_LOTECT")[1],TamSx3("D12_NUMLOT")[1],TamSx3("D12_QTDMOV")[1]}
Local lRet      := .T.
Local cWMSALOT  := SuperGetMV('MV_WMSALOT',.F.,'1') // Permite Alterar nro lote separacao -RF-. 1=Nao / 2=Sim / 3=Confirmacao
Local cRetPE    := ""
Local cSubLote  := ""
Local nI        := 0
Default lForceLote := .F.
	// Não permite a troca de lote quando requisição de OP x WMS
	If oMovimento:oOrdServ:GetOrigem() != "SC9" 
		lForceLote := .T.
	EndIf
	// PE para tratar o numero do lote.
	If lDV030LOT
		cRetPE := ExecBlock("DV030LOT",.F.,.F.,{oMovimento:oMovPrdLot:GetProduto(),cLoteCtl})
		If ValType(cRetPE) == "C"
			cLoteCtl := cRetPE
		EndIf
	EndIf
	// Para produtos x componentes não é permitida a troca de lote.
	If !(oMovimento:IsPriAtiv()) .Or. (!(oMovimento:oMovPrdLot:GetPrdOri() == oMovimento:oMovPrdLot:GetProduto()) .And. !oMovimento:oMovServic:ChkSepara())
		cWMSALOT := "1"
	EndIf
	// Validação tratamento lote
	If cWMSALOT == "1" .Or. lForceLote
		If Empty(cLoteCtl)
			VTClear()
			WMSVTCabec(STR0043,.F.,.F.,.T.) // Lotes a separar
			VTaBrowse(1,0,VTMaxRow()-1,VTMaxCol(),aCab,aLotes,aSize)
			VtRestore(,,,,aTela)
			lRet := .F.
		ElseIf !(cLoteCtl == cLoteOri)
			WMSVTAviso(WMSV03003,WmsFmtMsg(STR0012,{{"[VAR01]",cLoteCtl}})) // Lote [VAR01] não consta no documento atual.
			VTKeyBoard(chr(20))
			lRet := .F.
		EndIf
	Else
		// Selecionar lotes a separar do mesmo endereço.
		If Empty(cLoteCtl)
			SelecLote(@cLoteCtl,@cLoteOri,@cSubLoteOri,@nQtdTot,@cWmsUMI,@nItem,nProxLin)
			lRet := .F.
		ElseIf !(cLoteCtl == cLoteOri)
			If !Empty(oMovimento:GetIdUnit())
				WMSVTAviso(WMSV03038,STR0077) // Não permitida a troca de lotes para movimentações com o unitizador informado. Solicite a alteração via monitor.
				lRet := .F.
			EndIf
			If lRet
				If !(lRet := WMSV030VTL(oMovimento,cLoteCtl,oMovimento:oMovPrdLot:GetNumLote(),""))
					WMSVTAviso(WMSV03039,oMovimento:GetErro())
				EndIf
			EndIf
			If lRet .And. (cWMSALOT == "2" .Or. (cWMSALOT == "3" .And. WMSVTAviso(WMSV03013,STR0034,{STR0005,STR0006})==1)) // Deseja alterar o lote? // Sim // Nao
				aSaldoEnd := oEstEnder:GetSldEnd(oMovimento:oMovPrdLot:GetPrdOri(),;
												oMovimento:oMovEndOri:GetArmazem(),;
												oMovimento:oMovEndOri:GetEnder(),;
												cLoteCtl,;
												Nil,;
												Nil,;
												Nil,;
												Nil,;
												oMovimento:oMovPrdLot:GetProduto(),;
												Nil)
				If Empty(aSaldoEnd)
					WMSVTAviso(WMSV03005,WmsFmtMsg(STR0015,{{"[VAR01]",cLoteCtl}})) // Lote [VAR01] sem saldo disponível.
					VTKeyBoard(chr(20))
					lRet := .F.
				ElseIf Len(aSaldoEnd) == 1 
					If QtdComp(aSaldoEnd[1,6]) < QtdComp(oMovimento:GetQtdMov())
						WMSVTAviso(WMSV03004,WmsFmtMsg(STR0015,{{"[VAR01]",cLoteCtl}})) // Lote [VAR01] sem saldo disponível.
						VTKeyBoard(chr(20))
						lRet := .F.
					Else
						cLoteOri := cLoteCtl
						cSubLote := aSaldoEnd[1,4] 
					EndIf
				Else
					aLotes := {}
					For nI := 1 To Len(aSaldoEnd)
						If QtdComp(aSaldoEnd[nI,6]) >= QtdComp(oMovimento:GetQtdMov())
							AAdd(aLotes,{aSaldoEnd[nI,3],aSaldoEnd[nI,4],aSaldoEnd[nI,6],,})
						EndIf
					Next nI
					If !Empty(aLotes)
						If Len(aLotes) > 1
							VTClear()
							WMSVTCabec(STR0043,.F.,.F.,.T.) // Lotes a separar
							nPos := VTaBrowse(1,0,VTMaxRow()-1,VTMaxCol(),aCab,aLotes,aSize)
							VtRestore(,,,,aTela)
							// Trocar lote selecionado.
							If nPos > 0
								cSubLote := aLotes[nPos,2]
							Else
								VTKeyBoard(chr(20))
								lRet := .F.
							EndIf
						Else
							cLoteOri := cLoteCtl
							cSubLote := aLotes[1,2]
						EndIf
					Else
						WMSVTAviso(WMSV03037,WmsFmtMsg(STR0075,{{"[VAR01]",cLoteCtl}})) // Lote [VAR01] sem saldo disponível nos sub-lotes.
						VTKeyBoard(chr(20))
						lRet := .F.
					EndIf
				EndIf
				If lRet
					cLoteOri    := cLoteCtl
					cSubLoteOri := cSubLote
					//Realiza operações para troca de lote
					Begin Transaction
						lRet := oMovimento:UpdLote(cLoteOri,cSubLoteOri)
						If !lRet
							DisarmTransaction()
						EndIf
					End Transaction
				EndIf
			Else
				VTKeyBoard(chr(20))
				lRet := .F.
			EndIf
		EndIf
	EndIf
Return(lRet)
/*--------------------------------------------------------------------------------
---ValSubLote
---Verifica se o Sub-Lote digitado pertence ao Sub-lote do documento
---Flavio Luiz Vicco - 01/12/2009
---cSubLote, Caracter, (Sub-lote digitado)
---cSubLoteOri, Caracter, (Sub-lote do documento)
----------------------------------------------------------------------------------*/
Static Function ValSubLote(cSubLote,cSubLoteOri)
Local lRet := .T.
	If Empty(cSubLote)
		lRet := .F.
	Else
		If !(cSubLote == cSubLoteOri)
			WMSVTAviso( WMSV03011,WmsFmtMsg(STR0028,{{"[VAR01]",cSubLote}}) ) // Sub-Lote [VAR01] nao consta no documento atual.
			VTKeyBoard(chr(20))
			lRet := .F.
		EndIf
	EndIf
Return(lRet)
/*--------------------------------------------------------------------------------
---SelecLote
---Permite selecionar lotes a separar do mesmo endereco.
---Flavio Luiz Vicco - 16/12/2009
---cLoteCtl, Caracter, (Lote digitado)
---cLoteOri, Caracter, (Lote do documento)
---nQtdTot, Numerico, (Quantidade total
----------------------------------------------------------------------------------*/
Static Function SelecLote(cLoteCtl,cLoteOri,cSubLoteOri,nQtdTot,cWmsUMI,nItem,nProxLin)
Local nTipoConv := SuperGetMV('MV_TPCONVO',.F., 1 ) // 1=Por Atividade/2=Por Tarefa
Local aLotes    := {{oMovimento:oMovPrdLot:GetLoteCtl(),oMovimento:oMovPrdLot:GetNumLote(),oMovimento:GetQtdMov(),oMovimento:oMovPrdLot:GetUM(),oMovimento:GetRecno()}}
Local aCab      := {STR0018,STR0027,STR0042,STR0076} // Lote //Sub-Lote // Quant.
Local aSize     := {TamSx3("D12_LOTECT")[1],TamSx3("D12_NUMLOT")[1],TamSx3("D12_QTDMOV")[1],TamSx3("B1_UM")[1]}
Local aTela     := VtSave()
Local dDataFec  := DToS(WmsData())
Local lRet      := .T.
Local nPos      := 0
Local cQuery    := ""
Local cAliasQry := GetNextAlias()
Local oMovAux2  := WMSDTCMovimentosServicoArmazem():New()
Local cUM       := ""

	cQuery := " SELECT D12.R_E_C_N_O_ D12RECNO"
	cQuery +=   " FROM " + RetSqlName('D12')+" D12"
	cQuery += " WHERE D12.D12_FILIAL   = '"+xFilial("D12")+"'"
	cQuery +=   " AND D12.D12_SERVIC  = '"+oMovimento:oMovServic:GetServico()+"'"
	cQuery +=   " AND D12.D12_DOC     = '"+oMovimento:oOrdServ:GetDocto()+"'"
	cQuery +=   " AND D12.D12_SERIE   = '"+oMovimento:oOrdServ:GetSerie()+"'"
	cQuery +=   " AND D12.D12_PRODUT  = '"+oMovimento:oMovPrdLot:GetProduto()+"'"
	cQuery +=   " AND D12.D12_ENDORI  = '"+oMovimento:oMovEndOri:GetEnder()+"'"
	cQuery +=   " AND D12.D12_TAREFA  = '"+oMovimento:oMovTarefa:GetTarefa()+"'"
	cQuery +=   " AND D12.D12_ATIVID  = '"+oMovimento:oMovTarefa:GetAtivid()+"'"
	cQuery +=   " AND D12.D12_ORDATI  = '"+oMovimento:oMovTarefa:GetOrdem()+"'"
	cQuery +=   " AND D12.D12_RHFUNC  = '"+oMovimento:GetRhFunc()+"'"
	cQuery +=   " AND D12.D12_RECFIS  = '"+oMovimento:GetRecFis()+"'"
	cQuery +=   " AND (D12.D12_RECHUM  = ' ' OR D12.D12_RECHUM = '"+__cUserID+"')"
	cQuery +=   " AND D12.D12_STATUS   = '4'"
	cQuery +=   " AND D12.R_E_C_N_O_ <> "+AllTrim(Str(oMovimento:GetRecno()))
	cQuery +=   " AND D12.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)

	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	While (cAliasQry)->(!Eof())
		// Posicionar no registro do D12
		oMovAux2:GoToD12( (cAliasQry)->D12RECNO )
		// Somente se nao for a ultima atividade
		If StaticCall(WMSV001,ChkExecAnt,oMovAux2,nTipoConv,dDataFec,__cUserID,.F.)
			AAdd(aLotes,{oMovAux2:oMovPrdLot:GetLoteCtl(),oMovAux2:oMovPrdLot:GetNumLote(),oMovAux2:GetQtdMov(),oMovimento:oMovPrdLot:GetUM(),oMovAux2:GetRecno()})
		EndIf
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())

	aSort(aLotes,,,{|x,y| x[1]<y[1]})
	VTClear()
	WMSVTCabec(STR0043,.F.,.F.,.T.) // Lotes a separar
	nPos := VTaBrowse(1,0,VTMaxRow()-1,VTMaxCol(),aCab,aLotes,aSize)
	VtRestore(,,,,aTela)
	// Trocar lote selecionado.
	If nPos > 0
		// Trocar atividade
		If oMovimento:GetRecno()<>aLotes[nPos,5]
			oMovAux2:GoToD12(oMovimento:GetRecno())
			If oMovAux2:LockD12()
				// Posicionar no registro do D12
				oMovimento:SetStatus("4")
				oMovimento:SetDataIni(CtoD(""))
				oMovimento:SetHoraIni("")
				oMovimento:UpdateD12(.F.)
				oMovimento:UnLockD12()
				// P.E. para manipular o status da D12
			//	If lDV030SDB
			//		Execblock("DV030SDB",.F.,.F.,{lCtrlFOk})
			//	EndIf
				// Posicionar no registro do D12
				oMovimento:GoToD12(aLotes[nPos,5])
				If oMovimento:LockD12() .And. oMovimento:GetStatus() == "4"
					oMovimento:SetStatus("3")
					oMovimento:SetRecHum(__cUserID)
					oMovimento:SetDataIni(dDataBase)
					oMovimento:SetHoraIni(Time())
					oMovimento:UpdateD12(.F.)
					// P.E. para manipular o status da D12
			//		If lDV030SDB
			//			Execblock("DV030SDB",.F.,.F.,{lCtrlFOk})
			//		EndIf
					cLoteOri    := oMovimento:oMovPrdLot:GetLoteCtl()
					cSubLoteOri := oMovimento:oMovPrdLot:GetNumLote()
					nQtdTot     := oMovimento:GetQtdMov()
					// Verifica se há sublote
					If Empty(cSubLoteOri)
						WMSVTAviso(WMSV03016,STR0039) // Numero do lote alterado.
					Else
						WMSVTAviso(WMSV03036,STR0074) // Numero do lote/sublote alterado.
					EndIf
					// Deve carregar novamente as informações da unidade de medida, pois nos casos em que estiver configurado para
					// utilizar a 2a UM e a primeira atividade for menor que 1, o sistema passou a considerar a 1a UM do produto.
					WmsValUM(@nQtdTot,;                              // Quantidade movimento
								@cWmsUMI,;                            // Unidade parametrizada
								oMovimento:oMovPrdLot:GetProduto(),;  // Produto
								oMovimento:oMovEndOri:GetArmazem(),;  // Armazem
								oMovimento:oMovEndOri:GetEnder())     // Endereço
					// Seleciona unidade de medida
					WmsSelUM(cWmsUMI,;                             // Unidade parametrizada
								@cUM,;                                // Unidade medida reduzida
								Nil,;                                 // Descrição unidade medida
								nQtdTot,;                             // Quantidade movimento
								@nItem,;                              // Item seleção unidade
								"",;                                  // Mascara unidade medida
								Nil,;                                 // Quantidade no item seleção unidade
								Nil,;                                 // Indica se é uma conferência
								oMovimento:oMovTarefa:GetDesTar(),;   // Descrição da tarefa
								oMovimento:oMovEndOri:GetArmazem(),;  // Armazem
								oMovimento:oMovEndOri:GetEnder(),;    // Endereço
								oMovimento:oMovPrdLot:GetPrdOri(),;   // Produto Origem
								oMovimento:oMovPrdLot:GetProduto(),;  // Produto
								oMovimento:oMovPrdLot:GetLoteCtl(),;  // Lote
								oMovimento:oMovPrdLot:GetNumLote())   // sub-lote
					// Atualiza as informações em tela de acordo com a unidade de medida
					@ nProxLin-2, 00 VTSay PadR('Qtd'+' '+AllTrim(Str(nQtdTot))+' '+cUM, VTMaxCol()) // Qtde
				Else
					WMSVTAviso(WMSV03002,STR0040) // Nao foi possivel efetuar a alteracao.
					lRet := .F.
				EndIf
			Else
				WMSVTAviso(WMSV03017,STR0040) // Nao foi possivel efetuar a alteracao.
				lRet := .F.
			EndIf
		EndIf
	Else
		lRet := .F.
	EndIf
Return(lRet)
/*--------------------------------------------------------------------------------
---MntVolume
---Solita codigo do volume
---Alexsande.Correa - 01/04/2015
----------------------------------------------------------------------------------*/
Static Function MntVolume()
Local aTelaAnt    := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local ckey22      := VTDescKey(22)
Local ckey18      := VTDescKey(18)
Local bkey22      := VTSetKey(22)
Local bkey18      := VTSetKey(18)
	VTSetKey(22,Nil) // Ctrl+V
	VTSetKey(18,Nil) // Ctrl+R

	cVolume := PadR(cVolume,TamSx3("DCV_CODVOL")[1])

	While U_WOpcESC() == 0 .And. !U_WEndDes()
		// 01234567890123456789
		// 0 ______Apanhe_______
		// 1 Informe o Volume
		// 2 V001
		WMSVTCabec(oMovimento:oMovTarefa:GetDesTar(),.F.,.F.,.T.)
		VTKeyBoard(chr(20))
		If Empty(cVolume)
			@ 02,00 VTSay PadR(STR0055, VTMaxCol()) // Informe o Volume
			@ 03,00 VTGet cVolume Picture "@!" Valid Iif(!Empty(cVolume),WmsV081VlV(cVolume,oMovimento:oOrdServ:GetCarga(),oMovimento:oOrdServ:GetDocto(),oMovimento:oMovEndDes:GetArmazem(),oMovimento:oMovEndDes:GetEnder()),.F.)
		Else
			@ 02,00 VTSay PadR(STR0056, VTMaxCol()) // Volume Atual
			@ 03,00 VTSay PadR(cVolume, VTMaxCol())
			@ 04,00 VTSay PadR(STR0055, VTMaxCol()) // Informe o Volume
			@ 05,00 VTGet cVolume Picture "@!" Valid Iif(!Empty(cVolume),WmsV081VlV(cVolume,oMovimento:oOrdServ:GetCarga(),oMovimento:oOrdServ:GetDocto(),oMovimento:oMovEndDes:GetArmazem(),oMovimento:oMovEndDes:GetEnder()),.F.)
		EndIf
		VTRead
		If (VTLastKey()==27)
			WmsCtrlESC()
			Loop
		EndIf
		Exit
	EndDo
	VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
	// Restaura Tecla
	VTSetKey(22,bkey22, ckey22)
	VTSetKey(18,bkey18, ckey18)
Return
//---------------------------------------------------------
/*/{Protheus.doc} WMSV030VTL
(long_description)
Função responsável por validar permissão para troca de 
lote.
@author amanda.vieira
@since 26/01/2018
@version 1.0
@param oMovimento, objeto, objeto do movimento
@param cNovoLote, caracter, Lote novo
@param cNovoSubLt, caracter, Sub-Lote novo
@param cNovoEnder, caracter, Endereço novo
/*/
//---------------------------------------------------------
Static Function WMSV030VTL(oMovimento,cNovoLote,cNovoSubLt,cNovoEnder)
Local lRet      := .T.
Local cQuery    := ""
Local cAliasSC6 := ""
Local lVldEnder := !Empty(cNovoEnder)
Default cNovoLote  := ""
Default cNovoSubLt := ""
Default cNovoEnder := ""

	//Valida se as informações de endereço, lote ou sub-lote já foi informado na criação do pedido
	cQuery := " SELECT SC6.C6_NUM,"
	cQuery +=        " SC6.C6_LOCALIZ,"
	cQuery +=        " SC6.C6_LOTECTL,"
	cQuery +=        " SC6.C6_NUMLOTE"
	cQuery +=   " FROM "+RetSqlName("DCR")+" DCR"
	cQuery +=  " INNER JOIN "+RetSqlName("SC9")+" SC9 "
	cQuery +=     " ON SC9.C9_FILIAL  = '"+xFilial("SC9")+"'"
	cQuery +=    " AND SC9.C9_IDDCF   = DCR.DCR_IDDCF"
	cQuery +=    " AND SC9.C9_LOTECTL = '"+oMovimento:oMovPrdLot:GetLoteCtl()+"' "
	cQuery +=    " AND SC9.C9_NUMLOTE = '"+oMovimento:oMovPrdLot:GetNumLote()+"' "
	cQuery +=    " AND SC9.C9_BLWMS   = '01'"
	cQuery +=    " AND SC9.D_E_L_E_T_ = ' '"
	cQuery +=  " INNER JOIN "+RetSqlName("SC6")+" SC6 "
	cQuery +=     " ON SC6.C6_FILIAL  = '"+xFilial("SC6")+"'"
	cQuery +=    " AND SC6.C6_NUM     = SC9.C9_PEDIDO"
	cQuery +=    " AND SC6.C6_ITEM    = SC9.C9_ITEM"
	cQuery +=    " AND SC6.C6_PRODUTO = SC9.C9_PRODUTO"
	cQuery +=    " AND (SC6.C6_LOTECTL  <> '"+Space(TamSX3("C6_LOTECTL")[1])+"'"
	cQuery +=         " OR SC6.C6_NUMLOTE  <> '"+Space(TamSX3("C6_NUMLOTE")[1])+"'"
	If lVldEnder
		cQuery +=     " OR SC6.C6_LOCALIZ <> '"+Space(TamSX3("C6_LOCALIZ")[1])+"'"
	EndIf
	cQuery += ")" 
	cQuery +=    " AND SC6.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE DCR.DCR_FILIAL = '"+xFilial("DCR")+"'"
	cQuery +=    " AND DCR.DCR_IDMOV  = '"+oMovimento:GetIdMovto()+"'"
	cQuery +=    " AND DCR.DCR_IDOPER = '"+oMovimento:GetIdOpera()+"'"
	cQuery +=    " AND DCR.DCR_IDORI  = '"+oMovimento:oOrdServ:GetIdDCF()+"'"
	cQuery +=    " AND DCR.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasSC6 := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSC6,.F.,.T.)
	While (cAliasSC6)->(!EoF()) .And. lRet
		If lVldEnder .And. !Empty((cAliasSC6)->C6_LOCALIZ) .And. !((cAliasSC6)->C6_LOCALIZ == cNovoEnder)
			oMovimento:SetErro(WmsFmtMsg(STR0078,{{"[VAR01]",AllTrim((cAliasSC6)->C6_NUM)}})) //O endereço origem do documento [VAR01] foi informado na inclusão do pedido de venda, não é permitida a alteração via WMS.
			lRet := .F.
		ElseIf (!Empty((cAliasSC6)->C6_LOTECTL) .And. !((cAliasSC6)->C6_LOTECTL == cNovoLote)) .Or. (!Empty((cAliasSC6)->C6_NUMLOTE) .And. !((cAliasSC6)->C6_NUMLOTE == cNovoSubLt))
			oMovimento:SetErro(WmsFmtMsg(STR0079,{{"[VAR01]",AllTrim((cAliasSC6)->C6_NUM)}})) //O lote/sub-lote do documento [VAR01] foi informado na inclusão do pedido de venda, não é permitida a alteração via WMS.
			lRet := .F.
		EndIf
		(cAliasSC6)->(DbSkip())
	EndDo
	(cAliasSC6)->(DbCloseArea())
Return lRet
// -----------------------------------------------------------
/*/{Protheus.doc} WMSMultApn
Verifica se existe mais alguma atividade a ser executada quando
o apanhe permite selecionar vários movimentos desde que não sejam
maior que a norma do produto, possibilitando ao usuário executar
diversas atividades sem ter a necessidade de finalizar a anterior.
@author Jackson Patrick Werka
@since 01/04/2015
@version 1.0
@param nRecnoD12, númerico, (recno da ordem de serviço WMS (D12))
/*/
// -----------------------------------------------------------
Static Function WMSMultApn(nRecnoD12)
Local aAreaD12  := D12->(GetArea())
Local aAreaAnt  := GetArea()
Local cAliasAtv := GetNextAlias()
Local cFuncao   := aParConv[1]
Local cRecHum   := aParConv[3]
Local cUsuArma  := aParConv[4]
Local cUsuZona  := aParConv[5]
Local nTipoConv := aParConv[6]
Local dDataFec  := aParConv[7]
Local cQuery    := ""
Local lConvoca  := .F.
Local lWmsDaEn  := SuperGetMV("MV_WMSDAEN",.F.,.F.) // Descarga apenas considerando o endereço sem o armazém

	cQuery := QryValAtCv(cRecHum,cFuncao,cUsuArma,nRecnoD12,lReinAuto,.T.,.T.)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasAtv,.F.,.T.)
	While (cAliasAtv)->(!Eof())
		// verifica se o registro do D12 ja foi executado pelo processo de multi-tarefas
		If AScan(oMovimento:GetArrCol(),{|x|x[1] == (cAliasAtv)->RECD12 }) > 0
			(cAliasAtv)->(DbSkip())
			Loop
		EndIf
		// Verificar se o endereço destino é o mesmo
		// Caso não seja irá procurar se existe outra atividade para o mesmo endereço
		// Obs.: Nessa quando os endereço de uma mesma carga ou documento irá pular
		//       desreitando a sequencia de convocação
		D12->(dbGoTo((cAliasAtv)->RECD12))
		If (IIf(lWmsDaEn,D12->D12_LOCDES,"")+D12->D12_ENDDES) <> ;
		   (IIf(lWmsDaEn,oMovimento:oMovEndDes:GetArmazem(),"")+oMovimento:oMovEndDes:GetEnder())
			(cAliasAtv)->(DbSkip())
			Loop
		EndIf
		// Não precisa avaliar as tabelas DC5 e DC6, pois deve ser a mesma atividade
		If !ChkAvalD12((cAliasAtv)->RECD12,cRecHum,cFuncao,cUsuArma,cUsuZona,nTipoConv,dDataFec)
			(cAliasAtv)->(DbSkip())
			Loop
		EndIf
		// Verifica se o D12 a ser convocado não é uma norma, neste caso força a descarga dos anteriores
		If QtdComp(oMovimento:GetQtdMov()) < QtdComp(DLQtdNorma(oMovimento:oMovPrdLot:GetProduto(),oMovimento:oMovEndOri:GetArmazem(),oMovimento:oMovEndOri:GetEstFis(),,.F.))
			WMSConvD12(oMovimento:GetRecno())
			lConvoca := .T.
		EndIf
		Exit
	EndDo
	(cAliasAtv)->(DbCloseArea())

	If !lConvoca
		// Retorno registro atual
		oMovimento:GoToD12(nRecnoD12)
	Else
		// Seta D12_STATUS para Servico em Execucao
		If U_WAltSts()
			oMovimento:SetRecHum(cRecHum)
			oMovimento:SetStatus("3")
			oMovimento:SetDataIni(dDataBase)
			oMovimento:SetHoraIni(Time())
			oMovimento:SetDataFim(CTOD(""))
			oMovimento:SetHoraFim("")
			oMovimento:UpdateD12()
		EndIf
	EndIf
	RestArea(aAreaAnt)
	RestArea(aAreaD12)
Return lConvoca


/*--------------------------------------------------------------------------------
---QryValAtCv
---Monta a Query que valida as atividades para convocação
---Jackson Patrick Werka - 01/04/2015
---cRecHum, caracter, (Recurso logado)
---cFuncao, caracter, (Função para analise de convocação)
---cUsuArma, caracter, (Armazem logado)
---nRecnoD12, númerico, (recno D12)
---lStBloq, logico, (Considera status bloqueado)
---lFiltraSer, logico
---lFiltraDoc, logico
---lFiltraPrd, logico (Considera dados da etiqueta bipada)
---cProduto, caracter, (Código do produto na etiqueta)
---nQtde, numerico, (Quantidade do produto na etiqueta)
---cLoteCtl, caracter, (Lote do produto na etiqueta)
---cNumLote, caracter, (Sub-Lote do produto na etiqueta)
---cEndDes, caracter, (Endreço destino)
---cUnitizDig, caracter, (Unitizador digitado na troca de atividade)
----------------------------------------------------------------------------------*/
Static Function QryValAtCv(cRecHum,cFuncao,cUsuArma,nRecnoD12,lStBloq,lFiltraSer,lFiltraDoc,lFiltraPrd,cProduto,nQtde,cLoteCtl,cNumLote,cNumSerie,cEndDes,cUnitizDig)
Local cRecHumVz := PadR("", TamSx3("D12_RECHUM")[1])
Local aAreaD12  := D12->(GetArea())
Local cQuery    := ""
Default lStBloq := .F.
Default lFiltraPrd := .F.
Default cProduto := ""
	D12->(dbGoTo(nRecnoD12))
	cQuery := "SELECT CASE"
	cQuery +=           " WHEN (D12.D12_STATUS = '3' AND D12.D12_RECHUM = '"+cRecHum+"' AND D12_QTDMOV <> D12_QTDLID) THEN 0"
	cQuery +=           " WHEN (D12.D12_STATUS = '2' AND D12.D12_RECHUM = '"+cRecHum+"')                              THEN 1"
	cQuery +=           " WHEN (D12.D12_STATUS = '4' AND D12.D12_RECHUM = '"+cRecHum+"')                              THEN 2"
	cQuery +=           " WHEN (D12.D12_STATUS = '3' AND D12.D12_RECHUM = '"+cRecHum+"' AND D12_QTDMOV = D12_QTDLID)  THEN 3"
	cQuery +=           " WHEN (D12.D12_STATUS = '4' AND D12.D12_RECHUM = '"+cRecHumVz+"')                            THEN 4"
	cQuery +=           " WHEN (D12.D12_STATUS = '3' AND D12.D12_RECHUM = '"+cRecHumVz+"')                            THEN 5"
	cQuery +=        " ELSE 99 "
	cQuery +=        " END AS ORDWMS,"
	cQuery +=        " D12.R_E_C_N_O_ RECD12"
	cQuery +=   " FROM " + RetSqlName('D12')+" D12 "
	cQuery +=  " WHERE D12.D12_FILIAL = '"+xFilial("D12")+"'"
	// Verifica a versao e o paramentro que permite reabrir tarefa paralizadas
	If lStBloq
		cQuery += " AND D12.D12_STATUS IN ('2','3','4')"
	Else
		cQuery += " AND D12.D12_STATUS IN ('3','4')"
	EndIf
	If lFiltraSer .And. !lFiltraPrd
		cQuery += " AND D12.D12_SERVIC = '"+D12->D12_SERVIC+"'"
		cQuery += " AND D12.D12_TAREFA = '"+D12->D12_TAREFA+"'"
		cQuery += " AND D12.D12_ATIVID = '"+D12->D12_ATIVID+"'"
		cQuery += " AND D12.D12_ORDTAR = '"+D12->D12_ORDTAR+"'"
		cQuery += " AND D12.D12_ORDATI = '"+D12->D12_ORDATI+"'"
	EndIf
	cQuery += " AND D12.D12_RHFUNC = '"+cFuncao+"'"
	If !Empty(cUsuArma)
		cQuery += " AND D12.D12_LOCORI = '"+cUsuArma+"'"
	EndIf
	If lFiltraDoc
		If WmsCarga(D12->D12_CARGA)
			cQuery +=  " AND D12.D12_CARGA = '"+D12->D12_CARGA+"'"
		Else
			cQuery +=  " AND D12.D12_DOC    = '"+D12->D12_DOC+"'"
			cQuery +=  " AND D12.D12_CLIFOR = '"+D12->D12_CLIFOR+"'"
			cQuery +=  " AND D12.D12_LOJA   = '"+D12->D12_LOJA+"'"
		EndIf
	EndIf
	// Condições utilizadas quando é informado um produto diferente do convocado, função SeekAtivid.
	If lFiltraPrd
		cQuery += " AND D12.D12_PRODUT = '"+cProduto+"'"
		// Filta por quantidade informada na etiqueta
		If !Empty(nQtde)
			cQuery += " AND D12.D12_QTDMOV >= "+cValtoChar(nQtde)
		EndIf
		// Filtra pelo lote infomado na etiqueta
		If !Empty(cLoteCtl)
			cQuery += " AND D12.D12_LOTECT = '"+cLoteCtl+"'"
		EndIf
		// Filtra pelo sub-lote infomado na etiqueta
		If !Empty(cNumLote)
			cQuery += " AND D12.D12_NUMLOT = '"+cNumLote+"'"
		EndIf
		// Filtra pelo numero de série
		If !Empty(cNumSerie)
			cQuery += " AND D12.D12_NUMSER = '"+cNumSerie+"'"
		EndIf
		cQuery += " AND D12.D12_ENDORI = '"+D12->D12_ENDORI+"'"
	EndIf
	cQuery += " AND D12.D12_RADIOF = '1'"
	If !Empty(cEndDes)
		cQuery += " AND D12.D12_ENDDES = '"+cEndDes+"'"
	EndIf
	If nRecnoD12 <> 0
		cQuery += " AND D12.R_E_C_N_O_ <> "+AllTrim(Str(nRecnoD12))
	EndIf
	If !Empty(cUnitizDig)
		cQuery += " AND D12.D12_IDUNIT = '"+cUnitizDig+"'"
	EndIf
	If ExistBlock('DLV001WH')
		cQuery += ExecBlock('DLV001WH',.F.,.F.,{cRecHum,cFuncao})
	EndIf
	cQuery += " AND D12.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY ORDWMS, "

	If ExistBlock('DLV001ORD')
		cQuery += ExecBlock('DLV001ORD', .F., .F., {1})
	Else
		cQuery += SqlOrder(D12->(IndexKey(1))) // D12_FILIAL+D12_STATUS+D12_PRIORI+D12_CARGA+D12_DOC+D12_SERIE+D12_CLIFOR+D12_LOJA+D12_SERVIC+D12_ORDTAR+D12_ORDATI
	EndIf
	cQuery := ChangeQuery(cQuery)
	RestArea(aAreaD12)
Return cQuery

/*--------------------------------------------------------------------------------
---ChkAvalD12
---Avalia se o D12 passado pode ser convocado para execução
---Jackson Patrick Werka - 01/04/2015
---nRecnoD12, numerico, (Recno da D12)
---cRecHum, Caracter, (Recurso humano)
---cFuncao, Caracter, (Função para analise da convocação)
---cUsuArma, Caracter, (Armazem logado)
---cUsuZona, Caracter, (Zona de armazenagem logada)
---nTipoConv, Numerico, (Tipo convocação)
---dDataFec, Date, (Data de fechamento)
----------------------------------------------------------------------------------*/
Static Function ChkAvalD12(nRecnoD12,cRecHum,cFuncao,cUsuArma,cUsuZona,nTipoConv,dDataFec)
Local aAreaAnt   := GetArea()
Local lRet       := .T.
Local lConvoca   := .F.
Local lNaoConv   := SuperGetMV("MV_WMSNREG", .F., .F.)
Local aRetPE     := {}
Local cNumero    := ""
Local cArmSBE    := ""
Local lPertenceZ := .F.
Local lWMSCOMP   := (SuperGetMV('MV_WMSCOMP', .F., 'F')=='T') // Se realiza a separação completa da carga ou pedido antes de permitir a convocacao de atividade reiniciada de outra carga.
Local lPrimAtiv  := .T.
Local lUltiAtiv  := .T.
Local cEndereco  := ""
Local cSegSepara  := SuperGetMV('ES_SERVSEP',.T.,'025',cFilAnt)
Default cRecHum   := __cUserID
Default cFuncao   := ""
Default cUsuArma  := ""
Default cUsuZona  := ""
Default nTipoConv := SuperGetMV("MV_TPCONVO", .F., 1) // 1=Por Atividade/2=Por Tarefa
Default dDataFec  := DtoS(WmsData())

	VTMsg(STR0069) // Analisando...
	// Posiciona o registro de movimentação
	If !oMovimento:GoToD12(nRecnoD12)
		lRet := .F.
	EndIf

	oMovimento:SetQuant(oMovimento:GetQtdMov())
	// Ignora movimentos cancelado e finalizados
	If lRet .And. oMovimento:GetStatus() $ "0|1"
		lRet := .F.
	EndIf
	// Valida bloqueio produto (B1_MSBLQL)
	If lRet .And. !oMovimento:IsMovUnit() .And. !WmsSB1Blq(oMovimento:oMovPrdLot:GetProduto())
		lRet := .F.
	EndIf
	// Não permite reiniciar movimentos sem recurso definido e que foram bloqueados
	If lRet .And. oMovimento:GetStatus() == "2" .And. oMovimento:GetPrAuto() == "2" .And. Empty(oMovimento:GetRecHum())
		lRet := .F.
	EndIf

	// Não deve convocar as atividades geradas a partir de um mapa de separação de quantidade fracionada,
	// pois se trata de um processo manual. Elas serão consideradas pelo programa WMSA360.
	If lRet .And. oMovimento:GetMapaTip() == "1"
		lRet := .F.
	EndIf

	// Ignora servicos jah atribuidos a outros usuarios
	If lRet .And. !Empty(oMovimento:GetRecHum()) .And. oMovimento:GetRecHum() <> cRecHum
		lRet := .F.
	EndIf
	// Se atividade já está atribuída ao usuário e a quantidade lida está igual a solicitada
	// e a situação da atividade está em andamento e possuiu outras atividades em andamento
	If lRet .And. ;
		oMovimento:GetRecHum() == cRecHum .And. ;
		oMovimento:GetStatus() == "3" .And. ;
		QtdComp(oMovimento:GetQtdMov()) <= QtdComp(oMovimento:GetQtdLid()) .And. ;
		oMovimento:HasUsrAtv(cRecHum,cFuncao,cUsuArma)
		lPrimAtiv := oMovimento:IsPriAtiv()
		lUltiAtiv := oMovimento:IsUltAtiv()
		// Solicita endereco destino
		If lPrimAtiv .And. !lUltiAtiv .And.  oMovimento:oMovTarefa:GetSolEnd() == "1"
			cEndereco := oMovimento:oMovEndOri:GetEnder()
		Else
			cEndereco := oMovimento:oMovEndDes:GetEnder()
		EndIf
		AAdd(oMovimento:GetArrCol(),{oMovimento:GetRecno(),;
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
		// Independente se é multiplo apanhe ou não, deve colocar o endereço no Array
		If AScan(oMovimento:GetArrConf(),{|x|x[1]+x[2]==oMovimento:oMovEndOri:GetArmazem()+cEndereco})==0
			AAdd(oMovimento:GetArrConf(),{oMovimento:oMovEndOri:GetArmazem(),cEndereco})
		EndIf
		lRet := .F.
	EndIf

	// Verifica se há pendencias da ultima tarefa lida para permitir ser realiza uma atividade anterior reiniciada
	If lRet .And. oMovimento:GetRecHum() == cRecHum .And. !Empty(__nRecD12)
		If PendDocAnt(cRecHum,cFuncao,cUsuZona)
			If !__lDestino .Or. (__lDestino .AND. lWMSCOMP)
				lRet := .F.
			EndIf
		EndIf
	EndIf
	// Verifica se for conferência de expedição, se foi separada alguma quantidade para permitir conferir
	If lRet .And. oMovimento:oMovServic:ChkConfSai() // Conferencia de expedição
		lRet := HasPrdSai()
	EndIf
	// Verifica se permite reiniciar tarefas, e questiona uma unica vez na secao se deseja reiniciar
	If lRet
		If !lPergAuto .And. lReinAuto .And. oMovimento:GetStatus() == "2" .And. oMovimento:GetPrAuto() == "1"
			If !(lReinAuto := WMSVTAviso(WMSV00110,STR0033, {STR0016,STR0017}) == 1)  // Existe tarefa anterior pendente. Reiniciar? // Sim // Nao
				lRet := .F.
			EndIf
			lPergAuto := .T. // Para não perguntar novamente quando solicionado que não quer reiniciar
		Else
			// Ignora atividades já iniciadas por outros usuarios
			If !(oMovimento:GetStatus() $ "3|4")
				If !(lReinAuto .And. oMovimento:GetStatus() == "2")
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf
	// Valida se movimento possui dependente
	If lRet .And. oMovimento:oOrdServ:ChkDepPend()
		lRet := .F.
	EndIf
	// Não convocar endereços bloqueados
	// Verifica situação do endereço origem  e destino
	If lRet
		If oMovimento:oMovServic:GetServico() <> cSegSepara .And. !oMovimento:ChkEndOri(.T.,.T.) 
			lRet := .F.
		EndIf
		// Verifica situação do endereço destino
		If lRet .And. !oMovimento:ChkEndDes(.T.)
			lRet := .F.
		EndIf
		// Quando problema de saldo e capacidade e bloqueio de endereço gera log e bloqueia o movimento
		If !lRet
			oMovimento:SetLog('1')
			oMovimento:SetPrAuto("1") // Permite reinicio automático
			oMovimento:SetStatus('2')
			oMovimento:UpdateD12()
		EndIf
		// Para servicos de reabastecimento valida se a quantidade saldo do endereço é maior que a capacidade
		If oMovimento:oMovServic:ChkReabast() .And. !oMovimento:ValCapReab()
			lRet := .F.
		EndIf
	EndIf
	// Quando for uma conferencia de saida libera os demais itens
	If lRet .And. lReinAuto .And. oMovimento:oMovServic:ChkConfer()
		// Quando for uma conferencia de saida libera os demais itens
		UpdSitLib()
	EndIf

	If lRet
		If ExistBlock('DLVACONV')
			ExecBlock('DLVACONV', .F., .F., {cRecHum, cFuncao, oMovimento:GetRecno()})
		EndIf
		// Regra para a convocacao dos Servicos x Tarefas x Atividades
		If ExistBlock('WMSV001A')
			lConvoca := ExecBlock('WMSV001A', .F., .F.,{cRecHum,cFuncao,oMovimento:oMovServic:GetServico(),oMovimento:oMovTarefa:GetTarefa(),oMovimento:oMovTarefa:GetAtivid(),oMovimento:oMovTarefa:GetOrdem(),oMovimento:oOrdServ:GetDocto(),lConvoca})
		Else
			If AllTrim(oMovimento:GetRhFunc()) == AllTrim(cFuncao)
				If !Empty(oMovimento:oMovTarefa:GetTarefa()) .And. !Empty(oMovimento:oMovTarefa:GetAtivid())
					lConvoca := ChkExecAnt(oMovimento,nTipoConv,dDataFec,cRecHum,(lReinAuto  .And. oMovimento:GetPrAuto() == "1"))
				EndIf
			EndIf
		EndIf
		// Ponto de Entrada Antes da Confirmacao da Convocacao para verificar saldo endereco origem.
		If ExistBlock('WMSV001B')
			aRetPE := ExecBlock('WMSV001B', .F., .F.,{cRecHum,cFuncao,oMovimento:oMovServic:GetServico(),oMovimento:oMovTarefa:GetTarefa(),oMovimento:oMovTarefa:GetAtivid(),oMovimento:oMovTarefa:GetOrdem(),oMovimento:oOrdServ:GetDocto(),lConvoca,oMovimento:oMovServic:GetFuncao()})
			If ValType(aRetPE) == 'A' .And. !Empty(aRetPE) .And. ValType(aRetPE[1])=='L'
				lConvoca := aRetPE[1]
			EndIf
		EndIf
	EndIf
	If lRet .And. lConvoca
		If Empty(oMovimento:GetRecHum())
			cNumero := Left(oMovimento:oOrdServ:GetDocto(),Len(SD7->D7_NUMERO))
			// Movimentacoes de CQ
			SD7->(DbSetOrder(3))
			If SD7->(MsSeek(xFilial('SD7')+oMovimento:oMovPrdLot:GetProduto()+oMovimento:oOrdServ:GetNumSeq()+cNumero))
				cArmSBE := SD7->D7_LOCAL
			Else
				cArmSBE := oMovimento:oMovEndOri:GetArmazem()
			EndIf
			// Verifica se ha regras para convocacao para estas atividades.
			oRegraConv:aRetRegra := {}
			oRegraConv:SetArmazem(cArmSBE)
			oRegraConv:SetRecHum(cRecHum)
			oRegraConv:oMovimento:GoToD12(oMovimento:GetRecno())
			// Verifica se ha regras para convocacao
			If oRegraConv:LawRecHum()
				// Analisa se convocao ou nao
				If !oRegraConv:LawLimit()
					lRet := .F.
				EndIf
			Else
				// Convocar para esta atividade somente se encontrar regra definida para o operador.
				If lNaoConv
					lRet := .F.
				EndIf
				// Apesar de o operador(A) nao ter regra definida, preciso analisar se outro operador(B) reservou a rua,
				// se o operador(B) ja reservou a rua o operador(A) nao sera convocado ate que a rua seja liberada.
				If lRet .And. !oRegraConv:LawChkRua()
					lRet := .F.
				EndIf
				// Ignora a Zona de Armazenagem diferente da escolhida na convocacao
				If lRet .And. !Empty(cUsuZona)
					// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					// ³ Verifica o Tipo de Servico (1-Entrada/2-Saida/3-Mov.Interno)          ³
					// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					SBE->(DbSetOrder(1)) // BE_FILIAL+BE_LOCAL+BE_LOCALIZ+BE_ESTFIS
					lPertenceZ := .F.
					If oMovimento:oMovServic:GetTipo() $ '2|3' // Saidas ou Mov. Internos: Considera a Zona referente ao Endereco/Zona de ORIGEM
						lPertenceZ := (oMovimento:oMovEndOri:GetCodZona() == cUsuZona)
					EndIf
					If !lPertenceZ
						If oMovimento:oMovServic:GetTipo() $ '1|3' // Entradas ou Mov. Internos: Considera a Zona referente ao Endereco/Zona de DESTINO
							lPertenceZ := (oMovimento:oMovEndDes:GetCodZona() == cUsuZona)
						EndIf
					EndIf
					If !lPertenceZ
						lRet := .F.
					EndIf
				EndIf
			EndIf
		EndIf
	Else
		lRet := .F.
	EndIf
	RestArea(aAreaAnt)
Return lRet


// ---------------------------------------------------------
/*/{Protheus.doc} WMSConvD12
Seta a próxima atividade a ser convocada, sem ter a
necessidade de remontar o SQL da rotina de convocação
automática. Utilizada no multi-tarefa e também quando o D12
é desmembrado em várias movimentações para convocar o novo D12.
@author  Jackson Patrick Werka
@version P11
@Since    30/08/13
@obs  Seta a próxima atividade a ser convocada
@param nRecnoD12, númerico, (recno da ordem de serviço WMS (D12))
@param lConvD12, boleano, (Indica se convoca D12)
/*/
// ---------------------------------------------------------
Static Function WMSConvD12(nRecnoD12,lConvD12)
Default lConvD12 := .T.
	__nRecD12  := nRecnoD12
	__lConvoca := lConvD12
Return Nil



/*--------------------------------------------------------------------------------
---PendDocAnt
---Verifica se há atividades pendentes que podem ser realizadas
---pelo recurso
---Alexsander.correa - 22/08/2013
---cRecHum, caracter, (Recurso logado)
---cFuncao, caracter, (Função para analise de convocação)
---cUsuZona, caracter, (Armazem logado)
----------------------------------------------------------------------------------*/
Static Function PendDocAnt(cRecHum,cFuncao,cUsuZona)
Local lRet      := .F.
Local cAliasDCQ := GetNextAlias()
Local cAliasDoc := GetNextAlias()
Local aAreaD12  := D12->(GetArea())
Local cArmazem  := ""
Local cNumero   := ""
Local lContinua := .F.
Local cQuery    := ""
Local cCargaPed := ""
	// D12 da atividade anterior
	D12->(dbGoTo(__nRecD12))
	If D12->(!Eof())
		oServico:SetServico(D12->D12_SERVIC)
		oServico:SetOrdem(D12->D12_ORDTAR)
		oServico:LoadData()
		// Poderão ser utilizados os metodos de checagem pois a ordem da tarefa foi atribuída.
		If oServico:ChkSepara()
			If WmsCarga(oMovimento:oOrdServ:GetCarga())
				cCargaPed := oMovimento:oOrdServ:GetCarga()
			Else
				cCargaPed := oMovimento:oOrdServ:GetDocto()+oMovimento:oOrdServ:GetCliFor()+oMovimento:oOrdServ:GetLoja()
			EndIf
			// Verifica se a documento/carga é diferente do atual
			If cCargaPed <> Iif(WmsCarga(D12->D12_CARGA), D12->D12_CARGA,D12->D12_DOC+D12->D12_CLIFOR+D12->D12_LOJA)
				cNumero := Left(D12->D12_DOC,Len(SD7->D7_NUMERO))
				SD7->(DbSetOrder(3))
				If SD7->(MsSeek(xFilial('SD7')+D12->D12_PRODUT+D12->D12_NUMSEQ+cNumero))
					cArmazem := SD7->D7_LOCAL
				Else
					cArmazem := D12->D12_LOCORI
				EndIf
				// Verifica se possui regra de convocação exclusiva por documento/carga
				cQuery := " SELECT DCQ_FILIAL, DCQ_TPREGR, DCQ_DOCEXC "
				cQuery += " FROM " + RetSqlName('DCQ')
				cQuery += " WHERE DCQ_FILIAL = '"+xFilial("DCQ")+"'"
				cQuery += " AND DCQ_DOCEXC <> '2' "
				cQuery += " AND DCQ_LOCAL = '"+D12->D12_LOCORI+"' "
				cQuery += " AND (DCQ_CODFUN = ' ' OR DCQ_CODFUN = '"+cRecHum+"') "
				cQuery += " AND (DCQ_CODZON = ' ' OR DCQ_CODZON = '"+cUsuZona+"') "
				cQuery += " AND (DCQ_SERVIC = ' ' OR DCQ_SERVIC = '"+D12->D12_SERVIC+"') "
				cQuery += " AND D_E_L_E_T_ <> '*' "
				cQuery := ChangeQuery(cQuery)
				DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasDCQ,.F.,.T.)
				If (cAliasDCQ)->(!Eof())
					lContinua := .T.
				EndIf
				(cAliasDCQ)->(DbCloseArea())
				 If lContinua
					// Se possui regra verifica se o documento anterior possui pendencias
					cQuery := QryValAtCv(cRecHum,cFuncao,cArmazem,__nRecD12,.F.,.T.,.T.)
					DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasDoc,.F.,.T.)
					If (cAliasDoc)->(!Eof())
						lRet := .T.
					EndIf
					(cAliasDoc)->(dbCloseArea())
				EndIf
			EndIf
		EndIf
	EndIf
	RestArea(aAreaD12)
Return lRet

/*--------------------------------------------------------------------------------
---UpdSitLib
---Libera os serviços de conferencia quando permitido o reinicio automatico
---Alexsander.Correa - 11/05/2015
----------------------------------------------------------------------------------*/
Static Function UpdSitLib()
Local cQuery    := ""
Local aAreaD12  := D12->(GetArea())
Local cAliasD12 := GetNextAlias()
	cQuery := "SELECT D12.R_E_C_N_O_ RECD12"
	cQuery +=   " FROM " + RetSqlName('D12')+" D12 "
	cQuery +=  " WHERE D12.D12_FILIAL = '"+xFilial("D12")+"'"
	// Verifica a versao e o paramentro que permite reabrir tarefa paralizadas
	cQuery += " AND D12.D12_STATUS IN ('2','3')"
	If oMovimento:oMovServic:ChkConfEnt()
		cQuery += " AND D12.D12_DOC = '"+oMovimento:oOrdServ:GetDocto()+"'"
		cQuery += " AND D12.D12_SERIE = '"+oMovimento:oOrdServ:GetSerie()+"'"
	Else
		If WmsCarga(oMovimento:oOrdServ:GetCarga())
			cQuery += " AND D12.D12_CARGA = '"+oMovimento:oOrdServ:GetCarga()+"'"
		Else
			cQuery += " AND D12.D12_DOC = '"+oMovimento:oOrdServ:GetDocto()+"'"
		EndIf
	EndIf
	cQuery += " AND D12.D12_SERVIC = '"+oMovimento:oMovServic:GetServico()+"'"
	cQuery += " AND D12.D12_TAREFA = '"+oMovimento:oMovTarefa:GetTarefa()+"'"
	cQuery += " AND D12.D12_ATIVID = '"+oMovimento:oMovTarefa:GetAtivid()+"'"
	cQuery += " AND D12.D12_ORDTAR = '"+oMovimento:oMovServic:GetOrdem()+"'"
	cQuery += " AND D12.D12_ORDATI = '"+oMovimento:oMovTarefa:GetOrdem()+"'"
	cQuery += " AND D12.D12_QTDLID = 0"
	cQuery += " AND D12.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasD12,.F.,.T.)
	Do While (cAliasD12)->(!Eof())
		D12->(dbGoTo((cAliasD12)->RECD12))
		If D12->(!Eof())
			RecLock("D12",.F.)
			D12->D12_STATUS := '4'
			D12->(MsUnlock())
		EndIf
		(cAliasD12)->(dbSkip())
	EndDo
	(cAliasD12)->(DbCloseArea())
	RestArea(aAreaD12)
Return Nil


Static Function VldSegSep()
Local aArea    := GetArea()
Local nQtdRet  := 0
Local cSrv		:= SuperGetMV('ES_SERVDIS',.T.,'019',cFilAnt)
Local nRecnoD12	:= oMovimento:GetRecno()
Local aArrEnder	:= oMovimento:GetArrCol()
Local n			:= 0

For n := 1 to Len(aArrEnder)
	oMovimento:GoToD12(aArrEnder[n][1])
	DbSelectArea( "DCR" ) // Cadastro Relac. Mov. Distribuicao
	DbSetOrder( 2 ) // DCR_FILIAL + DCR_IDMOV + DCR_IDOPER + DCR_IDORI + DCR_IDDCF
	If DCR->( DbSeek( xFilial('DCR') +oMovimento:GetIdMovto()  + oMovimento:GetIdOpera() ) ) 
		/*-----------------------------------------------------------------+
		| Posicionamento do cadastro DCF - Ordem de Servicos               |
		+-----------------------------------------------------------------*/
		DbSelectArea( "DCF" ) // Cadastro Ordem de Servicos
		DbSetOrder( 9 ) // DCF_FILIAL + DCF_ID + DCF_SEQUEN
		If DCF->( DbSeek( DCR->( DCR_FILIAL + DCR_IDDCF + DCR_SEQUEN ) ) )		
			DC5->( DbSetOrder( 1 ) )
			If DC5->( DbSeek( xFilial( 'DC5' ) + DCF->DCF_SERVIC )) .AND. DC5->DC5_OPERAC = '3' .And. DCF->DCF_SERVIC == cSrv
				//TABELA DC6- TAREFA X ATIVIDADES
				DC6->( DbSetOrder( 1 ) )
				If DC6->( DbSeek( xFilial( 'DC6' ) + DC5->DC5_SERVIC )) .AND. DC6->DC6_TPAGLU <> '1'
					If DC6->DC6_TPAGLU <> '1' //DC6_TPAGLU <> '1' INDICA QUE A ATIVIDADE E AGLUTINADA
						GeraSegSep()
					EndIf
				Endif
			Endif 
		EndIf
	EndIf   
Next

oMovimento:GoToD12(nRecnoD12)

RestArea(aArea)
Return .T.



/*======================================================================================+
| Funcao de Usuario ..:   u_GeraSegSep()                                                |
| Autor...............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   23/10/2019                                                    |
| Descricao / Objetivo:   Programa-fonte com personalizacoes do processo da Segunda     |
|                         Separacao WMS.                                                |
| Doc. Origem.........:   MIT044 - R01PT - Criacao do Novo Servico de WMS no Processo   |
|                         de Separacao.                                                 |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
Static Function GeraSegSep()
Local aArea     := GetArea()
//Local aAreaD12  := D12->( GetArea() )
Local cCateg    := ""
Local nPesoLiq  := 0
Local nNorma    := 0
Local nPesoTot  := 0
Local nPosic    := 0
Local cCdEstFis := ""
Local cTpEstr   := Space( TamSX3( "DC8_TPESTR" )[ 1 ] )

Private aSeparacao := {}
Private aCapacid   := {}
Private nFatCnv    := 0

/*-----------------------------------------------------------------+
| Posicionamento do cadastro DCR - Relac. Mov. Distribuicao        |
+-----------------------------------------------------------------*/
DbSelectArea( "DCR" ) // Cadastro Relac. Mov. Distribuicao
DbSetOrder( 2 ) // DCR_FILIAL + DCR_IDMOV + DCR_IDOPER + DCR_IDORI + DCR_IDDCF
If DCR->( DbSeek( xFilial('DCR') +oMovimento:GetIdMovto()  + oMovimento:GetIdOpera() ) ) 
   While  ( xFilial('DCR') +oMovimento:GetIdMovto()  + oMovimento:GetIdOpera() ) == xFilial('DCR') + DCR->(DCR_IDMOV + DCR_IDOPER) 
      /*-----------------------------------------------------------------+
      | Posicionamento do cadastro DCF - Ordem de Servicos               |
      +-----------------------------------------------------------------*/
      DbSelectArea( "DCF" ) // Cadastro Ordem de Servicos
      DbSetOrder( 9 ) // DCF_FILIAL + DCF_ID + DCF_SEQUEN
      If DCF->( DbSeek( DCR->( DCR_FILIAL + DCR_IDDCF + DCR_SEQUEN ) ) )
      
         aSeparacao := {} // Reinicializa a array aSeparacao para o proximo DCF.
      
         /*-----------------------------------------------------------------+
         | Busco o codigo da Estrutura Fisica do cadastro de Endereco - SBE |
         +-----------------------------------------------------------------*/
         DbSelectArea( "SBE" ) // Cadastro de Enderecos
         DbSetOrder( 1 )
         If DbSeek( DCF->( DCF_FILIAL + DCF_LOCDES + DCF_ENDDES ) )                  
            cCdEstFis := SBE->BE_ESTFIS
         EndIf
         
         /*---------------------------------------------------------------------------+
         | Busco o peso bruto, categoria e fator conversao cadastro de Produtos - SB1 |
         +---------------------------------------------------------------------------*/
         DbSelectArea( "SB1" ) // Cadastro de Produtos
         DbSetOrder( 1 ) // B1_FILIAL + B1_COD
         If SB1->( DbSeek( xFilial( "SB1" ) + DCF->DCF_CODPRO ) )
            nPesoLiq := SB1->B1_PESO    // Pega o peso bruto do produto para fins de calculo de capacidade volumetrica
            cCateg   := SB1->B1_XCTGPRD // Pega a categoria do produto e atribui para a variavel cCateg
            nFatCnv  := SB1->B1_CONV    // Pega o fator de conversao e atribui para a variavel nFatCnv
         EndIf      
      
         /*-----------------------------------------------------------------+
         | Posiciona no arquivo DC8 (Estrutura Fisica) para obter o codigo  |
         | da estrutura (DC8_CODEST).                                       |
         +-----------------------------------------------------------------*/
         DbSelectArea( "DC8" ) // Cadastro de Estrutura Fisica
         DbSetOrder( 3 ) // DC8_FILIAL + DC8_TPESTR
         If DC8->( DbSeek( xFilial( "DC8" ) + "1" ) )  // "1" e' Pulmao
            cTpEstr := DC8->DC8_CODEST
         EndIf

         /*-----------------------------------------------------------------+
         | Posiciona no arquivo DC3 (Sequencia de Abastecimento) para saber |
         | o codigo da norma do produto.                                    |
         +-----------------------------------------------------------------*/
         DbSelectArea( "DC3" ) // Cadastro de Sequencia de Abastecimento
         DbSetOrder( 2 ) // DC3_FILIAL + DC3_CODPRO + DC3_LOCAL + DC3_TPESTR
         If DbSeek( xFilial( "DC3" ) + DCF->( DCF_CODPRO + DCF_LOCAL ) + cTpEstr )
            /*-----------------------------------------------------------+
            | Posiciona no arquivo DC2 (Norma de Paletizacao) para saber |
            | a quantidade da norma de cada produto.                     |
            +-----------------------------------------------------------*/
            DbSelectArea( "DC2" ) // Cadastro de Norma de Paletizacao
            DbSetOrder( 1 ) // DC2_FILIAL + DC2_CODNOR
            If DbSeek( xFilial( "DC2" ) + DC3->DC3_CODNOR )
               If Empty( nFatCnv ) 
                  nNorma := DC2->( DC2_LASTRO * DC2_CAMADA )
               Else
                  nNorma := DC2->( DC2_LASTRO * DC2_CAMADA ) * nFatCnv
               EndIf
            EndIf
         EndIf
                     
         /*---------------------------------------------------------------+
         | Variavel cCateg - Classificacao do Produto e seu conteudo      |
         +----------------------------------------------------------------+
         | 1=Alergenico  |  2=Controlado  |  3=Comum  | 4=Sensibilizante  |
         +---------------------------------------------------------------*/
         cCodZon := Space( 6 )
         Do Case
            Case cCateg == "1" // 1 - Alergenico
               cCodZon := AllTrim( SuperGetMV( "ES_CZALE", .F., "000004", cFilAnt ) ) // cFilAnt ---> EEFF (EE=Empresa | FF=Filial)
            Case cCateg == "2" // 2 - Controlado
               cCodZon := AllTrim( SuperGetMV( "ES_CZCNT", .F., "000009", cFilAnt ) ) // cFilAnt ---> EEFF (EE=Empresa | FF=Filial)
            Case cCateg == "3" .or. cCateg == "4" // 3 - Comum ou 4 - Sensibilizante
               cCodZon := AllTrim( SuperGetMV( "ES_CZNRM", .F., "000013", cFilAnt ) ) // cFilAnt ---> EEFF (EE=Empresa | FF=Filial)
         EndCase
                  
         /*---------------------------------------------------------------+
         | Posiciona no arquivo SBE (Enderecos) para calculo de capacida- |
         | de volumetrica do endereco.                                    |
         +---------------------------------------------------------------*/
         DbSelectArea( "SBE" ) // Cadastro de Enderecos
         DbSetOrder( 12 ) // BE_FILIAL + BE_ESTFIS + BE_CODCFG + BE_CODZON + BE_STATUS + BE_LOCAL (indice customizado)
         If .not. Empty( cCodZon )
            If SBE->( DbSeek( xFilial( "SBE" ) + "000002" + "000010" + cCodZon + "1" + DCF->DCF_LOCAL ) )
               Do While SBE->( BE_FILIAL + BE_ESTFIS + BE_CODCFG + BE_CODZON + BE_STATUS + BE_LOCAL ) == xFilial( "SBE" ) + "000002" + "000010" + cCodZon + "1" + DCF->DCF_LOCAL .and. .not. SBE->( EoF() )

                  /*----------------------------------------------------------------------+
                  | Trecho que verifica a capacidade da norma no endereco a possibilidade |
                  | de armazenar no endereco e de acordo com a categoria.                 | 
                  +----------------------------------------------------------------------*/
                  /*-------+-------+----------+--------+----------+-------+
                  | FILIAL | LOCAL | ENDERECO | PEDIDO | CATEGORIA| NORMA | Elementos da array aCapacid
                  +--------+-------+----------+--------+----------+------*/
                  nPosic := aScan( aCapacid, { | x | x[1]+x[2]+x[3]+x[4]+x[5] == SBE->( BE_FILIAL + BE_LOCAL + BE_LOCALIZ ) + DCF->DCF_DOCTO + cCateg } )

                  If nPosic == 0
                     nPosic1 := aScan( aCapacid, { | x | x[1]+x[2]+x[3]+x[5] == SBE->( BE_FILIAL + BE_LOCAL + BE_LOCALIZ )+ cCateg } )
                     If nPosic1 > 0
                        SBE->( DbSkiP() ) // Avanca para buscar o proximo endereco com capacidade disponivel
                        LooP
                     EndIf                        
                     aAdd( aCapacid, { SBE->BE_FILIAL, SBE->BE_LOCAL, SBE->BE_LOCALIZ, DCF->DCF_DOCTO, cCateg, nNorma } )
                     nPosic := aScan( aCapacid, { | x | x[1]+x[2]+x[3]+x[4]+x[5] == SBE->( BE_FILIAL + BE_LOCAL + BE_LOCALIZ ) + DCF->DCF_DOCTO + cCateg } )                                     
                  EndIf

                  If aCapacid[ nPosic, 6 ] >= ( DCF->DCF_QUANT * nPesoLiq )
                     /*-------------------------------------------------------------------------------------------------------------+
                     |                                                   Array aSeparacao                                           |
                     +--------+-------+----------+-----------+---------+------+------+--------+------+------------------------------+
                     | FILIAL | LOCAL | ENDERECO | CATEGORIA | PRODUTO | QTDE | LOTE | CLIFOR | LOJA | ESTFIS | PEDIDO | END.ORIGEM |
                     +--------+-------+----------+-----------+---------+------+------+--------+------+-----------------------------*/
                     aAdd( aSeparacao, { DCF->DCF_FILIAL, aCapacid[ nPosic, 2 ], aCapacid[ nPosic, 3 ], cCateg, DCF->DCF_CODPRO, ( DCF->DCF_QUANT * nPesoLiq ), oMovimento:oMovPrdLot:GetLoteCtl(), DCF->DCF_CLIFOR, DCF->DCF_LOJA, cCdEstFis, DCF->DCF_DOCTO, DCF->DCF_ENDDES } ) 

                     /*----------------------------------------------------------+
                     | Realiza a gravacao do DCF pela funcao estatica GravaDCF() |
                     +----------------------------------------------------------*/
                     GravaDCF()

                     aCapacid[ nPosic, 6 ] := aCapacid[ nPosic, 6 ] - ( DCF->DCF_QUANT * nPesoLiq ) // Abate a capacidadade de carga do endereco.

                  Else
                     SBE->( DbSkiP() ) // Avanca para buscar o proximo endereco com capacidade disponivel
                     LooP
                  EndIf
                  ExiT // Sai do laco para ir para o proximo DCF.
               EndDo
            Else
               /*--------------------------------------------------+
               | Nao encontrou endereco disponivel para armazenar. |
               +--------------------------------------------------*/
               DbSelectArea( "SBE" )
               DbSetOrder( 5 ) // BE_FILIAL + BE_CODCFG
               If DbSeek( xFilial( "SBE" ) + AllTrim( SuperGetMV( "ES_CODCFG", .F., "000009", cFilAnt ) ) )
                  /*-------------------------------------------------------------------------------------------------------------+
                  |                                                   Array aSeparacao                                           |
                  +--------+-------+----------+-----------+---------+------+------+--------+------+------------------------------+
                  | FILIAL | LOCAL | ENDERECO | CATEGORIA | PRODUTO | QTDE | LOTE | CLIFOR | LOJA | ESTFIS | PEDIDO | END.ORIGEM |
                  +--------+-------+----------+-----------+---------+------+------+--------+------+-----------------------------*/
                  aAdd( aSeparacao, { xFilial( "SBE" ), SBE->BE_LOCAL, SBE->BE_LOCALIZ, cCateg, DCF->DCF_CODPRO, DCF->DCF_QUANT, oMovimento:oMovPrdLot:GetLoteCtl(), DCF->DCF_CLIFOR, DCF->DCF_LOJA, cCdEstFis, DCF->DCF_DOCTO, DCF->DCF_ENDDES } )

                  /*----------------------------------------------------------+
                  | Realiza a gravacao do DCF pela funcao estatica GravaDCF() |
                  +----------------------------------------------------------*/
                  GravaDCF()

               EndIf
            EndIf
         Else
            DbSelectArea( "SBE" ) // Cadastro de Enderecos
            DbSetOrder( 5 ) // BE_FILIAL + BE_CODCFG
            If DbSeek( xFilial( "SBE" ) + AllTrim( SuperGetMV( "ES_CODCFG", .F., "000009", cFilAnt ) ) )
               /*-------------------------------------------------------------------------------------------------------------+
               |                                                   Array aSeparacao                                           |
               +--------+-------+----------+-----------+---------+------+------+--------+------+------------------------------+
               | FILIAL | LOCAL | ENDERECO | CATEGORIA | PRODUTO | QTDE | LOTE | CLIFOR | LOJA | ESTFIS | PEDIDO | END.ORIGEM |
               +--------+-------+----------+-----------+---------+------+------+--------+------+-----------------------------*/
               aAdd( aSeparacao, { xFilial( "SBE" ), SBE->BE_LOCAL, SBE->BE_LOCALIZ, cCateg, DCF->DCF_CODPRO, DCF->DCF_QUANT, oMovimento:oMovPrdLot:GetLoteCtl(), DCF->DCF_CLIFOR, DCF->DCF_LOJA, cCdEstFis, DCF->DCF_DOCTO, DCF->DCF_ENDDES } )

               /*----------------------------------------------------------+
               | Realiza a gravacao do DCF pela funcao estatica GravaDCF() |
               +----------------------------------------------------------*/
               GravaDCF()

            EndIf
         EndIf

         /*------------------------------------------------+
         | Reinicializa as variaveis de trabalho           |
         +------------------------------------------------*/
         cCateg    := ""
         nPesoLiq  := 0
         nFatCnv   := 0
         nNorma    := 0
         nPesoTot  := 0
         nPosic    := 0
         cCdEstFis := ""
         cTpEstr   := Space( TamSX3( "DC8_TPESTR" )[ 1 ] )  
      EndIf
      DCR->(DbSkip())
   EndDo
EndIf

RestArea( aArea    )
//RestArea( aAreaD12 )
Return( Nil )

/*======================================================================================+
| Funcao Estatica ....:   GravaDCF()                                                    |
| Autor...............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   27/11/2019                                                    |
| Descricao / Objetivo:   Funcao estatica para a gravacao do DCF a partir da array      |
|                         aSeparacao.                                                   |
| Doc. Origem.........:   MIT044 - R01PT - Criacao do Novo Servico de WMS no Processo   |
|                         de Separacao.                                                 |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
Static Function GravaDCF()
Local aArea := GetArea()
Local cHora := Time()
Local  cSegSepara	 := SuperGetMV('ES_SERVSEP',.T.,'025',cFilAnt)
/*-------------------------------------------------------+
| Realiza a gravacao do DCF a partir da array aSeparacao |
+-------------------------------------------------------*/
DbSelectArea( "DCF" ) // Cadastro Ordem de Servico WMS

/*----[ Elementos da array aSeparacao ]---------------------------------------------------------------------------------------------------------------------+
| 01 FILIAL  | 02 LOCAL  | 03 ENDERECO  | 04 CATEGORIA | 05 PRODUTO  | 06 QTDE  | 07 LOTE  | 08 CLIFOR  | 09 LOJA  | 10 ESTFIS | 11 PEDIDO | 12 END.ORIGEM  |
+----------------------------------------------------------------------------------------------------------------------------------------------------------*/
RecLock( "DCF", .F. )
Replace  DCF->DCF_SERVIC    With  cSegSepara
Replace  DCF->DCF_STSERV    With   "1"
Replace  DCF->DCF_XENDER    With  DCF->DCF_ENDER
Replace  DCF->DCF_ENDER     With  aSeparacao[ 1, 12 ] // Endereco Origem
Replace  DCF->DCF_XENDDE    with  DCF->DCF_ENDDES
Replace  DCF->DCF_ENDDES    With  aSeparacao[ 1,  3 ] // Endereco Destino
//Replace  DCF->DCF_LOTECT    With  aSeparacao[ 1, 7 ] // Lote

/*
Replace  DCF->DCF_FILIAL    With  aSeparacao[ 1,  1 ] // Filial
Replace  DCF->DCF_SERVIC    With  "025" // Novo servico (025)
Replace  DCF->DCF_DOCTO     With  aSeparacao[ 1, 11 ] // Pedido de Venda
Replace  DCF->DCF_SERIE     With  StrZero( 1, 2 ) // Sequencia
Replace  DCF->DCF_DATA      With  dDataBase // Data Base
Replace  DCF->DCF_CLIFOR    With  aSeparacao[ 1,  8 ] // Cliente/Fornecedor
Replace  DCF->DCF_LOJA      With  aSeparacao[ 1,  9 ] // Loja Cliente/Fornecedor
Replace  DCF->DCF_CODPRO    With  aSeparacao[ 1,  5 ] // Codigo Produto
Replace  DCF->DCF_STSERV    With   "1"
Replace  DCF->DCF_QUANT     With  DCF->DCF_QUANT + aSeparacao[ 1,  6 ] // Quantidade
Replace  DCF->DCF_QTSEUM    With  iIf( Empty( nFatCnv ), 0, DCF->DCF_QTSEUM + ( aSeparacao[ 1, 6 ] / nFatCnv ) ) // Qtde. Segunda UM
Replace  DCF->DCF_ORIGEM    With  "SC9"
Replace  DCF->DCF_NUMSEQ    With  ProxNum() // Analisar
Replace  DCF->DCF_LOCAL     With  aSeparacao[ 1,  2 ] // Local
Replace  DCF->DCF_ESTFIS    With  aSeparacao[ 1, 10 ] // Estrutura Fisica
Replace  DCF->DCF_ENDER     With  aSeparacao[ 1, 12 ] // Endereco Origem
Replace  DCF->DCF_LOTECTL   With  aSeparacao[ 1, 7 ] // Lote
Replace  DCF->DCF_QTDORI    With  aSeparacao[ 1,  6 ] // Qtde. Original
Replace  DCF->DCF_ID        With  ProxNum() // Analisar
Replace  DCF->DCF_SEQUEN    With  "01"
Replace  DCF->DCF_LOCDES    With  aSeparacao[ 1,  2 ] // Local Destino
Replace  DCF->DCF_ENDDES    With  aSeparacao[ 1,  3 ] // Endereco Destino
Replace  DCF->DCF_PRDORI    With  aSeparacao[ 1,  5 ] // Produto Origem
Replace  DCF->DCF_HORA      With  cHora // Hora*/
DCF->( MSUnLock() )

SC9->(DbSetOrder(9))
If SC9->(DbSeek(xFilial('SC9') + DCF->DCF_ID))
   While SC9->C9_IDDCF == DCF->DCF_ID
		If SC9->C9_LOTECTL == oMovimento:oMovPrdLot:GetLoteCtl()
			RecLock('SC9',.F.)
			SC9->C9_XSERVI := SC9->C9_SERVIC
			SC9->C9_SERVIC := cSegSepara
			SC9->C9_XBLWMS  := SC9->C9_BLWMS
			SC9->C9_BLWMS  := '01'  
			SC9->C9_XLOGWMS := UsrRetName( retcodusr() ) + ";" + DTOC(dDataBase) + ";" + Time()  + ";" + FUNNAME() + ";" + '01'
			//SC9->C9_XLOTECT := SC9->C9_LOTECTL
			//SC9->C9_LOTECTL := DCF->DCF_LOTECT
			SC9->C9_XENDPAD := SC9->C9_ENDPAD	
			SC9->C9_ENDPAD	:= DCF->DCF_ENDDES
			MsUnlock()
		EndIf
      SC9->(DbSkip())
   EndDo
EndIf


SC6->(DbSetOrder(1))
If SC6->(DbSeek(xFilial('SC6') + PADR(DCF->DCF_DOCTO,TamSX3('C6_NUM')[1]) + PADR(DCF->DCF_SERIE,TamSX3('C6_ITEM')[1]) + PADR(DCF->DCF_CODPRO,TamSX3('C6_PRODUTO')[1])))
   RecLock('SC6',.F.)
   SC6->C6_SERVIC := cSegSepara
   MsUnlock()	
EndIf
 /*-----------------------------------------------------------------+
| Posicionamento do cadastro D0D - Distribuicao Separacao          |
+-----------------------------------------------------------------*/
/*
DbSelectArea( "D0D" ) // Cadastro de Distribuicao de Separacao
DbSetOrder( 3 ) // D0D_FILIAL + D0D_PEDIDO (indice customizado)
If D0D->( DbSeek( DCF->( DCF_FILIAL + Left( DCF_DOCTO, 6 ) ) ) )
   If D0D->D0D_STATUS == "1" /* 1=Status Pendente | 2=Status Finalizado */
      /*-----------------------------------------------------------------+
      | Posicionamento do cadastro D0E - Distribuicao Separacao Itens    |
      +-----------------------------------------------------------------*/
/*      
      DbSelectArea( "D0E" ) // Cadastro de Distribuicao de Separacao (Itens)
//            DbSetOrder( 1 ) // D0E_FILIAL + D0E_CODDIS + D0E_CARGA + D0E_PEDIDO + D0E_LOCORI + D0E_PRDORI + D0E_PRODUT + D0E_LOTECT + D0E_NUMLOT
      DbSetOrder( 4 ) // D0E_FILIAL + D0E_CODDIS + D0E_PRDORI
      If D0E->( DbSeek( D0D->( D0D_FILIAL + D0D_CODDIS + D12->D12_PRODUT ) ) ) .And. D0D->D0D_DATA == DCF->DCF_DATA .And. D0D->D0D_LIBEST == '2'
         /*-----------------------------------------------------------+
         | Realiza a varredura do D0E para categorizacao dos produtos |
         +-----------------------------------------------------------*/
   /*      Do While D0E->( D0E_FILIAL + D0E_CODDIS + D0E_PRDORI ) == D0D->( D0D_FILIAL + D0D_CODDIS + D12->D12_PRODUT ) .and. .not. D0E->( EoF() )
            RecLock('D0E',.F.)
            D0E->D0E_ENDORI := aSeparacao[ 1,  3 ]
            MSUnLock()
            D0E->(DbSkip())
         EndDo
      EndIf
   EndIf
EndIf
*/
/*-----------------------------------------------------------------+
| Posicionamento do cadastro SC9                                    |
+-----------------------------------------------------------------*/
/*
DbSelectArea( "SC9" ) // Cadastro de Distribuicao de Separacao
DbSetOrder( 9 ) // IDDCF
If SC9->( DbSeek( xFilial('SC9') + DCF->DCF_ID ) ) 
   If  SC9->C9_SERVIC <> '025'  
      RecLock('SC9',.F.)
      SC9->C9_SERVIC := '025'
      SC9->C9_BLWMS  := '01'
      SC9->C9_LOTECTL := aSeparacao[ 1, 7 ]
      MSUnLock()
   EndIf
EndIf
*/
/*-----------------------------------------------+
| Reinicia a array aSeparacao para o proximo DCF |
+-----------------------------------------------*/
aSeparacao := {}

RestArea( aArea )
Return( Nil )

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



Static Function WmsMontPrd(cWmsUMI,lConf,cDesTar,cArmazem,cEndereco,cPrdOri,cProduto,cLoteCtl,cNumLote,cIdUnit)
Local lRet      := .T.
Local aTelaAnt  := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local lWmsLote  := SuperGetMV('MV_WMSLOTE',.F.,.F.) // Solicita a confirmacao do lote nas operacoes com RF
Local lDetProd  := SuperGetMV('MV_WMSVSTC',.F.,.F.) // Apresenta descricao do produto no coletor RF
Local oProdLote := WMSDTCProdutoLote():New()
Local oEndereco := WMSDTCEndereco():New()
Local nLin      := 1

Default cWmsUMI  := ""
Default lConf    := .F.
Default cLoteCtl := ""
Default cNumLote := ""
Default cIdUnit  := ""

	// Produto
	oProdLote:SetArmazem(cArmazem)
	oProdLote:SetPrdOri(cPrdOri)
	oProdLote:SetProduto(cProduto)
	oProdLote:SetLoteCtl(cLoteCtl)
	oProdLote:SetNumLote(cNumLote)
	oProdLote:SetNumSer("")
	oProdLote:LoadData()
	// Endereco
	oEndereco:SetArmazem(cArmazem)
	oEndereco:SetEnder(cEndereco)
	oEndereco:LoadData()
	//            1
	//  01234567890123456789
	// 0 _______Apanhe_______
	// 1 Pegue o produto
	// 2 WMS01
	// 3 PRODUTO WMS 01
	// 4
	// 5 Norma: L 10 x 10 C
	// 6 ___________________
	// 7 Pressione <ENTER>
	If lDetProd
		nLin := 1
		WMSVTCabec(cDesTar,.F.,.F.,.T.)
		@ nLin++,00 VTSay PadR(IIf(!lConf,"Pegue o Produto ","Dados do Produto"), VTMaxCol()) // Pegue o Produto // Dados do Produto
		@ nLin++,00 VTSay PadR(oProdLote:GetProdCol(),VTMaxCol())
		@ nLin++,00 VTSay PadR(SubStr(oProdLote:GetDesc(),1,VTMaxCol()),VTMaxCol())
		@ nLin++,00 VTSay PadR(SubStr(oProdLote:GetDesc(),VTMaxCol()+1,VTMaxCol()),VTMaxCol())
		@ nLin++,00 VTSay PadR(WmsDesNorma(oProdLote:GetProduto(),oEndereco:GetArmazem(),oEndereco:GetEstFis()),VTMaxCol())
		//Permite complementar a tela que solicita a coleta do produto
		WMSVTRodPe()
	EndIf
	If !lConf
		//            1
		//  01234567890123456789
		// 0 _______Apanhe_______
		// 1 Pegue o Produto
		// 2 008
		// 3 Lote: AUTO000160
		// 4 Sub-Lote: 000160
		// 5 Unitizador
		// 6 000001
		// 7  Pressione <ENTER>
		If (cWmsUMI == "3" .And. !lDetProd) .Or. (lWmsLote .And. oProdLote:HasRastro())
			nLin := 1
			WMSVTCabec(cDesTar,.F.,.F.,.T.)
			@ nLin++,00 VTSay PadR("Pegue o Produto", VTMaxCol())  // Pegue o Produto'
			@ nLin++,00 VTSay PadR(oProdLote:GetProdCol(),VTMaxCol()) // aItens[nPos][2]
			@ nLin++,00 VTSay PadR(SubStr(oProdLote:GetDesc(),1,VTMaxCol()),VTMaxCol())// RODOLFO - Descrição do produto
			If lWmsLote
				If oProdLote:HasRastro()
					@ nLin  ,00 VTSay PadR("Lote:",VTMaxCol()) // Lote:
					@ nLin++,06 VTSay PadR(oProdLote:GetLoteCtl(),VTMaxCol())
				EndIf
				If oProdLote:HasRastSub()
					@ nLin  ,00 VTSay PadR("Sub-Lote:",VTMaxCol()) // Sub-Lote:
					@ nLin++,10 VTSay PadR(oProdLote:GetNumLote(),VTMaxCol())
				EndIf
			EndIf
			If !Empty(cIdUnit)
				@ nLin++,00 VTSay PadR("Unitizador",VTMaxCol()) // Unitizador
				@ nLin++,00 VTSay PadR(cIdUnit,VTMaxCol())
			EndIf
			//Permite complementar a tela que solicita a coleta do produto
			WMSVTRodPe()
		EndIf
	EndIf
	VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)

Return lRet

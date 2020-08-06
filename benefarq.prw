#INCLUDE "protheus.ch"
#INCLUDE "BenefArq.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "fileio.ch"

#Define CRLF CHR(13)+CHR(10)

//-------------------------------------------------------------------
/*/{Protheus.doc} BENEFARQ
INTEGRACAO DE BENEFICIOS COM EMPRESA SE SERVICOS

@author Marcelo Faria
@since 06/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
User Function BENEFARQ()
	Private cVBPerg 	:= 'ARQBENEF'
	Private lNovoCalc	:= NovoCalcBEN()

	If lNovoCalc
		cVBPerg := 'BENFARQ'
	EndIf

	Pergunte(cVBPerg,.F.)

	TNewProcess():New("BENEFARQ", STR0001, {|oSelf| ProcessBnf(oSelf)}, STR0002, cVBPerg, NIL, NIL, NIL, NIL, .T., .F.) // "Exportacao dos arquivos de beneficios" - "Esta rotina processa e gera arquivo de beneficios para integracao"
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ProcessBnf

@since 06/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ProcessBnf(oProcess)
	Local nCount, nCount2
	Local nOldSet   := SetVarNameLen(255)
	Local aArea     := GetArea()
	Local aItems    := {}
	Local lCancel   := .F.
	Local cPath    := "c:\Sodexo\"

	Private nTotal  := 0
	Private nVlr    := 0
	Private nHdl    := 0
	Private nLin    := 0
	Private cQryFech := ""

	Private cReprocessa := IIf(MV_PAR03==2,"1","2")  //*Reprocessamento - selecionar RG2_Pedido==2
	Private lImpLis := Iif(MV_PAR15 == 1,.T.,.F.)   //Impressao Relatorio
	Private nOrd    := MV_PAR16                   //Ordem Relatorio
	Private aItens		:= {}
	Private cArqOut   := ""
	Private lErrorImp := .F.
	
	If !ExistDir(cPath) //Caso não tenha o diretorio, o sistema cria
		If MakeDir(cPath) <> 0
			Aviso("NOMAKEDIR", "Não foi criar o diretório " + cPath + " .Verifique as permissões da máquina.")
			Return lRet := .F.
		EndIf
	EndIf
	
	If lNovoCalc
		dbSelectArea( "SR0" )
	Else
		dbSelectArea( "RG2" )
	EndIf
	dbSetOrder(1)

	AAdd(aItems, {STR0003, { || ProcINI(oProcess) } }) //"Lendo arquivo INI"

	oProcess:SetRegua1(Len(aItems)) //Total de elementos da regua
	oProcess:SaveLog(STR0004)       //"Inicio de processamento"

	For nCount:= 1 to Len(aItems)
		If (oProcess:lEnd)
			Break
		EndIf

		oProcess:IncRegua1(aItems[nCount, 1])
		Eval(aItems[nCount, 2])
	Next

	SetVarNameLen(nOldSet)

	//Fecha Arquivo
	If nHdl > 0
		If !fClose(nHdl)
			MsgAlert(STR0005) //'Ocorreram problemas no fechamento do arquivo.'
		EndIf
	EndIf

	//Encerra o processamento
	If !oProcess:lEnd
		oProcess:SaveLog(STR0006) //"Fim do processamento"

		If lErrorImp
			fErase( cArqOut )
			Alert(STR0028)  //"Existe dados inválidos. Verifique o Log de Processos desta rotina!"

		ElseIf nLin > 0
			Aviso(STR0007, STR0006, {STR0008}) //"Exportacao de arquivos de beneficios" - "Fim do processamento" - "Ok"

			//Imprime Listagem
			If lImpLis
				fImpLis()
			EndIf

			//Atualizacao do status do historico RG2 
			If cReprocessa == "1"
				If lNovoCalc
					fAtuSR0()
				Else
					fAtuRG2()
				EndIf
			EndIf
		Else
			Aviso(STR0009, STR0010 ,{STR0008}) //"Aviso" - "Não existem registros a serem gravados." - "Ok"
		EndIf
	Else
		nLin := 0
		Aviso(STR0007, STR0011 , {STR0008}) //"Exportacao de arquivos de beneficios" - "Processamento cancelado pelo usuario!" - "Ok"
		oProcess:SaveLog(STR0011)
	EndIf

	RestArea(aArea)
Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} ProcIni

@since 06/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ProcINI(oProcess)
	Local cQuery    := ''
	Local cDemissa  := ''
	Local cPeriodo  := ''
	Local cNumPag   := ''
	Local cTipo     := ''
	Local cFilDe    := ''
	Local cFilAte   := ''
	Local cCcDe     := ''
	Local cCcAte    := ''
	Local cMatDe    := ''
	Local cMatAte   := ''
	Local cPedDe    := ''
	Local cPedAte   := ''
	Local cArqIni   := ""
	Local cFuncVal  := ""
	Local nCount    := 0
	Local nPos      := 0
	Local dAdm      := cTod(" / / ")
	Local aTab      := {}
	Local lCont     := .T.
	Local cMyChave  := ""
	Local nAux      := 0
	Local nTp		     := 0
	Local aForn410  := {}
	Local nLinha
	Local cQryAux
	Local aTemp		:= {}
	Local cSelect	:= ""
	Local cFrom		:= ""
	Local cTipoQry	:= ""
	Private nTipArq   := 1 //Arquivo VA/VR
	Private cForn410 := {}

	Private cCodCli  := ''
	Private cSRA_End := ''
	Private cSRA_Num := ''
	Private cRGC_End := ''
	Private cRGC_Num := ''

	Private cItemCod  := ''
	Private cItemNome := ''

	Private nReg    := 0
	Private nSeq    := 0
	Private dCred   := cTod(" / / ")
	Private aStruct

	Private nTotReg     := 0	//-Qtd.Registros - no arquivo
	Private nTotRegTP1  := 0	//-Qtd.Registros - Tipo 1
	Private nTotRegTP2  := 0	//-Qtd.Registros - Tipo 2
	Private nTotRegTP3  := 0	//-Qtd.Registros - Tipo 3
	Private nTotRegTP4  := 0	//-Qtd.Registros - Tipo 4
	Private nTotRegTP5  := 0	//-Qtd.Registros - Tipo 5
	Private nQtdTotItem := 0
	Private nvlrTotItem := 0

	Private nPosEnd := 0
	Private nSeqEnd := 0
	Private aSeqEnd := {}

	//Carrega Perguntas
	cFornecedor := MV_PAR01                     //Fornecedor selecionado
	cTiposSel   := MV_PAR02                     //Tipos Selecionados
	cPeriodo    := MV_PAR05                     //Periodo
	cNumPag     := MV_PAR06                     //Nro Pagamento
	cFilDe      := MV_PAR07                     //Da Filial
	cFilAte     := MV_PAR08                     //Ate a Filial
	cCcDe       := MV_PAR09                     //Do Centro Custo
	cCcAte      := MV_PAR10                     //Ate Centro de Custo
	cMatDe      := MV_PAR11                     //Da Matricula
	cMatAte     := MV_PAR12                     //Ate Matricula
	dCred       := MV_PAR13                     //Data Credito
	cAdm        := dToS(MV_PAR14)               //Consid.Admitido Ate
	//nTipArq     := MV_PAR17                     //Tipo de Arquivo
	If lNovoCalc
		cPedDe      := MV_PAR17                     //Do Pedido
		cPedAte     := MV_PAR18                     //Ate o Pedido
	EndIf

	If cFilAnt == '0101'
		If Left(cTiposSel,2) $ '86' //VR
			cTipoQry	:= "1"
			nTipArq := 1 
		ELSEIf Left(cTiposSel,2) $ '87' //VA
			cTipoQry	:= "2"
			nTipArq := 1 			
		ElseIf Left(cTiposSel,2) $ '88' 
			nTipArq := 2 //VT
		EndIf
	ElseIf cFilAnt == '0103'
		If Left(cTiposSel,2) $ '89' //VR
			cTipoQry	:= "1"
			nTipArq := 1 
		ElseIf Left(cTiposSel,2) $ '90' //VA
			cTipoQry	:= "2"
			nTipArq := 1 			
		ElseIf Left(cTiposSel,2) $ '91' 
			nTipArq := 2 //VT
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica parametros                                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(cFornecedor)
		Alert(STR0051) //"Parâmetro sobre fornecedor não preenchido!"
		Return
	EndIf
	If Empty(cAdm)
		Alert(STR0052) //"Parâmetro sobre data de admissão não preenchido!"
		Return
	EndIf
	If Empty(cTiposSel)
		Alert(STR0053) //"Parâmetro sobre tipos de beneficio não preenchido!"
		Return
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se foi informado os Arquivos .INI e de Saida                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nLinha  := FPOSTAB("S018", Alltrim(cFornecedor), "==", 4)
	If Empty( cArqIni := Alltrim(FTABELA("S018", nLinha, 08)) )
		Alert(STR0029) //"Arquivo .INI não informado na Tabela Auxiliar S018!"
		Return
	EndIf
	If Empty( cArqOut := Alltrim(FTABELA("S018", nLinha, 09)) )
		Alert(STR0030) //"Arquivo de Saída não informado na Tabela Auxiliar S018"
		Return
	EndIf
	If Empty( cFuncVal := Alltrim(FTABELA("S018", nLinha, 10)) )
		Alert(STR0031) //"Função de Validação não informada na Tabela Auxiliar S018"
		Return
	Else
		If At("(", cFuncVal ) > 0
			Alert(STR0056) //"Função validadora com caracter -()- invalido, na tabela S018"
			Return
		EndIf   
	EndIf
	
	If nTipArq == 2 // Arquivo VT
		cArqIni := "sodexo_vt.ini"
		//cArqOut := "C:\SODEXO\SDXV5_SODEXO_VT.TXT"
	EndIf
	
	If !file( cArqIni )
		Alert(STR0047 +' - ' +cArqIni) //"Arquivo de inicialização não localizado: "
		Return
	EndIf
	If File( cArqOut )
		If Aviso(STR0013 , cArqOut +" - " +STR0048 ,{STR0049,STR0050}) == 1  //"ATENCAO" - "Arquivo Já Existe. Sobrepor?" - "Não","Sim"
			Return
		EndIf
	EndIf

	//Executa funcao padrao para processar arquivo INI
	aStruct := RHProcessaIni(cArqIni)
	/* Estrutura do array de retorno
	aStruct[1] - Header
	aStruct[2] - Detalhes
	aStruct[3] - Trailler

	aStruct[1][1][1] - Header / Primeiro Campo / (1 campo: tipo do registro header)
	aStruct[1][1][2] - Header / Primeiro Campo / (2 campo: descricao do campo)
	aStruct[1][1][3] - Header / Primeiro Campo / (3 campo: tipo do dado)
	aStruct[1][1][4] - Header / Primeiro Campo / (4 campo: tamanho do campo)
	aStruct[1][1][5] - Header / Primeiro Campo / (5 campo: decimais campo numerico)
	aStruct[1][1][6] - Header / Primeiro Campo / (6 campo: valor e conteudo  para o campo)
	*/


	//Cria Arquivo de saida
	nHdl := fCreate(cArqOut)
	If nHdl == -1
		MsgAlert(STR0012,STR0013) //'O arquivo não pode ser criado! Verifique os parametros.' - 'Atenção!'
		Return
	Endif

	//-------------------------------------------------------------------------------------//
	// Codigo 0 - Header do Arquivo	- Identificação da Empresa e do Tipo de Pedido				                                       //
	//-------------------------------------------------------------------------------------//
	nSeq += 1
	fWrite( nHdl, RHGeraLinhas( aStruct[1] ) )

	//-------------------------------------------------------------------------------------//
	// Codigo 3 - Informações para Entrega							                                       //
	//-------------------------------------------------------------------------------------//
	nTotRegTP1 := 1
	If nTipArq == 2
		BeginSQL Alias "TRBSRA"
	
			SELECT DISTINCT SRA.RA_FILIAL,
				SRA.RA_LOCBNF,
				SRA.RA_MAT,
				SRA.RA_CC,
				SRA.RA_NOME,
				SRA.RA_NOMECMP,
				SRA.RA_NASC,
				SRA.RA_CIC,
				SRA.RA_SEXO,
				SRA.RA_RG,
				SRA.RA_RGUF,
				SRA.RA_DTRGEXP,
				SRA.RA_RGORG,
				SRA.RA_ENDEREC,
				SRA.RA_NUMENDE,
				SRA.RA_COMPLEM,
				SRA.RA_BAIRRO,
				SRA.RA_MUNICIP,
				SRA.RA_ESTADO,
				SRA.RA_CEP,
				SRA.RA_MAE,
				SRA.RA_ESTCIVI,
				SRA.RA_EMAIL,
				SRA.RA_DDDFONE,
				SRA.RA_TELEFON,
				RGC.RGC_KEYLOC,
				RGC.RGC_NMRESP,
				RGC.RGC_ENDER,
				RGC.RGC_NUMERO,
				RGC.RGC_BAIRRO,
				RGC.RGC_ESTADO,
				RGC.RGC_CODPOS,
				RGC.RGC_MUNIC,
				CTT.CTT_DESC01,
				SR0.R0_CODIGO,
				SR0.R0_VALCAL,
				SR0.R0_TPVALE,
				SR0.R0_DUTILM,
				SR0.R0_DIASPRO,
				SR0.R0_QDIAINF,
				SR0.R0_QDIACAL,
				SR0.R0_VLRVALE,
				RFP.RFP_PRODSX,
				RFP.RFP_FORMSX,
				RFP.RFP_LINHSX,
				RFP.RFP_CDOPSX
			FROM %TABLE:SRA% SRA	
			JOIN %TABLE:RGC% RGC ON 
				RGC.RGC_KEYLOC = SRA.RA_LOCBNF AND
				RGC.RGC_FILIAL = %Exp:xFilial("RGC")% AND 
				RGC.%NotDel%
			JOIN %TABLE:CTT% CTT ON
				CTT.CTT_FILIAL = SRA.RA_FILIAL AND
				CTT.CTT_CUSTO = SRA.RA_CC AND 
				CTT.%NotDel%
			JOIN %TABLE:SR0% SR0 ON 
				SR0.R0_MAT = SRA.RA_MAT AND
				SR0.R0_FILIAL = SRA.RA_FILIAL AND
				SR0.%NotDel%
			JOIN %TABLE:RFP% RFP ON
				RFP.RFP_FILIAL = %Exp:xFilial("RFP")%
				AND RFP.RFP_CODIGO = SR0.R0_CODIGO
				AND RFP.RFP_PRODSX = '007'
				AND RFP.RFP_FORMSX = '002'
				AND RFP.%NotDel%
			WHERE SRA.%NotDel%
				AND SRA.RA_FILIAL BETWEEN %Exp:cFilDe% AND %Exp:cFilAte%
				AND SRA.RA_CC BETWEEN %Exp:cCcDe% AND %Exp:cCcAte%
				AND SRA.RA_MAT BETWEEN %Exp:cMatDe% AND %Exp:cMatAte%
				AND SRA.RA_ADMISSA <= %Exp:cAdm%
				AND SRA.RA_DEMISSA = ''
				AND SRA.RA_SITFOLH <> 'D'
				AND SR0.R0_VALCAL <> 0
				AND SR0.R0_TPVALE = '0'
				//AND SR0.R0_ANOMES = %Exp:cPeriodo% 
				//AND SR0.R0_PERIOD = %Exp:cPeriodo%
			ORDER BY SRA.RA_CC,
			SRA.RA_LOCBNF
	
		EndSQL
	Else
		BeginSQL Alias "TRBSRA"
	
			SELECT DISTINCT SRA.RA_FILIAL,
				SRA.RA_LOCBNF,
				SRA.RA_MAT,
				SRA.RA_CC,
				SRA.RA_NOME,
				SRA.RA_NOMECMP,
				SRA.RA_NASC,
				SRA.RA_CIC,
				SRA.RA_SEXO,
				SRA.RA_RG,
				SRA.RA_RGUF,
				SRA.RA_DTRGEXP,
				SRA.RA_RGORG,
				SRA.RA_ENDEREC,
				SRA.RA_NUMENDE,
				SRA.RA_COMPLEM,
				SRA.RA_BAIRRO,
				SRA.RA_MUNICIP,
				SRA.RA_ESTADO,
				SRA.RA_CEP,
				SRA.RA_MAE,
				SRA.RA_ESTCIVI,
				SRA.RA_EMAIL,
				SRA.RA_DDDFONE,
				SRA.RA_TELEFON,
				RGC.RGC_KEYLOC,
				RGC.RGC_NMRESP,
				RGC.RGC_ENDER,
				RGC.RGC_NUMERO,
				RGC.RGC_BAIRRO,
				RGC.RGC_ESTADO,
				RGC.RGC_CODPOS,
				RGC.RGC_MUNIC,
				CTT.CTT_DESC01,
				SR0.R0_CODIGO,
				SR0.R0_VALCAL,
				SR0.R0_TPVALE,
				SR0.R0_DUTILM,
				SR0.R0_DIASPRO,
				SR0.R0_QDIAINF,
				SR0.R0_QDIACAL,
				SR0.R0_VLRVALE,
				RFP.RFP_PRODSX,
				RFP.RFP_FORMSX,
				RFP.RFP_LINHSX,
				RFP.RFP_CDOPSX
			FROM %TABLE:SRA% SRA	
			JOIN %TABLE:RGC% RGC ON 
				RGC.RGC_FILIAL = %Exp:xFilial("RGC")%
				AND RGC.RGC_KEYLOC = SRA.RA_LOCBNF
				AND RGC.%NotDel%
			JOIN %TABLE:CTT% CTT ON
				CTT.CTT_FILIAL = SRA.RA_FILIAL
				AND CTT.CTT_CUSTO = SRA.RA_CC
				AND CTT.%NotDel%
			JOIN %TABLE:SR0% SR0 ON 
				SR0.R0_MAT = SRA.RA_MAT
				AND SR0.R0_FILIAL = SRA.RA_FILIAL
				AND SR0.%NotDel%
			JOIN %TABLE:RFP% RFP ON
				RFP.RFP_FILIAL = %Exp:xFilial("RFP")%
				AND RFP.RFP_CODIGO = SR0.R0_CODIGO
				AND RFP.RFP_TPBEN = %Exp:LEFT(MV_PAR02,2)%
				AND RFP.%NotDel%
			WHERE SRA.%NotDel%
				AND SRA.RA_FILIAL BETWEEN %Exp:cFilDe% AND %Exp:cFilAte%
				AND SRA.RA_CC BETWEEN %Exp:cCcDe% AND %Exp:cCcAte%
				AND SRA.RA_MAT BETWEEN %Exp:cMatDe% AND %Exp:cMatAte%
				AND SRA.RA_ADMISSA <= %Exp:cAdm%
				AND SRA.RA_DEMISSA = ''
				AND SRA.RA_SITFOLH <> 'D'
				AND SR0.R0_VALCAL <> 0
				AND SR0.R0_TPVALE = %Exp:cTipoQry%
				AND RFP.RFP_PRODSX <> '007'
				AND RFP.RFP_FORMSX <> '002'
				//AND SR0.R0_ANOMES = %Exp:cPeriodo% 
				//AND SR0.R0_PERIOD = %Exp:cPeriodo%
			ORDER BY SRA.RA_CC,
			SRA.RA_LOCBNF
	
		EndSQL
	EndIf
	cColigada := TRBSRA->RA_LOCBNF
	cCCusto := TRBSRA->RA_CC

	nSeq += 1
	fWrite( nHdl, RHGeraLinhas( aStruct[2], "01" ) )

	//-------------------------------------------------------------------------------------//
	// Codigo 4 - Informações do Colaborador e Benefícios Solicitados			                                       //
	//-------------------------------------------------------------------------------------//
	nTotRegTP2 := 0

	nSeqEnd := 0
	aSeqEnd := {}

	While !TRBSRA->(EOF()) 
		// VERIFICA SE MUDOU O CENTRO DE CUSTO OU O LOCAL DO BENEFICIO
		If (cColigada #  TRBSRA->RA_LOCBNF .OR. cCCusto # TRBSRA->RA_CC)

			cColigada :=  TRBSRA->RA_LOCBNF 
			cCCusto := TRBSRA->RA_CC

			// REGISTRO 003 POR C. CUSTO
			fWrite( nHdl, RHGeraLinhas( aStruct[2], "01" ) )

		Endif

		//Grava Detalhes
		nTotRegTP2 += 1
		nSeq += 1
		fWrite( nHdl, RHGeraLinhas( aStruct[2], "02" ) )

		TRBSRA->(dbSkip())
	EndDo

	//-------------------------------------------------------------------------------------//
	// Codigo 9 - Trailler do Arquivo				                                       //
	//-------------------------------------------------------------------------------------//
	nTotReg := nSeq+1

	nSeq    += 1
	fWrite( nHdl, RHGeraLinhas( aStruct[3] ) )

	//TRBSRA->(dbClosearea())

	nLin += 1	//-Indica que pode imprimir o Relatorio Final

Return


	//-------------------------------------------------------------------
	/*/{Protheus.doc} Funcoes diversas relatorio /*/
//-------------------------------------------------------------------
Static Function fImpLis()
	//Inicia Variaveis
	Private cString  := '' // Alias do Arquivo Principal
	Private aOrd     := {""}
	Private aReturn  := { STR0015, 1, STR0016, 1, 2, 2,'',1 } //"Especial" - "Administra‡„o"
	Private nTamanho := 'P'
	Private cPerg    := ''
	Private wCabec0  := 2
	Private wCabec1  := STR0042 +space(02) +STR0043 +space(04) +STR0044 +space(30) +STR0045 +space(5) +STR0046
	// 'Filial  Matricula  Nome                  TP Benef.  Valor Benef.'
	Private wCabec2  := ''
	Private NomeProg := 'BENEFARQ'
	Private nLastKey := 0
	Private m_pag    := 0
	Private Li       := 0
	Private ContFl   := 1
	Private nOrdem   := 0
	Private nChar    := 0
	Private lEnd     := .F.
	Private wnrel    := 'BENEFARQ'

	//Envia controle para a funcao SETPRINT
	wnrel := SetPrint(cString,wnrel,"",STR0017,STR0018,STR0019,,.F.,aOrd,.F.,nTamanho) //'LISTAGEM DE BENEFICIOS' - 'Emissao de Relatorio para avaliacao de Benefícios. ' - 'Sera impresso de acordo com os parametros solicitados. '

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	//Processa Impressao
	RptStatus({|lEnd| fImpNota()},STR0021) //'Imprimindo...'

	
Return

Static Function fImpNota()
	//Inicia Variaveis
	Local cFilialAnt    := ''
	Local cCcAnt        := ''
	Local nTfunc        := 0
	Local nTccFunc      := 0
	Local nTFlFunc      := 0
	Local nTBen         := 0
	Local nTccBen       := 0
	Local nTFlBen       := 0
	Local nI			:= 1
	Local nPos			:= 0
	Local cFilReg		:= ""

	// Posiciona Regitro
	//dbSelectArea("QD03VB")
	TRBSRA->(DbGoTop())

	//Set Regua
	SetRegua(0)

	//Se Ordem Centro de Custo Imprime Nome Centro de Custo
	If nOrd == 2
		dbSelectArea("CTT")
		dbSetOrder(1)	//-CTT_FILIAL+CTT_CUSTO
		dbSeek(xFilial("CTT")+TRBSRA->RA_CC,.F.)

		cDet := Space(5) + AllTrim(TRBSRA->RA_CC) + " - " + CTT->CTT_DESC01
		Impr(cDet,'C')
	Endif

	//Carrega Filial
	If lNovoCalc
		cFilialAnt := TRBSRA->RA_FILIAL
	Else
		cFilialAnt := TRBSRA->RG2_FILIAL
	EndIf

	While !TRBSRA->(Eof())

		If lNovoCalc
			cFilReg := TRBSRA->RA_FILIAL
		Else
			cFilReg := TRBSRA->RG2_FILIAL
		EndIf


		//Abortado Pelo Operador
		If lAbortPrint
			cDet := STR0020 //'*** ABORTADO PELO OPERADOR ***'
			Impr(cDet,'C')
			Exit
		EndIF

		If lNovoCalc
			nVlr := TRBSRA->R0_VLRVALE
			cDet := TRBSRA->RA_FILIAL + Space(2) + TRBSRA->RA_MAT + Space(2) + TRBSRA->RA_NOME + Space(10) + TRBSRA->R0_TPVALE + Space(9) +Transform(nVlr,'@E 999,999.99')
			Impr(cDet,'C')		
		/*	nPos := Ascan(aItens,{|x| x[1]==TRBSRA->RA_FILIAL+TRBSRA->RA_MAT})
			For nI := 1 To Len(aItens[nPos][2])
				//	aItens == QD05VB->R0_TPVALE,QD05VB->R0_CODIGO,QD05VB->R0_QDIACAL,QD05VB->R0_VALCAL,
				//QD05VB->R0_VLRVALE,QD05VB->R0_VLRFUNC,QD05VB->R0_VLREMP,cItemCod,cItemNome

				nVlr := aItens[nPos][2][nI][2]
				cDet := TRBSRA->RA_FILIAL + Space(2) + TRBSRA->RA_MAT + Space(2) + TRBSRA->RA_NOME + Space(10) + aItens[nPos][2][nI][1] + Space(9) +Transform(nVlr,'@E 999,999.99')
				Impr(cDet,'C')
			Next nI*/
		Else
			nVlr := TRBSRA->RG2_VALCAL
			cDet := TRBSRA->RG2_FILIAL + Space(2) + TRBSRA->RG2_MAT + Space(2) + TRBSRA->RA_NOME + Space(10) + TRBSRA->RG2_TPBEN + Space(9) +Transform(nVlr,'@E 999,999.99')
			Impr(cDet,'C')
		EndIf
		TRBSRA->(dbSkip())

		IncRegua(STR0021)

		//Totaliza
		nTfunc   += 1
		nTccFunc += 1
		nTFlFunc += 1
		nTBen    += nVlr
		nTccBen  += nVlr
		nTFlBen  += nVlr

		If nOrd == 2
			If cCcAnt != TRBSRA->RA_CC .Or. cFilialAnt != cFilReg
				cCcAnt := TRBSRA->RA_CC

				cDet := STR0022 + Space(10) + Transform(nTccBen,'@E 999,999,999.99') //'Valores Totais Centro de Custo: '
				Impr(cDet,'C')

				cDet := STR0023 + Space(10)  + Transform(nTccFunc, '@E 9,999') //'Quantidade de lançamentos Centro Custo: '
				Impr(cDet,'C')
				cDet := ''
				Impr(cDet,'C')

				nTccFunc := 0
				nTccBen  := 0

				If !TRBSRA->(Eof()) .And. cFilialAnt == cFilReg
					dbSelectArea("CTT")
					dbSetOrder(1)	//-CTT_FILIAL+CTT_CUSTO
					dbSeek(xFilial("CTT")+TRBSRA->RA_CC,.F.)

					cDet := Space(5) + AllTrim(TRBSRA->RA_CC) + " - " + CTT->CTT_DESC01
					Impr(cDet,'C')
				Endif

			Endif
		Endif

		If cFilialAnt != cFilReg
			cFilialAnt := cFilReg

			//Imprime Totais
			Impr('','C')

			cDet := STR0024 + Space(10) + Transform(nTFlBen,'@E 999,999,999.99') //'Valores Totais da Filial: '
			Impr(cDet,'C')

			cDet := STR0025 + Transform(nTFlFunc, '@E 9,999') //'Quantidade de lancamentos da Filial: '
			Impr(cDet,'C')

			//Salta Página
			cDet := ''
			Impr(cDet,'F')

			nTFlFunc := 0
			nTFlBen  := 0

			If !TRBSRA->(Eof())
				dbSelectArea("CTT")
				dbSetOrder(1)	//-CTT_FILIAL+CTT_CUSTO
				dbSeek(xFilial("CTT")+TRBSRA->RA_CC,.F.)

				cDet := Space(5) + AllTrim(TRBSRA->RA_CC) + " - " + CTT->CTT_DESC01
				Impr(cDet,'C')
			Endif

		Endif

	EndDo

	//Totaliza
	Impr('','C')

	cDet := STR0026 + Space(30) + Transform(nTBen,'@E 999,999,999.99') //'Valores Totais da Empresa: '
	Impr(cDet,'C')

	cDet := STR0027 + Transform(nTfunc, '@E 9,999') //'Quantidade de lançamentos da Empresa: '
	Impr(cDet,'C')

	cDet := ''
	Impr(cDet,'F')

	If aReturn[5] == 1
		Set Printer to
		Ourspool(wnrel)
	Endif

	MS_FLUSH()

	TRBSRA->(dbClosearea())
	Return

	//-------------------------------------------------------------------
	/*/{Protheus.doc} Funcoes diversas configuracao /*/
//-------------------------------------------------------------------
Static Function fFormatDate(dData)
	Local cRet:= Day2Str(dData) + "/" + Month2Str(dData) + "/" + Year2Str(dData)
	Return cRet


	//-------------------------------------------------------------------
	/*/{Protheus.doc} Funcao de Validacao dos Funcionarios            /*/
//-------------------------------------------------------------------
Static Function VBValida(oProcess, cMyAlias)

	Local lRetErr := .T.
	Default cMyAlias := "SRA"

	If Empty( (cMyAlias)->RA_CEP )
		lRetErr := .F.
		oProcess:SaveLog( STR0032 +(cMyAlias)->RA_FILIAL + STR0033 +(cMyAlias)->RA_MAT + STR0034 ) //"Filial: ", " - Matricula: ", " - Funcionário com campo RA_CEP em branco."  
	EndIf
	If Empty( (cMyAlias)->RA_CIC )
		lRetErr := .F.
		oProcess:SaveLog( STR0032 +(cMyAlias)->RA_FILIAL + STR0033 +(cMyAlias)->RA_MAT + STR0035 ) //"Filial: ", " - Matricula: ", " - Funcionário com campo RA_CIC em branco."
	EndIf
	If Empty( (cMyAlias)->RA_RG )
		lRetErr := .F.
		oProcess:SaveLog( STR0032 +(cMyAlias)->RA_FILIAL + STR0033 +(cMyAlias)->RA_MAT + STR0036 ) //"Filial: ", " - Matricula: ", " - Funcionário com campo RA_RG em branco." 
	EndIf
	If Empty( (cMyAlias)->RA_MAE )
		lRetErr := .F.
		oProcess:SaveLog( STR0032 +(cMyAlias)->RA_FILIAL + STR0033 +(cMyAlias)->RA_MAT + STR0037 ) //"Filial: ", " - Matricula: ", " - Funcionário com campo RA_MAE em branco."
	EndIf
	If Empty( (cMyAlias)->RA_ENDEREC )
		lRetErr := .F.
		oProcess:SaveLog( STR0032 +(cMyAlias)->RA_FILIAL + STR0033 +(cMyAlias)->RA_MAT + STR0038 ) //"Filial: ", " - Matricula: ", " - Funcionário com campo RA_ENDEREC em branco." 
	EndIf
	If Empty( (cMyAlias)->RA_COMPLEM )
		lRetErr := .F.
		oProcess:SaveLog( STR0032 +(cMyAlias)->RA_FILIAL + STR0033 +(cMyAlias)->RA_MAT + STR0039 ) //"Filial: ", " - Matricula: ", " - Funcionário com campo RA_COMPLEM em branco."
	EndIf
	If Empty( (cMyAlias)->RA_MUNICIP )
		lRetErr := .F.
		oProcess:SaveLog( STR0032 +(cMyAlias)->RA_FILIAL + STR0033 +(cMyAlias)->RA_MAT + STR0040 ) //"Filial: ", " - Matricula: ", " - Funcionário com campo RA_MUNICIP em branco." 
	EndIf
	If Empty( (cMyAlias)->RA_ESTADO )
		lRetErr := .F.
		oProcess:SaveLog( STR0032 +(cMyAlias)->RA_FILIAL + STR0033 +(cMyAlias)->RA_MAT + STR0041 ) //"Filial: ", " - Matricula: ", " - Funcionário com campo RA_ESTADO em branco."
	EndIf
	If Empty( (cMyAlias)->RA_LOCBNF )
		lRetErr := .F.
		oProcess:SaveLog( STR0032 +(cMyAlias)->RA_FILIAL + STR0033 +(cMyAlias)->RA_MAT + STR0055 ) //"Filial: ", " - Matricula: ", " - Funcionário com o Codigo do Local de Entrega (RA_LOCBNF) em branco."
	EndIf

	If !lRetErr
		lImpLis   := .F.
		lErrorImp := .T.
	EndIf

	Return

	//-------------------------------------------------------------------
	/*/{Protheus.doc} Atualiza status RG2                             /*/
//-------------------------------------------------------------------
Static Function fAtuRG2()
/*
	// Posiciona Regitro
	dbSelectArea("QD03VB")
	QD03VB->(DbGoTop())

	While QD03VB->(!Eof())

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//  Atualizar arquivo de histórico de benefícios                                  
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("RG2")
		DbSetOrder ( RetOrder ("RG2", "RG2_FILIAL+RG2_PERIOD+RG2_NROPGT+RG2_TPVALE+RG2_CODIGO" ))
		If dbSeek( QD03VB->RG2_FILIAL + QD03VB->RG2_MAT + QD03VB->RG2_ANOMES + QD03VB->RG2_TPVALE + QD03VB->RG2_CODIGO )
			RecLock("RG2",.F.)
			RG2->RG2_PEDIDO := 2
			MsUnlock()
		EndIf

		QD03VB->(dbSkip())
	Enddo
*/
Return

	//-------------------------------------------------------------------
	/*/{Protheus.doc} Atualiza status SR0                            /*/
//-------------------------------------------------------------------
Static Function fAtuSR0()
Local cQuery := "" 
Local cTmp	:= GetNextAlias()


cQuery := " SELECT SR0.R_E_C_N_O_ AS RECSR0 FROM SR0010 SR0 "
cQuery += "WHERE R0_FILIAL = '" + xFilial('SR0') + "' "
cQuery += "AND   R0_MAT BETWEEN  '" +MV_PAR11 + "' AND '"  +MV_PAR12 + "' "
cQuery += "AND   R0_PERIOD = '" +MV_PAR05 + "'  " 
cQuery += "AND   R0_TPBEN = '" +MV_PAR02 + "'  "
cQuery += "AND   SR0.D_E_L_E_T_ = ' '  "
DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery), cTmp, .T., .F.)

While (cTmp)->(!Eof())
	SR0->(dbGoto((cTmp)->RECSR0))
	RecLock("SR0",.F.)
	SR0->R0_PEDIDO := '2'
	SR0->(MsUnlock())

	(cTmp)->(dbSkip())
Enddo
(cTmp)->(dbCloseArea())

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	    ³ BenefValid³ Autor ³ Tatiane Matias        ³ Data ³01/12/04³±±
±±³ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida os campos periodo e numero de	pagamento da pergunte.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cChave 	- Chave de pesquisa (RCH)  						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Pergunte ARQBENEF - campos Processo (MV_PAR04), 			  ³±±
±±³    		 ³                   Periodo (MV_PAR05) e ³±±
±±³    		 ³                   Numero de Pagamento (MV_PAR06).          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */
Static Function BenefValid(cChave)

	Local cReadVar	:= Upper( AllTrim( ReadVar() ) )
	Local cRoteiro 
	Local lTipoAut
	Local lRet 		:= .T.                   
	Local nPerNumPg
	Local nFilProces
	Local nTamRoteiro

	If Substr(cReadVar, 1, 3) == "M->"
		cReadVar := Substr(cReadVar,4)
	EndIf

	If cReadVar == "MV_PAR04"
		lRet 	   := ExistCpo("RCJ", cChave)
		cProcesso := (cReadVar == "MV_PAR06" .AND. mv_par06 == "99")
		cRoteiro := fGetRotOrdinar()
		If cRoteiro <> "EXT"	       
			DbSelectArea( "RCH" )
			DbSetOrder( 4 ) // RCH_FILIAL + RCH_PROCESSO + RCH_ROTEIRO + RCH_PERIODO + RCH_NUMPAG
			cChave:=(MV_PAR04+Space(5-Len(MV_PAR04))+cRoteiro+MV_PAR05+MV_PAR06)
			cChave := xFilial( "RCH" ) + cChave
			DbSeek( cChave, .F. ) 
			If Eof()
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Tratamento de Autonomos - Permite Nro. Pagto nao cadastrado  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nFilProces 	:= GetSx3Cache( "RCH_FILIAL", "X3_TAMANHO" ) + GetSx3Cache( "RCH_PROCES", "X3_TAMANHO" )
				nTamRoteiro	:= GetSx3Cache( "RCH_ROTEIR", "X3_TAMANHO" )
				//cRoteiro 	:= Substr(cChave, nFilProces+1, nTamRoteiro)
				nPerNumPg 	:= nFilProces + Len( cRoteiro ) + 1
				lTipoAut 	:= ( fGetTipoRot( cRoteiro ) == "9" )
				DbSelectArea("RCH")
				If lTipoAut
					DbSeek( Substr( cChave, 1, nFilProces ) + cRoteiro + Substr( cChave, nPerNumPg ) , .F. )
				EndIf
				If Eof()
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Pesquisar Periodo sem roteiro de calculo.                    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cRoteiro := Space( nTamRoteiro )
					cChave := Substr( cChave, 1, nFilProces ) + cRoteiro + Substr( cChave, nPerNumPg )
					DbSeek( cChave, .F. )
					If Eof()
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Tratamento de Autonomos - Permite Nro. Pagto nao cadastrado  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lTipoAut
							cChave := Substr( cChave, 1, nFilProces ) + cRoteiro
							DbSeek( cChave, .F. )
							If Eof()
								lTipoAut := .F.
							EndIf
						EndIf
						If !lTipoAut
							Help( " ", 1, "REGNOIS" )
							lRet 	 := .F.
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

Return ( lRet )
//-------------------------------------------------------------------
/*/{Protheus.doc} Funcoes diversas configuracao /*/
//-------------------------------------------------------------------
User Function BENEFOp()
Local MvPar
Local MvParDef := ""
Local aItens   := {}
Local aArea    := GetArea()

MvPar := &(Alltrim(ReadVar()))       // Carrega Nome da Variavel do Get em Questao
MvRet := Alltrim(ReadVar())          // Iguala Nome da Variavel ao Nome variavel de Retorno

dbSelectArea("RCC")
dbSetOrder(RetOrder("RCC","RCC_FILIAL+RCC_CODIGO+RCC_FIL+RCC_CHAVE+RCC_SEQUEN"))
dbSeek(xFilial("RCC")+"S011")
While !Eof() .And. RCC->RCC_FILIAL + RCC->RCC_CODIGO == xFilial("RCC")+"S011"
	
	If Substr(RCC->RCC_CONTEU,33,3) == alltrim(MV_PAR01)
		aAdd(aItens, Substr(RCC->RCC_CONTEU,3,30))
		MvParDef += Substr(RCC->RCC_CONTEU,1,2)
	EndIf
	
	("RCC")->(dbSkip())
End

//         Retorno,Titulo,opcoes,Strin Ret,lin,col, Tipo Sel,tam chave , n. ele ret, Botao
IF f_Opcoes(@MvPar, STR0017, aItens, MvParDef, 12, 49, .F., 2)  // "Opções"
	&MvRet := Strtran(MvPar,'*','')                                      // Devolve Resultado
EndIF

RestArea(aArea)                                  // Retorna Alias
Return MvParDef

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³gpRCHArqB  ³Autor³Cecilia Carvalho          ³Data³30/10/2013³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Filtro da Consulta Padrao								 	³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide Parametros Formais>									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                                             				³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³Consulta Padrao (SXB)				                  	   	³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
User Function gpRCHArq()
Local cFiltro		:= "(RCH->RCH_FILIAL == '" + xFilial("RCH") + "')"
Local cRotFiltro	:= ""
	
DbSelectArea("SRY")
DbSetOrder(1)  
dbSeek(xFilial("SRY"))
While (!Eof()) .And. (SRY->RY_FILIAL == xFilial("SRY") )
	If 	!Empty(SRY->RY_TIPO) .AND. 	(SRY->RY_TIPO == '8' .OR. SRY->RY_TIPO == 'D' .OR. SRY->RY_TIPO == 'E') 
		If Len(cRotFiltro)= 0
			cRotFiltro += " .AND. (RCH->RCH_ROTEIR == '" + SRY->RY_CALCULO + "'"
		Else
			cRotFiltro += " .OR. RCH->RCH_ROTEIR == '" + SRY->RY_CALCULO + "'"
		EndIf
	EndIf
	dbSkip()
EndDo
cRotFiltro	:= IIf ( Len(cRotFiltro) > 0,cRotFiltro + ")","") 

cFiltro	+= cRotFiltro 	
cFiltro := "@#" + cFiltro + "@#"

Return ( cFiltro )

User Function CalCred(nValor)
 
 	Local cValor := ""
 	
 	Default nValor = 0
 	
 	cValor := Str(nValor,10,2)
 	cValor := StrTran(cValor,".","")

 	If Len(cValor) < 12
 		cValor := Space(12-Len(cValor) ) + cValor
 	Endif 
 
 return cValor
 
 #include 'protheus.ch'

/*/{Protheus.doc} SPRATU18
Função que retorna o código da Sodexo conforme empresa/filial logada
@type function
@author Janaina de Jesus
@since 25/07/2019
@version 1.0
@return nRet, Código do Cliente Sodexo
@example
(examples)
@see (links_or_references)
/*/
User Function SPRATU18()
	Local nRet := 0
	
	If cFilAnt $ "0101"
		nRet := StrZero(1205533,8)
	ElseIf cFilAnt $ "0103"
		nRet := StrZero(1432442,8)
	ElseIf cFilAnt $ "0104"
		nRet := StrZero(1731430,8)		
	EndIf
Return nRet
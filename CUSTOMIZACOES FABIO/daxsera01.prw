#include 'protheus.ch'
#include 'parmtype.ch'
#include 'topconn.ch'

//--------------------------------------------------------------
/*/{Protheus.doc} EXFINA05()

Gera informações de titulos em arquivo txt para envio ao serasa.

@param xParam Parameter DescriptionuSER
@return xRet Return Description
@author Fabio Costa - TOTVS - costa.fabio@totvs.com.br
@since 18/07/2019

u_EXFINA05()


/*/

User Function dxser1()   //daxser1()

	Local _oProcess
	Local _aAreaMem := GetArea()
	Local _bProcess := {|_oSelf| EXECUTA(_oSelf) }
	Local cPerg    := "X_SER"
	Local _aInfo    := {}
	_oProcess := tNewProcess():New("daxsera01", "Serasa relato", _bProcess, "Rotina responsável pela geração do arquivo semanal Serasa relato.", cPerg, _aInfo, .T., 5, "Gera arquivo Serasa relato.", .T.)
	RestArea(_aAreaMem)

Return

Static Function EXECUTA(_oRegua)

	Local _cPasta1  := 'c:\temp\'
	Local _cPasta2  := 'Serasa Reciprocidade\'
	Local _cArqTxt  := 'serasa_reciprocidade_' + DToS(dDataBase) + '_' + StrTran(Time(), ':', '') + '.txt'
	Local _nHdl     := 0
	Local _cQuery   := ''
	Local _cCNPJ    := ''
	Local _nCNPJ    := 0
	Local _nTitulos := 0
	Local _cDtIni   := DToS(dDataBase - 6) //Periodo Semanal
	Local _cDtFim   := DToS(dDataBase)
	Local _cTipCli  := ''
	Local _aTipoTit := Separa(SuperGetMV('MV_TIPSERA',, 'NF'), ';') // Tipos de titulos separados por ponto e virgula.
	Local _cTipos   := ''
	Local _nT       := 0

	//If SA1->(FieldPos('A1_XSERASA')) == 0 .Or. SE1->(FieldPos('E1_XSERASA')) == 0
	//	Alert('Por favor, criar os campos A1_XSERASA e E1_XSERASA.')
	//	Return
	//EndIf

	//MakeDir(_cPasta1)
	//MakeDir(_cPasta1 + _cPasta2)
	//_nHdl := FCreate(_cPasta1 + _cPasta2 + _cArqTxt, 0)
	_nHdl := FCreate( AllTrim( mv_par03 ) )

	If _nHdl == -1
		MsgInfo("Ocorreu um erro na criação do arquivo. Por favor, tente novamente.")
	Else
		If Len(_aTipoTit) > 0
			For _nT := 1 To Len(_aTipoTit)
				If _nT > 1
					_cTipos += ", "
				EndIf
				_cTipos += "'" + AllTrim(_aTipoTit[_nT]) + "'"
			Next _nT
		EndIf

		// Titulos ativos e em aberto.
		_cQuery := "SELECT A1_CGC, A1_DTNASC, A1_PRICOM , A1_DTCAD, E1_VENCTO, E1_EMISSAO, " + CRLF
		_cQuery += "E1_VALOR VALOR, E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, '        ' BAIXA, " + CRLF
		_cQuery += "A1_MSBLQL, E1_SALDO SALDO, 'S' TITATIVO, '01' SEQ, A1_COD, A1_LOJA, " + CRLF   ///A1_XSERASA
		_cQuery += "SA1.R_E_C_N_O_ RECSA1, SE1.R_E_C_N_O_ RECSE1, 0 RECSE5 " + CRLF
		_cQuery += "FROM " + RetSqlName('SE1') + " SE1 " + CRLF
		_cQuery += "INNER JOIN " + RetSqlName('SA1') + " SA1 ON " + CRLF
		_cQuery += "SA1.D_E_L_E_T_ = '' " + CRLF
		_cQuery += "AND SA1.A1_FILIAL = '" + xFilial('SA1') + "' " + CRLF
		_cQuery += "AND SA1.A1_COD = SE1.E1_CLIENTE " + CRLF
		_cQuery += "AND SA1.A1_LOJA = SE1.E1_LOJA " + CRLF
		_cQuery += "AND SA1.A1_PESSOA = 'J' " + CRLF // Somente pessoa juridica.
		_cQuery += "WHERE " + CRLF
		_cQuery += "SE1.D_E_L_E_T_ = '' " + CRLF
		_cQuery += "AND SE1.E1_FILIAL = '" + xFilial('SE1') + "' " + CRLF
		_cQuery += "AND SE1.E1_TIPO NOT IN ('NCC', 'RA ', 'PR ') " // Retira recebimento antecipado, nota de crédito do cliente e titulo provisório.
		_cQuery += "AND SE1.E1_TIPO IN (" + _cTipos + ") " + CRLF // Considera somente os tipos de titulos do parametro SE_TIPSERA.
		_cQuery += "AND SE1.E1_CLIENTE BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' " 
		_cQuery += "AND SE1.E1_SALDO > 0 " + CRLF // Tratamento para titulos em aberto.
		_cQuery += "AND SE1.E1_EMISSAO >= '" + _cDtIni + "' " + CRLF
		_cQuery += "AND SE1.E1_EMISSAO <= '" + _cDtFim + "' " + CRLF
		//_cQuery += "AND SE1.E1_XSERASA IN (' ', 'N') " + CRLF // Somente titulos não enviados.

		_cQuery += "UNION ALL " + CRLF

		// Baixas de titulos.
		_cQuery += "SELECT A1_CGC, A1_DTNASC, A1_PRICOM , A1_DTCAD, E1_VENCTO, E1_EMISSAO, " + CRLF
		_cQuery += "E5_VALOR VALOR, E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E5_DATA BAIXA, " + CRLF
		_cQuery += "A1_MSBLQL, E1_SALDO SALDO, 'S' TITATIVO, E5_SEQ SEQ, A1_COD, A1_LOJA, " + CRLF   //A1_XSERASA
		_cQuery += "SA1.R_E_C_N_O_ RECSA1, SE1.R_E_C_N_O_ RECSE1, SE5.R_E_C_N_O_ RECSE5 " + CRLF
		_cQuery += "FROM " + RetSqlName('SE1') + " SE1 " + CRLF
		_cQuery += "INNER JOIN " + RetSqlName('SA1') + " SA1 ON " + CRLF
		_cQuery += "SA1.D_E_L_E_T_ = '' " + CRLF
		_cQuery += "AND SA1.A1_FILIAL = '" + xFilial('SA1') + "' " + CRLF
		_cQuery += "AND SA1.A1_COD = SE1.E1_CLIENTE " + CRLF
		_cQuery += "AND SA1.A1_LOJA = SE1.E1_LOJA " + CRLF
		_cQuery += "AND SA1.A1_PESSOA = 'J' " + CRLF // Somente pessoa juridica.
		_cQuery += "INNER JOIN " + RetSqlName('SE5') + " SE5 ON " + CRLF
		_cQuery += "SE5.D_E_L_E_T_ = '' " + CRLF
		_cQuery += "AND SE5.E5_FILIAL = '" + xFilial('SE5') + "' " + CRLF
		_cQuery += "AND SE5.E5_NUMERO = SE1.E1_NUM " + CRLF
		_cQuery += "AND SE5.E5_PREFIXO = SE1.E1_PREFIXO " + CRLF
		_cQuery += "AND SE5.E5_TIPO = SE1.E1_TIPO " + CRLF
		_cQuery += "AND SE5.E5_PARCELA = SE1.E1_PARCELA " + CRLF
		_cQuery += "AND SE5.E5_CLIFOR = SE1.E1_CLIENTE " + CRLF
		_cQuery += "AND SE5.E5_LOJA = SE1.E1_LOJA " + CRLF
		_cQuery += "AND SE5.E5_DATA >= '" + _cDtIni + "' " + CRLF
		_cQuery += "AND SE5.E5_DATA <= '" + _cDtFim + "' " + CRLF
		//_cQuery += "AND SE5.E5_XSERASA IN (' ', 'N') " + CRLF // Somente baixas não enviadas.
		_cQuery += "WHERE " + CRLF
		_cQuery += "SE1.D_E_L_E_T_ = '' " + CRLF
		_cQuery += "AND SE1.E1_FILIAL = '" + xFilial('SE1') + "' " + CRLF
		_cQuery += "AND SE1.E1_TIPO NOT IN ('NCC', 'RA ', 'PR ') " // Retira recebimento antecipado, nota de crédito do cliente e titulo provisório.
		_cQuery += "AND SE1.E1_TIPO IN (" + _cTipos + ") " + CRLF // Considera somente os tipos de titulos do parametro SE_TIPSERA.
		_cQuery += "AND SE1.E1_CLIENTE BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
		///_c//Query += "AND SE1.E1_XSERASA = 'S' " + CRLF

		_cQuery += "UNION ALL " + CRLF

		// Titulos cancelados.
		_cQuery += "SELECT A1_CGC, A1_DTNASC, A1_PRICOM , A1_DTCAD, E1_VENCTO, E1_EMISSAO, " + CRLF
		_cQuery += "E1_VALOR VALOR, E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_BAIXA BAIXA, " + CRLF
		_cQuery += "A1_MSBLQL, E1_SALDO SALDO, 'N' TITATIVO, '01' SEQ, A1_COD, A1_LOJA, " + CRLF   //A1_XSERASA
		_cQuery += "SA1.R_E_C_N_O_ RECSA1, SE1.R_E_C_N_O_ RECSE1, 0 RECSE5 " + CRLF
		_cQuery += "FROM " + RetSqlName('SE1') + " SE1 " + CRLF
		_cQuery += "INNER JOIN " + RetSqlName('SA1') + " SA1 ON " + CRLF
		_cQuery += "SA1.D_E_L_E_T_ = '' " + CRLF
		_cQuery += "AND SA1.A1_FILIAL = '" + xFilial('SA1') + "' " + CRLF
		_cQuery += "AND SA1.A1_COD = SE1.E1_CLIENTE " + CRLF
		_cQuery += "AND SA1.A1_LOJA = SE1.E1_LOJA " + CRLF
		_cQuery += "AND SA1.A1_PESSOA = 'J' " + CRLF // Somente pessoa juridica.
		_cQuery += "WHERE " + CRLF
		_cQuery += "SE1.D_E_L_E_T_ = '*' " + CRLF // Registros deletados.
		_cQuery += "AND SE1.E1_FILIAL = '" + xFilial('SE1') + "' " + CRLF
		_cQuery += "AND SE1.E1_TIPO NOT IN ('NCC', 'RA ', 'PR ') " // Retira recebimento antecipado, nota de crédito do cliente e titulo provisório.
		_cQuery += "AND SE1.E1_TIPO IN (" + _cTipos + ") " + CRLF // Considera somente os tipos de titulos do parametro SE_TIPSERA.
		_cQuery += "AND SE1.E1_EMISSAO >= '" + _cDtIni + "' " + CRLF
		_cQuery += "AND SE1.E1_EMISSAO <= '" + _cDtFim + "' " + CRLF
		_cQuery += "AND SE1.E1_CLIENTE BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
		///_cQuery += "AND SE1.E1_XSERASA = 'S' " + CRLF // Somente titulos já enviados ao Serasa.

		_cQuery += "ORDER BY A1_CGC" + CRLF
		MemoWrite('c:\temp\Daxia\daxsera01.sql', _cQuery)
		TcQuery _cQuery New Alias 'daxsera01'

		daxsera01->(DbGoTop())

		If daxsera01->(!EOF())

			// MOVIMENTO ENVIADO PELA EMPRESA À SERASA.
			HEADER01(_nHdl, _cDtIni, _cDtFim)

			While daxsera01->(!EOF())

				_cCNPJ := daxsera01->A1_CGC

				/*
				If daxsera01->A1_XSERASA == 'N' .Or. Empty(daxsera01->A1_XSERASA) // Verifica se o cliente já foi enviado ao Serasa.

				SA1->(DbGoTo(daxsera01->RECSA1))

				If SA1->A1_XSERASA == 'N' .Or. Empty(SA1->A1_XSERASA)
				RecLock('SA1', .F.)
				SA1->A1_XSERASA := 'S' // Marca o cliente como enviado a SERASA.
				SA1->(MsUnlock())
				EndIf
				*/
				_nCNPJ++

				If daxsera01->A1_MSBLQL == 'S'
					_cTipCli := '3' // 3 = Inativo.
				ElseIf (SToD(daxsera01->A1_DTCAD) + 365) > dDataBase
					_cTipCli := '2' // 2 = Menos de um ano.
				Else
					_cTipCli := '1' // 1 = Antigo.
				EndIf

				// TEMPO DE RELACIONAMENTO.
				// DEVERÁ SER FORMATADO SOMENTE PARA REMESSA NORMAL.
				CLIENTE(_nHdl, _cTipCli)

				//EndIf

				While daxsera01->(!EOF()) .And. _cCNPJ == daxsera01->A1_CGC

					_oRegua:IncRegua1('Processando registros...')

					SE1->(DbGoTo(daxsera01->RECSE1))

					/*
					If (SE1->E1_XSERASA == 'N' .Or. Empty(SE1->E1_XSERASA)) .And. daxsera01->TITATIVO == 'S'
					RecLock('SE1', .F.)
					SE1->E1_XSERASA := 'S' // Marca o titulo como enviado a SERASA.
					SE1->(MsUnlock())
					ElseIf daxsera01->TITATIVO == 'N'
					RecLock('SE1', .F.)
					SE1->E1_XSERASA := 'E' // Marca o titulo como enviado a SERASA para exclusão.
					SE1->(MsUnlock())
					EndIf
					*/
					_nTitulos++

					// TÍTULOS.
					TITULOS(_nHdl, daxsera01->VALOR, daxsera01->BAIXA, SubStr(daxsera01->E1_NUM, 4, 6) + SubStr(daxsera01->E1_PARCELA, 1, 2) + SubStr(daxsera01->SEQ, 1, 2))

					If daxsera01->RECSE5 > 0

						SE5->(DbGoTo(daxsera01->RECSE5))

						/*
						If (SE5->E5_XSERASA == 'N' .Or. Empty(SE5->E5_XSERASA))
						RecLock('SE5', .F.)
						SE5->E5_XSERASA := 'S' // Marca a baixa como enviado a SERASA.
						SE5->(MsUnlock())
						EndIf
						*/

					EndIf

					// Gera registro com o saldo do titulo.
					If !Empty(daxsera01->BAIXA) .And. daxsera01->SALDO > 0

						_nTitulos++

						// TÍTULOS.
						TITULOS(_nHdl, daxsera01->SALDO, SubStr(daxsera01->E1_NUM, 4, 6) + SubStr(daxsera01->E1_PARCELA, 1, 2) + SubStr(Soma1(daxsera01->SEQ, 2), 1, 2))

					EndIf

					daxsera01->(DbSkip())

				EndDo

			EndDo

			// TRAILLER.
			TRAILLER(_nHdl, _nCNPJ, _nTitulos)
			FClose(_nHdl)
			_oRegua:SaveLog("Arquivo gerado com sucesso. Usuário: " + AllTrim(UsrRetName(__cUserID)) + ". Caminho: " + _cPasta1 + _cPasta2 + _cArqTxt)
		Else
			_oRegua:SaveLog("Não foram encontrados registros para geração do arquivo.")
		EndIf
		daxsera01->(DbCloseArea())
	EndIf

Return


Static Function HEADER01(_nHdl, _cDtIni, _cDtFim)
	Local _cLinha := ''
	// MOVIMENTO ENVIADO PELA EMPRESA À SERASA.
	_cLinha := '00' // 001 - 002 || Identificação Registro Header = 00.
	_cLinha += PadR('RELATO COMP NEGOCIOS', 20) // 003 - 022 || Constante = 'RELATO COMP NEGOCIOS'.
	_cLinha += SM0->M0_CGC // 023 - 036 || CNPJ Empresa Conveniada.
	_cLinha += _cDtIni // 037 - 044. Data Início do Período Informado : AAAAMMDD.
	_cLinha += _cDtFim // 045 - 052 || Data Final do Período Informado : AAAAMMDD.
	_cLinha += 'S' // 053 - 053 || Periodicidade da remessa. Indicar a constante conforme a periodicidade D=Diário S=Semanal.
	_cLinha += Space(15) // 054 - 068 || Reservado Serasa.
	_cLinha += '017' // 069 - 071 || Número identificador do Grupo Relato Segmento ou brancos.
	_cLinha += Space(29) // 072 - 100 || Brancos.
	_cLinha += 'V.' // 101 - 102 || Identificação da Versão do Layout => Fixo = "V."
	_cLinha += '01' // 103 - 104 || Número da Versão do Layout => Fixo = "01".
	_cLinha += Space(26) // 105 - 130 || Brancos.
	_cLinha += CHR(13) + CHR(10)
	FWrite(_nHdl, _cLinha)
Return


Static Function CLIENTE(_nHdl, _cTipCli)
	Local _cLinha := ''
	// TEMPO DE RELACIONAMENTO.
	// DEVERÁ SER FORMATADO SOMENTE PARA REMESSA NORMAL.
	_cLinha := '01' // 001 - 002 || Identificação do Registro de Dados = 01.
	_cLinha += daxsera01->A1_CGC // 003 - 106 || Sacado Pessoa jurídica: CNPJ Empresa Cliente (Sacado).
	_cLinha += '01' // 017 - 018 || Tipo de Dados = 01 (Tempo de Relacionamento para Sacado Pessoa Jurídica).
	_cLinha += daxsera01->A1_DTCAD // 019 - 026 || Cliente Desde: AAAAMMDD.
	_cLinha += _cTipCli // 027 - 027 || Tipo de Cliente: 1 = Antigo; 2 = Menos de um ano; 3 = Inativo.
	_cLinha += Space(38) // 028 - 065 || Brancos.
	_cLinha += Space(34) // 066 - 099 || Brancos.
	_cLinha += Space(1) // 100 - 100 || Brancos.
	_cLinha += Space(30) // 101 - 130 || Brancos.
	_cLinha += CHR(13) + CHR(10)
	FWrite(_nHdl, _cLinha)
Return


Static Function TITULOS(_nHdl, _nValor, _cBaixa, _cNumTit)
	Local _cLinha := ''
	// TÍTULOS.
	_cLinha := '01' // 001 - 002 || Identificação do Registro de Dados = 01.
	_cLinha += daxsera01->A1_CGC // 003 - 016 || Sacado Pessoa jurídica: CNPJ Empresa Cliente (Sacado).
	_cLinha += '05' // 017 - 018 || Tipo de Dados = 05 (Títulos – Para Sacado Pessoa Jurídica).
	_cLinha += _cNumTit // 019 - 028 || Número do Título com até 10 posições.
	_cLinha += daxsera01->E1_EMISSAO // 029 - 036 || Data da Emissão do título: AAAAMMDD.
	If daxsera01->TITATIVO == 'S'
		_cLinha += StrZero(_nValor * 100, 13) // 037 - 049 || Valor do Título, com 2 casas decimais. Ajuste à direita com zeros à esquerda. Formatar 9999999999999 para exclusão do título.
	Else
		_cLinha += '9999999999999' // 037 - 049 || Enviar 9 neste campo para caracterizar exclusão do titulo no SERASA.
	EndIf
	_cLinha += daxsera01->E1_VENCTO // 050 - 057 || Data de Vencimento: AAAAMMDD.
	_cLinha += _cBaixa // 058 - 065 || Data de Pagamento: AAAAMMDD ou Brancos. No arquivo de Conciliação enviado pela Serasa esta informação estará com o conteúdo 99999999. No arquivo de Conciliação a ser enviado para a Serasa esta informação deverá ser formatada com a Data de Pagamento do título OU com Brancos, se o título não foi pago.
	_cLinha += '#D' + PadR(daxsera01->E1_FILIAL+daxsera01->E1_PREFIXO+daxsera01->E1_NUM+daxsera01->E1_PARCELA+daxsera01->E1_TIPO, 34) // 066 - 099 || Número do Título com mais de 10 posições: #D : indica número do título. Obs.: O "#D" pode ser utilizado quando o número do título for maior que dez posições. Se for informado "#D" nas posições 66 e 67, o sistema desprezará o conteúdo das posições 19 a 28 (Número do título), e considerará como número do título o número informado nas posições 68 a 99.
	_cLinha += Space(1) // 100 - 100 || Brancos.
	_cLinha += Space(24) // 101 - 124 || Reservado Serasa.
	//_cLinha += Space(2) // 125 - 126 || Reservado Serasa.
	_cLinha += Space(1) // 127 - 127 || Reservado Serasa.
	_cLinha += Space(1) // 128 - 128 || Reservado Serasa.
	_cLinha += Space(2) // 129 - 130 || Reservado Serasa.
	_cLinha += CHR(13) + CHR(10)
	FWrite(_nHdl, _cLinha)
Return


Static Function TRAILLER(_nHdl, _nCNPJ, _nTitulos)
	Local _cLinha := ''
	// TRAILLER.
	_cLinha := "99" // 001 - 002 || Identificação do Registro Trailler = 99.
	_cLinha += StrZero(_nCNPJ, 11) // 003 - 013 || Quantidade de Registros 01–Tempo de Relacionamento PJ. Ajuste à direita com zeros à esquerda Para remessa de Conciliação formatar zeros.
	_cLinha += Space(44) // 014 - 057 || Brancos.
	_cLinha += StrZero(_nTitulos, 11) // 058 - 068 || Quantidade de Registros 05 – Títulos PJ. Ajuste à direita com zeros à esquerda.
	_cLinha += Space(11) // 069 - 079 || Reservado Serasa.
	_cLinha += Space(11) // 080 - 090 || Reservado Serasa.
	_cLinha += Space(10) // 091 - 100 || Reservado Serasa.
	_cLinha += Space(30) // 101 - 130 || Brancos.
	_cLinha += CHR(13) + CHR(10)
	FWrite(_nHdl, _cLinha)
Return
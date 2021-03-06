#INCLUDE "PROTHEUS.CH"
#DEFINE COD_CISP "176"

/*/{Protheus.doc} DAXATU05
Gera��o de Arquivo CISP
@type  User Function
@author B. Vinicius
@since 19/08/2019
/*/

User Function DAXATU05()

	If MsgYesno('Deseja gerar o Cisp Restritivo?')
		ImpCisp()
	Else
		MsgAlert('Cancelado pelo usu�rio')
	Endif

Return

Static Function ImpCisp()

	Local cDiretorio  := cGetFile( '*.*' , 'Selecione o Diret�rio', 1, , .T., nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY ),.T., .T. )
	Local cArquivo := ""

	If !Empty(cDiretorio)
		cArquivo += "NEG" + COD_CISP +".TXT"
		nHandle := FCreate(cDiretorio + cArquivo)
		ProcCisp()
	Else
		MsgInfo('Nenhum diret�rio selecionado.')
	Endif

Return

Static Function ProcCisp()

	Local cAliasQry := GetNextAlias()
	Local dProtesto := DaySub(dDataBase , 1)
	Local aParam := {}

	aAdd(aParam, {1, "Motivo Protesto 1"   , CriaVar('E1_XMOTP1 ',.F.) ,  ,, 'UA',, 60, .T.} )
	aAdd(aParam, {1, "Motivo Protesto 2"   , CriaVar('E1_XMOTP2',.F.) ,  ,, 'UA',, 60, .F.} )

	If ParamBox(aParam,'Par�metros')

		BeginSQL Alias cAliasQry

		COLUMN E1_XDTPROT AS DATE

		SELECT  A1_CGC , A1_PESSOA , E1_NUM , E1_XDTPROT , E1_VALOR , E1_XMOTP1 , E1_XMOTP2

		FROM %TABLE:SE1% SE1

		INNER JOIN %TABLE:SA1% SA1

		ON ( A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA )

		WHERE E1_SALDO = E1_VALOR  AND E1_SITUACA = "F"

		AND SE1.E1_XDTPROT = %Exp:dProtesto%

		AND SE1.D_E_L_E_T_ = ''

		AND SA1.D_E_L_E_T_ = ''

		EndSQL


		If !(cAliasQry)->(EOF())
			FWMsgRun(, {|| MontaLayout(cAliasQry) }, "Processando", "Processando a rotina...")
			MsgInfo('Arquivo gerado com sucesso!')
			FClose(nHandle)
		Else
			MsgInfo('Nenhum t�tulo encontrado para envio!')

		Endif

		(cAliasQry)->(dbCloseArea())

	Else
		MsgInfo('Cancelado pelo usu�rio.')
	Endif

	Return

Static Function MontaLayout(cAliasQry)

	Local cTipoCli := Iif( (cAliasQry)->A1_PESSOA == "F" , "2" , "1" )
	Local cDocumento := ""
	Local cValor := ""

	While !(cAliasQry)->(EOF())

		If cTipoCli == "F" //Cliente Fisico

			//NOVO LAYOUT SO PESSOA JURIDICA
			(cAliasQry)->(dbSkip())

			cDocumento := (cAliasQry)->A1_CGC
		Else //Cliente Juridico
			cDocumento := Left((cAliasQry)->A1_CGC,8)
		Endif

		cValor := StrZero((cAliasQry)->E1_VALOR,15)
		cValor := StrTran(cValor,".","")

		If Len(Alltrim(cValor)) < 15
			cValor := "0" + cValor
		Endif

		FWrite(nHandle, COD_CISP) // C�digo do Associado na CISP
		FWrite(nHandle, Left(cDocumento,8) ) // Identifica��o (CNPJ / CPF / RG / Export. / Insc.Prod. / Outros)
		FWrite(nHandle, Dtos(dDataBase)) // Data da Informa��o
		FWrite(nHandle, MV_PAR01) // C�digo da Informa��o Complementar 1
		FWrite(nHandle, Iif(Empty(MV_PAR02),'99',MV_PAR02)) // C�digo da Informa��o Complementar 2
		FWrite(nHandle, Replicate("0",15)) // CNPJ ou CPF do S�cio do Cliente
		FWrite(nHandle, Padr('',40)) // Raz�o Social  ou  Nome do S�cio do Cliente
		FWrite(nHandle, Padl( Alltrim(StrTran((cAliasQry)->E1_NUM,"_","")) ,10,"0")) // Numero do (Cheque ou Duplicata)
		FWrite(nHandle, cValor) // Data da Ocorr�ncia
		FWrite(nHandle, Dtos((cAliasQry)->E1_XDTPROT) ) // Data da Ocorr�ncia
		FWrite(nHandle,CRLF)

		(cAliasQry)->(dbSkip())

	EndDo

Return
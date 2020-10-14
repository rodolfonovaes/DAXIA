#INCLUDE "PROTHEUS.CH"
#DEFINE COD_CISP "176"

/*/{Protheus.doc} DAXATU05
Geração de Arquivo CISP
@type  User Function
@author B. Vinicius
@since 19/08/2019
/*/

User Function DAXATU05()

	Private nTotReg := 0

	If MsgYesno('Deseja gerar o Cisp Restritivo?')
		ImpCisp()
	Else
		MsgAlert('Cancelado pelo usuário')
	Endif

Return

Static Function ImpCisp()

	Local cDiretorio  := cGetFile( '*.*' , 'Selecione o Diretório', 1, , .T., nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY ),.T., .T. )
	Local cArquivo := ""

	If !Empty(cDiretorio)
		cArquivo += "NEG" + COD_CISP +".TXT"
		nHandle := FCreate(cDiretorio + cArquivo)
		ProcCisp()
	Else
		MsgInfo('Nenhum diretório selecionado.')
	Endif

Return

Static Function ProcCisp()

	Local cAliasQry := GetNextAlias()
	Local aParam := {}
	Local dVenc := DaySub(dDataBase,6) //Data considerada para dias de um titulo Protestado

	aAdd(aParam, {1, "Motivo Protesto 1"   , CriaVar('E1_XMOTP1 ',.F.) ,  ,, 'UA',, 60, .T.} )
	aAdd(aParam, {1, "Motivo Protesto 2"   , CriaVar('E1_XMOTP2',.F.) ,  ,, 'UA',, 60, .F.} )
	aAdd(aParam, {1, "Motivo Cobrança 1"   , CriaVar('E1_XMOTP1 ',.F.) ,  ,, 'UA',, 60, .T.} )
	aAdd(aParam, {1, "Motivo Cobrança 2"   , CriaVar('E1_XMOTP2',.F.) ,  ,, 'UA',, 60, .F.} )


	If ParamBox(aParam,'Parâmetros')

		//MV_PAR03 := cValToChar(MV_PAR03) //Forca sempre a conversao por problemas na funcao parambox

		BeginSQL Alias cAliasQry

			COLUMN E1_BAIXA AS DATE

			SELECT  A1_CGC , A1_PESSOA , E1_NUM  , E1_VALOR , E1_XMOTP1 , E1_XMOTP2 , SE1.R_E_C_N_O_ RECSE1 , E1_BAIXA

			FROM %TABLE:SE1% SE1

			INNER JOIN %TABLE:SA1% SA1

			ON ( A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA )

			WHERE E1_SALDO = 0

			AND E1_XMTREG1 = '' AND E1_XMOTP1 <> '' 

			//AND SE1.E1_XDTPROT = %Exp:dProtesto%

			AND SE1.D_E_L_E_T_ = ''

			AND SA1.D_E_L_E_T_ = ''
		
		EndSQL

		FWMsgRun(, {|| MontaLayout(cAliasQry,dVenc,1) }, "Processando", "Processando Pagamentos...")

		(cAliasQry)->(dbCloseArea())

		cAliasQry := GetNextAlias()
		
		BeginSQL Alias cAliasQry

			SELECT  A1_CGC , A1_PESSOA , E1_NUM , E1_XDTPROT , E1_VALOR , E1_XMOTP1 , E1_XMOTP2 , SE1.R_E_C_N_O_ RECSE1

			FROM %TABLE:SE1% SE1

			INNER JOIN %TABLE:SA1% SA1

			ON ( A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA )

			WHERE E1_SALDO = E1_VALOR  AND E1_TIPO IN ('NF','BOL' , 'NEG')

			AND SE1.D_E_L_E_T_ = ''

			AND SA1.D_E_L_E_T_ = ''

			AND LEFT(E1_VENCREA,6) >= "202001"

			AND E1_VENCREA <= %Exp:dVenc%

			AND E1_XMOTP1 = ''

		EndSQL

		memowrite("c:\windows\temp\cquery.txt",GetLastQuery()[2])
		
		ALERT('TESTE')
		ALERT(dDataBase)


		FWMsgRun(, {|| MontaLayout(cAliasQry,dVenc,2) }, "Processando", "Processando Cobrança...")

		(cAliasQry)->(dbCloseArea())
	 	
		If nTotReg > 0 
			MsgInfo('Rotina finalizada')
		Else 
			MsgiNfo('Nenhum registro encontrado.')
		Endif 
	 	FClose(nHandle)
Else
		MsgInfo('Cancelado pelo usuário.')
Endif

Return


//nOpc = 1 pagamento , 2 = cobranca
Static Function MontaLayout(cAliasQry,dVenc,nOpc)

	Local cTipoCli := Iif( (cAliasQry)->A1_PESSOA == "F" , "2" , "1" )
	Local cDocumento := ""
	Local cValor := ""
	Local cCompl1 := ""
	Local cCompl2 := ""
	Local dOcorrencia := ""

	//Informacao complementar 1 pagamento
	If nOpc == 1
		cCompl1 := MV_PAR03
	//Informacao complementar 2 cobranca
	Else
		cCompl1 := MV_PAR01
	Endif

	//Informacao complementar 2 pagamento
	If nOpc == 1
		cCompl2 := MV_PAR04
	//Informacao complementar 2 cobranca
	Else
		cCompl2 := MV_PAR02
	Endif

	If Empty(cCompl2)
		cCompl2 := "99"
	Endif

	
	While !(cAliasQry)->(EOF())

		nTotReg ++ 

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

		If nOpc == 1
			dOcorrencia := Dtos((cAliasQry)->E1_BAIXA)
		Else
			dOcorrencia := Dtos(dVenc)
		Endif

		FWrite(nHandle, COD_CISP) // Código do Associado na CISP
		FWrite(nHandle, Left(cDocumento,8) ) // Identificação (CNPJ / CPF / RG / Export. / Insc.Prod. / Outros)
		FWrite(nHandle, Dtos(dDataBase)) // Data da Informação
		FWrite(nHandle, cCompl1) // Código da Informação Complementar 1
		FWrite(nHandle, cCompl2 ) // Código da Informação Complementar 2
		FWrite(nHandle, Replicate("0",15)) // CNPJ ou CPF do Sócio do Cliente
		FWrite(nHandle, Padr('',40)) // Razão Social  ou  Nome do Sócio do Cliente
		FWrite(nHandle, Padl( Alltrim(StrTran((cAliasQry)->E1_NUM,"_","")) ,10,"0")) // Numero do (Cheque ou Duplicata)
		FWrite(nHandle, cValor) // Data da Ocorrência
		FWrite(nHandle, dOcorrencia ) // Data da Ocorrência
		FWrite(nHandle,CRLF)

		//Atualiza o titulo com os campos customizados

		SE1->(dbGoTo( (cAliasQry)->RECSE1 ))
		Reclock("SE1" , .F.)

		//Motivo Regularizador
	If nOpc == 1

			E1_XMTREG1 := MV_PAR03
			E1_XMTREG2 := MV_PAR04
		//Protesto 
	Else
			E1_XMOTP1  := MV_PAR01
			E1_XMOTP2  := MV_PAR02

	Endif

		SE1->(MsUnLock())

		(cAliasQry)->(dbSkip())

EndDo

Return
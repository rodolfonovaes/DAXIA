#INCLUDE "TOTVS.CH"			//Biblioteca de sintaxes FIVEWIN
#INCLUDE "TOPCONN.CH"		//Bibliotecas para Top Connect
#include "AP5MAIL.CH"		//Biblioteca para envio de E-MAILS
#INCLUDE "TBICONN.CH"		//Biblioteca para abertura de Empresas
#INCLUDE "MSOLE.CH"
#INCLUDE "RWMAKE.CH"
#DEFINE DIRCISP   IIF(GetRemoteType() <> REMOTE_LINUX,"CISP\","CISP/")
#DEFINE REMOTE_LINUX		2			// O Remote está em Linux
//--------------------------------------------------------------
/*/{Protheus.doc} DaxCisp1()

Gera informações comerciais para CISP - Informações Comercias / Restritiva. 

@param xParam Parameter DescriptionuSER
@return xRet Return Description
@author Fabio Costa - TOTVS - costa.fabio@totvs.com.br
@since 18/07/2019

u_DaxCisp1()


/*/


User Function DaxCisp2(lJob)

	Local _oProcess
	Local _aAreaMem := GetArea()
	Local _bProcess := {|_oSelf| EXECUTA(_oSelf,.F.) }
	Local cPerg    := "Cisp01"
	Local _aInfo    := {}
	Default	lJob := .F.

//	lJob := .T.
	If lJob 
		
		// Seta job para nao consumir licensas
		Conout('CISP - Setando o ambiente')
		RpcSetType(3)
			
			RPCSetEnv( '01', '0103',,, "FIN")		
		//If GetMV( "MV_DTCISP" ) <> dDataBase
			Conout('CISP - Entrando no Job do CISP')
			EXECUTA(nil,lJob)
			RPCClearEnv()
			Conout('CISP - Fim da execução')
		//Else
		////	Conout('CISP - Ja rodou no dia')
		//	RPCClearEnv()
		//EndIf
	Else
		_oProcess := tNewProcess():New("DaxCisp01", "Cisp", _bProcess, "Rotina responsável pela geração do arquivo semanal CISP.", cPerg, _aInfo, .T., 5, "Gera arquivo CISP.", .T.)
	EndIf
	RestArea(_aAreaMem)
Return


Static Function EXECUTA(_oRegua,lJob)

	Local aFields := {}
	Local cArqTrb := ""
	Local cCGC	   := ""
	Local nLimite  := 0.00
	Local cTpGar   := "0"                             	// Tipo Garantia
	Local cGrauGar := "00"							   	// Grau Garantia
	Local cDtGar   := "00000000"       				// Data Garantia
	Local cValGar  := "000000000000000"				// Valor Garantia
	Local aSimb    := {}
	Local aMovi    := {}
	Local cLinha   := ""
	Local cCampo   := ""
	Local cAqImp   := ""
	Local cLimite  := ""
	Local nIndex   := 0
	Local cIndice  := ""
	Local cFiltro  := ""
	Local cQuery   := ""
	Local cAliasQry	:= ""
	
	Local nValorDA	 := 0.00
	Local nValorF	 := 0.00
	Local nValorC	 := 0.00
	Local nValorD5F	 := 0.00
	Local nValorD5C	 := 0.00
	Local nValorD15F := 0.00
	Local nValorD15C := 0.00
	Local nValorD30F := 0.00
	Local nValorD30C := 0.00
    Local nQtdDias	 := 0.00
	Local nQtdTit	 := 0.00
	Local nValoraVen := 0.00
	Local nValoraF	 := 0.00
	Local nValoraC	 := 0.00
	Local nQtdDias1	 := 0.00
	Local nQtdTit1	 := 0.00
	Local lAchou	 := .F.
	Local nSaldoABE  := 0
	Local aSorte     := {}
	Local nSaldoAnt  := 0
	Local nSaldo     := 0
	Local nSaldoTit  := 0
	Local aDatas     := {}
	Local dDataAnt   := "  /  /    "
	Local dDataCad   := " /  /     "
	Local nSaldoDia  := 0
	Local nVlBaixado := 0
	Local cErro		:= ''
	Local nValorMA	:= 0
	Local dDataMA	:= STOD(" ")
	Local dDataPV	:= STOD("  ")
	Local nValorPV	:= 0
	Local dDataUC	:= STOD("  ")
	Local nValorUC	:= 0
	Local cCliLoja	:= ''
	Local cErrMsg	:= ''
	Local cTipo		:= ''
	Local nMedPdaVen := 0
	Local nMdAriaVen := 0
	Local nMedPdaAtr := 0
	Local nMdAriaAtr := 0
	Local nMedPAtr5 := 0
	Local nMdArAtr5 := 0
	Local nMedPAtr15 := 0
	Local nMdArAtr15 := 0
	Local nMedPAtr30 := 0
	Local nMdArAtr30 := 0			
	Default	lJob	:= .F.
	Private cArqCli	:= ''
	Private cArqCom	:= ''
	Private dDataDe	:= dDataBase
	Private dDataAte	:= dDataBase
	Private nGeraCli	:= 1
	Private nTime	:= Val(Time())
	Private	_CLIENTE	:= ''
	

	If lJob
		cArqCli	:= DIRCISP + 'job_cliente' + AllTrim(DTOS(dDataBase))
		cArqCom	:= DIRCISP + 'job_com' + AllTrim(DTOS(dDataBase))
		dDataDe	:= dDataBase
		dDataAte	:= dDataBase
		nGeraCli	:= 1	
	Else
		cArqCli	:= MV_PAR01
		cArqCom	:= MV_PAR02
		dDataDe	:= MV_PAR03
		dDataAte	:= MV_PAR04
		nGeraCli	:= MV_PAR05
	EndIf

	aSimb	:= { "(", ")", "[", "]", ".", ",", "-", "Ç", "ç", ":", ";" , "/" }
	aMovi   := {}

	If nGeraCli == 2 // Só clientes com movimento
		SD2->( ProcRegua( LastRec()/10 ) )	

		cQuery	:= ''
		cAliasQry := GetNextAlias()
		

		cQuery := "SELECT D2_CLIENTE , D2_LOJA  "
		cQuery += "  FROM " + RetSQLTab('SD2') + " SD2 "
		cQuery += "  INNER JOIN " + RetSQLTab('SA1') + " SA1 ON A1_COD = D2_CLIENTE AND A1_LOJA = D2_LOJA AND A1_PESSOA = 'J'  SA1.D_E_L_E_T_ = ' '"
		cQuery += "  WHERE  "
		cQuery += "  D2_EMISSAO  <= '" +  DTOS(dDataAte) + "'   "
		cQuery += "  AND SD2.D_E_L_E_T_ = ' '"

		If Select(cAliasQry) > 0 
			(cAliasQry)->(DbCloseArea())
		EndIf

		TcQuery cQuery new Alias ( cAliasQry )
		(cAliasQry)->(dbGoTop())
		
		do While !(cAliasQry)->(EOF()) 
			IF !lJob
        		_oRegua:IncRegua1('Verificando Clientes com Movimento')
			EndIf
			If aScan(aMovi,(cAliasQry)->D2_CLIENTE+(cAliasQry)->D2_LOJA) == 0
				aadd(aMovi,(cAliasQry)->D2_CLIENTE+(cAliasQry)->D2_LOJA)
			Endif
			(cAliasQry)->(dbSkip())
		Enddo

		(cAliasQry)->(DbCloseArea())


		cAliasQry := GetNextAlias()
		

		cQuery := "SELECT E1_CLIENTE , E1_LOJA  "
		cQuery += "  FROM " + RetSQLTab('SE1') + " SE1 "
		cQuery += "  INNER JOIN " + RetSQLTab('SA1') + " SA1 ON A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA AND A1_PESSOA = 'J'  SA1.D_E_L_E_T_ = ' '"
		cQuery += "  WHERE  "
		cQuery += "  E1_EMISSAO  <= '" +  DTOS(dDataAte) + "'   "
		cQuery += "  AND SE1.D_E_L_E_T_ = ' '"

		If Select(cAliasQry) > 0 
			(cAliasQry)->(DbCloseArea())
		EndIf

		TcQuery cQuery new Alias ( cAliasQry )
		(cAliasQry)->(dbGoTop())

		do While !(cAliasQry)->(EOF()) 
            IF !lJob
				_oRegua:IncRegua1('Verificando Clientes com Movimento')
			EndIf
			If aScan(aMovi,(cAliasQry)->E1_CLIENTE+(cAliasQry)->E1_LOJA) == 0
				aadd(aMovi,(cAliasQry)->E1_CLIENTE+(cAliasQry)->E1_LOJA)
			Endif
			(cAliasQry)->(dbSkip())
		Enddo

		(cAliasQry)->(DbCloseArea())


		dbSelectArea("SE5")
		dbSetOrder(5)
		dbSeek(xFilial("SE5") + Dtos(dDataDe),.T.)

		cQuery := "SELECT E5_CLIFOR , E5_LOJA  "
		cQuery += "  FROM " + RetSQLTab('SE5') + " SE5 "
		cQuery += "  INNER JOIN " + RetSQLTab('SA1') + " SA1 ON A1_COD = E5_CLIFOR AND A1_LOJA = E5_LOJA AND A1_PESSOA = 'J'  SA1.D_E_L_E_T_ = ' '"
		cQuery += "  WHERE  "
		cQuery += "  E5_DATA  <= '" +  DTOS(dDataAte) + "'   "
		cQuery += "  AND SE5.D_E_L_E_T_ = ' ' AND E5_RECPAG = 'R' "

		If Select(cAliasQry) > 0 
			(cAliasQry)->(DbCloseArea())
		EndIf

		TcQuery cQuery new Alias ( cAliasQry )
		(cAliasQry)->(dbGoTop())

		do While !(cAliasQry)->(EOF()) 		
			IF !lJob
				_oRegua:IncRegua1('Verificando Clientes com Movimento')				
			EndIf
			If aScan(aMovi,(cAliasQry)->E5_CLIFOR+(cAliasQry)->E5_LOJA) == 0 
				aadd(aMovi,(cAliasQry)->E5_CLIFOR+(cAliasQry)->E5_LOJA)
			Endif
			(cAliasQry)->(dbSkip())
		Enddo

		(cAliasQry)->(DbCloseArea())
	Else
		/*SA1->( ProcRegua( LastRec()/10 ) )	
		SA1->(DbGoTop())
		While SA1->(!Eof())
        	_oRegua:IncRegua1('Verificando Clientes')
			If aScan(aMovi,SA1->A1_COD+SA1->A1_LOJA) == 0
				aadd(aMovi,SA1->A1_COD+SA1->A1_LOJA)
			Endif
			SA1->(dbSkip())			
		EndDo*/
	Endif

	
	If !Empty( cArqCli )
		cArqImp    := FCreate( AllTrim( cArqCli ) )

		DbSelectArea( "SA1" )
		SA1->( DbSetOrder( 1 ) )

		SA1->( ProcRegua( LastRec() ) )
		SA1->( DbSeek( xFilial( "SA1" ) ) )

		While !SA1->( Eof() ) //.and. SA1->A1_FILIAL == xFilial( "SA1" ) 
			IF !lJob
				_oRegua:IncRegua1('Processando Clientes...')
			EndIf

			If /*Len( AllTrim( SA1->A1_CGC ) ) # 14 .or.*/ Iif(nGeraCli==1,.F.,ascan(aMovi,SA1->A1_COD+SA1->A1_LOJA) == 0) .Or. SA1->A1_PESSOA == 'F'
				SA1->( DbSkip() )
				Loop
			EndIf

			tam 	:= LEN(ALLTRIM(SA1->A1_CGC))
			cLinha	:= IIF(tam <= 11 , "2" , "1") // Tipo : 1= CNPJ, 2= CPF

			// Código do associado
			cLinha  := cLinha + '0176'
			
			// CNPJ
			cLinha  := cLinha + PadL(Trim(SA1->A1_CGC),20,"0")
			
			// Data da Informação 
			cLinha  := cLinha + StrZero( Year( dDataBase ) , 4 ) +;
			StrZero( Month( dDataBase ) , 2 ) +;
			StrZero( Day( dDataBase ) , 2 )
			

			// Razão Social
			cCampo	:= AllTrim( SA1->A1_NOME )
			Limpa()
			cLinha  := cLinha + PadR(cCampo,60)

			// Sexo
			cCampo := " "
			cLinha += cCampo

			//  Dt Nascimento
			cCampo := "00000000"
			cLinha += cCampo

			// 	Estado Civil
			cCampo := "          "
			cLinha += cCampo

			// Endereço
			cCampo	:= AllTrim( SA1->A1_END )
			Limpa()
			cLinha  := cLinha + Padr(cCampo,60)

			// Bairro
			cCampo	:= AllTrim( SA1->A1_BAIRRO )
			Limpa()
			cLinha  := cLinha + Padr(cCampo,30)

			// Município
			cCampo	:= AllTrim( SA1->A1_MUN )
			Limpa()
			cLinha  := cLinha + Padr(cCampo,40)

			// Estado
			cCampo	:= AllTrim( SA1->A1_EST )
			Limpa()
			cLinha  := cLinha + cCampo

			// Pais
			dbSelectArea("SYA")
			dbSetOrder(1)
			dbSeek(xFilial("SYA") + SA1->A1_PAIS)
			cCampo	:= AllTrim(SYA->YA_DESCR)
			cLinha  := cLinha + Padr(cCampo,20)
			dbSelectArea("SA1")

			// Região
			If SA1->A1_EST $ "RS/SC/PR"
				cCampo := "SUL"
			ElseIf SA1->A1_EST $ "SP/RJ/MG/ES"
				cCampo := "SUDESTE"
			ElseIf SA1->A1_EST $ "MS/MT/GO/TO/DF"
				cCampo := "CENTRO OESTE"
			ElseIf SA1->A1_EST $ "AC/AM/PA/RO/RR"
				cCampo := "NORTE"
			ElseIf SA1->A1_EST $ "AL/BA/CE/MA/PB/PE/PI/RN/SE"
				cCampo := "NORDESTE"
			Endif
			cLinha  := cLinha + Padr(cCampo,20)

			// Cep
			cLinha  := cLinha + SA1->A1_CEP

			// Telefone
			cCampo	:= AllTrim( SA1->A1_TEL )
			Limpa()
			cLinha  := cLinha + Padr(cCampo,30)

			// Fax
			cCampo	:= AllTrim( SA1->A1_FAX )
			Limpa()
			cLinha  := cLinha + Padr(cCampo,30)

			// Data de Cadastro
			cLinha  := cLinha + StrZero( Year( dDataBase ) , 4 ) +;
			StrZero( Month( dDataBase ) , 2 ) +;
			StrZero( Day( dDataBase ) , 2 )

			// Atividade Economica
			If !Empty( SA1->A1_ATIVIDA )
				cLinha  := cLinha + PadR(AllTrim( SA1->A1_ATIVIDA ),8,"0")
			Else
				cLinha  := cLinha + "00000000" 
			EndIf       

			// E-Mail
			cCampo	:= AllTrim( SA1->A1_EMAIL)
			Limpa()
			cLinha  := cLinha + Padr(cCampo,50)				

			// Orgao Emissor do RG
			cLinha  := cLinha + Space(60)

			// Dt Expedição do RG
			cLinha := cLinha + "00000000"

			// Filiação
			cLinha := cLinha + Space(60)

			cLinha  := cLinha + Chr( 13 ) + Chr( 10 )

			FWrite( cArqImp , cLinha , Len( cLinha ) )

			SA1->( DbSkip() )
		EndDo

		FClose( cArqImp )
	EndIf

	If !Empty( cArqCom )

		/*If dDataDe <= GetMV( "MV_DTCISP" ) .and. nGeraCli == 1
			MsgStop( "Última remessa de arquivos para a CISP foi em " + DtoC( GetMV( "MV_DTCISP" ) ) +;
			", portanto, uma nova remessa deverá ser superior a esta data !" )
			Return 
		EndIf */

		If dDataDe > dDataAte
			MsgStop( "Período de datas inválidos !" )
			Return
		EndIf

		cArqImp	:= FCreate( AllTrim( cArqCom ) )
		cLimite	:= GetMV( "MV_CREDCLI" )

		aFields := {}
		cArqTrb := ""

		AAdd(aFields,{"CLIENTE"  	     ,"C",06,00}) 
		AAdd(aFields,{"LOJA"             ,"C",04,00})

		// cria a tabela temporária
		cArqTrb:="T_"+Criatrab(,.F.)
		MsCreate(cArqTrb,aFields,"DBFCDX")
		dbUseArea(.T.,"DBFCDX",cArqTrb,"CLI",.T.,.F.)
		IndRegua("CLI",cArqTrb,"CLIENTE+LOJA",,,"Ordenando arquivo de trabalho 1...")

		aFields := {}
		cArqTrb := ""

		AAdd(aFields,{"EMISSAO"  	   ,"D",08,00}) 
		AAdd(aFields,{"VALOR_FAT"      ,"N",15,02})
		AAdd(aFields,{"VALOR_REC"      ,"N",15,02})
		AAdd(aFields,{"NUM"  	  	   ,"C",TAMSX3('E1_NUM')[1] * 10,00}) 
		AAdd(aFields,{"CLIENTE"	  	   ,"C",TAMSX3('E1_CLIENTE')[1] + TAMSX3('E1_LOJA')[1],00}) 

		// cria a tabela temporária
		cArqTrb:="T_"+Criatrab(,.F.)
		MsCreate(cArqTrb,aFields,"DBFCDX")
		dbUseArea(.T.,"DBFCDX",cArqTrb,"EMI",.T.,.F.)
		IndRegua("EMI",cArqTrb,"DtoS(EMISSAO)",,,"Ordenando arquivo de trabalho 2...")

		DbSelectArea( "SE1" )

	//	nIndex	:= RetIndex( "SE1" )
	//	cIndice := CriaTrab("",.f.)

	//	cFiltro	:= 'AllTrim( SE1->E1_TIPO ) $ "NF" .and. DtoS(E1_EMISSAO) >= "'+DTOS(dDataAte-365)+'" .and. DtoS(E1_EMISSAO) <= "'+DTOS(dDataAte)+'"'

	//	IndRegua("SE1",cIndice,"E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM",,cFiltro,"Selecionando Registros...")

	//	RetIndex( "SE1" )

	//	#IFNDEF TOP		
	//	SE1->( DbSetIndex( cIndice ) )
	//	#ENDIF

	/*	DbSelectArea( "SE5" )
		SE5->( DbSetOrder( 7 ) )

		DbSelectArea( "SZ7" )
		SZ7->( DbSetOrder( 1 ) )
*/
		DbSelectArea( "SA1" ) 
		SA1->( DbSetOrder( 3 ) )

		SA1->( ProcRegua( LastRec() ) )
		SA1->( DbSeek( xFilial( "SA1" ) ) )

		While !SA1->( Eof() ) .and. SA1->A1_FILIAL == xFilial( "SA1" ) 

			If /*Len( AllTrim( SA1->A1_CGC ) ) # 14 .or.*/ Empty( SA1->A1_CGC )  .or. Iif(nGeraCli==1,.F.,ascan(aMovi,SA1->A1_COD+SA1->A1_LOJA) == 0) .Or. SA1->A1_PESSOA == 'F'
				IncProc( "Inf. Comerciais do CGC -> " + TransForm( Left( SA1->A1_CGC , 8 ) , "@R XX.XXX.XXX" ) )
				SA1->( DbSkip() )
				Loop
			EndIf

			IF !lJob
				_oRegua:IncRegua1('Processando registros do cliente ' + SA1->A1_CGC + ' ' + SA1->A1_NOME)
			EndIf
			
			DbSelectArea( "CLI" )
			DbSelectArea( "EMI" )
			//DEBUG
			cCGC		:=  Left( SA1->A1_CGC , 8 )
			//If cCGC == '10823480'
		//		Alert('OPA')
		//	EndIF
			_CLIENTE	:= RetCliente(cCGC)
			cTipo		:= IIF(Len(Alltrim(SA1->A1_CGC)) <= 11 , "2" , "1")
			dDataCad	:= RetDtCad(cCGC)//SA1->A1_DTCAD - REMOVER NO FUTURO
			nLimite		:= 0.00
			cTpGar		:= "0"                             	// Tipo Garantia
			cGrauGar	:= "00"							   	// Grau Garantia
			cDtGar		:= "00000000"       				// Data Garantia
			cValGar		:= "000000000000000"				// Valor Garantia

			//Rodolfo - Limpo o arquivo CLI
			CLI->(DbGoTop())
			While !CLI->(EOF())
				RecLock('CLI',.F.)
				CLI->(DbDelete())
				MsUnLock()
				CLI->(DbSkip())
			Enddo

			CONOUT('CISP - Inicio do processo cliente - ' + cCGC + ' - ' + Time()) 
			While !SA1->( Eof() ) .and. SA1->A1_FILIAL == xFilial( "SA1" ) .and. ;
			Left( SA1->A1_CGC , 8 ) == cCGC 

				IF !lJob
					_oRegua:IncRegua1('Informacoes Comerciais....')
				EndIf
				If /*Len( AllTrim( SA1->A1_CGC ) ) # 14 .or.*/ Empty( SA1->A1_CGC )
					SA1->( DbSkip() )
					Loop
				EndIf

				If		cLimite == "L"								// Crédito por Loja
					nLimite		:= Round( nLimite , 2 )	+ Round( SA1->A1_LC , 2 )
				ElseIf	cLimite == "C" //.and. SA1->A1_LOJA == "01"	// Crédito por Cliente - pq loja == 01????????
					nLimite		:= Round( nLimite , 2 )	+ Round( SA1->A1_LC , 2 )
				EndIf

				If !CLI->( DbSeek( SA1->A1_COD + SA1->A1_LOJA ) )
					RecLock( "CLI" , .T. )
					CLI->CLIENTE	:= SA1->A1_COD
					CLI->LOJA		:= SA1->A1_LOJA
					CLI->( MsUnLock() )
				EndIf 
				
				nValorDA	:= RetDbTot(SA1->A1_COD , SA1->A1_LOJA) //IIF(SA1->A1_SALDUP < 0 , 0 , SA1->A1_SALDUP)
				nValorMA	:= MAIORACU(@dDataMA)
				//dDataMA		:= SA1->A1_XDTMSAL
				dDataUC		:= XDTUC()
				nValorUC	:= XVLUC()
				nValorPV    := PENULTIMA(@dDataPV) 
				nValorD5F	:= RetAtr(SA1->A1_COD , SA1->A1_LOJA , 5)
				nValorD15F	:= RetAtr(SA1->A1_COD , SA1->A1_LOJA , 15)
				nValorD30F	:= RetAtr(SA1->A1_COD , SA1->A1_LOJA , 30)
				nValoraVen	:= RetDeb(SA1->A1_COD , SA1->A1_LOJA )
				nMedPdaVen	:= MDPDAVNC(@nMdAriaVen) 
				nMedPdaAtr	:= MDPDATR(@nMdAriaAtr,0) 
				nMedPAtr5	:= MDPDATR(@nMdArAtr5,5) 
				nMedPAtr15	:= MDPDATR(@nMdArAtr15,15) 
				nMedPAtr30	:= MDPDATR(@nMdArAtr30,30) 		

				If nValorUC == 0
					dDataUC := stod(' ')
					dDataMA	:= stod(' ')
					nValorMA	:= 0
				EndIf

				If dDataMA > dDataUC  .And.  nValorMA > 0
					dDataUC := dDataMA
					nValorUC := nValorMA
				EndIf

				If nValorUC > nValorMA .And. dDataUC >= YearSub(dDataBase,1)
					dDataMA := dDataUC
					nValorMA := nValorUC
				EndIf	
				
				If nValorMA == 0 .And. nValorUC > 0
					nValorMa	:= nValorUc
					dDataMA		:= dDataUC
				EndIf

				If dDataMA == Stod(' ') .And. nValorMA > 0
					dDataMA := dDataUC
				EndIf
				SA1->( DbSkip() )
			EndDo

			If CLI->( RecCount() ) == 0
				Loop
			EndIf
			
			If dDataPV == dDataUC
				dDataPV		:= CtoD( "" )
				nValorPV    := 0.00
			EndIf

			If !SZ7->( DbSeek( xFilial( "SZ7" ) + cCGC ) )
				If !lAchou	
					Loop
				EndIf
				RecLock( "SZ7" , .T. )
				SZ7->Z7_FILIAl		:= xFilial( "SZ7" )
				SZ7->Z7_CGC       	:= cCGC
				SZ7->Z7_DATCAD    	:= dDataCad
				SZ7->Z7_DTULTCO		:= dDataUC
				SZ7->Z7_VLULTCO		:= Round( nValorUC , 2 )

				//Protecao a diversos problemas na rotina, B. Vinicius 21/05
				If nValorMA >=  SZ7->Z7_VLMAIAC .And. SZ7->Z7_DTMAIAC >= YearSub(dDatabase,1)
					SZ7->Z7_VLMAIAC		:= Round( nValorMA , 2 )
					SZ7->Z7_DTMAIAC		:= dDataMA
				Endif

				SZ7->Z7_DTPENCO		:= dDataPV
				SZ7->Z7_VLPENCO		:= Round( nValorPV , 2 )
			Else
				if dDataCad > SZ7->Z7_DATCAD
					dDataCad := SZ7->Z7_DATCAD
				Else
					RecLock( "SZ7" , .F. )
					SZ7->Z7_DATCAD    	:= dDataCad
				EndIf
			EndIf

			cLinha	:= cTipo		

			// Código do associado
			cLinha  := cLinha + "0176"

			// CNPJ
			cLinha  := cLinha + PadL(ccgc,20,"0")  

			// Data da informação
			cLinha  := cLinha + StrZero( Year( dDataAte ) , 4 ) +;
			StrZero( Month( dDataAte ) , 2 ) +;
			StrZero( Day( dDataAte ) , 2 )

			// Data de Cadastro
			SZ7->Z7_DATCAD    	:= dDataCad
			If dDataCad # SZ7->Z7_DATCAD
				dDataCad	:= SZ7->Z7_DATCAD
			EndIf
			
			cLinha  := cLinha + StrZero( Year( dDataCad ), 4 ) +;
			StrZero( Month( dDataCad ) , 2 ) +;
			StrZero( Day( dDataCad ) , 2 )

			// Data última compra
			//			If dDataUC < SZ7->Z7_DTULTCO
			If Empty( dDataUC )
				dDataUC		:= SZ7->Z7_DTULTCO
				nValorUC	:= Round( SZ7->Z7_VLULTCO , 2 )
			EndIf
			cLinha  := cLinha + StrZero( Year( dDataUC ), 4 ) +;
			StrZero( Month( dDataUC ) , 2 ) +;
			StrZero( Day( dDataUC ) , 2 )

			cLinha   := cLinha + StrZero( Int( Round( nValorUC * 100 , 0 ) ) , 15 )

			// Data do maior acúmulo
			If dDataMA == STOD(' ') .And. nValorMA > 0
				//Caso o campo criado ainda não esteja preenchido
				dDataMA		:= SZ7->Z7_DTMAIAC
			Else
				If dDataMA == STOD(' ')
					dDataMA		:= dDataUC
					nValorMA	:= Round( nValorUC , 2 )
				EndIf
			EndIf

			If SZ7->Z7_DTMAIAC >= (dDataAte - 365) .and. SZ7->Z7_DTMAIAC <= dDataAte
				If /*dDataMA < SZ7->Z7_DTMAIAC .or. RODOLFO - NAO ENTENDI O PQ DESSE IF AQUI*/ Round( nValorMA , 2 ) < Round( SZ7->Z7_VLMAIAC , 2 ) .And. dDataUC >= SZ7->Z7_DTMAIAC .And. SZ7->Z7_DTMAIAC >= YearSub(dDatabase,1)
					dDataMA		:= SZ7->Z7_DTMAIAC
					nValorMA	:= Round( SZ7->Z7_VLMAIAC , 2 )
				EndIf
			EndIf //COMENTEI - NAO ENTENDI O PQ TA ACUMULANDO O VALOR DE TODOS OS CLIENTES

			// ADAPTADO BRUNO, NAO GRAVOU O VALOR ANTERIOR , ENTAO ATUALIZA PARA ASSUMIR O VALOR DO ULTIMO TITULO SE ELE FOR MAIOR
			If SZ7->Z7_VLULTCO > SZ7->Z7_VLMAIAC .And. SZ7->Z7_DTMAIAC >= YearSub(dDatabase,1)
				If RecLock( "SZ7" , .F. )
					SZ7->Z7_VLMAIAC :=  SZ7->Z7_VLULTCO
					SZ7->Z7_DTMAIAC := SZ7->Z7_DTULTCO
					SZ7->(MsUnlock())
				Endif 
				dDataMA		:= SZ7->Z7_DTMAIAC
				nValorMA	:= Round( SZ7->Z7_VLMAIAC , 2 )
			Endif 

			If (SZ7->Z7_VLMAIAC > nValorMA .Or. dDataMA < SZ7->Z7_DTMAIAC) .And. SZ7->Z7_DTMAIAC >= YearSub(dDatabase,1)
				dDataMA		:= SZ7->Z7_DTMAIAC
				nValorMA	:= Round( SZ7->Z7_VLMAIAC , 2 )
			Endif 			

			If SZ7->Z7_VLMAIAC <> nValorMA .And. dDataMA == SZ7->Z7_DTMAIAC .And. SZ7->Z7_DTMAIAC >= YearSub(dDatabase,1)
				dDataMA		:= SZ7->Z7_DTMAIAC
				nValorMA	:= Round( SZ7->Z7_VLMAIAC , 2 )
			Endif 					

			dDataMA_Old		:= dDataMA
			nValorMA_Old	:= Round( nValorMA , 2 )

			If ( dDataUC >= (dDataAte - 365) .and. dDataUC <= dDataAte .and. SZ7->Z7_DTMAIAC < (dDataAte - 365) )
				dDataMA		:= dDataMA_Old
				nValorMA	:= Round( nValorMA_Old , 2 )
			EndIf


			If dDataMA > dDataUC
				dDataUC := dDataMA
				nValorUC := nValorMA
			EndIf

			If nValorUC == 0
				dDataUC	:= Stod(' ')
				dDataMA := Stod(' ')
				nValorMA	:= 0
			EndIf


			If nValorMA == nValorDA .And. dDataUC >= YearSub(dDatabase,1)
				dDataMA := dDataUC
			EndIF

			if dDataPV == Stod(' ') .And. dDataUC <> dDataMA .And. dDataUC >= YearSub(dDatabase,1)
				dDataMA := dDataUC
			EndIf

			If nValorMA < nValorDA //.And. dDataUC >= YearSub(dDatabase,1)
				nValorMA := nValorDA
				dDataMA	 := dDataUC
			EndIf					

			If dDataUC < SZ7->Z7_DTULTCO
				dDataUC := SZ7->Z7_DTULTCO
				nValorUC := SZ7->Z7_VLULTCO
			EndIf				
			
			If dDataMA == CTOD(' ')
				dDataMA		:= SZ7->Z7_DTMAIAC
				nValorMA	:= Round( SZ7->Z7_VLMAIAC , 2 )
			EndIf

			If nValorMA ==  nValorUC 
				nValorMa	:= nValorUc
				dDataMA		:= dDataUC
			EndIf

			cLinha  := cLinha + StrZero( Year( dDataMA ) , 4 ) +;
			StrZero( Month( dDataMA ) , 2 ) +;
			StrZero( Day( dDataMA ) , 2 )

			// Valor do Maior Acúmulo			
			cLinha  := cLinha + StrZero( Int( Round( nValorMA * 100 , 0 ) ) , 15 )

			// Valor do débito atual
			cLinha  	:= cLinha + StrZero( Int( Round( nValorDA * 100 , 0 ) ) , 15 )

			// Valor do limite de crédito
			cLinha  := cLinha + StrZero( Int( Round( nLimite * 100 , 0 ) ) , 15 )

			// Média ponderada - atraso de pagamentos
			//cLinha  := cLinha + StrZero( Int( Round( ( nValorC / nValorF ) * 100 , 0 ) ) , 06 )
			cLinha  := cLinha + StrZero( Int( Round( ( nMedPdaAtr ) * 100 , 0 ) ) , 06 )

			// Média aritmética dias de atraso de pagamentos
			//cLinha  := cLinha + StrZero( Int( Round( ( nQtdDias / nQtdTit ) * 100 , 0 ) ) , 06 )
			cLinha  := cLinha + StrZero( Int( Round( ( nMdAriaAtr ) * 100 , 0 ) ) , 06 )

			// Valor do débito atual - a vencer
			cLinha  	:= cLinha + StrZero( Int( Round( nValoraVen * 100 , 0 ) ) , 15 )

			If nValoraVen == 0
				nValoraC := 0
				nQtdDias1 := 0
				nMedPdaVen := 0
				nMdAriaVen := 0
			EndIF
			// Média ponderada - a vencer
			//cLinha  := cLinha + StrZero( Int( Round( ( nValoraC / nValoraF ) * 100 , 0 ) ) , 06 )
			cLinha  := cLinha + StrZero( Int( Round( ( nMedPdaVen ) * 100 , 0 ) ) , 06 )

			// Prazo m‚dio de vendas
			//cLinha  := cLinha + StrZero( Int( Round( ( nQtdDias1 / nQtdTit1 ) * 100 , 0 ) ) , 06 )
			cLinha  := cLinha + StrZero( Int( Round( ( nMdAriaVen) * 100 , 0 ) ) , 06 )


			// Média ponderada - vencido a mais de 5 dias
			//cLinha  := cLinha + StrZero( Round( nValorD5C / nValorD5F , 0 )  , 4 )
			If nValorD5F == 0 .Or. nMedPAtr5 == 0
				nMedPAtr5 := 0
				nValorD5F := 0
			EndIf

			// Valor do débito atual - vencido a mais de 5 dias
			cLinha  	:= cLinha + StrZero( Int( Round( nValorD5F * 100 , 0 ) ) , 15 )			
			cLinha  := cLinha + StrZero( Round( nMedPAtr5 , 0 )  , 4 )



			
			If nValorD15F == 0 .Or. nMedPAtr15 == 0
				nMedPAtr15 := 0
				nValorD15F := 0
			EndIf			
			// Valor do débito atual - vencido a mais de 15 dias
			cLinha  	:= cLinha + StrZero( Int( Round( nValorD15F * 100 , 0 ) ) , 15 )
			// Média ponderada - vencido a mais de 15 dias			
			cLinha  := cLinha + StrZero( Round( nMedPAtr15 , 0 )  , 4 )
			
			If nValorD30F == 0 .Or. nMedPAtr30 == 0
				nMedPAtr30 := 0
				nValorD30F := 0
			EndIf		
			// Valor do débito atual - vencido a mais de 30 dias
			cLinha  	:= cLinha + StrZero( Int( Round( nValorD30F * 100 , 0 ) ) , 15 )	
			// Média ponderada - vencido a mais de 30 dias			
			cLinha  := cLinha + StrZero( Round( nMedPAtr30 , 0 )  , 4 )

			// Data da penúltima compra

		//	If dDataUC > SZ7->Z7_DTULTCO .and. Empty( dDataPV )
		//		dDataPV		:= SZ7->Z7_DTULTCO
		//		nValorPV    := Round( SZ7->Z7_VLULTCO , 2 )
		//	EndIf

		//	If dDataPV < SZ7->Z7_DTPENCO .And. SZ7->Z7_DTPENCO < dDataUC
		//		dDataPV	:= SZ7->Z7_DTPENCO
		//		nValorPV	:= Round( SZ7->Z7_VLPENCO , 2 )
		//	EndIf

			If dDataPV == STOD(' ') .And. SZ7->Z7_DTPENCO < dDataUC .And. SZ7->Z7_DTPENCO <> STOD(' ') .And. SZ7->Z7_VLULTCO > 0
				dDataPV		:= SZ7->Z7_DTPENCO
				nValorPV    := Round( SZ7->Z7_VLULTCO , 2 )
			EndIf

			If dDataPV == dDataUC
				dDataPV		:= STOD(' ')
				nValorPV    := 0
			EndIf

			cLinha  := cLinha + StrZero( Year( dDataPV ), 4 ) +;
			StrZero( Month( dDataPV ) , 2 ) +;
			StrZero( Day( dDataPV ) , 2 )

			// Valor da penúltima compra
			//			If Round( nValorPV , 2 ) < Round( SZ7->Z7_VLPENCO , 2 )
			//				nValorPV	:= Round( SZ7->Z7_VLPENCO , 2 )
			//			EndIf
			
			If nValorPV < 0
				nValorPV := nValorPV * -1
			EndIf
				
			cLinha  	:= cLinha + StrZero( Int( Round( nValorPV * 100 , 0 ) ) , 15 )

			// Situação do calculo do limite de crédito
			cLinha	:= cLinha + "6"

			// Tipo de garantia
			cLinha	:= cLinha + ctpgar

			// Grau da garantia - hipoteca
			cLinha 	:= cLinha + cgraugar

			// Data validade da garantia
			cLinha 	:= cLinha + cdtgar

			// Valor da Garantia
			cLinha 	:= cLinha + cvalgar							

			// Valor da Venda Pagamento Antecipado
			cLinha 	:= cLinha + "000000000000000"

			// Vendas sem crédito
			cLinha	:= cLinha + Space( 02 )

		cLinha  := cLinha + Chr( 13 ) + Chr( 10 )

			FWrite( cArqImp , cLinha , Len( cLinha ) )


			//Valido possiveis erros

			If nMedPAtr15 == 0 .AND. nValorD15F > 0
				cErro += 'Cliente - ' + cCGC + ' - -Débito Vencido à + 5 Dias SEM Média Atraso Vencido à + 5 Dias' + CRLF
			EndIF
			
			If nValoraVen == 0 .And. (( nValoraC / nValoraF ) > 0  .Or.  ( nQtdDias1 / nQtdTit1 ))
				cErro += 'Cliente - ' + cCGC + ' - - Média Ponderada Título a Vencer OU Prazo Médio Vendas SEM Débito Atual a Vencer ' + CRLF
			EndIf

			If nValorMA < nValorDA .And. dDataBase - dDataMA < 365
				cErro += 'Cliente - ' + cCGC + ' - Valor do Maior Acúmulo MENOR QUE Débito Atual ' + CRLF
			EndIf

			If nValorMA < 0
				cErro += 'Cliente - ' + cCGC + ' - Valor do Maior Acúmulo Negativo ' + CRLF
			EndIf			

			If nValorUC < 0
				cErro += 'Cliente - ' + cCGC + ' - Valor da ultima compra Negativo ' + CRLF
			EndIf	

			If dDataUC < dDataMA
				cErro += 'Cliente - ' + cCGC + ' - Data do Maior Acúmulo MAIOR QUE Data da Última Compra ' + CRLF
			EndIf

			If nValorDA < nValorD5F
				cErro += 'Cliente - ' + cCGC + ' - Débito Vencido hà + 5 Dias MAIOR QUE Débito Atual ' + CRLF
			EndIf

			If nValorDA < nValoraVen
				cErro += 'Cliente - ' + cCGC + ' - Débito Atual Total MENOR QUE Débito Atual a Vencer ' + CRLF
			EndIf

			If nValorDA < (nValoraVen + nValorD5F)
				cErro += 'Cliente - ' + cCGC + ' - (Débito a Vencer + Débito Vencido + 5 Dias) MAIOR QUE Débito Atual Total ' + CRLF
			EndIf

			If dDataUC <= dDataPV .And. dDataPV <> Stod(' ')
				cErro += 'Cliente - ' + cCGC + ' - Data Última Compra MENOR OU IGUAL Data Penúltima Compra ' + CRLF
			EndIf
			
			If '*' $ cLinha
				cErro += 'Cliente - ' + cCGC + ' - Linha com caracteres especiais ' + CRLF
			EndIf			

			If nMedPAtr5 < 5 .And. nMedPAtr5 > 0
				cErro += 'Cliente - ' + cCGC + ' - Média Ponderada Título Vencido à + 5 Dias MENOR QUE 5 Dias' + CRLF
			EndIf
			If nMedPAtr15 < 15 .And. nMedPAtr15 > 0
				cErro += 'Cliente - ' + cCGC + ' - Média Ponderada Título Vencido à + 15 Dias MENOR QUE 15 Dias' + CRLF
			EndIf

			If nMedPAtr30 < 30 .And. nMedPAtr30 > 0
				cErro += 'Cliente - ' + cCGC + ' - Média Ponderada Título Vencido à + 30 Dias MENOR QUE 30 Dias' + CRLF
			EndIf
			//*-------------------------------------------------------------------------------------------------------
			// Atualiza dados do cisp na tabela SZ7

			//tratamento para não dar errorlog de "lock required"
			SZ7->(MsUnLock())
			If !SZ7->( DbSeek( xFilial( "SZ7" ) + cCGC ) )
				SZ7->(RecLock('SZ7',.T.))
				SZ7->Z7_FILIAl		:= xFilial( "SZ7" )
				SZ7->Z7_CGC       	:= cCGC
				SZ7->Z7_DATCAD    	:= dDataCad
				SZ7->Z7_DTULTCO		:= dDataUC
				SZ7->Z7_VLULTCO		:= Round( nValorUC , 2 )

				//Protecao a diversos problemas na rotina, B. Vinicius 21/05
				If nValorMA >=  SZ7->Z7_VLMAIAC
					SZ7->Z7_VLMAIAC		:= Round( nValorMA , 2 )
					SZ7->Z7_DTMAIAC		:= dDataMA
				Endif

				SZ7->Z7_DTPENCO		:= dDataPV
				SZ7->Z7_VLPENCO		:= Round( nValorPV , 2 )				
			Else
				SZ7->(RecLock('SZ7',.F.))
			EndIf

			// Data/valor da última compra
			SZ7->Z7_DTULTCO   := dDataUC
			SZ7->Z7_VLULTCO   := Round( nValorUC , 2 )

			// Data/valor do maior acúmulo
			SZ7->Z7_DTMAIAC   := dDataMA
			SZ7->Z7_VLMAIAC   := Round( nValorMA , 2 )

			// Data/valor da penúltima compra
			SZ7->Z7_DTPENCO   := dDataPV
			SZ7->Z7_VLPENCO   := Round( nValorPV , 2 )

			// Valor do débito atual total
			SZ7->Z7_VLDBAT		:= Round( nValorDA , 2 )

			// Valor do débito atual a avencer
			SZ7->Z7_VLDBATA		:= Round( nValoraVen , 2 )

			// Valor débito atual vencido + 5 dias
			SZ7->Z7_VENC05		:= Round( nValorD5F , 2 )

			// Valor débito atual vencido + 15 dias
			SZ7->Z7_VENC15		:= Round( nValorD15F , 2 )

			// Valor débito atual vencido + 30 dias
			SZ7->Z7_VENC30		:= Round( nValorD30F , 2 )

			SZ7->( MsUnLock() )

		
			// Atualiza parâmetro com última data de geração do arquivo
			If nGeraCli == 1
				GetMV( "MV_DTCISP" )
				RecLock( "SX6" , .F. )
				SX6->X6_CONTEUD	:= DtoS( dDataAte )
				SX6->( MsUnLock() )
			Endif
			
		EndDo

		FClose( cArqImp )

		DbSelectArea( "CLI" )
		DbCloseArea( "CLI" )

		DbSelectArea( "EMI" )
		DbCloseArea( "EMI" )

		RetIndex( "SE1" )
		FErase(cIndice+OrdBagExt())

		U_CRZMail(						                                'rodolfo.novaes@totvs.com.br', ;
																			"", ;
																			"", ;
																		'envio do cisp ' + DTOC(dDataBase), ;
																		/*{cArqImp}*/, ;
																			iif(Empty(cErro),'Sem Erros', cErro), ;
																			.T., ;
																		@cErrMsg  )

		Conout('Erro email - ' + cErrMsg)																		
		If Len(cErro) > 0
			HS_MSGINF("Ocorreram os seguintes erros na geração do arquivo :" + CRLF + cErro ,"Geração arquivo CISP")
			MemoWrite( "C:\TEMP\ERROS_CISP_" + DTOS(dDatabase) + ".TXT", cErro )
		EndIf
	EndIf

	Return

	//*-------------------------------------------------------------------------------------------------------------------
Static Function Limpa()

	Local nC     := 0
	Local cSimb  := ""
	Local cCampo := ""
	Local aSimb  := {}

	For nC := 1 to Len( aSimb )
		cSimb	:= aSimb[ nC ]
		cCampo	:= StrTran( cCampo , cSimb , " " )
	Next nC

	cCampo	:= AllTrim( cCampo )	
	Return

	//*----------------------------------------------------------------------------
// Substituido pelo assistente de conversao do AP5 IDE em 07/11/01 ==> Function AjustaSX1
Static Function AjustaSX1()
	
	
	Local aPerg    := {}
	Local cPerg    := "Cisp01"
	Local nXX      := 0

	Aadd( aPerg , { "Arquivo de Clientes?" , "C" , 30 })
	Aadd( aPerg , { "Arquivo Comercial  ?" , "C" , 30 })
	Aadd( aPerg , { "Da  Data           ?" , "D" , 08 })
	Aadd( aPerg , { "Ate Data           ?" , "D" , 08 })
	Aadd( aPerg , { "Gera Clientes      ?" , "N" , 01 })   

	For nXX := 1 to Len( aPerg )
		If !SX1->( DbSeek( cPerg + StrZero( nXX , 2 ) ) )
			RecLock( "SX1" , .T. )
			SX1->X1_GRUPO     := cPerg
			SX1->X1_ORDEM     := StrZero( nXX , 2 )
			SX1->X1_PERGUNT   := aPerg[nXX][1]
			SX1->X1_VARIAVL   := "mv_ch" + Str( nXX , 1 )
			SX1->X1_TIPO      := aPerg[nXX][2]
			SX1->X1_TAMANHO   := aPerg[nXX][3]
			SX1->X1_PRESEL    := 1
			SX1->X1_GSC       := "G"
			SX1->X1_VAR01     := "mv_par" + StrZero( nXX , 2 )
			If nXX == 5
				SX1->X1_DEF01 := "Todos"   
				SX1->X1_DEF02 := "So c/ Movim"
				SX1->X1_GSC   := "C"			
			Endif
		EndIf
	Next nXX
Return


Static Function RetAtr(cCliente,cLoja,nDias)
Local cQuery	:= ''
Local cAliasQry := GetNextAlias()
Local nRet		:= 0

cQuery := "SELECT SUM(E1_SALDO) -  "
cQuery += "ISNULL((SELECT SUM(E1_SALDO) FROM SE1010 SE1A WHERE SE1A.E1_CLIENTE + SE1A.E1_LOJA  IN " + _CLIENTE + " AND SE1A.E1_TIPO = 'RA'  AND SE1A.E1_STATUS = 'A' AND SE1A.D_E_L_E_T_ = ' ' ),0) AS SALDO" 
cQuery += "  FROM " + RetSQLTab('SE1') 
cQuery += "  WHERE  "
cQuery += "  SE1.E1_CLIENTE + SE1.E1_LOJA  IN " + _CLIENTE + "  "
cQuery += " AND DATEDIFF(day, SUBSTRING(SE1.E1_VENCREA,1,4)+'-'+SUBSTRING(SE1.E1_VENCREA,5,2)+'-'+SUBSTRING(SE1.E1_VENCREA,7,2),'" + SUBSTR(DTOS(dDataAte),1,4) +"-"+ SUBSTR(DTOS(dDataAte),5,2) + "-"+ SUBSTR(DTOS(dDataAte),7,2) +"' )  >= " + Str(nDias) + "  "
cQuery += " AND SE1.E1_TIPO = 'NF' "
cQuery += " AND SE1.E1_STATUS = 'A' "
cQuery += "  AND SE1.D_E_L_E_T_ = ' '"

If Select(cAliasQry) > 0 
	(cAliasQry)->(DbCloseArea())
EndIf

TcQuery cQuery new Alias ( cAliasQry )
(cAliasQry)->(dbGoTop())

If !(cAliasQry)->(EOF()) .And. (cAliasQry)->SALDO > 0
	nRet := (cAliasQry)->SALDO
EndIf

(cAliasQry)->(DbCloseArea())
Return iif(nRet < 1, 0, nRet)

Static Function RetDeb(cCliente,cLoja)
Local cQuery	:= ''
Local cAliasQry := GetNextAlias()
Local nRet		:= 0

cQuery := "SELECT SUM(E1_SALDO) -  "
cQuery += "ISNULL((SELECT SUM(E1_SALDO) FROM SE1010 SE1A WHERE SE1A.E1_CLIENTE + SE1A.E1_LOJA  IN " + _CLIENTE + "  AND SE1A.E1_TIPO = 'RA'  AND SE1A.E1_STATUS = 'A' AND SE1A.D_E_L_E_T_ = ' ' ) ,0)AS SALDO" 
cQuery += "  FROM " + RetSQLTab('SE1') 
cQuery += "  WHERE  "
cQuery += "  SE1.E1_CLIENTE + SE1.E1_LOJA  IN " + _CLIENTE + "  "
cQuery += " AND " + DTOS(dDataAte) + " - SE1.E1_VENCREA  < 0  "
cQuery += " AND SE1.E1_TIPO = 'NF' "
cQuery += " AND SE1.E1_STATUS = 'A' "
cQuery += "  AND SE1.D_E_L_E_T_ = ' '"

If Select(cAliasQry) > 0 
	(cAliasQry)->(DbCloseArea())
EndIf

TcQuery cQuery new Alias ( cAliasQry )
(cAliasQry)->(dbGoTop())

If !(cAliasQry)->(EOF()) .And. (cAliasQry)->SALDO > 0
	nRet := (cAliasQry)->SALDO
EndIf

(cAliasQry)->(DbCloseArea())
Return nRet


Static FUNCTION XVLUC() 
Local cQuery	:= ""
Local nRet 		:= 0
Local cAlias   	:= GetNextAlias()         

cQuery := "SELECT F2_VALBRUT AS VLUC FROM SF2010 SF2 WHERE SF2.D_E_L_E_T_ = '' AND F2_CLIENTE + F2_LOJA IN  " + _CLIENTE + " AND SF2.F2_TIPO = 'N' AND F2_EMISSAO = ( "
cQuery += "SELECT TOP 1MAX(F2_EMISSAO) "
cQuery += "FROM SF2010 SF2 "
cQuery += "WHERE F2_CLIENTE + F2_LOJA IN  " + _CLIENTE + "AND  F2_TIPO = 'N' AND SF2.D_E_L_E_T_ = '' "
cQuery += "GROUP BY F2_CLIENTE )"

cQuery  := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGenQry( Nil, Nil, cQuery ), cAlias, .T., .F. )  
nRet  := (cAlias)->VLUC
(cAlias)->(DBCloseArea())
Return nRet   


Static FUNCTION XDTUC() 
Local cQuery	:= ""
Local dData 		:= CTOD(' ')
Local cAlias   	:= GetNextAlias()         

cQuery += "SELECT MAX(F2_EMISSAO) AS DATA"
cQuery += "FROM SF2010 SF2 "
cQuery += "WHERE F2_CLIENTE + F2_LOJA IN  " + _CLIENTE + " AND SF2.D_E_L_E_T_ = '' AND F2_TIPO = 'N' "
cQuery += "GROUP BY F2_CLIENTE "

cQuery  := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGenQry( Nil, Nil, cQuery ), cAlias, .T., .F. )  
dData  := STOD((cAlias)->DATA)
(cAlias)->(DBCloseArea())
Return dData   


Static FUNCTION MAIORACU(dDataMA) 
Local cQuery	:= ""
Local dData 		:= CTOD(' ')
Local nValor		:= 0
Local cAlias   	:= GetNextAlias()         

cQuery += "SELECT SUM(E1_VALOR) AS ACUMULO, E1_EMISSAO "
cQuery += "FROM SE1010 SE1  "
cQuery += "WHERE E1_CLIENTE + E1_LOJA IN " + _CLIENTE + " AND SE1.D_E_L_E_T_ = '' "
cQuery += "  AND E1_EMISSAO >= " + DTOS(YearSub(dDataBase,1)) + " AND E1_TIPO = 'NF' "
cQuery += "GROUP BY E1_EMISSAO  ORDER BY ACUMULO DESC"

cQuery  := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGenQry( Nil, Nil, cQuery ), cAlias, .T., .F. )  
If !(cAlias)->(Eof())
	dDataMA  := STOD((cAlias)->E1_EMISSAO)
	nValor	:= (cAlias)->ACUMULO	
EndIf
(cAlias)->(DBCloseArea())
Return nValor   


Static FUNCTION PENULTIMA(dDataPV) 
Local cQuery	:= ""
Local nRet 		:= 0
Local cAlias   	:= GetNextAlias()         

cQuery := "SELECT F2_EMISSAO DATA , F2_VALBRUT AS VALOR FROM SF2010 SF2 WHERE SF2.D_E_L_E_T_ = '' AND F2_CLIENTE + F2_LOJA IN  " + _CLIENTE + "  AND F2_TIPO = 'N' AND F2_EMISSAO < ( "
cQuery += "SELECT TOP 1 MAX(F2_EMISSAO) "
cQuery += "FROM SF2010 SF2 "
cQuery += "WHERE F2_CLIENTE + F2_LOJA IN  " + _CLIENTE + " AND F2_TIPO = 'N' AND SF2.D_E_L_E_T_ = '' "
cQuery += "GROUP BY F2_CLIENTE ) ORDER BY F2_EMISSAO DESC"

cQuery  := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGenQry( Nil, Nil, cQuery ), cAlias, .T., .F. )  
nRet  := (cAlias)->VALOR
dDataPV := Stod((cAlias)->DATA)
(cAlias)->(DBCloseArea())
Return nRet  

//Média Ponderada de Atraso nos Pagamentos e Média Aritmética dos Dias de Atraso de Pagamentos
Static FUNCTION MDPDATR(nMdAri, nDias) 
Local cQuery	:= ""
Local nRet 		:= 0
Local cAlias   	:= GetNextAlias()    
Local dDtCorte	:= YearSub(dDataBase,1)   
Local nVlrFat	:= 0
Local nDAtr		:= 0
Local nSomDAtr	:= 0
Local nVlrCalc	:= 0
Local nQtdTit	:= 0

cQuery := "SELECT E1_VALOR , E1_VENCTO , E1_BAIXA   "
cQuery += "FROM SE1010 SE1 "
cQuery += "WHERE SE1.D_E_L_E_T_ = '' AND SE1.E1_CLIENTE + SE1.E1_LOJA IN  " + _CLIENTE + " AND E1_TIPO = 'NF' " 

If nDias > 0 //Média Ponderada Atraso Títulos Vencidos e Não Pagos + 5 Dias 
	//cQuery += " AND SE1.E1_VENCTO - " + DTOS(dDataAte) + "   < '" + Str(nDias) + "'  "
	cQuery += " AND DATEDIFF(day,   CONVERT(VARCHAR, CONVERT(DATE, SE1.E1_VENCTO), 103),      CONVERT(VARCHAR, CONVERT(DATE, '" + DTOS(dDataAte) + "' ), 103) ) >  " +  STR(nDias) + " "
	cQuery += " AND E1_BAIXA = ' '  AND '" + DTOS(dDataAte) + "' > SE1.E1_VENCTO "
Else //Média Ponderada de Atraso nos Pagamentos e Média Aritmética dos Dias de Atraso de Pagamentos 
	cQuery += "AND E1_BAIXA <> ' '  AND E1_EMISSAO >= '" + DTOS(dDtCorte) + "' 
//	cQuery += " AND SE1.E1_VENCTO - CAST(E1_BAIXA AS INT)   < '" + Str(nDias) + "'  "
EndIf
cQuery += " AND SE1.E1_STATUS = 'A' "

cQuery  := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGenQry( Nil, Nil, cQuery ), cAlias, .T., .F. )  
While(!(cAlias)->(EOF()))
	nQtdTit++
	nVlrFat += (cAlias)->E1_VALOR
	If (cAlias)->E1_BAIXA > (cAlias)->E1_VENCTO .Or. nDias > 0
		If nDias >  0
			nDatr := DateDiffDay(STOD((cAlias)->E1_VENCTO),dDataBase)
		Else
			nDatr := DateDiffDay(STOD((cAlias)->E1_VENCTO),STOD((cAlias)->E1_BAIXA))
		EndIf
		nVlrCalc += nDatr * (cAlias)->E1_VALOR
		nSomDAtr += nDatr
	EndIF
	(cAlias)->(DbSkip())
EndDo

//Media Ponderada
nRet := nVlrCalc / nVlrFat

//Media Aritimetica 
nMdAri := nDatr / nQtdTit

(cAlias)->(DBCloseArea())
Return nRet  



//Média Ponderada de Títulos a Vencer e Prazo Médio de Vendas 
Static FUNCTION MDPDAVNC(nMdAri) 
Local cQuery	:= ""
Local nRet 		:= 0
Local cAlias   	:= GetNextAlias()     
Local nVlrFat	:= 0
Local nDias		:= 0
Local nSomDAtr	:= 0
Local nVlrCalc	:= 0
Local nQtdTit	:= 0

cQuery := "SELECT E1_VALOR , E1_VENCTO , E1_EMISSAO   "
cQuery += "FROM SE1010 SE1 "
cQuery += "WHERE SE1.D_E_L_E_T_ = '' AND SE1.E1_CLIENTE + SE1.E1_LOJA  IN " + _CLIENTE + " AND E1_TIPO = 'NF' AND E1_VENCTO > '" + DTOS(dDatabase) + "' "
cQuery += " AND SE1.E1_STATUS = 'A' "

cQuery  := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGenQry( Nil, Nil, cQuery ), cAlias, .T., .F. )  
While(!(cAlias)->(EOF()))
	nQtdTit++
	nVlrFat += (cAlias)->E1_VALOR
	nDias := DateDiffDay(STOD((cAlias)->E1_EMISSAO),STOD((cAlias)->E1_VENCTO))
	nVlrCalc += nDias * (cAlias)->E1_VALOR
	nSomDAtr += nDias
	(cAlias)->(DbSkip())
EndDo

//Media Ponderada
nRet := nVlrCalc / nVlrFat

//Media Aritimetica 
nMdAri := nDias / nQtdTit

(cAlias)->(DBCloseArea())
Return nRet  



Static Function RetDbTot(cCliente,cLoja)
Local cQuery	:= ''
Local cAliasQry := GetNextAlias()
Local nRet		:= 0

cQuery := "SELECT SUM(E1_SALDO) -  "
cQuery += "ISNULL((SELECT SUM(E1_SALDO) FROM SE1010 SE1A WHERE SE1A.E1_CLIENTE + SE1A.E1_LOJA  IN " + _CLIENTE + "  AND SE1A.E1_TIPO = 'RA'  AND SE1A.E1_STATUS = 'A' AND SE1A.D_E_L_E_T_ = ' ' ) ,0)AS SALDO" 
cQuery += "  FROM " + RetSQLTab('SE1') 
cQuery += "  WHERE  "
cQuery += "  SE1.E1_CLIENTE + SE1.E1_LOJA IN " + _CLIENTE + "  "
cQuery += " AND SE1.E1_TIPO = 'NF' "
cQuery += " AND SE1.E1_STATUS = 'A' "
cQuery += "  AND SE1.D_E_L_E_T_ = ' '"

If Select(cAliasQry) > 0 
	(cAliasQry)->(DbCloseArea())
EndIf

TcQuery cQuery new Alias ( cAliasQry )
(cAliasQry)->(dbGoTop())

If !(cAliasQry)->(EOF()) .And. (cAliasQry)->SALDO > 0
	nRet := (cAliasQry)->SALDO
EndIf

(cAliasQry)->(DbCloseArea())
Return nRet




Static Function RetCliente(cCGC)
Local cQuery	:= ''
Local cAliasQry := GetNextAlias()
Local cRet		:= "("

cQuery := "SELECT A1_COD + A1_LOJA  AS CLIENTE"
cQuery += "  FROM " + RetSQLTab('SA1') 
cQuery += "  WHERE  "
cQuery += "  A1_CGC LIKE '" + cCGC + "%'  "
cQuery += "  AND D_E_L_E_T_ = ' '"

If Select(cAliasQry) > 0 
	(cAliasQry)->(DbCloseArea())
EndIf

TcQuery cQuery new Alias ( cAliasQry )
(cAliasQry)->(dbGoTop())

While !(cAliasQry)->(EOF()) 
	cRet += "'" + (cAliasQry)->CLIENTE + "',"
	(cAliasQry)->(dbSkip())
EndDo

cRet := SUBSTR(cRet,1,Len(cRet) - 1 ) + ")"

(cAliasQry)->(DbCloseArea())
Return cRet



Static Function RetDtCad(cCGC)
Local cQuery	:= ''
Local cAliasQry := GetNextAlias()
Local dData		:= STOD(' ')

cQuery := "SELECT A1_DTCAD  AS DATA "
cQuery += "  FROM " + RetSQLTab('SA1') 
cQuery += "  WHERE  "
cQuery += "  A1_CGC LIKE '" + cCGC + "%'  "
cQuery += "  AND D_E_L_E_T_ = ' ' ORDER BY A1_DTCAD"

If Select(cAliasQry) > 0 
	(cAliasQry)->(DbCloseArea())
EndIf

TcQuery cQuery new Alias ( cAliasQry )
(cAliasQry)->(dbGoTop())

If !(cAliasQry)->(EOF()) 
	dData := STOD((cAliasQry)->DATA)
EndIf


(cAliasQry)->(DbCloseArea())
Return dData
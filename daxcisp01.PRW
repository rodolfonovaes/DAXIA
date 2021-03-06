#include "rwmake.ch"
#include "PROTHEUS.ch"

//--------------------------------------------------------------
/*/{Protheus.doc} DaxCisp1()

Gera informa��es comerciais para CISP - Informa��es Comercias / Restritiva. 

@param xParam Parameter DescriptionuSER
@return xRet Return Description
@author Fabio Costa - TOTVS - costa.fabio@totvs.com.br
@since 18/07/2019

u_DaxCisp1()


/*/


User Function DaxCisp1()

	Local _oProcess
	Local _aAreaMem := GetArea()
	Local _bProcess := {|_oSelf| EXECUTA(_oSelf) }
	Local cPerg    := "Cisp01"
	Local _aInfo    := {}
	_oProcess := tNewProcess():New("DaxCisp01", "Cisp", _bProcess, "Rotina respons�vel pela gera��o do arquivo semanal CISP.", cPerg, _aInfo, .T., 5, "Gera arquivo CISP.", .T.)
	RestArea(_aAreaMem)

Return


Static Function EXECUTA(_oRegua)

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
	Local dDataMA	:= "  /  /    "
	Local dDataPV	:= "  /  /    "
	Local nValorPV	:= 0
	Local dDataUC	:= "  /  /    "
	Local nValorUC	:= 0

	aSimb	:= { "(", ")", "[", "]", ".", ",", "-", "�", "�", ":", ";" , "/" }
	aMovi   := {}

	If mv_par05 == 2 // S� clientes com movimento
		SD2->( ProcRegua( LastRec()/10 ) )	
		dbSelectArea("SD2")
		dbSetOrder(5)
		dbSeek(xFilial("SD2") + Dtos(mv_par03),.T.)
		do While !Eof() .and. SD2->D2_FILIAL == xFilial("SD2") .and. SD2->D2_EMISSAO <= mv_par04
        	_oRegua:IncRegua1('Verificando Clientes com Movimento')
			If aScan(aMovi,SD2->D2_CLIENTE+SD2->D2_LOJA) == 0
				aadd(aMovi,SD2->D2_CLIENTE+SD2->D2_LOJA)
			Endif
			dbSkip()
		Enddo

		dbSelectArea("SE1")
		dbSetOrder(6)
		dbSeek(xFilial("SE1") + Dtos(mv_par03),.T.)
		do While !Eof() .and. SE1->E1_FILIAL == xFilial("SE1") .and. SE1->E1_EMISSAO <= mv_par04
            _oRegua:IncRegua1('Verificando Clientes com Movimento')
			If aScan(aMovi,SE1->E1_CLIENTE+SE1->E1_LOJA) == 0
				aadd(aMovi,SE1->E1_CLIENTE+SE1->E1_LOJA)
			Endif
			dbSkip()
		Enddo

		dbSelectArea("SE5")
		dbSetOrder(5)
		dbSeek(xFilial("SE5") + Dtos(mv_par03),.T.)
		do While !Eof() .and. SE5->E5_FILIAL == xFilial("SE5") .and. SE5->E5_DATA <= mv_par04
			_oRegua:IncRegua1('Verificando Clientes com Movimento')				
			If aScan(aMovi,SE5->E5_CLIFOR+SE5->E5_LOJA) == 0 .AND. SE5->E5_RECPAG == "R"
				aadd(aMovi,SE5->E5_CLIFOR+SE5->E5_LOJA)
			Endif
			dbSkip()
		Enddo
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

	If !Empty( mv_par01 )
		cArqImp    := FCreate( AllTrim( mv_par01 ) )

		DbSelectArea( "SA1" )
		SA1->( DbSetOrder( 1 ) )

		SA1->( ProcRegua( LastRec() ) )
		SA1->( DbSeek( xFilial( "SA1" ) ) )

		While !SA1->( Eof() ) .and. SA1->A1_FILIAL == xFilial( "SA1" ) 

			_oRegua:IncRegua1('Processando Clientes...')

			If /*Len( AllTrim( SA1->A1_CGC ) ) # 14 .or.*/ Iif(mv_par05==1,.F.,ascan(aMovi,SA1->A1_COD+SA1->A1_LOJA) == 0)
				SA1->( DbSkip() )
				Loop
			EndIf

			tam 	:= LEN(ALLTRIM(SA1->A1_CGC))
			cLinha	:= IIF(tam <= 11 , "2" , "1") // Tipo : 1= CNPJ, 2= CPF

			// C�digo do associado
			cLinha  := cLinha + '0176'
			
			// CNPJ
			cLinha  := cLinha + PadL(Trim(SA1->A1_CGC),20,"0")
			
			// Data da Informa��o 
			cLinha  := cLinha + StrZero( Year( dDataBase ) , 4 ) +;
			StrZero( Month( dDataBase ) , 2 ) +;
			StrZero( Day( dDataBase ) , 2 )
			

			// Raz�o Social
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

			// Endere�o
			cCampo	:= AllTrim( SA1->A1_END )
			Limpa()
			cLinha  := cLinha + Padr(cCampo,60)

			// Bairro
			cCampo	:= AllTrim( SA1->A1_BAIRRO )
			Limpa()
			cLinha  := cLinha + Padr(cCampo,30)

			// Munic�pio
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

			// Regi�o
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

			// Dt Expedi��o do RG
			cLinha := cLinha + "00000000"

			// Filia��o
			cLinha := cLinha + Space(60)

			cLinha  := cLinha + Chr( 13 ) + Chr( 10 )

			FWrite( cArqImp , cLinha , Len( cLinha ) )

			SA1->( DbSkip() )
		EndDo

		FClose( cArqImp )
	EndIf

	If !Empty( mv_par02 )

		If mv_par03 <= GetMV( "MV_DTCISP" ) .and. mv_par05 == 1
			MsgStop( "�ltima remessa de arquivos para a CISP foi em " + DtoC( GetMV( "MV_DTCISP" ) ) +;
			", portanto, uma nova remessa dever� ser superior a esta data !" )
			Return
		EndIf

		If mv_par03 > mv_par04
			MsgStop( "Per�odo de datas inv�lidos !" )
			Return
		EndIf

		cArqImp	:= FCreate( AllTrim( mv_par02 ) )
		cLimite	:= GetMV( "MV_CREDCLI" )

		aFields := {}
		cArqTrb := ""

		AAdd(aFields,{"CLIENTE"  	     ,"C",06,00}) 
		AAdd(aFields,{"LOJA"             ,"C",04,00})

		// cria a tabela tempor�ria
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

		// cria a tabela tempor�ria
		cArqTrb:="T_"+Criatrab(,.F.)
		MsCreate(cArqTrb,aFields,"DBFCDX")
		dbUseArea(.T.,"DBFCDX",cArqTrb,"EMI",.T.,.F.)
		IndRegua("EMI",cArqTrb,"DtoS(EMISSAO)",,,"Ordenando arquivo de trabalho 2...")

		DbSelectArea( "SE1" )

		nIndex	:= RetIndex( "SE1" )
		cIndice := CriaTrab("",.f.)

		cFiltro	:= 'AllTrim( SE1->E1_TIPO ) $ "NF" .and. DtoS(E1_EMISSAO) >= "'+DTOS(mv_par04-365)+'" .and. DtoS(E1_EMISSAO) <= "'+DTOS(mv_par04)+'"'

		IndRegua("SE1",cIndice,"E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM",,cFiltro,"Selecionando Registros...")

		RetIndex( "SE1" )

		#IFNDEF TOP		
		SE1->( DbSetIndex( cIndice ) )
		#ENDIF

		DbSelectArea( "SE5" )
		SE5->( DbSetOrder( 7 ) )

		DbSelectArea( "SZ7" )
		SZ7->( DbSetOrder( 1 ) )

		DbSelectArea( "SA1" ) 
		SA1->( DbSetOrder( 3 ) )

		SA1->( ProcRegua( LastRec() ) )
		SA1->( DbSeek( xFilial( "SA1" ) ) )

		While !SA1->( Eof() ) .and. SA1->A1_FILIAL == xFilial( "SA1" ) 

			If /*Len( AllTrim( SA1->A1_CGC ) ) # 14 .or.*/ Empty( SA1->A1_CGC )  .or. Iif(mv_par05==1,.F.,ascan(aMovi,SA1->A1_COD+SA1->A1_LOJA) == 0)
				IncProc( "Inf. Comerciais do CGC -> " + TransForm( Left( SA1->A1_CGC , 8 ) , "@R XX.XXX.XXX" ) )
				SA1->( DbSkip() )
				Loop
			EndIf

			_oRegua:IncRegua1('Processando registros...')
			
			DbSelectArea( "CLI" )
			DbSelectArea( "EMI" )

			cCGC		:=  Left( SA1->A1_CGC , 8 )
			dDataCad	:=  SA1->A1_DTCAD
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

			While !SA1->( Eof() ) .and. SA1->A1_FILIAL == xFilial( "SA1" ) .and. ;
			Left( SA1->A1_CGC , 8 ) == cCGC 

				_oRegua:IncRegua1('Informacoes Comerciais....')
				If /*Len( AllTrim( SA1->A1_CGC ) ) # 14 .or.*/ Empty( SA1->A1_CGC )
					SA1->( DbSkip() )
					Loop
				EndIf

				If		cLimite == "L"								// Cr�dito por Loja
					nLimite		:= Round( nLimite , 2 )	+ Round( SA1->A1_LC , 2 )
				ElseIf	cLimite == "C" //.and. SA1->A1_LOJA == "01"	// Cr�dito por Cliente - pq loja == 01????????
					nLimite		:= Round( nLimite , 2 )	+ Round( SA1->A1_LC , 2 )
				EndIf

				If !CLI->( DbSeek( SA1->A1_COD + SA1->A1_LOJA ) )
					RecLock( "CLI" , .T. )
					CLI->CLIENTE	:= SA1->A1_COD
					CLI->LOJA		:= SA1->A1_LOJA
					CLI->( MsUnLock() )
				EndIf
				SA1->( DbSkip() )
			EndDo

			If CLI->( RecCount() ) == 0
				Loop
			EndIf

			nValorDA	:= 0.00
			nValorF		:= 0.00
			nValorC		:= 0.00
			nValorD5F	:= 0.00
			nValorD5C	:= 0.00
			nValorD15F	:= 0.00
			nValorD15C	:= 0.00
			nValorD30F	:= 0.00
			nValorD30C	:= 0.00
			nQtdDias	:= 0.00
			nQtdTit		:= 0.00
			nValoraVen	:= 0.00
			nValoraF	:= 0.00
			nValoraC	:= 0.00
			nQtdDias1	:= 0.00
			nQtdTit1	:= 0.00
			lAchou		:= .F.

			EMI->(DbGoTop())
			While !EMI->(EOF())
				RecLock('EMI',.F.)
				EMI->(DbDelete())
				MsUnLock()
				EMI->(DbSkip())
			Enddo

			CLI->( DbGoTop() )
			While !CLI->( Eof() )

				SE1->( DbSetOrder( 2 ) )				
				SE1->( DbSeek( xFilial( "SE1" ) + CLI->CLIENTE + CLI->LOJA ) )

            	_oRegua:IncRegua1('Processando registros...')

				If cCGC $ '35402759|03252545'
				//	Alert('OPA')
				EndIf

				While !SE1->( Eof() ) .and. SE1->E1_FILIAL == xFilial( "SE1" ) .and. ;
				( SE1->E1_CLIENTE + SE1->E1_LOJA ) == ( CLI->CLIENTE + CLI->LOJA )

                	_oRegua:IncRegua1('Processando registros...')


					If AllTrim( SE1->E1_TIPO ) $ "NF" .and. Round( SE1->E1_VALOR , 2 ) > 0.00

						lAchou		:= .T.
						nSaldoABE	:= 0.00

						// T�tulos emitidos antes do per�odo solicitado
						If SE1->E1_EMISSAO < mv_par03

							nSaldoABE	:= Round( SE1->E1_VALOR , 2 )

							If !EMI->( DbSeek( DtoS( SE1->E1_EMISSAO ) ) )
								RecLock( "EMI" , .T. )
								EMI->EMISSAO	:= SE1->E1_EMISSAO
								EMI->CLIENTE	:= SE1->(E1_CLIENTE + E1_LOJA)
							Else
								RecLock( "EMI" , .F. )
							EndIf
							//If !SE1->E1_NUM $ EMI->NUM
								EMI->VALOR_FAT	:= Round( EMI->VALOR_FAT , 2 ) + Round( nSaldoABE , 2 )
								EMI->NUM		:= ALLTRIM(EMI->NUM) + '|' + SE1->E1_NUM
							//EndIf
							EMI->( MsUnLock() )
						EndIf

						// T�tulos emitidos no per�odo
						If SE1->E1_EMISSAO >= mv_par03 .and. SE1->E1_EMISSAO <= mv_par04
							If !EMI->( DbSeek( DtoS( SE1->E1_EMISSAO ) ) )
								RecLock( "EMI" , .T. )
								EMI->EMISSAO	:= SE1->E1_EMISSAO
								EMI->CLIENTE	:= SE1->(E1_CLIENTE + E1_LOJA)
							Else
								RecLock( "EMI" , .F. )
							EndIf
							//If !SE1->E1_NUM $ EMI->NUM
								EMI->VALOR_FAT	:= Round( EMI->VALOR_FAT , 2 ) + Round( SE1->E1_VALOR , 2 )
								EMI->NUM		:= ALLTRIM(EMI->NUM) + '|' + SE1->E1_NUM
							//EndIf
							EMI->( MsUnLock() )
							nSaldoABE		:= Round( SE1->E1_VALOR , 2 )
						EndIf

						// Verifica se j� houve baixa do t�tulo
						If Round( SE1->E1_SALDO , 2 ) # Round( SE1->E1_VALOR , 2 )

							aDatas	:= {}

							SE5->( DbSeek( xFilial( "SE5" ) + SE1->( E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO + E1_CLIENTE + E1_LOJA ) ) )

							While !SE5->( Eof() ) .and.	SE5->E5_FILIAL	== xFilial( "SE5" ) .and. ;
							SE5->E5_PREFIXO	== SE1->E1_PREFIXO .and. ;
							SE5->E5_NUMERO	== SE1->E1_NUM .and. ;
							SE5->E5_PARCELA	== SE1->E1_PARCELA .and. ;
							SE5->E5_CLIFOR	== SE1->E1_CLIENTE .and. ;
							SE5->E5_LOJA	== SE1->E1_LOJA
								If SE5->E5_DATA <= mv_par04
									aAdd( aDatas , SE5->E5_DATA )
								EndIf
								SE5->( DbSkip() )
							EndDo

							aSort( aDatas )

							nSaldoAnt	:= Round( nSaldoABE , 2 )

							For nXX := 1 to Len( aDatas )
								dDataAnt	:= aDatas[ nXX ]

								nSaldo	:=	Round( SaldoTIT( SE1->E1_PREFIXO , SE1->E1_NUM ,;
								SE1->E1_PARCELA , SE1->E1_TIPO , SE1->E1_NATUREZ ,;
								"R" , SE1->E1_CLIENTE , SE1->E1_MOEDA , , dDataAnt ,;
								SE1->E1_LOJA , SE1->E1_FILIAL ) , 2 )
								nSaldo	:= IIF( Round( nSaldo , 2 ) <= 0.02 , 0.00 , Round( nSaldo , 2 ) )

							//	If Str( nSaldo , 15 , 2 ) # Str( nSaldoAnt , 15 , 2 ) RODOLFO = N�o entendi isso aqui
									If !EMI->( DbSeek( DtoS( dDataAnt ) ) )
										RecLock( "EMI" , .T. )
										EMI->EMISSAO	:= dDataAnt
									Else
										RecLock( "EMI" , .F. )
									EndIf

									nVlBaixado		:= Round( Round( nSaldoAnt , 2 ) - Round( nSaldo , 2 ) , 2 )
									EMI->VALOR_REC	:= Round( EMI->VALOR_REC , 2 ) + Round( nVlBaixado , 2 )
									EMI->( MsUnLock() )

									If dDataAnt > SE1->E1_VENCTO
										//nValorF		:= Round( nValorF , 2 )  + Round( nVlBaixado , 2 )
										nValorF		:= Round( nValorF , 2 )  + Round( nSaldoAnt , 2 )
										nValorC		:= Round( nValorC , 2 )  + Round( ( Round( nSaldoAnt , 2 ) * ( dDataAnt - SE1->E1_VENCTO ) ) , 2 )
										nQtdDias	:= nQtdDias	+ ( dDataAnt - SE1->E1_VENCTO )
										nQtdTit		:= nQtdTit	+ 1
									EndIf

							//	EndIf

								nSaldoAnt	:= Round( nSaldo , 2 )

								If Str( nSaldo , 15 , 2 ) <= Str( SE1->E1_SALDO , 15 , 2 )
									Exit
								EndIf

							Next nXX

						EndIf

						nSaldoTIT	:= 0.00
						If SE1->E1_BAIXA > mv_par04 .or. ( !Empty( SE1->E1_BAIXA ) .and. Round( SE1->E1_SALDO , 2 ) > 0.00 )
							nSaldoTIT	:=	Round( SaldoTIT( SE1->E1_PREFIXO , SE1->E1_NUM ,;
							SE1->E1_PARCELA , SE1->E1_TIPO , SE1->E1_NATUREZ ,;
							"R" , SE1->E1_CLIENTE , SE1->E1_MOEDA , , mv_par04 ,;
							SE1->E1_LOJA , SE1->E1_FILIAL ) , 2 )
						Else
							nSaldoTIT	:= Round( SE1->E1_SALDO , 2 )
						EndIf

						nSaldoTIT	:= IIF( Round( nSaldoTIT , 2 ) <= 0.02 , 0.00 , Round( nSaldoTIT , 2 ) )
						nValorDA	:= Round( nValorDA , 2 ) + Round( nSaldoTIT , 2 )

						If Round( nSaldoTIT , 2 ) > 0.00 .and. ( mv_par04 - SE1->E1_VENCTO ) >= 5
							nValorD5F	:= Round( nValorD5F , 2 ) + Round( nSaldoTIT , 2 )
							nValorD5C	:= Round( nValorD5C , 2 )  + Round( ( Round( nSaldoTIT , 2 ) * ( mv_par04 - SE1->E1_VENCTO ) ) , 2 )
						EndIf

						If Round( nSaldoTIT , 2 ) > 0.00 .and. ( mv_par04 - SE1->E1_VENCTO ) >= 15
							nValorD15F	:= Round( nValorD15F , 2 ) + Round( nSaldoTIT , 2 )
							nValorD15C	:= Round( nValorD15C , 2 )  + Round( ( Round( nSaldoTIT , 2 ) * ( mv_par04 - SE1->E1_VENCTO ) ) , 2 )
						EndIf

						If Round( nSaldoTIT , 2 ) > 0.00 .and. ( mv_par04 - SE1->E1_VENCTO ) >= 30
							nValorD30F	:= Round( nValorD30F , 2 ) + Round( nSaldoTIT , 2 )
							nValorD30C	:= Round( nValorD30C , 2 )  + Round( ( Round( nSaldoTIT , 2 ) * ( mv_par04 - SE1->E1_VENCTO ) ) , 2 )
						EndIf

						If Round( nSaldoTIT , 2 ) > 0.00 .and. SE1->E1_VENCTO > mv_par04
							nValoraVen	:= Round( Round( nValoraVen , 2 )	+ Round( nSaldoTIT , 2 ) , 2 )
							nValoraF	:= Round( nValoraF , 2 )	+ Round( nSaldoTIT , 2 )
							nValoraC	:= Round( nValoraC , 2 )	+ Round( ( Round( nSaldoTIT , 2 ) * ( SE1->E1_VENCTO - SE1->E1_EMISSAO ) ) , 2 )
							nQtdDias1	:= nQtdDias1	+ ( SE1->E1_VENCTO - SE1->E1_EMISSAO )
							nQtdTit1	:= nQtdTit1		+ 1
						EndIf

					EndIf

					SE1->( DbSkip() )
				EndDo

				CLI->( DbSkip() )
			EndDo

			//dDataCad	:= CtoD( "" )

			dDataUC		:= CtoD( "" )
			nValorUC	:= 0.00

			dDataPV		:= CtoD( "" )
			nValorPV	:= 0.00
			dData		:= CtoD( "" )

			nSaldoDia	:= 0.00
			nValorMA	:= 0.00
			dDataMA		:= CtoD( "" )

			EMI->( DbGoTop() )

			While !EMI->( Eof() )

				dDataCad		:= IIF( Empty( dDataCad ) , EMI->EMISSAO , dDataCad )
				nSaldoDia		:= Round( nSaldoDia , 2 ) + Round( EMI->VALOR_FAT , 2 )
				nSaldoDia		:= Round( nSaldoDia , 2 ) - Round( EMI->VALOR_REC , 2 )
				//nValorDA		:= Round( nValorDA , 2 ) + Round( EMI->VALOR_FAT , 2 )
				If Round( nSaldoDia , 2 ) > Round( nValorMA , 2 )
					nValorMA	:= Round( nSaldoDia , 2 )
					dDataMA		:= EMI->EMISSAO
				EndIf

				If Round( EMI->VALOR_FAT , 2 ) > 0.00
					dDataPV		:= dDataUC
					nValorPV	:= Round( nValorUC , 2 )
					dDataUC		:= EMI->EMISSAO
					nValorUC	:= Round( EMI->VALOR_FAT , 2 )
				EndIf

				EMI->( DbSkip() )
			EndDo

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
				SZ7->Z7_DTMAIAC		:= dDataMA
				SZ7->Z7_VLMAIAC		:= Round( nValorMA , 2 )
				SZ7->Z7_DTPENCO		:= dDataPV
				SZ7->Z7_VLPENCO		:= Round( nValorPV , 2 )
			Else
				RecLock( "SZ7" , .F. )
				SZ7->Z7_DATCAD    	:= dDataCad
			EndIf

			If ( mv_par04 - SZ7->Z7_DTULTCO ) > 365 .and. nValorDA <= 0 .or. Empty( SZ7->Z7_DTULTCO )
				SZ7->( MsUnLock() )
				Loop
			EndIf

			cLinha	:= "1"

			// C�digo do associado
			cLinha  := cLinha + "0176"

			// CNPJ
			cLinha  := cLinha + PadL(ccgc,20,"0")  

			// Data da informa��o
			cLinha  := cLinha + StrZero( Year( mv_par04 ) , 4 ) +;
			StrZero( Month( mv_par04 ) , 2 ) +;
			StrZero( Day( mv_par04 ) , 2 )

			// Data de Cadastro
			SZ7->Z7_DATCAD    	:= dDataCad
			If dDataCad # SZ7->Z7_DATCAD
				dDataCad	:= SZ7->Z7_DATCAD
			EndIf
			
			cLinha  := cLinha + StrZero( Year( dDataCad ), 4 ) +;
			StrZero( Month( dDataCad ) , 2 ) +;
			StrZero( Day( dDataCad ) , 2 )

			// Data �ltima compra
			//			If dDataUC < SZ7->Z7_DTULTCO
			If Empty( dDataUC )
				dDataUC		:= SZ7->Z7_DTULTCO
				nValorUC	:= Round( SZ7->Z7_VLULTCO , 2 )
			EndIf
			cLinha  := cLinha + StrZero( Year( dDataUC ), 4 ) +;
			StrZero( Month( dDataUC ) , 2 ) +;
			StrZero( Day( dDataUC ) , 2 )

			// Valor da �ltima compra
			//			If Round( nValorUC , 2 ) < Round( SZ7->Z7_VLULTCO , 2 )
			//				nValorUC	:= Round( SZ7->Z7_VLULTCO , 2 )
			//			EndIf

			cLinha   := cLinha + StrZero( Int( Round( nValorUC * 100 , 0 ) ) , 15 )

			// Data do maior ac�mulo
			If Empty( dDataMA )
				dDataMA		:= dDataUC
				nValorMA	:= Round( nValorUC , 2 )
			EndIf

			If SZ7->Z7_DTMAIAC >= (mv_par04 - 365) .and. SZ7->Z7_DTMAIAC <= mv_par04
				If /*dDataMA < SZ7->Z7_DTMAIAC .or. ????? PRA Q ISSO ?  */Round( nValorMA , 2 ) < Round( SZ7->Z7_VLMAIAC , 2 )
					dDataMA		:= SZ7->Z7_DTMAIAC
					nValorMA	:= Round( SZ7->Z7_VLMAIAC , 2 )
				EndIf
			EndIf //COMENTEI - NAO ENTENDI O PQ TA ACUMULANDO O VALOR DE TODOS OS CLIENTES

			dDataMA_Old		:= dDataMA
			nValorMA_Old	:= Round( nValorMA , 2 )

			If ( dDataUC >= (mv_par04 - 365) .and. dDataUC <= mv_par04 .and. SZ7->Z7_DTMAIAC < (mv_par04 - 365) )
				dDataMA		:= dDataMA_Old
				nValorMA	:= Round( nValorMA_Old , 2 )
			EndIf
			cLinha  := cLinha + StrZero( Year( dDataMA ) , 4 ) +;
			StrZero( Month( dDataMA ) , 2 ) +;
			StrZero( Day( dDataMA ) , 2 )

			// Valor do Maior Ac�mulo			
			cLinha  := cLinha + StrZero( Int( Round( nValorMA * 100 , 0 ) ) , 15 )

			// Valor do d�bito atual
			cLinha  	:= cLinha + StrZero( Int( Round( nValorDA * 100 , 0 ) ) , 15 )

			// Valor do limite de cr�dito
			cLinha  := cLinha + StrZero( Int( Round( nLimite * 100 , 0 ) ) , 15 )

			// M�dia ponderada - atraso de pagamentos
			cLinha  := cLinha + StrZero( Int( Round( ( nValorC / nValorF ) * 100 , 0 ) ) , 06 )

			// M�dia aritm�tica dias de atraso de pagamentos
			cLinha  := cLinha + StrZero( Int( Round( ( nQtdDias / nQtdTit ) * 100 , 0 ) ) , 06 )

			// Valor do d�bito atual - a vencer
			cLinha  	:= cLinha + StrZero( Int( Round( nValoraVen * 100 , 0 ) ) , 15 )

			// M�dia ponderada - a vencer
			cLinha  := cLinha + StrZero( Int( Round( ( nValoraC / nValoraF ) * 100 , 0 ) ) , 06 )

			// Prazo m�dio de vendas
			cLinha  := cLinha + StrZero( Int( Round( ( nQtdDias1 / nQtdTit1 ) * 100 , 0 ) ) , 06 )

			// Valor do d�bito atual - vencido a mais de 5 dias
			cLinha  	:= cLinha + StrZero( Int( Round( nValorD5F * 100 , 0 ) ) , 15 )

			// M�dia ponderada - vencido a mais de 5 dias
			cLinha  := cLinha + StrZero( Round( nValorD5C / nValorD5F , 0 )  , 4 )

			// Valor do d�bito atual - vencido a mais de 15 dias
			cLinha  	:= cLinha + StrZero( Int( Round( nValorD15F * 100 , 0 ) ) , 15 )

			// M�dia ponderada - vencido a mais de 15 dias
			cLinha  := cLinha + StrZero( Round( nValorD15C / nValorD15F , 0 )  , 4 )

			// Valor do d�bito atual - vencido a mais de 30 dias
			cLinha  	:= cLinha + StrZero( Int( Round( nValorD30F * 100 , 0 ) ) , 15 )

			// M�dia ponderada - vencido a mais de 30 dias
			cLinha  := cLinha + StrZero( Round( nValorD30C / nValorD30F , 0 )  , 4 )

			// Data da pen�ltima compra

			If dDataUC > SZ7->Z7_DTULTCO .and. Empty( dDataPV )
				dDataPV		:= SZ7->Z7_DTULTCO
				nValorPV    := Round( SZ7->Z7_VLULTCO , 2 )
			EndIf

			If dDataPV < SZ7->Z7_DTPENCO
				dDataPV	:= SZ7->Z7_DTPENCO
				nValorPV	:= Round( SZ7->Z7_VLPENCO , 2 )
			EndIf

			If dDataPV == dDataUC
				dDataPV		:= STOD(' ')
				nValorPV    := 0
			EndIf

			cLinha  := cLinha + StrZero( Year( dDataPV ), 4 ) +;
			StrZero( Month( dDataPV ) , 2 ) +;
			StrZero( Day( dDataPV ) , 2 )

			// Valor da pen�ltima compra
			//			If Round( nValorPV , 2 ) < Round( SZ7->Z7_VLPENCO , 2 )
			//				nValorPV	:= Round( SZ7->Z7_VLPENCO , 2 )
			//			EndIf

			cLinha  	:= cLinha + StrZero( Int( Round( nValorPV * 100 , 0 ) ) , 15 )

			// Situa��o do calculo do limite de cr�dito
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

			// Vendas sem cr�dito
			cLinha	:= cLinha + Space( 02 )

			cLinha  := cLinha + Chr( 13 ) + Chr( 10 )

			FWrite( cArqImp , cLinha , Len( cLinha ) )


			//Valido possiveis erros
			If nValorMA < nValorDA
				cErro += 'Cliente - ' + cCGC + ' - Valor do Maior Ac�mulo MENOR QUE D�bito Atual ' + CRLF
			EndIf
			
			If dDataUC < dDataMA
				cErro += 'Cliente - ' + cCGC + ' - Data do Maior Ac�mulo MAIOR QUE Data da �ltima Compra ' + CRLF
			EndIf

			If nValorDA < nValorD5F
				cErro += 'Cliente - ' + cCGC + ' - D�bito Vencido h� + 5 Dias MAIOR QUE D�bito Atual ' + CRLF
			EndIf

			If nValorDA < nValoraVen
				cErro += 'Cliente - ' + cCGC + ' - D�bito Atual Total MENOR QUE D�bito Atual a Vencer ' + CRLF
			EndIf

			If nValorDA < (nValoraVen + nValorD5F)
				cErro += 'Cliente - ' + cCGC + ' - (D�bito a Vencer + D�bito Vencido + 5 Dias) MAIOR QUE D�bito Atual Total ' + CRLF
			EndIf

			If dDataUC <= dDataPV
				cErro += 'Cliente - ' + cCGC + ' - Data �ltima Compra MENOR OU IGUAL Data Pen�ltima Compra ' + CRLF
			EndIf

			//*-------------------------------------------------------------------------------------------------------
			// Atualiza dados do cisp na tabela SZ7

			// Data/valor da �ltima compra
			SZ7->Z7_DTULTCO   := dDataUC
			SZ7->Z7_VLULTCO   := Round( nValorUC , 2 )

			// Data/valor do maior ac�mulo
			SZ7->Z7_DTMAIAC   := dDataMA
			SZ7->Z7_VLMAIAC   := Round( nValorMA , 2 )

			// Data/valor da pen�ltima compra
			SZ7->Z7_DTPENCO   := dDataPV
			SZ7->Z7_VLPENCO   := Round( nValorPV , 2 )

			// Valor do d�bito atual total
			SZ7->Z7_VLDBAT		:= Round( nValorDA , 2 )

			// Valor do d�bito atual a avencer
			SZ7->Z7_VLDBATA		:= Round( nValoraVen , 2 )

			// Valor d�bito atual vencido + 5 dias
			SZ7->Z7_VENC05		:= Round( nValorD5F , 2 )

			// Valor d�bito atual vencido + 15 dias
			SZ7->Z7_VENC15		:= Round( nValorD15F , 2 )

			// Valor d�bito atual vencido + 30 dias
			SZ7->Z7_VENC30		:= Round( nValorD30F , 2 )

			SZ7->( MsUnLock() )

		
			// Atualiza par�metro com �ltima data de gera��o do arquivo
			If mv_par05 == 1
				GetMV( "MV_DTCISP" )
				RecLock( "SX6" , .F. )
				SX6->X6_CONTEUD	:= DtoS( mv_par04 )
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

		If Len(cErro) > 0
			HS_MSGINF("Ocorreram os seguintes erros na gera��o do arquivo :" + CRLF + cErro ,"Gera��o arquivo CISP")
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

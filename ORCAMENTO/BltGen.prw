#include "rwmake.ch"
#include "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณBltGen    บAutor  ณStanko              บ Data ณ  01/10/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณBoleto Generico para qualquer tipo de banco.                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FIN  		                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function BltGen()

Private cXEmpresa   := ""
Private cXCodBco   := ""
Private cXNomeBco  := ""
Private cXLogoBco  := ""
Private nXTxJurBco := 0

Private _aTitulos  := {}
Private _nCont	   := 1

If MntPerg()
	
	SA6->(dbSetOrder(1))
	If SA6->(dbSeek(xFilial("SA6")+MV_PAR07+MV_PAR08+MV_PAR09))
	
		
		SEE->(dbSetOrder(3))
//		If SEE->(dbSeek(xFilial("SEE")+SA6->(A6_COD+A6_AGENCIA+A6_NUMCON)+PadL(ALLTRIM(MV_PAR10),3,"0")))
		If SEE->(dbSeek(xFilial("SEE")+SA6->(A6_COD+A6_AGENCIA+A6_NUMCON)+MV_PAR10))
			
			If SEE->EE_XNUMBCO <> "237" .And.  SEE->EE_XNUMBCO <> "033"  .And. SEE->EE_XNUMBCO <> "001"
				MsgAlert("Banco nao liberado para uso!")
				Return .F.                              
			EndIf	

			SM0->(dbGoTop())
			
			cXEmpresa := AllTrim(SM0->M0_NOMECOM)+"  - "+"CNPJ "+Transform(SM0->M0_CGC,"@R 99.999.999/9999-99")+"  -  "+ALLTRIM(SM0->M0_ENDCOB)+" - "+ALLTRIM(SM0->M0_CIDCOB)+"/"+ALLTRIM(SM0->M0_ESTCOB) 

			If SEE->EE_XNUMBCO == "237" //BRADESCO

				cXCodBco := "237-2"
				cXNomeBco := "BANCO BRADESCO"
				cXLogoBco := "BRADESCO.BMP"
				nXTxJurBco := 0.2  //Juros de 1% ao mes que sao 0,03333% ao dia  
									
				cXFunDigNN := "BraMod11(_cCart+_cNumero)"
				cXFunCodBar := "BraCodBar()"

			ElseIf SEE->EE_XNUMBCO == "341" //ITAU
				cXCodBco := "341-7"
				cXNomeBco := "BANCO ITAU"
				cXLogoBco := "ITAU.BMP"
				nXTxJurBco := 0.05                      
				
				cXFunDigNN := "ItauMod11(_cNumero)"
				cXFunCodBar := "ItauCodBar()"
			
			
			ElseIf SEE->EE_XNUMBCO == "001" //BRASIL
				cXCodBco := "001-9"
				cXNomeBco := "BANCO DO BRASIL S. A."
				cXLogoBco := "BRASIL.BMP"
				nXTxJurBco := 0.05                      
				
				cXFunDigNN := "MODULO11(_cNumero)"  //funcao padrao!
				cXFunCodBar := "BBCodBar()"
			
			
			ElseIf SEE->EE_XNUMBCO == "033" //SANTANDER
				cXCodBco := "033-7"
				cXNomeBco := "BANCO SANTANDER"
				cXLogoBco := "SANTANDER.BMP"
				nXTxJurBco := 0.05                      
				
				cXFunDigNN := "MODULO11(_cNumero)"  //funcao padrao!
				cXFunCodBar := "StdCodBar()"
										


			ElseIf SEE->EE_XNUMBCO == "104" //CAIXA ECONOMICA
				cXCodBco := "104-0"
				cXNomeBco := "BANCO CAIXA ECONOMICA"
				cXLogoBco := "CAIXA.BMP"
				nXTxJurBco := 0.05  
				
				cXFunDigNN := "MODULO11(_cNumero)"
				cXFunCodBar := "CXCodBar()"


			
			Else
				MsgAlert("Banco/Agencia/Conta/Portador nao parametrizado para impressao!")
				Return Nil
			EndIf
			
			
			MntTela()
			
		Else
			MsgAlert("Parametros bancarios nao encontrado!")
		EndIf
		
	Else
		MsgAlert("Banco/agencia e conta nao encontrado!")
	EndIf
	
	
EndIf

Return Nil




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMntTela   บAutor  ณStanko              บ Data ณ  01/10/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta a tela de selecao dos titulos conforme pergunte      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function MntTela()
Local cFilter		:= ""
Local cIndexName	:= Criatrab(Nil,.F.)
Local cIndexKey	    := "E1_NUM"
Local lExec			:= .F.
Local oDlg


cFilter		+= "E1_FILIAL =='"+xFilial("SE1")+"' .And. E1_SALDO > 0 .And. "
cFilter		+= "E1_PREFIXO   >= '" + MV_PAR01 + "' .And. E1_PREFIXO  <='" + MV_PAR02 + "' .And. "
cFilter		+= "E1_NUM       >= '" + MV_PAR03 + "' .And. E1_NUM      <='" + MV_PAR04 + "' .And. "
cFilter		+= "E1_PARCELA   >= '" + MV_PAR05 + "' .And. E1_PARCELA  <='" + MV_PAR06 + "' .And. "
cFilter		+= "E1_CLIENTE   >= '" + MV_PAR11 + "' .And. E1_CLIENTE  <='" + MV_PAR12 + "' .And. "
cFilter		+= "E1_LOJA      >= '" + MV_PAR13 + "' .And. E1_LOJA     <='" + MV_PAR14 + "' .And. "
cFilter		+= "DTOS(E1_EMISSAO)>='"+DTOS(MV_PAR15)+"' .And. DTOS(E1_EMISSAO) <= '"+DTOS(MV_PAR16)+"' .And. "
cFilter		+= 'DTOS(E1_VENCREA)>="'+DTOS(MV_PAR17)+'" .And. DTOS(E1_VENCREA) <= "'+DTOS(MV_PAR18)+'" .And. '
cFilter		+= "!(E1_TIPO$MVABATIM) "
cFilter		+= ".AND. ALLTRIM(E1_TIPO) $ 'NF/DP/BOL/MUT/FT' "
//cFilter		+= " .AND. E1_XFORMA = 'BOL' "

If MV_PAR19 == 1  // ReImpressao = SIM
	cFilter		+= " .AND. !Empty(E1_NUMBCO) "
	
	cFilter		+= " .AND. AllTrim(E1_PORTADO) == '"+AllTrim(MV_PAR07)+"' "
	cFilter     += " .AND. AllTrim(E1_AGEDEP)  == '"+AllTrim(MV_PAR08)+"' "
	cFilter     += " .AND. AllTrim(E1_CONTA)   == '"+AllTrim(MV_PAR09)+"' "
//	cFilter     += " .AND. AllTrim(E1_XCARTER) == '"+AllTrim(MV_PAR10)+"' "

Else
	
	cFilter		+= " .AND. Empty(E1_NUMBCO) "
	cFilter		+= " .AND. Empty(E1_PORTADO) "
EndIf

DbSelectArea("SE1")
IndRegua("SE1", cIndexName, cIndexKey,, cFilter, "Aguarde selecionando registros....")

If RecCount() > 0

	dbGoTop()


	@ 001,001 TO 400,700 DIALOG oDlg TITLE "Sele็ใo de Titulos"
	@ 001,001 TO 170,350 BROWSE "SE1" MARK "E1_OK"
	@ 180,310 BMPBUTTON TYPE 01 ACTION (lExec := .T.,Close(oDlg))
	@ 180,280 BMPBUTTON TYPE 02 ACTION (lExec := .F.,Close(oDlg))
	@ 180,050 Button "Marca/Desmarca" Size 50,12 PIXEL OF oDlg Action(Marca())
	ACTIVATE DIALOG oDlg CENTERED

	If lExec
		Processa( {|| GeraNN()}	,"Aguarde" ,"Processando...")
	EndIf
Else
	MsgAlert("Nenhum registro encontrado para os parametros informados!")		
	
EndIf

DbSelectArea("SE1")
Set Filter To ""

Return Nil





/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGeraNN    บAutor  ณStanko              บ Data ณ  01/10/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gera/grava o nosso numero                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function GeraNN()

DbSelectArea("SE1")
dbGoTop()
ProcRegua(RecCount())
Do While !EOF()
	
	IncProc()
	
	If Marked("E1_OK")
		
		//Gera o NN somente se estiver em branco
		If Empty(SE1->E1_NUMBCO)
			
			_cCart   :=  Alltrim(SEE->EE_CARTEIR)
			_cNumero :=  Right(Alltrim(SEE->EE_FAXATU),11)
			
			// Garante que o numero tera 11 digitos
			If Len(Alltrim(_cNumero)) <> 11
				_cNumero := Strzero(Val(_cNumero),11)
			Endif
			
			// Verifica se nao estourou o contador, se estourou reinicializa
			// e grava o proximo numero
			dbSelectArea("SEE")
			RecLock("SEE",.F.)
			If _cNumero == "99999999999" .or. Val(_cNumero)==0
				_cNumero:="00000000001"
				SEE->EE_FAXATU := "00000000001"
			Else
				_nFaxAtu := Val(_cNumero) + 1
				_nFaxAtu := Strzero(_nFaxAtu,11)
				SEE->EE_FAXATU := _nFaxAtu
			Endif
			SEE->(MsUnlock())
			
			
			// Gera digito de controle para o numero sequencial
			dvnn := &(cXFunDigNN) //modulo11(_cCart+_cNumero)  //Digito verificador no Nosso Numero
			If Type("dvnn") = "N"
				dvnn := Str(dvnn)
			EndIF
				
			_NossoNum := Alltrim(_cNumero)+Alltrim(dvnn)
			 
			cQuery := "SELECT COUNT(*) QTDNN FROM "+RetSQLName("SE1")+" SE1 "
			cQuery += "WHERE E1_FILIAL ='"+xFilial("SE1")+"' AND SE1.D_E_L_E_T_ = ' '    "
			cQuery += "AND E1_PORTADO = '"+SA6->A6_COD+"' "
			cQuery += "AND E1_NUMBCO = '"+_NossoNum+"'" 
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "TMPNN", .T., .T.)
			nQtdNN := TMPNN->QTDNN           
			TMPNN->(dbCloseArea())
			If nQtdNN > 0 
				MsgAlert("Nosso numero "+_NossoNum+" ja existe. Boleto "+SE1->E1_PREFIXO+"-"+SE1->E1_PARCELA+SE1->E1_TIPO+" nao foi gerado" )
			Else
			
				// Salva Nosso Numero no titulo com digito de controle
				DbSelectArea("SE1")
				RecLock("SE1",.F.)
				SE1->E1_PORTADO := SA6->A6_COD
				SE1->E1_AGEDEP  := SA6->A6_AGENCIA
				SE1->E1_CONTA   := SA6->A6_NUMCON
				//SE1->E1_XCARTER := MV_PAR10
				SE1->E1_NUMBCO := _NossoNum
				SE1->(MsUnlock())
				//Adiciona o titulo para impressao
				AddTitulo()
		
			EndIf	
			
		Else
			_NossoNum := SE1->E1_NUMBCO
			//Adiciona o titulo para impressao
			AddTitulo()
			
		Endif
		
		
		
		
	EndIf
	
	dbSelectArea("SE1")
	DbSkip()
	
EndDo

//Chama a impressao
ChamaImp()

Return Nil



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAddTitulo บAutor  ณStanko              บ Data ณ  01/10/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Adiciona o titulo a ser impresso no vetor principal        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function AddTitulo()

Aadd(_aTitulos,{"","",0,"","","","","","","","","","","","","",0,0,"","",0})

nVlrAbat   :=  SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
nVlrAbat   += SE1->E1_SALDO * SE1->E1_DESCFIN/100
nValor 	   := (SE1->E1_SALDO-nVlrAbat)
lVenc 	   := .F.
dVencto    := SE1->E1_VENCTO
nMulta     := 0
nMora      := 0
_cCart   := 	Alltrim(SEE->EE_CARTEIR)

_cNum := SE1->E1_PREFIXO+" "+SE1->E1_NUM+" "+SE1->E1_PARCELA
_aTitulos[_nCont][01] := SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA           // Prexifo+Numero+Parcela do Titulo
_aTitulos[_nCont][02] := dVencto   												 // Vencimento
_aTitulos[_nCont][03] := nValor                                                 // Valor
_aTitulos[_nCont][04] := SE1->E1_NUMBCO   										//  Nosso Numero

cDigAgen   :=  ALLTRIM(SA6->A6_DVAGE)
cDigCon := ALLTRIM(SA6->A6_DVCTA)

_aTitulos[_nCont][05] := SE1->E1_AGEDEP+cDigAgen   							// Agencia
_aTitulos[_nCont][06] := right(Alltrim(SEE->EE_CONTA),9)  					// Codigo do Cedente RIGHT(Alltrim(SEE->EE_CONTA),9)
_aTitulos[_nCont][07] := _cCart      											// Carteira
_aTitulos[_nCont][08] := StrZero(Day(SE1->E1_EMISSAO),2)+"/"+StrZero(Month(SE1->E1_EMISSAO),2)+"/"+StrZero(Year(SE1->E1_EMISSAO),4)
_aTitulos[_nCont][16] := SE1->E1_CONTA+cDigCon 	  							// Numero da Conta Corrente
_aTitulos[_nCont][17] := SE1->E1_SALDO-nVlrAbat                           //SE1->E1_SALDO
_aTitulos[_nCont][18] := nMulta + nMora
_aTitulos[_nCont][19] := SE1->E1_PEDIDO
_aTitulos[_nCont][20] := SE1->E1_VEND1                                     
_aTitulos[_nCont][21] := SE1->E1_DECRESC




// Obtem dados do cliente
SA1->(DbSetOrder(1))
If SA1->(DbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA))
	_aTitulos[_nCont][09] := SA1->A1_COD+" - "+SA1->A1_NOME
	
	IF .NOT. Empty(Alltrim(SA1->A1_ENDCOB))
		_aTitulos[_nCont][10] := Alltrim(SA1->A1_ENDCOB) + "-" + AllTrim(SA1->A1_BAIRROC)
		_aTitulos[_nCont][11] := SA1->A1_MUNC
		_aTitulos[_nCont][12] := SA1->A1_ESTC
		_aTitulos[_nCont][13] := SA1->A1_CEPC
	ELSE
		_aTitulos[_nCont][10] := SA1->A1_END
		_aTitulos[_nCont][11] := SA1->A1_MUN
		_aTitulos[_nCont][12] := SA1->A1_EST
		_aTitulos[_nCont][13] := SA1->A1_CEP
	ENDIF
	_aTitulos[_nCont][14] := SA1->A1_CGC
	_aTitulos[_nCont][15] := StrZero(Day(dDatabase),2)+"/"+StrZero(Month(dDatabase),2)+"/"+StrZero(Year(dDatabase),4)
Endif
_nCont += 1

Return Nil





/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณChamaImp  บAutor  ณStanko              บ Data ณ  01/10/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Prepara a Impresso									      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ChamaImp()
Private _cBarra  := SPACE(44)
Private _cLinhaD := ""

Private _nLinha  := 0
Private _nEspLin := 0
Private _nPosHor := 0
Private _nPosVer := 0
Private _nTxtBox := 0
Private _nTxtBox2:= 0


oPrint     := TMSPrinter():New("Boleto Generico")
oPrint:SetPortrait()
oPrint:SETPAPERSIZE(1)

If !oPrint:Setup(,,,.F.)
	Return Nil
Endif

oPrint:SETPAPERSIZE(9)


For _nCont := 1 to len(_aTitulos)
	_nLinha  := 1
	                      
	_cBarra  := SPACE(44)
	_cLinhaD := ""
	
	// ajuste para papel A4
	
	oPrint:StartPage()
	
	ImpBlt( 1, .F.)
	ImpBlt( 2, .T.)
	ImpBlt( 3, .T.)
	
	oPrint:EndPage()
	
Next _nCont

	
//oPrint:setup()                                 
oPrint:Preview()

Return Nil


     

Static Function ImpBlt(_nVia, _lSepara) 

LOCAL cContaDig := ""
Local cAgeDig   := ""
LOCAL _oFntLinha
LOCAL _cTxtRodape:=""
LOCAL _nMoraDia      


oFont06  := TFont():New( "Arial",,06,,.F.,,,,,.F. )
oFont06B := TFont():New( "Arial",,06,,.T.,,,,,.F. )
oFont07  := TFont():New( "Arial",,07,,.F.,,,,,.F. )
oFont07B := TFont():New( "Arial",,07,,.T.,,,,,.F. )
oFont08  := TFont():New( "Arial",,08,,.F.,,,,,.F. )
oFont08B := TFont():New( "Arial",,08,,.T.,,,,,.F. )
oFont09  := TFont():New( "Arial",,09,,.F.,,,,,.F. )
oFont09B := TFont():New( "Arial",,09,,.T.,,,,,.F. )
oFont10  := TFont():New( "Arial",,10,,.F.,,,,,.F. )
oFont10B := TFont():New( "Arial",,10,,.T.,,,,,.F. )
oFont11  := TFont():New( "Arial",,11,,.F.,,,,,.F. )
oFont11B := TFont():New( "Arial",,11,,.T.,,,,,.F. )
oFont12  := TFont():New( "Arial",,12,,.F.,,,,,.F. )
oFont12B := TFont():New( "Arial",,12,,.T.,,,,,.F. )
oFont13  := TFont():New( "Arial",,13,,.F.,,,,,.F. )
oFont13B := TFont():New( "Arial",,13,,.T.,,,,,.F. )
oFont14  := TFont():New( "Arial",,14,,.F.,,,,,.F. )
oFont14B := TFont():New( "Arial",,14,,.T.,,,,,.F. )
oFont15  := TFont():New( "Arial",,15,,.F.,,,,,.F. )
oFont15B := TFont():New( "Arial",,15,,.T.,,,,,.F. )
oFont16  := TFont():New( "Arial",,16,,.F.,,,,,.F. )
oFont16B := TFont():New( "Arial",,16,,.T.,,,,,.F. )
oFont17  := TFont():New( "Arial",,17,,.F.,,,,,.F. )
oFont17B := TFont():New( "Arial",,17,,.T.,,,,,.F. )
oFont18  := TFont():New( "Arial",,18,,.F.,,,,,.F. )
oFont18B := TFont():New( "Arial",,18,,.T.,,,,,.F. )
oFont19  := TFont():New( "Arial",,19,,.F.,,,,,.F. )
oFont19B := TFont():New( "Arial",,19,,.T.,,,,,.F. )
oFont20  := TFont():New( "Arial",,20,,.F.,,,,,.F. )
oFont20B := TFont():New( "Arial",,20,,.T.,,,,,.F. )
oFont21  := TFont():New( "Arial",,21,,.F.,,,,,.F. )
oFont21B := TFont():New( "Arial",,21,,.T.,,,,,.F. )
oFont22  := TFont():New( "Arial",,22,,.F.,,,,,.F. )
oFont22B := TFont():New( "Arial",,22,,.T.,,,,,.F. )
oFont23  := TFont():New( "Arial",,23,,.F.,,,,,.F. )
oFont23B := TFont():New( "Arial",,23,,.T.,,,,,.F. )
oFont24  := TFont():New( "Arial",,24,,.F.,,,,,.F. )
oFont24B := TFont():New( "Arial",,24,,.T.,,,,,.F. )
oFont25  := TFont():New( "Arial",,25,,.F.,,,,,.F. )
oFont25B := TFont():New( "Arial",,25,,.T.,,,,,.F. )
oFont26  := TFont():New( "Arial",,26,,.F.,,,,,.F. )
oFont26B := TFont():New( "Arial",,26,,.T.,,,,,.F. )
oFont27  := TFont():New( "Arial",,27,,.F.,,,,,.F. )
oFont27B := TFont():New( "Arial",,27,,.T.,,,,,.F. )
oFont28  := TFont():New( "Arial",,28,,.F.,,,,,.F. )
oFont28B := TFont():New( "Arial",,28,,.T.,,,,,.F. )
oFont29  := TFont():New( "Arial",,29,,.F.,,,,,.F. )
oFont29B := TFont():New( "Arial",,29,,.T.,,,,,.F. )
oFont30  := TFont():New( "Arial",,30,,.F.,,,,,.F. )
oFont30B := TFont():New( "Arial",,30,,.T.,,,,,.F. )



// Posicionamento Horizontal
_nPosHor := 01
_nEspLin := 82
	
// Posicionamento Vertical
_nPosVer := 100
	
// Posicionamento do Texto Dentro do Box
_nTxtBox := 5
_nTxtBox2:= 15

cAgeDig   := ALLTRIM(SA6->A6_AGENCIA) + ALLTRIM(SA6->A6_DVAGE)
cContaDig := "00" + SUBS(SA6->A6_NUMCON,1,5) + SA6->A6_DVCTA //PadL( ALLTRIM(SA6->A6_NUMCON)  + ALLTRIM(SA6->A6_DVCTA), 8, "0")
//_cBarra:=""

_oFntLinha:=oFont11B

IF _lSepara
	_nLinha  += 2
	oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin)+40,_nPosVer,Replicate("- ",120),ofont12,100)
	_nLinha  += 1
   //_nEspLin:=70
ENDIF

IF _nVia == 1 //_VIA_BANCO
	_oFntLinha:=oFont13B
	
	cTexto :="Arquivo da Empresa"
	_cTxtRodape:="Autentica็ใo Mecโnica"

	// Monta codigo de barras do titulo
	&(cXFunCodBar)  //MeuCodBar

	// Monta Linha digitavel
	MinhaLinha()

ELSEIF _nVia == 2 //_VIA_EMPRESA
	cTexto :="Recibo do Pagador"         
	_cTxtRodape:="Autentica็ใo Mecโnica"
	
ELSEIF _nVia == 3 //_VIA_SACADO                                
	 cTexto := _clinhaD //"Recibo do Sacado"
	_cTxtRodape:="Autentica็ใo Mecโnica / FICHA DE COMPENSAวรO"
ENDIF

If !File(cXLogoBco)
	oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+15,_nPosVer,cXNomeBco,ofont13B,100)
Else
	oPrint:SayBitmap(_nPosHor+((_nLinha-1)*_nEspLin)+_nPosVer,0005,cXLogoBco,0350,0089)
EndIf

oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin)+10, _nTxtBox+720,"|"+cXCodBco+"|",oFont15B,100)
                 	
// Linha Digitavel
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+0025,_nPosVer+2230,cTexto,_oFntLinha,100,,,1)

	
// Box Local de Pagto
_nLinha  += 1
_nPosHor := 15
oPrint:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer    ,_nPosHor+(_nLinha*_nEspLin),_nPosVer+1650)
oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox    ,_nPosVer+0010,"Local de Pagamento",ofont08,100)
oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox2+33 ,_nPosVer+0010,"Pagแvel preferencialmente nas ag๊ncias do Banco Bradesco e Bradesco Expresso.",ofont09,100)

// Box Vencimento
oPrint:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+1650,_nPosHor+(_nLinha*_nEspLin),_nPosVer+2230)
oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1660,"Vencimento",ofont08,100)
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox2+30,_nPosVer+2200,StrZero(Day(_aTitulos[_nCont][02]),2)+"/"+StrZero(Month(_aTitulos[_nCont][02]),2)+"/"+StrZero(Year(_aTitulos[_nCont][02]),4),ofont08B,100,,,1)

// Box Cedente
_nLinha  += 1
oPrint:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer,_nPosHor+(_nLinha*_nEspLin),_nPosVer+1650)
oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0010,"Beneficiแrio",ofont08,100)
oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin+30)+_nTxtBox2,_nPosVer+0010,cXEmpresa,ofont08,100)

// Box Agencia/Codigo Cedente
oPrint:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+1650,_nPosHor+(_nLinha*_nEspLin),_nPosVer+2230)
oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1660,"Ag๊ncia/C๓digo Beneficiแrio",ofont08,100)

If SEE->EE_XNUMBCO == "001"                                                    
 oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin+30)+_nTxtBox2,_nPosVer+2200,transform(cAgeDig,"@R 9999-9")+"/"+Substr(cContaDig,3,5)+"-"+Substr(cContaDig,8,1),ofont08B,100,,,1)

ElseIf SEE->EE_XNUMBCO == "104"                                                    
 oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin+30)+_nTxtBox2,_nPosVer+2200,"0267.870.00000370-5",ofont08B,100,,,1)

ElseIf SEE->EE_XNUMBCO == "033"                                                              
 oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin+30)+_nTxtBox2,_nPosVer+2200,ALLTRIM(SA6->A6_AGENCIA)+"/"+ALLTRIM(SEE->EE_CODEMP),ofont08B,100,,,1)

Else
 oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin+30)+_nTxtBox2,_nPosVer+2200,transform(cAgeDig,"@R 9999-9")+"/"+transform(cContaDig,"@R 9999999-X"),ofont08B,100,,,1)
EndIf  

// Box Data do documento
_nLinha  += 1
oPrint:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer,_nPosHor+(_nLinha*_nEspLin),_nPosVer+0420)
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0010,"Data do documento",ofont08,100)
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox2+30,_nPosVer+0100,_aTitulos[_nCont][08],ofont08,100)

// Box Numero do Documento
oPrint:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+0420,_nPosHor+(_nLinha*_nEspLin),_nPosVer+0790)
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0430,"Nฐ do documento",ofont08,100)
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox2+30,_nPosVer+0530,_aTitulos[_nCont][01],ofont08,100)

// Box Especie Doc
oPrint:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+0790,_nPosHor+(_nLinha*_nEspLin),_nPosVer+1050)
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0800,"Esp้cie Doc",ofont08,100)
oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox2+30,_nPosVer+0900,"DM",ofont08,100)

// Box Aceite
oPrint:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+1050,_nPosHor+(_nLinha*_nEspLin),_nPosVer+1170)
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1060,"Aceite",ofont08,100)
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox2+30,_nPosVer+1080,"Nใo",ofont08,100)


// Box Data do Processamento
oPrint:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+1170,_nPosHor+(_nLinha*_nEspLin),_nPosVer+1650)
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1180,"Data do Processamento",ofont08,100)
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox2+30,_nPosVer+1280,_aTitulos[_nCont][15],ofont08,100)

// Box Cart./nosso numero
oPrint:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+1650,_nPosHor+(_nLinha*_nEspLin),_nPosVer+2230)
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1660,"Nosso N๚mero",ofont08,100)           

If SEE->EE_XNUMBCO == "001"                                                    
	cAux := Substr(SEE->EE_CODEMP,1,7)+StrZero(Val(Substr(_aTitulos[_nCont][04],1,Len(AllTrim(_aTitulos[_nCont][04]))-1)),10)
	oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox2+30,_nPosVer+1960,cAux,ofont08B,100)	

ElseIf SEE->EE_XNUMBCO == "033"                                                    
	oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox2+30,_nPosVer+1960,Transform((AllTrim(_aTitulos[_nCont][04])),"@R 99999999999-X"),ofont08B,100)

ElseIf SEE->EE_XNUMBCO == "237"                                                    
	oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox2+30,_nPosVer+1960,"09" + "/"+Transform((AllTrim(_aTitulos[_nCont][04])),"@R 99999999999-X"),ofont08B,100)

Else
	oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox2+30,_nPosVer+1960,Transform(_aTitulos[_nCont][04],"@R 99999999999-X"),ofont08B,100)
EndIf	


_nLinha  += 1
                   

	// Box Uso do Banco
	oPrint:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer,_nPosHor+(_nLinha*_nEspLin),_nPosVer+0420)
	oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0010,"Uso do Banco",ofont08,100)
	oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox2+30,_nPosVer+0050,"",ofont08,100)

	// Box Carteira
	oPrint:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+0420,_nPosHor+(_nLinha*_nEspLin),_nPosVer+0552)
	oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0430,"Carteira",ofont08,100)
	oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox2+30,_nPosVer+0480,_aTitulos[_nCont][07],ofont08,100)


/*If SEE->EE_XNUMBCO == "033"

	oPrint:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer,_nPosHor+(_nLinha*_nEspLin),_nPosVer+0420)
	oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0010,"Carteira",ofont08,100)
	oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox2+30,_nPosVer+0050,"101 - RAPIDA COM REGISTRO",ofont08,100)


Else

	// Box Uso do Banco
	oPrint:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer,_nPosHor+(_nLinha*_nEspLin),_nPosVer+0420)
	oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0010,"Uso do Banco",ofont08,100)
	oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox2+30,_nPosVer+0050,"",ofont08,100)

	// Box Carteira
	oPrint:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+0420,_nPosHor+(_nLinha*_nEspLin),_nPosVer+0552)
	oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0430,"Carteira",ofont08,100)
	oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox2+30,_nPosVer+0480,_aTitulos[_nCont][07],ofont08,100)

EndIf	*/
	
// Box Esp้cie Moeda
oPrint:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+0552,_nPosHor+(_nLinha*_nEspLin),_nPosVer+0790)
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0562,"Esp้cie moeda",ofont08,100)
oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox2+30,_nPosVer+0662,"R$",ofont08,100)

// Box Quantidade
oPrint:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+0790,_nPosHor+(_nLinha*_nEspLin),_nPosVer+1170)
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0800,"Quantidade",ofont08,100)

// Box Valor
oPrint:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+1170,_nPosHor+(_nLinha*_nEspLin),_nPosVer+1650)
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1180,"Valor",ofont08,100)

// Box Valor do documento
oPrint:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+1650,_nPosHor+(_nLinha*_nEspLin),_nPosVer+2230)
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1660,"1(=) Valor do documento",ofont08,100)
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox2+30,_nPosVer+2200,transform(_aTitulos[_nCont][17],"@E 999,999,999.99"),ofont08B,100,,,1)

_nLinha  += 1

// Box Desconto / Abatimento
oPrint:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+1650,_nPosHor+(_nLinha*_nEspLin),_nPosVer+2230)
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1660,"2(-) Desconto/abatimento",ofont08,100)
     
//nao mostra desconto 0
If SEE->EE_XNUMBCO $ "001/237"
	If  _aTitulos[_nCont][21] > 0                                                    
		oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox2+30,_nPosVer+2200,transform(_aTitulos[_nCont][21],"@E 999,999,999.99"),ofont08B,100,,,1)
	EndIf	
Else
	oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox2+30,_nPosVer+2200,transform(_aTitulos[_nCont][21],"@E 999,999,999.99"),ofont08B,100,,,1)
EndIf		

// Box Instrucoes
oPrint:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer,_nPosHor+(_nLinha*_nEspLin)+4*_nEspLin,_nPosVer+1650)
oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+10,_nPosVer+0010,"Instru็๕es (Texto de responsabilidade do Beneficiแrio)",ofont08,100)

//MENSAGENS
//_nMoraDia:=Round((_aTitulos[_nCont][17]*nXTxJurBco)/30,2)
oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+50 ,_nPosVer+0010,"Ap๓s o vencimento, cobrar juros de 6% ao m๊s.",ofont09,100)
//oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+100 ,_nPosVer+0010,"Ap๓s o vencimento cobrar multa de 2%.",ofont09,100)
//oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+150,_nPosVer+0010,"Sujeito a Protesto ap๓s o vencimento.",ofont09,100)


// Box Outras deducoes
_nLinha  += 1
oPrint:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+1650,_nPosHor+(_nLinha*_nEspLin),_nPosVer+2230)
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1660,"3(-) Outras dedu็๕es",ofont08,100)

//oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0010,"*** Valores Expressos em R$ ***",ofont09B,100)

// Box Mora / Multa
_nLinha  += 1
oPrint:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+1650,_nPosHor+(_nLinha*_nEspLin),_nPosVer+2230)
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1660,"4(+) Mora/Multa",ofont08,100)   
//oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+30,_nPosVer+2000,transform(_aTitulos[_nCont][18],"@E 999,999,999.99"),ofont08B,100)

//oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+0010,"Ap๓s o vencimento cobrar multa de R$  "+transform(_aTitulos[_nCont][17]*0.02,"@E 9,999,999.99"),ofont09B,100)
//oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+0010,"Pagavel em qualquer banco at้ o vencimento",ofont09B,100)

// Box Outros acrescimos                                                     '
_nLinha  += 1
oPrint:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+1650,_nPosHor+(_nLinha*_nEspLin),_nPosVer+2230)
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1660,"5(+) Outros Acr้scimos",ofont08,100)
//oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin)-50+_nTxtBox+10,_nPosVer+0010,"Apos 3 dias uteis serแ enviado ao cartorio",ofont09B,100)



//oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin)-50+_nTxtBox+10,_nPosVer+0010,"Mora Diแria de R$ "+transform((_aTitulos[_nCont][17]*0.03)/30,"@E 9,999,999.99"),ofont09B,100)
//oPrint:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+10,_nPosVer+0010,"Apos o vencimento juros de 0,33% ao dia (R$ "+AllTrim(Transform(_aTitulos[_nCont][17]*0.0033,"@E 9,999,999.99"))+")",ofont09B,100)

// Box Valor cobrado
_nLinha  += 1
oPrint:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+1650,_nPosHor+(_nLinha*_nEspLin),_nPosVer+2230)
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1660,"6(=) Valor cobrado",ofont08,100)
//oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+30,_nPosVer+2000,transform(_aTitulos[_nCont][3],"@E 999,999,999.99"),ofont08B,100)


// Box Sacado
_nLinha  += 1
oPrint:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer,_nPosHor+(_nLinha*_nEspLin)+_nEspLin,_nPosVer+2230)
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0010,"Pagador:",ofont08,100)
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox2,_nPosVer+0150,_aTitulos[_nCont][09],ofont08,100) // Nome Sacado
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox2,_nPosVer+1400,IIF(SA1->A1_PESSOA = 'J',"CNPJ: "+Transform(_aTitulos[_nCont][14],"@R 99.999.999/9999-99"),"CPF: "+Transform(_aTitulos[_nCont][14],"@R 999.999.999-99")),ofont08,100) // CNPJ Sacado
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox2+0030,_nPosVer+0150,_aTitulos[_nCont][10],ofont08,100) // End. Sacado
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox2+0060,_nPosVer+0150,Transform(_aTitulos[_nCont][13],"@R 99999-999"),ofont08,100) // CEP Sacado
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox2+0060,_nPosVer+0550,_aTitulos[_nCont][11],ofont08,100) // Cidade Sacado
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox2+0060,_nPosVer+1000,_aTitulos[_nCont][12],ofont08,100) // Estado Sacado
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+0120,_nPosVer+0010,"Sacador/Avalista:",ofont08,100)
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+0120,_nPosVer+1660,"C๓digo de Baixa:",ofont08,100)
oPrint:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+0170,_nPosVer+2230,_cTxtRodaPe,ofont08,100,,,1)

// Imprime codigo de barras
//MSBAR("INT25",14.2,0.5,_cbarra,oPrint,.F.,,.T.,0.02,1,NIL,NIL,NIL,.F.)  //0.0135
   
If _nVia == 3 //_VIA_BANCO
//	MsBar("INT25",26.5,2,_cbarra,oPrint,.F.,Nil,Nil,0.028,1.8,Nil,Nil,"A",.F.)  	    // folha A4 - driver windows 2000 server
//      MSBAR(cTypeBar,nRow ,nCol,cCode       ,oPrint,lCheck,Color,lHorz,nWidth,nHeigth,lBanner,cFont,cMode,lPrint,nPFWidth,nPFHeigth)
//      MSBAR("INT25" ,26   ,1.5 ,CB_RN_NN[1] ,oPrint,.F.   ,     ,     ,      ,1.2    ,       ,     ,     ,.F.)            // exemplo zana 
	MsBar("INT25" ,27   ,2   ,_cbarra     ,oPrint,.F.   ,     ,     ,      ,1.2    ,       ,     ,     ,.F.)  	    // folha A4 - driver windows 2000 server


EndIf	


IF File(cXLogoBco)
	// Imprime Logotipo do Banco
	oPrint:Saybitmap(0015,0060,cXLogoBco,0080,0070)

	// Imprime Logotipo do Banco
	oPrint:Saybitmap(0515,0060,cXLogoBco,0080,0070)

	// Imprime Logotipo do Banco
	oPrint:Saybitmap(0690,1850,cXLogoBco,0180,0180)

	// Imprime Logotipo do Banco
	oPrint:Saybitmap(2105,0060,cXLogoBco,0080,070)
ENDIF
	
Return (.T.)













Static FUNCTION MinhaLinha()

Local _nI   := 1
Local _nAux := 0
_cLinhaD     := ""
_nDigito    := 0
_cCampo     := ""
Fator      := CTOD("07/10/1997")
/*
Primeiro Campo
Posicao  Tam       Descricao
01 a 03   03   Codigo de Compensacao do Banco (237)
04 a 04   01   Codigo da Moeda (Real => 9, Outras => 0)
05 a 09   05   Pos 1 a 5 do campo Livre(Pos 1 a 4 Dig Agencia + Pos 1 Dig Carteira)
10 a 10   01   Digito Auto Correcao (DAC) do primeiro campo

 9 000.000001 00100.030568 2 54100000087659
Segundo Campo
11 a 20   10   Pos 6 a 15 do campo Livre(Pos 2 Dig Carteira + Pos 1 a 9 Nosso Num)
21 a 21   01   Digito Auto Correcao (DAC) do segundo campo

Terceiro Campo
22 a 31   10   Pos 16 a 25 do campo Livre(Pos 10 a 11 Nosso Num + Pos 1 a 8 Conta Corrente + "0")
32 a 32   01   Digito Auto Correcao (DAC) do terceiro campo

Quarto Campo
33 a 33   01   Digito Verificador do codigo de barras

Quinto Campo
34 a 37   04   Fator de Vencimento
38 a 47   10   Valor
*/

// Calculo do Primeiro Campo
_cCampo := ""
_cCampo := Subs(_cBarra,1,4)+Subs(_cBarra,20,5)
// Calculo do digito do Primeiro Campo
DigitoLin(2)
_cLinhaD += Subs(_cCampo,1,5)+"."+Subs(_cCampo,6,4)+Alltrim(Str(_nDigito))

// Insere espaco
_cLinhaD += " "

// Calculo do Segundo Campo
_cCampo := ""
_cCampo := Subs(_cBarra,25,10)
// Calculo do digito do Segundo Campo
DigitoLin(1)
_cLinhaD += Subs(_cCampo,1,5)+"."+Subs(_cCampo,6,5)+Alltrim(Str(_nDigito))

// Insere espaco
_cLinhaD += " "

// Calculo do Terceiro Campo
_cCampo := ""
_cCampo := Subs(_cBarra,35,10)
// Calculo do digito do Terceiro Campo
DigitoLin(1)
_cLinhaD += Subs(_cCampo,1,5)+"."+Subs(_cCampo,6,5)+Alltrim(Str(_nDigito))

// Insere espaco
_cLinhaD += " "

// Calculo do Quarto Campo
_cCampo := ""
_cCampo := Subs(_cBarra,5,1)
_cLinhaD += _cCampo

// Insere espaco
_cLinhaD += " "

// Calculo do Quinto Campo
_cCampo := ""
_cCampo := Subs(_cBarra,6,4)+Subs(_cBarra,10,10)
_cLinhaD += _cCampo

Return(.T.)





Static Function DigitoLin (_nCnt)

Local _nI   := 1
Local _nAux := 0
Local _nInt := 0
_nDigito    := 0

For _nI := 1 to Len(_cCampo)
	
	_nAux := Val(Substr(_cCampo,_nI,1)) * _nCnt
	If _nAux >= 10
		_nAux:= (Val(Substr(Str(_nAux,2),1,1))+Val(Substr(Str(_nAux,2),2,1)))
	Endif
	
	_nCnt += 1
	If _nCnt > 2
		_nCnt := 1
	Endif
	_nDigito += _nAux
	
Next _nI

If (_nDigito%10) > 0
	_nInt    := Int(_nDigito/10) + 1
Else
	_nInt    := Int(_nDigito/10)
Endif

_nInt    := _nInt * 10
_nDigito := _nInt - _nDigito

Return()














/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMarca     บAutor  ณStanko              บ Data ณ  01/10/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Marca/desmarca todos os titulos selecionados               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Marca()
Local cMarkX

DbSelectArea("SE1")
DbGotop()

While !Eof()
	
	If Marked("E1_OK")
		cMarkX := Thismark()
	Else
		cMarkX := "" //cMRKORI
	EndIf
	
	Reclock("SE1")
	SE1->E1_OK := cMarkX
	MsUnLock()
	
	DbSkip()
EndDo

DbGotop()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMntPerg   บAutor  ณStanko              บ Data ณ  01/10/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta o pergunte/parametros                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function MntPerg()
Local cPerg  := "BLTGEN"
Local aPergs :={}
Local aRet   :={}
Local lRet   :=.T.
Local aSN    :={"Sim","Nใo"}

Aadd(aPergs,{1,"De Prefixo"   	,Space(3),"@!",'.T.',     ,'.T.',15,.F.}) 			//01
Aadd(aPergs,{1,"Ate Prefixo"  	,Space(3),"@!",'.T.',     ,'.T.',15,.F.}) 			//02
Aadd(aPergs,{1,"De Numero"    	,Space(9),"@!",'.T.',     ,'.T.',32,.F.}) 			//03
Aadd(aPergs,{1,"Ate Numero"   	,Space(9),"@!",'.T.',     ,'.T.',32,.F.}) 			//04
Aadd(aPergs,{1,"De Parcela"   	,Space(2),"@!",'.T.',     ,'.T.',10,.F.}) 			//05
Aadd(aPergs,{1,"Ate Parcela"  	,Space(2),"@!",'.T.',     ,'.T.',10,.F.}) 			//06
Aadd(aPergs,{1,"Portador"     	,Space(3),"@!",'.T.',"SEE237",'.T.',30,.T.}) 	   		//07
Aadd(aPergs,{1,"Agencia"      	,Space(5),"@!",'.F.',     ,'.F.',30,.F.}) 			//08
Aadd(aPergs,{1,"Conta"        	,Space(10),"@!",'.F.',     ,'.F.',35,.F.})			//09
Aadd(aPergs,{1,"Carteira"     	,Space(03),"@!",'.F.',     ,'.F.',15,.F.}) 		//10
Aadd(aPergs,{1,"De Cliente"   	,Space(6),"@!",'.T.',"CLI",'.T.',35,.F.}) 			//11
Aadd(aPergs,{1,"Ate Cliente"  	,Space(6),"@!",'.T.',"CLI",'.T.',35,.F.}) 			//12
Aadd(aPergs,{1,"De Loja"      	,Space(2),"@!",'.T.',     ,'.T.',15,.F.}) 			//13
Aadd(aPergs,{1,"Ate Loja"      	,Space(2),"@!",'.T.',     ,'.T.',15,.F.}) 			//14
Aadd(aPergs,{1,"De Emissao"   	,Ctod("01/01/12"),"@D",'.T.',,'.T.',55,.F.})  		//15
Aadd(aPergs,{1,"Ate Emissao"  	,Ctod("31/12/22"),"@D",'.T.',,'.T.',55,.F.})  		//16
Aadd(aPergs,{1,"De Vencimento"  ,Ctod("01/01/12"),"@D",'.T.',,'.T.',55,.F.})  	//17
Aadd(aPergs,{1,"Ate Vencimento" ,Ctod("31/12/22"),"@D",'.T.',,'.T.',55,.F.}) 		//18
Aadd(aPergs,{3,"Reimpressao"	,1,aSN,20,'.T.',.T.})  							//19

lRet:=ParamBox(aPergs ,"Boleto de Cobran็a",aRet,,,.t.,,,,(cPerg+cFilAnt),.t.,.t.)

If lRet
	MV_PAR19:= IIF(Valtype(MV_PAR19)<>"N", Ascan(aSN,MV_PAR19), MV_PAR19)
EndIf

Return lRet





/**************************************************************************************************************************************/
/**************************************************************************************************************************************/
/**************************************************************************************************************************************/
/*******************************************INICIO DAS FUNCOES DO BANCO 341 - ITAU ****************************************************/
/**************************************************************************************************************************************/ 
/**************************************************************************************************************************************/
/**************************************************************************************************************************************/



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณItauMod11 บAutor  ณStanko              บ Data ณ  01/10/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Modelo 11 - Itau                                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ItauMod11(cData)
LOCAL L, D, P := 0
L := Len(cdata)
D := 0
P := 1
While L > 0
	P := P + 1
	D := D + (Val(SubStr(cData, L, 1)) * P)
	If P = 9
		P := 1
	End
	L := L - 1
End
D := 11 - (mod(D,11))
If (D == 0 .Or. D == 1 .Or. D == 10 .Or. D == 11)
	D := 1
End
Return(D)
                               
         
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณItauCodBarบAutor  ณStanko              บ Data ณ  01/10/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Codigo de Barras - Itau                                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ItauCodBar()
//

Local cBanco :=AllTrim(SEE->EE_XNUMBCO)+"9"
Local cAGencia := AllTrim(SEE->EE_AGENCIA)
Local cConta := AllTrim(SEE->EE_CONTA)
Local cDacCC := AllTrim(SEE->EE_DVCTA)
Local cCompleto := AllTrim(_aTitulos[_nCont][04])
Local cNroDoc := Substr(cCompleto,1,Len(cCompleto)-1)
Local nValor :=_aTitulos[_nCont][03]
Local dVencto :=_aTitulos[_nCont][02]
Local _cCart := MV_PAR10

LOCAL bldocnufinal := strzero(val(cNroDoc),8)
LOCAL blvalorfinal := strzero(int(nValor*100),10)
LOCAL dvnn         := 0
LOCAL dvcb         := 0
LOCAL dv           := 0
LOCAL NN           := ""
LOCAL RN           := ""
LOCAL CB           := ""
LOCAL s            := ""
LOCAL _cfator      := strzero(dVencto - ctod("07/10/97"),4)

//tira o digito

//
//-------- Definicao do NOSSO NUMERO
s    :=  cAgencia + cConta + _cCart + bldocnufinal
dvnn := ItauMod10(s) // digito verifacador Agencia + Conta + Carteira + Nosso Num
//alert(_cCart)
//alert(bldocnufinal)
//alert(Str(dvnn))

NN   := _cCart + bldocnufinal + '-' + AllTrim(Str(dvnn))
//
//	-------- Definicao do CODIGO DE BARRAS
s    := cBanco + _cfator + blvalorfinal + _cCart + bldocnufinal + AllTrim(Str(dvnn)) + cAgencia + cConta + cDacCC + '000'
dvcb := ItauMod11(s)
CB   := SubStr(s, 1, 4) + AllTrim(Str(dvcb)) + SubStr(s,5)
//
//-------- Definicao da LINHA DIGITAVEL (Representacao Numerica)
//	Campo 1			Campo 2			Campo 3			Campo 4		Campo 5
//	AAABC.CCDDX		DDDDD.DEFFFY	FGGGG.GGHHHZ	K			UUUUVVVVVVVVVV
//
// 	CAMPO 1:
//	AAA	= Codigo do banco na Camara de Compensacao
//	  B = Codigo da moeda, sempre 9
//	CCC = Codigo da Carteira de Cobranca
//	 DD = Dois primeiros digitos no nosso numero
//	  X = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
//
s    := cBanco + _cCart + SubStr(bldocnufinal,1,2)
dv   := ItauMod10(s)
RN   := SubStr(s, 1, 5) + '.' + SubStr(s, 6, 4) + AllTrim(Str(dv)) + '  '
//
// 	CAMPO 2:
//	DDDDDD = Restante do Nosso Numero
//	     E = DAC do campo Agencia/Conta/Carteira/Nosso Numero
//	   FFF = Tres primeiros numeros que identificam a agencia
//	     Y = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
//
s    := SubStr(bldocnufinal, 3, 6) + AllTrim(Str(dvnn)) + SubStr(cAgencia, 1, 3)
dv   := ItauMod10(s)
RN   := RN + SubStr(s, 1, 5) + '.' + SubStr(s, 6, 5) + AllTrim(Str(dv)) + '  '
//
// 	CAMPO 3:
//	     F = Restante do numero que identifica a agencia
//	GGGGGG = Numero da Conta + DAC da mesma
//	   HHH = Zeros (Nao utilizado)
//	     Z = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
s    := SubStr(cAgencia, 4, 1) + cConta + cDacCC + '000'
dv   := ItauMod10(s)
RN   := RN + SubStr(s, 1, 5) + '.' + SubStr(s, 6, 5) + AllTrim(Str(dv)) + '  '
//
// 	CAMPO 4:
//	     K = DAC do Codigo de Barras
RN   := RN + AllTrim(Str(dvcb)) + '  '
//
// 	CAMPO 5:
//	      UUUU = Fator de Vencimento
//	VVVVVVVVVV = Valor do Titulo
RN   := RN + _cfator + StrZero(Int(nValor * 100),14-Len(_cfator))
//     

_cBarra := CB
		

Return({CB,RN,NN})         
         
                                                      
         
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณItauMod10 บAutor  ณStanko              บ Data ณ  01/10/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Modelo 10 - Itau                                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
         
Static Function ItauMod10(cData)
LOCAL L,D,P := 0
LOCAL B     := .F.
L := Len(cData)
B := .T.
D := 0
While L > 0
	P := Val(SubStr(cData, L, 1))
	If (B)
		P := P * 2
		If P > 9
			P := P - 9
		End
	End
	D := D + P
	L := L - 1
	B := !B
End
D := 10 - (Mod(D,10))
If D = 10
	D := 0
End
Return(D)
         


                                                                                                                                        
/**************************************************************************************************************************************/
/**************************************************************************************************************************************/
/**************************************************************************************************************************************/
/*******************************************INICIO DAS FUNCOES DO BANCO 237 - BRADESCO ****************************************************/
/**************************************************************************************************************************************/
/**************************************************************************************************************************************/
/**************************************************************************************************************************************/


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณBraMod11  บAutor  ณStanko              บ Data ณ  01/10/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Modelo 11 - Bradesco                                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function BraMod11(cData) //Modulo 11 com base 7

LOCAL L, D, P := 0
L := Len(cdata)
D := 0
P := 1
DV:= " "

While L > 0
	P := P + 1
	D := D + (Val(SubStr(cData, L, 1)) * P)
	If P = 7   //Volta para o inicio, ou seja comeca a multiplicar por 2,3,4...
		P := 1
	End
	L := L - 1
End

if D >=11
	_nResto := mod(D,11)  //Resto da Divisao
	//D := 11 - (mod(D,11)) // Diferenca 11 (-) Resto da Divisao
	D := 11 - _nResto
	DV:=STR(D)
endif //renato

If _nResto == 0
	DV := "0"
End
If _nResto == 1
	DV := "P"
End

Return(DV)





/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ BraDg11   บ Autor ณ Stanko             บ Data ณ  23/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Calculo do Digito Verificador Codigo de Barras - MOD(11)   บฑฑ
ฑฑบ          ณ Pesos (2 a 9)                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function BraDg11()

Local _nCnt   := 0
Local _nPeso  := 2
Local _nJ     := 1
Local _nResto := 0

For _nJ := Len(_cCampo) To 1 Step -1
	_nCnt  := _nCnt + Val(SUBSTR(_cCampo,_nJ,1))*_nPeso
	_nPeso :=_nPeso+1
	if _nPeso > 9
		_nPeso := 2
	endif
Next _nJ

_nResto:=(_ncnt%11)

_nResto:=11 - _nResto

if _nResto == 0 .or. _nResto==1 .or. _nResto > 9
	_nDigbar:='1'
else
	_nDigbar:=Str(_nResto,1)
endif

Return(_nDigbar)




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณBraCodBar บAutor  ณStanko              บ Data ณ  01/10/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Codigo de Barras - Bradesco                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function BraCodBar()
Local _nAgen   := ""
Local _nCntCor := ""
Local _nI      := 0
Local Fator      := CTOD("07/10/1997")
/*
- Posicoes fixas padrao Banco Central
Posicao  Tam       Descricao
01 a 03   03   Codigo de Compensacao do Banco (237)
04 a 04   01   Codigo da Moeda (Real => 9, Outras => 0)
05 a 05   01   Digito verificador do codigo de barras
06 a 19   14   Valor Nominal do Documento sem ponto

- Campo Livre Padrao Bradesco
Posicao  Tam       Descricao
20 a 23   03   Agencia Cedente sem digito verificador
24 a 25   02   Carteira
25 A 36   11   Nosso Numero sem digito verificador
37 A 43   07   Conta Cedente sem digiro verificador
44 A 44   01   Zero
*/

// Monta numero da Agencia sem dv e com 4 caracteres
// Retira separador de digito se houver
For _nI := 1 To Len(_aTitulos[_nCont][05])
	If Subs(_aTitulos[_nCont][05],_nI,1) $ "0/1/2/3/4/5/6/7/8/9/"
		_nAgen += Subs(_aTitulos[_nCont][05],_nI,1)
	Endif
Next _nI
// retira o digito verificador
_nAgen := StrZero(Val(Subs(Alltrim(_nAgen),1,Len(_nAgen)-1)),4)

// Monta numero da Conta Corrente sem dv e com 7 caracteres
// Retira separador de digito se houver
For _nI := 1 To Len(_aTitulos[_nCont][16])
	If Subs(_aTitulos[_nCont][16],_nI,1) $ "0/1/2/3/4/5/6/7/8/9/"
		_nCntCor += Subs(_aTitulos[_nCont][16],_nI,1)
	Endif
Next _nI
// retira o digito verificador
_nCntCor := StrZero(Val(Subs(Alltrim(_nCntCor),1,Len(_nCntCor)-1)),7)

//_nCntCor := StrZero(Val(Subs(Alltrim(_nCntCor),1,Len(_nCntCor)-1)),7)

_cCampo := ""
// Pos 01 a 03 - Identificacao do Banco
_cCampo += "237"
// Pos 04 a 04 - Moeda
_cCampo += "9"
// Pos 06 a 09 - Fator de vencimento
_cCampo += Str((_aTitulos[_nCont][02] - Fator),4)
// Pos 10 a 19 - Valor
_cCampo += StrZero(Int(_aTitulos[_nCont][03]*100),10)
// Pos 20 a 23 - Agencia
_cCampo += _nAgen
// Pos 24 a 25 - Carteira
_cCampo += _aTitulos[_nCont][07]
// Pos 26 a 36 - Nosso Numero
_cCampo += Subs(_aTitulos[_nCont][04],1,11)
// Pos 37 a 43 - Conta do Cedente
_cCampo += _nCntCor
// Pos 44 a 44 - Zero
_cCampo += "0"
_cDigitbar := BraDg11()

// Monta codigo de barras com digito verificador
_cBarra := Subs(_cCampo,1,4)+_cDigitbar+Subs(_cCampo,5,43)

Return()








/**************************************************************************************************************************************/
/**************************************************************************************************************************************/
/**************************************************************************************************************************************/
/*******************************************INICIO DAS FUNCOES DO BANCO 001 - BRASIL****************************************************/
/**************************************************************************************************************************************/ 
/**************************************************************************************************************************************/
/**************************************************************************************************************************************/


						
Static Function BBCodBar()

//Static Function Ret_cBarra(	cPrefixo	,cNumero	,cParcela	,cTipo	,;
//						cBanco		,cAgencia	,cConta		,cDacCC	,;
//						cNroDoc		,nValor		,cCart		,cMoeda	, dVencto )

Local cBanco :=AllTrim(SEE->EE_XNUMBCO)
Local cAGencia := AllTrim(SEE->EE_AGENCIA)
Local cConta := AllTrim(SEE->EE_CONTA)
Local cDacCC := AllTrim(SEE->EE_DVCTA)
Local cCompleto := AllTrim(_aTitulos[_nCont][04])
Local cNroDoc := Substr(cCompleto,1,Len(cCompleto)-1)               
Local nValor :=_aTitulos[_nCont][03]
Local dVencto :=_aTitulos[_nCont][02]
Local cCart := AllTrim(MV_PAR10) 
Local cMoeda := "9"                                                                     


Local cNosso		:= ""
Local cDigNosso		:= ""
Local NNUM			:= ""
Local cCampoL		:= ""
Local cFatorValor	:= ""
Local cLivre		:= ""
Local cDigBarra		:= ""
Local cBarra		:= ""
Local cParte1		:= ""
Local cDig1			:= ""
Local cParte2		:= ""
Local cDig2			:= ""
Local cParte3		:= ""
Local cDig3			:= ""
Local cParte4		:= ""
Local cParte5		:= ""
Local cDigital		:= ""
Local aRet			:= {}

		
NNUM := StrZero(Val(SEE->EE_CODEMP),7)+StrZero(Val(cNroDoc),10)	//STRZERO(Val(cNroDoc),11)

// campo livre			// verificar a conta e carteira
cCampoL := "000000"+NNUM+cCart

//campo livre do codigo de barra                   // verificar a conta
cFatorValor  := u_fatorBB(dVencto)+strzero(nValor*100,10)
cFatorD      := u_fatorBB(dVencto)
nValorD		 := strzero(nValor*100,10)

cLivre := cBanco+cMoeda+cFatorValor+cCampoL

// campo do codigo de barra
cDigBarra := U_CALC_5pBB( cLivre )
cBarra    := Substr(cLivre,1,4)+cDigBarra+Substr(cLivre,5,40)

cNovoB := "001"
cNovoB += "9"
cNovoB += cFatorD
cNovoB += nValorD                  
cNovoB += "000000"
cNovoB += NNUM
cNovoB += cCart
cDigNovo := U_CALC_5pBB( cNovoB )
cNovoB    := Substr(cNovoB,1,4)+cDigNovo+Substr(cNovoB,5,40)


// composicao da linha digitavel
cParte1  := cBanco+cMoeda
cParte1  := cParte1 + SUBSTR(cBarra,20,5)
cDig1    := U_DIGIT0BB( cParte1 )
cParte2  := SUBSTR(cBarra,25,10)
cDig2    := U_DIGIT0BB( cParte2 )
cParte3  := SUBSTR(cBarra,35,10)
cDig3    := U_DIGIT0BB( cParte3 )
cParte4  := " "+cDigBarra+" "
cParte5  := cFatorValor

cDigital := substr(cParte1,1,5)+"."+substr(cparte1,6,4)+cDig1+" "+;
			substr(cParte2,1,5)+"."+substr(cparte2,6,5)+cDig2+" "+;
			substr(cParte3,1,5)+"."+substr(cparte3,6,5)+cDig3+" "+;
			cParte4+;
			cParte5

Aadd(aRet,cBarra)
Aadd(aRet,cDigital)
Aadd(aRet,NNUM)		

_cBarra := cBarra

Return aRet


sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	If base == 1
		base := 9
	EndIf
	auxi   := Val(SubStr(cBase, idig, 1)) * base
	sumdig := SumDig+auxi
	base   := base - 1
	iDig   := iDig-1
EndDo
auxi := mod(Sumdig,11)
If auxi == 10
	auxi := "X"
Else
	auxi := str(auxi,1,0)
EndIf
Return(auxi)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณDIGIT001  บAutor  ณMicrosiga           บ Data ณ  02/13/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPara calculo da linha digitavel do Banco do Brasil          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BOLETOS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DIGIT0BB(cVariavel)
Local Auxi := 0, sumdig := 0

cbase  := cVariavel
lbase  := LEN(cBase)
umdois := 2
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	auxi   := Val(SubStr(cBase, idig, 1)) * umdois
	sumdig := SumDig+If (auxi < 10, auxi, (auxi-9))
	umdois := 3 - umdois
	iDig:=iDig-1
EndDo
cValor:=AllTrim(STR(sumdig,12))
nDezena:=VAL(ALLTRIM(STR(VAL(SUBSTR(cvalor,1,1))+1,12))+"0")
auxi := nDezena - sumdig

If auxi >= 10
	auxi := 0
EndIf
Return(str(auxi,1,0))


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณFATOR		บAutor  ณMicrosiga           บ Data ณ  02/13/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCalculo do FATOR  de vencimento para linha digitavel.       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BOLETOS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User function FatorBB(dVencto)
If Len(ALLTRIM(SUBSTR(DTOC(dVencto),7,4))) = 4
	cData := SUBSTR(DTOC(dVencto),7,4)+SUBSTR(DTOC(dVencto),4,2)+SUBSTR(DTOC(dVencto),1,2)
Else
	cData := "20"+SUBSTR(DTOC(dVencto),7,2)+SUBSTR(DTOC(dVencto),4,2)+SUBSTR(DTOC(dVencto),1,2)
EndIf
cFator := STR(1000+(STOD(cData)-STOD("20000703")),4)
Return(cFator)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณCALC_5p   บAutor  ณMicrosiga           บ Data ณ  02/13/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCalculo do digito do nosso numero do                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BOLETOS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function CALC_5pBB(cVariavel)
Local Auxi := 0, sumdig := 0

cbase  := cVariavel
lbase  := LEN(cBase)
base   := 2
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	If base >= 10
		base := 2
	EndIf
	auxi   := Val(SubStr(cBase, idig, 1)) * base
	sumdig := SumDig+auxi
	base   := base + 1
	iDig   := iDig-1
EndDo
auxi := mod(sumdig,11)
If auxi == 0 .or. auxi == 1 .or. auxi >= 10
	auxi := 1
Else
	auxi := 11 - auxi
EndIf

Return(str(auxi,1,0))



/**************************************************************************************************************************************/
/**************************************************************************************************************************************/
/**************************************************************************************************************************************/
/*******************************************INICIO DAS FUNCOES DO BANCO 104 - CAIXA ECONOMICA******************************************/
/**************************************************************************************************************************************/ 
/**************************************************************************************************************************************/
/**************************************************************************************************************************************/





Static Function CXCodBar()
Local _nAgen   := ""
Local _nCntCor := ""
Local _nI      := 0
Local Fator      := CTOD("07/10/1997")
/*
- Posicoes fixas padrao Banco Central
Posicao  Tam       Descricao
01 a 03   03   Codigo de Compensacao do Banco (237)
04 a 04   01   Codigo da Moeda (Real => 9, Outras => 0)
05 a 05   01   Digito verificador do codigo de barras
06 a 19   14   Valor Nominal do Documento sem ponto

- Campo Livre Padrao Bradesco
Posicao  Tam       Descricao
20 a 23   03   Agencia Cedente sem digito verificador
24 a 25   02   Carteira
25 A 36   11   Nosso Numero sem digito verificador
37 A 43   07   Conta Cedente sem digiro verificador
44 A 44   01   Zero
*/

// Monta numero da Agencia sem dv e com 4 caracteres
// Retira separador de digito se houver
For _nI := 1 To Len(_aTitulos[_nCont][05])
	If Subs(_aTitulos[_nCont][05],_nI,1) $ "0/1/2/3/4/5/6/7/8/9/"
		_nAgen += Subs(_aTitulos[_nCont][05],_nI,1)
	Endif
Next _nI
// retira o digito verificador
_nAgen := StrZero(Val(Subs(Alltrim(_nAgen),1,Len(_nAgen)-1)),4)

// Monta numero da Conta Corrente sem dv e com 7 caracteres
// Retira separador de digito se houver
For _nI := 1 To Len(_aTitulos[_nCont][16])
	If Subs(_aTitulos[_nCont][16],_nI,1) $ "0/1/2/3/4/5/6/7/8/9/"
		_nCntCor += Subs(_aTitulos[_nCont][16],_nI,1)
	Endif
Next _nI
// retira o digito verificador
_nCntCor := StrZero(Val(Subs(Alltrim(_nCntCor),1,Len(_nCntCor)-1)),7)

_cCampo := ""
// Pos 01 a 03 - Identificacao do Banco
_cCampo += "104"
// Pos 04 a 04 - Moeda
_cCampo += "9"
// Pos 06 a 09 - Fator de vencimento
_cCampo += Str((_aTitulos[_nCont][02] - Fator),4)
// Pos 10 a 19 - Valor
_cCampo += StrZero(Int(_aTitulos[_nCont][03]*100),10)
// Pos 20 a 23 - Agencia
_cCampo += _nAgen
// Pos 24 a 25 - Carteira
_cCampo += _aTitulos[_nCont][07]
// Pos 26 a 36 - Nosso Numero
_cCampo += Subs(_aTitulos[_nCont][04],1,11)
// Pos 37 a 43 - Conta do Cedente
_cCampo += _nCntCor
// Pos 44 a 44 - Zero
_cCampo += "0"
_cDigitbar := CXDg11()

// Monta codigo de barras com digito verificador
_cBarra := Subs(_cCampo,1,4)+_cDigitbar+Subs(_cCampo,5,43)

Return()




Static Function CXDg11()

Local _nCnt   := 0
Local _nPeso  := 2
Local _nJ     := 1
Local _nResto := 0

For _nJ := Len(_cCampo) To 1 Step -1
	_nCnt  := _nCnt + Val(SUBSTR(_cCampo,_nJ,1))*_nPeso
	_nPeso :=_nPeso+1
	if _nPeso > 9
		_nPeso := 2
	endif
Next _nJ

_nResto:=(_ncnt%11)

_nResto:=11 - _nResto

if _nResto == 0 .or. _nResto==1 .or. _nResto > 9
	_nDigbar:='1'
else
	_nDigbar:=Str(_nResto,1)
endif

Return(_nDigbar)







/****************************SANTANDER*************************************************/
Static Function StdCodBar()

//Static Function Ret_cBarra(	cPrefixo	,cNumero	,cParcela	,cTipo	,;
//						cBanco		,cAgencia	,cConta		,cDacCC	,;
//						cNroDoc		,nValor		,cCart		,cMoeda	, dVencto )

Local cBanco :=AllTrim(SEE->EE_XNUMBCO)
Local cAGencia := AllTrim(SEE->EE_AGENCIA)
Local cConta := AllTrim(SEE->EE_CONTA)//AllTrim(SEE->EE_CONTA)
Local cDacCC := AllTrim(SEE->EE_DVCTA)
Local cCompleto := AllTrim(_aTitulos[_nCont][04])
Local cNroDoc := Substr(cCompleto,1,Len(cCompleto)-1)               
Local nValor :=_aTitulos[_nCont][03]
Local dVencto :=_aTitulos[_nCont][02]
Local cCart := AllTrim(MV_PAR10) 
Local cMoeda := "9"                                                                     


Local cNosso		:= ""
Local cDigNosso		:= ""
Local NNUM			:= ""
Local cCampoL		:= ""
Local cFatorValor	:= ""
Local cLivre		:= ""
Local cDigBarra		:= ""
Local cBarra		:= ""
Local cParte1		:= ""
Local cDig1			:= ""
Local cParte2		:= ""
Local cDig2			:= ""
Local cParte3		:= ""
Local cDig3			:= ""
Local cParte4		:= ""
Local cParte5		:= ""
Local cDigital		:= ""
Local aRet			:= {}

		
NNUM := StrZero(Val(SEE->EE_CODEMP),7)+StrZero(Val(cCompleto),13)	//STRZERO(Val(cNroDoc),11)

// campo livre			// verificar a conta e carteira


//campo livre do codigo de barra                   // verificar a conta
cFatorValor  := u_fatorBB(dVencto)+strzero(nValor*100,10)
cFatorD      := u_fatorBB(dVencto)
nValorD		 := strzero(nValor*100,10)


cCampoL := "9"+NNUM+"0101"

cLivre := cBanco+cMoeda+cFatorValor+cCampoL

// campo do codigo de barra
cDigBarra := U_CALC_5pBB( cLivre )
cBarra    := Substr(cLivre,1,4)+cDigBarra+Substr(cLivre,5,40)

cNovoB := "001"
cNovoB += "9"
cNovoB += cFatorD
cNovoB += nValorD                  
cNovoB += "000000"
cNovoB += NNUM
cNovoB += cCart
cDigNovo := U_CALC_5pBB( cNovoB )
cNovoB    := Substr(cNovoB,1,4)+cDigNovo+Substr(cNovoB,5,40)


// composicao da linha digitavel
cParte1  := cBanco+cMoeda
cParte1  := cParte1 + SUBSTR(cBarra,20,5)
cDig1    := U_DIGIT0BB( cParte1 )
cParte2  := SUBSTR(cBarra,25,10)
cDig2    := U_DIGIT0BB( cParte2 )
cParte3  := SUBSTR(cBarra,35,10)
cDig3    := U_DIGIT0BB( cParte3 )
cParte4  := " "+cDigBarra+" "
cParte5  := cFatorValor

cDigital := substr(cParte1,1,5)+"."+substr(cparte1,6,4)+cDig1+" "+;
			substr(cParte2,1,5)+"."+substr(cparte2,6,5)+cDig2+" "+;
			substr(cParte3,1,5)+"."+substr(cparte3,6,5)+cDig3+" "+;
			cParte4+;
			cParte5

Aadd(aRet,cBarra)
Aadd(aRet,cDigital)
Aadd(aRet,NNUM)		

_cBarra := cBarra

Return aRet




///////




#include "PROTHEUS.CH"

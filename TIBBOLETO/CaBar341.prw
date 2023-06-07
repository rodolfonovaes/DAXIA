#Include 'Totvs.ch'

/*/{Protheus.doc} CaBar341
BANCO ITAU - Calcula cod.barras, linha digitavel, DACs e nosso numero
@author Giane
@since 09/03/2016
@version 1.0
@param cBanco, character, (Codigo do Banco)
@param cArqCFG, character, (Nome do arquivo de configuracao de boletos)
@param cAgencia, character, (codigo da agencia)
@param cConta, character, (codigo da conta)
@param cNossoNum, character, (NossoNumero)
@param nVlrTit, numeric, (valor do titulo)
@param cParcela, character, (parcela do titulo)
@param dDtMovto, date, (data do processamento)
@param cNumTit, caracter, (Numero do titulo)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function CaBar341(cBanco, cArqCFG, cAgencia, cConta, cNossoNum, nVlrTit, cParcela, dDtMovto, cNumTit)

Local cFuncao 	:= ''
Local cCodigo	:= ''
Local cDACCodigo:= '' 
Local cCampo1	:= ''
Local cCampo2	:= ''
Local cCampo3	:= ''
Local cCampo4	:= ''
Local cCampo5	:= ''
Local cMoeda 	:= ''
Local nLen		:= Len(cNossoNum)
Local cFator	:= ''
Local cVencto	:= ''	
Local cDtFator	:= ''
Local cDAC3Anexo:= ''
Local cDAC		:= ''
Local cPartBar	:= ''
Local cLDig		:= ''
Local cCodBar	:= ''
Local cNumAux	:= ''
Local cNossoN2	:= ''

//calcula fator de vencimento
dVencto	:= Datavalida(SE1->E1_VENCTO,.T.)
cDtFator:= GetPvProfString(cBanco,"dDtFatorVencto",'07/10/1997', cArqCFG )
cFator	:= strzero(dVencto - CTOD(cDtFator),4)  

//Inicia calculos da linha digitavel, cod barras 
//cModulo := GetPvProfString(cBanco,"nModuloBarra",'10', cArqCFG )  //qual modulo de calculo o banco utiliza
//cFuncMod := 'U_Modulo10' 											//nome da funcao de calculo de modulo
cMoeda := GetPvProfString(cBanco,"cCodMoedaBarra",'9', cArqCFG )  //codigo da moeda

If FindFunction('U_Modulo10')
	//calcula nosso numero 
	cNumAux :=  AllTrim(cAgencia) + AllTrim(cConta) + Alltrim((cAliasSEE)->EE_CODCART) + Substr(cNossoNum,1,nLen)
	cNumAux	:= AllTrim(cNumAux)
	cNossoN2:= ( Alltrim((cAliasSEE)->EE_CODCART) + "/"  + Alltrim(Substr(cNossoNum,1,nLen)) + "-" + U_Modulo10(cNumAux))
	//	
	
	cCampo1	:= cBanco + cMoeda + Alltrim((cAliasSEE)->EE_CODCART) + substr(cNossoNum,1,2) 
	cDAC	:= U_Modulo10( cCampo1 )
	//cDAC	:= &(cFuncao)
	cCampo1	:= cCampo1 + cDAC

	cCodigo 	:= cAgencia + cConta + Alltrim((cAliasSEE)->EE_CODCART) + cNossoNum
	cDACCodigo  := U_Modulo10( cCodigo )
 	//cDACCodigo := &(cFuncao)
 	
 	cCampo2	:= substr(cNossoNum,3,nLen-2) + cDACCodigo + substr(cAgencia,1,3) 
 	cDAC	:= U_Modulo10( cCampo2 )
 	//cDAC	:= &(cFuncao)
	cCampo2	:= cCampo2 + cDAC
	
	cCampo3	:= substr(cAgencia,4,1) + (cConta+(cAliasSEE)->EE_DVCTA) + "000"  
	cDAC	:= U_Modulo10( cCampo3 ) 
	//cDAC    := &(cFuncao)                          
	cCampo3 := cCampo3 + cDAC

	//calculo Campo4:
	cDAC3Anexo := U_Modulo10(cAgencia + cConta) 
    //cDAC3Anexo := &(cFuncao)
    //cDAC = DAC do codigo de barras
    cPartBar := cFator + Strzero((nVlrTit*100),10) +  Alltrim((cAliasSEE)->EE_CODCART) + cNossoNum + cDACCodigo + cAgencia + cConta + cDAC3Anexo + "000"
	cDAC := cBanco + cMoeda + cPartBar
	cDAC := U_Mod11B29( cDAC )	
	cCampo4 := cDAC
	
	cCampo5 := cFator + Strzero((nVlrTit*100),10)
	
	//Linha digitavel ex: 34191.09008  00000.09008  02030.313049  2  61900000020000
	cLDig  := SubStr(cCampo1, 1, 5) + '.' + SubStr(cCampo1, 6, 5)  + '  '
	cLDig  += SubStr(cCampo2, 1, 5) + '.' + SubStr(cCampo2, 6, 6)  + '  '    
	cLDig  += SubStr(cCampo3, 1, 5) + '.' + SubStr(cCampo3, 6, 6)  + '  '
	cLDig  += cCampo4 + '  ' + cCampo5
	 
	//codigo de barras
	cCodBar := cBanco + cMoeda + cCampo4 + cPartBar
	
	//acrescenta o digito da conta corrente, para imprimir no boleto
	cConta += "-"+(cAliasSEE)->EE_DVCTA 
	
	cParcela:= SE1->E1_PARCELA
	cNumTit	:= AllTrim(SE1->E1_NUM)+AllTrim(SE1->E1_PARCELA)
	dDtMovto:= Date()
	
	If Empty(SE1->E1_NUMBCO)
		SE1->(RecLock("SE1", .F.))
		SE1->E1_NUMBCO := Substr(cNossoN2,1,3) + Substr(cNossoN2,5,8) //+ Substr(cNossoN2,14,1) 
		SE1->(MsUnLock())
	Endif  
	
Endif

Return({cCodBar, cLDig, cNossoN2})



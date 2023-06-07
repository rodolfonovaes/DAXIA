#Include 'Totvs.ch'

/*/{Protheus.doc} CaBar090
UNICRED - Calcula cod.barras, linha digitavel, DACs e nosso numero
@author Giane
@since 11/03/2016
@version 1.0
@param cBanco, character, (Codigo do Banco)
@param cArqCFG, character, (Nome do arquivo de configuracao de boletos)
@param cAgencia, character, (codigo da agencia)
@param cConta, character, (codigo da conta)
@param cNossoNum, character, (NossoNumero)
@param nVlrTit, numeric, (valor do titulo)
@param cParcela, character, (parcela do titulo)
@param dDtMovto, data, (data de processamento)
@param cNumTit, character, (Numero do titulo)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function CaBar090(cBanco,cArqCFG, cAgencia, cConta, cNossoNum, nVlrTit, cParcela, dDtMovto, cNumTit)

Local cAno			:= If(Empty(AllTrim((cAliasSEE)->EE_CODCOBE)),"00",AllTrim((cAliasSEE)->EE_CODCOBE))
Local cSeq			:= cNossonum
Local cFator		:= "3298765432"
Local nDiv			:= 11
Local nX			:= 1
Local nSoma			:= 0
Local cDigNossoN  	:= ''
Local cNossoNOrig 	:= cNossoNum
Local nLen			:= Len(cNossoNum)
Local cCodBar		:= ""
Local cLDig			:= ""
Local cMoeda		:= GetPvProfString(cBanco,"cCodMoedaBarra",'9', cArqCFG )
Local cDAC			:= ""
Local cCampo1		:= ""
Local cCampo2		:= ""
Local cCampo3		:= ""
Local cCampo4		:= ""
Local cCampo5		:= ""
Local cDACCodigo	:= ""
Local cDAC3Anexo	:= ""
Local cPartBar		:= ""
Local cCodigo		:= ""
Local cDtFator 		:= GetPvProfString(cBanco,"dDtFatorVencto",'07/10/1997', cArqCFG )
Local cFatVenc		:= ""


For nX := 1 to Len(cFator)
	If nX <= 2
		nSoma += Val(SubStr(cAno,nX,1)) * Val(SubStr(cFator,nX,1))
	Else
		nSoma += Val(SubStr(cSeq, nX-2, 1)) * Val(SubStr(cFator,nX,1))
	EndIf
Next nX
	
cDigNossoN := AllTrim(Str(nDiv - Mod( nSoma, nDiv )))
	
cNossoNOrig := cAno + cSeq + cDigNossoN



//Inicia calculos da linha digitavel, cod barras 
If FindFunction('U_Modulo10')

	//CAMPO1
	cCampo1	:= cBanco + cMoeda + Alltrim((cAliasSEE)->EE_CODCART) + substr(cNossoNum,1,3) 
	cDAC	:= U_Modulo10( cCampo1 )
	cCampo1	:= cCampo1 + cDAC // 10 caracteres
	
	//CAMPO LIVRE
	cCodigo 	:= cAgencia + Alltrim((cAliasSEE)->EE_CODCART) + cNossoNum + cConta + "0" //Campo livre
	cDACCodigo  := U_Modulo10( cCodigo )
 	
	//CAMPO2
 	cCampo2	:= substr(cNossoNum,3,nLen-2) + cDACCodigo + substr(cAgencia,1,3) 
 	cDAC	:= U_Modulo10( cCampo2 )
	cCampo2	:= cCampo2 + cDAC

	//CAMPO3	
	cCampo3	:= substr(cAgencia,4,1) + (cConta+(cAliasSEE)->EE_DVCTA) + "000"  
	cDAC	:= U_Modulo10( cCampo3 ) 
	cCampo3 := cCampo3 + cDAC

	cDAC3Anexo := U_Modulo10(cAgencia + cConta) 
    cPartBar := cDtFator + Strzero((nVlrTit*100),10) +  Alltrim((cAliasSEE)->EE_CODCART) + cNossoNum + cDACCodigo + cAgencia + cConta + cDAC3Anexo + "000"
	cDAC := cBanco + cMoeda + cPartBar
	cDAC := U_Mod11B29( cDAC )	

 	//CAMPO4
	cCampo4 := cDAC
	
	//CAMPO5	
	cFatVenc := STRZERO(SE1->E1_VENCREA - CTOD(cDtFator) ,4)
	cCampo5 := cFatVenc + Strzero((nVlrTit*100),10)

	
	//Linha digitavel ex: 23790.0310D  40031.77200D  28009.52790D  D  10010000000000
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

Endif

If Empty(SE1->E1_NUMBCO)				
	RecLock("SE1",.F.)			
	SE1->E1_NUMBCO := cNossoNOrig				
	SE1->(MsUnlock())
Endif

//nossonumero final para impressao
cNossoNum := Substr(cNossoNOrig,1,10) + "-" + Substr(cNossoNOrig,11,1)

Return( {cCodBar, cLDig, cNossoNum} )




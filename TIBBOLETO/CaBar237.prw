#Include 'Totvs.ch'

/*/{Protheus.doc} CaBar237
BANCO BRADESCO - Calcula cod.barras, linha digitavel, DACs e nosso numero
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
@param dDtMovto, data, (data de processamento)
@param cNumTit, character, (Numero do titulo)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function CaBar237(cBanco, cArqCFG, cAgencia, cConta, cNossoNum, nVlrTit, cParcela, dDtMovto, cNumTit)

Local cString	:= ''
Local cDVNossoN := ''
Local cValor 	:= ''
Local cDtFator	:= ''
Local cFator	:= ''
Local cCpoLivre := ''
Local cCodBar	:= ''
Local cDVBarra	:= ''
Local cBloco1	:= ''
Local cBloco2	:= ''
Local cBloco3	:= ''
Local cBloco4	:= ''
Local cBloco5	:= ''
Local cLDig		:= ''
Local cDigit1	:= ''
Local cDigit2	:= ''
Local cDigit3	:= ''
Local cCodCart:= Alltrim((cAliasSEE)->EE_CODCART)
Local cMoeda	:= GetPvProfString(cBanco,"cCodMoedaBarra",'9', cArqCFG )  //codigo da moeda

If Len(cCodCart) == 3
   cCodCart := SubStr(cCodCart,2,2)
Endif

//calcula digito verificador do nossonumero:
cString		:=  cCodCart + cNossoNum
cDVNossoN	:= Mod11B7(cString)

//Calculo do digito codigo de barras  
cDtFator	:= GetPvProfString(cBanco,"dDtFatorVencto",'07/10/1997', cArqCFG )
cFator		:= strzero(SE1->E1_VENCTO - Ctod(cDtFator),4)  

cValor		:= StrZero(nVlrTit * 100, 10)
cCpoLivre	:= SubStr(cAgencia,1,4) + cCodCart + cNossoNum + cConta + '0' //cconta deve ter 7 digitos com zeros a esquerda se necessario
cCodBar		:= cBanco + cMoeda + cFator + cValor + cCpoLivre  
cDVBarra	:= U_Mod11B29(cCodBar)

//codigo de barras completo
cCodBar	:= cBanco + cMoeda + cDVBarra + cFator + cValor + cCpoLivre  

//Linha digitavel
cBloco1	:= cBanco + cMoeda + SubStr(cCpoLivre, 1, 5)
cBloco2 := SubStr(cCpoLivre,  6, 10)
cBloco3 := SubStr(cCpoLivre, 16, 10)
cBloco4 := cDVBarra
cBloco5 := cFator + cValor
	
cDigit1 := Mod10237(cBloco1)
cDigit2 := Mod10237(cBloco2)
cDigit3 := Mod10237(cBloco3)
	
cLDig := SubStr(cBloco1, 1, 5) + "." + SubStr(cBloco1, 6, 4) + cDigit1 + " "
cLDig += SubStr(cBloco2, 1, 5) + "." + SubStr(cBloco2, 6, 5) + cDigit2 + " "
cLDig += SubStr(cBloco3, 1, 5) + "." + SubStr(cBloco3, 6, 5) + cDigit3
cLDig += " " + cBloco4 + " "
cLDig += cBloco5

//acrescenta digito da conta
cConta += (cAliasSEE)->EE_DVCTA

cNumTit	:= SE1->(E1_PREFIXO + E1_NUM + E1_PARCELA)

dDtMovto := dDataBase

If Empty(SE1->E1_NUMBCO)
	SE1->(RecLock("SE1", .F.))
	SE1->E1_NUMBCO := cNossoNum + cDVNossoN
	SE1->(MsUnLock())       
Endif

//Adiciona o numero da carteira ao Nosso Numero e Acrescenta o DV
cNossoNum := cString
cNossoNUm += cDVNossoN

cNossoNum := Left(cNossoNUm,2) + '/' + Substr(cNossoNum,3,11) + '-' + Right(cNossoNum,1)

Return({cCodBar, cLDig, cNossoNum})

/*/{Protheus.doc} Mod10237
calculo DV modulo 10, base 2..1, porem com algumas peculiaridades para o Bradesco
@author Giane
@since 11/03/2016
@version 1.0
@param cDados, character, (String a ser calculada o DV)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function Mod10237(cDados)

Local nBase1 := "212121212"
Local nBase2 := "1212121212"
Local nRetDig:= 0
Local nTotal := 0
Local cResult:= ""
Local nI	 := 0
	
If Len(cDados) == 9
	For nI := 1 To 9
		cResult := Alltrim(Str((Val(SubStr(cDados, nI, 1)) * Val(SubStr(nBase1, nI, 1))), 2, 0))
		If Len(cResult) == 2
			nTotal += Val(SubStr(cResult, 1, 1)) + Val(SubStr(cResult, 2, 1))
		Else
			nTotal += Val(cResult)
		EndIf
	Next nI
	nRetDig := (Round((nTotal / 10) + .49, 0) * 10) - nTotal
Else
	For nI := 1 To 10
		cResult := Alltrim(Str((Val(SubStr(cDados, nI, 1)) * Val(SubStr(nBase2, nI, 1))), 2, 0))
		If Len(cResult) == 2
			nTotal += Val(SubStr(cResult, 1, 1)) + Val(SubStr(cResult, 2, 1))
		Else
			nTotal += Val(cResult)
		EndIf
	Next nI
	nRetDig := (Round((nTotal / 10) + .49, 0) * 10) - nTotal
EndIf
	
Return(Str(nRetDig, 1, 0))


/*/{Protheus.doc} Mod11B7
Calcula digito verificador, Modulo11, base 7 (2... a 7) 
@author Giane
@since 11/03/2016
@version 1.0
@param cString, character, (String a ser calculado o DV)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function Mod11B7(cString)
Local nI	:= 1
Local nTot	:= 0
Local nMod	:= 0
Local nDig	:= 0
Local cDig	:= ''
Local nLen	:= Len(cString)
Local cBase	:= ''
Local nX	:= 0

//primeiro monta cBase, de 2.. a 7
For nx := nLen to 1 step -1
	nI++
	cBase := Str(nI,1) + cBase
	If nI == 7
		nI := 1
	Endif
Next

//agora efetua o calculo do dv
nI := 1
For nI := 1 To nLen
	nTot +=	(Val(SubStr(cString, nI, 1)) * Val(SubStr(cBase, nI, 1)))
Next nI
nDig := 11 - (nTot % 11)
Iif(nDig == 10, cDig := "P", Iif(nDig == 11, cDig := "0", cDig := Str(nDig, 1)))

Return cDig
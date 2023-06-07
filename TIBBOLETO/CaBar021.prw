#Include 'Totvs.ch'

/*/{Protheus.doc} CaBar021
(long_description)
@author usrback
@since 30/03/2016
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
User Function CaBar021(cBanco,cArqCFG, cAgencia, cConta, cNossoNum, nVlrTit, cParcela, dDtMovto, cNumTit)

Local cMoeda		:= GetPvProfString(cBanco,"cCodMoedaBarra",'9', cArqCFG )  //codigo da moeda
Local cFator		:= ''
Local cDtFator	:= ''
Local dVencto		:= Datavalida(SE1->E1_VENCTO,.T.)
Local cVlrTit		:= ''
Local cDAC			:= ''
Local cCodBar		:= ''
Local cTpCob		:= GetPvProfString(cBanco,"cTipoCobranca",'2', cArqCFG )
Local cCodAsBace	:= ''
Local cD1AsB		:= ''
Local cD2AsB		:= ''
Local cCampo1		:= ''
Local cCampo2		:= ''
Local cCampo3		:= ''
Local cCampo4		:= ''
Local cCampo5		:= ''
Local cLDig		:= ''

cDtFator := GetPvProfString(cBanco,"dDtFatorVencto",'07/10/1997', cArqCFG )
cFator := strzero(dVencto - CTOD(cDtFator),4)  

cVlrTit := Strzero(nVlrTit*100,10)

//calculo chave ASBACE
cCodAsBace := cNossoNum + cConta + cTpCob + cBanco
cD1AsB  := U_D1Asbace(cCodAsBace)

cD2AsB  := U_D2Asbace(cCodAsBace, @cD1AsB )
cCodAsBace += cD1AsB + cD2AsB


//calculo DV cod barras e cod barras
cDAC := U_Mod1129E(cBanco + cMoeda + cFator + cVlrTit + cCodAsbace,"1")
cCodBar := cBanco + cMoeda + cDAC + cFator + cVlrTit + cCodAsbace

//linha digitavel
cCampo1 := cBanco + cMoeda +  Substr(cCodAsbace,1,5) 
cCampo1 := cCampo1 +  Mod10021(cCampo1)  

cCampo2 := Substr(cCodAsbace, 6,10) 
cCampo2 := cCampo2 + Mod10021(cCampo2)

cCampo3 := Substr(cCodAsbace,16,10) 
cCampo3 := cCampo3 + Mod10021(cCampo3)
                                       
cCampo4 := cDAC
cCampo5 := cFator + cVlrTit 

cLDig := SubStr(cCampo1, 1, 5) + '.' + SubStr(cCampo1, 6, 5)  + '  '
cLDig += SubStr(cCampo2, 1, 5) + '.' + SubStr(cCampo2, 6, 6)  +  '  '    
cLDig += SubStr(cCampo3, 1, 5) + '.' + SubStr(cCampo3, 6, 6)  +  '  '
cLDig += cCampo4 + '  '
cLDig += cCampo5      

cNumTit := Alltrim(SE1->E1_NUM) +  Alltrim(SE1->E1_PARCELA)          

If Empty(SE1->E1_NUMBCO)//se já nao foi impresso
	SE1->(RecLock("SE1", .F.))
	SE1->E1_NUMBCO := cNossoNum
	SE1->(MsUnLock())      
EndIf  

Return( {cCodBar, cLDig, cNossoNum} )

/*/{Protheus.doc} D1Asbace
Calcula digito do codigo AsBACe, regras especificas de calculo
@author Giane
@since 30/03/2016
@version 1.0
@param cAsBace, character, (codigo AsBace)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function D1Asbace(cAsBace)

Local cRetorno := ''
Local cASBACE  := AllTrim(cASBACE)
Local aLista   := {}
Local nInd     := 0
Local nPeso    := 1
Local nNro     := 0
Local nSomatoria := 0
Local nResto   := 0

For nInd := 1 to Len(cASBACE)
	
	If nPeso == 1
		nPeso := 2
	Else
		nPeso := 1
	EndIf
	
	nNro := Val(substr(cASBACE, nInd, 1))	
	Aadd( aLista, { nNro  , nPeso, Iif ((nNro * nPeso) > 9 , (nNro * nPeso) - 9, (nNro * nPeso))  }  ) 	
Next

For nInd := 1 to Len(cASBACE)
	nSomatoria += aLista[nInd][3]
Next

nResto := mod(nSomatoria,10)

If nResto <= 0
	cRetorno := '0'
Else
	cRetorno := AllTrim( STR(10 - nResto) )
EndIf

Return cRetorno


/*/{Protheus.doc} D2Asbace
Calculo do digito 2 da chave AsBace
@author Giane
@since 30/03/2016
@version 1.0
@param cAsBace, character, (Chave Asbace)
@param cD1AsB, character, (Digito 1 chave Asbace)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function D2Asbace(cAsBace,cD1AsB)
Local lRecalcula := .T.
Local cDig2 := ''

Do While lRecalcula

	cDig2 := Mod11AsBace(cAsBace+cD1AsB)
    
	If cDig2 == "1"
		cD1AsB := AllTrim( STR(Val(cD1AsB) + 1) )	
		
		If Val(cD1AsB) >= 10
			cD1AsB := '0'
		EndIf
	Else
		lRecalcula := .F.		
	EndIf
Enddo

Return cDig2

/*/{Protheus.doc} Mod11AsBace
Modulo 11, base 2 a 7, com retorno especifico p/ chave Asbace
@author Giane
@since 30/03/2016
@version 1.0
@param cASBACE, character, (chave ASbace)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function Mod11AsBace(cASBACE)

Local cRetorno := ''
Local cASBACE  := AllTrim(cASBACE)
Local aLista   := {}
Local nInd     := 0
Local nPeso    := 2
Local nNro     := 0
Local nSomatoria := 0
Local nResto   := 0
Local nTam     := Len(cASBACE)

While nTam > 0
	nNro := Val(substr(cASBACE, nTam, 1))	
	Aadd( aLista, { nNro  , nPeso,  (nNro * nPeso) }  ) 	
    
	nPeso := nPeso + 1
	
	If nPeso > 7
		nPeso := 2
	EndIf	

	nTam := nTam - 1	
End
    
For nInd := 1 to Len(cASBACE)
	nSomatoria += aLista[nInd][3]
Next

nResto := mod(nSomatoria,11)

If nResto <= 0
	cRetorno := '0'
Else       

	If nResto == 1
		cRetorno := AllTrim( STR(nResto) )
	Else
		cRetorno := AllTrim( STR(11 - nResto) )	
	EndIf
	
EndIf

Return cRetorno

/*/{Protheus.doc} Mod10021
modulo 10, base 2 1, mas com diferencial no final
@author Giane
@since 30/03/2016
@version 1.0
@param cDado, character, (String a ser calculado o Dig)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function Mod10021(cDado)
Local cDIgit	:= ' ',cAux:=' ' 
Local nIndex	:= Len(cDado) 
Local nFator	:= 1
Local nSoma	:= 0 
Local nResto	:= 0
Local nTemp	:=0
Local cStrTemp:= ''
Local nAjud	:=0
Local lDois	:= .T.

Do While nIndex > 0 
	cAux := substr(cDado,nIndex, 1)
	
	if lDois
		nFator:=2
		lDois := .F.
	else	
		nFator:=1
		lDois := .T.
	endif
		
	nTemp := Val(cAux) * nFator
	cStrTemp := AllTrim(STR(nTemp))
	
	if nTemp < 10
		nSoma += nTemp
	endif
	
	if nTemp >= 10 .and. nTemp <= 99
		nAjud:= val( substr(cStrTemp,1,1)  )
		nSOma += nAjud
		nAjud:=val( substr(cStrTemp,2,1)  )     
		nSOma += nAjud
	endif                           
	
	if nTemp > 100
		nAjud:=val( substr(cStrTemp,1,1)  )
		nSOma += nAjud
		nAjud:=val( substr(cStrTemp,2,1)  )
		nSOma += nAjud
		nAjud:=val( substr(cStrTemp,3,1)  )
		nSOma += nAjud
	endif
	
	
	nIndex -= 1
Enddo

If nSoma < 10
	nResto := nSoma
Else	
	nResto := Mod(nSoma,10)
EndIf

If nResto <= 0
	cDigit := '0'
Else       
	If nResto == 1
		cDigit := AllTrim( STR(nResto) )
	Else
		cDigit := AllTrim( STR(10 - nResto) )	
	EndIf
EndIf
		
Return cDigit

/*/{Protheus.doc} CDIASBACE
Funcao que calcula Chave asbace e imprime no boleto Banestes
A chamada dela vai acontecer através da configuração no TIBBOLETO.V01, variaveis cCpoCustom1, nLinCpoCustom1, nColCpoCustom1
em conjunto com a função CpoCustom() que está no fonte TIBBOLETO.PRW
@author Giane
@since 31/03/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User function CDIASBACE()
Local cRet			:= ''
Local cTpCob		:= ''
Local cCodAsBace	:= ''
Local cD1AsB		:= ''
Local cD2AsB		:= ''
Local cConta   	:= ''
Local cBanco		:= MV_PAR11
Local cNossoNum	:= aCODE[3]
Local cArqCFG		:= Paramixb[1]

cConta   	:= U_EETabulacaoBanco(cArqCFG, "C")
cTpCob		:= GetPvProfString(cBanco,"cTipoCobranca",'2', cArqCFG )
	
//calculo chave ASBACE
cCodAsBace := cNossoNum + cConta + cTpCob + cBanco
cD1AsB  := U_D1Asbace(cCodAsBace)

cD2AsB  := U_D2Asbace(cCodAsBace, @cD1AsB )
cCodAsBace += cD1AsB + cD2AsB

cRet :=  'Chave Asbace: ' + cCodAsBace  

Return cRet

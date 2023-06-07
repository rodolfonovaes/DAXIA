#Include 'Totvs.ch'

/*/{Protheus.doc} CaBar422
BANCO SAFRA - Calcula cod.barras, linha digitavel, DACs e nosso numero
@author Giane
@since 15/03/2016
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
User Function CaBar422(cBanco, cArqCFG, cAgencia, cConta, cNossoNum, nVlrTit, cParcela, dDtMovto, cNumTit)

Local cCpoLivre	:= ''
Local cDV1			:= 	''
Local cDV2			:= 	''
Local cDV3			:= 	''
Local cVlrTit		:= Strzero(nVlrTit*100,10)
Local cCodBar		:= ''
Local cDAC			:= ''
Local cLDig	 	:= ''
Local cLinhaD		:= ''
LOCAL cFator  := ''
Local cDtFator := ''


//calcula fator de vencimento
cDtFator := GetPvProfString(cBanco,"dDtFatorVencto",'07/10/1997', cArqCFG )
cFator := strzero(SE1->E1_VENCREA - CTOD(cDtFator),4)  

cBanco		:= cBanco + "9"
cNossoNum := cNossoNum + U_Mod1129E(cNossoNum)

cCpoLivre := "7" + Substr(cAgencia,1,4) + cConta + cNossoNum + "2"  

cDV1 :=   U_Modulo10(cBanco + "7" + SUBSTR(cAgencia,1,4))
cDV2 :=   U_Modulo10(SUBSTR(cAgencia,5,1)+cConta )
cDV3 :=   U_Modulo10(cNossoNum+"2" )

cCodBar	:= cBanco + cFator + cVlrTit + "7" + SUBSTR(cAgencia,1,5)  + cConta + cNossoNum + "2"

cDAC		:= U_Mod1129E(cCodBar,"1")
cCodBar	:= Substr(cCodBar,1,4) + cDAC + Substr(cCodBar,5, Len(cCodBar) )

cLinhaD := (cBanco + "7" + Substr(cAgencia,1,4) + cDV1) + (SUBSTR(cAgencia,5,1)+cConta + cDV2) + (cNossoNum + "2" + cDV3) + cDAC + cFator + cVlrTit
 
//Linha Digitavel   versao 1
cLDig := SubStr(cLinhaD,1,5) + "." + SubStr(cLinhaD,6,5)  + " "   //primeiro campo
cLDig += SubStr(cLinhaD,11,5) + "." + SubStr(cLinhaD,16,6) + " "   //segundo campo
cLDig += SubStr(cLinhaD,22,5) + "." + SubStr(cLinhaD,27,6) +  " "   //terceiro campo
cLDig += " " + cDAC              //dig verificador geral
cLDig += "  " + cFator + cVlrTit  // fator de vencimento e valor nominal do titulo  

//nossonumero como deve ser impresso
cNossoNum := IIf( !Empty(SE1->E1_NUMBCO), SE1->E1_NUMBCO, cNossoNum )

cParcela := SE1->E1_PARCELA
cNumTit := AllTrim(SE1->E1_NUM)+AllTrim(SE1->E1_PARCELA)

If Empty(SE1->E1_NUMBCO)
	SE1->(RecLock("SE1", .F.))
	SE1->E1_NUMBCO := cNossoNum
	SE1->(MsUnLock())       
Endif

Return({cCodBar, cLDig, cNossoNum})




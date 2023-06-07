#Include 'Totvs.ch'

/*/{Protheus.doc} CaBar001
BANCO DO BRASIL - Calcula cod.barras, linha digitavel, DACs e nosso numero
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
User Function CaBar001(cBanco,cArqCFG, cAgencia, cConta, cNossoNum, nVlrTit, cParcela, dDtMovto, cNumTit)

Local nConvenio	:= Len( AllTrim((cAliasSEE)->EE_CODEMP) )
Local cCodCart	:= Alltrim(SubStr((cAliasSEE)->EE_CODCART,1,2))
Local cMoeda		:= GetPvProfString(cBanco,"cCodMoedaBarra",'9', cArqCFG )  //codigo da moeda
Local cFator		:= ''
Local cValor		:= ''
Local cCpoLivre	:= ''
Local cCodBar		:= ''
Local cDigBar		:= ''
Local cBloco1		:= ''
Local cBloco2		:= ''
Local cBloco3		:= ''
Local cBloco4		:= ''
Local cBloco5		:= ''
Local cDig1		:= ""
Local cDig2		:= ""
Local cDig3		:= ""
Local cLDig		:= ""
Local aRet			:= {}
Local cDigNossoN  := ''
Local cNossoNOrig := cNossoNum

cNossoNum := StrZero(Val((cAliasSEE)->EE_CODEMP),nConvenio) + cNossoNum	//nosso numero passa a ser este para os calculos abaixo

if nConvenio == 7 //codigo do convenio no banco usa 7 digitos

	//campo livre do codigo de barra   	
	cCpoLivre := "000000" + cNossoNum + "17" //17 numero fixo   
	                                                          	
Elseif nConvenio == 6
	cCpoLivre :=  cNossoNum + Substr(cAgencia,1,4) + cConta + cCodCart
	cDigNossoN := U_Mod11B92(cNossoNum)
	cNossoNum += cDigNossoN
	
Endif
	
cFator := Fator001(SE1->E1_VENCTO)	
               
If nVlrTit > 0
	cValor := Strzero(nVlrTit*100,10)
Else
	cValor  := Strzero(SE1->E1_SALDO*100,10)
Endif
	
cBloco1 := cBanco + cMoeda 
cCodBar := cFator + cValor + cCpoLivre

	
// campo do codigo de barra e DV
cDigBar := U_Mod11B29(cBloco1 + cCodBar) //CALC_5pBB( cBloco1 + cCodBar )
cCodBar := cBloco1 + cDigBar + cCodBar 
	
// composicao da linha digitavel
cBloco1  := cBloco1 + SUBSTR(cCodBar,20,5)
cDig1    := U_Modulo10( cBloco1 )
cBloco2  := SUBSTR(cCodBar,25,10)
cDig2    := U_Modulo10( cBloco2 )
cBloco3  := SUBSTR(cCodBar,35,10)
cDig3    := U_Modulo10( cBloco3 )
cBloco4  := " " + cDigBar +" "
cBloco5  := cFator + cValor
	
cLDig	  :=  Substr(cBloco1,1,5) + "." + Substr(cBloco1,6,4) + cDig1 + " " + ;
			  Substr(cBloco2,1,5) + "." + Substr(cBloco2,6,5) + cDig2 + " " +;
			  Substr(cBloco3,1,5) + "." + Substr(cBloco3,6,5) + cDig3 + " " +;
			  cBloco4 + cBloco5

cAgencia += "-" + ((cAliasSEE)->EE_DVAGE)	
cConta += "-" + ((cAliasSEE)->EE_DVCTA)

//nossonumero final para impressao
cNossoNum := Substr(cNossoNOrig,1,6) + Right(cNossoNOrig,5) + "-" + U_Mod11B92( Substr(cNossoNOrig,1,6) + Right(cNossoNOrig,5) )

If Empty(SE1->E1_NUMBCO)				
	RecLock("SE1",.F.)			
	SE1->E1_NUMBCO := cNossoNOrig				
	SE1->(MsUnlock())
Endif

Return( {cCodBar, cLDig, cNossoNum} )

/*/{Protheus.doc} Fator001
Fator de vencimento para o Banco do BRASIL
@author	Giane
@since 11/03/2016
@version 1.0
@param dVencto, data, (data de vencimento do titulo)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function Fator001(dVencto)

dVencto := DTOS(dVencto)
//inicia fator em 1001 e soma 1 a cada dia da diferença de datas (dvencto - 03/07/2000)
cFator := STR(1000+(STOD(dVencto)-STOD("20000703")),4)

Return(cFator)



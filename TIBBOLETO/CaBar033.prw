#Include 'Totvs.ch'

/*/{Protheus.doc} CaBar033
BANCO SANTANDER - Calcula cod.barras, linha digitavel, DACs e nosso numero
@author Giane
@since 14/03/2016
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
User Function CaBar033(cBanco, cArqCFG, cAgencia, cConta, cNossoNum, nVlrTit, cParcela, dDtMovto, cNumTit)

Local nConvenio	:= Len( AllTrim((cAliasSEE)->EE_CODEMP) )
Local cCodEmp	:= StrZero(Val((cAliasSEE)->EE_CODEMP ),7 )  //nConvenio)  //nilza - no caso do Santander o convenio sao 11 pos, mas temos que usar somente 7
Local cDtFator 	:= GetPvProfString(cBanco,"dDtFatorVencto",'07/10/1997', cArqCFG )           
Local cNumSeq 	:= ''
Local cVlrFinal  := Strzero(nVlrTit*100,10)
Local cCpoLivre	:= ''
Local cFatVenc	:= ''
Local cCBSemDig	:= ''
Local cCodBar		:= ''
Local cBloco1		:= ''
Local cBloco2		:= ''
Local cBloco3		:= ''
Local cDvGeral	:= ''
Local cDV1			:= ''
Local cDV2			:= ''
Local cDV3			:= ''
Local cLDig		:= ''

cBanco	:= cBanco + "9"

//Fator Vencimento - POSICAO DE 06 A 09
cFatVenc := STRZERO(SE1->E1_VENCREA - CTOD(cDtFator) ,4)
                           
cNumSeq := cNossoNum + Mod11033(cNossoNum)		

//Nosso Numero para impressao
IF Empty(SE1->E1_NUMBCO)
	cNossoNum := Left(cNumSeq,nConvenio) + Right(cNumSeq,1) 
Else
	cNossoNum := SE1->E1_NUMBCO
Endif  

//da posica 20 ate a 44 do layout cod. de barras:

//cCpoLivre := "9" + cCodEmp + "00000" + cNumSeq + "0" + "101"   //"9" eh fixo, nao é moeda 
cCpoLivre := "9" + cCodEmp +  "0" + cNumSeq + "0" + "101"   //"9" eh fixo, nao é moeda //nilza - o cnumseq tem mais digito do que era previsto

//Dados para Calcular o Dig Verificador Geral
cCBSemDig := cBanco + cFatVenc + cVlrFinal + cCpoLivre

//Codigo de Barras Completo
cCodBar := cBanco + U_Mod11B29(cCBSemDig) + cFatVenc + cVlrFinal + cCpoLivre   


//Montagem dos blocos da linha digitavel:
           
cBloco1 := cBanco + SubStr(cCodBar,20,5) 
//Digito Verificador do Primeiro Campo     
cDV1 := U_Modulo10(cBloco1)

//Digito Verificador do Segundo Campo
cBloco2 := SubStr(cCodBar,25,10)
cDV2 := U_Modulo10(cBloco2)

//Digito Verificador do Terceiro Campo
cBloco3 := SubStr(cCodBar,35,10)
cDV3 := U_Modulo10(cBloco3)

//Digito Verificador Geral
cDvGeral := SubStr(cCodBar,5,1)

//Linha Digitavel
cLDig := SubStr(cBloco1,1,5) + "." + SubStr(cBloco1,6,4) + cDV1 + " "   //primeiro campo
cLDig += SubStr(cBloco2,1,5) + "." + SubStr(cBloco2,6,5) + cDV2 + " "   //segundo campo
cLDig += SubStr(cBloco3,1,5) + "." + SubStr(cBloco3,6,5) + cDV3 + " "   //terceiro campo
cLDig += " " + cDvGeral              //dig verificador geral
cLDig += "  " + SubStr(cCodBar,6,4)+SubStr(cCodBar,10,10)  // fator de vencimento e valor nominal do titulo

//altera cConta, para imprimir o cod.empresa no lugar:
cConta := cCodEmp

If Empty(SE1->E1_NUMBCO)
	SE1->(RecLock("SE1", .F.))
	SE1->E1_NUMBCO := cNossoNum
	SE1->(MsUnLock())       
Endif

Return({cCodBar,cLDig,cNossoNum})

/*/{Protheus.doc} Mod11033
Calculo DV de nossonumero do banco SANTANDER, utiliza modulo 11, base 2.. a 9,
porem o final do calculo é diferente da funçao MOD11B29
@author Giane
@since 14/03/2016
@version 1.0
@param cString, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function Mod11033(cString)

Local cDIgit := ' '
Local cAux   :=' ' 
Local nIndex := Len(cString) 
Local nFator := 1
Local nSoma  := 0 
Local nResto := 0

Do While nIndex > 0 
	cAux := substr(cString,nIndex, 1)
	nFator+=1
	
	if nFator > 9
		nFator:=2
	endif
		
	nSoma += Val(cAux) * nFator
	
	nIndex -= 1
Enddo

nResto := (nSoma % 11)

cDigit := ' '

if nResto == 10
	cDigit := '1'
endif

if nResto == 1 .or. nResto == 0
	cDigit := '0'
endif

if nResto != 10 .and. nResto != 1 .and. nResto != 0
	cDigit := ALLTRIM( STR(11-nResto) )
endif
	
Return cDigit


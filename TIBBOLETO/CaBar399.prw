#Include 'Totvs.ch'

/*/{Protheus.doc} CaBar399
BANCO HSBC - Calcula cod.barras, linha digitavel, DACs e nosso numero
@author Giane
@since 18/03/2016
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
User Function CaBar399(cBanco, cArqCFG, cAgencia, cConta, cNossoNum, nVlrTit, cParcela, dDtMovto, cNumTit)

Local cConvenio	:= 	''
LoCAL cFator  	:= ''
Local cDtFator	:= ''
Local cAno 		:= ''
Local dDtIniAno 	:= ctod('') 
LOcal cDifData 	:= ''
Local cParcCodBar := ''
Local cMoeda		:= ''
Local cCodBar		:= ''
Local cDAC			:= ''
Local cDV1			:= 	''
Local cDV2			:= 	''
Local cDV3			:= 	''
Local cVlrTit		:= Strzero(nVlrTit*100,10)
Local cLDig	 	:= ''
Local cDtVenc		:= ''
Local cSeq			:= ''
Local cCampo		:= ''
Local cBloco1		:= ''
Local cBloco2		:= ''
Local cBloco3		:= ''
Local cBloco5		:= ''
Local cNossoN2	:= ''


cMoeda := GetPvProfString(cBanco,"cCodMoedaBarra",'9', cArqCFG )

//calcula fator de vencimento
cDtFator := GetPvProfString(cBanco,"dDtFatorVencto",'07/10/1997', cArqCFG )
cFator := Strzero(SE1->E1_VENCREA - CTOD(cDtFator),4)  

cConvenio := Alltrim((cAliasSEE)->EE_CODEMP)

cAno 		:= Left( DTOS(SE1->E1_VENCREA),4)
dDtIniAno	:=  CTOD("01/01/" + cAno)
cDifData 	:= Strzero(  (SE1->E1_VENCREA - dDtIniAno) + 1 ,3) + Substr(cAno,4,1)   

                                                                         
cParcCodBar := cBanco + cMoeda + cFator + cVlrTit + cConvenio + cNossoNum + cDifData + "2"
cDAC := U_Mod1129E(cParcCodBar)
cCodBar := cBanco + cMoeda + cDAC + cFator + cVlrTit + cConvenio + cNossoNum + cDifData + "2"

cDV1 := U_Mod11B92(cNossoNum)  

cSeq := cNossoNum+cDV1+"4"

cDtVenc := DTOS(SE1->E1_VENCREA)
cDtVenc := Right(cDtVenc,2) + Substr(cDtVenc,5,2) + Substr(cDtVenc,3,2) //dia+mes+ano com 2 digitos

cCampo := Alltrim( Str( Val(cSeq) + Val(cConvenio) + Val(cDtVenc) ) )

cDV2 := U_Mod11B92(cCampo)

cNossoN2 := cNossoNum + cDV1 + "4" + cDV2
                                             

//linha digitavel
cDV1 := U_Modulo10(cBanco + cMoeda +  Substr(cConvenio,1,5))                                                                     
cBloco1 := cBanco + cMoeda +  Substr(cConvenio,1,5)
cBloco1 += cDV1
cBloco1 := Substr(cBloco1,1,5)+"."+ Substr(cBloco1,6,10)


cDV2 := U_Modulo10( Substr(cConvenio,6,2) + Substr(cNossoNum,1,8) )                                                                     
cBloco2 += Substr(cConvenio,6,2) + Substr(cNossoNum,1,8)
cBloco2 += cDV2
cBloco2 := Substr(cBloco2,1,5)+"." + Substr(cBloco2,6,10)


cDV3	:= U_Modulo10( Substr(cNossoNum,9,5) + cDifData + "2")
cBloco3 += Substr(cNossoNum,9,5) + cDifData + "2"
cBloco3 += cDV3                                                                    
cBloco3 := Substr(cBloco3,1,5)+"." + Substr(cBloco3,6,10)
                                                                                                     
cBloco5 := (cFator + cVlrTit)                                                                  

cLDig   := cBloco1 + " "  + cBloco2  + " "  + cBloco3  + " "  + cDAC +  "  " + cBloco5   

cNumTit := AllTrim(SE1->E1_NUM)+'/'+cParcela

If Empty(SE1->E1_NUMBCO)
	cNossoNum := cNossoN2
	SE1->(RecLock("SE1", .F.))
	SE1->E1_NUMBCO := cNossoN2
	SE1->(MsUnLock())       
Endif

Return({cCodBar, cLDig, cNossoNum})



#Include 'Totvs.ch'

/*/{Protheus.doc} CaBar104
Banco CAIXA - Calcula cod.barras, linha digitavel, DACs e nosso numero
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
@param cNumTit, character, (Numero do titulo)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function CaBar104(cBanco, cArqCFG, cAgencia, cConta, cNossoNum, nVlrTit, cParcela, dDtMovto, cNumTit)

Local cVlrTit 	:= ''
Local cFator		:= ''    
Local cDtFator	:= '' 
Local cMoeda		:= ''       
Local cDVBenef 	:= ''  
Local cConst1 	:= '1' //cobranca registrada
Local cConst2		:= '4' //emissao pelo beneficiario
Local cSeq1		:= ''
Local cSeq2		:= ''
Local cSeq3		:= ''   
Local cDVSeqs		:= ''  
Local cParcCodBar := ''
Local cDAC			:= ''  
Local cCodBar		:= ''  
Local cLDig 		:= ''
Local cDV1			:= ''        
Local cDV2			:= ''        
Local cDV3			:= ''  
Local cBloco1		:= ''      
Local cBloco2		:= ''      
Local cBloco3		:= ''      
Local cBloco5		:= '' 
Local cCpoLivre  := ''
Local cCodBenef  := Alltrim( (cAliasSEE)->EE_CODEMP )      
 
cMoeda := GetPvProfString(cBanco,"cCodMoedaBarra",'9', cArqCFG )
 
cVlrTit 	:= StrZero(nVlrTit*100,10)
cDtFator 	:= GetPvProfString(cBanco,"dDtFatorVencto",'07/10/1997', cArqCFG )
cFator 	:= StrZero(SE1->E1_VENCREA - CtoD(cDtFator),4) 

//DV do beneficiario
cDVBenef 	:= U_Mod11B29(cCodBenef ) 
 
cSeq1 := substr(cNossoNum, 3, 3) 
cSeq2 := substr(cNossoNum, 6, 3)
cSeq3 := substr(cNossoNum, 9, 9)   

//DV do campo livre
cCpoLivre := cCodBenef + cDVBenef + cSeq1 + cConst1 + cSeq2 + cConst2 + cSeq3
cDVSeqs := U_Mod11B29(cCpoLivre) 

//calculo do DAC do cod barras             
cParcCodBar := cBanco + cMoeda  + cFator + cVlrTit + cCodBenef  + cDVBenef +  (cSeq1 + cConst1 + cSeq2 + cConst2 + cSeq3 + cDVSeqs )
cDAC := U_Mod11B29(cParcCodBar) 

//codigo de barras
cCodBar := cBanco + cMoeda + cDAC + cFator + cVlrTit + cCodBenef +  cDVBenef +  (cSeq1 + cConst1 + cSeq2 + cConst2 + cSeq3 + cDVSeqs )
              

//linha digitavel
cDV1	:= U_Modulo10(cBanco + cMoeda + Substr(cCpoLivre,1,5))                                                                     
cBloco1:= cBanco + cMoeda + Substr(cCpoLivre,1,5) + cDV1  

cDV2	:= U_Modulo10( Substr(cCpoLivre,6,10)  ) 
cBloco2:= Substr(cCpoLivre,6,10) + cDV2 

cDV3	:= U_Modulo10( Substr(cCpoLivre,16,10) ) 
cBloco3:= Substr(cCpoLivre,16,10) + cDV3

cBloco5 := cFator + cVlrTit
cLDig 	 := Substr(cBloco1,1,5) + "." + Substr(cBloco1,6,Len(cBloco1))  + " "   + ; 
           Substr(cBloco2,1,5) + "." + Substr(cBloco2,6,Len(cBloco2))  + " "  + ; 
           Substr(cBloco3,1,5) + "." + Substr(cBloco3,6,Len(cBloco3))  + " "  + ;
           cDAC + "  " + cBloco5         
      

cNoNumFrmt := cConst1 + cConst2 + cNossoNum + "-" + U_Mod1129E(cConst1 + cConst2 + cNossoNum)

cNumTit := AllTrim(SE1->E1_NUM)+AllTrim(SE1->E1_PARCELA)

//altera variavel cConta, para cod.empresa para imprimir no boleto
cConta :=  Alltrim((cAliasSEE)->EE_CODEMP) 

If Empty(SE1->E1_NUMBCO)

	SE1->(RecLock("SE1", .F.))
	SE1->E1_NUMBCO := cNossoNum
	SE1->(MsUnLock())       
Endif

Return({cCodBar, cLDig, cNoNumFrmt})


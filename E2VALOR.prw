#Include 'Protheus.ch'
#INCLUDE 'TOPCONN.CH' 
/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北篊onsultoria:                Q S   d o   B R A S I L                     罕�
北掏屯屯屯屯屯送屯屯屯屯退屯屯屯退屯屯屯屯屯屯屯屯屯屯送屯屯退屯屯屯屯屯屯突北
北篜rograma   � E2VALOR  篈utor  � Thiago Nascimento  � Data �  04/01/16   罕�
北掏屯屯屯屯屯瓮屯屯屯屯褪屯屯屯褪屯屯屯屯屯屯屯屯屯屯释屯屯褪屯屯屯屯屯屯凸北
北篋escricao  � ExecBlock Para somar o E2_VALOR de todos os titulos do     罕�
北�           �	do mesmo Bordero.										   罕�
北�           �															   罕�
北掏屯屯屯屯屯瓮屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯凸北
北� Uso       � MP11 - Cliente: Guanabara								   罕�
北掏屯屯屯屯屯瓮屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯凸北
北篠olicitante� 				   		        						   罕�
北掏屯屯屯屯屯瓮屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯凸北
北篈lteracoes � Descricao....: 											   罕�
北�           � o Excel.												   罕�
北�           � Solicitante..: 								        	   罕�
北�           � Data.........: 											   罕�
北�           � Consultor....: 											   罕�
北韧屯屯屯屯屯释屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯图北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
*/

User Function E2VALOR()    

Local aArea := getArea()
Local cQuery 	:= ""   
Local cBordero	:= SE2->E2_NUMBOR
Local cValor 	:= "" 
Local cRet 		:= "" 
Local nVal		:= 0

//Somando os campos de valores de todos os titulos pertencentes ao mesmo bordero.
cQuery := " SELECT SUM(E2_VALOR) E2_VALOR 
cQuery += "		, SUM(E2_ACRESC) E2_ACRESCT
cQuery += "		, SUM(E2_JUROS) + SUM(E2_MULTA)
cQuery +=" 		, SUM(E2_VALOR) + SUM(E2_ACRESC) 
cQuery += " FROM "+retsqlname("SE2")+" SE2 "         
cQuery += "	WHERE E2_NUMBOR = '"+cBordero+"'"
cQuery += "	AND SE2.D_E_L_E_T_ = ' ' "

TCQUERY cQuery NEW ALIAS "XTEMP"    
//Tranformando o Valor em Caractere
cValor := Alltrim(Transform(XTEMP->E2_VALOR,"@E 999999999.99"))
//Retirando o decimal
cValor	:= SUBSTR(cValor,1,LEN(cValor)-3)+SUBSTR(cValor,LEN(cValor)-1,2)   

//Validando se � valor inteiro, adicionando decimais.
IF Len(cValor) == 1 
	cValor	:= cValor+"00" 
EndI

//Convertendo para valor
nVal:= Val(cValor)

//Completando o conteudo com zeros at� interar 14 posi珲es.
cRet 	:= strzero(nVal,14)  

//Fechando Arquivo temporario 
dbCloseArea("XTEMP")   
restarea(aArea)
Return cRet
                                                           


//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Somando os campos de valor do titulo pertencentes ao mesmo bordero    E2_XVLENT                        �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁 

User Function E2XVLEN()    

Local aArea := getArea()
Local cQuery 	:= ""   
Local cBordero	:= SE2->E2_NUMBOR
Local cValor 	:= ""
Local cRet 		:= "" 
Local nVal		:= 0

//Somando os campos de valores de todos os titulos pertencentes ao mesmo bordero.
cQuery := " SELECT SUM(E2_VALOR) E2_VALOR 
cQuery += "		, SUM(E2_ACRESC) E2_ACRESC
cQuery += "		, SUM(E2_JUROS) + SUM(E2_MULTA) AS E2_JUROS
cQuery +=" 		, SUM(E2_VALOR) + SUM(E2_ACRESC)  AS E2_ACRESC
cQuery += " FROM "+retsqlname("SE2")+" SE2 "         
cQuery += "	WHERE E2_NUMBOR = '"+cBordero+"'"
cQuery += "	AND SE2.D_E_L_E_T_ = ' ' "

TCQUERY cQuery NEW ALIAS "XTEMP"    
//Tranformando o Valor em Caractere
cValor := Alltrim(Transform(XTEMP->E2_ACRESC,"@E 999999999.99"))
//Retirando o decimal
cValor	:= SUBSTR(cValor,1,LEN(cValor)-3)+SUBSTR(cValor,LEN(cValor)-1,2)

//Validando se � valor inteiro, adicionando decimais.
IF Len(cValor) == 1 
	cValor	:= cValor+"00" 
EndIF

//Convertendo para valor
nVal:= Val(cValor)

//Completando o conteudo com zeros at� interar 14 posi珲es.
cRet 	:= strzero(nVal,14)  

//Fechando Arquivo temporario 
dbCloseArea("XTEMP")   
restarea(aArea)
Return cRet

 

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Somando os campos de valor do titulo pertencentes ao mesmo bordero  E2_XVLJURO+ E2_XVLMULT                         �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁 

User Function E2XVLJ()    

Local aArea := getArea()
Local cQuery 	:= ""   
Local cBordero	:= SE2->E2_NUMBOR
Local cValor 	:= ""
Local cRet 		:= ""        
Local nVal		:= 0

//Somando os campos de valores de todos os titulos pertencentes ao mesmo bordero.
cQuery := " SELECT SUM(E2_VALOR) E2_VALOR 
cQuery += "		, SUM(E2_ACRESC) E2_ACRESC
cQuery += "		, SUM(E2_JUROS) + SUM(E2_MULTA) AS E2JUROS
cQuery +=" 		, SUM(E2_VALOR) + SUM(E2_ACRESC)  AS E2_ACRESC
cQuery += " FROM "+retsqlname("SE2")+" SE2 "         
cQuery += "	WHERE E2_NUMBOR = '"+cBordero+"'"
cQuery += "	AND SE2.D_E_L_E_T_ = ' ' "

TCQUERY cQuery NEW ALIAS "XTEMP"    
//Tranformando o Valor em Caractere
cValor := Alltrim(Transform(XTEMP->E2JUROS,"@E 999999999.99"))
//Retirando o decimal
cValor	:= SUBSTR(cValor,1,LEN(cValor)-3)+SUBSTR(cValor,LEN(cValor)-1,2)     

//Validando se � valor inteiro, adicionando decimais.
IF Len(cValor) == 1 
cValor	:= cValor+"00" 
EndIF

//Convertendo para valor
nVal:= Val(cValor)

//Completando o conteudo com zeros at� interar 14 posi珲es.
cRet 	:= strzero(nVal,14)  

//Fechando Arquivo temporario 
dbCloseArea("XTEMP")   
restarea(aArea)
Return cRet  

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Somando os campos de valor do titulo pertencentes ao mesmo bordero  E2_ACRESC+ E2_VALOR                         �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁 

User Function E2ACRE()    

Local aArea := getArea()
Local cQuery 	:= ""   
Local cBordero	:= SE2->E2_NUMBOR
Local cValor 	:= ""
Local cRet 		:= "" 
Local nVal		:= 0

//Somando os campos de valores de todos os titulos pertencentes ao mesmo bordero.
cQuery := " SELECT SUM(E2_VALOR) E2_VALOR 
cQuery += "		, SUM(E2_ACRESC) E2_ACRESC
cQuery += "		, SUM(E2_JUROS) + SUM(E2_MULTA) AS E2JUROS
cQuery +=" 		, SUM(E2_VALOR) + SUM(E2_ACRESC)  AS ACRESCVL
cQuery += " FROM "+retsqlname("SE2")+" SE2 "         
cQuery += "	WHERE E2_NUMBOR = '"+cBordero+"'"
cQuery += "	AND SE2.D_E_L_E_T_ = ' ' "

TCQUERY cQuery NEW ALIAS "XTEMP"    
//Tranformando o Valor em Caractere
cValor :=  Alltrim(Transform(XTEMP->ACRESCVL+E2JUROS,"@E 999999999.99"))
//Retirando o decimal
cValor	:= SUBSTR(cValor,1,LEN(cValor)-3)+SUBSTR(cValor,LEN(cValor)-1,2)

//Validando se � valor inteiro, adicionando decimais.
IF Len(cValor) == 1 
cValor	:= cValor+"00" 
EndIF

//Convertendo para valor
nVal:= Val(cValor)

//Completando o conteudo com zeros at� interar 14 posi珲es.
cRet 	:= strzero(nVal,14)  

//Fechando Arquivo temporario 
dbCloseArea("XTEMP")    
restarea(aArea)
Return cRet

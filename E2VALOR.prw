#Include 'Protheus.ch'
#INCLUDE 'TOPCONN.CH' 
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
���Consultoria:                Q S   d o   B R A S I L                     ���
��������������������������������������������������������������������������ͻ��
���Programa   � E2VALOR  �Autor  � Thiago Nascimento  � Data �  04/01/16   ���
��������������������������������������������������������������������������͹��
���Descricao  � ExecBlock Para somar o E2_VALOR de todos os titulos do     ���
���           �	do mesmo Bordero.										   ���
���           �															   ���
��������������������������������������������������������������������������͹��
��� Uso       � MP11 - Cliente: Guanabara								   ���
��������������������������������������������������������������������������͹��
���Solicitante� 				   		        						   ���
��������������������������������������������������������������������������͹��
���Alteracoes � Descricao....: 											   ���
���           � o Excel.												   ���
���           � Solicitante..: 								        	   ���
���           � Data.........: 											   ���
���           � Consultor....: 											   ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
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

//Completando o conteudo com zeros at� interar 14 posi��es.
cRet 	:= strzero(nVal,14)  

//Fechando Arquivo temporario 
dbCloseArea("XTEMP")   
restarea(aArea)
Return cRet
                                                           


//����������������������������������������������������������������������������������������������Ŀ
//� Somando os campos de valor do titulo pertencentes ao mesmo bordero    E2_XVLENT                        �
//������������������������������������������������������������������������������������������������ 

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

//Completando o conteudo com zeros at� interar 14 posi��es.
cRet 	:= strzero(nVal,14)  

//Fechando Arquivo temporario 
dbCloseArea("XTEMP")   
restarea(aArea)
Return cRet

 

//����������������������������������������������������������������������������������������������Ŀ
//� Somando os campos de valor do titulo pertencentes ao mesmo bordero  E2_XVLJURO+ E2_XVLMULT                         �
//������������������������������������������������������������������������������������������������ 

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

//Completando o conteudo com zeros at� interar 14 posi��es.
cRet 	:= strzero(nVal,14)  

//Fechando Arquivo temporario 
dbCloseArea("XTEMP")   
restarea(aArea)
Return cRet  

//����������������������������������������������������������������������������������������������Ŀ
//� Somando os campos de valor do titulo pertencentes ao mesmo bordero  E2_ACRESC+ E2_VALOR                         �
//������������������������������������������������������������������������������������������������ 

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

//Completando o conteudo com zeros at� interar 14 posi��es.
cRet 	:= strzero(nVal,14)  

//Fechando Arquivo temporario 
dbCloseArea("XTEMP")    
restarea(aArea)
Return cRet

#Include "Protheus.CH"
//************************************************************************
// Rotina para trazer o c�digo do fornecedor a partir do CNPJ / CPF      *
// Chamada a partir de gatilho no campo A2_CGC                           *    
// Dom�nio e Contra dom�nio = A2_CGC                                     *
//************************************************************************
User Function CodFor(cCGC,NN)     
Local cFor := "      " 
Local Cloja := "    "             

If Empty(cCGC)
	Return(cCGC)
Endif

// Primeiro calculo o c�digo da loja. Para CPF � sempre "0001". Para CNPJ � a Filial (4 posi��es antes dos d�gitos de controle).   
// Se estiver com um tamanho diferente, alerto o usu�rio e retorno

If Len(AllTrim(cCGC)) == 11          // CPF
	cLoja := "0001"
ElseIf Len(AllTrim(cCGC)) == 14      // CNPJ
	cLoja := Left(Right(cCGC,6),4)          
Else
	Alert("CPF precisa ter 11 d�gitos e CNPJ precisa ter 14 digitos. Preencha com zeros � esquerda, se necess�rio")
	cCGC := Space(14)  
	Return(cCGC)
Endif

// Depois calculo o c�digo do fornecedor. Se j� existir a raiz do CNPJ no cadastro, � o c�digo encontrado, caso contr�rio � o pr�ximo sequencial

dbSelectArea("SA2")
dbSetOrder(3)
If dbSeek(xFilial("SA2") + Left(cCGC,8))
	cFor := SA2->A2_COD
Else
	cFor := GetSxeNum("SA2","A2_COD")
Endif       

//M->A2_COD 	:= cFor
//M->A2_LOJA  := cLoja

IF NN == 1
	Return(cFor)
Else
	Return(cLoja)
Endif
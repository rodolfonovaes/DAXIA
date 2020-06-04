#Include "Protheus.CH"
//************************************************************************
// Rotina para trazer o código do fornecedor a partir do CNPJ / CPF      *
// Chamada a partir de gatilho no campo A2_CGC                           *    
// Domínio e Contra domínio = A2_CGC                                     *
//************************************************************************
User Function CodFor(cCGC,NN)     
Local cFor := "      " 
Local Cloja := "    "             

If Empty(cCGC)
	Return(cCGC)
Endif

// Primeiro calculo o código da loja. Para CPF é sempre "0001". Para CNPJ é a Filial (4 posições antes dos dígitos de controle).   
// Se estiver com um tamanho diferente, alerto o usuário e retorno

If Len(AllTrim(cCGC)) == 11          // CPF
	cLoja := "0001"
ElseIf Len(AllTrim(cCGC)) == 14      // CNPJ
	cLoja := Left(Right(cCGC,6),4)          
Else
	Alert("CPF precisa ter 11 dígitos e CNPJ precisa ter 14 digitos. Preencha com zeros à esquerda, se necessário")
	cCGC := Space(14)  
	Return(cCGC)
Endif

// Depois calculo o código do fornecedor. Se já existir a raiz do CNPJ no cadastro, é o código encontrado, caso contrário é o próximo sequencial

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
#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 19/11/99

User Function Digver()        // incluido pelo assistente de conversao do AP5 IDE em 19/11/99

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("CCAMPO,")

If Len(Alltrim(SE2->E2_CODBAR)) < 44
	cCampo := Substr(SE2->E2_CODBAR,33,1)
Else
	cCampo := Substr(SE2->E2_CODBAR,5,1)
EndIf	

// Substituido pelo assistente de conversao do AP5 IDE em 19/11/99 ==> __Return(cCampo)
Return(cCampo)        // incluido pelo assistente de conversao do AP5 IDE em 19/11/99

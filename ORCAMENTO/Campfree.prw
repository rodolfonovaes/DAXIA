#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 19/11/99

User Function Campfree()        // incluido pelo assistente de conversao do AP5 IDE em 19/11/99

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("CCAMPO,")

If Len(Alltrim(SE2->E2_CODBAR)) < 44
	cCampo := 	Substr(SE2->E2_CODBAR,5,5)+Substr(SE2->E2_CODBAR,11,10)+;
					Substr(SE2->E2_CODBAR,22,10)
Else
	cCampo := Substr(SE2->E2_CODBAR,20,25)
EndIf	

// Substituido pelo assistente de conversao do AP5 IDE em 19/11/99 ==> __Return(cCampo)
Return(cCampo)        // incluido pelo assistente de conversao do AP5 IDE em 19/11/99

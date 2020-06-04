#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 16/02/00
#include "EICGI21A.Ch"                                                             
        
#include "AVERAGE.CH"

User Function Eicgi21a()        // incluido pelo assistente de conversao do AP5 IDE em 16/02/00

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("LRET,")

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �EICGI21A  � Autor � Cristiano A. Ferreira � Data �30/04/1999���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Manutencao de Lote / PLI - Validacoes                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �ExecBlock("EICGI21A",.F.,F.,cCampo)                         ���
�������������������������������������������������������������������������Ĵ��
���Uso       �SIGAEIC - ALKA - (SX3/EICGI210)                             ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
lRet := .T.

While .T.
 
   IF ParamIXB == "WV_QTDE"
      IF nSaldo-M->WV_QTDE < 0
         Help("", 1, "AVG0000148")
         lRet := .F.
         Exit
      Endif
   Endif
   
   Exit
End

// Substituido pelo assistente de conversao do AP5 IDE em 16/02/00 ==> __Return(lRet)
Return(lRet)        // incluido pelo assistente de conversao do AP5 IDE em 16/02/00

*-------------------------------------------------------------------------*
* FIM DO PROGRAMA EICGI21A.PRW                                            *
*-------------------------------------------------------------------------*

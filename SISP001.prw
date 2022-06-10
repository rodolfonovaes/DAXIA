#include "rwmake.ch"

User Function SISP001()

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � SISP001  � Autor � ANDREIA PIVA          � Data � 11/06/19 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � ExecBlock disparado do 341REM.PAG para retornar            ���
���          � conta corrente do fornecedor.                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SISPAG                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Local cAgencia := ""
	IF SA2->A2_BANCO <> "399"
	cAgencia += STRZERO(VAL(SA2->A2_AGENCIA),5) // 24 a 28
	cAgencia += " "                              // 29 a 29
	cAgencia += STRZERO(VAL(SA2->A2_NUMCON),12) // 30 a 41
	cAgencia += Space(01)                        // 42 a 42
	cAgencia += SA2->A2_DVCTA                    // 43 a 43

Else  

	cAgencia += STRZERO(VAL(SA2->A2_AGENCIA),5) // 24 a 28
	cAgencia += " "                              // 29 a 29
	cAgencia += STRZERO(VAL(SA2->A2_NUMCON),12) // 30 a 41
	cAgencia += SA2->A2_DVCTA                    // 42 a 43

Endif


Return cAgencia
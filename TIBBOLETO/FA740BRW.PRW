#INCLUDE 'PROTHEUS.CH'
#include 'parmtype.ch'

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���P.ENTRADA �FA740BRW  �Autor  �Cristian Cerda                           ���
�������������������������������������������������������������������������Ĵ��
���DESCRICAO �Ponto de entrada para adicionar botoes ao browse da rotina  ���
���          �de funcoes contas a receber                                 ���
���          �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function FA740BRW()   

Local aRotina := {}

AAdd(aRotina, {'Boleto', 'U_TIBBOLETO()', 0,4, 0, NIL})

Return aRotina



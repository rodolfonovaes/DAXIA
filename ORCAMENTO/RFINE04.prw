#Include 'Rwmake.ch'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RFINE04   �Autor  �Nelson A. Pascoal   � Data �  05/07/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o para calculo do valor liquido para envio ao banco   ���
���          � atraves do CNAB                                            ���
�������������������������������������������������������������������������͹��
���Uso       � CNABS COBRANCA                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RFINE04()

Local _nValPgto, _nValImp
Local _nValImpr := ""
                                   
_nValPgto	:= SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",SE1->E1_MOEDA,SE1->E1_EMISSAO,SE1->E1_CLIENTE,SE1->E1_LOJA)
_nValImp	:= Alltrim(Str(((SE1->E1_SALDO - _nValPgto)*100)+ SE1->E1_ACRESC) )  

_nValImpr := STRZERO(val(_nValImp),13)

Return _nValImpr
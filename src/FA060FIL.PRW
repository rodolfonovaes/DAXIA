/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � FA60FIL  � Autor � Jose Choite Kita Jr   � Data �  07/07/06���
�������������������������������������������������������������������������Ĵ��
���Descri��o � PONTO.......: FA60FIL           PROGRAMA....: FINA060      ���
���          � Executado na sele��o de registros a serem processados para ���
���          � a elabora�� do bordero                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Filtrar titulos dos bancos definido na geracao do bordero  ���
���          � de acordo com titulo gerado com C5_BCOBOL                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

//ADAPTADO B. VINICIUS 24/10/19

User Function FA60FIL()

Local cPortador := ParamIXB[1]
Local cFiltro := ""

If MsgYesNo("T�tulos Impress�o DAXIA?")
    cFiltro := " Left(SE1->E1_PORTADO,3) = '"+Left(cPortador,3)+"' "
else
    cFiltro := " Empty(SE1->E1_PORTADO)  "
Endif

Return(cFiltro)



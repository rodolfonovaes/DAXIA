/*
�������������������������������������������������������������������������Ĵ��
���Descri��o � Calcula valor total do pedido                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Usado no campo virtual C5_XTOTAL para demonstrar o valor   ���
���          � total do pedido.                                           ���                                     
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function Vtotped(xfil,xcc)
Local cQuery
Local nRet
Local aArea := GetArea() 
Local cAlias     := GetNextAlias()


cQuery := "SELECT SUM(C6_QTDVEN * C6_PRCVEN) AS nTot FROM "+RETSQLNAME('SC6')+" WHERE C6_FILIAL='"+xfil+"' AND C6_NUM='"+xcc+"' AND D_E_L_E_T_ <> '*'"
cQuery := ChangeQuery(cQuery)
DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAlias,.F.,.T.)
nRet := (cAlias)->nTot
DBCloseArea()                                    
                        
RestArea(aArea)
Return(nRet)

/*
굇쳐컴컴컴컴컵컴컴컴컴컴컨컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Calcula valor total do pedido                              낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso      � Usado no campo virtual C5_XTOTAL para demonstrar o valor   낢�
굇�          � total do pedido.                                           낢�                                     
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
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

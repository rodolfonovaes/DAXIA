#INCLUDE "PROTHEUS.CH"
/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un嘺o    砎TOTORC   � Autor � TOTVS IBIRAPUERA     � Data � 17/06/19  潮�
北媚哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o � Calcula valor total do or鏰mento                           潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � Usado no campo virtual CJ_XTOTAL para demonstrar o valor   潮�
北�          � total do or鏰mento.                                        潮�                                     
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/

User Function Vtotorc(xfil,xcc)
Local cQuery
Local nRet
Local aArea := GetArea() 
Local cAlias     := GetNextAlias()


cQuery := "SELECT SUM(CK_QTDVEN * CK_PRCVEN) AS nTot FROM "+RETSQLNAME('SCK')+" WHERE CK_FILIAL='"+xfil+"' AND CK_NUM='"+xcc+"' AND D_E_L_E_T_ <> '*'"
cQuery := ChangeQuery(cQuery)
DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAlias,.F.,.T.)
nRet := (cAlias)->nTot
DBCloseArea()                                    
                        
RestArea(aArea)
Return(nRet)

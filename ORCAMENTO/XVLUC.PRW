#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Funcao    XVLUC    � Autor �  TOTVS IBIRAPUERA       � Data �01/07/2020 ���
��������������������������������������������������������������������������Ĵ��
���          �Execblock para calcular o valor da �ltima compra do cliente  ���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Parametros�                                                             ���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Uso       � A1_XVLUC                                                    ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������                        
������������������������������������������������������������������������������
/*/

USER FUNCTION XVLUC 
Local cQuery	:= ""
Local nRet 		:= 0
Local cAlias   	:= GetNextAlias()         

cQuery := "SELECT F2_VALBRUT AS VLUC FROM SF2010 SF2 WHERE SF2.D_E_L_E_T_ = '' AND F2_CLIENTE = '" + SA1->A1_COD + "' AND F2_LOJA = '" + SA1->A1_LOJA + "' AND F2_EMISSAO = ( "
cQuery += "SELECT MAX(F2_EMISSAO) "
cQuery += "FROM SF2010 SF2 "
cQuery += "WHERE F2_CLIENTE = '" + SA1->A1_COD + "' AND F2_LOJA = '" + SA1->A1_LOJA + "' AND SF2.D_E_L_E_T_ = '' "
cQuery += "GROUP BY F2_CLIENTE )"

cQuery  := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGenQry( Nil, Nil, cQuery ), cAlias, .T., .F. )  
nRet  := (cAlias)->VLUC

Return nRet   
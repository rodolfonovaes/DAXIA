#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪目北
北矲uncao    XDTMC    � Autor �  TOTVS IBIRAPUERA       � Data �01/07/2020 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪拇北
北�          矱xecblock para calcular a data da maior compra do cliente    潮�
北�          �                                                             潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砅arametros�                                                             潮�
北�          �                                                             潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砋so       � A1_XDTMC                                                    潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北                        
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
/*/

USER FUNCTION XDTMC 
Local cQuery	:= ""
Local dRet 		:= Ctod("  /  /  " )  
Local cAlias   	:= GetNextAlias()         

cQuery := "SELECT F2_EMISSAO AS DTMC FROM SF2010 SF2 WHERE SF2.D_E_L_E_T_ = '' AND F2_CLIENTE = '" + SA1->A1_COD + "' AND F2_LOJA = '" + SA1->A1_LOJA + "' AND F2_VALBRUT = ( "
cQuery += "SELECT MAX(F2_VALBRUT) "
cQuery += "FROM SF2010 SF2 "
cQuery += "WHERE F2_CLIENTE = '" + SA1->A1_COD + "' AND F2_LOJA = '" + SA1->A1_LOJA + "' AND SF2.D_E_L_E_T_ = '' "
cQuery += "GROUP BY F2_CLIENTE )"

cQuery  := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGenQry( Nil, Nil, cQuery ), cAlias, .T., .F. )  
dRet  := (cAlias)->DTMC

Return dRet   
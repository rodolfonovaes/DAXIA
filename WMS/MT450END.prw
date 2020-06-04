#INCLUDE "TOPCONN.CH"	
#INCLUDE "TBICONN.CH" 
#INCLUDE "PROTHEUS.CH"
//PE PARA QUEBRAR A SC9 QDO ULTRAPASSAR A NORMA
User Function MT450END()
Local aArea     := GetArea()
Local cPed   := SC9->C9_PEDIDO
Local cAliasQry := GetNextAlias()
Local cSrv		 := SuperGetMV('ES_SERVDIS',.T.,'019',cFilAnt)
Local cQuery        := ''

cQuery := "	SELECT R_E_C_N_O_ AS REC " 
cQuery += " FROM " + RetSqlName( "SC9" ) + " SC9 "
cQuery += " WHERE SC9.D_E_L_E_T_ = ' ' AND "
cQuery += "		SC9.C9_FILIAL =  '" +  xFilial('SC9') + "' AND " 
cQuery += "     SC9.C9_PEDIDO =  '" + cPed + "'	AND "	  		
cQuery += "     SC9.C9_SERVIC =  '" + cSrv + "'	AND "	  		
cQuery += "     SC9.C9_BLEST = '  '  "	  		

If Select(cAliasQry) > 0
    (cAliasQry)->(DbCloseArea())
EndIf

TcQuery cQuery new Alias ( cAliasQry )
If !(cAliasQry)->(Eof())
    SC9->(DbGoTo((cAliasQry)->REC))
    If U_DaxLib(SC9->C9_PEDIDO)
        U_AjustaC9(cPed)
    EndIf
EndIf

RestArea(aArea)

Return Nil
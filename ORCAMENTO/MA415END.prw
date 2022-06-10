#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"
User Function MA415END()
Local nTipo   := PARAMIXB[1]
Local nOper   := PARAMIXB[2]

If nTipo == 1 .And. nOper == 1 .And. Isincallstack('A415COPIA')
    RecLock('SCJ',.F.)
    SCJ->CJ_XUSER := SUBSTR(CUSUARIO,7,15)
    SCJ->CJ_XDATE := dDataBase
    SCJ->CJ_XTIME := TIME()
    MsUnLock()
EndIF

SetKey(VK_F7,{||U_RntOrcDx()})
SetKey(VK_F8,{||U_OrcRntIt()})    

Return  

User Function GFEX0101 ()     
Local nRet := 2
If IsInCallStack('U_DXGFEFRT')
    //Não apresentar a tela de resultado
    nRet := 0  
EndIf
Return nRet

User Function AVCADGE()
Local aArea     := GetArea()
Local cCodTab   := SUPERGETMV('ES_DAXTAB',.T.,'001')
Local dDataDA0  := SUPERGETMV('ES_DTDA0',.T.,dDataBase,cFilAnt)
Local cFilBkp   := cFilAnt
Local aSM0  	:= FWLoadSM0()
Local nX		:= 0
Local cParam := If(Type("ParamIxb") = "A",ParamIxb[1],If(Type("ParamIxb") = "C",ParamIxb,""))

if cParam == "x"
    
    If MsgYesNo('Confirma a atualiza��o das tabelas de pre�o com a cota��o do dolar :' + Alltrim(Transform( M->YE_VLCON_C, "@E 999,999,999,999.99" )) + '?')		
        SM2->(dbSetOrder(1))
        SM2->(DbSeek(DTOS(dDataBase)))

        If  RecLock('SM2',.F.)
            SM2->M2_MOEDA2 :=  M->YE_VLCON_C
            MsUnLock()
            
            For nX	:= 1 to Len(aSM0)
                cFilAnt := aSM0[nX][2]
                    
                //If dDataDA0 <> dDataBase
                    U_DaxJob01()
                //EndIf
                //U_UpdDA1()
            Next
        Else
            Alert('N�o foi possivel atualizar as tabelas de pre�o, tente novamente')
        EndIf
    EndIf
    cFilAnt := cFilBkp
EndIF
RestArea(aArea)    

Return Nil

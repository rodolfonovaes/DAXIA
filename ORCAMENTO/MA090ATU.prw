#INCLUDE "PROTHEUS.CH"

 /*/{Protheus.doc} MA090ATU
    (long_description)
    @type  Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function MA090ATU()
Local aArea     := GetArea()
Local cCodTab   := SUPERGETMV('ES_DAXTAB',.T.,'001')
Local dDataDA0  := SUPERGETMV('ES_DTDA0',.T.,dDataBase,cFilAnt)
Local cFilBkp   := cFilAnt
Local aSM0  	:= FWLoadSM0()
Local nX		:= 0
If MsgYesNo('Confirma a atualização das tabelas de preço com a cotação do dolar :' + Alltrim(Transform( SM2->M2_MOEDA2, "@E 999,999,999,999.99" )) + '?')		
    For nX	:= 1 to Len(aSM0)
        cFilAnt := aSM0[nX][2]
            
        //If dDataDA0 <> dDataBase
            U_DaxJob01()
        //EndIf
        //U_UpdDA1()
    Next
EndIf
cFilAnt := cFilBkp

RestArea(aArea)
Return
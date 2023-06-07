#Include 'PROTHEUS.CH'
#Include 'RWMAKE.CH'
#Include 'topconn.ch'
#Include 'tbiconn.ch'
/*/{Protheus.doc} DAXJOBA2
    Bloqueia fornecedores com homologação vencida
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
User Function DAXJOBA2(aFilial)
Local cQrySA2	:= ""
Local cAliasQry	:= ''
Local cQry	:= ""
Local cAliasQry2	:= ''
Local cLocQual	:= ''
Local nCount    := 0
Local nAtu      := 0
Local nErro      := 0


If Select("SX2") == 0
    cEmpProc	:= '01'
    cFilProc	:= aFilial[2]
	//Preparando o ambiente
	RPCSetType(3)
	CONOUT('DAXJOBA2 - Empresa ' + cEmpProc + '/ Filial '+ cFilProc)

	RPCSetEnv(cEmpProc, cFilProc, "", "", "")
EndIf
cAliasQry	:= GetNextAlias()
cAliasQry2	:= GetNextAlias()
cQrySA2			:= ""
cQrySA2			:= " SELECT R_E_C_N_O_ AS REC FROM " + RetSqlName("SA2") + " SA2 "
cQrySA2			+= " WHERE "
cQrySA2			+= "       SA2.A2_FILIAL   = '" + xFilial("SA2") + "' "
//cQrySA2			+= "   AND SA2.A2_MSBLQL  <> '1' "
//cQ1rySA2			+= "   AND SA2.A2_DTVAL    < '"+ Dtos(dDataBase) + "' "
cQrySA2			+= "   AND ((SA2.A2_DTVAL    < '"+ Dtos(dDataBase) + "' AND SA2.A2_MSBLQL  <> '1') OR "
cQrySA2			+= "        (SA2.A2_DTVAL    >= '"+ Dtos(dDataBase) + "' AND SA2.A2_MSBLQL  = '1')) AND SA2.A2_DTVAL    <> ' ' "
cQrySA2			+= "   AND SA2.D_E_L_E_T_ = ' ' "
cQrySA2			:= ChangeQuery( cQrySA2 )

CONOUT('DAXJOBA2 - QUERY ' + cQrySA2)

DbUseArea(.T., "TopConn", TCGenQry(, , cQrySA2 ), cAliasQry, .F., .F. )
DbSelectArea( cAliasQry )
( cAliasQry )->( DbGoTop() )
While ( cAliasQry )->( !Eof() )
    nCount ++
    SA2->(DbGoTo(( cAliasQry )->REC))
    RecLock('SA2', .F.)
    If SA2->A2_DTVAL < dDataBase
        SA2->A2_MSBLQL := '1'
    Else
        SA2->A2_MSBLQL := '2'
    EndIf
    MsUnlock()
    DbSelectArea( cAliasQry )
    ( cAliasQry )->( DbSkip() )
EndDo

CONOUT('DAXJOBA2 - Fim da execução  Atualizados - ' + Alltrim(Str(nCount)) + ' - registros .' )
Return 

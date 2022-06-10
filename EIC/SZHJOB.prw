#Include 'PROTHEUS.CH'
#Include 'RWMAKE.CH'
#Include 'topconn.ch'
#Include 'tbiconn.ch'
 /*/{Protheus.doc} SZHJOB
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
User Function SZHJOB(aFilial)
Local lJob := .F.
PRIVATE cEmpProc	:= '01'
PRIVATE cFilProc	:= ''


If Select("SX2") == 0
    cFilProc	:= aFilial[2]
	//Preparando o ambiente
	RPCSetType(3)
	CONOUT('DAXJOBB8 - Empresa ' + cEmpProc + '/ Filial '+ cFilProc)
    lJob := .T.
	RPCSetEnv(cEmpProc, cFilProc, "", "", "")
EndIf

If lJob .Or. MsgYesNo('Deseja atualizar a tabela de despesas?', "Atualiza SZH")

    CONOUT('SZHJOB - Inicio da execução' )
    UpdZH()
    CONOUT('SZHJOB - Fim da execução' )
    If !lJob
        MsgInfo('SZHJOB - Fim da execução' ,"Fim")
    EndIf
EndIf

Return 


Static Function UpdZH()
Local cQuery := ''
Local lReclock := .T.

cQuery := "SELECT SWH.* , ZH_PO_NUM FROM " + RetSqlName("SWH") + " SWH "
cQuery += " LEFT JOIN " + RetSqlName("SZH") + " SZH ON ZH_PO_NUM = WH_PO_NUM AND ZH_NR_CONT = WH_NR_CONT AND ZH_DESPESA = WH_DESPESA "
cQuery += "  WHERE "
cQuery += "  SWH.WH_DTAPUR = (SELECT MAX(WH_DTAPUR) FROM SWH010 SWHB WHERE SWHB.WH_PO_NUM = SWH.WH_PO_NUM)"
cQuery += " GROUP BY SWH.WH_FILIAL, SWH.WH_PO_NUM, SWH.WH_NR_CONT, SWH.WH_DESPESA , SWH.WH_MOEDA , SWH.WH_PER_DES , SWH.WH_VALOR , SWH.WH_DESC , SWH.WH_VALOR_R , SWH.WH_DTAPUR ,SWH.D_E_L_E_T_ , SWH.R_E_C_N_O_ ,SWH.R_E_C_D_E_L_ ,ZH_PO_NUM"   

If Select('TMPSZH') > 0
    ('TMPSZH')->(DbCloseArea())
EndIf

TCQUERY cQuery New Alias "TMPSZH"

Dbselectarea("TMPSZH")
dbGoTop()
SZH->(DbSetOrder(1))
While TMPSZH->(!EOF())
    If SZH->(DbSeek(TMPSZH->WH_FILIAL + PADR(TMPSZH->WH_PO_NUM,TAMSX3('ZH_PO_NUM')[1]) + PADR(STR(TMPSZH->WH_NR_CONT,4,0),TAMSX3('ZH_NR_CONT')[1])  + PADR(TMPSZH->WH_DESPESA,TAMSX3('ZH_DESPESA')[1])  ))
        lReclock := .F.
    Else
        lReclock := .T.
    EndIf
    RecLock('SZH',lReclock)
    SZH->ZH_FILIAL := TMPSZH->WH_FILIAL
    SZH->ZH_PO_NUM := TMPSZH->WH_PO_NUM
    SZH->ZH_NR_CONT := TMPSZH->WH_NR_CONT
    SZH->ZH_DESPESA := TMPSZH->WH_DESPESA
    SZH->ZH_MOEDA   := TMPSZH->WH_MOEDA
    SZH->ZH_PER_DES := TMPSZH->WH_PER_DES
    SZH->ZH_VALOR   := TMPSZH->WH_VALOR
    SZH->ZH_DESC    := TMPSZH->WH_DESC
    SZH->ZH_VALOR_R := TMPSZH->WH_VALOR_R
    SZH->ZH_DTAPUR  := STOD(TMPSZH->WH_DTAPUR)
    MsUnlock()

    TMPSZH->(DbSkip())
EndDo

Return




User Function AjuZH()
Local cQuery := ''
Local lReclock := .T.

cQuery := "select ZH_PO_NUM , ZH_FILIAL , W2_FILIAL ,  SZH.R_E_C_N_O_ AS REC  FROM " + RetSqlName("SZH") + " SZH "
cQuery += " INNER JOIN " + RetSqlName("SW2") + " SW2 ON W2_PO_NUM = ZH_PO_NUM  AND ZH_FILIAL <> W2_FILIAL "
cQuery += "  WHERE "
cQuery += "  SZH.D_E_L_E_T_ = ' ' AND SW2.D_E_L_E_T_ = ' '"

If Select('TMPSZH') > 0
    ('TMPSZH')->(DbCloseArea())
EndIf

TCQUERY cQuery New Alias "TMPSZH"

Dbselectarea("TMPSZH")
dbGoTop()
While TMPSZH->(!EOF())

    SZH->(DbGoTo(TMPSZH->REC))
    RecLock('SZH',.F.)
    SZH->ZH_FILIAL := TMPSZH->W2_FILIAL
    MsUnlock()

    TMPSZH->(DbSkip())
EndDo

Return

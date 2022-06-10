#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
/*/{Protheus.doc} DXPROD1()
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
User Function ATUSBZ()
Local aPergs :={}
Local aRet   :={}
Local nTipo     := 1

PROCSBZ()

Return


Static Function PROCSBZ()
Local cAliasQry	:= GetNextAlias()
Local cQry	:= ""
Local aCampos    := 0 
Local bCampo     := {|x| FieldName(x)}
Local aRet       := {}
Local cLog      := ''
Local nVlrOri   := 0
Local cProd     := ''
Local nCusto    := 0

cQry			:= ""
cQry			:= " SELECT DISTINCT SBZ.R_E_C_N_O_ AS REC FROM " + RetSqlName("SBZ") + " SBZ "
cQry			+= " WHERE "
cQry			+= "       SBZ.D_E_L_E_T_ = ' ' AND BZ_FILIAL = '0103' AND BZ_XTIPO IN ('ME','PA') "
cQry			:= ChangeQuery( cQry )

DbUseArea(.T., "TopConn", TCGenQry(, , cQry ), cAliasQry, .F., .F. )
DbSelectArea( cAliasQry )
( cAliasQry )->( DbGoTop() )
While ( cAliasQry )->( !Eof() )
    SBZ->(DbGoTo(( cAliasQry )->REC))
    nVlrOri := SBZ->BZ_CUSTD
    cProd   := SBZ->BZ_COD

    SBZ->(DbSetOrder(1))
    If SBZ->(DbSeek('0102'+cProd))
        If SBZ->BZ_MCUSTD  == '1'
            nCusto := nVlrOri + SuperGetMV('ES_CUSADDR',.F.,0.23,'0102')
        Else
            nCusto := nVlrOri + xMoeda(SuperGetMV('ES_CUSADDD',.F.,0.05,'0102'),2,1,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2'))
        EndIF
        RecLock('SBZ', .F.)
        SBZ->BZ_CUSTD := nCusto
        MsUnlock()
    EndIf

    If SBZ->(DbSeek('0104'+cProd))
        If SBZ->BZ_MCUSTD  == '1'
            nCusto := nVlrOri + SuperGetMV('ES_CUSADDR',.F.,0.40,'0104')
        Else
            nCusto := nVlrOri + xMoeda(SuperGetMV('ES_CUSADDD',.F.,0.08,'0104'),2,1,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2'))
        EndIF
        RecLock('SBZ', .F.)
        SBZ->BZ_CUSTD := nCusto
        MsUnlock()
    EndIf    
       
    cLog += 'Atualizado Produto ' + cProd + CRLF
    ( cAliasQry )->(DbSkip())
Enddo
( cAliasQry )->(DbCloseArea())

HS_MSGINF("Resumo do processamento :" + CRLF + cLog ,"Geração arquivo ")

Return 



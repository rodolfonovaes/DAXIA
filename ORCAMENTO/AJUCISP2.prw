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
User Function AJUCISP2()
Local aPergs :={}
Local aRet   :={}
Local nTipo     := 1

PROCSA1()

Return


Static Function PROCSA1()
Local cAliasQry	:= GetNextAlias()
Local cQry	:= ""
Local aCampos    := 0 
Local bCampo     := {|x| FieldName(x)}
Local aRet       := {}
Local cLog      := ''

cQry			:= " SELECT DISTINCT SC5.R_E_C_N_O_ AS REC FROM " + RetSqlName("SC5") + " SC5 "
cQry			+= " WHERE "
cQry			+= "       SC5.D_E_L_E_T_ = ' ' AND C5_NOTA <> ' ' AND C5_NOTA <> 'XXXXXXXXX' "
cQry			:= ChangeQuery( cQry )

DbUseArea(.T., "TopConn", TCGenQry(, , cQry ), cAliasQry, .F., .F. )
DbSelectArea( cAliasQry )
( cAliasQry )->( DbGoTop() )
While ( cAliasQry )->( !Eof() )
    SC5->(DbGoTo(( cAliasQry )->REC))
    Reclock('SC5',.F.)
    SC5->C5_BLEST := '10'
    SC5->C5_BLCRED := '10'
    MsUnlock()
    cLog += 'Atualizado PEDIDO ' + SC5->C5_NUM + CRLF
    ( cAliasQry )->(DbSkip())
Enddo
( cAliasQry )->(DbCloseArea())

HS_MSGINF("Resumo do processamento :" + CRLF + cLog ,"Geração arquivo ")

Return 

#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

 /*/{Protheus.doc} DXFRTCIF
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
User Function DXFRTCIF()
Local cQuery := ''
Local cAliasQry := GetNextAlias()
Local nVolume   := 0
Local nRec      := TMP1->(recno())
Local nRet      := 0
Local cCidOri   := ''
Local cEstOri   := ''
Local cFaixa    := ''

SA1->(DbSetOrder(1))
SA1->(DBSeek(xFilial('SA1') + M->(CJ_CLIENTE + CJ_LOJA)))

cCidade := SA1->A1_COD_MUN
cEst    := SA1->A1_EST


do case
    Case cFilAnt == '0101'
        cEstOri := '35'
        cCidOri := '50308'    
    Case cFilAnt == '0102'
        cEstOri := '42'
        cCidOri := '08203'
    Case cFilAnt == '0103'
        cEstOri := '35'
        cCidOri := '18800'
    Case cFilAnt == '0104'
        cEstOri := '26'
        cCidOri := '07901'            
EndCase

//Itens								
dbSelectArea("TMP1")
dbGoTop()

While !Eof()
    If !("TMP1")->CK_FLAG 
        nVolume += 	TMP1->CK_QTDVEN
    EndIf
    TMP1->(DbSkip())
EndDo

cFaixa := RetFaixa(nVolume,cEst,cCidade,cEstOri , cCidOri)

cQuery := " SELECT GV1_CDCOMP, GV7_QTFXFI, SUM(GV1_VLFIXN) AS VALOR , GV1_VLMINN , GV1_PCNORM , GV1_VLUNIN , GV1_VLFRAC"
cQuery += " FROM "+RetSQLName("SA4") + " AS SA4 " //WITH (NOLOCK)
cQuery += " INNER JOIN "+RetSQLName("GU3") + " AS GU3 ON GU3_IDFED = A4_CGC AND GU3.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
cQuery += " INNER JOIN "+RetSQLName("GV8") + " AS GV8 ON GU3_CDEMIT = GV8_CDEMIT  AND GV8.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
cQuery += " INNER JOIN "+RetSQLName("GU7") + " AS GU7 ON GU7_NRCID = GV8_NRCIDS  AND GU7.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
cQuery += " INNER JOIN "+RetSQLName("GV1") + " AS GV1 ON GV1_CDEMIT = GV8_CDEMIT AND GV8_NRTAB = GV1_NRTAB AND GV8_NRNEG = GV1_NRNEG AND GV8_NRROTA = GV1_NRROTA  AND GV1.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
cQuery += " INNER JOIN "+RetSQLName("GV7") + " AS GV7 ON GV7_CDEMIT = GV8_CDEMIT AND GV8_NRTAB = GV7_NRTAB AND GV8_NRNEG = GV7_NRNEG AND GV7.D_E_L_E_T_ = ' ' AND GV1_CDFXTV = GV7_CDFXTV " //WITH (NOLOCK)
cQuery += " WHERE A4_FILIAL  = '" + xFilial("SA4") + "' "
cQuery += " AND SA4.D_E_L_E_T_= ' ' "
cQuery += " AND SA4.A4_COD = '"+ M->CJ_XTRANSP +"' "
cQuery += " AND GU7_CDUF =  '" + cEst + "' "
cQuery += " AND SUBSTRING(GU7_NRCID,3,5) =  '" + cCidade + "' "
cQuery += " AND GV7_QTFXFI =  '" + cFaixa + "' "
cQuery += " GROUP BY GV1_CDCOMP , GV7_QTFXFI , GV1_VLMINN ,GV1_PCNORM , GV1_VLUNIN ,GV1_VLFRAC"
cQuery += " ORDER BY GV7_QTFXFI  "


TcQuery cQuery new Alias ( cAliasQry )

(cAliasQry)->(dbGoTop())

While !(cAliasQry)->(EOF())
    If (cAliasQry)->VALOR > 0
        nRet += (cAliasQry)->VALOR
    Else
        If Alltrim((cAliasQry)->GV1_CDCOMP) == 'FRETE PESO'
            IF M->CJ_XVLTOT * ((cAliasQry)->GV1_VLUNIN / 100) >= (cAliasQry)->GV1_VLMINN
                nRet += M->CJ_XVLTOT * ((cAliasQry)->GV1_VLUNIN / 100)
            Else
                nRet += (cAliasQry)->GV1_VLMINN
            EndIf
        ElseIf Alltrim((cAliasQry)->GV1_CDCOMP) == 'PEDAGIO'
            IF Ceiling(nVolume / (cAliasQry)->GV1_VLFRAC) * (cAliasQry)->GV1_VLUNIN >= (cAliasQry)->GV1_VLMINN
                nRet += Ceiling(nVolume / (cAliasQry)->GV1_VLFRAC) * (cAliasQry)->GV1_VLUNIN 
            Else
                nRet += (cAliasQry)->GV1_VLMINN
            EndIf                
        Else
            IF M->CJ_XVLTOT * ((cAliasQry)->GV1_PCNORM / 100) >= (cAliasQry)->GV1_VLMINN
                nRet += M->CJ_XVLTOT * ((cAliasQry)->GV1_PCNORM / 100)
            Else
                nRet += (cAliasQry)->GV1_VLMINN
            EndIf        
        EndIf
    EndIf
    (cAliasQry)->(DBSkip())
EndDo

(cAliasQry)->(DBCloseArea())


//se nao encontrar valor especifico para a cidade, busca para regioes
If nRet == 0

    cQuery := " SELECT GV1_CDCOMP, GV7_QTFXFI, SUM(GV1_VLFIXN) AS VALOR , GV1_VLMINN , GV1_PCNORM , GV1_VLUNIN , GV1_VLFRAC"
    cQuery += " FROM "+RetSQLName("SA4") + " AS SA4 " //WITH (NOLOCK)
    cQuery += " INNER JOIN "+RetSQLName("GU3") + " AS GU3 ON GU3_IDFED = A4_CGC AND GU3.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
    cQuery += " INNER JOIN "+RetSQLName("GV8") + " AS GV8 ON GU3_CDEMIT = GV8_CDEMIT  AND GV8.D_E_L_E_T_ = ' ' AND GV8_TPDEST = '3' " //WITH (NOLOCK)
    cQuery += " INNER JOIN "+RetSQLName("GV1") + " AS GV1 ON GV1_CDEMIT = GV8_CDEMIT AND GV8_NRTAB = GV1_NRTAB AND GV8_NRNEG = GV1_NRNEG AND GV8_NRROTA = GV1_NRROTA  AND GV1.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
    cQuery += " INNER JOIN "+RetSQLName("GV7") + " AS GV7 ON GV7_CDEMIT = GV8_CDEMIT AND GV8_NRTAB = GV7_NRTAB AND GV8_NRNEG = GV7_NRNEG AND GV7.D_E_L_E_T_ = ' '  AND GV1_CDFXTV = GV7_CDFXTV " //WITH (NOLOCK)
    cQuery += " INNER JOIN "+RetSQLName("GUA") + " AS GUA ON GV8_NRREDS = GUA_NRREG AND GUA.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
    cQuery += " WHERE A4_FILIAL  = '" + xFilial("SA4") + "' "
    cQuery += " AND SA4.D_E_L_E_T_= ' ' "
    cQuery += " AND SA4.A4_COD = '"+ M->CJ_XTRANSP +"' "
    cQuery += " AND (GV8_NRCIOR =  '" + cEstOri + cCidOri + "' OR GV8_TPORIG = '0')"
    cQuery += " AND GUA_NRCID =  '" + cEstOri + cCidOri + "' "
    cQuery += " AND GV7_QTFXFI =  '" + cFaixa + "' "
    cQuery += " GROUP BY GV1_CDCOMP , GV7_QTFXFI , GV1_VLMINN ,GV1_PCNORM , GV1_VLUNIN ,GV1_VLFRAC"
    cQuery += " ORDER BY GV7_QTFXFI  "

    TcQuery cQuery new Alias ( cAliasQry )

    (cAliasQry)->(dbGoTop())

    While !(cAliasQry)->(EOF())
        If (cAliasQry)->VALOR > 0
            nRet += (cAliasQry)->VALOR
        Else
            If Alltrim((cAliasQry)->GV1_CDCOMP) == 'FRETE PESO'
                IF M->CJ_XVLTOT * ((cAliasQry)->GV1_VLUNIN / 100) >= (cAliasQry)->GV1_VLMINN
                    nRet += M->CJ_XVLTOT * ((cAliasQry)->GV1_VLUNIN / 100)
                Else
                    nRet += (cAliasQry)->GV1_VLMINN
                EndIf
            ElseIf Alltrim((cAliasQry)->GV1_CDCOMP) == 'PEDAGIO'
                IF Ceiling(nVolume / (cAliasQry)->GV1_VLFRAC) * (cAliasQry)->GV1_VLUNIN >= (cAliasQry)->GV1_VLMINN
                    nRet += Ceiling(nVolume / (cAliasQry)->GV1_VLFRAC) * (cAliasQry)->GV1_VLUNIN 
                Else
                    nRet += (cAliasQry)->GV1_VLMINN
                EndIf                 
            Else
                IF M->CJ_XVLTOT * ((cAliasQry)->GV1_PCNORM / 100) >= (cAliasQry)->GV1_VLMINN
                    nRet += M->CJ_XVLTOT * ((cAliasQry)->GV1_PCNORM / 100)
                Else
                    nRet += (cAliasQry)->GV1_VLMINN
                EndIf        
            EndIf
        EndIf
        (cAliasQry)->(DBSkip())
    EndDo

    (cAliasQry)->(DBCloseArea())

EndIf
//se nao encontrar valor especifico para a cidade, busca para o estado
If nRet == 0

    cQuery := " SELECT GV1_CDCOMP, GV7_QTFXFI, SUM(GV1_VLFIXN) AS VALOR , GV1_VLMINN , GV1_PCNORM , GV1_VLUNIN , GV1_VLFRAC"
    cQuery += " FROM "+RetSQLName("SA4") + " AS SA4 " //WITH (NOLOCK)
    cQuery += " INNER JOIN "+RetSQLName("GU3") + " AS GU3 ON GU3_IDFED = A4_CGC AND GU3.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
    cQuery += " INNER JOIN "+RetSQLName("GV8") + " AS GV8 ON GU3_CDEMIT = GV8_CDEMIT  AND GV8.D_E_L_E_T_ = ' ' AND GV8_TPDEST = '4' " //WITH (NOLOCK)
    cQuery += " INNER JOIN "+RetSQLName("GV1") + " AS GV1 ON GV1_CDEMIT = GV8_CDEMIT AND GV8_NRTAB = GV1_NRTAB AND GV8_NRNEG = GV1_NRNEG AND GV8_NRROTA = GV1_NRROTA  AND GV1.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
    cQuery += " INNER JOIN "+RetSQLName("GV7") + " AS GV7 ON GV7_CDEMIT = GV8_CDEMIT AND GV8_NRTAB = GV7_NRTAB AND GV8_NRNEG = GV7_NRNEG AND GV7.D_E_L_E_T_ = ' '  AND GV1_CDFXTV = GV7_CDFXTV " //WITH (NOLOCK)
    cQuery += " WHERE A4_FILIAL  = '" + xFilial("SA4") + "' "
    cQuery += " AND SA4.D_E_L_E_T_= ' ' "
    cQuery += " AND SA4.A4_COD = '"+ M->CJ_XTRANSP +"' "
    cQuery += " AND (GV8_NRCIOR =  '" + cEstOri + cCidOri + "' OR GV8_TPORIG = '0')"
    cQuery += " AND GV8_CDUFDS =  '" + cEst + "' "
    cQuery += " AND GV7_QTFXFI =  '" + cFaixa + "' "
    cQuery += " GROUP BY GV1_CDCOMP , GV7_QTFXFI , GV1_VLMINN ,GV1_PCNORM , GV1_VLUNIN ,GV1_VLFRAC"
    cQuery += " ORDER BY GV7_QTFXFI  "

    TcQuery cQuery new Alias ( cAliasQry )

    (cAliasQry)->(dbGoTop())

    While !(cAliasQry)->(EOF())
        If (cAliasQry)->VALOR > 0
            nRet += (cAliasQry)->VALOR
        Else
            If Alltrim((cAliasQry)->GV1_CDCOMP) == 'FRETE PESO'
                IF M->CJ_XVLTOT * ((cAliasQry)->GV1_VLUNIN / 100) >= (cAliasQry)->GV1_VLMINN
                    nRet += M->CJ_XVLTOT * ((cAliasQry)->GV1_VLUNIN / 100)
                Else
                    nRet += (cAliasQry)->GV1_VLMINN
                EndIf
            ElseIf Alltrim((cAliasQry)->GV1_CDCOMP) == 'PEDAGIO'
                IF Ceiling(nVolume / (cAliasQry)->GV1_VLFRAC) * (cAliasQry)->GV1_VLUNIN >= (cAliasQry)->GV1_VLMINN
                    nRet += Ceiling(nVolume / (cAliasQry)->GV1_VLFRAC) * (cAliasQry)->GV1_VLUNIN 
                Else
                    nRet += (cAliasQry)->GV1_VLMINN
                EndIf                 
            Else
                IF M->CJ_XVLTOT * ((cAliasQry)->GV1_PCNORM / 100) >= (cAliasQry)->GV1_VLMINN
                    nRet += M->CJ_XVLTOT * ((cAliasQry)->GV1_PCNORM / 100)
                Else
                    nRet += (cAliasQry)->GV1_VLMINN
                EndIf        
            EndIf
        EndIf
        (cAliasQry)->(DBSkip())
    EndDo

    (cAliasQry)->(DBCloseArea())

EndIf


//se nao encontrar valor especifico para a cidade, busca para todas as cidades
If nRet == 0

    cQuery := " SELECT GV1_CDCOMP, GV7_QTFXFI, SUM(GV1_VLFIXN) AS VALOR , GV1_VLMINN , GV1_PCNORM , GV1_VLUNIN , GV1_VLFRAC"
    cQuery += " FROM "+RetSQLName("SA4") + " AS SA4 " //WITH (NOLOCK)
    cQuery += " INNER JOIN "+RetSQLName("GU3") + " AS GU3 ON GU3_IDFED = A4_CGC AND GU3.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
    cQuery += " INNER JOIN "+RetSQLName("GV8") + " AS GV8 ON GU3_CDEMIT = GV8_CDEMIT  AND GV8.D_E_L_E_T_ = ' ' AND GV8_TPDEST = '0' " //WITH (NOLOCK)
    cQuery += " INNER JOIN "+RetSQLName("GV1") + " AS GV1 ON GV1_CDEMIT = GV8_CDEMIT AND GV8_NRTAB = GV1_NRTAB AND GV8_NRNEG = GV1_NRNEG AND GV8_NRROTA = GV1_NRROTA  AND GV1.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
    cQuery += " INNER JOIN "+RetSQLName("GV7") + " AS GV7 ON GV7_CDEMIT = GV8_CDEMIT AND GV8_NRTAB = GV7_NRTAB AND GV8_NRNEG = GV7_NRNEG AND GV7.D_E_L_E_T_ = ' '  AND GV1_CDFXTV = GV7_CDFXTV " //WITH (NOLOCK)
    cQuery += " WHERE A4_FILIAL  = '" + xFilial("SA4") + "' "
    cQuery += " AND SA4.D_E_L_E_T_= ' ' "
    cQuery += " AND SA4.A4_COD = '"+ M->CJ_XTRANSP +"' "
    cQuery += " AND (GV8_NRCIOR =  '" + cEstOri + cCidOri + "' OR GV8_TPORIG = '0')"
    cQuery += " AND GV7_QTFXFI =  '" + cFaixa + "' "
    cQuery += " GROUP BY GV1_CDCOMP , GV7_QTFXFI , GV1_VLMINN ,GV1_PCNORM , GV1_VLUNIN ,GV1_VLFRAC"
    cQuery += " ORDER BY GV7_QTFXFI  "

    TcQuery cQuery new Alias ( cAliasQry )

    (cAliasQry)->(dbGoTop())

   While !(cAliasQry)->(EOF())
        If (cAliasQry)->VALOR > 0
            nRet += (cAliasQry)->VALOR
        Else
            If Alltrim((cAliasQry)->GV1_CDCOMP) == 'FRETE PESO'
                IF M->CJ_XVLTOT * ((cAliasQry)->GV1_VLUNIN / 100) >= (cAliasQry)->GV1_VLMINN
                    nRet += M->CJ_XVLTOT * ((cAliasQry)->GV1_VLUNIN / 100)
                Else
                    nRet += (cAliasQry)->GV1_VLMINN
                EndIf
            ElseIf Alltrim((cAliasQry)->GV1_CDCOMP) == 'PEDAGIO'
                IF Ceiling(nVolume / (cAliasQry)->GV1_VLFRAC) * (cAliasQry)->GV1_VLUNIN >= (cAliasQry)->GV1_VLMINN
                    nRet += Ceiling(nVolume / (cAliasQry)->GV1_VLFRAC) * (cAliasQry)->GV1_VLUNIN 
                Else
                    nRet += (cAliasQry)->GV1_VLMINN
                EndIf                    
            Else
                IF M->CJ_XVLTOT * ((cAliasQry)->GV1_PCNORM / 100) >= (cAliasQry)->GV1_VLMINN
                    nRet += M->CJ_XVLTOT * ((cAliasQry)->GV1_PCNORM / 100)
                Else
                    nRet += (cAliasQry)->GV1_VLMINN
                EndIf        
            EndIf
        EndIf
        (cAliasQry)->(DBSkip())
    EndDo
    (cAliasQry)->(DBCloseArea())
EndIf

M->CJ_XVLFRET := nRet
TMP1->(dbgoto(nRec))
Return nRet



/*/{Protheus.doc} RetFaixa(nFaixa)
    (long_description)
    @type  Static Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function RetFaixa(nVolume,cEst,cCidade,cEstOri , cCidOri)
Local cFaixa := ''
Local cQuery := ''
Local cAliasQry := GetNextAlias()


cQuery := " SELECT TOP 1 GV7_QTFXFI, SUM(GV1_VLFIXN) AS VALOR , GV1_VLMINN , GV1_PCNORM"
cQuery += " FROM "+RetSQLName("SA4") + " AS SA4 " //WITH (NOLOCK)
cQuery += " INNER JOIN "+RetSQLName("GU3") + " AS GU3 ON GU3_IDFED = A4_CGC AND GU3.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
cQuery += " INNER JOIN "+RetSQLName("GV8") + " AS GV8 ON GU3_CDEMIT = GV8_CDEMIT  AND GV8.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
cQuery += " INNER JOIN "+RetSQLName("GU7") + " AS GU7 ON GU7_NRCID = GV8_NRCIDS  AND GU7.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
cQuery += " INNER JOIN "+RetSQLName("GV1") + " AS GV1 ON GV1_CDEMIT = GV8_CDEMIT AND GV8_NRTAB = GV1_NRTAB AND GV8_NRNEG = GV1_NRNEG AND GV8_NRROTA = GV1_NRROTA  AND GV1.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
cQuery += " INNER JOIN "+RetSQLName("GV7") + " AS GV7 ON GV7_CDEMIT = GV8_CDEMIT AND GV8_NRTAB = GV7_NRTAB AND GV8_NRNEG = GV7_NRNEG AND GV7.D_E_L_E_T_ = ' ' AND GV1_CDFXTV = GV7_CDFXTV " //WITH (NOLOCK)
cQuery += " WHERE A4_FILIAL  = '" + xFilial("SA4") + "' "
cQuery += " AND SA4.D_E_L_E_T_= ' ' "
cQuery += " AND SA4.A4_COD = '"+ M->CJ_XTRANSP +"' "
cQuery += " AND GU7_CDUF =  '" + cEst + "' "
cQuery += " AND SUBSTRING(GU7_NRCID,3,5) =  '" + cCidade + "' "
cQuery += " AND GV7_QTFXFI >=  '" + Str(nVolume) + "' "
cQuery += " GROUP BY GV7_QTFXFI , GV1_VLMINN ,GV1_PCNORM  "
cQuery += " ORDER BY GV7_QTFXFI  "

TcQuery cQuery new Alias ( cAliasQry )

(cAliasQry)->(dbGoTop())

If !(cAliasQry)->(EOF())
    cFaixa := Str((cAliasQry)->GV7_QTFXFI)
EndIf
(cAliasQry)->(DBCloseArea())


If Empty(cFaixa)

    cQuery := " SELECT TOP 1 GV7_QTFXFI, SUM(GV1_VLFIXN) AS VALOR , GV1_VLMINN , GV1_PCNORM"
    cQuery += " FROM "+RetSQLName("SA4") + " AS SA4 " //WITH (NOLOCK)
    cQuery += " INNER JOIN "+RetSQLName("GU3") + " AS GU3 ON GU3_IDFED = A4_CGC AND GU3.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
    cQuery += " INNER JOIN "+RetSQLName("GV8") + " AS GV8 ON GU3_CDEMIT = GV8_CDEMIT  AND GV8.D_E_L_E_T_ = ' ' AND GV8_TPDEST = '3' " //WITH (NOLOCK)
    cQuery += " INNER JOIN "+RetSQLName("GV1") + " AS GV1 ON GV1_CDEMIT = GV8_CDEMIT AND GV8_NRTAB = GV1_NRTAB AND GV8_NRNEG = GV1_NRNEG AND GV8_NRROTA = GV1_NRROTA  AND GV1.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
    cQuery += " INNER JOIN "+RetSQLName("GV7") + " AS GV7 ON GV7_CDEMIT = GV8_CDEMIT AND GV8_NRTAB = GV7_NRTAB AND GV8_NRNEG = GV7_NRNEG AND GV7.D_E_L_E_T_ = ' '  AND GV1_CDFXTV = GV7_CDFXTV " //WITH (NOLOCK)
    cQuery += " INNER JOIN "+RetSQLName("GUA") + " AS GUA ON GV8_NRREDS = GUA_NRREG AND GUA.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
    cQuery += " WHERE A4_FILIAL  = '" + xFilial("SA4") + "' "
    cQuery += " AND SA4.D_E_L_E_T_= ' ' "
    cQuery += " AND SA4.A4_COD = '"+ M->CJ_XTRANSP +"' "
    cQuery += " AND (GV8_NRCIOR =  '" + cEstOri + cCidOri + "' OR GV8_TPORIG = '0')"
    cQuery += " AND GUA_NRCID =  '" + cEstOri + cCidOri + "' "
    cQuery += " AND GV7_QTFXFI >=  '" + Str(nVolume) + "' "
    cQuery += " GROUP BY GV7_QTFXFI , GV1_VLMINN , GV1_PCNORM  "
    cQuery += " ORDER BY GV7_QTFXFI  "

    TcQuery cQuery new Alias ( cAliasQry )

    (cAliasQry)->(dbGoTop())

    If !(cAliasQry)->(EOF())
        cFaixa := Str((cAliasQry)->GV7_QTFXFI)
    EndIf
    (cAliasQry)->(DBCloseArea())
EndIf

If Empty(cFaixa)

    cQuery := " SELECT TOP 1 GV7_QTFXFI, SUM(GV1_VLFIXN) AS VALOR , GV1_VLMINN , GV1_PCNORM"
    cQuery += " FROM "+RetSQLName("SA4") + " AS SA4 " //WITH (NOLOCK)
    cQuery += " INNER JOIN "+RetSQLName("GU3") + " AS GU3 ON GU3_IDFED = A4_CGC AND GU3.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
    cQuery += " INNER JOIN "+RetSQLName("GV8") + " AS GV8 ON GU3_CDEMIT = GV8_CDEMIT  AND GV8.D_E_L_E_T_ = ' ' AND GV8_TPDEST = '4' " //WITH (NOLOCK)
    cQuery += " INNER JOIN "+RetSQLName("GV1") + " AS GV1 ON GV1_CDEMIT = GV8_CDEMIT AND GV8_NRTAB = GV1_NRTAB AND GV8_NRNEG = GV1_NRNEG AND GV8_NRROTA = GV1_NRROTA  AND GV1.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
    cQuery += " INNER JOIN "+RetSQLName("GV7") + " AS GV7 ON GV7_CDEMIT = GV8_CDEMIT AND GV8_NRTAB = GV7_NRTAB AND GV8_NRNEG = GV7_NRNEG AND GV7.D_E_L_E_T_ = ' '  AND GV1_CDFXTV = GV7_CDFXTV " //WITH (NOLOCK)
    cQuery += " WHERE A4_FILIAL  = '" + xFilial("SA4") + "' "
    cQuery += " AND SA4.D_E_L_E_T_= ' ' "
    cQuery += " AND SA4.A4_COD = '"+ M->CJ_XTRANSP +"' "
    cQuery += " AND (GV8_NRCIOR =  '" + cEstOri + cCidOri + "' OR GV8_TPORIG = '0')"
    cQuery += " AND GV8_CDUFDS =  '" + cEst + "' "
    cQuery += " AND GV7_QTFXFI >=  '" + Str(nVolume) + "' "
    cQuery += " GROUP BY GV7_QTFXFI , GV1_VLMINN , GV1_PCNORM  "
    cQuery += " ORDER BY GV7_QTFXFI  "

    TcQuery cQuery new Alias ( cAliasQry )

    (cAliasQry)->(dbGoTop())

    If !(cAliasQry)->(EOF())
        cFaixa := Str((cAliasQry)->GV7_QTFXFI)
    EndIf
    (cAliasQry)->(DBCloseArea())
EndIf

If Empty(cFaixa)
    cQuery := " SELECT TOP 1 GV7_QTFXFI, SUM(GV1_VLFIXN) AS VALOR , GV1_VLMINN , GV1_PCNORM"
    cQuery += " FROM "+RetSQLName("SA4") + " AS SA4 " //WITH (NOLOCK)
    cQuery += " INNER JOIN "+RetSQLName("GU3") + " AS GU3 ON GU3_IDFED = A4_CGC AND GU3.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
    cQuery += " INNER JOIN "+RetSQLName("GV8") + " AS GV8 ON GU3_CDEMIT = GV8_CDEMIT  AND GV8.D_E_L_E_T_ = ' ' AND GV8_TPDEST = '0' " //WITH (NOLOCK)
    cQuery += " INNER JOIN "+RetSQLName("GV1") + " AS GV1 ON GV1_CDEMIT = GV8_CDEMIT AND GV8_NRTAB = GV1_NRTAB AND GV8_NRNEG = GV1_NRNEG AND GV8_NRROTA = GV1_NRROTA  AND GV1.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
    cQuery += " INNER JOIN "+RetSQLName("GV7") + " AS GV7 ON GV7_CDEMIT = GV8_CDEMIT AND GV8_NRTAB = GV7_NRTAB AND GV8_NRNEG = GV7_NRNEG AND GV7.D_E_L_E_T_ = ' '  AND GV1_CDFXTV = GV7_CDFXTV " //WITH (NOLOCK)
    cQuery += " WHERE A4_FILIAL  = '" + xFilial("SA4") + "' "
    cQuery += " AND SA4.D_E_L_E_T_= ' ' "
    cQuery += " AND SA4.A4_COD = '"+ M->CJ_XTRANSP +"' "
    cQuery += " AND (GV8_NRCIOR =  '" + cEstOri + cCidOri + "' OR GV8_TPORIG = '0')"
    cQuery += " AND GV7_QTFXFI >=  '" + Str(nVolume) + "' "
    cQuery += " AND GV1_CDCOMP =  'FRETE PESO' "
    cQuery += " GROUP BY GV7_QTFXFI , GV1_VLMINN , GV1_PCNORM  "
    cQuery += " ORDER BY GV7_QTFXFI  "

    TcQuery cQuery new Alias ( cAliasQry )

    (cAliasQry)->(dbGoTop())

    If !(cAliasQry)->(EOF())
        cFaixa := Str((cAliasQry)->GV7_QTFXFI)
    EndIf
    
    (cAliasQry)->(DBCloseArea())

EndIf
Return cFaixa

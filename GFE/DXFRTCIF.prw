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
Local aEst      := {}
Local cCodEst   := ''
Local nPos      := 0 
Local cGVACtr   := Iif(U_DxVldCtr(), " AND GVA_XCONTR = '1' ", " AND GVA_XCONTR <> '1' ") + " AND GVA_NRTAB = '" + M->CJ_XTBGFE + "' "
Local cTransp   := M->CJ_XTRANSP
Local cTabela   := M->CJ_XTBGFE

aEst := {;
    {'12','AC'},;
    {'27','AL'},;	
    {'13','AM'},;	
    {'16','AP'},;	
    {'29','BA'},;	
    {'23','CE'},;	
    {'53','DF'},;	
    {'32','ES'},;	
    {'52','GO'},;	
    {'21','MA'},;	
    {'31','MG'},;	
    {'50','MS'},;	
    {'51','MT'},;	
    {'15','PA'},;	
    {'25','PB'},;	
    {'26','PE'},;	
    {'22','PI'},;	
    {'41','PR'},;	
    {'33','RJ'},;	
    {'24','RN'},;	
    {'11','RO'},;	
    {'14','RR'},;	
    {'43','RS'},;	
    {'42','SC'},;	
    {'28','SE'},;	
    {'35','SP'},;	
    {'17','TO'};
    }

SA1->(DbSetOrder(1))
SA1->(DBSeek(xFilial('SA1') + M->(CJ_CLIENTE + CJ_LOJA)))

cCidade := SA1->A1_COD_MUN
cEst    := SA1->A1_EST
nPos    := aScan(aEst,{|x| AllTrim(x[2])==cEst})
cCodEst := aEst[nPos][1]

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

SB1->(DbSetOrder(1))
While !Eof()
    If !("TMP1")->CK_FLAG  
        If SB1->(DbSeek(xFilial('SB1') + TMP1->CK_PRODUTO))
            nVolume += 	TMP1->CK_QTDVEN * SB1->B1_PESBRU 
        EndIf
    EndIf
    TMP1->(DbSkip())
EndDo

SA4->(DbSetOrder(1))
If SA4->(DbSeek(xFilial('SA4') + cTransp))
    GU3->(DbSetOrder(11))
    If GU3->(DbSeek(xFilial('GU3') + SA4->A4_CGC))
        GVA->(DbSetOrder(1))
        If GVA->(DBSeek(xFilial('GVA') + GU3->GU3_CDEMIT + cTabela)) 
            If GVA->GVA_XCARCS == 'S'
                nRet := ClcCarCs()
                nVolume := 0
            EndIf
        EndIf
    EndIf
EndIf


If nVolume > 0

    cFaixa := RetFaixa(nVolume,cEst,cCidade,cEstOri , cCidOri, cCodEst)

    cQuery := " SELECT GV1_CDCOMP, GV7_QTFXFI, SUM(GV1_VLFIXN) AS VALOR , GV1_VLMINN , GV1_PCNORM , GV1_VLUNIN , GV1_VLFRAC,GV1_VLLIM , GV1_VLUNIE"
    cQuery += " FROM "+RetSQLName("SA4") + " AS SA4 " //WITH (NOLOCK)
    cQuery += " INNER JOIN "+RetSQLName("GU3") + " AS GU3 ON GU3_IDFED = A4_CGC AND GU3.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
    cQuery += " INNER JOIN "+RetSQLName("GV8") + " AS GV8 ON GU3_CDEMIT = GV8_CDEMIT  AND GV8.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
    cQuery += " INNER JOIN "+RetSQLName("GU7") + " AS GU7 ON GU7_NRCID = GV8_NRCIDS  AND GU7.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
    cQuery += " INNER JOIN "+RetSQLName("GV1") + " AS GV1 ON GV1_CDEMIT = GV8_CDEMIT AND GV8_NRTAB = GV1_NRTAB AND GV8_NRNEG = GV1_NRNEG AND GV8_NRROTA = GV1_NRROTA  AND GV1.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
    cQuery += " INNER JOIN "+RetSQLName("GV7") + " AS GV7 ON GV7_CDEMIT = GV8_CDEMIT AND GV8_NRTAB = GV7_NRTAB AND GV8_NRNEG = GV7_NRNEG AND GV7.D_E_L_E_T_ = ' ' AND GV1_CDFXTV = GV7_CDFXTV " //WITH (NOLOCK)
    cQuery += " INNER JOIN "+RetSQLName("GVA") + " AS GVA ON GU3_CDEMIT = GVA_CDEMIT AND GVA.D_E_L_E_T_ = ' ' " + cGVACtr //WITH (NOLOCK)
    cQuery += " INNER JOIN "+RetSQLName("GV9") + " AS GV9 ON GU3_CDEMIT = GV9_CDEMIT  AND GVA_NRTAB = GV9_NRTAB AND GV8_NRNEG = GV9_NRNEG AND GV9.D_E_L_E_T_ = ' ' AND GV9_SIT = '2' " //WITH (NOLOCK)
    cQuery += " WHERE A4_FILIAL  = '" + xFilial("SA4") + "' "
    cQuery += " AND SA4.D_E_L_E_T_= ' ' "
    cQuery += " AND SA4.A4_COD = '"+ M->CJ_XTRANSP +"' "
    cQuery += " AND GU7_CDUF =  '" + cEst + "' "
    cQuery += " AND SUBSTRING(GU7_NRCID,3,5) =  '" + cCidade + "' "
    cQuery += " AND GV7_QTFXFI =  '" + cFaixa + "' "
    cQuery += " AND GV1_NRTAB = '" + M->CJ_XTBGFE + "' "
    cQuery += " GROUP BY GV1_CDCOMP , GV7_QTFXFI , GV1_VLMINN ,GV1_PCNORM , GV1_VLUNIN ,GV1_VLFRAC,GV1_VLLIM , GV1_VLUNIE"
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
            ElseIf Alltrim((cAliasQry)->GV1_CDCOMP) == 'PESO EXCEDENTE'
                nRet +=((nVolume - (cAliasQry)->GV1_VLLIM) / (cAliasQry)->GV1_VLFRAC) * (cAliasQry)->GV1_VLUNIE                                 
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

        cQuery := " SELECT GV1_CDCOMP, GV7_QTFXFI, SUM(GV1_VLFIXN) AS VALOR , GV1_VLMINN , GV1_PCNORM , GV1_VLUNIN , GV1_VLFRAC,GV1_VLLIM , GV1_VLUNIE"
        cQuery += " FROM "+RetSQLName("SA4") + " AS SA4 " //WITH (NOLOCK)
        cQuery += " INNER JOIN "+RetSQLName("GU3") + " AS GU3 ON GU3_IDFED = A4_CGC AND GU3.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
        cQuery += " INNER JOIN "+RetSQLName("GV8") + " AS GV8 ON GU3_CDEMIT = GV8_CDEMIT  AND GV8.D_E_L_E_T_ = ' ' AND GV8_TPDEST = '3' " //WITH (NOLOCK)
        cQuery += " INNER JOIN "+RetSQLName("GV1") + " AS GV1 ON GV1_CDEMIT = GV8_CDEMIT AND GV8_NRTAB = GV1_NRTAB AND GV8_NRNEG = GV1_NRNEG AND GV8_NRROTA = GV1_NRROTA  AND GV1.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
        cQuery += " INNER JOIN "+RetSQLName("GV7") + " AS GV7 ON GV7_CDEMIT = GV8_CDEMIT AND GV8_NRTAB = GV7_NRTAB AND GV8_NRNEG = GV7_NRNEG AND GV7.D_E_L_E_T_ = ' '  AND GV1_CDFXTV = GV7_CDFXTV " //WITH (NOLOCK)
        cQuery += " INNER JOIN "+RetSQLName("GUA") + " AS GUA ON GV8_NRREDS = GUA_NRREG AND GUA.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
        cQuery += " INNER JOIN "+RetSQLName("GVA") + " AS GVA ON GU3_CDEMIT = GVA_CDEMIT AND GVA.D_E_L_E_T_ = ' ' " + cGVACtr //WITH (NOLOCK)
        cQuery += " INNER JOIN "+RetSQLName("GV9") + " AS GV9 ON GU3_CDEMIT = GV9_CDEMIT  AND GVA_NRTAB = GV9_NRTAB AND GV8_NRNEG = GV9_NRNEG AND GV9.D_E_L_E_T_ = ' ' AND GV9_SIT = '2' " //WITH (NOLOCK)
        cQuery += " WHERE A4_FILIAL  = '" + xFilial("SA4") + "' "
        cQuery += " AND SA4.D_E_L_E_T_= ' ' "
        cQuery += " AND SA4.A4_COD = '"+ M->CJ_XTRANSP +"' "
        cQuery += " AND (GV8_NRCIOR =  '" + cEstOri + cCidOri + "' OR GV8_TPORIG = '0')"
        cQuery += " AND GUA_NRCID =  '" + cCodEst + cCidade + "' "
        cQuery += " AND GV7_QTFXFI =  '" + cFaixa + "' "
        cQuery += " AND GV1_NRTAB = '" + M->CJ_XTBGFE + "' "
        cQuery += " GROUP BY GV1_CDCOMP , GV7_QTFXFI , GV1_VLMINN ,GV1_PCNORM , GV1_VLUNIN ,GV1_VLFRAC,GV1_VLLIM , GV1_VLUNIE"
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
                ElseIf Alltrim((cAliasQry)->GV1_CDCOMP) == 'PESO EXCEDENTE'
                    nRet +=((nVolume - (cAliasQry)->GV1_VLLIM) / (cAliasQry)->GV1_VLFRAC) * (cAliasQry)->GV1_VLUNIE                              
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

        cQuery := " SELECT GV1_CDCOMP, GV7_QTFXFI, SUM(GV1_VLFIXN) AS VALOR , GV1_VLMINN , GV1_PCNORM , GV1_VLUNIN , GV1_VLFRAC ,GV1_VLLIM , GV1_VLUNIE"
        cQuery += " FROM "+RetSQLName("SA4") + " AS SA4 " //WITH (NOLOCK)
        cQuery += " INNER JOIN "+RetSQLName("GU3") + " AS GU3 ON GU3_IDFED = A4_CGC AND GU3.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
        cQuery += " INNER JOIN "+RetSQLName("GV8") + " AS GV8 ON GU3_CDEMIT = GV8_CDEMIT  AND GV8.D_E_L_E_T_ = ' ' AND GV8_TPDEST = '4' " //WITH (NOLOCK)
        cQuery += " INNER JOIN "+RetSQLName("GV1") + " AS GV1 ON GV1_CDEMIT = GV8_CDEMIT AND GV8_NRTAB = GV1_NRTAB AND GV8_NRNEG = GV1_NRNEG AND GV8_NRROTA = GV1_NRROTA  AND GV1.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
        cQuery += " INNER JOIN "+RetSQLName("GV7") + " AS GV7 ON GV7_CDEMIT = GV8_CDEMIT AND GV8_NRTAB = GV7_NRTAB AND GV8_NRNEG = GV7_NRNEG AND GV7.D_E_L_E_T_ = ' '  AND GV1_CDFXTV = GV7_CDFXTV " //WITH (NOLOCK)
        cQuery += " INNER JOIN "+RetSQLName("GVA") + " AS GVA ON GU3_CDEMIT = GVA_CDEMIT AND GVA.D_E_L_E_T_ = ' ' " + cGVACtr //WITH (NOLOCK)
        cQuery += " INNER JOIN "+RetSQLName("GV9") + " AS GV9 ON GU3_CDEMIT = GV9_CDEMIT  AND GVA_NRTAB = GV9_NRTAB AND GV8_NRNEG = GV9_NRNEG AND GV9.D_E_L_E_T_ = ' ' AND GV9_SIT = '2' " //WITH (NOLOCK)
        cQuery += " WHERE A4_FILIAL  = '" + xFilial("SA4") + "' "
        cQuery += " AND SA4.D_E_L_E_T_= ' ' "
        cQuery += " AND SA4.A4_COD = '"+ M->CJ_XTRANSP +"' "
        cQuery += " AND (GV8_NRCIOR =  '" + cEstOri + cCidOri + "' OR GV8_TPORIG = '0')"
        cQuery += " AND GV8_CDUFDS =  '" + cEst + "' "
        cQuery += " AND GV7_QTFXFI =  '" + cFaixa + "' "
        cQuery += " AND GV1_NRTAB = '" + M->CJ_XTBGFE + "' "
        cQuery += " GROUP BY GV1_CDCOMP , GV7_QTFXFI , GV1_VLMINN ,GV1_PCNORM , GV1_VLUNIN ,GV1_VLFRAC ,GV1_VLLIM , GV1_VLUNIE"
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
                ElseIf Alltrim((cAliasQry)->GV1_CDCOMP) == 'PESO EXCEDENTE'
                    nRet +=((nVolume - (cAliasQry)->GV1_VLLIM) / (cAliasQry)->GV1_VLFRAC) * (cAliasQry)->GV1_VLUNIE                                       
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

        cQuery := " SELECT GV1_CDCOMP, GV7_QTFXFI, SUM(GV1_VLFIXN) AS VALOR , GV1_VLMINN , GV1_PCNORM , GV1_VLUNIN , GV1_VLFRAC, GV1_VLLIM , GV1_VLUNIE"
        cQuery += " FROM "+RetSQLName("SA4") + " AS SA4 " //WITH (NOLOCK)
        cQuery += " INNER JOIN "+RetSQLName("GU3") + " AS GU3 ON GU3_IDFED = A4_CGC AND GU3.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
        cQuery += " INNER JOIN "+RetSQLName("GV8") + " AS GV8 ON GU3_CDEMIT = GV8_CDEMIT  AND GV8.D_E_L_E_T_ = ' ' AND GV8_TPDEST = '0' " //WITH (NOLOCK)
        cQuery += " INNER JOIN "+RetSQLName("GV1") + " AS GV1 ON GV1_CDEMIT = GV8_CDEMIT AND GV8_NRTAB = GV1_NRTAB AND GV8_NRNEG = GV1_NRNEG AND GV8_NRROTA = GV1_NRROTA  AND GV1.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
        cQuery += " INNER JOIN "+RetSQLName("GV7") + " AS GV7 ON GV7_CDEMIT = GV8_CDEMIT AND GV8_NRTAB = GV7_NRTAB AND GV8_NRNEG = GV7_NRNEG AND GV7.D_E_L_E_T_ = ' '  AND GV1_CDFXTV = GV7_CDFXTV " //WITH (NOLOCK)
        cQuery += " INNER JOIN "+RetSQLName("GVA") + " AS GVA ON GU3_CDEMIT = GVA_CDEMIT AND GVA.D_E_L_E_T_ = ' ' " + cGVACtr //WITH (NOLOCK)
        cQuery += " INNER JOIN "+RetSQLName("GV9") + " AS GV9 ON GU3_CDEMIT = GV9_CDEMIT  AND GVA_NRTAB = GV9_NRTAB AND GV8_NRNEG = GV9_NRNEG AND GV9.D_E_L_E_T_ = ' ' AND GV9_SIT = '2' " //WITH (NOLOCK)
        cQuery += " WHERE A4_FILIAL  = '" + xFilial("SA4") + "' "
        cQuery += " AND SA4.D_E_L_E_T_= ' ' "
        cQuery += " AND SA4.A4_COD = '"+ M->CJ_XTRANSP +"' "
        cQuery += " AND (GV8_NRCIOR =  '" + cEstOri + cCidOri + "' OR GV8_TPORIG = '0')"
        cQuery += " AND GV7_QTFXFI =  '" + cFaixa + "' "
        cQuery += " AND GV1_NRTAB = '" + M->CJ_XTBGFE + "' "
        cQuery += " GROUP BY GV1_CDCOMP , GV7_QTFXFI , GV1_VLMINN ,GV1_PCNORM , GV1_VLUNIN ,GV1_VLFRAC,GV1_VLLIM , GV1_VLUNIE"
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
                ElseIf Alltrim((cAliasQry)->GV1_CDCOMP) == 'PESO EXCEDENTE'
                    nRet +=((nVolume - (cAliasQry)->GV1_VLLIM) / (cAliasQry)->GV1_VLFRAC) * (cAliasQry)->GV1_VLUNIE                                      
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
Static Function RetFaixa(nVolume,cEst,cCidade,cEstOri , cCidOri,cCodEst)
Local cFaixa := ''
Local cQuery := ''
Local cAliasQry := GetNextAlias()
Local cGVACtr   := Iif(U_DxVldCtr(), " AND GVA_XCONTR = '1' ", " AND GVA_XCONTR <> '1' ") 
Local cWhere    := Iif(!empty(M->CJ_XTBGFE),"AND GV7_NRTAB = '" + M->CJ_XTBGFE + "' ","")


cQuery := " SELECT TOP 1 GV7_QTFXFI, SUM(GV1_VLFIXN) AS VALOR , GV1_VLMINN , GV1_PCNORM"
cQuery += " FROM "+RetSQLName("SA4") + " AS SA4 " //WITH (NOLOCK)
cQuery += " INNER JOIN "+RetSQLName("GU3") + " AS GU3 ON GU3_IDFED = A4_CGC AND GU3.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
cQuery += " INNER JOIN "+RetSQLName("GV8") + " AS GV8 ON GU3_CDEMIT = GV8_CDEMIT  AND GV8.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
cQuery += " INNER JOIN "+RetSQLName("GU7") + " AS GU7 ON GU7_NRCID = GV8_NRCIDS  AND GU7.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
cQuery += " INNER JOIN "+RetSQLName("GV1") + " AS GV1 ON GV1_CDEMIT = GV8_CDEMIT AND GV8_NRTAB = GV1_NRTAB AND GV8_NRNEG = GV1_NRNEG AND GV8_NRROTA = GV1_NRROTA  AND GV1.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
cQuery += " INNER JOIN "+RetSQLName("GVA") + " AS GVA ON GU3_CDEMIT = GVA_CDEMIT AND GVA.D_E_L_E_T_ = ' ' " + cGVACtr //WITH (NOLOCK)
cQuery += " INNER JOIN "+RetSQLName("GV7") + " AS GV7 ON GV7_CDEMIT = GV8_CDEMIT AND GV8_NRTAB = GV7_NRTAB AND GV8_NRNEG = GV7_NRNEG AND GV7.D_E_L_E_T_ = ' ' AND GV1_CDFXTV = GV7_CDFXTV " //WITH (NOLOCK)
cQuery += " INNER JOIN "+RetSQLName("GV9") + " AS GV9 ON GU3_CDEMIT = GV9_CDEMIT  AND GVA_NRTAB = GV9_NRTAB AND GV8_NRNEG = GV9_NRNEG AND GV9.D_E_L_E_T_ = ' ' AND GV9_SIT = '2' " //WITH (NOLOCK)
cQuery += " WHERE A4_FILIAL  = '" + xFilial("SA4") + "' "
cQuery += " AND SA4.D_E_L_E_T_= ' ' "
cQuery += " AND SA4.A4_COD = '"+ M->CJ_XTRANSP +"' "
cQuery += " AND GU7_CDUF =  '" + cEst + "' "
cQuery += " AND SUBSTRING(GU7_NRCID,3,5) =  '" + cCidade + "' "
cQuery += " AND GV7_QTFXFI >=  '" + Str(nVolume) + "' "
cQuery += " AND GV1_NRTAB = '" + M->CJ_XTBGFE + "' "
cQuery += cWhere
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
    cQuery += " INNER JOIN "+RetSQLName("GVA") + " AS GVA ON GU3_CDEMIT = GVA_CDEMIT AND GVA.D_E_L_E_T_ = ' ' " + cGVACtr //WITH (NOLOCK)
    cQuery += " INNER JOIN "+RetSQLName("GUA") + " AS GUA ON GV8_NRREDS = GUA_NRREG AND GUA.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
    cQuery += " INNER JOIN "+RetSQLName("GV9") + " AS GV9 ON GU3_CDEMIT = GV9_CDEMIT  AND GVA_NRTAB = GV9_NRTAB AND GV8_NRNEG = GV9_NRNEG AND GV9.D_E_L_E_T_ = ' ' AND GV9_SIT = '2' " //WITH (NOLOCK)
    cQuery += " WHERE A4_FILIAL  = '" + xFilial("SA4") + "' "
    cQuery += " AND SA4.D_E_L_E_T_= ' ' "
    cQuery += " AND SA4.A4_COD = '"+ M->CJ_XTRANSP +"' "
    cQuery += " AND (GV8_NRCIOR =  '" + cEstOri + cCidOri + "' OR GV8_TPORIG = '0')"
    cQuery += " AND GUA_NRCID =  '" + cCodEst + cCidade + "' "
    cQuery += " AND GV7_QTFXFI >=  '" + Str(nVolume) + "' "
    cQuery += " AND GV1_NRTAB = '" + M->CJ_XTBGFE + "' "
    cQuery += cWhere
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
    cQuery += " INNER JOIN "+RetSQLName("GVA") + " AS GVA ON GU3_CDEMIT = GVA_CDEMIT AND GVA.D_E_L_E_T_ = ' ' " + cGVACtr //WITH (NOLOCK)
    cQuery += " INNER JOIN "+RetSQLName("GV7") + " AS GV7 ON GV7_CDEMIT = GV8_CDEMIT AND GV8_NRTAB = GV7_NRTAB AND GV8_NRNEG = GV7_NRNEG AND GV7.D_E_L_E_T_ = ' '  AND GV1_CDFXTV = GV7_CDFXTV " //WITH (NOLOCK)
    cQuery += " INNER JOIN "+RetSQLName("GV9") + " AS GV9 ON GU3_CDEMIT = GV9_CDEMIT  AND GVA_NRTAB = GV9_NRTAB AND GV8_NRNEG = GV9_NRNEG AND GV9.D_E_L_E_T_ = ' ' AND GV9_SIT = '2' " //WITH (NOLOCK)
    cQuery += " WHERE A4_FILIAL  = '" + xFilial("SA4") + "' "
    cQuery += " AND SA4.D_E_L_E_T_= ' ' "
    cQuery += " AND SA4.A4_COD = '"+ M->CJ_XTRANSP +"' "
    cQuery += " AND (GV8_NRCIOR =  '" + cEstOri + cCidOri + "' OR GV8_TPORIG = '0')"
    cQuery += " AND GV8_CDUFDS =  '" + cEst + "' "
    cQuery += " AND GV7_QTFXFI >=  '" + Str(nVolume) + "' "
    cQuery += " AND GV1_NRTAB = '" + M->CJ_XTBGFE + "' "
    cQuery += cWhere
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
    cQuery += " INNER JOIN "+RetSQLName("GVA") + " AS GVA ON GU3_CDEMIT = GVA_CDEMIT AND GVA.D_E_L_E_T_ = ' ' " + cGVACtr //WITH (NOLOCK)
    cQuery += " INNER JOIN "+RetSQLName("GV7") + " AS GV7 ON GV7_CDEMIT = GV8_CDEMIT AND GV8_NRTAB = GV7_NRTAB AND GV8_NRNEG = GV7_NRNEG AND GV7.D_E_L_E_T_ = ' '  AND GV1_CDFXTV = GV7_CDFXTV " //WITH (NOLOCK)
    cQuery += " INNER JOIN "+RetSQLName("GV9") + " AS GV9 ON GU3_CDEMIT = GV9_CDEMIT  AND GVA_NRTAB = GV9_NRTAB AND GV8_NRNEG = GV9_NRNEG AND GV9.D_E_L_E_T_ = ' ' AND GV9_SIT = '2' " //WITH (NOLOCK)
    cQuery += " WHERE A4_FILIAL  = '" + xFilial("SA4") + "' "
    cQuery += " AND SA4.D_E_L_E_T_= ' ' "
    cQuery += " AND SA4.A4_COD = '"+ M->CJ_XTRANSP +"' "
    cQuery += " AND (GV8_NRCIOR =  '" + cEstOri + cCidOri + "' OR GV8_TPORIG = '0')"
    cQuery += " AND GV7_QTFXFI >=  '" + Str(nVolume) + "' "
    cQuery += " AND GV1_CDCOMP =  'FRETE PESO' "
    cQuery += " AND GV1_NRTAB = '" + M->CJ_XTBGFE + "' "
    cQuery += cWhere
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
    cQuery += " INNER JOIN "+RetSQLName("GV8") + " AS GV8 ON GU3_CDEMIT = GV8_CDEMIT  AND GV8.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
    cQuery += " INNER JOIN "+RetSQLName("GU7") + " AS GU7 ON GU7_NRCID = GV8_NRCIDS  AND GU7.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
    cQuery += " INNER JOIN "+RetSQLName("GV1") + " AS GV1 ON GV1_CDEMIT = GV8_CDEMIT AND GV8_NRTAB = GV1_NRTAB AND GV8_NRNEG = GV1_NRNEG AND GV8_NRROTA = GV1_NRROTA  AND GV1.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
    cQuery += " INNER JOIN "+RetSQLName("GVA") + " AS GVA ON GU3_CDEMIT = GVA_CDEMIT AND GVA.D_E_L_E_T_ = ' ' " + cGVACtr //WITH (NOLOCK)
    cQuery += " INNER JOIN "+RetSQLName("GV7") + " AS GV7 ON GV7_CDEMIT = GV8_CDEMIT AND GV8_NRTAB = GV7_NRTAB AND GV8_NRNEG = GV7_NRNEG AND GV7.D_E_L_E_T_ = ' ' AND GV1_CDFXTV = GV7_CDFXTV " //WITH (NOLOCK)
    cQuery += " INNER JOIN "+RetSQLName("GV9") + " AS GV9 ON GU3_CDEMIT = GV9_CDEMIT  AND GVA_NRTAB = GV9_NRTAB AND GV8_NRNEG = GV9_NRNEG AND GV9.D_E_L_E_T_ = ' ' AND GV9_SIT = '2' " //WITH (NOLOCK)
    cQuery += " WHERE A4_FILIAL  = '" + xFilial("SA4") + "' "
    cQuery += " AND SA4.D_E_L_E_T_= ' ' "
    cQuery += " AND SA4.A4_COD = '"+ M->CJ_XTRANSP +"' "
    cQuery += " AND GU7_CDUF =  '" + cEst + "' "
    cQuery += " AND SUBSTRING(GU7_NRCID,3,5) =  '" + cCidade + "' "
    cQuery += " AND GV1_CDCOMP =  'FRETE COMBINADO' "
    cQuery += " AND GV1_NRTAB = '" + M->CJ_XTBGFE + "' "
    cQuery += cWhere
    cQuery += " GROUP BY GV7_QTFXFI , GV1_VLMINN ,GV1_PCNORM  "
    cQuery += " ORDER BY GV7_QTFXFI  "

    TcQuery cQuery new Alias ( cAliasQry )

    (cAliasQry)->(dbGoTop())

    If !(cAliasQry)->(EOF())
        cFaixa := Str((cAliasQry)->GV7_QTFXFI)
    EndIf
    (cAliasQry)->(DBCloseArea())   
EndIf


Return cFaixa


//Valida se existe itens controlado no orçamento
User Function DxVldCtr()
Local lRet := .F.
Local aArea := GetArea()
Local nPos  := ("TMP1")->(Recno())

dbSelectArea("TMP1")
dbGoTop()

SB5->(DbSetOrder(1))
While !Eof()
    If !("TMP1")->CK_FLAG 
        
        If SB5->(DbSeek(xFilial('SB5') + ("TMP1")->CK_PRODUTO))
            If SB5->B5_XCONTRO == 'S'
                lRet := .T.
                Exit
            EndIf
        EndIf
    EndIf
    TMP1->(DbSkip())
EndDo


("TMP1")->(DbGoTo(nPos))

Return lRet


Static Function ClcCarCs()
Local nFrete 	:= 0
Local nVlKg     := 0
Local aArea     := GetArea()
local nLinha	:= TMP1->(Recno())
Local nRet		:= 0
Local nTotItens	:= 0
Local nTotPeso	:= 0

SZ5->(DbSetOrder(1))
If SZ5->(DbSeek(xFilial('SZ5') + cFilAnt + M->CJ_XTRANSP))
	nFrete	:= SZ5->Z5_FRETE
    nVlKg := SZ5->Z5_VALOR
EndIf

dbSelectArea("TMP1")
dbGoTop()
While !Eof()
	IF TMP1->CK_UM == 'KG' .And. !("TMP1")->CK_FLAG .And. !Val(TMP1->CK_XMOTIVO) > 1
		nTotItens ++
		nTotPeso	+= TMP1->CK_QTDVEN
	EndIf
	TMP1->(DbSkip())
End

dbSelectArea("TMP1")
dbGoTop()
While !Eof()
    If  !("TMP1")->CK_FLAG .And. !Val(TMP1->CK_XMOTIVO) > 1
        SB1->(dbSetOrder(1))
        If SB1->(DbSeek(xFilial('SB1') + ("TMP1")->CK_PRODUTO )) .And. SB1->B1_PESBRU > 0
            nFrete += (("TMP1")->CK_QTDVEN * SB1->B1_PESBRU) * nVlKg 

			TMP1->CK_XVLFRET :=  ((("TMP1")->CK_QTDVEN * SB1->B1_PESBRU) * nVlKg) + (SZ5->Z5_FRETE / nTotItens)

			//U_ClcComis()
        EndIf
    EndIf
    ("TMP1")->(DbSkip())
EndDo

TMP1->(DbGoTo(nLinha))

GETDREFRESH()	   
oGetDad:Refresh()

RestArea(aArea) 
Return nFrete

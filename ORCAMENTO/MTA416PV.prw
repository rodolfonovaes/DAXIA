#Include "Protheus.CH"
#Include "RWMake.CH"
/*======================================================================================+
| Programa............:   MTA416PV.prw                                                  |
| Autores ............:   johnny.osugi@totvspartners.com.br                             |
|                         rodolfo.novaes@totvs.com.br                                   |
| Data................:   06/08/2019                                                    |
| Descricao / Objetivo:   Ponto de entrada que realiza o tratamento do cadastro de Or-  |
|                         camentos (SCJ/SCK) para que seja gravado no SC6 somente os    |
|                         itens como FECHADO (tratamento atraves do campo CK_XMOTIVO).  |
|                         Ainda neste ponto de entrada, realiza o tratamento do cabe-   |
|                         calho do PV para que leve o Tipo de Frete.                    |
| Doc. Origem.........:   MIT044 - Motivos de Perda do Orcamento e outro documento.     |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
Static _aDxCk   := {}
User Function MTA416PV()
Local nAux := PARAMIXB
Local nPPrcVen  := ascan(_aHeader,{|x|upper(alltrim(x[2]))=="C6_PRCVEN"})
Local nPProd    := ascan(_aHeader,{|x|upper(alltrim(x[2]))=="C6_PRODUTO"})
Local nPComis   := ascan(_aHeader,{|x|upper(alltrim(x[2]))=="C6_COMIS1"})
Local nPOper    := ascan(_aHeader,{|x|upper(alltrim(x[2]))=="C6_OPER"})
Local nPItem    := ascan(_aHeader,{|x|upper(alltrim(x[2]))=="C6_ITEM"})
Local nPMarg    := ascan(_aHeader,{|x|upper(alltrim(x[2]))=="C6_XMGBRUT"})
Local nPFret    := ascan(_aHeader,{|x|upper(alltrim(x[2]))=="C6_XVLFRET"})
Local nPPalet   := ascan(_aHeader,{|x|upper(alltrim(x[2]))=="C6_XPALET"})
Local nPIpi     := ascan(_aHeader,{|x|upper(alltrim(x[2]))=="C6_XVLIPI"})
Local nPIcm     := ascan(_aHeader,{|x|upper(alltrim(x[2]))=="C6_XICM"})
Local nPIcmP    := ascan(_aHeader,{|x|upper(alltrim(x[2]))=="C6_XICMP"})
Local nPPis     := ascan(_aHeader,{|x|upper(alltrim(x[2]))=="C6_XPIS"})
Local nPCof     := ascan(_aHeader,{|x|upper(alltrim(x[2]))=="C6_XCOF"})
Local nPCustd   := ascan(_aHeader,{|x|upper(alltrim(x[2]))=="C6_XCUSTD"})
Local nPMoeda   := ascan(_aHeader,{|x|upper(alltrim(x[2]))=="C6_XMOEDA"})
Local nPDsr     := ascan(_aHeader,{|x|upper(alltrim(x[2]))=="C6_XDSR"})
Local nPResult  := ascan(_aHeader,{|x|upper(alltrim(x[2]))=="C6_XRESULT"})
Local nPValor   := ascan(_aHeader,{|x|upper(alltrim(x[2]))=="C6_VALOR"})
Local nPDescont  := ascan(_aHeader,{|x|upper(alltrim(x[2]))=="C6_DESCONT"})
Local nPValDesc   := ascan(_aHeader,{|x|upper(alltrim(x[2]))=="C6_VALDESC"})
Local nFixa     := ascan(_aHeader,{|x|upper(alltrim(x[2]))=="C6_XFIXA"})
Local nTaxa     := ascan(_aHeader,{|x|upper(alltrim(x[2]))=="C6_XTAXA"})
Local nXCatite  := ascan(_aHeader,{|x|upper(alltrim(x[2]))=="C6_XCATITE"})
Local nPServic  := ascan(_aHeader,{|x|upper(alltrim(x[2]))=="C6_SERVIC"})
Local nPEndPad  := ascan(_aHeader,{|x|upper(alltrim(x[2]))=="C6_ENDPAD"})
Local nPRegWms  := ascan(_aHeader,{|x|upper(alltrim(x[2]))=="C6_REGWMS"})
Local nPerDsr   := 0
Local nPrcVen   := 0
Local cProd     := ''
Local n         := 0
Local aArea     := GetArea()
Local cQry  	:= ""
Local cAliasQry	:= GetNextAlias()
Local lContinua := .F.
Local cMsg		:= GetMV("ES_MSGMOV")

M->C5_TRANSP    := SCJ->CJ_XTRANSP
M->C5_XTREDES   := SCJ->CJ_XTREDES
M->C5_REDESP    := SCJ->CJ_XTREDES
M->C5_XNMREDE   := SCJ->CJ_XNMTRED
M->C5_CONDPAG   := SCJ->CJ_CONDPAG
M->C5_TABELA    := SCJ->CJ_TABELA
M->C5_VEND1     := SCJ->CJ_XVEND
M->C5_XNVEND    := SCJ->CJ_XNOMEV
M->C5_XNOME		:= SCJ->CJ_XNOME
M->C5_LOJACLI   := SCJ->CJ_LOJA
M->C5_NATUREZ	:= POSICIONE("SA1",1,XFILIAL("SA1") + SCJ->CJ_CLIENTE + SCJ->CJ_LOJA,"A1_NATUREZ")
M->C5_XUSER     := UsrRetName( retcodusr() )
M->C5_XDATE     := dDataBase
M->C5_XTIME     := Time()
M->C5_MENNOTA   := SCJ->CJ_XMENNOT
M->C5_XNUMCJ    := SCJ->CJ_NUM
M->C5_ZZOBSLA   := SCJ->CJ_ZZOBSLA
M->C5_ZZEXCEC   := SCJ->CJ_ZZEXCEC
M->C5_ZZSELO    := SCJ->CJ_ZZSELO
M->C5_ZZOBSLO   := SCJ->CJ_ZZOBSLO
M->C5_ZZPALLE   := SCJ->CJ_ZZPALLE
M->C5_ZZOBSPA   := SCJ->CJ_ZZOBSPA
M->C5_ZZOUTRO   := SCJ->CJ_ZZOUTRO
M->C5_ZZOUTXT   := SCJ->CJ_ZZOUTXT
M->C5_ZZNEGOC   := SCJ->CJ_ZZNEGOC  
M->C5_ZZLAUDO   := SCJ->CJ_ZZLAUDO
M->C5_XOBSPED   := SCJ->CJ_XOBSPED
M->C5_XOBSPED   := MSMM("CJ_XOBSPED",,,SCJ->CJ_XOBSPED,3,,,"SCJ","CJ_XOBSPED")
M->C5_XCNPJ     := POSICIONE('SA1',1,xFilial('SA1') + SCJ->(CJ_CLIENTE + CJ_LOJA),'A1_CGC')
M->C5_COMIS1    := 0
M->C5_XTPOPER   := SCJ->CJ_XTPOPER
M->C5_XNMTRAN   := SCJ->CJ_XNMTRAN

M->C5_XVLFRET     := SCJ->CJ_XVLFRET

If Alltrim(SCJ->CJ_TPCARGA) == "1"
    M->C5_GERAWMS := "2"
EndIf

If M->C5_PESOL == 0
    LoadPeso() //Carrego os pesos e volumes]
EndIf

do case 
    Case SCJ->CJ_XTPFRET == '1'
        M->C5_TPFRETE  := 'C'
    Case SCJ->CJ_XTPFRET == '2'
        M->C5_TPFRETE  := 'C'
    Case SCJ->CJ_XTPFRET == '3'
        M->C5_TPFRETE  := 'F'
    Case SCJ->CJ_XTPFRET == '4'
        M->C5_TPFRETE  := 'F'
    Case SCJ->CJ_XTPFRET == '5'
        M->C5_TPFRETE  := 'S'
EndCase                                

If SC5->(FieldPos('C5_XVLTOT')) > 0
	M->C5_XVLTOT := SCJ->CJ_XVLTOT
EndIf

If nPOper > 0
    _aCols[nAux][nPOper] := SCJ->CJ_XTPOPER
EndIf   

cQry			:= ""
cQry			:= " SELECT R_E_C_N_O_ AS REC,CK_XMOTIVO FROM " + RetSqlName("SCK") + " SCK "
cQry			+= " WHERE "
cQry			+= "       SCK.CK_FILIAL   = '" + xFilial("SCK") + "' "
cQry			+= "   AND SCK.CK_PRODUTO    = '"+ PADR(_aCols[nAux][nPProd],TAMSX3('CK_PRODUTO')[1]) + "' "
cQry			+= "   AND SCK.CK_NUM    = '"+ PADR(SCJ->CJ_NUM,TAMSX3('CK_NUM')[1]) + "' "
cQry			+= "   AND SCK.D_E_L_E_T_ = ' ' "
cQry			:= ChangeQuery( cQry )

DbUseArea(.T., "TopConn", TCGenQry(, , cQry ), cAliasQry, .F., .F. )
DbSelectArea( cAliasQry )
( cAliasQry )->( DbGoTop() )
If ( cAliasQry )->( !Eof() ) 
    If ascan(_aDxCk,( cAliasQry )->REC) > 0
        While ( cAliasQry )->( !Eof() ) 
            If ascan(_aDxCk,( cAliasQry )->REC) == 0
                lContinua := .T.
                Exit
            EndIf
            ( cAliasQry )->(DbSkip()) 
        EndDo
    Else
        lContinua := .T.
    EndIf 
    
    If lContinua
        SCK->(DbGoTo(( cAliasQry )->REC))
        aadd(_aDxCk,SCK->(Recno()))

        If POSICIONE('SBZ',1,xFilial('SBZ') + SCK->CK_PRODUTO , 'BZ_CTRWMS') == '1' .And. ;
        POSICIONE('SF4',1,xFilial('SF4') + SCK->CK_TES , 'F4_ESTOQUE') == 'S'
            _aCols[nAux][nPServic] := '026'
        EndIf
        
        If nPMarg > 0
            _aCols[nAux][nPMarg]    := SCK->CK_XMGBRUT
        EndIf
        If nPFret > 0
            _aCols[nAux][nPFret]    := SCK->CK_XVLFRET
        EndIf
        If nPPalet > 0
            _aCols[nAux][nPPalet]   := SCK->CK_XPALET
        EndIf
        If nPIpi
            _aCols[nAux][nPIpi]     := SCK->CK_XVLIPI
        EndIf
        If nPIcm
            _aCols[nAux][nPIcm]     := SCK->CK_XVLICM
        EndIf
        If nPIcmP
            _aCols[nAux][nPIcmP]    := SCK->CK_XVLICMP
        EndIf
        If nPPis > 0
            _aCols[nAux][nPPis]     := SCK->CK_XVLPIS
        EndIf
        If nPCof > 0
            _aCols[nAux][nPCof]     := SCK->CK_XVLCOF
        EndIf

    //  _aCols[nAux][nPMoeda]   := SCK->CK_MOEDA
    // _aCols[nAux][nPCustd]   := POSICIONE('DA1',1,xFilial('DA1') + SUPERGETMV('ES_DAXTAB',.T.,'001',cFilAnt)  + SCK->CK_PRODUTO , 'DA1_XCUSTD' )
        If nPValor > 0
            _aCols[nAux][nPValor]   := A410Arred(SCK->CK_PRCVEN*SCK->CK_QTDVEN,"C6_VALOR",If(cPaisLoc $ "CHI|PAR" .And. lPrcdec,M->C5_MOEDA,NIL)) //TRATAMENTO PARA CONTORNAR MSG DE ERRO NA EFETIVAÇÂO DO ORÇAMENTO
        EndIf
        If nPDescont > 0
            _aCols[nAux][nPDescont] := 0
        EndIf
        If nPValDesc > 0
            _aCols[nAux][nPValDesc] := 0
        EndIf
        If nFixa > 0
            _aCols[nAux][nFixa] := SCK->CK_XFIXA 
        EndIf
        If nTaxa > 0
            _aCols[nAux][nTaxa] := SCK->CK_XTAXA
        EndIf

        If nXCatite > 0
            _aCols[nAux][nXCatite] := SCK->CK_XCATITE
        EndIf
        
        If nPEndPad > 0
            _aCols[nAux][nPEndPad] := ' '
        EndIf
        
        If nPRegWms > 0 
            If Alltrim(_aCols[nAux][nPProd]) $ SuperGetMV('ES_PRDFIFO',.F.,'0207030001')
                _aCols[nAux][nPRegWms] := '4'
            Else
                _aCols[nAux][nPRegWms] := '3'
            EndIf
        EndIf

        DbSelectArea('SZD')
        SZD->(Dbsetorder(1))
        If SZD->(DbSeek(xFilial('SZD') + Alltrim(Str(year(dDatabase))) + PadL(Alltrim(STR(Month(dDataBase))),2,'0')))
            nPerDsr		:= SZD->ZD_PDSR / 100
            nPerDsr     := SCK->CK_COMIS1 * nPerDsr
            If nPDsr > 0
                _aCols[nAux][nPDsr] := SCK->CK_PRCVEN * (nPerDsr / 100)        
            EndIf
        EndIf
        //_aCols[nAux][nPResult] := SCK->CK_XMGBRUT - nPerDsr - SCK->CK_COMIS1
        //_aCols[nAux][nPMoeda] := SCK->CK_MOEDA

        /*-----------------------------------------------------------+
        | Realiza o tratamento dos itens do orcamento (SCK) para que |
        | somente leve os itens fechados para o Pedido de Vendas     |
        | Autor : johnny.osugi@totvspartners.com.br                  |
        | MIT ..: MIT044 - Motivos de Perda do Orcamento.            |
        +-----------------------------------------------------------*/
        If FindFunction( "U_DMNACOLS" )
            u_DMnaCols( nAux ) // Funcao de usuario no programa-fonte DX_PrdOr.prw
        EndIf   
    EndIf 
EndIf

( cAliasQry )->(DbCloseArea())

dbSelectArea("SA1")
dbSetOrder(1)
If dbSeek(xFilial("SA1") + SCJ->CJ_CLIENTE + SCJ->CJ_LOJA)
	If SA1->A1_XSITUA == "2"
		MsgAlert(cMsg,"Status")
	Endif            
	
	RecLock("SA1",.F.)
	SA1->A1_XSITUA := "1"
	msUnlock() 
Endif


RestArea( aArea )
Return( Nil )



/*/{Protheus.doc} LoadPeso
    Soma e grava peso bruto , liquido e volumes
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
Static Function LoadPeso()
Local nPesBrut  := 0
Local nPesLiq   := 0
Local nVolume   := 0
Local nQtd      := 0
Local nQtSeUm   := 0

DBselectarea('SCK')
SCK->(DBselectarea(1))
If SCK->(DbSeek(xFilial('SCK') + SCJ->CJ_NUM ))
    While SCK->(CK_FILIAL + CK_NUM == SCJ->(CJ_FILIAL + CJ_NUM))
        If  !Val(SCK->CK_XMOTIVO) > 1
            SB1->(dbSetOrder(1))
            If SB1->(DbSeek(xFilial('SB1') + SCK->CK_PRODUTO ))
                nPesBrut += (SCK->CK_QTDVEN * SB1->B1_PESBRU)
                nPesLiq += (SCK->CK_QTDVEN* SB1->B1_PESO)
                nQtd    += SCK->CK_QTDVEN

                If SB1->B1_TIPCONV == 'D'
                    nVolume     += IIF(SB1->B1_CONV > 0 ,SCK->CK_QTDVEN / SB1->B1_CONV , SCK->CK_QTDVEN)
                    nQtSeUm    += SCK->CK_QTDVEN / SB1->B1_CONV
                Else
                    nVolume     += IIF(SB1->B1_CONV > 0 ,SCK->CK_QTDVEN * SB1->B1_CONV , SCK->CK_QTDVEN)
                    nQtSeUm    += SCK->CK_QTDVEN * SB1->B1_CONV                
                EndIF
            EndIf    
        EndIf
        SCK->(DbSkip())
    EndDo
EndIf

M->C5_PESOL     := nPesLiq
M->C5_PBRUTO    := nPesBrut
M->C5_VOLUME1   := nVolume
M->C5_ESPECI1   := 'VOLUMES'
M->C5_XTQ1      := nQtd
M->C5_XTQ2      := nQtSeUm
Return

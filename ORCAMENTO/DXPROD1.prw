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
User Function DXPROD1()
Local aPergs :={}
Local aRet   :={}
Local nTipo     := 1
Aadd(aPergs,{2,"Tipo Processo"   	,nTipo,{'1=Saída da mercadoria SP destino PE', '2=Entrada da mercadoria em PE','3=Comércio Importador','4=Atualiza produtos'},150,'',.F.}) 		

If Parambox(aPergs,'Ajuste PRODEPE',aRet)
    nTipo := aRet[1]
    Do case
        Case nTipo == 1
            ProcA()
        Case nTipo == '2'
            ProcB()
        Case nTipo == '3'
            ProcC()
        Case nTipo == '4'
            PRODUTOS()            
    EndCase
EndIf

Return

Static Function ProcA()
Local cAliasQry	:= GetNextAlias()
Local cQry	:= ""
Local aCampos    := {}
Local bCampo     := {|x| FieldName(x)}

cQry			:= ""
cQry			:= " SELECT * FROM " + RetSqlName("SF4") + " SF4 "
cQry			+= " WHERE "
cQry			+= "       SF4.F4_FILIAL   = '" + xFilial("SF4") + "' "
cQry			+= "   AND SF4.F4_TIPO  = 'S' "
cQry			+= "   AND SF4.F4_CF    IN ('5152','6152')  AND F4_NRLIVRO = ' ' "
cQry			+= "   AND SF4.D_E_L_E_T_ = ' ' "
cQry			:= ChangeQuery( cQry )

DbUseArea(.T., "TopConn", TCGenQry(, , cQry ), cAliasQry, .F., .F. )
DbSelectArea( cAliasQry )
( cAliasQry )->( DbGoTop() )
While ( cAliasQry )->( !Eof() )
    aCampos := {}
    for nCountA := 1 to SF4->(Fcount())
        If SF4->(Eval(bCampo, nCountA)) $ 'F4_CODIGO'
            Aadd(aCampos,GetCod('S'))
        ElseIf SF4->(Eval(bCampo, nCountA)) $ 'F4_NRLIVRO'
            Aadd(aCampos,'2')
        ElseIf SF4->(Eval(bCampo, nCountA)) $ 'F4_CPPRODE'
            Aadd(aCampos, 3 )                
        ElseIf SF4->(Eval(bCampo, nCountA)) $ 'F4_TPPRODE'
            Aadd(aCampos, '4' )                            
        Else
            Aadd(aCampos,( cAliasQry )->&(Eval(bCampo, nCountA)))
        EndIf
    next

    Reclock('SF4',.T.)
    For nCountA := 1 To SF4->(FCount())
        SF4->(FieldPut(nCountA,aCampos[nCountA]))
    Next
    MsUnlock()

    ( cAliasQry )->(dbSkip())
Enddo

( cAliasQry )->(dbCloseArea())

Return 


Static Function ProcB()
Local cAliasQry	:= GetNextAlias()
Local cQry	:= ""
Local aCampos    := {}
Local bCampo     := {|x| FieldName(x)}

cQry			:= ""
cQry			:= " SELECT * FROM " + RetSqlName("SF4") + " SF4 "
cQry			+= " WHERE "
cQry			+= "       SF4.F4_FILIAL   = '" + xFilial("SF4") + "' "
cQry			+= "   AND SF4.F4_TIPO  = 'E' "
cQry			+= "   AND SF4.F4_CF    IN ('1152','2152')  AND F4_NRLIVRO = ' ' "
cQry			+= "   AND SF4.D_E_L_E_T_ = ' ' "
cQry			:= ChangeQuery( cQry )

DbUseArea(.T., "TopConn", TCGenQry(, , cQry ), cAliasQry, .F., .F. )
DbSelectArea( cAliasQry )
( cAliasQry )->( DbGoTop() )
While ( cAliasQry )->( !Eof() )
    aCampos := {}
    for nCountA := 1 to SF4->(Fcount())
        If SF4->(Eval(bCampo, nCountA)) $ 'F4_CODIGO'
            Aadd(aCampos,GetCod('E'))
        ElseIf SF4->(Eval(bCampo, nCountA)) $ 'F4_NRLIVRO'
            Aadd(aCampos,'2')
        ElseIf SF4->(Eval(bCampo, nCountA)) $ 'F4_CPPRODE'
            Aadd(aCampos, 3 )                
        ElseIf SF4->(Eval(bCampo, nCountA)) $ 'F4_TPPRODE'
            Aadd(aCampos, '3' )                            
        Else
            Aadd(aCampos,( cAliasQry )->&(Eval(bCampo, nCountA)))
        EndIf
    next

    Reclock('SF4',.T.)
    For nCountA := 1 To SF4->(FCount())
        SF4->(FieldPut(nCountA,aCampos[nCountA]))
    Next
    MsUnlock()

    ( cAliasQry )->(dbSkip())
Enddo

( cAliasQry )->(dbCloseArea())
Return 


Static Function ProcC()
Local cAliasQry	:= GetNextAlias()
Local cQry	:= ""
Local aCampos    := {}
Local bCampo     := {|x| FieldName(x)}
Local cCod      := ''
Local aTes      := {'537','538','541','545','598','603','612','615','619','620','629','639','694','716'}
Local aSFM      := {}
Local n         := 0
Local y         := 0
Local nCountA   := 0
Private  cLog     := ''

SF4->(DbSetOrder(1))
For n := 1 to Len(aTes)
    IF SF4->(DbSeek(xFilial('SF4') + aTes[n]))
        cCod := GetCod('S')
        aCampos := {}
        for nCountA := 1 to SF4->(Fcount())
            If SF4->(Eval(bCampo, nCountA)) $ 'F4_CODIGO'
                Aadd(aCampos,cCod)
            ElseIf SF4->(Eval(bCampo, nCountA)) $ 'F4_NRLIVRO'
                Aadd(aCampos,'2')
            ElseIf SF4->(Eval(bCampo, nCountA)) $ 'F4_CPPRODE'
                Aadd(aCampos, 8 )                
            ElseIf SF4->(Eval(bCampo, nCountA)) $ 'F4_TPPRODE'
                Aadd(aCampos, '6' )                           
            ElseIf SF4->(Eval(bCampo, nCountA)) $ 'F4_CF'
                Aadd(aCampos,'5' + SUBSTR(SF4->&(Eval(bCampo, nCountA)),2,Len(SF4->F4_CF)))                                        
            Else
                Aadd(aCampos,SF4->&(Eval(bCampo, nCountA)))
            EndIf
        next

        aSFM := AtuSFM(SF4->F4_CODIGO, cCod)

        Reclock('SF4',.T.)
        For nCountA := 1 To SF4->(FCount())
            SF4->(FieldPut(nCountA,aCampos[nCountA]))
        Next
        MsUnlock()
        
        cLog += 'Atualizado TES 8% ' + Alltrim(SF4->F4_CODIGO)

        cCod := GetCod('S')
        
        SFM->(DbSetOrder(3))
        For y   := 1 to Len(aSFM)
            SFM->(DbSeek(xFilial('SFM') + aSFM[y]))
            aCampos := {}
            for nCountA := 1 to SFM->(Fcount())
                If SF4->(Eval(bCampo, nCountA)) $ 'FM_ID'
                    Aadd(aCampos,MTA089ID())
                ElseIf SFM->(Eval(bCampo, nCountA)) $ 'FM_TS'
                    Aadd(aCampos,cCod)                                   
                Else
                    Aadd(aCampos,SFM->&(Eval(bCampo, nCountA)))
                EndIf
            next
            Reclock('SFM',.T.)
            For nCountA := 1 To SFM->(FCount())
                SFM->(FieldPut(nCountA,aCampos[nCountA]))
            Next
            MsUnlock()
            cLog += 'Atualizado TES inteligente ID ' + SFM->FM_ID +' Codigo antigo - ' + Alltrim(SF4->F4_CODIGO) + ' Codigo novo - ' + cCod            
        Next
        
        SF4->(DbSeek(xFilial('SF4') + aTes[n]))
        aCampos := {}
        for nCountA := 1 to SF4->(Fcount())
            If SF4->(Eval(bCampo, nCountA)) $ 'F4_CODIGO'
                Aadd(aCampos,cCod)
            ElseIf SF4->(Eval(bCampo, nCountA)) $ 'F4_NRLIVRO'
                Aadd(aCampos,'2')
            ElseIf SF4->(Eval(bCampo, nCountA)) $ 'F4_CPPRODE'
                Aadd(aCampos, 47.5 )                
            ElseIf SF4->(Eval(bCampo, nCountA)) $ 'F4_TPPRODE'
                Aadd(aCampos, '6' )                           
            ElseIf SF4->(Eval(bCampo, nCountA)) $ 'F4_CF'
                Aadd(aCampos,'6' + SUBSTR(SF4->&(Eval(bCampo, nCountA)),2,Len(SF4->F4_CF)))                                        
            Else
                Aadd(aCampos,SF4->&(Eval(bCampo, nCountA)))
            EndIf
        next

        Reclock('SF4',.T.)
        For nCountA := 1 To SF4->(FCount())
            SF4->(FieldPut(nCountA,aCampos[nCountA]))
        Next
        MsUnlock()
        cLog += 'Atualizado TES 47,5 % ' + Alltrim(SF4->F4_CODIGO)
    EndIf
Next
HS_MSGINF("Resumo do processamento :" + CRLF + cLog ,"Geração arquivo ")
Return 


Static Function GetCod(cTipo)
Local cCod := ''
Local nRec  := SF4->(Recno())
If cTipo == 'S'
    cCod := '501'
    SF4->(dbSetOrder(1))
    While SF4->(DbSeek(xFilial('SF4') + cCod))
        cCod := Soma1(cCod)
    Enddo
Else
    cCod := '001'
    SF4->(dbSetOrder(1))
    While SF4->(DbSeek(xFilial('SF4') + cCod))
        cCod := Soma1(cCod)
    Enddo

    If Val(cCod) >= 500
        Alert('Não foi possivel encontrar um codigo de TES valido!')
    EndIf
EndIf
SF4->(DbGoTo(nRec))
return cCod


Static Function AtuSFM(cCod, cNewCod)
Local cAliasQry	:= GetNextAlias()
Local cQry	:= ""
Local aCampos    := 0 
Local bCampo     := {|x| FieldName(x)}
Local aRet       := {}
cQry			:= ""
cQry			:= " SELECT R_E_C_N_O_ AS REC FROM " + RetSqlName("SFM") + " SFM "
cQry			+= " WHERE "
cQry			+= "       SFM.FM_FILIAL   = '" + xFilial("SFM") + "' "
cQry			+= "   AND SFM.FM_TS  =   '" + cCod + "' "
cQry			+= "   AND SFM.D_E_L_E_T_ = ' ' "
cQry			:= ChangeQuery( cQry )

DbUseArea(.T., "TopConn", TCGenQry(, , cQry ), cAliasQry, .F., .F. )
DbSelectArea( cAliasQry )
( cAliasQry )->( DbGoTop() )
While ( cAliasQry )->( !Eof() )
    SFM->(DbGoTo(( cAliasQry )->REC))
    Reclock('SFM',.F.)
    SFM->FM_TS := cNewCod
    MsUnlock()
    cLog += 'Atualizado TES inteligente ID ' + SFM->FM_ID +' Codigo antigo - ' + Alltrim(cCod) + ' Codigo novo - ' + cNewCod
    Aadd(aRet,SFM->FM_ID)
    ( cAliasQry )->(DbSkip())
Enddo
( cAliasQry )->(DbCloseArea())
Return aRet


Static Function PRODUTOS()
Local cAliasQry	:= GetNextAlias()
Local cQry	:= ""
Local aCampos    := {}
Local bCampo     := {|x| FieldName(x)}
Local cLog      := ''
Local cIn       := "'28352600','17025000','35030019','04081100','29224220','38089429','29181100','17021900','34021190','17029000','18040000','28321090','21069029','04049000','21069029','21069029','21069029','21069029','21041029','21069029','29157040','35079049','28341010','28341010','34021300','27101991','21039029','04089100','27129000','28353920','18050000','34021300','29251100','29161911','29054400','29321400','25262000','25262000','29400019','29152100','29181400','28092011','29181100','29182110','29161919','34021140','29181200','39053000','29241999','33029019','33029019','29242991','29239040','34029029','11052000','29163121','32041912','28369913','29181310','29094310','29393010','39123111','32030021','29181500','04089100','29239050','28272010','34029029','25010090','35071000','21041029','17029000','17029000','07129090','32030019','32030019','32041990','32041210','32041100','28352980','28112210','29157040','33029019','29224920','19019010','21023000'"
cQry			:= ""
cQry			:= " SELECT B1_COD , B1_DESC , SB5.R_E_C_N_O_ AS REC FROM " + RetSqlName("SB1") + " SB1 "
cQry			+= " INNER JOIN SB5010 SB5 ON B5_FILIAL = '" + xFilial('SB5') + "' AND SB1.B1_COD = SB5.B5_COD AND SB5.D_E_L_E_T_ = ' '    "
cQry			+= " WHERE "
cQry			+= "       SB1.B1_FILIAL   = '" + xFilial("SB1") + "' "
cQry			+= "   AND SB1.B1_POSIPI IN   (" + cIn + ")"
cQry			+= "   AND SB1.D_E_L_E_T_ = ' ' "
cQry			:= ChangeQuery( cQry )

DbUseArea(.T., "TopConn", TCGenQry(, , cQry ), cAliasQry, .F., .F. )
DbSelectArea( cAliasQry )
( cAliasQry )->( DbGoTop() )
While ( cAliasQry )->( !Eof() )
    SB5->(DbGoTo(( cAliasQry )->REC))
    Reclock('SB5',.F.)
    SB5->B5_NATBEN := '2'
    SB5->B5_NUMBEN := '43031'
    SB5->B5_DTDECRE := STOD('20160612')
    SB5->B5_ANOBEN  := '2031'
    MsUnlock()
    cLog += 'Atualizado produto ' + ( cAliasQry )->B1_COD + ' ' + ( cAliasQry )->B1_DESC + CRLF
    ( cAliasQry )->(dbSkip())
Enddo

( cAliasQry )->(dbCloseArea())
HS_MSGINF("Resumo do processamento :" + CRLF + cLog ,"Geração arquivo ")
Return
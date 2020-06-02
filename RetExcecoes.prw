User Function Excecoes(cTipo)
Local nValor   := 0
Local nRet      := 0
Local nLinha   := TMP1->(Recno())
Local nValorNG := SupergetMV('ES_VALORNG',.T.,0)
Local nValorPM := SupergetMV('ES_VALORPM',.T.,0)
Local nTotItens := 0

IF M->CJ_ZZEXCEC == 'N'
    Return 0 //se nao tiver exceções retorna 0
EndIf

dbSelectArea("TMP1")
dbGoTop()
While !Eof()
	IF TMP1->CK_UM == 'KG'
		nTotItens ++
	EndIf
	TMP1->(DbSkip())
End

dbSelectArea("TMP1")
dbGoTop()
IF !empty(("TMP1")->CK_PRODUTO)    
    While !Eof()
        If  !("TMP1")->CK_FLAG .And. !Val(TMP1->CK_XMOTIVO) > 1
            SB1->(dbSetOrder(1))
            If SB1->(DbSeek(xFilial('SB1') + ("TMP1")->CK_PRODUTO )) .And. SB1->B1_PESBRU > 0
                nValor += (("TMP1")->CK_QTDVEN * SB1->B1_PESBRU)
                If cTipo == '2'
                    TMP1->CK_XPALET := (("TMP1")->CK_QTDVEN * SB1->B1_PESBRU) * nValorNG
                ElseIf cTipo == '3'
                    TMP1->CK_XPALET := (("TMP1")->CK_QTDVEN * SB1->B1_PESBRU) * nValorPM
                ElseIf cTipo == '1'
                    TMP1->CK_XPALET := 0
                Endif
                If nLinha   == TMP1->(Recno())
                    nRet := (("TMP1")->CK_QTDVEN * SB1->B1_PESBRU) //+ (IIF(cTipo=='2',cValorNG , cValorPM) / nTotItens)
                EndIf                
            EndIf
        EndIf
        ("TMP1")->(DbSkip())
    EndDo
EndIf

If cTipo == '2'
    M->CJ_ZZNEGOC := nValor * nValorNG
    nRet := nRet * nValorNG
ElseIf cTipo == '3'
   M->CJ_ZZNEGOC := nValor * nValorPM
   nRet := nRet * nValorPM
ElseIf cTipo == '1'
   M->CJ_ZZNEGOC := 0
   nRet := 0
Endif

TMP1->(DbGoTo(nLinha))

GETDREFRESH()      
oGetDad:Refresh()

Return(nRet)

 /*/{Protheus.doc} VlrExceco()
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
User Function VlrExceco()
Local aParam      := {}
Local aRet        := {}
Local nValorNG      := SupergetMV('ES_VALORNG',.T.,0)
Local nValorPM      := SupergetMV('ES_VALORPM',.T.,0)

aAdd(aParam, {1, "Valor Negociado"   , Transform(nValorNG,'@E 9,999,99.999') ,  ,, ,, 60, .F.} )
aAdd(aParam, {1, "Valor Permuta"   , Transform(nValorPM,'@E 9,999,99.999')  ,  ,, ,, 60, .F.} )

If ParamBox(aParam,'Parâmetros',aRet)
    PutMv('ES_VALORNG',Val(STRTRAN(aRet[1],',','.')))
    PutMv('ES_VALORPM',Val(STRTRAN(aRet[2],',','.')))
    MsgInfo('Informações Atualizadas com sucesso!')
EndIf
Return 


/*/{Protheus.doc} UpdExcec()
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
User Function UpdExcec(cTipo)
Local aArea := GetArea()

M->CJ_ZZNEGOC := 0

dbSelectArea("TMP1")
dbGoTop()
While !Eof()
	TMP1->CK_XPALET := U_Excecoes(M->CJ_ZZPALLE)
    U_ClcComis()
	TMP1->(DbSkip())
End
TMP1->(dbGoTop())

GETDREFRESH()      
oGetDad:Refresh()
RestArea(aArea)
Return M->CJ_ZZPALLE



 /*/{Protheus.doc} LimpObs
    Limpa as observações de execções no orçamento
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
User Function LimpObs()
Local cVariavel := ReadVar()

//Limpo os campos
If cVariavel == 'M->CJ_ZZSELO'
    M->CJ_ZZOBSLO := Space(TAMSX3('CJ_ZZOBSLO')[1])
EndIf
If cVariavel == 'M->CJ_ZZLAUDO'
    M->CJ_ZZOBSLA := Space(TAMSX3('CJ_ZZOBSLA')[1])
EndIf
If cVariavel == 'M->CJ_ZZPALLE'
    M->CJ_ZZOBSPA := Space(60)
EndIf
If cVariavel == 'M->CJ_ZZOUTRO'
    M->CJ_ZZOUTXT := Space(TAMSX3('CJ_ZZOUTXT')[1])
EndIf

Return &cVariavel
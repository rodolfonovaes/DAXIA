#INCLUDE "TOPCONN.CH"
/*/{Protheus.doc} AjustaC9
    Crio uma SC9 e uma DCF quando ultrapassar a norma
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
User Function AjustaC9(cPed)
Local aArea := GetArea()
Local cSrv		 := SuperGetMV('ES_SERVDIS',.T.,'019',cFilAnt)
Local nNorma     := 0
Local nSobra     := 0
Local nQuant     := 0
Local aCampos    := 0 
Local bCampo     := {|x| FieldName(x)}
Local nCountA    := 0
Local cSequen    := ''
Local nRecC9     := SC9->(Recno())

SC9->(DbSetOrder(1))
If SC9->(DbSeek(xFilial('SC9') + cPed)) 
    SBZ->(DbSetOrder(1))
    If SBZ->(DbSeek(SC9->C9_FILIAL + SC9->C9_PRODUTO )) .And. SBZ->BZ_CTRWMS == '1' .And. SBZ->BZ_LOCALIZ == 'S'

        cSequen := RetSeq(SC9->C9_PEDIDO)
        While SC9->(C9_FILIAL + C9_PEDIDO) == xFilial('SC9') + cPed
            nRecC9     := SC9->(Recno())
            DbSelectArea( "DCF" ) // Cadastro Ordem de Servicos
            DCF->(DbSetOrder( 2 ) )
            If DCF->( DbSeek( xFilial('DCF') + cSrv + PADR(SC9->C9_PEDIDO,TAMSX3('DCF_DOCTO')[1]) + PADR(SC9->C9_ITEM,TAMSX3('DCF_SERIE')[1]) + PADR(SC9->C9_CLIENTE,TAMSX3('DCF_CLIFOR')[1]) + SC9->C9_LOJA + SC9->C9_PRODUTO))
                SB1->(DbSetOrder(1))
                SB1->(DbSeek(xFilial('SB1') + SC9->C9_PRODUTO))

                DC3->(DbSetOrder(2))
                If !DC3->(DbSeek(xFilial('DC3') + DCF->DCF_CODPRO + DCF->DCF_LOCAL + '000007'))
                    If DC3->(DbSeek(xFilial('DC3') + DCF->DCF_CODPRO + DCF->DCF_LOCAL + '000008'))
                            DC2->(DbSetOrder(1))
                            DC2->(DbSeek(xFilial('DC2') + DC3->DC3_CODNOR))			
                            nNorma :=  (DC2->DC2_LASTRO * DC2->DC2_CAMADA)  
                    EndIf
                Else
                    DC2->(DbSetOrder(1))
                    DC2->(DbSeek(xFilial('DC2') + DC3->DC3_CODNOR))			
                    nNorma :=  (DC2->DC2_LASTRO * DC2->DC2_CAMADA)  
                EndIf


                If nNorma > 0 .And. DCF->DCF_QTSEUM > nNorma
                    //enquanto a sobra for maior que zero vou subtraindo a norma e gravando DCF nova
                    nSobra  := DCF->DCF_QTSEUM - nNorma

                    Begin Transaction
                    //Atualizo a DCF e SC9 atual
                    Reclock('DCF',.F.)
                    DCF->DCF_QUANT  := nNorma *  SB1->B1_CONV
                    DCF->DCF_QTDORI := nNorma *  SB1->B1_CONV
                    DCF->DCF_QTSEUM := nNorma
                    MsUnlock()

                    Reclock('SC9',.F.)
                    SC9->C9_QTDLIB   := nNorma *  SB1->B1_CONV
                    SC9->C9_QTDLIB2  := nNorma
                    MsUnlock()       

                    While nSobra > 0
                        If nSobra >= nNorma
                            nQuant := nNorma
                        Else
                            nQuant := nSobra
                        EndIf

                        nSobra -= nQuant
                        aCampos := {}
                        for nCountA := 1 to DCF->(Fcount())
                            If DCF->(Eval(bCampo, nCountA)) $ 'DCF_NUMSEQ|DCF_ID'
                                Aadd(aCampos,ProxNum())
                            ElseIf DCF->(Eval(bCampo, nCountA)) $ 'DCF_QUANT|DCF_QTDORI'
                                Aadd(aCampos,nQuant * SB1->B1_CONV)
                            ElseIf DCF->(Eval(bCampo, nCountA)) $ 'DCF_QTSEUM'
                                Aadd(aCampos, nQuant )                
                            Else
                                Aadd(aCampos,DCF->&(Eval(bCampo, nCountA)))
                            EndIf
                        next

                        Reclock('DCF',.T.)
                        For nCountA := 1 To DCF->(FCount())
                            DCF->(FieldPut(nCountA,aCampos[nCountA]))
                        Next
                        MsUnlock()

                        //
                        aCampos := {}
                        cSequen := SOMA1(cSequen)
                        for nCountA := 1 to SC9->(Fcount())
                            If SC9->(Eval(bCampo, nCountA)) $ 'C9_IDDCF'
                                Aadd(aCampos,DCF->DCF_ID)
                            ElseIf SC9->(Eval(bCampo, nCountA)) $ 'C9_QTDLIB'
                                Aadd(aCampos,DCF->DCF_QUANT)
                            ElseIf SC9->(Eval(bCampo, nCountA)) $ 'C9_QTDLIB2'
                                Aadd(aCampos, DCF->DCF_QTSEUM )             
                            ElseIf SC9->(Eval(bCampo, nCountA)) $ 'C9_SEQUEN'
                                Aadd(aCampos, cSequen )             
                            ElseIf SC9->(Eval(bCampo, nCountA)) $ 'C9_BLEST'
                                Aadd(aCampos, '' )     
                            ElseIf SC9->(Eval(bCampo, nCountA)) $ 'C9_STSERV'
                                Aadd(aCampos, '1' )                                                                 
                            Else
                                Aadd(aCampos,SC9->&(Eval(bCampo, nCountA)))
                            EndIf
                        next

                        Reclock('SC9',.T.)
                        For nCountA := 1 To SC9->(FCount())
                            SC9->(FieldPut(nCountA,aCampos[nCountA]))
                        Next
                        MsUnlock()         
                    EndDo

                    //Não sei pq esta voltando o valor anterior, entao eu pego e volto o valor da SC9 pra norma
                    SC9->(dbGoTo(nRecC9))
                    Reclock('SC9',.F.)
                    SC9->C9_QTDLIB   := nNorma *  SB1->B1_CONV
                    SC9->C9_QTDLIB2  := nNorma
                    MsUnlock()     
                    
                    End Transaction
                EndIf

            EndIf
            SC9->(DbSkip())
        EndDo
    EndIf
EndIf

RestArea(aArea)
Return Nil



/*/{Protheus.doc} RetSeq()
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
Static Function RetSeq(cPedido)
Local cQuery := ''
Local cAliasQry := GetNextAlias()
Local cSequen   := ''

cQuery := "SELECT MAX(C9_SEQUEN) AS SEQ"
cQuery += "  FROM " + RetSQLTab('SC9') 
cQuery += "  WHERE  "
cQuery += "  C9_FILIAL = '" + xFilial('SC9') + "' AND C9_PEDIDO = '" + cPedido +"'  "
cQuery += "  AND SC9.D_E_L_E_T_ = ' '"

TcQuery cQuery new Alias ( cAliasQry )

(cAliasQry)->(dbGoTop())

If !(cAliasQry)->(EOF())
    cSequen := (cAliasQry)->SEQ       
EndIf

(cAliasQry)->(DbCloseArea())
Return cSequen

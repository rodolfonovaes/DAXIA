#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
 
 /*/{Protheus.doc} MTA440C9
    Ponto de Entrada apos gerar SC9(Liberacao do Pedido)
    @type  User Function
    @author B. Vinicius
    @since 17/12/2019
/*/
User Function MTA440C9()

    Local aAreaSC9 := SC9->(GetArea())
    Local aAreaSC5 := SC5->(GetArea())
    Local cStatusCred := ""
    Local cStatusEst := ""

    SC5->(dbSetorder(1))
    SC5->(dbSeek(FWxFilial("SC5")+SC9->C9_PEDIDO))


    If IsInCallStack('MATA440') //Libera��o comercial
        // REGISTRO QUEM LIBEROU
        Reclock("SC9",.F.)
        // Log de Atualiza��o
        // xxxxxx.xxxxx;99/99/9999;99:99;99;xxxxx;99
        // <<usu�rio>>;<<data>>;<<hora>>;<<fun�ao>>;<<valor novo>>
        SC9->C9_XLOGLIB := UsrRetName( retcodusr() ) + ";" + DTOC(dDataBase) + ";" + Time()  + ";" + FUNNAME() 
        SC9->(MsUnLock())
    
        Reclock("SC5",.F.)
        SC5->C5_XLOGLIB := UsrRetName( retcodusr() ) + ";" + DTOC(dDataBase) + ";" + Time()  + ";" + FUNNAME() 
        SC5->(MsUnLock())        
    EndIf

    If Empty(SC9->C9_XLOGLIB) .And. !IsInCallStack('MATA440') //Caso tenha sido incluida uma nova linha da SC9
        Reclock("SC9",.F.)
        // Log de Atualiza��o
        // xxxxxx.xxxxx;99/99/9999;99:99;99;xxxxx;99
        // <<usu�rio>>;<<data>>;<<hora>>;<<fun�ao>>;<<valor novo>>
        SC9->C9_XLOGLIB := RecLog(SC9->C9_PEDIDO , 1 )
        SC9->(MsUnLock())        
    EndIf

    //ATUALIZA SITUACAO DO CREDITO
    cStatusCred := RetStPed("C9_BLCRED")
    cAntesCRD   := SC5->C5_BLCRED

    Reclock("SC5",.F.)
    SC5->C5_BLCRED := cStatusCred
    SC5->(MsUnLock())

    //IF FieldPos("C9_XLOGCRE") > 0  .AND. ; // CASO O CAMPO EXISTA
 //    IF   ( EMPTY(ALLTRIM(cAntesCRD)) .OR. ; // CASO O STATUS ANTERIOR SEJA  VAZIO EU ATUALIZO
    If  ALLTRIM(cAntesCRD) <> ALLTRIM(cStatusCred) .And. Empty(cStatusCred) .And. IsInCallStack('MATA450')// CASO O STATUS ATUAL SEJA  DIFERENTE DO ANTERIOR EU ATUALIZO

        // REGISTRO QUEM LIBEROU
        Reclock("SC9",.F.)
        // Log de Atualiza��o
        // xxxxxx.xxxxx;99/99/9999;99:99;99;xxxxx;99
        // <<usu�rio>>;<<data>>;<<hora>>;<<fun�ao>>;<<valor novo>>
        SC9->C9_XLOGCRE := UsrRetName( retcodusr() ) + ";" + DTOC(dDataBase) + ";" + Time()  + ";" + FUNNAME() + ";" + cStatusCred
        SC9->(MsUnLock())
    
        Reclock("SC5",.F.)
        SC5->C5_XLOGCRE := UsrRetName( retcodusr() ) + ";" + DTOC(dDataBase) + ";" + Time()  + ";" + FUNNAME() + ";" + cStatusCred
        SC5->(MsUnLock())
        
    ENDIF

    If Empty(SC9->C9_XLOGCRE) .And. Empty(cStatusCred) .And. IsInCallStack('MATA450') //Libera��o comercial//Caso o log esteja vazio e esteja liberado no credito 
        Reclock("SC9",.F.)
        // Log de Atualiza��o
        // xxxxxx.xxxxx;99/99/9999;99:99;99;xxxxx;99
        // <<usu�rio>>;<<data>>;<<hora>>;<<fun�ao>>;<<valor novo>>
        SC9->C9_XLOGCRE := RecLog(SC9->C9_PEDIDO , 2)
        SC9->(MsUnLock())  

        Reclock("SC5",.F.)
        SC5->C5_XLOGCRE := SC9->C9_XLOGCRE
        SC5->(MsUnLock())              
    EndIf

    //ATUALIZA SITUACAO DO ESTOQUE
    cStatusEst := RetStPed("C9_BLEST")
    cAntesEST  := SC5->C5_BLEST

    Reclock("SC5",.F.)
    SC5->C5_BLEST := cStatusEst
    SC5->(MsUnLock())

    //IF FieldPos("C9_XLOGEST") > 0  .AND. ; // CASO O CAMPO EXISTA
    //IF    ( EMPTY(ALLTRIM(cAntesEST)) .OR. ; // CASO O STATUS ANTERIOR SEJA  VAZIO EU ATUALIZO
    If  ALLTRIM(cAntesEST) <> ALLTRIM(cStatusEst) .And. Empty(cStatusEst)// CASO O STATUS ATUAL SEJA  DIFERENTE DO ANTERIOR EU ATUALIZO
        // REGISTRO QUEM LIBEROU
        Reclock("SC9",.F.)
        // Log de Atualiza��o
        // xxxxxx.xxxxx;99/99/9999;99:99;99;xxxxx;99
        // <<usu�rio>>;<<data>>;<<hora>>;<<fun�ao>>;<<valor novo>>
        SC9->C9_XLOGEST := UsrRetName( retcodusr() ) + ";" + DTOC(dDataBase) + ";" + Time()  + ";" + FUNNAME() + ";" + cStatusEst
        SC9->(MsUnLock())    

        Reclock("SC5",.F.)
        SC5->C5_XLOGEST := UsrRetName( retcodusr() ) + ";" + DTOC(dDataBase) + ";" + Time()  + ";" + FUNNAME() + ";" + cStatusEst
        SC5->(MsUnLock())
    ENDIF

    If Empty(SC9->C9_XLOGEST) .And. Empty(cStatusEst) //Caso o log esteja vazio e esteja liberado no credito 
        Reclock("SC9",.F.)
        // Log de Atualiza��o
        // xxxxxx.xxxxx;99/99/9999;99:99;99;xxxxx;99
        // <<usu�rio>>;<<data>>;<<hora>>;<<fun�ao>>;<<valor novo>>
        SC9->C9_XLOGEST := RecLog(SC9->C9_PEDIDO , 3)
        SC9->(MsUnLock())        
    EndIf    

    //ATUALIZA SITUACAO DO WMS
    cStatusWMS := RetStPed("C9_BLWMS") // Status Atual
    cAntesWMS  := SC5->C5_XBLWMS       // Status Anterior

 //   IF FIELDPOS("C5_XBLWMS") > 0 // VERIFICO SE O CAMPO EXISTE
        
        Reclock("SC5",.F.)
        SC5->C5_XBLWMS := cStatusWMS
        SC5->(MsUnLock())

        IF  cStatusWMS $ ("01|02|03") // BLOQUEIO WMS
            // N�O PREVISTO LOG PARA BLOQUEIO 
        ELSEIF cStatusWMS $ ("05|06|07") // LIBERA��O WMS
         //   IF  FieldPos("C9_XLOGWMS") > 0 .AND. ; // CASO O CAMPO EXISTA
            //IF    ( EMPTY(ALLTRIM(cAntesWMS)) .OR. ; // CASO O STATUS ANTERIOR SEJA  VAZIO EU ATUALIZO
            If     ALLTRIM(cAntesWMS) <> ALLTRIM(cStatusWMS) .and. Empty(cStatusWMS)  // CASO O STATUS ATUAL SEJA  DIFERENTE DO ANTERIOR EU ATUALIZO

                // REGISTRO QUEM LIBEROU
                Reclock("SC9",.F.)
                // Log de Atualiza��o
                // xxxxxx.xxxxx;99/99/9999;99:99;99;xxxxx;99
                // <<usu�rio>>;<<data>>;<<hora>>;<<fun�ao>>;<<valor novo>>
                SC9->C9_XLOGWMS := UsrRetName( retcodusr() ) + ";" + DTOC(dDataBase) + ";" + Time()  + ";" + FUNNAME() + ";" + cStatusWMS
                SC9->(MsUnLock())

                Reclock("SC5",.F.)
                SC5->C5_XLOGWMS := UsrRetName( retcodusr() ) + ";" + DTOC(dDataBase) + ";" + Time()  + ";" + FUNNAME() + ";" + cStatusWMS
                SC5->(MsUnLock())
            ENDIF
    	ENDIF
 //   ENDIF

    RestArea(aAreaSC5)
    RestArea(aAreaSC9)

Return

Static Function RetStPed(cCampo)

    Local cRet := ""
    Local cQuery := ""
    Local cAliasQry := GetNextAlias()

    cQuery += " SELECT " + cCampo

    cQuery += " FROM " + RetSQLName("SC9") + " SC9 "

    cQuery += " WHERE C9_FILIAL = '" + FWxFilial("SC9")+"' "

    cQuery += " AND C9_PEDIDO = '" + SC9->C9_PEDIDO + "' "

    cQuery += " AND " + cCampo + " <> '' "

    cQuery += " AND SC9.D_E_L_E_T_ = '' "


    TcQuery cQuery new Alias (cAliasQry)

    If !(cAliasQry)->(EOF())
        cRet := (cAliasQry)->(&(cCampo))
    Endif

Return cRet

/*/{Protheus.doc} RecLog(cPedido)
    Recupera o ultimo log da SC9 qdo � executada a libera��o do estoque.
    Pois o sistema gera uma nova SC9
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
Static Function RecLog(cPedido, nTipo)
Local cRet := ''
Local cQuery := ""
Local cAliasQry := GetNextAlias()

cQuery += " SELECT TOP 1 * "
cQuery += " FROM " + RetSQLName("SC9") + " SC9 "
cQuery += " WHERE C9_FILIAL = '" + FWxFilial("SC9")+"' "
cQuery += " AND C9_PEDIDO = '" + cPedido + "' "
cQuery += " AND SC9.D_E_L_E_T_ <> '' "
cQuery += " ORDER BY R_E_C_N_O_ DESC "

TcQuery cQuery new Alias (cAliasQry)

If !(cAliasQry)->(EOF())
    If nTipo == 1
        cRet := (cAliasQry)->C9_XLOGLIB
    ELSEIF nTipo == 2
        cRet := (cAliasQry)->C9_XLOGCRE
    ELSEIF nTipo == 3
        cRet := (cAliasQry)->C9_XLOGEST        
    EndIf
Endif

Return cRet
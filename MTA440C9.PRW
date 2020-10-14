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

    //ATUALIZA SITUACAO DO CREDITO
    cStatusCred := RetStPed("C9_BLCRED")
    cAntesCRD   := SC5->C5_BLCRED

    Reclock("SC5",.F.)
    SC5->C5_BLCRED := cStatusCred
    SC5->(MsUnLock())

    //IF FieldPos("C9_XLOGCRE") > 0  .AND. ; // CASO O CAMPO EXISTA
     IF   ( EMPTY(ALLTRIM(cAntesCRD)) .OR. ; // CASO O STATUS ANTERIOR SEJA  VAZIO EU ATUALIZO
          ALLTRIM(cAntesCRD) <> ALLTRIM(cStatusCred) ) // CASO O STATUS ATUAL SEJA  DIFERENTE DO ANTERIOR EU ATUALIZO

        If       Empty(SC9->C9_XLOGCRE) .And. EMPTY(ALLTRIM(cAntesCRD))

        // REGISTRO QUEM LIBEROU
        Reclock("SC9",.F.)
        // Log de Atualização
        // xxxxxx.xxxxx;99/99/9999;99:99;99;xxxxx;99
        // <<usuário>>;<<data>>;<<hora>>;<<funçao>>;<<valor novo>>
        SC9->C9_XLOGCRE := UsrRetName( retcodusr() ) + ";" + DTOC(dDataBase) + ";" + Time()  + ";" + FUNNAME() + ";" + cStatusCred
        SC9->(MsUnLock())
    
        Reclock("SC5",.F.)
        SC5->C5_XLOGCRE := UsrRetName( retcodusr() ) + ";" + DTOC(dDataBase) + ";" + Time()  + ";" + FUNNAME() + ";" + cStatusCred
        SC5->(MsUnLock())
        
    ENDIF

    //ATUALIZA SITUACAO DO ESTOQUE
    cStatusEst := RetStPed("C9_BLEST")
    cAntesEST  := SC5->C5_BLEST

    Reclock("SC5",.F.)
    SC5->C5_BLEST := cStatusEst
    SC5->(MsUnLock())

    //IF FieldPos("C9_XLOGEST") > 0  .AND. ; // CASO O CAMPO EXISTA
    IF    ( EMPTY(ALLTRIM(cAntesEST)) .OR. ; // CASO O STATUS ANTERIOR SEJA  VAZIO EU ATUALIZO
            ALLTRIM(cAntesEST) <> ALLTRIM(cStatusEst) ) // CASO O STATUS ATUAL SEJA  DIFERENTE DO ANTERIOR EU ATUALIZO

        // REGISTRO QUEM LIBEROU
        Reclock("SC9",.F.)
        // Log de Atualização
        // xxxxxx.xxxxx;99/99/9999;99:99;99;xxxxx;99
        // <<usuário>>;<<data>>;<<hora>>;<<funçao>>;<<valor novo>>
        SC9->C9_XLOGEST := UsrRetName( retcodusr() ) + ";" + DTOC(dDataBase) + ";" + Time()  + ";" + FUNNAME() + ";" + cStatusEst
        SC9->(MsUnLock())    

        Reclock("SC5",.F.)
        SC5->C5_XLOGEST := UsrRetName( retcodusr() ) + ";" + DTOC(dDataBase) + ";" + Time()  + ";" + FUNNAME() + ";" + cStatusEst
        SC5->(MsUnLock())
    ENDIF

    //ATUALIZA SITUACAO DO WMS
    cStatusWMS := RetStPed("C9_BLWMS") // Status Atual
    cAntesWMS  := SC5->C5_XBLWMS       // Status Anterior

 //   IF FIELDPOS("C5_XBLWMS") > 0 // VERIFICO SE O CAMPO EXISTE
        
        Reclock("SC5",.F.)
        SC5->C5_XBLWMS := cStatusWMS
        SC5->(MsUnLock())

        IF  cStatusWMS $ ("01|02|03") // BLOQUEIO WMS
            // NÃO PREVISTO LOG PARA BLOQUEIO 
        ELSEIF cStatusWMS $ ("05|06|07") // LIBERAÇÃO WMS
         //   IF  FieldPos("C9_XLOGWMS") > 0 .AND. ; // CASO O CAMPO EXISTA
            IF    ( EMPTY(ALLTRIM(cAntesWMS)) .OR. ; // CASO O STATUS ANTERIOR SEJA  VAZIO EU ATUALIZO
                  ALLTRIM(cAntesWMS) <> ALLTRIM(cStatusWMS) ) // CASO O STATUS ATUAL SEJA  DIFERENTE DO ANTERIOR EU ATUALIZO

                // REGISTRO QUEM LIBEROU
                Reclock("SC9",.F.)
                // Log de Atualização
                // xxxxxx.xxxxx;99/99/9999;99:99;99;xxxxx;99
                // <<usuário>>;<<data>>;<<hora>>;<<funçao>>;<<valor novo>>
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
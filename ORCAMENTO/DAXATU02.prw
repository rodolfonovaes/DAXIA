#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"


User Function DAXATU02()





GPShowMemo(SC5->C5_MENNOTA)

Return



Static Function GPShowMemo(cMemo)
Local aParamBox := {}
Local aPergRet	:= {}
Local aMvPar := {}
Local nX      := 0

For nX := 1 To 40
 aAdd( aMvPar, &( "MV_PAR" + StrZero( nX, 2, 0 ) ) )
Next nX

aAdd(aParamBox, {1, "Data Coleta"			, SC5->C5_XDTCOL  ,  ,, ,, 50, .F.} )			//1
aAdd(aParamBox, {1, "Obs. Coleta"			, SC5->C5_XOBCOL , "@!" ,, ,, 200, .F.} )		//2
aAdd(aParamBox, {1, "Transportadora"		, SC5->C5_TRANSP , "@!" ,'U_DxVlSA4(MV_PAR03)','SA4' ,, 50, .F.} )	//3
aAdd(aParamBox, {1, "Redespacho"			, SC5->C5_XTREDES , "@!",'U_DxVlSA4(MV_PAR04)','SA4' ,, 50, .F.} )	//4
aAdd(aParamBox, {1, "Veiculo"				, SC5->C5_VEICULO , "@!" ,, ,, 50, .F.} )		//5
aAdd(aParamBox, {1, "Obs Faturamento"		, SC5->C5_ZZOUTXT , "@!" ,, ,, 200, .F.} )		//6
aAdd(aParamBox, {1, "Laudo"					, SC5->C5_ZZLAUDO , "@!" ,, ,, 50, .F.} )		//7
aAdd(aParamBox, {1, "Obs Laudo"				, SC5->C5_ZZOBSLA , "@!" ,, ,, 200, .F.} )		//8
aAdd(aParamBox, {1, "Volume "				, SC5->C5_VOLUME1 , "99999" ,, ,, 50, .F.} )	//9
aAdd(aParamBox, {1, "Especie "				, SC5->C5_ESPECI1 , "@X" ,, ,, 50, .F.} )		//10
aAdd(aParamBox, {1, "Peso Liquido"			, SC5->C5_PESOL , "@E 99,999,999.9999" ,, ,, 50, .F.} )	//11
aAdd(aParamBox, {1, "Peso Bruto"			, SC5->C5_PBRUTO , "@E 99,999,999.9999" ,, ,, 50, .F.} )	//12
aAdd(aParamBox, {11	, "Obs DANFE"			, cMemo, ,,.F.} )								//13
aAdd(aParamBox, {1, "Mensagem Padr�o"		, SC5->C5_MENPAD , "@!" ,,'SM4' ,, 50, .F.} )	//14
aAdd(aParamBox, {1, "Pedido Vinculado"		, SC5->C5_XPEDVIN , "@!" ,,'SC5VIN' ,, 50, .F.} )//15

If ParamBox(aParamBox, 'Ajuste', aPergRet,,,,,,,,.F.,.F.)
	UpdObs(aPergRet)
EndIf
/*
Pergunte('DXOBSPD',.F.)
u_zAtuPerg("DXOBSPD", "MV_PAR01", SC5->C5_XDTCOL)
u_zAtuPerg("DXOBSPD", "MV_PAR02", SC5->C5_XOBCOL)
u_zAtuPerg("DXOBSPD", "MV_PAR03", SC5->C5_TRANSP)
u_zAtuPerg("DXOBSPD", "MV_PAR04", SC5->C5_XTREDES)
u_zAtuPerg("DXOBSPD", "MV_PAR05", SC5->C5_VEICULO)
u_zAtuPerg("DXOBSPD", "MV_PAR06", SC5->C5_ZZOUTXT)
u_zAtuPerg("DXOBSPD", "MV_PAR07", SC5->C5_ZZLAUDO)
u_zAtuPerg("DXOBSPD", "MV_PAR08", SC5->C5_ZZOBSLA)
u_zAtuPerg("DXOBSPD", "MV_PAR09", SC5->C5_VOLUME1)
u_zAtuPerg("DXOBSPD", "MV_PAR10", SC5->C5_ESPECI1)
u_zAtuPerg("DXOBSPD", "MV_PAR11", SC5->C5_PESOL)
u_zAtuPerg("DXOBSPD", "MV_PAR12", SC5->C5_PBRUTO)
u_zAtuPerg("DXOBSPD", "MV_PAR13", cMemo)
u_zAtuPerg("DXOBSPD", "MV_PAR14", SC5->C5_MENPAD)
u_zAtuPerg("DXOBSPD", "MV_PAR15", SC5->C5_XPEDVIN)

If Pergunte('DXOBSPD',.T.)
	UpdObs(aPergRet)
EndIf
*/

For nX := 1 To Len( aMvPar )
 &( "MV_PAR" + StrZero( nX, 2, 0 ) ) := aMvPar[ nX ]
Next nX

Return


Static Function UpdObs(aPergRet)
If MsgYesNo("Confirma a altera��o dos campos?", "Observa��o - Daxia" )
	Reclock("SC5", .F.)
		SC5->C5_XDTCOL		:= aPergRet[1]
		SC5->C5_XOBCOL		:= aPergRet[2]
		SC5->C5_TRANSP  	:= aPergRet[3]
        SC5->C5_XNMTRAN     := POSICIONE('SA4',1,xFilial('SA4') + aPergRet[3] ,'A4_NOME')
		SC5->C5_XTREDES		:= aPergRet[4]
        SC5->C5_REDESP		:= aPergRet[4]
		SC5->C5_VEICULO		:= aPergRet[5]
		SC5->C5_ZZOUTXT		:= aPergRet[6]
		SC5->C5_ZZLAUDO		:= aPergRet[7]
		SC5->C5_ZZOBSLA		:= aPergRet[8]
		SC5->C5_VOLUME1 	:= aPergRet[9]
		SC5->C5_ESPECI1 	:= aPergRet[10]
		SC5->C5_PESOL   	:= aPergRet[11]
		SC5->C5_PBRUTO		:= aPergRet[12]
		SC5->C5_MENNOTA 	:= aPergRet[13]
        SC5->C5_MENPAD 	    := aPergRet[14]
		SC5->C5_XPEDVIN		:= aPergRet[15]
	MsUnLock()
EndIf
Return



User Function DXATUSC5()

DXShowMemo(SC5->C5_MENNOTA)

Return

Static Function DXShowMemo(cMemo)
Local aParamBox := {}
Local aPergRet	:= {}
Local aMvPar := {}
Local nX      := 0

For nX := 1 To 40
 aAdd( aMvPar, &( "MV_PAR" + StrZero( nX, 2, 0 ) ) )
Next nX

SC6->(DbSetOrder(1))
SC6->(DbSeek(xFilial('SC6') + SC5->C5_NUM))

aAdd(aParamBox, {1, "Data Entrega"			, SC6->C6_ENTREG  ,  ,'U_VDTENTR()', ,'EMPTY(SC5->C5_XDTCOL) .And. Empty(SC5->C5_XOBCOL) ', 50, .F.} )			//1
aAdd(aParamBox, {1, "Transportadora"		, SC5->C5_TRANSP , "@!" ,,'SA4' ,'EMPTY(SC5->C5_XDTCOL) .And. Empty(SC5->C5_XOBCOL) .And. U_VlPrdGfe()', 50, .F.} )	//2
//aAdd(aParamBox, {1, "Data Entrega"			, SC6->C6_ENTREG  ,  ,'U_VDTENTR()', ,, 50, .F.} )			//1
//aAdd(aParamBox, {1, "Transportadora"		, SC5->C5_TRANSP , "@!" ,,'SA4' ,, 50, .F.} )	//2
aAdd(aParamBox, {1, "Pedido Vinculado"		, SC5->C5_XPEDVIN , "@!" ,,'SC5VIN' ,, 50, .F.} )//3
aAdd(aParamBox, {1, "Mensagem Nota"			, SC5->C5_MENNOTA , "@!" ,,'' ,, 50, .F.} )//4

If ParamBox(aParamBox, 'Ajuste', aPergRet)
	UpdC5(aPergRet)
EndIf

For nX := 1 To Len( aMvPar )
 &( "MV_PAR" + StrZero( nX, 2, 0 ) ) := aMvPar[ nX ]
Next nX

Return


Static Function UpdC5(aPergRet)
If MsgYesNo("Confirma a altera��o dos campos?", "Observa��o - Daxia" )
	Reclock("SC5", .F.)	
		SC5->C5_TRANSP  	:= aPergRet[2]
        SC5->C5_XNMTRAN     := POSICIONE('SA4',1,xFilial('SA4') + aPergRet[2] ,'A4_NOME')
		SC5->C5_XPEDVIN		:= aPergRet[3]
		SC5->C5_FECENT 		:= aPergRet[1]
		SC5->C5_MENNOTA 	:= aPergRet[4]
	MsUnLock()

	SC6->(DbSetOrder(1))
	If SC6->(DbSeek(xFilial('SC6') + SC5->C5_NUM))
		While SC6->(C6_FILIAL + C6_NUM) == xFilial('SC6') + SC5->C5_NUM
			Reclock('SC6',.F.)
			SC6->C6_ENTREG := aPergRet[1]
			MsUnLock()

            SC9->(DbSetOrder(1))
            If SC9->(DbSeek(xFilial('SC9') + SC6->(C6_NUM  + C6_ITEM ) ))
                While(SC9->(C9_FILIAL+C9_PEDIDO+C9_ITEM) == xFilial('SC9')+SC6->(C6_NUM  + C6_ITEM ) )
                    If SC9->C9_PRODUTO == SC6->C6_PRODUTO
                        Reclock('SC9',.F.)
                        SC9->C9_DATENT := aPergRet[1]
                        MsUnlock()
                        SC9->(DbSkip())
                    EndIf
                EndDo
            EndIf  

			SC6->(DbSkip())

		EndDo
	EndIf
EndIf
Return

/*/{Protheus.doc} VlD
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
User Function VDTENTR()
Local lRet := .T.
Local dData := MV_PAR01

If dData < ddatabase
	lRet := .F.
	Alert('Data Invalida!')
EndIf

Return lRet


/*/{Protheus.doc} zAtuPerg
Fun��o que atualiza o conte�do de uma pergunta no X1_CNT01 / SXK / Profile
@author Atilio
@since 06/10/2016
@version 1.0
@type function
    @param cPergAux, characters, C�digo do grupo de Pergunta
    @param cParAux, characters, C�digo do par�metro
    @param xConteud, variavel, Conte�do do par�metro
    @example u_zAtuPerg("LIBAT2", "MV_PAR01", "000001")
/*/
 
User Function zAtuPerg(cPergAux, cParAux, xConteud)
    Local aArea      := GetArea()
    Local nPosCont   := 8
    Local nPosPar    := 14
    Local nLinEncont := 0
    Local aPergAux   := {}
    Default xConteud := ''
     
    //Se n�o tiver pergunta, ou n�o tiver ordem
    If Empty(cPergAux) .Or. Empty(cParAux)
        Return
    EndIf
     
    //Chama a pergunta em mem�ria
    Pergunte(cPergAux, .F., /*cTitle*/, /*lOnlyView*/, /*oDlg*/, /*lUseProf*/, @aPergAux)
     
    //Procura a posi��o do MV_PAR
    nLinEncont := aScan(aPergAux, {|x| Upper(Alltrim(x[nPosPar])) == Upper(cParAux) })
     
    //Se encontrou o par�metro
    If nLinEncont > 0
        //Caracter
        If ValType(xConteud) == 'C'
            xConteud := STRTRAN(xConteud,"'"," ")
            &(cParAux+" := '"+xConteud+"'")
         
        //Data
        ElseIf ValType(xConteud) == 'D'
            &(cParAux+" := sToD('"+dToS(xConteud)+"')")
             
        //Num�rico ou L�gico
        ElseIf ValType(xConteud) == 'N' .Or. ValType(xConteud) == 'L'
            &(cParAux+" := "+cValToChar(xConteud)+"")
         
        EndIf
         
        //Chama a rotina para salvar os par�metros
        __SaveParam(cPergAux, aPergAux)
    EndIf
     
    RestArea(aArea)
Return



 /*/{Protheus.doc} VldTransp(cTransp)
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
User Function DxVlSA4(cTransp)
LOCAL _lRet     := .T.
LOCAL aArea  := GetArea()
LOCAL _cProduto := ''
LOCAL _nQuant	:= 0
LOCAL _dEntreg	:= Stod(' ')
LOCAL _lPerigo  := .F. 													// INDICA SE O PRODUTO � PERIGOSO


SC6->(DbSetOrder(1))
If SC6->(DBSeek(SC5->C5_FILIAL + SC5->C5_NUM))
    While _lRet .And. SC6->(C6_FILIAL + C6_NUM) == SC5->(C5_FILIAL + C5_NUM)
        _cProduto   := SC6->C6_PRODUTO
        _nQuant	    := SC6->C6_QTDVEN
        _dEntreg	:= SC6->C6_ENTREG
        SB5->(DBSETORDER(1))
        IF SB5->(DBSEEK(XFILIAL("SB5")+_cProduto))
            _lPerigo := ( SB5->B5_PRODPF == "S" .OR. SB5->B5_PRODCON == "S" .OR. SB5->B5_PRODEX == "S" ) // VERIFICO SE O PRODUTO � PERIGOSO!
            
            IF _lPerigo
                DBSELECTAREA("Z00")
                // TRATAMENTO PRODUTO PERIGOSO - CONTROLE POLICIA FEDERAL
                IF SB5->B5_PRODPF  == "S" 
                    
                    IF SB5->B5_YVLLPF < _dEntreg
                        cMsgP := "N�o � permitido vender o produto " + ALLTRIM(_cProduto) + " pois a DAXIA est� com a Licen�a Vencida."
                        cMsgS := "Inicie o processo de Licenciamento do Produto: ("+ ALLTRIM(_cProduto) +")."
                        Help( ,, 'DAXATU02 (001)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
                        _lRet := .F.
                    ENDIF

                    // VERIFICAR CADASTRO DO CLIENTE
                    IF _lRet
                        DBSELECTAREA("AI0")
                        DbSetOrder(1) //AI0_FILIAL + AI0_CODCLI + AI0_LOJA
                        IF AI0->( DbSeek( xFilial("AI0")+ SC5->(C5_CLIENTE + C5_LOJACLI) ))
                            IF !( AI0->AI0_YPROPF == "S" )
                                cMsgP := "N�o � permitido vender o Produto (" + ALLTRIM(_cProduto) + "), pois o cliente n�o possui licen�a da policia federal."
                                cMsgS := "Verifique se o cliente possui Licen�a e providencie o cadastro da mesma."
                                Help( ,, 'DAXATU02 (004)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
                                _lRet := .F.
                            ENDIF
                            IF _lRet .AND. AI0->AI0_YVLLPF < _dEntreg
                                cMsgP := "N�o � permitido vender o produto " + ALLTRIM(_cProduto) + " pois a Licen�a do Cliente est� Vencida na Data da Entrega."
                                cMsgS := "Solicite a data de validade da licen�a renovada do Produto: ("+ ALLTRIM(_cProduto) +")."
                                Help( ,, 'DAXATU02 (006)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
                                _lRet := .F.
                            ENDIF
                            
                            IF _lRet .AND. Empty(AI0->AI0_YPROPF) .And. _nQuant > SB5->B5_YQTDPF
                                    cMsgP := "N�o � permitido vender esta quantidade do produto " + ALLTRIM(_cProduto) + ", o limite permitido � (" + ALLTRIM(STR(SB5->B5_YQTDPF)) + ")."
                                    cMsgS := "Escolha uma quantidade do Produto: ("+ ALLTRIM(_cProduto) +") dentro da permitida."
                                    Help( ,, 'DAXATU02 (003)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
                                    _lRet := .F.					
                            ENDIF						
                        ELSE
                            cMsgP := "N�o � permitido vender o Produto (" + ALLTRIM(_cProduto) + "), pois o cliente n�o possui licen�a da policia federal."
                            cMsgS := "Verifique se o cliente possui Licen�a e providencie o cadastro da mesma."
                            Help( ,, 'DAXATU02 (005)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
                            _lRet := .F.
                        ENDIF
                    ENDIF
                ENDIF
                // TRATAMENTO PRODUTO PERIGOSO - CONTROLE POLICIA CIVIL
                IF _lRet
                    _lRet := VlCivil(cTransp)
                EndIf	
               
                // TRATAMENTO PRODUTO PERIGOSO - CONTROLE EXERCITO 
                IF _lRet .AND. SB5->B5_PRODEX  == "S"
                    IF SB5->B5_YVLLEX < _dEntreg
                        cMsgP := "N�o � permitido vender o produto " + ALLTRIM(_cProduto) + " pois a Daxia est� com a Licen�a do Exercito Vencida."
                        cMsgS := "Regitre o processo de Licenciamento do Produto: ("+ ALLTRIM(_cProduto) +")."
                        Help( ,, 'DAXATU02 (012)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
                        _lRet := .F.
                    ENDIF
                    IF _lRet
                        DBSELECTAREA("SA1")
                        DBSETORDER(1)
                        IF  DBSEEK( XFILIAL("SA1")+ SC5->(C5_CLIENTE + C5_LOJACLI) ) 
                            
                            IF SA1->A1_PESSOA == 'F' .AND. _nQuant > 2
                                cMsgP := "N�o � permitido vender o produto " + ALLTRIM(_cProduto) + " em uma quantidade superior a 2 kilos ou 2 litros para clientes pessoa f�sica."
                                cMsgS := ""
                                Help( ,, 'DAXATU02 (013)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
                                _lRet := .F.
                            ENDIF
                        ENDIF
                        DBSELECTAREA("AI0")
                        DbSetOrder(1) //AI0_FILIAL + AI0_CODCLI + AI0_LOJA
                        IF AI0->( DbSeek( xFilial("AI0")+ SC5->(C5_CLIENTE + C5_LOJACLI) ))
                            IF _lRet .AND. !( AI0->AI0_YPROEX == "S" )
                                cMsgP := "N�o � permitido vender o Produto (" + ALLTRIM(_cProduto) + "), pois o cliente n�o possui licen�a."
                                cMsgS := "Verifique se o cliente possui Licen�a e providencie o cadastro da mesma."
                                Help( ,, 'DAXATU02 (014)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
                                _lRet := .F.
                            ENDIF
                            IF _lRet .AND. AI0->AI0_YVLLEX < _dEntreg
                                cMsgP := "N�o � permitido vender o produto " + ALLTRIM(_cProduto) + " pois a Licen�a do Cliente est� Vencida na Data da Entrega."
                                cMsgS := "Solicite a data de validade da licen�a renovada do Produto: ("+ ALLTRIM(_cProduto) +")."
                                Help( ,, 'DAXATU02 (016)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
                                _lRet := .F.
                            ENDIF
                        ELSE
                            cMsgP := "N�o � permitido vender o Produto (" + ALLTRIM(_cProduto) + "), pois o cliente n�o possui licen�a."
                            cMsgS := "Verifique se o cliente possui Licen�a e providencie o cadastro da mesma."
                            Help( ,, 'DAXATU02 (015)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
                            _lRet := .F.
                        ENDIF
                    ENDIF				
                ENDIF
                // VALIDA��O DA TRANSPORTADORA (S� ALERTA)
                IF _lRet
                    
                    dbSelectArea("SA4")
                    dbSetOrder(1)
                    IF dbSeek(xFilial("SA4")+cTransp)
                        _lExibe := .T.
                        
                        // TRATAMENTO PRODUTO PERIGOSO - CONTROLE POLICIA FEDERAL
                        IF SB5->B5_PRODPF  == "S" 
                            IF SA4->A4_YPRODPF <> "S"
                                cMsgP := "A transportadora n�o possui licen�a."
                                cMsgS := "Verifique se a transportadora possui Licen�a e providencie o cadastro da mesma."
                                Help( ,, 'DAXATU02 (017)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
                                _lExibe := .F.
                            ELSE
                                IF SA4->A4_YVLLPF < _dEntreg
                                    cMsgP := "N�o � permitido vender o produto " + ALLTRIM(_cProduto) + " pois a Transportadora est� com a Licen�a Vencida na Data da Entrega."
                                    cMsgS := "Solicite a data de validade da licen�a renovada e atualize o cadastro da Transportadora."
                                    Help( ,, 'DAXATU02 (018)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
                                    _lExibe := .F.
                                ENDIF
                            ENDIF
                        ENDIF
                        // TRATAMENTO PRODUTO PERIGOSO - CONTROLE POLICIA CIVIL

                        // TRATAMENTO PRODUTO PERIGOSO - CONTROLE EXERCITO
                        IF _lExibe .AND. SB5->B5_PRODEX  == "S"
                            IF SA4->A4_PRODEX <> "S"
                                cMsgP := "A transportadora n�o possui licen�a."
                                cMsgS := "Verifique se a transportadora possui Licen�a e providencie o cadastro da mesma."
                                Help( ,, 'DAXATU02 (021)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
                                _lExibe := .F.
                            ELSE
                                IF SA4->A4_YVLLEX < _dEntreg
                                    cMsgP := "N�o � permitido vender o produto " + ALLTRIM(_cProduto) + " pois a Transportadora est� com a Licen�a Vencida na Data da Entrega."
                                    cMsgS := "Solicite a data de validade da licen�a renovada e atualize o cadastro da Transportadora."
                                    Help( ,, 'DAXATU02 (022)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
                                    _lExibe := .F.
                                ENDIF
                            ENDIF
                        ENDIF
                    ELSE
                        // N�O TEM PREVIS�O DO QUE FAZER QUANDO N�O H� TRANSPORTADORA
                    ENDIF
                ENDIF
            ENDIF
        ENDIF
        SC6->(DBSkip())
    EndDo
EndIf

//Valida Transportadora GFE - Produtos Controlados
If _lRet .And. !U_VlPrdGfe()
    cMsgP := " Transportadora/Tabela de frete incompat�vel com o produto escolhido "
    cMsgS := " Favor alterar para continuar"
    Help( ,, 'DAXATU02 (023)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
    _lRet := .F.
EndIf


RestArea(aArea)
Return _lRet


Static Function VlCivil(cTransp)
Local _lRet := .T.
Local cRedes	:= ''
Local cCliente	:= SC5->C5_CLIENTE
Local cLoja		:= SC5->C5_LOJACLI
Local cProduto	:= SC6->C6_PRODUTO
Local _dEntreg	:= SC6->C6_ENTREG
Local cMsgP		:= ''
Local cMsgS		:= ''

SB5->(DBSETORDER(1))
IF SB5->(DBSEEK(XFILIAL("SB5")+cProduto))
	IF SB5->B5_PRODCON <> "S"
		Return .T.
	EndIf
Else
	_lRet := .F.
	Alert('Complemento de produto n�o encontrado!')	
EndIf

dbSelectArea("SA4")
dbSetOrder(1)
IF !dbSeek(xFilial("SA4")+cTransp)
	_lRet := .F.
	Alert('Transportadora n�o encontrada!')
EndIf			

DBSELECTAREA("SA1") 
DBSETORDER(1)
IF  _lRet .And. SA1->(DBSEEK( XFILIAL("SA1")+ cCliente + cLoja )) 	.And. SA1->A1_EST == 'SP' .And. (SA4->A4_EST == 'SP' .Or. 	Alltrim(cTransp)  == '000950')
	IF 	Alltrim(cTransp)  == '000950' .AND. SB5->B5_PRODCON == "S"
		cMsgP := "Este Produto � controlado pela Policia Civil, o transporte deve ser feito por Transportadora com Licen�a da Policia Civil vigente."
		cMsgS := " Altere a Transportadora ou contate a Logistica para adequa��o do cadastro" 
		Help( ,, 'VlCivil (003)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
		_lRet := .F.	
	Else
		IF  _lRet .AND. SB5->B5_PRODCON == "S"
			IF SB5->B5_YVLLPC < _dEntreg
				cMsgP := "N�o � permitido vender o produto " + ALLTRIM(cProduto) + " pois a Daxia est� com a Licen�a Vencida, contate o departamento fiscal da Daxia."
				cMsgS := "" //"Regitre o processo de Licenciamento do Produto: ("+ ALLTRIM(cProduto) +")."
				Help( ,, 'VlCivil (001)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
				_lRet := .F.
			ENDIF		
			IF _lRet .And. SA4->A4_YVLLPC < _dEntreg
				cMsgP := "Este Produto � controlado pela Policia Civil, o transporte deve ser feito por Transportadora com Licen�a da Policia Civil vigente."
				cMsgS := " Altere a Transportadora ou contate a Logistica para adequa��o do cadastro" 
				Help( ,, 'VlCivil (002)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
				_lRet := .F.
			ENDIF														
		EndIf
	EndIf
EndIF

	
Return _lRet


 /*/{Protheus.doc} VlPrdGfe
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
User Function VlPrdGfe()
Local lRet := .T.
Local cQuery := ''
Local cAliasQry := GetNextAlias()
Local cTransp   := IIF(IsInCallStack('U_DAXATU02'),MV_PAR03,MV_PAR02)
Local cMsgP     := ''
Local cMsgS     := ''

cQuery := " SELECT C6_PRODUTO"
cQuery += " FROM "+RetSQLName("SC6") + " AS SC6 " //WITH (NOLOCK)
cQuery += " INNER JOIN "+RetSQLName("SB5") + " AS SB5 ON C6_PRODUTO = B5_COD AND SB5.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
cQuery += " WHERE C6_FILIAL  = '" + SC5->C5_FILIAL + "' "
cQuery += " AND SC6.D_E_L_E_T_= ' ' "
cQuery += " AND SC6.C6_NUM = '"+ SC5->C5_NUM +"' "
cQuery += " AND SB5.B5_XCONTRO = 'S' "
//Valido os produtos do pedido

TcQuery cQuery new Alias ( cAliasQry )

(cAliasQry)->(dbGoTop())

If !(cAliasQry)->(EOF())
    SA4->(DbSetOrder(1))
    If SA4->(DbSeek(xFilial('SA4') + cTransp))
        GU3->(DbSetOrder(11))
        If GU3->(DbSeek(xFilial('GU3') + SA4->A4_CGC))
            GVA->(DbSetOrder(1))
            If GVA->(DBSeek(xFilial('GVA') + GU3->GU3_CDEMIT)) .And. GVA->GVA_XCONTR <> '1'
                lRet := .F.
            EndIf
        Else
            lRet := .F.
        EndIf
    Else
        lRet := .F.        
    EndIf
EndIf
If IsInCallStack('U_DXATUSC5') .and. !lRet
    cMsgP := " Transportadora/Tabela de frete incompat�vel com o produto escolhido "
    cMsgS := " Favor alterar para continuar"
    //Help( ,, 'DAXATU02 (023)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
    ALERT('Transportadora/Tabela de frete incompat�vel com o produto escolhido' + CRLF + "Favor alterar para continuar")
EndIf
Return lRet

#INCLUDE "PROTHEUS.CH"

User Function OM200DTR()

Local aRetTran := {}
Local cCodTran := PARAMIXB[1]//Código da Transportadora
Local cNomeTran := PARAMIXB[2]//Nome da Transportadora
Local aParamBox := {}
Local aPergRet	:= {}
Local aMvPar := {}
Local nX      := 0
Local aArea    := GetArea()

For nX := 1 To 40
    aAdd( aMvPar, &( "MV_PAR" + StrZero( nX, 2, 0 ) ) )
Next nX

aAdd(aParamBox, {1, "Transportadora"		, Criavar("A4_COD",.F.) , "@!" ,'U_OmsVLA4(MV_PAR01)','SA4' ,, 50, .F.} )	
If ParamBox(aParamBox, 'Transportadora', aPergRet,,,,,,,,.F.,.F.)
    cCodTran := aPergRet[1]
    cNomeTran := Posicione('SA4',1,xFilial('SA4') + aPergRet[1] , 'A4_NREDUZ')
EndIf
AAdd(aRetTran, cCodTran)
AAdd(aRetTran, cNomeTran)

For nX := 1 To Len( aMvPar )
    &( "MV_PAR" + StrZero( nX, 2, 0 ) ) := aMvPar[ nX ]
Next nX

RestArea(aArea)

Return(aRetTran)

 /*/{Protheus.doc} OmsVLA4()
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
User Function OmsVLA4(cTransp)
Local lRet := .T.
Local nPos  := TRBPED->(recno())
TRBPED->(dbGoTop())
While TRBPED->(!Eof()) .And. lRet
    If !empty(TRBPED->PED_MARCA)
        lRet := ValTransp(cTransp,TRBPED->PED_PEDIDO)
    EndIf
    TRBPED->(dbSkip())
EndDo

TRBPED->(DbGoTo(nPos))
Return lRet





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
Static Function ValTransp(cTransp,cPedido)
LOCAL _lRet     := .T.
LOCAL aArea  := GetArea()
LOCAL _cProduto := ''
LOCAL _nQuant	:= 0
LOCAL _dEntreg	:= Stod(' ')
LOCAL _lPerigo  := .F. 													// INDICA SE O PRODUTO  PERIGOSO

SC5->(DbSetOrder(1))
SC5->(DbSeek(xFilial('SC5') + cPedido))

SC6->(DbSetOrder(1))
If SC6->(DBSeek(SC5->C5_FILIAL + SC5->C5_NUM))
    While _lRet .And. SC6->(C6_FILIAL + C6_NUM) == SC5->(C5_FILIAL + C5_NUM)
        _cProduto   := SC6->C6_PRODUTO
        _nQuant	    := SC6->C6_QTDVEN
        _dEntreg	:= SC6->C6_ENTREG
        SB5->(DBSETORDER(1))
        IF SB5->(DBSEEK(XFILIAL("SB5")+_cProduto))
            _lPerigo := ( SB5->B5_PRODPF == "S" .OR. SB5->B5_PRODCON == "S" .OR. SB5->B5_PRODEX == "S" ) // VERIFICO SE O PRODUTO  PERIGOSO!
            
            IF _lPerigo
                DBSELECTAREA("Z00")
                // TRATAMENTO PRODUTO PERIGOSO - CONTROLE POLICIA FEDERAL
                IF SB5->B5_PRODPF  == "S" 
                    
                    IF SB5->B5_YVLLPF < _dEntreg
                        cMsgP := "Não á permitido vender o produto " + ALLTRIM(_cProduto) + " pois a DAXIA está com a Licença Vencida."
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
                                cMsgP := "Não é permitido vender o Produto (" + ALLTRIM(_cProduto) + "), pois o cliente não possui licença da policia federal."
                                cMsgS := "Verifique se o cliente possui Licença e providencie o cadastro da mesma."
                                Help( ,, 'DAXATU02 (004)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
                                _lRet := .F.
                            ENDIF
                            IF _lRet .AND. AI0->AI0_YVLLPF < _dEntreg
                                cMsgP := "Não é permitido vender o produto " + ALLTRIM(_cProduto) + " pois a Licença do Cliente está Vencida na Data da Entrega."
                                cMsgS := "Solicite a data de validade da licença renovada do Produto: ("+ ALLTRIM(_cProduto) +")."
                                Help( ,, 'DAXATU02 (006)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
                                _lRet := .F.
                            ENDIF
                            
                            IF _lRet .AND. Empty(AI0->AI0_YPROPF) .And. _nQuant > SB5->B5_YQTDPF
                                    cMsgP := "Não é permitido vender esta quantidade do produto " + ALLTRIM(_cProduto) + ", o limite permitido é (" + ALLTRIM(STR(SB5->B5_YQTDPF)) + ")."
                                    cMsgS := "Escolha uma quantidade do Produto: ("+ ALLTRIM(_cProduto) +") dentro da permitida."
                                    Help( ,, 'DAXATU02 (003)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
                                    _lRet := .F.					
                            ENDIF						
                        ELSE
                            cMsgP := "Não é permitido vender o Produto (" + ALLTRIM(_cProduto) + "), pois o cliente não possui licença da policia federal."
                            cMsgS := "Verifique se o cliente possui Licença e providencie o cadastro da mesma."
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
                        cMsgP := "Não á permitido vender o produto " + ALLTRIM(_cProduto) + " pois a Daxia está com a Licença do Exercito Vencida."
                        cMsgS := "Regitre o processo de Licenciamento do Produto: ("+ ALLTRIM(_cProduto) +")."
                        Help( ,, 'DAXATU02 (012)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
                        _lRet := .F.
                    ENDIF
                    IF _lRet
                        DBSELECTAREA("SA1")
                        DBSETORDER(1)
                        IF  DBSEEK( XFILIAL("SA1")+ SC5->(C5_CLIENTE + C5_LOJACLI) ) 
                            
                            IF SA1->A1_PESSOA == 'F' .AND. _nQuant > 2
                                cMsgP := "Não á permitido vender o produto " + ALLTRIM(_cProduto) + " em uma quantidade superior a 2 kilos ou 2 litros para clientes pessoa física."
                                cMsgS := ""
                                Help( ,, 'DAXATU02 (013)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
                                _lRet := .F.
                            ENDIF
                        ENDIF
                        DBSELECTAREA("AI0")
                        DbSetOrder(1) //AI0_FILIAL + AI0_CODCLI + AI0_LOJA
                        IF AI0->( DbSeek( xFilial("AI0")+ SC5->(C5_CLIENTE + C5_LOJACLI) ))
                            IF _lRet .AND. !( AI0->AI0_YPROEX == "S" )
                                cMsgP := "Não é permitido vender o Produto (" + ALLTRIM(_cProduto) + "), pois o cliente não possui licença."
                                cMsgS := "Verifique se o cliente possui Licença e providencie o cadastro da mesma."
                                Help( ,, 'DAXATU02 (014)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
                                _lRet := .F.
                            ENDIF
                            IF _lRet .AND. AI0->AI0_YVLLEX < _dEntreg
                                cMsgP := "Não é permitido vender o produto " + ALLTRIM(_cProduto) + " pois a Licença do Cliente está Vencida na Data da Entrega."
                                cMsgS := "Solicite a data de validade da licença renovada do Produto: ("+ ALLTRIM(_cProduto) +")."
                                Help( ,, 'DAXATU02 (016)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
                                _lRet := .F.
                            ENDIF
                        ELSE
                            cMsgP := "Não é permitido vender o Produto (" + ALLTRIM(_cProduto) + "), pois o cliente não possui licença."
                            cMsgS := "Verifique se o cliente possui Licença e providencie o cadastro da mesma."
                            Help( ,, 'DAXATU02 (015)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
                            _lRet := .F.
                        ENDIF
                    ENDIF				
                ENDIF
                // VALIDAÇÃO DA TRANSPORTADORA (SÓ ALERTA)
                IF _lRet
                    
                    dbSelectArea("SA4")
                    dbSetOrder(1)
                    IF dbSeek(xFilial("SA4")+cTransp)
                        _lExibe := .T.
                        
                        // TRATAMENTO PRODUTO PERIGOSO - CONTROLE POLICIA FEDERAL
                        IF SB5->B5_PRODPF  == "S" 
                            IF SA4->A4_YPRODPF <> "S"
                                cMsgP := "A transportadora não possui licença."
                                cMsgS := "Verifique se a transportadora possui Licença e providencie o cadastro da mesma."
                                Help( ,, 'DAXATU02 (017)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
                                _lExibe := .F.
                            ELSE
                                IF SA4->A4_YVLLPF < _dEntreg
                                    cMsgP := "Não é permitido vender o produto " + ALLTRIM(_cProduto) + " pois a Transportadora está com a Licença Vencida na Data da Entrega."
                                    cMsgS := "Solicite a data de validade da licença renovada e atualize o cadastro da Transportadora."
                                    Help( ,, 'DAXATU02 (018)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
                                    _lExibe := .F.
                                ENDIF
                            ENDIF
                        ENDIF
                        // TRATAMENTO PRODUTO PERIGOSO - CONTROLE POLICIA CIVIL

                        // TRATAMENTO PRODUTO PERIGOSO - CONTROLE EXERCITO
                        IF _lExibe .AND. SB5->B5_PRODEX  == "S"
                            IF SA4->A4_PRODEX <> "S"
                                cMsgP := "A transportadora não possui licença."
                                cMsgS := "Verifique se a transportadora possui Licença e providencie o cadastro da mesma."
                                Help( ,, 'DAXATU02 (021)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
                                _lExibe := .F.
                            ELSE
                                IF SA4->A4_YVLLEX < _dEntreg
                                    cMsgP := "Não é permitido vender o produto " + ALLTRIM(_cProduto) + " pois a Transportadora está com a Licença Vencida na Data da Entrega."
                                    cMsgS := "Solicite a data de validade da licença renovada e atualize o cadastro da Transportadora."
                                    Help( ,, 'DAXATU02 (022)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
                                    _lExibe := .F.
                                ENDIF
                            ENDIF
                        ENDIF
                    ELSE
                        // NÃO TEM PREVISÃO DO QUE FAZER QUANDO NÃO HÁ TRANSPORTADORA
                    ENDIF
                ENDIF
            ENDIF
        ENDIF
        SC6->(DBSkip())
    EndDo
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
	Alert('Complemento de produto não encontrado!')	
EndIf

dbSelectArea("SA4")
dbSetOrder(1)
IF !dbSeek(xFilial("SA4")+cTransp)
	_lRet := .F.
	Alert('Transportadora não encontrada!')
EndIf			

DBSELECTAREA("SA1") 
DBSETORDER(1)
IF  _lRet .And. SA1->(DBSEEK( XFILIAL("SA1")+ cCliente + cLoja )) 	.And. SA1->A1_EST == 'SP' .And. (SA4->A4_EST == 'SP' .Or. 	Alltrim(cTransp)  == '000950')
	IF 	Alltrim(cTransp)  == '000950' .AND. SB5->B5_PRODCON == "S"
		cMsgP := "Este Produto é controlado pela Policia Civil, o transporte deve ser feito por Transportadora com Licença da Policia Civil vigente."
		cMsgS := " Altere a Transportadora ou contate a Logistica para adequação do cadastro" 
		Help( ,, 'VlCivil (003)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
		_lRet := .F.	
	Else
		IF  _lRet .AND. SB5->B5_PRODCON == "S"
			IF SB5->B5_YVLLPC < _dEntreg
				cMsgP := "Não á permitido vender o produto " + ALLTRIM(cProduto) + " pois a Daxia está com a Licença Vencida, contate o departamento fiscal da Daxia."
				cMsgS := "" //"Regitre o processo de Licenciamento do Produto: ("+ ALLTRIM(cProduto) +")."
				Help( ,, 'VlCivil (001)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
				_lRet := .F.
			ENDIF		
			IF _lRet .And. SA4->A4_YVLLPC < _dEntreg
				cMsgP := "Este Produto é controlado pela Policia Civil, o transporte deve ser feito por Transportadora com Licença da Policia Civil vigente."
				cMsgS := " Altere a Transportadora ou contate a Logistica para adequação do cadastro" 
				Help( ,, 'VlCivil (002)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
				_lRet := .F.
			ENDIF														
		EndIf
	EndIf
EndIF

	
Return _lRet

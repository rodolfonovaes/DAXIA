#Include "TOTVS.CH" 
#Include "PROTHEUS.CH" 
User Function QP215J26()
aRet := PARAMIXB[1]
aadd(aRet,{'*ESPECIFICAO', "U_TSTPROD", 0, 2})
Return aRet


 /*/{Protheus.doc} QP215R()
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
User Function TSTPROD()
If QPK->QPK_SITOP = '2'  
    FWMsgRun(, {|oSay| IntFluig(oSay) }, "Processando", "Processando integração com o fluig...")
EndIf
Return
/*/{Protheus.doc} IntFluig
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
Static Function IntFluig(oSay)
Local aEspec := {}
Local cFile  := ''
SB1->(DbSetOrder(1))
SB1->(DbSeek(xFilial('SB1')  + QPK->QPK_PRODUT))

SB5->(DbSetOrder(1))
SB5->(DbSeek(xFilial('SB5')  + QPK->QPK_PRODUT))

SB8->(DbSetOrder(6))
SB8->(DbSeek(xFilial('SB8')  + PADR(QPK->QPK_LOTE,TAMSX3('B8_LOTECTL')[1])))

QP6->(DbSetOrder(1))
IF QP6->(DbSeek(xFilial('QE6')  +QPK->(QPK_PRODUT)))

    Aadd(aEspec,QP6->QP6_XCODET)                         //1 cEspec criar na QE6 e QP6
    Aadd(aEspec,QPK->QPK_REVI)                           //2 cRev
    Aadd(aEspec,DTOC(dDataBase))                        //3 cData
    Aadd(aEspec,QPK->QPK_PRODUT)                            //4 Produto
    Aadd(aEspec,SB1->B1_DESC)                           //5 cNomeCom
    Aadd(aEspec,SB1->B1_XNOMECO)                    //6 cProduto    ------- criar
    Aadd(aEspec,SB1->B1_XINS)                              //7 cIns
    Aadd(aEspec,SB1->B1_XDESCRI) //8 cDescricao
    Aadd(aEspec,SB1->B1_ORIGEM)                         //9 cProcedencia
    Aadd(aEspec,SB1->B1_XEMBALA)    //10cEmbalagem
    Aadd(aEspec,SB1->B1_XESTOCA)    //11cEstocagem
    Aadd(aEspec,Str(SB1->B1_PRVALID))    //12cValidade
    Aadd(aEspec,SB1->B1_XINFNUT)    //13cInfNutricional  
    Aadd(aEspec,IIF(SB5->B5_XOGM == 'S','Sim','Produto Livre de OGM'))    //14 cOgm 
    Aadd(aEspec,SB1->B1_XINFADI)    //15 cInfAdicionais  
    Aadd(aEspec,SB1->B1_XLEGISL) //16cLegislacao  
    Aadd(aEspec,SB1->B1_XFUNCIO)    //17cFuncionalidade  
    Aadd(aEspec,SB1->B1_XAPLICA)    //18cAplicacoes    
    Aadd(aEspec,SB1->B1_XOBSERV)    //19cObservacoes    

    oSay:SetText("Gerando PDF...")
    cFile := U_DXESPEC(aEspec,2)
    oSay:SetText("Enviando dados para o FLUIG...")
    U_DXWSTART(cFile, alltrim(SB1->B1_DESC) + '.PDF',QPK->QPK_PRODUT,2)
EndIf

Return 

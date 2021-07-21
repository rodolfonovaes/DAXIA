#Include "TOTVS.CH" 
#Include "PROTHEUS.CH" 
/*/{Protheus.doc} Q215FIM
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
User Function Q215GRVA()
If QEK->QEK_SITENT == '2' 
    FWMsgRun(, {|oSay| IntFluig(oSay) }, "Processando", "Processando integração com o fluig...")
EndIf
Return

Static Function IntFluig(oSay)
Local aEspec := {}
Local aArea := GetArea() //POSICIONADO NA QEK
Local cFile  := ''

SB1->(DbSetOrder(1))
SB1->(DbSeek(xFilial('SB1')  + QEK->QEK_PRODUT))

SB5->(DbSetOrder(1))
SB5->(DbSeek(xFilial('SB5')  + QEK->QEK_PRODUT))

SB8->(DbSetOrder(6))
SB8->(DbSeek(xFilial('SB8')  + PADR(QEK->QEK_LOTE,TAMSX3('B8_LOTECTL')[1])))

QE6->(DbSetOrder(1))
IF QE6->(DbSeek(xFilial('QE6')  +QEK->(QEK_PRODUT)))

    Aadd(aEspec,QE6->QE6_XCODET)    //1 cEspec criar na QE6 e QP6
    Aadd(aEspec,QEK->QEK_REVI)      //2 cRev
    Aadd(aEspec,DTOC(dDataBase))    //3 cData
    Aadd(aEspec,QEK->QEK_PRODUT)    //4 Produto
    Aadd(aEspec,SB1->B1_DESC)       //5 cNomeCom
    Aadd(aEspec,SB5->B5_XCEME)      //6 cProduto    ------- criar
    Aadd(aEspec,SB5->B5_XINS)       //7 cIns
    Aadd(aEspec,SB1->B1_XDESCRI)    //8 cDescricao
    Aadd(aEspec,SB1->B1_ORIGEM)     //9 cProcedencia    ExistCpo("SX5","S0"+M->B1_ORIGEM)
    Aadd(aEspec,SB1->B1_XEMBALA)    //10cEmbalagem
    Aadd(aEspec,SB1->B1_XESTOCA)    //11cEstocagem
    Aadd(aEspec,Alltrim(Str(SB1->B1_PRVALID)) + ' dias')   //12cValidade
    Aadd(aEspec,SB5->B5_XINUTRI)    //13cInfNutricional  
    Aadd(aEspec,IIF(SB5->B5_XOGM == 'S','Sim','Produto Livre de OGM'))    //14 cOgm  
    Aadd(aEspec,SB1->B1_XINFADI)    //15 cInfAdicionais  
    Aadd(aEspec,SB1->B1_XLEGISL)    //16cLegislacao  
    Aadd(aEspec,SB1->B1_XFUNCIO)    //17cFuncionalidade  
    Aadd(aEspec,SB1->B1_XAPLICA)    //18cAplicacoes    
    Aadd(aEspec,SB1->B1_XOBSERV)    //19cObservacoes    

    oSay:SetText("Gerando PDF...")
    cFile := U_DXESPEC(aEspec,1)
    oSay:SetText("Enviando dados para o FLUIG...")
    U_DXWSTART(cFile, alltrim(SB1->B1_DESC) + '.PDF',QEK->QEK_PRODUT,1)
EndIf

    
RestArea(aArea)

Return 
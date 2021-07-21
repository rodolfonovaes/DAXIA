#Include "TOTVS.CH" 
#Include "PROTHEUS.CH" 
/*/{Protheus.doc} QE010J1
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
User Function QE010J1()
Local nOpc  := PARAMIXB[1]

If nOpc == 4 //.And. (QE6->QE6_SITREV=='0' .OR. QE6->QE6_SITREV==' ')
    FWMsgRun(, {|oSay| IntFluig(oSay) }, "Processando", "Processando integração com o fluig...")
EndIf

Return

Static Function IntFluig(oSay)
Local aEspec := {}
Local aArea := GetArea() //POSICIONADO NA QEK
Local cFile  := ''
Local cProd := PARAMIXB[2]
Local cRev  := PARAMIXB[3]

SB1->(DbSetOrder(1))
SB1->(DbSeek(xFilial('SB1')  + cProd))

SB5->(DbSetOrder(1))
SB5->(DbSeek(xFilial('SB5')  + cProd))

SB8->(DbSetOrder(6))
SB8->(DbSeek(xFilial('SB8')  + PADR(QEK->QEK_LOTE,TAMSX3('B8_LOTECTL')[1])))


Aadd(aEspec,QE6->QE6_XCODET)                //1 cEspec criar na QE6 e QP6
Aadd(aEspec,cRev)                           //2 cRev
Aadd(aEspec,DTOC(QE6->QE6_DTINI))                //3 cData
Aadd(aEspec,cProd)                          //4 Produto
Aadd(aEspec,SB1->B1_DESC)                   //5 cNomeCom
Aadd(aEspec,SB5->B5_XCEME)                  //6 cProduto    ------- criar
Aadd(aEspec,SB5->B5_XINS)                   //7 cIns
Aadd(aEspec,SB1->B1_XDESC) //8 cDescricao
Aadd(aEspec,POSICIONE('SX5',1, xFilial('SX5') + "S0" + SB1->B1_ORIGEM, 'X5_DESCRI'))                         //9 cProcedencia ExistCpo("SX5","S0"+M->B1_ORIGEM)
Aadd(aEspec,SB1->B1_XEMBALA)    //10cEmbalagem
Aadd(aEspec,SB1->B1_XESTOCA)    //11cEstocagem
Aadd(aEspec,Alltrim(Str(SB1->B1_PRVALID)) + ' dias')   //12cValidade PEGAR DA B1 o TIPO DE PRAZO para compor
Aadd(aEspec,SB1->B1_XINFNUT)    //13cInfNutricional  
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


    
RestArea(aArea)

Return 
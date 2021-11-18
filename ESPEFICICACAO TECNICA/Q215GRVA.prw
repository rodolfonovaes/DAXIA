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

    Aadd(aEspec,QE6->QE6_XCODET)                         //1 cEspec criar na QE6 e QP6
    Aadd(aEspec,QEK->QEK_REVI)                           //2 cRev
    Aadd(aEspec,DTOC(dDataBase))                        //3 cData
    Aadd(aEspec,QEK->QEK_PRODUT)                            //4 Produto
    Aadd(aEspec,SB1->B1_DESC)                           //5 cNomeCom
    Aadd(aEspec,SB1->B1_XNOMECO)                    //6 cProduto    ------- criar
    Aadd(aEspec,SB1->B1_XINS)                              //7 cIns
    Aadd(aEspec,SB1->B1_XDESCRI)                        //8 cDescricao
    Aadd(aEspec,SB1->B1_ORIGEM)                         //9 cProcedencia
    Aadd(aEspec,SB1->B1_XEMBALA)    //10cEmbalagem
    Aadd(aEspec,SB1->B1_XESTOCA)    //11cEstocagem
    Aadd(aEspec,Alltrim(Str(SB1->B1_PRVALID)) + ' dias')    //12cValidade
    Aadd(aEspec,SB1->B1_XINFNUT)    //13cInfNutricional  
    Aadd(aEspec,IIF(SB5->B5_XOGM == 'S','Sim','Produto Livre de OGM'))    //14 cOgm  
    Aadd(aEspec,SB1->B1_XINFADI)    //15 cInfAdicionais  
    Aadd(aEspec,SB1->B1_XLEGISL)    //16cLegislacao  
    Aadd(aEspec,SB1->B1_XFUNCIO)    //17cFuncionalidade  
    Aadd(aEspec,SB5->B5_XAPLICA)    //18cAplicacoes   ALTERAR PARA B5!!!!  
    Aadd(aEspec,SB1->B1_XOBSERV)    //19cObservacoes    
    Aadd(aEspec,IIF(SB1->B1_GRUPO == '0002',SB5->B5_XINCNAM,'Não Aplicavel'))    //20 INC NAME
    Aadd(aEspec,IIF(SB1->B1_GRUPO == '0002',SB5->B5_XCAS,'Não Aplicavel'))       //21 CAS
    Aadd(aEspec,SB5->B5_XCOMPOS)       //22 COMPOSICAO
    Aadd(aEspec,U_zCmbDesc(SB1->B1_XORIG,'B1_XORIG'))       //23 ORIGEM
    Aadd(aEspec,SB1->B1_XPAIS)       //24 PAIS
    Aadd(aEspec,SB5->B5_XMICRO)       //25 MICROBIOLOGICAS
    Aadd(aEspec,SB5->B5_XNUTRI)       //26 info nutricional
    Aadd(aEspec,IIF(SB5->B5_XOGM == 'S',SB5->B5_XOOGM,'Não Aplicavel'))       //27 Origem OGM
    Aadd(aEspec,SB5->B5_XMANIP)       //28 Manipulacao 

    oSay:SetText("Gerando PDF...")
    cFile := U_DXESPEC(aEspec,1)
    oSay:SetText("Enviando dados para o FLUIG...")
    U_DXWSTART(cFile, alltrim(SB1->B1_DESC) + '.PDF',QEK->QEK_PRODUT,1)
EndIf

    
RestArea(aArea)

Return 
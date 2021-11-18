#Include "TOTVS.CH" 
#Include "PROTHEUS.CH" 
 /*/{Protheus.doc} QP010J11()
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
User Function QP010J11()
If ALTERA
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
Local aArea := GetArea()


If MsgYesNo('Houve uma alteração na especificação e será disparado um e-mail com a nova especificação para os clientes.' + CRLF + 'Deseja continuar?', 'Envio de especificação tecnica')
    If !MsgYesNo('Confirma o envio?', 'Envio de especificação tecnica')
        RestArea(aArea)
        Return    
    EndIf
Else
    RestArea(aArea)
    Return
EndIf

SB1->(DbSetOrder(1))
SB1->(DbSeek(xFilial('SB1')  + QP6->QP6_PRODUT))

SB5->(DbSetOrder(1))
SB5->(DbSeek(xFilial('SB5')  + QP6->QP6_PRODUT))

SB8->(DbSetOrder(6))
SB8->(DbSeek(xFilial('SB8')  + PADR(QPK->QPK_LOTE,TAMSX3('B8_LOTECTL')[1])))

Aadd(aEspec,Alltrim(QP6->QP6_XCODET) + '-REV-' + Alltrim(QP6->QP6_REVI))                         //1 cEspec criar na QE6 e QP6
Aadd(aEspec,QP6->QP6_REVI)                           //2 cRev
Aadd(aEspec,DTOC(dDataBase))                        //3 cData
Aadd(aEspec,QP6->QP6_PRODUT)                            //4 Produto
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
cFile := U_DXESPEC(aEspec,2)
oSay:SetText("Enviando dados para o FLUIG...")
U_DXWSTART(cFile, alltrim(SB1->B1_DESC) + '.PDF',QPK->QPK_PRODUT,2)

RestArea(aArea)
Return 

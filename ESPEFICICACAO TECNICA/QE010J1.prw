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

If SB1->B1_MSBLQL == '1' .Or. !MsgYesNo('Houve uma alteração na especificação e será gerado um novo pdf que sera enviado ao fluig.' + CRLF + 'Deseja continuar?', 'Envio de especificação tecnica')
    RestArea(aArea)
    Return
EndIf



Aadd(aEspec, Alltrim(QE6->QE6_XCODET) + '-REV-' + Alltrim(cRev))                         //1 cEspec criar na QE6 e QP6
Aadd(aEspec,cRev)                           //2 cRev
Aadd(aEspec,DTOC(dDataBase))                        //3 cData
Aadd(aEspec,cProd)                            //4 Produto
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
Aadd(aEspec,SB5->B5_MICRMAC)       //29 Micro Macro
Aadd(aEspec,SB5->B5_CONTAMI)       //30 Contamina

oSay:SetText("Gerando PDF...")
cFile := U_DXESPEC(aEspec,1)
oSay:SetText("Enviando dados para o FLUIG...")
U_DXWSTART(cFile, alltrim(SB1->B1_COD) + '-' +alltrim(SB1->B1_DESC) + '-REV-' + Alltrim(cRev) + '.PDF',cProd,1)


    
RestArea(aArea)

Return 

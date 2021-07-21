#Include "TOTVS.CH"
#Include "PROTHEUS.CH"
#INCLUDE "QNCA040.CH"
 /*/{Protheus.doc} QN040VLD
    Inclusao de justificativa para quando for um cancelamento
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
User Function QN040VLD
Local lRet := .T.
Local oDlg			:= NIL
Local oTexto		:= NIL
Local oFontMet		:= TFont():New("Courier New",6,0)
Local cCodFNC		:= ""
Local cTexto		:= ""    

If (INCLUI .OR. ALTERA) .And. M->QI2_STATUS == "5" 
    //Tela do Motivo de Nao Procede
    cCodFNC := M->QI2_FNC+"  "+STR0020+M->QI2_REV //"Revisao: "
    
    DEFINE MSDIALOG oDlg FROM 62,100 TO 320,610 TITLE "Justificativa da classificação Cancelado" PIXEL //"Justificativa da classificação Não-Procede"

    @ 003, 004 TO 027, 250 LABEL STR0019 OF oDlg PIXEL //"Ficha N.C.: "
    @ 040, 004 TO 110, 250 OF oDlg PIXEL

    @ 013, 010 MSGET cCodFNC WHEN .F. SIZE 185, 010 OF oDlg PIXEL

    @ 050, 010 GET oTexto VAR cTexto MEMO NO VSCROLL SIZE 238, 051 OF oDlg PIXEL
        
    oTexto:SetFont(oFontMet)

    DEFINE SBUTTON FROM 115,190 TYPE 1 ACTION (nOpca := 1,oDlg:End()) ENABLE OF oDlg
    DEFINE SBUTTON FROM 115,220 TYPE 2 ACTION (nOpca := 2,oDlg:End()) ENABLE OF oDlg
    
    ACTIVATE MSDIALOG oDlg CENTERED
    
    cMotivo := Iif(nOpca = 1,cTexto,"")
    
    If Empty(cMotivo) // Verifica se a justificativa foi preenchida
        Alert("É necessário informar a justificativa para a classificação Cancelado.") 
        lRet := .F.
    ELSE
        RecLock("QI2",.F.)
            M->QI2_MEMO5 := cMotivo
        MsUnlock()
    Endif
Endif
Return lRet
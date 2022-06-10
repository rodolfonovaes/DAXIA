#INCLUDE "PROTHEUS.CH"
/*/{Protheus.doc}  MTA450R
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
User Function  MTA450R()
Local aArea := GetArea()

Reclock("SC9",.F.)
// Log de Atualização
// xxxxxx.xxxxx;99/99/9999;99:99;99;xxxxx;99
// <<usuário>>;<<data>>;<<hora>>;<<funçao>>;<<valor novo>>
SC9->C9_XLOGCRE := UsrRetName( retcodusr() ) + ";" + DTOC(dDataBase) + ";" + Time()  + ";" + FUNNAME() + ";" + SC9->C9_BLCRED
SC9->(MsUnLock())


Reclock('SC5',.F.)
SC5->C5_XBLWMS  := SC9->C9_BLWMS
SC5->C5_BLEST   := SC9->C9_BLEST
SC5->C5_BLCRED  := SC9->C9_BLCRED
SC5->C5_XLOGCRE := UsrRetName( retcodusr() ) + ";" + DTOC(dDataBase) + ";" + Time()  + ";" + FUNNAME() + ";" + SC9->C9_BLCRED
MsUnlock()

SA1->(DbSetOrder(1))
If SA1->(DbSeek(xFilial('SA1') + SC5->(C5_CLIENTE + C5_LOJACLI)))
    RecLock('SA1', .F.)
    SA1->A1_SALPEDL := SC5->C5_XVLTOT
    MsUnlock()
EndIf


RestArea(aArea)
Return 

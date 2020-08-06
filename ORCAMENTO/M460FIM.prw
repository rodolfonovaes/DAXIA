#INCLUDE "PROTHEUS.CH"
/*/{Protheus.doc}  M460FIM
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
User Function  M460FIM()

Reclock('SC5',.F.)
SC5->C5_XBLWMS  := SC9->C9_BLWMS
SC5->C5_BLEST   := SC9->C9_BLEST
SC5->C5_BLCRED  := SC9->C9_BLCRED
MsUnlock()
Return 
 /*/{Protheus.doc} GFEA1181
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
User Function GFEA1181()
RecLock('GXG', .F.)
GXG->GXG_EMISDF :=  PADL(GXG->GXG_EMISDF,9,"0") 
MsUnlock()
Return 

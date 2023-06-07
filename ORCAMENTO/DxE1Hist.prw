#include "protheus.ch"
 /*/{Protheus.doc} DxE1Hist
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
User Function DxE1Hist()
Return Alltrim(SE1->E1_HIST)//Posicione('SE1',1, SE1->(E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO),'E1_HIST')

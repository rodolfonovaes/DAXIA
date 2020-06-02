 /*/{Protheus.doc} axcadz5
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
 User Function axcadz5()
 AxCadastro('SZ5','Frete por transportadora')
Return


User Function VlSZ5()
Local lRet := .T.

SZ5->(DbSetOrder(1))
If SZ5->(DbSeek(xFilial('SZ5') + M->Z5_CODFIL + M->Z5_TRANSP))
   Alert('Ja existe cadastro para essa filial!')
   lRet := .F.
EndIf

Return lRet
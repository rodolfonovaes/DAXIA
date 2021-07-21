/*/{Protheus.doc} MT103CWH
    edição do when do documento de entrada
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
User Function MT103CWH()
Local lRet := .T.
Local cCampo := PARAMIXB[1]
Local cConteudo := PARAMIXB[2]

If cCampo == 'F1_EMISSAO' .And. cFormul == 'S'
    lRet := .F.
    dDEmissao := dDataBase
Endif 

Return lRet
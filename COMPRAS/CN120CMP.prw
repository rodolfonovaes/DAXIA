
/*{Protheus.doc} CN120CMP()
    Tem por finalidade adicionar campos customizados à consulta especifica do contrato de Medição
*/
User Function CN120CMP()
    Local aRet  := {PARAMIXB[1], PARAMIXB[2]}
    Local cCampo:= "CN9_XDESCR"
 
    aAdd(aRet[1], GetSx3Cache( cCampo, "X3_TITULO" ) )
    aAdd(aRet[2], { cCampo, GetSx3Cache( cCampo, "X3_TIPO" ), GetSx3Cache( cCampo, "X3_CONTEXT" ), GetSx3Cache( cCampo, "X3_PICTURE" ) })
Return aRet
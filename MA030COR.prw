 /*/{Protheus.doc} MA030COR
    Ponto de Entrada para legendas no cadastro do cliente
    @type  User Function
    @author B. Vinicius
    @since 19/08/2019
/*/
User Function MA030COR()

Local aRet := {}

aAdd( aRet , { "SA1->A1_XSITUA == '1' "	, "GREEN"	, "Ativo" })
aAdd( aRet , { "SA1->A1_XSITUA == '2' "	, "BLUE"	, "Ativo sem movimento"})
aAdd( aRet , { "SA1->A1_XSITUA =='3' "	, "RED"	, "Encerrado"})

Return aRet
/*/{Protheus.doc} MTA455NL()
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
User Function MTA455NL()
Local cChave := SC9->(C9_FILIAL + C9_PEDIDO + C9_ITEM + C9_SEQUEN + C9_PRODUTO)
Local nQtdLib   := SC9->C9_QTDLIB
Local aArea := GetArea()

SC9->(DbSetOrder(1))
If SC9->(DbSeek(cChave)) //tive que fazer o seek novamente pq por algum motivo estava posicionado numa c9 q estava apagada 
    If Type('_cLibCred') == 'C' .And. SC9->C9_BLCRED <> _cLibCred
        a450Grava(1,.T.,.F.)

		// Integrado ao wms devera avaliar as regras para convocação do serviço
		// e disponibilizar os registros de atividades do WMS para convocação
		If IntWms()
			WmsAvalExe()
		EndIf
                
    EndIf
EndIf

RestArea(aArea)
Return
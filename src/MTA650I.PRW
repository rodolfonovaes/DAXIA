#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} MTA650I
Ponto de Entrada apos gerar inclusao de OP
@type function
@author B. Vinicius
@since 12/10/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/User Function MTA650I()

Local aArea := GetArea()

If Reclock("SC2",.F.)

    C2_XLOTE := NextLote()

    SC2->(MsUnLock())

Endif

RestArea(aArea)

Return
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

QPK->(DbSetOrder(1))
If QPK->(DbSeek(xFilial('QPK') + SC2->(C2_NUM + C2_ITEM + C2_SEQUEN)))
    RecLock('QPK', .F.)
    QPK->QPK_LOTE := SC2->C2_XLOTE
    MsUnlock()
EndIf
RestArea(aArea)

Return


#Include "Protheus.CH"

User function ARQPROD()

	Local aArea := GetArea()

	If IsInCallStack('MATA410')
		CONOUT("-----TESTESBZ------")
		CONOUT("FILIAL POSICIONADA: " + xFilial("SBZ"))
        CONOUT("PEDIDO: " + SC5->C5_NUM) 
		If SC5->C5_FILIAL <> xFilial("SBZ")
			CONOUT("-----DIVERGENCIA DE FILIAL----")
			CONOUT("SC5->C5_FILIAL " + SC5->C5_FILIAL)
			CONOUT("xFilial('SBZ') " + xFilial("SBZ"))
            CONOUT("PRODUTO SBZ "+ SBZ->BZ_COD)
            CONOUT("BZ_CTRWMS " + SBZ->BZ_CTRWMS)
		Endif
	Endif
	RestArea( aArea )

Return( Nil )

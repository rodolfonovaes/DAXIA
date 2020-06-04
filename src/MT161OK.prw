#Include 'Protheus.ch'

User Function MT161OK()
Local aPropostas    := PARAMIXB[1] // Array contendo todos os dados da proposta da cotação
Local cTpDoc        := PARAMIXB[2] // Tipo do documento
Local lContinua := .F.
Local n             := 0
Local nPag          := 0
Local nRecno        := 0
Local aParamBox := {}
Local aPergRet	:= {}
Local aArea     := GetArea()

For nPag := 1 to len(aPropostas)
    For n := 1 to Len(aPropostas[nPag])
        If aPropostas[nPag][n][2][1][1]
            nRecno  := aPropostas[nPag][n][2][1][9]
            Exit
        EndIf
    Next
Next

If _nDaxNumProp <> nRecno
    aAdd(aParamBox, {11	, "Motivo"					, SC8->C8_MOTIVO, ,,.F.} )
    If ParamBox(aParamBox, 'Ajuste', aPergRet)
        SC8->(DbGoTo(nRecno))
        lContinua   := UpdObs(aPergRet)
    EndIf
Else
    lContinua   := .T.
EndIf

RestArea(aArea)
Return (lContinua)

//
//
Static Function UpdObs(aPergRet)
Local lRet := .F.
If MsgYesNo("Confirma a alteração dos campos?", "Motivo - Daxia" )
	Reclock("SC8", .F.)
	SC8->C8_MOTIVO  	:= aPergRet[1]
	MsUnLock()
    lRet := .T.
Else
    lRet    := .F.
EndIf
Return
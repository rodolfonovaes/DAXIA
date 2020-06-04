#INCLUDE "PROTHEUS.CH"
User Function FERNANDA()
Local aParam      := {}
Local aRet        := {}
Local nImc		  := 0

aAdd(aParam, {1, "Altura"   	, SC5->C5_PESOL  ,  ,, ,, 60, .F.} )
aAdd(aParam, {1, "Peso"   		, SC5->C5_PESOL ,  ,, ,, 60, .F.} )

If ParamBox(aParam,'Parâmetros',aRet)
    nImc := aRet[2] / (aRet[1] * aRet[1])

    MsgAlert('Seu IMC é ' + Str(nImc) , 'Resultado')

    If nImc > 24.9
        MsgAlert('GORDO')
    EndIf

    If nImc < 18.5
        MsgAlert('MAGRO')
    EndIf
EndIf

Return

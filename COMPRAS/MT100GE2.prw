#Include 'PROTHEUS.CH'
#Include 'FWMVCDEF.CH'
#Include 'RWMAKE.CH'
#Include 'FONT.CH'
#Include 'COLORS.CH'
#Include 'TBICONN.CH'
#Include "topconn.ch"
#Include "fileio.ch"

/*
MT100GE2
Ponto de entrada na inclusao do documeto de entrada onde irá gravar a mensagem informada na nota (F1_MENNOTA) no historico do(s) titulo(s) (E2_HIST).

@author 	Rossana Barbosa
@since		10/08/2019
@version 	1.0
*/

User Function MT100GE2

	Local 	a_AreaATU   := GetArea()
	Local 	a_AreaSE2   := SE2->(GetArea())
	Local 	c_UpdQuery  := ""
	Local 	cChave 		:= SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA
	Local 	cMenNota	:= ''
	Private c_Hist      := ""
	Private c_Prefixo   := ""
	Private c_Num       := ""
	Private c_Parcela   := ""
	Private c_Tipo      := ""
	Private c_Fornece   := ""
	Private c_Loja      := ""

	SD1->(DbSetOrder(1))
	SD1->(DbSeek(xFilial('SD1') + cChave))
    Do While SD1->(!EOF()) .AND. cChave == SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
        If !Empty(SD1->D1_PEDIDO)
            SC7->(DbSetOrder(1))
            If SC7->(DbSeek(xFilial('SD1') + SD1->(D1_PEDIDO + D1_ITEMPC)))
                If !Alltrim(SC7->C7_OBSM) $ cMenNota
                    If !Empty(cMenNota)
                        cMenNota += ' | '
                    EndIf
                    cMenNota += Alltrim(SC7->C7_OBSM)
                EndIf
            EndIf
        EndIf	
        SD1->(DbSkip())
    EndDo	

	IF Alltrim(SE2->E2_TIPO) == 'NF' .And. (Alltrim(SE2->E2_PARCELA) == '1' .Or. Empty(SE2->E2_PARCELA)) 
		If Empty(SF1->F1_MENNOTA)
    		GPShowMemo(PADR(cMenNota,TAMSX3('F1_MENNOTA')[1]))
		Else
			GPShowMemo(PADR(SF1->F1_MENNOTA,TAMSX3('F1_MENNOTA')[1]))
		EndIf
	EndIf

	DbSelectArea("SF1")
	c_Hist := SF1->F1_MENNOTA
	//Alert('MT100GE2 - passou aqui  ' +  SE2->E2_NUM  )
	DbSelectArea("SE2")
	Reclock("SE2",.F.)
	SE2->E2_HIST := c_Hist
	MsUnLock()

	//Atualiza com o mesmo cento de custo do PAI os titulos FILHOS (Taxas - Retencoes dos Impostos)
	c_Prefixo	:= SE2->E2_PREFIXO
	c_Num		:= SE2->E2_NUM
	c_Parcela	:= SE2->E2_PARCELA
	c_Tipo		:= SE2->E2_TIPO
	c_Fornece	:= SE2->E2_FORNECE
	c_Loja		:= SE2->E2_LOJA

	c_Chave := c_Prefixo+c_Num+c_Parcela+c_Tipo+c_Fornece+c_Loja

	DbSelectArea("SE2")
	DbSetOrder(1)
	DbGoTop()
	c_UpdQuery := " UPDATE " + RetSqlName("SE2") + " SET E2_HIST = '" + c_Hist + "'"
	c_UpdQuery += " WHERE D_E_L_E_T_ = '' "
	c_UpdQuery += " AND E2_PREFIXO = '" + c_Prefixo + "'"
	c_UpdQuery += " AND E2_NUM = '" + c_Num + "'"
	c_UpdQuery += " AND E2_HIST = '' "
	c_UpdQuery += " AND E2_TITPAI = '" + c_Chave + "'"

	TcSqlExec(c_UpdQuery)

	RestArea(a_AreaATU)
	RestArea(a_AreaSE2)

Return Nil




/*/{Protheus.doc} GPShowMemo
Apresenta dialog para digitar a observação.
@author Leandro Prado
@since 22/12/2015
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GPShowMemo(cMemo)

	Local aParam	:= {}
	Local aRet		:= {}

	aAdd(aParam, {1, "Msg Nota"			, cMemo  ,  ,, ,, 120, .F.} )			//1 
	
	If ParamBox(aParam, 'Msg Nota', aRet,,,,,,,,.F.,.F.)
		UpdObs(aRet[1])
	EndIf

Return

/*/{Protheus.doc} UpdObs
Grava a informação no campo.
@author Leandro Prado
@since 22/12/2015
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function UpdObs(cMemo)
If MsgYesNo("Confirma a alteração da observação?", "Observação - Documento de Entrada" )
	RecLock('SF1',.F.)
	SF1->F1_MENNOTA := cMemo
	MsUnlock()
EndIf
Return
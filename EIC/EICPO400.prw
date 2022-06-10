/*/{Protheus.doc} EICPO400
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
xUser Function EICPO400
Local aArea := GetArea()
Local cParam := ''
Local aCampos := {}
Local nI	  := 0
Local bCampo     := {|x| FieldName(x)}

If ValType(ParamIXB) == "A"
 	cParam := ParamIXB[1]
Else
  	cParam := ParamIXB
EndIf

If cParam == "DEPOIS_ALTERA_INC_PO"
	SWH->(DbSetOrder(1))
    If SWH->(DbSeek(xFilial('SWH') + M->W2_PO_NUM))
          //Copio a SWH para uma tabela auxiliar
        While(xFilial('SWH') + M->W2_PO_NUM == SWH->(WH_FILIAL + WH_PO_NUM))
            for nI := 1 to SWH->(Fcount())
                Aadd(aCampos,{'ZH_' + SUBSTR(SWH->(FieldName(nI)),4,Len(SWH->(FieldName(nI)))),SWH->&(Eval(bCampo, nI))})
            next

            SX3->(dbSetOrder(2))
            Reclock('SZH',.T.)
            For nI := 1 To Len(aCampos)
                If SX3->(DbSeek(aCampos[nI,1]))
                    SZH->&(aCampos[nI,1]) := aCampos[nI,2]
                EndIf
            Next
            MsUnlock()    
            SWH->(DbSkip())
        EndDo
    EndIf
EndIf

restarea(aArea)

Return .T.

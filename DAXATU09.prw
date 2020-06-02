#INCLUDE "PROTHEUS.CH"
/*/{Protheus.doc} DAXATU09
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
User Function DAXATU09()
local dData := dDatabase
Local aParamBox := {}
Local aPergRet	:= {}
aAdd(aParamBox, {1, "Data Inicio"			, dDatabase  ,  ,, ,, 50, .F.} )			//1
aAdd(aParamBox, {1, "Data Fim"  			, dDatabase ,  ,, ,, 50, .F.} )		//2

If ParamBox(aParamBox, 'cria calendario', aPergRet)
    dData := aPergRet[1]

    SZF->(DbSetOrder(1))
    While dData <= aPergRet[2]
        If !SZF->(DbSeek(xFilial('SZF') + DTOS(dData)))
            Reclock('SZF',.T.)
            SZF->ZF_FILIAL := xFilial('SZF')
            SZF->ZF_DATA    := dData
            If DOW(dData) == 7 .Or. DOW(dData) == 1 
                SZF->ZF_TIPO := '1'
            Else
                SZF->ZF_TIPO := '2'
            EndIf
            MsUnlock()
        EndIf
        dData++
    EndDo
    MsgInfo('Processamento finalizado!')
EndIf
Return 


/*/{Protheus.doc} AXCADZF
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
User Function AXCADZF()
AxCadastro('SZF','Calendario Daxia')
Return 
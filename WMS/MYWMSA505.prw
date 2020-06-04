#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "WMSA505.CH"

 /*/{Protheus.doc} WMSA505
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
User Function XMSA505
Local aParam := PARAMIXB
Local oModel := aParam[1]
Local xRet   := .T.

If aParam[2] == 'FORMPRE' .And. aParam[5] == 'D4_ENDDES'
    //aParam[6] := 'WIP'
   // oModel:GetModel('PKGMASTER'):SETVALUE('D4_ENDDES','WIP')
ElseIf aParam[2] == 'MODELPRE' 
    oModel:GetModel('PKGMASTER'):LOADVALUE('D4_ENDDES','WIP')
EndIf

Return xRet
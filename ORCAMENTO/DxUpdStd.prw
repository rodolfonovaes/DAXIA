#INCLUDE "TOTVS.CH"
#Include "HBUTTON.CH"
#include "rwmake.ch"
 /*/{Protheus.doc} DxUpdStd()
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
User Function DxUpdStd()
Local nRet := 0
Local nX    := 0
Local nLInha := 0
Local oModel := FWModelActive()	
Local oSBZ := oModel:GetModel("SBZDETAIL")
Local nCusto := oSBZ:GetValue("BZ_CUSTD")
Local nRet   := nCusto
Local oView := FWViewActive()

If oSBZ:GetValue("BZ_FILIAL") == '0103'
    nLinha := oSBZ:GetLine()
    For nX := 1 to oSBZ:Length()
        oSBZ:GoLine(nX)
        If oSBZ:GetValue("BZ_FILIAL") == '0102'
            If oSBZ:GetValue("BZ_MCUSTD")  == '1'
                nCusto := nRet + SuperGetMV('ES_CUSADDR',.F.,0.13,'0102')
            Else
                nCusto := nRet + SuperGetMV('ES_CUSADDD',.F.,0.025,'0102')
            EndIF
            oSBZ:LoadValue('BZ_CUSTD', nCusto)
        EndIf

        If oSBZ:GetValue("BZ_FILIAL") == '0104'
            If oSBZ:GetValue("BZ_MCUSTD")  == '1'
                nCusto := nRet + SuperGetMV('ES_CUSADDR',.F.,0.30,'0104')
            Else
                nCusto := nRet + SuperGetMV('ES_CUSADDD',.F.,0.06,'0104')
            EndIF
            oSBZ:LoadValue('BZ_CUSTD', nCusto)
        EndIf        
    Next
    oSBZ:GoLine(nLinha)
    If oView <> NIL
        oView:Refresh()
    EndIf    
EndIf
Return nRet

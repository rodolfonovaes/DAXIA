#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"

 /*/{Protheus.doc} WMSA332A
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
User Function WMSA332A
Local aParam := PARAMIXB
Local oModel := aParam[1]
Local xRet   := .T.
Local oMdl := FwModelActive()
Local dDVldSB8	 := dDataBase
Local dDFabSB8	 := dDataBase
Local cLotForn	 := ''
Local cNomFabr	 := ''
Local cPaisOri	 := ''
Local cXCFABRI	 := ''
Local cXLFABRI	 := ''
Local cCliFor    := ''
Local cLoja      := ''
Local cXDProd    := ''

If aParam[2] == 'FORMLINEPOS' 
    SB8->(DbSetOrder(3))
    If SB8->(DbSeek(xFilial('SB8') + PADR(oMdl:GetModel("D12MASTER"):GetValue("D12_PRODUT"),TAMSX3('B8_PRODUTO')[1]) + oMdl:GetModel("D12MASTER"):GetValue("D12_LOCORI")  + PADR(oMdl:GetModel("D12MASTER"):GetValue("D12_LOTECT"),TAMSX3('B8_LOTECTL')[1]) ))
        dDVldSB8 := SB8->B8_DTVALID
        dDFabSB8 := SB8->B8_DFABRIC
        cLotForn := SB8->B8_LOTEFOR
        cNomFabr := SB8->B8_NFABRIC
        cPaisOri := SB8->B8_XPAISOR
        cXCFABRI := SB8->B8_XCFABRI
        cXLFABRI := SB8->B8_XLFABRI
        cCliFor  := SB8->B8_CLIFOR
        cLoja    := SB8->B8_LOJA
        cXDProd  := SB8->B8_XDPROD

        If SB8->(DbSeek(xFilial('SB8') + PADR(oMdl:GetModel("D12MASTER"):GetValue("D12_PRODUT"),TAMSX3('B8_PRODUTO')[1]) + oMdl:GetModel("D12MASTER"):GetValue("D12_LOCDES")  + PADR(oMdl:GetModel("D12MASTER"):GetValue("D12_LOTECT"),TAMSX3('B8_LOTECTL')[1]) ))
            Reclock('SB8',.F.)
            Replace SB8->B8_DTVALID With dDVldSB8
            Replace SB8->B8_DFABRIC With dDFabSB8
            Replace SB8->B8_NFABRIC With cNomFabr
            Replace SB8->B8_LOTEFOR With cLotForn 
            Replace SB8->B8_XPAISOR With cPaisOri
            Replace SB8->B8_XCFABRI With cXCFABRI
            Replace SB8->B8_XLFABRI With cXLFABRI			
            Replace SB8->B8_CLIFOR  With cCliFor
            Replace SB8->B8_LOJA    With cLoja
            Replace SB8->B8_XDPROD  With cXDProd        		
            Msunlock()
        Else
           // Alert('B8 de destino não encontrada!')
        EndIf
    Else
        //Alert('B8 de origem não encontrada!')
    EndIf
EndIf

Return xRet
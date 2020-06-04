/*/{Protheus.doc} DV030EN1()
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
User Function DV030EN1()
Local cRet := PARAMIXB
Local aArea := GetArea()
Local cSegSepara  := SuperGetMV('ES_SERVSEP',.T.,'025',cFilAnt)

//D12->(dbGoTo(nRecnoD12))
If D12->D12_SERVIC == cSegSepara
    D14->(DbSetOrder(1)) //D14_FILIAL+D14_LOCAL+D14_ENDER+D14_PRDORI+D14_PRODUT+D14_LOTECT+D14_NUMLOT+D14_NUMSER+D14_IDUNIT
    If D14->(DbSeek(xFilial('D14') + D12->(D12_LOCORI + D12_ENDORI + D12_PRODUT + D12_PRODUT + D12_LOTECT)))
        RecLock('D14',.F.)
        D14->D14_QTDEMP := D14->D14_QTDEMP - D12->D12_QTDMOV
        D14->D14_QTDEM2 := D14->D14_QTDEM2 - D12->D12_QTDMO2 
        D14->D14_QTDSPR := D14->D14_QTDSPR + D12->D12_QTDMOV
        D14->D14_QTDSP2 := D14->D14_QTDSP2 + D12->D12_QTDMO2
        D14->D14_QTDPEM := D14->D14_QTDPEM + D12->D12_QTDMOV
        D14->D14_QTDPE2 := D14->D14_QTDPE2 + D12->D12_QTDMO2
        MsUnlock()
    EndIf
EndIf

Return cRet
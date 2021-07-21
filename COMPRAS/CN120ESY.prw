User Function CN120ESY()
Local cQuery := Paramixb[1]
Local nPos   := 0
Local nPosU   := 0
Local cRet   := ''
nPos := At('FROM',cQuery)
cRet := SubStr(cQuery,1,nPos - 1) + ',CN9_XDESCR ' + SubStr(cQuery,nPos - 1, len(cQuery))

nPosU := At('UNION',cRet)
cRet := SubStr(cRet,1,nPosU - 1) + ',CN9_XDESCR ' + SubStr(cRet,nPosU - 1, len(cRet))

nPos := At('FROM',cRet,nPosU)
cRet := SubStr(cRet,1,nPos - 1) + ',CN9_XDESCR ' + SubStr(cRet,nPos - 1, len(cRet))

nPos := At('ORDER',cRet,nPosU)
cRet := SubStr(cRet,1,nPos - 1) + ',CN9_XDESCR ' + SubStr(cRet,nPos - 1, len(cRet))

Return cRet
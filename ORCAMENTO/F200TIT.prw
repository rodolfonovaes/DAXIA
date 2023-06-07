#include 'protheus.ch'

/*
Gravação de centro de custo na leitura do cnab
*/
User Function F200TIT()
Local lGrava := .F.
Local cCc	 := Separa(SuperGetMV('ES_200TIT',.t.,''),'|')[1]
Local cItem	 := Separa(SuperGetMV('ES_200TIT',.t.,''),'|')[2]
Local cClVldb:= Separa(SuperGetMV('ES_200TIT',.t.,''),'|')[3]
If SE5->E5_BANCO == '237'    //BRADESCO
	If AllTrim(SE5->E5_CONTA) == '1809' .And. SE5->E5_CNABOC $ '02|10|12|14|08|9F|21|19|30|14'
		lGrava := .T.
	ElseIf AllTrim(SE5->E5_CONTA) == '41554' .And. SE5->E5_CNABOC $ '02|10|12|14|08|9F|21|19|30|14'
		lGrava := .T.
	EndIf
ElseIf	SE5->E5_BANCO == '001'    // BANCO DO BRASIL
	If AllTrim(SE5->E5_CONTA) == '11615' .And. SE5->E5_CNABOC $ '02|09|10|12|14|9F|34|25|29|31|33'
		lGrava := .T.
	EndIf
ElseIf	SE5->E5_BANCO == '341'    // ITAU
	If AllTrim(SE5->E5_CONTA) == '43360' .And. SE5->E5_CNABOC $ '06|02|04|05|06|08|09|12|14|9F|21|26|29|32|33|34|35|26'
		lGrava := .T.
	ElseIf AllTrim(SE5->E5_CONTA) == '07581' .And. SE5->E5_CNABOC $ '06|02|04|05|06|08|09|12|14|9F|21|26|29|32|33|34'
		lGrava := .T.
	EndIf	
ElseIf	SE5->E5_BANCO == '033'    // SANTANDER
	If AllTrim(SE5->E5_CONTA) == '13008142' .And. SE5->E5_CNABOC $ '02|10|12|14|23|08|21|33|19|03'
		lGrava := .T.
	EndIf		
EndIf

If lGrava
	RecLock("SE5",.F.)
	Replace SE5->E5_CCUSTO With cCc
	Replace SE5->E5_ITEMD  With cItem
	Replace SE5->E5_CLVLDB With cClVldb
	SE5->(MsUnlock())
EndIf		
Return

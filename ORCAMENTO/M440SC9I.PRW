#Include "Protheus.CH"

//Rotina para gravar os campos na SC9: Nome do Cliente, Nome do usuário que liberou, data e hora 
//e descrição da condição de pagamento

User Function M440SC9I

   RecLock("SC9",.F.)
   SC9->C9_XDATE 	:= SC5->C5_XDATE
   SC9->C9_XTIME 	:= SC5->C5_XTIME
   SC9->C9_XUSER 	:= SC5->C5_XUSER
   SC9->C9_XCOND 	:= POSICIONE("SE4",1,XFILIAL("SE4")+SC5->C5_CONDPAG,"E4_DESCRI")
   IF SC5->C5_TIPO $ "BD"
   		SC9->C9_XNOMCLI := POSICIONE("SA2",1,XFILIAL("SA2")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A2_NOME")
   Else
      	SC9->C9_XNOMCLI := POSICIONE("SA1",1,XFILIAL("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NOME")
   Endif
   If Empty(SC9->C9_BLCRED)
      SC9->C9_XLOGCRE := SC5->C5_XLOGCRE
   EndIf

   If Empty(SC9->C9_BLEST)
      SC9->C9_XLOGEST := SC5->C5_XLOGEST
   EndIf

   If Empty(SC9->C9_BLWMS)
      SC9->C9_XLOGWMS := SC5->C5_XLOGWMS
   EndIf
      
   MsUnlock("SC9")

return

USER FUNCTION TRESP
Local cPerg := 'CRMAO5'
Local cResp := Space(6)
Local cNew  := Space(6)
Local cNome := Space(60) 
Local aRegs := {}
Local kkk

If !Pergunte(cPerg)
	Return
Endif

cResp := MV_PAR03
cNew  := MV_PAR04
cNome := USRRETNAME(ALLTRIM(cNew))

		
dbSelectArea("AOF")
dbSetOrder(10)
dbSeek(xFilial("AOF") + cResp + Dtos(MV_PAR01),.T.)
do While !Eof() .and. AOF->AOF_FILIAL == xFilial("AOF") .and. AOF->AOF_OBS == cResp	.and. AOF->AOF_DTINIC <= MV_PAR02
	If AOF->AOF_STATUS $ "1245"
		Aadd(aRegs,AOF->(RECNO()))
	Endif
	AOF->(dbSkip())
Enddo

For kkk := 1 To Len(aRegs)
	dbGoto(aRegs[kkk])
	RecLock("AOF",.F.)
    AOF->AOF_OBS    := cNew
    AOF->AOF_XRESP  := cNome
	msUnlock()
Next
		
Alert ("Alteração Efetuada")

 Return
 
 
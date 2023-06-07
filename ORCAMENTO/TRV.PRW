USER FUNCTION TRV
Local cPerg := 'CRMAO6'
Local cVend := Space(6)
Local cNew  := Space(6)
Local aRegs := {}
Local kkk

If !Pergunte(cPerg)
	Return
Endif

cVend := MV_PAR01
cNew  := MV_PAR02

If MV_PAR03 == 1
	dbSelectArea("SA1")
	dbSetOrder(10)
	dbSeek(xFilial("SA1") + cVend,.T.)
	do While !Eof() .and. SA1->A1_FILIAL == xFilial("SA1") .and. SA1->A1_VEND == cVend
		If !Empty(MV_PAR04) .and. A1_GRPVEN <> MV_PAR04
			SA1->(dbSkip())
			Loop
		ENDIF 
		If !Empty(MV_PAR06) .and. A1_EST <> MV_PAR06
			SA1->(dbSkip())
			Loop
		ENDIF 
		If !Empty(MV_PAR07) .and. A1_REGIAO <> MV_PAR07
			SA1->(dbSkip())
			Loop
		ENDIF 
		Aadd(aRegs,SA1->(RECNO()))
		SA1->(dbSkip())
	Enddo

	For kkk := 1 To Len(aRegs)
		dbGoto(aRegs[kkk])
		RecLock("SA1",.F.)
    	SA1->A1_VEND	:= cNew
    	msUnlock()
	Next

elseif MV_PAR03 == 2

	dbSelectArea("SUS")
	dbSetOrder(6)
	dbSeek(xFilial("SUS") + cVend,.T.)
	do While !Eof() .and. SUS->US_FILIAL == xFilial("SUS") .and. SUS->US_VEND == cVend
		If !Empty(MV_PAR05) .and. US_CODSEG <> MV_PAR05
			SUS->(dbSkip())
			Loop
		ENDIF 
		If !Empty(MV_PAR06) .and. US_EST <> MV_PAR06
			SUS->(dbSkip())
			Loop
		ENDIF 
		If !Empty(MV_PAR07) .and. LEFT(US_REGIAO,3) <> MV_PAR07
			SUS->(dbSkip())
			Loop
		ENDIF 

		Aadd(aRegs,SUS->(RECNO()))
		SUS->(dbSkip())
	Enddo

	For kkk := 1 To Len(aRegs)
		dbGoto(aRegs[kkk])
		RecLock("SUS",.F.)
    	SUS->US_VEND	:= cNew
    	msUnlock()
	Next

elseif MV_PAR03 == 3

	dbSelectArea("ACH")
	dbSetOrder(5)
	dbSeek(xFilial("ACH") + cVend,.T.)
	do While !Eof() .and. ACH->ACH_FILIAL == xFilial("ACH") .and. ACH->ACH_VEND == cVend
		If !Empty(MV_PAR05) .and. ACH_CODSEG <> MV_PAR05
			ACH->(dbSkip())
			Loop
		ENDIF 
		If !Empty(MV_PAR06) .and. ACH_EST <> MV_PAR06
			ACH->(dbSkip())
			Loop
		ENDIF 
		If !Empty(MV_PAR07) .and. LEFT(ACH_REGIAO,3) <> MV_PAR07
			ACH->(dbSkip())
			Loop
		ENDIF 
		Aadd(aRegs,ACH->(RECNO()))
		ACH->(dbSkip())
	Enddo

	For kkk := 1 To Len(aRegs)
		dbGoto(aRegs[kkk])
		RecLock("ACH",.F.)
    	ACH->ACH_VEND	:= cNew
    	msUnlock()
	Next	
ENDIF
		
Alert ("Alteração Efetuada")

Return

#include "rwmake.ch"

User Function SISP()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ SISP  ³ Autor ³ ANDREIA PIVA          ³ Data ³ 11/06/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ ExecBlock disparado do 341REM.PAG para retornar            ³±±
±±³          ³ conta corrente do fornecedor.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SISPAG                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Local cAgencia := ""
IF EMPTY(SE2->E2_FORBCO)
	IF SA2->A2_BANCO <> "399"
		cAgencia += STRZERO(VAL(SA2->A2_AGENCIA),5) // 24 a 28
		cAgencia += " "                              // 29 a 29
		cAgencia += STRZERO(VAL(SA2->A2_NUMCON),12) // 30 a 41
		cAgencia += Space(01)                        // 42 a 42
		cAgencia += SA2->A2_DVCTA                    // 43 a 43

	Else  

		cAgencia += STRZERO(VAL(SA2->A2_AGENCIA),5) // 24 a 28
		cAgencia += " "                              // 29 a 29
		cAgencia += STRZERO(VAL(SA2->A2_NUMCON),12) // 30 a 41
		cAgencia += SA2->A2_DVCTA                    // 42 a 43

	Endif
	
ELSE
	IF SE2->E2_FORBCO <> "399"
		cAgencia += STRZERO(VAL(SE2->E2_FORAGE),5) // 24 a 28
		cAgencia += " "                              // 29 a 29
		cAgencia += STRZERO(VAL(SE2->E2_FORCTA),12) // 30 a 41
		cAgencia += Space(01)                        // 42 a 42
		cAgencia += SE2->E2_FCTADV                    // 43 a 43

	Else  

		cAgencia += STRZERO(VAL(SE2->E2_FORAGE),5) // 24 a 28
		cAgencia += " "                              // 29 a 29
		cAgencia += STRZERO(VAL(SE2->E2_FORCTA),12) // 30 a 41
		cAgencia += SE2->E2_FCTADV                    // 42 a 43

	Endif
EndIf

Return cAgencia
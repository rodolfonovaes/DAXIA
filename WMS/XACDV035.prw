#INCLUDE "Acdv035.ch"
#INCLUDE "protheus.ch"
#INCLUDE "apvt100.ch"

STATIC __aRetCount	:= {} //Array que armazenara o retorno da analise do inventario ==>{lOk, aProdOk,aEtiQtdOk,aEtiLidas}
STATIC __cMestre	:= ""
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ACDV035  ³ Autor ³ ACD                   ³ Data ³ 14/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa principal do VT100 para o inventario              ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/


User Function XVD()

Local aTela
Local nOpc := 0
Private cArmazemAux := "" // CUSTOMIZADO

IF !(Type("lVT100B") == "L")
	Private lVT100B := .F.
EndIf


aTela := VtSave()
VTCLear()
@ 0,0 VTSAY STR0038 //"Inventario"
@ 1,0 VTSay STR0039 //'Selecione:'

If lVT100B // GetMv("MV_RF4X20")
	nOpc:=VTaChoice(2,0,3,VTMaxCol(),{STR0040,STR0009,STR0041})  //"Mestre"###"Produto"###"Endereco"
Else
	nOpc:=VTaChoice(3,0,5,VTMaxCol(),{STR0040,STR0009,STR0041})  //"Mestre"###"Produto"###"Endereco"
EndIf
VtRestore(,,,,aTela)
If nOpc == 1 // por mestre
	ACDV036()
ElseIf nOpc == 2 // por produto
	ACDV037()
ElseIf nOpc == 3 // por endereco
	ACDV038()
EndIf
Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ACDV036  ³ Autor ³ ACD                   ³ Data ³ 14/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa principal do VT100 para o inventario              ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ACDV036()
ACDV035X(1)
Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ACDV037  ³ Autor ³ ACD                   ³ Data ³ 14/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa principal do VT100 para o inventario              ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ACDV037()
ACDV035X(2)
Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ACDV038  ³ Autor ³ ACD                   ³ Data ³ 14/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa principal do VT100 para o inventario              ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ACDV038()
ACDV035X(3)
Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Informa    ³ Autor ³ TOTVS               ³ Data ³ 01/01/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa principal do VT100 para o inventario              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ACDV035X                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ACDV035X(nOpc,lRetorno)
Local lValidQtdInv
Local nTamLoc    := TamSX3("B2_LOCAL")[1]
Local nTamProd   := TamSX3("B1_COD")[1]
Local nTamEnd    := Tamsx3("BF_LOCALIZ")[1]
Local nTamCodInv := TamSX3("CBA_CODINV")[1]
Local nTamUnit   := TamSX3("D14_IDUNIT")[1]
Local nTamCodUni	 := TamSX3("D14_CODUNI")[1]
Local cLocal     := Space(nTamLoc)
Local cLocaAux
Local cEtiqueta :=Space(48)
Local lCBINV03  :=ExistBlock('CBINV03')
Local uRetEti
Local bkey09
Local lWmsNew	:= SuperGetMv("MV_WMSNEW",.F.,.F.)
Local lVolta := .F.
Local lUniCPO := CBC->(ColumnPos("CBC_IDUNIT")) > 0
Local lCBINVPR	:= ExistBlock('CBINVPR')
Local lCBINVFIM	:= ExistBlock('CBINVFIM')
Local lLocaliz	:= GetMv('MV_LOCALIZ') =="S"


Private cArmazem
Private cEndereco
Private cEtiqend
Private cProduto
Private cEtiqProd
Private cCodUnit
Private cCodTpUni
Private lProcUnit := .F.
Private nQtdEtiq
Private cClasses 	:= ""
Private cCodOpe  	:=CBRetOpe()
Private aProdEnd	:={}
Private lMsErroAuto	:= .F.
Private lUsaCB001 	:=UsaCB0("01")
Private lUsaCB002 	:=UsaCB0("02")
Private lModelo1  	:=GetMv("MV_CBINVMD")=="1"
Private lForcaQtd 	:=GetMV("MV_CBFCQTD",,"2") =="1"
Private lVldTelWMS 	:= .F.
Private _cEtiqueta	:= ''
Private _cLote		:= ''
lValidQtdInv := If(lUsaCB001,(GetMv("MV_VQTDINV")=="1"),.t.)

If Empty(cCodOpe)
	VTAlert(STR0001,STR0002,.T.,4000) //"Operador nao cadastrado"###"Aviso"
	Return .F.
EndIf
If ! SuperGetMV("MV_CBPE012",.F.,.F.)
	VTAlert(STR0042,STR0002,.T.,6000,3) //"Necessario ativar o parametro MV_CBPE012"###"Aviso"
	Return .F.
EndIf
If ! lModelo1
	bkey09 := VTSetKey(09,{|| Informa()},STR0043) //"Informacao"
EndIf

While .T.
    If lCBINV03
        cLocalAux := ExecBlock('CBINV03',.F.,.F.)
        If ValType(cLocalAux)== "C"
            cLocal := cLocalAux
        EndIf
    EndIf
	If lCBINVPR
		uRetEti := ExecBlock('CBINVPR',.F.,.F.)
		If ValType(uRetEti)=="C"
			cEtiqueta := uRetEti
		EndIf
	EndIf
	cArmazem := Space(nTamLoc)
	cEndereco:= Space(nTamEnd)
	cEtiqend := Space(48)
	cProduto := Space(nTamProd)
	cEtiqProd:= Space(48)
	cCodunit := Space(nTamUnit)
	cCodTpUni:= Space(nTamCodUni)
	nQtdEtiq := 1
	If lVT100B // GetMv("MV_RF4X20")
		If nOpc == 1       // por mestre de inventrio
			VTClear()
			cCodInv := Space(nTamCodInv)
			@ 0,0 VTSay STR0003 //'Inventario'
			@ 2,0 VTSay STR0004 //'Codigo Mestre'
			@ 3,0 VTGet cCodInv Pict '@!'Valid VldCodInv(cCodInv,@lRetorno)  F3 "CBB"
			VTRead
			If VtLastkey() == 27
				Exit
			EndIf

			If lWmsNew
				cEndereco:= Padr(cEtiqueta,nTamEnd)
			Else
				cEndereco := CBA->CBA_LOCALI
				cArmazem  := CBA->CBA_LOCAL
			Endif
			//@ 3,0 VTCLEAR TO 3,Len(cEndereco)
			VTClearBuffer()
		ElseIf nOpc == 2   // por produto
			@ 0,0 VTSay STR0003 //'Inventario'
			If lUsaCB001
				@ 0,0 VtSay STR0044  //"Leia a Etiqueta de"
				@ 1,0 VtSay STR0045 //"Produto p/ localizar"
				@ 2,0 VtSay STR0046 //"mestre de inventario"
				@ 3,0 VtGet cEtiqueta Pict '@!' Valid VldMEti(1,NIL,cEtiqueta)
				VTRead
			Else
				While .T.
					lVolta := .F.
					VTClear
					@ 1,0 VtSay STR0047 //"Armazem"
					@ 2,0 VtGet cLocal  Pict '@!' Valid !Empty(cLocal)
					VTRead

					cArmazemAux := cLocal //CUSTOMIZADO

					If VtLastkey() != 27
						VTClear
						@ 0,0 VtSay STR0044 //"Leia a Etiqueta de"
						@ 1,0 VtSay STR0045 //"Produto p/ localizar"
						@ 2,0 VtSay STR0046 //"mestre de inventario"
						@ 3,0 VtGet cEtiqueta Pict '@!' Valid VldMEti(1,cLocal,@cEtiqueta) when iif(vtRow() == 3 .and. vtLastKey() == 5,(VTKeyBoard(chr(27)),lVolta := .T.),.T.)
						VTRead
					EndIf

					If lVolta
						Loop
					EndIf

					Exit
				EndDo
			EndIf

			If VtLastkey() == 27
				Exit
			EndIf
			cArmazem  := CBA->CBA_LOCAL
			cEndereco := CBA->CBA_LOCALI
		ElseIf nOpc == 3   // por endereco
			//@ 0,0 VTSay STR0003 //'Inventario'
			@ 0,0 VtSay STR0044 //"Leia a Etiqueta de"
			@ 1,0 VtSay STR0048 //"Endereco p/ localizar"
			@ 2,0 VtSay STR0046 //"mestre de inventario"

			If lUsaCB002
				@ 3,0 VtGet cEtiqueta Pict '@!' Valid VldMEti(2,cLocal,cEtiqueta)
			Else
				@ 3,0 VTGet cLocal  pict '@!' Valid ! Empty(cLocal)
				@ 3,2 VTSay '-' VtGet cEtiqueta Pict '@!' Valid  VldCons(cLocal,cEtiqueta)
			EndIf
			VTRead

			If VtLastkey() == 27
				Exit
			EndIf
			//Rodolfo
			If !Empty(_cEtiqueta)
				cEtiqueta := _cEtiqueta
			EndIf
			If lUsaCB002
				cEtiqEnd:=  cEtiqueta
				VTKeyBoard(chr(13))
			Else
				cArmazem := cLocal
				cEndereco:= Padr(cEtiqueta,nTamEnd)
				VTKeyBoard(chr(13))
				VTKeyBoard(chr(13))
			Endif
		EndIf
		VTClear()

		While .T.
			//Rodolfo - alteração da ordem dos campos
			@ 0,0 VTSay STR0003 //'Inventario'
			@ 1,0 VTSay STR0005+CBA->CBA_LOCAL //'Armazem '

			If lLocaliz .and. If(Empty(CBA->CBA_PROD),.T.,Localiza(CBA->CBA_PROD,.T.))
				@ 2,0 VTSay STR0006 //'Endereco'
				If lUsaCB002
					lVolta := .F.
					@ 3,0 VTGet cEtiqEnd  pict '@!'  Valid EtiqEnd()
				Else
					If lCBINV03
						cLocalAux := ExecBlock('CBINV03',.F.,.F.)
						If ValType(cLocalAux)=="C"
							cArmazem := cLocalAux
						EndIf
					EndIf
					@ 3,0 VtGet cArmazem when iif(lVolta,(VTKeyBoard(chr(13)),lVolta := .F.,.T.),.T.)
					@ 3,4 VTSay '-' VtGet cEndereco Valid VldEnd()
				EndIf
				VTRead
			EndIf

			If VtLastkey() != 27
				VTClear
				@ 0,0 VTSay STR0007 //"Quantidade"
				@ 1,0 VTGet nQtdEtiq pict CBPictQtde() valid nQtdEtiq > 0 when (lForcaQtd .or. VTLastkey() == 5) .and. lValidQtdInv .and. iif(vtRow() == 1 .and. vtLastKey() == 5,(VTKeyBoard(chr(27)),lVolta := .T.),.T.)
				If lUsaCB001
					@ 2,0 VTSay STR0008 //"Etiqueta"
				Else
					@ 2,0 VTSay STR0009 //"Produto"
				EndIf
				@ 3,0 VTGet cEtiqProd pict "@!" Valid VTLastkey() == 5  .or. VldEtiPro(nOpc) when iif(vtRow() == 3 .and. vtLastKey() == 5 .and. !lForcaQtd .and. !lValidQtdInv,(VTKeyBoard(chr(27)),lVolta := .T.),.T.)
				VTRead
			EndIf

			If lVolta
				Loop
			EndIf

			Exit
		EndDo
	Else
		If nOpc == 1       // por mestre de inventrio
			VTClear()
			cCodInv := Space(nTamCodInv)
			@ 0,0 VTSay STR0003 //'Inventario'
			@ 2,0 VTSay STR0004 //'Codigo Mestre'
			@ 3,0 VTGet cCodInv Pict '@!'Valid VldCodInv(cCodInv,@lRetorno)  F3 "CBB"
			VTRead
			If VtLastkey() == 27
				Exit
			EndIf

			If lWmsNew
				cEndereco:= Padr(cEtiqueta,nTamEnd)
			Else
				cEndereco := CBA->CBA_LOCALI
				cArmazem  := CBA->CBA_LOCAL
			Endif
			//@ 3,0 VTCLEAR TO 3,Len(cEndereco)
			VTClearBuffer()
		ElseIf nOpc == 2   // por produto
			@ 0,0 VTSay STR0003 //'Inventario'
			If lUsaCB001 
				@ 1,0 VtSay STR0044 //"Leia a Etiqueta de"
				@ 2,0 VtSay STR0045 //"Produto p/ localizar"
				@ 3,0 VtSay STR0046 //"mestre de inventario"
				@ 4,0 VtGet cEtiqueta Pict '@!' Valid VldMEti(1,NIL,cEtiqueta) 
			Else
				@ 1,0 VtSay STR0047 //"Armazem"
				@ 2,0 VtGet cLocal  Pict '@!' Valid !Empty(cLocal)
				@ 3,0 VtSay STR0044 //"Leia a Etiqueta de"
				@ 4,0 VtSay STR0045 //"Produto p/ localizar"
				@ 5,0 VtSay STR0046 //"mestre de inventario"
				@ 6,0 VtGet cEtiqueta Pict '@!' Valid VldMEti(1,cLocal,cEtiqueta)
			EndIf
			VTRead
			If VtLastkey() == 27
				Exit
			EndIf
			cArmazem  := CBA->CBA_LOCAL
			cEndereco := CBA->CBA_LOCALI
		ElseIf nOpc == 3   // por endereco
			@ 0,0 VTSay STR0003 //'Inventario'
			@ 1,0 VtSay STR0044 //"Leia a Etiqueta de"
			@ 2,0 VtSay STR0048 //"Endereco p/ localizar"
			@ 3,0 VtSay STR0046 //"mestre de inventario"

			If lUsaCB002
				@ 4,0 VtGet cEtiqueta Pict '@!' Valid VldMEti(2,cLocal,cEtiqueta)
			Else
				@ 4,0 VTGet cLocal  pict '@!' Valid ! Empty(cLocal)
				@ 4,2 VTSay '-' VtGet cEtiqueta Pict '@!' Valid  VldCons(cLocal,cEtiqueta)
			EndIf
			VTRead
			If VtLastkey() == 27
				Exit
			EndIf
			//Rodolfo
			If !Empty(_cEtiqueta)
				cEtiqueta := _cEtiqueta
			EndIf			
			If lUsaCB002
				cEtiqEnd:=  cEtiqueta
				VTKeyBoard(chr(13))
			Else
				cArmazem := cLocal
				cEndereco:= Padr(cEtiqueta,nTamEnd)
				VTKeyBoard(chr(13))
				VTKeyBoard(chr(13))
			Endif
		EndIf
		VTClear()
		@ 0,0 VTSay STR0003 //'Inventario'
		@ 1,0 VTSay STR0005+CBA->CBA_LOCAL //'Armazem '

		If lLocaliz .and. If(Empty(CBA->CBA_PROD),.T.,Localiza(CBA->CBA_PROD,.T.))
			@ 2,0 VTSay STR0006 //'Endereco'
			If lUsaCB002
				@ 3,0 VTGet cEtiqEnd  pict '@!'  Valid EtiqEnd()
			Else
				If lCBINV03
					cLocalAux := ExecBlock('CBINV03',.F.,.F.)
					If ValType(cLocalAux)=="C"
						cArmazem := cLocalAux
					EndIf
				EndIf
				@ 3,0 VtGet cArmazem
				@ 3,4 VTSay '-' VtGet cEndereco Valid VldEnd()
			EndIf
		EndIf
		
		//ajustar ordem dos campos aqui - RODOLFO	
		nQtdEtiq := 0
		If lUsaCB001
			@ 4,0 VTSay STR0008 //"Etiqueta"
		Else
			@ 4,0 VTSay STR0009 //"Produto"
		EndIf
		@ 5,0 VTGet cEtiqProd pict "@!" Valid VTLastkey() == 5  .or. .T. //VldEtiPro(nOpc)
		
		if lUniCPO .and.lWmsNew
		   //@ 4,0 VTSay STR0119 // "Unitiza.:"
		   //@ 4,9 VtGet cCodUnit pict "@!"  Valid  Iif (lVldTelWMS ,AcdCopVal("UNI",cArmazem,cEndereco,cCodUnit,,@cCodTpUni),IIf(Empty(cCodUnit),.T.,.F.))
		   @ 6,0 VTSay STR0120 // 'QTD:'
		Else
			@ 6,0 VTSay STR0007 // Quantidade
		EndIf
		lForcaQtd := .T.
		if lUniCPO .and.lWmsNew
			@ 6,3 VTGet nQtdEtiq pict CBPictQtde() valid nQtdEtiq > 0 .And. VldEtiPro(nOpc) /*ConvQtd(cProduto,cArmazem,nQtdEtiq)*/ when (lForcaQtd .or. VTLastkey() == 5) .and. lValidQtdInv
		Else
			@ 6,0 VTGet nQtdEtiq pict CBPictQtde() valid nQtdEtiq > 0 .And. VldEtiPro(nOpc) when (lForcaQtd .or. VTLastkey() == 5) .and. lValidQtdInv
		Endif

		VTRead
	EndIf
	aiv035Fim()
	If lCBINVFIM
		lRet:=ExecBlock('CBINVFIM',.F.,.F.)
		If ValType(lRet)#"L"
			Return .T.
		EndIf
		If lRet == .F.
			cLocal	  :=""
			cEtiqueta :=""
			cLocal	  :=Space(nTamLoc)
			cEtiqueta :=Space(48)
			loop
		EndIf
	EndIF
	Exit
End
If ! lModelo1
	vtsetkey(09,bkey09)
EndIf
Return .T.

// -----------------------------------------------
/*/{Protheus.doc} VPeAltQtd
@param: Nil
@author:TOTVS
/*/
// -------------------------------------------------
Static Function VPeAltQtd()

If ExistBlock("V035ALTQTD")
	nQtdAux := ExecBlock("V035ALTQTD",.F.,.F.,{nQtdEtiq})
	If ValType(nQtdAux) = "N"
		nQtdEtiq := nQtdAux
		VTGetRefresh('nQtdEtiq')
	EndIf
EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VldCons	  ³ Autor ³ TOTVS               ³ Data ³ 25/06/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³  Efetua a validação da Etiqueta e do Endereço, deixando    ³±±
±±³			 ³  somente visual a informação.					   		        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ACDV035	                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function VldCons(cLocal,cEtiqueta)
Local lRet	:= .T.
Local nTamEnd := TamSX3("BF_LOCALIZ")[1]

//Rodolfo
SBE->(DbSetOrder(11))
If SBE->(DbSeek(xFilial('SBE') + cLocal + PADR(cEtiqueta,TamSX3('BE_XID')[1])))
	cEtiqueta := SBE->BE_LOCALIZ
	_cEtiqueta	:= SBE->BE_LOCALIZ
EndIf

If VldMEti(2,cLocal,cEtiqueta)

	If !VldEnd(cLocal,Padr(cEtiqueta,nTamEnd))
	   lRet := .F.
	EndIf

Else
    lRet := .F.
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VoltaStatus³ Autor ³ TOTVS               ³ Data ³ 01/01/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Analisa a contagem apos sua finalizacao, e verifica        ³±±
±±³			 ³ se a mesma esta vazia (gerou CBC), estornando a    		  ³±±
±±³			 ³ contagem e os status se necessario       				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ACDV035	                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function VoltaStatus()
Local cNum    := CBB->CBB_NUM
Local nRecPos := CBB->(RecNo())
Local lPausa  := .f.
Local lCAtiva := .f.  // Contagem ativada
Local cCodInv := CBB->CBB_CODINV

CBC->(DbSetOrder(1))
If !CBC->(DbSeek(xFilial("CBC")+CBB->CBB_NUM))
	DbSelectArea("CBB")
	RecLock("CBB",.f.)
	CBB->(DbDelete())
	CBB->(MsUnLock())


	DbSelectArea("CBA")
	RecLock("CBA",.f.)
	If ! lModelo1 // se for modelo 2 desbloquea mestre
		CBA->CBA_AUTREC := "1" // DESBLOQUEADO
	EndIf
	CBA->(MsUnlock())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Decrementa numero de contagens realizadas do mestre          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CBAtuContR(cCodInv, 2)

	RecLock("CBA",.f.)

	CBB->(DbSetOrder(3))
	// Se for encontrado verifica o modelo e altera o status
	If CBB->(DbSeek(xFilial('CBB')+CBA->CBA_CODINV))
		If !lModelo1
			CBA->CBA_STATUS := "3" 		// "3" - Contado
		Else
			While CBB->(!Eof() .AND. CBB_FILIAL+CBB_CODINV==xFilial("CBB")+CBA->CBA_CODINV)
				If (cNum#CBB->CBB_NUM) .and. CBB->CBB_STATUS $ "0|1"
					lCAtiva := .t.
					Exit
				EndIf
				CBB->(DbSkip())
			EndDo
			If !lCAtiva
				CBA->CBA_STATUS := "3" 		// "3" - Contado
			EndIf
		EndIf
	Else
		//Se nao encontrar nenhuma contagem para o mestre de inventario, altera status para noa iniciado
		CBA->CBA_STATUS := "0" 		// "0" - Nao Iniciado
		ACDA30Exc()
	EndIf
	CBA->(MsUnLock())
Else
	If lModelo1
		CBB->(dbSetOrder(3))
		CBB->(DbSeek(xFilial('CBB')+CBA->CBA_CODINV))
		While CBB->(!EOF() .AND. CBB_FILIAL+CBB_CODINV==xFilial('CBB')+CBA->CBA_CODINV)
			If (cNum==CBB->CBB_NUM) .and. (CBB->CBB_STATUS $ "01")
				lPausa := .T.
			ElseIf (cNum#CBB->CBB_NUM) .and. CBB->CBB_STATUS $ "0|1"
				lCAtiva := .t.
				RecLock("CBA",.f.)
				CBA->CBA_STATUS := "3" // EM PAUSA
				CBA->(MsUnLock())
				Exit
			EndIf
			CBB->(DbSkip())
		EndDo
	EndIf

	If !lModelo1 .or. (lPausa .and. !lCAtiva)
		//para o Modelo 2 somente a ultima contagem que importa, mas como so um
		//operador estara contando, nao preciso fazer analise, ja o modelo 1 deve
		//respeitar pausa somente se nenhum outro operador estiver com contagem em andamento.
		RecLock("CBA",.f.)
		CBA->CBA_STATUS := "2" // EM PAUSA
		CBA->(MsUnLock())
	EndIf
	CBB->(MsGoto(nRecPos))
EndIf
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³	aiv035Fim ³ Autor ³ TOTVS               ³ Data ³ 01/01/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Finaliza a contagem de Inventario				          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ACDV035	                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function aiv035Fim()
Local lPerExcInv  := SuperGetMv("MV_CBEXMIN", .F., .F.) //Habilitar exclusao do mestre inventario de enderecos s/saldo
Local lWmsNew		 := SuperGetMv("MV_WMSNEW",.F.,.F.)
Local lUniCPO		 := CBC->(ColumnPos("CBC_IDUNIT")) > 0
Local nRecCBB
Local nX
Local cCodInv := ""

If ! VTYesNo(STR0010,STR0002,.T.)  //"Deseja finalizar a contagem?"###"Aviso"
	// sandro
	// vereficar se nao leu nada para voltar o status
	CBB->(MsUnlock())
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Estorna contagem possicionada e altera status se necessario. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	VoltaStatus()
	Return
EndIf

// BY ERIKE Verificar se existe produtos a serem contados para este mestre
CBLoadEst(aProdEnd,.F.)
CBC->(dbSetOrder(1))
If Empty(aProdEnd) .and. ! CBC->(dbSeek(xFilial('CBC')+CBB->CBB_NUM))
	If CBA->CBA_TIPINV == "1" // Por Produto
		VTAlert(STR0049,STR0002,.T.,4000) //"Nao existem Produtos para este endereco. A contagem nao sera finalizada!"###"Aviso"
		CBB->(MsUnlock())
		Return
	Else	//Por Endereco
		CBB->(MsUnlock())
		nRecCBB := CBB->(RecNo())
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Caso este endereco estaja vazio, e nao exista ocorrencia de  ³
		//³ contagem, sera perguntado para o operador se o mesmo deseja  ³
		//³ continuar com a contagem em aberto, ou finalizar o mestre de ³
		//³ inventario.                                                  ³
		//³ Bops: 00000084197                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		CBC->(dbSetOrder(3))
		If !CBC->(DbSeek(xFilial('CBC')+CBA->CBA_CODINV))
			//Realiza desbloqueio do endereço
			If lWmsNew
				SBE->(dbSetOrder(1))
				If SBE->(dbSeek(xFilial('SBE')+CBA->(CBA_LOCAL+CBA_LOCALI)))
					RecLock("SBE",.F.)
					SBE->BE_STATUS  := "1"
					SBE->(MsUnlock())
				Endif
			EndIf

			VTAlert(STR0100+; //"Nao existem saldo(s) para este(s) produto(s) neste endereco, "
			STR0101+; //"nem foi detectada a ocorrencia de inventario para este mestre!"
			STR0102+; //"Este mestre deve ser excluido, caso contrario a contagem nao sera "
			STR0103,STR0104,.T.)   //"finalizada."###"Atencao"

			//Permite operador excluir Mestre inventario (tipo=endereco) por RF para inventario de endereco sem saldo.
			If lPerExcInv
				If VTYesNo(STR0105,STR0104,.t.) //"Deseja excluir este mestre de inventario?"###"Atencao"
					//Apaga Contagem atual
					RecLock('CBB',.F.)
					CBB->(DbDelete())
					CBB->(MsUnLock())
					//Apaga Mestre de inventario
					RecLock('CBA',.F.)
					CBA->(dbDelete())
					CBA->(MsUnLock())
				Else
					cCodInv := CBB->CBB_CODINV
					//Apaga Contagem atual
					RecLock('CBB',.F.)
					CBB->(DbDelete())
					CBB->(MsUnLock())

					RecLock('CBA',.F.)
					CBA->CBA_STATUS := "6" //"Endereco Sem Saldo" -> aProdEnd retorna vazio
					CBA->(MsUnLock())

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Decrementa numero de contagens realizadas do mestre          ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					CBAtuContR(cCodInv, 2)

				EndIf

				ACDA30Exc()

			Else

				cCodInv := CBB->CBB_CODINV
				//Apaga Contagem atual
				RecLock('CBB',.F.)
				CBB->(DbDelete())
				CBB->(MsUnLock())

				//Atualiza o status do mestre como nao inicial
				RecLock('CBA',.F.)
				CBA->CBA_STATUS := "6" //"Endereco Sem Saldo" -> aProdEnd retorna vazio
				CBA->(MsUnLock())

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Decrementa numero de contagens realizadas do mestre          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				CBAtuContR(cCodInv, 2)

			EndIf
		Else
			CBB->(MsGoto(nRecCBB))
			VTAlert(STR0100+; //"Nao existem produtos para este endereco nos saldos do sistema, "
			STR0106+; //"porem foi detectada a ocorrencia de inventario para este mestre!"
			STR0107+; //"sera necessario excluir esta contagem, caso contrario a contagem nao sera "
			STR0103,STR0104,.T.)   //"finalizada."###"Atencao"
			If VTYesNo(STR0108,STR0104,.t.) //"Deseja excluir a contagem atual?"###"Atencao"
				cCodInv := CBB->CBB_CODINV
				RecLock('CBB',.F.)
				CBB->(DbDelete())
				CBB->(MsUnLock())

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Decrementa numero de contagens realizadas do mestre          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				CBAtuContR(cCodInv, 2)

			EndIf
			If CBA->CBA_STATUS == "0"
				ACDA30Exc()
			EndIf
		EndIf
		Return
	EndIf
EndIf
///------------------------
dbSelectArea("CBC")
CBC->(dbSetOrder(1))
If ! CBC->(dbSeek(xFilial('CBC')+CBB->CBB_NUM))
	If ! VTYesNo(STR0033,STR0002,.t.) //'Nenhum produto foi inventariado, confirma estoque Zero'###"Aviso"
		CBB->(MsUnlock())
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Estorna contagem possicionada e altera status se necessario. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		VoltaStatus()
		Return
	Else
		For nX:= 1 To Len(aProdEnd)
			RecLock("CBC",.T.)
			CBC->CBC_FILIAL := xFilial("CBC")
			CBC->CBC_CODINV := CBB->CBB_CODINV
			CBC->CBC_NUM    := CBB->CBB_NUM
			CBC->CBC_LOCAL  := aProdEnd[nX,4]
			CBC->CBC_LOCALI := aProdEnd[nX,5]
			CBC->CBC_COD    := aProdEnd[nX,1]
			CBC->CBC_LOTECT := aProdEnd[nX,2]
			CBC->CBC_NUMLOT := aProdEnd[nX,3]
			CBC->CBC_NUMSER := aProdEnd[nX,6]
			if lUniCPO .and.IntWms(aProdEnd[nX,1])
				CBC->CBC_IDUNIT := aProdEnd[nX,9]
				CBC->CBC_CODUNI := aProdEnd[nX,10]
			EndIf
			CBC->CBC_QUANT  := 0
			CBC->(MSUNLOCK())
		Next
	EndIf
Else
	CBC->(dbSetOrder(2))
	For nX:= 1 To Len(aProdEnd)
		if !lWmsNew
			If CBC->(dbSeek(xFilial('CBC')+CBB->CBB_NUM+aProdEnd[nX,1]+aProdEnd[nX,4]+aProdEnd[nX,5]+aProdEnd[nX,2]+aProdEnd[nX,3]+aProdEnd[nX,6]))
				// se encontrar nao eh necessario completar a contagem para compatibilizar o estoque
				Loop
			EndIf
		ElseIf lUniCPO .and. lWmsNew
			If CBC->(dbSeek(xFilial('CBC')+CBB->CBB_NUM+aProdEnd[nX,1]+aProdEnd[nX,4]+aProdEnd[nX,5]+aProdEnd[nX,2]+aProdEnd[nX,3]+aProdEnd[nX,6]+aProdEnd[nX,9]))
				Loop
			EndIf
		EndIf
		RecLock("CBC",.T.)
		CBC->CBC_FILIAL := xFilial("CBC")
		CBC->CBC_CODINV := CBB->CBB_CODINV
		CBC->CBC_NUM    := CBB->CBB_NUM
		CBC->CBC_LOCAL  := aProdEnd[nX,4]
		CBC->CBC_LOCALI := aProdEnd[nX,5]
		CBC->CBC_COD    := aProdEnd[nX,1]
		CBC->CBC_LOTECT := aProdEnd[nX,2]
		CBC->CBC_NUMLOT := aProdEnd[nX,3]
		CBC->CBC_NUMSER := aProdEnd[nX,6]
		if lUniCPO .and.IntWms(aProdEnd[nX,1])
			CBC->CBC_IDUNIT := aProdEnd[nX,9]
			CBC->CBC_CODUNI := aProdEnd[nX,10]
		EndIf
		CBC->CBC_QUANT  := 0
		CBC->(MSUNLOCK())
	Next
Endif

dbSelectArea("CBB")
RecLock("CBB",.F.)
CBB->CBB_STATUS := "2"
CBB->(MsUnlock())
If ! Ultimo()
	Return
EndIF

dbSelectArea("CBA")
RecLock("CBA",.F.)
CBA->CBA_STATUS := "3" //Contado
CBA->(MsUnLock())

If GetMV("MV_ANAINV") # "1"
	//Esta funcao eh executada para atualizar o CBA_ANALIS (que indica se existe divergencia ou nao no mestre de inventario)
	AnalisaInv(.F.)
	Return
EndIf
CBAnaInv()
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CBAnaInv ³ Autor ³ ACD                   ³ Data ³ 01/01/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para analisar o inventario				          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CBAnaInv(lMonitor,lAutomatico)
Local nX		:= 0
Local lRet		:= .f.
Local lModelo1	:= SuperGetMv("MV_CBINVMD")=="1"
Local cInvRes 	:= 'INVRES'+ STRTRAN(AllTrim(cEmpAnt),' ','_')+ STRTRAN(AllTrim(cFilAnt),' ','_')
Local lLock340	:= SuperGetMV("MV_340LOCK",.F.,"F") == "U" // F = Filial ou U = Usuario

DEFAULT lMonitor   := .f.
DEFAULT lAutomatico:= .f.

If lLock340
	cInvRes	:= 'INVRES'+ STRTRAN(AllTrim(cEmpAnt),' ','_')+ STRTRAN(AllTrim(cFilAnt),' ','_')+ STRTRAN(AllTrim(RetCodusr()),' ','_')
EndIf

If MsFile(cInvRes,,"TOPCONN")
	If select(cInvRes) >0
		(cInvRes)->(DbCloseArea())
	EndIf
	USE (cInvres) EXCLUSIVE NEW VIA "TOPCONN"
	If !(NetErr())
		DbSelectArea(cInvRes)
		ZAP
		(cInvRes)->(DbCloseArea())
	EndIf
EndIf

Begin Transaction
If Type('aLogMestre')# 'A'
	Private aLogMestre := {}
EndIf

__cMestre   := ""
__aRetCount := AnalisaInv(lMonitor)
If __aRetCount[1]
	If IsTelNet()
		lRet := AcertoInv(aClone(__aRetCount[2]),aClone(__aRetCount[3]),aClone(__aRetCount[4]),lMonitor,lAutomatico)
	Else
		ProcRegua(Len(__aRetCount[2]))
		Processa({|| lRet := AcertoInv(aClone(__aRetCount[2]),aClone(__aRetCount[3]),aClone(__aRetCount[4]),lMonitor,lAutomatico)})
	EndIf
	If ! lRet
		DisarmTransaction()
		If !lAutomatico
			MsgInTrans(1,STR0011,STR0012,.T.,4000,3)  //"Falha na gravacao do inventario"###"ERRO"
		EndIf
		Break
	Endif
	//Ajusta localizacao
	If lRet .And. SuperGetMv("MV_ALTENDI") == "1" .And. lUsaCB001
		CB0->(DbSetorder(1))
		For nX:=1 To Len(__aRetCount[4])
 			If CB0->(DbSeek(xFilial("CB0")+__aRetCount[4,nX])) .And. CBA->(CBA_LOCAL+CBA_LOCALI) <> CB0->(CB0_LOCAL+CB0_LOCALI)
				RecLock("CB0",.F.)
				CB0->CB0_LOCAL  := __aRetCount[3,nX,3]
				CB0->CB0_LOCALI := __aRetCount[3,nX,4]
				MsUnLock()
			EndIf
		Next
	EndIf
Endif
DbSelectArea("CBA")
RecLock("CBA",.F.)
If __aRetCount[5] .and. !lMsErroAuto .and. CBA->CBA_STATUS # "5"
	CBA->CBA_STATUS := "4"  // 4-finalizado
EndIf

CBA->(MsUnlock())
End Transaction

//Mostra Mensagens da transacao se existir
ViewMsgInT()

If lMsErroAuto
	If lAutomatico
		Aadd(aLogMestre,{CBA->CBA_CODINV,0,STR0050+CBA->CBA_CODINV+STR0051,.F.}) //"-->Mestre:"###" - Erro na rotina automatica"
		//Aadd(aLogMestre,{CBA->CBA_CODINV,1,"Detalhes no arquivo "+NomeAutoLog(),.F.})
		lMsErroAuto := .F.
	Else
		If IsTelNet()
			VTDispFile(NomeAutoLog(),.t.)
		Else
			MostraErro()
		EndIf
	EndIf
Else
	If __aRetCount[1]
		If lAutomatico
			Aadd(aLogMestre,{CBA->CBA_CODINV,0,STR0052+CBA->CBA_CODINV+STR0053,.T.}) //"Mestre "###" foi finalizado com sucesso"
		Else
			CBAlert(STR0013,STR0002,.T.,4000,3) //"Inventario concluido"###"Aviso"
		Endif
	Else
		If lAutomatico
			Aadd(aLogMestre,{CBA->CBA_CODINV,0,STR0054+CBA->CBA_CODINV+STR0055,.F.}) //"--> Mestre: "###" - Nao foi finalizado"
			Aadd(aLogMestre,{CBA->CBA_CODINV,1,If(lModelo1,STR0056, ; //"- Contagem divergente"
			STR0057),.F.}) //"- Inventario bloqueado para auditoria"
		Else
			If lModelo1
				CBAlert(STR0014,STR0015,.T.,4000) //"Nao foi atingido o numero de contagens necessarias"###"Inv. em andamento"
			Else
				CBAlert(STR0058,STR0015,.T.,4000) //"Inventario bloqueado para Auditoria"###"Inv. em andamento"
			EndIf
		EndIf
	Endif
EndIf
Return

Static Function VldCodInv(cCodInv,lAlert)
Local lRetorno
Local lV035VLDM :=ExistBlock("V035VLDM")
Local cUltCont
Local aCBC:={}
Local nX,nY
Default lAlert:= .t.
If Empty(cCodInv)
	VtKeyBoard(chr(23))
	Return .F.
EndIf
CBA->(DbSetOrder(1))
If ! CBA->(DbSeek(xFilial('CBA')+cCodInv))
	VTBeep(3)
	VTAlert(STR0016,STR0017,.t.,4000) //'Codigo mestre de inventario nao cadastrado'###'Atencao'
	VTKeyBoard(chr(20))
	Return .f.
EndIf
If CBA->CBA_STATUS$"4-5" // 4=Finalizado / 5=Processado
	VTBeep(3)
	VTAlert(STR0018,STR0017,.t.,4000) //'Inventario finalizado'###'Atencao'
	VTKeyBoard(chr(20))
	Return .F.
EndIf
If (CB1->CB1_INVPVC<>"1")// mesmo operador executar o mesmo inventario
	CBB->(dbSetOrder(2))
	If CBB->(dbSeek(xFilial('CBB')+"2"+cCodOpe+CBA->CBA_CODINV ))
		VTBeep(3)
		VTAlert(STR0059,STR0060,.t.,4000)  //"Operador ja realizou contagem para o inventario"###"Sem permissao"
		VTKeyBoard(chr(20))
		Return .f.
	EndIf
EndIf
If DTOS(CBA->CBA_DATA)#DTOS(dDataBase)
	VTAlert(STR0115,STR0017,.t.,4000,3) //'Data do "Mestre de Inventario" deve ser igual a "Data Base" do sistema!'
	VTAlert(I18N(STR0116,{DTOC(CBA->CBA_DATA)}),STR0017,.t.)  //"Somente o Operador "###" pode dar continuidade a este inventario"###"Contagens == 1"
	VTKeyBoard(chr(20))
	Return .f.
EndIf
If CBA->CBA_CONTS == 1
	CBB->(DbSetOrder(1))
	If CBB->(DbSeek(xFilial('CBB')+CBA->CBA_CODINV )) .and. CBB->CBB_USU # cCodOpe
		VTBeep(3)
		VTAlert(STR0061+CBB->CBB_USU+STR0062,STR0063,.t.,4000)  //"Somente o Operador "###" pode dar continuidade a este inventario"###"Contagens == 1"
		VTKeyBoard(chr(20))
		Return .f.
	Endif
Endif
CBB->(DbSetOrder(2))
If CBB->(DbSeek(xFilial('CBB')+"1"+cCodOpe+CBA->CBA_CODINV ))
	If ! CBB->(RLock())
		VTBeep(3)
		VTAlert(STR0019,STR0017,.t.,4000) //'Operador executando inventario em outro terminal'###'Atencao'
		VTKeyBoard(chr(20))
		Return .F.
	EndIf
	CBB->(DBUnLock())
	Reclock("CBB",.f.)
Else
	cUltCont:=Space(TamSX3("CBB_NUM")[1])
	If ! lModelo1 // se for modelo 2 tem que verificar se tem autorizacao
		If CBA->CBA_AUTREC=="2" // BLOQUEADO
			VTBeep(3)
			VTAlert(STR0058,STR0017,.t.,4000) //'Atencao' //"Inventario bloqueado para auditoria"
			VTKeyBoard(chr(20))
			Return .F.
		EndIf
		cUltCont := CBUltCont(CBA->CBA_CODINV)
	EndIf
	Reclock("CBB",.T.)
	CBB->CBB_FILIAL := xFilial("CBB")
	CBB->CBB_NUM    := CBProxCod('MV_USUINV')
	CBB->CBB_CODINV := CBA->CBA_CODINV
	CBB->CBB_USU    := cCodOpe
	// CBB_NCONT  := nCont   // verificar necessidade
	CBB->CBB_STATUS := "1"
	CBB->(MsUnlock())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Incrementa numero de contagens realizadas do mestre          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CBAtuContR(CBB->CBB_CODINV, 1)

	Reclock("CBB",.F.)

	//-- transpor as contagens batidas para este usuario
	If ! lModelo1 .and. ! Empty(cUltCont)
		CBC->(DbSetOrder(1))
		CBC->(DbSeek(xFilial('CBC')+cUltCont))
		While CBC->(!Eof() .and. xFilial('CBC')+cUltCont == CBC_FILIAL+CBC_NUM)
			If CBC->CBC_CONTOK=="1"
				aadd(aCBC,array(CBC->(FCount())))
				For nX:= 1 to CBC->(FCount())
					aCBC[len(aCBC),nX] := CBC->(FieldGet(nX))
				Next
			EndIf
			CBC->(DbSkip())
		End
		For nX:= 1 to len(aCBC)
			Reclock("CBC",.t.)
			For nY := 1 to CBC->(FCount())
				If CBC->(FieldName(nY)) == "CBC_CODINV"
					CBC->CBC_CODINV    := CBB->CBB_CODINV
				ElseIf CBC->(FieldName(nY)) == "CBC_NUM"
					CBC->CBC_NUM    := CBB->CBB_NUM
				Else
					CBC->(FieldPut(nY,aCBC[nX,nY]))
				EndIf
			Next
			CBC->(MsUnLock())
		Next
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Analisando Classificacao por curva ABC                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cClasses := ""
If CBA->CBA_CLASSA=="1"
	cClasses+="A"
EndIf
If CBA->CBA_CLASSB=="1"
	cClasses+="B"
EndIf
If CBA->CBA_CLASSC=="1"
	cClasses+="C"
EndIf

CBLoadEst(aProdEnd)
If CBA->CBA_STATUS=='0'
	IniciaCBM(aProdEnd)
EndIf
RecLock("CBA",.f.)
If ! lModelo1 // se for modelo 2 tem que verificar se tem autorizacao
	CBA->CBA_AUTREC:="2" // BLOQUEADO
EndIf
CBA->CBA_STATUS := "1"  // 1=Em andamento
CBA->(MsUnlock())

If lV035VLDM
	   lRetorno := ExecBlock("V035VLDM",.F.,.F.)
	   lRetorno := If(ValType(lRetorno)=="L",lRetorno,.T.)
	   VTKeyBoard(chr(20))
	   If !lRetorno
	      Return .F.
	   Else
	      lRetorno:= NIL
	   Endif
Endif

If CBA->CBA_TIPINV =="2" .and. lAlert
	VTAlert(STR0035+CBA->CBA_LOCAL+STR0036+CBA->CBA_LOCALI,STR0002,.t.,4000) //"Va para o Armazem "###" Endereco "###"Aviso"
	cEndereco := CBA->CBA_LOCALI
EndIf
Return .T.

Static Function CBLoadEst(aProdEnd,lBloq)
Local cQuery	:= ""
Local cAliasSB8 := "SB8"
Local cAliasSBF := "SBF"
Local cClasses	:= ""
Local aArea		:= GetArea()
Local aAreaSB1	:= SB1->(GetArea())
Local aAreaSB2	:= SB2->(GetArea())
Local aAreaSBE	:= SBE->(GetArea())
Local aAreaSBF	:= SBF->(GetArea())
Local aAreaSB8	:= SB8->(GetArea())
Local lCBINV06	:= ExistBlock('CBINV06')
Local lSubLote	:= .F.
Local lNoLoop	:= .T.
Local lQuery	:= .F.
Local nTamLote 	:= TamSX3("B8_LOTECTL")[1]
Local nTamSLote	:= TamSX3("B8_NUMLOTE")[1]
Local nTamSeri	:= TamSX3("BF_NUMSERI")[1]
Local nTamEnd	:= TamSX3("BF_LOCALIZ")[1]
Local nX		:= 0
Local lWmsNew	:= SuperGetMv("MV_WMSNEW",.F.,.F.)
Local oSaldoWMS := Iif(lWmsNew,WMSDTCEstoqueEndereco():New(),Nil)
Local aSaldosWMS:= {}

default lBloq	:= .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Analisando Classificacao por curva ABC                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If CBA->CBA_CLASSA=="1"
	cClasses+="A"
EndIf
If CBA->CBA_CLASSB=="1"
	cClasses+="B"
EndIf
If CBA->CBA_CLASSC=="1"
	cClasses+="C"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Sempre inicializa a variavel com nenhuma informacao           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aProdEnd := {}

//cba tem que estar posicionado
If CBA->CBA_TIPINV == "1"  // Tipo do inventário / 1-Produto 2-Endereco
	If ! Empty(CBA->CBA_PROD)    // TEM PRODUTO
		SB2->(DbSetOrder(1)) // B2_FILIAL+B2_COD+B2_LOCAL
		If !SB2->(MsSeek(xFilial("SB2")+CBA->CBA_PROD+CBA->CBA_LOCAL))
			//CBAlert("Produto nao localizado na tabela de saldos!","Aviso",.T.,4000)
			RestArea(aAreaSB2)
			RestArea(aArea)
			Return
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se existe curva ABC para este mestre                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(cClasses) .And. !CBClABC(CBA->CBA_PROD,cClasses,.T.)
			Return
		EndIf
		If (SuperGetMV("MV_LOCALIZ") == "S") .And. Localiza(CBA->CBA_PROD,.T.)
			If !(lWmsNew .And. IntDL(CBA->CBA_PROD))
				DbSelectArea("SBF")
				SBF->(DbSetOrder(2)) //BF_FILIAL+BF_PRODUTO+BF_LOCAL+BF_LOTECLT+BF_NUMLOTE+BF_PRIOR+BF_LOCALIZ+BF_NUMSERI
				lQuery    := .T.
				cAliasSBF := "LOCLZ_"
				cQuery    := "SELECT BF_FILIAL, BF_PRODUTO, BF_LOTECTL, BF_NUMLOTE, BF_LOCAL, BF_LOCALIZ, BF_NUMSERI, BF_QUANT "
				cQuery    += "FROM "+RetSqlName("SBF")+" SBF "
				cQuery    += "WHERE SBF.BF_FILIAL ='"+xFilial("SBF")+"' AND "
				cQuery    += "SBF.BF_PRODUTO ='"+CBA->CBA_PROD+"' AND "
				cQuery    += "SBF.BF_LOCAL='"+CBA->CBA_LOCAL+"' AND "
				cQuery    += "SBF.D_E_L_E_T_ =' ' "
				cQuery    := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSBF,.T.,.T.)
				aEval(SBF->(dbStruct()), {|x| If(x[2] <> "C", TcSetField(cAliasSBF,x[1],x[2],x[3],x[4]),Nil)})

				While (cAliasSBF)->(!EOF() .And. If(lQuery,.T.,BF_FILIAL+BF_PRODUTO+BF_LOCAL == xFilial('SBF')+CBA->(CBA_PROD+CBA_LOCAL)))
					If lCBINV06
						lNoLoop := ExecBlock("CBINV06",.F.,.F.,{(cAliasSBF)->BF_PRODUTO,(cAliasSBF)->BF_LOCAL,(cAliasSBF)->BF_LOCALIZ,(cAliasSBF)->BF_NUMSERIE,(cAliasSBF)->BF_LOTECTL,(cAliasSBF)->BF_NUMLOTE})
						If ValType(lNoLoop)#"L"
							lNoLoop := .T.
						EndIf
						If !lNoLoop
							(cAliasSBF)->(DbSkip())
							Loop
						EndIf
					EndIf
					(cAliasSBF)->(aAdd(aProdEnd,{BF_PRODUTO,BF_LOTECTL,BF_NUMLOTE,BF_LOCAL,BF_LOCALIZ,BF_NUMSERI,BF_QUANT,Nil,Iif(lWmsnew,CriaVar('D14_IDUNIT', .F.),Nil)}))
					(cAliasSBF)->(DbSkip())
				EndDo

				If lQuery
					(cAliasSBF)->(DbCloseArea())
					DbSelectArea("SBF")
				EndIf
			Else
				// Executa a rotina que tem o mesmo conceito de consulta da SBF, somente quando for Wms Novo
				aSaldosWMS:=oSaldoWMS:GetSldEnd(CBA->CBA_PROD,CBA->CBA_LOCAL,CBA->CBA_LOCALI,,,,,.F.)
				If !Empty(aSaldosWMS)
					For nX := 1 to Len(aSaldosWMS)
						If !Empty(aSaldosWMS[nX][10])
							aAdd(aProdEnd,{aSaldosWMS[nX][10],aSaldosWMS[nX][3],aSaldosWMS[nX][4],aSaldosWMS[nX][1],aSaldosWMS[nX][2],aSaldosWMS[nX][5],aSaldosWMS[nX][6],NIL,aSaldosWMS[nX][11],aSaldosWMS[nX][12],})
						EndIf
					Next
				EndIf
			EndIf
		ElseIf Rastro(CBA->CBA_PROD)
			lSubLote := Rastro(CBA->CBA_PROD, 'S')
			DbSelectArea("SB8")
			SB8->(DbSetOrder(3)) //B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECLT+B8_NUMLOTE+DTOS(B8_DTVALID)

			lQuery    := .T.
			cAliasSB8 := "LOTES_"
			cQuery    := "SELECT B8_FILIAL, B8_PRODUTO, B8_LOCAL, B8_LOTECTL, B8_NUMLOTE, B8_DTVALID, B8_SALDO "
			cQuery    += "FROM "+RetSqlName("SB8")+" SB8 "
			cQuery    += "WHERE SB8.B8_FILIAL ='"+xFilial("SB8")+"' AND "
			cQuery    += "SB8.B8_PRODUTO ='"+CBA->CBA_PROD+"' AND "
			cQuery    += "SB8.B8_LOCAL='"+CBA->CBA_LOCAL+"' AND "
			cQuery    += "SB8.B8_SALDO > 0 AND "
			cQuery    += "SB8.D_E_L_E_T_ =' ' "
			cQuery    := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSB8,.T.,.T.)
			aEval(SB8->(dbStruct()), {|x| If(x[2] <> "C", TcSetField(cAliasSB8,x[1],x[2],x[3],x[4]),Nil)})

			While (cAliasSB8)->(!Eof() .And. If(lQuery,.T.,B8_FILIAL+B8_PRODUTO+B8_LOCAL == xFilial("SB8")+CBA->(CBA_PROD+CBA_LOCAL)) )
				If lQuery .Or. (cAliasSB8)->B8_SALDO > 0
					(cAliasSB8)->(aAdd(aProdEnd,{B8_PRODUTO,B8_LOTECTL,IIf(lSubLote,B8_NUMLOTE,Space(nTamSLote)),B8_LOCAL,Space(nTamEnd),Space(nTamSeri),B8_SALDO,B8_DTVALID}))
				EndIf
				(cAliasSB8)->(DbSkip())
			EndDo

			If lQuery
				(cAliasSB8)->(DbCloseArea())
				DbSelectArea("SB8")
			EndIf
		Else
			aAdd(aProdEnd,{SB2->B2_COD,Space(nTamLote),Space(nTamSLote),CBA->CBA_LOCAL,Space(nTamEnd),Space(nTamSeri),SB2->B2_QATU,Nil,Iif(lWmsnew,CriaVar('D14_IDUNIT', .F.),Nil)})
		EndIf

		If Empty(SB2->B2_DTINV) .And. lBloq
			RecLock("SB2",.F.)
			SB2->B2_DTINV := dDataBase
			SB2->(MsUnlock())
		EndIf
	Else  // TODOS OS PRODUTOS
		If (SuperGetMV("MV_LOCALIZ") == "S").And. Localiza(CBA->CBA_PROD)
			SBF->(DbSetOrder(1))

			lQuery    := .T.
			cAliasSBF := "LOCLZ_"
			cQuery    := "SELECT BF_FILIAL, BF_PRODUTO, BF_LOTECTL, BF_NUMLOTE, BF_LOCAL, BF_LOCALIZ, BF_NUMSERI, BF_QUANT "
			cQuery    += "FROM "+RetSqlName("SBF")+" SBF "
			cQuery    += "WHERE SBF.BF_FILIAL ='"+xFilial("SBF")+"' AND "
			cQuery    += "SBF.BF_LOCAL='"+CBA->CBA_LOCAL+"' AND "
			cQuery    += "SBF.D_E_L_E_T_ =' ' "
			cQuery    := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSBF,.T.,.T.)
			aEval(SBF->(dbStruct()), {|x| If(x[2] <> "C", TcSetField(cAliasSBF,x[1],x[2],x[3],x[4]),Nil)})

			While (cAliasSBF)->(!EOF() .And. If(lQuery,.T.,BF_FILIAL+BF_LOCAL == xFilial('SBF')+CBA->CBA_LOCAL))
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se existe curva ABC para este mestre                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(cClasses) .And. !CBClABC(cAliasSBF->BF_PRODUTO,cClasses, .T.)
					(cAliasSBF)->(DbSkip())
					Loop
				EndIf
				If lCBINV06
					lNoLoop := ExecBlock("CBINV06",.F.,.F.,{(cAliasSBF)->BF_PRODUTO,(cAliasSBF)->BF_LOCAL,(cAliasSBF)->BF_LOCALIZ,(cAliasSBF)->BF_NUMSERIE,(cAliasSBF)->BF_LOTECTL,(cAliasSBF)->BF_NUMLOTE})
					If ValType(lNoLoop)#"L"
						lNoLoop := .T.
					EndIf
					If !lNoLoop
						(cAliasSBF)->(DbSkip())
						Loop
					EndIf
				EndIf
				(cAliasSBF)->(aAdd(aProdEnd,{BF_PRODUTO,BF_LOTECTL,BF_NUMLOTE,BF_LOCAL,BF_LOCALIZ,BF_NUMSERI,BF_QUANT,Nil,Iif(lWmsnew,CriaVar('D14_IDUNIT', .F.),Nil)}))
				SB2->(DbSetOrder(1))
				SB2->(MsSeek(xFilial("SB2")+(cAliasSBF)->(BF_PRODUTO+BF_LOCAL)))
				If Empty(SB2->B2_DTINV) .And. lBloq
					RecLock("SB2",.F.)
					SB2->B2_DTINV := dDataBase
					SB2->(MsUnlock())
				EndIf
				(cAliasSBF)->(DbSkip())
			EndDo

			If lQuery
				(cAliasSBF)->(DbCloseArea())
				DbSelectArea("SBF")
			EndIf
		Else
			SB2->(DbSetOrder(1)) //B2_FILIAL+B2_COD+B2_LOCAL
			cAliasSB8 := "LOTES_"
			cQuery	:= "SELECT SB2.B2_COD, SB2.B2_LOCAL, B2_QATU, SB8.B8_LOTECTL, SB8.B8_NUMLOTE, SB8.B8_SALDO, SB8.B8_DTVALID, SBF.BF_LOCALIZ, SBF.BF_NUMSERI "
			cQuery	+= "FROM "+RetSqlName("SB2")+" SB2 "
			cQuery	+= "LEFT JOIN "+RetSqlName("SB8")+" SB8 ON "
			cQuery	+= "SB8.B8_FILIAL=SB2.B2_FILIAL AND SB8.B8_PRODUTO=SB2.B2_COD AND SB8.B8_LOCAL='"+CBA->CBA_LOCAL+"' AND SB8.D_E_L_E_T_ =' ' "
			cQuery	+= "LEFT JOIN "+RetSqlName("SBF")+" SBF ON "
			cQuery	+= "SBF.BF_FILIAL=SB2.B2_FILIAL AND SBF.BF_PRODUTO=SB2.B2_COD AND SBF.BF_LOCAL='"+CBA->CBA_LOCAL+"'	AND SBF.D_E_L_E_T_ =' ' "
			cQuery  += "WHERE SB2.B2_FILIAL ='"+xFilial("SB2")+"' AND "
			cQuery  += "SB2.B2_LOCAL='"+CBA->CBA_LOCAL+"' AND "
			cQuery  += "SB2.D_E_L_E_T_ =' ' "
			cQuery  := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSB8,.T.,.T.)
			aEval(SB2->(dbStruct()), {|x| If(x[2] <> "C", TcSetField(cAliasSB8,x[1],x[2],x[3],x[4]),Nil)})
			aEval(SB8->(dbStruct()), {|x| If(x[2] <> "C", TcSetField(cAliasSB8,x[1],x[2],x[3],x[4]),Nil)})
			While (cAliasSB8)->(!Eof())
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se existe curva ABC para este mestre                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(cClasses) .And. !CBClABC((cAliasSB8)->B2_COD,cClasses,.T.)
					(cAliasSB8)->(DbSkip())
					Loop
				EndIf
				If !Rastro((cAliasSB8)->B2_COD)
					If Empty((cAliasSB8)->BF_LOCALIZ)
						(cAliasSB8)->(aAdd(aProdEnd,{B2_COD,Space(nTamLote),Space(nTamSLote),B2_LOCAL,Space(nTamEnd),Space(nTamSeri),B2_QATU,Nil,Iif(lWmsnew,CriaVar('D14_IDUNIT', .F.),Nil)}))
					Else
						(cAliasSB8)->(aAdd(aProdEnd,{B2_COD,Space(nTamLote),Space(nTamSLote),B2_LOCAL,BF_LOCALIZ,BF_NUMSERI,B2_QATU,Nil,Iif(lWmsnew,CriaVar('D14_IDUNIT', .F.),Nil)}))
					EndIf
				ElseIf !Empty((cAliasSB8)->B8_NUMLOTE)
					If Empty((cAliasSB8)->BF_LOCALIZ)
						lSubLote := Rastro((cAliasSB8)->B2_COD,'S')
						(cAliasSB8)->(aAdd(aProdEnd,{B2_COD,B8_LOTECTL,IIf(lSubLote,B8_NUMLOTE,Space(nTamSLote)),B2_LOCAL,Space(nTamEnd),Space(nTamSeri),B8_SALDO,B8_DTVALID,}))
					Else
						lSubLote := Rastro((cAliasSB8)->B2_COD,'S')
						(cAliasSB8)->(aAdd(aProdEnd,{B2_COD,B8_LOTECTL,IIf(lSubLote,B8_NUMLOTE,Space(nTamSLote)),B2_LOCAL,BF_LOCALIZ,BF_NUMSERI,B8_SALDO,B8_DTVALID,}))
					EndIf
				EndIf
				If SB2->(MsSeek(xFilial("SB2")+(cAliasSB8)->B2_COD+(cAliasSB8)->B2_LOCAL))
					If Empty(SB2->B2_DTINV) .And. lBloq
						RecLock("SB2",.F.)
						SB2->B2_DTINV := dDataBase
						SB2->(MsUnlock())
					EndIf
				EndIf
				(cAliasSB8)->(DbSkip())
			EndDo
			(cAliasSB8)->(DbCloseArea())
		EndIf
	EndIf
Else
	SBE->(dbSetOrder(1))
	If SBE->(dbSeek(xFilial('SBE')+CBA->(CBA_LOCAL+CBA_LOCALI))) .And. lBloq
		RecLock("SBE",.F.)
		SBE->BE_DTINV  := dDatabase
		If lWmsNew
			SBE->BE_STATUS  := "6"
		Endif
		SBE->(MsUnlock())
	Endif
	SBF->(DbSetOrder(1))
	SBF->(DbSeek(xFilial('SBF')+CBA->(CBA_LOCAL+CBA_LOCALI)))
	While SBF->(! EOF() .And. BF_FILIAL+BF_LOCAL+BF_LOCALIZ == xFilial('SBF')+CBA->(CBA_LOCAL+CBA_LOCALI))
		If lCBINV06
			lNoLoop := ExecBlock("CBINV06",.F.,.F.,{SBF->BF_PRODUTO,SBF->BF_LOCAL,SBF->BF_LOCALIZ,SBF->BF_NUMSERIE,SBF->BF_LOTECTL,SBF->BF_NUMLOTE})
			If ValType(lNoLoop)#"L"
				lNoLoop := .T.
			EndIf
			If !lNoLoop
				SBF->(DbSkip())
				Loop
			EndIf
		EndIf
		If ExistCpo("SB1",SBF->BF_PRODUTO,1,,.F.)
			aAdd(aProdEnd,{SBF->BF_PRODUTO,SBF->BF_LOTECTL,SBF->BF_NUMLOTE,SBF->BF_LOCAL,SBF->BF_LOCALIZ,SBF->BF_NUMSERI,SBF->BF_QUANT,Nil,Iif(lWmsnew,CriaVar('D14_IDUNIT', .F.),Nil)})
		EndIf
		SBF->(DbSkip())
	EndDo
	// Executa a rotina que tem o mesmo conceito de consulta da SBF, somente quando for Wms Novo
	If lWmsNew
		aSaldosWMS:=oSaldoWMS:GetSldEnd(,CBA->CBA_LOCAL,CBA->CBA_LOCALI,,,,,.F.)
		If !Empty(aSaldosWMS)
			For nX := 1 to Len(aSaldosWMS)
				If !Empty(aSaldosWMS[nX][10]) .And. AcdCopVal("VLE", aSaldosWMS[nX][1],,,aSaldosWMS[nX][10])
					aAdd(aProdEnd,{aSaldosWMS[nX][10],aSaldosWMS[nX][3],aSaldosWMS[nX][4],aSaldosWMS[nX][1],aSaldosWMS[nX][2],aSaldosWMS[nX][5],aSaldosWMS[nX][6],NIL,aSaldosWMS[nX][11],aSaldosWMS[nX][12]})
				EndIf
			Next
		EndIf
	EndIf


EndIf
RestArea(aAreaSBF)
RestArea(aAreaSBE)
RestArea(aAreaSB2)
RestArea(aAreaSB8)
RestArea(aAreaSB1)
RestArea(aArea)
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ EtiqEnd    ³ Autor ³ TOTVS               ³ Data ³ 01/01/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao de Endereco							          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ACDV035                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function EtiqEnd()
Local aEtiqueta
If Empty(cEtiqEnd)
	Return .F.
EndIF
aEtiqueta := CBRetEti(cEtiqEnd,"02")
If Len(aEtiqueta) ==0
	VTBeep(3)
	VTAlert(STR0020,STR0002,.t.,4000) //'Etiqueta invalida'###'Aviso'
	VTKeyBoard(chr(20))
	Return .F.
EndIf
cEndereco := aEtiqueta[1]
cArmazem  := aEtiqueta[2]
@ 3,0 VTSay Padr(cEndereco,20)
Return VldEnd()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VldEnd     ³ Autor ³ TOTVS               ³ Data ³ 01/01/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao de Endereco							          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ACDV035                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function VldEnd(cLocal,cEnd)
Local lRet := .T.
Local lWmsNew		   := SuperGetMv("MV_WMSNEW",.F.,.F.)
Local lUniCPO		   := CBC->(ColumnPos("CBC_IDUNIT")) > 0
Default cLocal = ""
Default cEnd   = ""


SBE->(dbSetOrder(11))
If SBE->(dbSeek( FWxFilial("SBE") + cArmazem + Alltrim(cEndereco)))
	cEndereco := SBE->BE_LOCALIZ
Endif

If ExistBlock('CBINV02')
	lRet := ExecBlock("CBINV02",,,{cArmazem,cEndereco})
	If ValType(lRet)#"L"
		lRet := .T.
	EndIf
	If !lRet
		VTKeyBoard(chr(20))
		Return .F.
	EndIf
EndIf

If Empty(cArmazem) .Or. Empty(cEndereco)
	cArmazem  := IF(!Empty(cLocal),cLocal,cArmazem)
	cEndereco := IF(!Empty(cEnd),cEnd,cEndereco)
EndIf
if lUniCPO .and. lWmsNew
	If AcdCopVal("END",cArmazem,cEndereco)
		lVldTelWMS := .T.
	EndIf
EndIf


If CBA->CBA_TIPINV == "2"  // 2=Por Endereco
	If ! CBA->CBA_LOCAL == cArmazem .or. ! CBA->CBA_LOCALI == cEndereco
		VTBeep(3)
		VTAlert(STR0022+chr(13)+CHR(10)+STR0023+CBA->CBA_LOCAL+"-"+CBA->CBA_LOCALI,STR0017,.t.,4000) //'Armazem e endereco incorreto.'###'O correto seria:'###'Atencao'
		VtClearGet("cArmazem")
		VtClearGet("cEndereco")
		VtGetSetFocus("cArmazem")
		VTKeyBoard(chr(20))
		Return .F.
	EndIf
ElseIf AllTrim(CBA->CBA_LOCALI) == "" .And. AllTrim(CBA->CBA_PROD) == ""
   		Return .T.
Else
	SBE->(DbSetOrder(1))
	If !SBE->(MsSeek(xFilial('SBE')+cArmazem+cEndereco))
		VTBeep(3)
		VTAlert(STR0024,STR0017,.t.,4000) //'Endereco nao cadastrado.'###'Atencao'
		VtClearGet("cArmazem")
		VtClearGet("cEndereco")
		VtGetSetFocus("cArmazem")
		VTKeyBoard(chr(20))
		Return .F.
	EndIf
EndIf
Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VldEtiPro  ³ Autor ³ TOTVS               ³ Data ³ 01/01/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao de Etiqueta ou Produto					          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ACDV035                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function VldEtiPro(nOpc)
Local aEtiqueta
Local nQE
Local nQuant
Local nQtdEtiq2
Local cArm2
Local cEnd2
Local cNumSeri
Local aSave
Local aItensPallet := CBItPallet(cEtiqProd)
Local lIsPallet := .t.
Local nP, nX
Local aLidos    := {}
Local lCBINV01  := ExistBlock('CBINV01')
Local lCBINV04  := ExistBlock('CBINV04')
Local lCBINVVAl := ExistBlock("CBINVVAL")
Local lV035ALTQTD:=	ExistBlock("V035ALTQTD")
Local llocaliz	:= GetMv('MV_LOCALIZ') =="S"
Local lRet 	    := .T.
Local lWmsNew	:= SuperGetMv("MV_WMSNEW",.F.,.F.)
Local lUniCPO	  := CBC->(ColumnPos("CBC_IDUNIT")) > 0
Local lAltend :=	GetMV("MV_ALTENDI") == "0"
Local lB5CtrWms := .F.
Local lIteUnit  := .F.
Local oProdComp := IIf(lWmsNew,WMSDTCProdutoComponente():New(),Nil)
Local lCTRWMS 	:= ""
Local cPrdOri   := ""
Local cProduto  := ''
Local nQtdAux	:= 0

Local cAuxCust := ""

Private cLote   := Space(TamSX3("B8_LOTECTL")[1])
Private cSLote  := Space(TamSX3("B8_NUMLOTE")[1])
cLote	  := PADR(QbrString(2,cEtiqProd),TamSX3("B8_LOTECTL")[1])//CUSTOMIZADO
cEtiqProd := QbrString(1,cEtiqProd) //CUSTOMIZADO

If Empty(cEtiqProd)
	Return .f.
EndIf

ConvQtd(cEtiqProd,cArmazem,nQtdEtiq)

If lUsaCB001
	aEtiqueta := CBRetEti(cEtiqProd,"01",.T.,.T.)
	If Len(aEtiqueta)> 0
		cProduto  := aEtiqueta[01]
		If !ExistCpo("SB1",cProduto)
			Return .F.
		EndIf
	EndIF
Else
	aEtiqueta := CBRetEtiEan(cEtiqProd)
	If Len(aEtiqueta)> 0
		cProduto  := aEtiqueta[01]
		If !ExistCpo("SB1",cProduto)
			Return .F.
		EndIf
	EndIF
EndIf

//---------------------------------------//
// Validacao produto WMS                 //
//---------------------------------------//
If lWmsNew
	DbSelectArea("SB5")
	DbSetOrder(1)
	If SB5->(MsSeek(xFilial("SB5")+cProduto))
		If SB5->B5_CTRWMS == "1"
			lB5CtrWms := .T.
			If !Empty(cCodUnit)
				lIteUnit := .T.
			EndIf
		EndIf
	EndIf
EndIf

If len(aItensPallet) == 0
	aItensPallet:={cEtiqProd}
	lIsPallet := .f.
EndIf

Begin Sequence
For nP := 1 to len(aItensPallet)
	cEtiqProd:=Padr(aItensPallet[nP],48)

	If lCBINV01
		cEtiqProd := ExecBlock("CBINV01",,,{cArmazem,cEndereco,cEtiqProd})
		If ValType(cEtiqProd)#"C"
			cEtiqProd:=Padr(aItensPallet[nP],48)
		EndIf
	EndIf
	If lUsaCB001
		aEtiqueta := CBRetEti(cEtiqProd,"01",.T.,.T.)
		If Len(aEtiqueta) == 0 .Or. CB0->CB0_STATUS $"12"
			VTBeep(3)
			VTAlert(STR0020,STR0002,.t.,4000) //'Etiqueta invalida'###'Aviso'
			break
		EndIf
		If aEtiqueta[10] <> cArmazem
			VTBeep(3)
			VTAlert(STR0113,STR0017,.t.,4000) //"Armazem da etiqueta difere do Mestre de Inventario!"###'Atencao'
			Return .F.
		EndIf
		If A166VldCB9(aEtiqueta[1], CB0->CB0_CODETI)
			VTBeep(3)
			VTAlert(STR0088,STR0002,.t.,3000) //"Etiqueta Invalida"###"Aviso"
			break
		EndIf
		If ! lIsPallet .and. ! Empty(CB0->CB0_PALLET)
			VTBeep(3)
			VTAlert(STR0020+STR0064,STR0002,.t.,4000) //'Etiqueta invalida'", produto pertence a um pallet "###'Aviso'
			break
		EndIf
		cProduto := aEtiqueta[01]
		nQtdEtiq2:= aEtiqueta[02]
		//cLote    := aEtiqueta[16]
		cSLote   := aEtiqueta[17]
		cArm2    := aEtiqueta[10]
		cEnd2    := aEtiqueta[09]
		cNumSeri := CB0->CB0_NUMSER
		SB1->(DbSetOrder(1))
		If !SB1->(MsSeek(xFilial("SB1")+cProduto))
			VTBeep(3)
			VTAlert(STR0030,STR0017,.t.,4000) //'Produto nao cadastrado.'###'Atencao'
			break
		EndIf

		//Para evitar problemas na execucao da rotina automatica que gera SB7
		//Sera incluida aqui a validacao do valido do B7_LOCAL (by Erike)
		SB2->(DbSetOrder(1))
		If !SB2->(MsSeek(xFilial("SB2")+cProduto+cArm2))
			CriaSB2(cProduto,cArm2)
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Analisando Classificacao por curva ABC, somente inv. por prod.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If CBA->CBA_TIPINV == "1" .and. !Empty(cClasses) .and. !CBClABC(cProduto,cClasses)
			VTBeep(3)
			VTAlert(STR0066+cClasses+STR0067,STR0017,.t.,4000) //'Produto nao pertence a(s) classe(s) "'###'" da curva ABC!'
			break
		EndIf

		If llocaliz
			If nOpc == 1 // --> Inventario por Mestre
				If CBA->CBA_TIPINV == "1" .and. RetFldProd(cProduto,"B1_LOCALIZ") == "S" .and. Empty(cEnd2)
					VTBeep(3)
					VTAlert(STR0068,STR0002,.t.,4000) //"Etiqueta de produto sem endereco"###'Aviso'
					break
				Elseif CBA->CBA_TIPINV == "2" .and. RetFldProd(cProduto,"B1_LOCALIZ") == "S" .and. Empty(cEnd2)
					VTBeep(3)
					VTAlert(STR0068,STR0002,.t.,4000) //"Etiqueta de produto sem endereco"###'Aviso'
					break
				Elseif CBA->CBA_TIPINV == "2" .and. RetFldProd(cProduto,"B1_LOCALIZ") # "S"
					VTBeep(3)
					VTAlert(STR0069,STR0002,.t.,4000) //"Produto sem controle de endereco"###"Aviso"
					break
				Endif
			Elseif nOpc == 2 // --> Inventario por Produto
				If RetFldProd(cProduto,"B1_LOCALIZ") == "S" .and. Empty(cEnd2)
					VTBeep(3)
					VTAlert(STR0068,STR0002,.t.,4000) //"Etiqueta de produto sem endereco"###'Aviso'
					break
				Endif
			Else // --> Inventario por Endereco
				If RetFldProd(cProduto,"B1_LOCALIZ") # "S"
					VTBeep(3)
					VTAlert(STR0069,STR0002,.t.,4000) //"Produto sem controle de endereco"###"Aviso"
					break
				Elseif RetFldProd(cProduto,"B1_LOCALIZ") == "S" .and. Empty(cEnd2)
					VTBeep(3)
					VTAlert(STR0068,STR0002,.t.,4000) //"Etiqueta de produto sem endereco"###'Aviso'
					break
				Endif
			Endif
		Endif
		If Empty(aEtiqueta[2])
			nQtdEtiq2:= 1
		EndIf
		nQE:= 1
		If ! CBProdUnit(aEtiqueta[1])
			nQE := CBQtdEmb(aEtiqueta[1])
			If empty(nQE)
				break
			EndIf
			CBC->(DBSetOrder(1))
			If CBC->(DBSeek(xFilial('CBC')+CBB->CBB_NUM+CB0->CB0_CODETI))
				VTBeep(3)
				VTAlert(STR0026,STR0002,.t.,4000) //'Codigo ja lido'###'Aviso'
				break
			EndIf
			If Localiza(aEtiqueta[1])
				If lAltend
					IF ! Empty(cEnd2) .and. ! cArm2+cEnd2 == cArmazem+cEndereco
						VTBeep(3)
						VTAlert(STR0025+cArm2+'-'+cEnd2,STR0002,.t.,4000) //'Produto pertence ao endereco:'###'Aviso'
						break
					EndIf
				EndIf
			EndIf
		Else
			If CBQtdVar(aEtiqueta[1]) .and. ! lIsPallet
				aSave   := VTSAVE()
				VTClear()
				@ 2,0 VTSay STR0070 //"Produto com "
				@ 3,0 VtSay STR0071  //"Qtde variavel"
				@ 4,0 VtGet nQE pict CBPictQtde()
				VTREAD
				VtRestore(,,,,aSave)
				If VTLastKey() == 27
					VTAlert(STR0072,STR0002,.t.,3000) //"Quantidade Invalida"###"Aviso"
					VTKeyboard(chr(20))
					Return .f.
				EndIf
				nQtdEtiq2:= nQE
				nQE:= 1
			EndIf
			CBC->(DBSetOrder(1))
			If CBC->(DBSeek(xFilial('CBC')+CBB->CBB_NUM+CB0->CB0_CODETI))
				VTBeep(3)
				VTAlert(STR0026,STR0002,.t.,4000) //'Codigo ja lido'###'Aviso'
				break
			EndIf
			If Localiza(aEtiqueta[1])
				IF ! cArm2+cEnd2 == cArmazem+cEndereco
					If lAltend
						VTBeep(3)
						VTAlert(STR0025+cArm2+'-'+cEnd2,STR0002,.t.,4000) //'Produto pertence ao endereco:'###'Aviso'
						break
					EndIf
				EndIF
			EndIf
		EndIF

		If lV035ALTQTD
			nQtdAux := ExecBlock("V035ALTQTD",.F.,.F.,{nQtdEtiq})
			If ValType(nQtdAux) = "N"
				nQtdEtiq := nQtdAux
				VTGetRefresh('nQtdEtiq')
			EndIf
		EndIf

		nQuant := nQE*nQtdEtiq*nQtdEtiq2
	Else
		If ! CBLoad128(@cEtiqProd)
			VTAlert(STR0027,STR0002,.t.,4000,3) //'Leitura invalida'###'Aviso'
			VTKeyBoard(chr(20))
			Return .f.
		Endif
		cTipId:=CBRetTipo(cEtiqProd)
		If ! cTipId $ "EAN8OU13-EAN14-EAN128"
			VTALERT(STR0028,STR0002,.T.,4000,3)   //"Etiqueta invalida."###"Aviso"
			VTKeyboard(chr(20))
			Return .f.
		EndIf
		aEtiqueta := CBRetEtiEan(cEtiqProd)
		If Len(aEtiqueta) == 0
			VTAlert(STR0029,STR0002,.t.,4000,3) //'Etiqueta invalida!!'###'Aviso'
			VTKeyBoard(chr(20))
			Return .f.
		EndIf
		cProduto  := aEtiqueta[01]
		nQtdEtiq2 := aEtiqueta[02]
		//cLote     := aEtiqueta[03]
		cNumSeri  := aEtiqueta[05]
		nQE       := 1
		//-- SubLote: retornado no PE CBRETEAN (CBRetEtiEAN/ACDXFUN)
		If Len(aEtiqueta)>5
			cSLote := aEtiqueta[06]
		EndIf

		lCtrWms := IntDl(cProduto)

		If CBA->CBA_TIPINV=="2" .And. !Localiza(cProduto,IIF((lWmsNew .And. lCtrWms),.T.,.F.),.T.)
			If !MTVerPai(cProduto,.F.)
				VTAlert(STR0117,STR0002,.t.,4000,3)
			Else
				VTAlert(STR0069,STR0002,.t.,4000,3) //"Produto sem controle de endereco"###"Aviso"
			EndIf
			break
		EndIf

		If ! CBProdUnit(aEtiqueta[1])
			nQE := CBQtdEmb(aEtiqueta[1])
			If	Empty(nQE)
				VTKeyboard(chr(20))
				Return .f.
			EndIf
			nQtdEtiq2 := 1
		EndIf

		If lV035ALTQTD
			nQtdAux := ExecBlock("V035ALTQTD",.F.,.F.,{nQtdEtiq})
			If ValType(nQtdAux) = "N"
				nQtdEtiq := nQtdAux
				VTGetRefresh('nQtdEtiq')
			EndIf
		EndIf

		nQuant := nQE*nQtdEtiq*nQtdEtiq2
		If CBChkSer(aEtiqueta[1]) .And. ! CBNumSer(@cNumseri,Nil,aEtiqueta)
			Return .f.
		EndIf
		If !Empty(cNumseri)
		SBF->(DbSetorder(4))
			If !SBF->(DbSeek(xFilial("SBF")+cProduto+cNumseri)).And. lAltend
	            VTAlert(STR0084+cNumseri+STR0110,STR0021,.T.,3000) // N.serie: inválido #Aviso#
	            If !VTYesNo(STR0118+cNumseri,STR0002,.t.)
					 VTKeyBoard(chr(20))
					Return .F.
				  EndIF
			EndIf
		EndIf
	EndIf
	SB1->(DbSetOrder(1))
	If !SB1->(MsSeek(xFilial('SB1')+cProduto))
		VTBeep(3)
		VTAlert(STR0030,STR0017,.t.,4000) //'Produto nao cadastrado.'###'Atencao'
		VTKeyBoard(chr(20))
		Return .F.
	EndIf
    If lAltend .And. RetFldProd(cProduto,"B1_LOCALIZ") == "S" .And. Empty(cEndereco) .And. Empty(cNumseri)
	    VTAlert(STR0111,STR0021,.T.,3000)  //"Endereco e numero de serie em branco, informe a localização do produto"   #Aviso#
		VtClearGet("cEtiqProd")
		VtClearGet("cEndereco")
		VtGetSetFocus("cEndereco")
        Return .F.
    EndIf


    SBE->(DbSetOrder(1)) // Verificar se o endereco informado existe na tabela SBE
	If !SBE->(MsSeek(xFilial('SBE')+cArmazem+cEndereco)) .And. !Empty(cEndereco)
		VTBeep(3)
		If RetFldProd(cProduto,"B1_LOCALIZ") == "S"
			VTAlert(STR0024,STR0017,.T.,4000) //'Endereco nao cadastrado.'###'Atencao'
		Else
			VTAlert(STR0114,STR0017,.T.,4000)//Produto não utilzia endereco.'###'Atencao'
		EndIf
		VtClearGet("cEndereco")
		VtGetSetFocus("cEndereco")
		VTKeyBoard(chr(20))
		Return .F.
	EndIf

	//Para evitar problemas na execucao da rotina automatica que gera SB7
	//Sera incluida aqui a validacao do valido do B7_LOCAL (by Erike)
	SB2->(DbSetOrder(1))
	If !SB2->(DbSeek(xFilial("SB2")+cProduto+cArmazem))
		CriaSB2(cProduto,cArmazem)
		If lWmsNew .And. IntDL(cProduto)
			oProdComp:SetPrdCmp(cProduto)
			If oProdComp:LoadData(2)
				cPrdOri := oProdComp:GetPrdOri()
			EndIf
			If !Empty(cPrdOri) .And. !SB2->(DbSeek(xFilial("SB2")+cPrdOri+cArmazem))
				CriaSB2(cPrdOri,cArmazem)
			EndIf
		EndIf
	EndIf

	If CBA->CBA_TIPINV == "1"  // 1=Por Produto
		//-------------------------------//
		//Verifica se o item e unitizado//
		//------------------------------//
		If lIteUnit
			VTBeep(3)
			VTAlert(STR0122,STR0002,.t.,4000)// Produto unitizado deve ser utilizado no inventario por endereco
			VTKeyBoard(chr(20))
			Return .F.
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Analisando Classificacao por curva ABC, somente inv. por prod.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(cClasses) .and. !CBClABC(cProduto,cClasses)
			VTBeep(3)
			VTAlert(STR0066+cClasses+STR0067,STR0017,.t.,4000) //'Produto nao pertence a(s) classe(s) "'###'" da curva ABC!'
			VTKeyBoard(chr(20))
			Return .F.
		EndIf

		If ! CBA->CBA_PROD == cProduto .and. ! Empty(CBA->CBA_PROD)
			VTBeep(3)
			VTAlert(STR0031,STR0017,.t.,4000) //'Produto diferente do que deve ser inventariado.'###'Atencao'
			VTKeyBoard(chr(20))
			Return .F.
		EndIf
	EndIf
	If lIteUnit
		If !AcdCopVal('VLP',cArmazem,,,cProduto)
			Return .F.
		EndIf
	EndIf

	If lCBINV04
		ExecBlock("CBINV04",.F.,.F.)
	Endif
	If Rastro(cProduto)
		If ! CBRastro(cProduto,@cLote,@cSLote)
			VTKeyBoard(chr(20))
			Return .f.
		EndIf
		If !V35VldLot(cProduto,cArmazem,cLote,cSLote,cPrdOri)
			VTKeyBoard(chr(20))
			Return .f.
		EndIf
	EndIf

	If lCBINVVAL
		lRet := ExecBlock("CBINVVAL",.F.,.F.)
		If ValType(lRet)== "L"
			If !lRet
				Return .F.
			EndIf
		EndIf
	EndIf

	If lUsaCB001
		CBC->(DBSetOrder(1))
		If CBC->(DBSeek(xFilial('CBC')+CBB->CBB_NUM+CB0->CB0_CODETI))
			RecLock("CBC",.f.)
		Else
			RecLock("CBC",.T.)
			CBC->CBC_FILIAL := xFilial("CBC")
			CBC->CBC_CODINV := CBB->CBB_CODINV
			CBC->CBC_NUM    := CBB->CBB_NUM
			CBC->CBC_LOCAL  := cArmazem
			CBC->CBC_LOCALI := cEndereco
			CBC->CBC_COD    := cProduto
			CBC->CBC_CODETI := CB0->CB0_CODETI
			CBC->CBC_LOTECT := cLote
			CBC->CBC_NUMLOT := cSLote
			CBC->CBC_NUMSER := cNumSeri
			aadd(aLidos,CB0->CB0_CODETI)
		EndIf
		CBC->CBC_QUANT  += nQuant
		CBC->CBC_QTDORI += nQuant
		CBC->(MsUnlock())
	Else
		CBC->(DBSetorder(2))
		If !lUniCPO .Or. !lWmsNew
			If ! CBC->(DbSeek(xFilial('CBC')+CBB->CBB_NUM+cProduto+cArmazem+cEndereco+cLote+cSLote+cNumSeri))
				RecLock("CBC",.T.)
				CBC->CBC_FILIAL := xFilial("CBC")
				CBC->CBC_CODINV := CBB->CBB_CODINV
				CBC->CBC_NUM    := CBB->CBB_NUM
				CBC->CBC_LOCAL  := cArmazem
				CBC->CBC_LOCALI := cEndereco
				CBC->CBC_COD    := cProduto
				CBC->CBC_LOTECT := cLote
				CBC->CBC_NUMLOT := cSLote
				CBC->CBC_NUMSER := cNumSeri
			Else
				If ! lModelo1
					If CBC->CBC_CONTOK =="1"
						VTBeep(3)
						VTAlert(STR0073,STR0074,.t.,4000)  //"Nao eh necessario a recontagem!!!"###"Produto ja auditado"
						VTKeyBoard(chr(20))
						Return .F.
					EndIf
				EndIf
				RecLock("CBC",.f.)
			EndIf
		Else
			If ! CBC->(DbSeek(xFilial('CBC')+CBB->CBB_NUM+cProduto+cArmazem+cEndereco+cLote+cSLote+cNumSeri+cCodUnit))
				RecLock("CBC",.T.)
				CBC->CBC_FILIAL := xFilial("CBC")
				CBC->CBC_CODINV := CBB->CBB_CODINV
				CBC->CBC_NUM    := CBB->CBB_NUM
				CBC->CBC_LOCAL  := cArmazem
				CBC->CBC_LOCALI := cEndereco
				CBC->CBC_COD    := cProduto
				CBC->CBC_LOTECT := cLote
				CBC->CBC_NUMLOT := cSLote
				CBC->CBC_NUMSER := cNumSeri
				CBC->CBC_IDUNIT := cCodUnit
				CBC->CBC_CODUNI := cCodTpUni
			Else
				If ! lModelo1
					If CBC->CBC_CONTOK =="1"
						VTBeep(3)
						VTAlert(STR0073,STR0074,.t.,4000)  //"Nao eh necessario a recontagem!!!"###"Produto ja auditado"
						VTKeyBoard(chr(20))
						Return .F.
					EndIf
				EndIf
				RecLock("CBC",.f.)
			EndIf
		EndIf
		CBC->CBC_QUANT  += nQuant //RODOLFO - NESTE MOMENTO AINDA NAO TEM A QTD
		CBC->CBC_QTDORI += nQuant
		CBC->(MsUnlock())
	EndIf

	If lWmsNew .And. lUniCPO
		ACD35CBM(3,CBA->CBA_CODINV,cProduto,cArmazem,cEndereco,cLote,cSLote,cNumSeri,cCodUnit,cCodTpUni)
	Else
		ACD35CBM(3,CBA->CBA_CODINV,cProduto,cArmazem,cEndereco,cLote,cSLote,cNumSeri)
	EndIf
Next
If lForcaQtd
	VtSay(7,0,Space(19))
	cEtiqProd:= Space(48)
	nQtdEtiq := 0 //Rodolfo Mudei pra zero
	VtGetSetFocus('cEtiqProd')
	VtGetSetFocus('nQtdEtiq')
	VtKeyBoard(CHR(27)) // Rodolfo - volta cursor pro campo de cima
Else
	VTKeyBoard(chr(20))
	nQtdEtiq :=1
	VTGetRefresh('nQtdEtiq')
EndIf
Return .f.
End Sequence
// se passar aqui e' porque ocorreum alguma consistencia
For nX:= 1 to len(aLidos)
	CBC->(DBSetOrder(1))
	If CBC->(DBSeek(xFilial('CBC')+CBB->CBB_NUM+aLidos[nX]))
		RecLock("CBC",.f.)
		CBC->(DbDelete())
		CBC->(MsUnlock())
	EndIf
Next
VTKeyBoard(chr(20))
nQtdEtiq :=1
VTGetRefresh('nQtdEtiq')
Return .f.

Static Function Ultimo()
Local lIsLast:= .t.
Local nReg := CBB->(Recno())
RecLock('CBA',.f.)
CBB->(DbUnLock())
CBB->(DBSetOrder(1))
CBB->(DBSeek(xFilial('CBB')+CBA->CBA_CODINV))
While CBB->(!eof()) .and. CBB->CBB_CODINV == CBA->CBA_CODINV
	If ! CBB->(Rlock())
		lIsLast := .f.
		Exit
	EndIf
	CBB->(DBSkip())
EndDo
CBB->(MsGoto(nReg))
RecLock('CBB',.f.)
CBA->(DbUnLock())
Return lIsLast

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ AnalisaInv ³ Autor ³ TOTVS               ³ Data ³ 01/01/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Tem o objetivo de invalidar etiquetas nao lidas e  		  ³±±
±±³        	 ³atualizar valores(quantidade) no CB0.       			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³lMonitor Indica se o programa que fara a analise			  ³±±
±±³			 ³sera o Monitor de inv(protheus) ou RF.					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno:  ³Array, onde:                                      		  ³±±
±±³          ³array[1]: Logico indic se existe divergencia nas contagens  ³±±
±±³          ³array[2]: Array listando produtos sem diergencia   		  ³±±
±±³          ³array[3]: Array listando etiquetas sem divergencia 		  ³±±
±±³          ³array[4]: Array listando todas etiquetas lidas.    		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ACDV035                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function AnalisaInv(lMonitor)
Local aProds  := {}
Local aProdAux:= {}
Local aProdOK := {}
Local aProdOK2:= {}
Local aProdNoOk:={}
Local aEtiQtdOK:={}
Local aEtiLidas:={}
Local nPos
Local nLen
Local i, j
Local cCodCBB := CBB->CBB_NUM
Local cAux:=''
Local nSaldo
Local cProduto,cArm,cEnd,cLote,cSLote,cNumSeri,cIdunit,cCodUnit
Local lOK:= .f.
Local lModelo1 := SuperGetMv("MV_CBINVMD")=="1"
Local lUsaCB001:=UsaCB0("01")
Local nTamProd	:= Tamsx3("B1_COD")[1]
Local nTamArm	:= TamSx3("B2_LOCAL")[1]
Local nTamEnd	   	:= TamSX3("BF_LOCALIZ")[1]
Local nTamSeri   	:= TamSX3("BF_NUMSERI")[1]
Local nTamLote   	:= TamSX3("B8_LOTECTL")[1]
Local nTamSLote  	:= TamSX3("B8_NUMLOTE")[1]
Local nTamUnit   	:= TamSX3("D14_IDUNIT")[1]
Local lWmsNew := SuperGetMv("MV_WMSNEW",.F.,.F.)
Local lUniCPO	:= CBC->(ColumnPos("CBC_IDUNIT")) > 0
Local oEstEnder := Nil
Private aCods  := {}

If lModelo1
	CBB->(dbSetOrder(1))
	CBB->(dbSeek(xFilial('CBB')+CBA->CBA_CODINV))
	While ! CBB->(Eof()) .and. xFilial("CBB") == CBB->CBB_FILIAL .and. CBB->CBB_CODINV == CBA->CBA_CODINV
		If CBB->CBB_STATUS == "2"
			Aadd(aCods,CBB->CBB_NUM)
		EndIf
		CBB->(dbSkip())
	EndDo

	For i := 1 To Len(aCods)
		CBC->(dbSetOrder(1))
		CBC->(dbSeek(xFilial('CBC')+aCods[i]))
		While !CBC->(Eof()) .and. xFilial("CBC") == CBC->CBC_FILIAL .and. CBC->CBC_NUM == aCods[i]

			cAux:=Space(10)
			If lUsaCB001 .and.  CBProdUnit(CBC->CBC_COD) //.and. !CBQtdVar(CBC->CBC_COD)
				cAux:= CBC->CBC_CODETI
			EndIf
			If lUsaCB001
				If Ascan(aEtiLidas,CBC->CBC_CODETI) == 0 .And. !Empty(CBC->CBC_CODETI)
					aadd(aEtiLidas,CBC->CBC_CODETI)
				EndIf
			EndIf
			If lUniCPO .and.lWmsNew
				nPos := Ascan(aProds,{|x| x[1] == CBC->(CBC_COD+CBC_LOCAL+CBC_LOCALI+CBC_LOTECT+CBC_NUMLOT+CBC_NUMSER+cAux+CBC_IDUNIT) .and. x[3]==CBC->CBC_NUM })
			Else
				nPos := Ascan(aProds,{|x| x[1] == CBC->(CBC_COD+CBC_LOCAL+CBC_LOCALI+CBC_LOTECT+CBC_NUMLOT+CBC_NUMSER+cAux) .and. x[3]==CBC->CBC_NUM })
			EndIf
			If nPos > 0
				aProds[nPos,2] +=  CBC->CBC_QUANT
			Else
				If lUniCPO .and.lWmsNew
					Aadd(aProds,{CBC->(CBC_COD+CBC_LOCAL+CBC_LOCALI+CBC_LOTECT+CBC_NUMLOT+CBC_NUMSER+cAux+CBC_IDUNIT),; //1
								 CBC->CBC_QUANT,;																		//2
								 CBC->CBC_NUM,;																			//3
								 CBC->CBC_LOCAL,;																		//4
								 CBC->CBC_LOCALI,;																		//5
								 CBC->CBC_IDUNIT})																		//6

				Else
					Aadd(aProds,	{CBC->(CBC_COD+CBC_LOCAL+CBC_LOCALI+CBC_LOTECT+CBC_NUMLOT+CBC_NUMSER+cAux),; //1
									CBC->CBC_QUANT,;	//2
									CBC->CBC_NUM,;		//3
									CBC->CBC_LOCAL,;	//4
									CBC->CBC_LOCALI,;	//5
									CBC->CBC_LOTECT,;	//6
									CBC->CBC_NUMLOT,;	//7
									CBC->CBC_NUMSER,;	//8
									CBC->CBC_COD,;		//9
									CBC->CBC_CODETI})	//10
				EndIf
			Endif
			If cCodCBB == CBC->CBC_NUM
				CBC->(CBLog("04",{CBC_COD,CBC_QUANT,CBC_LOTECT,CBC_NUMLOT,CBC_LOCAL,CBC_LOCALI,CBA->CBA_CODINV,CBC_NUM,CBC_CODETI}))
			EndIf
			CBC->(dbSkip())
		EndDo
	Next i
	For i := 1 to len(aProds)
		For j:= 1 to len(aCods)
			If !lUniCPO .and. !lWmsNew
				CBC->(dbSetOrder(2))
				If !CBC->(DBSeek(xFilial('CBC')+aProds[i,3]+aProds[i,9]+aProds[i,4]+aProds[i,5]+aProds[i,6]+aProds[i,7]+aProds[i,8]))
					If Ascan(aProds,{|x| x[1] == aProds[i,1] .and. x[2] ==0 .and. x[3] == aCods[j]  }) == 0
						Aadd(aProds,{aProds[i,1],0,aCods[j],aProds[i,4],aProds[i,5]})
					EndIF
				Elseif lUsaCB001
					CBC->(dbSetOrder(1))
					If !(CBC->(DbSeek(xFilial('CBC') + aCods[j] + aProds[i,10])))
						Aadd(aProds,{aProds[i,1],0,aCods[j],aProds[i,4],aProds[i,5]})
					EndIf
				EndIf
			Elseif lUsaCB001
				CBC->(dbSetOrder(1))
				If !(CBC->(DbSeek(xFilial('CBC') + aCods[j] + aProds[i,10])))
					Aadd(aProds,{aProds[i,1],0,aCods[j],aProds[i,4],aProds[i,5],aProds[i,6]})
				EndIf
			EndIf
		Next
	Next
	For i := 1 to len(aProds)
		If lUniCPO .and.lWmsNew
			nLen := LEN(CBC->(CBC_COD+CBC_LOCAL+CBC_LOCALI+CBC_LOTECT+CBC_NUMLOT+CBC_NUMSER+cAux+CBC_IDUNIT))
		Else
			nLen := LEN(CBC->(CBC_COD+CBC_LOCAL+CBC_LOCALI+CBC_LOTECT+CBC_NUMLOT+CBC_NUMSER+cAux))
		EndIf

		nPos := Ascan(aProdAux,{|x| Padr(x[1],LEN(aProds[i,1]))==Padr(aProds[i,1], nLen) .and. StrZero(x[2],12,4) == StrZero(aProds[i,2],12,4) })
		If nPos==0
			If lUniCPO .And.lWmsNew
				Aadd(aProdAux,{aProds[i,1],aProds[i,2],1,aProds[i,4],aProds[i,5],aProds[i,6]})
			Else
				Aadd(aProdAux,{aProds[i,1],aProds[i,2],1,aProds[i,4],aProds[i,5]})
			EndIf
		Else
			aProdAux[nPos,3]++
		EndIF
	Next
	For i := 1 to len(aProdAux)
		If aProdAux[i,3] >= CBA->CBA_CONTS
			nPos := Ascan(aProdOK,{|x| x[1] == aProdAux[i,1]})
			If nPos== 0
				If lUniCPO .And.lWmsNew
					aadd(aProdOk,{aProdAux[i,1],aProdAux[i,2],aProdAux[i,4],aProdAux[i,5],aProdAux[i,6]})
				Else
					aadd(aProdOk,{aProdAux[i,1],aProdAux[i,2],aProdAux[i,4],aProdAux[i,5]})
				EndIf

				If Subs(aProdAux[i,1],LEN(CBC->(CBC_COD+CBC_LOCAL+CBC_LOCALI+CBC_LOTECT+CBC_NUMLOT+CBC_NUMSER)),10) <> Space(10)
					If lUniCPO .And.lWmsNew
						aadd(aEtiQtdOK,{Subs(aProdAux[i,1],nTamProd+nTamArm+nTamEnd+nTamLote+nTamSLote+nTamSeri+nTamUnit+1,10),aProdAux[i,2],aProdAux[i,4],aProdAux[i,5],aProdAux[i,6]})
					Else
						aadd(aEtiQtdOK,{Subs(aProdAux[i,1],nTamProd+nTamArm+nTamEnd+nTamLote+nTamSLote+nTamSeri+1,10),aProdAux[i,2],aProdAux[i,4],aProdAux[i,5]})
					EndIf
				EndIf

			EndIf
		Else
			nPos := Ascan(aProdNoOK,{|x| x[1] == aProdAux[i,1]})
			If nPos == 0
				aadd(aProdNoOK,{aProdAux[i,1]})
			EndIf
		EndIf
	Next
	For i := 1 to len(aProdOk)
		nPos := Ascan(aProdNoOK,{|x| x[1] == aProdOK[i,1]})
		If nPos > 0
			aDel(aProdNoOk,nPos)
			aSize(aPRodNoOk,Len(aProdNoOK)-1)
		EndIf
	Next
	aProdOk2:={}
	For i:= 1 to len(aProdOK)
		If lUniCPO .and.lWmsNew
			nPos := Ascan(aProdOK2,{|x| Left(x[1],nTamProd+nTamArm+nTamEnd+nTamLote+nTamSLote+nTamSeri+10+nTamUnit) == Left(aProdOK[i,1],nTamProd+nTamArm+nTamEnd+nTamLote+nTamSLote+nTamSeri+10+nTamUnit)})
		Else
			nPos := Ascan(aProdOK2,{|x| Left(x[1],nTamProd+nTamArm+nTamEnd+nTamLote+nTamSLote+nTamSeri) == Left(aProdOK[i,1],nTamProd+nTamArm+nTamEnd+nTamLote+nTamSLote+nTamSeri)})
		EndIf

		If nPos == 0
			If lUniCPO .and.lWmsNew
				aadd(aProdOk2,{Left(aProdOK[i,1],nTamProd+nTamArm+nTamEnd+nTamLote+nTamSLote+nTamSeri+10+nTamUnit),aProdOK[i,2],aProdOK[i,3],aProdOK[i,4],aProdOK[i,5]})
			Else
				aadd(aProdOk2,{Left(aProdOK[i,1],nTamProd+nTamArm+nTamEnd+nTamLote+nTamSLote+nTamSeri),aProdOK[i,2],aProdOK[i,3],aProdOK[i,4]})
			EndIf
		Else
			aProdOk2[npos,2] +=aProdOk[i,2]
		EndIF
	Next

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o status de analise indicando se esta divergente ou nao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("CBA")
	RecLock("CBA",.F.)
	If Empty(aProdNoOK)
		CBA->CBA_ANALIS := "1"
	Else
		CBA->CBA_ANALIS := "2"
	EndIf
	CBA->(MsUnLock())

Else
	// posicionar na ultima contagem
	CBB->(dbSetOrder(3))
	If ! CBB->(dbSeek(xFilial('CBB')+CBA->CBA_CODINV))
		MsgInTrans(1,STR0046+CBA->CBA_CODINV+STR0075) //"Mestre de Inventario"###" Nao encontrado"
	EndIf
	While ! CBB->(Eof()) .and. xFilial("CBB") == CBB->CBB_FILIAL .and. CBB->CBB_CODINV == CBA->CBA_CODINV
		CBB->(dbSkip())
	EndDo
	CBB->(dbSkip(-1))
	// Aglutinar as quantidade pela chave
	CBC->(dbSetOrder(1))
	CBC->(dbSeek(xFilial('CBC')+CBB->CBB_NUM))
	While CBC->( !Eof() .and. xFilial("CBC")+CBB->CBB_NUM == CBC_FILIAL+CBC_NUM)
		cAux:=Space(10)
		If lUsaCB001 .and.  CBProdUnit(CBC->CBC_COD) //.and. CBQtdVar(CBC->CBC_COD)
			cAux:= CBC->CBC_CODETI
		EndIf
		If lUsaCB001
			If Ascan(aEtiLidas,CBC->CBC_CODETI) == 0 .And. !Empty(CBC->CBC_CODETI)
				aadd(aEtiLidas,CBC->CBC_CODETI)
			EndIf
		EndIf
		If lUniCPO .and.lWmsNew
			nPos := Ascan(aProds,{|x| x[1] == CBC->(CBC_COD+CBC_LOCAL+CBC_LOCALI+CBC_LOTECT+CBC_NUMLOT+CBC_NUMSER+cAux+CBC_IDUNIT) })
		Else
			nPos := Ascan(aProds,{|x| x[1] == CBC->(CBC_COD+CBC_LOCAL+CBC_LOCALI+CBC_LOTECT+CBC_NUMLOT+CBC_NUMSER+cAux) })
		EndIf
		If nPos > 0
			aProds[nPos,2] += CBC->CBC_QUANT
		Else
			If lUniCPO .and.lWmsNew
				Aadd(aProds,{CBC->( CBC_COD+CBC_LOCAL+CBC_LOCALI+CBC_LOTECT+CBC_NUMLOT+CBC_NUMSER+cAux+CBC_IDUNIT),CBC->CBC_QUANT,CBC->CBC_LOCAL,CBC->CBC_LOCALI,CBC->CBC_IDUNIT,CBC->CBC_CODUNI})
			Else
				Aadd(aProds,{CBC->( CBC_COD+CBC_LOCAL+CBC_LOCALI+CBC_LOTECT+CBC_NUMLOT+CBC_NUMSER+cAux),CBC->CBC_QUANT,CBC->CBC_LOCAL,CBC->CBC_LOCALI})
			EndIf
		EndIf
		CBC->(CBLog("04",{CBC_COD,CBC_QUANT,CBC_LOTECT,CBC_NUMLOT,CBC_LOCAL,CBC_LOCALI,CBA->CBA_CODINV,CBC_NUM,CBC_CODETI}))
		CBC->(dbSkip())
	EndDo
	// aglutinar o mesmo produto
	For i:= 1 to len(aProds)
		If lUniCPO .and.lWmsNew
			nPos := Ascan(aProdAux,{|x| Left(x[1],nTamProd+nTamArm+nTamEnd+nTamLote+nTamSLote+nTamSeri+10+nTamUnit) == ;
										Left(aProds[i,1],nTamProd+nTamArm+nTamEnd+nTamLote+nTamSLote+nTamSeri+nTamUnit)})
		Else
			nPos := Ascan(aProdAux,{|x| Left(x[1],nTamProd+nTamArm+nTamEnd+nTamLote+nTamSLote+nTamSeri) == ;
										Left(aProds[i,1],nTamProd+nTamArm+nTamEnd+nTamLote+nTamSLote+nTamSeri)})
		EndIf
		If nPos== 0
			If lUniCPO .and.lWmsNew
				aadd(aProdAux,{Left(aProds[i,1],nTamProd+nTamArm+nTamEnd+nTamLote+nTamSLote+nTamSeri+10+nTamUnit),aProds[i,2],aProds[i,6]})
			Else
				aadd(aProdAux,{Left(aProds[i,1],nTamProd+nTamArm+nTamEnd+nTamLote+nTamSLote+nTamSeri),aProds[i,2]})
			EndIF
		Else
			aProdAux[nPos,2]+=aProds[i,2]
		EndIf
		If lUsaCB001
			aadd(aEtiQtdOK,{Subs(aProds[i,1],nTamProd+nTamArm+nTamEnd+nTamLote+nTamSLote+nTamSeri+1,10),aProds[i,2],aProds[i,3],aProds[i,4]})
		EndIf
	Next

	For i:= 1 to len(aProdAux)
		//CBC_COD
		//               CBC_LOCAL
		//                 CBC_LOCALI
		//                                CBC_LOTECT
		//                                          CBC_NUMLOT
		//                                                CBC_NUMSER
		//12345678901234512123456789012345123456789012345612345678901234567890
		//1234567890123456789012345678901234567890123456789012345678901234567980  regua
		//         1         2         3         4         5         6
		cProduto := Subs(aProdAux[i,1],01,nTamProd)
		cArm     := Subs(aProdAux[i,1],nTamProd+1,nTamArm)
		cEnd     := Subs(aProdAux[i,1],nTamProd+1+nTamArm,nTamEnd)
		cLote    := Subs(aProdAux[i,1],nTamProd+1+nTamArm+nTamEnd,nTamLote)
		cSLote   := Subs(aProdAux[i,1],nTamProd+1+nTamArm+nTamEnd+nTamLote,nTamSLote)
		cNumSeri := Subs(aProdAux[i,1],nTamProd+1+nTamArm+nTamEnd+nTamLote+nTamSLote,nTamSeri)
		cIdunit  := Subs(aProdAux[i,1],nTamProd+1+nTamArm+nTamEnd+nTamLote+nTamSLote+nTamSeri+10,nTamUnit)


		If Localiza(cProduto,.T.)
			nSaldo := SaldoSBF(cArm,cEnd,cProduto,cNumSeri,cLote,cSlote)
			If lWmsNew .And. AcdCopVal("CTR", , , ,cProduto)//Valido se o produto tem controle WMS
				// Busca o saldo do produto no endereço, independente se é montado ou desmontado
				oEstEnder := WMSDTCEstoqueEndereco():New()
				nSaldo := oEstEnder:FindSldEnd(cArm,cEnd,,,cProduto,cLote,cSlote,cNumSeri,.F./*lEntrPrev*/,.F./*lSaidaPrev*/,.F./*lEmpenho*/,.F./*lBloqueio*/,cIdUnit)
			EndIf
		ElseIf Rastro(cProduto)
			nSaldo := SaldoLote(cProduto,cArm,cLote,cSLote,.F.)
		Else
			SB2->(DbSetOrder(1))
			SB2->(MsSeek(xFilial('SB2')+cProduto+cArm))
			nSaldo := SaldoSB2(,.F.)
		EndIf
		If Str(aProdAux[i,2],12,4) == Str(nSaldo,12,4)
			nPos := Ascan(aProdOK,{|x| x[1] == aProdAux[i,1]})
			If nPos== 0
				aadd(aProdOk,{aProdAux[i,1],aProdAux[i,2]})
			EndIf
			If lUniCPO .and.lWmsNew
				nPos := ascan(aProdEnd,{|x| x[1]+x[2]+x[3]+x[4]+x[5]+x[6]+x[9]==cProduto+cLote+cSLote+cArm+cEnd+cNumSeri+cIdunit })
			Else
				nPos := ascan(aProdEnd,{|x| x[1]+x[2]+x[3]+x[4]+x[5]+x[6]==cProduto+cLote+cSLote+cArm+cEnd+cNumSeri })
			EndIf

			If npos > 0
				aDel(aProdEnd,nPos)
				aSize(aProdEnd,len(aProdEnd)-1)
			EndIf
		Else
			nPos := Ascan(aProdNoOK,{|x| x[1] == aProdAux[i,1]})
			If nPos == 0
				aadd(aProdNoOK,{aProdAux[i,1],aProdAux[i,2],IIF(Len(aProdAux[i])>2,aProdAux[i,3],NIL)})
			EndIf
		EndIf
	Next

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o status de analise indicando se esta divergente ou nao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("CBA")
	RecLock("CBA",.F.)
	If Empty(aProdNoOK)
		CBA->CBA_ANALIS := "1"
	Else
		CBA->CBA_ANALIS := "2"
	EndIf
	CBA->(MsUnLock())

	If lMonitor .and. ! Empty(aProdNoOK)
		aProdOk2 := aClone(aProdNoOk)
		aProdNoOk := {}
	Else
		If Empty(aProdNoOK) .and. ! Empty(aProdEnd)
			aProdNoOK := {STR0076} //"atribuicao simbolica somente para nao validar a contagem"
		Elseif Empty(aProdNoOK) .and. Empty(aProdEnd)
			lOK:= .t.
		EndIf
	EndIf
EndIf
Return {(len(aProdNoOK) == 0),aProdOk2,aEtiQtdOK,aEtiLidas,lOK}

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ AcertoInv  ³ Autor ³ Desenv. ACD         ³ Data ³ 30/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Acerto de inventario				                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ACDV035                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function AcertoInv(aProdOk,aEtiQtdOk,aEtiLidas,lMonitorInv,lAutomatico)
Local aVetor
Local nX
Local cProduto
Local cLote
Local cSLote
Local cNumSeri
Local nPos
Local cArm,cEnd
Local aEtiqueta     := {}
Local lDigitaQtde   := (GetMv("MV_VQTDINV") == "1")
Local lWmsNew		:= SuperGetMv("MV_WMSNEW",.F.,.F.)
Local lUniCPO		:= CBC->(ColumnPos("CBC_IDUNIT")) > 0
Local cUniCPO
Local dDataInv      := dDataBase
Local dDtValid      := ctod("")
Local aAreaSB7      := SB7->(GetArea())
Local nTamCod       := TamSX3('B1_COD')[1]
Local nTamLoc       := TamSX3('B1_LOCPAD')[1]
Local nTamSeri      := TamSX3('BF_NUMSERI')[1]
Local nTamEnd       := TamSX3("BF_LOCALIZ")[1]
Local nTamLote      := TamSX3("B8_LOTECTL")[1]
Local nTamSLote     := TamSX3("B8_NUMLOTE")[1]
Local nTamUnit      := TamSX3("D14_IDUNIT")[1]


Private lMsHelpAuto := .T.
Private nModulo     := 4

DEFAULT lMonitorInv := .F.
DEFAULT lAutomatico := .F.

RecLock("CBA",.f.)
CBA->CBA_STATUS := "4"  // 4-finalizado
CBA->(MsUnlock())
If Empty(aProdOK) .and. Empty(aProdEnd)
	// desbloquer o inventario
	CBLoadEst(aProdEnd,.F.)
	For nX := 1 to len(aProdEnd)
		cProduto := Subs(aProdEnd[nX,1],01,nTamCod)
		CBUnBlqInv(CBA->CBA_CODINV,cProduto)
	Next
	RecLock("CBA",.f.)
	CBA->CBA_STATUS := "5"  // 5-Processado sem registro no SB7
	CBA->(MsUnlock())
	Return .t.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso a geracao do SB7 seja feita pelo windows  data a            ³
//³ ser considerada a data do mestre de inventario                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !IsTelnet()
	// Pega a data do mestre de inventario quando executador fora do coletor
	dDataInv := CBA->CBA_DATA
EndIf

For nX := 1 to len(aProdOK)
	cProduto := Subs(aProdOk[nX,1],01                   ,nTamCod)
	cArm     := Subs(aProdOk[nX,1],nTamCod+01           ,nTamLoc)
	cEnd     := Subs(aProdOk[nX,1],nTamCod+nTamLoc+01   								,nTamEnd)
	cLote    := Subs(aProdOk[nX,1],nTamCod+nTamLoc+nTamEnd+01   					,nTamLote)
	cSLote   := Subs(aProdOk[nX,1],nTamCod+nTamLoc+nTamEnd+nTamLote+01   			,nTamSLote)
	cNumSeri := Subs(aProdOk[nX,1],nTamCod+nTamLoc+nTamEnd+nTamLote+nTamSLote+01 ,nTamSeri)
	cCodUnit := Subs(aProdOk[nX,1],nTamCod+nTamLoc+nTamEnd+nTamLote+nTamSLote+nTamSeri+10+01 ,nTamUnit)
	If lUniCPO .And. lWmsNew  .And. lModelo1
		cCodUnit := aProdOk[nX,5]
	EndIf

	If Empty(cNumSeri)
		cNumSeri:=Space(nTamSeri)
	EndIf
	If lUniCPO .And. lWmsNew
		nPos := ascan(aProdEnd,{|x| x[1]+x[2]+x[3]+x[4]+x[5]+x[6]+x[9]==cProduto+cLote+cSLote+cArm+cEnd+cNumSeri+cCodUnit})
	Else
		nPos := ascan(aProdEnd,{|x| x[1]+x[2]+x[3]+x[4]+x[5]+x[6]==cProduto+cLote+cSLote+cArm+cEnd+cNumSeri})
	EndIf
	If npos > 0
		dDtValid := aProdEnd[npos,8]
	EndIf

	If IsTelNet()
		VTMSG(STR0077) //"Incluindo Inventario"
	EndIf

	If !AcdvGSB7(cProduto,cArm,cEnd,CBA->CBA_CODINV,dDataInv,aProdOk[nX,2],cLote,cSLote,cNumSeri,dDtValid,Iif((lUniCPO .And. lWmsNew .And.  WmsArmUnit(cArm)),cCodUnit,Nil),Iif((lUniCPO .And. lWmsNew .And. WmsArmUnit(cArm)),aProdOk[nX,5],Nil))
		If lAutomatico
			Aadd(aLogMestre,{CBA->CBA_CODINV,2,STR0078,.F.})//"Erro na rotina automatica:"
			Aadd(aLogMestre,{CBA->CBA_CODINV,2,"==== == ====== ==========",.F.})
			Aadd(aLogMestre,{CBA->CBA_CODINV,3,STR0079+cProduto,.F.}) //"Produto: "
			Aadd(aLogMestre,{CBA->CBA_CODINV,3,STR0080+cArm,.F.}) //"Armazem: "
			Aadd(aLogMestre,{CBA->CBA_CODINV,3,STR0081+cEnd,.F.}) //"Endereco:"
			Aadd(aLogMestre,{CBA->CBA_CODINV,3,STR0082+cLote,.F.}) //"Lote:    "
			Aadd(aLogMestre,{CBA->CBA_CODINV,3,STR0083+cSLote,.F.}) //"Sub-Lote:"
			Aadd(aLogMestre,{CBA->CBA_CODINV,3,STR0084+cNumSeri,.F.}) //"N.Serie: "
		Else
			MsgInTrans(2)
			MsgInTrans(1,STR0085,STR0017,.T.,5000,2) //'Erro na rotina automatica, necessario excluir esta finalizacao pelo Mestre de Inventario'###'Atencao'
		EndIf
		Return .F.
	Endif

	If npos > 0
		aDel(aProdEnd,nPos)
		aSize(aProdEnd,len(aProdEnd)-1)
	EndIf
Next

If IsGeraAcerto(lMonitorInv)
	If IsTelNet()
		VTMSG(STR0086)  //"Acerto Estoque..."
	EndIf

	SB7->(DbOrderNickName("ACDSB701"))
	If SB7->(DbSeek(xFilial("SB7")+CBA->CBA_CODINV))
		MATA340(.T.,CBA->CBA_CODINV,.F.)
	EndIf

	RestArea(aAreaSB7)
EndIf

If !IsTelnet()
	IncProc()
EndIf
Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VldMEti    ³ Autor ³ Desenv. ACD         ³ Data ³ 30/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao da Etiqueta			                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ACDV035                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function VldMEti(nOpc,cLocal,cEtiqueta)

Local aEtiqueta := {}
Local cEtiqAux
Local cCodigo := QbrString(1,cEtiqueta)// CUSTOMIZADO cEtiqueta
Local aMestre:={}
Local aTela,npos
Local lRet	:= .t.
Local nTamProd := TamSX3("B1_COD")[1]
Local nTamEnd  := TamSx3("BF_LOCALIZ")[1]

cEtiqueta := cCodigo // Customizado

If Empty(cEtiqueta)
	Return .f.
EndIf
If nOpc==1
	If ExistBlock('CBINV01')
		cEtiqAux := ExecBlock("CBINV01",,,{cLocal,nil,cEtiqueta})
		If ValType(cEtiqAux)=="C"
			cCodigo := cEtiqAux
		EndIf
	EndIf
	If lUsaCB001
		aEtiqueta:= CbRetEti(cCodigo,"01",.T.,.T.)
		If Empty(aEtiqueta)
			VTBeep(3)
			VTAlert(STR0088,STR0002,.t.,3000) //"Etiqueta Invalida"###"Aviso"
			VTKeyBoard(chr(20))
			Return .f.
		EndIf
		cLocal := CB0->CB0_LOCAL
		cCodigo:= CB0->CB0_CODPRO
	Else
		If !CBLoad128(@cEtiqueta)
			VTAlert(STR0027,STR0002,.t.,4000,3) //'Leitura invalida'###'Aviso'
			VTKeyBoard(chr(20))
			Return .f.
		Endif
		If !(CBRetTipo(cEtiqueta)$"EAN8OU13-EAN14-EAN128")
			VTALERT(STR0028,STR0002,.T.,4000,3)   //"Etiqueta invalida."###"Aviso"
			VTKeyboard(chr(20))
			Return .f.
		EndIf
		aEtiqueta := CBRetEtiEan(cEtiqueta)
		If Len(aEtiqueta) == 0
			VTAlert(STR0029,STR0002,.t.,4000,3) //'Etiqueta invalida!!'###'Aviso'
			VTKeyBoard(chr(20))
			Return .f.
		EndIf
		cCodigo := aEtiqueta[01]
	EndIf
	CBA->(DbSetOrder(3)) // local+produto
Else
	If lUsaCB002
		aEtiqueta:= CbRetEti(cCodigo,"02")
		If Empty(aEtiqueta)
			VTBeep(3)
			VTAlert(STR0088,STR0002,.t.,3000) //"Etiqueta Invalida"###"Aviso"
			VTKeyBoard(chr(20))
			Return .f.
		EndIf
		cLocal := CB0->CB0_LOCAL
		cCodigo:= CB0->CB0_LOCALI
	EndIf
	CBA->(DbSetOrder(2)) // local+endereco
	If ExistBlock('CBINV02')
		lRet := ExecBlock("CBINV02",,,{cLocal,cCodigo})
		If ValType(lRet)#"L"
			lRet := .t.
		EndIf
		If !lRet
			VTKeyBoard(chr(20))
			Return .f.
		EndIf
	EndIf
EndIf
aMestre:={}
CBA->(DbSeek(xFilial("CBA")+Str(nOpc,1)+"0"+cLocal+Padr(cCodigo,If (nOpc == 1, nTamProd, nTamEnd))))
While CBA->(! EOF() .AND. xFilial("CBA")+Str(nOpc,1)+"0"+cLocal==CBA_FILIAL+CBA_TIPINV+CBA_STATUS+CBA_LOCAL)
	If Padr(cCodigo,If(nOpc ==1,nTamProd,nTamEnd)) == If(nOpc ==1,CBA->CBA_PROD,CBA->CBA_LOCALI) .AND. CBA->CBA_DATA <= dDataBase
		aadd(aMestre,{CBA->CBA_CODINV,DTOC(CBA->CBA_DATA),Padr(STR0089,19),CBA->(RecNo())}) //"Nao Iniciado"
	EndIf
	CBA->(DbSkip())
	If CBA->(EOF()) .or. Padr(cCodigo,If(nOpc ==1,nTamProd,nTamEnd)) <> If(nOpc ==1,CBA->CBA_PROD,CBA->CBA_LOCALI)
		Exit
	EndIf
End

If ! CBA->(DbSeek(xFilial("CBA")+Str(nOpc,1)+"1"+cLocal+Padr(cCodigo,If(nOpc ==1,nTamProd,nTamEnd))))
	If ! CBA->(DbSeek(xFilial("CBA")+Str(nOpc,1)+"2"+cLocal+Padr(cCodigo,If(nOpc ==1,nTamProd,nTamEnd))))
		CBA->(DbSeek(xFilial("CBA")+Str(nOpc,1)+"3"+cLocal+Padr(cCodigo,If(nOpc ==1,nTamProd,nTamEnd))))
	EndIf
EndIf
While CBA->(! EOF() .AND. xFilial("CBA")+Str(nOpc,1)+cLocal==CBA_FILIAL+CBA_TIPINV+CBA_LOCAL)
	If CBA->CBA_STATUS > "3"
		Exit
	EndIf
	If Padr(cCodigo,If(nOpc ==1,nTamProd,nTamEnd)) == If(nOpc ==1,CBA->CBA_PROD,CBA->CBA_LOCALI) .AND. CBA->CBA_DATA <= dDataBase
		aadd(aMestre,{CBA->CBA_CODINV,DTOC(CBA->CBA_DATA),Padr(STR0090,19),CBA->(RecNo())}) //"Em Andamento"
	EndIf
	CBA->(DbSkip())
	If CBA->(EOF()) .or. Padr(cCodigo,If(nOpc ==1,nTamProd,nTamEnd)) <> If(nOpc ==1,CBA->CBA_PROD,CBA->CBA_LOCALI)
		exit
	EndIf
End
If Empty(aMestre)
	VTBeep(3)
	VTAlert(STR0091,STR0002,.t.,3000) //"Mestre de Inventario nao encontrado"###"Aviso"
	VTKeyBoard(chr(20))
	If (nOpc==1 .and. ! lUsaCB001) .or. (nOpc==2 .and. ! lUsaCB002)
		VTClearGet("cEtiqueta")
		VTClearGet("cLocal")
		VTGetSetFocus("cLocal")
	EndIf
	Return .f.
EndIf
If Len(aMestre) > 1
	aMestre := aSort(aMestre,,,{|x,y| x[2]<y[2]})
	aTela := VtSave()
	VTClear()
	nPos :=VTaBrowse(0,0,7,19,{STR0040,STR0092,STR0093},aMestre,{06,08,19}) //"Mestre"###"Data"###"Status"
	VtRestore(,,,,aTela)
	If nPos == 0
		VTBeep(3)
		VTAlert(STR0094,STR0002,.t.,3000) //"Mestre de Inventario nao selecionado"###"Aviso"
		VTKeyBoard(chr(20))
		If (nOpc==1 .and. ! lUsaCB001) .or. (nOpc==2 .and. ! lUsaCB002)
			VTClearGet("cEtiqueta")
			VTClearGet("cLocal")
			VTGetSetFocus("cLocal")
		EndIf
		Return .f.
	EndIf
	CBA->(MsGoto(aMestre[nPos,4]))
Else
	CBA->(MsGoto(aMestre[1,4]))
EndIf

cEtiqueta := cCodigo

Return VldCodInv(CBA->CBA_CODINV,.f.)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Informa    ³ Autor ³ Desenv. ACD         ³ Data ³ 30/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Mostra produtos que ja foram lidos                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ACDV060                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Informa()
Local aCab,aSize,aSave := VTSAVE()
Local nX
Local aTemp:={}
Local aCBC:= CBC->(GetArea())
Local lWmsNew		   := SuperGetMv("MV_WMSNEW",.F.,.F.)
Local lUniCPO		   := CBC->(ColumnPos("CBC_IDUNIT")) > 0

CBC->(DbSetOrder(2))
VTClear()
aCab  := {STR0009,STR0047,STR0041,STR0095,STR0096,STR0097} //"Produto"###"Armazem"###"Endereco"###"Lote"###"SubLote"###"Serie"
aSize := {15,7,15,10,7,20}
For nX:= 1 to len(aProdEnd)
	If CBC->(DbSeek(xFilial('CBC')+CBB->CBB_NUM+aProdEnd[nx,1]+aProdEnd[nx,4]+aProdEnd[nx,5]+aProdEnd[nx,2]+aProdEnd[nx,3]+aProdEnd[nx,6])) .and. CBC->CBC_CONTOK=="1"
		Loop
	EndIf
	aadd(aTemp,{aProdEnd[nx,1],aProdEnd[nx,4],aProdEnd[nx,5],aProdEnd[nx,2],aProdEnd[nx,3],aProdEnd[nx,6]})
Next
VTaBrowse(0,0,7,19,aCab,aTemp,aSize)
VtRestore(,,,,aSave)
RestArea(aCBC)
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ AcdvGSB7   ³ Autor ³ TOTVS		        ³ Data ³ 01/01/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava Registros SB7				                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ACDV060                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function AcdvGSB7(cProduto,cArm,cEnd,cDoc,dData,nQuant,cLote,cSLote,cNumSeri,dDtValid,cCodUnit,cCodTipo)
Local aVetor		:= {}
Local aAreaSB1		:= {}
Local lCBINV05		:= ExistBlock('CBINV05')
Local lWmsNew		:= SuperGetMv("MV_WMSNEW",.F.,.F.)
Local lUniCPO		:= CBC->(ColumnPos("CBC_IDUNIT")) > 0
Local cCont			:= "001"
Default cNumSeri	:= ''
Default cCodUnit	:= " "
Default cCodTipo	:= " "
Private lMsErroAuto	:= .F.
Private lMsHelpAuto	:= .T.

aVetor:= {	{"B7_COD",		cProduto,	Nil},;
			{"B7_LOCAL",	cArm,		Nil},;
			{"B7_LOCALIZ",	cEnd,		Nil},;
			{"B7_DOC",		cDoc,		Nil},;
			{"B7_DATA",		dData,		Nil},;
			{"B7_QUANT",	nQuant,		Nil},;
			{"B7_LOTECTL",	cLote,		Nil},;
			{"B7_NUMLOTE",	cSLote,		Nil},;
			{"B7_CONTAGE",	cCont,		Nil}} //Forçar gravação do campo B7_CONTAGE para não apresentar help MT270CNTOBR
											  //Pois quando o inventário é feito via ACD o campo não é gravado
If ! Empty(cNumSeri)
	aAreaSB1:= SB1->(GetArea())
	SB1->(DbSetOrder(1))
	SB1->(MsSeek(xFilial("SB1")+cProduto))
	If SB1->B1_QTDSER <> 1
		aadd(aVetor,{"B7_QTSEGUM",1 , nil})
	EndIf
	aadd(aVetor,{"B7_NUMSERI", cNumSeri, Nil})
	RestArea(aAreaSB1)
EndIf
If !Empty(dDtValid)
	aadd(aVetor,{"B7_DTVALID", dDtValid, Nil})
EndIf
if lUniCPO .And.lWmsNew
	aadd(aVetor,{"B7_IDUNIT", cCodUnit, Nil})
	aadd(aVetor,{"B7_CODUNI", cCodTipo, Nil})
EndIf

MsExecAuto({|x| Mata270(x)},aVetor)
If !lMsErroAuto .AND. lCBINV05
	ExecBlock("CBINV05",,,{cProduto,cArm,cEnd,cDoc,dData,cLote,cSLote,cNumSeri,cCodUnit,cCodTipo})
Endif
Return ! lMsErroAuto

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³IsGeraAcerto³ Autor ³ TOTVS		        ³ Data ³ 01/01/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verificar se ira efetuar o acerto automatico               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³OBS		 ³ cInvAut:= MV_INVAUT 										  ³±±
±±³          ³ MV_INVAUT == '0' NAO FAZ ACERTO AUTOMATICO				  ³±±
±±³          ³ MV_INVAUT == '1' FAZ ACERTO AUTOMATICO SOMENTE PELO RADIO  ³±±
±±³          ³ MV_INVAUT == '2' FAZ ACERTO AUTOMATICO SOMENTE PELO MONITOR³±±
±±³          ³ MV_INVAUT == '3' FAZ ACERTO AUTOMATICO PELO RADIO E MONITOR³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ACDV0035                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function IsGeraAcerto(lMonitorInv)
Local lRet    := .F.
Local cInvAut := SuperGetMv("MV_INVAUT")
If cInvAut== '3'
	lRet := .T.
EndIf
If cInvAut=='1' .and. ! lMonitorInv
	lRet := .T.
EndIf
If cInvAut=='2' .and. lMonitorInv
	lRet := .T.
EndIf
Return lRet

// -----------------------------------------------
/*/{Protheus.doc} CBUnBlqInv
@param: Nil
@author:TOTVS
/*/
// -------------------------------------------------
Static Function CBUnBlqInv(cCodInv,cProduto)
Local aSB2 := SB2->(GetArea())
Local aSBE := SBE->(GetArea())
Local lWmsNew   := SuperGetMv("MV_WMSNEW",.F.,.F.)
Local oEstEnder := Nil
Local oProdComp := Nil
Local cPrdOri   := cProduto

SB2->(DbSetOrder(1))
SBE->(dbSetOrder(1))

//Desbloquer o produto ou endereco caso o inventario esteja com bloqueio de tempo de execucao
If !SuperGetMv('MV_VLDTINV') =='1' // TIPO DO BLOQUEIO
	CBA->(dbSetOrder(1))
	CBA->(dbSeek(xFilial('CBA')+cCodInv))
	If CBA->CBA_TIPINV =='2'
		SBE->(dbSetOrder(1))
		If SBE->(MsSeek(xFilial('SBE')+CBA->CBA_LOCAL+CBA->CBA_LOCALI))
			RecLock("SBE",.F.)
			SBE->BE_DTINV  := ctod('')
			SBE->(MsUnlock())
		EndIf
	Endif
	If SB2->(MsSeek(xFilial("SB2")+cProduto+CBA->CBA_LOCAL))
		If lWmsNew .And. IntDl(cProduto)
			oProdComp := WMSDTCProdutoComponente():New()
			oProdComp:SetPrdCmp(cProduto)
			If oProdComp:LoadData(2)
				cPrdOri := oProdComp:GetPrdOri()
			EndIf
			If SB2->(dbSeek(xFilial("SB2")+cProduto+CBA->CBA_LOCAL))
				RecLock("SB2",.F.)
				SB2->B2_DTINV := ctod('')
				SB2->(MsUnlock())
			EndIf
		Else
			RecLock("SB2",.F.)
			SB2->B2_DTINV := ctod('')
			SB2->(MsUnlock())
		EndIf
	EndIf
	RestArea(aSB2)
	RestArea(aSBE)
EndIf

If lWmsNew .and. CBA->CBA_TIPINV =='2'
	If CBA->CBA_TIPINV =='2'
		oEstEnder := WMSDTCEstoqueEndereco():New()
		oEstEnder:oEndereco:SetArmazem(CBA->CBA_LOCAL)
		oEstEnder:oEndereco:SetEnder(CBA->CBA_LOCALI)
		oEstEnder:UpdEnder()
	EndIf
EndIf

Return

// -----------------------------------------------
/*/{Protheus.doc} IniciaCBM
@param: Nil
@author:TOTVS
/*/
// -------------------------------------------------
Static Function IniciaCBM(aProdEnd)
Local nX
Local cProduto,cArm,cEnd,cLote,cSLote,cNumSeri,nQtdOri
Local cCodUnit:= CriaVar('D14_IDUNIT', .F.)
Local lChkClasse := ( "1" $ CBA->( CBA_CLASSA + CBA_CLASSB + CBA_CLASSC ) )
Local lWmsNew		   := SuperGetMv("MV_WMSNEW",.F.,.F.)
Local lUniCPO		   := CBM->(ColumnPos("CBM_IDUNIT")) > 0

DbSelectArea("SB3")
SB3->(DbSetOrder(1))
For nX := 1 to len(aProdEnd)
	cProduto := aProdEnd[nX,1]
	cArm     := aProdEnd[nX,4]
	cEnd     := aProdEnd[nX,5]
	cLote    := aProdEnd[nX,2]
	cSLote   := aProdEnd[nX,3]
	cNumSeri := aProdEnd[nX,6]
	nQtdOri  := aProdEnd[nX,7]
	If lUniCPO .And. lWmsNew .And. Len(aProdEnd[nX]) >= 9
		cCodUnit:= aProdEnd[nX,9]
	EndIf


	RecLock("CBM",.T.)
	CBM->CBM_FILIAL := xFilial("CBM")
	CBM->CBM_CODINV := CBA->CBA_CODINV
	CBM->CBM_LOCAL  := cArm
	CBM->CBM_LOCALI := cEnd
	CBM->CBM_COD    := cProduto
	CBM->CBM_LOTECT := cLote
	CBM->CBM_NUMLOT := cSLote
	CBM->CBM_NUMSER := cNumSeri
	CBM->CBM_QTDORI := nQtdOri
	If lUniCPO .And. lWmsNew
		CBM->CBM_IDUNIT:= cCodUnit
		CBM->CBM_CODUNI := cCodTpUni
	EndIf

	If lChkClasse .And. SB3->( MsSeek(xFilial("SB3")+cProduto) )
		CBM->CBM_CLASSE := SB3->B3_CLASSE
	EndIf
	CBM->(MsUnLock())
Next
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ ACD35CBM   ³ Autor ³ Desenv. ACD         ³ Data ³ 01/01/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gravar registro na tabela de hitorico                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ACDV060                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
// nOpc: 3-Inclui; 5-Exclui
Static Function ACD35CBM(nOpc,cCodInv,cProduto,cArm,cEnd,cLote,cSLote,cNumSer,cCodUnit,cCodTpUni)
Local lRetPE := .t.
Local lReclock := .F.
Local lWmsNew   := SuperGetMv("MV_WMSNEW",.F.,.F.)
Local lUniCPO	  := CBM->(ColumnPos("CBM_IDUNIT")) > 0
Default cCodUnit := CriaVar('D14_IDUNIT', .F.)
Default nOpc := 3

If ExistBlock('CBINV06')
	lRetPE := ExecBlock("CBINV06",.F.,.F.,{cProduto,cArm,cEnd,cNumSer,cLote,cSLote})
	If ValType(lRetPE)#"L"
		lRetPE := .t.
	EndIf
	If !lRetPE
		Return
	EndIf
EndIf

DbSelectArea("SB3")
SB3->(DbSetOrder(1))
CBM->(DbSetOrder(1))
If nOpc==3
	If ExistCpo("SB1",cProduto,1,,.F.)
		If lUniCPO .and.lWmsNew
			If ! CBM->(DbSeek(xFilial('CBM')+cCodInv+cProduto+cArm+cEnd+cLote+cSLote+cNumSer+cCodUnit))
				lReclock := .T.
			EndIf
		Else
			If ! CBM->(DbSeek(xFilial('CBM')+cCodInv+cProduto+cArm+cEnd+cLote+cSLote+cNumSer))
				lReclock := .T.
			EndIf
		EndIf
		If lReclock
			RecLock('CBM',.t.)
			CBM->CBM_FILIAL := xFilial("CBM")
			CBM->CBM_CODINV := CBA->CBA_CODINV
			CBM->CBM_LOCAL  := cArm
			CBM->CBM_LOCALI := cEnd
			CBM->CBM_COD    := cProduto
			CBM->CBM_LOTECT := cLote
			CBM->CBM_NUMLOT := cSLote
			CBM->CBM_NUMSER := cNumSer
			If lWmsNew .And. lUniCPO
				CBM->CBM_IDUNIT := cCodUnit
				CBM->CBM_CODUNI := cCodTpUni
		    EndIf
			If SB3->(DbSeek(xFilial("SB3")+cProduto))
				CBM->CBM_CLASSE := SB3->B3_CLASSE
			EndIf
			CBM->(MsUnLock())
		EndIf
	EndIf
ElseIf nOpc==5
	If lUniCPO .and.lWmsNew
		If !CBM->(DbSeek(xFilial('CBM')+cCodInv+cProduto+cArm+cEnd+cLote+cSLote+cNumSer+cCodUnit))
			Return
		EndIf
	Else
		If !CBM->(DbSeek(xFilial('CBM')+cCodInv+cProduto+cArm+cEnd+cLote+cSLote+cNumSer))
			Return
		EndIf
	EndIf
	RecLock('CBM',.F.)
	CBM->(DbDelete())
	CBM->(MsUnLock())
EndIf
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  CBATUCB0  ³ Autor ³ TOTVS		        ³ Data ³ 01/01/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tem o objetivo de invalidar etiquetas nao lidas e atualizar³±±
±±³		     ³ valores(quantidade) no CB0.								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³OBS		 ³ Esta rotina utiliza duas variaveis staticas: 			  ³±±
±±³          ³ __cMestre  : Codigo do mestre de inventario.				  ³±±
±±³          ³ __aRetCount: Declarado neste programa e chamado 			  ³±±
±±³          ³ 				pela funcao CBANAINV(..), e por 			  ³±±
±±³          ³				esta funcao.								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ACDV0035                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CBAtuCB0(lBloq) //Depois ver se o nome da funcao vai ser este mesmo
Local nPos
Local nX 		  := 0
Local lDigitaQtde := (GetMv("MV_VQTDINV") == "1")
Local aEtiQtdOk   := {}
Local aEtiLidas   := {}
Local lUsaCb0	  := UsaCB0("01")

Private aProdEnd  := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se as etiquetas para o mestre e produto ja foram atu³
//³ alizadas.                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If __cMestre==CBA->CBA_CODINV
	Return
EndIf

CBLoadEst(aProdEnd,lBloq)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa a analise de inventario para carregar arrays obriga- ³
//³ torios somente se o cod. do mestre atual for diferente do    ³
//³ mestre de inventario anterior.                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(__cMestre) .or. __cMestre <> CBA->CBA_CODINV
	__cMestre := CBA->CBA_CODINV
	__aRetCount := AnalisaInv(.T.)
EndIf

aEtiQtdOk := aClone(__aRetCount[3])
aEtiLidas := aClone(__aRetCount[4])

//Ajusta localizacao
If SuperGetMv("MV_ALTENDI") == "1" .And. lUsaCb0
	CB0->(DbSetorder(1))
	For nX:=1 To Len(aEtiLidas)
		If CB0->(DbSeek(xFilial("CB0")+aEtiLidas[nX])) .And. CBA->(CBA_LOCAL+CBA_LOCALI) <> CB0->(CB0_LOCAL+CB0_LOCALI)
			RecLock("CB0",.F.)
			CB0->CB0_LOCAL  := aEtiQtdOk[nX,3]
			CB0->CB0_LOCALI := aEtiQtdOk[nX,4]
			MsUnLock()
		EndIf
	Next
EndIf

// acerto das etiquetas quando utilizar CB0
If CBA->CBA_TIPINV== "1"  // 1-PRODUTO
	If ! Empty(CBA->CBA_PROD)    // TEM PRODUTO
		CB0->(DbSetorder(4)) // filial +produto+local
		CB0->(DBSeek(xFilial('CB0')+"01"+CBA->CBA_LOCAL+CBA->CBA_PROD))
		While CB0->(! EOF() .AND. CB0_FILIAL+CB0_TIPO+CB0_LOCAL+CB0_CODPRO==xFilial('CB0')+"01"+CBA->CBA_LOCAL+CBA->CBA_PROD)
			nPos := ascan(aEtiLidas,CB0->CB0_CODETI)
			RecLock("CB0")
			If Empty(nPos) .Or. If(!lDigitaQtde .And. (nPos := Ascan(aEtiLidas,CB0->CB0_CODETI))> 0,aEtiQtdOk[nPos,2]== 0,.F.)
				If CB0->CB0_STATUS <> "1"
					If Empty(CB0->CB0_PEDCOM)
						CB0->CB0_STATUS:= "2"
					Else
						If !Empty(CB0->CB0_NFENT)
							CB0->CB0_STATUS:= "2"
						EndIf
					EndIf
				EndIf
			Else
				CB0->CB0_STATUS:= " "
				nPos := Ascan(aEtiLidas,CB0->CB0_CODETI)
				If ! Empty(nPos) .and. ( lDigitaQtde .Or. CBQtdVar(CB0->CB0_CODPRO))
					CB0->CB0_QTDE := aEtiQtdOk[nPos,2]
				EndIf
			EndIf
			CB0->(MsUnLock())
			CB0->(DbSkip())
		End
		CB0->(DbSetOrder(1))
	Else  // TODOS OS PRODUTOS
		CB0->(DbSetOrder(3))
		CB0->(DBSeek(xFilial('CB0')+"01"+CBA->CBA_LOCAL))
		While CB0->(! EOF() .AND. CB0_FILIAL+CB0_TIPO ==xFilial('CB0')+"01")
			nPos:= ascan(aEtiLidas,CB0->CB0_CODETI)
			RecLock("CB0")
			If Empty(nPos) .and. lDigitaQtde .Or. If(lDigitaQtde .And. (nPos := Ascan(aEtiLidas,{|x| x[1] == CB0->CB0_CODETI}))> 0,aEtiQtdOk[nPos,2]== 0,.f.)
				If CB0->CB0_STATUS <> "1"
					If Empty(CB0->CB0_PEDCOM)
						CB0->CB0_STATUS:= "2"
					Else
						If ! Empty(CB0->CB0_NFENT)
							CB0->CB0_STATUS:= "2"
						EndIf
					EndIf
				EndIf
			Else
				CB0->CB0_STATUS:= " "
				nPos := Ascan(aEtiLidas,{|x| x == CB0->CB0_CODETI})
				If ! Empty(nPos) .and. ( lDigitaQtde .Or. CBQtdVar(CB0->CB0_CODPRO))
					CB0->CB0_QTDE := aEtiQtdOk[nPos,2]
				EndIf
			EndIf
			CB0->(MsUnLock())
			CB0->(DbSkip())
		End
		CB0->(DbSetOrder(1))
	EndIf
ElseIf CBA->CBA_TIPINV== "2"  // 2-Endereco
	CB0->(DbSetOrder(3))
	CB0->(DBSeek(xFilial('CB0')+"01"+CBA->CBA_LOCAL+CBA->CBA_LOCALI))
	While CB0->(! EOF() .AND. CB0_FILIAL+CB0_TIPO+CB0_LOCAL+CB0_LOCALI ==xFilial('CB0')+"01"+CBA->CBA_LOCAL+CBA->CBA_LOCALI)
		nPos:= Ascan(aEtiLidas,CB0->CB0_CODETI)
		RecLock("CB0")
		If Empty(nPos).Or. If(lDigitaQtde .And. (nPos := Ascan(aEtiLidas,CB0->CB0_CODETI))> 0,aEtiQtdOk[nPos,2]== 0,.F.)
			If CB0->CB0_STATUS <> "1"
				If Empty(CB0->CB0_PEDCOM)
					CB0->CB0_STATUS:= "2"
				Else
					If ! Empty(CB0->CB0_NFENT)
						CB0->CB0_STATUS:= "2"
					EndIf
				EndIf
			EndIf
		Else
			CB0->CB0_STATUS:= " "
			nPos := Ascan(aEtiLidas,CB0->CB0_CODETI)
			If ! Empty(nPos) .and. ( lDigitaQtde .Or. CBQtdVar(CB0->CB0_CODPRO))
				CB0->CB0_QTDE := aEtiQtdOk[nPos,2]
			EndIf
		EndIf
		CB0->(MsUnLock())
		CB0->(DbSkip())
	End
	CB0->(DbSetOrder(1))
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³CBClABC   ºAutor  ³Erike Yuri da Silva º Data ³  01/12/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que verifica se o mestre de inventario usa Classificaº±±
±±º          ³cao ABC e se esta cadastrado na tabela de demanda           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Logico                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CBClABC(cProduto,cClasses,lAutomatico,cClasse)
Local lRet := .T.
Default lAutomatico := .F.

// Sempre inicializa com conteudo branco
cClasse := Space(1)

//Verifica se analisa Classificacao ABC
If SuperGetMV("MV_CBCLABC",.F.,.F.)
	dbSelectArea("SB3")
	SB3->(DbSetOrder(1))
	If !SB3->(DbSeek(xFilial("SB3")+cProduto))
		If !lAutomatico
			CBAlert(STR0098,STR0002,.T.) //"Produto nao localizado na tabela de demandas (SB3)!"###"Aviso"
		EndIf
		lRet := .F.
	EndIf
	If lRet .And. (dDataBase - SB3->B3_MES) > 30
		If !lAutomatico
			CBAlert(STR0099,STR0002,.T.) //"Favor executar o recalculo do lote economico para atualizar a tabela de demandas!"###"Aviso"
		EndIf
		lRet :=  .F.
	EndIf
	If lRet .And. !(SB3->B3_CLASSE $ cClasses)
		lRet := .F.
	EndIf
	If lRet
		cClasse := SB3->B3_CLASSE
	EndIf
EndIf
Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³V35VldLot ³ Autor ³ Erike Yuri da Silva   ³ Data ³ 03/06/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida o numero do lote com o produto.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ACDV035                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function V35VldLot(cProduto,cLocal,cLote,cSLote,cPrdOri)
Local cOldAlias	:= Alias()
Local aAreaSB8	:= SB8->(GetArea())
Local lRet 		:= .T.
Local lVldLotErr:= If(Pergunte("MTA270",.F.),MV_PAR01 == 1,.F.) // Indica se valida a existencia do produto.

cProdAux := If(Empty(cPrdOri),cProduto,cPrdOri)

If Rastro( cProduto, "S" )
	dbSelectArea( "SB8" )
	dbSetOrder( 3 )
	If !dbSeek( xFilial( "SB8" ) + cProdAux + cLocal+ cLote + cSLote, .F.) .And. lVldLotErr
		VTAlert(STR0110,STR0095,.T.,4000) //"Lote"###"Invalido"
		lRet := .F.
	EndIf
Else
	dbSelectArea( "SB8" )
	dbSetOrder( 3 )
	If !dbSeek( xFilial( "SB8" ) + cProdAux + cLocal + PADR(cLote,TamSX3('B8_LOTECTL')[1]) ) .And. lVldLotErr
		VTAlert(STR0110,STR0095,.T.,4000) //"Lote"###"Invalido"
		lRet := .F.
	EndIf
EndIf
SB8->(RestArea(aAreaSB8))
dbSelectArea(cOldAlias)
Return lRet



/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CBUltCont ³ Autor ³ Erike Yuri da Silva   ³ Data ³ 05/12/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna a ultima contagem de um inventario                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ACDV035,ACDA032                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CBUltCont(cCondInv)
Local cUltCont := Space(TamSX3("CBB_NUM")[1])
Local aAreaCBB := CBB->(GetArea())

CBB->(DbSetorder(3))
CBB->(DbSeek(xFilial('CBB')+cCondInv))
While CBB->(!Eof() .and. xFilial('CBB')+cCondInv == CBB_FILIAL+CBB_CODINV)
	cUltCont:=CBB->CBB_NUM
	CBB->(DbSkip())
EndDo
CBB->(RestArea(aAreaCBB))
Return cUltCont


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MsgInTrans³ Autor ³ Erike Yuri da Silva   ³ Data ³ 21/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Guarda Mensagens que serao apresentadas apos a transacao.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Tipo da funcao :1=CBALERT,2-MOSTRAERRO             ³±±
±±³          ³ ExpC1 = Texto da Mensagem     - VT100 / WINDOWS            ³±±
±±³          ³ ExpC2 = Titulo da Mensagem    - VT100 / WINDOWS            ³±±
±±³          ³ ExpL1 = Mensagem centralizada - VT100                      ³±±
±±³          ³ ExpN2 = Tempo que a mensagem ficara ativada - VT100        ³±±
±±³          ³ ExpN3 = Numero de beeps - VT100                            ³±±
±±³          ³ ExpL2 = Limpa get atual - VT100                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ACDV035                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MsgInTrans(nTipo,cTexto,cTitulo,lCenter,nTime,nBeep,lLimpa)
STATIC __aMsg := {}
Aadd(__aMsg,{nTipo,cTexto,cTitulo,lCenter,nTime,nBeep,lLimpa})
Return


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ViewMsgInT³ Autor ³ Erike Yuri da Silva   ³ Data ³ 21/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Visualiza as mensagens que foram guardadas pela funcao     ³±±
±±³          ³ MsgInTrans.                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ACDV035                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ViewMsgInT()
Local nI
For nI:=1 To Len(__aMsg)
	DO CASE
		Case __aMsg[nI,1]== 1
			CBAlert(__aMsg[nI,2],__aMsg[nI,3],__aMsg[nI,4],__aMsg[nI,5],__aMsg[nI,6],__aMsg[nI,7])
		Case __aMsg[nI,1]== 2
			If IsTelNet()
				VTDispFile(NomeAutoLog(),.t.)
			Else
				MostraErro()
			EndIf
	END CASE
Next
__aMsg := {}
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CBAtuContR³Autor ³    Isaias Florencio    ³ Data ³28/11/14  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³ Incrementa/Decrementa numero de contagens realizadas       º±±
±±ºDescricao ³ param[1]  - cCodInv: Codigo do mestre de inventario        º±±
±±º          ³ param[2]  - nOpc: 1 - Incrementa | 2 - Decrementa          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ACDA030/ACDA032/ACDA035/ACDV035                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function CBAtuContR(cCodInv, nOpc)
Local aAreaAnt := GetArea()
Local aAreaCBA := CBA->(GetArea())

CBA->(DbSetOrder(1)) //  FILIAL + CODINV
If CBA->(MsSeek(xFilial("CBA")+cCodInv))
	// Incrementa
	If nOpc == 1
		RecLock("CBA",.F.)
		CBA->CBA_CONTR := CBA->CBA_CONTR + 1
		CBA->(MsUnlock())

	// Decrementa
	ElseIf nOpc == 2
		If CBA->CBA_CONTR > 0
			RecLock("CBA",.F.)
			CBA->CBA_CONTR := CBA->CBA_CONTR - 1
			CBA->(MsUnlock())
		EndIf
	EndIf
EndIf

RestArea(aAreaCBA)
RestArea(aAreaAnt)
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AcdCopVal
Funçao de validões WMS

@author Andre Maximo
@since 04/10/17
@version 1.0
@Param Cod, Armazem, Endereço,Unitizador
/*/
//-------------------------------------------------------------------

Static Function AcdCopVal(cCod, cArmazem, cEndereco,cCodUnit,cProduto,cCodTpUni)

Local lRet	:= .F.
Local lEnd	:= CBA->CBA_TIPINV == "2"
Local lTipoCPO := CBA->(ColumnPos("CBA_CODUNI")) > 0
Local lWmsNew   := SuperGetMv("MV_WMSNEW",.F.,.F.)
Default cArmazem  := " "
Default cEndereco := " "
Default cProduto  := " "
Default cCodUnit  := " "
Default cCodTpUni := " "

If cCod == "END"
	If WmsEndUnit(cArmazem,cEndereco)
		lRet := .T.
	EndIf
ElseIf cCod == "UNI"
	If !Empty(cCodUnit).And. WmsVldEti(cArmazem,cEndereco,cCodUnit,@cCodTpUni)
		lRet :=.T.
		//-----------------------------------------//
		// Veririfica tipo de Inventario           //
		//-----------------------------------------//
	 	If lTipoCPO .And. lWmsNew
			cTipInv := CBA->CBA_CODUNI
			AProdUni := WmsSldUni(cCodUnit)
			If cTipInv == "1" .And. lEnd
				If Len(AProdUni) > 0
						lProcUnit:= AcdWMSProc(CBB->CBB_NUM,CBB->CBB_CODINV,AProdUni)
				EndIf
			ElseIf cTipInv == "2" .And. lEnd
				If  !VTYesNo(STR0124,STR0002,.T.) // Unitizador Violado /Aviso
					If Len(AProdUni) > 0
						lProcUnit:= AcdWMSProc(CBB->CBB_NUM,CBB->CBB_CODINV,AProdUni)
					EndIf
				EndIf
			EndIf

	 	EndIf


	Else
		VTAlert(STR0121,STR0002,.t.,3000) //"Codigo unitizador invalido"
		VTKeyboard(chr(20))
		Return .f.
	EndIf
ElseIf cCod == "VLP"
	If WmsPrdCmp(cProduto).And. WmsArmUnit(cArmazem)
		VTAlert(STR0123,STR0002,.t.,3000) //"Este Produto faz parte de uma estrutura dessa forma não pode ser inventariado"                                                                                                                                                                                                                                                                                                                                                                                                                                     "                                                                                                                                                                                                                                                                                                                                                                                                                                     "
		VTKeyboard(chr(20))
		Return .f.
	Else
		lRet := .T.
	EndIf
ElseIf cCod == "VLE"
	If WmsArmUnit(cArmazem).And. WmsPrdCmp(cProduto)
		lRet := .F.
	Else
		lRet := .T.
	EndIf
ELseIf cCod == "CTR"
	DbSelectArea("SB5")
	DbSetOrder(1)
	If SB5->(MsSeek(xFilial("SB5")+cProduto))
		If SB5->B5_CTRWMS == "1"
			lRet := .T.
		EndIf
	EndIf
EndIf



Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} AcdWMSProc
Funçao de processamento do Unitizador Fechado.

@author Andre Maximo
@since 21/12/2017
@version 1.0
@Param cNum,cCodInv,AProdUni
/*/
//-------------------------------------------------------------------

Static Function AcdWMSProc(cNum,cCodInv,AProdUni)

Local aArea		:= GetArea()
Local lRet		:= .F.
Local lUnitNot	:= .F.
Local lModelo1	:= SuperGetMv("MV_CBINVMD")=="1"
Local nX			:= 0
Local ncount 		:= 0

//Retorno array WMS unitizado.
//[1]  Local
//[2]  Endereço
//[3]  Lote
//[4]  Sub-lote
//[5]  Número de Série
//[6]  Quantidade
//[7]  Seg. Un medida
//[8]  Data de Validade
//[9]  Produto origem
//[10] Produto
//[11] Id Unitizador
//[12] Tipo Unitizador

CBC->(DBSetorder(2))
For nX :=1 To Len(AProdUni)
	If ! CBC->(DbSeek(xFilial('CBC')+cNum+AProdUni[Nx,10]+AProdUni[Nx,1]+AProdUni[Nx,2]+AProdUni[Nx,3]+AProdUni[Nx,4]+AProdUni[Nx,5]+AProdUni[Nx,11]))
		RecLock("CBC",.T.)
		CBC->CBC_FILIAL := xFilial("CBC")
		CBC->CBC_CODINV := cCodInv
		CBC->CBC_NUM    := cNum
		CBC->CBC_LOCAL  := AProdUni[Nx,1]
		CBC->CBC_LOCALI := AProdUni[Nx,2]
		CBC->CBC_COD    := AProdUni[Nx,10]
		CBC->CBC_LOTECT := AProdUni[Nx,3]
		CBC->CBC_NUMLOT := AProdUni[Nx,4]
		CBC->CBC_NUMSER := AProdUni[Nx,5]
		CBC->CBC_IDUNIT := AProdUni[Nx,11]
		CBC->CBC_CODUNI := AProdUni[Nx,12]
	Else
		If ! lModelo1
			If CBC->CBC_CONTOK =="1"
				VTBeep(3)
				VTAlert(STR0073,STR0074+AProdUni[Nx,10],.t.,4000)  //"Nao eh necessario a recontagem!!!"###"Produto ja auditado"
				VTKeyBoard(chr(20))
				//Variavel de controla de o item será processado
				lUnitNot := .T.
			EndIf
		EndIf
		RecLock("CBC",.f.)
	EndIf
	If !lUnitNot
		CBC->CBC_QUANT  += AProdUni[Nx,6]
		CBC->CBC_QTDORI += AProdUni[Nx,6]
		CBC->(MsUnlock())
		lRet:= .T.
		ACD35CBM(3,cCodInv,AProdUni[Nx,10],AProdUni[Nx,1],AProdUni[Nx,2],AProdUni[Nx,3],AProdUni[Nx,4],AProdUni[Nx,5],AProdUni[Nx,11],AProdUni[Nx,12])
		ncount++
	EndIf
	lUnitNot := .F.

Next nX

VTAlert(STR(ncount),STR0125,.t.,4000)

//Limpa Tela para proxima contagem
VTKeyBoard(chr(20))
cCodUnit := CriaVar('D14_IDUNIT', .F.)
VTGetRefresh('cCodUnit')
VtGetSetFocus('cCodUnit')


RestArea(aArea)
Return lRet

Static Function QbrString(nOpc,cString)

Local aDados := Separa(cString,"|")
Local cRet := {}
Local nTam := Len(cString)

If Len(aDados) >= nOpc
	cRet := aDados[nOpc]
Endif

cRet := Padr(cRet,nTam)

Return cRet

//Customizado
Static Function CBRastro(cProduto,cLote,cSubLote,dValid,lEmpty,lNextLote)
Local aSave
Local aRetAux		:= {}
Local nQE			:= 1
IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf
DEFAULT lEmpty		:= .F.
DEFAULT lNextLote 	:= .F.


If ! Rastro(cProduto)
	Return .t.
EndIf

If	ExistBlock("CBRastro")
	// o retorno devera ser um array conforme abaixo:
	//{lote,sub-lote,data de validade}
	aRetAux := ExecBlock("CBRastro",.F.,.F.,{cProduto,cLote,cSubLote,dValid})
	If	Valtype(aRetAux)=='A' .And. Len(aRetAux) == 3
		cLote    := If(Valtype(aRetAux[1])=='C',aRetAux[1],cLote)
		cSubLote := If(Valtype(aRetAux[2])=='C',aRetAux[2],cSubLote)
		dValid   := If(Valtype(aRetAux[3])=='D',aRetAux[3],dValid)
	EndIf
EndIf

aSave   := VTSAVE()

If Empty(cLote)
	If lVT100B // GetMv("MV_RF4X20")
		cLote := Space(80)
		VTClear
		@ 0,0 VtSay "Lote""
		@ 1,0 VtGet cLote /*pict '@!'*/  valid If(lEmpty,.t.,!Empty(cLote).Or. lNextLote) when Empty(cLote)
		If Rastro(cProduto,"S")	.and. cSubLote <> NIL
			@ 2,0 VtSay STR0016  //"Sub-Lote"
			@ 3,0 VtGet cSubLote pict '@!' valid If(lEmpty,.t.,!Empty(cSubLote))
		EndIf
		VTRead
		VTClear()
		If dValid <> NIL
			@ 0,0 VtSay "Validade"  //"Validade"
			@ 1,0 VtGet dValid pict '@D' valid If(lEmpty,.t.,!Empty(dValid))
			VTREAD
		EndIf

	ElseIf VTModelo()=="RF"
		//cLote := Space(60)
		VTClear
		@ 0,0 VTSay "Produto com rastro"
		@ 2,0 VtSay "Lote"
		@ 3,0 VtGet cLote /*pict '@!'*/  valid QuebraLote(@cLote) .OR. If(lEmpty,.t.,!Empty(cLote).Or. lNextLote) when Empty(cLote)
		If Rastro(cProduto,"S")	.and. cSubLote <> NIL
			@ 5,0 VtSay  "Sub-Lote"
			@ 6,0 VtGet cSubLote pict '@!' valid If(lEmpty,.t.,!Empty(cSubLote))
		EndIf
		If dValid <> NIL
			@ 5,0 VtSay  "Validade"
			@ 6,0 VtGet dValid pict '@D' valid If(lEmpty,.t.,!Empty(dValid))
		EndIf
		VTREAD
	Else
		VTClear
		@ 0,0 VTSay "Produto com rastro"
		@ 1,0 VtSay  "Lote:"
		@ 1,7 VtGet cLote pict '@!'  valid If(lEmpty,.t.,!Empty(cLote)) when Empty(cLote)
		VTREAD
		If Rastro(cProduto,"S")	.and. cSubLote <> NIL
			VTClear(1,0,VTMaxCol(),VTMaxRow())
			@ 1,00 VtSay "Sub-Lote:"
			@ 1,10 VtGet cSubLote pict '@!' valid If(lEmpty,.t.,!Empty(cSubLote))
			VTREAD
		EndIf
		If dValid <> NIL
			VTClear(1,0,VTMaxCol(),VTMaxRow())
			@ 1,0 VtSay  "Validade:"
			@ 1,10 VtGet dValid pict '@D' valid If(lEmpty,.t.,!Empty(dValid))
			VTREAD
		EndIf
	EndIf
	VtRestore(,,,,aSave)
	If VTLastKey() == 27
		VTAlert("Lote invalido","Aviso",.t.,3000)
		Return .f.
	EndIf
EndIf
//???????????????????????????????
//?era Lote automatico considerando a formula B1_FORMLOT caso ?
//?xista                                                      ?
//???????????????????????????????
If lNextLote .And. Empty(cLote)
	cLote := NextLote(SC2->C2_PRODUTO,"L")
EndIf
Return .t.

//Customizado
Static FUnction QuebraLote(cString)

Local aDados := Separa(cString,"|")
Local cRet := {}
Local nTam := Len(cString)

If Len(aDados) > 0
	cRet := aDados[2]
Endif

cRet := Padr(cRet,TamSx3("CB8_LOTECTL")[1])
cString := cRet

Return .F.

Static Function ConvQtd(cProduto,cArmazem,nQuant)

Local aArea := GetArea()
Local aAreaNNR := NNR->(GetArea())

NNR->(dbSetOrder(1))
If NNR->(dbSeek( FWxFilial("NNR") + cArmazem))  .And. NNR->NNR_XINVEN = "2"
	SB1->(dbSetOrder(1))
	If SB1->(dbSeek( FWxFilial("SB1") + Alltrim(cProduto))) .And. SB1->B1_CONV > 0
		If SB1->B1_TIPCONV == 'D'
			nQtdEtiq :=SB1->B1_CONV * nQuant 
		Else
			nQtdEtiq :=SB1->B1_CONV / nQuant 
		EndIf
	Endif
Endif

Return .T.
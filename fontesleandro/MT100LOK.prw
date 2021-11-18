#include "rwmake.ch"

//	#########################################################################################
//	Projeto: DAXIA
//	Modulo : Contabilidade
//	Fonte  : MT100LOK.prw
//	---------+-------------------+-----------------------------------------------------------
//	Data     | Autor             | Descricao
//	---------+-------------------+-----------------------------------------------------------
//	25/09/19 |TIB                | Ponto de Entrada - Validacao da Conta Contábil / Centro
//	         |Leandro Frasson    | de Custo e Item Contábil
//	         |                   |
//	---------+-------------------+-----------------------------------------------------------
//	#########################################################################################

User Function MT100LOK

_cConta   := ascan(aheader,{|x|upper(alltrim(x[2]))=="D1_CONTA"})
_cCc  	  := ascan(aheader,{|x|upper(alltrim(x[2]))=="D1_CC"})
_cItemcta := ascan(aheader,{|x|upper(alltrim(x[2]))=="D1_ITEMCTA"})
_cRAteio  := ascan(aheader,{|x|upper(alltrim(x[2]))=="D1_RATEIO"})
_cItem    := ascan(aheader,{|x|upper(alltrim(x[2]))=="D1_ITEM"})
_cCfop    := ascan(aheader,{|x|upper(alltrim(x[2]))=="D1_CF"})
_Ret      := .t.

If IsInCallStack('IMPORTCOL')
	Return _Ret
EndIf

lTransf := procname(9) == "A310PROC"

If !aCols[n,Len(acols[n])]
	
	If Empty(aCols[n,_cConta]) .AND. aCols[n,_cRAteio] == '2' .and. !lTransf
		MSGBOX("Deverá ser informado C Contábil. Verifique! ","AVISO","STOP")
		_Ret := .F. 
		
	ElseIf Empty(aCols[n,_cItemcta]) .AND. aCols[n,_cRAteio] == '2' .and. !lTransf .and. POSICIONE("CT1",1,xFilial("CT1")+aCols[n,_cConta],"CT1_ITOBRG")=="1"
		MSGBOX("Deverá ser informado Nº Processo. Verifique! ","AVISO","STOP")
		_Ret := .F.
		
	ElseIf Empty(aCols[n,_cCc]) .AND. aCols[n,_cRAteio] == '2' .AND. !lTransf .and. SF4->F4_ESTOQUE <> "S" .and. !Substr(aCols[n,_cCfop],2,3)$"551_552"
		MSGBOX("Deverá ser informado o Centro Custo. Verifique! ","AVISO","STOP")
		_Ret := .F.
		
	ElseIf  Empty(aCols[n,_cCc]) .AND. aCols[n,_cRAteio] == '1'
		ascan(aheader,{|x|upper(alltrim(x[2]))=="D1_ITEM"})
		_Ret := .F.
		For i := 1 to Len(aBackColsSDE)
			If aBackColsSDE[i][1] == aCols[n,_cItem]
				For x := 1 to Len(aBackColsSDE[i][2])
					If aBackColsSDE[i][2][x][1] <> " "
						_Ret := .T.
					EndIf
				Next x
			EndIf
		Next i
		If !_Ret .and. !lTransf
			MSGBOX("Deverá ser informado o centro de custo ou rateio. Verifique! ","AVISO","STOP")
		EndIF
	EndIf
EndIf
Return(_Ret)

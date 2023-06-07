#INCLUDE 'RWMAKE.CH'
#INCLUDE 'APVT100.CH'
#INCLUDE "TOPCONN.CH"
/*                                                                                                                                                                       fonte
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CBRETEAN  ºAutor  ³ Edson Estevam      º Data ³  04/07/2015 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada no momento da separacao/enderecamento     º±±
±±º          ³ para validar o  codigo de barra                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ACD                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function CBRETEAN()
//Local lRet     := .F.
Local aRet     := {}
Local aArea    := GetArea()
Local cCodBar  := Alltrim(PARAMIXB[1])
Local cProduto := ""
Local cLote    := ""
Local aCodBar  := {}
Local nQtde	   := 0.00
Local dDtValid := Stod(' ')

/* causou impacto em oturas rotinas
IF Empty(cCodBar) .Or. !(IsInCallStack('WMSV001') .Or. IsInCallStack('WMSV104'))
	Return (aRet)
Endif
*/

/* não deve apresentar mais o help, cliente solicitou
If IsInCallStack('WMSV104')
	SB1->(DbSeek(xFilial('SB1') + D0Z->D0Z_PRODUT))
	WMSVTAviso('Atenção','Qtd ' + Alltrim(Str(D0Z->D0Z_QTDORI / SB1->B1_CONV) + ' ' + Alltrim(SB1->B1_SEGUM)))
EndIf
*/

SB1->(DbSetOrder(1))
If IsInCallStack('WMSV104')
	SB1->(DbSeek(xFilial('SB1') + D0Z->D0Z_PRODUT))
	If Posicione('SC5',1,xFilial('SC5') + D0Z->D0Z_PEDIDO, 'C5_ZZEXCEC') == 'S' 
		WMSVTAviso('Atenção','Pedido ' + Alltrim(D0Z->D0Z_PEDIDO) + ' com exceção!')
	EndIF
EndIf

cCodBar := Strtran(cCodbar,'.','|')
aCodBar:=StrTokArr(cCodBar, "|")


If Len(aCodBar) <> 3
	Return (aRet)
Endif

cProduto := AvKey(aCodBar[1],"B1_COD" )
cLote    := AvKey(aCodBar[2],"D1_LOTECTL" )
nQtde     := Val(aCodBar[3])

If SB1->(DbSeek(xFilial('SB1') + cProduto))
    cProduto := SB1->B1_CODBAR
    If SB1->B1_TIPCONV == 'D'
        nQtde :=nQtde / SB1->B1_CONV 
    Else
        nQtde :=nQtde * SB1->B1_CONV 
    EndIf
EndIf

If !Empty(cProduto)
	//codigo do produto,quantidade,lote,data de validade, numero de serie
	AAdd(aRet,cProduto)   //Codigo do produto
	AAdd(aRet,0)		  //Quantidade
	AAdd(aRet,cLote)  	  //Lote
	AAdd(aRet,dDtValid)   //Data de validade
	AAdd(aRet,Space(20))  //Numero de Serie
Endif

RestArea(aArea)
Return (aRet)

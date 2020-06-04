#include 'protheus.ch'
#include 'parmtype.ch'

//	#########################################################################################
//	Projeto: DAXIA
//	Modulo : Contabilidade
//	Fonte  : C105VLIN.prw
//	---------+-------------------+-----------------------------------------------------------
//	Data     | Autor             | Descricao
//	---------+-------------------+-----------------------------------------------------------
//	10/10/19 |TIB                | Ponto de Entrada na rotina CTBA105 - Contabiliza��o de
//	         |Leandro Frasson    | Integra��o e CTBA102 Contabiliza��o Automatica
//	         |                   | N�o permite deletar linha
//	---------+-------------------+-----------------------------------------------------------
//	#########################################################################################


User Function C105VLIN()
Local lRet  := .T.
//Verifica se a linha esta deletada, campo CT2_FLAG igual a .T. quando a linha esta deletada
Local aUser := Separa(SuperGetMv("MV_YDELCTB",, "000000"), ";")
//Verifica os usu�rios que tem permiss�o de deltar a linha 

//IF ALTERA

If !(ascan(aUser,Alltrim(RetCodUsr())) > 0)
	
	If TMP->CT2_FLAG
		MsgInfo("A linha n�o pode ser deletada. Procurar a Contabilidade!")
		lRet := .F.
	Endif
	Endif
//ENDIF
//Atualiza o browse
oGetDB:oBrowse:Refresh()

Return lRet

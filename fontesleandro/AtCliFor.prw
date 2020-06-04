#include "rwmake.ch"
#include "protheus.ch"

//	#########################################################################################
//	Projeto: DAXIA
//	Modulo : Contabilidade
//	Fonte  : AtCliFor.prw
//	---------+-------------------+-----------------------------------------------------------
//	Data     | Autor             | Descricao
//	---------+-------------------+-----------------------------------------------------------
//	08/07/19 |TIB                | Rotina para atualizar o cadastro da Classe de Valor
//	         |Leandro Frasson    | 
//	---------+-------------------+-----------------------------------------------------------
//	#########################################################################################

User Function AtCliFor()

//===================================================
// Rotina para atualizar o cadastro da Classe de Valor
// dos Clientes
//===================================================

dbselectarea("SA1")
SA1->(dbgotop())

While !SA1->(eof())
	
	RecLock("CTH",.T.)
	
	CTH->CTH_FILIAL :=  SA1->A1_FILIAL
	CTH->CTH_CLVL   :=	"C"+alltrim(SA1->A1_COD)+alltrim(SA1->A1_LOJA)
	CTH->CTH_DESC01 :=	SA1->A1_NOME
	CTH->CTH_CLASSE :=	"2"
	CTH->CTH_BLOQ   :=	"2"
	CTH->CTH_DTEXIS :=	CTOD("01/01/1980")
	CTH->CTH_CLVLLP :=	"C"+alltrim(SA1->A1_COD)+alltrim(SA1->A1_LOJA)
	
	CTH->(MSUNLOCK())
	
	SA1->(dbskip())
	
EndDo

SA1->(dbclosearea())

//===================================================
// Rotina para atualizar o cadastro da Classe de Valor
// dos Fornecedores
//===================================================

dbselectarea("SA2")
SA2->(dbgotop())

While !SA2->(eof())
	
	RecLock("CTH",.T.)
	
	CTH->CTH_FILIAL :=  SA2->A2_FILIAL
	CTH->CTH_CLVL   :=	"F"+alltrim(SA2->A2_COD)+alltrim(SA2->A2_LOJA)
	CTH->CTH_DESC01 :=	SA2->A2_NOME
	CTH->CTH_CLASSE :=	"2"
	CTH->CTH_BLOQ   :=	"2"
	CTH->CTH_DTEXIS :=	CTOD("01/01/1980")
	CTH->CTH_CLVLLP :=	"F"+alltrim(SA2->A2_COD)+alltrim(SA2->A2_LOJA)
	
	CTH->(MSUNLOCK())
	
	SA2->(dbskip())
	
EndDo

SA2->(dbclosearea())

//===================================================
// Rotina para atualizar o cadastro da Classe de Valor
// dos Produtos
//===================================================

dbselectarea("SB1")
SB1->(dbsetorder(1))
SB1->(dbgotop())

While !SB1->(eof())
	
	RecLock("CTH",.T.)
	
	CTH->CTH_FILIAL :=  SB1->B1_FILIAL
	CTH->CTH_CLVL   :=	"P"+alltrim(SB1->B1_COD)
	CTH->CTH_DESC01 :=	SB1->B1_DESC
	CTH->CTH_CLASSE :=	"2"
	CTH->CTH_BLOQ   :=	"2"
	CTH->CTH_DTEXIS :=	CTOD("01/01/1980")
	CTH->CTH_CLVLLP :=	"P"+alltrim(SB1->B1_COD)
	
	CTH->(MSUNLOCK())
	
	SB1->(dbskip())
	
EndDo

SB1->(dbclosearea())

//===================================================
// Rotina para atualizar o cadastro da Classe de Valor
// dos Ativos
//===================================================

dbselectarea("SN1")
SN1->(dbgotop())

While !SN1->(eof())
	
	RecLock("CTH",.T.)
	
	CTH->CTH_FILIAL :=  SN1->N1_FILIAL
	CTH->CTH_CLVL   :=	"A"+alltrim(SN1->N1_CBASE)+alltrim(SN1->N1_ITEM)
	CTH->CTH_DESC01 :=	SN1->N1_DESCRIC
	CTH->CTH_CLASSE :=	"2"
	CTH->CTH_BLOQ   :=	"2"
	CTH->CTH_DTEXIS :=	CTOD("01/01/1980")
	CTH->CTH_CLVLLP :=	"A"+alltrim(SN1->N1_CBASE)+alltrim(SN1->N1_ITEM)
	
	CTH->(MSUNLOCK())
	
	SN1->(dbskip())
	
EndDo

SN1->(dbclosearea())
         


CTH->(dbclosearea())

ALERT("CONCLUÍDO")

Return

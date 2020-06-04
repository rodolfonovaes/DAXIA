#include "rwmake.ch"
#include "protheus.ch"
#include "Topconn.ch"

/*/
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������Ŀ��
���P.Entrada �  ClvlCta � Autor �   TIB-Frasson               � Data � 06/08/19 ���
�������������������������������������������������������������������������������Ĵ��
���Descri��o � Inclus�o autom�tica da classe de valor referente                 ���
��� na grava��o do lan�amento cont�bil.                                         ���
��� Parametros da Fun��o:  cPar1 - Caracter Inicial do C�digo da Classe Cont�bil���
���                        cPar2 - C�digo Forncedor/Cliente/Produto/Banco/Ativo ���
���                        cPar3 - C�digo Loja/Agencia/Item Ativo               ���
���                        cPar4 - C�digo Conta Banco                           ���
��� Exemplo: u_ClvlCta("F","SA2->A2_COD","SA2->A2_LOJA")                        ���
�������������������������������������������������������������������������������Ĵ��
/*/

User Function ClvlCta(cPar1,cPar2,cPar3,cPar4)

Local aArea := getarea()
Local _lRet
Local _cDesc

If FunName() <> "CTBA080"
	
	If cPar2 == "SA1->A1_COD"     //Cliente
		
		_lRet  := Alltrim(cPar1)+alltrim(&cPar2)+alltrim(&cPar3)
		_cDesc := SA1->A1_NOME
		
	ElseIf cPar2 == "SA2->A2_COD" //Fornecedor
		
		_lRet  := Alltrim(cPar1)+alltrim(&cPar2)+alltrim(&cPar3)
		_cDesc := SA2->A2_NOME
		
	ElseIf cPar2 == "SB1->B1_COD" //Produto
		
		_lRet := Alltrim(cPar1)+alltrim(&cPar2)
		_cDesc := SB1->B1_DESC
		
	ElseIf cPar2 == "SA6->A6_COD" //Banco
		
		_lRet := Alltrim(cPar1)+alltrim(&cPar2)+alltrim(&cPar3)+alltrim(&cPar4)
		_cDesc := SA6->A6_NOME
		
	ElseIf cPar2 == "SN1->N1_CBASE" //Ativo
		
		_lRet := Alltrim(cPar1)+alltrim(&cPar2)
		_cDesc := SN1->N1_DESCRIC
		
	EndIf
	
	XCONCTH:=" SELECT COUNT(*) AS CONT FROM "+RETSQLNAME("CTH")+" WHERE D_E_L_E_T_ = ' ' AND CTH_CLVL = '"+_lRet+"'"
	
	If Select("XCONCTH")> 0
		XCONCTH->(DBCLOSEAREA())
	Endif
	
	TCQUERY XCONCTH NEW ALIAS "XCONCTH"
	
	If XCONCTH->CONT < 1
		
		// Grava conta no CTH
		RecLock("CTH",.T.)
		
		CTH->CTH_FILIAL  := '    '
		CTH->CTH_CLVL    := _lRet
		CTH->CTH_DESC01  := _cDesc
		CTH->CTH_CLASSE  := '2'
		CTH->CTH_BLOQ    := '2'
		CTH->CTH_DTEXIS	 := CtoD("01/01/1980")
		CTH->CTH_CLVLLP  := _lRet
		
		CTH->(MSUNLOCK())
		
	Endif
	
EndIf

RestArea(aArea)

Return(_lRet)

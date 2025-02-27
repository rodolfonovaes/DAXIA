#INCLUDE "PROTHEUS.CH"

/*
F100TOK - Validações Específicas de Usuário
Descrição:	O ponto se encontra no final da função e deve ser utilizado para validações especificas do usuario onde será controlada pelo 
retorno do ponto de entrada o qual se for .F. o processo será interrompido e se .T. será validado.
Daxia:	Validar na digitação da movimentação bancária os seguintes dados: 
        Centro de Custo e/ou Item Contábil validando o cadastro da conta contábil da natureza, se existe a obrigação do ccusto/item (plano de contas).
@author 	Rossana Barbosa
@since		14/05/2021
@version 	1.0
*/

User Function F100TOK()
Local lRet		:= .T.
Local aArea 	:= GetArea()
Local cCtaD 	:= ""
Local cCtaC 	:= ""
Local cCc	    := ""
Local cItemD    := ""
Local cHist 	:= ""

cCtaD   := M->E5_DEBITO
cCtaC   := M->E5_CREDITO
cCc     := M->E5_CCUSTO
cItemD  := M->E5_ITEMD
cHist   := M->E5_HISTOR

	If !lF100Auto

		If Empty(cCtaD)
			Help('', 1, 'F100TOK01',, 'Favor informar a Conta Cont�bil no cadastro da Natureza.', 1, 0)
			lRet := .F.
		Else
			If Empty(cCtaC)
				Help('', 1, 'F100TOK02',, 'Favor informar a Conta Cont�bil no cadastro do Banco.', 1, 0)
				lRet := .F.
			Else
				If Empty(cHist)
					Help('', 1, 'F100TOK03',, 'Favor informar Hist�rico.', 1, 0)
					lRet := .F.
				Endif
			Endif
		Endif

		IF !EMPTY(cCtaD)

			CT1->(Dbsetorder(1))

			IF CT1->(DbSeek(xFilial('CT1') + cCtaD)) //Atualizado pela conta da natureza.
				
				IF CT1->CT1_CCOBRG == '1'

					// Valida Centro de Custo e Rateio baseado na conta cont�bil (CT1_CCOBRG = 1 sim)
					If Empty( cCc )
						Help('', 1, 'F100TOK04',, 'Favor informar o Centro de Custo pois a classifica��o cont�bil deste item obriga esta informa��o', 1, 0)
						lRet	:= .F.

					Endif
				Endif

				IF CT1->CT1_ITOBRG == '1'

					// Valida Item Contábil e Rateio baseado na conta cont�bil (CT1_ITOBRG = 1 sim)
					If Empty( cItemD )
						Help('', 1, 'F100TOK05',, 'Favor informar o N� Processo pois a classifica��o cont�bil deste item obriga esta informa��o', 1, 0)
						lRet	:= .F.

					Endif
				Endif

			EndIf

		EndIf

	Endif

	RestArea(aArea)

Return lRet

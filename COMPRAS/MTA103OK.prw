#INCLUDE "PROTHEUS.CH"

/*
MTA103OK - Validações Específicas de Usuário
Descrição:	O ponto se encontra no final da função e deve ser utilizado para validações especificas do usuario onde será controlada pelo 
retorno do ponto de entrada o qual se for .F. o processo será interrompido e se .T. será validado.
Daxia:	Validar a digitação no item da nota ou no rateio do item da nota dos seguintes dados: 
        Centro de Custo e/ou Item Contábil validando o cadastro da conta contábil do item/produto, se existe a obrigação do ccusto/item (plano de contas).
@author 	Rossana Barbosa
@since		14/05/2021
@version 	1.0
*/

User Function MTA103OK()
	Local lRet		    := .T.
	Local aArea		    := GetArea()
	Local nPosConta	    := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_CONTA"})
	Local nPosCCus	    := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_CC"})
	Local nPosItem	    := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_ITEMCTA"})
	Local nPosCLVL   	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_CLVL"})
	Local nPosRateio	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_RATEIO"}) // 1=Sim;2=Nao
	Local cCCusto	    := aCols[n][nPosCCus]
	Local cItem	        := aCols[n][nPosItem]	
	Local cConta        := aCols[n][nPosConta]	
	Local cRateio	    := aCols[n][nPosRateio]
	Local cClvl		    := aCols[n][nPosCLVL]

	// Valida se é Rotina Automática
	If lRet .And. !l103Auto .And. !aCols[n][Len(aCols[n])]

		IF !EMPTY(cConta)		

			CT1->(Dbsetorder(1))

			IF CT1->(DbSeek(xFilial('CT1') + cConta))
				
				IF CT1->CT1_CCOBRG == '1'

					// Valida Centro de Custo e Rateio baseado na conta contábil (CT1_CCOBRG = 1 sim)
					If cRateio=="2" .And. Empty(cCCusto) 
						Help('', 1, 'MTA103OK01',, 'Favor informar o Centro de Custo (na linha do item ou na opção de rateio) pois a classificação contábil deste item obriga esta informação', 1, 0)
						lRet := .F.
					EndIf

				EndIf

				IF CT1->CT1_ITOBRG == '1'

					// Valida Item Contábil e Rateio baseado na conta contábil (CT1_ITOBRG = 1 sim)
					If cRateio=="2" .And. Empty(cItem)
						Help('', 1, 'MTA103OK02',, 'Favor informar o  Nº Processo (na linha do item ou na opção de rateio) pois a classificação contábil deste item obriga esta informação', 1, 0)
						lRet := .F.
					EndIf

				EndIf

				IF CT1->CT1_CLOBRG == '1'

					// Valida Item Contábil e Rateio baseado na conta contábil (CT1_CLOBRG = 1 sim)
					If cRateio=="2" .And. Empty(cClvl)
						Help('', 1, 'MTA103OK03',, 'Favor informar a classe de valor (na linha do item ou na opção de rateio) pois a classificação contábil deste item obriga esta informação', 1, 0)
						lRet := .F.
					EndIf

				EndIf

			EndIf

		EndIf

	EndIf

	RestArea(aArea)
Return lRet

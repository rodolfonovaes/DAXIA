#INCLUDE "PROTHEUS.CH"

/*
MTA103OK - Valida��es Espec�ficas de Usu�rio
Descri��o:	O ponto se encontra no final da fun��o e deve ser utilizado para valida��es especificas do usuario onde ser� controlada pelo 
retorno do ponto de entrada o qual se for .F. o processo ser� interrompido e se .T. ser� validado.
Daxia:	Validar a digita��o no item da nota ou no rateio do item da nota dos seguintes dados: 
        Centro de Custo e/ou Item Cont�bil validando o cadastro da conta cont�bil do item/produto, se existe a obriga��o do ccusto/item (plano de contas).
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

	// Valida se � Rotina Autom�tica
	If lRet .And. !l103Auto .And. !aCols[n][Len(aCols[n])]

		IF !EMPTY(cConta)		

			CT1->(Dbsetorder(1))

			IF CT1->(DbSeek(xFilial('CT1') + cConta))
				
				IF CT1->CT1_CCOBRG == '1'

					// Valida Centro de Custo e Rateio baseado na conta cont�bil (CT1_CCOBRG = 1 sim)
					If cRateio=="2" .And. Empty(cCCusto) 
						Help('', 1, 'MTA103OK01',, 'Favor informar o Centro de Custo (na linha do item ou na op��o de rateio) pois a classifica��o cont�bil deste item obriga esta informa��o', 1, 0)
						lRet := .F.
					EndIf

				EndIf

				IF CT1->CT1_ITOBRG == '1'

					// Valida Item Cont�bil e Rateio baseado na conta cont�bil (CT1_ITOBRG = 1 sim)
					If cRateio=="2" .And. Empty(cItem)
						Help('', 1, 'MTA103OK02',, 'Favor informar o  N� Processo (na linha do item ou na op��o de rateio) pois a classifica��o cont�bil deste item obriga esta informa��o', 1, 0)
						lRet := .F.
					EndIf

				EndIf

				IF CT1->CT1_CLOBRG == '1'

					// Valida Item Cont�bil e Rateio baseado na conta cont�bil (CT1_CLOBRG = 1 sim)
					If cRateio=="2" .And. Empty(cClvl)
						Help('', 1, 'MTA103OK03',, 'Favor informar a classe de valor (na linha do item ou na op��o de rateio) pois a classifica��o cont�bil deste item obriga esta informa��o', 1, 0)
						lRet := .F.
					EndIf

				EndIf

			EndIf

		EndIf

	EndIf

	RestArea(aArea)
Return lRet

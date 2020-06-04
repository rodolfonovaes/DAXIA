#INCLUDE 'TOTVS.CH'

// ----------------------------------------------------------------------
/*/{Protheus.doc} ProdNext
Retorna o proximo numero sequencial para construcao do codigo do produto
Funcao utilizada no gatilho dos campos B1_XCODFAM, B1_XCODLIN e B1_GRUPO
@author 
@since 23/11/2017
@version 1.0
@param cCodFam, character, Cod Família de itens
@param cCodLin, character, Cod Linha de itens
@param cGrupo, character, Grupo do itens 
Ajustado por Ricardo Amorim em 23/04/2019
/*/
// ----------------------------------------------------------------------
User Function ProdNext(cCodFam,cCodLin,cGrupo)
Local cRet       := ''
Local cAliasQry  := ''
Local aArea      := GetArea()
Local aAreaSB1   := SB1->(GetArea())
Default cCodFam  := M->B1_XCODFAM
Default cCodLin  := M->B1_XCODLIN
Default cGrupo   := M->B1_XGRUPO

cAliasQry := GetNextAlias()
BeginSQL Alias cAliasQry
	SELECT  MAX(SB1.B1_COD) B1_COD
	  FROM %Table:SB1% SB1
	 WHERE SB1.B1_FILIAL  	= %xFilial:SB1%
	   AND SB1.B1_XCODFAM   = %Exp:M->B1_XCODFAM% 	
	   AND SB1.B1_XCODLIN   = %Exp:M->B1_XCODLIN% 	
	   AND SB1.B1_XGRUPO   	= %Exp:M->B1_XGRUPO%
	   AND SB1.%NotDel%
EndSQL

If (cAliasQry)->(Eof()) .Or. Empty((cAliasQry)->B1_COD)
	cRet := cGrupo + '0001'
Else
	cRet := Soma1(Right(AllTrim((cAliasQry)->B1_COD), 10))
	SB1->(DbSetOrder(1))
	While SB1->(DbSeek(xFilial('SB1') + cRet)) //Tratamento para não pegar produto que ja existe
		cRet := Soma1(Right(AllTrim(SB1->B1_COD), 10))
	Enddo
EndIf

(cAliasQry)->(DbCloseArea())

RestArea(aArea)
RestArea(aAreaSB1)
Return(cRet)
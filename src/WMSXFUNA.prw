#INCLUDE "PROTHEUS.CH"
#INCLUDE "WMSXFUNA.CH" 
#INCLUDE 'APVT100.CH'
#INCLUDE "DBINFO.CH"

#DEFINE CLRF  Chr(13)+Chr(10)
#DEFINE WMSXFUNA01 "WMSXFUNA01"
#DEFINE WMSXFUNA02 "WMSXFUNA02"
#DEFINE WMSXFUNA03 "WMSXFUNA03"
#DEFINE WMSXFUNA04 "WMSXFUNA04"
#DEFINE WMSXFUNA05 "WMSXFUNA05"
#DEFINE WMSXFUNA06 "WMSXFUNA06"
#DEFINE WMSXFUNA07 "WMSXFUNA07"
#DEFINE WMSXFUNA08 "WMSXFUNA08"

Static __oOrdServ  := Nil
Static __aLibDCF   := {}
Static __lArmzUnit := .F.
Static __cLastArmz := ""
Static __lDLGA150E := ExistBlock("DLGA150E")
Static __lWMSALIB  := ExistBlock("WMSALIB")
Static __lWMSAVISO := ExistBlock("WMSAVISO")
Static __lWMSACEXP := ExistBlock("WMSACEXP")

/*
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- Função     WmsCarga    Autor  Alex Egydio/Fernando Joly Data 27.12.2004 --
-----------------------------------------------------------------------------
-- Descrição   Processos por carga ou documento/serie                      --
-----------------------------------------------------------------------------
-- Parametros  ExpC1 - Codigo da carga                                     --
--             ExpL1 - .T. = Analisa o parametro MV_WMSACAR                --
-----------------------------------------------------------------------------
--  Retorno    Logico                                                      --
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------*/
Function WmsCarga(cCarga,lWmsACar)
Local lRet     := .T.
Default cCarga := ''
Default lWmsACar:= .T.
	//-- Analisa o parametro mv_wmsacar
	If lWmsACar
		//-- .T. = Processos por carga
		//-- .F. = Processos por documento/serie
		lRet := (!Empty(cCarga) .And. SuperGetMV('MV_WMSACAR', .F., 'S')=='S')
	EndIf
Return(lRet)
/*
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- Função     WmsQtdUni   Autor  Alex Egydio/Fernando Joly Data 10.01.2005 --
-----------------------------------------------------------------------------
-- Descrição   Calcula a quantidade de produtos em Unitizadores,           --
--             2a.U.M. e 1a.U.M.                                           --
-----------------------------------------------------------------------------
-- Parametros  ExpC1 - Codigo do produto                                   --
--             ExpC2 - Armazem                                             --
--             ExpC3 - Codigo da estrutura fisica                          --
--             ExpN1 - Quantidade                                          --
-----------------------------------------------------------------------------
--  Retorno    Vetor aRet                                                  --
--             [01,01] = Quantidade de unitizadores                        --
--             [01,02] = Descricao do unitizador                           --
--             [02,01] = Quantidade na 2a.Unidade de medida                --
--             [02,02] = Descricao da 2a.U.M.                              --
--             [03,01] = Quantidade na 1a.U.M.                             --
--             [03,02] = Descricao da 1a.U.M.                              --
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------*/
Function WmsQtdUni(cCodPro,cArmazem,cEstFis,nQuant)
Local aAreaAnt := GetArea()
Local aAreaSB1 := SB1->(GetArea())
Local aAreaSB5 := SB5->(GetArea())
Local aRet     := {{0,''},{0,''},{0,''}}
Local cDesUni  := ''
Local nQtdNorma:= 0
Local nQtdOri  := nQuant

SB1->(DbSetOrder(1))
SB5->(DbSetOrder(1))
If SB1->(MsSeek(xFilial('SB1')+cCodPro))
	nQtdNorma := DLQtdNorma(cCodPro,cArmazem,cEstFis,@cDesUni,.F.)
	//-- Calcula a quantidade por unitizador
	aRet[1,1]   := Int( nQuant / nQtdNorma )           //-- Qtde unitizadores
	nQtdOri     -= aRet[1,1] * nQtdNorma
	If !Empty(SB1->B1_SEGUM)
		aRet[2,1]   := Int(ConvUm(cCodPro,nQtdOri,0,2)) //-- Qtde 2a unidade de medida
		nQtdOri     -= ConvUm(cCodPro,0,aRet[2,1],1)
	EndIf
	aRet[3,1]   := nQtdOri                             //-- Qtde 1a unidade de medida

	aRet[1,2] := cDesUni
	aRet[2,2] := SB1->B1_SEGUM
	aRet[3,2] := SB1->B1_UM
EndIf
RestArea(aAreaSB1)
RestArea(aAreaSB5)
RestArea(aAreaAnt)
Return aRet
/*
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Função      WmsDocOri | Autor   Alex Egydio               Data 27.12.2004 --
-------------------------------------------------------------------------------
-- Descrição   Estorna todos os documentos com referencia a carga ou         --
--             documento original.                                           --
-------------------------------------------------------------------------------
-- Parametros  ExpC1 - Acao executada pela funcao                            --
--                     1 = Verifica se habilita o estorno                    --
--                     2 = Estorna todos os documentos com referencia a      --
--                         carga ou documento original.                      --
--                     3 = Limpa de todos os documentos a referencia         --
--                         a carga original.                                 --
--                     4 = Limpa de todos os documentos a referencia         --
--                         ao documento original.                            --
--             ExpC2 - Documento original                                    --
--             ExpC3 - Serie do documento original                           --
--             ExpC4 - Carga                                                 --
--             ExpL1 - .T. indica que existe o ponto de entrada DLGA150D     --
-------------------------------------------------------------------------------
-- Retorno                                                                   --
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------*/
Function WmsDocOri(cAcao,cDocto,cSerie,cCarga,lDLGA150D,nStServ)
Local aAreaAtu := GetArea()
Local cVazio1  := ''
Local cVazio2  := ''
Local lRet     := .F.
Local lDocOri  := SIX->(MsSeek('DCF7')) .And. AllTrim(SIX->CHAVE)=='DCF_FILIAL+DCF_DOCORI+DCF_SERORI'
Local cQuery   := ''

If cAcao == '1' .Or. !lDocOri
	Return(lDocOri)
Else
	//-- Estorna todos os documentos com referencia a carga ou documento original
	If cAcao == '2'
		lRet := WmsEstOri(cCarga,cDocto,cSerie)
	//-- Limpa dos documentos a referencia a carga ou documento original
	ElseIf cAcao == '3' .Or. cAcao == '4'
		cVazio1 := Space(Len(DCF->DCF_DOCORI))
		cVazio2 := Space(Len(DCF->DCF_SERORI))
		cQuery := "UPDATE "+RetSqlName("DCF")+" "
		cQuery += "SET DCF_DOCORI = '" + cVazio1 + "',"
		cQuery += "    DCF_SERORI = '" + cVazio2 + "'"
		cQuery += "WHERE DCF_FILIAL='"+xFilial('DCF')+"' AND "
		If cAcao == '3'
			cQuery += "DCF_DOCORI ='"+cCarga+"'"
		ElseIf cAcao == '4'
			cQuery += "DCF_DOCORI ='"+cDocto+"' AND "
			cQuery += "DCF_SERORI ='"+cSerie+"'"
		EndIf
		TcSqlExec(cQuery)
	EndIf
EndIf

RestArea(aAreaAtu)
Return(lRet)
/*
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Função      WmsChkSDB | Autor   Alex Egydio               Data 09.04.2007 --
-------------------------------------------------------------------------------
-- Descrição   Analisa movimentos de distribuicao                            --
-------------------------------------------------------------------------------
-- Parametros  ExpC1 - Acao executada pela funcao                            --
--                     1 = Verifica se existe movimento de radio frequencia  --
--                         em andamento. Observacao: Eh necessario que o     --
--                         registro do SC9 estaja posicionado.               --
--                                                                           --
--                     2 = Verifica se houve uma movimentacao do carrinho    --
--                         p/a doca, p/que a O.S.WMS nao sera estornada e    --
--                         sim re-enderecada. Observacao: Eh necessario que  --
--                         o registro do DCF estaja posicionado.             --
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------*/
Function WmsChkSDB(cAcao,aRegSDB,bBlock,cStatSDB)
Local aAreaAnt  := GetArea()
Local cStatExec := SuperGetMV('MV_RFSTEXE', .F., '1') //-- DB_STATUS indicando Atividade Executada
Local cStatProb := SuperGetMV('MV_RFSTPRO', .F., '2') //-- DB_STATUS indicando Atividade com Problemas
Local cStatInte := SuperGetMV('MV_RFSTINT', .F., '3') //-- DB_STATUS indicando Atividade Interrompida
Local cStatAExe := SuperGetMV('MV_RFSTAEX', .F., '4') //-- DB_STATUS indicando Atividade A Executar
Local cAliasNew := ''
Local cQuery    := ''
Local lRet      := .F.

Default cAcao    := '1'
Default bBlock   := {||.T.}

If cAcao =='1'
	//-- Utilizado para verificar se alguma das atividades do documento está em andamento ou executada
	Default cStatSDB := "('"+cStatInte+"','"+cStatExec+"','M')"
	cAliasNew := GetNextAlias()
	cQuery := " SELECT SDB.R_E_C_N_O_ RECNOSDB"
	cQuery += " FROM " + RetSqlName('SDB')+" SDB"
	cQuery += " WHERE SDB.DB_FILIAL = '"+xFilial("SDB")+"'"
	If WmsCarga(DCF->DCF_CARGA)
		cQuery += " AND SDB.DB_CARGA  = '"+DCF->DCF_CARGA+"'"
	Else
		cQuery += " AND SDB.DB_DOC    = '"+DCF->DCF_DOCTO+"'"
		cQuery += " AND SDB.DB_SERIE  = '"+DCF->DCF_SERIE+"'"
		cQuery += " AND SDB.DB_CLIFOR = '"+DCF->DCF_CLIFOR+"'"
		cQuery += " AND SDB.DB_LOJA   = '"+DCF->DCF_LOJA+"'"
	EndIf
	cQuery += " AND SDB.DB_SERVIC  = '"+DCF->DCF_SERVIC+"'"
	cQuery += " AND SDB.DB_LOCAL   = '"+DCF->DCF_LOCAL+"'"
	cQuery += " AND SDB.DB_PRODUTO = '"+DCF->DCF_CODPRO+"'"
	cQuery += " AND SDB.DB_IDDCF   = '"+DCF->DCF_ID+"'"
	cQuery += " AND SDB.DB_ATUEST  = 'N'"
	cQuery += " AND SDB.DB_ESTORNO = ' '"
	cQuery += " AND SDB.DB_STATUS IN "+cStatSDB
	cQuery += " AND SDB.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasNew,.F.,.T.)
	If (cAliasNew)->(!Eof())
		lRet := .T.
	EndIf
	(cAliasNew)->(DbCloseArea())
ElseIf cAcao == '2'
	//-- Não utiliza mais
ElseIf cAcao == '3'
	//-- Utilizado na classif. da pre-nota
	Default cStatSDB := "('"+cStatProb+"','"+cStatInte+"','"+cStatAExe+"')"
	cAliasNew := GetNextAlias()
	cQuery := " SELECT DB_FILIAL,DB_SERVIC,DB_TAREFA,DB_ATIVID,DB_DOC,DB_SERIE,DB_PRODUTO,DB_LOCALIZ,DB_RHFUNC,DB_RECFIS,DB_ATUEST,DB_STATUS,DB_DATA,DB_NUMSEQ,DB_IDDCF,SDB.R_E_C_N_O_ RECNOSDB"
	cQuery += " FROM " + RetSqlName('SDB')+" SDB"
	cQuery += " WHERE DB_FILIAL = '"+xFilial("SDB")+"'"
	cQuery += " AND DB_DOC      = '"+DCF->DCF_DOCTO+"'"
	cQuery += " AND DB_SERIE    = '"+DCF->DCF_SERIE+"'"
	cQuery += " AND DB_SERVIC   = '"+DCF->DCF_SERVIC+"'"
	cQuery += " AND DB_PRODUTO  = '"+DCF->DCF_CODPRO+"'"
	cQuery += " AND DB_CLIFOR   = '"+DCF->DCF_CLIFOR+"'"
	cQuery += " AND DB_LOJA     = '"+DCF->DCF_LOJA+"'"
	cQuery += " AND DB_ATUEST   = 'N'"
	cQuery += " AND DB_ESTORNO  = ' '"
	cQuery += " AND DB_STATUS   IN "+cStatSDB
	cQuery += " AND SDB.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY DB_FILIAL, DB_SERVIC, DB_DOC, DB_SERIE, DB_PRODUTO"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasNew,.F.,.T.)
	If ValType(aRegSDB)=='A'
		//-- Houve movimentacao do carrinho para a doca, entao a O.S.WMS nao sera estornada e sim re-enderecada.
		While (cAliasNew)->(!Eof())
			If Eval((cAliasNew)->(bBlock))
				AAdd(aRegSDB,(cAliasNew)->RECNOSDB)
				lRet := .T.
			EndIf
			(cAliasNew)->(DbSkip())
		EndDo
	Else
		If (cAliasNew)->(!Eof())
			//-- Houve movimentacao do carrinho para a doca, entao a O.S.WMS nao sera estornada e sim re-enderecada.
			lRet := .T.
		EndIf
	EndIf
	(cAliasNew)->(DbCloseArea())
ElseIf cAcao == '4'
	//-- Utilizado para verificar se alguma das atividades do documento já foi executada
	Default cStatSDB := "('"+cStatProb+"','"+cStatAExe+"')"
	cAliasNew := GetNextAlias()
	cQuery := " SELECT SDB.R_E_C_N_O_ RECNOSDB"
	cQuery += " FROM "+RetSqlName('SDB')+" SDB"
	cQuery += " WHERE SDB.DB_FILIAL = '"+xFilial("SDB")+"'"
	If WmsCarga(DCF->DCF_CARGA)
		cQuery += " AND SDB.DB_CARGA  = '"+DCF->DCF_CARGA+"'"
	Else
		cQuery += " AND SDB.DB_DOC    = '"+DCF->DCF_DOCTO+"'"
		cQuery += " AND SDB.DB_SERIE  = '"+DCF->DCF_SERIE+"'"
		cQuery += " AND SDB.DB_CLIFOR = '"+DCF->DCF_CLIFOR+"'"
		cQuery += " AND SDB.DB_LOJA   = '"+DCF->DCF_LOJA+"'"
	EndIf
	cQuery += " AND SDB.DB_SERVIC  = '"+DCF->DCF_SERVIC+"'"
	cQuery += " AND SDB.DB_LOCAL   = '"+DCF->DCF_LOCAL+"'"
	cQuery += " AND SDB.DB_PRODUTO = '"+DCF->DCF_CODPRO+"'"
	cQuery += " AND SDB.DB_IDDCF   = '"+DCF->DCF_ID+"'"
	cQuery += " AND SDB.DB_ATUEST  = 'N'"
	cQuery += " AND SDB.DB_ESTORNO = ' '"
	cQuery += " AND SDB.DB_STATUS NOT IN "+cStatSDB
	cQuery += " AND SDB.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasNew,.F.,.T.)
	If (cAliasNew)->(!Eof())
		lRet := .T.
	EndIf
	(cAliasNew)->(DbCloseArea())
EndIf

RestArea(aAreaAnt)
Return lRet

/*
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Função     WmsSaldoSBF| Autor   Alex Egydio               Data 02.08.2005 --
-------------------------------------------------------------------------------
-- Descrição   Obtem o saldo do endereco considerando o saldo dos servicos   --
--             ja executados que estao aguardando convocao pela RF           --
-------------------------------------------------------------------------------
-- Parametros  ExpC1 - Armazem                                               --
--             ExpC2 - Endereco                                              --
--             ExpC3 - Produto                                               --
--             ExpC4 - Numero de serie                                       --
--             ExpC5 - Lote                                                  --
--             ExpC6 - Sub-Lote                                              --
--             ExpL1 = .T. = Considera os servicos em Cache (executados      --
--                     nesta mesma secao) (*)                                --
--             ExpL2 = .T. = Considera servicos ja executados aguardando     --
--                     convocacao (*)                                        --
--             ExpL3 = .T. = Soma saldo aguardando convocacao (*)            --
--             ExpL4 = .T. = Subtrai saldo aguardando convocacao (*)         --
--             ExpL5 = .T. = Considerar saldo do lote/sub-lote sem           --
--                           considerar o parametro MV_WMSTPEN. Passado pela --
--                           funcao SldPorLote()                             --
--             ExpL6 = .T. = Considerar saldo reservado pela radio frequencia --
--                                                                           --
--             (*) Parametros utilizados pela funcao  ConSldRF               --
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------*/
Function WmsSaldoSBF(cArmazem,cEndereco,cProduto,cNumSerie,cLoteCtl,cNumLote,lCache,lAConvo,lEntra,lSaida,cAcao,lConSldRF,cNumSeq,cDocto,cSerie,cCliFor,cLoja)
Local aAreaAnt := GetArea()
Local aAreaSB8 := SB8->(GetArea())
Local cQuery   := ''
Local cAliasSBF:= ''
Local nRet     := 0
Local aTamSX3  := {}

Default cProduto  := Space(TamSX3("BF_PRODUTO")[1])
Default cLoteCtl  := Space(TamSX3("BF_LOTECTL")[1])
Default cNumLote  := Space(TamSX3("BF_NUMLOTE")[1])
Default cNumSerie := Space(TamSX3("BF_NUMSERI")[1])
Default lCache    := .T.
Default lAConvo   := .T.
Default lEntra    := .T.
Default lSaida    := .T.
Default cAcao     := '1'
Default lConSldRF := .T.
Default cNumSeq   := ''
Default cDocto    := ''
Default cSerie    := ''
Default cCliFor   := ''
Default cLoja     := ''

If cAcao == '1' .Or. cAcao == '2'

	cQuery := "SELECT BF_QUANT, BF_EMPENHO, BF_QEMPPRE, BF_QTSEGUM, BF_EMPEN2, BF_QEPRE2"
	cQuery +=  " FROM "+RetSqlName('SBF')+" SBF"
	cQuery += " WHERE BF_FILIAL  = '"+xFilial('SBF')+"'"
	cQuery +=   " AND BF_LOCAL   = '"+cArmazem+"'"
	cQuery +=   " AND BF_LOCALIZ = '"+cEndereco+"'"
	If !Empty(cProduto)
		cQuery += " AND BF_PRODUTO = '"+cProduto+"'"
	EndIf
	If !Empty(cLoteCtl)
		cQuery += " AND BF_LOTECTL = '"+cLoteCtl+"'"
	EndIf
	If !Empty(cNumLote)
		cQuery += " AND BF_NUMLOTE = '"+cNumLote+"'"
	EndIf
	If !Empty(cNumSerie)
		cQuery += " AND BF_NUMSERI = '"+cNumSerie+"'"
	EndIf
	cQuery += " AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasSBF := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSBF,.F.,.T.)
	//-- Ajustando o tamanho dos campos da query
	aTamSX3:=TamSx3('BF_QUANT');   TcSetField(cAliasSBF,'BF_QUANT',  'N',aTamSX3[1],aTamSX3[2])
	aTamSX3:=TamSx3('BF_EMPENHO'); TcSetField(cAliasSBF,'BF_EMPENHO','N',aTamSX3[1],aTamSX3[2])
	aTamSX3:=TamSx3('BF_QEMPPRE'); TcSetField(cAliasSBF,'BF_QEMPPRE','N',aTamSX3[1],aTamSX3[2])
	aTamSX3:=TamSx3('BF_QTSEGUM'); TcSetField(cAliasSBF,'BF_QTSEGUM','N',aTamSX3[1],aTamSX3[2])
	aTamSX3:=TamSx3('BF_EMPEN2');  TcSetField(cAliasSBF,'BF_EMPEN2', 'N',aTamSX3[1],aTamSX3[2])
	aTamSX3:=TamSx3('BF_QEPRE2');  TcSetField(cAliasSBF,'BF_QEPRE2', 'N',aTamSX3[1],aTamSX3[2])
	//-- Consulta todos os registros
	While (cAliasSBF)->(!Eof())
		nRet += SBFSaldo(.F.,cAliasSBF)
		(cAliasSBF)->(DbSkip())
	EndDo
	(cAliasSBF)->(DbCloseArea())
	RestArea(aAreaAnt)
	If lConSldRF
		ConSldRF(cArmazem,cEndereco,cProduto,cLoteCtl,cNumLote, @nRet, Nil, Nil,lCache,lAConvo,lEntra,lSaida)
	EndIf
ElseIf cAcao == '3'

	ConSldRF(cArmazem,cEndereco,cProduto,cLoteCtl,cNumLote,@nRet,Nil,Nil,lCache,lAConvo,lEntra,lSaida,cNumSeq,cDocto,cSerie,cCliFor,cLoja)

EndIf
RestArea(aAreaSB8)
RestArea(aAreaAnt)
Return(nRet)
/*
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Função     WmsSeqAbast| Autor   Alex Egydio               Data 29.09.2005 --
-------------------------------------------------------------------------------
-- Descrição   Sequencia de abastecimento do produto                         --
-------------------------------------------------------------------------------
-- Parametros  ExpC1 - Armazem                                               --
--             ExpC2 - Produto                                               --
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------*/
Function WmsSeqAbast(cArmazem,cProduto,nProcesso)
Local aAreaDC3  := GetArea()
Local cAliasDC3 := GetNextAlias()
Local cQuery    := ""
Local cPriEnder := '1'
Local aRet      := {}

Default nProcesso := 1

	//Tipo Estruturas
	//1=Pulmao
	//2=Picking
	//3=Cross Docking
	//4=Blocado
	//5=Box/Doca
	//6=Blocado Fracionado

	cPriEnder := Posicione('DC3',1,xFilial('DC3')+cProduto+cArmazem,'DC3_PRIEND')

	cQuery := "SELECT CASE DC8.DC8_TPESTR"
	Do Case
		Case nProcesso == 1 //Endereçamento
			If cPriEnder == "2" //Prioridade de endereçamento 1-Picking/2-Pulmão
				cQuery += " WHEN '1' THEN 1"
				cQuery += " WHEN '2' THEN 2"
			Else
				cQuery += " WHEN '2' THEN 1"
				cQuery += " WHEN '1' THEN 2"
			EndIf
			cQuery += " WHEN '6' THEN 3"
			cQuery += " WHEN '4' THEN 4"
			cQuery += " WHEN '3' THEN 5 END REGRA,"
		Case nProcesso == 2 //Separação com ou sem volume
			cQuery += " WHEN '4' THEN 1"
			cQuery += " WHEN '6' THEN 2"
			cQuery += " WHEN '1' THEN 3"
			cQuery += " WHEN '2' THEN 4"
			cQuery += " WHEN '3' THEN 5 END REGRA,"
		Case nProcesso == 3 //Separaçao cross docking com e sem volume
			cQuery += " WHEN '3' THEN 1"
			cQuery += " WHEN '6' THEN 2"
			cQuery += " WHEN '4' THEN 3"
			cQuery += " WHEN '1' THEN 4"
			cQuery += " WHEN '2' THEN 5 END REGRA,"
		Case nProcesso == 4 //Abastecimento
			cQuery += " WHEN '1' THEN 1 END REGRA,"
		Case nProcesso == 6
			cQuery += " WHEN '2' THEN 1 END REGRA," // Separação (regra 4, geração de reabastecimento por demanda)
	EndCase
	cQuery += " DC3.DC3_ORDEM,DC3.DC3_TPESTR, DC8.DC8_TPESTR"
	cQuery += " FROM "+RetSqlName('DC3')+" DC3"
	cQuery += " INNER JOIN "+RetSqlName('DC8')+" DC8"
	cQuery += " ON DC8.DC8_FILIAL = '"+xFilial("DC8")+"'"
	cQuery += " AND DC8.DC8_CODEST = DC3_TPESTR"
	cQuery += " AND DC8.D_E_L_E_T_ = ' '"
	cQuery += " WHERE DC3.DC3_FILIAL = '"+xFilial("DC3")+"'"
	cQuery += " AND DC3.DC3_CODPRO = '"+cProduto+"'"
	cQuery += " AND DC3.DC3_LOCAL  = '"+cArmazem+"'"
	cQuery += " AND DC3.DC3_EMBDES = '1'" //-- Considera somente Sequencias de Abastecimento (nao utiliza Sequencias de Embarque/Desembarque)
	cQuery += " AND DC3.D_E_L_E_T_ = ' '"
	If nProcesso == 4 //Abastecimento
		cQuery += " AND DC8.DC8_TPESTR = '1'" //-- Somente estrutura pulmao
	ElseIf nProcesso == 6
		cQuery += " AND DC8.DC8_TPESTR = '2'" //-- Somente estrutura picking
	EndIf
	If nProcesso == 2 .Or. nProcesso == 3
		cQuery += " ORDER BY REGRA, DC3_QTDUNI DESC, DC3_ORDEM"
	Else
		cQuery += " ORDER BY REGRA, DC3_ORDEM"
	EndIf
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasDC3,.F.,.T.)

	While (cAliasDC3)->(!Eof())
		AAdd(aRet,(cAliasDC3)->DC3_ORDEM)
		(cAliasDC3)->(DbSkip())
	EndDo
	(cAliasDC3)->(DbCloseArea())

RestArea(aAreaDC3)
Return (aRet)

/*
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Função     WmsTrace   | Autor   sandro                    Data 26.11.2005 --
-------------------------------------------------------------------------------
-- Descrição   gera arquivo de log con informacoes para trace                --
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
*/


Function WmsTrace(cConteudo,cConteudo2)
Local nHandle2
Local cArquivo := "WMS"+__CUSERID+".log"
Local nDif
DEFAULT cConteudo :=""
Static nSeconds := 0

If File('WMSNOLOG.TXT')
	Return
EndIf

If ! File(cArquivo)
	If (nHandle2 := MSFCreate(cArquivo,0)) == -1
		Return
	EndIf
Else
	If (nHandle2 := FOpen(cArquivo,2)) == -1
		Return
	EndIf
EndIf
FSeek(nHandle2,0,2)
If nSeconds==0
	nDif:=0
Else
	nDif := Seconds()-nSeconds
EndIf
FWrite(nHandle2,Alltrim(FunName())+":"+Alltrim(ProcName(1))+"("+Alltrim(Str(ProcLine(1),5))+ ")"+STR0028+Time()+STR0029+Str(nDif,8,2)+If(! Empty(cConteudo),STR0030+cConteudo,"")+chr(13)+chr(10)) //" Atual:"##" Diferenca:"##" Obs: "
//CONOUT(nHandle2,Alltrim(FunName())+":"+Alltrim(ProcName(1))+"("+Alltrim(Str(ProcLine(1),5))+ ")"+" Atual:"+Time()+" Diferenca:"+Str(nDif,8,2)+If(! Empty(cConteudo)," Obs: "+cConteudo,"")+chr(13)+chr(10))
If cConteudo2<>NIL
	FWrite(nHandle2,VarInfo(cConteudo,cConteudo2,,.F.))
EndIf
nSeconds:= Seconds()
FClose(nHandle2)
Return
/*
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Função     WmsRegra| Autor   Alex Egydio                  Data 10.05.2006 --
-------------------------------------------------------------------------------
-- Descrição   Verifica se ha regra de convocacao para o recurso humano      --
-------------------------------------------------------------------------------
-- Parametros  ExpC1 - 1 = Verifica se ha regra de convocacao p/o recurso    --
--                         humano.                                           --
--                         Chamado pelo programa DLGV001                     --
--                                                                           --
--                     2 = Analisa a regra de convocacao de limitacao.       --
--                         Chamado pelo programa DLGV001                     --
--                                                                           --
--                     3 = Analisa a regra de convocacao para saber se deve  --
--                         liberar a RUA.                                    --
--                         Chamado pelo programa DLGV001                     --
--                                                                           --
--                     4 = Analisa a regra de convocacao para liberar a RUA  --
--                         Chamado pelo programa DLGV001                     --
--                                                                           --
--                     5 = Analisa a regra de convocacao de sequenciamento.  --
--                         Chamado pela funcao WmsExeDCF                     --
--                                                                           --
--                     6 = Libera a RUA se estiver travado pelo recurso      --
--                         humano, ao reiniciar a tarefa/atividade.          --
--                         Chamado pelo programa WMSA330                     --
--                                                                           --
--                     7 = Gerar sequencia quando encontrar Regra.           --
--                         Verifica se existe os indices do arquivo          --
--                         de regras.                                        --
--                                                                           --
--                     8 = Refaz regra de sequencia.                         --
--                                                                           --
--                     9 = Refaz regra de documento exclusivo para           --
--                         alocaç-o das atividades para recurso humano       --
--                         se ja possuir atividades alocadas para o mesmo.   --
--                                                                           --
--             ExpC2 - Armazem                                               --
--             ExpC3 - Recurso humano                                        --
--             ExpC3 - Servico                                               --
--             ExpC4 - Tarefa                                                --
--             ExpC5 - Atividade                                             --
--             ExpC6 - Endereco de origem                                    --
--             ExpC7 - Estrutura do endereco de origem                       --
--             ExpC8 - Endereco de destino                                   --
--             ExpC9 - Estrutura do endereco de destino                      --
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------*/
Function WmsRegra(cAcao,cArmazem,cRecHum,cServico,cTarefa,cAtivid,cEndOri,cEstrOri,cEndDes,cEstrDes,aRetRegra,cFuncao,cCarga,lRetAtiv,lDocExc,cPriori)

Static lPEWmsReg:= ExistBlock("WMSREGRA")

Local aAreaAnt := GetArea()
Local aAreaSBE := {}
Local aAreaDC7 := {}
Local aAreaDCQ := {}
Local aAreaSDB := {}
Local aRegra   := {}
Local aRetRgExc := {}
Local aSrv1    := {}
Local aSrv2    := {}
Local aSrv3    := {}
Local aSrv4    := {}
Local aSequencia:= {}
Local cSequencia:= '00'
Local cAliasRgr   := 'SDB'
Local cCodCfg  := ''
Local cCodZon  := ''
Local cEndAux  := ''
Local cFunExe  := ''
Local cTipoSrv := ''
Local cQuery   := ''
Local cGrvPri  := ''
Local cSeekDCQ := ''
Local cChave   := ''
Local cTrava   := ''
Local lDoca    := .F.
Local lDocaOri := .F.
Local lDocaDes := .F.
Local lRet     := .F.
Local n1Cnt    := 0
Local n2Cnt    := 0
Local nSeek    := 0
Local cStatExec := SuperGetMV('MV_RFSTEXE', .F., '1') //-- DB_STATUS indincando Atividade Executada
Local cStatProb := SuperGetMV('MV_RFSTPRO', .F., '2') //-- DB_STATUS indicando Atividade com Problemas
Local cStatInte := SuperGetMV('MV_RFSTINT', .F., '3') //-- DB_STATUS indicando Atividade Interrompida
Local cStatAExe := SuperGetMV('MV_RFSTAEX', .F., '4') //-- DB_STATUS indicando Atividade A Executar
Local cPrior     := SuperGetMV('MV_WMSPRIO', .F., '' ) //-- Prioridade de convocacao no WMS.
Local cSeqPri   := ''
Local cKeyDoc   := ''
Local cRecVazio := Space(Len(SDB->DB_RECHUM))
Local nPos      := 0

DEFAULT aRetRegra := {}
DEFAULT lDocExc   := .T.
Default cPriori := StrZero(0,2)

If cAcao=='1'
	//-- Verifica se existe o arquivo de regra
	If SIX->(MsSeek('DCQ1')) .And. AllTrim(SIX->CHAVE)=='DCQ_FILIAL+DCQ_TPREGR+DCQ_STATUS+DCQ_LOCAL+DCQ_CODFUN+DCQ_CODZON+DCQ_SERVIC+DCQ_TAREFA+DCQ_ATIVID'
		//-- Analise combinatoria para busca da regra de convocacao
		//--              Zona + Servico + Tarefa + Atividade
		//-- Regra 01     ----              Zona do endereco em branco          + Servico em branco  + Tarefa em branco   + Atividade em branco
		//-- Regra 02     -X--              Zona do endereco em branco          + Servico         + Tarefa em branco   + Atividade em branco
		//-- Regra 03     -XX-              Zona do endereco em branco          + Servico         + Tarefa       + Atividade em branco
		//-- Regra 04     -XXX              Zona do endereco em branco          + Servico         + Tarefa       + Atividade

		//-- Regra 05     X---              Zona do endereco origem             + Servico em branco  + Tarefa em branco   + Atividade em branco
		//-- Regra 06     XX--              Zona do endereco origem             + Servico            + Tarefa em branco   + Atividade em branco
		//-- Regra 07     XXX-              Zona do endereco origem             + Servico            + Tarefa             + Atividade em branco
		//-- Regra 08     XXXX              Zona do endereco origem             + Servico            + Tarefa             + Atividade

		//-- Regra 09     X---              Zona do endereco destino            + Servico em branco  + Tarefa em branco   + Atividade em branco
		//-- Regra 10     XX--              Zona do endereco destino            + Servico            + Tarefa em branco   + Atividade em branco
		//-- Regra 11     XXX-              Zona do endereco destino            + Servico            + Tarefa             + Atividade em branco
		//-- Regra 12     XXXX              Zona do endereco destino            + Servico            + Tarefa             + Atividade

		//-- Analise combinatoria para busca da regra de convocacao por documento exclusivo apenas
		//-- Regra 13     -XXX              Zona do endereco em branco          + Servico            + Tarefa             + Atividade
		//-- Regra 14     -XX-              Zona do endereco em branco          + Servico            + Tarefa             + Atividade em branco
		//-- Regra 15     -X--              Zona do endereco em branco          + Servico            + Tarefa em branco   + Atividade em branco
		//-- Regra 16     ----              Zona do endereco em branco          + Servico em branco  + Tarefa em branco   + Atividade em branco
		//-- DCQ_FILIAL+DCQ_TPREGR+DCQ_STATUS+DCQ_LOCAL+DCQ_CODFUN+DCQ_CODZON+DCQ_SERVIC+DCQ_TAREFA+DCQ_ATIVID
		DCQ->(DbSetOrder(1))
		cCodZon := Space(Len(DCQ->DCQ_CODZON))
		//-- Nao precisa avaliar a zona do endereco origem / destino, pois esta procurando zonas em branco
		//-- Regra 01
		AAdd(aRegra,cCodZon+Space(Len(DCQ->DCQ_SERVIC))+Space(Len(DCQ->DCQ_TAREFA))+Space(Len(DCQ->DCQ_ATIVID)))
		//-- Regra 02
		AAdd(aRegra,cCodZon+cServico+Space(Len(DCQ->DCQ_TAREFA))+Space(Len(DCQ->DCQ_ATIVID)))
		//-- Regra 03
		AAdd(aRegra,cCodZon+cServico+cTarefa+Space(Len(DCQ->DCQ_ATIVID)))
		//-- Regra 04
		AAdd(aRegra,cCodZon+cServico+cTarefa+cAtivid)

		For n1Cnt := 1 To Len(aRegra)
			If DCQ->(MsSeek(xFilial('DCQ')+'1'+'1'+cArmazem+cRecHum+aRegra[n1Cnt] ))
				//-- O recurso humano sera convocado
				lRet := .T.
				Exit
			EndIf
		Next

		If !lRet
			aRegra   := {}
		EndIf

		aAreaSBE := SBE->(GetArea())
		cCodZon  := ""
		lDocaOri := DLTipoEnd(cEstrOri) == 5
		lDocaDes := DLTipoEnd(cEstrDes) == 5
		SBE->(DbSetOrder(1))
		//-- Zona do endereco origem
		If SBE->(MsSeek(xFilial('SBE')+cArmazem+cEndOri+cEstrOri))
			If !lDocaOri .Or. (lDocaOri .And. lDocaDes)
				If !lRet
					cCodZon := SBE->BE_CODZON
					//-- Regra 05
					AAdd(aRegra,cCodZon+Space(Len(DCQ->DCQ_SERVIC))+Space(Len(DCQ->DCQ_TAREFA))+Space(Len(DCQ->DCQ_ATIVID)))
					//-- Regra 06
					AAdd(aRegra,cCodZon+cServico+Space(Len(DCQ->DCQ_TAREFA))+Space(Len(DCQ->DCQ_ATIVID)))
					//-- Regra 07
					AAdd(aRegra,cCodZon+cServico+cTarefa+Space(Len(DCQ->DCQ_ATIVID)))
					//-- Regra 08
					AAdd(aRegra,cCodZon+cServico+cTarefa+cAtivid)
				EndIf
				cCodCfg := SBE->BE_CODCFG
				cEndAux := cEndOri
			EndIf
		EndIf
		//-- Zona do endereco destino
		If SBE->(MsSeek(xFilial('SBE')+cArmazem+cEndDes+cEstrDes))
			If !lDocaDes .Or. (lDocaOri .And. lDocaDes)
				If !lRet .And. SBE->BE_CODZON != cCodZon
					cCodZon := SBE->BE_CODZON
					//-- Regra 09
					AAdd(aRegra,cCodZon+Space(Len(DCQ->DCQ_SERVIC))+Space(Len(DCQ->DCQ_TAREFA))+Space(Len(DCQ->DCQ_ATIVID)))
					//-- Regra 10
					AAdd(aRegra,cCodZon+cServico+Space(Len(DCQ->DCQ_TAREFA))+Space(Len(DCQ->DCQ_ATIVID)))
					//-- Regra 11
					AAdd(aRegra,cCodZon+cServico+cTarefa+Space(Len(DCQ->DCQ_ATIVID)))
					//-- Regra 12
					AAdd(aRegra,cCodZon+cServico+cTarefa+cAtivid)
				EndIf
				cCodCfg := SBE->BE_CODCFG
				cEndAux := cEndDes
			EndIf
		EndIf
		RestArea(aAreaSBE)

		//-- Verifica se ha regra definida para zona do endereco origem e destino
		If !lRet
			For n1Cnt := 1 To Len(aRegra)
				If DCQ->(MsSeek(xFilial('DCQ')+'1'+'1'+cArmazem+cRecHum+aRegra[n1Cnt] ))
					lRet := .T.
					Exit
				EndIf
			Next
		EndIf

		//-- Verifica se ha regra definida para o Servico/Tarefa/Atividade. Exemplo: Limitou a execucao da atividade RF para um operador (DCQ_DOCEXC).
		If !lRet
			cCodZon := Space(Len(DCQ->DCQ_CODZON))
			//-- Regra 01
			AAdd(aRegra,cServico+cTarefa+cAtivid)
			//-- Regra 02
			AAdd(aRegra,cServico+cTarefa+Space(Len(DCQ->DCQ_ATIVID)))
			//-- Regra 03
			AAdd(aRegra,cServico+Space(Len(DCQ->DCQ_TAREFA))+Space(Len(DCQ->DCQ_ATIVID)))
			//-- Regra 04
			AAdd(aRegra,Space(Len(DCQ->DCQ_SERVIC))+Space(Len(DCQ->DCQ_TAREFA))+Space(Len(DCQ->DCQ_ATIVID)))
			For n1Cnt := 1 To Len(aRegra)
				If DCQ->(MsSeek(xFilial('DCQ')+'1'+'1'+cArmazem+cRecVazio+cCodZon+aRegra[n1Cnt]) .And. DCQ_DOCEXC<>"2")
					lRet := .T.
					Exit
				EndIf
			Next
			If !lRet
				aRegra := {}
			EndIf
		EndIf

		If lRet
			//-- Retorno da regra, para acao no dlgv001
			AAdd(aRetRegra,cArmazem)         //-- 01 Armazem
			AAdd(aRetRegra,cRecHum)          //-- 02 Recurso Humano
			AAdd(aRetRegra,DCQ->DCQ_CODZON)     //-- 03 Zona de Armazenagem indicada como limitacao
			AAdd(aRetRegra,DCQ->DCQ_SERVIC)     //-- 04 Servico
			AAdd(aRetRegra,DCQ->DCQ_TAREFA)     //-- 05 Tarefa
			AAdd(aRetRegra,DCQ->DCQ_ATIVID)     //-- 06 Atividade
			AAdd(aRetRegra,DCQ->DCQ_ENDINI)     //-- 07 Endereco Inicial
			AAdd(aRetRegra,DCQ->DCQ_ENDFIM)     //-- 08 Endereco Final
			AAdd(aRetRegra,DCQ->DCQ_RESEND)     //-- 09 Reserva o Endereco
			AAdd(aRetRegra,DCQ->DCQ_LIBEND)     //-- 10 Como o endereco sera liberado se DCQ_RESEND igual a 1
			AAdd(aRetRegra,DCQ->DCQ_LOCALI)     //-- 11 Endereco Reservado
			AAdd(aRetRegra,cCodCfg)          //-- 12 Configuracao do codigo do endereco
			AAdd(aRetRegra,cEndAux)          //-- 13 Endereco
			AAdd(aRetRegra,DCQ->DCQ_CARGA)      //-- 14 Cargas que usam a regra
			AAdd(aRetRegra,DCQ->(Recno()))      //-- 15 Nr.do registro da regra encontrada
			AAdd(aRetRegra,cCodZon)          //-- 16 Zona de Armazenagem do endereco ( endereco no SDB ). Observacao: Se esta zona for diferente de DCQ_CODZON o recurso humano ficara limitado a trabalhar na zona indicada em DCQ_CODZON
			AAdd(aRetRegra,DCQ->DCQ_DOCEXC) //-- 17 Execucao das atividades RF ficara limitado a um unico operador.
		EndIf
	EndIf
ElseIf cAcao=='2'
	//-- Analisa regra de convocacao de limitacao
	lRet := .T.
	//-- Verifica se limitou a regra a alguma Carga
	If !Empty(aRetRegra[14])
		lRet := (cCarga$aRetRegra[14])
	EndIf

	//-- Verifica se houve limitacao de endereco para convocacao (Preenchimento dos campos DCQ_ENDINI e DCQ_ENDFIM)
	If lRet .And. !Empty(aRetRegra[8]) .And. !Empty(aRetRegra[12])
		cEndAux := aRetRegra[13]
		lRet := (cEndAux >= aRetRegra[7] .And. cEndAux <= aRetRegra[8])
	EndIf

	//-- Verifica esta limitado a alguma zona de armazenagem
	If lRet .And. !Empty(aRetRegra[3])
		lRet := (aRetRegra[3]==aRetRegra[16])
	EndIf

	//-- Verifica se exec. atividade RF esta limitado a um unico operador
	If lRet .And. lDocExc
		//-- Inclui trava para uso exclusivo desta carga / documento
		If lRet := WMSTrava(1,@cTrava,SDB->DB_CARGA,SDB->DB_DOC,"")
			If aRetRegra[17]<>"2" //DCQ_DOCEXC = 2 - Nao
				aAreaSDB := SDB->(GetArea())
				cAliasRgr := GetNextAlias()
				cQuery := " SELECT SDB.R_E_C_N_O_ RECNOSDB"
				cQuery += " FROM " + RetSqlName('SDB')+" SDB"
				cQuery += " INNER JOIN "+RetSqlName('DCI')+" DCI "
				cQuery += " ON  DCI_FILIAL  = '"+xFilial("DCI")+"'"
				cQuery += " AND DCI_CODFUN  = '"+cRecHum+"'"
				cQuery += " AND DCI_FUNCAO  = DB_RHFUNC"
				cQuery += " AND DCI.D_E_L_E_T_ = ' '"
				cQuery += " WHERE DB_FILIAL = '"+xFilial("SDB")+"'"
				cQuery += " AND DB_LOCAL    = '"+aRetRegra[1]+"'"
				cQuery += " AND DB_STATUS IN ('-','"+ cStatAExe+"')"
				cQuery += " AND DB_ESTORNO  = ' '"
				cQuery += " AND DB_ATUEST   = 'N'"
				//-- Se existe alguma atividade sem rec.humano
				cQuery += " AND DB_RECHUM   = '"+cRecVazio+"'"
				If !Empty(aRetRegra[4])
					cQuery += " AND DB_SERVIC = '"+aRetRegra[4]+"'"
				EndIf
				If !Empty(aRetRegra[5])
					cQuery += " AND DB_TAREFA = '"+aRetRegra[5]+"'"
				EndIf
				If !Empty(aRetRegra[6])
					cQuery += " AND DB_ATIVID = '"+aRetRegra[6]+"'"
				EndIf
				If !Empty(cCarga) .And. aRetRegra[17]=="1" //DCQ_DOCEXC = 1 - Docto. ou Carga
					cQuery += " AND DB_CARGA    = '"+cCarga+"'"
				Else
					cQuery += " AND DB_DOC      = '"+SDB->DB_DOC+"'"
					cQuery += " AND DB_CLIFOR   = '"+SDB->DB_CLIFOR+"'"
					cQuery += " AND DB_LOJA     = '"+SDB->DB_LOJA+"'"
				EndIf
				cQuery += " AND SDB.D_E_L_E_T_  = ' '"
				cQuery := ChangeQuery(cQuery)
				DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasRgr,.F.,.T.)
				While (cAliasRgr)->(!Eof())
					SDB->(dbGoTo((cAliasRgr)->RECNOSDB))
					//-- Verifica se ha regras para convocacao para estas atividades.
					aRetRgExc := {}
					If WmsRegra('1',SDB->DB_LOCAL,cRecHum,SDB->DB_SERVIC,SDB->DB_TAREFA,SDB->DB_ATIVID,SDB->DB_LOCALIZ,SDB->DB_ESTFIS,SDB->DB_ENDDES,SDB->DB_ESTDES,aRetRgExc,,,,.F.)
						//-- Analisa se convocao ou nao
						If WmsRegra('2',,cRecHum,SDB->DB_SERVIC,SDB->DB_TAREFA,SDB->DB_ATIVID,,,,,aRetRgExc,,SDB->DB_CARGA,,.F.)
							//-- Grava unico recurso nas atividades pendentes
							RecLock('SDB',.F.)
							SDB->DB_RECHUM := cRecHum
							MsUnLock()
						EndIf
					EndIf
					(cAliasRgr)->(DbSkip())
				EndDo
				dbSelectarea(cAliasRgr)
				dbCloseArea()
				RestArea(aAreaSDB)
			EndIf
			//-- Retira trava para liberar uso desta carga / documento
			WMSTrava(0,cTrava)
		EndIf

		//-- O recurso humano deve reservar o endereco (DCQ_RESEND=='1')
		If lRet .And. aRetRegra[9]=='1' .And. !Empty(aRetRegra[12])
			cEndAux := aRetRegra[13]
			cCodCfg := aRetRegra[12]
			aAreaDC7 := DC7->(GetArea())
			DC7->(DbSetOrder(1))
			If DC7->(MsSeek(xFilial('DC7')+cCodCfg))
				cEndAux := PadR(Substr(cEndAux,1,DC7->DC7_POSIC),Len(DCQ->DCQ_LOCALI))
			EndIf
			RestArea(aAreaDC7)
			cArmazem:= aRetRegra[1]
			cCodZon := Space(Len(DCQ->DCQ_CODZON))
			//-- Nao precisa avaliar a zona do endereco origem / destino, pois esta procurando zonas em branco
			//-- Regra 01
			AAdd(aRegra,cCodZon+Space(Len(DCQ->DCQ_SERVIC))+Space(Len(DCQ->DCQ_TAREFA))+Space(Len(DCQ->DCQ_ATIVID)))
			//-- Regra 02
			AAdd(aRegra,cCodZon+cServico+Space(Len(DCQ->DCQ_TAREFA))+Space(Len(DCQ->DCQ_ATIVID)))
			//-- Regra 03
			AAdd(aRegra,cCodZon+cServico+cTarefa+Space(Len(DCQ->DCQ_ATIVID)))
			//-- Regra 04
			AAdd(aRegra,cCodZon+cServico+cTarefa+cAtivid)

			cCodZon := aRetRegra[16]
			//-- Regra 05
			AAdd(aRegra,cCodZon+Space(Len(DCQ->DCQ_SERVIC))+Space(Len(DCQ->DCQ_TAREFA))+Space(Len(DCQ->DCQ_ATIVID)))
			//-- Regra 06
			AAdd(aRegra,cCodZon+cServico+Space(Len(DCQ->DCQ_TAREFA))+Space(Len(DCQ->DCQ_ATIVID)))
			//-- Regra 07
			AAdd(aRegra,cCodZon+cServico+cTarefa+Space(Len(DCQ->DCQ_ATIVID)))
			//-- Regra 08
			AAdd(aRegra,cCodZon+cServico+cTarefa+cAtivid)

			aAreaDCQ := DCQ->(GetArea())
			//-- DCQ_FILIAL+DCQ_TPREGR+DCQ_STATUS+DCQ_LOCAL+DCQ_LOCALI+DCQ_CODZON+DCQ_SERVIC+DCQ_TAREFA+DCQ_ATIVID+DCQ_CODFUN
			DCQ->(DbSetOrder(2))
			//-- Verifica se algum recurso humano reservou o endereco
			For n1Cnt := 1 To Len(aRegra)
				If DCQ->(MsSeek(xFilial('DCQ')+'1'+'1'+cArmazem+cEndAux+aRegra[n1Cnt]))
					lRet := (DCQ->DCQ_CODFUN == cRecHum)
					Exit
				EndIf
			Next
			RestArea(aAreaDCQ)

			If lRet
				//-- Este recurso humano reserva a rua
				RecLock('DCQ',.F.)
				DCQ->DCQ_LOCALI := cEndAux
				MsUnLock()
			EndIf
		EndIf
	EndIf
	If !lRet .And. !Empty(aRetRegra)
		aRetRegra := {}
	EndIf
ElseIf cAcao=='3'
	//-- Apesar de o operador(A) nao ter regra definida, preciso analisar se outro operador(B) reservou a rua,
	//-- se o operador(B) ja reservou a rua o operador(A) nao sera convocado ate que a rua seja liberada.
	lRet := .T.
	cCodZon := Space(Len(DCQ->DCQ_CODZON))
	//-- Nao precisa avaliar a zona do endereco origem / destino, pois esta procurando zonas em branco
	//-- Regra 01
	AAdd(aRegra,cCodZon+Space(Len(DCQ->DCQ_SERVIC))+Space(Len(DCQ->DCQ_TAREFA))+Space(Len(DCQ->DCQ_ATIVID)))
	//-- Regra 02
	AAdd(aRegra,cCodZon+cServico+Space(Len(DCQ->DCQ_TAREFA))+Space(Len(DCQ->DCQ_ATIVID)))
	//-- Regra 03
	AAdd(aRegra,cCodZon+cServico+cTarefa+Space(Len(DCQ->DCQ_ATIVID)))
	//-- Regra 04
	AAdd(aRegra,cCodZon+cServico+cTarefa+cAtivid)

	aAreaSBE := SBE->(GetArea())
	SBE->(DbSetOrder(1))
	//-- Zona do endereco origem
	If SBE->(MsSeek(xFilial('SBE')+cArmazem+cEndOri+cEstrOri))
		If DLTipoEnd(cEstrOri)!=5
			cCodZon := SBE->BE_CODZON
			//-- Regra 05
			AAdd(aRegra,cCodZon+Space(Len(DCQ->DCQ_SERVIC))+Space(Len(DCQ->DCQ_TAREFA))+Space(Len(DCQ->DCQ_ATIVID)))
			//-- Regra 06
			AAdd(aRegra,cCodZon+cServico+Space(Len(DCQ->DCQ_TAREFA))+Space(Len(DCQ->DCQ_ATIVID)))
			//-- Regra 07
			AAdd(aRegra,cCodZon+cServico+cTarefa+Space(Len(DCQ->DCQ_ATIVID)))
			//-- Regra 08
			AAdd(aRegra,cCodZon+cServico+cTarefa+cAtivid)
			cCodCfg := SBE->BE_CODCFG
			cEndAux := cEndOri
		EndIf
	EndIf
	//-- Zona do endereco destino
	If SBE->(MsSeek(xFilial('SBE')+cArmazem+cEndDes+cEstrDes))
		If DLTipoEnd(cEstrDes)!=5
			If SBE->BE_CODZON != cCodZon
				cCodZon := SBE->BE_CODZON
				//-- Regra 09
				AAdd(aRegra,cCodZon+Space(Len(DCQ->DCQ_SERVIC))+Space(Len(DCQ->DCQ_TAREFA))+Space(Len(DCQ->DCQ_ATIVID)))
				//-- Regra 10
				AAdd(aRegra,cCodZon+cServico+Space(Len(DCQ->DCQ_TAREFA))+Space(Len(DCQ->DCQ_ATIVID)))
				//-- Regra 11
				AAdd(aRegra,cCodZon+cServico+cTarefa+Space(Len(DCQ->DCQ_ATIVID)))
				//-- Regra 12
				AAdd(aRegra,cCodZon+cServico+cTarefa+cAtivid)
			EndIf
			cCodCfg := SBE->BE_CODCFG
			cEndAux := cEndDes
		EndIf
	EndIf
	RestArea(aAreaSBE)
	aAreaDC7 := DC7->(GetArea())
	DC7->(DbSetOrder(1))
	If !Empty(cCodCfg) .And. DC7->(MsSeek(xFilial('DC7')+cCodCfg))
		cEndAux := PadR(Substr(cEndAux,1,DC7->DC7_POSIC),Len(DCQ->DCQ_LOCALI))
		aAreaDCQ := DCQ->(GetArea())
		//-- DCQ_FILIAL+DCQ_TPREGR+DCQ_STATUS+DCQ_LOCAL+DCQ_LOCALI+DCQ_CODZON+DCQ_SERVIC+DCQ_TAREFA+DCQ_ATIVID+DCQ_CODFUN
		DCQ->(DbSetOrder(2))
		//-- Verifica se algum recurso humano reservou o endereco
		For n1Cnt := 1 To Len(aRegra)
			If DCQ->(MsSeek(xFilial('DCQ')+'1'+'1'+cArmazem+cEndAux+aRegra[n1Cnt]))
				//-- O endereco esta reservado
				lRet:=.F.
				Exit
			EndIf
		Next
		RestArea(aAreaDCQ)
	EndIf
	RestArea(aAreaDC7)
ElseIf cAcao=='4'
	//-- Libera a RUA ao finalizar cada atividade
	If aRetRegra[10]=='1'
		lRet := .T.
	//-- Libera a RUA quando todo o servico / tarefa / atividade forem executados
	ElseIf aRetRegra[10]=='2'
		If lRetAtiv
			aAreaSDB := SDB->(GetArea())
			cAliasRgr:= GetNextAlias()
			cQuery := "SELECT DB_CARGA,DB_LOCALIZ,DB_ESTFIS,DB_ENDDES,DB_ESTDES,DB_DATA"
			cQuery += " FROM"
			cQuery += " "+RetSqlName('SDB')+" SDB"
			cQuery += " WHERE"
			cQuery += " DB_FILIAL       = '"+xFilial("SDB")+"'"
			cQuery += " AND DB_ATUEST   = 'N'"
			cQuery += " AND DB_ESTORNO  = ' '"
			cQuery += " AND DB_LOCAL    = '"+aRetRegra[1]+"'"
			cQuery += " AND DB_STATUS   = '"+cStatAExe+"'"
			cQuery += " AND DB_RHFUNC   = '"+cFuncao+"'"
			If !Empty(aRetRegra[4])
				cQuery += " AND DB_SERVIC = '"+aRetRegra[4]+"'"
			EndIf
			If !Empty(aRetRegra[5])
				cQuery += " AND DB_TAREFA = '"+aRetRegra[5]+"'"
			EndIf
			If !Empty(aRetRegra[6])
				cQuery += " AND DB_ATIVID = '"+aRetRegra[6]+"'"
			EndIf
			cQuery += " AND SDB.D_E_L_E_T_ = ' ' "
			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasRgr,.F.,.T.)

			//-- Nao ha servicos, libera a rua
			lRet := .T.
			While (cAliasRgr)->(!Eof())
				//-- Verifica se limitou a regra a alguma Carga
				If !Empty(aRetRegra[14])
					If !Empty((cAliasRgr)->DB_CARGA) .And. !((cAliasRgr)->DB_CARGA$aRetRegra[14])
						(cAliasRgr)->(DbSkip())
						Loop
					EndIf
				EndIf
				//-- Encontrou servicos para a carga definida, nao libera a rua
				lRet := .F.
				//-- Verifica se houve limitacao de endereco para convocacao (Preenchimento dos campos DCQ_ENDINI e DCQ_ENDFIM)
				cEndAux := ''
				If !Empty(aRetRegra[8]) .And. !Empty(aRetRegra[12]) .And. !Empty(aRetRegra[13])
					If DLTipoEnd((cAliasRgr)->DB_ESTFIS)!=5
						cEndAux := (cAliasRgr)->DB_LOCALIZ
					ElseIf DLTipoEnd((cAliasRgr)->DB_ESTDES)!=5
						cEndAux := (cAliasRgr)->DB_ENDDES
					EndIf
					If !Empty(cEndAux)
						//-- Se o endereco nao estiver entre a faixa definida, libera a rua
						lRet := .T.
						cEndAux := PadR(Substr(cEndAux,1,Len(AllTrim(aRetRegra[13]))),Len(DCQ->DCQ_LOCALI))
						If (cEndAux >= aRetRegra[7] .And. cEndAux <= aRetRegra[8])
							//-- Encontrou servicos num endereco entre a faixa definida, nao libera a rua
							lRet := .F.
							Exit
						EndIf
					EndIf
				EndIf
				(cAliasRgr)->(DbSkip())
			EndDo
			DbSelectarea(cAliasRgr)
			DbCloseArea()
			RestArea(aAreaSDB)
		Else
			lRet := .T.
		EndIf
	//-- O operador libera a RUA atraves do coletor de RF
	ElseIf aRetRegra[10]=='3'
		If lRetAtiv
			lRet := (DLVTAviso('WMSXFUNA08',STR0031, {STR0032,STR0033}) == 1) //'Libera a RUA ?'##'Sim'##'Nao'
		Else
			lRet := .T.
		EndIf
	EndIf

	aAreaDCQ := DCQ->(GetArea())
	If lRet
		DbSelectArea('DCQ')
		DbSetOrder(1)
		DCQ->(MsGoTo(aRetRegra[15]))
		//-- Se o recurso humano reservou a rua, retira a reserva
		RecLock('DCQ',.F.)
		DCQ->DCQ_LOCALI := Space(Len(DCQ->DCQ_LOCALI))
		MsUnLock()
	EndIf
	RestArea(aAreaDCQ)
ElseIf cAcao=='5'
	//-- Verifica se existe o arquivo de regra
	//-- Analisa regra de convocacao de sequenciamento
	If SIX->(MsSeek('DCQ3')) .And. AllTrim(SIX->CHAVE)=='DCQ_FILIAL+DCQ_TPREGR+DCQ_STATUS+DCQ_LOCAL+DCQ_SERVIC+DCQ_TAREFA+DCQ_ATIVID+DCQ_ENDINI+DCQ_ENDFIM'
		aAreaDCQ := DCQ->(GetArea())
		aAreaSDB := SDB->(GetArea())
		For n2Cnt := 1 To Len(aLibSDB)
			If aLibSDB[n2Cnt,3]+aLibSDB[n2Cnt,4] <> cArmazem+cServico
				Loop
			EndIf
			SDB->(MsGoTo(aLibSDB[n2Cnt,2]))
			If SDB->(Eof())
				Loop
			EndIf
			cServico := SDB->DB_SERVIC
			cTarefa  := SDB->DB_TAREFA
			cAtivid  := SDB->DB_ATIVID
			aRegra   := {}
			lRet     := .F.

			//-- Regra 01
			AAdd(aRegra,Space(Len(DCQ->DCQ_SERVIC))+Space(Len(DCQ->DCQ_TAREFA))+Space(Len(DCQ->DCQ_ATIVID)))
			//-- Regra 02
			AAdd(aRegra,cServico+Space(Len(DCQ->DCQ_TAREFA))+Space(Len(DCQ->DCQ_ATIVID)))
			//-- Regra 03
			AAdd(aRegra,cServico+cTarefa+Space(Len(DCQ->DCQ_ATIVID)))
			//-- Regra 04
			AAdd(aRegra,cServico+cTarefa+cAtivid)

			DCQ->(DbSetOrder(3))
			For n1Cnt := 1 To Len(aRegra)
				If DCQ->(MsSeek(cSeekDCQ:=xFilial('DCQ')+'2'+'1'+cArmazem+aRegra[n1Cnt])) .And. !Empty(DCQ->DCQ_ORDEM)
					lRet:=.T.
					Exit
				EndIf
			Next

			If lRet
				cEndAux  := ''
				cFunExe  := ''
				cTipoSrv := ''
				lDoca := .F.
				If DLTipoEnd(SDB->DB_ESTFIS)!=5
					cEndAux := SDB->DB_LOCALIZ
				ElseIf   DLTipoEnd(SDB->DB_ESTDES)!=5
					cEndAux := SDB->DB_ENDDES
				Else
					WmsFunExe('1',SDB->DB_SERVIC,SDB->DB_TAREFA,@cFunExe,@cTipoSrv)
					cEndAux := SDB->DB_LOCALIZ
					lDoca := .T.
				EndIf
				While DCQ->(!Eof() .And. DCQ->DCQ_FILIAL+DCQ->DCQ_TPREGR+DCQ->DCQ_STATUS+DCQ->DCQ_LOCAL+DCQ->DCQ_SERVIC+DCQ->DCQ_TAREFA+DCQ->DCQ_ATIVID==cSeekDCQ)

					If !Empty(cEndAux) .And.;
						(Empty(DCQ->DCQ_ENDFIM) .Or. lDoca .Or. ;
						(Substr(cEndAux,1,Len(AllTrim(DCQ->DCQ_ENDFIM))) >= Substr(DCQ->DCQ_ENDINI,1,Len(AllTrim(DCQ->DCQ_ENDFIM))) .And.;
						 Substr(cEndAux,1,Len(AllTrim(DCQ->DCQ_ENDFIM))) <= Substr(DCQ->DCQ_ENDFIM,1,Len(AllTrim(DCQ->DCQ_ENDFIM))) ) )
						//-- Regra de sequencia para permitir priorizar blocos de enderecos.
						If Empty(DCQ->DCQ_PRIORI)
							cSequencia := Soma1(cSequencia,2)
							RecLock('DCQ',.F.)
							DCQ->DCQ_PRIORI := cSequencia
							MsUnLock()
						Else
							nSeek := AScan(aSequencia,DCQ->DCQ_PRIORI)
							If nSeek <= 0
								AAdd(aSequencia,DCQ->DCQ_PRIORI)
								nSeek := Len(aSequencia)
							EndIf
							cSequencia := aSequencia[nSeek]
						EndIf

						If 'DLCONFEREN' $ Upper(cFunExe) .Or. 'DLCONFSAI' $ Upper(cFunExe) .Or. 'DLCONFENT' $ Upper(cFunExe)
							AAdd(aSrv3,{cEndAux,SDB->DB_SERVIC,SDB->DB_ORDTARE,SDB->DB_ORDATIV,SDB->DB_CARGA,SDB->(Recno()),Iif(cTipoSrv=='1',Replicate('0',2),Replicate('Z',2)),'',SDB->DB_DOC, SDB->DB_CLIFOR, SDB->DB_LOJA})
						Else
							If DCQ->DCQ_ORDEM=='1'
								AAdd(aSrv1,{cEndAux,SDB->DB_SERVIC,SDB->DB_ORDTARE,SDB->DB_ORDATIV,SDB->DB_CARGA,SDB->(Recno()),'',cSequencia, SDB->DB_DOC, SDB->DB_CLIFOR, SDB->DB_LOJA})
							Else
								AAdd(aSrv2,{cEndAux,SDB->DB_SERVIC,SDB->DB_ORDTARE,SDB->DB_ORDATIV,SDB->DB_CARGA,SDB->(Recno()),'',cSequencia, SDB->DB_DOC, SDB->DB_CLIFOR, SDB->DB_LOJA})
							EndIf
						EndIf

						Exit
					EndIf
					DCQ->(DbSkip())
				EndDo
			EndIf
		Next
		RestArea(aAreaDCQ)
		RestArea(aAreaSDB)

		aSrv4 := {}
		cPriori := StrZero(0,2)

		If !Empty(aSrv1)

			ASort(aSrv1,,,{|x,y|x[1]+x[2]+x[3]+x[4] < y[1]+y[2]+y[3]+y[4]})
			//-- A T E N C A O : Nao altere o conteudo de cPriori pois o valor obtido no For/Next do vetor aSrv1 sera utilizado no For/Next feito no vetor aSrv2
			cChave := ''
			For n1Cnt := 1 To Len(aSrv1)
				If aSrv1[n1Cnt,1]+aSrv1[n1Cnt,2]+aSrv1[n1Cnt,3]!=cChave
					cPriori := Soma1(cPriori,2)
					cChave  := aSrv1[n1Cnt,1]+aSrv1[n1Cnt,2]+aSrv1[n1Cnt,3]
				EndIf
				AAdd(aSrv4,{aSrv1[n1Cnt,1],aSrv1[n1Cnt,2],aSrv1[n1Cnt,3],aSrv1[n1Cnt,4],aSrv1[n1Cnt,5],aSrv1[n1Cnt,6],cPriori,aSrv1[n1Cnt,8],aSrv1[n1Cnt,9],aSrv1[n1Cnt,10],aSrv1[n1Cnt,11]})
			Next

		EndIf


		If !Empty(aSrv2)

			ASort(aSrv2,,,{|x,y|x[1]+x[2]+x[3]+x[4] < y[1]+y[2]+y[3]+y[4]})
			//-- A T E N C A O : Neste ponto a variavel cPriori esta preenchida e sera utilizada pela funcao soma1() no For/Next abaixo.
			cChave := ''
			For n1Cnt := Len(aSrv2) To 1 Step -1
				If aSrv2[n1Cnt,1]+aSrv2[n1Cnt,2]+aSrv2[n1Cnt,3]!=cChave
					cPriori := Soma1(cPriori,2)
					cChave  := aSrv2[n1Cnt,1]+aSrv2[n1Cnt,2]+aSrv2[n1Cnt,3]
				EndIf
				aSrv2[n1Cnt,7]:=cPriori
			Next

			For n1Cnt := 1 To Len(aSrv2)
				AAdd(aSrv4,{aSrv2[n1Cnt,1],aSrv2[n1Cnt,2],aSrv2[n1Cnt,3],aSrv2[n1Cnt,4],aSrv2[n1Cnt,5],aSrv2[n1Cnt,6],aSrv2[n1Cnt,7],aSrv2[n1Cnt,8],aSrv2[n1Cnt,9],aSrv2[n1Cnt,10],aSrv2[n1Cnt,11]})
			Next

		EndIf
		//-- Ordena pela prioridade de faixa de enderecos
		If !Empty(aSrv4)
			//Ordena por DB_CARGA/DB_DOC/DB_CLIFOR/DB_LOJA
			ASort(aSrv4,,,{|x,y| x[5]+x[9]+x[10]+x[11] < y[5]+y[9]+y[10]+y[11] })
			cKeyDoc  := ""
			cSeqPri  := ""
			For n1Cnt := 1 To Len(aSrv4)
				//Grava a Sequencia de prioridade de convocacao
				SDB->(MsGoTo(aSrv4[n1Cnt,6]))
				If WmsCarga(SDB->DB_CARGA)
					If SDB->DB_CARGA <> cKeyDoc
						cSeqPri := WMSBuscaSeqPri(SDB->(Recno()))
						cKeyDoc := SDB->DB_CARGA
					EndIf
				Else
					If SDB->DB_DOC+SDB->DB_CLIFOR+SDB->DB_LOJA <> cKeyDoc
						cSeqPri := WMSBuscaSeqPri(SDB->(Recno()))
						cKeyDoc := SDB->DB_DOC+SDB->DB_CLIFOR+SDB->DB_LOJA
					EndIf
				EndIf
				RecLock('SDB',.F.)
				SDB->DB_SEQPRI := cSeqPri
				MsUnLock()
			Next

			cPriori := StrZero(0,2)
			cChave := ""
			// --- DB_FILIAL+DB_LOCAL+(DB_LOCALIZ ou DB_ENDDES)+DB_SERVIC+DB_ORDTARE+DB_ORDATIV
			ASort(aSrv4,,,{|x,y| x[8]+x[7]+x[1]+x[2]+x[3]+x[4] < y[8]+y[7]+y[1]+y[2]+y[3]+y[4] })

			For n1Cnt := 1 To Len(aSrv4)
				// ---
				If aSrv4[n1Cnt,8]+aSrv4[n1Cnt,7]+aSrv4[n1Cnt,1]+aSrv4[n1Cnt,2]+aSrv4[n1Cnt,3]!=cChave
					cPriori := Soma1(cPriori,2)
					cChave  := aSrv4[n1Cnt,8]+aSrv4[n1Cnt,7]+aSrv4[n1Cnt,1]+aSrv4[n1Cnt,2]+aSrv4[n1Cnt,3]
				EndIf
				SDB->(MsGoTo(aSrv4[n1Cnt,6]))

				If Empty(SDB->DB_PRIORI)
					cGrvPri := 'ZZ'
				Else
					cGrvPri := SubStr(SDB->DB_PRIORI,1,2)
				EndIf
				cGrvPri := cGrvPri+IIf(Empty(cPrior),'',&cPrior)+cPriori

				//------------------------------------------------------------------------
				//  Ponto de entrada que permite a manipulacao do campo DB_PRIORI
				//  Parametros: PARAMIXB[1] = Valor que seria gravado no campo DB_PRIORI
				//              PARAMIXB[2] = 1 para crescente / 2 para descrescente
				//  Retorno:    Valor a ser gravado no campo DB_PRIORI
				//------------------------------------------------------------------------
				If lPEWmsReg
					cGrvPri := ExecBlock("WMSREGRA", .F., .F., {cPriori, 1})
					If ValType(cGrvPri)<>"C" .Or. Empty(cGrvPri)
						cGrvPri := cPriori
					EndIf
				EndIf
				RecLock('SDB',.F.)
				SDB->DB_PRIORI := cGrvPri
				MsUnLock()
				If (nPos := AScan(aLibSDB,{|x| x[2] == SDB->(Recno())})) > 0
					AAdd(aLibSDB[nPos],SDB->DB_PRIORI)
				EndIf
			Next

		EndIf

		If !Empty(aSrv3)
			//Ordena por DB_CARGA/DB_DOC/DB_CLIFOR/DB_LOJA
			ASort(aSrv3,,,{|x,y| x[5]+x[9]+x[10]+x[11] < y[5]+y[9]+y[10]+y[11] })
			cKeyDoc  := ""
			cSeqPri  := ""
			For n1Cnt := 1 To Len(aSrv3)
				SDB->(MsGoTo(aSrv3[n1Cnt,6]))
				If Empty(SDB->DB_PRIORI)
					cGrvPri := 'ZZ'
				Else
					cGrvPri := SubStr(SDB->DB_PRIORI,1,2)
				EndIf
				If WmsCarga(SDB->DB_CARGA)
					If SDB->DB_CARGA <> cKeyDoc
						cSeqPri := WMSBuscaSeqPri(SDB->(Recno()))
						cKeyDoc := SDB->DB_CARGA
					EndIf
				Else
					If SDB->DB_DOC+SDB->DB_CLIFOR+SDB->DB_LOJA <> cKeyDoc
						cSeqPri := WMSBuscaSeqPri(SDB->(Recno()))
						cKeyDoc := SDB->DB_DOC+SDB->DB_CLIFOR+SDB->DB_LOJA
					EndIf
				EndIf
				RecLock('SDB',.F.)
				//Grava a Sequencia de prioridade de convocacao
				SDB->DB_SEQPRI := cSeqPri
				SDB->DB_PRIORI := cGrvPri+IIf(Empty(cPrior),'',&cPrior)+aSrv3[n1Cnt,7]
				MsUnLock()
				If (nPos := AScan(aLibSDB,{|x| x[2] == SDB->(Recno())})) > 0
					AAdd(aLibSDB[nPos],SDB->DB_PRIORI)
				EndIf
			Next
		EndIf

		lRet := .T.

	EndIf
ElseIf cAcao=='6'
	//-- Verifica se existe os indices do arquivo de regras
	//-- Libera o endereco se estiver travado pelo recurso humano, ao reiniciar a tarefa/atividade.
	If SIX->(MsSeek('DCQ1')) .And. AllTrim(SIX->CHAVE)=='DCQ_FILIAL+DCQ_TPREGR+DCQ_STATUS+DCQ_LOCAL+DCQ_CODFUN+DCQ_CODZON+DCQ_SERVIC+DCQ_TAREFA+DCQ_ATIVID'
		aAreaDCQ := DCQ->(GetArea())
		DCQ->(DbSetOrder(1))
		If DCQ->(MsSeek(cSeekDCQ:=xFilial('DCQ')+'1'+'1'+cArmazem+cRecHum))
			While DCQ->(!Eof() .And. DCQ->DCQ_FILIAL+DCQ->DCQ_TPREGR+DCQ->DCQ_STATUS+DCQ->DCQ_LOCAL+DCQ->DCQ_CODFUN==cSeekDCQ)
				//-- Se o recurso humano reservou a rua, retira a reserva
				RecLock('DCQ',.F.)
				DCQ->DCQ_LOCALI := Space(Len(DCQ->DCQ_LOCALI))
				MsUnLock()
				DCQ->(DbSkip())
			EndDo
		EndIf
		RestArea(aAreaDCQ)
	EndIf
ElseIf cAcao=="7"
	//-- Gerar sequencia quando encontrar Regra.
	//-- Verifica se existe os indices do arquivo de regras
	If SIX->(MsSeek('DCQ1')) .And. AllTrim(SIX->CHAVE)=='DCQ_FILIAL+DCQ_TPREGR+DCQ_STATUS+DCQ_LOCAL+DCQ_CODFUN+DCQ_CODZON+DCQ_SERVIC+DCQ_TAREFA+DCQ_ATIVID'
		cChave   := ""
		cKeyDoc  := ""
		cSeqPri  := ""
		For n1Cnt := 1 To Len(aLibSDB)
			If aLibSDB[n1Cnt,3]+aLibSDB[n1Cnt,4] <> cArmazem+cServico
				Loop
			EndIf
			//-- Se já possui regra definida não processa novamente
			If Len(aLibSDB[n1Cnt]) > 4
				Loop
			EndIf
			SDB->(MsGoTo(aLibSDB[n1Cnt,2]))
			If SDB->(Eof())
				Loop
			EndIf
			If SDB->DB_LOCAL+SDB->DB_SERVIC == cArmazem+cServico
				cEndAux := ""
				If Empty(SDB->DB_PRIORI)
					cGrvPri := 'ZZ'
				Else
					cGrvPri := SubStr(SDB->DB_PRIORI,1,2)
				EndIf
				If DLTipoEnd(SDB->DB_ESTFIS)<>5
					cEndAux := SDB->DB_LOCALIZ
				ElseIf DLTipoEnd(SDB->DB_ESTDES)<>5
					cEndAux := SDB->DB_ENDDES
				Else
					cEndAux := SDB->DB_LOCALIZ
				EndIf
				If cEndAux <> cChave
					cPriori := Soma1(cPriori,2)
					cChave   := cEndAux
				EndIf
				If WmsCarga(SDB->DB_CARGA)
					If SDB->DB_CARGA <> cKeyDoc
						cSeqPri := WMSBuscaSeqPri(SDB->(Recno()))
						cKeyDoc := SDB->DB_CARGA
					EndIf
				Else
					If SDB->DB_DOC+SDB->DB_CLIFOR+SDB->DB_LOJA <> cKeyDoc
						cSeqPri := WMSBuscaSeqPri(SDB->(Recno()))
						cKeyDoc := SDB->DB_DOC+SDB->DB_CLIFOR+SDB->DB_LOJA
					EndIf
				EndIf
				RecLock("SDB",.F.)
				//Grava a Sequencia de prioridade de convocacao
				SDB->DB_SEQPRI := cSeqPri
				SDB->DB_PRIORI := cGrvPri+IIf(Empty(cPrior),'',&cPrior)+cPriori
				MsUnLock()
				AAdd(aLibSDB[n1Cnt],SDB->DB_PRIORI)
			EndIf
		Next n1Cnt
	EndIf
ElseIf cAcao=="8"
	If Type("aWmsDCF")=="A"
		For n1Cnt := 1 To Len(aWmsDCF)
			//-- Inclui trava para uso exclusivo desta carga / documento
			If WMSTrava(1,@cTrava,aWmsDCF[n1Cnt, 3],aWmsDCF[n1Cnt, 4],"")
				aAreaSDB := SDB->(GetArea())
				cAliasRgr:= GetNextAlias()
				cQuery := "SELECT DB_LOCAL,DB_SERVIC,DB_ORDTARE,DB_ORDATIV,DB_CARGA,DB_DOC,DB_SERIE,DB_STATUS,SDB.R_E_C_N_O_ RECNOSDB"
				cQuery += " FROM " + RetSqlName('SDB')+" SDB "
				cQuery += " WHERE"
				cQuery += " DB_FILIAL      = '"+xFilial("SDB")+"'"
				cQuery += " AND DB_ATUEST  = 'N'"
				cQuery += " AND DB_ESTORNO = ' '"
				cQuery += " AND DB_LOCAL   = '"+aWmsDCF[n1Cnt, 1]+"'"
				cQuery += " AND DB_SERVIC  = '"+aWmsDCF[n1Cnt, 2]+"'"
				cQuery += " AND DB_STATUS IN ('"+cStatProb+"','"+cStatAExe+"') "
				cQuery += " AND SDB.D_E_L_E_T_ = ' ' "
				If WmsCarga(aWmsDCF[n1Cnt, 3])
					cQuery += " AND DB_CARGA  = '"+aWmsDCF[n1Cnt, 3]+"'"
				Else
					cQuery += " AND DB_DOC    = '"+aWmsDCF[n1Cnt, 4]+"'"
					cQuery += " AND DB_CLIFOR = '"+aWmsDCF[n1Cnt, 5]+"'"
					cQuery += " AND DB_LOJA   = '"+aWmsDCF[n1Cnt, 6]+"'"
				EndIf
				cQuery += " ORDER BY DB_LOCAL,DB_SERVIC,DB_ORDTARE,DB_ORDATIV,DB_CARGA,DB_DOC,DB_SERIE "
				cQuery := ChangeQuery(cQuery)
				DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasRgr,.F.,.T.)
				While (cAliasRgr)->(!Eof())
					aAdd(aLibSDB,{(cAliasRgr)->DB_STATUS,(cAliasRgr)->RECNOSDB,(cAliasRgr)->DB_LOCAL,(cAliasRgr)->DB_SERVIC})
					SDB->(dbGoTo((cAliasRgr)->RECNOSDB))
					RecLock("SDB",.F.)
					SDB->DB_STATUS := "-"
					MsUnLock()
					(cAliasRgr)->(DbSkip())
				EndDo
				DbSelectarea(cAliasRgr)
				DbCloseArea()
				RestArea(aAreaSDB)
				//-- Retira trava para liberar uso desta carga / documento
				WMSTrava(0,cTrava)
			EndIf
		Next n1Cnt
	EndIf
ElseIf cAcao=="9"
	If Type("aWmsDCF")=="A"
		For n1Cnt := 1 To Len(aWmsDCF)
			aAreaSDB := SDB->(GetArea())
			cAliasRgr:= GetNextAlias()
			cQuery := "SELECT DB_LOCAL, DB_SERVIC, DB_STATUS, SDB.R_E_C_N_O_ RECNOSDB"
			cQuery += " FROM " + RetSqlName('SDB')+" SDB "
			cQuery += " INNER JOIN "+RetSqlName('DCD')+" DCD"
			cQuery +=  " ON DCD_FILIAL   = '"+xFilial('DCD')+"'"
			cQuery +=   " AND DCD_CODFUN = DB_RECHUM"
			cQuery +=   " AND DCD_STATUS IN ('1','2')" // Somente se o operador estiver livre ou ocupado
			cQuery +=   " AND DCD.D_E_L_E_T_ = ' '"
			cQuery += " WHERE DB_FILIAL  = '"+xFilial("SDB")+"'"
			cQuery +=   " AND DB_ATUEST  = 'N'"
			cQuery +=   " AND DB_ESTORNO = ' '"
			cQuery +=   " AND DB_LOCAL   = '"+aWmsDCF[n1Cnt, 1]+"'"
			cQuery +=   " AND DB_SERVIC  = '"+aWmsDCF[n1Cnt, 2]+"'"
			cQuery +=   " AND DB_STATUS IN ('"+cStatProb+"','"+cStatInte+"','"+cStatAExe+"','"+cStatExec+"') "
			cQuery +=   " AND DB_RECHUM <> '"+cRecVazio+"'"
			cQuery +=   " AND SDB.D_E_L_E_T_ = ' ' "
			If WmsCarga(aWmsDCF[n1Cnt, 3])
				cQuery += " AND DB_CARGA  = '"+aWmsDCF[n1Cnt, 3]+"'"
			Else
				cQuery += " AND DB_DOC    = '"+aWmsDCF[n1Cnt, 4]+"'"
				cQuery += " AND DB_CLIFOR = '"+aWmsDCF[n1Cnt, 5]+"'"
				cQuery += " AND DB_LOJA   = '"+aWmsDCF[n1Cnt, 6]+"'"
			EndIf
			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasRgr,.F.,.T.)
			While (cAliasRgr)->(!Eof())
				SDB->(dbGoTo((cAliasRgr)->RECNOSDB))
				cRecHum := SDB->DB_RECHUM
				//-- Verifica se ha regras para convocacao para estas atividades.
				aRetRgExc := {}
				If WmsRegra('1',SDB->DB_LOCAL,cRecHum,SDB->DB_SERVIC,SDB->DB_TAREFA,SDB->DB_ATIVID,SDB->DB_LOCALIZ,SDB->DB_ESTFIS,SDB->DB_ENDDES,SDB->DB_ESTDES,aRetRgExc)
					//-- Analisa se convocao ou nao
					If WmsRegra('2',,cRecHum,SDB->DB_SERVIC,SDB->DB_TAREFA,SDB->DB_ATIVID,,,,,aRetRgExc,,SDB->DB_CARGA)
						//-- Grava unico recurso nas atividades pendentes
					EndIf
				EndIf
				(cAliasRgr)->(DbSkip())
			EndDo
			DbSelectarea(cAliasRgr)
			DbCloseArea()
			RestArea(aAreaSDB)
		Next n1Cnt
	EndIf
EndIf
RestArea(aAreaAnt)
Return(lRet)

/*
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Função     WmsVldSrv| Autor   Alex Egydio                 Data 10.05.2006 --
-------------------------------------------------------------------------------
-- Descrição   Validacoes do servico                                         --
-------------------------------------------------------------------------------
-- Parametros  ExpC1 - 1 = Verifica se o servico informado no campo          --
--                         B5_SERVEMB eh um servico de saida.                --
--                         Chamado pelo X3_VALID do campo B5_SERVEMB         --
--                                                                           --
--                     2 = Obtem o servico informado na montagem da carga.   --
--                         Chamado pelas funcoes WmsChkSC9,DLA220Esto e      --
--                         DL200PrEst                                        --
--                                                                           --
--                     3 = Obtem o servico informado no complem.do produto   --
--                         Chamado pelas funcoes OmsA210 e OmsXfun           --
--                                                                           --
--                     4 = Verifica se a execucao do servico de wms sera     --
--                         automatica                                        --
--                                                                           --
--                     5 = Verifica se o servico eh de conferencia           --
--                                                                           --
--                     6 = Verifica o tipo do servico                        --
--                                                                           --
--                     7 = Verifica se o servico eh de armazenagem           --
--                                                                           --
--                     8 = Verifica se o servico eh de crossdoc              --
--             ExpC2 - Servico                                               --
--             ExpC3 - Alias do arquivo que gerou o movimento                --
--             ExpC4 - Carga                                                 --
--             ExpC5 - Produto                                               --
--             ExpC6 - Unitizador                                            --
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------*/
Function WmsVldSrv(cAcao,cServico,cOrigem,cCarga,cProduto,cUnitiz,lHelp,cTm)
Local aAreaAnt := GetArea()
Local aAreaSB5 := {}
Local aAreaDC5 := {}
Local aAreaDBN := {}
Local lRet     := .T.
Local lWmsNew  := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local cFunExe  := ""

Default lHelp  := .T.
Default cTm    := ""
	//-- Acionado do x3_valid do campo B5_SERVEMB
	If cAcao=='1'
		If !Empty(cServico)
			aAreaDC5 := DC5->(GetArea())
			DC5->(DbSetOrder(1))
			If DC5->(MsSeek(xFilial('DC5')+cServico)) .And. DC5->DC5_TIPO=='2'
				lRet :=.T.
			Else
				If lHelp
					Help('',1,'REGNOIS',, AllTrim(RetTitle('DC5_SERVIC'))+' : '+cServico,4,1)
				EndIf
				lRet:=.F.
			EndIf
			RestArea(aAreaDC5)
		EndIf
	//-- Acionado pelas funcoes WmsChkSC9, DLA220Esto e DL220PrEst
	ElseIf cAcao=='2'
		If cOrigem=='DBN'
			aAreaDBN := DBN->(GetArea())
			DBN->(DbSetOrder(4)) //--DBN_FILIAL + DBN_CARGA + DBN_UNITIZ + DBN_CODPRO
			If DBN->(MsSeek(xFilial('DBN')+cCarga+cUnitiz+cProduto))
				cServico := DBN->DBN_SERVIC
			EndIf
			RestArea(aAreaDBN)
		EndIf
	//-- Acionado pelas funcoes OmsA210 e OmsxFun
	ElseIf cAcao=='3'
		DbSelectArea('SB5')
		aAreaSB5 := SB5->(GetArea())
		SB5->(DbSetOrder(1))
		If SB5->(MsSeek(xFilial('SB5')+cProduto)) .And. !Empty(SB5->B5_SERVEMB)
			cServico := SB5->B5_SERVEMB
			lRet := .T.
		Else
			lRet := .F.
		EndIf
		RestArea(aAreaSB5)
	//-- Acionado pela funcao maavalsc9, omsa200, omsa210, mata140, mata240, mata410 e CriaSDA.
	ElseIf cAcao=='4'
		DbSelectArea('DC5')
		aAreaDC5 := DC5->(GetArea())
		DC5->(DbSetOrder(1))
		lRet := ( DC5->(MsSeek(xFilial('DC5')+cServico)) .And. DC5->DC5_TPEXEC=='2' )
		RestArea(aAreaDC5)
	//-- Acionado pela funcao Ma140LinOk
	ElseIf cAcao=='5'
		If !lWmsNew .And. !Empty(cServico)
			Aviso("SIGAWMS",STR0113, {STR0036}) // Nao informar servico WMS para itens com endereco informado.
			lRet := .F.
		EndIf
	//-- Acionado pela funcao A241LinOk
	ElseIf cAcao=='6'
		aAreaDC5 := DC5->(GetArea())
		//-- Valida o Tipo de Servico
		DC5->(DbSetOrder(1))
		If DC5->(MsSeek(xFilial('DC5')+cServico))
			If cTm > '500'
				If !(DC5->DC5_TIPO == '2')
					Aviso("SIGAWMS",STR0034, {STR0036}) // Somente Serviços de SAÍDA ou MOV.INTERNA podem ser digitados para este tipo de movimentação'##'Ok'
					lRet := .F.
				EndIf
			Else
				If !(DC5->DC5_TIPO == '1')
					Aviso("SIGAWMS",STR0035, {STR0036}) //'Somente Serviços de ENTRADA ou MOV.INTERNA podem ser digitados para este tipo de movimentação'##'Ok'
					lRet := .F.
				EndIf
			EndIf
		Else
			If lHelp
				Help('',1,'REGNOIS',, AllTrim(RetTitle('DC5_SERVIC'))+' : '+cServico,4,1)
			EndIf
			lRet:=.F.
		EndIf
		RestArea(aAreaDC5)
	//-- Acionado pela funcao
	ElseIf cAcao=='7'
		aAreaDC5 := DC5->(GetArea())
		DC5->(DbSetOrder(1))
		If DC5->(MsSeek(xFilial('DC5')+cServico))
			//-- Verifica se o servico eh de armazenagem
			SX5->(DbSetOrder(1))
			If SX5->(MsSeek(xFilial('SX5')+'L6'+DC5->DC5_FUNEXE))
				cFunExe := AllTrim(Upper(SX5->(X5Descri())))
				//-- Indica se a funcao executada eh RDMake
				lRet := (cFunExe == "DLENDERECA()") .Or. (SubStr(cFunExe, 1, 2) == 'U_') .Or. (Empty(cFunExe))
			EndIf
		EndIf
		RestArea(aAreaDC5)
	//-- Acionado pela funcao
	ElseIf cAcao=='8'
		aAreaDC5 := DC5->(GetArea())
		DC5->(DbSetOrder(1))
		If DC5->(MsSeek(xFilial('DC5')+cServico))
			//-- Verifica se o servico eh de crossdoc
			SX5->(DbSetOrder(1))
			If SX5->(MsSeek(xFilial('SX5')+'L6'+DC5->DC5_FUNEXE))
				cFunExe := AllTrim(Upper(SX5->(X5Descri())))
				//-- Indica se a funcao executada eh RDMake
				lRet := (cFunExe == "DLCROSSDOC()") .Or. (SubStr(cFunExe, 1, 2) == 'U_') .Or. (Empty(cFunExe))
			EndIf
		EndIf
		RestArea(aAreaDC5)
	ElseIf cAcao=='9'
		aAreaDC5 := DC5->(GetArea())
		DC5->(DbSetOrder(1))
		If DC5->(MsSeek(xFilial('DC5')+cServico))
			//-- Verifica se o servico eh de conferencia
			SX5->(DbSetOrder(1))
			If SX5->(MsSeek(xFilial('SX5')+'L6'+DC5->DC5_FUNEXE))
				cFunExe := AllTrim(Upper(SX5->(X5Descri())))
				//-- Indica se a funcao executada eh RDMake
				lRet := (cFunExe == "DLAPANHEC1()") .Or. (cFunExe == "DLAPANHEC2()") .Or. (SubStr(cFunExe, 1, 2) == 'U_') .Or. (Empty(cFunExe))
			EndIf
		EndIf
		RestArea(aAreaDC5)
	ElseIf cAcao=='10'
		If !Empty(cServico)
			DC5->(DbSetOrder(1))
			If DC5->(MsSeek(xFilial("DC5")+cServico, .F.).And.DC5_TIPO=="3")
				SX5->(DbSetOrder(1))
				If !SX5->(MsSeek(xFilial('SX5')+'L6'+DC5->DC5_FUNEXE) .And. "DLTRANSFER" $ Upper(SX5->(X5Descri())))
					Aviso("SIGAWMS",STR0059,{STR0036}) //Somente serviços WMS de transferência podem ser utilizados.
					lRet := .F.
				EndIf
			Else
				Aviso("SIGAWMS",STR0060,{STR0036}) //Somente serviços de WMS do tipo 'Mov.Interna' podem ser utilizados.
				lRet := .F.
			EndIf
		EndIf
	EndIf
	
	RestArea(aAreaAnt)
Return(lRet)
/*
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Função     WmsFunExe| Autor   Alex Egydio                 Data 21.09.2006 --
-------------------------------------------------------------------------------
-- Descrição   Identifica a funcao executada pelo servico                    --
-------------------------------------------------------------------------------
-- Parametros  ExpC1 - 1 = Obtem a funcao executada pelo servico             --
--                     2 = Verifica se o servico esta associado a uma funcao --
--                         que deve movimentar estoque                       --
--                     3 = Verifica se o servico esta associado a uma funcao --
--                         que deve movimentar estoque e o servico ja eh     --
--                         passado para a funcao wmsfunexe atraves da        --
--                         variavel cfunexe.                                 --
--             ExpC2 - Servico                                               --
--             ExpC3 - Tarefa                                                --
--             ExpC4 - Nome da funcao executada pelo servico           (@)   --
--             ExpC5 - Tipo de Servico 1-Entrada/2-Saida/3-Mov.Interno (@)   --
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------*/
Function WmsFunExe(cAcao,cServico,cTarefa,cFunExe,cTipo)
Local aAreaAnt := GetArea()
Local aAreaDC5 := DC5->(GetArea())
Local cSeekDC5 := ''
Local lRet     := .F.
DEFAULT cFunExe   := ''
DEFAULT cTipo  := ''
If cAcao=='1' .Or. cAcao=='2'
	DC5->(DbSetOrder(1))
	If DC5->(MsSeek(cSeekDC5:=xFilial('DC5')+cServico))
		While DC5->(!Eof() .And. DC5->DC5_FILIAL+DC5->DC5_SERVIC==cSeekDC5)
			If DC5->DC5_TAREFA == cTarefa .And. !Empty(DC5->DC5_FUNEXE)
				SX5->(DbSetOrder(1))
				SX5->(MsSeek(xFilial('SX5')+'L6'+DC5->DC5_FUNEXE))
				cFunExe := AllTrim(SX5->(X5Descri()))
				cTipo   := DC5->DC5_TIPO
				lRet    := .T.
				Exit
			EndIf
			DC5->(DbSkip())
		EndDo
	EndIf
EndIf

If cAcao=='2' .Or. cAcao=='3'
	//-- Recebimento de mercadorias, Apanhe ou (Re)Abastecimento
	If 'DLENDERECA' $ Upper(cFunExe) .Or. ;
		'DLCROSSDOC' $ Upper(cFunExe) .Or. ;
		'DLAPANHE'   $ Upper(cFunExe) .Or. ;
		'DLGXABAST'  $ Upper(cFunExe) .Or. ;
		(SubStr(cFunExe, 1, 2) == 'U_') .Or. (Empty(cFunExe))
		lRet := .T.
	EndIf
EndIf

RestArea(aAreaDC5)
RestArea(aAreaAnt)
Return(lRet)

//------------------------------------------------------------------------------
Function WmsLibDCF(aLibDCF)
	If !Empty(aLibDCF)
		__aLibDCF := aLibDCF
	EndIf
Return __aLibDCF
//------------------------------------------------------------------------------
Function WmsOrdSer(oOrdServ)
	If oOrdServ != Nil
		__oOrdServ := oOrdServ
	EndIf
Return __oOrdServ

//------------------------------------------------------------------------------
// Execução de ordens de serviço das rotinas de integração
//------------------------------------------------------------------------------
Function WmsExeServ(lIsJob, lEncExe)
Local lRet      := .T.
Local lWmsNew   := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local lExAuSpCp := SuperGetMV("MV_WMSEASC",.F.,.F.)
Local nX        := 0

Default lIsJob     := SuperGetMV("MV_WMSEXJB",.F.,.F.)
Default lEncExe    := .F.

	If !lWmsNew
		If !Empty(__aLibDCF)
			Private aLibSDB   := {}
			Private aWmsAviso := {}
			// Executa as ordens de serviço
			For nX := 1 To Len(__aLibDCF)
				//-- Executa o servico de wms
				DCF->(MsGoTo(__aLibDCF[nX]))
				WmsExeDCF('1',.F.)
			Next
			// Avalia as regras e disponibiliza os registros para convocação
			WmsExeDCF('2')
			__aLibDCF := {}
		EndIf
	Else
		If __oOrdServ != Nil .And. !Empty(__oOrdServ:aLibDCF)
			If lIsJob .And. !lEncExe
				StartJob( "WmsExeJob", GetEnvServer(), .F., lIsJob, lEncExe, cEmpAnt, cFilAnt, __cUserID, __oOrdServ:aLibDCF,lExAuSpCp)
			Else
				lRet := WmsExeJob(lIsJob, lEncExe, cEmpAnt, cFilAnt, __cUserID, __oOrdServ:aLibDCF,lExAuSpCp)
			EndIf
			__oOrdServ:aLibDCF := {}
		EndIf
	EndIf
Return lRet

Function WmsExeJob(lIsJob, lEncExe, cEmpAmb, cFilAmb, cUsuario, aLibDCF, lExAuSpCp )
Local lRet       := .T.
Local lContinua  := .T.
Local oOrdSerRev := Nil
Local oOrdSerExe := Nil
Local oRegraConv := Nil
Local cLogFile   := ""
Local cListIdDcf := ""
Local nX         := 0
	If lIsJob
		// Seta job para nao consumir licensas
		RpcsetType(3)
		// Seta job para empresa filial desejadas
		RpcSetEnv(cEmpAmb,cFilAmb,cUsuario,/*cSenha*/,"WMS","WmsExeJob")
	EndIf
	// Integração com o WMS
	// Verifica as Ordens de servico geradas para execução automatica
	oOrdSerExe := WMSDTCOrdemServicoExecute():New()
	oRegraConv := WMSBCCRegraConvocacao():New()
	oOrdSerExe:SetArrLib(oRegraConv:GetArrLib())
	cListIdDcf := ""
	For nX := 1 To Len(aLibDCF)
		oOrdSerExe:SetIdDCF(aLibDCF[nX])
		If oOrdSerExe:LoadData()
			If (lContinua := oOrdSerExe:ExecuteDCF()) .And. oOrdSerExe:oServico:ChkSepara() .And. oOrdSerExe:GetOrigem() == "SC9"
				// Monta lista de ordem de serviço executada
				cListIdDcf += "'"+aLibDCF[nX]+"',"
			EndIf
		EndIf
		If !lContinua .And. lEncExe
			lRet := .F.
			Exit
		EndIf
	Next nX
	If lRet
		If !Empty(oRegraConv:GetArrLib())
			oRegraConv:LawExecute()
		EndIf
	EndIf
	// Verifica se há mensagem de inconsistência e o parâmetro de execução automática de separação completa
	If !Empty(oOrdSerExe:aWmsAviso) .And. lExAuSpCp .And. !Empty(cListIdDcf)
		// Ajusta lista de ordem de serviço executada
		cListIdDcf := SubsTr(cListIdDcf,1,Len(cListIdDcf)-1)
		oOrdSerRev := WMSDTCOrdemServicoReverse():New()
		oOrdSerRev:RevPedAut(cListIdDcf)
	EndIf
	// Verifica se ouve erro.
	If lIsJob .Or. IsTelNet() 
		If !Empty(oOrdSerExe:aWmsAviso)
			cLogFile := GravLogDiv(lIsJob, oOrdSerExe:aWmsAviso)
		EndIf
	EndIf
	If !lIsJob
		If !Empty(oOrdSerExe:aWmsAviso)
			If !IsTelNet()
				oOrdSerExe:ShowWarnig()
			Else
				VTDispFile(cLogFile,.T.)
				// Limpa as mensagens anteriores
				oOrdSerExe:aWmsAviso := {}
			EndIf
		EndIf
	EndIf
	If lIsJob
		RpcClearEnv()
	EndIf
Return lRet

/*
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Função     WmsExeDCF| Autor   Alex Egydio                 Data 16.11.2006 --
-------------------------------------------------------------------------------
-- Descrição   Execucao de servico do WMS                                    --
-------------------------------------------------------------------------------
-- Parametros  ExpC1 - Acao executada pela funcao.                           --
--                                                                           --
--                     1 = Execucao de servico do WMS.                       --
--                                                                           --
--                     2 = Executa a regra de convocacao e disponibiliza     --
--                         os registros do SDB para convocacao.              --
--                                                                           --
--                     3 = Redistribuir produtos no estorno do WMS.          --
--                         Gera uma O.S.WMS de entrada para redistribuir     --
--                         o produto.                                        --
--                                                                           --
--             ExpL1 - .T. = Executado pelo wmsxjob                          --
--             ExpL2 - .T. = Executa o ponto de entrada dlga150e             --
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------*/
Function WmsExeDCF(cAcao,lWmsJob,aRegSDB)
Local aAreaAnt  := GetArea()
Local aAreaDC5a := {}
Local aAreaSDB  := {}
Local aCarga    := {}
Local aTravas   := {}
Local aSrv      := {}
Local cFunExe   := ''
Local cSeek     := ''
Local cTrava    := ''
Local cCarga    := DCF->DCF_CARGA
Local cServic   := DCF->DCF_SERVIC
Local cDocto    := DCF->DCF_DOCTO
Local cSerie    := DCF->DCF_SERIE
Local cCliFor   := DCF->DCF_CLIFOR
Local cLoja     := DCF->DCF_LOJA
Local cProduto  := DCF->DCF_CODPRO
Local cUnitiz   := DCF->DCF_UNITIZ
Local cQuery    := ''
Local lFunExe   := .T.
Local lRet      := .T.
Local lRetPE    := .F.
Local nSemRegra := 0
Local lAviso    := .T.
Local n1Cnt     := 0
Local n2Cnt     := 0
Local nRegDCF   := 0
Local nSeek     := 0
Local nSaldoSBF := 0
Local lExibeMsg := WmsMsgExibe()
Local cPriori   := ""
Local cAgluExp  := SuperGetMV('MV_WMSACEX', .F., '0')
Local cAliasQry := ''
Local nQtdTotal := 0
Local nI        := 1
Local lWmsAviso := Type("aWmsAviso") == "A"
Local cRetPE    := ""

Default lWmsJob := .F.

If cAcao=='1'
	Private aAgluDCF  := {}
	Private aParam150 := Array(33)
	Private lExec150  := .T.
	//-------------------------------------------------------------------------
	//-- Defina as variaveis abaixo antes de executar a funcao wmsexedcf
	//-- Private aLibSDB := {}
	//-- Private aWmsAviso:= {}
	//-------------------------------------------------------------------------
	lRet := .T.
	nRegDCF := DCF->(Recno())
	//-- Inclui trava para uso exclusivo desta carga / documento
	If WMSTrava(1,@cTrava,DCF->DCF_CARGA,DCF->DCF_DOCTO,DCF->DCF_SERIE)
		//-- Executa os servicos
		If DC5->(DbSeek(cSeek:=xFilial('DC5')+DCF->DCF_SERVIC,.F.))
			If __lDLGA150E
				//-- Ponto de Entrada DLGA150E (Antes da Execucao do Servico)
				//-- Parametros Passados:
				//-- PARAMIXB[1] = Produto
				//-- PARAMIXB[2] = Local
				//-- PARAMIXB[3] = Documento
				//-- PARAMIXB[4] = Serie
				//-- PARAMIXB[5] = Recno no DCF
				lRetPE := ExecBlock("DLGA150E",.F.,.F.,{DCF->DCF_CODPRO,DCF->DCF_LOCAL,DCF->DCF_DOCTO,DCF->DCF_SERIE,nRegDCF})
				If ValType(lRetPE)=="L"
					lRet := lRetPE
				EndIf
			EndIf

			//-- Seta o Status do Servico para Interrompido
			DCF->(DbGoto(nRegDCF))
			DLA150Stat('2')

			If lRet
				//Seta para o WMS não exibir mensagens
				WmsMsgExibe(.F.)
				WmsMessage("","SIGAWMS",0,.F.) //Zerando as mensagens
				DbSelectArea('DC5')

				//Verifica se aglutina DCF
				If DC5->DC5_TIPO == '2' .And. WmsCarga(DCF->DCF_CARGA) .And. cAgluExp != '0'
					cQuery := " SELECT DCF_ID, DCF_QUANT, DCF_DOCTO, DCF_SERIE, DCF_CLIFOR, DCF_LOJA, DCF_NUMSEQ, R_E_C_N_O_ RECDCF"
					cQuery +=  " FROM "+RetSqlName('DCF')+" DCF"
					cQuery += " WHERE DCF_FILIAL = '"+DCF->DCF_FILIAL+"'"
					cQuery +=   " AND DCF_SERVIC = '"+DCF->DCF_SERVIC+"'"
					cQuery +=   " AND DCF_CARGA  = '"+DCF->DCF_CARGA +"'"
					cQuery +=   " AND DCF_LOCAL  = '"+DCF->DCF_LOCAL +"'"
					cQuery +=   " AND DCF_CODPRO = '"+DCF->DCF_CODPRO+"'"
					cQuery +=   " AND DCF_LOTECT = '"+DCF->DCF_LOTECT+"'"
					cQuery +=   " AND DCF_NUMLOT = '"+DCF->DCF_NUMLOT+"'"
					cQuery +=   " AND DCF_ENDER  = '"+DCF->DCF_ENDER +"'"
					If cAgluExp == '2' //Se aglutina por cliente
						cQuery += " AND DCF_CLIFOR = '"+DCF->DCF_CLIFOR+"'"
						cQuery += " AND DCF_LOJA   = '"+DCF->DCF_LOJA+"'"
					EndIf
					cQuery +=   " AND D_E_L_E_T_ = ' '"
					cQuery +=   " AND DCF_STSERV <> '3'"
					cQuery +=   " AND R_E_C_N_O_ <> "+AllTrim(Str(DCF->(Recno())))
					// PE para complemento da query de busca para aglutinação
					// de ordens de serviço provenientes de Montagem de Carga
					If __lWMSACEXP
						cRetPE := ExecBlock("WMSACEXP",.F.,.F.)
						If ValType(cRet) == "C"
							cQuery += cRetPE
						EndIf
					EndIf
					cQuery:= ChangeQuery(cQuery)
					cAliasQry := GetNextAlias()
					DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
					While (cAliasQry)->(!Eof())
						//-- Seta o Status do Servico para Interrompido
						DCF->(DbGoto((cAliasQry)->RECDCF))
						DLA150Stat('2')
						AAdd(aAgluDCF,{(cAliasQry)->DCF_ID,(cAliasQry)->DCF_QUANT,(cAliasQry)->RECDCF,{},(cAliasQry)->DCF_DOCTO,(cAliasQry)->DCF_SERIE,(cAliasQry)->DCF_CLIFOR,(cAliasQry)->DCF_LOJA,(cAliasQry)->DCF_NUMSEQ})
						(cAliasQry)->(dbSkip())
					EndDo
					(cAliasQry)->(DbCloseArea())

					//Força uma area ativa, para não ocorrer erros ao chamar a função Tabela()
					dbSelectArea("DCF")

					//Reposiciona na DCF corrente.
					DCF->(DbGoto(nRegDCF))

					//Incluí na primeira posição a DCF atual que está sendo processada
					If Len(aAgluDCF) > 0
						AAdd(aAgluDCF,{})
							aAgluDCF := AIns(aAgluDCF,1)
							aAgluDCF[1] := {DCF->DCF_ID,DCF->DCF_QUANT,DCF->(Recno()),{},DCF->DCF_DOCTO,DCF->DCF_SERIE,DCF->DCF_CLIFOR,DCF->DCF_LOJA,DCF->DCF_NUMSEQ}

							For nI := 1 To Len(aAgluDCF)
							nQtdTotal +=   aAgluDCF[nI][2]
						Next nI
					EndIf
				EndIf
				//Ordena o array pelo IDDCF
				ASort(aAgluDCF, , , {|x,y|x[1] < y[1]})

				While DC5->( !Eof() .And. DC5->DC5_FILIAL+DC5->DC5_SERVIC==cSeek .And. Iif(lWmsJob,!KillApp(),.T.) )
					//-- Seta o Status do Servico para Interrompido
					DCF->(DbGoto(nRegDCF))
					lExec150 := .T.

					//Reserva os campos para as quantidades das atividades
					If Len(aAgluDCF) > 0
						aAgluDCF := AEval( aAgluDCF, {|x| AAdd(x[4],{DC5->DC5_ORDEM,0,'',0}) })
					EndIf

					//-- Formato do Array aParam150, que sera utilizado para passar Parametros
					//-- a todas as funcoes cadastradas nas Tabelas executadas pela DLA150Serv.
					//--
					//-- aParam150[01] = Produto
					//-- aParam150[02] = Centro de Distribuicao Origem
					//-- aParam150[03] = Documento
					//-- aParam150[04] = Serie
					//-- aParam150[05] = Numero Sequencial
					//-- aParam150[06] = Quantidade a ser Movimentada
					//-- aParam150[07] = Data da Movimentacao
					//-- aParam150[08] = Hora da Movimentacao
					//-- aParam150[09] = Servico
					//-- aParam150[10] = Tarefa
					//-- aParam150[11] = Atividade
					//-- aParam150[12] = Cliente/Fornecedor
					//-- aParam150[13] = Loja
					//-- aParam150[14] = Tipo da Nota Fiscal
					//-- aParam150[15] = Item da Nota Fiscal
					//-- aParam150[16] = Tipo de Movimentacao
					//-- aParam150[17] = Origem de Movimentacao
					//-- aParam150[18] = Lote
					//-- aParam150[19] = Sub-Lote
					//-- aParam150[20] = Endereco Origem
					//-- aParam150[21] = Estrutura Fisica Origem
					//-- aParam150[22] = Regra de Apanhe (1=LOTE/2=NUMERO DE SERIE/3=DATA)
					//-- aParam150[23] = Codigo da Carga
					//-- aParam150[24] = Nr. do Pallet
					//-- aParam150[25] = Centro de Distribuicao Destino
					//-- aParam150[26] = Endereco Destino
					//-- aParam150[27] = Estrutura Fisica Destino
					//-- aParam150[28] = Ordem da Tarefa
					//-- aParam150[29] = Ordem da Atividade
					//-- aParam150[30] = Recurso Humano
					//-- aParam150[31] = Recurso Fisico
					//-- aParam150[32] = Identificador do DCF DCF_ID
					//-- aParam150[33] = Codigo da Norma informada no Docto de Entrada
					//-- aParam150[34] = Identificador exclusivo do Movimento no SDB
					aParam150      := Array(33)
					aParam150[01]  := DCF->DCF_CODPRO   //-- Produto
					aParam150[02]  := DCF->DCF_LOCAL    //-- Local Origem
					aParam150[03]  := DCF->DCF_DOCTO    //-- Documento
					aParam150[04]  := DCF->DCF_SERIE    //-- Serie
					aParam150[05]  := DCF->DCF_NUMSEQ   //-- Sequencial
					aParam150[06]  := IIf(nQtdTotal > 0,nQtdTotal,DCF->DCF_QUANT)  //-- Quantidade a ser Movimentada
					aParam150[07]  := dDataBase         //-- Data da Movimentacao
					aParam150[08]  := Time()            //-- Hora da Movimentacao
					aParam150[09]  := DC5->DC5_SERVIC   //-- Servico
					aParam150[10]  := DC5->DC5_TAREFA   //-- Tarefa
					aParam150[11]  := ''                //-- Atividade
					aParam150[12]  := DCF->DCF_CLIFOR   //-- Cliente/Fornecedor
					aParam150[13]  := DCF->DCF_LOJA     //-- Loja
					aParam150[14]  := ''                //-- Tipo da Nota Fiscal
					aParam150[15]  := '01'              //-- Item da Nota Fiscal
					aParam150[16]  := ''                //-- Tipo de Movimentacao
					aParam150[17]  := DCF->DCF_ORIGEM   //-- Origem de Movimentacao
					aParam150[18]  := DCF->DCF_LOTECT   //-- Lote
					aParam150[19]  := DCF->DCF_NUMLOT   //-- Sub-Lote
					aParam150[20]  := DCF->DCF_ENDER    //-- Endereco
					aParam150[21]  := DCF->DCF_ESTFIS   //-- Estrutura Fisica
					aParam150[22]  := Val(DCF->DCF_REGRA)//-- Regra de Apanhe (1=LOTE/2=NUMERO DE SERIE/3=DATA)
					aParam150[23]  := DCF->DCF_CARGA    //-- Carga
					aParam150[24]  := DCF->DCF_UNITIZ   //-- Nr. do Pallet
					aParam150[25]  := DCF->DCF_LOCAL    //-- Local Destino
					aParam150[26]  := DCF->DCF_ENDER    //-- Endereco Destino
					aParam150[27]  := DCF->DCF_ESTFIS   //-- Estrutura Fisica Destino
					aParam150[28]  := DC5->DC5_ORDEM    //-- Ordem da Tarefa
					aParam150[29]  := ''                //-- Ordem da Atividade
					aParam150[30]  := ''                //-- Recurso Humano
					aParam150[31]  := ''                //-- Recurso Fisico
					aParam150[32]  := DCF->DCF_ID    //-- Identificador do DCF
					aParam150[33]  := DCF->DCF_CODNOR      //-- Identificador do DCF
					//-- Executa as Tarefas (SX5 - Tab L6) Referentes ao Servico  (DC5)  ou
					//-- Executa as Atividades referentes a Tarefa (DC6)
					If !Empty(cFunExe:=AllTrim(Tabela('L6',DC5->DC5_FUNEXE,.F.)))
						aAreaDC5a   := DC5->(GetArea())
						cFunExe     += If(!('('$cFunExe),'()','')
						cFunExe     := StrTran(cFunExe,'"',"'")
						lFunExe     := &(cFunExe)

						lFunExe   := If(!(lFunExe==NIL).And.ValType(lFunExe)=='L', lFunExe, lExec150)
						If !lFunExe
							If lWmsAviso
								WmsAviso(WmsLastTit(),WmsLastMsg())
							Else
								WmsMessage(WmsLastMsg(),WmsLastTit(),WmsMsgType(),lExibeMsg)
							EndIf
							Exit
						EndIf
						RestArea(aAreaDC5a)
					ElseIf DLXExecAti(DC5->DC5_TAREFA, aParam150)
						If lExec150
							//-- Atualiza Status do Servico para Executado
							DCF->(DbGoto(nRegDCF))
							DLA150Stat('3')
							DLA150Carga(cCarga,aCarga)
						Else
							Exit
						EndIf
					EndIf
					DbSelectArea('DC5')
					DC5->(DbSkip())
				EndDo
				If lFunExe
					//-- Atualiza Status do Servico para Executado
					If Len(aAgluDCF) > 0
						For nI := 1 To Len(aAgluDCF)
							DCF->(DbGoto(aAgluDCF[nI][3]))
							DLA150Stat('3')
						Next nI
					Else
						DCF->(DbGoto(nRegDCF))
						DLA150Stat('3')
					EndIf
					DLA150Carga(cCarga,aCarga)
				EndIf
				//Recuperar o valor para o WMS exibir mensagens
				WmsMsgExibe(lExibeMsg)
			EndIf
		EndIf
		//-- Retira trava para liberar uso desta carga / documento
		WMSTrava(0,cTrava)
	EndIf

ElseIf cAcao=='2'
	If !Empty(aLibSDB)
		//-- Refaz regra de sequencia caso execucao de servico anterior interrompido.
		WmsRegra('8')
		//-- Executa regras para convocacao do servico
		For n1Cnt := 1 To Len(aLibSDB)
			If ASCan(aSrv,{|x| x[1]+x[2] == aLibSDB[n1Cnt,3]+aLibSDB[n1Cnt,4] })==0
				AAdd(aSrv,{aLibSDB[n1Cnt,3],aLibSDB[n1Cnt,4]})
				WmsRegra('5',aLibSDB[n1Cnt,3],,aLibSDB[n1Cnt,4],,,,,,,,,,,,@cPriori)
				nSemRegra := 0
				AEval(aLibSDB,{|x| Iif(Len(x) < 5,nSemRegra++,/*Não faz nada*/)})
				If nSemRegra > 0
					WmsRegra('7',aLibSDB[n1Cnt,3],,aLibSDB[n1Cnt,4],,,,,,,,,,,,cPriori)
				EndIf
			EndIf
		Next
		If __lWMSALIB
			ExecBlock("WMSALIB",.F.,.F.)
		EndIf
		aSort(aLibSDB,,, {|x,y| Iif(Len(x)>4 .And. Len(y)>4,x[5]<y[5],.T.)})
		//-- Disponibiliza registros do SDB para convocacao
		DbSelectArea('SDB')
		DbSetOrder(1)
		For n1Cnt := 1 To Len(aLibSDB)
			SDB->(DbGoTo(aLibSDB[n1Cnt,2]))
			If SDB->(!Eof())
				RecLock('SDB',.F.)
				SDB->DB_STATUS := aLibSDB[n1Cnt,1]
				If SDB->DB_STATUS == '2'
					SDB->DB_OCORRE := '9999' // Indica que é dependente de reabastecimento
				EndIf
				SDB->(MsUnlock())
			EndIf
		Next
		//-- Refaz regra de limite (DCQ_DOCEXC) caso execucao de servico anterior interrompido.
		WmsRegra('9')
	EndIf
	//-- Ponto de entrada para inibir mensagens
	If __lWMSAVISO
		lAviso := ExecBlock("WMSAVISO",.F.,.F.)
		lAviso := If(ValType(lAviso)=="L",lAviso,.T.)
	EndIf
	//-- Apresenta mensagens
	If lAviso
		WmsAviso(,,'2')
	EndIf

ElseIf cAcao=='3'
EndIf
RestArea(aAreaAnt)
Return(lRet)



/*
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Função     WmsAtzSDB| Autor   Alex Egydio                 Data 27.03.2007 --
-------------------------------------------------------------------------------
-- Descrição   Diversas manipulacoes no arquivo de movimentos SDB.           --
-------------------------------------------------------------------------------
-- Parametros  ExpC1 - 1 = Se a quantidade selecionada pelo operador for     --
--                         menor que a quantidade do SDB e o parametro       --
--                         MV_RFNNORM igual a .T., o SDB sera desmembrado.   --
--                         Executado pelo programa DLGV080 e solicitado pelo --
--                         cliente CHG, quando o operador nao conseguir      --
--                         movimentar de uma so vez a qtde total do endereco --
--                         origem para o endereco destino.                   --
--                     2 = Solicita o dispositivo de movimentacao (CARRINHO) --
--                         Executado pelo programa DLGV030 e solicitado pelo --
--                         cliente CHG.                                      --
--                     3 = Gera movimentos no SDB para apanhe utilizando     --
--                         dispositivo de movimentacao (CARRINHO)            --
--                         Executado pelo programa DLGV030 e solicitado pelo --
--                         cliente CHG.                                      --
--                     4 = Solicita etiqueta qd produto a granel             --
--                     5 = Grava etiqueta no arq. CB0 qd produto a granel    --
--                     6 = Retira o status de faturado no estorno da fatura  --
--             ExpN1 - Quantidade movimentada pelo operador de -RF-          --
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------*/
Function WmsAtzSDB(cAcao,nQtde,cDispMov,cEstDMov,cCodEtq1)
Local aAreaAnt := GetArea()
Local aAreaSDB := SDB->(GetArea())
Local aTelaAnt := {}
Local cAliasSDB   := ''
Local cCarga   := ''
Local cIdDCF   := ''
Local cDocto   := ''
Local cSerie   := ''
Local cCliFor  := ''
Local cLoja    := ''
Local cServic  := ''
Local cArmazem := ''
Local cProduto := ''
Local cLoteCTL := ''
Local cEndDes  := ''
Local cEstDes  := ''
Local cPriori  := ''
Local cSeqPri  := ''
Local cRecHum  := ''
Local cEtqAnt  := ''
Local cQuery   := ''
Local nDif     := 0
Local lLote    := .F.
Local lSLote   := .F.
Local lRet     := .F.
Local nQtde2UM := 0
Local nRecnoSDB:= 0
Local cStatExec := SuperGetMV('MV_RFSTEXE', .F., '1') //-- DB_STATUS indicando Atividade Executada

If cAcao=='1'

	lRet := .T.
	//-- Utilizado pelo programa DLGV080
	nDif     := SDB->DB_QUANT - nQtde
	nQtde2UM := ConvUm(SDB->DB_PRODUTO,nQtde,0,2)
	cPriori  := SDB->DB_PRIORI
	cSeqPri  := SDB->DB_SEQPRI
	//-- Atualiza o sdb posicionado com a quantidade informada pelo operador.
	RecLock('SDB',.F.)
	SDB->DB_QUANT   := nQtde
	SDB->DB_QTSEGUM := nQtde2UM
	MsUnLock()
	//-- Atualiza o DCR referente ao SDB posicionado
	lRet := WmsAtzDCR(SDB->DB_IDDCF,SDB->DB_IDMOVTO,SDB->DB_IDOPERA,SDB->DB_QUANT,SDB->DB_QTSEGUM)
	If lRet
		//-- Cria novo SDB com o restante da quantidade para posterior convocacao pelo radio frequencia.
		CriaSDB(SDB->DB_PRODUTO,SDB->DB_LOCAL,nDif ,SDB->DB_LOCALIZ,SDB->DB_NUMSERI,SDB->DB_DOC,SDB->DB_SERIE,SDB->DB_CLIFOR,SDB->DB_LOJA,SDB->DB_TIPONF,SDB->DB_ORIGEM,SDB->DB_DATA,SDB->DB_LOTECTL,SDB->DB_NUMLOTE,SDB->DB_NUMSEQ,SDB->DB_TM,SDB->DB_TIPO,SDB->DB_ITEM,.F.     ,Nil    ,Nil      ,Nil      ,SDB->DB_ESTFIS,SDB->DB_SERVIC,SDB->DB_TAREFA,SDB->DB_ATIVID,Nil/*Anomalia*/,SDB->DB_ESTDES,SDB->DB_ENDDES,Time()   ,'N'    ,SDB->DB_CARGA,SDB->DB_UNITIZ,SDB->DB_ORDTARE,SDB->DB_ORDATIV,SDB->DB_RHFUNC,SDB->DB_RECFIS,SDB->DB_SEQCAR,SDB->DB_IDDCF,@nRecnoSDB,SDB->DB_IDMOVTO)
		RecLock('SDB',.F.)
		SDB->DB_PRIORI := cPriori
		SDB->DB_SEQPRI := cSeqPri
		MsUnLock()
		//-- Seta o SDB para ser convocado logo em seguida do movimento dividido
		DLVConvSDB(nRecnoSDB)
	EndIf

ElseIf cAcao=='2'

	If ( DLTipoEnd(SDB->DB_ESTFIS) != 7 .And. DLTipoEnd(SDB->DB_ESTDES) != 7 )
		aTelaAnt := VTSave(00, 00, VTMaxRow(), VTMaxCol())
		//-- Solicita o dispositivo movel ( CARRINHO )
		cDispMov := Space(Len(SBE->BE_LOCALIZ))
		DLVTCabec(,.F.,.F.,.T.)
		@ 02, 00 VTSay PadR(STR0037, VTMaxCol()) //'Dispositivo Móvel'
		@ 03, 00 VTGet cDispMov Pict '@!' Valid WmsVldDisp(SDB->DB_LOCAL,cDispMov,@cEstDMov) When VTLASTKEY()==05 .Or. Empty(cDispMov)
		VTRead
		If (VTLastKey() == 27)
			cDispMov := Space(Len(SBE->BE_LOCALIZ))
			cEstDMov := Space(Len(SBE->BE_ESTFIS))
		EndIf
		VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
	EndIf

ElseIf cAcao=='3'

	If ( !Empty(cDispMov) .And. !Empty(cEstDMov) .And. DLTipoEnd(SDB->DB_ESTFIS) != 7 )
		cEndDes := SDB->DB_ENDDES
		cEstDes := SDB->DB_ESTDES
		cPriori := SDB->DB_PRIORI
		cRecHum  := SDB->DB_RECHUM
		//-- Registro original de saida.
		//-- A010 ==> DOCA

		//-- Se informar o dispositivo de movimentacao o SDB sera desmembrado da seguinte forma:
		//-- A010      ==> CARRINHO
		//-- CARRINHO  ==> DOCA

		RecLock('SDB',.F.)
		SDB->DB_ENDDES := cDispMov
		SDB->DB_ESTDES := cEstDMov
		MsUnLock()

		CriaSDB(SDB->DB_PRODUTO,SDB->DB_LOCAL,SDB->DB_QUANT,cDispMov,SDB->DB_NUMSERI,SDB->DB_DOC,SDB->DB_SERIE,SDB->DB_CLIFOR,SDB->DB_LOJA,SDB->DB_TIPONF,SDB->DB_ORIGEM,SDB->DB_DATA,SDB->DB_LOTECTL,SDB->DB_NUMLOTE,SDB->DB_NUMSEQ,SDB->DB_TM,SDB->DB_TIPO,SDB->DB_ITEM,.F.,Nil,Nil,Nil,cEstDMov,SDB->DB_SERVIC,SDB->DB_TAREFA,SDB->DB_ATIVID,'N',cEstDes,cEndDes,Time(),'N',SDB->DB_CARGA,SDB->DB_UNITIZ,SDB->DB_ORDTARE,'01',SDB->DB_RHFUNC,SDB->DB_RECFIS,,SDB->DB_IDDCF,,SDB->DB_IDMOVTO)
		RecLock('SDB',.F.)
		SDB->DB_PRIORI := 'ZZ'+SUBSTRING(SDB->DB_PRIORI,3,Len(SDB->DB_PRIORI))
		SDB->DB_RECHUM := cRecHum
		MsUnLock()
	EndIf

ElseIf cAcao=='4'

	//-- Produto a granel
	//-- O conteudo de B5_TIPUNIT indica se o produto e a granel ou nao.
	//-- Se o conteudo for igual a zero o produto eh a granel.
	//-- Solicita a leitura da etiqueta avulsa
	If Iif(FindFunction('UsaCB0'),UsaCB0('01'),.F.) .And. !CBProdUnit(SDB->DB_PRODUTO)
		aTelaAnt := VTSave(00, 00, VTMaxRow(), VTMaxCol())
		cEtqAnt := cCodEtq1
		cCodEtq1 := Space(10)
		DLVTCabec(,.F.,.F.,.T.)
		@ 02, 00 VTSay PadR(STR0038, VTMaxCol()) //'Etiqueta'
		@ 03, 00 VTGet cCodEtq1 Pict '@!' Valid WmsVldEtq(cCodEtq1) When VTLASTKEY()==05 .Or. Empty(cCodEtq1)
		VTRead
		If (VTLastKey() == 27)
			cCodEtq1 := cEtqAnt
		Else
			lRet:=.T.
		EndIf
		VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
	EndIf

ElseIf cAcao=='5'

	//-- Produto a granel grava etiqueta avulsa
	If !Empty(cCodEtq1) .And. nQtde > 0
		CBGrvEti('01',{SDB->DB_PRODUTO,nQtde,SDB->DB_RECHUM,,,,,,SDB->DB_LOCALIZ,SDB->DB_LOCAL,,SDB->DB_NUMSEQ,,,,SDB->DB_LOTECTL,SDB->DB_NUMLOTE,,,,SDB->DB_UNITIZ,,SDB->DB_NUMSERI,SDB->DB_ORIGEM},cCodEtq1)
	EndIf

ElseIf cAcao=='6'
	//-- Utilizado pelo programa MATA521 funcao MaDelNfs.
	//-- Ao estornar uma fatura retirar a marca de faturado dos registros do SDB.
	//-- O SC9 ja esta posicionado.
	cCarga   := PadR(SC9->C9_CARGA  ,Len(SDB->DB_CARGA))
	cDocto   := PadR(SC9->C9_PEDIDO ,Len(SDB->DB_DOC))
	cSerie   := PadR(SC9->C9_ITEM   ,Len(SDB->DB_SERIE))
	cCliFor  := PadR(SC9->C9_CLIENTE,Len(SDB->DB_CLIFOR))
	cLoja := PadR(SC9->C9_LOJA   ,Len(SDB->DB_LOJA))
	cServic  := PadR(SC9->C9_SERVIC ,Len(SDB->DB_SERVIC))
	cIdDCF   := SC9->C9_IDDCF
	cArmazem:= PadR(SC9->C9_LOCAL  ,Len(SDB->DB_LOCAL))
	cProduto:= PadR(SC9->C9_PRODUTO,Len(SDB->DB_PRODUTO))
	cLoteCTL:= PadR(SC9->C9_LOTECTL,Len(SDB->DB_LOTECTL))
	cNumLote:= PadR(SC9->C9_NUMLOTE,Len(SDB->DB_NUMLOTE))
	lLote := Rastro(cProduto)
	lSLote   := Rastro(cProduto,'S')
	DbSelectArea('SDB')

	cAliasSDB := GetNextAlias()
	cQuery := "SELECT R_E_C_N_O_ RECSDB"
	cQuery += " FROM"
	cQuery += " "+RetSqlName('SDB')+" SDB"
	cQuery += " WHERE"
	cQuery += " DB_FILIAL = '"+xFilial("SDB")+"'"
	cQuery += " AND DB_ATUEST  = 'N'"
	cQuery += " AND DB_SERVIC  = '"+cServic+"'"
	If !Empty(cIdDCF)
		cQuery += " AND DB_IDDCF = '"+cIdDCF+"'"
	EndIf
	If Empty(cCarga)
		cQuery += " AND DB_DOC    = '"+cDocto+"'"
		cQuery += " AND DB_SERIE  = '"+cSerie+"'"
		cQuery += " AND DB_CLIFOR = '"+cCliFor+"'"
		cQuery += " AND DB_LOJA   = '"+cLoja+"'"
	Else
		cQuery += " AND DB_CARGA  = '"+cCarga+"'"
	EndIf
	cQuery += " AND DB_LOCAL   = '"+cArmazem+"'"
	cQuery += " AND DB_PRODUTO = '"+cProduto+"'"
	//-- Somente movimentos referente a carga/documentos faturados
	cQuery += " AND DB_STATUS  = 'F'"
	cQuery += " AND SDB.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasSDB,.F.,.T.)

	While (cAliasSDB)->(!Eof())
		SDB->(MsGoTo((cAliasSDB)->RECSDB))
		If Iif(lLote  .And. !Empty(SDB->DB_LOTECTL) .And. !Empty(cLoteCTL),SDB->DB_LOTECTL == cLoteCTL,.T.) .And.;
			Iif(lSLote .And. !Empty(SDB->DB_NUMLOTE) .And. !Empty(cNumLote),SDB->DB_NUMLOTE == cNumLote,.T.) .And.;
			RecLock('SDB',.F.)
			SDB->DB_STATUS  := cStatExec
			MsUnLock()
		EndIf
		(cAliasSDB)->(DbSkip())
	EndDo

	DbSelectarea(cAliasSDB)
	DbCloseArea()
	RestArea(aAreaAnt)

EndIf
//-- Favor nao alterar!!!
//-- Eh obrigatorio q saia da funcao posicionado no registro contido no vetor aAreaSDB!!!
RestArea(aAreaSDB)
Return(lRet)
/*
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Função     WmsVldDisp| Autor   Alex Egydio                 Data 27.03.2007 --
-------------------------------------------------------------------------------
-- Descrição   Valida codigo do endereco.                                    --
-------------------------------------------------------------------------------
-- Parametros  ExpC1 - Armazem                                               --
--             ExpC2 - Endereco                                              --
--             ExpC3 - Estrutura Fisica                                 (@)  --
--             ExpL1 - .T. = Emite aviso para radio frequencia               --
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------*/
Function WmsVldDisp(cArmazem,cEndereco,cEstrutura,lHelp)
Local lRet := .T.
Default lHelp := .T.
If !Empty(cEndereco)
	SBE->(DbSetOrder(1))
	If SBE->(MsSeek(xFilial('SBE')+cArmazem+cEndereco))
		cEstrutura := SBE->BE_ESTFIS
	Else
		If lHelp
			DLAviso(,'WMSXFUNA06',STR0039) //'Dispositivo nao encontrado...'
			VTKeyBoard(chr(20))
		EndIf
		cEstrutura := Space(Len(SBE->BE_ESTFIS))
		lRet := .F.
	EndIf
EndIf
Return(lRet)
/*
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Função     WmsVldEtq| Autor   Alex Egydio                 Data 04.12.2007 --
-------------------------------------------------------------------------------
-- Descrição   Valida a etiqueta.                                            --
-------------------------------------------------------------------------------
-- Parametros  ExpC1 - Etiqueta                                              --
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------*/
Function WmsVldEtq(cCodEtq,lHelp)
Local aAreaAnt := GetArea()
Local lRet     := Empty(CBRetEti(cCodEtq,'01'))

Default lHelp  := .T.

If !lRet .And. lHelp
	DLAviso(,'WMSXFUNA36',STR0040) //'Etiqueta ja informada!'
	VTKeyBoard(chr(20))
EndIf

RestArea(aAreaAnt)
Return(lRet)
/*
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Função     WmsAtzSD3| Autor   Alex Egydio                 Data 23.05.2007 --
-------------------------------------------------------------------------------
-- Descrição   Atualizacoes no arquivo SD3.                                  --
-------------------------------------------------------------------------------
-- Parametros  ExpC1 - Documento                                             --
--             ExpC2 - Produto                                               --
--             ExpC3 - Sequencia                                             --
--             ExpN1 - Tipo movimento:                                       --
--                     1 = Enderecamento                                     --
--                     2 = Apanhe                                            --
--                     3 = Reabastecimento                                   --
--             ExpN2 - Quantidade                                            --
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------*/
Function WmsAtzSD3(cDocto,cProduto,cNumSeq,nTipoTr,nQtde)
Local aAreaAnt  := GetArea()
Local aAreaSD3  := SD3->(GetArea())
Local cAliasSD3 := ''
Local cQuery    := ''

	cAliasSD3 := GetNextAlias()
	cQuery := "SELECT R_E_C_N_O_ RECSD3"
	cQuery +=  " FROM "+RetSqlName('SD3')+" SD3"
	cQuery += " WHERE SD3.D3_FILIAL  = '"+xFilial("SD3")+"'"
	cQuery +=   " AND SD3.D3_DOC     = '"+cDocto+"'"
	cQuery +=   " AND SD3.D3_COD     = '"+cProduto+"'"
	cQuery +=   " AND SD3.D3_ESTORNO = ' '"
	cQuery +=   " AND SD3.D3_TM      > '500'"
	cQuery +=   " AND SD3.D3_NUMSEQ  = '"+cNumSeq+"'"
	cQuery +=   " AND SD3.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSD3,.F.,.T.)

	While (cAliasSD3)->(!Eof())
		SD3->(MsGoTo((cAliasSD3)->RECSD3))
		If Substr(SD3->D3_CF,3,1)<>'4'
			RecLock('SD3',.F.)
			If nTipoTr == 1
				//-- Soma a Quantidade Transferida ao Movimento
				SD3->D3_QUANT += nQtde
			ElseIf nTipoTr == 2
				//-- Subtrai a Quantidade Transferida ao Movimento
				SD3->D3_QUANT -= nQtde
			EndIf
			SD3->D3_ESTORNO := Iif(SD3->D3_QUANT>0,' ','S')
			SD3->(MsUnlock())
			Exit
		EndIf
		(cAliasSD3)->(DbSkip())
	EndDo
	(cAliasSD3)->(DbCloseArea())

RestArea(aAreaSD3)
RestArea(aAreaAnt)
Return NIL
/*
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Função     WmsAviso | Autor   Alex Egydio                 Data 23.05.2007 --
-------------------------------------------------------------------------------
-- Descrição   Apresenta mensagens do WMS                                    --
-------------------------------------------------------------------------------
-- Parametros  ExpC1 - Codigo da mensagem                                    --
--             ExpC2 - Mensagem                                              --
--             ExpC3 - Acao da funcao:                                       --
--                     1 = Verifica se existe o vetor aWmsAviso e adiciona   --
--                         a mensagem no vetor.                              --
--                     2 = Apresenta a tela com as mensagens.                --
--                     3 = Se o vetor aWmsAviso estiver VAZIO e o WMS nao    --
--                         conseguiu executar o servico, apresenta uma       --
--                         mensagem com as possiveis causas.                 --
--             ExpC4 - Tipo da estrutura fisica (somente para cAcao=3)       --
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------*/
Function WmsAviso(cCodMsg,cMsg,cAcao)
Local lRet     := .T.
Local nCntFor  := 0
Local cMemo    := ""
Local cFile    := ""
Local cMask    := STR0069 //"Arquivos Texto (*.TXT) |*.txt|"
Local cTitle   := STR0070 //"Salvar como..."
Default cAcao  := '1'
//-- Mensagens durante o processamento do servico do wms.
If Type('aWmsAviso')=='A'
	//-- Formato do vetor aWmsAviso
	//-- [01] = Codigo da mensagem
	//-- [02] = Mensagem
	//-- [03] = .T./.F. = Ativa/Desativa a Mensagem
	If cAcao == '1'
		AAdd(aWmsAviso,cMsg)
	ElseIf cAcao == '2'
		If !Empty(aWmsAviso)
			For nCntFor := 1 To Len(aWmsAviso)
				If nCntFor == 1
					cMemo := aWmsAviso[nCntFor]
				Else
					cMemo += CLRF+aWmsAviso[nCntFor]
				EndIf
			Next
			If WmsLogEnd()
				cMemo += CLRF+Replicate('*',90)
				cMemo += CLRF+STR0067 //"Para ordens de serviço de endereçamento com problemas, execute manual as ordens de serviço interrompidas e analise o relatório de busca de endereço."
			EndIf
			If WmsLogSld()
				cMemo += CLRF+Replicate('*',90)
				cMemo += CLRF+STR0068 //"Para ordens de serviço de expedição com problemas, execute manual as ordens de serviço interrompidas e analise o relatório de busca de saldo."
			EndIf
			DEFINE FONT oFont NAME "Courier New" SIZE 5,0   //6,15

			DEFINE MSDIALOG oDlg TITLE "SIGAWMS" From 3,0 to 340,417 PIXEL

			@ 5,5 GET oMemo  VAR cMemo MEMO SIZE 200,145 OF oDlg PIXEL
			oMemo:bRClicked := {||AllwaysTrue()}
			oMemo:oFont:=oFont

			DEFINE SBUTTON  FROM 153,175 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL //Apaga
			DEFINE SBUTTON  FROM 153,145 TYPE 13 ACTION (cFile:=cGetFile(cMask,cTitle),If(cFile="",.T.,MemoWrite(cFile,cMemo)),oDlg:End()) ENABLE OF oDlg PIXEL //Salva e Apaga //"Salvar Como..."

			ACTIVATE MSDIALOG oDlg CENTER
			//-- Limpa as mensagens anteriores
			aWmsAviso := {}
		EndIf
		If !IsInCallStack('DLGA150')
			WmsLogEnd(.F.)
			WmsLogSld(.F.)
		EndIf
	ElseIf cAcao == '3'
		//-- Não faz nada
	EndIf
Else
	lRet := .F.
EndIf
Return(lRet)

/*
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Função      WmsData | Autor   Alex Egydio                 Data 12.12.2007 --
-------------------------------------------------------------------------------
-- Descrição   Retorna data inicial para analise dos movimentos de -RF-      --
-------------------------------------------------------------------------------
-- Parametros                                                                --
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------*/
Static dRet := Nil 
Function WmsData()
	If dRet == Nil
		dRet := MVUlmes()
	EndIf
	//-- Determina a data inicial para analise dos movimentos SDB
	dRet := SuperGetMV('MV_WMSDINI',.F.,dRet)
Return(dRet)
/*
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Função     WmsChkSBE| Autor   Alex Egydio                 Data 10.01.2008 --
-------------------------------------------------------------------------------
-- Descrição  Verifica se o endereço possui saldo ou movimentações pendentes --
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------*/
Function WmsChkSBE(cArmazem,xComp1,xComp2,cEstFis,xComp3,xComp4,xComp5,xComp6,xComp7,xComp8,cEndereco)
Local lRet      := .F.
Local aAreaAnt  := GetArea()
Local cQuery    := ""
Local cAliasQry := ""

	If !SuperGetMV("MV_WMSNEW", .F., .F.)
		//-- Verifica se possui saldo por endereço
		cAliasQry := GetNextAlias()
		cQuery := "SELECT DISTINCT 1 "
		cQuery +=  " FROM "+RetSqlName('SBF')+" SBF"
		cQuery += " WHERE BF_FILIAL  = '"+xFilial('SBF')+"'"
		cQuery +=   " AND BF_LOCAL   = '"+cArmazem+"'"
		cQuery +=   " AND BF_LOCALIZ = '"+cEndereco+"'"
		cQuery +=   " AND BF_ESTFIS  = '"+cEstFis+"'"
		cQuery +=   " AND BF_QUANT   > 0"
		cQuery +=   " AND SBF.D_E_L_E_T_=' '"
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
		lRet := (cAliasQry)->(!Eof())
		(cAliasQry)->(DbCloseArea())

		//-- Verifica se possui movimentação pendente para o endereço
		If !lRet
			cAliasQry := GetNextAlias()
			cQuery := "SELECT DISTINCT 1 "
			cQuery +=  " FROM "+RetSqlName('SDB')+" SDB"
			cQuery += " WHERE DB_FILIAL  = '"+xFilial('SDB')+"'"
			cQuery +=   " AND DB_ESTORNO = ' '"
			cQuery +=   " AND DB_ATUEST  = 'N'"
			cQuery +=   " AND DB_LOCAL   = '"+cArmazem+"'"
			cQuery +=   " AND DB_ENDDES  = '"+cEndereco+"'"
			cQuery +=   " AND DB_ESTDES  = '"+cEstFis+"'"
			cQuery +=   " AND DB_STATUS IN ('-','3','2','4')"
			cQuery +=   " AND SDB.D_E_L_E_T_  = ' '"
			DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
			lRet := (cAliasQry)->(!Eof())
			(cAliasQry)->(DbCloseArea())
		EndIf
	Else
		//-- Verifica se possui saldo por endereço
		cAliasQry := GetNextAlias()
		cQuery := "SELECT DISTINCT 1 "
		cQuery +=  " FROM "+RetSqlName('D14')+" D14"
		cQuery += " WHERE D14_FILIAL = '"+xFilial('D14')+"'"
		cQuery +=   " AND D14_LOCAL  = '"+cArmazem+"'"
		cQuery +=   " AND D14_ENDER  = '"+cEndereco+"'"
		cQuery +=   " AND D14_ESTFIS = '"+cEstFis+"'"
		cQuery +=   " AND (D14_QTDEST+D14_QTDEPR) > 0"
		cQuery +=   " AND D14.D_E_L_E_T_ = ' '"
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
		lRet := (cAliasQry)->(!Eof())
		(cAliasQry)->(DbCloseArea())
	EndIf
RestArea(aAreaAnt)
Return(lRet)

/*
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Função     WmsChkDCP| Autor   Alex Egydio                 Data 07.10.2008 --
-------------------------------------------------------------------------------
-- Descrição   Verifica se ha percentual de ocupacao                         --
-------------------------------------------------------------------------------
-- Parametros  ExpC1 - Armazem                                               --
--             ExpC2 - Endereco                                              --
--             ExpC3 - Estrutura                                             --
--             ExpC4 - Norma                                                 --
--             ExpC5 - Produto                                               --
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------*/
Function WmsChkDCP(cArmazem,cEndereco,cEstFis,cNorma,cProduto,nTipoPerc)
Local aAreaAnt := GetArea()
Local aAreaDCP := DCP->(GetArea())
Local cVzProd  := Space(Len(DCP->DCP_CODPRO))
Local lRet     := .F.

If nTipoPerc != Nil
	nTipoPerc := 0
EndIf
//-- Existe percentual de ocupacao para o produto ou para produto em branco
DCP->(DbSetOrder(1))
If DCP->(DbSeek(xFilial('DCP')+cArmazem+cEndereco+cEstFis+cNorma+cProduto))
	lRet := .T.
	If nTipoPerc != Nil
		nTipoPerc := 1
	EndIf
EndIf
If !lRet
	If DCP->(DbSeek(xFilial('DCP')+cArmazem+cEndereco+cEstFis+cNorma+cVzProd))
		lRet := .T.
		If nTipoPerc != Nil
			nTipoPerc := 2
		EndIf
	EndIf
EndIf

RestArea(aAreaDCP)
RestArea(aAreaAnt)
Return(lRet)

//----------------------------------------------------------
/*/{Protheus.doc} WmsVolEmb
Cria os registros de montagem de volume a partir dos
movimentos de separação

@author  Guilherme A. Metzger
@version P12
@since   31/01/2017
/*/
//----------------------------------------------------------
Function WmsVolEmb(cCarga,cPedido,cProduto,cLote,cSubLote,cTarefa,nQtdSepa,cLibPed,cIdDCF)
Local oMntVolItem := Nil
Local nQtdOri     := 0
Local cQuery      := ""
Local cAliasQry   := ""

	oMntVolItem := WMSDTCMontagemVolumeItens():New()
	oMntVolItem:SetCarga(cCarga)
	oMntVolItem:SetPedido(cPedido)
	oMntVolItem:SetPrdOri(cProduto)
	oMntVolItem:SetProduto(cProduto)
	oMntVolItem:SetLoteCtl(cLote)
	oMntVolItem:SetNumLote(cSubLote)
	oMntVolItem:SetLibPed(cLibPed)
	oMntVolItem:SetIdDCF(cIdDCF)
	oMntVolItem:SetMntExc("2") // Mantém fixa a regra de montagem exclusiva por pedido
	// Busca o código da montagem de volume
	oMntVolItem:SetCodMnt(oMntVolItem:oMntVol:FindCodMnt())
	// Calcula a quantidade original do produto
	cQuery := "SELECT SUM(DCR.DCR_QUANT) QTDORI"
	cQuery +=  " FROM "+RetSqlName('DCF')+" DCF,"
	cQuery +=           RetSqlName('SDB')+" SDB,"
	cQuery +=           RetSqlName('DCR')+" DCR"
	cQuery += " WHERE DCF.DCF_FILIAL = '"+xFilial('DCF')+"'"
	cQuery +=   " AND DCF.DCF_CARGA  = '"+cCarga+"'"
	cQuery +=   " AND DCF.DCF_DOCTO  = '"+cPedido+"'"
	cQuery +=   " AND DCF.D_E_L_E_T_ = ' '"
	cQuery +=   " AND SDB.DB_FILIAL  = '"+xFilial('SDB')+"'"
	cQuery +=   " AND SDB.DB_PRODUTO = '"+cProduto+"'"
	cQuery +=   " AND SDB.DB_LOTECTL = '"+cLote+"'"
	cQuery +=   " AND SDB.DB_NUMLOTE = '"+cSubLote+"'"
	cQuery +=   " AND SDB.DB_TAREFA  = '"+cTarefa+"'"
	cQuery +=   " AND SDB.DB_SERVIC  = DCF.DCF_SERVIC"
	cQuery +=   " AND SDB.DB_ESTORNO = ' '"
	cQuery +=   " AND SDB.DB_ATUEST  = 'N'"
	cQuery +=   " AND SDB.DB_ORDATIV = (SELECT MAX(DB_ORDATIV) "
	cQuery +=                           " FROM "+RetSqlName('SDB')+" SDBM"
	cQuery +=                          " WHERE SDBM.DB_FILIAL  = SDB.DB_FILIAL"
	cQuery +=                            " AND SDBM.DB_PRODUTO = SDB.DB_PRODUTO"
	cQuery +=                            " AND SDBM.DB_DOC     = SDB.DB_DOC"
	cQuery +=                            " AND SDBM.DB_SERIE   = SDB.DB_SERIE"
	cQuery +=                            " AND SDBM.DB_CLIFOR  = SDB.DB_CLIFOR"
	cQuery +=                            " AND SDBM.DB_LOJA    = SDB.DB_LOJA"
	cQuery +=                            " AND SDBM.DB_SERVIC  = SDB.DB_SERVIC"
	cQuery +=                            " AND SDBM.DB_TAREFA  = SDB.DB_TAREFA"
	cQuery +=                            " AND SDBM.DB_IDMOVTO = SDB.DB_IDMOVTO"
	cQuery +=                            " AND SDBM.DB_ESTORNO = ' '"
	cQuery +=                            " AND SDBM.DB_ATUEST  = 'N')"
	cQuery +=   " AND DCR.DCR_FILIAL = '"+xFilial('DCR')+"'"
	cQuery +=   " AND DCR.DCR_IDORI  = SDB.DB_IDDCF"
	cQuery +=   " AND DCR.DCR_IDMOV  = SDB.DB_IDMOVTO"
	cQuery +=   " AND DCR.DCR_IDOPER = SDB.DB_IDOPERA"
	cQuery +=   " AND DCR.DCR_IDDCF  = DCF.DCF_ID"
	cQuery +=   " AND DCR.D_E_L_E_T_ = ' '"
	cQuery +=   " AND EXISTS (SELECT 1"
	cQuery +=                 " FROM "+RetSqlName('SC9')+" SC9"
	cQuery +=                " WHERE SC9.C9_FILIAL  = '"+xFilial('SC9')+"'"
	cQuery +=                  " AND SC9.C9_IDDCF   = DCF.DCF_ID"
	cQuery +=                  " AND SC9.C9_NFISCAL = ' '"
	cQuery +=                  " AND SC9.D_E_L_E_T_ = ' ')"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	If !(cAliasQry)->(Eof())
		TcSetField(cAliasQry,'QTDORI','N',TamSX3('DCT_QTORIG')[1],TamSX3('DCT_QTORIG')[2])
		nQtdOri := (cAliasQry)->QTDORI
	EndIf
	(cAliasQry)->(DbCloseArea())
	// Atualiza a quantidade original
	oMntVolItem:SetQtdOri(nQtdOri)
	// Seta a quantidade separada só neste momento para que a mesma
	// não seja sobreposta pelo LoadData() que é realizado acima
	oMntVolItem:SetQtdSep(nQtdSepa)
	// Se for uma nova montagem, gera os novos registros DCS e DCT
	If !oMntVolItem:AssignDCT()
		WmsMessage(oMntVolItem:GetErro(),"WmsApanhe",1)
		oMntVolItem:Destroy()
		Return .F.
	EndIf
	oMntVolItem:Destroy()

Return .T.

//----------------------------------------------------------
/*/{Protheus.doc} WmsEstVol
Elimina montagem de volumes a partir do estorno da OS WMS

@author  Guilherme A. Metzger
@version P12
@since   31/01/2017
/*/
//----------------------------------------------------------
Function WmsEstVol(cMntVol,cCarga,cPedido,cProduto,cLote,cSubLote,nQuant,cIdDCF)
Local oMntVolItem := Nil

	cCarga  := PadR(cCarga , Len(DCS->DCS_CARGA ))
	cPedido := PadR(cPedido, Len(DCS->DCS_PEDIDO))

	// Carrega os dados da montagem
	oMntVolItem := WMSDTCMontagemVolumeItens():New()
	oMntVolItem:SetCodMnt(cMntVol)
	oMntVolItem:SetCarga(cCarga)
	oMntVolItem:SetPedido(cPedido)
	oMntVolItem:SetPrdOri(cProduto)
	oMntVolItem:SetProduto(cProduto)
	oMntVolItem:SetLoteCtl(cLote)
	oMntVolItem:SetNumLote(cSubLote)
	oMntVolItem:SetIdDCF(cIdDCF)
	If oMntVolItem:LoadData()
		// Elimina a partir da quantidade da OS, pois o registro
		// de montagem pode ter sido originado por diferentes
		// sequências de um mesmo produto do pedido de venda
		oMntVolItem:RevMntVol(nQuant,nQuant)
		// Elimina registro de Mont. Volume x OS
		oMntVolItem:DeleteD0I()
	EndIf

Return .T.

/*---------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- Programa   WmsChkVol  Autor   Microsiga             Data    07/07/2016    --
-------------------------------------------------------------------------- --
-- Desc.      Verifica a existência de volumes montados para o documento   --
--                                                                         --
-------------------------------------------------------------------------- --
-- Uso         AP                                                          --
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
---------------------------------------------------------------------------*/
Function WmsChkVol(cCarga,cPedido,cProduto,cLote,cSubLote)
Local oMntVol := Nil

	// Ajusta as variáveis para o tamanho padrão dos
	// campos das tabelas de montagem de volumes
	cCarga  := PadR(cCarga , Len(DCU->DCU_CARGA ))
	cPedido := PadR(cPedido, Len(DCU->DCU_PEDIDO))
	// Busca o último código de montagem
	oMntVol := WMSDTCMontagemVolume():New()
	oMntVol:SetCarga(cCarga)
	oMntVol:SetPedido(cPedido)
	DCT->(DbSetOrder(1))
	If DCT->(DbSeek(xFilial('DCT')+oMntVol:FindCodMnt()+cCarga+cPedido+cProduto+cProduto+cLote+cSubLote)) .And.;
		DCT->DCT_STATUS != "1"
		Return .T.
	EndIf

Return .F.

//----------------------------------------------------------
/*{Protheus.doc}
Criar a tabela temporária com base na estrutura informada

@param   aStrField      (Obrigatório)  Estrutura da tabela a ser criada (array)
@param   aIndexTab      (Obrigatório)  Indices da tabela a ser criada (array)
@param   cAliasTab                  Alias da tabela


@author  Alexsander Burigo Corrêa
@version P11
@Since   16/05/12
*/
//----------------------------------------------------------
Function CriaTabTmp(aStrField,aIndexTab,cAliasTab,oTempTable)
Local aCampos    := {}
Local nI         := 1
Local nJ         := 1

Default cAliasTab  := GetNextAlias() // Obtem o alias para a tabela temporária
	oTempTable := FWTemporaryTable():New(cAliasTab, aStrField)
	For nI := 1 To Len(aIndexTab)
		aCampos := StrTokArr( StrTran(aIndexTab[nI]," ",""), "+" )
		// Remove funções Advpl dos índices (forma antiga)
		For nJ := 1 To Len(aCampos)
			If At('(',aCampos[nJ]) > 0
				aCampos[nJ] := AllTrim(SubStr(aCampos[nJ],At('(',aCampos[nJ]) + 1 , Rat(')',aCampos[nJ]) - At('(',aCampos[nJ]) - 1))
			EndIf
		Next nJ
		oTempTable:AddIndex("IND"+cValToChar(nI), aCampos)
	Next nI
	oTempTable:Create()
Return cAliasTab

//----------------------------------------------------------
/*/{Protheus.doc} DelTabTmp
Elimina a tabela temporária e os respectivos índices

@param   cAliasTab      (Obrigatório)     Alias da tabela temporária para eliminar

@author  Alexsander Burigo Corrêa
@version P11
@Since   16/05/12
@obs     Recebe o alias da tabela a eliminar

/*/
//----------------------------------------------------------
Function DelTabTmp(cAliasTab,oTempTable)
Local nI         := 1
	If Select(cAliasTab) > 0
		If oTempTable == Nil
			oTempTable := FWTemporaryTable():New( cAliasTab )
			oTempTable:LCREATED := .T.
			oTempTable:OSTRUCT:LACTIVATE := .T.
		EndIf
		oTempTable:Delete()
	EndIf
Return .T.

//----------------------------------------------------------
/*/{Protheus.doc} MntCargDad
Carrega dados da tabela temporária

@param   cAliasTab      (Obrigatório)     Alias da tabela temporária
@param   aDados     (Obrigatório)     Array de dados
@param   aCampos    (Obrigatório)     Array da estrutura da tabela temporária

@author  Alexsander Burigo Corrêa
@version P11
@Since   16/05/12
@obs     Carrega dados da tabela temporária

/*/
//----------------------------------------------------------
Function MntCargDad(cAliasTab,aDados,aCampos,cAliasQry,lZap)
Local nX := 0
Local nY   := 0
Local nLen := 0
Default cAliasQry := ""
Default lZap      := .T.

	//-------------------------------------------------------------------
	// Limpa tabela temporária
	//-------------------------------------------------------------------
	dbSelectArea(cAliasTab)
	(cAliasTab)->( dbSetOrder(1) )
	If lZap
		ZAP
	EndIf

	//-------------------------------------------------------------------
	// Carga de dados
	//-------------------------------------------------------------------
	If Empty(cAliasQry)
		For nX := 1 To Len(aDados)
			RecLock(cAliasTab,.T.)
			For nY := 1 To Len(aCampos)
				(cAliasTab)->( FieldPut( nY, aDados[nX,nY] ) )
			Next
			MsUnLock(cAliasTab)
		Next
	Else
		nLen := Iif(!Empty(aCampos),Len(aCampos),(cAliasQry)->(FCount()))
		(cAliasQry)->(dbGoTop())
		While((cAliasQry)->(!Eof()))
			RecLock(cAliasTab,.T.)
			For nY := 1 To nLen
				(cAliasTab)->( FieldPut( nY , (cAliasQry)->( FieldGet( nY ) ) ) )
			Next
			MsUnLock(cAliasTab)
			(cAliasQry)->(DbSkip())
		EndDo
	EndIf
	(cAliasTab)->(dbGoTop())
Return cAliasTab

//------------------------------------------------------------------------------
Function WmsQry2Tmp(cAliasTab,aCampos,cQuery,oTabTmp,lRecria,lDeleta)
Local aAreaAnt  := GetArea()
Local cQueryAux := ""
Local cAliasQry := ""
Local nX        := 0
Local nStatus   := 0
Local lRet      := .T.
Default lRecria := !InTransaction()
Default lDeleta := .T.

	If oTabTmp != Nil
		If lRecria
			oTabTmp:Delete()
			oTabTmp:Create()
		Else
			If lDeleta
				cQueryAux := "DELETE FROM "+oTabTmp:GetRealName()
				lRet := (nStatus := TcSQLExec(cQueryAux) >= 0)
			EndIf
		EndIf
		If lRet
			cQueryAux := "INSERT INTO "+oTabTmp:GetRealName()+" ("
			For nX := 1 To Len(aCampos)
				If nX == Len(aCampos)
					cQueryAux += aCampos[nX,1]+") "
				Else
					cQueryAux += aCampos[nX,1]+","
				EndIf
			Next
			cQueryAux += ChangeQuery(cQuery)
			lRet := (nStatus := TcSQLExec(cQueryAux) >= 0)
		EndIf
	Else
		cAliasQry := GetNextAlias()
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
		For nX := 1 To Len(aCampos)
			TcSetField(cAliasQry,(cAliasQry)->( FieldName( nX ) ),aCampos[nX,2],aCampos[nX,3],aCampos[nX,4])
		Next
		MntCargDad(cAliasTab,Nil,aCampos,cAliasQry,lDeleta)
		(cAliasQry)->(DbCloseArea())
	EndIf
	RestArea(aAreaAnt)
Return lRet

//----------------------------------------------------------
/*/{Protheus.doc} BuscarSX3
Carrega dados SX3

@param   cCampo      (Obrigatório)    Código do campo da tabela
@param   cSTRTitulo  (Não Obrigatório) Descrição alternativa do campo

@author  Alexsander Burigo Corrêa
@version P11
@Since   16/05/12
@obs     Busca Dados do Campo na tabela SX3

/*/
//----------------------------------------------------------
Function BuscarSX3(cCampo,cTitulo,aColsSX3)
Local cTitSX3 := ""
Local cPicSX3 := ""
Local aTamSX3 := {}
Default aColsSX3 := {}

	cTitSX3 := Iif(Empty(cTitulo),FWX3Titulo(cCampo),cTitulo)
	cPicSX3 := X3Picture(cCampo) // <-  Aqui não tem uma FW
	aTamSX3 := TamSX3(cCampo)

	aColsSX3 := {cTitSX3, cPicSX3, aTamSX3[1], aTamSX3[2]}

Return aColsSX3[1]

//----------------------------------------------------------
/*/{Protheus.doc} WmsConfMult
Cria os registros de conferência de expedição a partir dos
movimentos de separação

@author  Guilherme A. Metzger
@version P11
@since   03/09/2015
/*/
//----------------------------------------------------------
Function WmsConfMult(cCarga,cPedido,cProduto,cLote,cSubLote,cTarefa,nQtdSepa,cLibPed,cIdDCF)
Local oConfExpItem := Nil
Local nQtdOri      := 0
Local cQuery       := ''
Local cAliasQry    := ''

	oConfExpItem := WMSDTCConferenciaExpedicaoItens():New()
	oConfExpItem:SetCarga(cCarga)
	oConfExpItem:SetPedido(cPedido)
	oConfExpItem:SetPrdOri(cProduto)
	oConfExpItem:SetProduto(cProduto)
	oConfExpItem:SetLoteCtl(cLote)
	oConfExpItem:SetNumLote(cSubLote)
	oConfExpItem:SetLibPed(cLibPed)
	oConfExpItem:SetIdDCF(cIdDCF)
	// Busca código da conferência de expedição
	oConfExpItem:SetCodExp(oConfExpItem:oConfExp:FindCodExp())
	// Calcula a quantidade original do produto
	cQuery := "SELECT SUM(DCR.DCR_QUANT) QTDORI"
	cQuery +=  " FROM "+RetSqlName('DCF')+" DCF,"
	cQuery +=           RetSqlName('SDB')+" SDB,"
	cQuery +=           RetSqlName('DCR')+" DCR"
	cQuery += " WHERE DCF.DCF_FILIAL = '"+xFilial('DCF')+"'"
	cQuery +=   " AND DCF.DCF_CARGA  = '"+cCarga+"'"
	cQuery +=   " AND DCF.DCF_DOCTO  = '"+cPedido+"'"
	cQuery +=   " AND DCF.D_E_L_E_T_ = ' '"
	cQuery +=   " AND SDB.DB_FILIAL  = '"+xFilial('SDB')+"'"
	cQuery +=   " AND SDB.DB_PRODUTO = '"+cProduto+"'"
	cQuery +=   " AND SDB.DB_LOTECTL = '"+cLote+"'"
	cQuery +=   " AND SDB.DB_NUMLOTE = '"+cSubLote+"'"
	cQuery +=   " AND SDB.DB_TAREFA  = '"+cTarefa+"'"
	cQuery +=   " AND SDB.DB_SERVIC  = DCF.DCF_SERVIC"
	cQuery +=   " AND SDB.DB_ESTORNO = ' '"
	cQuery +=   " AND SDB.DB_ATUEST  = 'N'"
	cQuery +=   " AND SDB.DB_ORDATIV = (SELECT MAX(DB_ORDATIV)"
	cQuery +=                           " FROM "+RetSqlName('SDB')+" SDBM"
	cQuery +=                          " WHERE SDBM.DB_FILIAL  = SDB.DB_FILIAL"
	cQuery +=                            " AND SDBM.DB_PRODUTO = SDB.DB_PRODUTO"
	cQuery +=                            " AND SDBM.DB_DOC     = SDB.DB_DOC"
	cQuery +=                            " AND SDBM.DB_SERIE   = SDB.DB_SERIE"
	cQuery +=                            " AND SDBM.DB_CLIFOR  = SDB.DB_CLIFOR"
	cQuery +=                            " AND SDBM.DB_LOJA    = SDB.DB_LOJA"
	cQuery +=                            " AND SDBM.DB_SERVIC  = SDB.DB_SERVIC"
	cQuery +=                            " AND SDBM.DB_TAREFA  = SDB.DB_TAREFA"
	cQuery +=                            " AND SDBM.DB_IDMOVTO = SDB.DB_IDMOVTO"
	cQuery +=                            " AND SDBM.DB_ESTORNO = ' '"
	cQuery +=                            " AND SDBM.DB_ATUEST  = 'N')"
	cQuery +=   " AND DCR.DCR_FILIAL = '"+xFilial('DCR')+"'"
	cQuery +=   " AND DCR.DCR_IDORI  = SDB.DB_IDDCF"
	cQuery +=   " AND DCR.DCR_IDMOV  = SDB.DB_IDMOVTO"
	cQuery +=   " AND DCR.DCR_IDOPER = SDB.DB_IDOPERA"
	cQuery +=   " AND DCR.DCR_IDDCF  = DCF.DCF_ID"
	cQuery +=   " AND DCR.D_E_L_E_T_ = ' '"
	cQuery +=   " AND EXISTS (SELECT 1"
	cQuery +=                 " FROM "+RetSqlName('SC9')+" SC9"
	cQuery +=                " WHERE SC9.C9_FILIAL  = '"+xFilial('SC9')+"'"
	cQuery +=                  " AND SC9.C9_IDDCF   = DCF.DCF_ID"
	cQuery +=                  " AND SC9.C9_NFISCAL = ' '"
	cQuery +=                  " AND SC9.D_E_L_E_T_ = ' ')"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	If !(cAliasQry)->(Eof())
		TcSetField(cAliasQry,'QTDORI','N',TamSX3('D01_QTORIG')[1],TamSX3('D01_QTORIG')[2])
		nQtdOri := (cAliasQry)->QTDORI
	EndIf
	(cAliasQry)->(DbCloseArea())
	// Atualiza a quantidade original
	oConfExpItem:SetQtdOri(nQtdOri)
	// Seta a quantidade separada só neste momento para que a mesma
	// não seja sobreposta pelo LoadData() que é realizado acima
	oConfExpItem:SetQtdSep(nQtdSepa)
	// Se for uma nova conferência, gera os novos registros D01 e D02
	If !oConfExpItem:AssignD02()
		WmsMessage(oConfExpItem:GetErro(),"WmsApanhe",1)
		oConfExpItem:Destroy()
		Return .F.
	EndIf
	oConfExpItem:Destroy()

Return .T.

//----------------------------------------------------------
/*/{Protheus.doc} WmsConfEst
Elimina conferência de expedição a partir do estorno da OS WMS

@author  Guilherme A. Metzger
@version P11
@since   03/09/2015
/*/
//----------------------------------------------------------
Function WmsConfEst(cConfExped,cCarga,cPedido,cProduto,cLote,cSubLote,nQuant,cIdDCF)
Local aD01Area     := D01->(GetArea())
Local aD02Area     := D02->(GetArea())
Local oConfExpItem := WMSDTCConferenciaExpedicaoItens():New()

	cCarga  := PadR(cCarga , Len(D04->D04_CARGA ))
	cPedido := PadR(cPedido, Len(D04->D04_PEDIDO))

	// Carrega os dados da conferência
	oConfExpItem:SetCodExp(cConfExped)
	oConfExpItem:SetCarga(cCarga)
	oConfExpItem:SetPedido(cPedido)
	oConfExpItem:SetPrdOri(cProduto)
	oConfExpItem:SetProduto(cProduto)
	oConfExpItem:SetLoteCtl(cLote)
	oConfExpItem:SetNumLote(cSubLote)
	oConfExpItem:SetIdDCF(cIdDCF)
	If oConfExpItem:LoadData()
		// Elimina a partir da quantidade da OS, pois o registro
		// de conferência pode ter sido originado por diferentes
		// sequências de um mesmo produto do pedido de venda
		oConfExpItem:RevConfExp(nQuant,nQuant)
		// Elimina registro de Conf. Expedição x OS
		oConfExpItem:DeleteD0H()
	EndIf

RestArea(aD01Area)
RestArea(aD02Area)
Return

//----------------------------------------------------------
/*/{Protheus.doc} WmsChkConf
Verifica a existência de itens conferidos para o documento

@author  Guilherme A. Metzger
@version P11
@since   07/07/2016
/*/
//----------------------------------------------------------
Function WmsChkConf(cCarga,cPedido,cProduto,cLote,cSubLote,cServico)
Local oConfExp := Nil
Local lRet     := .F.
Local cSeekD02 := ""
Local cExpD02  := ""

	If Posicione('DC5',1,xFilial('DC5')+cServico,'DC5_COFEXP') == '1'
		// Ajusta as variáveis para o tamanho padrão
		// dos campos das tabelas de conferência
		cCarga  := PadR(cCarga , Len(D02->D02_CARGA ))
		cPedido := PadR(cPedido, Len(D02->D02_PEDIDO))
		// Busca o último código de expedição
		oConfExp := WMSDTCConferenciaExpedicao():New()
		oConfExp:SetCarga(cCarga)
		oConfExp:SetPedido(cPedido)
		cSeekD02 := xFilial('D02')+oConfExp:FindCodExp()+cCarga+cPedido+cProduto+cProduto+cLote+cSubLote
		cExpD02  := "D02->D02_FILIAL+D02->D02_CODEXP+D02->D02_CARGA+D02->D02_PEDIDO+D02->D02_PRDORI+D02->D02_CODPRO+D02->D02_LOTE+D02->D02_SUBLOT"
		D02->(DbSetOrder(1)) // D02_FILIAL+D02_CODEXP+D02_CARGA+D02_PEDIDO+D02_PRDORI+D02_CODPRO+D02_LOTE+D02_SUBLOT
		D02->(DbSeek(cSeekD02))
		While !D02->(Eof()) .And. cSeekD02 == &cExpD02
			If D02->D02_STATUS != '1'
				lRet := .T.
				Exit
			EndIf
			D02->(DbSkip())
		EndDo
	EndIf

Return lRet

//--------------------------------------------------------------
/*/{Protheus.doc} WMSBuscaSeqPri
Verifica se já foi realizada alguma execucao da carga/pedido para
obter a sequencia de prioridade, caso não encontrado utiliza uma
nova sequencia

@param   nRecno         (Obrigatório) Recno da SDB
@param   cNewSeq                    Sequencia de prioridade

@author  Alexsander Burigo Corrêa
@version P11
@Since     21/08/13
@obs  Verifica sequencia de prioridade
/*/
//--------------------------------------------------------------
Function WMSBuscaSeqPri(rRecSDB)
Local aAreaSDB   := SDB->(GetArea())
Local nNewSeq   := ''
Local cAliasSDB := GetNextAlias()

	SDB->(MsGoTo(rRecSDB))

	cQuery := " SELECT DB_SEQPRI"
	cQuery += " FROM " + RetSqlName('SDB')+" SDB"
	cQuery += " WHERE SDB.DB_FILIAL = '"+xFilial("SDB")+"'"
	If WmsCarga(SDB->DB_CARGA)
		cQuery += " AND SDB.DB_CARGA    = '"+SDB->DB_CARGA+"'"
	Else
		cQuery += " AND SDB.DB_DOC      = '"+SDB->DB_DOC+"'"
		cQuery += " AND SDB.DB_CLIFOR   = '"+SDB->DB_CLIFOR+"'"
		cQuery += " AND SDB.DB_LOJA     = '"+SDB->DB_LOJA+"'"
	EndIf
	cQuery += " AND SDB.DB_ATUEST  =  'N' "
	cQuery += " AND SDB.DB_ESTORNO <> 'S' "
	cQuery += " AND SDB.DB_SEQPRI  <> '      '"
	cQuery += " AND SDB.D_E_L_E_T_ <> '*'"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasSDB,.F.,.T.)
	(cAliasSDB)->(dbGotop())
	If (cAliasSDB)->( !Eof())
		nNewSeq := (cAliasSDB)->DB_SEQPRI
	EndIf
	(cAliasSDB)->(dbCloseArea())

	If Empty(nNewSeq)
		nNewSeq   := WMSProxSeq('MV_WMSSQPR','DB_SEQPRI') //Proxima sequencia da execucao dos servicos
	EndIf

	RestArea(aAreaSDB)

Return nNewSeq

//--------------------------------------------------------------
/*/{Protheus.doc} WMSProxSeq
Gera proxima sequencia

@param  cParametro               (Obrigatório) Parametro a ser encrementado
@param  cField                   (Obrigatório) Campo SX3 para obter o tamanho

@author  Alexsander Burigo Corrêa
@version P11
@Since   21/08/13
@obs  Gera proxima sequencia

/*/
//--------------------------------------------------------------
Function WMSProxSeq(cParametro, cField)
Local cCodAnt := ""
Local nC      := 0

	While !LockByName("WMSPROXSEQ", .T., .F.)
		Sleep(50)
		nC++
		If nC == 60
			nC := 0
		EndIf
	EndDo

	cCodAnt := GetMV(cParametro)
	If Empty(cCodAnt)
		cCodAnt := Replicate('0',TamSX3(cField)[1])
	EndIf
	cCodAnt := Soma1(cCodAnt,TamSX3(cField)[1])
	PutMv(cParametro,cCodAnt)

	UnLockByName("WMSPROXSEQ", .T., .F.)

Return cCodAnt

/*
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
--  Função    WMSCALTIME  Autor   Evaldo Cevinscki Jr.    Data  01/11/2013 --
-----------------------------------------------------------------------------
--  Descrição Calcula a quantidade de horas entre duas datas e horas,      --
--            Considerando 24 horas por dia e horas tipo caracter..'00:00' --
-----------------------------------------------------------------------------
--  Retorna   nQtdHrs - Quantidade de horas Ex. 1.15, 1.75                 --
-----------------------------------------------------------------------------
--  Uso       GENERICO                                                     --
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
*/
Function WMSCALTIME(dINICIO,hINICIO,dDFIM,hOFIM)
Local nINIHOR := WMSHTOM(hINICIO)
Local nFIMHOR := WMSHTOM(hOFIM)
Local nSOMADT := 0

//calcula os minutos dos dias
If dDFIM > dINICIO
	nSOMADT := ((dDFIM - dINICIO)*1440)
Endif
//calcula qtd total de horas em formato numerico
nQtdHORA := ( (nFIMHOR+nSOMADT) - nINIHOR ) / 60

Return nQtdHORA
/*/
-----------------------------------------------------------------------------
-- Função       WMSHTOM   Autor   TOTVS                   Data  01/11/2013 --
-----------------------------------------------------------------------------
-- Descrição   Converte horas em minutos                                   --
-----------------------------------------------------------------------------
-- Parametros  Parametros -> cTime -> Horas em 99:99                       --
-----------------------------------------------------------------------------
--  Uso        Generico                                                    --
-----------------------------------------------------------------------------
/*/
Function WMSHTOM(cTIME)
Local nHORA,nMINUTO,nPOS

nPOS := At(":",cTIME)
nHORA   := VAL(SUBSTR(cTIME,1,(nPOS-1)))
nMINUTO := VAL(SUBSTR(cTIME,(nPOS+1)))

Return (nHORA*60)+nMINUTO

//--------------------------------------------------------------
/*/{Protheus.doc} WmsAtzDCR
Atualiza as quantidades da tabela DCR em relação a tabela SDB
@author  Jackson Patrick Werka
@Since   31/01/2014

@param  cIdDCF     (Obrigatório) Identificador exclusivo da OS na DCF
@param  cIdMovto   (Obrigatório) Identificador exclusivo do movimento
@param  cIdOpera   (Obrigatório) Identificador exclusivo do registro na SDB
@param  nQtde      (Obrigatório) Nova quantidade para o movimento
@param  nQtde2UM   (Opcional)    Nova quantidade para o movimento na 2ª UM
/*/
//--------------------------------------------------------------
Function WmsAtzDCR(cIdDCF,cIdMovto,cIdOpera,nQtde,nQtde2UM)
Local aAreaAnt := GetArea()
Local lRet     := .T.
Local cQuery   := ""
Local cAliasDCR:= GetNextAlias()
Default nQtde2UM := 0

	cQuery := "SELECT DCR.R_E_C_N_O_ RECNODCR"
	cQuery +=  " FROM "+RetSqlName('DCR')+" DCR"
	cQuery += " WHERE DCR_FILIAL = '"+xFilial("DCR")+"'"
	cQuery += "   AND DCR_IDORI  = '"+cIdDCF+"'"
	cQuery += "   AND DCR_IDDCF  = '"+cIdDCF+"'"
	cQuery += "   AND DCR_IDMOV  = '"+cIdMovto+"'"
	cQuery += "   AND DCR_IDOPER = '"+cIdOpera+"'"
	cQuery += "   AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasDCR,.F.,.T.)
	If (cAliasDCR)->(!Eof())
		DCR->(DbGoTo((cAliasDCR)->RECNODCR))
		RecLock('DCR',.F.)
		If QtdComp(nQtde) <= 0
			DCR->(DbDelete())
		Else
			DCR->DCR_QUANT  := nQtde
			DCR->DCR_QTSEUM := nQtde2UM
		EndIf
		DCR->(MsUnlock())
	EndIf
	(cAliasDCR)->(DbCloseArea())
RestArea(aAreaAnt)
Return lRet

//----------------------------------------------------------
/*/{Protheus.doc} WMSChkInv
Valida no WMS as informações do inventário

@param   cCod        (Obrigatório)  Produto
@param   cLocal      (Obrigatório)  Armazém
@param   cLocaliza   (Obrigatório)  Endereço

@author  Marlon Fernando Quandt
@version P11
@Since      01/06/14
/*/
//----------------------------------------------------------
function WMSChkInv(cCod,cLocal,cLocaliza)
Local cLog := ""

/* endereço inválido */
	dbSelectArea("SBE")
	SBE->(dbSetOrder(1))
	If !SBE->(dbSeek(xFilial("SBE")+cLocal+cLocaliza))
		cLog := "WMS01"
	Else

		dbSelectArea("SB5")
		SB5->(dbSetOrder(1))
		If !SB5->(dbSeek(xFilial("SB5")+cCod))
			cLog := "WMS04"
		Else
			If SBE->BE_CODZON <> SB5->B5_CODZON
				dbSelectArea("DCH")
				DCH->(dbSetOrder(1))
				If !DCH->(dbSeek(xFilial("DCH")+cCod+SBE->BE_CODZON))
					cLog := "WMS04"
				EndIf
			EndIf
		EndIf

		dbSelectArea("DC3")
		DC3->(dbSetOrder(2))
		If !DC3->(dbSeek(xFilial("DC3")+cCod+cLocal+SBE->BE_ESTFIS))
			cLog := "WMS03"
		Else
			/* endereço informado para o produto é de uso exclusivo para outro produto  */
			If !Empty(SBE->BE_CODPRO) .And. SBE->BE_CODPRO <> cCod
				If DC3->DC3_TIPEND != '4'
					cLog := "WMS02"
				EndIf
			EndIf
		EndIf
	EndIf

Return cLog

//--------------------------------------------------------------
/*/{Protheus.doc} WMSLogInv
Retorna rodapé para programa de inventário

@author  Marlon Fernando Quandt
@version P11
@Since   01/06/2014
/*/
//--------------------------------------------------------------
function WMSLogInv()
	local aLegenda := {}

	aadd(aLegenda, STR0051) //"WMS1 - > Endereço inválido."
	aadd(aLegenda, STR0052) //"WMS2 - > Endereço informado para o produto é de uso exclusivo de um"
	aadd(aLegenda, STR0055) //"          outro produto."
	aadd(aLegenda, STR0053) //"WMS3 - > Estrutura física do endereço não cadastrada na sequencia de"
	aadd(aLegenda, STR0056) //"          abastecimento do produto."
	aadd(aLegenda, STR0054) //"WMS4 - > Zona de Armazenagem inválida."

Return aLegenda

//------------------------------------------------------------------------//
//--------- Valida Servico WMS de endereçamento quando informado, --------//
//--------------- saldo endereço origem e endereço destino ---------------//
//------------------------------------------------------------------------//
Function WmsVldEntr(cDocto, cServico, cProduto, cLocDest, cEndDest, cLoteCtl, cNumLote, cNumSerie, nQuant)
Local aAreaAnt := GetArea()
Local lRet     := .T.
Local lWmsVldT := SuperGetMV('MV_WMSVLDT',.F.,.T.)

//-- Valida Servico WMS de endereçamento quando informado
If !Empty(cServico) .And. !(cServico $ '499|999')
	lRet := WmsVldSrv('6',cServico,,,,,,'499')
EndIf

If lRet .And. lWmsVldT
	lRet := WmsVldDest(cProduto, cLocDest, cEndDest, cLoteCtl, cNumLote, cNumSerie, nQuant)
EndIf

RestArea(aAreaAnt)
Return lRet

//------------------------------------------------------------------------//
//--------- Valida Servico WMS de transferência quando informado, --------//
//--------------- saldo endereço origem e endereço destino ---------------//
//------------------------------------------------------------------------//
Function WmsVldTran(cDocto, cServico, cCodOrig, cLocOrig, cEndOrig, cCodDest, cLocDest, cEndDest, cLoteCtl, cNumLote, cNumSerie, nQuant)
Local aAreaAnt  := GetArea()
Local lRet      := .T.
Local nSaldoPrd := 0
Local nSaldoPRF := 0
Local lWmsVldT  := SuperGetMV('MV_WMSVLDT',.F.,.T.)
Local cMensagem := ""
Local lRetPE    := .T.

	//-- Valida Servico WMS de transferência quando informado
	If !Empty(cServico)
		lRet := WmsVldSrv('10',cServico)
		If lRet .And. Empty(cDocto)
			WmsMessage(STR0063,,1) //Para transferências com serviço WMS é necessário informar número de documento!
			lRet := .F.
		EndIf
		//-- Valida produto Origem / Destino
		If lRet .And. cCodOrig <> cCodDest
			WmsMessage(STR0061,,1) //Código do produto origem diferente do código produto destino.
			lRet := .F.
		EndIf
		If lRet
			// Ponto de entrada para substituir a validação pardrão entre armazém origem / destino
			// Desenvolvido para cliente Vaccinar - chamado TUKLHX
			If ExistBlock("WMSXVLLC")
				lRetPE := ExecBlock("WMSXVLLC",.F.,.F.,{cLocOrig,cLocDest,cCodOrig})
				lRet   := Iif(ValType(lRetPE)=="L",lRetPE,.T.)
			Else
				//-- Validação padrão armazém origem / destino
				If cLocOrig <> cLocDest
					WmsMessage(STR0071,,1) //Para transferências com serviço WMS é necessário que o armazém origem seja o mesmo que o armazém destino.
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf
	// --- Verifica endereço ORIGEM
	SBE->(DbSetOrder(1))
	If SBE->(DbSeek(xFilial("SBE")+cLocOrig+cEndOrig))
		If SBE->BE_STATUS == "3"  //-- Endereço bloqueado
			WmsMessage(WmsFmtMsg(STR0065,{{"[VAR01]",cEndOrig}}),,1) //"O endereço origem [VAR01] está bloqueado."
			lRet := .F.
		EndIf
	EndIf

	//-- Valida saldo endereço origem e endereço destino
	If lRet .And. lWmsVldT
		nSaldoPrd := WmsSaldoSBF(cLocOrig,cEndOrig,cCodOrig,cNumSerie,cLoteCtl,cNumLote,.F.,.F.,.F.,.F.,'1',.F.)
		//Se a variável cIdMovtoAt tiver sido definida quer dizer que a atividade de transferência está
		//sendo executada e neste momento não deve ser considerado o saldo pendente de RF, apenas o saldo do endereço
		If Type('cIdMovtoAt') == 'U'
			nSaldoPRF := WmsSaldoSBF(cLocOrig,cEndOrig,cCodOrig,cNumSerie,cLoteCtl,cNumLote,.F.,.T.,.F.,.T.,'3')
		EndIf
		//Utiliza soma pois somente as saídas retorna saldo negativo
		If (QtdComp(nSaldoPrd+nSaldoPRF) < QtdComp(nQuant))
			//Existem atividades a executar que comprometem o saldo do produto [VAR01] no endereço [VAR02].
			//Endereço possui saldo de [VAR01].
			//Movimentação WMS pendente de [VAR01].
			cMensagem := WmsFmtMsg(STR0066,{{"[VAR01]",cCodOrig},{"[VAR02]",cEndOrig}})
			cMensagem += CLRF+WmsFmtMsg(STR0025,{{"[VAR01]",Transf(nSaldoPrd,PesqPictQt('DB_QUANT',14))}})
			cMensagem += CLRF+WmsFmtMsg(STR0026,{{"[VAR01]",Transf((nSaldoPRF*(-1)),PesqPictQt('DB_QUANT',14))}})
			WmsMessage(cMensagem,,1)
			lRet := .F.
		ElseIf !Empty(cEndDest)
			lRet := WmsVldDest(cCodDest, cLocDest, cEndDest, cLoteCtl, cNumLote, cNumSerie, nQuant)
		EndIf
	EndIf

RestArea(aAreaAnt)
Return lRet

//----------------------------------------------------------------------------------//
//-------------------------- Valida endereço destino WMS ---------------------------//
//----------------------------------------------------------------------------------//
Function WmsVldDest(cProduto, cLocDest, cEndDest, cLoteCtl, cNumLote, cNumSerie, nQuant)
Local aAreaAnt   := GetArea()
Local lRet       := .T.
Local nSaldoSBF  := 0
Local nSaldoRF   := 0
Local nSaldoPrd  := 0
Local nSaldoPRF  := 0
Local nSaldoLT   := 0
Local nCapacEnd  := 0
Local cRetPE     := ""
Local cTpEstr    := ""
Local cWmsTpEn   := "1"
Local lPercOcup  := .F.
Local cMensagem  := ""
Local lChkCapa   := SuperGetMV('MV_WMSVLDE', .F., .T.)
Local cTipEstVld := "3|5|7"

	// Ponto de entrada para indicar quais armazéns não devem passar pelas validações WMS
	If ExistBlock("WMSVLDES")
		cRetPE := ExecBlock("WMSVLDES",.F.,.F.,{cLocDest,cEndDest,cProduto})
		If (ValType(cRetPE)=="C" .And. cLocDest $ cRetPE)
			Return .T.
		EndIf
	EndIf

	// --- Verifica endereço DESTINO
	SBE->(DbSetOrder(1))
	If SBE->(DbSeek(xFilial("SBE")+cLocDest+cEndDest,.F.))
		If SBE->BE_STATUS == "3"  //-- Endereço bloqueado
			WmsMessage(WmsFmtMsg(STR0019,{{"[VAR01]",cEndDest}}),,1) //"O endereço destino [VAR01] está bloqueado."
			lRet := .F.
		EndIf
		If lRet
			DC8->(DbSetOrder(1))
			If DC8->(!DbSeek(xFilial("DC8")+SBE->BE_ESTFIS,.F.))
				WmsMessage(WmsFmtMsg(STR0020,{{"[VAR01]",SBE->BE_ESTFIS}}),,1) //"Estrutura física [VAR01] não cadastrada. (DC8)"
				lRet :=.F.
			EndIf
		EndIf
		cTpEstr := AllTrim(Str(DLTipoEnd(SBE->BE_ESTFIS)))
		If lRet .And. !(cTpEstr $ cTipEstVld)
			// --- Verifica Sequência de Abastecimento
			DC3->(DbSetOrder(2))
			If DC3->(!DbSeek(xFilial("DC3")+cProduto+cLocDest+SBE->BE_ESTFIS,.F.))
				WmsMessage(WmsFmtMsg(STR0021,{{"[VAR01]",cProduto},{"[VAR02]",cLocDest},{"[VAR03]",SBE->BE_ESTFIS}}),,1) //"Produto [VAR01] não possui sequência de abastecimento para Armazém/Estrutura [VAR02]/[VAR03]. (DC3)"
				lRet :=.F.
			EndIf
			If lRet
				cWmsTpEn := DC3->DC3_TIPEND
				// --- Verifica Zona Armazenagem Alternativa
				SB5->(DbSetOrder(1))
				If SB5->(DbSeek(xFilial("SB5")+cProduto)) .And. SB5->B5_CODZON # SBE->BE_CODZON
					DCH->(DbSetOrder(1))
					If DCH->(!DbSeek(xFilial("DCH")+cProduto+SBE->BE_CODZON))
						WmsMessage(WmsFmtMsg(STR0022,{{"[VAR01]",cProduto},{"[VAR02]",SBE->BE_CODZON}}),,1) //"Produto [VAR01] não está cadastrado para a zona armazenagem [VAR02]. (SB5,DCH)"
						lRet :=.F.
					EndIf
				EndIf
			EndIf
		EndIf
		//Se está fazendo um reabastecimento, pode temporariamente exceder a capacidade
		If Type("lWmsMovPkg") == "L" .And. lWmsMovPkg
			cTipEstVld := "2|3|5|7"
		EndIf
		If lRet .And. lChkCapa .And. !(cTpEstr $ cTipEstVld)
			//Verifica se o endereço utiliza percentual de ocupação
			lPercOcup := WmsChkDCP(cLocDest,cEndDest,SBE->BE_ESTFIS,DC3->DC3_CODNOR,cProduto)

			//Carrega saldos de acordo somente do produto e do produto + lote + sublote
			nSaldoPrd := WmsSaldoSBF(cLocDest,cEndDest,cProduto,/*cNumSerie*/,/*cLoteCtl*/,/*cNumLote*/,.F.,.F.,.F.,.F.,'1',.F.)
			nSaldoPRF := WmsSaldoSBF(cLocDest,cEndDest,cProduto,/*cNumSerie*/,/*cLoteCtl*/,/*cNumLote*/,.T.,.T.,.T.,.F.,'3')
			nSaldoLT  := WmsSaldoSBF(cLocDest,cEndDest,cProduto,cNumSerie,cLoteCtl,cNumLote,.T.,.T.,.T.,.F.)

			If lPercOcup
				nSaldoSBF := nSaldoPrd
				nSaldoRF  := nSaldoPRF
			Else
				nSaldoSBF := WmsSaldoSBF(cLocDest,cEndDest,/*cProduto*/,/*cNumSerie*/,/*cLoteCtl*/,/*cNumLote*/,.F.,.F.,.F.,.F.,'1',.F.)
				nSaldoRF  := WmsSaldoSBF(cLocDest,cEndDest,/*cProduto*/,/*cNumSerie*/,/*cLoteCtl*/,/*cNumLote*/,.T.,.T.,.T.,.F.,'3')
			EndIf

			nCapacEnd := DLQtdNorma(cProduto,cLocDest,SBE->BE_ESTFIS,/*cDesUni*/,.T.,cEndDest) //Considerar a qtd pelo nr de unitizadores
			//Deve verificar se a quantidade a transferir não ultrapassa a capacidade do endereço
			If QtdComp(nSaldoSBF + nSaldoRF + nQuant) > QtdComp(nCapacEnd)
				//Movimentação de [VAR01] para o endereço [VAR02] excedendo a capacidade de armazenagem.
				//Capacidade total do endereço de [VAR01].
				//Endereço possui saldo de [VAR01].
				//Movimentação WMS pendente de [VAR01].
				cMensagem := WmsFmtMsg(STR0023,{{"[VAR01]",Transf(nQuant,PesqPictQt('DB_QUANT',14))},{"[VAR02]",cEndDest}})
				cMensagem += CLRF+WmsFmtMsg(STR0024,{{"[VAR01]",Transf(nCapacEnd,PesqPictQt('DB_QUANT',14))}})
				If nSaldoSBF > 0
					cMensagem += CLRF+WmsFmtMsg(STR0025,{{"[VAR01]",Transf(nSaldoSBF,PesqPictQt('DB_QUANT',14))}})
				EndIf
				If nSaldoRF > 0
					cMensagem += CLRF+WmsFmtMsg(STR0026,{{"[VAR01]",Transf(nSaldoRF,PesqPictQt('DB_QUANT',14))}})
				EndIf
				WmsMessage(cMensagem,,1)
				lRet := .F.
			EndIf

			//Se não compartilha endereço, deve verificar se o endereço está em uso por outro produto
			If lRet .And. cWmsTpEn != '4'
				If QtdComp(nSaldoPrd + nSaldoPRF) != QtdComp(nSaldoSBF + nSaldoRF)
					WmsMessage(WmsFmtMsg(STR0027,{{"[VAR01]",cEndDest}}),,1) //"Endereço [VAR01] em uso por outro produto."
					lRet := .F.
				EndIf
			EndIf

			//Se não compartilha endereço e não endereça produtos de mesmo lote,
			//deve verificar se o endereço está em uso por outro lote
			If lRet .And. cWmsTpEn == '3'
				If nSaldoLT != (nSaldoSBF + nSaldoRF) //A consulta de saldo por lote não está sendo feita separadamente, por isso não precisa somar RF
					WmsMessage(WmsFmtMsg(STR0064,{{"[VAR01]",cEndDest}}),,1) //"Endereço [VAR01] em uso por outro lote."
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf

RestArea(aAreaAnt)
Return lRet

//----------------------------------------------------------------------------------//
//--------------- Efetua as Movimentações de Estoque pelo WMS ----------------------//
//----------------------------------------------------------------------------------//
Function WmsMovEst(aParam, lEstorna, nRegOrigD3, nRegDestD3, nTipoTr)

Local aAreaAnt   := GetArea()
Local cProduto   := ""
Local cLoteCtl   := ""
Local cNumLote   := ""
Local cLocOrig   := ""
Local cEstOrig   := ""
Local cEndOrig   := ""
Local cLocDest   := ""
Local cEstDest   := ""
Local cEndDest   := ""
Local cSerOrig   := ""
Local dDtValid   := CtoD('  /  /  ')
Local cHrInicio  := ""
Local cServico   := ""
Local cTarefa    := ""
Local cAtividade := ""
Local cCarga     := ""
Local cUnitiza   := ""
Local cOrdTar    := ""
Local cRHumano   := ""
Local cRFisico   := ""
Local cDocumento := ""
Local nQtdMovto  := 0
Local nQuant2UM  := 0
Local lRet       := .F.
Local cNumSeq    := ""

Default lEstorna   := .F.
Default nRegOrigD3 := 0
Default nRegDestD3 := 0
Default nTipoTr    := 1 //-- 1=Enderecamento / 2=Apanhe / 3=Reabastecimento

Private cCusMed    := SuperGetMV('MV_CUSMED',.F.,"")
Private aRegSD3    := {}
Private cSerieSDB  := ''
Private nFCICalc := SuperGetMV("MV_FCICALC",.F.,0)

If aParam150[17] $ 'SC9/SD3/DCF'
	cSerieSDB  := aParam[04]
EndIf

If cCusMed == 'O'
	Private nHdlPrv     := 0   //-- Endereco do arquivo de contra prova dos lanctos cont.
	Private lCriaHeader := .T. //-- Para criar o header do arquivo Contra Prova
	Private cLoteEst    := ''  //-- Numero do lote para lancamentos do estoque
	//----------------------------------------------------------------
	//  Posiciona numero do Lote para Lancamentos do Faturamento
	//----------------------------------------------------------------
	DbSelectArea('SX5')
	DbSetOrder(1)
	DbSeek(xFilial('SX5')+'09EST', .F.)
	cLoteEst := If(Found(),Trim(X5Descri()),'EST ')
	Private nTotal   := 0  //-- Total dos lancamentos contabeis
	Private cArquivo := '' //-- Nome do arquivo contra prova
EndIf

	If ValType(aParam) == 'A'
		cProduto   := aParam[01]
		cLocOrig   := aParam[02]
		cDocumento := aParam[03]
		cNumSeq    := aParam[05]
		nQtdMovto  := aParam[06]
		cHrInicio  := aParam[08]
		cServico   := aParam[09]
		cTarefa    := aParam[10]
		cAtividade := aParam[11]
		cLoteCtl   := aParam[18]
		cNumLote   := aParam[19]
		cEndOrig   := aParam[20]
		cEstOrig   := aParam[21]
		cCarga     := aParam[23]
		cUnitiza   := aParam[24]
		cLocDest   := aParam[25]
		cEndDest   := aParam[26]
		cEstDest   := aParam[27]
		cOrdTar    := aParam[28]
		cRHumano   := aParam[30]
		cRFisico   := aParam[31]
	EndIf
	nQuant2UM := ConvUm(cProduto, nQtdMovto, 0, 2)

	If Rastro(cProduto)
		DbSelectArea('SB8')
		SB8->(DbSetOrder(3)) //B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL+B8_NUMLOTE+DTOS(B8_DTVALID)
		If SB8->(DbSeek(xFilial('SB8')+cProduto+cLocOrig+cLoteCtl+If(Rastro(cProduto, 'S'),cNumLote,''), .F.))
			dDtValid := SB8->B8_DTVALID
		EndIf
	EndIf

	Private cIdMovtoAt := SDB->DB_IDMOVTO
	lRet := a260WMSTOK(cProduto,;
							 cProduto,;
							 Iif(!lEstorna,cLocOrig,cLocDest),;
							 Iif(!lEstorna,cLocDest,cLocOrig),;
							 nQtdMovto,;
							 nQuant2UM,;
							 dDataBase,;
							 cLoteCtl,;
							 Iif(!lEstorna,cEndOrig,cEndDest),;
							 Iif(!lEstorna,cEndDest,cEndOrig),;
							 cNumLote,;
							 cSerOrig,;
							 cDocumento)
	If lRet
		//--
		Begin Transaction
		lRet := a260Processa(cProduto, ;   //-- Codigo do Produto Origem    - Obrigatorio
		cLocOrig, ;                        //-- Almox Origem                - Obrigatorio
		nQtdMovto, ;                       //-- Quantidade 1a UM            - Obrigatorio
		cDocumento, ;                      //-- Documento                   - Obrigatorio
		dDataBase, ;                       //-- Data                        - Obrigatorio
		nQuant2UM, ;                       //-- Quantidade 2a UM
		cNumLote, ;                        //-- Sub-Lote                    - Obrigatorio se usa Rastro "S"
		cLoteCtl, ;                        //-- Lote                        - Obrigatorio se usa Rastro
		dDtValid, ;                        //-- Validade                    - Obrigatorio se usa Rastro
		cSerOrig, ;                        //-- Numero de Serie
		cEndOrig, ;                        //-- Localizacao Origem
		cProduto, ;                        //-- Codigo do Produto Destino   - Obrigatorio
		cLocDest, ;                        //-- Almox Destino               - Obrigatorio
		cEndDest, ;                        //-- Endereco Destino            - Obrigatorio p/a Transferencia
		lEstorna, ;                        //-- Indica se movimento e estorno
		nRegOrigD3, ;                      //-- Numero do registro origem no SD3  - Obrigatorio se for Estorno
		nRegDestD3, ;                      //-- Numero do registro destino no SD3 - Obrigatorio se for Estorno
		"DLGXFUN", ;                       //-- Indicacao do programa que originou os lancamentos
		cEstOrig,;                         //-- Estrutura Fisica Padrao
		cServico,;                         //-- Servico
		cTarefa,;                          //-- Tarefa
		cAtividade,;                       //-- Atividade
		"",;                               //-- Anomalia
		cEstDest,;                         //-- Estrutura Fisica Destino
		cEndDest,;                         //-- Endereco Destino
		cHrInicio,;                        //-- Hora Inicio
		"S",;                              //-- Atualiza Estoque
		cCarga,;                           //-- Numero da Carga
		cUnitiza,;                         //-- Numero do Unitizador
		cOrdTar,;                          //-- Ordem da Tarefa
		"ZZ",;                             //-- Ordem da Atividade
		cRHumano,;                         //-- Recurso Humano
		cRFisico)                          //-- Recurso Fisico
		//-- Procura SD3 ORIGINAL para que seja REMOVIDO pois foi substituido pelos movimentos de transferencia
		If aParam150[17] == "SD3" .And. !Empty(cNumSeq)
			WmsAtzSD3(cDocumento,cProduto,cNumSeq,nTipoTr,nQtdMovto)
		EndIf
		End Transaction
	EndIf

RestArea(aAreaAnt)
Return lRet

Function CalcTmpMov(dDtInicio, dDtFinal, cHrInicio, cHrFinal, nTamHora)
Local nDias      := 0
Local nHoras     := 0
Local cDifTime   := ""

Default nTamHora := 2
Default dDtFinal := dDataBase
Default cHrFinal := Time()
	If !Empty(dDtInicio) .And. !Empty(cHrInicio)
		If Empty(dDtFinal)
			dDtFinal := dDataBase
		EndIf
		If Empty(cHrFinal)
			cHrFinal := Time()
		EndIf
		nDias    := ABS(dDtFinal-dDtInicio)
		cDifTime := ELAPTIME(cHrInicio,cHrFinal)
		nHoras   := Val(Substr(cDifTime,1,2))
		If nDias > 0
			nHoras := nHoras+(nDias*24)
		EndIf
		cDifTime := StrZero(nHoras,nTamHora)+substr(cDifTime,3)
	EndIf
Return cDifTime

/*/{Protheus.doc} WmsPergEnd
Exibe uma tela onde deverá ser informado o endereço WMS para o processo
@author Fernando J. Siquini
@since 02/04/2004

@param cEndOrig, Caracter, Código do endereço, retorna por referencia @cEndOrig
@param [lSuggest], Lógico, Indica que sugere as informações na tela
@param [lForce], Lógico, Indica se é obrigatório informar os dados de endereço
@param [cTipServ], Caracter, Tipo do serviço: 1- Entrada, 2- Saída, 3- Interno

@return Lógico Indicador se os dados foram informados corretamente
/*/
Function WmsPergEnd(cArmazWMS,cEnderWMS, lSuggest, lForce, cTipServ)
Local aAreaAnt  := {}
Local cArmazem  := CriaVar('BE_LOCAL',.F.)
Local cEndereco := CriaVar('BE_LOCALIZ',.F.)
Local cTitle    := "SIGAWMS"
Local cString   := ""
Local lCancel   := .F.
Local cSeek     := ""
Local oDlg, oBtn

Default lSuggest := .T.
Default lForce   := .F.
Default cTipServ := '3'

	NNR->(dbSetOrder(1))
	NNR->(dbSeek(xFilial("NNR")+cArmazWMS))
	cArmazem := NNR->NNR_CODIGO
	If lSuggest
		If !Empty(cEnderWMS)
			cEndereco := cEnderWMS
		EndIf
	EndIf

	If IsInCallStack('WmsExeDCF')
		cTitle += Iif(WmsCarga(DCF->DCF_CARGA)," - "+Trim(RetTitle("DCF_CARGA"))+": "+Trim(DCF->DCF_CARGA)," - "+Trim(RetTitle("DCF_DOCTO"))+": "+Trim(DCF->DCF_DOCTO))
	EndIf

	cString := Iif(cTipServ=='1',STR0075,STR0076) // Identifique a origem do Serviço WMS:"##"Identifique o destino do Serviço WMS:

	DEFINE MSDIALOG oDlg STYLE nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE ) FROM 0, 0 TO 145, 295 TITLE cTitle PIXEL
	@ 10, 10 SAY   AllTrim(cString)                    OF oDlg PIXEL
	@ 25, 10 SAY   AllTrim(RetTitle('BE_LOCAL'))+':' OF oDlg PIXEL
	@ 25, 50 MSGET cArmazem VALID ValArmazem(@cArmazem) F3 'NNR' OF oDlg PICTURE '@!' PIXEL
	@ 40, 10 SAY   AllTrim(RetTitle('BE_LOCALIZ'))+':' OF oDlg PIXEL
	@ 40, 50 MSGET cEndereco VALID ValEndereco(@cEndereco) F3 'SBELOC' OF oDlg PICTURE '@!' PIXEL

	@ 058,100 BUTTON oBtn PROMPT STR0077 SIZE 040,012 OF oDlg PIXEL; // Cancelar
	ACTION (Iif(ValEndWMS(@cArmazem,cEndereco,lForce,cTipServ,.F.),(oDlg:End(),lCancel:=.T.),/*Não faz nada*/))
	@ 058,058 BUTTON oBack PROMPT STR0078 SIZE 040, 012 OF oDlg PIXEL; // Confirmar
	ACTION (Iif(ValEndWMS(@cArmazem,cEndereco,.T.,cTipServ,.T.),(oDlg:End(),lCancel:=.F.),/*Não faz nada*/))

	oDlg:lEscClose := .F.
	ACTIVATE MSDIALOG oDlg CENTERED
	//Se não informou o endereço WMS
	If Empty(cArmazem) .Or. Empty(cEndereco) .Or. lCancel
		cArmazWMS := CriaVar('BE_LOCAL',.F.)
		cEnderWMS := CriaVar('BE_LOCALIZ',.F.)
	Else
		cArmazWMS := cArmazem
		cEnderWMS := cEndereco
	EndIf

Return !(Empty(cArmazWMS) .Or. Empty(cEnderWMS))


Static Function ValArmazem(cArmazem)
Local lRet := .T.
	If !Empty(cArmazem)
		NNR->(dbSetOrder(1))
		If !NNR->(dbSeek(xFilial("NNR")+cArmazem))
			cArmazem := CriaVar("NNR_CODIGO")
			lRet := .F.
		EndIf
	EndIf
Return lRet

Static Function ValEndereco(cArmazem,cEndereco)
Local lRet := .T.
	If !Empty(cEndereco)
		SBE->(dbSetOrder(1))
		If !SBE->(dbSeek(xFilial("SBE")+cArmazem+cEndereco))
			lRet := .F.
		EndIf
	EndIf
Return lRet

/*------------------------------------------------------------------------------
Valida as informações de endereço para serviços do WMS
------------------------------------------------------------------------------*/
Static Function ValEndWMS(cArmazem,cEndereco,lForce,cTipServ,lConfirm)
Local lRet := .T.
	If lConfirm .And. !Empty(cArmazem) .And. !Empty(cEndereco)
		DbSelectArea('SBE')
		SBE->(DbSetOrder(1))
		If SBE->(!MsSeek(xFilial('SBE')+cArmazem+cEndereco, .F.))
			WmsMessage(STR0079,"SIGAWMS",1,.T.) // Endereço não cadastrado (SBE).
			lRet := .F.
		Else
			If cTipServ != '3' .And. DLTipoEnd(SBE->BE_ESTFIS) != 5
				WmsMessage(STR0080,"SIGAWMS",1,.T.) // Para serviços de entrada/saída somente endereços de estrutura do tipo box/doca podem ser utilizados!
				lRet := .F.
			EndIf
		EndIf
	ElseIf lForce
		WmsMessage(Iif(cTipServ=='1',STR0081,STR0082),"SIGAWMS",1,.T.) // É obrigatório informar endereço origem // É obrigatório informar endereço destino
		lRet := .F.
	ElseIf !lConfirm
		lRet := (WmsMessage(Iif(cTipServ=='1',STR0083,STR0084),"SIGAWMS",4,.T.,{STR0085,STR0086})==2) // Sempre que um Serviço WMS for gerado é necessário que se informe um endereço origem"##"Sempre que um Serviço WMS for gerado é necessário que se informe um endereço destino // Sim // Não
	EndIf
Return lRet

//----------------------------------------------------------
/*/{Protheus.doc} IntWMS
Verifica se o sistema está parametrizado para integrar com o WMS.
Quando for informado produto, verifica também se o mesmo possui
controle WMS.

@param  cProduto (Opcional) Código do produto

@author  Guilherme A. Metzger
@version P11
@since   19/07/2016
/*/
//----------------------------------------------------------
Function IntWMS(cProduto)
Local lIntWMS  := SuperGetMV('MV_INTWMS',.F.,.F.)
Local aAreaAnt := GetArea()
Local lWmsNew  := SuperGetMv("MV_WMSNEW",.F.,.F.)

Default cProduto := ""
	If lIntWMS .And. !Empty(cProduto)
		// Verifica se controla endereçamento
		lIntWMS := Localiza(cProduto,.T.)
		// Verifica se o produto possui controle WMS
		If lIntWMS .And. lWmsNew
			SB5->(dbSetOrder(1))
			If SB5->(DbSeek(xFilial("SB5")+cProduto)) .AND. SB5->(FieldPos("B5_CTRWMS")) > 0
				lIntWMS := (RetFldProd(cProduto,"B5_CTRWMS") == "1")
			Else
				lIntWMS := .F.
			EndIf
		EndIf
	EndIf
	RestArea(aAreaAnt)
Return lIntWMS

//----------------------------------------------------------
/*/{Protheus.doc} FiltSBELoc
Monta uma expressão contendo todas as estruturas físicas do
tipo Doca, para ser utilizada na consulta padrão SBELOC.

@author  Guilherme A. Metzger
@version P11
@since   05/08/2016
/*/
//----------------------------------------------------------
Function FiltSBELoc()
Local cRet := ""

	DC8->(DbSetOrder(3)) // DC8_FILIAL+DC8_TPESTR
	DC8->(DbSeek(xFilial('DC8')+'5'))
	While !DC8->(Eof()) .And. (xFilial('DC8')+'5' == DC8->DC8_FILIAL+DC8->DC8_TPESTR)
		If Empty(cRet)
			cRet := DC8->DC8_CODEST
		Else
			cRet += "|"+DC8->DC8_CODEST
		EndIf
		DC8->(DbSkip())
	EndDo

Return cRet

//----------------------------------------------------------
/*/{Protheus.doc} FiltSC7WMS
Retorna o produto utilizado no filtro da consulta padrão SC7WMS,
de acordo

@author  Guilherme A. Metzger
@version P11
@since   20/03/2018
/*/
//----------------------------------------------------------
Function FiltSC7WMS()
Local oModel := ""
Local cRet   := ""

	If Type("aCols") == "A"
		cRet := aCols[n][2]
	Else
		oModel := FWModelActive()
		cRet   := oModel:GetValue("A324D0M","D0M_PRODUT")
	EndIf

Return cRet

Function WmsCopyReg(cTab)
Local aTab := {}
Local nCnt := 0

	For nCnt := 1 To (cTab)->(FCount())
		aAdd(aTab, (cTab)->(FieldGet(nCnt)))
	Next nCnt

	RecLock(cTab, .T.)
	For nCnt := 1 To Len(aTab)
		FieldPut(nCnt, aTab[nCnt])
	Next nCnt

	dbSelectArea(cTab)
Return Nil

//--------------------------------------------------------------
/*/{Protheus.doc} WmsSB1Blq
Verifica se produto ou se possui componentes os mesmos não
estejam bloqueados B1_MSBLQL

@author Alexsander Correa
@version P11
@Since   06/09/2016
/*/
//--------------------------------------------------------------
Function WmsSB1Blq(cProduto,cErro)
Local lRet      := .T.
Local aAreaSB1  := SB1->(GetArea())
Local aAreaD11  := Nil
Local cPrdCmp   := ""
	If Empty(cProduto)
		cErro := STR0087 // "Produto não informado!"
		Return .F.
	EndIf
	cErro     := ""
	// Valida produto bloqueado
	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	If IntWMS(cProduto) .And. SB1->(dbSeek(xFilial("SB1")+cProduto))
		If SB1->B1_MSBLQL == '1'
			cErro := WmsFmtMsg(STR0088,{{"[VAR01]",cProduto}}) // "Produto ([VAR01]) bloqueado (B1_MSBLQL)!"
			lRet := .F.
		EndIf
	EndIf
	aAreaD11 := D11->(GetArea())
	// Valida se há componentes bloqueados
	dbSelectArea("D11")
	D11->(dbSetOrder(1))
	D11->(dbSeek(xFilial("D11")+cProduto))
	Do While D11->(!Eof()) .And. xFilial("D11")+cProduto == D11->(D11_FILIAL+D11_PRODUT)
		cPrdCmp := D11->D11_PRDCMP
		If IntWMS(cPrdCmp) .And. SB1->(dbSeek(xFilial("SB1")+cPrdCmp))
			If SB1->B1_MSBLQL == '1'
				If !Empty(cErro)
					cErro += CHR(13)+CHR(10)
				Else
					cErro := WmsFmtMsg(STR0089,{{"[VAR01]",cProduto}}) + CHR(13)+CHR(10) //  "Produto ([VAR01]) possui componentes com bloqueio (B1_MSBLQL): "
				EndIf
				cErro +=  WmsFmtMsg(STR0090,{{"[VAR01]",cPrdCmp}}) // "Componente ([VAR01]) bloqueado!"
				lRet := .F.
			EndIf
		EndIf
		D11->(dbSkip())
	EndDo
	RestArea(aAreaD11)
	RestArea(aAreaSB1)
Return lRet

//-----------------------------------------------------------
/*/{Protheus.doc} WmsVlDelB1
Validação de exclusão do SB1
@author felipe.m
@since 24/10/2016
@version 1.0
@param cCod, character, (Código do produto)
@param aSM0CodFil, array, (Filiais SM0)
/*/
//-----------------------------------------------------------
Function WmsVlDelB1(cCod,aSM0CodFil)
Local aAreaAnt := GetArea()
Local lRet     := .T.
Local nBusca   := 0
Local aFiliais := {}
Local lWmsNew  := SuperGetMv("MV_WMSNEW",.F.,.F.)

	dbSelectArea("DCG")
	DCG->(dbSetOrder(1)) //DCG_FILIAL+DCG_CODPRO+DCG_SERVIC
	aFiliais := Iif(!Empty(FwFilial("DCG")) .And. Empty(FwFilial("SB1")), aClone(aSM0CodFil), {xFilial("DCG")})
	For nBusca := 1 To Len(aFiliais)
		If	DCG->(dbSeek(aFiliais[nBusca]+cCod))
			Help("", 1, "MT010WMS")
			lRet := .F.
		EndIf
	Next nBusca

	If	lRet
		dbSelectArea("DCH")
		DCH->(dbSetOrder(1)) //DCH_FILIAL+DCH_CODPRO+DCH_CODZON
		aFiliais := Iif(!Empty(FwFilial("DCH")) .And. Empty(FwFilial("SB1")), aClone(aSM0CodFil), {xFilial("DCH")})
		For nBusca := 1 To Len(aFiliais)
			If	DCH->(dbSeek(aFiliais[nBusca]+cCod))
				Help("", 1, "MT010WM1")
				lRet := .F.
			EndIf
		Next nBusca
	EndIf

	If	lRet
		dbSelectArea("DC3")
		DC3->(dbSetOrder(1)) //DC3_FILIAL+DC3_CODPRO+DC3_LOCAL+DC3_ORDEM
		aFiliais := Iif(!Empty(FwFilial("DC3")) .And. Empty(FwFilial("SB1")), aClone(aSM0CodFil), {xFilial("DC3")})
		For nBusca := 1 To Len(aFiliais)
			If	DC3->(dbSeek(aFiliais[nBusca]+cCod))
				Help("", 1, "MT010WM2")
				lRet := .F.
			EndIf
		Next nBusca
	EndIf

	If	lRet
		If lWmsNew
			dbSelectArea("D11")
			D11->(dbSetOrder(2)) //D11_FILIAL+D11_PRDCMP+D11_PRDORI+D11_PRODUT
			aFiliais := Iif(!Empty(FwFilial("D11")) .And. Empty(FwFilial("SB1")), aClone(aSM0CodFil), {xFilial("D11")})
			For nBusca := 1 To Len(aFiliais)
				If	D11->(dbSeek(aFiliais[nBusca]+cCod))
					WmsMessage(STR0091,"WmsVlDelB1",,,,STR0092) //"Produto não poderá ser excluído."##"Verificar o cadastro de Estrutura de Armazenagem do WMS."
					lRet := .F.
				EndIf
			Next nBusca
		EndIf
	EndIf

	If	lRet
		If lWmsNew
			dbSelectArea("D11")
			D11->(dbSetOrder(1)) //D11_FILIAL+D11_PRODUT+D11_PRDORI+D11_PRDCMP
			aFiliais := Iif(!Empty(FwFilial("D11")) .And. Empty(FwFilial("SB1")), aClone(aSM0CodFil), {xFilial("D11")})
			For nBusca := 1 To Len(aFiliais)
				If	D11->(dbSeek(aFiliais[nBusca]+cCod))
					WmsMessage(STR0091,"WmsVlDelB1",,,,STR0092) //"Produto não poderá ser excluído."##"Verificar o cadastro de Estrutura de Armazenagem do WMS."
					lRet := .F.
				EndIf
			Next nBusca
		EndIf
	EndIf

RestArea(aAreaAnt)
Return lRet

//-----------------------------------------------------------
/*/{Protheus.doc} WmsVlDelB5
Validação de exclusão do SB5
@author felipe.m
@since 24/10/2016
@version 1.0
@param cCod, character, (Código do produto)
/*/
//-----------------------------------------------------------
Function WmsVlDelB5(cCod)
Local aAreaAnt := GetArea()
Local lRet     := .T.
Local lWmsNew  := SuperGetMv("MV_WMSNEW",.F.,.F.)

	dbSelectArea("DC3")
	DC3->(dbSetOrder(1)) //DC3_FILIAL+DC3_CODPRO+DC3_LOCAL+DC3_ORDEM
	If	DC3->(dbSeek(xFilial("DC3")+cCod))
		WmsMessage(STR0093,"WmsVlDelB5",,,,STR0094) //"Complemento produto não poderá ser excluído."##"Verificar o cadastro de Sequência de Abastecimento do WMS."
		lRet := .F.
	EndIf

	If	lRet
		If lWmsNew
			dbSelectArea("D11")
			D11->(dbSetOrder(2)) //D11_FILIAL+D11_PRDCMP+D11_PRDORI+D11_PRODUT
			If	D11->(dbSeek(xFilial("D11")+cCod))
				WmsMessage(STR0093,"WmsVlDelB5",,,,STR0095) //"Complemento produto não poderá ser excluído."##"Verificar o cadastro de Estrutura de Armazenagem do WMS."
				lRet := .F.
			EndIf
		EndIf
	EndIf

	If	lRet
		If lWmsNew
			dbSelectArea("D11")
			D11->(dbSetOrder(1)) //D11_FILIAL+D11_PRODUT+D11_PRDORI+D11_PRDCMP
			If	D11->(dbSeek(xFilial("D11")+cCod))
				WmsMessage(STR0093,"WmsVlDelB5",,,,STR0095) //"Complemento produto não poderá ser excluído."##"Verificar o cadastro de Estrutura de Armazenagem do WMS."
				lRet := .F.
			EndIf
		EndIf
	EndIf

RestArea(aAreaAnt)
Return lRet
//-----------------------------------------------------------
/*/{Protheus.doc} WmsUsrRot
Validação se usuário logado no SIGAACD
@author alexsander.correa
@since 25/11/2016
@version 1.0
@param cNomUsua
/*/
//-----------------------------------------------------------
Function WmsUsrRot(cNomUsua)
Local aColetor   := Directory("VT*.SEM")
Local nX         := 0
Local lRet       := .F.
Local cLinha     := ""
Local cNomUAux   := ""
Local cProgIni   := ""

	cNomUsua := AllTrim(cNomUsua)
	For nX := 1 to Len(aColetor)
		cLinha  := Memoread(aColetor[nX,1])
		cNomUAux:= AllTrim(Subs(cLinha,4,25))
		cProgIni:= AllTrim(Subs(cLinha,51,8))
		If cNomUAux == cNomUsua .And. cProgIni == 'SIGAACD'
			lRet := .T.
		EndIf
		If lRet
			Exit
		EndIf
	Next nX
Return lRet
//-----------------------------------------------------------
/*/{Protheus.doc} WmsAvalSB2
Validação se existe produto cadastrado no armazém
@author alexsander.correa
@since 25/11/2016
@version 1.0
@param cNomUsua
/*/
//-----------------------------------------------------------
Function WmsAvalSB2(cLocal,cProduto)
Local aAreaSB2  := SB2->(GetArea())
	dbSelectArea("SB2")
	SB2->(dbSetOrder(1))
	If !SB2->(dbSeek(xFilial("SB2")+cProduto+cLocal))
		CriaSB2(cProduto,cLocal)
	EndIf
	RestArea(aAreaSB2)
Return Nil
//-----------------------------------------------------------
/*/{Protheus.doc} WmsConsDC5
Validação da serviço
@author alexsander.correa
@since 25/11/2016
@version 1.0
/*/
//-----------------------------------------------------------
Function WmsConsDC5()
Local aAreaAnt  := GetArea()
Local cQuery    := ""
Local cAliasDC5 := ""
Local cOrdem    := ""
Local nTamOrdem := TamSX3("DC5_ORDEM")[1]
	cQuery := "SELECT MIN(DC5.DC5_ORDEM) DC5_ORDEM"
	cQuery +=  " FROM "+RetSqlName('DC5')+" DC5"
	cQuery += " WHERE DC5.DC5_FILIAL = '"+xFilial("DC5")+"'"
	cQuery +=   " AND DC5.DC5_SERVIC = '"+DC5->DC5_SERVIC+"'"
	cQuery +=   " AND DC5.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasDC5 := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasDC5,.F.,.T.)
	If (cAliasDC5)->(!Eof())
		cOrdem := PadL((cAliasDC5)->DC5_ORDEM,nTamOrdem)
	EndIf
	(cAliasDC5)->(dbCloseArea())
	RestArea(aAreaAnt)
Return cOrdem
//-----------------------------------------------------------
/*/{Protheus.doc} WmsConsDC6
Validação da tarefa
@author alexsander.correa
@since 25/11/2016
@version 1.0
/*/
//-----------------------------------------------------------
Function WmsConsDC6()
Local aAreaAnt  := GetArea()
Local cQuery    := ""
Local cAliasDC6 := ""
Local cOrdem    := ""
	cQuery := "SELECT MIN(DC6.DC6_ORDEM) DC6_ORDEM"
	cQuery +=  " FROM "+RetSqlName('DC6')+" DC6"
	cQuery += " WHERE DC6.DC6_FILIAL = '"+xFilial("DC6")+"'"
	cQuery +=   " AND DC6.DC6_TAREFA = '"+DC6->DC6_TAREFA+"'"
	cQuery +=   " AND DC6.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasDC6 := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasDC6,.F.,.T.)
	If (cAliasDC6)->(!Eof())
		cOrdem := (cAliasDC6)->DC6_ORDEM
	EndIf
	(cAliasDC6)->(dbCloseArea())
	RestArea(aAreaAnt)
Return cOrdem

//-----------------------------------------------------------
/*/{Protheus.doc} WmsSldAmz
Validação da tarefa
@author alexsander.correa
@since 25/11/2016
@version 1.0
/*/
//-----------------------------------------------------------
Function WmsSldAmz(cArmazem, cProduto)
Local lRet      := .T.
Local cQuery    := ""
Local cAliasQry := ""
Local cVar01    := ""
Local lWmsNew   := SuperGetMv("MV_WMSNEW",.F.,.F.)
Local aAreaAnt  := GetArea()

Default cArmazem := ""
Default cProduto := ""

	If lWmsNew .And. IntWms(IIf(!Empty(cProduto),cProduto,""))
		cQuery := " SELECT DISTINCT D14.D14_PRODUT PRODUTO"
		cQuery +=   " FROM "+RetSQLName("D14")+" D14"
		cQuery +=  " WHERE D14.D14_FILIAL = '"+xFilial("D14")+"'"
		If !Empty(cArmazem)
			cQuery +=    " AND D14.D14_LOCAL = '"+cArmazem+"'"
		EndIf
		If !Empty(cProduto)
			cQuery +=    " AND D14.D14_PRDORI = '"+cProduto+"'"
		EndIf
		cQuery +=    " AND D14.D_E_L_E_T_ = ' '"
		cQuery +=  " UNION ALL"
		cQuery += " SELECT DISTINCT SBF.BF_PRODUTO PRODUTO"
		cQuery +=   " FROM "+RetSQLName("SBF")+" SBF"
		cQuery +=  " WHERE SBF.BF_FILIAL = '"+xFilial("SBF")+"'"
		If !Empty(cArmazem)
			cQuery +=  " AND SBF.BF_LOCAL = '"+cArmazem+"'"
		EndIf
		If !Empty(cProduto)
			cQuery +=  " AND SBF.BF_PRODUTO = '"+cProduto+"'"
		EndIf
		cQuery +=    " AND SBF.BF_QUANT > 0"
		cQuery +=    " AND SBF.D_E_L_E_T_ = ' '"
		cAliasQry := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
		If (cAliasQry)->(!Eof())
			If !Empty(cArmazem) .And. !Empty(cProduto)
				cVar01 := STR0097 + "/" + STR0098 //armazem/produto
			ElseIf !Empty(cArmazem)
				cVar01 := STR0097 //armazem
			Else
				cVar01 := STR0098 //produto
			EndIf
			WmsMessage(WmsFmtMsg(STR0096,{{"[VAR01]",cVar01}}),"WmsSldAmz") //-- Há saldos em estoque para o [VAR01], alteração não permitida!",
			lRet := .F.
		EndIf
		(cAliasQry)->(dbCloseArea())
	EndIf
	RestArea(aAreaAnt)

Return lRet

//-----------------------------------------------------------
/*/{Protheus.doc} WMSServCQ
Sugestão de serviço WMS na rotina de baixa de CQ
@author  guilherme.metzger
@since   25/04/2016
@version 1.0
/*/
//-----------------------------------------------------------
Function WMSServCQ()
Local aAreaSB5 := SB5->(GetArea())
Local cServico := ""
	If IntWMS(SD7->D7_PRODUTO)
		SB5->(DbSetOrder(1))
		If SB5->(DbSeek(xFilial('SB5')+SD7->D7_PRODUTO))
			cServico := SB5->B5_SERVENT
		EndIf
	EndIf
RestArea(aAreaSB5)
Return cServico

//-----------------------------------------------------------
/*/{Protheus.doc} WmsVlStr
Valida se o conteúdo enviado por parâmetro possui caractere especial
@author  felipe.m
@since   05/05/2017
@version 1.0
/*/
//-----------------------------------------------------------
Function WmsVlStr(cConteudo)
Local cCaracter := "!@#$%¨&*()+{}^~´`][;.>,<=/¢¬§ªº'?*|"+'"'
Local nI := 0
Local lRet := .T.

	If Empty(cConteudo)
		Return .T.
	EndIf

	For nI := 1 To Len(cConteudo)
		If SubStr(cConteudo,nI,1) $ cCaracter
			lRet := .F.
			Exit
		EndIf
	Next nI

	If !lRet
		WmsMessage(STR0099,"WmsVlStr",1) // Campo contém caracteres inválidos
	EndIf
Return lRet

//-----------------------------------------------------------
/*/{Protheus.doc} WmsArmUnit
Valida se o armazém é unitizado
@author  felipe.m
@since   25/05/2017
@version 1.0
/*/
//-----------------------------------------------------------
Function WmsArmUnit(cArmazem)
Local aAreaNNR := NNR->(GetArea())

	// Carrega sob demanda
	If __cLastArmz != cArmazem .Or. __lArmzUnit == Nil
		If WmsX312118("NNR","NNR_AMZUNI",.T.) // Verifica no SX3
			__lArmzUnit := (Posicione("NNR",1,xFilial("NNR")+cArmazem,"NNR_AMZUNI") == "1")
		Else
			__lArmzUnit := .F.
		EndIf
		__cLastArmz := cArmazem
	EndIf

RestArea(aAreaNNR)
Return __lArmzUnit

//------------------------------------------------------------------------------
Function WmsGerUnit(lUsado,lManual,lUnitPad,cIdUnitiz,cTipUnit)
//------------------------------------------------------------------------------
Local aAreaD0Y := D0Y->(GetArea())
Local nCont    := ""
Local oTipUnit := Nil

Default lUsado    := .T.
Default lManual   := .F.
Default lUnitPad  := .F.
Default cIdUnitiz := ""
Default cTipUnit  := ""

	// Busca o unitizador padrão
	If lUnitPad
		oTipUnit := WMSDTCUnitizadorArmazenagem():New()
		oTipUnit:FindPadrao()
		cTipUnit:= oTipUnit:GetTipUni()
		oTipUnit:Destroy()
	EndIf
	If Empty(cIdUnitiz)
		cIdUnitiz := WMSProxSeq("MV_WMSIDUN","D0Y_IDUNIT")
		//Tratamento para procutar uma etiqueta válida
		D0Y->(DbSetOrder(1))
		If D0Y->(DbSeek(xFilial('D0Y')+cIdUnitiz))
			For nCont := 1 To 60
				Sleep(1)
				cIdUnitiz := WMSProxSeq("MV_WMSIDUN","D0Y_IDUNIT")
				If D0Y->(DbSeek(xFilial('D0Y')+cIdUnitiz))
					cIdUnitiz := ""
				Else
					Exit
				EndIf
			Next nCont
		EndIf
	EndIf
	// Grava dados do unitizador
	If !Empty(cIdUnitiz)
		RecLock("D0Y",.T.)
		D0Y->D0Y_FILIAL := xFilial("D0Y")
		D0Y->D0Y_IDUNIT := cIdUnitiz
		D0Y->D0Y_TIPUNI := cTipUnit
		D0Y->D0Y_DATGER := dDataBase
		D0Y->D0Y_HORGER := Time()
		D0Y->D0Y_USUARI := __cUserID
		D0Y->D0Y_TIPGER := Iif(lManual,'1','2') // 1=Manual;2=Automatica
		D0Y->D0Y_USADO  := Iif(lUsado,'1','2')  // 1=Sim;2=Nao
		D0Y->D0Y_IMPRES := '2' // 1=Sim;2=Nao
		D0Y->(MsUnlock())
	EndIf

RestArea(aAreaD0Y)
Return cIdUnitiz

//-----------------------------------------------------------
/*/{Protheus.doc} WmsPrdPai
Valida se o armazém é unitizado
@author  felipe.m
@since   25/05/2017
@version 1.0
/*/
//-----------------------------------------------------------
Function WmsPrdPai(cProduto)
Local aAreaD11 := D11->(GetArea())
Local lRet     := .F.

	D11->(dbSetOrder(1))
	If D11->(dbSeek(xFilial("D11")+cProduto))
		lRet := .T.
	EndIf

RestArea(aAreaD11)
Return lRet
//--------------------------------------------------------------------
/*/{Protheus.doc} WmsComCons
Função chamada pelo valid do campo D3_PEDCOM para forçar a utilização do F3
que trará as informações necessárias para preencher os campos D3_ITPC e D3_FILPED

@author felipe.m
@since  26/06/2017
@obs   Squad WMS
@version 2.0
/*/
//--------------------------------------------------------------------
Function WmsComCons()
Local nFilPed := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_FILPED"}) // aHeader: variável private do mata410
Local nNumDoc := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PEDCOM"})
Local nItem := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_ITPC"})
Local nProd := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRODUTO"})
Local cNumDoc := M->C6_PEDCOM
Local cItem := aCols[n][nItem] // Numero do Item do Pedido
Local cFilPed := aCols[n][nFilPed] // Filial do Ped. de compras
Local cProd := aCols[n][nProd]
local lRet := .T.

	dbSelectArea("SC7")
	SC7->(dbSetOrder(1))
	If SC7->(dbSeek(cFilPed + cNumDoc + cItem))
		If cProd <> SC7->C7_PRODUTO
			Help( ,,'A410CROSWMS',, STR0100, 1, 0 ) // "O item do pedido de compras não é o mesmo que o item do pedido de venda."
			lRet := .F.
		EndIf
	Else
		Help( ,,'A410CROSWMS',, STR0101, 1, 0 ) // "É necessário que o preenchimento deste campo seja via consulta padrão do sistema(F3)."
		lRet := .F.
	EndIf
Return lRet
//--------------------------------------------------------------------
/*/{Protheus.doc} WmsVenComp
Função apra verificar se existe amarração de CrossDoc do novo WMS

@author felipe.m
@since  26/06/2017
@obs   Squad WMS
@version 2.0
/*/
//--------------------------------------------------------------------
Function WmsVenComp(aCols,aHeader)
Local nFilPed := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_FILPED"}) // aHeader: variável private do mata410
Local nNumDoc := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PEDCOM"})
Local nItem := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_ITPC"})
Local lRet := .T.
Local nI := 0
Local nX := 0

	For nX := 1 to Len(aCols)  //ITENS DO PEDIDO DE COMPRAS
		If !Empty(aCols[nX][nFilPed]) .and. !Empty(aCols[nX][nNumDoc]) .and. !Empty(aCols[nX][nItem])
			nI++
		Endif
	Next nX

	If nI > 0
		Help( ,,'A410CROSWMS',, STR0102, 1, 0 ) // "O pedido não pode ser excluído, pois possui integração com o pedido de compras via WMS."
		lRet:= .F.
	EndIf
Return lRet
//--------------------------------------------------------------------
/*/{Protheus.doc} WmsTipEst
Função que retorna o tipo de estrutura do endereço

@author Squad WMS
@since  04/10/2017
@version 1.0
/*/
//--------------------------------------------------------------------
Function WmsTipEst(cArmazem,cEndereco)
Local cTipEst   := ""
Local cQuery    := ""
Local cAliasQry := ""
	cQuery := " SELECT DC8.DC8_TPESTR" 
	cQuery +=   " FROM "+RetSqlName('SBE')+" SBE"
	cQuery +=  " INNER JOIN "+RetSqlName('DC8')+" DC8"
	cQuery +=     " ON DC8.DC8_FILIAL = '"+xFilial('DC8')+"'"
	cQuery +=    " AND DC8.DC8_CODEST = SBE.BE_ESTFIS"
	cQuery +=    " AND DC8.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE SBE.BE_FILIAL  = '"+xFilial('SBE')+"'"
	cQuery +=    " AND SBE.BE_LOCAL   = '"+cArmazem+"'"
	cQuery +=    " AND SBE.BE_LOCALIZ = '"+cEndereco+"'"
	cQuery +=    " AND SBE.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	If (cAliasQry)->(!EoF())
		cTipEst := (cAliasQry)->DC8_TPESTR
	EndIf
	(cAliasQry)->(DbCloseArea())
Return cTipEst
//--------------------------------------------------------------------
/*/{Protheus.doc} WmsEndUnit
Função para verificar se o armzém é unitizado

@author Squad WMS
@since  29/09/2017
@version 1.0
/*/
//--------------------------------------------------------------------
Function WmsEndUnit(cArmazem,cEndereco)
Local lRet      := .F.
	If !Empty(cArmazem) .And. !Empty(cEndereco)
		If WmsArmUnit(cArmazem)
			If !(WmsTipEst(cArmazem,cEndereco) $ '2|7|8')
				lRet := .T.
			EndIf
		EndIf
	EndIf
Return lRet
//--------------------------------------------------------------------
/*/{Protheus.doc} WmsVldEti
Função para verificar se a etiqueta existe

@author Squad WMS
@since  02/10/2017
@version 1.0
/*/
//--------------------------------------------------------------------
Function WmsVldEti(cArmazem,cEndereco,cIdUnit,cTipUni,lGeraEtiq)
Local lRet      := .T.
Local aAreaD0Y  := D0Y->(GetArea())
Local lExistEtq := .F.
Local oEtiqUnit := WMSDTCEtiquetaUnitizador():New()
Local cArmazOri := ""
Local cEnderOri := ""

Default cTipUni   := ""
Default lGeraEtiq := .T.
	
	// Quando for pelo coletor sempre inicializa a variavel cTipUni
	If IsTelNet()
		cTipUni := ""
	EndIf
	oEtiqUnit:SetIdUnit(cIdUnit)
	If oEtiqUnit:LoadData()
		lExistEtq := .T.
		cTipUni := If(!Empty(oEtiqUnit:GetTipUni()),oEtiqUnit:GetTipUni(),cTipUni)
	EndIf
	If lRet .And. Empty(cTipUni) 
		If IsTelNet()
			cTipUni := WmsRdTipUn(cIdUnit)
		EndIf
		// Verifica se tipo de unitizador foi informado
		If Empty(cTipUni)
			// Mensagem que tipo não informado
			WmsMessage(STR0103,WMSXFUNA01,1) // Tipo do unitizador não informado!
			lRet := .F.
		EndIf
	EndIf
	
	If lRet .And. !lExistEtq
		 // Cria etiqueta caso não exista
		If lGeraEtiq
			oEtiqUnit:SetIdUnit(cIdUnit)
			oEtiqUnit:SetTipUni(cTipUni)
			oEtiqUnit:SetTipGer("2")
			oEtiqUnit:SetUsado("1")
			oEtiqUnit:SetImpresso("1")
			If !oEtiqUnit:RecordD0Y()
				WmsMessage(oEtiqUnit:GetErro(),WMSXFUNA02,1) // Tipo do unitizador não informado!
				lRet := .F.
			EndIf
		Else
			WmsMessage(WmsFmtMsg(STR0104,{{"[VAR01]",cIdUnit}}),WMSXFUNA04) //Etiqueta do unitizador [VAR01] não cadastrada!
			lRet := .F.
		EndIf
	EndIf
	// Validar se etiqueta existe em outro endereço
	If lRet .And. lExistEtq
		If !WmsVldEnUn(cArmazem,cEndereco,cIdUnit,@cArmazOri,@cEnderOri)
			// Verifica se utilizado está em um armazem e endereço diferente do lido
			WmsMessage(WmsFmtMsg(STR0105,{{"[VAR01]",cIdUnit},{"[VAR02]",cArmazem},{"[VAR03]",cEndereco},{"[VAR04]",cArmazOri},{"[VAR05]",cEnderOri}}),WMSXFUNA05,1) // Unitizador [VAR01] não pertence ao armazem/endereço: [VAR02]/[VAR03] inventáriado! Verifique o armazém [VAR04] e endereço [VAR05]. 
			lRet := .F.
		EndIf
	EndIf
	RestArea(aAreaD0Y)
Return lRet
//--------------------------------------------------------------------
/*/{Protheus.doc} WmsPrdCmp
Função para verificar se o produto faz parte de uma estrutura

@author Squad WMS
@since  11/10/2017
@version 1.0
/*/
//--------------------------------------------------------------------
Function WmsPrdCmp(cProduto)
Local lRet := .F.
	D11->(DbSetOrder(2)) //D11_FILIAL+D11_PRDCMP+D11_PRDORI+D11_PRODUT
	If D11->(DbSeek(xFilial('D11')+cProduto))
		lRet := .T.
	EndIf
Return lRet
//--------------------------------------------------------------------
/*/{Protheus.doc} WmsEndDoca
Verifica se o endereço informado é uma DOCA.

@author Amanda Rosa Vieira
@since  13/10/2017
@version 1.0
/*/
//--------------------------------------------------------------------
Function WmsEndDoca(cArmazem,cEndereco)
Local lRet := .F.
	If WmsTipEst(cArmazem,cEndereco) == '5'
		lRet := .T.
	EndIf
Return lRet
//--------------------------------------------------------------------
/*/{Protheus.doc} WmsRdTipUn
Efetua a leitura tipo de unitizador quando IsTelNet()

@author Squad WMS Protheus
@since  13/12/2017
@version 1.0
/*/
//--------------------------------------------------------------------
Function WmsRdTipUn(cIdUnit)
Local lRet    := .T.
Local cTipUni := Space(TamSX3("D0T_CODUNI")[1])
Local aTela     := VtSave()
	WMSVTCabec(STR0106, .F., .F., .T.) // Unitizador
	@ 01,00 VTSay STR0107 //Id Unitizador
	@ 02,00 VTSay cIdUnit
	@ 03,00 VtSay STR0108 //Tipo Unitiz.
	@ 04,00 VtGet cTipUni Picture '@!' Valid WmsVldTpUn(cTipUni) F3 "D0T"
	VtRead()
	
	If VtLastkey() == 27
		cTipUni := ""
	EndIf
	VtRestore(,,,,aTela)
Return cTipUni
//--------------------------------------------------------------------
/*/{Protheus.doc} WmsVldTpUn
Verifica tipo de unitizador

@author Squad WMS Protheus
@since  13/12/2017
@version 1.0
/*/
//--------------------------------------------------------------------
Function WmsVldTpUn(cTipUni)
Local lRet     := .T.
Local oTipUnit := WMSDTCUnitizadorArmazenagem():New()
	//Se o tipo de unitizador  está vazio retorna true para que mostre a lista de embarques pendentes
	If Empty(cTipUni)
		lRet := .F.
	EndIf
	If lRet
		oTipUnit:SetTipUni(cTipUni)
		If !oTipUnit:LoadData()
			WmsMessage(oTipUnit:GetErro(),WMSXFUNA07)
			VTKeyBoard(Chr(20))
			lRet := .F.
		EndIf
	EndIf
	oTipUnit:Destroy()
Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} WmsVldEnUn
Valida o endereço do unitizador, caso esteja em outro endereço retorna falso
Retorna o armazém e endereço onde está este unitizador

@author Squad WMS Protheus
@since  13/12/2017
@version 1.0
/*/
//--------------------------------------------------------------------
Function WmsVldEnUn(cArmazem,cEndereco,cIdUnit,cArmazOri,cEnderOri)
Local lRet      := .T.
Local cQuery    := ""
Local cAliasQry := GetNextAlias()

	cArmazOri := cArmazem
	cEnderOri := cEndereco

	cQuery := " SELECT D14.D14_LOCAL,"
	cQuery +=        " D14.D14_ENDER"
	cQuery +=  " FROM "+RetSqlName('D14')+" D14"
	cQuery += " WHERE D14.D14_FILIAL = '"+xFilial("D14")+"'"
	cQuery +=   " AND D14.D14_IDUNIT = '" + cIdUnit + "'"
	cQuery +=   " AND D14.D14_QTDEST > 0"
	cQuery +=   " AND D14.D_E_L_E_T_ = ' '"
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	If (cAliasQry)->(!EoF())
		cArmazOri := (cAliasQry)->D14_LOCAL
		cEnderOri := (cAliasQry)->D14_ENDER
	EndIf
	(cAliasQry)->(DbCloseArea())

	If !(cArmazOri+cEnderOri == cArmazem+cEndereco)
		lRet := .F.
	EndIf

Return lRet
//----------------------------------------------------------
// Finaliza log de divergências
//----------------------------------------------------------
Static Function GravLogDiv(lIsJob, aLog)
Local lRet     := .T.
Local nHandle  := 0
Local n1Cnt    := 0
Local cLogFile := ""
Local cWmsDoc  := "" 
Local cHora    := Time()

Default lIsJob := .F.

	cLogFile := IIf(lIsJob,"WMSEXJB_","WMSEXVT")+DToS(dDataBase)+StrTran(cHora,":","")+".LOG"
	cWmsDoc  := SuperGetMV("MV_WMSDOC",.F.,"")
	If !Empty(cWmsDoc)
		cWmsDoc := AllTrim(cWmsDoc)
		If Right(cWmsDoc,1) $ "/\"
			cWmsDoc := Left(cWmsDoc,Len(cWmsDoc)-1)
		EndIf
		cLogFile := cWmsDoc+"/"+cLogFile
	EndIf

	If !File(cLogFile)
		If (nHandle := MSFCreate(cLogFile,0)) <> -1
			lRet := .T.
		EndIf
	Else
		If (nHandle := FOpen(cLogFile,2)) <> -1
			FSeek(nHandle,0,2)
			lRet := .T.
		EndIf
	EndIf
	If lRet
		FWrite(nHandle,STR0110+CRLF) // Microsiga Protheus WMS - LOG de execução da ordem de serviço automática
		FWrite(nHandle,"-----------------------------------------------------------------------"+CRLF)
		For n1Cnt := 1 To Len(aLog)
			FWrite(nHandle,aLog[n1Cnt]+CRLF)
		Next
		FClose(nHandle)
	EndIf

Return cLogFile
//--------------------------------------------------------------------
/*/{Protheus.doc} WMSChkPrg
Permite validar o programa executado e abortar quando necessário
@author Squad WMS Protheus
@since  28/09/2018
@version 1.0
@param cPrograma, character, Programa executado
@param cAcao, character, Lista de ações a serem validadas separadas por "|"
		exemplo: "1|2|3"
	1 - Novo WMS
	2 - Bloqueado temporáriamente

/*/
//--------------------------------------------------------------------
Function WMSChkPrg(cPrograma, cAcao)
Local lRet    := .T.
Local lWmsNew := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local aAcao   := StrTokArr(cAcao,'|')
Local nAcao   := 0
Local nI      := 0
	If !Empty(aAcao)
		For nI := 1 To Len(aAcao)
			nAcao := Val(aAcao[nI])
			Do Case
				Case nAcao == 1
					If !lWmsNew
						WmsMessage(WmsFmtMsg(STR0004,{{"[VAR01]",cPrograma}}),"WMSChkPrg",1) //Programa [VAR01] disponível somente para controle de estoque por endereço exclusivo do WMS (D14).
						lRet := .F.
					EndIf
				Case nAcao == 2
					If cPrograma == 'WMSA520'
						WmsMessage(WmsFmtMsg(STR0111,{{"[VAR01]",cPrograma}}),"WMSChkPrg",1) //Programa [VAR01] indisponível temporáriamente.
						lRet := .F.
					EndIf
				Case nAcao == 3
					If !lWmsNew
						If cPrograma == 'WMSC035'
							cProgMenu := 'MATA226'
							lRet := .F.
						ElseIf cPrograma == 'WMSR457'
							cProgMenu := 'MATR245'
							lRet := .F.
						ElseIf cPrograma == 'WMSR455'
							cProgMenu := 'MATR355'
							lRet := .F.
						ElseIf cPrograma == 'WMSR456'
							cProgMenu := 'MATR275'
							lRet := .F.
						EndIf
						If !lRet
							WmsMessage(WmsFmtMsg(STR0004,{{"[VAR01]",cPrograma}}),"WMSChkPrg",1,,,WmsFmtMsg(STR0112,{{"[VAR01]",cProgMenu}})) // Disponível somente para controle de estoque por endereço exclusivo do WMS (D14). // Cadastre o programa [VAR01] no menu para controle de estoque por endereço ERP (SBF).
						EndIf
					EndIf
			EndCase
			If !lRet
				Exit
			EndIf
		Next
	EndIf
Return lRet
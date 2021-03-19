#INCLUDE "DAXR820.CH"
#INCLUDE "PROTHEUS.CH"

Static cAliasTop
 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ DAXR820  ³ Autor ³ CICERO ODILIO CRUZ  ³ Data ³ 26/09/2019 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ordens de Producao DAXIA                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
USER FUNCTION DAXR820()
Local oReport
PRIVATE lSwHead := .T.
/*
IF dDatabase >= CTOD("15/10/2019")
	cMsgP := "Periodo de valida��o expirado."
	cMsgS := "Solicite um novo per�odo de valida��o."
	Help( ,, 'DAXR820 (001)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})				
	RETURN NIL
ENDIF
*/

//-- Verifica se o SH8 esta locado para atualizacao por outro processo                
IF !IsLockSH8()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Interface de impressao                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport := ReportDef()
	IF !oReport:PrintDialog()
		DBSELECTAREA("SH8")
		DBCLEARFILTER()
		DBCLOSEAREA()
		RETURN NIL
	ENDIF
ENDIF
	
RETURN NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³Felipe Nunes Toledo    ³ Data ³27/09/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³MATR820                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()
LOCAL oReport
LOCAL oSection1
LOCAL oSection3
LOCAL oSection6
LOCAL aOrdem		:= {STR0002,STR0003,STR0004,STR0005}	//"Por Numero"###"Por Produto"###"Por Centro de Custo"###"Por Prazo de Entrega"
LOCAL cTitle		:= STR0039 //"Ordens de Producao"
LOCAL nlargDesc		:= 0 
LOCAL oTFont1c 		:= TFont():New('Verdana',,-13,.T.)
Local oTFont1d 		:= TFont():New("Courrier New",13,13,,.T.,,,,.F.,.F.)

cAliasTop := GetNextAlias()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³                                                                        ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:= TReport():New("DAXR820",cTitle,"MTR820", {|oReport| ReportPrint(oReport, cAliasTop)},OemToAnsi(STR0001)) //"Este programa ira imprimir a Rela‡„o das Ordens de Produ‡„o"
oReport:SetPortrait()     // Define a orientacao de pagina do relatorio como retrato.
oReport:HideParamPage()   // Desabilita a impressao da pagina de parametros.
oReport:SetCustomText( {|| CabecPak(oReport) }) 
oReport:nFontBody	:= 9  // Define o tamanho da fonte.
oReport:nLineHeight	:= 50 // Define a altura da linha.
//-------------------------------------------------------------------------------------
//   Define as Dimens�es do Relat�rio (/*A4 210 x 297 mm*/)
//-------------------------------------------------------------------------------------
oReport:oPage:setPaperSize(9/*A4 210 x 297 mm*/)

//-------------------------------------------------------------------------------------
//   Redefine a Margem Esquerda do Relat�rio
//   (Obs.: oReport:LeftMargin()->Retorna a Margem)
//-------------------------------------------------------------------------------------
oReport:SetLeftMargin(7.5)

oReport:oFontheader   		:= oTFont1c

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas - MTR820                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01            // Da OP                                 ³
//³ mv_par02            // Ate a OP                              ³
//³ mv_par03            // Da data                               ³
//³ mv_par04            // Ate a data                            ³
//³ mv_par05            // Imprime roteiro de operacoes          ³
//³ mv_par06            // Imprime codigo de barras              ³
//³ mv_par07            // Imprime Nome Cientifico               ³
//³ mv_par08            // Imprime Op Encerrada                  ³
//³ mv_par09            // Impr. por Ordem de                    ³
//³ mv_par10            // Impr. OP's Firmes, Previstas ou Ambas ³
//³ mv_par11            // Impr. Item Negativo na Estrutura      ³
//³ mv_par12            // Imprime Lote/Sub-Lote                 ³
//³ mv_par13            // Imprime operações vencidas?           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(oReport:GetParam(),.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da secao utilizada pelo relatorio                               ³
//³                                                                        ³
//³TRSection():New                                                         ³
//³ExpO1 : Objeto TReport que a secao pertence                             ³
//³ExpC2 : Descricao da secao                                              ³
//³ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   ³
//³        sera considerada como principal para a secao.                   ³
//³ExpA4 : Array com as Ordens do relatorio                                ³
//³ExpL5 : Carrega campos do SX3 como celulas                              ³
//³        Default : False                                                 ³
//³ExpL6 : Carrega ordens do Sindex                                        ³
//³        Default : False                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

IF mv_par07 == 1 
   nlargDesc := 150
ELSE   	
	nlargDesc := 80
ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sessao 1 (oSection1)                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1 := TRSection():New(oReport,STR0050,{"SC2","SB1","SC5","SA1"},aOrdem) // "Ordens de Produção"
oSection1:SetLineStyle() //Define a impressao da secao em linha
oSection1:SetReadOnly()

TRCell():New(oSection1,'C2_NUM'		,'SC2',STR0073   ,PesqPict('SC2','C2_NUM')	 ,TamSX3('C2_NUM')[1]	  ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,'C2_PRODUTO'	,'SC2',/*Titulo*/,/*Picture*/					,/*Tamanho*/		   ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,'B1_DESC' 	,'SB1',/*Titulo*/,/*Picture*/					,nlargDesc,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,.T. )
TRCell():New(oSection1,'C2_EMISSAO' ,'SC2',STR0040   ,PesqPict("SC2","C2_EMISSAO")	,10						,/*lPixel*/,/*{|| DTOC(dDataBase) }*/)
TRCell():New(oSection1,'C5_CLIENTE'	,'SC5',/*Titulo*/,/*Picture*/					,/*Tamanho*/			,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,'C5_LOJACLI'	,'SC5',/*Titulo*/,/*Picture*/					,/*Tamanho*/			,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,'A1_NOME'  	,'SA1',/*Titulo*/,/*Picture*/					,/*Tamanho*/			,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,'QtdeProd'	,'SC2',STR0041   ,PesqPict("SC2","C2_QUANT")	,TamSX3("C2_QUANT")[1]	,/*lPixel*/,{|| aSC2Sld(cAliasTop) }) //STR0041
TRCell():New(oSection1,'C2_QUANT'	,'SC2',STR0042   ,/*Picture*/					,/*Tamanho*/			,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,'OpQuant'  	,'SC2',STR0043   ,PesqPict("SC2","C2_QUANT")	,TamSX3("C2_QUANT")[1]	,/*lPixel*/,{|| (cAliasTop)->C2_QUANT - (cAliasTop)->C2_QUJE })
TRCell():New(oSection1,'B1_UM'	 	,'SB1',/*Titulo*/,/*Picture*/					,/*Tamanho*/			,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,'C2_CC'		,'SC2',/*Titulo*/,/*Picture*/					,/*Tamanho*/			,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,'C2_STATUS'	,'SC2',/*Titulo*/,/*Picture*/					,/*Tamanho*/			,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,'C2_DATPRI'	,'SC2',/*Titulo*/,/*Picture*/					,/*Tamanho*/			,/*lPixel*/,{|| DTOC((cAliasTop)->C2_DATPRI) })
TRCell():New(oSection1,'C2_DATPRF'	,'SC2',/*Titulo*/,/*Picture*/					,/*Tamanho*/			,/*lPixel*/,{|| DTOC((cAliasTop)->C2_DATPRF) })
TRCell():New(oSection1,'C2_DATAJI'	,'SC2',/*Titulo*/,/*Picture*/					,/*Tamanho*/			,/*lPixel*/,{|| DTOC((cAliasTop)->C2_DATAJI) })
TRCell():New(oSection1,'C2_DATAJF'	,'SC2',/*Titulo*/,/*Picture*/					,/*Tamanho*/			,/*lPixel*/,{|| DTOC((cAliasTop)->C2_DATAJF) })
TRCell():New(oSection1,'RealIni'	,'SC2',STR0044   ,/*Picture*/                 ,8						,/*lPixel*/,{|| "__/__/__" })
TRCell():New(oSection1,'RealFim'	,'SC2',STR0045   ,/*Picture*/                 ,8						,/*lPixel*/,{|| "__/__/__" })
TRCell():New(oSection1,'C2_OBS'		,'SC2',/*Titulo*/,/*Picture*/					,/*Tamanho*/			,/*lPixel*/,/*{|| code-block de impressao }*/)

oSection1:Cell('B1_DESC'  ):SetCellBreak()
oSection1:Cell('C2_EMISSAO'):SetCellBreak()
oSection1:Cell('A1_NOME'  ):SetCellBreak()
oSection1:Cell('C2_QUANT' ):SetCellBreak()
oSection1:Cell('OpQuant'  ):SetCellBreak()
oSection1:Cell('B1_UM'    ):SetCellBreak()
oSection1:Cell('C2_CC'    ):SetCellBreak()
oSection1:Cell('C2_STATUS'):SetCellBreak()
oSection1:Cell('C2_DATPRF'):SetCellBreak()
oSection1:Cell('C2_DATAJF'):SetCellBreak()
oSection1:Cell('RealFim'  ):SetCellBreak()
oSection1:Hide() // Vou ocultar mas  os  dados ser�o contiar�o a ser processados caso eu queira reutilizar

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sessao 2 (oSection2) - ESPECIFICA��O                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection2 := TRSection():New(oSection1,"Especifica��es",{"SB1","QP7","QP8","QP1"},/*Ordem*/) //"Especifi��es"
oSection2:SetHeaderBreak()
oSection2:SetReadOnly()

TRCell():New(oSection2,'QP1_DESCPO' ,'QP1',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,'VlrPadrao' ,'QP7', "Valor Padr�o",/*Picture*/ , 10,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,'VlrMinimo' ,'QP7', "Valor Minimo",/*Picture*/ , 10,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,'VlrMaximo' ,'QP7', "Valor M�ximo",/*Picture*/ , 10,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,'PRE'       ,'QP7', "PRE",/*Picture*/ , 10,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,'APRV'      ,'QP7', "APRV",/*Picture*/ , 10,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,'REPR'      ,'QP7', "REPR",/*Picture*/ , 10,/*lPixel*/,/*{|| code-block de impressao }*/)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sessao 3 (oSection4)                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection4 := TRSection():New(oSection1,STR0052,{"SG2","SH8","SH1","SH4"},/*Ordem*/) //"Operações"
oSection4:SetHeaderBreak()
oSection4:SetReadOnly()

TRCell():New(oSection4,'G2_OPERAC'	,'SG2',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/)
TRCell():New(oSection4,'G2_DESCRI'	,'SG2',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,.T.)
TRCell():New(oSection4,'G2_FERRAM'	,'SG2',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection4,'H4_DESCRI'	,'SH4',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/)
TRCell():New(oSection4,'G2_RECURSO' ,'SG2',/*Titulo*/,/*Picture*/,10 		   ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection4,'H1_DESCRI'	,'SH1',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

oSection4:Cell('H1_DESCRI'):HideHeader()
oSection4:Cell('H4_DESCRI'):HideHeader()
oSection4:Cell('G2_DESCRI'):HideHeader()


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sessao 4 (oSection5)                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection5 := TRSection():New(oSection4,STR0053,{"SG2","SH8","SH1","SH4"},/*Ordem*/) //"Tempo Rot. Oper."
oSection5:SetLineStyle() //Define a impressao da secao em linha
oSection5:SetReadOnly()

TRCell():New(oSection5,'H8_DTINI'	,'SH8',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection5,'H8_HRINI'	,'SH8',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection5,'H8_DTFIM'	,'SH8',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection5,'H8_HRFIM'	,'SH8',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection5,'IniAloc'	,'SH8',STR0046   ,'@!'  , 24        ,/*lPixel*/,{|| " ____/ ____/____ ___:___" })
TRCell():New(oSection5,'FimAloc'	,'SH8',STR0047   ,'@!'  , 24        ,/*lPixel*/,{|| " ____/ ____/____ ___:___" })
TRCell():New(oSection5,'H8_QUANT'	,'SH8',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection5,'SEP01'		,'SH8'," "   ,'@!'  , 1        ,/*lPixel*/,{|| " " })
TRCell():New(oSection5,'QtdeProd'	,'SH8',STR0048   ,/*Picture*/, 12       ,/*lPixel*/,{|| Space(12) })
TRCell():New(oSection5,'SEP02'		,'SH8'," "   ,'@!'  , 1        ,/*lPixel*/,{|| " " })
TRCell():New(oSection5,'QtdPerda'	,'SH8',STR0049   ,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| Space(12) })
TRCell():New(oSection5,'VldInici'  ,'SH8',STR0074,'@!', 10,/*lPixel*/,/*{|| code-block de impressao }*/) //"Validade inicial"
TRCell():New(oSection5,'VldFinal'  ,'SH8',STR0075,'@!', 10,/*lPixel*/,/*{|| code-block de impressao }*/) //"Validade Final"

oSection5:Cell('H8_HRFIM'):SetCellBreak()
oSection5:Cell('FimAloc' ):SetCellBreak()
oSection5:Cell('QtdPerda' ):SetCellBreak()

// Personaliza��o DAXIA
oSection5:Cell('H8_QUANT'):SetTitle("Qtd.")
oSection5:Cell('H8_QUANT'):SetSize(20)
oSection5:Cell('QtdeProd'):SetTitle("Qtd. Produzida")
oSection5:Cell('QtdeProd'):SetSize(20)
//oSection5:Cell('QtdPerda'):SetTitle("Perdas")
oSection5:Cell('QtdPerda'):SetSize(20)
oSection5:Cell('VldInici'):SetTitle("Val. Inicial")
oSection5:Cell('VldFinal'):SetTitle("Val. Final")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sessao 2 (oSection6)                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
oSection6 := TRSection():New(oSection1,STR0051,{"SD4","SB1","NNR"},/*Ordem*/) //"Empenhos"      
oSection6:SetHeaderBreak()   
oSection6:SetReadOnly()                          

TRCell():New(oSection6,'D4_COD'	 	 , 'SD4' , STR0058   , PesqPict('SD4','D4_COD')    ,TamSX3('D4_COD')[1]+3    ,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,.F./*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
TRCell():New(oSection6,'B1_DESC' 	 , 'SB1' , STR0059   , PesqPict('SB1','B1_DESC')   ,30 ,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,.T./*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
oSection6:Cell("B1_DESC"):SetLineBreak() 
// Consumo Unit�rio
TRCell():New(oSection6, 'ConsUnit' 	 , 'SD4' , "Consumo Unit�rio", PesqPict('SD4','D4_QUANT')  ,TamSX3('D4_QUANT')[1]  ,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
//TRCell():New(oSection6, 'ConsUnit' 	 , 'SD4' , "Consumo Unit�rio", "@E 999,999.9999"  ,TamSX3('D4_QUANT')[1]  ,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)

// Validade
TRCell():New(oSection6, 'D4_DTVALID' , 'SD4' , "Data Validade"  , /*Picture*/                 , /*Tamanho*/           , /*lPixel*/,                                /*{|| code-block de impressao }*/ , /*cAlign*/, /*lLineBreak*/, /*cHeaderAlign*/, /*lCellBreak*/, /*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
TRCell():New(oSection6, 'D4_QUANT' 	 , 'SD4' , STR0043    		, PesqPict('SD4','D4_QUANT')  ,TamSX3('D4_QUANT')[1]  , /*lPixel*/,                                /*{|| code-block de impressao }*/ , /*cAlign*/, /*lLineBreak*/, /*cHeaderAlign*/, /*lCellBreak*/, /*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
TRCell():New(oSection6, 'B1_UM'   	 , 'SB1' , STR0061    		, PesqPict('SB1','B1_UM')     ,TamSX3('B1_UM')[1]     , /*lPixel*/,                                /*{|| code-block de impressao }*/ , /*cAlign*/, /*lLineBreak*/, /*cHeaderAlign*/, /*lCellBreak*/, /*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
TRCell():New(oSection6, 'D4_LOTECTL' , 'SD4' , /*Titulo*/ 		, PesqPict('SD4','D4_LOTECTL'),7/*TamSX3('D4_LOTECTL')[1]*/, /*lPixel*/,                                /*{|| code-block de impressao }*/ , /*cAlign*/, /*lLineBreak*/, /*cHeaderAlign*/, /*lCellBreak*/, /*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
TRCell():New(oSection6, 'D4_NUMLOTE' , 'SD4' , /*Titulo*/ 		, PesqPict('SD4','D4_NUMLOTE'),TamSX3('D4_NUMLOTE')[1], /*lPixel*/,                                /*{|| code-block de impressao }*/ , /*cAlign*/, /*lLineBreak*/, /*cHeaderAlign*/, /*lCellBreak*/, /*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
TRCell():New(oSection6, 'B2_LOCALIZ' , 'SB2' , /*Titulo*/ 		, PesqPict('SB2','B2_LOCALIZ'),TamSX3('B2_LOCALIZ')[1], /*lPixel*/,                                /*{|| code-block de impressao }*/ , /*cAlign*/, /*lLineBreak*/, /*cHeaderAlign*/, /*lCellBreak*/, /*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
TRCell():New(oSection6, 'D4_OP'  	 , 'SD4' , /*Titulo*/ 		, PesqPict('SD4','D4_OP')     ,TamSX3('D4_OP')[1]     , /*lPixel*/,                                /*{|| code-block de impressao }*/ , /*cAlign*/, /*lLineBreak*/, /*cHeaderAlign*/, /*lCellBreak*/, /*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
TRCell():New(oSection6, 'D4_TRT'  	 , 'SD4' , STR0064    		, PesqPict('SD4','D4_TRT')    ,TamSX3('D4_TRT')[1]    , /*lPixel*/,                                /*{|| code-block de impressao }*/ , /*cAlign*/, /*lLineBreak*/, /*cHeaderAlign*/, /*lCellBreak*/, /*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
TRCell():New(oSection6, 'D4_LOCAL'	 , 'SD4' , STR0072    		, PesqPict('SD4','D4_LOCAL')  ,TamSX3('D4_LOCAL')[1]  , /*lPixel*/,                                /*{|| code-block de impressao }*/ , /*cAlign*/, /*lLineBreak*/, /*cHeaderAlign*/, /*lCellBreak*/, /*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
TRCell():New(oSection6, 'NNR_DESCRI' , 'NNR' , /*Titulo*/ 		, PesqPict('NNR','NNR_DESCRI'),TamSX3('NNR_DESCRI')[1], /*lPixel*/, {||Posicione("NNR",1,xFilial("NNR")+SD4->D4_LOCAL,"NNR_DESCRI")} , /*cAlign*/, /*lLineBreak*/, /*cHeaderAlign*/, /*lCellBreak*/, /*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)

// Personaliza��o DAXIA
oSection6:Cell("ConsUnit"):SetTitle("Cons. Unit.")
oSection6:Cell("ConsUnit"):SetSize(5)
oSection6:Cell("D4_DTVALID"):SetTitle("Dt.Val.")
oSection6:Cell("D4_DTVALID"):SetSize(15)
oSection6:Cell("B1_UM"):SetTitle("UN.")
oSection6:Cell("D4_QUANT"):SetTitle("Qtd.")
oSection6:Cell("D4_QUANT"):SetSize(10)
oSection6:Cell("D4_LOCAL"):SetSize(15)
oSection6:Cell("D4_LOTECTL"):SetSize(10)
//Fonte se��o Materiais
// RETIRADO PARA CORRIGIR O ENCAVALAMENTO
/*
oSection6:Cell("ConsUnit"):oFontBody   		:= oTFont1d //oTFont1c
oSection6:Cell("D4_DTVALID"):oFontBody  	:= oTFont1d //oTFont1c
oSection6:Cell("B1_UM"):oFontBody   		:= oTFont1d //oTFont1c
oSection6:Cell("D4_QUANT"):oFontBody   		:= oTFont1d //oTFont1c
oSection6:Cell("D4_LOTECTL"):oFontBody   	:= oTFont1d //oTFont1c
oSection6:Cell("D4_COD"):oFontBody 			:= oTFont1d //oTFont1c
oSection6:Cell("B1_DESC"):oFontBody 		:= oTFont1d //oTFont1c
oSection6:Cell("B2_LOCALIZ"):oFontBody	 	:= oTFont1d //oTFont1c
*/
// Espa�o entre as  colunas
// RETIRADO PARA CORRIGIR O ENCAVALAMENTO
//oSection6:SetColSpace(2) //Dobro o espa�amento entre as colunas



oSection1:SetNoFilter({"SA1","SC5"})
oSection6:SetNoFilter({"SD4","SB1","SB2","SC2"})
oSection4:SetNoFilter({"SG2","SH8","SH1","SH4"})
oSection5:SetNoFilter({"SG2","SH8","SH1","SH4"})

Return(oReport)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrint ³ Autor ³Felipe Nunes Toledo  ³ Data ³27/09/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportPrint devera ser criada para todos  ³±±
±±³          ³os relatorios que poderao ser agendados pelo usuario.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatorio                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³MATR820                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportPrint(oReport, cAliasTop)
Local oSection1	:= oReport:Section(1)
Local oSection2	:= oReport:Section(1):Section(1)
Local oSection4	:= oReport:Section(1):Section(2)
Local oSection5	:= oReport:Section(1):Section(2):Section(1)
Local oSection6	:= oReport:Section(1):Section(3)
Local oSection7
Local nOrdem    := oSection1:GetOrder()
Local oBreak
Local cIndex	:= ""
Local cCondicao	:= ""
Local cCode    	:= ""
Local nCntFor   := 0
Local nLinBar	:= 0
Local cWhere01, cWhere02, cWhere03
Local cOrderBy
Local nLoops 		:= 0
Local lPlanilha 	:= oReport:nDevice == 4
Local oTFont1a 		:= TFont():New('Verdana',,-15,.T.)
Local oTFont1b  	:= TFont():New('Verdana',,-11,.T.)
Local oTFont1c 		:= TFont():New('Verdana',,-13,.T.)
Local oTFont1d 		:= TFont():New('Courier New',,-13,.T.)

Private aArray	 	:= {}
Private lItemNeg 	:= GetMv("MV_NEGESTR") .And. mv_par11 == 1
Private lPcpator 	:= GetMv("MV_PCPATOR")

If !lPlanilha .Or. len(oReport:aXlsTable) == 0
	oSection1:Cell("C2_NUM"):Disable()
Endif	

// Definindo quebra para secao 2 e ocultando celula utilizada somente para quebra
oBreak := TRBreak():New(oSection6,oSection6:Cell("D4_OP"),Nil,.F.)
oSection6:Cell("D4_OP"):Disable()
oSection6:Cell("D4_TRT"):Disable()
oSection6:Cell("D4_LOCAL"):Disable()
oSection6:Cell("D4_NUMLOTE"):Disable()
oSection6:Cell("NNR_DESCRI"):Disable()

If lPlanilha
	oSection7 := TRSection():New(oReport,'',{"SC2"},/*Ordem*/)
	TRCell():New(oSection7,'C2_NUM'  	,'SC2',/*Titulo*/,PesqPict('SC2','C2_NUM')     ,TamSX3('C2_NUM')[1]     ,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
Endif


If mv_par12 == 2
	oSection6:Cell("D4_LOTECTL"):Disable()
	oSection6:Cell("D4_NUMLOTE"):Disable()
ElseIf !oReport:oPage:IsLandScape()
	//oSection6:Cell("B1_DESC"):SetSize(19)
	oSection6:Cell("NNR_DESCRI"):SetSize(10)
	oSection6:Cell("B2_LOCALIZ"):SetSize(10)	
	oSection6:Cell("D4_NUMLOTE"):SetTitle(STR0057)
EndIf

//Fonte se��o Materiais
/*
oSection6:Cell("ConsUnit"):oFontBody   		:= oTFont1d //oTFont1c
oSection6:Cell("D4_DTVALID"):oFontBody  	:= oTFont1d //oTFont1c
oSection6:Cell("B1_UM"):oFontBody   		:= oTFont1d //oTFont1c
oSection6:Cell("D4_QUANT"):oFontBody   		:= oTFont1d //oTFont1c
oSection6:Cell("D4_LOTECTL"):oFontBody   	:= oTFont1d //oTFont1c
oSection6:Cell("D4_COD"):oFontBody 			:= oTFont1d //oTFont1c
oSection6:Cell("B1_DESC"):oFontBody 		:= oTFont1d //oTFont1c
oSection6:Cell("B2_LOCALIZ"):oFontBody	 	:= oTFont1d //oTFont1c
*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtragem do relatorio                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Transforma parametros Range em expressao SQL                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MakeSqlExpr(oReport:GetParam())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Condicao Where para filtrar OP's                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cWhere01 := "%'"+AllTrim(mv_par01)+"'%"
cWhere02 := "%'"+AllTrim(mv_par02)+"'%"

cWhere03 := "%"
If mv_par08 == 2
	cWhere03 += "AND SC2.C2_DATRF = ' '"
Endif
cWhere03 += "%"

cOrderBy := "%"
If nOrdem == 4
	cOrderBy += "SC2.C2_FILIAL, SC2.C2_DATPRF"
Else                                  
	cOrderBy += SqlOrder(SC2->(IndexKey(nOrdem)))
EndIf
cOrderBy += "%"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Query do relatorio da secao 1                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1:BeginQuery()	
BeginSql Alias cAliasTop

SELECT SC2.C2_FILIAL, SC2.C2_NUM, SC2.C2_ITEM, SC2.C2_SEQUEN, SC2.C2_ITEMGRD, SC2.C2_DATPRF,
       SC2.C2_DATRF, SC2.C2_PRODUTO, SC2.C2_REVI, SC2.C2_DESTINA, SC2.C2_PEDIDO, SC2.C2_ROTEIRO, SC2.C2_QUJE,
       SC2.C2_PERDA, SC2.C2_QUANT, SC2.C2_DATPRI, SC2.C2_CC, SC2.C2_DATAJI, SC2.C2_DATAJF,
       SC2.C2_STATUS, SC2.C2_OBS, SC2.C2_TPOP, SC2.C2_EMISSAO, SC2.C2_XOBSOP, SC2.C2_XCAPMAX, SC2.C2_XUMCMAX,
       SC2.R_E_C_N_O_  SC2RECNO

FROM %table:SC2% SC2

WHERE SC2.C2_FILIAL = %xFilial:SC2% AND
	  SC2.C2_NUM || SC2.C2_ITEM || SC2.C2_SEQUEN || SC2.C2_ITEMGRD >= %Exp:cWhere01% AND
	  SC2.C2_NUM || SC2.C2_ITEM || SC2.C2_SEQUEN || SC2.C2_ITEMGRD <= %Exp:cWhere02% AND
      SC2.C2_DATPRF BETWEEN %Exp:mv_par03% AND %Exp:mv_par04% AND
	  SC2.%NotDel%
	  %Exp:cWhere03%

ORDER BY %Exp:cOrderby%

EndSql
oSection1:EndQuery()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posicionamento das tabelas³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TRPosition():New(oSection1,"SB1",1,{|| xFilial("SB1")+(cAliasTop)->C2_PRODUTO })
TRPosition():New(oSection1,"SC5",1,{|| xFilial("SC5")+(cAliasTop)->C2_PEDIDO })
TRPosition():New(oSection1,"SA1",1,{|| xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI })

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicio da impressao do fluxo do relatorio                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:SetMeter(SC2->(LastRec()))

oSection1:Init()
//oSection4:Init()
//oSection5:Init()
//oSection6:oReport:lBold     := .T.
//oSection6:oReport:oFontHeader := oTFont1a //TFont():New(oSection2:oReport:cFontBody,0,(oSection2:oReport:nFontBody+10)*(-1),,oSection2:oReport:lBold,,,,oSection2:oReport:lItalic,oSection2:oReport:lUnderline)
//oSection6:oReport:oFontBody   := oTFont1a

oSection6:Init()

//oFontBKP := oSection6:oReport:oFontBody
//oSection1:oReport:lBold       := .F.
//oSection1:oReport:oFontHeader := oFontBKP
//oSection1:oReport:oFontBody   := oFontBKP

//oSection6:oReport:lBold       := .T.
//oSection6:oReport:oFontHeader := oTFont1a //TFont():New(oSection2:oReport:cFontBody,0,(oSection2:oReport:nFontBody+10)*(-1),,oSection2:oReport:lBold,,,,oSection2:oReport:lItalic,oSection2:oReport:lUnderline)
//oSection6:oReport:oFontBody   := oTFont1a

If lPlanilha
	oSection7:Init()
Endif

dbSelectArea(cAliasTop)
While !oReport:Cancel() .And. !(cAliasTop)->(Eof())
	//-- Valida se a OP deve ser Impressa ou nao
	If !MtrAValOP(mv_par10,"SC2",cAliasTop)
		dbSkip()
		Loop
	EndIf    

	//Definindo a descricao do produto
	MR820Desc(oReport, cAliasTop)
	
	lSwHead := .T.
	oReport:ShowHeader()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Desabilitando celulas que nao deverao serem impressas   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (cAliasTop)->C2_DESTINA <> "P"
    	oSection1:Cell('C5_CLIENTE'):Disable()
    	oSection1:Cell('C5_LOJACLI'):Disable()
    	oSection1:Cell('A1_NOME'   ):Disable()
 	EndIf
	If Empty((cAliasTop)->C2_STATUS)
		oSection1:Cell("C2_STATUS"):SetValue("Normal")
	EndIf
	If (cAliasTop)->C2_QUJE + (cAliasTop)->C2_PERDA > 0
		oSection1:Cell('OpQuant'):Disable()
	Else
		oSection1:Cell('QtdeProd'):Disable()
		oSection1:Cell('C2_QUANT'):Disable()
	Endif
	If (Empty((cAliasTop)->C2_OBS))
		oSection1:Cell('C2_OBS'):Disable()	
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Definindo o titulo do Relatorio³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//oReport:SetTitle(STR0010+(cAliasTop)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)) //"        O R D E M   D E   P R O D U C A O       NRO :"
	oReport:SetTitle((cAliasTop)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)) //ALTERO O NUMERO DA OP 

/*	If mv_par06 == 1 
		cCode := (cAliasTop)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)
		nLBarra :=  1.0
		nCBarra :=  9.125
		MSBAR3("CODE128",nLBarra,nCBarra,Trim(cCode),@oReport:oPrint,Nil,Nil,Nil,Nil ,1.5 ,Nil,Nil,Nil,.F.)
	EndIf
*/	
	If lPlanilha
		oReport:SkipLine()
		oSection7:Cell("C2_NUM"):SetValue((cAliasTop)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD))
		oSection7:Cell('C2_NUM'):Enable()	
		If len(oReport:aXlsTable) > 0
			oSection1:Cell("C2_NUM"):SetValue((cAliasTop)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD))
			oSection1:Cell('C2_NUM'):Enable()
		Endif
		//Impressao da Section 5
		oSection7:PrintLine()
		oReport:IncMeter()
	Endif
	
	//Impressao da Section 1
	oSection1:PrintLine()
	oReport:IncMeter()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Habilitando celulas³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (cAliasTop)->C2_DESTINA <> "P"
    	oSection1:Cell('C5_CLIENTE'):Enable()
    	oSection1:Cell('C5_LOJACLI'):Enable()
    	oSection1:Cell('A1_NOME'   ):Enable()
 	EndIf
	If (cAliasTop)->C2_QUJE + (cAliasTop)->C2_PERDA > 0
		oSection1:Cell('OpQuant'):Enable()
	Else
		oSection1:Cell('QtdeProd'):Enable()
		oSection1:Cell('C2_QUANT'):Enable()
	Endif
	If (Empty((cAliasTop)->C2_OBS))
		oSection1:Cell('C2_OBS'):Enable()	
	EndIf

	Mr820Esp( oReport, (cAliasTop)->C2_PRODUTO, (cAliasTop)->C2_REVI, (cAliasTop)->C2_ROTEIRO ) 

	//--- Inicio fluxo impressao secao 5
	SB1->(dbSeek(xFilial("SB1")+(cAliasTop)->C2_PRODUTO))
	cCODPROC := SB1->B1_CODPROC
	
	aArrObs := {}
	aArray := {}
	MontStruc( (cAliasTop)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)  )
	
	aSort( aArray,1,, { |x, y| (x[1]+x[11]+x[8]) < (y[1]+y[11]+y[8]) } )

	aMater := {}
	cPrdAtu	:= ""
	cLote	:= ""
	cEnder	:= ""
	//MSGALERT( "N�mero de Itens .: " +  ALLTRIM( STR( Len(aArray) ) ) )
	For nCntFor := 1 TO Len(aArray)
		
		//MSGALERT(   "(" + cPrdAtu + ") <> (" + aArray[nCntFor][1] + ") .and. " +;
		//  		  "(" + cLote + ") <> (" + aArray[nCntFor][11] + ") .and. " +;
		//	    	  "(" + cEnder + ") <> (" + aArray[nCntFor][8] + ")  " ) 

		SB1->(dbSetOrder(1))
	    SB1->(MsSeek(xFilial("SB1")+aArray[nCntFor][1]))

	    SD4->(dbSetOrder(2))
	    SD4->(MsSeek(xFilial("SD4")+(cAliasTop)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)+aArray[nCntFor][1]+aArray[nCntFor][6]))

		
		IF cPrdAtu	<> aArray[nCntFor][1]  .AND. ;
			 cLote	<> aArray[nCntFor][11] 

			//MSGALERT( "Incu�do no aMater 1 .: ( Produto -> " + ALLTRIM(aArray[nCntFor][1])  + " / " + ;
			//							 "       Lote -> " + ALLTRIM(aArray[nCntFor][11]) + " / " + ;
			//							 "   Endere�o -> " + ALLTRIM(aArray[nCntFor][8])  + " ) " )

			cPrdAtu	:= aArray[nCntFor][1]
			cLote	:= aArray[nCntFor][11]
			cEnder	:= aArray[nCntFor][8]

			IF  nCntFor <> 1
				// Encerro o Lote Anterior
				aMater[Len(aMater)][14] := aMater[Len(aMater)][5] / aMater[Len(aMater)][13]

				// ATUALIZO O CONSUMO UNIT�RIO DOS OUTROS LOTES
				nForCnt := 0
				nTotLot := 0
				FOR nForCnt := 1 TO LEN(aMater)
					IF aMater[Len(aMater)][1] == aMater[nForCnt][1]
						nTotLot += aMater[nForCnt][5]
						//MSGALERT( "Total .:" + ALLTRIM( STR( nTotLot ) ) )
					ENDIF
				NEXT

				// ATUALIZO O CONSUMO UNIT�RIO DOS LOTES 
				nForCnt := 0
				FOR nForCnt := 1 TO LEN(aMater)
					IF aMater[Len(aMater)][1] == aMater[nForCnt][1]
						aMater[nForCnt][14] := nTotLot / aMater[Len(aMater)][13] 
						//MSGALERT(" Consumo Unit�rio .:" + ALLTRIM( STR(  aMater[nForCnt][14] ) ) )
					ENDIF
				NEXT

			ENDIF
		 
			aAdd(	aMater,	{	aArray[nCntFor][1]  	,;
								aArray[nCntFor][2]  	,;
								aArray[nCntFor][3]  	,;
								aArray[nCntFor][4]  	,;
								aArray[nCntFor][5]  	,;
								aArray[nCntFor][6]  	,;
								aArray[nCntFor][7]  	,;
								aArray[nCntFor][8]  	,;
								aArray[nCntFor][9]  	,;
								aArray[nCntFor][10] 	,;
								aArray[nCntFor][11] 	,;
								aArray[nCntFor][12] 	,;
								(cAliasTop)->C2_QUANT 	,;
								0						})  // Consumo Unitario
			
			aMater[Len(aMater)][14] := aMater[Len(aMater)][5] / aMater[Len(aMater)][13]

		ELSEIF cPrdAtu	== aArray[nCntFor][1]  .AND. ;
				 cLote	<> aArray[nCntFor][11] 

			cLote	:= aArray[nCntFor][11]
			cEnder	:= aArray[nCntFor][8]

			//MSGALERT( "Incu�do no aMater 2 .: ( Produto -> " + ALLTRIM(aArray[nCntFor][1])  + " / " + ;
			//							 "       Lote -> " + ALLTRIM(aArray[nCntFor][11]) + " / " + ;
			//							 "   Endere�o -> " + ALLTRIM(aArray[nCntFor][8])  + " ) " )

			// Encerro o Lote Anterior
			aMater[Len(aMater)][14] := aMater[Len(aMater)][5] / aMater[Len(aMater)][13]

			aAdd(	aMater,	{	aArray[nCntFor][1]  	,;
								aArray[nCntFor][2]  	,;
								aArray[nCntFor][3]  	,;
								aArray[nCntFor][4]  	,;
								aArray[nCntFor][5]  	,;
								aArray[nCntFor][6]  	,;
								aArray[nCntFor][7]  	,;
								aArray[nCntFor][8]  	,;
								aArray[nCntFor][9]  	,;
								aArray[nCntFor][10] 	,;
								aArray[nCntFor][11] 	,;
								aArray[nCntFor][12] 	,;
								(cAliasTop)->C2_QUANT 	,;
								0						})  // Consumo Unitario

			aMater[Len(aMater)][14] := aMater[Len(aMater)][5] / aMater[Len(aMater)][13]

		ELSEIF cPrdAtu	== aArray[nCntFor][1]  .AND. ; // SOMO O SALDO
				cLote	== aArray[nCntFor][11] .AND. ;
				cEnder	<> aArray[nCntFor][8]  

			cEnder	:= aArray[nCntFor][8]

			//MSGALERT( "Atualizando aMater 3 .: ( Produto -> " + ALLTRIM(aArray[nCntFor][1])  + " / " + ;
			//							  "       Lote -> " + ALLTRIM(aArray[nCntFor][11]) + " / " + ;
			//							  "   Endere�o -> " + ALLTRIM(aArray[nCntFor][8])  + " ) " )

			aMater[Len(aMater)][5] += aArray[nCntFor][5]

			aMater[Len(aMater)][14] := aMater[Len(aMater)][5] / aMater[Len(aMater)][13]

		ELSEIF cPrdAtu	== aArray[nCntFor][1]  .AND. ; //SOMO O SALDO
				cLote	== aArray[nCntFor][11] .AND. ;
				cEnder	== aArray[nCntFor][8]  

			//MSGALERT( "Atualizando aMater 4 .: ( Produto -> " + ALLTRIM(aArray[nCntFor][1])  + " / " + ;
			//							  "       Lote -> " + ALLTRIM(aArray[nCntFor][11]) + " / " + ;
			//							  "   Endere�o -> " + ALLTRIM(aArray[nCntFor][8])  + " ) " )

			aMater[Len(aMater)][5] += aArray[nCntFor][5]

			aMater[Len(aMater)][14] := aMater[Len(aMater)][5] / aMater[Len(aMater)][13]

		ENDIF
	Next

	// REFAZ O CALCULO DO ULTIMO ITEM
	// ATUALIZO O CONSUMO UNIT�RIO DOS OUTROS LOTES
	nTamArr := LEN(aMater)
	nForCnt := 0
	nTotLot := 0
	FOR nForCnt := 1 TO LEN(aMater)
		IF aMater[nTamArr][1] == aMater[nForCnt][1]
			nTotLot += aMater[nForCnt][5]
		ENDIF
	NEXT

	// ATUALIZO O CONSUMO UNIT�RIO DOS LOTES 
	nForCnt := 0
	FOR nForCnt := 1 TO LEN(aMater)
		IF aMater[nTamArr][1] == aMater[nForCnt][1]
			aMater[nForCnt][14] := nTotLot / aMater[nTamArr][13] 
		ENDIF
	NEXT

	aArray := {}
	aArray := aClone(aMater)

	If mv_par09 == 1
		aSort( aArray,1,, { |x, y| (x[1]+x[9]) < (y[1]+y[9]) } )
	Else
		aSort( aArray,1,, { |x, y| (x[9]+x[1]) < (y[9]+y[1]) } )
	ENDIF                     
		
	For nCntFor := 1 TO Len(aArray)

	    SB1->(dbSetOrder(1))
	    SB1->(MsSeek(xFilial("SB1")+aArray[nCntFor][1]))

	    SD4->(dbSetOrder(2))
	    SD4->(MsSeek(xFilial("SD4")+(cAliasTop)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)+aArray[nCntFor][1]+aArray[nCntFor][6]))

		IF !( UPPER(ALLTRIM(aArray[nCntFor][3])) $ "GG" )

			oSection6:Cell("D4_COD"    ):SetValue(aArray[nCntFor][1])
			oSection6:Cell("B1_DESC"   ):SetValue(aArray[nCntFor][2])
			oSection6:Cell("D4_QUANT"  ):SetValue(aArray[nCntFor][5])
			oSection6:Cell("B1_UM"     ):SetValue(aArray[nCntFor][4])
			oSection6:Cell("D4_LOCAL"  ):SetValue(aArray[nCntFor][6])
			oSection6:Cell("NNR_DESCRI"):SetValue(aArray[nCntFor][7])
			oSection6:Cell("B2_LOCALIZ"):SetValue(aArray[nCntFor][8])
			oSection6:Cell("D4_TRT"    ):SetValue(aArray[nCntFor][9])
			oSection6:Cell("D4_OP"     ):SetValue((cAliasTop)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD))
			oSection6:Cell("ConsUnit"  ):SetValue(aArray[nCntFor][14])

			//aAdd( aArray[nCntFor], SD4->D4_QTDEORI/(cAliasTop)->(C2_QUANT) )
			oSection6:Cell("D4_COD"    ):SetSize(15)
			oSection6:Cell("B1_DESC"    ):SetSize(20)

			If mv_par12 == 1
				oSection6:Cell("D4_LOTECTL"):SetValue(aArray[nCntFor][11])
				oSection6:Cell("D4_NUMLOTE"):SetValue(aArray[nCntFor][12])
			ELSE
				oSection6:Cell("D4_LOTECTL"):Disable()
				oSection6:Cell("D4_NUMLOTE"):Disable()
			EndIf
			
			//CONOUT("FOR ("+ALLTRIM(STR(nCntFor))+") - oReport:PageHeight() -> "+STR(oReport:PageHeight()))
			//CONOUT("FOR ("+ALLTRIM(STR(nCntFor))+") - oReport:Row() -> "+STR(oReport:Row()))

			IF nCntFor == 1
				//�����������������������������Ŀ
				//�Verifica se cabera na pagina �
				//�������������������������������
				nPosLin := oReport:Row() 
				IF oReport:Row() > 2500
					oReport:EndPage()
					nPosLin := 550
					oReport:Skipline(2)
				ELSE
					oReport:Skipline(2)
					nPosLin := oReport:Row() 
				ENDIF			
				oReport:Say( nPosLin, oReport:Col(), "MATERIAIS", oTFont1a )
				oReport:Skipline(2)
				oSection6:SetRow( oReport:Row()+250 )
				
				
			ENDIF

			//Impressao da Section 2
			oSection6:PrintLine()
		ENDIF
	Next
	
	oReport:Skipline(2)
	oReport:Say(      oReport:Row(), 160, "Peso Liq. TOTAL: ______________       Peso Bruto TOTAL: ______________       Nro. Volumes: ______________", oTFont1c )
	oReport:Say(  oReport:Row()+150, 450, "RESPONS�VEL/DATA   ____________________________________       _____ / _____ / __________", oTFont1c )
	oReport:Skipline(4)

	If mv_par05 == 1
		Mr820Ope(oReport, cAliasTop) //Impressao da Section 3 e Section 4
	EndIf

	aArrObs := aClone(aArray)
	Mr820Obs( oReport, cAliasTop, cCODPROC , aArrObs, oSection6)

	oReport:EndPage() //-- Salta Pagina
	
	dbSelectArea(cAliasTop)
	dbSkip()

	// Para impressoras com Frente e Verso
	IF  MOD( oReport:Page()+1, 2 ) == 1 // SE PR�XIMA PAGINA � PAR - IMPRIMO VERSO
		lSwHead := .F.
		oReport:HideHeader()
		oReport:StartPage() 
		oReport:EndPage() 
	ENDIF
EndDo

If lPlanilha
	oSection7:Finish()
Endif
oSection6:Finish()
//oSection5:Finish()
//oSection4:Finish()
oSection1:Finish()
(cAliasTop)->(DbCloseArea())
dbSelectArea("SH8")
dbClearFilter()
dbCloseArea()

Return Nil

STATIC FUNCTION Mr820Obs ( oReport, cAlias, cCodProc, aDados, oSectionX )

Local aArea 	:= GetArea()
Local cPicQTD	:= PesqPictQT("C2_QUANT")
Local cPicQtM 	:= PesqPictQT("C2_XCAPMAX")
Local oTFont1a  := TFont():New('Verdana',,-15,.T.)
Local oTFont1b  := TFont():New('Verdana',, -9,.T.)
Local cOp		:= (cAlias)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)

oReport:Say(  oReport:Row(), 160, "", oTFont1b )
oReport:Skipline(2)
oSectionX:SetRow( oReport:Row()+250 )
oReport:Say(  oReport:Row(), 160, "OBSERVA��ES E COMENT�RIOS", oTFont1a )
oReport:Skipline(2)

IF (cAlias)->C2_XCAPMAX > 0

	oReport:Say(  oReport:Row(), 160, ALLTRIM( (cAlias)->C2_XOBSOP )+" "+ ALLTRIM( TRANSFORM( (cAlias)->C2_XCAPMAX, cPicQtM ) ) /*ALLTRIM( STR( (cAlias)->C2_XCAPMAX*1000 ) )*/ +" "+(cAlias)->C2_XUMCMAX, oTFont1b )

	cJaImp := ""
	FOR nI := 1 TO LEN(aDados)
		nConUni := aDados[nI][14]
		//CONOUT( "CUSTO UNIT�RIO .: " + STR(nConUni) )
		//CONOUT( "CODIGO MP  .:" + aDados[nI][1] )
		//CONOUT( "DESCRI��O MP .: " + aDados[nI][2] )
		//CONOUT( "UM .: " + aDados[nI][4] )
		//CONOUT( "CALCULO A SER FEITO .: " + STR(nConUni) + " * ( " + STR( (cAlias)->C2_XCAPMAX ) + " * 1000 ) " )
		//CONOUT( "C2_XCAPMAX .: " + STR( (cAlias)->C2_XCAPMAX ) )
		//CONOUT( "CALCULO FINAL .: " + STR( nConUni*( (cAlias)->C2_XCAPMAX*1000 )  ) )
		//CONOUT("TIPO.:"+aDados[nI][3])
		
		IF UPPER(ALLTRIM(aDados[nI][3])) $ "MP|ME|PI|PA" .AND. !( ALLTRIM(aDados[nI][1]) $ cJaImp )
			nValFim := nConUni * ( (cAlias)->C2_XCAPMAX )
			oReport:Skipline()
			//oReport:Say(  oReport:Row(), 160, aDados[nI][1]+" - "+ALLTRIM(aDados[nI][2])+" = "+ ALLTRIM( STR( nValFim ) )  + " " + aDados[nI][4] , oTFont1b )
			oReport:Say(  oReport:Row(), 160, aDados[nI][1]+" - "+ALLTRIM(aDados[nI][2])+" = "+ ALLTRIM( TRANSFORM( nValFim, '@E 99,999,999.99' ) )  + " " + aDados[nI][4] , oTFont1b )
			cJaImp += "| " +  aDados[nI][1] + " |"
		ENDIF
	NEXT

ENDIF

/*
dbSelectArea("SD4")
dbSetOrder(2)
dbSeek(xFilial("SD4")+cOp)

While !Eof() .And. D4_FILIAL+D4_OP == xFilial()+cOp
	//CONOUT( "ENCONTREI ITENS DA OP: "+cOp )
	//���������������������������������������������������������Ŀ
	//� Posiciona no produto desejado                           �
	//�����������������������������������������������������������
	dbSelectArea("SB1")
	dbSetOrder(1)
	If dbSeek(xFilial()+SD4->D4_COD)
		//CONOUT( "ENCONTREI A DESCRI��O DOS ITENS DA OP: " + cOp + "NA SB1" )
		//CONOUT( "ITEM DA OP: " + cOp + " -> QUANTIDADE: " + STR(SD4->D4_QUANT) )
		If SD4->D4_QTDEORI > 0 
			//AddAr820(SD4->D4_QTDEORI)
			oReport:Skipline()
			oReport:Say(  oReport:Row(), 30, SD4->D4_COD+" - "+ALLTRIM(SB1->B1_DESC)+" = "+ ALLTRIM( STR( ( SD4->D4_QTDEORI/(cAlias)->C2_QUANT ) * ( (cAlias)->C2_XCAPMAX*1000 ) ) ) + SB1->B1_UM , oTFont1b )
		EndIf
	Endif
	dbSelectArea("SD4")
	dbSkip()
Enddo */

aTxtDesc  := {}
xQuebra   := CHR(13)+CHR(10)
_cDescPrd := MSMM( cCodProc, TamSx3("B1_VM_PROC")[1] ) + CHR(13) + CHR(10)
cTexto    := _cDescPrd
nQuebra   := At(xQuebra,cTexto)
// Analiso as quebras e caso necessario as retiro
While nQuebra > 0
	cLinha := SubStr(cTexto,1,nQuebra-1)
	Aadd(aTxtDesc,cLinha)
	cTexto := Stuff(cTexto,1,nQuebra+1,"")
	nQuebra := At(xQuebra,cTexto)
EndDo
IF LEN(cTexto) > 0
	Aadd(aTxtDesc,cTexto)
ENDIF
//aTxtDesc  := JustificaTXT( _cDescPrd, 100, .T. )

IF !EMPTY(ALLTRIM(_cDescPrd)) .AND. LEN(aTxtDesc) > 0
	nI := 1
	FOR nI := 1 TO LEN(aTxtDesc)
		oReport:Skipline()
		oReport:Say(  oReport:Row(), 160, aTxtDesc[nI] , oTFont1b )
	NEXT
ENDIF

oReport:Skipline()
oReport:Skipline()

RestArea(aArea)

RETURN NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MR820Desc   ³ Autor ³Felipe Nunes Toledo  ³ Data ³28/09/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Atribui a descricao do produto conforme opcao selecionada   ³±±
±±³          ³no parametro mv_par07 (Descricao do Produto ?).             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatorio                           ³±±
±±³          ³ExpC1: Alias do arquivo Ordem de Producao                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³MATR820                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MR820Desc(oReport, cAliasTop)
Local oSection1 := oReport:Section(1)
Local lSB1Desc 	:= .T.
local cDescCampo	:= ''

If mv_par07 == 1
	SB5->(dbSetOrder(1))
	If SB5->(dbSeek(xFilial("SB5")+(cAliasTop)->C2_PRODUTO) .And. !Empty(B5_CEME))
		
		dbSelectArea("SX3")
		SX3->(dbSetOrder(2))
		SX3->(DbSeek("B5_CEME") )
		cDescCampo := Alltrim(X3Titulo()) 
		oSection1:Cell("B1_DESC"):SetTitle(cDescCampo)
		oSection1:Cell("B1_DESC"):SetLineBreak(.T.)
		oSection1:Cell("B1_DESC"):SetSize(150)
		oSection1:Cell("B1_DESC"):SetValue(SB5->B5_CEME)
		lSB1Desc := .F.		
	EndIf
ElseIf mv_par07 == 3
	If (cAliasTop)->C2_DESTINA == "P"
		SC6->(dbSetOrder(1))
		If SC6->(dbSeek(xFilial("SC6")+(cAliasTop)->C2_PEDIDO+(cAliasTop)->C2_ITEM))
			If !Empty(SC6->C6_DESCRI) .and. SC6->C6_PRODUTO == (cAliasTop)->C2_PRODUTO
				//oSection1:Cell("B1_DESC"):GetFieldInfo("C6_DESCRI")
				dbSelectArea("SX3")
				SX3->(dbSetOrder(2))
				SX3->(DbSeek("B1_DESC") )
				cDescCampo := Alltrim(X3Titulo()) 
				oSection1:Cell("B1_DESC"):SetTitle(cDescCampo)
				oSection1:Cell("B1_DESC"):SetLineBreak(.T.)
				oSection1:Cell("B1_DESC"):SetSize(80)
				oSection1:Cell("B1_DESC"):SetValue(SC6->C6_DESCRI)
				lSB1Desc := .F.
			EndIf
		EndIf
	EndIf
EndIf

If (mv_par07 <> 2) .And. lSB1Desc
	SB1->(dbSetOrder(1))
	If SB1->( dbSeek(xFilial("SB1")+(cAliasTop)->C2_PRODUTO) )
		//oSection1:Cell("B1_DESC"):GetFieldInfo("B1_DESC")
		dbSelectArea("SX3")
		SX3->(dbSetOrder(2))
		SX3->(DbSeek("B1_DESC") )
		cDescCampo := Alltrim(X3Titulo()) 
		oSection1:Cell("B1_DESC"):SetTitle(cDescCampo)
		oSection1:Cell("B1_DESC"):SetLineBreak(.T.)
		oSection1:Cell("B1_DESC"):SetSize(80)
		oSection1:Cell("B1_DESC"):SetValue(SB1->B1_DESC)
	EndIf
EndIf

Return Nil

Static Function Mr820Esp(oReport, cProduto, cRevisao, cRoteiro )
Local oSection2 := oReport:Section(1):Section(1)
Local cAlias2   := GETNEXTALIAS()
Local oTFont1a  := TFont():New('Verdana',,-15,.T.)
Local oTFont1b  := TFont():New('Verdana',,-11,.T.)

//CONOUT("ENTREI NA ESPECIFICA��O")
oSection2:BeginQuery()	
BEGINSQL ALIAS cAlias2
	SELECT    QP7.QP7_PRODUT AS PRODUTO,   QP7.QP7_REVI AS   REVISAO,  QP7.QP7_CODREC AS ROTEIRO, QP7.QP7_OPERAC AS OPERACAO, QP7.QP7_LABOR  AS LABORATORIO,
			  QP7.QP7_ENSAIO AS  ENSAIO, QP7.QP7_SEQLAB AS SEQUENCIA,  QP7.QP7_ENSAIO AS  ENSAIO,          'DIM' AS     TIPO, QP7.QP7_MINMAX AS      MINMAX,
			  QP7.QP7_LIE    AS     LIE, QP7.QP7_NOMINA AS   NOMINAL,     QP7.QP7_LSE AS     LSE, QP1.QP1_METODO AS   METODO, ''             AS       TEXTO,
			  QP7.QP7_PLAMO  AS   PLAMO, QP7.QP7_FORMUL AS   FORMULA,  QP1.QP1_TPCART AS  TPCART, QP1.QP1_CARTA  AS    CARTA, QP1.QP1_DESCPO AS      DESCPO,
			  QP1.QP1_DESCIN AS  DESCIN, QP1.QP1_DESCES AS    DESCES,  QP7.QP7_ENSOBR AS  ENSOBR, QP1.QP1_TIPO   AS       TP,   QP1.QP1_QTDE AS  QUANTIDADE
	FROM	  %table:QP1% QP1 (NOLOCK),
			  %table:QP7% QP7 (NOLOCK)
	WHERE	  QP7.QP7_FILIAL = %xFilial:QP7% 
		  AND QP1.QP1_FILIAL = %xFilial:QP1% 
	      AND QP7.QP7_PRODUT = %exp:cProduto% 
	      AND QP7.QP7_REVI   = %exp:cRevisao%
		  AND QP7.QP7_CODREC = %exp:cRoteiro%					
	      AND QP1.QP1_ENSAIO = QP7.QP7_ENSAIO		
	      AND QP7.%NotDel%
	      AND QP1.%NotDel%
    UNION
	SELECT    QP8.QP8_PRODUT AS PRODUTO,   QP8.QP8_REVI AS   REVISAO,  QP8.QP8_CODREC AS ROTEIRO, QP8.QP8_OPERAC AS OPERACAO, QP8.QP8_LABOR  AS LABORATORIO,
			  QP8.QP8_ENSAIO AS  ENSAIO, QP8.QP8_SEQLAB AS SEQUENCIA,  QP8.QP8_ENSAIO AS  ENSAIO,          'TXT' AS     TIPO, ''             AS      MINMAX,
			  ''             AS     LIE, ''             AS   NOMINAL,     ''          AS     LSE, QP1.QP1_METODO AS   METODO, QP8.QP8_TEXTO  AS       TEXTO,
			  QP8.QP8_PLAMO  AS   PLAMO, ''             AS   FORMULA,  QP1.QP1_TPCART AS  TPCARY, QP1.QP1_CARTA  AS    CARTA, QP1.QP1_DESCPO AS      DESCPO,
			  QP1.QP1_DESCIN AS  DESCIN, QP1.QP1_DESCES AS    DESCES,  QP8.QP8_ENSOBR AS  ENSOBR, QP1.QP1_TIPO   AS       TP,   QP1.QP1_QTDE AS  QUANTIDADE
	FROM	  %table:QP1% QP1 (NOLOCK),
			  %table:QP8% QP8 (NOLOCK)
	WHERE	  QP8.QP8_FILIAL = %xFilial:QP8%					
	      AND QP1.QP1_FILIAL = %xFilial:QP1% 
	      AND QP8.QP8_PRODUT = %exp:cProduto%
	      AND QP8.QP8_REVI   = %exp:cRevisao%
		  AND QP8.QP8_CODREC = %exp:cRoteiro%					
	      AND QP1.QP1_ENSAIO = QP8.QP8_ENSAIO		
	      AND QP1.%NotDel%
	      AND QP8.%NotDel%
	ORDER BY LABORATORIO, SEQUENCIA
ENDSQL
oSection2:EndQuery()
aLastQuery    := GetLastQuery()
cLastQuery    := aLastQuery[2]
MemoWrite( "C:\TEMP\QRY-ESP.TXT", cLastQuery )

IF !(cAlias2)->(EOF())
	//CONOUT("ENCONTREI DADOS NA ESPECIFICA��O")
ENDIF


IF oReport:Row() <= 550
	oReport:Skipline()
	oReport:Skipline()
	oReport:Say( 550, 160, "ESPECIFICA��O", oTFont1a )
	oReport:Skipline()
	oReport:Skipline()
	oSection2:SetRow( 700 )
ELSE
	oReport:Skipline()
	oReport:Skipline()
	oReport:Say( oReport:Row(), 160, "ESPECIFICA��O", oTFont1a )
	oReport:Skipline()
	oReport:Skipline()
ENDIF

oSection2:SetCellBorder( "ALL", NIL, NIL, .T. )
oSection2:SetCellBorder( "ALL" )
WHILE !(cAlias2)->(EOF())
	
	oSection2:Init()
	//CONOUT("DADOS DO ENSAIO "+(cAlias2)->DESCPO)
	oSection2:Cell('QP1_DESCPO'):SetValue((cAlias2)->DESCPO)

	IF EMPTY(ALLTRIM((cAlias2)->MINMAX))
		oSection2:Cell('VlrPadrao'):SetValue( "N/A" )
		oSection2:Cell('VlrMinimo'):SetValue( (cAlias2)->TEXTO )
		oSection2:Cell('VlrMaximo'):SetValue( (cAlias2)->TEXTO )
	ELSE
		IF ALLTRIM((cAlias2)->MINMAX) == "1"
			oSection2:Cell('VlrPadrao'):SetValue( (cAlias2)->NOMINAL )
			oSection2:Cell('VlrMinimo'):SetValue( (cAlias2)->LIE )
			oSection2:Cell('VlrMaximo'):SetValue( (cAlias2)->LSE )
		ELSEIF  ALLTRIM((cAlias2)->MINMAX) ==  "2"
			oSection2:Cell('VlrPadrao'):SetValue( (cAlias2)->NOMINAL )
			oSection2:Cell('VlrMinimo'):SetValue( (cAlias2)->LIE )
			oSection2:Cell('VlrMaximo'):SetValue( " >>> " )
		ELSEIF  ALLTRIM((cAlias2)->MINMAX) ==  "3" 
			oSection2:Cell('VlrPadrao'):SetValue( (cAlias2)->NOMINAL )
			oSection2:Cell('VlrMinimo'):SetValue( " <<< ")
			oSection2:Cell('VlrMaximo'):SetValue( (cAlias2)->LSE )
		ENDIF		  
	ENDIF

	oSection2:Cell('PRE'):SetValue("     ")
	oSection2:Cell('APRV'):SetValue("     ")
	oSection2:Cell('REPR'):SetValue("     ")
	oSection2:PrintLine()
	(cAlias2)->(DBSKIP())
ENDDO     

oSection2:Finish()

oReport:Skipline()
oReport:Skipline()
oReport:Say(     oReport:Row(), 1250, "_____ / _____ / __________    _________________________________", oTFont1b )
oReport:Say(  oReport:Row()+50, 1300, "         DATA                                       RESPONS�VEL", oTFont1b )
oReport:Skipline()
oReport:Skipline()

Return NIL

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ Mr820Ope ³ Autor ³ Felipe Nunes Toledo   ³ Data ³ 18/07/92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Imprime Roteiro de Operacoes                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ Mr820Ope()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR820                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function Mr820Ope(oReport, cAliasTop)
Local oSection4 := oReport:Section(1):Section(2)
Local oSection5	:= oReport:Section(1):Section(2):Section(1)
Local oBreak
Local cRoteiro	:= ""                 
Local cSeekWhile:= ""
Local lSH8 		:= .F.
local lSG2		:= .T. 
Local aArea   	:= GetArea()
Local oTFont1a := TFont():New('Verdana',,-15,.T.)
Local oTFont2    := TFont():New('Verdana',,-19,.T.)

oBreak:= TRBreak():New(oSection4,oSection4:Cell("G2_RECURSO"),Nil,.F.)  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se imprime ROTEIRO da OP ou PADRAO do produto    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty((cAliasTop)->C2_ROTEIRO)
	cRoteiro:=(cAliasTop)->C2_ROTEIRO
Else
	If !Empty(SB1->B1_OPERPAD)
		cRoteiro:=SB1->B1_OPERPAD
	Else
		If a630SeekSG2(1,(cAliasTop)->C2_PRODUTO,xFilial("SG2")+(cAliasTop)->C2_PRODUTO+"01")
			cRoteiro:="01"
		EndIf
	EndIf
EndIf
	
//Valida se as operações serão geradas individualmente na Ordem Produção.(.T. Sim(SHY), .F. Considera SG2.)
If lPcpator
	dbselectarea("SHY")
	dbSetOrder(1)
	IF dbSeek(xFilial("SHY")+(cAliasTop)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD+C2_ROTEIRO))
		lSG2 := .F.
	EndIF
EndIF

IF lSG2

	cSeekWhile := "SG2->(G2_FILIAL+G2_PRODUTO+G2_CODIGO)"
	If a630SeekSG2(1,(cAliasTop)->C2_PRODUTO,xFilial("SG2")+(cAliasTop)->C2_PRODUTO+cRoteiro,@cSeekWhile) 

		oSection4:Init()
		oSection5:Init()

		oReport:Skipline()
		IF oReport:Row() <= 550
			oReport:Say( 550, oReport:Col(), "OPERA��ES", oTFont1a )
		ELSE
			oReport:Say( oReport:Row(), oReport:Col(), "OPERA��ES", oTFont1a )
		ENDIF
		oReport:Skipline()

		While SG2->(!Eof()) .And. Eval(&cSeekWhile)
			SH8->(dbSetOrder(1))
			If SH8->(dbSeek(xFilial("SH8")+(cAliasTop)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)+SG2->G2_OPERAC))
				lSH8 := .T.
			EndIf
			
			If lSH8
				While SH8->(!Eof()) .And. SH8->(H8_FILIAL+H8_OP+H8_OPER) == xFilial("SH8")+(cAliasTop)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)+SG2->G2_OPERAC
					SH1->(dbSeek(xFilial("SH1")+SH8->H8_RECURSO))
					SH4->(dbSeek(xFilial("SH4")+SG2->G2_FERRAM))
					
					If mv_par13 == 2
						If !Empty(SG2->G2_DTINI)
							If SG2->G2_DTINI > (cAliasTop)->C2_DATPRI
								SH8->(dbSkip())
								Loop
							EndIf
						EndIf
						If !Empty(SG2->G2_DTFIM)
							If SG2->G2_DTFIM < (cAliasTop)->C2_DATPRI
								SH8->(dbSkip())
								Loop
							EndIf
						EndIf
					EndIf
					
					oSection4:Cell('G2_RECURSO'):SetValue(SH8->H8_RECURSO)
					oSection4:Cell('H1_DESCRI' ):SetValue(SH1->H1_DESCRI)
					oSection4:Cell('G2_FERRAM' ):SetValue(SG2->G2_FERRAM)
					oSection4:Cell('H4_DESCRI' ):SetValue(SH4->H4_DESCRI)
					oSection4:Cell('G2_OPERAC' ):SetValue(SG2->G2_OPERAC)
					oSection4:Cell('G2_DESCRI' ):SetValue(SG2->G2_DESCRI)
					oSection5:Cell('VldInici'):SetValue(DTOC(SG2->G2_DTINI))
					oSection5:Cell('VldFinal'):SetValue(DTOC(SG2->G2_DTFIM))

					oSection4:PrintLine()
					oSection5:PrintLine()
					
					oReport:ThinLine()
										
					SH8->(dbSkip())
				EndDo
			Else
				If mv_par13 == 2
					If !Empty(SG2->G2_DTINI)
						If SG2->G2_DTINI > (cAliasTop)->C2_DATPRI
							SG2->(dbSkip())
							Loop
						EndIf
					EndIf
					If !Empty(SG2->G2_DTFIM)
						If SG2->G2_DTFIM < (cAliasTop)->C2_DATPRI
							SG2->(dbSkip())
							Loop
						EndIf
					EndIf
				EndIf
				
				SH1->(dbSeek(xFilial("SH1")+SG2->G2_RECURSO))
				SH4->(dbSeek(xFilial("SH4")+SG2->G2_FERRAM))
			
				oSection4:Cell('G2_RECURSO'):SetValue(SG2->G2_RECURSO)
				oSection4:Cell('H1_DESCRI' ):SetValue(SH1->H1_DESCRI)
				oSection4:Cell('G2_FERRAM' ):SetValue(SG2->G2_FERRAM)
				oSection4:Cell('H4_DESCRI' ):SetValue(SH4->H4_DESCRI)
				oSection4:Cell('G2_OPERAC' ):SetValue(SG2->G2_OPERAC)
				oSection4:Cell('G2_DESCRI' ):SetValue(SG2->G2_DESCRI)
				oSection4:PrintLine()
				
				oSection5:Cell('H8_DTINI'):Disable()
				oSection5:Cell('H8_HRINI'):Disable()
				oSection5:Cell('H8_DTFIM'):Disable()
				oSection5:Cell('H8_HRFIM'):Disable()
				oSection5:Cell('H8_QUANT'):SetValue(aSC2Sld(cAliasTop))
				oSection5:Cell('VldInici'):SetValue(DTOC(SG2->G2_DTINI))
				oSection5:Cell('VldFinal'):SetValue(DTOC(SG2->G2_DTFIM))
				
				oSection5:PrintLine()
				oReport:ThinLine()

				oSection5:Cell('H8_DTINI'):Enable()
				oSection5:Cell('H8_HRINI'):Enable()
				oSection5:Cell('H8_DTFIM'):Enable()
				oSection5:Cell('H8_HRFIM'):Enable()
			Endif
			
			// CODIGO DE BARRAS DA OPERA��O - 01
			//nLBarra :=  ( oReport:Row()-50 ) / 175
			//nCBarra :=  16.00

			//MSBAR3("CODE128",nLBarra,nCBarra,"1234567890",@oReport:oPrint,Nil,Nil,Nil,Nil ,1.5 ,Nil,Nil,Nil,.F.)
	
			SG2->(dbSkip())
		EndDo

		oSection4:Finish()
		oSection5:Finish()

	Endif

Else // Considera tabela SHY 
	dbselectarea("SHY")
	dbSetOrder(1)
	IF dbSeek(xFilial("SHY")+(cAliasTop)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD+C2_ROTEIRO))

		oSection4:Init()
		oSection5:Init()

		oReport:Skipline()
		IF oReport:Row() <= 550
			oReport:Say( 550, oReport:Col(), "OPERA��ES", oTFont1a )
		ELSE
			oReport:Say( oReport:Row(), oReport:Col(), "OPERA��ES", oTFont1a )
		ENDIF
		oReport:Skipline()

		While SHY->(!Eof()) .And. SHY->(HY_FILIAL+HY_OP+HY_ROTEIRO) = xFilial("SHY")+(cAliasTop)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD+C2_ROTEIRO)
			SH8->(dbSetOrder(1))
			If SH8->(dbSeek(xFilial("SH8")+(cAliasTop)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)+SHY->HY_OPERAC))
				lSH8 := .T.
			EndIf
			
			If lSH8
				While SH8->(!Eof()) .And. SH8->(H8_FILIAL+H8_OP+H8_OPER) == xFilial("SH8")+(cAliasTop)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)+SHY->HY_OPERAC
					SH1->(dbSeek(xFilial("SH1")+SH8->H8_RECURSO))
					SH4->(dbSeek(xFilial("SH4")+SHY->HY_FERRAM))
					
					If mv_par13 == 2
						If !Empty(SHY->HY_DATAINI)
							If SHY->HY_DATAINI > (cAliasTop)->C2_DATPRI
								SH8->(dbSkip())
								Loop
							EndIf
						EndIf
						If !Empty(SHY->HY_DATAFIM)
							If SHY->HY_DATAFIM < (cAliasTop)->C2_DATPRI
								SH8->(dbSkip())
								Loop
							EndIf
						EndIf
					EndIf
					
					oSection4:Cell('G2_RECURSO'):SetValue(SH8->H8_RECURSO)
					oSection4:Cell('H1_DESCRI' ):SetValue(SH1->H1_DESCRI)
					oSection4:Cell('G2_FERRAM' ):SetValue(SHY->HY_FERRAM)
					oSection4:Cell('H4_DESCRI' ):SetValue(SH4->H4_DESCRI)
					oSection4:Cell('G2_OPERAC' ):SetValue(SHY->HY_OPERAC)
					oSection4:Cell('G2_DESCRI' ):SetValue(SHY->HY_DESCRI)
					oSection5:Cell('VldInici'):SetValue(DTOC(STOD(REPLACE(SHY->HY_DATAINI,'-',''))))
					oSection5:Cell('VldFinal'):SetValue(DTOC(STOD(REPLACE(SHY->HY_DATAFIM,'-',''))))
					

					oSection4:PrintLine()
					oSection5:PrintLine()
					oReport:ThinLine()
					SH8->(dbSkip())
				EndDo
			Else
				If mv_par13 == 2
					If !Empty(SHY->HY_DATAINI)
						If SHY->HY_DATAINI > (cAliasTop)->C2_DATPRI
							SHY->(dbSkip())
							Loop
						EndIf
					EndIf
					If !Empty(SHY->HY_DATAFIM)
						If SHY->HY_DATAFIM < (cAliasTop)->C2_DATPRI
							SHY->(dbSkip())
							Loop
						EndIf
					EndIf
				EndIf
				
				SH1->(dbSeek(xFilial("SH1")+SHY->HY_RECURSO))
				SH4->(dbSeek(xFilial("SH4")+SHY->HY_FERRAM))
				
				oSection4:Cell('G2_RECURSO'):SetValue(SHY->HY_RECURSO)
				oSection4:Cell('H1_DESCRI' ):SetValue(SH1->H1_DESCRI)
				oSection4:Cell('G2_FERRAM' ):SetValue(SHY->HY_FERRAM)
				oSection4:Cell('H4_DESCRI' ):SetValue(SH4->H4_DESCRI)
				oSection4:Cell('G2_OPERAC' ):SetValue(SHY->HY_OPERAC)
				oSection4:Cell('G2_DESCRI' ):SetValue(SHY->HY_DESCRI)
				oSection4:PrintLine()
				
				oSection5:Cell('H8_DTINI'):Disable()
				oSection5:Cell('H8_HRINI'):Disable()
				oSection5:Cell('H8_DTFIM'):Disable()
				oSection5:Cell('H8_HRFIM'):Disable()
				oSection5:Cell('H8_QUANT'):SetValue(aSC2Sld(cAliasTop))
				oSection5:Cell('VldInici'):SetValue(DTOC(STOD(REPLACE(SHY->HY_DATAINI,'-',''))))
				oSection5:Cell('VldFinal'):SetValue(DTOC(STOD(REPLACE(SHY->HY_DATAFIM,'-',''))))
				
				oSection5:PrintLine()
				oReport:ThinLine()
				

				oSection5:Cell('H8_DTINI'):Enable()
				oSection5:Cell('H8_HRINI'):Enable()
				oSection5:Cell('H8_DTFIM'):Enable()
				oSection5:Cell('H8_HRFIM'):Enable()
			Endif
			
			// CODIGO DE BARRAS DA OPERA��O - 02
			//nFator := 130
			//nLBarra :=  ( oReport:Row() ) / nFator			
			//nCBarra :=  16.00

			//MSBAR3("CODE128",nLBarra,nCBarra,"1234567890",@oReport:oPrint,Nil,Nil,Nil,Nil ,1.5 ,Nil,Nil,Nil,.F.)
			//oReport:Say(nLBarra*nFator, 2020, "LINHA .: " + ALLTRIM( STR( nLBarra*nFator ) ) 	, oTFont2 )
			SHY->(dbSkip())
		EndDo


		oSection4:Finish()
		oSection5:Finish()
	Endif	
EndIf
RestArea(aArea)
Return Nil

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��� Fun��o   � MontStruc� Autor � Ary Medeiros          � Data � 19/10/93 ���
�������������������������������������������������������������������������Ĵ��
��� Descri��o� Monta um array com a estrutura do produto                  ���
�������������������������������������������������������������������������Ĵ��
��� Sintaxe  � MontStruc(ExpC1,ExpN1,ExpN2)                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Codigo do produto a ser explodido                  ���
���          � ExpN1 = Quantidade base a ser explodida                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR820                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
/*/
Static Function MontStruc( cOp, nQuant )

dbSelectArea("SD4")
dbSetOrder(2)
dbSeek(xFilial("SD4")+ALLTRIM(cOp))

While !Eof() .And. D4_FILIAL+D4_OP == xFilial()+cOp
	//CONOUT( "ENCONTREI ITENS DA OP: "+cOp )
	//���������������������������������������������������������Ŀ
	//� Posiciona no produto desejado                           �
	//�����������������������������������������������������������
	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	If dbSeek(xFilial("SB1")+SD4->D4_COD)
		//CONOUT( "ENCONTREI A DESCRI��O DOS ITENS DA OP: " + cOp + "NA SB1" )
		//CONOUT( "ITEM DA OP: " + cOp + " -> QUANTIDADE: " + STR(SD4->D4_QUANT) )
		//If SD4->D4_QTDEORI > 0 //.Or. (lItemNeg .And. SD4->D4_QUANT < 0)
		//	AddAr820(SD4->D4_QTDEORI)
		//EndIf

		IF Localiza(SB1->B1_COD,.T.)
			_cLocal := "PRODU��O"
		ELSE
			_cLocal := ""
		ENDIF

		dbSelectArea("NNR")
		dbSeek(xFilial("NNR")+SD4->D4_LOCAL)
		// CONFORME ORIENTA��ES DO JOS� N�O POSSO ME  BASEAR NA  SDC LOGO N�O POSSO VER O ENDERE�O
		AADD(aArray, {SB1->B1_COD,SB1->B1_DESC,SB1->B1_TIPO,SB1->B1_UM,SD4->D4_QTDEORI,SD4->D4_LOCAL,NNR->NNR_DESCRI,_cLocal,SD4->D4_TRT,(cAliasTop)->C2_ROTEIRO,If(mv_par12 == 1,SD4->D4_LOTECTL,""),If(mv_par12 == 1,SD4->D4_NUMLOTE,"") } )
	Endif
	dbSelectArea("SD4")
	dbSkip()
Enddo

dbSetOrder(1)

Return

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��� Fun��o   � AddAr820 � Autor � Paulo Boschetti       � Data � 07/07/92 ���
�������������������������������������������������������������������������Ĵ��
��� Descri��o� Adiciona um elemento ao Array                              ���
�������������������������������������������������������������������������Ĵ��
��� Sintaxe  � AddAr820(ExpN1)                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 = Quantidade da estrutura                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR820                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
//Static Function AddAr820(nQuantItem)
//Local cDesc   := SB1->B1_DESC
//Local cLocal  := ""
//Local cKey    := ""
//Local cRoteiro:= ""   
// Local lExiste   
// Local nQtdDc  := 0

//�����������������������������������������������������������Ŀ
//� Verifica se imprime nome cientifico do produto. Se Sim    �
//� verifica se existe registro no SB5 e se nao esta vazio    �
//�������������������������������������������������������������
// If mv_par07 == 1
// 	dbSelectArea("SB5")
// 	dbSeek(xFilial()+SB1->B1_COD)
// 	If Found() .and. !Empty(B5_CEME)
// 		cDesc := B5_CEME
// 	EndIf
// ElseIf mv_par07 == 2
// 	cDesc := SB1->B1_DESC
// Else
	//�����������������������������������������������������������Ŀ
	//� Verifica se imprime descricao digitada ped.venda, se sim  �
	//� verifica se existe registro no SC6 e se nao esta vazio    �
 	//�������������������������������������������������������������
// 	If (cAliasTop)->C2_DESTINA == "P"
// 		dbSelectArea("SC6")
// 		dbSetOrder(1)
// 		dbSeek(xFilial()+(cAliasTop)->C2_PEDIDO+(cAliasTop)->C2_ITEM)
// 		If Found() .and. !Empty(C6_DESCRI) .and. C6_PRODUTO==SB1->B1_COD
// 			cDesc := C6_DESCRI
// 		ElseIf C6_PRODUTO # SB1->B1_COD
// 			dbSelectArea("SB5")
// 			dbSeek(xFilial()+SB1->B1_COD)
// 			If Found() .and. !Empty(B5_CEME)
// 				cDesc := B5_CEME
// 			EndIf
// 		EndIf
// 	EndIf
// EndIf

//�����������������������������������������������������������Ŀ
//� Verifica se imprime ROTEIRO da OP ou PADRAO do produto    �
//�������������������������������������������������������������
// If !Empty((cAliasTop)->C2_ROTEIRO)
// 	cRoteiro:=(cAliasTop)->C2_ROTEIRO
// Else
// 	If !Empty(SB1->B1_OPERPAD)
// 		cRoteiro:=SB1->B1_OPERPAD
// 	Else
// 		dbSelectArea("SG2")
// 		If dbSeek(xFilial()+(cAliasTop)->C2_PRODUTO+"01")
// 			cRoteiro:="01"
// 		EndIf
// 	EndIf
// EndIf
 
//dbSelectArea("NNR")
//dbSeek(xFilial()+SD4->D4_LOCAL)

/*dbSelectArea("SB2")
dbSeek(xFilial()+SB1->B1_COD+SD4->D4_LOCAL) */

/*
dbSelectArea("SD4")
cKey:=SD4->D4_COD+SD4->D4_LOCAL+SD4->D4_OP+SD4->D4_TRT+SD4->D4_LOTECTL+SD4->D4_NUMLOTE
cLocal:= " "
*/                                  

//lExiste := .F.

/*
nQtdDc := 0
DbSelectArea("SDC")
	DbSetOrder(2)
	DbSeek(xFilial("SDC")+cKey)
	If !Eof() .And. SDC->(DC_PRODUTO+DC_LOCAL+DC_OP+DC_TRT+DC_LOTECTL+DC_NUMLOTE) == cKey 
		While !Eof().And. SDC->(DC_PRODUTO+DC_LOCAL+DC_OP+DC_TRT+DC_LOTECTL+DC_NUMLOTE) == cKey 
			cLocal  :=DC_LOCALIZ      
			//nQtdEnd :=DC_QUANT 
			nQtdEnd :=DC_QTDORIG
		
			AADD(aArray, {SB1->B1_COD,cDesc,SB1->B1_TIPO,SB1->B1_UM,nQtdEnd,SD4->D4_LOCAL,NNR->NNR_DESCRI,cLocal,SD4->D4_TRT,cRoteiro,If(mv_par12 == 1,SD4->D4_LOTECTL,""),If(mv_par12 == 1,SD4->D4_NUMLOTE,"") } )
			lExiste := .T.
			nQtdDc += nQtdEnd 
			dbSkip()
		end
	EndIf

dbSelectArea("SD4")

cLocal := ' '
*/

//IF !lExiste 
//	AADD(aArray, {SB1->B1_COD,cDesc,SB1->B1_TIPO,SB1->B1_UM,nQuantItem,SD4->D4_LOCAL,NNR->NNR_DESCRI,cLocal,SD4->D4_TRT,cRoteiro,If(mv_par12 == 1,SD4->D4_LOTECTL,""),If(mv_par12 == 1,SD4->D4_NUMLOTE,"") } )
	//Else
	//	If nQuantItem > nQtdDc
	//		AADD(aArray, {SB1->B1_COD,cDesc,SB1->B1_TIPO,SB1->B1_UM,(nQuantItem - nQtdDc),SD4->D4_LOCAL,NNR->NNR_DESCRI,cLocal,SD4->D4_TRT,cRoteiro,If(mv_par12 == 1,SD4->D4_LOTECTL,""),If(mv_par12 == 1,SD4->D4_NUMLOTE,"") } )	
	//	EndIf
//ENDIF

//Return

Static Function CabecPak(oReport) 
      
    Local aArea      := GetArea()
	Local aAreaSC2   := SC2->(GetArea())
	Local aAreaSC5   := SC5->(GetArea())
	Local aAreaSB1   := SB1->(GetArea())
    Local aCabec     := {} 
    Local cChar      := chr(160) // caracter dummy para alinhamento do cabe�alho 
    //Local titulo     := oReport:Title() 
	LOCAL cOP		  := ALLTRIM( oReport:Title() )
    Local cCliente   :=""
	LOCAL _cEmp	  := FWCodEmp()
	Local _linha0 	  := "__LOGOEMP__" 
	//Local _linha1 	  := "DAXIA DOCE AROMA IND�STRIA E COM�RCIO LTDA "/*FWFilialName(_cEmp)*/ +  cChar + "        " + cChar + "        " + cChar //"OP No.: " + cOP
	Local _linha1 	  := ""
	//Local _linha2 	  := "ORDEM DE PRODU��O " +  cChar + "        " + cChar + " Data de Entrega: " + ALLTRIM( DTOC(dDataBase) )
	Local _linha2 	  := ""
	Local _linha3 	  := cChar + "        " + cChar + RptFolha + TRANSFORM(oReport:Page(),"999999")
	Local _linha4 	  := "" 
	Local _linha5 	  := "" //"CLIENTE......: "
	Local _linha6 	  := "CLIENTE......: " // "PRODUTO......: "
	Local _linha7 	  := "LOTE.........: "
	Local _linha8	  := "" //"DATA EMISS�O.: 99/99/9999 " +  cChar + "        " + cChar + "DATA PREVIS�O.: 99/99/9999 " +  cChar + "        " + cChar 
	Local _linha9 	  := "" // "QUANTIDADE...:   9.999,99 " +  cChar + "        " + cChar + "PRODUZIDO.: 9.999,99" +  cChar + "        " + cChar + "A PRODUZIR.: 9.999,99" +  cChar + "UM.: XX"
	//Local _linha2 	  := "DAXIA/DAXR820/v." + cVersao + "        " + cChar + UPPER(AllTrim(titulo)) + "        " + cChar + RptEmiss + " " + Dtoc(dDataBase)
	Local lImpar	  := !( oReport:Page()%2 == 0 )
	Local cPicQTD	  := PesqPictQT("C2_QUANT")
	Local oTFont1    := TFont():New('Verdana',,-15,.T.)
	Local oTFont2    := TFont():New('Verdana',,-11,.T.)
	Local oTFont3    := TFont():New('Verdana',,-10,.T.)
	Local oTFont4    := TFont():New('Verdana',,-13,.T.)

	IF lSwHead
		IF oReport:oPage:nPaperSize  == 9
			oReport:Say(065,   160, "DAXIA DOCE AROMA IND�STRIA E COM�RCIO LTDA "		, oTFont2 )
			oReport:Say(115,   160, "ORDEM DE PRODU��O"									, oTFont2 )	
		ELSE
			oReport:Say(065,   10, "DAXIA DOCE AROMA IND�STRIA E COM�RCIO LTDA "		, oTFont2 )
			oReport:Say(115,   10, "ORDEM DE PRODU��O"									, oTFont2 )	
		ENDIF
		
		IF SUBSTR(cOP,1,1) == "O"
			cOP := ""
			aCabec := { _linha0, _linha1, _linha2 }
		ENDIF

		IF !EMPTY(ALLTRIM(cOP))
			
			IF lImpar
				IF oReport:oPage:nPaperSize  == 9
					//oReport:Say(065, 1900, "OP No.: " + cOP                             		, oTFont1 )
					oReport:Say(065, 1800, "OP No.: " + cOP                             		, oTFont1 )
				ELSE
					oReport:Say(065, 2020, "OP No.: " + cOP                             		, oTFont1 )
				ENDIF
			ELSE
				IF oReport:oPage:nPaperSize  == 9
					oReport:Say(065, 1800, "OP No.: " + cOP                             		, oTFont1 )
				ELSE
					oReport:Say(065, 2020, "OP No.: " + cOP                             		, oTFont1 )
				ENDIF
			ENDIF
				
			DBSELECTAREA("SC2")
			DBSETORDER(1)
			DBSEEK(xFilial("SC2")+SubStr(cOP,1,8))
			IF !EOF()
				IF EMPTY(ALLTRIM(SC2->C2_PEDIDO))
					//_linha5 	  := "CLIENTE......: DAXIA DOCE AROMA IND�STRIA E COM�RCIO LTDA."
					_linha6 	  := "CLIENTE......: DAXIA DOCE AROMA IND�STRIA E COM�RCIO LTDA."
				ELSE
					cCliente   := Posicione("SC5",1,xFilial("SC5")+SC2->C2_PEDIDO,"C5_CLIENTE") 
					cRazao	   := Posicione("SA1",1,xFilial("SA1")+cCliente,"A1_NOME")
					//_linha5 	  := "CLIENTE......: " + cCliente + " - " + cRazao
					_linha6 	  := "CLIENTE......: " + cCliente + " - " + cRazao
				ENDIF
			
				SH6->(DbSetOrder(1))

				/*
				If SH6->(DbSeek(xFilial("SH6")+cOP))
					While ! SH6->(EOF()) .and. SH6->H6_OP == Padr(cOP,Len(SH6->H6_OP))
						If !EMPTY(ALLTRIM(SH6->H6_LOTECTL)) // Pego o Primeiro Apontamento com Lote
							_linha7 	  := "LOTE.........: " + ALLTRIM( SH6->H6_LOTECTL )
							Exit
						EndIf
						SH6->(DbSkip())
					Enddo
				EndIf
				*/
				_linha7 	  := "LOTE.........: " + ALLTRIM( SC2->C2_XLOTE )
				_linha8	      := "DATA EMISS�O.: "  + ALLTRIM( DTOC(SC2->C2_EMISSAO) ) +  cChar + "        " + cChar  
				_linha8	      += "DATA PREVIS�O.: " + ALLTRIM( DTOC(SC2->C2_DATPRI) ) +  cChar + "        " + cChar 
				IF lImpar
					IF oReport:oPage:nPaperSize  == 9
						oReport:Say(115, 1800, "Data de Entrega: " + ALLTRIM( DTOC(SC2->C2_DATPRF) ) 	, oTFont3 )
						//oReport:Say(115, 1900, "Data de Entrega: " + ALLTRIM( DTOC(SC2->C2_DATPRF) ) 	, oTFont3 )
					ELSE
						oReport:Say(115, 2020, "Data de Entrega: " + ALLTRIM( DTOC(SC2->C2_DATPRF) ) 	, oTFont2 )
					ENDIF
				ENDIF

				DBSELECTAREA("SB1")
				DBSETORDER(1)
				DBSEEK( xFilial("SB1") + SC2->C2_PRODUTO )
				IF !SB1->(EOF()) 
					//_linha6 	  := "PRODUTO......: " + ALLTRIM(SC2->C2_PRODUTO) + " - " + SB1->B1_DESC
			
					//oReport:Say(175, 160, "PRODUTO......: " + ALLTRIM(SC2->C2_PRODUTO) + " - " + SB1->B1_DESC, oTFont1 )
					oReport:Say(175,  160, "PRODUTO......: " + ALLTRIM(SC2->C2_PRODUTO), oTFont1 )
					oReport:Say(185,  800, " - " + SUBSTR(SB1->B1_DESC, 1, 40) , oTFont2 )
					oReport:Say(245,  160, "QUANTIDADE...: " + ALLTRIM( TRANSFORM( SC2->C2_QUANT, cPicQTD ) ), oTFont1 )
				
					_linha9 	  := "" //"QUANTIDADE...: " + ALLTRIM( TRANSFORM(                                SC2->C2_QUANT, cPicQTD ) ) + cChar + "        " + cChar 
					_linha9 	  +=    "PRODUZIDO.: " + ALLTRIM( TRANSFORM(                                 SC2->C2_QUJE, cPicQTD ) ) + cChar + "        " + cChar 
					
					//CONOUT( "A PRODUZIR.: ")
					//CONOUT( "......................C2_QUANT.: " + TRANSFORM( SC2->C2_QUANT, cPicQTD ) )
					//CONOUT( "......................C2_PERDA.: " + TRANSFORM( SC2->C2_PERDA, cPicQTD ) )
					//CONOUT( ".......................C2_QUJE.: " + TRANSFORM(  SC2->C2_QUJE, cPicQTD ) )
					nAProd := SC2->C2_QUANT - SC2->C2_PERDA - SC2->C2_QUJE
					//CONOUT( ".C2_QUANT - C2_PERDA - C2_QUJE.: " + TRANSFORM( nAProd, cPicQTD ) )
					
					_linha9 	  +=   "PERDA.: " + ALLTRIM( TRANSFORM( SC2->C2_PERDA, cPicQTD ) ) + cChar + "        " + cChar 
					_linha9 	  +=   "A PRODUZIR.: " + ALLTRIM( TRANSFORM( nAProd, cPicQTD ) ) + cChar + "        " + cChar 
					_linha9 	  +=           "UN.: " + SB1->B1_UM + cChar 
				ENDIF
						
				
				_linha4 	  := ""


			ENDIF

			IF mv_par06 == 1
				IF  lImpar // S� IMPRIMO EM PAGINAS  PARES (ERRO IMPRESS�O FRENTE E VERSO) 
					cCode := cOP
					IF oReport:oPage:nPaperSize  == 9 // Pap�l A4
						nLBarra :=  2.0
						nCBarra :=  17.25
					ELSE // Carta
						nLBarra :=  2.0
						nCBarra :=  18.25
					ENDIF
					MSBAR3("CODE128",nLBarra,nCBarra,Trim(cCode),@oReport:oPrint,Nil,Nil,Nil,Nil ,1.5 ,Nil,Nil,Nil,.F.)
				ENDIF
			ENDIF

			/*
			aCabec := {     "__LOGOEMP__" ,cChar + "        " + cChar + RptFolha + TRANSFORM(oReport:Page(),�999999�); 
							, "DAXIA/DAXR820/v." + cVersao + "        " + cChar + UPPER(AllTrim(titulo)) + "        " + cChar + RptEmiss + " " + Dtoc(dDataBase); 
							, "Cliente...........: " + Posicione("SA1",1,xFilial("SA1")+cCliente,"A1_NREDUZ");
							, "Ordem de Produ��o.: " + cOP + "        ";                      
							, "Cliente...........: " + Posicione("SA1",1,xFilial("SA1")+cCliente,"A1_NREDUZ");
							, "Placa.............: ______________________ "; 
							, "Conferente........: ______________________ " + " Ass.de Log�stica.: ______________________ " } 
			*/
			aCabec := { _linha0, _linha1, _linha2, _linha3, _linha4, _linha5, _linha6, _linha7, _linha8, _linha9 }

		ENDIF
	ELSE
		_linha0 	  := Nil //PADC( " ESTA PAGINA FOI IMPRESSA ORIGINALMENTE EM BRANCO  ", 80 )
		_linha1 	  := Nil //""
		_linha2 	  := Nil //""
		_linha3 	  := Nil //""
		_linha4 	  := Nil //"" 
		_linha5 	  := Nil //""
		_linha6 	  := Nil //""
		_linha7 	  := Nil //""
		_linha8	      := Nil //""
		_linha9 	  := Nil //""	
	ENDIF

    RestArea( aAreaSB1 ) 
	RestArea( aAreaSC5 ) 
	RestArea( aAreaSC2 ) 
	RestArea( aArea ) 

Return aCabec 

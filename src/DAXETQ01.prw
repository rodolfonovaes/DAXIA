#Include 'TOTVS.ch'
/*/{Protheus.doc} DAXETQ01
(long_description)
@type function
@author mynam
@since 21/05/2019
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function DAXETQ01()
Local cAliasQry		:= GetNextAlias()
Local cQuery		:= ''
Local AWBROWSE		:= {}
Local AWHEAD		:= {'Lote Ctl','Lote Forn.','Fornecedor','Cod. Produto','Desc. Produto', 'Situação' , 'Dt Fabrica' , 'Validade', 'Entrada'}
Local aSizeAut	:= MsAdvSize(,.F.,400)
local oBrowse
Local oButton1
Local oButton2
Local dDataIni		:= dDataBase
Local dDataFim		:= dDataBase
Local cLoteIni		:= Space(TamSx3('B8_LOTEFOR')[1])
Local cLoteFim		:= Space(TamSx3('B8_LOTEFOR')[1])
Local cLoteCtlIni	:= Space(TamSx3('B8_LOTECTL')[1])
Local cLoteCtlFim	:= Space(TamSx3('B8_LOTECTL')[1])
Local cProdIni		:= Space(TamSx3('QEK_PRODUT')[1])
Local cProdFim		:= Space(TamSx3('QEK_PRODUT')[1])

cQuery 	:=	"SELECT B8_LOTECTL ,B8_LOTEFOR , A2_NOME , B8_PRODUTO , B1_DESC , QEK_SITENT , B8_DFABRIC , B8_DTVALID , QEK_DTENTR"
cQuery	+=	" FROM " + RetSqlName('QEK') + " QEK "
cQuery	+=	" INNER JOIN " + RetSqlName('SA2') + " SA2 ON A2_FILIAL = '" + xFilial('SA2') + "' AND A2_COD = QEK_FORNEC AND A2_LOJA = QEK_LOJFOR AND SA2.D_E_L_E_T_ = ' ' "
cQuery	+=	" INNER JOIN " + RetSqlName('SB8') + " SB8 ON B8_FILIAL = '" + xFilial('SB8') + "' AND QEK_PRODUT = B8_PRODUTO AND SB8.D_E_L_E_T_ = ' ' "
cQuery	+=	" INNER JOIN " + RetSqlName('SB1') + " SB1 ON B1_FILIAL = '" + xFilial('SB1') + "' AND QEK_PRODUT = B1_COD AND SB1.D_E_L_E_T_ = ' ' "
cQuery	+=	"	WHERE " 
cQuery	+=	"	QEK.D_E_L_E_T_ = ' ' " 
/*cQuery	+=	"	AND QEK_DTENTR BETWEEN '" + DTOS( dDataIni ) + "' AND '" + DTOS( dDataFim ) + "' "
cQuery	+=	"	AND B8_LOTEFOR BETWEEN '" + cLoteIni  + "' AND '" + cLoteFim + "' "
cQuery	+=	"	AND B8_LOTECTL BETWEEN '" + cLoteCtlIni + "' AND '" + cLoteCtlFim + "' " 
cQuery	+=	"	AND QEK_PRODUT BETWEEN '" + cProdIni  + "' AND '" + cProdFim + "' "*/
cQuery  +=  " ORDER BY QEK_DTENTR , QEK_FORNEC ,QEK_LOJFOR , QEK_PRODUT " 

cQuery	:= ChangeQuery( cQuery )
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)

Do While (cAliasQry)->(!Eof())

	IncProc()
			
	//carrega array para tela   POSICIONE('CTT',1, xFilial('CTT') + cCentroCusto , 'CTT_DESC01') ,;

	Aadd( AWBROWSE , {	;
		 (cAliasQry)->B8_LOTECTL ,;
		 (cAliasQry)->B8_LOTEFOR ,;
		 (cAliasQry)->A2_NOME ,;
		 (cAliasQry)->B8_PRODUTO ,;
		 (cAliasQry)->B1_DESC ,;
		 (cAliasQry)->QEK_SITENT ,;
 		 cToD((cAliasQry)->B8_DFABRIC) ,;
  		 cToD((cAliasQry)->B8_DTVALID) ,;
   		 cToD((cAliasQry)->QEK_DTENTR) ;		 		 		 
		 })										 
		 							   			
	(cAliasQry)->(Dbskip())
EndDo

If Len(AWBROWSE) > 0
	DEFINE DIALOG oDlg2 TITLE "Etiqueta Entrada" FROM 000, 000  TO aSizeAut[6],aSizeAut[5] COLORS 0, 16777215 PIXEL  
	  
	oBrowse := TCBrowse():New( 01 , 01, aSizeAut[6] ,230,/*bLine*/,AWHEAD,/*colsize*/,;
								  oDlg2,/*cField*/,/*uValue1*/,/*uValue2*/,/*bChange*/,/*bLDblClick*/,;
								  /*bRClick*/,/*oFont*/,/*oCursor*/,/*nClrFore*/,/*nClrBack*/,/*cMsg*/,;
								  .F.,/*cAlias*/,.T.,/*bWhen*/,.F.,/*bValid*/,/*lHScroll*/,/*lVScroll*/)		
	oBrowse:SetArray(AWBROWSE)    
	oBrowse:bLine := {||{AWBROWSE[oBrowse:nAt,01],;                      
	AWBROWSE[oBrowse:nAt,02],;
	AWBROWSE[oBrowse:nAt,03],;
	AWBROWSE[oBrowse:nAt,04],;
	AWBROWSE[oBrowse:nAt,05],;
	AWBROWSE[oBrowse:nAt,06],;
	AWBROWSE[oBrowse:nAt,07],;
	AWBROWSE[oBrowse:nAt,08],;
	AWBROWSE[oBrowse:nAt,09];
	} }    
	// Scroll type
	oBrowse:nScrollType := 1
										
	@ 050, 625 BUTTON oButton1 PROMPT "Confirmar" SIZE 036, 013 OF oDlg2 ACTION (oDlg2:End(), lContinua := .T.) PIXEL
	@ 070, 625 BUTTON oButton2 PROMPT "Cancelar" SIZE 036, 013 OF oDlg2 ACTION (oDlg2:End(), lContinua := .F.) PIXEL
	ACTIVATE DIALOG oDlg2 CENTERED 
Else
	Alert('Não foi encontrado nenhum dado, favor verificar os cadastros!') 
	lContinua := .F.
EndIf

Return
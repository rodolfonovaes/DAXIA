#Include 'TOTVS.ch'
#INCLUDE "FILEIO.CH"
#INCLUDE 'APWIZARD.CH'


User Function DAXATD14()

	Local oWizard    := NIL
	Local lFinish    := .F.
	Local cHeader    := ''
	Local cMessage   := ''
	Local cText      := ''
	Local cTitleProg := 'Atualização D14'

	Local oFileCSV   := Nil
	Local cTextP2    := ''
	Local oTextP2    := Nil

	Local cNameFunc  := Space(100)
	Local oNameFunc  := Nil
	Local cTextP3    := ''
	Local oTextP3    := Nil
	Local nTipoData  := 1
	Local lNoAcento  := .T.
	Local oNoAcento  := Nil
	Local lOrdVetX3  := .T.
	Local oOrdVetX3  := .T.

	Local cFileLog   := ''
	Local cMascara := GetMv("MV_MASCGRD")
	Static __nValLcto_	:= 0
	Static __cHistLct	:= ''
	Static __cCtaDeb	:= ''
	Static __cCtaCred	:= ''
	Static __cCcDeb		:= ''
	Static __cCcCred	:= ''		
	Static cFileImp   := Space(100)
	Private nTamRef := Val(Substr(cMascara,1,2))
	Private nTamLin := Val(Substr(cMascara,4,2))
	Private nTamCol := Val(Substr(cMascara,7,2))

	DEFINE FONT oArial10	NAME 'Arial'       WEIGHT 10
	DEFINE FONT oCouri11	NAME 'Courier New' WEIGHT 11


	cHeader  := 'Atualização da D14.'
	cMessage := 'Assistente para processamento'
	cText    := 'Este assistente irá auxilia lo na configuração dos par?etros para realização da atualização '
	cText    += 'dos dados a partir da tabela SB8 (.CSV).'+CRLF+' O objetivo desta aplicação ?efetuar a atualização '
	cText    += 'da D14.' + CRLF
	cText    += CRLF+ CRLF
	cText    += 'Clique em "Avançar" para continuar...'

	DEFINE	WIZARD	oWizard TITLE	'Atualização D14';
		HEADER	cHeader;
		MESSAGE	cMessage;
		TEXT	cText;
		NEXT 	{|| .T.};
		FINISH 	{|| .F.}

	cMessage := 'Iniciar o processamento...'
	CREATE	PANEL 	oWizard  ;
		HEADER 	cHeader;
		MESSAGE	cMessage;
		BACK	{|| .T.} ;
		NEXT	{|| .F.};
		FINISH	{|| lFinish := .T.}

	TSay():New(045, 005, {|| 'Clique em "Finalizar" para encerrar o assistente e inicar o processamento...' },;
		oWizard:oMPanel[3],, oCouri11,,,, .T.,,, 200, 50)

	ACTIVATE WIZARD oWizard Center


	If lFinish
	    //--PROCESSA A IMPORTACAO:
		Processa({||  ProcImp() }, cTitleProg, 'Processando importação...')
	EndIf

Return .T.


Static Function ProcImp()
Local lErro			:= .F.
Local cLine 		:= ""		
Local cToken		:= ";"	
Local nHandle		:= 0 
Local nLine			:= 1
Local n				:= 0
Local cHoraImp		:= ""
Local cDirArquivo	:= "" 
Local cNomeOld		:= ""
Local cLog			:= ""
Local nH			:= 0
Local nPosErro		:= 0
Local nPFilial      := 0
Local nPProd        := 0
Local nPLote        := 0
Local nPLocal       := 0
Local nPLoteFor     := 0
Local nPClifor      := 0
Local nPLoja        := 0
Local nPXFabri      := 0
Local nPXLFabri     := 0
Local nPFabric      := 0
Local nPXPais       := 0
Local nPDFabric     := 0
Local nLinha        := 1
Local cAliasQry		:= GetNextAlias()
Local cQuery		:= ''
Private nHdlPrv		:= 0

cQuery 	:=	"SELECT R_E_C_N_O_ AS REC, D14_PRODUT "
cQuery	+=	" FROM " + RetSqlName('D14') + " D14 "
cQuery	+=	"	WHERE " 
cQuery	+=	"	D14.D_E_L_E_T_ = ' ' " 
cQuery  +=  " ORDER BY D14_PRODUT "

cQuery	:= ChangeQuery( cQuery )
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)

If (cAliasQry)->(!Eof())
    ProcRegua(RecCount())

    While (cAliasQry)->(!Eof())		
        SB8->(DbSetOrder(1))
        SB8->(DbSeek(xFilial('SB8') + (cAliasQry)->D14_PRODUT))
        
        While SB8->B8_PRODUTO == (cAliasQry)->D14_PRODUT
        
            IncProc()
            D14->(DbGoTo((cAliasQry)->REC))
            If D14->D14_DTVALID == STOD(' ')
                Reclock('D14',.F.)  
                D14->D14_DTVALID := SB8->B8_DTVALID
                D14->D14_DTFABR  := SB8->B8_DFABRIC
                MsUnlock()
            EndIf
            
            (cAliasQry)->(DbSkip())	

        EndDo
        
        (cAliasQry)->(DbSkip())	

    EndDo
    MsgInfo('Fim da Atualização!')
Else
    MsgInfo('Não foram encontrados dados!')
EndIf

Return
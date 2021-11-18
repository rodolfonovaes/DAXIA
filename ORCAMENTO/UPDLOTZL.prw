#Include 'TOTVS.ch'
#INCLUDE "FILEIO.CH"
#INCLUDE 'APWIZARD.CH'

#INCLUDE "TOPCONN.CH"
#include "FWMVCDEF.CH"
#INCLUDE "MATXDEF.CH"

User Function UPDLOTZL()

	Local oWizard    := NIL
	Local lFinish    := .F.
	Local cHeader    := ''
	Local cMessage   := ''
	Local cText      := ''
	Local cTitleProg := 'Importação de Planilha'

	
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
	Static cFileImp   := Space(100)
	Private nTamRef := Val(Substr(cMascara,1,2))
	Private nTamLin := Val(Substr(cMascara,4,2))
	Private nTamCol := Val(Substr(cMascara,7,2))

	DEFINE FONT oArial10	NAME 'Arial'       WEIGHT 10
	DEFINE FONT oCouri11	NAME 'Courier New' WEIGHT 11


	cHeader  := 'Atualização da SA1.'
	cMessage := 'Assistente para processamento'
	cText    := 'Este assistente irá auxilia lo na configuração dos par?etros para realização da importação '
	cText    += 'dos dados a partir de um arquivo (.CSV).'+CRLF+' O objetivo desta aplicação ?efetuar a atualização '
	cText    += 'da SA1.' + CRLF
	cText    += CRLF+ CRLF
	cText    += 'Clique em "Avançar" para continuar...'

	DEFINE	WIZARD	oWizard TITLE	'Importação de planilha';
		HEADER	cHeader;
		MESSAGE	cMessage;
		TEXT	cText;
		NEXT 	{|| .T.};
		FINISH 	{|| .F.}


	cMessage := 'Informe o local e o arquivo (.CSV) para importação dos dados...'
	CREATE	PANEL 	oWizard  ;
		HEADER 	cHeader;
		MESSAGE	cMessage;
		BACK	{|| .T.} ;
		NEXT	{|| !Empty(cFileImp) };
		FINISH	{|| .F.}

	cTextP2	:= 'Restrições:' + Chr(10)+Chr(13)
	cTextP2	+= Chr(10)+Chr(13)
	cTextP2	+= 'a.) O arquivo informado deve estar no formato CSV.' + Chr(10)+Chr(13)
	cTextP2	+= Chr(10)+Chr(13)
	cTextP2	+= 'b.) Os produtos devem estar cadastrados no sistema.' + Chr(10)+Chr(13)
	cTextP2	+= Chr(10)+Chr(13)
	cTextP2	+= 'c.) No conte?o dos campos n? pode haver caracteres especiais como aspas simples ou duplas ' + "(')" + '(")' + ' e ponto e v?gula (;). Isso ira ocasionar em erro na montagem do arquivo.'

	@ 012, 010 Say oTextP2 PROMPT cTextP2 Size 228, 094 Of oWizard:oMPanel[2] FONT oArial10 Pixel
	@ 085, 005 GROUP To 113, 245 PROMPT "Local e nome do arquivo:" OF oWizard:oMPanel[2] Pixel
	@ 095, 020 MsGet oFileCSV Var cFileImp Valid( If( File(cFileImp), .T., ( Alert("O arquivo informado para importação n? existe!") ,.F.) ) .Or. Empty(cFileImp) ) Size 212, 010 Of oWizard:oMPanel[2] F3 "DIR" Pixel


	cMessage := 'Iniciar o processamento...'
	CREATE	PANEL 	oWizard  ;
		HEADER 	cHeader;
		MESSAGE	cMessage;
		BACK	{|| .T.} ;
		NEXT	{|| .F.};
		FINISH	{|| lFinish := .T.}

	TSay():New(010, 005, {|| 'Ao t?mino do processo ser?criado o arquivo de log no mesmo diret?io do arquivo a ser importado. ' },;
		oWizard:oMPanel[3],, oCouri11,,,, .T.,,, 200, 50)

	TSay():New(045, 005, {|| 'Clique em "Finalizar" para encerrar o assistente e inicar o processamento...' },;
		oWizard:oMPanel[3],, oCouri11,,,, .T.,,, 200, 50)

	ACTIVATE WIZARD oWizard Center


	If lFinish
	//--PROCESSA A IMPORTACAO:
		cFileLog := SubStr(AllTrim(cFileImp), 1, At('.', AllTrim(cFileImp)) - 1) + '.LOG'

		Processa({||  ProcImp(Alltrim(cFileImp), cFileLog/*, Alltrim(cNameFunc),1,.T., lOrdVetX3*/) }, cTitleProg, 'Processando importação...')
	EndIf

Return .T.


Static Function ProcImp(cFileImp, cFileLog)
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
Local nPCod         := 1
Local nPLoja        := 2
Local nLinha        := 1
Local lReclock      := .F.
Local cItem     := '01'
Local cPedido       := ''
Private nHdlPrv		:= 0
Private nRecTMP1	:= 0
Private	nSeleciona	:= 0
Private dDataEft    := STOD(' ')
Private nRecSC6	:= 0

ProcRegua(RecCount())
cArquivo  := ""

SZL->(DBGOTOP())
WHILE !SZL->(EOF())		
    IncProc()
    nLinha ++
    lErro := .F.
    
    cPedido := RtPedido()
    SC5->(DbSetOrder(1))
    SC6->(DbSetOrder(1))
    If SC5->(DbSeek(xFilial('SC5') + cPedido)) 
        If SC6->(DbSeek(SC5->C5_FILIAL + SC5->C5_NUM + SZL->ZL_ITEM + SZL->ZL_PRODUTO))
            If Empty(SZL->ZL_LOTECTL)
                Reclock('SZL',.F.)
                SZL->ZL_LOTECTL := SC6->C6_LOTECTL
                MsUnlock()
            EndIf
        EndIf
    EndIf 
    SZL->(DBSKIP())
EndDo
						
LjWriteLog(cLog, "Fim da importação do arquivo " + cFileImp )
MsgInfo('Fim da Atualização!')

Return


/*/{Protheus.doc} Copia2Lidos
Move arquivo para uma determinada pasta de arquivos lidos

@author Rodolfo Novaes
@since 18/02/2015
@version 1.0
/*/
Static Function Copia2Lidos( cOrigem , cDestino )

Local nTry		:= 1

While nTry <= 15 .Or. !File( cDestino )

	__CopyFile( lower(cOrigem) , lower(cDestino) )
	Sleep(100)
	nTry += 1
	
End

Return File( cDestino )

/*/{Protheus.doc} DeletaLido
Deleta arquivo lido depois de copiado para pasta de backup

@author Rodolfo Novaes
@since 18/02/2015
@version 1.0
/*/
Static Function DeletaLido( cOrigem )

Local nTry		:= 1 

While nTry <= 15 .Or. File(cOrigem) 				 				

	Ferase(cOrigem)	
	Sleep(100)
	nTry += 1					

End
		 			
Return !File(cOrigem)



/*{Protheus.doc} Log2Array
Abre arquivo de LOG da ExecAuto e retorna em um array
@author Rodolfo Novaes
@since 10/04/2015
@version 1.0
*/
Static Function Log2Array(cFileLog, lAchaErro )	
	
	Local nHdl		:= -1  
	Local nPos		:= 0
	Local nBytes	:= 0
	
	Local cLinha	:= "" 
	Local cChar		:= ""   

	Local cRet		:= ""
	Local aRet		:= {}

	Default cFileLog	:= ""
	Default lAchaErro	:= .T.
	
	IF !Empty(cFileLog)
		nHdl := FOpen(cFileLog)	
	Endif

	If !(nHdl == -1)
	
		nBytes := FSeek(nHdl, 0, 2)	
		FSeek(nHdl, 0)	

		If nBytes > 0

			For nPos := 1 To nBytes	
	
				FRead(nHdl, @cChar, 1)
				
				// Quebra de linha (chr(13)+chr(10) = CR+LF)
				If cChar == Chr(10) .Or. nPos == nBytes 	
					
					If lAchaErro .And. "< -- Invalido" $ cLinha
						cRet	:= "Campo -> " + cLinha	
						Exit				
					Endif

					IF !Empty(cLinha)
						aAdd(aRet, cLinha)
					Endif
				
					cLinha :=  ""
										 
				ElseIf cChar <> Chr(13) 

					cLinha += cChar

				EndIf
	
			Next nPos

		EndIf
	
		FClose(nHdl)
	
	Endif    
		
	IF Empty(cRet) .And.  Len(aRet) >= 2  
		cRet := RTrim(aRet[1]) + " => " + RTrim(aRet[Len(aRet)])
	Endif
	
Return IIF( lAchaErro , cRet , aRet )


Static Function RtPedido()
Local cPedido := ''
Local cQuery	:= ''
Local cAliasQry := GetNextAlias()

cQuery := "SELECT C5_NUM  "
cQuery += "  FROM " + RetSQLTab('SC5')
cQuery += "  WHERE  "
cQuery += "  C5_FILIAL = '" + xFilial('SC5') + "' AND C5_XNUMCJ = '" + SZL->ZL_NUM + "'  "
cQuery += "  AND SC5.D_E_L_E_T_ = ' '"

TcQuery cQuery new Alias ( cAliasQry )

(cAliasQry)->(dbGoTop())

If !(cAliasQry)->(EOF())
	cPedido := (cAliasQry)->C5_NUM
EndIf

(cAliasQry)->(DbCloseArea())
Return cPedido

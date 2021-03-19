#Include 'TOTVS.ch'
#INCLUDE "FILEIO.CH"
#INCLUDE 'APWIZARD.CH'


User Function IMPLIGA()

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


	cHeader  := 'Atualização da ZZE.'
	cMessage := 'Assistente para processamento'
	cText    := 'Este assistente irá auxilia lo na configuração dos par?etros para realização da importação '
	cText    += 'dos dados a partir de um arquivo (.CSV).'+CRLF+' O objetivo desta aplicação ?efetuar a atualização '
	cText    += 'da tabela de Historico de Ligações.' + CRLF
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
	cTextP2	+= 'b.) Os Vendedores devem estar cadastrados no sistema.' + Chr(10)+Chr(13)
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
Local nPData        := 1
Local nPVend        := 2
Local nPRamal       := 3
Local nPRealiz      := 4
Local nPReceb       := 5
Local nPTotal       := 6
Local nLinha        := 1
Private nHdlPrv		:= 0

ProcRegua(RecCount())
cArquivo  := ""

If File( cFileImp )

	// Abre arquivo CSV
	nHandle		:= FT_FUSE( cFileImp ) 	
	cHoraImp	:= Time() 
	
	// Pasta para mover o arquivo processado e gravar o Log
	cDirArquivo	:= cFileLog
	cLog		:= cFileLog
	//cNomeOld	:= Left(cArquivo,Len(cArquivo)-4) + ".old"
	
	If !(nHandle == -1)
		MontaDir( cFileImp )

		ProcRegua(FT_FLastRec())		
		FT_FGoTop()

		LjWriteLog(cLog, "Iniciando importação do arquivo " + cFileImp )
		
		// Le o arquivo ja processando as inclusoes
		While !FT_FEof() 
    
			IncProc()

            nLinha ++
			lErro := .F.
			cLine 	:= AllTrim(FT_FReadLn())
			aLine 	:= Separa(cLine,cToken)

			Dbselectarea('SA3')
			SA3->(dbsetorder(1))									
			if  !SA3->(Dbseek(xFilial('SA3') +PADR(aLine[nPVend],TAMSX3('A3_COD')[1]) ))
				LjWriteLog(cLog, "Linha : " + Alltrim(STR(nLinha)) + ' Registro não encontrado na SA3! '+ aLine[nPVend]  )  
            Else
                Reclock('ZZE',.T.)  
                ZZE->ZZE_FILIAL := xFilial('ZZE')
                ZZE->ZZE_DATA   := CTOD(aLine[nPData])
                ZZE->ZZE_VEND   := aLine[nPVend]
                ZZE->ZZE_RAMAL   := aLine[nPRamal]
                ZZE->ZZE_REALIZ   := Val(aLine[nPRealiz])
                ZZE->ZZE_RECEBI   := Val(aLine[nPReceb])
                ZZE->ZZE_TOTAIS    := Val(aLine[nPTotal])
                MsUnlock()
			EndIf
			
			FT_FSkip()		

		EndDo
		
		FT_FUSE()
		
		// Copia arquivo para a pasta de processados
		If Copia2Lidos( cFileImp , Left(cFileImp,Len(cFileImp)-4) + ".old" )		
			
			// Deleta arquivo original
			 DeletaLido(cFileImp)			

		Endif
						
		LjWriteLog(cLog, "Fim da importação do arquivo " + cFileImp )
		MsgInfo('Fim da Atualização!')
	EndIf

EndIf

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
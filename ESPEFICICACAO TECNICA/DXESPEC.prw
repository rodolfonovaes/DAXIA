#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'MSOLE.CH'

Static cRootPath   := AllTrim(GetPvProfString(GetEnvServer(), 'RootPath', 'ERROR', GetADV97()) + If(Right(AllTrim(GetPvProfString(GetEnvServer(), 'RootPath', 'ERROR', GetADV97())), 1) == '\', '', '\'))
Static cStartPath  := AllTrim(GetPvProfString(GetEnvServer(), 'StartPath', 'ERROR', GetADV97()) + If(Right(AllTrim(GetPvProfString(GetEnvServer(), 'StartPath', 'ERROR', GetADV97())), 1) == '\', '', '\'))
Static cPathFisico := Left(cRootPath, Len(cRootPath) - 1) + If(Left(cStartPath, 1) <> '\', '\', '') + cStartPath

 /*/{Protheus.doc} DXESPEC
    (long_description)
    @type  Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function DXESPEC(aEspec,nTipo)
Local cArqModel     := ''
Local cExtension    :=  '*.PDF'
Local cPathDest     := 'C:\temp\'
Local cArqModel     := ''
Local cNewFile      := ''
Local cModel        := 'DXESPTEC2'
Local lContinua     := .T.
Local n             := 0
Local aOrgano       := {}
Local aFisico       := {}
Local aMicro        := {}
Local aColsEx       := {}
Local cContador     := '01'
Local aAlerg        := {}
Local aCabec        := {}
Local aLaudo        := {}
Local cLaudo        := ''
Local cEspec        := ''
Local nX            := 0

cArqModel := cStartpath + 'MODELOS\'+ cModel + '.dotm'

// ---------------------------------------
// VERIFICA SE O ARQUIVO "MODELO" EXISTE
// ---------------------------------------
If !File(cArqModel)
    lContinua := .F.
    Aviso('ATENÇÂO', 'O arquivo ' + cArqModel + ' não existe! Entre em contato com o Administrador do sistema.', {'OK'}, 2)
EndIf


// ------------------------------------------------
// TRANSFERE MODELO WORD DO SERVIDOR P/ ESTACAO
// ------------------------------------------------
If lContinua
    cArqTemp := AllTrim(GetTempPath()) + If(Right(AllTrim(GetTempPath()), 1) == '\', '', '\')
    If !CpyS2T(cArqModel,  cArqTemp , .F.)
        lContinua := .F.
        Aviso('ATENÇÃO',;
                'Não foi possível transferir o modelo Word do Servidor para sua estação de trabalho! Tente reiniciar o computador. Caso o problema persista, entre em contato com o Administrador do sistema' + CRLF + ;
                'Pasta destino : ' + CRLF + cArqTemp + " Codigo do erro " + Str(Ferror()) ;
                , {'OK'}, 2)
    Else
//		If MV_PAR17 == 1
//			cArqTemp := cArqTemp + 'GPPMSR01.dot'
    //	Else
            cArqTemp := cArqTemp + cModel +'.dotm'
        //EndIf
    EndIf
EndIf

aCabec := { ''                      , ; // 01 - Nota Fiscal de Saï¿½da
            ''                      , ; // 02 - Sï¿½rie da Nota Fiscal de Saida
            ''                      , ; // 03 - Cliente/Fornecedor
            ''                      , ; // 04 - Loja
            ''                      , ; // 05 - Nome Cliente
            IIF(ISINCALLSTACK('QIEA010'),QE6->QE6_PRODUT,QPK->QPK_PRODUT)         , ; // 06 - Cï¿½digo do Produto
            SB1->B1_DESC            , ; // 07 - Nome do Produto
            SB8->B8_LOTECTL         , ; // 08 - Lote 
            0                       , ; // 09 - Quantidade
            IIF(ISINCALLSTACK('QIEA010'),QE6->QE6_DTCAD,QPK->QPK_DTPROD)        , ; // 10 - Emissao
            SB1->B1_TIPO             , ; // 11 - Tipo ME (QIE) / PA (QIP)
            SB8->B8_DFABRIC         , ; // 12 - Data de Fabricaçãoo
            SB8->B8_DTVALID         , ; // 13 - Data de Validade
            SB8->B8_LOTEFOR         , ; // 14 - Lote Fornecedor (Sï¿½ Entradas)
            IIF(ISINCALLSTACK('QIEA010'),.F.,.T.)  } // 15 - Manufaturado (.T.) / Revenda (.F.) //AJUSTAR

//IF !U_MTDADLAU(aCabec[15], aCabec, @aLaudo, @cLaudo, .F.)
 //   lContinua := .F.
 //   Alert('Nï¿½o foram encontrado dados das propriedades fisico quimicas/microbiologicas')
//EndIF

If lContinua
    //cPathDest  := Alltrim(cGetFile ('Arquivo' + cExtension + '|' + cExtension +'|' , 'Selecione a pasta para gravaçãoo.', 1, '', .T., GETF_LOCALHARD+GETF_RETDIRECTORY,.F.))
    cFileName := If(Right(cPathDest, 1) == '\', '', '\') + alltrim(SB1->B1_COD) + Alltrim(aEspec[1])+ StrTran(cExtension, '*', '')
    cNewFile := cPathDest + cFileName
    // ESTABELECE COMUNICACAO COM O MS WORD
    // --------------------------------------
    oWord := OLE_CreateLink()
    OLE_SetProperty(oWord, oleWdVisible, .F.)
    if oWord == "-1" //Se retornar -1 no debug , apontar o remote do smartclient pro mesmo endereï¿½o do ambiente
        Aviso('ATENÇÃO', 'Não foi possível estabelecer a conexao com o MS-Word!', {'OK'}, 2)
    Else
        // -----------------------------------
        // CARREGA MODELO
        // -----------------------------------
        OLE_NewFile(oWord, Alltrim(cArqTemp))


        OLE_SetDocumentVar(oWord, 'cEspec' 			    , aEspec[1])
        OLE_SetDocumentVar(oWord, 'cRev' 			    , aEspec[2])
        OLE_SetDocumentVar(oWord, 'cData' 			    , aEspec[3])
        OLE_SetDocumentVar(oWord, 'cNomeCom' 			, aEspec[5])
        OLE_SetDocumentVar(oWord, 'cCodProd' 			, aEspec[4])
        OLE_SetDocumentVar(oWord, 'cProduto' 	        , aEspec[6])
        OLE_SetDocumentVar(oWord, 'cIns' 	            , aEspec[7])
        OLE_SetDocumentVar(oWord, 'cDescricao'          , aEspec[8])
        OLE_SetDocumentVar(oWord, 'cProcedencia'        , aEspec[9])
        OLE_SetDocumentVar(oWord, 'cEmbalagem'          , aEspec[10])
        OLE_SetDocumentVar(oWord, 'cEstocagem' 	        , aEspec[11])
        OLE_SetDocumentVar(oWord, 'cValidade' 	        , aEspec[12])
        OLE_SetDocumentVar(oWord, 'cInfNutricional'     , aEspec[13])
        //OLE_SetDocumentVar(oWord, 'cOgm'                , aEspec[14])
        OLE_SetDocumentVar(oWord, 'cInfAdicionais'      , aEspec[15])
        OLE_SetDocumentVar(oWord, 'cLegislacao'         , aEspec[16])
        OLE_SetDocumentVar(oWord, 'cFuncionalidade'     , aEspec[17])
        OLE_SetDocumentVar(oWord, 'cAplicacoes'         , aEspec[18])
        OLE_SetDocumentVar(oWord, 'cObservacoes'        , aEspec[19])
        OLE_SetDocumentVar(oWord, 'cIncName'            , aEspec[20])
        OLE_SetDocumentVar(oWord, 'cCas'                , aEspec[21])
        OLE_SetDocumentVar(oWord, 'cComposicao'         , aEspec[22])
        OLE_SetDocumentVar(oWord, 'cOrigem'             , aEspec[23])
        OLE_SetDocumentVar(oWord, 'cPais'               , aEspec[24])
        OLE_SetDocumentVar(oWord, 'cMicrobio'           , aEspec[25])
        OLE_SetDocumentVar(oWord, 'cInfNutricional'     , aEspec[26])
        OLE_SetDocumentVar(oWord, 'cOgm'                , aEspec[27])
        OLE_SetDocumentVar(oWord, 'cPreparacao'         , aEspec[28])
        OLE_SetDocumentVar(oWord, 'cMicroMacro'         , aEspec[29])
        OLE_SetDocumentVar(oWord, 'cContamina'         , aEspec[30])
          


        If nTipo == 1 // entrada
            QE8->(DbSetOrder(1))
            IF QE8->(DbSeek(xFilial('QE8') + aEspec[4] + aEspec[2]))
                While xFilial('QE8') + aEspec[4] + aEspec[2] == QE8->(QE8_FILIAL + QE8_PRODUT + QE8_REVI) 
                    If QE8->QE8_LABOR == 'ORGANO'
                        If aScan(aOrgano,{|x| AllTrim(x[1])==Alltrim(Posicione('QE1',1,xFilial('QE1') + QE8->QE8_ENSAIO,'QE1_DESCPO'))}) == 0
                            aadd(aOrgano,{Posicione('QE1',1,xFilial('QE1') + QE8->QE8_ENSAIO,'QE1_DESCPO'),QE8->QE8_TEXTO})
                        EndIf
                    EndIf
                    If ALLTRIM(QE8->QE8_LABOR) == 'MICRO'
                        If aScan(aMicro,{|x| AllTrim(x[1])==Alltrim(Posicione('QE1',1,xFilial('QE1') + QE8->QE8_ENSAIO,'QE1_DESCPO'))}) == 0
                            aadd(aMicro,{Posicione('QE1',1,xFilial('QE1') + QE8->QE8_ENSAIO,'QE1_DESCPO'),QE8->QE8_TEXTO})
                        EndIf
                    EndIf
                    If ALLTRIM(QE8->QE8_LABOR) == 'FISQUI'
                        If aScan(aFisico,{|x| AllTrim(x[1])==Alltrim(Posicione('QE1',1,xFilial('QE1') + QE8->QE8_ENSAIO,'QE1_DESCPO'))}) == 0
                            aadd(aFisico,{Posicione('QE1',1,xFilial('QE1') + QE8->QE8_ENSAIO,'QE1_DESCPO'),QE8->QE8_TEXTO})
                        EndIf
                    EndIf                    
                    QE8->(DbSkip())
                EndDo
            EndIF

            For nX := 1 to Len(aLaudo) 
                //aadd(aFisico,{ALLTRIM(aLaudo[nX][1]),ALLTRIM(aLaudo[nX][2])})
                //aadd(aMicro,{ALLTRIM(aLaudo[nX][1]),ALLTRIM(aLaudo[nX][2])})
            Next            

           QE7->(DbSetOrder(1))
            IF QE7->(DbSeek(xFilial('QE7') + aEspec[4] + aEspec[2]))
                While xFilial('QE7') + aEspec[4] + aEspec[2] == QE7->(QE7_FILIAL + QE7_PRODUT + QE7_REVI)
                    IF ALLTRIM(QE7->QE7_MINMAX) == "1"
                        cEspec := QE7->QE7_LIE+" á "+QE7->QE7_LSE
                    ELSEIF  ALLTRIM(QE7->QE7_MINMAX) ==  "2" // CONTRIOLA  MINIMO
                        cEspec := " Acima/Igual á  "+QE7->QE7_LIE 
                    ELSEIF  ALLTRIM(QE7->QE7_MINMAX) ==  "3" // CONTRIOLA  MAXIMO 
                        cEspec := " Abaixo/Igual á "+QE7->QE7_LSE
                    ENDIF

                    If !empty(QE7->QE7_UNIMED)
                        SAH->(DbSetOrder(1))
                        If SAH->(DbSeek(xFilial('SAH') + QE7->QE7_UNIMED))
                            cEspec += ' ' + SAH->AH_UMRES
                        EndIf
                    EndIf
                    
                    If ALLTRIM(QE7->QE7_LABOR) == 'FISQUI'
                        If aScan(aFisico,{|x| AllTrim(x[1])==Alltrim(Posicione('QE1',1,xFilial('QE1') + QE7->QE7_ENSAIO,'QE1_DESCPO'))}) == 0
                            aadd(aFisico,{Posicione('QE1',1,xFilial('QE1') + QE7->QE7_ENSAIO,'QE1_DESCPO'),cEspec})
                        EndIf
                    ElseIF ALLTRIM(QE7->QE7_LABOR) == 'MICRO'
                        If aScan(aMicro,{|x| AllTrim(x[1])==Alltrim(Posicione('QE1',1,xFilial('QE1') + QE7->QE7_ENSAIO,'QE1_DESCPO'))}) == 0
                            aadd(aMicro,{Posicione('QE1',1,xFilial('QE1') + QE7->QE7_ENSAIO,'QE1_DESCPO'),cEspec})
                        EndIf
                    ElseIf ALLTRIM(QE7->QE7_LABOR) == 'ORGANO'
                        If aScan(aOrgano,{|x| AllTrim(x[1])==Alltrim(Posicione('QE1',1,xFilial('QE1') + QE7->QE7_ENSAIO,'QE1_DESCPO'))}) == 0
                            aadd(aOrgano,{Posicione('QE1',1,xFilial('QE1') + QE7->QE7_ENSAIO,'QE1_DESCPO'),cEspec})                        
                        EndIf
                    EndIf
                    QE7->(DbSkip())
                EndDo
            EndIF
        Else
            QP8->(DbSetOrder(1))
            IF QP8->(DbSeek(xFilial('QE8') + aEspec[4] + aEspec[2]))
                While xFilial('QP8') + aEspec[4] + aEspec[2] == QP8->(QP8_FILIAL + QP8_PRODUT + QP8_REVI)
                    If QP8->QP8_LABOR == 'ORGANO'
                        If aScan(aOrgano,{|x| AllTrim(x[1])==Alltrim(Posicione('QP1',1,xFilial('QP1') + QP8->QP8_ENSAIO,'QP1_DESCPO'))}) == 0
                            aadd(aOrgano,{Alltrim(Posicione('QP1',1,xFilial('QP1') + QP8->QP8_ENSAIO,'QP1_DESCPO')),QP8->QP8_TEXTO})
                        EndIf
                    EndIf
                    If ALLTRIM(QP8->QP8_LABOR) == 'MICRO'
                        If aScan(aMicro,{|x| AllTrim(x[1])==Alltrim(Posicione('QP1',1,xFilial('QP1') + QP8->QP8_ENSAIO,'QP1_DESCPO'))}) == 0
                            aadd(aMicro,{Posicione('QP1',1,xFilial('QP1') + QP8->QP8_ENSAIO,'QP1_DESCPO'),QP8->QP8_TEXTO})
                        EndIf
                    EndIf    
                    If ALLTRIM(QP8->QP8_LABOR) == 'FISQUI'
                        If aScan(aFisico,{|x| AllTrim(x[1])==Alltrim(Posicione('QP1',1,xFilial('QP1') + QP8->QP8_ENSAIO,'QP1_DESCPO'))}) == 0
                            aadd(aFisico,{Posicione('QP1',1,xFilial('QP1') + QP8->QP8_ENSAIO,'QP1_DESCPO'),QP8->QP8_TEXTO})
                        EndIf
                    EndIf                                      
                    QP8->(DbSkip())
                EndDo
            EndIF

            QP7->(DbSetOrder(1))
            IF QP7->(DbSeek(xFilial('QP7') + aEspec[4] + aEspec[2]))
                While xFilial('QP7') + aEspec[4] + aEspec[2] == QP7->(QP7_FILIAL + QP7_PRODUT + QP7_REVI)
                    IF ALLTRIM(QP7->QP7_MINMAX) == "1"
                        cEspec := QP7->QP7_LIE+" á "+QP7->QP7_LSE
                    ELSEIF  ALLTRIM(QP7->QP7_MINMAX) ==  "2" // CONTRIOLA  MINIMO
                        cEspec := " Acima/Igual á "+QP7->QP7_LIE 
                    ELSEIF  ALLTRIM(QP7->QP7_MINMAX) ==  "3" // CONTRIOLA  MAXIMO 
                        cEspec := " Abaixo/Igual á "+QP7->QP7_LSE
                    ENDIF

                    If !empty(QP7->QP7_UNIMED)
                        SAH->(DbSetOrder(1))
                        If SAH->(DbSeek(xFilial('SAH') + QP7->QP7_UNIMED))
                            cEspec += ' ' + SAH->AH_UMRES
                        EndIf
                    EndIf

                    If ALLTRIM(QP7->QP7_LABOR) == 'FISQUI'
                        If aScan(aFisico,{|x| AllTrim(x[1])==Alltrim(Posicione('QP1',1,xFilial('QP1') + QP7->QP7_ENSAIO,'QP1_DESCPO'))}) == 0
                            aadd(aFisico,{Posicione('QP1',1,xFilial('QP1') + QP7->QP7_ENSAIO,'QP1_DESCPO'),cEspec})
                        EndIf
                    ElseIF ALLTRIM(QP7->QP7_LABOR) == 'MICRO'
                        If aScan(aMicro,{|x| AllTrim(x[1])==Alltrim(Posicione('QP1',1,xFilial('QP1') + QP7->QP7_ENSAIO,'QP1_DESCPO'))}) == 0
                            aadd(aMicro,{Posicione('QP1',1,xFilial('QP1') + QP7->QP7_ENSAIO,'QP1_DESCPO'),cEspec})
                        EndIf
                    ElseIf ALLTRIM(QP7->QP7_LABOR) == 'ORGANO'
                        If aScan(aOrgano,{|x| AllTrim(x[1])==Alltrim(Posicione('QP1',1,xFilial('QP1') + QP7->QP7_ENSAIO,'QP1_DESCPO'))}) == 0
                            aadd(aOrgano,{Posicione('QP1',1,xFilial('QP1') + QP7->QP7_ENSAIO,'QP1_DESCPO'),cEspec})                                                
                        EndIf
                    EndIf
                    QP7->(DbSkip())
                EndDo
            EndIF  

          //  For nX := 1 to Len(aLaudo) 
          //      aadd(aFisico,{ALLTRIM(aLaudo[nX][1]),ALLTRIM(aLaudo[nX][2])})
         //       aadd(aMicro,{ALLTRIM(aLaudo[nX][1]),ALLTRIM(aLaudo[nX][2])})
         //   Next                     
        EndIf

        ZZH->(DbSetOrder(1))
        //Monta aCols
        SX3->(DbSetOrder(2))
        While SX3->(DbSeek('ZZH_SENS' + cContador)) .And. Alltrim(SX3->X3_TITULO) <> 'x'
            
            If ZZH->(DbSeek(xFilial('ZZH') + aEspec[4]))
                
                If ZZH->&('ZZH_SENS'+cContador) <> 'N' .And. !empty(ZZH->&('ZZH_SENS'+cContador))
                    aAdd(aAlerg,{})
                    Aadd(aAlerg[Len(aAlerg)],SX3->X3_TITULO)
                    //C=Contem;N=Nao Contem;P=Pode Conter;D=Contem Derivados 
                    Do Case
                        Case  ZZH->&('ZZH_SENS'+cContador) == 'C'                                                                        
                            Aadd(aAlerg[Len(aAlerg)],'Contem')
                        Case  ZZH->&('ZZH_SENS'+cContador) == 'N'                                                                        
                            Aadd(aAlerg[Len(aAlerg)],'Não Contem')
                        Case  ZZH->&('ZZH_SENS'+cContador) == 'P'                                                                        
                            Aadd(aAlerg[Len(aAlerg)],'Pode Conter')
                        Case  ZZH->&('ZZH_SENS'+cContador) == 'D'                                                                        
                            Aadd(aAlerg[Len(aAlerg)],'Contem Derivados')    
                        OTHERWISE
                            Aadd(aAlerg[Len(aAlerg)],'N/A')                                                                            
                    EndCase
                    Aadd(aAlerg[Len(aAlerg)],ZZH->&('ZZH_AORI'+cContador)) //Origem
                    Aadd(aAlerg[Len(aAlerg)],ZZH->&('ZZH_AOBS'+cContador)) //Observacoes     
                EndIf                                                           
            EndIf
            cContador := Soma1(cContador)
        EndDo

        OLE_SetDocumentVar(oWord, 'nTotOrgano' 		, Len(aOrgano))
        For n := 1 to Len(aOrgano)
            OLE_SetDocumentVar(oWord, 'cParam' 		+ AllTrim(Str(n)) +  '1'	, aOrgano[n][1])
            OLE_SetDocumentVar(oWord, 'cEspec' 		+ AllTrim(Str(n)) +  '2'	, aOrgano[n][2])
        Next
    

        
        OLE_ExecuteMacro(oWord, "Organolepticas")


        For n := 1 to Len(aFisico)
            OLE_SetDocumentVar(oWord, 'cParamFis' 		+ AllTrim(Str(n)) +  '1'	, aFisico[n][1])
            OLE_SetDocumentVar(oWord, 'cEspecFis' 		+ AllTrim(Str(n)) +  '2'	, aFisico[n][2])
        Next

        OLE_SetDocumentVar(oWord, 'nTotFisico' 		, Len(aFisico))
        OLE_ExecuteMacro(oWord, "FisicoQuimicas")

        For n := 1 to Len(aMicro)
            OLE_SetDocumentVar(oWord, 'cParamMicro' 		+ AllTrim(Str(n)) +  '1'	, aMicro[n][1])
            OLE_SetDocumentVar(oWord, 'cEspecMicro' 		+ AllTrim(Str(n)) +  '2'	, aMicro[n][2])
        Next

        OLE_SetDocumentVar(oWord, 'nTotMicro' 		, Len(aMicro))


        For n := 1 to Len(aAlerg)
            OLE_SetDocumentVar(oWord, 'cAlerg' 		    + AllTrim(Str(n)) 	, aAlerg[n][1])
            OLE_SetDocumentVar(oWord, 'cAlergTipo' 		+ AllTrim(Str(n)) 	, aAlerg[n][2])
            OLE_SetDocumentVar(oWord, 'cAlergOri' 		+ AllTrim(Str(n)) 	, aAlerg[n][3])
            OLE_SetDocumentVar(oWord, 'cAlergObs' 		+ AllTrim(Str(n)) 	, aAlerg[n][4])
        Next
        OLE_SetDocumentVar(oWord, 'nTotAlerge' 		, Len(aAlerg))
    

        
        OLE_ExecuteMacro(oWord, "Alergenicos")

        OLE_UpDateFields(oWord)

        OLE_SaveAsFile(oWord, cNewFile,,,, '17') //--Parametro '17' salva em pdf
        
        //ShellExecute("open", cNewFile, "", cPathDest , 1)    

        OLE_CloseFile(oWord)
        OLE_CloseLink(oWord)    

        //-- Exclui arquivo modelo na estacao:
        FErase(cArqTemp)    
    EndIf
EndIf    
Return cNewFile


/*/{Protheus.doc} zCmbDesc
Função que retorna a descrição da opção do Combo selecionada
@type function
@author Atilio
@since 28/08/2016
@version 1.0
	@param cChave, character, Chave de pesquisa dentro do combo
	@param cCampo, character, Campo do tipo combo
	@param cConteudo, character, Conteúdo no formato de combo
	@return cDescri, Descrição da opção do combo
	@example
	u_zCmbDesc("D", "C5_TIPO", "") //Utilizando por Campo
	u_zCmbDesc("S", "", "S=Sim;N=Não;A=Ambos;") //Utilizando por Conteúdo
/*/
User Function zCmbDesc(cChave, cCampo, cConteudo)
	Local aArea       := GetArea()
	Local aCombo      := {}
	Local nAtual      := 1
	Local cDescri     := ""
	Default cChave    := ""
	Default cCampo    := ""
	Default cConteudo := ""
	
	//Se o campo e o conteúdo estiverem em branco, ou a chave estiver em branco, não há descrição a retornar
	If (Empty(cCampo) .And. Empty(cConteudo)) .Or. Empty(cChave)
		cDescri := ""
	Else
		//Se tiver campo
		If !Empty(cCampo)
			aCombo := RetSX3Box(GetSX3Cache(cCampo, "X3_CBOX"),,,1)
			
			//Percorre as posiçÃµes do combo
			For nAtual := 1 To Len(aCombo)
				//Se for a mesma chave, seta a descrição
				If cChave == aCombo[nAtual][2]
					cDescri := aCombo[nAtual][3]
				EndIf
			Next
			
		//Se tiver conteúdo
		ElseIf !Empty(cConteudo)
			aCombo := StrTokArr(cConteudo, ';')
			
			//Percorre as posiçÃµes do combo
			For nAtual := 1 To Len(aCombo)
				//Se for a mesma chave, seta a descrição
				If cChave == SubStr(aCombo[nAtual], 1, At('=', aCombo[nAtual])-1)
					cDescri := SubStr(aCombo[nAtual], At('=', aCombo[nAtual])+1, Len(aCombo[nAtual]))
				EndIf
			Next
		EndIf
	EndIf
	
	RestArea(aArea)
Return cDescri

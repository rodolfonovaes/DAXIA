#INCLUDE "FINC010.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "SIGAWIN.CH"

#DEFINE QTDETITULOS	1
#DEFINE MOEDATIT	2
#DEFINE VALORTIT	3
#DEFINE VALORREAIS	4

Static lFc010Con
Static lFc010ConT
Static _oFINC0101
Static _oFINC0102
Static _oFINC0103
Static _oFINC0104
Static _oFINC0105
Static _oPergunte

Static __lExisFKD    := .F.
Static __cDateFormat := ""

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ FINC010  ³ Autor ³ Eduardo Riera         ³ Data ³ 30.12.1999 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Consulta a Posicao Financeira de Clientes                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Financiero                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR    ³ DATA   ³  BOPS  ³  MOTIVO DA ALTERACAO                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Norbert Waage  ³25/05/06³  ----  ³Alteracao na rotina ImpDet, para      ³±±
±±³                ³        ³        ³cortar o conteudo do campo E1_HIST de ³±±
±±³                ³        ³        ³acordo com o espaco reservado a este, ³±±
±±³                ³        ³        ³considerando o cabecalho do relatorio.³±±
±±³Marco A. Glez R.³27/02/17³MMI-4156³Se realiza replica para V12.1.14, que ³±±
±±³                ³        ³        ³corresponde al llamado de V11.8 TVBMJG³±±
±±³                ³        ³        ³Permite seleccion de sucursales y ajus³±±
±±³                ³        ³        ³te de campo filial en consulta. (ARG) ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Finc010(nPosArotina)

	Local cFilter	:= Nil

	__lExisFKD := TableInDic('FKD') .And. TableInDic('FKC')

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private cCadastro	:=	STR0005 	  // "Consulta Posi‡ao Clientes"
	Private aRotina 	:= MenuDef()  
	Private cFilCorr	:= cFilAnt			/* Gestao */

	DEFAULT nPosArotina := 0

	FC10INIVAR() 

	__cDateFormat   := UPPER(GetSrvProfString( 'DATEFORMAT', 'DEFAULT' ))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Habilita o Banco de Conhecimento ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aRotina,{STR0119,"MsDocument", 0 , 4}) //"Conhecimento"

	//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	// Variaveis utilizadas para parametros 				
	// MV_PAR01		  // Emissao De
	// MV_PAR02		  // Emissao Ate
	// MV_PAR03		  // Vencimento De 
	// MV_PAR04		  // Vencimento Ate
	// MV_PAR05		  // Considera Provisorios
	// MV_PAR06		  // Do Prefixo 
	// MV_PAR07		  // At‚ Prefixo
	// MV_PAR08       // Considera Faturados
	// MV_PAR09       // Considera Liquidados
	// MV_PAR10       // Pedidos c/Itens Bloq.
	// MV_PAR11       // Titulos Gerados por Liquidacao
	// MV_PAR12       // Considera Saldo ? Normal/Corrigido
	// MV_PAR13       // Considera Lojas ?		
	// MV_PAR14       // TES gera duplicata ?	
	// MV_PAR15       // Considera RA ?
	// MV_PAR16       // Exibe dias a vencer ?
	// MV_PAR17       // Seleciona Filiais ?
	// MV_PAR18       // Imprime data de vencimento ?
	//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

	//³ Ativa tecla F12 para acessar os parametros³
	SetKey(VK_F12, { || pergunte("FIC010",.T.) } )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Seleciona o Cadastro de Clientes. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SA1")
	dbSetOrder(1)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endereca a funcao de BROWSE ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("FC010BRW")
		ExecBlock("FC010BRW",.F.,.F.)
	EndIf 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Filtro inicial ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	#IFDEF TOP
	If ExistBlock("FC010FIL")
		cFilter := ExecBlock( "FC010FIL",.F.,.F.,{cFilter})
	EndIf                                                    
	#ENDIF

	If nPosArotina > 0 // Sera executada uma opcao diretamento de aRotina, sem passar pela mBrowse
		dbSelectArea("SA1")
		bBlock := &( "{ |a,b,c,d,e| " + aRotina[ nPosArotina,2 ] + "(a,b,c,d,e) }" )
		Eval( bBlock, Alias(), (Alias())->(Recno()),nPosArotina)
	Else 
		#IFDEF TOP 
		mBrowse( 6, 1,22,75,"SA1",,,,,,,,,,,,,,cFilter)
		#ELSE
		mBrowse( 6, 1,22,75,"SA1")
		#ENDIF
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Desativa tecla F12 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SetKey(VK_F12,Nil)

	_oPergunte := NIl

	Fc010Clr()
	
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Fc010Con  ³ Autor ³ Eduardo Riera         ³ Data ³31.12.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Consulta a Posicao de Clientes                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias                                              ³±±
±±³          ³ ExpN2 : Recno                                              ³±±
±±³          ³ ExpN3 : nOpc da MBrowse      l                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fc010Con(cAlias,nRecno,nOpcx)
	
	Local lPanelFin := IsPanelFin()
	Local aParam := {}
	Local lPergunte := .F.
		
	Private Inclui := .F.
	Private Altera := .F.
	
	If Type("cFilCorr") == "C"
		cFilCorr	:= If(cFilCorr = Nil , cFilAnt, cFilCorr)			/* Gestao */
	Else
		Private cFilCorr	:= cFilAnt			/* Gestao */
	EndIf
	
	If lPanelFin
		lPergunte := PergInPanel("FIC010",.T.)
	Else
		lPergunte := Pergunte("FIC010",FunName()=="FINC010")		
	EndIf

	If lPergunte .Or. FunName()<>"FINC010"

		aadd(aParam,MV_PAR01)
		aadd(aParam,MV_PAR02)
		aadd(aParam,MV_PAR03)
		aadd(aParam,MV_PAR04)
		aadd(aParam,MV_PAR05)
		aadd(aParam,MV_PAR06)
		aadd(aParam,MV_PAR07)
		aadd(aParam,MV_PAR08)
		aadd(aParam,MV_PAR09)
		aadd(aParam,MV_PAR10)
		aadd(aParam,MV_PAR11)
		aadd(aParam,MV_PAR12)
		aadd(aParam,MV_PAR13)
		aadd(aParam,MV_PAR14)
		aadd(aParam,MV_PAR15)
		aadd(aParam,MV_PAR16)
		aadd(aParam,MV_PAR17)
		
		If VerSenha(104) //Permite consulta a Posicao de Cliente
			Fc010Cli(aParam)
		Else
			Help(" ",1,"SEMPERM")
		EndIf
	EndIf
	
	If !FwIsInCallStack("FINC010") 
		Fc010Clr()
	EndIf

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³fc010Imp  ³ Autor ³Eduardo Riera          ³ Data ³04/01/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Funcao de Impressao ao dos Itens individuais da Posicao de  ³±±
±±³          ³Cliente.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³Fc010Imp()          										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1		: Recno do Arquivo principal                      ³±±
±±³          ³ExpN2		: nBrowse                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINC010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fc010Imp()

	Local aArea    := GetArea()
	Local cTitulo  := cCadastro
	Local cDesc1   := STR0048 //"Este programa ir  imprimir a Consulta de um Cliente,"
	Local cDesc2   := STR0049 //"informando os dados acumulados do Cliente, os Pedidos"
	Local cDesc3   := STR0050 //"em aberto, Titulos em Aberto e rela‡„o do Faturamento."
	Local cString  := "SA1"
	Local wnrel    := "FINC010"
	Local lSetCentury := __SetCentury()
	/*
	GESTAO - inicio */
	Private aSelFil	:= {}
	Private aTmpFil	:= {}
	/* GESTAO - fim
	*/
	Private Tamanho := "G"
	Private Limite  := 220
	Private cPerg   := "FIC010"
	Private aReturn := { STR0051,1,STR0051,1,2,1,"",1} //"Zebrado"###"Administracao"
	Private nLastKey:= 0
	Private m_pag   := 1
	Private lEnd    := .F.
	Private nCasas := GetMv("MV_CENT")

	SA1->(MsUnlockAll())

	If Pergunte(cPerg,.T.)
		wnrel := SetPrint(cString,wnrel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,,.F.,Tamanho,,.F.)
		__SetCentury("OFF")
		If ( nLastKey == 0 )
			SetDefault(aReturn,cString)
			If ( nLastKey == 0 )
				/*
				GESTAO - inicio */
				If FWModeAccess("SA1",3) == "C"
					If MV_PAR17 == 1
						If  FindFunction("AdmSelecFil")
							AdmSelecFil("FIC010",17,.F.,@aSelFil,"SA1",(FwModeAccess("SA1",1) == "E"),(FwModeAccess("SA1",2) == "E"),cFilCorr)
						Else
							aSelFil := AdmGetFil(.F.,.F.,"SA1")
						Endif
					Endif
					If Empty(aSelFil)
						Aadd(aSelFil,cFilCorr)
					Endif
				Else
					Aadd(aSelFil,cFilAnt)
				Endif
				/* GESTAO - fim 
				*/
				RptStatus({|lEnd| ImpDet(@lEnd,wnRel,cString,"FINC010",cTitulo)},cTitulo)
			EndIf
		EndIf
		dbSelectArea(cString)
		dbClearFilter()
		dbSetOrder(1)
		/*
		GESTAO - inicio */
		FC010QFil(2)
		/* GESTAO - fim 
		*/
		RestArea(aArea)
	EndIf

	If lSetCentury
		__SetCentury("ON")
	EndIf	

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Fc010Cli  ³ Autor ³ Eduardo Riera         ³ Data ³31.12.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Consulta a Posicao de Clientes                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 : [1] Data de Emissao Inicial                        ³±±
±±³          ³         [2] Data de Emissao Final                          ³±±
±±³          ³         [3] Vencimento Inicial                             ³±±
±±³          ³         [4] Vencimento Final                               ³±±
±±³          ³         [5] Considera Provisorios (1) Sim (2) Nao          ³±±
±±³          ³         [6] Prefixo Inicial                                ³±±
±±³          ³         [7] Prefixo Final                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³18/08/2000³Eduardo Motta  ³ Botao para consultar OSs em Aberto caso    ³±±
±±³          ³               ³ esteja instalado o VEICULOS                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fc010Cli(aParam)

	Local aArea 	:= GetArea()
	Local aAlias	:= {}
	Local oDlg
	Local cCadastro := STR0005 //"Consulta Posi‡ao Clientes"
	Local cCgc		:= RetTitle("A1_CGC")
	Local cMoeda    := ""
	Local nMcusto   := Iif(SA1->A1_MOEDALC > 0, SA1->A1_MOEDALC, Val(GetMv("MV_MCUSTO")))         
	Local aSavAhead := If(Type("aHeader")=="A",aHeader,{})
	Local aSavAcol  := If(Type("aCols")=="A",aCols,{})
	Local nSavN     := If(Type("N")=="N",n,0)
	Local nConLin   := 0
	Local aCols     :={}
	Local aHeader   :={}
	Local cSalFin	:=""
	Local cLcFin	:=""
	Local aGet      := {"","","",""}
	Local cTelefone := Alltrim(SA1->A1_DDI+" "+SA1->A1_DDD+" "+SA1->A1_TEL)
	Local lFc010Bol := ExistBlock( "FC010BOL" )	
	Local dPRICOM   := CRIAVAR("A1_PRICOM",.F.) 
	Local dULTCOM   := CRIAVAR("A1_ULTCOM",.F.) 
	Local dDTULCHQ  := CRIAVAR("A1_DTULCHQ",.F.)
	Local dDTULTIT  := CRIAVAR("A1_DTULTIT",.F.)
	Local lhabili   := .F.          
	Local cRISCO    := ""
	Local nLC       := 0
	Local nSALDUP   := 0
	Local nSALDUPM  := 0
	Local nLCFIN    := 0
	Local nMATR     := 0
	Local nSALFIN   := 0
	Local nSALFINM  := 0
	Local nMETR     := 0
	Local nMCOMPRA  := 0
	Local nMSALDO   := 0          
	Local nCHQDEVO  := 0
	Local nTITPROT  := 0
	Local lFC010LIST := ExistBlock("FC010LIST")
	Local nI		 := 1 
	Local oNomCli	 := Nil
	Local oNumTel	 := Nil
	Local oNumCGC	 := Nil

	SX3->(DbSetOrder(2))
	cLcFin	:=	If(SX3->(DbSeek("A1_LCFIN")) ,X3Titulo(),STR0076)
	cSalFin  := If(SX3->(DbSeek("A1_SALFIN")),X3Titulo(),STR0075)
	cMoeda  		:= " "+Pad(Getmv("MV_SIMB"+Alltrim(STR(nMCusto))),4)
	lFc010ConT      := If(lFc010ConT==Nil,ExistTemplate("FC010CON"),lFc010ConT)
	lFc010Con       := If(lFc010Con==Nil,ExistBlock("FC010CON"),lFc010Con) 
	Private nCasas := GetMv("MV_CENT")
	/*
	GESTAO - inicio */
	Private aSelFil	:= {}
	Private aTmpFil	:= {}
	
	If lFc010Bol
		Private aVetAlias := {}
	EndIf

	If FWModeAccess("SA1",3) == "C"
		If MV_PAR17 == 1
			If  FindFunction("AdmSelecFil")
				AdmSelecFil("FIC010",17,.F.,@aSelFil,"SA1",(FwModeAccess("SA1",1) == "E"),(FwModeAccess("SA1",2) == "E"),cFilCorr)
			Else
				aSelFil := AdmGetFil(.F.,.F.,"SA1")
			Endif
		Endif
		If Empty(aSelFil)
			Aadd(aSelFil,cFilCorr)
		Endif
	Else
		Aadd(aSelFil,cFilAnt)
	Endif		
	/* GESTAO - fim
	*/

	If aParam[13] == 1
		nLC      := SA1->A1_LC
		dPRICOM  := SA1->A1_PRICOM
		nSALDUP  := SA1->A1_SALDUP
		nSALDUPM := SA1->A1_SALDUPM
		dULTCOM  := SA1->A1_ULTCOM       
		nLCFIN   := SA1->A1_LCFIN       
		nMATR    := SA1->A1_MATR                 
		nSALFIN  := SA1->A1_SALFIN  
		nSALFINM := SA1->A1_SALFINM              
		nMETR    := SA1->A1_METR 
		nMCOMPRA := SA1->A1_MCOMPRA        
		cRISCO   := SA1->A1_RISCO
		nMSALDO  := SA1->A1_MSALDO
		nCHQDEVO := SA1->A1_CHQDEVO
		dDTULCHQ := SA1->A1_DTULCHQ
		nTITPROT := SA1->A1_TITPROT
		dDTULTIT := SA1->A1_DTULTIT
	Else
		Fc010Loja(@nLC,@dPRICOM,@nSALDUP,@nSALDUPM,@dULTCOM,@nLCFIN,@nMATR,@nSALFIN,@nSALFINM,@nMETR,@nMCOMPRA,@cRISCO,@nMSALDO,@nCHQDEVO,@dDTULCHQ,@nTITPROT,@dDTULTIT)
	Endif

	aHeader	:= {STR0077,STR0078,STR0069+AllTrim(cMoeda)," ",STR0077,STR0005}  
	//LIMITE DE CREDITO # PRIMEIRA COMPRA
	Aadd(aCols,{STR0014,TRansform(Round(Noround(xMoeda(nLC, nMcusto, 1,dDataBase,MsDecimais(1)+1),2),MsDecimais(1)),PesqPict("SA1","A1_LC",14,1)),;
	TRansform(nLC,PesqPict("SA1","A1_LC",14,nMCusto)),;
	" ",STR0015,SPACE(07)+DtoC(dPRICOM)}) // LIMITE DE CREDITO # Primeira Compra 
	//SALDO # ULTIMA COMPRA
	Aadd(aCols,{STR0010,TRansform(nSALDUP,PesqPict("SA1","A1_SALDUP",14,1) ),;
	TRansform(nSALDUPM,PesqPict("SA1","A1_SALDUPM",14,nMcusto)),;
	" ",STR0016,SPACE(07)+DtoC(dULTCOM)}) // Valor Parcelas / Saldo  / Ultima Parcela / Ultima Compra
	//Limite de credito secundario # MAIOR ATRASO
	Aadd(aCols,{cLcFin,TRansform(Round(Noround(xMoeda(nLCFIN,nMcusto,1,dDatabase,MsDecimais(1)+1),2),MsDecimais(1)),PesqPict("SA1","A1_LCFIN",14,1)),;     
	TRansform(nLCFIN,PesqPict("SA1","A1_LCFIN",14,nMcusto)),;
	" ",STR0017,Transform(nMATR,PesqPict("SA1","A1_MATR",14))}) // Limite sec / Maior Atraso    
	//SAldo do limite de credito secundario $ media de Atraso
	Aadd(aCols,{cSalFin,TRansform(nSALFIN,PesqPict("SA1","A1_SALFIN",14,1)),;
	TRansform(nSALFINM,PesqPict("SA1","A1_SALFINM",14,nMcusto)),;
	" ",STR0018,PADC(STR(nMETR,7,2),22)}) // Saldo em Cheque / Media de Atraso
	//Maior Compra # Grau de risco
	Aadd(aCols,{STR0011,;
	TRansform(Round(Noround(xMoeda(nMCOMPRA, nMcusto ,1, dDataBase,MsDecimais(1)+1),2),MsDecimais(1)),PesqPict("SA1","A1_MCOMPRA",14,1) ) ,;
	TRansform(nMCOMPRA,PesqPict("SA1","A1_MCOMPRA",14,nMcusto)),;
	" ",STR0019,SPACE(25)+cRISCO}) // Maior Compra / Grau de Risco
	//MAior Saldo
	Aadd(aCols,{STR0012,;
	TRansform(Round(Noround(xMoeda(nMSALDO, nMcusto ,1, dDataBase,MsDecimais(1)+1 ),2),MsDecimais(1)),PesqPict("SA1","A1_MSALDO",14,1)),;
	TRansform(nMSALDO,PesqPict("SA1","A1_MSALDO",14,nMcusto)),;
	" "," ",""}) //Maior saldo


	IF lFC010LIST
		aCols := ExecBlock ("FC010LIST",.F.,.F.,aCols)
	EndIF

	DEFINE MSDIALOG oDlg FROM	09,0 TO 30,85 TITLE cCadastro OF oMainWnd

	@ 001,002 TO 043, 267 OF oDlg	PIXEL
	@ 130,002 TO 154, 114 OF oDlg	PIXEL
	@ 130,121 TO 154, 267 OF oDlg	PIXEL

	@ 004,005 SAY STR0006 SIZE 025,07          OF oDlg PIXEL //"Codigo"
	@ 012,004 MSGET SA1->A1_COD      SIZE 070,09 WHEN .F. OF oDlg PIXEL

	If aParam[13] == 1  //Considera loja		
		@ 004,077 SAY STR0007 SIZE 020,07          OF oDlg PIXEL //"Loja"
		@ 012,077 MSGET SA1->A1_LOJA     SIZE 021,09 WHEN .F. OF oDlg PIXEL
	Endif


@ 004,100 SAY STR0008 						SIZE 025,07 OF oDlg PIXEL //"Nome"
	@ 012,100 MSGET oNomCli VAR SA1->A1_NOME	SIZE 150,09 OF oDlg PIXEL When .F. OFUSCATED RetGlbLGPD('A1_NOME')

	@ 023,005 SAY cCGC    SIZE 025,07 OF oDlg PIXEL
	If cPaisLoc=="BRA"
		@ 030,004 MSGET oNumCGC Var SA1->A1_CGC	SIZE 070,09 PICTURE StrTran(PicPes(SA1->A1_PESSOA),"%C","") OF oDlg PIXEL When .F. OFUSCATED RetGlbLGPD('A1_CGC')
	Else
		@ 030,004 MSGET SA1->A1_CGC      SIZE 070,09 PICTURE PesqPict("SA1","A1_CGC") WHEN .F. OF oDlg PIXEL
	EndIf
	
	@ 023,077 SAY STR0009 					SIZE 025,07 OF oDlg PIXEL //"Telefone"
	@ 030,077 MSGET oNumTel Var cTelefone	SIZE 060,09 OF oDlg PIXEL When .F. OFUSCATED RetGlbLGPD('A1_TEL')

	@ 023,141 SAY RetTitle("A1_VENCLC")  SIZE 035,07 OF oDlg PIXEL
	@ 030,141 MSGET SA1->A1_VENCLC       SIZE 060,09 WHEN .F. OF oDlg PIXEL
	
	@ 023,206 SAY STR0057 SIZE 035,07 OF oDlg PIXEL //"Vendedor"
	@ 030,206 MSGET SA1->A1_VEND  	 SIZE 053,09 WHEN .F. OF oDlg PIXEL

	oLbx := RDListBox(3.5, .42, 264, 70, aCols, aHeader,{38,51,51,11,50,63})   

	@ 124,002 SAY STR0020 SIZE 061,07 OF oDlg PIXEL //"Cheques Devolvidos"
	@ 124,121 SAY STR0021 SIZE 061,07 OF oDlg PIXEL //"Titulos Protestados"

	@ 133,005 SAY STR0022 SIZE 034,07 OF oDlg PIXEL //"Quantidade"
	@ 133,045 SAY STR0023 SIZE 066,07 OF oDlg PIXEL //"Ultimo Devolvido"
	@ 133,126 SAY STR0022 SIZE 034,07 OF oDlg PIXEL //"Quantidade"
	@ 133,163 SAY STR0024 SIZE 076,07 OF oDlg PIXEL //"Ultimo Protesto"

	@ 141,006 MSGET nCHQDEVO SIZE 024,08 WHEN .F. OF oDlg PIXEL
	@ 141,045 MSGET dDTULCHQ SIZE 050,08 WHEN .F. OF oDlg PIXEL
	@ 141,126 MSGET nTITPROT SIZE 024,08 WHEN .F. OF oDlg PIXEL
	@ 141,163 MSGET dDTULTIT SIZE 050,08 WHEN .F. OF oDlg PIXEL
	
	@ 001,272 BUTTON STR0025 SIZE 60,12 FONT oDlg:oFont ACTION If( lFc010Bol, ExecBlock( "FC010BOL", .F., .F., {1,aVetAlias,aParam,.T.,aGet} ), Fc010Brow(1,@aAlias,aParam,.T.,aGet))  OF oDlg PIXEL //"Boleto Aberto" / "Tit Aberto"
	@ 015,272 BUTTON STR0122 SIZE 60,12 FONT oDlg:oFont ACTION If( lFc010Bol, ExecBlock( "FC010BOL", .F., .F., {2,aVetAlias,aParam,.T.,aGet} ), FC010Brow(2,@aAlias,aParam,.T.,aGet))  OF oDlg PIXEL //"Boleto Pago" / "Tit Recebidos"

	@ 029,272 BUTTON STR0027 SIZE 60,12 FONT oDlg:oFont ACTION Fc010Brow(3,@aAlias,aParam,.T.,aGet)	OF oDlg PIXEL //"Pedidos"
	@ 043,272 BUTTON STR0028 SIZE 60,12 FONT oDlg:oFont ACTION Fc010Brow(4,@aAlias,aParam,.T.,aGet)	OF oDlg PIXEL //"Faturamento"
	nConLin+=14	

	If ( cPaisLoc<>"BRA" )
		@ 043+nConLin,272 BUTTON STR0029 SIZE 60,12 FONT oDlg:oFont ACTION Fc010Brow(5,@aAlias,aParam,.T.,aGet)	OF oDlg PIXEL //"Cheques/Trans"
		nConLin+=14
	EndIf
	If ( lFC010ConT )
		@ 043+nConLin,272 BUTTON STR0030 SIZE 60,12 FONT oDlg:oFont ACTION ExecTemplate("FC010CON",.F.,.F.) OF oDlg  PIXEL //"Cons.Especif."
		nConLin+=14
	EndIf
	If ( lFC010Con )
		@ 043+nConLin,272 BUTTON STR0030 SIZE 60,12 FONT oDlg:oFont ACTION ExecBlock("FC010CON",.F.,.F.) OF oDlg  PIXEL //"Cons.Especif."
		nConLin+=14
	EndIf
	If Trim(GetMV("MV_VEICULO")) == "S"
		@ 043+nConLin,272 BUTTON STR0058 SIZE 60,12 FONT oDlg:oFont ACTION FG_SALOSV(SA1->A1_COD,SA1->A1_LOJA,," ","T") OF oDlg PIXEL  //"OSs em Aberto"
		nConLin+=14
	EndIf   
	If aParam[13] == 1  //Considera loja
		lhabili := .T.
	Endif
	@ 043+nConLin,272 BUTTON STR0059 SIZE 60,12 FONT oDlg:oFont ACTION Mata030Ref("SA1",SA1->(Recno()),2) WHEN lhabili OF oDlg PIXEL //"Referencias"
	nConLin+=14

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³O modulo de call center não esta disponivel em Pyme, portanto nao exibe o botao do historico de cobranca³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !__lPyme 
		@ 043+nConLin,272 BUTTON STR0095 SIZE 60,12 FONT oDlg:oFont ACTION TmkC020() WHEN lhabili OF oDlg PIXEL //Historico de Cobranca
		nConLin += 14
	Endif	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de entrada para inclusão de um botão customizado na tela ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("FC010BTN")	
		If !__lPyme
			nConLin += 14 
			@ 043+nConLin,272 BUTTON ExecBlock("FC010BTN",.F.,.F.,{1}) SIZE 60,12 FONT oDlg:oFont ACTION ExecBlock("FC010BTN",.F.,.F.,{3}) MESSAGE ExecBlock("FC010BTN",.F.,.F.,{2})  OF oDlg PIXEL // "Botao habilitado pelo cliente mediante ponto de entrada" 
		Endif		
	EndIf 

	@ 143,272 BUTTON STR0031 SIZE 60,12 FONT oDlg:oFont ACTION oDlg:End() 	OF oDlg PIXEL //"Sair"
	ACTIVATE MSDIALOG oDlg CENTERED
	
	If lFc010Bol //areas a serem fechadas
		If Len(aAlias) == 0
			aAlias := AClone(aVetAlias)
		Else
			For nI := 1 to Len(aVetAlias)
				aadd(aAlias, {aVetAlias[nI, 1], aVetAlias[nI,2]})
			Next nI
		EndIf
	EndIf


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Restaura a Integridade dos Dados  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHeader := aSavAHead
	aCols   := aSavaCol
	N       := nSavN

	Fc010Clr() //Fecha alias e deleta as tabelas temporárias que foram criadas no banco de dados
		
	dbSelectArea("SA1")
	/*
	GESTAO - inicio */
	FC010QFil(2)
	/* GESTAO - fim 
	*/	
	RestArea(aArea)

	FwFreeObj(_oPergunte)
	
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Fc010Brow ³ Autor ³ Eduardo Riera         ³ Data ³31.12.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Consulta a Posicao de Clientes                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 : nOpcao                                             ³±±
±±³          ³         [1] Titulos em Aberto                              ³±±
±±³          ³         [2] Titulos Recebidos                              ³±±
±±³          ³         [3] Pedidos                                        ³±±
±±³          ³         [4] Faturamento                                    ³±±
±±³          ³ ExpA2 : Alias a Serem Fechados.                            ³±±
±±³          ³ ExpA3 : [1] Data de Emissao Inicial                        ³±±
±±³          ³         [2] Data de Emissao Final                          ³±±
±±³          ³         [3] Vencimento Inicial                             ³±±
±±³          ³         [4] Vencimento Final                               ³±±
±±³          ³         [5] Considera Provisorios (1) Sim (2) Nao          ³±±
±±³          ³         [6] Prefixo Inicial                                ³±±
±±³          ³         [7] Prefixo Final                                  ³±±
±±³          ³ ExpL4 : Indica se os dados devem ser exibidos              ³±±
±±³          ³ ExpL5 : Indica se os dados serao montados para o relatorio ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fc010Brow(nBrowse,aAlias,aParam,lExibe,aGet,lRelat)

	Local aArea		:= GetArea()
	Local aAreaSC5	:= SC5->(GetArea())
	Local aAreaSC6	:= SC6->(GetArea())
	Local aAreaSC9	:= SC9->(GetArea())
	Local aAreaSF4	:= SF4->(GetArea())
	Local aStru		:= {}
	Local aQuery	:= {}
	Local aSay		:= {"","","","","","","",""}
	Local oGetDb
	Local oScrPanel
	Local oBold
	Local oDlg
	Local oBtn
	Local bVisual
	Local bWhile
	Local bFiltro
	Local cAlias	:= ""
	Local cArquivo	:= ""
	Local cCadastro	:= ""
	Local cQuery	:= ""
	Local cDbMs
	Local cQry		:= ""
	Local cChave	:= ""
	Local lQuery	:= .F.
	Local nCntFor	:= 0
	Local nSalped	:= 0
	Local nSalpedl	:= 0
	Local nSalpedb	:= 0
	Local nQtdPed	:= 0
	Local nTotAbat	:= 0
	Local cAnterior	:= ""
	Local nTaxaM	:= 0	
	Local nMoeda
	Local oTipo
	Local nTipo		:= 1
	Local bTipo
	Local oCheq
	Local aTotRec	:= {{0,1,0,0}} // Totalizador de titulos a receber por por moeda
	Local aTotPag	:= {{0,1,0,0}} // Totalizador de titulos recebidos por por moeda
	Local nAscan
	Local nTotalRec	:=0
	Local aSize		:= MsAdvSize( .F. )
	Local aPosObj1	:= {}                 
	Local aObjects	:= {}                       
	Local aCpos		:= {}
	Local aCpoVlr	:= {}
	Local cCheques	:=	IIF(Type('MVCHEQUES')=='C',MVCHEQUES,MVCHEQUE)
	Local nI := 0
	Local bCond
	Local cOrdem	:= ""
	Local cNumAnt	:= ""
	Local cTpDocAnt	:= ""
	Local cParcAnt	:= ""
	Local lFC010Head := ExistBlock("FC010HEAD")
	Local cSaldo := ""
	Local lFC010Pedi := ExistBlock("FC010Pedi")
	Local aRetAux	:= {}
	Local lFC0101FAT	:= ExistBlock("FC0101FAT")
	Local lFC0102FAT	:= ExistBlock("FC0102FAT")
	Local lFC0103FAT	:= ExistBlock("FC0103FAT")
	Local aAuxCpo		:= {}
	Local aHeader1		:= {}
	Local nA			:= 0
	Local nMulta		:= 0                            //Valor da Multa
	Local nJuros		:= 0
	Local cMvJurTipo 	:= SuperGetMv("MV_JURTIPO",,"") //Tipo de Calculo de Juros do Financeiro	
	Local lLojxRMul  	:= .T.        //Funcao que calcula a Multa do Financeiro
	Local lMvLjIntFS	:= SuperGetMv("MV_LJINTFS", ,.F.) //Habilita Integração com o Financial Services
	Local lFC010bxhe	:= ExistBlock("FC010bxhe")//Ponto de entrada para incluir campo no Head dos Tit. Baixados
	Local nTamFil		:= 0
	Local lFilF4		:= .F.
	Local lFilF4C6		:= .F.
	Local cChaveFK7		:= ""
	Local cChaveTit		:= ""	
	Local lValAcess   	:= ExistFunc("FValAcess")
	Local cCmpFilE1		:= ""
	Local cCompSE1		:= ""
	Local cCmpFilE5		:= ""
	Local cCompSE5		:= ""
	Local cSepNeg   	:= If("|"$MV_CPNEG,"|",",")
	Local cSepPag   	:= If("|"$MVPAGANT,"|",",")
	Local cTmpFil		:= ""
	Local lNoChqTran	:= .T.		//Controla processo se não for somente cheque transitorio
	Local cBkpFil		:= ""
	Local cTmpFK7		:= ""
	Local nTamFK7C		:= TamSX3('FK7_CHAVE')[1]
	Local nChvSE1		:= TamSX3('E1_FILORIG')[1] + 1 + TamSX3('E1_PREFIXO')[1] + 1 + TamSX3('E1_NUM')[1] + 1 + TamSX3('E1_PARCELA')[1] + 1 + TamSX3('E1_TIPO')[1] + 1 + TamSX3('E1_CLIENTE')[1] + 1 + TamSX3('E1_LOJA')[1]
	Local cMVCRNEG  	:= SuperGetMv("MV_CRNEG",.F.,MVRECANT+"/"+MV_CRNEG)  /*23/11/2018 Diogo Melo*
											Valiavel criada para atender base Agentina trazendo valores negativos de acordo com o conteudo do paramentro
										   */
	/*
	GESTAO - inicio */
	Local nPosAlias	:= 0
	Local cCompSC5	:= ""
	/* GESTAO - fim
	*/
	Local aStrTmp	:= {}
	Local lF010CQTA	:= ExistBlock("F010CQTA")
	Local nPos		:= 0
	Local lFilial	:= .F.
	Local lFilOri	:= .F.
	Local cFilCQTA	:= ""
	Local lF010DATR	:= ExistBlock("F010DATR")
	Local cPicture 	:= "@E 9,999.99"
	Local aDtTit 	:= {} 
	Local nSaldo    := 0
	Local nSaldoTit := 0
	Local nDescFin  := 0
	Local aAreaSE1  := {}
	Local nRecAtu	:= 0
	Local lAntCred  := SuperGetMv("MV_ANTCRED", .F., .F.)

	Private aHeader	:= {}
	Private cFilCorr	:= cFilAnt
	DEFAULT lRelat	:= .F.

	FC10INIVAR()

	If MV_PAR17 == 1 .AND. Len(aSelFil) <= 0 .AND. FWModeAccess("SA1",3) == "C"	// Chamar a tela de seleção de filiais caso não tenha sido chamada anteriormente. Quando chamado o botão diretamente.
		If  FindFunction("AdmSelecFil")
			AdmSelecFil("FIC010",17,.F.,@aSelFil,"SE1",(FwModeAccess("SE1",1) == "E"),(FwModeAccess("SE1",2) == "E"),cFilCorr)
		Else
			aSelFil := AdmGetFil(.F.,.F.,"SE1")
		Endif
	Endif
	If Empty(aSelFil)
		Aadd(aSelFil,cFilCorr)
	Endif

	aGet := {"","","","","","","",""}

	Do Case
		Case ( nBrowse == 1 )	
			cCadastro := STR0025
			cAlias    := "FC010QRY01"
			aSay[1]   := STR0032 //"Qtd.Tit."
			aSay[2]   := STR0033 //"Principal"
			aSay[3]   := STR0120 //"Saldo a Receber"
			aSay[4]   := STR0046 //"Juros"
			aSay[5]   := STR0091 //"Acresc."
			aSay[6]   := STR0092 //"Decresc."
			aSay[7]   := STR0086 //"Abatimentos"
			aSay[8]   := STR0104 //"Tot.Geral"	
			bVisual   := {|| Fc010Visua((cAlias)->XX_RECNO,nBrowse) }
		Case ( nBrowse == 2 )
			cCadastro := STR0122
			cAlias    := "FC010QRY02"
			aSay[1]   := STR0036 //"Qtd.Pag."
			aSay[2]   := STR0037 //"Principal"
			aSay[3]   := STR0038 //"Vlr.Pagto"
			aSay[4]   := STR0114 //"Crédito"
			aSay[5]   := STR0141 //"Compensado"
			bVisual   := {|| Fc010Visua((cAlias)->XX_RECNO,nBrowse) }
		Case ( nBrowse == 3 )
			cCadastro := STR0027
			cAlias    := "FC010QRY03"
			aSay[1]   := STR0039 //"Qtd.Ped."
			aSay[2]   := STR0040 //"Tot.Pedido"
			aSay[3]   := STR0041 //"Tot.Liber."
			aSay[4]   := STR0042 //"Sld.Pedido"
			bVisual   := {|| Fc010Visua((cAlias)->XX_RECNO,nBrowse) }
		Case ( nBrowse == 4 )
			cCadastro := STR0028
			cAlias    := "FC010QRY04"
			aSay[1]   := STR0043 //"Qtd.Notas"
			aSay[2]   := STR0044 //"Tot.Fatur."
			bVisual   := {|| Fc010Visua((cAlias)->XX_RECNO,nBrowse) }
		Case ( nBrowse == 5 )
			cCadastro := STR0061 //"Cartera de cheques"
			cAlias    := "FC010QRY05"
			aSay[1]   := STR0062 //"Pendiente"
			If cPaisLoc$"URU|BOL"
				aSay[2]   := STR0088 //"Rechazado"
			Else
				aSay[2]   := STR0063 //"Negociado"
			Endif   
			aSay[3]   := STR0064 //"Cobrado"
			If cPaisLoc$"ARG|COS"
				aSay[4]   := STR0134 //"Em Transito"
			Endif
			bVisual   := {|| Fc010Visua((cAlias)->XX_RECNO,If( (cAlias)->XX_ESTADO == "TRAN",5,1) ) }
	EndCase

	Do Case
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Titulo em Aberto  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Case ( nBrowse == 1 ) 
		If !lRelat .And. (cPaisLoc == "BRA" .Or. cPaisLoc == "MEX"  .Or. cPaisLoc == "ARG" )
			Aadd(aHeader,{"",	"XX_LEGEND","@BMP",10,0,"","","C","",""})
			Aadd(aStru,{"XX_LEGEND","C",12,0})
		Endif	
		dbSelectArea("SX3")
		dbSetOrder(2)

		dbSeek("E1_LOJA")
		If aParam[13] == 2  //Considera loja		
			aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		Endif
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		/* 
		GESTAO - inicio */
		dbSeek("E1_FILORIG")
		If !lRelat
			nTamFil := Len(SM0->(AllTrim(M0_CODFIL) + " - " + M0_NOME))
		else
			nTamFil := Len(SM0->(AllTrim(M0_CODFIL)))
		Endif
		aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,nTamFil,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,nTamFil,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,nTamFil,SX3->X3_DECIMAL})
		/* GESTAO - fim
		*/
		dbSeek("E1_PREFIXO")
		aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		dbSeek("E1_NUM")
		aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		dbSeek("E1_PARCELA")
		aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		dbSeek("E1_TIPO")
		aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		
		If !lRelat .and. cPaisLoc == 'BRA'
			dbSeek("E1_NFELETR")
			aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
			aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		Endif		

		dbSeek("E1_CLIENTE")
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		dbSeek("E1_EMISSAO")
		aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		If lRelat 
			dbSeek("E1_VENCTO")
			If MV_PAR18 == 1
				aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
			Endif
			aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

			dbSeek("E1_VENCREA")
			If MV_PAR18 == 2		
				aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
			Endif
			aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		Else		
			dbSeek("E1_VENCTO")
			aadd(aHeader,{AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
			aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})	

			dbSeek("E1_VENCREA")
			aadd(aHeader,{AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
			aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		Endif		
		
		dbSeek("E1_BAIXA")
		aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				
		If !lRelat
			dbSeek("E1_MOEDA")
			aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )

			dbSeek("E1_VALOR")
			aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
			aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		Endif	

		dbSeek("E1_VLCRUZ")
		aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		aadd(aHeader,{STR0086,"E1_ABT",cPicture,10,2,"","","N","","V" } ) //"Abatimentos"
		aadd(aStru ,{"E1_ABT","N",10,2})

		dbSeek("E1_SDACRES")
		aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		dbSeek("E1_SDDECRE")
		aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		dbSeek("E1_VALJUR")
		aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ 11/Ago/2005 Rafael E. Rodrigues                             ³
		//³ Quando o modulo Gestao Educacional estiver em uso, inclui a ³
		//³ coluna com a provisao de multa de titulos em atraso.        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


		//Calculo de Juros e Multas: SIGALOJA x SIGAFIN  - Inicio
		/*BEGINDOC
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Calculo de juros e multas, segundo o controle de loja³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ENDDOC*/
		If (cMVJurTipo == "L" .OR. lMvLjIntFS).AND. lLojxRMul
			dbSeek("E1_MULTA")		
			aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,cPicture,8,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
			aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,8,SX3->X3_DECIMAL})
			aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,8,SX3->X3_DECIMAL})
		EndIf  

		//Calculo de Juros e Multas: SIGALOJA x SIGAFIN  - Inicio	
		/*BEGINDOC
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Calculo de juros e multas, segundo o controle de loja³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ENDDOC*/
		If (cMVJurTipo == "L" .OR. lMvLjIntFs) .and. lLojxRMul
			dbSeek("E1_ACRES")		
			aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

			dbSeek("E1_JUROS")		
			aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		EndIf 
		//Calculo de Juros e Multas: SIGALOJA x SIGAFIN - Final
		
		//Valores Acessorios
		If __lExisFKD
			If dbSeek("FKD_VALOR")
				aadd(aHeader,{ AllTrim(STR0139),SX3->X3_CAMPO,cPicture,8,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )//"Valores Acessorios"
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,8,SX3->X3_DECIMAL})
			Endif
		Endif

		dbSeek("E1_SALDO")
		aadd(aHeader,{STR0120,SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )	//"Saldo a Receber"
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		aadd(aHeader,{ STR0103,"E1_SALDO2",SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } ) // "Saldo na moeda tit"
		aadd(aStru ,{"E1_SALDO2",SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		If !lRelat
			dbSeek("E1_NATUREZ")
			aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
			aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		Endif
		
		dbSeek("E1_PORTADO")
		aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})		

		dbSeek("E1_NUMBCO")
		aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,TamSX3('E1_NUMBCO')[1],SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,TamSX3('E1_NUMBCO')[1],SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,TamSX3('E1_NUMBCO')[1],SX3->X3_DECIMAL})

		If !lRelat
			dbSeek("E1_NUMLIQ")
			aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
			aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		Endif

		dbSeek("E1_HIST")
		aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		aadd(aHeader,{STR0035,"E1_ATR","9999999999",10,0,"","","N","","V" } ) //"Atraso"
		aadd(aStru ,{"E1_ATR","N",10,0})

		If !lRelat
			dbSeek("E1_CHQDEV")
			aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		EndIf
		//sitcob
		dbSeek("E1_SITUACA")
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		If cPaisLoc == "BRA"
			Aadd(aStru,{"ZZ_STATUS","C",40,0})
		EndIf
		Aadd(aStru,{"FRV_DESCRI","C",40,0})
		aadd(aStru,{"XX_RECNO","N",12,0})
		aadd(aStru,{"E1_MOEDA","N",02,0})

		aadd(aQuery,{"E1_PORCJUR","N",12,4})
		aadd(aQuery,{"E1_MOEDA","N",02,0})
		aadd(aQuery,{"E1_VALOR","N",16,2})

		If cPaisLoc == "BRA"
			aadd(aQuery,{"E1_TXMOEDA","N",17,4})
		EndIf	

		If !lRelat .and. cPaisLoc == "BRA"
			Aadd(aHeader,{STR0137,"ZZ_STATUS","@!",40,0,"","","C","","V" } ) //"Status Serasa"
			//sitcob
			Aadd(aHeader,{STR0045,"FRV_DESCRI","@!",40,0,"","","C","FRV","" } ) //"Situacao"
		EndIf

		IF lFC010Head
			aHeader1 :=	aHeader			
			aHeader1 := ExecBlock("FC010HEAD",.F.,.F.,aHeader1)

			For nA := 1 to Len(aHeader1)
				// Verificação se os campos adicionados no PE já estão no cabeçalho(aHeader)
				If Ascan(aHeader,{ |e| Alltrim(e[2]) == Alltrim(aHeader1[nA,2]) }) = 0	
					aadd(aHeader,{;
						aHeader1[nA,1],aHeader1[nA,2],aHeader1[nA,3],aHeader1[nA,4], ;
						aHeader1[nA,5],aHeader1[nA,6],aHeader1[nA,7],aHeader1[nA,8]  ;
					})																		
				Endif									
			Next

			For nA := 1 to Len(aHeader)
				// Verificação se os campos do aHeader já estão na estrutura(aStru)
				If Ascan(aStru,{|e| Alltrim(e[1]) == Alltrim(aHeader[nA,2])}) = 0				   
					aadd(aStru ,{aHeader[nA,2],aHeader[nA,8],aHeader[nA,4],aHeader[nA,5]})
					aadd(aQuery,{aHeader[nA,2],aHeader[nA,8],aHeader[nA,4],aHeader[nA,5]})														
				Endif									
			Next			

		EndIf

		SX3->(dbSetOrder(1))

		If ( Select(cAlias) ==	0 )
			cArquivo := CriaTrab(,.F.)			
			aadd(aAlias,{ cAlias , cArquivo })
			aadd(aStru,{"FLAG","L",01,0})

			If _oFINC0101 <> Nil
				_oFINC0101:Delete()
				_oFINC0101 := Nil
			Endif

			_oFINC0101 := FWTemporaryTable():New( cAlias )  
			_oFINC0101:SetFields(aStru) 
			_oFINC0101:AddIndex("1", {"E1_FILORIG","E1_CLIENTE","E1_LOJA","E1_PREFIXO","E1_NUM","E1_PARCELA","E1_TIPO"})

			//------------------
			//Criação da tabela temporaria
			//------------------
			_oFINC0101:Create()  

			#IFDEF TOP
			If ( TcSrvType()!="AS/400" )
				lQuery := .T.
				cQuery := ""
				aEval(aQuery,{|x| cQuery += ","+AllTrim(x[1])})
				cQuery := "SELECT "+SubStr(cQuery,2)
				cQuery +=         ",SE1.R_E_C_N_O_ SE1RECNO"
				cQuery +=         ",FRV.FRV_DESCRI "
				cQuery +=		  ",SE1.E1_FILIAL "
				cQuery += "FROM "+RetSqlName("SE1")+" SE1,"
				cQuery +=         RetSqlName("FRV")+" FRV "
				cQuery += "WHERE "
				/*
				GESTAO - inicio */
				nPosAlias := FC010QFil(1,"SE1")
				cQuery += "SE1.E1_FILIAL " + aTmpFil[nPosAlias,2] + " AND "
				/* GESTAO - fim
				*/
				cQuery +=       "SE1.E1_CLIENTE='"+SA1->A1_COD+"' AND "
				If aParam[13] == 1  //Considera loja
					cQuery +=       "SE1.E1_LOJA='"+SA1->A1_LOJA+"' AND "
				Endif
				cQuery +=       "SE1.E1_EMISSAO>='"+Dtos(aParam[1])+"' AND "
				cQuery +=       "SE1.E1_EMISSAO<='"+Dtos(aParam[2])+"' AND "
				cQuery +=       "SE1.E1_VENCREA>='"+Dtos(aParam[3])+"' AND "
				cQuery +=       "SE1.E1_VENCREA<='"+Dtos(aParam[4])+"' AND "
				If ( aParam[5] == 2 )
					cQuery +=   "SE1.E1_TIPO<>'PR ' AND "
				EndIf					
				If ( aParam[15] == 2 )
					cQuery +=   "SE1.E1_TIPO<>'RA ' AND "	
				Endif
				cQuery += "SE1.E1_PREFIXO>='"+aParam[6]+"' AND "
				cQuery += "SE1.E1_PREFIXO<='"+aParam[7]+"' AND " 
				If cPaisLoc != "BRA"
					cQuery += "SE1.E1_TIPO NOT IN" + FormatIn(cCheques,"|") + " AND "
				Endif	
				cQuery += "SE1.E1_SALDO > 0 AND "

				If aParam[11] == 2 // Se nao considera titulos gerados pela liquidacao
					If aParam[09] == 1 
						cQuery += "SE1.E1_NUMLIQ ='"+Space(Len(SE1->E1_NUMLIQ))+"' AND "
					Else  
						cQuery += "SE1.E1_TIPOLIQ='"+Space(Len(SE1->E1_TIPOLIQ))+"' AND "						
						cQuery += "SE1.E1_NUMLIQ ='"+Space(Len(SE1->E1_NUMLIQ))+"' AND "
					Endif	
				Else
					If aParam[09] == 2
						cQuery += "SE1.E1_TIPOLIQ='"+Space(Len(SE1->E1_TIPOLIQ))+"' AND "						
					Endif	
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Ponto de entrada para filtrar pelo MSFIL em caso de ³
				//³ arquivo compartilhado.  Titulos em aberto           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (ExistBlock("FO10FILT"))    
					cQuery += ExecBlock("FO10FILT",.F.,.F.)
				Endif                    

				//SITCOB
				cQuery +=		"SE1.D_E_L_E_T_<>'*' AND "
				cQuery +=    	"FRV.FRV_FILIAL = '"+xFilial("FRV")+"' AND "
				cQuery +=		"FRV.FRV_CODIGO = SE1.E1_SITUACA AND "
				cQuery +=		"FRV.D_E_L_E_T_<>'*' "

				cQuery += "AND SE1.E1_TIPO NOT IN " + FormatIn(MVABATIM,"|")

				If UPPER(TcGetDb()) != "INFORMIX"
					cQuery   += " ORDER BY  " + SqlOrder("E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+SE1RECNO")
				Endif	

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Ponto de entrada para alteracao da cQuery na consulta Titulos em Aberto ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lF010CQTA
					cQuery := ExecBlock("F010CQTA",.F.,.F.,{cQuery})
				EndIf  

				cQuery := ChangeQuery(cQuery)
				cQry   := cArquivo+"A"

				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cQry,.T.,.T.)
				
				If lF010CQTA
					aStrTmp := (cQry)->(DBSTRUCT())

					If aScan(aStrTmp, {|x| x[1] == "E1_FILIAL" })  > 0
						lFilial	:= .T.
					Endif
					If aScan(aStrTmp, {|x| x[1] == "E1_FILORIG" })  > 0
						lFilOri	:= .T.
					Endif
				EndIf

				aEval(aQuery,{|x| If(x[2]!="C",TcSetField(cQry,x[1],x[2],x[3],x[4]),Nil)})
			Else
				#ENDIF
				cQry := "SE1"
				#IFDEF TOP
			EndIf
			#ENDIF
			dbSelectArea(cQry)
			If ( !lQuery )
				dbSetOrder(2)
				If aParam[13] == 1 //Considera loja
					dbSeek(xFilial("SE1")+SA1->A1_COD+SA1->A1_LOJA)
					bWhile := {|| !Eof() .And. xFilial("SE1") == SE1->E1_FILIAL .And.;
					SA1->A1_COD    == SE1->E1_CLIENTE .And.;
					SA1->A1_LOJA   == SE1->E1_LOJA }
				Else
					dbSeek(xFilial("SE1")+SA1->A1_COD)
					bWhile := {|| !Eof() .And. xFilial("SE1") == SE1->E1_FILIAL .And.;
					SA1->A1_COD    == SE1->E1_CLIENTE }
				Endif

				bFiltro:= {|| !(SE1->E1_TIPO $ MVABATIM) .And.;
				SE1->E1_EMISSAO >= aParam[1] .And.;
				SE1->E1_EMISSAO <= aParam[2] .And.;
				SE1->E1_VENCREA >= aParam[3] .And.;
				SE1->E1_VENCREA <= aParam[4] .And.;
				If(aParam[5]==2,SE1->E1_TIPO!="PR ",.T.) .And.;
				If(aParam[15]==2,!SE1->E1_TIPO$MVRECANT,.T.) .And.;
				SE1->E1_PREFIXO >= aParam[6] .And.;
				SE1->E1_PREFIXO <= aParam[7] .And.;
				SE1->E1_SALDO   > 0 .And.;
				IIf(cPaisLoc == "BRA",.T.,!(SE1->E1_TIPO$cCheques)) .And.;
				IIF(aParam[11] == 2, Empty(SE1->E1_NUMLIQ) .And. Empty(SE1->E1_TIPOLIQ),.T.)}
			Else
				bWhile := {|| !Eof() }
				bFiltro:= {|| .T. }
			EndIf	
			
			cFilAux := cFilAnt
			
			While ( Eval(bWhile) )				
				If ( Eval(bFiltro) )
					// SETA A FILIAL DO TITULO
					If lF010CQTA
						If lFilOri
							cFilAnt := (cQry)->E1_FILORIG
						EndIf
						If lFilial
							cFilCQTA := (cQry)->E1_FILIAL
						Endif
					Else
						cFilAnt := (cQry)->E1_FILORIG
					EndIf
					dbSelectArea(cAlias)
					dbSetOrder(1)
					cChave := Iif( lF010CQTA, Iif( !lFilOri, (cQry)->E1_FILORIG, cFilAnt), (cQry)->E1_FILORIG)+(cQry)->(E1_CLIENTE)+(cQry)->(E1_LOJA) +;
								(cQry)->(E1_PREFIXO)+(cQry)->(E1_NUM)+;
								(cQry)->(E1_PARCELA)
					cChave += If((cQry)->(E1_TIPO)	$ MVABATIM, "",;
								(cQry)->(E1_TIPO))
					If ( !dbSeek(cChave) )
						RecLock(cAlias,.T.)						
					Else
						RecLock(cAlias,.F.)
					EndIf
					DbSetOrder(1)
					nTotAbat := 0
					
					//Calculo de Juros e Multas: SIGALOJA x SIGAFIN - Inicio 
					nMulta := 0 
					nJuros := 0
					nVA := 0		//Valores Acessórios
					//Saldo Corrigido - Calcula juros e multa
					If aParam[12] == 2
						If !( (cQry)->E1_TIPO $ MVRECANT + "|" + MV_CRNEG ) .And. (cMVJurTipo == "L" .OR. lMvLjIntFS) .AND. lLojxRMul .and. (cQry)->E1_SALDO == (cQry)->E1_VALOR
							nMulta := LojxRMul( , , ,(cQry)->E1_SALDO, (cQry)->E1_ACRESC, (cQry)->E1_VENCREA,  , , (cQry)->E1_MULTA, ,;
													(cQry)->E1_PREFIXO, (cQry)->E1_NUM, (cQry)->E1_PARCELA, (cQry)->E1_TIPO, (cQry)->E1_CLIENTE, (cQry)->E1_LOJA,, .T.  ) 
						EndIf
						
						nJuros := xMoeda(FaJuros((cQry)->E1_VALOR,(cQry)->E1_SALDO,(cQry)->E1_VENCTO,(cQry)->E1_VALJUR,(cQry)->E1_PORCJUR,;
												(cQry)->E1_MOEDA,(cQry)->E1_EMISSAO,,If(cPaisLoc=="BRA",(cQry)->E1_TXMOEDA,0),(cQry)->E1_BAIXA,;
												(cQry)->E1_VENCREA,,(cQry)->E1_PREFIXO, (cQry)->E1_NUM, (cQry)->E1_PARCELA,(cQry)->E1_TIPO),;
												(cQry)->E1_MOEDA,1,,,If(cPaisLoc=="BRA",(cQry)->E1_TXMOEDA,0))
					
						//Chamar calculo Valores Acessorios
						If lValAcess
							nVa := FValAcess(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA, SE1->E1_NATUREZ,!Empty(SE1->E1_BAIXA),,"R",SE1->E1_BAIXA,,SE1->E1_MOEDA)
						EndIf
					EndIf

					//Calculo de Juros e Multas: SIGALOJA x SIGAFIN - Final
					For nCntFor := 1 To Len(aStru)
						Do Case
							Case ( AllTrim(aStru[nCntFor][1])=="FRV_DESCRI" )
								If !( (cQry)->(E1_TIPO)	$ MVABATIM )
									If ( lQuery )
										(cAlias)->FRV_DESCRI := FN022SITCB((cQry)->E1_SITUACA)[9]
									Else
										(cAlias)->FRV_DESCRI := FN022SITCB(SE1->E1_SITUACA)[9]	
									EndIf
								Endif	
							Case ( AllTrim( aStru[nCntFor][1] ) == "ZZ_STATUS" )
								If !( (cQry)->(E1_TIPO) $ MVABATIM )
									If ( lQuery )
										cChaveTit	:=	(cQry)->(	xFilial('SE1',Iif( lF010CQTA, Iif( !lFilOri, E1_FILORIG, cFilAnt), E1_FILORIG))	+"|"+;
																	E1_PREFIXO					+"|"+;
																	E1_NUM						+"|"+;
																	E1_PARCELA					+"|"+;
																	E1_TIPO						+"|"+;
																	E1_CLIENTE					+"|"+;
																	E1_LOJA)					
																					
										cIdDoc	:= FINGRVFK7("SE1", cChaveTit, Iif( lF010CQTA, Iif( !lFilOri, (cQry)->E1_FILORIG, cFilAnt), (cQry)->E1_FILORIG))
										If cPaisLoc == "BRA"
											(cAlias)->ZZ_STATUS := GetStatus(.F., cIdDoc)			
										EndIf						
									EndIf
								Endif
							Case ( AllTrim(aStru[nCntFor][1])=="E1_VALJUR" )
								(cAlias)->E1_VALJUR := nJuros	
							Case ( AllTrim(aStru[nCntFor][1])=="E1_MULTA" )
								(cAlias)->E1_MULTA := nMulta
							//Valores Acessorios
							Case ( AllTrim(aStru[nCntFor][1])=="FKD_VALOR" )
								If __lExisfkd .and. lValAcess
									nVa := FValAcess((calias)->E1_PREFIXO,(calias)->E1_NUM,(calias)->E1_PARCELA,(calias)->E1_TIPO,(calias)->E1_CLIENTE,(calias)->E1_LOJA, iif(!lRelat,(calias)->E1_NATUREZ,),!Empty((calias)->E1_BAIXA),,"R",(calias)->E1_BAIXA,,(calias)->E1_MOEDA)
									(cAlias)->FKD_VALOR := nVa
								EndIf
							Case ( AllTrim(aStru[nCntFor][1])=="E1_ABT" )
								If cPaisLoc == "BRA"
									nTaxaM := (cQry)->E1_TXMOEDA
								Else
									nTaxaM:=round((cQry)->E1_VLCRUZ / (cQry)->E1_VALOR,4)  // Pegar a taxa da moeda usada qdo da inclusão do titulo
								EndIf
								If ( lQuery )
									nRecAtu := (cQry)->SE1RECNO
									SE1->(DbGoTo(nRecAtu))
									nTotAbat := SomaAbat((cQry)->E1_PREFIXO,(cQry)->E1_NUM,(cQry)->E1_PARCELA,"R",1,,(cQry)->E1_CLIENTE,(cQry)->E1_LOJA,If( !lFilial, (cQry)->E1_FILIAL, cFilCQTA),/*DATA REF.*/,(cQry)->E1_TIPO)
									dbSelectArea(cAlias)
									(cAlias)->E1_ABT := nTotAbat								 
								Else
									(cAlias)->E1_ABT := (nTotAbat := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA,SE1->E1_FILIAL,/*DATA REF.*/,(cQry)->E1_TIPO))
								Endif

							Case ( AllTrim(aStru[nCntFor][1])=="E1_SDDECRE" )

								nSaldo := 0
								If cPaisLoc == "BRA"
									nTaxaM := (cQry)->E1_TXMOEDA
								Else
									nTaxaM:=round((cQry)->E1_VLCRUZ / (cQry)->E1_VALOR,4)  // Pegar a taxa da moeda usada qdo da inclusão do titulo
								Endif
								nSaldo += xMoeda((cQry)->(E1_SALDO),(cQry)->(E1_MOEDA),1,dDataBase,,ntaxaM)
								nSaldo -= nTotAbat
								
								aAreaSE1 := SE1->(GetArea())
								nDescFin := 0
								If (cAlias)->E1_VENCREA >= dDataBase .AND. nSaldo > 0
									SE1->(dbSetOrder(1))
									SE1->(dbSeek(FWxFilial('SE1',Iif( lF010CQTA, Iif( !lFilOri, E1_FILORIG, cFilAnt), E1_FILORIG)) + (cAlias)->E1_PREFIXO + (cAlias)->E1_NUM + (cAlias)->E1_PARCELA + (cAlias)->E1_TIPO))
									nDescFin := FaDescFin("SE1",dDataBase,nSaldo,(cAlias)->E1_MOEDA)
								Endif
								RestArea(aAreaSE1)
								(cAlias)->E1_SDDECRE := (cQry)->E1_SDDECRE + nDescFin
								
							Case ( AllTrim(aStru[nCntFor][1])=="E1_SALDO" )
								If cPaisLoc == "BRA"
									nTaxaM := (cQry)->E1_TXMOEDA
								Else
									nTaxaM:=round((cQry)->E1_VLCRUZ / (cQry)->E1_VALOR,4)  // Pegar a taxa da moeda usada qdo da inclusão do titulo
								Endif
								(cAlias)->E1_SALDO += xMoeda((cQry)->(E1_SALDO),(cQry)->(E1_MOEDA),1,dDataBase,,ntaxaM)
								(cAlias)->E1_SALDO -= nTotAbat
								(cAlias)->E1_SALDO += xMoeda((cQry)->(E1_SDACRES) - ((cQry)->(E1_SDDECRE) + nDescFin),(cQry)->(E1_MOEDA),1,dDataBase,,ntaxaM)
								
								If aParam[12] == 2 // mv_par12 = 2 : Considera juros e taxa de pernamencia na visualizacao de titulos em aberto.
									
									If !( (cAlias)->E1_TIPO $ MVRECANT + "|" + MV_CRNEG )
										(cAlias)->E1_SALDO += nJuros
										(cAlias)->E1_SALDO += nVA 
										(cAlias)->E1_SALDO += xMoeda(nMulta,(cQry)->E1_MOEDA,1,,,If(cPaisLoc=="BRA",(cQry)->E1_TXMOEDA,0))
	
										//-------------------------------------------------------------------------------------------------
										// Quando o modulo Gestao Educacional estiver em uso, inclui a 
										// provisao de multa no saldo de titulos em atraso.            
										//-------------------------------------------------------------------------------------------------										
									EndIf
								EndIf
							Case ( AllTrim(aStru[nCntFor][1])=="E1_SALDO2" )
								
								(cAlias)->E1_SALDO2 += (cQry)->(E1_SALDO)
								(cAlias)->E1_SALDO2 -= nTotAbat
								(cAlias)->E1_SALDO2 += (cAlias)->E1_SDACRES - (cAlias)->E1_SDDECRE 
	
								If !( (cAlias)->E1_TIPO $ MVRECANT + "|" + MV_CRNEG )
									//Calculo de Juros e Multas: SIGALOJA x SIGAFIN   -Inicio
									(cAlias)->E1_VALJUR := nJuros										    
									
									
								EndIf 
							    //Calculo de Juros e Multas: SIGALOJA x SIGAFIN  - Final							   								
								If aParam[12] == 2   // mv_par12 = 2 : Considera juros e taxa de pernamencia na visualizacao de titulos em aberto.	
	
									If !( (cAlias)->E1_TIPO $ MVRECANT + "|" + MV_CRNEG )
										(cAlias)->E1_SALDO2 += xMoeda((cAlias)->E1_VALJUR,1,(cQry)->(E1_MOEDA),dDataBase,,ntaxaM) 
										IF __lExisFKD .and. !lRelat
											(cAlias)->E1_SALDO2 += xMoeda((cAlias)->FKD_VALOR,1,(cQry)->(E1_MOEDA),dDataBase,,ntaxaM) //Valores Acessorios
										Endif
										If (cMVJurTipo == "L" .OR. lMvLjIntFS) .and. lLojxRMul
											(cAlias)->E1_SALDO2 += xMoeda((cAlias)->E1_MULTA,1,(cQry)->(E1_MOEDA),dDataBase,,ntaxaM) 
										EndIf

									EndIf								
								Endif
							Case ( AllTrim(aStru[nCntFor][1])=="XX_RECNO" )
								If !( (cQry)->(E1_TIPO)	$ MVABATIM )
									If ( lQuery )
										(cAlias)->XX_RECNO := (cQry)->SE1RECNO
									Else
										(cAlias)->XX_RECNO := SE1->(RecNo())
									EndIf
								Endif
							//Tabela FWA - Situação de título Serasa, não existe em países localizados	
							Case (cPaisLoc == "BRA" .Or. cPaisLoc == "MEX" .Or. cPaisLoc == "ARG") .And. ( !lRelat .And. AllTrim(aStru[nCntFor][1])=="XX_LEGEND" )//Rodrigo

								If !(cPaisLoc $ "MEX|ARG")
									DbSelectArea("FWA")
									FWA->( DbSetOrder(3) )
		
									If 	FWA->(DbSeek((cQry)->(Iif( lF010CQTA, Iif( !lFilOri, E1_FILORIG, cFilAnt), E1_FILORIG)+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA))) .AND. FWA->(FWA_STATUS) == "3"
										(cAlias)->XX_LEGEND  := 	"DISABLE"
									ElseIf (cQry)->E1_CHQDEV == "1"
										(cAlias)->XX_LEGEND  := 	"BR_AMARELO"
									Else
										If !((cQry)->E1_TIPO $ MVABATIM)
											(cAlias)->XX_LEGEND := If(ROUND((cQry)->E1_SALDO,2) != ROUND((cQry)->E1_VALOR,2),"BR_AZUL","BR_VERDE")
										EndIf
									Endif
									FWA->(DbCloseArea())
								Else
									If (cQry)->E1_CHQDEV == "1"
										(cAlias)->XX_LEGEND := "BR_AMARELO"
									Else
										(cAlias)->XX_LEGEND := If(ROUND((cQry)->E1_SALDO,2) != ROUND((cQry)->E1_VALOR,2),"BR_AZUL","BR_VERDE")
									Endif
								Endif
							Case ( AllTrim(aStru[nCntFor][1])=="E1_TIPO" )
								If ( Empty((cAlias)->E1_TIPO) )
									(cAlias)->E1_TIPO := (cQry)->E1_TIPO
								EndIf
							Case ( AllTrim(aStru[nCntFor][1])=="E1_ATR" )
							//Se o título estiver atrasado, faz o calculo dos dias de atraso
								If lF010DATR   
									(cAlias)->E1_ATR := ExecBlock("F010DATR",.F.,.F.,{cQry,cAlias}) // cQry -> Alias da Query. cAlias -> Alias do temporário
								Else
									If dDataBase > (cQry)->E1_VENCREA
										If (((cAlias)->E1_TIPO) $ MVRECANT+"/"+MV_CRNEG)
											(cAlias)->E1_ATR := 0
										Else	
											(cAlias)->E1_ATR := dDataBase - (cAlias)->E1_VENCTO
										EndIf	
									Else 
										If MV_PAR16 == 2 //Se o título NÃO estiver atrasado, então tem ATRASO = 0
											(cAlias)->E1_ATR := 0
										Else
											(cAlias)->E1_ATR := dDataBase - DataValida((cAlias)->E1_VENCREA,.T.)
										EndIf
									Endif
								Endif
							Case ( AllTrim(aStru[nCntFor][1])=="FLAG" )
							Case ( AllTrim(aStru[nCntFor][1])=="E1_FILORIG" )
								(cAlias)->E1_FILORIG := AllTrim(Iif( lF010CQTA, Iif( !lFilOri, (cQry)->E1_FILORIG, cFilAnt), (cQry)->E1_FILORIG)) + " - " + FWFilialName(/*Grupo*/,Iif( lF010CQTA, Iif( !lFilOri, (cQry)->E1_FILORIG, cFilAnt), (cQry)->E1_FILORIG),1)
							Case ( AllTrim(aStru[nCntFor][1])=="E1_VLCRUZ" )
								If !((cQry)->(E1_TIPO)	$ MVABATIM)
									(cAlias)->E1_VLCRUZ := xMoeda((cQry)->(E1_VALOR),(cQry)->(E1_MOEDA),1,dDataBase,,If(cPaisLoc=="BRA",(cQry)->E1_TXMOEDA,0))
									If (cQry)->(E1_TIPO) $ Alltrim(cMVCRNEG) 
										(cAlias)->E1_VLCRUZ := (cAlias)->E1_VLCRUZ * (-1)
									EndIf
								Endif
							Case ( AllTrim(aStru[nCntFor][1])=="E1_VLMULTA" )
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ 11/Ago/2005 Rafael E. Rodrigues                              ³
								//³ Quando o modulo Gestao Educacional estiver em uso eh exibida ³
								//³ a provisao de multa no saldo de titulos em atraso.           ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								(cAlias)->E1_VLMULTA := xMoeda(If(Empty((cQry)->(E1_BAIXA)) .and. dDataBase > Iif((cQry)->E1_VENCREA <> NIL,(cQry)->E1_VENCREA ,(cQry)->E1_VENCTO), (cQry)->(E1_VLMULTA), (cQry)->(E1_MULTA)),(cQry)->(E1_MOEDA),1,dDataBase,,ntaxaM)
							Case ( AllTrim(aStru[nCntFor][1])=="E1_EMISSAO" )
								aDtTit := FINCDtano(cQry)
								(cAlias)->E1_EMISSAO := cTod(aDtTit[1])
							Case ( AllTrim(aStru[nCntFor][1])=="E1_VENCTO" )
								(cAlias)->E1_VENCTO := cTod(aDtTit[2])
							Case ( AllTrim(aStru[nCntFor][1])=="E1_VENCREA" )
								(cAlias)->E1_VENCREA := cTod(aDtTit[3])	
							OtherWise
								If lF010CQTA
									If ( nPos := aScan(aStrTmp, {|x| x[1] == aStru[nCntFor][1] }) ) > 0
										If !( (cQry)->(E1_TIPO)	$ MVABATIM )
											(cAlias)->(FieldPut(nCntFor,(cQry)->(FieldGet(FieldPos(aStru[nCntFor][1])))))
										EndIf
									Else
										If !( (cQry)->(E1_TIPO)	$ MVABATIM )
											If aStru[nCntFor][2] == 'N'
												(cAlias)->(FieldPut(nCntFor, 0 ))
											Else
												(cAlias)->(FieldPut(nCntFor, "" ))
											EndIf
										EndIf
									EndIf
									nPos	:= 0
								Else
									If !( (cQry)->(E1_TIPO)	$ MVABATIM )
										(cAlias)->(FieldPut(nCntFor,(cQry)->(FieldGet(FieldPos(aStru[nCntFor][1])))))
									EndIf
								EndIf	
						EndCase
					Next nCntFor
					dbSelectArea(cAlias)
					If nTotAbat = 0
						If ( (cAlias)->E1_SALDO <= 0 )
							dbDelete()
						EndIf
					Endif						
					MsUnLock()
				EndIf
				dbSelectArea(cQry)
				dbSkip()				
			EndDo
			
			cFilAnt := cFilAux
			
			If ( lQuery )
				dbSelectArea(cQry)
				dbCloseArea()
			EndIf

			cOrdem := IF(MV_PAR18 == 1,"DTOS(E1_VENCTO)","DTOS(E1_VENCREA)")

			If (ExistBlock("F010ORD1"))    
				//Retornar chave no formato "E1_CLIENTE+E1_LOJA+E1_TIPO+E1_PREFIXO+E1_NUM+E1_PARCELA+SE1RECNO"
				cOrdem := ExecBlock("F010ORD1",.F.,.F.)
			Endif                    

			dbSelectArea(cAlias)
			IndRegua(cAlias,cArquivo,cOrdem)
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Totais da Consulta ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aGet[1] := 0
		aGet[2] := 0
		aGet[3] := 0
		aGet[4] := 0
		aGet[5] := 0
		aGet[6] := 0
		aGet[7] := 0
		aGet[8] := 0
		aTotRec := {{0,1,0,0}} // Totalizador de titulos a receber por moeda
		dbSelectArea(cAlias)
		dbGotop()
		While !EOF()		 			 	
			aGet[1]++
			If !lRelat
				SE1->(DbGoto((cAlias)->XX_RECNO))	// Posiciona no arquivo original para obter os valores
				// em outras moedas e em R$
				nAscan := Ascan(aTotRec,{|e| e[MOEDATIT] == E1_MOEDA})
			Endif

			//Calcular o abatimento para visualização em tela
			If (cAlias)->E1_ABT > 0
				//(cAlias)->E1_SALDO -= (cAlias)->E1_ABT		 	
				(cAlias)->E1_SALDO2 := xMoeda((cAlias)->E1_SALDO,E1_MOEDA,1,dDataBase,,ntaxaM)
			Endif		 	

			If E1_TIPO $ "RA #"+MV_CRNEG
				aGet[2] -= E1_VLCRUZ
				aGet[3] -= E1_SALDO
				aGet[4] -= E1_VALJUR

				nAcresc := nDecres := 0
				If !lRelat
					nAcresc := xMoeda(E1_SDACRES,E1_MOEDA,1,dDataBase,,ntaxaM)
					nDecres := xMoeda(E1_SDDECRE,E1_MOEDA,1,dDataBase,,ntaxaM)
					aGet[5] -= nAcresc
					aGet[6] -= nDecres
					If nAscan = 0 
						Aadd(aTotRec,{1,E1_MOEDA,SE1->E1_SALDO*(-1),If(E1_MOEDA>1,xMoeda(SE1->E1_SALDO,E1_MOEDA,1,,,If(cPaisLoc=="BRA",SE1->E1_TXMOEDA,0)),SE1->E1_SALDO)*(-1)})
					Else
						aTotRec[nAscan][QTDETITULOS]--
						aTotRec[nAscan][VALORTIT]	-= SE1->E1_SALDO
						aTotRec[nAscan][VALORREAIS]	-= If(E1_MOEDA>1,xMoeda(SE1->E1_SALDO,E1_MOEDA,1,,,If(cPaisLoc=="BRA",SE1->E1_TXMOEDA,0)),SE1->E1_SALDO)
					Endif
				Endif	
				If aParam[12] == 1 //Saldo sem correcao
					aGet[8] -= E1_SALDO-E1_ABT+E1_VALJUR+nAcresc-nDecres
				Else
					aGet[8] -= E1_SALDO
				Endif
			Else	
				aGet[2] += E1_VLCRUZ
				aGet[3] += E1_SALDO
				aGet[4] += E1_VALJUR
				aGet[7] += E1_ABT
				nAcresc := nDecres := 0
				If !lRelat
					nAcresc := xMoeda(E1_SDACRES,E1_MOEDA,1,dDataBase,,ntaxaM)
					nDecres := xMoeda(E1_SDDECRE,E1_MOEDA,1,dDataBase,,ntaxaM)
					aGet[5] += nAcresc
					aGet[6] += nDecres
					If nAscan = 0
						Aadd(aTotRec,{1,E1_MOEDA,SE1->E1_SALDO,If(E1_MOEDA>1,xMoeda(SE1->E1_SALDO,E1_MOEDA,1,,,If(cPaisLoc=="BRA",SE1->E1_TXMOEDA,0)),SE1->E1_SALDO)})
					Else
						aTotRec[nAscan][QTDETITULOS]++
						aTotRec[nAscan][VALORTIT]	+= SE1->E1_SALDO
						aTotRec[nAscan][VALORREAIS]	+= If(E1_MOEDA>1,xMoeda(SE1->E1_SALDO,E1_MOEDA,1,,,If(cPaisLoc=="BRA",SE1->E1_TXMOEDA,0)),SE1->E1_SALDO)
					Endif
				Endif
				If aParam[12] == 1 //Saldo sem correcao
					aGet[8] += E1_SALDO-E1_ABT+E1_VALJUR+nAcresc-nDecres 
				Else
					aGet[8] += E1_SALDO 
				Endif
			Endif
			dbSkip()
		Enddo
		If !lRelat
			nTotalRec:=0
			aEval(aTotRec,{|e| nTotalRec+=e[VALORREAIS]})
			Aadd(aTotRec,{"","",STR0096,nTotalRec}) //"Total ====>>"
			// Formata as colunas
			aEval(aTotRec,{|e|	If(ValType(e[VALORTIT]) == "N"	, e[VALORTIT]		:= Transform(e[VALORTIT],Tm(e[VALORTIT],16,nCasas)),Nil),;
			If(ValType(e[VALORREAIS]) == "N"	, e[VALORREAIS]	:= Transform(e[VALORREAIS],Tm(e[VALORREAIS],16,nCasas)),Nil)})
		Endif										

		aGet[1] := TransForm(aGet[1],Tm(aGet[1],16,0))
		aGet[2] := TransForm(aGet[2],Tm(aGet[2],16,nCasas))
		aGet[3] := TransForm(aGet[3],Tm(aGet[3],16,nCasas))
		aGet[4] := TransForm(aGet[4],Tm(aGet[4],16,nCasas))
		aGet[5] := TransForm(aGet[5],Tm(aGet[5],16,nCasas))
		aGet[6] := TransForm(aGet[6],Tm(aGet[6],16,nCasas))
		aGet[7] := TransForm(aGet[7],Tm(aGet[7],16,nCasas))		
		aGet[8] := TransForm(aGet[8],Tm(aGet[8],16,nCasas))		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Titulos Recebidos ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*-----------------------------------------------------------------------------------------------------------------DMS*/		
		Case ( nBrowse == 2 )
		dbSelectArea("SX3")
		dbSetOrder(2)

		dbSeek("E1_LOJA")
		If aParam[13] == 2  //Considera loja
			aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		Endif
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		/* 
		GESTAO - inicio */
		dbSeek("E1_FILORIG")
		If !lRelat
			nTamFil := Len(SM0->(AllTrim(M0_CODFIL) + " - " + M0_NOME))
		else
			nTamFil := Len(SM0->(AllTrim(M0_CODFIL)))
		Endif
		aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,nTamFil,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,nTamFil,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,nTamFil,SX3->X3_DECIMAL})
		
		/* GESTAO - fim
		*/
				
		dbSeek("E1_PREFIXO")
		aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		dbSeek("E1_NUM")
		aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		dbSeek("E1_PARCELA")
		aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		dbSeek("E1_TIPO")
		aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		
		If !lRelat .and. cPaisLoc == 'BRA'
			dbSeek("E1_NFELETR")
			aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
			aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		Endif

		IF !lRelat
			dbSeek("E1_MOEDA")
			aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
			aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		Endif

		dbSeek("E1_EMISSAO")
		aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				
		If lRelat 
			dbSeek("E1_VENCTO")
			If MV_PAR18 == 1
				aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
			Endif
			aadd(aStru  ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aadd(aQuery ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

			dbSeek("E1_VENCREA")
			If MV_PAR18 == 2		
				aadd(aHeader,{AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
			Endif
			aadd(aStru  ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aadd(aQuery ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		Else		
			dbSeek("E1_VENCTO")
			aadd(aHeader,{AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
			aadd(aStru  ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aadd(aQuery ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})	

			dbSeek("E1_VENCREA")
			aadd(aHeader,{AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
			aadd(aStru  ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aadd(aQuery ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		Endif	

		dbSeek("E5_DATA")
		aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		dbSeek("E5_DTDISPO")
		aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		IF !lRelat
			dbSeek("E1_VALOR")
			aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
			aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		Endif	

		dbSeek("E1_VLCRUZ")
		aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,18,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,18,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,18,SX3->X3_DECIMAL})

		aCpoVlr := { "E5_VLJUROS", "E5_VLMULTA", "E5_VLCORRE", "E5_VLDESCO", "E5_VLACRES", "E5_VLDECRE" }
		For nCntFor := 1 To Len(aCpoVlr)
			dbSeek(aCpoVlr[nCntFor])
			aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,8,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
			aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		Next
		
		//Valores Acessorios
		If __lExisFKD .and. !lRelat
			If dbSeek("FKD_VALOR")
				aadd(aHeader,{ AllTrim(STR0139),SX3->X3_CAMPO,cPicture,8,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )//"Valores Acessorios"
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,8,SX3->X3_DECIMAL})
			Endif
		Endif

		dbSeek("E5_VALOR")
		aadd(aHeader,{STR0047,"E1_PAGO",SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,"V" } ) //"Pago"
		aadd(aStru ,{"E1_PAGO",SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		IF !lRelat
			dbSeek("E1_VALOR")
			aadd(aHeader,{ STR0093,"E1_VLMOED2",SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } ) //"Vlr pago  moeda tit."
			aadd(aStru ,{"E1_VLMOED2",SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

			dbSeek("E5_VLMOED2")
			aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

			If cPaisLoc == "BRA"
				dbSeek("E5_TXMOEDA")
				aadd(aHeader,{AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			Endif
		Endif	

		dbSeek("E1_NATUREZ")
		aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		If !lRelat
			dbSeek("E1_NUMLIQ")
			aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
			aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		Endif

		dbSeek("E5_BANCO")
		aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		dbSeek("E5_AGENCIA")
		aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		dbSeek("E5_CONTA")
		aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		dbSeek("E5_HISTOR")
		aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		dbSeek("E5_MOTBX")
		aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		If !lRelat
			dbSeek("E5_CNABOC")
			aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
			aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		Endif

		dbSeek("E5_TIPODOC")
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})		

		aadd(aHeader,{STR0035,"E1_ATR","9999999999",10,0,"","","N","","V" } ) //"Atraso"
		aadd(aStru ,{"E1_ATR","N",10,0})

		dbSeek("E1_VALJUR")
		aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		aadd(aStru,{"XX_RECNO","N",12,0})

		If cPaisLoc == "BRA"
			aadd(aQuery,{"E1_TXMOEDA","N",17,4})
		Endif	

		IF lFC010bxhe
			aHeader1 :=	aClone(aHeader)			
			aHeader1 :=	ExecBlock("FC010bxhe",.F.,.F.,aHeader1)						

			For nA := 1 to Len(aHeader1)
				// Verificação se os campos adicionados no PE já estão no cabeçalho(aHeader)
				If Ascan(aHeader,{ |e| Alltrim(e[2]) == Alltrim(aHeader1[nA,2]) }) = 0	
					aadd(aHeader,{;
						aHeader1[nA,1],aHeader1[nA,2],aHeader1[nA,3],aHeader1[nA,4], ;
						aHeader1[nA,5],aHeader1[nA,6],aHeader1[nA,7],aHeader1[nA,8]  ;
					})																
				Endif									
			Next

			For nA := 1 to Len(aHeader)
				// Verificação se os campos do cabeçalho já estão na estrutura(aStru)
				If Ascan(aStru,{|e| Alltrim(e[1]) == Alltrim(aHeader1[nA,2])}) = 0				   
					aadd(aStru ,{aHeader[nA,2],aHeader[nA,8],aHeader[nA,4],aHeader[nA,5]})
					aadd(aQuery,{aHeader[nA,2],aHeader[nA,8],aHeader[nA,4],aHeader[nA,5]})														
				Endif									
			Next									
		EndIf

		SX3->(DbSetOrder(1))

		If ( Select(cAlias) ==	0 )
			cArquivo := CriaTrab(,.F.)			
			aadd(aAlias,{ cAlias , cArquivo })
			aadd(aStru,{"FLAG","L",01,0})

			If _oFINC0102 <> Nil
				_oFINC0102:Delete()
				_oFINC0102 := Nil
			Endif

			_oFINC0102 := FWTemporaryTable():New( cAlias )  
			_oFINC0102:SetFields(aStru) 
			_oFINC0102:AddIndex("1", {"E1_FILORIG","E1_PREFIXO","E1_NUM","E1_PARCELA","E1_TIPO"})

			//------------------
			//Criação da tabela temporaria
			//------------------
			_oFINC0102:Create()  

			#IFDEF TOP
			If ( TcSrvType()!="AS/400" )
				cCmpFilE1	:= FWModeAccess("SE1", 3)
				cCompSE1	:= FWModeAccess("SE1", 1) + FWModeAccess("SE1", 2) + cCmpFilE1
				cCmpFilE5	:= FWModeAccess("SE5", 3)
				cCompSE5	:= FWModeAccess("SE5", 1) + FWModeAccess("SE5", 2) + cCmpFilE5

				cQuery := ""
				aEval(aQuery,{|x| cQuery += ","+AllTrim(x[1])})
				cQuery := "SELECT "+SubStr(cQuery,2)+",E1_ORIGEM,SE5.R_E_C_N_O_ SE5RECNO , SE5.E5_DOCUMEN E5_DOCUMEN ,SE1.E1_CLIENTE,SE1.E1_LOJA, FK7.FK7_IDDOC "
				cQuery += "FROM "+RetSqlName("SE1")+" SE1 "
				cQuery += "INNER JOIN " + RetSqlName("SE5")+" SE5 ON "

				If cCmpFilE1 == 'E'
					cQuery += "( SE5.E5_FILIAL " + GetRngFil(aSelFil,'SE5',.T.,@cTmpFil) + " OR "
					cQuery += "SE5.E5_FILORIG " + GetRngFil(aSelFil,'SE5',.T.,@cTmpFil) + ") AND "
					cQuery += "SE5.E5_FILORIG = SE1.E1_FILIAL AND "
				Else
					cQuery += "((SE5.E5_FILIAL " + GetRngFil(aSelFil,'SE5',.T.,@cTmpFil) + " AND "
					cQuery += "SE5.E5_FILORIG = SE1.E1_FILORIG) "
					cQuery += " OR (SE5.E5_FILORIG = '')) AND "  // Tratamento pelo compartilhamento da SE5, esse existe para base legado com FILORIG em branco
				EndIf

				cQuery +=		"SE5.E5_NATUREZ=SE1.E1_NATUREZ AND "
				cQuery +=		"SE5.E5_PREFIXO=SE1.E1_PREFIXO AND "
				cQuery +=		"SE5.E5_NUMERO=SE1.E1_NUM AND "
				cQuery +=		"SE5.E5_PARCELA=SE1.E1_PARCELA AND "
				cQuery +=		"SE5.E5_TIPO=SE1.E1_TIPO AND "
				cQuery +=		"SE5.E5_CLIFOR=SE1.E1_CLIENTE AND "
				cQuery +=		"SE5.E5_LOJA=SE1.E1_LOJA AND "
				If !lAntCred   
					cQuery +=	"SE5.E5_DATA >= SE1.E1_EMISSAO AND "
				Endif
				cQuery +=		"(SE5.E5_RECPAG ='R' OR (SE5.E5_RECPAG='P' AND SE5.E5_TIPO IN ('NCC', 'RA ') ) )AND "				
				cQuery +=		"SE5.E5_TIPODOC <> 'RA ' AND "
				cQuery +=		"SE5.E5_TIPODOC IN ('VL','BA','V2','CP','LJ','R$') AND "

				If aParam[8] == 2
					//Titulos baixados por geracao de fatura
					cQuery += " SE5.E5_MOTBX <> 'FAT' AND "
				Endif
				If aParam[09] == 2
					//Titulos baixados por liquidacao
					cQuery += " SE5.E5_MOTBX <> 'LIQ' AND "
				Endif

				cQuery +=		"SE5.E5_SITUACA <>'C' AND "
				cQuery +=		"SE5.D_E_L_E_T_ = ' ' AND "				
				cQuery += "		NOT EXISTS ( "
				cQuery += "		SELECT A.E5_NUMERO "
				cQuery += "		FROM "+RetSqlName("SE5")+" A "
				cQuery += "		WHERE A.E5_FILIAL = SE5.E5_FILIAL AND "				
				cQuery +=		"A.E5_NATUREZ=SE5.E5_NATUREZ AND "
				cQuery +=		"A.E5_PREFIXO=SE5.E5_PREFIXO AND "
				cQuery +=		"A.E5_NUMERO=SE5.E5_NUMERO AND "
				cQuery +=		"A.E5_PARCELA=SE5.E5_PARCELA AND "
				cQuery +=		"A.E5_TIPO=SE5.E5_TIPO AND "
				cQuery +=		"A.E5_CLIFOR=SE5.E5_CLIFOR AND "
				cQuery +=		"A.E5_LOJA=SE5.E5_LOJA AND "
				cQuery +=		"A.E5_SEQ=SE5.E5_SEQ AND "
				cQuery +=		"A.E5_TIPODOC='ES' AND "
				cQuery +=		"A.E5_RECPAG<>'R' AND "
				cQuery +=		"A.D_E_L_E_T_= ' ' ) "


				cQuery += " LEFT JOIN " + RetSqlName("FK7") + " FK7 "
				cQuery += " 	ON FK7_FILIAL " + GetRngFil(aSelFil,'FK7',.T.,@cTmpFK7)
				cQuery += "		AND FK7_ALIAS = 'SE1' "
				If 'MSSQL' $ UPPER(TcGetDb()) // MSSQL não tem RPAD
					cQuery += "		AND FK7_CHAVE = E1_FILORIG || '|' || E1_PREFIXO || '|' || E1_NUM || '|' || E1_PARCELA || '|' || E1_TIPO || '|' || E1_CLIENTE || '|' || E1_LOJA  +  Space(" + cValToChar(nTamFK7C - nChvSE1) + ") "
				Else
					cQuery += "		AND FK7_CHAVE = RPAD( E1_FILORIG || '|' || E1_PREFIXO || '|' || E1_NUM || '|' || E1_PARCELA || '|' || E1_TIPO || '|' || E1_CLIENTE || '|' || E1_LOJA , " + cValToChar(nTamFK7C) + " , ' ' ) "									
				EndIf
				cQuery += "		AND FK7.D_E_L_E_T_ = ' ' "

				/*
				GESTAO - inicio */
				nPosAlias := FC010QFil(1,"SE1")
				cQuery += "WHERE SE1.E1_FILIAL " + aTmpFil[nPosAlias,2] + " AND "
				/* GESTAO - fim
				*/
				cQuery +=       "SE1.E1_CLIENTE='"+SA1->A1_COD+"' AND "
				If aParam[13] == 1  //Considera loja
					cQuery +=       "SE1.E1_LOJA='"+SA1->A1_LOJA+"' AND "
				Endif
				cQuery +=       "SE1.E1_EMISSAO>='"+Dtos(aParam[1])+"' AND "
				cQuery +=       "SE1.E1_EMISSAO<='"+Dtos(aParam[2])+"' AND "
				cQuery +=       "SE1.E1_VENCREA>='"+Dtos(aParam[3])+"' AND "
				cQuery +=       "SE1.E1_VENCREA<='"+Dtos(aParam[4])+"' AND "
				If ( aParam[5] == 2 )
					cQuery +=   "SE1.E1_TIPO<>'PR ' AND "
				EndIf					
				If ( aParam[15] == 2 )
					cQuery +=   "SE1.E1_TIPO<>'RA ' AND "
				EndIf					
				cQuery +=       "SE1.E1_PREFIXO>='"+aParam[6]+"' AND "
				cQuery +=       "SE1.E1_PREFIXO<='"+aParam[7]+"' AND "

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Ponto de entrada para filtrar pelo MSFIL em caso de ³
				//³ arquivo compartilhado. Titulos Recebidos            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				If (ExistBlock("FO10FLTR"))    
					cQuery += ExecBlock("FO10FLTR",.F.,.F.)
				Endif                    

				If cPaisLoc != "BRA"
					cQuery += "SE1.E1_TIPO NOT IN" + FormatIn(cCheques,"|") + " AND "
				Else
					cQuery += "SE1.E1_ORIGEM <> 'FINA087A' AND "
				Endif

				cQuery +=		"SE1.E1_TIPO NOT IN " + FormatIn(MVPAGANT, cSepPag) + " AND "
				cQuery +=		"SE1.E1_TIPO NOT IN " + FormatIn(MV_CPNEG, cSepNeg) + " AND "				
				cQuery +=		"SE1.D_E_L_E_T_ = ' '  "


				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Ponto de entrada para alteracao da cQuery na consulta Titulos Recebidos ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (ExistBlock("F010CQTR"))    
					cQuery := ExecBlock("F010CQTR",.F.,.F.,{cQuery})
				Endif

				cQuery := ChangeQuery(cQuery)
				cQry   := cArquivo+"A"

				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cQry,.T.,.T.)

				aEval(aQuery,{|x| If(x[2]!="C",TcSetField(cQry,x[1],x[2],x[3],x[4]),Nil)})

				dbSelectArea(cQry)
				bWhile := {|| (cQry)->(!Eof()) }
				bFiltro:= {|| IIf( UPPER(SUBSTR((cQry)->E5_HISTOR,1,4)) <> "LOJ-", .T., ;
							( ;
								( ;
									(cQry)->E1_NUM == cNumAnt .AND. (cQry)->E5_TIPODOC == cTpDocAnt ;
								) ;
								.OR. ;
								( ;
									(cQry)->E1_NUM == cNumAnt .AND. (cQry)->E1_PARCELA <> cParcAnt  ;
								) ;
								.OR. ;
									(cQry)->E1_NUM <> cNumAnt ;
								) ;
							)  }
				cAnterior := ""
				DbSelectArea("FK1")
				cBkpFil	:= cFilAnt
				While ( Eval(bWhile) )				
					If ( Eval(bFiltro) )
						cNumAnt := (cQry)->E1_NUM
						cTpDocAnt := (cQry)->E5_TIPODOC
						cParcAnt := (cQry)->E1_PARCELA
						dbSelectArea(cAlias)
						dbSetOrder(1)
						RecLock(cAlias,.T.)
						For nCntFor := 1 To Len(aStru)
							Do Case
								Case ( AllTrim(aStru[nCntFor][1])=="E1_PAGO" )
									If ( (cQry)->E5_TIPODOC $ "VL/BA/V2/CP/LJ/R$" )
										(cAlias)->E1_PAGO += (cQry)->E5_VALOR
									EndIf
								Case ( AllTrim(aStru[nCntFor][1])=="E1_VLMOED2" ) .And. !lRelat
									If ( (cQry)->E5_TIPODOC $ "VL/BA/V2/CP/LJ/R$" ) .And. (cQry)->E1_MOEDA > 1
										(cAlias)->E1_VLMOED2 := If((cQry)->E1_MOEDA > 1, (cQry)->E5_VLMOED2, (cQry)->E5_VALOR)
									EndIf	
								Case ( AllTrim(aStru[nCntFor][1])=="E1_SALDO2" )
									If ( (cQry)->(E1_TIPO)	$ MVABATIM )
										(cAlias)->E1_SALDO2 -= nTotAbat
									Else
										(cAlias)->E1_SALDO2 += (cQry)->(E1_SALDO)
										(cAlias)->E1_SALDO2 += (cAlias)->E1_SDACRES - (cAlias)->E1_SDDECRE
									EndIf

									If ( !lQuery )
										(cAlias)->E1_SALDO2 -= nTotAbat
									EndIf	
								Case ( AllTrim(aStru[nCntFor][1])=="E5_VLJUROS" ) .AND. !lRelat
									(cAlias)->E5_VLJUROS := (cQry)->E5_VLJUROS - (cQry)->E5_VLACRES
								Case ( AllTrim(aStru[nCntFor][1]) == 'FKD_VALOR' .And. !lRelat)
									nVa := 0
									cFilAnt := (cQry)->E1_FILORIG
									cChaveFK7 := (cQry)->FK7_IDDOC

									If Empty(cChaveFK7)
										cChaveTit := xFilial("SE1", (cQry)->E1_FILORIG) + "|" + (cQry)->E1_PREFIXO + "|" + (cQry)->E1_NUM + "|" + (cQry)->E1_PARCELA + "|" + (cQry)->E1_TIPO + "|" + (cQry)->E1_CLIENTE + "|" + (cQry)->E1_LOJA
										cChaveFK7 := FINGRVFK7("SE1", cChaveTit)
									EndIf

									FK1->(DbSetOrder(2))
									If(FK1->(DbSeek(xFilial( "FK1")+cChaveFK7)))
										While FK1->(!EOF()) .AND. FK1->FK1_IDDOC == cChaveFK7
										
											nVA += FxLoadFK6("FK1",FK1->FK1_IDFK1,"VA")[1][2]
											
											FK1->(DbSkip())
										End
									EndIf

									(cAlias)->FKD_VALOR := nVA
								Case ( AllTrim(aStru[nCntFor][1])=="E5_VLDESCO" ) .AND. !lRelat
									(cAlias)->E5_VLDESCO := (cQry)->E5_VLDESCO - (cQry)->E5_VLDECRE
								Case ( AllTrim(aStru[nCntFor][1])=="E1_VLCRUZ" )
									If ( (cQry)->E5_TIPODOC $ "VL/BA/V2/CP/LJ/R$" )
										If cAnterior != (cQry)->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)
											(cAlias)->E1_VLCRUZ := (cQry)->E1_VLCRUZ
											cAnterior := (cQry)->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)
										Endif
									EndIf										
								Case ( AllTrim(aStru[nCntFor][1])=="E1_ATR" )								
									If (cQry)->E5_DATA > DataValida((cQry)->E1_VENCREA,.T.)
										(cAlias)->E1_ATR := (cQry)->E5_DATA - (cQry)->E1_VENCREA
									Else										
										If (cQry)->E5_DATA < (cQry)->E1_VENCREA
											(cAlias)->E1_ATR := 0
										else
											(cAlias)->E1_ATR := (cQry)->E5_DATA - DataValida((cQry)->E1_VENCREA,.T.)
										Endif	
									Endif									
								Case ( AllTrim(aStru[nCntFor][1])=="E1_FILORIG" )
									(cAlias)->E1_FILORIG := AllTrim((cQry)->E1_FILORIG) + " - " + FWFilialName(/*Grupo*/,(cQry)->E1_FILORIG,1)
								Case cPaisLoc=="BRA" .And. ( AllTrim(aStru[nCntFor][1])=="E5_TXMOEDA" )  .And. !lRelat
									If (cQry)->E1_MOEDA == 1
										(cAlias)->E5_TXMOEDA := 1
									Else
										If (cQry)->E5_TXMOEDA == 0 
											(cAlias)->E5_TXMOEDA := ((cQry)->E5_VALOR /(cQry)->E5_VLMOED2)
										Else
											(cAlias)->E5_TXMOEDA := (cQry)->E5_TXMOEDA
										Endif
									Endif
								Case ( !lRelat .And. AllTrim(aStru[nCntFor][1])=="E1_NUMLIQ" )
									If (cQry)->E5_MOTBX == "LIQ"
										If Empty( (cQry)->E1_NUMLIQ )
											(cAlias)->E1_NUMLIQ := SUBSTR((cQry)->E5_DOCUMEN,1,TamSx3("E1_NUMLIQ")[1])
										Else
											(cAlias)->(FieldPut(nCntFor,(cQry)->(FieldGet(FieldPos(aStru[nCntFor][1])))))			
										Endif		
									Endif
								Case ( AllTrim(aStru[nCntFor][1])=="XX_RECNO" )
									(cAlias)->XX_RECNO := (cQry)->SE5RECNO
								Case ( AllTrim(aStru[nCntFor][1])=="FLAG" )
								OtherWise
									(cAlias)->(FieldPut(nCntFor,(cQry)->(FieldGet(FieldPos(aStru[nCntFor][1])))))
							EndCase
						Next nCntFor
						(cAlias)->(MsUnLock())
					EndIf
					dbSelectArea(cQry)
					dbSkip()				
				EndDo
				cFilAnt := cBkpFil
				dbSelectArea(cQry)
				dbCloseArea()
			Else
				#ENDIF
				dbSelectArea("SE1")
				dbSetOrder(2)
				If aParam[13] == 1  //Considera loja
					dbSeek(xFilial("SE1")+SA1->A1_COD+SA1->A1_LOJA)
					bWhile := {|| !Eof() .And. xFilial("SE1") == SE1->E1_FILIAL .And.;
					SA1->A1_COD    == SE1->E1_CLIENTE .And.;
					SA1->A1_LOJA   == SE1->E1_LOJA }
				Else
					dbSeek(xFilial("SE1")+SA1->A1_COD)
					bWhile := {|| !Eof() .And. xFilial("SE1") == SE1->E1_FILIAL .And.;
					SA1->A1_COD    == SE1->E1_CLIENTE }
				Endif

				bFiltro:= {|| 	SubStr(SE1->E1_TIPO,3,1)!="-" .And.;
				SE1->E1_EMISSAO >= aParam[1] .And.;
				SE1->E1_EMISSAO <= aParam[2] .And.;
				SE1->E1_VENCREA >= aParam[3] .And.;
				SE1->E1_VENCREA <= aParam[4] .And.;
				If(aParam[5]==2,SE1->E1_TIPO!="PR ",.T.) .And.;
				If(aParam[15]==2,!SE1->E1_TIPO$MVRECANT,.T.) .And.;									
				SE1->E1_PREFIXO >= aParam[6] .And.;
				SE1->E1_PREFIXO <= aParam[7] .And.;
				IIf(cPaisLoc == "BRA",(SE1->E1_ORIGEM<>"FINA087A"),!(SE1->E1_TIPO$cCheques)) }

				While ( Eval(bWhile) )
					If ( Eval(bFiltro) )
						dbSelectArea("SE5")
						dbSetOrder(7)
						dbSeek(xFilial("SE5")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+SE1->E1_CLIENTE+SE1->E1_LOJA)

						While ( !Eof() .And. xFilial("SE5") == SE5->E5_FILIAL .And.;
						SE1->E1_PREFIXO == SE5->E5_PREFIXO .And.;
						SE1->E1_NUM == SE5->E5_NUMERO      .And.;
						SE1->E1_PARCELA == SE5->E5_PARCELA .And.;
						SE1->E1_TIPO == SE5->E5_TIPO       .And.;
						SE1->E1_CLIENTE == SE5->E5_CLIFOR	.And.;
						SE1->E1_LOJA == SE5->E5_LOJA )

							// Baixas efetuadas por liquidacao ou por fatura, se nao devem ser consideradas despreza
							If (aParam[08] == 2 .And. SE5->E5_MOTBX == "FAT") .Or.;
							(aParam[09] == 2 .And. SE5->E5_MOTBX == "LIQ")
								dbSelectArea("SE5")
								dbSkip()	
								Loop
							Endif

							If ((!SE5->E5_TIPO $ "RA /PA /"+MV_CRNEG+"/"+MV_CPNEG) .And. !TemBxCanc() .and. ;
							SE5->E5_SITUACA <> "C" .And. SE5->E5_TIPODOC $ "VL/BA/V2/CP/LJ/R$")
								RecLock(cAlias,.T.)
								For nCntFor := 1 To Len(aStru)
									Do Case
										Case ( AllTrim(aStru[nCntFor][1])=="E1_PAGO" )
										If ( SE5->E5_TIPODOC $ "VL/BA/V2/CP/LJ/R$" )
											(cAlias)->E1_PAGO += SE5->E5_VALOR
										EndIf
										Case ( AllTrim(aStru[nCntFor][1])=="E1_VLMOED2" ) .And. !lRelat
										If ( SE5->E5_TIPODOC $ "VL/BA/V2/CP/LJ/R$" ) .And. SE1->E1_MOEDA > 1
											(cAlias)->E1_VLMOED2 := If(SE1->E1_MOEDA > 1, SE5->E5_VLMOED2, SE5->E5_VALOR)
										EndIf		
										Case ( AllTrim(aStru[nCntFor][1])=="E1_VLCRUZ" )
										If ( SE5->E5_TIPODOC $ "VL/BA/V2/CP/LJ/R$" )
											If cAnterior != SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)
												(cAlias)->E1_VLCRUZ := SE1->E1_VLCRUZ
												cAnterior := SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)
											Endif
										Endif	
										Case ( AllTrim(aStru[nCntFor][1])=="E1_ATR" )
										If SE5->E5_DATA > DataValida(SE1->E1_VENCREA,.T.)
											(cAlias)->E1_ATR := SE5->E5_DATA - SE1->E1_VENCREA
										Else
											(cAlias)->E1_ATR := SE5->E5_DATA - DataValida(SE1->E1_VENCREA,.T.)
										Endif
										Case cPaisLoc=="BRA" .And. ( AllTrim(aStru[nCntFor][1])=="E5_TXMOEDA" ) .And. !lRelat
										If SE1->E1_MOEDA == 1
											(cAlias)->E5_TXMOEDA := 1
										Else
											If SE5->E5_TXMOEDA == 0 
												(cAlias)->E5_TXMOEDA := (SE5->E5_VALOR /SE5->E5_VLMOED2)
											Else
												(cAlias)->E5_TXMOEDA := SE5->E5_TXMOEDA
											Endif
										Endif
										Case ( AllTrim(aStru[nCntFor][1])=="E1_NUMLIQ" )
										If SE5->E5_MOTBX == "LIQ"
											If Empty(SE1->E1_NUMLIQ)
												(cAlias)->E1_NUMLIQ := SUBSTR(SE5->E5_DOCUMEN,1,TamSx3("E1_NUMLIQ")[1])
											Else
												(cAlias)->(FieldPut(nCntFor,SE1->(FieldGet(FieldPos(aStru[nCntFor][1])))))
											Endif
										Endif
										Case ( AllTrim(aStru[nCntFor][1])=="XX_RECNO" )
										(cAlias)->XX_RECNO := SE5->(RecNo())
										Case ( "E5_"$AllTrim(aStru[nCntFor][1]) )
										(cAlias)->(FieldPut(nCntFor,SE5->(FieldGet(FieldPos(aStru[nCntFor][1])))))
										Case ( AllTrim(aStru[nCntFor][1])=="FLAG" )
										OtherWise
										(cAlias)->(FieldPut(nCntFor,SE1->(FieldGet(FieldPos(aStru[nCntFor][1])))))
									EndCase
								Next nCntFor
								(cAlias)->(MsUnLock())
							EndIf
							dbSelectArea("SE5")
							dbSkip()
						EndDo										
					EndIf
					dbSelectArea("SE1")
					dbSkip()					
				EndDo
				#IFDEF TOP
			EndIf					
			#ENDIF
			dbSelectArea(cAlias)
			IndRegua(cAlias,cArquivo,"DTOS(E5_DATA)") 
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Totais da Consulta ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aGet[1] := 0
		aGet[2] := 0
		aGet[3] := 0
		aGet[4] := 0
		aGet[5] := 0
		aTotPag := {{0,1,0,0}} // Totalizador de titulos recebidos por por moeda
		dbSelectArea(cAlias)
		dbGotop()
		FC010TotRc(aGet,cAlias,aTotPag,lRelat)  // Totais de Baixas
		If !lRelat
			nSaldoTit := aGet[2]-aGet[3]
			Aadd(aTotPag,{"","",STR0094,nSaldoTit}) //"Sem baixas"
			// Formata as colunas
			aEval(aTotPag,{|e|	If(ValType(e[VALORTIT]) == "N"	, e[VALORTIT]		:= Transform(e[VALORTIT],Tm(e[VALORTIT],16,nCasas)),Nil),;
			If(ValType(e[VALORREAIS]) == "N"	, e[VALORREAIS]	:= Transform(e[VALORREAIS],Tm(e[VALORREAIS],16,nCasas)),Nil)})
		Endif
		aGet[1] := TransForm(aGet[1],Tm(aGet[1],16,0))
		aGet[2] := TransForm(aGet[2],Tm(aGet[2],16,nCasas))
		aGet[3] := TransForm(aGet[3],Tm(aGet[3],16,nCasas))
		aGet[4] := TransForm(aGet[4],Tm(aGet[4],16,nCasas))
		aGet[5] := TransForm(aGet[5],Tm(aGet[5],16,nCasas))
		//ÚÄÄÄÄÄÄÄÄ¿
		//³Pedidos ³
		//ÀÄÄÄÄÄÄÄÄÙ
		Case ( nBrowse == 3 )
		dbSelectArea("SX3")
		dbSetOrder(2)  

		dbSeek("C5_LOJACLI")
		If aParam[13] == 2  //Considera loja
			aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		Endif
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		
		/*
		GESTAO - inicio */
		dbSeek("C5_FILIAL")
		aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		/* GESTAO - fim
		*/
		dbSeek("C5_NUM")
		aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		dbSeek("C5_EMISSAO")
		aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		dbSeek("C6_VALOR")
		aadd(aHeader,{STR0040,"XX_SLDTOT",SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } ) //"Tot.Pedido"
		aadd(aStru ,{"XX_SLDTOT",SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aHeader,{STR0041,"XX_SLDLIB",SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } ) //"Sld.Liberado"
		aadd(aStru ,{"XX_SLDLIB",SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aHeader,{STR0042,"XX_SLDPED",SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } ) //"Sld.Pedido"
		aadd(aStru ,{"XX_SLDPED",SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aStru,{"XX_RECNO","N",12,0})

		IF lFC010Pedi
			aRetAux := aClone(ExecBlock("FC010PEDI",.F.,.F.,{aClone(aHeader),aClone(aStru)}))
			If ValType(aRetAux) <> "A" .or. Len(aRetAux) <> 2
				aRetAux := {{},{}}
			Else
				aEval(aRetAux[1] , {|x| aAdd(aHeader , x ) })
				aEval(aRetAux[2] , {|x| aAdd(aStru , x ) })
			EndIf
		EndIf

		SX3->(dbSetOrder(1))

		If ( Select(cAlias) ==	0 )
			cArquivo := CriaTrab(,.F.)			
			aadd(aAlias,{ cAlias , cArquivo })
			aadd(aStru,{"FLAG","L",01,0})

			If _oFINC0103 <> Nil
				_oFINC0103:Delete()
				_oFINC0103 := Nil
			Endif

			_oFINC0103 := FWTemporaryTable():New( cAlias )  
			_oFINC0103:SetFields(aStru) 
			_oFINC0103:AddIndex("1", {"C5_FILIAL","C5_NUM"})

			//------------------
			//Criação da tabela temporaria
			//------------------
			_oFINC0103:Create()  

			#IFDEF TOP
			If ( TcSrvType()!="AS/400" )
				cCompSC5 := FWModeAccess("SC5",1) + FWModeAccess("SC5",2) + FWModeAccess("SC5",3)

				//Caso de compartilhamentos idênticos
				If FWModeAccess("SC6",3) == FWModeAccess("SF4",3) .And. FWModeAccess("SC6",2) ==  FWModeAccess("SF4",2) .And. FWModeAccess("SC6",1) ==  FWModeAccess("SF4",1)
					lFilF4C6 := .T.
				EndIf

				IF FWModeAccess("SF4",1) == "C"
					lFilF4 := .T.
				ElseIf FWModeAccess("SC6",3) == "E"
					lFilF4 := .T.
				ElseIf FWModeAccess("SC6",1) == "C" 
					lFilF4 := .F.
				ElseIf FWModeAccess("SF4",2) == "E" .AND. !(FWModeAccess("SF4",3) == "C" .AND. FWModeAccess("SC6",2) == "E")
					lFilF4 := .F.
				Else
					lFilF4 := .T.
				EndIf

				lQuery := .T.
				cQuery := "SELECT SC5.C5_FILIAL,SC5.C5_NUM PEDIDO,SC5.C5_LOJACLI C5_LOJACLI,"
				cQuery += 		  "SC5.C5_EMISSAO EMISSAO," 
				//*************************************
				// Monta campos do ponro de entrada   * 
				// FC010PEDI na tabela temporaria.    *
				//*************************************
				IF lFC010Pedi
					aEval(aRetAux[2] , {|x| cQuery += x[1] + "," })
				EndIf
				cQuery +=  		  "SC5.C5_MOEDA MOEDA,"    
				cQuery +=  		  "SC5.C5_FRETE FRETE,"
				cQuery += 		  "SC5.R_E_C_N_O_ SC5RECNO,"
				cQuery += 		  "(C6_QTDVEN-C6_QTDEMP-C6_QTDENT) QTDVEN,"
				cQuery +=		  "C6_PRCVEN PRCVEN,"
				cQuery +=         "1 TIPO,"
				cQuery +=         "C5_EMISSAO DATALIB," //NAO RETIRAR - POSTGRES
				cQuery +=         "C6_BLQ BLCRED "		//NAO RETIRAR - POSTGRES
				cQuery += "FROM "+RetSqlName("SC5")+" SC5,"
				cQuery +=         RetSqlName("SC6")+" SC6,"
				cQuery +=         RetSqlName("SF4")+" SF4 "
				/*
				GESTAO - inicio */
				nPosAlias := FC010QFil(1,"SC5")
				cQuery += "WHERE SC5.C5_FILIAL " + aTmpFil[nPosAlias,2] + " AND "
				/* GESTAO - fim
				*/
				cQuery += 		"SC5.C5_CLIENTE='"+SA1->A1_COD+"' AND "
				If aParam[13] == 1  //Considera loja
					cQuery +=		"SC5.C5_LOJACLI='"+SA1->A1_LOJA+"' AND "
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Ponto de entrada para filtrar pelo MSFIL em caso de ³
				//³ arquivo compartilhado.  Pedidos                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				If (ExistBlock("F010FLPD"))    
					cQuery += ExecBlock("F010FLPD",.F.,.F.)
				Endif                    

				cQuery +=		"SC5.C5_TIPO NOT IN('D','B') AND "
				cQuery +=		"SC5.C5_EMISSAO >='"+Dtos(aParam[1])+"' AND "
				cQuery +=		"SC5.C5_EMISSAO <='"+Dtos(aParam[2])+"' AND "	
				cQuery +=		"SC5.D_E_L_E_T_ = ' ' AND "
				/*
				GESTAO - inicio */
				If (FWModeAccess("SC6",1) + FWModeAccess("SC6",2) + FWModeAccess("SC6",3)) == cCompSC5
					cQuery += "SC6.C6_FILIAL = SC5.C5_FILIAL AND "
				Else
					nPosAlias := FC010QFil(1,"SC6")
					cQuery += "SC6.C6_FILIAL " + aTmpFil[nPosAlias,2] + " AND "
				Endif
				/* GESTAO - fim
				*/
				cQuery +=		"SC6.C6_NUM=SC5.C5_NUM AND "
				cQuery +=		"SC6.C6_BLQ NOT IN('R ') AND "
				If aParam[10] == 2 // nao considera pedidos com bloqueio
					cQuery +=		"SC6.C6_BLQ NOT IN('S ') AND "
				Endif
				cQuery +=		"(SC6.C6_QTDVEN-SC6.C6_QTDEMP-SC6.C6_QTDENT)>0 AND "
				cQuery +=		"SC6.D_E_L_E_T_ = ' ' AND "

				If lFilF4C6
					cQuery		+=		"SF4.F4_FILIAL=SC6.C6_FILIAL AND "
				Else
					If !lFilF4
						cQuery +=		"SF4.F4_FILIAL='"+xFilial("SF4")+"' AND "
					Else
						cQuery +=		"SF4.F4_FILIAL='"+xFilial("SF4",SC6->C6_FILIAL)+"' AND "
					EndIf
				EndIf

				cQuery +=		"SF4.F4_CODIGO=SC6.C6_TES AND "
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Considera sim, não ou ambos os itens com TES gerando duplicata ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If aParam[14] == 2
					cQuery +=		"SF4.F4_DUPLIC='S' AND "
				ElseIf aParam[14] == 3                   
					cQuery +=		"SF4.F4_DUPLIC='N' AND "
				Endif
				cQuery +=		"SF4.D_E_L_E_T_ = ' ' "
				cQuery += "UNION ALL "
				cQuery += "SELECT C5_FILIAL,C5_NUM PEDIDO,SC5.C5_LOJACLI C5_LOJACLI,"
				cQuery += 		  "C5_EMISSAO EMISSAO,"
				//*************************************
				// Monta campos do ponro de entrada   * 
				// FC010PEDI na tabela temporaria.    *
				//*************************************
				IF lFC010Pedi
					aEval(aRetAux[2] , {|x| cQuery += x[1] + "," })
				EndIf
				cQuery += 		  "C5_MOEDA MOEDA,"
				cQuery +=  		  "C5_FRETE FRETE,"
				cQuery += 		  "SC5.R_E_C_N_O_ SC5RECNO,"					
				cQuery += 		  "C9_QTDLIB QTDVEN,"
				cQuery +=		  "C9_PRCVEN PRCVEN, "
				cQuery +=         "2 TIPO,"										
				cQuery +=		  "C9_DATALIB DATALIB, "
				cQuery +=		  "C9_BLCRED BLCRED "
				cQuery += "FROM "+RetSqlName("SC5")+" SC5,"+RetSqlName("SC6")+" SC6,"
				cQuery +=         RetSqlName("SF4")+" SF4,"+RetSqlName("SC9")+" SC9 "
				/*
				GESTAO - inicio */
				nPosAlias := FC010QFil(1,"SC5")
				cQuery += "WHERE SC5.C5_FILIAL " + aTmpFil[nPosAlias,2] + " AND "
				/* GESTAO - fim
				*/
				cQuery += 		"SC5.C5_CLIENTE='"+SA1->A1_COD+"' AND "
				If aParam[13] == 1  //Considera loja
					cQuery +=		"SC5.C5_LOJACLI='"+SA1->A1_LOJA+"' AND "
				Endif
				cQuery +=		"SC5.C5_TIPO NOT IN('D','B') AND "
				cQuery +=		"SC5.C5_EMISSAO >='"+Dtos(aParam[1])+"' AND "
				cQuery +=		"SC5.C5_EMISSAO <='"+Dtos(aParam[2])+"' AND "						
				cQuery +=		"SC5.D_E_L_E_T_ =  ' ' AND "
				/*
				GESTAO - inicio */
				If (FWModeAccess("SC6",1) + FWModeAccess("SC6",2) + FWModeAccess("SC6",3)) == cCompSC5
					cQuery += "SC6.C6_FILIAL = SC5.C5_FILIAL AND "
				Else
					nPosAlias := FC010QFil(1,"SC6")
					cQuery += "SC6.C6_FILIAL " + aTmpFil[nPosAlias,2] + " AND "
				Endif
				/* GESTAO - fim
				*/
				cQuery +=		"SC6.C6_NUM=SC5.C5_NUM AND "
				cQuery +=		"SC6.D_E_L_E_T_ = ' ' AND "
				cQuery +=		"SC6.C6_BLQ NOT IN('R ') AND "
				If aParam[10] == 2 // nao considera pedidos com bloqueio
					cQuery +=		"SC6.C6_BLQ NOT IN('S ') AND "
				Endif
				/*
				GESTAO - inicio */
				nPosAlias := FC010QFil(1,"SF4")
				cQuery += "SF4.F4_FILIAL " + aTmpFil[nPosAlias,2] + " AND "
				/* GESTAO - fim
				*/
				cQuery +=		"SF4.F4_CODIGO=SC6.C6_TES AND "
				If lFilF4C6
					cQuery		+=		"SF4.F4_FILIAL=SC6.C6_FILIAL AND "
				Else
					If !lFilF4
						cQuery +=		"SF4.F4_FILIAL='"+xFilial("SF4")+"' AND "
					Else
						cQuery +=		"SF4.F4_FILIAL='"+xFilial("SF4",SC6->C6_FILIAL)+"' AND "
					EndIf
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Considera sim, não ou ambos os itens com TES gerando duplicata ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If aParam[14] == 2
					cQuery +=		"SF4.F4_DUPLIC='S' AND "
				ElseIf aParam[14] == 3                   
					cQuery +=		"SF4.F4_DUPLIC='N' AND "
				Endif
				cQuery +=		"SF4.D_E_L_E_T_ = ' ' AND "
				/*
				GESTAO - inicio */
				If (FWModeAccess("SC9",1) + FWModeAccess("SC9",2) + FWModeAccess("SC9",3)) == cCompSC5
					cQuery += "SC9.C9_FILIAL = SC5.C5_FILIAL AND "
				Else
					nPosAlias := FC010QFil(1,"SC9")
					cQuery += "SC9.C9_FILIAL " + aTmpFil[nPosAlias,2] + " AND "
				Endif
				/* GESTAO - fim
				*/
				cQuery +=		"SC9.C9_PEDIDO=SC5.C5_NUM AND "
				cQuery +=		"SC9.C9_ITEM=SC6.C6_ITEM AND "
				cQuery +=		"SC9.C9_PRODUTO=SC6.C6_PRODUTO AND "		
				cQuery +=		"SC9.C9_NFISCAL='"+Space(Len(SC9->C9_NFISCAL))+"' AND "
				cQuery +=		"SC9.D_E_L_E_T_ = ' '"

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Ponto de entrada para alteracao da cQuery na consulta de Pedidos ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (ExistBlock("F010CQPE"))    
					cQuery := ExecBlock("F010CQPE",.F.,.F.,{cQuery})
				Endif 

				cQuery := ChangeQuery(cQuery)
				cQry   := cArquivo+"A"

				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cQry,.T.,.T.)

				TcSetField(cQry,"EMISSAO","D")
				TcSetField(cQry,"DATALIB","D")
				TcSetField(cQry,"TIPO","N",1)
				TcSetField(cQry,"SC5RECNO","N",12,0) 
				TcSetField(cQry,"QTDVEN","N",TamSx3("C6_QTDVEN")[1],TamSx3("C6_QTDVEN")[2])
				TcSetField(cQry,"PRCVEN","N",TamSx3("C6_PRCVEN")[1],TamSx3("C9_PRCVEN")[2]) 

				//*************************************
				// Monta campos do ponro de entrada   * 
				// FC010PEDI na tabela temporaria.    *
				//*************************************
				IF lFC010Pedi
					aEval(aRetAux[2] , {|x| TcSetField(cQry,x[1],x[2],x[3],x[4]) })
				EndIf

				dbSelectArea(cQry)
				bWhile := {|| !Eof() }
				bFiltro:= {|| .T. }
				While ( Eval(bWhile) )				
					If ( Eval(bFiltro) )
						dbSelectArea(cAlias)
						dbSetOrder(1)
						cChave := (cQry)->(C5_FILIAL + PEDIDO)
						If ( !dbSeek(cChave) )
							RecLock(cAlias,.T.)
						Else
							RecLock(cAlias,.F.)
						EndIf
						If ( (cQry)->TIPO == 1 )
							If aParam[13] == 2
								(cAlias)->C5_LOJACLI := (cQry)->C5_LOJACLI
							Endif
							(cAlias)->C5_FILIAL  := (cQry)->C5_FILIAL
							(cAlias)->C5_NUM     := (cQry)->PEDIDO
							(cAlias)->C5_EMISSAO := (cQry)->EMISSAO
							(cAlias)->XX_SLDTOT  += xMoeda((cQry)->QTDVEN*(cQry)->PRCVEN,(cQry)->MOEDA,1,(cQry)->EMISSAO)
							IF EMPTY(cSaldo) .or. cSaldo <> cChave
								(cAlias)->XX_SLDTOT  += xMoeda((cQry)->FRETE,(cQry)->MOEDA,1,(cQry)->EMISSAO)	// Adiciona frete ao total
							ENDIF	
							(cAlias)->XX_SLDLIB  := 0
							(cAlias)->XX_SLDPED  := (cAlias)->XX_SLDTOT
						Else	
							If aParam[13] == 2
								(cAlias)->C5_LOJACLI := (cQry)->C5_LOJACLI
							Endif						
							(cAlias)->C5_FILIAL  := (cQry)->C5_FILIAL
							(cAlias)->C5_NUM     := (cQry)->PEDIDO
							(cAlias)->C5_EMISSAO := (cQry)->EMISSAO						
							If ( Empty((cQry)->BLCRED) )
								(cAlias)->XX_SLDLIB  += xMoeda((cQry)->QTDVEN*(cQry)->PRCVEN,(cQry)->MOEDA,1,(cQry)->DATALIB)
								IF EMPTY(cSaldo) .or. cSaldo <> cChave
									(cAlias)->XX_SLDLIB  += xMoeda((cQry)->FRETE,(cQry)->MOEDA,1,(cQry)->EMISSAO)  // Adiciona frete ao total
								ENDIF
								(cAlias)->XX_SLDTOT  += xMoeda((cQry)->QTDVEN*(cQry)->PRCVEN,(cQry)->MOEDA,1,(cQry)->DATALIB)
								IF EMPTY(cSaldo) .or. cSaldo <> cChave
									(cAlias)->XX_SLDTOT  += xMoeda((cQry)->FRETE,(cQry)->MOEDA,1,(cQry)->EMISSAO)  // Adiciona frete ao total
								ENDIF
							Else
								(cAlias)->XX_SLDTOT  += xMoeda((cQry)->QTDVEN*(cQry)->PRCVEN,(cQry)->MOEDA,1,(cQry)->DATALIB)
								IF EMPTY(cSaldo) .or. cSaldo <> cChave
									(cAlias)->XX_SLDTOT  += xMoeda((cQry)->FRETE,(cQry)->MOEDA,1,(cQry)->EMISSAO)  // Adiciona frete ao total
								ENDIF	
								(cAlias)->XX_SLDPED  += xMoeda((cQry)->QTDVEN*(cQry)->PRCVEN,(cQry)->MOEDA,1,(cQry)->DATALIB)           
								IF Empty (cSaldo) .or. cSaldo <> cChave          
									(cAlias)->XX_SLDPED  += xMoeda((cQry)->FRETE,(cQry)->MOEDA,1,(cQry)->EMISSAO)  // Adiciona frete ao total
								EndIf
							EndIf
						EndIf
						(cAlias)->XX_RECNO := (cQry)->SC5RECNO
						//*************************************
						// Monta campos do ponto de entrada   * 
						// FC010PEDI na tabela temporaria.    *
						//*************************************
						IF lFC010Pedi
							aEval(aRetAux[2] , {|x| (cAlias)->&(x[1]) := (cQry)->&(x[1])  })
						EndIf
						(cAlias)->(MsUnLock())
						cSaldo := cChave
					EndIf
					dbSelectArea(cQry)
					dbSkip()				
				EndDo
				dbSelectArea(cQry)
				dbCloseArea()			
			Else
				#ENDIF
				dbSelectArea("SC5")
				dbSetOrder(3)
				dbSeek(xFilial("SC5")+SA1->A1_COD)
				While ( !Eof() .And. SC5->C5_FILIAL==xFilial("SC5") .And.;
				SC5->C5_CLIENTE == SA1->A1_COD )
					nSalPed := 0
					nSalPedb:= 0
					nSalPedL:= 0
					nQtdPed := 0											
					If ( If(aParam[13] == 1,SC5->C5_LOJACLI == SA1->A1_LOJA,.T.) .And. !(SC5->C5_TIPO $ "DB") .And. SC5->C5_EMISSAO >= aParam[1] .And. C5_EMISSAO <= aParam[2] )
						dbSelectArea("SC6")
						dbSetOrder(1)
						dbSeek(xFilial("SC6")+SC5->C5_NUM)
						While ( !Eof() .And. SC6->C6_FILIAL == xFilial('SC5') .And.;
						SC6->C6_NUM == SC5->C5_NUM )
							If ( !AllTrim(SC6->C6_BLQ) $ "R"+If(aParam[10]==2,"#S",""))
								dbSelectArea("SF4")
								dbSetOrder(1)
								dbSeek(cFilial+SC6->C6_TES)
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Buscar Qtde no arquivo SC9 (itens liberados) p/ A1_SALPEDL³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								dbSelectArea("SC9")
								dbSetOrder(2)
								dbSeek(xFilial("SC9")+SC6->C6_CLI+SC6->C6_LOJA+SC6->C6_NUM+SC6->C6_ITEM)

								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Considera sim, não ou ambos os itens com TES gerando duplicata ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If aParam[14] == 2
									bCond := { || SF4->F4_DUPLIC == "S" }
								ElseIf aParam[14] == 3
									bCond := { || SF4->F4_DUPLIC == "N" }
								Else
									bCond := { || .T.}
								Endif

								If Eval(bCond)
									While ( !Eof() .And. xFilial("SC9") == SC9->C9_FILIAL .And.;
									SC6->C6_CLI == SC9->C9_CLIENTE .And.;
									SC6->C6_LOJA == SC9->C9_LOJA .And.;
									SC6->C6_NUM == SC9->C9_PEDIDO .And.;
									SC6->C6_ITEM == SC9->C9_ITEM )
										If ( Empty(C9_NFISCAL) .And. SC6->C6_PRODUTO==SC9->C9_PRODUTO )
											If ( Empty(SC9->C9_BLCRED) )
												nSalpedl += xMoeda( SC9->C9_QTDLIB * SC9->C9_PRCVEN , SC5->C5_MOEDA , 1 , SC9->C9_DATALIB )
												nSalpedl += xMoeda( SC5->C5_FRETE , SC5->C5_MOEDA , 1 , SC9->C9_DATALIB )
											Else
												nSalpedb += xMoeda( SC9->C9_QTDLIB * SC9->C9_PRCVEN , SC5->C5_MOEDA , 1 , SC9->C9_DATALIB )
												nSalpedb += xMoeda( SC5->C5_FRETE , SC5->C5_MOEDA , 1 , SC9->C9_DATALIB )
											EndIf
										EndIf
										dbSelectArea("SC9")
										dbSkip()
									EndDo
								Endif
								If Eval(bCond)
									nQtdPed := SC6->C6_QTDVEN - SC6->C6_QTDEMP - SC6->C6_QTDENT
									nQtdPed := IIf( nQtdPed < 0 , 0 , nQtdPed )
									nSalped += xMoeda( nQtdPed * SC6->C6_PRCVEN , SC5->C5_MOEDA , 1 , SC5->C5_EMISSAO )
									nSalped += xMoeda( SC5->C5_FRETE , SC5->C5_MOEDA , 1 , SC5->C5_EMISSAO )
								EndIf
							EndIf
							dbSelectArea("SC6")
							dbSkip()
						EndDo
					EndIf
					If ( nSalped+nSalpedl+nSalpedb > 0 )
						RecLock(cAlias,.T.)
						(cAlias)->C5_NUM     := SC5->C5_NUM
						(cAlias)->C5_EMISSAO := SC5->C5_EMISSAO
						(cAlias)->XX_SLDTOT  := nSalPed+nSalPedL+nSalPedb
						(cAlias)->XX_SLDLIB  := nSalPedL
						(cAlias)->XX_SLDPED  := nSalPed+nSalPedb
						(cAlias)->XX_RECNO    := SC5->(RecNo())
						MsUnlock()
					EndIf
					dbSelectArea("SC5")
					dbSkip()
				EndDo
				#IFDEF TOP
			EndIf
			#ENDIF
		EndIf
		dbSelectArea(cAlias)
		dbGotop()
		aGet[1] := 0
		aGet[2] := 0
		aGet[3] := 0
		aGet[4] := 0
		dbEval({|| 	aGet[1]++,;
		aGet[2]+=XX_SLDTOT,;
		aGet[3]+=XX_SLDLIB,;
		aGet[4]+=XX_SLDPED})

		aGet[1] := TransForm(aGet[1],Tm(aGet[1],16,0))
		aGet[2] := TransForm(aGet[2],Tm(aGet[2],16,nCasas))
		aGet[3] := TransForm(aGet[3],Tm(aGet[3],16,nCasas))
		aGet[4] := TransForm(aGet[4],Tm(aGet[3],16,nCasas))	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Notas Fiscais ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Case ( nBrowse == 4 )
		If cPaisLoc == "BRA"
			If aParam[13] == 2 
				aCpos:={"F2_LOJA","F2_FILIAL","F2_SERIE","F2_DOC","F2_NFELETR","F2_EMISSAO","F2_DUPL","F2_VALFAT","F2_FRETE","F2_HORA","F2_TRANSP","A4_NREDUZ"}
			Else
				aCpos:={"F2_FILIAL","F2_SERIE","F2_DOC","F2_NFELETR","F2_EMISSAO","F2_DUPL","F2_VALFAT","F2_FRETE","F2_HORA","F2_TRANSP","A4_NREDUZ"}
			EndIf
		Else
			If aParam[13] == 2 
				aCpos:={"F2_LOJA","F2_FILIAL","F2_SERIE","F2_DOC","F2_NFELETR","F2_EMISSAO","F2_DUPL","F2_VALFAT","F2_FRETE","F2_HORA","F2_TRANSP","A4_NREDUZ"}
			Else
				aCpos:={"F2_FILIAL","F2_SERIE","F2_DOC","F2_EMISSAO","F2_DUPL","F2_VALFAT","F2_FRETE","F2_HORA","F2_TRANSP","A4_NREDUZ","F2_MOEDA","F2_TXMOEDA"}
			EndIf
		EndIf

		If lFC0101FAT
			aAuxCpo := aClone(ExecBlock("FC0101FAT",.F.,.F.,{aCpos}))
			If ValType(aAuxCpo) == "A"
				aCpos := aClone(aAuxCpo)			
			EndIf
		EndIf

		dbSelectArea("SX3")
		dbSetOrder(2)
		For nI := 1 To Len(aCpos)
			dbSeek(aCpos[nI])
			aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
			aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		Next nI

		aadd(aStru,{"XX_RECNO","N",12,0})

		SX3->(dbSetOrder(1))

		If ( Select(cAlias) ==	0 )
			cArquivo := CriaTrab(,.F.)			
			aadd(aAlias,{ cAlias , cArquivo })
			aadd(aStru,{"FLAG","L",01,0})

			If _oFINC0104 <> Nil
				_oFINC0104:Delete()
				_oFINC0104 := Nil
			Endif

			_oFINC0104 := FWTemporaryTable():New( cAlias )  
			_oFINC0104:SetFields(aStru) 
			_oFINC0104:AddIndex("1", {"F2_FILIAL","F2_EMISSAO","F2_SERIE","F2_DOC"})

			//------------------
			//Criação da tabela temporaria
			//------------------
			_oFINC0104:Create()  


			#IFDEF TOP
			cDbMs	 := UPPER(TcGetDb())
			If ( TcSrvType()!="AS/400" .and. cDbMs!="POSTGRES")
				lQuery := .T.

				cQuery := "SELECT SF2.F2_FILIAL,SF2.F2_DOC F2_DOC,"
				cQuery += 		"  SF2.F2_LOJA F2_LOJA,"
				cQuery += 		"  SF2.F2_SERIE F2_SERIE,"
				cQuery += 		"  SF2.F2_EMISSAO F2_EMISSAO,"
				cQuery +=		"  SF2.F2_DUPL F2_DUPL,"	
				cQuery += 		"  SF2.F2_VALFAT F2_VALFAT, "
				cQuery += 		"  SF2.F2_FRETE F2_FRETE, "
				cQuery += 		"  SF2.F2_HORA F2_HORA, "
				cQuery += 		"  SF2.F2_TRANSP F2_TRANSP, "
				If cPaisLoc == "BRA"
					cQuery +=		"  SF2.F2_NFELETR F2_NFELETR,"
				Else
					cQuery +=	"  SF2.F2_MOEDA F2_MOEDA, "
					cQuery +=	"  SF2.F2_TXMOEDA F2_TXMOEDA, "
				EndIf
				/*
				GESTAO - inicio */
				cQuery += 		"  SF2.R_E_C_N_O_ SF2RECNO "
				/* GESTAO - fim
				*/
				If lFC0102FAT
					cQuery += ", " + ExecBlock("FC0102FAT",.F.,.F.) + " "					
				EndIf

				cQuery += "FROM "+RetSqlName("SF2")+" SF2 "
				/*
				GESTAO - inicio */
				nPosAlias := FC010QFil(1,"SF2")
				cQuery += " WHERE SF2.F2_FILIAL " + aTmpFil[nPosAlias,2] + " AND "
				/* GESTAO - fim
				*/
				cQuery += 		" SF2.F2_CLIENTE='"+SA1->A1_COD+"' AND "
				If aParam[13] == 1  //Considera loja
					cQuery +=		" SF2.F2_LOJA='"+SA1->A1_LOJA+"' AND "
				Endif
				cQuery +=		" SF2.F2_TIPO NOT IN('D','B') AND "
				cQuery +=		" SF2.F2_EMISSAO>='"+DTOS(aParam[1])+"' AND "
				cQuery +=		" SF2.F2_EMISSAO<='"+DTOS(aParam[2])+"' AND "

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Ponto de entrada para filtrar pelo MSFIL em caso de ³
				//³ arquivo compartilhado.                              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				If (ExistBlock("FO10FLFT"))    
					cQuery += ExecBlock("FO10FLFT",.F.,.F.)
				Endif                    

				If aParam[14] == 3 // TES Duplic = N
					cQuery +=		" SF2.F2_VALFAT = 0 AND "					
				ElseIf aParam[14] == 2  // TES Duplic = S
					cQuery +=		" SF2.F2_VALFAT > 0 AND "					
				Endif												

				cQuery += " SF2.D_E_L_E_T_ = ' '"
				/*
				GESTAO
				*/
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Ponto de entrada para alteracao da cQuery na consulta Faturamento ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (ExistBlock("F010CQFT"))
					cQuery := ExecBlock("F010CQFT",.F.,.F.,{cQuery})
				Endif

				cQuery := ChangeQuery(cQuery)
				cQry   := cArquivo+"A"

				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cQry,.T.,.T.)

				TcSetField(cQry,"F2_EMISSAO","D")
				TcSetField(cQry,"F2_VALFAT","N",TamSx3("F2_VALFAT")[1],TamSx3("F2_VALFAT")[2])
				TcSetField(cQry,"F2_FRETE","N",TamSx3("F2_FRETE")[1],TamSx3("F2_FRETE")[2])
				TcSetField(cQry,"SF2RECNO","N",12,0)
				If cPaisLoc <> "BRA"
					TcSetField(cQry,"F2_MOEDA","N",TamSx3("F2_MOEDA")[1],TamSx3("F2_MOEDA")[2])
					TcSetField(cQry,"F2_TXMOEDA","N",TamSx3("F2_TXMOEDA")[1],TamSx3("F2_TXMOEDA")[2])
				EndIf                                                                                
			Else
				#ENDIF
				cQry := "SF2"

				#IFDEF TOP
			EndIf
			#ENDIF
			aGet[1] := 0
			aGet[2] := 0
			dbSelectArea(cQry)
			If ( !lQuery )
				dbSetOrder(2)
				If aParam[13] == 1  //Considera loja
					dbSeek(xFilial("SF2")+SA1->A1_COD+SA1->A1_LOJA)
					bWhile := {|| !Eof() .And. xFilial("SF2") == SF2->F2_FILIAL .And.;
					SA1->A1_COD == SF2->F2_CLIENTE .And.;
					SA1->A1_LOJA == SF2->F2_LOJA }
				Else                                
					dbSeek(xFilial("SF2")+SA1->A1_COD)
					bWhile := {|| !Eof() .And. xFilial("SF2") == SF2->F2_FILIAL .And.;
					SA1->A1_COD == SF2->F2_CLIENTE}
				Endif
				If aParam[14] == 3 // TES Duplic = N
					bFiltro:= {|| !SF2->F2_TIPO$"DB" .And.;
					SF2->F2_EMISSAO >= aParam[1]     .And.;
					SF2->F2_EMISSAO <= aParam[2]	 .And.;
					SF2->F2_VALFAT  =  0}
				ElseIf aParam[14] == 2  // TES Duplic = S
					bFiltro:= {|| !SF2->F2_TIPO$"DB" .And.;
					SF2->F2_EMISSAO >= aParam[1] .And.;
					SF2->F2_EMISSAO <= aParam[2] .And.;
					SF2->F2_VALFAT  >  0}
				Else // TES Duplic = Todas
					bFiltro:= {|| !SF2->F2_TIPO$"DB" .And.;
					SF2->F2_EMISSAO >= aParam[1] .And.;
					SF2->F2_EMISSAO <= aParam[2]}				
				Endif											
			Else
				bWhile := {|| !Eof() }
				bFiltro:= {|| .T. }
			EndIf			
			While ( Eval(bWhile) )				
				If ( Eval(bFiltro) )
					If !lQuery
						// Se nao for query, posiciona SA4 para obter o nome da transportadora
						SA4->(MsSeek(xFilial("SA4")+SF2->F2_TRANSP))
						Else		/* GESTAO */
						SA4->(MsSeek(xFilial("SA4",(cQry)->F2_FILIAL) + (cQry)->F2_TRANSP))
					Endif
					RecLock(cAlias,.T.)
					If aParam[13] == 2
						(cAlias)->F2_LOJA  	 := (cQry)->F2_LOJA
					EndIf 
					(cAlias)->F2_FILIAL  := (cQry)->F2_FILIAL					
					(cAlias)->F2_SERIE   := (cQry)->F2_SERIE
					(cAlias)->F2_DOC     := (cQry)->F2_DOC
					(cAlias)->F2_EMISSAO := (cQry)->F2_EMISSAO
					(cAlias)->F2_DUPL    := (cQry)->F2_DUPL
					(cAlias)->F2_VALFAT  := (cQry)->F2_VALFAT
					(cAlias)->F2_FRETE   := (cQry)->F2_FRETE
					(cAlias)->F2_HORA    := (cQry)->F2_HORA
					(cAlias)->F2_TRANSP  := (cQry)->F2_TRANSP
					If cPaisLoc == "BRA"
						(cAlias)->F2_NFELETR := (cQry)->F2_NFELETR
					Else
						(cAlias)->F2_MOEDA    := (cQry)->F2_MOEDA
						(cAlias)->F2_TXMOEDA  := (cQry)->F2_TXMOEDA
					EndIf
					(cAlias)->A4_NREDUZ  := SA4->A4_NREDUZ
					(cAlias)->XX_RECNO   := If(lQuery,(cQry)->SF2RECNO,SF2->(RecNo()))
					(cAlias)->(MsUnLock())
					If lFC0103FAT
						ExecBlock("FC0103FAT",.F.,.F.,{cAlias,cQry})					
					EndIf
				EndIf
				dbSelectArea(cQry)
				dbSkip()				
			EndDo
			If ( lQuery )
				dbSelectArea(cQry)
				dbCloseArea()
			EndIf
		EndIf		
		aGet[1] := 0
		aGet[2] := 0
		dbSelectArea(cAlias)
		dbGotop()
		If cPaisLoc == "BRA"
			dbEval({|| aGet[1]++,aGet[2]+=F2_VALFAT})
		Else 
			dbEval({|| aGet[1]++,aGet[2]+=Iif(F2_MOEDA == 1,F2_VALFAT,xMoeda(F2_VALFAT,F2_MOEDA,1,F2_EMISSAO,MsDecimais(1),F2_TXMOEDA))})			
		EndIf
		aGet[1] := TransForm(aGet[1],Tm(aGet[1],16,0))
		aGet[2] := TransForm(aGet[2],Tm(aGet[2],16,nCasas))			

		//CHEQUES
		Case (nBrowse == 5)
		DEFINE MSDIALOG oCheq FROM   15,1 TO 170,272 TITLE STR0072 PIXEL //"Seleccion de parametros"
		@ 6 , 12 TO 65, 93 OF oCheq   LABEL STR0073 PIXEL //"Tipos de cheques a exhibir"

		If cPaisLoc$"ARG|COS"
			@ 13, 13 RADIO oTipo VAR nTipo ;
			PROMPT STR0062,STR0064,If(cPaisLoc="ARG",STR0088,STR0063),STR0134,STR0074 ;  //"Pendientes"###"Cobrados"###"Negociados"###"Transito"###"Todos"
			OF oCheq PIXEL SIZE 75,12
		Else
			@ 13, 13 RADIO oTipo VAR nTipo ;
			PROMPT STR0062,STR0064,If(cPaisLoc$"URU|BOL",STR0088,STR0063),STR0074 ;  //"Pendientes"###"Cobrados"###"Negociados"###"Todos"
			OF oCheq PIXEL SIZE 75,12
		Endif

		DEFINE SBUTTON FROM 45, 100 TYPE 1 ACTION oCheq:End() ENABLE OF oCheq //11,132
		ACTIVATE MSDIALOG oCheq CENTERED

		Do case
			Case nTipo 	== 	1
			bTipo	:=	{ || (cQry)->E1_SALDO > 0 }
			Case nTipo	==	2
			bTipo	:=	{ || !(FN022SITCB((cQry)->E1_SITUACA)[1]) .And. (cQry)->E1_SALDO == 0 }
			Case nTipo	==	3
			bTipo	:=	{ || (cQry)->E1_STATUS == "R" .And. FN022SITCB((cQry)->E1_SITUACA)[1] .And. (cQry)->E1_SALDO == 0}
			Case nTipo	==	4
			If cPaisLoc $ "ARG/COS"			
				bTipo	:=	{ || (cQry)->EL_TIPODOC $ cCheques .And. (cQry)->EL_TRANSIT == '1' .And. (cQry)->EL_DTENTRA == CTOD("//")}
			Else
				bTipo	:=	{ || .T. }
			Endif
			Case nTipo == 5	//Apenas ARG e COS
			bTipo	:=	{ || .T. }

		EndCase

		nMoeda := 1
		dbSelectArea("SX3")
		dbSetOrder(2)
		dbSeek("E1_STATUS")
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		aadd(aHeader,{AllTrim(X3TITULO()),"XX_ESTADO","@!",04,0,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aadd(aStru,{"XX_ESTADO","C",04,0})
		/*
		GESTAO - inicio */
		dbSeek("E1_FILORIG")
		If !lRelat
			nTamFil := Len(SM0->(AllTrim(M0_CODFIL) + " - " + M0_NOME))
		else
			nTamFil := Len(SM0->(AllTrim(M0_CODFIL)))
		Endif
		aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,nTamFil,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,nTamFil,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,nTamFil,SX3->X3_DECIMAL})
		/* GESTAO - fim
		*/
		dbSeek("E1_PREFIXO")
		aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		dbSeek("E1_NUM")
		aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		dbSeek("E1_PARCELA")
		aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		dbSeek("E1_NUMNOTA")
		aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		dbSeek("E1_EMISSAO")
		aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		dbSeek("E1_VALOR")
		aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		dbSeek("E1_SALDO")
		aadd(aHeader,{ AllTrim(X3TITULO()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		dbSeek("E1_MOEDA")
		aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		dbSeek("E1_VLCRUZ")
		aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		dbSeek("E1_VENCREA")
		aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		dbSeek("E1_NATUREZ")
		aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		dbSeek("E1_PORTADO")
		aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		dbSeek("E1_BCOCHQ")
		aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		dbSeek("E1_HIST")
		aadd(aHeader,{ AllTrim(X3TITULO()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		//sitcob
		dbSeek("E1_SITUACA")
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aHeader,{STR0045,"FRV_DESCRI","@!",40,0,"","","C","FRV","" } ) //"Situacao"
		aadd(aStru,{"FRV_DESCRI","C",40,0})

		aadd(aStru,{"XX_RECNO" ,"N",12,0})
		aadd(aStru,{"XX_VALOR" ,"N",18,0})

		SX3->(dbSetOrder(1))

		cArquivo := CriaTrab(,.F.)			
		If !lExibe
			aadd(aAlias,{ cAlias , cArquivo })
		Endif
		aadd(aStru,{"FLAG","L",01,0})

		If _oFINC0105 <> Nil
			_oFINC0105:Delete()
			_oFINC0105 := Nil
		Endif

		_oFINC0105 := FWTemporaryTable():New( cAlias )  
		_oFINC0105:SetFields(aStru) 
		_oFINC0105:AddIndex("1", {"E1_PREFIXO","E1_NUM","E1_PARCELA"})

		//------------------
		//Criação da tabela temporaria
		//------------------
		_oFINC0105:Create()

		lNoChqTran := IIF(cPaisLoc $ "ARG|COS", (nTipo != 4) , .T.)
		If lnoChqTran

			#IFDEF TOP
			If ( TcSrvType()!="AS/400" )
				lQuery := .T.
				cQuery := ""
				aEval(aQuery,{|x| cQuery += ","+AllTrim(x[1])})
				cQuery := "SELECT "+SubStr(cQuery,2)
				cQuery +=         ",SE1.R_E_C_N_O_ SE1RECNO"
				cQuery +=         ",FRV.FRV_DESCRI "
				cQuery += "FROM "+RetSqlName("SE1")+" SE1,"
				cQuery +=         RetSqlName("FRV")+" FRV "
				/*
				GESTAO - inicio */
				nPosAlias := FC010QFil(1,"SE1")
				cQuery += " WHERE SE1.E1_FILIAL " + aTmpFil[nPosAlias,2] + " AND "
				/* GESTAO - fim
				*/
				cQuery +=      "SE1.E1_CLIENTE='"+SA1->A1_COD+"' AND "
				If aParam[13] == 1  //Considera loja
					cQuery +=      "SE1.E1_LOJA='"+SA1->A1_LOJA+"' AND "
				Endif
				cQuery +=		"SE1.E1_EMISSAO>='"+Dtos(aParam[1])+"' AND "
				cQuery +=		"SE1.E1_EMISSAO<='"+Dtos(aParam[2])+"' AND "
				cQuery +=		"SE1.E1_VENCREA>='"+Dtos(aParam[3])+"' AND "
				cQuery +=		"SE1.E1_VENCREA<='"+Dtos(aParam[4])+"' AND "
				cQuery +=		"SE1.E1_TIPO IN" + FormatIn(cCheques,"|") + " AND "
				cQuery +=		"SE1.E1_PREFIXO>='"+aParam[6]+"' AND "
				cQuery +=		"SE1.E1_PREFIXO<='"+aParam[7]+"' AND "
				cQuery +=		"SE1.D_E_L_E_T_ = ' ' AND "
				cQuery +=		"FRV.FRV_FILIAL = '"+xFilial("FRV")+"' AND "		//SITCOB
				cQuery +=		"FRV.FRV_CODIGO = SE1.E1_SITUACA AND "
				cQuery +=		"FRV.D_E_L_E_T_ = ' '"            

				cQuery := ChangeQuery(cQuery)
				cQry   := cArquivo+"A"

				MsAguarde({ || dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cQry,.T.,.T.)},STR0065) //"Seleccionado registros en el servidor"

				aEval(aQuery,{|x| If(x[2]!="C",TcSetField(cQry,x[1],x[2],x[3],x[4]),Nil)})
			Else
				#ENDIF
				cQry := "SE1"
				#IFDEF TOP
			EndIf
			#ENDIF

			dbSelectArea(cQry)
			If ( !lQuery )
				dbSetOrder(2)

				If aParam[13] == 1  //Considera loja
					dbSeek(xFilial("SE1")+SA1->A1_COD+SA1->A1_LOJA)
					bWhile := {|| !Eof() .And. xFilial("SE1") == SE1->E1_FILIAL .And.;
					SA1->A1_COD    == SE1->E1_CLIENTE .And.;
					SA1->A1_LOJA   == SE1->E1_LOJA }
				Else
					dbSeek(xFilial("SE1")+SA1->A1_COD)
					bWhile := {|| !Eof() .And. xFilial("SE1") == SE1->E1_FILIAL .And.;
					SA1->A1_COD    == SE1->E1_CLIENTE}			
				Endif
				bFiltro:= {|| 	SE1->E1_EMISSAO >= aParam[1] .And.;
				SE1->E1_EMISSAO <= aParam[2] .And.;
				SE1->E1_VENCREA >= aParam[3] .And.;
				SE1->E1_VENCREA <= aParam[4] .And.;
				SE1->E1_TIPO	 $ cCheques .And.;
				SE1->E1_PREFIXO >= aParam[6] .And.;
				SE1->E1_PREFIXO <= aParam[7]}
			Else
				bWhile := {|| !Eof() }
				bFiltro:= {|| .T. }
			EndIf			

			While ( Eval(bWhile) )			
				If ( Eval(bFiltro) ) .And. Eval(bTipo)
					dbSelectArea(cAlias)
					dbSetOrder(1)
					cChave := (cQry)->(E1_PREFIXO)+(cQry)->(E1_NUM)+(cQry)->(E1_PARCELA)
					If ( !dbSeek(cChave) )
						RecLock(cAlias,.T.)						
					Else
						RecLock(cAlias,.F.)
					EndIf
					For nCntFor := 1 To Len(aStru)
						Do Case
							//SITCOB
							Case ( AllTrim(aStru[nCntFor][1])=="FRV_DESCRI" )
							If ( lQuery )
								(cAlias)->FRV_DESCRI := FN022SITCB((cQry)->E1_SITUACA)[9]	
							Else
								(cAlias)->FRV_DESCRI := FN022SITCB(SE1->E1_SITUACA)[9]	
							EndIf

							Case ( AllTrim(aStru[nCntFor][1])=="XX_ESTADO" )
							If lQuery
								If (cQry)->E1_SALDO > 0
									(cAlias)->XX_ESTADO := STR0066 //"PEND"
								ElseIf (cQry)->E1_STATUS == "R" .And. FN022SITCB((cQry)->E1_SITUACA)[1]		//(cQry)->E1_SITUACA $ "0FG"
									(cAlias)->XX_ESTADO := If(cPaisLoc$"URU|BOL|ARG",STR0089,STR0067) //"NEGO"
								Else									
									(cAlias)->XX_ESTADO := STR0068 //"COBR"
								Endif
							Else
								If SE1->E1_SALDO > 0
									(cAlias)->XX_ESTADO := STR0066 //"PEND"
								ElseIf SE1->E1_STATUS == "R" .And. FN022SITCB((cQry)->E1_SITUACA)[1]		//SE1->E1_SITUACA $ "0FG"
									(cAlias)->XX_ESTADO := IIf(cPaisLoc$"URU|BOL|ARG",STR0089,STR0067) //"NEGO"
								Else									
									(cAlias)->XX_ESTADO := STR0068 //"COBR"
								Endif
							Endif
							Case ( AllTrim(aStru[nCntFor][1])=="XX_RECNO" )
							If ( lQuery )
								(cAlias)->XX_RECNO := (cQry)->SE1RECNO
							Else
								(cAlias)->XX_RECNO := SE1->(RecNo())
							EndIf
							Case ( AllTrim(aStru[nCntFor][1])=="XX_VALOR" )
							If ( lQuery )
								(cAlias)->XX_VALOR := xMoeda((cQry)->E1_VALOR,(cQry)->E1_MOEDA,nMoeda,,,If(cPaisLoc=="BRA",(cQry)->E1_TXMOEDA,0))
							Else
								(cAlias)->XX_VALOR := xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,nMoeda,,,If(cPaisLoc=="BRA",SE1->E1_TXMOEDA,0))
							EndIf
							Case ( AllTrim(aStru[nCntFor][1])=="FLAG" )

							OtherWise							
							(cAlias)->(FieldPut(nCntFor,(cQry)->(FieldGet(FieldPos(aStru[nCntFor][1])))))
						EndCase
					Next nCntFor
					dbSelectArea(cAlias)
					MsUnLock()
				EndIf
				dbSelectArea(cQry)
				dbSkip()				
			EndDo
		Endif

		//Cheques em transito
		If cPaisLoc $ "ARG/COS" .and. (nTipo == 4 .or. nTipo == 5)

			#IFDEF TOP
			If ( TcSrvType()!="AS/400" )

				aQuery := SEL->(dbStruct())				

				lQuery := .T.
				cQuery := "SELECT "
				cQuery += "EL_FILIAL,EL_PREFIXO,EL_NUMERO,EL_PARCELA,EL_EMISSAO,EL_VALOR,EL_VALOR,EL_MOEDA,EL_VLMOED1,"
				cQuery += "EL_DTVCTO,EL_NATUREZ,EL_BANCO,EL_BCOCHQ,El_TXMOEDA,EL_TIPODOC,EL_TRANSIT,EL_DTENTRA,"
				cQuery += "SEL.R_E_C_N_O_ SELRECNO "
				cQuery += "FROM "+RetSqlName("SEL")+" SEL "
				/*
				GESTAO - inicio */
				nPosAlias := FC010QFil(1,"SEL")
				cQuery += " WHERE SEL.EL_FILIAL " + aTmpFil[nPosAlias,2] + " AND "
				/* GESTAO - fim
				*/
				cQuery += "SEL.EL_CLIENTE='"+SA1->A1_COD+"' AND "
				If aParam[13] == 1  //Considera loja
					cQuery +=      "SEL.EL_LOJA='"+SA1->A1_LOJA+"' AND "
				Endif
				cQuery +=  "SEL.EL_EMISSAO >= '"+Dtos(aParam[1])+"' AND "
				cQuery +=  "SEL.EL_EMISSAO <= '"+Dtos(aParam[2])+"' AND "
				cQuery +=  "SEL.EL_DTVCTO  >= '"+Dtos(aParam[3])+"' AND "
				cQuery +=  "SEL.EL_DTVCTO  <= '"+Dtos(aParam[4])+"' AND "
				cQuery +=  "SEL.EL_TIPODOC IN " + FormatIn(cCheques,"|") + " AND "
				cQuery +=  "SEL.EL_PREFIXO >= '"+aParam[6]+"' AND "
				cQuery +=  "SEL.EL_PREFIXO <= '"+aParam[7]+"' AND "
				cQuery +=  "SEL.D_E_L_E_T_ = ' ' AND "
				cQuery +=  "SEL.EL_TRANSIT = '1' AND "
				cQuery +=  "SEL.EL_DTENTRA = ' ' "				

				cQuery := ChangeQuery(cQuery)
				cQry   := cArquivo+"B"

				MsAguarde({ || dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cQry,.T.,.T.)},STR0065) //"Seleccionado registros en el servidor"

				aEval(aQuery,{|x| If(x[2]!="C",TcSetField(cQry,x[1],x[2],x[3],x[4]),Nil)})
			Else
				#ENDIF
				cQry := "SEL"
				#IFDEF TOP
			EndIf
			#ENDIF

			dbSelectArea(cQry)

			If ( !lQuery )
				SEL->(dbSetOrder(7))

				If aParam[13] == 1  //Considera loja
					dbSeek(xFilial("SEL")+SA1->A1_COD+SA1->A1_LOJA)
					bWhile := {|| !Eof() .And. xFilial("SEL") == SEL->EL_FILIAL .And.;
					SA1->A1_COD    == SEL->EL_CLIENTE .And.;
					SA1->A1_LOJA   == SEL->EL_LOJA }
				Else
					dbSeek(xFilial("SEL")+SA1->A1_COD)
					bWhile := {|| !Eof() .And. xFilial("SEL") == SEL->EL_FILIAL .And.;
					SA1->A1_COD    == SE1->EL_CLIENTE}			
				Endif
				bFiltro:= {|| 	SEL->EL_EMISSAO >= aParam[1] .And.;
				SEL->EL_EMISSAO <= aParam[2] .And.;
				SEL->EL_DTVCTO  >= aParam[3] .And.;
				SEL->EL_DTVCTO <= aParam[4] .And.;
				SEL->EL_TIPODOC	 $ cCheques .And.;
				SEL->EL_PREFIXO >= aParam[6] .And.;
				SEL->EL_PREFIXO <= aParam[7] .And.;
				SEL->EL_TRANSIT == '1' }

			Else
				bWhile := {|| !Eof() }
				bFiltro:= {|| .T. }
			EndIf			

			While ( Eval(bWhile) )				
				If ( Eval(bFiltro) ) .And. Eval(bTipo)
					dbSelectArea(cAlias)
					dbSetOrder(1)

					RecLock(cAlias,.T.)						
					(cAlias)->XX_ESTADO  := "TRAN" 
					(cAlias)->E1_FILORIG := (cQry)->EL_FILIAL 
					(cAlias)->E1_PREFIXO := (cQry)->EL_PREFIXO
					(cAlias)->E1_NUM 	 := (cQry)->EL_NUMERO
					(cAlias)->E1_PARCELA := (cQry)->EL_PARCELA
					(cAlias)->E1_NUMNOTA := ""
					(cAlias)->E1_EMISSAO := (cQry)->EL_EMISSAO
					(cAlias)->E1_VALOR   := (cQry)->EL_VALOR
					(cAlias)->E1_SALDO   := (cQry)->EL_VALOR
					(cAlias)->E1_MOEDA   := Val((cQry)->EL_MOEDA)
					(cAlias)->E1_VLCRUZ  := (cQry)->EL_VLMOED1
					(cAlias)->E1_VENCREA := (cQry)->EL_DTVCTO
					If !lRelat
						(cAlias)->E1_NATUREZ := (cQry)->EL_NATUREZ
					EndIf
					(cAlias)->E1_PORTADO := (cQry)->EL_BANCO
					(cAlias)->E1_BCOCHQ  := (cQry)->EL_BCOCHQ
					(cAlias)->E1_HIST    := "CHQ EM TRANSITO" 

					If ( lQuery )
						(cAlias)->XX_RECNO   := (cQry)->SELRECNO
						(cAlias)->XX_VALOR   := xMoeda((cQry)->EL_VALOR,VAL((cQry)->EL_MOEDA),nMoeda )
					Else
						(cAlias)->XX_RECNO := SEL->(RecNo())
						(cAlias)->XX_VALOR := xMoeda(SEL->EL_VALOR,Val(SEL->EL_MOEDA),nMoeda)
					Endif

					(cAlias)->(MsUnLock())

				EndIf
				dbSelectArea(cQry)
				dbSkip()				
			EndDo
		Endif	

		If ( lQuery )
			dbSelectArea(cQry)
			dbCloseArea()
		EndIf                                              
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Totais da Consulta ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea(cAlias)
		dbGotop()
		aGet	:=	{0,0,0,0,0,0,0,0}
		While !EOF()
			DO CASE
				CASE XX_ESTADO	==	STR0066 //"PEND"
				aGet[1]	+=	(cAlias)->E1_SALDO
				aGet[4]++
				CASE XX_ESTADO	==	If(cPaisLoc$"URU|BOL|ARG",STR0089,STR0067) //"NEGO"
				aGet[2]	+=	(cAlias)->XX_VALOR
				aGet[5]++
				CASE XX_ESTADO	==	STR0068 //"COBR"
				aGet[3]	+=	(cAlias)->XX_VALOR
				aGet[6]++
				CASE XX_ESTADO	==	STR0135 //"TRAN"
				aGet[7]	+=	(cAlias)->XX_VALOR
				aGet[8]++

			EndCase				 	
			dbSkip()
		Enddo
		If lExibe
			aGet[1] := TransForm(aGet[1],Tm(aGet[1],16,MsDecimais(nMoeda))) + " (" +Alltrim(STR(aGet[4]))+")"
			aGet[2] := TransForm(aGet[2],Tm(aGet[2],16,MsDecimais(nMoeda))) + " (" +Alltrim(STR(aGet[5]))+")"
			aGet[3] := TransForm(aGet[3],Tm(aGet[3],16,MsDecimais(nMoeda))) + " (" +Alltrim(STR(aGet[6]))+")"
			aGet[4] := TransForm(aGet[7],Tm(aGet[7],16,MsDecimais(nMoeda))) + " (" +Alltrim(STR(aGet[8]))+")"
			aGet[5] := STR0069+GetMv("MV_MOEDA1") //"Valores en "  
			aGet[6] := ""
		EndIf
		Otherwise
		Alert(STR0060)		//Não Implementado
		lExibe := .f.
	EndCase	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exibe os dados Gerados ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( lExibe )
		dbSelectArea(cAlias)
		dbGotop()
		If ( !Eof() )

			aObjects := {} 
			AAdd( aObjects, { 100, 35,  .t., .f., .t. } )
			AAdd( aObjects, { 100, 100 , .t., .t. } )
			AAdd( aObjects, { 100, 50 , .t., .f. } )

			aInfo    := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 } 
			aPosObj1 := MsObjSize( aInfo, aObjects) 

			DEFINE FONT oBold    NAME "Arial" SIZE 0, -12 BOLD

			DEFINE MSDIALOG oDlg FROM	aSize[7],0 TO aSize[6],aSize[5] TITLE cCadastro OF oMainWnd PIXEL
			@ aPosObj1[1,1], aPosObj1[1,2] MSPANEL oScrPanel PROMPT "" SIZE aPosObj1[1,3],aPosObj1[1,4] OF oDlg LOWERED

			@ 04,004 SAY OemToAnsi(STR0006) SIZE 025,07          OF oScrPanel PIXEL //"Codigo"
			@ 12,004 SAY SA1->A1_COD  SIZE 060,09  OF oScrPanel PIXEL FONT oBold

			If aParam[13] == 1  //Considera loja		
				@ 04,067 SAY OemToAnsi(STR0007) SIZE 020,07          OF oScrPanel PIXEL //"Loja"
				@ 12,067 SAY SA1->A1_LOJA SIZE 021,09 OF oScrPanel PIXEL FONT oBold
			Endif

			@ 04,090 SAY OemToAnsi(STR0008) SIZE 025,07 OF oScrPanel PIXEL //"Nome"
			
			If RetGlbLGPD("A1_NOME")
				@ 12,090 SAY Replicate("*", TamSx3("A1_NOME")[1]) SIZE 165,09 OF oScrPanel PIXEL FONT oBold
			Else
				@ 12,090 SAY SA1->A1_NOME SIZE 165,09 OF oScrPanel PIXEL FONT oBold
			Endif

			oGetDb:=MsGetDB():New(aPosObj1[2,1],aPosObj1[2,2],aPosObj1[2,3],aPosObj1[2,4],2,"",,,.F.,,,.F.,,cAlias,,,,,,.T.)
			oGetdb:lDeleta:=NIL
			dbSelectArea(cAlias)
			dbGotop()

			@ aPosObj1[3,1]+04,005 SAY aSay[1] SIZE 045,07 OF oDlg PIXEL
			If nBrowse <> 2
				@ aPosObj1[3,1]+04,175 SAY aSay[2] SIZE 045,07 OF oDlg PIXEL
				@ aPosObj1[3,1]+15,005 SAY aSay[3] SIZE 045,07 OF oDlg PIXEL
				@ aPosObj1[3,1]+15,175 SAY aSay[4] SIZE 045,07 OF oDlg PIXEL
				@ aPosObj1[3,1]+26,005 SAY aSay[5] SIZE 045,07 OF oDlg PIXEL
				@ aPosObj1[3,1]+26,175 SAY aSay[6] SIZE 045,07 OF oDlg PIXEL
			Else
				@ aPosObj1[3,1]+04,175 SAY aSay[2] SIZE 045,07 OF oDlg PIXEL
				@ aPosObj1[3,1]+15,175 SAY aSay[3] SIZE 045,07 OF oDlg PIXEL
				@ aPosObj1[3,1]+04,345 SAY aSay[4] SIZE 045,07 OF oDlg PIXEL
				@ aPosObj1[3,1]+15,345 SAY aSay[5] SIZE 045,07 OF oDlg PIXEL
			EndIf

			@ aPosObj1[3,1]+04,060 SAY aGet[1] SIZE 060,07 OF oDlg PIXEL
			If nBrowse <> 2
				@ aPosObj1[3,1]+04,215 SAY aGet[2] SIZE 060,07 OF oDlg PIXEL
				@ aPosObj1[3,1]+15,060 SAY aGet[3] SIZE 060,07 OF oDlg PIXEL
				@ aPosObj1[3,1]+15,215 SAY aGet[4] SIZE 060,07 OF oDlg PIXEL
				@ aPosObj1[3,1]+26,060 SAY aGet[5] SIZE 060,07 OF oDlg PIXEL
				@ aPosObj1[3,1]+26,215 SAY aGet[6] SIZE 060,07 OF oDlg PIXEL
			Else
				@ aPosObj1[3,1]+04,215 SAY aGet[2] SIZE 060,07 OF oDlg PIXEL
				@ aPosObj1[3,1]+15,215 SAY aGet[3] SIZE 060,07 OF oDlg PIXEL
				@ aPosObj1[3,1]+04,395 SAY aGet[4] SIZE 060,07 OF oDlg PIXEL
				@ aPosObj1[3,1]+15,395 SAY aGet[5] SIZE 060,07 OF oDlg PIXEL
			EndIf
			If ( nBrowse == 1 ) // Para titulos em aberto, mostra legenda.
				Fc010Legenda(oDlg,aPosObj1,aSay,aGet)
			Endif

			DEFINE SBUTTON 		FROM 04,aPosObj1[1,3]-If(nBrowse <= 2,60,30) TYPE  1  ENABLE OF oScrPanel ACTION ( oDlg:End() )
			// Exibe o botao de distribuicao por moedas, apenas na consulta de titulos
			// em aberto e recebidos
			If nBrowse <= 2
				SButton():New(04, aPosObj1[1,3]-30, 18,{||Fc010Moeda(If(nBrowse==1,aTotRec,aTotPag),oScrPanel)},oScrPanel,.T.,STR0097) //"Consulta distribuição por moedas"
				TButton():New(19, aPosObj1[1,3]-60,'Excel',oScrPanel,{||Fc010Excel(cAlias,aHeader,aParam,nBrowse)},26,10,,,,.T.) 			
			Endif	

			DEFINE SBUTTON oBtn 	FROM 19,aPosObj1[1,3]-30 TYPE 15 ENABLE OF oScrPanel

			oBtn:lAutDisable := .F.
			If ( bVisual != Nil )
				oBtn:bAction := bVisual
			Else
				oBtn:SetDisable(.T.)
			EndIf
			ACTIVATE MSDIALOG oDlg
		Else
			Help(" ",1,"REGNOIS")	
		EndIf
		If nBrowse == 5
			(cAlias)->(dbCloseArea()) //;Ferase(cArquivo+GetDBExtension());Ferase(cArquivo+OrdBagExt())
			If _oFINC0105 <> Nil
				_oFINC0105:Delete()
				_oFINC0105 := Nil
			Endif
		Endif
	EndIf

		
	CtbTmpErase(cTmpFil)
	CtbTmpErase(cTmpFK7)	

	RestArea(aAreaSC5)
	RestArea(aAreaSC6)
	RestArea(aAreaSC9)
	RestArea(aAreaSF4)
	RestArea(aArea)
	
Return(aHeader)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³fc010Visua³ Autor ³Eduardo Riera  		³ Data ³04/01/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Funcao de Visualizacao dos Itens individuais da Posicao de  ³±±
±±³          ³Cliente.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³Fc010Visua()        						     			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1		: Recno do Arquivo principal                      ³±±
±±³          ³ExpN2		: nBrowse                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINC010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fc010Visua(nRecno,nBrowse)

	Local aArea := GetArea()
	Local aAreaSE1 := SE1->(GetArea())
	Local aAreaSE5 := SE5->(GetArea())
	Local aAreaSC5 := SC5->(GetArea())
	Local aSavAhead:= If(Type("aHeader")=="A",aHeader,{})
	Local aSavAcol := If(Type("aCols")=="A",aCols,{})
	Local nSavN    := If(Type("N")=="N",N,0)
	Local cFilBkp  := cFilAnt 

	Do Case
		Case ( nBrowse == 1 )
		SE1->(MsGoto(nRecno))
		// Modifica a filial para visualizacao atraves da funcao AxVisual
		cFilAnt := IIf(cFilAnt <> SE1->E1_FILIAL .And. !Empty(cFilAnt),SE1->E1_FILIAL,cFilAnt)	
		SE1->(AxVisual("SE1",nRecNo,2))

		Case ( nBrowse == 2 )
		SE5->(MsGoto(nRecno))
		// Modifica a filial para visualizacao atraves da funcao AxVisual
		cFilAnt := IIf(cFilAnt <> SE5->E5_FILIAL .And. !Empty(cFilAnt),SE5->E5_FILIAL,cFilAnt)
		SE5->(AxVisual("SE5",nRecNo,2))

		Case ( nBrowse == 3 )
		SC5->(MsGoto(nRecno))		
		// Modifica a filial para visualizacao atraves da funcao AxVisual
		cFilAnt := IIf(cFilAnt <> SC5->C5_FILIAL .And. !Empty(cFilAnt),SC5->C5_FILIAL,cFilAnt)
		SC5->(a410Visual("SC5",nRecNo,2))

		Case ( nBrowse == 4 )
		SF2->(MsGoto(nRecno))
		// Modifica a filial para visualizacao atraves da funcao AxVisual
		cFilAnt := IIf(cFilAnt <> SF2->F2_FILIAL .And. !Empty(cFilAnt),SF2->F2_FILIAL,cFilAnt)
		SF2->(Mc090Visual("SF2",nRecNo,2))
		Case ( nBrowse == 5 )
		SEL->(MsGoto(nRecno))
		// Modifica a filial para visualizacao atraves da funcao AxVisual
		cFilAnt := IIf(cFilAnt <> SEL->EL_FILIAL .And. !Empty(cFilAnt),SEL->EL_FILIAL,cFilAnt)	
		SEL->(AxVisual("SEL",nRecNo,2))
	EndCase
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Restaura a Integridade dos Dados ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cFilAnt := cFilBkp
	aHeader := aSavAHead
	aCols   := aSavACol
	N       := nSavN
	
	RestArea(aAreaSC5)
	RestArea(aAreaSE5)
	RestArea(aAreaSE1)
	RestArea(aArea)
	
Return(.T.)	

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ ImpDet   ³ Autor ³ Eduardo Riera         ³ Data ³02.07.1998³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Controle de Fluxo do Relatorio.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImpDet(lEnd,wnrel,cString,cNomeprog,cTitulo)

	Local li      := 100 // Contador de Linhas
	Local lImp    := .F. // Indica se algo foi impresso
	Local cbCont  := 0   // Numero de Registros Processados
	Local cbText  := ""  // Mensagem do Rodape
	Local cHist	  := ""
	Local cMoeda  := ""
	Local aCol    := {}
	Local aHeader := {}
	Local nCntFor := 0 
	Local nTamHis := 0	// Tamanho do campo historico a ser impresso
	//
	//                          1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
	//                01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	Local cCabec1 := ""
	Local cCabec2 := ""
	Local aAlias  := {}
	Local aParam  := {}
	Local nMCusto := If(SA1->A1_MOEDALC > 0,SA1->A1_MOEDALC,Val(GetMv("MV_MCUSTO")))
	Local cSalFin :=""
	Local cLcFin  :=""
	Local aGet      := {"","","",""}
	Local lInverte
	Local nSizeCol := 0
	Local cMvJurTipo 	:= SuperGetMv("MV_JURTIPO",,"") //Tipo de Calculo de Juros do Financeiro	

	SX3->(DbSetOrder(2))
	cLcFin	:=	If(SX3->(DbSeek("A1_LCFIN")) ,X3Titulo(),STR0076)
	cSalFin  := If(SX3->(DbSeek("A1_SALFIN")),X3Titulo(),STR0075)

	aadd(aParam,MV_PAR01)
	aadd(aParam,MV_PAR02)
	aadd(aParam,MV_PAR03)
	aadd(aParam,MV_PAR04)
	aadd(aParam,MV_PAR05)
	aadd(aParam,MV_PAR06)
	aadd(aParam,MV_PAR07)
	aadd(aParam,MV_PAR08)
	aadd(aParam,MV_PAR09)
	aadd(aParam,MV_PAR10)
	aadd(aParam,MV_PAR11)
	aadd(aParam,MV_PAR12)
	aadd(aParam,MV_PAR13)
	aadd(aParam,MV_PAR14)
	aadd(aParam,MV_PAR15)

	cMoeda	:= AllTrim(STR(nMCusto))
	cMoeda	:= SubStr(Getmv("MV_SIMB"+cMoeda)+Space(4),1,4)

	dbSelectArea(cString)
	SetRegua(LastRec())
	dbSetOrder(1)

	Li := cabec(cTitulo,cCabec1,cCabec2,cNomeProg,Tamanho)
	@li,000 PSAY Replicate("*",220)
	Li++

	If RetGlbLGPD("A1_NOME")
		@li,001 PSAY RetTitle("A1_COD")+": "+SA1->A1_COD+" "+RetTitle("A1_NOME")+": "+ Replicate("*", TamSx3("A1_NOME")[1]) +" "+RetTitle("A1_TEL")+": "+;
		Alltrim(SA1->A1_DDI+" "+SA1->A1_DDD+" "+SA1->A1_TEL)
	Else
		@li,001 PSAY RetTitle("A1_COD")+": "+SA1->A1_COD+" "+RetTitle("A1_NOME")+": "+SA1->A1_NOME+" "+RetTitle("A1_TEL")+": "+;
		Alltrim(SA1->A1_DDI+" "+SA1->A1_DDD+" "+SA1->A1_TEL)
	Endif

	Li++

	If RetGlbLGPD("A1_CGC")
		@li,001 PSAY RetTitle("A1_CGC")+": "+ Replicate("*", 14)
	Else
		@li,001 PSAY RetTitle("A1_CGC")+": "+SA1->A1_CGC
	Endif

	Li++
	@Li,001 PSAY RetTitle("A1_PRICOM")+": "+DTOC(SA1->A1_PRICOM)
	Li++
	@Li,001 PSAY RetTitle("A1_ULTCOM")+": "+DTOC(SA1->A1_ULTCOM)
	Li++
	@Li,001 PSAY RetTitle("A1_MATR")+": "+TransForm(SA1->A1_MATR,PesqPict("SA1","A1_MATR"))
	Li++
	@Li,001 PSAY RetTitle("A1_METR")+": "+TransForm(SA1->A1_METR,PesqPict("SA1","A1_METR")) 
	Li++
	@Li,001 PSAY RetTitle("A1_CHQDEVO")+": "+TransForm(SA1->A1_CHQDEVO,PesqPict("SA1","A1_CHQDEVO",4))
	Li++
	@Li,001 PSAY RetTitle("A1_DTULCHQ")+": "+Dtoc(SA1->A1_DTULCHQ)
	Li++
	@Li,001 PSAY RetTitle("A1_TITPROT")+": "+TransForm(SA1->A1_TITPROT,PesqPict("SA1","A1_TITPROT",4))
	Li++
	@Li,001 PSAY RetTitle("A1_DTULTIT")+": "+DtoC(SA1->A1_DTULTIT)
	Li++
	@Li,001 PSAY RetTitle("A1_RISCO")+": "+SA1->A1_RISCO
	Li++
	@Li,001 PSAY RetTitle("A1_VENCLC")+": "+Dtoc(SA1->A1_VENCLC)
	Li++
	@Li,001 PSAY STR0077+Space(31-Len(STR0077))+STR0078+;
	Space(11-Len(STR0078))+STR0069+cMoeda
	Li++
	@Li,001 PSAY RetTitle("A1_SALDUP")+": "+Space(20-Len(RetTitle("A1_SALDUP")))+TransForm(SA1->A1_SALDUP,PesqPict("SA1","A1_SALDUP",14,1))+;
	SPACE(6)+TransForm(SA1->A1_SALDUPM,PesqPict("SA1","A1_SALDUPM",14,nMcusto))
	Li++
	@Li,001 PSAY RetTitle("A1_MCOMPRA")+": "+Space(20-Len(RetTitle("A1_MCOMPRA")))+TransForm(xMoeda(SA1->A1_MCOMPRA,nMcusto,1,dDataBase,MsDecimais(1)),;
	PesqPict("SA1","A1_MCOMPRA",14,1))+SPACE(6)+TransForm(SA1->A1_MCOMPRA,PesqPict("SA1","A1_MCOMPRA",14,nMcusto))
	Li++
	@Li,001 PSAY RetTitle("A1_MSALDO")+": "+Space(20-Len(RetTitle("A1_MSALDO")))+TransForm(xMoeda(SA1->A1_MSALDO,nMcusto,1,dDataBase,MsDecimais(1)),;
	PesqPict("SA1","A1_MCOMPRA",14,1))+SPACE(6)+TransForm(SA1->A1_MSALDO,PesqPict("SA1","A1_MCOMPRA",14,nMCusto))
	Li++

	@Li,001 PSAY cSalFin+": "+Space(20-Len(cSalFin))+;
	TRansform(SA1->A1_SALFIN,PesqPict("SA1","A1_SALFIN",14,1))+SPACE(6)+;
	TRansform(SA1->A1_SALFINM,PesqPict("SA1","A1_SALFINM",14,nMcusto))
	Li++

	@Li,001 PSAY cLcFin+": "+Space(20-Len(cLcFin))+;
	TRansform(xMoeda(SA1->A1_LCFIN,nMcusto,1,dDatabase,MsDecimais(1)),PesqPict("SA1","A1_LCFIN",14,1))+;
	SPACE(6)+TRansform(SA1->A1_LCFIN,PesqPict("SA1","A1_LCFIN",14,nMcusto))

	Li++

	@Li,001 PSAY RetTitle("A1_LC")+": "+Space(20-Len(RetTitle("A1_LC")))+TransForm(xMoeda(SA1->A1_LC,nMcusto,1,dDataBase,MsDecimais(nMCusto)),PesqPict("SA1","A1_LC",14,nMCusto))+SPACE(6)+;
	TransForm(SA1->A1_LC,PesqPict("SA1","A1_LC",14,1))

	Li+=3
	@Li,001 PSAY PadC(STR0053,Limite) //"TITULOS EM ABERTO"
	Li++
	aHeader := Fc010Brow(1,@aAlias,aParam,.F.,aGet,.T.)
	IncRegua(1)
	cCabec1 := ""
	aCol    := {}
	dbSelectArea(aAlias[Len(aAlias)][1])
	dbGotop()
	aadd(aCol,1)

	aHeader := FC010COLIMP(aHeader)

	For nCntFor := 1 To Len(aHeader)
		If nModulo != 49    //Gestao Educacional
			If !(Alltrim(aHeader[nCntFor][2]) $ "E1_SDACRES#E1_SDDECRE#E1_HIST") .and. !(Alltrim(aHeader[nCntFor][2])== "E1_SALDO2")				
				cCabec1 += PadR(aHeader[nCntFor][1],Max(Len(TransForm(FieldGet(FieldPos(aHeader[nCntFor][2])),Trim(aHeader[nCntFor][3]))),Len(AllTrim(aHeader[nCntFor][1]))))+Space(2)

			ElseIf Alltrim(aHeader[nCntFor][2]) $ "E1_HIST"  //Limita Historico
				cHist	:= PadR(aHeader[nCntFor][1],12)+Space(2)
				cCabec1 += cHist
				nTamHis := Len(cHist) - 1
			Endif
		Else
			If !(Alltrim(aHeader[nCntFor][2]) $ "E1_SDACRES#E1_SDDECRE#E1_HIST") .and. !(Alltrim(aHeader[nCntFor][2])== "E1_SALDO2")
				cCabec1 += PadR(aHeader[nCntFor][1],Max(Len(TransForm(FieldGet(FieldPos(aHeader[nCntFor][2])),Trim(aHeader[nCntFor][3]))),Len(AllTrim(aHeader[nCntFor][1]))))+Space(2)
			Endif
		EndIf		

		aadd(aCol,Len(cCabec1)+2)

	Next nCntFor
	@ Li,001 PSAY cCabec1
	Li++
	While ( !Eof() )
		lImp := .T.
		If lEnd
			@ Prow()+1,001 PSAY STR0070 //"CANCELADO PELO OPERADOR"
			Exit
		EndIf
		If ( Li > 56 )
			li := cabec(cTitulo,' '+cCabec1,cCabec2,cNomeprog,Tamanho)
			li++
		Endif
		For nCntFor := 1 To Len(aHeader)
			If nModulo != 49    //Gestao Educacional
				If !(Alltrim(aHeader[nCntFor][2]) $ "E1_SDACRES#E1_SDDECRE") .and. !(Alltrim(aHeader[nCntFor][2])== "E1_SALDO2")
					lInverte	:= E1_TIPO $ MVRECANT+","+MV_CRNEG .And. Alltrim(aHeader[nCntFor][2]) $ "E1_VLCRUZ#E1_SALDO"
					If (Alltrim(aHeader[nCntFor][2]) == "E1_NUMBCO")
						@ Li,IIf(cMvJurTipo=="L",176,Iif(aParam[13] == 1 ,160,165))-If(lInverte,1,0) PSAY If(lInverte,"(","")+TransForm(FieldGet(FieldPos(aHeader[nCntFor][2])),Trim(aHeader[nCntFor][3])) + If(lInverte,")","")
					ElseIf (Alltrim(aHeader[nCntFor][2]) <> "E1_HIST")
						@ Li,aCol[nCntFor]-If(lInverte,1,0) PSAY If(lInverte,"(","")+TransForm(FieldGet(FieldPos(aHeader[nCntFor][2])),Trim(aHeader[nCntFor][3])) + If(lInverte,")","")
					Else
						@ Li,IIf(cMvJurTipo=="L",195,179) PSAY SubStr(TransForm(FieldGet(FieldPos(aHeader[nCntFor][2])),Trim(aHeader[nCntFor][3])),1,nTamHis)
					EndIf
				Endif		
			Else
				If !(Alltrim(aHeader[nCntFor][2]) $ "E1_SDACRES#E1_SDDECRE#E1_HIST") .and. !(Alltrim(aHeader[nCntFor][2])== "E1_SALDO2")
					lInverte	:= E1_TIPO $ MVRECANT+","+MV_CRNEG .And. Alltrim(aHeader[nCntFor][2]) $ "E1_VLCRUZ#E1_SALDO"
					@ Li,aCol[nCntFor]-If(lInverte,1,0) PSAY If(lInverte,"(","")+TransForm(FieldGet(FieldPos(aHeader[nCntFor][2])),Trim(aHeader[nCntFor][3])) + If(lInverte,")","")
				Endif		
			EndIf
		Next nCntFor
		Li++
		dbSkip()
		cbCont++
	EndDo
	Li++
	@Li,001 PSAY STR0087 + RIGHT(aGet[1],5)  //"Total : "
	@Li,076 PSAY aGet[2]
	@Li,150 PSAY aGet[3]

	Li+=3
	If ( Li > 55 )
		li := cabec(cTitulo,"","",cNomeprog,Tamanho)
		li++
	Endif

	@Li,001 PSAY PadC(STR0054,Limite) //"TITULOS RECEBIDOS"
	Li++
	aHeader := Fc010Brow(2,@aAlias,aParam,.F.,aGet,.T.)
	cCabec1 := ""
	aCol    := {}
	IncRegua(2)

	dbSelectArea(aAlias[Len(aAlias)][1])
	dbGotop()
	aadd(aCol,1)
	aHeader := FC010COLIMP(aHeader)

	//Atribui máscara de acordo com o dimensionamento da coluna
	AEVAL(aHeader,{|e,i| aHeader[i][3] := IF(aHeader[i][5] > 0 .AND. aHeader[i][8] == 'N','@E 9,999,999.99',aHeader[i][3])})

	For nCntFor := 1 To Len(aHeader)

		nSizeCol := aHeader[nCntFor][4]+If(aHeader[nCntFor][5]>2,aHeader[nCntFor][5]+1,0)
		nSizeCol += If(aHeader[nCntFor][8]=='D',2,0)

		If (nSizeCol > 3) .and. (LEN(aHeader[nCntFor][1]) > nSizeCol)

			If aHeader[nCntFor][2] $ "E5_VLDECRE#E5_VLMULTA#E5_VLCORRE#E5_VLDESCO#E5_VLACRES"		  
				aHeader[nCntFor][1] := SUBSTR(aHeader[nCntFor][1],1,nSizeCol+4)			
			Elseif aHeader[nCntFor][2] $ "E1_PAGO"
				aHeader[nCntFor][1] := space(4) + alltrim(aHeader[nCntFor][1])
			Else
				aHeader[nCntFor][1] := SUBSTR(aHeader[nCntFor][1],1,nSizeCol)
			Endif

		EndIf 

		If nSizeCol < 4
			If aHeader[nCntFor][2] $ "E1_PAGO"
				aHeader[nCntFor][1] := space(4) + alltrim(aHeader[nCntFor][1])
			Else
				aHeader[nCntFor][1] := SUBSTR(aHeader[nCntFor][1],1,4)
			Endif
		endif

		If !Alltrim(aHeader[nCntFor][2]) $ "E5_VLJUROS#E5_VLMULTA#E5_VLCORRE#E5_VLDECRE#E5_HISTOR"
			cCabec1 += PadR(aHeader[nCntFor][1],Max(Len(TransForm(FieldGet(FieldPos(aHeader[nCntFor][2])),Trim(aHeader[nCntFor][3]))),Len(AllTrim(aHeader[nCntFor][1]))))+Space(1)	
			aadd(aCol,Len(cCabec1)+1)
		ElseIf Alltrim(aHeader[nCntFor][2]) $ "E5_HISTOR"		//Limita Historico a 35 posicoes
			cCabec1 += PadR(aHeader[nCntFor][1],12)+Space(2)
			aadd(aCol,Len(cCabec1)+1)
		Else
			aadd(aCol,aCol[Len(aCol)])		// Deixar aCol do mesmo tamanho de aHeader para que na impressao nao
			// ocorram problemas.
		Endif	
	Next nCntFor
	@ Li,001 PSAY cCabec1
	Li++
	While ( !Eof() )
		lImp := .T.
		If lEnd
			@ Prow()+1,001 PSAY STR0070 //"CANCELADO PELO OPERADOR"
			Exit
		EndIf
		If ( Li > 56 )
			li := cabec(cTitulo,' '+cCabec1,cCabec2,cNomeprog,Tamanho)
			li++
		Endif
		For nCntFor := 1 To Len(aHeader)
			If !Alltrim(aHeader[nCntFor][2]) $ "E5_VLJUROS#E5_VLMULTA#E5_VLCORRE#E5_VLDECRE#E5_HISTOR" .and. aHeader[nCntFor][8] != "D"
				@ Li,aCol[nCntFor] PSAY TransForm(FieldGet(FieldPos(aHeader[nCntFor][2])),Trim(aHeader[nCntFor][3]))
			ElseIf Alltrim(aHeader[nCntFor][2]) $ "E5_HISTOR"		//Limita Historico a 35 posicoes
				@ Li,aCol[nCntFor] PSAY Substr(FieldGet(FieldPos(aHeader[nCntFor][2])),1,12)+Space(2)
			ELSEIF aHeader[nCntFor][8] = "D"		//altera para data abreviada
				@ Li,aCol[nCntFor] PSAY TransForm(gravadata(FieldGet(FieldPos(aHeader[nCntFor][2])),.f.,1),"@R 99/99/99")
			Endif
		Next nCntFor
		Li++
		dbSkip()
		cbCont++
	EndDo
	Li++
	@Li,001 PSAY STR0087 + RIGHT(aGet[1],5)   //"Total : "
	@Li,056 PSAY aGet[3]

	Li+=3
	If ( Li > 55 )
		li := cabec(cTitulo,"","",cNomeprog,Tamanho)
		li++
	Endif

	@Li,001 PSAY PadC(STR0055,Limite) //"PEDIDOS"
	Li++
	aHeader := Fc010Brow(3,@aAlias,aParam,.F.,aGet,.T.)
	cCabec1 := ""
	aCol    := {}
	IncRegua(3)

	dbSelectArea(aAlias[Len(aAlias)][1])
	dbGotop()
	aadd(aCol,1)
	For nCntFor := 1 To Len(aHeader)
		cCabec1 += PadR(aHeader[nCntFor][1],Max(Len(TransForm(FieldGet(FieldPos(aHeader[nCntFor][2])),Trim(aHeader[nCntFor][3]))),Len(AllTrim(aHeader[nCntFor][1]))))+Space(1)	
		aadd(aCol,Len(cCabec1)+1)
	Next nCntFor
	@ Li,001 PSAY cCabec1
	Li++
	While ( !Eof() )
		lImp := .T.
		If lEnd
			@ Prow()+1,001 PSAY STR0070 //"CANCELADO PELO OPERADOR"
			Exit
		EndIf
		If ( Li > 56 )
			li := cabec(cTitulo,cCabec1,cCabec2,cNomeprog,Tamanho)
			li++
		Endif
		For nCntFor := 1 To Len(aHeader)
			@ Li,aCol[nCntFor] PSAY TransForm(FieldGet(FieldPos(aHeader[nCntFor][2])),Trim(aHeader[nCntFor][3]))
		Next nCntFor
		Li++
		dbSkip()
		cbCont++
	EndDo
	Li+=2

	@Li,001 PSAY STR0087 + RIGHT(aGet[1],5)   //"Total : "
	@Li,019 PSAY Transform(Val(StrTran(StrTran(aGet[2],".",""),",",".")),"@E 999,999,999.99")
	@Li,034 PSAY Transform(Val(StrTran(StrTran(aGet[3],".",""),",",".")),"@E 999,999,999.99")
	@Li,049 PSAY Transform(Val(StrTran(StrTran(aGet[4],".",""),",",".")),"@E 999,999,999.99")

	Li+=3

	If ( Li > 55 )
		li := cabec(cTitulo,"","",cNomeprog,Tamanho)
		li++
	Endif

	@Li,001 PSAY PadC(STR0056,Limite) //"FATURAMENTO"
	Li++
	aHeader := Fc010Brow(4,@aAlias,aParam,.F.,aGet,.T.)
	cCabec1 := ""
	aCol    := {}
	IncRegua(4)

	dbSelectArea(aAlias[Len(aAlias)][1])
	dbGotop()
	aadd(aCol,1)
	For nCntFor := 1 To Len(aHeader)
		cCabec1 += PadR(aHeader[nCntFor][1],Max(Len(TransForm(FieldGet(FieldPos(aHeader[nCntFor][2])),Trim(aHeader[nCntFor][3]))),Len(AllTrim(aHeader[nCntFor][1]))))+Space(1)	
		aadd(aCol,Len(cCabec1)+1)
	Next nCntFor
	@ Li,001 PSAY cCabec1
	Li++
	While ( !Eof() )
		lImp := .T.
		If lEnd
			@ Prow()+1,001 PSAY STR0070 //"CANCELADO PELO OPERADOR"
			Exit
		EndIf
		If ( Li > 56 )
			li := cabec(cTitulo,cCabec1,cCabec2,cNomeprog,Tamanho)
			li++
		Endif
		For nCntFor := 1 To Len(aHeader)
			@ Li,aCol[nCntFor] PSAY TransForm(FieldGet(FieldPos(aHeader[nCntFor][2])),Trim(aHeader[nCntFor][3]))
		Next nCntFor
		Li++
		dbSkip()
		cbCont++
	EndDo
	Li++
	@Li,001 PSAY STR0087 + RIGHT(aGet[1],5)   //"Total : "
	@Li,045 PSAY aGet[2]
	Li++

	If cPaisLoc	<> "BRA"
		Li++
		@Li,001 PSAY PadC(STR0061,Limite) //"Cartera de Cheques"
		Li++

		aHeader := Fc010Brow(5,@aAlias,aParam,.F.,aGet,.T.)

		IncRegua(5)

		cCabec1 := ""
		aCol    := {}

		dbSelectArea(aAlias[Len(aAlias)][1])
		dbGotop()

		aadd(aCol,1)

		For nCntFor := 1 To Len(aHeader)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se e um campo numero, para alinhar a direita ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			If aHeader[nCntFor,8] == "N"
				cCabec1 += PadL(aHeader[nCntFor,1],Max(Len(TransForm(FieldGet(FieldPos(aHeader[nCntFor,2])),Trim(aHeader[nCntFor,3]))),Len(AllTrim(aHeader[nCntFor,1]))))+Space(1)
			Else
				cCabec1 += PadR(aHeader[nCntFor,1],Max(Len(TransForm(FieldGet(FieldPos(aHeader[nCntFor,2])),Trim(aHeader[nCntFor,3]))),Len(AllTrim(aHeader[nCntFor,1]))))+Space(1)
			EndIf

			aadd(aCol,Len(cCabec1)+1)
		Next nCntFor

		@ Li,001 PSAY alltrim(cCabec1)

		Li++

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Variaveis que controlam os totalizadores           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		aVals	:=	{0,0,0,0,0,0}	
		nPosEst	:=	Ascan(aHeader,{|x| Trim(x[2]) == "XX_ESTADO"})
		nPosVal	:=	Ascan(aHeader,{|x| Trim(x[2]) == "E1_VLCRUZ"})
		dbSelectArea(aAlias[Len(aAlias)][1])
		dbGotop()

		While ( !Eof() )
			lImp := .T.

			If lEnd
				@ Prow()+1,001 PSAY STR0070 //"CANCELADO PELO OPERADOR"
				Exit
			EndIf

			If ( Li > 56 )
				li := cabec(cTitulo,cCabec1,cCabec2,cNomeprog,Tamanho)
				li++
			Endif

			For nCntFor := 1 To Len(aHeader)
				@ Li,aCol[nCntFor] PSAY TransForm(FieldGet(FieldPos(aHeader[nCntFor][2])),Trim(aHeader[nCntFor][3]))
			Next

			Li++
			cbCont++
			Do Case
				CASE FieldGet(FieldPos(aHeader[nPosEst,2]))	==	STR0066 //"PEND"
				aVals[1]	+=	FieldGet(FieldPos(aHeader[nPosVal,2]))
				aVals[4]++
				CASE FieldGet(FieldPos(aHeader[nPosEst,2]))	==	If(cPaisLoc$"URU|BOL|ARG",STR0089,STR0067) //"NEGO"
				aVals[2]	+=	FieldGet(FieldPos(aHeader[nPosVal,2]))
				aVals[5]++
				CASE FieldGet(FieldPos(aHeader[nPosEst,2]))	==	STR0068 //"COBR"
				aVals[3]	+=	FieldGet(FieldPos(aHeader[nPosVal,2]))
				aVals[6]++
			EndCase				 	

			dbSkip()
		EndDo

		Li++

		@Li,000  PSAY STR0071 //"Totales --> "
		@Li,020 	PSAY STR0062+ " : " + Transform(aVals[1],Tm(aVals[1],16,MsDecimais(1))) + " (" + Alltrim(STR(aVals[4])) + ")" //"Pendientes"
		If cPaisLoc$"URU|BOL"
			@Li,060	PSAY STR0088+ " : " + Transform(aVals[2],Tm(aVals[2],16,MsDecimais(1)))	+ " (" + Alltrim(STR(aVals[5])) + ")" //"Negociados"
		Else
			@Li,060	PSAY STR0063+ " : " + Transform(aVals[2],Tm(aVals[2],16,MsDecimais(1)))	+ " (" + Alltrim(STR(aVals[5])) + ")" //"Negociados"
		Endif
		@Li,100 	PSAY STR0064+ " : " + Transform(aVals[3],Tm(aVals[3],16,MsDecimais(1)))	+ " (" + Alltrim(STR(aVals[6])) + ")" //"Cobrados  "

		Li++
	Endif
	If ( lImp )
		Roda(cbCont,cbText,Tamanho)
	EndIf
	If Trim(GetMV("MV_VEICULO")) == "S"
		FG_SALOSV(SA1->A1_COD,SA1->A1_LOJA,," ","I")
	EndIf   

	Fc010Clr() //Deleta as tabelas temporárias que foram criadas no banco de dados

	dbSelectArea("SA1")
	Set Device To Screen
	Set Printer To


	If ( aReturn[5] = 1 )
		dbCommitAll()
		OurSpool(wnrel)
	Endif
	MS_FLUSH()

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³FC010TotRc³ Autor ³ Mauricio Pequim Jr    ³ Data ³30.08.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Somat¢ria dos titulos recebidos                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aGet - Array que guardar  o nro de titulos, valores princi- ³±±
±±³          ³       pais e valor da baixa                                ³±±
±±³          ³cAlias - Alias do arquivo tempor rio                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FC010TotRc(aGet, cAlias, aTotPag, lRelat)

	Local cTitAnt	:= ""
	Local nAscan	:= 0
	Local lRest		:= .F.

	Default lRelat:= .F.

	While !Eof()
		aGet[1]++
		lRest := IIf(E1_TIPO $ "RA #" + MV_CRNEG, .T., .F.)
		// Impressao do relatorio nao existe E1_MOEDA no temporario
		If !lRelat
			nAscan := Ascan(aTotPag,{|e| e[MOEDATIT] == E1_MOEDA})
			If nAscan == 0
				If lRest
					Aadd(aTotPag, {1, E1_MOEDA, IIf(E1_MOEDA > 1, E1_VLMOED2, E1_PAGO) * (-1), E1_PAGO * (-1)})
				Else
					Aadd(aTotPag, {1, E1_MOEDA, IIf(E1_MOEDA > 1, E1_VLMOED2, E1_PAGO), E1_PAGO})
				EndIf
			Else
				aTotPag[nAscan][QTDETITULOS]++
				If lRest
					aTotPag[nAscan][VALORTIT]	-= IIf(E1_MOEDA > 1, E1_VLMOED2, E1_PAGO)
					aTotPag[nAscan][VALORREAIS]	-= E1_PAGO
				Else
					aTotPag[nAscan][VALORTIT]	+= IIf(E1_MOEDA > 1, E1_VLMOED2, E1_PAGO)
					aTotPag[nAscan][VALORREAIS]	+= E1_PAGO
				EndIf
			Endif
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Somo o valor do titulo apenas uma vez em caso de baixa parcial ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (cAlias)->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO) != cTitAnt
			If lRest // adiantamentos
				aGet[4] += E1_VLCRUZ
			else
				aGet[2] += E1_VLCRUZ
			EndIf
			cTitAnt := (cAlias)->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)
		Endif
		
		If lRest // adiantamentos
			aGet[5] += E1_PAGO
		else
			aGet[3] += E1_PAGO
		EndIf

		dbSkip()
	EndDo

Return (aGet)	

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Fc010Moeda³ Autor ³ Claudio Donizete Souza³ Data ³13.11.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Exibe os totais a pagar a recebidos por moeda               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aTotais- Matriz de totais por moeda						  ³±±
±±³          ³oDlg   - Objeto dialog que sera exibida a tela da consulta  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Fc010Moeda(aTotais,oDlg)
	
	Local aCab := {	STR0098	,; //"Qtde. Titulos"
					STR0099	,; //"Moeda"
					STR0100	,; //"Valor na moeda"
					STR0101} 	//"Valor em R$"
	Local oLbx					 
	
	DEFINE DIALOG oDlg FROM 0,0 TO 20,70 TITLE STR0102 OF oDlg //"Distribuição por moeda"
	oLbx := RDListBox(.5, .4, 270, 130, aTotais, aCab)
	oLbx:LNOHSCROLL := .T.
	oLbx:LHSCROLL := .F.
	ACTIVATE MSDIALOG oDlg CENTERED
	
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Fc010Legen³ Autor ³ Claudio Donizete Souza³ Data ³13.11.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Exibe legenda de titulos baixados parcial ou totalmente     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
static Function Fc010Legenda(oDlg,aPosObj1,aSay,aGet)
	@ aPosObj1[3,1]+37,005 SAY aSay[7] SIZE 035,07 OF oDlg PIXEL  //Total Geral
	@ aPosObj1[3,1]+37,060 SAY aGet[7] SIZE 060,07 OF oDlg PIXEL

	@ aPosObj1[3,1]+4, 300 BITMAP oBmp RESNAME "BR_AZUL" SIZE 16,16 NOBORDER OF oDlg PIXEL
	@ aPosObj1[3,1]+4, 310 SAY STR0121 OF oDlg PIXEL // "Baixado parcial"
			
	@ aPosObj1[3,1]+16, 300 BITMAP oBmp1 RESNAME "BR_VERDE" SIZE 16,16 NOBORDER OF oDlg PIXEL
	@ aPosObj1[3,1]+16, 310 SAY STR0094 OF oDlg PIXEL // "Sem baixas"

	@ aPosObj1[3,1]+28, 300 BITMAP oBmp RESNAME "BR_AMARELO" SIZE 16,16 NOBORDER OF oDlg PIXEL
	@ aPosObj1[3,1]+28, 310 SAY STR0113 OF oDlg PIXEL   //"Titulo c/ Cheque Devolvido"
	
	If !(cPaisLoc $ "MEX|ARG")
		@ aPosObj1[3,1]+40, 300 BITMAP oBmp RESNAME "DISABLE" SIZE 16,16 NOBORDER OF oDlg PIXEL
		@ aPosObj1[3,1]+40, 310 SAY STR0138 OF oDlg PIXEL   //"Título no Serasa"
	Endif

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Fc010Loja ºAutor  ³Microsiga           º Data ³  12/30/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega as variaveis com todos os valores da empresa        º±±
±±º          ³selecionada                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Finc010                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Fc010Loja(nLC,dPRICOM,nSALDUP,nSALDUPM,dULTCOM,nLCFIN,nMATR,nSALFIN,nSALFINM,nMETR,nMCOMPRA,cRISCO,nMSALDO,nCHQDEVO,dDTULCHQ,nTITPROT,dDTULTIT)

	Local nRecSA1 := SA1->(Recno())
	Local cCod := SA1->A1_COD
	Local cChave := xFilial("SA1") + cCod         
	Local aAreaSA1 := SA1->(GetArea())

	SA1->(DbSetOrder(1))
	SA1->(DbSeek(cChave))
	While cChave == (xFilial("SA1") + SA1->A1_COD)
		nLC      += SA1->A1_LC
		nSALDUP  += SA1->A1_SALDUP
		nSALDUPM += SA1->A1_SALDUPM
		nLCFIN   += SA1->A1_LCFIN       
		nSALFIN  += SA1->A1_SALFIN  
		nSALFINM += SA1->A1_SALFINM              
		If nMCOMPRA < SA1->A1_MCOMPRA
			nMCOMPRA := SA1->A1_MCOMPRA        
		Endif
		If nMSALDO < SA1->A1_MSALDO
			nMSALDO := SA1->A1_MSALDO
		Endif       
		If cRISCO < SA1->A1_RISCO
			cRISCO := SA1->A1_RISCO
		Endif
		If nMETR < SA1->A1_METR 
			nMETR := SA1->A1_METR 
		Endif
		If nMATR < SA1->A1_MATR
			nMATR := SA1->A1_MATR
		Endif                 
		If dULTCOM < SA1->A1_ULTCOM       
			dULTCOM := SA1->A1_ULTCOM       
		Endif
		If Empty(dPRICOM) .Or. dPRICOM > SA1->A1_PRICOM
			dPRICOM :=SA1->A1_PRICOM
		Endif
		nCHQDEVO += SA1->A1_CHQDEVO
		nTITPROT += SA1->A1_TITPROT
		If dDTULCHQ < SA1->A1_DTULCHQ
			dDTULCHQ := SA1->A1_DTULCHQ
		Endif
		If dDTULTIT < SA1->A1_DTULTIT
			dDTULTIT := SA1->A1_DTULTIT
		Endif
		SA1->(DbSkip())
	EndDo

	RestArea(aAreaSA1)
	SA1->(dbGoTo(nRecSA1))

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva    ³ Data ³28/11/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados		  ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()

	Private aRotina :=	{{STR0001, "AxPesqui" , 0 , 1},; //"Pesquisar"
						{STR0003, "FC010CON" , 0 , 2},;  //"Consultar"
						{STR0002, "AxVisual" , 0 , 2},;  //"Visualizar"
						{STR0004, "FC010IMP" , 0 , 2},;  //"Impressao"
						{STR0119,"MsDocument", 0 , 4}}   //"Conhecimento"
Return(aRotina)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FC010COLIMP³ Autor ³ Marcelo Celi Marques  ³ Data ³ 26.09.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Altera o tamanho da coluna de impressao mediante tam picture³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINC010                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FC010COLIMP(aHeader)
	
	Local nCntFor := 0
	
	For nCntFor := 1 To Len(aHeader)					

		// Mudança das Pictures
		If Alltrim(aHeader[nCntFor][2]) $ "E1_ATR"
			aHeader[nCntFor][3] := "99999"					
		Endif      
		If Alltrim(aHeader[nCntFor][2]) $ "E1_VLCRUZ#E1_SDACRES#E1_SDDECRE#E1_SALDO#E1_SALDO2#E1_MULTA"
			aHeader[nCntFor][3] := "@E 999,999,999.99"					
		Endif      
		If Alltrim(aHeader[nCntFor][2]) $ "E1_VALJUR"
			aHeader[nCntFor][3] := "@E 9,999,999.99"					
		Endif

		// Mudança das STR
		If Alltrim(aHeader[nCntFor][2]) $ "E1_PREFIXO"
			aHeader[nCntFor][1] := STR0124
		Endif      
		If Alltrim(aHeader[nCntFor][2]) $ "E1_PARCELA"
			aHeader[nCntFor][1] := STR0125
		Endif      
		If Alltrim(aHeader[nCntFor][2]) $ "E1_VALJUR"
			aHeader[nCntFor][1] := STR0126
		Endif      
		If Alltrim(aHeader[nCntFor][2]) $ "E1_PORTADO"
			aHeader[nCntFor][1] := STR0127
		Endif
	Next
	
Return aHeader


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FinC010T   ³ Autor ³ Marcelo Celi Marques ³ Data ³ 31.03.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada semi-automatica utilizado pelo gestor financeiro   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINC010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FinC010T(aParam)	
	
	cRotinaExec := "FINC010"
	ReCreateBrow("SA1",FinWindow)      	
	FinC010(aParam[1])
	ReCreateBrow("SA1",FinWindow)      		

	dbSelectArea("SA1")

	INCLUI := .F.
	ALTERA := .F.

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Fc010Excel ³ Autor ³ Mauricio Pequim Jr   ³ Data ³ 31.03.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina para exportatacao de dados para Excel               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias                                              ³±±
±±³          ³ ExpA2 : Array com as Descricoes do Cabecalho               ³±±
±±³          ³ ExpA3 : Array com os parametros (perguntes) da rotina      ³±±
±±³          ³ ExpN4 : Opcao executada                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINC010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Fc010Excel(cAlias,aHeader,aParam,nBrowse)

	LOCAL aItem			:= {}
	LOCAL aItenXCel		:= {}
	Local aStruD		:= {}
	Local aStruX		:= {}
	Local aArea			:= (cAlias)->(GetArea())
	Local lLoja			:= .T.
	Local nX			:= 0
	Local cTexto		:= ""
	Local cLibVersion
	Local cNomCli		:= ""

	DEFAULT cAlias		:= "SE1"
	DEFAULT aHeader		:= {}
	DEFAULT aParam		:= {}
	DEFAULT nBrowse 	:= 0
	
	IF GetRemoteType (@cLibVersion) == 5//Smart Client versão HTML.
	   Msgalert(STR0140) //"No es posible usar envio a Excel cuando se hace de la aplicación desde smartcliente HTML”
	   Return 
	ENDIF    


	If Len(aHeader) > 0 .and. Len(aParam) > 0

		If RetGlbLGPD("A1_NREDUZ")
			cNomCli := Replicate("*", TamSx3("A1_NREDUZ")[1])
		Else
			cNomCli	:= SA1->A1_NREDUZ
		Endif

		If aParam[13] == 1 // -> considera lojas
			cCliente := SA1->A1_COD + " - " + SA1->A1_LOJA + " - " + cNomCli
		Else
			cCliente := SA1->A1_COD + " - " + cNomCli
			lLoja := .F.
		Endif

		If ! ApOleClient( 'MsExcel' ) 
			MsgAlert( STR0133)  //'MsExcel nao instalado'
		Else
			DbSelectArea(cAlias)
			DbGotop()

			//Montagem dos dados a serem exportados para Excel
			For nX := 1 to Len(aHeader)
				//-------------------------
				//aHeader
				//01 AllTrim(X3Titulo())
				//02 SX3->X3_CAMPO
				//03 SX3->X3_PICTURE
				//04 SX3->X3_TAMANHO
				//05 SX3->X3_DECIMAL
				//06 SX3->X3_VALID
				//07 SX3->X3_USADO
				//08 SX3->X3_TIPO
				//09 SX3->X3_ARQUIVO
				//10 SX3->X3_CONTEXT
				//-------------------------

				If !("XX_" $ aHeader[nX][2]) .and. !(If(lLoja,("_LOJA" $ aHeader[nX][2]),.F.))
					aADD(aStruD,{aHeader[nX][1],aHeader[nX][8],aHeader[nX][4],aHeader[nX][5]})
					aADD(aStruX,{aHeader[nX][2],aHeader[nX][8],aHeader[nX][4],aHeader[nX][5]})
				Endif
			Next

			AADD(aStruD,{"","C",1,0})
			AADD(aStruX,{"","C",1,0})

			WHILE (cAlias)->(!EOF())

				aItem := Array(Len(aStruX))
				For nX := 1 to Len(aStruX)
					IF nX == Len(aStruX)  // Coluna de compatibilizacao com a abertura no EXCEL
						aItem[nX] := CHR(160)
					ELSEIF aStruX[nX][2] == "C"
						aItem[nX] := CHR(160)+(cAlias)->&(aStruX[nX][1])
					ELSE
						aItem[nX] := (cAlias)->&(aStruX[nX][1])
					ENDIF
				Next nX 
				AADD(aItenXcel,aItem)
				aItem := {}
				(cAlias)->(dbSkip())
			Enddo

			If nBrowse == 1
				cTexto := STR0128 +cCLiente //"Consulta Titulos em Aberto do Cliente - "
			Else		
				cTexto := STR0129 +cCLiente //"Consulta Titulos Baixados do Cliente - "
			Endif

			MsgRun(STR0130, STR0131,{||DlgToExcel({{"GETDADOS",cTexto,aStruD,aItenXcel}})}) //"Favor Aguardar....."###"Exportando os Registros para o Excel"

		EndIf

	Endif

	RestArea(aArea)

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FC010QFil  ³ Autor ³                      ³ Data ³06/12/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria um complemento para uso em queries para os casos em   ³±±
±±³          ³ se necessisita verificar em uma relacao de filiais.        ³±±
±±³          ³ Utiliza as funcoes do ctb para controle da quatidade de    ³±±
±±³          ³ filiais.                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Paramatros³ nAcao: 1 cria o complemento para query.                    ³±±
±±³          ³        2 apaga as tabelas temporaria, se criadas.          ³±±
±±³          ³ cAliasFil: tabela onde sera comparada a filial.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINC010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FC010QFil(nAcao,cAliasFil)
	
	Local nPosAlias		:= 0
	Local cTmpFil		:= ""

	Default cAliasFil	:= ""
	Default nAcao		:= 2

	If nAcao == 1
		If !Empty(cAliasFil)
			nPosAlias := Ascan(aTmpFil,{|carq| carq[1] == cAliasFil})
			If nPosAlias == 0
				Aadd(aTmpFil,{"","",""})
				nPosAlias := Len(aTmpFil)
				aTmpFil[nPosAlias,1] := cAliasFil
				MsgRun(STR0130,STR0005 ,{|| aTmpFil[nPosAlias,2] := GetRngFil(aSelFil,cAliasFil,.T.,@cTmpFil)}) //"Favor Aguardar....."###"Consulta Posição Clientes"
				aTmpFil[nPosAlias,3] := cTmpFil
			Endif
		Endif
	Else
		If nAcao == 2
			If !Empty(aTmpFil) 
				MsgRun(STR0130,STR0005 ,{|| AEval(aTmpFil,{|tmpfil| CtbTmpErase(tmpFil[3])})}) //"Favor Aguardar....."###"Consulta Posição Clientes"
				nPosAlias := Len(aTmpFil)
				aTmpFil := {}
				aSelFil := {}
			Endif
		Endif
	Endif
Return(nPosAlias)

/*{Protheus.doc} GetStatus

Função para retorno da descrição do status do titulo no Serasa.

@author	lucas.oliveira
@since		01/07/2015

*/
Function GetStatus(lLegenda, cIdDoc)
Local aArea			:= GetArea()
Local cStatus		:= ''
Local cQuery		:= ''
Local cFile			:= CriaTrab(,.F.)
Default cIdDoc		:= ''
Default lLegenda	:= .F.

cQuery := "SELECT FWB.FWB_DESCR FROM " + RetSqlName('FWB') + " FWB "
cQuery += "WHERE FWB.FWB_IDDOC = '" + cIdDoc + "' AND "
cQuery += "FWB.FWB_SEQ = ( SELECT MAX(FWB2.FWB_SEQ) FROM " + RetSqlName('FWB') + " FWB2 "
cQuery += "WHERE FWB2.FWB_IDDOC = '" + cIdDoc + "' AND FWB2.D_E_L_E_T_ = ' ' ) AND "
cQuery += "FWB.D_E_L_E_T_ = ''"  

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cFile,.T.,.T.)

If !(cFile)->(Eof())	
	cStatus := (cFile)->FWB_DESCR 		
ElseIf !(lLegenda)
	cStatus := STR0136// "Sem restrições"
EndIf

(cFile)->(dbCloseArea())

RestArea(aArea)

Return cStatus

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡…o    ³Fc010Clr   ³ Autor ³ Fabio Casagrande Lima   ³ Data ³ 21.12.16 ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡…o ³ Fecha alias e Deleta as tabelas temporárias no banco de dados ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³ Uso      ³ FINC010                                                       ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fc010Clr()	

	If Select("FC010QRY01") > 0
		dbSelectArea("FC010QRY01")
		("FC010QRY01")->(dbCloseArea())
		If _oFINC0101 <> Nil
			_oFINC0101:Delete()
			_oFINC0101 := Nil
		Endif
	EndIf

	If Select("FC010QRY02") > 0
		dbSelectArea("FC010QRY02")
		("FC010QRY02")->(dbCloseArea())
		If _oFINC0102 <> Nil
			_oFINC0102:Delete()
			_oFINC0102 := Nil
		Endif
	EndIf

	If Select("FC010QRY03") > 0
		dbSelectArea("FC010QRY03")
		("FC010QRY03")->(dbCloseArea())
		If _oFINC0103 <> Nil
			_oFINC0103:Delete()
			_oFINC0103 := Nil
		Endif
	EndIf

	If Select("FC010QRY04") > 0
		dbSelectArea("FC010QRY04")
		("FC010QRY04")->(dbCloseArea())
		If _oFINC0104 <> Nil
			_oFINC0104:Delete()
			_oFINC0104 := Nil
		Endif	
	EndIf

	If Select("FC010QRY05") > 0
		dbSelectArea("FC010QRY05")
		("FC010QRY05")->(dbCloseArea())
		If _oFINC0105 <> Nil
			_oFINC0105:Delete()
			_oFINC0105 := Nil
		Endif	
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FINCDtano
Função para transformar o ano em 2 caracteres.

@author Jose Gavetti
@since 03/02/2021
@version 03.01.21
@return Retorna um array com as datas do título transformadas
/*/
//-------------------------------------------------------------------
Function FINCDtano(cQry As Character) As Array

    Local cData1   As Character
    Local nI       As Numeric
    Local aDtTit   As Array
	Local __aDtTit As Array

    cData1   := ""
    nI       := 0
    aDtTit 	 := {}
	__aDtTit := {}

    Default cQry	:= 'SE1'

	aAdd(aDtTit,{(cQry)->E1_EMISSAO})
	aAdd(aDtTit,{(cQry)->E1_VENCTO})
	aAdd(aDtTit,{(cQry)->E1_VENCREA})
	
    For nI := 1 To Len(aDtTit)
        cData1 := right(Dtos(aDtTit[nI][1]),6)
        If __cDateFormat == 'AMERICAN'
            aAdd(__aDtTit, substr(cData1,3,2) +"/"+ substr(cData1,5,2) +"/"+ substr(cData1,1,2) )
        Else	// DEFAULT
            aAdd(__aDtTit, substr(cData1,5,2) +"/"+ substr(cData1,3,2) +"/"+ substr(cData1,1,2) )
        EndIf
    Next

Return __aDtTit

//-------------------------------------------------------------------
/*/{Protheus.doc} FC10INIVAR
Inicializa o pergunte da rotina FINC010.

@author Jose Gavetti
@since 26/02/2021
@version 03.01.21
@return 
/*/
//-------------------------------------------------------------------
Function FC10INIVAR() As Array

If Empty(_oPergunte)
	_oPergunte := FwSx1Util():New()
	_oPergunte:AddGroup("FIC010")
	_oPergunte:SearchGroup()

	IF LEN(_oPergunte:GetGroup("FIC010")) > 1 .AND. !Empty(_oPergunte:GetGroup("FIC010")[2])
		IF LEN(_oPergunte:GetGroup("FIC010")[2]) < 18
			MV_PAR18 := 2
		ENDIF
	ELSE
		MV_PAR18 := 2
	ENDIF
Endif

Return

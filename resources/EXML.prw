#INCLUDE "TOTVS.CH"			//Biblioteca de sintaxes FIVEWIN
#INCLUDE "TOPCONN.CH"		//Bibliotecas para Top Connect
#include "AP5MAIL.CH"		//Biblioteca para envio de E-MAILS
#INCLUDE "TBICONN.CH"		//Biblioteca para abertura de Empresas
#INCLUDE "APWIZARD.CH"		//Biblioteca para montagem de wizard (configuracao deste software)
#INCLUDE "MSOLE.CH"
#INCLUDE "RWMAKE.CH"

#DEFINE DIRXML   IIF(GetRemoteType() <> REMOTE_LINUX,"EXML\","EXML/")	//Diretorio de armazenamento de arquivos do XML
#DEFINE DIRALER  IIF(GetRemoteType() <> REMOTE_LINUX,"NEW\","NEW/")		//Pasta com novos arquivos para importar
#DEFINE DIRLIDO  IIF(GetRemoteType() <> REMOTE_LINUX,"OLD\","OLD/")		//Pasta com arquivos ja importados
#DEFINE DIRERRO  IIF(GetRemoteType() <> REMOTE_LINUX,"ERR\","ERR/")		//Pasta com arquivos que tiveram erros de importacao
#DEFINE DIRDANFE IIF(GetRemoteType() <> REMOTE_LINUX,"DANFE\","DANFE/")	//Pasta com os relatorios de DANFE
#DEFINE DIRCTE   IIF(GetRemoteType() <> REMOTE_LINUX,"CTE\","CTE/") //	"CTE\"

#DEFINE REMOTE_LINUX		2			// O Remote está em Linux

#DEFINE SIGLAARQ "EXML_"    //Sigla Inicial do Arquivo XML

#DEFINE VERSAO   "1.04"		//Versao do aplicativo de importacao

#DEFINE SIMPLES Char( 39 )
#DEFINE DUPLAS  Char( 34 )

Static cRetArq   := ""		//Retorno da consulta XMLDIR

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º       Componentizacao de software para uso pela FSW - INOVACAO        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º  *********     DOCUMENTACAO DE MANUTENCAO DO PROGRAMA     *********   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºConsultor ³   Data   ³ Hora  ³ Detalhes da Alteracao                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³          ³       ³                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Insira abaixo os CNPJs que irao utilizar esta solucao (sem pontos ou traços)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function LicUsoEXML(cCnpj)
Local aCnpj  := {}
Local lRet   := .T.

//Empresa...........: TOTVS - Unidade ABM
//Codigo de Cliente.: 999999
//Este cliente adquiriu a solucao para TODOS os CNPJ's e nao por CNPJ
AddSM0( @aCnpj, "11601370000109" )

//Empresa...........: Vespor Automotive Distribuidora de Autopeças Ltda.
//Codigo de Cliente.: T13807
//Este cliente adquiriu a solucao para TODOS os CNPJ's e nao por CNPJ
AddSM0( @aCnpj, "04771370000183" )

//Empresa...........: Baker Tilly Brasil
//Codigo de Cliente.: TEYYVK
//Este cliente adquiriu a solucao para TODOS os CNPJ's e nao por CNPJ
AddSM0( @aCnpj, "04667469000130" )

//Empresa...........: Padron Perfumaria Ltda
//Codigo de Cliente.: T59311
//Este cliente adquiriu a solucao para TODOS os CNPJ's e nao por CNPJ
AddSM0( @aCnpj, "62245881000168" )
AddSM0( @aCnpj, "62245881000249" )
AddSM0( @aCnpj, "62245881000320" )
AddSM0( @aCnpj, "62245881000400" )
AddSM0( @aCnpj, "62245881000591" )
AddSM0( @aCnpj, "62245881000672" )
AddSM0( @aCnpj, "62245881000753" )
AddSM0( @aCnpj, "59320028000159" )
AddSM0( @aCnpj, "63933972000159" )
AddSM0( @aCnpj, "00023222000120" )
AddSM0( @aCnpj, "05938715000103" )

//Empresa...........: PHB Eletronica Ltda
//Codigo de Cliente.: T15123
//Este cliente adquiriu a solucao para TODOS os CNPJ's e nao por CNPJ
AddSM0( @aCnpj, "53977021000128" )

//Empresa...........: EVC GROUP IMPORTADORA E EXPORTADORA LTDA
//Codigo de Cliente.: TEYVZ3
//Este cliente adquiriu a solucao para TODOS os CNPJ's e nao por CNPJ
AddSM0( @aCnpj, "02314954000102" )
AddSM0( @aCnpj, "02314954000285" )
AddSM0( @aCnpj, "02314954000366" )
AddSM0( @aCnpj, "12010247000178" )
AddSM0( @aCnpj, "12010247000259" )
AddSM0( @aCnpj, "05990369000102" )
AddSM0( @aCnpj, "05990369000293" )
AddSM0( @aCnpj, "02314954000447" )
AddSM0( @aCnpj, "02314954000528" )

//Empresa...........: LEONARDI CONST. INDUSTRIALIZADA LTDA
//Codigo de Cliente.: T54271
//Este cliente adquiriu a solucao para TODOS os CNPJ's e nao por CNPJ
AddSM0( @aCnpj, "59893545000117" )
AddSM0( @aCnpj, "59893545000206" )

//Empresa...........: HEXAGON COML TELECOMUNICACOES LTDA
//Codigo de Cliente.: T04346
//Este cliente adquiriu a solucao para TODOS os CNPJ's e nao por CNPJ
AddSM0( @aCnpj, "00495563000106" )
AddSM0( @aCnpj, "00582926000132" )
AddSM0( @aCnpj, "14332641000158" )

//Empresa...........: SCANNTECH
//Codigo de Cliente.: ...
//Este cliente adquiriu a solucao para TODOS os CNPJ's e nao por CNPJ
AddSM0( @aCnpj, "18147500000116" )

//Empresa...........: TEPX
//Codigo de Cliente.: TEZHPQ
//Este cliente adquiriu a solucao para TODOS os CNPJ's e nao por CNPJ
AddSM0( @aCnpj, "17212096000154" )
AddSM0( @aCnpj, "04374317000149" )
AddSM0( @aCnpj, "13711720000107" )

//Empresa...........: BULGARI
//Codigo de Cliente.: TEZHIT
//Este cliente adquiriu a solucao para TODOS os CNPJ's e nao por CNPJ
AddSM0( @aCnpj, "53485215000106" )
AddSM0( @aCnpj, "14863735000153" )

//Empresa...........: JNAKAO
//Codigo de Cliente.: TEZI77
//Este cliente adquiriu a solucao para TODOS os CNPJ's e nao por CNPJ
AddSM0( @aCnpj, "53794996000463")
AddSM0( @aCnpj, "53485215000106")
AddSM0( @aCnpj, "53794996000110")
AddSM0( @aCnpj, "19933110000134")


//Empresa...........: SOMMAPLAST
//Codigo de Cliente.: TEZI56
//Este cliente adquiriu a solucao para TODOS os CNPJ's e nao por CNPJ
AddSM0( @aCnpj, "00519577000104" )

//Empresa...........: SDBR COMERCIO DE EQUIPAMENTOS DE SEGURANCA LTDA (SMITHS DETECTION)
//Codigo de Cliente.: 000573
//Este cliente adquiriu a solucao para TODOS os CNPJ's e nao por CNPJ
AddSM0( @aCnpj, "13099243000170" )

//Empresa...........: GRUPO MUNDIAL
//Empresas do Grupo.: SOCIEDADE COMERCIAL ATACADISTA DE MERCADOS LTDA (TEZIXY)
//                    COMERCIO GERAL DE BEBIDAS LTDA (TEZIYO)
//                    COMERCIAL IMPORTADORA MUNDIAL LTDA (TEZIXZ)
//Este cliente adquiriu a solucao para TODOS os CNPJ's e nao por CNPJ
AddSM0( @aCnpj, "20966789000147" )
AddSM0( @aCnpj, "20490214000109" )
AddSM0( @aCnpj, "21331902000180" )
AddSM0( @aCnpj, "21331902000342" )
AddSM0( @aCnpj, "21331902000261" )

//Empresa...........: SECUR COMERCIAL IMP E EXP LTDA
//Codigo de Cliente.: TEZIS9
//Este cliente adquiriu a solucao para TODOS os CNPJ's e nao por CNPJ
AddSM0( @aCnpj, "01159496000103" )


//Empresa...........: MIP BRASIL FARMA
//Codigo de Cliente.: TEZJOE
//Este cliente adquiriu a solucao para TODOS os CNPJ's e nao por CNPJ
AddSM0( @aCnpj, "14626301000130" )
AddSM0( @aCnpj, "14626301000210" )


//Empresa...........: TESSIN INDUSTRIA E COMERCIO LTDA
//Codigo de Cliente.: TEJIJ7
//Este cliente adquiriu a solucao para TODOS os CNPJ's e nao por CNPJ
AddSM0( @aCnpj, "44412435000461")
AddSM0( @aCnpj, "51366185000193")
AddSM0( @aCnpj, "44903516000111")
AddSM0( @aCnpj, "55131841000120")
AddSM0( @aCnpj, "04422405000179")


//Empresa...........: WECKERLE SP
AddSM0( @aCnpj, "00845366000110")
//Empresa...........: WECKERLE MOGI
AddSM0( @aCnpj, "00845326000209")
//Empresa...........: LIBUS MOGI
AddSM0( @aCnpj, "19860927000120")

//Empresa...........: DEMARCHE COMERCIO E REPRESENTACOES LTDA
AddSM0( @aCnpj, "00463883000176")

//Empresa...........: TAWCOPLAST
AddSM0( @aCnpj, "13727162000178") 

//Empresa...........: CELEBRAR ADMINISTRACAO LTDA - MATRIZ       - LOJA SHER
AddSM0( @aCnpj, "18511372000148")
//Empresa...........: CELEBRAR ADMINISTRACAO LTDA - LOJA AUGUSTA - LOJA SHER                   
AddSM0( @aCnpj, "18511372000229")

//Empresa...........: CONCESSIONARIA FACA FACIL CIDADAO S.A   
AddSM0( @aCnpj, "19364481000142")
AddSM0( @aCnpj, "19364481000223")
AddSM0( @aCnpj, "19364481000495")
AddSM0( @aCnpj, "19364481000304")

//Empresa...........: BAKER TILLY BRASIL SERVICOS CONTABEIS LTDA - EPP   
AddSM0( @aCnpj, "04667469000130")
//Empresa...........: BAKER TILLY BRASIL AUDITORES INDEPENDENTES S/S  
AddSM0( @aCnpj, "67634717000166")

//Empresa...........: QUALIFE ALIMENTOS LTDA - EPP  
AddSM0( @aCnpj, "02740984000172")
AddSM0( @aCnpj, "13438856000195")
AddSM0( @aCnpj, "11914922000120")

//Empresa...........: HITACHI KOKI DO BRASIL LTDA.                                   
AddSM0( @aCnpj, "11582259000104")

//Empresa...........: CBS MEDICA CIENTIFICA S/A.                                   
AddSM0( @aCnpj, "48791685000168")

//Empresa...........: LFJ
AddSM0( @aCnpj, "07037868000105")

//Empresa...........: MHI TRASNPORTATION - MATRIZ
AddSM0( @aCnpj, "20500438000146")

//Empresa...........: MHI TRASNPORTATION - FILIAL
AddSM0( @aCnpj, "20500438000227")

//Empresa...........: PETCOM
AddSM0( @aCnpj, "08200314000140")
AddSM0( @aCnpj, "08200314000220")

//Empresa...........: KAWAGRAF (MATRIZ E FILIAL)
AddSM0( @aCnpj, "74372285000128")
AddSM0( @aCnpj, "74372285000209")

//Empresa...........: CGA
AddSM0( @aCnpj, "44045565000160")

//Empresa...........: SICES BRASIL LTDA
AddSM0( @aCnpj, "17774501000128")

//Empresa...........: OR BRASIL 
AddSM0( @aCnpj, "02505572000158")

//Empresa...........: NOVATA
AddSM0( @aCnpj, "05266821000198")

//Empresa...........: GP
AddSM0( @aCnpj, "00960272000133") // – GP ELETRONICA - MATRIZ                   
AddSM0( @aCnpj, "00971855000160") // - GPZINHA- MATRIZ                          
AddSM0( @aCnpj, "04349636000102") // - CTT                                      

//Empresa...........: PIMENTA PRIN
AddSM0( @aCnpj, "21755120000179") // – PRINT COMERCIO                 
AddSM0( @aCnpj, "10219302000109") // - BRUNO BENEIT                        
AddSM0( @aCnpj, "11312680000103") // - ARMANDO EPP        

//Empresa...........: KEYENCE BRASIL COMERCIO DE PRODUTOS ELETRONICOS LTDA
//Codigo de Cliente.: TEWM19
//Este cliente adquiriu a solucao para TODOS os CNPJ's e nao por CNPJ
AddSM0( @aCnpj, "13743249000139" )


//Empresa...........: CHRISTEYNS BRASIL
//Codigo de Cliente.: TEZUTW
//Este cliente adquiriu a solucao para TODOS os CNPJ's e nao por CNPJ
AddSM0( @aCnpj, "13707444000103" )


//Empresa...........: DAXIA
AddSM0( @aCnpj, "74581091000132" ) 
AddSM0( @aCnpj, "74581091000213" )
AddSM0( @aCnpj, "74581091000647" )
AddSM0( @aCnpj, "74581091000728" )


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o CNPJ enviado esta dentro do licenciamento de uso da rotina³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lRet := ( aScan( aCnpj, cCnpj ) > 0 )

Return lRet

//-----------------------------------------------------------------------------------------------------\\
// Utilize esta funcao "APENAS" se o cliente adquiriu a solucao para todos os CNPJ's e não "por" CNPJ" \\
//-----------------------------------------------------------------------------------------------------\\
Static Function AddSM0( aCnpj, cCnpj )
Local aSM0  := FWLoadSM0()
Local nX    := 0

If aScan( aSM0, {|x| AllTrim(x[18]) == cCnpj} ) > 0
	For nX := 1 to Len( aSM0 )
		AAdd( aCnpj, aSM0[nX,18] )
	Next nX
EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³  EXMLNFE ³AUTOR  ³FELIPE NUNES DE TOLEDO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Funcao responsavel pela execucao do Job para importacao do ³±±
±±³          ³ arquivo de XML da Nota Fiscal de Entrada.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³PARAMETROS³ cCodEmp     : Codigo da Empresa                            ³±±
±±³          ³ cCodFil     : Codigo da Filial                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observ.   ³ Configuracao appserver.ini                                 ³±±
±±³          ³                                                            ³±±
±±³          ³ [ONSTART]                                                  ³±±
±±³          ³ Jobs=EXMLNFE                                               ³±±
±±³          ³ RefreshRate=180                                            ³±±
±±³          ³                                                            ³±±
±±³          ³ [EXMLNFE]                                                  ³±±
±±³          ³ Main=U_EXMLNFE                                             ³±±
±±³          ³ Environment=<nome ambiente>                                ³±±
±±³          ³ Empresa=<codigo empresa>                                   ³±±
±±³          ³ Filial=<codigo filial>                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function EXMLNFE(cCodEmp,cCodFil)
Local cMailServer := ""
Local cUserMail   := ""
Local cPassMail   := ""
Local nPortPOP    := 0
Local dDataBkp    := CtoD("")
Local cFilBkp     := ""
Local nPosM0      := 0

DEFAULT cCodEmp   := GetJobProfString('Empresa', '01')
DEFAULT cCodFil   := GetJobProfString('Filial' , '99')

//-- Cria os diretorios de importacao
If !ExistDir(DIRXML)
	MakeDir(DIRXML)
	MakeDir(DIRXML +DIRALER)
	MakeDir(DIRXML +DIRLIDO)
	MakeDir(DIRXML +DIRERRO)
	MakeDir(DIRXML +DIRDANFE)
EndIf

Conout('[EXMLNFE] Empresa: ' + cCodEmp + ' Filial: ' + cCodFil)


// Seta job para nao consumir licensas

If !(AllTrim(Upper(FunName())) $ "MATA103/MATA140/U_EXMLIMP")
	RpcSetType(3)
	RPCSetEnv( cCodEmp, cCodFil,,, "COM")
Else
	dDataBkp    := dDataBase
	cFilBkp     := cFilAnt
	nPosM0      := SM0->( Recno() )
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o servico do TSS esta ativo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If XMLVerTSS(.T.)
	If GetNewPar("ES_USAPOP3",2) == 1

		//-- Servidor de E-mail POP para Recebimento do XML
		cMailServer := GetMV('ES_POP3SRV',,'')
		//-- Usuario de E-mail para Recebimento do XML
		cUserMail   := GetMV('ES_USUPOP3',,'')
		//-- Senha de E-mail para Recebimento do XML
		cPassMail   := GetMV('ES_PSWPOP3',,'')
		// Porta do servidor POP
		nPortPOP    := GetMV('ES_POP3POR',,110)

		//-- Acessa Caixa de E-mail e recebe o arquivo XML anexado
		If !(AllTrim(Upper(FunName())) $ "MATA103/MATA140/U_EXMLIMP")
			U_DIXPopOn(cMailServer,cUserMail,cPassMail,nPortPOP)
		Else
			MsgRun( 'Verificando a Caixa Postal de E-MAILS...',;
					'Aguarde...',;
					{|| U_DIXPopOn(cMailServer,cUserMail,cPassMail,nPortPOP) })
		EndIf
	EndIf

	//-- Chama rotina para importacao do Arquivo XML
	If !(AllTrim(Upper(FunName())) $ "MATA103/MATA140/U_EXMLIMP")
		U_DIXRunImp(.T.)
	Else
		Processa({|| U_DIXRunImp(.F.)},"Processando Entradas","Processando Entradas, Aguarde...")
	EndIf

	If !(AllTrim(Upper(FunName())) $ "MATA103/MATA140/U_EXMLIMP")
	 	RPCClearEnv()
	Else
		dDataBase := dDataBkp
		cFilAnt  := cFilBkp
		SM0->( dbGoto( nPosM0 ) )
	EndIf
	
EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³DIXRunImp ³AUTOR  ³FELIPE NUNES DE TOLEDO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Funcao responsavel pela execucao Job para importacao do    ³±±
±±³          ³ arquivo de XML da Nota Fiscal de Entrada.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³PARAMETROS³ lJob        : Execucao via Job (.T./.F.)                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function DIXRunImp(lJob)
Local aProc     := {}
Local aErro     := {}
Local aInfNFE   := {}
Local aDirXml   := {}
Local aAttach   := {}
Local nCntFor1  := 0
Local cChvNFCan := ''
Local aInfDoc   := {}
Local lExcNfCan := .F.
Local cFile     := ""

DEFAULT lJob   := .T.

//-- Cria os diretorios de importacao
If !ExistDir(DIRXML)
	MakeDir(DIRXML)
	MakeDir(DIRXML +DIRALER)
	MakeDir(DIRXML +DIRLIDO)
	MakeDir(DIRXML +DIRERRO)
	MakeDir(DIRXML +DIRDANFE)
EndIf

//-- Verica se existe arquivo XML pendente para ser importado
aDirXml  := Directory( DIRXML + DIRALER + '*.XML' )

If (AllTrim(Upper(FunName())) $ "MATA103/MATA140/U_EXMLIMP")
	ProcRegua(Len(aDirXml))
EndIf

For nCntFor1 := 1 To Len(aDirXml)
	cFile := aDirXml[nCntFor1][1]
	If (AllTrim(Upper(FunName())) $ "MATA103/MATA140/U_EXMLIMP")
		IncProc(cFile)
	EndIf

	aProc    := {}
	aErro    := {}
	aAttach  := {}
	aInfNFE  := {}
	U_DIXIMPNFE(cFile,lJob,@aProc,@aErro,@aInfNFE,@cChvNFCan)

	//-- Verifica se houve erro na importacao do XML
	If Len(aErro) > 0
		//-- Adiciona o arquivo XML
		If File(DIRXML+DIRERRO+cFile)
			AAdd(aAttach,DIRXML+DIRERRO+cFile)
		EndIf

		//-- Adciona o arquivo de LOG ExecAuto
		If File(DIRXML+DIRERRO+StrTran(Upper(cFile),".XML","_ERR.TXT"))
			AAdd(aAttach,DIRXML+DIRERRO+StrTran(Upper(cFile),".XML","_ERR.TXT"))
		EndIf
		If GetNewPar("ES_USAMAIL",2) == 1
			//-- Envia e-mail com a Notificao de inconsistencia
			DIXSMail(aErro,cFile,aAttach,aInfNFE)
		EndIf
	EndIf

	//-- Envia e-mail informando Nota Fiscal de Cancelamento
	If !Empty(cChvNFCan) .And. DIXLocNFE(cChvNFCan)
		aInfDoc := {}
		AAdd(aInfDoc, SF1->F1_FILIAL)
		AAdd(aInfDoc, SF1->F1_DOC)
		AAdd(aInfDoc, SF1->F1_SERIE)
		AAdd(aInfDoc, SF1->F1_FORNECE)
		AAdd(aInfDoc, SF1->F1_LOJA)
		AAdd(aInfDoc, SF1->F1_EMISSAO)
		AAdd(aInfDoc, SF1->F1_U_DTXML)
		AAdd(aInfDoc, SF1->F1_U_HRXML)

		//-- Exclui Pre Nota de Entrada
		If Empty(SF1->F1_STATUS)
			lExcNfCan := DIXCancNFe()
		EndIf

		//-- Envia e-mail informando Nota Fiscal de Cancelamento
		If GetNewPar("ES_USAMAIL",2) == 1
			DIXSMCanc(aInfDoc,lExcNfCan)
		EndIf
	EndIf
Next nCntFor1

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³DIXIMPNFE ³Autor  ³TOTVS ABM                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³Funcao para leitura de XMLs de NFe no diretorio de download ³±±
±±³          ³e geracao da pre-nota de entrada.                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function DIXIMPNFE(cFile,lJob,aProc,aErros,aInfNFE,cChvNFCan)

Local aAreaSMO  := SM0->( GetArea() )
Local cXML      := ""
Local cError    := ""
Local cWarning  := ""
Local cCGC	    := ""
Local cTipoNF   := ""
Local cTabEmit  := ""
Local cDoc	    := ""
Local cSerie    := ""
Local cCodigo   := ""
Local cLoja	    := ""
Local cAlias1   := ""
Local cCampo1   := ""
Local cCampo2   := ""
Local cCampo3   := ""
Local cCampo4   := ""
Local cCampo5   := ""
Local cQuery    := ""
Local cCFOPDev  := GetMV("ES_CFOPDEV",.F.,"")	//CFOP que serao considerados como Devolucao
Local cCFOPDv2  := GetMV("ES_CFOPDV2",.F.,"")	//CFOP que serao considerados como Devolucao
Local cCFOPDv3  := GetMV("ES_CFOPDV3",.F.,"")	//CFOP que serao considerados como Devolucao
Local cCFOPBen  := GetMV("ES_CFOPBEN",.F.,"")	//CFOP que serao considerados como Beneficiamento
Local lFound    := .F.
Local lProces   := .T.
Local lCFOPEsp  := .T.
Local lDelFile  := .T.
Local nX	    := 0
Local nY	    := 0
Local nZ        := 0
Local oFullXML  := NIL
Local oAuxXML   := NIL
Local oXML	    := NIL
Local aItens    := {}
Local aCabecNFE := {}
Local aItemNFE  := {}
Local aItensNFE := {}
Local lItemBEN  := .F.
Local lProdFor  := .F.
Local cProduto  := ""
Local lMensExib := .F.
Local nQuant    := 0
Local cCnpjDest := ""
Local cDescri   := ""
Local lCancel   := .F.
Local cChvNfe   := ""
Local aCposAlt  := {}
Local nPos      := 0
Local aRetPE    := {}
Local aProd     := {}
Local lVldNF    := .T.
Local aNCMDiverg:= {}
Local aNCMProd  := {}
Local aRastro	:= {}
Local nX		:= 0

Private oItemNfe    := Nil //-- Declarado como Private devido a limitacao na funcao Type
Private lMsErroAuto := .F.
Private oXMLPriv    := Nil

DEFAULT lJob      := .T.
DEFAULT aProc     := {}
DEFAULT aErros    := {}
DEFAULT aInfNFE   := {}
DEFAULT cChvNFCan := ''

//-- Cria os diretorios de importacao
If !ExistDir(DIRXML)
	MakeDir(DIRXML)
	MakeDir(DIRXML +DIRALER)
	MakeDir(DIRXML +DIRLIDO)
	MakeDir(DIRXML +DIRERRO)
	MakeDir(DIRXML +DIRDANFE)
EndIf

If !File(DIRXML +DIRALER +cFile)
	If lJob
		AAdd(aErros,{cFile,"Arquivo inexistente.","Não se aplica."})
	Else
		Aviso("Erro","Arquivo " +cFile +" inexistente.",{"OK"},2,"ReadXML")
	EndIf
	lProces := .F.
Else
//	cXML := MemoRead(DIRXML +DIRALER +cFile)
	cXML := StrTran(StrTran(MemoRead(DIRXML +DIRALER +cFile), Chr(10), ''), Chr(13), '') //Trata os comandos CR+LF dos XML`s de alguns fornecedores

	//-- Nao processa conhecimentos de transporte
	If "</CTE>" $ Upper(cXML)
		FErase(DIRXML+DIRALER+cFile)
		lProces := .F.
	EndIf

	//-- Nao processa notas por Evento (Ex: CCe)
	If "</PROCEVENTONFE>" $ Upper(cXML)
		FErase(DIRXML+DIRALER+cFile)
		lProces := .F.
	EndIf

	//-- Nao processa cancelamento de nota fiscal
	If "</CANCNFE>" $ Upper(cXML)
		lCancel := .T.
	EndIf
EndIf

//-- Elimina arquivo de erro de fonte que será reprocessado
If File(DIRXML+DIRERRO+cFile)
	FErase(DIRXML+DIRERRO+cFile)
EndIf

//-- Adciona o arquivo de LOG ExecAuto
If File(DIRXML+DIRERRO+StrTran(Upper(cFile),".XML","_ERR.TXT"))
	FErase(DIRXML+DIRERRO+StrTran(Upper(cFile),".XML","_ERR.TXT"))
EndIf

If lProces

	//verifica se existem caracter ENTER no arquivo e retira
	//fLeFile(DIRXML +DIRALER + cFile)
	//

	oFullXML := XmlParserFile(DIRXML +DIRALER + cFile,"_",@cError,@cWarning)

	//-- Erro na sintaxe do XML
	If Empty(oFullXML) .Or. !Empty(cError)
		If lJob
			AAdd(aErros,{cFile,"Erro de sintaxe no arquivo XML: "+cError,"Entre em contato com o emissor do documento e comunique a ocorrência."})
		Else
			Aviso("Erro",cError,{"OK"},2,"ReadXML")
		EndIf

		lProces := .F.
	EndIf
EndIf

//-- Tratamento de Cancelamento de Nota Fiscal
If lCancel
	If !lJob
		Aviso("Erro","XML referente a cancelamento de nota fiscal não poderá ser importado.",{"OK"},2,"ReadXML")
	EndIf

	oItemNfe   := oFullXML
	cChvNFCan  := If(Type("oItemNfe:_ProcCancNFe:_CancNFe:_InfCanc:_ChNFe:Text") <> 'U',oItemNfe:_ProcCancNFe:_CancNFe:_InfCanc:_ChNFe:Text,'')
	lProces    := .F.
EndIf

If lProces
	oXML    := oFullXML
	oAuxXML := oXML

	//-- Resgata o no inicial da NF-e
	Do While !lFound
		oAuxXML := XmlChildEx(oAuxXML,"_NFE")
		lFound := oAuxXML <> NIL
		If !lFound
			For nX := 1 To XmlChildCount(oXML)
				oAuxXML  := XmlChildEx(XmlGetchild(oXML,nX),"_NFE")
				If ValType(oAuxXML) == "O"
    				lFound := oAuxXML:_InfNfe # Nil
    				If lFound
    					oXML := oAuxXML
    					Exit
    				EndIf
    			EndIf
			Next nX
		EndIf

		If lFound
			oXML := oAuxXML
			Exit
		ElseIf ValType(oAuxXML) <> "O"
			If lJob
				AAdd(aErros,{cFile,"Este arquivo XML é inválido, pois não se trata de uma NFE.","Utilize um arquivo XML de NFE."})
			Else
				Aviso("Erro","Este arquivo XML é inválido, pois não se trata de uma NFE.",{"OK"},2,"ReadXML")
			EndIf
			lProces := .F.
			Exit
		EndIf
	EndDo

	oXMLPriv := oXML
	
	// Tratamento para não processar xml fora do padrão SEFAZ
	If Type("oXMLPriv:_InfNfe:_DEST:_ENDERDEST:_UF:TEXT") == "U"
		If lJob
			AAdd(aErros,{cFile,"Este arquivo XML é inválido.","Utilize um arquivo no padrão SEFAZ."})
		Else
			Aviso("Erro","O arquivo " + cFile + " é inválido, Utilize um arquivo no padrão SEFAZ.",{"OK"},2,"ReadXML")
		EndIf
		lProces := .F.
	EndIf
	
	// Tratamento para NFEs de fornecedor estrangeiro
	if lProces
		If oXML:_InfNfe:_DEST:_ENDERDEST:_UF:Text == "EX"  
			If lJob
				AAdd(aErros,{cFile,"Este arquivo XML é inválido, pois se trata de um arquivo de Importação.","Utilize um arquivo XML de NFE."})
			Else
				Aviso("Erro","Este arquivo XML é inválido, pois se trata de um arquivo de Importação.",{"OK"},2,"ReadXML")
			EndIf
			lProces := .F.
		EndIf
	endif

	If lProces
		//-- CNPJ do Emitente
		If ValType(oXML:_INFNFE:_EMIT:_CNPJ) <> "U"
			cCGC := oXML:_INFNFE:_EMIT:_CNPJ:Text
		ElseIf ValType(oXML:_INFNFE:_EMIT:_CPF) <> "U"
			cCGC := oXML:_INFNFE:_EMIT:_CPF:Text
		EndIf

		//-- Numero e Serie do Documento
		cDoc     := StrZero(Val(AllTrim(oXML:_InfNfe:_Ide:_nNF:Text)),TamSx3("F1_DOC")[1])
		cSerie   := PadL(oXML:_InfNfe:_Ide:_Serie:Text,TamSX3("F1_SERIE")[1],'0')//AJUSTE RODOLFO - PARA COMPLETAR COM ZEROS A ESQUERDA

		//---------------------------------------------
		// Tratamento especifico para o Supermecado Dia
		//---------------------------------------------
		AAdd(aInfNFE,oXML:_InfNfe:_EMIT:_xNome:Text)	//-- Razao Social Emitente
		AAdd(aInfNFE,cCGC)                          	//-- CNPJ Emitente
		AAdd(aInfNFE,cDoc)                          	//-- Documento
		AAdd(aInfNFE,cSerie)                        	//-- Serie
		AAdd(aInfNFE,oXML:_InfNfe:_DEST:_xNome:Text)	//-- Razao Social Destinatario
		AAdd(aInfNFE,oXML:_InfNfe:_DEST:_CNPJ:Text) 	//-- CNPJ Destinatario
	EndIf

	// Ponto de entrada para pular o processamento de notas sem tratá-las como erro.
	If lProces .AND. ExistBlock("EXMLSKIP")
		lProces := ExecBlock("EXMLSKIP",.F.,.F.,{oXML} )
	EndIf

	//-- Nao processa XML de outra empresa/filial
	If lProces

		If ExistBlock("EXMLFIL")
			lProces := ExecBlock("EXMLFIL",.F.,.F.,{aInfNFE, oXML} )

			If ValType(lProces) <> "L"
				lProces := .F.
			EndIf

			If !lProces
				If lJob
					AAdd(aErros,{cFile,"Este XML pertence a outra empresa/filial e não podera ser processado na empresa/filial do sistema.","Entre em contato com o emissor do documento e comunique a ocorrência."})
				Else
					Aviso("Erro","Este XML pertence a outra empresa/filial e não podera ser processado na empresa/filial do sistema.",{"OK"},2,"ReadXML")
				EndIf
				lProces  := .F.
			EndIf
		Else
			cCnpjDest := ''

			DbSelectArea("SM0")
			SM0->(dbSetOrder(1)) //--M0_CODIGO + M0_CODFIL
			SM0->(DbGoTop())
			Do While SM0->(!Eof())
				If AllTrim(oXML:_InfNfe:_DEST:_CNPJ:Text) == AllTrim(SM0->M0_CGC) .And. cEmpAnt == AllTrim(SM0->M0_CODIGO)
					cCnpjDest := SM0->M0_CGC
					cFilAnt   := AllTrim(SM0->M0_CODFIL)
					Exit
				EndIf

				SM0->(DbSkip())
			EndDo

			If Empty(cCnpjDest)
				If lJob
					AAdd(aErros,{cFile,"Este XML pertence a outra empresa/filial e não podera ser processado na empresa/filial do sistema.","Entre em contato com o emissor do documento e comunique a ocorrência."})
				Else
					Aviso("Erro","Este XML pertence a outra empresa/filial e não podera ser processado na empresa/filial do sistema.",{"OK"},2,"ReadXML")
				EndIf
				lProces  := .F.
			EndIf
		EndIf
	EndIf

	//---------------------------------------------
	// Se o CNPJ do destinatario nao possui licença
	// de uso do template, nao permitir o acesso.
	//---------------------------------------------
	If lProces .And. !Empty(cCnpjDest)
		lProces := LicUsoEXML(cCnpjDest)

		If !lProces
			If lJob
				AAdd(aErros,{cFile,"Este XML pertence a outra empresa/filial e não podera ser processado na empresa/filial do sistema.","Entre em contato com o emissor do documento e comunique a ocorrência."})
			Else
				Aviso("Erro","Este XML pertence a outra empresa/filial e não podera ser processado na empresa/filial do sistema.",{"OK"},2,"ReadXML")
			EndIf
		EndIf
	EndIf

	If lProces
		//-- Se tag _InfNfe:_Det valida
		//-- Extrai CGC do fornecedor/cliente
		If AllTrim(oXML:_InfNfe:_Ide:_finNFe:Text) == "1"
			cTipoNF := "N"
		ElseIf AllTrim(oXML:_InfNfe:_Ide:_finNFe:Text) == "4"
			cTipoNF := "D"
		Else
			lProces := .F.
			If lJob
				AAdd(aErros,{cFile,"Este arquivo XML é inválido.","Utilize um arquivo no padrão SEFAZ."})
			Else
				Aviso("Erro","O arquivo " + cFile + " é inválido, Utilize um arquivo no padrão SEFAZ.",{"OK"},2,"ReadXML")
			EndIf
		EndIf
	EndIf

	If lProces
		//-- Se ID valido
		//-- Extrai tag _InfNfe:_Det
		If ValType(oXML:_InfNfe:_Det) == "O"
			aItens := {oXML:_InfNfe:_Det}
		Else
			aItens := oXML:_InfNfe:_Det
		EndIf

		If cTipoNF <> "D"
			For nX := 1 To Len(aItens)
				If aItens[nX]:_PROD:_CFOP:TEXT $ cCFOPBen
					cTipoNF := "B"
					Exit
				ElseIf aItens[nX]:_PROD:_CFOP:TEXT $ cCFOPDev .OR. aItens[nX]:_PROD:_CFOP:TEXT $ cCFOPDv2 ;
															  .OR. aItens[nX]:_PROD:_CFOP:TEXT $ cCFOPDv3
				/*
				Verifica se o CFOP da nota está contido nos 3 parâmetros que gravam os CFOPs de devolução
				*/
					cTipoNF := "D"
					Exit
				EndIf
			Next nX
		EndIf

		//---------------------------------------------
		// Inclusao de Cliente ou Fornecedor, dependendo do tipo da nota
		//---------------------------------------------
		If !Empty(cCGC)
			If cTipoNF $ "B|D"
				lProces := EXMLCadCli(cCGC,oXML,cFile,@aErros,lJob,@lMensExib)
			Else
				lProces := DIXFornec(cCGC,oXML,cFile,@aErros,lJob,@lMensExib,cTipoNF)
			EndIf
		EndIf
	EndIf

	//-- Verifica se este ID ja foi processado
	If lProces


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³P.E. executado para troca do codigo e loja do fornecedor/cliente³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("EXMLCLFR")
			cCodigo := Space(6)
			cLoja   := Space(2)

			aRetPE  := ExecBlock("EXMLCLFR",.F.,.F.,{cCGC,cTipoNF,oFullXML})

			If ValType(aRetPE) == "A"
				cCodigo := aRetPE[1]
				cLoja   := aRetPE[2]
				cTipoNF := aRetPE[3]
			Else
				If lJob
					AAdd(aErros,{cFile,If(cTipoNF=='N',"Fonecedor ","Cliente ") +oXML:_INFNFE:_EMIT:_XNOME:Text +" [" + Transform(cCGC,"@R 99.999.999/9999-99") +"] - Retorno Invalido do P.E. EXMLCLFR.","Verifique a Customizacao deste P.E."})
				Else
					If !lMensExib
						Aviso("Erro",If(cTipoNF=='N',"Fonecedor ","Cliente ") + oXML:_INFNFE:_EMIT:_XNOME:Text +" [" + Transform(cCGC,"@R 99.999.999/9999-99") +"] - Retorno inválido do P.E. EXMLCLFR, verifique a customizacao.",{"OK"},2,"ReadXML")
						lMensExib := .T.
					EndIf
				EndIf
				lProces := .F.
			EndIf

		    If lProces
				cTabEmit := IIf(cTipoNF == "N","SA2","SA1")
				(cTabEmit)->(dbSetOrder(1))
				If (cTabEmit)->( !dbSeek(xFilial(cTabEmit) + cCodigo + cLoja))
					If lJob
						AAdd(aErros,{cFile,If(cTipoNF=='N',"Fonecedor ","Cliente ") +oXML:_INFNFE:_EMIT:_XNOME:Text +" [" + Transform(cCGC,"@R 99.999.999/9999-99") +"] inexistente na base.","Gere cadastro para este fornecedor."})
					Else
						If !lMensExib
							Aviso("Erro",If(cTipoNF=='N',"Fonecedor ","Cliente ") + oXML:_INFNFE:_EMIT:_XNOME:Text +" [" + Transform(cCGC,"@R 99.999.999/9999-99") +"] inexistente na base.",{"OK"},2,"ReadXML")
							lMensExib := .T.
						EndIf
					EndIf

					lProces := .F.
				EndIf
			EndIf
		Else
			//-- Se tag CGC valida
			//-- Busca fornecedor/cliente na base
			cTabEmit := If(cTipoNF == "N","SA2","SA1")
			(cTabEmit)->(dbSetOrder(3))
			If (cTabEmit)->(dbSeek(xFilial(cTabEmit)+cCGC))
				cCodigo := (cTabEmit)->&(Substr(cTabEmit,2,2)+"_COD")
				cLoja   := (cTabEmit)->&(Substr(cTabEmit,2,2)+"_LOJA")
			Else
				If lJob
					AAdd(aErros,{cFile,If(cTipoNF=='N',"Fonecedor ","Cliente ") +oXML:_INFNFE:_EMIT:_XNOME:Text +" [" + Transform(cCGC,"@R 99.999.999/9999-99") +"] inexistente na base.","Gere cadastro para este fornecedor."})
				Else
					If !lMensExib
						Aviso("Erro",If(cTipoNF=='N',"Fonecedor ","Cliente ") + oXML:_INFNFE:_EMIT:_XNOME:Text +" [" + Transform(cCGC,"@R 99.999.999/9999-99") +"] inexistente na base.",{"OK"},2,"ReadXML")
						lMensExib := .T.
					EndIf
				EndIf

				lProces := .F.
			EndIf
		EndIf

		If lProces

			//-- Processa cabeçalho e itens
			if cTipoNF == "N"
				cAlias1 := "SA5"
				cCampo1 := "A5_PRODUTO"
				cCampo2 := "A5_FILIAL"
				cCampo3 := "A5_FORNECE"
				cCampo4 := "A5_LOJA"
				cCampo5 := "A5_CODPRF"
			elseif cTipoNF $ "B|D"
				cAlias1 := "SA7"
				cCampo1 := "A7_PRODUTO"
				cCampo2 := "A7_FILIAL"
				cCampo3 := "A7_CLIENTE"
				cCampo4 := "A7_LOJA"
				cCampo5 := "A7_CODCLI
			Endif

			//-- Cabecalho da nota fiscal de entrada
			AAdd(aCabecNFE, {"F1_TIPO"   	, cTipoNF  	, NIL}) //Tipo da Nota
			AAdd(aCabecNFE, {"F1_FORMUL" 	, ""      	, NIL}) //Formulario proprio
			AAdd(aCabecNFE, {"F1_DOC"		, cDoc    	, NIL}) //Numero do Documento
			AAdd(aCabecNFE, {"F1_SERIE"  	, cSerie  	, NIL}) //Serie
			AAdd(aCabecNFE, {"F1_FORNECE"	, cCodigo	, NIL}) //Fornecedor
			AAdd(aCabecNFE, {"F1_LOJA"   	, cLoja	  	, NIL}) //Loja do Fornecedor
			AAdd(aCabecNFE, {"F1_ESPECIE"	, "SPED"  	, NIL}) //Especie Documento
			//AAdd(aCabecNFE, {"F1_EMISSAO"	, StoD(StrTran(AllTrim(oXML:_InfNfe:_Ide:_DEmi:Text),"-",""))    	, NIL})  //Data de Emissão
			AAdd(aCabecNFE, {"F1_EMISSAO"	, Iif(oXML:_InfNfe:_VERSAO:TEXT >= "3.10", StoD(StrTran(AllTrim(Substr(oXML:_InfNfe:_Ide:_DHEMI:Text,1,10)),"-","")) , StoD(StrTran(AllTrim(oXML:_InfNfe:_Ide:_DEmi:Text),"-","")) ) , NIL})  //Data de Emissão
			AAdd(aCabecNFE, {"F1_CHVNFE"	, Iif(ValType("opNF:_InfNfe:_Id")<>"U",Right(AllTrim(oXML:_InfNfe:_Id:Text),44),"") , NIL})  //Chave de Acesso da NF

			cChvNfe := Iif(ValType("opNF:_InfNfe:_Id")<>"U",Right(AllTrim(oXML:_InfNfe:_Id:Text),44),"")

			oXMLPriv := oFullXML
			If Type("oXMLPriv:_NFEPROC:_PROTNFE:_INFPROT:_DHRECBTO:TEXT") <> "U"
				AAdd(aCabecNFE, {"F1_EMINFE"	, StoD(StrTran(Left(oFullXML:_NFEPROC:_PROTNFE:_INFPROT:_DHRECBTO:TEXT,10),"-","")) , NIL}) //Data Transmissao NFE
				AAdd(aCabecNFE, {"F1_HORNFE"	, Right(oFullXML:_NFEPROC:_PROTNFE:_INFPROT:_DHRECBTO:TEXT,8)						, NIL}) //Hora Transmissao NFE
			EndIf

			If SF1->(FieldPos('F1_U_DTXML')) > 0
				AAdd(aCabecNFE, {'F1_U_DTXML'	, dDataBase	  	    	, NIL}) //Data importacao do XML
			EndIf
			If SF1->(FieldPos('F1_U_HRXML')) > 0
				AAdd(aCabecNFE, {'F1_U_HRXML'	, SubStr(Time(),1,5)	, NIL}) //Hora importacao XML
			EndIf
			If SF1->(FieldPos('F1_U_ARXML')) > 0
				AAdd(aCabecNFE, {'F1_U_ARXML'	, SIGLAARQ + cFile      , NIL}) //Nome Arquivo XML
			EndIf

			DbSelectArea(cAlias1)
			(cAlias1)->(dbSetOrder(1))

			For nX := 1 To Len(aItens)
				cQuery := "SELECT " +cCampo1 +" FROM " +RetSqlName(cAlias1)
				cQuery += " WHERE D_E_L_E_T_ <> '*' AND "
				cQuery += cCampo2 +" = '" +xFilial(cAlias1) +"' AND "
				cQuery += cCampo3 +" = '" +cCodigo +"' AND "
				cQuery += cCampo4 +" = '" +cLoja +"' AND "
				cQuery += cCampo5 +" = '" +AllTrim(aItens[nX]:_Prod:_cProd:Text) +"'"

				If Select("TRB") > 0
					TRB->(dbCloseArea())
				EndIf

				TCQUERY cQuery ALIAS "TRB" NEW

				SB1->(dbSetOrder(1)) //-- B1_FILIAL + B1_COD

				//Se existe o ponto de entrada para tratamento de localizacao do produto especifica do cliente
				If ExistBlock("EXMLPROD")
					cProduto := ExecBlock("EXMLPROD",.F.,.F.,{PadR(AllTrim(aItens[nX]:_Prod:_cProd:Text),Len(SB1->B1_COD)), aItens, nX, oFullXML} )

					If ValType( cProduto ) <> "C"
						cProduto := ""
					EndIf

					SB1->(dbSetOrder(1)) //-- B1_FILIAL + B1_COD
					If !SB1->(dbSeek(xFilial('SB1') + cProduto ) )
						If lJob
							AAdd(aErros,{cFile,"Codigo do Produto nao encontrado.";
												+" Código " + AllTrim(aItens[nX]:_Prod:_cProd:Text) + ".","Gere cadastro para esta relação."})
						Else
							If !lMensExib
								Aviso("Erro","Fornecedor " + oXML:_INFNFE:_EMIT:_XNOME:Text +" [" +cCGC +"]";
											+" nao possui cadastro de Produto";
											+" para o código "+ AllTrim(aItens[nX]:_Prod:_cProd:Text) +".",{"OK"},2,"ReadXML")
								lMensExib := .T.
							EndIf
						EndIf

						lProces := .F.
					EndIf
				ElseIf !TRB->(EOF())
					cProduto := TRB->(&cCampo1)
				ElseIf SB1->(dbSeek(xFilial('SB1') + PadR(AllTrim(aItens[nX]:_Prod:_cProd:Text),Len(SB1->B1_COD)) ) )
					cProduto := SB1->B1_COD
				Else
					//Parametro não divulgado pois fica sob responsabilidade do consultor habilita-lo ou não
					If GetNewPar("ES_INCPROD",.F.)
						//Array com o produto a ser incluido
						aProd := {}
						AAdd(aProd, {"B1_COD"	  , PadR(AllTrim(aItens[nX]:_Prod:_cProd:Text),TamSX3("B1_COD")[1])           , NIL})
						AAdd(aProd, {"B1_DESC"	  , PadR(AllTrim(aItens[nX]:_Prod:_xProd:Text),TamSX3("B1_DESC")[1])          , NIL})
						AAdd(aProd, {"B1_TIPO"	  , "PA"                                                                      , NIL})
						AAdd(aProd, {"B1_UM"      , PadR(AllTrim(aItens[nX]:_Prod:_uCom:Text) ,TamSX3("B1_UM")[1])            , NIL})
						AAdd(aProd, {"B1_LOCPAD"  , "01"        															  , NIL})
						AAdd(aProd, {"B1_CONTRAT" , "N"                                                                       , NIL})
						AAdd(aProd, {"B1_LOCALIZ" , "N"                                                                       , NIL})
						AAdd(aProd, {"B1_POSIPI"  , PadR(AllTrim(aItens[nX]:_Prod:_NCM:Text) ,TamSX3("B1_POSIPI")[1])         , NIL})

						//P.E. para manipular a array de rotina automatica do Cad. de Produtos
						//Ponto de Entrada' não divulgado pois fica sob responsabilidade do consultor habilita-lo ou não
						If ExistBlock("EXMLINPR")
							aProd := ExecBlock("EXMLINPR",.F.,.F.,{aProd,oFullXML})
						EndIf

						lMsErroAuto := .F.
						MSExecAuto({|x,y| MATA010(x,y)},aProd,3)

						If lMsErroAuto
							If lJob
								MostraErro(DIRXML+DIRERRO,StrTran(Upper(cFile),".XML","_ERR.TXT"))
								AAdd(aErros,{cFile,"Erro na geração do Cadastro de Produtos.","Cheque o arquivo "+StrTran(Upper(cFile),".XML","_ERR.TXT")})
							Else
								MostraErro()
							EndIf
							lProces  := .F.
						Else
							cProduto := SB1->B1_COD
							lProces  := .T.

							/*If cTipoNF $ "B|D"
								CriaSA7(cCodigo,cLoja,cProduto)
							Else
								lProces := CriaSA5(cCodigo,cLoja,cProduto,lJob,cFile,@aErros)
							EndIf*/
						EndIf
				    Else
						If lJob
							AAdd(aErros,{cFile,"Codigo do Produto nao encontrado.";
												+" Código " + AllTrim(aItens[nX]:_Prod:_cProd:Text) + ".","Gere cadastro para esta relação."})
						Else
							If !lMensExib
								Aviso("Erro","Fornecedor " + oXML:_INFNFE:_EMIT:_XNOME:Text +" [" +cCGC +"]";
											+" nao possui cadastro de Produto";
											+" para o código "+ AllTrim(aItens[nX]:_Prod:_cProd:Text) +".",{"OK"},2,"ReadXML")
								lMensExib := .T.
							EndIf
						EndIf
						lProces := .F.
					EndIf
				EndIf

				If lProces
					If GetNewPar("ES_USAMAIL",2) == 1
						aNCMProd := {}
						aNCMProd := ExmlChkNCM( cProduto, PadL(aItens[nX]:_nItem:Text,TamSX3("D1_ITEM")[1],"0"), PadR(AllTrim(aItens[nX]:_Prod:_NCM:Text) ,TamSX3("B1_POSIPI")[1]) )
						If Len(aNCMProd) > 0
							Aadd(aNCMDiverg,aNCMProd)
						EndIf
					EndIf
				EndIf

				TRB->(dbCloseArea())

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se Unid. Medida foi preenchida na relacao Prod. x Forn. ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nQuant := Val(aItens[nX]:_Prod:_qCom:Text)
				If SA5->(dbSeek(xFilial("SA5")+cCodigo+cLoja+cProduto)) .And. SA5->A5_UMNFE == "2"
					nQuant := ConvUM(cProduto,Val(aItens[nX]:_Prod:_qCom:Text),Val(aItens[nX]:_Prod:_qCom:Text),1)
				EndIf
				
				aItemNFE := {}
				If aItens[nX]:_Prod:_RASTRO == "A"
					aRastro := aItens[nX]:_Prod:_RASTRO
				EndIf
				If Len(aRastro) > 0
					For nX := 1 to Len(aRastro)
						aItemNFE := {}
						AAdd(aItemNFE, {"D1_ITEM"		, PadL(aItens[nX]:_nItem:Text,TamSX3("D1_ITEM")[1],"0")                      	, NIL})
						AAdd(aItemNFE, {"D1_COD"		, cProduto                                                                     	, NIL})
						AAdd(aItemNFE, {"D1_QUANT"		, Val(aRastro[nX]:qLote:Text)													, NIL})
						AAdd(aItemNFE, {"D1_VUNIT"	 	, Round((Val(aItens[nX]:_Prod:_vProd:Text)/nQuant),TamSX3("D1_VUNIT")[2])    	, NIL})
						AAdd(aItemNFE, {"D1_TOTAL"	 	, Val(aItens[nX]:_Prod:_vProd:Text)                                           	, NIL})

						//-- Especifico DAXIA%
						AAdd(aItemNFE, {"D1_FCICOD" , aItens[nX]:_Prod:_nFCI:Text	, NIL})
						AAdd(aItemNFE, {"D1_LOTEFOR" , aItens[nX]:_Prod:_nLote:Text	, NIL})
						AAdd(aItemNFE, {"D1_DFABRIC" , StoD(StrTran(Left(aItens[nX]:_Prod:_dFab:Text,10),"-",""))	, NIL})
						AAdd(aItemNFE, {"D1_DTVALID" , StoD(StrTran(Left(aItens[nX]:_Prod:_dVal:Text,10),"-",""))	, NIL})

						//--------------------------------------
						// Informa o numero do Pedido de Compra
						//--------------------------------------
						oItemNfe := aItens[nX] //-- Carrega o Array para o Objeto devido limitacao da funcao Type
						If Type("oItemNfe:_Prod:_xPed:Text") <> 'U' .And. Type("oItemNfe:_Prod:_nItemPed:Text") <> 'U'

							cNumPed  := Strzero( val(aItens[nX]:_Prod:_xPed:Text),TamSX3("C7_NUM")[1])
							cItemPed := Strzero( val(AllTrim(aItens[nX]:_Prod:_nItemPed:Text)), TamSX3("C7_ITEM")[1] )

							SC7->(dbSetOrder(1)) //-- C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
							If SC7->( dbSeek(xFilial('SC7') + cNumPed + cItemPed) )
								AAdd(aItemNFE, {"D1_PEDIDO" 	, cNumPed   , NIL})
								AAdd(aItemNFE, {"D1_ITEMPC"	, cItemPed  , NIL})
							EndIf
						EndIf
						AAdd(aItensNFE, aItemNFE)
					Next				
				Else
				
					AAdd(aItemNFE, {"D1_ITEM"		, PadL(aItens[nX]:_nItem:Text,TamSX3("D1_ITEM")[1],"0")                      	, NIL})
					AAdd(aItemNFE, {"D1_COD"		, cProduto                                                                     	, NIL})
					AAdd(aItemNFE, {"D1_QUANT"		, nQuant                                                                       	, NIL})
					AAdd(aItemNFE, {"D1_VUNIT"	 	, Round((Val(aItens[nX]:_Prod:_vProd:Text)/nQuant),TamSX3("D1_VUNIT")[2])    	, NIL})
					AAdd(aItemNFE, {"D1_TOTAL"	 	, Val(aItens[nX]:_Prod:_vProd:Text)                                           	, NIL})

					//-- Especifico DAXIA%
					AAdd(aItemNFE, {"D1_FCICOD" , aItens[nX]:_Prod:_nFCI:Text	, NIL})
					AAdd(aItemNFE, {"D1_LOTEFOR" , aItens[nX]:_Prod:_nLote:Text	, NIL})
					AAdd(aItemNFE, {"D1_DFABRIC" , StoD(StrTran(Left(aItens[nX]:_Prod:_dFab:Text,10),"-",""))	, NIL})
					AAdd(aItemNFE, {"D1_DTVALID" , StoD(StrTran(Left(aItens[nX]:_Prod:_dVal:Text,10),"-",""))	, NIL})

					//--------------------------------------
					// Informa o numero do Pedido de Compra
					//--------------------------------------
					oItemNfe := aItens[nX] //-- Carrega o Array para o Objeto devido limitacao da funcao Type
					If Type("oItemNfe:_Prod:_xPed:Text") <> 'U' .And. Type("oItemNfe:_Prod:_nItemPed:Text") <> 'U'

						cNumPed  := Strzero( val(aItens[nX]:_Prod:_xPed:Text),TamSX3("C7_NUM")[1])
						cItemPed := Strzero( val(AllTrim(aItens[nX]:_Prod:_nItemPed:Text)), TamSX3("C7_ITEM")[1] )

						SC7->(dbSetOrder(1)) //-- C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
						If SC7->( dbSeek(xFilial('SC7') + cNumPed + cItemPed) )
							AAdd(aItemNFE, {"D1_PEDIDO" 	, cNumPed   , NIL})
							AAdd(aItemNFE, {"D1_ITEMPC"	, cItemPed  , NIL})
						EndIf
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Ponto de entrada para manutencao no aRetPE³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If ExistBlock("EXMLITD1")
						aRetPE := ExecBlock("EXMLITD1",.F.,.F.,{aItemNFE,aItens,nX,oFullXML} )

						If ValType(aRetPE) == "A" .And. !Empty( aRetPE )
							aItemNFE := aClone(aRetPE)
						EndIf
					EndIf

					AAdd(aItensNFE, aItemNFE)
				EndIf
			Next nX
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Realiza a consulta da chave da NFE para verificar se ela eh valida³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lProces
			If Len(aNCMDiverg) > 0
				TIBNCMAlert( aNCMDiverg, cDoc, cSerie )
			EndIf
			lProces := U_XMLCvNfe(cChvNfe,@aCabecNFE,@cFile,@aErros,@lMensExib,@lJob,1, cFile)
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³P.E. para validar a inclusao da Pre-NF de Entrada     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("EXMLVLNF")
			lVldNF := ExecBlock("EXMLVLNF",.F.,.F.,{aCabecNFE,aItensNFE,oFullXML} )
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava os dados do cabeçalho e itens da nota importada do XML³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lProces .And. lVldNF
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³P.E. antes de executar a inclusao da Pre-NF de Entrada³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ExistBlock("EXMLDOCE")
				aRetPE := ExecBlock("EXMLDOCE",.F.,.F.,{aCabecNFE,aItensNFE,oFullXML} )

				If ValType(aRetPE) == "A" .And. Len( aRetPE[1] ) == 2
					aCabecNFE := aClone(aRetPE[1,1])
					aItensNFE := aClone(aRetPE[1,2])
				EndIf
			EndIf

			lMsErroAuto := .F.
			MsExecAuto({|x,y,z| MATA140(x,y,z)},aCabecNFE,aItensNFE,3 )

			If lMsErroAuto
				If lJob
					MostraErro(DIRXML+DIRERRO,StrTran(Upper(cFile),".XML","_ERR.TXT"))
					AAdd(aErros,{cFile,"Erro na geração da Pré-Nota de Entrada.","Cheque o arquivo "+StrTran(Upper(cFile),".XML","_ERR.TXT")})
				Else
					MostraErro()
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se existir a NF, efetuar o anexo ao banco de conhecimento para nao³
				//³perder a referencia da NF                                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				SF1->( dbSetOrder(1) )
				If SF1->( dbSeek( xFilial("SF1") + cDoc + cSerie + cCodigo + cLoja) )

					AC9->( dbSetOrder(2) )
					If AC9->( !dbSeek( xFilial("AC9") + "SF1" + xFilial("SF1") + cDoc + cSerie + cCodigo + cLoja) )
						//---------------------------------------------
						// Anexa o arquivo XML ao Banco de Conhecimento
						//---------------------------------------------
						If File(DIRXML + DIRALER + cFile)
							SplitPath( DIRXML + DIRALER + cFile,,, @cDescri)

							//-- Anexa o arquivo XML ao Banco de Conhecimento
							If !(AllTrim(Upper(FunName())) $ "MATA103/MATA140/U_EXMLIMP")
								U_DIXConhec(DIRXML + DIRALER + cFile,cDescri,'SF1')
							Else
								CpyS2T( DIRXML + DIRALER + cFile, GetTempPatch(), .F. )
								If File(GetTempPatch() + cFile)
									U_DIXConhec(GetTempPatch() + cFile,cDescri,'SF1')
									FErase(GetTempPatch() + cFile)
								EndIf
							EndIf
						EndIf

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Acerta campos da NF³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If Empty(aCposAlt)
							AAdd( aCposAlt, "F1_EMINFE" )
							AAdd( aCposAlt, "F1_HORNFE" )
							AAdd( aCposAlt, "F1_U_DTXML")
							AAdd( aCposAlt, "F1_U_HRXML")
							AAdd( aCposAlt, "F1_U_ARXML")
							AAdd( aCposAlt, "F1_CHVNFE" )
							AAdd( aCposAlt, "F1_1_DTCNS")
							AAdd( aCposAlt, "F1_1_HRCNS")
							AAdd( aCposAlt, "F1_1_VRNFE")
							AAdd( aCposAlt, "F1_1_AMNFE")
							AAdd( aCposAlt, "F1_1_CRNFE")
							AAdd( aCposAlt, "F1_1_MRNFE")
							AAdd( aCposAlt, "F1_1_PRNFE")
							AAdd( aCposAlt, "F1_1_DVNFE")
							AAdd( aCposAlt, "F1_2_DTCNS")
							AAdd( aCposAlt, "F1_2_HRCNS")
							AAdd( aCposAlt, "F1_2_VRNFE")
							AAdd( aCposAlt, "F1_2_AMNFE")
							AAdd( aCposAlt, "F1_2_CRNFE")
							AAdd( aCposAlt, "F1_2_MRNFE")
							AAdd( aCposAlt, "F1_2_PRNFE")
							AAdd( aCposAlt, "F1_2_DVNFE")
						EndIf

						SF1->( RecLock("SF1",.F.) )
						For nZ := 1 to Len( aCposAlt )
							nPos := aScan( aCabecNFE, {|x| AllTrim(Upper(x[1])) == aCposAlt[nZ]} )
							If nPos > 0
								SF1->( FieldPut(FieldPos(aCposAlt[nZ]), aCabecNFE[nPos,2] ) )
							EndIf
						Next nZ
						SF1->( MsUnlock() )
					EndIf
				EndIf

				lProces := .F. //Nao prossegue pois houve erro de rotina automatica.
			Else
				//-- Move arquivo para pasta dos processados
				Copy File &(DIRXML+DIRALER+cFile) To &(DIRXML+DIRLIDO+cFile)
				FErase(DIRXML+DIRALER+cFile)

				AAdd(aProc,{cDoc,cSerie,Posicione("SA2",1,xFilial("SA2")+cCodigo+cLoja,"A2_NOME")})

				//---------------------------------------------
				// Anexa o arquivo XML ao Banco de Conhecimento
				//---------------------------------------------
				If File(DIRXML + DIRLIDO + cFile)
					SplitPath( DIRXML + DIRLIDO + cFile,,, @cDescri)

					//-- Anexa o arquivo XML ao Banco de Conhecimento
					U_DIXConhec(DIRXML + DIRLIDO + cFile,cDescri,'SF1')
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Ponto de entrada executado apos a gravacao da NFE³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ExistBlock("EXMLPSDE")
					ExecBlock( "EXMLPSDE",.F.,.F.,{aCabecNFE,aItensNFE,oFullXML,cFile} )
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

If !lProces .And. lDelFile
	//-- Move arquivo para pasta dos erros
	Copy File &(DIRXML+DIRALER+cFile) To &(DIRXML+DIRERRO+cFile)
	FErase(DIRXML+DIRALER+cFile)
EndIf

RestArea(aAreaSMO)
Return lProces


/*/{Protheus.doc} ExmlChkNCM
Checa se o NCM do produto na nota é igual ao NCM do produto no cadastro de produtos.

@return oView
@version 1.0
/*/
Static Function ExmlChkNCM( cProduto, cItem, cNCM )
Local aAreaSB1 := SB1->(GetArea())
Local lVldNCM  := GetNewPar("ES_VLDNCM",.F.)
Local aRet     := {}

If lVldNCM
	DbSelectArea("SB1")
	SB1->(DbSetOrder())
	If SB1->(DbSeek(xFilial("SB1")+cProduto))
		If AllTrim(SB1->B1_POSIPI) <> AllTrim(cNCM)
			aAdd( aRet, cItem          )
			aAdd( aRet, cProduto       )
			aAdd( aRet, cNCM           )
			aAdd( aRet, SB1->B1_POSIPI )
		EndIf
	EndIf
EndIf

RestArea( aAreaSB1 )

Return aRet

/*/{Protheus.doc} TIBNCMAlert
Envia e-mail alertando a divergência de NCM entre a NFE e o cadastro de produtos.

@return oView
@version 1.0
/*/
Static Function TIBNCMAlert( aProds, cDoc, cSerie )
Local cMailAdm   := GetMV('ES_MAILADM',.F.,'') //-- E-mail de notificacao Administrado Sistema
Local nCntFor1   := 0
Local cAssunto   := '[EXML] - Notificação Divergência Fiscal NFE vs Cadastro de Produtos'
Local cMensagem  := ""
Local aDadosHTML := {}
Local aItensErro := {}
Local aErrosHTML := {}

DEFAULT cDoc     := ""
DEFAULT cSerie   := ""

If Empty( cMailAdm )
	Return Nil
EndIf

//----------------------------------------
// DADOS DO ARQUIVO
//----------------------------------------
If !Empty(cDoc) .AND. !Empty(cSerie)
    Aadd(aDadosHTML,"NFE: "+cDoc)
    Aadd(aDadosHTML,"Serie: "+cSerie)
Else
    Aadd(aDadosHTML,"")
    Aadd(aDadosHTML,"")
EndIf

//--Determina as propriedades
cMensagem := GetHTMLMessage( "exml060", aDadosHTML, aProds )

EXMLSendMail(cMailAdm,cAssunto,cMensagem)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³DIXPopOn  ³AUTOR  ³FELIPE NUNES DE TOLEDO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Funcao responsavel pela verificacao da Caixa de Entrada    ³±±
±±³          ³ do e-mail para recebimento do arquivo XML.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³PARAMETROS³ cMailServer : Endereco do servidor de e-mail               ³±±
±±³          ³ cUserMail   : Nome do Usuario do E-mail                    ³±±
±±³          ³ cPassMail   : Senha do e-mail                              ³±±
±±³          ³ nPortPop    : Porta de concexao POP3                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function DIXPopOn(cMailServer,cUserMail,cPassMail,nPortPop)
Local oPOPManager := Nil
Local oMessage    := NIl
Local nNumMsg     := 0
Local nNumAttach  := 0
Local nCntFor1    := 0
Local nCntFor2    := 0
Local aInfAttach  := {}
Local cRootPath   := AllTrim( GetSrvProfString( "RootPath","" ) )
Local lUsaSSl     := GetMv("MV_RELSSL")
Local nRet        := 0
Local cProtocol   := AllTrim(Upper(GetPvProfString("MAIL", "PROTOCOL", "POP3", GetAdv97())))

DEFAULT nPortPop  := 110

// CONEXAO POP ---------------------------------------
oPOPManager:= tMailManager():New()
oPOPManager:SetUseSSL(lUsaSSl)
oPOPManager:Init(cMailServer, "", cUserMail, cPassMail, nPortPop, 0 )

If oPOPManager:SetPopTimeOut( 60 ) != 0
	Conout( "[POPCONNECT] Falha ao setar o time out" )
	Return .F.
EndIf

If cProtocol == "POP3"
	nRet := oPOPManager:POPConnect()
ElseIf cProtocol == "IMAP"
	nRet := oPOPManager:IMAPConnect()
EndIf

If nRet != 0
	Conout("[POPCONNECT] Falha ao conectar" )
	Conout("[POPCONNECT][ERROR] " + str(nRet,6) , oPOPManager:GetErrorString(nRet))
	Return .F.
Else
	Conout( "[POPCONNECT] Sucesso ao conectar" )
EndIf

//Quantidade de mensagens
oPOPManager:GetNumMsgs( @nNumMsg )

If nNumMsg > 0
	For nCntFor1 := 1 To nNumMsg
		//inicia Objeto
		oMessage := tMailMessage():new()
		//Limpa o objeto da mensagem
		oMessage:Clear()
		//Recebe a mensagem do servidor
		oMessage:Receive( oPOPManager, nCntFor1 )

		//Quantidade de anexos na mensagem
		nNumAttach := oMessage:GetAttachCount()

		//Escreve no server os dados do e-mail recebido
		Conout( CRLF )
		Conout( "[POPCONNECT] Email Numero: " + AllTrim(Str(nCntFor1)) )
		Conout( "[POPCONNECT] De:      " + oMessage:cFrom )
		Conout( "[POPCONNECT] Para:    " + oMessage:cTo )
		Conout( "[POPCONNECT] Copia:   " + oMessage:cCc )
		Conout( "[POPCONNECT] Assunto: " + oMessage:cSubject )

		// recebe o anexo da mensagem em string
		For nCntFor2 := 1 To nNumAttach
			aInfAttach := oMessage:GetAttachInfo(nCntFor2)
			If !Empty(aInfAttach[1]) .And. Upper(Right(AllTrim(aInfAttach[1]),4)) == '.XML'
				//Salva Anexo na pasta
				If oMessage:SaveAttach(nCntFor2, cRootPath +"\"+ DIRXML + DIRALER + aInfAttach[1])
					Conout( "[POPCONNECT] Anexo " + AllTrim(Str(nCntFor2)) + ": " + aInfAttach[1] )
				Else
					Conout( "[POPCONNECT] Erro ao salvar anexo " + AllTrim(Str(nCntFor2)) + ": " + aInfAttach[1] )
				EndIf
			ElseIf !Empty(aInfAttach[1]) .And. Upper(Right(AllTrim(aInfAttach[1]),4)) == '.PDF'
				//Salva Anexo na pasta
				If oMessage:SaveAttach(nCntFor2, cRootPath +"\"+ DIRXML + DIRDANFE + aInfAttach[1])
					Conout( "[POPCONNECT] Anexo " + AllTrim(Str(nCntFor2)) + ": " + aInfAttach[1] )
				Else
					Conout( "[POPCONNECT] Erro ao salvar anexo " + AllTrim(Str(nCntFor2)) + ": " + aInfAttach[1] )
				EndIf
			EndIf
		Next nCntFor2

		//Deleta a mensagens do servidor
		oPOPManager:DeleteMsg( nCntFor1 )

		Conout( CRLF )
	Next nCntFor1
Else
	ConOut("[POPCONNECT] Nao ha mensagens pendentes para processamento. Desconectando...")
EndIf

//Desconecta do servidor POP
oPOPManager:POPDisconnect()

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³DIXSMail  ³Autor  ³FELIPE NUNES DE TOLEDO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Envia e-mail com a notificacao de inconsistencia na        ³±±
±±³          ³ importacao do arquivo XML de Entrada.                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DIXSMail(aErro,cFileXML,aAttach,aInfNFE)
Local oProcess   := Nil
Local cMailAdm   := GetMV('ES_MAILADM',.F.,'') //-- E-mail de notificacao Administrado Sistema
Local nCntFor1   := 0
Local cAssunto   := '[EXML] - Notificação Inconsistência Importação NFE'
Local cMensagem  := ""
Local aDadosHTML := {}
Local aItensErro := {}
Local aErrosHTML := {}

DEFAULT aAttach := {}

If Empty( cMailAdm )
	Return Nil
EndIf

//----------------------------------------
// DADOS DO ARQUIVO
//----------------------------------------
Aadd(aDadosHTML,{'cNomeXML' , cFileXML })
If Len(aInfNFE) > 0
    Aadd(aDadosHTML,{'cNomeFor' , aInfNFE[1] })
    Aadd(aDadosHTML,{'cCNPJFor' , aInfNFE[2] })
    Aadd(aDadosHTML,{'cDoc'     , aInfNFE[3] })
    Aadd(aDadosHTML,{'cSerie'   , aInfNFE[4] })
    Aadd(aDadosHTML,{'cNomeDest', aInfNFE[5] })
    Aadd(aDadosHTML,{'cCNPJDest', aInfNFE[6] })
Else
    Aadd(aDadosHTML,{'cNomeFor' , ' - ' })
    Aadd(aDadosHTML,{'cCNPJFor' , ' - ' })
    Aadd(aDadosHTML,{'cDoc'     , ' - ' })
    Aadd(aDadosHTML,{'cSerie'   , ' - ' })
    Aadd(aDadosHTML,{'cNomeDest', ' - ' })
    Aadd(aDadosHTML,{'cCNPJDest', ' - ' })
EndIf

//----------------------------------------
// INCONSISTENCIAS
//----------------------------------------
For nCntFor1 := 1 To Len(aErro)
    aItensErro := {}

    AAdd(aItensErro,{'ERRO.cMotivo'  , If(ValType(aErro[nCntFor1][2])=='C',aErro[nCntFor1][2],'')} )
    AAdd(aItensErro,{'ERRO.cSolucao' , If(ValType(aErro[nCntFor1][3])=='C',aErro[nCntFor1][3],'')} )

    aAdd(aErrosHTML, aItensErro)
Next nCntFor1

//--Determina as propriedades
cMensagem := GetHTMLMessage( "exml020", aDadosHTML, aErrosHTML )

EXMLSendMail(cMailAdm,cAssunto,cMensagem,aAttach)

Return Nil

/*/{Protheus.doc} EXMLSendMail
Realiza o envio de e-mail.

@author  Leandro Faggyas Dourado
@since   03/07/2015
@version 1.0
@param   cDestinat, character, Destinatario do e-mail
@param   cAssunto , character, Assunto do e-mail
@param   cMensagem, character, Mensagem (corpo) do e-mail
@return  lRet     , Retorna verdadeiro ou falso se a mensagem foi enviada
/*/
Static Function EXMLSendMail(cDestinat,cAssunto,cMensagem, aAnexos, lTeste)
Local lRet			:= .T.
Local cTO			:= ""
Local cCC			:= ""
Local cFrom		    := GETMV("MV_RELFROM",.F.,"")
Local cSMTPServer	:= GETMV("MV_RELSERV",.F.,"")
Local cSMTPUser 	:= GETMV("MV_RELACNT",.F.,"")
Local cSMTPPass 	:= GETMV("MV_RELPSW" ,.F.,"")

Local lTLS		 	:= GETMV("MV_RELTLS" ,.F.,.F.)
Local lUsaSSL		:= GetMV("MV_RELSSL",.F.)

Local nSMTPPort	    := GetNewPar('MV_GCPPORT',25)
Local oMail		    := Nil
Local oMessage  	:= Nil
Local nErro		    := 0
Local cErro         := ""
Local nEmail		:= 0
Local lRelAuth 	    := GetMv("MV_RELAUTH",.F., .F.)
Local nTimeout      := GetNewPar('MV_RELTIME',120)
Local nX            := 0

DEFAULT cDestinat	:= ""
DEFAULT cAssunto	:= ""
DEFAULT cMensagem	:= ""
DEFAULT aAnexos     := {}
DEFAULT lTeste      := .F.

Private cError		:= ""
Private lSendOk	:=	.T.

/*
 * Envio de e-mail só ocorre se existir destinatário
 */
If !Empty(cDestinat)
//	cTo := cDestinat

	If At(":",cSMTPServer) > 0
		cSMTPServer := SubStr(cSMTPServer,1,At(":",cSMTPServer)-1)//":"+AllTrim(Str(nSMTPPort))
	EndIf

	/*
	 * Iniciando conexão com o servidor de e-mails
	 */
	oMail := TMailManager():New()
	oMail:SetUseTLS(lTLS)
	oMail:SetUseSSL(lUsaSSL)
	oMail:Init( '', cSMTPServer , cSMTPUser, cSMTPPass, 0, nSMTPPort  )
	oMail:SetSmtpTimeOut( nTimeout )
	nErro := oMail:SmtpConnect()

	/*
	 * Autenticando o usuário no servidor de e-mails
	 */
	If lRelAuth
		nErro := oMail:SmtpAuth(cSMTPUser ,cSMTPPass)

		If nErro <> 0

			// Recupera erro ...
			cMAilError := oMail:GetErrorString(nErro)
			DEFAULT cMailError := '***UNKNOW***'
			Conout("Erro de Autenticacao "+str(nErro,4)+' ('+cMAilError+')')
			lRet := .F.
		Endif
	EndIf

	If nErro <> 0
		// Recupera erro
		cMAilError := oMail:GetErrorString(nErro)
		DEFAULT cMailError := '***UNKNOW***'
		conout(cMAilError)

		oMail:SMTPDisconnect()
		lRet := .F.
	Endif

	/*
	 * Criando o objeto da mensagem do e-mail
	 */
	 oMessage := TMailMessage():New()
	oMessage:Clear()
	oMessage:cFrom		:= cFrom
	oMessage:cTo		:= cDestinat
	oMessage:cBcc		:= cCC
	oMessage:cSubject	:= cAssunto
	oMessage:cBody		:= cMensagem
	oMessage:MsgBodyType( "text/html" )

    For nX := 1 to Len(aAnexos)
        If File(aAnexos[nX])
            If oMessage:AttachFile(aAnexos[nX]) < 0
                // TO DO: Tratar erro ao anexar arquivo.
            EndIf
        EndIf
    Next nX

	nErro := oMessage:Send( oMail )

	If nErro <> 0
		cErro := oMail:GetErrorString(nErro)
		If lTeste
			MsgStop("Erro de Envio SMTP "+str(nErro,4)+" ("+cErro+")")
		Else
			Conout("Erro de Envio SMTP "+str(nErro,4)+" ("+cErro+")")
		EndIf
		lRet := .F.
	Else
		If lTeste
			MsgStop("Enviado com sucesso!!!")
		EndIf
	Endif

	oMail:SMTPDisconnect()
Else
	CONOUT("Sem destinatários para envio do e-mail.")
	lRet := .F.
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³DIXCancNFe³Autor  ³FELIPE NUNES DE TOLEDO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Realiza a exclusao da pre nota de entrada.                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DIXCancNFe()
Local aCabecNFE := {}
Local aItemNFE  := {}
Local aItensNFE := {}
Local lRet      := .T.

Private lMsErroAuto := .F.

//-- Cabecalho da pre nota de entrada
AAdd(aCabecNFE, {"F1_FILIAL" 	, SF1->F1_FILIAL 	, NIL}) //Filial
AAdd(aCabecNFE, {"F1_TIPO"   	, SF1->F1_TIPO   	, NIL}) //Tipo da Nota
AAdd(aCabecNFE, {"F1_FORMUL" 	, SF1->F1_FORMUL 	, NIL}) //Formulario proprio
AAdd(aCabecNFE, {"F1_DOC"		, SF1->F1_DOC    	, NIL}) //Numero do Documento
AAdd(aCabecNFE, {"F1_SERIE"  	, SF1->F1_SERIE  	, NIL}) //Serie
AAdd(aCabecNFE, {"F1_FORNECE"	, SF1->F1_FORNECE	, NIL}) //Fornecedor
AAdd(aCabecNFE, {"F1_LOJA"   	, SF1->F1_LOJA	  	, NIL}) //Loja do Fornecedor
AAdd(aCabecNFE, {"F1_ESPECIE"	, SF1->F1_ESPECIE	, NIL}) //Especie Documento
AAdd(aCabecNFE, {"F1_EMISSAO"	, SF1->F1_EMISSAO	, NIL}) //Data de Emissão

SD1->(dbSetOrder(1))
SD1->(dbSeek(SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))
Do While SD1->( !Eof() ) .And. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
	aItemNFE := {}
	AAdd(aItemNFE, {"D1_FILIAL" 	, SD1->D1_FILIAL 	, NIL})
	AAdd(aItemNFE, {"D1_ITEM"		, SD1->D1_ITEM	  	, NIL})
	AAdd(aItemNFE, {"D1_COD"		, SD1->D1_COD	  	, NIL})
	AAdd(aItemNFE, {"D1_QUANT"		, SD1->D1_QUANT 	, NIL})
	AAdd(aItemNFE, {"D1_VUNIT"	 	, SD1->D1_VUNIT  	, NIL})
	AAdd(aItemNFE, {"D1_TOTAL"	 	, SD1->D1_TOTAL  	, NIL})

	AAdd(aItensNFE, aItemNFE)

	SD1->(DbSkip())
EndDo

MsExecAuto({|x,y,z| MATA140(x,y,z)},aCabecNFE,aItensNFE,5 )

lRet := !lMsErroAuto

Return( lRet )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³DIXSMCanc ³Autor  ³FELIPE NUNES DE TOLEDO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Envia e-mail notificando o cancelamento de uma Nota Fiscal ³±±
±±³          ³ de Entrada.                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DIXSMCanc(aInfDoc,lExcNfCan)
Local oProcess  := Nil
Local cMailAdm  := GetMV('ES_MAILADM',.F.,'') //-- E-mail de notificacao Administrado Sistema
Local cAssunto  := ""
Local cMensagem := ""
Local aDadosHTML:= {}
Local cObserv   := ''

If Empty( cMailAdm )
	Return Nil
EndIf

//--------------------------------
// aInfDoc
// [1] F1_FILIAL
// [2] F1_DOC
// [3] F1_SERIE
// [4] F1_FORNECE
// [5] F1_LOJA
// [6] F1_EMISSAO
// [7] F1_U_DTXML
// [8] F1_U_HRXML
//--------------------------------

SA2->( dbSetOrder(1) ) //-- A2_LOJA + A2_COD + A2_LOJA
SA2->( dbSeek( U_DIXRetFil('SA2',aInfDoc[1]) + aInfDoc[4] + aInfDoc[5] ) )

cAssunto := "[EXML] - " + AllTrim(aInfDoc[1]) + ' Notificação Cancelamento de NFE '

If lExcNfCan
    cObserv := 'Pre Nota de Entrada excluida com sucesso !!'
Else
    cObserv := 'Nao foi possivel realizar a exclusao da Pre Nota de Entrada. Favor verificar as movimentacoes da Pre Nota.'
EndIf

Aadd(aDadosHTML,{'NFE.cFilial'  , aInfDoc[1]  })
AAdd(aDadosHTML,{'NFE.cFornece' , SA2->A2_NOME})
AAdd(aDadosHTML,{'NFE.cCodLoja' , aInfDoc[4] + "/" + aInfDoc[5]} )
AAdd(aDadosHTML,{'NFE.cDoc'     , aInfDoc[2]  })
AAdd(aDadosHTML,{'NFE.cSerie'   , aInfDoc[3]  })
AAdd(aDadosHTML,{'NFE.cDtEmis'  , aInfDoc[6]  })
AAdd(aDadosHTML,{'NFE.cDtInc'   , aInfDoc[7]  })
AAdd(aDadosHTML,{'NFE.cHrInc'   , aInfDoc[8]  })
aAdd(aDadosHTML,{'cObserv'      , cObserv     })

cMensagem := GetHTMLMessage( "exml040", aDadosHTML )

EXMLSendMail(cMailAdm,cAssunto,cMensagem)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³DIXRetFil ³Autor  ³FELIPE NUNES DE TOLEDO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Retorna o codigo da Filial do Alias                        ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function DIXRetFil(cCodTab,cFilTab)
Local aAreaAnt := GetArea()

dbSelectArea(cCodTab)
If Empty(FWFilial(cCodTab))
	cRet := FWFilial(cCodTab)
Else
	cRet := cFilTab
EndIf

RestArea( aAreaAnt )
Return( cRet )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³DIXLocNFE ³Autor  ³FELIPE NUNES DE TOLEDO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Localiza a Nota Fiscal pela Chave da NFe.                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DIXLocNFE(cChvNFCan)
Local lRet        := .F.
Local cAliasQry   := GetNextAlias()

DEFAULT cChvNFCan := ''

BeginSql Alias cAliasQry
	SELECT
	R_E_C_N_O_ RecNo
	FROM %Table:SF1% SF1
	WHERE
	SF1.%notdel%
	AND SF1.F1_CHVNFE = %Exp:cChvNFCan%
EndSql

If (cAliasQry)->( !Eof() )
	SF1->( DbGoTo( (cAliasQry)->RecNo ) )
	lRet := .T.
EndIf

(cAliasQry)->( DbCloseArea() )

Return( lRet )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³DIXJOBPEN ³Autor  ³FELIPE NUNES DE TOLEDO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Job para envio de notificacao com as Pre Notas Pendentes   ³±±
±±³          ³ de classificacao.                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observ.   ³ Configuracao appserver.ini                                 ³±±
±±³          ³                                                            ³±±
±±³          ³ [ONSTART]                                                  ³±±
±±³          ³ Jobs=DIXJOBPEN                                             ³±±
±±³          ³ RefreshRate=180                                            ³±±
±±³          ³                                                            ³±±
±±³          ³ [DIXJOBPEN]                                                ³±±
±±³          ³ Main=U_DIXJOBPEN                                           ³±±
±±³          ³ Environment=<nome ambiente>                                ³±±
±±³          ³ Empresa=<codigo empresa>                                   ³±±
±±³          ³ Filial=<codigo filial>                                     ³±±
±±³          ³ Intervalo=<numero em horas de intervalo p/ execucao>       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function DIXJOBPEN(cCodEmp,cCodFil)
Local cMailAdm    := ""
Local cUltProc    := ""
Local nIntervalo  := Val(GetJobProfString('Intervalo' , '1')) //-- Intervalo em Horas
Local dDtUlt      := CtoD("01/01/00")
Local cHrUlt      := ""

DEFAULT cCodEmp   := GetJobProfString('Empresa', '01')
DEFAULT cCodFil   := GetJobProfString('Filial' , '01')

Conout('[DIXJOBPEN] Empresa: ' + cCodEmp + ' Filial: ' + cCodFil)

// Seta job para nao consumir licensas
RpcSetType(3)

RPCSetEnv( cCodEmp, cCodFil,,, "COM")

cUltProc  := SuperGetMV('ES_ULTPROC',.F.,'2000010101:00') //-- Data + Hora do Ultimo Processamento

dDtUlt  := StoD( Substring(cUltProc,1,8) )
cHrUlt  := Substring(cUltProc,9,5)

If SomaDiaHor(@dDtUlt,@cHrUlt,nIntervalo) .And.;
	Date() >= dDtUlt .And. Time() >= cHrUlt

	//-- Servidor de E-mail POP para Recebimento do XML
	cMailAdm  := GetMV('ES_MAILADM',.F.,'') //-- E-mail de notificacao Administrado Sistema

	If !Empty( cMailAdm )
		//-- Acessa Caixa de E-mail e recebe o arquivo XML anexado
		U_DIXPenNFE(cMailAdm)
	EndIf

	PutMV( 'ES_ULTPROC', DtoS(Date())+Left(Time(),5) )
EndIf


RPCClearEnv()

Return Nil
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³DIXPenNFE ³Autor  ³FELIPE NUNES DE TOLEDO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Envia e-mail com a notificacao de pendencia de Classifica_ ³±±
±±³          ³ cao da Pre Nota de Entrada.                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function DIXPenNFE(cMailAdm)
Local aArea      := GetArea()
Local cAliasQry  := GetNextAlias()
Local cFilSA2    := ''
Local oProcess   := Nil
Local cAssunto   := ""
Local cMensagem  := ""
Local aDadosHTML := {}
Local aItensHTML := {}

cFilSA2 := "%"
If Empty( xFilial('SA2') )
	cFilSA2 += "AND SA2.A2_FILIAL  = ' '"
Else
	cFilSA2 += "AND SA2.A2_FILIAL  = SF1.F1_FILIAL"
EndIf
cFilSA2 += "%"

BeginSql Alias cAliasQry
	COLUMN F1_EMISSAO AS DATE
	COLUMN F1_U_DTXML AS DATE

	SELECT F1_FILIAL, A2_NOME, F1_FORNECE, F1_LOJA, F1_DOC, F1_SERIE, F1_EMISSAO, F1_U_DTXML, F1_U_HRXML
	FROM %table:SF1% SF1
	INNER JOIN %table:SA2% SA2 ON
	SA2.%NotDel%
	%Exp:cFilSA2%
	AND SA2.A2_COD     = SF1.F1_FORNECE
	AND SA2.A2_LOJA    = SF1.F1_LOJA
	WHERE
	SF1.%NotDel%
	ORDER BY SF1.F1_FILIAL, SA2.A2_NOME, SF1.F1_DOC, SF1.F1_SERIE
EndSql

If (cAliasQry)->( !Eof() )

    //--Determina as propriedades
    cAssunto  := "[EXML] - " + AllTrim((cAliasQry)->F1_FILIAL) + ' Notificação de Pendência de Conferência da Pre Nota de Entrada '

	Do While (cAliasQry)->( !Eof() )

	    aItensHTML := {} // Zera as informacoes para preenchimento da proxima linha

		//----------------------------------------
		// DOCUMENTOS
		//----------------------------------------
		Aadd(aItensHTML,{'NFE.cFilial' , (cAliasQry)->F1_FILIAL                                  })
        Aadd(aItensHTML,{'NFE.cFornece', (cAliasQry)->A2_NOME                                    })
        Aadd(aItensHTML,{'NFE.cCodLoja', (cAliasQry)->(F1_FORNECE) + "/" + (cAliasQry)->(F1_LOJA)})
        Aadd(aItensHTML,{'NFE.cDoc'    , (cAliasQry)->F1_DOC                                     })
        Aadd(aItensHTML,{'NFE.cSerie'  , (cAliasQry)->F1_SERIE                                   })
        Aadd(aItensHTML,{'NFE.cDtEmis' , DtoC((cAliasQry)->F1_EMISSAO)                           })
        Aadd(aItensHTML,{'NFE.cDtInc'  , DtoC((cAliasQry)->F1_U_DTXML)                           })
        Aadd(aItensHTML,{'NFE.cHrInc'  , (cAliasQry)->F1_U_HRXML                                 })

        aAdd(aDadosHTML,aItensHTML)

		(cAliasQry)->( DbSkip() )
	EndDo

	cMensagem := GetHTMLMessage( "exml030", aDadosHTML )

	EXMLSendMail(cMailAdm,cAssunto,cMensagem)
EndIf

dbSelectArea(cAliasQry)
DbCloseArea()

RestArea( aArea )

Return Nil

/*/{Protheus.doc} EXMLCadCli
Cadastro automático de clientes, com base no arquivo XML da nota fiscal de entrada quando a operação for de beneficiamento ou devolução.

@author  Leandro Faggyas Dourado
@since   07/07/2015
@version 1.0
@param   cDestinat, character, Destinatario do e-mail
@return  lRet     , Retorna verdadeiro ou falso se o cliente foi cadastrado
/*/
Static Function EXMLCadCli(cCGC,oXML,cFile,aErros,lJob,lMensExib)
Local aArea    := GetArea()
Local aAreaSA1 := SA1->(GetArea())
Local cNome    := ''
Local cNReduz  := ''
Local cEndere  := ''
Local cNroEnd  := ''
Local cBairro  := ''
Local cUF      := ''
Local cCep     := ''
Local cCodMun  := ''
Local cCodPais := ''
Local cFone    := ''
Local cInscr   := ''
Local cInscrM  := ''
Local lCadCli  := (GetNewPar("ES_CDNWCLI",2) == 1)
Local aCliente := {}
Local cCodCli  := ""
Local cLojCli  := ""
Local oInfEmit := Nil
Local lRet     := .T.

DEFAULT oXml   := Nil

Private lMsErroAuto := .F.

IF ValType(oXML) == "O"
	oInfEmit := oXML:_INFNFE:_EMIT
EndIf

SA1->(dbSetOrder(3)) //-- A1_FILIAL + A1_CGC
If oInfEmit <> Nil .AND. !SA1->(dbSeek(xFilial('SA1') + cCGC))
	If lCadCli
		cCodCli  := SA1->( U_DXGetSXE( "SA1","A1_COD",1 ) )
		cLojCli  := "01"
		If __lSX8
			ConfirmSX8()
		EndIf
		cRazao   := IF(XmlChildEx( oInfEmit, "_XNOME" ) <> Nil,oInfEmit:_XNOME:Text                                  ,'')
		// Caso o XML venha sem o campo com o nome fantasia, faz o cadastro utilizando a razão social
		cNReduz  := IF(XmlChildEx( oInfEmit, "_XFANT" ) <> Nil,oInfEmit:_XFANT:Text                                  ,cRazao)
		cInscr   := IF(XmlChildEx( oInfEmit, "_IE"    ) <> Nil,oInfEmit:_IE:Text                                     ,'')
		cInscrM  := IF(XmlChildEx( oInfEmit, "_IM"    ) <> Nil,oInfEmit:_IM:Text                                     ,'')
		cEndere  := IF(XmlChildEx( oInfEmit:_ENDEREMIT, "_XLGR"   ) <> Nil,oInfEmit:_ENDEREMIT:_xLgr:Text            ,'')
		cNroEnd  := IF(XmlChildEx( oInfEmit:_ENDEREMIT, "_NRO"    ) <> Nil,oInfEmit:_ENDEREMIT:_Nro:Text             ,'')
		cBairro  := IF(XmlChildEx( oInfEmit:_ENDEREMIT, "_XBAIRRO") <> Nil,oInfEmit:_ENDEREMIT:_xBairro:Text         ,'')
		cUF      := IF(XmlChildEx( oInfEmit:_ENDEREMIT, "_UF"     ) <> Nil,oInfEmit:_ENDEREMIT:_UF:Text              ,'')
		cCep     := IF(XmlChildEx( oInfEmit:_ENDEREMIT, "_CEP"    ) <> Nil,oInfEmit:_ENDEREMIT:_CEP:Text             ,'')
		cCodMun  := IF(XmlChildEx( oInfEmit:_ENDEREMIT, "_CMUN"   ) <> Nil,Substr(oInfEmit:_ENDEREMIT:_cMun:Text,3,5),'')
		cCodPais := IF(XmlChildEx( oInfEmit:_ENDEREMIT, "_CPAIS"  ) <> Nil,'0' + oInfEmit:_ENDEREMIT:_cPais:Text     ,'')
		cFone    := IF(XmlChildEx( oInfEmit:_ENDEREMIT, "_FONE"   ) <> Nil,oInfEmit:_ENDEREMIT:_Fone:Text            ,'')

		aCliente :={{"A1_COD"       	,cCodCli                               	,Nil},;
					{"A1_LOJA"       	,cLojCli                               	,Nil},;
					{"A1_NOME"       	,cRazao                                	,Nil},;
					{"A1_NREDUZ"     	,cNReduz                               	,Nil},;
					{"A1_CGC"        	,cCGC                                  	,Nil},;
					{"A1_PESSOA"       	,If(Len(AllTrim(cCGC))< 14,'F','J')   	,Nil},;
					{"A1_END"        	,cEndere + ', ' + cNroEnd              	,Nil},;
					{"A1_BAIRRO"     	,cBairro                               	,Nil},;
					{"A1_EST"        	,cUF                                   	,Nil},;
					{"A1_CEP"        	,cCep                                  	,Nil},;
					{"A1_COD_MUN"    	,cCodMun                               	,Nil},;
					{"A1_CODPAIS"    	,cCodPais                              	,Nil},;
					{"A1_TEL"        	,cFone                                 	,Nil},;
					{"A1_COND"       	,GetMV('ES_CONPGNF',.F.,'')       		,Nil},;
					{"A1_INSCR"      	,cInscr                                	,Nil},;
					{"A1_INSCRM"     	,cInscrM                               	,Nil},;
					{"A1_TIPO"          ,"F"                                    ,Nil}} // TO DO: Verificar de onde pegar essa informação

		lMsErroAuto := .F.

		MSExecAuto({|x,y| MATA030(x,y)},aCliente,3)

		If lMsErroAuto
			If lJob
				MostraErro(DIRXML+DIRERRO,StrTran(Upper(cFile),".XML","_ERR.TXT"))
				AAdd(aErros,{cFile,"Erro no cadastramento do Cliente.","Cheque o arquivo "+StrTran(Upper(cFile),".XML","_ERR.TXT")})
			Else
				MostraErro()
			EndIf

			lRet := .F.
		EndIf
	Else
		If lJob
			AAdd(aErros,{cFile,"Cliente " +oXML:_INFNFE:_EMIT:_XNOME:Text +" [" + Transform(cCGC,"@R 99.999.999/9999-99") +"] inexistente na base.","Gere cadastro para este Cliente."})
		Else
			If !lMensExib
				Aviso("Erro","Cliente "   +oXML:_INFNFE:_EMIT:_XNOME:Text +" [" + Transform(cCGC,"@R 99.999.999/9999-99") +"] inexistente na base.",{"OK"},2,"ReadXML")
				lMensExib := .T.
			EndIf
		EndIf

		lRet := .F.
	EndIf

EndIf

RestArea( aArea )
RestArea( aAreaSA1 )

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³DIXFornec ³Autor  ³FELIPE NUNES DE TOLEDO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Cadastramento automatico do Fornecedor, com base no arqui_ ³±±
±±³          ³ vo XML da Nota Fiscal de Entrada.                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DIXFornec(cCGC,oXML,cFile,aErros,lJob,lMensExib,cTipoNF)
Local aAreaAnt := GetArea()
Local aAreaSA2 := SA2->( GetArea() )
Local cNome    := ''
Local cNReduz  := ''
Local cEndere  := ''
Local cNroEnd  := ''
Local cBairro  := ''
Local cUF      := ''
Local cCep     := ''
Local cCodMun  := ''
Local cCodPais := ''
Local cFone    := ''
Local cInscr   := ''
Local cInscrM  := ''
Local lRet     := .T.
Local lCadFor  := (GetNewPar("ES_CDNWFOR",2) == 1)
Local cCodFor  := ""
Local cLojFor  := ""
Local aRetPE   := {}
//Local nSaveSX8 := 0
//Local cMay     := ""

Private oInfEmit    := oXML:_INFNFE:_EMIT
Private lMsErroAuto := .F.

SA2->(dbSetOrder(3)) //-- A2_FILIAL + A2_CGC
If !SA2->(dbSeek(xFilial('SA2') + cCGC))

	If lCadFor
		cRazao   := IF(Type("oInfEmit:_XNOME:Text")=='C',oInfEmit:_XNOME:Text,'')
		cNReduz  := IF(Type("oInfEmit:_XFANT:Text")=='C',oInfEmit:_XFANT:Text,'')
		If Empty(cNReduz)
			cNReduz := cRazao
		EndIf
		cEndere  := IF(Type("oInfEmit:_ENDEREMIT:_xLgr:Text" )=='C',oInfEmit:_ENDEREMIT:_xLgr:Text,'')
		cNroEnd  := IF(Type("oInfEmit:_ENDEREMIT:_Nro:Text" )=='C',oInfEmit:_ENDEREMIT:_Nro:Text,'')
		cBairro  := IF(Type("oInfEmit:_ENDEREMIT:_xBairro:Text" )=='C',oInfEmit:_ENDEREMIT:_xBairro:Text,'')
		cUF      := IF(Type("oInfEmit:_ENDEREMIT:_UF:Text" )=='C',oInfEmit:_ENDEREMIT:_UF:Text,'')
		cCep     := IF(Type("oInfEmit:_ENDEREMIT:_CEP:Text" )=='C',oInfEmit:_ENDEREMIT:_CEP:Text,'')
		cCodMun  := IF(Type("oInfEmit:_ENDEREMIT:_cMun:Text")=='C',Substr(oInfEmit:_ENDEREMIT:_cMun:Text,3,5),'')
		cCodPais := IF(Type("oInfEmit:_ENDEREMIT:_cPais:Text")=='C','0' + oInfEmit:_ENDEREMIT:_cPais:Text,'')
		cFone    := IF(Type("oInfEmit:_ENDEREMIT:_Fone:Text")=='C',oInfEmit:_ENDEREMIT:_Fone:Text,'')
		cInscr   := IF(Type("oInfEmit:_IE:Text")=='C',oInfEmit:_IE:Text,'')
		cInscrM  := IF(Type("oInfEmit:_IM:Text")=='C',oInfEmit:_IM:Text,'')

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³P.E. para troca do codigo do fornecedor conforme solicitado pelo cliente³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("EXMLCFOR")
			aRetPE := ExecBlock( "EXMLCFOR",.F.,.F.,{cCGC,cTipoNF,oXML} )

			If ValType(aRetPE) == "A" .And. !Empty(aRetPE)
				cCodFor  := aRetPE[1]
				cLojFor  := aRetPE[2]
            EndIf
		Else
			cCodFor  := SA2->( U_DXGetSXE( "SA2","A2_COD",1 ) )
			cLojFor  := "01"
			If __lSX8
				ConfirmSX8()
			EndIf
		EndIf

		aFornecedor:={;
					{"A2_COD"       	,cCodFor                               	,Nil},;
					{"A2_LOJA"       	,cLojFor                               	,Nil},;
					{"A2_NOME"       	,cRazao                                	,Nil},;
					{"A2_NREDUZ"     	,cNReduz                               	,Nil},;
					{"A2_CGC"        	,cCGC                                  	,Nil},;
					{"A2_TIPO"       	,If(Len(AllTrim(cCGC))< 14,'F','J')   	,Nil},;
					{"A2_END"        	,cEndere + ', ' + cNroEnd              	,Nil},;
					{"A2_BAIRRO"     	,cBairro                               	,Nil},;
					{"A2_EST"        	,cUF                                   	,Nil},;
					{"A2_CEP"        	,cCep                                  	,Nil},;
					{"A2_COD_MUN"    	,cCodMun                               	,Nil},;
					{"A2_CODPAIS"    	,cCodPais                              	,Nil},;
					{"A2_TEL"        	,cFone                                 	,Nil},;
					{"A2_COND"       	,GetMV('ES_CONPGNF',.F.,'')       	,Nil},;
					{"A2_INSCR"      	,cInscr                                	,Nil},;
					{"A2_INSCRM"     	,cInscrM                               	,Nil}}


		lMsErroAuto := .F.

		//PE antes da gravacao do Fornecedor
		If ExistBlock("EXMLFORN")
			aRetPE := ExecBlock("EXMLFORN",.F.,.F.,{aFornecedor, cTipoNF, oXML})

			If ValType(aRetPE) == "A" .And. !Empty( aRetPE )
				aFornecedor := aClone( aRetPE )
			EndIf
		EndIf

		MSExecAuto({|x,y| MATA020(x,y)},aFornecedor,3)

		If ExistBlock("EXMLPSFO")
			ExecBlock("EXMLPSFO",.F.,.F., {aFornecedor, lMsErroAuto, cTipoNF , oXML})
		EndIf

		If lMsErroAuto
			If lJob
				MostraErro(DIRXML+DIRERRO,StrTran(Upper(cFile),".XML","_ERR.TXT"))
				AAdd(aErros,{cFile,"Erro no cadastramento do Fornecedor.","Cheque o arquivo "+StrTran(Upper(cFile),".XML","_ERR.TXT")})
			Else
				MostraErro()
			EndIf

			lRet := .F.
		EndIf
	Else
		If lJob
			AAdd(aErros,{cFile,If(cTipoNF=='N',"Fonecedor ","Cliente ") +oXML:_INFNFE:_EMIT:_XNOME:Text +" [" + Transform(cCGC,"@R 99.999.999/9999-99") +"] inexistente na base.","Gere cadastro para este fornecedor."})
		Else
			If !lMensExib
				Aviso("Erro",If(cTipoNF=='N',"Fonecedor ","Cliente ") + oXML:_INFNFE:_EMIT:_XNOME:Text +" [" + Transform(cCGC,"@R 99.999.999/9999-99") +"] inexistente na base.",{"OK"},2,"ReadXML")
				lMensExib := .T.
			EndIf
		EndIf

		lRet := .F.
	EndIf
EndIf

RestArea( aAreaSA2 )
RestArea( aAreaAnt )
Return( lRet )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³DIXConhec ³Autor  ³FELIPE NUNES DE TOLEDO | V. RASPA        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Anexa arquivo ao Banco de Conhecimento.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³PARAMETROS³ cObj     : Diretorio + Nome do arquivo a ser anexado       ³±±
±±³          ³ cDescri  : Descricao do arquivo                            ³±±
±±³          ³ cEntidade: Alias a ser vnculado ao arquivo                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function DIXConhec(cObj,cDescri,cEntidade)
Local lRet       := .F.
Local aEntidade  := {}
Local nPos       := 0
Local cUnico     := ''
Local cCodEnt    := ''
Local aChave     := {}
Local aRecno     := {}
Local nSaveSX8   := 0
Local cDirDocs   := ''
Local cFile      := ''
Local cExtensao  := ''
Local nSaveSX8   := 0
Local aArea      := GetArea()
Local aAreaAC9   := AC9->(GetArea())
Local aAreaSX2   := SX2->(GetArea())
Local aAreaACC   := ACC->(GetArea())

//-- Variaveis especificas utilizadas nas
//-- funcoes de manipulacao do Banco de Conhecimento:
Private aHeader   := {}
Private aCols     := {}
Private Inclui    := If(ValType('Inclui')=='L',Inclui,.T.)
Private cCadastro := 'Conhecimento'
Private lFilACols := .F.

//-- Estabelece o relacionamento da tabela principal
//-- com o banco de conhecimento:
aEntidade := AC9->(MsRelation())
nPos      := AScan(aEntidade, {|x| x[1] == cEntidade})

If nPos <> 0 .Or. (SX2->(DbSeek(cEntidade)) .And. !Empty(SX2->X2_UNICO))
	If nPos == 0 //--Localiza a chave unica pelo SX2
		//--Macro executa a chave unica
		cUnico    := SX2->X2_UNICO
		cCodEnt   := &cUnico
	Else
		aChave    := aEntidade[nPos, 2]
		cCodEnt   := MaBuildKey(cEntidade, aChave)
	EndIf

	//-- Prepara inclusao no banco de conhecimento:
	ACC->(FillGetDados(3, 'ACC', 1,,,,,,,,, .T., aHeader, aCols))

	//-- Transfere o arquivo p/ diretorio do banco de conhecimento:
	SplitPath(cObj,,, @cFile, @cExtensao)
	cDirDocs := AllTrim(If(FindFunction('MsMultDir') .And. MsMultDir(), MsRetPath(cFile+cExtensao), MsDocPath()))
	cDirDocs += If(Right(cDirDocs, 1) <> '\', '\', '')
	__CopyFile(cObj, cDirDocs + cFile + cExtensao)

	If File(cDirDocs + "\" + cFile + cExtensao)
		nSaveSX8      := GetSX8Len()
		M->ACB_CODOBJ := GetSXENum( "ACB", "ACB_CODOBJ" )
		M->ACB_DESCRI := cDescri
		M->ACB_OBJETO := cObj

	    //-- Realiza a gravacao do objeto
	    //-- e vincula o documento no banco de conhecimento:
		Ft340Grv(1, aRecno)

		While (GetSx8Len() > nSaveSx8)
			ConfirmSX8()
		EndDo

		aHeader := {}
		aCols   := {}
		AC9->( FillGetDados(3,'AC9',1,,,,,,,,,.T.,aHeader,aCols,,,) )

		GDFieldPut( 'AC9_OBJETO', ACB->ACB_OBJETO, Len(aCols) )
		lRet := MsDocGrv( cEntidade, cCodEnt, {}, .F. )

		If lRet
			ConOut('[e-XML: ARQUIVO ' + cFile + cExtensao + ' ANEXADO AO BANCO DE CONHECIMENTO COM SUCESSO!')
		Else
			ConOut('[e-XML: NAO FOI POSSIVEL ANEXAR O ARQUIVO ' + cFile + cExtensao + ' AO BANCO DE CONHECIMENTO!')
		EndIf

	EndIf
EndIf

RestArea(aArea)
RestArea(aAreaAC9)
RestArea(aAreaSX2)
RestArea(aAreaACC)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³DIXGetXML ³Autor  ³FELIPE NUNES DE TOLEDO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Carrega XML da NFe inserido no Banco de Conhecimento       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³PARAMETROS³ cFileXML : Nome do Arquivo XML                             ³±±
±±³          ³ oXML     : Objeto XML a ser carregado                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function DIXGetXML(cFileXML,oXML)
Local nX        := 0
Local cFile     := ''
Local cDirDocs  := ''
Local cPathFile := ''
Local cError    := ""
Local cWarning  := ""
Local oFullXML  := Nil
Local oAuxXML   := Nil
Local lFound    := .F.
Local lRet      := .F.

DEFAULT oXML    := Nil

ACB->(dbSetOrder(3)) //-- ACB_FILIAL+ACB_DESCRI
If ACB->( dbSeek( xFilial('ACB') + cFileXML ) )
	cFile := ACB->ACB_OBJETO

	If MsMultDir()
		cDirDocs := MsRetPath( cFile )
	Else
		cDirDocs := MsDocPath()
	EndIf

	//-------------------------------------------------
	// Retira a ultima barra invertida ( se houver )
	//-------------------------------------------------
	cDirDocs  := MsDocRmvBar( cDirDocs )
	cPathFile := cDirDocs + "\" + cFile


	oFullXML := XmlParserFile(cPathFile,"_",@cError,@cWarning)

	//-- Erro na sintaxe do XML
	If Empty(oFullXML) .Or. !Empty(cError)
		Conout("[DIXGetXML] Erro de sintaxe no arquivo XML: "+cError,"Entre em contato com o emissor do documento e comunique a ocorrência.")
	Else
		lRet := .T.
	EndIf

	If lRet
		oXML    := oFullXML
		oAuxXML := oXML

		//-- Resgata o no inicial da NF-e
		Do While !lFound
			oAuxXML := XmlChildEx(oAuxXML,"_NFE")
			If !(lFound := oAuxXML # NIL)
				For nX := 1 To XmlChildCount(oXML)
					oAuxXML  := XmlChildEx(XmlGetchild(oXML,nX),"_NFE")
					lFound := oAuxXML:_InfNfe # Nil
					If lFound
						oXML := oAuxXML
						Exit
					EndIf
				Next nX
			EndIf

			If lFound
				oXML := oAuxXML
				Exit
			EndIf
		EndDo
	EndIf
EndIf

Return( lRet )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³DIXRetXML ³Autor  ³FELIPE NUNES DE TOLEDO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Carrega XML da NFe inserido no Banco de Conhecimento       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³PARAMETROS³ cFileXML : Nome do Arquivo XML                             ³±±
±±³          ³ oXML     : Objeto XML a ser carregado                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function DIXRetXML(cFileXML,cDirDest)
Local cFile     := ''
Local cDirDocs  := ''
Local cPathFile := ''
Local lRet      := .F.

ACB->(dbSetOrder(2)) //-- ACB_FILIAL+ACB_DESCRI
If ACB->( dbSeek( xFilial('ACB') + cFileXML ) )
	cFile := ACB->ACB_OBJETO

	If MsMultDir()
		cDirDocs := MsRetPath( cFile )
	Else
		cDirDocs := MsDocPath()
	EndIf

	//-------------------------------------------------
	// Retira a ultima barra invertida ( se houver )
	//-------------------------------------------------
	cDirDocs  := MsDocRmvBar( cDirDocs )
	cPathFile := AllTrim(cDirDocs + "\" + cFile)

	//Copia para o destino
	If File( cPathFile )
		CpyS2T( cPathFile, cDirDest, .F. )
	EndIf
EndIf

Return( lRet )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³DIXFisXML ³Autor  ³FELIPE NUNES DE TOLEDO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³Retorna array com os impostos destacados no arquivo XML     ³±±
±±³          ³da Nota Fiscal Eletronica de Entrada.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³RETORNO   ³aRet[1]                                                     ³±±
±±³          ³    [1][1]:  Base de Calculo ICMS                           ³±±
±±³          ³    [1][2]:  Aliquota ICMS                                  ³±±
±±³          ³    [1][3]:  Valor ICMS                                     ³±±
±±³          ³    [1][4]:  Base de Calculo PIS                            ³±±
±±³          ³    [1][5]:  Aliquota PIS                                   ³±±
±±³          ³    [1][6]:  Valor PIS                                      ³±±
±±³          ³    [1][7]:  Base de Calculo COFINS                         ³±±
±±³          ³    [1][8]:  Aliquota COFINS                                ³±±
±±³          ³    [1][9]:  Valor COFINS                                   ³±±
±±³          ³aRet[2]                                                     ³±±
±±³          ³    [2][1]:  Total Base de Calculo ICMS                     ³±±
±±³          ³    [2][2]:  Total Valor ICMS                               ³±±
±±³          ³    [2][3]:  Total Valor IPI                                ³±±
±±³          ³    [2][4]:  Total Valor PIS                                ³±±
±±³          ³    [2][5]:  Total Valor COFINS                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function DIXFisXML()
Local cFileXML  := ''
Local aTotal    := {}
Local aImpItem  := {}
Local aImpTot   := {}
Local aRet      := {{},{}}
Local aItens    := {}
Local nCountXml := 0

Private oNfeXML   := Nil

If !Empty(SF1->F1_U_ARXML)
	cFileXML := StrTran(UPPER(AllTrim(SF1->F1_U_ARXML)), '.XML', '')
	If U_DIXGetXML(cFileXML,@oNfeXML) .And. Type('oNfeXML:_InfNfe:_Det') <> 'U'

		//-- Se ID valido
		//-- Extrai tag _InfNfe:_Det
		If ValType(oNfeXML:_InfNfe:_Det) == "O"
			aItens := {oNfeXML:_InfNfe:_Det}
		Else
			aItens := oNfeXML:_InfNfe:_Det
		EndIf

		aTotal := oNfeXML:_InfNfe:_total

		For nCountXml := 1 To Len(aItens)
			aImpItem := {}

			xVarComp := aItens[nCountXml]

			If Type("xVarComp:_imposto:_ICMS:_ICMS00")<>"U" //-- TRIBUTADA INTEGRALMENTE
				AAdd(aImpItem, Val(aItens[nCountXml]:_imposto:_ICMS:_ICMS00:_vBC:Text))   //-- Base de Calculo ICMS
				AAdd(aImpItem, Val(aItens[nCountXml]:_imposto:_ICMS:_ICMS00:_pICMS:Text)) //-- Aliquota ICMS
				AAdd(aImpItem, Val(aItens[nCountXml]:_imposto:_ICMS:_ICMS00:_vICMS:Text)) //-- Valor ICMS
			ElseIf Type("xVarComp:_imposto:_ICMS:_ICMS20")<>"U" //-- COM REDUCAO DE BASE DE CALCULO
				AAdd(aImpItem, Val(aItens[nCountXml]:_imposto:_ICMS:_ICMS20:_vBC:Text))   //-- Base de Calculo ICMS
				AAdd(aImpItem, Val(aItens[nCountXml]:_imposto:_ICMS:_ICMS20:_pICMS:Text)) //-- Aliquota ICMS
				AAdd(aImpItem, Val(aItens[nCountXml]:_imposto:_ICMS:_ICMS20:_vICMS:Text)) //-- Valor ICMS
			Else
				AAdd(aImpItem, 0 ) //-- Base de Calculo ICMS
				AAdd(aImpItem, 0 ) //-- Aliquota ICMS
				AAdd(aImpItem, 0 ) //-- Valor ICMS
			EndIf

			AAdd(aImpItem, If(Type("xVarComp:_imposto:_PIS:_PISAliq")<>"U",Val(aItens[nCountXml]:_imposto:_PIS:_PISAliq:_vBC:Text),0))   //-- Base de Calculo PIS
			AAdd(aImpItem, If(Type("xVarComp:_imposto:_PIS:_PISAliq")<>"U",Val(aItens[nCountXml]:_imposto:_PIS:_PISAliq:_pPIS:Text),0))  //-- Aliquota PIS
			AAdd(aImpItem, If(Type("xVarComp:_imposto:_PIS:_PISAliq")<>"U",Val(aItens[nCountXml]:_imposto:_PIS:_PISAliq:_vPIS:Text),0))  //-- Valor PIS

			AAdd(aImpItem, If(Type("xVarComp:_imposto:_COFINS:_COFINSAliq")<>"U",Val(aItens[nCountXml]:_imposto:_COFINS:_COFINSAliq:_vBC:Text),0))      //-- Base de Calculo COFINS
			AAdd(aImpItem, If(Type("xVarComp:_imposto:_COFINS:_COFINSAliq")<>"U",Val(aItens[nCountXml]:_imposto:_COFINS:_COFINSAliq:_pCOFINS:Text),0))  //-- Aliquota COFINS
			AAdd(aImpItem, If(Type("xVarComp:_imposto:_COFINS:_COFINSAliq")<>"U",Val(aItens[nCountXml]:_imposto:_COFINS:_COFINSAliq:_vCOFINS:Text),0))  //-- Valor COFINS

			AAdd(aRet[1], aImpItem)
		Next nCountXml

		AAdd(aImpTot, Val(aTotal:_ICMSTot:_vBC:Text))      //-- Total Base de Calculo ICMS
		AAdd(aImpTot, Val(aTotal:_ICMSTot:_vICMS:Text))    //-- Total Valor ICMS
		AAdd(aImpTot, Val(aTotal:_ICMSTot:_vIPI:Text))     //-- Total Valor IPI
		AAdd(aImpTot, Val(aTotal:_ICMSTot:_vPIS:Text))     //-- Total Valor PIS
		AAdd(aImpTot, Val(aTotal:_ICMSTot:_vCOFINS:Text))  //-- Total Valor COFINS

		AAdd(aRet[2], aImpTot)
	EndIf
EndIf

Return(aRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³DIXCompXML³Autor  ³FELIPE NUNES DE TOLEDO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³Compara os impostos calculados pelo sistema com os impostos ³±±
±±³          ³destacados no arquivo XML.                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function DIXCompXML(cDoc,cSerie,cFornec,cLoja)
Local aAreaAnt   := GetArea()
Local cAliasQry  := GetNextAlias()
Local aFisXML    := U_DIXFisXML() //-- Retorna informacoes fiscais contidas no arquivo XML.
Local nCount     := 0
//Local cPicBase   := PesqPictQt('D1_BASEICM')
//Local cPicPerc   := PesqPictQt('D1_PICM')
Local cPicVal    := PesqPictQt('D1_VALICM')
Local cStrItem   := ''
Local cStrTot    := ''
Local aVetMsg    := {}

If !Empty(aFisXML[1])
	BeginSql Alias cAliasQry
		SELECT
		D1_ITEM,
		D1_COD,
		B1_DESC,
		D1_BASEICM,
		D1_PICM,
		D1_VALICM,
		D1_BASIMP5,
		D1_ALQIMP5,
		D1_VALIMP5,
		D1_BASIMP6,
		D1_ALQIMP6,
		D1_VALIMP6,
		D1_TES
		FROM %Table:SD1% SD1
		INNER JOIN %Table:SB1% SB1 ON
		SB1.B1_FILIAL  = %xFilial:SB1%
		AND SB1.B1_COD     = SD1.D1_COD
		AND SB1.%NotDel%
		WHERE
		SD1.D1_FILIAL  = %xFilial:SD1%
		AND SD1.D1_DOC     = %Exp:cDoc%
		AND SD1.D1_SERIE   = %Exp:cSerie%
		AND SD1.D1_FORNECE = %Exp:cFornec%
		AND SD1.D1_LOJA    = %Exp:cLoja%
		AND SD1.%NotDel%
		ORDER BY D1_ITEM
	EndSql

	//-- Valida os valores dos itens da nota
	Do While (cAliasQry)->(!Eof())
		nCount++
		cStrItem := ''

		//If (cAliasQry)->D1_BASEICM <> aFisXML[1][nCount][1]
		/*
		If Abs( (cAliasQry)->D1_BASEICM - aFisXML[1][nCount][1] ) > 0.01
		cStrItem += '[Base ICMS]' + CRLF
		cStrItem += ' NFe: ' + AllTrim(Transform((cAliasQry)->D1_BASEICM,cPicBase)) + CRLF
		cStrItem += ' - XML: ' + AllTrim(Transform(aFisXML[1][nCount][1]  ,cPicBase)) + CRLF
		EndIf
		*/

		//If (cAliasQry)->D1_PICM <> aFisXML[1][nCount][2]
		/*
		If Abs( (cAliasQry)->D1_PICM - aFisXML[1][nCount][2] ) > 0.01
		cStrItem += '[Aliq. ICM]' + CRLF
		cStrItem += ' NFe: ' + AllTrim(Transform((cAliasQry)->D1_PICM,cPicPerc)) + CRLF
		cStrItem += ' - XML: ' + AllTrim(Transform(aFisXML[1][nCount][2],cPicPerc)) + CRLF
		EndIf
		*/

		//If (cAliasQry)->D1_VALICM <> aFisXML[1][nCount][3]
		If Abs( (cAliasQry)->D1_VALICM - aFisXML[1][nCount][3] ) > 0.01
			cStrItem += '[Vlr. ICM]' + CRLF
			cStrItem += ' NFe: ' + AllTrim(Transform((cAliasQry)->D1_VALICM,cPicVal)) + CRLF
			cStrItem += ' - XML: ' + AllTrim(Transform(aFisXML[1][nCount][3],cPicVal)) + CRLF
		EndIf

		//If (cAliasQry)->D1_BASIMP6 <> aFisXML[1][nCount][4]
		/*
		If Abs( (cAliasQry)->D1_BASIMP6 - aFisXML[1][nCount][4] ) > 0.01
		cStrItem += '[Base PIS]' + CRLF
		cStrItem += ' NFe: ' + AllTrim(Transform((cAliasQry)->D1_BASIMP6,cPicBase)) + CRLF
		cStrItem += ' - XML: ' + AllTrim(Transform(aFisXML[1][nCount][4]  ,cPicBase)) + CRLF
		EndIf
		*/

		//If (cAliasQry)->D1_ALQIMP6 <> aFisXML[1][nCount][5]
		/*
		If Abs( (cAliasQry)->D1_ALQIMP6 - aFisXML[1][nCount][5] ) > 0.01
		cStrItem += '[Aliq. PIS]' + CRLF
		cStrItem += ' NFe: ' + AllTrim(Transform((cAliasQry)->D1_ALQIMP6,cPicPerc)) + CRLF
		cStrItem += ' - XML: ' + AllTrim(Transform(aFisXML[1][nCount][5],cPicPerc)) + CRLF
		EndIf
		*/

		//If (cAliasQry)->D1_VALIMP6 <> aFisXML[1][nCount][6]
		If Abs( (cAliasQry)->D1_VALIMP6 - aFisXML[1][nCount][6] ) > 0.01
			cStrItem += '[Vlr. PIS]' + CRLF
			cStrItem += ' NFe: ' + AllTrim(Transform((cAliasQry)->D1_VALIMP6,cPicVal)) + CRLF
			cStrItem += ' - XML: ' + AllTrim(Transform(aFisXML[1][nCount][6],cPicVal)) + CRLF
		EndIf

		//If (cAliasQry)->D1_BASIMP5 <> aFisXML[1][nCount][7]
		/*
		If Abs( (cAliasQry)->D1_BASIMP5 - aFisXML[1][nCount][7] ) > 0.01
		cStrItem += '[Base COF]' + CRLF
		cStrItem += ' NFe: ' + AllTrim(Transform((cAliasQry)->D1_BASIMP5,cPicBase)) + CRLF
		cStrItem += ' - XML: ' + AllTrim(Transform(aFisXML[1][nCount][7]  ,cPicBase)) + CRLF
		EndIf
		*/

		//If (cAliasQry)->D1_ALQIMP5 <> aFisXML[1][nCount][8]
		/*
		If Abs( (cAliasQry)->D1_ALQIMP5 - aFisXML[1][nCount][8] ) > 0.01
		cStrItem += '[Aliq. COF]' + CRLF
		cStrItem += ' NFe: ' + AllTrim(Transform((cAliasQry)->D1_ALQIMP5,cPicPerc)) + CRLF
		cStrItem += ' - XML: ' + AllTrim(Transform(aFisXML[1][nCount][8],cPicPerc)) + CRLF
		EndIf
		*/

		//If (cAliasQry)->D1_VALIMP5 <> aFisXML[1][nCount][9]
		If Abs( (cAliasQry)->D1_VALIMP5 - aFisXML[1][nCount][9] ) > 0.01
			cStrItem += '[Vlr. COF]' + CRLF
			cStrItem += ' NFe: ' + AllTrim(Transform((cAliasQry)->D1_VALIMP5,cPicVal)) + CRLF
			cStrItem += ' - XML: ' + AllTrim(Transform(aFisXML[1][nCount][9],cPicVal)) + CRLF
		EndIf

		If !Empty(cStrItem)
			AAdd(aVetMsg, {(cAliasQry)->D1_ITEM,(cAliasQry)->D1_COD,(cAliasQry)->B1_DESC,cStrItem})
		EndIf

		(cAliasQry)->(DbSkip())
	EndDo

	//-- Valida os valores totais da nota
	//If SF1->F1_BASEICM <> aFisXML[2][1][1]
	/*
	If Abs( SF1->F1_BASEICM - aFisXML[2][1][1] ) > 0.01
	cStrTot += '[Base Total ICMS]' + CRLF
	cStrTot += ' NFe: ' + AllTrim(Transform(SF1->F1_BASEICM,cPicBase)) + CRLF
	cStrTot += ' - XML: ' + AllTrim(Transform(aFisXML[2][1][1] ,cPicBase)) + CRLF
	EndIf
	*/

	//If SF1->F1_VALICM <> aFisXML[2][1][2]
	If Abs( SF1->F1_VALICM - aFisXML[2][1][2] ) > 0.15
		cStrTot += '[Vlr. Total ICM]' + CRLF
		cStrTot += ' NFe: ' + AllTrim(Transform(SF1->F1_VALICM,cPicVal)) + CRLF
		cStrTot += ' - XML: ' + AllTrim(Transform(aFisXML[2][1][2],cPicVal)) + CRLF
	EndIf

	//If SF1->F1_VALIPI <> aFisXML[2][1][3]
	If Abs( SF1->F1_VALIPI - aFisXML[2][1][3] ) > 0.15
		cStrTot += '[Vlr. Total IPI]' + CRLF
		cStrTot += ' NFe: ' + AllTrim(Transform(SF1->F1_VALIPI,cPicVal)) + CRLF
		cStrTot += ' - XML: ' + AllTrim(Transform(aFisXML[2][1][3],cPicVal)) + CRLF
	EndIf

	//If SF1->F1_VALIMP6 <> aFisXML[2][1][4]
	If Abs( SF1->F1_VALIMP6 - aFisXML[2][1][4] ) > 0.15
		cStrTot += '[Vlr. Total PIS]' + CRLF
		cStrTot += ' NFe: ' + AllTrim(Transform(SF1->F1_VALIMP6,cPicVal)) + CRLF
		cStrTot += ' - XML: ' + AllTrim(Transform(aFisXML[2][1][4],cPicVal)) + CRLF
	EndIf

	//If SF1->F1_VALIMP5 <> aFisXML[2][1][5]
	If Abs( SF1->F1_VALIMP5 - aFisXML[2][1][5] ) > 0.15
		cStrTot += '[Vlr. Total COF]' + CRLF
		cStrTot += ' NFe: ' + AllTrim(Transform(SF1->F1_VALIMP5,cPicVal)) + CRLF
		cStrTot += ' - XML: ' + AllTrim(Transform(aFisXML[2][1][5],cPicVal)) + CRLF
	EndIf

	If !Empty(cStrTot)
		AAdd(aVetMsg, {' - ',' - ',' - ',cStrTot})
	EndIf

	//-- Envia e-mail de notificacao de inconsistencias
	If Len(aVetMsg) > 0
		DIXMailCmp(aVetMsg)
	EndIf
EndIf

RestArea(aAreaAnt)
Return Nil
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³DIXMailCmp³Autor  ³FELIPE NUNES DE TOLEDO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Envia e-mail com a notificacao de inconsistencia na        ³±±
±±³          ³ importacao do arquivo XML de Entrada.                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DIXMailCmp(aErro)
Local oProcess   := Nil
Local cMailAdm   := GetMV('ES_MAILADM',.F.,'') //-- E-mail de notificacao Administrado Sistema
Local cAssunto   := ""
Local cMensagem  := ""
Local aDadosHTML := {}
Local aItensErro := {}
Local aErrosHTML := {}
Local nCntFor1   := 0
Local aAnexos    := {}

If !Empty( cMailAdm )
	Return Nil
EndIf

//-- Posiciona no Cadastro de Fornecedores
SA2->(dbSetOrder(1))
SA2->(dbSeek(xFilial('SA2')+SF1->F1_FORNECE+SF1->F1_LOJA))

//----------------------------------------
// DADOS DO ARQUIVO
//----------------------------------------
Aadd(aDadosHTML,{'cNomeXML'   , SF1->F1_U_ARXML        })
Aadd(aDadosHTML,{'cNomeFor'   , SA2->A2_NOME           })
Aadd(aDadosHTML,{'cCNPJFor'   , SA2->A2_CGC            })
Aadd(aDadosHTML,{'cDoc'       , SF1->F1_DOC            })
Aadd(aDadosHTML,{'cSerie'     , SF1->F1_SERIE          })
Aadd(aDadosHTML,{'dDtEmissao' , DtoC(SF1->F1_EMISSAO)  })
Aadd(aDadosHTML,{'cNomeDest'  , SM0->M0_NOMECOM        })
Aadd(aDadosHTML,{'cCNPJDest'  , SM0->M0_CGC            })
Aadd(aDadosHTML,{'cLoja'      , Right(SF1->F1_FILIAL,5)})

//----------------------------------------
// INCONSISTENCIAS
//----------------------------------------
For nCntFor1 := 1 To Len(aErro)
    aItensErro := {}

	AAdd(aItensErro,{'ERRO.cItem'   , If(ValType(aErro[nCntFor1][1])=='C',aErro[nCntFor1][1],'')} )
	AAdd(aItensErro,{'ERRO.cCodPro' , If(ValType(aErro[nCntFor1][2])=='C',aErro[nCntFor1][2],'')} )
	AAdd(aItensErro,{'ERRO.cDesPro' , If(ValType(aErro[nCntFor1][3])=='C',aErro[nCntFor1][3],'')} )
	AAdd(aItensErro,{'ERRO.cMotivo' , If(ValType(aErro[nCntFor1][4])=='C',aErro[nCntFor1][4],'')} )

	aAdd(aErrosHTML, aItensErro)
Next nCntFor1

//--Determina as propriedades
cAssunto  := "[EXML] - " + AllTrim(SF1->F1_FILIAL) + ' Notificação Divergencia Fiscal - NF-e vs Arquivo XML '
cMensagem := GetHTMLMessage( "exml010", aDadosHTML, aErrosHTML )

//----------------------------------------
// ADICIONA ANEXO
//----------------------------------------
If File(DIRXML+DIRLIDO+SF1->F1_U_ARXML)
    Aadd(aAnexos,DIRXML + DIRLIDO + SF1->F1_U_ARXML)
EndIf

EXMLSendMail(cMailAdm,cAssunto,cMensagem,aAnexos)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³ EXMLIMP  ³Autor  ³ FERNANDO SALVATORI                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Inicio Manual do Servico de Importacao de XML              ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function EXMLIMP()
Local aArea     := GetArea()
Local oListF
Local aListF    := {}
Local aListCte	:= {}
Local oListCte	
Local oPanel1
Local oSay1
Local oSButton1
Local oSButton2
Local oSButton3
Local oCaminho
Local oCaminho2	
Local cCaminho  := Space(200)
Local cPathCte	:= Space(200)
Local oDlg
Local lOk       := .F.
Local lOkCte	:= .F. 
Local nX
Local oOk 		:= LoadBitmap( GetResources(), "LBOK")
Local oNo 		:= LoadBitmap( GetResources(), "LBNO")
Local oInverte
Local lInverte  := .F.
Local oInverte2
Local oTodos
Local oTodos2
Local lTodos    := .T.
Local lRetTSS   := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o servico do TSS esta ativo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsgRun( 'Verificando a disponibilidade do servido do TSS...',;
		'TOTVS Service SPED (TSS)...',;
		{|| lRetTSS := XMLVerTSS() })

If !lRetTSS
	Return Nil
EndIf

//-- Cria os diretorios de importacao
If !ExistDir(DIRXML)
	MakeDir(DIRXML)
	MakeDir(DIRXML +DIRALER)
	MakeDir(DIRXML +DIRLIDO)
	MakeDir(DIRXML +DIRERRO)
	MakeDir(DIRXML +DIRDANFE)
EndIf

AAdd( aListF, {.F., "","","","" } )
AAdd( aListCTE, {.F., "","","","" } )
DEFINE MSDIALOG oDlg TITLE "Selecionar arquivos XML" FROM 000, 000  TO 500, 700 PIXEL

@ 00, 000 FOLDER oFolder1 SIZE 350, 250 OF oDlg ITEMS "E-Xml","CT-e" COLORS 0, 16777215 PIXEL

//-- Folder 1
@ 000, 000 MSPANEL oPanel1 SIZE 328, 020 OF oFolder1:aDialogs[1] RAISED
@ 006, 005 SAY oSay1 PROMPT "Caminho:" SIZE 038, 007 OF oPanel1 PIXEL
@ 004, 047 MSGET oCaminho VAR cCaminho SIZE 229, 012 F3 "XMLDIR" OF oPanel1 PIXEL HASBUTTON

DEFINE SBUTTON oSButton1 FROM 004, 294 TYPE 14 OF oPanel1 ENABLE ACTION ( XMLArqXML(oListF, aListF, cCaminho, oOk, oNo) )

@ 035, 008 LISTBOX oListF FIELDS HEADER " ","Nome","Tamanho","Data","Hora" SIZE 329, 179 OF oFolder1:aDialogs[1] PIXEL

oListF:SetArray( aListF )
oListF:bLine := {|| { IIf( aListF[oListF:nAt,1],oOk,oNo),;
						   aListF[oListF:nAt,2],;
						   aListF[oListF:nAt,3],;
						   aListF[oListF:nAt,4],;
						   aListF[oListF:nAt,5] } }
oListF:bLdbLClick := {|| (aListF[oListF:nAt,1] := !aListF[oListF:nAt,1], oListF:Refresh()) }
oListF:Refresh()

@ 220, 010 CHECKBOX oInverte VAR lInverte PROMPT "Inverter Seleção" Message "Inverte toda sas marcas"     SIZE 40, 007 PIXEL OF oFolder1:aDialogs[1] ON CLICK XMLInverte( lInverte, @aListF, oListF )
@ 220, 130 CHECKBOX oTodos   VAR lTodos   PROMPT "Marcar Todos"     Message "Marca todos os arquivos XML" SIZE 40, 007 PIXEL OF oFolder1:aDialogs[1] ON CLICK XmlMarcTot( lTodos, @aListF, oListF )

DEFINE SBUTTON oSButton2 FROM 220, 273 TYPE 01 OF oFolder1:aDialogs[1] ENABLE ACTION ( lOk := .T., oDlg:End() )
DEFINE SBUTTON oSButton3 FROM 220, 310 TYPE 02 OF oFolder1:aDialogs[1] ENABLE ACTION ( lOk := .F., oDlg:End() )

//-- Folder 2
@ 000, 000 MSPANEL oPanel2 SIZE 328, 020 OF oFolder1:aDialogs[2] RAISED
@ 006, 005 SAY oSay2 PROMPT "Caminho:" SIZE 038, 007 OF oPanel2 PIXEL
@ 004, 047 MSGET oCaminho2 VAR cPathCte SIZE 229, 012 F3 "XMLDIR" OF oPanel2 PIXEL HASBUTTON

DEFINE SBUTTON oSButton2 FROM 004, 294 TYPE 14 OF oPanel2 ENABLE ACTION ( XMLArqXML(oListCte, aListCte, cPathCte, oOk, oNo) )

@ 035, 008 LISTBOX oListCte FIELDS HEADER " ","Nome","Tamanho","Data","Hora" SIZE 329, 179 OF oFolder1:aDialogs[2] PIXEL

oListCte:SetArray( aListCte )
oListCte:bLine := {|| { IIf( aListCte[oListCte:nAt,1],oOk,oNo),;
						   aListCte[oListCte:nAt,2],;
						   aListCte[oListCte:nAt,3],;
						   aListCte[oListCte:nAt,4],;
						   aListCte[oListCte:nAt,5] } }
oListCte:bLdbLClick := {|| (aListCte[oListCte:nAt,1] := !aListCte[oListCte:nAt,1], oListCte:Refresh()) }
oListCte:Refresh()

@ 220, 010 CHECKBOX oInverte2 VAR lInverte PROMPT "Inverter Seleção" Message "Inverte toda sas marcas"     SIZE 40, 007 PIXEL OF oFolder1:aDialogs[2] ON CLICK XMLInverte( lInverte, @aListCte, oListCte )
@ 220, 130 CHECKBOX oTodos2   VAR lTodos   PROMPT "Marcar Todos"     Message "Marca todos os arquivos XML" SIZE 40, 007 PIXEL OF oFolder1:aDialogs[2] ON CLICK XmlMarcTot( lTodos, @aListCte, oListCte )

DEFINE SBUTTON oSButton2 FROM 220, 273 TYPE 01 OF oFolder1:aDialogs[2] ENABLE ACTION ( lOkCte := .T., oDlg:End() )
DEFINE SBUTTON oSButton3 FROM 220, 310 TYPE 02 OF oFolder1:aDialogs[2] ENABLE ACTION ( lOkCte := .F., oDlg:End() )

ACTIVATE MSDIALOG oDlg CENTERED

If lOk .And. MsgYesNo("Iniciar importacao de arquivos de XML de NF-e?")

	cCaminho := AllTrim(cCaminho)

	If Right(cCaminho,1) <> "\"
		cCaminho += "\"
	EndIf

	Processa({|| XMLCpyArq(aListF,cCaminho) },"Copiando arquivos para o Server")

	If ExistBlock("EXMLAIMP")
		ExecBlock("EXMLAIMP",.F.,.F.,{aListF,cCaminho})
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicia a importação dos dados³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	U_EXMLNFE(cEmpAnt,cFilAnt)

	If ExistBlock("EXMLDIMP")
		ExecBlock("EXMLDIMP",.F.,.F.,{aListF,cCaminho})
	EndIf
ElseIf lOkCte .And. MsgYesNo("Iniciar importacao de arquivos de XML de CT-e?")
	AjustaSX1()
	If Pergunte("IMPCTE",.T.)
		cCaminho := AllTrim(cPathCte)
	
		If Right(cCaminho,1) <> "\"
			cCaminho += "\"
		EndIf
	
		Processa({|| XMLCpyArq(aListCte,cCaminho,.T.) },"Copiando arquivos para o Server")
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inicia a importação dos dados³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		U_EXMLCTE(cEmpAnt,cFilAnt)
		
	EndIf
EndIf

RestArea( aArea )

Return

//**********
Static Function XMLCpyArq(aListF,cCaminho,lCte)
Local nX

Default lCte	:= .F. 

If lCte
	//-- Cria os diretorios de importacao
	If !ExistDir(DIRCTE)
		MakeDir(DIRCTE)
		MakeDir(DIRCTE + DIRALER)
		MakeDir(DIRCTE + DIRLIDO)
		MakeDir(DIRCTE + DIRERRO)
	EndIf
EndIf

For nX := 1 to Len( aListF )
	If aListF[nX,1] .And. !Empty( aListF[nX,2] )
		If lCte
			CpyT2S( cCaminho + aListF[nX,2], DIRCTE + DIRALER )
		Else
			CpyT2S( cCaminho + aListF[nX,2], DIRXML + DIRALER )
		EndIf
	EndIf
Next nX

Return Nil

//**********
Static Function XMLInverte( lInverte, aListF, oListF )

aEval( aListF, {|x| x[1] := !x[1]} )
oListF:Refresh()

Return Nil

//**********
Static Function XmlMarcTot( lTodos, aListF, oListF )

aEval( aListF, {|x| x[1] := lTodos} )
oListF:Refresh()

Return Nil

//*************
Static Function XMLArqXML(oListF, aListF, cCaminho, oOk, oNo)
Local aArqs := {}
Local nX    := 0

If Empty( cCaminho )
	MsgStop("Selecine um diretorio antes de confirmar.")
	Return .F.
EndIf

cCaminho := AllTrim(cCaminho)

If Right(cCaminho,1) <> "\"
	cCaminho += "\"
EndIf

aArqs := Directory( cCaminho + '*.xml' )

aListF := {}

For nX := 1 to Len( aArqs )
	AAdd( aListF, {.T.,aArqs[nX,1],aArqs[nX,2],aArqs[nX,3],aArqs[nX,4]} )
Next nX

If Empty( aListF )
	AAdd( aListF, {.F.,"","","",""} )
EndIf

oListF:SetArray( aListF )
oListF:bLine := {|| { IIf( aListF[oListF:nAt,1],oOk,oNo),;
						   aListF[oListF:nAt,2],;
						   aListF[oListF:nAt,3],;
						   aListF[oListF:nAt,4],;
						   aListF[oListF:nAt,5] } }
oListF:Refresh()

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³ EXMLConf ³Autor  ³ FERNANDO SALVATORI                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Configuracao do programa de XML.                           ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function EXMLConf()
Local oWizard    := Nil
Local oPanel     := Nil
Local cInicio    := ""
Local oInicio    := Nil
Local cConclusao := ""
Local oConclusao := Nil
Local cHeader    := "Assistente de Configuracao E-XML versão "+VERSAO
Local oFont      := Nil
Local cDate      := ""
Local cTime      := ""
Local nFolder    := 0

/*/
    Variaveis do Quadro 2: Configuracoes SMTP
/*/
// Objetos
Local oUsaMail   := Nil                                    // ComboBox que indica se será utilizado o SMTP para envio de e-mails
Local oAutentic  := Nil                                    // ComboBox da identificacao de autenticacao
Local oSMTP      := Nil                                    // Get do Servidor SMTP
Local oPortSMTP  := Nil                                    // Get da porta do servidor SMTP
Local oUsuSmtp   := Nil                                    // Get da conta SMTP utilizada para autenticacao
Local oSenSmtp   := Nil                                    // Get da senha SMTP
Local oAccRem    := Nil                                    // Get da Conta de e-mail utilizada como remetente
Local oTimeOut   := Nil                                    // Get do tempo de time-out para envio de email (em segundos)

// Gets
Local nUsaMail   := GetNewPar("ES_USAMAIL",1)              // Indica se será utilizado o SMTP para envio de e-mails
Local nAutentic  := IIF(GetNewPar("MV_RELAUTH" ,.T.),1,2)  // Indica se o servidor necessita de autenticação
Local cSMTP      := PadR(GetNewPar('MV_RELSERV','') ,100)  // Servidor SMTP
Local cPortSMTP  := PadR(GetNewPar('MV_GCPPORT',25) , 20)  // Porta do servidor SMTP
Local cUsuSmtp   := PadR(GetNewPar('MV_RELACNT','') ,100)  // Conta SMTP utilizada para autenticacao
Local cSenSmtp   := PadR(GetNewPar('MV_RELPSW' ,'') , 20)  // Senha da conta SMTP
Local cAccRem    := PadR(GetNewPar('MV_RELFROM','') ,100)  // Conta de e-mail utilizada como remetente
Local cTimeOut   := PadR(GetNewPar('MV_RELTIME',120),  3)  // Tempo de time-out para envio de email (em segundos)

/*/
    Variaveis do Quadro 3: Configuracoes POP
/*/
// Objetos
Local oUsaPOP3   := Nil
Local oPOP3      := Nil
Local oPortPOP3  := Nil
Local oUsuPOP3   := Nil
Local oSenPOP3   := Nil
Local oUsaTLS    := Nil
Local oUsaSSL    := Nil

// Gets
Local nUsaPOP3   := GetNewPar("ES_USAPOP3",1)
Local cPOP3      := PadR(GetNewPar('ES_POP3SRV','') , 30)
Local cPortPOP3  := PadR(GetNewPar('ES_POP3POR',110),  3)
Local cUsuPOP3   := PadR(GetNewPar('ES_USUPOP3','') ,100)
Local cSenPOP3   := PadR(GetNewPar('ES_PSWPOP3','') , 30)
Local nUsaTLS    := IIF(GetNewPar('MV_RELTLS',.F.)  ,1,2)
Local nUsaSSL    := IIF(GetNewPar('MV_RELSSL',.F.)  ,1,2)

/*/
    Variaveis do Quadro 4: Configuracoes Diversas
/*/
// Objetos
Local oEmailAud  := Nil
Local oVldNFE    := Nil
Local oCFOPBon   := Nil
Local oCFOPBenif := Nil
Local oCFOPDev   := Nil
Local oCDNewFor  := Nil
Local oCDNewCli  := Nil
Local oCndFor    := Nil
Local oCadProd   := Nil
Local oVldNCM    := Nil

// Gets
Local cEmailAud  := PadR(GetNewPar("ES_MAILADM",""),100)
Local nVldNFE    := IF(GetNewPar("ES_HBCONNF",.T.),1,2)   // Indica se o sistema fará a validacao da chave da NFE
Local cCFOPBon   := PadR(GetNewPar("ES_XMLCFPC",""),100)
Local cCFOPBenif := PadR(GetNewPar("ES_CFOPBEN",""),100)
Local cCFOPDev   := PadR(GetNewPar("ES_CFOPDEV",""),100)
Local nCDNewFor  := GetNewPar('ES_CDNWFOR',2)
Local nCDNewCli  := GetNewPar('ES_CDNWCLI',2)
Local nCadProd   := IF(GetNewPar("ES_INCPROD",.T.),1,2)
Local nVldNCM    := IF(GetNewPar("ES_VLDNCM",.T.),1,2)

Local lRetTSS    := .F.

Private cCndFor  := PadR(GetNewPar("ES_CONPGNF",""),3)

//DEFINE FONT oFont NAME "Courier New" SIZE 10,20

cInicio := "Este assistente irá lhe auxiliar na parametrização desta rotina para uso da rotina de importação de XML no "+CRLF
cInicio += "arquivo de documento de entrada."+CRLF
cInicio += CRLF
cInicio += CRLF
cInicio += CRLF
cInicio += CRLF
cInicio += CRLF
cInicio += CRLF
cInicio += CRLF
cInicio += CRLF
cInicio += CRLF
cInicio += "Tecle 'Avançar' para continuar... "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Primeiro painel         ³
//³Apresentacao do processo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE	WIZARD oWizard 	TITLE "E-XML" ;
		HEADER cHeader ;
		MESSAGE "Bem Vindo..." ;
		NEXT { || .T. } ;
		FINISH {|| .T.} ;
		PANEL

nFolder += 1
oPanel := oWizard:oMPanel[nFolder]

@ 020,015 SAY oInicio VAR cInicio OF oPanel SIZE 500,500 PIXEL //FONT oFont

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Segundo Painel          ³
//³Configuracao de E-MAIL  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CREATE PANEL oWizard	HEADER "Configuração de E-MAIL" ;
						MESSAGE "Informe os dados de SMTP" ;
						BACK {|| .T. } ;
						NEXT {|| DIXTstSmtp(oUsaMail:nAt,cSMTP,cUsuSmtp,cSenSmtp,oAutentic:nAt,Val(cPortSMTP),@cDate,@cTime) } ;
						FINISH {|| .T. } ;
						PANEL

nFolder += 1
oPanel := oWizard:oMPanel[nFolder]

@ 005,030 SAY "Utiliza SMTP?" OF oPanel SIZE 0100,010 PIXEL
@ 015,030 MSCOMBOBOX oUsaMail VAR nUsaMail ITEMS {"Sim","Não"} SIZE 100, 010 OF oPanel PIXEL

@ 005,160 SAY "Servidor requer Autenticação?"   SIZE 90,10 OF oPanel PIXEL
@ 015,160 MSCOMBOBOX oAutentic VAR nAutentic ITEMS {"Sim","Não"} SIZE 100, 010 OF oPanel PIXEL WHEN oUsaMail:nAt == 1

@ 035,030 SAY "Servidor SMTP:"   SIZE 90,10 OF oPanel PIXEL
@ 045,030 MSGET oSMTP VAR cSMTP SIZE 100,10 OF oPanel PIXEL WHEN oUsaMail:nAt == 1

@ 035,160 SAY "Porta SMTP:"   SIZE 90,10 OF oPanel PIXEL
@ 045,160 MSGET oPortSMTP VAR cPortSMTP PICTURE "99999" SIZE 100,10 OF oPanel PIXEL WHEN oUsaMail:nAt == 1

@ 065,030 SAY "Conta para autenticação SMTP:"   SIZE 90,10 OF oPanel PIXEL
@ 075,030 MSGET oUsuSmtp VAR cUsuSmtp SIZE 100,10 OF oPanel PIXEL WHEN oUsaMail:nAt == 1

@ 065,160 SAY "Senha da conta de autenticação:"   SIZE 90,10 OF oPanel PIXEL
@ 075,160 MSGET oSenSmtp VAR cSenSmtp SIZE 100,10 OF oPanel PASSWORD PIXEL WHEN oUsaMail:nAt == 1

@ 095,030 SAY "Conta utilizada para envio de e-mail:"   SIZE 90,10 OF oPanel PIXEL
@ 105,030 MSGET oAccRem VAR cAccRem SIZE 100,10 OF oPanel PIXEL WHEN oUsaMail:nAt == 1

@ 095,160 SAY "Time-out para envio (segundos):"   SIZE 90,10 OF oPanel PIXEL
@ 105,160 MSGET oTimeOut VAR cTimeOut SIZE 100,10 OF oPanel PIXEL WHEN oUsaMail:nAt == 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Terceiro Painel         ³
//³Configuracao de E-MAIL  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CREATE PANEL oWizard	HEADER "Configuração de E-MAIL" ;
						MESSAGE "Informe os dados de POP3" ;
						BACK {|| .T. } ;
						NEXT {|| DIXTstPop3(oUsaPOP3:nAt,cPOP3,cUsuPOP3,cSenPOP3,Val(cPortPOP3),cDate,cTime,oUsaSSL:nAt) } ;
						FINISH {|| .T. } ;
						PANEL

nFolder += 1
oPanel := oWizard:oMPanel[nFolder]

@ 005,030 SAY "Utiliza POP3?" OF oPanel SIZE 0100,010 PIXEL
@ 015,030 MSCOMBOBOX oUsaPOP3 VAR nUsaPOP3 ITEMS {"Sim","Não"} SIZE 100, 010 OF oPanel PIXEL

@ 035,030 SAY "Servidor POP3:"   SIZE 90,10 OF oPanel PIXEL
@ 045,030 MSGET oPOP3 VAR cPOP3 SIZE 100,10 OF oPanel PIXEL WHEN oUsaPOP3:nAt == 1

@ 035,160 SAY "Porta POP3:"   SIZE 90,10 OF oPanel PIXEL
@ 045,160 MSGET oPortPOP3 VAR cPortPOP3 PICTURE "99999" SIZE 100,10 OF oPanel PIXEL WHEN oUsaPOP3:nAt == 1

@ 065,030 SAY "E-mail para recebimento de dados:"   SIZE 90,10 OF oPanel PIXEL
@ 075,030 MSGET oUsuPOP3 VAR cUsuPOP3 SIZE 100,10 OF oPanel PIXEL WHEN oUsaPOP3:nAt == 1

@ 065,160 SAY "Senha do e-mail de recebimento:"   SIZE 90,10 OF oPanel PIXEL
@ 075,160 MSGET oSenPOP3 VAR cSenPOP3 SIZE 100,10 OF oPanel PASSWORD PIXEL WHEN oUsaPOP3:nAt == 1

@ 095,030 SAY "Utiliza segurança TLS?"   SIZE 90,10 OF oPanel PIXEL
@ 105,030 MSCOMBOBOX oUsaTLS VAR nUsaTLS ITEMS {"Sim","Não"} SIZE 100,10 OF oPanel PIXEL WHEN oUsaPOP3:nAt == 1

@ 095,160 SAY "Utiliza segurança SSL?"   SIZE 90,10 OF oPanel PIXEL
@ 105,160 MSCOMBOBOX oUsaSSL VAR nUsaSSL ITEMS {"Sim","Não"} SIZE 100,10 OF oPanel PIXEL WHEN oUsaPOP3:nAt == 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quarto Painel           ³
//³Configuracoes Gerais    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CREATE PANEL oWizard	HEADER "Configurações Diversas" ;
						MESSAGE "Informe as configurações necessárias relacionadas ao comportamento da Rotina de Importação de XML" ;
						BACK {|| .T. } ;
						NEXT {|| .T. } ;
						FINISH {|| .T. } ;
						PANEL

nFolder += 1
oPanel := oWizard:oMPanel[nFolder]

@ 000,030 SAY "E-mail para auditoria de erros:"  		SIZE 190,10 OF oPanel PIXEL
@ 010,030 MSGET oEmailAud VAR cEmailAud 				SIZE 100,10 OF oPanel PIXEL WHEN oUsaMail:nAt == 1

@ 000,160 SAY "Valida chave da NFE?"  					SIZE 190,10 OF oPanel PIXEL
@ 010,160 MSCOMBOBOX oVldNFE VAR nVldNFE ITEMS {"Sim","Não"} 	SIZE 100,10 OF oPanel PIXEL

@ 030,030 SAY "CFOP para NF de Beneficiamento:"   		SIZE 190,10 OF oPanel PIXEL
@ 040,030 MSGET oCFOPBenif VAR cCFOPBenif 				SIZE 100,10 OF oPanel PIXEL

@ 030,160 SAY "CFOP para NF de Devolução:"   			SIZE 190,10 OF oPanel PIXEL
@ 040,160 MSGET oCFOPDev VAR cCFOPDev 					SIZE 100,10 	  OF oPanel PIXEL

@ 060,030 SAY "Cadastra Fornecedor durante Importação?"	SIZE 190,10 OF oPanel PIXEL
@ 070,030 MSCOMBOBOX oCDNewFor VAR nCDNewFor ITEMS {"Sim","Não"} SIZE 100, 010 OF oPanel PIXEL

@ 060,160 SAY "Condição de Pagamento do Fornecedor"		SIZE 190,10 OF oPanel PIXEL
@ 070,160 MSGET oCndFor VAR cCndFor F3 "SE4" VALID ExistCpo("SE4",&(ReadVar()),1) SIZE 112,10 OF oPanel PIXEL WHEN oCDNewFor:nAt == 1 HASBUTTON

@ 090,030 SAY "Cadastra Produto durante Importação?"	SIZE 190,10 OF oPanel PIXEL
@ 100,030 MSCOMBOBOX oCadProd VAR nCadProd ITEMS {"Sim","Não"} 	SIZE 100,10     OF oPanel PIXEL

@ 090,160 SAY "Cadastra Cliente durante Importação?"	SIZE 190,10 OF oPanel PIXEL
@ 100,160 MSCOMBOBOX oCDNewCli VAR nCDNewCli ITEMS {"Sim","Não"} 	SIZE 100,10     OF oPanel PIXEL

@ 120,030 SAY "Valida NCM dos Produtos?"				SIZE 190,10 OF oPanel PIXEL
@ 130,030 MSCOMBOBOX oVldNCM VAR nVldNCM ITEMS {"Sim","Não"} 	SIZE 100,10     OF oPanel PIXEL


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada que permite a criação de mais ³
//³Paineis especificos para o cliente / consultor ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("EXMLPNEL")
	nFolder += 1
	oWizard := ExecBlock( "EXMLPNEL",.F.,.F.,{oWizard,nFolder} )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quinto Painel           ³
//³Conclusao do Processo   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cConclusao := "  O assistente concluiu as parametrizações com êxito."+CRLF
cConclusao += CRLF
cConclusao += CRLF
cConclusao += "   Para concluir a operação, clique em 'Finalizar'."+CRLF

CREATE PANEL oWizard	HEADER "Concluído." ;
						MESSAGE "Obrigado!" ;
						BACK {|| .T. } ;
						NEXT {|| .F. } ;
						FINISH {|| U_DIXGrvCfg(oUsaMail:nAt   ,oAutentic:nAt ,cSMTP       ,Val(cPortSMTP),;
							                   cUsuSmtp       ,cSenSmtp      ,cAccRem     ,Val(cTimeOut) ,;
							                   cPOP3          ,Val(cPortPOP3),cUsuPOP3    ,cSenPOP3      ,;
							                   oUsaTLS:nAt    ,oUsaSSL:nAt   ,cEmailAud   ,cCFOPBenif    ,;
							                   oCDNewFor:nAt  ,cCndFor       ,oUsaPOP3:nAt,oVldNFE:nAt==1,;
							                   oCadProd:nAt==1,oCDNewCli:nAt ,cCFOPDev    ,oVldNCM:nAt==1 ) } ;
						PANEL

nFolder += 1
oPanel := oWizard:oMPanel[nFolder]

@ 020,015 SAY oConclusao VAR cConclusao OF oPanel SIZE 500,500 PIXEL //FONT oFont

ACTIVATE WIZARD oWizard CENTER

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³DIXTstSmtp³Autor  ³ FERNANDO SALVATORI                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Efetua um teste de parametrizacao do SMTP                  ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DIXTstSmtp(nUsaMail,cSMTP,cUsuSmtp,cSenSmtp,nAutentic,nPortSMTP,cDate,cTime)
Local lRet := .T.

//Se nao usar E-MAIL, nao ha necessidade de configuracao
If nUsaMail <> 2
	MsgRun( 'Efetuando um teste nos dados de SMTP. Por favor, aguarde...',;
			'Aguarde...',;
			{|| lRet := DIXEnvMail(nUsaMail,cSMTP,cUsuSmtp,cSenSmtp,nAutentic,nPortSMTP,@cDate,@cTime) })
EndIf

Return lRet

//-----
Static Function DIXEnvMail(nUsaMail,cSMTP,cUsuSmtp,cSenSmtp,nAutentic,nPortSMTP,cDate,cTime)
Local lRet    := .T.
Local lResult := .T.
Local cError  := ""
Local cUser   := ""
Local nAt     := 0

cSMTP    := AllTrim(cSMTP)

cUsuSmtp := AllTrim(cUsuSmtp)
cSenSmtp := AllTrim(cSenSmtp)

If nPortSMTP <> 25 .AND. At(":",cSMTP) == 0
	cSMTP := cSMTP + ":" + AllTrim(Str(nPortSMTP))
EndIf

CONNECT SMTP SERVER cSMTP ACCOUNT cUsuSmtp PASSWORD cSenSmtp RESULT lResult

If lResult .And. nAutentic == 1
	//Primeiro tenta fazer a Autenticacao de E-mail utilizando o e-mail completo
	lResult := MailAuth(cUsuSmtp, cSenSmtp)

	//Se nao conseguiu fazer a Autenticacao usando o E-mail completo, tenta fazer a autenticacao usando apenas o nome de usuario do E-mail
	If !lResult
		nAt 	:= At("@",cUsuSmtp)
		cUser 	:= If(nAt > 0,SubStr(cUsuSmtp,1,nAt-1),cUsuSmtp)
		lResult := MailAuth(cUsuSmtp, cSenSmtp)
	EndIf
EndIf

cDate := DtoC(Date())
cTime := Time()

lRet := lResult

If !lResult
	//Erro no envio do email
	GET MAIL ERROR cError
	MsgStop("Servidor de SMTP: ERRO"+CRLF+CRLF+cError)
EndIf

DISCONNECT SMTP SERVER

If (lRet := lResult)
	MsgInfo("Servidor de SMTP: Ok")
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³DIXTstPop3³Autor  ³ FERNANDO SALVATORI                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Efetua um teste de parametrizacao do POP3                  ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DIXTstPop3(nUsaPOP3,cPOP3,cUsuPOP3,cSenPOP3,nPortPOP3,cDate,cTime,nUsaSSL)
Local lRet := .T.

If nUsaPOP3 <> 2
	MsgRun( 'Efetuando um teste nos dados de POP3. Por favor, aguarde...',;
			'Aguarde...',;
			{|| lRet := DIXRecMail(nUsaPOP3,AllTrim(cPOP3),AllTrim(cUsuPOP3),AllTrim(cSenPOP3),nPortPOP3,cDate,cTime,nUsaSSL) })
EndIf

Return lRet

//-----
Static Function DIXRecMail(nUsaPOP3,cPOP3,cUsuPOP3,cSenPOP3,nPortPOP3,cDate,cTime,nUsaSSL)
Local nRet        := 0
Local oPOPManager := Nil
Local nNumMsg     := 0
Local nCntFor1    := 0
Local lRet        := .F.
Local lUsaSSl     := nUsaSSL == 1
Local nC          := 0
Local cProtocol   := AllTrim(Upper(GetPvProfString("MAIL", "PROTOCOL", "POP3", GetAdv97())))

// CONEXAO POP ---------------------------------------
oPOPManager:= tMailManager():New()
oPOPManager:SetUseSSL(lUsaSSl)
oPOPManager:Init(cPOP3, "", cUsuPOP3, cSenPOP3, nPortPOP3,0  )

If cProtocol == "POP3"
	nRet := oPOPManager:POPConnect()
ElseIf cProtocol == "IMAP"
	nRet := oPOPManager:IMAPConnect()
EndIf

If nRet != 0
	MsgStop("Falha ao conectar no POP3: "+CRLF+oPOPManager:GetErrorString(nRet))
	Return .F.
Else
	lRet := .T.
EndIf

//Desconecta do servidor POP
oPOPManager:POPDisconnect()

If !lRet
	MsgStop("Nao foi possivel encontrar o E-MAIL TESTE do POP3, realize novamente o teste do SMTP")
Else
	MsgInfo("Teste de POP3: Ok")
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³DIXGrvCfg ³Autor  ³ FERNANDO SALVATORI                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Efetua a Gravacao dos Parametros da Rotina                 ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function DIXGrvCfg(nUsaMail ,nAutentic,cSMTP    ,nPortSMTP,;
                        cUsuSmtp ,cSenSmtp ,cAccRem  ,nTimeOut ,;
                        cPOP3    ,nPortPOP3,cUsuPOP3 ,cSenPOP3 ,;
                        nUsaTLS  ,nUsaSSL  ,cEmailAud,cCFOPBen ,;
                        nCDNewFor,cCndFor  ,nUsaPOP3 ,lVldNFE  ,;
                        lCadProd ,nCadCli  ,cCFOPDev ,lVldNCM   )

//Sem configuracao de E-MAIL, limpa os parametros
If nUsaMail == 2
	nAutentic  := 2
	cSMTP      := ""
	nPortSMTP  := 25
	cUsuSmtp   := ""
	cSenSmtp   := ""
	cAccRem    := ""
	nUsaTLS    := 2
	nTimeOut   := 120
EndIf

If nUsaPOP3 == 2
	cPOP3      := ""
	nPortPOP3  := 110
	cUsuPOP3   := ""
	cSenPOP3   := ""
	nUsaSSL    := 2
EndIf

// Ajusta parâmetros especificos
PutMV("ES_USAMAIL",nUsaMail )
PutMV("ES_USAPOP3",nUsaPOP3 )
PutMV("ES_POP3SRV",cPOP3    )
PutMV("ES_POP3POR",nPortPOP3)
PutMV("ES_USUPOP3",cUsuPOP3 )
PutMV("ES_PSWPOP3",cSenPOP3 )
PutMV("ES_MAILADM",cEmailAud)
PutMV("ES_CDNWFOR",nCDNewFor)
PutMV("ES_CDNWCLI",nCadCli  )
PutMV("ES_CONPGNF",cCndFor  )
PutMV("ES_HBCONNF",lVldNFE  )
PutMV("ES_INCPROD",lCadProd )
PutMV("ES_CFOPBEN",cCFOPBen )
PutMV("ES_CFOPDEV",cCFOPDev )
PutMV("ES_VLDNCM" ,lVldNCM  )

// Ajusta parâmetros do padrao.
PutMV("MV_RELTLS" ,IIF(nUsaTLS==1  ,.T.,.F.))
PutMV("MV_RELSSL" ,IIF(nUsaSSL==1  ,.T.,.F.))
PutMV("MV_RELAUTH",IIF(nAutentic==1,.T.,.F.))
PutMV("MV_RELSERV",cSMTP    )
PutMV("MV_GCPPORT",nPortSMTP)
PutMV("MV_RELACNT",cUsuSmtp )
PutMV("MV_RELPSW" ,cSenSmtp )
PutMV("MV_RELFROM",cAccRem  )
PutMV("MV_RELTIME",nTimeOut )

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³ DXGetSXE ³Autor  ³ FERNANDO SALVATORI                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Tratamento completo para numeros sequenciais automaticos   ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function DXGetSXE(cAlias,cCampo,nIndice)
Local nSaveSx8	:= GetSx8Len()
Local cCodigo   := ""
Local cMay      := ""
Local aArea     := sGetArea()

sGetArea( aArea, cAlias )

cCodigo := GetSX8Num(cAlias,cCampo)
FreeUsedCode()
cMay    := Alltrim(xFilial(cAlias))+cCodigo

(cAlias)->(dbSetOrder(nIndice) )

Do While (cAlias)->(dbSeek(xFilial(cAlias)+cCodigo) ) .Or. !MayIUseCode(cMay)
	Do While (GetSX8Len() > nSaveSx8)
		ConfirmSx8()
	EndDo

	cCodigo := GetSX8Num(cAlias,cCampo)
	FreeUsedCode()
	cMay    := Alltrim(xFilial(cAlias))+cCodigo
EndDo

sRestArea( aArea )
Return cCodigo

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³ EXMLExpo ³Autor  ³ FERNANDO SALVATORI                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Exporta XML para base Local                                ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function EXMLExpo()
Local bProcesso	:= { |oSelf| EXMLPrc(oSelf) }
Local oTProces
Local aHelpPor  := {}
Local cPerg     := "EXLEXP"
Local cDescri   := "Esta rotina tem por objetivo, realizar o filtro das notas emitidas em um determinado período e exportar seus respectivos XML´s conforme filtro definido nos parametros desta rotina."

aHelpPor := {}
AAdd(aHelpPor, "Diretorio destino dos arquivos xml.     ")
PutSx1(cPerg, "01", "Caminho?", "Caminho?", "Caminho?", "mv_ch1", "C", 99, 0, 0, "G", "", "XMLDIR", "", "", "MV_PAR01", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", aHelpPor, aHelpPor, aHelpPor)

aHelpPor := {}
AAdd(aHelpPor, "Informe a filial inicial para filtro    ")
PutSx1(cPerg, "02", "Filial de?", "Filial de?", "Filial de?", "mv_ch2", "C", Len(SF1->F1_FILIAL), 0, 0, "G", "", "SM0", "", "", "MV_PAR02", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", aHelpPor, aHelpPor, aHelpPor)

aHelpPor := {}
AAdd(aHelpPor, "Informe a filial final para filtro      ")
PutSx1(cPerg, "03", "Filial Ate?", "Filial Ate?", "Filial Ate?", "mv_ch3", "C", Len(SF1->F1_FILIAL), 0, 0, "G", "", "SM0", "", "", "MV_PAR03", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", aHelpPor, aHelpPor, aHelpPor)

aHelpPor := {}
AAdd(aHelpPor, "Informe o Documento inicial para filtro ")
PutSx1(cPerg, "04", "Documento De?", "Documento De?", "Documento De?", "mv_ch4", "C", Len(SF1->F1_DOC), 0, 0, "G", "", "", "", "", "MV_PAR04", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", aHelpPor, aHelpPor, aHelpPor)

aHelpPor := {}
AAdd(aHelpPor, "Informe o Documento final para filtro   ")
PutSx1(cPerg, "05", "Documento Ate?", "Documento Ate?", "Documento Ate?", "mv_ch5", "C", Len(SF1->F1_DOC), 0, 0, "G", "", "", "", "", "MV_PAR05", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", aHelpPor, aHelpPor, aHelpPor)

aHelpPor := {}
AAdd(aHelpPor, "Informe a Serie inicial para filtro     ")
PutSx1(cPerg, "06", "Serie De?", "Serie De?", "Serie De?", "mv_ch6", "C", Len(SF1->F1_SERIE), 0, 0, "G", "", "", "", "", "MV_PAR06", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", aHelpPor, aHelpPor, aHelpPor)

aHelpPor := {}
AAdd(aHelpPor, "Informe a Serie final para filtro       ")
PutSx1(cPerg, "07", "Serie Ate?", "Serie Ate?", "Serie Ate?", "mv_ch7", "C", Len(SF1->F1_SERIE), 0, 0, "G", "", "", "", "", "MV_PAR07", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", aHelpPor, aHelpPor, aHelpPor)

aHelpPor := {}
AAdd(aHelpPor, "Informe a Data de Emissao Inicial       ")
PutSx1(cPerg, "08", "Data Emissao de?", "Data Emissao de?", "Data Emissao de?", "mv_ch8", "D", 8, 0, 0, "G", "", "", "", "", "MV_PAR08", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", aHelpPor, aHelpPor, aHelpPor)

aHelpPor := {}
AAdd(aHelpPor, "Informe a Data de Emissao Final         ")
PutSx1(cPerg, "09", "Data Emissao Ate?", "Data Emissao Ate?", "Data Emissao Ate?", "mv_ch9", "D", 8, 0, 0, "G", "", "", "", "", "MV_PAR09", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", aHelpPor, aHelpPor, aHelpPor)

aHelpPor := {}
AAdd(aHelpPor, "Informe o fornecedor inicial para filtro")
PutSx1(cPerg, "10", "Fornecedor De?", "Fornecedor de?", "Fornecedor de?", "mv_cha", "C", Len(SF1->F1_FORNECE), 0, 0, "G", "", "", "", "", "MV_PAR10", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", aHelpPor, aHelpPor, aHelpPor)

aHelpPor := {}
AAdd(aHelpPor, "Informe a loja do fornecedor inicial    ")
PutSx1(cPerg, "11", "Loja De?", "Loja de?", "Loja de?", "mv_chb", "C", Len(SF1->F1_LOJA), 0, 0, "G", "", "", "", "", "MV_PAR11", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", aHelpPor, aHelpPor, aHelpPor)

aHelpPor := {}
AAdd(aHelpPor, "Informe o fornecedor final para filtro  ")
PutSx1(cPerg, "12", "Fornecedor Ate?", "Fornecedor Ate?", "Fornecedor Ate?", "mv_chc", "C", Len(SF1->F1_FORNECE), 0, 0, "G", "", "", "", "", "MV_PAR12", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", aHelpPor, aHelpPor, aHelpPor)

aHelpPor := {}
AAdd(aHelpPor, "Informe a loja do fornecedor final      ")
PutSx1(cPerg, "13", "Loja Ate?", "Loja Ate?", "Loja Ate?", "mv_chd", "C", Len(SF1->F1_LOJA), 0, 0, "G", "", "", "", "", "MV_PAR13", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", aHelpPor, aHelpPor, aHelpPor)

oTProces := tNewProcess():New( "EXMLEXPO" , "Exportar XML NF-e" , bProcesso , cDescri , cPerg ,,,,,.T.,.T.)

Return Nil
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³ EXMLExpo ³Autor  ³ FERNANDO SALVATORI                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Exporta XML para base Local                                ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function EXMLPrc(oSelf)
Local cQuery   := ""
Local nHdl     := 0
Local aLog     := {}
Local nX       := 0
Local lFirst1  := .T.
LoCAL lFirst2  := .T.
Local cTexto   := ""
Local cFileLog := ""
Local nCnt     := 0
Local oFont
Local oDlgLog
Local oMemo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifico se o destino dos arquivos XML é valido³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty( MV_PAR01 )
	Aviso("Erro","Informe um caminho válido para o destino dos arquivos XML.",{"OK"},2,"ReadXML")
	Return Nil
EndIf

MV_PAR01 := AllTrim(MV_PAR01)

//Acrescenta uma barra ao final do parametro
If Right(MV_PAR01,1) <> "\"
	MV_PAR01 += "\"
EndIf

If File(MV_PAR01+"teste.lck")
	FErase(MV_PAR01+"teste.lck")
EndIf

nHdl  := fCreate(MV_PAR01+"teste.lck")

If nHdl < 0
	Aviso("Erro","O Caminho informado nao possui permissão de gravação dos arquivos, escolha um caminho válido ou solicite ao administrador do computador a permissão de gravação neste diretório.",{"OK"},2,"ReadXML")
	Return Nil
EndIf

fClose(nHdl)
If File(MV_PAR01+"teste.lck")
	FErase(MV_PAR01+"teste.lck")
EndIf

oSelf:SaveLog("Inicio do Processo")

cQuery := " SELECT F1_FILIAL, F1_DOC, F1_SERIE, F1_U_ARXML FROM "+RetSQLName("SF1")
cQuery += "  WHERE F1_FILIAL  >= '"+xFilial("SF1",MV_PAR02)+"' AND F1_FILIAL  <='"+xFilial("SF1",MV_PAR03)+"' "
cQuery += "    AND F1_DOC     >= '"+MV_PAR04+"' AND F1_DOC     <='"+MV_PAR05+"' "
cQuery += "    AND F1_SERIE   >= '"+MV_PAR06+"' AND F1_SERIE   <='"+MV_PAR07+"' "
cQuery += "    AND F1_FORNECE >= '"+MV_PAR10+"' AND F1_FORNECE <='"+MV_PAR12+"' "
cQuery += "    AND F1_LOJA    >= '"+MV_PAR11+"' AND F1_LOJA    <='"+MV_PAR13+"' "
cQuery += "    AND F1_EMISSAO >= '"+DtoS(MV_PAR08)+"' AND F1_EMISSAO <='"+DtoS(MV_PAR09)+"' "
cQuery += "    AND D_E_L_E_T_ = ' ' "

If Select("TSF1") > 0
	TSF1->( dbCloseArea() )
EndIf

TCQUERY ChangeQuery( cQuery ) ALIAS "TSF1" NEW

dbGotop()
COUNT to nCnt
dbGotop()

oSelf:SetRegua1(nCnt)

If nCnt <= 0
	Aviso("Erro","Não foram encontrados notas fiscais com os parametros informados.",{"OK"},2,"ReadXML")
Else
	Do While !Eof()
		oSelf:IncRegua1("Exportando, aguarde...")

		U_DIXRetXML( AllTrim( SubStr(TSF1->F1_U_ARXML,6) ), MV_PAR01 )

		If File( MV_PAR01 + AllTrim( SubStr(TSF1->F1_U_ARXML,6) ) )
			AAdd( aLog, {1,TSF1->F1_FILIAL,TSF1->F1_DOC,TSF1->F1_SERIE,TSF1->F1_U_ARXML} )
		Else
			AAdd( aLog, {2,TSF1->F1_FILIAL,TSF1->F1_DOC,TSF1->F1_SERIE,TSF1->F1_U_ARXML} )
		EndIf

		dbSkip()
	EndDo
EndIf

If !Empty( aLog )
	aLog := aSort(aLog,,,{|x,y| x[1] < y[1]})

	For nX := 1 to Len( aLog )
		If aLog[nX,1] == 1 .And. lFirst1
			cTexto += CRLF+CRLF+"ARQUIVOS ENCONTRADOS E EXPORTADOS: "+CRLF+CRLF
			lFirst1 := .F.
		EndIf

		If aLog[nX,1] == 2 .And. lFirst2
			cTexto += CRLF+CRLF+"ARQUIVOS NAO ENCONTRADOS: "+CRLF+CRLF
			lFirst2 := .F.
		EndIf

		cTexto += "Filial: "+aLog[nX,2]+" Documento: "+aLog[nX,3]+" Serie: "+aLog[nX,4]+" XML: "+AllTrim(aLog[nX,5]) + CRLF
	Next nX

	cFileLog := MemoWrite( CriaTrab( , .F. ) + ".log", cTexto )

	DEFINE FONT oFont NAME "Mono AS" Size 5, 12

	DEFINE MSDIALOG oDlgLog Title "Atualizacao concluida." From 3, 0 to 340, 417 Pixel

	@ 5, 5 GET oMemo VAR cTexto Memo SIZE 200, 145 Of oDlgLog PIXEL
	oMemo:bRClicked := { || AllwaysTrue() }
	oMemo:oFont     := oFont

	DEFINE SBUTTON FROM 153, 175 TYPE  1 ACTION oDlgLog:End() ENABLE Of oDlgLog PIXEL // Apaga

	ACTIVATE MSDIALOG oDlgLog CENTER

//	If GetRemoteType() == 1 // Caso a plataforma seja Windows, abre o diretorio para auxilio ao usuario
//		WinExec("explorer "+MV_PAR01)
//	EndIf
EndIf

oSelf:SaveLog("Fim do Processo")

If Select("TSF1") > 0
	TSF1->( dbCloseArea() )
EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³ XMLPath  ³Autor  ³ FERNANDO SALVATORI                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Seleciona diretorio de retorno                             ³±±
±±³          ³ (Consulta padrao XMLDIR)                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function XMLPath(cType)
Local cTitDir := "Selecione o Diretório "
Local nDir    := 0

DEFAULT cType := ""

If !Empty( cType )
	cTitDir := "Selecione o Arquivo "
EndIf

nDir := GETF_NETWORKDRIVE + GETF_LOCALHARD + GETF_LOCALFLOPPY + GETF_RETDIRECTORY

cRetArq	:= cGetFile(cType, cTitDir,Nil,Nil,.F.,nDir,.F.)

Return !Empty(cRetArq)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³ XMLDir   ³Autor  ³ FERNANDO SALVATORI                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Retorno do diretorio escolhido                             ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function XMLDir()

Return(cRetArq)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³XMLConsNfe³Autor  ³ FERNANDO SALVATORI                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Consulta a chave da NFE se eh valida                       ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function XMLConsNfe(cChaveNFe,aCabecNFE,cFile,aErros,lMensExib,lJob,nTipCons)

Local cURL      := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cMensagem := ""
Local cIdEnt    := ""
Local oWS
Local aRet      := Array(6)

DEFAULT aCabecNFE := {}
DEFAULT cFile     := ""
DEFAULT aErros    := {}
DEFAULT lMensExib := .F.
DEFAULT lJob      := .F.
DEFAULT nTipCons  := 1

aRet[1] := ""
aRet[2] := 0
aRet[3] := ""
aRet[4] := ""
aRet[5] := ""
aRet[6] := ""

If CTIsReady()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Obtem o codigo da entidade                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cIdEnt := RetIdEnti()
	If !Empty(cIdEnt)
		oWs:= WsNFeSBra():New()
		oWs:cUserToken   := "TOTVS"
		oWs:cID_ENT      := cIdEnt
		ows:cCHVNFE      := cChaveNFe
		oWs:_URL         := AllTrim(cURL)+"/NFeSBRA.apw"

		If oWs:ConsultaChaveNFE()
			cMensagem := ""
			If !Empty(oWs:oWSCONSULTACHAVENFERESULT:cVERSAO)
				cMensagem += "Versão da mensagem: "+oWs:oWSCONSULTACHAVENFERESULT:cVERSAO+CRLF
			EndIf
			cMensagem += "Ambiente: "+IIf(oWs:oWSCONSULTACHAVENFERESULT:nAMBIENTE==1,"Produção","Homologação")+CRLF //###"Homologação"
			cMensagem += "Cod.Ret.NFe: "+oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE+CRLF
			cMensagem += "Msg.Ret.NFe: "+oWs:oWSCONSULTACHAVENFERESULT:cMSGRETNFE+CRLF
			If !Empty(oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO)
				cMensagem += "Protocolo: "+oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO+CRLF
			EndIf
		    If !Empty(oWs:oWSCONSULTACHAVENFERESULT:cDIGVAL)
				cMensagem += "Digest Value: "+oWs:oWSCONSULTACHAVENFERESULT:cDIGVAL+CRLF
			EndIf

			aRet[1] := oWs:oWSCONSULTACHAVENFERESULT:cVERSAO
			aRet[2] := oWs:oWSCONSULTACHAVENFERESULT:nAMBIENTE
			aRet[3] := oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE
			aRet[4] := oWs:oWSCONSULTACHAVENFERESULT:cMSGRETNFE
			aRet[5] := oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO
			aRet[6] := oWs:oWSCONSULTACHAVENFERESULT:cDIGVAL
		Else
			If !lJob
				Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"Ok"},3)
				lMensExib := .T.
			Else
				AAdd(aErros,{cFile,"Erro na comunicação do Serviço do TSS.",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))})
			EndIf
		EndIf
	Else
		If !lJob
			Aviso("SPED","Execute o módulo de configuração do serviço do SPED NFE, antes de utilizar esta opção!",{"Ok"},3)
			lMensExib := .T.
		Else
			AAdd(aErros,{cFile,"Erro na comunicação do Serviço do TSS.","Execute o módulo de configuração do serviço do SPED NFE, antes de utilizar esta opção!"})
		EndIf
	EndIf
EndIf

Return aRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³XMLCvNfe  ³Autor  ³ FERNANDO SALVATORI                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Consulta a chave da NFE se eh valida                       ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function XMLCvNfe(cChvNfe,aCabecNFE,cFile,aErros,lMensExib,lJob,nTipCons, cFile)
Local aProtoc := {}
Local cMsg    := ''
Local nPosDoc := 0
Local lRet    := .T.


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametro que determina se habilita consulta da chave da NFE no sistema³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !GetNewPar("ES_HBCONNF",.T.)
	Return .T.
EndIf

DEFAULT aCabecNFE := {}
DEFAULT cFile     := ""
DEFAULT aErros    := {}
DEFAULT lMensExib := .F.
DEFAULT lJob      := .F.
DEFAULT nTipCons  := 1

//Variavel nTipCons
//1=Validar a chave
//2=Revalidar a chave

If !Empty(cChvNfe)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Funcao XMLConsNFE                      ³
	//³                                       ³
	//³1 - Versao da NFE                      ³
	//³2 - Ambiente (1=Producao/2=Homologacao)³
	//³3 - Codigo de Retorno da NFE           ³
	//³4 - Mensagem de Retorno da NFE         ³
	//³5 - Protocolo                          ³
	//³6 - DigVal                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aProtoc := aClone(XMLConsNfe(cChvNfe,@aCabecNFE,@cFile,@aErros,@lMensExib,@lJob,@nTipCons))

	If Empty(aProtoc[5])
		cMsg := 'Não foi encontrado o protocolo de autenticação desta chave da NFe ou ocorreram erros durante a validação da chave.' + CRLF
		nPosDoc := aScan(aCabecNFE, {|x| x[1] == 'F1_DOC'})
		If nPosDoc <> 0
			cMsg += 'Nota Fiscal No. ' + aCabecNFE[nPosDoc, 2] + CRLF
			cMsg += 'Chave da NFe: ' + cChvNfe + CRLF
			cMsg += 'Arquivo XML: ' + cFile
		EndIf
		If !Empty(aProtoc[4])
			cMsg += CRLF
			cMsg += 'Mensagem Validação: ' + aProtoc[4]
		EndIf

		If lJob
			AAdd(aErros,{cFile, "Erro Validação da Chave da NFE", cMsg})
		Else
			If !lMensExib
				Aviso("Erro", cMsg, {"OK"}, 3, "ReadXML")
				lMensExib := .T.
			EndIf
		EndIf
		lRet := .F.

	ElseIf aProtoc[2] == 2
		cMsg := 'Esta NF foi emitida em ambiente Homologacao, sem valor fiscal' + CRLF
		nPosDoc := aScan(aCabecNFE, {|x| x[1] == 'F1_DOC'})
		If nPosDoc <> 0
			cMsg += 'Nota Fiscal No. ' + aCabecNFE[nPosDoc, 2] + CRLF
			cMsg += 'Chave da NFe: ' + cChvNfe + CRLF
			cMsg += 'Arquivo XML: ' + cFile
		EndIf
		If lJob
			AAdd(aErros,{cFile,"Erro Validação da Chave da NFE", cMsg})
		Else
			If !lMensExib
				Aviso("Erro", cMsg, {"OK"}, 3, "ReadXML")
				lMensExib := .T.
			EndIf
		EndIf
		lRet := .F.

	ElseIf AllTrim(aProtoc[3]) <> "100" //-- <> 100: Problemas com a chave da NFe
		cMsg := 'Chave da NFe não é válida!' + CRLF
		cMsg += 'Descrição do erro: ' + AllTrim(aProtoc[4]) + CRLF
		nPosDoc := aScan(aCabecNFE, {|x| x[1] == 'F1_DOC'})
		If nPosDoc <> 0
			cMsg += 'Nota Fiscal No. ' + aCabecNFE[nPosDoc, 2] + CRLF
			cMsg += 'Chave da NFe: ' + cChvNfe + CRLF
			cMsg += 'Arquivo XML: ' + cFile
		EndIf

		If lJob
			AAdd(aErros,{cFile, "Erro Validação da Chave da NFE", cMsg})
		Else
			If !lMensExib
				Aviso("Erro", cMsg, {"OK"}, 3, "ReadXML")
				lMensExib := .T.
			EndIf
		EndIf
		lRet := .F.

	ElseIf AllTrim(aProtoc[3]) == '100'//--100: NFe normal, autorizada.
		If nTipCons == 1
			AAdd(aCabecNFE, {"F1_1_DTCNS", Date()  , NIL})  //Data da Consulta da NFE
			AAdd(aCabecNFE, {"F1_1_HRCNS", Time() , NIL})   //Hora da Consulta da NFE
			AAdd(aCabecNFE, {"F1_1_VRNFE", aProtoc[1] , NIL})  //Versao da consulta - NFE
			AAdd(aCabecNFE, {"F1_1_AMNFE", Str(aProtoc[2],1) , NIL})  //Ambiente Emitido - NFE
			AAdd(aCabecNFE, {"F1_1_CRNFE", aProtoc[3] , NIL})  //Codigo de Retorno da NFE
			AAdd(aCabecNFE, {"F1_1_MRNFE", aProtoc[4] , NIL})  //Mensagem de Retorno - NFE
			AAdd(aCabecNFE, {"F1_1_PRNFE", aProtoc[5] , NIL})  //Protocolo da NFE - NFE
			AAdd(aCabecNFE, {"F1_1_DVNFE", aProtoc[6] , NIL})  //DigVal da NFE
		ElseIf nTipCons == 2
			AAdd(aCabecNFE, {"F1_2_DTCNS", Date()  , NIL})  //Data da Consulta da NFE
			AAdd(aCabecNFE, {"F1_2_HRCNS", Time() , NIL})   //Hora da Consulta da NFE
			AAdd(aCabecNFE, {"F1_2_VRNFE", aProtoc[1] , NIL})  //Versao da consulta - NFE
			AAdd(aCabecNFE, {"F1_2_AMNFE", Str(aProtoc[2],1) , NIL})  //Ambiente Emitido - NFE
			AAdd(aCabecNFE, {"F1_2_CRNFE", aProtoc[3] , NIL})  //Codigo de Retorno da NFE
			AAdd(aCabecNFE, {"F1_2_MRNFE", aProtoc[4] , NIL})  //Mensagem de Retorno - NFE
			AAdd(aCabecNFE, {"F1_2_PRNFE", aProtoc[5] , NIL})  //Protocolo da NFE - NFE
			AAdd(aCabecNFE, {"F1_2_DVNFE", aProtoc[6] , NIL})  //DigVal da NFE
		EndIf
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³XMLVerTSS ºAutor  ³ Fernando Salvatori º Data ³  04/16/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se o TSS está no ar                               º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function XMLVerTSS(lJob)
Local cIdEnt    := ""
Local lRet      := .T.

Default lJob    := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametro que determina se habilita consulta da chave da NFE no sistema³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !GetNewPar("ES_HBCONNF",.T.)
	Return .T.
EndIf

If CTIsReady()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Obtem o codigo da entidade                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cIdEnt := RetIdEnti()
	If Empty(cIdEnt)
		If !lJob
			Aviso("SPED","Verifique se o serviço do TSS está ativo ou execute o módulo de configuração do serviço do SPED NFE, antes de utilizar esta opção!",{"Ok"},3)
		Else
			// Caso o processamento seja executado via JOB, envia e-mail para administrador para alertar que o serviço está fora do ar
			ErrTSSMail()
		EndIf
		lRet := .F.
	EndIf
Else
	If !lJob
		Aviso("SPED","Verifique se o serviço do TSS está ativo ou execute o módulo de configuração do serviço do SPED NFE, antes de utilizar esta opção!",{"Ok"},3)
	Else
		// Caso o processamento seja executado via JOB, envia e-mail para administrador para alertar que o serviço está fora do ar
		ErrTSSMail()
	EndIf

	lRet := .F.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ UPDEXML  º Autor ³ TOTVS Protheus     º Data ³  24/04/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao³ Funcao de update dos dicionários para compatibilização     ³±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³ Uso      ³ UPDEXML    - Gerado por EXPORDIC / Upd. V.4.10.6 EFS       ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function UPDEXML( cEmpAmb, cFilAmb )

Local   aSay      := {}
Local   aButton   := {}
Local   aMarcadas := {}
Local   cTitulo   := "ATUALIZAÇÃO DE DICIONÁRIOS E TABELAS"
Local   cDesc1    := "Esta rotina tem como função fazer  a atualização  dos dicionários do Sistema ( SX?/SIX )"
Local   cDesc2    := "Este processo deve ser executado em modo EXCLUSIVO, ou seja não podem haver outros"
Local   cDesc3    := "usuários  ou  jobs utilizando  o sistema.  É extremamente recomendavél  que  se  faça um"
Local   cDesc4    := "BACKUP  dos DICIONÁRIOS  e da  BASE DE DADOS antes desta atualização, para que caso "
Local   cDesc5    := "ocorra eventuais falhas, esse backup seja ser restaurado."
Local   cDesc6    := ""
Local   cDesc7    := ""
Local   lOk       := .F.
Local   lAuto     := ( cEmpAmb <> NIL .or. cFilAmb <> NIL )

Private oMainWnd  := NIL
Private oProcess  := NIL

#IFDEF TOP
    TCInternal( 5, "*OFF" ) // Desliga Refresh no Lock do Top
#ENDIF

__cInterNet := NIL
__lPYME     := .F.

Set Dele On

// Mensagens de Tela Inicial
aAdd( aSay, cDesc1 )
aAdd( aSay, cDesc2 )
aAdd( aSay, cDesc3 )
aAdd( aSay, cDesc4 )
aAdd( aSay, cDesc5 )
//aAdd( aSay, cDesc6 )
//aAdd( aSay, cDesc7 )

// Botoes Tela Inicial
aAdd(  aButton, {  1, .T., { || lOk := .T., FechaBatch() } } )
aAdd(  aButton, {  2, .T., { || lOk := .F., FechaBatch() } } )

If lAuto
	lOk := .T.
Else
	FormBatch(  cTitulo,  aSay,  aButton )
EndIf

If lOk
	If lAuto
		aMarcadas :={{ cEmpAmb, cFilAmb, "" }}
	Else
		aMarcadas := EscEmpresa()
	EndIf

	If !Empty( aMarcadas )
		If lAuto .OR. MsgNoYes( "Confirma a atualização dos dicionários ?", cTitulo )
			oProcess := MsNewProcess():New( { | lEnd | lOk := FSTProc( @lEnd, aMarcadas ) }, "Atualizando", "Aguarde, atualizando ...", .F. )
			oProcess:Activate()

		If lAuto
			If lOk
				MsgStop( "Atualização Realizada.", "UPDEXML" )
				dbCloseAll()
			Else
				MsgStop( "Atualização não Realizada.", "UPDEXML" )
				dbCloseAll()
			EndIf
		Else
			If lOk
				Final( "Atualização Concluída." )
			Else
				Final( "Atualização não Realizada." )
			EndIf
		EndIf

		Else
			MsgStop( "Atualização não Realizada.", "UPDEXML" )

		EndIf

	Else
		MsgStop( "Atualização não Realizada.", "UPDEXML" )

	EndIf

EndIf

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ FSTProc  º Autor ³ TOTVS Protheus     º Data ³  24/04/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao³ Funcao de processamento da gravação dos arquivos           ³±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³ Uso      ³ FSTProc    - Gerado por EXPORDIC / Upd. V.4.10.6 EFS       ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FSTProc( lEnd, aMarcadas )
Local   aInfo     := {}
Local   aRecnoSM0 := {}
Local   cAux      := ""
Local   cFile     := ""
Local   cFileLog  := ""
Local   cMask     := "Arquivos Texto" + "(*.TXT)|*.txt|"
Local   cTCBuild  := "TCGetBuild"
Local   cTexto    := ""
Local   cTopBuild := ""
Local   lOpen     := .F.
Local   lRet      := .T.
Local   nI        := 0
Local   nPos      := 0
Local   nRecno    := 0
Local   nX        := 0
Local   oDlg      := NIL
Local   oFont     := NIL
Local   oMemo     := NIL

Private aArqUpd   := {}

If ( lOpen := MyOpenSm0(.T.) )

	dbSelectArea( "SM0" )
	dbGoTop()

	While !SM0->( EOF() )
		// So adiciona no aRecnoSM0 se a empresa for diferente
		If aScan( aRecnoSM0, { |x| x[2] == SM0->M0_CODIGO } ) == 0 ;
		   .AND. aScan( aMarcadas, { |x| x[1] == SM0->M0_CODIGO } ) > 0
			aAdd( aRecnoSM0, { Recno(), SM0->M0_CODIGO } )
		EndIf
		SM0->( dbSkip() )
	End

	SM0->( dbCloseArea() )

	If lOpen

		For nI := 1 To Len( aRecnoSM0 )

			If !( lOpen := MyOpenSm0(.F.) )
				MsgStop( "Atualização da empresa " + aRecnoSM0[nI][2] + " não efetuada." )
				Exit
			EndIf

			SM0->( dbGoTo( aRecnoSM0[nI][1] ) )

			RpcSetType( 3 )
			RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL )

			lMsFinalAuto := .F.
			lMsHelpAuto  := .F.

			cTexto += Replicate( "-", 128 ) + CRLF
			cTexto += "Empresa : " + SM0->M0_CODIGO + "/" + SM0->M0_NOME + CRLF + CRLF

			oProcess:SetRegua1( 8 )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza o dicionário SX3         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			FSAtuSX3( @cTexto )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza o dicionário SXB         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			FSAtuSXB( @cTexto )

			oProcess:IncRegua1( "Dicionário de dados" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			oProcess:IncRegua2( "Atualizando campos/índices" )

			//------------------------------------
			// Atualiza o dicionário SX6
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de parâmetros" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSX6()

			// Alteracao fisica dos arquivos
			__SetX31Mode( .F. )

			If FindFunction(cTCBuild)
				cTopBuild := &cTCBuild.()
			EndIf

			For nX := 1 To Len( aArqUpd )

				If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
					If ( ( aArqUpd[nX] >= "NQ " .AND. aArqUpd[nX] <= "NZZ" ) .OR. ( aArqUpd[nX] >= "O0 " .AND. aArqUpd[nX] <= "NZZ" ) ) .AND.;
						!aArqUpd[nX] $ "NQD,NQF,NQP,NQT"
						TcInternal( 25, "CLOB" )
					EndIf
				EndIf

				If Select( aArqUpd[nX] ) > 0
					dbSelectArea( aArqUpd[nX] )
					dbCloseArea()
				EndIf

				X31UpdTable( aArqUpd[nX] )

				If __GetX31Error()
					Alert( __GetX31Trace() )
					MsgStop( "Ocorreu um erro desconhecido durante a atualização da tabela : " + aArqUpd[nX] + ". Verifique a integridade do dicionário e da tabela.", "ATENÇÃO" )
					cTexto += "Ocorreu um erro desconhecido durante a atualização da estrutura da tabela : " + aArqUpd[nX] + CRLF
				EndIf

				If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
					TcInternal( 25, "OFF" )
				EndIf

			Next nX

			RpcClearEnv()

		Next nI

		If MyOpenSm0(.T.)

			cAux += Replicate( "-", 128 ) + CRLF
			cAux += Replicate( " ", 128 ) + CRLF
			cAux += "LOG DA ATUALIZACAO DOS DICIONÁRIOS" + CRLF
			cAux += Replicate( " ", 128 ) + CRLF
			cAux += Replicate( "-", 128 ) + CRLF
			cAux += CRLF
			cAux += " Dados Ambiente" + CRLF
			cAux += " --------------------"  + CRLF
			cAux += " Empresa / Filial...: " + cEmpAnt + "/" + cFilAnt  + CRLF
			cAux += " Nome Empresa.......: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOMECOM", cEmpAnt + cFilAnt, 1, "" ) ) ) + CRLF
			cAux += " Nome Filial........: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) ) + CRLF
			cAux += " DataBase...........: " + DtoC( dDataBase )  + CRLF
			cAux += " Data / Hora Inicio.: " + DtoC( Date() )  + " / " + Time()  + CRLF
			cAux += " Environment........: " + GetEnvServer()  + CRLF
			cAux += " StartPath..........: " + GetSrvProfString( "StartPath", "" )  + CRLF
			cAux += " RootPath...........: " + GetSrvProfString( "RootPath" , "" )  + CRLF
			cAux += " Versao.............: " + GetVersao(.T.)  + CRLF
			cAux += " Usuario TOTVS .....: " + __cUserId + " " +  cUserName + CRLF
			cAux += " Computer Name......: " + GetComputerName() + CRLF

			aInfo   := GetUserInfo()
			If ( nPos    := aScan( aInfo,{ |x,y| x[3] == ThreadId() } ) ) > 0
				cAux += " "  + CRLF
				cAux += " Dados Thread" + CRLF
				cAux += " --------------------"  + CRLF
				cAux += " Usuario da Rede....: " + aInfo[nPos][1] + CRLF
				cAux += " Estacao............: " + aInfo[nPos][2] + CRLF
				cAux += " Programa Inicial...: " + aInfo[nPos][5] + CRLF
				cAux += " Environment........: " + aInfo[nPos][6] + CRLF
				cAux += " Conexao............: " + AllTrim( StrTran( StrTran( aInfo[nPos][7], Chr( 13 ), "" ), Chr( 10 ), "" ) )  + CRLF
			EndIf
			cAux += Replicate( "-", 128 ) + CRLF
			cAux += CRLF

			cTexto := cAux + cTexto + CRLF

			cTexto += Replicate( "-", 128 ) + CRLF
			cTexto += " Data / Hora Final.: " + DtoC( Date() ) + " / " + Time()  + CRLF
			cTexto += Replicate( "-", 128 ) + CRLF

			cFileLog := MemoWrite( CriaTrab( , .F. ) + ".log", cTexto )

			Define Font oFont Name "Mono AS" Size 5, 12

			Define MsDialog oDlg Title "Atualizacao concluida." From 3, 0 to 340, 417 Pixel

			@ 5, 5 Get oMemo Var cTexto Memo Size 200, 145 Of oDlg Pixel
			oMemo:bRClicked := { || AllwaysTrue() }
			oMemo:oFont     := oFont

			Define SButton From 153, 175 Type  1 Action oDlg:End() Enable Of oDlg Pixel // Apaga
			Define SButton From 153, 145 Type 13 Action ( cFile := cGetFile( cMask, "" ), If( cFile == "", .T., ;
			MemoWrite( cFile, cTexto ) ) ) Enable Of oDlg Pixel

			Activate MsDialog oDlg Center

		EndIf

	EndIf

Else

	lRet := .F.

EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ FSAtuSX3 º Autor ³ TOTVS Protheus     º Data ³  24/04/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao³ Funcao de processamento da gravacao do SX3 - Campos        ³±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³ Uso      ³ FSAtuSX3   - Gerado por EXPORDIC / Upd. V.4.10.6 EFS       ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FSAtuSX3( cTexto )
Local aEstrut   := {}
Local aSX3      := {}
Local cAlias    := ""
Local cAliasAtu := ""
Local cMsg      := ""
Local cSeqAtu   := ""
Local lTodosNao := .F.
Local lTodosSim := .F.
Local nI        := 0
Local nJ        := 0
Local nOpcA     := 0
Local nPosArq   := 0
Local nPosCpo   := 0
Local nPosOrd   := 0
Local nPosSXG   := 0
Local nPosTam   := 0
Local nSeqAtu   := 0
Local nTamSeek  := Len( SX3->X3_CAMPO )

cTexto  += "Inicio da Atualizacao" + " SX3" + CRLF + CRLF

aEstrut := { "X3_ARQUIVO", "X3_ORDEM"  , "X3_CAMPO"  , "X3_TIPO"   , "X3_TAMANHO", "X3_DECIMAL", ;
             "X3_TITULO" , "X3_TITSPA" , "X3_TITENG" , "X3_DESCRIC", "X3_DESCSPA", "X3_DESCENG", ;
             "X3_PICTURE", "X3_VALID"  , "X3_USADO"  , "X3_RELACAO", "X3_F3"     , "X3_NIVEL"  , ;
             "X3_RESERV" , "X3_CHECK"  , "X3_TRIGGER", "X3_PROPRI" , "X3_BROWSE" , "X3_VISUAL" , ;
             "X3_CONTEXT", "X3_OBRIGAT", "X3_VLDUSER", "X3_CBOX"   , "X3_CBOXSPA", "X3_CBOXENG", ;
             "X3_PICTVAR", "X3_WHEN"   , "X3_INIBRW" , "X3_GRPSXG" , "X3_FOLDER" , "X3_PYME"   }

//
// Tabela SD1
//
aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	''																		, ; //X3_ORDEM
	'D1_U_CFNFE'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	5																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'CFOP - NFE'															, ; //X3_TITULO
	'CFOP - NFE'															, ; //X3_TITSPA
	'CFOP - NFE'															, ; //X3_TITENG
	'CFOP da NFE'															, ; //X3_DESCRIC
	'CFOP da NFE'															, ; //X3_DESCSPA
	'CFOP da NFE'															, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

//
// Tabela SF1
//
aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	''																		, ; //X3_ORDEM
	'F1_U_DTXML'															, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Dt. Import.'															, ; //X3_TITULO
	'Dt. Import.'															, ; //X3_TITSPA
	'Dt. Import.'															, ; //X3_TITENG
	'Data da Importacao do XML'												, ; //X3_DESCRIC
	'Data da Importacao do XML'												, ; //X3_DESCSPA
	'Data da Importacao do XML'												, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	''																		, ; //X3_ORDEM
	'F1_U_HRXML'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	5																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Hr. Import.'															, ; //X3_TITULO
	'Hr. Import.'															, ; //X3_TITSPA
	'Hr. Import.'															, ; //X3_TITENG
	'Hora da Importacao do XML'												, ; //X3_DESCRIC
	'Hora da Importacao do XML'												, ; //X3_DESCSPA
	'Hora da Importacao do XML'												, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	''																		, ; //X3_ORDEM
	'F1_U_ARXML'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	100																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Arq. XML'																, ; //X3_TITULO
	'Arq. XML'																, ; //X3_TITSPA
	'Arq. XML'																, ; //X3_TITENG
	'Arquivo XML Processado'												, ; //X3_DESCRIC
	'Arquivo XML Processado'												, ; //X3_DESCSPA
	'Arquivo XML Processado'												, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	'XMLDIR'																, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	''																		, ; //X3_ORDEM
	'F1_1_DTCNS'															, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Dt.Cons.NFE'															, ; //X3_TITULO
	'Dt.Cons.NFE'															, ; //X3_TITSPA
	'Dt.Cons.NFE'															, ; //X3_TITENG
	'Data da Consulta da NFE'												, ; //X3_DESCRIC
	'Data da Consulta da NFE'												, ; //X3_DESCSPA
	'Data da Consulta da NFE'												, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	''																		, ; //X3_ORDEM
	'F1_1_HRCNS'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Hr.Cons.NFE'															, ; //X3_TITULO
	'Hr.Cons.NFE'															, ; //X3_TITSPA
	'Hr.Cons.NFE'															, ; //X3_TITENG
	'Hora da Consulta do NFE'												, ; //X3_DESCRIC
	'Hora da Consulta do NFE'												, ; //X3_DESCSPA
	'Hora da Consulta do NFE'												, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	''																		, ; //X3_ORDEM
	'F1_1_VRNFE'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cons.Ver.NFE'															, ; //X3_TITULO
	'Cons.Ver.NFE'															, ; //X3_TITSPA
	'Cons.Ver.NFE'															, ; //X3_TITENG
	'Consulta da Versao do NFE'												, ; //X3_DESCRIC
	'Consulta da Versao do NFE'												, ; //X3_DESCSPA
	'Consulta da Versao do NFE'												, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	''																		, ; //X3_ORDEM
	'F1_1_AMNFE'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cons.Amb.NFE'															, ; //X3_TITULO
	'Cons.Amb.NFE'															, ; //X3_TITSPA
	'Cons.Amb.NFE'															, ; //X3_TITENG
	'Consulta Ambiente NFE'													, ; //X3_DESCRIC
	'Consulta Ambiente NFE'													, ; //X3_DESCSPA
	'Consulta Ambiente NFE'													, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	''																		, ; //X3_ORDEM
	'F1_1_CRNFE'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	4																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod.Ret.Nfe'															, ; //X3_TITULO
	'Cod.Ret.Nfe'															, ; //X3_TITSPA
	'Cod.Ret.Nfe'															, ; //X3_TITENG
	'Codigo de Retorno da NFE'												, ; //X3_DESCRIC
	'Codigo de Retorno da NFE'												, ; //X3_DESCSPA
	'Codigo de Retorno da NFE'												, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	''																		, ; //X3_ORDEM
	'F1_1_MRNFE'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	30																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Msg.Ret.NFE'															, ; //X3_TITULO
	'Msg.Ret.NFE'															, ; //X3_TITSPA
	'Msg.Ret.NFE'															, ; //X3_TITENG
	'Mensagem de Retorno da NF'												, ; //X3_DESCRIC
	'Mensagem de Retorno da NF'												, ; //X3_DESCSPA
	'Mensagem de Retorno da NF'												, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	''																		, ; //X3_ORDEM
	'F1_1_PRNFE'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Num.Prot.NFE'															, ; //X3_TITULO
	'Num.Prot.NFE'															, ; //X3_TITSPA
	'Num.Prot.NFE'															, ; //X3_TITENG
	'Numero de Protocolo da NF'												, ; //X3_DESCRIC
	'Numero de Protocolo da NF'												, ; //X3_DESCSPA
	'Numero de Protocolo da NF'												, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	''																		, ; //X3_ORDEM
	'F1_1_DVNFE'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	30																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'DigVal NFE'															, ; //X3_TITULO
	'DigVal NFE'															, ; //X3_TITSPA
	'DigVal NFE'															, ; //X3_TITENG
	'DigVal da NFE'															, ; //X3_DESCRIC
	'DigVal da NFE'															, ; //X3_DESCSPA
	'DigVal da NFE'															, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	''																		, ; //X3_ORDEM
	'F1_2_DTCNS'															, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'2 Dt.Cons.NF'															, ; //X3_TITULO
	'2 Dt.Cons.NF'															, ; //X3_TITSPA
	'2 Dt.Cons.NF'															, ; //X3_TITENG
	'Data da Consulta da NFE'												, ; //X3_DESCRIC
	'Data da Consulta da NFE'												, ; //X3_DESCSPA
	'Data da Consulta da NFE'												, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	''																		, ; //X3_ORDEM
	'F1_2_HRCNS'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'2 Hr.Cons.NF'															, ; //X3_TITULO
	'2 Hr.Cons.NF'															, ; //X3_TITSPA
	'2 Hr.Cons.NF'															, ; //X3_TITENG
	'Hora da Consulta do NFE'												, ; //X3_DESCRIC
	'Hora da Consulta do NFE'												, ; //X3_DESCSPA
	'Hora da Consulta do NFE'												, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	''																		, ; //X3_ORDEM
	'F1_2_VRNFE'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'2 Con.Ver.NF'															, ; //X3_TITULO
	'2 Con.Ver.NF'															, ; //X3_TITSPA
	'2 Con.Ver.NF'															, ; //X3_TITENG
	'Consulta da Versao do NFE'												, ; //X3_DESCRIC
	'Consulta da Versao do NFE'												, ; //X3_DESCSPA
	'Consulta da Versao do NFE'												, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	''																		, ; //X3_ORDEM
	'F1_2_AMNFE'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'2 Con.Amb.NF'															, ; //X3_TITULO
	'2 Con.Amb.NF'															, ; //X3_TITSPA
	'2 Con.Amb.NF'															, ; //X3_TITENG
	'Consulta Ambiente NFE'													, ; //X3_DESCRIC
	'Consulta Ambiente NFE'													, ; //X3_DESCSPA
	'Consulta Ambiente NFE'													, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	''																		, ; //X3_ORDEM
	'F1_2_CRNFE'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	4																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'2 Cod.Ret.Nf'															, ; //X3_TITULO
	'2 Cod.Ret.Nf'															, ; //X3_TITSPA
	'2 Cod.Ret.Nf'															, ; //X3_TITENG
	'Codigo de Retorno da NFE'												, ; //X3_DESCRIC
	'Codigo de Retorno da NFE'												, ; //X3_DESCSPA
	'Codigo de Retorno da NFE'												, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	''																		, ; //X3_ORDEM
	'F1_2_MRNFE'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	30																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'2 Msg.Ret.NF'															, ; //X3_TITULO
	'2 Msg.Ret.NF'															, ; //X3_TITSPA
	'2 Msg.Ret.NF'															, ; //X3_TITENG
	'Mensagem de Retorno da NF'												, ; //X3_DESCRIC
	'Mensagem de Retorno da NF'												, ; //X3_DESCSPA
	'Mensagem de Retorno da NF'												, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	''																		, ; //X3_ORDEM
	'F1_2_PRNFE'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'2 Nr.Prot.NF'															, ; //X3_TITULO
	'2 Nr.Prot.NF'															, ; //X3_TITSPA
	'2 Nr.Prot.NF'															, ; //X3_TITENG
	'Numero de Protocolo da NF'												, ; //X3_DESCRIC
	'Numero de Protocolo da NF'												, ; //X3_DESCSPA
	'Numero de Protocolo da NF'												, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	''																		, ; //X3_ORDEM
	'F1_2_DVNFE'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	30																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'2 DigVal NFE'															, ; //X3_TITULO
	'2 DigVal NFE'															, ; //X3_TITSPA
	'2 DigVal NFE'															, ; //X3_TITENG
	'DigVal da NFE'															, ; //X3_DESCRIC
	'DigVal da NFE'															, ; //X3_DESCSPA
	'DigVal da NFE'															, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

//
// Atualizando dicionário
//

nPosArq := aScan( aEstrut, { |x| AllTrim( x ) == "X3_ARQUIVO" } )
nPosOrd := aScan( aEstrut, { |x| AllTrim( x ) == "X3_ORDEM"   } )
nPosCpo := aScan( aEstrut, { |x| AllTrim( x ) == "X3_CAMPO"   } )
nPosTam := aScan( aEstrut, { |x| AllTrim( x ) == "X3_TAMANHO" } )
nPosSXG := aScan( aEstrut, { |x| AllTrim( x ) == "X3_GRPSXG"  } )

aSort( aSX3,,, { |x,y| x[nPosArq]+x[nPosOrd]+x[nPosCpo] < y[nPosArq]+y[nPosOrd]+y[nPosCpo] } )

oProcess:SetRegua2( Len( aSX3 ) )

dbSelectArea( "SX3" )
dbSetOrder( 2 )
cAliasAtu := ""

For nI := 1 To Len( aSX3 )

	//
	// Verifica se o campo faz parte de um grupo e ajsuta tamanho
	//
	If !Empty( aSX3[nI][nPosSXG] )
		SXG->( dbSetOrder( 1 ) )
		If SXG->( MSSeek( aSX3[nI][nPosSXG] ) )
			If aSX3[nI][nPosTam] <> SXG->XG_SIZE
				aSX3[nI][nPosTam] := SXG->XG_SIZE
				cTexto += "O tamanho do campo " + aSX3[nI][nPosCpo] + " nao atualizado e foi mantido em ["
				cTexto += AllTrim( Str( SXG->XG_SIZE ) ) + "]" + CRLF
				cTexto += "   por pertencer ao grupo de campos [" + SX3->X3_GRPSXG + "]" + CRLF + CRLF
			EndIf
		EndIf
	EndIf

	SX3->( dbSetOrder( 2 ) )

	If !( aSX3[nI][nPosArq] $ cAlias )
		cAlias += aSX3[nI][nPosArq] + "/"
		aAdd( aArqUpd, aSX3[nI][nPosArq] )
	EndIf

	If !SX3->( dbSeek( PadR( aSX3[nI][nPosCpo], nTamSeek ) ) )

		//
		// Busca ultima ocorrencia do alias
		//
		If ( aSX3[nI][nPosArq] <> cAliasAtu )
			cSeqAtu   := "00"
			cAliasAtu := aSX3[nI][nPosArq]

			dbSetOrder( 1 )
			SX3->( dbSeek( cAliasAtu + "ZZ", .T. ) )
			dbSkip( -1 )

			If ( SX3->X3_ARQUIVO == cAliasAtu )
				cSeqAtu := SX3->X3_ORDEM
			EndIf

			nSeqAtu := Val( RetAsc( cSeqAtu, 3, .F. ) )
		EndIf

		nSeqAtu++
		cSeqAtu := RetAsc( Str( nSeqAtu ), 2, .T. )

		RecLock( "SX3", .T. )
		For nJ := 1 To Len( aSX3[nI] )
			If     nJ == nPosOrd  // Ordem
				FieldPut( FieldPos( aEstrut[nJ] ), cSeqAtu )

			ElseIf FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSX3[nI][nJ] )

			EndIf
		Next nJ

		dbCommit()
		MsUnLock()

		cTexto += "Criado o campo " + aSX3[nI][nPosCpo] + CRLF

	Else

		//
		// Verifica se o campo faz parte de um grupo e ajsuta tamanho
		//
		If !Empty( SX3->X3_GRPSXG ) .AND. SX3->X3_GRPSXG <> aSX3[nI][nPosSXG]
			SXG->( dbSetOrder( 1 ) )
			If SXG->( MSSeek( SX3->X3_GRPSXG ) )
				If aSX3[nI][nPosTam] <> SXG->XG_SIZE
					aSX3[nI][nPosTam] := SXG->XG_SIZE
					cTexto +=  "O tamanho do campo " + aSX3[nI][nPosCpo] + " nao atualizado e foi mantido em ["
					cTexto += AllTrim( Str( SXG->XG_SIZE ) ) + "]"+ CRLF
					cTexto +=  "   por pertencer ao grupo de campos [" + SX3->X3_GRPSXG + "]" + CRLF + CRLF
				EndIf
			EndIf
		EndIf

		//
		// Verifica todos os campos
		//
		For nJ := 1 To Len( aSX3[nI] )

			//
			// Se o campo estiver diferente da estrutura
			//
			If aEstrut[nJ] == SX3->( FieldName( nJ ) ) .AND. ;
				PadR( StrTran( AllToChar( SX3->( FieldGet( nJ ) ) ), " ", "" ), 250 ) <> ;
				PadR( StrTran( AllToChar( aSX3[nI][nJ] )           , " ", "" ), 250 ) .AND. ;
				AllTrim( SX3->( FieldName( nJ ) ) ) <> "X3_ORDEM"

				cMsg := "O campo " + aSX3[nI][nPosCpo] + " está com o " + SX3->( FieldName( nJ ) ) + ;
				" com o conteúdo" + CRLF + ;
				"[" + RTrim( AllToChar( SX3->( FieldGet( nJ ) ) ) ) + "]" + CRLF + ;
				"que será substituido pelo NOVO conteúdo" + CRLF + ;
				"[" + RTrim( AllToChar( aSX3[nI][nJ] ) ) + "]" + CRLF + ;
				"Deseja substituir ? "

				If      lTodosSim
					nOpcA := 1
				ElseIf  lTodosNao
					nOpcA := 2
				Else
					nOpcA := Aviso( "ATUALIZAÇÃO DE DICIONÁRIOS E TABELAS", cMsg, { "Sim", "Não", "Sim p/Todos", "Não p/Todos" }, 3, "Diferença de conteúdo - SX3" )
					lTodosSim := ( nOpcA == 3 )
					lTodosNao := ( nOpcA == 4 )

					If lTodosSim
						nOpcA := 1
						lTodosSim := MsgNoYes( "Foi selecionada a opção de REALIZAR TODAS alterações no SX3 e NÃO MOSTRAR mais a tela de aviso." + CRLF + "Confirma a ação [Sim p/Todos] ?" )
					EndIf

					If lTodosNao
						nOpcA := 2
						lTodosNao := MsgNoYes( "Foi selecionada a opção de NÃO REALIZAR nenhuma alteração no SX3 que esteja diferente da base e NÃO MOSTRAR mais a tela de aviso." + CRLF + "Confirma esta ação [Não p/Todos]?" )
					EndIf

				EndIf

				If nOpcA == 1
					cTexto += "Alterado o campo " + aSX3[nI][nPosCpo] + CRLF
					cTexto += "   " + PadR( SX3->( FieldName( nJ ) ), 10 ) + " de [" + AllToChar( SX3->( FieldGet( nJ ) ) ) + "]" + CRLF
					cTexto += "            para [" + AllToChar( aSX3[nI][nJ] )          + "]" + CRLF + CRLF

					RecLock( "SX3", .F. )
					FieldPut( FieldPos( aEstrut[nJ] ), aSX3[nI][nJ] )
					dbCommit()
					MsUnLock()
				EndIf

			EndIf

		Next

	EndIf

	oProcess:IncRegua2( "Atualizando Campos de Tabelas (SX3)..." )

Next nI

cTexto += CRLF + "Final da Atualizacao" + " SX3" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF

Return NIL

//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX6
Função de processamento da gravação do SX6 - Parâmetros

@author TOTVS Protheus
@since  15/07/2015
@obs    Gerado por EXPORDIC - V.4.24.11.8 EFS / Upd. V.4.19.13 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX6()
Local aEstrut   := {}
Local aSX6      := {}
Local cAlias    := ""
Local cMsg      := ""
Local lContinua := .T.
Local lReclock  := .T.
Local lTodosNao := .F.
Local lTodosSim := .F.
Local nI        := 0
Local nJ        := 0
Local nOpcA     := 0
Local nTamFil   := Len( SX6->X6_FIL )
Local nTamVar   := Len( SX6->X6_VAR )

AutoGrLog( "Ínicio da Atualização" + " SX6" + CRLF )

aEstrut := { "X6_FIL"    , "X6_VAR"    , "X6_TIPO"   , "X6_DESCRIC", "X6_DSCSPA" , "X6_DSCENG" , "X6_DESC1"  , ;
             "X6_DSCSPA1", "X6_DSCENG1", "X6_DESC2"  , "X6_DSCSPA2", "X6_DSCENG2", "X6_CONTEUD", "X6_CONTSPA", ;
             "X6_CONTENG", "X6_PROPRI" , "X6_VALID"  , "X6_INIT"   , "X6_DEFPOR" , "X6_DEFSPA" , "X6_DEFENG" , ;
             "X6_PYME"   }

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_CDNWCLI'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Permite incluir cliente durante importacao do XML.'					, ; //X6_DESCRIC
	'Permite incluir cliente durante importacao do XML.'					, ; //X6_DSCSPA
	'Permite incluir cliente durante importacao do XML.'					, ; //X6_DSCENG
	'1=Sim e 2=Nao'													, ; //X6_DESC1
	'1=Sim e 2=Nao'													, ; //X6_DSCSPA1
	'1=Sim e 2=Nao'													, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'2'																		, ; //X6_CONTEUD
	'2'																		, ; //X6_CONTSPA
	'2'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	'2'																		, ; //X6_DEFPOR
	'2'																		, ; //X6_DEFSPA
	'2'																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_CDNWFOR'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Permite incluir fornecedor durante importacao do'						, ; //X6_DESCRIC
	'Permite incluir fornecedor durante importacao do'						, ; //X6_DSCSPA
	'Permite incluir fornecedor durante importacao do'						, ; //X6_DSCENG
	'XML. 1=Sim e 2=Nao'													, ; //X6_DESC1
	'XML. 1=Sim e 2=Nao'													, ; //X6_DSCSPA1
	'XML. 1=Sim e 2=Nao'													, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'2'																		, ; //X6_CONTEUD
	'2'																		, ; //X6_CONTSPA
	'2'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	'2'																		, ; //X6_DEFPOR
	'2'																		, ; //X6_DEFSPA
	'2'																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_CFOPBEN'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'CFOPs para notas de Beneficiamento (XML).'								, ; //X6_DESCRIC
	'CFOPs para notas de Beneficiamento (XML).'								, ; //X6_DSCSPA
	'CFOPs para notas de Beneficiamento (XML).'								, ; //X6_DSCENG
	'Separar usando barras (/)'												, ; //X6_DESC1
	'Separar usando barras (/)'												, ; //X6_DSCSPA1
	'Separar usando barras (/)'												, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_CFOPDEV'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'CFOPs para notas de Devolucao (XML). Separar usando'					, ; //X6_DESCRIC
	'CFOPs para notas de Devolucao (XML). Separar usando'					, ; //X6_DSCSPA
	'CFOPs para notas de Devolucao (XML). Separar usando'					, ; //X6_DSCENG
	'barras (/)'															, ; //X6_DESC1
	'barras (/)'															, ; //X6_DSCSPA1
	'barras (/)'															, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_CFOPDV2'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'CFOPs para notas de Devolucao (XML). Separar usando'					, ; //X6_DESCRIC
	'CFOPs para notas de Devolucao (XML). Separar usando'					, ; //X6_DSCSPA
	'CFOPs para notas de Devolucao (XML). Separar usando'					, ; //X6_DSCENG
	'barras (/)'															, ; //X6_DESC1
	'barras (/)'															, ; //X6_DSCSPA1
	'barras (/)'															, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'5412/5413/5503/5553/5555/5556/5660/5661/5662/5918/5919/6201/6202/6208/6209/6210/6410/6411/6412/6413/6503/6553/6555/6556/6660/6661/6662/6918/6919/7201/7202/7210/7211/7553/7556', ; //X6_CONTEUD
	'5412/5413/5503/5553/5555/5556/5660/5661/5662/5918/5919/6201/6202/6208/6209/6210/6410/6411/6412/6413/6503/6553/6555/6556/6660/6661/6662/6918/6919/7201/7202/7210/7211/7553/7556', ; //X6_CONTSPA
	'5412/5413/5503/5553/5555/5556/5660/5661/5662/5918/5919/6201/6202/6208/6209/6210/6410/6411/6412/6413/6503/6553/6555/6556/6660/6661/6662/6918/6919/7201/7202/7210/7211/7553/7556', ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	'5412/5413/5503/5553/5555/5556/5660/5661/5662/5918/5919/6201/6202/6208/6209/6210/6410/6411/6412/6413/6503/6553/6555/6556/6660/6661/6662/6918/6919/7201/7202/7210/7211/7553/7556', ; //X6_DEFPOR
	'5412/5413/5503/5553/5555/5556/5660/5661/5662/5918/5919/6201/6202/6208/6209/6210/6410/6411/6412/6413/6503/6553/6555/6556/6660/6661/6662/6918/6919/7201/7202/7210/7211/7553/7556', ; //X6_DEFSPA
	'5412/5413/5503/5553/5555/5556/5660/5661/5662/5918/5919/6201/6202/6208/6209/6210/6410/6411/6412/6413/6503/6553/6555/6556/6660/6661/6662/6918/6919/7201/7202/7210/7211/7553/7556', ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_CFOPDV3'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'CFOPs para notas de Devolucao (XML). Separar usando'					, ; //X6_DESCRIC
	'CFOPs para notas de Devolucao (XML). Separar usando'					, ; //X6_DSCSPA
	'CFOPs para notas de Devolucao (XML). Separar usando'					, ; //X6_DSCENG
	'barras (/)'															, ; //X6_DESC1
	'barras (/)'															, ; //X6_DSCSPA1
	'barras (/)'															, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1201/1202/1203/1204/1208/1209/1410/1411/1503/1504/1505/1506/1553/1660/1661/1662/1903/1918/1919/2201/2202/2203/2204/2208/2209/2410/2411/2503/2504/2505/2506/2553/2660/2661/2662/2903/2918/2919/3201/3202/3211/3503/3553/5201/5202/5208/5209/5210/5410/5411', ; //X6_CONTEUD
	'1201/1202/1203/1204/1208/1209/1410/1411/1503/1504/1505/1506/1553/1660/1661/1662/1903/1918/1919/2201/2202/2203/2204/2208/2209/2410/2411/2503/2504/2505/2506/2553/2660/2661/2662/2903/2918/2919/3201/3202/3211/3503/3553/5201/5202/5208/5209/5210/5410/5411', ; //X6_CONTSPA
	'1201/1202/1203/1204/1208/1209/1410/1411/1503/1504/1505/1506/1553/1660/1661/1662/1903/1918/1919/2201/2202/2203/2204/2208/2209/2410/2411/2503/2504/2505/2506/2553/2660/2661/2662/2903/2918/2919/3201/3202/3211/3503/3553/5201/5202/5208/5209/5210/5410/5411', ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	'1201/1202/1203/1204/1208/1209/1410/1411/1503/1504/1505/1506/1553/1660/1661/1662/1903/1918/1919/2201/2202/2203/2204/2208/2209/2410/2411/2503/2504/2505/2506/2553/2660/2661/2662/2903/2918/2919/3201/3202/3211/3503/3553/5201/5202/5208/5209/5210/5410/5411', ; //X6_DEFPOR
	'1201/1202/1203/1204/1208/1209/1410/1411/1503/1504/1505/1506/1553/1660/1661/1662/1903/1918/1919/2201/2202/2203/2204/2208/2209/2410/2411/2503/2504/2505/2506/2553/2660/2661/2662/2903/2918/2919/3201/3202/3211/3503/3553/5201/5202/5208/5209/5210/5410/5411', ; //X6_DEFSPA
	'1201/1202/1203/1204/1208/1209/1410/1411/1503/1504/1505/1506/1553/1660/1661/1662/1903/1918/1919/2201/2202/2203/2204/2208/2209/2410/2411/2503/2504/2505/2506/2553/2660/2661/2662/2903/2918/2919/3201/3202/3211/3503/3553/5201/5202/5208/5209/5210/5410/5411', ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_CONPGNF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Condicao de pagamento do fornecedor incluso durant'					, ; //X6_DESCRIC
	'Condicao de pagamento do fornecedor incluso durant'					, ; //X6_DSCSPA
	'Condicao de pagamento do fornecedor incluso durant'					, ; //X6_DSCENG
	'e importacao de arquivo XML.'											, ; //X6_DESC1
	'e importacao de arquivo XML.'											, ; //X6_DSCSPA1
	'e importacao de arquivo XML.'											, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_HBCONNF'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita consulta da validade da chave da NFE?'						, ; //X6_DESCRIC
	'Habilita consulta da validade da chave da NFE?'						, ; //X6_DSCSPA
	'Habilita consulta da validade da chave da NFE?'						, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	'.T.'																	, ; //X6_DEFPOR
	'.T.'																	, ; //X6_DEFSPA
	'.T.'																	, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_INCPROD'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Determina se sera feita inclusao de produtos ao im'					, ; //X6_DESCRIC
	'Determina se sera feita inclusao de produtos ao im'					, ; //X6_DSCSPA
	'Determina se sera feita inclusao de produtos ao im'					, ; //X6_DSCENG
	'portar pre-nota de entrada via e-XML'									, ; //X6_DESC1
	'portar pre-nota de entrada via e-XML'									, ; //X6_DSCSPA1
	'portar pre-nota de entrada via e-XML'									, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	'.F.'																	, ; //X6_DEFPOR
	'.F.'																	, ; //X6_DEFSPA
	'.F.'																	, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_MAILADM'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'E-MAIL do Administrador(Auditoria) de XML'								, ; //X6_DESCRIC
	'E-MAIL do Administrador(Auditoria) de XML'								, ; //X6_DSCSPA
	'E-MAIL do Administrador(Auditoria) de XML'								, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_POP3POR'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Porta do Servidor POP3'												, ; //X6_DESCRIC
	'Porta do Servidor POP3'												, ; //X6_DSCSPA
	'Porta do Servidor POP3'												, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'110'																	, ; //X6_CONTEUD
	'110'																	, ; //X6_CONTSPA
	'110'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	'110'																	, ; //X6_DEFPOR
	'110'																	, ; //X6_DEFSPA
	'110'																	, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_POP3SRV'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Endereco do Servidor POP3'												, ; //X6_DESCRIC
	'Endereco do Servidor POP3'												, ; //X6_DSCSPA
	'Endereco do Servidor POP3'												, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_PSWPOP3'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Senha do Servidor POP3'												, ; //X6_DESCRIC
	'Senha do Servidor POP3'												, ; //X6_DSCSPA
	'Senha do Servidor POP3'												, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_ULTPROC'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Data e hora do ultimo processamento da conferencia'					, ; //X6_DESCRIC
	'Data e hora do ultimo processamento da conferencia'					, ; //X6_DSCSPA
	'Data e hora do ultimo processamento da conferencia'					, ; //X6_DSCENG
	' de pre-notas pendentes.'												, ; //X6_DESC1
	' de pre-notas pendentes.'												, ; //X6_DSCSPA1
	' de pre-notas pendentes.'												, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'2000010101:00'															, ; //X6_CONTEUD
	'2000010101:00'															, ; //X6_CONTSPA
	'2000010101:00'															, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	'2000010101:00'															, ; //X6_DEFPOR
	'2000010101:00'															, ; //X6_DEFSPA
	'2000010101:00'															, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_USAMAIL'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Utiliza SMTP ao importar arquivo XML. 1=Sim, 2=Nao'					, ; //X6_DESCRIC
	'Utiliza SMTP ao importar arquivo XML. 1=Sim, 2=Nao'					, ; //X6_DSCSPA
	'Utiliza SMTP ao importar arquivo XML. 1=Sim, 2=Nao'					, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'2'																		, ; //X6_CONTEUD
	'2'																		, ; //X6_CONTSPA
	'2'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	'2'																		, ; //X6_DEFPOR
	'2'																		, ; //X6_DEFSPA
	'2'																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_USAPOP3'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Utiliza POP3 na importacao de XML. 1=Sim, 2=Nao'						, ; //X6_DESCRIC
	'Utiliza POP3 na importacao de XML. 1=Sim, 2=Nao'						, ; //X6_DSCSPA
	'Utiliza POP3 na importacao de XML. 1=Sim, 2=Nao'						, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'2'																		, ; //X6_CONTEUD
	'2'																		, ; //X6_CONTSPA
	'2'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	'2'																		, ; //X6_DEFPOR
	'2'																		, ; //X6_DEFSPA
	'2'																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_USUPOP3'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Usuario do Servidor POP3'												, ; //X6_DESCRIC
	'Usuario do Servidor POP3'												, ; //X6_DSCSPA
	'Usuario do Servidor POP3'												, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_VLDNCM' 															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Valida o NCM da NFE X cadastro de produtos? '							, ; //X6_DESCRIC
	'Valida o NCM da NFE X cadastro de produtos? '							, ; //X6_DSCSPA
	'Valida o NCM da NFE X cadastro de produtos? '							, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	'.F.'																	, ; //X6_DEFPOR
	'.F.'																	, ; //X6_DEFSPA
	'.F.'																	, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSX6 ) )

dbSelectArea( "SX6" )
dbSetOrder( 1 )

For nI := 1 To Len( aSX6 )
	lContinua := .F.
	lReclock  := .F.

	If !SX6->( dbSeek( PadR( aSX6[nI][1], nTamFil ) + PadR( aSX6[nI][2], nTamVar ) ) )
		lContinua := .T.
		lReclock  := .T.
		AutoGrLog( "Foi incluído o parâmetro " + aSX6[nI][1] + aSX6[nI][2] + " Conteúdo [" + AllTrim( aSX6[nI][13] ) + "]" )
	Else
		lContinua := .T.
		lReclock  := .F.
		If !StrTran( SX6->X6_CONTEUD, " ", "" ) == StrTran( aSX6[nI][13], " ", "" )

			cMsg := "O parâmetro " + aSX6[nI][2] + " está com o conteúdo" + CRLF + ;
			"[" + RTrim( StrTran( SX6->X6_CONTEUD, " ", "" ) ) + "]" + CRLF + ;
			", que é será substituido pelo NOVO conteúdo " + CRLF + ;
			"[" + RTrim( StrTran( aSX6[nI][13]   , " ", "" ) ) + "]" + CRLF + ;
			"Deseja substituir ? "

			If      lTodosSim
				nOpcA := 1
			ElseIf  lTodosNao
				nOpcA := 2
			Else
				nOpcA := Aviso( "ATUALIZAÇÃO DE DICIONÁRIOS E TABELAS", cMsg, { "Sim", "Não", "Sim p/Todos", "Não p/Todos" }, 3, "Diferença de conteúdo - SX6" )
				lTodosSim := ( nOpcA == 3 )
				lTodosNao := ( nOpcA == 4 )

				If lTodosSim
					nOpcA := 1
					lTodosSim := MsgNoYes( "Foi selecionada a opção de REALIZAR TODAS alterações no SX6 e NÃO MOSTRAR mais a tela de aviso." + CRLF + "Confirma a ação [Sim p/Todos] ?" )
				EndIf

				If lTodosNao
					nOpcA := 2
					lTodosNao := MsgNoYes( "Foi selecionada a opção de NÃO REALIZAR nenhuma alteração no SX6 que esteja diferente da base e NÃO MOSTRAR mais a tela de aviso." + CRLF + "Confirma esta ação [Não p/Todos]?" )
				EndIf

			EndIf

			lContinua := ( nOpcA == 1 )

			If lContinua
				AutoGrLog( "Foi alterado o parâmetro " + aSX6[nI][1] + aSX6[nI][2] + " de [" + ;
				AllTrim( SX6->X6_CONTEUD ) + "]" + " para [" + AllTrim( aSX6[nI][13] ) + "]" )
			EndIf

		Else
			lContinua := .F.
		EndIf
	EndIf

	If lContinua
		If !( aSX6[nI][1] $ cAlias )
			cAlias += aSX6[nI][1] + "/"
		EndIf

		RecLock( "SX6", lReclock )
		For nJ := 1 To Len( aSX6[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSX6[nI][nJ] )
			EndIf
		Next nJ
		dbCommit()
		MsUnLock()
	EndIf

	oProcess:IncRegua2( "Atualizando Arquivos (SX6)..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SX6" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºRotina    ³ESCEMPRESAºAutor  ³ Ernani Forastieri  º Data ³  27/09/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao Generica para escolha de Empresa, montado pelo SM0_ º±±
±±º          ³ Retorna vetor contendo as selecoes feitas.                 º±±
±±º          ³ Se nao For marcada nenhuma o vetor volta vazio.            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function EscEmpresa()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametro  nTipo                           ³
//³ 1  - Monta com Todas Empresas/Filiais      ³
//³ 2  - Monta so com Empresas                 ³
//³ 3  - Monta so com Filiais de uma Empresa   ³
//³                                            ³
//³ Parametro  aMarcadas                       ³
//³ Vetor com Empresas/Filiais pre marcadas    ³
//³                                            ³
//³ Parametro  cEmpSel                         ³
//³ Empresa que sera usada para montar selecao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local   aSalvAmb := GetArea()
Local   aSalvSM0 := {}
Local   aRet     := {}
Local   aVetor   := {}
Local   oDlg     := NIL
Local   oChkMar  := NIL
Local   oLbx     := NIL
Local   oMascEmp := NIL
Local   oMascFil := NIL
Local   oButMarc := NIL
Local   oButDMar := NIL
Local   oButInv  := NIL
Local   oSay     := NIL
Local   oOk      := LoadBitmap( GetResources(), "LBOK" )
Local   oNo      := LoadBitmap( GetResources(), "LBNO" )
Local   lChk     := .F.
Local   lOk      := .F.
Local   lTeveMarc:= .F.
Local   cVar     := ""
Local   cNomEmp  := ""
Local   cMascEmp := "??"
Local   cMascFil := "??"

Local   aMarcadas  := {}


If !MyOpenSm0(.F.)
	Return aRet
EndIf


dbSelectArea( "SM0" )
aSalvSM0 := SM0->( GetArea() )
dbSetOrder( 1 )
dbGoTop()

While !SM0->( EOF() )

	If aScan( aVetor, {|x| x[2] == SM0->M0_CODIGO} ) == 0
		aAdd(  aVetor, { aScan( aMarcadas, {|x| x[1] == SM0->M0_CODIGO .and. x[2] == SM0->M0_CODFIL} ) > 0, SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_NOME, SM0->M0_FILIAL } )
	EndIf

	dbSkip()
End

RestArea( aSalvSM0 )

Define MSDialog  oDlg Title "" From 0, 0 To 270, 396 Pixel

oDlg:cToolTip := "Tela para Múltiplas Seleções de Empresas/Filiais"

oDlg:cTitle   := "Selecione a(s) Empresa(s) para Atualização"

@ 10, 10 Listbox  oLbx Var  cVar Fields Header " ", " ", "Empresa" Size 178, 095 Of oDlg Pixel
oLbx:SetArray(  aVetor )
oLbx:bLine := {|| {IIf( aVetor[oLbx:nAt, 1], oOk, oNo ), ;
aVetor[oLbx:nAt, 2], ;
aVetor[oLbx:nAt, 4]}}
oLbx:BlDblClick := { || aVetor[oLbx:nAt, 1] := !aVetor[oLbx:nAt, 1], VerTodos( aVetor, @lChk, oChkMar ), oChkMar:Refresh(), oLbx:Refresh()}
oLbx:cToolTip   :=  oDlg:cTitle
oLbx:lHScroll   := .F. // NoScroll

@ 112, 10 CheckBox oChkMar Var  lChk Prompt "Todos"   Message  Size 40, 007 Pixel Of oDlg;
on Click MarcaTodos( lChk, @aVetor, oLbx )

@ 123, 10 Button oButInv Prompt "&Inverter"  Size 32, 12 Pixel Action ( InvSelecao( @aVetor, oLbx, @lChk, oChkMar ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Inverter Seleção" Of oDlg

// Marca/Desmarca por mascara
@ 113, 51 Say  oSay Prompt "Empresa" Size  40, 08 Of oDlg Pixel
@ 112, 80 MSGet  oMascEmp Var  cMascEmp Size  05, 05 Pixel Picture "@!"  Valid (  cMascEmp := StrTran( cMascEmp, " ", "?" ), cMascFil := StrTran( cMascFil, " ", "?" ), oMascEmp:Refresh(), .T. ) ;
Message "Máscara Empresa ( ?? )"  Of oDlg
@ 123, 50 Button oButMarc Prompt "&Marcar"    Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .T. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Marcar usando máscara ( ?? )"    Of oDlg
@ 123, 80 Button oButDMar Prompt "&Desmarcar" Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .F. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Desmarcar usando máscara ( ?? )" Of oDlg

Define SButton From 111, 125 Type 1 Action ( RetSelecao( @aRet, aVetor ), oDlg:End() ) OnStop "Confirma a Seleção"  Enable Of oDlg
Define SButton From 111, 158 Type 2 Action ( IIf( lTeveMarc, aRet :=  aMarcadas, .T. ), oDlg:End() ) OnStop "Abandona a Seleção" Enable Of oDlg
Activate MSDialog  oDlg Center

RestArea( aSalvAmb )
dbSelectArea( "SM0" )
dbCloseArea()

Return  aRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºRotina    ³MARCATODOSºAutor  ³ Ernani Forastieri  º Data ³  27/09/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao Auxiliar para marcar/desmarcar todos os itens do    º±±
±±º          ³ ListBox ativo                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MarcaTodos( lMarca, aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := lMarca
Next nI

oLbx:Refresh()

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºRotina    ³INVSELECAOºAutor  ³ Ernani Forastieri  º Data ³  27/09/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao Auxiliar para inverter selecao do ListBox Ativo     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function InvSelecao( aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := !aVetor[nI][1]
Next nI

oLbx:Refresh()

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºRotina    ³RETSELECAOºAutor  ³ Ernani Forastieri  º Data ³  27/09/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao Auxiliar que monta o retorno com as selecoes        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RetSelecao( aRet, aVetor )
Local  nI    := 0

aRet := {}
For nI := 1 To Len( aVetor )
	If aVetor[nI][1]
		aAdd( aRet, { aVetor[nI][2] , aVetor[nI][3], aVetor[nI][2] +  aVetor[nI][3] } )
	EndIf
Next nI

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºRotina    ³ MARCAMAS ºAutor  ³ Ernani Forastieri  º Data ³  20/11/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao para marcar/desmarcar usando mascaras               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MarcaMas( oLbx, aVetor, cMascEmp, lMarDes )
Local cPos1 := SubStr( cMascEmp, 1, 1 )
Local cPos2 := SubStr( cMascEmp, 2, 1 )
Local nPos  := oLbx:nAt
Local nZ    := 0

For nZ := 1 To Len( aVetor )
	If cPos1 == "?" .or. SubStr( aVetor[nZ][2], 1, 1 ) == cPos1
		If cPos2 == "?" .or. SubStr( aVetor[nZ][2], 2, 1 ) == cPos2
			aVetor[nZ][1] :=  lMarDes
		EndIf
	EndIf
Next

oLbx:nAt := nPos
oLbx:Refresh()

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSAtuSXB ³ Autor ³Fabio Rogerio Pereira  ³ Data ³19/02/02  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de processamento da gravacao do SXB                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Implantacao PMS                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FSAtuSXB(cTexto)
Local aSXB   := {}
Local aEstrut:= {}
Local i      := 0
Local j      := 0

aEstrut:= {"XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI","XB_DESCSPA","XB_DESCENG","XB_CONTEM","XB_WCONTEM"}

AAdd(aSXB,{"XMLDIR","1","01","RE","Selecione o Diretorio","Selecione o Diretorio","Selecione o Diretorio","SX5",""})
AAdd(aSXB,{"XMLDIR","2","01","01","","","","U_XMLPath()",""})
AAdd(aSXB,{"XMLDIR","5","01","  ","","","","U_XMLDir()",""})

ProcRegua(Len(aSXB))

cTexto  += "Inicio da Atualizacao" + " SXB" + CRLF + CRLF

dbSelectArea("SXB")
dbSetOrder(1)
For i:= 1 To Len(aSXB)
	IncProc()
	If !Empty(aSXB[i][1])
		If !dbSeek(aSXB[i,1]+aSXB[i,2]+aSXB[i,3]+aSXB[i,4])
			RecLock("SXB",.T.)

			For j:=1 To Len(aSXB[i])
				If !Empty(FieldName(FieldPos(aEstrut[j])))
					FieldPut(FieldPos(aEstrut[j]),aSXB[i,j])
				EndIf
			Next j

			cTexto  += "Criado Consulta Padrao " + aSXB[i][1] + " - Sequencia: "+aSXB[i][3] + CRLF

			dbCommit()
			MsUnLock()
		EndIf
	EndIf
Next i

cTexto  += "Fim da Atualizacao" + " SXB" + CRLF + CRLF

Return(.T.)

/*/{Protheus.doc} GetHTMLMessage
Retorna o lay-out em HTML da mensagem de e-mail que será enviada.
@author Leandro Faggyas Dourado
@since 03/07/2015
@version 1.0
@param cLayOut, character, (Descrição do parâmetro)
@return cHtml, Mensagem de e-mail em HTML
/*/
Static Function GetHTMLMessage( cLayOut, aDados, aErros )
Local cHtml  := ""
Local nCount := 0

DEFAULT cLayOut    := ""
DEFAULT aDados     := {}
DEFAULT aErros     := {}

If !Empty(cLayout)
	cLayout := Upper(cLayout)
EndIf

If cLayOut == "EXML010"
	cHtml := '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'+CRLF
	cHtml += '<html xmlns="http://www.w3.org/1999/xhtml">'+CRLF
	cHtml += '	<style type="text/css">'+CRLF
	cHtml += '		.button { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 10px; color: #000000; border: 1px ridge #CC6600; font-weight: bold; margin: 1px; padding: 1px; background-color: #ECEEEB; }'+CRLF
	cHtml += '		.text   { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 11px; color: 660000; text-decoration: none; font-style: normal; }'+CRLF
	cHtml += '		.title  { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; color: 660000; text-decoration:none; font-weight: bold; }'+CRLF
	cHtml += '		.table  { border-bottom:1px solid #999; border-right:1px solid #999; border-left:1px solid #999; border-top:1px solid #999; margin:1em auto; }'+CRLF
	cHtml += '		.form0  { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; color:#FFF; text-decoration: none; font-weight: bold; background-color:#CC0000}'+CRLF
	cHtml += '		.form1  { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 10px; color: #000000; text-decoration: none; font-weight: bold; background-color:#ECF0EE;}	'+CRLF
	cHtml += '		.form2  { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 11px; color: #333333; text-decoration: none; background-color:#F7F9F8;}'+CRLF
	cHtml += '		.form3  { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 9px; color: #333333; text-decoration: none; background-color:#F7F9F8; font-weight:bold}'+CRLF
	cHtml += '		.links  { font-family: Arial, Helvetica, sans-serif; font-size: 11px; color: 660000; text-decoration:underline; font-style: normal;}'+CRLF
	cHtml += '	</style>'+CRLF
	cHtml += ''+CRLF
	cHtml += '	<head>'+CRLF
	cHtml += '		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />'+CRLF
	cHtml += '		<title>Notificação Divergência</title>'+CRLF
	cHtml += '	</head>'+CRLF
	cHtml += '	<body>'+CRLF
	cHtml += '		<table width="90%" class="table">'+CRLF
	cHtml += '			<tr>'+CRLF
	cHtml += '				<td width="85%" align="center" bgcolor="#CC0000" class="form0">NOTIFICA&Ccedil;&Atilde;O DE DIVERG&Ecirc;NCIA FISCAL NOTA FISCAL vs ARQUIVO XML</td>'+CRLF
	cHtml += '			</tr>'+CRLF
	cHtml += '		</table> '+CRLF
	cHtml += '		<table width="90%" class="table">'+CRLF
	cHtml += '  <tr>'+CRLF
	cHtml += '				<td width="100%">'+CRLF
	cHtml += '					<table width="100%">'+CRLF
	cHtml += '						<tr>'+CRLF
	cHtml += '							<td colspan="2" class="form0">DADOS DO ARQUIVO</td>                    '+CRLF
	cHtml += '						</tr>'+CRLF
	cHtml += '						<tr>'+CRLF
	cHtml += '						  <td class="form1">Nome Arquivo XML</td>'+CRLF
	cHtml += '						  <td class="form2"><strong>'+aDados[aScan(aDados,{|x| Upper(x[1]) == Upper('cNomeXML')  }),2]+'</strong></td>'+CRLF
	cHtml += '					  </tr>'+CRLF
	cHtml += '						<tr>'+CRLF
	cHtml += '						  <td class="form1">Raz&atilde;o Emissor</td>'+CRLF
	cHtml += '						  <td class="form2"><strong>'+aDados[aScan(aDados,{|x| Upper(x[1]) == Upper('cNomeFor')  }),2]+'</strong></td>'+CRLF
	cHtml += '					  </tr>'+CRLF
	cHtml += '						<tr>'+CRLF
	cHtml += '						  <td class="form1">CNPJ Emissor</td>'+CRLF
	cHtml += '						  <td class="form2"><strong>'+aDados[aScan(aDados,{|x| Upper(x[1]) == Upper('cCNPJFor')  }),2]+'</strong></td>'+CRLF
	cHtml += '					  </tr>'+CRLF
	cHtml += '						<tr>'+CRLF
	cHtml += '						  <td class="form1">N&uacute;mero NF-e</td>'+CRLF
	cHtml += '						  <td class="form2"><strong>'+aDados[aScan(aDados,{|x| Upper(x[1]) == Upper('cDoc')      }),2]+'</strong></td>'+CRLF
	cHtml += '					  </tr>'+CRLF
	cHtml += '						<tr>'+CRLF
	cHtml += '						  <td class="form1">S&eacute;rie NF-e</td>'+CRLF
	cHtml += '						  <td class="form2"><strong>'+aDados[aScan(aDados,{|x| Upper(x[1]) == Upper('cSerie')    }),2]+'</strong></td>'+CRLF
	cHtml += '					  </tr>'+CRLF
	cHtml += '						<tr>'+CRLF
	cHtml += '						  <td class="form1">Data Emiss&atilde;o NF-e</td>'+CRLF
	cHtml += '						  <td class="form2"><strong>'+aDados[aScan(aDados,{|x| Upper(x[1]) == Upper('dDtEmissao')}),2]+'</strong></td>'+CRLF
	cHtml += '					  </tr>'+CRLF
	cHtml += '						<tr>'+CRLF
	cHtml += '						  <td class="form1">Raz&atilde;o Destinat&aacute;rio</td>'+CRLF
	cHtml += '						  <td class="form2"><strong>'+aDados[aScan(aDados,{|x| Upper(x[1]) == Upper('cNomeDest') }),2]+'</strong></td>'+CRLF
	cHtml += '					  </tr>'+CRLF
	cHtml += '						<tr>'+CRLF
	cHtml += '						  <td class="form1">CNPJ Destinat&aacute;rio</td>'+CRLF
	cHtml += '						  <td class="form2"><strong>'+aDados[aScan(aDados,{|x| Upper(x[1]) == Upper('cCNPJDest') }),2]+'</strong></td>'+CRLF
	cHtml += '					  </tr>'+CRLF
	cHtml += '						<tr>'+CRLF
	cHtml += '							<td width="22%" class="form1">Loja</td>'+CRLF
	cHtml += '							<td width="78%" class="form2"><strong>'+aDados[aScan(aDados,{|x| Upper(x[1]) == Upper('cLoja') }),2]+'</strong></td>'+CRLF
	cHtml += '						</tr>'+CRLF
	cHtml += '					</table>'+CRLF
	cHtml += '</td>'+CRLF
	cHtml += '			</tr>'+CRLF
	cHtml += '			<tr>'+CRLF
	cHtml += '				<td width="100%" height="74">'+CRLF
	cHtml += '					<table width="100%">'+CRLF
	cHtml += '						<tr>'+CRLF
	cHtml += '							<td colspan="4" class="form0">INCONSIST&Ecirc;NCIAS</td>'+CRLF
	cHtml += '						</tr>'+CRLF
	cHtml += '						<tr>'+CRLF
	cHtml += '							<td width="9%" class="form1" align="Left">It.</td>'+CRLF
	cHtml += '							<td width="13%" class="form1" align="Left">C&oacute;digo Produto</td>'+CRLF
	cHtml += '							<td width="24%" class="form1" align="Left">Descri&ccedil;&atilde;o</td>'+CRLF
	cHtml += '							<td width="54%" class="form1" align="Left">Motivo</td>'+CRLF
	cHtml += '						</tr>'+CRLF
	For nCount := 1 To Len(aErros)
    	cHtml += '						<tr>'+CRLF
    	cHtml += '							<td width="9%"  class="form2" align="Left">'+aErros[nCount,aScan(aErros[nCount],{|x| Upper(x[1]) == Upper('ERRO.cItem'  ) }),2]+'</td>'+CRLF
    	cHtml += '							<td width="13%" class="form2" align="Left">'+aErros[nCount,aScan(aErros[nCount],{|x| Upper(x[1]) == Upper('ERRO.cCodPro') }),2]+'</td>'+CRLF
    	cHtml += '							<td width="24%" class="form2" align="Left">'+aErros[nCount,aScan(aErros[nCount],{|x| Upper(x[1]) == Upper('ERRO.cDesPro') }),2]+'</td>'+CRLF
    	cHtml += '							<td width="54%" class="form2" align="Left">'+aErros[nCount,aScan(aErros[nCount],{|x| Upper(x[1]) == Upper('ERRO.cMotivo') }),2]+'</td>'+CRLF
    	cHtml += '						</tr>'+CRLF
    Next nCount
	cHtml += '					</table>'+CRLF
	cHtml += '				</td>'+CRLF
	cHtml += '			</tr>'+CRLF
	cHtml += '        </table>'+CRLF
	cHtml += '	</body>'+CRLF
	cHtml += '</html>	'+CRLF
EndIf

If cLayOut == "EXML020"
	cHtml := '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'+CRLF
	cHtml += '<html xmlns="http://www.w3.org/1999/xhtml">'+CRLF
	cHtml += '	<style type="text/css">'+CRLF
	cHtml += '		.button { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 10px; color: #000000; border: 1px ridge #CC6600; font-weight: bold; margin: 1px; padding: 1px; background-color: #ECEEEB; }'+CRLF
	cHtml += '		.text   { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 11px; color: 660000; text-decoration: none; font-style: normal; }'+CRLF
	cHtml += '		.title  { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; color: 660000; text-decoration:none; font-weight: bold; }'+CRLF
	cHtml += '		.table  { border-bottom:1px solid #999; border-right:1px solid #999; border-left:1px solid #999; border-top:1px solid #999; margin:1em auto; }'+CRLF
	cHtml += '		.form0  { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; color:#FFF; text-decoration: none; font-weight: bold; background-color:#CC0000}'+CRLF
	cHtml += '		.form1  { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 10px; color: #000000; text-decoration: none; font-weight: bold; background-color:#ECF0EE;}	'+CRLF
	cHtml += '		.form2  { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 11px; color: #333333; text-decoration: none; background-color:#F7F9F8;}'+CRLF
	cHtml += '		.form3  { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 9px; color: #333333; text-decoration: none; background-color:#F7F9F8; font-weight:bold}'+CRLF
	cHtml += '		.links  { font-family: Arial, Helvetica, sans-serif; font-size: 11px; color: 660000; text-decoration:underline; font-style: normal;}'+CRLF
	cHtml += '	</style>'+CRLF
	cHtml += ''+CRLF
	cHtml += '	<head>'+CRLF
	cHtml += '		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />'+CRLF
	cHtml += '		<title>Notificação Divergência</title>'+CRLF
	cHtml += '	</head>'+CRLF
	cHtml += '	<body>'+CRLF
	cHtml += '		<table width="90%" class="table">'+CRLF
	cHtml += '			<tr>'+CRLF
	cHtml += '				<td width="85%" align="center" bgcolor="#CC0000" class="form0">NOTIFICA&Ccedil;&Atilde;O DE INCONSIST&Ecirc;NCIA NA IMPORTA&Ccedil;&Atilde;O DO ARQUIVO XML</td>'+CRLF
	cHtml += '			</tr>'+CRLF
	cHtml += '		</table> '+CRLF
	cHtml += '		<table width="90%" class="table">'+CRLF
	cHtml += '  <tr>'+CRLF
	cHtml += '				<td width="100%">'+CRLF
	cHtml += '					<table width="100%">'+CRLF
	cHtml += '						<tr>'+CRLF
	cHtml += '							<td colspan="2" class="form0">DADOS DO ARQUIVO</td>                    '+CRLF
	cHtml += '						</tr>'+CRLF
	cHtml += '						<tr>'+CRLF
	cHtml += '						  <td class="form1">Nome Arquivo XML</td>'+CRLF
	cHtml += '						  <td class="form2"><strong>'+aDados[aScan(aDados,{|x| Upper(x[1]) == Upper('cNomeXML')  }),2]+'</strong></td>'+CRLF
	cHtml += '					  </tr>'+CRLF
	cHtml += '						<tr>'+CRLF
	cHtml += '						  <td class="form1">Raz&atilde;o Emissor</td>'+CRLF
	cHtml += '						  <td class="form2"><strong>'+aDados[aScan(aDados,{|x| Upper(x[1]) == Upper('cNomeFor')  }),2]+'</strong></td>'+CRLF
	cHtml += '					  </tr>'+CRLF
	cHtml += '						<tr>'+CRLF
	cHtml += '						  <td class="form1">CNPJ Emissor</td>'+CRLF
	cHtml += '						  <td class="form2"><strong>'+aDados[aScan(aDados,{|x| Upper(x[1]) == Upper('cCNPJFor')  }),2]+'</strong></td>'+CRLF
	cHtml += '					  </tr>'+CRLF
	cHtml += '						<tr>'+CRLF
	cHtml += '						  <td class="form1">N&uacute;mero NF-e</td>'+CRLF
	cHtml += '						  <td class="form2"><strong>'+aDados[aScan(aDados,{|x| Upper(x[1]) == Upper('cDoc')      }),2]+'</strong></td>'+CRLF
	cHtml += '					  </tr>'+CRLF
	cHtml += '						<tr>'+CRLF
	cHtml += '						  <td class="form1">S&eacute;rie NF-e</td>'+CRLF
	cHtml += '						  <td class="form2"><strong>'+aDados[aScan(aDados,{|x| Upper(x[1]) == Upper('cSerie')    }),2]+'</strong></td>'+CRLF
	cHtml += '					  </tr>'+CRLF
	cHtml += '						<tr>'+CRLF
	cHtml += '						  <td class="form1">Raz&atilde;o Destinat&aacute;rio</td>'+CRLF
	cHtml += '						  <td class="form2"><strong>'+aDados[aScan(aDados,{|x| Upper(x[1]) == Upper('cNomeDest') }),2]+'</strong></td>'+CRLF
	cHtml += '					  </tr>'+CRLF
	cHtml += '						<tr>'+CRLF
	cHtml += '							<td width="22%" class="form1">CNPJ Destinat&aacute;rio</td>'+CRLF
	cHtml += '							<td width="78%" class="form2"><strong>'+aDados[aScan(aDados,{|x| Upper(x[1]) == Upper('cCNPJDest') }),2]+'</strong></td>'+CRLF
	cHtml += '						</tr>'+CRLF
	cHtml += '					</table>'+CRLF
	cHtml += '</td>'+CRLF
	cHtml += '			</tr>'+CRLF
	cHtml += '			<tr>'+CRLF
	cHtml += '				<td width="100%" height="74">'+CRLF
	cHtml += '					<table width="100%">'+CRLF
	cHtml += '						<tr>'+CRLF
	cHtml += '							<td colspan="2" class="form0">INCONSIST&Ecirc;NCIAS</td>'+CRLF
	cHtml += '						</tr>'+CRLF
	cHtml += '						<tr>'+CRLF
	cHtml += '							<td width="5%" class="form1" align="Left">Motivo</td>'+CRLF
	cHtml += '							<td width="10%" class="form1" align="Left">Solu&ccedil;&atilde;o</td>'+CRLF
	cHtml += '						</tr>'+CRLF
	For nCount := 1 To Len(aErros)
    	cHtml += '						<tr>'+CRLF
    	cHtml += '							<td width="5%"  class="form2" align="Left">'+aErros[nCount,aScan(aErros[nCount],{|x| Upper(x[1]) == Upper('ERRO.cMotivo' ) }),2]+'</td>'+CRLF
    	cHtml += '							<td width="10%" class="form2" align="Left">'+aErros[nCount,aScan(aErros[nCount],{|x| Upper(x[1]) == Upper('ERRO.cSolucao') }),2]+'</td>'+CRLF
    	cHtml += '						</tr>'+CRLF
    Next nCount
	cHtml += '					</table>'+CRLF
	cHtml += '				</td>'+CRLF
	cHtml += '			</tr>'+CRLF
	cHtml += '        </table>'+CRLF
	cHtml += '	</body>'+CRLF
	cHtml += '</html>'+CRLF
EndIf

If cLayOut == "EXML030"
	cHtml := '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'+CRLF
	cHtml += '<html xmlns="http://www.w3.org/1999/xhtml">'+CRLF
	cHtml += '	<style type="text/css">'+CRLF
	cHtml += '		.button { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 10px; color: #000000; border: 1px ridge #CC6600; font-weight: bold; margin: 1px; padding: 1px; background-color: #ECEEEB; }'+CRLF
	cHtml += '		.text   { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 11px; color: 660000; text-decoration: none; font-style: normal; }'+CRLF
	cHtml += '		.title  { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; color: 660000; text-decoration:none; font-weight: bold; }'+CRLF
	cHtml += '		.table  { border-bottom:1px solid #999; border-right:1px solid #999; border-left:1px solid #999; border-top:1px solid #999; margin:1em auto; }'+CRLF
	cHtml += '		.form0  { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; color:#FFF; text-decoration: none; font-weight: bold; background-color:#CC0000}'+CRLF
	cHtml += '		.form1  { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 10px; color: #000000; text-decoration: none; font-weight: bold; background-color:#ECF0EE;}	'+CRLF
	cHtml += '		.form2  { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 11px; color: #333333; text-decoration: none; background-color:#F7F9F8;}'+CRLF
	cHtml += '		.form3  { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 9px; color: #333333; text-decoration: none; background-color:#F7F9F8; font-weight:bold}'+CRLF
	cHtml += '		.links  { font-family: Arial, Helvetica, sans-serif; font-size: 11px; color: 660000; text-decoration:underline; font-style: normal;}'+CRLF
	cHtml += '	</style>'+CRLF
	cHtml += ''+CRLF
	cHtml += '	<head>'+CRLF
	cHtml += '		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />'+CRLF
	cHtml += '		<title>Notificação Divergência</title>'+CRLF
	cHtml += '	</head>'+CRLF
	cHtml += '	<body>'+CRLF
	cHtml += '		<table width="90%" class="table">'+CRLF
	cHtml += '			<tr>'+CRLF
	cHtml += '				<td width="85%" align="center" bgcolor="#CC0000" class="form0">NOTIFICA&Ccedil;&Atilde;O DE PEND&Ecirc;NCIAS DE CONFER&Ecirc;NCIA PRE NOTA DE ENTRADA</td>'+CRLF
	cHtml += '			</tr>'+CRLF
	cHtml += '		</table> '+CRLF
	cHtml += '		<table width="90%" class="table">'+CRLF
	cHtml += '  <tr>'+CRLF
	cHtml += '	  <td width="100%" height="74">'+CRLF
	cHtml += '		  <table width="100%">'+CRLF
	cHtml += '			  <tr>'+CRLF
	cHtml += '				  <td colspan="8" class="form0">DOCUMENTOS</td>'+CRLF
	cHtml += '			  </tr>'+CRLF
	cHtml += '			  <tr>'+CRLF
	cHtml += '				  <td width="8%" class="form1" align="Left">Filial</td>'+CRLF
	cHtml += '				  <td width="39%" class="form1" align="Left">Fornecedor</td>'+CRLF
	cHtml += '				  <td width="10%" class="form1" align="Left">C&oacute;digo/Loja</td>'+CRLF
	cHtml += '				  <td width="8%" class="form1" align="Left">Docto.</td>'+CRLF
	cHtml += '				  <td width="8%" class="form1" align="Left">S&eacute;rie</td>'+CRLF
	cHtml += '				  <td width="9%" class="form1" align="Left">Dt. Emiss&atilde;o</td>'+CRLF
	cHtml += '				  <td width="9%" class="form1" align="Left">Dt. Inclus&atilde;o</td>'+CRLF
	cHtml += '				  <td width="9%" class="form1" align="Left">Hr. Inclus&atilde;o</td>'+CRLF
	cHtml += '			  </tr>'+CRLF
	For nCount := 1 To Len(aDados)
    	cHtml += '			  <tr>'+CRLF
    	cHtml += '				  <td width="8%"  class="form2" align="Left">'+aDados[nCount,aScan(aDados[nCount],{|x| Upper(x[1]) == Upper('NFE.cFilial' ) }),2]+'</td>'+CRLF
    	cHtml += '				  <td width="39%" class="form2" align="Left">'+aDados[nCount,aScan(aDados[nCount],{|x| Upper(x[1]) == Upper('NFE.cFornece') }),2]+'</td>'+CRLF
    	cHtml += '				  <td width="10%" class="form2" align="Left">'+aDados[nCount,aScan(aDados[nCount],{|x| Upper(x[1]) == Upper('NFE.cCodLoja') }),2]+'</td>'+CRLF
    	cHtml += '				  <td width="8%"  class="form2" align="Left">'+aDados[nCount,aScan(aDados[nCount],{|x| Upper(x[1]) == Upper('NFE.cDoc'    ) }),2]+'</td>'+CRLF
    	cHtml += '				  <td width="8%"  class="form2" align="Left">'+aDados[nCount,aScan(aDados[nCount],{|x| Upper(x[1]) == Upper('NFE.cSerie'  ) }),2]+'</td>'+CRLF
    	cHtml += '				  <td width="9%"  class="form2" align="Left">'+aDados[nCount,aScan(aDados[nCount],{|x| Upper(x[1]) == Upper('NFE.cDtEmis' ) }),2]+'</td>'+CRLF
    	cHtml += '				  <td width="9%"  class="form2" align="Left">'+aDados[nCount,aScan(aDados[nCount],{|x| Upper(x[1]) == Upper('NFE.cDtInc'  ) }),2]+'</td>'+CRLF
    	cHtml += '				  <td width="9%"  class="form2" align="Left">'+aDados[nCount,aScan(aDados[nCount],{|x| Upper(x[1]) == Upper('NFE.cHrInc'  ) }),2]+'</td>'+CRLF
    	cHtml += '			  </tr>'+CRLF
    Next nCount
	cHtml += '		  </table>'+CRLF
	cHtml += '	  </td>'+CRLF
	cHtml += '	</tr>'+CRLF
	cHtml += '        </table>'+CRLF
	cHtml += '	</body>'+CRLF
	cHtml += '</html>'+CRLF

EndIf

If cLayOut == "EXML040"
	cHtml := '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'+CRLF
	cHtml += '<html xmlns="http://www.w3.org/1999/xhtml">'+CRLF
	cHtml += '	<style type="text/css">'+CRLF
	cHtml += '		.button { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 10px; color: #000000; border: 1px ridge #CC6600; font-weight: bold; margin: 1px; padding: 1px; background-color: #ECEEEB; }'+CRLF
	cHtml += '		.text   { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 11px; color: 660000; text-decoration: none; font-style: normal; }'+CRLF
	cHtml += '		.title  { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; color: 660000; text-decoration:none; font-weight: bold; }'+CRLF
	cHtml += '		.table  { border-bottom:1px solid #999; border-right:1px solid #999; border-left:1px solid #999; border-top:1px solid #999; margin:1em auto; }'+CRLF
	cHtml += '		.form0  { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; color:#FFF; text-decoration: none; font-weight: bold; background-color:#CC0000}'+CRLF
	cHtml += '		.form1  { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 10px; color: #000000; text-decoration: none; font-weight: bold; background-color:#ECF0EE;}	'+CRLF
	cHtml += '		.form2  { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 11px; color: #333333; text-decoration: none; background-color:#F7F9F8;}'+CRLF
	cHtml += '		.form3  { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 9px; color: #333333; text-decoration: none; background-color:#F7F9F8; font-weight:bold}'+CRLF
	cHtml += '		.links  { font-family: Arial, Helvetica, sans-serif; font-size: 11px; color: 660000; text-decoration:underline; font-style: normal;}'+CRLF
	cHtml += '	</style>'+CRLF
	cHtml += ''+CRLF
	cHtml += '	<head>'+CRLF
	cHtml += '		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />'+CRLF
	cHtml += '		<title>Notificação Divergência</title>'+CRLF
	cHtml += '	</head>'+CRLF
	cHtml += '	<body>'+CRLF
	cHtml += '		<table width="90%" class="table">'+CRLF
	cHtml += '			<tr>'+CRLF
	cHtml += '				<td width="85%" align="center" bgcolor="#CC0000" class="form0">NOTIFICA&Ccedil;&Atilde;O DE CANCELAMENTO DA NOTA FISCAL DE ENTRADA</td>'+CRLF
	cHtml += '			</tr>'+CRLF
	cHtml += '		</table> '+CRLF
	cHtml += '	<table width="90%" class="table">'+CRLF
	cHtml += '  <tr>'+CRLF
	cHtml += '	  <td width="100%" height="74">'+CRLF
	cHtml += '		  <table width="100%">'+CRLF
	cHtml += '			  <tr>'+CRLF
	cHtml += '				  <td colspan="8" class="form0">DOCUMENTO</td>'+CRLF
	cHtml += '			  </tr>'+CRLF
	cHtml += '			  <tr>'+CRLF
	cHtml += '				  <td width="8%" class="form1" align="Left">Filial</td>'+CRLF
	cHtml += '				  <td width="39%" class="form1" align="Left">Fornecedor</td>'+CRLF
	cHtml += '				  <td width="10%" class="form1" align="Left">C&oacute;digo/Loja</td>'+CRLF
	cHtml += '				  <td width="8%" class="form1" align="Left">Docto.</td>'+CRLF
	cHtml += '				  <td width="8%" class="form1" align="Left">S&eacute;rie</td>'+CRLF
	cHtml += '				  <td width="9%" class="form1" align="Left">Dt. Emiss&atilde;o</td>'+CRLF
	cHtml += '				  <td width="9%" class="form1" align="Left">Dt. Inclus&atilde;o</td>'+CRLF
	cHtml += '				  <td width="9%" class="form1" align="Left">Hr. Inclus&atilde;o</td>'+CRLF
	cHtml += '			  </tr>'+CRLF
	cHtml += '			  <tr>'+CRLF
	cHtml += '				  <td width="8%"  class="form2" align="Left">'+aDados[aScan(aDados,{|x| Upper(x[1]) == Upper('NFE.cFilial')  }),2]+'</td>'+CRLF
	cHtml += '				  <td width="39%" class="form2" align="Left">'+aDados[aScan(aDados,{|x| Upper(x[1]) == Upper('NFE.cFornece') }),2]+'</td>'+CRLF
	cHtml += '				  <td width="10%" class="form2" align="Left">'+aDados[aScan(aDados,{|x| Upper(x[1]) == Upper('NFE.cCodLoja') }),2]+'</td>'+CRLF
	cHtml += '				  <td width="8%"  class="form2" align="Left">'+aDados[aScan(aDados,{|x| Upper(x[1]) == Upper('NFE.cDoc')     }),2]+'</td>'+CRLF
	cHtml += '				  <td width="8%"  class="form2" align="Left">'+aDados[aScan(aDados,{|x| Upper(x[1]) == Upper('NFE.cSerie')   }),2]+'</td>'+CRLF
	cHtml += '				  <td width="9%"  class="form2" align="Left">'+aDados[aScan(aDados,{|x| Upper(x[1]) == Upper('NFE.cDtEmis')  }),2]+'</td>'+CRLF
	cHtml += '				  <td width="9%"  class="form2" align="Left">'+aDados[aScan(aDados,{|x| Upper(x[1]) == Upper('NFE.cDtInc')   }),2]+'</td>'+CRLF
	cHtml += '				  <td width="9%"  class="form2" align="Left">'+aDados[aScan(aDados,{|x| Upper(x[1]) == Upper('NFE.cHrInc')   }),2]+'</td>'+CRLF
	cHtml += '			  </tr>'+CRLF
	cHtml += '		  </table>'+CRLF
	cHtml += '	  </td>'+CRLF
	cHtml += '	</tr>'+CRLF
	cHtml += '        </table>'+CRLF
	cHtml += '<table width="90%" class="table">'+CRLF
	cHtml += '		  <tr>'+CRLF
	cHtml += '		    <td width="100%" height="43"><table width="100%">'+CRLF
	cHtml += '		      <tr>'+CRLF
	cHtml += '		        <td class="form0">OBSERVA&Ccedil;&Atilde;O</td>'+CRLF
	cHtml += '	          </tr>'+CRLF
	cHtml += '		      <tr>'+CRLF
	cHtml += '		        <td width="8%" class="form2" align="left">'+aDados[aScan(aDados,{|x| Upper(x[1]) == Upper('cObserv')  }),2]+'</td>'+CRLF
	cHtml += '	          </tr>'+CRLF
	cHtml += '		      </table></td>'+CRLF
	cHtml += '	      </tr>'+CRLF
	cHtml += '    </table>'+CRLF
	cHtml += '    </body>'+CRLF
	cHtml += '</html>'+CRLF
EndIf

// Notificação de serviço do TSS fora do ar
If cLayOut == "EXML050"
	cHtml := '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'+CRLF
	cHtml += '<html xmlns="http://www.w3.org/1999/xhtml">'+CRLF
	cHtml += '	<style type="text/css">'+CRLF
	cHtml += '		.button { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 10px; color: #000000; border: 1px ridge #CC6600; font-weight: bold; margin: 1px; padding: 1px; background-color: #ECEEEB; }'+CRLF
	cHtml += '		.text   { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 11px; color: 660000; text-decoration: none; font-style: normal; }'+CRLF
	cHtml += '		.title  { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; color: 660000; text-decoration:none; font-weight: bold; }'+CRLF
	cHtml += '		.table  { border-bottom:1px solid #999; border-right:1px solid #999; border-left:1px solid #999; border-top:1px solid #999; margin:1em auto; }'+CRLF
	cHtml += '		.form0  { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; color:#FFF; text-decoration: none; font-weight: bold; background-color:#CC0000}'+CRLF
	cHtml += '		.form1  { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 10px; color: #000000; text-decoration: none; font-weight: bold; background-color:#ECF0EE;}	'+CRLF
	cHtml += '		.form2  { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 11px; color: #333333; text-decoration: none; background-color:#F7F9F8;}'+CRLF
	cHtml += '		.form3  { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 9px; color: #333333; text-decoration: none; background-color:#F7F9F8; font-weight:bold}'+CRLF
	cHtml += '		.links  { font-family: Arial, Helvetica, sans-serif; font-size: 11px; color: 660000; text-decoration:underline; font-style: normal;}'+CRLF
	cHtml += '	</style>'+CRLF
	cHtml += ''+CRLF
	cHtml += '	<head>'+CRLF
	cHtml += '		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />'+CRLF
	cHtml += '		<title>Notificação Divergência</title>'+CRLF
	cHtml += '	</head>'+CRLF
	cHtml += '	<body>'+CRLF
	cHtml += '		<table width="90%" class="table">'+CRLF
	cHtml += '			<tr>'+CRLF
	cHtml += '				<td width="85%" align="center" bgcolor="#CC0000" class="form0">NOTIFICA&Ccedil;&Atilde;O DE INDISPONIBILIDADE DO SERVIDOR DO TSS</td>'+CRLF
	cHtml += '			</tr>'+CRLF
	cHtml += '		</table> '+CRLF
	cHtml += '	<table width="90%" class="table">'+CRLF
	cHtml += '  <tr>'+CRLF
	cHtml += '	  <td width="100%" height="74">'+CRLF
	cHtml += '		  <table width="100%">'+CRLF
	cHtml += '			  <tr>'+CRLF
	cHtml += '				  <td colspan="8" class="form0">MOTIVO</td>'+CRLF
	cHtml += '			  </tr>'+CRLF
	cHtml += '			  <tr>'+CRLF
	cHtml += '				  <td width="100%"  class="form2" align="Left">O servi&ccedil;o do TSS esta indisponivel ou n&atilde;o foi configurado!</td>'+CRLF
	cHtml += '			  </tr>'+CRLF
	cHtml += '		  </table>'+CRLF
	cHtml += '	  </td>'+CRLF
	cHtml += '	</tr>'+CRLF
	cHtml += '        </table>'+CRLF
	cHtml += '<table width="90%" class="table">'+CRLF
	cHtml += '		  <tr>'+CRLF
	cHtml += '		    <td width="100%" height="43"><table width="100%">'+CRLF
	cHtml += '		      <tr>'+CRLF
	cHtml += '		        <td class="form0">SOLU&Ccedil;&Atilde;O</td>'+CRLF
	cHtml += '	          </tr>'+CRLF
	cHtml += '		      <tr>'+CRLF
	cHtml += '		        <td width="8%" class="form2" align="left">Solu&ccedil;&atilde;o 1: Execute o modulo de configura&ccedil;&atilde;o do servi&ccedil;o do SPED NFE.</td>'+CRLF
	cHtml += '	          </tr>'+CRLF
	cHtml += '		      <tr>'+CRLF
	cHtml += '		        <td width="8%" class="form2" align="left">Solu&ccedil;&atilde;o 2: Habilite o servi&ccedil;o do TSS. Caso n&atilde;o seja possivel, desabilite o parametro ES_HBCONNF.</td>'+CRLF
	cHtml += '	          </tr>'+CRLF
	cHtml += '		      </table></td>'+CRLF
	cHtml += '	      </tr>'+CRLF
	cHtml += '    </table>'+CRLF
	cHtml += '    </body>'+CRLF
	cHtml += '</html>'+CRLF
EndIf

If cLayOut == "EXML060"
	cHtml := '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'+CRLF
	cHtml += '<html xmlns="http://www.w3.org/1999/xhtml">'+CRLF
	cHtml += '	<style type="text/css">'+CRLF
	cHtml += '		.button { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 10px; color: #000000; border: 1px ridge #CC6600; font-weight: bold; margin: 1px; padding: 1px; background-color: #ECEEEB; }'+CRLF
	cHtml += '		.text   { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 11px; color: 660000; text-decoration: none; font-style: normal; }'+CRLF
	cHtml += '		.title  { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; color: 660000; text-decoration:none; font-weight: bold; }'+CRLF
	cHtml += '		.table  { border-bottom:1px solid #999; border-right:1px solid #999; border-left:1px solid #999; border-top:1px solid #999; margin:1em auto; }'+CRLF
	cHtml += '		.form0  { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; color:#FFF; text-decoration: none; font-weight: bold; background-color:#CC0000}'+CRLF
	cHtml += '		.form1  { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 10px; color: #000000; text-decoration: none; font-weight: bold; background-color:#ECF0EE;}	'+CRLF
	cHtml += '		.form2  { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 11px; color: #333333; text-decoration: none; background-color:#F7F9F8;}'+CRLF
	cHtml += '		.form3  { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 9px; color: #333333; text-decoration: none; background-color:#F7F9F8; font-weight:bold}'+CRLF
	cHtml += '		.links  { font-family: Arial, Helvetica, sans-serif; font-size: 11px; color: 660000; text-decoration:underline; font-style: normal;}'+CRLF
	cHtml += '	</style>'+CRLF
	cHtml += ''+CRLF
	cHtml += '	<head>'+CRLF
	cHtml += '		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />'+CRLF
	cHtml += '		<title>Notificação Divergência</title>'+CRLF
	cHtml += '	</head>'+CRLF
	cHtml += '	<body>'+CRLF
	cHtml += '		<table width="90%" class="table">'+CRLF
	cHtml += '			<tr>'+CRLF
	cHtml += '				<td width="85%" align="center" bgcolor="#CC0000" class="form0">NOTIFICA&Ccedil;&Atilde;O DE DIVERG&Ecirc;NCIA FISCAL (NOTA FISCAL vs CADASTRO DE PRODUTOS)</td>'+CRLF
	cHtml += '			</tr>'+CRLF
	cHtml += '		</table> '+CRLF
	cHtml += '		<table width="90%" class="table">'+CRLF
	cHtml += '  <tr>'+CRLF
	cHtml += '	  <td width="100%" height="74">'+CRLF
	cHtml += '		  <table width="100%">'+CRLF
	cHtml += '			  <tr>'+CRLF
	cHtml += '				  <td colspan="8" class="form0">DOCUMENTO '+aDados[1]+aDados[2]+'</td>'+CRLF
	cHtml += '			  </tr>'+CRLF
	cHtml += '			  <tr>'+CRLF
	cHtml += '				  <td width="10%" class="form1" align="Left">Item</td>'+CRLF
	cHtml += '				  <td width="40%" class="form1" align="Left">Produto</td>'+CRLF
	cHtml += '				  <td width="25%" class="form1" align="Left">NCM da NFE</td>'+CRLF
	cHtml += '				  <td width="25%" class="form1" align="Left">NCM Cadastrado</td>'+CRLF
	cHtml += '			  </tr>'+CRLF
	For nCount := 1 To Len(aErros)
    	cHtml += '			  <tr>'+CRLF
    	cHtml += '				  <td width="10%"  class="form2" align="Left">'+aErros[nCount,1]+'</td>'+CRLF
    	cHtml += '				  <td width="40%"  class="form2" align="Left">'+aErros[nCount,2]+'</td>'+CRLF
    	cHtml += '				  <td width="25%"  class="form2" align="Left">'+aErros[nCount,3]+'</td>'+CRLF
    	cHtml += '				  <td width="25%"  class="form2" align="Left">'+aErros[nCount,4]+'</td>'+CRLF
    	cHtml += '			  </tr>'+CRLF
    Next nCount
	cHtml += '		  </table>'+CRLF
	cHtml += '	  </td>'+CRLF
	cHtml += '	</tr>'+CRLF
	cHtml += '        </table>'+CRLF
	cHtml += '	</body>'+CRLF
	cHtml += '</html>'+CRLF

EndIf

Return cHtml
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºRotina    ³ VERTODOS ºAutor  ³ Ernani Forastieri  º Data ³  20/11/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao auxiliar para verificar se estao todos marcardos    º±±
±±º          ³ ou nao                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VerTodos( aVetor, lChk, oChkMar )
Local lTTrue := .T.
Local nI     := 0

For nI := 1 To Len( aVetor )
	lTTrue := IIf( !aVetor[nI][1], .F., lTTrue )
Next nI

lChk := IIf( lTTrue, .T., .F. )
oChkMar:Refresh()

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ MyOpenSM0º Autor ³ TOTVS Protheus     º Data ³  24/04/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao³ Funcao de processamento abertura do SM0 modo exclusivo     ³±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³ Uso      ³ MyOpenSM0  - Gerado por EXPORDIC / Upd. V.4.10.6 EFS       ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MyOpenSM0(lShared)

Local lOpen := .F.
Local nLoop := 0

For nLoop := 1 To 20
	dbUseArea( .T., , "SIGAMAT.EMP", "SM0", lShared, .F. )

	If !Empty( Select( "SM0" ) )
		lOpen := .T.
		dbSetIndex( "SIGAMAT.IND" )
		Exit
	EndIf

	Sleep( 500 )

Next nLoop

If !lOpen
	MsgStop( "Não foi possível a abertura da tabela " + ;
	IIf( lShared, "de empresas (SM0).", "de empresas (SM0) de forma exclusiva." ), "ATENÇÃO" )
EndIf

Return lOpen

/////////////////////////////////////////////////////////////////////////////


User Function Teste_EXML()
Local c_Emp 	 := "01"
Local c_Fil 	 := "010101"
Local cLayOut    := ""
Local aDadosHTML := {}
Local aItensHTML := {}
Local aErrosHTML := {}
Local aItensErro := {}
Local aAnexos    := {}
Local nCntFor1   := 0

//Abre Ambiente
PREPARE ENVIRONMENT EMPRESA c_Emp Filial c_Fil modulo 'COM'

//
//	Teste EXML010
//

/*cLayOut := "EXML010"
Aadd(aDadosHTML,{'cNomeXML'   , "TEMPLATE EXML010"          })
Aadd(aDadosHTML,{'cNomeFor'   , "FORNECEDOR TESTE"})
Aadd(aDadosHTML,{'cCNPJFor'   , "XXX.XXX.XXX-XX"  })
Aadd(aDadosHTML,{'cDoc'       , "0000001"         })
Aadd(aDadosHTML,{'cSerie'     , "UNI"             })
Aadd(aDadosHTML,{'dDtEmissao' , DtoC(dDataBase)   })
Aadd(aDadosHTML,{'cNomeDest'  , "DESTINATÁRIO TESTE"    })
Aadd(aDadosHTML,{'cCNPJDest'  , "XXX.XXX.XXX-XX"  })
Aadd(aDadosHTML,{'cLoja'      , "01"})

For nCntFor1 := 1 To 4
    aItensErro := {}

	AAdd(aItensErro,{'ERRO.cItem'   , '0'+AllTrim(Str(nCntFor1)) } )
	AAdd(aItensErro,{'ERRO.cCodPro' , 'PROD00'+AllTrim(Str(nCntFor1)) } )
	AAdd(aItensErro,{'ERRO.cDesPro' , "PRODUTO ACABADO 00"+AllTrim(Str(nCntFor1)) } )
	AAdd(aItensErro,{'ERRO.cMotivo' , 'Motivo 00'+AllTrim(Str(nCntFor1)) } )

	aAdd(aErrosHTML, aItensErro)
Next nCntFor1

cMensagem := GetHTMLMessage( "exml010", aDadosHTML, aErrosHTML )

Aadd(aAnexos,DIRXML + DIRLIDO + "parafusalia 37632.xml")
Aadd(aAnexos,DIRXML + DIRLIDO + "pop3.jpg")
*/
//
// Teste EXML020
//
/*cLayOut := "EXML020"
Aadd(aDadosHTML,{'cNomeXML' , "TEMPLATE EXML020" })
Aadd(aDadosHTML,{'cNomeFor' , "FORNECEDOR TESTE" 	  })
Aadd(aDadosHTML,{'cCNPJFor' , 'XXX.XXX.XXX-XX'})
Aadd(aDadosHTML,{'cDoc'     , '0001' 		  })
Aadd(aDadosHTML,{'cSerie'   , 'UNI' 	      })
Aadd(aDadosHTML,{'cNomeDest', "DESTINATÁRIO TESTE"  })
Aadd(aDadosHTML,{'cCNPJDest', 'XXX.XXX.XXX-XX'})

//For nCntFor1 := 1 To 3
aItensErro := {}
AAdd(aItensErro,{'ERRO.cMotivo'  , 'Produto não encontrado '})
AAdd(aItensErro,{'ERRO.cSolucao' , 'Cadastre o produto'})
aAdd(aErrosHTML, aItensErro)

aItensErro := {}
AAdd(aItensErro,{'ERRO.cMotivo'  , 'Fornecedor não cadastrado '})
AAdd(aItensErro,{'ERRO.cSolucao' , 'Cadastre o fornecedor'})
aAdd(aErrosHTML, aItensErro)
//Next nCntFor1

cMensagem := GetHTMLMessage( "exml020", aDadosHTML, aErrosHTML )*/

//
// Teste Exml030
//
/*cLayOut := "EXML030"
For nCntFor1 := 1 To 3

	aItensHTML := {} // Zera as informacoes para preenchimento da proxima linha

	Aadd(aItensHTML,{'NFE.cFilial' , c_Fil                              })
	Aadd(aItensHTML,{'NFE.cFornece', "FORNECEDOR TESTE "+AllTrim(Str(nCntFor1))       })
	Aadd(aItensHTML,{'NFE.cCodLoja', "0"+AllTrim(Str(nCntFor1))         })
	Aadd(aItensHTML,{'NFE.cDoc'    , "00000000"+AllTrim(Str(nCntFor1))  })
	Aadd(aItensHTML,{'NFE.cSerie'  , "UNI"                              })
	Aadd(aItensHTML,{'NFE.cDtEmis' , DtoC(dDataBase-10)                 })
	Aadd(aItensHTML,{'NFE.cDtInc'  , DtoC(dDataBase)                    })
	Aadd(aItensHTML,{'NFE.cHrInc'  , Time()                             })

	aAdd(aDadosHTML,aItensHTML)

Next nCntFor1

cMensagem := GetHTMLMessage( "exml030", aDadosHTML )*/

//
// Teste Exml040
//

cLayOut := "EXML040"
Aadd(aDadosHTML,{'NFE.cFilial'  , c_Fil  })
AAdd(aDadosHTML,{'NFE.cFornece' , "FORNECEDOR TESTE "})
AAdd(aDadosHTML,{'NFE.cCodLoja' , "01"} )
AAdd(aDadosHTML,{'NFE.cDoc'     , "000000001"  })
AAdd(aDadosHTML,{'NFE.cSerie'   , "UNI"  })
AAdd(aDadosHTML,{'NFE.cDtEmis'  , DtoC(dDataBase-10)  })
AAdd(aDadosHTML,{'NFE.cDtInc'   , DtoC(dDataBase)  })
AAdd(aDadosHTML,{'NFE.cHrInc'   , Time()  })
aAdd(aDadosHTML,{'cObserv'      , 'Pre Nota de Entrada excluida com sucesso !!'     })

cMensagem := GetHTMLMessage( cLayOut, aDadosHTML )

/*
cLayOut := "EXML050"
cMensagem := GetHTMLMessage( cLayOut )
*/

EXMLSendMail("leandro.dourado@totvs.com.br","Teste e-XML",cMensagem,aAnexos)

Return

/*/{Protheus.doc} CriaSA5
Cria amarração de produto x fornecedor quando o produto for cadastrado via eXML.
Esse processo não é feito por rotina automática porque o fonte responsável por esse cadastro (MATA370) não possui tal tratamento.

@author  Leandro Faggyas Dourado
@since   13/07/2015
@version 1.0
@return  lRet, logical  , Retorna verdadeiro ou falso se a amarração foi criada corretamente.
/*/
Static Function CriaSA5(cFornecedor,cLoja,cProduto,lJob,;
											cFile,aErros)
Local aArea := GetArea()
Local aSA5  := {}
Local lRet  := .T.

Private lMsErroAuto := .F.

AAdd(aSA5, {"A5_FORNECE", cFornecedor, NIL})
AAdd(aSA5, {"A5_LOJA"	, cLoja      , NIL})
AAdd(aSA5, {"A5_PRODUTO", cProduto   , NIL})
AAdd(aSA5, {"A5_CODPRF"	, cProduto   , NIL})

MSExecAuto({|x,y| MATA060(x,y)},aSA5,3)

If lMsErroAuto
	If lJob
		MostraErro(DIRXML+DIRERRO,StrTran(Upper(cFile),".XML","_ERR.TXT"))
		AAdd(aErros,{cFile,"Erro na geração do Cadastro de amarração Produtos x Fornecedor.","Cheque o arquivo "+StrTran(Upper(cFile),".XML","_ERR.TXT")})
	Else
		MostraErro()
	EndIf
	lRet  := .F.
EndIf

RestArea( aArea )

Return lRet

/*/{Protheus.doc} CriaSA7
Cria amarração de produto x cliente quando a nota for de beneficiamento.
Esse processo não é feito por rotina automática porque o fonte responsável por esse cadastro (MATA370) não possui tal tratamento.

@author  Leandro Faggyas Dourado
@since   13/07/2015
@version 1.0
@return  lRet, logical  , Retorna verdadeiro ou falso se a amarração foi criada corretamente.
/*/
Static Function CriaSA7(cCliente,cLoja,cProduto)
Local aArea := GetArea()

DbSelectArea("SA7")
SA7->(DbSetOrder())

Reclock("SA7",.T.)
SA7->A7_FILIAL  := xFilial("SA7")
SA7->A7_CLIENTE := cCliente
SA7->A7_LOJA    := cLoja
SA7->A7_PRODUTO := cProduto
SA7->A7_CODCLI  := cProduto
SA7->(MsUnlock())

RestArea( aArea )

Return Nil

/*/{Protheus.doc} ErrTSSMail
Notifica quando o serviço do TSS está fora do ar, caso o processamento seja feito via JOB.

@author  Leandro Faggyas Dourado
@since   21/07/2015
@version 1.0
/*/
Static Function ErrTSSMail()
Local cMailAdm  := GetMV('ES_MAILADM',.F.,'') //-- E-mail de notificacao Administrado Sistema
Local cMensagem := GetHTMLMessage( "exml050" )
Local cAssunto  := '[EXML] - Notificação de Indisponibilidade de Serviço TSS'

EXMLSendMail(cMailAdm,cAssunto,cMensagem)

Return

/*/{Protheus.doc} EXMLTstMail
Envia um e-mail de teste.

@author  Leandro Faggyas Dourado
@since   21/07/2015
@version 1.0
/*/
User Function EXMLTstMail()
Local cMailADM := GetMV('ES_MAILADM',.F.,'')

EXMLSendMail(cMailADM,"[EXML] - Teste de Envio","Teste!!",,.T.)

Return

//-------------------------------------------------------------------
/*EXMLCTE
Decodificação do XML CTE

@author  Caio Murakami
@since   19/01/2015
@version 1.0      
*/
//-------------------------------------------------------------------
User Function EXMLCTE(cCodEmp,cCodFil)
Local nCount		:= 0
Local nValCte		:= 0 //-- Valor CT-e
Local nBaseICM60	:= 0 //-- Base ICMS Substituição Tributária
Local nValICM60		:= 0 //-- Valor ICMS Substituição Tributária
Local nX			:= 0
Local cBuffer		:= ""
Local cCodProd		:= "" 
Local cError		:= ""
Local cWarning		:= ""
Local cXMLRet		:= ""
Local cNumCTe		:= "" //-- Numeração CT-e
Local cSerieCTe		:= "" //-- Serie CT-e		
Local cCGCForn		:= "" //-- CNPJ Fornecedor
Local lRet			:= .T. 
Local oXml			:= Nil
Local oXmlAux		:= Nil
Local aItens		:= {} 
Local aNotas		:= {}
Local dDtEmisCTe	:= Nil
Local cFileOpen		:= ""
Local aDirXml		:= ""
Local cNomeArq		:= ""
Local lJob			:= .F. 

DEFAULT cCodEmp   := GetJobProfString('Empresa', '01')
DEFAULT cCodFil   := GetJobProfString('Filial' , '01')

// Seta job para nao consumir licensas
If !(AllTrim(Upper(FunName())) $ "MATA103/MATA140/U_EXMLIMP")
	RpcSetType(3)
	RPCSetEnv( cCodEmp, cCodFil,,, "COM")
	lJob	:= .T. 
EndIf


//-- Cria os diretorios de importacao
If !ExistDir(DIRCTE)
	MakeDir(DIRCTE)
	MakeDir(DIRCTE + DIRALER)
	MakeDir(DIRCTE + DIRLIDO)
	MakeDir(DIRCTE + DIRERRO)
EndIf

//-- Verica se existe arquivo XML pendente para ser importado
aDirXml  := Directory( DIRCTE + DIRALER + '*.XML' )

For nX	:= 1 To Len(aDirXML)
	cFileOpen 	:= DIRCTE + DIRALER + aDirXml[nX][1]
	cNomeArq	:= aDirXml[nX][1]
	cBuffer		:= ""
	lRet		:= .T. 
	cError		:= ""
	cWarning	:= ""
	cCGCForn	:= ""
	cNumCte		:= ""
	cSerieCTe	:= ""
	dDtEmisCTe	:= dDataBase
	nValCte		:= 0
	nBaseICM60	:= 0
	nValICM60	:= 0
	aNotas		:= {}

	FT_FUSE(cFileOpen) //ABRIR
	FT_FGOTOP()//Posiciona no inicio
	ProcRegua(FT_FLASTREC()*2) //QTOS REGISTROS LER
	
	While !FT_FEOF()
		IncProc("Processando XML" )
		cBuffer 	+= FT_FREADLN() //LENDO LINHA		
		FT_FSKIP() //próximo registro no arquivo 	
	EndDo
	
	FT_FUSE() //fecha o arquivo 
	
	If lRet
		oXML := XmlParser( cBuffer, "_", @cError, @cWarning )
		
		//Verifica se houve erro na criacao do objeto XML
		If ( oXML <> Nil ) .And. ( Empty(cError) ) .And. ( Empty(cWarning) )
			If XmlChildEx( oXML, '_CTEPROC' ) != Nil 
				oXML	:= oXML:_cteProc
				
				If XmlChildEx( oXML, '_CTE' ) != Nil
					oXML	:= oXML:_Cte
					
					If XmlChildEx( oXML , '_INFCTE') != Nil
						oXML	:= oXML:_infCte
						
						//--------------------------------------------------------------------
						//-- Busca numeração CT-e
						//--------------------------------------------------------------------
						If XmlChildEx( oXML , '_IDE') != Nil
							oXMLAux	:= oXML:_ide
							
							If XmlChildEx(oXMLAux,'_NCT') != Nil
								cNumCte		:= oXMLAux:_nCT:text
							EndIf
							
							If XMLChildEx(oXMLAux,'_SERIE') != Nil
								cSerieCTe	:= oXMLAux:_serie:text
							EndIf
							
							If XMLChildEx(oXMLAux,'_DHEMI') != Nil
								dDtEmisCTe := Ctod( SubStr( oXMLAux:_dhEmi:Text , 9, 2 ) + '/' + ;
												SubStr( oXMLAux:_dhEmi:Text, 6, 2 ) + '/' + ;
												SubStr( oXMLAux:_dhEmi:Text, 1, 4 ) )
							
							EndIf
						EndIf
						
						//--------------------------------------------------------------------
						//-- Busca dados da transportadora 
						//--------------------------------------------------------------------
						If XmlChildEx( oXML , '_EMIT') != Nil
							oXMLAux	:= oXML:_emit
							
							If XMLChildEx(oXMLAux , '_CNPJ') != Nil
								cCGCForn	:= oXMLAux:_CNPJ:text	
							EndIf
						EndIf
						
						//--------------------------------------------------------------------
						//-- Busca Valores CT-e
						//--------------------------------------------------------------------
						
						//-- Valor prestação de serviço
						If XmlChildEx( oXML , '_VPREST') != Nil
							oXMLAux	:= oXML:_vPrest
							
							//-- Valor Prestação de Serviço
							If XmlChildEx(oXMLAux , '_VTPREST') != Nil
								nValCte		:= Val(oXMLAux:_vTPrest:Text)
							EndIf					
						EndIf
						
						//-- Valores ICMS 
						If XmlChildEx( oXml , '_IMP') != Nil
							oXMLAux	:= oXml:_imp
							
							If XmlChildEx(oXmlAux , '_ICMS') != Nil
								oXMLAux		:= oXMLAux:_ICMS
								
								//-- Substituição Tributária
								If XmlChildEx(oXMLAux, '_ICMS60') != Nil
									oXMLAux	:= oXMLAux:_ICMS60
									
									//-- Base ICMS 
									If XmlChildEx(oXMLAux,'_VBC') != Nil
										nBaseICM60	:= Val(oXMLAux:_vBC:Text)
									EndIf
									
									//-- Valor ICMS 
									If XmlChildEx(oXMLAux,'_VICMS') != Nil
										nValICM60	:= Val(oXMLAux:_vICMS:Text)
									EndIf
								EndIf
							EndIf					
						EndIf	
						
						//--------------------------------------------------------------------
						//-- Verifica notas fiscais existentes
						//--------------------------------------------------------------------
						If XmlChildEx( oXML , '_INFCTENORM') != Nil
							oXMLAux		:= oXML:_InfCteNorm
							
							If XmlChildEx( oXMLAux , '_INFDOC') != Nil
								oXMLAux		:= oXMLAux:_infDoc
								
								If XmlChildEx(oXMLAux,'_INFNFE') != Nil
									oXMLAux		:= oXMLAux:_infNfe	
																								
									If XmlChildEx(oXMLAux , '_CHAVE') != Nil
									
										//-- Transforma em um array
										If ValType(oXMLAux:_chave) <> "A"
											XmlNode2Arr(oXMLAux:_chave, "_CHAVE")
										EndIf			
										
										//-- Chaves da nota fiscal eletrônica					
										For nCount := 1 To Len(oXMLAux:_chave)
											Aadd( aNotas , oXMLAux:_chave[nCount]:Text )
										Next nCount
										
									EndIf
								EndIf
							EndIf
						EndIf
																									
					EndIf
				EndIf
							
			EndIf	
		Else
			//Tratamento no erro do parse Xml
			lRet 	:= .F.
			cXMLRet := 'Erro na manipulação do Xml recebido'
			cXMLRet += IIf ( !Empty(cError), cError, cWarning )
			
			cXMLRet := EncodeUTF8( cXMLRet )		
		EndIf
		
		If lRet .And. Len(aNotas) > 0
			lRet	:= GeraDoc(aNotas , cNumCte , cSerieCte , dDtEmisCTe , cCGCForn , nValCte , nBaseICM60 , nValICM60 , lJob , cFileOpen , cNomeArq )
		Else
			lRet	:= .F. 
		EndIf
		
	EndIf
Next nX

Return lRet

//-------------------------------------------------------------------
/*GeraDoc
Gera MATA116

@author  Caio Murakami
@since   19/01/2015
@version 1.0      
*/
//-------------------------------------------------------------------
Static Function GeraDoc(aNotas , cNumCte , cSerieCte , dDtEmisCTe , cCGCForn , nValCte , nBaseICM60 , nValICM60 , lJob , cFileOpen , cNomeArq )
Local lRet		:= .T. 
Local nCount	:= 1
Local aArea		:= GetArea()
Local aCabec	:= {}
Local aItens	:= {}
Local aErroAuto	:= {}
Local cFornCTe	:= ""
Local cLojaCTe	:= ""
Local cLogErro	:= ""

Default aNotas		:= {}
Default cNumCTe		:= ""
Default cSerieCte	:= ""
Default dDtEmisCTe	:= dDataBase
Default cCGCForn	:= ""
Default nValCte		:= 0
Default nBaseICM60	:= 0
Default nValICM60	:= 0
Default lJob		:= .F. 
Default cFileOpen	:= ""
Default cNomeArq	:= ""

//-- FILIAL + CGC
SA2->(dbSetOrder(3))
If SA2->(MsSeek(xFilial("SA2") + cCGCForn))
	cFornCTE	:= SA2->A2_COD
	cLojaCTe	:= SA2->A2_LOJA
EndIf

//-- FILIAL + CHAVENFE
SF1->(dbSetOrder(8))
For nCount := 1 To Len(aNotas)
	If SF1->(MsSeek(xFilial("SF1") + aNotas[nCount] ))
		Aadd(aItens,{ {"PRIMARYKEY",	SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA	,Nil } })
	Else
		MsgStop("A nota fiscal de chave: " + aNotas[nCount] +" não foi encontrada no sistema. O XML não será importado.")
		lRet	:= .F. 
	EndIf
Next nCount

If lRet
	Pergunte("IMPCTE",.F.)
	
	aAdd(aCabec,{""				,dDataBase-90 })       												// Data inicial para filtro das notas
	aAdd(aCabec,{""				,dDataBase    })       												// Data final para filtro das notas
	aAdd(aCabec,{""				,2            })       												// 2-Inclusao ; 1=Exclusao
	aAdd(aCabec,{""				,Space(TamSx3("F1_FORNECE")[1]) } )    								// Rementente das notas contidas no conhecimento
	aAdd(aCabec,{""				,Space(TamSx3("F1_LOJA")[1])    } )  								// Loja do remetente das notas contidas no conhecimento
	aAdd(aCabec,{""				,1       })                											// Tipo das notas contidas no conhecimento: 1=Normal ; 2=Devol/Benef
	aAdd(aCabec,{""				,1       })                											// 1=Aglutina itens ; 2=Nao aglutina itens
	aAdd(aCabec,{"F1_EST"		,""      })		  													// UF das notas contidas no conhecimento
	aAdd(aCabec,{""				,nValCte }) 														// Valor do conhecimento
	aAdd(aCabec,{"F1_FORMUL"	,1       })															// Formulario proprio: 1=Nao ; 2=Sim
	aAdd(aCabec,{"F1_DOC"		,PadR(cNumCTE,TamSx3("F1_DOC")[1])     } )							// Numero da nota de conhecimento
	aAdd(aCabec,{"F1_SERIE"		,PadR(cSerieCTE,TamSx3("F1_SERIE")[1]) } )							// Serie da nota de conhecimento
	aAdd(aCabec,{"F1_FORNECE"	,cFornCTe   })														// Fornecedor da nota de conhecimento
	aAdd(aCabec,{"F1_LOJA"		,cLojaCTe   })														// Loja do fornecedor da nota de conhecimento
	aAdd(aCabec,{""				,mv_par02   })														// TES a ser utilizada nos itens do conhecimento
	aAdd(aCabec,{"F1_BASERET"	,nBaseICM60 })														// Valor da base de calculo do ICMS retido
	aAdd(aCabec,{"F1_ICMRET"	,nValICM60  })														// Valor do ICMS retido
	aAdd(aCabec,{"F1_COND"		,mv_par01   })										   				// Condicao de pagamento
	aAdd(aCabec,{"F1_EMISSAO"	,dDtEmisCTe }) 														// Data de emissao do conhecimento
	aAdd(aCabec,{"F1_ESPECIE"	,"CTE"      })														// Especie do documento
	aAdd(aCabec,{"Natureza"		,"C"        })														// Chave para tratamentos especificos
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa a ExecAuto do MATA116 para gravar os itens com o valor de frete rateado ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lMsErroAuto    := .F.
	lAutoErrNoFile := .T.
	
	SA2->(dbSetOrder(1))
	SF1->(dbSetOrder(1))
	
	BEGIN TRANSACTION
	
	MsExecAuto({|x,y| MATA116(x,y)},aCabec,aItens)
	
	If lMsErroAuto
		DisarmTransaction()
		If lJob
			MostraErro(DIRCTE + DIRERRO,StrTran(Upper(cNomeArq),".XML","_ERR.TXT"))
			//-- Move arquivo para pasta dos processados
			Copy File &(DIRXML + DIRALER + cNomeArq) To &(DIRXML + DIRERRO + cNomeArq)
			FErase(DIRXML+DIRALER+cNomeArq)
			lRet 	:= .F.
		Else
			aErroAuto := GetAutoGRLog()		
			For nCount := 1 To Len(aErroAuto)
				cLogErro += StrTran(StrTran(aErroAuto[nCount],"<",""),"-","") + chr(13)+ chr(10)
			Next nCont
			
			ExibeLog(cLogErro)
			MostraErro(DIRCTE + DIRERRO,StrTran(Upper(cNomeArq),".XML","_ERR.TXT"))
			
			//-- Move arquivo para pasta dos processados
			Copy File &(DIRXML + DIRALER + cNomeArq) To &(DIRXML + DIRERRO + cNomeArq)
			FErase(DIRXML+DIRALER+cNomeArq)
			lRet 	:= .F.
		EndIf
	Else
		//-- Move arquivo para pasta dos processados
		Copy File &(DIRCTE + DIRALER + cNomeArq) To &(DIRCTE + DIRLIDO + cNomeArq)
		FErase(DIRCTE + DIRALER + cNomeArq)
		If !lJob
			MsgInfo("Conhecimento: " + cNumCTE + " incluido com sucesso.")
		EndIf
	EndIf
	
	END TRANSACTION
	
EndIf

RestArea(aArea)
Return lRet

/*/{Protheus.doc} AJUSTASX1

@since 19/01/2016
@version 1.0

@type function
/*/

Static Function AJUSTASX1(cPerg)

Default cPerg		:= "IMPCTE"

PutSx1(cPerg,'01','Condição Pgto? ','Condição Pgto?' ,'Condição Pgto?'	,'mv_ch1','C',TamSx3("E4_CODIGO")[1]	,0,0,'G','','SE4'	,'','','mv_par01','','','','','','','','','','','','','','','','')//,Nil,Nil,Nil)
PutSx1(cPerg,'02','TES? ','TES?' ,'TES?'	,'mv_ch2','C',TamSx3("F4_CODIGO")[1]	,0,0,'G','','SF4'	,'','','mv_par02','','','','','','','','','','','','','','','','')//,Nil,Nil,Nil)

Return

//-------------------------------------------------------------------
/* ExibeLog
ExibeLog

@author  Caio Murakami
@since   15/10/15
@version 1.0
*/
//-------------------------------------------------------------------
Static Function ExibeLog(cLogErro)
Local nCont		:= 0
Local aArea		:= GetArea()
Local nHandle	:= 0
Local oDlg
Local cMemo
Local cFile    	:=	""
Local cMask    	:= "Arquivos Texto (*.TXT) |*.txt|"
Local oFont
Local cFile		:= ""

Default cLogErro	:= ""

DEFINE FONT oFont NAME "Courier New" SIZE 7,14   //6,15

cMemo := cLogErro
DEFINE MSDIALOG oDlg TITLE "Erro ExecAuto" From 3,0 to 600,800 PIXEL
oDlg:lCentered	:= .T.

@ 5,5 GET oMemo  VAR cMemo MEMO SIZE 380,270 OF oDlg PIXEL
oMemo:bRClicked := {||AllwaysTrue()}
oMemo:oFont:=oFont

DEFINE SBUTTON  FROM 280,010 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL //Apaga
DEFINE SBUTTON  FROM 280,050 TYPE 13 ACTION (cFile:=cGetFile(cMask,OemToAnsi("Salvar Como...")),If(cFile="",.t.,MemoWrite(cFile,cMemo)),oDlg:End()) ENABLE OF oDlg PIXEL

ACTIVATE MSDIALOG oDlg CENTER	
Return

/*/{Protheus.doc} fLeFile
Retira caracteres especiais chr(13)+chr(10) do XML, caso exista
@author Giane
@since 04/04/2016
@version 1.0
@param cFile, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function fLeFile(cFile)

Local cBuffer := ''
Local nFile := 0
local xBuffer := space(100)
local nTamArq := 0
Local I := 0
Local aLinha := {}

nFile:=FOPEN(cFile,2)
If FERROR()== 0
	 
	nTamArq:=FSEEK(nFile,0,2)	// VerIfica tamanho do arquivo
	FSEEK(nFile,0,0)			// Volta para inicio do arquivo

	For I:= 0 to  nTamArq step 100 // Processo para ir para o final do arquivo	
		xBuffer:=Space(100)
		FREAD(nFile,@xBuffer,100)
			
		cLinha  := StrTran( xBuffer, CRLF,"" )
		//cLinha  := StrTran( cLinha, Chr(10),"" )
		aadd(aLinha, cLinha)		

    Next			

	FClose(nfile)
Endif

nLen := Len(aLinha)
If nLen > 0
	//renomeia arquivo XML para poder criar novamente com o mesmo nome, gravando o novo conteudo sem chr(13)+chr(10)
	cFileOld := Left(cFile, Len(cFile) - 4 ) + "_XMLANTERIOR" + Right(cFile,4)
	If File(cFileOld)
		FErase(cFileOld)
	Endif
	
	If fRename(cFile,cFileOld) <> -1
		nFile  := fCreate(cFile)
	
		If nFile <> -1
			//Aviso("Erro","O Caminho informado nao possui permissão de gravação dos arquivos, escolha um caminho válido ou solicite ao administrador do computador a permissão de gravação neste diretório.",{"OK"},2,"ReadXML")
			
			For I := 1 to nLen
				FWrite(nFile, aLinha[I] )
			
			Next
		
			FClose(nFile)	
			FErase(cFileOld)
		EndIf
	Endif
Endif


Return

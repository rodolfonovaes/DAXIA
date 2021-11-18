#INCLUDE "PROTHEUS.CH"
#Include "RPTDEF.CH" 
#include 'TOTVS.CH'
#include 'FWPRINTSETUP.CH'
#INCLUDE "RWMAKE.CH"
#INCLUDE "topconn.ch"
#INCLUDE "ap5mail.ch"
#Include "Colors.ch"

/*/                                                           
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ TIBCOB   ³Descri‡ão³ Imprime boleto   - Oswaldo Leite      ³±±
±±³                                 atraves de template de cobrancas      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function TIBCOB (cBorDe, cPrefDe, cTitDe, cCliDe, cLojaDe, cCodBco, lPrimTit) 
Local lRet := U_TIBSF1(.F.)
Private lTib14 := lPrimTit, lTib12 := .F., cTib01 := '', cTib02 := '', cTib03 := '', cTib04 := '', cTib05 := '', cTib06 := '', cTib07 := '', cTib08 := '', cTib09 := '', cTib10 := '', cTib11 := ''
Private cPDFGer  := GetNewPar("ES_PDFGER","laybol")

If lRet
	cTib01 := cBorDe//BORDERO DE
	cTib02 := cBorDe//BORDERO ATE
	
	cTib03 := cPrefDe//PREF DE
	cTib04 := cPrefDe//PREF ATE
	
	cTib05 := cTitDe//TIT DE
	cTib06 := cTitDe//TIT ATE
	
	cTib07 := cCliDe//CLI DE
	cTib08 := cLojaDe//loja de
	
	cTib09 := cCliDe//CLI ATE
	cTib10 := cLojaDe//loja ate
	cTib11 := cCodBco//COD BANCO
	DbselectArea("SE1")
	DbSetOrder(1)
	Processa({|lEnd|SAFBO()})//MontaRel
EndIf

Return
/*/                                                           
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ TIBSF1   ³Descri‡ão³ Imprime boleto SAFRA  - Oswaldo Leite ³±±
±±³                                  imprime pdf do boleto                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function TIBSF1(lPorMenu)
Local lRet := .F.
Local nOpc := 0
Local aHardLock  := {}  //Lista de hardlocks liberados para uso
Local aCNPJLib   := {}  //Lista de cnpjs liberados para uso

Private cLayout := ''
PRIVATE Exec    := .F.
Private cCaminhoPDFs := ''   
Private cPDFGer  := GetNewPar("ES_PDFGER","laybol")  //ajustado para utilizar em cloud, o conteudo deve ser C:\Boletos  Private cPDFGer  := "\SYSTEM\" + GetNewPar("ES_PDFGER","laybol")
Private lTib14 := .F., lTib12 := .T., cTib01 := '', cTib02 := '', cTib03 := '', cTib04 := '', cTib05 := '', cTib06 := '', cTib07 := '', cTib08 := '', cTib09 := '', cTib10 := '', cTib11 := ''
Default lPorMenu := .T.		                
//HardLocks liberados para utilizar a rotina
aAdd(aHardLock, 2100013039)  //TotvsIbirapuera

//CNPJ's liberados para utilizar a rotina
aAdd(aCNPJLib, "        ")  //Empresa TESTE
aAdd(aCNPJLib, "20041743")  //NLMK - Cloud Totvs
aAdd(aCNPJLib, "00610829")  //AVE e SABOR
aAdd(aCNPJLib, "20966789")  //SOC. COM.
aAdd(aCNPJLib, "20490214")  //COM. IMP. MUNDIAL
aAdd(aCNPJLib, "21331902")  //COM. GERAL DE BEBIDAS
aAdd(aCNPJLib, "08604593")  //EUROTRONICS
aAdd(aCNPJLib, "01159496")  //SECUR
aAdd(aCNPJLib, "00845326")  //Grupo WECKERLE - WECKERLE
aAdd(aCNPJLib, "19860927")  //Grupo WECKERLE - LIBUS
aAdd(aCNPJLib, "44412435")  //Grupo Tessin
aAdd(aCNPJLib, "51366185")  //Grupo Tessin
aAdd(aCNPJLib, "44903516")  //Grupo Tessin
aAdd(aCNPJLib, "55131841")  //Grupo Tessin
aAdd(aCNPJLib, "04422405")  //Grupo Tessin
aAdd(aCNPJLib, "14626301")	//MIP FARMA
aAdd(aCNPJLib, "62300066")  //açumel caramelos
aAdd(aCNPJLib, "19760833")     //TIEX
aAdd(aCNPJLib, "18209863")     //TIEX
aAdd(aCNPJLib, "21248667")     //TIEX
aAdd(aCNPJLib, "12187493")     //TIEX
aAdd(aCNPJLib, "18474495")     //TIEX
aAdd(aCNPJLib, "05692186")     //TIEX
aAdd(aCNPJLib, "20307337")     //TIEX
aAdd(aCNPJLib, "09628437")     //TIEX
aAdd(aCNPJLib, "04821800")     //TIEX
aAdd(aCNPJLib, "18466811")     //TIEX
aAdd(aCNPJLib, "12782020")     //TIEX
aAdd(aCNPJLib, "14411194")     //TIEX
aAdd(aCNPJLib, "05018227")     //TIEX
aAdd(aCNPJLib, "20199698")     //TIEX
aAdd(aCNPJLib, "22103098")     //TIEX
aAdd(aCNPJLib, "19879389")     //TIEX
aAdd(aCNPJLib, "20259079")     //TIEX
aAdd(aCNPJLib, "20259079")     //TIEX
aAdd(aCNPJLib, "20259079")     //TIEX
aAdd(aCNPJLib, "61618823")     //TIEX
aAdd(aCNPJLib, "12998292")     //TIEX
aAdd(aCNPJLib, "17026299")     //TIEX
aAdd(aCNPJLib, "06889658")     //TIEX
aAdd(aCNPJLib, "21794838")     //TIEX
aAdd(aCNPJLib, "22062496")     //TIEX
aAdd(aCNPJLib, "43607886")     //TIEX
aAdd(aCNPJLib, "44150910")     //Uniquimica
aAdd(aCNPJLib, "60910023")     //Iraja
aAdd(aCNPJLib, "47103106") //0001-84 - ICA - Telecomunicaçãoes Ltda
aAdd(aCNPJLib, "04163433") //0001-19 - Icatel Telemática Servicos e Comercio Ltda
aAdd(aCNPJLib, "44772937") //0001-50 - Telematica Sistemas Inteligentes Ltda

aAdd(aCNPJLib, "44045565") // CGA 
aAdd(aCNPJLib, "13727162") // tawcoplast 0001-78

aAdd(aCNPJLib, "19464930") //TRIAH
aAdd(aCNPJLib, "04507739") //GRANDPORT
 
aAdd(aCNPJLib, "19769981") //000164    Granport Transporte

aAdd(aCNPJLib, "02505572") //OR BRASIL

aAdd(aCNPJLib, "17212096") // TEPX RECICLAGEM 
aAdd(aCNPJLib, "04374317") //CLODAM DO BRASIL
aAdd(aCNPJLib, "13711720") //CLODAX RECICLAGEM
aAdd(aCNPJLib, "13743249") //KEYENCE  
aAdd(aCNPJLib, "60730512") //KEYENCE  




// Valida autorização de execução
If aScan(aHardLock, LS_GetID()) <= 0  //Verifica o hardlock
	If aScan(aCNPJLib, SubStr(SM0->M0_CGC,1,8)) <= 0  //Verifica o cnpj
		Return lRet
	EndIf
EndIf   

lRet := .T.

If lPorMenu
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica as perguntas selecionadas                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ValidPerg("TIBSTF")
	//
	If !Pergunte("TIBSTF",.T.)
		Return()
	EndIf
	                                   
	cTib01 := MV_PAR01//BORDERO DE
	cTib02 := MV_PAR02//BORDERO ATE
	
	cTib03 := MV_PAR03//PREF DE
	cTib04 := MV_PAR04//PREF ATE
	
	cTib05 := MV_PAR05//TIT DE
	cTib06 := MV_PAR06//TIT ATE
	
	cTib07 := MV_PAR07//CLI DE
	cTib08 := MV_PAR08//loja de
	
	cTib09 := MV_PAR09//CLI ATE
	cTib10 := MV_PAR10//loja ate
	cTib11 := MV_PAR11//COD BANCO

	DbselectArea("SE1")
	DbSetOrder(1)
	Processa({|lEnd|SAFBO()})//MontaRel
Else
	Pergunte("TIBSTF",.f.)
EndIf


Return lRet

//========================================================================================================
Static Function SAFBO()
LOCAL   n := 0, nCOunt := 0, aArqLidos := {}
LOCAL aDadosTit
LOCAL aDadosBanco
LOCAL aDatSacado
Local cOldCli := '', cOldLoja := ''
LOCAL CB_RN_NN     := {}
LOCAL nRec         := 0, cParcNum := ''
LOCAL _nVlrAbat    := 0
LOCAL cParcela	   := "", lTinhaNossoNro := .F.
Local ltemnum      := .f.,lErrMsgSTop := .T., lAlgumTit := .F.
local lPrimeiro := .T.
Local cTimeFiltrado:=''
Local cSEEDif := GetNextAlias()
Local aTitCob	:= {}
Local cSession        := GetPrinterSession()
Local nLocal          := If(GetProfString(cSession, "LOCAL", "SERVER", .T.) == "SERVER", 1, 2)  
Local cMailCopy  	:= ALLTRIM(GetNewPar("ES_MAILCOP",""))
Local cHstcLin	:= ''
Local cExtension    :=  '*.PDF'
Private cPDFPath := ''
Private cPorta      := Space(3)
Private cConta      := Space(10)
Private cAgenc      := Space(10)
Private aTitulos := {}
Private oPrinter := Nil
Private _cNossoNum := '',     lAbortProcesso := .F.
Private lFazANexo := .F.
Private lEnviaEmail  := .F.//usuario pode nao querer anexar no email, mas desejar gerar o PDF para imprimir manualmente depois            
Private oPrinter, cFilePdf := ''
Private cEEConta := '', cEEAgencia := '', cA6Conta := '', cA6Agencia := ''
// o PDF completo dos boletos impressos fic em um diretorio diferernte: GetNewPar("ES_IMPGR")  pois os demais diretorios sao apagados pela rotina de email periodicamente
//cFilePdf := MV_PAR07 +"_" + dtos(Date())+"_"+cHorario

aDadosEmp    := {	AllTrim(SM0->M0_NOMECOM)                                                   ,; //[1]Nome da Empresa
					SM0->M0_ENDCOB                                                              ,; //[2]Endereço
					AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB ,; //[3]Complemento
					"CEP: "+Subs(SM0->M0_CEPCOB,1,5)+"-"+Subs(SM0->M0_CEPCOB,6,3)             ,; //[4]CEP
					"PABX/FAX: "+SM0->M0_TEL                                                    ,; //[5]Telefones
					"C.N.P.J.: "+Subs(SM0->M0_CGC,1,2)+"."+Subs(SM0->M0_CGC,3,3)+"."+          ; //[6]
					Subs(SM0->M0_CGC,6,3)+"/"+Subs(SM0->M0_CGC,9,4)+"-"+                       ; //[6]
					Subs(SM0->M0_CGC,13,2)                                                     ,; //[6]CGC
					"I.E.: "+Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+            ; //[7]
					Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3)                             , ; //[7]
					alltrim(SM0->M0_BAIRCOB)        , ; //[7]
					alltrim(SM0->M0_CIDCOB)+'/'+alltrim(SM0->M0_ESTCOB)  }  //[7]I.E
					
ProcRegua(0)

If !(OnStack("U_SEFATA01") .or. OnStack("U_SEFATA05") .or. OnStack("U_SEFATA03") .or. OnStack("U_SEFATA04"))
	if cTib02 < cTib01
		ALert ("Intervalo de Borderôs inválido!")
		Return()
	endif
	                                 
	if Empty(cTib02) 
		ALert ("Informe Borderô Até !")
		Return()
	endif
EndIf

if cTib04 < cTib03
	ALert ("Intervalo de Prefixos inválido!")
	Return()
endif

if Empty(cTib04) 
	ALert ("Informe Prefixo Até !")
	Return()
endif
                                 

if val(cTib06) < val(cTib05)
	ALert ("Intervalo de Títulos inválido!")
	Return()
endif

if Empty(cTib06) 
	ALert ("Informe Título Até !")
	Return()
endif

if cTib09 < cTib07
	ALert ("Intervalo de Clientes inválido!")
	Return()
endif

if Empty(cTib09) 
	ALert ("Informe Título Até !")
	Return()
endif                    


if Empty(cTib11) 
	ALert ("Informe o Código do Banco SAFRA, SANTANDER,HSBC, CEF(CAIXA ECONOMICA), ITAU, SANTANDER ou BANCO DO BRASIL ! Não é permitido imprimir os boletos de todos os bancos simultâneamente!")
	Return()            
endif

if (cTib11 <> '422') .and. (cTib11 <> '001') .and. (cTib11 <> '033') .and. (cTib11 <> '399').and. (cTib11 <> '104').and. (cTib11 <> '237').and. (cTib11 <> '341') .and. (cTib11 <> '633') .and. (cTib11 <> '021')
	ALert ("Informe o Código do Banco Safra, Santander, HSBC , CEF(CAIXA ECONOMICA), ITAU, SANTANDER, Rendimentos, Banestes ou Banco do Brasil!")
	Return()            
endif

If OnStack("U_SEFATA01") .or. OnStack("U_SEFATA05") .or. OnStack("U_SEFATA03") .or. OnStack("U_SEFATA04")
	
	SE1->(DBSETORDER(1))
	SE1->(dbgotop()) 
	
	cSQL:=" SELECT R_E_C_N_O_ SE1REC FROM " + RETSQLTAB("SE1") 

	cSQL+=" WHERE " + RETSQLCOND("SE1") + " AND E1_PREFIXO >=" + VALTOSQL(cTib03) + " AND E1_NUM >= " +  VALTOSQL(cTib05) 
	cSQL+=" AND E1_PREFIXO <=" + VALTOSQL(cTib04) + " AND E1_NUM <= " +  VALTOSQL(cTib06) 
	cSQL+=" AND E1_CLIENTE >=" + VALTOSQL(cTib07)+ " AND E1_CLIENTE <= " + VALTOSQL(cTib09) 
	cSQL+=" AND E1_PARCELA = '" + cParSecSE1 + "'  "                                                                 

	cSQL+=" AND E1_SALDO > 0 AND D_E_L_E_T_ <> '*'  and E1_PORTADO = '" + cTib11 + "' and E1_AGEDEP <> ''  ORDER BY E1_CLIENTE, E1_LOJA "
Else
	LimpaDir()
	
	SE1->(DBSETORDER(1))
	SE1->(dbgotop()) 
	
	cSQL:=" SELECT R_E_C_N_O_ SE1REC FROM " + RETSQLTAB("SE1") 

	cSQL+=" WHERE " + RETSQLCOND("SE1") + " AND E1_PREFIXO >=" + VALTOSQL(cTib03) + " AND E1_NUM >= " +  VALTOSQL(cTib05) + " AND E1_NUMBOR >= " + VALTOSQL(cTib01)
	cSQL+=" AND E1_PREFIXO <=" + VALTOSQL(cTib04) + " AND E1_NUM <= " +  VALTOSQL(cTib06) + " AND E1_NUMBOR <= " + VALTOSQL(cTib02)
	cSQL+=" AND E1_CLIENTE >=" + VALTOSQL(cTib07)+ " AND E1_CLIENTE <= " + VALTOSQL(cTib09) 
	                                                                 

	cSQL+=" AND E1_SALDO > 0 AND D_E_L_E_T_ <> '*'  and E1_PORTADO = '" + cTib11 + "' and E1_AGEDEP <> ''  ORDER BY E1_CLIENTE, E1_LOJA "
EndIf

cSql := ChangeQuery(cSql)

If Select ("TRBBOL")   > 0 
    dbSelectArea( "TRBBOL" )   
    dbCloseArea() 
EndIf 

DbUseArea(.T.,"TOPCONN",TCGenQry(,,cSQL),'TRBBOL',.F.,.T.)
IF TRBBOL->(EOF() .AND. BOF())
	SE1->(DBGOBOTTOM())
ELSE
    SE1->(DBGOTO(TRBBOL->SE1REC))
ENDIF 

if cTib11 =='422'          
	cLayOut := cPDFGer + "\BOL422.JPG"
	
	If GetRemoteType() == 2 // REMOTE_LINUX 
		cLayOut := strtran(cLayOut,"\","/",1,20)
	EndIf
endif

if cTib11 == '001'
	cLayOut := cPDFGer + "\BOL001.JPG"
	
	If GetRemoteType() == 2 // REMOTE_LINUX 
		cLayOut := strtran(cLayOut,"\","/",1,20)
	EndIf
endif

if cTib11  == '033'
	cLayOut := cPDFGer + "\BOL033.JPG"

	If GetRemoteType() == 2 // REMOTE_LINUX 
		cLayOut := strtran(cLayOut,"\","/",1,20)
	EndIf
endif

if cTib11  == '399'
	cLayOut := cPDFGer + "\BOL399.JPG"

	If GetRemoteType() == 2 // REMOTE_LINUX 
		cLayOut := strtran(cLayOut,"\","/",1,20)
	EndIf
endif

if cTib11  == '104'
	cLayOut := cPDFGer + "\BOL104.JPG"

	If GetRemoteType() == 2 // REMOTE_LINUX 
		cLayOut := strtran(cLayOut,"\","/",1,20)
	EndIf
endif

if cTib11  == '341'
	cLayOut := cPDFGer + "\BOL341.JPG"

	If GetRemoteType() == 2 // REMOTE_LINUX 
		cLayOut := strtran(cLayOut,"\","/",1,20)
	EndIf
endif

if cTib11  == '237'
	cLayOut := cPDFGer + "\BOL237.JPG"

	If GetRemoteType() == 2 // REMOTE_LINUX 
		cLayOut := strtran(cLayOut,"\","/",1,20)
	EndIf
endif

if cTib11  == '633'
	cLayOut := cPDFGer + "\BOL633.JPG"

	If GetRemoteType() == 2 // REMOTE_LINUX 
		cLayOut := strtran(cLayOut,"\","/",1,20)
	EndIf
endif

if cTib11  == '021'
	cLayOut := cPDFGer + "\BOL021.JPG"

	If GetRemoteType() == 2 // REMOTE_LINUX 
		cLayOut := strtran(cLayOut,"\","/",1,20)
	EndIf
endif


cFilePdf:= ""                              
cPDFGer := cPDFGer + "\"
					    
If GetRemoteType() == 2 // REMOTE_LINUX 
	cPDFGer := strtran(cPDFGer,"\","/",1,20)
EndIf
	
cTimeFiltrado:= Time()  	
cTimeFiltrado:= STRTRAN(cTimeFiltrado,":","",1,5)

 
If IsInCallStack("U_MFIN001")
	cPDFPath := GetNewPar("ES_PAHPDF","PDF_cobranca")//GetPvProfString(GetEnvServer(), 'RootPath', 'ERROR', GetADV97()) + GetPvProfString(GetEnvServer(), 'StartPath', 'ERROR', GetADV97()) +;
	          //GetNewPar("ES_PAHTML","email_cobranca") + "\" + GetNewPar("ES_PAHPDF","PDF_cobranca") + "\"     
Else
            
	cPDFPath := cPDFGer                    
Endif           

         
If GetRemoteType() == 2 // REMOTE_LINUX 
	cPDFPath := strtran(cPDFPath,"\","/",1,20)
EndIf  

If lTib12
  //Ğ	oPrinter:Setup()
EndIf
        
cPDFPath  := Alltrim(cGetFile ('Arquivo' + cExtension + '|' + cExtension +'|' , 'Selecione a pasta para gravação.', 1, '', .T., GETF_LOCALHARD+GETF_RETDIRECTORY,.F.))

DO WHILE !TRBBOL->(EOF())
		SE1->(DBGOTO(TRBBOL->SE1REC))
		cFilePdf :=	"Boletos_"+dtos(dDataBase)+"_"+SE1->E1_NUM

		oPrinter := Nil      
		If IsInCallStack("U_MFIN001")     
			//oPrinter := FWMSPrinter():New (cFilePdf, IMP_PDF, .F., cPDFPath/*cCaminhosPDF*/, .T.,,,,.F.,,,.F.,)   
			oPrinter := FWMSPrinter():New (cFilePdf, IMP_PDF, .F., cPDFPath, .T., .F., , , .T., .T., , .F.)

			oPrinter:cPathPDF := cPDFPath //cPDFGer//cPathPDF	
		Else


			oPrinter := FWMSPrinter():New  (cFilePdf, IMP_PDF, .F., /*cCaminhosPDF*/, .T.,,,,.T.,,,.F.,)  

			//oPrinter:Setup()  
		Endif
						
		oPrinter:SetPortrait()
		oPrinter:SetPaperSize(9)
		oPrinter:SetDevice(IMP_PDF)

		
		_cNossoNum := ''

		cPorta := SE1->E1_PORTADO 
		cAgenc := SE1->E1_AGEDEP
		cConta := SE1->E1_CONTA
		
		
		BeginSql Alias cSEEDif
	
	       SELECT SEE.* FROM %table:SEE% SEE
	       WHERE SEE.EE_FILIAL  = %xFilial:SEE%
	             AND SEE.%NotDel%

	              AND SEE.EE_CODIGO   = %Exp:(cPorta)%
	              AND SEE.EE_AGENCIA  = %Exp:(cAgenc)%
	              AND SEE.EE_CONTA   = %Exp:(cConta)%
	              AND SEE.EE_CODCART     <> %Exp:('')%  //para SEE(Pgto) com mesmo codigo, agencia e conta do SEE(Recbto) ... por convencao, diferenciamos desta forma: Pagto náo tem carteira na SEE, Rebto tem campo carteira informado na SEE
	            
		EndSql

		If (cSEEDif)->(!Eof())     

			DbSelectArea("SEE")
			SEE->(DbGoTo(  (cSEEDif)->(R_E_C_N_O_)  ))			
		Else
			DbSelectArea("SEE")
			DbSetOrder(1)    
			DbSeek(xFilial("SEE")+cPorta+cAgenc+cConta  ,.T.)// +cSubcto   TESTE() //
		EndIf
		
		(cSEEDif)->(DbCloseArea())

		EETabulacaoBanco()
		
		if cTib11 == '422'

			_cNossoNum := SUBSTR(SE1->E1_NUMBCO,1,8)
			lTinhaNossoNro := .T.    
			
			if Empty(_cNossoNum)//se ainda nao gerou nosso nro
				_cNossoNum :=SEE->EE_FAXATU   
				lTinhaNossoNro := .F.
				if len(alltrim(_cNossoNum)) == 0  .OR. _cNossoNum == '00000000'
				   if lErrMsgSTop
		  			   Msgstop("Atenção...  Faixa de nosso numero incorreta para o boleto "+SE1->E1_NUM+", por favor verifique","Verifique")
					   lErrMsgSTop:= .F.
				   endif
	
				   TRBBOL->(DBSKIP()) 
				   LOOP
				Endif                    
				
			Endif                    
	        
		endif

		if cTib11 == '001'

			if Len(Alltrim(SEE->EE_CODEMP)) == 7
				_cNossoNum := Substr(ALLTRIM(SE1->E1_NUMBCO),1,10)
				_cNossoNum := STRZERO(Val(_cNossoNum),10)
				_cNossoNum := AllTrim(_cNossoNum)
				lTinhaNossoNro := .T.    
				
				if Empty(_cNossoNum) .or. _cNossoNum == '0000000000'//se ainda nao gerou nosso nro
					_cNossoNum :=SEE->EE_FAXATU   
			  		_cNossoNum := AllTrim(_cNossoNum)
					lTinhaNossoNro := .F.
					if len(alltrim(_cNossoNum)) == 0  .OR. _cNossoNum == '0000000000'  .or. Len( _cNossoNum ) != 10
					   if lErrMsgSTop
			  			   Msgstop("Atenção...  Faixa de nosso numero incorreta para o boleto "+SE1->E1_NUM+", por favor verifique","Verifique")
						   lErrMsgSTop:= .F.
					   endif
		
					   TRBBOL->(DBSKIP()) 
					   LOOP
					Endif                    
					
				Endif                               
			endif
			
			if Len(Alltrim(SEE->EE_CODEMP)) == 6
				_cNossoNum := Substr(ALLTRIM(SE1->E1_NUMBCO),1,5)
				_cNossoNum := STRZERO(Val(_cNossoNum),5)
				_cNossoNum := AllTrim(_cNossoNum)
				lTinhaNossoNro := .T.    
				
				if Empty(_cNossoNum) .or. _cNossoNum == '00000'//se ainda nao gerou nosso nro
					_cNossoNum :=SEE->EE_FAXATU   
			  		_cNossoNum := AllTrim(_cNossoNum)
					lTinhaNossoNro := .F.
					if len(alltrim(_cNossoNum)) == 0  .OR. _cNossoNum == '00000'  .or. Len( _cNossoNum ) != 5
					   if lErrMsgSTop
			  			   Msgstop("Atenção...  Faixa de nosso numero incorreta para o boleto "+SE1->E1_NUM+", por favor verifique","Verifique")
						   lErrMsgSTop:= .F.
					   endif
		
					   TRBBOL->(DBSKIP()) 
					   LOOP
					Endif                    
					
				Endif                               
			endif


			if Len(Alltrim(SEE->EE_CODEMP)) != 6  .and. Len(Alltrim(SEE->EE_CODEMP)) != 7
			   Msgstop("Atenção...  Este programa trabalha com Convênio de 6 e 7 dígitos! favor, verificar o seu convênio! "+SE1->E1_NUM,"Verifique")
			   lErrMsgSTop:= .F.
			endif
		endif//fim do BB

		if cTib11 == '341'
			_cNossoNum :=SUBSTR(SE1->E1_NUMBCO,1,8)//pois codigo gravado na numbco contem mais dados alem do sequencial de 8 digitos
	  		_cNossoNum := AllTrim(_cNossoNum)
			lTinhaNossoNro := .T.    
		
			if Empty(_cNossoNum) .OR. _cNossoNum == '00000000'//se ainda nao gerou nosso nro
				_cNossoNum :=SEE->EE_FAXATU  
		  		_cNossoNum := AllTrim(_cNossoNum) 
				lTinhaNossoNro := .F.
				if len(alltrim(_cNossoNum)) == 0  .OR. _cNossoNum == '00000000'
				   if lErrMsgSTop
		  			   Msgstop("Atenção...  Faixa de nosso numero incorreta para o boleto "+SE1->E1_NUM+", por favor verifique","Verifique")
					   lErrMsgSTop:= .F.
				   endif
	
				   TRBBOL->(DBSKIP()) 
				   LOOP
				Endif                    
			Endif                    

        endif
             
        If cTib11 == '021'
			_cNossoNum := SUBSTR(SE1->E1_NUMBCO,1,8)
	  		_cNossoNum := AllTrim(_cNossoNum)
			lTinhaNossoNro := .T.    
			
			if Empty(_cNossoNum)  .OR. _cNossoNum == '00000000'//se ainda nao gerou nosso nro
				_cNossoNum :=SEE->EE_FAXATU   
		  		_cNossoNum := AllTrim(_cNossoNum)
				lTinhaNossoNro := .F.
				if len(alltrim(_cNossoNum)) == 0  .OR. _cNossoNum == '00000000'
				   if lErrMsgSTop
		  			   Msgstop("Atenção...  Faixa de nosso numero incorreta para o boleto "+SE1->E1_NUM+", por favor verifique","Verifique")
					   lErrMsgSTop:= .F.
				   endif
	
				   TRBBOL->(DBSKIP()) 
				   LOOP
				Endif                    
				
			Endif                    
		Endif
		
		if cTib11 == '033'

			_cNossoNum := SUBSTR(SE1->E1_NUMBCO,1,7)
	  		_cNossoNum := AllTrim(_cNossoNum)
			lTinhaNossoNro := .T.    
			
			if Empty(_cNossoNum)  .OR. _cNossoNum == '0000000'//se ainda nao gerou nosso nro
				_cNossoNum :=SEE->EE_FAXATU   
		  		_cNossoNum := AllTrim(_cNossoNum)
				lTinhaNossoNro := .F.
				if len(alltrim(_cNossoNum)) == 0  .OR. _cNossoNum == '0000000'
				   if lErrMsgSTop
		  			   Msgstop("Atenção...  Faixa de nosso numero incorreta para o boleto "+SE1->E1_NUM+", por favor verifique","Verifique")
					   lErrMsgSTop:= .F.
				   endif
	
				   TRBBOL->(DBSKIP()) 
				   LOOP
				Endif                    
				
			Endif                    
	        
		endif

		if cTib11 == '399'   //HSBC

			_cNossoNum := Substr(ALLTRIM(SE1->E1_NUMBCO),1,13)
			_cNossoNum := STRZERO(Val(_cNossoNum),13)
			_cNossoNum := AllTrim(_cNossoNum)
			lTinhaNossoNro := .T.    
			
			if Empty(_cNossoNum) .or. _cNossoNum == '0000000000000'//se ainda nao gerou nosso nro
				_cNossoNum := STRZERO(Val(SEE->EE_FAXATU) ,13)         //pois SEE->EE_FAXATU só tinha 12 posições no padrao
		  		_cNossoNum := AllTrim(_cNossoNum)
				lTinhaNossoNro := .F.
				if len(alltrim(_cNossoNum)) == 0  .OR. _cNossoNum == '0000000000000'  .or. Len( _cNossoNum ) != 13
				   if lErrMsgSTop
		  			   Msgstop("Atenção...  Faixa de nosso numero incorreta para o boleto "+SE1->E1_NUM+", por favor verifique","Verifique")
					   lErrMsgSTop:= .F.
				   endif
	
				   TRBBOL->(DBSKIP()) 
				   LOOP
				Endif                    
				
			Endif                    
	                           
		endif//fim do BB
                                                             
   		if cTib11 == '237'

			_cNossoNum := SUBSTR(SE1->E1_NUMBCO,1,11)
	  		_cNossoNum := AllTrim(_cNossoNum)
			lTinhaNossoNro := .T.    
			
			if Empty(_cNossoNum)  .OR. _cNossoNum == '00000000000'//se ainda nao gerou nosso nro
				_cNossoNum :=SEE->EE_FAXATU   
		  		_cNossoNum := AllTrim(_cNossoNum)
				lTinhaNossoNro := .F.
				if len(alltrim(_cNossoNum)) == 0  .OR. _cNossoNum == '00000000000'
				   if lErrMsgSTop
		  			   Msgstop("Atenção...  Faixa de nosso numero incorreta para o boleto "+SE1->E1_NUM+", por favor verifique","Verifique")
					   lErrMsgSTop:= .F.
				   endif
	
				   TRBBOL->(DBSKIP()) 
				   LOOP
				Endif                    
				
			Endif                    
	        
		endif

   		if cTib11 == '633' //banco rendimentos Jonas Abrigo

			_cNossoNum := SUBSTR(SE1->E1_NUMBCO,1,12)
	  		_cNossoNum := AllTrim(_cNossoNum)
			lTinhaNossoNro := .T.    
			
			if Empty(_cNossoNum)  .OR. _cNossoNum == '000000000000'//se ainda nao gerou nosso nro
				_cNossoNum :=SEE->EE_FAXATU   
		  		_cNossoNum := AllTrim(_cNossoNum)
				lTinhaNossoNro := .F.
				if len(alltrim(_cNossoNum)) == 0  .OR. _cNossoNum == '000000000000'
				   if lErrMsgSTop
		  			   Msgstop("Atenção...  Faixa de nosso numero incorreta para o boleto "+SE1->E1_NUM+", por favor verifique","Verifique")
					   lErrMsgSTop:= .F.
				   endif
	
				   TRBBOL->(DBSKIP()) 
				   LOOP
				Endif                    
				
			Endif                    
	        
		endif


		if cTib11 == '104' // caixa economica federal   - CEF
			/*      
			
			http://downloads.caixa.gov.br/_arquivos/cobranca_caixa/manuaissicob/ESP_COD_BARRAS_SIGCB_COBRANCA_CAIXA.pdf
			
            XYNNNNNNNNNNNNNNN(17 digitos)
			XYNNNNNNNNNNNNNNN-D (co o DV dá dezoito)
			x = 1      (default,indica cobr.registrada)
			y = 4      (default) 	                      	  
			
			obs.:mas no banco gravamos o nro com o digito verificador
			
			atenção: para CEF a conta bancária deve ter 6 digitos e o intervalo de numeração da SEE deve ser de
			14000000000000001  até 14999999999999999
				*/
			
			_cNossoNum := Substr(ALLTRIM(SE1->E1_NUMBCO),1,17)
			_cNossoNum := STRZERO(Val(_cNossoNum),17)
			_cNossoNum := AllTrim(_cNossoNum)
			lTinhaNossoNro := .T.    
			
			if Empty(_cNossoNum) .or. _cNossoNum == '00000000000000000'//se ainda nao gerou nosso nro
				_cNossoNum :=SEE->EE_FAXATU   
		  		_cNossoNum := AllTrim(_cNossoNum)
				lTinhaNossoNro := .F.
				if len(alltrim(_cNossoNum)) == 0  .OR. _cNossoNum == '00000000000000000'  .or. Len( _cNossoNum ) != 17
				   if lErrMsgSTop
		  			   Msgstop("Atenção...  Faixa de nosso numero incorreta para o boleto "+SE1->E1_NUM+", por favor verifique","Verifique")
					   lErrMsgSTop:= .F.
				   endif
	
				   TRBBOL->(DBSKIP()) 
				   LOOP
				Endif                    
				
			Endif                    
	                           
		endif//fim do BB
        
		Begin Transaction 
		    
		if !lTinhaNossoNro
			SEE->(RecLock("SEE",.f.))   
			
			if cTib11 == '422'
				SEE->EE_FAXATU:= STRZERO(VAL(_cNossoNum)+1,8)
			endif
			
			if cTib11 == '001'
				if Len(Alltrim(SEE->EE_CODEMP)) == 7
					SEE->EE_FAXATU:= STRZERO(VAL(_cNossoNum)+1,10)
				ELSE         
					SEE->EE_FAXATU:= STRZERO(VAL(_cNossoNum)+1,5)
				ENDIF
			endif              
			
			if cTib11 == '399'     //HSBC
				//O CERTO SERIA GRAVAR COM 13 CARACTERES:  SEE->EE_FAXATU:= STRZERO(VAL(_cNossoNum)+1,13)//
				//MAS NA BASE DO SILVINO  o campo tem só 12 caractreres...então fazemos abaixo um STRZERO de 12
				SEE->EE_FAXATU:= STRZERO(VAL(_cNossoNum)+1,12)//
			endif  
			
			if cTib11 == '033'
				SEE->EE_FAXATU:= STRZERO(VAL(_cNossoNum)+1,7)
			endif
				
			if cTib11 == '104'//CEF    
			    cParcNum := substr(_cNossoNum,3,15)
				SEE->EE_FAXATU:=  "14" + STRZERO(VAL(cParcNum)+1,15)
			endif                
		 
			if cTib11 == '021'//BANESTES    
				SEE->EE_FAXATU:= STRZERO(VAL(_cNossoNum)+1,8)
			endif	
			
			if cTib11 == '341'//ITAU    
				SEE->EE_FAXATU:= STRZERO(VAL(_cNossoNum)+1,8)
			endif	
			
			if cTib11 == '237'//BRADECSO    
				SEE->EE_FAXATU:= STRZERO(VAL(_cNossoNum)+1,11)
			endif	
			
			if cTib11 == '633'//RENDIMENTOS    
				SEE->EE_FAXATU:= STRZERO(VAL(_cNossoNum)+1,12)
			endif	
			
			SEE->(MsUnlock())
	    endif
		    

		//Posiciona o SA1 (Cliente)
		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA,.T.)
		
		//Posiciona o SA6 (Bancos)
		DbSelectArea("SA6")
		DbSetOrder(1)
		DbSeek(xFilial("SA6")+SE1->(E1_PORTADO+E1_AGEDEP+E1_CONTA),.T.)   

		
		//
		DO CASE
			CASE ( SE1->E1_PARCELA == "A" .or. Val(SE1->E1_PARCELA) == 1 )
				cParcela := "1"
			CASE (SE1->E1_PARCELA == "B".or. Val(SE1->E1_PARCELA) == 2 )
				cParcela := "2"
			CASE (SE1->E1_PARCELA == "C" .or. Val(SE1->E1_PARCELA) == 3 )
				cParcela := "3"
			CASE (SE1->E1_PARCELA == "D" .or. Val(SE1->E1_PARCELA) == 4 )
				cParcela := "4"
			CASE (SE1->E1_PARCELA == "E"  .or. Val(SE1->E1_PARCELA) == 5 )
				cParcela := "5"
			CASE (SE1->E1_PARCELA == "F" .or. Val(SE1->E1_PARCELA) == 6 )
				cParcela := "6"
			CASE (SE1->E1_PARCELA == "G"  .or. Val(SE1->E1_PARCELA) == 7 )
				cParcela := "7"
			CASE (SE1->E1_PARCELA == "H" .or. Val(SE1->E1_PARCELA) == 8 )
				cParcela := "8"
			CASE (SE1->E1_PARCELA == "I" .or. Val(SE1->E1_PARCELA) == 9 )
				cParcela := "9"
			OTHERWISE
				cParcela := "0"
		ENDCASE
		
		//montamos um único pdf com todos os titulos
		aTitulos := { ;
		                 SE1->E1_NUM,     ;
		                 SE1->E1_PREFIXO,  ;
		                 cParcela, ; //SE1->E1_PARCELA,   ;
		                 SE1->E1_TIPO,      ;
		                 SE1->E1_CLIENTE,  ;
		                 SE1->E1_LOJA,    ;
		                 '',             ;
		                 SE1->E1_PORTADO,;
		                 SE1->E1_AGEDEP  ;
						}                   
						
						
		
		cHstcLin := U_TIBSF2 (aTitulos,cTib02,MV_PAR12)  
		aTitCob := {}
		aAdd(aTitCob, {	SE1->E1_NUM,;
						SE1->E1_PREFIXO,;
						SE1->E1_PARCELA,;
						SE1->E1_PORTADO,;
						SEE->EE_AGENCIA,;
						SEE->EE_CONTA,;						
						SE1->E1_VENCTO,;
						SE1->E1_VALOR,;
						cHstcLin,; //linha digitavel 
						_cNossoNum,; // nosso numero
						SE1->E1_EMISSAO})		
		lAlgumTit := .T.
		
		End Transaction 			
		
        if lAbortProcesso //se houve erro de conexão ao servidor de email
			TRBBOL->(DBCLOSEAREA())
			return
		endif	

		If lTib12
			oPrinter:lviewpdf := .T.
		EndIf
		If IsInCallStack("U_MFIN001") 
			oPrinter:Print()
		Else
			oPrinter:Preview()  
		EndIf	

		//Rodolfo - Inclusao de função para enviar email com o boleto
		SendMail(ALLTRIM(SA1->A1_EMAIL) + "," + cMailCopy  , SA1->A1_NOME , cPDFPath + cFilePdf + ".pdf"  , cFilePdf + ".pdf", aTitCob)
				
		FreeObj(oPrinter)
		oPrinter := Nil
		
    IncProc()
	TRBBOL->(dbSkip())

EndDo   

if !lAlgumTit    

	If OnStack("U_SEFATA01") .or. OnStack("U_SEFATA05") .or. OnStack("U_SEFATA03") .or. OnStack("U_SEFATA04")
		Alert ("Não foi possível imprimir qualquer Boleto. Verifique se os títulos estão de acordo com os filtros em tela e se pertencem ao banco filtrado! " + Chr(13) + CHr(10) )
	Else
		Alert ("Não foi possível imprimir qualquer Boleto. Verifique se os títulos\borderôs estão de acordo com os filtros em tela e se pertencem ao banco filtrado! " + Chr(13) + CHr(10) )
	EndIf
	
else

endif	



TRBBOL->(DBCLOSEAREA())                          
          
return                                          



//
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ValidPerg   ³Descri‡ão³Verifica o Arquivo Sx1, criando as  ³±±
±±³          ³             ³         ³Perguntas se necessario.            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ValidPerg(CPERG)

PutSx1( cPerg,     ; //Grupo de perguntas SX1
         "01",     ; //seq do parâmetro 
         "Borderô",;//descr pergunta
         " ", ;//descr pergunta
         " ", ;//descr pergunta
         "MV_CH01" ,;  //variável auxiliar
         "C",    ;    //tipo
         6 ,     ;    //tamanho
         0,      ;    //decimal
         0,      ;    //qual opção de combo é padrão
         "G",    ;    //campo será GET-G ou COMBO-C
         "", ; //Valid
         "",      ;         //F3
         "",            ;      //código do grupo SXG
         ,              ;      //Pyme
         "MV_PAR01",    ;      //nome do parâmetro
         "",            ;  //descrição combo
         "",;//descrição combo
         "",;//descrição combo
         "",;    //conteúdo padrão
         "",;//descrição combo
         "",;//descrição combo
         "",;//descrição combo
         "",; //daqui pra baixo é tudo Help
         "",     "",     "",      "",      "",      "",      "",        "" )  
                  

PutSx1( cPerg,     ; //Grupo de perguntas SX1
         "02",     ; //seq do parâmetro 
         "Borderô",;//descr pergunta
         " ", ;//descr pergunta
         " ", ;//descr pergunta
         "MV_CH02" ,;  //variável auxiliar
         "C",    ;    //tipo
         6 ,     ;    //tamanho
         0,      ;    //decimal
         0,      ;    //qual opção de combo é padrão
         "G",    ;    //campo será GET-G ou COMBO-C
         "", ; //Valid
         "",      ;         //F3
         "",            ;      //código do grupo SXG
         ,              ;      //Pyme
         "MV_PAR02",    ;      //nome do parâmetro
         "",            ;  //descrição combo
         "",;//descrição combo
         "",;//descrição combo
         "",;    //conteúdo padrão
         "",;//descrição combo
         "",;//descrição combo
         "",;//descrição combo
         "",; //daqui pra baixo é tudo Help
         "",     "",     "",      "",      "",      "",      "",        "" )  
                  
PutSx1( cPerg,     ; //Grupo de perguntas SX1
         "03",     ; //seq do parâmetro 
         "Prefixo De",;//descr pergunta
         " ", ;//descr pergunta
         " ", ;//descr pergunta
         "MV_CH03" ,;  //variável auxiliar
         "C",    ;    //tipo
         3 ,     ;    //tamanho
         0,      ;    //decimal
         0,      ;    //qual opção de combo é padrão
         "G",    ;    //campo será GET-G ou COMBO-C
         "", ; //Valid
         "",      ;         //F3
         "",            ;      //código do grupo SXG
         ,              ;      //Pyme
         "MV_PAR03",    ;      //nome do parâmetro
         "",            ;  //descrição combo
         "",;//descrição combo
         "",;//descrição combo
         "",;    //conteúdo padrão
         "",;//descrição combo
         "",;//descrição combo
         "",;//descrição combo
         "",; //daqui pra baixo é tudo Help
         "",          "",          "",          "",          "",          "",          "",       "" )

PutSx1( cPerg,     ; //Grupo de perguntas SX1
         "04",     ; //seq do parâmetro 
         "Prefixo Até",;//descr pergunta
         " ", ;//descr pergunta
         " ", ;//descr pergunta
         "MV_CH04" ,;  //variável auxiliar
         "C",    ;    //tipo
         3 ,     ;    //tamanho
         0,      ;    //decimal
         0,      ;    //qual opção de combo é padrão
         "G",    ;    //campo será GET-G ou COMBO-C
         "", ; //Valid
         "",      ;         //F3
         "",            ;      //código do grupo SXG
         ,              ;      //Pyme
         "MV_PAR04",    ;      //nome do parâmetro
         "",            ;  //descrição combo
         "",;//descrição combo
         "",;//descrição combo
         "",;    //conteúdo padrão
         "",;//descrição combo
         "",;//descrição combo
         "",;//descrição combo
         "",; //daqui pra baixo é tudo Help
         "",          "",          "",          "",          "",          "",          "",       "" )
                  
PutSx1( cPerg,     ; //Grupo de perguntas SX1
         "05",     ; //seq do parâmetro 
         "Titulo De",;//descr pergunta
         " ", ;//descr pergunta
         " ", ;//descr pergunta
         "MV_CH05" ,;  //variável auxiliar
         "C",    ;    //tipo
         9 ,     ;    //tamanho
         0,      ;    //decimal
         0,      ;    //qual opção de combo é padrão
         "G",    ;    //campo será GET-G ou COMBO-C
         "", ; //Valid
         "",      ;         //F3
         "",            ;      //código do grupo SXG
         ,              ;      //Pyme
         "MV_PAR05",    ;      //nome do parâmetro
         "",            ;  //descrição combo
         "",;//descrição combo
         "",;//descrição combo
         "",;    //conteúdo padrão
         "",;//descrição combo
         "",;//descrição combo
         "",;//descrição combo
         "",; //daqui pra baixo é tudo Help
         "",          "",          "",          "",          "",          "",          "",       "" )

PutSx1( cPerg,     ; //Grupo de perguntas SX1
         "06",     ; //seq do parâmetro 
         "Titulo Até",;//descr pergunta
         " ", ;//descr pergunta
         " ", ;//descr pergunta
         "MV_CH06" ,;  //variável auxiliar
         "C",    ;    //tipo
         9 ,     ;    //tamanho
         0,      ;    //decimal
         0,      ;    //qual opção de combo é padrão
         "G",    ;    //campo será GET-G ou COMBO-C
         "", ; //Valid
         "",      ;         //F3
         "",            ;      //código do grupo SXG
         ,              ;      //Pyme
         "MV_PAR06",    ;      //nome do parâmetro
         "",            ;  //descrição combo
         "",;//descrição combo
         "",;//descrição combo
         "",;    //conteúdo padrão
         "",;//descrição combo
         "",;//descrição combo
         "",;//descrição combo
         "",; //daqui pra baixo é tudo Help
         "",          "",          "",          "",          "",          "",          "",       "" )
                 
         
PutSx1( cPerg,     ; //Grupo de perguntas SX1
         "07",     ; //seq do parâmetro 
         "Cliente De",;//descr pergunta
         " ", ;//descr pergunta
         " ", ;//descr pergunta
         "MV_CH07" ,;  //variável auxiliar
         "C",    ;    //tipo
         6 ,     ;    //tamanho
         0,      ;    //decimal
         0,      ;    //qual opção de combo é padrão
         "G",    ;    //campo será GET-G ou COMBO-C
         "", ; //Valid
         "SA1",      ;         //F3
         "",            ;      //código do grupo SXG
         ,              ;      //Pyme
         "MV_PAR07",    ;      //nome do parâmetro
         "",            ;  //descrição combo
         "",;//descrição combo
         "",;//descrição combo
         "",;    //conteúdo padrão
         "",;//descrição combo
         "",;//descrição combo
         "",;//descrição combo
         "",; //daqui pra baixo é tudo Help
         "",     "",     "",      "",      "",      "",      "",        "" )  
         

PutSx1( cPerg,     ; //Grupo de perguntas SX1
         "08",     ; //seq do parâmetro 
         "Loja",;//descr pergunta
         " ", ;//descr pergunta
         " ", ;//descr pergunta
         "MV_CH08" ,;  //variável auxiliar
         "C",    ;    //tipo
         2 ,     ;    //tamanho
         0,      ;    //decimal
         0,      ;    //qual opção de combo é padrão
         "G",    ;    //campo será GET-G ou COMBO-C
         "", ; //Valid
         "",      ;         //F3
         "",            ;      //código do grupo SXG
         ,              ;      //Pyme
         "MV_PAR08",    ;      //nome do parâmetro
         "",            ;  //descrição combo
         "",;//descrição combo
         "",;//descrição combo
         "",;    //conteúdo padrão
         "",;//descrição combo
         "",;//descrição combo
         "",;//descrição combo
         "",; //daqui pra baixo é tudo Help
         "",     "",     "",      "",      "",      "",      "",        "" )  
                  

PutSx1( cPerg,     ; //Grupo de perguntas SX1
         "09",     ; //seq do parâmetro 
         "Cliente Até",;//descr pergunta
         " ", ;//descr pergunta
         " ", ;//descr pergunta
         "MV_CH09" ,;  //variável auxiliar
         "C",    ;    //tipo
         6 ,     ;    //tamanho
         0,      ;    //decimal
         0,      ;    //qual opção de combo é padrão
         "G",    ;    //campo será GET-G ou COMBO-C
         "", ; //Valid
         "SA1",      ;         //F3
         "",            ;      //código do grupo SXG
         ,              ;      //Pyme
         "MV_PAR09",    ;      //nome do parâmetro
         "",            ;  //descrição combo
         "",;//descrição combo
         "",;//descrição combo
         "",;    //conteúdo padrão
         "",;//descrição combo
         "",;//descrição combo
         "",;//descrição combo
         "",; //daqui pra baixo é tudo Help
         "",     "",     "",      "",      "",      "",      "",        "" )  
                  
         
PutSx1( cPerg,     ; //Grupo de perguntas SX1
         "10",     ; //seq do parâmetro 
         "Loja",;//descr pergunta
         " ", ;//descr pergunta
         " ", ;//descr pergunta
         "MV_CH10" ,;  //variável auxiliar
         "C",    ;    //tipo
         2 ,     ;    //tamanho
         0,      ;    //decimal
         0,      ;    //qual opção de combo é padrão
         "G",    ;    //campo será GET-G ou COMBO-C
         "", ; //Valid
         "",      ;         //F3
         "",            ;      //código do grupo SXG
         ,              ;      //Pyme
         "MV_PAR10",    ;      //nome do parâmetro
         "",            ;  //descrição combo
         "",;//descrição combo
         "",;//descrição combo
         "",;    //conteúdo padrão
         "",;//descrição combo
         "",;//descrição combo
         "",;//descrição combo
         "",; //daqui pra baixo é tudo Help
         "",     "",     "",      "",      "",      "",      "",        "" )  


PutSx1( cPerg,     ; //Grupo de perguntas SX1
         "11",     ; //seq do parâmetro 
         "Banco",;//descr pergunta
         " ", ;//descr pergunta
         " ", ;//descr pergunta
         "MV_CH11" ,;  //variável auxiliar
         "C",    ;    //tipo
         3 ,     ;    //tamanho
         0,      ;    //decimal
         0,      ;    //qual opção de combo é padrão
         "G",    ;    //campo será GET-G ou COMBO-C
         "", ; //Valid
         "SA6",      ;         //F3
         "",            ;      //código do grupo SXG
         ,              ;      //Pyme
         "MV_PAR11",    ;      //nome do parâmetro
         "",            ;  //descrição combo
         "",;//descrição combo
         "",;//descrição combo
         "",;    //conteúdo padrão
         "",;//descrição combo
         "",;//descrição combo
         "",;//descrição combo
         "",; //daqui pra baixo é tudo Help
         "",     "",     "",      "",      "",      "",      "",        "" )  

//alterado em 20/11/2015 , pedido da ave & sabor:
PutSx1( cPerg,     ; //Grupo de perguntas SX1
         "12",     ; //seq do parâmetro 
         "Imprime Nome Cliente?",;//descr pergunta
         " ", ;//descr pergunta
         " ", ;//descr pergunta
         "MV_CH12" ,;  //variável auxiliar
         "N",    ;    //tipo
         1 ,     ;    //tamanho
         0,      ;    //decimal
         0,      ;    //qual opção de combo é padrão
         "C",    ;    //campo será GET-G ou COMBO-C
         "", ; //Valid
         "",      ;         //F3
         "",            ;      //código do grupo SXG
         ,              ;      //Pyme
         "MV_PAR12",    ;      //nome do parâmetro
         "Razao Social",            ;  //descrição combo
         "Razao Social",;//descrição combo
         "Razao Social",;//descrição combo
         "",;    //conteúdo padrão
         "Nome Fantasia",;//descrição combo
         "Nome Fantasia",;//descrição combo
         "Nome Fantasia",;//descrição combo
         "",; //daqui pra baixo é tudo Help
         "",     "",     "",      "",      "",      "",      "",        "" )                     
         
RETURN()


Static function LimpaDir()						                                                       
Local aLstARqs:={}, nCount:=0

//apaga antigos arquivos pra evitar mensagem do windows

If GetRemoteType() == 2 // REMOTE_LINUX 
	aLstArqs := directory(cPDFGer + "/" +   "*.rel*")//por definição, sempre limpar todo o diretório e re-gerar boletos.        
			  
	for nCount := 1 to Len(aLstArqs)
		ferase(cPDFGer +  "/" +aLstArqs[nCount][1] )	
	Next                 
	
	If (lTib12 == .F.) .And. (lTib14 == .F. )    //lTib12 == .F. -> rotina chamado no ato do envio do email
		Sleep(10)//ao imprimir mais de um boleto no ato do envio de cobranca o sistema evita apagar os pdf gerados anteriormente
	Else						
		aLstArqs := directory(cPDFGer + "/" +  "*.pdf*")//por definição, sempre limpar todo o diretório e re-gerar boletos.        
				  
		for nCount := 1 to Len(aLstArqs)
			ferase(cPDFGer +  "/" +aLstArqs[nCount][1] )	
		Next                 
		
		Sleep(10)
	EndIf
Else
	aLstArqs := directory(cPDFGer + "\" +   "*.rel*")//por definição, sempre limpar todo o diretório e re-gerar boletos.        
			  
	for nCount := 1 to Len(aLstArqs)
		ferase(cPDFGer +  "\" +aLstArqs[nCount][1] )	
	Next                 
	
	If (lTib12 == .F.) .And. (lTib14 == .F. )    //lTib12 == .F. -> rotina chamado no ato do envio do email
		Sleep(10)//ao imprimir mais de um boleto no ato do envio de cobranca o sistema evita apagar os pdf gerados anteriormente
	Else						
		aLstArqs := directory(cPDFGer + "\" +  "*.pdf*")//por definição, sempre limpar todo o diretório e re-gerar boletos.        
				  
		for nCount := 1 to Len(aLstArqs)
			ferase(cPDFGer +  "\" +aLstArqs[nCount][1] )	
		Next                 
		
		Sleep(10)
	EndIf
EndIf

return

                           
      
/*

Os layouts dos bancos exigem uma determinada qtd de caracteres no formato da conta e da agencia. Caso o usuário não tenha informado isto corretamente no
seu cadastrom, eu mesmo arrumo no ato da emissão do boleto!

ITAU   CONTA BANCARIA 5(C)   AGENCIA(4)
santander   CONTA BANCARIA 6(C)   AGENCIA(4) 
bradesco   CONTA BANCARIA 7(C)   AGENCIA(4)
bco brasil  8(c)                        (4)  
(bco 104)   6(c)                        (4)


(bco 399)   5(c)                        (4)  
(bco 422)   9(c)                        5(c)    

*/
static function EETabulacaoBanco()
Local cContAtu := ALLTRIM( SEE->EE_CONTA )
Local cAgenAtu := ALLTRIM( SEE->EE_AGENCIA )
Local nTamConta   := Len(cContAtu)
Local nTamAgencia := Len(cAgenAtu)
Local nDif := 0
Local cStr := ''                    

cEEConta := ''
cEEAgencia := ''

if cTib11 == '422'
	nDif :=  9 - nTamConta 

	IF nDif > 0
		cStr := STRZERO(0, nDif)
		cEEConta := cStr + cContAtu
	ELSE
		cEEConta := cContAtu
	ENDIF
	
	nDif :=  5 - nTamAgencia
	
	IF nDif > 0
		cStr := STRZERO(0, nDif)
		cEEAgencia 	:= cStr + cAgenAtu
	ELSE
		cEEAgencia := cAgenAtu
	ENDIF
	
endif

if cTib11 == '001'
	nDif := 8  - nTamConta

	if nDif > 0
		cStr := STRZERO(0, nDif)
		cEEConta := cStr + cContAtu
	ELSE
		cEEConta := cContAtu
	ENDIF

	nDif := 4  - nTamAgencia

	if nDif > 0
		cStr := STRZERO(0, nDif)
		cEEAgencia 	:= cStr + cAgenAtu
	else
		cEEAgencia 	:= cAgenAtu
	endif
	


endif 

if cTib11 == '033' 
	nDif :=  6 - nTamConta
	
	if nDif > 0
		cStr := STRZERO(0, nDif)
		cEEConta := cStr + cContAtu
	else
		cEEConta := cContAtu
	endif
	
	nDif :=  4 - nTamAgencia

	if nDif > 0
		cStr := STRZERO(0, nDif)
		cEEAgencia 	:= cStr + cAgenAtu
	else
		cEEAgencia 	:= cAgenAtu
	endif
endif

if cTib11 == '399'
	nDif :=  5 - nTamConta
	
	if nDif > 0
		cStr := STRZERO(0, nDif)
		cEEConta := cStr + cContAtu
	else
		cEEConta := cContAtu
	endif
	
	nDif :=  4 - nTamAgencia
	
	if nDif > 0
		cStr := STRZERO(0, nDif)
		cEEAgencia 	:= cStr + cAgenAtu
	else
		cEEAgencia 	:= cAgenAtu
	endif
endif

if cTib11 == '104'
	nDif :=  6 - nTamConta
	
	if nDif > 0
		cStr := STRZERO(0, nDif)
		cEEConta := cStr + cContAtu
	else
		cEEConta := cContAtu
	endif
	
	nDif :=  4 - nTamAgencia

	if nDif > 0
		cStr := STRZERO(0, nDif)
		cEEAgencia 	:= cStr + cAgenAtu
	else
		cEEAgencia 	:= cAgenAtu
	endif
	
endif

if cTib11 == '237'
	nDif :=  7 - nTamConta
	
	if nDif > 0
		cStr := STRZERO(0, nDif)
		cEEConta := cStr + cContAtu
	else
		cEEConta := cContAtu
	endif
	
	nDif :=  4 - nTamAgencia
	
	if nDif > 0
		cStr := STRZERO(0, nDif)
		cEEAgencia 	:= cStr + cAgenAtu
	else
		cEEAgencia 	:= cAgenAtu
	endif
	
endif

if cTib11 == '633'
	nDif :=  7 - nTamConta
	
	if nDif > 0
		cStr := STRZERO(0, nDif)
		cEEConta := cStr + cContAtu
	else
		cEEConta := cContAtu
	endif
	
	nDif :=  4 - nTamAgencia
	
	if nDif > 0
		cStr := STRZERO(0, nDif)
		cEEAgencia 	:= cStr + cAgenAtu
	else
		cEEAgencia 	:= cAgenAtu
	endif
	
endif

if cTib11 == '341'
	nDif :=  5 - nTamConta
	
	if nDif > 0
		cStr := STRZERO(0, nDif)
		cEEConta := cStr + cContAtu
	else
		cEEConta :=  cContAtu
	endif
	
	nDif :=  4 - nTamAgencia
	
	if nDif > 0
		cStr := STRZERO(0, nDif)
		cEEAgencia 	:= cStr + cAgenAtu
	else
		cEEAgencia 	:=  cAgenAtu
	endif
endif


if cTib11 == '021'
	nDif :=  11 - nTamConta
	
	if nDif > 0
		cStr := STRZERO(0, nDif)
		cEEConta := cStr + cContAtu
	else
		cEEConta :=  cContAtu
	endif
	
	nDif :=  4 - nTamAgencia
	
	if nDif > 0
		cStr := STRZERO(0, nDif)
		cEEAgencia 	:= cStr + cAgenAtu
	else
		cEEAgencia 	:=  cAgenAtu
	endif
endif

return

/*
OnStack
verifica se tem uma funcao na pilha
@since 09/12/2014
@version 1.0
*/

Static Function OnStack(cFunc)
Local lRet := .F.
Local cProc := ""
Local nX := 0

While !Empty(cProc := ProcName( nX++ )) .And. !lRet
	lRet := (Alltrim(Upper(cProc)) == cFunc)
End

Return lRet



/*/{Protheus.doc} SendMail
@type function
@author TOTVS IBIRAPUERA
@since 26/07/2016
@version 1.0
@param cTo, character, 
@param cNomeCli, character, 
@param cFileBol, character, 
@param cFilePdf, character, 
/*/
Static Function SendMail(cTo , cNomeCli , cFileBol , cFilePdf, aTitCob)
Local nPrtServer    	:= Nil
Local oMessage      	:= NIL
Local cMailConta    	:= ""
Local cMailServer   	:= ""
Local cMailSenha    	:= ""
Local cMailCtaAut   	:= ""
Local lContinua     	:= .T., cListCopias := ""
Local nCount := 0, nI 	:= 0, nErro := 0, cNome := "", nIndc:= 0
Local aLstCliAlgumTit 	:= {}//clientens com algum titulos configurado para disparar email de cobranca                                     
Local nTemTitMarcado 	:= 0, cAVencer := '', cPendentes:=''
Local cParcNome 		:= ""
Local cNewNome  		:= ""                   
Local cNome     		:= ""
Local lTLS				:= .F.
Local lUsaSSl 			:= .F.
Local lRelAuth 			:= .F.
Local nIndChar 			:= 0
Local cTitMail 			:= "Boleto(s) automático Santa Fé"
Local cPathHtml         := GetNewPar("ES_PAHTML","email_cobranca")
Local cPathAVencerHtml  := GetNewPar("ES_AVHTML","avencer.html")
Local cAVencMsg			:= ""
Local cAVencHtml 		:= ""   
Local cPDFGer  			:= GetSrvProfString("Startpath","") +  "TIBBOLETO\"

Private	oServer	

Default cTo				:= ""
Default cNomeCli		:= ""
Default cFileBol		:= ""  
Default cFilePDF		:= ""

//--Obtem a configuracao de e-mail:
cMailConta  := "boletos.santafe@feltrossantafe.com.br"                                                                                                                                                                                                                                 
cMailServer := "smtp.terra.com.br"                                                                                                                                                                                                                                     
cMailSenha  := "321@Blt#""
cMailCtaAut := "boletos.santafe@feltrossantafe.com.br" 
nPrtServer  := 587
lRelAuth 	:= .T.
lTLS	    := .T.
lUsaSSl     := .F.

If At(":",cMailServer) > 0 
	cMailServer	:= SubStr(cMailServer,1,At(":",cMailServer) - 1 )
EndIf

If GetRemoteType() == 2 // REMOTE_LINUX 
	cAVencHtml     := MemoRead( "/system/" + cPathHtml + "/" + AllTrim(cPathAVencerHtml) )  
Else
	cAVencHtml     := MemoRead( "\system\" + cPathHtml + "\" + AllTrim(cPathAVencerHtml) )  
EndIf

cAVencer := GridCorpoEmail(.T.,aTitCob)

cAVencMsg 	:= STRTRAN ( cAVencHtml , '[NOME DO CLIENTE]' , cNomeCli , 1 , 1 )
cAVencMsg 	:= STRTRAN ( cAVencMsg , '[TITULO]' , cAVencer , 1 , 1 )

//--Cria a conexão com o server STadmin	MP ( Envio de e-mail )
oServer := TMailManager():New()      

//cPrtServer:='587' 
oServer:SetUseTLS(lTLS)  //na Integral tive que ligar TSL para funcionar. No meu PC com esta linha não funciona SSL

oServer:SetUseSSL(lUsaSSl)

//oServer:Init('', cMailServer, cMailCtaAut, cMailSenha, 0, Val(cPrtServer))//25
nRet := oServer:Init('', cMailServer, cMailCtaAut, cMailSenha, 0, nPrtServer)//25

If nRet != 0
  cMsg := "Could not initialize SMTP server: " + oServer:GetErrorString( nRet )
  conout( cMsg )
  Return
Endif

nRet := oServer:SetSMTPTimeOut( 120 )
If NRet != 0
    cMsg := "Could not set " + cProtocol + " timeout to " + cValToChar( 180 )
    conout( cMsg )
Endif
//--Seta um tempo de time out com servidor de 1min  

If  oServer:SMTPConnect() <> 0       //180  

	Conout( "Ocorreu um problema ao determinar o Time-Out do servidor SMTP ou nao foi possível estabelecer a conexao com o mesmo." )
	lContinua := .F.          

Else
	If lRelAuth
		nErro := oServer:SmtpAuth(cMailConta, cMailSenha)
			
		If nErro <> 0
	        cMAilError := oServer:GetErrorString(nErro)
	        DEFAULT cMailError := '***UNKNOW***'
	        ConOut("Erro de Autenticacao " + Str(nErro,4) + '(' + cMAilError + ')')
	        oServer := Nil
	        Return
	    EndIf	
    Endif
EndIf

If lContinua
   	oMessage := TMailMessage():New()         
	//--Limpa o objeto
	oMessage:Clear()

	//--Popula com os dados de envio
	oMessage:cFrom 		:= cMailCtaAut	//cMailConta
	oMessage:cTo 		:= cTo			//"oswaldo.luiz@totvs.com.br"
	oMessage:cSubject   := cTitMail		//SuperGetMV('ES_TITMSG',,'Aviso de Cobrança Eletrônica')       
	oMessage:cBody 		:= "Prezado Cliente, <BR><BR>Para sua comodidade e com o objetivo de facilitar o recebimento dos boletos de cobrança evitando possíveis problemas com atrasos no seu recebimento, segue boleto em anexo. <BR><BR>No caso de dúvidas, gentileza entrar em contato através dos canais abaixo: <BR><BR>1. E-mail: boletos@feltrossantafe.com.br <BR><BR>2. Telefone: 11-2487-4255 - Contas a Receber <BR><BR>Esta é uma mensagem automática. Favor não responder. <BR><BR>O título após vencido, tem o prazo de 10 dias corridos para pagamento, podendo ser utilizado o mesmo boleto. <BR><BR>Para segunda via, necessário solicitar através do e-mail boletos acima, a Santa Fé só encaminhará segunda via se solicitado por e-mail, ou após algum acordo previamente negociado com o contas a receber. <BR><BR>Títulos com boletos não podem ser depositados. <BR><BR>Indústria de Feltros Santa Fé S.A. <BR><BR>Antes de imprimir, avalie a real necessidade e pense em sua responsabilidade e compromisso com o meio ambiente."
    //-----------------------------------------------------------------------------------------------------------------
	//lembre-se de que aqui neste ponto todos os registros da array aTitulos fazem uso do mesmo layout.
    //-----------------------------------------------------------------------------------------------------------------

	 cNome :=  cFileBol                               

     If GetRemoteType() == 2 // REMOTE_LINUX 
	     cNewNome := strtran (cNome,"/SYSTEM/","*",1,1)//não sabemos como usuario informou a palavra no parametro, testamos por segurança os dois casos				     
	     cNewNome := strtran (cNome,"/system/","*",1,1)				     
     Else
	     cNewNome := strtran (cNome,"\SYSTEM\","*",1,1)//não sabemos como usuario informou a palavra no parametro, testamos por segurança os dois casos				     
	     cNewNome := strtran (cNome,"\system\","*",1,1)				     
     EndIf
 
     //cNome := "\system\" + GetNewPar("ES_PAHTML","email_cobranca") + "\" + GetNewPar("ES_PAHPDF","PDF_cobranca")  + "\" + cNome			     
    
    If CpyT2S( oPrinter:cPathPDF+ cFilePdf , cPDFGer ) 	 
		cNome	:= cPDFGer + cFilePdf
	EndIf
		
     nRet := oMessage:AttachFile( cNome )
     If nRet <> 0
     	Conout( "Erro ao anexar arquivo ao e-mail " + cNome ) 
     Endif
 
    //--Envia o e-mail
	ConOut('Enviando mensagem  - Destinatario(s): ' + cNomeCli )
	nSend :=  oMessage:Send(oServer) 
	If nSend!= 0
		Conout( "Erro ao enviar o e-mail " + oServer:GetErrorString( nSend ) ) 	     
	EndIf
    
    oMessage := Nil
		                                                      
	//--Desconecta do servidor
	If oServer:SMTPDisconnect() != 0
		Conout( "Erro ao desconectar do servidor SMTP" )
	EndIf
	
EndIf                                                  

oMessage := Nil
oServer := Nil      

Return

Static FUnction GridCOrpoEMail (lAVencer, aLstTit)
					
Local cGrid 	:= ''
Local cNomBco 	:= ''
Local nY := 0

For nY:=1 to Len(aLstTit)
	
	If aLstTit[nY][4] == '001'
		cNomBco := 'Banco do Brasil'
	ElseIf aLstTit[nY][4] == '033'
		cNomBco := 'Santander'
	ElseIf aLstTit[nY][4] == '237'
		cNomBco := 'Bradesco'
	ElseIf aLstTit[nY][4] == '341'
		cNomBco := 'Itau'
	Endif
	
	cGrid += '<tr class="Text">' + Chr(13)+Chr(10)
	
	If !Empty(aLstTit[nY][3]) // Prefixo + Nr.Titulo + Parcela		                
		cGrid += '<td>' + aLstTit[nY][2] + " - " + aLstTit[nY][1] +  ' - Parcela ' + aLstTit[nY][3]+ '  </td>' + Chr(13)+Chr(10)
    Else
		cGrid += '<td>' + aLstTit[nY][2] + " - " + aLstTit[nY][1] + ' ' + aLstTit[nY][3]+ '  </td>' + Chr(13)+Chr(10)
    Endif

	cGrid += '<td>' + aLstTit[nY][10] + '  </td>' + Chr(13)+Chr(10) // Nosso Numero
    
	cGrid += '<td>' + aLstTit[nY][4] + ' - ' + cNomBco +  '  </td>' + Chr(13)+Chr(10) // Banco
	
	cGrid += '<td>' + aLstTit[nY][5] + '  </td>' + Chr(13)+Chr(10) // Agencia
	cGrid += '<td>' + aLstTit[nY][6] + '  </td>' + Chr(13)+Chr(10) // Conta
	cGrid += '<td>' + DtoC(aLstTit[nY][11]) + '  </td>' + Chr(13)+Chr(10) // Emissao
	cGrid += '<td>' + DtoC(aLstTit[nY][7]) + '  </td>' + Chr(13)+Chr(10) // Vencimento
	cGrid += '<td align="left">R$ ' + Transform(aLstTit[nY][8], PesqPict('SE1', 'E1_SALDO')) + '  </td>' + Chr(13)+Chr(10) // Valor
	cGrid += '<td>' + aLstTit[nY][9] + '</td>' + Chr(13)+Chr(10) // Linha Digitavel

	cGrid += '</tr>' + Chr(13)+Chr(10)

Next nY								

Return(cGrid)

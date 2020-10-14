/*
Funcao: EICCO100()
Autor.: Alex Wallauer
Data..: 29/10/2008
====================================================================
Chamada do Menu:
			<MenuItem Status="Enable">
				<Title lang="pt">Importacao PCO</Title>
				<Title lang="es">Importacao PCO</Title>
				<Title lang="en">Importacao PCO</Title>
				<Function>EICCO100</Function>
				<Type>1</Type>
				<Access>xxxxxxxxxx</Access>
				<Module>17</Module>
			</MenuItem>
====================================================================
*/
#INCLUDE "Average.ch"
#INCLUDE "AVPRINT.CH"
#INCLUDE "TOPCONN.ch"
#INCLUDE "EICCO100.CH"

#DEFINE COD_II     " 1-II"
#DEFINE COD_IPI    " 2-IPI"
#DEFINE COD_PIS    " 3-PIS"
#DEFINE COD_COFINS " 4-COFINS"
#DEFINE COD_ICMS   " 5-ICMS"
#DEFINE IMPOSTOS_NFE "1-II , 2-IPI , 3-PIS , 4-COFINS , 5-ICMS"

#DEFINE NFP "Valores NF Primeira"
#DEFINE NFC "Valores NF Complementar"
#DEFINE NFU "Valores NF Unica"
#DEFINE NFT "Valores NF Transferencia"
#DEFINE CALCULADO "Valores Calculados"
#DEFINE DESEMBARACO "Valores do Desembaraco"

#DEFINE INCLUSAO  1
#DEFINE ALTERACAO 2
#DEFINE ESTORNO   3

#DEFINE ENTER CHR(13)+CHR(10)

#DEFINE NF_TRANSFERENCIA 9

*========================================================================================*
Function EICCO100(lTemBrowse)
*========================================================================================*
LOCAL oDlg
LOCAL aFixos:={}
Local aCores:={}
DEFAULT lTemBrowse := .T.

PRIVATE aRotina    :=MenuDef()
PRIVATE lImportador:=EasyGParam("MV_PCOIMPO",,.T.)//Se for importador é .T., e Adquirente é .F.
PRIVATE lAdquirente:=!lImportador            //Se for importador é .F., e Adquirente é .T.
PRIVATE lMV_EASY   :=(EasyGParam("MV_EASY",,"N") = "S")//Se for integrado com a Microsiga é .T.
PRIVATE lCalcNFT   :=!(lMV_EASY .AND. lImportador)//.T.//Nao calcular a PCO quando integrado com a Microsiga e for importador
PRIVATE lMarcadoSempreImp := .F.    // Permitir desmarcar os impostos
PRIVATE lSoLeNFT:=.F.
PRIVATE cFilSW2:=xFilial("SW2")
PRIVATE cFilSA2:=xFilial("SA2")
PRIVATE cFilSB1:=xFilial("SB1")
PRIVATE cFilSF1:=xFilial("SF1")
PRIVATE cFilSWZ:=xFilial("SWZ")
PRIVATE cFilEIW:=xFilial("EIW")
PRIVATE cFilEIY:=xFilial("EIY")
PRIVATE cFilEIZ:=xFilial("EIZ")
PRIVATE cFilSWD:=xFilial("SWD")
PRIVATE cFilSWN:=xFilial("SWN")
PRIVATE cFilSWW:=xFilial("SWW")
PRIVATE cFilSYB:=xFilial("SYB")
PRIVATE cFilSW9:=xFilial("SW9")
PRIVATE cFilSW7:=xFILIAL("SW7")
PRIVATE cFilSW8:=xFILIAL("SW8")
PRIVATE cFilEIJ:=xFILIAL("EIJ")
PRIVATE lICMSRedIPI := EasyGParam("MV_EIC0018",,.F.)          //NCF - 14/09/2012 - Redução de ICMS (Carga Trib. Equiv) na Nota Fiscal de Transferência
lICMSRedIPI := If(ValType(lICMSRedIPI)=="C",StrTran(lICMSRedIPI,".","")=="T",lICMSRedIPI) //AAF 26/12/2014 - Alguns dicionários sairam com MV_EIC0018 com tipo caracter.
PRIVATE nBasRedICM  := 0
//OAP - Adequação para o correto funcionamento do EICDI554. - Variavel do EICDI554
PRIVATE PICTPesoT := AVSX3("B1_PESO",6)
Private PICT06_2  := '@E 999.99'
Private PICT15_2  := '@E 999,999,999,999.99'
Private PICTPesoI := AVSX3("B1_PESO",6)
Private PICT21_8  := ALLTRIM(X3Picture("W3_PRECO"))
Private PICT_CPO07:= ALLTRIM(X3Picture("W3_QTDE"))
Private lLote          := EasyGParam("MV_LOTEEIC",,"N") $ cSim
Private lExiste_Midia  := EasyGParam("MV_SOFTWAR",,"N") $ cSim
Private lRateioCIF     := EasyGParam("MV_RATCIF" ,,"N") $ cSim
Private PICT_CPO03 :=  ALLTRIM(X3PICTURE("B1_POSIPI")) //_PictTec
Private lCposCofMj := SWN->(FieldPos("WN_VLCOFM")) > 0 .And. SWN->(FieldPos("WN_ALCOFM")) > 0  .AND.;
                         EIW->(FieldPos("EIW_ALCOFM")) > 0 .AND. EIW->(FieldPos("EIW_VLCOFM")) > 0  // GFP - 13/12/2013 - Tratamento de Majoração COFINS
Private lCposPisMj := SWN->(FieldPos("WN_VLPISM")) > 0 .And. SWN->(FieldPos("WN_ALPISM")) > 0  .AND.;
                         EIW->(FieldPos("EIW_ALPISM")) > 0 .AND. EIW->(FieldPos("EIW_VLPISM")) > 0  // GFP - 13/12/2013 - Tratamento de Majoração PIS
Private lNftFilha  := EasyGParam("MV_NFT_FLH",,.F.)
Private cFrmProprio:= EasyGParam("MV_NF_AUTO",, "N")
Private lNFAuto    := .F.
Private lCposDspBs := SYB->(FieldPos("YB_BIPINFT")) > 0 .AND. EIW->(FieldPos("EIW_DBSIPI")) > 0 .AND.;
                      EIW->(FieldPos("EIW_DBSICM")) > 0                                             // NCF - 23/07/2015 - Despesas base de ICMS e IPI na NFT
//MFR 05/07/2017  MTRADE-1200 WCC-524950
Private lCpoBseNft       := SWZ->(FieldPos("WZ_BASENFT")) > 0
//NCF - 01/11/2017 - Integ.NFT via Mens.Unica
Private lIntNFTEAI       := lAdquirente .And. !lNftFilha .And. AvFlags("EIC_EAI") .And. EIW->(FieldPos("EIW_DOCORI")) > 0 .And. EIW->(FieldPos("EIW_SERORI")) > 0
Private aEnv_NFS         := {}
Private nTipoNF          := NF_TRANSFERENCIA
Private nNvlForEst       := 7
Private lIntegrarEstorno := .T.

IF lNftFilha .AND. lMV_EASY .AND. cFrmProprio == "S"
   lNFAuto := .T.
ENDIF

If !lImportador .AND. EasyGParam("MV_TEM_DI",,.F.)  // GFP - 13/10/2015
   MsgAlert("Não é possível efetuar a geração de NF de Transferencia de Posse pois o parametro MV_TEM_DI está habilitado." + ENTER + "Desabilite o parametro MV_TEM_DI para realizar a geração de NF de Transferencia de Posse.","Aviso")
   Return
EndIf

IF lImportador
   cCadastro  :="Pre-Nota"
  IF lMV_EASY
     cCadastro+=" com Geracao de PV"
  ENDIF
ELSE
   cCadastro  :="Geracao de NF de Transferencia de Posse"
ENDIF

AADD( aFixos,{ AVSX3("W6_HAWB"   ,5) ,"W6_HAWB"   }) //Processo
AADD( aFixos,{ AVSX3("W6_DI_NUM" ,5) ,"W6_DI_NUM" }) //No. da DI
AADD( aFixos,{ AVSX3("W6_TX_US_D",5) ,"W6_TX_US_D"}) //Taxa da DI
AADD( aFixos,{ AVSX3("W6_IMPCO"  ,5) ,"W6_IMPCO"  }) //Import C.O.?
IF SW6->(FIELDPOS("W6_IMPENC")) # 0
   AADD( aFixos,{ AVSX3("W6_IMPENC",5),"W6_IMPENC"}) //Encomenda?
ENDIF
IF lMV_EASY .AND. lImportador
   AADD(aFixos,{ AVSX3("W6_PEDFAT",5),"W6_PEDFAT"} )
ENDIF
IF EasyGParam("MV_TEM_DI",,.F.)
   AADD( aFixos,{ AVSX3("W6_ADICAOK",5) ,{|| IF(!SW6->W6_ADICAOK $ cSim,"Nao","Sim")}})
ENDIF
AADD( aFixos,{ AVSX3("W6_NF_ENT" ,5) ,"W6_NF_ENT" }) //"1a. NFE"
AADD( aFixos,{ AVSX3("W6_DT_NF"  ,5) ,"W6_DT_NF"  }) //"Dt 1a. NFE"
AADD( aFixos,{ AVSX3("W6_NF_COMP",5) ,"W6_NF_COMP"}) //"1a. NFC"
AADD( aFixos,{ AVSX3("W6_DT_NFC" ,5) ,"W6_DT_NFC" }) //"Dt 1a. NFC"
AADD( aFixos,{ AVSX3("W6_FOB_GER",5) ,"W6_FOB_GER"}) //"Total Geral"
AADD( aFixos,{ AVSX3("W6_FOB_TOT",5) ,"W6_FOB_TOT"}) //"Total F.O.B."
AADD( aFixos,{ AVSX3("W6_INLAND" ,5) ,"W6_INLAND" }) //"Inland"
AADD( aFixos,{ AVSX3("W6_PACKING",5) ,"W6_PACKING"}) //"Packing"
AADD( aFixos,{ AVSX3("W6_FRETEIN",5) ,"W6_FRETEIN"}) //"Frete Intl"
AADD( aFixos,{ AVSX3("W6_DESCONT",5) ,"W6_DESCONT"}) //"Desconto"

AADD( aCores,{ "PCOGerado('VERDE')" , "ENABLE"    })//VERDE
AADD( aCores,{ "PCOGerado('AZUL' )" , "BR_AZUL"   })//AZUL
AADD( aCores,{ "PCOGerado('AMAR' )" , "BR_AMARELO"})//AMARELO
AADD( aCores,{ "PCOGerado('VERM' )" , "DISABLE"   })//VERMELHO
AADD( aCores,{ "PCOGerado('PRETO')" , "BR_PRETO"  })//PRETO

SWN->(DBSETORDER(3))//WN_FILIAL+WN_HAWB+WN_TIPO_NF

IF lTemBrowse

   #ifdef TOP
     IF SW6->(FIELDPOS("W6_IMPENC")) = 0
        cFiltro:="W6_IMPCO = '1'"
     ELSE//AWR - 30/11/2009
//      cFiltro:="(W6_IMPENC = '1' .OR. W6_IMPCO = '1')" //AWR - 03/12/2009 - O Filtro nao Funcionou em TOP com os 2 campos
        cFiltro:=NIL
        DBSELECTAREA("SW6")
        SET FILTER TO (SW6->W6_IMPCO = '1' .OR. SW6->W6_IMPENC = '1')
     ENDIF
   #else
     cFiltro:=NIL
     DBSELECTAREA("SW6")
     IF SW6->(FIELDPOS("W6_IMPENC")) = 0
        SET FILTER TO SW6->W6_IMPCO = '1'
     ELSE//AWR - 30/11/2009
        SET FILTER TO (SW6->W6_IMPCO = '1' .OR. SW6->W6_IMPENC = '1')
     ENDIF
   #endif

   mBrowse(,,,,"SW6",aFixos,,,,,aCores,,,,,,,,cFiltro)

ELSE
   SF1->(DBSETORDER(5))
   SWN->(DBSETORDER(3))
   IF !SWN->(DBSEEK(/*cFilSWN*/SW6->W6_FILIAL+SW6->W6_HAWB+"9")) .AND. !SF1->(DBSEEK(/*cFilSF1*/SW6->W6_FILIAL+SW6->W6_HAWB+"9"))
      MSGSTOP("Processo nao possui NFT.")
      RETURN .F.
   ENDIF
   lSoLeNFT:=.T.
   PCOTela("SW6",SW6->(RECNO()),2)

ENDIF

DBSELECTAREA("SW6")
SET FILTER TO

SF1->(DBSETORDER(1))
SW7->(DBSetOrder(1))
SW8->(DBSetOrder(1))
SW9->(DBSETORDER(1))
SWN->(DBSETORDER(1))
SWW->(DBSETORDER(1))
SWZ->(DBSETORDER(1))

RETURN .T.
*========================================================================================*
Static Function MenuDef()
*========================================================================================*
Private aRotina  := { {"Pesquisar","AxPesqui"    ,0,1} }//1 - 1-Pesquisa
IF EasyGParam("MV_PCOIMPO",,.T.)//Se for importador é .T., e Adquirente é .F.
   AADD(aRotina, {"Pre - Nota"  ,"PCOTela"   ,0,4} )//2 - 4-Alterar
ELSE
   AADD(aRotina, {"Valores NFT" ,"PCOTela"   ,0,4} )//2 - 4-Alterar
ENDIF
AADD(aRotina   , {"Impressao Val.","PCOImprNFT(.T.)",0,4} )
AADD(aRotina   , {"Legenda"       ,"PCOLegend" ,0,3} )

IF(EasyEntryPoint("EICCO100"),Execblock("EICCO100",.F.,.F.,"AROTINA"),)   // GFP - 02/07/2013

Return aRotina

*--------------------------------------------------------------------------------------*
Function PCOGerado(cCor)
*--------------------------------------------------------------------------------------*
LOCAL lTemNFT,lTemPed,lTemNFT_or_Ped
LOCAL lIntegrouNFT:=.F.
LOCAL lGerouNFT   :=.F.

PCOInitVar()

SF1->(DBSETORDER(5))
SWN->(DBSETORDER(3))
lTemNFT        := lCalcNFT  .AND. (SWN->(DBSEEK(/*cFilSWN*/SW6->W6_FILIAL+SW6->W6_HAWB+"9")) .AND. SF1->(DBSEEK(/*cFilSF1*/SW6->W6_FILIAL+SW6->W6_HAWB+"9")))
lTemPed        := !lCalcNFT .AND. !EMPTY(SW6->W6_PEDFAT)
lTemNFT_or_Ped := lTemNFT   .OR.  lTemPed//Nunca os dois vao estar verdadeiro

IF lCalcNFT
   IF EIW->(DBSEEK(xFilial("EIW")+SW6->W6_HAWB))
      IF EIW->EIW_NFTGER = "1"
         lGerouNFT:=.T.
      ENDIF
   ENDIF
   IF lTemNFT .AND. !lGerouNFT
      lIntegrouNFT:=.T.
   ENDIF
ENDIF

DO CASE
   CASE cCor == "VERDE"
        IF !lTemNFT_or_Ped .AND. !EIW->(DBSEEK(xFilial("EIW")+SW6->W6_HAWB))//FDR - 29/02/12
           RETURN .T.
        ENDIF

   CASE cCor == "AMAR"
        IF !lTemNFT_or_Ped .AND. EIW->(DBSEEK(xFilial("EIW")+SW6->W6_HAWB))
           RETURN .T.
        ENDIF

   CASE cCor == "AZUL"
        If lIntNFTEAI
           IF lTemNFT .AND. lGerouNFT .AND. SF1->F1_STATUS <> "0"
              RETURN .T.
           ENDIF        
        Else
           IF lTemNFT_or_Ped .AND. !EIW->(DBSEEK(xFilial("EIW")+SW6->W6_HAWB))
              RETURN .T.
           ENDIF
        EndIf

   CASE cCor == "VERM"
        IF lTemNFT_or_Ped .AND. EIW->(DBSEEK(xFilial("EIW")+SW6->W6_HAWB)) .AND. !lIntegrouNFT
           RETURN .T.
        ENDIF

   CASE cCor == "PRETO"
        IF lTemNFT_or_Ped .AND. EIW->(DBSEEK(xFilial("EIW")+SW6->W6_HAWB)) .AND. lIntegrouNFT
           RETURN .T.
        ENDIF

ENDCASE

RETURN .F.
*--------------------------------------------------------------------------------------*
Function PCOLegend()
*--------------------------------------------------------------------------------------*
LOCAL aLegenda:={}
AADD(aLegenda,{"ENABLE"    ,"Valores Nao Gravados"    })
AADD(aLegenda,{"BR_AMARELO","Valores Gravados"        })

If lIntNFTEAI
   AADD(aLegenda,{"DISABLE" ,"Valores gravados e NFT Gerada"})
   AADD(aLegenda,{"BR_AZUL" ,"NFT(s) Gerada(s) e Integrada(s)"})
Else
   IF lMV_EASY .AND. lImportador
      AADD(aLegenda,{"BR_AZUL","Pedido de Venda Gerado"  })
      AADD(aLegenda,{"DISABLE","Valores Gravados/Pedido de Venda Gerado"})
   ELSEIF lAdquirente
      AADD(aLegenda,{"BR_AZUL" ,"NF Transferencia Integrada"})
      AADD(aLegenda,{"DISABLE" ,"Valores gravados e NFT Gerada"})
      AADD(aLegenda,{"BR_PRETO","Valores gravados e NFT Integrada"})
   ENDIF
EndIf

BrwLegenda(cCadastro,"Legenda",aLegenda)

Return .T.

*========================================================================================*
Function PCOTela(cAlias,nReg,nOpc)
*========================================================================================*
LOCAL oDlg_wk,W
LOCAL bOkGra := {|| IF(MSGYESNO("Confirma Gravacao dos Valores?"),(oDlg_wk:End(),nBotao:=1),) }
LOCAL bOkExc := {|| IF(MSGYESNO("Confirma Exclusao dos Valores?"),(oDlg_wk:End(),nBotao:=2),) }
LOCAL bOkGer := {|| (lIntegrarEstorno := .T.,oDlg_wk:End(),nBotao:=3) }
LOCAL bOkEst := {|| If( If(lIntNFTEAI .And. lNFTPendEAI , DI154Logix(.F.) .And. MSGYESNO("Confirma Estorno ?") , MSGYESNO("Confirma Estorno ?")) ,(lIntegrarEstorno := .T.,oDlg_wk:End(),nBotao:=4),) }
LOCAL bCancel:= {|| IF(MSGYESNO("Confirma Saida ?")   ,(oDlg_wk:End(),nBotao:=0),) }
LOCAL lDsbBtn1 := lDsbBtn2 := .T.
LOCAL bOKEstForc := {|| IF( DI154Logix(.F.) .AND. MsgYesNo(STR0003, STR0001), (nBotao:=4, lIntegrarEstorno := .F., oDlg_wk:End()) , ) }
PRIVATE nCol1,nCol2,nCol3,nColA,nColB,nPula,nLarg1,nLarg2,nAltu1,nAltu2,nLinha      // GFP - 05/03/2013
Private aBotoes:={}  // GFP - 02/07/2013
IF SW6->W6_IMPCO # "1"
   IF SW6->(FIELDPOS("W6_IMPENC")) = 0
      MSGINFO("Processo nao é de Importacao por Conta e Ordem.")
      RETURN nOpc
   ELSEIF SW6->W6_IMPENC # "1"
      MSGINFO("Processo nao é de Importacao por Conta e Ordem e nem Encomenda.")
      RETURN nOpc
   ENDIF
ENDIF

PRIVATE cTipoNF:=""
PRIVATE aTabTaxas:={}//Usado no programa EICDI154.PRW na funcao DI154TaxaFOB() linha + - 8000
PRIVATE oMark1:=oMark2:=NIL
PRIVATE cCONDPAMS:= SPACE(LEN(SE4->E4_CODIGO))
PRIVATE cCLIENTE := SPACE(LEN(SW2->W2_CLIENTE))
PRIVATE cCLLOJA  := SPACE(LEN(SA1->A1_LOJA))
PRIVATE cTIPCLI  := SPACE(LEN(SA1->A1_TIPCLI))
PRIVATE cTipoPV  := "N"
PRIVATE cMarca   :=GetMark()

//LGS-22/10/2014 - Controle de Saldo nft filha
PRIVATE aItemEIW :={} //Grava a quantidade original dos itens da EIW
PRIVATE aItemSWN :={} //Grava a quantidade de cada item consumido na SWN
PRIVATE aItemStn :={} //Grava os dados da NFT Filha para estorno
PRIVATE lNFTPendEAI := .F.
PCOInitVar()

DBSELECTAREA("SWN")
DBSETORDER(3)///WN_FILIAL+WN_HAWB+WN_TIPO_NF

SYT->(DBSETORDER(1))  // GFP - 21/05/2015
SYT->(dBSeek(xFilial("SYT")+SW6->W6_IMPORT))

Begin Sequence

	lIntegrouNFT:=.F.
	lGerouNFT   :=.F.
	nTela       :=INCLUSAO

	IF EIW->(DBSEEK(CFILEIW+SW6->W6_HAWB))
	   IF EIW->EIW_NFTGER = "1"
	      lGerouNFT:=.T.
	   ENDIF
	   nTela:=ALTERACAO
	ENDIF

	IF LMV_EASY .AND. LIMPORTADOR
	   IF !EMPTY(SW6->W6_PEDFAT)
	      nTela = ESTORNO
	   ENDIF
	ELSE
	   SF1->(DBSETORDER(5))
	   SWN->(DBSETORDER(3))//WN_FILIAL+WN_HAWB+WN_TIPO_NF
	   IF SWN->(DBSEEK(CFILSWN+SW6->W6_HAWB+"9")) .AND. SF1->(DBSEEK(CFILSF1+SW6->W6_HAWB+"9"))
	      IF lGerouNFT .OR. lSoLeNFT
	         nTela = ESTORNO
	      ELSE
	         lIntegrouNFT:=.T.
	      ENDIF
	   ENDIF
	ENDIF

	IF lNftFilha
		cVal := PCONFTFilha(,.T.)
		DO CASE
          CASE cVal == "SAIR"
				 Break
          CASE cVal == "INCLUIR"
               lIntegrouNFT:= .F.
               lGerouNFT   := .T.
               nTela       := 2
          CASE cVal == "ESTORNO"
				 nTela:= ESTORNO
		ENDCASE
	ENDIF

	PRIVATE nTamSeq:=5
	//PRIVATE cMarca :=GetMark()
	PRIVATE lRateioCIF:= EasyGParam("MV_RATCIF",,"N") $ cSim

	//======================================================================== MARCA
	aSemSX3:={}
	AADD(aSemSX3,{"WK_FLAG"   ,"C",02,0})
	AADD(aSemSX3,{"WKDESCRICA","C",50,0})
	AADD(aSemSX3,{"WKVALOR"   ,"N",15,2})
	AADD(aSemSX3,{"WKORIGEM"  ,"C",LEN(EIY->EIY_ORIGEM),0} )
	AADD(aSemSX3,{"WKRECNO"   ,"N",15,0})

	aCampos:={}
	aHeader:={}

	cFileMarca:=E_CriaTrab(,aSemSX3,"WorkMarca",,)
	IndRegua("WorkMarca",cFileMarca+TEOrdBagExt(),"WKDESCRICA")

	//======================================================================== ITENS ==> EIW
	aSemSX3:={}
	IF lNftFilha
	   AADD(aSemSX3,{"WK_FLAG"   ,"C",04,0})
	ELSE
	   AADD(aSemSX3,{"WK_FLAG"   ,"C",02,0})
	ENDIF
	AADD(aSemSX3,{"WKVALOR"   ,"N",15,2})
	AADD(aSemSX3,{"WKOPERACAO","C",LEN(SWN->WN_OPERACA),2})
	AADD(aSemSX3,{"WKIIBASE"  ,"N",15,2})
	AADD(aSemSX3,{"WKIPIBASE" ,"N",15,2})
	AADD(aSemSX3,{"WKIPITX"   ,"N",06,2})
	AADD(aSemSX3,{"WKIPIVAL"  ,"N",15,2})

//MFR 05/07/2017  MTRADE-1200 WCC-524950 segundo orientação do Alessandro sempre exibir o campo mesmo que na for utilzar
//	If EasyGParam("MV_EIC0058",,.F.)  // GFP - 21/05/2015
	   AADD(aSemSX3,{"WKDESPBICM","N",15,2})
	   If lCposDspBs
	      AADD(aSemSX3,{"WKDESPBIPI","N",15,2})
	   EndIf
//	EndIf
	AADD(aSemSX3,{"WKBASEICMS","N",15,2})
	AADD(aSemSX3,{"WKICMS_A"  ,"N",06,2})
	AADD(aSemSX3,{"WKVL_ICM"  ,"N",15,2})
	If EasyGParam("MV_EIC0027",,.F.)  // GFP - 27/03/2013
	   AADD(aSemSX3,{"WKPISVAL"  ,"N",15,2})
	   AADD(aSemSX3,{"WKCOFVAL"  ,"N",15,2})
	   If EIW->(FieldPos("EIW_PERPIS")) # 0   // GFP - 03/12/2015
	      AADD(aSemSX3,{"WKPERPIS"  ,"N",6,2})
	   EndIf
	   If EIW->(FieldPos("EIW_PERCOF")) # 0   // GFP - 03/12/2015
	      AADD(aSemSX3,{"WKPERCOF"  ,"N",6,2})
	   EndIf
	EndIf
	If EIW->(FieldPos("EIW_BASEPC")) # 0   // GFP - 11/07/2013
	   AADD(aSemSX3,{"WKBASEPC" ,"N",15,2})
	EndIf
	If EIW->(FieldPos("EIW_VALMER")) > 0   //NCF - 24/03/2015
	   AADD(aSemSX3,{"WKVALMERC" ,"N",15,2})
	EndIf
	IF lNftFilha
	   AADD(aSemSX3,{"WK_CHAVE","C",50,0})
	ENDIF
	AADD(aSemSX3,{"WKRECNO"   ,"N",15,0})
	AADD(aSemSX3,{"WN_DOC"    ,"C",AVSX3("EIW_NOTA",3),0})  // GFP - 13/10/2015
	
	//NCF - 31/10/2017 - NF Transferência integ. Mensagem Única
   If lIntNFTEAI
      aAdd(aSemSX3,{"WKNOTAPR"    , AvSx3("WN_DOC"  , AV_TIPO)  , AvSx3("WN_DOC"    , AV_TAMANHO), AvSx3("WN_DOC"    , AV_DECIMAL)})
      aAdd(aSemSX3,{"WKSERIEPR"   , AvSx3("WN_SERIE", AV_TIPO)  , AvSx3("WN_SERIE"  , AV_TAMANHO), AvSx3("WN_SERIE"  , AV_DECIMAL)})
      aAdd(aSemSX3,{"WKMENNOTA"   , "C"                         , AVSX3("F1_MENNOTA", AV_TAMANHO), AVSX3("F1_MENNOTA", AV_DECIMAL)})
      aAdd(aSemSX3,{"WK_OK"       , "C"                         , AVSX3("F1_OK"     ,AV_TAMANHO) , AvSx3("F1_OK"     , AV_DECIMAL)})
      aAdd(aSemSX3,{"WKSTATUS"    , "C"                         , 01                             ,                               0})      
   EndIf

	aCampos:={"WN_PRODUTO","WN_QUANT","WN_IIVAL"  ,"WN_IPIVAL" ,"WN_VLRPIS","WN_VLRCOF","WN_VALICM","WN_SERIE",;
	          "WN_PO_EIC" ,"WN_ITEM" ,"WN_PGI_NUM","WN_INVOICE","WV_LOTE"  ,"B1_DESC"  ,"WN_PESOL" ,"WN_FOB_R","WN_FRETE","WN_SEGURO",;
	          "WN_VLCOFM","WN_ALCOFM","WN_VLPISM","WN_ALPISM"} // GFP - 13/12/2013 - Tratamento de Majoração PIS/COFINS
      
      If AvFlags("NFT_DESP_BASE_IMP") //THTS - 09/01/2018 - Nota fiscal de transferência com despesas base de impostos que não compoe total da nota
            aAdd(aCampos,"EIW_VALTOT")
            aAdd(aCampos,"EIW_DESPCU")
      EndIf

	aHeader:={}
	cFileItens:=E_CriaTrab(,aSemSX3,"WorkItens")

	IndRegua("WorkItens",cFileItens+TEOrdBagExt(),"WN_PO_EIC+WN_ITEM+WN_PGI_NUM+WV_LOTE+WN_INVOICE")

	//======================================================================== TAXAS
	aSemSX3:={}
	AADD(aSemSX3,{"WK_MARCA"  ,"C",4,0})
	AADD(aSemSX3,{"WKNOVATAXA","N",AVSX3("W9_TX_FOB",3),AVSX3("W9_TX_FOB",4)})
	AADD(aSemSX3,{"WKOLDTAXA" ,"N",AVSX3("W9_TX_FOB",3),AVSX3("W9_TX_FOB",4)})
	AADD(aSemSX3,{"WKRECNO"   ,"N",15,0})

	aCampos:={"WN_INVOICE","W9_MOE_FOB","W9_TX_FOB"}

	aHeader:={}
	cFileTaxa:=E_CriaTrab(,aSemSX3,"WorkTaxa")

	IndRegua("WorkTaxa",cFileTaxa+TEOrdBagExt(),"W9_MOE_FOB+WN_INVOICE")

	//======================================================================== DESPESAs ==> EIY
	aSemSX3:={}
	AADD(aSemSX3,{"WKORIGEM"  ,"C"                  ,LEN(EIY->EIY_ORIGEM) ,0} )
	AADD(aSemSX3,{"WW_NR_CONT","C"                  ,LEN(SWW->WW_NR_CONT) ,0} )
	AADD(aSemSX3,{"WW_INVOICE","C"                  ,LEN(SWN->WN_INVOICE) ,0} )
	AADD(aSemSX3,{"WW_LOTECTL","C"                  ,LEN(SWV->WV_LOTE)    ,0} )
	AADD(aSemSX3,{"WW_BASEICM",AVSX3("YB_BASEICM",2),AVSX3("YB_BASEICM",3),0} ) //LGS-26/01/2015
	AADD(aSemSX3,{"WW_BASEIMP",AVSX3("YB_BASEIMP",2),AVSX3("YB_BASEIMP",3),0} ) //LRS - 13/07/2016
	AADD(aSemSX3,{"WKRECNO"   ,"N"                  ,15                   ,0} )

	aCampos:={"WW_DESPESA","WW_VALOR","WW_PO_NUM","WW_PGI_NUM"}
	aHeader:={}
	cFileDesp:=E_CriaTrab(,aSemSX3,"WorkDespesa")

	IndRegua("WorkDespesa",cFileDesp+TEOrdBagExt(),"WW_PO_NUM+WW_NR_CONT+WW_PGI_NUM+WW_LOTECTL+WW_INVOICE+WW_DESPESA")

	//======================================================================== WOKRMARCA
	aTBCampos1:={}
	IF !lSoLeNFT
	   AADD(aTBCampos1,{"WK_FLAG",,"" ,})
	ENDIF
	AADD(aTBCampos1,{"WKDESCRICA",,"Despesas / Impostos",})
	AADD(aTBCampos1,{"WKVALOR"   ,,"Valor" ,AVSX3("WW_VALOR",6),})
	AADD(aTBCampos1,{"WKORIGEM"  ,,"Origem",})

	//======================================================================== ITENS ==> EIW
	IF !lNftFilha
	   aTBCampos2:={}
	   IF nTela # ESTORNO .AND. lCalcNFT
	      AADD(aTBCampos2,{"WK_FLAG",,"" ,})
	   ENDIF
	   AADD(aTBCampos2,{"WN_PRODUTO",,"Codigo do Produto"})
	   AADD(aTBCampos2,{"B1_DESC"   ,,"Descricao do Produto"})
	   AADD(aTBCampos2,{"WN_QUANT"  ,,AVSX3("EIW_QTDE"  ,5),AVSX3("EIW_QTDE"  ,6)})
	   AADD(aTBCampos2,{"WN_FOB_R"  ,,AVSX3("EIW_FOB_R" ,5),AVSX3("EIW_FOB_R" ,6)})
	   AADD(aTBCampos2,{"WN_FRETE"  ,,AVSX3("EIW_FRETE" ,5),AVSX3("EIW_FRETE" ,6)})
	   AADD(aTBCampos2,{"WN_SEGURO" ,,AVSX3("EIW_SEGURO",5),AVSX3("EIW_SEGURO",6)})
	   AADD(aTBCampos2,{"WKVALOR"   ,,AVSX3("EIW_VALOR" ,5),AVSX3("EIW_VALOR" ,6)})
	   If EasyGParam("MV_EIC0027",,.F.)  // GFP - 27/03/2013
	      If EIW->(FieldPos("EIW_PERPIS")) # 0   // GFP - 03/12/2015
	         AADD(aTBCampos2,{"WKPERPIS"  ,,AVSX3("EIW_PERPIS" ,5),AVSX3("EIW_PERPIS" ,6)})
	      EndIf
	      AADD(aTBCampos2,{"WKPISVAL"  ,,AVSX3("WN_VLRPIS" ,5),AVSX3("EIW_VLRPIS" ,6)})
	      If EIW->(FieldPos("EIW_PERCOF")) # 0   // GFP - 03/12/2015
	         AADD(aTBCampos2,{"WKPERCOF"  ,,AVSX3("EIW_PERCOF" ,5),AVSX3("EIW_PERCOF" ,6)})
	      EndIf
	      AADD(aTBCampos2,{"WKCOFVAL"  ,,AVSX3("WN_VLRCOF" ,5),AVSX3("EIW_VLRCOF" ,6)})
	   EndIf
	   IF lCalcNFT
	      AADD(aTBCampos2,{"WKOPERACAO",,AVSX3("EIW_OPERAC",5),AVSX3("EIW_OPERAC",6)})
//MFR 05/07/2017  MTRADE-1200 WCC-524950 segundo orientação do Alessandro sempre exibir o campo mesmo que na for utilzar
//	      If EasyGParam("MV_EIC0058",,.F.)  // GFP - 21/05/2015
	         AADD(aTBCampos2,{"WKDESPBICM",,"Desp Base ICMS",AVSX3("EIW_BASEIC",6)})
	         If lCposDspBs
	            AADD(aTBCampos2,{"WKDESPBIPI",,"Desp Base IPI",AVSX3("EIW_DBSIPI",6)})
	         EndIf
//	      EndIf
	      AADD(aTBCampos2,{"WKBASEICMS",,AVSX3("EIW_BASEIC",5),AVSX3("EIW_BASEIC",6)})
	      AADD(aTBCampos2,{"WKICMS_A"  ,,AVSX3("EIW_ICMS_A",5),AVSX3("EIW_ICMS_A",6)})
	      AADD(aTBCampos2,{"WKVL_ICM"  ,,AVSX3("EIW_VL_ICM",5),AVSX3("EIW_VL_ICM",6)})
	      AADD(aTBCampos2,{"WKIPIBASE" ,,AVSX3("EIW_IPIBAS",5),AVSX3("EIW_IPIBAS",6)})
	      AADD(aTBCampos2,{"WKIPITX"   ,,AVSX3("EIW_IPITX" ,5),AVSX3("EIW_IPITX" ,6)})
	      AADD(aTBCampos2,{"WKIPIVAL"  ,,AVSX3("EIW_IPIVAL",5),AVSX3("EIW_IPIVAL",6)})
            //THTS - 09/01/2018 - Nota fiscal de transferência com despesas base de impostos que não compoe total da nota
            If AvFlags("NFT_DESP_BASE_IMP")
                aAdd(aTBCampos2,{"EIW_DESPCU",,AVSX3("EIW_DESPCU",5),AVSX3("EIW_DESPCU",6)})
                aAdd(aTBCampos2,{"EIW_VALTOT" ,,AVSX3("EIW_VALTOT",5) ,AVSX3("EIW_VALTOT" ,6)})
            EndIf

	      AADD(aTBCampos2,{"WN_DOC"    ,,AVSX3("EIW_NOTA"  ,5),})
            AADD(aTBCampos2,{{|| Transform(WorkItens->WN_SERIE,AvSX3("WN_SERIE",AV_PICTURE)) },,AVSX3("EIW_SERIE" ,5),}) //MCF - 05/10/2015

	   ENDIF
	      AADD(aTBCampos2,{{|| WorkItens->("["+WN_PO_EIC+"]+["+WN_ITEM+"]+["+WN_PGI_NUM+"]+["+WV_LOTE+"]+["+WN_INVOICE+"]")},,"PO+Posicao+PGI+Lote+Invoice",})
          //NCF - 31/10/2017 - NF Transferência integ. Mensagem Única
          IF lIntNFTEAI	  
             Private aSTs:={"0=NF não integrada","1=NF Integrada.","2=NF integrada c/ sol.cancelamento","3=NF cancelada."}	  
             aAdd(aTBCampos2,{ {|| if((nPosST:=aScan(aSTs,WorkItens->WKSTATUS))>0,aSTs[nPosST],"") }                          ,  ,AVSX3("F1_STATUS",5)})                        // "Nao Classif."###"Classificada"
             aAdd(aTBCampos2,{ {|| if(AllTrim(WorkItens->WK_OK) == "1","Grupo de NF Integrado","Grupo de NF não Integrado") } ,"",AVSX3("F1_OK",5)      ,AVSX3("F1_OK",6)     })
             aAdd(aTBCampos2,{ "WKMENNOTA"                                                                                ,"",AVSX3("F1_MENNOTA",5) ,AVSX3("F1_MENNOTA",6)})
          ENDIF
	   
	ENDIF
	//======================================================================== ITENS ==> EIW

	lTemDespesas:=.F.
	IF nTela = INCLUSAO .OR. lSoLeNFT
	   lGerou:=.F.
	   Processa( {|| lGerou:=PCOGerar( lSoLeNFT )},,"Gerando Valores...")
	   IF !lGerou
	      PCOCloseWrk()
	      RETURN .F.
	   ENDIF
	ELSE
	   Processa( {|| PCOLeGrava(.T.)},,"Lendo dados...")
	ENDIF
      
      If AvFlags("NFT_DESP_BASE_IMP") .And. Empty(WorkItens->EIW_VALTOT) //Se algum item da work estiver com o campo EIW_VALTOT vazio. significa que ele foi criado após a inclusão do processo, 
            InitDesCus() //THTS - 10/01/2018                             //Assim a funcao InitDesCus deve ser executada para simular as despesas que estao selecionadas e preencher o valor do campo.
      EndIf
	
      aBotoes:={}
	IF !lSoLeNFT
	   AADD(aBotoes,{"PRECO"    ,{|| PCODespTela(nTela)  },"Despesas dos Item" ,"Despesas"})
	ENDIF
	AADD(aBotoes,{"SIMULACA"    ,{|| PCOTotDesp ()       },"Totais de Despesas","Totais"  })

	IF(EasyEntryPoint("EICCO100"),Execblock("EICCO100",.F.,.F.,"ABOTOES"),)  // GFP - 02/07/2013

	IF WorkMarca->(EOF()) .AND. WorkMarca->(BOF())
	   WorkMarca->(DBAPPEND())
	   WorkMarca->WKDESCRICA:="Nao existem despesas"
	ENDIF

	nCol1 :=70
	nCol2 :=nCol1+82
	nCol3 :=nCol2+82
	nColA :=315
	nColB :=nColA+5
	nPula :=14
	nLarg1:=75
	nLarg2:=80
	nAltu1:=12
	nAltu2:=12

	DO WHILE .T.

	   IF lNftFilha //LGS - 22/10/2014 - Validação das variaveis para esconder os botoes na tela quando ja tiver gravado os valores do processo.
	      IF EIW->(DBSEEK(cFilEIW+SW6->W6_HAWB)) .AND. (EMPTY(cVal) .OR. cVal == "INCLUIR")
             lDsbBtn1 := .F.
             IF cVal == "INCLUIR"
                lDsbBtn2 := .F.
             ENDIF
          ENDIF
       ENDIF

	   nBotao:=10
	   oMainWnd:ReadClientCoors()
	   DEFINE MSDIALOG oDlg_wk TITLE cCadastro+" - Processo: "+SW6->W6_HAWB;//"Valores Base da Nota Fiscal de Transferencia de Posse" ;
	          FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 ;
	          TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 OF oMainWnd PIXEL

	     nLinha:=5
	     nTam:=100

	     @nLinha,001 MSPANEL oPanItem Prompt "" Size 150,125 of oDlg_wk
	     oPanItem:CTITLE:="IMPOSTOS E DESPESAS DA DI"
	     nLinha+=04
	     nLinAux:=nLinha

	     IF nTela = INCLUSAO .OR. nTela = ALTERACAO

	        IF (lTemDespesas .OR. !lMarcadoSempreImp) .AND. lDsbBtn1
	           @nLinha,nColB BUTTON "Des / Marca Todas Despesas" SIZE nLarg1,nAltu1 ACTION (Processa( {|| PCOMarca(.T.,!lMarcadoSempreImp) })) of oPanItem Pixel MESSAGE "Desmarca / Marca Todos as Despesas"
	           nLinha+=nPula
	        ENDIF
	        IF lDsbBtn1
	           @nLinha,nColB BUTTON "Gravar Valores"      SIZE nLarg1,nAltu1 ACTION (EVAL(bOkGra)) of oPanItem Pixel MESSAGE "Grava Todos Valores da Tela"
	           nLinha+=nPula
	        ENDIF

	        IF nTela = ALTERACAO .AND. lDsbBtn2
	           @nLinha,nColB BUTTON "Excluir Valores"  SIZE nLarg1,nAltu1 ACTION (EVAL(bOkExc)) of oPanItem Pixel MESSAGE "Exclui Todos Valores da Tela e Sai"
	           nLinha+=nPula
	        ENDIF

	        IF lMV_EASY .AND. lImportador
	           @nLinha,nColB BUTTON "Altera Taxas Todos Itens" SIZE nLarg1,nAltu1 ACTION (PCOTaxaTela(.T.)) of oPanItem Pixel MESSAGE "Altera Taxas D.I. de FOB, Frete e Seguro de Todos os Itens"
	           nLinha+=nPula
	           @nLinha,nColB BUTTON "Gerar P.V."               SIZE nLarg1,nAltu1 ACTION ( IF(PCO_VAL_PV(),EVAL(bOkGer),) ) of oPanItem Pixel MESSAGE "Grava valores da tela e gera o Pedido de Venda (SIGAFAT)"
	           nLinha+=nPula
	        ELSEIF !lIntegrouNFT
	           @nLinha,nColB BUTTON "Digitacao No. NFT Itens"  SIZE nLarg1,nAltu1 ACTION ( Processa( {|| PCOGetNota()} ) ) of oPanItem Pixel MESSAGE "Digitacao do Numero e Serie NFT dos Itens"
	           nLinha+=nPula
	           IF lAdquirente
	              @nLinha,nColB BUTTON "Gerar NFT"         SIZE nLarg1,nAltu1 ACTION (IF(ImpPCOVal("GERAR_NFT"),EVAL(bOkGer),)) of oPanItem Pixel MESSAGE "Grava valores da tela e gera a NF de Transferencia de Posse"
	              nLinha+=nPula
	           ENDIF
	        ENDIF

	        //OAP - Inseção do botão para geração do relatório de quantidades de itens por PO.
	        If lImportador
	           @nLinha,nColB BUTTON "Relat. de Status dos Itens"  SIZE nLarg1,nAltu1 ACTION ( Processa( {|| EICSTATPROD()} ) ) of oPanItem Pixel MESSAGE "Relatorio de status dos itens importados por conta e ordem        "
	           nLinha+=nPula
	        EndIf

	        bOk:={|| IF(MSGYESNO("Confirma Gravacao dos Valores?"),(oDlg_wk:End(),nBotao:=5),) }

	        IF(EasyEntryPoint("EICCO100"),Execblock("EICCO100",.F.,.F.,"TELA_INC_ALT"),)  // GFP - 05/03/2013

	     ELSEIF nTela = ESTORNO

	        IF lMV_EASY .AND. lImportador
	           @nLinha,nColB BUTTON "Estorna P.V." SIZE nLarg1,nAltu1 ACTION (EVAL(bOkEst)) of oPanItem Pixel MESSAGE "Estorna só o Pedido de Venda"
	           nLinha+=nPula
	        ELSEIF lAdquirente
	           @nLinha,nColB BUTTON If(lIntNFTEAI .And. lNFTPendEAI,"Integracao","Estorna NFT")  SIZE nLarg1,nAltu1 ACTION (EVAL(bOkEst)) of oPanItem Pixel MESSAGE "Estorna só a Nota Fiscal de Transferencia de Posse"
	           nLinha+=nPula

              If lIntNFTEAI .And. cNivel >= nNvlForEst .And. !lNFTPendEAI
                 @nLinha,nColB BUTTON STR0002 SIZE nLarg1,nAltu1 ACTION (EVAL(bOkEstForc)) of oPanItem Pixel MESSAGE "Estorno forçado sem integração com ERP"
                 nLinha+=nPula
              EndIf
              	           
	           IF lSoLeNFT
	              @nLinha,nColB BUTTON "Impressao NFT"  SIZE nLarg1,nAltu1 ACTION (PCOImprNFT(.F.)) of oPanItem Pixel MESSAGE "Imprimi os valores da Nota Fiscal de Transferencia de Posse"
	              nLinha+=nPula
	           ENDIF
	        ENDIF
	        bOk:=bOkEst

	     ENDIF

	     nLinha:=nLinAux
	     WorkMarca->(DBGOTOP())
	     oMark1:= MsSelect():New("WorkMarca","WK_FLAG",,aTBCampos1,.F.,@cMarca,{nLinha,001,(nLinha+nTam),nColA},,,oPanItem)//(oDlg_WK:nClientWidth-4)/2
	     IF nTela = INCLUSAO .OR. nTela = ALTERACAO
	        oMark1:bAval:={||  PCOMarca(.F.,!lMarcadoSempreImp) }
	     ELSE
	        oMark1:bAval:={|| .T. }
	     ENDIF
	     nLinha+=nTam+3

	     @nLinha,005 SAY ("ITENS DO PROCESSO") PIXEL of oPanItem

	     nLinha-=02
	     IF nTela # ESTORNO .AND. lCalcNFT
	        @nLinha,nCol1 BUTTON "Altera Taxas Todos Itens"  SIZE nLarg2,nAltu2 ACTION (PCOTaxaTela(.T.))                  of oPanItem Pixel MESSAGE "Altera Taxas de Todos os Itens"
	        @nLinha,nCol2 BUTTON "Des / Marca Todos Itens"   SIZE nLarg2,nAltu2 ACTION (Processa( IF(lNftFilha,{|| PCO2Click(oMark2:oBrowse,"WorkItens","ALL") },{|| PCOMrcaItem(.T.) })));
	                                                                                                                       of oPanItem Pixel MESSAGE "Desmarca / Marca Todos os Itens"
	        @nLinha,nCol3 BUTTON "Altera Itens Marcados"     SIZE nLarg2,nAltu2 ACTION (PCOTaxaTela(.F.))                  of oPanItem Pixel MESSAGE "Altera Itens Marcados" //LGS-19/09/2014
	     ENDIF
	     nLinha+=20

	     IF lNftFilha
			 cCampoSWN := ""
	        aHeader   := PCOGrvHeader()
	        IF nTela # ESTORNO .AND. lCalcNFT
	           cCampoSWN := "WN_QUANT"
	        ENDIF
	     	 DBSELECTAREA("WorkItens")
        	 WorkItens->(DBSETORDER(0))
        	 WorkItens->(DBGOTOP())
        	 oMark2:=MsGetDb():New(nLinha,01,(oDlg_WK:nClientHeight-6)/2,(oDlg_WK:nClientWidth-4)/2,2    ,        ,       ,        ,.F.    ,{cCampoSWN},       ,      ,    ,"WorkItens",        ,            ,.F.    ,oDlg_WK,         ,      ,,)
			 oPanItem:Align      := CONTROL_ALIGN_TOP
			 oMark2:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT
        	 b2Click:=oMark2:oBrowse:bLDblClick
        	 oMark2:oBrowse:bLDblClick := { || PCO2Click(oMark2:oBrowse,"WorkItens") }
        	 oMark2:oBrowse:bAdd := {||.F.} // não inclui novos itens MsGetDb()
        	 oDlg_wk:lMaximized  := .T.
        	 oMark2:oBrowse:Refresh()
	     ELSE
	     	 WorkItens->(DBGOTOP())
	    	 oMark2:= MsSelect():New("WorkItens","WK_FLAG",,aTBCampos2,.F.,@cMarca,{nLinha,01,(oDlg_WK:nClientHeight-6)/2,(oDlg_WK:nClientWidth-4)/2},,,oDlg_wk)
			 IF nTela # ESTORNO .AND. lCalcNFT
				 oMark2:bAval:={|| PCOMrcaItem(.F.) }
			 ENDIF
			 oPanItem:Align      := CONTROL_ALIGN_TOP
			 oMark2:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT
			 oDlg_wk:lMaximized  := .T.
	     ENDIF

	   ACTIVATE MSDIALOG oDlg_wk ON INIT (EnchoiceBar(oDlg_wk,bOk,bCancel,,aBotoes))


	   IF nBotao # 0

	      IF nBotao = 1 .OR. nBotao = 3 .OR. nBotao = 5//Gravar Botao ou Gravar OK ou Gerar
	         Processa( {|| PCOLeGrava(.F.,nBotao)},,"Gravando Valores...")
	         IF nBotao = 1
	            nTela := ALTERACAO
	            IF MSGYESNO("Dados gravados com sucesso. Deseja Sair?")
	               EXIT
	            ENDIF
	            LOOP
	         ENDIF
	      ELSEIF nBotao = 2//Excluir
	         Processa( {|| PCOEstorno(.F.)},,"Excluindo Valores...")
	      ENDIF

	      IF nBotao = 3//Gerar

	         IF lMV_EASY .AND. lImportador
	            IF !PCO_PV()
	               LOOP
	            ENDIF
	         ELSE
	            lGerar:=.F.
	            Processa( {|| lGerar:=EICGerNFT(.T.)},,"Lendo Dados...")
	            IF !lGerar
	                LOOP
	            ENDIF
	         ENDIF

	      ELSEIF nBotao = 4//Estornar

	         IF lMV_EASY .AND. lImportador
	            IF !PCO_PV()
	               MSGINFO("Os valores foram gravados, mas o PV nao foi gerado.")
	               LOOP
	            ENDIF
	         ELSE
	            lEstorno:=.F.
	            Processa( {|| lEstorno:=EICGerNFT(.F.)},,"Estornando NFT...")
	            IF !lEstorno
	               MSGINFO("Os valores foram gravados, mas a nota NFT nao foi estornada.")
	               LOOP
	            ENDIF
	         ENDIF

	      ELSEIF nBotao = 10//Botao xiszinho da tela

	         IF MSGYESNO("Confirma Saida ?")
	            EXIT
	         ENDIF

	      ENDIF

	   ENDIF

	   EXIT

	ENDDO

	If lNftFilha
	   If nBotao == 0 .OR. nBotao == 1 .OR. nBotao == 2 .OR. nBotao == 5
	   	  PCOCloseWrk()
	   EndIf
	Else
	   PCOCloseWrk()
	EndIf

	SWN->(DBSETORDER(3))//WN_FILIAL+WN_HAWB+WN_TIPO_NF

End Sequence

Return .T.
*==============================================*
STATIC FUNCTION PCOCloseWrk()
*==============================================*
SW6->(MsUnlock())
WorkMarca->((E_EraseArq(cFileMarca)))
WorkItens->((E_EraseArq(cFileItens)))
WorkDespesa->((E_EraseArq(cFileDesp)))
WorkTaxa->((E_EraseArq(cFileTaxa)))
return .T.
*==============================================*
STATIC FUNCTION PCOTaxaTela(lTaxa)
*==============================================*
LOCAL nLinha:=02,T
LOCAL nCol1 :=003
LOCAL nCol2 :=nCol1+35
LOCAL nCol3 :=nCol2+80
LOCAL nCol4 :=nCol3+40
LOCAL oMark4,cPicture:=AVSX3("WW_VALOR",6)
LOCAL cPictPer:="@E 999.99"
LOCAL oDlgTaxa,nTam:=50,nTam2:=35,nPula:=15
LOCAL bOk    := {|| lOK:=.T. , (oDlgTaxa:End()) }
LOCAL bCancel:= {|| (oDlgTaxa:End()) }

nFreteReal:=nSeguroReal:=NIL//Varaivel Usada no programa EICDI154.PRW na funcao DI154Grava() linha + - 3043

IF lTaxa
   IF WorkTaxa->(EOF()) .AND. WorkTaxa->(BOF())
      MSGSTOP("Nao existe taxas de FOB / Frete / Seguro para alteracao.")
      RETURN .F.
   ENDIF
   aHeader:={}
   AADD(aHeader  ,{""         ,"WK_MARCA"  ,"@BMP"               ,4                    ,0                   ,""          ,""      ,""     ,""        ,""} )
   AADD(aHeader  ,{"Documento","WN_INVOICE","@!"                 ,AVSX3("W9_INVOICE",3),0                   ,""          ,""      ,"C"    ,""        ,""} )
   AADD(aHeader  ,{"Moeda"    ,"W9_MOE_FOB","@!"                 ,AVSX3("W9_MOE_FOB",3),0                   ,""          ,""      ,"C"    ,""        ,""} )
   AADD(aHeader  ,{"Taxa DI"  ,"W9_TX_FOB" ,AVSX3("W9_TX_FOB" ,6),AVSX3("W9_TX_FOB", 3),AVSX3("W9_TX_FOB",4),""          ,""      ,"N"    ,""        ,""} )
   AADD(aHeader  ,{"Taxa NFT" ,"WKNOVATAXA",AVSX3("W9_TX_FOB" ,6),AVSX3("W9_TX_FOB", 3),AVSX3("W9_TX_FOB",4),"Positivo()",""      ,"N"    ,""        ,""} )
   //AADD(aHeader,{X3Titulo() ,x3_Campo    ,x3_picture           ,x3_tamanho           ,x3_decimal          ,x3_valid    ,x3_usado,x3_tipo,x3_arquivo,x3_context}))

   DBSELECTAREA("WorkTaxa")
   IF !EMPTY(SW6->W6_DTREG_D)
      dData :=SW6->W6_DTREG_D-1
   ELSE
      dData :=dDataBase
   ENDIF
   nLimfim:=250
   nComfim:=450
ELSE
   nLimfim:=150
   nComfim:=350
   lTemMarcado:=.F.
   WorkItens->(DBGOTOP())
   DO WHILE WorkItens->(!EOF())
      IF !EMPTY(WorkItens->WK_FLAG)
         lTemMarcado:=.T.
         EXIT
      ENDIF
      WorkItens->(DBSKIP())
   ENDDO
   WorkItens->(DBGOTOP())
   IF !lTemMarcado
      MSGSTOP("Nao existem itens marcados.")
      RETURN .F.
   ENDIF
ENDIF
nIPITx   :=WorkItens->WKIPITX
nICMSTx  :=WorkItens->WKICMS_A
cOperacao:=WorkItens->WKOPERACAO

DO WHILE .T.

   lOK:=.F.
   nLinha:=02
   DEFINE MSDIALOG oDlgTaxa TITLE IF(lTaxa,"Recalculo dos valores de FOB, Frete e Seguro","Recalculo dos valores de IPI e ICMS") ;
       FROM 0,0 TO nLimfim,nComfim OF oMainWnd PIXEL


     IF lTaxa

        @001,001 MSPANEL oPanDesp Prompt "" Size 145,015 of oDlgTaxa

        @nLinha,nCol1 BUTTON "Busca Taxa dos Documentos Marcados:" SIZE 99,11 ACTION (NFBuscaTaxa()) OF oPanDesp Pixel
        @nLinha,nCol3 SAY "Data da Busca" PIXEL OF oPanDesp
        @nLinha,nCol4 MSGET dData         PIXEL SIZE nTam,9 Picture "@D" OF oPanDesp VALID NaoVazio(dData)
        nLinha+=10

     ELSE

        @001,001 MSPANEL oPanDesp Prompt "" Size 145,050 of oDlgTaxa

        @nLinha,nCol1 SAY "Operacao"  PIXEL OF oPanDesp
        @nLinha,nCol2 MSGET cOperacao PIXEL SIZE nTam2,8 OF oPanDesp VALID ImpPCOVal("CFO") F3 "SWZ" WHEN !lTaxa//ExistCpo("SWZ",cOperacao,2)
        nLinha+=nPula

        @nLinha,nCol1 SAY "Aliquota ICMS" PIXEL OF oPanDesp
        @nLinha,nCol2 MSGET nICMSTx       PIXEL SIZE nTam2,8 Picture cPictPer OF oPanDesp VALID Positivo() WHEN !lTaxa
        nLinha+=nPula

        @nLinha,nCol1 SAY "Aliquota IPI"  PIXEL OF oPanDesp
        @nLinha,nCol2 MSGET nIPITx        PIXEL SIZE nTam2,8 Picture cPictPer OF oPanDesp VALID Positivo() WHEN !lTaxa
        nLinha+=nPula

     ENDIF

     oPanDesp:Align := CONTROL_ALIGN_TOP

     IF lTaxa

        DBSELECTAREA("WorkTaxa")
        WorkTaxa->(DBSETORDER(0))
        WorkTaxa->(DBGOTOP())
        oMark4:=MsGetDb():New(nLinha,005,(nLinha+nTam),(oDlgTaxa:nClientWidth-9)/2,2    ,        ,       ,        ,.F.    ,{"WKNOVATAXA"},       ,      ,    ,"WorkTaxa",        ,            ,.F.    ,oDlgTaxa,         ,      ,,)
//              MsGetDb():New(nT    ,nL ,nB           ,nR                         ,nOpcX,cLinhaOk,cTudoOk,cIniCpos,lDeleta,aAlter        ,nFreeze,lEmpty,nMax,cTrb      ,cFieldOk,lCondicional,lAppend,oWnd    ,lDisparos,lIndex,cDelOk         ,cSuperDel)
        oMark4:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT
        b2Click:=oMark4:oBrowse:bLDblClick
        oMark4:oBrowse:bLDblClick := { || PCO2Click(oMark4:oBrowse,"WorkTaxa") }
        oMark4:oBrowse:bAdd  := {||.F.} // não inclui novos itens MsGetDb()

     ENDIF

   ACTIVATE MSDIALOG oDlgTaxa ON INIT  EnchoiceBar(oDlgTaxa,bOk,bCancel,,)  CENTERED

IF lOK
   lEmBranco:=.F.
   lAlterou:=.F.

   IF lTaxa
      WorkTaxa->(DBSETORDER(1))
      WorkTaxa->(DBGOTOP())
      DO WHILE WorkTaxa->(!EOF())

         IF EMPTY(WorkTaxa->WKNOVATAXA)
            lEmBranco:=.T.
            EXIT
         ENDIF
         IF WorkTaxa->WN_INVOICE = "FATURAS"
            IF (nPos:=ASCAN(aTabTaxas,{ |M|  M[1] == WorkTaxa->W9_MOE_FOB } )) # 0
               IF (WorkTaxa->WKOLDTAXA # WorkTaxa->WKNOVATAXA)
                  lAlterou:=.T.
                  aTabTaxas[nPos,2]  :=WorkTaxa->WKNOVATAXA//Usado no programa EICDI154.PRW na funcao DI154TaxaFOB() linha + - 8000
                  WorkTaxa->WKOLDTAXA:=WorkTaxa->WKNOVATAXA
               ENDIF
            ENDIF

         ELSEIF WorkTaxa->WN_INVOICE = "FRETE"
            IF (WorkTaxa->WKOLDTAXA # WorkTaxa->WKNOVATAXA)
               lAlterou:=.T.
               WorkTaxa->WKOLDTAXA:=WorkTaxa->WKNOVATAXA
            ENDIF
            nFreteReal:= ROUND((ValorFrete(SW6->W6_HAWB,,,2) * WorkTaxa->WKNOVATAXA),2)//Varaivel Usada no programa EICDI154.PRW na funcao DI154Grava() linha + - 3043

         ELSEIF WorkTaxa->WN_INVOICE = "SEGURO"
            IF (WorkTaxa->WKOLDTAXA # WorkTaxa->WKNOVATAXA)
               lAlterou:=.T.
               WorkTaxa->WKOLDTAXA:=WorkTaxa->WKNOVATAXA
           ENDIF
           nSeguroReal:= ROUND(SW6->W6_VL_USSE * WorkTaxa->WKNOVATAXA,2)//Varaivel Usada no programa EICDI154.PRW na funcao DI154Grava() linha + - 3043

         ENDIF

         WorkTaxa->(DBSKIP())
      ENDDO
      IF lEmBranco
         MSGSTOP("Taxa do(as) "+LOWER(RTRIM(WorkTaxa->WN_INVOICE))+" nao preenchida.")
         LOOP
      ENDIF
      IF lAlterou
         Processa( {|| EICNFCalc(.F.) },, "Recalculando Valores...")
      ENDIF

   ELSE

      WorkItens->(DBGOTOP())
      DO WHILE WorkItens->(!EOF())

         IF EMPTY(WorkItens->WK_FLAG)
            WorkItens->(DBSKIP())
            LOOP
         ENDIF
         IF WorkItens->WKIPITX # nIPITx
            WorkItens->WKIPITX :=nIPITx
            lAlterou := .T.
         ENDIF
         IF WorkItens->WKICMS_A # nICMSTx
            WorkItens->WKICMS_A :=nICMSTx
            lAlterou := .T.
         ENDIF
         IF WorkItens->WKOPERACAO # cOperacao
            WorkItens->WKOPERACAO :=cOperacao
            lAlterou := .T.
         ENDIF
         IF lAlterou
            PCOCalcImposto()
         ENDIF

         WorkItens->(DBSKIP())
      ENDDO

   ENDIF

ENDIF

WorkItens->(DBGOTOP())

EXIT

ENDDO

IF lNftFilha .AND. lTaxa
   aHeader := PCOGrvHeader()
ENDIF

Return .T.
*==============================================*
STATIC FUNCTION ImpPCOVal(cOrigem)
*==============================================*
PCOInitVar()

IF cOrigem = "CFO"

   IF EMPTY(cOperacao)
      RETURN .T.
   ENDIF

   SWZ->(DBSETORDER(2))
   IF !SWZ->(DBSEEK(cFilSWZ+cOperacao))//Ordem 2 do SWZ
      MSGSTOP("Operacao nao cadastrada.")
      RETURN .F.
   ELSE
      IF EMPTY(nICMSTx)
         nICMSTx:=SWZ->WZ_AL_ICMS
      ENDIF
   ENDIF

ELSEIF cOrigem = "GERAR_NFT"

   DO WHILE .T.

      WorkItens->(DBGOTOP())
      lBranco:=.F.
      DO WHILE WorkItens->(!EOF()) .AND. !lNFAuto
         IF lNftFilha
            IF WorkItens->WK_FLAG == "LBOK" .AND. EMPTY(WorkItens->WN_DOC)
               lBranco:=.T.
               EXIT
         	ENDIF
         ELSE
         	IF EMPTY(WorkItens->WN_DOC)
               lBranco:=.T.
               EXIT
         	ENDIF
         ENDIF
         WorkItens->(DBSKIP())

      ENDDO
      WorkItens->(DBGOTOP())

      IF lBranco

         MSGSTOP("Existem itens sem Numero de Nota digitado.")

         lRetorno:=.F.
         Processa( {|| lRetorno:=PCOGetNota()} )
         IF !lRetorno
            RETURN .F.
         ENDIF

         LOOP

      ENDIF

      EXIT

   ENDDO

   IF !MSGYESNO("Confirma Gravacao dos Valores e Geracao da NFT ?")
      RETURN .F.
   ENDIF

ENDIF

RETURN .T.

*==============================================*
STATIC FUNCTION NFBuscaTaxa()
*==============================================*
WorkTaxa->(DBGOTOP())
DO WHILE WorkTaxa->(!EOF())

   IF WorkTaxa->WK_MARCA = "LBOK"
      WorkTaxa->WKNOVATAXA:=BuscaTaxa(WorkTaxa->W9_MOE_FOB,dData,.T.,.F.,.T.)
   ENDIF

   WorkTaxa->(DBSKIP())
ENDDO
WorkTaxa->(DBGOTOP())

Return .T.
*==============================================*
STATIC FUNCTION PCO2Click(oMarca,cAlias,cTodos)
*==============================================*
Default cTodos := ""
IF oMarca:nColPos = 1
   IF cAlias == "WorkTaxa"
	  IF WorkTaxa->WK_MARCA = "LBOK"
	     WorkTaxa->WK_MARCA = "LBNO"
	  ELSE
	     WorkTaxa->WK_MARCA = "LBOK"
	  ENDIF
   ENDIF
   IF cAlias == "WorkItens"
	  IF Empty(cTodos)
	  	 IF WorkItens->WK_FLAG = "LBOK"
	     	WorkItens->WK_FLAG = "LBNO"
	  	 ELSE
	     	WorkItens->WK_FLAG = "LBOK"
	  	 ENDIF
	  ELSE
	     WorkItens->(DbGoTop())
	     DO WHILE WorkItens->(!Eof())
	        IF WorkItens->WK_FLAG = "LBOK"
	     	   WorkItens->WK_FLAG = "LBNO"
	  	    ELSE
	     	   WorkItens->WK_FLAG = "LBOK"
	  	    ENDIF
	        WorkItens->(DbSkip())
	     ENDDO
	     WorkItens->(DbGoTop())
	     oMark2:oBrowse:Refresh()
	  ENDIF
   ENDIF
ELSE
   Return EVAL(b2Click)
ENDIF
Return .T.
*==============================================*
STATIC FUNCTION PCODespTela(nTela)
*==============================================*
LOCAL nLinha:=02
LOCAL nCol1 :=005,nCol2:=nCol1+25
LOCAL nCol3 :=110,nCol4:=nCol3+25
LOCAL nCol5 :=nCol4+80,nCol6:=nCol5+35
LOCAL oMark3,cPicture:=AVSX3("WW_VALOR",6)
LOCAL cPictPer:="@E 999.99"
LOCAL oDlg_Desp,nTam:=65,nTam2:=35,nPula:=15
LOCAL bOk    := {|| lOK:=.T. , (oDlg_Desp:End()) }
LOCAL bCancel:= {|| (oDlg_Desp:End()) }
LOCAL aTBCampos3:={}, lWhen:=.F.
LOCAL cFiltro := ""  // JWJ 10/06/2009: o CTREE dá erro se o filtro é vinculado direto entre works. Deve-se armazenar o filtro em string primeiro.

AADD(aTBCampos3,{"WW_DESPESA",,"Despesa",})
AADD(aTBCampos3,{"WW_VALOR"  ,,"Valor"    ,AVSX3("WW_VALOR",6),})
AADD(aTBCampos3,{"WKORIGEM"  ,,"Origem",})
AADD(aTBCampos3,{{|| WorkDespesa->("["+WW_PO_NUM+"]+["+WW_NR_CONT+"]+["+WW_PGI_NUM+"]+["+WW_LOTECTL+"]+["+WW_INVOICE+"]")},,"PO+Posicao+PGI+Lote+Invoice",})

//Esta com IF(EMPTY(WorkItens->WN_INVOICE) na INVOICE pode ocorrer de nao existir o campo WW_INVOICE ou nao estar preenchido na base por causa de uma virada se versão.
DBSELECTAREA("WorkDespesa")

IF EMPTY(WorkItens->WN_INVOICE)
   cFiltro := WorkItens->(WN_PO_EIC+WN_ITEM+WN_PGI_NUM+WV_LOTE)
   SET FILTER TO WorkDespesa->WW_PO_NUM+WorkDespesa->WW_NR_CONT+WorkDespesa->WW_PGI_NUM+WorkDespesa->WW_LOTECTL == cFiltro
ELSE
   cFiltro := WorkItens->(WN_PO_EIC+WN_ITEM+WN_PGI_NUM+WV_LOTE+WN_INVOICE)
   SET FILTER TO WorkDespesa->WW_PO_NUM+WorkDespesa->WW_NR_CONT+WorkDespesa->WW_PGI_NUM+WorkDespesa->WW_LOTECTL+WorkDespesa->WW_INVOICE == cFiltro
ENDIF
DEFINE MSDIALOG oDlg_Desp TITLE "Despesas/Impostos da NFE rateadas por Item" ;
       FROM 0,0 TO oMainWnd:nBottom-180,oMainWnd:nRight-180 OF oMainWnd PIXEL

  IF nTela = INCLUSAO

     @001,001 MSPANEL oPanDesp Prompt "" Size 150,050 of oDlg_Desp

     @nLinha,nCol1 SAY "Produto" PIXEL OF oPanDesp
     @nLinha,nCol2 MSGET WorkItens->WN_PRODUTO PIXEL SIZE nTam,8 WHEN .F. OF oPanDesp
     @nLinha,nCol3 SAY "P.I.S." PIXEL OF oPanDesp
     @nLinha,nCol4 MSGET WorkItens->WN_VLRPIS  PIXEL SIZE nTam,8 Picture cPicture WHEN lWhen OF oPanDesp
     nLinha+=nPula

     @nLinha,nCol1 SAY "I.I."  PIXEL OF oPanDesp
     @nLinha,nCol2 MSGET WorkItens->WN_IIVAL   PIXEL SIZE nTam,8 Picture cPicture WHEN lWhen OF oPanDesp
     @nLinha,nCol3 SAY "COFINS" PIXEL OF oPanDesp
     @nLinha,nCol4 MSGET WorkItens->WN_VLRCOF  PIXEL SIZE nTam,8 Picture cPicture WHEN lWhen OF oPanDesp
     nLinha+=nPula

     @nLinha,nCol1 SAY "I.P.I." PIXEL OF oPanDesp
     @nLinha,nCol2 MSGET WorkItens->WN_IPIVAL  PIXEL SIZE nTam,8 Picture cPicture WHEN lWhen OF oPanDesp
     @nLinha,nCol3 SAY "I.C.M.S." PIXEL OF oPanDesp
     @nLinha,nCol4 MSGET WorkItens->WN_VALICM  PIXEL SIZE nTam,8 Picture cPicture WHEN lWhen OF oPanDesp
     nLinha+=nPula

     oPanDesp:Align := CONTROL_ALIGN_TOP

  ENDIF

   WorkDespesa->(DBGOTOP())
   oMark3:= MsSelect():New("WorkDespesa",,,aTBCampos3,.F.,@cMarca,{nLinha,002,(oDlg_Desp:nClientHeight-4)/2,(oDlg_Desp:nClientWidth-4)/2},,,oDlg_Desp)
   oMark3:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg_Desp ON INIT EnchoiceBar(oDlg_Desp,bOk,bCancel,,) CENTERED

DBSELECTAREA("WorkDespesa")
SET FILTER TO

Return .T.

*-----------------------------------*
STATIC FUNCTION PCOGerar(lSoLeNFT)
*-----------------------------------*
LOCAL nTotItem:=0,nTotal:=15,M
LOCAL lRatDspCIF_II  := lRateioCIF .And. EasyGParam("MV_EIC0021",,.F.)                 //NCF - 27/12/2012 - Apuração de despesas não base rateadas por CIF+II

//FDR - 08/01/13 - Variável alterada para private para utilização no PE
Private aWorkMarca:={}
Private nRateio := 0
Private MPE

PCOInitVar()

nCont:=0
ProcRegua(nTotal)
//======================================================= SWD - Le despesas so desembaraco
SWW->(DBSETORDER(2))//WW_FILIAL+WW_HAWB+WW_TIPO_NF
lTemSWW:=SWW->(DBSEEK(cFILSWW+SW6->W6_HAWB)) .AND. SWW->WW_TIPO_NF # "4"//Se nao tem nada no SWW é para ler todas as despesas do SWD

SWD->(DBSETORDER(1))//WW_FILIAL+WW_HAWB+WW_TIPO_NF
SWD->(DBSEEK(cFILSWD+SW6->W6_HAWB))
DO WHILE SWD->(!EOF()) .AND.;
         SWD->WD_FILIAL == cFILSWD .AND.;
         SWD->WD_HAWB   == SW6->W6_HAWB .AND. !lSoLeNFT

   IF nCont > nTotal
      ProcRegua(nTotal)
      nCont:=0
   ENDIF
   nCont++
   IncProc("Lendo Despesa: "+ALLTRIM(SWD->WD_DESPESA))

   IF (LEFT(SWD->WD_DESPESA,1) $ "1,2,7,9") .OR. (!EMPTY(SWD->WD_NF_COMP) .AND. lTemSWW)
      SWD->(DBSKIP())
      LOOP
   ENDIF

   cDesp:=LEFT(SWD->WD_DESPESA,3)
   SYB->(DBSEEK(cFilSYB+cDesp))

   IF (nPos:=ASCAN(aWorkMarca,{|A| LEFT(A[1],3) = cDesp })) = 0
      AADD(aWorkMarca,{ SWD->WD_DESPESA+"-"+SYB->YB_DESCR , SWD->WD_VALOR_R, DESEMBARACO , SYB->YB_RATPESO, SYB->YB_BASEICM, SYB->YB_BASEIMP }) //LGS-26/01/2015
   ELSE
      aWorkMarca[nPos,2]+=SWD->WD_VALOR_R
   ENDIF
   lTemDespesas:=.T.
   SWD->(DBSKIP())

ENDDO
//======================================================= SWD - Le despesas so desembaraco

//======================================================= SWN - Le os itens das Notas
SWN->(DBSETORDER(3))//WN_FILIAL+WN_HAWB+WN_TIPO_NF
cTipo:="1"
lAchouNF:=SWN->(DBSEEK(cFilSWN+SW6->W6_HAWB+cTipo))
IF !lAchouNF
   cTipo:="3"
   lAchouNF:=SWN->(DBSEEK(cFilSWN+SW6->W6_HAWB+cTipo))
ENDIF

IF lSoLeNFT
   cTipo:="9"
   lAchouNF:=SWN->(DBSEEK(cFilSWN+SW6->W6_HAWB+cTipo))
ENDIF

IF lAchouNF

   IF SWN->WN_TIPO_NF = "1"
      cTipoNF:=NFP
   ELSEIF SWN->WN_TIPO_NF = "3"
      cTipoNF:=NFU
   ELSEIF SWN->WN_TIPO_NF = "9"
      cTipoNF:=NFT
   ENDIF

   DO WHILE SWN->(!EOF()) .AND.;
            SWN->WN_FILIAL  == cFILSWN .AND.;
            SWN->WN_HAWB    == SW6->W6_HAWB .AND.;
            SWN->WN_TIPO_NF == cTipo

      IF nCont > nTotal
         ProcRegua(nTotal)
         nCont:=0
      ENDIF
      nCont++
      IncProc("Lendo Item: "+ALLTRIM(SWN->WN_PRODUTO))

      WorkItens->(DBAPPEND())

      AVREPLACE("SWN","WorkItens")

      SB1->(DBSEEK(cFilSB1+SWN->WN_PRODUTO))
      WorkItens->B1_DESC   :=SB1->B1_DESC
      WorkItens->WKOPERACAO:=SWN->WN_OPERACA
      WorkItens->WKIPITX   :=SWN->WN_IPITX
      WorkItens->WKICMS_A  :=SWN->WN_ICMS_A

      IF lSoLeNFT
         WorkItens->WKVALOR   :=SWN->WN_DESPESAS
         WorkItens->WKIPIBASE :=SWN->WN_IPIBASE
         WorkItens->WKIIBASE  :=SWN->WN_CIF
         WorkItens->WKIPITX   :=SWN->WN_IPITX
         WorkItens->WKIPIVAL  :=SWN->WN_IPIVAL
         WorkItens->WKBASEICMS:=SWN->WN_BASEICM
         WorkItens->WKICMS_A  :=SWN->WN_ICMS_A
         WorkItens->WKVL_ICM  :=SWN->WN_VALICM
         If lIntNFTEAI
            SF1->(DBSETORDER(1))//F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
            SF1->(DBSeek(xFilial("SF1")+SWN->(WN_DOC+WN_SERIE+WN_FORNECE+WN_LOJA+AvKey("N","F1_TIPO"))))
            WorkItens->WKSTATUS  := SF1->F1_STATUS
            WorkItens->WKMENNOTA := SF1->F1_MENNOTA
            WorkItens->WK_OK     := SF1->F1_OK
            If SWN->(FIELDPOS("WN_DOCORI" )) # 0 .AND. SWN->(FIELDPOS("WN_SERORI" )) # 0
               WorkItens->WKNOTAPR  := SWN->WN_DOCORI
               WorkItens->WKSERIEPR := SWN->WN_SERORI       
            EndIf
         EndIf
      ELSE
         WorkItens->WN_DOC    :=""
         WorkItens->WN_SERIE  :=""
      ENDIF

      If EasyGParam("MV_EIC0027",,.F.)  // GFP - 27/03/2013
         WorkItens->WKPISVAL := SWN->WN_VLRPIS
         WorkItens->WKCOFVAL := SWN->WN_VLRCOF
         If EIW->(FieldPos("EIW_BASEPC")) # 0   // GFP - 11/07/2013
            WorkItens->WKBASEPC := SWN->WN_BASPIS
         EndIf
         If EIW->(FieldPos("EIW_PERPIS")) # 0   // GFP - 03/12/2015
	         WorkItens->WKPERPIS := SWN->WN_PERPIS
	      EndIf
	      If EIW->(FieldPos("EIW_PERCOF")) # 0   // GFP - 03/12/2015
	         WorkItens->WKPERCOF := SWN->WN_PERCOF
	      EndIf
      EndIf

      SWN->(DBSKIP())

   ENDDO

ELSE

   //========================== Le os itens das Notas Calculada automatica
   cTipoNF:=CALCULADO

   IF !EICNFCalc(.T.)
      MSGINFO("Para ajudar na correcao, tente gerar a nota fiscal de Entrada.")
      RETURN .F.
   ENDIF
   //========================== Le os itens das Notas Calculada automatica

ENDIF
//======================================================= SWN - Le os itens das Notas

//======================================================= WorkItens - Soma os impostos dos itens
ProcRegua(nTotItem:=WorkItens->(LASTREC()))

nCIFTotal:=nFOBTotal:=nPesototal:=nBaseIITotal:=nII_Total:=0            //NCF - 27/12/2012 - Rateio das despesas por CIF+II

WorkItens->(DBGOTOP())

DO WHILE WorkItens->(!EOF())

   IncProc("Lendo Item: "+ALLTRIM(WorkItens->WN_PRODUTO))

   IF !lSoLeNFT
      PCOCalcImposto()
   ENDIF

   nPesoTotal+=WorkItens->WN_PESOL
   nFOBTotal +=WorkItens->WN_FOB_R
   //IF lRateioCIF
      nCIFTotal+=(WorkItens->WN_FOB_R+WorkItens->WN_FRETE+WorkItens->WN_SEGURO)
   //ENDIF

   If lRatDspCIF_II                                     //NCF - 27/12/2012 - Rateio das despesas por CIF+II
      nII_Total     += WorkItens->WN_IIVAL
      nBaseIITotal  += WorkItens->WKIIBASE
   EndIf

   nPos:=0
   IF !lSoLeNFT
      IF (nPos:=ASCAN(aWorkMarca,{|A|A[1]=COD_II })) = 0
         AADD(aWorkMarca,{COD_II,WorkItens->WN_IIVAL,cTipoNF,"",.T.,.T.})
      ELSE
         aWorkMarca[nPos,2]+=WorkItens->WN_IIVAL
      ENDIF

      IF (nPos:=ASCAN(aWorkMarca,{|A|A[1]=COD_PIS })) = 0
         AADD(aWorkMarca,{COD_PIS,WorkItens->WN_VLRPIS,cTipoNF,"",.T.,.T.})
      ELSE
         aWorkMarca[nPos,2]+=WorkItens->WN_VLRPIS
      ENDIF

      IF (nPos:=ASCAN(aWorkMarca,{|A|A[1]=COD_COFINS })) = 0
         AADD(aWorkMarca,{COD_COFINS,WorkItens->WN_VLRCOF,cTipoNF,"",.T.,.T.})
      ELSE
         aWorkMarca[nPos,2]+=WorkItens->WN_VLRCOF
      ENDIF
   ENDIF

   IF (nPos:=ASCAN(aWorkMarca,{|A|A[1]=COD_IPI })) = 0
      AADD(aWorkMarca,{COD_IPI,WorkItens->WN_IPIVAL,cTipoNF,"",.T.,.T.})
   ELSE
      aWorkMarca[nPos,2]+=WorkItens->WN_IPIVAL
   ENDIF

   IF (nPos:=ASCAN(aWorkMarca,{|A|A[1]=COD_ICMS })) = 0
      AADD(aWorkMarca,{COD_ICMS,WorkItens->WN_VALICM,cTipoNF,"",.T.,.T.})
   ELSE
      aWorkMarca[nPos,2]+=WorkItens->WN_VALICM
   ENDIF
   WorkItens->(DBSKIP())

ENDDO
//======================================================= WorkItens - Soma os impostos dos itens

//======================================================= SW9 - Le as taxas e moedas
SW9->(DBSETORDER(3))
SW9->(DBSEEK(cFilSW9+SW6->W6_HAWB))
DO WHILE SW9->(!EOF()) .AND. cFilSW9 == SW9->W9_FILIAL .AND. SW6->W6_HAWB == SW9->W9_HAWB .AND. !lSoLeNFT

   IF nCont > nTotal
      ProcRegua(nTotal)
      nCont:=0
   ENDIF
   nCont++
   IncProc("Lendo Invoice: "+ALLTRIM(SW9->W9_INVOICE))

   IF !WorkTaxa->(DBSEEK( SW9->W9_MOE_FOB+"FATURAS" ))
      WorkTaxa->(DBAPPEND())
      WorkTaxa->WK_MARCA  :="LBOK"
      WorkTaxa->WN_INVOICE:="FATURAS"
      WorkTaxa->W9_MOE_FOB:=SW9->W9_MOE_FOB
      WorkTaxa->W9_TX_FOB :=SW9->W9_TX_FOB
      WorkTaxa->WKNOVATAXA:=SW9->W9_TX_FOB
      WorkTaxa->WKOLDTAXA :=SW9->W9_TX_FOB
      AADD(aTabTaxas, {SW9->W9_MOE_FOB,SW9->W9_TX_FOB} )//Usado no programa EICDI154.PRW na funcao DI154TaxaFOB() linha + - 8000
   ENDIF

   SW9->(DBSKIP())

ENDDO

IF !EMPTY(SW6->W6_FREMOED) .AND. !lSoLeNFT
   WorkTaxa->(DBAPPEND())
   WorkTaxa->WK_MARCA  :="LBOK"
   WorkTaxa->WN_INVOICE:="FRETE"
   WorkTaxa->W9_MOE_FOB:=SW6->W6_FREMOED
   WorkTaxa->W9_TX_FOB :=SW6->W6_TX_FRET
   WorkTaxa->WKNOVATAXA:=SW6->W6_TX_FRET
   WorkTaxa->WKOLDTAXA :=SW6->W6_TX_FRET
ENDIF

IF !EMPTY(SW6->W6_SEGMOED) .AND. !lSoLeNFT
   WorkTaxa->(DBAPPEND())
   WorkTaxa->WK_MARCA  :="LBOK"
   WorkTaxa->WN_INVOICE:="SEGURO"
   WorkTaxa->W9_MOE_FOB:=SW6->W6_SEGMOED
   WorkTaxa->W9_TX_FOB :=SW6->W6_TX_SEG
   WorkTaxa->WKNOVATAXA:=SW6->W6_TX_SEG
   WorkTaxa->WKOLDTAXA :=SW6->W6_TX_SEG
ENDIF
//======================================================= SW9 - Le as taxas e moedas

//======================================================= SWW Le despesas das notas
nTotItem:=(nTotItem*3)
SWW->(DBSETORDER(2))//WW_FILIAL+WW_HAWB+WW_TIPO_NF
SWW->(DBSEEK(cFILSWW+SW6->W6_HAWB))

DO WHILE SWW->(!EOF()) .AND.;
         SWW->WW_FILIAL == cFILSWW .AND.;
         SWW->WW_HAWB   == SW6->W6_HAWB .AND. !lSoLeNFT

   IF nCont > nTotItem
      ProcRegua(nTotItem)
      nCont:=0
   ENDIF
   nCont++
   IncProc("Lendo Despesa: "+ALLTRIM(SWW->WW_DESPESA))

   IF !(SWW->WW_TIPO_NF $ "1,2,3") .OR. LEFT(SWW->WW_DESPESA,1) = "7"
      SWW->(DBSKIP())
      LOOP
   ENDIF

   WorkDespesa->(DBAPPEND())

   AVREPLACE("SWW","WorkDespesa")

   IF SWW->WW_TIPO_NF = "1"
      WorkDespesa->WKORIGEM:=NFP
   ELSEIF SWW->WW_TIPO_NF = "2"
      WorkDespesa->WKORIGEM:=NFC
   ELSEIF SWW->WW_TIPO_NF = "3"
      WorkDespesa->WKORIGEM:=NFU
   ENDIF

   cDesp:=LEFT(SWW->WW_DESPESA,3)

   IF (nPos:=ASCAN(aWorkMarca,{|A| LEFT(A[1],3) = cDesp })) = 0
      AADD(aWorkMarca,{ SWW->WW_DESPESA , SWW->WW_VALOR, WorkDespesa->WKORIGEM })
   ELSE
      aWorkMarca[nPos,2]+=SWW->WW_VALOR
   ENDIF
   lTemDespesas:=.T.

   SWW->(DBSKIP())

ENDDO
SWW->(DBSETORDER(1))
//======================================================= SWW Le despesas das notas

//======================================================= Cria a work Marca

ProcRegua(LEN(aWorkMarca))

FOR M := 1 TO LEN(aWorkMarca)

   IncProc("Lendo Despesa: "+ALLTRIM(WorkMarca->WKDESCRICA))
   WorkMarca->(DBAPPEND())
   WorkMarca->WKDESCRICA:=aWorkMarca[M,1]
   WorkMarca->WKVALOR   :=aWorkMarca[M,2]
   WorkMarca->WKORIGEM  :=aWorkMarca[M,3]
   IF !lSoLeNFT
      IF lMarcadoSempreImp .AND. LEN(aWorkMarca[M]) > 4 .AND. aWorkMarca[M,5]
         PCOMarca(.F.,.T.,.F.) //Marca os impostos
      ENDIF
   ENDIF

NEXT
//======================================================= Cria a work Marca

//======================================================= Rateia despesas do SWD
FOR M := 1 TO LEN(aWorkMarca)

    //FDR - 10/01/2013 - Contador utilizado no RDMAKE
    MPE:= M

    IF aWorkMarca[M,3] # DESEMBARACO
       LOOP
    ENDIF

    ProcRegua(WorkItens->(LASTREC()))

    WorkItens->(DBGOTOP())
    nAcerta:=0
    nRecno:=0
    nMaiorValor:=0
    DO WHILE WorkItens->(!EOF())

       IncProc("Calculando Item: "+ALLTRIM(WorkItens->WN_PRODUTO))

       IF LEN(aWorkMarca[M]) > 3 .AND. aWorkMarca[M,4] $ cSim
          nRateio := WorkItens->WN_PESOL/nPesoTotal
       ELSE
          IF lRateioCIF
             nRateio := (WorkItens->WN_FOB_R+WorkItens->WN_FRETE+WorkItens->WN_SEGURO)/nCIFTotal
             If lRatDspCIF_II                                                                     //NCF - 27/12/2012 - Apuração de despesas não base rateadas por CIF+II
                nRateio := (WorkItens->WKIIBASE+WorkItens->WN_IIVAL)/(nBaseIITotal+nII_Total)
             EndIf
          ELSE
             nRateio := WorkItens->WN_FOB_R/nFOBTotal
          ENDIF
       ENDIF

       //FDR - 10/01/13 - Ponto de Entrada para alterar a forma de rateio
       If(EasyEntryPoint("EICCO100"),Execblock("EICCO100",.F.,.F.,"RATEIO"),)

       nValor := (aWorkMarca[M,2] * nRateio)

       WorkDespesa->(DBAPPEND())
       WorkDespesa->WKORIGEM   :=DESEMBARACO
       WorkDespesa->WW_NR_CONT :=WorkItens->WN_ITEM
       WorkDespesa->WW_INVOICE :=WorkItens->WN_INVOICE
       WorkDespesa->WW_LOTECTL :=WorkItens->WV_LOTE
       WorkDespesa->WW_DESPESA :=aWorkMarca[M,1]
       WorkDespesa->WW_PO_NUM  :=WorkItens->WN_PO_EIC
       WorkDespesa->WW_PGI_NUM :=WorkItens->WN_PGI_NUM
       WorkDespesa->WW_VALOR   :=nValor
       WorkDespesa->WW_BASEICM :=aWorkMarca[M,5] //LGS-26/01/2015
       WorkDespesa->WW_BASEIMP :=aWorkMarca[M,6] //LRS-13/07/2016
       nAcerta+=WorkDespesa->WW_VALOR
       IF WorkDespesa->WW_VALOR > nMaiorValor
          nMaiorValor:=WorkDespesa->WW_VALOR
          nRecno:=WorkDespesa->(Recno())
       ENDIF

       WorkItens->(DBSKIP())

    ENDDO

    IF nRecno # 0 .AND. nAcerta # aWorkMarca[M,2]
       WorkDespesa->(DBGOTO(nRecno))
       WorkDespesa->WW_VALOR += (aWorkMarca[M,2] - nAcerta)
    ENDIF

NEXT
//======================================================= Rateia despesas do SWD

RETURN .T.
*===========================================================================*
STATIC FUNCTION PCOMarca(lMarcaALL,lMarcaImpostos,lMensagem)
*===========================================================================*
PRIVATE lMarcando:=EMPTY(WorkMarca->WK_FLAG)
DEFAULT lMensagem := .T.

IF !lMarcaALL

   IF EMPTY(WorkMarca->WKVALOR)
      IF lMensagem
         MSGSTOP("Valor zerado, nao pode ser marcado.")
      ENDIF
      RETURN .F.
   ENDIF

   IF !lMarcaImpostos .AND. ALLTRIM(WorkMarca->WKDESCRICA) $ IMPOSTOS_NFE
      MSGSTOP("Valores dos impostos nao podem ser desmarcados.")
      RETURN .F.
   ENDIF

   Processa( {|| PCOCalcMarca(.T.) } )

   WorkItens->(DBGOTOP())
   IF oMark1 # NIL
      oMark1:oBrowse:Refresh()
      oMark2:oBrowse:Refresh()
   ENDIF

   RETURN .T.

ENDIF

ProcRegua(WorkMarca->(LASTREC()))

IF EMPTY(WorkMarca->WKVALOR) .OR. (lMarcadoSempreImp .AND. ALLTRIM(WorkMarca->WKDESCRICA) $ IMPOSTOS_NFE)
   lPrimeiraDesp:=.T.
ELSE
   lPrimeiraDesp:=.T.
ENDIF

WorkMarca->(DBGOTOP())

WorkDespesa->(DBSETORDER(1))    //"WW_PO_NUM+WW_NR_CONT+WW_PGI_NUM+WW_LOTECTL+WW_INVOICE+WW_DESPESA"

DO WHILE WorkMarca->(!EOF())

   IncProc("Calculando Desp: "+ALLTRIM(WorkMarca->WKDESCRICA))
   IF EMPTY(WorkMarca->WKVALOR)
      WorkMarca->(DBSKIP())
      LOOP
   ENDIF

   IF lMarcadoSempreImp .AND. ALLTRIM(WorkMarca->WKDESCRICA) $ IMPOSTOS_NFE
      WorkMarca->(DBSKIP())
      LOOP
   ENDIF

   IF lPrimeiraDesp
      lMarcando:=EMPTY(WorkMarca->WK_FLAG)
      lPrimeiraDesp:=.F.
   ENDIF

   IF lMarcando
      IF EMPTY(WorkMarca->WK_FLAG)
         PCOCalcMarca(.F.)
      ENDIF
   ELSE
      IF !EMPTY(WorkMarca->WK_FLAG)
         PCOCalcMarca(.F.)
      ENDIF
   ENDIF

   WorkMarca->(DBSKIP())

ENDDO

WorkMarca->(DBGOTOP())
WorkItens->(DBGOTOP())
IF oMark1 # NIL
   oMark1:oBrowse:Refresh()
   oMark2:oBrowse:Refresh()
ENDIF

RETURN .T.
*==============================================*
STATIC FUNCTION PCOMrcaItem(lMarcaALL)
*==============================================*
LOCAL lMarcado:=EMPTY(WorkItens->WK_FLAG)

IF !lMarcaALL

   IF EMPTY(WorkItens->WK_FLAG)
      WorkItens->WK_FLAG:=cMarca
   ELSE
      WorkItens->WK_FLAG:=""
   ENDIF

   IF oMark2 # NIL
      oMark2:oBrowse:Refresh()
   ENDIF

   RETURN .T.

ENDIF

ProcRegua(WorkItens->(LASTREC()))

WorkItens->(DBGOTOP())

DO WHILE WorkItens->(!EOF())

   IncProc("Marcando Item: "+ALLTRIM(WorkItens->WN_PRODUTO))

   IF lMarcado
      IF EMPTY(WorkItens->WK_FLAG)
         WorkItens->WK_FLAG:=cMarca
      ENDIF
   ELSE
      IF !EMPTY(WorkItens->WK_FLAG)
         WorkItens->WK_FLAG:=""
      ENDIF
   ENDIF

   WorkItens->(DBSKIP())

ENDDO

WorkItens->(DBGOTOP())
IF oMark2 # NIL
   oMark2:oBrowse:Refresh()
ENDIF
RETURN .T.


*==============================================*
STATIC FUNCTION PCOCalcMarca(lRegua)
*==============================================*
//Local cDesp := ""

IF lRegua
   ProcRegua(WorkItens->(LASTREC()))
ENDIF

IF lMarcando
   WorkMarca->WK_FLAG:=cMarca
ELSE
   WorkMarca->WK_FLAG:=""
ENDIF

WorkItens->(DBGOTOP())

DO WHILE WorkItens->(!EOF())

   IF lRegua
      IncProc("Calculando Item: "+ALLTRIM(WorkItens->WN_PRODUTO))
   ENDIF

   // GFP - 11/04/2012 - Apenas contabiliza despesas que compoem Base de Imposto.
   //cDesp := Left(WORKMARCA->WKDESCRICA,3)
   //If SYB->(DbSeek(xFilial() + cDesp))
   //   If SYB->YB_BASEIMP == "1"     // 1 - SIM  ###  2 - NÃO
         PCOCalcItem()
   //   EndIf
   //EndIf

   IF WorkItens->WKVALOR < 0
      WorkItens->WKVALOR:=0
   ENDIF

   PCOCalcImposto()

   WorkItens->(DBSKIP())

ENDDO

RETURN .T.
*==============================================*
STATIC FUNCTION PCOCalcImposto(nWNQTD)
*==============================================*
LOCAL nBase:=nICMS_A:=nBaseICMS:=nValIPI:=nValICM:=nBaseIPI:=0
LOCAL lRedICMIPI := .F.
LOCAL nBasRedICM := 0
LOCAL lSemIPIBase := EasyGParam("MV_EIC0026",,.F.)//FDR - 01/03/2013
Default nWNQTD := 0

PCOInitVar()

IF lCalcNFT

   If lNftFilha //LGS-22/10/2014 - Função responsavel por controlar o saldo dos itens das notas filhas.
      PCONFTFilha(,,nWNQTD)
   EndIf

   //INICIO DOS CALCULOS DE IMPOSTOS DE NOTA DE TRANSFERENCIA.
   //A NOTA DE TRANSFERÊNCIA É UMA NOTA FISCAL NACIONAL, DE SAIDA PARA O IMPORTADOR E ENTRADA PARA O ADQUIRENTE.
   //OS IMPOSTOS QUE INCIDEM NESSE NF SÃO O ICMS E O IPI, SENDO A BASE DO ICMS O VALOR DA MERCADORIA E DESPESAS MARCADAS PELO USUÁRIO (INCLUINDO IMPOSTOS DA NF DE IMPORTAÇÃO)
   //E A BASE DO IPI É IGUAL A BASE DO ICMS, COM EXCEÇÃO DOS CASOS EM QUE O MV_EIC0026 ESTÁ LIGADO OU NO CASO QUE HÁ REDUÇÃO/CARGA TRIBUTARIA EQUIVALENTE DE ICMS.

   //Base para inicio do calculo da base de ICMS
//   If EasyGParam("MV_EIC0058",,.F.)  // GFP - 21/05/2015
      nBase     := WorkItens->WN_FOB_R+WorkItens->WN_FRETE+WorkItens->WN_SEGURO+WorkItens->WKDESPBICM
//   Else
//      nBase     := WorkItens->WN_FOB_R+WorkItens->WN_FRETE+WorkItens->WN_SEGURO+WorkItens->WKVALOR
//   EndIf
   nICMS_A   := WorkItens->WKICMS_A/100
   nBaseICMS := nBase/(1-nICMS_A) //ICMS integra a própria Base
   nValICM   := nBaseICMS * nICMS_A

   //Base de calculo do IPI é a mesma do ICMS, porém quando o MV_EIC0026 está ligado, é necessário recalcular a base do IPI desconsiderando o IPI pago pelo importador.
   //If lSemIPIBase
//      nBaseIPI:=(nBase-WorkItens->WN_IPIVAL)/(1-nICMS_A)
   //Else
      //nBaseIPI:= nBaseICMS
   //EndIf
//MFR 05/07/2017  MTRADE-1200 WCC-524950
//   If EasyGParam("MV_EIC0058",,.F.) .And. lCposDspBs  // NCF - 23/07/2015
//   IF GetCfo58() .And. lCposDspBs
      If lSemIPIBase
         nBaseIPI     := WorkItens->WN_FOB_R + WorkItens->WN_FRETE + WorkItens->WN_SEGURO + /*nValICM*/ (nBase-WorkItens->WN_IPIVAL)/(1-nICMS_A) * nICMS_A + WorkItens->WKDESPBIPI - WorkItens->WN_IPIVAL   //AAF -TE-5086508561 / MTRADE-701 / 706 - Calculo do IPI conta e ordem com parametros MV_EIC0058 e MV_EIC0026 ligados.
      Else
         nBaseIPI     := WorkItens->WN_FOB_R + WorkItens->WN_FRETE + WorkItens->WN_SEGURO + nValICM + WorkItens->WKDESPBIPI
      EndIf
//   EndIf

   nValIPI   := nBaseIPI * (WorkItens->WKIPITX /100)

   //Recalculo do ICMS em caso de redução ou carga tributária equivalente
   SWZ->(DBSETORDER(2))
   IF !EMPTY(WorkItens->WKOPERACAO) .AND. SWZ->(DBSEEK(cFilSWZ+WorkItens->WKOPERACAO))//Ordem 2 do SWZ

      nAlqReducao := IF(SWZ->WZ_RED_ICM#0,(100-SWZ->WZ_RED_ICM)/100,1)
      nBaseICMS   := nBase
      IF !EMPTY(SWZ->WZ_RED_CTE) .AND. nAlqReducao == 1
         //Carga Tributária Equivalente
		 If EasyGParam("MV_EIC0029",,"N") == "R"                                                         //NCF - 22/05/2013 - O valor do ICMS a integrar a própria base de cálculo para cálculo por Carga Tributária
            nBaseNew:= ( nBaseICMS / ( (100 - SWZ->WZ_RED_CTE) /100 ) )                                  //                   Equivalente deve ser obtido conforme o parâmetro: N=Alíquota Normal; R=Alíquota Reduzida
            nBaseICMS := DITrans( nBaseNew * (SWZ->WZ_RED_CTE/WorkItens->WKICMS_A) ,2)
         Else
            nBaseNew:= ( nBaseICMS/(1-(WorkItens->WKICMS_A/100)) )                                             //NCF - 06/02/2013 - Correção do cálculo de Carga Tributária equivalente
            nBaseICMS := DITRANS( nBaseNew * ((SWZ->WZ_RED_CTE/100) / (WorkItens->WKICMS_A/100)),2)
         Endif
      ELSE
	     //Redução da base de calculo
         nBaseICMS := DITrans( ( (nBaseICMS*nAlqReducao) / ( (100 - WorkItens->WKICMS_A) /100 ) ) ,2)
      ENDIF

	  //ICMS reduzido (caso tenha redução ou carga tributaria equivalente)
	  nValICM   := (nBaseICMS * nICMS_A)

	  //Recalcula o IPI considerando a redução de ICMS caso MV_EIC0018 estiver ligado e tenha redução ou carga tributaria equivalente de ICMS.
	  lICMSRedIPI := If(Type("lICMSRedIPI")<>"L",.F.,lICMSRedIPI)
	  IF lICMSRedIPI .AND. SWZ->WZ_RED_CTE+SWZ->WZ_RED_ICM > 0
//        If lSemIPIBase
//           nBaseIPI:= (nBase-WorkItens->WN_IPIVAL)+nValICM
//        Else
//           nBaseIPI := nBase+nValICM
//        EndIf

        // NCF - 23/07/2015
        //MFR 05/07/2017  MTRADE-1200 WCC-524950
        //If EasyGParam("MV_EIC0058",,.F.) .And. lCposDspBs  // NCF - 23/07/2015
//        IF GetCfo58() .And. lCposDspBs
           If lSemIPIBase
              nBaseIPI     := WorkItens->WN_FOB_R + WorkItens->WN_FRETE + WorkItens->WN_SEGURO + nValICM + WorkItens->WKDESPBIPI - WorkItens->WN_IPIVAL
           Else
              nBaseIPI     := WorkItens->WN_FOB_R + WorkItens->WN_FRETE + WorkItens->WN_SEGURO + nValICM + WorkItens->WKDESPBIPI
           EndIf
        //EndIf

		 nValIPI   := nBaseIPI * (WorkItens->WKIPITX /100)
	  EndIf
   ENDIF

   WorkItens->WKBASEICMS:= nBaseICMS
   WorkItens->WKVL_ICM  := nValICM

   If EIW->(FieldPos("EIW_VALMER")) > 0 .And. WorkItens->WKIPITX == 0            //NCF - 24/03/2015 - Zera a base do IPI se a taxa estiver zerada (IPI->Supenso ou Isento)
      WorkItens->WKVALMERC := nBaseIPI
      WorkItens->WKIPIBASE := 0
   Else
      WorkItens->WKIPIBASE := nBaseIPI
   EndIf

   WorkItens->WKIPIVAL  := nValIPI

   If AvFlags("NFT_DESP_BASE_IMP") //THTS - 09/01/2018
      If EasyGParam("MV_EIC0058",,.F.)
            WORKITENS->EIW_VALTOT := WorkItens->WN_FOB_R + WorkItens->WKVL_ICM + WorkItens->EIW_DESPCU + FretSegNFT() - WorkItens->WKIPIVAL //Verifica se deve somar o frete e o Seguro
      Else
            WORKITENS->EIW_VALTOT := WorkItens->WN_FOB_R + WorkItens->WKVL_ICM + WorkItens->EIW_DESPCU + FretSegNFT() //Verifica se deve somar o frete e o Seguro
      EndIf
   EndIf

ENDIF

RETURN .T.

*==============================================*
STATIC FUNCTION PCOCalcItem()
*==============================================*
Local lImposto:= .F.
Local aImposto:= {}, nPos, cDespesa
Local nValor:= 0
Local lAtualiza := .F.

AADD(aImposto,{"1-II"    ,"201"    })
AADD(aImposto,{"2-IPI"   ,"202"    })
AADD(aImposto,{"3-PIS"   ,"203"    })
AADD(aImposto,{"4-COFINS","204"    })
AADD(aImposto,{"5-ICMS"  ,"205"    })

//RTRIM() pq o COD_ tem um espaco na frente
IF RTRIM(WorkMarca->WKDESCRICA) = COD_II
   IF lMarcando
      WorkItens->WKVALOR+=WorkItens->WN_IIVAL
   ELSE
      WorkItens->WKVALOR-=WorkItens->WN_IIVAL
   ENDIF
   //RETURN .T.
   lImposto:= .T.
   nValor:= WorkItens->WN_IIVAL
ENDIF
//RTRIM() pq o COD_ tem um espaco na frente
IF RTRIM(WorkMarca->WKDESCRICA) = COD_IPI
   IF lMarcando
      WorkItens->WKVALOR+=WorkItens->WN_IPIVAL
   ELSE
      WorkItens->WKVALOR-=WorkItens->WN_IPIVAL
   ENDIF
   //RETURN .T.
   lImposto:= .T.
   nValor:= WorkItens->WN_IPIVAL
ENDIF
//RTRIM() pq o COD_ tem um espaco na frente
IF RTRIM(WorkMarca->WKDESCRICA) = COD_PIS
   IF lMarcando
      WorkItens->WKVALOR+=WorkItens->WN_VLRPIS
   ELSE
      WorkItens->WKVALOR-=WorkItens->WN_VLRPIS
   ENDIF
   //RETURN .T.
   lImposto:= .T.
   nValor:= If(EasyGParam("MV_EIC0027",,.F.) , WorkItens->WKPISVAL, WorkItens->WN_VLRPIS)
ENDIF
//RTRIM() pq o COD_ tem um espaco na frente
IF RTRIM(WorkMarca->WKDESCRICA) = COD_COFINS
   IF lMarcando
      WorkItens->WKVALOR+=WorkItens->WN_VLRCOF
   ELSE
      WorkItens->WKVALOR-=WorkItens->WN_VLRCOF
   ENDIF
   //RETURN .T.
   lImposto:= .T.
   nValor:= If(EasyGParam("MV_EIC0027",,.F.) , WorkItens->WKCOFVAL, WorkItens->WN_VLRCOF)
ENDIF
//RTRIM() pq o COD_ tem um espaco na frente
IF RTRIM(WorkMarca->WKDESCRICA) = COD_ICMS
   IF lMarcando
      WorkItens->WKVALOR+=WorkItens->WN_VALICM
   ELSE
      WorkItens->WKVALOR-=WorkItens->WN_VALICM
   ENDIF
   //RETURN .T.
   lImposto:= .T.
   nValor:= WorkItens->WN_VALICM
ENDIF

If !lImposto                                //"WW_PO_NUM+WW_NR_CONT+WW_PGI_NUM+WW_LOTECTL+WW_INVOICE+WW_DESPESA"
   IF WorkDespesa->(DBSEEK(WorkItens->(WN_PO_EIC+WN_ITEM   +WN_PGI_NUM+WV_LOTE+WN_INVOICE+ALLTRIM(WorkMarca->WKDESCRICA))))
      IF lMarcando
         WorkItens->WKVALOR+=WorkDespesa->WW_VALOR
      ELSE
         WorkItens->WKVALOR-=WorkDespesa->WW_VALOR
      ENDIF
   ENDIF
ENDIF

nPos:= AScan(aImposto, {|x| Alltrim(x[1]) == Alltrim(WORKMARCA->WKDESCRICA)})
If nPos > 0
   cDespesa:= aImposto[nPos][2]
Else
   cDespesa:= AvKey(Left(WORKMARCA->WKDESCRICA,3),"YB_DESP")
EndIf

//MFR 05/07/2017  MTRADE-1200 WCC-524950
//If EasyGParam("MV_EIC0058",,.F.) .AND. SYB->(DbSeek(xFilial("SYB") + cDespesa))  // GFP - 21/05/2015
//If GetCfo58() .AND. SYB->(DbSeek(xFilial("SYB") + cDespesa))
//   If cDespesa=="202" //desp ipi
   If cDespesa=="202" //desp ipi
      If GetCfo58()=="SIM"
         IF lMarcando
            WorkItens->WKDESPBICM+=nValor
         ELSE
            WorkItens->WKDESPBICM-=nValor
         ENDIF
         lAtualiza = .F.
      ElseIf GetCfo58()=="NAO"
         lAtualiza = .F.
      ElseIf GetCfo58()=="NAO CONFIGURADO"
         lAtualiza = .T.
      EndIf
   Else
      lAtualiza = .T.
   EndIf

   If lAtualiza .AND. (!EasyGParam("MV_EIC0058",,.F.) .or. SYB->(DbSeek(xFilial("SYB") + cDespesa)) .and. SYB->YB_BASEICM $ cSim .AND. SYB->(FIELDPOS("YB_ICMS_"+SYT->YT_ESTADO)) # 0 .AND. SYB->(FIELDGET(FIELDPOS("YB_ICMS_"+SYT->YT_ESTADO))) $ cSim)
      If !lImposto
         IF lMarcando
            WorkItens->WKDESPBICM+=WorkDespesa->WW_VALOR
         ELSE
            WorkItens->WKDESPBICM-=WorkDespesa->WW_VALOR
         ENDIF
      Else
         IF lMarcando
            WorkItens->WKDESPBICM+=nValor
         ELSE
            WorkItens->WKDESPBICM-=nValor
         ENDIF
      EndIf
   EndIf

   If !EasyGParam("MV_EIC0058",,.F.)  .or. (lCposDspBs .and. SYB->(DbSeek(xFilial("SYB") + cDespesa)) .and. SYB->YB_BIPINFT $ cSim)
//   If (lCposDspBs .and. SYB->YB_BIPINFT $ cSim)
         If !lImposto
            IF lMarcando
               WorkItens->WKDESPBIPI+=WorkDespesa->WW_VALOR
            ELSE
               WorkItens->WKDESPBIPI-=WorkDespesa->WW_VALOR
            ENDIF
         Else
            IF lMarcando
               WorkItens->WKDESPBIPI+=nValor
            ELSE
               WorkItens->WKDESPBIPI-=nValor
            ENDIF
         EndIf
//      EndIf
   EndIf
//EndIF
   //LRS - 09/01/2018
   IF SYB->(DbSeek(xFilial("SYB") + cDespesa))
      IF AvFlags("NFT_DESP_BASE_IMP") .AND. SYB->YB_TOTNFT != "2"
         If !lImposto
            IF lMarcando
               WORKITENS->EIW_DESPCU += WorkDespesa->WW_VALOR
            Else
               WORKITENS->EIW_DESPCU -= WorkDespesa->WW_VALOR
            endif
         ElSe
            IF lMarcando
               WORKITENS->EIW_DESPCU += nValor
            Else
               WORKITENS->EIW_DESPCU -= nValor
            endif
         EndIF
         /* wfs jul/2019
            Inicializa os valores de despesas para os processos que tiveram a nota de transferência gerada antes da criação dos campos - http://tdn.totvs.com/pages/releaseview.action?pageId=331854475.
            Correção para reiniciar os valores, descartando valores negativos decorrentes da simulação da desmarcação do item.*/
         If WORKITENS->EIW_DESPCU < 0
            WORKITENS->EIW_DESPCU:= 0
         EndIf

      EndIF
   EndIF

Return .T.
*-----------------------------------*
STATIC FUNCTION PCOLeGrava(lLer,nOpc)
*-----------------------------------*
LOCAL cAliasIT:="EIW",G, J:=0, S:=1
LOCAL aGravaIT:={}
LOCAL cAliasDE:="EIY",M
LOCAL aGravaDE:={}
LOCAL nTotal  := 15,nCount:=0
LOCAL aGravImp:={}
LOCAL aOrdSWN := SaveOrd({"SWN"})
LOCAL lEstFilha := .F.
//LGS-20/09/2014
LOCAL lGravaEIW:= .T.
Default nOpc  := 1

PCOInitVar()

AADD(aGravImp,{COD_II    })//Impostos da NFE
AADD(aGravImp,{COD_IPI   })//Impostos da NFE
AADD(aGravImp,{COD_PIS   })//Impostos da NFE
AADD(aGravImp,{COD_COFINS})//Impostos da NFE
AADD(aGravImp,{COD_ICMS  })//Impostos da NFE

AADD(aGravaIT,{WorkItens->(FIELDPOS("WN_PO_EIC" )),EIW->(FIELDPOS("EIW_PO_NUM")) })//Dados da NFE
AADD(aGravaIT,{WorkItens->(FIELDPOS("WN_ITEM"   )),EIW->(FIELDPOS("EIW_POSICA")) })//Dados da NFE
AADD(aGravaIT,{WorkItens->(FIELDPOS("WN_PGI_NUM")),EIW->(FIELDPOS("EIW_PGI_NU")) })//Dados da NFE
AADD(aGravaIT,{WorkItens->(FIELDPOS("WN_INVOICE")),EIW->(FIELDPOS("EIW_INVOIC")) })//Dados da NFE
AADD(aGravaIT,{WorkItens->(FIELDPOS("WV_LOTE"   )),EIW->(FIELDPOS("EIW_LOTECT")) })//Dados da NFE
AADD(aGravaIT,{WorkItens->(FIELDPOS("WN_PRODUTO")),EIW->(FIELDPOS("EIW_COD_I" )) })//Dados da NFE
AADD(aGravaIT,{WorkItens->(FIELDPOS("WN_QUANT"  )),EIW->(FIELDPOS("EIW_QTDE"  )) })//Dados da NFE
AADD(aGravaIT,{WorkItens->(FIELDPOS("WN_FOB_R"  )),EIW->(FIELDPOS("EIW_FOB_R" )) })//Valores da NFT
AADD(aGravaIT,{WorkItens->(FIELDPOS("WN_FRETE"  )),EIW->(FIELDPOS("EIW_FRETE" )) })//Valores da NFT
AADD(aGravaIT,{WorkItens->(FIELDPOS("WN_SEGURO" )),EIW->(FIELDPOS("EIW_SEGURO")) })//Valores da NFT
AADD(aGravaIT,{WorkItens->(FIELDPOS("WKVALOR"   )),EIW->(FIELDPOS("EIW_VALOR" )) })//Valores da NFT
AADD(aGravaIT,{WorkItens->(FIELDPOS("WKOPERACAO")),EIW->(FIELDPOS("EIW_OPERAC")) })//Dados da NFT
AADD(aGravaIT,{WorkItens->(FIELDPOS("WKIPIBASE" )),EIW->(FIELDPOS("EIW_IPIBAS")) })//Impostos da NFT
AADD(aGravaIT,{WorkItens->(FIELDPOS("WKIPITX"   )),EIW->(FIELDPOS("EIW_IPITX" )) })//Impostos da NFT
AADD(aGravaIT,{WorkItens->(FIELDPOS("WKIPIVAL"  )),EIW->(FIELDPOS("EIW_IPIVAL")) })//Impostos da NFT
AADD(aGravaIT,{WorkItens->(FIELDPOS("WKBASEICMS")),EIW->(FIELDPOS("EIW_BASEIC")) })//Impostos da NFT
AADD(aGravaIT,{WorkItens->(FIELDPOS("WKICMS_A"  )),EIW->(FIELDPOS("EIW_ICMS_A")) })//Impostos da NFT
AADD(aGravaIT,{WorkItens->(FIELDPOS("WKVL_ICM"  )),EIW->(FIELDPOS("EIW_VL_ICM")) })//Impostos da NFT
AADD(aGravaIT,{WorkItens->(FIELDPOS("WN_IIVAL"  )),EIW->(FIELDPOS("EIW_IIVAL" )) })//Impostos da NFE
AADD(aGravaIT,{WorkItens->(FIELDPOS("WN_IPIVAL" )),EIW->(FIELDPOS("EIW_IPI_VL")) })//Impostos da NFE
AADD(aGravaIT,{WorkItens->(FIELDPOS("WN_VALICM" )),EIW->(FIELDPOS("EIW_VALICM")) })//Impostos da NFE
AADD(aGravaIT,{WorkItens->(FIELDPOS("WN_VLRPIS" )),EIW->(FIELDPOS("EIW_VLRPIS")) })//Impostos da NFE
AADD(aGravaIT,{WorkItens->(FIELDPOS("WN_VLRCOF" )),EIW->(FIELDPOS("EIW_VLRCOF")) })//Impostos da NFE
AADD(aGravaIT,{WorkItens->(FIELDPOS("WN_DOC"    )),EIW->(FIELDPOS("EIW_NOTA"  )) })
AADD(aGravaIT,{WorkItens->(FIELDPOS("WN_SERIE"  )),EIW->(FIELDPOS("EIW_SERIE" )) })
If EIW->(FieldPos("EIW_BASEPC")) # 0   // GFP - 11/07/2013
   AADD(aGravaIT,{WorkItens->(FIELDPOS("WKBASEPC"  )),EIW->(FIELDPOS("EIW_BASEPC" )) })
   // GFP - 13/12/2013 - Tratamento de Majoração PIS/COFINS
   If lCposCofMj
      AADD(aGravaIT,{WorkItens->(FIELDPOS("WN_ALCOFM"  )),EIW->(FIELDPOS("EIW_ALCOFM" )) })
      AADD(aGravaIT,{WorkItens->(FIELDPOS("WN_VLCOFM"  )),EIW->(FIELDPOS("EIW_VLCOFM" )) })
   EndIf
   If lCposPisMj
      AADD(aGravaIT,{WorkItens->(FIELDPOS("WN_ALPISM"  )),EIW->(FIELDPOS("EIW_ALPISM" )) })
      AADD(aGravaIT,{WorkItens->(FIELDPOS("WN_VLPISM"  )),EIW->(FIELDPOS("EIW_VLPISM" )) })
   EndIf
EndIf

If EIW->(FieldPos("EIW_VALMER")) > 0                                                   //NCF - 24/03/2015 - Recupera valor da mercadoria (Base do IPI)
   AADD(aGravaIT,{WorkItens->(FIELDPOS("WKVALMERC"  )),EIW->(FIELDPOS("EIW_VALMER")) })
EndIf

//MFR 05/07/2017  MTRADE-1200 WCC-524950 segundo orientação do Alessandro sempre exibir o campo mesmo que na for utilzar
//If EasyGParam("MV_EIC0058",,.F.) .And. lCposDspBs
   AADD(aGravaIT,{WorkItens->(FIELDPOS("WKDESPBICM"  )),EIW->(FIELDPOS("EIW_DBSICM")) })//Despesas base de ICMS da NFT
   If lCposDspBs
      AADD(aGravaIT,{WorkItens->(FIELDPOS("WKDESPBIPI"  )),EIW->(FIELDPOS("EIW_DBSIPI")) })//Despesas base de IPI  da NFT
   Endif
//EndIf

If EasyGParam("MV_EIC0027",,.F.) //LRS - 03/10/2016
   If EIW->(FieldPos("EIW_PERPIS")) # 0   // GFP - 03/12/2015
      AADD(aGravaIT,{WorkItens->(FIELDPOS("WKPERPIS"  )),EIW->(FIELDPOS("EIW_PERPIS")) })//% PIS
   EndIf
   If EIW->(FieldPos("EIW_PERCOF")) # 0   // GFP - 03/12/2015
      AADD(aGravaIT,{WorkItens->(FIELDPOS("WKPERCOF"  )),EIW->(FIELDPOS("EIW_PERCOF")) })//% COFINS
   EndIf
EndIf

 If AvFlags("NFT_DESP_BASE_IMP") //LRS - 10/01/2018
    AADD(aGravaIT,{WorkItens->(FIELDPOS("EIW_DESPCU"  )),EIW->(FIELDPOS("EIW_DESPCU")) })
    AADD(aGravaIT,{WorkItens->(FIELDPOS("EIW_VALTOT"  )),EIW->(FIELDPOS("EIW_VALTOT")) })
 EndIF

AADD(aGravaDE,{WorkDespesa->(FIELDPOS("WW_PO_NUM" )),EIY->(FIELDPOS("EIY_PO_NUM")) })//Dados da NFE
AADD(aGravaDE,{WorkDespesa->(FIELDPOS("WW_NR_CONT")),EIY->(FIELDPOS("EIY_POSICA")) })//Dados da NFE
AADD(aGravaDE,{WorkDespesa->(FIELDPOS("WW_PGI_NUM")),EIY->(FIELDPOS("EIY_PGI_NU")) })//Dados da NFE
AADD(aGravaDE,{WorkDespesa->(FIELDPOS("WW_INVOICE")),EIY->(FIELDPOS("EIY_INVOIC")) })//Dados da NFE
AADD(aGravaDE,{WorkDespesa->(FIELDPOS("WW_LOTECTL")),EIY->(FIELDPOS("EIY_LOTECT")) })//Dados da NFE
AADD(aGravaDE,{WorkDespesa->(FIELDPOS("WW_DESPESA")),EIY->(FIELDPOS("EIY_DESPES")) })//Dados da NFE
AADD(aGravaDE,{WorkDespesa->(FIELDPOS("WKORIGEM"  )),EIY->(FIELDPOS("EIY_ORIGEM")) })//Dados da NFE
AADD(aGravaDE,{WorkDespesa->(FIELDPOS("WW_VALOR"  )),EIY->(FIELDPOS("EIY_VALOR" )) })//Despesas da NFE

IF lLer//LEITURA =======================================================================================

   ProcRegua(nTotal)
   EIW->(DBSETORDER(1))
   EIW->(DBSEEK(cFilEIW+SW6->W6_HAWB))

   //Tratamento para estorno da NFT Filha
   IF lNftFilha
      IF LEN(aItemStn)>0
      	 SWN->(DBSETORDER(2))
      	 SWN->(DBSEEK(xFilial("SWN")+aItemStn[1][1]+aItemStn[1][2]+aItemStn[1][3]))
      	 aSWN := {}
      	 DO WHILE SWN->(!EOF()) .AND. SWN->WN_DOC == aItemStn[1][1] .AND. SWN->WN_SERIE == aItemStn[1][2]
      	 	AADD(aSWN,{SWN->WN_PRODUTO, SWN->WN_ITEM, SWN->WN_QUANT})
      	 	lEstFilha := .T.
      	 	SWN->(DBSKIP())
      	ENDDO
      ENDIF
   ENDIF

   DO WHILE EIW->(!EOF()) .AND. EIW->EIW_FILIAL = cFilEIW .AND. EIW->EIW_HAWB == SW6->W6_HAWB

      IF lNftFilha
      	 J++
      	 IF lEstFilha //Validação para estorno da NFT Filha
      	 	IF S <= LEN(aSWN)
      	 	   IF EIW->EIW_POSICA != aSWN[S][2] /*EIW->EIW_COD_I != aSWN[S][1] .AND. */
      	          EIW->(DBSKIP())
      	          LOOP
      	       ELSE
      	          S++
      	       ENDIF
      	    ELSE
      	       EIW->(DBSKIP())
      	       LOOP
      	    ENDIF
      	 ELSEIF LEN(aItemEIW)>0 .AND. !lEstFilha //Validação para não apresentar itens sem saldo
      	    IF EIW->EIW_COD_I == aItemEIW[J][1] .AND. aItemEIW[J][2] == 0
      	       EIW->(DBSKIP())
      	       LOOP
      	    ENDIF
      	 ENDIF
      ENDIF

      IF nCount > nTotal
         ProcRegua(nTotal)
         nCount:=0
      ENDIF
      nCount++
      IncProc("Lendo Item: "+ALLTRIM(EIW->EIW_COD_I))

      WorkItens->(DBAPPEND())
      FOR G := 1 TO LEN(aGravaIT)
	      IF aGravaIT[G,2] # 0  //POSICAO                     VALOR A SER GRAVADO
 	         WorkItens->(FIELDPUT(aGravaIT[G,1], EIW->(FIELDGET(aGravaIT[G,2]))) )
	      ENDIF
      NEXT
      If EasyGParam("MV_EIC0027",,.F.)  // GFP - 17/06/2015
         WorkItens->WKPISVAL := EIW->EIW_VLRPIS
         WorkItens->WKCOFVAL := EIW->EIW_VLRCOF
         If EIW->(FieldPos("EIW_PERPIS")) # 0   // GFP - 03/12/2015
	         WorkItens->WKPERPIS := EIW->EIW_PERPIS
	      EndIf
	      If EIW->(FieldPos("EIW_PERCOF")) # 0   // GFP - 03/12/2015
	         WorkItens->WKPERCOF := EIW->EIW_PERCOF
	      EndIf
      EndIf
      SB1->(DBSEEK(cFilSB1+EIW->EIW_COD_I))
      WorkItens->B1_DESC:=SB1->B1_DESC
      WorkItens->WKRECNO:=EIW->(RECNO())


      IF lNftFilha //LGS-22/10/2014
         WorkItens->WK_FLAG  := "LBOK"
         WorkItens->WK_CHAVE := cValToChar(WorkItens->("["+WN_PO_EIC+"]+["+WN_ITEM+"]+["+WN_PGI_NUM+"]+["+WV_LOTE+"]+["+WN_INVOICE+"]"))
         IF !lEstFilha .AND. LEN(aItemEIW) > 0 //Inclusão de NFT Filha
         	  FOR G:=1 TO LEN(aItemEIW)
         	  		IF WorkItens->WN_PRODUTO == aItemEIW[G][1] .AND. WorkItens->WV_LOTE == aItemEIW[G][3]
         	  			WorkItens->WN_QUANT  := aItemEIW[G][2]
         	 		ENDIF
         	  NEXT
         ENDIF
         IF lEstFilha //Estorno NFT Filha
			  FOR G:=1 TO LEN(aSWN)
        	  		IF WorkItens->WN_PRODUTO == aSWN[G][1] .AND. WorkItens->WN_ITEM == aSWN[G][2]
            			WorkItens->WN_QUANT  := aSWN[G][3]
            			WorkItens->WN_DOC    := aItemStn[1][1]
            			WorkItens->WN_SERIE  := aItemStn[1][2]
            		ENDIF
            NEXT
         ENDIF
         PCONFTFilha()
      ENDIF
      
      If lIntNFTEAI
         aInfoSF1 := GetStItNFT()
         WorkItens->WK_OK     := aInfoSF1[1]       
         WorkItens->WKSTATUS  := aInfoSF1[2]
         WorkItens->WKMENNOTA := aInfoSF1[3]
         WorkItens->WKNOTAPR  := EIW->EIW_DOCORI
         WorkItens->WKSERIEPR := EIW->EIW_SERORI       

         If aInfoSF1[4] <> 0 .And. aScan( aEnv_NFS , aInfoSF1[4] ) == 0
            AADD( aEnv_NFS , aInfoSF1[4] )
         EndIf
         If Empty(WorkItens->WKSTATUS) .Or. WorkItens->WKSTATUS == "0"
            lNFTPendEAI := .T.
         EndIf
      EndIf

      If AvFlags("NFT_DESP_BASE_IMP") //THTS - 09/01/2018
            /*If EasyGParam("MV_EIC0058",,.F.)
                  WORKITENS->EIW_VALTOT := WorkItens->WN_FOB_R + WorkItens->WKVL_ICM + WorkItens->EIW_DESPCU + FretSegNFT() - WorkItens->WKIPIVAL //Verifica se deve somar o frete e o Seguro
            Else
                  WORKITENS->EIW_VALTOT := WorkItens->WN_FOB_R + WorkItens->WKVL_ICM + WorkItens->EIW_DESPCU + FretSegNFT() //Verifica se deve somar o frete e o Seguro
            EndIf*/
            WORKITENS->EIW_VALTOT := EIW->EIW_VALTOT
      EndIf

      EIW->(DBSKIP())
   ENDDO

   aWorkMarca:={}
   ProcRegua(nTotal)
   EIY->(DBSETORDER(1))
   EIY->(DBSEEK(cFilEIY+SW6->W6_HAWB))
   DO WHILE EIY->(!EOF()) .AND. EIY->EIY_FILIAL = cFilEIY .AND. EIY->EIY_HAWB == SW6->W6_HAWB

      IF nCount > nTotal
         ProcRegua(nTotal)
         nCount:=0
      ENDIF
      nCount++
      IncProc("Lendo Despesa: "+ALLTRIM(EIY->EIY_DESPES))

      IF !ALLTRIM(EIY->EIY_DESPES) $ IMPOSTOS_NFE
         WorkDespesa->(DBAPPEND())
         FOR G := 1 TO LEN(aGravaDE)
                          //POSICAO                     VALOR A SER GRAVADO
             WorkDespesa->(FIELDPUT(aGravaDE[G,1], EIY->(FIELDGET(aGravaDE[G,2]))) )
         NEXT
      ENDIF

      cDesp:=LEFT(EIY->EIY_DESPES,3)

      IF (nPos:=ASCAN(aWorkMarca,{|A| LEFT(A[1],3) = cDesp })) = 0
         AADD(aWorkMarca,{ EIY->EIY_DESPES, EIY->EIY_VALOR, EIY->EIY_ORIGEM, EIY->EIY_MARCA, EIY->(RECNO()) })
      ELSE
         aWorkMarca[nPos,2]+=EIY->EIY_VALOR
      ENDIF

      IF !ALLTRIM(EIY->EIY_DESPES) $ IMPOSTOS_NFE
         WorkDespesa->WKRECNO:=EIY->(RECNO())
         lTemDespesas:=.T.
      ENDIF

      EIY->(DBSKIP())

   ENDDO

   ProcRegua(LEN(aWorkMarca))

   FOR M := 1 TO LEN(aWorkMarca)

      WorkMarca->(DBAPPEND())
      WorkMarca->WKDESCRICA:=aWorkMarca[M,1]
      WorkMarca->WKVALOR   :=aWorkMarca[M,2]
      WorkMarca->WKORIGEM  :=aWorkMarca[M,3]
      IF !EMPTY(aWorkMarca[M,4])
         WorkMarca->WK_FLAG := cMarca
      ENDIF
      WorkMarca->WKRECNO   :=aWorkMarca[M,5]
      IncProc("Lendo Despesa: "+ALLTRIM(WorkMarca->WKDESCRICA))

   NEXT

   ProcRegua(nTotal)
   EIZ->(DBSETORDER(1))
   EIZ->(DBSEEK(cFilEIZ+SW6->W6_HAWB))
   DO WHILE EIZ->(!EOF()) .AND. EIZ->EIZ_FILIAL = cFilEIZ .AND. EIZ->EIZ_HAWB == SW6->W6_HAWB

      IF nCount > nTotal
         ProcRegua(nTotal)
         nCount:=0
      ENDIF
      nCount++
      IncProc("Lendo Taxas: "+ALLTRIM(EIY->EIY_DESPES))

      WorkTaxa->(DBAPPEND())
      WorkTaxa->WK_MARCA  :="LBOK"
      WorkTaxa->WN_INVOICE:=EIZ->EIZ_DOCUME
      WorkTaxa->W9_MOE_FOB:=EIZ->EIZ_MOEDA
      WorkTaxa->W9_TX_FOB :=EIZ->EIZ_TX_DI
      WorkTaxa->WKNOVATAXA:=EIZ->EIZ_TX_NEW
      WorkTaxa->WKOLDTAXA :=EIZ->EIZ_TX_NEW
      WorkTaxa->WKRECNO   :=EIZ->(RECNO())

      IF (nPos:=ASCAN(aTabTaxas,{ |M|  M[1] == WorkTaxa->W9_MOE_FOB } )) = 0
         AADD(aTabTaxas, {WorkTaxa->W9_MOE_FOB,WorkTaxa->W9_TX_FOB} )//aTabTaxas: Usado no programa EICDI154.PRW na funcao DI154TaxaFOB() linha + - 8000
      ENDIF

      EIZ->(DBSKIP())

   ENDDO

//LEITURA =======================================================================================
ELSE
//Gravacao ======================================================================================

 Begin Transaction

   /// ======  EIW - Itens
   ProcRegua(WorkItens->(LASTREC()))
   WorkItens->(DBGOTOP())
   DO WHILE WorkItens->(!EOF())
	  //LGS-24/09/2014 - Verifica se é processo de NFT Filha e mantem as quantidades originais do processo para controle de saldo.
	If lNftFilha .And. nOpc != 1  .And. !EMPTY(WorkItens->WKRECNO) //NCF - 22/08/2019
         lGravaEIW := .F.
      EndIf

      IncProc("Lendo Item: "+ALLTRIM(WorkItens->WN_PRODUTO))

      IF EMPTY(WorkItens->WKRECNO)
         EIW->(RECLOCK("EIW",.T.))
         EIW->EIW_FILIAL:=cFilEIW
         EIW->EIW_HAWB  :=SW6->W6_HAWB
      ELSE
         EIW->(DBGOTO(WorkItens->WKRECNO))
         EIW->(RECLOCK("EIW",.F.))
      ENDIF

	  If lGravaEIW //LGS-22/10/2014 - Mantem as quantidades originais do processo para controle de saldo NFT Filha.
	     IF lNftFilha .AND. EIW->(FIELDPOS("EIW_POSORI")) > 0
	        J++
	        EIW->EIW_POSORI    := WorkItens->WN_ITEM
	        WorkItens->WN_ITEM := PADL(J,AVSX3("EIW_POSICA",3),"0")
	     ENDIF
	     FOR G := 1 TO LEN(aGravaIT)
	         IF aGravaIT[G,2] # 0
	            EIW->(FIELDPUT(aGravaIT[G,2],WorkItens->(FIELDGET(aGravaIT[G,1]))))
	         ENDIF
	     NEXT
      EndIf
      WorkItens->WKRECNO:=EIW->(RECNO())
	  SerieNfId("EIW",1,"EIW_SERIE",,,,EIW->EIW_SERIE)

      EIW->(MSUNLOCK())

      WorkItens->(DBSKIP())

   ENDDO
   /// ======  EIW - Itens

   /// ======  EIY - Impostos
   ProcRegua(LEN(aGravImp))
   FOR M := 1 TO LEN(aGravImp)

       IncProc("Lendo Imposto: "+aGravImp[M,1])
       WorkMarca->(DBSEEK(aGravImp[M,1]))

       IF EMPTY(WorkMarca->WKVALOR)//Verifica se o imposto nao esta zerado
          LOOP
       ENDIF

       IF EMPTY(WorkMarca->WKRECNO)
          EIY->(RECLOCK("EIY",.T.))
          EIY->EIY_FILIAL:=cFilEIY
          EIY->EIY_HAWB  :=SW6->W6_HAWB
       ELSE
          EIY->(DBGOTO(WorkMarca->WKRECNO))
          EIY->(RECLOCK("EIY",.F.))
       ENDIF

       EIY->EIY_DESPES:=aGravImp[M,1]
       EIY->EIY_ORIGEM:=cTipoNF
       EIY->EIY_VALOR :=WorkMarca->WKVALOR

       IF EMPTY(WorkMarca->WK_FLAG)
          EIY->EIY_MARCA:=""
       ELSE
          EIY->EIY_MARCA:="XX"
       ENDIF
       WorkMarca->WKRECNO:=EIY->(RECNO())
       EIY->(MSUNLOCK())

   NEXT
   /// ======  EIY - Impostos

   /// ======  EIY - Despesas
   ProcRegua(WorkDespesa->(LASTREC()))
   WorkDespesa->(DBGOTOP())
   DO WHILE WorkDespesa->(!EOF())

      IncProc("Lendo Despesa: "+ALLTRIM(WorkDespesa->WW_DESPESA))

      IF EMPTY(WorkDespesa->WKRECNO)
         EIY->(RECLOCK("EIY",.T.))
         EIY->EIY_FILIAL:=cFilEIY
         EIY->EIY_HAWB  :=SW6->W6_HAWB
      ELSE
         EIY->(DBGOTO(WorkDespesa->WKRECNO))
         EIY->(RECLOCK("EIY",.F.))
      ENDIF

      FOR G := 1 TO LEN(aGravaDE)
          EIY->(FIELDPUT(aGravaDE[G,2],WorkDespesa->(FIELDGET(aGravaDE[G,1]))))
      NEXT
      WorkMarca->(DBSEEK(LEFT(WorkDespesa->WW_DESPESA,3)))
      IF EMPTY(WorkMarca->WK_FLAG)
         EIY->EIY_MARCA:=""
      ELSE
         EIY->EIY_MARCA:="XX"
      ENDIF
      WorkDespesa->WKRECNO:=EIY->(RECNO())
      EIY->(MSUNLOCK())

      WorkDespesa->(DBSKIP())

   ENDDO
   /// ======  EIY - Despesas

   /// ======  EIZ - TAXAS
   ProcRegua(WorkTaxa->(LASTREC()))
   WorkTaxa->(DBGOTOP())
   DO WHILE WorkTaxa->(!EOF())

      IF EMPTY(WorkTaxa->WKRECNO)
         EIZ->(RECLOCK("EIZ",.T.))
         EIZ->EIZ_FILIAL:=cFilEIZ
         EIZ->EIZ_HAWB  :=SW6->W6_HAWB
      ELSE
         EIZ->(DBGOTO(WorkTaxa->WKRECNO))
         EIZ->(RECLOCK("EIZ",.F.))
      ENDIF

      EIZ->EIZ_DOCUME:=WorkTaxa->WN_INVOICE
      EIZ->EIZ_MOEDA :=WorkTaxa->W9_MOE_FOB
      EIZ->EIZ_TX_DI :=WorkTaxa->W9_TX_FOB
      EIZ->EIZ_TX_NEW:=WorkTaxa->WKNOVATAXA
      WorkTaxa->WKRECNO:=EIZ->(RECNO())
      EIZ->(MSUNLOCK())

      WorkTaxa->(DBSKIP())

   ENDDO
   WorkTaxa->(DBGOTOP())
   /// ======  EIZ - TAXAS

 End Transaction

ENDIF//Gravacao =======================================================================================

RestOrd(aOrdSWN)
Return .T.

*-----------------------------------*
STATIC FUNCTION PCOEstorno()
*-----------------------------------*
ProcRegua(WorkItens->(LASTREC()))

PCOInitVar()

Begin Transaction

EIW->(DBSETORDER(1))
EIW->(DBSEEK(cFilEIW+SW6->W6_HAWB))
DO WHILE EIW->(!EOF()) .AND. EIW->EIW_FILIAL = cFilEIW .AND. EIW->EIW_HAWB == SW6->W6_HAWB

   IncProc("Lendo Item: "+ALLTRIM(EIW->EIW_COD_I))

   EIW->(RECLOCK("EIW",.F.))
   EIW->(DBDELETE())
   EIW->(MSUNLOCK())

   EIW->(DBSKIP())

ENDDO

ProcRegua(WorkDespesa->(LASTREC()))

EIY->(DBSETORDER(1))
EIY->(DBSEEK(cFilEIY+SW6->W6_HAWB))
DO WHILE EIY->(!EOF()) .AND. EIY->EIY_FILIAL = cFilEIY .AND. EIY->EIY_HAWB == SW6->W6_HAWB

   IncProc("Lendo Despesa: "+ALLTRIM(EIY->EIY_DESPES))

   EIY->(RECLOCK("EIY",.F.))
   EIY->(DBDELETE())
   EIY->(MSUNLOCK())

   EIY->(DBSKIP())

ENDDO

ProcRegua(WorkTaxa->(LASTREC()))

EIZ->(DBSETORDER(1))
EIZ->(DBSEEK(cFilEIZ+SW6->W6_HAWB))
DO WHILE EIZ->(!EOF()) .AND. EIZ->EIZ_FILIAL = cFilEIZ .AND. EIZ->EIZ_HAWB == SW6->W6_HAWB

   IncProc("Lendo Despesa: "+ALLTRIM(EIZ->EIZ_DOCUME))

   EIZ->(RECLOCK("EIZ",.F.))
   EIZ->(DBDELETE())
   EIZ->(MSUNLOCK())

   EIZ->(DBSKIP())

ENDDO

End Transaction

RETURN .T.

*=============================================*
STATIC FUNCTION EICNFCalc(lAppend)//Calcula FOB, FRETE e SEGURO
*=============================================*
ProcRegua(3)

IncProc("Iniciando parametros...")
//Variavais usadas na funcao DI154NFE()
Private lAUTPCDI := DI500AUTPCDI()
Private lSegInc  := SW9->(FIELDPOS("W9_SEGINC")) # 0 .AND. SW9->(FIELDPOS("W9_SEGURO")) # 0 .AND. ;
                    SW8->(FIELDPOS("W8_SEGURO")) # 0 .AND. SW6->(FIELDPOS("W6_SEGINV")) # 0 // tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
PRIVATE Work1File,Work1FileA,Work1FileB,Work1FileC,Work1FileD,Work1FileE,Work1FileF,Work2File,Work2FileA, Work3File,Work3FileA,Work4File,cFileWk,cFileWkA,Work5File
Private _PictPrUn   := ALLTRIM(X3Picture("W3_PRECO"))
PRIVATE aDespesa    := {}
Private lIntDraw    := EasyGParam("MV_EIC_EDC",,.F.)
Private cAntImp     := EasyGParam("MV_ANT_IMP",,"1")
PRIVATE nTotFreTira := 0
Private cCodTxSisc  := EasyGParam("MV_CODTXSI",,"XXX")
Private lRatCIF     := EasyGParam("MV_TXSIRAT",,.F.)
PRIVATE lNaoDelWork := .T.
PRIVATE aLocExecAuto:= {.T.,.F.,{},.T.,.F.}//Veja explicacao dessa array no final desse rdmake
//Variavais usadas na funcao DI154NFE()

PCOInitVar()

IncProc("Calculando NF...")

nTipoNF:=2//1
IF cTipoNF = NFP
   nTipoNF:=2//1
ELSEIF cTipoNF = NFU
   nTipoNF:=4//3
ENDIF

IF !DI154NFE("SW6" ,SW6->(RECNO()),nTipoNF,     ,     ,aLocExecAuto)//Chama calculando os impostos
   IF EasyGParam("MV_TEM_DI",,.F.)
      E_RESET_554()
   Else
      E_RESET_154()
   Endif
   RETURN .T.//.F.//O Retorno tem que ser sempre .T. pq os dados ja esta gravados
ENDIF

//BAK - Verificando se a Work1 está sendo utilizada
If Select("WORK1") == 0
   Return .F.
EndIf

/*//OAP - 29/03/2011 - Adequação para os processo de CO que tenham DI eltrônica
IF EasyGParam("MV_TEM_DI",,.F.)
   IF !DI554NFE("SW6" ,SW6->(RECNO()),nTipoNF)//Chama calculando os impostos
      E_RESET_DI554()
      RETURN .T.//.F.//O Retorno tem que ser sempre .T. pq os dados ja esta gravados
   ENDIF
ELSE
//  DI154NFE(cAlias,nRegNF        ,nOpc   ,xVal1,xVal2,aLocExecAuto)
   IF !DI154NFE("SW6" ,SW6->(RECNO()),nTipoNF,     ,     ,aLocExecAuto)//Chama calculando os impostos
      E_RESET_DI154()
      RETURN .T.//.F.//O Retorno tem que ser sempre .T. pq os dados ja esta gravados
   ENDIF
ENDIF*/


//DBSELECTAREA("Work1")
//COPY TO Work1

ProcRegua(Work1->(LASTREC()))

WorkItens->(DBSETORDER(1))//"WN_PO_EIC+WN_ITEM+WN_PGI_NUM+WN_INVOICE+WV_LOTE"
Work1->(DBGOTOP())
DO WHILE Work1->(!EOF())

   IncProc("Lendo Item: "+Work1->WKPO_NUM+Work1->WKPOSICAO)

   IF lAppend//Calcula

      WorkItens->(DBAPPEND())

      SB1->(DBSEEK(cFilSB1+Work1->WKCOD_I))
      WorkItens->WN_PRODUTO:=Work1->WKCOD_I
      WorkItens->B1_DESC   :=SB1->B1_DESC
      WorkItens->WN_QUANT  :=Work1->WKQTDE
      WorkItens->WN_IIVAL  :=Work1->WKIIVAL
      WorkItens->WN_IPIVAL :=Work1->WKIPIVAL
      WorkItens->WN_VLRPIS :=Work1->WKVLRPIS
      WorkItens->WN_VLRCOF :=Work1->WKVLRCOF
      WorkItens->WN_VALICM :=Work1->WKVL_ICM
      WorkItens->WN_PO_EIC :=Work1->WKPO_NUM
      WorkItens->WN_ITEM   :=Work1->WKPOSICAO
      WorkItens->WN_PGI_NUM:=Work1->WKPGI_NUM
      WorkItens->WN_INVOICE:=Work1->WKINVOICE
      WorkItens->WV_LOTE   :=Work1->WK_LOTE
      WorkItens->WN_PESOL  :=Work1->WKPESOL
      WorkItens->WKOPERACAO:=Work1->WK_OPERACA
      WorkItens->WKIPITX   :=Work1->WKIPITX
      WorkItens->WKICMS_A  :=Work1->WKICMS_A
      WorkItens->WN_FOB_R  :=Work1->WKFOB_R
      WorkItens->WN_FRETE  :=Work1->WKFRETE
      WorkItens->WN_SEGURO :=Work1->WKSEGURO
      WorkItens->WKIIBASE  :=Work1->WKCIF
      If EasyGParam("MV_EIC0027",,.F.)  // GFP - 27/03/2013
         WorkItens->WKPISVAL  :=Work1->WKVLRPIS
         WorkItens->WKCOFVAL  :=Work1->WKVLRCOF
         If EIW->(FieldPos("EIW_BASEPC")) # 0   // GFP - 11/07/2013
            WorkItens->WKBASEPC := Work1->WKBASPIS
         EndIf
         If EIW->(FieldPos("EIW_PERPIS")) # 0   // GFP - 03/12/2015
	         WorkItens->WKPERPIS := Work1->WKPERPIS
	      EndIf
	      If EIW->(FieldPos("EIW_PERCOF")) # 0   // GFP - 03/12/2015
	         WorkItens->WKPERCOF := Work1->WKPERCOF
	      EndIf
      EndIf

      If lCposCofMj  // GFP - 13/12/2013 - Tratamento de Majoração COFINS
         WorkItens->WN_VLCOFM := Work1->WKVLCOFM
         WorkItens->WN_ALCOFM := Work1->WKALCOFM
      EndIf
      If lCposPisMj  // GFP - 13/12/2013 - Tratamento de Majoração PIS
         WorkItens->WN_VLPISM := Work1->WKVLPISM
         WorkItens->WN_ALPISM := Work1->WKALPISM
      EndIf
	  If lNftFilha
	     WorkItens->WK_FLAG   := "LBOK"
	  EndIf

   ELSE//ReCalcula

      IF WorkItens->(DBSEEK(Work1->WKPO_NUM+Work1->WKPOSICAO+Work1->WKPGI_NUM+Work1->WK_LOTE+RTRIM(Work1->WKINVOICE)))
         WorkItens->WN_FOB_R :=Work1->WKFOB_R
         WorkItens->WN_FRETE :=Work1->WKFRETE
         WorkItens->WN_SEGURO:=Work1->WKSEGURO
         PCOCalcImposto()
      ELSE
        MSGINFO("Chave nao encontrada: "+Work1->("["+WKPO_NUM+"]+["+WKPOSICAO+"]+["+WKPGI_NUM+"]+["+WKINVOICE+"]+["+WK_LOTE+"]"),STR(LEN(Work1->WKPO_NUM+Work1->WKPOSICAO+Work1->WKPGI_NUM+Work1->WKINVOICE+Work1->WK_LOTE),2)+"==>"+STR(LEN(WorkItens->(WN_PO_EIC+WN_ITEM+WN_PGI_NUM+WN_INVOICE+WV_LOTE)),2))
      ENDIF

   ENDIF

   Work1->(DBSKIP())

ENDDO

//OAP - 29/03/2011 - Adequação para os processo de CO que tenham DI eltrônica
IF EasyGParam("MV_TEM_DI",,.F.)
   E_RESET_554()
ELSE
   E_RESET_154()//Funcao do EICDI154.PRW
ENDIF

RETURN .T.

*=============================================*
STATIC FUNCTION EICGerNFT(lGerar)
*=============================================*
Local cNrNota, cSerieNota  // By JPP - 27/07/2009 - 12:44
Local nVlrTotNF := 0 // SVG - 19/01/2011 -
ProcRegua(3)

IncProc("Iniciando paramentros...")
//Variavais usadas na funcao DI154NFE()
Private lAUTPCDI := DI500AUTPCDI()
Private lSegInc  := SW9->(FIELDPOS("W9_SEGINC")) # 0 .AND. SW9->(FIELDPOS("W9_SEGURO")) # 0 .AND. ;
                    SW8->(FIELDPOS("W8_SEGURO")) # 0 .AND. SW6->(FIELDPOS("W6_SEGINV")) # 0 // tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
PRIVATE Work1File,Work1FileA,Work1FileB,Work1FileC,Work1FileD,Work1FileE,Work1FileF,Work2File,Work2FileA, Work3File,Work3FileA,Work4File,cFileWk,cFileWkA,Work5File
Private PICT_CPO03  := ALLTRIM(X3PICTURE("B1_POSIPI"))
Private _PictPrUn   := ALLTRIM(X3Picture("W3_PRECO"))
Private _PictQtde   := ALLTRIM(X3Picture("W3_QTDE"))
Private PICT_CPO07  := _PictQtde
PRIVATE aDespesa    := {}
Private lIntDraw    := EasyGParam("MV_EIC_EDC",,.F.)
Private cAntImp     := EasyGParam("MV_ANT_IMP",,"1")
PRIVATE nTotFreTira := 0
Private cCodTxSisc  := EasyGParam("MV_CODTXSI",,"XXX")
Private lRatCIF     := EasyGParam("MV_TXSIRAT",,.F.)
PRIVATE lNaoDelWork := .T.
Private lAltNfeNum  := .T.
PRIVATE cTitBut     := "Gera NFT"
PRIVATE aLocExecAuto:= {.T.,.F.,{},.F.,.T.}//Veja explicacao dessa array no final desse rdmake//.F.
//Variavais usadas na funcao DI154NFE()

PCOInitVar()

IncProc("Processando NFT...")

IF !DI154NFE("SW6" ,SW6->(RECNO()),10  ,     ,     ,aLocExecAuto)//10-1 ==> Nota de Transferencia
   IF EasyGParam("MV_TEM_DI",,.F.)
      E_RESET_554()
   Else
      E_RESET_154()
   Endif
   RETURN .F.//O Retorno tem que ser sempre .T. pq os dados ja esta gravados
ENDIF

/*//OAP - 29/03/2011 - Adequação para os processo de CO que tenham DI eltrônica
IF EasyGParam("MV_TEM_DI",,.F.)
   IF !DI554NFE("SW6" ,SW6->(RECNO()),10)
      E_RESET_DI554()
      RETURN .F.//O Retorno tem que ser sempre .T. pq os dados ja esta gravados
   ENDIF
ELSE
   // Essa chamada executa a funcao EICGrvWork1() abaixo no EICDI154.PRW na funcao DI154GrWorks() linha + - 2463
   //  DI154NFE(cAlias,nRegNF        ,nOpc,xVal1,xVal2,aLocExecAuto)
   IF !DI154NFE("SW6" ,SW6->(RECNO()),10  ,     ,     ,aLocExecAuto)//10-1 ==> Nota de Transferencia
      E_RESET_DI154()
      RETURN .F.//O Retorno tem que ser sempre .T. pq os dados ja esta gravados
   ENDIF
ENDIF */

EIW->(DBSETORDER(1))//EIW_FILIAL+EIW_HAWB+EIW_PO_NUM+EIW_POSICA+EIW_PGI_NU+EIW_INVOIC+EIW_LOTECT

IF lGerar

   IF EIW->(DBSEEK(cFilEIW+SW6->W6_HAWB))

      ProcRegua(WorkItens->(LASTREC()))
      cNrNota    := ""
      cSerieNota := ""
      DO WHILE EIW->(!EOF()) .AND. EIW->EIW_FILIAL == cFilEIW .AND. EIW->EIW_HAWB == SW6->W6_HAWB

         IncProc("Lendo Item: "+EIW->EIW_COD_I)
         EIW->(RECLOCK("EIW",.F.))
         EIW->EIW_NFTGER:="1"
         EIW->(MSUNLOCK())

         IF !lNftFilha .And. Empty(cNrNota) .And. !Empty(EIW->EIW_NOTA)   // By JPP - 27/07/2009 - 12:44 - Pega o numero da nota que será gravado nas despesas para
            If lIntNFTEAI
               cNrNota    := SF1->F1_DOC                    
               cSerieNota := SF1->F1_SERIE            
            Else
               cNrNota    := EIW->EIW_NOTA                                   // Geração da nota fiscal de transferência de posse.
               cSerieNota := EIW->EIW_SERIE
            EndIf
         ELSEIF lNftFilha .And. Empty(cNrNota) .And. Empty(EIW->EIW_NOTA)
            cNrNota    := SF1->F1_DOC                    // Geração da nota fiscal de transferência de posse.
            cSerieNota := SF1->F1_SERIE
         ENDIF

         // SVG - 19/01/2011 -  Total da nf
         nVlrTotNF  += EIW->EIW_FOB_R+EIW->EIW_FRETE+EIW->EIW_SEGURO+EIW->EIW_VALOR+EIW->EIW_VL_ICM+EIW->EIW_IPIVAL
         EIW->(DBSKIP())

      ENDDO
      // By JPP - 27/07/2009 - 12:44 - Grava o numero da nota nas despesas utilizadas na geração da nota fiscal de transferência de posse
      // para que seja possível a Geração da nota fiscal de transferência de posse.
      lGravouSW6 := .F.
      SWD->(DbSetOrder(1))
      EIY->(DbSetOrder(1)) //EIY_FILIAL+EIY_HAWB+EIY_DESPES
      EIY->(DbSeek(xFilial("EIY")+SW6->W6_HAWB))
      Do While !EIY->(Eof()) .And. EIY->(EIY_FILIAL+EIY_HAWB) == xFilial("EIY")+SW6->W6_HAWB
         If !(Alltrim(EIY->EIY_DESPES) $ IMPOSTOS_NFE) .And. !Empty(EIY->EIY_MARCA)   // "1-II , 2-IPI , 3-PIS , 4-COFINS , 5-ICMS"
            lGravaouNFT := .F.
            SWD->(DbSeek(xFilial("SWD")+SW6->W6_HAWB))
            Do While !SWD->(Eof()) .And. SWD->(WD_FILIAL+WD_HAWB) == xFilial("SWD")+SW6->W6_HAWB
               If Left(EIY->EIY_DESPES,3) == SWD->WD_DESPESA
                  SWD->(Reclock("SWD",.F.))
                  SWD->WD_NF_COMP := cNrNota
                  SWD->WD_SE_NFC  := cSerieNota
                  SWD->WD_DT_NFC  := dDataBase
                  lGravaouNFT := .T.
                  SWD->(MsUnLock())
               EndIf
               SWD->(DbSkip())
            EndDo
         EndIf
         EIY->(DbSkip())
      EndDo

      If !Empty(cNrNota) .AND. !Empty(cSerieNota) .AND. !lGravouSW6  // GFP - 14/10/2015
         SW6->(Reclock("SW6",.F.))
         SW6->W6_NF_ENT := cNrNota
         SW6->W6_SE_NF  := cSerieNota
         SW6->W6_DT_NF  := dDataBase
         SW6->W6_VL_NF  := nVlrTotNF   // SVG - 19/01/2011 - Total da nf
         lGravouSW6 := .T.
         SW6->(MsUnLock())
      EndIf
   ENDIF

ELSE

   IF EIW->(DBSEEK(cFilEIW+SW6->W6_HAWB))

      lAtuEIW := .T.
      IF lNftFilha //LGS-22/10/2014
         IF LEN(aItemStn)>0
         	  IF aItemStn[1][7] > 1 //Tem o total de notas geradas para o processo.
               lAtuEIW := .F.
         	  ENDIF
         ENDIF
      ENDIF

      ProcRegua(WorkItens->(LASTREC()))

      DO WHILE EIW->(!EOF()) .AND. EIW->EIW_FILIAL == cFilEIW .AND. EIW->EIW_HAWB == SW6->W6_HAWB .AND. lAtuEIW

         IncProc("Lendo Item: "+EIW->EIW_COD_I)
         EIW->(RECLOCK("EIW",.F.))
         EIW->EIW_NFTGER:="2"
         EIW->(MSUNLOCK())
         EIW->(DBSKIP())

      ENDDO

      EIW->(DBSEEK(cFilEIW+SW6->W6_HAWB))
      DO WHILE EIW->(!EOF()) .AND. EIW->EIW_FILIAL == cFilEIW .AND. EIW->EIW_HAWB == SW6->W6_HAWB
         EIW->(RECLOCK("EIW",.F.))
         EIW->EIW_NOTA  := ""
         //EIW->EIW_SERIE := ""
		  SerieNfId("EIW",1,"EIW_SERIE",CTod("  /  /  "),"","","")
         EIW->(MSUNLOCK())
         EIW->(DBSKIP())
      ENDDO
      // By JPP - 27/07/2009 - 12:44 - Limpa o numero da nota nas despesas utilizadas na geração da nota fiscal de transferência de posse
      // no caso de Estorno da nota de transferência de Posse.
      lGravouSW6 := .F.
      SWD->(DbSetOrder(1))
      EIY->(DbSetOrder(1)) //EIY_FILIAL+EIY_HAWB+EIY_DESPES
      EIY->(DbSeek(xFilial("EIY")+SW6->W6_HAWB))
      Do While !EIY->(Eof()) .And. EIY->(EIY_FILIAL+EIY_HAWB) == xFilial("EIY")+SW6->W6_HAWB
         If !(Alltrim(EIY->EIY_DESPES) $ IMPOSTOS_NFE) .And. !Empty(EIY->EIY_MARCA)   // "1-II , 2-IPI , 3-PIS , 4-COFINS , 5-ICMS"
            lGravaouNFT := .F.
            SWD->(DbSeek(xFilial("SWD")+SW6->W6_HAWB))
            Do While !SWD->(Eof()) .And. SWD->(WD_FILIAL+WD_HAWB) == xFilial("SWD")+SW6->W6_HAWB
               If Left(EIY->EIY_DESPES,3) == SWD->WD_DESPESA
                  SWD->(Reclock("SWD",.F.))
                  SWD->WD_NF_COMP := ""
                  SWD->WD_SE_NFC  := ""
                  SWD->WD_DT_NFC  := Ctod("  /  /  ")
                  lGravaouNFT := .T.
                  SWD->(MsUnLock())
               EndIf
               SWD->(DbSkip())
            EndDo
         EndIf
         EIY->(DbSkip())
      EndDo

      If !lGravouSW6  // GFP - 14/10/2015
         SW6->(Reclock("SW6",.F.))
         SW6->W6_NF_ENT := ""
         SW6->W6_SE_NF  := ""
         SW6->W6_DT_NF  := Ctod("  /  /  ")
         SW6->W6_VL_NF  := 0
         lGravouSW6 := .T.
         SW6->(MsUnLock())
      EndIf
   ENDIF

ENDIF

//OAP - 29/03/2011 - Adequação para os processo de CO que tenham DI eltrônica
IF EasyGParam("MV_TEM_DI",,.F.)
   E_RESET_554()
ELSE
   E_RESET_154()
ENDIF

If lNftFilha //LGS - Deleta as works utilizadas no processo.
   PCONFTFilha(.T.) //Ajusta preço unitario do item
   PCOCloseWrk()    //Fecha todas os Works utilizadas
EndIf

RETURN .T.

*=============================================*
FUNCTION EICGrvWork1()//Chamado do programa EICDI154.PRW na funcao DI154GrWorks() linha + - 2463 - AVSTACTION("206")
*=============================================*
LOCAL nTotal   :=15, nCount:=0
LOCAL cFornece := cLoja:=""
LOCAL nQtdAlt  := 0
LOCAL lRecalc  := .F.
LOCAL cNroNf, cSerie
lNFAutomatica  := .F.//Usado no programa EICDI154.PRW

PCOInitVar()

SWN->(DBSETORDER(3))//WN_FILIAL+WN_HAWB+WN_TIPO_NF
SF1->(DBSETORDER(5))

IF lNftFilha //LGS-22/10/2014
	IF nTela == 3 .AND. SWN->(DBSEEK(cFilSWN+SW6->W6_HAWB+"9")) .AND. SF1->(DBSEEK(cFilSF1+SW6->W6_HAWB+"9"))
	   lSoGravaNF  :=.F. //Usado no programa EICDI154.PRW
	   lSoEstornaNF:=.T. //Usado no programa EICDI154.PRW
	   RETURN .T.
	ENDIF
ELSE
	IF SWN->(DBSEEK(cFilSWN+SW6->W6_HAWB+"9")) .AND. SF1->(DBSEEK(cFilSF1+SW6->W6_HAWB+"9"))
	   lSoGravaNF  :=.F. //Usado no programa EICDI154.PRW
	   lSoEstornaNF:=.T. //Usado no programa EICDI154.PRW
	   RETURN .T.
	ENDIF
ENDIF

ProcRegua(nTotal)

SW2->(DBSETORDER(1))
SW7->(DBSetOrder(4))//W7_FILIAL+W7_HAWB+W7_PO_NUM+W7_POSICAO+W7_PGI_NUM
SW8->(DBSetOrder(6))//W8_FILIAL+W8_HAWB+W8_INVOICE+W8_PO_NUM+W8_POSICAO+W8_PGI_NUM
SWZ->(DBSETORDER(2))
SA2->(DBSETORDER(1))
SB1->(DBSETORDER(1))
EIJ->(DBSETORDER(1))

IF !lImportador
   nOldOrder := SYT->(INDEXORD())
   SYT->(DBSETORDER(1))
   IF SYT->(DBSEEK(xFilial("SYT")+AVKEY(SW6->W6_IMPORT,"W2_IMPORT") ))
      cFornece:= SYT->YT_FORN
      cLoja   := SYT->YT_LOJA
      SA2->(DBSEEK(cFilSA2+cFornece+cLoja))
   ENDIF
   SYT->(DBSETORDER(nOldOrder))
ENDIF

IF lNftFilha //Work recalculada...
   WorkItens->(DbSetOrder(1))
   WorkItens->(DbGotop())
ENDIF

EIW->(DBSETORDER(1))
EIW->(DBSEEK(cFilEIW+SW6->W6_HAWB))

DO WHILE EIW->(!EOF()) .AND. EIW->EIW_FILIAL = cFilEIW .AND. EIW->EIW_HAWB == SW6->W6_HAWB

   IF lNftFilha //LGS-22/10/2014 - Posiciona no item da Work para verificar a quantidade que esta sendo utilizada na NFT Filha.
   	  IF WorkItens->(DbSeek(EIW->EIW_PO_NUM+EIW->EIW_POSICA+EIW->EIW_PGI_NU+EIW->EIW_LOTECT+EIW->EIW_INVOIC))
        IF WorkItens->WK_FLAG == "LBNO"
      	    EIW->(DBSKIP())
      	    LOOP
        ENDIF
   	  	 nQtdAlt := WorkItens->WN_QUANT
   	  	 IF nQtdAlt <> EIW->EIW_QTDE
   	  	    lRecalc := .T.
   	  	 ENDIF
   	  ELSE
   	  	 EIW->(DBSKIP())
   	  	 LOOP
   	  ENDIF
   ENDIF

   IF nCount > nTotal
      ProcRegua(nTotal)
      nCount:=0
   ENDIF
   nCount++
   IncProc("Lendo Item: "+ALLTRIM(EIW->EIW_COD_I))

   SW2->(DBSeek(cFilSW2+EIW->EIW_PO_NUM))

   IF lNftFilha .AND. EIW->(FIELDPOS("EIW_POSORI")) > 0
      SW8->(DBSeek(cFilSW8+SW6->W6_HAWB+EIW->EIW_INVOIC+EIW->EIW_PO_NUM+EIW->EIW_POSORI+EIW->EIW_PGI_NU))
   ELSE
      SW8->(DBSeek(cFilSW8+SW6->W6_HAWB+EIW->EIW_INVOIC+EIW->EIW_PO_NUM+EIW->EIW_POSICA+EIW->EIW_PGI_NU))
   ENDIF

   SW7->(DbSeek(cFilSW7+SW8->W8_HAWB+SW8->W8_PO_NUM+SW8->W8_POSICAO+SW8->W8_PGI_NUM))
   SB1->(DBSEEK(cFilSB1+EIW->EIW_COD_I))

   IF EMPTY(cFornece)
      SA2->(DBSEEK(cFilSA2+SW7->W7_FORN))
   ENDIF

   IF lNftFilha
   	  SWZ->(DBSEEK(cFilSWZ+WorkItens->WKOPERACAO))
   ELSE
   	  SWZ->(DBSEEK(cFilSWZ+EIW->EIW_OPERAC))
   ENDIF

   IF lNftFilha
   	  cNroNf := WorkItens->WN_DOC
   	  cSerie := WorkItens->WN_SERIE
   ELSE
   	  cNroNf := EIW->EIW_NOTA
   	  cSerie := EIW->EIW_SERIE //LGS-23/12/2014
   ENDIF

   Work1->(DBAPPEND())
   Work1->WK_NFE     := cNroNf //EIW->EIW_NOTA
   Work1->WK_SE_NFE  := cSerie //EIW->EIW_NOTA
   Work1->WK_DT_NFE  := dDataBase
   Work1->WKTEC      := SW8->W8_TEC
   Work1->WKEX_NCM   := SW8->W8_EX_NCM
   Work1->WKEX_NBM   := SW8->W8_EX_NBM
   Work1->WKQTDE     := IF (lRecalc, nQtdAlt, EIW->EIW_QTDE)
   Work1->WKPRECO    := IF (lRecalc, ((SW8->W8_PRECO /EIW->EIW_QTDE) * nQtdAlt), SW8->W8_PRECO)
   Work1->WKPO_NUM   := EIW->EIW_PO_NUM
   Work1->WKPO_SIGA  := DI154_PO_SIGA()//SW2->W2_PO_SIGA
   Work1->WKCOD_I    := EIW->EIW_COD_I
   Work1->WK_CFO     := SWZ->WZ_CFO
   Work1->WK_OPERACA := IF (lNftFilha, WorkItens->WKOPERACAO, EIW->EIW_OPERAC)
   Work1->WKDESCR    := SB1->B1_DESC
   Work1->WKUNI      := BUSCA_UM(SW7->W7_COD_I+SW7->W7_FABR +SW7->W7_FORN,SW7->W7_CC+SW7->W7_SI_NUM)
   Work1->WKFOB_R    := IF (lRecalc, WorkItens->WN_FOB_R , EIW->EIW_FOB_R)
   Work1->WKFRETE    := IF (lRecalc, WorkItens->WN_FRETE , EIW->EIW_FRETE)
   Work1->WKSEGURO   := IF (lRecalc, WorkItens->WN_SEGURO, EIW->EIW_SEGURO)
   Work1->WKCIF      := IF (lRecalc, (Work1->WKFOB_R+Work1->WKFRETE+Work1->WKSEGURO), (EIW->EIW_FOB_R+EIW->EIW_FRETE+EIW->EIW_SEGURO))

//Nopado por FDR - 30/09/13 - Sempre enviar a base do IPI no valor da mercadoria
//   IF lICMSRedIPI
//      IF SWZ->(DBSEEK(cFilSWZ+EIW->EIW_OPERAC)) .And. SWZ->WZ_RED_CTE > 0
           If AvFlags("NFT_DESP_BASE_IMP")
                  Work1->WKVALMERC  := IF (lRecalc, WorkItens->EIW_VALTOT , EIW->EIW_VALTOT)
           Else
                  If EIW->(FieldPos("EIW_VALMER")) > 0        //NCF - 24/03/2015 - Zera a base do IPI se a taxa estiver zerada (IPI->Supenso ou Isento)
                        If lRecalc
                        Work1->WKVALMERC  := If( WorkItens->WKIPITX == 0 , WorkItens->WKVALMERC , WorkItens->WKIPIBASE )
                        Else
                        Work1->WKVALMERC  := If( EIW->EIW_IPITX == 0 , EIW->EIW_VALMER , EIW->EIW_IPIBAS )
                        EndIf
                  Else
                        Work1->WKVALMERC  := IF (lRecalc, WorkItens->WKIPIBASE , EIW->EIW_IPIBAS)
                  EndIf
            EndIf
//      ELSE
//         Work1->WKVALMERC  := EIW->EIW_BASEIC
//      ENDIF
//   ELSE
//      Work1->WKVALMERC  := EIW->EIW_BASEIC
//   ENDIF

   Work1->WKOUT_DESP := IF (lRecalc, WorkItens->WKVALOR   , EIW->EIW_VALOR)
   Work1->WKPRUNI    := Work1->WKVALMERC/Work1->WKQTDE
   Work1->WKIPIBASE  := IF (lRecalc, WorkItens->WKIPIBASE , EIW->EIW_IPIBAS)
   Work1->WKIPITX    := IF (lRecalc, WorkItens->WKIPITX   , EIW->EIW_IPITX)
   Work1->WKIPIVAL   := IF (lRecalc, WorkItens->WKIPIVAL  , EIW->EIW_IPIVAL)
   Work1->WKBASEICMS := IF (lRecalc, WorkItens->WKBASEICMS, EIW->EIW_BASEIC)
   Work1->WKICMS_A   := IF (lRecalc, WorkItens->WKICMS_A  , EIW->EIW_ICMS_A)
   Work1->WKVL_ICM   := IF (lRecalc, WorkItens->WKVL_ICM  , EIW->EIW_VL_ICM)
   Work1->WKPESOL    := SW7->W7_PESO * Work1->WKQTDE
   Work1->WK_CC      := SW7->W7_CC
   Work1->WKSI_NUM   := SW7->W7_SI_NUM
   Work1->WKNROLI    := SWP->WP_REGIST
   Work1->WKNOME     := SA2->A2_NOME
   Work1->WKFABR     := SW8->W8_FABR
   Work1->WKPOSICAO  := EIW->EIW_POSICA

   IF Work1->(FIELDPOS("WKPOSORI"))>0
      Work1->WKPOSORI:= EIW->EIW_POSORI
   ENDIF

   Work1->WKPGI_NUM  := EIW->EIW_PGI_NU
   Work1->WKINVOICE  := EIW->EIW_INVOIC
   Work1->TRB_ALI_WT := "EIW"
   Work1->TRB_REC_WT := EIW->(Recno())
   Work1->WKOUTDESP  := IF (lRecalc, ((SW8->W8_OUTDESP /EIW->EIW_QTDE) * nQtdAlt), SW8->W8_OUTDESP)
   Work1->WKINLAND   := IF (lRecalc, ((SW8->W8_INLAND  /EIW->EIW_QTDE) * nQtdAlt), SW8->W8_INLAND)
   Work1->WKPACKING  := IF (lRecalc, ((SW8->W8_PACKING /EIW->EIW_QTDE) * nQtdAlt), SW8->W8_PACKING)
   Work1->WKDESCONT  := IF (lRecalc, ((SW8->W8_DESCONT /EIW->EIW_QTDE) * nQtdAlt), SW8->W8_DESCONT)
// Work1->WKRATEIO   := Work1->WKFOB_R / DITRANS((SW6->W6_FOB_TOT+MDespesas),2)
   IF EMPTY(cFornece)
      Work1->WKFORN  := SW7->W7_FORN
      Work1->WKLOJA  := SA2->A2_LOJA
   ELSE
      Work1->WKFORN  := cFornece
      Work1->WKLOJA  := cLoja
   ENDIF

   If !Empty(SW8->W8_AC)
      Work1->WKADICAO  := SW8->W8_ADICAO
   ELSEIF !lExisteSEQ_ADI .And. !EMPTY(SW8->W8_ADICAO) .And. EIJ->(Dbseek(cFilEIJ+SW8->W8_HAWB+SW8->W8_ADICAO))
      WORK1->WKGRUPORT := SW8->W8_ADICAO
   ELSEIF !EMPTY(SW8->W8_ADICAO)
      Work1->WKADICAO  := SW8->W8_ADICAO
   EndIF
   IF lExisteSEQ_ADI
      WORK1->WKGRUPORT := SW8->W8_GRUPORT
   EndIF
   IF lLote
      Work1->WK_LOTE   := EIW->EIW_LOTECT
//    Work1->WKDTVALID:= SWN->WN_DTVALID
   ENDIF
   IF lExisteSEQ_ADI
      Work1->WKSEQ_ADI := SW8->W8_SEQ_ADI
   ENDIF

   IF ASCAN(aLista,{|F|F=Work1->WKFORN})=0
      AADD(aLista,Work1->WKFORN+"-"+SA2->A2_NREDUZ)
   ENDIF

   If EasyGParam("MV_EIC0027",,.F.)  // GFP - 27/03/2013
      Work1->WKVLRPIS := IF (lRecalc, ((EIW->EIW_VLRPIS /EIW->EIW_QTDE) * nQtdAlt), EIW->EIW_VLRPIS)
      Work1->WKVLRCOF := IF (lRecalc, ((EIW->EIW_VLRCOF /EIW->EIW_QTDE) * nQtdAlt), EIW->EIW_VLRCOF)
      If EIW->(FieldPos("EIW_BASEPC")) # 0   // GFP - 11/07/2013
         Work1->WKBASPIS := IF (lRecalc, ((EIW->EIW_BASEPC /EIW->EIW_QTDE) * nQtdAlt), EIW->EIW_BASEPC)
         Work1->WKBASCOF := IF (lRecalc, ((EIW->EIW_BASEPC /EIW->EIW_QTDE) * nQtdAlt), EIW->EIW_BASEPC)
         If EIW->(FieldPos("EIW_PERPIS")) # 0   // GFP - 03/12/2015
	         Work1->WKPERPIS := EIW->EIW_PERPIS
	      EndIf
	      If EIW->(FieldPos("EIW_PERCOF")) # 0   // GFP - 03/12/2015
	         Work1->WKPERCOF := EIW->EIW_PERCOF
	      EndIf
         // GFP - 13/12/2013 - Tratamento de Majoração PIS/COFINS
         If lCposCofMj
            Work1->WKVLCOFM := IF (lRecalc, ((EIW->EIW_VLCOFM /EIW->EIW_QTDE) * nQtdAlt), EIW->EIW_VLCOFM)
            Work1->WKALCOFM := EIW->EIW_ALCOFM
         EndIf
         If lCposPisMj
            Work1->WKVLPISM := IF (lRecalc, ((EIW->EIW_VLPISM /EIW->EIW_QTDE) * nQtdAlt), EIW->EIW_VLPISM)
            Work1->WKALPISM := EIW->EIW_ALPISM
         EndIf

      EndIf
   EndIf

   nFOB_R   +=Work1->WKFOB_R
   nFreteNew+=Work1->WKFRETE
   nSEGURO  +=Work1->WKSEGURO
   nCIFNew  +=Work1->WKCIF
   MDI_OUTR +=Work1->WKOUT_DESP
   nNBM_II  +=Work1->WKIIVAL
   nNBM_IPI +=Work1->WKIPIVAL
   nNBM_ICMS+=Work1->WKVL_ICM

   EIW->(DBSKIP())

ENDDO

IF lApuraCIF .OR. lComIcms .OR. lRateioCIF
   MDI_FOB_R  := nFOB_R
   MDI_FRETE  := nFreteNew
   MDI_SEGURO := nSEGURO
   MDI_CIF    := nCIFNew
   MDI_CIFPURO:= nFOB_R+nFreteNew+nSEGURO
ENDIF

SWZ->(DBSETORDER(1))
SW7->(DBSetOrder(1))
SW8->(DBSetOrder(1))

RETURN .T.
*========================================================================================*
STATIC FUNCTION E_RESET_154()//Antigo E_RESET_AREA - Funcao copiada do EICDI154.PRW
*========================================================================================*
IF SELECT("Work1") # 0
   //Work1->(dbCloseArea())
   Work1->(E_EraseArq(Work1File,Work1FileA,Work1FileB))
/* FErase(Work1FileC+TEOrdBagExt())
   FErase(Work1FileD+TEOrdBagExt())
   FErase(Work1FileE+TEOrdBagExt())
*/ //THTS - 03/10/2017 - TE-7085 - Temporario no Banco de Dados
   FErase(Work1FileC+TEOrdBagExt())
   FErase(Work1FileD+TEOrdBagExt())
   FErase(Work1FileE+TEOrdBagExt())
ENDIF
IF SELECT("Work2") # 0
   //Work2->(dbCloseArea())
   Work2->(E_EraseArq(Work2File, Work2FileA))
ENDIF
IF(SELECT("Work4")   #0,Work4->(E_EraseArq(Work4File)),)
IF(SELECT("Work_EIU")#0,Work_EIU->(E_EraseArq(Work5File)),)
IF(SELECT("Work3")   #0,Work3->(E_EraseArq(Work3File,Work3FileA)),)
IF(SELECT("Work_Tot")#0,Work_Tot->(E_EraseArq(cFileWk,cFileWkA)) ,)

RETURN .T.


*========================================================================================*
STATIC FUNCTION E_RESET_554() //- Funcao copiada do EICDI554.PRW
*========================================================================================*
DBSELECTAREA("SW6")
IF(EasyEntryPoint("EICDI554"),Execblock("EICDI554",.F.,.F.,'DELETAWORK'),)

SW6->(MSUnlock())

IF SELECT("Work1")    #0
   //Work1->(dbCloseArea())
   Work1->(E_EraseArq(Work1File,Work1FileA,Work1FileB))
/* FErase(Work1FileC+TEOrdBagExt())
   FErase(Work1FileD+TEOrdBagExt())
*/ //THTS - 03/10/2017 - TE-7085 - Temporario no Banco de Dados
   FErase(Work1FileC+TEOrdBagExt())
   FErase(Work1FileD+TEOrdBagExt())
ENDIF

IF SELECT("Work2")    #0
   //Work2->(dbCloseArea())
   Work2->(E_EraseArq(Work2File))
EndIf

IF(SELECT("Work3")    #0,Work3->(E_EraseArq(Work3File,Work3FileA)),)
IF(SELECT("Work4")    #0,Work4->(E_EraseArq(Work4File)),)
IF(SELECT("Work_Tot") #0,Work_Tot->(E_EraseArq(cFileWk,cFileWkA)),)

RETURN .T.


*========================================================================================*
//AUTOR: LUCIANO CAMPOS DE SANTANA
//DATA.: 24/11/2008 - 18:36
*========================================================================================*
STATIC Function PCO_VAL_PV()
*========================================================================================*
LOCAL oDLG,bOK,bCANCEL,nBTOP,XX
LOCAL lGerou:=.F.
Local oPanel
bOK      := {|| nBTOP := 1,IF(PCOVALPAR("bOK"),oDLG:END(),nBTOP := 0)}
bCANCEL  := {|| nBTOP := 0,oDLG:END()}
nBTOP    := 0
XX       := " "
cCONDPAMS:= SPACE(LEN(SE4->E4_CODIGO))
cCLIENTE := SPACE(LEN(SW2->W2_CLIENTE))
cCLLOJA  := SPACE(LEN(SA1->A1_LOJA))
cTIPCLI  := SPACE(LEN(SA1->A1_TIPCLI))
aTipos   := ComboX3BOX("C5_TIPO","")
IF aTipos[1] = "&"
   aTipos[1]:=SUBSTR(aTipos[1],2)
ENDIF
cTipoPV  := aTipos[1]

DEFINE MSDIALOG oDLG TITLE "Geracao de Pedido de Venda" FROM 0,0 TO 220,410 OF oMainWnd PIXEL

    oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165) //MCF - 23/07/2015
    oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

    @ 20,005 SAY "Tipo do Pedido de Venda" PIXEL OF oPanel
    @ 20,100 ComboBox oGet Var cTipoPV Items aTipos Size 80,90 Pixel Of oPanel

    @ 40,005 SAY "Condicao de Pagamento (SIGAFAT)" PIXEL OF oPanel
    @ 40,100 MSGET cCONDPAMS PICTURE AVSX3("E4_CODIGO",AV_PICTURE) SIZE 30,08 F3("SE4") ;
              VALID(PCOVALPAR("cCONDPAMS")) PIXEL OF oPanel

//  @ 00,00 MSGET XX  // SO PARA RESOLVER PROBLEMA DA TELA

ACTIVATE MSDIALOG oDLG ON INIT ENCHOICEBAR(oDLG,bOK,bCANCEL) CENTERED

IF nBTOP == 1

   RETURN .T.

ENDIF

RETURN .F.
*========================================================================================*
STATIC Function PCO_PV()
*========================================================================================*
LOCAL lGerou:=.F.
LOCAL lEstorno:=.F.

IF !EMPTY(SW6->W6_PEDFAT)

   SC5->(DBSETORDER(1))
   IF !SC5->(DBSEEK(xFilial("SC5")+AVKEY(SW6->W6_PEDFAT,"C5_NUM")))

      MSGINFO("Pedido de Venda nao encontrado: "+ALLTRIM(SW6->W6_PEDFAT)+", o campo será limpo.","Atencao")

      SW6->(RECLOCK("SW6",.F.))
      SW6->W6_PEDFAT := ""
      SW6->(MSUNLOCK())
      RETURN .F.

   ENDIF

   Processa( {|| lEstorno:=PCODelPV() } ,, "Estorno PV...")

   RETURN lEstorno

ELSE

   Processa( {|| lGerou:=PCOGrvPV() } ,, "Gerando PV...")

   RETURN lGerou

ENDIF

RETURN .F.
*========================================================================================*
STATIC FUNCTION PCODelPV()
*========================================================================================*
ProcRegua(3)
IncProc("Lendo PV...")
// CAPA
aCAB  := {{"C5_NUM",SW6->W6_PEDFAT,NIL}}
// ITENS
aITENS:= {}
AADD(aITENS,{ {"C6_NUM",SW6->W6_PEDFAT,NIL} } )

IncProc("Estornando PV...")

lMSERROAUTO := .F.

MSEXECAUTO({|x,y,z| MATA410(x,y,z)},aCAB,aITENS,5)

IF lMSERROAUTO
   MOSTRAERRO()
   RETURN .F.
ELSE
   IncProc("PV Estornado")
   // LIMPA O NUMERO DO PEDIDO DE VENDA NO DESEMBARACAO
   SW6->(RECLOCK("SW6",.F.))
   SW6->W6_PEDFAT := ""
   SW6->(MSUNLOCK())
   MSGINFO("Pedido de Venda estornado com sucesso.","P.V.: "+aCAB[1,2])
ENDIF

RETURN .T.
*========================================================================================*
STATIC FUNCTION PCOGrvPV()
*========================================================================================*
LOCAL nTotal:=15
LOCAL nCount:=0
LOCAL nDec := AVSX3("C6_PRCVEN",AV_DECIMAL)
LOCAL cSEQITEM

PCOInitVar()

ProcRegua(nTotal)

IncProc("Lendo Capa...")
// CAPA
aCAB  := {{"C5_NUM"    ,PCOVALPAR("GETSXENUM"),NIL},;
          {"C5_TIPO"   ,LEFT(cTipoPV,1),NIL},;
          {"C5_CLIENTE",cCLIENTE    ,NIL},;
          {"C5_LOJACLI",cCLLOJA     ,NIL},;
          {"C5_LOJAENT",cCLLOJA     ,NIL},;
          {"C5_TIPOCLI",cTIPCLI     ,NIL},;
          {"C5_CONDPAG",cCONDPAMS   ,NIL},;
          {"C5_EMISSAO",dDATABASE   ,NIL},;
          {"C5_MOEDA"  ,1           ,NIL}}
// ITENS DA NF
cSEQITEM := "01"
aITENS   := {}
SB1->(DBSETORDER(1))
EIW->(DBSETORDER(1))
EIW->(DBSEEK(cFilEIW+SW6->W6_HAWB,.T.))
DO WHILE ! EIW->(EOF()) .AND.;
   EIW->(EIW_FILIAL+EIW_HAWB) == (cFilEIW+SW6->W6_HAWB)

   IF nCount > nTotal
      ProcRegua(nTotal)
      nCount:=0
   ENDIF
   nCount++
   IncProc("Lendo Item: "+ALLTRIM(EIW->EIW_COD_I))

   nVlrTot  := EIW->EIW_FOB_R+EIW->EIW_FRETE+EIW->EIW_SEGURO+EIW->EIW_VALOR
   nVlrUnit := ROUND(nVlrTot/EIW->EIW_QTDE,nDec)
// nVlrTot  := nVlrUnit*EIW->EIW_QTDE//Para bater o Total
   //DFS - 15/03/13 - Inclusão de NoRound para que não arredonde e respeite apenas as duas primeiras casas decimais na geração do PV
   nVlrTot := Round(nVlrUnit*EIW->EIW_QTDE,2)  // GFP - 02/04/2013 - Implementado arredondamento

   SB1->(DBSEEK(XFILIAL("SB1")+EIW->EIW_COD_I))

   AADD(aITENS,{{"C6_NUM"    ,aCAB[1,2]     ,NIL},;
                {"C6_ITEM"   ,cSEQITEM      ,NIL},;
                {"C6_PRODUTO",EIW->EIW_COD_I,NIL},;
                {"C6_DESCRI" ,SB1->B1_DESC  ,NIL},;
                {"C6_UM"     ,SB1->B1_UM    ,NIL},;
                {"C6_TES"    ,SB1->B1_TS    ,NIL},;
                {"C6_LOCAL"  ,SB1->B1_LOCPAD,NIL},;
                {"C6_QTDVEN" ,EIW->EIW_QTDE ,NIL},;
                {"C6_PRCVEN" ,nVlrUnit      ,NIL},;
                {"C6_PRUNIT" ,nVlrUnit      ,NIL},;
                {"C6_VALOR"  ,nVlrTot       ,NIL},;
                {"C6_ENTREG" ,dDATABASE     ,NIL}})
   cSEQITEM := SOMAIT(cSEQITEM)
   EIW->(DBSKIP())
ENDDO
IncProc("Gerando PV, Aguarde...")
lMSERROAUTO := .F.
MSEXECAUTO({|x,y,z| MATA410(x,y,z)},aCAB,aITENS,3)
IF lMSERROAUTO
   MOSTRAERRO()
   RETURN .F.
ELSE
   IncProc("PV Gerado")
   // GRAVA O NUMERO DO PEDIDO DE VENDA NO DESEMBARACAO
   SW6->(RECLOCK("SW6",.F.))
   SW6->W6_PEDFAT := aCAB[1,2]
   SW6->(MSUNLOCK())
   MSGINFO("Pedido de Venda gerado com sucesso, codigo: "+ALLTRIM(SW6->W6_PEDFAT),"Atencao")
ENDIF

RETURN .T.
*========================================================================================*
STATIC FUNCTION PCOVALPAR(cP_ACAO)
*========================================================================================*
LOCAL lRET,aORDANT
*
lRET    := .T.
cP_ACAO := IF(cP_ACAO==NIL,"",cP_ACAO)
IF cP_ACAO == "cCONDPAMS"
   IF EMPTY(cCONDPAMS)
      MSGINFO("Condicao de pagamento nao preenchida.","Atencao")
      lRET := .F.
   ELSE
      aORDANT := {SE4->(INDEXORD())}
      SE4->(DBSETORDER(1))
      IF ! (SE4->(DBSEEK(XFILIAL("SE4")+cCONDPAMS)))
         MSGINFO("Condicao de Pagamento nao cadastrada no Modulo de Faturamento.","Atencao")
         lRET := .F.
      ENDIF
      SE4->(DBSETORDER(aORDANT[1]))
   ENDIF
ELSEIF cP_ACAO == "CLIENTE_PO"
       aORDANT := {SW7->(INDEXORD()),SW2->(INDEXORD()),SA1->(INDEXORD())}
       SW7->(DBSETORDER(1))
       IF ! (SW7->(DBSEEK(XFILIAL("SW7")+SW6->W6_HAWB)))
          MSGINFO("Nao tem itens no Desembaraco.","Atencao")
          lRET := .F.
       ELSE
          SW2->(DBSETORDER(1))
          IF ! (SW2->(DBSEEK(XFILIAL("SW2")+SW7->W7_PO_NUM)))
             MSGINFO("Pedido de importacao nao encontrado: "+SW7->W7_PO_NUM,"Atencao")
             lRET := .F.
          ELSEIF EMPTY(SW2->W2_CLIENTE)
             MSGINFO("Cliente nao informado no PO: "+SW7->W7_PO_NUM ,"Atencao")
             lRET := .F.
          ELSE
             SA1->(DBSETORDER(1))
             IF ! (SA1->(DBSEEK(XFILIAL("SA1")+SW2->W2_CLIENTE)))
                MSGINFO("Cliente nao cadastrado: "+SW2->W2_CLIENTE,"Atencao")
                lRET := .F.
             ELSE
                cCLIENTE := SW2->W2_CLIENTE
                cCLLOJA  := SA1->A1_LOJA
                cTIPCLI  := SA1->A1_TIPO
              //EIW->(DBSETORDER(1))
              //IF ! (EIW->(DBSEEK(XFILIAL("EIW")+SW6->W6_HAWB)))
              //   MSGINFO("Nao existem Valores Gravados !","Atencao")
              //   lRET := .F.
              //ENDIF
             ENDIF
          ENDIF
       ENDIF
ELSEIF cP_ACAO == "bOK"
       IF !PCOVALPAR("cCONDPAMS") .OR.;
          !PCOVALPAR("CLIENTE_PO")
          lRET := .F.
       ELSEIF !MSGYESNO("Confirma Gravacao dos Valores e Geracao do PV ?")
          lRET := .F.
       ENDIF
ELSEIF cP_ACAO == "GETSXENUM"
       lRET := GETSXENUM("SC5")
       CONFIRMSX8()
ENDIF
RETURN(lRET)
*========================================================================================*
Static Function PCOGetNota()
*========================================================================================*
LOCAL oDlg1,lMarcado
LOCAL bOk    := {|| lOK:=.T. , (oDlg1:End()) }
LOCAL bCancel:= {|| (oDlg1:End()) }
LOCAL lOK    := .F.
LOCAL nTipo  := 1
LOCAL nPula  := 15
LOCAL nCo1   := 5
LOCAL nCo2   := nCo1+30
LOCAL nCo3   := nCo2+55
LOCAL nTam   := 35
LOCAL nAlt   := 8
LOCAL nLinha := 20
LOCAL cTpNrNfs := EasyGParam("MV_TPNRNFS",,"1") //LRS - 11/09/2017
PRIVATE lOldNF := .T. //LRS - 11/09/2017
PRIVATE cNota :=WorkItens->WN_DOC
PRIVATE cSerie:=WorkItens->WN_SERIE
DO WHILE .T.

   lOK   :=.F.
   nLinha:=020

   IF(EasyEntryPoint("EICCO100"),Execblock("EICCO100",.F.,.F.,'NOTA_SERIE'),) //LRS - 11/09/2017

   If !lOldNF .OR. lIntNFTEAI  //LRS - 11/09/2017   //NCF - Refeita as verificações para manter a opção de digitação manual de Nro. da Nota
      If (cTpNrNfs == "1" .OR. cTpNrNfs == "2")
         IF lOK:= SX5NumNota(.F.,cTpNrNfs)
            cNota := NxTSx5Nota(cSerie,.T.,cTpNrNfs)
         Else
            RETURN .F.
         Endif
      ElseIf cTpNrNfs == "3"
	    cNota := Ma461NumNF(.T.,Left(WorkItens->WN_SERIE,SerieNfId("SWN",6,"WN_SERIE")),WorkItens->WN_DOC) //AAF 18/02/2015
      EndIf
   EndIf

      DEFINE MSDIALOG oDlg1 TITLE "Digitacao do Numero da NFT dos Itens" FROM 0,0 TO 14,50 Of oDlg1

            oPanel:= TPanel():New(0, 0, "", oDlg1,, .F., .F.,,, 90, 165) //MCF - 23/07/2015
            oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

            @ nLinha,nCo1 SAY  "Numero" SIZE nTam,nAlt of oPanel PIXEL
            @ nLinha,nCo2 MSGET cNota   SIZE nTam,nAlt of oPanel PIXEL VALID (IF(EMPTY(cNota),cSerie:=SPACE(LEN(WorkItens->WN_SERIE)),),.T.)
            nLinha+=nPula

            @ nLinha,nCo1 SAY "Serie"  SIZE nTam,nAlt of oPanel PIXEL
            @ nLinha,nCo2 MSGET cSerie PICTURE AvSx3("F1_SERIE",AV_PICTURE) SIZE nTam,nAlt of oPanel PIXEL WHEN !EMPTY(cNota)
            nLinha+=nPula

            nLinha := 17
            @ nLinha,nCo3-05 TO (nLinha+(nPula*2)),nCo3+55 LABEL "Itens" of oPanel PIXEL
            nLinha+=nPula-7

            @ nLinha,nCo3 RADIO nTipo ITEMS "Marcados","Atual" of oPanel PIXEL 3D SIZE 45,10

      ACTIVATE MSDIALOG oDlg1 ON INIT  EnchoiceBar(oDlg1,bOk,bCancel,,)  CENTERED
   
   IF lOK

      IF lNftFilha
      	 IF !PCOValid("NFT")
      	    MSGSTOP("O numero informado para gerar a NF Transferencia já foi utilizado, deve ser informado outro diferente")
      	    RETURN .F.
      	 ENDIF
      ENDIF

      If lIntNFTEAI .And. !Empty(cSerie)   //NCF - 13/04/2018 - Este caracter identifica a nota provisóra interna para efeitos de determinação do status da Nota quando em uma integração
         cSerie := "_"                     //                   de um lote de notas uma das integrações dá problema e é necessário fazer o cancelamento automático das outras notas.
      EndIf
      
	cSerie := SerieNfId(,4,"WN_SERIE",dDataBase,GetMv("MV_ESPEIC",,'NFE'),cSerie)

      IF nTipo = 2
         WorkItens->WN_DOC  :=cNota
         WorkItens->WN_SERIE:=cSerie
         RETURN .T.
      ENDIF

      ProcRegua(WorkItens->(LASTREC()))
      lMarcado:=.F.

      WorkItens->(DBGOTOP())
      DO WHILE WorkItens->(!EOF())

         IncProc()
         IF lNftFilha
            IF WorkItens->WK_FLAG = "LBNO"
               WorkItens->(DBSKIP())
               LOOP
            ENDIF
         ELSE
         	IF EMPTY(WorkItens->WK_FLAG)
               WorkItens->(DBSKIP())
               LOOP
            ENDIF
         ENDIF
         lMarcado:=.T.
         WorkItens->WN_DOC  :=cNota
         WorkItens->WN_SERIE:=cSerie
         //WorkItens->WK_FLAG :=""
         WorkItens->(DBSKIP())

      ENDDO
      WorkItens->(DBGOTOP())

      IF !lMarcado
         MSGSTOP("Nenhum item esta selecionado para digitacao.")
         LOOP
      ENDIF

   ELSE

      RETURN .F.

   ENDIF

   EXIT

ENDDO

Return .T.

/*
//Autor    : Igor de Araújo Chiba
//Data     : 19/02/09
//Objetivo : Mostrar totais dos itens
//Revisão  : Guilherme Fernandes Pilan - GFP
//Data/Hora: 03/11/2014 :: 14:48
//Objetivo : Ajuste de função para que possa ser chamada atraves do EICDI154/EICDI554.
*/
*========================================================================================*
Function PCOTotDesp(cChave)
*========================================================================================*
LOCAL  oDlg2
LOCAL  nFobR    := 0
LOCAL  nFrete   := 0
LOCAL  nSeguro  := 0
LOCAL  nCIF     := 0
LOCAL  nDesp    := 0
LOCAL  nIPIval  := 0
LOCAL  nIPIbase := 0
LOCAL  nValMerc := 0 //WHRS
LOCAL  nICMSvl  := 0
LOCAL  nICMSbs  := 0
LOCAL  nVlTota  := 0
LOCAL  PICT15_2 := AVSX3("W6_FOB_TOT" ,6)

LOCAL nLinha    := 10
LOCAL nPula     := 15
LOCAL nCo1      := 8
LOCAL nCo2      := 50
LOCAL nCo3      := 130
LOCAL nCo4      := 170
LOCAL nTam      := 70
LOCAL nAlt      := 8
LOCAL cTitFob   := AVSX3("EIW_FOB_R" ,5)
LOCAL cTitFret  := AVSX3("EIW_FRETE" ,5)
LOCAL cTitSeg   := AVSX3("EIW_SEGURO",5)
LOCAL cTitDesp  := AVSX3("EIW_VALOR" ,5)
LOCAL cTitIcmBs := AVSX3("EIW_BASEIC",5)
LOCAL cTitIcm   := AVSX3("EIW_VL_ICM",5)
LOCAL cTitIpiBs := AVSX3("EIW_IPIBAS",5)
LOCAL cTitIpi   := AVSX3("EIW_IPIVAL",5)
LOCAL nTelaLarg := 76
Local nNFT_DESP_BASE_IMP:= 0

DEFAULT cChave := ""

lCalcNFT := If(!Empty(cChave),!(EasyGParam("MV_EASY",,"N") = "S" .AND. EasyGParam("MV_PCOIMPO",,.T.)),lCalcNFT)
lICMSRedIPI := If(!Empty(cChave),EasyGParam("MV_EIC0018",,.F.),lICMSRedIPI)
lICMSRedIPI := If(ValType(lICMSRedIPI)=="C",StrTran(lICMSRedIPI,".","")=="T",lICMSRedIPI) //AAF 26/12/2014 - Alguns dicionários sairam com MV_EIC0018 com tipo caracter.
SWZ->(DBSETORDER(2))

If !Empty(cChave)
   EIW->(DBSETORDER(1))
   EIW->(DBSEEK(cChave))
   DO WHILE EIW->(!EOF()) .AND. EIW->(EIW_FILIAL+EIW_HAWB) == cChave
      nFobR    += EIW->EIW_FOB_R
      nFrete   += EIW->EIW_FRETE
      nSeguro  += EIW->EIW_SEGURO
      nDesp    += EIW->EIW_VALOR    
      //MFR 13/03/2019 OSSME-2253
      If AvFlags("NFT_DESP_BASE_IMP")
         nVlTota += EIW->EIW_VALTOT
         nNFT_DESP_BASE_IMP += EIW->(EIW_VALTOT + EIW_DESPCU)
      Endif

      IF lCalcNFT
         nIPIVal   += EIW->EIW_IPIVAL
         nIPIbase  += EIW->EIW_IPIBAS
         nICMSbs   += EIW->EIW_BASEIC
         nICMSvl   += EIW->EIW_VL_ICM

        //NCF - 24/03/2015 - Zera a base do IPI se a taxa estiver zerada (IPI->Supenso ou Isento)
        If EIW->(FieldPos("EIW_VALMER")) > 0                        //NCF - 04/07/2018 - Deve somar o ICMS Reduzido
           nValMerc  += If( EIW->EIW_IPITX == 0 , EIW->EIW_VALMER , IF( SWZ->(DBSEEK(xFilial("SWZ")+EIW->EIW_OPERAC)) .And. SWZ->WZ_RED_CTE > 0 , EIW->( EIW_FOB_R + EIW_FRETE + EIW_SEGURO + EIW->EIW_VALOR + EIW_VL_ICM ) , EIW->EIW_IPIBAS ) )
        Else
           nValMerc  += EIW->EIW_IPIBAS
        EndIf

      ENDIF
      EIW->(DBSKIP())
   ENDDO
Else
   WorkItens->(DBGOTOP())
   DO WHILE WorkItens->(!EOF())
      nFobR    += WorkItens->WN_FOB_R
      nFrete   += WorkItens->WN_FRETE
      nSeguro  += WorkItens->WN_SEGURO
      nDesp    += WorkItens->WKVALOR
      //MFR 13/03/2019 OSSME-2253
      If AvFlags("NFT_DESP_BASE_IMP")
         nVlTota += WorkItens->EIW_VALTOT
         nNFT_DESP_BASE_IMP += WorkItens->(EIW_VALTOT + EIW_DESPCU)
      Endif

      IF lCalcNFT
         nIPIVal   += WorkItens->WKIPIVAL
         nIPIbase  += WorkItens->WKIPIBASE
         nICMSbs   += WorkItens->WKBASEICMS
         nICMSvl   += WorkItens->WKVL_ICM

        //NCF - 24/03/2015 - Zera a base do IPI se a taxa estiver zerada (IPI->Suspenso ou Isento)
        If WorkItens->(FieldPos("EIW_VALMER")) > 0                                 //NCF - 04/07/2018 - Deve somar o ICMS Reduzido
           nValMerc  += If( WorkItens->WKIPITX == 0 , WorkItens->WKVALMERC , IF( SWZ->(DBSEEK(xFilial("SWZ")+WorkItens->WkOperacao)) .And. SWZ->WZ_RED_CTE > 0 , WorkItens->( WN_FOB_R + WN_FRETE + WN_SEGURO + WKVALOR + WKVL_ICM ) , WorkItens->WKIPIBASE ) )
        Else
           nValMerc  += WorkItens->WKIPIBASE
        EndIf

      ENDIF
      WorkItens->(DBSKIP())
   ENDDO
   WorkItens->(DBGOTOP())
EndIf

lICMSRedIPI := If (ValType("lICMSRedIPI")<>"L",.F.,lICMSRedIPI) //LGS-22/12/2014

/* wfs jul/2019
   bloco retornado para tratar apenas o legado, para clientes que tiveram notas de transferências geradas antes da publicação dos campos 
   YB_TOTNFT, EIW_VALTOT e EIW_DESPCU - http://tdn.totvs.com/pages/releaseview.action?pageId=331854475- realizada no release 12.1.7 de agosto/2018.
   atualização da variável nVlTota, apenas para visualização do total; quando a nota fiscal gerada e os campos EIW_VALTOT e EIW_DESPCU não possuem valores gravados. */
If !AvFlags("NFT_DESP_BASE_IMP") .Or. PCOGerado("VERM") .And. nNFT_DESP_BASE_IMP == 0
   IF lCalcNFT
      If lICMSRedIPI .And. nBasRedICM > 0
         nVlTota := nIPIVal + nBasRedICM  //valor total soma das base IPI + soma vlr IPI
      Else                                                                   //NCF - 04/07/2018 - Deve somar o ICMS Calculado (com ou sem redução)
         nVlTota := nIPIVal + If(EIW->(FieldPos("EIW_VALMER")) > 0,nValMerc, (nFobR + nFrete + nSeguro + nDesp + nICMSvl) )  // nIPIbase //NCF - 24/03/2015 - Zera a base do IPI se a taxa estiver zerada (IPI->Suspenso ou Isento) 
      EndIf
   ELSE
      nVlTota := nFobR+nFrete+nSeguro+nDesp
   ENDIF
EndIf

DEFINE MSDIALOG oDlg2 TITLE "TOTAIS" FROM 0,10 TO 15,nTelaLarg //MCF - 12/01/2015
   nLinha := 10

   @nLinha,nCo1 SAY  cTitFob                          SIZE nTam,nAlt of oDlg2 PIXEL     //FOB
   @nLinha,nCo2 MSGET nFobR WHEN .F. PICTURE PICT15_2 SIZE nTam,nAlt of oDlg2 PIXEL
   nLinha+=nPula

   @nLinha,nCo1 SAY cTitFret                           SIZE nTam,nAlt of oDlg2 PIXEL    //FRETE
   @nLinha,nCo2 MSGET nFrete WHEN .F. PICTURE PICT15_2 SIZE nTam,nAlt of oDlg2 PIXEL
   nLinha+=nPula

   @nLinha,nCo1 SAY cTitSeg                             SIZE nTam,nAlt of oDlg2 PIXEL    //SEGURO
   @nLinha,nCo2 MSGET nSeguro WHEN .F. PICTURE PICT15_2 SIZE nTam,nAlt  of oDlg2 PIXEL
   nLinha+=nPula

   @nLinha,nCo1 SAY cTitDesp                          SIZE nTam,nAlt of oDlg2 PIXEL  //DESPESA
   @nLinha,nCo2 MSGET nDesp WHEN .F. PICTURE PICT15_2 SIZE nTam,nAlt of oDlg2 PIXEL
   nLinha+=nPula

   IF lCalcNFT

      nLinha := 10
      @nLinha,nCo3 SAY cTitIcmbs                            SIZE nTam,nAlt of oDlg2 PIXEL // BASE ICMS
      @nLinha,nCo4 MSGET nICMSbs  WHEN .F. PICTURE PICT15_2 SIZE nTam,nAlt of oDlg2 PIXEL
      nLinha+=nPula

      @nLinha,nCo3 SAY cTitIcm                             SIZE nTam,nAlt of oDlg2 PIXEL   //VLR ICMS
      @nLinha,nCo4 MSGET nICMSvl WHEN .F. PICTURE PICT15_2 SIZE nTam,nAlt of oDlg2 PIXEL
      nLinha+=nPula

      @nLinha,nCo3 SAY   cTitIpiBs                           SIZE nTam,nAlt of oDlg2 PIXEL  //BASE IPI
      @nLinha,nCo4 MSGET nIPIbase  WHEN .F. PICTURE PICT15_2 SIZE nTam,nAlt of oDlg2 PIXEL
      nLinha+=nPula

      @nLinha,nCo3 SAY cTitIpi                              SIZE nTam,nAlt of oDlg2 PIXEL    //VLR IPI
      @nLinha,nCo4 MSGET nIPIVal  WHEN .F. PICTURE PICT15_2 SIZE nTam,nAlt of oDlg2 PIXEL
      nLinha+=nPula

      @nLinha,nCo3 SAY "Total Geral"                         SIZE nTam,nAlt of oDlg2 PIXEL
      @nLinha,nCo4 MSGET nVlTota   WHEN .F. PICTURE PICT15_2 SIZE nTam,nAlt of oDlg2 PIXEL

   ELSE

      @nLinha,nCo1 SAY "Total Geral"                         SIZE nTam,nAlt of oDlg2 PIXEL
      @nLinha,nCo2 MSGET nVlTota   WHEN .F. PICTURE PICT15_2 SIZE nTam,nAlt of oDlg2 PIXEL

   ENDIF

ACTIVATE MSDIALOG oDlg2 CENTERED


Return .T.
*========================================================================================*
Function PCOImprNFT(lEIW)
*========================================================================================*
PCOInitVar()
IF lEIW

   EIW->(DBSETORDER(1))
   IF !EIW->(DBSEEK(cFilEIW+SW6->W6_HAWB))

      MSGSTOP("Nao existe valores gravados para imprimir.")
      RETURN .F.

   ENDIF

ELSE

   SWN->(DBSETORDER(3))//WN_FILIAL+WN_HAWB+WN_TIPO_NF
   IF !SWN->(DBSEEK(cFilSWN+SW6->W6_HAWB+"9"))

      SWN->(DBSETORDER(1))
      MSGSTOP("Nao existe itens da NFT para impressao.")
      RETURN .F.

   ENDIF
   SWN->(DBSETORDER(1))

ENDIF


PRIVATE cTitulo:="Relatorio dos Valores da NFT"


#DEFINE COURIER_07  oFont1
#DEFINE COURIER_N   oFont2
#DEFINE COURIER_08  oFont3
#DEFINE COURIER_10  oFont4
#DEFINE COURIER_12  oFont5


PRINT oPrn NAME ''
      oPrn:SetLandsCape()
ENDPRINT

AVPRINT oPrn NAME cTitulo

   DEFINE FONT oFont1  NAME 'Courier New' SIZE 0,07 OF  oPrn
   DEFINE FONT oFont2  NAME 'Courier New' SIZE 0,08 OF  oPrn BOLD
   DEFINE FONT oFont3  NAME 'Courier New' SIZE 0,08 OF  oPrn
   DEFINE FONT oFont4  NAME 'Courier New' SIZE 0,10 OF  oPrn
   DEFINE FONT oFont5  NAME 'Courier New' SIZE 0,12 OF  oPrn

   AVPAGE

      oPrn:oFont:=COURIER_07

      Processa( {||DI155RelNFE(lEIW)} ,"Impressao da Nota Fiscal...",,.T.)

   AVENDPAGE

AVENDPRINT

oFont1:End()
oFont2:End()
oFont3:End()
oFont4:End()
oFont5:End()

RETURN .T.
*----------------------------------------------------------------------------------*
Static Function DI155RelNFE(lEIW)
*----------------------------------------------------------------------------------*
PRIVATE nTotal:=10,nCount:=0

PCOInitVar()

ProcRegua( nTotal )

IncProc("Iniciando variaveis do relatorio, Aguarde...")

PRIVATE lAbortPrint:=.F.
PRIVATE nItem:= nValMerc :=nFOB := nFrete:= nSeguro:= nIPIVal:= nICMSVal:= nICMSEmb := 0
PRIVATE nTotGeral:=0
PRIVATE cPictNotaF:=IF(!EMPTY(AVSX3("WN_DOC",6)),AVSX3("WN_DOC",6),"@!")
PRIVATE cPictItem:= AVSX3('B1_COD',6)
PRIVATE cPictFre := '@E 9999,999,999.99'
PRIVATE cPictSeg := '@E 999999,999.99'
PRIVATE cPICT15_2:= '@E 999999,999.99'
PRIVATE cPICT06_2:= '@E 999.99'
PRIVATE cPictPeso:= AVSX3('W7_PESO',6)
PRIVATE cPICTICMS:= AVSX3('YD_ICMS_RE',6)

lPrimPag:= .T.
nLimPage:= 2150
nColFim := 2980
nLin    := 99999
nPag    := 0
cChave  := ''
cNFChave:= ''

nCol01 := 1
nCol03 := nCol01    //Produto
nCol02 := nCol03+670//CFO
nCol04 := nCol02+100//Operac
nCol05 := nCol04+320//Peso
nCol07 := nCol05+300//Qtde
nCol08 := nCol07+260//Preco
nCol11 := nCol08+240//FOB
nCol09 := nCol11+250//Frete
nCol10 := nCol09+230//Seguro
nCol14 := nCol10+230//Vlr Merc
nCol15 := nCol14+115//%ICMS
nCol16 := nCol15+215//Vlr ICMS
nCol21 := nCol16+115//% IPI
nCol22 := nCol21+215//Vlr IPI
/* GFP - 11/04/2012 - Inclusão dos valores II, PIS e COFINS
nCol23 := nCol22+215//Vlr II
nCol24 := nCol23+215//Vlr PIS
nCol25 := nCol24+215//Vlr COFINS
nColFim:= nCol25 //nCol22*/

SF1->(DBSETORDER(5))
SWN->(DBSETORDER(3))
SW7->(DBSETORDER(1))
SW2->(DBSETORDER(1))

SW7->(DbSeek(xFILIAL('SW7')+SW6->W6_HAWB))
SW2->(DbSeek(xFilial("SW2")+SW7->W7_PO_NUM))

aSemSX3:={}
AADD(aSemSX3,{"WK_NOTA"  ,"C",LEN(SWN->WN_DOC)    ,0})
AADD(aSemSX3,{"WK_SERIE" ,"C",LEN(SWN->WN_SERIE)  ,0})
AADD(aSemSX3,{"WK_CFO"   ,"C",LEN(SWN->WN_CFO)    ,0})
AADD(aSemSX3,{"WK_OPERA" ,"C",LEN(SWN->WN_OPERACA),0})
AADD(aSemSX3,{"WK_COD_I" ,"C",LEN(SWN->WN_PRODUTO),0})
AADD(aSemSX3,{"WK_RECNO" ,"N",15,2})

aCampos:={}
aHeader:={}
cFile:=E_CriaTrab(,aSemSX3,"Work",,)
IndRegua("Work",cFile+TEOrdBagExt(),"WK_NOTA+WK_SERIE+WK_CFO+WK_OPERA+WK_COD_I")

IF lEIW

   EIW->(DBSETORDER(1))
   IF EIW->(DBSEEK(cFilEIW+SW6->W6_HAWB))

      SWZ->(DBSETORDER(2))
      DO WHILE EIW->(!EOF()) .AND. EIW->EIW_FILIAL == cFilEIW .AND. EIW->EIW_HAWB == SW6->W6_HAWB

         IF nCount > nTotal
            ProcRegua( nTotal )
            nCount:=0
         ENDIF
         nCount++
         IncProc("Lendo dados...")

         SWZ->(DBSEEK(cFilSWZ+EIW->EIW_OPERAC))

         Work->(DBAPPEND())
         Work->WK_NOTA  := EIW->EIW_NOTA
         Work->WK_SERIE := EIW->EIW_SERIE
         Work->WK_COD_I := EIW->EIW_COD_I
         Work->WK_CFO   := SWZ->WZ_CFO
         Work->WK_OPERA := EIW->EIW_OPERAC
         Work->WK_RECNO := EIW->(RECNO())
         EIW->(DBSKIP())

      ENDDO

   ENDIF

ELSE

   IF SWN->(DBSEEK(cFilSWN+SW6->W6_HAWB+"9"))

      DO WHILE SWN->(!EOF()) .AND. SWN->WN_FILIAL == cFilSWN .AND. SWN->WN_HAWB == SW6->W6_HAWB .AND. SWN->WN_TIPO_NF = "9"

         IF nCount > nTotal
            ProcRegua( nTotal )
            nCount:=0
         ENDIF
         nCount++
         IncProc("Lendo dados...")

         Work->(DBAPPEND())
         Work->WK_NOTA  := SWN->WN_DOC
         Work->WK_SERIE := SWN->WN_SERIE
         Work->WK_COD_I := SWN->WN_PRODUTO
         Work->WK_CFO   := SWN->WN_CFO
         Work->WK_OPERA := SWN->WN_OPERACA
         Work->WK_RECNO := SWN->(RECNO())
         SWN->(DBSKIP())

      ENDDO

   ENDIF

ENDIF

Work->(DBGOTOP())

ProcRegua( Work->(LASTREC()) )

nTxFrete :=SW6->W6_TX_FRET
nTxSeguro:=SW6->W6_TX_SEG

IF lEIW
   SW7->(DBSetOrder(4))//W7_FILIAL+W7_HAWB+W7_PO_NUM+W7_POSICAO+W7_PGI_NUM
   SW8->(DBSetOrder(6))//W8_FILIAL+W8_HAWB+W8_INVOICE+W8_PO_NUM+W8_POSICAO+W8_PGI_NUM
   SB1->(DBSETORDER(1))
   EIZ->(DBSETORDER(1))

   EIZ->(DBSEEK(cFilEIZ+SW6->W6_HAWB))
   DO WHILE EIZ->(!EOF()) .AND. EIZ->EIZ_FILIAL = cFilEIZ .AND. EIZ->EIZ_HAWB == SW6->W6_HAWB
      IF EIZ->EIZ_DOCUME = "FRETE"
         nTxFrete :=EIZ->EIZ_TX_NEW
      ELSEIF EIZ->EIZ_DOCUME = "SEGURO"
         nTxSeguro:=EIZ->EIZ_TX_NEW
      ENDIF
      EIZ->(DBSKIP())
   ENDDO

ENDIF

DO WHILE Work->(!EOF())

   IF lEIW
      EIW->(DBGOTO(Work->WK_RECNO))
   ELSE
      SWN->(DBGOTO(Work->WK_RECNO))
   ENDIF

   DI155DetRel(lEIW) //.T. EIW .F. SWN

   Work->(DBSKIP())

ENDDO

DI155Totais()

IF lEIW
   SW7->(DBSetOrder(1))
   SW8->(DBSetOrder(1))
   SWZ->(DBSETORDER(1))
   SB1->(DBSETORDER(1))
ENDIF

SF1->(DBSETORDER(1))
SWN->(DBSETORDER(1))
SWZ->(DBSETORDER(1))

Work->((E_EraseArq(cFile)))


RETURN .T.
*----------------------------------*
STATIC FUNCTION DI155CabRel(lEIW)
*----------------------------------*

IF lPrimPag
   lPrimPag:=.F.
   cNFChave:=TRANS(cNotaF,cPictNotaF)+" "+cSerie
ELSE
   AVNEWPAGE
ENDIF

nLin:= 100
nPag++

oPrn:Box( nLin,01 ,nLin+1,4000)
nLin+=25

oPrn:Say(nLin,nCol01 ,SM0->M0_NOME,COURIER_12)
oPrn:Say(nLin,nColFim/2,cTitulo,COURIER_12,,,,2)
oPrn:Say(nLin,nColFim,"Pagina..: "+STR(nPag,8),COURIER_12,,,,1)
nLin+=50

oPrn:Say(nLin,nCol01   ,"SIGAEIC"      ,COURIER_12)
oPrn:Say(nLin,nColFim/2,"Analítico"    ,COURIER_12,,,,2)
oPrn:Say(nLin,nColFim  ,"Emissao.: "   +DTOC(dDataBase),COURIER_12,,,,1)
nLin+=50

oPrn:Box( nLin,01 ,nLin+1,4000)
nLin +=25

SYT->(DBSEEK(XFILIAL('SYT')+SW2->W2_IMPORT))

oPrn:Say(nLin,nCol01,"Empresa...............: "+SW2->W2_IMPORT+" - "+ALLTRIM(SYT->YT_NOME)+" - "+ALLTRIM(SYT->YT_ENDE),COURIER_08)
nLin+=45
oPrn:Say(nLin,nCol01,"Processo..............: "+SW6->W6_HAWB,COURIER_08)
oPrn:Say(nLin,0800  ,"Conhecimento........: "  +SW6->W6_HOUSE,COURIER_08)
oPrn:Say(nLin,1600  ,"Dt. Entrega..........: " +DTOC(SW6->W6_DT_ENTR),COURIER_08)
nLin+=45
oPrn:Say(nLin,nCol01,"Dt. Processo..........: "+DTOC(SW6->W6_DT_HAWB),COURIER_08)
oPrn:Say(nLin,0800  ,"D.I.................: "  +TRANS(SW6->W6_DI_NUM,'@R 99/9999999-9'),COURIER_08)
oPrn:Say(nLin,1600  ,"Dt. D.I..............: " +DTOC(SW6->W6_DTREG_D),COURIER_08)
nLin+=45
oPrn:Say(nLin,nCol01,"Tx. Conversao US$ D.I.: "+TRANS(SW6->W6_TX_US_D,AVSX3('W6_TX_US_D',6)),COURIER_08)
oPrn:Say(nLin,0800  ,"Tx. Conversao Frete.: "  +TRANS(nTxFrete,AVSX3('W6_TX_FRET',6)),COURIER_08)
oPrn:Say(nLin,1600  ,"Tx. Conversao Seguro.: " +TRANS(nTxSeguro,AVSX3('W6_TX_SEG',6)),COURIER_08)
nLin+=50
oPrn:Say( nLin,nCol01 ,"***Os valores deste relatório estão expressos em REAIS" ,COURIER_08)
nLin+=50


oPrn:Box( nLin,01,nLin+1,4000)
nLin +=25

oPrn:Say( nLin,nCol03,"Produto"          ,COURIER_07)
oPrn:Say( nLin,nCol02,"CFO"              ,COURIER_07)
oPrn:Say( nLin,nCol04,"Operac"           ,COURIER_07)
oPrn:Say( nLin,nCol05,"Peso Liq."        ,COURIER_07,,,,1)
oPrn:Say( nLin,nCol07,"Quantidade"       ,COURIER_07,,,,1)
oPrn:Say( nLin,nCol08,"Preco"            ,COURIER_07,,,,1)
oPrn:Say( nLin,nCol11,"Vlr FOB"          ,COURIER_07,,,,1)
oPrn:Say( nLin,nCol09,"Vlr Frete"        ,COURIER_07,,,,1)
oPrn:Say( nLin,nCol10,"Vlr Seguro"       ,COURIER_07,,,,1)
oPrn:Say( nLin,nCol14,"Vlr Mercadoria"   ,COURIER_07,,,,1)
oPrn:Say( nLin,nCol15,"%ICMS"            ,COURIER_07,,,,1)
oPrn:Say( nLin,nCol16,"Vlr ICMS"         ,COURIER_07,,,,1)
oPrn:Say( nLin,nCol21,"%IPI"             ,COURIER_07,,,,1)
oPrn:Say( nLin,nCol22,"Vlr IPI"          ,COURIER_07,,,,1)
/*oPrn:Say( nLin,nCol23,"Vlr II"           ,COURIER_07,,,,1)  // GFP - 11/04/2012
oPrn:Say( nLin,nCol24,"Vlr PIS"          ,COURIER_07,,,,1)  // GFP - 11/04/2012
oPrn:Say( nLin,nCol25,"Vlr COFINS"       ,COURIER_07,,,,1)  // GFP - 11/04/2012
*/
nLin +=40
oPrn:Say( nLin,nCol03,REPL('=',LEN(cCod_I+" - "+cDescr)),COURIER_07)
oPrn:Say( nLin,nCol02,REPL('=',LEN(cCFO))      ,COURIER_07)
oPrn:Say( nLin,nCol04,REPL('=',LEN("Operacao")),COURIER_07)
oPrn:Say( nLin,nCol05,REPL('=',LEN(cPeso   ))  ,COURIER_07,,,,1)
oPrn:Say( nLin,nCol07,REPL('=',LEN(cUni+cQtde)),COURIER_07,,,,1)
oPrn:Say( nLin,nCol08,REPL('=',LEN(cPreco  ))  ,COURIER_07,,,,1)
oPrn:Say( nLin,nCol11,REPL('=',LEN(cFOB    ))  ,COURIER_07,,,,1)
oPrn:Say( nLin,nCol09,REPL('=',LEN(cFrete  ))  ,COURIER_07,,,,1)
oPrn:Say( nLin,nCol10,REPL('=',LEN(cSeguro ))  ,COURIER_07,,,,1)
oPrn:Say( nLin,nCol14,REPL('=',LEN(cValMerc)+1),COURIER_07,,,,1)
oPrn:Say( nLin,nCol15,REPL('=',LEN(cICMS_A ))  ,COURIER_07,,,,1)
oPrn:Say( nLin,nCol16,REPL('=',LEN(cICMSVal))  ,COURIER_07,,,,1)
oPrn:Say( nLin,nCol21,REPL('=',LEN(cIPITx  ))  ,COURIER_07,,,,1)
oPrn:Say( nLin,nCol22,REPL('=',LEN(cIPIVal ))  ,COURIER_07,,,,1)
/*oPrn:Say( nLin,nCol23,REPL('=',LEN(cIIVal ))   ,COURIER_07,,,,1)
oPrn:Say( nLin,nCol24,REPL('=',LEN(cPISVal ))  ,COURIER_07,,,,1)
oPrn:Say( nLin,nCol25,REPL('=',LEN(cCOFVal ))  ,COURIER_07,,,,1)
*/
nLin +=35

RETURN .T.
*----------------------------------------------------------------------------------*
Static Function DI155DetRel(lEIW)
*----------------------------------------------------------------------------------*
LOCAL lPassou:=.F.

PCOInitVar()

IF lEIW
   SW8->(DBSeek(cFilSW8+SW6->W6_HAWB+EIW->EIW_INVOIC+EIW->EIW_PO_NUM+EIW->EIW_POSICA+EIW->EIW_PGI_NU))
   SW7->(DbSeek(cFilSW7+SW8->W8_HAWB+SW8->W8_PO_NUM+SW8->W8_POSICAO+SW8->W8_PGI_NUM))
   SB1->(DBSEEK(cFilSB1+EIW->EIW_COD_I))
ENDIF

cNotaF  := Work->WK_NOTA
cSerie  := Work->WK_SERIE
cCFO    := Work->WK_CFO
cOperac := Work->WK_OPERA
cCod_I  := TRAN( Work->WK_COD_I ,cPictItem)
cDescr  := LEFT( IF(lEIW, SB1->B1_DESC  , SWN->WN_DESCR   ) ,25)
cUni    := IF(lEIW,BUSCA_UM(SW7->W7_COD_I+SW7->W7_FABR +SW7->W7_FORN,SW7->W7_CC+SW7->W7_SI_NUM),SWN->WN_UNI)
cPeso   := TRAN( IF(lEIW, SW7->W7_PESO * EIW->EIW_QTDE , SWN->WN_PESOL ), cPictPeso)
cPreco  := TRAN( IF(lEIW,(EIW->EIW_BASEIC/EIW->EIW_QTDE),SWN->WN_PRUNI) , AVSX3("WN_PRUNI",6))
//NCF - 14/09/2012 - Redução de ICMS (Carga Trib. Equiv) na Nota Fiscal de Transferência
SWZ->(DBSETORDER(2))
IF lICMSRedIPI
   IF SWZ->(DBSEEK(cFilSWZ+EIW->EIW_OPERAC)) .And. SWZ->WZ_RED_CTE > 0
      cPreco := TRAN( IF(lEIW,(EIW->EIW_IPIBAS/EIW->EIW_QTDE),SWN->WN_PRUNI), AVSX3("WN_PRUNI",6)) 
   ENDIF
ENDIF

cQtde   := TRAN( IF(lEIW, EIW->EIW_QTDE    , SWN->WN_QUANT   ) , AVSX3("WN_QUANT",6) )
cFOB    := TRAN( IF(lEIW, EIW->EIW_FOB_R   , SWN->WN_FOB_R   ) ,cPICT15_2)
cFrete  := TRAN( IF(lEIW, EIW->EIW_FRETE   , SWN->WN_FRETE   ) ,cPictFre)
cSeguro := TRAN( IF(lEIW, EIW->EIW_SEGURO  , SWN->WN_SEGURO  ) ,cPictSeg)

//NCF - 14/09/2012 - Redução de ICMS (Carga Trib. Equiv) na Nota Fiscal de Transferência
IF lICMSRedIPI
   IF SWZ->(DBSEEK(cFilSWZ+EIW->EIW_OPERAC)) .And. SWZ->WZ_RED_CTE > 0
      cValMerc:= TRAN( IF(lEIW, EIW->EIW_IPIBAS  , SWN->WN_VALOR   ) ,cPICT15_2)
   ELSE
      cValMerc:= TRAN( IF(lEIW, EIW->EIW_BASEIC  , SWN->WN_VALOR   ) ,cPICT15_2)
   ENDIF
ELSE
   cValMerc:= TRAN( IF(lEIW, EIW->EIW_BASEIC  , SWN->WN_VALOR   ) ,cPICT15_2)
ENDIF

cIPITx  := TRAN( IF(lEIW, EIW->EIW_IPITX   , SWN->WN_IPITX   ) ,cPICT06_2)
cIPIVal := TRAN( IF(lEIW, EIW->EIW_IPIVAL  , SWN->WN_IPIVAL  ) ,cPICT15_2)
cICMS_A := TRAN( IF(lEIW, EIW->EIW_ICMS_A  , SWN->WN_ICMS_A  ) ,cPICTICMS)
cICMSVal:= TRAN( IF(lEIW, EIW->EIW_VL_ICM  , SWN->WN_VL_ICM  ) ,cPICT15_2)
/* GFP - 11/04/2012 - Inclusão dos valores II, PIS e COFINS
cIIVal  := TRAN( IF(lEIW, EIW->EIW_IIVAL   , SWN->WN_IIVAL   ) ,cPICT15_2)
cPISVal := TRAN( IF(lEIW, EIW->EIW_VLRPIS  , SWN->WN_VLRPIS  ) ,cPICT15_2)
cCOFVal := TRAN( IF(lEIW, EIW->EIW_VLRCOF  , SWN->WN_VLRPIS  ) ,cPICT15_2)
*/
IF nCount > nTotal
   ProcRegua( nTotal )
   nCount:=0
ENDIF

nCount++
IncProc("Imprimindo Item: "+cCod_I)

IF nLin > nLimPage
   DI155CabRel(lEIW)
   lPassou:=.T.
ENDIF

IF cChave # cNotaF+cSerie

   IF cNFChave # TRANS(cNotaF,cPictNotaF)+" "+cSerie
      IF(lPassou,nLin+=40,)
      DI155Totais()
      cNFChave:= TRANS(cNotaF,cPictNotaF)+" "+cSerie
      lPassou := .F.
   ENDIF

   IF nLin > nLimPage
      DI155CabRel(lEIW)
      lPassou:=.T.
   ENDIF

   IF !lPassou
      oPrn:Box( nLin,01,nLin+1,4000)
      nLin +=15
   ENDIF
   oPrn:Say( nLin,nCol01,"Nota Fiscal: "    +TRANS(cNotaF,cPictNotaF)+" "+cSerie,COURIER_N)

   cChave  := cNotaF+cSerie
   nLin+=40
   oPrn:Box( nLin,01,nLin+1,4000)
   nLin +=15

   IF nLin > nLimPage
      DI155CabRel(lEIW)
   ENDIF

ENDIF

nItem++
oPrn:Say( nLin,nCol03,cCod_I+" - "+cDescr,COURIER_07)
oPrn:Say( nLin,nCol02,cCFO      ,COURIER_07)
oPrn:Say( nLin,nCol04,cOperac   ,COURIER_07)
oPrn:Say( nLin,nCol05,cPeso     ,COURIER_07,,,,1)
oPrn:Say( nLin,nCol07,cUni+cQtde,COURIER_07,,,,1)
oPrn:Say( nLin,nCol08,cPreco    ,COURIER_07,,,,1)
oPrn:Say( nLin,nCol11,cFOB      ,COURIER_07,,,,1)
oPrn:Say( nLin,nCol09,cFrete    ,COURIER_07,,,,1)
oPrn:Say( nLin,nCol10,cSeguro   ,COURIER_07,,,,1)
oPrn:Say( nLin,nCol14,cValMerc  ,COURIER_07,,,,1)
oPrn:Say( nLin,nCol15,cICMS_A   ,COURIER_07,,,,1)
oPrn:Say( nLin,nCol16,cICMSVal  ,COURIER_07,,,,1)
oPrn:Say( nLin,nCol21,cIPITx    ,COURIER_07,,,,1)
oPrn:Say( nLin,nCol22,cIPIVal   ,COURIER_07,,,,1)
/* GFP - 11/04/2012 - Inclusão dos valores II, PIS e COFINS
oPrn:Say( nLin,nCol23,cIIVal    ,COURIER_07,,,,1)
oPrn:Say( nLin,nCol24,cPISVal   ,COURIER_07,,,,1)
oPrn:Say( nLin,nCol25,cCOFVal   ,COURIER_07,,,,1)
*/
nLin+=40

//NCF - 14/09/2012 - Redução de ICMS (Carga Trib. Equiv) na Nota Fiscal de Transferência
IF lICMSRedIPI
   IF SWZ->(DBSEEK(cFilSWZ+EIW->EIW_OPERAC)) .And. SWZ->WZ_RED_CTE > 0
      nValMerc += IF(lEIW, EIW->EIW_IPIBAS  , SWN->WN_VALOR   )
      nICMSEmb += IF(lEIW, EIW->EIW_VL_ICM  , SWN->WN_VL_ICM  )
   ELSE
      nValMerc += IF(lEIW, EIW->EIW_BASEIC  , SWN->WN_VALOR   )
   ENDIF
ELSE
   IF SWZ->(DBSEEK(cFilSWZ+EIW->EIW_OPERAC)) .And. SWZ->WZ_RED_CTE > 0
      nValMerc += IF(lEIW, EIW->( EIW_FOB_R + EIW_FRETE + EIW_SEGURO + EIW->EIW_VALOR + EIW_VL_ICM ) , SWN->( WN_FOB_R + WN_FRETE + WN_SEGURO + WN_DESPESAS + WN_VL_ICM ) )
   Else
      nValMerc += IF(lEIW, EIW->EIW_BASEIC  , SWN->WN_VALOR   )
   EndIf
ENDIF

nFOB     += IF(lEIW, EIW->EIW_FOB_R   , SWN->WN_FOB_R   )
nFrete   += IF(lEIW, EIW->EIW_FRETE   , SWN->WN_FRETE   )
nSeguro  += IF(lEIW, EIW->EIW_SEGURO  , SWN->WN_SEGURO  )
nIPIVal  += IF(lEIW, EIW->EIW_IPIVAL  , SWN->WN_IPIVAL  )
nICMSVal += IF(lEIW, EIW->EIW_VL_ICM  , SWN->WN_VL_ICM  )
/* GFP - 11/04/2012 - Inclusão dos valores II, PIS e COFINS
nIIVal   += IF(lEIW, EIW->EIW_IIVAL   , SWN->WN_IIVAL   )
nPISVal  += IF(lEIW, EIW->EIW_VLRPIS  , SWN->WN_VLRPIS  )
nCOFVal  += IF(lEIW, EIW->EIW_VLRCOF  , SWN->WN_VLRPIS  )
*/

RETURN .T.
*---------------------------------------------------------------------------------*
Static FUNCTION DI155Totais()
*---------------------------------------------------------------------------------*
IF nItem > 1
   oPrn:Say( nLin,nCol11,REPL('=',LEN(cPICT15_2)-3) ,COURIER_07,,,,1)
   oPrn:Say( nLin,nCol09,REPL('=',LEN(cPictFre )-3) ,COURIER_07,,,,1)
   oPrn:Say( nLin,nCol10,REPL('=',LEN(cPictSeg )-3) ,COURIER_07,,,,1)
   nLin +=30
   oPrn:Say( nLin,nCol11,TRAN(nFOB    ,cPICT15_2) ,COURIER_07,,,,1)
   oPrn:Say( nLin,nCol09,TRAN(nFrete  ,cPictFre ) ,COURIER_07,,,,1)
   oPrn:Say( nLin,nCol10,TRAN(nSeguro ,cPictSeg ) ,COURIER_07,,,,1)
   nLin +=40
ENDIF

IF lICMSRedIPI
   nTotGeral:=nValMerc+nIPIVal+nICMSVal-nICMSEmb                 //NCF - 14/09/2012 - O Total geral corresponde a Base do IPI (Com Valor do ICMS Incluso - seja ele integral ou reduzido por Carga Tributária Equivalente) + o Valor
ELSE                                                             //                   do próprio IPI Calculado + Valor do ICMS calculado - o valor do ICMS que já está embutido no valor da mercadoria.
   nTotGeral:=nValMerc+nIPIVal //+nICMSVal                       //NCF - 04/07/2018 - O valor do ICMS já está embutido no valor da Mercadoria "nValMerc"                   
ENDIF

oPrn:Say( nLin,nColFim,"Vlr. Mercadoria..........: "+TRAN(nValMerc,cPICT15_2),COURIER_10,,,,1)
nLin+=45

oPrn:Say( nLin,nColFim,"Total I.C.M.S............: "+TRAN(nICMSVal,cPICT15_2),COURIER_10,,,,1)
nLin+=45

oPrn:Say( nLin,nColFim,"Total I.P.I..............: "+TRAN(nIPIVal ,cPICT15_2),COURIER_10,,,,1)
nLin+=45
/*
oPrn:Say( nLin,nColFim,"Total I.I................: "+TRAN(nIIVal  ,cPICT15_2),COURIER_10,,,,1)   // GFP - 11/04/2012
nLin+=45

oPrn:Say( nLin,nColFim,"Total PIS................: "+TRAN(nPISVal ,cPICT15_2),COURIER_10,,,,1)   // GFP - 11/04/2012
nLin+=45

oPrn:Say( nLin,nColFim,"Total COFINS.............: "+TRAN(nCOFVal ,cPICT15_2),COURIER_10,,,,1)   // GFP - 11/04/2012
nLin+=45
*/
oPrn:Say( nLin,nColFim,"Total Geral.: "+TRAN(nTotGeral,cPICT15_2),COURIER_10,,,,1)
nLin+=65

nItem:=nFOB:=nFrete:=nSeguro:=nValMerc:=nICMSVal:=nIPIVal:=0 //nIIVal:=nPISVal:=nCOFVal:=0  // GFP - 11/04/2012

RETURN .T.
/*
Função    : PcoGrvNfDesp()
Parâmetros: Nenhum
Retorno   : Nenhum
Objetivo  : Gravacao do numero da nota fiscal de transferência de posse nas despesas do desembaraco,
            para que seja possível gerar no fiscal complementar de transferência de posse.
Autor     : Julio de Paula Paz
Data/Hora : 24/07/2009 - 16:00
Observação:
* /
Static Function PcoGrvNfDesp()

Begin Sequence
IF !lAdquirente
   RETURN .F.
ENDIF

   ProcRegua(WorkDespesa->(LastRec()))
   WorkDespesa->(DbGotop())
   Do While WorkDespesa->(!Eof())
      SWD->(DbSeek(xFilial("SWD")+SW6->W6_HAWB))
      DO WHILE SWD->(!EOF()) .AND. EVAL(bDDIWhi)
         IF !SYB->(DbSeek(xFilial("SYB")+SWD->WD_DESPESA )) .OR.; //SVG - 08-12-08
            !EVAL(bDDIFor) .OR. SYB->YB_BASECUS $ cNao .AND. (EasyGParam("MV_EICNFTO",,"1") <> "2" .OR. SYB->YB_BASEIMP $ cNao)
            SWD->(DBSKIP())
            LOOP
         ENDIF
         lBaseICMS:=SYB->YB_BASEICM
         IF SYB->YB_BASEICM $ cSim
            IF lTemYB_ICM_UF
               lBaseICMS:= SYB->(FIELDGET(FIELDPOS(cCpoBasICMS)))
            ENDIF
         ENDIF
         IF nTipoNF = NFE_PRIMEIRA .AND. !(SYB->YB_BASEIMP $ cSim) .AND. !(lBaseICMS $ cSim)
            SWD->(DBSKIP())
            LOOP
         ENDIF
         SWD->(RecLock("SWD",.F.))
         SWD->WD_NF_COMP:=Work1->WK_NFE
         SWD->WD_SE_NFC :=Work1->WK_SE_NFE
         SWD->WD_DT_NFC :=Work1->WK_DT_NFE
         SWD->WD_VL_NFC :=nVlTotNFs
         SWD->(MsUnlock())
         SWD->(DBSKIP())
      ENDDO
End Sequence

Return .F.
*/
/*========================================================================
TRATAMENTO DA ARRAY aLocExecAuto NO EICDI154.PRW

IF aLocExecAuto == NIL
   lExecAuto:=.F.
   lDespAuto:=.F.
ELSE
   IF VALTYPE(aLocExecAuto) == "L"
      lExecAuto:=aLocExecAuto
   ELSE
      lExecAuto:= aLocExecAuto[1]//Define que uma chamada de outro programa
      If (lDespAuto:=aLocExecAuto[2])==.T.  // indica que os calculos de despesa devem ser baseados na tabela passada como parâmetro
         aDespExecAuto:=aLocExecAuto[3]
      Endif
      IF Len(aLocExecAuto) > 3
         lCalcImpAuto := aLocExecAuto[4]  // Define se calcula os impostos ou nao
      ENDIF
   ENDIF
      IF Len(aLocExecAuto) > 4
         lSoGravaNF := aLocExecAuto[5]  // Define se somente Grava a NF ou nao
      ENDIF
ENDIF
DEL EIW*.*
DEL EIY*.*
DEL EIZ*.*
*/

*==========================================================*
FUNCTION PCONFTFilha(lNfGerou,lMontaTela,nWNQTD)
*==========================================================*
LOCAL cChaveNF := ""
LOCAL cChaveIT := ""
LOCAL cVal     := NIL
LOCAL nQtdOri  := nQtdAlt := 0
LOCAL nOpc     := 0
LOCAL aOrd     := SaveOrd("EIW") //NCF - 22/08/2019

DEFAULT lNfGerou  := .F.
DEFAULT lMontaTela:= .F.
DEFAULT nWNQTD    := 0

PCOInitVar()
cChaveNF := cFilSWN+SW6->W6_HAWB+"9"

SF1->(DbSetOrder(5))
SD1->(DbSetOrder(8))
SWN->(DbSetOrder(3))
EIW->(DbSetOrder(1))

IF !lMontaTela
   cChaveIT := SW6->W6_HAWB+WorkItens->WN_PO_EIC+WorkItens->WN_ITEM+WorkItens->WN_PGI_NUM
ENDIF

IF SF1->(DBSEEK(cChaveNF))
	IF lNfGerou
		IF SWN->(DBSEEK(cChaveNF))
			DO WHILE SWN->(!Eof()) .AND. SWN->WN_HAWB == SW6->W6_HAWB
				IF !SWN->(IsLocked())
					IF SWN->( RecLock("SWN", .F.) )
						SWN->WN_PRUNI := (SWN->WN_VALOR / SWN->WN_QUANT)
						SWN->( MSUnlock() )
					ENDIF
				ELSE
					SWN->WN_PRUNI := (SWN->WN_VALOR / SWN->WN_QUANT)
				ENDIF
				SWN->(DBSKIP())
			ENDDO
		ENDIF
		IF SD1->(DBSEEK(cChaveNF))
			DO WHILE SD1->(!Eof()) .AND. SD1->D1_CONHEC == SW6->W6_HAWB
				IF !SD1->(IsLocked())
					IF SD1->( RecLock("SD1", .F.) )
						SD1->D1_VUNIT := (SD1->D1_TOTAL / SD1->D1_QUANT)
						SD1->( MSUnlock() )
					ENDIF
				ELSE
					SD1->D1_VUNIT := (SD1->D1_TOTAL / SD1->D1_QUANT)
				ENDIF
				SD1->(DBSKIP())
			ENDDO
		ENDIF
	ENDIF
	IF lMontaTela
		nOpc := PCONFTTela(SW6->W6_HAWB)
		DO CASE
			CASE nOpc == 0
				 cVal := "SAIR"
			CASE nOpc == 1
				 cVal := "INCLUIR"
			CASE nOpc == 2
				 cVal := "ESTORNO"
		ENDCASE
	ENDIF
ENDIF

//===CALCULA OS VALORES DAS BASE FAZENDO A FATORAÇÃO PROPRORCIONAL PELA NOVA QTDE.
IF EIW->(DBSEEK(cFilEIW+cChaveIT)) .And. !lNfGerou .And. !lMontaTela
	IF !lSoLeNFT
		nQtdAlt := IF (nWNQTD > 0, nWNQTD, WorkItens->WN_QUANT)
		nQtdOri := EIW->EIW_QTDE
		WorkItens->WN_FOB_R   := ( (EIW->EIW_FOB_R /nQtdOri)* nQtdAlt )
		WorkItens->WN_FRETE   := ( (EIW->EIW_FRETE /nQtdOri)* nQtdAlt )
		WorkItens->WN_SEGURO  := ( (EIW->EIW_SEGURO/nQtdOri)* nQtdAlt )
		WorkItens->WKVALOR    := ( (EIW->EIW_VALOR /nQtdOri)* nQtdAlt )
		WorkItens->WKBASEICMS := ( (EIW->EIW_BASEIC/nQtdOri)* nQtdAlt )
		WorkItens->WKIPIBASE  := ( (EIW->EIW_IPIBAS/nQtdOri)* nQtdAlt )
	ENDIF
ENDIF

RestOrd(aOrd,.T.) //NCF - 22/08/2019

RETURN cVal

*==============================================*
STATIC FUNCTION PCONFTTela(cProcesso)
*==============================================*
LOCAL oDLG, nOpca := 0, nQtdNF := 0
LOCAL lGerou := .F., i
LOCAL lSaldo := .T.
LOCAL lInclui:= .F.
LOCAL TB_Campos  :={}

aItemEIW :={}
aItemSWN :={}
aItemStn :={}

PCOInitVar()

AADD(TB_CAMPOS,{{||WorkSF1->F1_DOC+" "+Transform(WorkSF1->F1_SERIE,AvSx3("F1_SERIE",AV_PICTURE))},,"Nro Nota Fiscal"}) //"N§ Nota Fiscal"
AADD(TB_CAMPOS,{"F1_FORNECE" ,,"Fornecedor"}) 								      //"Fornecedor"
AADD(TB_CAMPOS,{"F1_EMISSAO" ,,"Data NF"})									      //"Data NF"

aCpsSF1:={ {"F1_DOC"    ,AVSX3("F1_DOC"    ,AV_TIPO),AVSX3("F1_DOC"    ,AV_TAMANHO),AVSX3("F1_DOC"    ,AV_DECIMAL)},;
		   {"F1_SERIE"  ,AVSX3("F1_SERIE"  ,AV_TIPO),AVSX3("F1_SERIE"  ,AV_TAMANHO),AVSX3("F1_SERIE"  ,AV_DECIMAL)},;
		   {"F1_FORNECE",AVSX3("F1_FORNECE",AV_TIPO),AVSX3("F1_FORNECE",AV_TAMANHO),AVSX3("F1_FORNECE",AV_DECIMAL)},;
		   {"F1_EMISSAO",AVSX3("F1_EMISSAO",AV_TIPO),AVSX3("F1_EMISSAO",AV_TAMANHO),AVSX3("F1_EMISSAO",AV_DECIMAL)},;
		   {"TRB_ALI_WT"                   ,"C"                        ,03                            ,0          },;
		   {"TRB_REC_WT"                   ,"N"                        ,10                            ,0          }}
cFileSF1 := E_CriaTrab(,aCpsSF1,"WorkSF1")

DO WHILE SF1->(!Eof()) .And. SF1->F1_HAWB == cProcesso
	WorkSF1->(DBAPPEND())
	WorkSF1->F1_DOC     := SF1->F1_DOC
	WorkSF1->F1_SERIE   := SF1->F1_SERIE
	WorkSF1->F1_FORNECE := SF1->F1_FORNECE
	WorkSF1->F1_EMISSAO := SF1->F1_EMISSAO
	WorkSF1->TRB_ALI_WT := "SF1"
	WorkSF1->TRB_REC_WT := SF1->(RECNO())
	nQtdNF++
	SF1->(DBSKIP())
ENDDO

//===PESQUISA QTD DE NF GERADAS PARA O PROCESSO DA NFT FILHA =====================
EIW->(DBSEEK(cFilEIW+SW6->W6_HAWB))
DO WHILE EIW->(!Eof()) .And. EIW->EIW_HAWB == SW6->W6_HAWB
   AADD(aItemEIW,{EIW->EIW_COD_I, EIW->EIW_QTDE, EIW->EIW_LOTECT})
   EIW->(DBSKIP())
ENDDO

//===GRAVA QTD DE ITENS UTILIZADOS NAS NFT's FILHA ===============================
aItemSWN:=ACLONE(aItemEIW)
FOR i:=1 TO LEN(aItemSWN)
	aItemSWN[i][2] := 0
	SWN->(DBSEEK(cFilSWN+SW6->W6_HAWB+"9"))
	DO WHILE SWN->(!Eof()) .And. SWN->WN_HAWB == SW6->W6_HAWB
	   IF SWN->WN_PRODUTO == AvKey(aItemSWN[i][1],"WN_PRODUTO") .AND. SWN->WN_LOTECTL == AvKey(aItemSWN[i][3],"WN_LOTECT")  // GFP - 30/10/2014
	   	  aItemSWN[i][2]  := aItemSWN[i][2] + SWN->WN_QUANT
	      SWN->(DBSKIP())
	   ELSE
	   	  SWN->(DBSKIP())
	   ENDIF
	ENDDO
NEXT

//===ATUALIZA O SALDO NO ARRAY PRINCIPAL E VALIDA PARA VER SE A ITENS COM SALDO ==
FOR i:=1 TO LEN(aItemEIW)
	IF aItemEIW[i][1] == aItemSWN[i][1] .AND. aItemSWN[i][3] == aItemSWN[i][3]
	   aItemEIW[i][2] -= aItemSWN[i][2]
	ENDIF
NEXT
FOR i:=1 TO LEN(aItemEIW)
	IF aItemEIW[i][2] > 0
	   lInclui := .T.
	ENDIF
NEXT

// ***
WorkSF1->(DBGOTO(1))
      DEFINE MSDIALOG oDlg TITLE "N.F.'s Transferências Geradas" FROM 5,5 TO 22,55 Of oMainWnd //"Nota Fiscal"
      @ 00,00 MsPanel oPanel Prompt "" Size 60,20 of oDlg
      IF lInclui
         @4.2,24 BUTTON "Incluir"   SIZE 38,12 ACTION (nOpca:=1,oDlg:End()) OF oPanel Pixel //"&Inclui"
      ENDIF
         @4.2,140 BUTTON "Estornar" SIZE 38,12 ACTION (nOpca:=2,oDlg:End()) OF oPanel Pixel //"&Estorna"

      oMarkNF:=MsSelect():New("WorkSF1",,,TB_Campos,.F.,@cMarca,{33,5,(oDlg:nClientHeight-6)/2,(oDlg:nClientWidth-4)/2})
      oPanel:Align:=CONTROL_ALIGN_TOP
      oMarkNF:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT
      ACTIVATE MSDIALOG oDlg ON INIT ;
            (EnchoiceBar(oDlg,{||IF(lInclui, nOpca:=1, nOpca:=2),oDlg:End()},;
                              {||nOpca:=0,oDlg:End()}),oMarkNF:oBrowse:Refresh()) CENTERED
IF nOpca == 2 //Estorno
   AADD(aItemStn,{WorkSF1->F1_DOC,;
				  WorkSF1->F1_SERIE,;
				  WorkSF1->F1_FORNECE,;
				  WorkSF1->F1_EMISSAO,;
				  WorkSF1->TRB_ALI_WT,;
				  WorkSF1->TRB_REC_WT,;
				  nQtdNF})
ENDIF
WorkSF1->((E_EraseArq(cFileSF1)))

RETURN nOpca

*==============================================*
FUNCTION PCOValid(cValid)
*==============================================*
LOCAL i
LOCAL nSaldo := 0
LOCAL lRet   := .T.

PCOInitVar()

DO CASE
   CASE cValid == "EIW_QTDE"
		IF NaoVazio(M->WN_QUANT) .AND. Positivo(M->WN_QUANT)

		   IF LEN(aItemEIW)== 0
		      EIW->(DBSEEK(cFilEIW+SW6->W6_HAWB))
		      DO WHILE EIW->(!Eof()) .And. EIW->EIW_HAWB == SW6->W6_HAWB
		         AADD(aItemEIW,{EIW->EIW_COD_I, EIW->EIW_QTDE, EIW->EIW_LOTECT})
		         EIW->(DBSKIP())
		      ENDDO
		   ENDIF

		   FOR i:=1 TO LEN(aItemEIW)
		       IF WorkItens->WN_PRODUTO == aItemEIW[i][1]  .AND. WorkItens->WV_LOTE == aItemEIW[i][3]
				   nSaldo := aItemEIW[i][2]
				ENDIF
		   NEXT

		   IF M->WN_QUANT > nSaldo
		      lRet := .F.
		      M->WN_QUANT := WorkItens->WN_QUANT
		      MSGINFO("Quantidade maior que a disponivel")
		   ELSE
		   	  PCOCalcImposto(M->WN_QUANT)
		   	  MsgInfo("Produto "+ TRIM(cValToChar(WorkItens->WN_PRODUTO))+" recalculado.")
		   ENDIF
		ENDIF

   CASE cValid == "NFT"
        aOrdSF1 := SaveOrd({"SF1"})
        IF SF1->(DBSEEK(cFilSF1+SW6->W6_HAWB+"9"+cNota+cSerie))
           lRet := .F.
        ENDIF
        RestOrd(aOrdSF1)
ENDCASE

RETURN lRet

*==============================================*
FUNCTION PCOGrvHeader()
*==============================================*
LOCAL aHdrItem:={}

IF nTela # ESTORNO .AND. lCalcNFT
   AADD(aHdrItem  ,{""         ,"WK_FLAG"  ,"@BMP"               ,4                    ,0                   ,""          ,""      ,""     ,""        ,""} )
ENDIF
AADD(aHdrItem  ,{"Codigo do Produto"   ,"WN_PRODUTO","@!"                 ,AVSX3("B1_COD"    ,3),0                     ,""          ,""      ,"C"    ,""        ,""} )
AADD(aHdrItem  ,{"Descricao do Produto","B1_DESC"   ,"@!"                 ,AVSX3("B1_DESC"   ,3),0                     ,""          ,""      ,"C"    ,""        ,""} )
AADD(aHdrItem  ,{AVSX3("EIW_QTDE"  ,5) ,"WN_QUANT"  ,AVSX3("EIW_QTDE"  ,6),AVSX3("EIW_QTDE"  , 3),AVSX3("EIW_QTDE"  ,4),"PCOValid('EIW_QTDE')",""      ,"N"    ,""        ,""} )
AADD(aHdrItem  ,{AVSX3("EIW_FOB_R" ,5) ,"WN_FOB_R"  ,AVSX3("EIW_FOB_R" ,6),AVSX3("EIW_FOB_R" , 3),AVSX3("EIW_FOB_R" ,4),""          ,""      ,"N"    ,""        ,""} )
AADD(aHdrItem  ,{AVSX3("EIW_FRETE" ,5) ,"WN_FRETE"  ,AVSX3("EIW_FRETE" ,6),AVSX3("EIW_FRETE" , 3),AVSX3("EIW_FRETE" ,4),""          ,""      ,"N"    ,""        ,""} )
AADD(aHdrItem  ,{AVSX3("EIW_SEGURO",5) ,"WN_SEGURO" ,AVSX3("EIW_SEGURO",6),AVSX3("EIW_SEGURO", 3),AVSX3("EIW_SEGURO",4),""          ,""      ,"N"    ,""        ,""} )
AADD(aHdrItem  ,{AVSX3("EIW_VALOR" ,5) ,"WKVALOR"   ,AVSX3("EIW_VALOR" ,6),AVSX3("EIW_VALOR" , 3),AVSX3("EIW_VALOR" ,4),""          ,""      ,"N"    ,""        ,""} )
IF EasyGParam("MV_EIC0027",,.F.)  // GFP - 27/03/2013
   If EIW->(FieldPos("EIW_PERPIS")) # 0   // GFP - 03/12/2015
	   AADD(aHdrItem  ,{AVSX3("EIW_PERPIS" ,5) ,"WKPERPIS"  ,AVSX3("EIW_PERPIS",6),AVSX3("EIW_PERPIS", 3),AVSX3("EIW_PERPIS",4),""          ,""      ,"N"    ,""        ,""} )
	EndIf
   AADD(aHdrItem  ,{AVSX3("WN_VLRPIS" ,5) ,"WKPISVAL"  ,AVSX3("EIW_VLRPIS",6),AVSX3("EIW_VLRPIS", 3),AVSX3("EIW_VLRPIS",4),""          ,""      ,"N"    ,""        ,""} )
   If EIW->(FieldPos("EIW_PERCOF")) # 0   // GFP - 03/12/2015
	   AADD(aHdrItem  ,{AVSX3("EIW_PERCOF" ,5) ,"WKPERCOF"  ,AVSX3("EIW_PERCOF",6),AVSX3("EIW_PERCOF", 3),AVSX3("EIW_PERCOF",4),""          ,""      ,"N"    ,""        ,""} )
	EndIf
   AADD(aHdrItem  ,{AVSX3("WN_VLRCOF" ,5) ,"WKCOFVAL"  ,AVSX3("EIW_VLRCOF",6),AVSX3("EIW_VLRCOF", 3),AVSX3("EIW_VLRCOF",4),""          ,""      ,"N"    ,""        ,""} )
ENDIF
IF lCalcNFT
   AADD(aHdrItem  ,{AVSX3("EIW_OPERAC",5) ,"WKOPERACAO",AVSX3("EIW_OPERAC",6),AVSX3("EIW_OPERAC", 3),0                    ,""          ,""      ,"C"    ,""        ,""} )
//MFR 05/07/2017  MTRADE-1200 WCC-524950 segundo orientação do Alessandro sempre exibir o campo mesmo que na for utilzar
// If EasyGParam("MV_EIC0058",,.F.)  // GFP - 21/05/2015
      AADD(aHdrItem  ,{"Desp Base ICMS"      ,"WKDESPBICM",AVSX3("EIW_BASEIC",6),AVSX3("EIW_BASEIC", 3),AVSX3("EIW_BASEIC",4),""          ,""      ,"N"    ,""        ,""} )
      If lCposDspBs
         AADD(aHdrItem  ,{"Desp Base IPI"      ,"WKDESPBIPI",AVSX3("EIW_DBSIPI",6),AVSX3("EIW_DBSIPI", 3),AVSX3("EIW_DBSIPI",4),""          ,""      ,"N"    ,""        ,""} )
      EndIf
// EndIf
   AADD(aHdrItem  ,{AVSX3("EIW_BASEIC",5) ,"WKBASEICMS",AVSX3("EIW_BASEIC",6),AVSX3("EIW_BASEIC", 3),AVSX3("EIW_BASEIC",4),""          ,""      ,"N"    ,""        ,""} )
   AADD(aHdrItem  ,{AVSX3("EIW_ICMS_A",5) ,"WKICMS_A"  ,AVSX3("EIW_ICMS_A",6),AVSX3("EIW_ICMS_A", 3),AVSX3("EIW_ICMS_A",4),""          ,""      ,"N"    ,""        ,""} )
   AADD(aHdrItem  ,{AVSX3("EIW_VL_ICM",5) ,"WKVL_ICM"  ,AVSX3("EIW_VL_ICM",6),AVSX3("EIW_VL_ICM", 3),AVSX3("EIW_VL_ICM",4),""          ,""      ,"N"    ,""        ,""} )
   AADD(aHdrItem  ,{AVSX3("EIW_IPIBAS",5) ,"WKIPIBASE" ,AVSX3("EIW_IPIBAS",6),AVSX3("EIW_IPIBAS", 3),AVSX3("EIW_IPIBAS",4),""          ,""      ,"N"    ,""        ,""} )
   AADD(aHdrItem  ,{AVSX3("EIW_IPITX" ,5) ,"WKIPITX"   ,AVSX3("EIW_IPITX" ,6),AVSX3("EIW_IPITX" , 3),AVSX3("EIW_IPITX" ,4),""          ,""      ,"N"    ,""        ,""} )
   AADD(aHdrItem  ,{AVSX3("EIW_IPIVAL",5) ,"WKIPIVAL"  ,AVSX3("EIW_IPIVAL",6),AVSX3("EIW_IPIVAL", 3),AVSX3("EIW_IPIVAL",4),""          ,""      ,"N"    ,""        ,""} )
   //THTS - 09/01/2018 - Nota fiscal de transferência com despesas base de impostos que não compoe total da nota
   If AvFlags("NFT_DESP_BASE_IMP")
      aAdd(aHdrItem, {AVSX3("EIW_DESPCU",5),"EIW_DESPCU",AVSX3("EIW_DESPCU",6),AVSX3("EIW_DESPCU", 3),AVSX3("EIW_DESPCU",4),""          ,""      ,"N"    ,""        ,""})
      aAdd(aHdrItem, {AVSX3("EIW_VALTOT" ,5),"EIW_VALTOT" ,AVSX3("EIW_VALTOT" ,6),AVSX3("EIW_VALTOT" , 3),AVSX3("EIW_VALTOT" ,4),""          ,""      ,"N"    ,""        ,""})
   EndIf
   AADD(aHdrItem  ,{AVSX3("EIW_NOTA"  ,5) ,"WN_DOC"    ,AVSX3("EIW_NOTA"  ,6),AVSX3("EIW_NOTA"  , 3),0                    ,""          ,""      ,"C"    ,""        ,""} )
   AADD(aHdrItem  ,{AVSX3("EIW_SERIE" ,5) ,"WN_SERIE"  ,AVSX3("EIW_SERIE" ,6),AVSX3("EIW_SERIE" , 3),0                    ,""          ,""      ,"C"    ,""        ,""} )
ENDIF
AADD(aHdrItem  ,{"PO+Posicao+PGI+Lote+Invoice","WK_CHAVE","@!"                 ,50                    ,0                    ,""          ,""      ,"C"    ,""        ,""} )

RETURN aHdrItem

*==============================================*
FUNCTION PCOInitVar()
*==============================================*
//RECARREGA AS VERIAVEIS NOVAMENTE PARA NAO TER ERRO COM A FILIAL DO PROCESSO
cFilSW2:=xFilial("SW2")
cFilSA2:=xFilial("SA2")
cFilSB1:=xFilial("SB1")
cFilSF1:=xFilial("SF1")
cFilSWZ:=xFilial("SWZ")
cFilEIW:=xFilial("EIW")
cFilEIY:=xFilial("EIY")
cFilEIZ:=xFilial("EIZ")
cFilSWD:=xFilial("SWD")
cFilSWN:=xFilial("SWN")
cFilSWW:=xFilial("SWW")
cFilSYB:=xFilial("SYB")
cFilSW9:=xFilial("SW9")
cFilSW7:=xFILIAL("SW7")
cFilSW8:=xFILIAL("SW8")
cFilEIJ:=xFILIAL("EIJ")

RETURN NIL

//MFR 05/07/2017  MTRADE-1200 WCC-524950
*==============================================*
FUNCTION GetCfo58()
*==============================================*
/*
1=Sim
2=nao
3=nao confiugrado
MVEIC_0058=Sistema considera apenas as despesas base de ICMS para o calculo de ICMS na NF Transferencia.
*/

SWZ->(DBSETORDER(2))
SWZ->(DBSEEK(cFilSWZ+WorkItens->WKOPERACAO))
IF !lCpoBseNft .OR. empty(rtrim(WorkItens->WKOPERACAO)) .OR. empty(rtrim(SWZ->WZ_BASENFT)) .OR. SWZ->WZ_BASENFT == '3'
   return "NAO CONFIGURADO"
ElseIF SWZ->WZ_BASENFT == '1'
   return "SIM"
Else
   return "NAO"
EndIf


/*
Funcao      : GetStItNFT()
Parametros  : <Nenhum>
Retorno     : aRet -> {<F1_OK> , <F1_STATUS>, <F1_MENNOTA> , <R_E_C_N_0_> }
Objetivos   : Retornar dados da Nota Fiscal de um item específico da NFT
Autor       : NCF
Data        : Nov/2017
Revisao     :
Obs.        : Função de escopo local
*/
*====================*
Function GetStItNFT()
*====================*
Local aRet     := { AvKey("","F1_OK"), AvKey("","F1_STATUS"), AvKey("","F1_MENNOTA"), 0 }
Local cQuery   := ""
Local cCondFil := ""

   If TcSrvType() <> "AS/400"
      cCondFil := " ON "+RetSqlCond("SF1") + " And " + RetSqlCond("SWN")
   Else
      cCondFil := " ON SF1.F1_FILIAL = '" + SF1->(xFilial()) + "' And  SWN.WN_FILIAL = '" + SWN->(xFilial()) + "'"
   EndIf

   cQuery := "SELECT SF1.F1_DOC, SF1.F1_SERIE, SF1.F1_FORNECE, SF1.F1_LOJA, SF1.F1_TIPO, SF1.F1_OK, SF1.F1_STATUS, SF1.F1_MENNOTA, SF1.R_E_C_N_O_" 
   cQuery += " FROM "      + RetSqlName("SF1") +" SF1"   
   cQuery += " INNER JOIN "+ RetSqlName("SWN") +" SWN"
   cQuery += cCondFil 
   cQuery += " AND SF1.F1_DOC     =  SWN.WN_DOC"
   cQuery += " AND SF1.F1_SERIE   =  SWN.WN_SERIE"
   cQuery += " AND SF1.F1_FORNECE =  SWN.WN_FORNECE"
   cQuery += " AND SF1.F1_LOJA    =  SWN.WN_LOJA"
   cQuery += " AND SF1.F1_HAWB    =  SWN.WN_HAWB"
   cQuery += " AND SF1.D_E_L_E_T_ = ' '"
   cQuery += " AND SWN.WN_TIPO_NF = '9'"
   cQuery += " AND SWN.WN_HAWB    = '"+ EIW->EIW_HAWB   +"'"
   cQuery += " AND SWN.WN_PO_EIC  = '"+ EIW->EIW_PO_NUM +"'"
   cQuery += " AND SWN.WN_ITEM    = '"+ EIW->EIW_POSICA +"'"
   cQuery += " AND SWN.WN_PGI_NUM = '"+ EIW->EIW_PGI_NU +"'"
   cQuery += " AND SWN.WN_LOTECTL = '"+ EIW->EIW_LOTECT +"'"
   cQuery += " AND SWN.WN_INVOICE = '"+ EIW->EIW_INVOIC +"'"
   cQuery += " AND SWN.D_E_L_E_T_ = ' '"

   If Select("SF1INFO") > 0
      SF1INFO->(DBCloseArea())
   EndIf
   
   cQuery:= ChangeQuery(cQuery)
   TcQuery cQuery Alias "SF1INFO" New

   If !SF1INFO->(Bof()) .Or. !SF1INFO->(Eof())
      aREt := { SF1INFO->F1_OK, SF1INFO->F1_STATUS, SF1INFO->F1_MENNOTA, SF1INFO->R_E_C_N_O_  }
   EndIf
   
   SF1INFO->(DBCloseArea())

Return aRet 


/*
Funcao      : FretSegNFT()
Parametros  : <Nenhum>
Retorno     : nRet - Valor somado do Frete e Seguro caso o campo YB_TOTNFT seja diferente de 2 e as despesas estejam marcadas
Autor       : THTS - Tiago Henrique Tudisco dos Santos
Data        : 10/01/2018
Revisao     :
*/
Static Function FretSegNFT()
Local nRet        := 0
Local aAreaSYB

If AvFlags("NFT_DESP_BASE_IMP")
      aAreaSYB := SYB->(getArea())
      SYB->(dbSetOrder(1)) //YB_FILIAL + YB_DESP
      //Frete
      If SYB->(dbSeek(xFilial("SYB") + "102")) .And. SYB->YB_TOTNFT != "2"
            nRet := WorkItens->WN_FRETE
      EndIf
      //Seguro
      If SYB->(dbSeek(xFilial("SYB") + "103")) .And. SYB->YB_TOTNFT != "2"
            nRet += WorkItens->WN_SEGURO
      EndIf
      RestArea(aAreaSYB)
EndIf

Return nRet


/*
Funcao      : InitDesCus()
Parametros  : <Nenhum>
Retorno     : <Nenhum>
Objetivos   : Inicializa o valor do campo EIW_DESPCU quando tiver despesa selecionada e seu conteudo for zero.
Autor       : THTS - Tiago Henrique Tudisco dos Santos
Data        : 10/01/2018
Revisao     : 
*/
Static Function InitDesCus()
Local nRecMarca   := WorkMarca->(Recno())
Local aMarcados   := {}
Local nI

WorkMarca->(dbGoTop())
While WorkMarca->(!Eof())

      If !EmpTy(WorkMarca->WK_FLAG) //Despesa esta marcada
            aAdd(aMarcados,WorkMarca->(Recno()))
            PCOMarca(.F.,.T.,.F.)
      EndIf
      WorkMarca->(dbSkip())

End

For nI := 1 To Len(aMarcados)
      WorkMarca->(dbGoTo(aMarcados[nI]))
      PCOMarca(.F.,.T.,.F.)
Next

WorkMarca->(dbGoTo(nRecMarca))

Return

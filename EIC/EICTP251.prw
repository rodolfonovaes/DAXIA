#INCLUDE "Eictp251.ch" 
//#include "FiveWin.ch"
#include "Average.ch"
#INCLUDE "AvPrint.ch"
#INCLUDE "TOPCONN.CH"

#COMMAND E_RESET_AREA => SW3->(DBSETORDER(1)) ; SW5->(DBSETORDER(1))   ;
                       ; SW7->(DBSETORDER(1)) ;
                       ; If(Select("WORK_1")>0,Work_1->(E_EraseArq(FileWork,FileWork1)),);
                       ; If(Select("WORK_2")>0,Work_2->(E_EraseArq(FileWork_2)),)

#define  DESPESA_FOB        "101" 
#define  DESPESA_FRETE      "102"
#define  DESPESA_SEGURO     "103"
#define  DESPESA_II         "201"
#define  DESPESA_IPI        "202"
#define  DESPESA_ICMS       "203"
#define  VALOR_CIF          "104"
#define  DESPESA_CIF        "199"
#define  DESP_GERAL_SEM_IMP "T90"  //SEM IPI  SEM ICMS SEM PIS SEM COFINS
#define  DESP_GERAL_IPI     "T96"  //COM IPI  SEM ICMS
#define  DESP_GERAL_ICMS    "T97"  //SEM IPI  COM ICMS
#define  DESP_GERAL_SEM     "T98"  //SEM IPI  SEM ICMS
#define  DESPESA_GERAL      "TR9"  //COM IPI  COM ICMS //RRV - 12/11/2012 - Ajustado para imprimir total geral corretamente com a define DESPESA_SUBTOT == R9
#define  DESPESA_SUBTOT     "R9"   //RRV - 17/10/2012 - Ajustado para "R9" para que o usuário possa usar uma despesa com final "99"
#define  DESPESA_ADIANT     "999"
#define  CUSTO_DO_ITEM      "000"      
#define  Titulo IF(MParam== "2",;
                   STR0001,; //"COMPARATIVO PRE-CALCULO X CUSTO REALIZADO"
                   IF(MParam=="1",STR0002,; //"CUSTO REALIZADO"
                                        STR0003)) //"MONTAGEM DO PRE-CALCULO"
 
#XTRANSLATE :APEHAWB    => \[1\]
#XTRANSLATE :APENUM     => \[2\]
#XTRANSLATE :APEDT      => \[3\]
#XTRANSLATE :APEBANCO   => \[4\]
#XTRANSLATE :APEFOBMOE  => \[5\]
#XTRANSLATE :APECEDENTE => \[5\]
#XTRANSLATE :APEDT_VEN  => \[6\]
#XTRANSLATE :APELC_NUM  => \[2\]
#XTRANSLATE :APELC_DT   => \[3\]
#XTRANSLATE :APELC_VEN  => \[4\]
#XTRANSLATE :APELC_BAN  => \[5\]
#XTRANSLATE :APECA_NUM  => \[2\]
#XTRANSLATE :APECA_DT   => \[3\]
#XTRANSLATE :APECA_TX   => \[4\]
#XTRANSLATE :APESE_AP   => \[2\]
#XTRANSLATE :APESE_DT   => \[3\]
#XTRANSLATE :APESE_VEN  => \[4\]
#XTRANSLATE :APESE_AVP  => \[5\]
#XTRANSLATE :APESE_AVPD => \[6\]
#XTRANSLATE :APESE_AVD  => \[7\]
#XTRANSLATE :APESE_AVDD => \[8\]
#XTRANSLATE :APESE_VAL  => \[9\]
#XTRANSLATE :APESE_FRQ  => \[10\]
#XTRANSLATE :GIGI_NUM   => \[1\]
#XTRANSLATE :GIDT       => \[2\]
#XTRANSLATE :GIDT_VEN   => \[3\]

// vide funcao TPCCalculo no PADRAO3E

#XTRANSLATE :DESPESA    => \[3\]

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³EICTP251A  ³ Autor ³ AVERAGE/ROBSON LUIZ   ³ Data ³ 30.06.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Montagem do Pre-Calculo                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC / V407                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
        Last change:  US    9 Nov 98    4:39 pm
*/
Function EICTP25A(aAvfluxo)
IF !(aAvFluxo == NIL)
   cNumPo :=aAvFluxo[1] 
   cTabPre:=aAvFluxo[2] 
   cAVFase:= aAvFluxo[3]
   lAvFluxo:=.T.
ELSE                         
   cNumPo:=''
   cTabPre:='' 
   lAvFluxo:=.F.        
   cAVFase:=''
ENDIF

MParam := "3"  //Pre_Calculo
PRIVATE TB_Funcoes:= {}, TNr_PO  // devido macrosubstituicao no help

RETURN TPC251Main()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³EICTP251B  ³ Autor ³ AVERAGE/ROBSON LUIZ   ³ Data ³ 30.06.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Montagem do Custo Realizado                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC / V407                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICTP25B(aAvfluxo)
MParam := "1"  // Realizado
PRIVATE TB_Funcoes:= {}, TNr_PO  // devido macrosubstituicao no help
IF !(aAvFluxo == NIL)
   cNumPo:=aAvFluxo[1] 
   cTabPre:=aAvFluxo[2] 
   cAVFase  := aAvFluxo[3]
   lAvFluxo:=.T.
ELSE                         
   cNumPo:=''
   cTabPre:='' 
   cAVFase:=''
   lAvFluxo:=.F.
ENDIF

RETURN TPC251Main()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³EICTP251C  ³ Autor ³ AVERAGE/ROBSON LUIZ   ³ Data ³ 04.07.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Montagem do Custo Realizado                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC / V407                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICTP25C(aAvFluxo)
MParam:="2"  // Pre_X_Real
PRIVATE TB_Funcoes:= {}, TNr_PO  // devido macrosubstituicao no help
IF !(aAvFluxo == NIL)
   cNumPo:=aAvFluxo[1] 
   cTabPre:=aAvFluxo[2] 
   cAVFase:= aAvFluxo[3]
   lAvFluxo:=.T.
ELSE                         
   cNumPo:=''
   cTabPre:=''  
   cAVFase:='' 
   lAvFluxo:=.F.
ENDIF

RETURN TPC251Main()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³TPC251Main ³ Autor ³ AVERAGE/ROBSON        ³ Data ³ 30.06.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Programa principal                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³TPC251()                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC / V407                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*--------------------*
Function TPC251Main()
*--------------------*
PRIVATE nLenFabr := AVSX3("A2_COD",3) //SO.:0026 OS.: 0252/02  FCD
PRIVATE nLenForn := AVSX3("A2_COD",3) //SO.:0026 OS.: 0252/02  FCD 
Private aDespesas := {}   // GFP - 03/04/2013
//PRIVATE lZeraDesPis:= EasyGParam("MV_ZDESPIS",,.F.)  // RS 22/09/05

//#IFNDEF TOP
//    E_OpenFile({},{||TPC251()},aClose)
//#ELSE
    TPC251()
//#ENDIF

RETURN
*----------------*
Function TPC251()
*----------------*


LOCAL _PictItem := ALLTRIM(X3Picture("B1_COD"))

LOCAL TB_Campos := { { "WKFLAGWIN",,""} ,;
                     { {||TRAN(WKCOD_I,_PictItem)+' '+WKDESCR},,STR0004}                  ,; //"Cod. Item"
                     { "WKQTD_INI"                            ,,STR0005,'@E 999,999.999'} ,; //"Qtde. Inic."
                     { "WKQTD_ACU"                            ,,STR0006,AVSX3("W7_QTDE",6)} ,; //"Qtde. Entr."
                     { "WKQTD_SALD"                           ,,STR0007,AVSX3("W3_QTDE",6)      } ,; //"Saldo"
                     { "WKUNID"                               ,,STR0008      }                   ,; //"Unid"
                     { "WKNBM"                                ,,STR0009    ,'@R 9999.99.99 999999'}  ,; //"Nr. NCM"
                     { {||TRAN(WKPESO_L * WKQTD_ACU, AVSX3("W7_QTDE",6) )},,STR0010} }  //"Peso Liq. Entregue"

LOCAL TMensagem1, TMensagem2,  MMsgAPu, nOldArea:=SELECT(), lOk:=.F.
LOCAL lSx6Midia:=SX6->(DBSEEK(SM0->M0_CODFIL+"MV_SOFTWAR")).OR.SX6->(DBSEEK(Space(FWSizeFilial())+"MV_SOFTWAR"))
PRIVATE cMOEDAEST  := BuscaDolar()//ALLTRIM(EasyGParam("MV_SIMB2"))+SPACE(LEN(SW2->W2_MOEDA)-LEN(EasyGParam("MV_SIMB2"))) 

//RRV - 01/10/2012 - Atualiza variável se YF_COD_GI da cMOEDAEST for diferente de "220"
SYF->(DbSetOrder(3))
If SYF->(DbSeek(xFilial("SYF")+"220"))
   IF SYF->YF_MOEDA <> "US$"
      cMOEDAEST := SYF->YF_MOEDA
   EndIf
EndIf

PRIVATE Realizado  :=  "1" //Passou para Private porque no Protheus estorou o numero de Define's
PRIVATE Pre_X_Real :=  "2"
PRIVATE Pre_Calculo:=  "3"
PRIVATE Por_Item   :=  "1"
PRIVATE Por_PO     :=  "2"

PRIVATE cCadastro:=Titulo,MHAWB, cArqF3:="SWF", cCampoF3:="WF_TAB"

PRIVATE cMarca := SX3->(GetMark()), lInverte := .F.

SX3->(DBSETORDER(2))
PRIVATE lExiste_Midia:=EasyGParam("MV_SOFTWAR") $ cSim
PRIVATE nTotBaseMid    := 0, nTaxaMid := 0
PRIVATE lExiste_Garrafa:= IPIPauta()
PRIVATE _PictPrUn := ALLTRIM(X3Picture("W3_PRECO")), _PictPO := ALLTRIM(X3Picture("W2_PO_NUM"))
PRIVATE lWB_TP_CON := SWB->(FieldPos("WB_TP_CON")) > 0 .and. SWB->(FieldPos("WB_TIPOCOM")) > 0 //GFC - 02/12/05
PRIVATE cPicCond := AVSX3("Y6_COD",6) // DRL 08/05/09 - Recebe a Picture da condicao de pagamento

PRIVATE lRegTriPO := SW3->(FieldPos("W3_GRUPORT")) # 0 .AND. SIX->(dbSeek("EIJ2"))  // GFP 11/02/2011 :: 15:52

PRIVATE nCasasDec := EasyGParam("MV_EIC0065",,2) //LGS-25/07/2016-Controla as casas decimais do relatório
PRIVATE cPicture  := AvCalcPict(AVSX3("WH_VALOR",3),nCasasDec) //"@E 99,999,999.999999" //LGS-25/07/2016
FileWork:=FileWork1:=FileWork_2:=IndWork2:=''//Sao PRIVATE por causa do EICFI400

If nCasasDec > AVSX3("WH_VALOR",4) //LGS-25/07/2016
   Help("", 1, "EIC01006")
   Return .F.
EndIf

TP251CriaWork()

SX3->(DBSETORDER(1))

DO WHILE .T.

   TNr_PO := SPACE(LEN(SW7->W7_PO_NUM))
   MHAWB:=" "
   TMensagem1 := TMensagem2 := SPACE(33)

   If !lAvFluxo
      IF ! Pergunte("EI251A",.T.)
         E_RESET_AREA
         RETURN .T.
      ENDIF
      If Empty(mv_par01)
         MsgInfo(STR0189)
         Loop
      EndIf
      TNr_PO:=mv_par01
   Else
      TNr_PO:=cNumPo   
   Endif   

   Private dDataConTx := dDataBase // RA - 13/08/2003 - O.S. 746/03 e 748/03
   Private nTMExtDConTx := BuscaTaxa(cMOEDAEST,dDataConTx,.T.,.F.,.T.) //RMD - 21/03/2019 - Representa a taxa da moeda (cMoedaEst) na data dDataConTx. Deve ser atualizada sempre que mudar a variável dDataConTx.

   If(EasyEntryPoint("EICTP251"),ExecBlock("EICTP251",.F.,.F.,"DATA_CONV_TAXA"),) // RA - 13/08/2003 - O.S. 746/03 e 748/03

   IF EMPTY( SW2->W2_STAT_PC )

      TMensagem1:=IF(MParam==Pre_Calculo,STR0011,; //"   NAO EXISTE PRE-CALCULO.       "
                                         STR0012) //"   PRE-CALCULO SERA EFETIVADO    "
      TMensagem2:=SPACE(33)

   ELSEIF SW2->W2_STAT_PC = "2"

      IF MParam==Pre_Calculo
         TMensagem1 := STR0013 //"ATENCAO: P.O. DIFERE DO PRE-CALC."
         TMensagem2 := STR0014 //"    PRE-CALCULO - RECALCULADO    "
      ELSE
         TMensagem1 := STR0015 //"ATENCAO: PRE-CALCULO EFETIVADO.  "
         TMensagem2 := STR0016 //"AS INFORMACOES DIVERGEM DO P.O.  "
      ENDIF

   ENDIF

   IF MParam == Realizado

      IF TPC251SelHAWB() == 0
         LOOP
      ENDIF

   ENDIF

   IF MParam == Pre_Calculo
      If lAvFLuxo      
         Tpr_Cal:=cTabPre
         TPC251VerCon()
         //E_RESET_AREA  JMS 23/06/04 OS ARQUIVOS SERAO APAGADOS NO EICDI500.PRW
         RETURN .T. 
      ELSE   
      TPC251Calc(TMensagem1,TMensagem2)
      ENDIF   
      LOOP
   ENDIF

   Work_1->(avzap())
   DBSELECTAREA("SW3")
   DBSETORDER(1)
   DBSEEK(xFilial("SW3")+SW2->W2_PO_NUM)
   MNr_Controle:= 0

   lProcessa:=.T.
   ncont:=SW3->(LASTREC())
   If ( Type("lPOAuto") == "U" .OR. !lPOAuto )
      Processa({||SW3->(DBEVAL({||TPC251QtIt_Decla(MHAWB,lProcessa),lProcessa:=.F.},{||SW3->W3_SEQ=0},;
                            {||SW3->W3_PO_NUM==SW2->W2_PO_NUM .AND. SW3->W3_FILIAL == xFilial("SW3") })),;
                               TP251FimProc()},STR0017 ) //"Pesquisando processos"
   Else
      SW3->(DBEVAL({||TPC251QtIt_Decla(MHAWB,lProcessa),lProcessa:=.F.},{||SW3->W3_SEQ=0},;
                            {||SW3->W3_PO_NUM==SW2->W2_PO_NUM .AND. SW3->W3_FILIAL == xFilial("SW3") }))
   EndIf
   DBSELECTAREA("Work_1")
   Work_1->(DBGOTOP() )
   Work_1->(DBSETORDER(1))
   IF Work_1->(BOF()) .AND. Work_1->(EOF())
      Help("", 1, "AVG0000555")//MsgInfo(STR0018,STR0019) //"Não Existe Embarque/Desembaraço deste Pedido para ser processado"###"Informação"
      LOOP
   ENDIF

   DO WHILE .T.
      lOk  :=.F.
      nOpca:=0
      DBGOTOP()
      oMainWnd:ReadClientCoors()
      DEFINE MSDIALOG oDlgHawb TITLE cCadastro ;
             FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
      	       OF oMainWnd PIXEL                          

         IF !(MParam == Pre_X_Real .AND. EMPTY(SW2->W2_TAB_PC))
            lOk:=.T.
            DEFINE SBUTTON FROM 18,(oDlgHawb:nClientWidth-4)/2-30 TYPE 6 ACTION (nOpca:=1,oDlgHawb:End()) ENABLE OF oDlgHawb
         ENDIF

         @ 18,006 SAY STR0020         SIZE 35,8 PIXEL //"No. P.O."
         @ 18,112 SAY STR0021         SIZE 35,8 PIXEL //"Data"
         @ 18,128 MSGET SW2->W2_PO_DT SIZE 45,8 WHEN .F. PIXEL
         @ 18,040 MSGET TNr_PO        SIZE 60,8 WHEN .F. PIXEL

         SA2->(DBSEEK(xFilial("SA2")+SW2->W2_FORN+EICRetLoja("SW2","W2_FORLOJ")))

         TForn:=SW2->W2_FORN+' '+IF(EICLOJA(),SW2->W2_FORLOJ,"")+' '+SA2->A2_NREDUZ
         @ 39,006 SAY STR0022      SIZE 40,8 PIXEL //"Fornecedor"
         @ 39,040 MSGET TForn      SIZE 70,8 WHEN .F. PIXEL

         oMark:= MsSelect():New("Work_1","WKFLAGWIN",,TB_Campos,@lInverte,@cMarca,{57,1,(oDlgHawb:nClientHeight-6)/2,(oDlgHawb:nClientWidth-4)/2})

         oMark:bAval:={||Work_1->WKFLAG:=IF(Work_1->WKFLAG=='A','N','A'),;
                         Work_1->WKFLAGWIN:=IF(Work_1->WKFLAG=='A',cMarca,SPACE(02))}

      ACTIVATE MSDIALOG oDlgHawb ON INIT;
                EnchoiceBar(oDlgHawb,{||nOpca:=2,oDlgHawb:End(),.T.},;
                                     {||nOpca:=0,oDlgHawb:End(),.T.})

      IF lOk .AND. nOpca = 1
         TPC251Print(Por_PO,MHAWB)
         LOOP
      ENDIF

      EXIT

   ENDDO

   IF nOpca = 0
      EXIT
   ENDIF

ENDDO

E_RESET_AREA

RETURN .T.

*----------------------*
FUNCTION TP251FimProc()
*----------------------*
Local i
FOR I:= 1 TO ncont
    IncProc(STR0023) //"Lendo Itens do Pedido"
NEXT i

RETURN .T.

*-----------------------*
FUNCTION TPC251SelHAWB()
*-----------------------*
LOCAL cTituloHawb, nCol, oDlgHawb, oTipo, ocBx
LOCAL TOpcao:=1, MLenHAWB, L1:=3,C1:=0.8,;
      aSaveHAWB:={}, MSelHAWB:=" "

nOpca:=0

DBSELECTAREA("SW7")
DBSETORDER(2)

If !SW2->(DBSEEK(xFilial("SW2")+TNr_PO))
   Help("", 1, "AVG0000557")//MsgInfo(STR0024,STR0019) //"P.O. não cadastrado"###"Informação"
   RETURN nOpca
ENDIF

If !SW7->(DBSEEK(xFilial("SW7")+TNr_PO))
   Help("", 1, "AVG0000558")//MsgInfo(STR0025,STR0019) //"Não existe embarque para este Pedido"###"Informação"
   RETURN nOpca
ENDIF
cOld__Hawb:=""
DBEVAL({|| IF(ASCAN(aSaveHAWB,SW7->W7_HAWB)=0,AADD(aSaveHAWB,SW7->W7_HAWB),) },{||TPC251aDecl()},;
       {|| SW7->W7_PO_NUM = SW2->W2_PO_NUM .AND. W7_FILIAL == xFilial("SW7") })

IF EMPTY(aSaveHawb)
   Help("", 1, "AVG0000560")//MsgInfo(STR0026,STR0019) //"Não existe Embarque/Desembara‡o deste Pedido para ser processado"###"Informação"
	RETURN nOpca
ENDIF

IF ! (MLenHAWB:=LEN(aSaveHAWB)) > 1   // existe apenas um HOUSE p/ este pedido
   MHAWB:=aSaveHawb[1]
   RETURN 1
ENDIF

MSelHawb:=aSaveHawb[1]

DEFINE MSDIALOG oDlgHawb TITLE cCadastro From 9,0 To 20,45 OF oMainWnd

  @ 1.4,0.8 SAY STR0020 //"No. P.O."
  @ 1.4,12  SAY STR0021 //"Data"
  @ 1.4,14  MSGET SW2->W2_PO_DT WHEN .F.  SIZE 40,8
  @ 1.4,4   MSGET TNr_PO        WHEN .F.  SIZE 50,8


  @ 2.5,10 SAY STR0027 //"Nr. Processo"
  @ 3.5,10 COMBOBOX oCbx VAR MSelHawb ITEMS aSaveHawb OF oDlgHawb SIZE 75,120

  oCbx:disable()

  @ 30,6 TO 60,50 LABEL STR0028 OF oDlgHawb PIXEL //"Tipo"

  @ 37,7 RADIO oTipo VAR TOpcao ITEMS STR0029,STR0030 3D SIZE 35,11 ; //"Geral   "###"Embarque"
               ON CHANGE (IF(TOpcao=1,oCbx:disable(),oCbx:enable())) PIXEL

ACTIVATE MSDIALOG oDlgHawb ON INIT EnchoiceBar(oDlgHawb,{||nOpca:=1,oDlgHawb:End()},;
                                                        {||nOpca:=0,oDlgHawb:End()}) CENTERED
MHAWB:=IF(TOpcao=1,"",MSelHawb)

RETURN nOpca

*---------------------*
FUNCTION TPC251aDecl()
*---------------------*
LOCAL nRetorno:=.T.

SW6->(DBSETORDER(1))
SW6->(DBSEEK(xFilial()+SW7->W7_HAWB))

IF(EMPTY(SW6->W6_TX_US_D).OR.SW6->(EOF()),nRetorno:=.F.,)

IF !nRetorno .AND. cOld__Hawb # SW7->W7_HAWB
   Help("", 1, "AVG0000563",,ALLTRIM(SW7->W7_HAWB)+STR0032,1,10)//MsgInfo(STR0031+ALLTRIM(SW7->W7_HAWB)+STR0032,STR0019) //"Processo "###" não possui taxa de conversão"###"Informação"
   cOld__Hawb:=SW7->W7_HAWB
ENDIF


RETURN nRetorno


*--------------------------------------------------------------------------*
FUNCTION TPC251QtIt_Decla(PHAWB,lProcessa)
*--------------------------------------------------------------------------*
// Acumula a quantidade Total daquele PO+Item_Reg no It_Declaracao(ID000)

LOCAL TQtde := 0 ,nPesoTot:=0
PRIVATE nPeso:=0
Private oBufferUM:= tHashMap():New() //bufferização da busca pela unidade de medida

SW7->(DBSETORDER(2))

IF lProcessa
   ProcRegua(SW3->(LASTREC()))
ENDIF

IncProc(STR0023) //"Lendo Itens do Pedido"
nCont--

IF EMPTY(PHAWB)
   SW7->(DBSEEK(xFilial()+SW2->W2_PO_NUM))
ELSE
   IF ! SW7->(DBSEEK(xFilial()+SW2->W2_PO_NUM+PHAWB))
      RETURN TQtde
   ENDIF
ENDIF

MNr_Controle ++

WHILE SW7->(!EOF()) .AND. SW7->W7_PO_NUM = SW2->W2_PO_NUM .AND. SW7->W7_FILIAL == xFilial("SW7")

   cOld__Hawb:=SW7->W7_HAWB
   IF !TPC251aDecl()
      SW7->(DBSKIP())
      LOOP
   ENDIF

   IF SW7->W7_COD_I  = SW3->W3_COD_I  .AND. SW7->W7_REG  = SW3->W3_REG  .AND.;
      SW7->W7_SI_NUM = SW3->W3_SI_NUM .AND. SW7->W7_FABR = SW3->W3_FABR .AND.;
      (!EICLOJA() .OR. SW7->W7_FABLOJ == SW3->W3_FABLOJ) .AND. SW7->W7_CC     = SW3->W3_CC                         
      
      TQtde += SW7->W7_QTDE
      SB1->(DBSEEK(xFilial("SB1")+SW3->W3_COD_I))
      nPeso := W5Peso()
      IF(EasyEntryPoint("EICTP251"),ExecBlock("EICTP251",.F.,.F.,"EM_SW7"),)
      nPesoTot+=nPeso * SW7->W7_QTDE
      TPC251Work_1('N','A') // gera um registro p/ cada desembaraco //DRL - 11/05/09
   ENDIF

   SW7->(DBSKIP())

   IF !EMPTY(PHAWB) .AND. SW7->W7_HAWB # PHAWB
      IF TQtde = 0
         RETURN TQtde
      ENDIF
      EXIT
   ENDIF
ENDDO

IF TQtde == 0                              // nao houve desembaraco p/ o item
   TPC251Work_1('S','A',.F.)               // sera exibido p/ mostrar o saldo //DRL - 11/05/09
   Work_1->WKQTD_SALD:= SW3->W3_QTDE
ELSE
   Work_1->WKQTD_ACU := TQtde             // exibe o ultimo desembaraco
   Work_1->WKQTD_SALD:= SW3->W3_QTDE - TQtde
   Work_1->WKTELA    := 'S'
   Work_1->WKFLAG    := 'A'
   Work_1->WKPESO_L  := nPesoTot/TQtde
   Work_1->WKFLAGWIN := cMarca            //mjb1197
ENDIF

RETURN TQtde
*---------------------------------------------*
FUNCTION TPC251Work_1(Tela,Flag,Achou_ID)
*---------------------------------------------*
LOCAL TemItemNoID000:=IF(AChou_ID # NIL,AChou_ID,.T.), nOrdSW8:=(SW8->(INDEXORD()))
Local nOrdSW9:=(SW9->(INDEXORD()))

*1- Parametro - "S" - Indica que o registro sera exibido
*               "N" - Indica que o registro nao sera exibido
*2- Parametro - "A" - Ativo - "N" - Nao Ativo
*3- Parametro - .T. - Item desse PO ja tem desembaraco
*               .F. - Item desse PO nao tem desembaraco

SW8->(dbSetOrder(3))
SW9->(dbSetOrder(1))
SB1->(DBSETORDER(1))
//SA5->(DBSEEK(xFilial("SA5")+SW3->W3_COD_I + SW3->W3_FABR + SW3->W3_FORN))
EICSFabFor(xFilial("SA5")+SW3->W3_COD_I+SW3->W3_FABR+SW3->W3_FORN, EICRetLoja("SW3","W3_FABLOJ"), EICRetLoja("SW3","W3_FORLOJ"))

Work_1->(DBAPPEND())

Work_1->WKPO_NUM   := SW2->W2_PO_NUM
Work_1->WKCOD_I    := SW3->W3_COD_I
Work_1->WKTELA     := Tela
Work_1->WKFLAG     := Flag
Work_1->WKFLAGWIN  := cMarca            //DRL - 11/05/09
Work_1->WKQTD_INI  := SW3->W3_QTDE
Work_1->WKQTD_ENTR := IF(TemItemNoID000,SW7->W7_QTDE,0)
Work_1->WKDESCR    := Posicione("SB1", 1, xFilial("SB1")+Work_1->WKCOD_I, "B1_DESC")//RMD - 21/03/19 - Utiliza a descrição do B1 IF(SB1->(DBSEEK(xFilial("SB1")+Work_1->WKCOD_I)),MSMM(SB1->B1_DESC_GI,30,1),SPACE(30))
Work_1->WKFABR     := SW3->W3_FABR
IF EICLOJA()
   Work_1->W3_FABLOJ:= SW3->W3_FABLOJ
ENDIF   
Work_1->WKCONTROLE := STR(MNr_Controle,4)
Work_1->WKCONT_IP  := IF(SW3->W3_NR_CONT > 0,SW3->W3_NR_CONT,VAL(SW3->W3_POSICAO)) //JMS 04/05/06 QUANDO O PEDIDO É INTEGRADO, NÃO GRAVA O W3_NR_CONT
Work_1->WKNBM      := If(TemItemNoID000,Busca_NCM("SW7"),Busca_NCM("SW3")) //GFC 24/9/01
Work_1->WKUNID     := BUSCA_UM(SW3->W3_COD_I+SW3->W3_FABR +SW3->W3_FORN,SW3->W3_CC+SW3->W3_SI_NUM,IF(EICLOJA(),SW3->W3_FABLOJ,""),IF(EICLOJA(),SW3->W3_FORLOJ,""))//SO.:0022/02 OS.:0133/02 IF(! EMPTY(SA5->A5_UNID),SA5->A5_UNID,SB1->B1_UM)
Work_1->WKIDPRECO  := IF(TemItemNoID000,SW7->W7_PRECO,0)
Work_1->WKHAWB     := IF(TemItemNoID000,SW7->W7_HAWB,SPACE(1))

//AAF 03/02/2017 - Ajuste para considerar os campos de peso do pedido/li quando preenchidos.
If TemItemNoID000
  Work_1->WKPESO_L := W5PESO()
Else
  If SW3->(FieldPos("W3_PESOL")) > 0 .AND. !Empty(SW3->W3_PESOL)
    Work_1->WKPESO_L := SW3->W3_PESOL
  Else
    Work_1->WKPESO_L := B1PESO(SW3->W3_CC,SW3->W3_SI_NUM,SW3->W3_COD_I,SW3->W3_REG,SW3->W3_FABR,SW3->W3_FORN,EICRetLoja("SW3","W3_FABLOJ"),EICRetLoja("SW3","W3_FORLOJ"))
  EndIf
EndIf

Work_1->WKPOSICAO  := SW3->W3_POSICAO
IF(EasyEntryPoint("EICTP251"),ExecBlock("EICTP251",.F.,.F.,"WORK_1"),)

IF lExiste_Midia
  SB1->(DBSEEK(xFilial("SB1")+SW3->W3_COD_I))
  IF SB1->B1_MIDIA $ cSim
    Work_1->WK_QTMIDIA := SB1->B1_QTMIDIA
    Work_1->WKICM_MID  := EasyGParam("MV_ICMSMID") * Work_1->WK_QTMIDIA * SW3->W3_QTDE
    Work_1->WKBASEMID  := Work_1->WK_QTMIDIA * SW3->W3_QTDE * SW2->W2_VLMIDIA   //FOB MIDIA
    SW8->(dbSeek(xFilial("SW8")+SW7->W7_HAWB+SW7->W7_PGI_NUM+;  //GFC 24/9/01
                 SW7->W7_PO_NUM+SW7->W7_SI_NUM+SW7->W7_CC+SW7->W7_COD_I+Str(SW7->W7_REG,4,0)))
    //TDF 06/12/2010 - ACRESCENTA O HAWB NA CHAVE DE BUSCA
    SW9->(dbSeek(xFilial("SW9")+SW8->W8_INVOICE+SW8->W8_FORN+EICRetLoja("SW8","W8_FORLOJ")+SW8->W8_HAWB))
    IF TemItemNoID000 .AND. !Empty(SW9->W9_MOE_FOB)  //GFC 24/9/01
       nTaxaMid := SW9->W9_TX_FOB
    ELSE
//     nTaxaMid:=BuscaTaxa(SW2->W2_MOEDA,SW2->W2_PO_DT)
//     nTaxaMid:=BuscaTaxa(SW2->W2_MOEDA,dDataBase) // RA - 13/08/2003 - O.S. 746/03 e 748/03
       If SW2->W2_MOEDA <> cMoedaEst//RMD - 21/03/19
          nTaxaMid:=BuscaTaxa(SW2->W2_MOEDA,dDataConTx,.T.,.F.,.T.)// RA - 13/08/2003 - O.S. 746/03 e 748/03
       Else
          nTaxaMid := nTMExtDConTx
       EndIf
       
    ENDIF
             
    nTotBaseMid += Work_1->WKBASEMID

  ENDIF

ENDIF
SW8->(dbSetOrder(nOrdSW8))
SW9->(dbSetOrder(nOrdSW9))

*--------------------------------------------*
FUNCTION TPC251Calc(PMensagem1,PMensagem2)
*--------------------------------------------*
LOCAL oDesc, cDescTab, oDlg, lProcessa:=.T., nOpca:=0
Static aEDspBsIITab := {}
PMensagem1 := STR0033 //"PRE-CALCULO EFETIVADO"
PMensagem2 := SPACE(33)

If AvKey(TNr_PO,"W2_PO_NUM") # SW2->W2_PO_NUM
   SW2->(DbSeek(xFilial("SW2")+AvKey(TNr_PO,"W2_PO_NUM")))
EndIf

DEFINE MSDIALOG oDlg TITLE cCadastro From 7,0 To 23,80 OF oMainWnd

oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165)
oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

@ 13,5 TO 74,(oDlg:nClientWidth-10)/2 LABEL "" OF oPanel PIXEL
@ 20,10 SAY STR0020 OF oPanel PIXEL //"No. P.O."
@ 20,98 SAY STR0021 OF oPanel PIXEL //"Data"

@ 20,50   MSGET TNr_PO  PICTURE _PictPO  SIZE 40,8 WHEN .F. OF oPanel PIXEL
@ 20,125  MSGET SW2->W2_PO_DT            SIZE 40,8 WHEN .F. OF oPanel PIXEL

@ 33,10  SAY STR0034 OF oPanel PIXEL //"Tab.Pre-Calc"
@ 20,195 SAY STR0035 OF oPanel PIXEL //"Gerado em"

@ 47,10 SAY STR0036 OF oPanel PIXEL //"Cond. Pagto"

cPag:=TRAN(SW2->W2_COND_PA, cPicCond)+'/ '+TRAN(SW2->W2_DIAS_PA,'999') //DRL - 11/05/09

@ 47,50 MSGET cPag WHEN .F. OF oPanel PIXEL  SIZE 40,8

SYQ->(DBSETORDER(1))
SYQ->(DBSEEK(xFilial("SYQ")+SW2->W2_TIPO_EM))

cVia0:=SYQ->YQ_VIA
cVia1:=ALLTRIM(SYQ->YQ_DESCR)  // ALLTRIM(LEFT(SYQ->YQ_DESCR,11))
cVia2:=ALLTRIM(SW2->W2_ORIGEM)
cVia3:=ALLTRIM(SW2->W2_DEST)
@47,098 SAY STR0037 OF oPanel PIXEL SIZE 30,8 //"Via "
@47,195 SAY STR0038 OF oPanel PIXEL SIZE 30,8 //"Origem"
@47,255 SAY STR0039 OF oPanel PIXEL SIZE 30,8 //"Destino"

@47,110 MSGET cVia1       WHEN .F. SIZE 78,8 OF oPanel PIXEL
@47,225 MSGET cVia2       WHEN .F. SIZE 15,8 OF oPanel PIXEL
@47,282 MSGET cVia3       WHEN .F. SIZE 15,8 OF oPanel PIXEL

@33,195 SAY STR0040 OF oPanel PIXEL //"Mensagem"
@33,225 MSGET PMensagem1  WHEN .F. SIZE 80,8 OF oPanel PIXEL

cForn:=SW2->W2_FORN+' '+IF(EICLOJA(),SW2->W2_FORLOJ,"")+IF(SA2->(DBSEEK(xFilial("SA2")+SW2->W2_FORN+EICRetLoja("SW2","W2_FORLOJ"))),SA2->A2_NREDUZ,SPACE(12))
@60,10 SAY STR0041 OF oPanel PIXEL //"Fornecido por "
@60,50 MSGET cForn WHEN .F. OF oPanel PIXEL SIZE 110,8

TPr_Cal:=SW2->W2_TAB_PC

If !SWI->(dbSetOrder(2),dbSeek(xFilial("SWI")+SW2->W2_TIPO_EM+SW2->W2_TAB_PC))  // AAF - 07/10/2013
   SWI->(dbSetOrder(1))
   SWI->(DBSEEK(xFilial("SWI")+TPr_Cal))
EndIf
SWI->(dbSetOrder(1))

cDescTab:=LEFT(SWI->WI_DESC,30)

@ 33,50  MSGET TPr_Cal F3 cArqF3           SIZE 32,8 OF oPanel PIXEL  //VALID IF(TPC251Tab(oDesc,cDescTab),(nOpca:=1,oDlg:End(),.T.),.F.) PIXEL
@ 33,98  MSGET oDesc VAR cDescTab WHEN .F. SIZE 90,8 OF oPanel PIXEL
@ 20,225 MSGET SW2->W2_DT_PC      WHEN .F. SIZE 40,8 OF oPanel PIXEL

If(EasyEntryPoint("EICTP251"),ExecBlock("EICTP251",.F.,.F.,"TPC251CALC_ANT_TELA"),) //ISS - 19/10/2010 - Para inclusão de novos campos
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||IF(TPC251Tab(oDesc,cDescTab),(nOpca:=1,oDlg:End()),)},;
                                                {||nOpca:=0,oDlg:End()}) CENTERED

IF nOpca==1
   TPC251VerCon()
ENDIF

RETURN nOpca

*----------------------------------------------------------------------------*
Function TPC251VerCon()
*----------------------------------------------------------------------------*
LOCAL _PictItem := ALLTRIM(X3Picture("B1_COD"))

LOCAL TB_Campos := { { "WKFLAGWIN",,""} ,;
                     { {||TRAN(Work_1->WKCOD_I,_PictItem)+' '+Work_1->WKDESCR},,STR0004  } ,; //"Cod. Item"
                     { "WKQTD_ACU"                            ,,STR0042,AVSX3("W7_QTDE",6)} ,; //"Quantidade"
                     { "WKFOB_UNT"                            ,,STR0043, _PictPrUn   } ,; //"Fob. Unitario"
                     { "WKFOB_TOT"                            ,,STR0044, _PictPrUn      } ,; //"Fob. Total"
                     { {||Work_1->( TRAN(WKPESO_L * WKQTD_ACU,AVSX3("W3_PESOL",6) ) )},,STR0045} } //"Peso Liq."


LOCAL oDesc,cDescTab, oDlg2, PMensagem1, PMensagem2, oPanel
LOCAL cPag, cVia0, cVia1, cVia2, cVia3, cFil_SW3
LOCAL cBD := TcGetDb()
Local aBuffers := {tHashMap():New(), tHashMap():New()}//RMD - 08/04/19 - Buffers para a função TPC251GrPreCalc: [1]-Dados de NCM, [2]-Dados de Unidade de Medida

PRIVATE nQtdeAcumulada := 0 // CAF OS.871/98 07/08/1998 15:16
PRIVATE nPesoAcumulado := 0 // CAF OS.871/98 07/08/1998 15:16
Private nTotFreGeral   := 0

PRIVATE nIpiAcumulado  := 0 // CAF OS.871/98 08/08/1998 15:34
PRIVATE nIi_Acumulado  := 0 // CAF OS.871/98 08/08/1998 15:34
PRIVATE nFobAcumulado  := 0 , lProcessa:=.T., nCont:=0

PRIVATE nValFobTot := 0 //AAF 27/11/08 
PRIVATE aButtons := {} //FDR - 16/08/11


//WFS 03/07/2014
If Type("lAvIntDesp") <> "L"
   lAvIntDesp := AvFlags("AVINT_PR_EIC") .OR. AvFlags("AVINT_PRE_EIC")
EndIf

IF lExiste_Midia
  AADD(TB_CAMPOS ,{ "WKBASEMID" ,, STR0046}) //"Base Midia "
ENDIF

IF !lAvFLuxo//Por causa do Begin Transaction acionado para o financeiro
   Work_1->(avzap())
ELSE
   Work_1->(DBGOTOP())
   DO WHILE Work_1->(!EOF())
      Work_1->(DBDELETE())
      Work_1->(DBSKIP())
   ENDDO
ENDIF

#IFDEF TOP 
   If Alltrim(cBD) <> "INFORMIX"
      cQuery := "Select * from "+RetSqlName("SW3")+" Where D_E_L_E_T_ <> '*' AND W3_PO_NUM = '"+SW2->W2_PO_NUM+"' AND W3_SEQ = 0"
    
      cQuery := "SELECT COUNT(*) AS TOTAL FROM ("+cQuery+") TEMP"
      TcQuery ChangeQuery(cQuery) ALIAS "TOTALREG" NEW
      nCont:= TOTALREG->TOTAL
      TOTALREG->( dbCloseArea() )
      DBSELECTAREA("SW3")
   Else   
      DBSELECTAREA("SW3")
      DBSEEK((cFil_SW3:=xFilial("SW3"))+SW2->W2_PO_NUM)
      If ( Type("lPOAuto") == "U" .OR. !lPOAuto )
         Processa({||DBEVAL({||nCont++},{||W3_SEQ==0 .AND. TPC251SALDOPC(SW2->W2_PO_NUM)>0 },{||W3_FILIAL+W3_PO_NUM==cFil_SW3+SW2->W2_PO_NUM})},STR0023) //"Lendo Itens do Pedido"
      Else
         DBEVAL({||nCont++},{||W3_SEQ==0 .AND. TPC251SALDOPC(SW2->W2_PO_NUM)>0 },{||W3_FILIAL+W3_PO_NUM==cFil_SW3+SW2->W2_PO_NUM})
      EndIf
   EndIf    
#ELSE
   DBSELECTAREA("SW3")
   DBSEEK((cFil_SW3:=xFilial("SW3"))+SW2->W2_PO_NUM)
   Processa({||DBEVAL({||nCont++},{||W3_SEQ==0 .AND. TPC251SALDOPC(SW2->W2_PO_NUM)>0 },{||W3_FILIAL+W3_PO_NUM==cFil_SW3+SW2->W2_PO_NUM})},STR0023) //"Lendo Itens do Pedido"
#ENDIF

DBSEEK((cFil_SW3:=xFilial("SW3"))+SW2->W2_PO_NUM)

//Processa({||DBEVAL({||TPC251GrPreCalc()},{||W3_SEQ==0 .AND. TPC251SALDOPC(SW2->W2_PO_NUM)>0 },{||W3_FILIAL+W3_PO_NUM==cFil_SW3+SW2->W2_PO_NUM}),STR0023) //"Lendo Itens do Pedido"
If ( Type("lPOAuto") == "U" .OR. !lPOAuto )
   Processa({||LerItensPed(aBuffers)},STR0023) //"Lendo Itens do Pedido"
Else
   LerItensPed(aBuffers)
EndIf
PMensagem1 := STR0033 //"PRE-CALCULO EFETIVADO"
PMensagem2 := SPACE(33)

DBSELECTAREA("Work_1")

MMsgApu:=STR0047 //"GERANDO PRE-CALCULO - AGUARDE..."

IF EMPTY(SW2->W2_STAT_PC) .OR. SW2->W2_STAT_PC = "2"
   If ( Type("lPOAuto") == "U" .OR. !lPOAuto )
      Processa( {||TPC251CalTab(MMsgApu)} )
   Else
      TPC251CalTab(MMsgApu)
   EndIf
ELSE
   IF TPr_Cal <> SW2->W2_TAB_PC
      If ( Type("lPOAuto") == "U" .OR. !lPOAuto )
         Processa({||TPC251CalTab(MMsgApu)})
      Else
         TPC251CalTab(MMsgApu)
      EndIf
   ELSE
     If !lAvFluxo
      IF ( Type("lPOAuto") == "U" .OR. !lPOAuto ) .And. MsgYesNo(STR0048,STR0049) //"Deseja reapurar o Pre-Calculo ? "###"Pre-Calculo"
           MMsgApu:=STR0050 //"REAPURANDO O PRE-CALCULO - AGUARDE..."
           Processa({||TPC251CalTab(MMsgApu)})
        ENDIF
     ELSE
         MMsgApu:=STR0050 //"REAPURANDO O PRE-CALCULO - AGUARDE..."
         If ( Type("lPOAuto") == "U" .OR. !lPOAuto )
            Processa({||TPC251CalTab(MMsgApu)})
         Else
            TPC251CalTab(MMsgApu)
         EndIf
      ENDIF
   ENDIF
ENDIF
If(EasyEntryPoint("EICTP251"),ExecBlock("EICTP251",.F.,.F.,"POS_GRAVA_TPC"),) //JWJ 24/10/2006

//FDR - 16/08/11 - Botões da EnchoiceBar
Aadd(aButtons,{"S4WB010N"    ,{|| TPC251Print(Por_Item,MHAWB)},STR0068,STR0068})//"Relatorio por Item" 
Aadd(aButtons,{"RELATORIO"   ,{|| TPC251Print(Por_PO,MHAWB)}  ,STR0069,STR0069})//"Relatorio por P.O" 
Aadd(aButtons,{"MENURUN"     ,{|| TPC251Con()}                ,STR0070,STR0070})//"Ver Tabela" 
Aadd(aButtons,{"RESPONSA"    ,{|| TPC251MarcAll()}            ,STR0198,STR0198}) 
 
DO WHILE .T. .and. !lAvFluxo // Entra se nao for Fluxo

   DBSELECTAREA("Work_1")
   DBGOTOP()
   nOpca:=0

   oMainWnd:ReadClientCoors()
   DEFINE MSDIALOG oDlg2 TITLE cCadastro ;
             FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
      	       OF oMainWnd PIXEL               //From 8,0 To 28,80 OF oMainWnd
     @ 00,00 MsPanel oPanel2 Prompt "" Size 60,60 of oDlg2
     @ 7,10 SAY STR0020 of oPanel2 PIXEL //"No. P.O."
     @ 7,98 SAY STR0021 of oPanel2 PIXEL //"Data"

     @ 5,50   MSGET TNr_PO  PICT _PictPO SIZE 40,8 WHEN .F. of oPanel2 PIXEL
     @ 5,125  MSGET SW2->W2_PO_DT        SIZE 40,8 WHEN .F. of oPanel2 PIXEL

     @ 20,10  SAY STR0034 of oPanel2 PIXEL //"Tab.Pre-Calc"
     @ 7,195 SAY STR0035 of oPanel2 PIXEL //"Gerado em"

     @ 34,10 SAY STR0036   of oPanel2 PIXEL //"Cond. Pagto"

     cPag:=TRAN(SW2->W2_COND_PA, cPicCond)+'/ '+TRAN(SW2->W2_DIAS_PA,'999') //DRL - 11/05/09

     @ 32,50 MSGET cPag WHEN .F. of oPanel2 PIXEL  SIZE 40,8

     SYQ->(DBSETORDER(1))
     //SYQ->(DBSEEK(xFilial("SYQ")+SW2->W2_TIPO_EM))
     SYQ->(DBSEEK(xFilial("SYQ")+if(empty(SWI->WI_VIA),SW2->W2_TIPO_EM,SWI->WI_VIA)))

     cVia0:=SYQ->YQ_VIA
     cVia1:=ALLTRIM(SYQ->YQ_DESCR)
     cVia2:=ALLTRIM(SW2->W2_ORIGEM)
     cVia3:=ALLTRIM(SW2->W2_DEST)
     @34,098 SAY STR0037   of oPanel2 PIXEL SIZE 30,8 //"Via "
     @34,195 SAY STR0038   of oPanel2 PIXEL SIZE 30,8 //"Origem"
     @34,260 SAY STR0039   of oPanel2 PIXEL SIZE 30,8 //"Destino"

     @32,110 MSGET cVia1       WHEN .F. SIZE 78,8 of oPanel2 PIXEL
     @32,225 MSGET cVia2       WHEN .F. SIZE 15,8 of oPanel2 PIXEL
     @32,290 MSGET cVia3       WHEN .F. SIZE 15,8 of oPanel2 PIXEL

     @20,195 SAY STR0040 of oPanel2 PIXEL //"Mensagem"
     @18,225 MSGET PMensagem1  WHEN .F. SIZE 80,8 of oPanel2 PIXEL

     cForn:=SW2->W2_FORN+' '+IF(EICLOJA(),SW2->W2_FORLOJ,"")+IF(SA2->(DBSEEK(xFilial("SA2")+SW2->W2_FORN+EICRetLoja("SW2","W2_FORLOJ"))),SA2->A2_NREDUZ,SPACE(12))
     @47,10 SAY STR0041 of oPanel2 PIXEL //"Fornecido por "
     @45,50 MSGET cForn WHEN .F. of oPanel2 PIXEL SIZE 110,8

     TPr_Cal:=SW2->W2_TAB_PC
     
     If !SWI->(dbSetOrder(2),dbSeek(xFilial("SWI")+SW2->W2_TIPO_EM+SW2->W2_TAB_PC))
        SWI->(dbSetOrder(1))
        SWI->(DBSEEK(xFilial("SWI")+TPr_Cal))
     EndIf
     SWI->(dbSetOrder(1))
     
     cDescTab:=LEFT(SWI->WI_DESC,30)
     @ 18,50  MSGET TPr_Cal             WHEN .F. SIZE 32,8 of oPanel2 PIXEL
     @ 18,98  MSGET oDesc VAR cDescTab  WHEN .F. SIZE 90,8 of oPanel2 PIXEL
     @ 5,225 MSGET SW2->W2_DT_PC       WHEN .F. SIZE 40,8 of oPanel2 PIXEL

     oMark:= MsSelect():New("Work_1","WKFLAGWIN",,TB_Campos,@lInverte,@cMarca,{80,5,(oDlg2:nClientHeight-2)/2,(oDlg2:nClientWidth-2)/2})
     oMark:bAval:={||Work_1->WKFLAG:=IF(Work_1->WKFLAG=='A','N','A'),;
                  Work_1->WKFLAGWIN:=IF(Work_1->WKFLAG=='A',cMarca,SPACE(02))}

     If(EasyEntryPoint("EICTP251"),ExecBlock("EICTP251",.F.,.F.,"TPC251VERCON_ANT_TELA"),) //ISS - 19/10/2010 - Para inclusão de novos campos
							  
     oPanel2:Align:=CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
	 oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
	 
   ACTIVATE MSDIALOG oDlg2 ON INIT (EnchoiceBar(oDlg2,{||oDlg2:End()},{||oDlg2:End()},,aButtons)) //FDR - 16/08/11 //LRL 12/04/04 - Alinhamento MDI.    //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT                                                 

   If nOpca = 0
      EXIT
   EndIF

/*   DO CASE
      CASE  nOpca=0
            EXIT
      CASE  nOpca=1
            TPC251Print(Por_Item,MHAWB)

      CASE  nOpca=2
            TPC251Print(Por_PO,MHAWB)

      CASE  nOpca=3
            TPC251Con() 
            
      CASE  nOpca=4
      		TPC251MarcAll()
      
   ENDCASE*/

ENDDO

RETURN .T.

*----------------------------------------------------------------------------*
FUNCTION TPC251CalTab(MMsgApu)
*----------------------------------------------------------------------------*
LOCAL aPagtos:={}, Paridade:=1, MFOB, MRateio,;
      MTx_Usd:= nTMExtDConTx//RMD - 21/03/19 - BuscaTaxa(cMOEDAEST,dDataConTx,.T.,.F.,.T.)// RA - 13/08/2003 - O.S. 746/03 e 748/03
//    MTx_Usd:= BuscaTaxa(cMOEDAEST,dDataBase) // RA - 13/08/2003 - O.S. 746/03 e 748/03
//    MTx_Usd:= BuscaTaxa("US$",SW2->W2_PO_DT) 


LOCAL MRateioPeso:=0  // Jonato em 12/08/2003

LOCAL bGrava  :={|desp,data,valor,tab,perc,lConverte| ;
                  TPC251Grava(desp,data,valor,tab,perc,cFilSWH,nDecWHVal,nDecWHValR,lConverte)}
Local bTPCPag:={ |TPC| IF(TPC:DESPESA # VALOR_CIF .And. aScan(aDespBase, &("{|x| x[1] == '"+TPC:DESPESA+"'}")) == 0 ,;
                   TPCCalculo(TPC, Work_1->WKQTD_ACU, MRateio,MTx_Usd,bGrava,;
                   aPagtos,TPr_Cal,aDespBase,SW2->W2_FREPPCC,/*Origem252*/,/*PDBF*/,MRateioPeso,/*dDtRef*/,/*nParidade*/,SW6->W6_IMPORT,lRegTriPO,bTPCPag,@aBuffers,"TPC251"),) }  // GFP - 01/08/2013
LOCAL I, nInd_Frete, nimp, nVlrConte
LOCAL nVl_Pag := 0,  nOrdSW3:=(SW3->(INDEXORD()))
//RRV - 27/12/2012
Local n := 0
Local nPos, nPos2
Local cCalculado := "1"   //NCF - 10/01/2017
Local nBasCalFre          //NCF - 12/12/2018
Local aBuffers := {tHashMap():New(), tHashMap():New(), tHashMap():New()}//RMD - 08/04/19 - Buffers para a função TPCCalculo: [1]-Dados de Paridade, [2]-Dados de NCM, [2]-Dados de Majoração do Cofins
//RMD - 08/04/19 - Para evitar a chamada em loop na função TPC251Grava
Local cFilSWH := xFilial("SWH")
Local nDecWHVal  := AvSX3("WH_VALOR", AV_DECIMAL)
Local nDecWHValR := AvSX3("WH_VALOR_R", AV_DECIMAL)

PRIVATE MFobDesp,nValFobTot, aTPC:={}, aDespBase:={},nValor_Frete := 0,aRateio := {} //RRV - 27/12/2012
Private MTx_Usd_Pc       //RRV - 27/12/2012
Private aICMS_Dif := {}  //NCF - 24/01/2013 - Array de aliquotas do CFO para cada item
If Type("oBufferNCM") <> "O"
   Private oBufferNCM := tHashMap():New()//RMD - 21/03/19 - Buffer para os dados de NCM
EndIf
SWH->(DBSETORDER(1))
SWH->(DBSEEK(xFilial("SWH")+SW2->W2_PO_NUM))

If ( Type("lPOAuto") == "U" .OR. !lPOAuto )
   ProcRegua(SWH->(LASTREC()))
   SWH->(DBEVAL({|| IncProc(STR0051) ,; //"Eliminando Valores do Pre-Calculo Anterior"
                 SWH->(RecLock("SWH",.F.)) ,;
                 SWH->(DBDELETE())  ,;
                 SWH->(MsUnlock())   },,;
                 {|| SWH->WH_PO_NUM = SW2->W2_PO_NUM .AND. SWH->WH_FILIAL == xFilial("SWH") }))
Else
   SWH->(DBEVAL({|| SWH->(RecLock("SWH",.F.)) ,;
                 SWH->(DBDELETE())  ,;
                 SWH->(MsUnlock())   },,;
                 {|| SWH->WH_PO_NUM = SW2->W2_PO_NUM .AND. SWH->WH_FILIAL == xFilial("SWH") }))
EndIf
IF SW2->W2_MOEDA # cMOEDAEST
// Paridade:=BuscaTaxa(SW2->W2_MOEDA,SW2->W2_PO_DT) / MTx_Usd
// Paridade:=BuscaTaxa(SW2->W2_MOEDA,dDataBase) / MTx_Usd // RA - 13/08/2003 - O.S. 746/03 e 748/03 
   Paridade:=BuscaTaxa(SW2->W2_MOEDA,dDataConTx,.T.,.F.,.T.) / MTx_Usd // RA - 13/08/2003 - O.S. 746/03 e 748/03 
ENDIF
//MFR 25/09/2019 OSSME-3748
SWI->(DBSETORDER(2))
If IsMemVar("cVia0") .And. IsMemVar("Tpr_Cal")
   SWI->(DBSEEK(xFilial("SWI") + cVia0 + Tpr_Cal))
   If SWI->(EOF()) .or. SWI->(BOF())
      SWI->(DBSETORDER(1))      
      SWI->(DBSEEK(xFilial("SWI") + Tpr_Cal))
   EndIf   
Else
   SWI->(DBSEEK(xFilial("SWI") + SW2->W2_TIPO_EM + SW2->W2_TAB_PC))
   If SWI->(EOF()) .or. SWI->(BOF())
      SWI->(DBSETORDER(1))      
      SWI->(DBSEEK(xFilial("SWI") + SW2->W2_TAB_PC))
    EndIf      
EndIf   
TPCCarga(aTPC,.T.)
nInd_Frete := aScan( aTPC, {|x| x[3] == DESPESA_FRETE })
nInd_Seguro := aScan( aTPC, {|x| x[3] == DESPESA_SEGURO }) 

 MFobDesp:=geraFob(nInd_Frete,nInd_Seguro)
 IF (GetNewPar("MV_EASYFIN","N")='S' .Or. lAvIntDesp) .AND. cAVFase$'PODI'  //wfs 03/07/2014 - atualização dos valores para integração via EAI
   //Se Integração com EASY Financeiro o sistema de baseia 
   //No rateio de Outras despesas INLAND PACKING DESCONTO e se Frete Pre-Pago FRETEIN

   nValFobTot:=0            
   Work_1->(DBGOTOP())
   Work_1->(DBEVAL({|| nValFobTot+=Work_1->WKFOB_TOT } ))
   IF nValFobTot < SW2->W2_FOB_TOT
   //MFR 20/08/2019 OSSME-2689
      MFobDesp:= ( MFobDesp * (   nValFobTot / SW2->W2_FOB_TOT ) )  
   EndIf
ENDIF

// *** CAF OS.871/98 07/08/1998 15:13 (INICIO)
IF nInd_Frete != 0 
   IF EasyGParam("MV_AVG0227",,.F.) .And. Empty(SWF->WF_VIA) .And. aTPC[nInd_Frete][11] == "2"  //FSY - 15/07/2013- Validação para calcular frete com % fixo pela tabela de pre-calculo. Codigo adicionado: !(EasyGParam("MV_AVG0227",,.F.) .And. Empty(SWF->WF_VIA)
      nBasCalFre          := TPCBase251(aTPC[nInd_Frete][7],aTPC,nInd_Frete)
      nValor_Frete        := nBasCalFre * (aTPC[nInd_Frete][6]/100)
      aTPC[nInd_Frete][5] := nValor_Frete
      //aTPC[nInd_Frete][11]:= "1"
   Else
      aTPC[nInd_Frete][6]:=0 //PARA ZERAR O PERCENTUAL APLICADO
      IF aTPC[nInd_Frete][11] # "1"
         SYR->(DBSEEK(xFilial()+SW2->W2_TIPO_EM+SW2->W2_ORIGEM+SW2->W2_DEST))
         aTpc[nInd_Frete][4]:=SYR->YR_MOEDA //RRV - 29/10/2012 - Assume a moeda informada na via de transporte.
         IF(EasyEntryPoint("EICTP251"),Execblock("EICTP251",.F.,.F.,'TOT_CNT'),)
         //RRV - 27/12/2012 - Mudança na sequencia de valores do frete(1ºConteiner,2ºCubagem,3ºRegra de peso por quilo).
         IF SW2->(!EMPTY(W2_FRETEIN)) //LGS-13/06/2016
            nValor_Frete := SW2->W2_FRETEIN
         
         ELSEIF (SW2->W2_CONTA20 > 0 .And. SYR->YR_20 > 0) 	.Or.;
            (SW2->W2_CONTA40 > 0 .And. SYR->YR_40 > 0) 	.Or.;
            (SW2->W2_CON40HC > 0 .And. SYR->YR_40_HC > 0) 	.Or.;
            (SW2->W2_OUTROS > 0 .And. SYR->YR_OUTROS > 0) 

            nValor_Frete += SW2->W2_CONTA20 * SYR->YR_20
            nValor_Frete += SW2->W2_CONTA40 * SYR->YR_40
            nValor_Frete += SW2->W2_CON40HC * SYR->YR_40_HC
            nValor_Frete += SW2->W2_OUTROS  * SYR->YR_OUTROS

         ELSEIF !EMPTY(SW2->W2_MT3)
            nFrete1:=TabFre( SW2->W2_MT3 / 0.006 )
            nFrete2:=TabFre( nPesoAcumulado )
            nValor_Frete:=IF(nFrete1>=nFrete2,nFrete1,nFrete2)
         ELSE
            nValor_Frete := TabFre( nPesoAcumulado )
         ENDIF
         aTPC[nInd_Frete][5] := nValor_Frete
         aTPC[nInd_Frete][11] := "1"  // Caracter diferente de 2 para ser caculado os valores maximo e minino para o frete.

         If aTPC[nInd_Frete][4] # SYR->YR_MOEDA 
   //       aTPC[nInd_Frete][5]:= aTPC[nInd_Frete][5] * (BuscaTaxa(SYR->YR_MOEDA,dDataBase) / BuscaTaxa(aTPC[nInd_Frete][4],dDataBase))      
            aTPC[nInd_Frete][5]:= aTPC[nInd_Frete][5] * (If(SYR->YR_MOEDA==cMoedaEst, nTMExtDConTx, BuscaTaxa(SYR->YR_MOEDA,dDataConTx,.T.,.F.,.T.)) / If(aTPC[nInd_Frete][4]==cMoedaEst, nTMExtDConTx, BuscaTaxa(aTPC[nInd_Frete][4],dDataConTx,.T.,.F.,.T.))) // RA - 13/08/2003 - O.S. 746/03 e 748/03      
         ENDIF
      ENDIF     
   EndIf
   
   IF aTPC[nInd_Frete][5] < aTPC[nInd_Frete][10] // SWI->WI_VAL_MIN
      aTPC[nInd_Frete][5] := aTPC[nInd_Frete][10] 
   ElseIF aTPC[nInd_Frete][5] > aTPC[nInd_Frete][9] .AND. aTPC[nInd_Frete][9] # 0 // SWI->WI_VAL_MAX
      aTPC[nInd_Frete][5] := aTPC[nInd_Frete][9]
   ENDIF 

   nTotFreGeral := aTPC[nInd_Frete][5]
ENDIF

// valor do seguro transformado em função a ser usado também no tp252
nTotSegGeral := TP251Seguro(@aTPC,nInd_Seguro)

If ( Type("lPOAuto") == "U" .OR. !lPOAuto )
   ProcRegua(Len(aTPC)*2)
EndIf
For I:=1 To Len( aTPC )
    If ( Type("lPOAuto") == "U" .OR. !lPOAuto )
      IncProc(STR0052) //"Processando Despesas"
    EndIf
    IF At(aTPC[I][3],"101.102.103.104.201.202.203") != 0// SWI->WI_DESP && FOB.SEG.CIF.II.IPI.ICMS
       Loop
    ENDIF

    IF aTPC[I][11] == "3"  // SWI->WI_IDVL == QUANTIDADE
       aTPC[I][5] := nQtdeAcumulada * aTPC[I][8] //SWI->WI_VALOR
    ENDIF

    IF aTPC[I][11] = "4" .AND. aTPC[I][3] # DESPESA_FRETE // WI_IDVL == DESPESA POR PESO

       IF nPesoAcumulado <= aTPC[I][12]     // WI_KILO1
          aTPC[I][5] := aTPC[I][13] * nPesoAcumulado  // WI_VALOR1
       ELSEIF nPesoAcumulado <= aTPC[I][14] // WI_KILO2
          aTPC[I][5] := aTPC[I][15]  * nPesoAcumulado// WI_VALOR2
       ELSEIF nPesoAcumulado <= aTPC[I][16] // WI_KILO3
          aTPC[I][5] := aTPC[I][17]  * nPesoAcumulado// WI_VALOR3
       ELSEIF nPesoAcumulado <= aTPC[I][18] // WI_KILO4
          aTPC[I][5] := aTPC[I][19]  * nPesoAcumulado// WI_VALOR4
       ELSEIF nPesoAcumulado <= aTPC[I][20] // WI_KILO5
          aTPC[I][5] := aTPC[I][21]  * nPesoAcumulado// WI_VALOR5
       ELSE //nPesoAcumulado <= aTPC[I][22] // WI_KILO6
          aTPC[I][5] := aTPC[I][23]  * nPesoAcumulado// WI_VALOR6
       ENDIF
      
    ENDIF
    
    IF aTPC[I][11] # "2"  // SWI->WI_IDVL != PERCENTUAL
       IF aTPC[I][5] < aTPC[I][10] // SWI->WI_VAL_MIN
          aTPC[I][5] := aTPC[I][10] 
       ENDIF
       IF aTPC[I][5] > aTPC[I][9] .AND. aTPC[I][9] # 0 // SWI->WI_VAL_MAX
          aTPC[I][5] := aTPC[I][9]
       ENDIF
    ENDIF 
    
    IF aTPC[I][11] == "5"  // SWI->WI_IDVL == CONTEINER
       nVlrConte := 0
       nVlrConte += SW2->W2_CONTA20 * aTPC[I][24] //SWI->WI_CON20
       nVlrConte += SW2->W2_CONTA40 * aTPC[I][25] //SWI->WI_CON40
       nVlrConte += SW2->W2_CON40HC * aTPC[I][26] //SWI->WI_CON40H
       nVlrConte += SW2->W2_OUTROS  * aTPC[I][27] //SWI->WI_CONOUT
       aTPC[I][5] := nVlrConte
       IF aTPC[I][5] < aTPC[I][10] // SWI->WI_VAL_MIN
          aTPC[I][5] := aTPC[I][10] 
       ENDIF
       IF aTPC[I][5] > aTPC[I][9] .AND. aTPC[I][9] # 0 // SWI->WI_VAL_MAX
          aTPC[I][5] := aTPC[I][9]
       ENDIF
    ENDIF                                       

Next I

//ER - 24/04/2007
If EasyEntryPoint("EICTP251")
   ExecBlock("EICTP251",.F.,.F.,"CALTAB")
EndIf

// *** CAF OS.871/98 07/08/1998 15:13 (FIM)
If ( Type("lPOAuto") == "U" .OR. !lPOAuto )
   ProcRegua(Work_1->(LASTREC()))
EndIf
IF !((GetNewPar("MV_EASYFIN","N")='S' .Or. lAvIntDesp) .AND. cAVFase$'PODI') //wfs 03/07/2014 - atualização dos valores para integração via EAI
   nValFobTot:=SW2->W2_FOB_TOT
ENDIF

Work_1->(DBGOTOP())

SYB->(DBSETORDER(1))

nTamCont:=AVSX3("WH_NR_CONT",3)

DO WHILE Work_1->(!EOF())
   If ( Type("lPOAuto") == "U" .OR. !lPOAuto )
      IncProc(MMsgApu)
   EndIf
   IF (GetNewPar("MV_EASYFIN","N")="S" .Or. lAvIntDesp) .AND. !(cPaisLoc="BRA") //AAF 27/11/08 - A variável cUltimoItem é apenas para Localizações. //wfs 03/07/2014 - atualização dos valores para integração via EAI
      Work_1->(DBSKIP())
      
      If Work_1->(EOF())       // Solicitado envio especificando qual é o ultimo 
         cUltimoItem:=.t.
      ELSE
         cUltimoItem:=.f.
      Endif
      
      Work_1->(DBSKIP(-1))
   ENDIF
   //LRS - 26/07/2017 - Correção do calculo FOB de acordo com a paridade
   MRateio:= Work_1->WKFOB_TOT / nValFobTot //SW2->W2_FOB_TOT
  // If MParam == Pre_Calculo  // GFP - 02/12/2016
  //    MFOB   := Work_1->WKFOB_TOT  * MRateio  * Paridade
  // Else
      MFOB   := (Work_1->WKFOB_TOT + (MFobDesp * MRateio) ) * Paridade
  // EndIf

   SB1->(DBSEEK(xFilial("SB1")+Work_1->WKCOD_I))
   SW3->(DBSETORDER(8))  // Jonato , 30-07-01, para funcionar a funcao busca_ncm(), chamada da tpccalculo
   SW3->(DBSEEK(xFilial("SW3")+Work_1->WKPO_NUM+Work_1->WKPOSICAO))
   SW3->(DBSETORDER(nOrdSW3))

   MRateioPeso:= Work_1->WKPESO_L / nPesoAcumulado  // Jonato em 12/08/2003
   ASIZE(aPagtos,0)
   ASIZE(aDespBase,0)
// AADD(aPagtos,{dDataBase,MFOB})  // RA - 13/08/2003 - O.S. 746/03 e 748/03
   AADD(aPagtos,{dDataConTx,MFOB}) // RA - 13/08/2003 - O.S. 746/03 e 748/03
   PRIVATE nDspBasImp:=0 // AWR - Desp Base
   AEVAL(aTPC,bTPCPag)

   //AWR - 07/08/2003
   IF(EasyEntryPoint("EICTP251"),ExecBlock("EICTP251",.F.,.F.,"APOS_AEVAL_TPC"),)
  
   IF (GetNewPar("MV_EASYFIN","N")="S" .Or. lAvIntDesp) .AND. !(cPaisLoc="BRA") //wfs 03/07/2014 - atualização dos valores para integração via EAI
      SWH->(DBSEEK(XFILIAL("SWH")+Work_1->WKPO_NUM+STR(Work_1->WKCONT_IP,nTamCont)))
      aItensDesp:={}
      SYD->(DBSEEK(xfilial("SYD")+Work_1->WKNBM))
      DO WHILE !SWH->(EOF()) .AND. XFILIAL("SWH")+Work_1->WKPO_NUM+STR(Work_1->WKCONT_IP,nTamCont) == SWH->WH_FILIAL + SWH->WH_PO_NUM+STR(SWH->WH_NR_CONT,nTamCont)
            SYB->(DBSEEK(xFilial("SYB")+SWH->WH_DESPESA))
            IF SWH->WH_DESPESA='101' 
               SWH->(DBSKIP())
               LOOP
            ENDIF                                                                       
            // Verifica Saldo em Quantidade
            SYB->(DBSEEk(XFILIAL("SYB")+SWH->WH_DESPESA ))
            IF SYB->(EOF())
               SWH->(DBSKIP())
               LOOP
            ENDIF                                                                       

             // Adiciona Itens para Previsao
            nAsc:=ASCAN(aItensDesp, {|cAsc| cAsc[1]==SWH->WH_DESPESA } )
            
            IF nAsc == 0
            
               IF !EMPTY(SYB->YB_IMPINS)
                  AADD(aItensDesp,{ SWH->WH_DESPESA, SWH->WH_VALOR , SYB->YB_IMPINS } )
               ENDIF   
            ENDIF                 
       
            SWH->(DBSKIP())
      
      ENDDO
        

       aCalcImp:=CalcImpGer(SYD->YD_TES,,,Work_1->WKFOB_TOT,,,,aItensDesp,Work_1->WKNBM,nValfobtot,cUltimoItem )         
 
       For nimp:=1 to Len(aCalcImp[6])
       If Subs(aCalcImp[6,nImp,5],1,2) == "SS"
          nSinal	:=	 1
       ElseIf Subs(aCalcImp[6,nImp,5],1,2) == "NN"
	      nSinal	:=	-1
       Else
          nSinal	:= 0
	   Endif
       IF nSinal>0              
          nOrdSFC:=SFC->(INDEXORD())  
          SFC->(DBSETORDER(2))
          SFC->(DBSEEK(XFILIAL("SFC")+SYD->YD_TES+aCalcImp[6,nImp,1]))
          SWH->(RecLock("SWH",.T.))
          SWH->WH_FILIAL  := xFilial("SWH")
          SWH->WH_PO_NUM  := SW2->W2_PO_NUM
          SWH->WH_NR_CONT := Work_1->WKCONT_IP                                     
          SWH->WH_DESPESA := "2"+SFC->FC_SEQ
          //IF ASC(RIGHT(aCalcImp[6,nImp,6],1))>=65
          //   SWH->WH_DESPESA :='20'+subst(aCalcImp[6,nImp,6],10,1)
          //ELSE
          //   SWH->WH_DESPESA :='2'+STRZERO(3+VAl( RIGHT(aCalcImp[6,nImp,6],1) ),2)
          //ENDIF   
          SWH->WH_MOEDA   := cMOEDAEST
          SWH->WH_PER_DES := aCalcImp[6,nImp,2]
          SWH->WH_VALOR   := aCalcImp[6,nImp,4]*nSinal
          SWH->WH_DESC    := aCalcImp[6,nImp,1] 
          If SWH->(FieldPos("WH_DTAPUR")) # 0
             SWH->WH_DTAPUR := dDataConTx
          EndIf
          SWH->(MsUnlock())
          SFC->(DBSETORDER(nOrdSFC))
          
          //ISS - 19/10/2010 - Para a gravação de novos campos na tabela SWH
          If(EasyEntryPoint("EICTP251"),ExecBlock("EICTP251",.F.,.F.,"TPC251CALCTAB_GRV_SWH"),)
                    
       ENDIF 
       
      Next nImp   
       
   ENDIF
  
   Work_1->(DBSKIP())
         
ENDDO

//RRV - 27/12/2012 - Tratamento de acerto das despesas do pré-calculo.
SWH->(DbSetOrder(1))
For n := 1 to len (aRateio)
   If SWH->(DBSEEK(xFilial("SWH")+SW2->W2_PO_NUM+STR(aRateio[n][2],4,0)+aRateio[n][1]))   
      nPos := aScan(aRateio, {|x| x[1] == SWH->WH_DESPESA})
      nPos2:= aScan(aTpc,{|x| x[3] == SWH->WH_DESPESA})
      If nPos > 0 .And. nPos2 > 0 .And. aTpc[nPos2][5] <> 0
         If AllTrim(aTpc[nPos2][4]) == "R$" .And. aTpc[nPos2][4] == aRateio[nPos][6]
            If aTpc[nPos2][5] - aRateio[nPos][5] <> 0
               nDif = aTpc[nPos2][5] - aRateio[nPos][5]         
               SWH->(RecLock("SWH",.F.))
               SWH->WH_VALOR := SWH->WH_VALOR + (nDif / MTx_Usd_Pc)
               SWH->WH_VALOR_R := SWH->WH_VALOR_R + nDif
            EndIf
         ElseIf (aTpc[nPos2][4] == cMoedaEst) .And. (aTpc[nPos2][4] == aRateio[nPos][6])
            If aTpc[nPos2][5] - aRateio[nPos][4] <> 0
               nDif = aTpc[nPos2][5] - aRateio[nPos][4]
               SWH->(RecLock("SWH",.F.))
               SWH->WH_VALOR := SWH->WH_VALOR + nDif
               SWH->WH_VALOR_R := SWH->WH_VALOR_R + (nDif * MTx_Usd_Pc)                                              
            EndIf
         EndIf
      EndIf 
   Endif
Next n
   
SW2->(RecLock("SW2",.F.))
SW2->W2_DT_PC   := dDataBase
SW2->W2_TAB_PC  := TPr_Cal
SW2->W2_STAT_PC := "1"
SW2->(MsUnlock())

return .t.
/*
|* Função: TP251Seguro(@aTPC,nInd_Seguro)
|* Pegar o valor do seguro e preencher no array antes de tratamento para gravar valores na work do pré caulculo.
|* MPG - 05/07/2021
*/
function TP251Seguro(aTPC,nInd_Seguro)
   Local nValor := 0
   Local nValor_Seguro

   IF nInd_Seguro != 0 .AND. !EMPTY(SW2->W2_SEGURIN)
      //PARA ZERAR O PERCENTUAL APLICADO pela tabela pré calculo
      aTPC[nInd_Seguro][6]:=0
      aTpc[nInd_Seguro][4]:=SW2->W2_MOEDA

      IF aTPC[nInd_Seguro][11] # "1"

         nValor_Seguro := SW2->W2_SEGURIN

         If nValor_Seguro # 0
            aTPC[nInd_Seguro][5] := nValor_Seguro
            aTPC[nInd_Seguro][11] := "1"  // Caracter diferente de 2 para ser caculado os valores maximo e minino para o seguro.
         EndIf

         IF aTPC[nInd_Seguro][5] < aTPC[nInd_Seguro][10] // SWI->WI_VAL_MIN
            aTPC[nInd_Seguro][5] := aTPC[nInd_Seguro][10]
         ElseIF aTPC[nInd_Seguro][5] > aTPC[nInd_Seguro][9] .AND. aTPC[nInd_Seguro][9] # 0 // SWI->WI_VAL_MAX
            aTPC[nInd_Seguro][5] := aTPC[nInd_Seguro][9]
         ENDIF

         nValor := aTPC[nInd_Seguro][5]

      ENDIF
   ENDIF
return nValor
*------------------------------------------------------------*
FUNCTION TPC251Grava(PDESP,PDATA,PVALOR,PTAB,PPERC,cFilSWH, nDecWHVal, nDecWHValR,lConverte )
*------------------------------------------------------------*
LOCAL b_US, nTX_US // RA - 12/08/2003 - O.S. 746/03 e 748/03 //RRV - 27/12/2012
Local nPos, nPos2 //RRV - 27/12/2012
Default lConverte := .F.
SWH->(RecLock("SWH",.T.))
SWH->WH_FILIAL  := cFilSWH//RMD - 21/03/19 - xFilial("SWH")
SWH->WH_PO_NUM  := SW2->W2_PO_NUM
SWH->WH_NR_CONT := Work_1->WKCONT_IP
SWH->WH_DESPESA := PDESP
SWH->WH_MOEDA   := cMOEDAEST
SWH->WH_PER_DES := PPERC

MTx_Usd_Pc:=nTMExtDConTx//RMD - 21/03/19 - EVAL(b_US,dDataConTx) // RA - 13/08/2003 - O.S. 746/03 e 748/03
If lConverte //lConverte = .T., o valor deve ser convertido pra dolar
   SWH->WH_VALOR   := Round(PVALOR * MTx_Usd_Pc, nDecWHVal)
Else
   SWH->WH_VALOR   := PVALOR
EndIf
//If SWH->(FieldPos("WH_DTAPUR")) # 0 RMD - 21/03/19 - Campo já é padrão desde 12.1.14
   SWH->WH_DTAPUR := dDataConTx
//EndIf
   b_US:={|dt| IF(EMPTY(nTX_US:=BuscaTaxa(cMOEDAEST,dt,.T.,.F.,.T.)),;
                        nTX_US:=BuscaTaxa(cMOEDAEST,dt,.T.,.F.,.T.),) , nTX_US }

   //SWH->WH_VALOR_R := NOROUND(SWH->WH_VALOR * MTx_Usd_Pc,2) //ROUND(SWH->WH_VALOR * MTx_Usd_Pc,3)       // GFP - 25/02/2013 //comentado por WFS
   If lConverte // lConverte = .T., o valor deve ser convertido pra dolar, neste caso, como grava o valor em real, o valor ja esta em real
      SWH->WH_VALOR_R := PVALOR
   Else
      SWH->WH_VALOR_R := ROUND(SWH->WH_VALOR * MTx_Usd_Pc,nDecWHValR/*AvSX3("WH_VALOR_R", AV_DECIMAL) RMD - 21/03/19*/)
   EndIf 
   //ISS - 19/10/2010 - Para a gravação de novos campos na tabela SWH
   If(EasyEntryPoint("EICTP251"),ExecBlock("EICTP251",.F.,.F.,"TPC251GRAVA_GRV_SWH"),)

SWH->(MsUnlock())

//RRV - 27/12/2012 - Controle para de rateio para acerto das despesas na impressão do pré-calculo   
If (nPos := aScan(aRateio, {|x| x[1] == SWH->WH_DESPESA})) == 0
   If (nPos2 := aScan(aTpc,{|x| x[3] == SWH->WH_DESPESA})) > 0
      //aAdd(aRateio,{PDESP,Work_1->WKCONT_IP,1,Round(SWH->WH_VALOR,2),Round(SWH->WH_VALOR_R,2),aTpc[nPos2][4]}) //RRV - 18/01/2013 - Arredonda o valor para a correta impressão. //comentado por WFS
      aAdd(aRateio,{PDESP,Work_1->WKCONT_IP,1,Round(SWH->WH_VALOR,nDecWHVal/*AvSX3("WH_VALOR", AV_DECIMAL) RMD - 21/03/19*/),Round(SWH->WH_VALOR_R,nDecWHValR/*AvSX3("WH_VALOR_R", AV_DECIMAL) RMD - 21/03/19*/),aTpc[nPos2][4]}) //RRV - 18/01/2013 - Arredonda o valor para a correta impressão.
   EndIf
Else
   aRateio[nPos][3] += 1
   aRateio[nPos][4] += SWH->WH_VALOR
   aRateio[nPos][5] += SWH->WH_VALOR_R
EndIf

If aScan(aDespesas,{|x| x == PDESP}) == 0   // GFP - 03/04/2013
   aAdd(aDespesas, PDESP)  
EndIf
RETURN NIL
*--------------------------*
FUNCTION TPC251Con(PCod_Tab)
*--------------------------*
LOCAL  oldselect:=ALIAS(),;
       _recno:=SWI->(RECNO()), SaveTab:=SWI->WI_TAB,nIndex, cAlias:="SWI", cDescTab

LOCAL PMensagem1 := STR0033, oDlgTab //"PRE-CALCULO EFETIVADO"
LOCAL oPanTab //LRL 13/04/04 
LOCAL Tb_Campos:={ {{||TPC251TB_Desp()},,STR0053} ,; //"Despesa"
                   {{||TPC251TB_Desp('D')},,STR0054},; //"Descricao"
                   {{||IF(!EMPTY(WI_PERCAPL),'% '+TRAN(WI_PERCAPL,'@E 999.9999')+SPACE(15),STR0168+WI_MOEDA+' '+TRAN(WI_VALOR,cPicture))},, " " },; //LGS-25/07/2016
                   {{||TRAN(WI_DESPBASE,'@R 9.99/9.99/9.99')},, STR0055 }} //"Despesas Base"

cDescTab:=LEFT(SWI->WI_DESC,30)
SaveTab:=SW2->W2_TAB_PC
DBSELECTAREA(cAlias)
DBSETORDER(1)
DBSEEK(xFilial()+SaveTab)

SYQ->(DBSETORDER(1))
//SYQ->(DBSEEK(xFilial("SYQ")+SW2->W2_TIPO_EM))
SYQ->(DBSEEK(xFilial("SYQ")+if(empty(SWI->WI_VIA),SW2->W2_TIPO_EM,SWI->WI_VIA)))

oMainWnd:ReadClientCoors()
DEFINE MSDIALOG oDlgTab TITLE cCadastro ;
       FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
 	       OF oMainWnd PIXEL   
@ 00,00 MsPanel oPanTab Prompt "" Size 60,64 of oDlgTab //LRL 13/04/04 - Painel para alinhamento em Ambiente MDI
@ 07,006 SAY STR0020 SIZE 35,8 of oPanTab PIXEL //"No. P.O."
@ 07,120 SAY STR0021     SIZE 35,8  of oPanTab  PIXEL //"Data"

@ 05,152 MSGET SW2->W2_PO_DT        SIZE /*30*/40,8  WHEN .F.  of oPanTab  PIXEL      // GFP - 25/02/2013 
@ 05,040 MSGET TNr_PO  PICT _PictPO SIZE /*40*/50,8  WHEN .F.  of oPanTab  PIXEL      // GFP - 25/02/2013 

@ 020,006 SAY STR0034 SIZE 40,8  of oPanTab  PIXEL //"Tab.Pre-Calc"
@ 07,208  SAY STR0035    SIZE 40,8  of oPanTab  PIXEL //"Gerado em"
@ 033,006 SAY STR0036  SIZE 40,8  of oPanTab  PIXEL //"Cond. Pagto"
@ 033,200 SAY STR0040     SIZE 35,8  of oPanTab  PIXEL //"Mensagem"

@ 031,232 MSGET PMensagem1  WHEN .F. SIZE 80,8  of oPanTab PIXEL
                                                            
@ 033,040 SAY TRAN(SW2->W2_COND_PA, cPicCond) SIZE 50,8  of oPanTab PIXEL //DRL - 11/05/09
@ 033,064 SAY '/ '+TRAN(SW2->W2_DIAS_PA,'999')   SIZE 50,8  of oPanTab PIXEL

@ 046,006 SAY STR0037+ALLTRIM(LEFT(SYQ->YQ_DESCR,11))+STR0056+ALLTRIM(SW2->W2_ORIGEM)+STR0057+ALLTRIM(SW2->W2_DEST)               SIZE 99,8  of oPanTab  PIXEL //"Via "###" de "###" para "
@ 054,006 SAY STR0041+SW2->W2_FORN+' '+IF(EICLOJA(),SW2->W2_FORLOJ,"")+' '+IF(SA2->(DBSEEK(xFilial("SA2")+SW2->W2_FORN+EICRetLoja("SW2","W2_FORLOJ"))),LEFT(SA2->A2_NREDUZ,10),SPACE(10)) SIZE 99,8  of oPanTab  PIXEL //"Fornecido por "

@ 018,040 MSGET SaveTab            WHEN .F. SIZE 030,8  of oPanTab  PIXEL
@ 018,080 MSGET oDesc VAR cDescTab WHEN .F. SIZE 100,8  of oPanTab  PIXEL
@ 05 ,240 MSGET SW2->W2_DT_PC      WHEN .F. SIZE /*030*/40,8  of oPanTab  PIXEL      // GFP - 25/02/2013 

oMark:= MsSelect():New(cAlias,,,TB_Campos,@lInverte,@cMarca,{80,1,(oDlgTab:nClientHeight-2)/2,(oDlgTab:nClientWidth-2)/2},"TP251Filtra","TP251Filtra")
oPanTab:Align:=CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
ACTIVATE MSDIALOG oDlgTab ON INIT (EnchoiceBar(oDlgTab,{||oDlgTab:end()},; 
                                                      {||oDlgTab:end()})) //LRL 13/04/04 - Alinhamento MDI  //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT                                                  

SWI->(DBGOTO(_recno))
DBSELECTAREA("Work_1")
RETURN NIL
*---------------------------------------*
Function TP251Filtra()
*---------------------------------------*
RETURN xFilial('SWI')+SW2->W2_TAB_PC

*--------------------------*
FUNCTION TPC251TB_Desp(Tipo)
*--------------------------*
IF Tipo == NIL
   SYB->(DBSEEK(xFilial()+SWI->WI_DESP))
   RETURN TRAN(SWI->WI_DESP,'@R 9.99')
ELSE
   RETURN SYB->YB_DESCR
ENDIF


*---------------------*
Function TPC251ValPO()
*---------------------*

IF EMPTY(mv_par01)
   Help("", 1, "AVG0000564")//MsgInfo(STR0058,STR0019) //"Pedido não preenchido"###"Informação"
   RETURN .F.
ENDIF
IF ! SW2->(DBSEEK(xFilial("SW2")+mv_par01))
   Help("", 1, "AVG0000566")//MsgInfo(STR0059,STR0019) //"Pedido não cadastrado"###"Informação"
   RETURN .F.
ENDIF
RETURN .T.

*--------------------------------------------*
function TPC251Tab(oDesc,cDescTab,oDlg,nOpca)
*--------------------------------------------*
IF EMPTY(TPr_Cal)
   Help("", 1, "AVG0000567")//MsgInfo(STR0060,STR0019) //"TABELA DE PRE-CALCULO NÃO PREENCHIDA"###"Informação"
   RETURN .F.
ENDIF
IF !SWI->(dbSetOrder(1),DBSEEK(xFilial("SWI")+TPr_Cal))   // AAF - 07/10/2013
   Help("", 1, "AVG0000568")//MsgInfo(STR0061,STR0019) //"TABELA DE PRE-CALCULO NÃO CADASTRADA"###"Informação"
   RETURN .F.
ENDIF

IF !EMPTY(SW2->W2_TAB_PC) .AND. TPr_Cal <> SW2->W2_TAB_PC
   IF !MsgYesNo(STR0062,STR0049)// # "S" //"Confirma a substituição da tabela de Pre-Calculo ?"###"Pre-Calculo"
      RETURN .F.
   ENDIF
ENDIF

cDescTab:=LEFT(SWI->WI_DESC,30)
oDesc:Refresh()

RETURN .T.

*-------------------------*
Function TPC251GrPreCalc(nQtdeSald, aBuffers)//RMD - 21/03/19 - Recebe o saldo na chamada para não precisar recalcular, Recebe o Buffer definido na função TPC251VerCon
*-------------------------*
LOCAL _PictItem := ALLTRIM(X3Picture("B1_COD"))
Local aValBufNcm := {}

IF  lProcessa
    ProcRegua(nCont)
    lProcessa:=.F.
ENDIF

IncProc(STR0063+TRAN(W3_COD_I,_PictItem)) //"Gravando Item: "
SB1->(DBSEEK(xFIlial("SB1") + SW3->W3_COD_I)) 
//RMD - 08/04/19 - Cria um buffer para os dados de NCM
If aBuffers <> Nil
   aValBufNCM := {}
   If aBuffers[1]:Get("SW3"+AllTrim(Str(SW3->(Recno()))), @aValBufNcm)
      cNBM := aValBufNCM[3]
   Else
      cNBM := Busca_NCM("SW3")
      aBuffers[1]:Set("SW3"+AllTrim(Str(SW3->(Recno()))), {"SW3", SW3->(Recno()), cNBM, 0})
   EndIf
Else
   cNBM := Busca_NCM("SW3")
EndIf

IF .NOT. Work_1->(DBSEEK("S" + SW3->W3_COD_I+cNBM+If(lRegTriPO,"WKGRUPORT",""))) //TDF - 26/11/12 - Acrescenta a TEC+EX-NCM+EX-NBM  //NCF - 24/01/2013 - Acrescenta o Reg. Trib.
   //SA5->(DBSEEK(xFilial("SA5")+SW3->W3_COD_I+SW3->W3_FABR+SW3->W3_FORN))        
   //EICSFabFor(xFilial("SA5")+SW3->W3_COD_I+SW3->W3_FABR+SW3->W3_FORN, EICRetLoja("SW3","W3_FABLOJ"), EICRetLoja("SW3","W3_FORLOJ")) RMD - 21/03/19 - O posicionamento da tabela SA5 não é utilziado, além disso a função BUSCA_UM já efetua o mesmo posicionamento

   Work_1->(DBAPPEND())
   Work_1->WKPO_NUM  := SW2->W2_PO_NUM
   Work_1->WKFOB_UNT := SW3->W3_PRECO
   Work_1->WKFABR    := SW3->W3_FABR
   IF EICLOJA()
      Work_1->W3_FABLOJ := SW3->W3_FABLOJ
   ENDIF
   Work_1->WKCONT_IP := IF(SW3->W3_NR_CONT > 0,SW3->W3_NR_CONT,VAL(SW3->W3_POSICAO)) // TDF - 23/04/2012
   Work_1->WKCOD_I   := SW3->W3_COD_I
   If lAvFluxo//RMD - 21/03/19 - Este campo não será persistido, então não carrega quando for executado sem tela
      //Se for carregar a descrição, utiliza a resumida do SB1 por performance, evitando MSMM
      Work_1->WKDESCR   := Posicione("SB1", 1, xFilial("SB1")+Work_1->WKCOD_I, "B1_DESC")//IF(SB1->(DBSEEK(xFilial("SB1")+Work_1->WKCOD_I)),MSMM(SB1->B1_DESC_GI,30,1),SPACE(30))
   EndIf
   Work_1->WKNBM     := cNBM
   
   //RMD - 21/03/19 - Buffer para reaproveitar as informações caso o produto/fab/forn se repita entre os itens
   If aBuffers <> Nil
      cUnid := ""
      If !aBuffers[2]:Get(SW3->W3_COD_I+SW3->W3_FABR+SW3->W3_FORN+SW3->W3_CC+SW3->W3_SI_NUM+SW3->W3_FABLOJ+SW3->W3_FORLOJ, @cUnid)
         cUnid := BUSCA_UM(SW3->W3_COD_I+SW3->W3_FABR +SW3->W3_FORN,SW3->W3_CC+SW3->W3_SI_NUM,SW3->W3_FABLOJ,SW3->W3_FORLOJ)
         aBuffers[2]:Set(SW3->W3_COD_I+SW3->W3_FABR+SW3->W3_FORN+SW3->W3_CC+SW3->W3_SI_NUM+SW3->W3_FABLOJ+SW3->W3_FORLOJ, cUnid)
      EndIf
   Else
      cUnid := BUSCA_UM(SW3->W3_COD_I+SW3->W3_FABR +SW3->W3_FORN,SW3->W3_CC+SW3->W3_SI_NUM,SW3->W3_FABLOJ,SW3->W3_FORLOJ)
   EndIf

   Work_1->WKUNID := cUnid
   
   Work_1->WKFLAG    := "A"
   Work_1->WKFLAGWIN := cMarca //DRL - 12/05/09
   Work_1->WKTELA    := "S"
   Work_1->WKPOSICAO := SW3->W3_POSICAO
   If lRegTriPO                                     //NCF - 08/02/2013 - Gravação do Reg. Tributação
      Work_1->WKGRUPORT := SW3->W3_GRUPORT
   EndIf   
ENDIF
If nQtdeSald == Nil
   nQtdeSald:=TPC251SALDOPC(SW2->W2_PO_NUM)//RMD - 22/03/19 - Movido para o parâmetro
EndIf
IF lExiste_Midia
  SB1->(DBSEEK(xFilial("SB1")+SW3->W3_COD_I))
  IF SB1->B1_MIDIA $ cSim
    Work_1->WK_QTMIDIA := SB1->B1_QTMIDIA
    Work_1->WKICM_MID  := EasyGParam("MV_ICMSMID") * Work_1->WK_QTMIDIA * nQtdeSald
//  Work_1->WKBASEMID  := Work_1->WK_QTMIDIA * SW3->W3_QTDE * SW2->W2_VLMIDIA   //FOB MIDIA
    Work_1->WKBASEMID  := Work_1->WK_QTMIDIA * nQtdeSald * SW2->W2_VLMIDIA   //FOB MIDIA
//  nTaxaMid:=BuscaTaxa(SW2->W2_MOEDA,SW2->W2_PO_DT)
//  nTaxaMid:=BuscaTaxa(SW2->W2_MOEDA,dDataBase) // RA - 13/08/2003 - O.S. 746/03 e 748/03
    nTaxaMid:=If(SW2->W2_MOEDA==cMoedaEst,nTMExtDConTx,BuscaTaxa(SW2->W2_MOEDA,dDataConTx,.T.,.F.,.T.)) // RA - 13/08/2003 - O.S. 746/03 e 748/03
    nTotBaseMid += Work_1->WKBASEMID
  ENDIF
ENDIF

Work_1->WKFOB_TOT += (nQtdeSald * SW3->W3_PRECO)
Work_1->WKQTD_ACU += nQtdeSald

//AAF 03/02/2017 - Ajuste para considerar os campos de peso do pedido/li quando preenchidos.
If SW3->(FieldPos("W3_PESOL")) > 0 .AND. !Empty(SW3->W3_PESOL)
  Work_1->WKPESO_L := SW3->W3_PESOL
Else
  Work_1->WKPESO_L := B1PESO(SW3->W3_CC,SW3->W3_SI_NUM,SW3->W3_COD_I,SW3->W3_REG,SW3->W3_FABR,SW3->W3_FORN,EICRetLoja("SW3","W3_FABLOJ"),EICRetLoja("SW3","W3_FORLOJ"))
EndIf

nQtdeAcumulada += nQtdeSald               // CAF OS.871/98 07/08/1998 15:13
IF EasyGParam("MV_EIC0012",,.F.)               //GFP - 14/10/2013 - Considerar para cálculo de Frte o Peso Bruto do Cadastro de Produtos
   nPesoAcumulado += SB1->B1_PESBRU * nQtdeSald
Else
   nPesoAcumulado += Work_1->WKPESO_L * nQtdeSald // CAF OS.871/98 07/08/1998 15:13   // LDR - OS 1217/03 
EndIF
nFobAcumulado += (nQtdeSald * SW3->W3_PRECO)                               

If EasyEntryPoint("EICTP251") // RRV - 26/09/2012
   Execblock("EICTP251",.F.,.F.,"ALTPESO")
EndIf

nValFobTot += Round(nQtdeSald * SW3->W3_PRECO,2) //AAF 27/11/08

//cChPOSIPI:=Busca_NCM("SW3") RMD - 09/04/19 - A informação já foi carregad na variável cNBM

//SYD->(DBSEEK(xFilial()+cChPOSIPI))
//MPerc_II :=SYD->YD_PER_II                     // GFP 11/02/2011
//MPerc_IPI:=SYD->YD_PER_IPI

If lRegTriPO	
   // *** GFP 11/02/2011 :: 16:02
   EIJ->(DbSetOrder(2))
   EIJ->(DbSeek(xFilial() + SW3->(W3_PO_NUM + W3_GRUPORT)))
   MPerc_II := EIJ->EIJ_ALI_II
   MPerc_IPI:= EIJ->EIJ_ALAIPI
Else
   SYD->(DBSEEK(xFilial()+/*cChPOSIPI*/cNBM))                   
   MPerc_II :=SYD->YD_PER_II
   MPerc_IPI:=SYD->YD_PER_IPI
EndIf
// *** Fim GFP 11/02/2011

IF lExiste_Midia .AND. SB1->B1_MIDIA $ cSim
  nValor_II := (Work_1->WK_QTMIDIA * nQtdeSald * SW2->W2_VLMIDIA) * MPerc_II /100
  nII_Acumulado += nValor_II
  nIpiAcumulado += ((Work_1->WK_QTMIDIA * nQtdeSald * SW2->W2_VLMIDIA )+nValor_II) * MPerc_IPI /100

ELSE
  IF IPIPauta()
//   nIpiAcumulado +=  ROUND(SW3->W3_QTDE * IPIPauta(.F.) / BuscaTaxa(SW2->W2_MOEDA,SW2->W2_PO_DT),2)
//   nIpiAcumulado +=  ROUND(nQtdeSald * IPIPauta(.F.) / BuscaTaxa(SW2->W2_MOEDA,dDataBase),2) // RA - 13/08/2003 - O.S. 746/03 e 748/03
     nIpiAcumulado +=  ROUND(nQtdeSald * IPIPauta(.F.) / If(SW2->W2_MOEDA==cMoedaEst,nTMExtDConTx,BuscaTaxa(SW2->W2_MOEDA,dDataConTx,.T.,.F.,.T.)),2) // RA - 13/08/2003 - O.S. 746/03 e 748/03
  ELSE
  nIpiAcumulado += SW3->W3_PRECO * nQtdeSald * MPerc_IPI /100
  ENDIF
  nII_Acumulado += SW3->W3_PRECO * nQtdeSald * MPerc_II  /100
ENDIF
RETURN .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³TPC251Print³ Autor ³ ALEX WALLAUER         ³ Data ³ 09/11/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Impressao do Relatorio de Pre-Calculo/Custo Realizado       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC  /  V407                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*--------------------------------*/
FUNCTION TPC251Print(PTipo,PHawb)
*--------------------------------*

#DEFINE COURIER_07 oFont1
#DEFINE COURIER_10 oFont2

//mjb160300 PRINT oPrn NAME ""
//mjb160300       oPrn:SetPortrait()
//mjb160300 ENDPRINT

AVPRINT oPrn NAME Titulo

   DEFINE FONT oFont1  NAME "Courier New" SIZE 0,07 OF oPrn
   DEFINE FONT oFont2  NAME "Courier New" SIZE 0,10 OF oPrn

   AVPAGE

     Processa({||TPC251Rel(PTipo,PHawb)},Titulo)

   AVENDPAGE


AVENDPRINT

oFont1:End()
oFont2:End()

Return .T.

*------------------------------*
FUNCTION TPC251Rel(PTipo,PHAWB)
*------------------------------*

LOCAL OldRecno := Work_1->(RECNO()), L1:=09, C1:=25,;
      aAPE:={}, aPGI:={}, aCambio:={}, aLC:={},;
      aSeguro:={}, Tb_Hawb:={}

IF MParam = Realizado .AND. PTipo == Por_PO

   DBSELECTAREA("Work_1")
   DBGOTOP()

   ProcRegua(Work_1->(LASTREC()))

   WHILE ! EOF()

     IncProc(STR0073+Work_1->WKCOD_I) //"Processando Item: "

     IF Work_1->WKFLAG <> "A" .OR. EMPTY(Work_1->WKHAWB)
        DBSKIP() ; LOOP
     ENDIF

     SW5->(DBSETORDER(2))
     SW5->(DBSEEK(xFilial("SW5")+Work_1->WKHAWB))
     SWA->(DBSEEK(xFilial("SWA")+Work_1->WKHAWB))
     SWB->(DBSEEK(xFilial("SWB")+Work_1->WKHAWB))

     IF ASCAN(Tb_Hawb,{|aHawb|aHawb:APEHAWB = Work_1->WKHAWB}) = 0
        AADD(Tb_Hawb,{Work_1->WKHAWB})
     ENDIF

     IF ASCAN(aAPE,{|aHAWB| aHAWB:APEHAWB = Work_1->WKHAWB}) = 0
        DO WHILE ! SWB->(EOF()) .AND. SWB->WB_HAWB = Work_1->WKHAWB .AND. SWB->WB_FILIAL == xFilial("SWB")
           
           //** GFC - 02/12/05 - Não considerar registros com tipo de contrato 3 ou 4
           If lWB_TP_CON .and. SWB->WB_TP_CON $ ("3/4")
              SWB->(dbSkip())
              Loop
           EndIf
           //**
           
           AADD(aAPE,{Work_1->WKHAWB,SWB->WB_NUM,SWB->WB_DT,SWB->WB_BANCO,;
                                     SWA->WA_CEDENTE,SWB->WB_DT_VEN})

           IF ! EMPTY(SWB->WB_CA_NUM)
              AADD(aCambio,{Work_1->WKHAWB,SWB->WB_CA_NUM,SWB->WB_CA_DT,;
                                           SWB->WB_CA_TX ,SWB->WB_FOBMOE})
           ENDIF

           IF ! EMPTY(SWB->WB_LC_NUM) .AND.;
              ASCAN(aLC,{|LC| LC:APELC_NUM = SWB->WB_LC_NUM}) = 0
              SWC->(DBSEEK(xFilial("SWC")+SWB->WB_LC_NUM))
              AADD(aLC,{Work_1->WKHAWB,SWC->WC_LC_NUM,;
                                       SWC->WC_DT_EMI,;
                                       SWC->WC_DT_VEN,;
                                       SWC->WC_BANCO})
           ENDIF
           SWB->(DBSKIP())
        ENDDO

        DO WHILE ! SW5->(EOF()) .AND. SW5->W5_HAWB = Work_1->WKHAWB .AND. SW5->W5_FILIAL == xFilial("SW5")
          IF ASCAN(aPGI,{|PGI| PGI[1] = SW5->W5_PGI_NUM }) = 0
             AADD (aPGI,{SW5->W5_PGI_NUM,NIL,NIL})
             SW4->(DBSEEK(xFilial("SW4")+SW5->W5_PGI_NUM))
             IF ! EMPTY(SWA->WA_SE_AP) .OR. ! EMPTY(SW4->W4_AVERBNO)
                AADD(aSeguro,{Work_1->WKHAWB,SWA->WA_SE_AP,  SWA->WA_SE_DT,;
                                             SWA->WA_SE_VEN, SW4->W4_AVERBNO,;
                                             SW4->W4_AVERBDT,SWA->WA_SE_AVD,;
                                             SWA->WA_SE_AVDD,SWA->WA_SE_VAL,;
                                             SWA->WA_SE_FRQ})
             ENDIF
          ENDIF
          SW5->(DBSKIP())
        ENDDO
     ENDIF

     DBSKIP()
   ENDD
   Work_1->(DBGOTO(OldRecno))
ENDIF

AEVAL(aPGI,{|PGI| SW4->( DBSEEK(xFilial("SW4")+PGI[1]) ), PGI[1]:=SW4->W4_GI_NUM  ,;
                  PGI[2]  :=SW4->W4_DT        , PGI[3]:=SW4->W4_DT_VEN  })


nLimPage := 2955
nColIni  := 0001
nColFim  := 2320
lPrimPag := .T.
nPulaLin1:= 25
nPulaLin2:= 40
nPulaLin3:= 50
nAuxLin1 := nAuxLin2 := 0
nAuxLin3 := nAuxLin4 := MPag := 0

MLin  :=99999
nCol2 :=QC210xCol(029)
nCol3 :=QC210xCol(049)
nCol4 :=QC210xCol(069)
nCol5 :=QC210xCol(089)
nCol6 :=QC210xCol(109)
nCol7 :=QC210xCol(124)
nCol8 :=QC210xCol(029)
nCol9 :=QC210xCol(049)
nCol10:=QC210xCol(069)
nCol11:=QC210xCol(089)

IF MParam==Pre_X_Real
   nCol2 :=QC210xCol(025)
   nCol3 :=QC210xCol(041)
   nCol4 :=QC210xCol(057)
   nCol5 :=QC210xCol(065)
   nCol6 :=QC210xCol(083)
   nCol7 :=QC210xCol(101)
   nCol8 :=QC210xCol(110)
   nCol9 :=QC210xCol(117)
   nCol10:=QC210xCol(124)
   nCol11:=QC210xCol(132)
ENDIF

nCol2_I:=QC210xCol(033)
nCol3_I:=QC210xCol(038)

IF !MParam==Pre_Calculo
   nCol4_I:=QC210xCol(049)
ELSE
   nCol4_I:=nCol3_I
ENDIF

nCol5_I:=QC210xCol(061)
nCol6_I:=QC210xCol(074)

IF PTipo # Por_Item
   nCol7_I:=QC210xCol(090)
   nCol8_I:=QC210xCol(106)
   nCol9_I:=QC210xCol(122)
ELSE
   nCol7_I:=nCol2_I
   nCol8_I:=nCol3_I
   nCol9_I:=nCol4_I
ENDIF

Work_2->(avzap())

TPC251_Apuracao(PTipo)

If(Len(aDespesas) > 0, TP251AjustVlr(),) // GFP - 04/04/2013

DBSETORDER(2)

DBGOTOP()

ProcRegua(Work_1->(LASTREC()))

WHILE ! Work_1->(EOF())

  IF PTipo # Por_Item
     IncProc(STR0074+Work_1->WKCOD_I) //"Imprimindo Item: "
  ENDIF

  IF PTipo == Por_Item
     IF Work_1->WKFLAG <> "A"
        Work_1->(DBSKIP()) ; LOOP
     ENDIF
  ENDIF

  TItem := Work_1->WKCOD_I

  IF MLin > nLimPage
     TPC251Cab(PTipo,PHAWB)
  ENDIF

  DBSELECTAREA("Work_2")

  IF PTipo == Por_Item
     IF ! Work_2->(DBSEEK(TItem))
          Work_1->(DBSKIP()) ; LOOP
     ENDIF
  ELSE
     Work_2->(DBGOTOP())
  ENDIF

  IF MParam ==Pre_X_Real
     TPC251DesCab()
  ELSE
     TPC251Des_CR(PTipo)
  ENDIF

  TPC251DetDesp(PTipo,PHAWB)

  IF PTipo == Por_Item

     TPC251Colunas(1)
     IF MLin > (nLimPage-nPulaLin1*2-nPulaLin3*2)
        TPC251Cab(PTipo,PHAWB)
     ENDIF
     TPC251CabDetI(PTipo)
     TPC251ImprItens(PTipo,PHAWB)
     //oPrn:Box( MLin,nColIni,MLin+1,nColFim)
     MLin:=99999

  ELSE

     EXIT

  ENDIF

END


IF MPag <> 0 .AND. PTipo == Por_PO
   Work_1->(DBGOTOP())
   ProcRegua(Work_1->(LASTREC()))
   TPC251ImprItens(PTipo,PHAWB)
			//oPrn:Box( MLin,nColIni,MLin+1,nColFim)
   MLin+=nPulaLin1
ENDIF

IF !EMPTY(aPGI)
   MLin := 99999
   TPC251_APE(PHAWB,aPGI,aAPE,aCambio,aLC,aSeguro,Tb_Hawb,PTipo)
ENDIF

Work_1->(DBSETORDER(1))
Work_1->(DBGOTO(OldRecno))

RETURN .T.
*------------------------------*
FUNCTION TPC251Cab(PTipo,PHAWB)
*------------------------------*
LOCAL _PictItem := ALLTRIM(X3Picture("B1_COD"))
LOCAL MSubCab:=IF(PTipo == Por_Item,STR0075,; //"P O R   I T E M"
                                   STR0076)//, I, nLines:=1 //"P O R   P U R C H A S E   O R D E R" // DRL -11/05/09
LOCAL nRegSW6:=SW6->(RECNO())
LOCAL cPictTaxa := AVSX3("W6_TX_US_D",6)

If !EMPTY(PHAWB)
   SW6->(DBSETORDER(1))

   SW6->(DBSEEK(xFilial()+PHAWB))
//   MSubCab+=STR0077+ALLTRIM(PHAWB)+")"+ IF(!EMPTY(SW6->W6_DI_NUM),STR0078+TRAN(SW6->W6_DI_NUM,'@R 99/9999999-9')+")","") //"  (PROCESSO : "###"  (DI: "
   MSubCab+=STR0077+ALLTRIM(PHAWB)+")"+ IF(!EMPTY(SW6->W6_DI_NUM),STR0078+TRAN(SW6->W6_DI_NUM,AVSX3("W6_DI_NUM",AV_PICTURE))+")","") //"  (PROCESSO : "###"  (DI: "//ACB - 16/04/2010
   SW6->(DBGOTO(nRegSW6))
EndIf

If SWH->(FieldPos("WH_DTAPUR")) # 0
   SWH->(DBSETORDER(1))
   SWH->(DBSEEK(xFilial("SWH")+SW2->W2_PO_NUM))
   dDataConTx := SWH->WH_DTAPUR
   nTMExtDConTx := BuscaTaxa(cMOEDAEST,dDataConTx,.T.,.F.,.T.) //RMD - 21/03/2019 - Representa a taxa da moeda (cMoedaEst) na data dDataConTx. Deve ser atualizada sempre que mudar a variável dDataConTx.
EndIf
oPrn:oFont:=COURIER_07

IF !lPrimPag
   AVNEWPAGE
ENDIF

lPrimPag:=.F.
MLin:= 100
MPag++

oPrn:Box( MLin,nColIni,MLin+1,nColFim)
MLin+=nPulaLin1

oPrn:Say(MLin,nColIni,SM0->M0_NOME,COURIER_10)
oPrn:Say(MLin,(nColFim/2),Titulo,COURIER_10,,,,2)
oPrn:Say(MLin,(nColFim-20),STR0079+STR(MPag,8),COURIER_10,,,,1) //"Pagina..: "
MLin+=nPulaLin3

oPrn:Say(MLin,nColIni,"SIGAEIC",COURIER_10)
oPrn:Say(MLin,(nColFim-20),STR0080+DTOC(dDataBase),COURIER_10,,,,1) //"Emissao.: "
MLin+=nPulaLin3

oPrn:Box(MLin,nColIni,MLin+1,nColFim)
MLin+=nPulaLin1

oPrn:oFont:=COURIER_07

oPrn:Say(MLin,nColIni,MSubCab)
MLin+=nPulaLin3

oPrn:Box(MLin,nColIni,MLin+1,nColFim)
MLin+=nPulaLin3

nAuxLin1:=MLin

oPrn:Box(MLin,nColIni,MLin+1,nColFim)
MLin+=nPulaLin1

oPrn:Say(MLin,QC210xCol(003),STR0081+SW2->W2_PO_NUM) //"Nr. PO....: "
oPrn:Say(MLin,QC210xCol(054),STR0082+DTOC(SW2->W2_PO_DT)) //"Emitido em  "
oPrn:Say(MLin,QC210xCol(094),STR0083+SW2->W2_TAB_PC+' '+IF(SWI->(dbSetOrder(1),DBSEEK(xFilial("SWI")+SW2->W2_TAB_PC)),LEFT(SWI->WI_DESC,20),SPACE(20))) //"Tab. Pre-Calculo.: "   // AAF - 07/10/2013
MLin+=nPulaLin3

IF PTipo == Por_Item
   oPrn:Say(MLin,QC210xCol(003),STR0084+ALLTRIM(TRAN(TItem,_PictItem))+' '+IF(SB1->(DBSEEK(xFilial("SB1")+TItem)),ALLTRIM(SB1->B1_DESC),"")) //"Item......: "
ELSE
   SYT->(DBSEEK(xFilial("SYT")+SW2->W2_IMPORT))
   oPrn:Say(MLin,QC210xCol(003),STR0085+SW2->W2_IMPORT+" "+SYT->YT_NOME) //"Importador: "
   oPrn:Say(MLin,QC210xCol(094),STR0086+DTOC(SW2->W2_DT_PC)) //"Data Pre-Calculo.: "
   MLin+=nPulaLin3
ENDIF
//oPrn:Say(MLin,QC210xCol(094), "Taxa " + (cMOEDAEST) + "...: " + Trans(BuscaTaxa(cMOEDAEST,dDataConTx,.T.,.F.,.T.), cPictTaxa) ) //DRL - 11/05/09 //RRV - 01/10/2012 - Imprime taxa do cMOEDAEST
oPrn:Say(MLin,QC210xCol(094), "Taxa " + (SW2->W2_MOEDA) + "...: " + Trans(BuscaTaxa(SW2->W2_MOEDA,dDataConTx,.T.,.F.,.T.), cPictTaxa) ) //DRL - 11/05/09 //RRV - 01/10/2012 - Imprime taxa do cMOEDAEST
MLin+=nPulaLin3

//DFS - 24/09/12 - Retirado a função PADL para que não inclua zeros a esquerda no código do Fabricante e Fornecedor na impressão do Pré-Calculo.
oPrn:Say(MLin,QC210xCol(003),STR0087+SW2->W2_FORN+' '+IF(EICLOJA(),SW2->W2_FORLOJ,"")+' '+IF(SA2->(DBSEEK(xFilial("SA2")+SW2->W2_FORN+EICRetLoja("SW2","W2_FORLOJ"))),SA2->A2_NREDUZ,"")) //"Fornecedor.....: "//SO.:0026 OS.: 0252/02 FCD
//LGS - 14/08/2013
oPrn:Say(MLin,QC210xCol(054),STR0088+Work_1->WKFABR+' '+IF(EICLOJA(),Work_1->W3_FABLOJ,"")+''+IF(SA2->(DBSEEK(xFilial("SA2")+Work_1->WKFABR+EICRetLoja("Work_1","W3_FABLOJ"))),SA2->A2_NREDUZ,"")) //"Fabricante.: "//SO.:0026 OS.: 0252/02 FCD
oPrn:Say(MLin,QC210xCol(094), "Taxa Dolar.: " + Trans(BuscaTaxa(cMOEDAEST    ,dDataConTx,.T.,.F.,.T.), cPictTaxa) ) //DRL - 11/05/09
IF(EasyEntryPoint("EICTP251"),ExecBlock("EICTP251",.F.,.F.,"IMP_DATA_CONV_TAXA"),) // RA - 13/08/2003 - O.S. 746/03 e 748/03
MLin+=nPulaLin3

if empty(SWI->WI_VIA)
   oPrn:Say(MLin,QC210xCol(003),STR0089+SW2->W2_TIPO_EM+' '+IF(SYQ->(DBSEEK(xFilial("SYQ")+SW2->W2_TIPO_EM)),SYQ->YQ_DESCR,"")) //"Via Transporte.: "
Else    
   oPrn:Say(MLin,QC210xCol(003),STR0089+SWI->WI_VIA+' '+IF(SYQ->(DBSEEK(xFilial("SYQ")+SWI->WI_VIA)),SYQ->YQ_DESCR,""))
EndIf   
oPrn:Say(MLin,QC210xCol(054),STR0090+SW2->W2_ORIGEM) //"De.........: "
oPrn:Say(MLin,QC210xCol(081),STR0091 +SW2->W2_DEST) //"Para...: "
MLin+=nPulaLin3

SY6->(DBSEEK(xFilial("SY6")+SW2->W2_COND_PA+STR(SW2->W2_DIAS_PA,3)))

oPrn:Say(MLin,QC210xCol(003),STR0092+SW2->W2_COND_PA+" "+STR(SW2->W2_DIAS_PA,3)+"-"+MSMM(SY6->Y6_DESC_P,/*100*/50,1)) //"Condicao Pagto.: " //DRL - 11/05/09      // GFP - 28/06/2013 - Reduzido descrição para evitar sobreposição de informações.
//MLin+=nPulaLin3
oPrn:Say(MLin,QC210xCol(081),STR0093+IF(SY4->(DBSEEK(xFilial("SY4")+SW2->W2_AGENTE)),SY4->Y4_NOME,"")) //"Agente.: "

//nLines := MLCOUNT(MSMM(SY6->Y6_DESC_P,48,1))

MLin+=nPulaLin3

/*
IF nLines <= 1
   oPrn:Say(MLin,QC210xCol(21),MSMM(SY6->Y6_DESC_P,48,1))
   MLin+=nPulaLin3
ELSE
   MLin+=nPulaLin3
   FOR I = 1 TO nLines
       IF !EMPTY(MSMM(SY6->Y6_DESC_P,50,I))
          oPrn:Say(MLin,QC210xCol(03),MSMM(SY6->Y6_DESC_P,48,I))
          MLin+=nPulaLin3
       ENDIF
   NEXT
ENDIF
*/

RETURN .T.


*----------------------*
FUNCTION TPC251DesCab()
*----------------------*
*|----------------------------------------------------------------------------------------------------------------------------------------|
*| D E S P E S A S       |    C U S T O    U N I T A R I O      |      C U S T O       T O T A L             |% PARTICIPACAO| % SOBRE FOB |
*|-----------------------|--------------------------------------|--------------------------------------------|--------------|-------------|
*|9.99 xxxxxxxxxxxxxxxxxx|Previsto       | Realizado    |  % VAR|    Previsto      | Realizado       |  % VAR|Prev  |Realiz |Prev  |Realiz|
*|                       |---------------|--------------|-------|------------------|-----------------|-------|------|-------|------|------|
*|                       |99,999,999.9999|99,999,999.999|-999.99|9,999,999,999.9999|9,999,999,999.999|-999.99|999.99|999.99 |999.99|999.99|
nAuxLin2:=MLin

oPrn:Box( MLin,nColIni,MLin+1,nColFim)
MLin+=nPulaLin1

oPrn:Say(MLin,QC210xCol(003),STR0094) //"D E S P E S A S"
oPrn:Say(MLin,QC210xCol(030),STR0095) //"C U S T O      U N I T A R I O"
oPrn:Say(MLin,QC210xCol(071),STR0096) //"C U S T O       T O T A L"
oPrn:Say(MLin,QC210xCol(110.5),STR0097) //"% PARTICIPACAO"
oPrn:Say(MLin,QC210xCol(125),STR0098) //"% SOBRE FOB"
MLin+=nPulaLin3

nAuxLin3:=MLin

oPrn:Box(nAuxLin2,nCol2 ,nAuxLin3,nCol2 +1)
oPrn:Box(nAuxLin2,nCol5 ,nAuxLin3,nCol5 +1)
oPrn:Box(nAuxLin2,nCol8 ,nAuxLin3,nCol8 +1)
oPrn:Box(nAuxLin2,nCol10,nAuxLin3,nCol10+1)
oPrn:Box( MLin,nColIni,MLin+1,nColFim)
MLin+=nPulaLin1
IF  lExiste_Midia 
  IF nTotBaseMid # 0
    oPrn:Say(MLin,QC210xCol(003),"Midia :"+TRANS( nTotBaseMid*nTaxaMid,cPicture)) //LGS-25/07/2016
  ENDIF
endif
oPrn:Say(MLin,QC210xCol(026),STR0099) //"Previsto US$"
oPrn:Say(MLin,QC210xCol(043),STR0100) //"Realizado US$"
oPrn:Say(MLin,QC210xCol(059),STR0101) //"% VAR"
oPrn:Say(MLin,QC210xCol(069),STR0099) //"Previsto US$"
oPrn:Say(MLin,QC210xCol(085),STR0100) //"Realizado US$"
oPrn:Say(MLin,QC210xCol(104),STR0101) //"% VAR"
oPrn:Say(MLin,QC210xCol(110),STR0102) //" Prev"
oPrn:Say(MLin,QC210xCol(117),STR0103) //" Real"
oPrn:Say(MLin,QC210xCol(125),STR0102) //" Prev"
oPrn:Say(MLin,QC210xCol(132),STR0103) //" Real"
MLin+=nPulaLin3

oPrn:Box( MLin,nColIni,MLin+1,nColFim)
MLin+=nPulaLin1

RETURN .T.

*----------------------------*
FUNCTION TPC251CabDetI(PTipo)
*----------------------------*
*| Item                            | Unid| Qtde. Inic. | Qtde. Entr  | Saldo       |    N.B.M       |  Peso Liq. Entregue                       |
*| 99999-99-9 xxxxxxxxxxxxxxxxxxxx | xxx | 999,999.999 | 999,999.999 | 999,999.999 | 9999.99.9999   |  9,999,999,999.9999                       |
*|---------------------------------|-----|-------------|-------------|-------------|------------------------------------------------------------
*--------------------------------|---|-----------|-----------|------------|---------------|---------------|---------------|---------------|
*Item                            |Un.| Qtde. Entr|      Saldo|   N.C.M.   |  Unitario (R$)| Unitario (US$)|     TOTAL (R$)|    TOTAL (US$)|
*--------------------------------|---|-----------|-----------|------------|---------------|---------------|---------------|---------------|
*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx|xxx|999,999.999|999,999.999|9999.99.9999|999,999,999.999|999,999,999.999|999,999,999.999|999,999,999.999|
*--------------------------------|---|-----------|-----------|------------|---------------|---------------|---------------|---------------|
*1                              33  37          49          61           74              90             106             122             138

//RRV - 01/10/2012 - Monta relatório de acordo com a moeda na variável cMOEDAEST
Local cMsg1
Local cMsg2
Local cMsg3
Local cMsg4

cMsg1 := "C/Imposto " + cMOEDAEST
cMsg2 := "S/Imposto " + cMOEDAEST
cMsg3 := "Unitário (" + cMOEDAEST + ")"
cMsg4 := "Total (" + cMOEDAEST + ")"

nAuxLin4:=MLin

oPrn:Box( MLin,nColIni,MLin+1,nColFim)
MLin+=nPulaLin1

oPrn:Say(MLin,QC210xCol(001),STR0104) //"Item"
oPrn:Say(MLin,QC210xCol(034),STR0105) //"Un."

IF MParam == Pre_Calculo //LGS - 14/08/2013 - Alterado posição para melhor posicionamento no relatorio.
   oPrn:Say(MLin,QC210xCol(039),STR0042) //"Quantidade"
ELSE
   oPrn:Say(MLin,QC210xCol(039),STR0106) //"Qtde. Entr"
   oPrn:Say(MLin,QC210xCol(052),STR0007) //"Saldo"
ENDIF
oPrn:Say(MLin,QC210xCol(063),STR0107) //"N.C.M."

IF PTipo # Por_Item
   IF MParam == Realizado
      oPrn:Say(MLin+1,QC210xCol(076),STR0108) //"C/Imposto R$"
      oPrn:Say(MLin+1,QC210xCol(092),cMsg1) //"C/Imposto US$" //RRV - 01/10/2012 - Monta relatório de acordo com a moeda na variável cMOEDAEST
      oPrn:Say(MLin+1,QC210xCol(108),STR0110) //"S/Imposto R$"
      oPrn:Say(MLin+1,QC210xCol(124),cMsg2) //"S/Imposto US$" //RRV - 01/10/2012 - Monta relatório de acordo com a moeda na variável cMOEDAEST
   ELSE
      oPrn:Say(MLin,QC210xCol(077),STR0112) //"Unitario (R$)"
      oPrn:Say(MLin,QC210xCol(092),cMsg3) //"Unitario (US$)" //RRV - 01/10/2012 - Monta relatório de acordo com a moeda na variável cMOEDAEST
      oPrn:Say(MLin,QC210xCol(112),STR0114) //"TOTAL (R$)"
      oPrn:Say(MLin,QC210xCol(127),cMsg4) //"TOTAL (US$)" //RRV - 01/10/2012 - Monta relatório de acordo com a moeda na variável cMOEDAEST
   ENDIF
ELSE
   IF MParam = Pre_Calculo
      oPrn:Say(MLin,QC210xCol(082),STR0116) //" Peso Liquido"
   ELSE
      oPrn:Say(MLin,QC210xCol(082),STR0117) //" Peso Liq. Entregue"
   ENDIF
ENDIF
MLin+=nPulaLin3

oPrn:Box( MLin,nColIni,MLin+1,nColFim)
MLin+=nPulaLin1

RETURN .T.

*------------------------------------*
FUNCTION TPC251ImprItens(PTipo,PHAWB)
*------------------------------------*
LOCAL cCodItem :=""
LOCAL nTamItem :=0 

DBSELECTAREA("Work_1")

IF PTipo == Por_PO
   TPC251Colunas(1)
   IF MLin > (nLimPage-nPulaLin1*2-nPulaLin3*2)
      TPC251Cab(PTipo,PHAWB)
   ENDIF
   TPC251CabDetI(PTipo)
ENDIF

WHILE ! EOF()

  IncProc(STR0074+Work_1->WKCOD_I) //"Imprimindo Item: "

  IF WKFLAG <> "A"
     DBSKIP() ; LOOP
  ENDIF

  IF MParam = Realizado .AND. Work_1->WKQTD_ACU = 0
     DBSKIP() ; LOOP
  ENDIF

  IF PTipo == Por_Item .AND. WKCOD_I <> TItem
     EXIT
  ENDIF

  IF MLin > nLimPage
     TPC251Colunas(2)
     TPC251Cab(PTipo,PHAWB)
     TPC251CabDetI(PTipo)
  ENDIF

   SB1->(DBSEEK(xFilial("SB1")+Work_1->WKCOD_I))
   cCodItem :=ALLTRIM(SB1->B1_COD)                              
   nTamDesc :=30//35   // GFP - 15/07/2013
   nTamItem :=nTamDesc-LEN(cCodItem)
   cDescrItem:=MSMM(SB1->B1_DESC_P,36)
   oPrn:Say(MLin,QC210xCol(002),cCodItem +"-"+MEMOLINE(cDescrItem,nTamItem,1) )
   oPrn:Say(MLin,QC210xCol(034),WKUNID)
   //oPrn:Say(MLin,QC210xCol(035),TRAN(WKQTD_ACU,AVSX3("W7_QTDE",6)),,,,1)
   oPrn:Say(MLin,QC210xCol(038),TRAN(WKQTD_ACU,AVSX3("W7_QTDE",6)),,,,1) //LGS - 14/08/2013 - Alterado posição para nao sobrepor informação na geração do relatório.
   
    
   IF !(MParam == Pre_Calculo)
      oPrn:Say(MLin,QC210xCol(47),TRAN(WKQTD_SALD,AVSX3("W3_QTDE",6)),,,,1)
   ENDIF

   IF !EMPTY(SUBST(Work_1->WKNBM,1,08))
      oPrn:Say(MLin,QC210xCol(063),TRAN(SUBST(Work_1->WKNBM,1,08),"@R 9999.99.99"))
   ENDIF

   IF PTipo == Por_PO
      //inclusao do campo controle no indice do work2, para diferenciar custo do
      //item, quando o mesmo codigo de item aparecer duas vezes no mesmo P.O.
      //Work_2->(DBSEEK(Work_1->WKCOD_I+CUSTO_DO_ITEM+DTOS(AVCTOD(""))+Work_1->WKCONTROLE))
      Work_2->(DBSEEK(Work_1->WKCOD_I+If(lRegTriPO,Work_1->WKGRUPORT,"")+"000"+DTOS(AVCTOD(""))+Work_1->WKCONTROLE )) //GFP - 25/06/2015
      oPrn:Say(MLin,QC210xCol(075),TRAN(Work_2->WKCUS_T_P / WKQTD_ACU,cPicture))//LGS-25/07/2016
      oPrn:Say(MLin,QC210xCol(091),TRAN(Work_2->WKCUS_T_R / WKQTD_ACU,cPicture))//LGS-25/07/2016

      IF MParam == Realizado  // IMPRESSAO DO CUSTO UNITARIO SEM/COM ICMS /IPI NO LUGAR DAS COLUNAS DE TOTAL
         oPrn:Say(MLin,QC210xCol(107),TRAN(Work_2->WKCUS_S_P / WKQTD_ACU,cPicture))//LGS-25/07/2016
         oPrn:Say(MLin,QC210xCol(123),TRAN(Work_2->WKCUS_S_R / WKQTD_ACU,cPicture))//LGS-25/07/2016
      ELSE  // CONTINUA COMO ESTAVA
         oPrn:Say(MLin,QC210xCol(107),TRAN(Work_2->WKCUS_T_P,cPicture))//LGS-25/07/2016
         oPrn:Say(MLin,QC210xCol(123),TRAN(Work_2->WKCUS_T_R,cPicture))//LGS-25/07/2016
      ENDIF

   ELSE

      oPrn:Say(MLin,QC210xCol(075),TRAN(WKPESO_L * WKQTD_ACU,AVSX3("W3_PESOL",6)))  //100

   ENDIF
   MLin+=nPulaLin2
   oPrn:Say(MLin,QC210xCol(002),MEMOLINE(SUBSTR(cDescrItem,nTamItem),nTamDesc,1))
   IF !EMPTY(SUBST(Work_1->WKNBM,11,6))
      oPrn:Say(MLin,QC210xCol(063),TRAN(SUBST(Work_1->WKNBM,11,6),"@R 999.999"))
   ENDIF
   MLin+=nPulaLin2
   

   DBSKIP()

ENDDO

TPC251Colunas(2)

RETURN .T.

*------------------------------------*
FUNCTION TPC251DetDesp(PTipo,PHAWB)
*------------------------------------*
LOCAL DESP1_1, DESP2_2, nFreteR_P:=0, nFreteR_R:=0, nSaveTot_P:=0,;
      nSaveTot_R:=0, lBateu:=.F., lBateuCab:=.F.
PRIVATE nPerCIF:=0,nPerPar:=0

WHILE ! EOF()

  IF PTipo == Por_Item
     IF Work_2->WKCOD_I <> TItem
        EXIT
     ENDIF
  ENDIF

  IF PTipo == Por_PO
     IF ! EMPTY(Work_2->WKCOD_I)
        EXIT
     ENDIF
  ENDIF

  lBateuCab:=.F.
  IF MLin > nLimPage
     IF lBateu
        MLin-=nPulaLin1
     ENDIF
     SB1->(DBSEEK(xFilial("SB1") + Work_2->WKCOD_I))
     TPC251Colunas(1)
     TPC251Cab(PTipo,PHAWB)
     IF MParam ==Pre_X_Real
        TPC251DesCab()
     ELSE
        TPC251Des_CR(PTipo)
     ENDIF
     lBateuCab:=.T.
  ENDIF

  DESP1_1:= LEFT(WKDESPESA,1) ; DESP2_2:= RIGHT(WKDESPESA,2)

  IF DESP2_2 # DESPESA_SUBTOT .AND. WKDESPESA # DESP_GERAL_SEM .AND. WKDESPESA # DESP_GERAL_IPI .AND.;
     WKDESPESA # DESP_GERAL_ICMS .AND. WKDESPESA # "T94" .AND. WKDESPESA # "T95" .AND. WKDESPESA # "T93" .AND. WKDESPESA # DESP_GERAL_SEM_IMP

     oPrn:Say(MLin,QC210xCol(002),TRAN(WKDESPESA,"@R 9.99"))

     SYB->(DBSEEK(xFilial("SYB")+Work_2->WKDESPESA))

     DO CASE
        CASE MParam == Realizado

             IF !SYB->(EOF())
             oPrn:Say(MLin,QC210xCol(007),LEFT(SYB->YB_DESCR,22))
             ELSE
                cCodFB:=WKDESC
                SFB->(DBSEEK(XFILIAL("SFB")+cCodFB))
                oPrn:Say(MLin,QC210xCol(007),LEFT(SFB->FB_DESCR,22))
             ENDIF   

             IF PTipo = Por_PO

                oPrn:Say(MLin,QC210xCol(034),DTOC(WKDES_ADI))

                IF AT(STR0118,SYB->YB_DESCR) # 0 //"FRETE RODOVIARIO"
                   nFreteR_P+=WKCUS_T_P
                   nFreteR_R+=WKCUS_T_R
                ENDIF

             ENDIF
        CASE MParam == Pre_Calculo

             IF !SYB->(EOF())
             oPrn:Say(MLin,QC210xCol(007),If(PTipo == Por_Item,LEFT(SYB->YB_DESCR,14),LEFT(SYB->YB_DESCR,22)/*LEFT(SYB->YB_DESCR,30)*/)+' '+; //LGS - 09/08/2013 - Reduzido descrição para evitar sobreposição de informações na impressão em PDF.
                             If(!Empty(WKPER_DES) .And. PTipo == Por_Item,TRAN(WKPER_DES,'@E 999.99')+'%','')) //RRV - 16/01/2013 - Imprime alíquotas apenas se relatório for por item.  // GFP - 15/07/2013 - Exibe descrição completa da despesa apenas se relatorio for por PO.
             ELSE  
                 cCodFB:=WKDESC
                 SFB->(DBSEEK(XFILIAL("SFB")+cCodFB))
                 oPrn:Say(MLin,QC210xCol(007),LEFT(SFB->FB_DESCR,14)+' '+;
                             If(!Empty(WKPER_DES),TRAN(WKPER_DES,'@E 999.99')+'%',''))
             ENDIF
        OTHERWISE
             IF !SYB->(EOF())
             oPrn:Say(MLin,QC210xCol(007),LEFT(SYB->YB_DESCR,18))
             ELSE                             
                cCodFB:=WKDESC
                SFB->(DBSEEK(XFILIAL("SFB")+cCodFB))
                oPrn:Say(MLin,QC210xCol(007),LEFT(SFB->FB_DESCR,18))
             ENDIF   


    ENDCASE
  ELSE             
     IF !lBateuCab .AND. ! DESP1_1 $ "T9" 
        oPrn:Box( MLin,nColIni,MLin+1,nColFim)
        MLin+=nPulaLin1
     ENDIF

     DO CASE
        CASE DESP1_1 = '1'
             oPrn:Say(MLin,QC210xCol(002),"1.04")
             oPrn:Say(MLin,QC210xCol(007),STR0119) //"C.I.F."
        CASE DESP1_1 = '2'
             oPrn:Say(MLin,QC210xCol(002),STR0120) //"TOTAL DE IMPOSTOS"
        CASE DESP1_1 = '3'
             oPrn:Say(MLin,QC210xCol(002),STR0121) //"TOTAL OUTRAS DESPESAS"
        CASE DESP1_1 = '4'
             oPrn:Say(MLin,QC210xCol(002),STR0122) //"TOTAL DESPESAS 4     "
        CASE DESP1_1 = '5'
             oPrn:Say(MLin,QC210xCol(002),STR0123) //"TOTAL DESPESAS 5     "
        CASE DESP1_1 = '6'
             oPrn:Say(MLin,QC210xCol(002),STR0124) //"TOTAL DESPESAS 6     "
        CASE DESP1_1 = '7'
             oPrn:Say(MLin,QC210xCol(002),STR0125) //"TOTAL DESPESAS 7     "
        CASE DESP1_1 = '8'
             oPrn:Say(MLin,QC210xCol(002),STR0200) //"TOTAL DESPESAS 8     "
        CASE DESP1_1 = 'T'
             //PTipo == Por_PO .AND.
             IF  (MParam == Realizado .OR. MParam == Pre_Calculo)
             
                 IF cPaisLoc=="BRA"
                IF DESP_GERAL_SEM == WKDESPESA
                   oPrn:Say(MLin,QC210xCol(002),"TOTAL GERAL SEM IPI/ICMS")  //STR0126
                   
                ELSEIF DESP_GERAL_IPI == WKDESPESA                         
                   oPrn:Say(MLin,QC210xCol(002),"TOTAL GERAL C/IPI S/ICMS") // STR0127
                   
                ELSEIF DESP_GERAL_ICMS == WKDESPESA                         
                   oPrn:Say(MLin,QC210xCol(002),"TOTAL GERAL S/IPI C/ICMS")
                   
                ELSEIF DESPESA_GERAL == WKDESPESA
                   oPrn:Say(MLin,QC210xCol(002),"TOTAL GERAL COM IPI/ICMS")
                   nSaveTot_P+=WKCUS_T_P
                   nSaveTot_R+=WKCUS_T_R
                ELSEIF "T93" == WKDESPESA
                   oPrn:Say(MLin,QC210xCol(002),"TOTAL GERAL S/PIS S/COF")
                ELSEIF "T94" == WKDESPESA
                   oPrn:Say(MLin,QC210xCol(002),"TOTAL GERAL S/PIS C/COF")
                ELSEIF "T95" == WKDESPESA
                   oPrn:Say(MLin,QC210xCol(002),"TOTAL GERAL C/PIS S/COF")
                ELSEIF DESP_GERAL_SEM_IMP == WKDESPESA
                   oPrn:Say(MLin,QC210xCol(002),"TOTAL GERAL S/PIS/COF/IPI/ICM")  // GFP - 28/06/2013 - Reduzido título para evitar sobreposição de informações na impressão.
                ENDIF
                    
                ELSE
                    IF DESPESA_GERAL == WKDESPESA
                       oPrn:Say(MLin,QC210xCol(002),STR0128)
                       nSaveTot_P+=WKCUS_T_P
                       nSaveTot_R+=WKCUS_T_R
                    ENDIF
                ENDIF   
                    
           //  ELSE
           //     oPrn:Say(MLin,QC210xCol(002),"TOTAL GERAL")
           //     nSaveTot_P+=WKCUS_T_P
           //     nSaveTot_R+=WKCUS_T_R
             ENDIF
        CASE DESP1_1 = '9'
             oPrn:Say(MLin,QC210xCol(002),STR0129+"("+SW2->W2_MOEDA+")") //"CUSTO NA MOEDA FOB"
     ENDCASE
  ENDIF

  nPerCIF :=WKPERCIF_R
  nPerPAr:= WKPERPAR_R

  IF EasyEntryPoint("EICTP251")
     EXECBLOCK( "EICTP251",.F.,.F.,"IMPRIRDESP")
  ENDIF                    

  IF PTipo==Por_Item
     IF !(!(cPaisLoc=="BRA") .AND. WKDESPESA $ (DESP_GERAL_SEM +'/'+ DESP_GERAL_IPI +'/'+ DESP_GERAL_ICMS +'/'+ DESP_GERAL_SEM_IMP))
     oPrn:Say(MLin,QC210xCol(IF(MParam==Pre_X_Real,024,030)),TRAN(WKCUS_U_P,IF(MParam==Pre_X_Real,cPicture,cPicture)))//LGS-25/07/2016
     oPrn:Say(MLin,QC210xCol(IF(MParam==Pre_X_Real,039,050)),TRAN(WKCUS_U_R,IF(MParam==Pre_X_Real,cPicture,cPicture)))//LGS-25/07/2016
     ENDIF        
     IF MParam == Pre_X_Real
        oPrn:Say(MLin,QC210xCol(058),TRAN(WKVARCUS_U,cPicture))//LGS-25/07/2016
     ENDIF

  ENDIF

  IF !(!(cPaisLoc=="BRA") .AND. WKDESPESA $ (DESP_GERAL_SEM +'/'+ DESP_GERAL_IPI +'/'+ DESP_GERAL_ICMS +'/'+ DESP_GERAL_SEM_IMP))
  oPrn:Say(MLin,QC210xCol(IF(MParam==Pre_X_Real,065,070)),TRAN(WKCUS_T_P,IF(MParam==Pre_X_Real,cPicture,cPicture)))//LGS-25/07/2016
  oPrn:Say(MLin,QC210xCol(IF(MParam==Pre_X_Real,084,090)),TRAN(WKCUS_T_R,IF(MParam==Pre_X_Real,cPicture,cPicture)))//LGS-25/07/2016
  ENDIF
  IF MParam == Pre_X_Real
     oPrn:Say(MLin,QC210xCol(104),TRAN(WKVARCUS_T,cPicture))//LGS-25/07/2016
  ENDIF

  IF WKDESPESA # DESPESA_ADIANT
     IF !(!(cPaisLoc=="BRA") .AND. WKDESPESA $ (DESP_GERAL_SEM +'/'+ DESP_GERAL_IPI +'/'+ DESP_GERAL_ICMS +'/'+ DESP_GERAL_SEM_IMP))

     IF MParam==Pre_X_Real
        oPrn:Say(MLin,QC210xCol(111),TRAN(WKPERPAR_P,cPicture))//LGS-25/07/2016
        oPrn:Say(MLin,QC210xCol(118),TRAN(nPerPAr,cPicture))//LGS-25/07/2016
     ELSE
        oPrn:Say(MLin,QC210xCol(108),TRAN(nPerPAr,cPicture))//LGS-25/07/2016
        ENDIF
     ENDIF
  ENDIF

  DO CASE
     CASE WKDESPESA=DESPESA_ADIANT

     CASE WKDESPESA=DESPESA_FOB
          oPrn:Say(MLin,QC210xCol(IF(MParam==Pre_X_Real,127,128)),STR0130) //"BASE"
          IF MParam == Pre_X_Real
             oPrn:Say(MLin,QC210xCol(134),STR0130) //"BASE"
          ENDIF

     CASE MParam == Pre_X_Real
          IF !(!(cPaisLoc=="BRA") .AND. WKDESPESA $ (DESP_GERAL_SEM +'/'+ DESP_GERAL_IPI +'/'+ DESP_GERAL_ICMS +'/'+ DESP_GERAL_SEM_IMP))
          oPrn:Say(MLin,QC210xCol(126),TRAN(WKPERCIF_P,cPicture))//LGS-25/07/2016
          oPrn:Say(MLin,QC210xCol(133),TRAN(nPerCIF,cPicture))//LGS-25/07/2016
          ENDIF   

     OTHERWISE
          IF !(!(cPaisLoc=="BRA") .AND. WKDESPESA $ (DESP_GERAL_SEM +'/'+ DESP_GERAL_IPI +'/'+ DESP_GERAL_ICMS +'/'+ DESP_GERAL_SEM_IMP))
          oPrn:Say(MLin,QC210xCol(126),TRAN(nPerCIF,cPicture))//LGS-25/07/2016
          ENDIF   
   ENDCASE

  MLin+=nPulaLin2
  lBateu:=.F.
  IF DESP2_2 = DESPESA_SUBTOT .AND. ! DESP1_1 $ '89'
     oPrn:Box( MLin,nColIni,MLin+1,nColFim)
     MLin+=nPulaLin1
     lBateu:=.T.
  ENDIF

  DBSKIP()

ENDDO

IF (nFreteR_P+nFreteR_R) # 0
   IF !lBateu
      oPrn:Box( MLin,nColIni,MLin+1,nColFim)
      MLin+=nPulaLin1
   ENDIF
   lBateu:=.F.
   oPrn:Say(MLin,QC210xCol(002),STR0131) //"VALOR ADUANEIRO"
   oPrn:Say(MLin,QC210xCol(070),TRAN((nSaveTot_P-nFreteR_P),cPicture))//LGS-25/07/2016
   oPrn:Say(MLin,QC210xCol(090),TRAN((nSaveTot_R-nFreteR_R),cPicture))//LGS-25/07/2016
   MLin+=nPulaLin2
ENDIF

IF lBateu
   MLin-=nPulaLin1
ENDIF


DBSELECTAREA("Work_1")

RETURN .T.

*---------------------------*
FUNCTION TPC251Des_CR(PTipo)
*---------------------------*
LOCAL cMoeda
LOCAL Cab1:=IF(PTipo==Por_PO .AND. MParam==Realizado,;
               STR0132,STR0133) //"D A T A"###"C U S T O    U N I T A R I O"
*-----------------------------------------------------------------------------------------------------------------------------------------|
*  D E S P E S A S           |    C U S T O    U N I T A R I O       |       C U S T O   T O T A L           |% PARTICIPACAO| % SOBRE FOB |
*----------------------------|---------------------------------------|---------------------------------------|--------------|-------------|
* 9.99 xxxxxxxxxxxxxxxxxxxxxx|    Reais (R$)     |   Dolares (US$)   |      Reais (R$)   |    Dolares (US$)  |              |             |
*                            |-------------------|-------------------|-------------------|-------------------|--------------|-------------|
*                            |999,999,999,999.999|999,999,999,999.999|999,999,999,999.999|999,999,999,999.999|    999.99        999.99
nAuxLin2:=MLin

oPrn:Box( MLin,nColIni,MLin+1,nColFim)
MLin+=nPulaLin1

oPrn:Say(MLin,QC210xCol(003),STR0094) //"D E S P E S A S"
oPrn:Say(MLin,QC210xCol(034),Cab1)
oPrn:Say(MLin,QC210xCol(077),STR0134) //"C U S T O   T O T A L"
oPrn:Say(MLin,QC210xCol(110),STR0097) //"% PARTICIPACAO"
oPrn:Say(MLin,QC210xCol(126),STR0098) //"% SOBRE FOB"
MLin+=nPulaLin3

nAuxLin3:=MLin

oPrn:Box(nAuxLin2,nCol2 ,nAuxLin3,nCol2+1)
oPrn:Box(nAuxLin2,nCol4 ,nAuxLin3,nCol4+1)
oPrn:Box(nAuxLin2,nCol6 ,nAuxLin3,nCol6+1)
oPrn:Box(nAuxLin2,nCol7 ,nAuxLin3,nCol7+1)
oPrn:Box( MLin,nColIni,MLin+1,nColFim)
MLin+=nPulaLin1

cMoeda := ALLTRIM(EasyGParam("MV_MOEDA1"))+" ( "+ALLTRIM(EasyGParam("MV_SIMB1"))+" )"  // RS
cMoeda2:= "Dolares (" + cMOEDAEST + ")" //RRV - 01/10/2012 - Monta relatório de acordo com a moeda na variável cMOEDAEST
IF !(PTipo==Por_PO .AND. MParam==Realizado)
   IF lExiste_Midia
     IF Work_1->WKBASEMID # 0
      oPrn:Say(MLin,QC210xCol(001),"FOB Midia :"+SW2->W2_MOEDA+TRANS( IF(PTipo==Por_Item,Work_1->WKBASEMID,nTotBaseMid)/**nTaxaMid*/,cPicture))//LGS-25/07/2016
     ENDIF
   ENDIF


// oPrn:Say(MLin,QC210xCol(034),STR0135) //"Reais (R$)"
// oPrn:Say(MLin,QC210xCol(053),STR0136) //"Dolares (US$)"   
 
oPrn:Say(MLin,QC210xCol(034),cMoeda) //"Reais (R$)"
oPrn:Say(MLin,QC210xCol(053),cMoeda2) //"Dolares (US$)" //RRV - 01/10/2012 - Monta relatório de acordo com a moeda na variável cMOEDAEST

ENDIF

//oPrn:Say(MLin,QC210xCol(076),STR0135) //"Reais (R$)"
oPrn:Say(MLin,QC210xCol(076),cMoeda) //"Reais (R$)"
oPrn:Say(MLin,QC210xCol(094),cMoeda2) //"Dolares (US$)" //RRV - 01/10/2012 - Monta relatório de acordo com a moeda na variável cMOEDAEST
MLin+=nPulaLin3

oPrn:Box( MLin,nColIni,MLin+1,nColFim)
MLin+=nPulaLin1

RETURN .T.

*-------------------------------*
FUNCTION TPC251Colunas(nQualDet)
*-------------------------------*
Local nLinFim:=MLin
oPrn:Box(nAuxLin1,nColIni,nLinFim,nColIni+1)//Coluna Esquerda
oPrn:Box(nAuxLin1,nColFim,nLinFim,nColFim+1)//Coluna Direita

DO CASE
   CASE nQualDet = 1
 
      oPrn:Box(nAuxLin3,nCol2 ,nLinFim,nCol2 +1)
      oPrn:Box(nAuxLin3,nCol3 ,nLinFim,nCol3 +1)
      oPrn:Box(nAuxLin3,nCol4 ,nLinFim,nCol4 +1)
      oPrn:Box(nAuxLin3,nCol5 ,nLinFim,nCol5 +1)
      oPrn:Box(nAuxLin3,nCol6 ,nLinFim,nCol6 +1)
      oPrn:Box(nAuxLin3,nCol7 ,nLinFim,nCol7 +1)
      oPrn:Box(nAuxLin3,nCol8 ,nLinFim,nCol8 +1)
      oPrn:Box(nAuxLin3,nCol9 ,nLinFim,nCol9 +1)
      oPrn:Box(nAuxLin3,nCol10,nLinFim,nCol10+1)
      oPrn:Box(nAuxLin3,nCol11,nLinFim,nCol11+1)
      oPrn:Box(nLinFim ,nColIni,nLinFim+1,nColFim)
      
      

   CASE nQualDet = 2
      MLin+=nPulaLin1
						oPrn:Box(nAuxLin4,nCol2_I,nLinFim,nCol2_I+1)
      oPrn:Box(nAuxLin4,nCol3_I,nLinFim,nCol3_I+1)
      oPrn:Box(nAuxLin4,nCol4_I,nLinFim,nCol4_I+1)
      oPrn:Box(nAuxLin4,nCol5_I,nLinFim,nCol5_I+1)
      oPrn:Box(nAuxLin4,nCol6_I,nLinFim,nCol6_I+1)
      oPrn:Box(nAuxLin4,nCol7_I,nLinFim,nCol7_I+1)
      oPrn:Box(nAuxLin4,nCol8_I,nLinFim,nCol8_I+1)
      oPrn:Box(nAuxLin4,nCol9_I,nLinFim,nCol9_I+1)
      oPrn:Box(nLinFim ,nColIni,nLinFim+1,nColFim)

      IF MParam == Realizado  
     				oPrn:Box(nAuxLin4,nCol6_I,nAuxLin4+nPulaLin1+2,nColFim)
  	      oPrn:Say(nAuxLin4+1,nCol7_I,STR0188) // "    P  R  E  C  O       U  N  I  T  A  R  I  O           "
  	   EndIf

ENDCASE

RETURN .T.

*------------------------------------------------------------------------
FUNCTION TPC251_APE(PHAWB,aPGI,aAPE,aCambio,aLC,aSeguro,Tb_Hawb,PTipo)
*------------------------------------------------------------------------
LOCAL Item, aPrint:={}, VL_US:=CIF_US:=PAR_US:=0, MDtVen,;
      MDias, aSaveInv:={}, _PictApe := ALLTRIM(X3Picture("WR_NUM"))
Local Ind


IF MLin > nLimPage
   TPC251CabAPE(PTipo)
ENDIF

ProcRegua(LEN(aPGI)+LEN(aAPE)+LEN(aCambio)+LEN(aLC)+(LEN(Tb_Hawb)*3)+LEN(aSeguro))

TPC251Sub_Cab(STR0137) //"Guia de Importacao"
TPC251GuiasImp()

FOR Item = 1 TO LEN(aPGI)
    aPrint:=aPGI[Item]

    IncProc(STR0138) //"Imprimindo Guias"

    IF Item <> 1
       MLin+=nPulaLin2
    ENDIF

    IF MLin > nLimPage
       TPC251CabAPE(PTipo)
       TPC251Sub_Cab(STR0137) //"Guia de Importacao"
       TPC251GuiasImp()
    ENDIF

    TPC251GIDet(aPrint)


    SYI->(DBSEEK(xFilial("SYI")+aPrint:GIGI_NUM))
    WHILE ! SYI->(EOF()) .AND. SYI->YI_GI_NUM = aPrint:GIGI_NUM .AND. SYI->YI_FILIAL == xFilial('SYI')

      IF MLin > nLimPage
         TPC251CabAPE(PTipo)
         TPC251Sub_Cab(STR0137) //"Guia de Importacao"
         TPC251GuiasImp()
         TPC251GIDet(aPrint)
      ENDIF

      IF ! EMPTY(SYI->YI_AGI_NUM)
         oPrn:Say(MLin,QC210xCol(039),TRAN(SYI->YI_AGI_NUM,"@R 9999-99/999999-9"))
         oPrn:Say(MLin,QC210xCol(057),DTOC(SYI->YI_AGI_DT))
      ELSE
         oPrn:Say(MLin,QC210xCol(039),STR0139+TRAN(SYI->YI_PAGI_NU ,ALLTRIM(X3Picture("W4_PGI_NUM")))) //"PAGI "
         oPrn:Say(MLin,QC210xCol(057),DTOC(SYI->YI_PAGI_DT))
      ENDIF

      oPrn:Say(MLin,QC210xCol(066),DTOC(SYI->YI_AGI_VEN))
      MLin+=nPulaLin2
      SYI->(DBSKIP())
    END
NEXT

aPGI:={}
MLin+=nPulaLin3

IF MLin > nLimPage
   TPC251CabAPE(PTipo)
ENDIF

TPC251Sub_Cab(STR0140) //"A.P.E."
TPC251APEs()
ASIZE(aSaveInv,0)

FOR Item=1 TO LEN(aAPE)

    IncProc(STR0141) //"Imprimindo A.P.E."

    IF MLin > nLimPage
       TPC251CabAPE(PTipo)
       TPC251Sub_Cab("A.P.E.")
       TPC251APEs()
    ENDIF

    aPrint:=aAPE[Item]

    IF EMPTY(aPrint:APENUM)
       LOOP
    ENDIF

    SW6->(DBSEEK(xFilial("SW6")+aPrint:APEHAWB))

    oPrn:Say(MLin,QC210xCol(01),TRAN(aPrint:APENUM,_PictApe))
    oPrn:Say(MLin,QC210xCol(12),DTOC(aPrint:APEDT))
    oPrn:Say(MLin,QC210xCol(22),aPrint:APECEDENTE)
    oPrn:Say(MLin,QC210xCol(44),aPrint:APEBANCO)

   SW9->(DBSEEK(xFilial("SW9")+aPrint:APEHAWB))

   WHILE ! SW9->(EOF()) .AND. SW9->W9_HAWB = aPrint:APEHAWB .AND. SW9->W9_FILIAL == xFilial("SW9")

     IF ASCAN(aSaveInv,SW9->W9_INVOICE) = 0 // para nao imprimir a mesma
        AADD(aSaveInv,SW9->W9_INVOICE)      // invoice varias vezes
     ELSE
        SW9->(DBSKIP()) ; LOOP
     ENDIF

     IF MLin > nLimPage
        TPC251CabAPE(PTipo)
        TPC251Sub_Cab("A.P.E.")
        TPC251APEs()
        oPrn:Say(MLin,QC210xCol(01),TRAN(aPrint:APENUM,_PictApe))
        oPrn:Say(MLin,QC210xCol(12),DTOC(aPrint:APEDT))
        oPrn:Say(MLin,QC210xCol(22),aPrint:APECEDENTE)
        oPrn:Say(MLin,QC210xCol(44),aPrint:APEBANCO)
     ENDIF

     oPrn:Say(MLin,QC210xCol(66),SW9->W9_INVOICE)
     oPrn:Say(MLin,QC210xCol(82),DTOC(SW9->W9_DT_EMIS))
     DO CASE
         CASE SW2->W2_DIAS_PA < 0
              oPrn:Say(MLin,QC210xCol(91),STR0179)//' A VISTA'

         CASE SW2->W2_DIAS_PA >= 900
              SY6->(DBSEEK(xFilial("SY6")+SW2->W2_COND_PA+STR(SW2->W2_DIAS_PA,3)))
//              MDias:=SY6->(FIELDPOS("Y6_DIAS_"+PADL(Item,2,"0")))
              MDias:=SY6->(FIELDPOS("Y6_DIAS_"+STRZERO(Item,2)))
              IF(MDias # 0,MDias:=SY6->(FIELDGET(MDias)),)
              IF ! EMPTY(SW6->W6_DT_EMB)
                 MDtVen:=SW6->W6_DT_EMB+MDias
                 oPrn:Say(MLin,QC210xCol(91),DTOC(MDtVen))
                 IF aPrint:APEDT_VEN # MDtVen .AND. ! EMPTY(aPrint:APEDT_VEN)
                    oPrn:Say(MLin,QC210xCol(100),"*")
                 ENDIF
              ELSE
                 oPrn:Say(MLin,QC210xCol(91),STR(MDias,3)+STR0180)//' DIAS'
              ENDIF

         CASE SW2->W2_DIAS_PA # 0
              IF ! EMPTY(SW6->W6_DT_EMB)
                 oPrn:Say(MLin,QC210xCol(91),DTOC((MDtVen:=SW6->W6_DT_EMB+SW2->W2_DIAS_PA)))
                 IF aPrint:APEDT_VEN # MDtVen .AND. ! EMPTY(aPrint:APEDT_VEN)
                    oPrn:Say(MLin,QC210xCol(100),"*")
                 ENDIF
              ELSE
                 oPrn:Say(MLin,QC210xCol(91),STR(SW2->W2_DIAS_PA,3)+STR0180)
              ENDIF
      ENDCASE

     MLin+=nPulaLin2
     SW9->(DBSKIP())
  END
NEXT

MLin+=nPulaLin3

IF MLin > nLimPage
   TPC251CabAPE(PTipo)
ENDIF

TPC251Sub_Cab(STR0142) //"Contrato de Cambio"
TPC251ContrCambio()

FOR Item=1 TO LEN(aCambio)

    IncProc(STR0143) //"Imprimindo Contrato de Cambio"

    IF MLin > nLimPage
       TPC251CabAPE(PTipo)
       TPC251Sub_Cab(STR0142) //"Contrato de Cambio"
       TPC251ContrCambio()
    ENDIF

    aPrint:=aCambio[Item]

    oPrn:Say(MLin,QC210xCol(001),aPrint:APECA_NUM)
    oPrn:Say(MLin,QC210xCol(017),DTOC(aPrint:APECA_DT))
    oPrn:Say(MLin,QC210xCol(026),SW2->W2_MOEDA)
    oPrn:Say(MLin,QC210xCol(030),TRAN(aPrint:APEFOBMOE,cPicture))//LGS-25/07/2016
    oPrn:Say(MLin,QC210xCol(049),TRAN(aPrint:APECA_TX,cPicture))//LGS-25/07/2016
    oPrn:Say(MLin,QC210xCol(066),TRAN(aPrint:APEFOBMOE*aPrint:APECA_TX,cPicture))//LGS-25/07/2016
    MLin+=nPulaLin2

NEXT

aCambio:={}

MLin+=nPulaLin3

IF MLin > nLimPage
   TPC251CabAPE(PTipo)
ENDIF

TPC251Sub_Cab(STR0144) //"Carta de Credito"
TPC251CartasCred()

FOR Item=1 TO LEN(aLC)

    IncProc(STR0145) //"Imprimindo Carta de Credito"

    IF MLin > nLimPage
       TPC251CabAPE(PTipo)
       TPC251Sub_Cab(STR0144) //"Carta de Credito"
       TPC251CartasCred()
    ENDIF

    aPrint:=aLC[Item]

    SW6->(DBSEEK(xFilial("SW6")+aPrint:APEHAWB))

    oPrn:Say(MLin,QC210xCol(01),TRAN(aPrint:APELC_NUM,ALLTRIM(X3Picture("YH_LC_NUM"))))
    oPrn:Say(MLin,QC210xCol(12),DTOC(aPrint:APELC_DT))
    oPrn:Say(MLin,QC210xCol(22),DTOC(aPrint:APELC_VEN))
    //IF !EMPTY(SW6->W6_VLMLEMN)                  
      //nOrdSW9:=SW9->(INDEXORD())
      //SW9->(DBSETORDER(3))
      //SW9->(DBSEEK(xFilial("SW9")+SW6->W6_HAWB))
      //oPrn:Say(MLin,QC210xCol(32),SW9->W9_MOE_FOB)     
      //oPrn:Say(MLin,QC210xCol(36),TRAN(SW6->W6_VLMLE + SW6->W6_INLAND +;// IF(BuscaPPCC()=="PP",SW9->W9_FRETEIN,0) + ;
                        //SW6->W6_PACKING - SW6->W6_DESCONT,"@E 9,999,999,999.9999"))
      
      /*oPrn:Say(MLin,QC210xCol(36),TRAN(SW6->W6_FOB_TOT + SW6->W6_INLAND + IF(BuscaPPCC()=="PP",SW6->W6_FRETEIN,0) + ;
                        SW6->W6_PACKING - SW6->W6_DESCONT,"@E 9,999,999,999.9999"))*/
      //SW9->(DBSETORDER(nOrdSW9))                  
    //ELSE                                
    aVal:= ConvDespFobMoeda(SW6->W6_HAWB,,,"FOB_TUDO")
    FOR Ind:=1 TO LEN(aVal)  
       oPrn:Say(MLin,QC210xCol(32),aVal[Ind,1]  )           	                
       oPrn:Say(MLin,QC210xCol(36),TRAN(aVal[Ind,2],cPicture))//LGS-25/07/2016
       MLin+=nPulaLin2
    NEXT       
    //ENDIF                  
    oPrn:Say(MLin,QC210xCol(56),aPrint:APELC_BAN)
    MLin+=nPulaLin2

NEXT
aLC:={}

MLin+=nPulaLin3

IF MLin > nLimPage
   TPC251CabAPE(PTipo)
ENDIF

TPC251Sub_Cab(STR0030) //"Embarque"
TPC251Embarque()
*IF(EMPTY(aAPE),aAPE:=Tb_Hawb,) // PARA EMBARQUES / DECLARARACAO DE IMPORTACAO
*                                  E C.I.F.  O PRG UTILIZA SEMPRE A TABELA DE
*                                  HAWB
*                                  RESOLVENDO O PROBLEMA DE QUANDO EXISTIA MAIS
*                                  DE UM REGISTRO NO APD , DUPLICAVA AS INFORMACOES
*                                  DESTAS IMPRESSOES

FOR Item=1 TO LEN(Tb_Hawb)

    IncProc(STR0146) //"Imprimindo Embarque"

    IF MLin > nLimPage
       TPC251CabAPE(PTipo)
       TPC251Sub_Cab("Embarque")
       TPC251Embarque()
    ENDIF

    aPrint:=Tb_Hawb[Item]

    SW6->(DBSEEK(xFilial("SW6")+aPrint:APEHAWB))

    oPrn:Say(MLin,QC210xCol(01),aPrint:APEHAWB)
    oPrn:Say(MLin,QC210xCol(20),DTOC(SW6->W6_DT_EMB))
    oPrn:Say(MLin,QC210xCol(30),IF(SY9->(DBSEEK(xFilial("SY9")+SW6->W6_LOCAL)),SY9->Y9_DESCR,''))
    oPrn:Say(MLin,QC210xCol(57),MSMM(SW6->W6_OBS,40,1,"",3))
    oPrn:Say(MLin,QC210xCol(99),DTOC(SW6->W6_DT_ENTR))
    MLin+=nPulaLin2

NEXT

MLin+=nPulaLin3

IF MLin > nLimPage
   TPC251CabAPE(PTipo)
ENDIF

TPC251Sub_Cab(STR0147) //"Declaracao de Importacao"
TPC251Declaracao()

FOR Item=1 TO LEN(Tb_Hawb)

   IncProc(STR0148) //"Imprimindo Declaracao de Importacao"

   IF MLin > nLimPage
      TPC251CabAPE(PTipo)
      TPC251Sub_Cab(STR0147) //"Declaracao de Importacao"
      TPC251Declaracao()
   ENDIF

   aPrint:=Tb_Hawb[Item]

   SW6->(DBSEEK(xFilial("SW6")+aPrint:APEHAWB))

   IF !EMPTY(SW6->W6_DI_NUM)
      oPrn:Say(MLin,QC210xCol(001),TRAN(SW6->W6_DI_NUM,'@R 99/9999'))
//      oPrn:Say(MLin,QC210xCol(001),TRAN(SW6->W6_DI_NUM,AVSX3("W6_NUM_DI", AV_PICTURE)))//acb - 16/04/2010
   ELSE
      LOOP
   ENDIF

   oPrn:Say(MLin,QC210xCol(014),DTOC(SW6->W6_DT))
   oPrn:Say(MLin,QC210xCol(023),DTOC(SW6->W6_DT_DESE))
   oPrn:Say(MLin,QC210xCol(033),SW6->W6_NF_ENT)
   oPrn:Say(MLin,QC210xCol(054),DTOC(SW6->W6_DT_NF))
   oPrn:Say(MLin,QC210xCol(063),TRAN(SW6->W6_VL_NF,cPicture))//LGS-25/07/2016
   oPrn:Say(MLin,QC210xCol(082),SW6->W6_NF_COMP)
   oPrn:Say(MLin,QC210xCol(092),DTOC(SW6->W6_DT_NFC))
   oPrn:Say(MLin,QC210xCol(102),TRAN(SW6->W6_VL_NFC,cPicture))//LGS-25/07/2016
   oPrn:Say(MLin,QC210xCol(121),SUBSTR(SW6->W6_IDENTVE,1,24))
   MLin+=nPulaLin2

NEXT

MLin+=nPulaLin3

IF MLin > nLimPage
   TPC251CabAPE(PTipo)
ENDIF

TPC251Sub_Cab(STR0119) //"C.I.F."
TPC251CIF()
nTxSeguro := BuscaTaxa(SW6->W6_SEGMOED,SW6->W6_DT,.T.,.F.,.T.)//RMD - 21/03/19
FOR Item=1 TO LEN(Tb_Hawb)

   IncProc(STR0149) //"Imprimindo C.I.F."

   IF MLin > nLimPage
      TPC251CabAPE(PTipo)
      TPC251Sub_Cab("C.I.F.")
      TPC251CIF()
   ENDIF

   aPrint:=Tb_Hawb[Item]

   SW6->(DBSEEK(xFilial("SW6")+aPrint:APEHAWB))

   IF !EMPTY(SW6->W6_DI_NUM)
     // oPrn:Say(MLin,QC210xCol(001),TRAN(SW6->W6_DI_NUM,'@R 99/9999999-9'))
      oPrn:Say(MLin,QC210xCol(001),TRAN(SW6->W6_DI_NUM,AVSX3("W6_DI_NUM", AV_PICTURE)))
   ELSE
      LOOP
   ENDIF

   oPrn:Say(MLin,QC210xCol(014),STR0150) //"FISCAL"
   //IF !EMPTY(SW6->W6_VLMLEMN)                    
     //nOrdSW9:=SW9->(INDEXORD())
     //SW9->(DBSETORDER(3))
     //SW9->(DBSEEK(xFilial("SW9")+SW6->W6_HAWB))
     //oPrn:Say(MLin,QC210xCol(0211),SW9->W9_MOE_FOB)
     //oPrn:Say(MLin,QC210xCol(025),TRAN(MFOB_Tot,"9,999,999,999.9999"))
     //SW9->(DBSETORDER(nOrdSW9))
   //ELSE  
   aVal:= ConvDespFobMoeda(SW6->W6_HAWB,,,"FOB_TUDO")
   FOR Ind:=1 TO LEN(aVal[1])  
      oPrn:Say(MLin,QC210xCol(32),aVal[1,Ind,1] )            	                
      oPrn:Say(MLin,QC210xCol(36),TRAN(aVal[1,Ind,2],cPicture))//LGS-25/07/2016
      MLin+=nPulaLin2
   NEXT
   //ENDIF   
   oPrn:Say(MLin,QC210xCol(045),SW6->W6_FREMOED)
   oPrn:Say(MLin,QC210xCol(049),TRAN(ValorFrete(SW6->W6_HAWB,,,2),cPicture))//LGS-25/07/2016
   oPrn:Say(MLin,QC210xCol(069),SW6->W6_SEGMOED)
   oPrn:Say(MLin,QC210xCol(073),TRAN(SW6->W6_VL_USSE,cPicture))//LGS-25/07/2016
   MLin+=nPulaLin2

   IF ! EMPTY(SW6->W6_TX_US_D)
      aVal :=  ConvDespFobMoeda(SW6->W6_HAWB,cMOEDAEST,SW6->W6_DT,"FOB_TUDO")
      CIF_US :=(VL_US:=aVal[1,2])
  //   CIF_US:=(VL_US:= MFOB_Tot *;
   //           (PAR_US:=SW6->W6_TX_FOB / SW6->W6_TX_US_D))
      oPrn:Say(MLin,QC210xCol(014),STR0151) //"REAL"
      oPrn:Say(MLin,QC210xCol(021),cMOEDAEST)
      oPrn:Say(MLin,QC210xCol(025),TRAN(VL_US,cPicture))//LGS-25/07/2016

      oPrn:Say(MLin,QC210xCol(045),cMOEDAEST)
//      IF SW6->W6_FREMOED # cMOEDAEST
         VL_US:=ValorFrete(SW6->W6_HAWB,cMOEDAEST,SW6->W6_DT,3) 
//      ELSE
//         VL_US:=SW6->W6_VL_FRET
//      ENDIF

      CIF_US+=VL_US
      oPrn:Say(MLin,QC210xCol(049),TRAN(VL_US,"999,999,999,999.99"))

      oPrn:Say(MLin,QC210xCol(069),cMOEDAEST)

      IF SW6->W6_SEGMOED # cMOEDAEST .AND. ! EMPTY(SW6->W6_SEGMOED)
         IF SW6->W6_SEGMOED # SW2->W2_MOEDA
            PAR_US:=nTxSeguro /*BuscaTaxa(SW6->W6_SEGMOED,SW6->W6_DT,.T.,.F.,.T.)*/ /;
                    SW6->W6_TX_US_D
         ENDIF
         VL_US:=SW6->W6_VL_USSE*PAR_US
      ELSE
         VL_US:=SW6->W6_VL_USSE
      ENDIF

      CIF_US+=VL_US
      oPrn:Say(MLin,QC210xCol(073),TRAN(VL_US,"999,999,999,999.99"))
      oPrn:Say(MLin,QC210xCol(093),TRAN(CIF_US,"999,999,999,999.99"))
      MLin+=nPulaLin2

   ENDIF

NEXT

aAPE:={}

MLin+=nPulaLin3

IF MLin > nLimPage
   TPC251CabAPE(PTipo)
ENDIF

TPC251Sub_Cab(STR0152) //"Seguro"
TPC251Seguros()

FOR Item=1 TO LEN(aSeguro)

   IncProc(STR0153) //"Imprimindo Seguro"

   IF MLin > nLimPage
       TPC251CabAPE(PTipo)
       TPC251Sub_Cab(STR0152) //"Seguro"
       TPC251Seguros()
    ENDIF

    aPrint:=aSeguro[Item]

    oPrn:Say(MLin,QC210xCol(001), aPrint:APESE_AP)
    oPrn:Say(MLin,QC210xCol(028), DTOC(aPrint:APESE_DT))
    oPrn:Say(MLin,QC210xCol(038), DTOC(aPrint:APESE_VEN))
    oPrn:Say(MLin,QC210xCol(048), "P - "+aPrint:APESE_AVP+' '+DTOC(aPrint:APESE_AVPD))
    oPrn:Say(MLin,QC210xCol(088), TRAN(aPrint:APESE_VAL,"999,999,999,999.99"))
    oPrn:Say(MLin,QC210xCol(108), TRAN(aPrint:APESE_FRQ,"999,999,999,999.99"))
    MLin+=nPulaLin2

    oPrn:Say(MLin,QC210xCol(048), "D - "+aPrint:APESE_AVD+' '+DTOC(aPrint:APESE_AVDD))
    MLin+=nPulaLin2

NEXT

aSeguro:={}

RETURN .T.
*---------------------------*
FUNCTION TPC251CabAPE(PTipo)
*---------------------------*
LOCAL MSubCab:=IF(PTipo == Por_Item,STR0075,; //"P O R   I T E M"
                                    STR0076) //"P O R   P U R C H A S E   O R D E R"

oPrn:oFont:=COURIER_07

IF !lPrimPag
   AVNEWPAGE
ENDIF

MLin:= 100
MPag++

oPrn:Box( MLin,nColIni,MLin+1,nColFim)
MLin+=nPulaLin1

oPrn:Say(MLin,nColIni,SM0->M0_NOME,COURIER_10)
oPrn:Say(MLin,(nColFim/2),Titulo,COURIER_10,,,,2)
oPrn:Say(MLin,(nColFim-20),STR0079+STR(MPag,8),COURIER_10,,,,1) //"Pagina..: "
MLin+=nPulaLin3

oPrn:Say(MLin,nColIni,"SIGAEIC",COURIER_10)
oPrn:Say(MLin,(nColFim/2),MSubCab,COURIER_10,,,,2)
oPrn:Say(MLin,(nColFim-20),STR0080+DTOC(dDataBase),COURIER_10,,,,1) //"Emissao.: "
MLin+=nPulaLin3

oPrn:oFont:=COURIER_07
oPrn:Box( MLin,nColIni,MLin+1,nColFim)
MLin+=nPulaLin1

oPrn:Say(MLin,QC210xCol(003),STR0081) //"Nr. PO....: "
oPrn:Say(MLin,QC210xCol(054),STR0085) //"Importador: "
oPrn:Say(MLin,QC210xCol(017),SW2->W2_PO_NUM)

SYT->(DBSEEK(xFilial("SYT")+SW2->W2_IMPORT))
oPrn:Say(MLin,QC210xCol(068),SW2->W2_IMPORT+" "+SUBSTR(SYT->YT_NOME,1,30))

MLin+=nPulaLin3

RETURN .T.

*----------------------------------*
FUNCTION TPC251Sub_Cab( Cabecalho )
*----------------------------------*
oPrn:Say(MLin,QC210xCol(01),Cabecalho)
MLin+=nPulaLin3
oPrn:Box( MLin,nColIni,MLin+1,nColFim)
MLin+=nPulaLin1

RETURN NIL
*----------------------*
FUNCTION TPC251Embarque
*----------------------*
*Hawb          Data      Destino                    Observacoes
*xxxxxxxxxxxx  xx/xx/xx  XXXXXXXXXXXXXXXXXXXXXXXXX  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

oPrn:Say(MLin,QC210xCol(01),STR0027) //"Nr. Processo"
oPrn:Say(MLin,QC210xCol(20),STR0021) //"Data"
oPrn:Say(MLin,QC210xCol(30),STR0039) //"Destino"
oPrn:Say(MLin,QC210xCol(57),STR0154) //"Observacoes"
oPrn:Say(MLin,QC210xCol(99),STR0155) //"Entrega"
MLin+=nPulaLin2

oPrn:Say(MLin,QC210xCol(01),REPLI('-',17))
oPrn:Say(MLin,QC210xCol(20),REPLI('-',08))
oPrn:Say(MLin,QC210xCol(30),REPLI('-',25))
oPrn:Say(MLin,QC210xCol(57),REPLI('-',40))
oPrn:Say(MLin,QC210xCol(99),"--------")
MLin+=nPulaLin2

RETURN NIL
*-----------------------*
FUNCTION TPC251GuiasImp
*-----------------------*
*Guias             Data      Vencto         Frete Interno          Embalagem           Desconto  Aditivos         Data     Vencto
*9999-99/999999-9  xx/xx/xx  xx/xx/xx  999,999,999,999.99 999,999,999,999.99 999,999,999,999.99  9999-99/999999-9 xx/xx/xx xx/xx/xx
*Guias             Data      Vencto    Aditivos         Data     Vencto
*9999-99/999999-9  xx/xx/xx  xx/xx/xx  9999-99/999999-9 xx/xx/xx xx/xx/xx

oPrn:Say(MLin,QC210xCol(001),STR0156) //"Guias"
oPrn:Say(MLin,QC210xCol(019),STR0021) //"Data"
oPrn:Say(MLin,QC210xCol(029),STR0157) //"Vencto"
oPrn:Say(MLin,QC210xCol(039),STR0158) //"Aditivos"
oPrn:Say(MLin,QC210xCol(057),STR0021) //"Data"
oPrn:Say(MLin,QC210xCol(066),STR0157) //"Vencto"
MLin+=nPulaLin2

oPrn:Say(MLin,QC210xCol(001),REPLI('-',16))
oPrn:Say(MLin,QC210xCol(019),REPLI('-',08))
oPrn:Say(MLin,QC210xCol(029),REPLI('-',08))
oPrn:Say(MLin,QC210xCol(039),REPLI('-',16))
oPrn:Say(MLin,QC210xCol(057),REPLI('-',08))
oPrn:Say(MLin,QC210xCol(066),REPLI('-',08))
MLin+=nPulaLin2

RETURN NIL

*------------------------------*
FUNCTION TPC251GIDet(aPrint)
*------------------------------*
oPrn:Say(MLin,QC210xCol(001),TRAN(aPrint:GIGI_NUM,"@R 9999-99/999999-9"))
oPrn:Say(MLin,QC210xCol(019),DTOC(aPrint:GIDT))
oPrn:Say(MLin,QC210xCol(029),DTOC(aPrint:GIDT_VEN))

RETURN NIL

*--------------------------*
FUNCTION TPC251ContrCambio
*--------------------------*
*Contrato        Data     Valor na Moeda         Taxa           Valor em R$          Banco
*XXXXXXXXXXXXXXX XX/XX/XX XXX 9,999,999,999.9999 999,999.99999999 999,999,999,999.9999 xxxxxxxxxxxxxxxxxxxx

oPrn:Say(MLin,QC210xCol(001),STR0159) //"Contrato"
oPrn:Say(MLin,QC210xCol(017),STR0021) //"Data"
oPrn:Say(MLin,QC210xCol(026),STR0160) //"Valor na Moeda"
oPrn:Say(MLin,QC210xCol(049),STR0161) //"Taxa"
oPrn:Say(MLin,QC210xCol(066),STR0162) //"Valor em R$"
MLin+=nPulaLin2

oPrn:Say(MLin,QC210xCol(001),REPLI('-',15))
oPrn:Say(MLin,QC210xCol(017),REPLI('-',08))
oPrn:Say(MLin,QC210xCol(026),REPLI('-',22))
oPrn:Say(MLin,QC210xCol(049),REPLI('-',16))
oPrn:Say(MLin,QC210xCol(066),REPLI('-',20))
MLin+=nPulaLin2

RETURN NIL

*-----------------------*
FUNCTION TPC251CartasCred
*-----------------------*
*Numero     Data      Vencto    Valor na Moeda          Banco
*xxxxxxxxx  xx/xx/xx  xx/xx/xx  xxx 9,999,999,999.9999  xxxxxxxxxxxxxxxxxxxx

oPrn:Say(MLin,QC210xCol(01),STR0163) //"Numero"
oPrn:Say(MLin,QC210xCol(12),STR0021) //"Data"
oPrn:Say(MLin,QC210xCol(22),STR0157) //"Vencto"
oPrn:Say(MLin,QC210xCol(32),STR0160) //"Valor na Moeda"
oPrn:Say(MLin,QC210xCol(56),STR0164) //"Banco"
MLin+=nPulaLin2

oPrn:Say(MLin,QC210xCol(01),REPLI('-',10))
oPrn:Say(MLin,QC210xCol(12),REPLI('-',08))
oPrn:Say(MLin,QC210xCol(22),REPLI('-',08))
oPrn:Say(MLin,QC210xCol(32),REPLI('-',22))
oPrn:Say(MLin,QC210xCol(56),REPLI('-',20))
MLin+=nPulaLin2

RETURN NIL

*-------------------*
FUNCTION TPC251APEs
*-------------------*
*Numero  Data     Cedente              Sacado               Invoice         Data     Vencto
*xXXXXXX xx/xx/xx xxxxxxxxxxxxxxxxxxxx xxxxxxxxxxxxxxxxxxxx xxxxxxxxxxxxxxx xx/xx/xx xx/xx/xx

oPrn:Say(MLin,QC210xCol(01),STR0181)//'Numero' 
oPrn:Say(MLin,QC210xCol(12),STR0182)//'Data'   
oPrn:Say(MLin,QC210xCol(22),STR0183)//'Cedente'
oPrn:Say(MLin,QC210xCol(44),STR0184)//'Sacado' 
oPrn:Say(MLin,QC210xCol(66),STR0185)//'Invoice'
oPrn:Say(MLin,QC210xCol(82),STR0186)//'Data'   
oPrn:Say(MLin,QC210xCol(91),STR0187)//'Vencto' 
MLin+=nPulaLin2

oPrn:Say(MLin,QC210xCol(01),REPLI('-',10))
oPrn:Say(MLin,QC210xCol(12),REPLI('-',08))
oPrn:Say(MLin,QC210xCol(22),REPLI('-',20))
oPrn:Say(MLin,QC210xCol(44),REPLI('-',20))
oPrn:Say(MLin,QC210xCol(66),REPLI('-',15))
oPrn:Say(MLin,QC210xCol(82),REPLI('-',08))
oPrn:Say(MLin,QC210xCol(91),REPLI('-',08))
MLin+=nPulaLin2

RETURN NIL

*------------------------*
FUNCTION TPC251Declaracao
*------------------------*
*Numero       Emissao  Liberacao Nota Fiscal Entrada  Data                  Valor N.F.Comp. Data                   Valor
*99/9999999-9 xx/xx/xx xx/xx/xx  xxxxxxxxxxxxxxxxxxxx xx/xx/xx 999.999.999.999,99 xxxxx     xx/xx/xx  999.999.999.999,99 123456789012345678901234

oPrn:Say(MLin,QC210xCol(001),STR0163) //"Numero"
oPrn:Say(MLin,QC210xCol(014),STR0165) //"Emissao"
oPrn:Say(MLin,QC210xCol(023),STR0166) //"Desemb."
oPrn:Say(MLin,QC210xCol(033),STR0167) //"Nota Fiscal Entrada"
oPrn:Say(MLin,QC210xCol(054),STR0021) //"Data"
oPrn:Say(MLin,QC210xCol(076),STR0168) //"Valor"
oPrn:Say(MLin,QC210xCol(082),STR0169) //"N.F.Comp."
oPrn:Say(MLin,QC210xCol(092),STR0021) //"Data"
oPrn:Say(MLin,QC210xCol(115),STR0168) //"Valor"
oPrn:Say(MLin,QC210xCol(121),STR0170) //"Embarcacao"
MLin+=nPulaLin2

oPrn:Say(MLin,QC210xCol(001),REPLI('-',12))
oPrn:Say(MLin,QC210xCol(014),REPLI('-',08))
oPrn:Say(MLin,QC210xCol(023),REPLI('-',09))
oPrn:Say(MLin,QC210xCol(033),REPLI('-',20))
oPrn:Say(MLin,QC210xCol(054),REPLI('-',08))
oPrn:Say(MLin,QC210xCol(063),REPLI('-',18))
oPrn:Say(MLin,QC210xCol(082),REPLI('-',09))
oPrn:Say(MLin,QC210xCol(092),REPLI('-',08))
oPrn:Say(MLin,QC210xCol(102),REPLI('-',18))
oPrn:Say(MLin,QC210xCol(121),REPLI('-',24))
MLin+=nPulaLin2

RETURN NIL

*---------------------*
FUNCTION TPC251CIF
*---------------------*
*DI No.                        F.O.B.                   FRETE                  SEGURO               TOTAL
*999999 FISCAL xxx 9,999,999,999.9999  xxx 9,999,999,999.9999  xxx 9,999,999,999.9999  9,999,999,999.9999
oPrn:Say(MLin,QC210xCol(001),STR0171) //"DI No."
oPrn:Say(MLin,QC210xCol(037),STR0172) //"F.O.B."
oPrn:Say(MLin,QC210xCol(062),STR0173) //"FRETE"
oPrn:Say(MLin,QC210xCol(085),STR0152) //"SEGURO"
oPrn:Say(MLin,QC210xCol(106),STR0174) //"TOTAL"
MLin+=nPulaLin2

oPrn:Say(MLin,QC210xCol(001),REPLI('-',12))
oPrn:Say(MLin,QC210xCol(021),REPLI('-',22))
oPrn:Say(MLin,QC210xCol(045),REPLI('-',22))
oPrn:Say(MLin,QC210xCol(069),REPLI('-',22))
oPrn:Say(MLin,QC210xCol(094),REPLI('-',18))
MLin+=nPulaLin2

RETURN NIL

*-----------------------*
FUNCTION TPC251Seguros()
*-----------------------*
*Apolice                    Data      Vencto    Averbacoes                              Valor               Franquia
*xxxxxxxxxxxxxxxxxxxxxxxxx  xx/xx/xx  xx/xx/xx  P - xxxxxxxxxxxxxxxxxxxxxxxxx xx/xx/xx  999,999,999,999.99  999,999,999,999.99
*                                               D - xxxxxxxxxxxxxxxxxxxxxxxxx xx/xx/xx
oPrn:Say(MLin,QC210xCol(001),STR0175   ) //"Apolice"
oPrn:Say(MLin,QC210xCol(028),STR0021      ) //"Data"
oPrn:Say(MLin,QC210xCol(038),STR0157    ) //"Vencto"
oPrn:Say(MLin,QC210xCol(048),STR0176) //"Averbacoes"
oPrn:Say(MLin,QC210xCol(088),STR0168     ) //"Valor"
oPrn:Say(MLin,QC210xCol(108),STR0177  ) //"Franquia"
MLin+=nPulaLin2

oPrn:Say(MLin,QC210xCol(001),REPLI('-',25))
oPrn:Say(MLin,QC210xCol(028),REPLI('-',08))
oPrn:Say(MLin,QC210xCol(038),REPLI('-',08))
oPrn:Say(MLin,QC210xCol(048),REPLI('-',38))
oPrn:Say(MLin,QC210xCol(088),REPLI('-',18))
oPrn:Say(MLin,QC210xCol(108),REPLI('-',18))
MLin+=nPulaLin2

RETURN NIL

*---------------------------------------------------*
FUNCTION TPC251_Apuracao (PTipo)
*---------------------------------------------------*
LOCAL MTotGer_P:=MTotGer_R:=MCus_T_P:=MCus_T_R:=0, PData:=AVCTOD('')
LOCAL cPointE:="TP25101E", cPointS:="EICTP01S"
LOCAL lPointE:=EasyEntryPoint(cPointE), lPointS:=EasyEntryPoint(cPointS)
//              MCus_T_P                 MCus_T_R
// -----------  ---------------------    ----------------------
// Pre-Calculo  CUSTO EM REAIS           CUSTO EM US$
// Realizado      "    "   "               "   "   "
// Comparativo  CUSTO PREVISTO EM US$    CUSTO REALIZADO EM US$

// ATENCAO: despesas da GI (inland, packing, desconto) nao entram na apuracao,
//          pois ela se baseia em valores reais pagos

LOCAL MTx_Usd, MTx_Usd_Pc:=0, MRecno, nRecSWH := 0, nRecSWH2 := 0, nValor := 0, nValorRS := 0, cAlias := ""

LOCAL MCod_I_Sal, MControle_Sal, nTX_US, MCod_RegTrib                        //NCF - 28/01/2013

* LOCAL b_US:={|dt| IF(EMPTY(nTX_US:=BuscaTaxa(cMOEDAEST,dt)),;
*                            nTX_US:=BuscaTaxa(cMOEDAEST,dt),) , nTX_US }

LOCAL b_US:={|dt| IF(EMPTY(nTX_US:=BuscaTaxa(cMOEDAEST,dt,.T.,.F.,.T.)),;
                           nTX_US:=BuscaTaxa(cMOEDAEST,dt,.T.,.F.,.T.),) , nTX_US }

Local aControle := {} //RRV - 27/12/2012
Local lDspIInoCIF := EasyGParam("MV_EIC0068",,0) == 2 //NCF - 04/01/2018 - Nesta config. as despesas base de II são somadas ao total do CIF no rel. pré-cálculo
Local MDsBII_T_P := 0, MDsBII_T_R := 0, aValores := {0,0}
Local cViaTPC, cTabTPC
PRIVATE MTotCif_P:=MTotCif_R:=0 //variaveis para RDMAKE

*
* Funcao utilizada para apurar Pre_calculo e Custo Realizado. Gera registros
* por ITEM ou por P.O. em arquivo temporario Work2 que sera utilizado nos
* programas chamadores.
*  SE Work_2->WKCOD_I = vazio Indentifica registro de P.O.
*                       SENAO Indentifica registro de ITEM
*****************************************************************************
DBSELECTAREA("Work_1")  ;  DBSETORDER(2)  ; DBGOTOP()

ProcRegua(Work_1->(LASTREC()))

nTamCont:=AVSX3("WH_NR_CONT",3)

WHILE ! EOF()

  IF PTipo == Por_Item
     IF WKFLAG = "N"
        MCod_I_Sal:= WKCOD_I ; MControle_Sal:= VAL(WKCONTROLE)
        If lRegTriPO                                                                       //NCF - 28/01/2013
           MCod_RegTrib := WKGRUPORT
        EndIf
        WHILE ! EOF() .AND. WKCOD_I    = MCod_I_Sal ;
                      .AND. VAL(WKCONTROLE) = MControle_Sal ;
                      .AND. If(lRegTriPO,WKGRUPORT = MCod_RegTrib,.T.)
              IncProc(STR0178+Work_1->WKCOD_I) //"Processando Pre-Calculo Item "
              DBSKIP() ; LOOP
        END
        LOOP
     ENDIF
  ENDIF
 //MFR 20/08/2019 OSSME-2689
 /* COMENTADO PQ TODA VEZ QUE PASSA POR OUTRAS AÇÕES, GERA RELATÓRIO DUPLICAVA NA TABELA SSW
  If MParam == Pre_Calculo .AND. SWH->(DBSEEK(xFilial("SWH")+Work_1->WKPO_NUM+STR(Work_1->WKCONT_IP,nTamCont,0)))  // GFP - 02/12/2016
     cAlias := Alias()
     Do While SWH->(!Eof()) .AND. SWH->(WH_FILIAL+WH_PO_NUM+STR(WH_NR_CONT,4,0)) == xFilial("SWH")+Work_1->WKPO_NUM+STR(Work_1->WKCONT_IP,nTamCont,0)
        nRecSWH := If(SWH->WH_DESPESA == DESPESA_FOB,SWH->(Recno()),nRecSWH)                            
        If (SWH->WH_DESPESA == DESPESA_FRETE  .AND. AvRetInco(AllTrim(SW2->W2_INCOTER),"CONTEM_FRETE")  .AND. SW2->W2_FREINC $ cSim ) .OR.;
           (SWH->WH_DESPESA == DESPESA_SEGURO .AND. AvRetInco(AllTrim(SW2->W2_INCOTER),"CONTEM_SEG")  .AND. SW2->W2_SEGINC $ cSim  )
           nRecSWH2 := SWH->(Recno())
           nValor := SWH->WH_VALOR
           nValorRS := SWH->WH_VALOR_R
           SWH->(DbGoTo(nRecSWH))
           If RecLock("SWH",.F.)
              SWH->WH_VALOR_R -= nValorRS
              SWH->WH_VALOR -= nValor
              SWH->(MsUnlock())
           EndIf
           SWH->(DbGoTo(nRecSWH2))
           nRecSWH2 := 0
           nValor := 0
           nValorRS := 0
        EndIf      
        SWH->(DbSkip())
     EndDo
     DbSelectArea(cAlias)
  EndIf */
  
  //NCF - 10/01/2017 - apurar despesas base para compor CIF no relatorio
  /*lDspIInoCIF := EasyGParam("MV_EIC0068",,0) == 2 
  If lDspIInoCIF 
     aValores := EDspBsImp(pTipo,Work_1->WKPO_NUM,Work_1->WKCONT_IP)
     MDsBII_T_R := aValores[1]//+= If( !aValidDBII[1] , SWH->WH_VALOR   , 0 )
     MDsBII_T_P := aValores[2]//If( !aValidDBII[1] , SWH->WH_VALOR_R , 0 )
  EndIf */ 

  MFirst:= .T.
  MControle_Sal:= VAL(Work_1->WKCONTROLE)
  MCod_I_Sal   := Work_1->WKCOD_I
  If lRegTriPO
     MCod_RegTrib := Work_1->WKGRUPORT
  EndIf
  WHILE ! EOF() .AND. MCod_I_Sal    = Work_1->WKCOD_I ;
                .AND. MControle_Sal = VAL(Work_1->WKCONTROLE);
                .AND. If(lRegTriPO,WKGRUPORT = MCod_RegTrib,.T.)
     
     //RRV - 27/12/2012 - Verifica se o numero de controle atual já foi somado.
     //NCF - 28/01/2013 - Verificar po Cod.produto + Reg. Tributação(quando houver)
     //If aScan(aControle,STR(Work_1->WKCONT_IP)+If(lRegTriPO,"WKGRUPORT","")) > 0 //comentado por WFS
     If AScan(aControle, {|x| x == STR(Work_1->WKCONT_IP)+If(lRegTriPO,"WKGRUPORT","")}) > 0
        DbSkip()
        Loop
     EndIf

     IF MParam == Pre_X_Real .OR. MParam == Pre_Calculo
        IF MFirst
           SWH->(DBSEEK(xFilial("SWH")+Work_1->WKPO_NUM+STR(Work_1->WKCONT_IP,nTamCont,0)))
           WHILE ! SWH->(EOF()) .AND. ;
              Work_1->WKPO_NUM  = SWH->WH_PO_NUM .AND. ;
              Work_1->WKCONT_IP = SWH->WH_NR_CONT .AND. SWH->WH_FILIAL == xFilial("SWH")

              IF EMPTY(MTx_Usd_PC)
//               MTx_Usd_Pc:=EVAL(b_US,SW2->W2_PO_DT)
//               MTx_Usd_Pc:=EVAL(b_US,dDataBase)  // RA - 13/08/2003 - O.S. 746/03 e 748/03
                 MTx_Usd_Pc:=EVAL(b_US,dDataConTx) // RA - 13/08/2003 - O.S. 746/03 e 748/03
                 IF SW2->W2_PO_DT < AVCTOD("01/07/94")
                    MTx_Usd_PC/=2750
                 ENDIF
              ENDIF
              IF MParam == Pre_Calculo
                 MCus_T_P:= SWH->WH_VALOR_R //RRV - 27/12/2012 - Carregada agora direto da tabela física com o valor em Reais.
                 MCus_T_R:= SWH->WH_VALOR
              ELSE
                 MCus_T_P:= SWH->WH_VALOR
                 MCus_T_R:= 0
              ENDIF

              lDspIInoCIF := EasyGParam("MV_EIC0068",,0) == 2 .And. (SWH->WH_DESPESA == DESPESA_FOB) //NCF - 10/01/2017
              If lDspIInoCIF 
                 aValores := EDspBsImp("1",Work_1->WKPO_NUM,Work_1->WKCONT_IP)
                 MDsBII_T_R := aValores[1]
                 MDsBII_T_P := aValores[2]
              EndIf  
* Acumula Item ---------------------------------------------------------------
              TPC251Grv_WK2(PTipo,SWH->WH_DESPESA,MCus_T_P,MCus_T_R,,,IF((GetNewPar("MV_EASYFIN","N")='S' .Or. lAvIntDesp) .AND. !(cPaisLoc='BRA'),SWH->WH_DESC,' ')) //wfs 03/07/2014 - atualização dos valores para integração via EAI

* Totais do Grupo X.99 -------------------------------------------------------
              TPC251Grv_WK2(PTipo,LEFT(SWH->WH_DESPESA,1) + ;
                            DESPESA_SUBTOT, MCus_T_P + If(lDspIInoCIF,MDsBII_T_P,0), MCus_T_R + If(lDspIInoCIF,MDsBII_T_R,0) )

* Total Geral  8.98 S/IPI S/ICMS, 8.97 S/IPI C/ICMS,8.96 C/IPI S/ICMS---------------------------
            //PTipo == Por_PO .AND. 
            IF MParam== Pre_Calculo 
               IF SWH->WH_DESPESA # DESPESA_IPI .AND. SWH->WH_DESPESA # "203" //SEM IPI SEM ICMS
                  TPC251Grv_WK2 (PTipo,DESP_GERAL_SEM,MCus_T_P,MCus_T_R)
               ENDIF
               IF SWH->WH_DESPESA # DESPESA_IPI   //SEM IPI COM ICMS
                  TPC251Grv_WK2 (PTipo,DESP_GERAL_ICMS,MCus_T_P,MCus_T_R)      
               ENDIF
               IF SWH->WH_DESPESA # "203"         //COM IPI SEM ICMS
                  TPC251Grv_WK2 (PTipo,DESP_GERAL_IPI,MCus_T_P,MCus_T_R)
               ENDIF                                  

               IF SWH->WH_DESPESA # "204".AND. SWH->WH_DESPESA # "205"
                  TPC251Grv_WK2 (PTipo,"T93",MCus_T_P,MCus_T_R)
               ENDIF                                  
               IF SWH->WH_DESPESA # "204"         //SEM PIS COM COFINS
                  TPC251Grv_WK2 (PTipo,"T94",MCus_T_P,MCus_T_R)
               ENDIF                                  
               IF SWH->WH_DESPESA # "205"         //COM PIS SEM COFINS
                  TPC251Grv_WK2 (PTipo,"T95",MCus_T_P,MCus_T_R)
               ENDIF                                  
               IF !(SWH->WH_DESPESA $ DESPESA_IPI+"/203/204/205")
                  TPC251Grv_WK2 (PTipo,DESP_GERAL_SEM_IMP,MCus_T_P,MCus_T_R)
               EndIf
            ENDIF

* Total Geral  8.99 ----------------------------------------------------------
              TPC251Grv_WK2(PTipo,DESPESA_GERAL,MCus_T_P,MCus_T_R)

              SWH->(DBSKIP())

           ENDDO
           MFirst := If(lAvFluxo,MFirst:= .F.,MFirst)  // GFP - 07/10/2014
        ENDIF
     ENDIF

     IF MParam == Realizado .OR. MParam == Pre_X_Real
        SW6->(DBSEEK(xFilial("SW6")+Work_1->WKHAWB))
        MCus_T_P:=MCus_T_R:=0

        TPC251FOB(PTipo,b_US)

        WHILE ! SWD->(EOF()) .AND. ;
                SWD->WD_HAWB = SW6->W6_HAWB .AND. SWD->WD_FILIAL == xFilial("SWD")

           IF LEFT(SWD->WD_DESPESA,1) = "9" .OR. SWD->WD_DESPESA = DESPESA_FOB
              SWD->(DBSKIP())
              LOOP
           ENDIF

           MTx_Usd:= EVAL(b_US,SWD->WD_DES_ADI)

           IF MParam = Realizado
              IF SWD->WD_DES_ADI < AVCTOD("01/07/94")  // Em Reais
                 MCus_T_P := TPC251_T_R_Cus(2750)
              ELSE
                 MCus_T_P := TPC251_T_R_Cus(1)
              ENDIF
           ENDIF
           MCus_T_R := TPC251_T_R_Cus(MTx_Usd)

* Acumula Item ------------------------------------------------------------------------
           TPC251Grv_WK2 (PTipo,SWD->WD_DESPESA,MCus_T_P,MCus_T_R,SWD->WD_DES_ADI)

* Totais do Grupo X.99 ----------------------------------------------------------------
           TPC251Grv_WK2 (PTipo,LEFT(SWD->WD_DESPESA,1) + ;
                          DESPESA_SUBTOT,MCus_T_P,MCus_T_R)

* Total Geral  8.98 S/IPI S/ICMS, 8.97 S/IPI C/ICMS,8.96 C/IPI S/ICMS---------------------------

            IF PTipo == Por_PO .AND. MParam== Realizado
               IF SWD->WD_DESPESA # DESPESA_IPI .AND. SWD->WD_DESPESA # "203" //SEM IPI SEM ICMS
                  TPC251Grv_WK2 (PTipo,DESP_GERAL_SEM,MCus_T_P,MCus_T_R)
               ENDIF
               IF SWD->WD_DESPESA # DESPESA_IPI   //SEM IPI COM ICMS
                  TPC251Grv_WK2 (PTipo,DESP_GERAL_ICMS,MCus_T_P,MCus_T_R)      
               ENDIF
               IF SWD->WD_DESPESA # "203"         //COM IPI SEM ICMS
                  TPC251Grv_WK2 (PTipo,DESP_GERAL_IPI,MCus_T_P,MCus_T_R)
               ENDIF

               IF SWD->WD_DESPESA # "204".AND. SWD->WD_DESPESA # "205"
                  TPC251Grv_WK2 (PTipo,"T93",MCus_T_P,MCus_T_R)
               ENDIF                                  
               IF SWD->WD_DESPESA # "204"         //SEM PIS COM COFINS
                  TPC251Grv_WK2 (PTipo,"T94",MCus_T_P,MCus_T_R)
               ENDIF                                  
               IF SWD->WD_DESPESA # "205"         //COM PIS SEM COFINS
                  TPC251Grv_WK2 (PTipo,"T95",MCus_T_P,MCus_T_R)
               ENDIF                        
               IF !(SWH->WH_DESPESA $ DESPESA_IPI+"/203/204/205")
                  TPC251Grv_WK2 (PTipo,DESP_GERAL_SEM_IMP,MCus_T_P,MCus_T_R)
               EndIf          

            ENDIF
* Total Geral  8.99 -------------------------------------------------------------------
           TPC251Grv_WK2 (PTipo,DESPESA_GERAL,MCus_T_P,MCus_T_R)
           SWD->(DBSKIP())
        ENDDO
     ENDIF
     IncProc(STR0178+Work_1->WKCOD_I) //"Processando Pre-Calculo Item "
     
     //RRV - 27/12/2012 - Adiciona no array os WKCONT_IP que já foram somados no pre-calculo.
     //NCF - 28/01/2013 - Adiciona o Cod.produto + Reg. Tributação(quando houver)
     aAdd(aControle,STR(Work_1->WKCONT_IP)+If(lRegTriPO,"WKGRUPORT",""))
     
     DBSKIP()
  ENDDO

ENDDO

// ATUALIZA CUSTO UNITARIO

Work_1->(DBSETORDER(1))

DBSELECTAREA("Work_2") ; DBGOTOP()

If lPointE .And. !ExecBlock(cPointE)
   Return .F.
Endif

ProcRegua(Work_2->(LASTREC()))

WHILE ! EOF()

   MRecno:=RECNO()

* ALTERACAO PEDIDA POR LAB EM 18:01 13 Nov,1995
* VALOR BASE PARA PERCENTUAIS AGORA E' O FOB E NAO MAIS O CIF

*   DBSEEK( Work_2->WKCOD_I+DESPESA_CIF )   && Total CIF
    DBSEEK( Work_2->WKCOD_I+If(lRegTriPO,Work_1->WKGRUPORT,"")+DESPESA_FOB )   && Total FOB //MCF-13/05/2015
   MItem_Ant := Work_2->WKCOD_I
   WHILE ! EOF() .AND. MItem_Ant=Work_2->WKCOD_I .AND. Work_2->WKDESPESA == DESPESA_FOB
      MTotCif_P += Work_2->WKCUS_T_P
      MTotCif_R += Work_2->WKCUS_T_R
      IncProc(STR0178+Work_2->WKCOD_I) //"Processando Pre-Calculo Item "
      DBSKIP()
   ENDDO
   
   DBSEEK( Work_2->WKCOD_I+If(lRegTriPO,Work_1->WKGRUPORT,"")+DESPESA_GERAL )   && Total Geral //MCF-13/05/2015
   MTotGer_P := Work_2->WKCUS_T_P
   MTotGer_R := Work_2->WKCUS_T_R

   DBGOTO(MRecno)

   MItem_Ant:= Work_2->WKCOD_I
   DO WHILE ! EOF() .AND. MItem_Ant=Work_2->WKCOD_I

      IF PTipo # Por_PO
         Work_1->(DBSETORDER(1))
         IF Work_1->(DBSEEK("S" + Work_2->WKCOD_I ))
            Work_2->WKCUS_U_P := IF(Work_1->WKQTD_ACU>0,WKCUS_T_P / Work_1->WKQTD_ACU,0)
            Work_2->WKCUS_U_R := IF(Work_1->WKQTD_ACU>0,WKCUS_T_R / Work_1->WKQTD_ACU,0)
         ENDIF
         Work_2->WKVARCUS_U := Percentual(WKCUS_U_R,WKCUS_U_P,1)
      ENDIF

      Work_2->WKVARCUS_T := Percentual(WKCUS_T_R,WKCUS_T_P,1)

      Work_2->WKPERPAR_P := Percentual(WKCUS_T_P,MTotGer_P,0)
      Work_2->WKPERPAR_R := Percentual(WKCUS_T_R,MTotGer_R,0)

/*      IF Work_2->WKDESPESA=DESPESA_GERAL .OR.  Work_2->WKDESPESA=DESPESA_CIF .OR. ;
         Work_2->WKDESPESA=DESP_GERAL_SEM .OR. Work_2->WKDESPESA=DESP_GERAL_IPI .OR. ;
         Work_2->WKDESPESA=DESP_GERAL_ICMS

         Work_2->WKPERCIF_P := Percentual(WKCUS_T_P ,MTotCif_P,0)  //Percentual(WKCUS_T_P ,MTotCif_P,1)
         Work_2->WKPERCIF_R := Percentual(WKCUS_T_R ,MTotCif_R,0)  //Percentual(WKCUS_T_R ,MTotCif_R,1)
      ELSE*/
         Work_2->WKPERCIF_P := Percentual(WKCUS_T_P,MTotCif_P,0)
         Work_2->WKPERCIF_R := Percentual(WKCUS_T_R,MTotCif_R,0)
//      ENDIF
      IF EasyEntryPoint("EICTP251")        
        EXECBLOCK( "EICTP251",.F.,.F.,"PERC_DESPESA")
      ENDIF

      IncProc(STR0178+Work_2->WKCOD_I) //"Processando Pre-Calculo Item "
      DBSKIP()
   ENDDO

ENDDO

If lPointS
   ExecBlock(cPointS)
Endif

DBGOTOP()
DBSELECTAREA("Work_1")

RETURN .T.
*--------------------------------------------------------------------------*
// FUNCAO RECURSIVA !
FUNCTION TPC251Grv_WK2 (PTipo,PDespesa,PCus_T_P,PCus_T_R,PDes_ADI,PAcumImp,PDescImp)
*--------------------------------------------------------------------------*
LOCAL MCod_I:=IF(PTipo == Por_PO,SPACE(LEN(Work_1->WKCOD_I)),Work_1->WKCOD_I),lAchou

IF MParam # Realizado .OR. PDes_ADI = NIL
   PDes_ADI:=AVCTOD("")
ENDIF

If ! PDespesa == CUSTO_DO_ITEM
     lAchou:=Work_2->(DBSEEK(MCod_I + If(lRegTriPO,Work_1->WKGRUPORT,"") + PDespesa + DTOS(PDes_ADI)))
Else
     lAchou:=Work_2->(DBSEEK(MCod_I + If(lRegTriPO,Work_1->WKGRUPORT,"") + PDespesa + DTOS(PDes_ADI) + Work_1->WKCONTROLE ))
Endif

IF  ! lAchou
      Work_2->(DBAPPEND())
      Work_2->WKCHAVE   := MCod_I + If(lRegTriPO,Work_1->WKGRUPORT,"") + PDespesa + DTOS(PDes_ADI) + Work_1->WKCONTROLE
      Work_2->WKCOD_I   := MCod_I
      Work_2->WKDESPESA := PDespesa
      Work_2->WKDES_ADI := PDes_ADI
      If PDespesa == CUSTO_DO_ITEM
         Work_2->WKCONTROLE:= Work_1->WKCONTROLE
      Endif

      IF !(PDescImp == NIL) .AND. !(cPaisLoc=="BRA")
         Work_2->WKDESC := PDescImp
	  ENDIF

      
ENDIF

Work_2->WKCUS_T_P := Work_2->WKCUS_T_P + PCus_T_P

IF(PCus_T_R # NIL,Work_2->WKCUS_T_R := Work_2->WKCUS_T_R + PCus_T_R,)
IF(MParam == Pre_Calculo,Work_2->WKPER_DES := SWH->WH_PER_DES,)

IF PDespesa == CUSTO_DO_ITEM .AND. PAcumImp # NIL 
   Work_2->WKCUS_S_P := Work_2->WKCUS_S_P + PCus_T_P
   IF(PCus_T_R # NIL,Work_2->WKCUS_S_R := Work_2->WKCUS_S_R + PCus_T_R,)
ENDIF

// acumula custo total de cada item

IF PTipo == Por_PO .AND. RIGHT(PDespesa,2) # DESPESA_SUBTOT .AND. PDespesa # DESP_GERAL_SEM ;
   .AND. PDespesa # DESP_GERAL_IPI .AND. PDespesa # DESP_GERAL_ICMS .AND. PDespesa # "T94";
   .AND. PDespesa # "T95" .AND. PDespesa # "T93" .AND. PDespesa # DESP_GERAL_SEM_IMP
   
   IF MParam == Realizado .AND. PDespesa # DESPESA_IPI .AND. PDespesa # "203" // ACUMULA SO QUANDO DESPESA e' # IPI / ICMS
      TPC251Grv_WK2 (Por_Item,CUSTO_DO_ITEM,PCus_T_P,PCus_T_R,,"N")
   ELSE
      TPC251Grv_WK2 (Por_Item,CUSTO_DO_ITEM,PCus_T_P,PCus_T_R)
   ENDIF
ENDIF
*----------------------------------------------
FUNCTION TPC251_T_R_Cus(PTx_Usd)
*----------------------------------------------
LOCAL MVl_T_R

MVl_T_R:= SWD->WD_VALOR_R * ;
          (Work_1->WKQTD_ENTR * Work_1->WKIDPRECO / SW6->W6_FOB_TOT)

RETURN MVl_T_R / PTx_Usd
*----------------------------------------------------------------------------*
FUNCTION TPC251FOB(PTipo,b_US)
*----------------------------------------------------------------------------*
LOCAL MCus_T_P:=MCus_T_R:=0, dData, nTX_US, nTX_FOB,cCond,cDias
LOCAL nRateio:=Work_1->WKQTD_ENTR * Work_1->WKIDPRECO / if(empty(SW6->W6_FOB_TOT),1,SW6->W6_FOB_TOT)
LOCAL aOrd := SaveOrd({"SW2","SW4","SW7","SY6"})

SW7->(DBSETORDER(1))
SW4->(DBSETORDER(1))

IF EMPTY(SW6->W6_COND_PA)              

   SW7->(DBSEEK(xFilial("SW7")+SW6->W6_HAWB))
   SW4->(DBSEEK(xFilial("SW4")+SW7->W7_PGI_NUM))

   IF !EMPTY(SW4->W4_COND_PA)
      cCond:=SW4->W4_COND_PA
      cDias:=STR(SW4->W4_DIAS_PA,3,0)
     ELSE
      SW2->(DBSEEK(xFilial("SW2")+SW7->W7_PO_NUM))
      cCond:=SW2->W2_COND_PA
      cDias:=STR(SW2->W2_DIAS_PA,3,0)
     ENDIF

ELSE

   cCond:=SW6->W6_COND_PA
   cDias:=STR(SW6->W6_DIAS_PA,3,0)
   
ENDIF            

SY6->(DBSEEK(xFilial("SY6")+cCond+cDias))

IF SY6->Y6_TIPOCOB == "4"  // sem cobertura cambial 
   SWD->(DBSEEK(xFilial("SWD")+Work_1->WKHAWB)) // NAO IMPRIMIA OUTROS REGISTROS DO DDI000
   RETURN NIL
ENDIF

RestOrd(aOrd,.T.)

dData:=IF(EMPTY(SW6->W6_DT),SW2->W2_PO_DT,SW6->W6_DT)

nTX_FOB:=IF(SW6->W6_TX_FOB=0,BuscaTaxa(SW2->W2_MOEDA, dDataBase,.T.,.F.,.T.),SW6->W6_TX_FOB)

aValor := ConvDespFobMoeda(SW6->W6_HAWB,{"R$ ",cMOEDAEST},SW6->W6_DT,"FOB_TUDO") 
MCus_T_P+=aValor[1,2]//M_Fob*nTX_FOB

IF SW2->W2_MOEDA = cMOEDAEST 
   MCus_T_R+=aValor[2,2]//M_Fob
ELSE
   nTX_US :=IF(SW6->W6_TX_US_D=0,EVAL(b_US,SW2->W2_PO_DT),;
               SW6->W6_TX_US_D)
   MCus_T_R+= aValor[2,2]// M_Fob * nTX_FOB / nTX_US
ENDIF


MCus_T_P*=IF(MParam = Realizado,nRateio,0)
MCus_T_R*=nRateio

IF dData < AVCTOD("01/07/94")  // Em Reais
   MCus_T_P /= 2750
ENDIF

TPC251Grv_WK2 (PTipo,DESPESA_FOB,MCus_T_P,MCus_T_R,dData)
TPC251Grv_WK2 (PTipo,LEFT(DESPESA_FOB,1)+DESPESA_SUBTOT,MCus_T_P,MCus_T_R)

IF (PTipo == Por_PO .AND. MParam== Realizado) .OR. MParam == Pre_Calculo
   TPC251Grv_WK2 (PTipo,DESP_GERAL_SEM,MCus_T_P,MCus_T_R)
   TPC251Grv_WK2 (PTipo,DESP_GERAL_IPI,MCus_T_P,MCus_T_R)
   TPC251Grv_WK2 (PTipo,DESP_GERAL_ICMS,MCus_T_P,MCus_T_R)

   TPC251Grv_WK2 (PTipo,"T93",MCus_T_P,MCus_T_R)
   TPC251Grv_WK2 (PTipo,"T94",MCus_T_P,MCus_T_R)
   TPC251Grv_WK2 (PTipo,"T95",MCus_T_P,MCus_T_R)

ENDIF

TPC251Grv_WK2 (PTipo,DESPESA_GERAL,MCus_T_P,MCus_T_R)
SWD->(DBSEEK(xFilial("SWD")+Work_1->WKHAWB))
RETURN NIL


*----------------------------------------------------------------------------
FUNCTION TPCBase251(PDespBase, aTPC, nIndAtu)
*----------------------------------------------------------------------------
LOCAL Ind1:=ASCAN(aTPC,{|desp| desp[3] = LEFT(PDespBase,3) })
LOCAL Ind2:=ASCAN(aTPC,{|desp| desp[3] = SUBSTR(PDespBase,4,3) })
LOCAL Ind3:=ASCAN(aTPC,{|desp| desp[3] = RIGHT(PDespBase,3) })
LOCAL IndFob:=ASCAN(aTPC,{|x| x[3] == DESPESA_FOB })
LOCAL MValor:=0,cAux:=(DESPESA_FOB + DESPESA_II +  DESPESA_IPI + VALOR_CIF + DESPESA_FRETE)
Private dDataConTx    := If( Type("dDataContx")=="D"    , dDataContx    , dDataBase )
Private nTMExtDConTx  := If(Type("nTMExtDConTx")=="N", nTMExtDConTx, BuscaTaxa(cMOEDAEST,dt,.T.,.F.,.T.)) //RMD - 21/03/2019 - Representa a taxa da moeda (cMoedaEst) na data dDataConTx. Deve ser atualizada sempre que mudar a variável dDataConTx.


Private nFobAcumulado := If( Type("nFobAcumulado")=="N" , nFobAcumulado , 0 )                
Private MFobDesp      := If( Type("MFobDesp")=="N"      , MFobDesp      , 0 )                //NCF - 04/01/2017 - não existe na chamada de rotina de prev. desembolso

IF AT(DESPESA_FOB,PDespBase) # 0
   MValor += nFobAcumulado + MFobDesp
   MValor := IF( aTPC[IndFob][4]==aTPC[nIndAtu][4] , MValor , ( MValor * BuscaTaxa(aTPC[IndFob][4],dDataConTx,.T.,.F.,.T.)) / (BuscaTaxa(aTPC[nIndAtu][4],dDataConTx,.T.,.F.,.T.)) )
ENDIF

IF AT(DESPESA_II,PDespBase) # 0
   MValor += nII_Acumulado
ENDIF

IF AT(DESPESA_IPI,PDespBase) # 0
   MValor += ( nIPIAcumulado )
ENDIF

IF AT(VALOR_CIF,PDespBase) # 0
   MValor += TPCBase251(DESPESA_FOB+DESPESA_FRETE+DESPESA_SEGURO,aTPC,nIndAtu)
   If EasyGParam("MV_EIC0068",,0) > 0 //NCF - 28/12/2017 - Desp.Base.Imp. compõe o valor CIF
      MValor += GetEDspBas(aTPC,"II",nIndAtu) 
   EndIf
ENDIF
    
IF Ind1 # 0 .AND. !aTPC[Ind1,3] $ cAux .AND. aTPC[Ind1,5] = 0 .AND. aTPC[Ind1,6] # 0
   MValor += TPCBase251(aTPC[Ind1,7],aTPC,Ind1) * aTPC[Ind1,6] / 100
ENDIF
   
IF Ind2 # 0 .AND. !aTPC[Ind2,3] $ cAux .AND. aTPC[Ind2,5] = 0 .AND. aTPC[Ind2,6] # 0
   MValor += TPCBase251(aTPC[Ind2,7],aTPC,Ind2) * aTPC[Ind2,6] / 100
ENDIF

IF Ind3 # 0 .AND. !aTPC[Ind3,3] $ cAux .AND. aTPC[Ind3,5] = 0 .AND. aTPC[Ind3,6] # 0
   MValor += TPCBase251(aTPC[Ind3,7],aTPC,Ind3) * aTPC[Ind3,6] / 100
ENDIF

//NCF - 29/09/2011 - Modificado o retorno do valor para efetuar conversão de moeda quando a moeda da despesa calculada
//                   for diferente da moeda da despesa base.    
                                      //Verifica Moeda da Desp e D.Base  Valor na Moeda  Valor Convertido da Desp. Base para moeda da Desp. Calc
MValor += IF(Ind1 # 0,/*aTPC[Ind1,5]*/ IF(aTPC[Ind1][4]==aTPC[nIndAtu][4] , aTPC[Ind1,5] , (aTPC[Ind1][5] * BuscaTaxa(aTPC[Ind1][4],dDataConTx,.T.,.F.,.T.)) / (BuscaTaxa(aTPC[nIndAtu][4],dDataConTx,.T.,.F.,.T.)) ),0)//THTS - 22/06/2017
MValor += IF(Ind2 # 0,/*aTPC[Ind2,5]*/ IF(aTPC[Ind2][4]==aTPC[nIndAtu][4] , aTPC[Ind2,5] , (aTPC[Ind2][5] * BuscaTaxa(aTPC[Ind2][4],dDataConTx,.T.,.F.,.T.)) / (BuscaTaxa(aTPC[nIndAtu][4],dDataConTx,.T.,.F.,.T.)) ),0)//THTS - 22/06/2017
MValor += IF(Ind3 # 0,/*aTPC[Ind3,5]*/ IF(aTPC[Ind3][4]==aTPC[nIndAtu][4] , aTPC[Ind3,5] , (aTPC[Ind3][5] * BuscaTaxa(aTPC[Ind3][4],dDataConTx,.T.,.F.,.T.)) / (BuscaTaxa(aTPC[nIndAtu][4],dDataConTx,.T.,.F.,.T.)) ),0)//THTS - 22/06/2017

RETURN MValor

*---------------------------------*
Static Function QC210xCol( pnColuna )
*---------------------------------*
Return ( pnColuna * 16 )

*-----------------------------------------*
FUNCTION TPCTotMidia(PDesp,aDespBase,PSALDO_Q)
*-----------------------------------------*
LOCAL Ind1:= ASCAN(aDespBase,{|desp| desp [1] = DESPESA_FRETE })
LOCAL Ind2:= ASCAN(aDespBase,{|desp| desp [1] = DESPESA_SEGURO})
LOCAL Ind3:= ASCAN(aDespBase,{|desp| desp [1] = DESPESA_II})
LOCAL MVal_IMP := 0
LOCAL nBaseMidia := 0

nBaseMidiA := PSALDO_Q * SB1->B1_QTMIDIA * SW2->W2_VLMIDIA

MVal_IMp:=IF(Ind1 # 0,aDespBase[Ind1,2] ,0)  +;
         IF(Ind2 # 0,aDespBase[Ind2,2] ,0) +;
         IF(PDesp == DESPESA_IPI .AND. Ind3 # 0,aDespBase[Ind3,2],0)+;
         nBaseMidia
RETURN MVal_imp

// Funcao Criada em 06/04/2001 por S.A.M. com o propósito de buscar o saldo
// do P.O. se for embarcado ou possuir LI. apenas quando for integrado com o
// Financeiro SIGA.
*----------------------------------------------------------------*
FUNCTION TPC251SALDOPC(cPo)
*----------------------------------------------------------------*
PRIVATE nQTDE,nSld_Gi:= 0,nQtd_Gi:= 0,TPO_NUM
   
IF cAVFase$'PODI' .AND. (GetNewPar("MV_EASYFIN","N")='S' .Or. lAvIntDesp) //wfs 03/07/2014 - atualização dos valores para integração via EAI
   nSld_Gi:= 0
   nQtd_Gi:= 0
   TPO_NUM:=cPo
   Po420_IgPos("3")
   IF SW3->W3_FLUXO == "7"
      nQtde := nSld_Gi
   ELSE
      nQtde := SW3->W3_SALDO_Q + nSld_Gi 
   ENDIF
Else
   nQtde := SW3->W3_QTDE
ENDIF
                           
RETURN nQtde
*----------------------------------------------------------------------------*
Function TP251CriaWork()//Funcao chamada do EICDI500.PRW e no EICNA400.PRW
*----------------------------------------------------------------------------*
LOCAL Estrutura ,Est_Work_2

If Type("nCasasDec") <> "N"
   nCasasDec := EasyGParam("MV_EIC0065",,2)
EndIf

IF SELECT("WORK_1") # 0 .AND. SELECT("WORK_2") # 0
   IF TYPE("axFlDelWork") = "A" .AND. LEN(axFlDelWork) > 2
      FileWork  :=axFlDelWork[1]
      FileWork1 :=axFlDelWork[2]
      FileWork_2:=axFlDelWork[3]
   ENDIF   
   RETURN .T.
ENDIF
//NCF - 30/01/2013 - Reg. Trib. PO (Para quando gravada só a capa do embarque)
If Type("lRegTriPO") == "U" 
   PRIVATE lRegTriPO := SW3->(FieldPos("W3_GRUPORT")) # 0 .AND. SIX->(dbSeek("EIJ2"))
EndIf
Estrutura := { ;
{ "WKFLAGWIN",  "C", 02,0 } ,;
{ "WKFLAG"   ,  "C", 01,0 } ,;
{ "WKCOD_I"  ,  "C", AVSX3("W3_COD_I",3),0 } ,;
{ "WKTELA"   ,  "C", 01,0 } ,;
{ "WKDESCR"  ,  "C", 20,0 } ,;
{ "WKPO_NUM"  , "C", AVSX3("W7_PO_NUM",AV_TAMANHO),0 } ,;
{ "WKIDPRECO",  "N", AVSX3("W7_PRECO",3),AVSX3("W7_PRECO",4) } ,;
{ "WKHAWB"   ,  "C", AVSX3("W7_HAWB",AV_TAMANHO),0 } ,;
{ "WKQTD_INI",  "N", AVSX3("W3_QTDE",3),AVSX3("W3_QTDE",4) } ,;
{ "WKUNID"   ,  "C", 03,0 } ,;
{ "WKQTD_ENTR", "N", AVSX3("W7_QTDE",3),AVSX3("W7_QTDE",4) } ,;
{ "WKQTD_ACU" , "N", AVSX3("W7_QTDE",3),AVSX3("W7_QTDE",4)  } ,;
{ "WKQTD_SALD", "N", AVSX3("W3_QTDE",3),AVSX3("W3_QTDE",4)  } ,;
{ "WKPESO_L"  , "N", AVSX3("W3_PESOL",3),AVSX3("W3_PESOL",4) } ,;
{ "WKCONTROLE", "C", 04,0 } ,;
{ "WKCONT_IP" , "N", AVSX3("WH_NR_CONT",3),0 } ,;
{ "WKFABR"    , "C", AVSX3("W3_FABR",3),0 } ,; //DFS - 24/09/12 - Inclusão de AVSX3 para pegar o tamanho do campo e não chumbado como antes.
{ "WKFOB_UNT" , "N", AVSX3("W3_PRECO",3),AVSX3("W3_PRECO",4)  } ,;
{ "WKFOB_TOT" , "N", AVSX3("W2_FOB_TOT",3),AVSX3("W2_FOB_TOT",4)  } ,;
{ "WKPOSICAO" , "C", AVSX3("W3_POSICAO",3),AVSX3("W3_POSICAO",4) } ,;
{ "WKNBM"    ,  "C", 16,0 } }

If lRegTriPO
   aAdd(Estrutura,{"WKGRUPORT","C",AVSX3("W3_GRUPORT",3),0})
EndIf

EICAddWkLoja(Estrutura, "W3_FABLOJ", "WKFABR")
Est_Work_2 := { ;
{"WKCOD_I"   ,"C"  ,AVSX3("W3_COD_I",3),0 } ,;
{"WKCHAVE"   ,"C"  , 33,0 } ,;                                      //NCF - 08/02/2013
{"WKDESPESA" ,"C"  , 03,0 } ,;
{"WKDES_ADI" ,"D"  , 08,0 } ,;
{"WKCUS_U_P" ,"N"  , AVSX3("WH_VALOR",3)  ,nCasasDec } ,; //LGS-25/07/2016
{"WKCUS_U_R" ,"N"  , AVSX3("WH_VALOR_R",3),nCasasDec } ,; //LGS-25/07/2016
{"WKVARCUS_U","N"  , AVSX3("WH_VALOR",3)  ,nCasasDec } ,; //LGS-25/07/2016
{"WKCUS_T_P" ,"N"  , AVSX3("WH_VALOR",3)  ,nCasasDec } ,; //LGS-25/07/2016//RRV - 05/02/2013
{"WKCUS_T_R" ,"N"  , AVSX3("WH_VALOR_R",3),nCasasDec } ,; //LGS-25/07/2016//RRV - 05/02/2013
{"WKVARCUS_T","N"  , AVSX3("WH_VALOR",3)  ,nCasasDec } ,; //LGS-25/07/2016
{"WKPER_DES" ,"N"  , AVSX3("WH_VALOR",3)  ,nCasasDec } ,; //LGS-25/07/2016
{"WKPERPAR_P","N"  , AVSX3("WH_VALOR",3)  ,nCasasDec } ,; //LGS-25/07/2016
{"WKPERPAR_R","N"  , AVSX3("WH_VALOR_R",3),nCasasDec } ,; //LGS-25/07/2016
{"WKPERCIF_P","N"  , AVSX3("WH_VALOR",3)  ,nCasasDec } ,; //LGS-25/07/2016
{"WKPERCIF_R","N"  , AVSX3("WH_VALOR_R",3),nCasasDec } ,; //LGS-25/07/2016
{"WKCUS_S_P" ,"N"  , AVSX3("WH_VALOR",3)  ,nCasasDec } ,; //LGS-25/07/2016
{"WKCUS_S_R" ,"N"  , AVSX3("WH_VALOR_R",3),nCasasDec } ,; //LGS-25/07/2016
{"WKCONTROLE","C"  , 04,0 } ,;
{"WKDESC"    ,"C"  , 03,0 } }

IF EasyGParam("MV_SOFTWAR") $ cSim
   AADD(Estrutura,{"WK_QTMIDIA",AVSX3("B1_QTMIDIA",2),;
                                AVSX3("B1_QTMIDIA",3),;
                                AVSX3("B1_QTMIDIA",4)})
   AADD(Estrutura,{"WKICM_MID","N",15,4})
   AADD(Estrutura,{"WKBASEMID","N",15,4 })
ENDIF

FileWork := E_CriaTrab(,Estrutura,"Work_1") //THTS - 05/10/2017 - TE-7085 - Temporario no Banco de Dados

IF !USED()
   Help("", 1, "AVG0000573")//Nao foi possivel a abertura do Arquivo de Trabalho
   Return .F.
ENDIF

IndRegua("Work_1",FileWork+TEOrdBagExt(),"WKTELA+WKCOD_I+WKNBM"+IF(lRegTriPO,"+WKGRUPORT","")) //TDF - 26/11/12 - Acrescenta a TEC+EX-NCM+EX-NBM 

FileWork1:=E_Create(Estrutura,.F.)

IndRegua("Work_1",FileWork1+TEOrdBagExt(),"WKCOD_I+WKCONTROLE+WKFLAG")

SET INDEX TO (FileWork+TEOrdBagExt()),(FileWork1+TEOrdBagExt())

//Campo chave eh o tamanho dos campos do indice: WKCOD_I, WKDESPESA, WKDES_ADI e WKCONTROLE AWR 17/12/99
Est_Work_2[2][3] := Est_Work_2[1][3]+/*14*/18                                                            //NCF - 08/02/2013 - Reg. Trib. PO

FileWork_2 := E_CriaTrab(,Est_Work_2,"Work_2") //THTS - 05/10/2017 - TE-7085 - Temporario no Banco de Dados

IF !USED()
   Help("", 1, "AVG0000573")//Nao foi possivel a abertura do Arquivo de Trabalho
   Return .F.
ENDIF

IndRegua("Work_2",FileWork_2+TEOrdBagExt(),"WKCHAVE")

IndWork2:=E_Create(,.F.)   // GFP - 04/04/2013
IndRegua("Work_2",IndWork2+TEOrdBagExt(),"WKDESPESA")

SET INDEX TO (FileWork_2+TEOrdBagExt()),(IndWork2+TEOrdBagExt())   

IF TYPE("axFlDelWork") = "A"
   AADD(axFlDelWork,FileWork)
   AADD(axFlDelWork,FileWork1)
   AADD(axFlDelWork,FileWork_2)
ENDIF   

RETURN .T.


*----------------------------------------------------------------------------*
Function TPC251MarcAll()
*----------------------------------------------------------------------------*
LOCAL nRecno := Work_1->(recno())
    
IF Work_1->WKFLAGWIN == SPACE(2)
	cMarcNew := cMarca
	cFlag    := "A"
ELSE
	cMarcNew := SPACE(2)
	cFlag    := "N"
ENDIF
Work_1->(dbGotop())
DO WHILE !Work_1->(eof())
	Work_1->WKFLAGWIN := cMarcNew
	Work_1->WKFLAG    := cFlag
	Work_1->(dbSkip())
ENDDO
Work_1->(dbGoto(nRecno))
RETURN NIL

//** AAF 27/11/08 - Melhoria de Performance
Static Function LerItensPed(aBuffers)
Local cFilSW3 := xFilial("SW3"), nSaldo

SW3->(DbSetFilter({|| W3_SEQ == 0}, "W3_SEQ == 0")) //wfs - out/2019: ajustes de performance
Do While !EoF() .AND. W3_FILIAL+W3_PO_NUM==cFilSW3+SW2->W2_PO_NUM

   If W3_SEQ==0 .AND. (nSaldo := TPC251SALDOPC(SW2->W2_PO_NUM))>0//RMD - 08/04/19 - Guarda o saldo em uma variável para não precisar apurar novamente na função TPC251GrPreCalc
      TPC251GrPreCalc(nSaldo, aBuffers)
   
   #IFDEF TOP   
   ElseIf W3_SEQ==0
      IncProc(STR0063) //"Gravando Item: "      
   #ENDIF
   
   EndIf
   
   dbSkip()
EndDo
SW3->(DbClearFilter())
Return .T.

/*
Função     : TP251AjustVlr
Objetivo   : Ajustar arredondamentos
Retorno    : Nil
Autor      : Guilherme Fernandes Pilan
Data/Hora  : 03/04/2013 : 14:06
*/  
*------------------------*
Function TP251AjustVlr()
*------------------------*
Local nValTotRS2, nValTotRS3, nValTotUS2, nValTotUS3, i, nMaiorValRS, nMaiorValUS, nRecnoRS, nRecnoUS, nDifDecRS, nDifDecUS
Local nWKRecno := WORK_2->(Recno())
Local aOrd := SaveOrd("WORK_2")

WORK_2->(DbSetOrder(2))  //WKDESPESA

For i := 1 To Len(aDespesas)
   nValTotRS2 := nValTotRS3 := nValTotUS2 := nValTotUS3 := nDifDecRS := nDifDecUS := 0
   nMaiorValRS := nMaiorValUS := nRecnoRS := nRecnoUS := 0
   
   If WORK_2->(DbSeek(aDespesas[i]))
      Do While WORK_2->(!Eof()) .AND. WORK_2->WKDESPESA == aDespesas[i]
         nValTotRS3  += WORK_2->WKCUS_T_P
         nValTotUS3 += WORK_2->WKCUS_T_R
         
         nDifDecRS := nValTotRS3 - NoRound(nValTotRS3,2)
         nDifDecUS := nValTotUS3 - NoRound(nValTotUS3,2)
      
         nValTotRS2  += If(nDifDecRS <= 0.005, NoRound(WORK_2->WKCUS_T_P, 2), Round(WORK_2->WKCUS_T_P, 2))
         nValTotUS2  += If(nDifDecUS <= 0.005, NoRound(WORK_2->WKCUS_T_R, 2), Round(WORK_2->WKCUS_T_R, 2))
         
         If nMaiorValRS < WORK_2->WKCUS_T_P
            nMaiorValRS := WORK_2->WKCUS_T_P
            nRecnoRS := WORK_2->(Recno())
         EndIf
         If nMaiorValUS < WORK_2->WKCUS_T_R
            nMaiorValUS := WORK_2->WKCUS_T_R
            nRecnoUS := WORK_2->(Recno())
         EndIf               
         WORK_2->(DbSkip())
      EndDo 
      
      If nValTotRS2 <> nValTotRS3
         WORK_2->(DbGoTo(nRecnoRS))
         WORK_2->WKCUS_T_P += (nValTotRS2 - nValTotRS3)
      EndIf
      If nValTotUS2 <> nValTotUS3
         WORK_2->(DbGoTo(nRecnoUS))
         WORK_2->WKCUS_T_R += (nValTotUS2 - nValTotUS3)
      EndIf
      
      If WORK_2->(DbSeek(LEFT(WORK_2->WKDESPESA,1)+"R9"))  // Atualiza totalizadores
         WORK_2->WKCUS_T_P += (nValTotRS2 - nValTotRS3)
         WORK_2->WKCUS_T_R += (nValTotUS2 - nValTotUS3)
      EndIf     
   EndIf                                                               
Next i

RestOrd(aOrd,.T.)
WORK_2->(DbGoTo(nWKRecno)) 
Return Nil

/*
Função     : GetEDspBas
Objetivo   : retornar o valor de uma despesa base ou a soma dos valores de despesas base (II/ICMS)
Parametros : aTPC -> Array com os dados de todas despesas da tabela de pré-cálculo
             cDesp -> O Código da despesa a verificar
             nIndAtu -> posição da despesa verificada no array aTPC
             nIndex -> posição da despesa base da despesa atual no array aTPC
             cOrig -> Indica a função recursiva a ser invocada para calcular os valores das despesas no array aTPC
             cCodImport -> Indica o cód. do importador para validação da UF no caso de desp. base ICMS
Retorno    : nValDesp -> valor somado das despesa base de imposto/icms que permitem o cálculo.
Autor      : Nilson César
Data/Hora  : 28/12/2017
*/  
*--------------------------------------------------------------*
Function GetEDspBas(aTPC,cDesp,nIndAtu,nIndex,cOrig,cCodImport,nPRateio,bTPCPag)
*--------------------------------------------------------------*
Local nValDesp := 0, nVlDspAcum := 0
Local x
Local bWhile
Local nBaseCalc
LOCAL Ind1:=ASCAN(aTPC,{|desp| desp[3] = LEFT(  aTPC[nIndAtu][7],3)   })
LOCAL Ind2:=ASCAN(aTPC,{|desp| desp[3] = SUBSTR(aTPC[nIndAtu][7],4,3) })
LOCAL Ind3:=ASCAN(aTPC,{|desp| desp[3] = RIGHT( aTPC[nIndAtu][7],3)   })
LOCAL aValImp
Default nIndex := 0, cOrig := "TPCBase251", cCodImport := ""
bWhile := If( nIndex == 0 , {|| x <= Len(aTPC) } , {|| x == nIndex } )
x      := If( nIndex == 0 , 1 , nIndex )
cOrig := "TPCBase"
Do While Eval(bWhile)   
   If AT(LEFT(aTPC[x][3],1),'129T') == 0 //Despesa liberada para uso
      If IsDspBasIm(cDesp,aTPC[x][3],"PROC",cCodImport)    //Despesa base de Imposto/base ICMS
         If aTPC[x][11] == "2"           //Despesa calculada por percentual
            //If If(cDesp == "II", !(VALOR_CIF $ aTPC[x][7]) .And. !(DESPESA_II $ aTPC[x][7]) ,  If(cDesp == "ICMS", !(DESPESA_ICMS $ aTPC[x][7]) , .T.)  ) //Quando for II, verificar se não tem a despesa CIF/Vlr.II como base de calculo (ref. circular)
            aValImp := EA110RefCirc(cDesp,aTPC[x][3],aTPC[x][3],aTPC[x][7],"SWI",SWI->WI_VIA,SWI->WI_TAB,.T.,.F.,"PROC",cCodImport)                         //Quando for ICMS, verificar se não tem a despesa ICMS como base de calculo (ref. circular)
            If !aValImp[1]
                                                       //EICTP252A                           //DI500Manut/EICTP252                                        
               nBaseCalc := If( cOrig == "TPCBase251", TPCBase251(aTPC[x][7],aTPC,nIndAtu) , TPCBase(aTPC[x][7],aDespBase,0,bTPCPag) )                            
               nValDesp  := nBaseCalc * (aTPC[x][6]/100)
            Else 
               nValDEsp := 0
            EndIf
         Else
            nValDesp := aTPC[x][5] * nPRateio
         EndIf

        If nValDesp <> 0 .And. aTPC[x][4] <> aTPC[nIndAtu][4] //Moedas diferentes entre Base calculada e despesa base
           If Alltrim(aTPC[x][4]) $ "R$/BRL"
              nValDesp := nValDesp / (BuscaTaxa(aTPC[x][4],dDataBase,.T.,.F.,.T.) )                                                           //Converte para Vlr.Moeda com a taxa da moeda o vlr.Reais   
           ElseIf Alltrim(aTPC[x][4]) <> "US$" 
              nValDesp := nValDesp * ( (BuscaTaxa(aTPC[nIndAtu][4],dDataBase,.T.,.F.,.T.)) / (BuscaTaxa(aTPC[x][4],dDataBase,.T.,.F.,.T.))  ) //Converte para Vlr.Moeda com paridade entre moedas Ext.1 e Ext.2 
           EndIf                                                                                                                              //Moeda Ext.1 sempre = US$ pois o CIF só é expresso em R$ ou US$
        EndIf

      EndIf
   EndIf
   nVlDspAcum += nValDesp
   nBaseCalc := 0
   x++
EndDo 

return nVlDspAcum 

/*
Função     : IsDspBasIm
Objetivo   : verificar se uma despesa é base de II ou ICMS
Parametros : cImp -> Tipo de despesa base a verificar
             cDesp -> O Código da despesa a verificar
             cTipoProc -> Tipo do Processamento("PROC"=Processameto e "CAD"=Cadastro)
                          para definir se valida a UF do importador
             cCodImp -> Código do importador (quando cImp = ICMS)
Retorno    : lRet (T= se for base da despesa e F caso contrário)
Autor      : Nilson César
Data/Hora  : 28/12/2017
*/ 
*------------------------------------------------* 
Function IsDspBasIm(cImp,cDesp,cTipoProc,cCodImp)
*------------------------------------------------* 
Local lRet := .F.
Local nOrder := SYB->(IndexOrd())
Local nRecno := SYB->(Recno())
Local lBaseICM := .F.
Local cCpoBasICMS

SYB->(DbSetORder(1))
If SYB->(DBseek(xFilial("SYB") + cDesp))
   If cImp == "II"
      lRet := SYB->YB_BASEIMP == "1"
   ElseIf cImp == "ICMS"
      lBaseICM:=SYB->YB_BASEICM $ cSim
      If cTipoProc == "PROC"
         IF cCodImp # NIL
            SYT->(DBSETORDER(1))
            SYT->(dBSeek(xFilial("SYT")+cCodImp))
            cCpoBasICMS:="YB_ICMS_"+Alltrim(SYT->YT_ESTADO)
            IF SYB->(FIELDPOS(cCpoBasICMS)) # 0
               lBaseICM:=lBaseICM .AND. SYB->(FIELDGET(FIELDPOS(cCpoBasICMS))) $ cSim
            ENDIF
         Else
            lBaseICM := .F.
         EndIf
      ENDIF
      lRet := lBaseICM
   EndIf
EndIf

SYB->(DbSetORder(nOrder))
SYB->(DbGoTo(nRecno))

Return lRet

*------------------------------------------------* 
Static Function EDspBsImp(pTipo,cPoNum,nIndItem)
*------------------------------------------------* 
Local nOldArea := Select()
Local aValores := {0,0}
Local cQry, cQuery, i
Local aDespBases := {}, aValidDBII
Local aOrdTab := SaveOrd({"SW2","SWI","SWH"})
Local cViaTPC := AvKey( Posicione("SW2", 1, xFilial("SW2")+cPoNum, "W2_TIPO_EM") , "WI_VIA" )
Local cTabTPC := AvKey( Posicione("SW2", 1, xFilial("SW2")+cPoNum, "W2_TAB_PC" ) , "WI_TAB" )

cqry := "SELECT WI_DESP"
cqry += " FROM "+RetSQLName("SWI")
cqry += " WHERE WI_TAB = '"+cTabTPC+"'"
cqry += " AND WI_VIA = '"+cViaTPC+"'"
cqry += " AND WI_DESP NOT LIKE '1%'"  
cqry += " AND WI_DESP NOT LIKE '2%'" 
cqry += " AND WI_DESP NOT LIKE '9%'" 
cqry += " AND D_E_L_E_T_ = ' '"

//Obtém as despesas da tabela que não possuem referencia circular
TcQuery ChangeQuery(cQry) ALIAS "LISTDESP" NEW
Do While LISTDESP->(!Eof())
   If IsDspBasIm("II",Alltrim(LISTDESP->WI_DESP),"CAD") 
      aValidDBII := EA110RefCirc( "II" , Alltrim(LISTDESP->WI_DESP) , Alltrim(LISTDESP->WI_DESP) , "" ,"SWI",cViaTPC,cTabTPC,.T.,.F.,,)
      If !aValidDBII[1]
         aAdd(aDespBases,LISTDESP->WI_DESP)   
      EndIf
   EndIf
    LISTDESP->(DbSkip())    
EndDo
LISTDESP->( dbCloseArea() )

If Len(aDespBases) <> 0 
  //Obtém a soma das despesas base de imposto calculadas
  cQuery := "SELECT SUM(WH_VALOR) TOT_DSP_USD, SUM(WH_VALOR_R) TOT_DSP_RS"
  cquery += " FROM "+RetSQLName("SWH")
  cquery += " WHERE WH_FILIAL = '"+xFilial("SWH")+"'"
  cquery += " AND WH_PO_NUM = '"+cPoNum+"'"
  If pTipo == "1"
     cquery += " AND WH_NR_CONT = "+Alltrim(STR(nIndItem,Avsx3("WH_NR_CONT",3),0))
  EndIf
  cquery += " AND WH_DESPESA IN ("
  for i := 1 To Len(aDespBases)
        cquery += "'"+aDespBases[i]+"',"
        if i == Len(aDespBases)
           cQuery := Left(cQuery,Len(cQuery)-1)
        EndIf
   Next i
   cquery += ")"
     
  cquery +=  " AND D_E_L_E_T_ = ' '"

  TcQuery ChangeQuery(cQuery) ALIAS "EDSPBASEIMP" NEW
  If EDSPBASEIMP->(!Eof()) .And. EDSPBASEIMP->(!Bof())
     aValores := { EDSPBASEIMP->TOT_DSP_USD, EDSPBASEIMP->TOT_DSP_RS }
  EndIf
  EDSPBASEIMP->( dbCloseArea() )
EndIf
RestOrd(aOrdTab,.T.)

DbSelectArea(nOldArea)

REturn aValores

/* 
Funcao     : geraFob() 
Parametros : nIndFrete, indica se a tabela de pré-calula existe a despesa frete
             nIndSeguro, indica se a tabela de pré-calula existe a despesa seguro
Retorno    : valor fob
Objetivos  : Retornar o valor 
Autor      : Maurício Frison
Data/Hora  : 21/08/19 17:39:12 
*/ 
Function geraFob( nInd_Frete, nInd_Seguro)
   Local fob

   fob := SW2->W2_INLAND + SW2->W2_PACKING - IF(AvRetInco(SW2->W2_INCOTER,"CONTEM_FRETE") .and. SW2->W2_FREINC $ cSim .and. nInd_Frete != 0  ,SW2->W2_FRETEIN,0) - IF(AvRetInco(SW2->W2_INCOTER,"CONTEM_SEGURO") .And. SW2->W2_SEGINC $ cSim .and. nInd_Seguro != 0, SW2->W2_SEGURIN, 0) - SW2->W2_DESCONT + SW2->W2_OUT_DES
   
   if AvRetInco(SW2->W2_INCOTER,"CONTEM_FRETE") .and. nInd_Frete == 0 .and. SW2->W2_FREINC $ cNao
      fob += SW2->W2_FRETEIN
   EndIf
   
   if AvRetInco(SW2->W2_INCOTER,"CONTEM_SEGURO") .and. nInd_Seguro == 0 .and. SW2->W2_SEGINC $ cNao
      fob += SW2->W2_SEGURIN
   EndIf

Return fob 
*----------------------------------------------------------------------------*
*                         FINAL DO PROGRAMA EICTP251.PRW                     *
*----------------------------------------------------------------------------*


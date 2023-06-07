#Include 'PROTHEUS.CH'
#Include 'RWMAKE.CH'
#Include 'topconn.ch'
#Include 'tbiconn.ch'
//#include "FiveWin.ch"
#include "Average.ch"
#INCLUDE "AvPrint.ch"
#INCLUDE "EicFi400.ch"  
//Funcao    : AVFLUXO()
//Autor     : SIDNEY MONTEIRO
//Data      : 21 Nov 2000
//Descricao : Ponto de entrada Antes e Depois das gravacoes do PO e da DI
//Cliente   : "Los Hermanos"

#DEFINE DESP_FRETE   '102'
#DEFINE DESP_SEGURO  '103'
#DEFINE ENTER CHR(13)+CHR(10) 
 /*/{Protheus.doc} SZHJOB
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
User Function SZHJOB(aFilial)
Local lJob := .F.
PRIVATE cEmpProc	:= '01'
PRIVATE cFilProc	:= ''


If Select("SX2") == 0
    cFilProc	:= aFilial[2]
	//Preparando o ambiente
	RPCSetType(3)
	CONOUT('DAXJOBB8 - Empresa ' + cEmpProc + '/ Filial '+ cFilProc)
    lJob := .T.
	RPCSetEnv(cEmpProc, cFilProc, "", "", "")
EndIf

If lJob .Or. MsgYesNo('Deseja atualizar a tabela de despesas?', "Atualiza SZH")

    CONOUT('SZHJOB - Inicio da execução' )
    U_UpdCalc()
    UpdZH()
    CONOUT('SZHJOB - Fim da execução' )
    If !lJob
        MsgInfo('SZHJOB - Fim da execução' ,"Fim")
    EndIf
EndIf

Return 


Static Function UpdZH()
Local cQuery := ''
Local lReclock := .T.

cQuery := "SELECT SWH.* , ZH_PO_NUM FROM " + RetSqlName("SWH") + " SWH "
cQuery += " LEFT JOIN " + RetSqlName("SZH") + " SZH ON ZH_PO_NUM = WH_PO_NUM AND ZH_NR_CONT = WH_NR_CONT AND ZH_DESPESA = WH_DESPESA "
cQuery += "  WHERE "
cQuery += "  SWH.WH_DTAPUR = (SELECT MAX(WH_DTAPUR) FROM SWH010 SWHB WHERE SWHB.WH_PO_NUM = SWH.WH_PO_NUM)"
cQuery += " GROUP BY SWH.WH_FILIAL, SWH.WH_PO_NUM, SWH.WH_NR_CONT, SWH.WH_DESPESA , SWH.WH_MOEDA , SWH.WH_PER_DES , SWH.WH_VALOR , SWH.WH_DESC , SWH.WH_VALOR_R , SWH.WH_DTAPUR ,SWH.D_E_L_E_T_ , SWH.R_E_C_N_O_ ,SWH.R_E_C_D_E_L_ ,ZH_PO_NUM"   

If Select('TMPSZH') > 0
    ('TMPSZH')->(DbCloseArea())
EndIf

TCQUERY cQuery New Alias "TMPSZH"

Dbselectarea("TMPSZH")
dbGoTop()
SZH->(DbSetOrder(1))
While TMPSZH->(!EOF())
    If SZH->(DbSeek(TMPSZH->WH_FILIAL + PADR(TMPSZH->WH_PO_NUM,TAMSX3('ZH_PO_NUM')[1]) + PADR(STR(TMPSZH->WH_NR_CONT,4,0),TAMSX3('ZH_NR_CONT')[1])  + PADR(TMPSZH->WH_DESPESA,TAMSX3('ZH_DESPESA')[1])  ))
        lReclock := .F.
    Else
        lReclock := .T.
    EndIf
    RecLock('SZH',lReclock)
    SZH->ZH_FILIAL := TMPSZH->WH_FILIAL
    SZH->ZH_PO_NUM := TMPSZH->WH_PO_NUM
    SZH->ZH_NR_CONT := TMPSZH->WH_NR_CONT
    SZH->ZH_DESPESA := TMPSZH->WH_DESPESA
    SZH->ZH_MOEDA   := TMPSZH->WH_MOEDA
    SZH->ZH_PER_DES := TMPSZH->WH_PER_DES
    SZH->ZH_VALOR   := TMPSZH->WH_VALOR
    SZH->ZH_DESC    := TMPSZH->WH_DESC
    SZH->ZH_VALOR_R := TMPSZH->WH_VALOR_R
    SZH->ZH_DTAPUR  := STOD(TMPSZH->WH_DTAPUR)
    MsUnlock()

    TMPSZH->(DbSkip())
EndDo

Return




User Function AjuZH()
Local cQuery := ''
Local lReclock := .T.

cQuery := "select ZH_PO_NUM , ZH_FILIAL , W2_FILIAL ,  SZH.R_E_C_N_O_ AS REC  FROM " + RetSqlName("SZH") + " SZH "
cQuery += " INNER JOIN " + RetSqlName("SW2") + " SW2 ON W2_PO_NUM = ZH_PO_NUM  AND ZH_FILIAL <> W2_FILIAL "
cQuery += "  WHERE "
cQuery += "  SZH.D_E_L_E_T_ = ' ' AND SW2.D_E_L_E_T_ = ' '"

If Select('TMPSZH') > 0
    ('TMPSZH')->(DbCloseArea())
EndIf

TCQUERY cQuery New Alias "TMPSZH"

Dbselectarea("TMPSZH")
dbGoTop()
While TMPSZH->(!EOF())

    SZH->(DbGoTo(TMPSZH->REC))
    RecLock('SZH',.F.)
    SZH->ZH_FILIAL := TMPSZH->W2_FILIAL
    MsUnlock()

    TMPSZH->(DbSkip())
EndDo

Return



User Function UpdCalc()
Local cQuery := ''
Local lReclock := .T.

cQuery := "select SW2.R_E_C_N_O_ AS REC  FROM " + RetSqlName("SW2") + " SW2 "
cQuery += "  WHERE "
cQuery += "  SW2.D_E_L_E_T_ = ' ' AND SW2.W2_STAT_PC = ' ' "

If Select('TMPSW2') > 0
    ('TMPSW2')->(DbCloseArea())
EndIf

TCQUERY cQuery New Alias "TMPSW2"

Dbselectarea("TMPSW2")
dbGoTop()
While TMPSW2->(!EOF())

    SW2->(DbGoTo(TMPSW2->REC))
    
    U_DxPreCal(SW2->W2_FILIAL , SW2->W2_PO_NUM)

    TMPSW2->(DbSkip())
EndDo

Return




 /*/{Protheus.doc} DxPreCal()
    chama o EICTP251 no job
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
User Function DxPreCal(cFilPo , cCodPO)
LOCAL aDespesas:={},nAlias:=SELECT(), aDtEntr := {}   // GFP - 26/03/2013
LOCAL nInd := SW2->(INDEXORD()),    nOrdSW3:=(SW3->(INDEXORD())), nOrdSWI:=(SWI->(INDEXORD())),;
      nOrdSY5:= SY5->(INDEXORD()),  nOrdSB1:= SB1->(INDEXORD()),;
      nOrdSWD:= SWD->(INDEXORD()),  nOrdSYW:=SYW->(INDEXORD()) ,  nOrdSY4:=SY4->(INDEXORD())      
LOCAL cFornecMV:=PADR(EasyGParam("MV_FORDESP"),LEN(SA2->A2_COD))
LOCAL cLojaFMV :=PADR(EasyGParam("MV_LOJDESP"),LEN(SA2->A2_LOJA))
LOCAL cMoeda1:=EasyGParam("MV_SIMB1")
LOCAL cMoeda2:=EasyGParam("MV_SIMB2")
LOCAL cFornFret:= "", cLojaFret:= "", nDesp
Local cMsgAgente:= ""
Local cMsgDespach:= "" 
Local cMsgValid:= ""
Local lIntEAI:= AvFlags("EIC_EAI")
Local lEventFin:= .T.
Local lMoedaWF := If( (EasyGParam("MV_EASYFPO",,"N") == "S" .Or. EasyGParam("MV_EASYFDI",,"N") == "S") .And. SWF->(FieldPos("WF_IDMOEDA")) > 0 ,.T.,.F.)//LGS-28/07/2016
Local loIntPr:= .F.
Local cFilSWI := XFILIAL("SWI")//RMD - 21/03/19 - Para evitar chamada em loop
Local cFilSWH := XFILIAL("SWH")//RMD - 21/03/19 - Para evitar chamada em loop
Local cFilSW3 := XFILIAL("SW3")//RMD - 21/03/19 - Para evitar chamada em loop
//RMD - 21/03/19 - Buffer para os dados do SW3, Despesas e SW5
Local oBufferSW3 := tHashMap():New(), nBufRecSW3
Local oBufferDesp := tHashMap():New(), aBufDesp
Local oVlrGI := tHashMap():New(), aBufVlrGI

PRIVATE nSld_Gi:= 0,nQtd_Gi:= 0,TPO_NUM:= cCodPO,lSair:=.F.
//TRP - 09/03/2010 - Variável utilizada em rdmake
PRIVATE nValorRdm := 0
PRIVATE cDespRdm  := ""
Private cUltParc := ""  // GFP - 20/01/2014
lPOAuto := .T.
SW2->(DbSetOrder(1))
SW2->(Dbseek(xFilial('SW2',cFilPo) + cCodPO))
SWD->(DBSETORDER(1))
SYW->(DBSETORDER(1))
SY4->(DBSETORDER(1))
SA2->(DBSETORDER(1))
SY6->(DBSETORDER(1))
SB1->(DBSETORDER(1))
SWI->(DBSETORDER(2))
SW5->(DBSETORDER(3)) // GFP - 26/03/2013
SA2->(DBSEEK(xFilial("SA2")+SW2->W2_FORN))       
SWF->(DBSEEK(xFilial("SWF")+SW2->W2_TAB_PC))

If !SWI->(DBSEEK(xFilial('SWI')/*RMD - 21/03/19 xFilial("SWI")*/+SW2->W2_TIPO_EM+SW2->W2_TAB_PC)) // // RRV - 10/08/2012 / Procura a tabela de pré-calculo com via de transporte referente ao PO, se existirem mais de uma com o mesmo código corretamente.
   SWI->(DBSETORDER(1))
   SWI->(DBSEEK(xFilial('SWI')/*RMD - 21/03/19 xFilial("SWI")*/+SW2->W2_TAB_PC))
EndIf   

//Tabela de pré-cálculo vinculada ao P.O.
cTabPC:=SW2->W2_TAB_PC

//Código do agente de transporte/ embarcador
If SY4->(DBSEEK(XFILIAL("SY4")+SW2->W2_AGENTE))
   cFornFret:=SY4->Y4_FORN
   cLojaFret:=SY4->Y4_LOJA   
EndIf

If Empty(cFornFret)
	cMsgAgente:= StrTran(STR0151, "XXXX", AllTrim(SW2->W2_AGENTE)) + ENTER //"O fornecedor do Agente de Transporte não foi infomado. Atualize o cadastro XXXX."
EndIf

//Código do despachante
If !Empty(SW2->W2_DESP)
   IF SY5->(DBSEEK(XFILIAL("SY5")+ SW2->W2_DESP )) .AND. !EMPTY(SY5->Y5_FORNECE)
      cFornecMV:= SY5->Y5_FORNECE 
      cLojaFMV := SY5->Y5_LOJAF   
   ENDIF
   If Empty(cFornecMV)
      cMsgDespach:= StrTran(STR0152, "XXXX", AllTrim(SW2->W2_DESP)) + ENTER //"O fornecedor do Despachante não foi infomado. Atualize o cadastro XXXX."
   EndIf
Else
   cMsgDespach:= STR0153 //"O campo Despachante não está preechido. Preencha o campo Despachante na pasta Cadastrais do Purchase Order."
EndIf                       


//Cadastro de contas (evento contábil) configurado
If lIntEAI
   EC6->(DBSetOrder(1)) //EC6_FILIAL+EC6_TPMODU+EC6_ID_CAM+EC6_IDENTC
   If EC6->(DBSeek(xFilial() + AvKey("IMPORT", "EC6_TPMODU") + AvKey("150", "EC6_ID_CAM")))
      If Empty(EC6->EC6_NATFIN)
         cMsgValid += StrTran(STR0154, "####", AvSx3("EC6_NATFIN", AV_TITULO)) + ENTER //"O tipo de despesa do ERP para a geração do título no financeiro não foi informado. Acesse o cadastro de Eventos Contábeis e atualize o evento contábil IMPORT-150 (despesas provisórias), campo '####'."
         lEventFin:= .F.
      EndIf
   Else
      cMsgValid += STR0155 + ENTER //"O evento contábil IMPORT-150 (despesas provisórias) não foi encontrado. Verifique o cadastro de Eventos Contábeis."
      lEventFin:= .F.
   EndIf
EndIf

//Atualização das tabelas do sigaeic
SW3->(DBSETORDER(7))
ProcRegua(3)

EICTP25A({SW2->W2_PO_NUM,cTabPC,''})

Return 



Static FUNCTION CalTab(MMsgApu)

LOCAL aPagtos:={}, Paridade:=1, MFOB, MRateio,;
      MTx_Usd:= nTMExtDConTx//RMD - 21/03/19 - BuscaTaxa(cMOEDAEST,dDataConTx,.T.,.F.,.T.)// RA - 13/08/2003 - O.S. 746/03 e 748/03
//    MTx_Usd:= BuscaTaxa(cMOEDAEST,dDataBase) // RA - 13/08/2003 - O.S. 746/03 e 748/03
//    MTx_Usd:= BuscaTaxa("US$",SW2->W2_PO_DT) 


LOCAL MRateioPeso:=0  // Jonato em 12/08/2003

LOCAL bGrava  :={|desp,data,valor,tab,perc,lConverte| ;
                  TPC251Grava(desp,data,valor,tab,perc,cFilSWH,nDecWHVal,nDecWHValR,lConverte)}
Local bTPCPag:={ |TPC| IF(TPC:DESPESA # VALOR_CIF .And. aScan(aDespBase, &("{|x| x[1] == '"+TPC:DESPESA+"'}")) == 0 ,;
                   TPCCalculo(TPC, nQtdeSald, MRateio,MTx_Usd,bGrava,;
                   aPagtos,TPr_Cal,aDespBase,SW2->W2_FREPPCC,/*Origem252*/,/*PDBF*/,MRateioPeso,/*dDtRef*/,/*nParidade*/,SW6->W6_IMPORT,lRegTriPO,bTPCPag,@aBuffers,"TPC251"),) }  // GFP - 01/08/2013
LOCAL I, nInd_Frete, nimp, nVlrConte
LOCAL nVl_Pag := 0,  nOrdSW3:=(SW3->(INDEXORD()))
//RRV - 27/12/2012
Local n := 0
Local nPos, nPos2
Local cCalculado := "1"   //NCF - 10/01/2017
Local nBasCalFre          //NCF - 12/12/2018
Local aBuffers := {tHashMap():New(), tHashMap():New(), tHashMap():New()}//RMD - 08/04/19 - Buffers para a fun?o TPCCalculo: [1]-Dados de Paridade, [2]-Dados de NCM, [2]-Dados de Majora?o do Cofins
//RMD - 08/04/19 - Para evitar a chamada em loop na fun?o TPC251Grava
Local cFilSWH := xFilial("SWH")
Local nDecWHVal  := AvSX3("WH_VALOR", AV_DECIMAL)
Local nDecWHValR := AvSX3("WH_VALOR_R", AV_DECIMAL)

PRIVATE MFobDesp,nValFobTot, aTPC:={}, aDespBase:={},nValor_Frete := 0,nValor_Seguro := 0,aRateio := {} //RRV - 27/12/2012
Private MTx_Usd_Pc       //RRV - 27/12/2012
Private aICMS_Dif := {}  //NCF - 24/01/2013 - Array de aliquotas do CFO para cada item
If Type("oBufferNCM") <> "O"
   Private oBufferNCM := tHashMap():New()//RMD - 21/03/19 - Buffer para os dados de NCM
EndIf

lPOAuto := .T.

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
 IF (GetNewPar("MV_EASYFIN","N")='S' .Or. lAvIntDesp) .AND. cAVFase$'PODI'  //wfs 03/07/2014 - atualiza?o dos valores para integra?o via EAI
   //Se Integra?o com EASY Financeiro o sistema de baseia 
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
   IF EasyGParam("MV_AVG0227",,.F.) .And. Empty(SWF->WF_VIA) .And. aTPC[nInd_Frete][11] == "2"  //FSY - 15/07/2013- Valida?o para calcular frete com % fixo pela tabela de pre-calculo. Codigo adicionado: !(EasyGParam("MV_AVG0227",,.F.) .And. Empty(SWF->WF_VIA)
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
         //RRV - 27/12/2012 - Mudan? na sequencia de valores do frete(1?onteiner,2?ubagem,3?egra de peso por quilo).
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

IF nInd_Seguro != 0 .AND. !EMPTY(SW2->W2_SEGURIN)
   aTPC[nInd_Seguro][6]:=0 //PARA ZERAR O PERCENTUAL APLICADO
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
   
      nTotSegGeral := aTPC[nInd_Seguro][5]

   ENDIF
ENDIF
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
IF !((GetNewPar("MV_EASYFIN","N")='S' .Or. lAvIntDesp) .AND. cAVFase$'PODI') //wfs 03/07/2014 - atualiza?o dos valores para integra?o via EAI
   nValFobTot:=SW2->W2_FOB_TOT
ENDIF

Work_1->(DBGOTOP())

SYB->(DBSETORDER(1))

nTamCont:=AVSX3("WH_NR_CONT",3)

DO WHILE Work_1->(!EOF())
   If ( Type("lPOAuto") == "U" .OR. !lPOAuto )
      IncProc(MMsgApu)
   EndIf
   IF (GetNewPar("MV_EASYFIN","N")="S" .Or. lAvIntDesp) .AND. !(cPaisLoc="BRA") //AAF 27/11/08 - A vari?el cUltimoItem ?apenas para Localiza?es. //wfs 03/07/2014 - atualiza?o dos valores para integra?o via EAI
      Work_1->(DBSKIP())
      
      If Work_1->(EOF())       // Solicitado envio especificando qual ?o ultimo 
         cUltimoItem:=.t.
      ELSE
         cUltimoItem:=.f.
      Endif
      
      Work_1->(DBSKIP(-1))
   ENDIF
   //LRS - 26/07/2017 - Corre?o do calculo FOB de acordo com a paridade
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
  
   IF (GetNewPar("MV_EASYFIN","N")="S" .Or. lAvIntDesp) .AND. !(cPaisLoc="BRA") //wfs 03/07/2014 - atualiza?o dos valores para integra?o via EAI
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
          
          //ISS - 19/10/2010 - Para a grava?o de novos campos na tabela SWH
          If(EasyEntryPoint("EICTP251"),ExecBlock("EICTP251",.F.,.F.,"TPC251CALCTAB_GRV_SWH"),)
                    
       ENDIF 
       
      Next nImp   
       
   ENDIF
  
   Work_1->(DBSKIP())
         
ENDDO

//RRV - 27/12/2012 - Tratamento de acerto das despesas do pr?calculo.
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

//TP251CriaWork


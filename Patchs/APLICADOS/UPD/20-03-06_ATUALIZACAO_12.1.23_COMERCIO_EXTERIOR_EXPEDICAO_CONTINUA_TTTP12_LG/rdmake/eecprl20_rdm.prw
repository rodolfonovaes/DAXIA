//Revis�o - Alcir Alves - 05-12-05 - desconsiderar dados do ECC para eventos de cambio que n�o dependem do mesmo
//Revis�o - Alcir Alves - 06-12-05 - inclus�o de filtros por EEQ_TP_CON
//Revis�o - Henrique V. Ranieri - 19/06/06 - FINIMP, novos campos do SIGAEFF

#INCLUDE "EECRDM.CH"
#INCLUDE "EECPRL20.CH"

/*
Programa  : EECPRL20_RDM.
Objetivo  : Relat�rio de Controle de Cambiais
Autor     : Jo�o Pedro Macimiano Trabbold
Data/Hora : 04/08/04; 10:38
Obs       :
*/

/*
Funcao      : EECPRL20().
Parametros  : Nenhum.
Retorno     : .f.
Objetivos   : Impress�o do Relat�rio de Controle de Cambiais
Autor       : Jo�o Pedro Macimiano Trabbold.
Data/Hora   : 04/08/04; 10:38
*/
*-----------------------*
User Function EECPRL20()
*-----------------------*
Local nValFob := 0, nValCom := 0 ,lAppend := .t.
Local cProcAtual := ""//, cProcPast := ""
Local   aOrd   := SaveOrd({"EEQ","EC6","EF3","EEC","SA1","SA2","SA6"})
// WFS 13/10/08
// contador
Local nInc
//Array para ordena��o com o nome do importador
Local aReg := {}
Private cProcPast := ""
//Alcir Alves - 05-12-05
Private lTPCONExt:=(EEQ->(fieldpos("EEQ_TP_CON"))>0)
Private oCbTpCon,cTpCon
Private aTpCon:={"*Todos","1-Exportacao","2-Importacao","3-Recebimento","4-Remessa"}
//
Private lRet   := .t. ,lApaga:= .f., lFlag:=.f. , lCalc := .f.
Private cArqRpt:="rel20.rpt",;
		  cTitRpt:= STR0001 //"Controle de Cambiais"
Private aArqs,;
        cNomDbfC := "CAMBIALC",;
        aCamposC := {{"SEQREL"     ,"C",08,0 },;
                     {"FILIAL"     ,"C",2,0 },;
                     {"PERIODO"    ,"C",25,0 },;
                     {"IMPORTADOR" ,"C",AvSx3("A1_NOME",AV_TAMANHO),0 },;
                     {"FORNECEDOR" ,"C",AvSx3("A2_NOME",AV_TAMANHO),0 },;
                     {"MOEDA"      ,"C",AvSx3("EEC_MOEDA",AV_TAMANHO)+2,0 },;
                     {"TITULOS"    ,"C",25,0 },;
                     {"VINC_FIN"   ,"C",5 ,0 }}

Private cNomDbfD := "CAMBIALD",;
        aCamposD := {{"SEQREL"     ,"C", 8,0},;
                     {"EEQ_PREEMB" ,"C",AvSx3("EEQ_PREEMB",AV_TAMANHO),0 },;
                     {"EEQ_IMPORT" ,"C",AvSx3("A1_NREDUZ" ,AV_TAMANHO),0 },;
                     {"EEQ_MOEDA"  ,"C",AvSx3("EEC_MOEDA" ,AV_TAMANHO),0 },;
                     {"A6_NREDUZ"  ,"C",AvSx3("A6_NREDUZ" ,AV_TAMANHO),0 },;
                     {"EEQ_RFBC"   ,"C",AvSx3("EEQ_RFBC"  ,AV_TAMANHO),0 },;
                     {"EEQ_VLCAMB" ,"C",AvSx3("EEQ_VL"    ,AV_TAMANHO)+7,0 },;
                     {"EEQ_VLCOMS" ,"C",AVSX3("EEC_VALCOM",AV_TAMANHO)+7,0 },;
                     {"EEC_DTCONH" ,"C",AvSx3("EEC_DTCONH",AV_TAMANHO),0 },;
                     {"EEQ_VCT"    ,"C",AvSx3("EEQ_VCT"   ,AV_TAMANHO),0 },;
                     {"SALDO"      ,"C",AvSx3("EEQ_VL"    ,AV_TAMANHO)+7,0 },;
 					 		{"EEQ_DTCE"   ,"C",AvSx3("EEQ_DTCE"  ,AV_TAMANHO),0 },;
 							{"DIASATRASO" ,"C",10,0 },;
                     {"VALORJUROS" ,"C",AvSx3("EF3_VL_MOE",AV_TAMANHO)+7,0 },;
                     {"EEQ_FORN"   ,"C",AvSx3("A2_NREDUZ" ,AV_TAMANHO),0 },;
                     {"EEC_CONDPA" ,"C",AvSx3("EEC_CONDPA",AV_TAMANHO),0 },;
                     {"EEC_DIASPA" ,"C",AvSx3("EEC_DIASPA",AV_TAMANHO),0 },;
                     {"EF3_CONTRA" ,"C",AvSx3("EF3_CONTRA",AV_TAMANHO),0 },;
                     {"TP_CON","C",18,0 },;
                     {"FLAG","C",1,0 }}

Private dDtIni     := AVCTOD("  /  /  ")
Private dDtFim     := AVCTOD("  /  /  ")
Private aFinanc    := {STR0002,STR0003,STR0004} //{"Ambos","Sim","N�o"}
Private cFinanc    := ""
Private cImport    := Space(AVSX3("A1_COD"   ,AV_TAMANHO))
Private cFornece   := Space(AVSX3("A2_COD"   ,AV_TAMANHO))
Private cForn      := ""
Private cImp       := ""
Private cMoeda     := Space(AVSX3("EEQ_MOEDA",AV_TAMANHO))
Private lProc      := .f.
Private aTitulos   := {STR0005,STR0006}  //{"A Receber","A Pagar"}
Private cTitulos   := ""
Private cAlias     := ""
Private lTrat      := .t. , lTratCom:= .t.
Private nPos, nInd:=0
Private nRec:=0
Private nVlCamb :=0, dVencto := AVCTOD("  /  /  ")
Private aLiquida   := {STR0026,STR0027,STR0028}//{"Liquidados","N�o Liquidados","Todos"}
Private cLiquida   := ""
Private aPagtoExt  := {STR0003,STR0004,STR0028}//CCH - 03/09/2008 - Filtro por Pagamento no Exterior, "Sim", "N�o", "Todos"
Private cPagtoExt  := ""
//WFS - 10/10/08
Private lOrdImp := .F., oOrdImp
//HVR - Novos campos do FinImp
Private lEFFTpMod := EF1->( FieldPos("EF1_TPMODU") ) > 0 .AND. EF1->( FieldPos("EF1_SEQCNT") ) > 0 .AND.;
                     EF2->( FieldPos("EF2_TPMODU") ) > 0 .AND. EF2->( FieldPos("EF2_SEQCNT") ) > 0 .AND.;
                     EF3->( FieldPos("EF3_TPMODU") ) > 0 .AND. EF3->( FieldPos("EF3_SEQCNT") ) > 0 .AND.;
                     EF4->( FieldPos("EF4_TPMODU") ) > 0 .AND. EF4->( FieldPos("EF4_SEQCNT") ) > 0 .AND.;
                     EF6->( FieldPos("EF6_SEQCNT") ) > 0 .AND. EF3->( FieldPos("EF3_ORIGEM") ) > 0 .and.;
                     EF3->( FieldPos("EF3_ROF"   ) ) > 0

//JVR - 11/12/09 - Relat�rio Personalizavel
Private oReport
Private lRelPersonal := FindFunction("TRepInUse") .And. TRepInUse()

BEGIN SEQUENCE
   lTrat    := EECFlags("FRESEGCOM")  // vari�vel que verifica os novos tratamentos de frete, seguro e comiss�o
   lTratCom := EECFlags("COMISSAO")   // vari�vel que verifica os novos tratamentos de frete, seguro e comiss�o
   aARQS := {}
   AADD(aARQS,{cNOMDBFC,aCAMPOSC,"CAP","SEQREL"})
   AADD(aARQS,{cNOMDBFD,aCAMPOSD,"DET","SEQREL"})

   IF ! TelaGets()
      lRet := .F.
      Break
   Endif

   aRetCrw := CrwNewFile(aARQS)
   lApaga:= .t.

   cSEQREL :=GetSXENum("SY0","Y0_SEQREL")
   CONFIRMSX8()

   CAP->(DBAPPEND())
   CAP->SEQREL := cSEQREL
   CAP->FILIAL:=cfilant
   //testa o filtro de data de vencimento do cambio que aparecer� no cabe�alho do relat�rio
   if empty(dDtIni)
      if !empty(dDtFim) //somente Data final preenchida
         CAP->PERIODO := STR0007 + DTOC(dDtFim)  //"at�"
      else //nenhuma data preenchida
         CAP->PERIODO := STR0008 //"Todos"
      endif
   else
      if !empty(dDtFim)
         if dDtIni == dDtFim//DtIni e DtFim iguais
            CAP->PERIODO := DTOC(dDtFim)
         else //DtIni e DtFim <>
            CAP->PERIODO := STR0009 + DTOC(dDtIni) + STR0010 + DTOC(dDtFim) //"De " + DTOC(dDtIni) + " a " + DTOC(dDtFim)
         endif
      else//somente data inicial preenchida
         CAP->PERIODO :=  STR0011 + DTOC(dDtIni) //"Ap�s "
      endif
   endif

   //testa o filtro de importador que aparecer� no cabe�alho do relat�rio
   if !empty(cImport)
      SA1->(DBSEEK(xFilial("SA1")+cImport))
      CAP->IMPORTADOR := SA1->A1_NOME
   else
      CAP->IMPORTADOR := STR0008 //"Todos"
   endif

   //testa o filtro de Fornecedor que aparecer� no cabe�alho do relat�rio
   if !empty(cFornece)
      SA2->(DBSEEK(xFilial("SA2")+cFornece))
      CAP->FORNECEDOR := SA2->A2_NOME
   else
      CAP->FORNECEDOR := STR0008 //"Todos"
   endif
   if !empty(cFornece)
      CAP->MOEDA    := cMoeda
   Else
      CAP->MOEDA    := STR0012 //"Todas"
   Endif
   CAP->VINC_FIN := cFinanc
   CAP->TITULOS  := " - " + cTitulos

   #IFDEF TOP
      IF TCSRVTYPE() <> "AS/400"
         cCmd := MontaQuery()
         cCmd := ChangeQuery(cCmd)
         dbUseArea(.T., "TOPCONN", TCGENQRY(,,cCmd), "QRY", .F., .T.)
         cAlias:="QRY"
      ELSE
         cAlias:="EEQ"
         EEQ->(DBSETORDER(1))
         EEQ->(DBSEEK(xFilial("EEQ")))
      ENDIF
   #ELSE
      cAlias:="EEQ"
      EEQ->(DBSETORDER(1))
      EEQ->(DBSEEK(xFilial("EEQ")))
   #ENDIF

//WFS - 13/10/08
//Alimentando o array com o nome do importador.
//Quando for solicitada a ordena��o pelo nome, os registros ser�o posicionados de acordo com o RecNo armazenado
//neste array
   If cAlias == "EEQ"
      While (cAlias)->(!EOF()) .AND. xFilial("EEQ") == (cAlias)->EEQ_FILIAL
         aAdd(aReg, {EEQ->(Recno()), Posicione("SA1", 1, xFilial("SA1")+EEQ->(EEQ_IMPORT+EEQ_IMLOJA), "A1_NREDUZ")})
         EEQ->(DbSkip())
      EndDo
   EndIf
   //Ordena pelo nome do importador (DBF) - WFS 13/10/08
   If lOrdImp .And. cAlias == "EEQ"
       aSort(aReg,,,{|x, y| x[2] < y[2]})
   EndIf

   If cAlias == "EEQ"
      For nInc := 1 To Len(aReg)
         (cAlias)->(DbGoTo(aReg[nInc][1]))
         GrvWork(cAlias)
      Next
   Else
      While (cAlias)->(!EOF()) .AND. xFilial("EEQ") == (cAlias)->EEQ_FILIAL
         GrvWork(cAlias)
         (cAlias)->(DbSkip())
      EndDo
   EndIf

/* WFS - 13/10/08
   Com esta parte do c�digo foi criada uma fun��o (GeraWork) para o tratamento de ordena��o do relat�rio
   por nome do importador.

      While (cAlias)->(!EOF()) .AND. xFilial("EEQ") == (cAlias)->EEQ_FILIAL
         //Alcir Alves - 05-12-05 - considera apena tipo 1 - Exporta��o
         //if lTPCONExt
         //   if (cAlias)->EEQ_TP_CON<>"1" .and. (cAlias)->EEQ_TP_CON<>"2"
         //     (cAlias)->(DBSKIP())
         //      loop
         //   ENDIF
         //endif
         //
         EEC->(DbSetOrder(1))//filtros: Receita - importador, despesa - fornecedor(sem os novos tratamentos de frete, seguro, comiss�o)
         EEC->(DBSEEK(xFilial("EEC")+(cAlias)->EEQ_PREEMB))
         if !lTPCONExt .and. EEC->(eof())
            (cAlias)->(DbSkip())
            Loop
         endif

         if lTPCONExt
            if cTpCon==aTpCon[2] //"1-C�mbio de Exporta��o"
              IF (cAlias)->EEQ_TP_CON<>"1"
                 (cAlias)->(DbSkip())
                 Loop
              ENDIF
            elseif cTpCon==aTpCon[3] //"2-C�mbio de Importa��o"
              IF (cAlias)->EEQ_TP_CON<>"2"
                 (cAlias)->(DbSkip())
                 Loop
              ENDIF
            elseif cTpCon==aTpCon[4] //"3-Recebimento"
              IF (cAlias)->EEQ_TP_CON<>"3"
                 (cAlias)->(DbSkip())
                 Loop
              ENDIF
            elseif cTpCon==aTpCon[5] //"4-Remessa"
              IF (cAlias)->EEQ_TP_CON<>"4"
                 (cAlias)->(DbSkip())
                 Loop
              ENDIF
            endif
         endif

         If lTrat .OR. EEC->(EOF())
            EC6->(DbSetOrder(1)) //filtros: Receita - importador, despesa - fornecedor
            if EC6->(DbSeek(xFilial("EC6")+"EXPORT"+(cAlias)->EEQ_EVENT))
               if EC6->EC6_RECDES == "1" .AND. (cTitulos == STR0006 .Or. If(!Empty(cImport),(cAlias)->EEQ_IMPORT <> cImport,.f.)) //"A Pagar"
                  (cAlias)->(DbSkip())
                  Loop
               endif
               if EC6->EC6_RECDES == "2" .AND. (cTitulos == STR0005 .Or. If(!Empty(cFornece),(cAlias)->EEQ_FORN <> cFornece,.f.)) //"A Receber"
                  (cAlias)->(DbSkip())
                  Loop
               endif
            endif
         Else
            EC6->(DbSetOrder(1))
            if EC6->(DbSeek(xFilial("EC6")+"EXPORT"+(cAlias)->EEQ_EVENT))
               if EC6->EC6_RECDES == "1" .AND. (cTitulos == STR0006 .Or. If(!Empty(cImport),EEC->EEC_IMPORT <> cImport,.f.)) //"A Pagar"
                  (cAlias)->(DbSkip())
                  Loop
               endif
               if EC6->EC6_RECDES == "2" .AND. (cTitulos == STR0005 .Or. If(!Empty(cFornece),EEC->EEC_FORN <> cFornece,.f.)) //"A Receber"
                  (cAlias)->(DbSkip())
                  Loop
               endif
            endif
         EndIf
         //filtro: Vinculados a financiamento??
         if cFinanc <> STR0002 //"Ambos"
            EF3->(DbSetOrder(3))
            if EF3->(DbSeek(xFilial("EF3")+IF(lEFFTpMod, IF((cAlias)->EEQ_TP_CON $ ("2/4"),"I","E"),"")+(cAlias)->EEQ_NRINVO+(cAlias)->EEQ_PARC)) //HVR
               if cFinanc == STR0004 //"N�o"
                  (cAlias)->(DBSkip())
                  loop
               endif
            else
               if cFinanc == STR0003 //"Sim"
                  (cAlias)->(DBSkip())
                  loop
               endif
            endif
         endif
         //Alcir Alves - 05-12-05 - por causa dos novos tipos de cambio TP_CON 1,2,3 e 4 ser� necess�rio for�ar
         //a valida��o manual para top e codebase
         If !FiltrosDBF(cAlias)  // filtros para ambiente codebase
            loop
         Endif

         /*
         #IFDEF TOP
            IF TCSRVTYPE() = "AS/400"
               If !FiltrosDBF()  // filtros para ambiente codebase
                  loop
               Endif
            Endif
         #ELSE
            If !FiltrosDBF()  // filtros para ambiente codebase
               loop
            EndIf
         #ENDIF
         */
      /*
         cProcAtual := (cAlias)->EEQ_PREEMB
         //Grava��o dos detalhes
         DET->(DbAppend())
         IF lTPCONExt //HVR
            if !empty((cAlias)->EEQ_TP_CON)
               if val((cAlias)->EEQ_TP_CON)<=(len(aTpCon)-1)
                  DET->TP_CON:=aTpCon[(val((cAlias)->EEQ_TP_CON)+1)]
               else
                  DET->TP_CON:="-"
               endif
            else
               DET->TP_CON:="-"
            endif
         ELSE
            DET->TP_CON:="-"
         ENDIF
         lFlag := !lFlag
         If(lFlag, DET->FLAG := "X", DET->FLAG := "Y") //zebrado do relat�rio
         DET->SEQREL     := cSEQREL
         DET->EEQ_PREEMB := (cAlias)->EEQ_PREEMB
         SA6->(DbSetOrder(1))
         SA6->(DbSeek(xFilial("SA6")+(cAlias)->EEQ_BANC))
         DET->A6_NREDUZ  := SA6->A6_NREDUZ  //nome reduzido do banco
         DET->EEQ_RFBC   := LOWER((cAlias)->EEQ_RFBC) //refer�ncia banc�ria

         If Empty((cAlias)->EEQ_ORIGEM)  //c�lculo do valor cambial - in�cio
            If cAlias == "EEQ"
               nRec := (cAlias)->(RecNo())
            Else
               EEQ->(DbGoTop())
               EEQ->(DbSetOrder(1))
               EEQ->(DbSeek(xFilial("EEQ")+(cAlias)->EEQ_PREEMB+(cAlias)->EEQ_PARC))
            Endif
            CalcCamb(.t.)
            If(cAlias == "EEQ",(cAlias)->(DbGoTo(nRec)),)
         Endif
         if Empty((cAlias)->EEQ_PGT)  //n�o pago
            DET->SALDO   := Alltrim(TRANSFORM((cAlias)->EEQ_VL,  AVSX3("EEQ_VL",  AV_PICTURE)))
            If lCalc
               DET->EEQ_VLCAMB := Alltrim(TRANSFORM((cAlias)->EEQ_VL, AVSX3("EEQ_VL",  AV_PICTURE)))
            Else
               DET->EEQ_VLCAMB := Alltrim(TRANSFORM(nVlCamb, AVSX3("EEQ_VL",  AV_PICTURE)))
            Endif
         Else      //pago
            DET->SALDO := "0"
            DET->EEQ_VLCAMB := Alltrim(TRANSFORM((cAlias)->EEQ_VL, AVSX3("EEQ_VL",  AV_PICTURE)))
         Endif  //c�lculo do valor cambial - fim

         EEQ->(DbSetOrder(1))
         lCalc := .f.

         #IFDEF TOP
            If TCSRVTYPE() <> "AS/400"
               dVencto  := AVCTOD(SUBSTR((cAlias)->EEQ_VCT,7,2)+"/"+SUBSTR((cAlias)->EEQ_VCT,5,2)+"/"+SUBSTR((cAlias)->EEQ_VCT,3,2))
            Else
               dVencto  := (cAlias)->EEQ_VCT
            Endif
         #ELSE
            dVencto :=  (cAlias)->EEQ_VCT
         #ENDIF
         If dDatabase > dVencto .and. Empty((cAlias)->EEQ_PGT) // c�lculo dos dias de atraso
            DET->DIASATRASO := AllTrim(Str(dDatabase - dVencto))+ If(dDatabase - dVencto <> 1,STR0013,STR0014) //" dias"," dia"
         Else
            DET->DIASATRASO := "-"
         Endif

         EEC->(DbSetOrder(1))
         EEC->(DbSeek(xFilial("EEC")+(cAlias)->EEQ_PREEMB))
         //c�culo do valor da comiss�o
         IF !EEC->(EOF())
            If lTrat //com tratamentos de frete, seguro e comiss�o, h� uma comiss�o pra cada parcela
               nValcom := (cAlias)->EEQ_AREMET + (cAlias)->EEQ_ADEDUZ + (cAlias)->EEQ_CGRAFI
               DET->EEQ_VLCOMS := Alltrim(Transform(nValcom,AVSX3("EEC_VALCOM",AV_PICTURE)))
            Else  //sem tratamentos de frete, de seguro e comiss�o
               If cProcAtual <> cProcPast //a cada mudanca de PREEMB, h� o c�lculo da comiss�o
                  If lTratCom
                     DET->EEQ_VLCOMS := Alltrim(Transform(EEC->EEC_VALCOM,AVSX3("EEC_VALCOM",AV_PICTURE)))
                  Else
                     nValFOB := (EEC->EEC_TOTPED+EEC->EEC_DESCON)-(EEC->EEC_FRPREV+EEC->EEC_FRPCOM+EEC->EEC_SEGPRE+EEC->EEC_DESPIN+AvGetCpo("EEC->EEC_DESP1")+AvGetCpo("EEC->EEC_DESP2"))
                     nValCom := (if(EEC->EEC_TIPCVL=="1",(EEC->EEC_VALCOM*nValFOB)/100,EEC->EEC_VALCOM))
                     DET->EEQ_VLCOMS := Alltrim(Transform(nValcom,AVSX3("EEC_VALCOM",AV_PICTURE)))
                  Endif
               Endif
            Endif
            DET->EEC_CONDPA  :=  EEC->EEC_CONDPA  //condi��o de pagamento
            DET->EEC_DIASPA  :=  ALLTRIM(STR(EEC->EEC_DIASPA)) //dias da condi��o de pagamento
         else
            DET->EEQ_VLCOMS := Alltrim(Transform(0,AVSX3("EEC_VALCOM",AV_PICTURE)))
            DET->EEC_CONDPA  :=  "-"
            DET->EEC_DIASPA  :=  "-"
         ENDIF

         #IFDEF TOP
            If TCSRVTYPE() = "AS/400"
               If EEC->(EOF()) .OR. Empty(EEC->EEC_DTCONH)          //datas
                  DET->EEC_DTCONH  := "-"
               Else
                  DET->EEC_DTCONH  := TRANSFORM(DTOC(EEC->EEC_DTCONH) ,AVSX3("EEC_DTCONH" ,AV_PICTURE))
               EndIf

               If Empty(EEQ->EEQ_DTCE)
                  DET->EEQ_DTCE  := "-"
               Else
                  DET->EEQ_DTCE := TRANSFORM(DTOC((cAlias)->EEQ_DTCE),AVSX3("EEQ_DTCE",AV_PICTURE))
               EndIf

               If Empty(EEQ->EEQ_VCT)
                  DET->EEQ_VCT  := "-"
               Else
                  DET->EEQ_VCT  := TRANSFORM(DTOC((cAlias)->EEQ_VCT) ,AVSX3("EEQ_VCT" ,AV_PICTURE))
               EndIf
            Else
               if EEC->(EOF()) .OR. Empty(EEC->EEC_DTCONH)
                  DET->EEC_DTCONH  := "-"
               else
                  DET->EEC_DTCONH:= TRANSFORM(DTOC(EEC->EEC_DTCONH) ,AVSX3("EEC_DTCONH" ,AV_PICTURE))
               endif

               if Empty((cAlias)->EEQ_DTCE)
                  DET->EEQ_DTCE  := "-"
               else
                  DET->EEQ_DTCE := SUBSTR((cAlias)->EEQ_DTCE,7,2)+"/"+SUBSTR((cAlias)->EEQ_DTCE,5,2)+"/"+SUBSTR((cAlias)->EEQ_DTCE,3,2)
               endif

               if Empty((cAlias)->EEQ_VCT)
                  DET->EEQ_VCT  := "-"
               else
                  DET->EEQ_VCT  := SUBSTR((cAlias)->EEQ_VCT,7,2)+"/"+SUBSTR((cAlias)->EEQ_VCT,5,2)+"/"+SUBSTR((cAlias)->EEQ_VCT,3,2)
               endif

            endif
         #ELSE

            If EEC->(EOF()) .OR. EEC->(EOF())
               DET->EEC_DTCONH  := "-"
            Else
               DET->EEC_DTCONH  := TRANSFORM(DTOC(EEC->EEC_DTCONH) ,AVSX3("EEC_DTCONH" ,AV_PICTURE))
            EndIf

            If Empty(EEQ->EEQ_DTCE)
               DET->EEQ_DTCE  := "-"
            Else
               DET->EEQ_DTCE := TRANSFORM(DTOC((cAlias)->EEQ_DTCE),AVSX3("EEQ_DTCE",AV_PICTURE))
            EndIf

            If Empty(EEQ->EEQ_VCT)
               DET->EEQ_VCT  := "-"
            Else
               DET->EEQ_VCT  := TRANSFORM(DTOC((cAlias)->EEQ_VCT) ,AVSX3("EEQ_VCT" ,AV_PICTURE))
            EndIf

         #ENDIF
         EEC->(DbSetOrder(1))
         EEC->(DbSeek(xFilial("EEC")+(cAlias)->EEQ_PREEMB))
         If lTrat .or. EEC->(EOF())
               DET->EEQ_MOEDA  := (cAlias)->EEQ_MOEDA

               SA1->(DbSetOrder(1))

               If SA1->(DbSeek(xFilial("SA1")+(cAlias)->EEQ_IMPORT))
                  DET->EEQ_IMPORT := SA1->A1_NREDUZ
               Endif
               SA2->(DbSetOrder(1))
               If SA2->(DbSeek(xFilial("SA2")+(cAlias)->EEQ_FORN))
                  DET->EEQ_FORN   := SA2->A2_NREDUZ
               Endif
         Else
               DET->EEQ_MOEDA  := EEC->EEC_MOEDA

               SA1->(DbSetOrder(1))
               SA1->(DbSeek(xFilial("SA1")+EEC->EEC_IMPORT))
               DET->EEQ_IMPORT := SA1->A1_NREDUZ

               SA2->(DbSetOrder(1))
               SA2->(DbSeek(xFilial("SA2")+EEC->EEC_FORN))
               DET->EEQ_FORN   := SA2->A2_NREDUZ
         Endif

         // impress�o dos contratos de financiamento para cada parcela
         EF3->(DbSetOrder(3))
         if EF3->(DbSeek(xFilial("EF3")+IF(lEFFTpMod, IF((cAlias)->EEQ_TP_CON $ ("2/4"),"I","E"),"")+(cAlias)->EEQ_NRINVO+(cAlias)->EEQ_PARC+"600")) //HVR
            lAppend := .f.
            While !EF3->(EOF()) .And. xFilial("EF3") == EF3->EF3_FILIAL .And. IF(lEFFTpMod, IF((cAlias)->EEQ_TP_CON $ ("2/4"),"I","E") = EF3->EF3_TPMODU, .T.) .And. (cAlias)->EEQ_PARC == EF3->EF3_PARC .And. (cAlias)->EEQ_NRINVO == EF3->EF3_INVOIC .and. EF3->EF3_CODEVE == "600"
               If lAppend
                  DET->(DBAppend())
                  DET->SEQREL   := cSEQREL
                  If(lFlag, DET->FLAG := "X", DET->FLAG := "Y")
               Endif
               DET->EF3_CONTRA := EF3->EF3_CONTRA
               nRecEF3 := EF3->(RecNo())
               nJuros  := 0
               if EF3->(DbSeek(xFilial("EF3")+IF(lEFFTpMod, IF((cAlias)->EEQ_TP_CON $ ("2/4"),"I","E"),"")+(cAlias)->EEQ_NRINVO+(cAlias)->EEQ_PARC+"520"))//c�lculo dos juros //HVR
                  While !EF3->(EOF()) .And. xFilial("EF3") == EF3->EF3_FILIAL .And. IF(lEFFTpMod, IF((cAlias)->EEQ_TP_CON $ ("2/4"),"I","E") = EF3->EF3_TPMODU, .T.) .And. (cAlias)->EEQ_PARC == EF3->EF3_PARC .And. (cAlias)->EEQ_NRINVO == EF3->EF3_INVOIC .and. EF3->EF3_CODEVE == "520"
                     If DET->EF3_CONTRA == EF3->EF3_CONTRA
                        nJuros += EF3->EF3_VL_MOE
                     Endif
                     EF3->(DbSkip())
                  Enddo
                  DET->VALORJUROS :=Transform(nJuros,AvSx3("EF3_VL_MOE",AV_PICTURE))
               Else
                  DET->VALORJUROS := "-"
               Endif
               EF3->(DbGoto(nRecEF3))
               EF3->(DbSkip())
               lAppend := .t.
            EndDo
         Endif
         nJuros := 0
         lProc := .t.
         cProcPast := cProcAtual
         (cAlias)->(DBSkip())
      Enddo   */ // WFS - 13/10/08

   if lProc = .f.
      msginfo(STR0015,STR0016)//("Intervalo sem dados para impress�o.","Aviso!")
      lRet := .f.
      break
   ELSE
      //JVR - 04/12/09 - Relat�rio Personalizavel
      If lRelPersonal
         oReport := ReportDef()
      EndIf
   endif

END SEQUENCE

IF ( lRet )
   //JVR - 01/12/09 - Relat�rio Personalizavel
   If lRelPersonal
      oReport:PrintDialog()
      CrwCloseFile(aRetCrw,.T.)
   Else
      lRetC := CrwPreview(aRetCrw,cArqRpt,cTitRpt,cSeqRel)
   EndIf
ELSEIF lApaga
   // Fecha e apaga os arquivos temporarios
   CrwCloseFile(aRetCrw,.T.)
ENDIF

if cAlias == "QRY"
   QRY->(DbCloseArea())
endif
RestOrd(aOrd)

Return (.f.)

/*
Funcao      : TelaGets().
Parametros  : Nenhum.
Retorno     : .t./.f.
Objetivos   : Tela com op��es de filtros para os embarques.
Autor       : Jo�o Pedro Macimiano Trabbold.
Data/Hora   : 04/08/04; 10:50
*/
*-----------------------------*
Static Function TelaGets()
*-----------------------------*
Local lRet  := .f.
Local nOpc  := 0
Local bOk, bCancel, oPanel
Private oCbxTit, oGetForn, oGetImp, oForn, oImp, oGetLoja, cLoja, oCbxPgt

Begin Sequence

   DEFINE MSDIALOG oDlg TITLE cTitRpt FROM 0,0 TO 30,49 OF oMainWnd //29.5  -  31,34

      oPanel:=TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 0, 0)
      oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

      @ 12,8  SAY STR0017 Of oPanel PIXEL //"Dt. Venc. :"
      @ 10,38 MSGET dDtIni SIZE 40,8 Of oPanel PIXEL

      @ 12,88 SAY STR0007 Of oPanel PIXEL //"At� "
      @ 10,98 MSGET dDtFim SIZE 40,8 Of oPanel PIXEL

      @ 25,8  SAY STR0018 Of oPanel PIXEL //"T�tulos :"
      //TComboBox():New(65,60,bSETGET(cTitulos),aTitulos,40,8,oDlg,,,,,,.T.)
      @ 23,38 COMBOBOX oCbxTit VAR cTitulos ITEMS aTitulos  SIZE 80,8 ON CHANGE (fChange()) Of oPanel PIXEL

      @ 38,8 SAY STR0025 Of oPanel PIXEL //"Liquida��o:"
      @ 36,38 COMBOBOX oCbxLiq VAR cLiquida ITEMS aLiquida SIZE 80,8 ON CHANGE(fChange()) Of oPanel PIXEL

      @ 51,8 SAY STR0029 Of oPanel PIXEL //"Pagto.Ext:"
      @ 49,38 COMBOBOX oCbxPgt VAR cPagtoExt ITEMS aPagtoExt SIZE 40,8 ON CHANGE(fChange()) Of oPanel PIXEL

      @ 64,8  SAY STR0019 Of oPanel PIXEL //"Fornecedor:"
      @ 62,38 MSGET oGetForn VAR cFornece F3 "YA2" Valid (Empty(cFornece) .or. ExistCPO("SA2")) SIZE 60,8 ON CHANGE (TrazDesc("FORN")) Of oPanel PIXEL

      @ 77,8  SAY STR0020 Of oPanel PIXEL //"Descri��o :"
      @ 75,38 MSGET oForn VAR cForn SIZE 130,8 Of oPanel PIXEL
      oForn:Disable()
      cForn:=Space(20)

      @ 90,8  SAY STR0021 Of oPanel PIXEL //"Importador :"
      @ 88,38 MSGET oGetImp VAR cImport F3 "EA1" Valid (Empty(cImport) .or. ExistCPO("SA1")) SIZE 60,8 ON CHANGE (TrazDesc("IMP")) Of oPanel PIXEL

      @ 103,8  SAY STR0020 Of oPanel PIXEL //"Descri��o :"
      @ 101,38 MSGET oImp VAR cImp SIZE 130,8 Of oPanel PIXEL
      oImp:Disable()
      cImp:=Space(20)

      @ 116,8  SAY STR0022 Of oPanel PIXEL //"Vinc. Fin.?"
      TComboBox():New(114,38,bSETGET(cFinanc),aFinanc,40,8,oPanel,,,,,,.T.)

      @ 129,8  SAY STR0023 Of oPanel PIXEL //"Moeda: "
      @ 127,38 MSGET cMoeda PICTURE "@!" F3 "SYF" Valid (Empty(cMoeda) .or. ExistCPO("SYF")) SIZE 40,8 Of oPanel PIXEL

      if lTPCONExt
          @ 142,8  SAY AVSX3("EEQ_TP_CON",5) Of oPanel PIXEL //"Tipo de contrato "
          @ 140,38 COMBOBOX oCbTpCon VAR cTpCon ITEMS aTpCon SIZE 65,8 Of oPanel PIXEL
      else
          cTpCon:=aTpCon[2]
      endif
      // WFS - 10/10/08
      // Op��o de ordena��o por nome do importador
      @ 153,8 CheckBox oOrdImp Var lOrdImp Prompt "Ordena pelo nome do Importador? " Size 090,08 Of oPanel Pixel

      fChange()

      bOk     := {|| If(ConfereDt(),(nOpc:=1, oDlg:End()),nOpc:=0)}
      bCancel := {|| oDlg:End() }

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel) CENTERED

   IF nOpc == 1
      lRet := .t.
   Else
      lRet := .f.
   Endif

End Sequence

Return lRet

/*
Funcao      : fChange().
Parametros  : Nenhum.
Retorno     : nil
Objetivos   : Enable/Disable dos campos de Fornecedor e Importador, de acordo com o tipo de titulo(A Receber ou a Pagar)
Autor       : Jo�o Pedro Macimiano Trabbold.
Data/Hora   : 23/08/04; 13:20
*/

*------------------------*
Static Function fChange()
*------------------------*

Begin Sequence

   if cTitulos == STR0006 //"A Pagar"
      oGetForn:Enable()
      cFornece:= Space(AVSX3("A2_COD",AV_TAMANHO))
      cForn:= Space(90)
      oGetImp:Disable()
      cImport:= ""
      cImp:= ""
      oGetImp:Refresh()
      oImp:Refresh()
   endif

   if cTitulos == STR0005 //"A Receber"
      oGetImp:Enable()
      cImport := Space(AVSX3("A1_COD",AV_TAMANHO))
      cImp:= Space(90)
      cFornece:= ""
      cForn:= ""
      oGetForn:Disable()
      oGetForn:Refresh()
      oForn:Refresh()
   endif

end sequence
return nil

/*
Funcao      : TrazDesc().
Parametros  : cTipo : define se � a descri��o do importador ou do fornecedor
Retorno     : NIL
Objetivos   : Traz descri��o do Fornecedor e Importador na tela de filtros
Autor       : Jo�o Pedro Macimiano Trabbold.
Data/Hora   : 20/08/04; 13:20
*/
*------------------------------*
Static Function TrazDesc(cTipo)
*------------------------------*
Begin Sequence
   If cTipo == "FORN"
      SA2->(DbSetOrder(1))
      SA2->(DBSeek(xFilial("SA2")+cFornece))
      cForn := SA2->A2_NOME
   else
      SA1->(DbSetOrder(1))
      SA1->(DBSeek(xFilial("SA1")+cImport))
      cImp := SA1->A1_NOME
   endif
end sequence
return nil

/*
Funcao      : ConfereDt().
Parametros  : Nenhum.
Retorno     : .t./.f.
Objetivos   : Confere se as datas digitadas na tela de filtro s�o v�lidas.
Autor       : Jo�o Pedro Macimiano Trabbold.
Data/Hora   : 04/08/04; 13:27
*/
*-----------------------------------*
Static Function ConfereDt()
*-----------------------------------*
Local lRet := .f.

Begin Sequence

   if !empty(dDtIni) .And. !empty(dDtFim) .And. dDtIni > dDtFim
      MsgInfo(STR0024,STR0016) //("Data Final n�o pode ser menor que a inicial.","Aviso!")
   Else
      lRet := .t.
   Endif

End Sequence

Return lRet
/*
Funcao      : MontaQuery().
Parametros  : Nenhum.
Retorno     : cQry
Objetivos   : Monta a query para Serv. TOP
Autor       : Jo�o Pedro Macimiano Trabbold.
Data/Hora   : 13/09/04; 9:00
*/
#IFDEF TOP
*-----------------------------------*
Static Function Montaquery()
*-----------------------------------*
Local cQry := ""
Begin Sequence
   if !lTPCONExt
      cQry := "Select EEQ_FILIAL, EEQ_DTCE, EEQ_PREEMB, EEQ_VL, EEQ_TX, EEQ_EQVL, "
      //Alcir Alves - 05-12-05 - considera apena tipo 1 - Exporta��o
      //if lTPCONExt
      //    cQry += " EEQ_TP_CON,"
      //endif

      //HVR
      If lEFFTpMod
         cQry += " EEQ_TP_CON,"
      endif

      //Inclus�o do nome do importador para poder ordenar os resultados - Rodrigo - WFS
      cQry += "  (Select A1_NREDUZ From " + RetSqlName("SA1") + " Where A1_COD = EEQ_IMPORT And A1_LOJA = EEQ_IMLOJA And D_E_L_E_T_ <> '*') As NOME_IMP,"

      cQry += " EEQ_BANC, EEQ_RFBC, EEQ_NROP, EEQ_OBS, EEQ_VCT, EEQ_PGT, EEQ_EVENT, EEQ_NRINVO, EEQ_PARC, "
      cQry += " EEQ_ORIGEM, EEC_DTCONH, EEC_CONDPA, EEC_DIASPA, "
      If lTrat
         cQry += " EEQ_IMPORT, EEQ_IMLOJA, EEQ_FORN, EEQ_MOEDA, EEC_IMPORT, EEC_FORN, EEC_MOEDA, "
         cQry += " EEQ_AREMET, EEQ_ADEDUZ, EEQ_CGRAFI "
      Else
         cQry += " EEC_IMPORT, EEQ_IMLOJA, EEC_FORN, EEC_MOEDA "
      EndIf
      cQry += "From " + RetSqlName("EEC") + " EEC, " + RetSqlName("EEQ") + " EEQ "
      cQry += "Where EEQ.D_E_L_E_T_ <> '*' and EEC.D_E_L_E_T_ <> '*' and EEQ_FILIAL = '" + xFilial("EEQ")+"'"
      //Alcir Alves - 05-12-05 - considera apena tipo 1 - Exporta��o e 2 Importa��o
      //if lTPCONExt
      //    cQRY += " and (EEQ_TP_CON='1' or EEQ_TP_CON='2')"
      //endif
      //
      cQry += " and EEC_FILIAL = '" + xFilial("EEC") + "' and EEC_PREEMB = EEQ_PREEMB "
      //WFS 05/11/08 ---
      //Filtro para que o relat�rio considere apenas os processos que n�o estejam na fase de
      //pedido ou vinculados ao cliente (adiantamentos).
      cQry += " and (EEQ_FASE <> 'P' and EEQ_FASE <> 'C')"
      // ---
      if !empty(dDtIni)
         cQry += " and EEQ_VCT >= '" + DtoS(dDtIni) + "'"
      endif
      if !empty(dDtFim)
         cQry += " and EEQ_VCT <= '" + DtoS(dDtFim) + "'"
      endif
      If cLiquida == STR0026     //Liquidados
         cQry += " and EEQ_PGT <> ''"
      ElseIf cLiquida == STR0027
          cQry += " and EEQ_PGT = ''"
      EndIf
      If cPagtoExt == STR0003          //Pagamento no Exterior?
         cQry += " and EEQ_DTCE <> ''"
      ElseIf cPagtoExt == STR0004
          cQry += " and EEQ_DTCE = ''"
      EndIf
      If lTrat
         if !Empty(cMoeda)
            cQry += " and EEQ_MOEDA = '" + cMoeda + "'"
         endif
         if cTitulos == STR0006 .And. !Empty(cFornece) //"A Pagar"
            cQry += " and EEQ_FORN = '" + cFornece  + "'"
         elseif cTitulos == STR0005 .And. !Empty(cImport) //"A Receber"
            cQry += " and EEQ_IMPORT = '" + cImport + "'"
         endif
      Else
         if !Empty(cMoeda)
            cQry += " and EEC_MOEDA = '" + cMoeda + "'"
         endif
         if cTitulos == STR0006 .And. !Empty(cFornece) //"A Pagar"
            cQry += " and EEC_FORN = '" + cFornece  + "'"
         elseif cTitulos == STR0005 .And. !Empty(cImport) //"A Receber"
            cQry += " and EEC_IMPORT = '" + cImport + "'"
         endif
      EndIf

   else //caso EEQ_TP_CON exista
      cQry := "Select EEQ_FILIAL, EEQ_DTCE, EEQ_PREEMB, EEQ_VL, EEQ_TX, EEQ_EQVL,"

      //HVR
      //If lEFFTpMod
         cQry += " EEQ_TP_CON,"
      //endif

      cQry += " EEQ_BANC, EEQ_RFBC, EEQ_NROP, EEQ_OBS, EEQ_VCT, EEQ_PGT, EEQ_EVENT, EEQ_NRINVO, EEQ_PARC "
      If lTrat
         cQry += ",EEQ_IMPORT, EEQ_IMLOJA, EEQ_FORN, EEQ_MOEDA "
         cQry += ",EEQ_AREMET, EEQ_ADEDUZ, EEQ_CGRAFI "
      EndIf

      //Inclus�o do nome do importador para poder ordenar os resultados - Rodrigo - WFS
      cQry += ",  (Select A1_NREDUZ From " + RetSqlName("SA1") + " Where A1_COD = EEQ_IMPORT And A1_LOJA = EEQ_IMLOJA And D_E_L_E_T_ <> '*') As NOME_IMP"

      cQry += ",EEQ_ORIGEM "
      cQry += "From "+ RetSqlName("EEQ") + " EEQ "
      cQry += "Where EEQ.D_E_L_E_T_ <> '*' and EEQ_FILIAL = '" + xFilial("EEQ")+"'"
      if !empty(dDtIni)
         cQry += " and EEQ_VCT >= '" + DtoS(dDtIni) + "'"
      endif
      if !empty(dDtFim)
         cQry += " and EEQ_VCT <= '" + DtoS(dDtFim) + "'"
      endif
      //WFS 05/11/08 ---
      //Inclus�o do filtro, selecionado pelo usu�rio na TelaGets
      If cPagtoExt == STR0003          //Pagamento no Exterior?
         cQry += " and EEQ_DTCE <> ''"
      ElseIf cPagtoExt == STR0004
          cQry += " and EEQ_DTCE = ''"
      EndIf
      //Filtro para que o relat�rio considere apenas os processos que n�o estejam na fase de
      //pedido ou vinculados ao cliente (adiantamentos).
      cQry += " and (EEQ_FASE <> 'P' and EEQ_FASE <> 'C')"
      // ---

      If lTrat
         if !Empty(cMoeda)
            cQry += " and EEQ_MOEDA = '" + cMoeda + "'"
         endif
         if cTitulos == STR0006 .And. !Empty(cFornece) //"A Pagar"
            cQry += " and EEQ_FORN = '" + cFornece  + "'"
         elseif cTitulos == STR0005 .And. !Empty(cImport) //"A Receber"
            cQry += " and EEQ_IMPORT = '" + cImport + "'"
         endif
      EndIf

   endif

   //RMD - WFS 10/10/2008
   If lOrdImp
      cQry += " Order By NOME_IMP,EEQ_PREEMB, EEQ_PARC "
   Else
      cQry += " Order By EEQ_PREEMB, EEQ_PARC "
   EndIf

End Sequence

Return cQry
#ENDIF
/*
Funcao      : FiltrosDBF().
Parametros  : Nenhum.
Retorno     : .T./.F.
Objetivos   : Filtros para ambiente CodeBase
Autor       : Jo�o Pedro Macimiano Trabbold.
Data/Hora   : 26/08/04; 16:50*/


*-----------------------------------*
Static Function FiltrosDBF(cAlias)
*-----------------------------------*
Local lRet := .t.

Begin Sequence

// Testa as condicoes para o filtro pela dt inicial de vencimento de cambio.
if !Empty(dDtIni) .And. (cAlias)->EEQ_VCT < dtos(dDtIni) //BHF - 15/08/08
   (cAlias)->(DbSkip())
   lRet := .f.
EndIf

// Testa as condicoes para o filtro pela dt final de vencimento de cambio.
if !Empty(dDtFim) .And. (cAlias)->EEQ_VCT > dtos(dDtFim) //BHF - 15/08/08
   (cAlias)->(DbSkip())
   lRet := .f.
EndIf

If lTrat
   // Testa as condicoes para o filtro pelo fornecedor.
   If !Empty(cFornece) .And. cTitulos == STR0006 .And. (cAlias)->EEQ_FORN <> cFornece //"A Pagar"
      (cAlias)->(DbSkip())
      lRet := .f.
   EndIf
   // Testa as condicoes para o filtro pelo importador.
   If !Empty(cImport) .And. cTitulos == STR0005 .And. (cAlias)->EEQ_IMPORT <> cImport //"A Receber"
      (cAlias)->(DbSkip())
      lRet := .f.
   EndIf

   // AST - 08/07/08 - Testa as condic��es para o filtro pela Liquida��o
   if cLiquida == STR0026
      if Empty((cAlias)->EEQ_PGT)
         (cAlias)->(DbSkip())
         lRet := .F.
      endif
   elseif cLiquida == STR0027
      if !Empty((cAlias)->EEQ_PGT)
         (cAlias)->(DbSkip())
         lRet := .F.
      endif
   endif

   // Testa as condicoes para o filtro pela moeda.
   If !Empty(cMoeda) .And. (cAlias)->EEQ_MOEDA <> cMoeda
      (cAlias)->(DbSkip())
      lRet := .f.
   EndIf

   // WFS 05/11/08 ---
   //Inclus�o do filtro selecionado pelo usu�rio na TelaGets
   If cPagtoExt == STR0003
      If Empty((cAlias)->EEQ_DTCE)
         (cAlias)->(DbSkip())
         lRet := .F.
      EndIf
   ElseIf cPagtoExt == STR0004
      If !Empty((cAlias)->EEQ_DTCE)
         (cAlias)->(DbSkip())
         lRet := .F.
      EndIf
   EndIf
   // ---

Else
   EEC->(DbSetOrder(1))
   EEC->(DbSeek(xFilial("EEC")+(cAlias)->EEQ_PREEMB))
   // Testa as condicoes para o filtro pelo fornecedor.
   IF !EEC->(EOF())
      If !Empty(cFornece) .And. cTitulos == STR0006 .And. EEC->EEC_FORN <> cFornece //"A Pagar"
         (cAlias)->(DbSkip())
         lRet := .f.
      EndIf

      // Testa as condicoes para o filtro pelo Importador.
      If !Empty(cImport) .And. cTitulos == STR0005 .And. EEC->EEC_IMPORT <> cImport //"A Receber"
         (cAlias)->(DbSkip())
         lRet := .f.
      EndIf
      // Testa as condicoes para o filtro pela moeda.
      If !Empty(cMoeda) .And. EEC->EEC_MOEDA <> cMoeda
         (cAlias)->(DbSkip())
         lRet := .f.
      EndIf

   ELSE
      If !Empty(cFornece) .And. cTitulos == STR0006 .And. EEQ->EEQ_TP_CON <> "4" //"A Pagar"
         (cAlias)->(DbSkip())
         lRet := .f.
      EndIf
      // Testa as condicoes para o filtro pelo Importador.
      If !Empty(cImport) .And. cTitulos == STR0005 .And. EEC->EEC_IMPORT <> "3" //"A Receber"
         (cAlias)->(DbSkip())
         lRet := .f.
      EndIf

      // AST - 08/07/08 - Testa as condic��es para o filtro pela Liquida��o
      if cLiquida == STR0026
         if Empty((cAlias)->EEQ_PGT)
            (cAlias)->(DbSkip())
            lRet := .F.
         endif
      elseif cLiquida == STR0027
         if !Empty((cAlias)->EEQ_PGT)
            (cAlias)->(DbSkip())
            lRet := .F.
         endif
      End If
      //CCH - 03/09/2008 - Testa as condi��es para o filtro por Pagamento no Exterior
      If cPagtoExt == STR0003
         If Empty((cAlias)->EEQ_DTCE)
            (cAlias)->(DbSkip())
            lRet := .F.
         EndIf
      ElseIf cPagtoExt == STR0004
         If !Empty((cAlias)->EEQ_DTCE)
            (cAlias)->(DbSkip())
            lRet := .F.
         EndIf
      EndIf

      // Testa as condicoes para o filtro pela moeda.
      If !Empty(cMoeda) .And. (cAlias)->EEQ_MOEDA <> cMoeda
         (cAlias)->(DbSkip())
         lRet := .f.
      EndIf
   ENDIF

EndIf

End Sequence

Return lRet

/*
Funcao      : CalcCamb().
Parametros  : lFirst : Define se � a primeira chamada da fun��o
Retorno     : .T./.F.
Objetivos   : Fun��o recursiva para c�lculo do valor cambial
Autor       : Jo�o Pedro Macimiano Trabbold.
Data/Hora   : 13/09/04; 16:50
Obs.        : cuidado ao dar manuten��o a esta fun��o, pois esta � recursiva
*/

*-----------------------------------*
Static Function CalcCamb(lFirst)
*-----------------------------------*
local   nRecNo := 0 , cParc := "" , lFound := .t.
Default lFirst := .f.

Begin Sequence
   If lFirst
      EEQ->(DbSetOrder(3))
      nVlCamb := 0
   Endif
   cParc   := EEQ->EEQ_PARC   //poss�vel parcela pai
   cPreemb := EEQ->EEQ_PREEMB

   If EEQ->(DbSeek(xFilial("EEQ")+cPreemb+cParc)) //se achar alguma parcela que tenha como origem a poss�vel parcela pai, ent�o possui parcela filha
      nRecNo := EEQ->(RecNo())
      If lFirst .and. Empty(Posicione("EEQ",1,xFilial("EEQ")+cPreemb+cParc,"EEQ_PGT"))
         nVlCamb := Posicione("EEQ",1,xFilial("EEQ")+cPreemb+cParc,"EEQ_VL")
      Endif
      EEQ->(DbSetOrder(3))
      EEQ->(DbGoto(nRecNo))
      lFound := .t.
      While xFilial("EEQ") == EEQ->EEQ_FILIAL .and. EEQ->EEQ_PREEMB == cPreemb .and. EEQ->EEQ_ORIGEM == cParc
         If Empty(EEQ->EEQ_PGT)             //procura parcelas irm�s da parcela filha
            nVlCamb += EEQ->EEQ_VL
         Endif
         nRecNo  := EEQ->(RecNo())
         CalcCamb()
         EEQ->(DbGoTo(nRecNo))
         EEQ->(DbSkip())
      Enddo
   Else
      lFound := .f.
      If lFirst
         nVlCamb := Posicione("EEQ",1,xFilial("EEQ")+cPreemb+cParc,"EEQ_VL")
      Endif
   Endif
   If !lFound .and. lFirst
      lCalc  := .t.
   Endif
End Sequence
Return nil

/*
Funcao      : GrvWork(cAlias).
Parametros  : cAlias
Retorno     :
Objetivos   : Fun��o para grava��o da tabela DET
Autor       : Wilsimar Fabr�cio da Silva - WFS
Data/Hora   : 13/10/08; 11:00
Obs.        : Desvinculada da fun��o EECPRL20 para tratar a ordena��o por nome do Importador
*/

Static Function GrvWork(cAlias)

Begin Sequence

   //Alcir Alves - 05-12-05 - considera apena tipo 1 - Exporta��o
   //if lTPCONExt
   //   if (cAlias)->EEQ_TP_CON<>"1" .and. (cAlias)->EEQ_TP_CON<>"2"
   //     (cAlias)->(DBSKIP())
   //      loop
   //   EndIF
   //Endif
   //
   EEC->(DbSetOrder(1))//filtros: Receita - importador, despesa - fornecedor(sem os novos tratamentos de frete, seguro, comiss�o)
   EEC->(DBSEEK(xFilial("EEC")+(cAlias)->EEQ_PREEMB))

   If !lTPCONExt .and. EEC->(eof())
      (cAlias)->(DbSkip())
      Break
   EndIf

   If lTPCONExt
      If cTpCon==aTpCon[2] //"1-C�mbio de Exporta��o"
         If (cAlias)->EEQ_TP_CON<>"1"
            Break
         EndIf
      ElseIf cTpCon==aTpCon[3] //"2-C�mbio de Importa��o"
         If (cAlias)->EEQ_TP_CON<>"2"
            (cAlias)->(DbSkip())
            Break
         EndIf
      ElseIf cTpCon==aTpCon[4] //"3-Recebimento"
         If (cAlias)->EEQ_TP_CON<>"3"
            (cAlias)->(DbSkip())
            Break
         EndIf
      ElseIf cTpCon==aTpCon[5] //"4-Remessa"
         If (cAlias)->EEQ_TP_CON<>"4"
            (cAlias)->(DbSkip())
            Break
         EndIf
      EndIf
   EndIf

   If lTrat .OR. EEC->(EOF())
      EC6->(DbSetOrder(1)) //filtros: Receita - importador, despesa - fornecedor
      If EC6->(DbSeek(xFilial("EC6")+"EXPORT"+(cAlias)->EEQ_EVENT))
         If EC6->EC6_RECDES == "1" .AND. (cTitulos == STR0006 .Or. If(!Empty(cImport),(cAlias)->EEQ_IMPORT <> cImport,.f.)) //"A Pagar"
            (cAlias)->(DbSkip())
            Break
         EndIf
         If EC6->EC6_RECDES == "2" .AND. (cTitulos == STR0005 .Or. If(!Empty(cFornece),(cAlias)->EEQ_FORN <> cFornece,.f.)) //"A Receber"
            (cAlias)->(DbSkip())
            Break
         EndIf
      EndIf
   Else
      EC6->(DbSetOrder(1))
      If EC6->(DbSeek(xFilial("EC6")+"EXPORT"+(cAlias)->EEQ_EVENT))
         If EC6->EC6_RECDES == "1" .AND. (cTitulos == STR0006 .Or. If(!Empty(cImport),EEC->EEC_IMPORT <> cImport,.f.)) //"A Pagar"
            (cAlias)->(DbSkip())
            Break
         EndIf
         If EC6->EC6_RECDES == "2" .AND. (cTitulos == STR0005 .Or. If(!Empty(cFornece),EEC->EEC_FORN <> cFornece,.f.)) //"A Receber"
            (cAlias)->(DbSkip())
            Break
         EndIf
      EndIf
   EndIf
         //filtro: Vinculados a financiamento??
   If cFinanc <> STR0002 //"Ambos"

      EF3->(DbSetOrder(3))

      If EF3->(DbSeek(xFilial("EF3")+If(lEFFTpMod, If((cAlias)->EEQ_TP_CON $ ("2/4"),"I","E"),"")+(cAlias)->EEQ_NRINVO+(cAlias)->EEQ_PARC)) //HVR
         If cFinanc == STR0004 //"N�o"
            (cAlias)->(DBSkip())
            Break
         EndIf
      Else
         If cFinanc == STR0003 //"Sim"
            (cAlias)->(DBSkip())
            Break
         EndIf
      EndIf
   EndIf

   //WFS 05/11/08 ---
   //Filtro para que o relat�rio considere apenas os processos que n�o estejam na fase de
   //pedido ou vinculados ao cliente (adiantamentos).
   If cAlias == "EEQ"
      If (cAlias)->EEQ_FASE == "P" .Or. (cAlias)->EEQ_FASE == "C"
         (cAlias)->(DBSkip())
         Break
      EndIf
   EndIf

   // ---
   //Alcir Alves - 05-12-05 - por causa dos novos tipos de cambio TP_CON 1,2,3 e 4 ser� necess�rio for�ar
   //a valida��o manual para top e codebase
   If !FiltrosDBF(cAlias)  // filtros para ambiente codebase
      Break
   EndIf

         /*
         #IfDEF TOP
            If TCSRVTYPE() = "AS/400"
               If !FiltrosDBF()  // filtros para ambiente codebase
                  loop
               EndIf
            EndIf
         #Else
            If !FiltrosDBF()  // filtros para ambiente codebase
               loop
            EndIf
         #EndIf
         */
   cProcAtual := (cAlias)->EEQ_PREEMB

   //Grava��o dos detalhes
   DET->(DbAppEnd())
   If lTPCONExt //HVR
      If !empty((cAlias)->EEQ_TP_CON)
         If val((cAlias)->EEQ_TP_CON)<=(len(aTpCon)-1)
            DET->TP_CON:=aTpCon[(val((cAlias)->EEQ_TP_CON)+1)]
         Else
            DET->TP_CON:="-"
         EndIf
      Else
         DET->TP_CON:="-"
      EndIf
   Else
      DET->TP_CON:="-"
   EndIf
   lFlag := !lFlag

   If(lFlag, DET->FLAG := "X", DET->FLAG := "Y") //zebrado do relat�rio

   DET->SEQREL     := cSEQREL
   DET->EEQ_PREEMB := (cAlias)->EEQ_PREEMB
   SA6->(DbSetOrder(1))
   SA6->(DbSeek(xFilial("SA6")+(cAlias)->EEQ_BANC))
   DET->A6_NREDUZ  := SA6->A6_NREDUZ  //nome reduzido do banco
   DET->EEQ_RFBC   := LOWER((cAlias)->EEQ_RFBC) //refer�ncia banc�ria

   If Empty((cAlias)->EEQ_ORIGEM)  //c�lculo do valor cambial - in�cio
      If cAlias == "EEQ"
         nRec := (cAlias)->(RecNo())
      Else
         EEQ->(DbGoTop())
         EEQ->(DbSetOrder(1))
         EEQ->(DbSeek(xFilial("EEQ")+(cAlias)->EEQ_PREEMB+(cAlias)->EEQ_PARC))
      EndIf
      CalcCamb(.t.)

      If(cAlias == "EEQ",(cAlias)->(DbGoTo(nRec)),)
   EndIf

   If Empty((cAlias)->EEQ_PGT)  //n�o pago
      DET->SALDO   := Alltrim(TRANSFORM((cAlias)->EEQ_VL,  AVSX3("EEQ_VL",  AV_PICTURE)))
      If lCalc
         DET->EEQ_VLCAMB := Alltrim(TRANSFORM((cAlias)->EEQ_VL, AVSX3("EEQ_VL",  AV_PICTURE)))
      Else
         DET->EEQ_VLCAMB := Alltrim(TRANSFORM(nVlCamb, AVSX3("EEQ_VL",  AV_PICTURE)))
      EndIf
   Else      //pago
      DET->SALDO := "0"
      DET->EEQ_VLCAMB := Alltrim(TRANSFORM((cAlias)->EEQ_VL, AVSX3("EEQ_VL",  AV_PICTURE)))
   EndIf  //c�lculo do valor cambial - fim

   EEQ->(DbSetOrder(1))
   lCalc := .f.

   #IfDEF TOP
      If TCSRVTYPE() <> "AS/400"
         dVencto  := AVCTOD(SUBSTR((cAlias)->EEQ_VCT,7,2)+"/"+SUBSTR((cAlias)->EEQ_VCT,5,2)+"/"+SUBSTR((cAlias)->EEQ_VCT,3,2))
      Else
         dVencto  := (cAlias)->EEQ_VCT
      EndIf
   #Else
      dVencto :=  (cAlias)->EEQ_VCT
   #EndIf

   If dDatabase > dVencto .and. Empty((cAlias)->EEQ_PGT) // c�lculo dos dias de atraso
      DET->DIASATRASO := AllTrim(Str(dDatabase - dVencto))+ If(dDatabase - dVencto <> 1,STR0013,STR0014) //" dias"," dia"
   Else
      DET->DIASATRASO := "-"
   EndIf

   EEC->(DbSetOrder(1))
   EEC->(DbSeek(xFilial("EEC")+(cAlias)->EEQ_PREEMB))

   //c�lculo do valor da comiss�o
   If !EEC->(EOF())
      If lTrat //com tratamentos de frete, seguro e comiss�o, h� uma comiss�o pra cada parcela
         nValcom := (cAlias)->EEQ_AREMET + (cAlias)->EEQ_ADEDUZ + (cAlias)->EEQ_CGRAFI
         DET->EEQ_VLCOMS := Alltrim(Transform(nValcom,AVSX3("EEC_VALCOM",AV_PICTURE)))
      Else  //sem tratamentos de frete, de seguro e comiss�o
         If cProcAtual <> cProcPast //a cada mudanca de PREEMB, h� o c�lculo da comiss�o
            If lTratCom
               DET->EEQ_VLCOMS := Alltrim(Transform(EEC->EEC_VALCOM,AVSX3("EEC_VALCOM",AV_PICTURE)))
            Else
               nValFOB := (EEC->EEC_TOTPED+EEC->EEC_DESCON)-(EEC->EEC_FRPREV+EEC->EEC_FRPCOM+EEC->EEC_SEGPRE+EEC->EEC_DESPIN+AvGetCpo("EEC->EEC_DESP1")+AvGetCpo("EEC->EEC_DESP2"))
               nValCom := (If(EEC->EEC_TIPCVL=="1",(EEC->EEC_VALCOM*nValFOB)/100,EEC->EEC_VALCOM))
               DET->EEQ_VLCOMS := Alltrim(Transform(nValcom,AVSX3("EEC_VALCOM",AV_PICTURE)))
            EndIf
         EndIf
      EndIf
      DET->EEC_CONDPA  :=  EEC->EEC_CONDPA  //condi��o de pagamento
      DET->EEC_DIASPA  :=  ALLTRIM(STR(EEC->EEC_DIASPA)) //dias da condi��o de pagamento
    Else
      DET->EEQ_VLCOMS := Alltrim(Transform(0,AVSX3("EEC_VALCOM",AV_PICTURE)))
      DET->EEC_CONDPA  :=  "-"
      DET->EEC_DIASPA  :=  "-"
   EndIf

   #IFDEF TOP
      If TCSRVTYPE() = "AS/400"
         If EEC->(EOF()) .OR. Empty(EEC->EEC_DTCONH)          //datas
            DET->EEC_DTCONH  := "-"
         Else
            DET->EEC_DTCONH  := TRANSFORM(DTOC(EEC->EEC_DTCONH) ,AVSX3("EEC_DTCONH" ,AV_PICTURE))
         EndIf

         If Empty(EEQ->EEQ_DTCE)
            DET->EEQ_DTCE  := "-"
         Else
            DET->EEQ_DTCE := TRANSFORM(DTOC((cAlias)->EEQ_DTCE),AVSX3("EEQ_DTCE",AV_PICTURE))
         EndIf

         If Empty(EEQ->EEQ_VCT)
            DET->EEQ_VCT  := "-"
         Else
            DET->EEQ_VCT  := TRANSFORM(DTOC((cAlias)->EEQ_VCT) ,AVSX3("EEQ_VCT" ,AV_PICTURE))
         EndIf
      Else
         If EEC->(EOF()) .OR. Empty(EEC->EEC_DTCONH)
            DET->EEC_DTCONH  := "-"
         Else
            DET->EEC_DTCONH:= TRANSFORM(DTOC(EEC->EEC_DTCONH) ,AVSX3("EEC_DTCONH" ,AV_PICTURE))
         EndIf

         If Empty((cAlias)->EEQ_DTCE)
            DET->EEQ_DTCE  := "-"
         Else
            DET->EEQ_DTCE := SUBSTR((cAlias)->EEQ_DTCE,7,2)+"/"+SUBSTR((cAlias)->EEQ_DTCE,5,2)+"/"+SUBSTR((cAlias)->EEQ_DTCE,3,2)
         EndIf

         If Empty((cAlias)->EEQ_VCT)
            DET->EEQ_VCT  := "-"
         Else
            DET->EEQ_VCT  := SUBSTR((cAlias)->EEQ_VCT,7,2)+"/"+SUBSTR((cAlias)->EEQ_VCT,5,2)+"/"+SUBSTR((cAlias)->EEQ_VCT,3,2)
         EndIf

      EndIf

   #ELSE

      If EEC->(EOF()) .OR. EEC->(EOF())
         DET->EEC_DTCONH  := "-"
      Else
         DET->EEC_DTCONH  := TRANSFORM(DTOC(EEC->EEC_DTCONH) ,AVSX3("EEC_DTCONH" ,AV_PICTURE))
      EndIf

      If Empty(EEQ->EEQ_DTCE)
         DET->EEQ_DTCE  := "-"
      Else
         DET->EEQ_DTCE := TRANSFORM(DTOC((cAlias)->EEQ_DTCE),AVSX3("EEQ_DTCE",AV_PICTURE))
      EndIf

      If Empty(EEQ->EEQ_VCT)
         DET->EEQ_VCT  := "-"
       Else
         DET->EEQ_VCT  := TRANSFORM(DTOC((cAlias)->EEQ_VCT) ,AVSX3("EEQ_VCT" ,AV_PICTURE))
      EndIf

   #ENDIF

   EEC->(DbSetOrder(1))
   EEC->(DbSeek(xFilial("EEC")+(cAlias)->EEQ_PREEMB))

   If lTrat .or. EEC->(EOF())
      DET->EEQ_MOEDA  := (cAlias)->EEQ_MOEDA
      SA1->(DbSetOrder(1))

      If SA1->(DbSeek(xFilial("SA1")+(cAlias)->(EEQ_IMPORT+EEQ_IMLOJA)))
         DET->EEQ_IMPORT := SA1->A1_NREDUZ
      EndIf

      SA2->(DbSetOrder(1))

      If SA2->(DbSeek(xFilial("SA2")+(cAlias)->EEQ_FORN))
         DET->EEQ_FORN   := SA2->A2_NREDUZ
      EndIf
   Else
      DET->EEQ_MOEDA  := EEC->EEC_MOEDA

      SA1->(DbSetOrder(1))
      SA1->(DbSeek(xFilial("SA1")+EEC->EEC_IMPORT))
      DET->EEQ_IMPORT := SA1->A1_NREDUZ
      SA2->(DbSetOrder(1))
      SA2->(DbSeek(xFilial("SA2")+EEC->EEC_FORN))
      DET->EEQ_FORN   := SA2->A2_NREDUZ
   EndIf

   // impress�o dos contratos de financiamento para cada parcela
   EF3->(DbSetOrder(3))
   If EF3->(DbSeek(xFilial("EF3")+If(lEFFTpMod, If((cAlias)->EEQ_TP_CON $ ("2/4"),"I","E"),"")+(cAlias)->EEQ_NRINVO+(cAlias)->EEQ_PARC+"600")) //HVR
      lAppEnd := .f.

      While !EF3->(EOF()) .And. xFilial("EF3") == EF3->EF3_FILIAL .And. If(lEFFTpMod, If((cAlias)->EEQ_TP_CON $ ("2/4"),"I","E") = EF3->EF3_TPMODU, .T.) .And. (cAlias)->EEQ_PARC == EF3->EF3_PARC .And. (cAlias)->EEQ_NRINVO == EF3->EF3_INVOIC .and. EF3->EF3_CODEVE == "600"
         If lAppEnd
            DET->(DBAppEnd())
            DET->SEQREL   := cSEQREL
            If(lFlag, DET->FLAG := "X", DET->FLAG := "Y")
         EndIf

         DET->EF3_CONTRA := EF3->EF3_CONTRA
         nRecEF3 := EF3->(RecNo())
         nJuros  := 0

         If EF3->(DbSeek(xFilial("EF3")+If(lEFFTpMod, If((cAlias)->EEQ_TP_CON $ ("2/4"),"I","E"),"")+(cAlias)->EEQ_NRINVO+(cAlias)->EEQ_PARC+"520"))//c�lculo dos juros //HVR
            While !EF3->(EOF()) .And. xFilial("EF3") == EF3->EF3_FILIAL .And. If(lEFFTpMod, If((cAlias)->EEQ_TP_CON $ ("2/4"),"I","E") = EF3->EF3_TPMODU, .T.) .And. (cAlias)->EEQ_PARC == EF3->EF3_PARC .And. (cAlias)->EEQ_NRINVO == EF3->EF3_INVOIC .and. EF3->EF3_CODEVE == "520"
               If DET->EF3_CONTRA == EF3->EF3_CONTRA
                  nJuros += EF3->EF3_VL_MOE
               EndIf
               EF3->(DbSkip())
            Enddo
            //DET->VALORJUROS := Transform(nJuros,AvSx3("EF3_VL_MOE",AV_PICTURE))
            DET->VALORJUROS := Alltrim(Transform(nJuros,AvSx3("EF3_VL_MOE",AV_PICTURE)))//JVR - 11/12/09
         Else
            DET->VALORJUROS := "-"
         EndIf

         EF3->(DbGoto(nRecEF3))
         EF3->(DbSkip())
         lAppEnd := .t.
      EndDo
   EndIf
   nJuros := 0
   lProc := .t.
   cProcPast := cProcAtual

End Sequence

Return

/*
Funcao      : ReportDef
Parametros  :
Retorno     :
Objetivos   : Relat�rio Personalizavel TReport
Autor       : Jean Victor Rocha
Data/Hora   : 11/12/2009
Revisao     :
Obs.        :
*/
*-------------------------*
Static Function ReportDef()
*-------------------------*

//Variaveis
Local cDescr := cTitulo := cTitRpt

//Alias que podem ser utilizadas para adicionar campos personalizados no relat�rio
aTabelas := {"DET", "EEC", "EEQ"}

//Array com o titulo e com a chave das ordens disponiveis para escolha do usu�rio
aOrdem   := {}
//
//Par�metros:            Relat�rio , Titulo  ,  Pergunte , C�digo de Bloco do Bot�o OK da tela de impress�o , Descri��o
oReport := TReport():New("EECPRL20", cTitulo ,""         , {|oReport| ReportPrint(oReport)}                 , cDescr    )

//Inicia o relat�rio como paisagem.
oReport:oPage:lLandScape := .T.
oReport:oPage:lPortRait := .F.

//Define os objetos com as se��es do relat�rio
oSecao1 := TRSection():New(oReport,"Se��o 1",{"CAB"},{})
oSecao2 := TRSection():New(oReport,"Se��o 2",aTabelas,aOrdem)

//Defini��o das colunas de impress�o da se��o 1
TRCell():New(oSecao1,"PERIODO"   , "CAB", "Periodo"                 ,            ,     ,           ,       )
TRCell():New(oSecao1,"VINC_FIN"  , "CAB", "Vinc. a Financiamento"   ,            ,     ,           ,       )
TRCell():New(oSecao1,"IMPORTADOR", "CAB", "Importador"              ,            ,     ,           ,       )
TRCell():New(oSecao1,"FORNECEDOR", "CAB", "Fornecedor"              ,            ,     ,           ,       )
TRCell():New(oSecao1,"MOEDA"     , "CAB", "Moeda"                   ,            ,     ,           ,       )

//Defini��o das colunas de impress�o da se��o 2
//           objeto ,cName        ,cAlias,cTitle              ,cPicture             ,nSize,lPixel     ,bBlock ,cAlign  ,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize,nClrBack,nClrFore,lBold
TRCell():New(oSecao2,"EEQ_PREEMB" , "DET", "Processo"         ,                     ,     ,           ,       ,"LEFT"  ,          ,            ,          ,         , .T.     ,        ,        ,     )
TRCell():New(oSecao2,"EEQ_IMPORT" , "DET", "Importador"       ,                     ,     ,           ,       ,"LEFT"  ,          ,            ,          ,         , .T.     ,        ,        ,     )
TRCell():New(oSecao2,"EEQ_MOEDA"  , "DET", "Moeda"            ,                     ,     ,           ,       ,"LEFT"  ,          ,            ,          ,         , .T.     ,        ,        ,     )
TRCell():New(oSecao2,"A6_NREDUZ"  , "DET", "Banco"            ,                     ,     ,           ,       ,"LEFT"  ,          ,            ,          ,         , .T.     ,        ,        ,     )
TRCell():New(oSecao2,"EEQ_RFBC"   , "DET", "Ref.Bancaria"     ,                     , 010 ,           ,       ,"LEFT"  ,          ,            ,          ,         , .T.     ,        ,        ,     )
TRCell():New(oSecao2,"EEQ_VLCAMB" , "DET", "Val.Cambial"      ,                     , 014 ,           ,       ,"RIGHT" ,          ,"RIGHT"     ,          ,         , .T.     ,        ,        ,     )
TRCell():New(oSecao2,"EEC_DTCONH" , "DET", "Dt. B/L"          ,                     ,     ,           ,       ,"CENTER",          ,            ,          ,         , .T.     ,        ,        ,     )
TRCell():New(oSecao2,"EEQ_VCT"    , "DET", "Vencto."          ,                     ,     ,           ,       ,"CENTER",          ,            ,          ,         , .T.     ,        ,        ,     )
TRCell():New(oSecao2,"SALDO"      , "DET", "Saldo"            ,                     , 014 ,           ,       ,"RIGHT" ,          ,"RIGHT"     ,          ,         , .T.     ,        ,        ,     )
TRCell():New(oSecao2,"EEQ_DTCE"   , "DET", "Pg.Ext."          ,                     ,     ,           ,       ,"CENTER",          ,            ,          ,         , .T.     ,        ,        ,     )
TRCell():New(oSecao2,"DIASATRASO" , "DET", "Atraso"           ,                     ,     ,           ,       ,"CENTER",          ,            ,          ,         , .T.     ,        ,        ,     )
TRCell():New(oSecao2,"EEQ_FORN"   , "DET", "Exportador"       ,                     ,     ,           ,       ,"LEFT"  ,          ,            ,          ,         , .T.     ,        ,        ,     )
TRCell():New(oSecao2,"EEC_CONDPA" , "DET", "Cond.Pag."        ,                     ,     ,           ,       ,"LEFT"  ,          ,            ,          ,         , .T.     ,        ,        ,     )
TRCell():New(oSecao2,"EEC_DIASPA" , "DET", "Dias"             ,                     ,     ,           ,       ,"CENTER",          ,            ,          ,         , .T.     ,        ,        ,     )
TRCell():New(oSecao2,"EF3_CONTRA" , "DET", "Nr.Contr.ACC/ACE" ,                     ,     ,           ,       ,"RIGHT" ,          ,            ,          ,         , .T.     ,        ,        ,     )
TRCell():New(oSecao2,"VALORJUROS" , "DET", "Val. Juros"       ,                     ,     ,           ,       ,"RIGHT" ,          ,"RIGHT"     ,          ,         , .T.     ,        ,        ,     )
TRCell():New(oSecao2,"TP_CON"     , "DET", "Tp. Contr."       ,                     ,     ,           ,       ,"LEFT"  ,          ,            ,          ,         , .T.     ,        ,        ,     )

oReport:bOnPageBreak :={||oReport:Section("Se��o 1"):PrintLine()}
oSecao1:SkipLine(2)

Return oReport


*----------------------------------*
Static Function ReportPrint(oReport)
*----------------------------------*

//Faz o posicionamento de outros alias para utiliza��o pelo usu�rio na adi��o de novas colunas.
TRPosition():New(oReport:Section("Se��o 2"),"EEC", 1,{|| xFilial("EEC") + DET->EEQ_PREEMB })
TRPosition():New(oReport:Section("Se��o 2"),"EEQ", 1,{|| xFilial("EEQ") + EEC->EEC_PREEMB })

//Inicio da impress�o da se��o 1.
oReport:Section("Se��o 1"):Init()

//Inicio da impress�o da se��o 2.
oReport:Section("Se��o 2"):Init()

oReport:SetMeter(DET->(EasyRecCount()))
DET->(dbGoTop())

FilePrint:=E_Create(,.F.)
IndRegua("DET",FilePrint+TEOrdBagExt(),"EEQ_PREEMB")

//La�o principal
Do While DET->(!EoF()) .And. !oReport:Cancel()
   oReport:Section("Se��o 2"):PrintLine() //Impress�o da linha
   oReport:IncMeter()                     //Incrementa a barra de progresso
   DET->( dbSkip() )
EndDo

//Fim da impress�o da se��o 1
oReport:Section("Se��o 1"):Finish()
//Fim da impress�o da se��o 2
oReport:Section("Se��o 2"):Finish()

FERASE(FilePrint+TEOrdBagExt())

Return .T.

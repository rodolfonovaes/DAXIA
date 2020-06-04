//Revis�o - Alcir Alves - 05-12-05 - desconsiderar dados do EEC  quando o cambio n�o possuir embarque
//Revis�o - Alcir Alves - 06-12-05 - inclus�o do filtro e campo para TP_CON 
//Revis�o - Henrique Raineire - 19/06/06 - Nova estrutura de tabelas do SIGAEFF - FINIMP
#INCLUDE "EECRDM.CH"      
#INCLUDE "EECPRL21.ch"              

/*
Programa  : EECPRL21_RDM.
Objetivo  : Relat�rio de Contratos de Cambio no Periodo
Autor     : Jo�o Pedro Macimiano Trabbold
Data/Hora : 20/08/04; 10:38 
Obs       : 
*/
/*
Funcao      : EECPRL21().
Parametros  : Nenhum.
Retorno     : .f.
Objetivos   : Impress�o do Relat�rio de Contratos de Cambio no Periodo
Autor       : Jo�o Pedro Macimiano Trabbold.
Data/Hora   : 20/08/04; 10:38 
*/
*-----------------------*
User Function EECPRL21()
*-----------------------*
Local   aOrd   := SaveOrd({"EEC","EEQ","EF1","EF3","SA6","SA1"})     
Local   nInd := 0

Private lRet   := .t. , lApaga := .f.
//Alcir Alves - 05-12-05
Private lTPCONExt:=(EEQ->(fieldpos("EEQ_TP_CON"))>0)
Private oCbTpCon,cTpCon 
Private aTpCon:={"*Todos","1-Exportacao","2-Importacao","3-Recebimento","4-Remessa"}
//
Private cArqRpt:="rel21.rpt",;
		  cTitRpt:= STR0001 //"Contratos de Cambio no Per�odo"  
Private aArqs,;
        cNomDbfC := "REL21C",;
        aCamposC := {{"SEQREL"     ,"C",08,0 },;
                     {"FILIAL"     ,"C",2,0 },;
                     {"PERIODOLIQ" ,"C",25,0 },; 
                     {"PERIODOABE" ,"C",25,0 },;
                     {"IMPORTADOR" ,"C",AvSx3("A1_NOME"  ,AV_TAMANHO),0 },;   
                     {"FORNECEDOR" ,"C",AvSx3("A2_NOME"  ,AV_TAMANHO),0 },;
                     {"MOEDA"      ,"C",5 ,0 },;
                     {"TITULOS"    ,"C",12,0 },;
                     {"CONSIDACC"  ,"C",5 ,0 }}
                                    
//JVR - 10/12/09 - Relat�rio Personalizavel
Private oReport
Private lRelPersonal := FindFunction("TRepInUse") .And. TRepInUse()                     
Private cTypeCpo := If(!lRelPersonal,"C","N")
                     
Private cNomDbfD := "REL21D",;
        aCamposD := ;
{{"SEQREL"     ,"C", 8,0},;
{"EEQ_PGT"    ,"C",AvSx3("EEQ_PGT"      ,AV_TAMANHO),0 },;   
{"EEQ_DTCE"   ,"C",AvSx3("EEQ_DTCE"     ,AV_TAMANHO),0 },;   
{"EEQ_PREEMB" ,"C",AvSx3("EEQ_PREEMB"   ,AV_TAMANHO),0 },;   
{"EEQ_MOEDA"  ,"C",AvSx3("EEC_MOEDA"    ,AV_TAMANHO),0 },;
{"EEQ_VL"     ,cTypeCpo,AvSx3("EEQ_VL"  ,AV_TAMANHO)+If(lRelPersonal,0,AvSx3("EEQ_VL"  ,AV_DECIMAL)),If(!lRelPersonal,0,AvSx3("EEQ_VL"  ,AV_DECIMAL)) },;
{"EEQ_TX"     ,cTypeCpo,AvSx3("EEQ_TX"  ,AV_TAMANHO)+If(lRelPersonal,0,AvSx3("EEQ_TX"  ,AV_DECIMAL)),If(!lRelPersonal,0,AvSx3("EEQ_TX"  ,AV_DECIMAL)) },;
{"EEQ_EQVL"   ,cTypeCpo,AvSx3("EEQ_EQVL",AV_TAMANHO)+If(lRelPersonal,0,AvSx3("EEQ_EQVL",AV_DECIMAL)),If(!lRelPersonal,0,AvSx3("EEQ_EQVL",AV_DECIMAL)) },;
{"EEQ_BANC"   ,"C",AvSx3("A6_NREDUZ"    ,AV_TAMANHO),0 },;
{"EEQ_IMPORT" ,"C",AvSx3("A1_NREDUZ"    ,AV_TAMANHO),0 },;
{"CONTRATO"   ,"C",AvSx3("EEQ_NROP"     ,AV_TAMANHO),0 },;
{"PRAZO"      ,"C",40,0 },; 
{"SOMA"       ,"C",AvSx3("EEQ_VL"       ,AV_TAMANHO)+7,0 },;
{"TP_CON","C",18,0 },;
{"FLAG2"      ,"C",1 ,0 },;
{"FLAG"       ,"C",1 ,0 }}
                                          
Private dDtIniLiq  := AVCTOD("  /  /  ")
Private dDtFimLiq  := AVCTOD("  /  /  ")         
Private dDtIniAb   := AVCTOD("  /  /  ")
Private dDtFimAb   := AVCTOD("  /  /  ")  
Private cImport    := Space(AVSX3("A1_COD"   ,AV_TAMANHO)) 
Private cFornece   := Space(AVSX3("A2_COD"   ,AV_TAMANHO))   
Private cForn      := ""
Private cImp       := ""
Private cMoeda     := Space(AVSX3("EEQ_MOEDA",AV_TAMANHO))  
Private lProc      := .f.
Private aConsidACC := {STR0002,STR0003,STR0004} //{"Ambos","Sim","N�o"}
Private cConsidACC := ""  
Private aTitulos   := {STR0006,STR0005} //{"A Receber","A Pagar"}
Private cTitulos   := ""     
Private cAlias     := ""
Private lTrat      := .t.    
Private aMoeda:={}, nPos   
Private lFlag := .f. 
//HVR - Novos campos do FinImp
Private lEFFTpMod := EF1->( FieldPos("EF1_TPMODU") ) > 0 .AND. EF1->( FieldPos("EF1_SEQCNT") ) > 0 .AND.;
                     EF2->( FieldPos("EF2_TPMODU") ) > 0 .AND. EF2->( FieldPos("EF2_SEQCNT") ) > 0 .AND.;
                     EF3->( FieldPos("EF3_TPMODU") ) > 0 .AND. EF3->( FieldPos("EF3_SEQCNT") ) > 0 .AND.;
                     EF4->( FieldPos("EF4_TPMODU") ) > 0 .AND. EF4->( FieldPos("EF4_SEQCNT") ) > 0 .AND.;
                     EF6->( FieldPos("EF6_SEQCNT") ) > 0 .AND. EF3->( FieldPos("EF3_ORIGEM") ) > 0 .and.;
                     EF3->( FieldPos("EF3_ROF"   ) ) > 0

BEGIN SEQUENCE
   lTrat := EECFlags("FRESEGCOM")  // vari�vel que verifica os novos tratamentos de frete, seguro e comiss�o 
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
   CAP->filial := cfilant
   
   //testa o filtro de data de vencimento do cambio que aparecer� no cabe�alho do relat�rio
   if empty(dDtIniAb)
      if !empty(dDtFimAb)//somente Data final preenchida
         CAP->PERIODOABE := STR0007 + DTOC(dDtFimAb) //"At�"        
      else //nenhuma data preenchida       
         CAP->PERIODOABE := STR0008 //"todos"
      endif
   else                                                         	
      if !empty(dDtFimAb)
         if dDtIniAb == dDtFimAb //DtIni e DtFim iguais
            CAP->PERIODOABE := DTOC(dDtFimAb)
         else   //DtIni e DtFim <>
            CAP->PERIODOABE := STR0009 + DTOC(dDtIniAb) + STR0010 + DTOC(dDtFimAb) //"De "      " a " 
         endif
      else //somente data inicial preenchida
         CAP->PERIODOABE := STR0011 + DTOC(dDtIniAb) //"Ap�s "
      endif
   endif
   
   //testa o filtro de data de Liquida��o do cambio que aparecer� no cabe�alho do relat�rio
   if empty(dDtIniLiq)
      if !empty(dDtFimLiq)//somente Data final preenchida
         CAP->PERIODOLIQ := STR0007 + DTOC(dDtFimLiq) //"At� "
      else   //nenhuma data preenchida     
         CAP->PERIODOLIQ := STR0008 //"Todos" 
      endif
   else                                                         	
      if !empty(dDtFimLiq)
         if dDtIniLiq == dDtFimLiq//DtIni e DtFim iguais
            CAP->PERIODOLIQ := DTOC(dDtFimLiq)
         else //DtIni e DtFim <>
            CAP->PERIODOLIQ := STR0009 + DTOC(dDtIniLiq) + STR0010 + DTOC(dDtFimLiq) //"De "      " a "
         endif
      else //somente data inicial preenchida
         CAP->PERIODOLIQ := STR0011 + DTOC(dDtIniLiq) //"Ap�s "
      endif
   endif     
    
   //testa o filtro de importador que aparecer� no cabe�alho do relat�rio
   if !empty(cImport)  
      SA1->(DBSetorder(1))
      SA1->(DBSEEK(xFilial("SA1")+cImport))
      CAP->IMPORTADOR := SA1->A1_NOME 
   else
      CAP->IMPORTADOR := STR0008 //"Todos"
   endif
   
   //testa o filtro de fornecedor que aparecer� no cabe�alho do relat�rio
   if !empty(cFornece)  
      SA2->(DBSetOrder(1))
      SA2->(DBSEEK(xFilial("SA2")+cFornece))
      CAP->FORNECEDOR := SA2->A2_NOME 
   else
      CAP->FORNECEDOR := STR0008 //"Todos"
   endif                 
   
   If !Empty(cMoeda)
      CAP->MOEDA := cMoeda
   else
      CAP->MOEDA := STR0012 //"Todas"  
   endif    
   
   //filtro de contratos de ACC que aparecer� no cabe�alho do relat�rio
   CAP->CONSIDACC := cConsidACC
     
   CAP->TITULOS := " - " + cTitulos
   
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
   
   While (cAlias)->(!EOF()) .AND. xFilial("EEQ") == (cAlias)->EEQ_FILIAL
      //Alcir Alves - 05-12-05 - considera apena tipo 1 - Exporta��o
      //if lTPCONExt
      //   if (cAlias)->EEQ_TP_CON<>"1" .and. (cAlias)->EEQ_TP_CON<>"2" 
      //      (cAlias)->(DBSKIP())
      //      loop
      //  ENDIF
      //endif
      //
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
      EEC->(DbSetOrder(1))//filtros: Receita - importador, despesa - fornecedor(sem os novos tratamentos de frete, seguro, comiss�o)
      EEC->(DBSEEK(xFilial("EEC")+EEQ->EEQ_PREEMB))
         If lTrat .or. EEC->(EOF())
            EC6->(DbSetOrder(1)) //filtros: Receita - importador, despesa - fornecedor
            if EC6->(DbSeek(xFilial("EC6")+"EXPORT"+(cAlias)->EEQ_EVENT))
               if EC6->EC6_RECDES == "1" .AND. (cTitulos == STR0005 .Or. If(!Empty(cImport),(cAlias)->EEQ_IMPORT <> cImport,.f.))//"A pagar"
                  (cAlias)->(DbSkip())
                  Loop 
               endif
               if EC6->EC6_RECDES == "2" .AND. (cTitulos == STR0006 .Or. If(!Empty(cFornece),(cAlias)->EEQ_FORN <> cFornece,.f.))//"A Receber"
                  (cAlias)->(DbSkip())
                  Loop     
               endif
            endif   
         Else
            EC6->(DbSetOrder(1))
            if EC6->(DbSeek(xFilial("EC6")+"EXPORT"+(cAlias)->EEQ_EVENT))
               if EC6->EC6_RECDES == "1" .AND. (cTitulos == STR0005 .Or. If(!Empty(cImport),EEC->EEC_IMPORT <> cImport,.f.))//"A pagar"
                  (cAlias)->(DbSkip())
                  Loop 
               endif
               if EC6->EC6_RECDES == "2" .AND. (cTitulos == STR0006 .Or. If(!Empty(cFornece),EEC->EEC_FORN <> cFornece,.f.))//"A Receber"
                  (cAlias)->(DbSkip())
                  Loop     
               endif
            endif
         EndIf     
      if cConsidACC <> STR0002   //"Ambos"  //filtro: Considera ACC ou n�o
         EF3->(DbSetOrder(3))
         if EF3->(DbSeek(xFilial("EF3")+IF(lEFFTpMod, IF((cAlias)->EEQ_TP_CON $ ("2/4"),"I","E"),"")+(cAlias)->EEQ_NRINVO+(cAlias)->EEQ_PARC))
            if cConsidACC == STR0004 //"N�o" 
               (cAlias)->(DBSkip())
               loop
            endif
         else
            if cConsidACC == STR0003 //"Sim" 
               (cAlias)->(DBSkip())
               loop
            endif 
         endif
      endif
      //for�a sempre o filtro manual
      If !FiltrosDBF()  // filtros para ambiente codebase
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
      //Grava��o dos detalhes 
      lFlag := !lFlag  //zebrado do relat�rio     
      DET->(DbAppend()) 
      DET->SEQREL     := cSEQREL
      if lTPCONExt      
         if !empty((cAlias)->EEQ_TP_CON)
           if val((cAlias)->EEQ_TP_CON)<=(len(aTpCon)-1)
              DET->TP_CON:=aTpCon[(val((cAlias)->EEQ_TP_CON)+1)]
            else
              DET->TP_CON:="-"
            endif
         else
            DET->TP_CON:="-"
         endif
      else
        DET->TP_CON:=aTpCon[2]      
      endif
      
      If(lFlag, DET->FLAG2 := "X", DET->FLAG2 := "Y") //zebrado do relat�rio   
      DET->FLAG       := "A" // Diferencia��o entre o relat�rio principal e o Sub-Relat�rio
      #IFDEF TOP
         If TCSRVTYPE() = "AS/400"						 
            If Empty(EEQ->EEQ_PGT)
               DET->EEQ_PGT  := "-"
            Else
               DET->EEQ_PGT  := TRANSFORM(DTOC((cAlias)->EEQ_PGT) ,AVSX3("EEQ_PGT" ,AV_PICTURE))  
            EndIf
            If Empty(EEQ->EEQ_DTCE)
               DET->EEQ_DTCE  := "-"
            Else   
               DET->EEQ_DTCE := TRANSFORM(DTOC((cAlias)->EEQ_DTCE),AVSX3("EEQ_DTCE",AV_PICTURE))
            EndIf
         Else 
            if Empty((cAlias)->EEQ_PGT)
               DET->EEQ_PGT  := "-"
            else
               DET->EEQ_PGT  := SUBSTR((cAlias)->EEQ_PGT,7,2)+"/"+SUBSTR((cAlias)->EEQ_PGT,5,2)+"/"+SUBSTR((cAlias)->EEQ_PGT,3,2)
            endif
            if Empty((cAlias)->EEQ_DTCE)
               DET->EEQ_DTCE  := "-"
            else
               DET->EEQ_DTCE := SUBSTR((cAlias)->EEQ_DTCE,7,2)+"/"+SUBSTR((cAlias)->EEQ_DTCE,5,2)+"/"+SUBSTR((cAlias)->EEQ_DTCE,3,2)
            endif
         endif
      #ELSE
         If Empty(EEQ->EEQ_PGT)
            DET->EEQ_PGT  := "-"
         Else
            DET->EEQ_PGT  := TRANSFORM(DTOC((cAlias)->EEQ_PGT) ,AVSX3("EEQ_PGT" ,AV_PICTURE))  
         EndIf
         If Empty(EEQ->EEQ_DTCE)
            DET->EEQ_DTCE  := "-"
         Else   
            DET->EEQ_DTCE := TRANSFORM(DTOC((cAlias)->EEQ_DTCE),AVSX3("EEQ_DTCE",AV_PICTURE))
         EndIf    
      #ENDIF
      DET->EEQ_PREEMB := (cAlias)->EEQ_PREEMB
      If !lRelPersonal
         DET->EEQ_VL     := TRANSFORM((cAlias)->EEQ_VL,  AVSX3("EEQ_VL",  AV_PICTURE))
         DET->EEQ_TX     := If(!Empty((cAlias)->EEQ_TX),TRANSFORM((cAlias)->EEQ_TX,  AVSX3("EEQ_TX",  AV_PICTURE)),"-")
         DET->EEQ_EQVL   := If(!Empty((cAlias)->EEQ_EQVL),TRANSFORM((cAlias)->EEQ_EQVL,AVSX3("EEQ_EQVL",AV_PICTURE)),"-")
      Else 
         DET->EEQ_VL     := (cAlias)->EEQ_VL
         DET->EEQ_TX     := If(!Empty((cAlias)->EEQ_TX),(cAlias)->EEQ_TX,0)
         DET->EEQ_EQVL   := If(!Empty((cAlias)->EEQ_EQVL),(cAlias)->EEQ_EQVL,0)      
      EndIf
       
      If !Empty((cAlias)->EEQ_BANC)
         SA6->(DbSetOrder(1))
         If SA6->(DbSeek(xFilial("SA6")+(cAlias)->EEQ_BANC)) .And. !Empty(SA6->A6_NREDUZ)
            DET->EEQ_BANC := SA6->A6_NREDUZ  
         Else
            DET->EEQ_BANC := SUBSTR(SUBSTR(SA6->A6_NOME,1,at(" ",SA6->A6_NOME)-1),1,15) 
         Endif
      Else
         DET->EEQ_BANC := "-"
      EndIf
      
      EEC->(DbSetOrder(1))
      EEC->(DbSeek(xFilial("EEC")+(cAlias)->EEQ_PREEMB))
      If lTrat .or. EEC->(EOF())                       
         //Constru��o do array para mostrar os totais por moeda
         nPos := aScan(aMoeda,{|x| x[1] == (cAlias)->EEQ_MOEDA}) //procura a moeda no array      
         If nPos = 0    //se n�o achar, adiciona a moeda e o valor                                         
            AADD(aMoeda,{(cAlias)->EEQ_MOEDA,(cAlias)->EEQ_VL})         
         Else          //se achar, acrescenta ao valor
            aMoeda[nPos][2] +=(cAlias)->EEQ_VL
         EndIf

         DET->EEQ_MOEDA  := (cAlias)->EEQ_MOEDA   
      
         EC6->(DbSetOrder(1))
         if EC6->(DbSeek(xFilial("EC6")+"EXPORT"+(cAlias)->EEQ_EVENT))
            if EC6->EC6_RECDES == "1"
               SA1->(DbGoTop())
               SA1->(DbSetOrder(1))
               If SA1->(DbSeek(xFilial("SA1")+(cAlias)->EEQ_IMPORT))
                  DET->EEQ_IMPORT := SA1->A1_NREDUZ
               Else
                  DET->EEQ_IMPORT := (cAlias)->EEQ_IMPORT    
               EndIf   
            endif
            if EC6->EC6_RECDES == "2" 
               SA2->(DbGoTop())
               SA2->(DbSetOrder(1))
               If SA2->(DbSeek(xFilial("SA2")+(cAlias)->EEQ_FORN))
                  DET->EEQ_IMPORT := SA2->A2_NREDUZ
               Else
                  DET->EEQ_IMPORT := (cAlias)->EEQ_FORN    
               EndIf
            endif
         endif 
      Else
         //Constru��o do array para mostrar os totais por moeda
         nPos := aScan(aMoeda,{|x| x[1] == EEC->EEC_MOEDA}) //Procura a moeda no array
         If nPos = 0    // se n�o achar, adiciona a moeda e o valor
            AADD(aMoeda,{EEC->EEC_MOEDA,(cAlias)->EEQ_VL})         
         Else       // se achar, acrescenta o valor
            aMoeda[nPos][2] +=(cAlias)->EEQ_VL
         EndIf
                  
         DET->EEQ_MOEDA  := EEC->EEC_MOEDA   
           
         EC6->(DbSetOrder(1))
         if EC6->(DbSeek(xFilial("EC6")+"EXPORT"+(cAlias)->EEQ_EVENT))
            if EC6->EC6_RECDES == "1"
               SA1->(DbGoTop())
               SA1->(DbSetOrder(1))
               If SA1->(DbSeek(xFilial("SA1")+EEC->EEC_IMPORT))
                  DET->EEQ_IMPORT := SA1->A1_NREDUZ
               Else
                  DET->EEQ_IMPORT := EEC->EEC_IMPORT    
               EndIf   
            endif
            if EC6->EC6_RECDES == "2" 
               SA2->(DbGoTop())
               SA2->(DbSetOrder(1))
               If SA2->(DbSeek(xFilial("SA2")+EEC->EEC_FORN))
                  DET->EEQ_IMPORT := SA2->A2_NREDUZ
               Else
                  DET->EEQ_IMPORT := EEC->EEC_FORN    
               EndIf
            endif
         endif   
      Endif  
      
      // Impress�o dos contratos de ACC(se houver) e suas respectivas datas de vencimento para cada parcela   
      EF3->(DbSetOrder(3))
         
      if EF3->(DbSeek(xFilial("EF3")+IF(lEFFTpMod, IF((cAlias)->EEQ_TP_CON $ ("2/4"),"I","E"),"")+(cAlias)->EEQ_NRINVO+(cAlias)->EEQ_PARC+"600")) //HVR
         DET->CONTRATO := EF3->EF3_CONTRA
         DET->PRAZO    := TRANSFORM(DTOC(Posicione("EF1",1,xFilial("EF1")+IF(lEFFTpMod, EF3->EF3_TPMODU,"")+EF3->EF3_CONTRA,"EF1_DT_VEN")),AVSX3("EF1_DT_VEN",AV_PICTURE)) //HVR
         EF3->(DbSkip())
         While !EF3->(EOF()) .And. xFilial("EF3") == EF3->EF3_FILIAL .And. IF(lEFFTpMod, IF((cAlias)->EEQ_TP_CON $ ("2/4"),"I","E") = EF3->EF3_TPMODU, .T.) .And. (cAlias)->EEQ_PARC == EF3->EF3_PARC .And. (cAlias)->EEQ_NRINVO == EF3->EF3_INVOIC .and. EF3->EF3_CODEVE == "600"  //HVR
               DET->(DBAppend())
               DET->SEQREL   := cSEQREL
               If(lFlag, DET->FLAG2 := "X", DET->FLAG2 := "Y") 
               DET->CONTRATO := EF3->EF3_CONTRA
               DET->PRAZO    := TRANSFORM(DTOC(Posicione("EF1",1,xFilial("EF1")+IF(lEFFTpMod, EF3->EF3_TPMODU,"")+EF3->EF3_CONTRA,"EF1_DT_VEN")),AVSX3("EF1_DT_VEN",AV_PICTURE))  //HVR
               EF3->(DbSkip())
         EndDo 
      Else //se n�o houver contrato de ACC, grava o n�mero da opera��o
         DET->CONTRATO := (cAlias)->EEQ_NROP
         DET->PRAZO    := lower((cAlias)->EEQ_OBS)
      EndIf 
        																										
      lProc := .t.
      (cAlias)->(DBSkip())
   Enddo    
   
   if lProc = .f. 
      msginfo(STR0013,STR0014) //msginfo("Intervalo sem dados para impress�o.","Aviso!")
      lRet :=.f.
      break
   ELSE
      //JVR - 04/12/09 - Relat�rio Personalizavel
      If lRelPersonal
         oReport := ReportDef()
      EndIf
   endif
   
   //JVR - 10/12/09 - so faz totalizador por moeda se n�o for ralatorio personalizado
   If !lRelPersonal
      //Grava��o do sub-relat�rio de totais por moeda
      For nInd:=1 to Len(aMoeda)
         DET->(DbAppend())
         DET->SEQREL    := cSeqRel
         DET->FLAG      := "B"
         DET->EEQ_MOEDA := aMoeda[nInd][1]
         DET->EEQ_VL    := TRANSFORM(aMoeda[nInd][2],AVSX3("EEQ_VL",AV_PICTURE))
      next  
   EndIf
   
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

   If select("QRY") > 0
      QRY->(DbCloseArea()) 
   endif
   RestOrd(aOrd)
   
Return (.f.) 

/*
Funcao      : TelaGets().
Parametros  : Nenhum.
Retorno     : .t./.f.
Objetivos   : Tela com op��es de filtros para os contratos.
Autor       : Jo�o Pedro Macimiano Trabbold.
Data/Hora   : 20/08/04; 10:50
*/
*-----------------------------------*
Static Function TelaGets()
*-----------------------------------*
Local lRet  := .f.
Local nOpc  := 0   	
Local bOk, bCancel
Local nLinFin, nColFin, nAdic
Private oCbxTit, oGetForn, oGetImp, oForn, oImp, oGetLoja, cLoja

Begin Sequence

   If SetMdiChild()
      nLinFin:= 31.2
      nColFin:= 49
      nAdic  := 45
   Else
      nLinFin:= 31.01
      nColFin:= 38
      nAdic  := 0
   EndIf

   //DEFINE MSDIALOG oDlg TITLE cTitRpt FROM 9,0 TO 28.01,34 OF oMainWnd nopado por WFS em 05/02/10
   DEFINE MSDIALOG oDlg TITLE cTitRpt FROM 9,0 TO nLinFin, nColFin OF oMainWnd       

      @ 42,8  SAY STR0015 PIXEL //"Liquidados :"
      @ 40,38 MSGET dDtIniLiq SIZE 40,8 PIXEL   
      
      @ 42,78 SAY STR0007 PIXEL 
      @ 40,88 MSGET dDtFimLiq SIZE 40,8 PIXEL  

      @ 54,8  SAY STR0016 PIXEL //"Em Aberto :"                                              	
      @ 52,38 MSGET dDtIniAb  SIZE 40,8 PIXEL
      
      @ 54,78 SAY STR0007 PIXEL 
      @ 52,88 MSGET dDtFimAb SIZE 40,8 PIXEL  

      @ 66,8  SAY STR0017 PIXEL //"T�tulos :"
      //TComboBox():New(65,60,bSETGET(cTitulos),aTitulos,40,8,oDlg,,,,,,.T.)      
      @ 64,38 COMBOBOX oCbxTit VAR cTitulos ITEMS aTitulos  SIZE 40,8 ON CHANGE (fChange()) OF oDlg PIXEL  
            
      @ 78,8  SAY STR0018 PIXEL //"Fornecedor:"
      @ 76,38 MSGET oGetForn VAR cFornece F3 "YA2" Valid (Empty(cFornece) .or. ExistCPO("SA2")) SIZE 40,8 ON CHANGE (TrazDesc("FORN")) OF oDlg PIXEL  
      
      @ 90,8  SAY STR0019 PIXEL //"Descri��o :"    
      @ 88,38 MSGET oForn VAR cForn SIZE 90,8 OF oDlg PIXEL   
      oForn:Disable() 
      cForn:=Space(20) 
           
      @ 102,8  SAY STR0020 PIXEL //"Importador :" 
      @ 100,38 MSGET oGetImp VAR cImport F3 "EA1" Valid (Empty(cImport) .or. ExistCPO("SA1")) SIZE 40,8 ON CHANGE (TrazDesc("IMP")) OF oDlg PIXEL   
      
      @ 114,8  SAY STR0019 PIXEL //"Descri��o :"  
      @ 112,38 MSGET oImp VAR cImp SIZE 90,8 OF oDlg PIXEL 
      oImp:Disable()
      cImp:=Space(20) 
      
      @ 126,8  SAY STR0021 PIXEL //"Cons. ACC?" 
      TComboBox():New(124,38,bSETGET(cConsidACC),aConsidACC,40,8,oDlg,,,,,,.T.)  
       
      @ 138,8  SAY STR0022 PIXEL //"Moeda:"
      @ 136,38 MSGET cMoeda PICTURE "@!" F3 "SYF" Valid (Empty(cMoeda) .or. ExistCPO("SYF")) SIZE 40,8 OF oDlg PIXEL 
      
      if lTPCONExt      
          @ 150,8  SAY AVSX3("EEQ_TP_CON",5) PIXEL //"Tipo de contrato "
          @ 148,38 COMBOBOX oCbTpCon VAR cTpCon ITEMS aTpCon SIZE 65,8 OF oDlg PIXEL  
      else
          cTpCon:=aTpCon[2]
      endif

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
Funcao      : MontaQuery().
Parametros  : Nenhum.
Retorno     : cQry
Objetivos   : Monta a query para Serv. TOP
Autor       : Jo�o Pedro Macimiano Trabbold.
Data/Hora   : 23/08/04; 16:54
*/ 
#IFDEF TOP
*-----------------------------------*
Static Function Montaquery()
*-----------------------------------*
Local cQry := ""
Begin Sequence   
   if !lTPCONExt
      //Contratos Liquidados
      cQry := "Select EEQ_FILIAL, EEQ_PGT, EEQ_DTCE, EEQ_PREEMB, EEQ_VL, EEQ_TX, EEQ_EQVL, " 
      cQry += " EEQ_BANC, EEQ_NROP, EEQ_OBS, EEQ_VCT, EEQ_EVENT, EEQ_NRINVO, EEQ_PARC, "
      //HVR
      If lEFFTpMod
         cQry += " EEQ_TP_CON,"
      endif
      
      If lTrat 
         cQry += " EEQ_IMPORT, EEQ_FORN, EEQ_MOEDA "
      Else
         cQry += " EEC_IMPORT, EEC_FORN, EEC_MOEDA "
      EndIf  
     
      cQry += "From " + RetSqlName("EEC") + " EEC, " + RetSqlName("EEQ") + " EEQ "
      cQry += "Where EEQ.D_E_L_E_T_ <> '*' and EEC.D_E_L_E_T_ <> '*' and EEQ_FILIAL = '" + xFilial("EEQ") 
      cQry += "' and EEC_FILIAL = '" + xFilial("EEC") + "' and EEC_PREEMB = EEQ_PREEMB "
      cQry += " and EEQ_PGT <> '        ' "   

      //Alcir Alves - 05-12-05 - considera apena tipo 1 - Exporta��o e 2 Importa��o
      //if lTPCONExt
      //    cQRY += " and (EEQ_TP_CON='1' or EEQ_TP_CON='2')"
      //endif
      //

      if !empty(dDtIniLiq)
         cQry += " and EEQ_PGT >= '" + DtoS(dDtIniLiq) + "'"
      endif          

      if !empty(dDtFimLiq)
         cQry += " and EEQ_PGT <= '" + DtoS(dDtFimLiq) + "'"
      endif      
      If lTrat
         if !Empty(cMoeda) 
            cQry += " and EEQ_MOEDA = '" + cMoeda + "'"	    
         endif
         if cTitulos == STR0005 .And. !Empty(cFornece) //"A Pagar"
            cQry += " and EEQ_FORN = '" + cFornece  + "'"  
         elseif cTitulos == STR0006 .And. !Empty(cImport) //"A Receber"    
            cQry += " and EEQ_IMPORT = '" + cImport + "'" 
         endif  
      Else
         if !Empty(cMoeda) 
            cQry += " and EEC_MOEDA = '" + cMoeda + "'"	    
         endif
         if cTitulos == STR0005 .And. !Empty(cFornece)  //"A Pagar"
            cQry += " and EEC_FORN = '" + cFornece  + "'"   
         elseif cTitulos == STR0006 .And. !Empty(cImport) //"A Receber"   
            cQry += " and EEC_IMPORT = '" + cImport + "'"
         endif  
      EndIf       
      cQry += " UNION "   
      //Contratos Em Aberto
      cQry += "Select EEQ_FILIAL, EEQ_PGT, EEQ_DTCE, EEQ_PREEMB, EEQ_VL, EEQ_TX, EEQ_EQVL, "
      cQry += " EEQ_BANC, EEQ_NROP, EEQ_OBS, EEQ_VCT, EEQ_EVENT, EEQ_NRINVO, EEQ_PARC, "
      //HVR
      If lEFFTpMod
         cQry += " EEQ_TP_CON,"
      endif

      If lTrat 
         cQry += " EEQ_IMPORT, EEQ_FORN, EEQ_MOEDA "
      Else
         cQry += " EEC_IMPORT, EEC_FORN, EEC_MOEDA "
      EndIf  
      cQry += "From " + RetSqlName("EEC") + " EEC, " + RetSqlName("EEQ") + " EEQ "
      cQry += "Where EEQ.D_E_L_E_T_ <> '*' and EEC.D_E_L_E_T_ <> '*' and EEQ_FILIAL = '" + xFilial("EEQ")
      cQry += "' and EEC_FILIAL = '" + xFilial("EEC") + "' and EEC_PREEMB = EEQ_PREEMB "
      cQry += " and EEQ_PGT = '        ' " 
      //Alcir Alves - 05-12-05 - considera apena tipo 1 - Exporta��o e 2 Importa��o
      //if lTPCONExt
      //    cQry += " and (EEQ_TP_CON='1' or EEQ_TP_CON='2')"
      //endif
      //
      if !empty(dDtIniAb)
         cQry += " and EEQ_VCT >= '" + DtoS(dDtIniAb) + "'"
      endif          
      if !empty(dDtFimAb)
         cQry += " and EEQ_VCT <= '" + DtoS(dDtFimAb) + "'"
      endif      
      If lTrat
         if !Empty(cMoeda) 
            cQry += " and EEQ_MOEDA = '" + cMoeda + "'"	    
         endif
         if cTitulos == STR0005 .And. !Empty(cFornece) //"A Pagar"
            cQry += " and EEQ_FORN = '" + cFornece  + "'"  
         elseif cTitulos == STR0006 .And. !Empty(cImport) //"A Receber"
            cQry += " and EEQ_IMPORT = '" + cImport + "'" 
         endif  
      Else
         if !Empty(cMoeda) 
            cQry += " and EEC_MOEDA = '" + cMoeda + "'"	    
         endif
         if cTitulos == STR0005 .And. !Empty(cFornece) //"A Pagar"
            cQry += " and EEC_FORN = '" + cFornece  + "'"   
         elseif cTitulos == STR0006 .And. !Empty(cImport)//"A Receber"    
            cQry += " and EEC_IMPORT = '" + cImport + "'"
         endif  
      EndIf         
   else //caso exista o campo TP_CON
      //Contratos Liquidados
      cQry := "Select EEQ_FILIAL, EEQ_PGT, EEQ_DTCE, EEQ_PREEMB, EEQ_VL, EEQ_TX, EEQ_EQVL, " 
      cQry += " EEQ_BANC, EEQ_NROP, EEQ_OBS, EEQ_VCT, EEQ_EVENT, EEQ_NRINVO, EEQ_PARC"
      //HVR
      //IF lEFFTpMod
         cQry += ",EEQ_TP_CON "
      //ENDIF

      If lTrat 
         cQry += ",EEQ_IMPORT, EEQ_FORN, EEQ_MOEDA "
      EndIf  
     
      cQry += "From " + RetSqlName("EEQ") + " EEQ "
      cQry += "Where EEQ.D_E_L_E_T_ <> '*' and EEQ_FILIAL = '" + xFilial("EEQ") +"'"
      cQry += " and EEQ_PGT <> '        ' "   

      //Alcir Alves - 05-12-05 - considera apena tipo 1 - Exporta��o e 2 Importa��o
      //if lTPCONExt
      //    cQRY += " and (EEQ_TP_CON='1' or EEQ_TP_CON='2')"
      //endif
      //

      if !empty(dDtIniLiq)
         cQry += " and EEQ_PGT >= '" + DtoS(dDtIniLiq) + "'"
      endif          

      if !empty(dDtFimLiq)
         cQry += " and EEQ_PGT <= '" + DtoS(dDtFimLiq) + "'"
      endif      
      If lTrat
         if !Empty(cMoeda) 
            cQry += " and EEQ_MOEDA = '" + cMoeda + "'"	    
         endif
         if cTitulos == STR0005 .And. !Empty(cFornece) //"A Pagar"
            cQry += " and EEQ_FORN = '" + cFornece  + "'"  
         elseif cTitulos == STR0006 .And. !Empty(cImport) //"A Receber"    
            cQry += " and EEQ_IMPORT = '" + cImport + "'" 
         endif  
      EndIf       
      cQry += " UNION "   
      //Contratos Em Aberto
      cQry += "Select EEQ_FILIAL, EEQ_PGT, EEQ_DTCE, EEQ_PREEMB, EEQ_VL, EEQ_TX, EEQ_EQVL, " 
      cQry += " EEQ_BANC, EEQ_NROP, EEQ_OBS, EEQ_VCT, EEQ_EVENT, EEQ_NRINVO, EEQ_PARC"

      //HVR
      //IF lEFFTpMod
         cQry += ",EEQ_TP_CON "
      //ENDIF

      If lTrat 
         cQry += ",EEQ_IMPORT, EEQ_FORN, EEQ_MOEDA "
      EndIf  
      cQry += "From "+ RetSqlName("EEQ") + " EEQ "
      cQry += "Where EEQ.D_E_L_E_T_ <> '*' and EEQ_FILIAL = '" + xFilial("EEQ")+"'"
      cQry += " and EEQ_PGT = '        ' " 
      //Alcir Alves - 05-12-05 - considera apena tipo 1 - Exporta��o e 2 Importa��o
      //if lTPCONExt
      //    cQry += " and (EEQ_TP_CON='1' or EEQ_TP_CON='2')"
      //endif
      //
      if !empty(dDtIniAb)
         cQry += " and EEQ_VCT >= '" + DtoS(dDtIniAb) + "'"
      endif          
      if !empty(dDtFimAb)
         cQry += " and EEQ_VCT <= '" + DtoS(dDtFimAb) + "'"
      endif      
      If lTrat
         if !Empty(cMoeda) 
            cQry += " and EEQ_MOEDA = '" + cMoeda + "'"	    
         endif
         if cTitulos == STR0005 .And. !Empty(cFornece) //"A Pagar"
            cQry += " and EEQ_FORN = '" + cFornece  + "'"  
         elseif cTitulos == STR0006 .And. !Empty(cImport) //"A Receber"
            cQry += " and EEQ_IMPORT = '" + cImport + "'" 
         endif  
      EndIf            
   endif
   cQry += " Order By EEQ_PREEMB, EEQ_PARC "     


End Sequence

Return cQry  
#ENDIF
/*
Funcao      : fChange().
Parametros  : Nenhum.
Retorno     : .t./.f.
Objetivos   : Enable/Disable dos campos de Fornecedor e Importador, de acordo com o tipo de titulo(A Receber ou a Pagar)
Autor       : Jo�o Pedro Macimiano Trabbold.
Data/Hora   : 23/08/04; 13:20
*/ 

*------------------------*
Static Function fChange()
*------------------------*  

Begin Sequence 
 
   if cTitulos == STR0005 //"A Pagar" 
      oGetForn:Enable() 
      cFornece:= Space(AVSX3("A2_COD",AV_TAMANHO))  
      cForn:= Space(90)    
      oGetImp:Disable() 
      cImport:= "" 
      cImp:= "" 
      oGetImp:Refresh()   
      oImp:Refresh()          
   endif
   
   if cTitulos == STR0006 //"A Receber" 
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
Parametros  : Nenhum.
Retorno     : .t./.f.
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
Data/Hora   : 20/08/04; 13:27
*/
*-----------------------------------*
Static Function ConfereDt()
*-----------------------------------*
Local lRet := .f.

Begin Sequence      
   
   if !empty(dDtIniLiq) .And. !empty(dDtFimLiq) .And. dDtIniLiq > dDtFimLiq 
      MsgInfo(STR0023,STR0014) //MsgInfo("Data Final(Liquidados) n�o pode ser menor que a inicial.","Aviso!")
      Break
   Else
      lRet := .t.
   Endif   
   if !empty(dDtIniAb) .And. !empty(dDtFimAb) .And. dDtIniAb > dDtFimAb 
      MsgInfo(STR0024,STR0014)//MsgInfo("Data Final(Em Aberto) n�o pode ser menor que a inicial.","Aviso!")  
      lRet:=.f.
      Break
   Else
      lRet := .t.
   Endif   
   
        
End Sequence
      
Return lRet  

/*
Funcao      : FiltrosDBF().
Parametros  : Nenhum.
Retorno     : .T./.F.
Objetivos   : Filtros para ambiente CodeBase
Autor       : Jo�o Pedro Macimiano Trabbold.
Data/Hora   : 26/08/04; 16:50
*/

*-----------------------------------*
Static Function FiltrosDBF()
*-----------------------------------*
Local lRet := .t.

Begin Sequence   
if Empty(EEQ->EEQ_PGT)
   // Testa as condicoes para o filtro pela dt inicial de vencimento de cambio.
   if !Empty(dDtIniAb) .And. EEQ->EEQ_VCT < dDtIniAb        
      EEQ->(DbSkip())
      lRet := .f.  
   EndIf
   
   // Testa as condicoes para o filtro pela dt final de vencimento de cambio.
   if !Empty(dDtFimAb) .And. EEQ->EEQ_VCT > dDtFimAb        
      EEQ->(DbSkip())
      lRet := .f. 
   EndIf  
else
   // Testa as condicoes para o filtro pela dt inicial de Liquida��o do cambio.
   if !Empty(dDtIniLiq) .And. !Empty(EEQ->EEQ_PGT) .And. EEQ->EEQ_PGT < dDtIniLiq        
      EEQ->(DbSkip())
      lRet := .f. 
   EndIf
     
   // Testa as condicoes para o filtro pela dt final de Liquida��o do cambio.
   if !Empty(dDtFimLiq) .And. !Empty(EEQ->EEQ_PGT) .And. EEQ->EEQ_PGT > dDtFimLiq        
      EEQ->(DbSkip())
      lRet := .f. 
   EndIf   
       
endif      

EEC->(DbSetOrder(1))
EEC->(DbSeek(xFilial("EEC")+EEQ->EEQ_PREEMB))
If lTrat .or. EEC->(EOF())    
   // Testa as condicoes para o filtro pelo fornecedor.        
   If !Empty(cFornece) .And. cTitulos == STR0005 .And. EEQ->EEQ_FORN <> cFornece //"A Pagar"
      EEQ->(DbSkip())
      lRet := .f. 
   EndIf 
   // Testa as condicoes para o filtro pelo importador. 
   If !Empty(cImport) .And. cTitulos == STR0006 .And. EEQ->EEQ_IMPORT <> cImport //"A Receber"
      EEQ->(DbSkip())
      lRet := .f. 
   EndIf      
     
   // Testa as condicoes para o filtro pela moeda.       
   If !Empty(cMoeda) .And. EEQ->EEQ_MOEDA <> cMoeda
      EEQ->(DbSkip())
      lRet := .f. 
   EndIf    
   
Else
   // Testa as condicoes para o filtro pelo fornecedor.                
   If !Empty(cFornece) .And. cTitulos == STR0005 .And. EEC->EEC_FORN <> cFornece //"A Pagar"
      EEQ->(DbSkip())
      lRet := .f. 
   EndIf 
      
   // Testa as condicoes para o filtro pelo Importador.       
   If !Empty(cImport) .And. cTitulos == STR0006 .And. EEC->EEC_IMPORT <> cImport //"A Receber"
      EEQ->(DbSkip())
      lRet := .f. 
   EndIf                                                            
      
   // Testa as condicoes para o filtro pela moeda.       
   If !Empty(cMoeda) .And. EEC->EEC_MOEDA <> cMoeda
      EEQ->(DbSkip())
      lRet := .f. 
   EndIf   
EndIf    
           
End Sequence
      
Return lRet


/*
Funcao      : ReportDef
Parametros  : 
Retorno     : 
Objetivos   : Relat�rio Personalizavel TReport
Autor       : Jean Victor Rocha
Data/Hora   : 10/12/2009
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
oReport := TReport():New("EECPRL21", cTitulo ,""         , {|oReport| ReportPrint(oReport)}                 , cDescr    )

//Inicia o relat�rio como paisagem.
oReport:oPage:lLandScape := .T.
oReport:oPage:lPortRait := .F.
  
//Define os objetos com as se��es do relat�rio
oSecao1 := TRSection():New(oReport,"Se��o 1",{"CAP"},{})
oSecao2 := TRSection():New(oReport,"Se��o 2",aTabelas,aOrdem)

//Defini��o das colunas de impress�o da se��o 1  
TRCell():New(oSecao1,"PERIODOLIQ" , "CAP", "Periodo Liquidado" ,            ,     ,           ,       )
TRCell():New(oSecao1,"PERIODOABE" , "CAP", "Periodo Aberto"    ,            ,     ,           ,       )
TRCell():New(oSecao1,"IMPORTADOR" , "CAP", "importador"        ,            ,     ,           ,       )
TRCell():New(oSecao1,"FORNECEDOR" , "CAP", "Fornecedor"        ,            ,     ,           ,       )
TRCell():New(oSecao1,"CONSIDACC"  , "CAP", "Consid. ACC"       ,            ,     ,           ,       )
TRCell():New(oSecao1,"MOEDA"      , "CAP", "Moeda"             ,            ,     ,           ,       )

//Defini��o das colunas de impress�o da se��o 2
//           objeto ,cName       ,cAlias,cTitle          ,cPicture             ,nSize                         ,lPixel     ,bBlock ,cAlign ,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize,nClrBack,nClrFore,lBold
TRCell():New(oSecao2,"EEQ_PGT"   , "DET", "Dt Fechamento",                     ,                              ,           ,       ,"LEFT" ,          ,            ,          ,         , .T.     ,        ,        ,     )
TRCell():New(oSecao2,"EEQ_DTCE"  , "DET", "Dt Cre."      ,                     ,                              ,           ,       ,"LEFT" ,          ,            ,          ,         , .T.     ,        ,        ,     )
TRCell():New(oSecao2,"EEQ_PREEMB", "DET", "Processo"     ,                     ,AVSX3("EEQ_PREEMB",AV_TAMANHO),           ,       ,"LEFT" ,          ,            ,          ,         , .T.     ,        ,        ,     )
TRCell():New(oSecao2,"EEQ_MOEDA" , "DET", "Moeda"        ,                     ,                              ,           ,       ,"LEFT" ,          ,            ,          ,         , .T.     ,        ,        ,     )
TRCell():New(oSecao2,"EEQ_VL"    , "DET", "Valor"        ,                     ,AVSX3("EEQ_VL",AV_TAMANHO)    ,           ,       ,"RIGHT",          ,"RIGHT"     ,          ,         , .T.     ,        ,        ,     )
TRCell():New(oSecao2,"EEQ_TX"    , "DET", "Taxa"         ,                     ,AVSX3("EEQ_TX",AV_TAMANHO)    ,           ,       ,"RIGHT",          ,"RIGHT"     ,          ,         , .T.     ,        ,        ,     )
TRCell():New(oSecao2,"EEQ_EQVL"  , "DET", "Valor R$"     ,                     ,AVSX3("EEQ_EQVL",AV_TAMANHO)  ,           ,       ,"RIGHT",          ,"RIGHT"     ,          ,         , .T.     ,        ,        ,     )
TRCell():New(oSecao2,"EEQ_BANC"  , "DET", "Banco"        ,                     ,                              ,           ,       ,"LEFT" ,          ,            ,          ,         , .T.     ,        ,        ,     )
TRCell():New(oSecao2,"EEQ_IMPORT", "DET", "Cliente"      ,                     ,                              ,           ,       ,"LEFT" ,          ,            ,          ,         , .T.     ,        ,        ,     )
TRCell():New(oSecao2,"CONTRATO"  , "DET", "Contrato"     ,                     ,                              ,           ,       ,"LEFT" ,          ,            ,          ,         , .T.     ,        ,        ,     )
TRCell():New(oSecao2,"PRAZO"     , "DET", "Prazo"        ,                     ,                              ,           ,       ,"LEFT" ,          ,            ,          ,         , .T.     ,        ,        ,     )
TRCell():New(oSecao2,"TP_CON"    , "DET", "Tp.Contrato"  ,                     ,                              ,           ,       ,"LEFT" ,          ,            ,          ,         , .T.     ,        ,        ,     )


oSecao2:SkipLine(2)
oTotal:=TRFunction():New(oSecao2:Cell("EEQ_VL"),NIL,"SUM",/*oBreak*/, , ,{|| DET->EEQ_VL },.T.,.F.) 
oSecao2:SetTotalText("Total geral por Moeda: ")

oReport:bOnPageBreak :={||oReport:Section("Se��o 1"):PrintLine()} 
oSecao1:SkipLine(2)

Return oReport


*----------------------------------*
Static Function ReportPrint(oReport)
*----------------------------------*

//Faz o posicionamento de outros alias para utiliza��o pelo usu�rio na adi��o de novas colunas.
TRPosition():New(oReport:Section("Se��o 2"),"EEC", 1,{|| xFilial("EEC") + DET->EEQ_PREEMB  })
TRPosition():New(oReport:Section("Se��o 2"),"EEQ", 1,{|| xFilial("EEQ") + EEC->EEC_PREEMB})
 
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


#Include "EECRDM.CH" 

/*
Programa    : EECPRL22.
Objetivos   : Impress�o do Relat�rio de Rela��o de Despesas Nacionais
Autor       : Eduardo C. Romanini
Data/Hora   : 19/09/2007 11:10.
Revisao     :
Obs.        : Para impress�o do relat�rio, o sistema utiliza o arquivo Rel25.RPT;
*/

/*
Funcao          : EECPRL25.
Parametros      : Nenhum.
Retorno         : .T./.F.
Objetivos       : Impress�o Relat�rio de Rela��o de Despesas Nacionais
Autor           : Eduardo C. Romanini
Data/Hora       : 19/09/2007 11:10.
Revisao         :
Obs.            :
*/
*----------------------*
User Function EECPRL25()
*----------------------*
Local nOldArea := Select()

Local lRet := .T.

Private cArqRpt, cNomDbfC, cNomDbfD
Private aArqs, aCamposC, aCamposD
Private cTitRpt := "Rela��o de despesas nacionais" //FDR 08/12/2016
Private nFase   := 2
Private nAgrup  := 1

Private cProCod := Space(AvSX3("EE7_PEDIDO",AV_TAMANHO))
Private cDesp   := Space(AvSX3("EET_DESPES",AV_TAMANHO))

Private dProDtIni := AVCTOD("  /  /  ")
Private dProDtFim := AVCTOD("  /  /  ")
Private dDespIni  := AVCTOD("  /  /  ")
Private dDespFim  := AVCTOD("  /  /  ")
Private dDesemIni := AVCTOD("  /  /  ")
Private dDesemFim := AVCTOD("  /  /  ")

Private aAdian := {"Sim","N�o","Todos"}
Private cAdian := aAdian[3]

Private aPagoPor := {"Despachante","Exportador","Todos"}
Private cPagoPor := aPagoPor[3]

Private lExisteDados:=.f.

#IFDEF TOP
  Private cWhere
#ELSE
  Private cWork
#ENDIF

Begin Sequence

   //Valida��es iniciais.
   If !EECFlags("FRESEGCOM")
      MsgStop("O relat�rio de Rela��o de Desp. Nacionais n�o poder� ser gerado."+Replic(ENTER,2)+;
              "Detalhes:"+ENTER+;
              "O ambiente n�o possui os tratamentos de Frete, Seguro e Comiss�o"+ENTER+;
              "habilitados","Aten��o")
      lRet := .f.
      Break
   EndIf

   If Select("WorkId") > 0
      cArqRpt := WorkId->EEA_ARQUIV
   EndIf

   cSEQREL :=GetSXENum("SY0","Y0_SEQREL")
   CONFIRMSX8()

   cNomDbfC := "REL25C"

   aCamposC := {{"SEQREL  ","C",008,0},;
                {"AGRUP"   ,"C",050,0},;
                {"PROCESSO","C",020,0},;
                {"DTPROCI" ,"D",008,0},;
                {"DTPROCF" ,"D",008,0},;
                {"TIPODESP","C",003,0},;
                {"DTDESPI" ,"D",008,0},;
                {"DTDESPF" ,"D",008,0},;
                {"DTDESEI" ,"D",008,0},;
                {"DTDESEF" ,"D",008,0},;
                {"ADIAN"   ,"C",005,0},;
                {"PAGOPOR" ,"C",050,0}}

   cNomDbfD := "REL25D"

   aCamposD := {{"SEQREL  ","C", 08,0},;
                {"PROCESSO","C", AvSx3("EET_PEDIDO",AV_TAMANHO),0},;
                {"CODAGE  ","C", AvSx3("EET_CODAGE",AV_TAMANHO),0},;
                {"DESCAGE ","C", AvSx3("Y5_NOME"   ,AV_TAMANHO),0},;
                {"TIPOAG  ","C", AvSx3("EET_TIPOAG",AV_TAMANHO),0},;
                {"DESPES  ","C", AvSx3("EET_DESPES",AV_TAMANHO),0},;
                {"DESPDES ","C", AvSx3("YB_DESCR"  ,AV_TAMANHO),0},;
                {"DESPDT  ","C", 08,0},;
                {"DESPVAL ","C", AvSx3("EET_VALORR",AV_TAMANHO),0},;
                {"ADIAN   ","C", 05,0},;
                {"PAGOPOR ","C", 20,0},;
                {"DESEMDT ","C", 08,0},;
                {"TOTAL   ","N", AvSx3("EET_VALORR",AV_TAMANHO),AvSx3("EET_VALORR",AV_DECIMAL)},;
                {"ADDDESP ","N", AvSx3("EET_VALORR",AV_TAMANHO),AvSx3("EET_VALORR",AV_DECIMAL)},;
                {"COMDESP ","N", AvSx3("EET_VALORR",AV_TAMANHO),AvSx3("EET_VALORR",AV_DECIMAL)},;
                {"DEVDESP ","N", AvSx3("EET_VALORR",AV_TAMANHO),AvSx3("EET_VALORR",AV_DECIMAL)},;
                {"OUTROS  ","N", AvSx3("EET_VALORR",AV_TAMANHO),AvSx3("EET_VALORR",AV_DECIMAL)}}

   aArqs := {}
   aAdd(aArqs,{cNomDbfC,aCamposC,"CAB","SEQREL"})
   aAdd(aArqs,{cNomDbfD,aCamposD,"DET","SEQREL"})
   aRetCrw := CrwNewFile(aARQS)

   If !TelaGets()
      lRet := .f.
      Break
   EndIf

   SelectData() // Seleciona os dados a serem impressos.

   If !lExisteDados
      MsgStop("N�o h� dados que satisfa�am as condi��es.","Aten��o")
      lRet:=.f.
      Break
   EndIf

   #IFDEF TOP
      Processa({|| lRet := Imprimir()})
      Qry->(DbCloseArea())

   #ELSE
      MsAguarde({||lRet := Imprimir()}, "Imprimindo Despesas ...")
      Qry->(E_EraseArq(cWork))
   #ENDIF

End Sequence

If Select("QRY") > 0
   Qry->(DbCloseArea())
EndIf

IF Empty(cTitRpt)
   cTitRpt := "Rela��o de Despesas Nacionais"  //LRS - 27/07/2016
EndIF

If lRet
   lRetC := CrwPreview(aRetCrw,cArqRpt,cTitRpt,cSeqRel)
Else
   CrwCloseFile(aRetCrw,.t.)
EndIf

DbSelectArea(nOldArea)

Return .F.

/*
Funcao      : TelaGets.
Parametros  : Nenhum.
Retorno     : .t./.f.
Objetivos   : Tela para digita��o dos filtros.
Autor       : Eduardo C. Romanini
Data/Hora   : 19/09/07 12:18.
Revisao     :
Obs.        :
*/
*------------------------*
Static Function TelaGets()
*------------------------*
Local lRet:=.F.

Local oDlg
Local oFase
Local oAgrup
Local oProCod
Local oProDtIni
Local oProDtFim
Local oDesp
Local oDespIni
Local oDespFim
Local oDesemIni
Local oDesemFim

Local cF3 := "EEC"
Local bValid :={||Vazio() .or. ExistCpo("EEC",cProCod)}
Local bChange := {||(cProCod:= Space(AvSX3("EE7_PEDIDO",AV_TAMANHO)),oProCod:Refresh(),;
                    IF(nFase == 1,;
                    (oProCod:cF3:= "EE7",oProCod:bValid:={||Vazio() .or. ExistCpo("EE7",cProCod)}),;
                    (oProCod:cF3:= "EEC",oProCod:bValid:={||Vazio() .or. ExistCpo("EEC",cProCod)})))}

Local bOk := {|| If(ValidTela(),(lRet := .T., oDlg:End()),)}
Local bCancel := {|| oDlg:End()}

//Declara��o das Colunas
Local nCol1  := 008
Local nCol2  := nCol1  + 5
Local nCol3  := nCol2  + 25
Local nCol4  := nCol3  + 20
Local nCol5  := nCol4  + 4
Local nCol6  := nCol5  + 5
Local nCol7  := nCol6  + 4
Local nCol8  := nCol7  + 4
Local nCol9  := nCol8  + 5
Local nCol10 := nCol9  + 25
Local nCol11 := nCol10 + 50

//Declara��o das Linhas
Local nLin1  := 010
Local nLin2  := nLin1  + 6
Local nLin3  := nLin2  + 22
Local nLin4  := nLin3  + 4
Local nLin5  := nLin4  + 8
Local nLin6  := nLin5  + 12
Local nLin7  := nLin6  + 12
Local nLin8  := nLin7  + 4
Local nLin9  := nLin8  + 8
Local nLin10 := nLin9  + 12
Local nLin11 := nLin10  + 12
Local nLin12 := nLin11 + 4
Local nLin13 := nLin12 + 8
Local nLin14 := nLin13 + 12
Local nLin15 := nLin14 + 4
Local nLin16 := nLin15 + 8
Local nLin17 := nLin16 + 12

Begin Sequence

   DEFINE MSDIALOG oDlg TITLE "Rela��o de Despesas Nacionais" FROM AVG_CORD(250),AVG_CORD(214) TO AVG_CORD(645),AVG_CORD(530) PIXEL

      oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165) //LRS - 27/07/2016
      oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

      //@ AVG_CORD(017),AVG_CORD(004) TO AVG_CORD(225),AVG_CORD(182) LABEL "Filtros" PIXEL OF oDlg
      AvBorda(oDlg)

      //Seleciona a Fase para Impress�o
      @ AVG_CORD(nLin1),AVG_CORD(nCol1) TO AVG_CORD(nLin3),AVG_CORD(nCol7) LABEL "Fase" PIXEL OF oPanel
      @ AVG_CORD(nLin2),AVG_CORD(nCol2) Radio oFase Var nFase Items "Pedido","Embarque" 3D On Change Eval(bChange) Size AVG_CORD(049),AVG_CORD(008) PIXEL OF oPanel

      //Seleciona o Agrupamento para Impress�o
      @ AVG_CORD(nLin1),AVG_CORD(nCol8) TO AVG_CORD(nLin3),AVG_CORD(nCol11) LABEL "Agrupamento" PIXEL OF oPanel
      @ AVG_CORD(nLin2),AVG_CORD(nCol9) Radio oAgrup Var nAgrup Items "Processo","Empresa" 3D Size AVG_CORD(049),AVG_CORD(008) PIXEL OF oPanel

      //Dados do Processo
      @ AVG_CORD(nLin4),AVG_CORD(nCol1) TO AVG_CORD(nLin7),AVG_CORD(nCol11) LABEL "Processo" PIXEL OF oPanel

      @ AVG_CORD(nLin5),AVG_CORD(nCol2) Say "C�digo :" Size AVG_CORD(021),AVG_CORD(008) PIXEL OF oPanel
      @ AVG_CORD(nLin5-1),AVG_CORD(nCol3) MsGet oProCod Var cProCod F3 cF3 Valid Eval(bValid) Size AVG_CORD(098),AVG_CORD(008) PIXEL OF oPanel

      @ AVG_CORD(nLin6),AVG_CORD(nCol2) Say "Data Inicial" Size AVG_CORD(028),AVG_CORD(008) PIXEL OF oPanel
      @ AVG_CORD(nLin6-1),AVG_CORD(nCol3) MsGet oProDtIni Var dProDtIni Size AVG_CORD(035),AVG_CORD(008) PIXEL OF oPanel

      @ AVG_CORD(nLin6),AVG_CORD(nCol9) Say "Data Final" Size AVG_CORD(026),AVG_CORD(008) PIXEL OF oPanel
      @ AVG_CORD(nLin6-1),AVG_CORD(nCol10) MsGet oProDtFim Var dProDtFim Size AVG_CORD(035),AVG_CORD(008) PIXEL OF oPanel

      //Dados de Despesas
      @ AVG_CORD(nLin8),AVG_CORD(nCol1) TO AVG_CORD(nLin11),AVG_CORD(nCol11) LABEL "Despesas" PIXEL OF oPanel

      @ AVG_CORD(nLin9),AVG_CORD(nCol2) Say "Despesa :" Size AVG_CORD(021),AVG_CORD(008) PIXEL OF oPanel
      @ AVG_CORD(nLin9-1),AVG_CORD(nCol3) MsGet oDesp Var cDesp F3 "SYB" Valid (Vazio() .Or. ExistCpo("SYB",cDesp)) Size AVG_CORD(028),AVG_CORD(008) PIXEL OF oPanel

      @ AVG_CORD(nLin10),AVG_CORD(nCol2) Say "Data Inicial" Size AVG_CORD(028),AVG_CORD(008) PIXEL OF oPanel
      @ AVG_CORD(nLin10-1),AVG_CORD(nCol3) MsGet oDespIni Var dDespIni Size AVG_CORD(035),AVG_CORD(008) PIXEL OF oPanel

      @ AVG_CORD(nLin10),AVG_CORD(nCol9) Say "Data Final" Size AVG_CORD(026),AVG_CORD(008) PIXEL OF oPanel
      @ AVG_CORD(nLin10-1),AVG_CORD(nCol10) MsGet oDespFim Var dDespFim Size AVG_CORD(035),AVG_CORD(008) PIXEL OF oPanel

      //Dados do Desembara�o
      @ AVG_CORD(nLin12),AVG_CORD(nCol1) TO AVG_CORD(nLin14),AVG_CORD(nCol11) LABEL "Desembara�o" PIXEL OF oPanel

      @ AVG_CORD(nLin13),AVG_CORD(nCol2) Say "Data Inicial" Size AVG_CORD(028),AVG_CORD(008) PIXEL OF oPanel
      @ AVG_CORD(nLin13-1),AVG_CORD(nCol3) MsGet oDesemIni Var dDesemIni Size AVG_CORD(035),AVG_CORD(008) PIXEL OF oPanel

      @ AVG_CORD(nLin13),AVG_CORD(nCol9) Say "Data Final" Size AVG_CORD(026),AVG_CORD(008) PIXEL OF oPanel
      @ AVG_CORD(nLin13-1),AVG_CORD(nCol10) MsGet oDesemFim Var dDesemFim Size AVG_CORD(035),AVG_CORD(008) PIXEL OF oPanel

      //Adiantado?
      @ AVG_CORD(nLin15),AVG_CORD(nCol1) TO AVG_CORD(nLin17),AVG_CORD(nCol4) LABEL "Adiantado?" PIXEL OF oPanel
      @ AVG_CORD(nLin16),AVG_CORD(nCol2) ComboBox cAdian Items aAdian Size AVG_CORD(038),AVG_CORD(008) PIXEL OF oPanel

      //Pago Por?
      @ AVG_CORD(nLin15),AVG_CORD(nCol5) TO AVG_CORD(nLin17),AVG_CORD(nCol11) LABEL "Pago Por?" PIXEL OF oPanel
      @ AVG_CORD(nLin16),AVG_CORD(nCol6) ComboBox cPagoPor Items aPagoPor Size AVG_CORD(081),AVG_CORD(008) PIXEL OF oPanel

   ACTIVATE MSDIALOG oDlg On Init EnChoiceBar(oDlg,bOk,bCancel) Centered

End Sequence

Return lRet

/*
Funcao          : ValidTela()
Parametros      : Nenhum
Retorno         : .t./.f.
Objetivos       : Valida as informa��es da tela de filtros
Autor           : Eduardo C. Romanini
Data/Hora       : 21/09/2007 - 11:09.
Revisao         :
Obs.            :
*/
*-------------------------*
Static Function ValidTela()
*-------------------------*
Local lRet := .T.

Begin Sequence

   //Valida as Data do Processo
   If !Empty(dProDtIni) .and. !Empty(dProDtFim)
      If DtoS(dProDtIni) > DtoS(dProDtFim)
         MsgInfo("Per�odo de Datas do Processo Inv�lido","Aten��o")
         lRet := .F.
         Break
      EndIf
   EndIf

   //Valida as Data de Despesas
   If !Empty(dDespIni) .and. !Empty(dDespFim)
      If DtoS(dDespIni) > DtoS(dDespFim)
         MsgInfo("Per�odo de Datas de Despesas Inv�lido","Aten��o")
         lRet := .F.
         Break
      EndIf
   EndIf

   //Valida as Data de Desembara�o
   If !Empty(dDesemIni) .and. !Empty(dDesemFim)
      If DtoS(dDesemIni) > DtoS(dDesemFim)
         MsgInfo("Per�odo de Datas de Desembara�o Inv�lido","Aten��o")
         lRet := .F.
         Break
      EndIf
   EndIf

End Sequence

Return lRet

/*
Funcao          : SelectData()
Parametros      : Nenhum
Retorno         : .t./.f.
Objetivos       : Seleciona as informa��es a serem impressas.
                  Roda em ambientes Top e CodeBase.
Autor           : Eduardo C. Romanini
Data/Hora       : 20/09/2007 - 11:29.
Revisao         :
Obs.            :
*/
*--------------------------*
Static Function SelectData()
*--------------------------*
Local lRet:=.t.

#IFDEF TOP
   Local cCmd
   Private cSelect, cOrder
#ELSE
   Local aSemSx3:={}
   Private aCampos:={}
#ENDIF

Private cFase := If(nFase == 1,"P","Q")

Begin Sequence

   #IFDEF TOP
      cSelect := "Select EET_PEDIDO, EET_CODAGE, EET_TIPOAG, "+;
                        "EET_DESPES, EET_DESADI, EET_VALORR, "+;
                        "EET_BASEAD, EET_PAGOPO, EET_DTDEMB  "

      If cFase == "P" //Pedido
         cSelect += ", EE7_PEDIDO "
      Else //Embarque
         cSelect += ", EEC_PREEMB "
      EndIf

      cSelect += "From "+RetSqlName("EET") + " EET "

      If cFase == "P" //Pedido
         cSelect += ", "+RetSqlName("EE7") + " EE7 "
      Else //Embarque
         cSelect += ", "+RetSqlName("EEC") + " EEC "
      EndIf

      cWhere :=  "Where EET.D_E_L_E_T_ <> '*' " + Iif( cFase == "P", "And EE7.D_E_L_E_T_ <> '*'" , "And EEC.D_E_L_E_T_ <> '*'" ) +  " And EET_FILIAL = '"+xFilial("EET")+"' And " +;
                  Iif( cFase == "P", "EE7_FILIAL = '" + xFilial("EE7") , "EEC_FILIAL = '" + xFilial("EEC") ) + "'" 

      If cFase == "P" //Pedido
         cWhere += " And EET.EET_PEDIDO = EE7.EE7_PEDIDO"
      Else //Embarque
         cWhere += " And EET.EET_PEDIDO = EEC.EEC_PREEMB"
      EndIf

      //Sele��o da Fase
      cWhere += " And EET.EET_OCORRE = '" + cFase + "'"

      //Sele��o do Processo
      If !Empty(cProCod)
         cWhere += " And EET.EET_PEDIDO = '" + cProCod + "'"
      EndIf

      //Sele��o do Per�odo de Data de Processos
      If !Empty(dProDtIni) //Data Inicial
         If cFase == "P"
            cWhere += " And EE7.EE7_DTPROC >= '" + DtoS(dProDtIni) + "'"
         Else
            cWhere += " And EEC.EEC_DTPROC >= '" + DtoS(dProDtIni) + "'"
         EndIf
      EndIf

      If !Empty(dProDtFim) //Data Final
         If cFase == "P"
            cWhere += " And EE7.EE7_DTPROC <= '" + DtoS(dProDtFim) + "'"
         Else
            cWhere += " And EEC.EEC_DTPROC <= '" + DtoS(dProDtFim) + "'"
         EndIf
      EndIf

      //Sele��o da Despesa
      If !Empty(cDesp)
         cWhere += " And EET.EET_DESPES = '" + cDesp + "'"
      EndIf

      //Sele��o do Per�odo de Data das Despesas
      If !Empty(dDespIni) //Data Inicial
         cWhere += " And EET.EET_DESADI >= '" + DtoS(dDespIni) + "'"
      EndIf

      If !Empty(dDespFim) //Data Final
         cWhere += " And EET.EET_DESADI <= '" + DtoS(dDespFim) + "'"
      EndIf

      //Sele��o do Per�odo de Data de Desembara�o
      If !Empty(dDesemIni) //Data Inicial
         cWhere += " And EET.EET_DTDEMB >= '" + DtoS(dDesemIni) + "'"
      EndIf

      If !Empty(dDesemFim) //Data Final
         cWhere += " And EET.EET_DTDEMB <= '" + DtoS(dDesemFim) + "'"
      EndIf

      //Adiantado?
      If cAdian == aAdian[1] //Sim
         cWhere += " And EET.EET_BASEAD = '1'"
      ElseIf cAdian == aAdian[2]//N�o
         cWhere += " And EET.EET_BASEAD = '2'"
      EndIf

      //Pago Por?
      If cPagoPor == aPagoPor[2] //Exportador
         cWhere += " And EET.EET_PAGOPO = '2'"
      ElseIf cPagoPor == aPagoPor[1]  //Despachante
         cWhere += " And EET.EET_PAGOPO = '1'"
      EndIf

      //Agrupamento
      If nAgrup == 1 //Processo
         cOrder := " Order by EET.EET_PEDIDO"
      Else
         cOrder := " Order by EET.EET_CODAGE"
      EndIf

      cCmd := cSelect+cWhere+cOrder
      cCmd := ChangeQuery(cCmd)
      DbUseArea(.t.,"TOPCONN", TCGENQRY(,,cCmd), "Qry", .f., .t.)

      lExisteDados := !(Qry->(Eof()) .And. Qry->(Bof()))

   #ELSE

      aSemSX3 := {{"EET_PEDIDO","C",AVSX3("EET_PEDIDO",AV_TAMANHO),0},;
                  {"EET_CODAGE","C",AVSX3("EET_CODAGE",AV_TAMANHO),0},;
                  {"EET_TIPOAG","C",AVSX3("EET_TIPOAG",AV_TAMANHO),0},;
                  {"EET_DESPES","C",AVSX3("EET_DESPES",AV_TAMANHO),0},;
                  {"EET_DESADI","C",AVSX3("EET_DESADI",AV_TAMANHO),0},;
                  {"EET_VALORR","N",AVSX3("EET_VALORR",AV_TAMANHO),AVSX3("EET_VALORR" ,AV_DECIMAL)},;
                  {"EET_BASEAD","C",AVSX3("EET_BASEAD",AV_TAMANHO),0},;
                  {"EET_PAGOPO","C",AVSX3("EET_PAGOPO",AV_TAMANHO),0},;
                  {"EET_DTDEMB","C",AVSX3("EET_DTDEMB",AV_TAMANHO),0}}

      cWork  := E_CriaTrab(,aSemSX3,"Qry")
      IndRegua("Qry",cWork+TEOrdBagExt(),"EET_PEDIDO","AllwayTrue()","AllwaysTrue()","Processando Arquivo Temporario")
      Set Index to (cWork+TEOrdBagExt())

      EET->(DbSetOrder(1))
      If !Empty(cProCod)

         If EET->(DbSeek(xFilial("EET")+AvKey(cProCod,"EET_PEDIDO")+cFase))

            While EET->(!EOF()) .and. EET->(EET_FILIAL+EET_PEDIDO+EET_OCORRE) == xFilial("EET")+AvKey(cProCod,"EET_PEDIDO")+cFase

               If !ValidSelect()
                  EET->(DbSkip())
                  Loop
               EndIf

               GravaSelect()

               EET->(DbSkip())
            EndDo

         EndIf

      Else

         If EET->(DbSeek(xFilial("EET")))

            While EET->(!EOF()) .and. EET->EET_FILIAL == xFilial("EET")

               If !ValidSelect()
                  EET->(DbSkip())
                  Loop
               EndIf

               GravaSelect()

               EET->(DbSkip())
            EndDo

         EndIf

      EndIf

   #ENDIF

End Sequence

Return lRet

#IFDEF TOP
#ELSE

/*
Funcao          : ValidSelect().
Parametros      : Nenhum.
Retorno         : .t./.f.
Objetivos       : Validar os registros de Despesas Nacionais
Autor           : Eduardo C. Romanini
Data/Hora       : 20/09/2004 - 12:50.
Revisao         :
Obs.            :
*/
*---------------------------*
Static Function ValidSelect()
*---------------------------*
Local lRet := .T.

Begin Sequence

   //Verifica a Fase
   If EET->EET_OCORRE <> cFase
      lRet := .F.
      Break
   EndIf

   //Verifica o Processo
   If !Empty(cProCod)
      If EET->EET_PEDIDO <> Avkey(cProCod,"EET_PEDIDO")
         lRet := .F.
         Break
      EndIf
   EndIf

   //Verifica a Data dos Processos
   If !Empty(dProDtIni)
      If cFase == "P" //Pedido
         EE7->(DbSetOrder(1))
         If EE7->(DbSeek(xFilial("EE7")+EET->EET_PEDIDO))
            If DtoS(EE7->EE7_DTPROC) < DtoS(dProDtIni)
              lRet := .F.
              Break
            EndIf
         EndIf
      Else
         EEC->(DbSetOrder(1))
         If EEC->(DbSeek(xFilial("EEC")+EET->EET_PEDIDO))
           If DtoS(EEC->EEC_DTPROC) < DtoS(dProDtIni)
              lRet := .F.
              Break
            EndIf
         EndIf
      EndIf
   EndIf

   If !Empty(dProDtFim)
      If cFase == "P" //Pedido
         EE7->(DbSetOrder(1))
         If EE7->(DbSeek(xFilial("EE7")+EET->EET_PEDIDO))
            If DtoS(EE7->EE7_DTPROC) > DtoS(dProDtFim)
              lRet := .F.
              Break
            EndIf
         EndIf
      Else
         EEC->(DbSetOrder(1))
         If EEC->(DbSeek(xFilial("EEC")+EET->EET_PEDIDO))
           If DtoS(EEC->EEC_DTPROC) > DtoS(dProDtFim)
              lRet := .F.
              Break
            EndIf
         EndIf
      EndIf
   EndIf

   //Verifica a Despesa
   If !Empty(cDesp)
      If EET->EET_DESPES <> Avkey(cDesp,"EET_DESPES")
         lRet := .F.
         Break
      EndIf
   EndIf

   //Verifica a Data das Despesas
   If !Empty(dDespIni)
      If DtoS(EET->EET_DESADI) < DtoS(dDespIni)
         lRet := .F.
         Break
      EndIf
   EndIf

   If !Empty(dDespFim)
      If DtoS(EET->EET_DESADI) > DtoS(dDespFim)
         lRet := .F.
         Break
      EndIf
   EndIf

   //Verifica a Data de Desembara�o
   If !Empty(dDesemIni)
     If DtoS(EET->EET_DTDEMB) < DtoS(dDesemIni)
        lRet := .F.
        Break
      EndIf
   EndIf

   If !Empty(dDesemFim)
      If DtoS(EET->EET_DTDEMB) > DtoS(dDesemFim)
         lRet := .F.
         Break
      EndIf
   EndIf

   //Verifica se � a despesa � Adiantada
   If cAdian == aAdian[1] //Sim
      If EET->EET_BASEAD <> "1"
         lRet := .F.
         Break
      EndIf
   ElseIf cAdian == aAdian[2] //N�o
      If EET->EET_BASEAD <> "2"
         lRet := .F.
         Break
      EndIf
   EndIf

   //Verifica quem paga a Despesa
   If cPagoPor == aPagoPor[1] //Despachante
      If EET->EET_PAGOPO <> "1"
         lRet := .F.
         Break
      EndIf
   ElseIf cPagoPor == aPagoPor[2] //Exportador
      If EET->EET_PAGOPO <> "2"
         lRet := .F.
         Break
      EndIf
   EndIf

End Sequence

Return lRet


/*
Funcao          : GravaSelect().
Parametros      : Nenhum.
Retorno         : .t./.f.
Objetivos       : Validar os registros de Despesas Nacionais
Autor           : Eduardo C. Romanini
Data/Hora       : 20/09/2004 - 12:50.
Revisao         :
Obs.            :
*/
*---------------------------*
Static Function GravaSelect()
*---------------------------*

Begin Sequence

   Qry->(DbAppend())
   Qry->EET_PEDIDO := EET->EET_PEDIDO
   Qry->EET_CODAGE := EET->EET_CODAGE
   Qry->EET_TIPOAG := EET->EET_TIPOAG
   Qry->EET_DESPES := EET->EET_DESPES
   Qry->EET_DESADI := DtoS(EET->EET_DESADI)
   Qry->EET_VALORR := EET->EET_VALORR
   Qry->EET_BASEAD := EET->EET_BASEAD
   Qry->EET_PAGOPO := EET->EET_PAGOPO
   Qry->EET_DTDEMB := DtoS(EET->EET_DTDEMB)

   lExisteDados := .t.

End Sequence

Return

#ENDIF

/*
Funcao          : Imprimir().
Parametros      : Nenhum.
Retorno         : .t./.f.
Objetivos       : Gravar os arquivos tempor�rios para gera��o do relat�rio.
Autor           : Eduardo C. Romanini
Data/Hora       : 20/09/2004 - 12:50.
Revisao         :
Obs.            :
*/
*------------------------*
Static Function Imprimir()
*------------------------*
Local lRet := .t.

#IFDEF TOP
   Local cCmd
   Local nOldArea
#ENDIF

Begin Sequence

   #IFDEF TOP
      If TcSrvType() <> "AS/400"
         nOldArea := Alias()

         cCmd := "Select COUNT(*) AS TOTAL From " +;
                     RetSqlName("EET") + " EET "

         If nFase == 1 //Pedido
            cCmd += ", "+RetSqlName("EE7") + " EE7 "
         Else //Embarque
            cCmd += ", "+RetSqlName("EEC") + " EEC "
         EndIf

         cCmd := ChangeQuery(cCmd+cWhere)
         DbUseArea(.t.,"TOPCONN", TcGenQry(,,cCmd),"QryTemp", .f., .t.)

         ProcRegua(QryTemp->TOTAL)

         QryTemp->(DbCloseArea())
         DbSelectArea(nOldArea)
      EndIf
   #ENDIF

   CAB->(DbAppend())
   CAB->SEQREL   := cSeqRel

   //Agrupamento
   If nAgrup  == 1
      CAB->AGRUP := "Processo"
   Else
      CAB->AGRUP := "Empresa"
   EndIf

   //Processo
   If !Empty(cProCod)
      CAB->PROCESSO := AllTrim(cProCod)
   EndIf

   //Data Inicial do Processo
   If !Empty(dProDtIni)
      CAB->DTPROCI := dProDtIni
   EndIf

   //Data Final do Processo
   If !Empty(dProDtFim)
      CAB->DTPROCF := dProDtFim
   EndIf

   //Despesa
   If !Empty(cDesp)
      CAB->TIPODESP := Alltrim(cDesp)
   EndIf

   //Data Inicial de Despesas
   If !Empty(dDespIni)
      CAB->DTDESPI := dDespIni
   EndIf

   //Data Final de Despesas
   If !Empty(dDespFim)
      CAB->DTDESPF := dDespFim
   EndIf

   //Data Inicial de Desembara�o
   If !Empty(dDesemIni)
      CAB->DTDESEI := dDesemIni
   EndIf

   //Data Final de Desembara�o
   If !Empty(dDespFim)
      CAB->DTDESEI := dDesemFim
   EndIf

   //Adinatado?
   If cAdian == aAdian[1] //Sim
      CAB->ADIAN := "Sim"
   ElseIf cAdian == aAdian[2] //N�o
      CAB->ADIAN := "N�o"
   Else
      CAB->ADIAN := "Todos"
   EndIf

   //Pago Por
   If cPagoPor == aPagoPor[1]
      CAB->PAGOPOR := "Despachante"
   ElseIf cPagoPor == aPagoPor[2]
      CAB->PAGOPOR := "Exportador"
   Else
      CAB->PAGOPOR := "Todos"
   EndIf

   Qry->(DbGoTop())
   Do While Qry->(!Eof())

      DET->(DBAPPEND())

      DET->SEQREL   := cSeqRel

      If nAgrup  == 1 //Agrupamento por Processo
         DET->PROCESSO := Qry->EET_PEDIDO
      Else //Agrupamento por Empresa
         DET->PROCESSO := ""
      EndIf

      DET->CODAGE   := Qry->EET_CODAGE
      DET->DESCAGE  := Posicione("SY5",1,xFilial("SY5")+Qry->EET_CODAGE,"Y5_NOME")
      DET->TIPOAG   := Qry->EET_TIPOAG
      DET->DESPES   := Qry->EET_DESPES
      DET->DESPDES  := Posicione("SYB",1,xFilial("SYB")+Qry->EET_DESPES,"YB_DESCR")
      DET->DESPDT   := DtoC(StoD(Qry->EET_DESADI))
      DET->DESPVAL  := Transform(Qry->EET_VALORR,"@E 99,999,999.99")
      DET->ADIAN    := If(Qry->EET_BASEAD == "1","Sim","N�o")
      DET->PAGOPOR  := If(Qry->EET_PAGOPO == "1","Despachante","Exportador")

      DET->DESEMDT  := DtoC(StoD(Qry->EET_DTDEMB))

      //Total
      DET->TOTAL    := Qry->EET_VALORR

      //Adiantamento
      If Qry->EET_DESPES == "901"
         DET->ADDDESP := Qry->EET_VALORR
         DET->COMDESP := 0
         DET->DEVDESP := 0
         DET->OUTROS  := 0

      //Complemento
      ElseIf Qry->EET_DESPES == "902"
         DET->COMDESP := Qry->EET_VALORR
         DET->ADDDESP := 0
         DET->DEVDESP := 0
         DET->OUTROS  := 0

      //Devolu��o
      ElseIf Qry->EET_DESPES == "903"
         DET->DEVDESP := Qry->EET_VALORR
         DET->ADDDESP := 0
         DET->COMDESP := 0
         DET->OUTROS  := 0

      //Outros
      Else
         DET->OUTROS  := Qry->EET_VALORR
         DET->ADDDESP := 0
         DET->DEVDESP := 0
         DET->COMDESP := 0

      EndIf

      Qry->(dbSkip())
   EndDo

End Sequence

Return lRet

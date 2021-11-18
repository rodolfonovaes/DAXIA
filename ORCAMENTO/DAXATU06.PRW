#Include "PROTHEUS.CH"
#Include "TOPCONN.CH"

/*/{Protheus.doc} DAXATU06
Consulta de Orçamentos
@type  User Function
@author B. Vinicius
@since 19/08/2019
/*/                                       
User Function DAXATU06()

  Local aArea := GetArea()

  Local Filtrar
  Local Imprimir
  Local oGetGrPrd
  Local oGetProd
  Local oSay1
  Local oSay2
  Local oSay3
  Local oSay4
  Local oSay5
  Local aOrdem := {}

  Private oDlg
  Private aHeadOrc
  Private aColsOrc
  Private oGetOrc
  Private cGetGrPrd := CriaVar('BM_GRUPO',.F.)
  Private cGetProd := CriaVar('B1_COD',.F.)
  Private cCombOrd := "Orçamento"
  Private cSayTot := 0
  Private nTotOrc := 0
  Private aAuxSer := {}
  Private cCliente  := IIF(M->CJ_CLIENTE == Nil , SCJ->CJ_CLIENTE , M->CJ_CLIENTE)
  Private cLoja   := IIF(M->CJ_LOJA == Nil , SCJ->CJ_LOJA , M->CJ_LOJA)

// OPCOES COMBOBOX DE ORDENACAO
  aAdd( aOrdem , "Orçamento")
  aAdd( aOrdem , "Produto")

  //MONTANDO A TELA
  DEFINE MSDIALOG oDlg TITLE "Consulta de Orçamentos" FROM 000, 000  TO 500, 900 COLORS 0, 16777215 PIXEL

  @ 011, 019 SAY oSay1 PROMPT "Histórico de Orçamentos" SIZE 095, 007 OF oDlg COLORS 0, 14215660 PIXEL
  @ 010, 121 SAY oSay2 PROMPT POSICIONE("SA1",1,FWxFilial("SA1")+cCliente+cLoja,"A1_NOME") SIZE 216, 007 OF oDlg COLORS 0, 16777215 PIXEL
  fMSNewGetDados1()
  @ 185, 024 SAY oSay3 PROMPT "Grupo de Produto" SIZE 061, 007 OF oDlg COLORS 0, 14215660 PIXEL
  @ 184, 094 MSGET oGetGrPrd VAR cGetGrPrd SIZE 172, 010 OF oDlg COLORS 0, 16777215 F3 "SBM" PIXEL
  @ 202, 024 SAY oSay4 PROMPT "Produto" SIZE 059, 007 OF oDlg COLORS 0, 14215660 PIXEL
  @ 201, 093 MSGET oGetProd VAR cGetProd SIZE 172, 010 OF oDlg COLORS 0, 16777215 F3 "SB1" PIXEL
  @ 172, 008 SAY oSay5 PROMPT "Filtros" SIZE 025, 007 OF oDlg COLORS 0, 14215660 PIXEL

  @ 218 ,  024 SAY oSay5 PROMPT "Ordenacao" SIZE 059, 007 OF oDlg COLORS 0, 14215660 PIXEL
  @ 217, 093 MSCOMBOBOX oCombOrd VAR cCombOrd ITEMS aOrdem SIZE 072, 010 OF oDlg COLORS 0, 16777215 PIXEL

  @ 216, 306 BUTTON Filtrar PROMPT "Filtrar" SIZE 037, 012 OF oDlg Action FWMsgRun(, {|| LoadaCols() }, "Processando", "Filtrando Registros...")  PIXEL
  //@ 216, 362 BUTTON Imprimir PROMPT "Imprimir" SIZE 037, 012 OF oDlg Action FWMsgRun(, {|| ImpDados() }, "Processando", "Filtrando Registros...")   PIXEL

  @ 234 , 024 SAY oSay7 PROMPT "Total" SIZE 059, 007 OF oDlg COLORS 0, 14215660 PIXEL
  @ 234 , 094 SAY oSayTot PROMPT cSayTot SIZE 059, 007 OF oDlg COLORS 0, 14215660 PIXEL

  ACTIVATE MSDIALOG oDlg

  RestArea(aArea)

Return


//CARREGANDO A GRID
//------------------------------------------------ 
Static Function fMSNewGetDados1()
//------------------------------------------------ 
  Local nX
  Local aFieldFill := {}
  Local aFields := {"CJ_NUM","CJ_EMISSAO","CK_NUMPV","D2_DOC","F2_EMISSAO","CK_PRODUTO","CK_DESCRI","CK_QTDVEN","CK_UM","Preço em Dólar","Preço em Real","CK_VALOR","CK_XMOTIVO","CK_XDSCMOT","CK_XJUSTIF"}
//Local aFields := {"CJ_NUM","CK_NUMPV",/*"N. NF"*/,"CK_PRODUTO","CK_DESCRI","CK_QTDVEN","CK_UM",/*"Preco Neg","Moeda",*/"CK_VALOR"/* ,"Status ","Justificativa"*/}
  Local aAlterFields := {}
  Local ctitulo := ''
  aHeadOrc := {}
  aColsOrc := {}

  // Define field properties
  DbSelectArea("SX3")
  SX3->(DbSetOrder(2))
  For nX := 1 to Len(aFields)
    If SX3->(DbSeek(aFields[nX]))
      If aFields[nX] == "F2_EMISSAO"
        cTitulo := 'Dt Faturamento'
      Else
        cTitulo := AllTrim(X3Titulo())
      EndIf
      Aadd(aHeadOrc, {cTitulo,SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
        SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
    Elseif aFields[nX] == "Preço em Real"
      Aadd(aHeadOrc, {aFields[nX],"VLREAL",PesqPict("SCK","CK_PRCVEN"),TamSx3("CK_PRCVEN")[1],TamSx3("CK_PRCVEN")[2],".T.",;
        SX3->X3_USADO,"N",SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
    Elseif aFields[nX] == "Preço em Dólar"
      Aadd(aHeadOrc, {aFields[nX],"VLDOL",PesqPict("SCK","CK_PRCVEN"),TamSx3("CK_PRCVEN")[1],TamSx3("CK_PRCVEN")[2],".T.",;
        SX3->X3_USADO,"N",SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
    Elseif aFields[nX] == "CK_DESCRI"
      Aadd(aHeadOrc, {cTitulo,SX3->X3_CAMPO,SX3->X3_PICTURE,85,SX3->X3_DECIMAL,SX3->X3_VALID,;
        SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})  
    Endif
  Next nX

  // Define field values
  For nX := 1 to Len(aFields)
    If DbSeek(aFields[nX])
      Aadd(aFieldFill, CriaVar(SX3->X3_CAMPO,.F.))
    Else
      Aadd(aFieldFill, CriaVar('CK_PRCVEN',.F.))
    Endif
  Next nX
  Aadd(aFieldFill, .F.)
  Aadd(aColsOrc, aFieldFill)

  oGetOrc := MsNewGetDados():New( 031, 017, 157, 406, GD_INSERT+GD_DELETE+GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeadOrc, aColsOrc)

Return

//CARREGANDO ACOLS CONFORME PARAMETROS
Static Function LoadaCols()

  Local cAliasQry := GetNextAlias()
  Local cQuery := ""
  Local nCont
  Local nPosVirg := 0
  Local nPosTot := aScan(aHeadOrc,{|x| AllTrim(x[2]) == "VLREAL" 	})
  Local cPedido := ""
  Local cNF := ""
  Local nValConv := 0
  Local aAreaSM2 := SM2->(GetArea())

  nTotOrc := 0

  aColsOrc := {}

  cQuery += " SELECT "

  cQuery += " CJ_NUM ,CJ_EMISSAO, CK_NUMPV , CK_PRUNIT ,  CK_PRODUTO , CK_DESCRI, CK_QTDVEN , CK_UM , CK_VALOR ,

  cQuery += " CK_MOEDA , CK_XMOTIVO , CK_XJUSTIF ,  CK_PRCVEN , CJ_EMISSAO ,  "

  cQuery += " CK_XPRUNI2 , CK_XPRVEN2 , CK_XVALOR2 , CK_XFIXA , CK_XTAXA "

  cQuery += " FROM " + RetSQLName("SCK") + " SCK "

  cQuery += " INNER JOIN " + RetSQLName("SCJ") + " SCJ "

  cQuery += " ON ( CK_FILIAL = CJ_FILIAL AND CK_NUM = CJ_NUM )"

// FILTO DE PRODUTO
  If !Empty(cGetProd)

    cQuery += " INNER JOIN " + RetSQLName("SB1") + " SB1 "

    cQuery += " ON ( CK_PRODUTO = B1_COD AND CK_PRODUTO = '" + cGetProd + "' AND SB1.D_E_L_E_T_ = '' ) "

  Endif

// FILTO DE GRUPO DE PRODUTO
  If !Empty(cGetGrPrd)

    If Empty(cGetProd)

      cQuery += " INNER JOIN " + RetSQLName("SB1") + " SB1 "

      cQuery += " ON ( CK_PRODUTO = B1_COD AND  SB1.D_E_L_E_T_ = ''  ) "

    Endif

    cQuery += " INNER JOIN " + RetSQLName("SBM") + " SBM "

    cQuery += " ON ( BM_GRUPO = B1_GRUPO AND BM_GRUPO = '" + cGetGrPrd + "' AND SBM.D_E_L_E_T_ = '' ) "

  Endif

  cQuery += " WHERE CJ_FILIAL = '" + FWxFilial("SCJ") + "' "

  cQuery += " AND CJ_CLIENTE = '" + cCliente + "' "

  cQuery += " AND CJ_LOJA = '" + cLoja + "' "

  cQuery += " AND SCK.D_E_L_E_T_ = '' AND SCJ.D_E_L_E_T_ = '' "

//ORDENACAO
  If Alltrim(cCombOrd) == "Orçamento"
    cQuery += " ORDER BY CJ_NUM "
  Elseif Alltrim(cCombOrd) == "Produto"
    cQuery += " ORDER BY CK_PRODUTO "
  Endif

  TcQuery cQuery new Alias (cAliasQry)

  While !(cAliasQry)->(EOF())

    cPedido := ""
    cNf := ""

    If !Empty( (cAliasQry)->CK_NUMPV )

      SC5->(dbSetOrder(1))

      If SC5->(dbSeek( FWxFilial("SC5") + (cAliasQry)->CK_NUMPV ))
        cNF := SC5->C5_NOTA
      Endif

    Endif

    aAdd ( aColsOrc , Array( Len(aHeadOrc) + 1)  )

    For nCont := 1 To Len(aHeadOrc)

      If "D2" $ aHeadOrc[nCont][2]
        aColsOrc[Len(aColsOrc)][nCont] := cNF
      Elseif Alltrim(aHeadOrc[nCont][2]) == "CK_XDSCMOT" //Campo Virtual
        aColsOrc[Len(aColsOrc)][nCont] := POSICIONE("SZ8",1,XFILIAL("SZ8")+(cAliasQry)->CK_XMOTIVO,"Z8_MOTIVO")
      Elseif Alltrim(aHeadOrc[nCont][2]) == "CJ_EMISSAO" //Converto para o formato DD/MM/AAAA
        aColsOrc[Len(aColsOrc)][nCont] := DToC(STOD((cAliasQry)->CJ_EMISSAO))
      Elseif Alltrim(aHeadOrc[nCont][2]) == "VLREAL"

        // VENDA EM REAL
        If (cAliasQry)->CK_MOEDA == "1"
          aColsOrc[Len(aColsOrc)][nCont] :=  (cAliasQry)->CK_PRCVEN
        Else // VENDA EM DOLAR CONVERTE O VALOR COM A MOEDA NA DATA DO ORCAMENTO

          If Empty(cNF)
              aColsOrc[Len(aColsOrc)][nCont] := 0
          Else

            // PEGANDO VALOR DA DATA DO DOLAR NA EMISSAO DO ORÇAMENTO

            SF2->(dbSetOrder(1))
            SF2->(dbSeek(FWxFilial("SF2")+cNF))

            SM2->(dbSetOrder(1))
            SM2->(dbSeek(SF2->F2_EMISSAO))
            
            If (cAliasQry)->CK_XFIXA == 'S'
              nValConv := (cAliasQry)->CK_XTAXA
            Else
              nValConv := SM2->M2_MOEDA2
            EndIf

            aColsOrc[Len(aColsOrc)][nCont] := NoRound((cAliasQry)->CK_PRCVEN,TamSx3("CK_PRCVEN")[1]) * nValConv

            Endif
        Endif

      Elseif Alltrim(aHeadOrc[nCont][2]) == "VLDOL"

        // VENDA EM REAL , VALOR 0
        If (cAliasQry)->CK_MOEDA == "1"
          aColsOrc[Len(aColsOrc)][nCont] := 0
        Else // VENDA EM DOLAR BUSCA O VALOR
          aColsOrc[Len(aColsOrc)][nCont] :=  (cAliasQry)->CK_PRCVEN
        Endif

      Elseif Alltrim(aHeadOrc[nCont][2]) == "CK_VALOR" .And. (cAliasQry)->CK_MOEDA == "2"
          aColsOrc[Len(aColsOrc)][nCont] :=  (cAliasQry)->CK_VALOR * nValConv
      Elseif Alltrim(aHeadOrc[nCont][2]) == "F2_EMISSAO"   
          If Empty(cNF)
              aColsOrc[Len(aColsOrc)][nCont] := STOD('')
          Else
              SF2->(dbSetOrder(1))
              SF2->(dbSeek(FWxFilial("SF2")+cNF))          
              aColsOrc[Len(aColsOrc)][nCont] := SF2->F2_EMISSAO
          EndIf             
      Elseif Alltrim(aHeadOrc[nCont][2]) == "CK_DESCRI" 
          aColsOrc[Len(aColsOrc)][nCont] :=  Posicione('SB1',1,xFilial('SB1') + (cAliasQry)->CK_PRODUTO,'B1_DESC')
      Else
        aColsOrc[Len(aColsOrc)][nCont] :=  (cAliasQry)->&(aHeadOrc[nCont][2])
      Endif

    Next

    aColsOrc[Len(aColsOrc)][Len(aHeadOrc) + 1] := .F.

    (cAliasQry)->(dbSkip())
  EndDo

  oGetOrc:SetArray(aColsOrc, .T.)
  oGetOrc:Refresh(.T.)
  oGetOrc:ForceRefresh()

  (cAliasQry)->(dbCloseArea())


  For nCont := 1 To Len(oGetOrc:aCols)
    nTotOrc += oGetOrc:aCols[nCont][nPosTot]
  Next

  oSayTot:cCaption := Alltrim(Transform(nTotOrc,"@E 9,999,999,999.999999"))
  oSayTot:Refresh()

Return

//EXPORTA DADOS DA GRID PARA EXCEL
Static Function ImpDados()

  Local nCont := 0
  Local nCont2
  Local aCabec := {}
  Local aExcel := {}
  Local nPosTot := aScan(aHeadOrc,{|x| AllTrim(x[2]) == "CK_VALOR" 	})

  aCabec := Array(Len(aHeadOrc))

  For nCont2 := 1 To Len(aCabec)
    aCabec[nCont2] := aHeadOrc[nCont2][1]
  Next

  For nCont := 1 To Len(oGetOrc:aCols)

    aAdd ( aExcel , Array(Len(aHeadOrc)) )

    For nCont2 := 1 To Len(aHeadOrc)

      If ValType(oGetOrc:aCols[nCont][nCont2]) == "C"
        aExcel[Len(aExcel)][nCont2] := CHR(160) +oGetOrc:aCols[nCont][nCont2]
      Else
        aExcel[Len(aExcel)][nCont2] := oGetOrc:aCols[nCont][nCont2]
      Endif

    Next

  Next

  aAdd ( aExcel , Array(Len(aHeadOrc)) )


  aExcel[Len(aExcel)][1] := "Total:"
  aExcel[Len(aExcel)][nPosTot] := nTotOrc

  If !ApOleClient("MSExcel")
    MsgAlert("Microsoft Excel não instalado!")
    Return
  EndIf

  DLGTOEXCEL({ {"ARRAY", "Orçamentos", aCabec, aExcel} })

Return

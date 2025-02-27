#Include "RWMAKE.CH"
#Include "TBIConn.CH"
#Include "TBICode.CH"
#Include "Protheus.CH"
#Include "Font.CH"                               
#Include "TopConn.CH"
#Include "FWPrintSetup.CH" // Header de impressao
#Include "RPTDef.CH" // Header de impressao

#Define  _ENTER  Chr( 13 ) + Chr( 10 )

/*======================================================================================+
| Funcao de usuario ..:   DX_ROMAN()                                                    |
| Autor...............:                                                                 |
| Data................:   15/08/2019                                                    |
| Descricao / Objetivo:   Funcao de usuario de impressao de pedido de venda.            |
| Doc. Origem.........:   MIT044                                                        |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
User Function DX_ROMAN() // Relatorio PV

/*------------------------+
| Declaracao de Variaveis |
+------------------------*/
Local    aArea           := GetArea()
Local    lAdjustToLegacy := .T.
Local    lDisableSetup   := .T.
Local    cNomRel         := ""
Private  nTotal	         := 0
Private  nSubTot         := 0
Private  oPrn            := Nil
Private  oFont06         := Nil
Private  oFont06N        := Nil
Private  oFont08         := Nil
Private  oFont08N        := Nil
Private  oFont10         := Nil
Private  oFont10N        := Nil
Private  oFont11         := Nil
Private  oFont11N        := Nil
Private  oFont12         := Nil
Private  oFont12N        := Nil
Private  oFont13         := Nil
Private  oFont13N        := Nil
Private  oFont14         := Nil
Private  oFont14N        := Nil
Private  oFont16         := Nil
Private  oFont16N        := Nil
Private  oFontC10        := Nil 
Private  cPerg           := "DXPV01"
Private  nLin            := 1650 // Linha de inicio da impressao
Private  cLocal          := SuperGetMV( "ES_RELDIR", , "C:\RELATS"  )
Private  cTime_          := Time()
Private  nPagina         := 1
Private  cPedido         := ""
Private  cOrc			 := ""

/*----------------------------------------------------------------+
| Verifica a existencia do diretorio/pasta do parametro ES_RELDIR |
+----------------------------------------------------------------*/
If File( cLocal )
   cLocal := AllTrim( cLocal ) + "\"
Else
   nRet := MakeDir( cLocal )
   If nRet <> 0
      MsgAlert( OEMToANSI( "N�o foi poss�vel criar o diret�rio " + cLocal + " - Erro: " ) + cValToChar( FError() ) )
   Else
      cLocal := AllTrim( cLocal ) + "\"
   EndIf
EndIf

/*-----------------------------------------+
| Definicao dos fontes e tamanho em pixels |
+-----------------------------------------*/
oFont06	 := TFont():New( "Arial", 06, 06,, .F.,,,, .T., .F. )
oFont06N := TFont():New( "Arial", 06, 06,, .T.,,,, .T., .F. )
oFont08	 := TFont():New( "Arial", 08, 08,, .F.,,,, .T., .F. )
oFont08N := TFont():New( "Arial", 08, 08,, .T.,,,, .T., .F. )
oFont10	 := TFont():New( "Arial", 10, 10,, .F.,,,, .T., .F. )
oFont10N := TFont():New( "Arial", 10, 10,, .T.,,,, .T., .F. )
oFont11  := TFont():New( "Arial", 11, 11,, .F.,,,, .T., .F. )
oFont11N := TFont():New( "Arial", 11, 11,, .T.,,,, .T., .F. )
oFont12  := TFont():New( "Arial", 12, 12,, .F.,,,, .T., .F. )
oFont12N := TFont():New( "Arial", 12, 12,, .T.,,,, .T., .F. )
oFont13  := TFont():New( "Arial", 13, 13,, .F.,,,, .T., .F. )
oFont13N := TFont():New( "Arial", 13, 13,, .T.,,,, .T., .F. )
oFont14	 := TFont():New( "Arial", 14, 14,, .F.,,,, .T., .F. )
oFont14N := TFont():New( "Arial", 14, 14,, .T.,,,, .T., .F. )
oFont16	 := TFont():New( "Arial", 16, 16,, .F.,,,, .T., .F. )
oFont16N := TFont():New( "Arial", 16, 16,, .T.,,,, .T., .F. )
oFontC10 := TFont():New( "Courier New", 10, 10,, .T.,,,, .T., .F. )

/*--------------------------------------+
| Definicao do nome do arquivo PDF      |
+--------------------------------------*/
cNomRel := "romaneio" + Str( Year( dDataBase ), 4, 0 ) + /* Prefixo "orcam_" + Ano */;
           StrZero( Month( dDataBase ), 2 ) + /* ........ Mes */;
           StrZero( Day( dDataBase ), 2 ) + /* .......... Dia */;
           "_" + Left( cTime_, 2 ) + /* ................. Hora */;
           SubStr( cTime_, 4, 2 ) + /* .................. Minuto */;
           ".PD_" /* .................................... Extensao PDF */  

/*--------------------------------------+
| Configuracao do objeto de impressao   |
+--------------------------------------*/
oPrn := FWMSPrinter():New( cNomRel, IMP_PDF, lAdjustToLegacy, cLocal, lDisableSetup, , , , , , .F., .T. )
oPrn:SetLandScape()
oPrn:SetPaperSize( DMPAPER_A4 )
oPrn:Setup()

/*--------------------------------------+
| Impressao do relatorio de PV          |
+--------------------------------------*/
PedVen()
MS_Flush()
oPrn:EndPage()
RestArea( aArea )
Return( Nil )

/*======================================================================================+
| Funcao Estatica ....:   PedVen()                                                      |
| Autor...............:                                                                 |
| Data................:   15/08/2019                                                    |
| Descricao / Objetivo:   Impressao do Pedido de Vendas.			                    |
| Doc. Origem.........:   MIT044                                                        |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
Static Function PedVen()
Local cFilePrint := ""
Local nVlrTot	 := 0

/*--------------------------------------------------+
| Impressao do relatorio do Pedido de Vendas        |
+--------------------------------------------------*/
cOrc := Posicione( "SCJ", 3, xFilial( "SCJ" ) + SC5->( C5_CLIENTE + C5_LOJACLI + DtoS( C5_EMISSAO ) ), "CJ_NUM" )	
cPedido:= SC5->C5_NUM  // Alterado por amorim 30/12/2019
	
DbSelectArea( "SA1" ) // Clientes
DbSetOrder( 1 ) // A1_FILIAL + A1_COD + A1_LOJA
DbSeek( xFilial( "SA1" ) + SC5->( C5_CLIENTE + C5_LOJACLI ) )

DbSelectArea( "SA4" ) // Transportadora
DbSetOrder( 1 ) // A4_FILIAL + A4_COD
DbSeek( xFilial( "SA4" ) + SC5->C5_TRANSP )
	
DbSelectArea( "SA3" ) // Vendedores
DbSetOrder( 1 ) // A3_FILIAL + A3_COD
DbSeek( xFilial( "SA3" ) + SC5->C5_VEND1 )

DbSelectArea( "DA0" )   // Tabela de pre�o
DbSetOrder( 1 ) // DA0_FILIAL + DA0_CODTAB
DbSeek(xFilial( "DA0" ) + SC5->C5_TABELA )

DbSelectArea( "SF4" )  // TES
DbSetOrder( 1 ) // F4_FILIAL + F4_CODIGO
DbSeek( xFilial( "SF4" ) + SC6->C6_TES )
	
DbSelectArea( "SE4" ) // Condicao de pagamento
DbSetOrder( 1 ) // E4_FILIAL + E4_CODIGO
DbSeek( xFilial( "SE4" ) + SC5->C5_CONDPAG )
	
DbSelectArea( "SC6" ) // Itens do PV
DbSetOrder( 1 ) // C6_FILIAL + C6_NUM + C6_ITEM + C6_PRODUTO
DbSeek( xFilial( "SC6" ) + SC5->C5_NUM )
	

	
DbSelectArea( "SC6" )
DbSetOrder( 1 ) // C6_FILIAL + C6_NUM + C6_ITEM + C6_PRODUTO
DbSeek( SC5->( C5_FILIAL + C5_NUM ) )
	
nLin := 2500 // ja' sai estourando a linha para montagem do cabecalho

cPedido := SC5->C5_NUM

SC9->(DbSetOrder( 1 )) // C9_FILIAL + C9_PEDIDO + C9_ITEM + C9_SEQUEN + C9_PRODUTO + C9_BLEST + C9_BLCRED
IF SC9->(DbSeek( xFilial( "SC9" ) + cPedido ))
    Do While SC9->( .not. EoF() ) .and. SC9->( C9_FILIAL + C9_PEDIDO ) == SC5->( C5_FILIAL + C5_NUM )
    If nLin > 2300
        MontaCabec()
    Endif
        

    oPrn:Say( nLin, 0065, SC9->C9_PRODUTO + ' - ' + Posicione('SB1',1,xFilial('SB1') + SC9->C9_PRODUTO,'B1_DESC'), oFont10 ) // Produto
    oPrn:Say( nLin, 2000, SC9->C9_LOTECTL, oFont10 ) // Lote
    oPrn:Say( nLin, 2100, Transform( SC9->C9_QTDLIB, "@E 9,999,999.99" ), oFontC10 ) // Quantidade
    oPrn:Say( nLin, 2400, SC6->C6_UM, oFont10 ) // Unid. Medida
    oPrn:Say( nLin, 2800, DtoC( SC6->C6_ENTREG ), oFont10 ) // Data de Entrega
    nLin += 15

    oPrn:Say( nLin, 0065, Replicate( "_", 525 ), oFont06 )
    nLin += 50

    SC9->( DbSkiP() )
        
    EndDo

    /*----------------------------------------------------------------+
    | Impresso do rodape' para finalizacao da impressao do PedVem.    |
    +----------------------------------------------------------------*/
    //MontaRodape()
    /*------------------------------------------------------+
    | Finalizacao do processo de impressao                  |
    +------------------------------------------------------*/
    File2Printer( cFilePrint, "PDF" )
    oPrn:cPathPDF := cLocal
    oPrn:EndPage()
    oPrn:Preview()    
Else
    Alert('N�o encontrou registro na SC9!')
EndIf

Return( Nil )

/*======================================================================================+
| Funcao Estatica ....:   MontaCabec()                                                  |
| Autor...............:                                                                 |
| Data................:   06/09/2019                                                    |
| Descricao / Objetivo:   Funcao estatica de geracao do cabe�ario do relatorio          |
|                                                                                       |
| Doc. Origem.........:   MIT044                                                        |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
Static Function MontaCabec()
Local cEnd  := " - - - "
Local cNome := "DAXIA DOCE AROMA INDUSTRIA E COMERCIO LTDA"
Local cCNPJ := Space( 14 )
Local cIE   := ""

/*---------------------------------------------------------------------+
| Verifica qual filial esta' posicionada/logada para buscar o endereco |
+---------------------------------------------------------------------*/
Do Case
   Case Right( SC5->C5_FILIAL, 2 ) == "01" // Tatuape
        cEnd  := "RUA CANTAGALO, 74" + " - "  + "03319-000" + " - " + "SAO PAULO" + " - " + "SP"
        cCNPJ := "74581091000132"
        cIE   := "114224468110"  
   Case Right( SC5->C5_FILIAL, 2 ) == "02" // Itajai
        cEnd  := "RUA CESAR AUGUSTO DALCOQUIO, 4255" + " - " + "88311-500" + " - " + "ITAJAI" + " - " + "SC"   
        cCNPJ := "74581091000213"
        cIE   := "255789025     "
   Case Right( SC5->C5_FILIAL, 2 ) == "03" // Guarulhos
        cEnd  := "RUA JONAS FERREIRA GUIMARAES, 100" + " - " + "07250-025" + " - " + "GUARULHOS" + " - " + "SP"
        cCNPJ := "74581091000647"
        cIE   := "796061457115"  
   Case Right( SC5->C5_FILIAL, 2 ) == "04" // Jaboatao
        cEnd  := "ROD BR 101 SUL, 9391" + " - " + "54503-010" + " - " + "CABO DE SANTO AGOSTINHO" + " - "  + "PE"
        cCNPJ := "74581091000728"
        cIE   := "062696726"     
EndCase

oPrn:StartPage() // Inicializa a pagina
oPrn:SayBitMap( 120, 050, "\system\lgrl01.bmp", 369, 61 ) // Impressao do logo

/*-------------------------------------------------------------------------------------------+
| Abaixo dados do cabe�alho do relat�rio, com informa��es da emmpresa emissora do relat�rio. |
+-------------------------------------------------------------------------------------------*/
oPrn:Say( 0100, 0460, cNome, oFont14N )
oPrn:Say( 0100, 2410, "PEDIDO DE VENDA  No..: " + cPedido, oFont14N )
oPrn:Say( 0137, 0460, "CNPJ: " + Transform( AllTrim( cCNPJ ), "@R 99.999.999/9999-99" ), oFont11 )
oPrn:Say( 0137, 1010, "I.E.: " + cIE, oFont11 )
oPrn:Say( 0145, 2605, "EMITIDA EM : " + DtoC( dDataBase ), oFont11 )
oPrn:Say( 0187, 0460, cEnd, oFont11 )

oPrn:Say( 0200, 2180, "ESTE PEDIDO FOI GERADO PELO OR�AMENTO: " + cOrc, oFont11N )
oPrn:Say( 0224, 0460, "FONE..: (11) 2633-3000 - FAX ", oFont11 )
oPrn:Say( 0250, 2785, "P�gina..: " + AllTrim( Str( nPagina, 6, 0 ) ), oFont11 )
oPrn:Say( 0261, 0460, "EMAIL.: administrativo@daxia.com.br - WEBSITE: WWW.DAXIA.COM.BR ", oFont11 )

/*-------------------------------------------------------------------------------------------+
| Abaixo imprimo uma linha para dividir a tela de informa��es da empresa com as dos clientes |
+-------------------------------------------------------------------------------------------*/
oPrn:Say( 0300, 0050, Replicate( "__", 085 ), oFont14N )
oPrn:Say( 0365, 0065, "Cliente", oFont14N )
oPrn:Box( 0388, 0062, 0790, 2950 )
//oPrn:Say( 0365, 1820, "Condi��es", oFont14N )
//oPrn:Box( 0388, 1810, 0790, 2950 )

/*--------------------------+
| Dados dos clientes        |
+--------------------------*/
oPrn:Say( 0437, 0075, "Nome/Raz�o Social", oFont14N )
oPrn:Say( 0437, 1700, "Nome Fantasia", oFont14N )
oPrn:Say( 0474, 0075, SA1->A1_NOME, oFont12 )
oPrn:Say( 0474, 1700, SA1->A1_NREDUZ, oFont12 )
oPrn:Say( 0530, 0075, "Endereco", oFont14N )
oPrn:Say( 0567, 0075, AllTrim( SA1->A1_END )    + " - " +;
                      AllTrim( SA1->A1_BAIRRO ) + " - " +;
                      AllTrim( SA1->A1_MUN )    + " - " +;
                      AllTrim( SA1->A1_EST )    + " - " +;
                      "CEP " + Transform( SA1->A1_CEP, "@R 99999-999" ), oFont12 ) // Endereco / Bairro / Cidade / UF / CEP


oPrn:Say( 0623, 0075, "Transportadora", oFont14N )
cTransp	 := Posicione( "SA4", 1, xFilial( "A4" ) + SC5->C5_TRANSP, "A4_NREDUZ" ) //A4_FILIAL+A4_COD
oPrn:Say( 0660, 0075, cTransp , oFont12 ) // Endere�o / Bairro / Cidade / UF de Cobran�a

cFraseFrete := ""
Do Case
   Case SC5->C5_TPFRETE == "1"
        cFraseFrete := "1 - CIF Frete Daxia         "
   Case SC5->C5_TPFRETE == "2"
        cFraseFrete := "2 - CIF Transportadora      "
   Case SC5->C5_TPFRETE == "3"
        cFraseFrete := "3 - FOB Redespacho          "
   Case SC5->C5_TPFRETE == "4"
        cFraseFrete := "4 - FOB Transportadora      "
   Case SC5->C5_TPFRETE == "5"
        cFraseFrete := "5 - Sem Frete Cliente Retira"

//inserido por amorim em 30/12	
   
   Case SC5->C5_TPFRETE == "C"
        cFraseFrete := "C - CIF                     "
   Case SC5->C5_TPFRETE == "F"
        cFraseFrete := "F - FOB                     "
   Case SC5->C5_TPFRETE == "T"
        cFraseFrete := "T - Por conta de terceiros  "
   Case SC5->C5_TPFRETE == "R"
        cFraseFrete := "R - Por conta remetente     "
   Case SC5->C5_TPFRETE == "D"
        cFraseFrete := "D - Por conta destinat�rio  "
   Case SC5->C5_TPFRETE == "S"
        cFraseFrete := "S - Sem frete               "
		
EndCase

oPrn:Say( 0716, 0075, "Frete" ,oFont14N )
oPrn:Say( 0753, 0075, cFraseFrete, oFont12 )

oPrn:Say( 0716, 1050, "Pedido do Cliente", oFont14N )
oPrn:Say( 0753, 1050, AllTrim( SC6->C6_PEDCLI ), oFont12 )

oPrn:Say( 0716, 1700, "Vendedor", oFont14N )
oPrn:Say( 0753, 1700, AllTrim( SC5->C5_XNVEND), oFont12 )


/*------------------------------------+
| Cabe�alho dos Itens                 |
+------------------------------------*/
oPrn:Say( 0830, 0065, "ITENS DO PEDIDO", 	oFont12N )
oPrn:Say( 0880, 0065, "PRODUTO",             oFont12N )
oPrn:Say( 0880, 2000, "LOTE",                oFont12N )
oPrn:Say( 0880, 2200, "QTDE",                oFont12N )
oPrn:Say( 0880, 2400, "UN",                  oFont12N )
oPrn:Say( 0840, 2800, "DATA P/",             oFont12N )
oPrn:Say( 0880, 2800, "ENTREGA",             oFont12N )

nLin := 940
nPagina++ // Incremento de pagina

Return( Nil )

/*======================================================================================+
| Funcao Estatica ....:   MontaRodape()                                                 |
| Autor...............:                                                                 |
| Data................:   06/09/2019                                                    |
| Descricao / Objetivo:   Funcao estatica de geracao do rodape do relatorio             |
|                                                                                       |
| Doc. Origem.........:   MIT044                                                        |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
Static Function MontaRodape()
Local cUsuario  := AllTrim( UsrRetName( __CUSERID ) )
Local cDia      := SubStr( DtoS( dDataBase), 7, 2 )
Local cAno      := SubStr( DtoS( dDataBase), 1, 4 )
Local cMesExt   := MesExtenso( Month( dDataBase ) )
Local cDtImpr_  := cDia + " de " + cMesExt + " de " + cAno
Local cMenDolar := "* O Valor em Dolar ser� convertido na data do faturamento"

/*----------------------------------------------------------------------+
| Abaixo fa�o o desenho do box para as informa��es do rodap� da p�gina. |
+----------------------------------------------------------------------*/
/*oPrn:Say( 1960, 0100, OEMToANSI( "Log (Usu�rio e data de Entrada do Pedido)" ) , oFont10N )
oPrn:Box( 1980, 0050, 2090, 1050 )
oPrn:Say( 2045, 0100, cDtImpr_ + " - " + cTime_ + Space( 10 ) + cUsuario, oFont10 )
oPrn:Say( 2125, 0100, "Data e Assinatura do Cliente", oFont10N )
oPrn:Box( 2140, 0050, 2260, 1050 )*/
oPrn:Say( 1960, 0050, "Resumo do Pedido", oFont10N )
//oPrn:Say( 1950, 2240, OEMToANSI( cMenDolar ), oFont10N )
oPrn:Box( 1980, 0050, 2270, 2920 )
ImpBoxQL(oPrn, oFont10N, 2010, 0050, 2250, 2340, POSICIONE("SCJ",1,XFILIAL("SCJ")+SC5->C5_XNUMCJ,"CJ_XOBSPED")                                                                   )
oPrn:EndPage() // Finaliza a pagina
Return( Nil )


//Imprime texto dentro de um box definido
Static Function ImpBoxQL(oPrn,oFnt,nY,nX,nH,nW,cTxt)

Local aTexto
Local aTexto2
Local cTexto := AllTrim(cTxt)
Local nLin := nY
Local nAltLin := oPrn:GetTextHeight("MMMM",oFnt)
Local nA, nB := 0

aTexto := StrTokArr(cTexto,Chr(13)+Chr(10),.T.)

For nA := 1 to Len(aTexto)

	aTexto2 := StrTokArr(aTexto[nA]," ",.T.)

	cLinha := ""

	For nB := 1 to Len(aTexto2)

		If oPrn:GetTextWidth(cLinha+" "+aTexto2[nB],oFnt) > nW .And. !Empty(cLinha)

			oPrn:Say( nLin, nX ,AllTrim(cLinha),oFnt,,,,0)
			cLinha := ""
			nLin += nAltLin
			
			//--Volta 1 no contador para nao desprezar a 
			//--descricao seguinte:
			nB := nB - 1
               
		Else

			cLinha += " "+aTexto2[nB]

		EndIf
          If nLin > nH
               Exit
          EndIf
	Next nB

	If !Empty(cLinha)

		oPrn:Say( nLin, nX ,AllTrim(cLinha),oFnt,,,,0)
		nLin += nAltLin
	
	EndIf

Next nA

Return nLin

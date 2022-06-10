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
| Funcao de usuario ..:   DX_RelOrc()                                                   |
| Autor...............:                                                                 |
| Data................:   15/08/2019                                                    |
| Descricao / Objetivo:   Funcao de usuario de impressao de orcamentos.                 |
| Doc. Origem.........:   MIT044                                                        |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
User Function DX_RelOrc()

/*------------------------+
| Declaracao de Variaveis |
+------------------------*/
Local    aArea           := GetArea()
Local    lAdjustToLegacy := .T.
Local    lDisableSetup   := .T.
Local    cNomRel         := ""
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
Private  cPerg           := "DXORC01"
Private  nLin            := 1650 // Linha de inicio da impressao
Private  cLocal          := SuperGetMV( "ES_RELDIR", , "C:\RELATS"  )
Private  cTime_          := Time()
Private  nPagina         := 1
Private  cOrcPed         := ""
Private  cPedido         := ""

/*----------------------------------------------------------------+
| Verifica a existencia do diretorio/pasta do parametro ES_RELDIR |
+----------------------------------------------------------------*/
If File( cLocal )
   cLocal := AllTrim( cLocal ) + "\"
Else
   nRet := MakeDir( cLocal )
   If nRet <> 0
      MsgAlert( OEMToANSI( "Não foi possível criar o diretório " + cLocal + " - Erro: " ) + cValToChar( FError() ) )
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
cNomRel := "orcam_" + Str( Year( dDataBase ), 4, 0 ) + /* Prefixo "orcam_" + Ano */;
           StrZero( Month( dDataBase ), 2 ) + /* ........ Mes */;
           StrZero( Day( dDataBase ), 2 ) + /* .......... Dia */;
           "_" + Left( cTime_, 2 ) + /* ................. Hora */;
           SubStr( cTime_, 4, 2 ) + /* .................. Minuto */;
           ".PD_" /* .................................... Extensao PDF */  
           /* Exemplo: orcam_20191015_1046.pdf  */

/*--------------------------------------+
| Configuracao do objeto de impressao   |
+--------------------------------------*/
oPrn := FWMSPrinter():New( cNomRel, IMP_PDF, lAdjustToLegacy, cLocal, lDisableSetup, , , , , , .F., .T. )
oPrn:SetResolution(78)
oPrn:SetLandScape()
oPrn:SetPaperSize( DMPAPER_A4 )
oPrn:SetMargin(60,60,60,60)
oPrn:Setup()

/*--------------------------------------+
| Impressao do relatorio de Orcamento   |
+--------------------------------------*/
Orcamento()
MS_Flush()
oPrn:EndPage()
RestArea( aArea )
Return( Nil )

/*======================================================================================+
| Funcao Estatica ....:   Orcamento()                                                   |
| Autor...............:                                                                 |
| Data................:   15/08/2019                                                    |
| Descricao / Objetivo:   Impressao do Orcamento do Pedido de Vendas.                   |
| Doc. Origem.........:   MIT044                                                        |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
Static Function Orcamento()
Local cFilePrint := ""
Local cMoeda     := ""
Local nVlrTot    := 0

DbSelectArea( "SA1" ) // Clientes
DbSetOrder( 1 ) // A1_FILIAL + A1_COD + A1_LOJA
DbSeek( xFilial( "SA1" ) + SCJ->CJ_CLIENTE + SCJ->CJ_LOJA ) 

DbSelectArea( "SCK" ) // Itens do Orcamento
DbSetOrder( 1 ) // CK_FILIAL + CK_NUM + CK_ITEM + CK_PRODUTO
DbSeek( SCJ->CJ_FILIAL + SCJ->CJ_NUM )


SE4->(DbSetOrder(1))
SE4->(DbSeek(xFilial('SE4')+SCJ->CJ_CONDPAG))

cOrcPed := SCJ->CJ_NUM
cPedido := SCK->CK_NUMPV

nLin := 2500 // ja' sai estourando a linha para montagem do cabecalho

Do While SCK->( .not. EoF() ) .and. SCK->CK_FILIAL + SCK->CK_NUM == SCJ->CJ_FILIAL + SCJ->CJ_NUM

   If nLin > 2000
      MontaCabec()
   EndIf
		
   /*-------------------------------------------------------------+
   | Calcula o total do item mais IPI                             |
   +-------------------------------------------------------------*/
   nVlrTot := 0
   nVlrTot := iIf( .not. Empty( SCK->CK_XVLIPI ), SCK->CK_VALOR + ( ( SCK->CK_VALOR * SCK->CK_XVLIPI ) / 100 ), SCK->CK_VALOR )

   /*-------------------------------------------------------------+
   | Faço o tratamento da Moeda para saber pelo número o seu nome |
   | MV_MOEDA1 A MV_MOEDA5, 1=REAL, 2=DOLAR, 3=UFIR, 4=XXXXX      |
   +-------------------------------------------------------------*/
   cMoeda := ""
   Do Case
      /*-------------------------+
      |  1 = REAL                |
      +-------------------------*/
      Case Substr( AllTrim( SCK->CK_MOEDA ), 1, 1 ) == "1"
           cMoeda := "REAL"
      /*-------------------------+
      |  2 = DOLAR               |
      +-------------------------*/
      Case SubStr( AllTrim( SCK->CK_MOEDA ), 1, 1 ) == "2"
           cMoeda := "DOLAR"
      /*-------------------------+
      |  3 = UFIR                |
      +-------------------------*/
      OtherWise
           cMoeda := "UFIR"
   EndCase

   oPrn:Say( nLin, 0065, SUBSTR(SCK->CK_DESCRI,1,40), oFont10 ) // Produto
   oPrn:Say( nLin, 0680, Left( SCK->CK_XPROCED, 15 ), oFont10 ) // Origem Produto
   oPrn:Say( nLin, 1000, Transform( SCK->CK_QTDVEN, "@E 9,999,999.99" ), oFontC10 ) // Quantidade
   oPrn:Say( nLin, 1220, SCK->CK_UM, oFont10 ) // Unid. Medida
   oPrn:Say( nLin, 1350, cMoeda, oFont10 ) // Moeda Produto
   oPrn:Say( nLin, 1635, Transform( SCK->CK_PRCVEN, "@E 9,999,999.99" ), oFontC10 ) // Preco de Venda
   oPrn:Say( nLin, 1880, Transform( SCK->CK_XVLIPI, "@E 99,999,999.99" ), oFontC10 ) // % IPI
   oPrn:Say( nLin, 2100, Transform( SCK->CK_XVLICM, "@E 99,999,999.99" ), oFontC10 ) // % ICMS
   oPrn:Say( nLin, 2400, Transform( nVlrTot,        "@E 9,999,999.99" ), oFontC10 ) // Valor total do IPI
   oPrn:Say( nLin, 2750, DtoC( SCK->CK_ENTREG ), oFont10 ) // Data de Entrega
   oPrn:Say( nLin, 3000, Transform( SCK->CK_XVLFRET, "@E 99,999,999.99" ), oFont10 ) // Data de Entrega
   nLin += 15

   oPrn:Say( nLin, 0065, Replicate( "_", 525 ), oFont06 )
   nLin += 50

   SCK->( DbSkiP() )
	
EndDo

/*----------------------------------------------------------------+
| Impresso do rodape' para finalizacao da impressao do orcamento. |
+----------------------------------------------------------------*/
MontaRodape()

/*------------------------------------------------------+
| Finalizacao do processo de impressao                  |
+------------------------------------------------------*/
File2Printer( cFilePrint, "PDF" )
oPrn:cPathPDF := cLocal
oPrn:EndPage()
oPrn:Preview()

Return( Nil )

/*======================================================================================+
| Funcao Estatica ....:   MontaCabec()                                                  |
| Autor...............:                                                                 |
| Data................:   06/09/2019                                                    |
| Descricao / Objetivo:   Funcao estatica de geracao do cabeçario do relatorio          |
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
   Case Right( SCJ->CJ_FILIAL, 2 ) == "01" // Tatuape
        cEnd  := "RUA CANTAGALO, 74" + " - "  + "03319-000" + " - " + "SAO PAULO" + " - " + "SP"
        cCNPJ := "74581091000132"
        cIE   := "114224468110"  
   Case Right( SCJ->CJ_FILIAL, 2 ) == "02" // Itajai
        cEnd  := "RUA CESAR AUGUSTO DALCOQUIO, 4255" + " - " + "88311-500" + " - " + "ITAJAI" + " - " + "SC"   
        cCNPJ := "74581091000213"
        cIE   := "255789025     "
   Case Right( SCJ->CJ_FILIAL, 2 ) == "03" // Guarulhos
        cEnd  := "RUA JONAS FERREIRA GUIMARAES, 100" + " - " + "07250-025" + " - " + "GUARULHOS" + " - " + "SP"
        cCNPJ := "74581091000647"
        cIE   := "796061457115"  
   Case Right( SCJ->CJ_FILIAL, 2 ) == "04" // Jaboatao
        cEnd  := "RUA DONA MARIA DE SOUZA, 681" + " - " + "54400-260" + " - " + "JABOATAO DOS GUARARAPES" + " - "  + "PE"
        cCNPJ := "74581091000728"
        cIE   := "062696726"     
EndCase

oPrn:StartPage() // Inicializa a pagina

/*-------------------------------------------------------------------------------------------+
| Abaixo dados do cabeçalho do relatório, com informações da emmpresa emissora do relatório. |
+-------------------------------------------------------------------------------------------*/
oPrn:SayBitMap( 120, 050, "\system\lgrl01.bmp", 369, 61 ) // Impressao do logo
oPrn:Say( 0100, 0460, cNome, oFont14N )
oPrn:Say( 0100, 2340, "ORÇAMENTO DE VENDA  No..: " + cOrcPed, oFont14N )
oPrn:Say( 0137, 0460, "CNPJ: " + Transform( AllTrim( cCNPJ ), "@R 99.999.999/9999-99" ), oFont11 )
oPrn:Say( 0137, 1010, "I.E.: " + AllTrim( cIE ), oFont11 )
oPrn:Say( 0145, 2605, "EMITIDA EM : " + DtoC( dDataBase ), oFont11 )
oPrn:Say( 0187, 0460, cEnd, oFont11 )
oPrn:Say( 0200, 2325, "ESTE ORÇAMENTO GEROU O PEDIDO: " + cPedido, oFont11N )
oPrn:Say( 0224, 0460, "FONE..: (11) 2633-3000 - FAX ", oFont11 )
oPrn:Say( 0250, 2760, "Página..: " + AllTrim( Str( nPagina, 6, 0 ) ), oFont11 )
oPrn:Say( 0261, 0460, "EMAIL.: administrativo@daxia.com.br - WEBSITE: WWW.DAXIA.COM.BR ", oFont11 )

/*-------------------------------------------------------------------------------------------+
| Abaixo imprimo uma linha para dividir a tela de informações da empresa com as dos clientes |
+-------------------------------------------------------------------------------------------*/
oPrn:Say( 0300, 0050, Replicate( "__", 085 ), oFont14N )
oPrn:Say( 0365, 0065, "Cliente", oFont14N )
oPrn:Box( 0388, 0062, 0790, 1800 )
oPrn:Say( 0365, 1820, "Condições", oFont14N )
oPrn:Box( 0388, 1810, 0790, 2950 )

/*--------------------------+
| Dados dos clientes        |
+--------------------------*/
oPrn:Say( 0437, 0075, "Nome/Razão Social", oFont14N )
oPrn:Say( 0437, 1050, "Fone/Fax", oFont14N )
oPrn:Say( 0474, 0075, OEMToANSI( AllTrim( SA1->A1_NOME ) ), oFont12 )
oPrn:Say( 0474, 1050, "(" + AllTrim( SA1->A1_DDD ) + ") " + Telefone( SA1->A1_TEL ), oFont12 )
oPrn:Say( 0530, 0075, "Endereco", oFont14N )
oPrn:Say( 0567, 0075, AllTrim( SA1->A1_END )    + " - " +;
                      AllTrim( SA1->A1_BAIRRO ) + " - " +;
                      AllTrim( SA1->A1_MUN )    + " - " +;
                      AllTrim( SA1->A1_EST )    + " - " +;
                      "CEP " + Transform( SA1->A1_CEP, "@R 99999-999" ), oFont12 ) // Endereco / Bairro / Cidade / UF / CEP

/*-----------------------------------------------------+
| Abaixo os dados do endereço de cobrança dos clientes |
+-----------------------------------------------------*/
oPrn:Say( 0623, 0075, "Endereco de Cobrança", oFont14N )
oPrn:Say( 0660, 0075, AllTrim( SA1->A1_ENDCOB )  + " - " +;
                      AllTrim( SA1->A1_BAIRROC ) + " - " +;
                      AllTrim( SA1->A1_MUNC )    + " - " +;
                      AllTrim( SA1->A1_ESTC )    + " - " +;
                      "CEP " + Transform( SA1->A1_CEPC, "@R 99999-999" ), oFont12 ) // Endereço / Bairro / Cidade / UF de Cobrança
oPrn:Say( 0716, 0075, "CNPJ" ,oFont14N )
oPrn:Say( 0716, 0670, "Inscrição Estadual", oFont14N )
oPrn:Say( 0716, 1050, "Contato", oFont14N )
oPrn:Say( 0753, 0075, Transform( AllTrim( SA1->A1_CGC ), "@R 99.999.999/9999-99" ), oFont12 )
oPrn:Say( 0753, 0670, SA1->A1_INSCR, oFont12 )
oPrn:Say( 0753, 1050, SCJ->CJ_XCONTAT, oFont12 )

/*-----------------------------------------------------+
| Abaixo dados das condições de pagamento dos clientes |
+-----------------------------------------------------*/
oPrn:Say( 0437, 1820, "Prazo de Pagamento", oFont14N )
oPrn:Say( 0437, 2400, "Transportadora", oFont14N )
oPrn:Say( 0474, 1820, SE4->E4_DESCRI, oFont12 )
oPrn:Say( 0474, 2400, AllTrim( SCJ->CJ_XNMTRAN ), oFont12 )
oPrn:Say( 0530, 1820, "Frete", oFont14N )
oPrn:Say( 0530, 2400, "Pedido do Cliente", oFont14N )

cFraseFrete := ""
Do Case
   Case SCJ->CJ_XTPFRET == "1"
        cFraseFrete := "1 - CIF Frete Daxia         "
   Case SCJ->CJ_XTPFRET == "2"
        cFraseFrete := "2 - CIF Transportadora      "
   Case SCJ->CJ_XTPFRET == "3"
        cFraseFrete := "3 - FOB Redespacho          "
   Case SCJ->CJ_XTPFRET == "4"
        cFraseFrete := "4 - FOB Transportadora      "
   Case SCJ->CJ_XTPFRET == "5"
        cFraseFrete := "5 - Sem Frete Cliente Retira"
EndCase

oPrn:Say( 0567, 1820, Upper( cFraseFrete ), oFont12 )
oPrn:Say( 0567, 2400, AllTrim( SCJ->CJ_XCONTAT ), oFont12 )

oPrn:Say( 0623, 1820, "Valor Frete:", oFont14N )
oPrn:Say( 0623, 2000, Transform( SCJ->CJ_XVLFRET, "@E 9,999,999.99" ), oFont12 )

oPrn:Say( 0679, 1820, "Destino", oFont14N )

cRespTipcli := ""
Do Case
   Case SubStr( AllTrim( SCJ->CJ_TIPOCLI ), 1, 1 ) == "F"
        cRespTipcli := "Cons.Final           "
   Case SubStr( AllTrim( SCJ->CJ_TIPOCLI ), 1, 1 ) == "L"
        cRespTipcli := "Prod.Rural           "
   Case SubStr( AllTrim( SCJ->CJ_TIPOCLI ), 1, 1 ) == "R"
        cRespTipcli := "Revendedor           "
   Case SubStr( AllTrim( SCJ->CJ_TIPOCLI ), 1, 1 ) == "S"
        cRespTipcli := "Solidario            "
   Case SubStr( AllTrim( SCJ->CJ_TIPOCLI ), 1, 1 ) == "X"
        cRespTipcli := "Importacao/Importacao"
EndCase

oPrn:Say( 0716, 1820, Upper( cRespTipcli ), oFont12 )
oPrn:Say( 0679, 2400, "Vendedor", oFont14N )
oPrn:Say( 0716, 2400, AllTrim( SCJ->CJ_XNOMEV ), oFont12 )
oPrn:Say( 0772, 1820, "Validade da Proposta:", oFont14N )
oPrn:Say( 0772, 2200, DtoC( SCJ->CJ_VALIDA ), oFont12 )

/*------------------------------------+
| Cabeçalho dos Itens                 |
+------------------------------------*/
oPrn:Say( 0830, 0065, "ITENS DO ORCAMENTO", oFont12N )
oPrn:Say( 0840, 1680, "PREÇO",              oFont12N )
oPrn:Say( 0840, 2000, "%",                  oFont12N )
oPrn:Say( 0840, 2200, "%",                  oFont12N )
oPrn:Say( 0840, 2400, "TOTAL",              oFont12N )
oPrn:Say( 0840, 2750, "DATA P/",            oFont12N )
oPrn:Say( 0840, 3000, "VALOR",              oFont12N )
oPrn:Say( 0880, 0065, "PRODUTO",            oFont12N )
oPrn:Say( 0880, 0680, "PROCEDÊNCIA",        oFont12N )
oPrn:Say( 0880, 1090, "QTDE",               oFont12N )
oPrn:Say( 0880, 1220, "UN",                 oFont12N )
oPrn:Say( 0880, 1350, "MOEDA",              oFont12N )
oPrn:Say( 0880, 1680, "UNITÁRIO",           oFont12N )
oPrn:Say( 0880, 2000, "IPI",                oFont12N )
oPrn:Say( 0880, 2200, "ICMS",               oFont12N )
oPrn:Say( 0880, 2400, "DO ITEM C/IPI",      oFont12N )
oPrn:Say( 0880, 2750, "ENTREGA",            oFont12N )
oPrn:Say( 0880, 3000, "FRETE",              oFont12N )

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
Local cMenDolar := "* O Valor em Dolar será convertido na data do faturamento"

/*----------------------------------------------------------------------+
| Abaixo faço o desenho do box para as informações do rodapé da página. |
+----------------------------------------------------------------------*/
oPrn:Say( 2080, 0100, OEMToANSI( "Log (Usuário e data de Entrada do Pedido)" ) , oFont10N )
oPrn:Box( 2110, 0050, 2210, 1050 )
oPrn:Say( 2175, 0100, cDtImpr_ + " - " + cTime_ + Space( 10 ) + cUsuario, oFont10 )
oPrn:Say( 2250, 0100, "Data e Assinatura do Cliente", oFont10N )
oPrn:Box( 2270, 0050, 2380, 1050 )
oPrn:Say( 2080, 1100, "Resumo do Pedido", oFont10N )
oPrn:Say( 2080, 2240, OEMToANSI( cMenDolar ), oFont10N )
oPrn:Box( 2110, 1100, 2390, 2920 )
oPrn:EndPage() // Finaliza a pagina
Return( Nil )

/*======================================================================================+
| Funcao Estatica ....:   Telefone( cTel )                                              |
| Autor...............:                                                                 |
| Data................:   06/09/2019                                                    |
| Descricao / Objetivo:   Funcao estatica edicao do campo A1_TEL (telefone do cliente)  |
| Doc. Origem.........:   MIT044                                                        |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
Static Function Telefone( cTel )
Local  aArea   := GetArea()
Local  cTelMsk := ""
Local  cTl

cTl := AllTrim( cTel )
For nX := 1 to Len( cTl )
    If IsDigit( SubStr( cTl, nX, 1 ) )
       cTelMsk += SubStr( cTl, nX, 1 )
    EndIf
NexT
cTelMsk := Left( cTelMsk,(Len(cTelMsk)-4) ) + "-" +Right( cTelMsk, 4 )
RestArea( aArea )
Return( cTelMsk )

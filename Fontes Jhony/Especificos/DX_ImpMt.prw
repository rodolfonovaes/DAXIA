#include "protheus.ch"	
#include "totvs.ch"
#include "fileio.ch"

/*======================================================================================+
| Programa............:   DX_ImpMt.prw                                                  |
| Autor...............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   29/07/2019                                                    |
| Descricao / Objetivo:   Programa-fonte com diversas funcoes especificas de importacao |
|                         de metas para o cadastro SCT.                                 |
| Doc. Origem.........:   MIT044 - Importacao de Metas.                                 |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
User Function DXImMt()
Local   aArea   := GetArea()
Local   lRet    := .F.
Local   cTitulo := "Arquivo Metas de Vendas (*.CSV)"
Private cTrgtDir
Private cDocto_ := Space( 09 )
Private cDescr_ := Space( 40 )
 
cTrgtDir := cGetFile( "*.csv", cTitulo, 0, "c:\", .F., GETF_LOCALHARD, .F. )

If Empty( cTrgtDir )
   lRet := .T.
Else
   If .not. ".CSV"$Upper( cTrgtDir )
       MsgInfo( OEMToANSI( "Arquivo selecionado não é tipo *.CSV" ), OEMToANSI( "Seleção Arquivo *.CSV" ) )
       lRet := .T.
   EndIf
EndIf

If .not. lRet
   If DocDescrOk()
      MsgRun( OEMToANSI( "Aguarde, importando arquivo: " + cTrgtDir ), OEMToANSI( "Importação" ), { | x, y | Importa( cTrgtDir ) } )
   EndIf
EndIf

RestArea( aArea )
Return( Nil )
 
/*======================================================================================+
| Funcao Estatica ....:   Importa( _cTrgtDir )                                          |
| Autor...............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   29/07/2019                                                    |
| Descricao / Objetivo:   Funcao estatica que importa os dados da array aDados e grava  |
|                         no cadastro SCT.                                              |
| Doc. Origem.........:   MIT044 - Importacao de Metas.                                 |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
Static Function Importa( _cTrgtDir )
Local aArea    := GetArea()
Local aRet     := {}
Local aAux     := {}
Local nX       := 0
Local nY       := 0
Local nHandle

/*-----------------------------------------------------------------------------------------+
| Realiza a consistencia de abertura de baixo nivel do caminho/arquivo contido na variavel |
| _cTrgDir. Caso haja inconsistencia (-1) abandonara' o processo de importacao.            |
+-----------------------------------------------------------------------------------------*/
nHandle := FT_FUSE( _cTrgtDir )

If nHandle = -1
   nRet := oFTPHandle:DeleteFile( "*.csv" )
   MsgInfo( OEMToANSI( "Ocorreu problemas no procedimento de abertura do arquivo *.CSV. Contatar o Administrador do Sistema." ), OEMToANSI( "Abertura de Arquivo *.CSV" ) )
Else
   /*-------------------------------------------------+
   | Posiciona na primeira linha do arquivo *.CSV     |
   +-------------------------------------------------*/
   FT_FGOTOP()
   Do While .not. FT_FEOF()
      cAux := FT_FREADLN()
      aAux := Separa( cAux, ";" )
      aAdd( aRet, aAux )
      FT_FSKIP()
   EndDo
   FT_FUSE() // Fecha o arquivo *.CSV

   /*-------------------------------------------------+
   | Grava os campos do SCT a partir da array aRet    |
   +-------------------------------------------------*/
   For nX := 1 To Len( aRet )
       RecLock( "SCT", .T. )
       For nY := 1 To SCT->( fCount() )
           Do Case
              Case nY == FieldPos( "CT_FILIAL"  )
                   SCT->( FieldPut( nY, xFilial( "SCT" ) ) )
              Case nY == FieldPos( "CT_DOC"     )
                   SCT->( FieldPut( nY, cDocto_ ) )
              Case nY == FieldPos( "CT_SEQUEN"  )
                   SCT->( FieldPut( nY, StrZero( nX, TamSX3( "CT_SEQUEN" )[ 1 ] ) ) )
              Case nY == FieldPos( "CT_DESCRI"  )
                   SCT->( FieldPut( nY, cDescr_ ) )
              Case nY == FieldPos( "CT_DATA"    )
                   SCT->( FieldPut( nY, dDataBase ) )
              Case nY == FieldPos( "CT_VEND"    )
                   SCT->( FieldPut( nY, aRet[nX][4] ) )
              Case nY == FieldPos( "CT_PRODUTO" )
                   SCT->( FieldPut( nY, aRet[nX][5] ) )
              Case nY == FieldPos( "CT_TIPO" )
                   SCT->( FieldPut( nY, GetAdvFval( "SB1", "B1_TIPO", xFilial( "SB1" ) + aRet[nX][5], 1, 1 ) ) )
              Case nY == FieldPos( "CT_QUANT"   )
                   SCT->( FieldPut( nY, Val( aRet[nX][6] ) ) )
              Case nY == FieldPos( "CT_VALOR"   )
                   SCT->( FieldPut( nY, Val( aRet[nX][7] ) ) )
              Case nY == FieldPos( "CT_MOEDA"   )
                   SCT->( FieldPut( nY, Val( aRet[nX][9] ) ) )
              Case nY == FieldPos( "CT_XMMAAAA" ) // (campo MM/AAAA - customizado)
                   SCT->( FieldPut( nY, aRet[nX][1] ) )
              Case nY == FieldPos( "CT_XNEGOC"  ) // (campo Codigo Negocio - customizado)
                   SCT->( FieldPut( nY, aRet[nX][2] ) )
              Case nY == FieldPos( "CT_XEQVEND" ) // (campo Codigo Equipe de Vendas - customizado)
                   SCT->( FieldPut( nY, aRet[nX][3] ) )
              Case nY == FieldPos( "CT_XDOLAR"  ) // (campo Total em Dolar - customizado)
                   SCT->( FieldPut( nY, Val( aRet[nX][8] ) ) )
              Case nY == FieldPos( "CT_XTAXMET"  ) // (campo Taxa Meta - customizado)
                   SCT->( FieldPut( nY, Val( aRet[nX][10] ) ) )
           EndCase
       NexT nY
       SCT->( MSUnlock() )
       ConfirmSX8() // Confirmar o uso do codigo SCT.
   Next nX
EndIf

RestArea( aArea )	
Return( Nil )

/*======================================================================================+
| Funcao Estatica ....:   DocDescrOk()                                                  |
| Autor...............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   01/08/2019                                                    |
| Descricao / Objetivo:   Funcao estatica de preenchimento dos campos documento e des-  |
|                         cricao da Meta de Vendas.                                     |
| Doc. Origem.........:   MIT044 - Importacao de Metas.                                 |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
Static Function DocDescrOk()
Local  aArea   :=  GetArea()
Local  lRet    :=  .F.
Local  _nOpcao :=  0
Local  _oDlgPto
Local  oBold
Local  oGDocOri
Local  oGDescr

/*-------------------------------------------+
|  Busca o proximo codigo do cadastro SCT    |
+-------------------------------------------*/
cDocto_ := GetSx8Num( "SCT", "CT_DOC" )

Define MSDialog _oDlgPto Title OEMToANSI( "* Docto. e Descrição da Meta de Vendas" ) From 00,00 To 20, 64 Of oMainWnd
Define Font oBold Name "Arial" Size 0, -13 Bold
@ 050, 006  To  140, 230  Label  OEMToANSI( "[ Documento e Descrição ]" )  Of  _oDlgPto  Pixel

/*---------------------------------------------------------------+
| Digitacao do numero de documento e descricao da Meta de Vendas |
+---------------------------------------------------------------*/
@ 080, 010 Say    OEMtoANSI( "Documento" ) Font oBold  Pixel Color CLR_HBLUE
@ 095, 010 Say    OEMtoANSI( "Descrição" ) Font oBold  Pixel Color CLR_HBLUE

@ 080, 055 MSGet  oGDocOri  Var cDocto_  Valid VldDoc() Picture "@9" Size 050, 008 Of _oDlgPto Pixel
@ 095, 055 MSGet  oGDescr   Var cDescr_  Valid VldDsc() Picture "@!" Size 150, 008 Of _oDlgPto Pixel

Activate MSDialog _oDlgPto Center On Init EnchoiceBar( _oDlgPto, { || _nOpcao := 1, _oDlgPto:End() }, { || _oDlgPto:End() } )

/*--[ Enchoice Bar ]-------------------+
| _nOpcao == 1 --> Botao [ Ok ]        |
| _nOpcao == 0 --> Botao [ Cancelar ]  |
+-------------------------------------*/
If _nOpcao == 1
   If MsgYesNo( OEMToANSI( "Confirma o Documento e a Descrição?" ), OEMToANSI( "Confirmação" ) )
      lRet := .T.
   Else
      lRet := .F.
   EndIf
EndIf

RestArea( aArea )
Return( lRet )

/*======================================================================================+
| Funcao Estatica ....:   VldDoc()                                                      |
| Autor...............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   01/08/2019                                                    |
| Descricao / Objetivo:   Funcao estatica de validacao da variavel private cDocto_      |
| Doc. Origem.........:   MIT044 - Importacao de Metas.                                 |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
Static Function VldDoc()
Local aArea := GetArea()
Local lRet  := .F.

If Empty( cDocto_ )
   MsgInfo( OEMToANSI( "O código do Documento deve ser preenchido." ), OEMToANSI( "Documento" ) )
Else
   DbSelectArea( "SCT" )
   DbSetOrder( 1 ) // CT_FILIAL + CT_DOC + CT_SEQUEN
   If DbSeek( xFilial( "SCT" ) + cDocto_ )
      MsgInfo( OEMToANSI( "Documento de Metas de Vendas já cadastrado." ), OEMToANSI( "Documento" ) )
   Else
      lRet := .T.
   EndIf
EndIf

RestArea( aArea )
Return( lRet )

/*======================================================================================+
| Funcao Estatica ....:   VldDsc()                                                      |
| Autor...............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   01/08/2019                                                    |
| Descricao / Objetivo:   Funcao estatica de validacao da variavel private cDocto_      |
| Doc. Origem.........:   MIT044 - Importacao de Metas.                                 |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
Static Function VldDsc()
Local aArea := GetArea()
Local lRet  := .F.

If Empty( cDescr_ )
   MsgInfo( OEMToANSI( "A Descrição do Documento deve ser preenchido." ), OEMToANSI( "Descrição" ) )
Else
   lRet := .T.
EndIf

RestArea( aArea )
Return( lRet )

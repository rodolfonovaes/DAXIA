#include "protheus.ch"	
#include "totvs.ch"
#include "fileio.ch"
/*======================================================================================+
| Programa............:   DX_AjuMt.prw                                                  |
| Autor...............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   30/07/2019                                                    |
| Descricao / Objetivo:   Programa-fonte com diversas funcoes especificas de ajustes de |
|                         metas do cadastro SCT.                                        |
| Doc. Origem.........:   MIT044 - Ajuste de Metas.                                     |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
User Function DXAjMt()
Local    aArea   := GetArea()
Local    _oDlgPto
Local    oBold
Local    oGDocOri
Local    oGMes
Local    oGAno
Local    oGDescr_
Local    oGTxDlr
Local    oGDocDst
Local    _nOpcao := 0

Private  cDocOri := Space( 09 )
Private  cDocDst := GetSx8Num( "SCT", "CT_DOC" )
Private  cDescr_ := Space( 40 )
Private  cMes    := Space( 02 )
Private  cAno    := Space( 04 )
Private  nTxDlr  := 0.0000

Define MSDialog _oDlgPto Title OEMToANSI( "* Ajustes de Metas de Vendas" ) From 00,00 To 25, 64 Of oMainWnd
Define Font oBold Name "Arial" Size 0, -13 Bold
@ 050, 006  To  160, 230  Label  OEMToANSI( "[ Ajustes de Metas de Vendas ]" )  Of  _oDlgPto  Pixel

/*-----------------------------------------+
| Campos para ajustes de metas de vendas   |
+-----------------------------------------*/
   @ 060, 010 Say    OEMtoANSI( "Documento Origem" ) Font oBold  Pixel Color CLR_HBLUE
   @ 075, 010 Say    OEMtoANSI( "Mês" ) Font oBold  Pixel Color CLR_HBLUE
   @ 090, 010 Say    OEMtoANSI( "Ano" ) Font oBold  Pixel Color CLR_HBLUE
   @ 105, 010 Say    OEMtoANSI( "Descrição" ) Font oBold  Pixel Color CLR_HBLUE
   @ 120, 010 Say    OEMtoANSI( "Taxa de Conversão do Dolar?" ) Font oBold  Pixel Color CLR_HBLUE
   @ 135, 010 Say    OEMtoANSI( "Documento Destino (sugestão)" ) Font oBold  Pixel Color CLR_HBLUE

   @ 060, 115 MSGet  oGDocOri  Var cDocOri  F3 "SCT" Valid VldDocO( cDocOri ) Picture "@9" Size 050, 008 Of _oDlgPto Pixel
   @ 075, 115 MSGet  oGMes     Var cMes     Valid VldMes()  Picture "99"   Size 025, 008 Of _oDlgPto Pixel
   @ 090, 115 MSGet  oGAno     Var cAno     Valid VldAno()  Picture "9999" Size 025, 008 Of _oDlgPto Pixel
   @ 105, 115 MSGet  oGDescr_  Var cDescr_  Valid VldDsc()  Picture "@!"   Size 100, 008 Of _oDlgPto Pixel
   @ 120, 115 MSGet  oGTxDlr   Var nTxDlr   Valid VldTax()  Picture "@E 999,999.9999" Size 050, 008 Of _oDlgPto Pixel
   @ 135, 115 MSGet  oGDocDst  Var cDocDst  Valid VldDoc()  Picture "@9" Size 050, 008 Of _oDlgPto Pixel

   Activate MSDialog _oDlgPto Center On Init EnchoiceBar( _oDlgPto, { || _nOpcao := 1, _oDlgPto:End() }, { || _oDlgPto:End() } )

   /*--[ Enchoice Bar ]-------------------+
   | _nOpcao == 1 --> Botao [ Ok ]        |
   | _nOpcao == 0 --> Botao [ Cancelar ]  |
   +-------------------------------------*/
   If _nOpcao == 1
      If MsgYesNo( OEMToANSI( "Confirma o Ajuste de Metas?" ), OEMToANSI( "Confirmação" ) )
         GravaSCT()
      EndIf
   EndIf

RestArea( aArea )
Return( Nil )

/*======================================================================================+
| Funcao Estatica ....:   GravaSCT()                                                    |
| Autor...............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   30/07/2019                                                    |
| Descricao / Objetivo:   Funcao estatica que atualiza a taxa do dolar e faz copia do   |
|                         cadastro de metas de vendas (SCT)                             |
| Doc. Origem.........:   MIT044 - Ajuste de Metas.                                     |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
Static Function GravaSCT()
Local aArea := GetArea()
Local aSCT_ := {}
Local aAux

DbSelectArea( "SCT" )
DbSetOrder( 1 ) // CT_FILIAL + CT_DOC + CT_SEQUEN
If DbSeek( xFilial( "SCT" ) + cDocOri )
   /*--------------------------------------------------------------------------------------------------+
   | Trecho que realiza a copia do Documento Origem para ser replicada para outro Documento (destino). |
   +--------------------------------------------------------------------------------------------------*/
   Do While ( SCT->( CT_FILIAL + CT_DOC ) ==  xFilial( "SCT" ) + cDocOri ) .and. .not. SCT->( EoF() ) 
      aAux := {}
      For nX := 1 to SCT->( fCount() )
          aAdd( aAux, FieldGet( nX ) )
      NexT
      aAdd( aSCT_, aAux )
      SCT->( DbSkip() )
   EndDo

   /*----------------------------------------------------------------------------+
   | Trecho que realiza a gravacao do Documento Destino a partir da array aSCT_. |
   +----------------------------------------------------------------------------*/
   For nX := 1 to Len( aSCT_ )
       RecLock( "SCT", .T. )

       /*------------------------------------------+
       | Grava todos os campos da estrutura de SCT |
       +------------------------------------------*/
       For nY := 1 to Len( aSCT_[ nX ] )
           SCT->( FieldPut( nY, aSCT_[ nX ][ nY ] ) )
       NexT

       /*----------------------------------------------------------------+
       | Grava o codigo do documento destino contido na variavel cDocDst |
       +----------------------------------------------------------------*/
       SCT->CT_DOC := cDocDst

       /*-------------------------------------------------------------------+
       | Grava a descricao do documento destino contido na variavel cDescr_ |
       +-------------------------------------------------------------------*/
       SCT->CT_DESCRI := cDescr_

       /*------------------------------------------------------------------+
       | Grava a taxa-meta no documento destino contido na variavel nTxDlr |
       +------------------------------------------------------------------*/
       SCT->CT_XTAXMET := nTxDlr

       /*-------------------------------------------------------------+
       | Se a moeda for dolar (CT_MOEDA igual a 2) converte a cotacao |
       | do campo CT_XDOLAR com a cotacao da variavel xTxDlr.         |
       +-------------------------------------------------------------*/
       If SCT->CT_MOEDA == 2
          SCT->CT_VALOR := SCT->CT_XDOLAR * nTxDlr
       EndIF

       SCT->( MSUnLock() )
   NexT

   ConfirmSX8() // Grava o proximo codigo do campo CT_DOC.

EndIf

RestArea( aArea )
Return( Nil )

/*======================================================================================+
| Funcao Estatica ....:   VldDocO()                                                     |
| Autor...............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   30/07/2019                                                    |
| Descricao / Objetivo:   Funcao estatica que valida o mes digitado.                    |
| Doc. Origem.........:   MIT044 - Ajuste de Metas.                                     |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
Static Function VldDocO()
Local aArea := GetArea()
Local lRet  := .T.

If Empty( cDocOri )
   MsgInfo( OEMToANSI( "Campo Documento Origem deve ser preenchido." ), OEMToANSI( "Documento Origem" ) )
   lRet := .F.
Else
   cDocOri := StrZero( Val( cDocOri ), TamSX3("CT_DOC")[1] )
   DbSelectArea( "SCT" )
   DbSetOrder( 1 ) // CT_FILIAL + CT_DOC + CT_SEQUEN
   If .not. DbSeek( xFilial( "SCT" ) + cDocOri )
      MsgInfo( OEMToANSI( "Documento de Metas de Vendas não encontrado." ), OEMToANSI( "Documento Origem" ) )
      lRet := .F.
   EndIf
EndIf

RestArea( aArea )
Return( lRet )

/*======================================================================================+
| Funcao Estatica ....:   VldMes()                                                      |
| Autor...............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   30/07/2019                                                    |
| Descricao / Objetivo:   Funcao estatica que valida o mes digitado.                    |
| Doc. Origem.........:   MIT044 - Ajuste de Metas.                                     |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
Static Function VldMes()
Local aArea := GetArea()
Local lRet  := .T.
Local lMes  := .F.
Local cFil_ := ""

If .not. Empty( cMes )
   If cMes <= "00" .or. cMes >= "13"
      MsgInfo( OEMToANSI( "Mês inválido" ), OEMToANSI( "Mês" ) )
      lRet := .F.
   Else
      DbSelectArea( "SCT" )
      DbSetOrder( 1 ) // CT_FILIAL + CT_DOC + CT_SEQUEN
      If DbSeek( xFilial( "SCT" ) + cDocOri )
         cFil_ := xFilial( "SCT" )

         Do While ( xFilial( "SCT" ) + SCT->CT_DOC )  == ( cFil_ + cDocOri ) .and. .not. SCT->( EoF())
            If Left( SCT->CT_XMMAAAA, 2 ) # cMes
               SCT->( DbSkiP() ) 
            Else
               lMes := .T.
               ExiT
            EndIf
         EndDo

         If .not. lMes // Nao achei o mes na Meta de Vendas Origem
            MsgInfo( OEMToANSI( "Mês não correspondente à Meta de Vendas Origem." ), OEMToANSI( "Mês" ) )
            lRet := .F.
         Else // Achei o mes na Meta de Vendas Origem
            lRet := .T.
         EndIf
      EndIf

   EndIf
Else
   MsgInfo( OEMToANSI( "Mês deve ser preenchido" ), OEMToANSI( "Mês" ) )
   lRet := .F.
EndIf

RestArea( aArea )
Return( lRet )

/*======================================================================================+
| Funcao Estatica ....:   VldAno()                                                      |
| Autor...............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   30/07/2019                                                    |
| Descricao / Objetivo:   Funcao estatica que valida o ano digitado.                    |
| Doc. Origem.........:   MIT044 - Ajuste de Metas.                                     |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
Static Function VldAno()
Local aArea := GetArea()
Local lRet  := .T.
Local lAno  := .F.
Local cFil_ := ""

If .not. Empty( cAno )
   DbSelectArea( "SCT" )
   DbSetOrder( 1 ) // CT_FILIAL + CT_DOC + CT_SEQUEN
   If DbSeek( xFilial( "SCT" ) + cDocOri )
      cFil_ := xFilial( "SCT" )

      Do While ( xFilial( "SCT" ) + SCT->CT_DOC )  == ( cFil_ + cDocOri ) .and. .not. SCT->( EoF())
         If Right( SCT->CT_XMMAAAA, 4 ) # cAno
            SCT->( DbSkiP() )
         Else
            lAno := .T.
            ExiT
         EndIf
      EndDo

      If .not. lAno // Nao achei o ano na Meta de Vendas Origem
         MsgInfo( OEMToANSI( "Ano não correspondente à Meta de Vendas Origem." ), OEMToANSI( "Ano" ) )
         lRet := .F.
      Else // Achei o ano na Meta de Vendas Origem
         lRet := .T.
      EndIf

   EndIf
Else
   MsgInfo( OEMToANSI( "Ano deve ser preenchido." ), OEMToANSI( "Ano" ) )
   lRet := .F.
EndIf

RestArea( aArea )
Return( lRet )

/*======================================================================================+
| Funcao Estatica ....:   VldTax()                                                      |
| Autor...............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   30/07/2019                                                    |
| Descricao / Objetivo:   Funcao estatica que valida o ano digitado.                    |
| Doc. Origem.........:   MIT044 - Ajuste de Metas.                                     |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
Static Function VldTax()
Local aArea := GetArea()
Local lRet  := .T.

If Empty( nTxDlr )
   MsgInfo( OEMToANSI( "Taxa do Dólar deve ser preenchido." ), OEMToANSI( "Taxa do Dólar" ) )
   lRet := .F.
EndIf

RestArea( aArea )
Return( lRet )

/*======================================================================================+
| Funcao Estatica ....:   VldDoc( _cDoc  )                                              |
| Autor...............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   30/07/2019                                                    |
| Descricao / Objetivo:   Funcao estatica que valida o documento digitado.              |
| Doc. Origem.........:   MIT044 - Ajuste de Metas.                                     |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
Static Function VldDoc()
Local aArea := GetArea()
Local lRet  := .T.

_cDoc := StrZero( Val( cDocDst ), TamSX3("CT_DOC")[1] )
DbSelectArea( "SCT" )
DbSetOrder( 1 ) // CT_FILIAL + CT_DOC + CT_SEQUEN
If DbSeek( xFilial( "SCT" ) + cDocDst )
   MsgInfo( OEMToANSI( "Documento de Metas de Vendas existente." ), OEMToANSI( "Documento Destino" ) )
   lRet := .F.
EndIf

RestArea( aArea )
Return( lRet )

/*======================================================================================+
| Funcao Estatica ....:   VldDsc()                                                      |
| Autor...............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   12/08/2019                                                    |
| Descricao / Objetivo:   Funcao estatica que valida a descricao do documento destino.  |
| Doc. Origem.........:   MIT044 - Ajuste de Metas.                                     |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
Static Function VldDsc()
Local aArea := GetArea()
Local lRet  := .T.

If Empty( cDescr_ )
   MsgInfo( OEMToANSI( "A Descrição do Documento Destino deve ser preenchida." ), OEMToANSI( "Descrição Docto. Destino" ) )
   lRet := .F.
EndIf

RestArea( aArea )
Return( lRet )

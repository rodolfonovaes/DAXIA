#include "protheus.ch"	
#include "totvs.ch"
#include "fileio.ch"
/*======================================================================================+
| Programa............:   DX_AjuMt2.prw                                                 |
| Autor...............:   Totvs Ibirapuera                                              |
| Data................:   12/04/2022                                                    |
| Descricao / Objetivo:   Programa-fonte com diversas funcoes especificas de ajustes de |
|                         metas do cadastro SCT.                                        |
| Doc. Origem.........:   MIT044 - Ajuste de Metas.                                     |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
User Function DXAjMt2()
Local    aArea   := GetArea()
Local    _oDlgPto
Local    oBold
Local    oGDocOri
Local    _nOpcao := 0

Private  cDocOri := Space( 09 )
Private  cDescr_ := Space( 40 )
Private  cMes    := Space( 02 )
Private  cAno    := Space( 04 )
Private  nTxDlr  := 0.0000
Private  cV1     := "      "
Private  cV2     := "      "

Define MSDialog _oDlgPto Title OEMToANSI( "* Troca Meta Vendedores" ) From 00,00 To 25, 64 Of oMainWnd
Define Font oBold Name "Arial" Size 0, -13 Bold
@ 050, 006  To  180, 230  Label  OEMToANSI( "[ Troca Meta Vendedores ]" )  Of  _oDlgPto  Pixel

/*-----------------------------------------+
| Campos para toca meta vendedores         |
+-----------------------------------------*/
   @ 060, 010 Say    OEMtoANSI( "Documento Origem" ) Font oBold  Pixel Color CLR_HBLUE
   
   @ 075, 010 Say    OEMtoANSI( "Vend Ori (Branco = Desconsidera)" ) Font oBold  Pixel Color CLR_HBLUE
   @ 090, 010 Say    OEMtoANSI( "Vend Dest (Branco = Desconsidera)" ) Font oBold  Pixel Color CLR_HBLUE


   @ 060, 123 MSGet  oGDocOri  Var cDocOri  F3 "SCT" Valid VldDocO() Picture "@9" Size 050, 008 Of _oDlgPto Pixel
   @ 075, 123 MSGet  oGV1     Var cV1   F3 "SA3" Valid VldV1() Picture "@9" Size 050, 008 Of _oDlgPto Pixel
   @ 090, 123 MSGet  oGV2     Var cV2   F3 "SA3" Valid VldV2() Picture "@9" Size 050, 008 Of _oDlgPto Pixel

   Activate MSDialog _oDlgPto Center On Init EnchoiceBar( _oDlgPto, { || _nOpcao := 1, _oDlgPto:End() }, { || _oDlgPto:End() } )

   /*--[ Enchoice Bar ]-------------------+
   | _nOpcao == 1 --> Botao [ Ok ]        |
   | _nOpcao == 0 --> Botao [ Cancelar ]  |
   +-------------------------------------*/
   If _nOpcao == 1
      If MsgYesNo( OEMToANSI( "Confirma a toca de vendedores?" ), OEMToANSI( "Confirmação" ) )
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
Local Nx,Ny,Nz

DbSelectArea( "SCT" )
DbSetOrder( 3 ) // CT_FILIAL + CT_DOC + CT_SEQUEN
If DbSeek( xFilial( "SCT" ) + cDocOri)
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

   dbSetOrder(1)

   /*----------------------------------------------------------------------------+
   | Trecho que realiza a gravacao do Documento Destino a partir da array aSCT_. |
   +----------------------------------------------------------------------------*/
   lFirst := .T.
   For nX := 1 to Len( aSCT_ )
      If cV1 <> "      " .and. cV2 <> "      "

         //Primeiro apaga o destino (cV2)
         If lFirst
            For nZ := 1 to Len( aSCT_ )
               If aSCT_[nZ,8] == cV2
                  lAchou := dbSeek(xFilial("SCT") + cDocOri + aSCT_[nZ,15] ) 
                  If lAchou
                     Reclock ("SCT",.F.)
                     dbDelete()
                     msUnlock()
                  ENDIF
               ENDIF
            NEXT
            lFirst := .F.
         Endif

         //Depois altera o cV1 para cV2      
         
         If aSCT_[nx,8] == cV1
            lAchou := dbSeek(xFilial("SCT") + cDocOri + aSCT_[nX,15] ) 
            Reclock ("SCT",!lAchou)

            /*------------------------------------------+
            | Grava todos os campos da estrutura de SCT |
            +------------------------------------------*/
            For nY := 1 to Len( aSCT_[ nX ] )
               SCT->( FieldPut( nY, aSCT_[ nX ][ nY ] ) )
            NexT

            /*----------------------------------------------------------------+
            | Grava o codigo do vendedor destino contido na variavel cV2      |
            +----------------------------------------------------------------*/
            SCT->CT_VEND := cV2

            SCT->( MSUnLock() )

         Endif
      EndIf
   NexT


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
| Funcao Estatica ....:   VldV1( _cVend )                                              |
| Autor...............:   Totvs Ibirapuera                                              |
| Data................:   11/04/2022                                                    |
| Descricao / Objetivo:   Funcao estatica que valida o vendedor  digitado.              |
| Doc. Origem.........:   MIT044 - Ajuste de Metas.                                     |
| Solicitante.........:   Liliam                                                        |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
Static Function VldV1()
Local aArea := GetArea()
Local lRet  := .T.

_cVend1 := StrZero( Val( cV1 ), TamSX3("A3_COD")[1] )
DbSelectArea( "SA3" )
DbSetOrder( 1 ) 
If !DbSeek( xFilial( "SA3" ) + _cVend1 )
   If !Empty(cV1)
      MsgInfo( OEMToANSI( "Vendedor Origem não existe" ), OEMToANSI( "Vendedor Origem" ) )
      lRet := .F.
   Endif
EndIf

RestArea( aArea )
Return( lRet )

Static Function VldV2()
Local aArea := GetArea()
Local lRet  := .T.

_cVend2 := StrZero( Val( cV2 ), TamSX3("A3_COD")[1] )
DbSelectArea( "SA3" )
DbSetOrder( 1 ) 
If !DbSeek( xFilial( "SA3" ) + _cVend2 )
   If !Empty(cV2)
      MsgInfo( OEMToANSI( "Vendedor Destino não existe" ), OEMToANSI( "Vendedor Destino" ) )
      lRet := .F.
   Endif
EndIf

If (Empty(cV1) .and. !Empty(cV2)) .or. (Empty(cV2) .and. !Empty(cV1))
   MsgInfo( OEMToANSI( "Não pode preencher um vendedor e deixar o outro em branco" ), OEMToANSI( "Vendedor Origem / Destino" ) )
   lRet := .F.
EndIf


RestArea( aArea )
Return( lRet )




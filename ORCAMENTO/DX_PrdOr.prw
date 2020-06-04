#Include "Protheus.ch"	
#Include "Totvs.ch"
#Include "FileIO.ch"

/*======================================================================================+
| Programa............:   DX_PrdOr.prw                                                  |
| Autor...............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   07/08/2019                                                    |
| Descricao / Objetivo:   Programa-fonte com diversas funcoes especificas de Perda de   |
|                         Orcamento.                                                    |
| Doc. Origem.........:   MIT044 - Perda de Orcamento.                                  |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com. Ltda.                              |
| Obs.................:                                                                 |
+======================================================================================*/

/*======================================================================================+
| Funcao de Usuario ..:   DXDcMt( cCodMot )                                             |
| Autor...............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   07/08/2019                                                    |
| Descricao / Objetivo:   Funcao de usuario para exibir a descricao do Motivo de Perda. |
| Doc. Origem.........:   MIT044 - Perda de Orcamento.                                  |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com. Ltda.                              |
| Obs.................:                                                                 |
+======================================================================================*/
User Function DXDcMt()
Local aArea  := GetArea()
Local cDescr := Space( 40 )

If .not. Empty( M->CK_XMOTIVO )
   DbSelectArea( "SZ8" )
   DbSetOrder( 1 ) // Z8_FILIAL + Z8_CODIGO

   If DbSeek( xFilial( "SZ8" ) + M->CK_XMOTIVO ) 
      cDescr := SZ8->Z8_MOTIVO
   EndIf

EndIf

RestArea( aArea )
Return( cDescr )

/*======================================================================================+
| Funcao de Usuario ..:   DXVldOrc()                                                    |
| Autor...............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   13/08/2019                                                    |
| Descricao / Objetivo:   Funcao de usuario para validar os dados do cadastro de Orca-  |
|                         mentos.                                                       |
| Doc. Origem.........:   MIT044 - Perda de Orcamento.                                  |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com. Ltda.                              |
| Obs.................:   Funcao chamada no ponto de entrada MT415EFT.prw               |
+======================================================================================*/
User Function DXVldOrc()
Local aArea    := GetArea()
Local lEfetiva := .F.
Local lAberto  := .F.
Local cOrcam   := SCJ->( CJ_FILIAL + CJ_NUM )
Local cMtFech  := SuperGetMV( "ES_MOTFECH",, "000001" )
Local cMtAber  := SuperGetMV( "ES_MOTABRT",, "000000" )

If SCJ->CJ_STATUS == "P"
   MsgInfo( OEMToANSI( "Não é permitido efetivar Orçamento de Perda (itens com diversos motivos de perda)." ),;
            OEMToANSI( "* Efetivação Orçamento" ) )
Else
   /*-------------------------------------------------+
   | Busca os itens do orcamento (SCK) para checar se | 
   | possui itens em aberto.                          |
   +-------------------------------------------------*/
   DbSelectArea( "SCK" )
   DbSetOrder( 1 ) // CK_FILIAL + CK_NUM + CK_ITEM + CK_PRODUTO
   If DbSeek( cOrcam )
      Do While SCK->( CK_FILIAL + CK_NUM ) == cOrcam .and. .not. SCK->( EoF() )
         If cMtAber$SCK->CK_XMOTIVO // Se o campo CK_MOTIVO contem o codigo de motivo "EM ABERTO" do item.
            lAberto := .T.
            ExiT
         Else
            SCK->( DbSkiP() )
         EndIf
      EndDo

      If lAberto // Existem itens "EM ABERTO"
         MsgInfo( OEMToANSI( "Existe(m) item(ns) do orçamento " + SCJ->( CJ_FILIAL + "/" + CJ_NUM ) + " EM ABERTO." ),;
                  OEMToANSI( "* Efetivação Orçamento" ) )
      Else // O orcamento nao possui itens "EM ABERTO"
         If DbSeek( cOrcam )
            Do While SCK->( CK_FILIAL + CK_NUM ) == cOrcam .and. .not. SCK->( EoF() )
               If cMtFech$SCK->CK_XMOTIVO // Se o campo CK_MOTIVO contem o codigo de motivo "FECHADO" do item.
                  lEfetiva := .T.
                  ExiT
               Else
                  SCK->( DbSkiP() )
               EndIf
            EndDo
         EndIf

         If .not. lEfetiva
            MsgInfo( OEMToANSI( "Todos itens do orçamento " + SCJ->( CJ_FILIAL + "/" + CJ_NUM ) + " sem motivo de fechamento." ),;
                     OEMToANSI( "* Efetivação Orçamento" ) )
         EndIf
   
      EndIf
   EndIf
EndIf

RestArea( aArea )
Return( lEfetiva )

/*======================================================================================+
| Funcao de Usuario ..:   DMnaCols( nLin )                                              |
| Autor...............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   13/08/2019                                                    |
| Descricao / Objetivo:   Funcao de usuario para dar manutencao na array publica _aCols |
|                         para que apenas os itens fechados ou aprovados.               |
|                         Para produtos nao aprovados, devera' digitar uma justificati- |
|                         va por nao ter ido o item para o Pedido de Vendas.            |
| Doc. Origem.........:   MIT044 - Perda de Orcamento.                                  |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com. Ltda.                              |
| Obs.................:   Funcao chamada no ponto de entrada MTA416PV.prw               |
+======================================================================================*/
User Function DMnaCols( nLin )
Local aArea   := GetArea()
Local nPosDel := 0
Local cMtFech := SuperGetMV( "ES_MOTFECH",, "000001" )

nPosDel := Len( _aCols[ nLin ] )

If .not. cMtFech$SCK->CK_XMOTIVO .And. !Empty(SCK->CK_PRODUTO) 
   
   /*-------------------------------------------------------+
   | Se o campo CK_MOTIVO nao contem o codigo de motivo de  | 
   | fechamento do item, e' excluido o item do _aCols e in- |
   | sere a justificativa do item nao fechado ou reprovado. |
   +-------------------------------------------------------*/
   _aCols[nLin][nPosDel] := .T.
   /* InsJust() */  // Funcao obsoleta devido a uma nova definicao sobre as justificativas dos itens (19/09/2019).
EndIf

RestArea( aArea )
Return( Nil )

/*======================================================================================+
| Funcao Estatica ....:   InsJust()                                                     |
| Autor...............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   13/08/2019                                                    |
| Descricao / Objetivo:   Funcao de usuario para dar manutencao no campo "Justificativa"|
|                         (CK_XJUSTIF) onde deve ser digitado o motivo de nao fechamen- |
|                         to ou reprovacao do item.                                     |
| Doc. Origem.........:   MIT044 - Perda de Orcamento.                                  |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com. Ltda.                              |
| Obs.................:   Funcao obsoleta devido a uma nova definicao sobre as          |
|                         justificativas dos itens (19/09/2019).                        |
+======================================================================================*/
Static Function InsJust() 
Local aArea := GetArea()
Local    _nOpcao := 0
Local    oBold
Local    oGcFilOr
Local    oGItem
Local    oGCdProd
Local    oGDtEmis
Local    oGCdCli
Local    oGcQtde
Local    oGcPrVen
Local    oGcTotal
Local    oGcMotiv
Local    oGcJust
Local    cFilOrc := SCJ->CJ_FILIAL + " / " + SCJ->CJ_NUM
Local    cDtEmis := DtoC( SCJ->CJ_EMISSAO )
Local    cCdCli  := SCJ->CJ_CLIENTE + " / " + SCJ->CJ_LOJA + " - " + AllTrim( GetAdvFVal( "SA1", "A1_NOME", xFilial( "SA1" ) + SCJ->CJ_CLIENTE + SCJ->CJ_LOJA, 1, "CLIENTE NAO ENCONTRADO" ) )
Local    cItem   := SCK->CK_ITEM
Local    cCdProd := AllTrim( SCK->CK_PRODUTO ) + " / " + AllTrim( GetAdvFVal( "SB1", "B1_DESC", xFilial( "SB1" ) + SCK->CK_PRODUTO, 1, "PRODUTO NAO ENCONTRADO" ) )
Local    cQtde   := AllTrim( Transform( SCK->CK_QTDVEN, "@E 999,999,999.99"   ) )  
Local    cPrVen  := AllTrim( Transform( SCK->CK_PRCVEN, "@E 999,999,999.9999" ) )
Local    cTotal  := AllTrim( Transform( SCK->CK_VALOR,  "@E 999,999,999.99"   ) )
Local    cMotiv  := SCK->CK_XMOTIVO + " / " + AllTrim( GetAdvFVal( "SZ8", "Z8_MOTIVO", xFilial( "SZ8" ) + SCK->CK_XMOTIVO, 1, "MOTIVO NAO ENCONTRADO" ) )
Local    cJust   := Space( 250 )
Private  _oDlgPto

Define MSDialog _oDlgPto Title OEMToANSI( "* Justificativa" ) From 00,00 To 25, 80 Of oMainWnd Style DS_MODALFRAME
Define Font oBold Name "Arial" Size 0, -13 Bold
@ 050, 006  To  090, 310  Label  OEMToANSI( "[ Informações do Orçamento ]" ) Of  _oDlgPto  Pixel
@ 095, 006  To  155, 310  Label  OEMToANSI( "[ Informações do Produto ]"   ) Of  _oDlgPto  Pixel
@ 160, 006  To  185, 310  Label  OEMToANSI( "[ Justificativa ]"            ) Of  _oDlgPto  Pixel

/*-----------------------------------------------------------------------+
| Campos para visualizacao do orcamento e preenchimento da justificativa |
+-----------------------------------------------------------------------*/
@ 060, 010 Say    OEMtoANSI( "Filial/Orçamento" ) Font oBold  Pixel Color CLR_HBLUE
@ 060, 160 Say    OEMtoANSI( "Data Emissão"     ) Font oBold  Pixel Color CLR_HBLUE
@ 075, 010 Say    OEMtoANSI( "Cliente"          ) Font oBold  Pixel Color CLR_HBLUE
@ 105, 010 Say    OEMtoANSI( "Item"             ) Font oBold  Pixel Color CLR_HBLUE
@ 105, 070 Say    OEMtoANSI( "Código/Produto"   ) Font oBold  Pixel Color CLR_HBLUE
@ 120, 010 Say    OEMtoANSI( "Qtde"             ) Font oBold  Pixel Color CLR_HBLUE
@ 120, 095 Say    OEMtoANSI( "Prc. Venda"       ) Font oBold  Pixel Color CLR_HBLUE
@ 120, 210 Say    OEMtoANSI( "Vlr. Total"       ) Font oBold  Pixel Color CLR_HBLUE
@ 135, 010 Say    OEMtoANSI( "Motivo"           ) Font oBold  Pixel Color CLR_HBLUE 

@ 060, 070 MSGet  oGcFilOr  Var cFilOrc   Size 045, 008 When .F. Of _oDlgPto Pixel
@ 060, 210 MSGet  oGDtEmis  Var cDtEmis   Size 035, 008 When .F. Of _oDlgPto Pixel
@ 075, 050 MSGet  oGCdCli   Var cCdCli    Size 200, 008 When .F. Of _oDlgPto Pixel
@ 105, 030 MSGet  oGItem    Var cItem     Size 010, 008 When .F. Of _oDlgPto Pixel
@ 105, 125 MSGet  oGCdProd  Var cCdProd   Size 170, 008 When .F. Of _oDlgPto Pixel
@ 120, 030 MSGet  oGCQtde   Var cQtde     Size 050, 008 When .F. Of _oDlgPto Pixel
@ 120, 135 MSGet  oGCPrVen  Var cPrVen    Size 060, 008 When .F. Of _oDlgPto Pixel
@ 120, 240 MSGet  oGCTotal  Var cTotal    Size 050, 008 When .F. Of _oDlgPto Pixel
@ 135, 035 MSGet  oGcMotiv  Var cMotiv    Size 120, 008 When .F. Of _oDlgPto Pixel
@ 170, 010 MSGet  oGcJust   Var cJust     Picture "@!" Size 100, 008 Of _oDlgPto Pixel

Activate MSDialog _oDlgPto Center On Init EnchoiceBar( _oDlgPto, { || _nOpcao := 1, u_VldJust( cJust ) /*_oDlgPto:End()*/ }, { || u_VldCanc() /*_oDlgPto:End()*/ } )

   /*--[ Enchoice Bar ]-------------------+
   | _nOpcao == 1 --> Botao [ Ok ]        |
   | _nOpcao == 0 --> Botao [ Cancelar ]  |
   +-------------------------------------*/
   If _nOpcao == 1
      RecLock( "SCK", .F. )
      Replace SCK->CK_XJUSTIF with cJust  // Grava a justificativa de perda do item do orcamento.
      SCK->( MSUnlock() )
   EndIf

RestArea( aArea )
Return( Nil )

/*======================================================================================+
| Funcao Estatica ....:   VldCanc()                                                     |
| Autor...............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   13/08/2019                                                    |
| Descricao / Objetivo:   Funcao de usuario para validar o campo "Justificativa" - nao  |
|                         pode ser cancelado sem que o usuario preencha a justificativa |
|                         de perda do orcamento.                                        |
| Doc. Origem.........:   MIT044 - Perda de Orcamento.                                  |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com. Ltda.                              |
| Obs.................:                                                                 |
+======================================================================================*/
User Function VldCanc()
Local aArea := GetArea()
Local lRet := .F.

MsgInfo( OEMToANSI( "Não é permitido cancelar até o preenchimento do campo Justificativa de Perda de Orçamento." ), OEMToANSI( "* Cancelar Justificativa" ) )

RestArea( aArea )
Return( lRet )

/*======================================================================================+
| Funcao Estatica ....:   VldJust( cJust_ )                                             |
| Autor...............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   13/08/2019                                                    |
| Descricao / Objetivo:   Funcao de usuario para validar o campo "Justificativa" - nao  |
|                         pode deixar de ser preenchido a justificativa de perda do     | 
|                         orcamento.                                                    |
| Doc. Origem.........:   MIT044 - Perda de Orcamento.                                  |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com. Ltda.                              |
| Obs.................:                                                                 |
+======================================================================================*/
User Function VldJust( cJust_ )
Local aArea := GetArea()
Local lRet := .F.

If Empty( cJust_ )
   MsgInfo( OEMToANSI( "O campo Justificativa de Perda de Orçamento deve ser preenchido." ), OEMToANSI( "* Campo Justificativa" ) )
Else
   lRet := .T.
   _oDlgPto:End()
EndIf

RestArea( aArea )
Return( lRet )

/*======================================================================================+
| Funcao de Usuario ..:   DelItem()                                                     |
| Autor...............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   13/08/2019                                                    |
| Descricao / Objetivo:   Funcao de usuario para validar a exclusao da linha de itens   |
|                         (aCols) do Pedido de Vendas originados do cadastro de Orca-   | 
|                         mentos (SCJ e SCK).                                           |
| Doc. Origem.........:   MIT044 - Perda de Orcamento.                                  |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com. Ltda.                              |
| Obs.................:                                                                 |
+======================================================================================*/
User Function DelItem()
Local aArea := GetArea()
Local nPos  := Len( aCols[n] )  // Busca a quantidade de elementos do aCols MATA410.
Local lRet  := .F.

If IsInCallStack( "MATA416" ) // Verifica se o pedido de vendas foi originado do orcamento. Se foi, nao e' permitido exclusao nem recuperacao dos itens do aCols.
   MsgInfo( OEMToANSI( "Não é permitido a exclusão nem recuperação de itens do Pedido de Venda originados do Orçamento." ), OEMToANSI( "Recuperação/Exclusão de Itens" ) )
   iIf( aCols[n][nPos],  aCols[n][nPos] := .F., aCols[n][nPos] := .T. )
   oGetDad:Refresh()
Else
   lRet := .T.
EndIf

RestArea( aArea )
Return( lRet )

/*======================================================================================+
| Funcao de Usuario ..:   SCK_Just( cMotivo )                                           |
| Autor...............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   19/09/2019                                                    |
| Descricao / Objetivo:   Funcao de usuario para insercao de justificativa de acordo c/ |
|                         os parametros ES_MTABRT e ES_MOTFECH.                         | 
| Doc. Origem.........:   MIT044 - Perda de Orcamento.                                  |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com. Ltda.                              |
| Obs.................:                                                                 |
+======================================================================================*/
User Function SCK_Just()
Local  aArea    := GetArea()
Local  _nOpcao  :=  0
Local  cJust    :=  Space( TamSX3( "CK_XJUSTIF" )[1] )
Local  oBold
Local  oGJust
Local  cSemJust := SuperGetMV( "ES_MOTABRT",, "000000" ) + "|" + SuperGetMV( "ES_MOTFECH",, "000001" ) 
Private  _oDlgPto

If .not. M->CK_XMOTIVO$cSemJust
   Define MSDialog _oDlgPto Title OEMToANSI( "* Justificativa" ) From 000,000 To 012, 100 Of oMainWnd // Style DS_MODALFRAME
   Define Font oBold Name "Arial" Size 0, -13 Bold
   @ 035, 006  To  075, 380  Label  OEMToANSI( "[ Justificativa (máx. 30 caracteres) ]" )  Of  _oDlgPto  Pixel

   /*---------------------------+
   | Digitacao da Justificativa |
   +---------------------------*/
   @ 053, 010 Say    OEMtoANSI( "Justificativa" ) Font oBold  Pixel Color CLR_HBLUE
   @ 053, 055 MSGet  oGLote  Var cJust  Picture "@!" Size 300, 008 Of _oDlgPto Pixel
   Activate MSDialog _oDlgPto Center On Init EnchoiceBar( _oDlgPto, { || _nOpcao := 1, u_VldJust( cJust ) }, { || u_VldCanc() } )

   /*--[ Enchoice Bar ]-------------------+
   | _nOpcao == 1 --> Botao [ Ok ]        |
   | _nOpcao == 0 --> Botao [ Cancelar ]  |
   +-------------------------------------*/
EndIf

RestArea( aArea )
Return( cJust )


#Include "Protheus.CH"
#Include "RWMake.CH"
/*======================================================================================+
| Programa............:   WMSA150_PE.prw                                                |
| Autores ............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   21/08/2019                                                    |
| Descricao / Objetivo:   Ponto de entrada para a rotina padrao WSMA150.prw             |
| Doc. Origem.........:   Nenhum.                                                       |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
User Function WMSA150() // Sempre colocar o nome da rotina padrao para chamada do ponto de entrada
Local  aArea    :=  GetArea()
Local  aParam   :=  PARAMIXB
Local  xRet     :=  .T.
Local  oObj     :=  Nil
Local  cIdPonto :=  ""
Local  cIdModel :=  ""
Local  nOper    :=  0
Local  cCampo   :=  ""
Local  cTipo    :=  ""

/*--------------------------+
|  Se tiver parametro       |
+--------------------------*/
If aParam # Nil

   /*-----------------------------------+
   | Pega informacoes dos parametros    |
   +-----------------------------------*/
   oObj     := aParam[ 1 ]
   cIdPonto := aParam[ 2 ]
   cIdModel := aParam[ 3 ]
   
   If cIdPonto == "BUTTONBAR"
      xRet := {}
      aAdd( xRet, { "*Alterar Lote", "", { || AjustaLt() }, "Opcao de alteracao de lote do produto." } )
   EndIf
Else
   MsgInfo( "Sem ParamIXB - Contatar Administrador do Sistema.", "* Sem ParamIXB" )
EndIf

RestArea( aArea )
Return( xRet )

/*======================================================================================+
| Funcao Estatica ....:   AjustaLt()                                                    |
| Autores ............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   23/08/2019                                                    |
| Descricao / Objetivo:   Funcao estatica que realiza a alteracao do lote do produto.   |
| Doc. Origem.........:   MIT044 - Permissao informar lote na execucao servico de WMS.  |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
Static Function AjustaLt()
Local aArea   := GetArea()
Local lRet    := .T.
Local cFilDC5 := Left( DCF_FILIAL, 2 ) + Space( 2 )

/*-----------------------------------------------------+
| Verifica se a separacao pode ter o seu lote alterado |
| checando-se a tabela de servicos DC5, do WMS.        |
+-----------------------------------------------------*/
DbSelectArea( "DC5" ) // Tabela de Servicos do WMS
DbSetOrder( 1 ) // DC5_FILIAL + DC5_SERVIC + DC5_ORDEM
If DbSeek( cFilDC5 + DCF->DCF_SERVIC )
   If DC5->DC5_OPERAC # "3"
      MsgInfo( OEMToANSI( "Operação Inválida para troca de Lote." ), OEMToANSI( "* Operação" ) )
      lRet := .F.
   Else
      TrocaLot()
   EndIf
EndIf

RestArea( aArea )
Return( lRet )

/*======================================================================================+
| Funcao Estatica ....:   TrocaLot()                                                    |
| Autores ............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   23/08/2019                                                    |
| Descricao / Objetivo:   Funcao estatica que realiza a selecao e alteracao do lote do  |
|                         do produto.                                                   |
| Doc. Origem.........:   MIT044 - Permissao informar lote na execucao servico de WMS   |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
Static Function TrocaLot()
Local  aArea    := GetArea()
Local  lRet     := .T.
Local  _nOpcao  :=  0
Local  _oDlgPto
Local  oBold
Local  oGLote
Local  oGLocal
Local  cLote_   := Space( TamSX3( "B8_LOTECTL" )[1] )
Local  cLocal_  := Space( TamSX3( "B8_LOCAL"   )[1] )
Local  cLotAnt  := iIf(.not. Empty( DCF->DCF_LOTECT ) , xFilial( "SB8" ) + DCF->( DCF_LOTECT + DCF_LOCAL + DCF_CODPRO ), "" )

Define MSDialog _oDlgPto Title OEMToANSI( "* Mudança de Lote" ) From 00,00 To 20, 64 Of oMainWnd
Define Font oBold Name "Arial" Size 0, -13 Bold
@ 050, 006  To  140, 230  Label  OEMToANSI( "[ Mudança de Lote ]" )  Of  _oDlgPto  Pixel

/*---------------------------------------------------------------+
| Digitacao do novo numero de lote (troca ou retirar o lote).    |
+---------------------------------------------------------------*/
@ 080, 010 Say    OEMtoANSI( "Lote" )    Font oBold  Pixel Color CLR_HBLUE
@ 095, 010 Say    OEMtoANSI( "Armazém" ) Font oBold  Pixel Color CLR_HBLUE

@ 080, 055 MSGet  oGLote    Var cLote_   F3 "SB8LOT"  Picture "@!" Size 050, 008 Of _oDlgPto Pixel
@ 095, 055 MSGet  oGLocal   Var cLocal_               Picture "@!" Size 010, 008 Of _oDlgPto Pixel

Activate MSDialog _oDlgPto Center On Init EnchoiceBar( _oDlgPto, { || _nOpcao := 1, _oDlgPto:End() }, { || _oDlgPto:End() } )

/*--[ Enchoice Bar ]-------------------+
| _nOpcao == 1 --> Botao [ Ok ]        |
| _nOpcao == 0 --> Botao [ Cancelar ]  |
+-------------------------------------*/
If _nOpcao == 1

   If VldLote( cLote_, cLocal_ ) 

      If MsgYesNo( OEMToANSI( "Confirma a Mudança de Lote?" ), OEMToANSI( "* Mudança de Lote" ) )
         /*--------------------------------------------------------------------+
         | Confirmacao de troca de lote - e' feita tudo neste trecho deste IF. |
         +--------------------------------------------------------------------*/

         /*----------------------------------------------------------------------------------------------------------+
         | Atualizacao do campo DCF_LOTECT e DCF_LOCAL com o conteudo da variavel cLote_ e cLocal_, respectivamente. |
         +----------------------------------------------------------------------------------------------------------*/
         DbSelectArea( "DCF" )
         RecLock( "DCF", .F. )
         Replace DCF->DCF_LOTECT with cLote_
         DCF->( MSUnLock() )

         /*---------------------------------------------------------------------------------------------------------------------+
         | Atualizacao do campo C9_LOTECTL usando os campo DCF_DOCTO e DCF_SERIE (Num PV e Sequencia do item, respectivamente). |
         +---------------------------------------------------------------------------------------------------------------------*/
         DbSelectArea( "SC9" )
         DbSetOrder( 9 ) // C9_FILIAL + C9_PEDIDO + C9_ITEM + C9_SEQUEN + C9_PRODUTO + C9_BLEST + C9_BLCRED
 
         If DbSeek( xFilial( "SC9" ) + DCF->( AllTrim( DCF_ID )  ) )
            While (xFilial('DCF') + SC9->C9_IDDCF == DCF->(DCF_FILIAL + DCF_ID))
               RecLock( "SC9", .F. )
               Replace SC9->C9_LOTECTL with cLote_
               SC9->( MSUnlock() )
               SC9->(DbSkip())
            EndDo
         EndIf

         /*---------------------------------------------------------------------------------------------------------------------+
         | Atualizacao do campo C6_LOTECTL usando os campo DCF_DOCTO e DCF_SERIE (Num PV e Sequencia do item, respectivamente). |
         +---------------------------------------------------------------------------------------------------------------------*/
         DbSelectArea( "SC6" )
         DbSetOrder( 1 ) // C6_FILIAL + C6_NUM + C6_ITEM C6_PRODUTO
 
         If DbSeek( xFilial( "SC6" ) + DCF->( AllTrim( DCF_DOCTO ) + AllTrim( DCF_SERIE ) ) )
            RecLock( "SC6", .F. )
            Replace SC6->C6_LOTECTL with cLote_
            SC6->( MSUnlock() )
         EndIf

         If .not. Empty( cLote_ + cLocal_ )
            /*-----------------------------------------------------------------+
            | Empenho do campo B8_EMPENHO com a quantidade do campo DCF_QUANT. |
            | Ja' esta' posicionado atraves da Consulta Padrao ou pela pesqui- |
            | na funcao estatica VldLote().                                    |
            +-----------------------------------------------------------------*/
            DbSelectArea( "SB8" )      
            RecLock( "SB8", .F. )
            Replace SB8->B8_EMPENHO with ( SB8->B8_EMPENHO + DCF->DCF_QUANT )
            SB8->( MSUnlock() )

            /*----------------------------------------------+
            | Retira o empenho do lote anterior do produto. |
            +----------------------------------------------*/
            If .not. Empty( cLotAnt ) // cLotAnt == xFilial( "SB8" ) + DCF->( DCF_LOTECT + DCF_LOCAL + DCF_CODPRO )
               DbSetOrder( 6 ) // B8_FILIAL + B8_LOTECTL + B8_LOCAL + B8_PRODUTO
               If DbSeek( cLotAnt )
                  RecLock( "SB8", .F. )
                  Replace SB8->B8_EMPENHO with ( SB8->B8_EMPENHO - DCF->DCF_QUANT )
                  SB8->( MSUnlock() ) 
               EndIf
            EndIf

         Else
            /*-------------------------------------------+
            | Retira o empenho do lote atual do produto. |
            +-------------------------------------------*/
            If .not. Empty( cLotAnt ) // cLotAnt == xFilial( "SB8" ) + DCF->( DCF_LOTECT + DCF_LOCAL + DCF_CODPRO )
               DbSelectArea( "SB8" )
               DbSetOrder( 6 ) // B8_FILIAL + B8_LOTECTL + B8_LOCAL + B8_PRODUTO
               If DbSeek( cLotAnt )
                  RecLock( "SB8", .F. )
                  Replace SB8->B8_EMPENHO with ( SB8->B8_EMPENHO - DCF->DCF_QUANT )
                  SB8->( MSUnlock() ) 
               EndIf
            EndIf
         EndIf
      Else
         lRet := .F.
      EndIf

   EndIf

EndIf

RestArea( aArea )
Return( lRet )

/*======================================================================================+
| Funcao Estatica ....:   VldLote( cLot, cLoc )                                         |
| Autores ............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   23/08/2019                                                    |
| Descricao / Objetivo:   Funcao estatica que valida os campos de preenchimento Lote e  |
|                         Local/Armazem.                                                |
| Doc. Origem.........:   MIT044 - Permissao informar lote na execucao servico de WMS   |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
Static Function VldLote( cLot, cLoc )
Local  aArea    := GetArea()
Local  lRet     := .F.
 
/*-----------------------------------------------------------------------------+
| Realiza a validacao do lote/local em nivel de quantidade e validade do lote. |
+-----------------------------------------------------------------------------*/ 
If .not. Empty( cLot + cLoc )
   DbSelectArea( "SB8" )
   DbSetOrder( 6 ) // B8_FILIAL + B8_LOTECTL + B8_LOCAL + B8_PRODUTO  
   If DbSeek( xFilial( "SB8" ) + cLot + cLoc + DCF->DCF_CODPRO )
      If SB8->B8_SALDO < DCF->DCF_QUANT
         MsgInfo( OEMToANSI( "Saldo insuficiente do lote para atender o item." ), OEMToANSI( "* Saldo Insuficiente" ) )
      ElseIf SB8->B8_DTVALID < dDataBase
         MsgInfo( OEMToANSI( "Lote com data de validade expirada." ), OEMToANSI( "* Data Validade Expirada" ) )
      Else
         lRet := .T.
      EndIf
   Else
      MsgInfo( OEMToANSI( "Lote e/ou Local não encontrado." ), OEMToANSI( "* Lote/Local" ) )
   EndIf
Else
   lRet := .T.
EndIf

RestArea( aArea )
Return( lRet )

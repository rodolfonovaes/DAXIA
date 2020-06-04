#Include "Protheus.CH"
#Include "RWMake.CH"
/*======================================================================================+
| Programa............:   M415GRV.prw                                                   |
| Autores ............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   23/09/2019                                                    |
| Descricao / Objetivo:   Ponto de entrada que realiza o tratamento dos campos do cadas-|
|                         tro SCJ (cabecalho do orcamento) e/ou SCK(itens do orcamento).|
| Doc. Origem.........:                                                                 |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
User Function M415Grv()
Local aArea   := GetArea()
Local lSemMot := .F.
Local cSemMot := SuperGetMV( "ES_MOTABRT",, "000000" )  + "|" + SuperGetMV( "ES_MOTFECH",, "000001" )

/*-------------------------------------------------------------------+
| Trecho que consiste se tem itens sem motivos (Abertos e/ou Fecha-  |
| dos) e, caso NAO tenham algum destes sai do laco e grava no campo  |
| M->CJ_STATS com "P" - de Orcamento de Perda.                       |
+-------------------------------------------------------------------*/
DbSelectArea( "SCK" ) // Itens do Orcamento
DbSetOrder( 1 ) // CK_FILIAL + CK_NUM + CK_ITEM + CK_PRODUTO
If DbSeek( SCJ->( CJ_FILIAL + CJ_NUM ) )
   Do While SCK->( CK_FILIAL + CK_NUM ) == SCJ->( CJ_FILIAL + CJ_NUM ) .and. SCK->( .not. EoF() )
      If SCK->CK_XMOTIVO$cSemMot // Registro cujo campo CK_XMOTIVO preenchido com "000000" ou "000001" (aberto ou fechado)
         lSemMot := .T.
         ExiT
      EndIf
      SCK->( DbSkiP() )
   EndDo
   If .not. lSemMot
      MsgInfo( OEMToANSI( "O orçamento " + SCJ->CJ_FILIAL + " / " + SCJ->CJ_NUM + " - todos os seus itens são de perda." ), OEMToANSI( "*Orçamento de Perda" ) )
      RecLock( "SCJ", .F. )
      Replace SCJ->CJ_STATUS with "P" // Status "P" de perda
      SCJ->( MSUnlock() )
   EndIf
EndIf

RestArea( aArea )
Return( Nil )
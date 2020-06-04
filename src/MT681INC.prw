#Include "Protheus.CH"
#Include "RWMake.CH"
/*======================================================================================+
| Programa............:   MT681INC.prw                                                  |
| Autores ............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   27/09/2019                                                    |
| Descricao / Objetivo:   Ponto de entrada MT681INC.                                    |
| Doc. Origem.........:   MIT044 - R01PT - Especificacao de Personalizacao - Apontamen- |
|                         to PCP MOD2 - item 20.                                        |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
User Function MT681INC()
Local aArea   := GetArea()
Local cMsg_   := OEMToANSI( "Função SB8Valid() não compilada. Contatar Administrador do Sistema." )
Local cTit_   := OEMToANSI( "* Apont. Validades" )
Local cUltOp  := ""
Local cKeySH6 := ""

/*------------------------------------------------------------+
| Funcao SB8Valid() encontrada no programa-fonte FORMLOTE.prw |
+------------------------------------------------------------*/

cUltOp  := u_UltOper() // Busca a ultima operacao do roteiro de processo PCP.

cKeySH6 := SC2->( C2_FILIAL + C2_NUM + C2_ITEM + C2_SEQUEN + Space( 3 ) + C2_PRODUTO ) + cUltOp 
DbSelectArea( "SH6" ) // Cadastro de Apontamentos da OP
DbSetOrder( 1 ) // H6_FILIAL + H6_OP + H6_PRODUTO + H6_OPERAC + H6_SEQ + DTOS(H6_DATAINI) + H6_HORAINI + DTOS(H6_DATAFIN) + H6_HORAFIN
If DbSeek( cKeySH6 )
   iIf( FindFunction( "U_SB8VALID" ), u_SB8Valid(), MsgAlert( cMsg_, cTit_ ) )
EndIf

RestArea( aArea )
Return( Nil )

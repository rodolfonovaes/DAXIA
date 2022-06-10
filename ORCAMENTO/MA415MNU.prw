#Include "Protheus.CH"
#Include "RWMake.CH"
#INCLUDE "FWMVCDEF.CH"
/*======================================================================================+
| Programa............:   MA415MNU.prw                                                  |
| Autores ............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   24/09/2019                                                    |
| Descricao / Objetivo:   Ponto de entrada que realiza a criacao de novas opcoes no bo- |
|                         tao [Outras Acoes] - rotina Orcamentos/MATA415.               |
| Doc. Origem.........:   MIT044                                                        |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
User Function MA415MNU()
Local aArea  := GetArea()
Local cUsers   := SupergetMV('ES_NIVMARG',.T.,'totvs.rnovaes')

If at(UPPER(Alltrim(UsrRetName( retcodusr() ))),UPPER(cUsers)) > 0 .Or. at(UPPER(Alltrim(UsrRetName( retcodusr() ))),UPPER('totvs.rnovaes')) > 0
    aAdd( aRotina, { "Margem Rentabilidade", "U_RntOrcDx()", 0 , 7, 0, Nil } ) 
    aAdd( aRotina, { "Margem Rentabilidade Item", "U_OrcRntIt()", 0 , 7, 0, Nil } )
    SetKey(VK_F5,{||U_RntOrcDx()})
    SetKey(VK_F6,{||U_OrcRntIt()})    
EndIf
aAdd( aRotina, { "*Imprimir", "U_DX_RELORC()", 0 , 7, 0, Nil } )   // Relatorio Grafico de Orcamentos
aAdd( aRotina, { "Consulta de Orçamentos", "U_DAXATU06()", 0 , 6, 0, Nil } )   // Consulta de Orçamentos

RestArea( aArea )
Return( aRotina )

#Include "Protheus.ch"
#Include "RWMake.ch"
#Include "FWBrowse.ch" // Header Browse do MVC
#Include "FWMVCDef.ch" // Header do MVC

/*======================================================================================+
| Programa............:   DX_CdAss.prw                                                  |
| Autor...............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   27/08/2019                                                    |
| Descricao / Objetivo:   Programa-fonte com diversas funcoes especificas de cadastro - |
|                         Cadastro de Assuntos x Descricoes.                            |
| Doc. Origem.........:   MIT044 - Consulta de Clientes com Geracao de Atividades.      |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
User Function DXCASS()
Local aArea := GetArea() 

AxCadastro( "SZA", OEMToANSI( "* Cadastro de Assuntos x Descrição" ), /*"U_DELMOT()"*/,,,,,,,,,,, )  

RestArea( aArea )
Return( Nil )

/*======================================================================================+
| Funcao de Usuario ..:   DelMot()                                                      |
| Autor...............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   08/08/2019                                                    |
| Descricao / Objetivo:   Funcao de usuario que consiste a possibilidade de exclusao do |
|                         Motivo. Se estiver em uso, nao permite a sua exclusao.        |
| Doc. Origem.........:   MIT044 - Motivos de Perda do Orcamento.                       |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/                        
//User Function DelMot()
//Local aArea := GetArea()
//Local lRet  := .F.

//DbSelectArea( "SCK" )
//DbSetOrder( 6 ) // CK_FILIAL + CK_XMOTIVO

//If DbSeek( xFilial( "SCK" ) + SZ8->Z8_CODIGO )
//   MsgInfo( OEMToANSI( "Exclusão não permitida. Motivo já usado no cadastro de Itens do Orçamento." ), OEMToANSI( "Exclusão Motivo" ) )
//Else
//   lRet := .T.
//EndIf

//RestArea( aArea )
//Return( lRet ) 

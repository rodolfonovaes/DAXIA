#Include "RWMake.ch"
#Include "FWBrowse.ch" // Header Browse do MVC
#Include "FWMVCDef.ch" // Header do MVC
#Include "TopConn.ch"
#Include "TbiConn.ch"
#Include "TbiCode.ch"
#Include "Protheus.ch"
#Include "Font.ch"
#Define  _ENTER  Chr( 13 ) + Chr( 10 )

/*======================================================================================+
| Programa............:   DX_GerAt.prw                                                  |
| Autor...............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   28/08/2019                                                    |
| Descricao / Objetivo:   Programa-fonte com diversas funcoes especificas da Consulta   |
|                         de clientes com geracao de atividade.                         |
| Doc. Origem.........:   MIT044 - Consulta de Clientes com Geracao de Atividades.      |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
User Function DX_GerAt()
Local   aArea      :=  GetArea()
Local   oOk        := LoadBitMap( GetResources(), "LBOK" )
Local   oNo        := LoadBitMap( GetResources(), "LBNO" )
Private aGrAtv
Private oBrwGA
Private cQuery     := ""
Private nQtMot_    := 0
Private nQtSit_    := 0
Private aSituacao  := ChkBoxSit( "A1_XSITUA " )
Private aMotivos   := {}
Private cA1_XSIT   := ""
Private cMotivos   := ""
Private aColunas   := {11,14,18,4,7,8,9,10,2,19,13,17,15,16,3,5}      
Private aOrders    := {.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.}

If _PrmBox() 

   /*------------------------------------------------------+
   | Montagem das variaveis de controle de filtragem de    |
   | Situacao e Motivos                                    |
   +------------------------------------------------------*/
   SitMot()

   /*------------------------------------------------------+
   | Montagem da Query                                     |
   +------------------------------------------------------*/
   MontaQry()

   /*------------------------------------------------------+
   | Montagem da array private aGrAtv                      |
   +------------------------------------------------------*/
   GrvaGrAtv()

   If Empty( aGrAtv ) // Se estiver vazio o array aGrAtv sai do programa
      MsgInfo(  "Nao foram encontrados orcamentos para Geracao de Atividades para o CRM." ,  "*Geracao de Atividades"  )
      RestArea( aArea )
      Return( Nil )
   EndIf


      Define Font   oFonte Name "Courier New" Size 00, 24 Bold
      Define MSDialog oDlgCons Title OEMToANSI( "*Geracao de Atividades" ) From 20, 0 To 480, 1200 /*950*/ Pixel
      /*-----------------------------------------------------------------------------------+
      | @ 020, 010 Say OEMToANSI( "Qtde. Itens por Pï¿½gina: " ) + cCfgPag Pixel FONT oFonte | (reservado para mensagens)
      +-----------------------------------------------------------------------------------*/
      oBrwGA := TCBrowse():New( 010, 005, 590, 190,,,, oDlgCons,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
      oBrwGA:bLDblClick := { || iIf( oBrwGA:ColPos==1, MarcaSN(), .F. ) }
      /*
      oBrwGA:AddColumn( TCColumn():New( "Orcamento"      , { || aGrAtv[oBrwGA:nAt,14] },,,,, 25, .F., .F.,,,, .F., ) )
      oBrwGA:AddColumn( TCColumn():New( "Emissao"        , { || aGrAtv[oBrwGA:nAt,18] },,,,, 25, .F., .F.,,,, .F., ) )
      oBrwGA:AddColumn( TCColumn():New( "Motivo"         , { || aGrAtv[oBrwGA:nAt,02] },,,,, 25, .F., .F.,,,, .F., ) )
      oBrwGA:AddColumn( TCColumn():New( "Cod. Cliente"   , { || SUBSTR(aGrAtv[oBrwGA:nAt,03],1,TamSX3('A1_COD')[1]) },,,,, 50, .F., .F.,,,, .F., ) )
      oBrwGA:AddColumn( TCColumn():New( "Cliente"        , { || aGrAtv[oBrwGA:nAt,04] },,,,, 50, .F., .F.,,,, .F., ) )
      oBrwGA:AddColumn( TCColumn():New( "Regiao"         , { || aGrAtv[oBrwGA:nAt,17] },,,,, 50, .F., .F.,,,, .F., ) )
      oBrwGA:AddColumn( TCColumn():New( "Estado"         , { || aGrAtv[oBrwGA:nAt,15] },,,,, 50, .F., .F.,,,, .F., ) )
      oBrwGA:AddColumn( TCColumn():New( "Municipio"      , { || aGrAtv[oBrwGA:nAt,16] },,,,, 50, .F., .F.,,,, .F., ) )
      oBrwGA:AddColumn( TCColumn():New( "Situacao"       , { || aGrAtv[oBrwGA:nAt,05] },,,,, 40, .F., .F.,,,, .F., ) )
      oBrwGA:AddColumn( TCColumn():New( "Vendedor"       , { || aGrAtv[oBrwGA:nAt,13] },,,,, 40, .F., .F.,,,, .F., ) )
      oBrwGA:AddColumn( TCColumn():New( "Cod.Produto"    , { || aGrAtv[oBrwGA:nAt,07] },,,,, 45, .F., .F.,,,, .F., ) )
      oBrwGA:AddColumn( TCColumn():New( "Produto"        , { || aGrAtv[oBrwGA:nAt,08] },,,,, 45, .F., .F.,,,, .F., ) )
      oBrwGA:AddColumn( TCColumn():New( "Qtde.Produto"   , { || aGrAtv[oBrwGA:nAt,09] }, "@E 99,999,999.99",,,, 45, .F., .F.,,,, .F., ) )
      oBrwGA:AddColumn( TCColumn():New( "Valor Total"    , { || aGrAtv[oBrwGA:nAt,10] }, "@E 999,999,999.99",,,, 45, .F., .F.,,,, .F., ) )
      oBrwGA:AddColumn( TCColumn():New( "Gera Atividade?", { || iIf( aGrAtv[oBrwGA:nAt,11], oOk, oNo ) },,,,,20, .T., .F.,,,, .F., ) )
      */                                                                                                                              
      oBrwGA:AddColumn( TCColumn():New( "Gera Atividade?", { || iIf( aGrAtv[oBrwGA:nAt,11], oOk, oNo ) },,,,,20, .T., .F.,,,, .F., ) )
      oBrwGA:AddColumn( TCColumn():New( "Orcamento"      , { || aGrAtv[oBrwGA:nAt,14] },,,,, 25, .F., .F.,,,, .F., ) )      
      oBrwGA:AddColumn( TCColumn():New( "Emissao"        , { || aGrAtv[oBrwGA:nAt,18] },,,,, 25, .F., .F.,,,, .F., ) )      
      oBrwGA:AddColumn( TCColumn():New( "Cliente"        , { || aGrAtv[oBrwGA:nAt,04] },,,,, 50, .F., .F.,,,, .F., ) )
      oBrwGA:AddColumn( TCColumn():New( "Cod.Produto"    , { || aGrAtv[oBrwGA:nAt,07] },,,,, 45, .F., .F.,,,, .F., ) )
      oBrwGA:AddColumn( TCColumn():New( "Produto"        , { || aGrAtv[oBrwGA:nAt,08] },,,,, 45, .F., .F.,,,, .F., ) )                   
      oBrwGA:AddColumn( TCColumn():New( "Qtde.Produto"   , { || aGrAtv[oBrwGA:nAt,09] }, "@E 99,999,999.99",,,, 45, .F., .F.,,,, .F., ) )
      oBrwGA:AddColumn( TCColumn():New( "Valor Total"    , { || aGrAtv[oBrwGA:nAt,10] }, "@E 999,999,999.99",,,, 45, .F., .F.,,,, .F., ) )                  
      oBrwGA:AddColumn( TCColumn():New( "Motivo"         , { || aGrAtv[oBrwGA:nAt,02] },,,,, 25, .F., .F.,,,, .F., ) )
 	  oBrwGA:AddColumn( TCColumn():New( "Justificativa"  , { || aGrAtv[oBrwGA:nAt,19] },,,,, 80, .F., .F.,,,, .F., ) )   
      oBrwGA:AddColumn( TCColumn():New( "Vendedor"       , { || aGrAtv[oBrwGA:nAt,13] },,,,, 40, .F., .F.,,,, .F., ) )
      oBrwGA:AddColumn( TCColumn():New( "Regiao"         , { || aGrAtv[oBrwGA:nAt,17] },,,,, 50, .F., .F.,,,, .F., ) )
      oBrwGA:AddColumn( TCColumn():New( "Estado"         , { || aGrAtv[oBrwGA:nAt,15] },,,,, 50, .F., .F.,,,, .F., ) )
      oBrwGA:AddColumn( TCColumn():New( "Municipio"      , { || aGrAtv[oBrwGA:nAt,16] },,,,, 50, .F., .F.,,,, .F., ) )                              
      oBrwGA:AddColumn( TCColumn():New( "Cod. Cliente"   , { || SUBSTR(aGrAtv[oBrwGA:nAt,03],1,TamSX3('A1_COD')[1]) },,,,, 50, .F., .F.,,,, .F., ) )
      oBrwGA:AddColumn( TCColumn():New( "Situacao"       , { || aGrAtv[oBrwGA:nAt,05] },,,,, 40, .F., .F.,,,, .F., ) )      
   
            
      oBrwGA:SetArray( aGrAtv )
      oBrwGA:bWhen := { || Len( aGrAtv ) > 0 }    
      
      oBrwGA:bHeaderClick := {|o, nCol| Ordena(nCol)}

      oBtnTds    := tButton():New( 210, 310, "Marca Todos"  , oDlgCons, { || MrkTodos()    }, 40, 12,,,, .T.,,,, { || },, )
      oBtnInv    := tButton():New( 210, 370, "Desmarcar"    , oDlgCons, { || InvMrk()    }, 40, 12,,,, .T.,,,, { || },, )
      oBtnLote   := tButton():New( 210, 430, "Automatico"  , oDlgCons, { || GerAut()    }, 40, 12,,,, .T.,,,, { || },, )
      oBtnOk     := tButton():New( 210, 490, "Editar",       oDlgCons, { || GravarGA() }, 40, 12,,,, .T.,,,, { || },, )
      oBtnCancel := tButton():New( 210, 550, "Cancelar", oDlgCons, { || ::End()    }, 40, 12,,,, .T.,,,, { || },, )
      Activate MSDialog oDlgCons Centered

EndIf

RestArea( aArea )
Return( Nil )

/*======================================================================================+
| Funcao Estatica ....:   _PrmBox()                                                     |
| Autor...............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   04/09/2019                                                    |
| Descricao / Objetivo:   Funcao de usuario, via ParamBox(), para criacao das opcoes,   |
|                         tipo combobox, como alternativa do cadastro de perguntas (SX1)|
| Doc. Origem.........:   MIT044 - Consulta de Clientes com Geracao de Atividades.      |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
Static Function _PrmBox()
Local  aRet       := {}
Local  lPrim      := .T.
Local  aParamBox  := {}
Local  lRet       := .F.
Private cCadastro := OEMToANSI( "Geracao de Atividades" )

nQtSit_ := Len( aSituacao ) // Variavel private de quantidade de situacoes do cliente (A1_XSITUA)
//IMPORTANTE - NAO ALTERAR A ORDEM DAS PERGUNTAS , SE ALTERAR A PERGUNTA 29, alterar tambem a consulta padrao SZA


/*-----------------------------------------------------+
| Parametro "Data de? / Data ate?"                     |
+-----------------------------------------------------*/
aAdd( aParamBox, { 1, "Data de",  CtoD( Space( 8 ) ), "", "", "", "", 50, .F. } ) // Data de? MV_PAR01
aAdd( aParamBox, { 1, "Data até", CtoD( Space( 8 ) ), "", "", "", "", 50, .F. } ) // Data ate? MV_PAR02

/*-----------------------------------------------------+
| Parametro "Vendedor de? / Vendedor ate?"             |
+-----------------------------------------------------*/
aAdd( aParamBox, { 1, "Vendedor de",  Space( TamSX3("A3_COD")[1] ),          "", "", "SA3", "", TamSX3("A3_COD")[1], .F. } ) // Vendedor de? MV_PAR03
aAdd( aParamBox, { 1, "Vendedor até", Replicate( "Z", TamSX3("A3_COD")[1] ), "", "", "SA3", "", TamSX3("A3_COD")[1], .F. } ) // Vendedor ate? MV_PAR04

/*-----------------------------------------------------+
| Parametro "Equipe de? / Equipe ate?"                 |
+-----------------------------------------------------*/
aAdd( aParamBox, { 1, "Equipe de",  Space( TamSX3("ACA_GRPREP")[1] ),          "", "", "ACA", "", TamSX3("ACA_GRPREP")[1], .F. } ) // Equipe de? MV_PAR05
aAdd( aParamBox, { 1, "Equipe até", Replicate( "Z", TamSX3("ACA_GRPREP")[1] ), "", "", "ACA", "", TamSX3("ACA_GRPREP")[1], .F. } ) // Equipe ate? MV_PAR06

/*-----------------------------------------------------+
| Parametro "Un.Neg de? / Un.Neg ate?"                 |
+-----------------------------------------------------*/
aAdd( aParamBox, { 1, "Un.Neg de",  Space( TamSX3("ADK_COD")[1] ),          "", "", "ADK", "", TamSX3("ADK_COD")[1], .F. } ) // Unidade de Negocio de? MV_PAR07
aAdd( aParamBox, { 1, "Un.Neg até", Replicate( "Z", TamSX3("ADK_COD")[1] ), "", "", "ADK", "", TamSX3("ADK_COD")[1], .F. } ) // Unidade de Negocio ate? MV_PAR08

/*-----------------------------------------------------+
| Parametro "Fam.Prod. de? / Fam.Prod. ate?"           |
+-----------------------------------------------------*/
aAdd( aParamBox, { 1, "Fam.Prod. de",  Space( TamSX3("Z1_COD")[1] ),          "", "", "SZ1", "", TamSX3("Z1_COD")[1], .F. } ) // Familia Produto de? MV_PAR09
aAdd( aParamBox, { 1, "Fam.Prod. até", Replicate( "Z", TamSX3("Z1_COD")[1] ), "", "", "SZ1", "", TamSX3("Z1_COD")[1], .F. } ) // Familia Produto ate? MV_PAR10

/*-----------------------------------------------------+
| Parametro "Lin.Prod. de? / Lin.Prod. ate?"           |
+-----------------------------------------------------*/
aAdd( aParamBox, { 1, "Linha Prod. de",  Space( TamSX3("Z2_COD")[1] ),          "", "", "SZ2", "", TamSX3("Z2_COD")[1], .F. } ) // Linha Produto de? 11
aAdd( aParamBox, { 1, "Linha Prod. até", Replicate( "Z", TamSX3("Z2_COD")[1] ), "", "", "SZ2", "", TamSX3("Z2_COD")[1], .F. } ) // Linha Produto ate? 12

/*-----------------------------------------------------+
| Parametro "Grupo Prod. de? / Grupo Prod. ate?"       |
+-----------------------------------------------------*/
aAdd( aParamBox, { 1, "Grupo Prod. de",  Space( TamSX3("Z3_COD")[1] ),          "", "", "SZ3", "", TamSX3("Z3_COD")[1], .F. } ) // Grupo Produto de? 13
aAdd( aParamBox, { 1, "Grupo Prod. até", Replicate( "Z", TamSX3("Z3_COD")[1] ), "", "", "SZ3", "", TamSX3("Z3_COD")[1], .F. } ) // Grupo Produto ate? 14

/*-----------------------------------------------------+
| Parametro "Produto de? / Produto ate?"       MV_PAR08        |
+-----------------------------------------------------*/
aAdd( aParamBox, { 1, "Produto de",      Space( TamSX3("B1_COD")[1] ),          "", "", "SB1", "", /*TamSX3("B1_COD")[1]*/ 80, .F. } ) // Produto de? 15
aAdd( aParamBox, { 1, "Produto até",     Replicate( "Z", TamSX3("B1_COD")[1] ), "", "", "SB1", "", /*TamSX3("B1_COD")[1]*/ 80, .F. } ) // Produto ate? 16

/*-----------------------------------------------------+
| Parametro "Cliente de? / Cliente ate?"         MV_PAR09       |
+-----------------------------------------------------*/
aAdd( aParamBox, { 1, "Cliente de",      Space( TamSX3("A1_COD")[1] ),          "", "", "SA1", "", TamSX3("A1_COD")[1], .F. } ) // Cliente de? 17
aAdd( aParamBox, { 1, "Cliente até",     Replicate( "Z", TamSX3("A1_COD")[1] ), "", "", "SA1", "", TamSX3("A1_COD")[1], .F. } ) // Cliente ate? 18

/*-----------------------------------------------------+
| Parametro "Lj Cliente de? / Lj Cliente ate?"         |
+-----------------------------------------------------*/
aAdd( aParamBox, { 1, "Lj Cliente de",   Space( TamSX3("A1_LOJA")[1] ),          "", "", "SA1", "", TamSX3("A1_LOJA")[1], .F. } ) // Lj Cliente de? 19
aAdd( aParamBox, { 1, "Lj Cliente até",  Replicate( "Z", TamSX3("A1_LOJA")[1] ), "", "", "SA1", "", TamSX3("A1_LOJA")[1], .F. } ) // Lj Cliente ate? 20

/*-----------------------------------------------------+
| Parametro "Regiao de? / Regiao ate?"           MV_PAR11      |
+-----------------------------------------------------*/
aAdd( aParamBox, { 1, "Regiao de",       Space( 3 ),          "", "", "A2", "", 3, .F. } ) // Regiao de? 21 
aAdd( aParamBox, { 1, "Regiao até",      Replicate( "Z", 3 ), "", "", "A2", "", 3, .F. } ) // Regiao ate? 22

/*-----------------------------------------------------+
| Parametro "Estado de? / Estado ate?"                 |
+-----------------------------------------------------*/
aAdd( aParamBox, { 1, "Estado de",       Space( 2 ),   "", "", "12", "", 5, .F. } ) // Estado de? 23
aAdd( aParamBox, { 1, "Estado até",      "ZZ",         "", "", "12", "", 5, .F. } ) // Estado ate? 24

/*-----------------------------------------------------+
| Parametro "Cidade de? / Cidade ate?"                 |
+-----------------------------------------------------*/
aAdd( aParamBox, { 1, "Cidade de",       Space( TamSX3("A1_COD_MUN")[1] ),          "", "", "CC2SA1", "", TamSX3("A1_COD_MUN")[1], .F. } ) // Cidade de? 25
aAdd( aParamBox, { 1, "Cidade até",      Replicate( "Z", TamSX3("A1_COD_MUN")[1] ), "", "", "CC2SA1", "", TamSX3("A1_COD_MUN")[1], .F. } ) // Cidade ate? 26

/*-----------------------------------------------------+
| Parametro "Grp.Venda de? / Grp.Venda ate?"           |
+-----------------------------------------------------*/
aAdd( aParamBox, { 1, "Grp.Venda de",    Space( TamSX3("A1_GRPVEN")[1] ),          "", "", "ACY", "", TamSX3("A1_GRPVEN")[1], .F. } ) // Grp.Venda de? 27
aAdd( aParamBox, { 1, "Grp.Venda até",   Replicate( "Z", TamSX3("A1_GRPVEN")[1] ), "", "", "ACY", "", TamSX3("A1_GRPVEN")[1], .F. } ) // Grp.Venda ate? 28

/*-----------------------------------------------------+
| Parametro Assunto                                    |
+-----------------------------------------------------*/
aAdd( aParamBox, { 2, "Assunto", 6, CntCBox( "AOF_ASSUNT" ), 100, "", .F. } ) // Assunto? 29 

/*-----------------------------------------------------+
| Parametro Data de Atividade                          |
+-----------------------------------------------------*/
aAdd( aParamBox, { 1, "Data Lembrete",  CtoD( Space( 8 ) ), "", "", "", "", 50, .F. } ) // Data de Atividade? 30

/*-----------------------------------------------------+
| Parametro Descricao                                  |
+-----------------------------------------------------*/
aAdd( aParamBox, { 1, "Descrição", Space( TamSX3("ZA_CODIGO")[1] ), "", "", "SZA", "", TamSX3("ZA_CODIGO")[1], .F. } ) // Descricao? 31

/*-----------------------------------------------------+
| Parametro Situacao (via checkbox)                    |
+-----------------------------------------------------*/
lPrim := .T.
If .not. Empty( aSituacao )
   For nX := 1 to Len( aSituacao )
       If lPrim
          aAdd( aParamBox, { 4, "Situação", .F., aSituacao[ nX ], 90, "", .F. } ) // Situacao 32
          lPrim := .F.
       Else
          aAdd( aParamBox, { 4,         "", .F., aSituacao[ nX ], 90, "", .F. } ) // Situacao 32
       EndIf
   NexT
EndIf

/*-----------------------------------------------------+
| Parametro Motivo? (via CheckBox)                     |
+-----------------------------------------------------*/
DbSelectArea( "SZ8" )
DbSetOrder( 2 ) // Z8_FILIAL + Z8_MOTIVO
SZ8->( DbGoTop() )
lPrim := .T.
Do While SZ8->( .not. EoF() )
   nQtMot_++ // Variavel private de quantidade de Motivos
   If lPrim
      aAdd( aParamBox, { 4, "Motivo", .F., SZ8->Z8_MOTIVO, 90, "", .F. } )
      lPrim := .F.
   Else
      aAdd( aParamBox, { 4,       "", .F., SZ8->Z8_MOTIVO, 90, "", .F. } )
   EndIf
   aAdd( aMotivos, { SZ8->Z8_CODIGO, SZ8->Z8_MOTIVO } )
   SZ8->( DbSkiP() )
EndDo 

/*-----------------------------------------------------+
| Confirmacao da execucao do ParamBox()                |
+-----------------------------------------------------*/
If ParamBox( aParamBox, OEMToANSI( "Parametros" ), @aRet )
   lRet := .T.
Else
   lRet := .F.
EndIf

Return( lRet )

/*======================================================================================+
| Funcao Estatica ....:   CntCBox( cCampo )                                             |
| Autor...............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   04/09/2019                                                    |
| Descricao / Objetivo:   Funcao estatica que separa as opcoes do campo do dicionario   |
|                         de dados X3_CBOX e, o transforma em uma array unidimensional  |
|                         e, cada elemento e' uma opcao do ComboBox.                    |
| Doc. Origem.........:   MIT044 - Consulta de Clientes com Geracao de Atividades.      |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
Static Function CntCBox( cCampo )
Local aArea   := GetArea()
Local aCBox   := {}
Local nPos    := 1
Local nPosAtu := 1
Local cSX3Cbox

DbSelectArea( "SX3" )
DbSetOrder( 2 ) // X3_CAMPO

If DbSeek( cCampo )

   cSX3Cbox := AllTrim( SX3->X3_CBOX )
   For nPos := 1 to Len( cSX3Cbox )
       If SubStr( cSX3Cbox, nPos, 1 ) # ";"
          LooP
       EndIf

       nPos-- // Retrocede um para nao considerar o caracter ";"

       aAdd( aCBox, AllTrim( SubStr( cSX3Cbox, nPosAtu, (nPos-nPosAtu)+1 ) ) ) // Captura a substring entre nPosAtu e (nPos-nPosAtu)+1.

       nPos    := ( nPos + 2 ) // Soma mais 2 para avancar o proximo caracter depois do ";"
       nPosAtu := nPos // Iguala o nPosAtu com nPos para considerar a posicao inicial a ser considerada de cSX3Cbox       
   NexT
   aAdd( aCBox, AllTrim( SubStr( cSX3Cbox, nPosAtu, nPos ) ) ) // Captura a ultima substring entre nPosAtu e nPos.

Else
   aCBox := { "SEM OPCOES - " + AllTrim( cCampo ) }
EndIf

RestArea( aArea )
Return( aCBox )

/*======================================================================================+
| Funcao Estatica ....:   MontaQry()                                                    |
| Autor...............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   06/09/2019                                                    |
| Descricao / Objetivo:   Funcao estatica para montagem da query de acordo com os para- |
|                         metros preenchidos na funcao estatica _PrmBox().              |
| Doc. Origem.........:   MIT044 - Consulta de Clientes com Geracao de Atividades.      |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
Static Function MontaQry()
Local  aArea   := GetArea()
Local  cQryMot := ""

cQuery := "SELECT   DISTINCT SCK.CK_PRODUTO  AS  COD_PROD, " + _ENTER
cQuery += "         SCJ.CJ_XVEND             AS  VENDEDOR, " + _ENTER
cQuery += "         SA3.A3_NOME              AS  NOMEVEN, " + _ENTER
cQuery += "         SUM(SCK.CK_QTDVEN)       AS  QTDE_TOTAL, " + _ENTER
cQuery += "         SUM(SCK.CK_VALOR)        AS  VALOR_TOTAL, " + _ENTER
cQuery += "         COUNT(SCK.CK_NUM)        AS  QTDE_ORC, " + _ENTER
cQuery += "         SCJ.CJ_CLIENTE           AS  CLIENTE, " + _ENTER
cQuery += "         SCJ.CJ_LOJA              AS  LOJACLI, " + _ENTER
cQuery += "         SCJ.CJ_XNOME             AS  NOMECLI, " + _ENTER
cQuery += "         SCK.CK_XMOTIVO           AS  MOTIVO, " + _ENTER
cQuery += "         SCJ.CJ_NUM               AS  ORC, " + _ENTER
cQuery += "         SA1.A1_EST               AS  EST, " + _ENTER
cQuery += "         SA1.A1_MUN               AS  MUN, " + _ENTER
cQuery += "         SX5.X5_DESCRI            AS  REGIAO, " + _ENTER
cQuery += "         SCK.CK_XJUSTIF           AS  JUSTIF, " + _ENTER
cQuery += "         SCJ.CJ_EMISSAO           AS  EMISSAO " + _ENTER

cQuery += "FROM SCJ010 SCJ, SCK010 SCK, SA1010 SA1 ,SA3010 SA3 , SX5010 SX5 " + _ENTER
cQuery += "WHERE SCJ.CJ_EMISSAO  BETWEEN '" + DtoS( MV_PAR01 ) + "' AND '" + DtoS( MV_PAR02 ) + "' " + _ENTER
cQuery += "      AND  SCJ.CJ_FILIAL = '" + xFilial( "SCJ" ) + "'" + _ENTER
cQuery += "      AND  SCK.CK_FILIAL = '" + xFilial( "SCK" ) + "'" + _ENTER
cQuery += "      AND  SA1.A1_FILIAL = '" + xFilial( "SA1" ) + "'" + _ENTER
cQuery += "      AND  SA3.A3_FILIAL = '" + xFilial( "SA3" ) + "'" + _ENTER
cQuery += "      AND  SX5.X5_FILIAL = '" + xFilial( "SX5" ) + "'" + _ENTER
cQuery += "      AND  SCJ.CJ_CLIENTE  BETWEEN '  " + MV_PAR17 + "' AND '" + MV_PAR18 + "' " + _ENTER
cQuery += "      AND  SCJ.CJ_LOJA BETWEEN '" + MV_PAR19 + "' AND '" + MV_PAR20 + "' " + _ENTER
cQuery += "      AND  SCJ.CJ_XVEND BETWEEN '" + MV_PAR03   + "' AND '" + MV_PAR04 + "' " + _ENTER
cQuery += "      AND  SCK.CK_NUM = SCJ.CJ_NUM " + _ENTER
cQuery += "      AND  SCJ.CJ_XVEND = SA3.A3_COD " + _ENTER
cQuery += "      AND  SX5.X5_TABELA = 'A2' AND SX5.X5_CHAVE = SA1.A1_REGIAO " + _ENTER
cQuery += "      AND  SCJ.CJ_CLIENTE = SA1.A1_COD AND CJ_LOJA = A1_LOJA " + _ENTER
cQuery += "      AND  SCK.CK_PRODUTO  BETWEEN '" + MV_PAR15  + "' AND '" + MV_PAR16 + "' " + _ENTER
cQuery += "      AND  SCJ.CJ_CLIENTE  BETWEEN '" + MV_PAR17  + "' AND '" + MV_PAR18 + "' " + _ENTER
cQuery += "      AND  SA1.A1_REGIAO  BETWEEN '" + MV_PAR21  + "' AND '" + MV_PAR22 + "' " + _ENTER
cQuery += "      AND  SA1.A1_YEQUIPE  BETWEEN '" + MV_PAR05  + "' AND '" + MV_PAR06 + "' " + _ENTER
cQuery += "      AND  SA3.A3_UNIDAD  BETWEEN '" + MV_PAR07  + "' AND '" + MV_PAR08 + "' " + _ENTER

cQryMot := _cMotivo() // Insercao de motivos no processo de selecao.
If .not. Empty( cQryMot )
   cQuery += cQryMot 
EndIf

cQuery += "      AND SCJ.D_E_L_E_T_ = ' ' " + _ENTER
cQuery += "      AND SCK.D_E_L_E_T_ = ' ' " + _ENTER
cQuery += "GROUP BY SCK.CK_PRODUTO, SCJ.CJ_XVEND, SCK.CK_VALOR, SCK.CK_XMOTIVO, SCJ.CJ_CLIENTE, SCJ.CJ_LOJA, SCJ.CJ_XNOME  , SA3.A3_NOME , CJ_NUM ,A1_EST ,A1_MUN , X5_DESCRI,CK_XJUSTIF,CJ_EMISSAO " + _ENTER
cQuery += "ORDER BY SCJ.CJ_EMISSAO DESC , SCJ.CJ_CLIENTE, SCJ.CJ_LOJA " + _ENTER

cQuery := ChangeQuery( cQuery )

/*-------------------------------------------------------+
| Verifica a existencia do alias em aberto - se existir, |
| realizara' o seu fechamento e nova abertura da query.  |
+-------------------------------------------------------*/
If ( Select( "GAQRY" ) ) > 0
   DbSelectArea( "GAQRY" )
   GAQRY->( DbCloseArea() )
EndIf
TCQuery cQuery New Alias "GAQRY"

RestArea( aArea )
Return( Nil )

/*======================================================================================+
| Funcao Estatica ....:   _cMotivo()                                                    |
| Autor...............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   05/09/2019                                                    |
| Descricao / Objetivo:   Funcao estatica para concatenar as opcoes do campo CK_XMOTIVO |
|                         e sera' usado para a query.                                   |
| Doc. Origem.........:   MIT044 - Consulta de Clientes com Geracao de Atividades.      |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
Static Function _cMotivo()
Local aArea   := GetArea()
Local lPrim   := .T.
Local cQry    := ""

DbSelectArea( "SZ8" )
SZ8->( DbGoTop() )
Do While .not. SZ8->( EoF() )
   If SZ8->Z8_CODIGO$AllTrim( cMotivos )
      If lPrim
         cQry  := "      AND  ( SCK.CK_XMOTIVO = '" + SZ8->Z8_CODIGO + "' "
         lPrim := .F.
      Else
         cQry += "OR SCK.CK_XMOTIVO = '" + SZ8->Z8_CODIGO + "' "
      EndIf      
   EndIf
   SZ8->( DbSkiP() )
EndDo

If .not. Empty( cQry )
   cQry += ") " + _ENTER
EndIf

RestArea( aArea )
Return( cQry )

/*======================================================================================+
| Funcao Estatica ....:   GravarGA()                                                    |
| Autor...............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   06/09/2019                                                    |
| Descricao / Objetivo:   Funcao estatica para Geracao das Atividades do CRM.           |
| Doc. Origem.........:   MIT044 - Consulta de Clientes com Geracao de Atividades.      |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
Static Function GravarGA()
Local aArea  := GetArea()
Local lNMarc := .F.
Local nXCnt

/*------------------------------------------------------------------------------------+
| Laco que checa se tem algum item marcado para geracao do cadastro de atividades CRM |
+------------------------------------------------------------------------------------*/
For nXCnt := 1 to Len( aGrAtv )
   If aGrAtv[nXCnt][11] // Item marcado
      lNMarc := .T.
      ExiT
   EndIf
NexT

If .not. lNMarc
   MsgAlert( OEMToANSI( "Nao há item(ns) marcado(s) para separacao. Favor verificar!" ), OEMToANSI( "*Geracao de Atividades" ) )
Else
   If MsgYesNo( "Confirma a geracao das atividades CRM para os itens marcados?", "*Geracao de Atividades" )
      GrvGA() // Funcao estatica da geracao cadastro de atividades CRM.
      oDlgCons:End() // Fecha a janela de geracao de atividades CRM.
   EndIf
EndIf

RestArea( aArea )
Return( Nil )

/*======================================================================================+
| Funcao Estatica ....:   MarcaSN()                                                     |
| Autor...............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   06/09/2019                                                    |
| Descricao / Objetivo:   Funcao estatica para marcacao do check-box para Geracao das   |
|                         Atividades do CRM.                                            |
| Doc. Origem.........:   MIT044 - Consulta de Clientes com Geracao de Atividades.      |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
Static Function MarcaSN()
Local aArea := GetArea()
aGrAtv[oBrwGA:nAt,11] := .not. aGrAtv[oBrwGA:nAt,11]
RestArea( aArea )
Return( Nil )

/*======================================================================================+
| Funcao Estatica ....:   GrvaGrAtv()                                                   |
| Autor...............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   06/09/2019                                                    |
| Descricao / Objetivo:   Funcao estatica para inserir linhas e elementos essenciais pa-|
|                         ra geracao das atividades CRM na array private aGrAtv.        |
| Doc. Origem.........:   MIT044 - Consulta de Clientes com Geracao de Atividades.      |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
Static Function GrvaGrAtv()
Local  aArea  :=  GetArea()

aGrAtv := {} // Inicializacao da array private
DbSelectArea( "GAQRY" )
GAQRY->( DbGoTop() )
Do While .not. GAQRY->( EoF() )

   /*--------------------------------------------------------------------+
   | Realizar as filtragens - parametro Vendedor                         |
   +--------------------------------------------------------------------*/
   If .not. ( GAQRY->VENDEDOR >= MV_PAR03 .and. GAQRY->VENDEDOR <= MV_PAR04 )  
      GAQRY->( DbSkiP() )
      LooP
   EndIf

   /*--------------------------------------------------------------------+
   | Realizar as filtragens - parametros Familia|Linha|Grupo de Produtos |
   +--------------------------------------------------------------------*/
   DbSelectArea( "SB1" )
   DbSetOrder( 1 ) // B1_FILIAL + B1_COD
   If DbSeek( xFilial( "SB1" ) + GAQRY->COD_PROD )
      If .not. ( ( SB1->B1_XCODFAM >= MV_PAR09 .and. SB1->B1_XCODFAM <= MV_PAR10 ) .and.;
                 ( SB1->B1_XCODLIN >= MV_PAR11 .and. SB1->B1_XCODLIN <= MV_PAR12 ) .and.;
                 ( SB1->B1_XGRUPO  >= MV_PAR13 .and. SB1->B1_XGRUPO  <= MV_PAR14 ) )
         GAQRY->( DbSkiP() )
         LooP
      EndIf
   Else
      GAQRY->( DbSkiP() )
      LooP
   EndIf
   DbSelectArea( "GAQRY" )

   /*------------------------------------------------------------------------------------+
   | Realizar as filtragens - parametros Regiao|Estado|Cidade|Grupo de Venda de Clientes |
   +------------------------------------------------------------------------------------*/
   DbSelectArea( "SA1" )
   DbSetOrder( 1 ) // A1_FILIAL + A1_COD + A1_LOJA
   If DbSeek( xFilial( "SA1" ) + GAQRY->( CLIENTE + LOJACLI ) )
      If .not. ( ( SA1->A1_REGIAO  >= MV_PAR21 .and. SA1->A1_REGIAO  <= MV_PAR22 ) .and.;
                 ( SA1->A1_EST     >= MV_PAR23 .and. SA1->A1_EST     <= MV_PAR24 ) .and.;
                 ( SA1->A1_COD_MUN >= MV_PAR25 .and. SA1->A1_COD_MUN <= MV_PAR26 ) .and.;
                 ( SA1->A1_GRPVEN  >= MV_PAR27 .and. SA1->A1_GRPVEN  <= MV_PAR28 ) .and.;
                 ( SA1->A1_XSITUA$AllTrim( cA1_XSIT ) ) )
         GAQRY->( DbSkiP() )
         LooP
      EndIf
   Else
      GAQRY->( DbSkiP() )
      LooP
   EndIf
   DbSelectArea( "GAQRY" )

   /*---------------------------------------------------------------+
   | Passado por todos os filtros, gravacao da array private aGrAtv |
   +---------------------------------------------------------------*/
   aAdd( aGrAtv, { /* 01-Cod Motivo */ AllTrim( GAQRY->MOTIVO ),;
                   /* 02-Motivo     */ GetAdvFVal( "SZ8", "Z8_MOTIVO", xFilial( "SZ8" ) + GAQRY->MOTIVO, 1, 1 ),;
                   /* 03-Cod. Cli   */ GAQRY->( CLIENTE + LOJACLI ),;
                   /* 04-Cliente    */ AllTrim( GAQRY->NOMECLI ),;
                   /* 05-Situacao   */ DescSit(),;
                   /* 06-Qtd.Orc    */ GAQRY->QTDE_ORC,;
                   /* 07-Cod. Prod  */ GAQRY->COD_PROD,;                                  
                   /* 08-Produto    */ GetAdvFVal( "SB1", "B1_DESC", xFilial( "SB1" ) + GAQRY->COD_PROD, 1, 1 ),;
                   /* 09-Qtd.Prod   */ GAQRY->QTDE_TOTAL,;
                   /* 10-Val.Tot.   */ GAQRY->VALOR_TOTAL,;
                   /* 11-Gera Atv?  */ .F.,;
                   /* 12-Cod.Vend.  */ GAQRY->VENDEDOR,;
                   /* 13-nome.Vend.  */ GAQRY->NOMEVEN, ;
                   /* 14-Orcamento.  */ GAQRY->ORC, ;
                   /* 15-Estado.     */ GAQRY->EST, ;
                   /* 16-Municipio.  */ GAQRY->MUN, ;
                   /* 17-Regiao.     */ GAQRY->REGIAO  ,;       
                   /* 18-Emissao.    */ DTOC(STOD(GAQRY->EMISSAO)),;
                   /* 19-Justificativ*/ GAQRY->JUSTIF ;            
                   } )

   GAQRY->( DbSkiP() )
EndDo

RestArea( aArea )
Return( Nil )

/*======================================================================================+
| Funcao Estatica ....:   ChkBoxSit( cCampo )                                           |
| Autor...............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   06/09/2019                                                    |
| Descricao / Objetivo:   Funcao estatica para inserir elementos na array aSituacao p/  |
|                         exibir as opcoes, via checkbox, do campo A1_XSITUA.           |
| Doc. Origem.........:   MIT044 - Consulta de Clientes com Geracao de Atividades.      |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
Static Function ChkBoxSit( cCampo )
Local aArea   := GetArea()
Local aSit    := {}
Local nPos    := 1
Local nPosAtu := 1
Local cSX3Cbox

DbSelectArea( "SX3" )
DbSetOrder( 2 ) // X3_CAMPO

If DbSeek( cCampo )

   cSX3Cbox := AllTrim( SX3->X3_CBOX )
   For nPos := 1 to Len( cSX3Cbox )
       If SubStr( cSX3Cbox, nPos, 1 ) # ";"
          LooP
       EndIf

       nPos-- // Retrocede um para nao considerar o caracter ";"

       aAdd( aSit, SubStr( cSX3Cbox, nPosAtu, (nPos-nPosAtu)+1 ) ) // Captura a substring entre nPosAtu e (nPos-nPosAtu)+1.

       nPos    := ( nPos + 2 ) // Soma mais 2 para avancar o proximo caracter depois do ";"
       nPosAtu := nPos // Iguala o nPosAtu com nPos para considerar a posicao inicial a ser considerada de cSX3Cbox       
   NexT
   aAdd( aSit, SubStr( cSX3Cbox, nPosAtu, nPos ) ) // Captura a ultima substring entre nPosAtu e nPos.

Else
   aCBox := { "SEM OPCOES - " + AllTrim( cCampo ) }
EndIf

RestArea( aArea )
Return( aSit )

/*======================================================================================+
| Funcao Estatica ....:   GrvGA()                                                       |
| Autor...............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   07/09/2019                                                    |
| Descricao / Objetivo:   Funcao estatica para gravacao dos dados nos cadastros AOF, da |
|                         rotina CRMA180 (Atualizacoes / Vendas / Atividades).          |
| Doc. Origem.........:   MIT044 - Consulta de Clientes com Geracao de Atividades.      |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
Static Function GrvGA()
Local  aArea     := GetArea()
Local  oModel    := FWLoadModel( "CRMA180" )
Local  oModelCRM := oModel:GetModel( "AOFMASTER" )
Local  cDesc     := ""
Local  cPropr    := ""
Local  cContato  := ""
Local  cNContato  := ""
Local  aPriori   := Separa(Supergetmv('ES_ATIVPRI',.T.,''),'|')
Local  cPriori   := ''
Local  nPos      := 0
Local  cTel      := ''
Local  cDDD     := ''
For nX := 1 to Len( aGrAtv )

    If aGrAtv[nX][11] // Tarefa marcada pelo usuario 

       oModel:SetOperation( 3 ) // 3, de Insercao
       oModel:Activate()
      
       nPos := MV_PAR29
       If nPos > 0
         cPriori := Alltrim(aPriori[nPos])
       Else
         cPriori := '3'
       EndIf

       /*-----------------------------------------------------------------+
       | Carrega os campos da tabela AOF com os conteudos da array aGrAtv |
       +-----------------------------------------------------------------*/
       cDesc  := "*** Gerado Automaticamente." + _ENTER + cDscAss() + _ENTER + "Produto: " + AllTrim(aGrAtv[nX][08])
       cPropr := Propriet( aGrAtv[nX][3] )
       cContato := ""
       cTel    := ''
      SA1->(DbSetOrder(1))
      SA1->(DbSeek(xFilial('SA1') + aGrAtv[nX][3]))
      AC8->(DbSetOrder(2))
      If AC8->(DbSeek(xFilial('AC8') + 'SA1' + xFilial('SA1') + SA1->(A1_COD + A1_LOJA)))
         SU5->(DbSetOrder(1))
         If SU5->(DbSeek(xFilial('SU5') + AC8->AC8_CODCON))
            If SU5->U5_XPADRAO == 'S'
               cContato := AC8->AC8_CODCON
               cNContato   := SU5->U5_CONTAT
               cTel     := SU5->U5_FONE
               cDDD     := SU5->U5_DDD
            EndIf
         EndIf
      EndIf
       oModelCRM:LoadValue( "AOF_FILIAL", xFilial( "AOF" ) )
       oModelCRM:LoadValue( "AOF_TIPO",   "1" )
       oModelCRM:LoadValue( "AOF_ASSUNT", Alltrim(Str(MV_PAR29)) )
       oModelCRM:LoadValue( "AOF_DESCRI", cDesc )
       oModelCRM:LoadValue( "AOF_CHAVE",  aGrAtv[nX][3] )
       oModelCRM:LoadValue( "AOF_DTINIC", dDatabase )
       oModelCRM:LoadValue( "AOF_DTFIM",  dDatabase + 7 )
       oModelCRM:LoadValue( "AOF_STATUS", "1" )
       oModelCRM:LoadValue( "AOF_PRIORI", "2" )
       oModelCRM:LoadValue( "AOF_PERCEN", "1" )
       oModelCRM:LoadValue( "AOF_CODUSR", cPropr )
       oModelCRM:LoadValue( "AOF_DESTIN", CRM170Inic( FwFldGet( "AOF_ENTIDA" ), FwFldGet( "AOF_CHAVE" ) ) )     
       oModelCRM:LoadValue( "AOF_CODUSR", RetCodUsr() )
       oModelCRM:LoadValue( "AOF_OBS"   , POSICIONE('SA3',1,xFilial('SA3') +SA1->A1_VEND, 'A3_CODUSR' ) )
       oModelCRM:LoadValue( "AOF_XRESP"   , POSICIONE('SA3',1,xFilial('SA3') +SA1->A1_VEND, 'A3_NOME' ) )
       oModelCRM:LoadValue( "AOF_DTLEMB"   , MV_PAR30 )
       oModelCRM:LoadValue( "AOF_XCONT"   , cContato )
       oModelCRM:LoadValue( "AOF_XNCONT"   , cNContato )
       oModelCRM:LoadValue( "AOF_XTEL"   , cTel )
       oModelCRM:LoadValue( "AOF_XDDD"   , cDDD )
       oModelCRM:LoadValue( "AOF_PRIORI"   , cPriori )


       FWExecView( OEMToANSI( "*Inclusao via Customizacao" ), "VIEWDEF.CRMA180", MODEL_OPERATION_INSERT,, { || .T. },, /*nPerReducTela*/,,,,, oModel )

    EndIf
NexT

RestArea( aArea )
Return( Nil )

/*======================================================================================+
| Funcao Estatica ....:   SitMot()                                                      |
| Autor...............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   07/09/2019                                                    |
| Descricao / Objetivo:   Funcao estatica para montagem das variaveis privates cA1_XSIT |
|                         e cMotivos.                                                   |
| Doc. Origem.........:   MIT044 - Consulta de Clientes com Geracao de Atividades.      |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
Static Function SitMot()
Local aArea   := GetArea()
Local cParam_
Local nX      := 1
Local nCnt    := 32 // 31 e' o ultimo parametro fixo dos MV_PAR99.

/*----------------------------------------------------+
| Montagem da variavel private cA1_XSIT               |
+----------------------------------------------------*/
For nX := 1 to nQtSit_ // nQtSit_ - variavel private
    cParam_ := "MV_PAR" + StrZero( nCnt, 2 )    
    If ValType( &cParam_ ) == "L"
       If &cParam_
          cA1_XSIT := cA1_XSIT + Left( aSituacao[ nX ], 1 ) + "." 
       EndIf
    EndIf
    nCnt++
NexT 

/*----------------------------------------------------+
| Montagem da variavel private cMotivos               |
+----------------------------------------------------*/
For nX := 1 to nQtMot_ // nQtMot_ - variavel private
    cParam_ := "MV_PAR" + StrZero( nCnt, 2 )
    If ValType( &cParam_ ) == "L"
       If &cParam_
          cMotivos += aMotivos[ nX ][ 1 ] + "." 
       EndIf
    EndIf
    nCnt++
NexT 

RestArea( aArea )
Return( Nil )

/*======================================================================================+
| Funcao Estatica ....:   DescSit()                                                     |
| Autor...............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   07/09/2019                                                    |
| Descricao / Objetivo:   Funcao estatica para buscar a descricao do campo A1_XSITUA.   |
| Doc. Origem.........:   MIT044 - Consulta de Clientes com Geracao de Atividades.      |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
Static Function DescSit()
Local aArea := GetArea()
Local xSit  := ""
Local cDSit := ""

xSit := GetAdvFVal( "SA1", "A1_XSITUA", xFilial( "SA1" ) + GAQRY->( CLIENTE + LOJACLI ), 1, "X" )

If .not. Empty( xSit )
   If xSit == "1"
      cDSit := aSituacao[ Val( xSit ) ]
   ElseIf xSit == "2"
      cDSit := aSituacao[ Val( xSit ) ]
   ElseIf xSit == "3"
      cDSit := aSituacao[ Val( xSit ) ]
   Else
      cDSit := "X-SIT. DESCONH."   
   EndIf 
EndIf

Return( cDSit )

/*======================================================================================+
| Funcao Estatica ....:   Propriet( cChave )                                            |
| Autor...............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   11/09/2019                                                    |
| Descricao / Objetivo:   Funcao estatica para buscar o proprietario-vendedor do        |
|                         cliente.                                                      |
| Doc. Origem.........:   MIT044 - Consulta de Clientes com Geracao de Atividades.      |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
Static Function Propriet( cChave )
Local  aArea := GetArea()
Local  cProp := ""

DbSelectArea( "SA1" )
DbSetOrder( 1 )  // A1_FILIAL + A1_COD + A1_LOJA
If DbSeek( xFilial( "SA1" ) + cChave )
   DbSelectArea( "AO3" )
   DbSetOrder( 2 ) // AO3_FILIAL + AO3_VEND
   If DbSeek( xFilial( "AO3" ) + SA1->A1_VEND )
      cProp := AO3->AO3_CODUSR
   EndIf
EndIf

RestArea( aArea )
Return( cProp )

/*======================================================================================+
| Funcao Estatica ....:   cDscAss()                                                     |
| Autor...............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   11/09/2019                                                    |
| Descricao / Objetivo:   Funcao estatica para buscar a descricao do assunto CRM.       |
| Doc. Origem.........:   MIT044 - Consulta de Clientes com Geracao de Atividades.      |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
Static Function cDscAss()
Local  aArea := GetArea()
Local  cDsc  := ""

DbSelectArea( "SZA" )
DbSetOrder( 3 ) // ZA_FILIAL + ZA_CODIGO
If DbSeek( xFilial( "SZA" ) + MV_PAR31 )
   cDsc := SZA->ZA_DESCR
EndIf

RestArea( aArea )
Return( cDsc )


/*/{Protheus.doc} GerAut
   (long_description)
   @type  Function
   @author user
   @since date
   @version version
   @param param, param_type, param_descr
   @return return, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
   /*/
Static Function GerAut()
Local  aArea     := GetArea()
Local  oModel    := FWLoadModel( "CRMA180" )
Local  oModelCRM := oModel:GetModel( "AOFMASTER" )
Local  cDesc     := ""
Local  cPropr    := ""
Local  cContato  := ""
Local  aPriori   := Separa(Supergetmv('ES_ATIVPRI',.T.,''),'|')
Local  cPriori   := ''
Local  nPos      := 0
Local  cTel      := ''
Local  cDDD      := ''
Local lNMarc := .F.
/*------------------------------------------------------------------------------------+
| Laco que checa se tem algum item marcado para geracao do cadastro de atividades CRM |
+------------------------------------------------------------------------------------*/
For nXCnt := 1 to Len( aGrAtv )
   If aGrAtv[nXCnt][11] // Item marcado
      lNMarc := .T.
      ExiT
   EndIf
NexT

If .not. lNMarc
   MsgAlert( OEMToANSI( "Nao há item(ns) marcado(s) para separacao. Favor verificar!" ), OEMToANSI( "*Geracao de Atividades" ) )
Else
   If MsgYesNo('Confirma a geração automatica das atividades marcadas?')
      For nX := 1 to Len( aGrAtv )
         If aGrAtv[nX][11] // Tarefa marcada pelo usuario 
            oModel    := FWLoadModel( "CRMA180" )
            oModelCRM := oModel:GetModel( "AOFMASTER" )

            oModel:SetOperation( 3 ) // 3, de Insercao
            oModel:Activate()

            nPos :=IIF(ValType(MV_PAR29) == 'C', Val(MV_PAR29),MV_PAR29)
            If nPos > 0
               cPriori := Alltrim(aPriori[nPos])
            Else
               cPriori := 3
            EndIf
            cDesc  := "**** Gerado Automaticamente." + _ENTER + cDscAss() + _ENTER + "Produto: " + AllTrim(aGrAtv[nX][08])
            cPropr := Propriet( aGrAtv[nX][3] )
            cContato := ""
            SA1->(DbSetOrder(1))
            SA1->(DbSeek(xFilial('SA1') + aGrAtv[nX][3]))
            AC8->(DbSetOrder(2))
            If AC8->(DbSeek(xFilial('AC8') + 'SA1' + xFilial('SA1') + SA1->(A1_COD + A1_LOJA)))
               SU5->(DbSetOrder(1))
               If SU5->(DbSeek(xFilial('SU5') + AC8->AC8_CODCON))
                  If SU5->U5_XPADRAO == 'S'
                     cContato := AC8->AC8_CODCON
                     cTel     := SU5->U5_FONE
                     cDDD     := SU5->U5_DDD
                  EndIf
               EndIf
            EndIf
            oModelCRM:LoadValue( "AOF_FILIAL", xFilial( "AOF" ) )
            oModelCRM:LoadValue( "AOF_TIPO",   "1" )
            oModelCRM:LoadValue( "AOF_ASSUNT", ALLTRIM(STR(IIF(ValType(MV_PAR29) == 'C', Val(MV_PAR29),MV_PAR29))) )
            oModelCRM:LoadValue( "AOF_DESCRI", cDesc )
            oModelCRM:LoadValue( "AOF_CHAVE",  aGrAtv[nX][3] )
            oModelCRM:LoadValue( "AOF_DTINIC", dDatabase )
            oModelCRM:LoadValue( "AOF_DTFIM",  dDatabase + 7 )
            oModelCRM:LoadValue( "AOF_STATUS", "1" )
            oModelCRM:LoadValue( "AOF_PRIORI", "2" )
            oModelCRM:LoadValue( "AOF_PERCEN", "1" )
            oModelCRM:LoadValue( "AOF_CODUSR", cPropr )
            oModelCRM:LoadValue( "AOF_DESTIN", CRM170Inic( FwFldGet( "AOF_ENTIDA" ), FwFldGet( "AOF_CHAVE" ) ) )     
            oModelCRM:LoadValue( "AOF_CODUSR", RetCodUsr() )
            oModelCRM:LoadValue( "AOF_OBS"   , POSICIONE('SA3',1,xFilial('SA3') +SA1->A1_VEND, 'A3_CODUSR' ) )
            oModelCRM:LoadValue( "AOF_XRESP"   , POSICIONE('SA3',1,xFilial('SA3') +SA1->A1_VEND, 'A3_NOME' ) )
            oModelCRM:LoadValue( "AOF_DTLEMB"   , MV_PAR30 )
            oModelCRM:LoadValue( "AOF_XCONT"   , cContato )
            oModelCRM:LoadValue( "AOF_XTEL"   , cTel )
            oModelCRM:LoadValue( "AOF_XDDD"   , cDDD )
            oModelCRM:LoadValue( "AOF_PRIORI"   , cPriori )

            FwFormCommit(oModel)
         // Desativamos o Model
            oModel:DeActivate()
            oModel:Destroy()
            oModel:=NIL   
         EndIf
      NexT
      MsgInfo('Processamento realizado com sucesso!')
      oDlgCons:End() // Fecha a janela de geracao de atividades CRM.
   EndIf
EndIf
RestArea( aArea )
Return      

//**********

Static Function InvMrk()

local nXCnt  := 0

For nXCnt := 1 to Len( aGrAtv )
   aGrAtv[nXCnt][11] := .F. // Desmarca  (era !aGrAtv[nXCnt][11]// Inverte Marcação)
NexT

Return Nil

//**********

Static Function MrkTodos( )

local nXCnt  := 0

For nXCnt := 1 to Len( aGrAtv )
   aGrAtv[nXCnt][11] := .T.  // Marca
NexT

Return Nil

//**********

Static Function Ordena (nCol)

If aOrders[nCol]                                
	ASORT(aGrAtv ,,, { | x,y | x[aColunas[nCol]] > y[aColunas[nCol]] } )
Else
	ASORT(aGrAtv ,,, { | x,y | x[aColunas[nCol]] < y[aColunas[nCol]] } )
Endif

aOrders[nCol] := !aOrders[nCol]

oBrwGA:Refresh()

Return

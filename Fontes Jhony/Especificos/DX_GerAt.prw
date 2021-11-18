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
      MsgInfo( OEMToANSI( "Não foram encontrados orçamentos para Geração de Atividades para o CRM." ), OEMToANSI( "*Geração de Atividades" ) )
      RestArea( aArea )
      Return( Nil )
   EndIf

   Define Font   oFonte Name "Courier New" Size 00, 24 Bold
   Define MSDialog oDlgCons Title OEMToANSI( "*Geração de Atividades" ) From 20, 0 To 480, 1200 /*950*/ Pixel
   /*-----------------------------------------------------------------------------------+
   | @ 020, 010 Say OEMToANSI( "Qtde. Itens por Página: " ) + cCfgPag Pixel FONT oFonte | (reservado para mensagens)
   +-----------------------------------------------------------------------------------*/
   oBrwGA := TCBrowse():New( 010, 005, 590, 190,,,, oDlgCons,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
   oBrwGA:bLDblClick := { || iIf( oBrwGA:ColPos==9, MarcaSN(), .F. ) }
   oBrwGA:AddColumn( TCColumn():New( "Motivo"         , { || aGrAtv[oBrwGA:nAt,02] },,,,, 25, .F., .F.,,,, .F., ) )
   oBrwGA:AddColumn( TCColumn():New( "Cliente"        , { || aGrAtv[oBrwGA:nAt,04] },,,,, 50, .F., .F.,,,, .F., ) )
   oBrwGA:AddColumn( TCColumn():New( "Situação"       , { || aGrAtv[oBrwGA:nAt,05] },,,,, 40, .F., .F.,,,, .F., ) )
   oBrwGA:AddColumn( TCColumn():New( "Qtde.Orç."      , { || aGrAtv[oBrwGA:nAt,06] }, "@E 99,999.99",,,, 45, .F., .F.,,,, .F., ) )
   oBrwGA:AddColumn( TCColumn():New( "Cod.Produto"    , { || aGrAtv[oBrwGA:nAt,07] },,,,, 45, .F., .F.,,,, .F., ) )
   oBrwGA:AddColumn( TCColumn():New( "Produto"        , { || aGrAtv[oBrwGA:nAt,08] },,,,, 45, .F., .F.,,,, .F., ) )
   oBrwGA:AddColumn( TCColumn():New( "Qtde.Produto"   , { || aGrAtv[oBrwGA:nAt,09] }, "@E 99,999,999.99",,,, 45, .F., .F.,,,, .F., ) )
   oBrwGA:AddColumn( TCColumn():New( "Valor Total"    , { || aGrAtv[oBrwGA:nAt,10] }, "@E 999,999,999.99",,,, 45, .F., .F.,,,, .F., ) )
   oBrwGA:AddColumn( TCColumn():New( "Gera Atividade?", { || iIf( aGrAtv[oBrwGA:nAt,11], oOk, oNo ) },,,,,20, .T., .F.,,,, .F., ) )
   oBrwGA:SetArray( aGrAtv )
   oBrwGA:bWhen := { || Len( aGrAtv ) > 0 }
   oBtnOk     := tButton():New( 210, 490, "Ok",       oDlgCons, { || GravarGA() }, 40, 12,,,, .T.,,,, { || },, )
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
Private cCadastro := OEMToANSI( "Geração de Atividades" )

nQtSit_ := Len( aSituacao ) // Variavel private de quantidade de situacoes do cliente (A1_XSITUA)

/*-----------------------------------------------------+
| Parametro "Data de? / Data ate?"                     |
+-----------------------------------------------------*/
aAdd( aParamBox, { 1, "Data de",  CtoD( Space( 8 ) ), "", "", "", "", 50, .F. } ) // Data de?
aAdd( aParamBox, { 1, "Data até", CtoD( Space( 8 ) ), "", "", "", "", 50, .F. } ) // Data ate?

/*-----------------------------------------------------+
| Parametro "Vendedor de? / Vendedor ate?"             |
+-----------------------------------------------------*/
aAdd( aParamBox, { 1, "Vendedor de",  Space( TamSX3("A3_COD")[1] ),          "", "", "SA3", "", TamSX3("A3_COD")[1], .F. } ) // Vendedor de?
aAdd( aParamBox, { 1, "Vendedor até", Replicate( "Z", TamSX3("A3_COD")[1] ), "", "", "SA3", "", TamSX3("A3_COD")[1], .F. } ) // Vendedor ate?

/*-----------------------------------------------------+
| Parametro "Equipe de? / Equipe ate?"                 |
+-----------------------------------------------------*/
aAdd( aParamBox, { 1, "Equipe de",  Space( TamSX3("ACA_GRPREP")[1] ),          "", "", "ACA", "", TamSX3("ACA_GRPREP")[1], .F. } ) // Equipe de?
aAdd( aParamBox, { 1, "Equipe até", Replicate( "Z", TamSX3("ACA_GRPREP")[1] ), "", "", "ACA", "", TamSX3("ACA_GRPREP")[1], .F. } ) // Equipe ate?

/*-----------------------------------------------------+
| Parametro "Un.Neg de? / Un.Neg ate?"                 |
+-----------------------------------------------------*/
aAdd( aParamBox, { 1, "Un.Neg de",  Space( TamSX3("ADK_COD")[1] ),          "", "", "ADK", "", TamSX3("ADK_COD")[1], .F. } ) // Unidade de Negocio de?
aAdd( aParamBox, { 1, "Un.Neg até", Replicate( "Z", TamSX3("ADK_COD")[1] ), "", "", "ADK", "", TamSX3("ADK_COD")[1], .F. } ) // Unidade de Negocio ate?

/*-----------------------------------------------------+
| Parametro "Fam.Prod. de? / Fam.Prod. ate?"           |
+-----------------------------------------------------*/
aAdd( aParamBox, { 1, "Fam.Prod. de",  Space( TamSX3("Z1_COD")[1] ),          "", "", "SZ1", "", TamSX3("Z1_COD")[1], .F. } ) // Familia Produto de?
aAdd( aParamBox, { 1, "Fam.Prod. até", Replicate( "Z", TamSX3("Z1_COD")[1] ), "", "", "SZ1", "", TamSX3("Z1_COD")[1], .F. } ) // Familia Produto ate?

/*-----------------------------------------------------+
| Parametro "Lin.Prod. de? / Lin.Prod. ate?"           |
+-----------------------------------------------------*/
aAdd( aParamBox, { 1, "Linha Prod. de",  Space( TamSX3("Z2_COD")[1] ),          "", "", "SZ2", "", TamSX3("Z2_COD")[1], .F. } ) // Linha Produto de?
aAdd( aParamBox, { 1, "Linha Prod. até", Replicate( "Z", TamSX3("Z2_COD")[1] ), "", "", "SZ2", "", TamSX3("Z2_COD")[1], .F. } ) // Linha Produto ate?

/*-----------------------------------------------------+
| Parametro "Grupo Prod. de? / Grupo Prod. ate?"       |
+-----------------------------------------------------*/
aAdd( aParamBox, { 1, "Grupo Prod. de",  Space( TamSX3("Z3_COD")[1] ),          "", "", "SZ3", "", TamSX3("Z3_COD")[1], .F. } ) // Grupo Produto de?
aAdd( aParamBox, { 1, "Grupo Prod. até", Replicate( "Z", TamSX3("Z3_COD")[1] ), "", "", "SZ3", "", TamSX3("Z3_COD")[1], .F. } ) // Grupo Produto ate?

/*-----------------------------------------------------+
| Parametro "Produto de? / Produto ate?"               |
+-----------------------------------------------------*/
aAdd( aParamBox, { 1, "Produto de",      Space( TamSX3("B1_COD")[1] ),          "", "", "SB1", "", /*TamSX3("B1_COD")[1]*/ 80, .F. } ) // Produto de?
aAdd( aParamBox, { 1, "Produto ate",     Replicate( "Z", TamSX3("B1_COD")[1] ), "", "", "SB1", "", /*TamSX3("B1_COD")[1]*/ 80, .F. } ) // Produto ate?

/*-----------------------------------------------------+
| Parametro "Cliente de? / Cliente ate?"               |
+-----------------------------------------------------*/
aAdd( aParamBox, { 1, "Cliente de",      Space( TamSX3("A1_COD")[1] ),          "", "", "SA1", "", TamSX3("A1_COD")[1], .F. } ) // Cliente de?
aAdd( aParamBox, { 1, "Cliente ate",     Replicate( "Z", TamSX3("A1_COD")[1] ), "", "", "SA1", "", TamSX3("A1_COD")[1], .F. } ) // Cliente ate?

/*-----------------------------------------------------+
| Parametro "Lj Cliente de? / Lj Cliente ate?"         |
+-----------------------------------------------------*/
aAdd( aParamBox, { 1, "Lj Cliente de",   Space( TamSX3("A1_LOJA")[1] ),          "", "", "SA1", "", TamSX3("A1_LOJA")[1], .F. } ) // Lj Cliente de?
aAdd( aParamBox, { 1, "Lj Cliente ate",  Replicate( "Z", TamSX3("A1_LOJA")[1] ), "", "", "SA1", "", TamSX3("A1_LOJA")[1], .F. } ) // Lj Cliente ate?

/*-----------------------------------------------------+
| Parametro "Regiao de? / Regiao ate?"                 |
+-----------------------------------------------------*/
aAdd( aParamBox, { 1, "Regiao de",       Space( 3 ),          "", "", "A2", "", 3, .F. } ) // Regiao de?
aAdd( aParamBox, { 1, "Regiao ate",      Replicate( "Z", 3 ), "", "", "A2", "", 3, .F. } ) // Regiao ate?

/*-----------------------------------------------------+
| Parametro "Estado de? / Estado ate?"                 |
+-----------------------------------------------------*/
aAdd( aParamBox, { 1, "Estado de",       Space( 2 ),   "", "", "12", "", 5, .F. } ) // Estado de?
aAdd( aParamBox, { 1, "Estado ate",      "ZZ",         "", "", "12", "", 5, .F. } ) // Estado ate?

/*-----------------------------------------------------+
| Parametro "Cidade de? / Cidade ate?"                 |
+-----------------------------------------------------*/
aAdd( aParamBox, { 1, "Cidade de",       Space( TamSX3("A1_COD_MUN")[1] ),          "", "", "CC2SA1", "", TamSX3("A1_COD_MUN")[1], .F. } ) // Cidade de?
aAdd( aParamBox, { 1, "Cidade ate",      Replicate( "Z", TamSX3("A1_COD_MUN")[1] ), "", "", "CC2SA1", "", TamSX3("A1_COD_MUN")[1], .F. } ) // Cidade ate?

/*-----------------------------------------------------+
| Parametro "Grp.Venda de? / Grp.Venda ate?"           |
+-----------------------------------------------------*/
aAdd( aParamBox, { 1, "Grp.Venda de",    Space( TamSX3("A1_GRPVEN")[1] ),          "", "", "ACY", "", TamSX3("A1_GRPVEN")[1], .F. } ) // Grp.Venda de?
aAdd( aParamBox, { 1, "Grp.Venda ate",   Replicate( "Z", TamSX3("A1_GRPVEN")[1] ), "", "", "ACY", "", TamSX3("A1_GRPVEN")[1], .F. } ) // Grp.Venda ate?

/*-----------------------------------------------------+
| Parametro Assunto                                    |
+-----------------------------------------------------*/
aAdd( aParamBox, { 2, "Assunto", "1", CntCBox( "AOF_ASSUNT" ), 100, "", .F. } ) // Assunto?

/*-----------------------------------------------------+
| Parametro Data de Atividade                          |
+-----------------------------------------------------*/
aAdd( aParamBox, { 1, "Data Ativid.",  CtoD( Space( 8 ) ), "", "", "", "", 50, .F. } ) // Data de Atividade?

/*-----------------------------------------------------+
| Parametro Descricao                                  |
+-----------------------------------------------------*/
aAdd( aParamBox, { 1, "Descricao", Space( TamSX3("ZA_CODIGO")[1] ), "", "", "SZA", "", TamSX3("ZA_CODIGO")[1], .F. } ) // Descricao?

/*-----------------------------------------------------+
| Parametro Situacao (via checkbox)                    |
+-----------------------------------------------------*/
lPrim := .T.
If .not. Empty( aSituacao )
   For nX := 1 to Len( aSituacao )
       If lPrim
          aAdd( aParamBox, { 4, "Situacao", .F., aSituacao[ nX ], 90, "", .F. } ) // Situacao
          lPrim := .F.
       Else
          aAdd( aParamBox, { 4,         "", .F., aSituacao[ nX ], 90, "", .F. } ) // Situacao
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
If ParamBox( aParamBox, OEMToANSI( "Parâmetros" ), @aRet )
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
cQuery += "         SUM(SCK.CK_QTDVEN)       AS  QTDE_TOTAL, " + _ENTER
cQuery += "         SUM(SCK.CK_VALOR)        AS  VALOR_TOTAL, " + _ENTER
cQuery += "         COUNT(SCK.CK_NUM)        AS  QTDE_ORC, " + _ENTER
cQuery += "         SCJ.CJ_CLIENTE           AS  CLIENTE, " + _ENTER
cQuery += "         SCJ.CJ_LOJA              AS  LOJACLI, " + _ENTER
cQuery += "         SCJ.CJ_XNOME             AS  NOMECLI, " + _ENTER
cQuery += "         SCK.CK_XMOTIVO           AS  MOTIVO " + _ENTER
cQuery += "FROM SCJ010 SCJ, SCK010 SCK " + _ENTER
cQuery += "WHERE SCJ.CJ_EMISSAO  BETWEEN '" + DtoS( MV_PAR01 ) + "' AND '" + DtoS( MV_PAR01 ) + "' " + _ENTER
cQuery += "      AND  SCJ.CJ_FILIAL = '" + xFilial( "SCJ" ) + "'" + _ENTER
cQuery += "      AND  SCK.CK_FILIAL = '" + xFilial( "SCK" ) + "'" + _ENTER
cQuery += "      AND  SCJ.CJ_CLIENTE  BETWEEN '  " + MV_PAR17 + "' AND '" + MV_PAR18 + "' " + _ENTER
cQuery += "      AND  SCJ.CJ_LOJA BETWEEN '" + MV_PAR19 + "' AND '" + MV_PAR20 + "' " + _ENTER
cQuery += "      AND  SCJ.CJ_XVEND BETWEEN '" + MV_PAR03   + "' AND '" + MV_PAR04 + "' " + _ENTER
cQuery += "      AND  SCK.CK_NUM = SCJ.CJ_NUM " + _ENTER

cQryMot := _cMotivo() // Insercao de motivos no processo de selecao.
If .not. Empty( cQryMot )
   cQuery += cQryMot 
EndIf

cQuery += "      AND SCJ.D_E_L_E_T_ = ' ' " + _ENTER
cQuery += "      AND SCK.D_E_L_E_T_ = ' ' " + _ENTER
cQuery += "GROUP BY SCK.CK_PRODUTO, SCJ.CJ_XVEND, SCK.CK_VALOR, SCK.CK_XMOTIVO, SCJ.CJ_CLIENTE, SCJ.CJ_LOJA, SCJ.CJ_XNOME " + _ENTER
cQuery += "ORDER BY SCJ.CJ_CLIENTE, SCJ.CJ_LOJA " + _ENTER

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
   MsgAlert( OEMToANSI( "Não há item(ns) marcado(s) para separação. Favor verificar!" ), OEMToANSI( "*Geração de Atividades" ) )
Else
   If MsgYesNo( "Confirma a geração das atividades CRM para os itens marcados?", "*Geração de Atividades" )
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
      If .not. ( ( SA1->A1_CDRDES  >= MV_PAR21 .and. SA1->A1_CDRDES  <= MV_PAR22 ) .and.;
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
                   /* 12-Cod.Vend.  */ GAQRY->VENDEDOR } )

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

For nX := 1 to Len( aGrAtv )

    If aGrAtv[nX][11] // Tarefa marcada pelo usuario 

       oModel:SetOperation( 3 ) // 3, de Insercao
       oModel:Activate()

       /*-----------------------------------------------------------------+
       | Carrega os campos da tabela AOF com os conteudos da array aGrAtv |
       +-----------------------------------------------------------------*/
       cDesc  := "*** Gerado Automaticamente." + _ENTER + cDscAss()
       cPropr := Propriet( aGrAtv[nX][3] )

       oModelCRM:LoadValue( "AOF_FILIAL", xFilial( "AOF" ) )
       oModelCRM:LoadValue( "AOF_TIPO",   "1" )
       oModelCRM:LoadValue( "AOF_ASSUNT", MV_PAR29 )
       oModelCRM:LoadValue( "AOF_DESCRI", cDesc )
       oModelCRM:LoadValue( "AOF_CHAVE",  aGrAtv[nX][3] )
       oModelCRM:LoadValue( "AOF_DTINIC", MV_PAR30 )
       oModelCRM:LoadValue( "AOF_DTFIM",  MV_PAR30 )
       oModelCRM:LoadValue( "AOF_STATUS", "1" )
       oModelCRM:LoadValue( "AOF_PRIORI", "2" )
       oModelCRM:LoadValue( "AOF_PERCEN", "1" )
       oModelCRM:LoadValue( "AOF_CODUSR", cPropr )
       oModelCRM:LoadValue( "AOF_DESCRE", CRM170Inic( FwFldGet( "AOF_ENTIDA" ), FwFldGet( "AOF_CHAVE" ) ) )   
       oModelCRM:LoadValue( "AOF_DESTIN", CRM170Inic( FwFldGet( "AOF_ENTIDA" ), FwFldGet( "AOF_CHAVE" ) ) )     
       oModelCRM:LoadValue( "AOF_CODUSR", RetCodUsr() )

       FWExecView( OEMToANSI( "*Inclusão via Customização" ), "VIEWDEF.CRMA180", MODEL_OPERATION_INSERT,, { || .T. },, /*nPerReducTela*/,,,,, oModel )

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
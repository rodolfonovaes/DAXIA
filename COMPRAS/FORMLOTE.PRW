#INCLUDE "PROTHEUS.CH"
#Define  _ENTER  Chr( 13 ) + Chr( 10 )
/*/{Protheus.doc} FormLote
Lote gerado no apontamento de producao, funcao informada no campo B1_FORMLOT
@type function
@author B. Vinicius
@since 23/08/2019
@version 1.0
@return ${return}, ${return_description}
/*/

User Function FormLote()
Local aArea    := GetArea()
Local aAreaSC2 := SC2->( GetArea() )
Local cRet     := ""
Local cOp      := ""
Local cLtAtu   := ""
Local cLtOut   := ""
Local cCond1   := ""
Local cCond2   := ""
Local cCond3   := ""
Local cFormLot := AllTrim( SuperGetMV( "MV_FORMLOT",, "XXX" ) )

/*--------------------------------------------------------------+
| Captura o lote atual gravado no campo C2_XLOTE (se o campo    |
| C2_XLOTE estiver vazio, e' gerado o novo lote atraves da      |
| Formula( MV_FORMLOT ).                                             |
+--------------------------------------------------------------*/
If IsInCallStack( "MATA681" ) .or. IsInCallStack( "ACDV025" )
   If .not. Empty( SC2->C2_XLOTE )
      If .not. Empty( SC2->C2_XULOTE )
         cLtAtu := SC2->C2_XULOTE
         cRet   := cLtAtu
      Else
         cLtAtu := SC2->C2_XLOTE
         cRet   := cLtAtu
      EndIf
   Else
      cLtAtu := Formula( cFormLot )
      cRet   := cLtAtu
   EndIf
Else
   cLtAtu := Formula( cFormLot )
   cRet   := cLtAtu
EndIf
   
If IsInCallStack( "MATA681" ) .or. IsInCallStack( "ACDV025" )

   cOp := u_UltOper() // Busca a ultima operacao do roteiro de processo PCP.

   /*--------------------------------------------------+
   | Define qual condicional usar - MATA681 ou ACDV025 |
   +--------------------------------------------------*/
   If IsInCallStack( "MATA681" )
      cCond1 := 'MsgYesNo( OEMToANSI( "Manter o mesmo Lote " + AllTrim( cLtAtu ) + " ?" ), OEMToANSI( "*Gerenciamento Lote" ) )'
      cCond2 := 'MsgInfo( OEMToANSI( "O novo lote é " + AllTrim( cRet ) + "." ), OEMToANSI( "*Gerenciamento Lote" ) )'
      cCond3 := 'SH6->H6_OPERAC == cOp'
   Else
      cCond1 := 'WMSVTAviso( "*Troca Lote", "Mantem o Lote " + AllTrim( cLtAtu ) + "?", { "Sim", "Nao" } ) == 1'
      cCond2 := 'WMSVTAviso( "*Ger.Lote", "Novo lote " + AllTrim( cRet ) )'
      cCond3 := 'cUltOper == cOp' // a variavel cUltOper e' tipo Private e foi criada no programa-padrao ACDV025.prg
   EndIf

   If &cCond3
      If u_Mais1FimOP()
         If &cCond1 // Janela dialog (S/N) para se confirma manter o mesmo lote
            cRet := cLtAtu
         Else
            /*--------------------------------------------------------------+
            | Busca o proximo lote                                          |
            +--------------------------------------------------------------*/
            cLtOut := NextLote() // Funcao padrao AdvPL que captura o proximo lote para ser criado no SB8.
            cRet := cLtOut
            &cCond2 // Janela de Aviso de troca de lote do MATA681 ou ACDV025
         EndIf
      Else
         cRet := cLtAtu
      EndIf
   EndIf

   /*------------------------------------------------------------+
   | Atualiza o campo C2_XULOTE com o lote selecionado pelo      |
   | usuario para fins de pesquisa no ponto de entrada MT681INC. |
   +------------------------------------------------------------*/
   DbSelectArea ( "SC2" )
   SC2->( DbSetOrder ( 1 ) ) // C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD
   If SC2->( DbSeek( C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN ) )
      RecLock( "SC2", .F. )
      Replace SC2->C2_XULOTE With cRet
      SC2->( MSUnLock() )
   EndIf

EndIf

RestArea( aAreaSC2 )
RestArea( aArea )
Return( cRet )

/*======================================================================================+
| Funcao de Usuario ..:   UltOper()                                                     |
| Autores ............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   28/09/2019                                                    |
| Descricao / Objetivo:   Funcao de usuario que captura a ultima operacao do produto do |
|                         cadastro de roteiro de operacoes (SG2).                       |
| Doc. Origem.........:   MIT044                                                        |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
User Function UltOper()
Local aArea := GetArea()

/*---------------------------------------------+
| Acessa o SG2 para buscar o codigo de operacao|
+---------------------------------------------*/
DbSelectArea( "SG2" )
DbSetOrder( 1 ) // G2_FILIAL + G2_PRODUTO + G2_CODIGO + G2_OPERAC
If DbSeek( xFilial( "SG2" ) + SC2->C2_PRODUTO + SC2->C2_ROTEIRO )
   Do While SG2->( G2_FILIAL + G2_PRODUTO + G2_CODIGO ) == ( xFilial( "SG2" ) + SC2->C2_PRODUTO + SC2->C2_ROTEIRO ) .and.;
            .not. SG2->( EoF() )
      cOp   := SG2->G2_OPERAC
      SG2->( DbSkiP() )
   EndDo
EndIf

RestArea( aArea )
Return( cOp )

/*======================================================================================+
| Funcao de Usuario ..:   Mais1FimOP()                                                  |
| Autores ............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   02/10/2019                                                    |
| Descricao / Objetivo:   Funcao de usuario que verifica se tem mais de OP com ultima   |
|                         operacoes (quando o apontamento da OP for parcial).           |
| Doc. Origem.........:   MIT044                                                        |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
User Function Mais1FimOP()
Local aArea    := GetArea()
Local aAreaSH6 := SH6->( GetArea() ) 
Local lRet     := .F.
Local nCnt     := 0
Local cUltOp   := u_UltOper() // Verifica qual a ultima operacao da OP
Local cKeySH6  := ""

cKeySH6 := SC2->( C2_FILIAL + C2_NUM + C2_ITEM + C2_SEQUEN + Space( 3 ) + C2_PRODUTO ) + cUltOp 

DbSelectArea( "SH6" ) // Cadastro de Apontamentos da OP
DbSetOrder( 1 ) // H6_FILIAL + H6_OP + H6_PRODUTO + H6_OPERAC + H6_SEQ + DTOS(H6_DATAINI) + H6_HORAINI + DTOS(H6_DATAFIN) + H6_HORAFIN
If DbSeek( cKeySH6 )
   Do While ( H6_FILIAL + H6_OP + H6_PRODUTO + H6_OPERAC ) == cKeySH6 .and. .not. SH6->( EoF() )
      nCnt++
      SH6->( DbSkiP() )
   EndDo

   If nCnt > 1 // Porque tem mais OP com mais de uma operacao final (apontamento parcial)
      lRet := .T.
   EndIf
EndIf

RestArea( aAreaSH6 )
RestArea( aArea )
Return( lRet )

/*======================================================================================+
| Funcao de Usuario ..:   SB8Valid()                                                    |
| Autores ............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   02/10/2019                                                    |
| Descricao / Objetivo:   Funcao de usuario que trata as validade do produto, data de   |
|                         fabricacao e pais de origem.                                  |
| Doc. Origem.........:   MIT044 - - R01PT - Especificação de Personalização - Aponta-  |
|                         mento PCP MOD2 - item 20.                                     |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
User Function SB8Valid()
Local aArea    := GetArea()
Local aAreaSB8 := SB8->( GetArea() ) 
Local cFilSH6  := SH6->H6_FILIAL 
Local cProdSH6 := SH6->H6_PRODUTO
Local cOP_     := SH6->H6_OP
Local cLoteCTL := PADR(SC2->C2_XULOTE,TamSX3('B8_LOTECTL')[1])
//Local cLoteCTL := AllTrim( SuperGetMV( "ES_LOTECTL",, "XXXXXX" ) ) + Space( TamSX3( "B8_LOTECTL" )[1] - Len( AllTrim( SuperGetMV( "ES_LOTECTL",, "XXXXXX" ) ) ) )
Local cDoc     := Left( SH6->H6_OP, 6 ) + Space( TamSX3( "B8_DOC" )[1] - Len( Left( SH6->H6_OP, 6 ) ) )
Local cXMAMTEM := ""
Local dDVlSB81 := CtoD( Space( 8 ) )
Local dDVldSB8 := CtoD( Space( 8 ) )
Local dDFabSB8 := CtoD( Space( 8 ) )
Local nDiasVld := iIf( SB1->( DbSeek( xFilial( "SB1" ) + SH6->H6_PRODUTO ) ), SB1->B1_PRVALID, 0 )
Local cTMPad   := AllTrim( SuperGetMV( "MV_TMPAD",, "XXX" ) )
Local cNumSeq  := SD5->D5_NUMSEQ
Local cIdent   := SH6->H6_IDENT
Local cUltOpe  := SG2->G2_OPERAC

/*------------------------------------------------------------+
| Busca o tipo de regra de calculo de fabricacao e validade   |
| atraves do cadastro de Roteiro de Operacoes.                |
+------------------------------------------------------------*/
DbSelectArea( "SG2" )
DbSetOrder( 1 ) // G2_FILIAL + G2_PRODUTO + G2_CODIGO + G2_OPERAC

If DbSeek( SC2->( C2_FILIAL + C2_PRODUTO + SC2->C2_ROTEIRO ) )
   Do While SG2->( G2_FILIAL + G2_PRODUTO + G2_CODIGO ) == ( SC2->C2_FILIAL + SC2->C2_PRODUTO + SC2->C2_ROTEIRO )
      If !Empty(SG2->G2_XMAMTEM)
         cXMAMTEM := SG2->G2_XMAMTEM
         cUltOpe  := SG2->G2_OPERAC
         Exit
      EndIf
      SG2->( DbSkip() )
   EndDo
EndIf

If Empty( cXMAMTEM )
   If IsInCallStack( "MATA681" )
      MsgAlert( OEMToANSI( "Não foi possível definir regras de datas fabric./validade." ), OEMToANSI( "* Manter Datas" ) )
   Else
      WMSVTAviso( "*G2_XMAMTEM", "G2_XMAMTEM vazio. Verifique." )
   EndIf
ElseIf cXMAMTEM == "1"
       /*---------------------------------+
       | Regra 1 - Regra de Fracionado    |
       +---------------------------------*/
       DbSelectArea( "SD4" )
       DbSetOrder( 2 ) // D4_FILIAL + D4_OP + D4_COD + D4_LOCAL
       If DbSeek( xFilial( "SD4" ) + cOP_ )
          Do While SD4->( D4_FILIAL + D4_OP ) == ( xFilial( "SD4" ) + cOP_ )
             /*-----------------------------------------------------------+
             | Se o campo D4_LOTECTL estiver vazio e' porque o componente |
             | nao tem controle de lote.                                  |
             +-----------------------------------------------------------*/
             If Empty( SD4->D4_LOTECTL )
                SD4->( DbSkiP() )
                LooP 
             EndIf

             /*-----------------------------------------------------------+
             | Inicializa as variaveis.                                   |
             +-----------------------------------------------------------*/
             dDVldSB8 := CtoD( Space( 8 ) )
             dDFabSB8 := CtoD( Space( 8 ) )
             cNomFabr := Space( 20 )
             cPaisOri := Space( 20 )
             cXCFABRI := Space( 20 )
             cXLFABRI := Space( 20 )
             cLotForn := ""

             /*-------------------------------------------------------------------------+
             | Pesquisa no SB1 atraves do campo D4_COD (componente) se o produto atende |
             | 'a condicional de componente francionado (B1_XTPCOMP igual a '1').       |
             +-------------------------------------------------------------------------*/
             DbSelectArea( "SB1" )
             DbSetOrder( 1 ) // B1_FILIAL + B1_COD
             If DbSeek( xFilial( "SB1" ) + SD4->D4_COD )
                If SB1->B1_XTPCOMP == "1" // Componente Fracionado
                   DbSelectArea( "SB8" )
                   DbSetOrder( 7 ) // B8_FILIAL + B8_PRODUTO + B8_LOTECTL + B8_DOC 
                   /*---------------------------------------------------------+
                   | Realiza a busca da Data de Validade, Data de Fabricacao, | 
                   | Nome do Fabricante e Pais de Origem.                     |
                   +---------------------------------------------------------*/
                   If DbSeek( xFilial( "SB8" ) + SD4->( D4_COD + D4_LOTECTL ) )
                      dDVldSB8 := SB8->B8_DTVALID
                      dDFabSB8 := SB8->B8_DFABRIC
                      cLotForn := SB8->B8_LOTEFOR
                      cNomFabr := SB8->B8_NFABRIC
                      cPaisOri := SB8->B8_XPAISOR
                      cXCFABRI := SB8->B8_XCFABRI
                      cXLFABRI := SB8->B8_XLFABRI
                   EndIf

                   /*-------------------------------------------------------------------+
                   | Atualiza o produto origem (MP) com as variaveis Data de Validade,  | 
                   | Data de Fabricacao, Nome do Fabricante e Pais de Origem do produto |
                   | Componente (D4_COD).                                               |
                   +-------------------------------------------------------------------*/
                   If SB8->( DbSeek( cFilSH6 + cProdSH6 + cLoteCTL + cDoc ) )
                      RecLock( "SB8", .F. )
                      Replace SB8->B8_DTVALID With dDVldSB8
                      Replace SB8->B8_DFABRIC With dDFabSB8
                      Replace SB8->B8_NFABRIC With cNomFabr
                      Replace SB8->B8_LOTEFOR With cLotForn 
                      Replace SB8->B8_XPAISOR With cPaisOri
                      Replace SB8->B8_XCFABRI With cXCFABRI
                      Replace SB8->B8_XLFABRI With cXLFABRI
                      SB8->( MSUnLock() )
                   EndIf

                   /*-------------------------------------------------------------------+
                   | Atualiza a Data de Validade do cadastro SD5 (Requisicoes).         | 
                   +-------------------------------------------------------------------*/
                   DbSelectArea ( "SD5" )
                   SD5->( DbSetOrder ( 2 ) ) // D5_FILIAL + D5_PRODUTO + D5_LOCAL + D5_LOTECTL
                   If SD5->( DbSeek ( cFilSH6 + SH6->H6_PRODUTO + SH6->H6_LOCAL + cLoteCTL ) )
                   		Do While SD5-> ( D5_FILIAL + D5_PRODUTO + D5_LOCAL + D5_LOTECTL ) == ( cFilSH6 + SH6->H6_PRODUTO + SH6->H6_LOCAL + cLoteCTL )
                   			If SD5->D5_ORIGLAN == cTMPAD
                   				cNumSeq := SD5->D5_NUMSEQ
                   			Endif
                   			SD5->( DbSkiP() )
                   		EndDo
                   EndIf
                   SD5->( DbOrderNickName ( "D5ORIGLAN" ) ) // D5_FILIAL + D5_NUMSEQ + D5_PRODUTO + D5_LOCAL + D5_LOTECTL + D5_ORIGLAN
                   //If SD5->( DbSeek( cFilSH6 + StrZero( ( Val( SH6->H6_IDENT ) + 1 ), 6 ) + SH6->H6_PRODUTO + SH6->H6_LOCAL + SH6->H6_LOTECTL )  )
                   If SD5->( DbSeek( cFilSH6 + cNumSeq + SH6->H6_PRODUTO + SH6->H6_LOCAL + cLoteCTL + cTMPad)  )
                      RecLock( "SD5", .F. )
                      Replace SD5->D5_LOTECTL With cLoteCTL
                      Replace SD5->D5_DTVALID With dDVldSB8
                      SD5->( MSUnLock() )
                   EndIf

                   /*-------------------------------------------------------------------+
                   | Atualiza o Lote do cadastro SD7 (Movimentos do CQ).                | 
                   +-------------------------------------------------------------------*/
                   SD7->( DbSetOrder( 4 ) ) // D7_FILIAL + D7_LOCAL + D7_PRODUTO + D7_NUMSEQ
                   //If SD7->( DbSeek( cFilSH6 + SH6->H6_LOCAL + SH6->H6_PRODUTO + StrZero( ( Val( SH6->H6_IDENT ) + 1 ), 6 ) ) )                   
                   If SD7->( DbSeek( cFilSH6 + SH6->H6_LOCAL + SH6->H6_PRODUTO + cNumSeq ) )
                      RecLock( "SD7", .F. )
                      Replace SD7->D7_LOTECTL With cLoteCTL
                      Replace SD7->D7_DTVALID With dDVldSB8
                      SD7->( MSUnLock() )
                   EndIf

                   /*------------------------------------------------------------------------------+
                   | Atualiza o Lote e Data de Validade do cadastro SH6 (Movimentação da Produção) |
                   +------------------------------------------------------------------------------*/
                   DbSelectArea ( "SH6" )
                   SH6->( DbSetOrder ( 3 ) ) // H6_FILIAL+H6_PRODUTO+H6_OP+H6_OPERAC+H6_LOTECTL+H6_NUMLOTE
                   If SH6->( DbSeek( SC2->C2_FILIAL + SC2->C2_PRODUTO + SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN + "   " + cUltOpe + cLoteCTL ) )
                   		Do While SH6-> ( H6_FILIAL + H6_PRODUTO + H6_OP + H6_OPERAC + H6_LOTECTL ) == ( SC2->C2_FILIAL + SC2->C2_PRODUTO + SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN + "   " + cUltOpe + cLoteCTL )
                           cIdent := SH6->H6_IDENT
                           SH6->( DbSkiP() )
                        EndDo   
                   EndIf
                   SH6->( DbOrderNickName ( "H6IDENT" ) ) // H6_FILIAL+H6_PRODUTO+H6_OP+H6_OPERAC+H6_LOTECTL+H6_NUMLOTE+H6_IDENT
                   If SH6->( DbSeek ( SC2->C2_FILIAL + SC2->C2_PRODUTO + SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN + "   " + cUltOpe + cLoteCTL + cIdent ) )
                      RecLock( "SH6", .F. )
                      Replace SH6->H6_LOTECTL With cLoteCTL
                      Replace SH6->H6_DTVALID With dDVldSB8
                   Endif
                EndIf
             EndIf
             DbSelectArea( "SD4" )
             SD4->( DbSkiP() )
          EndDo
       EndIf
ElseIf cXMAMTEM == "2"
       /*---------------------------------+
       | Regra 2 - Regra de Glucose       |
       +---------------------------------*/
       DbSelectArea( "SD4" )
       DbSetOrder( 2 ) // D4_FILIAL + D4_OP + D4_COD + D4_LOCAL
       If DbSeek( xFilial( "SD4" ) + cOP_ )
          Do While SD4->( D4_FILIAL + D4_OP ) == ( xFilial( "SD4" ) + cOP_ )
             /*-----------------------------------------------------------+
             | Se o campo D4_LOTECTL estiver vazio e' porque o componente |
             | nao tem controle de lote.                                  |
             +-----------------------------------------------------------*/
             If Empty( SD4->D4_LOTECTL )
                SD4->( DbSkiP() )
                LooP 
             EndIf

             /*-----------------------------------------------------------+
             | Inicializa as variaveis.                                   |
             +-----------------------------------------------------------*/
             dDVlSB81 := CtoD( Space( 8 ) )
             dDVldSB8 := CtoD( Space( 8 ) )
             cLotForn := ""
             cNomFabr := ""
             cPaisOri := Space( 20 )
             cXCFABRI := ""
             cXLFABRI := ""

             /*-------------------------------------------------------------------------+
             | Pesquisa no SB1 atraves do campo D4_COD (componente) se o produto atende |
             | 'a condicional de componente Glucose (B1_XTPCOMP igual a '2').           |
             +-------------------------------------------------------------------------*/
             DbSelectArea( "SB1" )
             DbSetOrder( 1 ) // B1_FILIAL + B1_COD
             If DbSeek( xFilial( "SB1" ) + SD4->D4_COD )
                If SB1->B1_XTPCOMP == "2" // Componente Glucose
                   DbSelectArea( "SB8" )
                   DbSetOrder( 7 ) // B8_FILIAL + B8_PRODUTO + B8_LOTECTL + B8_DOC 
                   /*---------------------------------------------------------+
                   | Realiza a busca da Data de Validade, Data de Fabricacao, | 
                   | Nome do Fabricante e Pais de Origem.                     |
                   +---------------------------------------------------------*/
                   If DbSeek( xFilial( "SB8" ) + SD4->( D4_COD + D4_LOTECTL ) )
                      dDVlSB81 := SB8->B8_DFABRIC
                      dDVldSB8 := ( SB8->B8_DFABRIC + nDiasVld )
                      cLotForn := SB8->B8_LOTEFOR
                      cPaisOri := SB8->B8_XPAISOR
                      cNomFabr := SB8->B8_NFABRIC
                      cXCFABRI := SB8->B8_XCFABRI
                      cXLFABRI := SB8->B8_XLFABRI
                   EndIf

                   /*-------------------------------------------------------------------+
                   | Atualiza o produto origem (MP) com as variaveis Data de Validade,  | 
                   | Lote do Fornecedor e Pais de Origem do produto Componente (D4_COD).|
                   +-------------------------------------------------------------------*/
                   If SB8->( DbSeek( cFilSH6 + cProdSH6 + cLoteCTL + cDoc ) )
                      RecLock( "SB8", .F. )
                      Replace SB8->B8_DFABRIC With dDVlSB81
                      Replace SB8->B8_DTVALID With dDVldSB8
                      Replace SB8->B8_LOTEFOR With cLotForn
                      Replace SB8->B8_NFABRIC With cNomFabr
                      Replace SB8->B8_XPAISOR With cPaisOri
                      Replace SB8->B8_XCFABRI With cXCFABRI
                      Replace SB8->B8_XLFABRI With cXLFABRI
                      SB8->( MSUnLock() )
                   EndIf

                   /*-------------------------------------------------------------------+
                   | Atualiza a Data de Validade do cadastro SD5 (Requisicoes).         | 
                   +-------------------------------------------------------------------*/
                   DbSelectArea ( "SD5" )
                   SD5->( DbSetOrder ( 2 ) ) // D5_FILIAL + D5_PRODUTO + D5_LOCAL + D5_LOTECTL
                   If SD5->( DbSeek ( cFilSH6 + SH6->H6_PRODUTO + SH6->H6_LOCAL + cLoteCTL ) )
                   		Do While SD5-> ( D5_FILIAL + D5_PRODUTO + D5_LOCAL + D5_LOTECTL ) == ( cFilSH6 + SH6->H6_PRODUTO + SH6->H6_LOCAL + cLoteCTL )
                   			If SD5->D5_ORIGLAN == cTMPAD
                   				cNumSeq := SD5->D5_NUMSEQ
                   			Endif
                   			SD5->( DbSkiP() )
                   		EndDo
                   EndIf
                   SD5->( DbOrderNickName ( "D5ORIGLAN" ) ) // D5_FILIAL + D5_NUMSEQ + D5_PRODUTO + D5_LOCAL + D5_LOTECTL + D5_ORIGLAN
                   //If SD5->( DbSeek( cFilSH6 + StrZero( ( Val( SH6->H6_IDENT ) + 1 ), 6 ) + SH6->H6_PRODUTO + SH6->H6_LOCAL + SH6->H6_LOTECTL )  )
                   If SD5->( DbSeek( cFilSH6 + cNumSeq + SH6->H6_PRODUTO + SH6->H6_LOCAL + cLoteCTL + cTMPad)  )
                      RecLock( "SD5", .F. )
                      Replace SD5->D5_LOTECTL With cLoteCTL
                      Replace SD5->D5_DTVALID With dDVldSB8
                      SD5->( MSUnLock() )
                   EndIf

                   /*-------------------------------------------------------------------+
                   | Atualiza o Lote do cadastro SD7 (Movimentos do CQ).                | 
                   +-------------------------------------------------------------------*/
                   SD7->( DbSetOrder( 4 ) ) // D7_FILIAL + D7_LOCAL + D7_PRODUTO + D7_NUMSEQ
                   //If SD7->( DbSeek( cFilSH6 + SH6->H6_LOCAL + SH6->H6_PRODUTO + StrZero( ( Val( SH6->H6_IDENT ) + 1 ), 6 ) ) )                   
                   If SD7->( DbSeek( cFilSH6 + SH6->H6_LOCAL + SH6->H6_PRODUTO + cNumSeq ) )
                      RecLock( "SD7", .F. )
                      Replace SD7->D7_LOTECTL With cLoteCTL
                      SD7->( MSUnLock() )
                   EndIf

                   /*------------------------------------------------------------------------------+
                   | Atualiza o Lote e Data de Validade do cadastro SH6 (Movimentação da Produção) |
                   +------------------------------------------------------------------------------*/
                   DbSelectArea ( "SH6" )
                   SH6->( DbSetOrder ( 3 ) ) // H6_FILIAL+H6_PRODUTO+H6_OP+H6_OPERAC+H6_LOTECTL+H6_NUMLOTE
                   If SH6->( DbSeek( SC2->C2_FILIAL + SC2->C2_PRODUTO + SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN + "   " + cUltOpe + cLoteCTL ) )
                   		Do While SH6-> ( H6_FILIAL + H6_PRODUTO + H6_OP + H6_OPERAC + H6_LOTECTL ) == ( SC2->C2_FILIAL + SC2->C2_PRODUTO + SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN + "   " + cUltOpe + cLoteCTL )
                           cIdent := SH6->H6_IDENT
                           SH6->( DbSkiP() )
                        EndDo   
                   EndIf
                   SH6->( DbOrderNickName ( "H6IDENT" ) ) // H6_FILIAL+H6_PRODUTO+H6_OP+H6_OPERAC+H6_LOTECTL+H6_NUMLOTE+H6_IDENT
                   If SH6->( DbSeek ( SC2->C2_FILIAL + SC2->C2_PRODUTO + SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN + "   " + cUltOpe + cLoteCTL + cIdent ) )
                      RecLock( "SH6", .F. )
                      Replace SH6->H6_LOTECTL With cLoteCTL
                      Replace SH6->H6_DTVALID With dDVldSB8
                      SH6->( MSUnLock() )
                   Endif
                EndIf
             EndIf

             DbSelectArea( "SD4" )
             SD4->( DbSkiP() )
          EndDo
       EndIf
ElseIf cXMAMTEM == "3"
       /*---------------------------------+
       | Regra 3 - Padrao Sistemico       |
       +---------------------------------*/

       /*-----------------------------------------------------------+
       | Inicializa as variaveis.                                   |
       +-----------------------------------------------------------*/
       dDFabSB8 := GetAdvFVal( "SC2", "C2_EMISSAO", cFilSH6 + cOP_, 1, CtoD( Space( 8 ) ) )
       dDVldSB8 := dDFabSB8 + nDiasVld
       cLotForn := Left( cOP_, 6 ) + "/" + StrZero( Year( dDFabSB8 ), 4 )
       cPaisOri := "BRASIL"

       /*-------------------------------------------------------------------+
       | Atualiza o produto origem (MP) com as variaveis Data de Validade,  | 
       | Data de Fabricacao, Nome do Fabricante, Lote do Fabricante e Pais  |
       | de Origem da regra padrao.                                         |
       +-------------------------------------------------------------------*/
       DbSelectArea( "SB8" )
       DbSetOrder( 7 ) // B8_FILIAL + B8_PRODUTO + B8_LOTECTL + B8_DOC 
       If SB8->( DbSeek( cFilSH6 + cProdSH6 + cLoteCTL + cDoc ) )
          RecLock( "SB8", .F. )
          Replace SB8->B8_DFABRIC With dDFabSB8
          Replace SB8->B8_DTVALID With dDVldSB8
          Replace SB8->B8_LOTEFOR With cLotForn
          Replace SB8->B8_XPAISOR With cPaisOri
          SB8->( MSUnLock() )
       EndIf


       /*-------------------------------------------------------------------+
       | Atualiza a Data de Validade do cadastro SD5 (Requisicoes).         | 
       +-------------------------------------------------------------------*/
       DbSelectArea ( "SD5" )
       SD5->( DbSetOrder (2 ) ) // D5_FILIAL + D5_PRODUTO + D5_LOCAL + D5_LOTECTL
       If SD5->( DbSeek ( cFilSH6 + SH6->H6_PRODUTO + SH6->H6_LOCAL + cLoteCTL ) )
          Do While SD5-> ( D5_FILIAL + D5_PRODUTO + D5_LOCAL + D5_LOTECTL ) == ( cFilSH6 + SH6->H6_PRODUTO + SH6->H6_LOCAL + cLoteCTL )
             If SD5->D5_ORIGLAN == cTMPAD
                cNumSeq := SD5->D5_NUMSEQ
             Endif
             SD5->( DbSkiP() )
          EndDo
       EndIf
       SD5->( DbOrderNickName ( "D5ORIGLAN" ) ) // D5_FILIAL + D5_NUMSEQ + D5_PRODUTO + D5_LOCAL + D5_LOTECTL + D5_ORIGLAN
       //If SD5->( DbSeek( cFilSH6 + StrZero( ( Val( SH6->H6_IDENT ) + 1 ), 6 ) + SH6->H6_PRODUTO + SH6->H6_LOCAL + SH6->H6_LOTECTL )  )
       If SD5->( DbSeek( cFilSH6 + cNumSeq + SH6->H6_PRODUTO + SH6->H6_LOCAL + cLoteCTL + cTMPad)  )       
          RecLock( "SD5", .F. )
          Replace SD5->D5_LOTECTL With cLoteCTL
          Replace SD5->D5_DTVALID With dDVldSB8
          SD5->( MSUnLock() )
       EndIf

       /*-------------------------------------------------------------------+
       | Atualiza o Lote do cadastro SD7 (Movimentos do CQ).                | 
       +-------------------------------------------------------------------*/
       SD7->( DbSetOrder( 4 ) ) // D7_FILIAL + D7_LOCAL + D7_PRODUTO + D7_NUMSEQ
       //If SD7->( DbSeek( cFilSH6 + SH6->H6_LOCAL + SH6->H6_PRODUTO + StrZero( ( Val( SH6->H6_IDENT ) + 1 ), 6 ) ) )                   
       If SD7->( DbSeek( cFilSH6 + SH6->H6_LOCAL + SH6->H6_PRODUTO + cNumSeq ) )
          RecLock( "SD7", .F. )
          Replace SD7->D7_LOTECTL With cLoteCTL
          SD7->( MSUnLock() )
          EndIf

       /*------------------------------------------------------------------------------+
       | Atualiza o Lote e Data de Validade do cadastro SH6 (Movimentação da Produção) |
       +------------------------------------------------------------------------------*/
       DbSelectArea ( "SH6" )
       SH6->( DbSetOrder ( 3 ) ) // H6_FILIAL+H6_PRODUTO+H6_OP+H6_OPERAC+H6_LOTECTL+H6_NUMLOTE
       If SH6->( DbSeek( SC2->C2_FILIAL + SC2->C2_PRODUTO + SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN + "   " + cUltOpe + cLoteCTL ) )
          Do While SH6-> ( H6_FILIAL + H6_PRODUTO + H6_OP + H6_OPERAC + H6_LOTECTL ) == ( SC2->C2_FILIAL + SC2->C2_PRODUTO + SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN + "   " + cUltOpe + cLoteCTL )
             cIdent := SH6->H6_IDENT
             SH6->( DbSkiP() )
          EndDo   
       EndIf
       SH6->( DbOrderNickName ( "H6IDENT" ) ) // H6_FILIAL+H6_PRODUTO+H6_OP+H6_OPERAC+H6_LOTECTL+H6_NUMLOTE+H6_IDENT
       If SH6->( DbSeek ( SC2->C2_FILIAL + SC2->C2_PRODUTO + SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN + "   " + cUltOpe + cLoteCTL + cIdent ) )
          RecLock( "SH6", .F. )
          Replace SH6->H6_LOTECTL With cLoteCTL
          Replace SH6->H6_DTVALID With dDVldSB8
          SH6->( MSUnLock() )
       Endif

EndIf

RestArea( aArea )
RestArea( aAreaSB8 )
Return( Nil )

/*======================================================================================+
| Funcao de Usuario ..:   SB8DtValid()                                                  |
| Autores ............:   Jose Luis Bernardes                                           |
| Data................:   26/11/2019                                                    |
| Descricao / Objetivo:   Funcao de usuario que trata a validade do produto             |
| Doc. Origem.........:   MIT044 - - R01PT - Especificação de Personalização - Aponta-  |
|                         mento PCP MOD2 - item 20.                                     |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
User Function SB8DtValid()
Local aArea    := GetArea()
Local aAreaSB8 := SB8->( GetArea() ) 
Local cFilSH6  := SC2->C2_FILIAL 
Local cOP_     := SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN
Local cXMAMTEM := ""
Local dDVldSB8 := CtoD( Space( 8 ) )
Local dDFabSB8 := CtoD( Space( 8 ) )
Local nDiasVld := iIf( SB1->( DbSeek( xFilial( "SB1" ) + SC2->C2_PRODUTO ) ), SB1->B1_PRVALID, 0 )
Local cUltOpe  := SG2->G2_OPERAC

/*------------------------------------------------------------+
| Seta a data de validade a partir da EMISSÃO da OP           |
+------------------------------------------------------------*/
dDVldSB8 := dDataBase+nDiasVld

/*------------------------------------------------------------+
| Busca o tipo de regra de calculo de fabricacao e validade   |
| atraves do cadastro de Roteiro de Operacoes.                |
+------------------------------------------------------------*/
DbSelectArea( "SG2" )
DbSetOrder( 1 ) // G2_FILIAL + G2_PRODUTO + G2_CODIGO + G2_OPERAC

If DbSeek( SC2->( C2_FILIAL + C2_PRODUTO + SC2->C2_ROTEIRO ) )
   Do While SG2->( G2_FILIAL + G2_PRODUTO + G2_CODIGO ) == ( SC2->C2_FILIAL + SC2->C2_PRODUTO + SC2->C2_ROTEIRO )
      cXMAMTEM := SG2->G2_XMAMTEM
      cUltOpe  := SG2->G2_OPERAC
      SG2->( DbSkip() )
   EndDo
EndIf

If Empty( cXMAMTEM )
   If IsInCallStack( "MATA681" )
      MsgAlert( OEMToANSI( "Não foi possível definir regras de datas fabric./validade." ), OEMToANSI( "* Manter Datas" ) )
   Else
      WMSVTAviso( "*G2_XMAMTEM", "G2_XMAMTEM vazio. Verifique." )
   EndIf
ElseIf cXMAMTEM == "1"
       /*---------------------------------+
       | Regra 1 - Regra de Fracionado    |
       +---------------------------------*/
       DbSelectArea( "SD4" )
       DbSetOrder( 2 ) // D4_FILIAL + D4_OP + D4_COD + D4_LOCAL
       If DbSeek( xFilial( "SD4" ) + cOP_ )
          Do While SD4->( D4_FILIAL + D4_OP ) == ( xFilial( "SD4" ) + cOP_ )
             /*-----------------------------------------------------------+
             | Se o campo D4_LOTECTL estiver vazio e' porque o componente |
             | nao tem controle de lote.                                  |
             +-----------------------------------------------------------*/
             If Empty( SD4->D4_LOTECTL )
                SD4->( DbSkiP() )
                LooP 
             EndIf

             /*-------------------------------------------------------------------------+
             | Pesquisa no SB1 atraves do campo D4_COD (componente) se o produto atende |
             | 'a condicional de componente francionado (B1_XTPCOMP igual a '1').       |
             +-------------------------------------------------------------------------*/
             DbSelectArea( "SB1" )
             DbSetOrder( 1 ) // B1_FILIAL + B1_COD
             If DbSeek( xFilial( "SB1" ) + SD4->D4_COD )
                If SB1->B1_XTPCOMP == "1" // Componente Fracionado
                   DbSelectArea( "SB8" )
                   DbSetOrder( 7 ) // B8_FILIAL + B8_PRODUTO + B8_LOTECTL + B8_DOC 
                   /*---------------------------------------------------------+
                   | Realiza a busca da Data de Validade, Data de Fabricacao, | 
                   | Nome do Fabricante e Pais de Origem.                     |
                   +---------------------------------------------------------*/
                   If DbSeek( xFilial( "SB8" ) + SD4->( D4_COD + D4_LOTECTL ) )
                      dDVldSB8 := SB8->B8_DTVALID
                   EndIf
                EndIf
             EndIf
             DbSelectArea( "SD4" )
             SD4->( DbSkiP() )
          EndDo
       EndIf
ElseIf cXMAMTEM == "2"
       /*---------------------------------+
       | Regra 2 - Regra de Glucose       |
       +---------------------------------*/
       DbSelectArea( "SD4" )
       DbSetOrder( 2 ) // D4_FILIAL + D4_OP + D4_COD + D4_LOCAL
       If DbSeek( xFilial( "SD4" ) + cOP_ )
          Do While SD4->( D4_FILIAL + D4_OP ) == ( xFilial( "SD4" ) + cOP_ )
             /*-----------------------------------------------------------+
             | Se o campo D4_LOTECTL estiver vazio e' porque o componente |
             | nao tem controle de lote.                                  |
             +-----------------------------------------------------------*/
             If Empty( SD4->D4_LOTECTL )
                SD4->( DbSkiP() )
                LooP 
             EndIf

             /*-------------------------------------------------------------------------+
             | Pesquisa no SB1 atraves do campo D4_COD (componente) se o produto atende |
             | 'a condicional de componente Glucose (B1_XTPCOMP igual a '2').           |
             +-------------------------------------------------------------------------*/
             DbSelectArea( "SB1" )
             DbSetOrder( 1 ) // B1_FILIAL + B1_COD
             If DbSeek( xFilial( "SB1" ) + SD4->D4_COD )
                If SB1->B1_XTPCOMP == "2" // Componente Glucose
                   DbSelectArea( "SB8" )
                   DbSetOrder( 7 ) // B8_FILIAL + B8_PRODUTO + B8_LOTECTL + B8_DOC 
                   /*---------------------------------------------------------+
                   | Realiza a busca da Data de Validade, Data de Fabricacao, | 
                   | Nome do Fabricante e Pais de Origem.                     |
                   +---------------------------------------------------------*/
                   If DbSeek( xFilial( "SB8" ) + SD4->( D4_COD + D4_LOTECTL ) )
                      dDVldSB8 := ( SB8->B8_DFABRIC + nDiasVld )
                   EndIf
                EndIf
             EndIf

             DbSelectArea( "SD4" )
             SD4->( DbSkiP() )
          EndDo
       EndIf
ElseIf cXMAMTEM == "3"
       /*---------------------------------+
       | Regra 3 - Padrao Sistemico       |
       +---------------------------------*/

       /*-----------------------------------------------------------+
       | Inicializa as variaveis.                                   |
       +-----------------------------------------------------------*/
       dDFabSB8 := GetAdvFVal( "SC2", "C2_EMISSAO", cFilSH6 + cOP_, 1, CtoD( Space( 8 ) ) )
       dDVldSB8 := dDFabSB8 + nDiasVld

EndIf

RestArea( aArea )
RestArea( aAreaSB8 )
Return( dDVldSB8 )

/*======================================================================================+
| Funcao Estatica ....:   ContPilha()                                                   |
| Autores ............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   14/11/2019                                                    |
| Descricao / Objetivo:   Funcao estatica que grava em arquivo texto as pilhas de cha=  |
|                         mada das funcoes e programas.                                 |
| Doc. Origem.........:                                                                 |
| Solicitante.........:                                                                 |
| Uso.................:                                                                 |
| Obs.................:                                                                 |
+======================================================================================*/
Static Function ContPilha()
Local aArea    := GetArea()
Local nCont    := 1
Local nHdl     := 0
Local cArquivo := "C:\DESENV\pilha.txt"

/*------------------------------------------------+
| Gerando o arquivo e pegando o handle (ponteiro) |
+------------------------------------------------*/     
FErase( cArquivo )
nHdl := FCreate(cArquivo)
fWrite( nHdl, 'FunName: ' + FunName() + _ENTER )

/*-------------------------------------------------+
| Enquanto houver procname que nao estao em branco |
+-------------------------------------------------*/
Do While .not. Empty( ProcName( nCont ) )

   /*-------------------------------------------------+
   | Escrevendo o numero do procname e a descricao    |
   +-------------------------------------------------*/
   fWrite( nHdl, 'ProcName > ' + StrZero( nCont, 6 ) + ' - ' + ProcName( nCont ) + _ENTER )
   nCont++
EndDo
     
/*-------------------------------------------------+
| Fechando o arquivo                               |
+-------------------------------------------------*/
FClose( nHdl )
     
RestArea( aArea )
Return( Nil )

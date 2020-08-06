#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH" 
User Function DV030SDB()
Local lCtrlFOk := PARAMIXB[1]
Local aArea    := GetArea()
Local nQtdRet  := 0
Local cSrv		:= SuperGetMV('ES_SERVDIS',.T.,'019',cFilAnt)
Local cSegSepara	 := SuperGetMV('ES_SERVSEP',.T.,'025',cFilAnt)
/*-----------------------------------------------------------------------+
| Posicionar na DC5 para checar se serviço é de separação                |
+-----------------------------------------------------------------------*/

If oMovimento:oMovServic:GetServico() == cSegSepara
    D14->(DbSetOrder(1)) //D14_FILIAL+D14_LOCAL+D14_ENDER+D14_PRDORI+D14_PRODUT+D14_LOTECT+D14_NUMLOT+D14_NUMSER+D14_IDUNIT
    If D14->(DbSeek(xFilial('D14') + oMovimento:oMovEndOri:GetArmazem() + oMovimento:oMovEndOri:GetEnder() + oMovimento:oMovPrdLot:GetProduto()  + oMovimento:oMovPrdLot:GetProduto()  + oMovimento:oMovPrdLot:GetLoteCtl()))
        RecLock('D14',.F.)
        D14->D14_QTDEMP := D14->D14_QTDEMP - D12->D12_QTDMOV
        D14->D14_QTDEM2 := D14->D14_QTDEM2 - D12->D12_QTDMO2 
        D14->D14_QTDSPR := D14->D14_QTDSPR + D12->D12_QTDMOV
        D14->D14_QTDSP2 := D14->D14_QTDSP2 + D12->D12_QTDMO2
        D14->D14_QTDPEM := D14->D14_QTDPEM + D12->D12_QTDMOV
        D14->D14_QTDPE2 := D14->D14_QTDPE2 + D12->D12_QTDMO2
        MsUnlock()

        If D14->D14_QTDEST + D14->D14_QTDEPR + D14->D14_QTDSPR + D14->D14_QTDEMP + D14->D14_QTDPEM + D14->D14_QTDBLQ == 0 
            RecLock('D14',.F.)
            DbDelete()
            MsUnlock()
        EndIf
    EndIf
EndIf

DC5->( DbSetOrder( 1 ) )			
If DC5->( DbSeek( xFilial( 'DC5' ) + oMovimento:oMovServic:GetServico() )) .AND. DC5->DC5_OPERAC = '3' .And. oMovimento:GetStatus() <> '2'
   If DC5->DC5_SERVIC == cSrv
      //TABELA DC6- TAREFA X ATIVIDADES
      DC6->( DbSetOrder( 1 ) )
      If DC6->( DbSeek( xFilial( 'DC6' ) + DC5->DC5_SERVIC )) .AND. DC6->DC6_TPAGLU <> '1'
         GeraSegSep()
      Endif
   EndIf
Endif 

RestArea(aArea)
Return .T.



/*======================================================================================+
| Funcao de Usuario ..:   u_GeraSegSep()                                                |
| Autor...............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   23/10/2019                                                    |
| Descricao / Objetivo:   Programa-fonte com personalizacoes do processo da Segunda     |
|                         Separacao WMS.                                                |
| Doc. Origem.........:   MIT044 - R01PT - Criacao do Novo Servico de WMS no Processo   |
|                         de Separacao.                                                 |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
Static Function GeraSegSep()
Local aArea     := GetArea()
//Local aAreaD12  := D12->( GetArea() )
Local cCateg    := ""
Local nPesoLiq  := 0
Local nNorma    := 0
Local nPesoTot  := 0
Local nPosic    := 0
Local cCdEstFis := ""
Local cTpEstr   := Space( TamSX3( "DC8_TPESTR" )[ 1 ] )
Local cSrv		 := SuperGetMV('ES_SERVDIS',.T.,'019',cFilAnt)
Local cQuery := ''
Local cAliasQry := GetNextAlias()
Local cAliasSZG := GetNextAlias()
Local cPedAnt   := ''
Local lContinua   := .F.
Private cSequen   := ''
Private nFatCnv    := 0

Conout('DV030SDB - entrou no gerasegsep - Produto : ' + oMovimento:oMovPrdLot:GetProduto())
/*-----------------------------------------------------------------+
| Posicionamento do cadastro DCR - Relac. Mov. Distribuicao        |
+-----------------------------------------------------------------*/
DbSelectArea( "DCR" ) // Cadastro Relac. Mov. Distribuicao
DbSetOrder( 2 ) // DCR_FILIAL + DCR_IDMOV + DCR_IDOPER + DCR_IDORI + DCR_IDDCF
If DCR->( DbSeek( xFilial('DCR') +oMovimento:GetIdMovto()  + oMovimento:GetIdOpera() ) ) 
   Conout('DV030SDB - Achou DCR')
   While  ( xFilial('DCR') +oMovimento:GetIdMovto()  + oMovimento:GetIdOpera() ) == xFilial('DCR') + DCR->(DCR_IDMOV + DCR_IDOPER) 
      cQuery := "SELECT R_E_C_N_O_ AS REC"
      cQuery += "  FROM " + RetSQLTab('SC9') 
      cQuery += "  WHERE  "
      cQuery += "  C9_FILIAL = '" + xFilial('SC9') + "' AND C9_IDDCF = '" + DCR->DCR_IDDCF +"'  "
      cQuery += "  AND C9_SERVIC = '" + cSrv +"'  "
      cQuery += "  AND C9_QTDLIB = '" + STR(DCR->DCR_QUANT) +"'  "
      cQuery += "  AND C9_LOTECTL = '" + oMovimento:oMovPrdLot:GetLoteCtl()  +"'  "
      cQuery += "  AND C9_PRODUTO = '" + oMovimento:oMovPrdLot:GetProduto() +"'  "
      cQuery += "  AND SC9.D_E_L_E_T_ = ' '"

      TcQuery cQuery new Alias ( cAliasQry )   
      If !(cAliasQry)->(EOF())
         
         While !(cAliasQry)->(EOF())
            SC9->(DbGoTo((cAliasQry)->REC))
            
            If cPedAnt <> SC9->C9_PEDIDO
               cPedAnt := SC9->C9_PEDIDO
               cSequen := ''
            EndIf
            /*-----------------------------------------------------------------+
            | Posicionamento do cadastro DCF - Ordem de Servicos               |
            +-----------------------------------------------------------------*/
            DbSelectArea( "DCF" ) // Cadastro Ordem de Servicos
            DbSetOrder( 9 ) // DCF_FILIAL + DCF_ID + DCF_SEQUEN
            If DCF->( DbSeek( DCR->( DCR_FILIAL + DCR_IDDCF + DCR_SEQUEN ) ) ) //.And. DCF->DCF_SERVIC == cSrv
            
               _aSeparaca := {} // Reinicializa a array _aSeparaca para o proximo DCF.
            
               /*-----------------------------------------------------------------+
               | Busco o codigo da Estrutura Fisica do cadastro de Endereco - SBE |
               +-----------------------------------------------------------------*/
               DbSelectArea( "SBE" ) // Cadastro de Enderecos
               DbSetOrder( 1 )
               If DbSeek( DCF->( DCF_FILIAL + DCF_LOCDES + DCF_ENDDES ) )                  
                  cCdEstFis := SBE->BE_ESTFIS
               EndIf
               
               /*---------------------------------------------------------------------------+
               | Busco o peso bruto, categoria e fator conversao cadastro de Produtos - SB1 |
               +---------------------------------------------------------------------------*/
               DbSelectArea( "SB1" ) // Cadastro de Produtos
               DbSetOrder( 1 ) // B1_FILIAL + B1_COD
               If SB1->( DbSeek( xFilial( "SB1" ) + DCF->DCF_CODPRO ) )
                  nPesoLiq := SB1->B1_PESO    // Pega o peso bruto do produto para fins de calculo de capacidade volumetrica
                  cCateg   := SB1->B1_XCTGPRD // Pega a categoria do produto e atribui para a variavel cCateg
                  nFatCnv  := SB1->B1_CONV    // Pega o fator de conversao e atribui para a variavel nFatCnv
               EndIf      
            
               /*-----------------------------------------------------------------+
               | Posiciona no arquivo DC8 (Estrutura Fisica) para obter o codigo  |
               | da estrutura (DC8_CODEST).                                       |
               +-----------------------------------------------------------------*/
               DbSelectArea( "DC8" ) // Cadastro de Estrutura Fisica
               DbSetOrder( 3 ) // DC8_FILIAL + DC8_TPESTR
               If DC8->( DbSeek( xFilial( "DC8" ) + "1" ) )  // "1" e' Pulmao
                  cTpEstr := DC8->DC8_CODEST
               EndIf

               /*-----------------------------------------------------------------+
               | Posiciona no arquivo DC3 (Sequencia de Abastecimento) para saber |
               | o codigo da norma do produto.                                    |
               +-----------------------------------------------------------------*/
               DbSelectArea( "DC3" ) // Cadastro de Sequencia de Abastecimento
               DbSetOrder( 2 ) // DC3_FILIAL + DC3_CODPRO + DC3_LOCAL + DC3_TPESTR
               If DbSeek( xFilial( "DC3" ) + DCF->( DCF_CODPRO + DCF_LOCAL ) + cTpEstr )
                  /*-----------------------------------------------------------+
                  | Posiciona no arquivo DC2 (Norma de Paletizacao) para saber |
                  | a quantidade da norma de cada produto.                     |
                  +-----------------------------------------------------------*/
                  DbSelectArea( "DC2" ) // Cadastro de Norma de Paletizacao
                  DbSetOrder( 1 ) // DC2_FILIAL + DC2_CODNOR
                  If DbSeek( xFilial( "DC2" ) + DC3->DC3_CODNOR )
                     If Empty( nFatCnv ) 
                        nNorma := DC2->( DC2_LASTRO * DC2_CAMADA )
                     Else
                        nNorma := DC2->( DC2_LASTRO * DC2_CAMADA ) * nFatCnv
                     EndIf
                  EndIf
               EndIf
                           
               /*---------------------------------------------------------------+
               | Variavel cCateg - Classificacao do Produto e seu conteudo      |
               +----------------------------------------------------------------+
               | 1=Alergenico  |  2=Controlado  |  3=Comum  | 4=Sensibilizante  |
               +---------------------------------------------------------------*/
               cCodZon := Space( 6 )
               Do Case
                  Case cCateg == "1" // 1 - Alergenico
                     cCodZon := AllTrim( SuperGetMV( "ES_CZALE", .F., "000004", cFilAnt ) ) // cFilAnt ---> EEFF (EE=Empresa | FF=Filial)
                  Case cCateg == "2" // 2 - Controlado
                     cCodZon := AllTrim( SuperGetMV( "ES_CZCNT", .F., "000009", cFilAnt ) ) // cFilAnt ---> EEFF (EE=Empresa | FF=Filial)
                  Case cCateg == "3" .or. cCateg == "4" // 3 - Comum ou 4 - Sensibilizante
                     cCodZon := AllTrim( SuperGetMV( "ES_CZNRM", .F., "000013", cFilAnt ) ) // cFilAnt ---> EEFF (EE=Empresa | FF=Filial)
               EndCase

               lContinua := .F.
               //ler a SZG com o Filial + LOCAL + DOCTO (DCF)
               cQuery := "SELECT *"
               cQuery += "  FROM " + RetSQLTab('SZG') 
               cQuery += "  WHERE  "
               cQuery += "  ZG_FILIAL = '" + xFilial('SZG') + "' AND ZG_LOCAL = '" + DCF->DCF_LOCAL +"'  "
               cQuery += "  AND ZG_DOCTO = '" + DCF->DCF_DOCTO +"'  "
               cQuery += "  AND D_E_L_E_T_ = ' '"


               If Select(cAliasSZG) > 0
                  (cAliasSZG)->(DbCloseArea())
               EndIf
               TcQuery cQuery new Alias ( cAliasSZG )   
               While !(cAliasSZG)->(EOF())       
                  Conout('DV030SDB - entrou no while da SZG')
                  //SE ACHAR , TRAZER O SZG->ZG_LOCALIZ
                  SBE->(DbSetOrder(1))
                  If SBE->(DbSeek(xFilial('SBE') + (cAliasSZG)->ZG_LOCAL + (cAliasSZG)->ZG_LOCALIZ))
                      If  SBE->BE_CODZON == cCodZon
                           If SZG->ZG_SALDO >= (oMovimento:GetQtdMov() * nPesoLiq)
                              Conout('DV030SDB - vai chamar o grava DCF')
                              aAdd( _aSeparaca, { DCF->DCF_FILIAL, DCF->DCF_LOCAL, (cAliasSZG)->ZG_LOCALIZ, cCateg, DCF->DCF_CODPRO, ( oMovimento:GetQtdMov() * nPesoLiq ), oMovimento:oMovPrdLot:GetLoteCtl(), DCF->DCF_CLIFOR, DCF->DCF_LOJA, cCdEstFis, DCF->DCF_DOCTO, DCF->DCF_ENDDES } ) 
                              GravaDCF()
                              SZG->(DbGoTo((cAliasSZG)->R_E_C_N_O_))
                              RecLock('SZG',.F.)
                              SZG->ZG_SALDO := SZG->ZG_SALDO - ( oMovimento:GetQtdMov() * nPesoLiq )
                              MsUnlock()
                              lContinua := .T.
                              Exit
                           EndIf
                     EndIf
                  EndIf
                  (cAliasSZG)->(DbSkip())
               EndDo                                    

               If lContinua
                  Exit
               EndIf

               /*---------------------------------------------------------------+
               | Posiciona no arquivo SBE (Enderecos) para calculo de capacida- |
               | de volumetrica do endereco.                                    |
               +---------------------------------------------------------------*/
               DbSelectArea( "SBE" ) // Cadastro de Enderecos
               DbSetOrder( 12 ) // BE_FILIAL + BE_ESTFIS + BE_CODCFG + BE_CODZON + BE_STATUS + BE_LOCAL (indice customizado)
               If .not. Empty( cCodZon ) 
                  If SBE->( DbSeek( xFilial( "SBE" ) + "000002" + "000010" + cCodZon + "1" + DCF->DCF_LOCAL ) )
                     Do While SBE->( BE_FILIAL + BE_ESTFIS + BE_CODCFG + BE_CODZON + BE_STATUS + BE_LOCAL ) == xFilial( "SBE" ) + "000002" + "000010" + cCodZon + "1" + DCF->DCF_LOCAL .and. .not. SBE->( EoF() )
                        nNorma   := SBE->BE_CAPACID
                        Conout('DV030SDB - entrou no while da SBE')
                        /*----------------------------------------------------------------------+
                        | Trecho que verifica a capacidade da norma no endereco a possibilidade |
                        | de armazenar no endereco e de acordo com a categoria.                 | 
                        +----------------------------------------------------------------------*/

                        If EndUsado(SBE->BE_LOCAL, SBE->BE_LOCALIZ , DCF->DCF_CODPRO , DCF->DCF_DOCTO, nNorma, oMovimento:GetQtdMov() * nPesoLiq) 
                              SBE->( DbSkiP() ) // Avanca para buscar o proximo endereco com capacidade disponivel
                           Loop
                        EndIf             
                        Conout('DV030SDB - vai chamar gravadcf')          
                        aAdd( _aSeparaca, { DCF->DCF_FILIAL, DCF->DCF_LOCAL, SBE->BE_LOCALIZ, cCateg, DCF->DCF_CODPRO, ( oMovimento:GetQtdMov() * nPesoLiq ), oMovimento:oMovPrdLot:GetLoteCtl(), DCF->DCF_CLIFOR, DCF->DCF_LOJA, cCdEstFis, DCF->DCF_DOCTO, DCF->DCF_ENDDES } ) 
                        GravaDCF()

                        /*-------+-------+----------+--------+----------+-------+
                        | FILIAL | LOCAL | ENDERECO | PEDIDO | CATEGORIA| NORMA | Elementos da array _aCapacid
                        +--------+-------+----------+--------+----------+------*/
                        /*nPosic := aScan( _aCapacid, { | x | x[1]+x[2]+x[3]+x[4]+x[5] == SBE->( BE_FILIAL + BE_LOCAL + BE_LOCALIZ ) + DCF->DCF_DOCTO + cCateg } )

                         
                        If nPosic == 0
                           nPosic1 := aScan( _aCapacid, { | x | x[1]+x[2]+x[3]+x[5] == SBE->( BE_FILIAL + BE_LOCAL + BE_LOCALIZ )+ cCateg } )
                           If nPosic1 > 0
                              SBE->( DbSkiP() ) // Avanca para buscar o proximo endereco com capacidade disponivel
                              LooP
                           EndIf 
                           aAdd( _aCapacid, { SBE->BE_FILIAL, SBE->BE_LOCAL, SBE->BE_LOCALIZ, DCF->DCF_DOCTO, cCateg, nNorma } )
                           nPosic := aScan( _aCapacid, { | x | x[1]+x[2]+x[3]+x[4]+x[5] == SBE->( BE_FILIAL + BE_LOCAL + BE_LOCALIZ ) + DCF->DCF_DOCTO + cCateg } )                                     
                        EndIf

                        If _aCapacid[ nPosic, 6 ] >= ( DCF->DCF_QUANT * nPesoLiq )
                           /*-------------------------------------------------------------------------------------------------------------+
                           |                                                   Array _aSeparaca                                           |
                           +--------+-------+----------+-----------+---------+------+------+--------+------+------------------------------+
                           | FILIAL | LOCAL | ENDERECO | CATEGORIA | PRODUTO | QTDE | LOTE | CLIFOR | LOJA | ESTFIS | PEDIDO | END.ORIGEM |
                           +--------+-------+----------+-----------+---------+------+------+--------+------+-----------------------------*/
                           /*aAdd( _aSeparaca, { DCF->DCF_FILIAL, _aCapacid[ nPosic, 2 ], _aCapacid[ nPosic, 3 ], cCateg, DCF->DCF_CODPRO, ( DCF->DCF_QUANT * nPesoLiq ), oMovimento:oMovPrdLot:GetLoteCtl(), DCF->DCF_CLIFOR, DCF->DCF_LOJA, cCdEstFis, DCF->DCF_DOCTO, DCF->DCF_ENDDES } ) 

                           /*----------------------------------------------------------+
                           | Realiza a gravacao do DCF pela funcao estatica GravaDCF() |
                           +----------------------------------------------------------*/
                           //GravaDCF()

                           //_aCapacid[ nPosic, 6 ] := _aCapacid[ nPosic, 6 ] - ( DCF->DCF_QUANT * nPesoLiq ) // Abate a capacidadade de carga do endereco.
                           /*
                        Else
                           SBE->( DbSkiP() ) // Avanca para buscar o proximo endereco com capacidade disponivel
                           LooP
                        EndIf*/
                        ExiT // Sai do laco para ir para o proximo DCF.
                     EndDo
                  Else
                     /*--------------------------------------------------+
                     | Nao encontrou endereco disponivel para armazenar. |
                     +--------------------------------------------------*/
                     Conout('DV030SDB - Else do SBE , não encontrou endereco disponivel')
                     DbSelectArea( "SBE" )
                     DbSetOrder( 5 ) // BE_FILIAL + BE_CODCFG
                     If DbSeek( xFilial( "SBE" ) + AllTrim( SuperGetMV( "ES_CODCFG", .F., "000009", cFilAnt ) ) )
                        If EndUsado(SBE->BE_LOCAL, SBE->BE_LOCALIZ , DCF->DCF_CODPRO , DCF->DCF_DOCTO, nNorma, oMovimento:GetQtdMov() * nPesoLiq) 
                              SBE->( DbSkiP() ) // Avanca para buscar o proximo endereco com capacidade disponivel
                           Loop
                        EndIf                       
                        /*-------------------------------------------------------------------------------------------------------------+
                        |                                                   Array _aSeparaca                                           |
                        +--------+-------+----------+-----------+---------+------+------+--------+------+------------------------------+
                        | FILIAL | LOCAL | ENDERECO | CATEGORIA | PRODUTO | QTDE | LOTE | CLIFOR | LOJA | ESTFIS | PEDIDO | END.ORIGEM |
                        +--------+-------+----------+-----------+---------+------+------+--------+------+-----------------------------*/
                        aAdd( _aSeparaca, { xFilial( "SBE" ), SBE->BE_LOCAL, SBE->BE_LOCALIZ, cCateg, DCF->DCF_CODPRO, oMovimento:GetQtdMov() * nPesoLiq, oMovimento:oMovPrdLot:GetLoteCtl(), DCF->DCF_CLIFOR, DCF->DCF_LOJA, cCdEstFis, DCF->DCF_DOCTO, DCF->DCF_ENDDES } )

                        /*----------------------------------------------------------+
                        | Realiza a gravacao do DCF pela funcao estatica GravaDCF() |
                        +----------------------------------------------------------*/
                        Conout('DV030SDB - vai chamar grava dcf')
                        GravaDCF()

                     EndIf
                  EndIf
               Else
                  Conout('DV030SDB - entrou no outro else da SBE')
                  DbSelectArea( "SBE" ) // Cadastro de Enderecos
                  DbSetOrder( 5 ) // BE_FILIAL + BE_CODCFG
                  If DbSeek( xFilial( "SBE" ) + AllTrim( SuperGetMV( "ES_CODCFG", .F., "000009", cFilAnt ) ) )
                     If EndUsado(SBE->BE_LOCAL, SBE->BE_LOCALIZ , DCF->DCF_CODPRO , DCF->DCF_DOCTO, nNorma, oMovimento:GetQtdMov() * nPesoLiq) 
                           SBE->( DbSkiP() ) // Avanca para buscar o proximo endereco com capacidade disponivel
                        Loop
                     EndIf                    
                     /*-------------------------------------------------------------------------------------------------------------+
                     |                                                   Array _aSeparaca                                           |
                     +--------+-------+----------+-----------+---------+------+------+--------+------+------------------------------+
                     | FILIAL | LOCAL | ENDERECO | CATEGORIA | PRODUTO | QTDE | LOTE | CLIFOR | LOJA | ESTFIS | PEDIDO | END.ORIGEM |
                     +--------+-------+----------+-----------+---------+------+------+--------+------+-----------------------------*/
                     aAdd( _aSeparaca, { xFilial( "SBE" ), SBE->BE_LOCAL, SBE->BE_LOCALIZ, cCateg, DCF->DCF_CODPRO, oMovimento:GetQtdMov() * nPesoLiq, oMovimento:oMovPrdLot:GetLoteCtl(), DCF->DCF_CLIFOR, DCF->DCF_LOJA, cCdEstFis, DCF->DCF_DOCTO, DCF->DCF_ENDDES } )

                     /*----------------------------------------------------------+
                     | Realiza a gravacao do DCF pela funcao estatica GravaDCF() |
                     +----------------------------------------------------------*/
                     Conout('DV030SDB - vai chamar o grava dcf')
                     GravaDCF()

                  EndIf
               EndIf

               /*------------------------------------------------+
               | Reinicializa as variaveis de trabalho           |
               +------------------------------------------------*/
               cCateg    := ""
               nPesoLiq  := 0
               nFatCnv   := 0
               nNorma    := 0
               nPesoTot  := 0
               nPosic    := 0
               cCdEstFis := ""
               cTpEstr   := Space( TamSX3( "DC8_TPESTR" )[ 1 ] )  
            EndIf         

            (cAliasQry)->(DbSkip())
         EndDo
      EndIf 
      (cAliasQry)->(DbCloseArea())  
      DCR->(DbSkip())
   EndDo
EndIf

RestArea( aArea    )
//RestArea( aAreaD12 )
Return( Nil )

/*======================================================================================+
| Funcao Estatica ....:   GravaDCF()                                                    |
| Autor...............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   27/11/2019                                                    |
| Descricao / Objetivo:   Funcao estatica para a gravacao do DCF a partir da array      |
|                         _aSeparaca.                                                   |
| Doc. Origem.........:   MIT044 - R01PT - Criacao do Novo Servico de WMS no Processo   |
|                         de Separacao.                                                 |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
Static Function GravaDCF()
Local aArea := GetArea()
Local cHora := Time()
Local cSegSepara	 := SuperGetMV('ES_SERVSEP',.T.,'025',cFilAnt)
Local cSrv		:= SuperGetMV('ES_SERVDIS',.T.,'019',cFilAnt)
Local cLoteCtl := ''
Local cIdDCF   := ''
Local aCampos    := 0 
Local bCampo     := {|x| FieldName(x)}
Local nCountA    := 0
Conout('DV030SDB - Entrou no grava dcf')
//ler e excluir a c9 , criar uma nova
If Empty(cSequen)
   cSequen := RetSeq(SC9->C9_PEDIDO)
EndIf

aCampos := {}
cSequen := SOMA1(cSequen)
for nCountA := 1 to SC9->(Fcount())
      If SC9->(Eval(bCampo, nCountA)) $ 'C9_SERVIC'
         Aadd(aCampos,cSegSepara)
      ElseIf SC9->(Eval(bCampo, nCountA)) $ 'C9_BLWMS'
         Aadd(aCampos,'01' )             
      ElseIf SC9->(Eval(bCampo, nCountA)) $ 'C9_ENDPAD'
         Aadd(aCampos, _aSeparaca[ 1,  3 ] ) 
      ElseIf SC9->(Eval(bCampo, nCountA)) $ 'C9_IDDCF'
         cIdDCF := ProxNum()
         Aadd(aCampos, cIdDCF )                        
      ElseIf SC9->(Eval(bCampo, nCountA)) $ 'C9_NUMSEQ'
         Aadd(aCampos, '' )                     
      ElseIf SC9->(Eval(bCampo, nCountA)) $ 'C9_SEQUEN'
         Aadd(aCampos, cSequen )                                                                 
      Else
         Aadd(aCampos,SC9->&(Eval(bCampo, nCountA)))
      EndIf
next

//gravo backup da SC9
GravaSZZ(cIdDCF)
Conout('DV030SDB - Gravou SZZ')
//Apago o registro da primeira separação
RecLock('SC9',.F.)
SC9->(DbDelete())
MsUnlock()
Conout('DV030SDB - Excluiu SC9 da primeira separação')

Reclock('SC9',.T.)
For nCountA := 1 To SC9->(FCount())
   SC9->(FieldPut(nCountA,aCampos[nCountA]))
Next
SC9->C9_XLOGWMS := UsrRetName( retcodusr() ) + ";" + DTOC(dDataBase) + ";" + Time()  + ";" + FUNNAME() + ";" + SC9->C9_BLWMS
MsUnlock() 
Conout('DV030SDB - Gravou SC9 da segunda separacao')
aCampos := {}
for nCountA := 1 to DCF->(Fcount())
      If DCF->(Eval(bCampo, nCountA)) $ 'DCF_SERVIC'
         Aadd(aCampos,cSegSepara)
      ElseIf DCF->(Eval(bCampo, nCountA)) $ 'DCF_STSERV'
         Aadd(aCampos,'1')
      ElseIf DCF->(Eval(bCampo, nCountA)) $ 'DCF_ENDER'
         Aadd(aCampos, _aSeparaca[ 1, 12 ] )       
      ElseIf DCF->(Eval(bCampo, nCountA)) $ 'DCF_ENDDES'
         Aadd(aCampos, _aSeparaca[ 1,  3 ] ) 
      ElseIf DCF->(Eval(bCampo, nCountA)) $ 'DCF_LOTECT'
         Aadd(aCampos, SC9->C9_LOTECTL )     
      ElseIf DCF->(Eval(bCampo, nCountA)) $ 'DCF_REGRA'
         Aadd(aCampos, '1')  
      ElseIf DCF->(Eval(bCampo, nCountA)) $ 'DCF_ESTFIS'
         Aadd(aCampos, _aSeparaca[ 1, 10 ] )  
      ElseIf DCF->(Eval(bCampo, nCountA)) $ 'DCF_QUANT'
         Aadd(aCampos, SC9->C9_QTDLIB ) 
      ElseIf DCF->(Eval(bCampo, nCountA)) $ 'DCF_QTSEUM'
         Aadd(aCampos, SC9->C9_QTDLIB2 ) 
      ElseIf DCF->(Eval(bCampo, nCountA)) $ 'DCF_ID'
         Aadd(aCampos, SC9->C9_IDDCF )                                                                      
      Else
         Aadd(aCampos,DCF->&(Eval(bCampo, nCountA)))
      EndIf
next

Reclock('DCF',.T.)
For nCountA := 1 To DCF->(FCount())
   DCF->(FieldPut(nCountA,aCampos[nCountA]))
Next
MsUnlock()
Conout('DV030SDB - Gravou DCF da segunda separacao')

SC6->(DbSetOrder(1))
If SC6->(DbSeek(xFilial('SC6') + PADR(DCF->DCF_DOCTO,TamSX3('C6_NUM')[1]) + PADR(DCF->DCF_SERIE,TamSX3('C6_ITEM')[1]) + PADR(DCF->DCF_CODPRO,TamSX3('C6_PRODUTO')[1])))
   RecLock('SC6',.F.)
   SC6->C6_SERVIC := cSegSepara
   MsUnlock()	
EndIf
 /*-----------------------------------------------------------------+
| Posicionamento do cadastro D0D - Distribuicao Separacao          |
+-----------------------------------------------------------------*/
/*
DbSelectArea( "D0D" ) // Cadastro de Distribuicao de Separacao
DbSetOrder( 3 ) // D0D_FILIAL + D0D_PEDIDO (indice customizado)
If D0D->( DbSeek( DCF->( DCF_FILIAL + Left( DCF_DOCTO, 6 ) ) ) )
   If D0D->D0D_STATUS == "1" /* 1=Status Pendente | 2=Status Finalizado */
      /*-----------------------------------------------------------------+
      | Posicionamento do cadastro D0E - Distribuicao Separacao Itens    |
      +-----------------------------------------------------------------*/
/*      
      DbSelectArea( "D0E" ) // Cadastro de Distribuicao de Separacao (Itens)
//            DbSetOrder( 1 ) // D0E_FILIAL + D0E_CODDIS + D0E_CARGA + D0E_PEDIDO + D0E_LOCORI + D0E_PRDORI + D0E_PRODUT + D0E_LOTECT + D0E_NUMLOT
      DbSetOrder( 4 ) // D0E_FILIAL + D0E_CODDIS + D0E_PRDORI
      If D0E->( DbSeek( D0D->( D0D_FILIAL + D0D_CODDIS + D12->D12_PRODUT ) ) ) .And. D0D->D0D_DATA == DCF->DCF_DATA .And. D0D->D0D_LIBEST == '2'
         /*-----------------------------------------------------------+
         | Realiza a varredura do D0E para categorizacao dos produtos |
         +-----------------------------------------------------------*/
   /*      Do While D0E->( D0E_FILIAL + D0E_CODDIS + D0E_PRDORI ) == D0D->( D0D_FILIAL + D0D_CODDIS + D12->D12_PRODUT ) .and. .not. D0E->( EoF() )
            RecLock('D0E',.F.)
            D0E->D0E_ENDORI := _aSeparaca[ 1,  3 ]
            MSUnLock()
            D0E->(DbSkip())
         EndDo
      EndIf
   EndIf
EndIf
*/
/*-----------------------------------------------------------------+
| Posicionamento do cadastro SC9                                    |
+-----------------------------------------------------------------*/
/*
DbSelectArea( "SC9" ) // Cadastro de Distribuicao de Separacao
DbSetOrder( 9 ) // IDDCF
If SC9->( DbSeek( xFilial('SC9') + DCF->DCF_ID ) ) 
   If  SC9->C9_SERVIC <> '025'  
      RecLock('SC9',.F.)
      SC9->C9_SERVIC := '025'
      SC9->C9_BLWMS  := '01'
      SC9->C9_LOTECTL := _aSeparaca[ 1, 7 ]
      MSUnLock()   EndIf
EndIf
*/
/*-----------------------------------------------+
| Reinicia a array _aSeparaca para o proximo DCF |
+-----------------------------------------------*/
_aSeparaca := {}

RestArea( aArea )
Return( Nil )

/*/{Protheus.doc} RetSeq()
    (long_description)
    @type  Static Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function RetSeq(cPedido)
Local cQuery := ''
Local cAliasQry := GetNextAlias()
Local cSequen   := ''
Local cSrv		:= SuperGetMV('ES_SERVDIS',.T.,'019',cFilAnt)

cQuery := "SELECT MAX(C9_SEQUEN) AS SEQ"
cQuery += "  FROM " + RetSQLTab('SC9') 
cQuery += "  WHERE  "
cQuery += "  C9_FILIAL = '" + xFilial('SC9') + "' AND C9_PEDIDO = '" + cPedido +"'  "
cQuery += "  AND SC9.D_E_L_E_T_ = ' '"

TcQuery cQuery new Alias ( cAliasQry )

(cAliasQry)->(dbGoTop())

If !(cAliasQry)->(EOF())
    cSequen := (cAliasQry)->SEQ       
EndIf

(cAliasQry)->(DbCloseArea())
Return cSequen

/*/{Protheus.doc} EndUsado
   Valida se o endereço sera usado
   @type  Static Function
   @author user
   @since date
   @version version
   @param param, param_type, param_descr
   @return return, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
   /*/
Static Function EndUsado(cLocal,cEndereco,cProduto,cDoc,  nNorma , nQtd)
local lRet := .F.
Local cQuery := ''
Local cAliasQry := GetNextAlias()
Local cAliasQry2 := GetNextAlias()
Local nSaldo   := nNorma - nQtd

cQuery := "SELECT * "
cQuery += "  FROM " + RetSQLTab('SZG') 
cQuery += "  WHERE  "
cQuery += "  ZG_FILIAL = '" + xFilial('SZG') + "' AND ZG_DOCTO = '" + cDoc +"'  "
cQuery += "  AND ZG_LOCAL = '" + cLocal + "' AND ZG_LOCALIZ = '" + cEndereco +"'  "
cQuery += "  AND SZG.D_E_L_E_T_ = ' '"

TcQuery cQuery new Alias ( cAliasQry )

(cAliasQry)->(dbGoTop())

If !(cAliasQry)->(EOF())
   If (cAliasQry)->ZG_SALDO < nQtd
      lRet := .T. //endereço sem capacidade
   Else
      SZG->(DbGoTo((cAliasQry)->R_E_C_N_O_))
      RecLock('SZG', .F.)
      SZG->ZG_SALDO := SZG->ZG_SALDO - nQtd
      MsUnlock()
   EndIf
Else 

   cQuery := "SELECT * "
   cQuery += "  FROM " + RetSQLTab('SZG') 
   cQuery += "  WHERE  "
   cQuery += "  ZG_FILIAL = '" + xFilial('SZG') + "' AND ZG_DOCTO <> '" + cDoc +"'  "
   cQuery += "  AND ZG_LOCAL = '" + cLocal + "' AND ZG_LOCALIZ = '" + cEndereco +"'  "
   cQuery += "  AND SZG.D_E_L_E_T_ = ' '"

   TcQuery cQuery new Alias ( cAliasQry2 )

   (cAliasQry2)->(dbGoTop())

   If !(cAliasQry2)->(EOF())
      lRet := .T. //endereço ja usado
   Else
      RecLock('SZG',.T.)
      SZG->ZG_FILIAL    := xFilial('SZG')
      SZG->ZG_LOCAL     := cLocal
      SZG->ZG_LOCALIZ   := cEndereco
      SZG->ZG_PRODUTO   := cProduto
      SZG->ZG_DOCTO     := cDoc
      SZG->ZG_NORMA     := nNorma
      SZG->ZG_SALDO     := nSaldo
      MsUnlock()
   EndIf
EndIf
If SELECT(cAliasQry) > 0
   (cAliasQry)->(DbCloseArea())
EndIf
If SELECT(cAliasQry2) > 0
   (cAliasQry2)->(DbCloseArea())
EndIf
Return lRet



/*/{Protheus.doc} GravaSZZ
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
Static Function GravaSZZ(cIdDCF) //por no pe 
Local aCampos := {}
Local nI	  := 0
Local bCampo     := {|x| FieldName(x)}

for nI := 1 to SC9->(Fcount())
	Aadd(aCampos,{'ZZ_' + SUBSTR(SC9->(FieldName(nI)),4,Len(SC9->(FieldName(nI)))),SC9->&(Eval(bCampo, nI))})
next

SX3->(dbSetOrder(2))
Reclock('SZZ',.T.)
For nI := 1 To Len(aCampos)
   If SX3->(DbSeek(aCampos[nI,1]))
	   SZZ->&(aCampos[nI,1]) := aCampos[nI,2]
   EndIf
Next
MsUnlock()      

Return 
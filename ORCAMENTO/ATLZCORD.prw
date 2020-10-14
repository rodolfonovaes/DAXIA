#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE 'TOTVS.CH'
#INCLUDE 'APWIZARD.CH'
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � ATLZCORD  � Autor � Jose Luis Bernardes  � Data � 25/05/20 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Atualiza coordenadores na SB1                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function ATLZCORD()

Local oWizard    := NIL
Local lFinish    := .F.
Local cHeader    := ''
Local cMessage   := ''
Local cText      := ''
Local cTitleProg := 'TOTVS ImportCSV 1.0'
Local cFileImp   := Space(250)
Local oFileCSV   := Nil
Local cTextP2    := ''
Local oTextP2    := Nil

    DEFINE FONT oArial10	NAME 'Arial'       WEIGHT 10
	DEFINE FONT oCouri11	NAME 'Courier New' WEIGHT 11

//���������������������Ŀ
//�PAINEL PRINCIPAL     �
//�����������������������
	cHeader  := 'Atualiza Coordenadores.'
	cMessage := 'Assistente para processamento'
	cText    := 'Este assistente ir� auxili�-lo na configura��o dos par�metros para realiza��o da importa��o '
	cText    += 'dos dados a partir de um arquivo (.CSV). O objetivo desta aplica��o � efetuar a importa��o '
	cText    += 'consistindo todas as valida��es existentes no sistema para a atualiza��o do produto.' + Chr(10) + Chr(13)
	cText    += ' ' + Chr(10) + Chr(13)
	cText    += ' ' + Chr(10) + Chr(13)
	cText    += 'Clique em "Avan�ar" para continuar...'

	DEFINE	WIZARD	oWizard ;
		TITLE	'AtlzCord v1.0';
		HEADER	cHeader;
		MESSAGE	cMessage;
		TEXT	cText;
		NEXT 	{|| .T.};
		FINISH 	{|| .F.}

//���������������������Ŀ
//�PAINEL 02            �
//�����������������������

	cMessage := 'Informe o local e o arquivo (.CSV) para importa��o dos dados...'
	CREATE	PANEL 	oWizard  ;
		HEADER 	cHeader;
		MESSAGE	cMessage;
		BACK	{|| .T.} ;
		NEXT	{|| !Empty(cFileImp) };
		FINISH	{|| .F.}

	cTextP2	:= 'Restri��es do arquivo:' + Chr(10)+Chr(13)
	cTextP2	+= Chr(10)+Chr(13)
	cTextP2	+= 'a.) A 1a. linha deve conter o cabe�alho do arquivo.' + Chr(10)+Chr(13)
	cTextP2	+= Chr(10)+Chr(13)
	cTextP2	+= 'b.) O tamanho da linha (Cabe�alho e Itens) n�o pode conter mais do que 1023 caracteres.' + Chr(10)+Chr(13)
	cTextP2	+= Chr(10)+Chr(13)
	cTextP2	+= 'c.) No conte�do dos campos n�o pode haver caracteres especiais como aspas simples ou duplas ' + "(')" + '(")' + ' e ponto e v�rgula (;). Isso ira ocasionar em erro na montagem do arquivo.'

	@ 012, 010 Say oTextP2 PROMPT cTextP2 Size 228, 094 Of oWizard:oMPanel[2] FONT oArial10 Pixel
	@ 085, 005 GROUP To 113, 245 PROMPT "Local e nome do arquivo:" OF oWizard:oMPanel[2] Pixel
	@ 095, 020 MsGet oFileCSV Var cFileImp Valid( If( File(cFileImp), .T., ( Alert("O arquivo informado para importa��o n�o existe!") ,.F.) ) .Or. Empty(cFileImp) ) Size 212, 010 Of oWizard:oMPanel[2] F3 "DIR" Pixel

//���������������������Ŀ
//�PAINEL 03            �
//�����������������������

	cMessage := 'Iniciar o processamento...'
	CREATE	PANEL 	oWizard  ;
		HEADER 	cHeader;
		MESSAGE	cMessage;
		BACK	{|| .T.} ;
		NEXT	{|| .F.};
		FINISH	{|| lFinish := .T.}

    ACTIVATE WIZARD oWizard Center

    If lFinish
        If ( !File(cFileImp) )
            MsgBox("ArquiVO " + cFileImp + " n�o encontrado" + CHR(13) + " Formato ")
            Return
        Else
            Processa({|| fImpDados(cFileImp)}, "Carregando......")
        Endif
    EndIf
    
Return    
/*
====================================================
Importa arquivo CSV e mostra Browse
====================================================
*/    
Static Function fImpDados(pArquivo)

Local nPos
Local x
Local cLinha
Local cCab    := ""
Local i       := 0
Local aCSV    := {}                           
Local nCols   := 0
Local pMatriz := {}
Local pUsaCab := .F.

    ProcRegua(2000)

       //Abrindo o arquivo
       FT_FUse(pArquivo)
       FT_FGoTop()
       //Capturando as linhas do arquivo
       do while ( !FT_FEof() )
          IncProc()
          if ( Empty(cCab) )
               cCab := FT_FREADLN()
          endif
          if ( pUsaCab )
               AADD(aCSV,FT_FREADLN())
          elseif ( !pUsaCab ) .and. ( i > 0 )
               AADD(aCSV,FT_FREADLN())
          endif
          i++
          FT_FSkip()
       enddo
       FT_FUSE()
       //Pegando o numero de colunas com base no cabecalho
       for i := 1 to Len(cCab)
           IncProc()
           nPos := At(";",cCab)
           if ( nPos > 0 )
               nCols+= 1
               cCab := SubStr(cCab,nPos+1,Len(cCab)-nPos)
           endif
       next
       //Definindo o tamanho da Matriz que recebera os dados
       pMatriz := Array(Len(aCSV),nCols+1)
       // Carregando os dados
       for i := 1 to Len(aCSV)
           IncProc()
           cLinha := aCSV[i]
           for x := 1 to nCols+1
               nPos := At(";",cLinha)
               if ( nPos > 0 )
                    pMatriz[i,x] := AllTrim(SubStr(cLinha,1,nPos-1))
                    cLinha := SubStr(cLinha,nPos+1,Len(cLinha)-nPos)
               else
                    pMatriz[i,x] := AllTrim(cLinha)
                    cLinha := ""
               endif
           next x
       next i

  
Private aDados := {}
AADD(aDados, {"Produto","Produto", "@!" , "10" , "00"})    
AADD(aDados, {"Coord1","Coord1", "@!" , "06" , "00"})
AADD(aDados, {"Coord2","Coord2", "@!" , "06" , "00"})
      
Private aCampos := {}
    AADD(aCampos, {"Produto", "C" , 10 , 00})
    AADD(aCampos, {"Coord1" , "C" , 06 , 00})
    AADD(aCampos, {"Coord2" , "C" , 06 , 00})    
 
       cArqTrab := CriaTrab(aCampos)
       dbUseArea( .T.,, cArqTrab, "DADOS",.F.,.F.)  
    
       For inx := 1 to Len(pMatriz)
           RECLOCK("DADOS",.T.)
           DADOS->Produto  := pMatriz[inx][1]
           DADOS->Coord1   := pMatriz[inx][2]
           DADOS->Coord2   := pMatriz[inx][3]
           DADOS->(MSUNLOCK())
       Next inx
    
       Atlzprod()

       DbSelectArea("DADOS")                       
       DbGotop()

       @ 000,000 TO 800,900 DIALOG oDlg TITLE pArquivo   
       @ 010,010 to 360,430 Browse "DADOS" Fields aDados
       @ 380,390 BMPBUTTON TYPE 2 ACTION Close(oDlg)
             
    ACTIVATE DIALOG oDlg CENTERED
                            
       DbSelectArea("DADOS")
       DADOS->(DbCloseArea())
Return
/*
====================================================
Atualiza SB1 
====================================================
*/    
Static Function Atlzprod()

Local cQrySB1	:= ""
Local cAliasQry	:= GetNextAlias()

/*cQrySB1			:= ""
cQrySB1			:= " SELECT * FROM DADOS "
cQrySB1			+= " WHERE "
cQrySB1			+= "       SB1.B8_FILIAL   = '" + xFilial("SB1") + "' "
cQrySB1			+= "   AND SB1.B8_NFABRIC  <> ' ' "
cQrySB1			+= "   AND SB1.B8_LOCAL    = '"+ cLocQual + "' "
cQrySB1			+= "   AND SB1.D_E_L_E_T_ = ' ' " 
cQrySB1			:= ChangeQuery( cQrySB1 )

DbUseArea(.T., "TopConn", TCGenQry(, , cQrySB1 ), cAliasQry, .F., .F. )
DbSelectArea( cAliasQry )
( cAliasQry )->( DbGoTop() ) */

DbSelectArea( "DADOS" )
( "DADOS" )->(DbGoTop() )
//While ( cAliasQry )->( !Eof() )
While ( "DADOS" )->( !Eof() )
    DbSelectArea("SB1")
    SB1->( DbSetOrder( 1 ) ) 
    If SB1->( DbSeek( xFilial("SB1") + DADOS->PRODUTO ) )
        While SB1->( !Eof() ) .AND. SB1->B1_FILIAL = xFilial("SB1") .AND. SB1->B1_COD = DADOS->PRODUTO  
            If RecLock("SB1", .F. )
				SB1->B1_XCOORD1 := DADOS->COORD1
				SB1->B1_XCOORD2	:= DADOS->COORD2
				SB1->( MsUnLock() )
            EndIf
            SB1->(DbSkip())
        EndDo
    EndIf
    DbSelectArea( "DADOS" )
    ( "DADOS" )->( DbSkip() )
EndDo

SB1->(DbCloseArea())
MsgInfo('Processamento finalizado!')

Return
/*================================================================*
* Fim do programa                                                 *
*=================================================================*/
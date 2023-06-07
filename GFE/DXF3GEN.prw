#Include 'TOTVS.ch'
#INCLUDE "FILEIO.CH"
#INCLUDE 'APWIZARD.CH'
#INCLUDE "TOPCONN.CH"

User Function FiltroF3(cTitulo,cQuery,nTamCpo,cAlias,cCodigo,cCpoChave,cTitCampo,cMascara,cRetCpo,cRetCpo2,nColuna,nColuna2,nColPesq)
	/*
	+------------------+------------------------------------------------------------+
	!Modulo            ! Diversos                                                   !
	+------------------+------------------------------------------------------------+
	!Nome              ! FiltroF3                                                   !
	+------------------+------------------------------------------------------------+
	!Descricao         ! Função usada para criar uma Consulta Padrão  com SQL       !
	!			       !                                                            !
	!			       !                                                            !
	+------------------+------------------------------------------------------------+
	!Autor             ! Rodrigo Lacerda P Araujo                                   !
	+------------------+------------------------------------------------------------+
	!Data de Criacao   ! 03/01/2013                                                 !
	+------------------+-----------+------------------------------------------------+
	!Campo             ! Tipo	   ! Obrigatorio                                    !
	+------------------+-----------+------------------------------------------------+
	!cTitulo           ! Caracter  !                                                !
	!cQuery            ! Caracter  ! X                                              !
	!nTamCpo           ! Numerico  !                                                !
	!cAlias            ! Caracter  ! X                                              !
	!cCodigo           ! Caracter  !                                                !
	!cCpoChave         ! Caracter  ! X                                              !
	!cTitCampo         ! Caracter  ! X                                              !
	!cMascara          ! Caracter  !                                                !
	!cRetCpo           ! Caracter  ! X                                              !
	!nColuna           ! Numerico  !                                                !
	+------------------+-----------+------------------------------------------------+
	!Parametros:                                                                  !
	!==========		                                                        !
	!          																			   !
	!cTitulo = Titulo da janela da consulta                                         !
	!cQuery  = A consulta SQL que vem do parametro cQuery não pode retornar um outro!
	!nome para o campo pesquisado, pois a rotina valida o nome do campo real        !
	!          																			   !
	!Exemplo Incorreto                                                              !
	!cQuery := "SELECT A1_NOME 'NOME', A1_CGC 'CGC' FROM SA1010 WHERE D_E_L_E_T_='' !
	!          																			   !
	!Exemplo Certo                                                                  !
	!cQuery := "SELECT A1_NOME, A1_CGC FROM SA1010 WHERE D_E_L_E_T_=''              !
	!          																			   !
	!Deve-se manter o nome do campo apenas.                                         !
	!          																			   !
	!nTamCpo   = Tamanho do campo de pesquisar,se não informado assume 30 caracteres!
	!cAlias    = Alias da tabela, ex: SA1                                           !
	!cCodigo   = Conteudo do campo que chama o filtro                               !
	!cCpoChave = Nome do campo que será utilizado para pesquisa, ex: A1_CODIGO      ! 
	!cTitCampo = Titulo do label do campo                                           !
	!cMascara  = Mascara do campo, ex: "@!"                                         !
	!cRetCpo   = Campo que receberá o retorno do filtro                             !
	!nColuna   = Coluna que será retornada na pesquisa, padrão coluna 1             !
	+--------------------------------------------------------------------------------
	*/
	Local nLista  
	Local cCampos 	:= ""
	Local bCampo		:= {}
	Local nCont		:= 0
	Local bTitulos	:= {}
	Local aCampos 	:= {}
	Local cTabela 
	Local cCSSGet		:= "QLineEdit{ border: 1px solid gray;border-radius: 3px;background-color: #ffffff;selection-background-color: #3366cc;selection-color: #ffffff;padding-left:1px;}"
	Local cCSSButton 	:= "QPushButton{background-repeat: none; margin: 2px;background-color: #ffffff;border-style: outset;border-width: 2px;border: 1px solid #C0C0C0;border-radius: 5px;border-color: #C0C0C0;font: bold 12px Arial;padding: 6px;QPushButton:pressed {background-color: #ffffff;border-style: inset;}"
	Local cCSSButF3	:= "QPushButton {background-color: #ffffff;margin: 2px;border-style: outset;border-width: 2px;border: 1px solid #C0C0C0;border-radius: 3px; border-color: #C0C0C0;font: Normal 10px Arial;padding: 3px;} QPushButton:pressed {background-color: #e6e6f9;border-style: inset;}"
    Local nX := 0
	Private _oLista	:= nil
	Private _oDlg 	:= nil
	Private _oCodigo
	Private _cCodigo 	
	Private _aDados 	:= {}
	Private _nColuna	:= 0
	Private _nColuna2	:= 0
	Private _nColPesq	:= 0

	Default cTitulo 	:= ""
	Default cCodigo 	:= ""
	Default nTamCpo 	:= 30
	Default _nColuna 	:= 1
	Default nColPesq	:= 1
	Default cTitCampo	:= RetTitle(cCpoChave)
	Default cMascara	:= PesqPict('"'+cAlias+'"',cCpoChave)

	_nColuna	:= nColuna
	_nColuna2	:= nColuna2
	_nColPesq	:= nColPesq

	If Empty(cAlias) .OR. Empty(cCpoChave) .OR. Empty(cRetCpo) .OR. Empty(cQuery)
		MsgStop("Os parametro cQuery, cCpoChave, cRetCpo e cAlias são obrigatórios!","Erro")
		Return
	Endif

	_cCodigo := Space(nTamCpo)
	_cCodigo := cCodigo

	cTabela:= CriaTrab(Nil,.F.)
	DbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),cTabela, .F., .T.)
     
	(cTabela)->(DbGoTop())
	If (cTabela)->(Eof())
		If IsInCallStack('MATA415')
			MsgStop("NÃO EXISTE TRANSPORTADORA COM TABELA DE PREÇO CADASTRADA PARA ESTA REGIÃO, POR FAVOR ENTRAR EM CONTATO COM O DEPARTAMENTO DE COMPRAS")
		Else	
			MsgStop("Não há registros para serem exibidos!","Atenção")
		EndIf
		Return .F.
	Endif
   
	Do While (cTabela)->(!Eof())
		/*Cria o array conforme a quantidade de campos existentes na consulta SQL*/
		cCampos	:= ""
		aCampos 	:= {}
		For nX := 1 TO FCount()
			bCampo := {|nX| Field(nX) }
			If ValType((cTabela)->&(EVAL(bCampo,nX)) ) <> "M" .OR. ValType((cTabela)->&(EVAL(bCampo,nX)) ) <> "U"
				If Alltrim(Field( nX )) == 'GVA_XCONTR'
					cCampos += "'" + IIF((cTabela)->&(EVAL(bCampo,nX)) == '1','Sim','Não')  + "',"
				Elseif ValType((cTabela)->&(EVAL(bCampo,nX)) )=="C" .And. TAMSX3(Field(nX))[3] == 'C'
					cCampos += "'" + zLimpaEsp((cTabela)->&(EVAL(bCampo,nX)))  + "',"
				ElseIf ValType((cTabela)->&(EVAL(bCampo,nX)) )=="C" .And. TAMSX3(Field(nX))[3] == 'D'
					cCampos += "'" +  DTOC(STOD((cTabela)->&(EVAL(bCampo,nX)))) + "',"
				Else
					cCampos +=  Str((cTabela)->&(EVAL(bCampo,nX))) + ","
				Endif
					
				aadd(aCampos,{EVAL(bCampo,nX),Alltrim(RetTitle(EVAL(bCampo,nX))),"LEFT",30})
			Endif
		Next
     
     	If !Empty(cCampos) 
     		cCampos 	:= Substr(cCampos,1,len(cCampos)-1)
     		aAdd( _aDados,&("{"+cCampos+"}"))
     	Endif
     	
		(cTabela)->(DbSkip())     
	Enddo
   
	DbCloseArea(cTabela)
	
	If Len(_aDados) == 0
		If IsInCallStack('MATA415')
		
			MsInfo("NÃO EXISTE TRANSPORTADORA  COM TABELA DE PREÇO CADASTRADA PARA ESTA REGIÃO, POR FAVOR ENTRAR EM CONTATO COM O DEPARTAMENTO DE COMPRAS")
		Else
			MsgInfo("Não há dados para exibir!","Aviso")
			Return
		EndIf
	Endif
   
	nLista := aScan(_aDados, {|x| alltrim(x[1]) == alltrim(_cCodigo)})
     
	iif(nLista = 0,nLista := 1,nLista)
     
	Define MsDialog _oDlg Title "Consulta Padrão" + IIF(!Empty(cTitulo)," - " + cTitulo,"") From 0,0 To 280, 500 Of oMainWnd Pixel
	
	oCodigo:= TGet():New( 003, 005,{|u| if(PCount()>0,_cCodigo:=u,_cCodigo)},_oDlg,205, 010,cMascara,{|| /*Processa({|| FiltroF3P(M->_cCodigo)},"Aguarde...")*/ },0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"",_cCodigo,,,,,,,cTitCampo + ": ",1 )
	oCodigo:SetCss(cCSSGet)	
	oButton1 := TButton():New(010, 212," &Pesquisar ",_oDlg,{|| Processa({|| FiltroF3P(M->_cCodigo) },"Aguarde...") },037,013,,,.F.,.T.,.F.,,.F.,,,.F. )
	oButton1:SetCss(cCSSButton)	
	    
	_oLista:= TCBrowse():New(26,05,245,90,,,,_oDlg,,,,,{|| _oLista:Refresh()},,,,,,,.F.,,.T.,,.F.,,,.f.)
	nCont := 1
        //Para ficar dinâmico a criação das colunas, eu uso macro substituição "&"
	For nX := 1 to len(aCampos)
		SX3->(DbSetOrder(2))
		If SX3->(DbSeek(aCampos[nX,1]))
			cAlias := SX3->X3_ARQUIVO
		EndIf
		cColuna := &('_oLista:AddColumn(TCColumn():New("'+aCampos[nX,2]+'", {|| _aDados[_oLista:nAt,'+StrZero(nCont,2)+']},PesqPict("'+cAlias+'","'+aCampos[nX,1]+'"),,,"'+aCampos[nX,3]+'", '+StrZero(aCampos[nX,4],3)+',.F.,.F.,,{|| .F. },,.F., ) )')
		nCont++
	Next
	_oLista:SetArray(_aDados)
	_oLista:bWhen 		 := { || Len(_aDados) > 0 }
	_oLista:bLDblClick  := { || FiltroF3R(_oLista:nAt, _aDados, cRetCpo,cRetCpo2)  }
	_oLista:Refresh()

	oButton2 := TButton():New(122, 005," OK "			,_oDlg,{|| Processa({|| FiltroF3R(_oLista:nAt, _aDados, cRetCpo,cRetCpo2) },"Aguarde...") },037,012,,,.F.,.T.,.F.,,.F.,,,.F. )
	oButton2:SetCss(cCSSButton)	
	oButton3 := TButton():New(122, 047," Cancelar "	,_oDlg,{|| _oDlg:End() },037,012,,,.F.,.T.,.F.,,.F.,,,.F. )
	oButton3:SetCss(cCSSButton)	

	Activate MSDialog _oDlg Centered	
Return(bRet)

Static Function FiltroF3P(cBusca)
	Local i := 0

	if !Empty(cBusca)
		For i := 1 to len(_aDados)
			//Aqui busco o texto exato, mas pode utilizar a função AT() para pegar parte do texto
			if UPPER(Alltrim(cBusca)) $ UPPER(Alltrim(_aDados[i,_nColPesq]))
				//Se encontrar me posiciono no grid e saio do "For"			
				_oLista:GoPosition(i)
				_oLista:Setfocus()
				exit
			Endif
		Next
	Endif
Return

Static Function FiltroF3R(nLinha,aDados,cRetCpo,cRetCpo2)
	cCodigo := aDados[nLinha,_nColuna]
	&(cRetCpo) := cCodigo //Uso desta forma para campos como tGet por exemplo.
	If cRetCpo2 == 'xEmissao'
		&(cRetCpo2) := CTOD(aDados[nLinha,_nColuna2]) //Uso desta forma para campos como tGet por exemplo.
	Else
		&(cRetCpo2) := aDados[nLinha,_nColuna2] //Uso desta forma para campos como tGet por exemplo
	EndIf

	If IsInCallStack('MATA415') .And. M->CJ_XTPFRET == '1'
		M->CJ_XTBGFE := aDados[nLinha,4]
	EndIf
	//aCpoRet[1] := cCodigo //Não esquecer de alimentar essa variável quando for f3 pois ela e o retorno
	bRet := .T.
	_oDlg:End()    
Return


Static Function zLimpaEsp(cConteudo)

//Retirando caracteres
cConteudo := StrTran(cConteudo, "'", "")
cConteudo := StrTran(cConteudo, "#", "")
cConteudo := StrTran(cConteudo, "%", "")
cConteudo := StrTran(cConteudo, "*", "")
cConteudo := StrTran(cConteudo, "&", "E")
cConteudo := StrTran(cConteudo, ">", "")
cConteudo := StrTran(cConteudo, "<", "")
cConteudo := StrTran(cConteudo, "!", "")
cConteudo := StrTran(cConteudo, "@", "")
cConteudo := StrTran(cConteudo, "$", "")
cConteudo := StrTran(cConteudo, "(", "")
cConteudo := StrTran(cConteudo, ")", "")
cConteudo := StrTran(cConteudo, "_", "")
cConteudo := StrTran(cConteudo, "=", "")
cConteudo := StrTran(cConteudo, "+", "")
cConteudo := StrTran(cConteudo, "{", "")
cConteudo := StrTran(cConteudo, "}", "")
cConteudo := StrTran(cConteudo, "[", "")
cConteudo := StrTran(cConteudo, "]", "")
cConteudo := StrTran(cConteudo, "/", "")
cConteudo := StrTran(cConteudo, "?", "")
cConteudo := StrTran(cConteudo, ".", "")
cConteudo := StrTran(cConteudo, "\", "")
cConteudo := StrTran(cConteudo, "|", "")
cConteudo := StrTran(cConteudo, ":", "")
cConteudo := StrTran(cConteudo, ";", "")
cConteudo := StrTran(cConteudo, '"', '')
cConteudo := StrTran(cConteudo, '°', '')
cConteudo := StrTran(cConteudo, 'ª', '')
cConteudo := StrTran(cConteudo, "'", '')

    
//Adicionando os espaços a direita
cConteudo := Alltrim(cConteudo)
     
Return cConteudo

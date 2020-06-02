#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK260ROT  ºAutor  ³ Totvs Ibirapuera   º Data ³  11/10/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada executado na rotina de prospect para      º±±
±±º          ³ gerar um cliente.                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GENERICO                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function TK260ROT

Return aClone( {{"Gera Cliente","U_TK260GCLI", 0,2 }} )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK260GCLI ºAutor  ³ Totvs Ibirapuera   º Data ³  11/10/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao responsavel pela geracao dos dados do prospect      º±±
±±º          ³ para cliente.                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function TK260GCLI()
Local cCodSA1 		:= ""							// Novo codigo de cliente que sera informado para esse prospect
Local cCodAux 		:= ""							// Codigo auxiliar para evitar falhas no semaforo
Local lGrava  		:= .F.							// Flag para permitir ou nao a Gravacao
Local lRet	  		:= .F.							// Retorno da funcao
Local cWhile        := ""							// Var. Auxiliar
Local nX 			:= 0							// Var. Auxiliar
Local aArea  		:= GetArea() 					// Area do sistema
Local cCodLoja	:= ''
Local cAliasJ 

If MsgYesNo("Confirma a geração do cliente para este prospect?","Atenção")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posiciona o PROSPECT e GRAVA um novo CLIENTE                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SUS")
	DbSetOrder(1)
	If DbSeek(xFilial("SUS")+SUS->US_COD+SUS->US_LOJA)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³O PROSPECT nao pode ter nenhum cliente relacionado       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(SUS->US_CODCLI) .AND. Empty(SUS->US_LOJACLI)
			lGrava := .T.
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida se existe o CGC desse prospect na base de clientes³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lGrava
			If !Empty(SUS->US_CGC)
				DbSelectArea("SA1")
				DbSetOrder(3)
				If DbSeek(xFilial("SA1")+SUS->US_CGC)
					Aviso("Atencao","O CNPJ desse Prospect ja está cadastrado na tabela de Clientes, a gravação não será concluida",{"OK"})
					Return(lRet)
				Else
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Valida se existe o mesmo NOME desse PROSPECT na base de clientes   ³
					//³Porem mantem a gravacao do registro porque os CNPJS sao diferentes ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DbSelectArea("SA1")
					DbSetOrder(2)
					If DbSeek(xFilial("SA1")+SUS->US_NOME)
						If (ALLTRIM(SA1->A1_NOME) == ALLTRIM(SUS->US_NOME))
							Aviso("Atencao","Ja existe um Cliente cadastrado com o mesmo nome desse Prospect",{"OK"})
						Endif
					Endif
				Endif
			Endif                                                                                       
			                                               
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valida se o prospect tem Tipo Pessoa       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			If Empty(SUS->US_PESSOA)
				Aviso("Atencao","Nao foi informado se o Prospect é pessoa física ou jurídica. Impossível transformar em Cliente",{"OK"})
				Return(lRet)
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valida se o prospect tem CNAE              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SUS->US_PESSOA == "J"
				If Empty(SUS->US_CNAE)
					Aviso("Atencao","Não foi digitado CNAE para esse Prospect. Como é Pessoa Jurídica é necessário digitar essa informação antes de transformar em cliente",{"OK"})
					Return(lRet)
				Endif    
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valida se o prospect tem CNPJ              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			If Empty(SUS->US_CGC)
				Aviso("Atencao","Não foi digitado CNPJ para esse Prospect. Digite primeiro antes de transformar em cliente",{"OK"})
				Return(lRet)
			Endif
			
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Pega um codigo valido para o novo  Cliente ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			/*cCodSA1 := CriaVar("A1_COD",.F.)
			cCodAux := TkNumero("SA1","A1_COD")
			If cCodAux <> SUS->US_COD
				cCodSA1 := cCodAux
			Endif
			*/
			IF SUS->US_PESSOA == "F"
 				cCodLoja:= "00" + RIGHT(ALLTRIM(SUS->US_CGC),2)
			ELSEIF SUS->US_PESSOA == "J"
 				cCodLoja  := Substr(SUS->US_CGC,9,4)
			ENDIF			

			cCodSA1 := GetSxeNum('SA1','A1_COD')
			SA1->(DbSetOrder(1))
			While(SA1->(DbSeek(xFilial('SA1') + cCodSA1 + cCodLoja)))
				cCodSA1 := Soma1(cCodSA1)
			EndDo

			
			
			Reclock("SA1",.T.)
			SA1->A1_FILIAL 		:= SUS->US_FILIAL
			SA1->A1_COD 		:= cCodSA1
			SA1->A1_LOJA		:= cCodLoja
			SA1->A1_NOME		:= SUS->US_NOME
			SA1->A1_NREDUZ	 	:= SUS->US_NREDUZ
			SA1->A1_TIPO		:= SUS->US_TIPO
			SA1->A1_END			:= SUS->US_END
			SA1->A1_COD_MUN		:= SUS->US_COD_MUN
			SA1->A1_REGIAO		:= SUS->US_REGIAO
			SA1->A1_MUN			:= SUS->US_MUN
			SA1->A1_PESSOA		:= SUS->US_PESSOA
			//SA1->A1_NUMERO	:= SUS->US_NUMERO
			SA1->A1_BAIRRO		:= SUS->US_BAIRRO
			SA1->A1_CEP			:= SUS->US_CEP
			SA1->A1_EST			:= SUS->US_EST
			SA1->A1_DDI			:= SUS->US_DDI
			SA1->A1_DDD			:= SUS->US_DDD
			SA1->A1_TEL			:= SUS->US_TEL
			SA1->A1_FAX			:= SUS->US_FAX
			SA1->A1_EMAIL		:= SUS->US_EMAIL
			SA1->A1_HPAGE		:= SUS->US_URL
			SA1->A1_ULTVIS		:= SUS->US_ULTVIS
			SA1->A1_CODHIST		:= SUS->US_CODHIST
			SA1->A1_CGC			:= SUS->US_CGC
			SA1->A1_INSCR		:= SUS->US_INSCR
			SA1->A1_SATIV1		:= SUS->US_SATIV
			SA1->A1_SATIV2		:= SUS->US_SATIV2
			SA1->A1_SATIV3		:= SUS->US_SATIV3
			SA1->A1_SATIV4		:= SUS->US_SATIV4
			SA1->A1_SATIV5		:= SUS->US_SATIV5
			SA1->A1_SATIV6		:= SUS->US_SATIV6
			SA1->A1_SATIV7		:= SUS->US_SATIV7
			SA1->A1_SATIV8		:= SUS->US_SATIV8
			SA1->A1_VEND		:= SUS->US_VEND
			SA1->A1_ULTVIS		:= SUS->US_ULTVIS
			//SA1->A1_VENDARQ	:= SUS->US_VENDARQ
			//SA1->A1__PESCLI 	:= SUS->US__PESCLI   
			SA1->A1_LC			:= SUS->US_LC
			SA1->A1_VENCLC		:= SUS->US_VENCLC
			SA1->A1_MOEDALC		:= SUS->US_MOEDALC    
			SA1->A1_NATUREZ		:= SUS->US_NATUREZ
			SA1->A1_SUFRAMA		:= SUS->US_SUFRAMA
			SA1->A1_TPESSOA		:= SUS->US_TPESSOA
			SA1->A1_HRTRANS		:= SUS->US_TRASLA
			SA1->A1_CONTRIB		:= SUS->US_CONTRIB      
			SA1->A1_RECCOFI		:= SUS->US_RECCOFI
			SA1->A1_RECCSLL		:= SUS->US_RECCSLL
			SA1->A1_RECPIS		:= SUS->US_RECPIS
			SA1->A1_RECINSS		:= SUS->US_RECINSS
			SA1->A1_RECISS		:= SUS->US_RECISS
		
			// Solicitações da Ninfa:
			SA1->A1_RISCO 		:= "E"
			SA1->A1_COND		:= "99"
			SA1->A1_MSBLQL		:= "1"             
			SA1->A1_CNAE		:= SUS->US_CNAE        
			SA1->A1_HRCAD		:= Time()
			SA1->A1_DTCAD		:= dDataBase
			
			FkCommit()
			MsUnlock()
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Pegou um codigo novo confirma a gravacao do SXE³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If __lSX8
				ConfirmSX8()
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Altera os relacionamentos de contatos para a nova entidade - CLIENTES ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("AC8")
			DbSetOrder(2) 		//AC8_FILIAL+AC8_ENTIDA+AC8_FILENT+AC8_CODENT+AC8_CODCON
			If DbSeek(xFilial("AC8")+"SUS"+xFilial("SUS")+(SUS->US_COD+SUS->US_LOJA))
				While (!Eof()) 									.AND.;
					(AC8->AC8_FILIAL == xFilial("AC8")) 		.AND.;
					(AC8->AC8_ENTIDA == "SUS") 		  			.AND.;
					(AC8->AC8_FILENT == xFilial("SUS")) 		.AND.;
					(ALLTRIM(AC8->AC8_CODENT) == ALLTRIM(SUS->US_COD + SUS->US_LOJA))
					
					Reclock("AC8",.F.)
					Replace AC8_FILIAL With xFilial("AC8")
					Replace AC8_ENTIDA With "SA1"
					Replace AC8_FILENT With xFilial("SA1")
					Replace AC8_CODENT With cCodSA1+cCodLoja
					MsUnlock()
					DbCommit()
					
					AC8->(Dbskip())
				End
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza o STATUS do prospect  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SUS")
			Reclock( "SUS" ,.F.)
			Replace US_STATUS  With "6" 			// 6 - Cliente
			Replace US_CODCLI  With SA1->A1_COD
			Replace US_LOJACLI With SA1->A1_LOJA
			Replace US_DTCONV  With Date()  
			Replace US_HRCONV  With Time()
			MsUnlock()
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se ha banco de conhecimento e o transforma em cliente tambem³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ChkFile("AC9",.F.,"__AC9")
			
			dbSelectArea("__AC9")
			dbSetOrder(2)
			dbSeek( cWhile := xFilial("AC9") + "SUS" + xFilial("SUS") + SUS->US_COD + SUS->US_LOJA )
			
			Do While !Eof() .And. cWhile == AC9_FILIAL + AC9_ENTIDA + AC9_FILENT + SubStr(AC9_CODENT,1,TamSX3("US_COD")[1]+TamSX3("US_LOJA")[1])
				AC9->( RecLock("AC9",.T.) )
				For nX := 1 to FCount()
					AC9->( FieldPut(nX,__AC9->(FieldGet(nX)) ) )
				Next nX
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Troca da chave unica³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				AC9->AC9_FILENT := xFilial("SA1")
				AC9->AC9_ENTIDA := "SA1"
				AC9->AC9_CODENT := SA1->A1_COD + SA1->A1_LOJA
				
				AC9->( MsUnlock() )
				
				dbSelectArea("__AC9")
				dbSkip()
			EndDo
			__AC9->( dbCloseArea() )
			
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se existe orcamentos para este prospect, ajusta o codigo do cliente³
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			SCK->(DbSetOrder(1))
			cAliasJ := GetNextAlias()
			BeginSql Alias cAliasJ
				SELECT 
				  SCJ.R_E_C_N_O_ NREG	
				FROM %Table:SCJ% SCJ
				WHERE
					SCJ.CJ_FILIAL = %Exp:FwxFilial("SCJ")%
					AND SCJ.CJ_PROSPE = %Exp:SUS->US_COD%
					AND SCJ.CJ_LOJPRO = %Exp:SUS->US_LOJA%
					AND SCJ.%NotDel%
			EndSql
			
			Do While (cAliasJ)->(!Eof()) 
				SCJ->(DbGoto( (cAliasJ)->NREG ))
				SCJ->( RecLock("SCJ",.F.) )
				SCJ->CJ_CLIENTE  := SA1->A1_COD
				SCJ->CJ_LOJA 		:= SA1->A1_LOJA
				SCJ->CJ_CLIENT	:= SA1->A1_COD
				SCJ->CJ_LOJAENT	:= SA1->A1_LOJA
				SCJ->( MsUnlock() )
				
				SCK->(DbSeek( FwxFilial("SCK") + SCJ->CJ_NUM ))
				Do While SCK->(!Eof()) .and. SCK->CK_FILIAL + SCK->CK_NUM == FwxFilial("SCK") + SCJ->CJ_NUM
					RecLock("SCK",.F.)
					SCK->CK_CLIENTE := SA1->A1_COD
					SCK->CK_LOJA		:= SA1->A1_LOJA
					
					SCK->(DbSkip())
				Enddo
				
				(cAliasJ)->(DbSkip())
			Enddo
			
			(cAliasJ)->(DbCloseArea())		
			
			lRet := .T.
		Else
			U_MsgHBox("Este prospect já possui cliente","TK260ROT_01")
		EndIf
	EndIf
EndIf

RestArea( aArea )

Return Nil
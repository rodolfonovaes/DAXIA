#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

 /*/{Protheus.doc} DAXREL01
    Relatorio de Custo Homologado
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
User Function DAXREL01
Processa({|| ProcInc()},"Processando Historico de Custo Homologado","Processando Historico de Custo Homologado, Aguarde...")
Return

Static Function ProcInc()

Local cAliasQry := GetNextAlias()
Local aParam := {}
Local aRet := {}
Local cQuery := ""
Local oFWMsExcel
Local cArquivo    := GetTempPath() + StrTran(Time(),":","") + '.xml'
Local aResult	:= {}
local n
Local aX3cBox	:= RetSx3Box( GetSX3Cache("Z4_OPCAO","X3_CBOX"),,,1)
Local nPos		:= 0

aAdd(aParam, {1, "Produto de"		, CriaVar('B1_COD',.F.) ,  ,, 'SB1',, 60, .F.} )
aAdd(aParam, {1, "Produto Até"		, CriaVar('B1_COD',.F.) ,  ,, 'SB1',, 60, .F.} )
aAdd(aParam, {1, "Data de"			, dDataBase ,  ,, ,, 60, .T.} )
aAdd(aParam, {1, "Data Até"			, dDataBase ,  ,, ,, 60, .T.} )

If ParamBox(aParam,'Parâmetros',aRet)


	cQuery += " SELECT *  " + CRLF

	cQuery += " FROM " + RetSQLName("SZ4") + " SZ4 " + CRLF

	cQuery += " WHERE Z4_COD BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' " + CRLF
	cQuery += " AND Z4_DATA BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "' " + CRLF
	cQuery += " AND SZ4.D_E_L_E_T_ = '' AND Z4_DESCART <> 'S' " + CRLF
	cQuery += " ORDER BY Z4_FILIAL , Z4_COD " + CRLF

	TcQuery cQuery new Alias ( cAliasQry )

	Count to nTotReg

	(cAliasQry)->(dbGoTop())

	If !(cAliasQry)->(EOF())
		oFWMsExcel := FWMSExcel():New()

		oFWMsExcel:AddworkSheet("CUSTO HOMOLOGADO")

	    //Criando a Tabela
	    oFWMsExcel:AddTable("CUSTO HOMOLOGADO","ITENS")
	    oFWMsExcel:AddColumn("CUSTO HOMOLOGADO","ITENS","Filial",1)
	    oFWMsExcel:AddColumn("CUSTO HOMOLOGADO","ITENS","Data da alteração",1)
		oFWMsExcel:AddColumn("CUSTO HOMOLOGADO","ITENS","Hora",1)
		oFWMsExcel:AddColumn("CUSTO HOMOLOGADO","ITENS","Codigo",1)
	    oFWMsExcel:AddColumn("CUSTO HOMOLOGADO","ITENS","Descrição",1)
		oFWMsExcel:AddColumn("CUSTO HOMOLOGADO","ITENS","Moeda",1)
	    oFWMsExcel:AddColumn("CUSTO HOMOLOGADO","ITENS","Custo Anterior",1)
		oFWMsExcel:AddColumn("CUSTO HOMOLOGADO","ITENS","Custo Medio",1)
	    oFWMsExcel:AddColumn("CUSTO HOMOLOGADO","ITENS","Novo Custo Homologado",1)
		oFWMsExcel:AddColumn("CUSTO HOMOLOGADO","ITENS","Opção",1)
		oFWMsExcel:AddColumn("CUSTO HOMOLOGADO","ITENS","Fornecedor",1)
		oFWMsExcel:AddColumn("CUSTO HOMOLOGADO","ITENS","Loja",1)
		oFWMsExcel:AddColumn("CUSTO HOMOLOGADO","ITENS","Nome",1)
		oFWMsExcel:AddColumn("CUSTO HOMOLOGADO","ITENS","Usuario",1)

		While !(cAliasQry)->(EOF())
			nPos := AScan(aX3cBox, {|x| x[2] == Alltrim((cAliasQry)->Z4_OPCAO)})
	    	oFWMsExcel:AddRow("CUSTO HOMOLOGADO","ITENS",{;
								FWFilialName(cEmpAnt,(cAliasQry)->Z4_FILIAL),;
								DTOC(STOD((cAliasQry)->Z4_DATA)),;
								(cAliasQry)->Z4_HORA,;
								(cAliasQry)->Z4_COD,;
								(cAliasQry)->Z4_DESC,;
								IIF(Alltrim((cAliasQry)->Z4_MOEDA) == '1', 'Real','Dolar'),;
								Alltrim(Transform( (cAliasQry)->Z4_CANTER, "@E 999,999,999,999.99" )),;
								Alltrim(Transform( (cAliasQry)->Z4_CMEDIO, "@E 999,999,999,999.99" )),;
                                Alltrim(Transform( (cAliasQry)->Z4_CHOMOLO, "@E 999,999,999,999.99" )),;
								Iif(nPos > 0 ,aX3cBox[nPos,3], ''),;
								(cAliasQry)->Z4_FORNECE,;
								(cAliasQry)->Z4_LOJA,;
								(cAliasQry)->Z4_NOME,;
								(cAliasQry)->Z4_USER;
								})
			(cAliasQry)->(dbSkip())
		EndDo
		//Ativando o arquivo e gerando o xml
		oFWMsExcel:Activate()
		oFWMsExcel:GetXMLFile(cArquivo)


		//Abrindo o excel e abrindo o arquivo xml
		oExcel := MsExcel():New()             //Abre uma nova conexão com Excel
		oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
		oExcel:SetVisible(.T.)                 //Visualiza a planilha
		oExcel:Destroy()

	Else
			Help(,, 'DAXREL01',, 'Nenhum registro encontrado.', 1, 0 )

	Endif

	(cAliasQry)->(dbCloseArea())

Else
	MsgInfo("Cancelado pelo usuário.")
Endif

Return
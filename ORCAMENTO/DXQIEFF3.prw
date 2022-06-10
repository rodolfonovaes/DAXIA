User Function DXQCLI() //USADO NA CONSULTA PADRAO DAXTRA - CAMPO CJ_XTRANSP
	Local cTitulo		:= "Cliente/Fornecedor"
	Local cQuery		:= "" 								//obrigatorio
	Local cAlias		:= "SA1"							//obrigatorio
	Local cCpoChave	:= "A1_COD" 					//obrigatorio
	Local cTitCampo	:= RetTitle(cCpoChave)			//obrigatorio
	Local cMascara	:= PesqPict(cAlias,cCpoChave)	//obrigatorio
	Local nTamCpo		:= TamSx3(cCpoChave)[1]		
	Local cRetCpo		:= "xCliFor"					//obrigatorio
    Local cRetCpo2      := "xLoja"
	Local nColuna		:= 1	
	Local cCodigo		:= 'A4_COD'		//pego o conteudo e levo para minha consulta padrão			
    Local cEst          := ''
    Local cCidade       := ''
 	Private bRet 		:= .F.
    Public xCliFor      := ''
    Public xLoja      := ''

    If M->QI2_XRELAC =='1'
        cAlias		:= "SA1"
        cCpoChave	:= "A1_COD" 
        //Monto minha consulta, neste caso quero retornar apenas uma coluna, mas poderia inserir outros campos para compor outras colunas no grid, lembrando que não posso utilizar um alias para o nome do campo, deixar o nome real.
        //Posso fazer qualquer tipo de consulta, usando INNER, GROUPY BY, UNION's etc..., desde que mantenha o nome dos campos no SELECT.
        cQuery := " SELECT DISTINCT A1_COD,A1_LOJA, A1_NOME "
        cQuery += " FROM "+RetSQLName("SA1") + " AS SA1 " //WITH (NOLOCK)
        cQuery += " WHERE A1_FILIAL  = '" + xFilial("SA1") + "' "
        cQuery += " AND SA1.D_E_L_E_T_ = ' ' "
        cQuery += " ORDER BY A1_COD, A1_LOJA "
    ElseIf M->QI2_XRELAC =='2'
        cAlias		:= "SA2"
        cCpoChave	:= "A2_COD"     
        cQuery := " SELECT DISTINCT A2_COD,A2_LOJA, A2_NOME "
        cQuery += " FROM "+RetSQLName("SA2") + " AS SA2 " //WITH (NOLOCK)
        cQuery += " WHERE A2_FILIAL  = '" + xFilial("SA2") + "' "
        cQuery += " AND SA2.D_E_L_E_T_ = ' ' "
        cQuery += " ORDER BY A2_COD, A2_LOJA "
    EndIf
 
 	bRet := U_FiltroF3(cTitulo,cQuery,nTamCpo,cAlias,cCodigo,cCpoChave,cTitCampo,cMascara,cRetCpo,cRetCpo2,nColuna,2)
Return(bRet)



 /*/{Protheus.doc} DXQLOJA()
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
User Function DXQLOJA()
Local cRet := ''

If M->QI2_XRELAC =='1'
    cRet := SA1->A1_LOJA
ElseIf M->QI2_XRELAC =='2'
    cRet := SA2->A2_LOJA
EndIf

Return cRet

User Function DXQNOME()
Local cRet := ''

If M->QI2_XRELAC =='1'
    cRet := Posicione('SA1',1,xFilial('SA1') + PADR(M->QI2_XCLIFO,TAMSX3('A1_COD')[1]) + PADR(M->QI2_XLOJA,TAMSX3('A1_LOJA')[1]),'A1_NOME')
ElseIf M->QI2_XRELAC =='2'
    cRet := Posicione('SA2',1,xFilial('SA2') + PADR(M->QI2_XCLIFO,TAMSX3('A2_COD')[1]) + PADR(M->QI2_XLOJA,TAMSX3('A2_LOJA')[1]),'A2_NOME')
EndIf

Return cRet



User Function DXQDOC() //USADO NA CONSULTA PADRAO DAXTRA - CAMPO CJ_XTRANSP
	Local cTitulo		:= "Doc Saida/Doc Entrada"
	Local cQuery		:= "" 								//obrigatorio
	Local cAlias		:= "SF2"							//obrigatorio
	Local cCpoChave	:= "F2_DOC" 					//obrigatorio
	Local cTitCampo	:= RetTitle(cCpoChave)			//obrigatorio
	Local cMascara	:= PesqPict(cAlias,cCpoChave)	//obrigatorio
	Local nTamCpo		:= TamSx3(cCpoChave)[1]		
	Local cRetCpo		:= "xDoc"					//obrigatorio
    Local cRetCpo2      := "xEmissao"
	Local nColuna		:= 1	
	Local cCodigo		:= 'F2_DOC'		//pego o conteudo e levo para minha consulta padrão			
    Local cEst          := ''
    Local cCidade       := ''
 	Private bRet 		:= .F.
    Public xDoc      := ''
    Public xEmissao      := Stod('')

    If M->QI2_XRELAC =='1'
        cAlias		:= "SF2"
        cCpoChave	:= "F2_DOC" 
        //Monto minha consulta, neste caso quero retornar apenas uma coluna, mas poderia inserir outros campos para compor outras colunas no grid, lembrando que não posso utilizar um alias para o nome do campo, deixar o nome real.
        //Posso fazer qualquer tipo de consulta, usando INNER, GROUPY BY, UNION's etc..., desde que mantenha o nome dos campos no SELECT.
        cQuery := " SELECT DISTINCT F2_DOC,F2_EMISSAO "
        cQuery += " FROM "+RetSQLName("SF2") + " AS SF2 " //WITH (NOLOCK)
        cQuery += " WHERE F2_FILIAL  = '" + xFilial("SF2") + "' "
        cQuery += " AND F2_CLIENTE =  '" + M->QI2_XCLIFO + "' "
        cQuery += " AND F2_LOJA =  '" + M->QI2_XLOJA + "' "
        cQuery += " AND SF2.D_E_L_E_T_ = ' ' "
        cQuery += " ORDER BY F2_DOC,F2_EMISSAO "
    ElseIf M->QI2_XRELAC =='2'
        cAlias		:= "SF1"
        cCpoChave	:= "F1_DOC"     
        cQuery := " SELECT DISTINCT F1_DOC,F1_EMISSAO "
        cQuery += " FROM "+RetSQLName("SF1") + " AS SF1 " //WITH (NOLOCK)
        cQuery += " WHERE F1_FILIAL  = '" + xFilial("SF1") + "' "
        cQuery += " AND F1_FORNECE =  '" + M->QI2_XCLIFO + "' "
        cQuery += " AND F1_LOJA =  '" + M->QI2_XLOJA + "' "
        cQuery += " AND SF1.D_E_L_E_T_ = ' ' "
        cQuery += " ORDER BY F1_DOC,F1_EMISSAO "
    EndIf
 
 	bRet := U_FiltroF3(cTitulo,cQuery,nTamCpo,cAlias,cCodigo,cCpoChave,cTitCampo,cMascara,cRetCpo,cRetCpo2,nColuna,2)
Return(bRet)

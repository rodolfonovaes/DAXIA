User Function DXGFEF3() //USADO NA CONSULTA PADRAO DAXTRA - CAMPO CJ_XTRANSP
	Local cTitulo		:= "Transportadoras"
	Local cQuery		:= "" 								//obrigatorio
	Local cAlias		:= "SA4"							//obrigatorio
	Local cCpoChave	:= "A4_COD" 					//obrigatorio
	Local cTitCampo	:= RetTitle(cCpoChave)			//obrigatorio
	Local cMascara	:= PesqPict(cAlias,cCpoChave)	//obrigatorio
	Local nTamCpo		:= TamSx3(cCpoChave)[1]		
	Local cRetCpo		:= "xTransp"
    Local cRetCpo2      := ""					//obrigatorio
	Local nColuna		:= 1	
	Local cCodigo		:= Space(tamsx3('A4_COD')[1])		//pego o conteudo e levo para minha consulta padrão			
    Local cEst          := ''
    Local cCidade       := ''
    Local cCidOri   := ''
    Local cEstOri   := ''    
 	Private bRet 		:= .F.
    Public xTransp      := ''
    Public xNil         := ''


    SA1->(DbSetOrder(1))
    SA1->(DBSeek(xFilial('SA1') + M->(CJ_CLIENTE + CJ_LOJA)))

    cCidade := SA1->A1_COD_MUN
    cEst    := SA1->A1_EST

    do case
        Case cFilAnt == '0101'
            cEstOri := '35'
            cCidOri := '50308'    
        Case cFilAnt == '0102'
            cEstOri := '42'
            cCidOri := '08203'
        Case cFilAnt == '0103'
            cEstOri := '35'
            cCidOri := '18800'
        Case cFilAnt == '0104'
            cEstOri := '26'
            cCidOri := '07901'            
    EndCase

    If M->CJ_XTPFRETE =='1'
        //Monto minha consulta, neste caso quero retornar apenas uma coluna, mas poderia inserir outros campos para compor outras colunas no grid, lembrando que não posso utilizar um alias para o nome do campo, deixar o nome real.
        //Posso fazer qualquer tipo de consulta, usando INNER, GROUPY BY, UNION's etc..., desde que mantenha o nome dos campos no SELECT.
        cQuery := " SELECT DISTINCT A4_COD, A4_NOME "
        cQuery += " FROM "+RetSQLName("SA4") + " AS SA4 " //WITH (NOLOCK)
        cQuery += " INNER JOIN "+RetSQLName("GU3") + " AS GU3 ON GU3_IDFED = A4_CGC AND GU3.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
        cQuery += " INNER JOIN "+RetSQLName("GV8") + " AS GV8 ON GU3_CDEMIT = GV8_CDEMIT  AND GV8.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
        cQuery += " INNER JOIN "+RetSQLName("GU7") + " AS GU7 ON GU7_NRCID = GV8_NRCIDS  AND GU7.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
        cQuery += " WHERE A4_FILIAL  = '" + xFilial("SA4") + "' "
        cQuery += " AND SA4.D_E_L_E_T_= ' ' "
        cQuery += " AND GU7_CDUF =  '" + cEst + "' "
        cQuery += " AND GV8_NRCIOR =  '" + cEstOri + cCidOri + "' "
        cQuery += " AND SUBSTRING(GU7_NRCID,3,5) =  '" + cCidade + "' "
        cQuery += " UNION "
        cQuery += " SELECT DISTINCT A4_COD, A4_NOME "
        cQuery += " FROM "+RetSQLName("SA4") + " AS SA4 " //WITH (NOLOCK)
        cQuery += " INNER JOIN "+RetSQLName("GU3") + " AS GU3 ON GU3_IDFED = A4_CGC AND GU3.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
        cQuery += " INNER JOIN "+RetSQLName("GV8") + " AS GV8 ON GU3_CDEMIT = GV8_CDEMIT  AND GV8.D_E_L_E_T_ = ' ' AND GV8_TPDEST = '3' " //WITH (NOLOCK)
        cQuery += " INNER JOIN "+RetSQLName("GUA") + " AS GUA ON GV8_NRREDS = GUA_NRREG AND GUA.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
        cQuery += " WHERE A4_FILIAL  = '" + xFilial("SA4") + "' "
        cQuery += " AND (GV8_NRCIOR =  '" + cEstOri + cCidOri + "' OR GV8_TPORIG = '0')"
        cQuery += " AND GUA_NRCID =  '" + cEstOri + cCidOri + "' "
        cQuery += " AND SA4.D_E_L_E_T_= ' ' "           
        cQuery += " UNION "
        cQuery += " SELECT DISTINCT A4_COD, A4_NOME "
        cQuery += " FROM "+RetSQLName("SA4") + " AS SA4 " //WITH (NOLOCK)
        cQuery += " INNER JOIN "+RetSQLName("GU3") + " AS GU3 ON GU3_IDFED = A4_CGC AND GU3.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
        cQuery += " INNER JOIN "+RetSQLName("GV8") + " AS GV8 ON GU3_CDEMIT = GV8_CDEMIT  AND GV8.D_E_L_E_T_ = ' ' AND GV8_TPDEST = '4' " //WITH (NOLOCK)
        cQuery += " WHERE A4_FILIAL  = '" + xFilial("SA4") + "' "
        cQuery += " AND (GV8_NRCIOR =  '" + cEstOri + cCidOri + "' OR GV8_TPORIG = '0')"
        cQuery += " AND GV8_CDUFDS =  '" + cEst + "' "
        cQuery += " AND SA4.D_E_L_E_T_= ' ' "        
        cQuery += " UNION "
        cQuery += " SELECT DISTINCT A4_COD, A4_NOME "
        cQuery += " FROM "+RetSQLName("SA4") + " AS SA4 " //WITH (NOLOCK)
        cQuery += " INNER JOIN "+RetSQLName("GU3") + " AS GU3 ON GU3_IDFED = A4_CGC AND GU3.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
        cQuery += " INNER JOIN "+RetSQLName("GV8") + " AS GV8 ON GU3_CDEMIT = GV8_CDEMIT  AND GV8.D_E_L_E_T_ = ' ' AND GV8_TPDEST = '0' " //WITH (NOLOCK)
        cQuery += " WHERE A4_FILIAL  = '" + xFilial("SA4") + "' "
        cQuery += " AND (GV8_NRCIOR =  '" + cEstOri + cCidOri + "' OR GV8_TPORIG = '0')"
        cQuery += " AND SA4.D_E_L_E_T_= ' ' "
        cQuery += " ORDER BY A4_COD, A4_NOME "        

        
    Else
        cQuery := " SELECT DISTINCT A4_COD, A4_NOME "
        cQuery += " FROM "+RetSQLName("SA4") + " AS SA4 " //WITH (NOLOCK)
        cQuery += " WHERE A4_FILIAL  = '" + xFilial("SA4") + "' "
        cQuery += " AND SA4.D_E_L_E_T_= ' ' "
        cQuery += " ORDER BY A4_COD, A4_NOME "    
    EndIf
 
 	bRet := U_FiltroF3(cTitulo,cQuery,nTamCpo,cAlias,cCodigo,cCpoChave,cTitCampo,cMascara,cRetCpo,cRetCpo2,nColuna,2)
Return(bRet)

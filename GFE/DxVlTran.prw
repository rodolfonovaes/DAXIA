 /*/{Protheus.doc} DxVlTransp
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
User Function DxVlTran()
Local lRet := .T.
Local cQuery		:= "" 	
Local cAliasQry := GetNextAlias()							//obrigatorio	
Local cEst          := ''
Local cCidade       := ''
Local cCidOri   := ''
Local cEstOri   := ''    
Local aEst      := {}
Local cCodEst   := ''
Local nPos      := 0 

aEst := {;
{'12','AC'},;
{'27','AL'},;	
{'13','AM'},;	
{'16','AP'},;	
{'29','BA'},;	
{'23','CE'},;	
{'53','DF'},;	
{'32','ES'},;	
{'52','GO'},;	
{'21','MA'},;	
{'31','MG'},;	
{'50','MS'},;	
{'51','MT'},;	
{'15','PA'},;	
{'25','PB'},;	
{'26','PE'},;	
{'22','PI'},;	
{'41','PR'},;	
{'33','RJ'},;	
{'24','RN'},;	
{'11','RO'},;	
{'14','RR'},;	
{'43','RS'},;	
{'42','SC'},;	
{'28','SE'},;	
{'35','SP'},;	
{'17','TO'};
}



SA1->(DbSetOrder(1))
SA1->(DBSeek(xFilial('SA1') + M->(CJ_CLIENTE + CJ_LOJA)))

cCidade := SA1->A1_COD_MUN
cEst    := SA1->A1_EST
nPos    := aScan(aEst,{|x| AllTrim(x[2])==cEst})
If nPos != 0
    cCodEst := aEst[nPos][1]
EndIf
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

If M->CJ_XTPFRETE =='1' //.And. UPPER(Alltrim(GetEnvServer())) == 'GFE'
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
    cQuery += " AND SA4.A4_COD = '"+ M->CJ_XTRANSP +"' "
    cQuery += " UNION "
    cQuery += " SELECT DISTINCT A4_COD, A4_NOME "
    cQuery += " FROM "+RetSQLName("SA4") + " AS SA4 " //WITH (NOLOCK)
    cQuery += " INNER JOIN "+RetSQLName("GU3") + " AS GU3 ON GU3_IDFED = A4_CGC AND GU3.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
    cQuery += " INNER JOIN "+RetSQLName("GV8") + " AS GV8 ON GU3_CDEMIT = GV8_CDEMIT  AND GV8.D_E_L_E_T_ = ' ' AND GV8_TPDEST = '3' " //WITH (NOLOCK)
    cQuery += " INNER JOIN "+RetSQLName("GUA") + " AS GUA ON GV8_NRREDS = GUA_NRREG AND GUA.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
    cQuery += " WHERE A4_FILIAL  = '" + xFilial("SA4") + "' "
    cQuery += " AND (GV8_NRCIOR =  '" + cEstOri + cCidOri + "' OR GV8_TPORIG = '0')"
    cQuery += " AND GUA_NRCID =  '" + cCodEst + cCidade + "' "
    cQuery += " AND SA4.A4_COD = '"+ M->CJ_XTRANSP +"' "
    cQuery += " AND SA4.D_E_L_E_T_= ' ' "           
    cQuery += " UNION "
    cQuery += " SELECT DISTINCT A4_COD, A4_NOME "
    cQuery += " FROM "+RetSQLName("SA4") + " AS SA4 " //WITH (NOLOCK)
    cQuery += " INNER JOIN "+RetSQLName("GU3") + " AS GU3 ON GU3_IDFED = A4_CGC AND GU3.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
    cQuery += " INNER JOIN "+RetSQLName("GV8") + " AS GV8 ON GU3_CDEMIT = GV8_CDEMIT  AND GV8.D_E_L_E_T_ = ' ' AND GV8_TPDEST = '4' " //WITH (NOLOCK)
    cQuery += " WHERE A4_FILIAL  = '" + xFilial("SA4") + "' "
    cQuery += " AND (GV8_NRCIOR =  '" + cEstOri + cCidOri + "' OR GV8_TPORIG = '0')"
    cQuery += " AND GV8_CDUFDS =  '" + cEst + "' "
    cQuery += " AND SA4.A4_COD = '"+ M->CJ_XTRANSP +"' "
    cQuery += " AND SA4.D_E_L_E_T_= ' ' "        
    cQuery += " UNION "
    cQuery += " SELECT DISTINCT A4_COD, A4_NOME "
    cQuery += " FROM "+RetSQLName("SA4") + " AS SA4 " //WITH (NOLOCK)
    cQuery += " INNER JOIN "+RetSQLName("GU3") + " AS GU3 ON GU3_IDFED = A4_CGC AND GU3.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
    cQuery += " INNER JOIN "+RetSQLName("GV8") + " AS GV8 ON GU3_CDEMIT = GV8_CDEMIT  AND GV8.D_E_L_E_T_ = ' ' AND GV8_TPDEST = '0' " //WITH (NOLOCK)
    cQuery += " WHERE A4_FILIAL  = '" + xFilial("SA4") + "' "
    cQuery += " AND (GV8_NRCIOR =  '" + cEstOri + cCidOri + "' OR GV8_TPORIG = '0')"
    cQuery += " AND SA4.A4_COD = '"+ M->CJ_XTRANSP +"' "
    cQuery += " AND SA4.D_E_L_E_T_= ' ' "
    cQuery += " ORDER BY A4_COD, A4_NOME "    


	DbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
     
	(cAliasQry)->(DbGoTop())
	If (cAliasQry)->(Eof())
        MsgStop("TRANSPORTADORA SEM TABELA DE PREÇO CADASTRADA PARA ESTA REGIÃO, POR FAVOR ENTRAR EM CONTATO COM O DEPARTAMENTO DE COMPRAS")
        lRet := .F.
    EndIf    
    (cAliasQry)->(dbclosearea())
EndIf
Return lRet

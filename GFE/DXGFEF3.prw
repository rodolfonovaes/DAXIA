User Function DXGFEF3() //USADO NA CONSULTA PADRAO DAXTRA - CAMPO CJ_XTRANSP
	Local cTitulo		:= "Transportadoras"
	Local cQuery		:= "" 								//obrigatorio
	Local cAlias		:= "SA4"							//obrigatorio
	Local cCpoChave	:= "A4_NOME" 					//obrigatorio
	Local cTitCampo	:= RetTitle(cCpoChave)			//obrigatorio
	Local cMascara	:= PesqPict(cAlias,cCpoChave)	//obrigatorio
	Local nTamCpo		:= TamSx3(cCpoChave)[1]		
	Local cRetCpo		:= "xTransp"
    Local cRetCpo2      := ""					//obrigatorio
	Local nColuna		:= 1	
	Local cCodigo		:= Space(tamsx3('A4_NOME')[1])		//pego o conteudo e levo para minha consulta padrão			
    Local cEst          := ''
    Local cCidade       := ''
    Local cCidOri   := ''
    Local cEstOri   := ''    
    Local aEst      := {}
    Local cCodEst   := ''
    Local nPos      := 0 
 	Private bRet 		:= .F.
    Public xTransp      := ''
    Public xNil         := ''

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
    //MsgAlert(Alltrim(GetEnvServer()), 'Env')
    If M->CJ_XTPFRETE =='1' //.And. UPPER(Alltrim(GetEnvServer())) == 'GFE'
        //Monto minha consulta, neste caso quero retornar apenas uma coluna, mas poderia inserir outros campos para compor outras colunas no grid, lembrando que não posso utilizar um alias para o nome do campo, deixar o nome real.
        //Posso fazer qualquer tipo de consulta, usando INNER, GROUPY BY, UNION's etc..., desde que mantenha o nome dos campos no SELECT.
        cQuery := " SELECT DISTINCT A4_COD, A4_NOME, GVA_XCONTR , GV6_NRTAB , GV6_QTPRAZ"
        cQuery += " FROM "+RetSQLName("SA4") + " AS SA4 " //WITH (NOLOCK)
        cQuery += " INNER JOIN "+RetSQLName("GU3") + " AS GU3 ON GU3_IDFED = A4_CGC AND A4_CGC <> ' ' AND GU3.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
        cQuery += " INNER JOIN "+RetSQLName("GVA") + " AS GVA ON GU3_CDEMIT = GVA_CDEMIT AND GVA.D_E_L_E_T_ = ' '  " //WITH (NOLOCK)
        cQuery += " INNER JOIN "+RetSQLName("GV8") + " AS GV8 ON GU3_CDEMIT = GV8_CDEMIT  AND GV8.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
        cQuery += " INNER JOIN "+RetSQLName("GV9") + " AS GV9 ON GU3_CDEMIT = GV9_CDEMIT  AND GVA_NRTAB = GV9_NRTAB AND GV8_NRNEG = GV9_NRNEG AND GV9.D_E_L_E_T_ = ' ' AND GV9_SIT = '2' " //WITH (NOLOCK)
        cQuery += " INNER JOIN "+RetSQLName("GU7") + " AS GU7 ON GU7_NRCID = GV8_NRCIDS  AND GU7.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
        cQuery += " INNER JOIN "+RetSQLName("GV6") + " AS GV6 ON GV6_CDEMIT = GV8_CDEMIT AND GV8_NRTAB = GV6_NRTAB AND GV8_NRNEG = GV6_NRNEG AND GV8_NRROTA = GV6_NRROTA AND GV6.D_E_L_E_T_ = ' ' AND GVA_NRTAB = GV6_NRTAB AND " //WITH (NOLOCK)
        cQuery += " GV6_CDFXTV = ( SELECT MAX(GV6_CDFXTV) FROM "+RetSQLName("GV6") + " AS GV6 WHERE GV6_CDEMIT = GV8_CDEMIT AND GV8_NRTAB = GV6_NRTAB AND GV8_NRNEG = GV6_NRNEG AND GV8_NRROTA = GV6_NRROTA AND GV6.D_E_L_E_T_ = ' ' ) " //WITH (NOLOCK)
        cQuery += " WHERE A4_FILIAL  = '" + xFilial("SA4") + "' "
        cQuery += " AND SA4.D_E_L_E_T_= ' ' "
        cQuery += " AND GU7_CDUF =  '" + cEst + "' "
        cQuery += " AND GV8_NRCIOR =  '" + cEstOri + cCidOri + "' "
        cQuery += " AND SUBSTRING(GU7_NRCID,3,5) =  '" + cCidade + "' "
        cQuery += " UNION "
        cQuery += " SELECT DISTINCT A4_COD, A4_NOME, GVA_XCONTR , GV6_NRTAB , GV6_QTPRAZ"
        cQuery += " FROM "+RetSQLName("SA4") + " AS SA4 " //WITH (NOLOCK)
        cQuery += " INNER JOIN "+RetSQLName("GU3") + " AS GU3 ON GU3_IDFED = A4_CGC AND A4_CGC <> ' ' AND GU3.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
        cQuery += " INNER JOIN "+RetSQLName("GVA") + " AS GVA ON GU3_CDEMIT = GVA_CDEMIT AND GVA.D_E_L_E_T_ = ' '  " //WITH (NOLOCK)
        cQuery += " INNER JOIN "+RetSQLName("GV8") + " AS GV8 ON GU3_CDEMIT = GV8_CDEMIT  AND GV8.D_E_L_E_T_ = ' ' AND GV8_TPDEST = '3' " //WITH (NOLOCK)
        cQuery += " INNER JOIN "+RetSQLName("GV9") + " AS GV9 ON GU3_CDEMIT = GV9_CDEMIT  AND GVA_NRTAB = GV9_NRTAB AND GV8_NRNEG = GV9_NRNEG AND GV9.D_E_L_E_T_ = ' ' AND GV9_SIT = '2' " //WITH (NOLOCK)
        cQuery += " INNER JOIN "+RetSQLName("GUA") + " AS GUA ON GV8_NRREDS = GUA_NRREG AND GUA.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
        cQuery += " INNER JOIN "+RetSQLName("GV6") + " AS GV6 ON GV6_CDEMIT = GV8_CDEMIT AND GV8_NRTAB = GV6_NRTAB AND GV8_NRNEG = GV6_NRNEG AND GV8_NRROTA = GV6_NRROTA AND GV6.D_E_L_E_T_ = ' ' AND GVA_NRTAB = GV6_NRTAB AND " //WITH (NOLOCK)
        cQuery += " GV6_CDFXTV = ( SELECT MAX(GV6_CDFXTV) FROM "+RetSQLName("GV6") + " AS GV6 WHERE GV6_CDEMIT = GV8_CDEMIT AND GV8_NRTAB = GV6_NRTAB AND GV8_NRNEG = GV6_NRNEG AND GV8_NRROTA = GV6_NRROTA AND GV6.D_E_L_E_T_ = ' ' ) " //WITH (NOLOCK)
        cQuery += " WHERE A4_FILIAL  = '" + xFilial("SA4") + "' "
        cQuery += " AND (GV8_NRCIOR =  '" + cEstOri + cCidOri + "' OR GV8_TPORIG = '0')"
        cQuery += " AND GUA_NRCID =  '" + cCodEst + cCidade + "' "
        cQuery += " AND SA4.D_E_L_E_T_= ' ' "           
        cQuery += " UNION "
        cQuery += " SELECT DISTINCT A4_COD, A4_NOME, GVA_XCONTR , GV6_NRTAB , GV6_QTPRAZ"
        cQuery += " FROM "+RetSQLName("SA4") + " AS SA4 " //WITH (NOLOCK)
        cQuery += " INNER JOIN "+RetSQLName("GU3") + " AS GU3 ON GU3_IDFED = A4_CGC AND A4_CGC <> ' ' AND GU3.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
        cQuery += " INNER JOIN "+RetSQLName("GVA") + " AS GVA ON GU3_CDEMIT = GVA_CDEMIT AND GVA.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
        cQuery += " INNER JOIN "+RetSQLName("GV8") + " AS GV8 ON GU3_CDEMIT = GV8_CDEMIT  AND GV8.D_E_L_E_T_ = ' ' AND GV8_TPDEST = '4' " //WITH (NOLOCK)
        cQuery += " INNER JOIN "+RetSQLName("GV9") + " AS GV9 ON GU3_CDEMIT = GV9_CDEMIT  AND GVA_NRTAB = GV9_NRTAB AND GV8_NRNEG = GV9_NRNEG AND GV9.D_E_L_E_T_ = ' ' AND GV9_SIT = '2' " //WITH (NOLOCK)
        cQuery += " INNER JOIN "+RetSQLName("GV6") + " AS GV6 ON GV6_CDEMIT = GV8_CDEMIT AND GV8_NRTAB = GV6_NRTAB AND GV8_NRNEG = GV6_NRNEG AND GV8_NRROTA = GV6_NRROTA AND GV6.D_E_L_E_T_ = ' ' AND GVA_NRTAB = GV6_NRTAB AND " //WITH (NOLOCK)
        cQuery += " GV6_CDFXTV = ( SELECT MAX(GV6_CDFXTV) FROM "+RetSQLName("GV6") + " AS GV6 WHERE GV6_CDEMIT = GV8_CDEMIT AND GV8_NRTAB = GV6_NRTAB AND GV8_NRNEG = GV6_NRNEG AND GV8_NRROTA = GV6_NRROTA AND GV6.D_E_L_E_T_ = ' ' ) " //WITH (NOLOCK)
        cQuery += " WHERE A4_FILIAL  = '" + xFilial("SA4") + "' "
        cQuery += " AND (GV8_NRCIOR =  '" + cEstOri + cCidOri + "' OR GV8_TPORIG = '0')"
        cQuery += " AND GV8_CDUFDS =  '" + cEst + "' "
        cQuery += " AND SA4.D_E_L_E_T_= ' ' "        
        cQuery += " UNION "
        cQuery += " SELECT DISTINCT A4_COD, A4_NOME, GVA_XCONTR , GV6_NRTAB , GV6_QTPRAZ"
        cQuery += " FROM "+RetSQLName("SA4") + " AS SA4 " //WITH (NOLOCK)
        cQuery += " INNER JOIN "+RetSQLName("GU3") + " AS GU3 ON GU3_IDFED = A4_CGC AND A4_CGC <> ' ' AND GU3.D_E_L_E_T_ = ' ' " //WITH (NOLOCK)
        cQuery += " INNER JOIN "+RetSQLName("GVA") + " AS GVA ON GU3_CDEMIT = GVA_CDEMIT AND GVA.D_E_L_E_T_ = ' '  " //WITH (NOLOCK)
        cQuery += " INNER JOIN "+RetSQLName("GV8") + " AS GV8 ON GU3_CDEMIT = GV8_CDEMIT  AND GV8.D_E_L_E_T_ = ' ' AND GV8_TPDEST = '0' " //WITH (NOLOCK)
        cQuery += " INNER JOIN "+RetSQLName("GV9") + " AS GV9 ON GU3_CDEMIT = GV9_CDEMIT  AND GVA_NRTAB = GV9_NRTAB AND GV8_NRNEG = GV9_NRNEG AND GV9.D_E_L_E_T_ = ' ' AND GV9_SIT = '2' " //WITH (NOLOCK)
        cQuery += " INNER JOIN "+RetSQLName("GV6") + " AS GV6 ON GV6_CDEMIT = GV8_CDEMIT AND GV8_NRTAB = GV6_NRTAB AND GV8_NRNEG = GV6_NRNEG AND GV8_NRROTA = GV6_NRROTA AND GV6.D_E_L_E_T_ = ' ' AND GVA_NRTAB = GV6_NRTAB AND " //WITH (NOLOCK)
        cQuery += " GV6_CDFXTV = ( SELECT MAX(GV6_CDFXTV) FROM "+RetSQLName("GV6") + " AS GV6 WHERE GV6_CDEMIT = GV8_CDEMIT AND GV8_NRTAB = GV6_NRTAB AND GV8_NRNEG = GV6_NRNEG AND GV8_NRROTA = GV6_NRROTA AND GV6.D_E_L_E_T_ = ' ' ) " //WITH (NOLOCK)
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
 
 	bRet := U_FiltroF3(cTitulo,cQuery,nTamCpo,cAlias,cCodigo,cCpoChave,cTitCampo,cMascara,cRetCpo,cRetCpo2,nColuna,2,2)
Return(bRet)



 /*/{Protheus.doc} nomeFunction
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
User Function XGFE()
Local lRet := UPPER(Alltrim(GetEnvServer())) == 'GFE'
Return lRet 

#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

/*/{Protheus.doc} DAXREL04
Demonstrativo de comissões por periodo
@type function
@author Rodolfo
@since 03/06/2019
@version 1.0
/*/
User Function DAXREL04()
	Local cComp      := AnoMes(dDataBase)
	Local oPrint
	Local cNomeArq    := 'DEMONSTRATIVO'+StrTran(DTOC(dDataBase),'/', '-') + "_" + StrTran(Time(),":","")+'.PDF'
	Local cLocal      := GetTempPath()
	Local aParam      := {}
	Local aRet        := {}	

	aAdd(aParam, {1, "Vendedor"   	, CriaVar('E3_VEND',.F.)  ,  ,, 'SA3',, 60, .T.} )
	aAdd(aParam, {1, "Dia Inicial"   	,21  ,  ,, ,, 60, .T.} )
	aAdd(aParam, {1, "Dia Final"   	, 20 ,  ,, ,, 60, .T.} )
    aAdd(aParam, {1, "Data Inicial"   	, dDataBase ,  ,, ,, 60, .T.} )
    aAdd(aParam, {1, "Data Final"   	, dDataBase ,  ,, ,, 60, .T.} )


	
	If ParamBox(aParam,'Parâmetros',aRet)
		oPrint := FWMSPrinter():New(cNomeArq, IMP_PDF, .T., cLocal, .T.,  .F., , ,  .T.,  .T., , .T.)
		oPrint:SetLandScape()
	
		RptStatus({|| lEnd:= ImpRel(oPrint,aRet)},"Imprimindo relatório...")
		//If lEnd
			oPrint:Preview()
		//EndIf	
	Else	
		MsgInfo("Cancelado pelo usuário.")		
	Endif

Return

/*/{Protheus.doc} ImpRel
Gerar relatório de Contribuicoes em Atraso
@type function
@author Rodolfo
@since 03/06/2019
@version 1.0
/*/
Static Function ImpRel(oPrint,aRet)
	Local cAliasQry  := GetNextAlias()
	Local cEmpAnt    := ""
	Local cEmpAtu    := ""
	Local cMes       := ""
	Local cAno       := ""
	Local oFont10    := TFont():New("Arial",9,12,.T.,.F.,5,.T.,5,.T.,.F.)
	Local oFont15    := TFont():New("Arial",14,12,.T.,.F.,5,.T.,5,.T.,.F.)
	Local lRet       := .T.
	Local nControle  := 1
	Local nLinha     := 0
    Local dDtIni     := aRet[4]
    Local dDtFim     := aRet[4]
    Local dDtVazia		:= Stod(' ')
	Private nPagina		:= 1
	Private nTotFat     := 0
	Private nTotRec     := 0
	Private nTotAtr     := 0
	Private nTotCom     := 0
	Private nTotPCom    := 0
	Private nTotCRec     := 0
    Private nTotCAtr     := 0
    Private nTotCARec     := 0
    Private nLinCom    := 0

    Cabecalho(oPrint, cAliasQry,aRet) //Imprime Cabeçalho
    nLinha := 0455
			
    While dDtFim <= aRet[5]
        //obtenho o primeiro periodo
        while Day(dDtIni) <> aRet[2]
            dDtIni++
        EndDo
        dDtFim := dDtIni

        while Day(dDtFim) <> aRet[3]
            dDtFim++
        EndDo  

        BeginSQL Alias cAliasQry
        
            SELECT 	DISTINCT SUM(SE1.E1_VALOR)  AS FAT ,
            ( SELECT SUM(E3_BASE)
                FROM %TABLE:SE3% SE3
                 WHERE
                    SE3.E3_VEND     = %Exp:aRet[1]% AND
                    SE3.E3_EMISSAO  >= %Exp:DTOS(dDtIni)% AND
                    SE3.E3_EMISSAO  <= %Exp:DTOS(dDtFim)% AND
                    SE3.%NotDel%                  
            ) AS RECEBIDO,
            (
                SELECT 	SUM(SE1.E1_VALOR) 				
                FROM %TABLE:SE1% SE1					                  
                WHERE SE1.E1_VEND1     = %Exp:aRet[1]% AND 
                    SE1.E1_EMISSAO  >= %Exp:DTOS(dDtIni)% AND 
                    SE1.E1_EMISSAO  <= %Exp:DTOS(dDtFim)% AND 	
                    SE1.E1_BAIXA    <> ' ' AND
                    SE1.%NotDel%                
                    AND SE1.E1_TIPO NOT IN ('NCC','RA')
            )            
            AS RECEBIDO1,
(
                SELECT 	SUM(SE1.E1_SALDO) 				
                FROM %TABLE:SE1% SE1					             
                WHERE 
                    SE1.E1_VEND1     = %Exp:aRet[1]% AND 
                    SE1.E1_VENCREA  >= %Exp:DTOS(dDtIni)% AND 
                    SE1.E1_VENCREA  <= %Exp:DTOS(dDtFim)% AND
                    SE1.E1_BAIXA    = ' '	AND
                    SE1.%NotDel%                   
                    AND SE1.E1_TIPO NOT IN ('NCC','RA')
            ) AS ATRASO,
                (SELECT SUM(SE1.E1_BASCOM1 * (SE1.E1_COMIS1/100))
                FROM %TABLE:SE1% SE1					            
                WHERE 
                    SE1.E1_VEND1     = %Exp:aRet[1]% AND 
                    SE1.E1_VENCREA  >= %Exp:DTOS(dDtIni)% AND 
                    SE1.E1_VENCREA  <= %Exp:DTOS(dDtFim)% AND
                    SE1.%NotDel%       
                    AND SE1.E1_TIPO NOT IN ('NCC','RA')       
            ) AS COMISSAO,
            (
                SELECT 	SUM(E3_COMIS) 				
                FROM %TABLE:SE3% SE3					            
                WHERE 
                    SE3.E3_VEND     = %Exp:aRet[1]% AND 
                    SE3.E3_EMISSAO  >= %Exp:DTOS(dDtIni)% AND 
                    SE3.E3_EMISSAO  <= %Exp:DTOS(dDtFim)% AND 	
                    SE3.E3_DATA     <> ' ' AND 
                    SE3.%NotDel%                  

            ) AS CRECEB,
            (SELECT SUM(SE1.E1_SALDO * (SE1.E1_COMIS1/100))
                FROM %TABLE:SE1% SE1            
                WHERE
                    SE1.E1_VEND1     = %Exp:aRet[1]% AND
                    SE1.E1_VENCREA  >= %Exp:DTOS(dDtIni)% AND
                    SE1.E1_VENCREA  <= %Exp:DTOS(dDtFim)% AND
                    SE1.E1_BAIXA    = ' ' AND
                    SE1.%NotDel%                  
                    AND SE1.E1_TIPO NOT IN ('NCC','RA')

            ) AS CATRAS,
            (
                SELECT 	SUM(E3_COMIS) 				
                FROM %TABLE:SE3% SE3					
                INNER JOIN  %TABLE:SE1% SE1 ON 			
                    SE1.E1_FILIAL   = %Exp:FWxFilial("SE1")% AND 
                    SE1.E1_PREFIXO  = SE3.E3_PREFIXO AND
                    SE1.E1_NUM      = SE3.E3_NUM  AND
                    SE1.E1_PARCELA  = SE3.E3_PARCELA AND
                    SE1.E1_TIPO     = SE3.E3_TIPO AND
                    SE1.%NotDel%                       
                    AND SE1.E1_TIPO NOT IN ('NCC','RA')
                WHERE 
                    SE3.E3_VEND     = %Exp:aRet[1]% AND 
                    SE3.E3_EMISSAO  >= %Exp:DTOS(dDtIni)% AND 
                    SE3.E3_EMISSAO  <= %Exp:DTOS(dDtFim)% AND 	
                    SE1.E1_BAIXA    = ' '	AND
                    SE1.E1_VENCTO   < %Exp:DTOS(dDataBase)% AND 
                    SE1.E1_PREFIXO  = 'IMP'	 AND
                    SE3.%NotDel%                     
            )
             AS CATRAS1,
            (
                SELECT 	SUM(E3_COMIS) 				
                FROM %TABLE:SE3% SE3					            
                WHERE 
                    SE3.E3_VEND     = %Exp:aRet[1]% AND 
                    SE3.E3_EMISSAO  >= %Exp:DTOS(dDtIni)% AND 
                    SE3.E3_EMISSAO  <= %Exp:DTOS(dDtFim)% AND 	
                    SE3.E3_DATA     = ' ' AND
                    SE3.%NotDel%                  

            ) AS CARECEB	
            FROM %TABLE:SE1% SE1					                  
            WHERE SE1.%NotDel%	AND
                SE1.E1_VEND1     = %Exp:aRet[1]% AND 
                SE1.E1_VENCREA  >= %Exp:DTOS(dDtIni)% AND 
                SE1.E1_VENCREA  <= %Exp:DTOS(dDtFim)%  	
                AND SE1.E1_TIPO NOT IN ('NCC','RA')
        EndSQL
        
        If (cAliasQry)->(EOF())
            MsgInfo("Nenhum registro encontrado")
            lRet:= .F.
            Return
        EndIf
        
        While (cAliasQry)->( ! Eof() )
            nLinha += 50
            If nLinha >= 2200 //Se atingir o tamanho máximo imprime nova folha
                oPrint:EndPage()
                oPrint:StartPage()			
                //Imprime quadro da folha
                oPrint:Line(0100, 0100, 0100, 2900)
                oPrint:Line(2300, 0100, 2300, 2900)
                oPrint:Line(0100, 2900, 2300, 2900)
                oPrint:Line(0100, 0100, 2300, 0100)
						
                nLinha := 0200
                nPagina++
            EndIf	

            oPrint:Say(nLinha, 0150        	+, DTOC(dDtIni) + ' a ' + DTOC(dDtFim)		                            , oFont10 )
            oPrint:Say(nLinha, 0500     	, Transform( (cAliasQry)->FAT ,PesqPict("SF2","F2_VALMERC"))	    , oFont10 )
            oPrint:Say(nLinha, 0850     	, Transform((cAliasQry)->RECEBIDO /*+ (cAliasQry)->RECEBIDO1*/ ,PesqPict("SF2","F2_VALMERC"))		, oFont10 )
            oPrint:Say(nLinha, 1050     	, Transform((cAliasQry)->ATRASO ,PesqPict("SF2","F2_VALMERC"))		    , oFont10 )
            //oPrint:Say(nLinha, 1350     	, Transform((cAliasQry)->COMISSAO ,PesqPict("SF2","F2_VALBRUT"))		, oFont10 )
            oPrint:Say(nLinha, 1400     	, Transform((((cAliasQry)->CRECEB + (cAliasQry)->CARECEB) / (cAliasQry)->RECEBIDO) * 100  ,"@E 999,999.999")		        , oFont10 )
            oPrint:Say(nLinha, 1750     	, Transform((cAliasQry)->CRECEB ,PesqPict("SE3","E3_COMIS"))		    , oFont10 )
            oPrint:Say(nLinha, 2050     	, Transform((cAliasQry)->CATRAS + (cAliasQry)->CATRAS1 ,PesqPict("SE3","E3_COMIS"))		    , oFont10 )
            oPrint:Say(nLinha, 2500     	, Transform((cAliasQry)->CARECEB ,PesqPict("SE3","E3_COMIS"))		    , oFont10 )

            nTotFat   += (cAliasQry)->FAT
            nTotRec   += (cAliasQry)->RECEBIDO 
            nTotAtr   += (cAliasQry)->ATRASO
            nTotCom   += (cAliasQry)->COMISSAO
            //If (cAliasQry)->MEDIA > 0
                nTotPCom  += ((cAliasQry)->COMISSAO / (cAliasQry)->RECEBIDO) * 100
                nLinCom   ++
           // EndIf
            nTotCRec  += (cAliasQry)->CRECEB
            nTotCAtr  += (cAliasQry)->CATRAS + (cAliasQry)->CATRAS1
            nTotCARec += (cAliasQry)->CARECEB + (cAliasQry)->CATRAS1
            nLinha += 50
            (cAliasQry)->(dbSkip())
        EndDo
        dDtIni ++
        dDtFim ++
        (cAliasQry)->(dbClosearea())
    EndDo
    trailer(oPrint,nLinha)
Return lRet

/*/{Protheus.doc} Cabecalho
Efetua a impressão do cabeçalho com os dados da Empresa
@type function
@author Janaina de Jesus
@since 03/06/2019
@version 1.0
@param oPrint, objeto, objeto de impressão
@param cAliasQry, character, tabela ativa
/*/
Static Function Cabecalho(oPrint, cAliasQry,aRet)
	Local oFont10    := TFont():New("Arial"      ,9,12,.T.,.T.,5,.T.,5,.T.,.F.)
	Local oFont15    := TFont():New("Arial"      ,20,12,.T.,.T.,5,.T.,5,.T.,.F.)
	Local oFont10c   := TFont():New("Calibre",9,12,.T.,.T.,5,.T.,5,.T.,.F.)
	Local cNomeEmp   := AllTrim(SM0->M0_NOMECOM)
	Local cEmissao   := OemToAnsi("Impresso em: ") + DtoC( dDataBase) + ' ' + Time() + ' Pagina ' + Alltrim(STR(nPagina))
	
	cCGC:= Transform(cCGC, "@R 99.999.999/9999-99")
	
	oPrint:StartPage()
	//Imprime quadro da folha
	oPrint:Line(0100, 0100, 0100, 2900)
	oPrint:Line(2300, 0100, 2300, 2900)
	oPrint:Line(0100, 2900, 2300, 2900)
	oPrint:Line(0100, 0100, 2300, 0100)
				
	oPrint:Say(0150, 2000, cNomeEmp, oFont10c)
	oPrint:Say(0250, 2000, cEmissao, oFont10c)
	oPrint:Say(0150, 0150, "DEMONSTRATIVO DE COMISSÕES POR PERIODO" , oFont15)
	//oPrint:Line(0420, 0200, 0420, 2300)
	oPrint:Say(0250, 0150, "Periodo Considerado:    " + DTOC(aRet[4]) + ' a ' + DTOC(aRet[5]) , oFont15)
	oPrint:Say(0300, 0150, "Representante:               " + Posicione('SA3',1,xFilial('SA3') + aRet[1],'A3_NOME'), oFont15)

    oPrint:Line(0420, 0100, 0420, 2900)
	
	oPrint:Say(0455, 0150, "Periodo"	        , oFont10)
	oPrint:Say(0455, 0450, "Titulos com venc no periodo" 	, oFont10)
	oPrint:Say(0455, 0850, "Vl Liquidado"	    , oFont10)
    oPrint:Say(0455, 1100, "Vl Atraso"	        , oFont10)
    //oPrint:Say(0455, 1350, "Vl Comissão Sem DSR"  , oFont10)
    oPrint:Say(0455, 1300, "% Medio comissão Sem DSR"	, oFont10)
    oPrint:Say(0455, 1700, "Com. Recebida s/ DSR"	, oFont10)
    oPrint:Say(0455, 2050, "Com. Em Atraso s/ DSR"	, oFont10)
    oPrint:Say(0455, 2450, "Com. A Receber S/ DSR"	, oFont10)
	
Return


Static Function trailer(oPrint,nLinha)
	Local oFont10    := TFont():New("Arial"      ,9,12,.T.,.T.,5,.T.,5,.T.,.F.)
	Local oFont15    := TFont():New("Arial"      ,20,12,.T.,.T.,5,.T.,5,.T.,.F.)
	Local oFont10c   := TFont():New("Calibre",9,12,.T.,.T.,5,.T.,5,.T.,.F.)


	nLinha += 100

	If nLinha >= 2900 //Se atingir o tamanho máximo imprime nova folha
		oPrint:EndPage()
		oPrint:StartPage()			
		//Imprime quadro da folha
        oPrint:Line(0100, 0100, 0100, 2900)
        oPrint:Line(2300, 0100, 2300, 2900)
        oPrint:Line(0100, 2900, 2300, 2900)
        oPrint:Line(0100, 0100, 2300, 0100)
				
		nLinha := 0200
		mPagina
	EndIf	
		
	oPrint:Say(nLinha	 , 150 		, 'TOTAL'		, oFont10 )
    oPrint:Say(nLinha, 0500     	, Transform(nTotFat ,PesqPict("SF2","F2_VALMERC"))	    , oFont10 )
    oPrint:Say(nLinha, 0800     	, Transform(nTotRec ,PesqPict("SF2","F2_VALMERC"))		, oFont10 )
    oPrint:Say(nLinha, 1050     	, Transform(nTotAtr ,PesqPict("SF2","F2_VALMERC"))		    , oFont10 )
  //  oPrint:Say(nLinha, 1350     	, Transform(nTotCom ,PesqPict("SF2","F2_VALBRUT"))		, oFont10 )
    If nLinCom > 0 
   //     oPrint:Say(nLinha, 1750     	, Transform( nTotPCom ,"@E 999,999.999")		        , oFont10 )
    Else
     //   oPrint:Say(nLinha, 1750     	, Transform( 0 ,"@E 999,999.999")		        , oFont10 )
    EndIf
    oPrint:Say(nLinha, 1750     	, Transform(nTotCRec ,PesqPict("SE3","E3_COMIS"))		    , oFont10 )
    oPrint:Say(nLinha, 2050     	, Transform(nTotCAtr ,PesqPict("SE3","E3_COMIS"))		    , oFont10 )
    oPrint:Say(nLinha, 2500     	, Transform(nTotCARec ,PesqPict("SE3","E3_COMIS"))		    , oFont10 )

Return
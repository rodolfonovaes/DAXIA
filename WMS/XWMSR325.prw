#INCLUDE "WMSR325.CH"

//---------------------------------------------------------------------------
/*/{Protheus.doc} WMSR325
Relatorio checagem embarque conferencia 
@author Alexsander Burigo Corrêa
@since 20/08/2012
@version 1.0
/*/
//---------------------------------------------------------------------------
User Function xWMSR325()
Local oReport  // objeto que contem o relatorio
Local aAreaDCW := DCW->( GetArea() )
Local aAreaDCX := DCX->( GetArea() )
Local aAreaDCY := DCY->( GetArea() )
Local aAreaDCZ := DCZ->( GetArea() )
	//  Interface de impressao
	oReport := ReportDef()
	oReport:PrintDialog()

	RestArea( aAreaDCW )
	RestArea( aAreaDCX )
	RestArea( aAreaDCY )
	RestArea( aAreaDCZ )
Return     
//----------------------------------------------------------
// Definições do relatório
//----------------------------------------------------------
Static Function ReportDef()
Local oReport, oSection1, oSection2    
Local cEmbarq := DCW->DCW_EMBARQ
	//-----------------------------------------------------------------------
	// Criacao do componente de impressao
	// TReport():New
	// ExpC1 : Nome do relatorio
	// ExpC2 : Titulo
	// ExpC3 : Pergunte
	// ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao
	// ExpC5 : Descricao
	//-----------------------------------------------------------------------
	oReport:= TReport():New("xWMSR325",'CHECK-OUT '+STR0001,"xWMSR325", {|oReport| ReportPrint(oReport)},STR0001) // CHECK-OUT conferencia
	oReport:HideParamPage()   // Desabilita a impressao da pagina de parametros.
	
	//Verifica os parâmetros selecionados via Pergunte
    Pergunte(oReport:GetParam(),.F.)
	
	oSection1 := TRSection():New(oReport,"",{"DCW"}) 
	oSection1:SetLineStyle()
	oSection1:SetCols(1)
	TRCell():New(oSection1,"DCW_EMBARQ","DCW")
	TRCell():New(oSection1,"DCW_SITEMB","DCW")
	
	oSection2 := TRSection():New(oReport,"",{"DCX"}) 
	TRCell():New(oSection2,"DCX_DOC","DCX")
	TRCell():New(oSection2,"DCX_SERIE","DCX")
	TRCell():New(oSection2,"DCX_FORNEC","DCX")
	TRCell():New(oSection2,"DCX_LOJA","DCX")
		
	oSection3 := TRSection():New(oReport,"",{"DCY","SB1"})
	//TRCell():New(oSection3,"DCY_PRDORI","DCY")
	TRCell():New(oSection3,"DCY_LOCAL","DCY", 'Armazem' ,/*Picture*/, 20  ,/*lPixel*/,  )  
	TRCell():New(oSection3,"DCY_PROD","DCY", 'Prod' ,/*Picture*/, 40  ,/*lPixel*/,  ) 
	TRCell():New(oSection3,"B1_DESC","SB1", 'Descr.' ,/*Picture*/, 100  ,/*lPixel*/,  )  
	TRCell():New(oSection3,"PADEMB"   ,/*Alias*/, 'Pad Embalagem' ,/*Picture*/, 30  ,/*lPixel*/,{|| IIF(SB1->B1_TIPCONV=="M",SB1->B1_PESO*SB1->B1_CONV,SB1->B1_CONV/SB1->B1_PESO)}  )  //"Lote"	
	TRCell():New(oSection3,"D1_LOTECTL","SD1")
	TRCell():New(oSection3,"D1_LOTEFOR","SD1")
	TRCell():New(oSection3,"D1_DFABRIC","SD1", 'Dt Fabr.' ,/*Picture*/, 40  ,/*lPixel*/,  )  
	TRCell():New(oSection3,"D1_DTVALID","SD1", 'Dt Valid' ,/*Picture*/, 40  ,/*lPixel*/,  )  
	//TRCell():New(oSection3,"DCY_SUBLOT","DCY")
	//TRCell():New(oSection3,"LACUNA1"   ,/*Alias*/, STR0003 ,/*Picture*/, 30  ,/*lPixel*/,{|| "______________________________"}  )  //"Lote"	
	//TRCell():New(oSection3,"DCY_QTORIG","DCY")
	//TRCell():New(oSection3,"DCY_QTCONF","DCY")
	//TRCell():New(oSection3,"NQTDIFERE","DCY",STR0002,,,/*lPixel*/,{ || (DCY->DCY_QTCONF - DCY->DCY_QTORIG) }) // Qt. Diferenca
	//TRCell():New(oSection3,"LACUNA2"   ,/*Alias*/, STR0004  ,/*Picture*/, 30 ,/*lPixel*/,{|| "______________________________"}  )  //"Quantidade"
	TRPosition():New(oSection3,"SB1",1,{|| xFilial("SB1")+DCY->DCY_PROD})	                        
                               	                                                                                    
	oSection4 := TRSection():New(oReport,"",{"DCZ","DCD"})
	TRCell():New(oSection4,"DCZ_OPER"    ,"DCZ")
	TRCell():New(oSection4,"DCD_NOMFUN"  ,"DCD")                                                 	
	
	oSection4:BeginQuery()	
	BeginSql Alias 'QRYDCZ'      	
		SELECT DISTINCT DCZ_OPER
		  FROM %table:DCZ% DCZ 
		 WHERE DCZ.DCZ_FILIAL = %xfilial:DCZ% 
		   AND DCZ.DCZ_EMBARQ = %Exp:cEmbarq%
		   AND DCZ.%NotDel%
		 ORDER BY DCZ.DCZ_OPER
	EndSql		                                 				
	oSection4:EndQuery()		                            	
Return(oReport) 
//----------------------------------------------------------
// Impressão do relatório
//----------------------------------------------------------
Static Function ReportPrint(oReport)
Local oSection1  := oReport:Section(1)
Local oSection2  := oReport:Section(2)
Local oSection3  := oReport:Section(3)
Local oSection4  := oReport:Section(4)
Local cDoc		 := ''
Local cSerie	 := ''
Local cFornece	 := ''
Local cLoja	 	 := ''
                        

	oReport:SetMeter(DCW->( LastRec() ))
	// Secção 1
	oSection1:Init()
	oSection1:PrintLine()
	oSection1:Finish()
	// Secção 2	            
	oSection2:Init()
	dbSelectArea('DCX')
	DCX->( dbSetOrder(1))
	DCX->( dbSeek(xFilial('DCX')+DCW->DCW_EMBARQ) )
	While !DCX->( Eof() ) .And. DCX->DCX_FILIAL+DCX->DCX_EMBARQ == xFilial('DCX')+DCW->DCW_EMBARQ
		cDoc	:=	DCX->DCX_DOC
		cSerie	:=	DCX->DCX_SERIE
		cFornece:=	DCX->DCX_FORNEC
		cLoja	:=	DCX->DCX_LOJA
		oSection2:PrintLine()		
		DCX->( dbSkip() )
	EndDo       
	oSection2:Finish()
	// Secção 3	
	oSection3:Init()
	dbSelectArea('DCY')
	DCY->( dbSetOrder(2))
	DCY->( dbSeek(xFilial('DCY')+DCW->DCW_EMBARQ) )
	While !DCY->( Eof() ) .And. DCY->DCY_FILIAL+DCY->DCY_EMBARQ == xFilial('DCY')+DCW->DCW_EMBARQ
		If DCY->DCY_PRDORI == DCY->DCY_PROD
			oSection3:Cell("DCY_LOCAL"):SetValue(DCY->DCY_LOCAL)
			oSection3:Cell("DCY_PROD"):SetValue(DCY->DCY_PROD)
		Else
			oSection3:Cell("DCY_LOCAL"):SetValue(DCY->DCY_LOCAL)
			oSection3:Cell("DCY_PROD"):SetValue(DCY->DCY_PROD)
		EndIf
		SD1->(DbSetOrder(1))
		If SD1->(DBSeek(xFilial('SD1') + cDoc + cSerie + cFornece + cLoja + DCY->DCY_PROD))
			oSection3:Cell("D1_LOTECTL"):SetValue(SD1->D1_LOTECTL)
			oSection3:Cell("D1_LOTEFOR"):SetValue(SD1->D1_LOTEFOR)
			oSection3:Cell("D1_DFABRIC"):SetValue(SD1->D1_DFABRIC)
			oSection3:Cell("D1_DTVALID"):SetValue(SD1->D1_DTVALID)
		EndIf
		oSection3:PrintLine()
		DCY->( dbSkip() )
	EndDo       
	oSection3:Finish()		
	// Secção 4	         	
	oSection4:Init()
	While  !oReport:Cancel() .And. !('QRYDCZ')->( Eof() )
		oSection4:Cell("DCZ_OPER"):SetValue(('QRYDCZ')->DCZ_OPER)	
		Osection4:Cell("DCD_NOMFUN"):SetValue( Posicione("DCD",1,xFilial("DCD")+('QRYDCZ')->DCZ_OPER,"DCD_NOMFUN"))
		oSection4:PrintLine()
		('QRYDCZ')->( dbSkip() )
	EndDo       
	oSection4:Finish()			           
	oReport:IncMeter()
Return

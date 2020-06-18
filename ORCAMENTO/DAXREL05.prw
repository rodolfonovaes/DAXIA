#include "topconn.ch"
#include 'protheus.ch'
#include 'parmtype.ch'


/*/{Protheus.doc} DAXREL05
Relatorio Racional de preço de produto
@author dev
@since 08/06/2017
@version

@type function
/*/


User function DAXREL05()

Local oReport := Nil
Local aParam        := {}
Local aRet          := {}
Local cAliasP       := GetNextAlias()
Local cAliasP2      := GetNextAlias()
Local cPerg         :=   PadR( 'DAXREL05',Len(SX1->X1_GRUPO) )

aAdd(aParam, {1, "De"   , SG1->G1_COD ,  ,, 'SB1',, 60, .F.} )
aAdd(aParam, {1, "Até"   , SG1->G1_COD ,  ,, 'SB1',, 60, .F.} )

If ParamBox(aParam,'Racional',aRet) 
    oReport := ReportDef(SG1->G1_COD,aRet)
    oReport:PrintDialog()      
EndIF
Return

/*/{Protheus.doc} ReportDef
Criação do objeto treport e definição das seções e celulas
@author Rodolfo Novaes
@since 04/08/2016
@version 1.0
/*/

Static Function ReportDef(cCod,aRet)

Local oReport    	:= Nil
Local oSecCabec  	:= Nil
Local oSecMP  	    := Nil
Local oSectEM  	:= Nil
Local oSecGG  	:= Nil
Local oSection5  	:= Nil
Local oSecTot  	:= Nil
Local oSectionPI  	:= Nil

oReport := TReport():New("DAXREL05", "Racional de custo do produto ", , {|oReport| PRINTREPORT(oReport, cCod,aRet)}, "Racional de custo do produto ",.T.)

oReport:SetTotalInLine(.F.)

oSecCabec := TRSection():New(oReport, "Custo do produto", {"QRY"})

TRCell():New(oSecCabec,"COD"			, "QRY","Codigo"			    ,, 50,, )
TRCell():New(oSecCabec,"DESC"		    , "QRY","Descrição"				,, 50,,)
TRCell():New(oSecCabec,"UM"		        , "QRY","Unidade de Medida"	    ,, 50,,)

oSecMP := TRSection():New(oReport, "Materia Prima", {"QRY"})
oSecMP:SetTotalInLine(.F.)

TRCell():New(oSecMP,"COD"			, "QRY","Codigo"			    ,, 50,, )
TRCell():New(oSecMP,"DESC"		    , "QRY","Descrição"			    ,, 50,,)
TRCell():New(oSecMP,"QUANT"		    , "QRY","Quantidade"				    ,, 50,,)
TRCell():New(oSecMP,"PRUNIT"		    , "QRY","Vlr. Unitario"			,, 50,,)
TRCell():New(oSecMP,"VALOR"		    , "QRY","Valor R$"				,, 50,,)
TRFunction():new(oSecMP:Cell("PRUNIT")		,,"SUM",,"Total Unitario",,,.T.,.T.,.F.,,)
TRFunction():new(oSecMP:Cell("VALOR")		,,"SUM",,"Total ",,,.T.,.T.,.F.,,)

oSectEM := TRSection():New(oReport, "Embalagem", {"QRY"})

TRCell():New(oSectEM,"COD"	        , "QRY","Codigo"		        ,, 50,, )
TRCell():New(oSectEM,"DESC"		    , "QRY","Descricao"		        ,, 50,, )
TRCell():New(oSectEM,"QUANT"		    , "QRY","Quantidade"				    ,, 50,,)
TRCell():New(oSectEM,"PRUNIT"		    , "QRY","Vlr. Unitario"		    ,, 50,,)
TRCell():New(oSectEM,"VALOR"		    , "QRY","Valor R$"				,, 50,,)
TRFunction():new(oSectEM:Cell("PRUNIT")		,,"SUM",,"Total Unitario",,,.T.,.T.,.F.,,)
TRFunction():new(oSectEM:Cell("VALOR")		,,"SUM",,"Total ",,,.T.,.T.,.F.,,)
oSectEM:SetTotalInLine(.F.)

oSecGG := TRSection():New(oReport, "Gastos Gerais", {"QRY"})

TRCell():New(oSecGG,"RECURSO"	    , "QRY","Recurso"		        ,, 50,, )
TRCell():New(oSecGG,"CC"			    , "QRY","Centro de Custo"		,, 50,, )
TRCell():New(oSecGG,"QUANT"		    , "QRY","Quantidade"		    ,, 50,,)
TRCell():New(oSecGG,"PRUNIT"		    , "QRY","Vlr. Unitario"		    ,, 50,,)
TRCell():New(oSecGG,"VALOR"		    , "QRY","Valor R$"				,, 50,,)
TRFunction():new(oSecGG:Cell("PRUNIT")		,,"SUM",,"Total Unitario",,,.T.,.T.,.F.,,)
TRFunction():new(oSecGG:Cell("VALOR")		,,"SUM",,"Total ",,,.T.,.T.,.F.,,)
oSecGG:SetTotalInLine(.F.)

oSection5 := TRSection():New(oReport, "Embalagem", {"QRY"})

TRCell():New(oSection5,"COD"	        , "QRY","Codigo"		        ,, 50,, )
TRCell():New(oSection5,"DESC"		    , "QRY","Descricao"		        ,, 50,, )
TRCell():New(oSection5,"QUANT"		    , "QRY","Quantidade"				    ,, 50,,)
TRCell():New(oSection5,"PRUNIT"		    , "QRY","Vlr. Unitario"		    ,, 50,,)
TRCell():New(oSection5,"VALOR"		    , "QRY","Valor R$"				,, 50,,)
TRFunction():new(oSection5:Cell("PRUNIT")		,,"SUM",,"Total Unitario",,,.T.,.T.,.F.,,)
TRFunction():new(oSection5:Cell("VALOR")		,,"SUM",,"Total ",,,.T.,.T.,.F.,,)
oSection5:SetTotalInLine(.F.)


oSectionPI := TRSection():New(oReport, "PI", {"QRY"})

TRCell():New(oSectionPI,"COD"	        , "QRY","Codigo"		        ,, 50,, )
TRCell():New(oSectionPI,"DESC"		    , "QRY","Descricao"		        ,, 50,, )
TRCell():New(oSectionPI,"QUANT"		    , "QRY","Quantidade"				    ,, 50,,)
TRCell():New(oSectionPI,"PRUNIT"		    , "QRY","Vlr. Unitario"		    ,, 50,,)
TRCell():New(oSectionPI,"VALOR"		    , "QRY","Valor R$"				,, 50,,)
TRFunction():new(oSectionPI:Cell("PRUNIT")		,,"SUM",,"Total Unitario",,,.T.,.T.,.F.,,)
TRFunction():new(oSectionPI:Cell("VALOR")		,,"SUM",,"Total ",,,.T.,.T.,.F.,,)
oSectionPI:SetTotalInLine(.F.)


oSecTot := TRSection():New(oReport, "Custo", {"QRY"})

TRCell():New(oSecTot,"VALOR"	        , "QRY","TOTAL"		        ,, 50,, )

oReport:ShowHeader()
oReport:SetTotalInLine(.F.)
Return oReport



/*/{Protheus.doc} PRINTREPORT
@author Rodolfo Novaes
@since 04/08/2016
@version 1.0
/*/
Static Function PRINTREPORT(oReport, cCod,aRet)

Local oSecCabec := oReport:Section(1)
Local oSecMP	:= oReport:Section(2)
Local oSectEM := oReport:Section(3)
Local oSecGG	:= oReport:Section(4)
Local oSection5	:= oReport:Section(5)
Local oSecTot	:= oReport:Section(7)
Local oSecPI	:= oReport:Section(6)
Local nValor    := 0
Local aAux      := {}
Local nI        := 0
Local cAliasQry := GetNextAlias()
Local cQuery    := ''


cQuery := "	SELECT DISTINCT SB1.B1_COD , SBZ.R_E_C_N_O_ AS BZREC,ROW_NUMBER() OVER(ORDER BY BZ_COD) AS QTD " 
cQuery += " FROM " + RetSqlName( "SB1" ) + " SB1 "
cQuery += " INNER JOIN " + RetSqlName( "SBZ" ) + " SBZ "
cQuery += " ON SBZ.BZ_COD = SB1.B1_COD AND SBZ.D_E_L_E_T_ = ' ' AND BZ_FILIAL = '" + xFilial('SBZ') + "' "
cQuery += " WHERE SB1.D_E_L_E_T_ = ' ' AND "
cQuery += "		SB1.B1_FILIAL =  '" +  xFilial('SB1') + "' AND " 
cQuery += "     SB1.B1_COD >=  '" + aRet[1] + "'	AND "	  		
cQuery += "     SB1.B1_COD <=  '" + aRet[2] + "'	AND "	  				  		
cQuery += "     B1_TIPO IN ('PA','PI' )  "	  		
cQuery += "     ORDER BY SB1.B1_COD "

If Select(cAliasQry) > 0
    (cAliasQry)->(DbCloseArea())
EndIf

TcQuery cQuery new Alias ( cAliasQry )
If !(cAliasQry)->(Eof())	
    While !(cAliasQry)->(Eof())	
        cCod := (cAliasQry)->B1_COD
        SB1->(DbsetOrder(1))
        SB1->(DbSeek(xFilial('SB1') + cCod))
        oSecCabec:Init()
        oSecCabec:Cell("COD"):SetValue(cCod)
        oSecCabec:Cell("DESC"):SetValue(SB1->B1_DESC)
        oSecCabec:Cell("UM"):SetValue(SB1->B1_UM)
        oSecCabec:Printline()
        oSecCabec:Finish()

        aAux := U_RetG1(cCod,'MP|ME')
        oSecMP:Init()
        
        For nI := 1 to Len(aAux)
        
            oSecMP:Cell("COD"):SetValue(aAux[nI,1])
            oSecMP:Cell("DESC"):SetValue(aAux[nI,2])
            oSecMP:Cell("QUANT"):SetValue(aAux[nI,3])
            oSecMP:Cell("PRUNIT"):SetValue(aAux[nI,4])
            oSecMP:Cell("VALOR"):SetValue(aAux[nI,5])
            oSecMP:Cell("QUANT"):SetAlign('LEFT')
            oSecMP:Cell("PRUNIT"):SetAlign('LEFT')
            oSecMP:Cell("VALOR"):SetAlign('LEFT')       
            oSecMP:Printline()
            nValor += aAux[nI,5]
        Next
        oSecMP:Finish()


        aAux := U_RetG1(cCod,'PI')
        oSecPI:Init()
        
        For nI := 1 to Len(aAux)
        
            oSecPI:Cell("COD"):SetValue(aAux[nI,1])
            oSecPI:Cell("DESC"):SetValue(aAux[nI,2])
            oSecPI:Cell("QUANT"):SetValue(aAux[nI,3])
            oSecPI:Cell("PRUNIT"):SetValue(aAux[nI,4])
            oSecPI:Cell("VALOR"):SetValue(aAux[nI,5])
            oSecPI:Cell("QUANT"):SetAlign('LEFT')
            oSecPI:Cell("PRUNIT"):SetAlign('LEFT')
            oSecPI:Cell("VALOR"):SetAlign('LEFT')       
            oSecPI:Printline()
            nValor += aAux[nI,5]
        Next
        oSecPI:Finish()

        aAux := U_RetG1(cCod,'EM')
        oSectEM:Init()

        For nI := 1 to Len(aAux)
            
            oSectEM:Cell("COD"):SetValue(aAux[nI,1])
            oSectEM:Cell("DESC"):SetValue(aAux[nI,2])
            oSectEM:Cell("QUANT"):SetValue(aAux[nI,3])
            oSectEM:Cell("PRUNIT"):SetValue(aAux[nI,4])
            oSectEM:Cell("VALOR"):SetValue(aAux[nI,5])
            oSectEM:Cell("QUANT"):SetAlign('LEFT')
            oSectEM:Cell("PRUNIT"):SetAlign('LEFT')
            oSectEM:Cell("VALOR"):SetAlign('LEFT')    
            oSectEM:Printline()
            nValor += aAux[nI,5]
        Next
        oSectEM:Finish()


        //Mao de obra
        oSecGG:Init()
        aAux := RetG2(cCod)
        For nI := 1 to Len(aAux)
            
            oSecGG:Cell("RECURSO"):SetValue(aAux[nI,1])
            oSecGG:Cell("CC"):SetValue(aAux[nI,2])
            oSecGG:Cell("QUANT"):SetValue(aAux[nI,3])
            oSecGG:Cell("PRUNIT"):SetValue(aAux[nI,4])
            oSecGG:Cell("VALOR"):SetValue(aAux[nI,5])
            oSecGG:Cell("QUANT"):SetAlign('LEFT')
            oSecGG:Cell("PRUNIT"):SetAlign('LEFT')
            oSecGG:Cell("VALOR"):SetAlign('LEFT')    
            oSecGG:Printline()
            nValor += aAux[nI,5]
        Next
        oSecGG:Finish()

        aAux := U_RetG1(cCod,'GG|SV')
        oSection5:Init()

        For nI := 1 to Len(aAux)
            
            oSection5:Cell("COD"):SetValue(aAux[nI,1])
            oSection5:Cell("DESC"):SetValue(aAux[nI,2])
            oSection5:Cell("QUANT"):SetValue(aAux[nI,3])
            oSection5:Cell("PRUNIT"):SetValue(aAux[nI,4])
            oSection5:Cell("VALOR"):SetValue(aAux[nI,5])
            oSection5:Cell("QUANT"):SetAlign('LEFT')
            oSection5:Cell("PRUNIT"):SetAlign('LEFT')
            oSection5:Cell("VALOR"):SetAlign('LEFT')
            oSection5:Printline()
            nValor += aAux[nI,5]
        Next
        oSection5:Finish()


        oSecTot:Init()
        oSecTot:Cell("VALOR"):SetValue(nValor)
        oSecTot:Cell("VALOR"):SetAlign('LEFT')
        oSecTot:Printline()

        oSecTot:Finish()

        (cAliasQry)->(DbSkip())
    Enddo
EndIf

Return


//Função recursiva para retornar o valor das arvores dos PI ARVORES SOMOS NOZES
User Function RetG1(cProd,cTipo)
Local aRet      := {}
Local aProds    := {}   
Local nI        := 0
Local nAux      := 0

SG1->(DbSetOrder(1))
If SG1->(DbSeek(xFilial('SG1') + cProd))
    While SG1->(G1_FILIAL + G1_COD) == xFilial('SG1') + cProd
        SBZ->(DbSetOrder(1))
        If SBZ->(DbSeek(xFilial('SBZ') + SG1->G1_COMP)) .And. SBZ->BZ_XTIPO $ cTipo
            If cTipo <> 'PI' // tratamento para não entrar na estrutura do PI
                aadd(aProds,{SG1->G1_COMP,SG1->(RECNO()) })
            EndIf
            Aadd(aRet,{ cTipo + ' ' + SG1->G1_COMP , ;
                        Posicione('SB1',1,xFilial('SB1') + SG1->G1_COMP,'B1_DESC'),;
                        SG1->G1_QUANT,;
                        xMoeda(SBZ->BZ_CUSTD,Val(SBZ->BZ_MCUSTD),1,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2')),;
                        SG1->G1_QUANT * xMoeda(SBZ->BZ_CUSTD,Val(SBZ->BZ_MCUSTD),1,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2'))})
            If IsInCallStack('U_DAXJOB01')
                Reclock('SG1',.F.)
                SG1->G1_XVALOR := SG1->G1_QUANT * xMoeda(SBZ->BZ_CUSTD,Val(SBZ->BZ_MCUSTD),1,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2'))
                Msunlock()
            EndIf                                
        EndIf
        /*   ElseIf Posicione('SB1',1,xFilial('SB1') + SG1->G1_COMP,'B1_TIPO') $ 'PI'
            //aadd(aProds,{SG1->G1_COMP,SG1->(RECNO()) })                
            SBZ->(DbSetOrder(1))
            If SBZ->(DbSeek(xFilial('SBZ') + SG1->G1_COMP))
                Aadd(aRet,{ 'PI' + ' ' + SG1->G1_COMP , ;
                            Posicione('SB1',1,xFilial('SB1') + SG1->G1_COMP,'B1_DESC'),;
                            SG1->G1_QUANT,;
                            xMoeda(SBZ->BZ_CUSTD,Val(SBZ->BZ_MCUSTD),1,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2')),;
                            SG1->G1_QUANT * xMoeda(SBZ->BZ_CUSTD,Val(SBZ->BZ_MCUSTD),1,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2'))})                
                If IsInCallStack('U_DAXJOB01')
                    Reclock('SG1',.F.)
                    SG1->G1_XVALOR := SG1->G1_QUANT * xMoeda(SBZ->BZ_CUSTD,Val(SBZ->BZ_MCUSTD),1,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2'))
                    Msunlock()
                EndIf
            EndIf   */                
        //EndIf
        SG1->(DbSkip())
    Enddo
EndIf

For nI := 1 to Len(aProds)
    aAux := U_RetG1(aProds[nI,1],cTipo)
    For n := 1 to len(aAux)
        aadd(aRet,aAux[n])
    Next
Next

Return aRet


//Função recursiva para retornar o valor das arvores dos PI ARVORES SOMOS NOZES
Static Function RetG2(cProd)
Local aRet      := {}
Local aProds    := {}
Local nI        := 0
Local nAux      := 0

SG1->(DbSetOrder(1))
If SG1->(DbSeek(xFilial('SG1') + cProd))
    While SG1->(G1_FILIAL + G1_COD) == xFilial('SG1') + cProd
        aadd(aProds,{SG1->G1_COMP,SG1->(RECNO()) })
        SG2->(DbSetOrder(1))
        If SG2->(DbSeek(xFilial('SG2') + SG1->G1_COMP))
            If len(cProd) > TAMSX3('G1_COD')[1]
                While SG2->(G1_FILIAL + G1_COD + G1_COMP) == xFilial('SG2') + SG1->G1_COMP
                    SH1->(DbSetOrder(1))
                    IF SH1->(DbSeek(xFilial('SH1') + SG2->G2_RECURSO))
                        Aadd(aRet,{ SG2->G2_DESCRI , ;
                                    Posicione('CTT',1,xFilial('CTT') + SH1->H1_CCUSTO,'CTT_DESC01'),;
                                    SG2->G2_MAOOBRA * SG2->G2_TEMPAD ,;
                                    IIF(SG2->G2_TPOPER == '1' , (SG2->G2_MAOOBRA * SG2->G2_TEMPAD * 0/*SH1->H1_XVLMAO*/) / SG2->G2_LOTEPAD, SG2->G2_MAOOBRA * SG2->G2_TEMPAD * 0/*SH1->H1_XVLMAO*/ ),;//unitario
                                    SG2->G2_MAOOBRA * SG2->G2_TEMPAD * 0/*SH1->H1_XVLMAO*/})
                    EndIf
                    SG2->(DbSkip())
                Enddo
            Else
                While SG2->(G2_FILIAL + G2_PRODUTO) == xFilial('SG2') + SG1->G1_COMP
                    SH1->(DbSetOrder(1))
                    IF SH1->(DbSeek(xFilial('SH1') + SG2->G2_RECURSO))
                        Aadd(aRet,{ SG2->G2_DESCRI , ;
                                    Posicione('CTT',1,xFilial('CTT') + SH1->H1_CCUSTO,'CTT_DESC01'),;
                                    SG2->G2_MAOOBRA * SG2->G2_TEMPAD ,;
                                    IIF(SG2->G2_TPOPER == '1' , (SG2->G2_MAOOBRA * SG2->G2_TEMPAD * 0/*SH1->H1_XVLMAO*/) / SG2->G2_LOTEPAD, SG2->G2_MAOOBRA * SG2->G2_TEMPAD * 0/*SH1->H1_XVLMAO*/ ),;//unitario
                                    SG2->G2_MAOOBRA * SG2->G2_TEMPAD * 0/*SH1->H1_XVLMAO*/})
                    EndIf
                    SG2->(DbSkip())
                Enddo
            EndIf
        EndIf
        SG1->(DbSkip())
    Enddo
EndIf

For nI := 1 to Len(aProds)
    aAux := RetG2(aProds[nI,1])
    For n := 1 to len(aAux)
        aadd(aRet,aAux[n])
    Next
Next

Return aRet
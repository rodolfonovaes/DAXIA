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


User function DAXREL06()

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
EndIf
Return

/*/{Protheus.doc} ReportDef
Criação do objeto treport e definição das seções e celulas
@author Rodolfo Novaes
@since 04/08/2016
@version 1.0
/*/

Static Function ReportDef(cCod,aRet)

Local oReport    	:= Nil
Local oSection1  	:= Nil
Local oSection2  	:= Nil
Local oSection3  	:= Nil
Local oSection4  	:= Nil
Local oSection5  	:= Nil
Local oSection6  	:= Nil

oReport := TReport():New("DAXREL06", "Racional de custo do produto ", , {|oReport| PRINTREPORT(oReport, cCod,aRet)}, "Racional de custo do produto ",.T.)

oReport:SetTotalInLine(.F.)

oSection1 := TRSection():New(oReport, "Custo do produto", {"QRY"})

TRCell():New(oSection1,"COD"			, "QRY","Codigo"			    ,, 50,, )
TRCell():New(oSection1,"DESC"		    , "QRY","Descrição"				,, 50,,)
TRCell():New(oSection1,"UM"		        , "QRY","Unidade de Medida"	    ,, 50,,)

oSection2 := TRSection():New(oReport, "Materia Prima", {"QRY"})
oSection2:SetTotalInLine(.F.)

TRCell():New(oSection2,"COD"			, "QRY","Codigo"			    ,, 50,, )
TRCell():New(oSection2,"DESC"		    , "QRY","Descrição"			    ,, 50,,)
TRCell():New(oSection2,"QUANT"		    , "QRY","Quantidade"				    ,, 50,,)
TRCell():New(oSection2,"PRUNIT"		    , "QRY","Vlr. Unitario"			,, 50,,)
TRCell():New(oSection2,"VALOR"		    , "QRY","Valor R$"				,, 50,,)
TRFunction():new(oSection2:Cell("PRUNIT")		,,"SUM",,"Total Unitario",,,.T.,.T.,.F.,,)
TRFunction():new(oSection2:Cell("VALOR")		,,"SUM",,"Total ",,,.T.,.T.,.F.,,)

oSection3 := TRSection():New(oReport, "Embalagem", {"QRY"})

TRCell():New(oSection3,"COD"	        , "QRY","Codigo"		        ,, 50,, )
TRCell():New(oSection3,"DESC"		    , "QRY","Descricao"		        ,, 50,, )
TRCell():New(oSection3,"QUANT"		    , "QRY","Quantidade"				    ,, 50,,)
TRCell():New(oSection3,"PRUNIT"		    , "QRY","Vlr. Unitario"		    ,, 50,,)
TRCell():New(oSection3,"VALOR"		    , "QRY","Valor R$"				,, 50,,)
TRFunction():new(oSection3:Cell("PRUNIT")		,,"SUM",,"Total Unitario",,,.T.,.T.,.F.,,)
TRFunction():new(oSection3:Cell("VALOR")		,,"SUM",,"Total ",,,.T.,.T.,.F.,,)
oSection3:SetTotalInLine(.F.)

oSection4 := TRSection():New(oReport, "Gastos Gerais", {"QRY"})

TRCell():New(oSection4,"RECURSO"	    , "QRY","Recurso"		        ,, 50,, )
TRCell():New(oSection4,"CC"			    , "QRY","Centro de Custo"		,, 50,, )
TRCell():New(oSection4,"QUANT"		    , "QRY","Quantidade"		    ,, 50,,)
TRCell():New(oSection4,"PRUNIT"		    , "QRY","Vlr. Unitario"		    ,, 50,,)
TRCell():New(oSection4,"VALOR"		    , "QRY","Valor R$"				,, 50,,)
TRFunction():new(oSection4:Cell("PRUNIT")		,,"SUM",,"Total Unitario",,,.T.,.T.,.F.,,)
TRFunction():new(oSection4:Cell("VALOR")		,,"SUM",,"Total ",,,.T.,.T.,.F.,,)
oSection4:SetTotalInLine(.F.)

oSection5 := TRSection():New(oReport, "Embalagem", {"QRY"})

TRCell():New(oSection5,"COD"	        , "QRY","Codigo"		        ,, 50,, )
TRCell():New(oSection5,"DESC"		    , "QRY","Descricao"		        ,, 50,, )
TRCell():New(oSection5,"QUANT"		    , "QRY","Quantidade"				    ,, 50,,)
TRCell():New(oSection5,"PRUNIT"		    , "QRY","Vlr. Unitario"		    ,, 50,,)
TRCell():New(oSection5,"VALOR"		    , "QRY","Valor R$"				,, 50,,)
TRFunction():new(oSection5:Cell("PRUNIT")		,,"SUM",,"Total Unitario",,,.T.,.T.,.F.,,)
TRFunction():new(oSection5:Cell("VALOR")		,,"SUM",,"Total ",,,.T.,.T.,.F.,,)
oSection5:SetTotalInLine(.F.)

oSection6 := TRSection():New(oReport, "Custo", {"QRY"})

TRCell():New(oSection6,"VALOR"	        , "QRY","Valor Total"		        ,, 50,, )



oSection7 := TRSection():New(oReport, "PI", {"QRY"})

TRCell():New(oSection7,"COD"	        , "QRY","Codigo"		        ,, 50,, )
TRCell():New(oSection7,"DESC"		    , "QRY","Descricao"		        ,, 50,, )
TRCell():New(oSection7,"QUANT"		    , "QRY","Quantidade"				    ,, 50,,)
TRCell():New(oSection7,"PRUNIT"		    , "QRY","Vlr. Unitario"		    ,, 50,,)
TRCell():New(oSection7,"VALOR"		    , "QRY","Valor R$"				,, 50,,)
TRFunction():new(oSection7:Cell("PRUNIT")		,,"SUM",,"Total Unitario",,,.T.,.T.,.F.,,)
TRFunction():new(oSection7:Cell("VALOR")		,,"SUM",,"Total ",,,.T.,.T.,.F.,,)
oSection7:SetTotalInLine(.F.)



oReport:ShowHeader()
oReport:SetTotalInLine(.F.)
Return oReport



/*/{Protheus.doc} PRINTREPORT
@author Rodolfo Novaes
@since 04/08/2016
@version 1.0
/*/
Static Function PRINTREPORT(oReport,cCod,aRet)

Local oSection1 := oReport:Section(1)
Local oSection2	:= oReport:Section(2)
Local oSection3 := oReport:Section(3)
Local oSection4	:= oReport:Section(4)
Local oSection5	:= oReport:Section(5)
Local oSection6	:= oReport:Section(6)
Local oSection7	:= oReport:Section(7)
Local nValor    := 0
Local aAux      := {}
Local nI        := 0
Local cAliasQry := GetNextAlias()
Local cAliasQry1 := GetNextAlias()
Local cQuery    := ''
Local cQry1     := ''

cQry1 := "	SELECT DISTINCT SB1.B1_COD , SBZ.R_E_C_N_O_ AS BZREC,ROW_NUMBER() OVER(ORDER BY BZ_COD) AS QTD " 
cQry1 += " FROM " + RetSqlName( "SB1" ) + " SB1 "
cQry1 += " INNER JOIN " + RetSqlName( "SBZ" ) + " SBZ "
cQry1 += " ON SBZ.BZ_COD = SB1.B1_COD AND SBZ.D_E_L_E_T_ = ' ' AND BZ_FILIAL = '" + xFilial('SBZ') + "' "
cQry1 += " WHERE SB1.D_E_L_E_T_ = ' ' AND "
cQry1 += "		SB1.B1_FILIAL =  '" +  xFilial('SB1') + "' AND " 
cQry1 += "     SB1.B1_COD >=  '" + aRet[1] + "'	AND "	  		
cQry1 += "     SB1.B1_COD <=  '" + aRet[2] + "'	AND "	  				  		
cQry1 += "     BZ_XTIPO IN ('PA','PI','BN' )  "	  		
cQry1 += "     ORDER BY SB1.B1_COD "

If Select(cAliasQry1) > 0
    (cAliasQry1)->(DbCloseArea())
EndIf

TcQuery cQry1 new Alias ( cAliasQry1 )
If !(cAliasQry1)->(Eof())	
    While!(cAliasQry1)->(Eof())	
        cCod := (cAliasQry1)->B1_COD
        SB1->(DbsetOrder(1))
        SB1->(DbSeek(xFilial('SB1') + cCod))
        oSection1:Init()
        oSection1:Cell("COD"):SetValue(cCod)
        oSection1:Cell("DESC"):SetValue(SB1->B1_DESC)
        oSection1:Cell("UM"):SetValue(SB1->B1_UM)
        oSection1:Printline()
        oSection1:Finish()

        //MP ME
        cQuery := RetQry(cCod,"('MP','ME','PA','BN')")

        If Select(cAliasQry) > 0
            (cAliasQry)->(DbCloseArea())
        EndIf
        aAux := {}
        TcQuery cQuery new Alias ( cAliasQry )
        If !(cAliasQry)->(Eof())	
            While !(cAliasQry)->(Eof())	
                aadd(aAux,{(cAliasQry)->G1_COMP,;
                (cAliasQry)->B1_DESC,;
                (cAliasQry)->G1_QUANT,;
                xMoeda((cAliasQry)->BZ_CUSTD,Val((cAliasQry)->BZ_MCUSTD),1,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2')),;
                (cAliasQry)->G1_QUANT  * xMoeda((cAliasQry)->BZ_CUSTD,Val((cAliasQry)->BZ_MCUSTD),1,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2'));
                })
                (cAliasQry)->(DbSkip())
            EndDo
            (cAliasQry)->(DbCloseArea())
            
            oSection2:Init()
            For nI := 1 to Len(aAux)
            
                oSection2:Cell("COD"):SetValue(aAux[nI,1])
                oSection2:Cell("DESC"):SetValue(aAux[nI,2])
                oSection2:Cell("QUANT"):SetValue(aAux[nI,3])
                oSection2:Cell("PRUNIT"):SetValue(aAux[nI,4])
                oSection2:Cell("VALOR"):SetValue(aAux[nI,5])
                oSection2:Cell("QUANT"):SetAlign('LEFT')
                oSection2:Cell("PRUNIT"):SetAlign('LEFT')
                oSection2:Cell("VALOR"):SetAlign('LEFT')       
                oSection2:Printline()
                nValor += aAux[nI,5]
            Next
            oSection2:Finish()
        EndIf


        //PI
        cQuery := RetQry(cCod,"('PI')")
        aAux := {}
        If Select(cAliasQry) > 0
            (cAliasQry)->(DbCloseArea())
        EndIf

        TcQuery cQuery new Alias ( cAliasQry )
        If !(cAliasQry)->(Eof())	
            While !(cAliasQry)->(Eof())	
                aadd(aAux,{(cAliasQry)->G1_COMP,;
                (cAliasQry)->B1_DESC,;
                (cAliasQry)->G1_QUANT,;
                xMoeda((cAliasQry)->BZ_CUSTD,Val((cAliasQry)->BZ_MCUSTD),1,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2')),;
                (cAliasQry)->G1_QUANT  * xMoeda((cAliasQry)->BZ_CUSTD,Val((cAliasQry)->BZ_MCUSTD),1,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2'));
                })
                (cAliasQry)->(DbSkip())
            EndDo
            (cAliasQry)->(DbCloseArea())
            
            oSection7:Init()
            For nI := 1 to Len(aAux)
            
                oSection7:Cell("COD"):SetValue(aAux[nI,1])
                oSection7:Cell("DESC"):SetValue(aAux[nI,2])
                oSection7:Cell("QUANT"):SetValue(aAux[nI,3])
                oSection7:Cell("PRUNIT"):SetValue(aAux[nI,4])
                oSection7:Cell("VALOR"):SetValue(aAux[nI,5])
                oSection7:Cell("QUANT"):SetAlign('LEFT')
                oSection7:Cell("PRUNIT"):SetAlign('LEFT')
                oSection7:Cell("VALOR"):SetAlign('LEFT')       
                oSection7:Printline()
                nValor += aAux[nI,5]
            Next
            oSection7:Finish()
        EndIf

        //Embalagem
        cQuery := RetQry(cCod,"('EM')")
        aAux := {}
        If Select(cAliasQry) > 0
            (cAliasQry)->(DbCloseArea())
        EndIf

        TcQuery cQuery new Alias ( cAliasQry )
        If !(cAliasQry)->(Eof())	
            While !(cAliasQry)->(Eof())	
                aadd(aAux,{(cAliasQry)->G1_COMP,;
                (cAliasQry)->B1_DESC,;
                (cAliasQry)->G1_QUANT,;
                xMoeda((cAliasQry)->BZ_CUSTD,Val((cAliasQry)->BZ_MCUSTD),1,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2')),;
                (cAliasQry)->G1_QUANT  * xMoeda((cAliasQry)->BZ_CUSTD,Val((cAliasQry)->BZ_MCUSTD),1,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2'));
                })
                (cAliasQry)->(DbSkip())
            EndDo
            (cAliasQry)->(DbCloseArea())
            
            oSection3:Init()

            For nI := 1 to Len(aAux)
                
                oSection3:Cell("COD"):SetValue(aAux[nI,1])
                oSection3:Cell("DESC"):SetValue(aAux[nI,2])
                oSection3:Cell("QUANT"):SetValue(aAux[nI,3])
                oSection3:Cell("PRUNIT"):SetValue(aAux[nI,4])
                oSection3:Cell("VALOR"):SetValue(aAux[nI,5])
                oSection3:Cell("QUANT"):SetAlign('LEFT')
                oSection3:Cell("PRUNIT"):SetAlign('LEFT')
                oSection3:Cell("VALOR"):SetAlign('LEFT')    
                oSection3:Printline()
                nValor += aAux[nI,5]
            Next
            oSection3:Finish()
        EndIf

        //Mao de obra
        oSection4:Init()
        aAux := RetG2(cCod)
        For nI := 1 to Len(aAux)
            
            oSection4:Cell("RECURSO"):SetValue(aAux[nI,1])
            oSection4:Cell("CC"):SetValue(aAux[nI,2])
            oSection4:Cell("QUANT"):SetValue(aAux[nI,3])
            oSection4:Cell("PRUNIT"):SetValue(aAux[nI,4])
            oSection4:Cell("VALOR"):SetValue(aAux[nI,5])
            oSection4:Cell("QUANT"):SetAlign('LEFT')
            oSection4:Cell("PRUNIT"):SetAlign('LEFT')
            oSection4:Cell("VALOR"):SetAlign('LEFT')    
            oSection4:Printline()
            nValor += aAux[nI,5]
        Next
        oSection4:Finish()


        //Embalagem
        cQuery := RetQry(cCod,"('GG')")
        aAux := {}
        If Select(cAliasQry) > 0
            (cAliasQry)->(DbCloseArea())
        EndIf

        TcQuery cQuery new Alias ( cAliasQry )
        If !(cAliasQry)->(Eof())	
            While !(cAliasQry)->(Eof())	
                aadd(aAux,{(cAliasQry)->G1_COMP,;
                (cAliasQry)->B1_DESC,;
                (cAliasQry)->G1_QUANT,;
                xMoeda((cAliasQry)->BZ_CUSTD,Val((cAliasQry)->BZ_MCUSTD),1,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2')),;
                (cAliasQry)->G1_QUANT  * xMoeda((cAliasQry)->BZ_CUSTD,Val((cAliasQry)->BZ_MCUSTD),1,dDataBase,TamSx3("C6_PRCVEN")[2],POSICIONE('SM2',1,dDatabase,'M2_MOEDA2'));
                })
                (cAliasQry)->(DbSkip())
            EndDo
            (cAliasQry)->(DbCloseArea())
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
        EndIf

        oSection6:Init()
        oSection6:Cell("VALOR"):SetValue(nValor)
        oSection6:Cell("VALOR"):SetAlign('LEFT')
        oSection6:Printline()

        oSection6:Finish()
        (cAliasQry1)->(DbSkip())
    EndDo
EndIf
Return
/*/{Protheus.doc} RetQry
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
Static Function RetQry(cProd,cTipo)
Local cQuery := ''
cQuery := "	SELECT DISTINCT G1_COD , G1_COMP , G1_QUANT , G1_XVALOR ,B1_DESC , BZ_MCUSTD, BZ_CUSTD" 
cQuery += " FROM " + RetSqlName( "SG1" ) + " SG1 "
cQuery += " INNER JOIN " + RetSqlName( "SBZ" ) + " SBZ "
cQuery += " ON SBZ.BZ_COD = SG1.G1_COMP AND SBZ.D_E_L_E_T_ = ' ' AND BZ_FILIAL = '" + xFilial('SBZ') + "' "
cQuery += " INNER JOIN " + RetSqlName( "SB1" ) + " SB1 "
cQuery += " ON SB1.B1_COD = SG1.G1_COMP AND SB1.D_E_L_E_T_ = ' ' AND B1_FILIAL = '" + xFilial('SB1') + "' "
cQuery += " WHERE SG1.D_E_L_E_T_ = ' ' AND "
cQuery += "		SG1.G1_FILIAL =  '" +  xFilial('SG1') + "' AND " 
cQuery += "     SG1.G1_COD =  '" + cProd + "'	AND "	  		
cQuery += "     SBZ.BZ_XTIPO IN  " + cTipo + "	 "	  				  		  		
cQuery += "     ORDER BY G1_COMP "
Return cQuery



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
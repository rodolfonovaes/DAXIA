#include 'protheus.ch'
#include 'fwprintsetup.ch'
#include 'rptdef.ch'
#include 'danfeetiqueta.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} ImpDfEtq
Impress�o de danfe simplificada - Etiqueta

@param		cUrl			Endere�o do Web Wervice no TSS
            cIdEnt			Entidade do TSS para processamento
			lUsaColab		Totvs Colabora��o ou n�o
/*/
//-------------------------------------------------------------------
user function ImpDfEtq(cUrl, cIdEnt, lUsaColab)
    local lOk        := .F.
    local aArea      := {}
    local aAreaCB5   := {}
    local aAreaSF3   := {}
    local aAreaSA1   := {}
    local aAreaSA2   := {}
    local cNotaIni   := ""
    local cNotaFim   := ""
    local cSerie     := ""
    local dDtIni     := ctod("")
    local dDtFim     := ctod("")
    local nTipoDoc   := 0
    local nTipImp    := 0
    local cLocImp    := ""
    local nTamSerie  := 0
    local lSdoc      := .F.
    local cAliasQry  := ""
    local cWhere     := ""
    local lMv_Logod  := .F.
	local cLogo      := ""
	local cLogoD	 := ""
    local oPrinter   := nil
    local oSetup     := nil
    local nLinha     := 0
    local nColuna    := 0
    local cGrpCompany:= ""
    local cCodEmpGrp := ""
    local cUnitGrp	 := ""
    local cFilGrp	 := ""
    local cDescLogo  := ""
    local oFontTit   := nil
    local oFontInf   := nil
    local aParam     := {}
	local aNotas     := {}
    local cAviso     := ""
	local cErro      := ""
    local nNotas     := 0
    local cProtocolo := ""
    local cDpecProt  := ""
	local cXml       := ""
    local oTotal     := nil
    local cTotNota   := ""
    local cHautNfe   := ""
    local dDautNfe   := ctod("")
    local aNFe       := {}
    local aEmit      := {}
    local aDest      := {}
    local cCgc       := ""
    local cNome      := ""
    local cInscr     := ""
    local cUF        := ""
    local nContDanfe := 0

    default cUrl      := PARAMIXB[1]
    default cIdEnt    := PARAMIXB[2]
    default lUsaColab := PARAMIXB[3]

    private oRetNF   := nil
    private oNFe     := nil

    begin sequence

    aArea := getArea()

    dbSelectArea("CB5")
    aAreaCB5 := CB5->(getArea())

    dbSelectArea("SF3")
    aAreaSF3 := SF3->(getArea())

    dbSelectArea("SA1")
    aAreaSA1 := SA1->(getArea())

    dbSelectArea("SA2")
    aAreaSA2 := SA2->(getArea())

    if !Pergunte("NFDANFETIQ",.T.)
        break
    endif

    cNotaIni := MV_PAR01 // Nota Inicial
    cNotaFim := MV_PAR02 // Nota Final
    cSerie := MV_PAR03 // Serie
    dDtIni := MV_PAR04 // Data de emiss�o Inicial
    dDtFim := MV_PAR05 // Data de emiss�o Final
    nTipoDoc := MV_PAR06 // Tipo de Opera��o (1 - Entrada / 2 - Sa�da)
    nTipImp := MV_PAR07 // Tipo de Impressora (1 - T�rmica / 2 - Normal)
    cLocImp := MV_PAR08 // Impressora 

    // Valida��es para impressoras termicas
    if nTipImp == 1
        if empty(cLocImp)
     		Help(NIL, NIL, STR0001, NIL, STR0002, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0003}) //local de impress�o n�o informado., Informe um local de impress�o cadastrado., Acesse a rotina 'Locais de Impress�o'.
            break
        else
            CB5->(dbSetOrder(1))
            if !CB5->(DbSeek( xFilial("CB5") + padR(cLocImp, GetSX3Cache("CB5_CODIGO", "X3_TAMANHO")) )) .or. !CB5SetImp(cLocImp)
                Help(NIL, NIL, STR0004 + " - " + alltrim(cLocImp) + ".", NIL, STR0002, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0003}) //local de impress�o n�o encontrado, Informe um local de impress�o cadastrado., Acesse a rotina 'Locais de Impress�o'.
                break
            endif
        endif
    endif

    if val(cNotaIni) > val(cNotaFim)
        Help(NIL, NIL, STR0005, NIL, STR0006, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0007}) //Valores de numera��o de documentos inv�lidos., Informe um intervalo v�lido de notas., Verifique as informa��es do intervalo de notas.
        break
    endif

    nTamSerie := GetSX3Cache("F3_SERIE", "X3_TAMANHO")
    lSdoc := nTamSerie == 14
    cSerie := Padr(cSerie, nTamSerie )
    cWhere := "% SF3.F3_SERIE = '"+ cSerie + "' AND SF3.F3_ESPECIE IN ('SPED','NFCE') "

    if lSdoc
        cSerie := Padr(cSerie, GetSX3Cache("F3_SDOC", "X3_TAMANHO") )
        cWhere := "% SF3.F3_SDOC = '"+ cSerie + "' AND SF3.F3_ESPECIE IN ('SPED','NFCE') "
    endif

    if nTipoDoc == 1
        cWhere += " AND SubString(SF3.F3_CFO,1,1) < '5' AND SF3.F3_FORMUL = 'S' "
	elseif nTipoDoc == 2
        cWhere += " AND SubString(SF3.F3_CFO,1,1) >= '5' "
    endif
		
	if !empty(dDtIni) .or. !empty(dDtFim)
		cWhere += " AND (SF3.F3_EMISSAO >= '"+ SubStr(DTOS(dDtIni),1,4) + SubStr(DTOS(dDtIni),5,2) + SubStr(DTOS(dDtIni),7,2) + "' AND SF3.F3_EMISSAO <= '"+ SubStr(DTOS(dDtFim),1,4) + SubStr(DTOS(dDtFim),5,2) + SubStr(DTOS(dDtFim),7,2) + "')"
	endif

	cWhere += " %"
    cAliasQry := getNextAlias()

    BeginSql Alias cAliasQry
        SELECT MIN(SF3.F3_NFISCAL) NOTAINI, MAX(SF3.F3_NFISCAL) NOTAFIM
        FROM
            %Table:SF3% SF3
        WHERE
            SF3.F3_FILIAL = %xFilial:SF3% AND
            SF3.F3_NFISCAL >= %Exp:cNotaIni% AND
            SF3.F3_NFISCAL <= %Exp:cNotaFim% AND
            SF3.F3_DTCANC = %Exp:Space(8)% AND
            %Exp:cWhere% AND
            SF3.D_E_L_E_T_ = ' '
    EndSql

    (cAliasQry)->(dbGoTop())
    cNotaIni := (cAliasQry)->NOTAINI
    cNotaFim := (cAliasQry)->NOTAFIM
    (cAliasQry)->(dbCloseArea())

    if val(cNotaIni) == 0 .or. val(cNotaFim) == 0
        Help(NIL, NIL, STR0008, NIL, STR0006, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0007}) //Documentos n�o encontrados para impress�o do DANFE., Informe um intervalo v�lido de notas., Informe um intervalo v�lido de notas.
        break
    endif

    if nTipImp == 2
	    oPrinter := FWMSPrinter():New("DANFE_ETIQUETA_" + cIdEnt + "_" + Dtos(MSDate())+StrTran(Time(),":",""),,.F.,,.T.,,,,,.F.)
	    oSetup := FWPrintSetup():New(PD_ISTOTVSPRINTER + PD_DISABLEORIENTATION + PD_DISABLEPAPERSIZE + PD_DISABLEPREVIEW + PD_DISABLEMARGIN,"DANFE SIMPLIFICADA")
	    oSetup:SetPropert(PD_PRINTTYPE , 2) //Spool
	    oSetup:SetPropert(PD_ORIENTATION , 2)
	    oSetup:SetPropert(PD_DESTINATION , 1)
	    oSetup:SetPropert(PD_MARGIN , {0,0,0,0})
	    oSetup:SetPropert(PD_PAPERSIZE , 2)
	    if !oSetup:Activate() == PD_OK
            break
        endif

        lMv_Logod  := If(GetNewPar("MV_LOGOD", "N" ) == "S", .T., .F.   )
        if lMv_Logod 
            cGrpCompany	:= alltrim(FWGrpCompany())
            cCodEmpGrp	:= alltrim(FWCodEmp())
            cUnitGrp	:= alltrim(FWUnitBusiness())
            cFilGrp		:= alltrim(FWFilial())

            if !empty(cUnitGrp)
                cDescLogo := cGrpCompany + cCodEmpGrp + cUnitGrp + cFilGrp
            else
                cDescLogo := cEmpAnt + cFilAnt
            endif

            cLogoD := GetSrvProfString("Startpath","") + "DANFE" + cDescLogo + ".BMP"
            if !file(cLogoD)
                cLogoD	:= GetSrvProfString("Startpath","") + "DANFE" + cEmpAnt + ".BMP"
                if !file(cLogoD)
                    lMv_Logod := .F.
                endif
            endif
        endif
        if lMv_Logod
            cLogo := cLogoD
        else
            cLogo := FisxLogo("1")
        endif
		oFontTit := TFont():New( "Arial", , -8, .T.) //Fonte para os titulos
		oFontTit:Bold := .T.						 //Setado negrito
		oFontInf := TFont():New( "Arial", , -8, .T.) //Fonte para as informa��es
		oFontInf:Bold := .F.						 //Setado negrito := .F.
        //oSetup:GetOrientation() // Retorna a orienta��o (Retrato ou Paisagem) do objeto.
        oPrinter:SetLandscape()		//Define a orientacao como paisagem
        oPrinter:setPaperSize(9) 	//Define tipo papel A4
        If oSetup:GetProperty(PD_PRINTTYPE) == IMP_PDF
            oPrinter:nDevice := IMP_PDF
            oPrinter:cPathPDF := if( empty(oSetup:aOptions[PD_VALUETYPE]), SuperGetMV('MV_RELT',,"\SPOOL\") , oSetup:aOptions[PD_VALUETYPE] )
        elseIf oSetup:GetProperty(PD_PRINTTYPE) == IMP_SPOOL
            oPrinter:nDevice := IMP_SPOOL
            fwWriteProfString(GetPrinterSession(),"DEFAULT", oSetup:aOptions[PD_VALUETYPE], .T.)
            oPrinter:cPrinter := oSetup:aOptions[PD_VALUETYPE]
        Endif

    endif

    aParam := {cSerie, cNotaIni, cNotaFim}
	if lUsaColab
		aNotas := colNfeMonProc( aParam, 1,,, @cAviso)
	else
		aNotas := procMonitorDoc(cIdEnt, cUrl, aParam, 1,,, @cAviso)
	endif

    aEmit := array(4)
    aEmit[1] := SM0->M0_NOMECOM
    aEmit[2] := SM0->M0_CGC
    aEmit[3] := SM0->M0_INSC
    aEmit[4] := if(!GetNewPar("MV_SPEDEND",.F.),SM0->M0_ESTCOB,SM0->M0_ESTENT)

    SA1->(dbSetOrder(1))
    SA2->(dbSetOrder(1))
    SF3->(dbSetOrder(5))

    for nNotas := 1 to len(aNotas)

        cXml := aTail(aNotas[nNotas])[2]
        if empty(cXml)
            loop
        endif

        cProtocolo := aNotas[nNotas][4]
        cDpecProt := aTail(aNotas[nNotas])[3]
        fwFreeObj(oRetNF)
        fwFreeObj(oNfe)
        fwFreeObj(oTotal)

        oRetNF := XmlParser(cXml,"_",@cAviso,@cErro)
        if ValAtrib("oRetNF:_NFEPROC") <> "U"
            oNfe := WSAdvValue( oRetNF,"_NFEPROC","string",NIL,NIL,NIL,NIL,NIL)
        else
            oNfe := oRetNF
        endif

        if ValAtrib("oNFe:_NFe:_InfNfe:_Total") == "U"
            loop
        else
            oTotal := oNFe:_NFe:_InfNfe:_Total
        endif

        if (!empty(cProtocolo) .or. !empty(cDpecProt))

            if !SF3->(dbSeek(xFilial("SF3") + aNotas[nNotas][1]))
                loop
            endif

            cTotNota := alltrim(Transform(Val(oTotal:_ICMSTOT:_vNF:TEXT),"@e 9,999,999,999,999.99"))

		    cHautNfe := aTail(aNotas[nNotas])[5]
		    dDautNfe := if( !empty(aTail(aNotas[nNotas])[6]), aTail(aNotas[nNotas])[6], SToD("  /  /  ") )

            aSize(aNFe, 0)
            aSize(aDest, 0)

            aNFe := array(9)
            aNfe[1] := SF3->F3_CHVNFE
            aNfe[2] := cProtocolo
            aNfe[3] := cDpecProt
            aNfe[4] := cLogo
            aNfe[5] := if( SubStr(SF3->F3_CFO,1,1) >= '5', "1", "0" ) // 0 - Entrada / 1 - Sa�da
            aNfe[6] := SF3->F3_NFISCAL
            aNfe[7] := SF3->F3_SERIE
            aNfe[8] := SF3->F3_EMISSAO
            aNfe[9] := cTotNota

            aDest := array(4)
            if ( SubStr(SF3->F3_CFO,1,1) < '5' .and. SF3->F3_TIPO $ "DB") .or. (SubStr(SF3->F3_CFO,1,1) >= '5' .and. !SF3->F3_TIPO $ "DB")
                if SA1->(dbSeek(xFilial("SA1")+SF3->F3_CLIEFOR+SF3->F3_LOJA))
                    cCgc := SA1->A1_CGC
                    cNome := SA1->A1_NOME
                    cInscr := SA1->A1_INSCR
                    cUF := SA1->A1_EST
                endif
            else // if ( SubStr(SF3->F3_CFO,1,1) < '5' .and. !SF3->F3_TIPO $ "DB") .or. (SubStr(SF3->F3_CFO,1,1) >= '5' .and. SF3->F3_TIPO $ "DB")
                if SA2->(dbSeek(xFilial("SA2")+SF3->F3_CLIEFOR+SF3->F3_LOJA))
                    cCgc := SA2->A2_CGC
                    cNome := SA2->A2_NOME
                    cInscr := SA2->A2_INSCR
                    cUF := SA2->A2_EST
                endif
            endif
            aDest[1] := cNome
            aDest[2] := cCgc
            aDest[3] := cInscr
            aDest[4] := cUF

            nContDanfe += 1
            if nTipImp == 1 // 1 - T�rmica 

                impZebra(aNfe, aEmit, aDest)

            elseif nTipImp == 2 // 2 - Normal

                if nContDanfe == 1
                    oPrinter:StartPage() 		//Define inicio da pagina
                    nLinha := 0
                    nColuna := 0
                elseif nContDanfe == 2 
                    nLinha := 0
                    nColuna := 250
                elseif nContDanfe == 3
                    nLinha := 0
                    nColuna := 500
                elseif nContDanfe == 4
                    nLinha := 250
                    nColuna := 0
                elseif nContDanfe == 5
                    nLinha := 250
                    nColuna := 250
                elseif nContDanfe == 6
                    nLinha := 250
                    nColuna := 500
                    oPrinter:EndPage()
                    nContDanfe := 0
                endif

                DanfeSimp(oPrinter, nLinha, nColuna, oFontTit, oFontInf, aEmit, aNfe, aDest)

            endif    
            lOk := .T.

        endif

    next

    if lOk
        if nTipImp == 1 // 1 - T�rmica 
            MSCBCLOSEPRINTER()
        elseif nTipImp == 2 // 2 - Normal
            if nContDanfe <> 6
                oPrinter:EndPage()
            endif
            oPrinter:Print()
        endif
    endif

    end sequence

    fwFreeObj(oPrinter)
    //fwFreeObj(oSetup)
    fwFreeObj(oFontTit)
    fwFreeObj(oFontInf)
    restArea(aAreaSA2)
    restArea(aAreaSA1)
    restArea(aAreaSF3)
    restArea(aAreaCB5)
    restArea(aArea)

return

static Function ValAtrib(atributo)
Return (type(atributo) )

//-------------------------------------------------------------------
/*/{Protheus.doc} DanfeSimp
Impress�o normal de danfe simplificada - Etiqueta 

/*/
//-------------------------------------------------------------------
static function DanfeSimp(oPrinter, nPosY, nPosX, oFontTit, oFontInf, aEmit, aNfe, aDest)
	local cTitDanfe		:= "DANFE SIMPLIFICADO - ETIQUETA"
	local cChAces		:= "CHAVE DE ACESSO: "
    local cTitProt		:= "PROTOCOLO DE AUTORIZACAO: "
    local cTitPrtEPEC	:= "PROTOCOLO DE AUTORIZACAO EPEC: "
	local cTitNome		:= "NOME/RAZAO SOCIAL: "
	local cCpf			:= "CPF: "
	local cCnpj 		:= "CNPJ: "
	local cIETxt		:= "IE: "
	local cUFTxt		:= "UF: "
    local cSerieTxt		:= "S�RIE: "
	local cNumTxt		:= "N�: "
    local cDtEmi		:= "DATA EMISS�O:"
	local cTipOp		:= "TIPO DE OPERA��O: "
	local cEntTxt		:= "0 - Entrada "
	local cSaiTxt		:= "1 - Saida"
    local cDestTxt		:= "DESTINATARIO: "
	local cValTotTxt	:= "VALOR TOTAL DA NOTA FISCAL: "
    local cValor 		:= "R$: "

    // Box Principal
    // box (eixo Y inicio, eixo X inicio, eixo y fim, eixo x fim)
    oPrinter:Box( 30 + nPosY, 30 + nPosX, 270 + nPosY, 270 + nPosX, "-6") // box (eixo Y inicio, eixo X inicio, eixo y fim, eixo x fim)

    // Box T�tulo
    oPrinter:Box( 30 + nPosY, 30 + nPosX, 50 + nPosY, 270 + nPosX, "-4")
    oPrinter:Say( 45 + nPosY, 80 + nPosX, cTitDanfe, oFontTit) //say (y,x)

    // Box Chave de acesso
    oPrinter:Box( 50 + nPosY, 30 + nPosX, 120 + nPosY, 270 + nPosX, "-4")
    oPrinter:Say( 65 + nPosY, 35 + nPosX, cChAces, oFontTit)
    oPrinter:Say( 110 + nPosY, 50 + nPosX, Transform(aNfe[1],"@R 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999"), oFontInf)
    oPrinter:Code128c( 100 + nPosY, 40 + nPosX, aNfe[1], 30)

    // Box Protocolo de Autorizacao
    oPrinter:Box( 120 + nPosY, 30 + nPosX, 135 + nPosY, 270 + nPosX, "-4")
    if !empty(aNfe[2])
        oPrinter:Say( 130 + nPosY, 50 + nPosX, cTitProt, oFontTit)
        oPrinter:Say( 130 + nPosY, 180 + nPosX, aNfe[2], oFontInf)
    else
        oPrinter:Say( 130 + nPosY, 50 + nPosX, cTitPrtEPEC, oFontTit)
        oPrinter:Say( 130 + nPosY, 180 + nPosX, aNfe[3], oFontInf)
    endif

    //Remetente
    oPrinter:SayBitmap( 140 + nPosY, 35 + nPosX, aNfe[4], 25, 25)
    oPrinter:Say( 145 + nPosY, 80 + nPosX, cTitNome, oFontTit)
    if len(aEmit[1]) > 21
        oPrinter:Say( 145 + nPosY, 175 + nPosX, SubStr(aEmit[1],1,20), oFontInf)
        oPrinter:Say( 153 + nPosY, 80 + nPosX, SubStr(aEmit[1],21,59), oFontInf)
    else
        oPrinter:Say( 145 + nPosY, 175 + nPosX, aEmit[1], oFontInf)
    endif
    oPrinter:Say( 161 + nPosY, 80 + nPosX, cIETxt, oFontTit)
    oPrinter:Say( 161 + nPosY, 90 + nPosX, aEmit[3], oFontInf)
    if len(aEmit[2]) == 11
        oPrinter:Say( 161 + nPosY, 175 + nPosX, cCpf, oFontTit)
        oPrinter:Say( 161 + nPosY, 200 + nPosX, Transform(aEmit[2],"@R 999.999.999-99"), oFontInf)
    else
        oPrinter:Say( 161 + nPosY, 175 + nPosX, cCnpj, oFontTit)
        oPrinter:Say( 161 + nPosY, 200 + nPosX, Transform(aEmit[2],"@R 99.999.999/9999-99"), oFontInf)
    endif
    oPrinter:Say( 169 + nPosY, 80 + nPosX, cUFTxt, oFontTit)
    oPrinter:Say( 169 + nPosY, 100 + nPosX, aEmit[4], oFontInf)

    // Box serie
    oPrinter:Box( 175 + nPosY, 30 + nPosX, 210 + nPosY, 100 + nPosX, "-4")
    oPrinter:Say( 185 + nPosY, 38 + nPosX, cSerieTxt, oFontTit)
    oPrinter:Say( 185 + nPosY, 65 + nPosX, aNfe[7], oFontInf)
    oPrinter:Say( 193 + nPosY, 38 + nPosX, cNumTxt, oFontTit)
    oPrinter:Say( 193 + nPosY, 53 + nPosX, aNfe[6], oFontInf)

    // Box Data Emissao
    oPrinter:Box( 175 + nPosY, 100 + nPosX, 210 + nPosY, 180 + nPosX, "-4")
    oPrinter:Say( 185 + nPosY, 110 + nPosX, cDtEmi, oFontTit)
    oPrinter:Say( 193 + nPosY, 120 + nPosX, dtoc(aNfe[8]), oFontInf)

    // Box Tipo da operacao
    oPrinter:Box( 175 + nPosY, 175 + nPosX, 210 + nPosY, 270 + nPosX, "-4")
    oPrinter:Say( 185 + nPosY, 180 + nPosX, cTipOp, oFontTit)
    oPrinter:Say( 185 + nPosY, 262 + nPosX, aNfe[5], oFontInf)
    oPrinter:Say( 193 + nPosY, 200 + nPosX, cEntTxt, oFontInf)
    oPrinter:Say( 201 + nPosY, 200 + nPosX, cSaiTxt, oFontInf)

    // Destinatario
    oPrinter:Box( 210 + nPosY, 30 + nPosX, 220 + nPosY, 270 + nPosX, "-4")
    oPrinter:Say( 218 + nPosY, 120 + nPosX, cDestTxt, oFontTit)
    oPrinter:Say( 228 + nPosY, 35 + nPosX, cTitNome, oFontTit)
    if len(aDest[1]) > 21
        oPrinter:Say( 228 + nPosY, 130 + nPosX, SubStr(aDest[1], 1, 30), oFontInf)
        oPrinter:Say( 236 + nPosY, 35 + nPosX, SubStr(aDest[1], 31, 49), oFontInf)
    else
        oPrinter:Say( 228 + nPosY, 130 + nPosX, aDest[1], oFontInf)
    endif
    oPrinter:Say( 244 + nPosY, 35 + nPosX, cIETxt, oFontTit)
    oPrinter:Say( 244 + nPosY, 45 + nPosX, aDest[3], oFontInf)
    if len(aEmit[2]) == 11
        oPrinter:Say( 244 + nPosY, 175 + nPosX, cCpf, oFontTit)
        oPrinter:Say( 244 + nPosY, 200 + nPosX, Transform(aDest[2], "@R 999.999.999-99"), oFontInf)
    else
        oPrinter:Say( 244 + nPosY, 175 + nPosX, cCnpj, oFontTit)
        oPrinter:Say( 244 + nPosY, 200 + nPosX, Transform(aDest[2], "@R 99.999.999/9999-99"), oFontInf)
    endif
    oPrinter:Say( 252 + nPosY, 35 + nPosX, cUFTxt, oFontTit)
    oPrinter:Say( 252 + nPosY, 55 + nPosX, aDest[4], oFontInf)

    // Box Valor Total
    oPrinter:Box( 255 + nPosY, 30 + nPosX, 270 + nPosY, 270 + nPosX, "-4") // box (inicio, Margem esquerda, fim, largura)
    oPrinter:Say( 265 + nPosY, 35 + nPosX, cValTotTxt , oFontTit)
    oPrinter:Say( 265 + nPosY, 190 + nPosX, cValor + aNfe[9], oFontInf)

return

//-------------------------------------------------------------------
/*/{Protheus.doc} impZebra
Impress�o de danfe simplificada - Etiqueta para impressora Zebra

@param		aNfe		Dados da Nota
            aEmit		Dados do Emitente da Nota
			aDest		Dados do Destinat�rio da Nota

/*/ 
//-------------------------------------------------------------------
static function impZebra(aNFe, aEmit, aDest)

    local cFontMaior := "016,013" //Fonte maior - t�tulos dos campos obrigat�rios do DANFE ("altura da fonte, largura da fonte")
    local cFontMenor := "015,008" //Fonte menor - campos vari�veis do DANFE ("altura da fonte, largura da fonte")

    local lProtEPEC  := .F.
    local lNomeEmit  := .F.
    local lNomeDest  := .F.

    local nNome      := 1
    local nCNPJ      := 2
    local nIE        := 3
    local nUF        := 4
    local nChave     := 1
    local nProtocolo := 2
    local nProt_EPEC := 3
    local nOperacao  := 5
    local nNumero    := 6
    local nSerie     := 7
    local nData      := 8
    local nValor     := 9
    local nTamEmit   := len( allTrim( aEmit[nNome] ) ) //Quantidade de caracteres da raz�o social do emitente
    local nTamDest   := len( allTrim( aDest[nNome] ) ) //Quantidade de caracteres da raz�o social do destinat�rio
    local nMaxNome   := 34 //Quantidade de caracteres m�xima da primeira linha da raz�o social

    Default aNFe     := {}
    Default aEmit    := {}
    Default aDest    := {}

    //Inicializa a impress�o
    MSCBBegin(1,6,150)

    //Cria��o do Box
    MSCBBox(02,02,98,148)

    //Cria��o das linhas Horizontais - sentido: de cima para baixo
    MSCBLineH(02, 012, 98)
    MSCBLineH(02, 047, 98)
    MSCBLineH(02, 057, 98)
    MSCBLineH(02, 084, 98)
    MSCBLineH(40, 101, 98)
    MSCBLineH(02, 101, 98)
    MSCBLineH(02, 111, 98)
    MSCBLineH(02, 138, 98)

    //Cria��o das linhas verticais - sentido: da direita para esquerda
    MSCBLineV(32, 84, 101)
    MSCBLineV(64, 84, 101)

    //Imprime o c�digo de barras
    MSCBSayBar(14, 24, aNFe[nChave], "N", "C", 10, .F., .F., .F., "C", 2, 1, .F., .F., "1", .T.)

    lProtEPEC  := !empty( aNFe[nProt_EPEC] ) //Se utilizado evento EPEC para emiss�o da Nota lProtEPEC = .T.
    lEmitJurid := len( aEmit[nCNPJ] ) == 14 //Se emitente pessoa jur�dica lEmitJurid = .T.
    lDestJurid := len( aDest[nCNPJ] ) == 14 //Se destinat�rio pessoa jur�dica lDestJurid = .T.

    //Cria��o dos campos de textos fixos da etiqueta
    MSCBSay(17.5, 06.25, "DANFE SIMPLIFICADO - ETIQUETA", "N", "A", cFontMaior)
    MSCBSay(04  , 15   , "CHAVE DE ACESSO:"             , "N", "A", cFontMaior)

    if !lProtEPEC
        MSCBSay(22.5, 48.75, "PROTOCOLO DE AUTORIZACAO:"     , "N", "A", cFontMaior)
    else
        MSCBSay(16.5, 48.75, "PROTOCOLO DE AUTORIZACAO EPEC:", "N", "A", cFontMaior)
    endIf

    MSCBSay(04, 60, "NOME/RAZAO SOCIAL:", "N", "A", cFontMaior)

    if lEmitJurid
        MSCBSay(04, 66.25 , "CNPJ:", "N", "A", cFontMaior)
    else
        MSCBSay(04, 66.25 , "CPF:", "N", "A", cFontMaior)
    endIf

    MSCBSay(04  , 70    , "IE:"               , "N", "A", cFontMaior)
    MSCBSay(04  , 73.75 , "UF:"               , "N", "A", cFontMaior)
    MSCBSay(04  , 88.75 , "SERIE:"            , "N", "A", cFontMaior)
    MSCBSay(04  , 93.75 , "N_A7:"             , "N", "A", cFontMaior)
    MSCBSay(34  , 88.75 , "DATA EMISSAO:"     , "N", "A", cFontMaior)
    MSCBSay(65.5, 88.75 , "TIPO OPER.:"       , "N", "A", cFontMaior)
    MSCBSay(65.5, 92.5  , "0 - ENTRADA"       , "N", "A", cFontMenor)
    MSCBSay(65.5, 96.25 , "1 - SAIDA"         , "N", "A", cFontMenor)
    MSCBSay(35  , 105.5 , "DESTINATARIO"      , "N", "A", cFontMaior)
    MSCBSay(04  , 113.75, "NOME/RAZAO SOCIAL:", "N", "A", cFontMaior)

    if lDestJurid
        MSCBSay(04, 120, "CNPJ:", "N", "A", cFontMaior)
    else
        MSCBSay(04, 120, "CPF:" , "N", "A", cFontMaior)
    endIf

    MSCBSay(04  , 123.75, "IE:"         , "N", "A", cFontMaior)
    MSCBSay(04  , 127.5 , "UF:"         , "N", "A", cFontMaior)
    MSCBSay(04  , 142.5 , "VALOR TOTAL:", "N", "A", cFontMaior)
    MSCBSay(62.5, 142.5 , "R$"          , "N", "A", cFontMaior)

    lNomeEmit := nTamEmit > nMaxNome //Se quantidade de caracteres da raz�o social do emitente for maior que o permitido para a primeira linha lNomeEmit := T
    lNomeDest := nTamDest > nMaxNome //Se quantidade de caracteres da raz�o social do destinat�rio for maior que o permitido para a primeira linha lNomeDest := T

    //Cria��o dos campos de textos vari�veis da etiqueta
    MSCBSay(09, 39, transform( aNFe[nChave], "@R 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999" ), "N", "A", cFontMenor)

    if !lProtEPEC
        MSCBSay(38.75, 53.75, aNFe[nProtocolo], "N", "A", cFontMenor)
    else
        MSCBSay(38.75, 53.75, aNFe[nProt_EPEC], "N", "A", cFontMenor)
    endIf

    if lNomeEmit
        MSCBSay(44, 60, allTrim( subStr( aEmit[nNome], 1, nMaxNome ) ), "N", "A", cFontMenor)
        MSCBSay(04, 62.5, allTrim( subStr( aEmit[nNome], nMaxNome + 1, nTamEmit ) ), "N", "A", cFontMenor)
    else
        MSCBSay(44, 60, allTrim( aEmit[nNome] ), "N", "A", cFontMenor)
    endIf

    if lEmitJurid
        MSCBSay(15, 66.25, transform( aEmit[nCNPJ], "@R 99.999.999/9999-99" ), "N", "A", cFontMenor) //Emitente pessoa jur�dica
    else
        MSCBSay(15, 66.25, transform( aEmit[nCNPJ], "@R 999.999.999-99" ), "N", "A", cFontMenor) //Emitente pessoa f�sica
    endIf

    MSCBSay(11, 70,    aEmit[nIE], "N", "A", cFontMenor)
    MSCBSay(11, 73.75, aEmit[nUF], "N", "A", cFontMenor)
    MSCBSay(18, 88.75, aNFe[nSerie], "N", "A", cFontMenor)
    MSCBSay(11, 93.75, aNFe[nNumero], "N", "A", cFontMenor)
    MSCBSay(40, 93.75, ajustaData( aNFe[nData] ) , "N", "A", cFontMenor)
    MSCBSay(93, 88.75, aNFe[nOperacao], "N", "A", cFontMenor)

    if lNomeDest
        MSCBSay(44, 113.75, allTrim( subStr( aDest[nNome], 1, nMaxNome ) ), "N", "A", cFontMenor)
        MSCBSay(04, 116.25, allTrim( subStr( aDest[nNome], nMaxNome + 1, nTamDest ) ), "N", "A", cFontMenor)
    else
        MSCBSay(44, 113.75, allTrim( aDest[nNome] ), "N", "A", cFontMenor)
    endIf

    if lDestJurid
        MSCBSay(15, 120, transform( aDest[nCNPJ], "@R 99.999.999/9999-99" ), "N", "A", cFontMenor) //Destinat�rio pessoa jur�dica
    else
        MSCBSay(15, 120, transform( aDest[nCNPJ], "@R 999.999.999-99" ), "N", "A", cFontMenor) //Destinat�rio pessoa f�sica
    endIf

    MSCBSay(11, 123.75, aDest[nIE]  , "N", "A", cFontMenor)
    MSCBSay(11, 127.5 , aDest[nUF]  , "N", "A", cFontMenor)
    MSCBSay(70, 142.5 , aNFe[nValor], "N", "A", cFontMenor)

    //Finaliza a impress�o
    MSCBEND()

return

//-------------------------------------------------------------------
/*/{Protheus.doc} ajustaData
Recebe um dado do tipo data (AAAAMMDD) e devolve uma string no
formato (DD/MM/AAAA)

@param		dData		Dado do tipo data(AAAAMMDD)
@return     cDataForm	String formatada com a data (DD/MM/AAAA)

/*/
//-------------------------------------------------------------------
static function ajustaData( dData )

    local cDia      := ""
    local cMes      := ""
    local cAno      := ""
    local cDataForm := ""

    default dData   := Date()

    cDia := strZero( day( dData ), 2 )
    cMes := strZero( month( dData ), 2 )
    cAno := allTrim( str( year( dData ) ) )

    cDataForm = cDia + "/" + cMes + "/" + cAno

return cDataForm

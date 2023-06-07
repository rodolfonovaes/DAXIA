#Include "RWMake.ch"
#Include "FWBrowse.ch" // Header Browse do MVC
#Include "FWMVCDef.ch" // Header do MVC
#Include "Protheus.ch"
#Define  _ENTER  Chr( 13 ) + Chr( 10 )

User Function FT300GRA()
Local  aArea        := GetArea()
Local  cProcessos   := AllTrim(GetMV("ES_PROCOPO"))            // Processos que disparam a geração da atividade
//Local  nDiasMax     := GetMV("ES_DIASMAX")
Local  cProsp       := M->AD1_PROSPE + M->AD1_LOJPRO 
Local  cCli         := M->AD1_CODCLI + M->AD1_LOJCLI
Local  cNome        := ""
Local  oModel       := FWLoadModel( "CRMA180" )
Local  oModelCRM    := oModel:GetModel( "AOFMASTER" )
Local  cDesc        := ""
Local  cPropr       := ""
Local  cContato     := ""
Local  cNContato    := ""
Local  cTel         := ''
Local  cDDD         := ''
Local  lProsp       := .F.


If (INCLUI .OR. ALTERA) .and. AllTrim(M->AD1_PROVEN) $ cProcessos .and. M->AD1_STAGE == "000002"
    IF Empty(cCli) // Prospect Informado
        cCodVend := Posicione("SUS",1,xFilial("SUS") + cProsp,"US_VEND")
        cNomVend := Posicione("SA3",1,xFilial("SA3") + cCodVend,"A3_NREDUZ")
        cVend := cCodVend + " - " + AllTrim(cNomVend)
    else           // Cliente Informado
        cCodVend := Posicione("SA1",1,xFilial("SA1") + cCli,"A1_VEND")
        cNomVend := Posicione("SA3",1,xFilial("SA3") + cCodVend,"A3_NREDUZ")
        cVend := cCodVend + " - " + AllTrim(cNomVend)
    ENDIF

    If MsgYesNo("Será gerada uma atividade para o vendedor " + cVend + ". Confirma?")
        oModel:SetOperation( 3 ) // 3, de Insercao
        oModel:Activate()
        cDesc  := "*** Gerado Automaticamente através da oportunidade " + M->AD1_NROPOR + _ENTER + Descri()
        cPropr := cVend // Posicione("SUS",1,xFilial("SUS") + cProsp,"US_VEND")
        cContato := ""
        cTel    := ''
        IF Empty(cCli) // Prospect Informado
            lProsp := .T.
            SUS->(DbSetOrder(1))
            SUS->(DbSeek(xFilial('SUS') + cProsp))
            cNome := SUS->US_NOME
            AC8->(DbSetOrder(2))
            If AC8->(DbSeek(xFilial('AC8') + 'SUS' + xFilial('SUS') + SUS->(US_COD + US_LOJA)))
                SU5->(DbSetOrder(1))
                If SU5->(DbSeek(xFilial('SU5') + AC8->AC8_CODCON))
                    If SU5->U5_XPADRAO == 'S'
                    cContato := AC8->AC8_CODCON
                    cNContato:= SU5->U5_CONTAT
                    cTel     := SU5->U5_FONE
                    cDDD     := SU5->U5_DDD
                    EndIf
                EndIf
            EndIf
        else
            lProsp := .F.
            SA1->(DbSetOrder(1))
            SA1->(DbSeek(xFilial('SA1') + cCli))
            cNome := SA1->A1_NOME
            AC8->(DbSetOrder(2))
            If AC8->(DbSeek(xFilial('AC8') + 'SA1' + xFilial('SA1') + SA1->(A1_COD + A1_LOJA)))
                SU5->(DbSetOrder(1))
                If SU5->(DbSeek(xFilial('SU5') + AC8->AC8_CODCON))
                    If SU5->U5_XPADRAO == 'S'
                    cContato := AC8->AC8_CODCON
                    cNContato:= SU5->U5_CONTAT
                    cTel     := SU5->U5_FONE
                    cDDD     := SU5->U5_DDD
                    EndIf
                EndIf
            EndIf
        ENDIF            

        oModelCRM:LoadValue( "AOF_FILIAL", xFilial( "AOF" ) )
        oModelCRM:LoadValue( "AOF_TIPO",   "1" )
        oModelCRM:LoadValue( "AOF_ASSUNT", "9" )
        oModelCRM:LoadValue( "AOF_DESCRI", cDesc )
        oModelCRM:LoadValue( "AOF_ENTIDA", Iif(lProsp,"SUS","SA1") )
        oModelCRM:LoadValue( "AOF_CHAVE",  Iif(lProsp,cProsp,cCli) )
        oModelCRM:LoadValue( "AOF_DESCRE",  AllTrim(cNome) )
        oModelCRM:LoadValue( "AOF_DTINIC", M->AD1_DTINI )
        oModelCRM:LoadValue( "AOF_DTFIM",  M->AD1_DTFIM )
        oModelCRM:LoadValue( "AOF_STATUS", "1" )
        oModelCRM:LoadValue( "AOF_PRIORI", STRZERO((4 - Val(M->AD1_PRIOR)),1) )
        oModelCRM:LoadValue( "AOF_PERCEN", "1" )
        oModelCRM:LoadValue( "AOF_CODUSR", cPropr )
        //oModelCRM:LoadValue( "AOF_DESTIN", CRM170Inic( FwFldGet( "AOF_ENTIDA" ), FwFldGet( "AOF_CHAVE" ) ) )     
        oModelCRM:LoadValue( "AOF_DESTIN", AllTrim(cNome) )     
        oModelCRM:LoadValue( "AOF_CODUSR", RetCodUsr() )
        oModelCRM:LoadValue( "AOF_OBS"   , POSICIONE('SA3',1,xFilial('SA3') + cPropr, 'A3_CODUSR' ) )
        oModelCRM:LoadValue( "AOF_XRESP" , POSICIONE('SA3',1,xFilial('SA3') + cPropr, 'A3_NOME' ) )
        oModelCRM:LoadValue( "AOF_DTLEMB", M->AD1_DTINI )
        oModelCRM:LoadValue( "AOF_XCONT" , cContato )
        oModelCRM:LoadValue( "AOF_XNCONT", cNContato )
        oModelCRM:LoadValue( "AOF_XTEL"  , cTel )
        oModelCRM:LoadValue( "AOF_XDDD"  , cDDD )
        oModelCRM:LoadValue( "AOF_XOPO"  , M->AD1_NROPOR )

        FWExecView( OEMToANSI( "Inclusão via Customização devido ao Processo estar contido em " + cProcessos ), "VIEWDEF.CRMA180", MODEL_OPERATION_INSERT,, { || .T. },, /*nPerReducTela*/,,,,, oModel )
    EndIf
ENDIF

RestArea( aArea )
Return( Nil )



Static Function Descri
// Monta a descrição da atitivadade
cDescri := "Item com OPORTUNIDADE de venda identificada neste cliente. Realizar contatos para negociação. A Tarefa só deve ser encerrada após a efetivação da venda e reporte do N° do pedido."
cDescri += _ENTER
dbSelectArea("ADJ")
dbSetOrder(1)
If dbSeek(xFilial("ADJ") + M->AD1_NROPOR)
    cDescri += "Produtos: " + _ENTER
    do While !Eof() .and. ADJ->ADJ_FILIAL == xFilial("ADJ") .and. ADJ->ADJ_NROPOR == M->AD1_NROPOR 
        cDescri += ADJ->ADJ_PROD + " - " + AllTrim(Posicione("SB1",1,xFilial("SB1")+ADJ->ADJ_PROD,"B1_DESC")) + _ENTER
        ADJ->(dbSkip())
    ENDDO
ENDIF

Return(cDescri)

User Function GatStat(cVar)
Local aArea     := GetArea()
Local cRet := ""
Default cVar := M->AOF_STATUS

// Gatilho para atualizar o status da Oportunidade "mãe" de acordo com o status da atividade - campo AOF_STATUS
If M->AOF_STATUS == "2"     //Em andamento
    cRet := "5"             //Em andamento

ElseIf M->AOF_STATUS == "5" // Adiada
    cRet := "3"             // Suspensa

ElseIf M->AOF_STATUS == "3" // Concluida
    cRet := "9"             // Ganha

ElseIf M->AOF_STATUS == "9" // Cancelada
    cRet := "C"             // Cancelada

ElseIf M->AOF_STATUS == "1" // Nao Iniciada
    cRet := "1"             // Aberto   

ENDIF

dbSelectArea("AD1")
dbSetOrder(1)
If dbSeek(xFilial("AD1") + M->AOF_XOPO)
    RecLock("AD1",.F.)
    AD1->AD1_STATUS := cRet
    If cRet == "9"
        AD1->AD1_DTFIM := dDatabase
        AD1->AD1_FCS   := "000002" // FCS = Ganha
    Endif
    If cRet == "C"
        AD1->AD1_FCI   := "000001" // FCI = Cancelado
    Endif
    msUnlock()
ENDIF

RestArea(aArea)
Return(cVar)

User Function GatVend(cCampo)
Local cRet,cEnt,cCod
Local aArea := GetArea()
Local lAchou

If cCampo == "1"    // Prospect
    cCod := M->AD1_PROSPE
    cEnt := "SUS"
    cRet := Posicione("SUS",1,xFilial("SUS") + cCod,"US_VEND")
Else                // Cliente
    cCod := M->AD1_CODCLI
    cEnt := "SA1"
    cRet := Posicione("SA1",1,xFilial("SA1") + cCod,"A1_VEND")
ENDIF
/*
dbSelectArea("AD2")
dbSetOrder(1)
lAchou := dbSeek(xFilial("AD2") + M->AD1_NROPOR + M->AD1_REVISA)

RecLock("AD2",!lAchou)
AD2->AD2_FILIAL := xFilial("AD2")
AD2->AD2_NROPOR := M->AD1_NROPOR 
AD2->AD2_REVISA := M->AD1_REVISA 
AD2->AD2_HISTOR := "1"
AD2->AD2_VEND   := cRet
AD2->AD2_PERC   := 100
msUnlock()
*/

dbSelectArea("AC8")
dbSetOrder(3)
dbSeek(xFilial("AC8") + Space(4) + cEnt + cCod)
do While !EOF() .and. AC8->AC8_FILIAL == xFilial("AC8") .and. AC8->AC8_ENTIDA == cEnt .and. Left(AC8->AC8_CODENT,6) == cCod
    dbSelectArea("SU5")
    dbSetOrder(1)
    dbSeek(xFilial("SU5") + AC8->AC8_CODCON)
    If SU5->U5_XPADRAO == "S" .AND. SU5->U5_ATIVO == "1" .AND. SU5->U5_MSBLQL == "2"
        EXIT 
    ENDIF
    dbSelectArea("AC8")
    dbSkip()
Enddo

dbSelectArea("AD9")
RecLock("AD9",.T.)
AD9->AD9_FILIAL := xFilial("AD9")
AD9->AD9_NROPOR := M->AD1_NROPOR 
AD9->AD9_REVISA := M->AD1_REVISA 
AD9->AD9_HISTOR := "2"
AD9->AD9_CODCON := SU5->U5_CODCONT
/*
AD9->AD9_XDDD   := POSICIONE("AGB",3,"01  SU5"+SU5->U5_CODCONT+SPACE(19)+"1","AGB_DDD")                                                            
AD9->AD9_XFONE  := POSICIONE("AGB",3,"01  SU5"+SU5->U5_CODCONT+SPACE(19)+"1","AGB_TELEFO")                                                         
*/
msUnlock()



RestArea(aArea)
Return (cRet)


User Function FT300VLD()
Local oModel  := FwModelActive()	
Local nOperation := oModel:GetOperation()
Local lRet := .T.

If nOperation == MODEL_OPERATION_INSERT .or. nOperation == MODEL_OPERATION_UPDATE

    If Empty(OMODEL:AALLSUBMODELS[6]:ADATAMODEL[1,1,1,5]) 
        lRet := .F.
        Help("",1,"FT300VLD",,"Preencher pelo menos um produto na aba Produtos" ,1)
    ENDIF

EndIf    


Return(lRet)



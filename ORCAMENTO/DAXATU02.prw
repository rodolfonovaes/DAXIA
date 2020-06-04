#INCLUDE "PROTHEUS.CH"



User Function DAXATU02()

GPShowMemo(SC5->C5_MENNOTA)

Return



Static Function GPShowMemo(cMemo)
Local aParamBox := {}
Local aPergRet	:= {}
/*

/*
aAdd(aParamBox, {1, "Data Coleta"			, SC5->C5_XDTCOL  ,  ,, ,, 50, .F.} )			//1
aAdd(aParamBox, {1, "Obs. Coleta"			, SC5->C5_XOBCOL , "@!" ,, ,, 200, .F.} )		//2
aAdd(aParamBox, {1, "Transportadora"		, SC5->C5_TRANSP , "@!" ,,'SA4' ,, 50, .F.} )	//3
aAdd(aParamBox, {1, "Redespacho"			, SC5->C5_XTREDES , "@!" ,,'SA4' ,, 50, .F.} )	//4
aAdd(aParamBox, {1, "Veiculo"				, SC5->C5_VEICULO , "@!" ,, ,, 50, .F.} )		//5
aAdd(aParamBox, {1, "ObsFaturamento"		, SC5->C5_ZZOUTXT , "@!" ,, ,, 200, .F.} )		//6
aAdd(aParamBox, {1, "Laudo"					, SC5->C5_ZZLAUDO , "@!" ,, ,, 50, .F.} )		//7
aAdd(aParamBox, {1, "ObsLaudo"				, SC5->C5_ZZOBSLA , "@!" ,, ,, 200, .F.} )		//8
aAdd(aParamBox, {1, "Volume "				, SC5->C5_VOLUME1 , "99999" ,, ,, 50, .F.} )	//9
aAdd(aParamBox, {1, "Especie "				, SC5->C5_ESPECI1 , "@X" ,, ,, 50, .F.} )		//10
aAdd(aParamBox, {1, "Peso Liquido"			, SC5->C5_PESOL , "@E 99,999,999.9999" ,, ,, 50, .F.} )	//11
aAdd(aParamBox, {1, "Peso Bruto"			, SC5->C5_PBRUTO , "@E 99,999,999.9999" ,, ,, 50, .F.} )	//12
aAdd(aParamBox, {11	, "Obs DANFE"					, cMemo, ,,.F.} )								//13
aAdd(aParamBox, {1, "Mensagem Padrão"		, SC5->C5_MENPAD , "@!" ,,'SM4' ,, 50, .F.} )	//14
aAdd(aParamBox, {1, "Pedido Vinculado"		, SC5->C5_XPEDVIN , "@!" ,,'SC5VIN' ,, 50, .F.} )//15*/



//If ParamBox(aParamBox, 'Ajuste', aPergRet)
Pergunte('DXOBSPD',.F.)
u_zAtuPerg("DXOBSPD", "MV_PAR01", SC5->C5_XDTCOL)
u_zAtuPerg("DXOBSPD", "MV_PAR02", SC5->C5_XOBCOL)
u_zAtuPerg("DXOBSPD", "MV_PAR03", SC5->C5_TRANSP)
u_zAtuPerg("DXOBSPD", "MV_PAR04", SC5->C5_XTREDES)
u_zAtuPerg("DXOBSPD", "MV_PAR05", SC5->C5_VEICULO)
u_zAtuPerg("DXOBSPD", "MV_PAR06", SC5->C5_ZZOUTXT)
u_zAtuPerg("DXOBSPD", "MV_PAR07", SC5->C5_ZZLAUDO)
u_zAtuPerg("DXOBSPD", "MV_PAR08", SC5->C5_ZZOBSLA)
u_zAtuPerg("DXOBSPD", "MV_PAR09", SC5->C5_VOLUME1)
u_zAtuPerg("DXOBSPD", "MV_PAR10", SC5->C5_ESPECI1)
u_zAtuPerg("DXOBSPD", "MV_PAR11", SC5->C5_PESOL)
u_zAtuPerg("DXOBSPD", "MV_PAR12", SC5->C5_PBRUTO)
u_zAtuPerg("DXOBSPD", "MV_PAR13", cMemo)
u_zAtuPerg("DXOBSPD", "MV_PAR14", SC5->C5_MENPAD)
u_zAtuPerg("DXOBSPD", "MV_PAR15", SC5->C5_XPEDVIN)

If Pergunte('DXOBSPD',.T.)
	UpdObs(aPergRet)
EndIf

Return


Static Function UpdObs(aPergRet)
If MsgYesNo("Confirma a alteração dos campos?", "Observação - Daxia" )
	Reclock("SC5", .F.)
		SC5->C5_XDTCOL		:= MV_PAR01
		SC5->C5_XOBCOL		:= MV_PAR02	
		SC5->C5_TRANSP  	:= MV_PAR03
		SC5->C5_XTREDES		:= MV_PAR04	
		SC5->C5_VEICULO		:= MV_PAR05
		SC5->C5_ZZOUTXT		:= MV_PAR06	
		SC5->C5_ZZLAUDO		:= MV_PAR07	
		SC5->C5_ZZOBSLA		:= MV_PAR08
		SC5->C5_VOLUME1 	:= MV_PAR09
		SC5->C5_ESPECI1 	:= MV_PAR10
		SC5->C5_PESOL   	:= MV_PAR11
		SC5->C5_PBRUTO		:= MV_PAR12
		SC5->C5_MENNOTA 	:= MV_PAR13
        SC5->C5_MENPAD 	    := MV_PAR14
		SC5->C5_XPEDVIN		:= MV_PAR15
	MsUnLock()
EndIf
Return



User Function DXATUSC5()

DXShowMemo(SC5->C5_MENNOTA)

Return

Static Function DXShowMemo(cMemo)
Local aParamBox := {}
Local aPergRet	:= {}

aAdd(aParamBox, {1, "Data Entrega"			, SC6->C6_ENTREG  ,  ,'U_VDTENTR()', ,, 50, .F.} )			//1
aAdd(aParamBox, {1, "Transportadora"		, SC5->C5_TRANSP , "@!" ,,'SA4' ,, 50, .F.} )	//2
aAdd(aParamBox, {1, "Pedido Vinculado"		, SC5->C5_XPEDVIN , "@!" ,,'SC5VIN' ,, 50, .F.} )//3
aAdd(aParamBox, {1, "Mensagem Nota"			, SC5->C5_MENNOTA , "@!" ,,'' ,, 50, .F.} )//4

If ParamBox(aParamBox, 'Ajuste', aPergRet)
	UpdC5(aPergRet)
EndIf

Return


Static Function UpdC5(aPergRet)
If MsgYesNo("Confirma a alteração dos campos?", "Observação - Daxia" )
	Reclock("SC5", .F.)	
		SC5->C5_TRANSP  	:= aPergRet[2]
		SC5->C5_XPEDVIN		:= aPergRet[3]
		SC5->C5_FECENT 		:= aPergRet[1]
		SC5->C5_MENNOTA 	:= aPergRet[4]
	MsUnLock()

	SC6->(DbSetOrder(1))
	If SC6->(DbSeek(xFilial('SC6') + SC5->C5_NUM))
		While SC6->(C6_FILIAL + C6_NUM) == xFilial('SC6') + SC5->C5_NUM
			Reclock('SC6',.F.)
			SC6->C6_ENTREG := aPergRet[1]
			MsUnLock()

            SC9->(DbSetOrder(1))
            If SC9->(DbSeek(xFilial('SC9') + SC6->(C6_NUM  + C6_ITEM ) ))
                While(SC9->(C9_FILIAL+C9_PEDIDO+C9_ITEM) == xFilial('SC9')+SC6->(C6_NUM  + C6_ITEM ) )
                    If SC9->C9_PRODUTO == SC6->C6_PRODUTO
                        Reclock('SC9',.F.)
                        SC9->C9_DATENT := aPergRet[1]
                        MsUnlock()
                        SC9->(DbSkip())
                    EndIf
                EndDo
            EndIf  

			SC6->(DbSkip())

		EndDo
	EndIf
EndIf
Return

/*/{Protheus.doc} VlD
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
User Function VDTENTR()
Local lRet := .T.
Local dData := MV_PAR01

If dData < ddatabase
	lRet := .F.
	Alert('Data Invalida!')
EndIf

Return lRet


/*/{Protheus.doc} zAtuPerg
Função que atualiza o conteúdo de uma pergunta no X1_CNT01 / SXK / Profile
@author Atilio
@since 06/10/2016
@version 1.0
@type function
    @param cPergAux, characters, Código do grupo de Pergunta
    @param cParAux, characters, Código do parâmetro
    @param xConteud, variavel, Conteúdo do parâmetro
    @example u_zAtuPerg("LIBAT2", "MV_PAR01", "000001")
/*/
 
User Function zAtuPerg(cPergAux, cParAux, xConteud)
    Local aArea      := GetArea()
    Local nPosCont   := 8
    Local nPosPar    := 14
    Local nLinEncont := 0
    Local aPergAux   := {}
    Default xConteud := ''
     
    //Se não tiver pergunta, ou não tiver ordem
    If Empty(cPergAux) .Or. Empty(cParAux)
        Return
    EndIf
     
    //Chama a pergunta em memória
    Pergunte(cPergAux, .F., /*cTitle*/, /*lOnlyView*/, /*oDlg*/, /*lUseProf*/, @aPergAux)
     
    //Procura a posição do MV_PAR
    nLinEncont := aScan(aPergAux, {|x| Upper(Alltrim(x[nPosPar])) == Upper(cParAux) })
     
    //Se encontrou o parâmetro
    If nLinEncont > 0
        //Caracter
        If ValType(xConteud) == 'C'
            xConteud := STRTRAN(xConteud,"'"," ")
            &(cParAux+" := '"+xConteud+"'")
         
        //Data
        ElseIf ValType(xConteud) == 'D'
            &(cParAux+" := sToD('"+dToS(xConteud)+"')")
             
        //Numérico ou Lógico
        ElseIf ValType(xConteud) == 'N' .Or. ValType(xConteud) == 'L'
            &(cParAux+" := "+cValToChar(xConteud)+"")
         
        EndIf
         
        //Chama a rotina para salvar os parâmetros
        __SaveParam(cPergAux, aPergAux)
    EndIf
     
    RestArea(aArea)
Return
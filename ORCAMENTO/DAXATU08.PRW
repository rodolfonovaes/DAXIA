/*/{Protheus.doc} DAXATU08
Inicalizador dos campos F2_XBOLETO e F2_XBCO1 
@type  User Function
@author B. Vinicius 
@since 18/12/2019
/*/User Function DAXATU08(nOpc)

Local cRet := ""
Local aAreaSF2 := SF2->(GetArea())
Local aAreaSA1 := SA1->(GetArea())
local cQuery   := ""


SA1->(dbSetOrder(1))
If SA1->( dbSeek(FwxFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA ))
    If nOpc == 1
        cRet := SA1->A1_YBOLETO
    Elseif nOpc == 2
        cRet := SA1->A1_BCO1 
    Endif
Endif

RestArea(aAreaSA1)
RestArea(aAreaSF2)

if nOpc == 3
    cQuery := " SELECT SC5.C5_ZZLAUDO FROM " + RetSqlName( "SC5" ) + " SC5  "
    cQuery += " INNER JOIN " + RetSqlName( "SC6" ) + " SC6  "
    cQuery += " ON SC5.C5_FILIAL=SC6.C6_FILIAL AND SC5.C5_NUM=SC6.C6_NUM AND SC6.D_E_L_E_T_=SC5.D_E_L_E_T_"
    cQuery += " WHERE SC5.D_E_L_E_T_<>'*' AND SC6.C6_NOTA='"+SF2->F2_DOC+"' AND SC6.C6_SERIE='"+SF2->F2_SERIE+"' and SC6.C6_FILIAL='"+SF2->F2_FILIAL+"'" 
	cQuery := ChangeQuery( cQuery ) 
	
	dbUseArea( .t., "TOPCONN", TcGenQry( ,,cQuery ), "xxSC5", .f., .t. )

    IF xxSC5->(!EOF())
        cRet:=xxSC5->C5_ZZLAUDO
    endif    
    xxSC5->( dbCloseArea() ) 
endif    

Return cRet
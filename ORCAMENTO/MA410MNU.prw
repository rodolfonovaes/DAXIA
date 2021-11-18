#Include "PROTHEUS.CH"
#Include "RWMake.CH"
/*======================================================================================+
| Programa............:   MA410MNU.prw                                                  |
| Autores ............:   johnny.osugi@totvspartners.com.br                             |
| Data................:   24/09/2019                                                    |
| Descricao / Objetivo:   Ponto de entrada que realiza a criacao de novas opcoes no bo- |
|                         tao [Outras Acoes] - rotina Pedidos de Vendas/MATA410.        |
| Doc. Origem.........:   MIT044                                                        |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Obs.................:                                                                 |
+======================================================================================*/
User Function MA410MNU()
Local aGrp  := UsrRetGrp()
Local aGrpCom := Separa(Supergetmv('ES_GRPCOM',.T.,'000000'),'|')
Local aGrupoObs := Separa(Supergetmv('ES_GRPOBS',.T.,'000000'),'|')
Local cUsers   := SupergetMV('ES_NIVMARG',.T.,'totvs.rnovaes')
Local lComercial    := .F.
Local lGeral        := .F.
Local n             := 0
Local cUsrRoma := SupergetMV('ES_USRROMA',.T.,'')
Local aGrupos   := UsrRetGrp()

For n := 1 to len(aGrpCom)
    If ascan(aGrp,aGrpCom[n]) > 0
        lComercial := .T.
    EndIf
Next

If lComercial .Or. UPPER(Alltrim(UsrRetName( retcodusr() ))) == 'ADMINISTRADOR'
    aadd(aRotina,{'*Obs. Ped Venda.Comercial','U_DXATUSC5' , 0 , 9,0,NIL})
EndIf

For n := 1 to len(aGrupoObs)
    If ascan(aGrp,aGrupoObs[n]) > 0
        lGeral := .T.
    EndIf
Next

If lGeral .Or. UPPER(Alltrim(UsrRetName( retcodusr() ))) == 'ADMINISTRADOR'
    aadd(aRotina,{'*Observação Ped venda','U_DAXATU02' , 0 , 9,0,NIL})
EndIf

If at(UPPER(Alltrim(UsrRetName( retcodusr() ))),UPPER(cUsers)) > 0 .Or. at(UPPER(Alltrim(UsrRetName( retcodusr() ))),UPPER('totvs.rnovaes')) > 0
    AADD(aRotina, {'*Margem', 'U_PdRent', 0, 0, 0, .F.} )
    AADD(aRotina, {'*Margem Item', 'U_PdRentIt', 0, 0, 0, .F.} )
    SetKey(VK_F7,{||U_PdRent()})
    SetKey(VK_F8,{||U_pdRentIt()})    
EndIf

aAdd( aRotina, { "*Imprimir", "U_DX_RELPV()", 0 , 7, 0, Nil } )
If Autoriza(aGrupos,cUsrRoma)
    aAdd( aRotina, { "*Romaneio", "U_DX_ROMAN()", 0 , 7, 0, Nil } )
EndIf

Return

Static Function Autoriza(aGrupos,cGrupos)
Local lRet := .F.
Local n     := 0

For n := 1 to Len(aGrupos)
    If aGrupos[n] $ cGrupos
        lRet := .T.
        Exit
    EndIf
Next

Return lRet

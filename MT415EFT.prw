#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#include "FWMVCDEF.CH"
#INCLUDE "MATXDEF.CH"
 /*/{Protheus.doc} MT415EFT
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
User Function MT415EFT()
Local aDados    := U_Rentab('3')
Local aDadosIt    := {}
Local nOpc      := PARAMIXB[1]
Local nMargem    := 0
Local nItens     := 0
Local cItem     := '01'
Local lRet       := .T.
Local nFx1Ini    := Val(Separa(GETMV('ES_LIBFX1'),'|')[1])
Local nFx1Fim    := Val(Separa(GETMV('ES_LIBFX1'),'|')[2])
Local nFx2Ini    := Val(Separa(GETMV('ES_LIBFX2'),'|')[1])
Local nFx2Fim    := Val(Separa(GETMV('ES_LIBFX2'),'|')[2])
Local nFx3Ini    := Val(Separa(GETMV('ES_LIBFX3'),'|')[1])
Local nFx3Fim    := Val(Separa(GETMV('ES_LIBFX3'),'|')[2])
Local aArea      := GetArea()
Local nItens    := 0
Local lReclock  := .T.
Private nRecTMP1	:= 0
Private	nSeleciona	:= 0
If nOpc == 1
    TMP1->(DbGoTop())
    While !TMP1->(EOF())
        If !TMP1->CK_FLAG .And. !Val(TMP1->CK_XMOTIVO) > 1
            nSeleciona++

            nRecTMP1 := TMP1->(Recno())

            aDadosIt := U_Rentab('ITATUAL')
            SZL->(DbSetOrder(1))
            If SZL->(DbSeek(xFilial('SZL') + M->CJ_NUM + cItem + TMP1->CK_PRODUTO ))
                lReclock := .F.
            Else
                lReclock := .T.
            EndIF
            Reclock('SZL',lReclock)
            SZL->ZL_FILIAL  := xFilial('SZL')
            SZL->ZL_NUM     := M->CJ_NUM
            SZL->ZL_ITEM     := cItem 
            SZL->ZL_PRODUTO  := TMP1->CK_PRODUTO 
            SZL->ZL_DATA    := dDataBase
            SZL->ZL_TIPO    := '1' //efetivação
            SZL->ZL_RECEITA := aDadosIt[1,1]
            SZL->ZL_IPI     := aDadosIt[2,1]
            SZL->ZL_RECSIPI := aDadosIt[3,1]
            SZL->ZL_CUSTD   := aDadosIt[4,1]
            SZL->ZL_GBRTCX  := aDadosIt[5,1]
            SZL->ZL_PIS     := aDadosIt[6,1]
            SZL->ZL_COFINS  := aDadosIt[7,1]
            SZL->ZL_ICMS    := aDadosIt[8,1]
            SZL->ZL_ICMSP   := aDadosIt[9,1]
            SZL->ZL_DESPFIN := aDadosIt[10,1]
            SZL->ZL_FRETE   := aDadosIt[11,1]
            SZL->ZL_COMIS   := aDadosIt[14,1]
            SZL->ZL_DSR     := aDadosIt[15,1]
            SZL->ZL_RESULT  := aDadosIt[17,1]
            SZL->ZL_PPIS    := aDadosIt[6,2]
            SZL->ZL_PCOFINS := aDadosIt[7,2]
            SZL->ZL_PICMS   := aDadosIt[8,2]
            SZL->ZL_PICMSP  := aDadosIt[9,2]
            SZL->ZL_PCOMIS  := aDadosIt[14,2]
            SZL->ZL_PDESPFI := aDadosIt[10,2]
            SZL->ZL_PALET   := aDadosIt[12,1]
            SZL->ZL_PFRETE  := ROUND(aDadosIt[11,2],6)
            SZL->ZL_PDSR    := aDadosIt[15,2]   
            MsUnlock()
            cItem := Soma1(cItem)     
        EndIf
        TMP1->(DbSkip())
    EndDo
EndIf
If nOpc == 1
    If lRet .And. !SCJ->CJ_XTPOPER $ SUPERGETMV('ES_OPZERPE',.T.,'')
        Reclock('SZC',.T.)
        SZC->ZC_FILIAL  := xFilial('SZC')
        SZC->ZC_NUM     := M->CJ_NUM
        SZC->ZC_DATA    := dDataBase
        SZC->ZC_TIPO    := '1' //efetivação
        SZC->ZC_RECEITA := aDados[1,1]
        SZC->ZC_IPI     := aDados[2,1]
        SZC->ZC_RECSIPI := aDados[3,1]
        SZC->ZC_CUSTD   := aDados[4,1]
        SZC->ZC_GBRTCX  := aDados[5,1]
        SZC->ZC_PIS     := aDados[6,1]
        SZC->ZC_COFINS  := aDados[7,1]
        SZC->ZC_ICMS    := aDados[8,1]
        SZC->ZC_ICMSP   := aDados[9,1]
        SZC->ZC_DESPFIN := aDados[10,1]
        SZC->ZC_FRETE   := aDados[11,1]
        SZC->ZC_COMIS   := aDados[14,1]
        SZC->ZC_DSR     := aDados[15,1]
        SZC->ZC_RESULT  := aDados[17,1]
        SZC->ZC_PPIS    := aDados[6,2]
        SZC->ZC_PCOFINS := aDados[7,2]
        SZC->ZC_PICMS   := aDados[8,2]
        SZC->ZC_PICMSP  := aDados[9,2]
        SZC->ZC_PCOMIS  := aDados[14,2]
        SZC->ZC_PDESPFI := aDados[10,2]
        SZC->ZC_PALET   := aDados[12,1]
        SZC->ZC_PFRETE  := ROUND(aDados[11,2],6)
        SZC->ZC_PDSR    := aDados[15,2]
        SZC->ZC_ITENS   := nItens

        MsUnlock()
    EndIf
EndIf

lRet := iIf( FindFunction( "U_DXVLDORC" ), u_DXVldOrc(), .T. )  // Funcao no programa-fonte DX_PRDORC.prw

RestArea(aArea)
Return lRet
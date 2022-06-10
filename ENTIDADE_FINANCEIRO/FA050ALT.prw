#INCLUDE "PROTHEUS.CH"

/*
  FA040ALT
  Ponto de entrada na alteracao do titulo a pagar validando a obrigatoriedade do centro de custo /item / classe de valor de acordo com a conta contabil

  @author 	Rodolfo Novaes
  @since		12/08/2021
*/

User Function FA050ALT()
Local lRet		    := .T.
local lCc           := .F.
Local lItem         := .F.
Local lClvl         := .F.
Local aArea 	    := GetArea()

IF !lF050Auto .and. SUBSTR(SE2->E2_ORIGEM,1,4) == 'FINA'
    CT1->(DbSetOrder(1))
    If CT1->(DbSeek(xFilial('CT1') + Posicione('SED',1,xFilial('SED') + M->E2_NATUREZ , 'ED_CONTA'))) 
        If CT1->CT1_CCOBRG == '1'
            lCc := .T.
        EndIf
        If CT1->CT1_ITOBRG == '1'
            lItem := .T.
        EndIf
        If CT1->CT1_CLOBRG == '1'
            lClvl := .T.
        EndIf
    EndIf

    If CT1->(DbSeek(xFilial('CT1') + Posicione('SA2',1,xFilial('SA2') + M->E2_FORNECE + M->E2_LOJA , 'A2_CONTA'))) 
        If CT1->CT1_CCOBRG == '1'
            lCc := .T.
        EndIf
        If CT1->CT1_ITOBRG == '1'
            lItem := .T.
        EndIf
        If CT1->CT1_CLOBRG == '1'
            lClvl := .T.
        EndIf
    EndIf

    If Alltrim(M->E2_TIPO) == 'PA'
        If CT1->(DbSeek(xFilial('CT1') + Posicione('SA6',1,xFilial('SA6') + M->E2_PORTADO + M->E2_AGEDEP + M->E2_CONTA , 'A6_CONTA'))) 
            If CT1->CT1_CCOBRG == '1'
                lCc := .T.
            EndIf
            If CT1->CT1_ITOBRG == '1'
                lItem := .T.
            EndIf
            If CT1->CT1_CLOBRG == '1'
                lClvl := .T.
            EndIf
        EndIf        
    EndIf
    

    CT1->(DbSetOrder(1)) //Valido conta do fornecedor
    If CT1->(DbSeek(xFilial('CT1') + M->E2_CREDIT )) 
        If CT1->CT1_CCOBRG == '1'
            lCc := .T.
        EndIf
        If CT1->CT1_ITOBRG == '1'
            lItem := .T.
        EndIf
        If CT1->CT1_CLOBRG == '1'
            lClvl := .T.
        EndIf
    EndIf   

    If (lCc .And. Empty(M->E2_CCUSTO)) 
        lRet := .F.
        Help('', 1, 'FA050ALT01',, 'Centro de custo obrigatorio para essa conta contabil.', 1, 0)
    EndIf

    If    (lItem .And. Empty(M->E2_ITEMCTA)) 
        lRet := .F.
        Help('', 1, 'FA050ALT02',, 'Item obrigatorio para essa conta contabil.', 1, 0)
    EndIf

    If (lClvl .And. Empty(M->E2_CLVL))
        lRet := .F.
        Help('', 1, 'FA050ALT03',, 'Classe de valor obrigatorio para essa conta contabil. ', 1, 0)
    EndIf     

Endif

RestArea(aArea)

Return lRet

#INCLUDE "PROTHEUS.CH"

/*
  FA040ALT
  Ponto de entrada na alteracao do titulo a receber validando a obrigatoriedade do centro de custo /item / classe de valor de acordo com a conta contabil

  @author 	Rodolfo Novaes
  @since		12/08/2021
*/

User Function FA040ALT()
Local lRet		    := .T.
local lCc           := .F.
Local lItem         := .F.
Local lClvl         := .F.
Local aArea 	    := GetArea()

IF !lF040Auto .and. SUBSTR(SE1->E1_ORIGEM,1,4) == 'FINA' .and. ALLTRIM(SE1->E1_ORIGEM) != 'FINA460'
    CT1->(DbSetOrder(1))
    If CT1->(DbSeek(xFilial('CT1') + Posicione('SED',1,xFilial('SED') + M->E1_NATUREZ , 'ED_CONTA'))) 
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

    If CT1->(DbSeek(xFilial('CT1') + Posicione('SA1',1,xFilial('SA1') + M->E1_CLIENTE + M->E1_LOJA , 'A1_CONTA'))) 
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

    If Alltrim(M->E1_TIPO) == 'RA'
        If CT1->(DbSeek(xFilial('CT1') + Posicione('SA6',1,xFilial('SA6') + M->E1_PORTADO + M->E1_AGEDEP + M->E1_CONTA , 'A6_CONTA'))) 
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
    
    If (lCc .And. Empty(M->E1_CCUSTO)) 
        lRet := .F.
        Help('', 1, 'FA040ALT01',, 'Centro de custo obrigatorio para essa conta contabil.', 1, 0)
    EndIf

    If    (lItem .And. Empty(M->E1_ITEMCTA)) 
        lRet := .F.
        Help('', 1, 'FA040ALT02',, 'Item obrigatorio para essa conta contabil.', 1, 0)
    EndIf

    If (lClvl .And. Empty(M->E1_CLVL))
        lRet := .F.
        Help('', 1, 'FA040ALT03',, 'Classe de valor obrigatorio para essa conta contabil. ', 1, 0)
    EndIf     

Endif

RestArea(aArea)

Return lRet

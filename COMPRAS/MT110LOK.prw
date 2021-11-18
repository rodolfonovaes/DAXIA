#Include "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.ch"



//Validação das entidades contabeis na solicitação de compra


User Function MT110LOK()

Local nPosConta     := Ascan(aHeader,{|x| "C1_CONTA"   $ x[2]})
Local nPosCCu       := Ascan(aHeader,{|x| "C1_CC"      $ x[2]})
Local nPosItem      := Ascan(aHeader,{|x| "C1_ITEMCTA" $ x[2]})
Local nPosRat       := Ascan(aHeader,{|x| "C1_RATEIO"  $ x[2]})
Local nPosClvl      := Ascan(aHeader,{|x| "C1_CLVL"  $ x[2]})
Local cCCusto	    := aCols[n][nPosCCu]
Local cRateio	    := aCols[n][nPosRat]
Local cConta        := aCols[n][nPosConta]
Local cClvl         := aCols[n][nPosClvl]
Local cItem         := aCols[n][nPosItem]
Local lRet          := .t.
local lCc           := .F.
Local lItem         := .F.
Local lClvl         := .F.
Local aArea         := GetArea()

If !aCols[n,Len(acols[n])] .And. !l110Auto // Verifica se a linha está deletada
    
    CT1->(DbSetOrder(1))
    If CT1->(DbSeek(xFilial('CT1') + cConta))
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

	If Inclui .or. Altera
				
        If cRateio=="2" 
            If (lCc .And. Empty(cCCusto)) 
                lRet := .F.
                Help('', 1, 'MT110LOK01',, 'Centro de custo obrigatorio para essa conta contabil.', 1, 0)
            EndIf

            If    (lItem .And. Empty(cItem)) 
                lRet := .F.
                Help('', 1, 'MT110LOK02',, 'Item obrigatorio para essa conta contabil.', 1, 0)
            EndIf

            //If (lClvl .And. Empty(cClvl))
              //  lRet := .F.
                //Help('', 1, 'MT110LOK03',, 'Classe de valor obrigatorio para essa conta contabil. ', 1, 0)
            //EndIf    
        EndIf
		
	EndIf
	
EndIf

RestArea(aArea)
Return(lRet)

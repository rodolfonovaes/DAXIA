#include "protheus.ch"
User Function AfterLogin()
Local cId	:= ParamIXB[1]
Local cNome := ParamIXB[2]
Local cUsers    := SupergetMV('ES_USRCSHOM',.T.,'totvs.rnovaes')
Local lChama    := .F.
Local cArquivo  := 'DAXATU01'+DTOS(dDataBase)+'.txt'

If !File(cArquivo) .And. oApp:cModName == 'SIGAEST' .And. cNome $ cUsers
    lChama := .T.
    nHdlSem := Fcreate(cArquivo)
    If nHdlSem < 0
        MsgStop( 'Problemas ao criar o arquivo de semaforo, codigo de erro : ' + Str(Ferror())  )
        Return
    Else
        Fclose(nHdlSem)
    EndIf
EndIf

If lChama
    U_DAXATU01()
EndIf
Return
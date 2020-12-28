#INCLUDE 'PROTHEUS.CH'

#DEFINE NOMEDOARQUIVO			 1 
#DEFINE NTAMPROTOCOLO			 8

/*
{protheus.doc}	DAXJLAU
				JOB que envia os LAUDOS  a cada 10 min
@author			Cícero Odilio Cruz
@since			10/10/2019
@project		Envio de Laudo ao Cliente
@param			aProcess - Preparacao de ambiente via job
*/
User Function DAXJLAU( aProcess )
LOCAL nOpca			 		:= 0
LOCAL aSays					:= {}
LOCAL aButtons				:= {}
LOCAL lExecJob				:= GetRemoteType() == -1	//Execucao por JOB
LOCAL nStart 				:= Seconds()

PRIVATE cEmpProc			:= Iif(aProcess==Nil,CEMPANT,aProcess[1])
PRIVATE cFilProc			:= Iif(aProcess==Nil,CFILANT,aProcess[2])
PRIVATE oProcess			:= NIL
PRIVATE lProcess			:= .T.
PRIVATE nProcessos			:= 3
PRIVATE cLogJob				:= ""

CONOUT( "DAXJLAU01: Iniciando... " + Time() )
FwLogMsg("INFO", /*cTransactionId*/, "DAXJLAU01", FunName(), "", "01", "Iniciando..." , 0, (nStart - Seconds()), {}) 

If  lExecJob

	CONOUT( "DAXJLAU02: Iniciando JOB... " + Time() )
	FwLogMsg("INFO", /*cTransactionId*/, "DAXJLAU02", FunName(), "", "01", "Executando Chamada do Job..." , 0, (nStart - Seconds()), {}) 

	//Abre Empresa inicial
	RpcSetType ( 3 )
	RpcSetEnv( cEmpProc, cFilProc, , , 'QIE' )                           

	LAU2PROC(lExecJob, cEmpProc, cFilProc, cLogJob)
	
	RpcClearEnv()

ELSE

    cLogJob += "DAXJLAU03: Iniciando via TELA... " + Time() + CHR(13)+CHR(10)
	
	AADD(aSays,"Este programa tem por objetivo realizar o envio de e-mail "  )
	AADD(aSays,"com o Laudo ao Cliente." )
	AADD(aButtons, { 1,.T.,{|| nOpca:= 1, FechaBatch() }} )
	AADD(aButtons, { 2,.T.,{|| FechaBatch() }} )
	FormBatch( "Importação: Comissão Loja.", aSays, aButtons )

ENDIF

IF nOpca == 1
	// Sobe nova thread para executar o processo
	CONOUT( "DAXJLAU04: SOBE A THREAD LAU2PROC NO PROCESSO" )
	oProcess := MsNewProcess():New( { ||  LAU2PROC(.T., cEmpProc, cFilProc, cLogJob )  },"LAU2PROC", "Aguarde, processando ...", .F. )
	oProcess:Activate()
ENDIF

RETURN NIL

/*
{protheus.doc}	COMIS2PROC
Inicio do processamento
@author			Cícero Odilio Cruz
@since			10/10/2019
@param			lJob - Processamento por Job?
@project		Busca Notas sem Laudo Enviado
*/
Static Function LAU2PROC( lOnJob, cEmpProc, cFilProc, cLogJob )
LOCAL cTime  := ""+ Time()
LOCAL nStart := Seconds()
//CONOUT("INICIANDO PROCESSO LAU2PROC")

IF lOnJob

	//Abre Empresa
	RpcSetType ( 3 )
	RpcSetEnv( cEmpProc, cFilProc, , , 'EST' )                           

	//CONOUT("DAXJLAU05: Acessando empresa:" + cEmpProc+'/'+cFilProc )
	FwLogMsg("INFO", /*cTransactionId*/, "DAXJLAU05", FunName(), "", "01", "Acessando empresa:" + cEmpProc+'/'+cFilProc , 0, (nStart - Seconds()), {}) 
	
	//CONOUT("DAXJLAU06: Executando função de envio de Laudos...")
	FwLogMsg("INFO", /*cTransactionId*/, "DAXJLAU06", FunName(), "", "01", "Executando função de envio de Laudos..." , 0, (nStart - Seconds()), {}) 
	
	U_RtItmNFS(cFilProc, .T.)
	
	//CONOUT("DAXJLAU07: Fim da Execução")
	FwLogMsg("INFO", /*cTransactionId*/, "DAXJLAU07", FunName(), "", "01", "Fim da Execução" , 0, (nStart - Seconds()), {}) 

	RpcClearEnv()

ENDIF

RETURN
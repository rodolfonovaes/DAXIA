#INCLUDE "TOTVS.CH"

// Define os niveis por Laboratorio no vetor aResultados
#DEFINE _LAB 1      // Laboratorio
#DEFINE _ENS 2      // Ensaio
#DEFINE _PAE 3      // Plano de Amostragem por Ensaio
#DEFINE _MED 4      // Medicoes
#DEFINE _NCO 5      // Nao-conformidades
#DEFINE _CRO 6      // Cronicas
#DEFINE _INS 7      // Instrumentos
#DEFINE _ANE 8      // Documentos anexos
#DEFINE _LAU 9      // Laudo do laboratorio

// Posicoes das colunas no browse que contem os ensaios associados a cada Laboratorio.
#DEFINE SEQ    01   // Sequencia do Laboratorio
#DEFINE ENSAIO 02   // Ensaio corrente              
#DEFINE DESPOR 03   // Descricao do Ensaio Portugues
#DEFINE CARTA  04   // Carta
#DEFINE LIE    05   // Limite Inferior de Engenharia
#DEFINE VLRNOM 06   // Valor Nominal
#DEFINE LSE    07   // Limite Superior de Engenharia
#DEFINE QTDMED 08   // Quantidade de Medicoes (carta)
#DEFINE SKPTST 09   // Situacao do Skip-Teste
#DEFINE METODO 11   // Metodo
#DEFINE REVDOC 12   // Revisao do Documento 
#DEFINE FORMUL 13   // Formula
#DEFINE TEXTO  15   // Texto do Ensaio

#DEFINE QUEBRA   Chr(13) + Chr(10) 
/*
+=======================================================================================+
| Funcao Estatica ....:   DAXIINSP()                                                    |
| Autor(es)...........:   Cicero Odilio Cruz - cicero.cruz@gmail.com                    |
| Data................:   15/08/2020                                                    |
| Descricao / Objetivo:   Botão para Importação de Dados de uma Filial para Outra       |
|                                                                                       |
| Doc. Origem.........:   MIT044 - REPLICAÇÃO DE DADOS INSPEÇÃO ENTRE EMPRESAS-FILIAIS  |
| Solicitante.........:   TOTVS Ibirapuera                                              |
| Uso.................:   Daxia Doce Aroma Ind. Com Ltda.                               |
| Parametros..........:   cProduto - Produto a ser pesquisado                           |
|                         cLote    - Número do Lote                                     |
|                         cItem    - Item da Nota Fiscal                                |
|                         cSerie   - Série da Nota Fiscal                               |
|                         cNota    - Número da Nota Fiscal                              |
| Retorno.............:   << Sem Retorno >>                                             |
| Obs.................:                                                                 |
+=======================================================================================+
*/
USER FUNCTION DAXIINSP()

LOCAL aEmpRel       := {}
LOCAL nPosEmp       := 0
LOCAL cAlias        := GetNextAlias()
LOCAL cAliTMed      := GetNextAlias()
LOCAL lProcesso     := .F.
LOCAL cRevisao      := "00"
LOCAL aResultados   := {}
LOCAL nRecQEK		:= QEK->(RECNO())
LOCAL aDePara		:= {}
LOCAL lResPar		:= .F.

PRIVATE aCpoUsu     := {}  //Armazena os campos ems uso criados pelo usuarios como aliases iguais a QER,QES,QEQ
PRIVATE aCpoQry     := {}  //Armazena os campos a serem utilizados na montagem da Query
PRIVATE lCosEns     := GETMV("DX_LCENSA",.F., .F.)

// Valida a Data de Expiração da Validação por parte do cliente
IF dDatabase >= CTOD("30/11/2020")
	//IF !lJob 
		cMsgP := "Periodo de validação expirado."
		cMsgS := "Solicite um novo período de validação."
		Help( ,, 'DAXIINSP (001)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})				
	//ELSE
	//	CONOUT("AVISO: Periodo de validação expirado. Solicite um novo período de validação.")
	//ENDIF
	RETURN .F.
ENDIF

// TABELA DE-PARA FORNECEDOR-LOJA / EMPRESA-FILIAL
aEmpRel := {    { '000677', '0001', '01', '0101' },; // MATRIZ
                { '000677', '0006', '01', '0103' },; // GUARULHOS
                { '000677', '0007', '01', '0104' },; // RECIFE
                { '000677', '0002', '01', '0102' }}  // ITAJAI

nPosEmp     := aScan( aEmpRel, { | x | x[1]+x[2] == QEK->( QEK_FORNEC + QEK_LOJFOR ) } )

IF nPosEmp == 0
	cMsgP := "Só é  possivel importar medições de entradas da DAXIA."
	cMsgS := "Digite as medições desta entrada."
	Help( ,, 'DAXIINSP (012)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})	
	RETURN NIL
ENDIF

cFilOri     := aEmpRel[nPosEmp][4]
cLote       := ALLTRIM(QEK->QEK_LOTE)
cLoteQEK    := ALLTRIM(QEK->QEK_LOTE)
cProduto    := QEK->QEK_PRODUT
cNota       := QEK->QEK_NTFISC
cItem		:= QEK->QEK_ITEMNF
cRevisao    := QA_UltRevEsp(cProduto,,,,"QIE")

IF LEN(ALLTRIM(cLote)) < 6 // Ajuste para padronizar o tamanho do campo Lote
    cLote   := PADL(ALLTRIM(QEK->QEK_LOTE), 6, '0')
ENDIF

BEGINSQL ALIAS cAliTMed
    %noparser%
	SELECT	QER.R_E_C_N_O_ AS POSICAO
	FROM	%Table:QER% QER (NOLOCK) , 
			%Table:QEK% QEK (NOLOCK) 
	WHERE		QER.QER_FILIAL 	= %xFilial:QER%  
			AND	QER.QER_PRODUT 	= %exp:cProduto%
			AND QER.QER_REVI 	= %exp:cRevisao% 
			AND QER.QER_LOTE 	= %exp:cLoteQEK%  
			AND QEK.QEK_NTFISC  = %exp:cNota%
			AND QEK.QEK_ITEMNF  = %exp:cItem%
			AND QER.QER_TIPONF 	= 'N' 
			AND QER.QER_FORNEC 	= QEK.QEK_FORNEC 
			AND QER.QER_LOJFOR 	= QEK.QEK_LOJFOR 
			AND QER.QER_PRODUT 	= QEK.QEK_PRODUT 
			AND QER.QER_REVI 	= QEK.QEK_REVI 
			AND QER.QER_DTENTR 	= QEK.QEK_DTENTR 
			AND QER.QER_LOTE	= QEK.QEK_LOTE 
			AND QER.QER_PRODUT 	= QEK.QEK_PRODUT 
			AND QER.QER_NUMSEQ  = QEK.QEK_NUMSEQ
			AND QEK.%notdel% 
			AND QER.%notdel% 
	ORDER BY  QER_FILIAL,QER_PRODUT,QER_REVI,QER_FORNEC,QER_LOJFOR,QER_NISERI,QER_TIPONF,QER_LOTE,QER_LABOR,QER_ENSAIO,QER_DTMEDI,QER_HRMEDI,QER_NUMSEQ
ENDSQL

IF  !(cAliTMed)->(Eof())
	cMsgP := "Lote já possui inspeção cadastrada, impossível importar..."
	cMsgS := "Não é possivel importar medições em uma Inspeção, que já possui medições."
	Help( ,, 'DAXIINSP (009)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
	RETURN NIL
ENDIF

// BUSCA ORIGEM DO LOTE ENTRADA (MERCADORIA DE REVENDA) OU PROCESSO (ORDEM DE PRODUCAO)
// CASO nRegs SEJA MAIOR QUE 0 INDICA QUE O LOTE É DERIVADO DE UMA PRODUCAO
BEGINSQL ALIAS cAlias
    %noparser%
    SELECT  R_E_C_N_O_ AS POSICAO
    FROM    %Table:QPK% QPK (NOLOCK)  
    WHERE       QPK.QPK_FILIAL  = %exp:cFilOri% 
            AND QPK.QPK_LOTE    = %exp:cLote%  
            AND QPK.QPK_PRODUT	= %exp:cProduto%
            AND QPK.%notdel%
ENDSQL

cOP := ""
nRegs := 0
IF (cAlias)->(!Eof())
    (cAlias)->(DbGoTop())
	Count To nRegs
	(cAlias)->(DbGoTop())
	DBSELECTAREA("QPK")
	DBSETORDER(1)
	DBGOTO((cAlias)->POSICAO)
	cOP := QPK->QPK_OP	// pego a primeira OP válida do Lote
ENDIF

IF nRegs > 0
    //MSGALERT("LOTE DERIVADO DE PRODUCAO")
    lProcesso := .T.

	aDePara := aClone( QipDePara( cProduto ) )

	IF LEN(aDePara) > 0 // SE EXISTE DE-PARA CADASTRADO
		//MSGAlert("Produto possui DE-PARA")  
		IF U_QipMedRs( cFilOri, cProduto, cRevisao, @aResultados, cOP, QPK->QPK_LOTE, aDePara, @lResPar )

			Begin Transaction
			U_QipGrvMd( aResultados, nRecQEK, lResPar )
			End Transaction  
		ELSE
			cMsgP := "Lote origem não possui medições cadastradas..."
			cMsgS := "Verifique se o Lote Origem possui medições cadastradas."
			Help( ,, 'DAXIINSP (008)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
		ENDIF
		lResPar := .F.
	ELSE
		MSGAlert("De-Para QIP x QIE não cadastrado...")
	ENDIF
ELSE
    //MSGALERT("LOTE DERIVADO DE ENTRADA")
    lProcesso   := .F.
	
	IF SELECT(cAlias) > 0
		(cAlias)->(DBCLOSEAREA())
	ENDIF

	BEGINSQL ALIAS cAlias
		%noparser%
		SELECT  QEK.QEK_REVI
		FROM	QEK010 QEK (NOLOCK) 
		WHERE		QEK.QEK_FILIAL = %exp:cFilOri% 
				AND QEK.QEK_LOTE   = %exp:cLote%  
				AND QEK.QEK_PRODUT = %exp:cProduto%
				AND QEK.%notdel%
	ENDSQL
    
	// BUSCO A REVISÃO ORIGEM
	IF (cAlias)->(!Eof())
    	(cAlias)->(DbGoTop())
		cRevisao := (cAlias)->QEK_REVI
	 
	    IF 	U_QieMedRs( cFilOri, cProduto, cRevisao, @aResultados, @lResPar )

			Begin Transaction
			U_QieGrvMd( aResultados, nRecQEK, lResPar )
			End Transaction

		ELSE
			cMsgP := "Lote origem não possui medições cadastradas..."
			cMsgS := "Verifique se o Lote Origem possui medições cadastradas."
			Help( ,, 'DAXIINSP (003)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})
		ENDIF  
		lResPar := .F.
	ELSE
		cMsgP := "Origem do Lote não encontrada"
		cMsgS := "Verifique o Número do Lote de Daxia, caso esteja errado efetue a exclusão da Nota Fiscal de Entrada."
		Help( ,, 'DAXIINSP (004)',,cMsgP, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgS})	
	ENDIF 

ENDIF

(cAlias)->(DBCLOSEAREA())

RETURN Nil

USER FUNCTION QieMedRs(cFilOri, cProduto, cRevisao, aResultados, lResPar)

LOCAL aAreaAnt      := GetArea()
LOCAL aAreaQE7      := QE7->(GetArea())
LOCAL aAreaQE8      := QE8->(GetArea())
LOCAL nPosLab		:= 0
LOCAL nPosEns		:= 0
LOCAL cFilQE7 	    := IIF ( EMPTY(ALLTRIM(xFilial("QE7"))),  xFilial("QE7"), IIF( xFilial("QE7") == "01  ", xFilial("QE7"), cFilOri) )
LOCAL cFilQE8 	    := IIF ( EMPTY(ALLTRIM(xFilial("QE8"))),  xFilial("QE8"), IIF( xFilial("QE8") == "01  ", xFilial("QE8"), cFilOri) )
LOCAL aTitPag 	    := {}
LOCAL lFilLab       := .T.
LOCAL nX            := 0
LOCAL lRet 			:= .F.
LOCAL lResult		:= .F.
//LOCAL lResPar		:= .F.

dbSelectArea("QE6")
dbSetOrder(1)                               
MsSeek(xFilial("QE6")+cProduto+Inverte(cRevisao))

QE7->(dbSetOrder(4))
IF QE7->(MsSeek(cFilQE7+cProduto+cRevisao))
	WHILE QE7->(!Eof()) .And. (QE7->QE7_FILIAL+QE7->QE7_PRODUT+QE7->QE7_REVI) ==;
		(cFilQE7+cProduto+cRevisao)
		
		//Preenche o aResultados com o Laboratorio
		IF Ascan(aResultados,{|x|x[_LAB]==QE7->QE7_LABOR}) == 0
		
			Aadd( aTitPag,{ Upper(QE7->QE7_LABOR), Upper(QE7->QE7_LABOR) } )
		
			Aadd(aResultados,{QE7->QE7_LABOR,{},{},{},{},{},{},{}})
		
		ENDIF
		
		nPosLab := Ascan(aResultados,{|x|x[_LAB]==QE7->QE7_LABOR})
		IF (nPosLab > 0)
			cNiseri := QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF
			
            //Verifica o Skip-Teste definido para o Ensaio
			cSkpTst := QieSkpTst(QEK->QEK_FORNEC,QEK->QEK_LOJFOR,QEK->QEK_PRODUT,QE7->QE7_ENSAIO,QEK->QEK_DTENTR,QEK->QEK_LOTE,,cNiseri,QEK->QEK_TIPONF)
		    
			QE1->(dbSetOrder(1))
			IF QE1->(MsSeek(xFilial("QE1")+QE7->QE7_ENSAIO))		

				//Verifica se o Metodo associado a especificacao esta preenchido
				IF !Empty(QE7->QE7_METODO)
					cMetodo := QE7->QE7_METODO
					cRevDoc := QE7->QE7_REVDOC
				ELSE 
					cMetodo := QE1->QE1_METODO					
					cRevDoc := ' '	
				ENDIF
					
				//Formata a Formula do Ensaio, caso a mesma esteja definida para o Ensaio 
				cFormula := StrTran(QE7->QE7_FORMUL,"#","")
				IF Empty(cFormula) .And. QE1->QE1_TIPO == "1"
					cFormula := OemToAnsi("O Ensaio e do Tipo Calculado, mas nao possui formula associada")
				ENDIF
			
				//Armazena os Ensaios por Laboratorio no vetor aResultados                                       
				Aadd(aResultados[nPosLab,_ENS],{QE7->QE7_SEQLAB,QE7->QE7_ENSAIO,QE1->QE1_DESCPO,QE1->QE1_CARTA,IIF(QE7->QE7_MINMAX=="3","<<<",QE7->QE7_LIE),;
					QE7->QE7_NOMINA,If(QE7->QE7_MINMAX=="2",">>>",QE7->QE7_LSE),'',Q215QtdMed(QE7->QE7_ENSAIO),cSkpTst,cMetodo,QA_ULTRVDC(cMetodo,dDataBase,.f.,.f.),cFormula,QE1->QE1_DESCIN,QE1->QE1_DESCES})
			
				//Cria a dimensao para os anexos associados aos ensaios
				Aadd(aResultados[nPosLab,_ANE],{})
				
			ENDIF
		ENDIF

		QE7->(dbSkip())	
	ENDDO		
ENDIF

QE8->(dbSetOrder(4))
IF QE8->(MsSeek(cFilQE8+cProduto+cRevisao))
	WHILE QE8->(!Eof()) .And. (QE8->QE8_FILIAL+QE8->QE8_PRODUT+QE8->QE8_REVI) ==;
		(cFilQE8+cProduto+cRevisao)

		//Preenche o aResultados com o Laboratorio
		IF Ascan(aResultados,{|x|x[_LAB]==QE8->QE8_LABOR}) == 0
		
			Aadd( aTitPag,{ Upper(QE8->QE8_LABOR), Upper(QE8->QE8_LABOR) } )
					
			Aadd(aResultados,{QE8->QE8_LABOR,{},{},{},{},{},{},{}})

		ENDIF
		
		//Preenche o aResultados com os Ensaios Vinculados ao Laboratorio
		nPosLab := Ascan(aResultados,{|x|x[_LAB]==QE8->QE8_LABOR})
		IF (nPosLab > 0)
			cNiseri := QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF
		    
            //Verifica o Skip-Teste definido para o Ensaio
			cSkpTst := QieSkpTst(QEK->QEK_FORNEC,QEK->QEK_LOJFOR,QEK->QEK_PRODUT,QE8->QE8_ENSAIO,QEK->QEK_DTENTR,QEK->QEK_LOTE,,cNiseri,QEK->QEK_TIPONF)
		    
			QE1->(dbSetOrder(1))
			IF QE1->(MsSeek(xFilial("QE1")+QE8->QE8_ENSAIO))	
				//Verifica se o Metodo associado a especificacao esta preenchido
				IF !Empty(QE8->QE8_METODO)
					cMetodo := QE8->QE8_METODO
					cRevDoc := QE8->QE8_REVDOC
				ELSE 
					cMetodo := QE1->QE1_METODO					
					cRevDoc := ' '	
				ENDIF

				//Armazena os Ensaios por Laboratorio no vetor aResultados                                       
				Aadd(aResultados[nPosLab,_ENS],{QE8->QE8_SEQLAB,QE8->QE8_ENSAIO,QE1->QE1_DESCPO,QE1->QE1_CARTA,;
					OemToAnsi("N/A"),OemToAnsi("N/A"),OemToAnsi("N/A"),QE8->QE8_TEXTO,Q215QtdMed(QE8->QE8_ENSAIO),;
					cSkpTst,cMetodo,QA_ULTRVDC(cMetodo,dDataBase,.f.,.f.),OemToAnsi("Nao ha Formula definida"),QE1->QE1_DESCIN,QE1->QE1_DESCES}) 
					
				//Cria a dimensao para os anexos associados aos ensaios
				Aadd(aResultados[nPosLab,_ANE],{})
				
			ENDIF				
		
		ENDIF
		
		
		QE8->(dbSkip())	
	ENDDO		
ENDIF

//Ordena a descricao dos Laboratorios nos Folders
aSort(aTitPag,,,{|x,y|x[2]<y[2]})

//Ordena os Laboratorios 
aSort(aResultados,,,{|x,y|x[1]<y[1]})

//Ordena a Sequencia dos Ensaios por Laboratorio
Aeval(aResultados,{|x,y|aSort(aResultados[y,_ENS],,,{|z,w|z[1]<w[1]})})

//????????????????????????????????
//?Associacao das Medicoes, Nao-conformidades, Cronicas e Ins-  ?
//?trumentos ao Vetor aResultados, para edicao dos mesmos.      ?
//????????????????????????????????
cForOri := ""
cLojOri := ""
dDtdOri := STOD("  /  /    ")
cNSOri := ""
cTpOri := ""

FOR nPosLab := 1 TO Len(aResultados)

	FOR nPosEns := 1 TO Len(aResultados[nPosLab,_ENS])
							
		// Cria a posicao para as medicoes referentes ao ensaio		
		Aadd(aResultados[nPosLab,_MED],{})
		
		aColsEns := DaxFilMed(cFilOri, QEK->QEK_FORNEC,QEK->QEK_LOJFOR,cProduto,cRevisao,QEK->QEK_LOTE,QEK->QEK_DTENTR,aResultados[nPosLab,_LAB],aResultados[nPosLab,_ENS,nPosEns,ENSAIO],aResultados[nPosLab,_ENS,nPosEns,CARTA],cNiseri,QEK->QEK_TIPONF,QEK->QEK_NUMSEQ,@cForOri,@cLojOri,@dDtdOri,@cNSOri,@cTpOri,@lResult,@lResPar)
		
		// Dados do Ensaio 
		IF Len(aColsEns) == 0
			aColsEns  := aClone({})	
		ENDIF

        aResultados[nPosLab,_MED,Len(aResultados[nPosLab,_MED])] := aClone(aColsEns)

        // Cria a posicao para as nao-conformidades
		Aadd(aResultados[nPosLab,_NCO],Array(Len(aColsEns)))                                                
						
		// Cria a posicao para as cronicas
		Aadd(aResultados[nPosLab,_CRO],Array(Len(aColsEns))) 

        // Armazena o Plano de Amostragem associado ao Ensaio corrente
		Aadd(aResultados[nPosLab,_PAE],{})

        Aadd(aResultados[nPosLab,_INS],Array(Len(aColsEns))) 
	
	NEXT 

NEXT

nQtdLab := Len(aResultados) //Quantidade de Laboratorios

aStruct := FWFormStruct(3,"QEL")[3]
nPosLaudo  := Ascan(aStruct,{|x|AllTrim(x[1])=="QEL_LAUDO"})
nPosDtEnLa := Ascan(aStruct,{|x|AllTrim(x[1])=="QEL_DTENLA"})
nPosHrEnLa := Ascan(aStruct,{|x|AllTrim(x[1])=="QEL_HRENLA"})
nPosTamLot := Ascan(aStruct,{|x|AllTrim(x[1])=="QEL_TAMLOT"})
nPosDtaLau := Ascan(aStruct,{|x|AllTrim(x[1])=="QEL_DTLAUD"})
nPosValLau := Ascan(aStruct,{|x|AllTrim(x[1])=="QEL_DTVAL"})

FOR nX := 1 TO Len(aTitPag) 

	//Cria a posicao para os laudos
	Aadd(aResultados[nX],{})
	cNiseri := QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF
	aLauLab := DaxFilLau(cFilOri, cForOri, cLojOri, cProduto, dDtdOri,QEK->QEK_LOTE,aTitPag[nX,2],cNSOri,cTPOri,QEK->QEK_NUMSEQ)
	IF Len(aLauLab)	== 0         
		//Preenche a posicao do Laudo com as variaveis default, caso nao haja laudo
		aLauLab := DAXFilEnc("QEL",.F.)
                                      
		//Sugere os campos no Laudo do Laboratorio a partir da Entrada
		aLauLab[nPosDtEnLa] := QEK->QEK_DTENTR
		aLauLab[nPosHrEnLa] := QEK->QEK_HRENTR
		aLauLab[nPosTamLot] := QEK->QEK_TAMLOT
		aLauLab[nPosDtaLau] := QEK->QEK_DTENTR
		aLauLab[nPosValLau] := QEK->QEK_DTENTR + QAtuShelf(QEK->QEK_PRODUT,QEK->QEK_REVI) 		
	EndIf
	
	//Cria a posicao para o laudo 
	aResultados[nX,Len(aResultados[nX])] := aClone(aLauLab)

NEXT  

//Verifica se existem Ensaios a serem inspecionados
Aeval(aResultados,{|x,y|lFilLab:=If(Len(aResultados[y,_ENS])==0,.F.,lFilLab)})

If lFilLab

	//Cria a posicao para o Laudo Geral
	Aadd(aResultados,{})
	cNiseri := QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF
	//Caso o Laudo Geral da Entrada esteja preenchido carrega o mesmo para edicao

	aLauGer := DaxFilLau(cFilOri, cForOri, cLojOri, cProduto, dDtdOri,QEK->QEK_LOTE,Space(TamSX3("QEL_LABOR")[1]),cNSOri,cTPOri,QEK->QEK_NUMSEQ)
			
	//Armazena o Laudo Geral da Entrada
	Aadd(aResultados[Len(aResultados)],aClone(aLauGer))

ENDIF

RestArea(aAreaQE7)   
RestArea(aAreaQE8)   
RestArea(aAreaAnt)   

Return lResult                                     

USER FUNCTION QieGrvMd(aResultados, nRecQEK, lResPar)

LOCAL nX      := 0
LOCAL nY      := 0
LOCAL nZ      := 0
LOCAL nCpoMed := 0
LOCAL nPosMed := 0 
LOCAL lQReinsp	:= QieReinsp()
LOCAL nSaveSX8   := GetSX8Len()
LOCAL lVerMens   := .T. 

//Grava o numero do certificado, caso haja Laudo da Entrada
If Empty(QEK->QEK_CERQUA)
	RecLock("QEK",.F.)
	QEK->QEK_CERQUA := QA_SEQUSX6("QIE_CEQU",TamSX3("QEK_CERQUA")[1],"S","Certificado Qualidade") 
	MsUnlock()
EndIf
	
//	RecLock("QEK",.F.)
//	For nI := 1 To Len(aCpos)  //Grava campos de usuarios da tabela QEK
//		&("QEK->"+Alltrim(aCpos[nI])) := &("M->"+Alltrim(aCpos[nI]))
//	Next 
//	MsUnLock()

nQtdLab := Len(aResultados)-1

//Salva a posicao do Laudo Geral da Entrada
nFldLabGer := Len(aResultados)

lTemDados := .F.
FOR nX := 1 to nQtdLab
	FOR nY := 1 to Len(aResultados[nX,_MED])
		IF LEN(aResultados[nX,_ENS,nY]) > 0
			lTemDados := .T.
		ENDIF
	NEXT
NEXT

IF !lTemDados
	MSGALERT("NÃO FORAM ENCONTRADOS DADOS DE MEDIÇÕES...")
ENDIF

//????????????????????????????????
//?Atualiza os Laudos referentes aos Laboratorios	 			 ?
//????????????????????????????????
Aeval( aResultados, { |x,y| IIF( y <= nQtdLab, QIEAtuLab( aResultados[y,_LAB], y, aResultados, .F., lResPar ), NIL ) } )

QIEAtuLab( '', nFldLabGer, aResultados, .T., lResPar )

//??????????????????????????????
//?Grava os dados referentes a medicoes					?
//??????????????????????????????
For nX := 1 to nQtdLab
    cLabor := aResultados[nX,_LAB] //Laboratorio corrente
    
	For nY := 1 to Len(aResultados[nX,_MED])
		nPosLab	 := nX
		cEnsaio  := aResultados[nX,_ENS,nY,ENSAIO] //Ensaio corrente		
		cCarEns  := QA_CartEns(cEnsaio)            //Carta utilizada no Ensaio
		cFormul  := ""
		aHeadTmp := aClone( DAXQHMED(nPosLab,cEnsaio,cCarEns,cFormul) )	    //aHeader formatado para o ensaio corrente			
		nQtdMed  := Q215QtdMed(cEnsaio)		        //Quantidade de medicoes

		//Salva a posicao do Resultado da Medicao
		If cCarEns == "TXT"
			nPosResMed := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QEQ_RESULT"})
		Else
			nPosResMed := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QER_RESULT"})
		EndIf	
		nFilMat   := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QER_FILMAT"})
		nPosRast  := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QER_RASTRE"})
      	nPosMetod := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QER_METODO"})
  	   	nPosRvDoc := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QER_RVDOC"})
      	nPosEnsR  := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QER_ENSR"})
                                     
      	If cCarEns == "TMP" //Ensaio do Tipo: TEMPO
      		nPosDtIni := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QER_DTINI"})
      		nPosHrIni := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QER_HRINI"}) 		
      		nPosDtFim := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QER_DTFIM"})
      		nPosHrFim := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QER_HRFIM"}) 		
      	EndIf 

		//??????????????????????????????
		//?Grava as medicoes										?
		//??????????????????????????????
		For nZ := 1 to Len(aResultados[nX,_MED,nY])                      
			cCodMed := 	"ZZZZZZZZ" 		
			//lDelMed := 	aResultados[nX,_MED,nY,nZ,Len(aResultados[nX,_MED,nY,nZ])]
			cNiseri := 	QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF
			cSeek 	:= 	QEK->(QEK_PRODUT+QEK_REVI+QEK_FORNEC+QEK_LOJFOR)+cNiseri+QEK->(QEK_TIPONF+;
					   	QEK_LOTE)+cLabor+cEnsaio+dTos(aResultados[nX,_MED,nY,nZ,1])+;
						aResultados[nX,_MED,nY,nZ,2]
						
			If lQReinsp
				cSeek += QEK->QEK_NUMSEQ
			Endif				

		
			dbSelectArea("QER")
			dbSetOrder(4)
			cCodMed := QA_SXESXF("QER","QER_CHAVE",,4)
			While ( GetSX8Len() > nSaveSx8 )
				ConfirmSX8()
			EndDo

			RecLock("QER",.T.)
			QER->QER_FILIAL := xFilial("QER")
			QER->QER_PRODUT := QEK->QEK_PRODUT
			QER->QER_REVI   := QEK->QEK_REVI
			QER->QER_FORNEC := QEK->QEK_FORNEC
			QER->QER_LOJFOR := QEK->QEK_LOJFOR
			QER->QER_DTENTR := QEK->QEK_DTENTR
			QER->QER_LOTE   := QEK->QEK_LOTE
			QER->QER_LABOR  := cLabor
			QER->QER_ENSAIO := cEnsaio
			QER->QER_CHAVE  := cCodMed
			QER->QER_NISERI := QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF
			QER->QER_NTFISC := QEK->QEK_NTFISC 
			QER->QER_ITEMNF := QEK->QEK_ITEMNF 
			QER->QER_SERINF := QEK->QEK_SERINF 					
			QER->QER_TIPONF := QEK->QEK_TIPONF 
			
			If lQReinsp
				QER->QER_NUMSEQ := QEK->QEK_NUMSEQ
			Endif

			QER->QER_DTMEDI := aResultados[nX,_MED,nY,nZ,1] //posicao fixa
			QER->QER_HRMEDI := aResultados[nX,_MED,nY,nZ,2] //posicao fixa
			QER->QER_AMOSTR := aResultados[nX,_MED,nY,nZ,3] //posicao fixa
			QER->QER_ENSR   := aResultados[nX,_MED,nY,nZ,nPosEnsR]  
			QER->QER_RESULT := aResultados[nX,_MED,nY,nZ,nPosResMed]
			QER->QER_FILMAT := aResultados[nX,_MED,nY,nZ,nFilMat]
			QER->QER_RASTRE := aResultados[nX,_MED,nY,nZ,nPosRast] 
			QER->QER_METODO := aResultados[nX,_MED,nY,nZ,nPosMetod] 
			QER->QER_RVDOC  := aResultados[nX,_MED,nY,nZ,nPosRvDoc] 
			
			If cCarEns == "TMP"  //Ensaio do Tipo: TEMPO
				QER->QER_DTINI := aResultados[nX,_MED,nY,nZ,nPosDtIni] 
				QER->QER_HRINI := aResultados[nX,_MED,nY,nZ,nPosHrIni] 
				QER->QER_DTFIM := aResultados[nX,_MED,nY,nZ,nPosDtFim] 
				QER->QER_HRFIM := aResultados[nX,_MED,nY,nZ,nPosHrFim] 
			EndIf 

			//??????????????????????????????
			//?Realiza a gravacao dos campos criados pelo usuario 		?
			//??????????????????????????????
			For nCpoMed := 1 to Len(aCpoUsu)
				If SubStr(aCpoUsu[nCpoMed],1,3) == "QER"         
					nPosCpoMed := Ascan(aHeadTmp,{|x|AllTrim(x[2])==AllTrim(aCpoUsu[nCpoMed])})
					If nPosCpoMed > 0
						If GetSx3Cache(aCpoUsu[nCpoMed],"X3_PROPRI") == "U"
							If aCpoUsu[nCpoMed] <> "QER_NUMSEQ"
								QER->(FieldPut(FieldPos(AllTrim(aCpoUsu[nCpoMed])),aResultados[nX,_MED,nY,nZ,nPosCpoMed]))
							Endif
						EndIf										 
					EndIf		
				EndIf
			Next nCpoMed
			
			QER->(MsUnLock())
			
			//??????????????????????????????
			//?Grava as medicoes dos ensaios com carta # TXT			?
			//??????????????????????????????
			If cCarEns <> "TXT" .And. lVerMens       
				If cCarEns == "P  "
					nPosMed  := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QES_MEDIPA"})
				Else
					nPosMed  := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QES_MEDICA"})
				EndIf
				
				dbSelectArea("QES")
				dbSetOrder(1)
				If MsSeek(xFilial("QES")+cCodMed)
					lTrava := .F.
				Else
					lTrava := .T.
				EndIf						
					     
				//Grava as medicoes mensuraveis	
				nQtdCpo := (nPosMed+nQtdMed-1)
				For nPosMed := nPosMed to nQtdCpo
				
				    //Verifica se a medicao mensuravel possui a mesma chave
				    If !lTrava .And. (QES->QES_CODMED <> cCodMed)
				    	Exit
				    EndIf               

					//Considera somente os campos que serao gravados no QES				    
					If AllTrim(aHeadTmp[nPosMed,2]) $ "QES_MEDICA/QES_MEDIPA/QES_MEDIPN/QES_MEDIPP"	
					
						RecLock("QES",lTrava)            
						If lTrava
							QES->QES_FILIAL := xFilial("QES")
							QES->QES_CODMED := cCodMed   
						EndIf					         
					
						//Se existir o registro e estiver deletado no aCols		
						//If (!lTrava .And. lDelMed)
							//Exclui a medicao mensuravel
							//dbDelete()
						//Else    						   
							//Se nao existir e estiver deletado no aCols
							//If !lDelMed	
								If cCarEns <> "P  "                    
									If AllTrim(aHeadTmp[nPosMed,2]) == "QES_MEDICA"	 
										If cCarEns == "TMP"                    
											QES->QES_MEDICA := If(Valtype(aResultados[nX,_MED,nY,nZ,nPosMed])=='N',;
												AllTrim(Str(aResultados[nX,_MED,nY,nZ,nPosMed])),;
												AllTrim(aResultados[nX,_MED,nY,nZ,nPosMed]))
     	                                Else
											QES->QES_MEDICA := aResultados[nX,_MED,nY,nZ,nPosMed]
										EndIf	
									EndIf	
								Else               
									If 	AllTrim(aHeadTmp[nPosMed,2]) == "QES_MEDIPA"	 						                                                                                             
										QES->QES_INDMED := "A"                             
										QES->QES_MEDICA := Str(aResultados[nX,_MED,nY,nZ,nPosMed],TamSx3("QES_MEDICA")[1])
										
									ElseIf AllTrim(aHeadTmp[nPosMed,2]) == "QES_MEDIPN"	 			 
										QES->QES_MEDICA := StrTran(Str(aResultados[nX,_MED,nY,nZ,nPosMed],TamSx3("QES_MEDICA")[1],2),".",",")
										
										nPosCalPor := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QES_CALPOR"})
										If aResultados[nX,_MED,nY,nZ,nPosCalPor] == "S"								
											QES->QES_INDMED := "N"
										EndIf
									ElseIf AllTrim(aHeadTmp[nPosMed,2]) == "QES_MEDIPP"	 						                                                                                             
										QES->QES_INDMED := "P"
										QES->QES_MEDICA := Str(aResultados[nX,_MED,nY,nZ,nPosMed],TamSx3("QES_MEDICA")[1],TamSx3("QES_MEDIPP")[2])
									EndIf									
								EndIf								
							//EndIf
						//EndIf
				        MsUnLock()

				        //Se o registro existe, pula o mesmo
						If !lTrava
							QES->(dbSkip())
						EndIf
					EndIf	
						
				Next nPosMed

			ElseIf cCarEns == "TXT" .And. lVerMens                             
				//??????????????????????????????
				//?Grava as medicoes dos ensaios com carta = TXT			?
				//??????????????????????????????
				 
				//Grava os resultados com carta do tipo texto
				nPosTxtMed := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QEQ_MEDICA"})

				dbSelectArea("QEQ")
				dbSetOrder(1)
				//If MsSeek(xFilial("QEQ")+cCodMed)
					//RecLock("QEQ",.F.)                                   
					//Se existir o registro e estiver marcado para exclusao
					//If lDelMed    
					//	dbDelete()
					//EndIf
				//Else
					//If !lDelMed
						RecLock("QEQ",.T.)
						QEQ->QEQ_FILIAL := xFilial("QEQ")
						QEQ->QEQ_CODMED := cCodMed
					//EndIf	
				//EndIf
				//Se nao estiver marcado para exclusao                             
				//If !lDelMed
					QEQ->QEQ_MEDICA := aResultados[nX,_MED,nY,nZ,nPosTxtMed] 		
				//EndIf	
				MsUnLock()
							
			EndIf

			//??????????????????????????????
			//?Atualiza as nao-conformidades e cronicas associadas as  ?
			//?Medicoes    											?
			//??????????????????????????????
			//Q215AtuNco(nX,nY,nZ,lDelMed,cCodMed,@lNaoGrvNNC)      
			
			//??????????????????????????????
			//?Atualiza as cronicas associadas as nao-conformidades    ?
			//??????????????????????????????
			//Q215AtuIns(nX,nY,nZ,lDelMed,cCodMed)

			//??????????????????????????????
			//?Salva as chaves para Integracao com o QNC				?
			//??????????????????????????????
			//Aadd(aCodMed,cCodMed)
			
	    Next nZ
	
	Next nY    
	
	//??????????????????????????????
	//?Atualiza os Documentos Anexos							?
	//??????????????????????????????
	//Aeval(aResultados[nX,_ENS],{|x,y|Q215AtuAnexos(nX,y,QEK->QEK_LOTE,nOpc,QEK->QEK_PRODUT)})
Next nX

QEK->(DBGOTO(nRecQEK))
RecLock("QEK",.F.)  
QEK->QEK_MOVEST := "S"
QEK->QEK_SITENT := "6"
QEK->(MSUNLOCK())   

Return

USER FUNCTION QipGrvMd(aResultados, nRecQEK, lResPar)

LOCAL nX      		:= 0
LOCAL nY      		:= 0
LOCAL nZ      		:= 0
LOCAL nCpoMed 		:= 0
LOCAL nPosMed 		:= 0 
LOCAL lQReinsp		:= QieReinsp()
LOCAL nSaveSX8   	:= GetSX8Len()
LOCAL lVerMens   	:= .T. 

//Grava o numero do certificado, caso haja Laudo da Entrada
If Empty(QEK->QEK_CERQUA)
	RecLock("QEK",.F.)
	QEK->QEK_CERQUA := QA_SEQUSX6("QIE_CEQU",TamSX3("QEK_CERQUA")[1],"S","Certificado Qualidade") 
	MsUnlock()
EndIf
	
//	RecLock("QEK",.F.)
//	For nI := 1 To Len(aCpos)  //Grava campos de usuarios da tabela QEK
//		&("QEK->"+Alltrim(aCpos[nI])) := &("M->"+Alltrim(aCpos[nI]))
//	Next 
//	MsUnLock()

nQtdLab := Len(aResultados)-1

//Salva a posicao do Laudo Geral da Entrada
nFldLabGer := Len(aResultados)
		
//????????????????????????????????
//?Atualiza os Laudos referentes aos Laboratorios	 			 ?
//????????????????????????????????
Aeval( aResultados, { |x,y| IIF( y <= nQtdLab, QIPAtuLab( aResultados[y,_LAB], y, aResultados, .F., lResPar ), NIL ) } )

QIPAtuLab( '', nFldLabGer, aResultados, .T., lResPar )

//??????????????????????????????
//?Grava os dados referentes a medicoes					?
//??????????????????????????????
For nX := 1 to nQtdLab
    cLabor := aResultados[nX,_LAB] //Laboratorio corrente
    
	For nY := 1 to Len(aResultados[nX,_MED])
		nPosLab	 := nX
		cEnsaio  := aResultados[nX,_ENS,nY,ENSAIO] //Ensaio corrente		
		cCarEns  := QA_CartEns(cEnsaio)            //Carta utilizada no Ensaio
		cFormul  := ""
		aHeadTmp := aClone( DAXQHMED(nPosLab,cEnsaio,cCarEns,cFormul) )	    //aHeader formatado para o ensaio corrente			
		nQtdMed  := Q215QtdMed(cEnsaio)		        //Quantidade de medicoes

		//Salva a posicao do Resultado da Medicao
		If cCarEns == "TXT"
			nPosResMed := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QEQ_RESULT"})
		Else
			nPosResMed := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QER_RESULT"})
		EndIf	
		nFilMat   := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QER_FILMAT"})
		nPosRast  := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QER_RASTRE"})
      	nPosMetod := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QER_METODO"})
  	   	nPosRvDoc := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QER_RVDOC"})
      	nPosEnsR  := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QER_ENSR"})
                                     
      	If cCarEns == "TMP" //Ensaio do Tipo: TEMPO
      		nPosDtIni := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QER_DTINI"})
      		nPosHrIni := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QER_HRINI"}) 		
      		nPosDtFim := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QER_DTFIM"})
      		nPosHrFim := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QER_HRFIM"}) 		
      	EndIf 

		//??????????????????????????????
		//?Grava as medicoes										?
		//??????????????????????????????
		For nZ := 1 to Len(aResultados[nX,_MED,nY])                      
			cCodMed := 	"ZZZZZZZZ" 		
			//lDelMed := 	aResultados[nX,_MED,nY,nZ,Len(aResultados[nX,_MED,nY,nZ])]
			cNiseri := 	QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF
			cSeek 	:= 	QEK->(QEK_PRODUT+QEK_REVI+QEK_FORNEC+QEK_LOJFOR)+cNiseri+QEK->(QEK_TIPONF+;
					   	QEK_LOTE)+cLabor+cEnsaio+dTos(aResultados[nX,_MED,nY,nZ,1])+;
						aResultados[nX,_MED,nY,nZ,2]
						
			If lQReinsp
				cSeek += QEK->QEK_NUMSEQ
			Endif				

		
			dbSelectArea("QER")
			dbSetOrder(4)
			cCodMed := QA_SXESXF("QER","QER_CHAVE",,4)
			While ( GetSX8Len() > nSaveSx8 )
				ConfirmSX8()
			EndDo

			RecLock("QER",.T.)
			QER->QER_FILIAL := xFilial("QER")
			QER->QER_PRODUT := QEK->QEK_PRODUT
			QER->QER_REVI   := QEK->QEK_REVI
			QER->QER_FORNEC := QEK->QEK_FORNEC
			QER->QER_LOJFOR := QEK->QEK_LOJFOR
			QER->QER_DTENTR := QEK->QEK_DTENTR
			QER->QER_LOTE   := QEK->QEK_LOTE
			QER->QER_LABOR  := cLabor
			QER->QER_ENSAIO := cEnsaio
			QER->QER_CHAVE  := cCodMed
			QER->QER_NISERI := QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF
			QER->QER_NTFISC := QEK->QEK_NTFISC 
			QER->QER_ITEMNF := QEK->QEK_ITEMNF 
			QER->QER_SERINF := QEK->QEK_SERINF 					
			QER->QER_TIPONF := QEK->QEK_TIPONF 
			
			If lQReinsp
				QER->QER_NUMSEQ := QEK->QEK_NUMSEQ
			Endif

			QER->QER_DTMEDI := aResultados[nX,_MED,nY,nZ,1] //posicao fixa
			QER->QER_HRMEDI := aResultados[nX,_MED,nY,nZ,2] //posicao fixa
			QER->QER_AMOSTR := aResultados[nX,_MED,nY,nZ,3] //posicao fixa
			QER->QER_ENSR   := aResultados[nX,_MED,nY,nZ,nPosEnsR]  
			QER->QER_RESULT := aResultados[nX,_MED,nY,nZ,nPosResMed]
			QER->QER_FILMAT := aResultados[nX,_MED,nY,nZ,nFilMat]
			QER->QER_RASTRE := aResultados[nX,_MED,nY,nZ,nPosRast] 
			QER->QER_METODO := aResultados[nX,_MED,nY,nZ,nPosMetod] 
			QER->QER_RVDOC  := aResultados[nX,_MED,nY,nZ,nPosRvDoc] 
			
			If cCarEns == "TMP"  //Ensaio do Tipo: TEMPO
				QER->QER_DTINI := aResultados[nX,_MED,nY,nZ,nPosDtIni] 
				QER->QER_HRINI := aResultados[nX,_MED,nY,nZ,nPosHrIni] 
				QER->QER_DTFIM := aResultados[nX,_MED,nY,nZ,nPosDtFim] 
				QER->QER_HRFIM := aResultados[nX,_MED,nY,nZ,nPosHrFim] 
			EndIf 

			//??????????????????????????????
			//?Realiza a gravacao dos campos criados pelo usuario 		?
			//??????????????????????????????
			For nCpoMed := 1 to Len(aCpoUsu)
				If SubStr(aCpoUsu[nCpoMed],1,3) == "QER"         
					nPosCpoMed := Ascan(aHeadTmp,{|x|AllTrim(x[2])==AllTrim(aCpoUsu[nCpoMed])})
					If nPosCpoMed > 0
						If GetSx3Cache(aCpoUsu[nCpoMed],"X3_PROPRI") == "U"
							If aCpoUsu[nCpoMed] <> "QER_NUMSEQ"
								QER->(FieldPut(FieldPos(AllTrim(aCpoUsu[nCpoMed])),aResultados[nX,_MED,nY,nZ,nPosCpoMed]))
							Endif
						EndIf										 
					EndIf		
				EndIf
			Next nCpoMed
			
			QER->(MsUnLock())
			
			//??????????????????????????????
			//?Grava as medicoes dos ensaios com carta # TXT			?
			//??????????????????????????????
			If cCarEns <> "TXT" .And. lVerMens       
				If cCarEns == "P  "
					nPosMed  := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QES_MEDIPA"})
				Else
					nPosMed  := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QES_MEDICA"})
				EndIf
				
				dbSelectArea("QES")
				dbSetOrder(1)
				If MsSeek(xFilial("QES")+cCodMed)
					lTrava := .F.
				Else
					lTrava := .T.
				EndIf						
					     
				//Grava as medicoes mensuraveis	
				nQtdCpo := (nPosMed+nQtdMed-1)
				For nPosMed := nPosMed to nQtdCpo
				
				    //Verifica se a medicao mensuravel possui a mesma chave
				    If !lTrava .And. (QES->QES_CODMED <> cCodMed)
				    	Exit
				    EndIf               

					//Considera somente os campos que serao gravados no QES				    
					If AllTrim(aHeadTmp[nPosMed,2]) $ "QES_MEDICA/QES_MEDIPA/QES_MEDIPN/QES_MEDIPP"	
					
						RecLock("QES",lTrava)            
						If lTrava
							QES->QES_FILIAL := xFilial("QES")
							QES->QES_CODMED := cCodMed   
						EndIf					         
					
						//Se existir o registro e estiver deletado no aCols		
						//If (!lTrava .And. lDelMed)
							//Exclui a medicao mensuravel
							//dbDelete()
						//Else    						   
							//Se nao existir e estiver deletado no aCols
							//If !lDelMed	
								If cCarEns <> "P  "                    
									If AllTrim(aHeadTmp[nPosMed,2]) == "QES_MEDICA"	 
										If cCarEns == "TMP"                    
											QES->QES_MEDICA := If(Valtype(aResultados[nX,_MED,nY,nZ,nPosMed])=='N',;
												AllTrim(Str(aResultados[nX,_MED,nY,nZ,nPosMed])),;
												AllTrim(aResultados[nX,_MED,nY,nZ,nPosMed]))
     	                                Else
											QES->QES_MEDICA := aResultados[nX,_MED,nY,nZ,nPosMed]
										EndIf	
									EndIf	
								Else               
									If 	AllTrim(aHeadTmp[nPosMed,2]) == "QES_MEDIPA"	 						                                                                                             
										QES->QES_INDMED := "A"                             
										QES->QES_MEDICA := Str(aResultados[nX,_MED,nY,nZ,nPosMed],TamSx3("QES_MEDICA")[1])
										
									ElseIf AllTrim(aHeadTmp[nPosMed,2]) == "QES_MEDIPN"	 			 
										QES->QES_MEDICA := StrTran(Str(aResultados[nX,_MED,nY,nZ,nPosMed],TamSx3("QES_MEDICA")[1],2),".",",")
										
										nPosCalPor := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QES_CALPOR"})
										If aResultados[nX,_MED,nY,nZ,nPosCalPor] == "S"								
											QES->QES_INDMED := "N"
										EndIf
									ElseIf AllTrim(aHeadTmp[nPosMed,2]) == "QES_MEDIPP"	 						                                                                                             
										QES->QES_INDMED := "P"
										QES->QES_MEDICA := Str(aResultados[nX,_MED,nY,nZ,nPosMed],TamSx3("QES_MEDICA")[1],TamSx3("QES_MEDIPP")[2])
									EndIf									
								EndIf								
							//EndIf
						//EndIf
				        MsUnLock()

				        //Se o registro existe, pula o mesmo
						If !lTrava
							QES->(dbSkip())
						EndIf
					EndIf	
						
				Next nPosMed

			ElseIf cCarEns == "TXT" .And. lVerMens                             
				//??????????????????????????????
				//?Grava as medicoes dos ensaios com carta = TXT			?
				//??????????????????????????????
				 
				//Grava os resultados com carta do tipo texto
				nPosTxtMed := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QEQ_MEDICA"})

				dbSelectArea("QEQ")
				dbSetOrder(1)
				//If MsSeek(xFilial("QEQ")+cCodMed)
					//RecLock("QEQ",.F.)                                   
					//Se existir o registro e estiver marcado para exclusao
					//If lDelMed    
					//	dbDelete()
					//EndIf
				//Else
					//If !lDelMed
						RecLock("QEQ",.T.)
						QEQ->QEQ_FILIAL := xFilial("QEQ")
						QEQ->QEQ_CODMED := cCodMed
					//EndIf	
				//EndIf
				//Se nao estiver marcado para exclusao                             
				//If !lDelMed
					QEQ->QEQ_MEDICA := aResultados[nX,_MED,nY,nZ,nPosTxtMed] 		
				//EndIf	
				MsUnLock()
							
			EndIf

			//??????????????????????????????
			//?Atualiza as nao-conformidades e cronicas associadas as  ?
			//?Medicoes    											?
			//??????????????????????????????
			//Q215AtuNco(nX,nY,nZ,lDelMed,cCodMed,@lNaoGrvNNC)      
			
			//??????????????????????????????
			//?Atualiza as cronicas associadas as nao-conformidades    ?
			//??????????????????????????????
			//Q215AtuIns(nX,nY,nZ,lDelMed,cCodMed)

			//??????????????????????????????
			//?Salva as chaves para Integracao com o QNC				?
			//??????????????????????????????
			//Aadd(aCodMed,cCodMed)
			
	    Next nZ
	
	Next nY    
	
	//??????????????????????????????
	//?Atualiza os Documentos Anexos							?
	//??????????????????????????????
	//Aeval(aResultados[nX,_ENS],{|x,y|Q215AtuAnexos(nX,y,QEK->QEK_LOTE,nOpc,QEK->QEK_PRODUT)})
Next nX

QEK->(DBGOTO(nRecQEK))
RecLock("QEK",.F.)  
QEK->QEK_MOVEST := "S"
QEK->QEK_SITENT := "6"
QEK->(MSUNLOCK())   

Return

Static Function DaxFilMed(cFilOri, cFornec,cLoja,cProduto,cRevi,cLote,dEntrada,cLabor,cEnsaio,cCarta,cNiseri,cTiNF,cNumSeq,cForOri,cLojOri,dDtdOri,cNSOri,cTpOri,lResult,lResPar)
Local aAreaAnt	:= GetArea()                      
Local aAreaQES  := QES->(GetArea())
Local aAreaQEQ  := QEQ->(GetArea())
Local aAreaQER  := QER->(GetArea())
Local nQtdMed   := 0
Local cSeek     := ""
Local cChvMed	:= ""
Local aMed		:= {}
Local aMedicao  := {}
Local cSeekQER  := "" 
Local lQReinsp	:= QieReinsp()

Local cAliasQER := "QER"
Local lQuery    := .F.          
Local cQuery    := ""
Local aStruQER  := {}
Local nPosCpo   := 0

nQtdMed	:= Q215QtdMed(cEnsaio) //Define o numero de medicoes cadastradas
//QER->(dbSetOrder(5)) //Criar ordem de pesquisar, possivel ordem nova - DENIS
//cSeek   :=   (cFilOri+cProduto+cRevi+cFornec+cLoja+cNiseri+cTiNF+cLote+cLabor+cEnsaio)
//cSeekQER := "(QER_FILIAL+QER_PRODUT+QER_REVI+QER_FORNEC+QER_LOJFOR+QER_NISERI+QER_TIPONF+QER_LOTE+QER_LABOR+QER_ENSAIO)"

//dbSelectArea("QER")

//If MsSeek(cSeek)

IF LEN(ALLTRIM(cLote)) < 6 // Ajuste para padronizar o tamanho do campo Lote
    cLote   := PADL(ALLTRIM(QEK->QEK_LOTE), 6, '0')
ENDIF

	cAliasQER := "QRYQER"           
	aStruQER  := QER->(dbStruct())
	lQuery    := .T.
	cQuery    := "SELECT QER.QER_FILIAL QER_FILIAL, " + QUEBRA
	cQuery    += "QER.QER_PRODUT QER_PRODUT, " + QUEBRA
	cQuery    += "QER.QER_REVI   QER_REVI  , " + QUEBRA
	cQuery    += "QER.QER_FORNEC QER_FORNEC, " + QUEBRA
	cQuery    += "QER.QER_LOJFOR QER_LOJFOR, " + QUEBRA
	cQuery    += "QER.QER_DTENTR QER_DTENTR, " + QUEBRA 
	cQuery    += "QER.QER_LOTE   QER_LOTE  , " + QUEBRA
	cQuery    += "QER.QER_RASTRE QER_RASTRE, " + QUEBRA
	cQuery    += "QER.QER_LABOR  QER_LABOR , " + QUEBRA
	cQuery    += "QER.QER_ENSAIO QER_ENSAIO, " + QUEBRA
	cQuery    += "QER.QER_DTMEDI QER_DTMEDI, " + QUEBRA
	cQuery    += "QER.QER_HRMEDI QER_HRMEDI, " + QUEBRA
	cQuery    += "QER.QER_AMOSTR QER_AMOSTR, " + QUEBRA
	cQuery    += "QER.QER_ENSR   QER_ENSR  , " + QUEBRA
	cQuery    += "QER.QER_RESULT QER_RESULT, " + QUEBRA
	cQuery    += "QER.QER_CHAVE  QER_CHAVE , " + QUEBRA
	cQuery    += "QER.QER_NISERI  QER_NISERI, " + QUEBRA    
	cQuery    += "QER.QER_TIPONF  QER_TIPONF, " + QUEBRA    
	cQuery    += "QER.QER_FILMAT QER_FILMAT, " + QUEBRA                                         
  	cQuery    += "QER.QER_METODO QER_METODO, " + QUEBRA
	cQuery    += "QER.QER_RVDOC  QER_RVDOC , " + QUEBRA      
	cQuery    += "QER.QER_DTINI  QER_DTINI , " + QUEBRA      
	cQuery    += "QER.QER_HRINI  QER_HRINI , " + QUEBRA      
	cQuery    += "QER.QER_DTFIM  QER_DTFIM , " + QUEBRA      
	cQuery    += "QER.QER_HRFIM  QER_HRFIM , " + QUEBRA      
	cQuery    += "QER.R_E_C_N_O_ QERRECNO    " + QUEBRA                                                                           
	//????????????????????????????????
	//?Define as colunas dos campos criados pelo usuario			 ?
	//????????????????????????????????
	//Aeval(aCpoQry,{|x|If(SubStr(x,1,3)=="QER",cQuery+=", QER."+x+" "+x+" ",NIL)})		
	
	cQuery    += "FROM "+RetSqlName("QER")+" QER " + QUEBRA
	If lQReinsp
		cQuery    += ","+RetSqlName("QEK")+" QEK " + QUEBRA
	Endif
	//cQuery    += "WHERE QER.QER_FILIAL = '"+xFilial("QER")+"' AND " + QUEBRA
	cQuery    += "WHERE QER.QER_FILIAL = '"+cFilOri+"' AND " + QUEBRA
	cQuery    += "QER.QER_PRODUT = '"+cProduto+"' AND " + QUEBRA
	cQuery    += "QER.QER_REVI = '"+cRevi+"' AND " + QUEBRA
	//cQuery    += "QER.QER_FORNEC = '"+cFornec+"' AND " + QUEBRA
	//cQuery    += "QER.QER_LOJFOR = '"+cLoja+"' AND " + QUEBRA
	//cQuery    += "QER.QER_DTENTR = '"+DTOS(dEntrada)+"' AND " + QUEBRA
	cQuery    += "QER.QER_LOTE = '"+cLote+"' AND " + QUEBRA
	cQuery    += "QER.QER_LABOR = '"+cLabor+"' AND " + QUEBRA
	cQuery    += "QER.QER_ENSAIO = '"+cEnsaio+"' AND " + QUEBRA
	//cQuery    += "QER.QER_NISERI = '"+cNiseri+"' AND " + QUEBRA
	cQuery    += "QER.QER_TIPONF = '"+cTiNF+"' AND " + QUEBRA

	If lQReinsp
		cQuery    += " QER.QER_FORNEC  = QEK.QEK_FORNEC AND " + QUEBRA
		cQuery    += " QER.QER_LOJFOR  = QEK.QEK_LOJFOR AND " + QUEBRA
		cQuery    += " QER.QER_PRODUT  = QEK.QEK_PRODUT AND " + QUEBRA
		cQuery    += " QER.QER_REVI  = QEK.QEK_REVI AND " + QUEBRA
		cQuery    += " QER.QER_DTENTR  = QEK.QEK_DTENTR AND " + QUEBRA
		cQuery    += " QER.QER_LOTE    = QEK.QEK_LOTE AND " + QUEBRA
		cQuery    += " QER.QER_PRODUT  = QEK.QEK_PRODUT AND " + QUEBRA
		//cQuery    += " QEK.QEK_NUMSEQ = '"+cNumSeq+"' AND " + QUEBRA
		cQuery    += " QEK.D_E_L_E_T_ <> '*' AND " + QUEBRA
	Endif
						
	cQuery    += "QER.D_E_L_E_T_ <> '*' " + QUEBRA
	cQuery    += "ORDER BY "+SqlOrder(QER->(IndexKey()))
	cQuery    := ChangeQuery(cQuery)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQER,.F.,.T.)
	For nPosCpo := 1 To Len(aStruQER)
		If aStruQER[nPosCpo,2]<>"C"
			TcSetField(cAliasQER,aStruQER[nPosCpo,1],aStruQER[nPosCpo,2],;
				aStruQER[nPosCpo,3],aStruQER[nPosCpo,4])
		EndIf
	Next nPosCpo
	DbSelectArea(cAliasQER)    

	IF !EOF()
		cForOri := (cAliasQER)->QER_FORNEC
		cLojOri := (cAliasQER)->QER_LOJFOR
		dDtdOri := (cAliasQER)->QER_DTENTR
		cNSOri  := (cAliasQER)->QER_NISERI
		cTpOri  := (cAliasQER)->QER_TIPONF
	ENDIF         
	
	While !Eof() //.And. (xFilial("QER")+cSeek) == &cSeekQER .AND. QER_DTENTR == dEntrada

		//??????????????????????????????
		//?Valores das medicoes 									 ?
		//??????????????????????????????
		cChvMed := QER_CHAVE
		aMed    := {}			 
		
		If cCarta <> "TXT"
			If cCarta == "P  "
				aMed := Afill(Array(4),0)     
				aMed[4] := " " //somente na quarta posicao
			EndIf
			QES->(dbSetOrder(1))
			QES->(MsSeek(cFilOri+cChvMed))
			While QES->(!Eof()) .And.	(QES->QES_FILIAL+QES->QES_CODMED) ==;
				(cFilOri+cChvMed)
				
				If cCarta <> "P  "
					Aadd(aMed,QES->QES_MEDICA)
				Else
					If QES->QES_INDMED == "A"
						aMed[1] := SuperVal(QES->QES_MEDICA)
					ElseIf QES->QES_INDMED == "N"
						aMed[2] := SuperVal(QES->QES_MEDICA)
						aMed[4] := "S"
					ElseIf QES->QES_INDMED == "P"
						aMed[3] := SuperVal(QES->QES_MEDICA)
					EndIf
				EndIf                    
				
				QES->(dbSkip())
			EndDo                                 
			If cCarta == "P  "
				If Empty(aMed[4])
					aMed[4] := "N"
					aMed[2] := 0
				Endif
			EndIf
		Else
			QEQ->(dbSetOrder(1))
			If QEQ->(MsSeek(cFilOri+cChvMed))
				Aadd(aMed, QEQ->QEQ_MEDICA)
			EndIf				
		EndIf

		// QUANDO NÃO ENCONTRO MEDIÇÕES
		IF LEN(aMed) == 0
			lResPar := .T.
			IF cCarta <> "TXT"
				If cCarta <> "P  "
					Aadd(aMed, "")
				Else
					aMed := Afill(Array(4),0)   
					aMed[1] := 0
					aMed[2] := 0
					aMed[4] := "N"
					aMed[3] := 0
				EndIf
			ELSE
				Aadd(aMed, "")
			ENDIF
		ELSE
			lResult := .T.
		ENDIF
        
        //??????????????????????????????
		//?Monta o array das medicoes 								 ?
		//??????????????????????????????
		Aadd(aMedicao,{})
		Aadd(aMedicao[Len(aMedicao)],QER_DTMEDI)                                 //Data medicao
		Aadd(aMedicao[Len(aMedicao)],QER_HRMEDI)                                 //Hora medicao
		Aadd(aMedicao[Len(aMedicao)],QER_AMOSTR)                                 //Amostra
		Aadd(aMedicao[Len(aMedicao)],QER_FILMAT)                                 //Filial da matricula
		Aadd(aMedicao[Len(aMedicao)],QER_ENSR)                                   //Codigo do ensaiador
		Aadd(aMedicao[Len(aMedicao)],QA_NUSR(QER_FILMAT,QER_ENSR,.F.,"A"))      //Nome do Ensaiador
		
		If cCarta == "TMP" //Campos para tratamento de ensaios do tipo: TEMPO
			Aadd(aMedicao[Len(aMedicao)],QER_DTINI)
			Aadd(aMedicao[Len(aMedicao)],QER_HRINI)
			Aadd(aMedicao[Len(aMedicao)],QER_DTFIM)
			Aadd(aMedicao[Len(aMedicao)],QER_HRFIM)
		EndIf

		Aeval(aMed,{|x|Aadd(aMedicao[Len(aMedicao)],x)})                        //Medicoes
		
		IF lResult
			Aadd(aMedicao[Len(aMedicao)],QER_RESULT)                             //Resultado
		ELSE
			Aadd(aMedicao[Len(aMedicao)],"")                             //Resultado
			lResPar := .T.
		ENDIF
		Aadd(aMedicao[Len(aMedicao)],QER_RASTRE)                                 //Rastreamento
		
		Aeval(aCpoUsu,{|x|Aadd(aMedicao[Len(aMedicao)],FieldGet(FieldPos(x)))}) //Campos Criados pelo usuario
		
			Aadd(aMedicao[Len(aMedicao)],QER_METODO)	                              //Metodo
			Aadd(aMedicao[Len(aMedicao)],QER_RVDOC)                                  //Revisao do Documento
	    
		Aadd(aMedicao[Len(aMedicao)],QER_CHAVE)	                                  //Chave de ligacao 

		Aadd(aMedicao[Len(aMedicao)],"QER")
		Aadd(aMedicao[Len(aMedicao)],IIf(lQuery,QERRECNO,QER->(RecNo())))
		Aadd(aMedicao[Len(aMedicao)],.F.)	                                	  //Marca de delecao
		
		dbSkip()
	EndDo
	
//	If lQuery
		dbSelectArea(cAliasQER)
		dbCloseArea()
//	EndIf
	
//EndIf     

//cFilAnt := cFilBkp

RestArea(aAreaQES)
RestArea(aAreaQEQ)
RestArea(aAreaQER)
RestArea(aAreaAnt)

Return(aMedicao)                      

Static Function Q215QtdMed(cEnsaio)
Local nQtdMed := 1  //Valor default

QE1->(dbSetOrder(1))
QE1->(MsSeek(xFilial("QE1")+cEnsaio))
If QE1->QE1_CARTA $ "XBR/XBS/XMR/HIS"
	nQtdMed	:= QE1->QE1_QTDE
ElseIf QE1->QE1_CARTA == "IND"
	nQtdMed	:= 1
ElseIf QE1->QE1_CARTA == "NP "
	nQtdMed	:= 1
ElseIf QE1->QE1_CARTA == "C  "
	nQtdMed	:= 1
ElseIf QE1->QE1_CARTA == "U  "
	nQtdMed	:= 2
ElseIf QE1->QE1_CARTA == "P  "
	nQtdMed	:= 3         
ElseIf QE1->QE1_CARTA == "TMP"	
	nQtdMEd := 1	
EndIf
Return(nQtdMed)

Static Function DaxFilLau(cFilOri, cFornece,cLoja,cProduto,dEntrada,cLote,cLabor,cNiseri,cTiNF,cNumSeq)
Local aLaudo	:= {}
Local cSeek		:= cFilOri+cFornece+cLoja+cProduto+cNiseri+cTiNF+Dtos(dEntrada)+cLote+cLabor
Local lQReinsp	:= QieReinsp()

//If lQReinsp
//	cSeek += cNumSeq
//Endif
IF LEN(ALLTRIM(cLote)) < 6 // Ajuste para padronizar o tamanho do campo Lote
    cLote   := PADL(ALLTRIM(QEK->QEK_LOTE), 6, '0')
	cLote   := PADR(cLote, TAMSX3("QEL_LOTE")[1], ' ')
	cSeek		:= cFilOri+cFornece+cLoja+cProduto+cNiseri+cTiNF+Dtos(dEntrada)+cLote+cLabor
ENDIF
//??????????????????????????????
//?Pesquisa o Laudo do laboratorio							 ?
//??????????????????????????????
dbSelectArea("QEL")
QEL->(dbClearFilter())
QEL->(dbGoTop())
QEL->(dbSetOrder(3))  // QEL_FILIAL, QEL_FORNEC, QEL_LOJFOR, QEL_PRODUT, QEL_NISERI, QEL_TIPONF, QEL_DTENTR, QEL_LOTE, QEL_LABOR, QEL_NUMSEQ, R_E_C_N_O_, D_E_L_E_T_     
IF QEL->(DbSeek(cSeek))
	aLaudo := DAXFilEnc("QEL",.T.)
ENDIF

Return(aLaudo)
                         
Static Function DaxQIPLau(cFilOri, cOp, cLote, cNiseri, cProduto, cRevi, cLabor )
LOCAL aLaudo	:= {}
LOCAL cAliasQPL := GetNextAlias()
LOCAL nRecQPL 	:= 0

IF LEN(ALLTRIM(cLote)) < 6 // Ajuste para padronizar o tamanho do campo Lote
    cLote   := PADL(ALLTRIM(QEK->QEK_LOTE), 6, '0')
	cLote   := PADR(cLote, TAMSX3("QPL_LOTE")[1], ' ')
	cSeek	:= cFilOri+cOp+cLote+cNiseri+cProduto+cRevi
ENDIF

BEGINSQL ALIAS cAliasQPL
    %noparser%
    SELECT	QPL.R_E_C_N_O_ AS POSICAO
	FROM	%Table:QPL% QPL (NOLOCK) 
	WHERE		QPL.QPL_FILIAL = %exp:cFilOri% 
			AND QPL.QPL_LOTE   = %exp:cLote% 
			AND QPL.QPL_LABOR  = %exp:cLabor% 
			AND QPL.%notdel%
ENDSQL

IF !(cAliasQPL)->(EOF())
	nRecQPL := (cAliasQPL)->POSICAO
ENDIF

//??????????????????????????????
//?Pesquisa o Laudo do laboratorio							 ?
//??????????????????????????????
DbSelectArea("QPL")
QPL->(DBClearFilter())
QPL->(DBGoTop())
QPL->(DBSetOrder(1)) 
IF  nRecQPL > 0
	QPL->( DBGOTO(nRecQPL) )
	aLaudo := DAXFilEnc("QPL",.T.)
ENDIF

IF  SELECT(cAliasQPL)
	DBCLOSEAREA(cAliasQPL)
ENDIF

Return(aLaudo)

Static Function DAXFilEnc(cAlias,lAchou)
Local aDados  := {}
Local aStruct := {}                                                      
Local nX	   := 0

//Pesquisa os campos em uso para edicao
aStruct := FWFORMSTRUCT(3,cAlias)[3]
FOR nX := 1 TO LEN(aStruct)
	IF cNivel >= GETSX3CACHE( aStruct[nX,1], "X3_NIVEL" )
		IF lAchou
			IF cAlias == "QPL"
				cCampo := aStruct[nX,1] // X3_CAMPO
				IF ALLTRIM(cCampo) == "QPL_DESLAU" //Preenche a descricao do Laudo
					aAdd( aDados, POSICIONE( "QPD", 1, XFILIAL("QPD")+QPL_LAUDO, "QPD_DESCPO" ) )
				ELSE
					IF GETSX3CACHE(cCampo, "X3_CONTEXT") == "V"
						aAdd( aDados, CRIAVAR( ALLTRIM(cCampo) ) )
					ELSE
						aAdd( aDados, &(cCampo) )
					ENDIF
				ENDIF
			ELSE
				IF ALLTRIM(aStruct[nX,1]) == "QEL_DESLAU" //Preenche a descricao do Laudo
					aAdd( aDados, QE215RDL( "QED", 1, XFILIAL("QED")+QEL_LAUDO ) )
				ELSEIF ALLTRIM(aStruct[nX,1]) == "QEL_TAMLOT"
					aAdd( aDados, IIF( EMPTY( QEL_TAMLOT ), QEK->QEK_TAMLOT, QEL_TAMLOT ) )
				ELSE
					IF GetSx3Cache(aStruct[nX,1],"X3_CONTEXT") == "V"
						aAdd( aDados, CRIAVAR( ALLTRIM(aStruct[nX,1]) ) )
					ELSE                 
						aAdd( aDados, &(aStruct[nX,1]) )                     
					ENDIF
				ENDIF
			ENDIF
		ELSE
			aAdd( aDados, CRIAVAR( ALLTRIM(aStruct[nX,1]) ) )
		ENDIF
	ENDIF
NEXT

Return(aDados)

Static Function	DAXQHMed(nPosLab,cEnsaio,cCarta,cFormul)
Local aHeaderTmp := {}
//Local aColsTmp   := {}
Local bHeadMed                    
Local nQtdMed    := 0     
Local nX         := 0
Local lMedicao	:= Iif(cCarta $ "IND" .AND. !Empty(cFormul) , ".F." , ".T." )

//????????????????????????????????
//?Numero de medicoes de acordo com a Carta do Ensaio			 ?
//????????????????????????????????	
nQtdMed	:= Q215QtdMed(cEnsaio)

//Campo Data da Medicao
Aadd(aHeaderTmp, DAXGetSX3("QER_DTMEDI","",""))

//Campo Hora da Medicao
Aadd(aHeaderTmp, DAXGetSX3("QER_HRMEDI","",""))

//Campo Amostragem
Aadd(aHeaderTmp, DAXGetSX3("QER_AMOSTR","",""))

//Campo Filial do Usuario
Aadd(aHeaderTmp, DAXGetSX3("QER_FILMAT","",""))

//Campo Ensaiador
Aadd(aHeaderTmp, DAXGetSX3("QER_ENSR","",""))

//Campo Nome do Ensaiador
Aadd(aHeaderTmp, DAXGetSX3("QER_ENSRNO","",""))

If cCarta <> "TXT"
	If cCarta <> "P  "
		//Campos das Medicoes Mensuraveis 
		If cCarta $ "XBR/XBS/XMR/IND/HIS"
			For nX := 1 to nQtdMed 
				Aadd(aHeaderTmp, DAXGetSX3("QES_MEDICA","Medicao"+StrZero(nX,2),lMedicao))
			Next nX

		ElseIf cCarta == "U  "
			Aadd(aHeaderTmp, DAXGetSX3("QES_MEDICA","Amostra",".T.")) //"Amostra"
			Aadd(aHeaderTmp, DAXGetSX3("QES_MEDICA","Nao Conf. p/ Unid.",".T.")) //"Nao Conf. p/ Unid."

		ElseIf cCarta == "NP "
			Aadd(aHeaderTmp, DAXGetSX3("QES_MEDICA","Nao Conformes",".T.")) //"Nao Conformes"

		ElseIf cCarta == "C  "
			Aadd(aHeaderTmp, DAXGetSX3("QES_MEDICA","",".T.")) //"Nao Conformidades"

		ElseIf cCarta == "TMP"  
			Aadd(aHeaderTmp, DAXGetSX3("QER_DTINI","Data Inicial",".T.")) //"Data Inicial"
			Aadd(aHeaderTmp, DAXGetSX3("QER_HRINI","Hora Inicial",".T.")) //"Hora Inicial"			
			Aadd(aHeaderTmp, DAXGetSX3("QER_DTFIM","Data Final",".T.")) //"Data Final"
			Aadd(aHeaderTmp, DAXGetSX3("QER_HRFIM","Hora Final",".T.")) //"Hora Final"
			Aadd(aHeaderTmp, DAXGetSX3("QES_MEDICA","Medicao"+"01",".T.")) //"Medicao"

		EndIf
	Else
		//Campo Amostra
		Aadd(aHeaderTmp, DAXGetSX3("QES_MEDIPA","",""))

		//Campo Unidades Nao Conforme
		Aadd(aHeaderTmp, DAXGetSX3("QES_MEDIPN","",""))

		//Campo Porcentagem Nao Conforme
		Aadd(aHeaderTmp, DAXGetSX3("QES_MEDIPP","",""))

		//Campo de Calculo da Porcentagem Automaticamente
		Aadd(aHeaderTmp, DAXGetSX3("QES_CALPOR","",""))

	EndIf
Else
	//Campo Medicao 
	Aadd(aHeaderTmp, DAXGetSX3("QEQ_MEDICA","Texto",".T.")) //"Texto"

EndIf

//????????????????????????????????
//?Insere o campo do Resultado da Medicao						 ?
//????????????????????????????????	
If cCarta <> "TXT"
	Aadd(aHeaderTmp, DAXGetSX3("QER_RESULT","",""))
	
Else
	Aadd(aHeaderTmp, DAXGetSX3("QEQ_RESULT","",""))

EndIf
//????????????????????????????????
//?Adiciona Campo da Rastreabilidade.   						 ?
//????????????????????????????????	
Aadd(aHeaderTmp, DAXGetSX3("QER_RASTRE","",""))

//????????????????????????????????
//?Adiciona os campos criados pelo Usuario						 ?
//????????????????????????????????	
Q215FilCpo("QER",bHeadMed,@aHeaderTmp,@aCpoUsu,@aCpoQry)  

//Campo Metodo
Aadd(aHeaderTmp, DAXGetSX3("QER_METODO","",""))

//Campo Revisao do Documento
Aadd(aHeaderTmp, DAXGetSX3("QER_RVDOC","",""))

//Campo Chave da medicao
Aadd(aHeaderTmp, DAXGetSX3("QER_CHAVE","","")) 

// Inclui coluna de registro atraves de funcao generica
ADHeadRec("QER",aHeaderTmp)

//Armazena o aHeader de acordo com a Carta do Ensaio
//Aadd(aSavHeadEns[nPosLab],aClone(aHeaderTmp))

Return(aHeaderTmp)

Static Function DAXGetSX3(cCampo, cTitulo, cWhen)
Local aHeaderTmp := {}
aHeaderTmp:= {IIf(Empty(cTitulo), QAGetX3Tit(cCampo), cTitulo),;
              GetSx3Cache(cCampo,'X3_CAMPO'),;
              GetSx3Cache(cCampo,'X3_PICTURE'),;
              GetSx3Cache(cCampo,'X3_TAMANHO'),;
              GetSx3Cache(cCampo,'X3_DECIMAL'),;
              GetSx3Cache(cCampo,'X3_VALID'),;              
              GetSx3Cache(cCampo,'X3_USADO'),;
              GetSx3Cache(cCampo,'X3_TIPO'),;
              GetSx3Cache(cCampo,'X3_F3'),;
              GetSx3Cache(cCampo,'X3_CONTEXT'),;
              QAGetX3Cmb(cCampo),;
              GetSx3Cache(cCampo,'X3_RELACAO'),;
              IIf(Empty(cWhen), GetSx3Cache(cCampo, 'X3_WHEN'), cWhen) }
Return aHeaderTmp

Static Function QIEAtuLab( cLabor, nPosLdo, aResultados, lLauGer, lResPar )
Local nPosEnc
Local cHistorico := " "
Local nCpo 
Local cSeek      := ""        
Local lQReinsp	 := QieReinsp()
Local aStruct 	 := FWFormStruct(3,"QEL")[3]
Local nPosLaudo  := aScan(aStruct,{|x|AllTrim(x[1])=="QEL_LAUDO"})
Local nPosDtEnLa := aScan(aStruct,{|x|AllTrim(x[1])=="QEL_DTENLA"})
Local nPosHrEnLa := aScan(aStruct,{|x|AllTrim(x[1])=="QEL_HRENLA"})
Local nPosTamLot := aScan(aStruct,{|x|AllTrim(x[1])=="QEL_TAMLOT"})
Local nPosDtaLau := aScan(aStruct,{|x|AllTrim(x[1])=="QEL_DTLAUD"})
Local nPosHraLau := aScan(aStruct,{|x|AllTrim(x[1])=="QEL_HRLAUD"})
Local nPosValLau := aScan(aStruct,{|x|AllTrim(x[1])=="QEL_DTVAL"})
Local nPosQtdRej := aScan(aStruct,{|x|AllTrim(x[1])=="QEL_QTREJ"})
Local nPosDtaLau := aScan(aStruct,{|x|AllTrim(x[1])=="QEL_DTLAUD"}) 
Local nPosQtdDes := aScan(aStruct,{|x|AllTrim(x[1])=="QEL_QTDEST"})
Local nPosQtdApr := aScan(aStruct,{|x|AllTrim(x[1])=="QEL_QTDAPR"})  

IF lCosEns
	IF lResPar
		RETURN NIL
	ENDIF
ENDIF

If lLauGer 
	nPosEnc := 1 //posicao do Laudo Geral da Entrada 
Else	
	nPosEnc := _LAU //posicao do Laudo do Laboratorio
EndIf

IF LEN(aResultados[ nPosLdo, nPosEnc ]) < nPosQtdRej
	RETURN NIL
ENDIF

dbSelectArea("QEL")
cNiseri	:= QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF
dbSetOrder(3)
cSeek	:= QEK->(QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT)+cNiseri+(QEK->(QEK_TIPONF+DtOS(QEK_DTENTR)+QEK_LOTE))+cLabor

If lQReinsp
	cSeek += QEK->QEK_NUMSEQ
Endif	

If !MsSeek(xFilial("QEL")+cSeek,.F.)
	RecLock("QEL",.T.)   

	QEL->QEL_FILIAL	:= xFilial("QEL")
	QEL->QEL_FORNEC	:= QEK->QEK_FORNEC
	QEL->QEL_LOJFOR	:= QEK->QEK_LOJFOR
	QEL->QEL_PRODUT	:= QEK->QEK_PRODUT
	QEL->QEL_DTENTR	:= QEK->QEK_DTENTR
	QEL->QEL_LOTE	:= QEK->QEK_LOTE
	QEL->QEL_LABOR	:= cLabor
	QEL->QEL_REVI	:= QEK->QEK_REVI
	QEL->QEL_NISERI	:= QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF
	QEL->QEL_TIPONF	:= QEK->QEK_TIPONF

	IF lQReinsp
		QEL->QEL_NUMSEQ := QEK->QEK_NUMSEQ
	ENDIF	
	
	IF nPosDtaLau > 0
		QEL->QEL_DTLAUD := aResultados[ nPosLdo, nPosEnc, nPosDtaLau ] 
	ENDIF
	IF nPosHraLau > 0
		QEL->QEL_HRLAUD := aResultados[ nPosLdo, nPosEnc, nPosHraLau ] 
	ENDIF
	IF nPosLaudo > 0
		QEL->QEL_LAUDO  := aResultados[ nPosLdo, nPosEnc, nPosLaudo ] 
	ENDIF
	IF nPosDtEnLa > 0
		QEL->QEL_DTENLA := aResultados[ nPosLdo, nPosEnc, nPosDtEnLa ] 
	ENDIF
	IF nPosHrEnLa > 0
		QEL->QEL_HRENLA := aResultados[ nPosLdo, nPosEnc, nPosHrEnLa ] 
	ENDIF
	IF nPosTamLot > 0
		QEL->QEL_TAMLOT := aResultados[ nPosLdo, nPosEnc, nPosTamLot ] 
	ENDIF
	IF nPosValLau > 0
		QEL->QEL_DTVAL  := aResultados[ nPosLdo, nPosEnc, nPosValLau ] 
	ENDIF
	IF nPosQtdRej > 0
		QEL->QEL_QTREJ  := aResultados[ nPosLdo, nPosEnc, nPosQtdRej ]
	ENDIF
	IF nPosQtdDes > 0	
		QEL->QEL_QTDEST := aResultados[ nPosLdo, nPosEnc, nPosQtdDes ]
	ENDIF
	IF nPosDtaLau > 0
		QEL->QEL_DTLAUD := aResultados[ nPosLdo, nPosEnc, nPosDtaLau]
	ENDIF
	IF nPosQtdApr > 0
		QEL->QEL_QTDAPR := aResultados[ nPosLdo, nPosEnc, nPosQtdApr]
	ENDIF
	MsUnLock()        

EndIf
   
Return(NIL)

Static Function QIPAtuLab( cLabor, nPosLdo, aResultados, lLauGer, lResPar )
LOCAL nPosEnc
LOCAL cHistorico := " "
LOCAL nCpo 
LOCAL cSeek      := ""        
LOCAL lQReinsp	 := QieReinsp()
LOCAL aStruct 	 := FWFormStruct(3,"QEL")[3]
LOCAL nPosLaudo  := aScan(aStruct,{|x|AllTrim(x[1])=="QEL_LAUDO"})
LOCAL nPosDtEnLa := aScan(aStruct,{|x|AllTrim(x[1])=="QEL_DTENLA"})
LOCAL nPosHrEnLa := aScan(aStruct,{|x|AllTrim(x[1])=="QEL_HRENLA"})
LOCAL nPosTamLot := aScan(aStruct,{|x|AllTrim(x[1])=="QEL_TAMLOT"})
LOCAL nPosDtaLau := aScan(aStruct,{|x|AllTrim(x[1])=="QEL_DTLAUD"})
LOCAL nPosHraLau := aScan(aStruct,{|x|AllTrim(x[1])=="QEL_HRLAUD"})
LOCAL nPosValLau := aScan(aStruct,{|x|AllTrim(x[1])=="QEL_DTVAL"})
LOCAL nPosQtdRej := aScan(aStruct,{|x|AllTrim(x[1])=="QEL_QTREJ"})
LOCAL nPosDtaLau := aScan(aStruct,{|x|AllTrim(x[1])=="QEL_DTLAUD"}) 
LOCAL nPosQtdDes := aScan(aStruct,{|x|AllTrim(x[1])=="QEL_QTDEST"})
LOCAL nPosQtdApr := aScan(aStruct,{|x|AllTrim(x[1])=="QEL_QTDAPR"})  

IF lCosEns
	IF lResPar
		RETURN NIL
	ENDIF
ENDIF

If lLauGer 
	nPosEnc := 1 //posicao do Laudo Geral da Entrada 
Else	
	nPosEnc := _LAU //posicao do Laudo do Laboratorio
EndIf

dbSelectArea("QEL")
cNiseri	:= QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF
dbSetOrder(3)
cSeek	:= QEK->(QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT)+cNiseri+(QEK->(QEK_TIPONF+DtOS(QEK_DTENTR)+QEK_LOTE))+cLabor

If lQReinsp
	cSeek += QEK->QEK_NUMSEQ
Endif	

If !MsSeek(xFilial("QEL")+cSeek,.F.)
	RecLock("QEL",.T.)   

	QEL->QEL_FILIAL	:= xFilial("QEL")
	QEL->QEL_FORNEC	:= QEK->QEK_FORNEC
	QEL->QEL_LOJFOR	:= QEK->QEK_LOJFOR
	QEL->QEL_PRODUT	:= QEK->QEK_PRODUT
	QEL->QEL_DTENTR	:= QEK->QEK_DTENTR
	QEL->QEL_LOTE	:= QEK->QEK_LOTE
	QEL->QEL_LABOR	:= cLabor
	QEL->QEL_REVI	:= QEK->QEK_REVI
	QEL->QEL_NISERI	:= QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF
	QEL->QEL_TIPONF	:= QEK->QEK_TIPONF

	IF lQReinsp
		QEL->QEL_NUMSEQ := QEK->QEK_NUMSEQ
	ENDIF	
	
	IF nPosDtaLau > 0
		QEL->QEL_DTLAUD := aResultados[ nPosLdo, nPosEnc, nPosDtaLau ] 
	ENDIF
	IF nPosHraLau > 0
		QEL->QEL_HRLAUD := aResultados[ nPosLdo, nPosEnc, nPosHraLau ] 
	ENDIF
	IF nPosLaudo > 0
		QEL->QEL_LAUDO  := aResultados[ nPosLdo, nPosEnc, nPosLaudo ] 
	ENDIF
	IF nPosDtEnLa > 0
		QEL->QEL_DTENLA := aResultados[ nPosLdo, nPosEnc, nPosDtEnLa ] 
	ENDIF
	IF nPosHrEnLa > 0
		QEL->QEL_HRENLA := aResultados[ nPosLdo, nPosEnc, nPosHrEnLa ] 
	ENDIF
	IF nPosTamLot > 0
		IF valtype(aResultados[ nPosLdo, nPosEnc, nPosTamLot ]) == "N"
			QEL->QEL_TAMLOT := ALLTRIM(STR(aResultados[ nPosLdo, nPosEnc, nPosTamLot ] ))
		ELSE
			QEL->QEL_TAMLOT := aResultados[ nPosLdo, nPosEnc, nPosTamLot ] 
		ENDIF
	ENDIF
	IF nPosValLau > 0
		QEL->QEL_DTVAL  := aResultados[ nPosLdo, nPosEnc, nPosValLau ] 
	ENDIF
	IF nPosQtdRej > 0
		QEL->QEL_QTREJ  := aResultados[ nPosLdo, nPosEnc, nPosQtdRej ]
	ENDIF
	IF nPosQtdDes > 0	
		QEL->QEL_QTDEST := aResultados[ nPosLdo, nPosEnc, nPosQtdDes ]
	ENDIF
	IF nPosDtaLau > 0
		QEL->QEL_DTLAUD := aResultados[ nPosLdo, nPosEnc, nPosDtaLau]
	ENDIF
	IF nPosQtdApr > 0
		QEL->QEL_QTDAPR := aResultados[ nPosLdo, nPosEnc, nPosQtdApr]
	ENDIF
	MsUnLock()        

EndIf
   
Return(NIL)


STATIC FUNCTION QipDePara( cProd )
//Retorna a ultima revisao do Produto
LOCAL cRevQIP  := QA_UltRevEsp( cProd, , , , "QIP" )
LOCAL cAliDePa := GetNextAlias()
LOCAL aDados   := {}

// SÓ CARREGO OS  DADOS SE OS  ENSAIOS DE-PARA FOREM DO MESMO TIPO
BEGINSQL ALIAS cAliDePa

	SELECT QP7_ENSAIO AS COD_ENSAIO, QP1_CARTA, QP1_DESCPO, QP1_ENSQIR ENSAIO_REL, QE1.QE1_CARTA, QE1_DESCPO
	FROM %Table:QP7% QP7 (NOLOCK)
	LEFT JOIN %Table:QP1% QP1 (NOLOCK) ON 		QP1.QP1_ENSAIO = QP7.QP7_ENSAIO 
											AND QP1.%notdel%
	LEFT JOIN %Table:QE1% QE1 (NOLOCK) ON 		QE1.QE1_ENSAIO = QP1.QP1_ENSQIR 
											AND QE1.%notdel%
	WHERE 		QP7.QP7_FILIAL =  %xFilial:QP7% 
			AND	QP7.QP7_PRODUT =  %exp:cProd%
			AND QP7.QP7_REVI   =  %exp:cRevQIP% 
			AND QP1.QP1_ENSQIR <> ''
			AND QP7.%notdel%
	UNION
	SELECT QP7_ENSAIO AS COD_ENSAIO, QP1_CARTA, QP1_DESCPO, QP1_ENSQI2 ENSAIO_REL, QE1.QE1_CARTA, QE1_DESCPO
	FROM %Table:QP7% QP7 (NOLOCK)
	LEFT JOIN %Table:QP1% QP1 (NOLOCK) ON 		QP1.QP1_ENSAIO = QP7.QP7_ENSAIO 
											AND QP1.%notdel%
	LEFT JOIN %Table:QE1% QE1 (NOLOCK) ON 		QE1.QE1_ENSAIO = QP1.QP1_ENSQI2 
											AND QE1.%notdel%
	WHERE 		QP7.QP7_FILIAL =  %xFilial:QP7% 
			AND	QP7.QP7_PRODUT =  %exp:cProd%
			AND QP7.QP7_REVI   =  %exp:cRevQIP% 
			AND QP1.QP1_ENSQIR <> ''
			AND QP7.%notdel%
	UNION
	SELECT QP7_ENSAIO AS COD_ENSAIO, QP1_CARTA, QP1_DESCPO, QP1_ENSQI3 ENSAIO_REL, QE1.QE1_CARTA, QE1_DESCPO
	FROM %Table:QP7% QP7 (NOLOCK)
	LEFT JOIN %Table:QP1% QP1 (NOLOCK) ON 		QP1.QP1_ENSAIO = QP7.QP7_ENSAIO 
											AND QP1.%notdel%
	LEFT JOIN %Table:QE1% QE1 (NOLOCK) ON 		QE1.QE1_ENSAIO = QP1.QP1_ENSQI3 
											AND QE1.%notdel%
	WHERE 		QP7.QP7_FILIAL =  %xFilial:QP7% 
			AND	QP7.QP7_PRODUT =  %exp:cProd%
			AND QP7.QP7_REVI   =  %exp:cRevQIP% 
			AND QP1.QP1_ENSQIR <> ''
			AND QP7.%notdel%
	UNION
	SELECT QP7_ENSAIO AS COD_ENSAIO, QP1_CARTA, QP1_DESCPO, QP1_ENSQI4 ENSAIO_REL, QE1.QE1_CARTA, QE1_DESCPO
	FROM %Table:QP7% QP7 (NOLOCK)
	LEFT JOIN %Table:QP1% QP1 (NOLOCK) ON 		QP1.QP1_ENSAIO = QP7.QP7_ENSAIO 
											AND QP1.%notdel%
	LEFT JOIN %Table:QE1% QE1 (NOLOCK) ON 		QE1.QE1_ENSAIO = QP1.QP1_ENSQI4 
											AND QE1.%notdel%
	WHERE 		QP7.QP7_FILIAL =  %xFilial:QP7% 
			AND	QP7.QP7_PRODUT =  %exp:cProd%
			AND QP7.QP7_REVI   =  %exp:cRevQIP% 
			AND QP1.QP1_ENSQIR <> ''
			AND QP7.%notdel%
	UNION
	SELECT QP7_ENSAIO AS COD_ENSAIO, QP1_CARTA, QP1_DESCPO, QP1_ENSQI5 ENSAIO_REL, QE1.QE1_CARTA, QE1_DESCPO
	FROM %Table:QP7% QP7 (NOLOCK)
	LEFT JOIN %Table:QP1% QP1 (NOLOCK) ON 		QP1.QP1_ENSAIO = QP7.QP7_ENSAIO 
											AND QP1.%notdel%
	LEFT JOIN %Table:QE1% QE1 (NOLOCK) ON 		QE1.QE1_ENSAIO = QP1.QP1_ENSQI5 
											AND QE1.%notdel%
	WHERE 		QP7.QP7_FILIAL =  %xFilial:QP7% 
			AND	QP7.QP7_PRODUT =  %exp:cProd%
			AND QP7.QP7_REVI   =  %exp:cRevQIP% 
			AND QP1.QP1_ENSQIR <> ''
			AND QP7.%notdel%
	UNION
	SELECT QP8_ENSAIO AS COD_ENSAIO, QP1_CARTA, QP1_DESCPO, QP1_ENSQIR ENSAIO_REL, QE1.QE1_CARTA, QE1_DESCPO
	FROM %Table:QP8% QP8 (NOLOCK)
	LEFT JOIN %Table:QP1% QP1 (NOLOCK) ON 		QP1.QP1_ENSAIO = QP8.QP8_ENSAIO 
											AND QP1.%notdel%
	LEFT JOIN %Table:QE1% QE1 (NOLOCK) ON 		QE1.QE1_ENSAIO = QP1.QP1_ENSQIR 
											AND QE1.%notdel%
	WHERE 		QP8.QP8_FILIAL =  %xFilial:QP8% 
			AND	QP8.QP8_PRODUT =  %exp:cProd%
			AND QP8.QP8_REVI   =  %exp:cRevQIP%
			AND QP1.QP1_ENSQIR <> ''
			AND QP8.%notdel%
	UNION
	SELECT QP8_ENSAIO AS COD_ENSAIO, QP1_CARTA, QP1_DESCPO, QP1_ENSQI2 ENSAIO_REL, QE1.QE1_CARTA, QE1_DESCPO
	FROM %Table:QP8% QP8 (NOLOCK)
	LEFT JOIN %Table:QP1% QP1 (NOLOCK) ON 		QP1.QP1_ENSAIO = QP8.QP8_ENSAIO 
											AND QP1.%notdel%
	LEFT JOIN %Table:QE1% QE1 (NOLOCK) ON 		QE1.QE1_ENSAIO = QP1.QP1_ENSQI2 
											AND QE1.%notdel%
	WHERE 		QP8.QP8_FILIAL =  %xFilial:QP8% 
			AND	QP8.QP8_PRODUT =  %exp:cProd%
			AND QP8.QP8_REVI   =  %exp:cRevQIP%
			AND QP1.QP1_ENSQIR <> ''
			AND QP8.%notdel%
	UNION
	SELECT QP8_ENSAIO AS COD_ENSAIO, QP1_CARTA, QP1_DESCPO, QP1_ENSQI3 ENSAIO_REL, QE1.QE1_CARTA, QE1_DESCPO
	FROM %Table:QP8% QP8 (NOLOCK)
	LEFT JOIN %Table:QP1% QP1 (NOLOCK) ON 		QP1.QP1_ENSAIO = QP8.QP8_ENSAIO 
											AND QP1.%notdel%
	LEFT JOIN %Table:QE1% QE1 (NOLOCK) ON 		QE1.QE1_ENSAIO = QP1.QP1_ENSQI3 
											AND QE1.%notdel%
	WHERE 		QP8.QP8_FILIAL =  %xFilial:QP8% 
			AND	QP8.QP8_PRODUT =  %exp:cProd%
			AND QP8.QP8_REVI   =  %exp:cRevQIP%
			AND QP1.QP1_ENSQIR <> ''
			AND QP8.%notdel%
	UNION
	SELECT QP8_ENSAIO AS COD_ENSAIO, QP1_CARTA, QP1_DESCPO, QP1_ENSQI4 ENSAIO_REL, QE1.QE1_CARTA, QE1_DESCPO
	FROM %Table:QP8% QP8 (NOLOCK)
	LEFT JOIN %Table:QP1% QP1 (NOLOCK) ON 		QP1.QP1_ENSAIO = QP8.QP8_ENSAIO 
											AND QP1.%notdel%
	LEFT JOIN %Table:QE1% QE1 (NOLOCK) ON 		QE1.QE1_ENSAIO = QP1.QP1_ENSQI4 
											AND QE1.%notdel%
	WHERE 		QP8.QP8_FILIAL =  %xFilial:QP8% 
			AND	QP8.QP8_PRODUT =  %exp:cProd%
			AND QP8.QP8_REVI   =  %exp:cRevQIP%
			AND QP1.QP1_ENSQIR <> ''
			AND QP8.%notdel%
	UNION
	SELECT QP8_ENSAIO AS COD_ENSAIO, QP1_CARTA, QP1_DESCPO, QP1_ENSQI5 ENSAIO_REL, QE1.QE1_CARTA, QE1_DESCPO
	FROM %Table:QP8% QP8 (NOLOCK)
	LEFT JOIN %Table:QP1% QP1 (NOLOCK) ON 		QP1.QP1_ENSAIO = QP8.QP8_ENSAIO 
											AND QP1.%notdel%
	LEFT JOIN %Table:QE1% QE1 (NOLOCK) ON 		QE1.QE1_ENSAIO = QP1.QP1_ENSQI5 
											AND QE1.%notdel%
	WHERE 		QP8.QP8_FILIAL =  %xFilial:QP8% 
			AND	QP8.QP8_PRODUT =  %exp:cProd%
			AND QP8.QP8_REVI   =  %exp:cRevQIP%
			AND QP1.QP1_ENSQIR <> ''
			AND QP8.%notdel%
ENDSQL

WHILE !(cAliDePa)->(Eof())
	IF  ALLTRIM((cAliDePa)->QP1_CARTA) == ALLTRIM((cAliDePa)->QE1_CARTA)
		Aadd( aDados,{ (cAliDePa)->COD_ENSAIO, (cAliDePa)->ENSAIO_REL } )
	ENDIF
    (cAliDePa)->(DbSkip())
ENDDO

(cAliDePa)->(DBCloseArea())

RETURN aDados


USER FUNCTION QipMedRs( cFilOri, cProduto, cRevisao, aResultados, cOP, cLote, aDePara, lResPar )

LOCAL aAreaAnt      := GetArea()
LOCAL aAreaQE7      := QE7->(GetArea())
LOCAL aAreaQE8      := QE8->(GetArea())
LOCAL nPosLab		:= 0
LOCAL nPosEns		:= 0
LOCAL cFilQE7 	    := IIF ( EMPTY(ALLTRIM(xFilial("QE7"))),  xFilial("QE7"), IIF( xFilial("QE7") == "01  ", xFilial("QE7"), cFilOri) )
LOCAL cFilQE8 	    := IIF ( EMPTY(ALLTRIM(xFilial("QE8"))),  xFilial("QE8"), IIF( xFilial("QE8") == "01  ", xFilial("QE8"), cFilOri) )
LOCAL aTitPag 	    := {}
LOCAL lFilLab       := .T.
LOCAL nX            := 0
LOCAL nPEnsQIP      := 0
LOCAL lResult		:= .F.

IF LEN(ALLTRIM(cLote)) < 6 // Ajuste para padronizar o tamanho do campo Lote
    cLote   := PADL(ALLTRIM(QEK->QEK_LOTE), 6, '0')
	cLote   := PADR(cLote, TAMSX3("QEL_LOTE")[1], ' ')
ENDIF
cNiseri  		:= QPK->QPK_NUMSER

dbSelectArea("QE6")
dbSetOrder(1)                               
MsSeek(xFilial("QE6")+cProduto+Inverte(cRevisao))

QE7->(dbSetOrder(4))
IF QE7->(MsSeek(cFilQE7+cProduto+cRevisao))
	WHILE QE7->(!Eof()) .And. (QE7->QE7_FILIAL+QE7->QE7_PRODUT+QE7->QE7_REVI) ==;
		(cFilQE7+cProduto+cRevisao)
		
		//Preenche o aResultados com o Laboratorio
		IF Ascan(aResultados,{|x|x[_LAB]==QE7->QE7_LABOR}) == 0
		
			Aadd( aTitPag,{ Upper(QE7->QE7_LABOR), Upper(QE7->QE7_LABOR) } )
		
			Aadd(aResultados,{QE7->QE7_LABOR,{},{},{},{},{},{},{}})
		
		ENDIF
		
		nPosLab := Ascan(aResultados,{|x|x[_LAB]==QE7->QE7_LABOR})
		IF (nPosLab > 0)
			//cNiseri := QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF
			
            //Verifica o Skip-Teste definido para o Ensaio
			cSkpTst := QieSkpTst(QEK->QEK_FORNEC,QEK->QEK_LOJFOR,QEK->QEK_PRODUT,QE7->QE7_ENSAIO,QEK->QEK_DTENTR,QEK->QEK_LOTE,,cNiseri,QEK->QEK_TIPONF)
		    
			QE1->(dbSetOrder(1))
			IF QE1->(MsSeek(xFilial("QE1")+QE7->QE7_ENSAIO))		

				//Verifica se o Metodo associado a especificacao esta preenchido
				IF !Empty(QE7->QE7_METODO)
					cMetodo := QE7->QE7_METODO
					cRevDoc := QE7->QE7_REVDOC
				ELSE 
					cMetodo := QE1->QE1_METODO					
					cRevDoc := ' '	
				ENDIF
					
				//Formata a Formula do Ensaio, caso a mesma esteja definida para o Ensaio 
				cFormula := StrTran(QE7->QE7_FORMUL,"#","")
				IF Empty(cFormula) .And. QE1->QE1_TIPO == "1"
					cFormula := OemToAnsi("O Ensaio e do Tipo Calculado, mas nao possui formula associada")
				ENDIF
			
				//Armazena os Ensaios por Laboratorio no vetor aResultados                                       
				Aadd(aResultados[nPosLab,_ENS],{QE7->QE7_SEQLAB,QE7->QE7_ENSAIO,QE1->QE1_DESCPO,QE1->QE1_CARTA,IIF(QE7->QE7_MINMAX=="3","<<<",QE7->QE7_LIE),;
					QE7->QE7_NOMINA,If(QE7->QE7_MINMAX=="2",">>>",QE7->QE7_LSE),'',Q215QtdMed(QE7->QE7_ENSAIO),cSkpTst,cMetodo,QA_ULTRVDC(cMetodo,dDataBase,.f.,.f.),cFormula,QE1->QE1_DESCIN,QE1->QE1_DESCES})
			
				//Cria a dimensao para os anexos associados aos ensaios
				Aadd(aResultados[nPosLab,_ANE],{})
				
			ENDIF
		ENDIF

		QE7->(dbSkip())	
	ENDDO		
ENDIF

QE8->(dbSetOrder(4))
IF QE8->(MsSeek(cFilQE8+cProduto+cRevisao))
	WHILE QE8->(!Eof()) .And. (QE8->QE8_FILIAL+QE8->QE8_PRODUT+QE8->QE8_REVI) ==;
		(cFilQE8+cProduto+cRevisao)

		//Preenche o aResultados com o Laboratorio
		IF Ascan(aResultados,{|x|x[_LAB]==QE8->QE8_LABOR}) == 0
		
			Aadd( aTitPag,{ Upper(QE8->QE8_LABOR), Upper(QE8->QE8_LABOR) } )
					
			Aadd(aResultados,{QE8->QE8_LABOR,{},{},{},{},{},{},{}})

		ENDIF
		
		//Preenche o aResultados com os Ensaios Vinculados ao Laboratorio
		nPosLab := Ascan(aResultados,{|x|x[_LAB]==QE8->QE8_LABOR})
		IF (nPosLab > 0)
		//	cNiseri := QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF
		    
            //Verifica o Skip-Teste definido para o Ensaio
			cSkpTst := QieSkpTst(QEK->QEK_FORNEC,QEK->QEK_LOJFOR,QEK->QEK_PRODUT,QE8->QE8_ENSAIO,QEK->QEK_DTENTR,QEK->QEK_LOTE,,cNiseri,QEK->QEK_TIPONF)
		    
			QE1->(dbSetOrder(1))
			IF QE1->(MsSeek(xFilial("QE1")+QE8->QE8_ENSAIO))	
				//Verifica se o Metodo associado a especificacao esta preenchido
				IF !Empty(QE8->QE8_METODO)
					cMetodo := QE8->QE8_METODO
					cRevDoc := QE8->QE8_REVDOC
				ELSE 
					cMetodo := QE1->QE1_METODO					
					cRevDoc := ' '	
				ENDIF

				//Armazena os Ensaios por Laboratorio no vetor aResultados                                       
				Aadd(aResultados[nPosLab,_ENS],{QE8->QE8_SEQLAB,QE8->QE8_ENSAIO,QE1->QE1_DESCPO,QE1->QE1_CARTA,;
					OemToAnsi("N/A"),OemToAnsi("N/A"),OemToAnsi("N/A"),QE8->QE8_TEXTO,Q215QtdMed(QE8->QE8_ENSAIO),;
					cSkpTst,cMetodo,QA_ULTRVDC(cMetodo,dDataBase,.f.,.f.),OemToAnsi("Nao ha Formula definida"),QE1->QE1_DESCIN,QE1->QE1_DESCES}) 
					
				//Cria a dimensao para os anexos associados aos ensaios
				Aadd(aResultados[nPosLab,_ANE],{})
				
			ENDIF				
		
		ENDIF
		
		
		QE8->(dbSkip())	
	ENDDO		
ENDIF

//Ordena a descricao dos Laboratorios nos Folders
aSort(aTitPag,,,{|x,y|x[2]<y[2]})

//Ordena os Laboratorios 
aSort(aResultados,,,{|x,y|x[1]<y[1]})

//Ordena a Sequencia dos Ensaios por Laboratorio
Aeval(aResultados,{|x,y|aSort(aResultados[y,_ENS],,,{|z,w|z[1]<w[1]})})

//??????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
//? Associacao das Medicoes, Nao-conformidades, Cronicas e Instrumentos ao Vetor aResultados, para edicao dos mesmos.      ?
//??????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
cForOri := ""
cLojOri := ""
dDtdOri := STOD("  /  /    ")
cNSOri := ""
cTpOri := ""

FOR nPosLab := 1 TO Len(aResultados)

	FOR nPosEns := 1 TO Len(aResultados[nPosLab,_ENS])
							
		//Cria a posicao para as medicoes referentes ao ensaio		
		Aadd(aResultados[nPosLab,_MED],{})
		nPEnsQIP := aScan( aDePara, { | x | ALLTRIM(x[2]) == ALLTRIM(aResultados[nPosLab,_ENS,nPosEns,ENSAIO]) } )
		cEnsQIP := ""
		IF nPEnsQIP > 0
			cEnsQIP := aDePara[nPEnsQIP][1]
		ENDIF
		aColsEns := DAXQipMed(cFilOri, cProduto, cRevisao, cLote, aResultados[nPosLab,_LAB], aResultados[nPosLab,_ENS,nPosEns,ENSAIO],aResultados[nPosLab,_ENS,nPosEns,CARTA], cOP, aDePara, cEnsQIP, @lResult, @lResPar )
		IF Len(aColsEns) == 0
			aColsEns  := aClone({})	
		ENDIF

        aResultados[nPosLab,_MED,Len(aResultados[nPosLab,_MED])] := aClone(aColsEns)

        // Cria a posicao para as nao-conformidades
		Aadd(aResultados[nPosLab,_NCO],Array(Len(aColsEns)))                                                
						
		// Cria a posicao para as cronicas
		Aadd(aResultados[nPosLab,_CRO],Array(Len(aColsEns))) 

        // Armazena o Plano de Amostragem associado ao Ensaio corrente
		Aadd(aResultados[nPosLab,_PAE],{})

        Aadd(aResultados[nPosLab,_INS],Array(Len(aColsEns))) 
	
	NEXT 

NEXT

nQtdLab := Len(aResultados) //Quantidade de Laboratorios

aStruct := FWFormStruct(3,"QEL")[3]
nPosLaudo  := Ascan(aStruct,{|x|AllTrim(x[1])=="QEL_LAUDO"})
nPosDtEnLa := Ascan(aStruct,{|x|AllTrim(x[1])=="QEL_DTENLA"})
nPosHrEnLa := Ascan(aStruct,{|x|AllTrim(x[1])=="QEL_HRENLA"})
nPosTamLot := Ascan(aStruct,{|x|AllTrim(x[1])=="QEL_TAMLOT"})
nPosDtaLau := Ascan(aStruct,{|x|AllTrim(x[1])=="QEL_DTLAUD"})
nPosValLau := Ascan(aStruct,{|x|AllTrim(x[1])=="QEL_DTVAL"})

FOR nX := 1 TO Len(aTitPag) 
	cLabor := aTitPag[nX][1]
	//Cria a posicao para os laudos
	Aadd(aResultados[nX],{})
	//cNiseri := QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF
	aLauLab := DaxQIPLau(cFilOri, cOp, cLote, cNiseri, cProduto, QPK->QPK_REVI, cLabor )
	IF Len(aLauLab)	== 0         
		//Preenche a posicao do Laudo com as variaveis default, caso nao haja laudo
		aLauLab := DAXFilEnc("QEL",.F.)
                                      
		//Sugere os campos no Laudo do Laboratorio a partir da Entrada
		aLauLab[nPosDtEnLa] := QPK->QPK_DTPROD
		aLauLab[nPosHrEnLa] := Time()
		aLauLab[nPosTamLot] := QPK->QPK_TAMLOT
		aLauLab[nPosDtaLau] := QPK->QPK_EMISSA
		aLauLab[nPosValLau] := QPK->QPK_EMISSA + QAtuShelf(QPK->QPK_PRODUT,QPK->QPK_REVI) 		
	EndIf
	
	//Cria a posicao para o laudo 
	aResultados[nX,Len(aResultados[nX])] := aClone(aLauLab)

NEXT  

//Verifica se existem Ensaios a serem inspecionados
Aeval(aResultados,{|x,y|lFilLab:=IIF(Len(aResultados[y,_ENS])==0,.F.,lFilLab)})
//lFilLab := lResult

If lFilLab 

	//Cria a posicao para o Laudo Geral
	Aadd(aResultados,{})
	//cNiseri := QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF
	//Caso o Laudo Geral da Entrada esteja preenchido carrega o mesmo para edicao

	aLauGer := DaxQIPLau(cFilOri, cOp, cLote, cNiseri, cProduto, QPK->QPK_REVI, Space(TamSX3("QPL_LABOR")[1]) )
			
	//Armazena o Laudo Geral da Entrada
	Aadd(aResultados[Len(aResultados)],aClone(aLauGer))

ENDIF

RETURN lResult
                         
Static Function DAXQipMed( cFilOri, cProduto, cRevi, cLote, cLabor, cEnsaio, cCarta, cOP, aDados, cEnsQIP, lResult, lResPar)
Local aAreaAnt	:= GetArea()                      
Local aAreaQES  := QES->(GetArea())
Local aAreaQEQ  := QEQ->(GetArea())
Local aAreaQER  := QER->(GetArea())
Local nQtdMed   := 0
Local cSeek     := ""
Local cChvMed	:= ""
Local aMed		:= {}
Local aMedicao  := {}
Local cSeekQER  := "" 
Local lQReinsp	:= QieReinsp()

Local cAliasQER := "QER"
Local lQuery    := .F.          
Local cQuery    := ""
Local aStruQER  := {}
Local nPosCpo   := 0
LOCAL cAliasQPR := GetNextAlias()
LOCAL lJaSkip   := .F.
LOCAL cChave 	:= "% 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11 %"
LOCAL nRegs		:= 0

nQtdMed	:= Q215QtdMed(cEnsaio) //Define o numero de medicoes cadastradas

IF LEN(ALLTRIM(cLote)) < 6 // Ajuste para padronizar o tamanho do campo Lote
    cLote   := PADL(ALLTRIM(QEK->QEK_LOTE), 6, '0')
ENDIF

//nPosEns := aScan( aDados, { | x | ALLTRIM(x[2]) == ALLTRIM(cEnsaio) } )
//IF nPosEns > 0
//	cEnsaio := aDados[nPosEns][1]
//ENDIF

cNumSer   := QPK->QPK_NUMSER

If cCarta # "TXT"
	BeginSql Alias cAliasQPR

		SELECT  QPR.QPR_FILIAL,     QPR.QPR_OP,	  QPR.QPR_LOTE,	 QPR.QPR_NUMSER, QPR.QPR_ROTEIR, QPR.QPR_OPERAC,
			     QPR.QPR_LABOR, QPR.QPR_ENSAIO, QPR.QPR_DTMEDI,  QPR.QPR_HRMEDI,  QPR.QPR_AMOSTR,   QPR.QPR_ENSR, QPS.QPS_INDMED,
			    QPS.QPS_MEDICA, QPR.QPR_RESULT,  QPR.QPR_DTINI,   QPR.QPR_HRINI,   QPR.QPR_DTFIM,  QPR.QPR_HRFIM,
			    QPR.QPR_METODO,  QPR.QPR_RVDOC,                   QPR.QPR_CHAVE, QPR.QPR_FILMAT, 'QPS' AS TABELA, QPR.R_E_C_N_O_
		FROM   %table:QPR% QPR,
			   %table:QPS% QPS
		WHERE  QPR.QPR_FILIAL = %exp:cFilOri%			AND
			   QPR.QPR_OP     = %Exp:cOp% 				AND
			   QPR.QPR_LOTE   = %Exp:cLote%				AND
			   QPR.QPR_NUMSER = %Exp:cNumSer%			AND
			   QPR.QPR_ENSAIO = %Exp:cEnsQIP%			AND
			   QPR.QPR_FILIAL = QPS.QPS_FILIAL			AND
			   QPS.QPS_CODMED = QPR.QPR_CHAVE			AND
			   QPS.%notDel%								AND
			   QPR.%notDel%
		ORDER BY %Exp:cChave%

	EndSql
	(cAliasQPR)->(DbGoTop())
	Count To nRegs
	(cAliasQPR)->(DbGoTop())
	CONOUT("IND")
Else
	BeginSql Alias cAliasQPR

		SELECT QPR.QPR_FILIAL,     QPR.QPR_OP,	  QPR.QPR_LOTE,	 QPR.QPR_NUMSER, QPR.QPR_ROTEIR, QPR.QPR_OPERAC,
			     QPR.QPR_LABOR, QPR.QPR_ENSAIO, QPR.QPR_DTMEDI,  QPR.QPR_HRMEDI, QPR.QPR_AMOSTR,   QPR.QPR_ENSR, ' ',
			    QPQ.QPQ_MEDICA, QPR.QPR_RESULT,  QPR.QPR_DTINI,   QPR.QPR_HRINI,  QPR.QPR_DTFIM,  QPR.QPR_HRFIM,
			    QPR.QPR_METODO,  QPR.QPR_RVDOC,                   QPR.QPR_CHAVE, QPR.QPR_FILMAT, 'QPS' AS TABELA, QPR.R_E_C_N_O_
		FROM   %table:QPR% QPR,
			   %table:QPQ% QPQ
		WHERE  QPR.QPR_FILIAL = %exp:cFilOri%			AND
			   QPR.QPR_OP     = %Exp:cOp% 				AND
			   QPR.QPR_LOTE   = %Exp:cLote%				AND
			   QPR.QPR_NUMSER = %Exp:cNumSer%			AND
			   QPR.QPR_ENSAIO = %Exp:cEnsQIP%			AND
			   QPR.QPR_FILIAL = QPQ.QPQ_FILIAL			AND
			   QPQ.QPQ_CODMED = QPR.QPR_CHAVE			AND
			   QPQ.%notDel%								AND
			   QPR.%notDel%
		ORDER BY %Exp:cChave%

    EndSql
	(cAliasQPR)->(DbGoTop())
	Count To nRegs
	(cAliasQPR)->(DbGoTop())
	CONOUT("TXT")
EndIf

While &(cAliasQPR+"->(!Eof())")

	//??????????????????????????????
	//?Valores das medicoes 									 ?
	//??????????????????????????????
	cCHvMed := &(cAliasQPR+"->QPR_CHAVE")
	aMed    := {}

	If cCarta # "TXT"
		If cCarta == "P  "
			aMed := Afill(Array(4),0)
			aMed[4] := " " //somente na quarta posicao
		EndIf
		If cCarta # "P  "
			For nX := 1 to nQtdMed
				If QPR_CHAVE == cCHvMed
					Aadd(aMed,&(cAliasQPR+"->QPS_MEDICA"))
					IF !EMPTY(ALLTRIM(&(cAliasQPR+"->QPS_MEDICA")))
						lResult := .T.
					ELSE
						lResPar := .T.
					ENDIF
					IF nRegs > 1
						&(cAliasQPR+"->(dbSkip())")
						lJaSkip := .T.
					ENDIF
				EndIf
			Next
		Else
			For nX := 1 to 3
				If QPR_CHAVE == cCHvMed
					If &(cAliasQPR+"->QPS_INDMED") == "A"
						aMed[1] := SuperVal(&(cAliasQPR+"->QPS_MEDICA"))
						IF !EMPTY(ALLTRIM(&(cAliasQPR+"->QPS_MEDICA")))
							lResult := .T.
						ELSE
							lResPar := .T.
						ENDIF
					ElseIf &(cAliasQPR+"->QPS_INDMED") == "N"
						aMed[2] := SuperVal(&(cAliasQPR+"->QPS_MEDICA"))
						IF !EMPTY(ALLTRIM(&(cAliasQPR+"->QPS_MEDICA")))
							lResult := .T.
						ELSE
							lResPar := .T.
						ENDIF
						aMed[4] := "S"
					ElseIf &(cAliasQPR+"->QPS_INDMED") == "P"
						aMed[3] := SuperVal(&(cAliasQPR+"->QPS_MEDICA"))
						IF !EMPTY(ALLTRIM(&(cAliasQPR+"->QPS_MEDICA")))
							lResult := .T.
						ELSE
							lResPar := .T.
						ENDIF
					EndIf
					IF nRegs > 1
						&(cAliasQPR+"->(dbSkip())")
						lJaSkip := .T.
					ENDIF
				EndIf
			Next
		EndIf

		//Alimenta array com as medi?es em braNCo.
		If Len(aMed) < nQtdMed
			For nX := Len(aMed)+1 to nQtdMed
				Aadd(aMed,"0")
			Next nX
		EndIf

		If cCarta == "P  "
			If Empty(aMed[4])
				aMed[4] := "N"
				aMed[2] := 0
			Endif
		EndIf
	Else
		Aadd(aMed, &(cAliasQPR+"->QPQ_MEDICA"))
		IF !EMPTY(ALLTRIM(&(cAliasQPR+"->QPQ_MEDICA")))
			lResult := .T.
		ELSE
			lResPar := .T.
		ENDIF
	EndIf

	//??????????????????????????????
	//  Monta o array das medicoes 
	//??????????????????????????????
	Aadd( aMedicao,{})
	Aadd( aMedicao[Len(aMedicao)], CTOD(SubStr(&(cAliasQPR+"->QPR_DTMEDI"),7,2)+"/"+SubStr(&(cAliasQPR+"->QPR_DTMEDI"),5,2)+"/"+SubStr(&(cAliasQPR+"->QPR_DTMEDI"),3,2)) )   // Data da Medição                              //Data medicao
	Aadd( aMedicao[Len(aMedicao)], &(cAliasQPR+"->QPR_HRMEDI") )                                 																			// Hora medicao
	Aadd( aMedicao[Len(aMedicao)], &(cAliasQPR+"->QPR_AMOSTR") )                                 																			// Amostra
	Aadd( aMedicao[Len(aMedicao)], &(cAliasQPR+"->QPR_FILMAT") )                                 																			// Filial da matricula
	Aadd( aMedicao[Len(aMedicao)], &(cAliasQPR+"->QPR_ENSR")   )                                   																			// Codigo do ensaiador
	Aadd( aMedicao[Len(aMedicao)], QA_NUSR(&(cAliasQPR+"->QPR_FILMAT"),&(cAliasQPR+"->QPR_ENSR"),.F.,"A") )      																								// Nome do Ensaiador

	If cCarta == "TMP" //Campos para tratamento de ensaios do tipo: TEMPO
		Aadd(aMedicao[Len(aMedicao)], CTOD(SubStr(&(cAliasQPR+"->QPR_DTINI"),7,2)+"/"+SubStr(&(cAliasQPR+"->QPR_DTINI"),5,2)+"/"+SubStr(&(cAliasQPR+"->QPR_DTINI"),3,2)) )
		Aadd(aMedicao[Len(aMedicao)], &(cAliasQPR+"->QPR_HRINI") )
		Aadd(aMedicao[Len(aMedicao)], CTOD(SubStr(&(cAliasQPR+"->QPR_DTFIM"),7,2)+"/"+SubStr(&(cAliasQPR+"->QPR_DTFIM"),5,2)+"/"+SubStr(&(cAliasQPR+"->QPR_DTFIM"),3,2)) )
		Aadd(aMedicao[Len(aMedicao)], &(cAliasQPR+"->QPR_HRFIM") )
	EndIf

	Aeval(aMed,{|x|Aadd(aMedicao[Len(aMedicao)],x)})                        //Medicoes
	
	Aadd(aMedicao[Len(aMedicao)], &(cAliasQPR+"->QPR_RESULT") )                                 //Resultado
	Aadd(aMedicao[Len(aMedicao)], '' )                                 //Rastreamento
	
	Aeval(aCpoUsu,{|x|Aadd(aMedicao[Len(aMedicao)],FieldGet(FieldPos(x)))}) //Campos Criados pelo usuario
	
	Aadd(aMedicao[Len(aMedicao)], &(cAliasQPR+"->QPR_METODO") )	                              //Metodo
	Aadd(aMedicao[Len(aMedicao)], &(cAliasQPR+"->QPR_RVDOC") )                                  //Revisao do Documento
	
	Aadd(aMedicao[Len(aMedicao)], &(cAliasQPR+"->QPR_CHAVE") )	                                  //Chave de ligacao 

	Aadd(aMedicao[Len(aMedicao)], "QER")
	Aadd(aMedicao[Len(aMedicao)], 0 )
	Aadd(aMedicao[Len(aMedicao)], .F.)	                                	  //Marca de delecao

	If !lJaSkip
		&(cAliasQPR+"->(dbSkip())")
	EndIf
EndDo

RestArea(aAreaQES)
RestArea(aAreaQEQ)
RestArea(aAreaQER)
RestArea(aAreaAnt)

Return(aMedicao)                      

//Bibliotecas
#Include "Totvs.ch"
#Include "FWMVCDef.ch"
#INCLUDE "TOPCONN.CH"
#include "rwmake.ch"
#include "protheus.ch"


User Function DXREPMKP()
Local aParam      	:= {}
Local nX			:= 0
Private aParRet        	:= {}
Private cProdOri	  	:= SB1->B1_COD
Private oMark

aMvPar := {}

For nX := 1 To 40
 aAdd( aMvPar, &( "MV_PAR" + StrZero( nX, 2, 0 ) ) )
Next nX
aAdd(aParam, {1, "Filial Origem"   , CriaVar('B1_FILIAL',.F.) ,  ,, 'SM0',, 60, .F.} )
aAdd(aParam, {1, "Filial Inicial"   , CriaVar('B1_FILIAL',.F.) ,  ,, 'SM0',, 60, .F.} )
aAdd(aParam, {1, "Filial Final"   , CriaVar('B1_FILIAL',.F.) ,  ,, 'SM0',, 60, .F.} )
aAdd(aParam, {1, "Produto Inicial"   , CriaVar('B1_COD',.F.) ,  ,, 'SB1',, 60, .F.} )
aAdd(aParam, {1, "Produto Final"   , CriaVar('B1_COD',.F.) ,  ,, 'SB1',, 60, .F.} )

If ParamBox(aParam,'Parâmetros',aParRet)
	MntTela(aParRet)
EndIf

For nX := 1 To Len( aMvPar )
 &( "MV_PAR" + StrZero( nX, 2, 0 ) ) := aMvPar[ nX ]
Next nX
Return


Static Function MntTela(aParRet)
Local cFilter		:= ""
Local cFilOri := aParRet[1]
Local cFilIni := aParRet[2]
Local cFilFim := aParRet[3]
Local cProdIni := aParRet[4]
Local cProdFim := aParRet[5]
Local lMarcar  	:= .F.
Private aRotBkp := aRotina

//-- Atualiza botoes
aRotina := MenuDefMark()

cFilter		+= "B1_COD   >= '" + cProdIni + "' .And. B1_COD  <='" + cProdFim + "' .And.  B1_MSBLQL = '2'   "
oMark := FWMarkBrowse():New()

oMark:SetAlias("SB1")

oMark:SetDescription("Replica de markup de produto")

// Define o campo de marcação da tabela
oMark:SetFieldMark("B1_OK")

// Define um semáforo para o MarkBrowse
// Impede que outros usuários marquem o mesmo registro ao mesmo tempo
//oMark:SetSemaphore(.T.)

// Define um filtro padrão com os parâmetros informados na pergunta
oMark:SetFilterDefault(cFilter)

//Indica o Code-Block executado no clique do header da coluna de marca/desmarca
//oMark:bAllMark := { || MCFG6Invert(oMark:Mark(),lMarcar := !lMarcar ), oMark:Refresh(.T.)  }
oMark:SetAllMark( { || SB1->( DbGoTop() , DbEval( { || RecLock( 'SB1' , .F. ) , B1_OK := oMark:Mark() , MSUnlock() } , { || .T. } , { || !Eof() } ) , DbGoTop() , oMark:Refresh() ) } )
//oMark:AddButton("Efetiva"      , { || U_ProcRep()  },,,, .F., 2 )
oMark:SetMenuDef('')
oMark:Activate()


aRotina := aRotBkp 
Return Nil
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³MenuDef   ³Autor  ³V. Raspa                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³Menu Funcional                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDefMark()     
Local aRotina := {}

ADD OPTION aRotina TITLE 'Pesquisar'			ACTION 'PesqBrw'			OPERATION 0							ACCESS 0
ADD OPTION aRotina TITLE 'Efetivar replica'			ACTION 'U_ProcRep()'			OPERATION MODEL_OPERATION_UPDATE	ACCESS 0

Return(aRotina)

Static Function MCFG6Invert(cMarca,lMarcar)
    Local cAliasSB1 := 'SB1'
    Local aAreaSD1  := (cAliasSB1)->( GetArea() )
 
    dbSelectArea(cAliasSB1)
    (cAliasSB1)->( dbGoTop() )
    While !(cAliasSB1)->( Eof() )
        RecLock( (cAliasSB1), .F. )
        (cAliasSB1)->B1_OK := IIf( lMarcar, cMarca, '  ' )
        MsUnlock()
        (cAliasSB1)->( dbSkip() )
    EndDo
 
    RestArea( aAreaSD1 )
Return .T.

User Function ProcRep()
Local cFilOri 		:= aParRet[1]
Local cFilIni 		:= aParRet[2]
Local cFilFim 		:= aParRet[3]
Local cQuery	  	:= ''
Local cAliasQry   	:= GetNextAlias()
Local aMkpOri		:= {}
Local lRecLock		:= .t.
Local nX			:= 0
Local nY			:= 0
Local aSM0      	:= FwLoadSM0() 
Local cMarca		:= oMark:Mark()

cQuery := "	SELECT *" 
cQuery += " FROM " + RetSqlName( "SZO" ) + " SZO "
cQuery += " WHERE SZO.D_E_L_E_T_ = ' ' AND "
cQuery += "    SZO.ZO_PRODUTO =  '" + cProdOri + "'	"	
cQuery += " AND SZO.ZO_FILIAL BETWEEN  '" + cFilOri + "'	 AND '" + cFilOri + "'	
cQuery += " ORDER BY ZO_FILIAL, ZO_PRODUTO, ZO_FAIXA "

If Select(cAliasQry) > 0
	(cAliasQry)->(DbCloseArea())
EndIf

TcQuery cQuery new Alias ( cAliasQry )

if !(cAliasQry)->(Eof())	
	While !(cAliasQry)->(Eof())
		Aadd(aMkpOri,{(cAliasQry)->ZO_FILIAL , (cAliasQry)->ZO_FAIXA , (cAliasQry)->ZO_MARKUP})
		(cAliasQry)->(DbSkip())
	EndDo
Else
	MsgInfo('Não existem markups cadastrados para esse produto')
	Return
EndIf

DbSelectArea("SB1")
dbGoTop()
ProcRegua(RecCount())
Do While !EOF()
	
	IncProc()
	
	If oMark:IsMark(cMarca)
		For nX := 1 To Len(aSM0)
			If aSM0[nX,SM0_CODFIL] >= cFilIni .and. aSM0[nX,SM0_CODFIL] <= cFilFim
				DelSZO(aSM0[nX,SM0_CODFIL],SB1->B1_COD)

				SZO->(DbSetOrder(1))

				IncProc( "Criando markup do produto " +SB1->B1_COD + ". Aguarde..." )
				For nY := 1 to Len(aMkpOri)
					If SZO->(DbSeek(aSM0[nX,SM0_CODFIL] + SB1->B1_COD + aMkpOri[nY][2] ))
						lReclock := .f.
					Else
						lReclock := .t.
					EndIf

					Reclock('SZO',lReclock)
					ZO_FILIAL 	:= aSM0[nX,SM0_CODFIL]
					ZO_PRODUTO 	:= SB1->B1_COD
					ZO_FAIXA 	:= aMkpOri[nY][2]
					ZO_MARKUP 	:= aMkpOri[nY][3]
				Next
			EndIf
		Next
	
	EndIf
	
	dbSelectArea("SB1")
	DbSkip()
	
EndDo

MsgInfo('Replica feita com sucesso!')
oMark:GetOwner():End()

Return Nil



Static Function DelSZO(cFilAtu,cProduto)
SZO->(DbSetOrder(1))
If SZO->(DbSeek(cFilAtu + cProduto))
	While(cFilAtu + cProduto == SZO->(ZO_FILIAL + ZO_PRODUTO))
		Reclock('SZO',.f.)
		DbDelete()
		MsUnlock()
		SZO->(DbSkip())
	EndDO
EndIf
Return

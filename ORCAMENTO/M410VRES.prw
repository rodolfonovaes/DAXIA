#Include "Protheus.ch"	
#Include "Totvs.ch"
/*/{Protheus.doc} M410VRES()
    (long_description.T.
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
User Function M410VRES()
Local aArea := GetArea()
Local cJustif   := ''

SD2->(DbSetOrder(8))
If !SD2->(DbSeek(xFilial('SD2') +SC5->C5_NUM))
    SCJ->(DbSetOrder(1))
    If SCJ->(DbSeek(xFilial('SCJ') + SC5->C5_XNUMCJ))
        
        cJustif := Dlg_Justif()

        Reclock('SCJ',.F.)
        SCJ->CJ_STATUS := 'R'
        MsUnlock()

        SCK->(DbSetOrder(1))
        If SCK->(DbSeek(xFilial('SCK') + SCJ->CJ_NUM))
            While(SCJ->CJ_FILIAL + SCJ->CJ_NUM  == SCK->(CK_FILIAL + CK_NUM))
                Reclock('SCK',.F.)
                SCK->CK_XMOTIVO := '000011'
                SCK->CK_XJUSTIF := cJustif
                MsUnlock()
                SCK->(DbSkip())
            Enddo
        EndIf
    EndIf
EndIf

Restarea(aArea)
Return .T.


Static Function Dlg_Justif()
Local  aArea    := GetArea()
Local  _nOpcao  :=  0
Local  cJust    :=  Space( TamSX3( "CK_XJUSTIF" )[1] )
Local  oBold
Local  oGJust
Local  cSemJust := SuperGetMV( "ES_MOTABRT",, "000000" ) + "|" + SuperGetMV( "ES_MOTFECH",, "000001" ) 
Private  _oDlgPto


Define MSDialog _oDlgPto Title OEMToANSI( "* Justificativa" ) From 000,000 To 012, 100 Of oMainWnd // Style DS_MODALFRAME
Define Font oBold Name "Arial" Size 0, -13 Bold
@ 035, 006  To  075, 380  Label  OEMToANSI( "[ Justificativa (máx. 30 caracteres) ]" )  Of  _oDlgPto  Pixel

/*---------------------------+
| Digitacao da Justificativa |
+---------------------------*/
@ 053, 010 Say    OEMtoANSI( "Justificativa" ) Font oBold  Pixel Color CLR_HBLUE
@ 053, 055 MSGet  oGLote  Var cJust  Picture "@!" Size 300, 008 Of _oDlgPto Pixel
Activate MSDialog _oDlgPto Center On Init EnchoiceBar( _oDlgPto, { || _nOpcao := 1, u_VldJust( cJust ) }, { || u_VldCanc() } )

/*--[ Enchoice Bar ]-------------------+
| _nOpcao == 1 --> Botao [ Ok ]        |
| _nOpcao == 0 --> Botao [ Cancelar ]  |
+-------------------------------------*/

RestArea( aArea )
Return( cJust )
#Include "Protheus.CH"
#Include "topconn.ch"
/*/{Protheus.doc} nomeFunction
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
User Function RTESTE01()                        
Local oGet1
Local cGet1 := "                            "
Local oSay1
Static oDlg
Static oPanel1
Static oPanel2
Static oPanel3

  DEFINE MSDIALOG oDlg TITLE "Teste" FROM 000, 000  TO 1000, 1700 COLORS 0, 16777215 PIXEL

    @ 001, 001 MSPANEL oPanel1 PROMPT "" SIZE 850, 048 OF oDlg COLORS 0, 16777088 RAISED
    @ 004, 003 SAY oSay1 PROMPT "Nome Cliente" SIZE 048, 013 OF oPanel1 COLORS 0, 16777215 PIXEL
    @ 019, 002 MSGET oGet1 VAR cGet1 SIZE 069, 010 OF oPanel1 COLORS 0, 16777215 PIXEL
    @ 047, 002 MSPANEL oPanel2 PROMPT "" SIZE 850, 305 OF oDlg COLORS 0, 16776960 RAISED
    fMSNewGe1()
    @ 350, 003 MSPANEL oPanel3 PROMPT "" SIZE 850, 105 OF oDlg COLORS 0, 8421504 RAISED

  ACTIVATE MSDIALOG oDlg CENTERED

Return

//------------------------------------------------ 
Static Function fMSNewGe1()
//------------------------------------------------ 
Local nX
Local aHeaderEx := {}
Local aColsEx := {}
Local aFieldFill := {}
Local aFields := {"A1_NOME","A1_TEL"}
Local aAlterFields := {}
Static oMSNewGe1

  // Define field properties
  DbSelectArea("SX3")
  SX3->(DbSetOrder(2))
  For nX := 1 to Len(aFields)
    If SX3->(DbSeek(aFields[nX]))
      Aadd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
                       SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
    Endif
  Next nX

  // Define field values
  For nX := 1 to Len(aFields)
    If DbSeek(aFields[nX])
      Aadd(aFieldFill, CriaVar(SX3->X3_CAMPO))
    Endif
  Next nX
  Aadd(aFieldFill, .F.)
  Aadd(aColsEx, aFieldFill)

  oMSNewGe1 := MsNewGetDados():New( 002, 023, 400, 850, GD_INSERT+GD_DELETE+GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oPanel2, aHeaderEx, aColsEx)

Return
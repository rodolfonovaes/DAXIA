User Function MA010BUT()
Local aButtons := {} // botões a adicionar
If ALTERA
    AAdd(aButtons,{ 'NOTE',{| |  U_CPerigo() }, 'Classf. Perigo','Estrut' } )
    AAdd(aButtons,{ 'NOTE',{| |  U_DxAlerge() }, 'Alergenicos','Estrut' } )
EndIf
Return (aButtons)

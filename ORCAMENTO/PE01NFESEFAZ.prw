#include "PROTHEUS.CH"
#include "TOPCONN.CH"
#Include 'PLSAREXP.ch'
#Include 'FWMVCDef.ch'

#define MENSCLI 2
#define NOTA 5
#define MENSFIS 3
#define CUBAGEM 17

User Function PE01NFESEFAZ()
Local aArea    := GetArea()
Local aNfe     := PARAMIXB
Local cMensCli := ""
Local cNota
Local cChaveSD1 := ""
Local cChaveSD2 := ""
Local nDI := 0
Local nTotItens := 0
Local nQtdItens := 0
Local cPedVen := ""
Local cClieFor   := ""
Local cLoja      := ""
Local cMensFis   := PARAMIXB[3]
Local aNota      := PARAMIXB[5]


cChaveSD2 := SF2->F2_FILIAL + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA

SD2->(dbSetOrder(3))
If SD2->(dbSeek( cChaveSD2 ))
	cPedVen := SD2->D2_PEDIDO
Endif

cMensCli := aNfe[MENSCLI]

SC5->(dbSetOrder(1))
If SC5->(DbSeek(xFilial("SC5")+cPedVen)) // Posiciona cabecalho do pedido
	SA4->(DbSetORder(1))
	If !Empty(SC5->(C5_XTREDES)) .And. SA4->(DbSeek(xFilial('SA4') + SC5->C5_XTREDES))
		cMensFis := ' - Dados para Redespacho :' + Alltrim(SA4->A4_NOME) + ' - CNPJ: ' + Transform(SA4->A4_CGC,"@R 99.999.999/9999-99") + ' - I.E: ' + Alltrim(SA4->A4_INSEST) +;
		' ' + Alltrim(SA4->A4_END) + ' - ' + Alltrim(SA4->A4_BAIRRO) + ' - CEP:' + AllTrim(Transform(SA4->A4_CEP, "@R 99999-999")) + ' - ' + ALLTRIM(SA4->A4_MUN) + ' - ' + Alltrim(SA4->A4_EST)
	EndIf

	aNfe[MENSFIS] += cMensFis
EndIf 

RestArea(aArea)

Return aNfe


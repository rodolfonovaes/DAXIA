#INCLUDE "PROTHEUS.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MAVALMMAIL Autor � Totvs Ibirapuera   � Data � 19/07/2021  ���
�������������������������������������������������������������������������͹��
���Descricao � P.E. PARA ENVIAR OU NAO EMAILS DA FUNCAO MENVIAMAIL()      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � DAXIA                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function MAVALMMAIL() 
Local lRet   := .T.
Local aDados := ParamIxb[2]

conout("EMAIL PONTO DE PEDIDO")
conout(Ctod(date())+time())
conout(paramixb[1])
conout(adados[1])
conout("-------------------------")
if ParamIxb[1] == '001'
    // Se a mensagem for de armaz�m diferente do padr�o, n�o envia o e-mail
    If Posicione("SB1",1,xFilial("SB1") + aDados[1],"B1_LOCPAD") <> aDados[3]
    	lRet := .F.
    Endif
endif
 
Return lRet

/*
cMensagem := OemToAnsi(STR0064) + aDados[1] + " - " + aDados[2] + OemToAnsi(STR0065)	            //"O produto "###" atingiu a quantidade de "
cMensagem += Str(aDados[4]) + OemToAnsi(STR0066) + aDados[3] + OemToAnsi(STR0067) + Str(aDados[5])	//" (almoxarifado "###"), abaixo do Ponto de Pedido de "
*/

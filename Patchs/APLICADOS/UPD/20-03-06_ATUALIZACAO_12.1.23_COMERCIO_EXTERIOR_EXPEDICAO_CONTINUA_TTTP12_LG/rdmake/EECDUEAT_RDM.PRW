#INCLUDE "Protheus.ch"

/*
Programa: EECDUEAT_RDM.PRW
Objetivo: Contem as regras necessárias para validação dos campos de atributos necessários para registro de DUE em exportações de café.
*/

/*
Função  : U_DUAtList
Objetivo: Retorna a lista de valores válida para o atributo para geração do ComboBox
*/
User Function DUAtList(cCpoAtt)
Local cList := ""
Default cCpoAtt := ""

    Do Case
        Case cCpoAtt == "EE9_AT3038"//Padrão de qualidade
            cList := "1=S: Total conformidade com os padrões de defeito e umidade;2=XD: O café não está em conformidade com o padrão de defeito desejado;3=XM: O café não está em conformidade com o padrão de umidade desejado;4=XDM: O café não está em conformidade com o padrão (defeito e umidade desejados)"

        Case cCpoAtt == "EE9_AT3039"//Embarcado Em
            cList := "1=Sacas;2=Granel;99=Outros"

        Case cCpoAtt == "EE9_AT3040"//Tipo
            cList := "1=Arábica;2=Robusta"

        Case cCpoAtt == "EE9_AT3041"//Método de Processamento (1)
            cList := "1=Lavado;2=Não Lavado"

        Case cCpoAtt == "EE9_AT3058"//Método de Processamento (2)
            cList := "1=Atomizado(Spray-dried);2=Liofilizado(Freeze-dried)"

        Case cCpoAtt == "EE9_AT3059"//Embalagem final
            cList := "1=Sim;2=Não"

        Case cCpoAtt == "EE9_AT3060"//Característica Especial
            cList := "a=Especialidade / café gourmet;b=Associação 4C;c=Eurepgap;d=FLO Internacional (Fairtrade);e=Sistema Q Coffee;f=Rainforest Alliance;g=Centro das Aves Migratórias do Smithsonian (Bird friendly);h=Certificado UTZ;i=Padrões Corporativos;j=Fair Trade USA;k=Outro (por favor especifique)"

    EndCase

Return cList

/*
Função  : U_DUAtWhen
Objetivo: Indica se um atributo pode ser informado ou não, de acordo com o NCM
*/
User Function DUAtWhen(cCpoAtt)
Local lRet := .F.
Local cNCM := ""
Default cCpoAtt := ""

    If IsInCallStack("AP100MAN")//Pedido
        cNCM := AllTrim(M->EE8_POSIPI)
    ElseIf IsInCallStack("AE100MAN")//Embarque
        cNCM := AllTrim(M->EE9_POSIPI)
    EndIf

    cCpoAtt := Right(AllTrim(cCpoAtt), 4)

    Do Case
        Case cNCM == "09011110"
            lRet := (aScan( {"3038", "3039", "3040", "3041", "3060", "3061"} , cCpoAtt ) > 0)
        Case cNCM == "09011190"
            lRet := (aScan( {"3038", "3039", "3040", "3041", "3060", "3061"} , cCpoAtt ) > 0)
        Case cNCM == "09011200"
            lRet := (aScan( {"3038", "3039", "3040", "3041", "3060", "3061"} , cCpoAtt ) > 0)
        Case cNCM == "09012100"
            lRet := (aScan( {"3039", "3060", "3061"} , cCpoAtt ) > 0)
        Case cNCM == "09012200"
            lRet := (aScan( {"3039", "3060", "3061"} , cCpoAtt ) > 0)
        Case cNCM == "21011110"
            lRet := (aScan( {"3039", "3058", "3059", "3060", "3061"} , cCpoAtt ) > 0)
        Case cNCM == "21011190"
            lRet := (aScan( {"3039", "3060", "3061"} , cCpoAtt ) > 0)
       Case cNCM == "21011200"
            lRet := (aScan( {"3039", "3060", "3061"} , cCpoAtt ) > 0)
    EndCase

    If cCpoAtt == "3061" .And. M->EE9_AT3060 <> "k"
        lRet := .F.
    EndIf

Return lRet

/*
Função  : DUEEnvAt
Objetivo: Implementação de ponto de entrada na integração da DUE para definir a lista de atributos e valores informados para registro de item da DUE
*/
User Function DUEEnvAt()
Local aAttList := {}
Local aAux := {}
Local cAux := ""

    If EE9->(FieldPos("EE9_AT3038")) > 0 .And. !Empty(EE9->EE9_AT3038)//Padrão de qualidade
        aAdd(aAttList, {"ATT_3038", EE9->EE9_AT3038})
    EndIf

    If EE9->(FieldPos("EE9_AT3039")) > 0 .And. !Empty(EE9->EE9_AT3039)///Embarcado Em
        aAdd(aAttList, {"ATT_3039", alltrim(EE9->EE9_AT3039)})
    EndIf

    If EE9->(FieldPos("EE9_AT3040")) > 0 .And. !Empty(EE9->EE9_AT3040)///Tipo
        aAdd(aAttList, {"ATT_3040", EE9->EE9_AT3040})
    EndIf

    If EE9->(FieldPos("EE9_AT3041")) > 0 .And. !Empty(EE9->EE9_AT3041)///Método de Processamento (Verde)
        aAdd(aAttList, {"ATT_3041", EE9->EE9_AT3041})
    EndIf

    If EE9->(FieldPos("EE9_AT3058")) > 0 .And. !Empty(EE9->EE9_AT3058)///Método de Processamento (Solúvel)
        aAdd(aAttList, {"ATT_3058", EE9->EE9_AT3058})
    EndIf

    If EE9->(FieldPos("EE9_AT3059")) > 0 .And. !Empty(EE9->EE9_AT3059)///Embalagem final
        aAdd(aAttList, {"ATT_3059", if(EE9->EE9_AT3059=="1",'true','false')}) //ATT_3059 está definido como booleano no cadastro de atributos do portal unico.
    EndIf

    If EE9->(FieldPos("EE9_AT3060")) > 0 .And. !Empty(EE9->EE9_AT3060)///Característica Especial
        aAdd(aAttList, {"ATT_3060", EE9->EE9_AT3060})
    EndIf

    If EE9->(FieldPos("EE9_AT3061")) > 0 .And. !Empty(EE9->EE9_AT3061)///Outra Característica Especial
        aAdd(aAttList, {"ATT_3061", alltrim(EE9->EE9_AT3061)})
    EndIf

Return aAttList
//Bibliotecas
#Include "Protheus.ch"
#include "Fileio.ch"
/*/{Protheus.doc} zSpedXML
Fun��o que gera o arquivo xml da nota (normal ou cancelada) atrav�s do documento e da s�rie disponibilizados
@author Atilio
@since 25/07/2017
@version 1.0
@param cDocumento, characters, C�digo do documento (F2_DOC)
@param cSerie, characters, S�rie do documento (F2_SERIE)
@param cArqXML, characters, Caminho do arquivo que ser� gerado (por exemplo, C:\TOTVS\arquivo.xml)
@param lMostra, logical, Se ser� mostrado mensagens com os dados (erros ou a mensagem com o xml na tela)
@type function
@example Segue exemplo abaixo
    u_zSpedXML("000000001", "1", "C:\TOTVS\arquivo1.xml", .F.) //N�o mostra mensagem com o XML
        
    u_zSpedXML("000000001", "1", "C:\TOTVS\arquivo2.xml", .T.) //Mostra mensagem com o XML
/*/
    
User Function zSpedXML(cDocumento, cSerie, cArqXML, lMostra , cErrXml)
    Local aArea        := GetArea()
    Local cURLTss      := PadR(GetNewPar("MV_SPEDURL","http://"),250)  
    Local oWebServ
    Local cIdEnt       := RetIdEnti()
    Local cTextoXML    := ""
    Local cFilCont      := ""
    Local aFiles      := {} // O array receber� os nomes dos arquivos e do diret�rio
    Local aSizes      := {} // O array receber� os tamanhos dos arquivos e do diretorio      
    Default cDocumento := ""
    Default cSerie     := ""
    Default cArqXML    := GetTempPath()+"arquivo_"+cSerie+cDocumento+".xml"
    Default lMostra    := .F.
        
    //Se tiver documento
    If !Empty(cDocumento)
        cDocumento := PadR(cDocumento, TamSX3('F2_DOC')[1])
        cSerie     := PadR(cSerie,     TamSX3('F2_SERIE')[1])
            
        //Instancia a conex�o com o WebService do TSS    
        oWebServ:= WSNFeSBRA():New()
        oWebServ:cUSERTOKEN        := "TOTVS"
        oWebServ:cID_ENT           := cIdEnt
        oWebServ:oWSNFEID          := NFESBRA_NFES2():New()
        oWebServ:oWSNFEID:oWSNotas := NFESBRA_ARRAYOFNFESID2():New()
        aAdd(oWebServ:oWSNFEID:oWSNotas:oWSNFESID2,NFESBRA_NFESID2():New())
        aTail(oWebServ:oWSNFEID:oWSNotas:oWSNFESID2):cID := (cSerie+cDocumento)
        oWebServ:nDIASPARAEXCLUSAO := 0
        oWebServ:_URL              := AllTrim(cURLTss)+"/NFeSBRA.apw"
            
        //Se tiver notas
        If oWebServ:RetornaNotas()
            
            //Se tiver dados
            If Len(oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3) > 0
                
                //Se tiver sido cancelada
                If oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFECANCELADA != Nil
                    cTextoXML := oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFECANCELADA:cXML
                        
                //Sen�o, pega o xml normal (foi alterado abaixo conforme dica do Jorge Alberto)
                Else
                    cTextoXML := '<?xml version="1.0" encoding="UTF-8"?>'
                    cTextoXML += '<nfeProc xmlns="http://www.portalfiscal.inf.br/nfe" versao="4.00">'
                    cTextoXML += oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFE:cXML
                    cTextoXML += oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFE:cXMLPROT
                    cTextoXML += '</nfeProc>'
                EndIf
                    
                //Gera o arquivo
                If !MemoWrite(cArqXML, cTextoXML)
                    cErrXml :=  "zSpedXML > Erro ao gravar o arquivo xml no servidor . Cod Erro " + Alltrim(Str(fError()))

                EndIf
                    
                //Se for para mostrar, ser� mostrado um aviso com o conte�do
                If lMostra
                    Aviso("zSpedXML", cTextoXML, {"Ok"}, 3)
                EndIf
                    
            //Caso n�o encontre as notas, mostra mensagem
            Else
                ConOut("zSpedXML > Verificar par�metros, documento e s�rie n�o encontrados ("+cDocumento+"/"+cSerie+")...")
                cErrXml :=  "zSpedXML > Verificar par�metros, documento e s�rie n�o encontrados ("+cDocumento+"/"+cSerie+")... Entidade : " + cIdEnt + " Url : " + cURLTss
                If lMostra
                    Aviso("zSpedXML", "Verificar par�metros, documento e s�rie n�o encontrados ("+cDocumento+"/"+cSerie+")...", {"Ok"}, 3)
                EndIf
            EndIf
            
        //Sen�o, houve erros na classe
        Else
            ConOut("zSpedXML > "+IIf(Empty(GetWscError(3)), GetWscError(1), GetWscError(3))+"...")
            cErrXml :=   "zSpedXML > "+IIf(Empty(GetWscError(3)), GetWscError(1), GetWscError(3))+"..."
            If lMostra
                Aviso("zSpedXML", IIf(Empty(GetWscError(3)), GetWscError(1), GetWscError(3)), {"Ok"}, 3)
            EndIf
        EndIf
    EndIf

    //Transformo em base64 o arquivo
    ADir(cArqXML, aFiles, aSizes)//Verifica o tamanho do arquivo, par�metro exigido na FRead.

    If Len(aFiles) == 0
        //Alert('N�o foi gerado o arquivo PDF!')
        Return
    EndIF

    nHandle := fopen(cArqXML , FO_READWRITE + FO_SHARED )
    cString := ""
    FRead( nHandle, cString, aSizes[1] ) //Carrega na vari�vel cString, a string ASCII do arquivo.

    cFilCont := Encode64(cString) //Converte o arquivo para BASE64

    fclose(nHandle)

    RestArea(aArea)
Return cFilCont

#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#Include 'FWMVCDEF.CH'
#INCLUDE "RESTFUL.CH"

WSRESTFUL Exemplo DESCRIPTION "Exemplo WS" 
	WSDATA Fields			AS STRING	OPTIONAL
	WSDATA Order			AS STRING	OPTIONAL
	WSDATA Page				AS INTEGER	OPTIONAL
	WSDATA PageSize			AS INTEGER	OPTIONAL
	WSDATA Code				AS STRING	OPTIONAL
 
    WSMETHOD GET Main ;
    DESCRIPTION "Carrega todos os cadastros" ;
    WSSYNTAX "/Exemplo/{Order, Page, PageSize, Fields}" ;
    PATH "/Exemplo"

    WSMETHOD GET Code ;
    DESCRIPTION "Registro específico" ;
    WSSYNTAX "/Exemplo/{Code}/{Order, Page, PageSize, Fields}" ;
    PATH "/Exemplo/{Code}"	

    WSMETHOD POST Main ;
    DESCRIPTION "Cadastra um novo registro" ;
    WSSYNTAX "/crm/Notes/{Fields}" ;
    PATH "/Exemplo"


ENDWSRESTFUL

/*/{Protheus.doc} GET / Notes/crm/Notes
Retorna todos os Notes

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numérico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/

WSMETHOD GET Main WSRECEIVE Order, Page, PageSize, Fields WSSERVICE Exemplo
	Local lRet	:= .T.
	Local nX	:= 0
	Local oJson	:= JsonObject():New()
	Local oProds:= JsonObject():New()

	(DbSelectArea("SB1"))
	oJson['items'] := {}
	While SB1->(!EOF()) .And. nX <= 5
		oProds:= JsonObject():New()
		oProds['Produto'] := SB1->B1_COD
		aAdd( oJson['items'], oProds)
		SB1->(DbSkip())
		nX++
	EndDo

	Self:SetResponse( EncodeUtf8(FwJsonSerialize(oJson ,.T.,.T.)))

Return lRet

WSMETHOD GET Code WSRECEIVE Order, Page, PageSize, Fields WSSERVICE Exemplo
	Local lRet	:= .T.
	Local oJson	:= JsonObject():New()
	Local oDogs1:= JsonObject():New()
	Local oDogs2:= JsonObject():New()

	oJson['Codigo']		:= "000001"
	oJson['Nome'] 		:= "Nairan"
	oJson['Endereco'] 	:= "Jundiaí"
	oJson['Pai'] 		:= "Tonho"
	oJson['Mae'] 		:= "Cida"

	oJson['Cachorros'] := {}

	oDogs1['Nome'] 		:= "Raul"
	oDogs1['Apelido'] 	:= "Gordão"
	
	oDogs2['Nome'] 		:= "Babilina"
	oDogs2['Apelido'] 	:= "Magrela"

	aAdd(oJson['Cachorros'], oDogs1)
	aAdd(oJson['Cachorros'], oDogs2)

	Self:SetResponse( EncodeUtf8(FwJsonSerialize(oJson ,.T.,.T.)))

Return lRet

/*/{Protheus.doc} POST / Notes/crm/Notes
Inclui um novo vendedor

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numérico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/
WSMETHOD POST Main WSRECEIVE Order, Page, PageSize, Fields WSSERVICE Exemplo
	Local cBody 	:= Self:GetContent()
	Local oItems	:= {}
	
	FWJsonDeserialize(cBody,@oItems)

	conout("exemplo")

Return .T.
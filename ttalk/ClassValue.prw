#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#Include 'FWMVCDEF.CH'
#INCLUDE "RESTFUL.CH"

WSRESTFUL ClassValue DESCRIPTION "Cadastro Classe de Valor" 
	WSDATA Fields			AS STRING	OPTIONAL
	WSDATA Order			AS STRING	OPTIONAL
	WSDATA Page				AS INTEGER	OPTIONAL
	WSDATA PageSize			AS INTEGER	OPTIONAL
	WSDATA Code				AS STRING	OPTIONAL

    WSMETHOD GET Main ;
    DESCRIPTION "Carrega todos os Notes" ;
    WSSYNTAX "/classvalues/{Order, Page, PageSize, Fields}" ;
    PATH "/classvalues"

    WSMETHOD POST Main ;
    DESCRIPTION "Cadastra um novo Prospesct" ;
    WSSYNTAX "/classvalues/{Order, Page, PageSize, Fields}" ;
    PATH "/classvalues"

	WSMETHOD GET Code ;
    DESCRIPTION "Carrega um Note específico" ;
    WSSYNTAX "/classvalues/{Code}{Order, Page, PageSize, Fields}" ;
    PATH "/classvalues/{Code}"	

	WSMETHOD PUT Code ;
    DESCRIPTION "Altera um Note específico" ;
    WSSYNTAX "/classvalues/{Code}/{Fields}" ;
    PATH "/classvalues/{Code}"	

	WSMETHOD DELETE Code ;
    DESCRIPTION "Deleta um Note específico" ;
    WSSYNTAX "/classvalues/{Code}" ;
    PATH "/classvalues/{Code}"

ENDWSRESTFUL

/*/{Protheus.doc} GET / Notes/crm/Notes
Retorna todos os Notes
@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numérico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.
@return lRet	, Lógico, Informa se o processo foi executado com sucesso.
@author		Squad Controladoria
@since		06/08/2018
@version	12.1.20
/*/
WSMETHOD GET Main WSRECEIVE Order, Page, PageSize, Fields WSSERVICE ClassValue
    
    Local cError			:= ""
	Local aFatherAlias		:= {"CTH", "items", "items"}
	Local cIndexKey			:= "CTH_FILIAL, CTH_CLVL"
	Local lRet				:= .T.
	Local oApiManager		:= Nil
	
    Self:SetContentType("application/json")

	oApiManager := APIMANAGER():New("CTBS060","1.000") 	

    oApiManager:SetApiAdapter("CTBS060") 
	oApiManager:SetApiMap(ApiMap())
   	oApiManager:SetApiAlias(aFatherAlias)
	oApiManager:Activate() 

	lRet := GetMain(@oApiManager, Self:aQueryString, aFatherAlias, , cIndexKey)
	
	If lRet
		Self:SetResponse( oApiManager:GetJsonSerialize() )
	Else
		cError := oApiManager:GetJsonError()	
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()

Return lRet

/*/ 
 --------------------------------------------------------------
 --------------------------------------------------------------
 --------------------------------------------------------------
 --------------------------------------------------------------
 /*/
WSMETHOD GET Code WSRECEIVE Order, Page, PageSize, Fields WSSERVICE ClassValue
	Local aFilter			:= {}
	Local cError			:= ""
    Local lRet 				:= .T.
	Local oApiManager		:= APIMANAGER():New("CTBS060","1.000")
	Local nLenFields		:= TamSX3("CTH_FILIAL")[1] + TamSX3("CTH_CLVL")[1]
	
	Default Self:Code:= ""

    Self:SetContentType("application/json")

	If Len(AllTrim(Self:Code)) >= nLenFields
		Aadd(aFilter, {"CTH", "items",{"CTH_CLVL  = '" + SubStr(self:Code, TamSX3("CTH_FILIAL")[1] + 1, TamSX3("CTH_CLASSE")[1]) 							  + "'"}})
		oApiManager:SetApiFilter(aFilter) 		
		lRet := GetMain(@oApiManager, Self:aQueryString)
	Else
		lRet := .F.
		oApiManager:SetJsonError("400","Erro buscar o Note!", "O Note ID deve possuir pelo menos "+cValToChar(nLenFields)+" caracteres.",/*cHelpUrl*/,/*aDetails*/)
	EndIf

	If lRet
		Self:SetResponse( oApiManager:ToObjectJson() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()
	FreeObj(aFilter)

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
WSMETHOD POST Main WSRECEIVE Order, Page, PageSize, Fields WSSERVICE ClassValue

	Local aFilter		:= {}
	Local cError		:= ""
    Local lRet			:= .T.
	Local oApiManager	:= APIMANAGER():New("CTBS060","1.000")
	Local cBody 	   	:= Self:GetContent()	
	Local nLenFields	:= TamSX3("CTH_FILIAL")[1] + TamSX3("CTH_CLVL")[1]

	Self:SetContentType("application/json")

	oApiManager:SetApiMap(ApiMap())
	oApiManager:SetApiAlias({"CTH","items", "items"})

	If Len(AllTrim(Self:Code)) >= nLenFields
		If AOB->(Dbseek(Self:Code))
			lRet := ManutNote(@oApiManager, Self:aQueryString, 4,, self:Code, cBody)
		Else
			lRet := .F.
			oApiManager:SetJsonError("404","Erro ao alterar o Note!", "Note não encontrado.",/*cHelpUrl*/,/*aDetails*/)
		EndIf
	Else
		lRet := .F.
		oApiManager:SetJsonError("400","Erro ao alterar o Note!", "O Note ID deve possuir pelo menos "+cValToChar(nLenFields)+" caracteres.",/*cHelpUrl*/,/*aDetails*/)
	EndIf

	If lRet
		Aadd(aFilter, {"CTH", "items",{"CTH_CLVL = '" + AOB->AOB_IDNOTA + "'"}})
		oApiManager:SetApiFilter(aFilter) 		
		GetMain(@oApiManager, Self:aQueryString)
		Self:SetResponse( oApiManager:ToObjectJson() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()

Return lRet

/*/------------------/*/
Static Function GetMain(oApiManager, aQueryString, aFatherAlias, lHasNext, cIndexKey)

	Local aRelation 		:= {}
	Local aChildrenAlias	:= {}
	Local lRet 				:= .T.

	Default oApiManager		:= Nil	
	Default aQueryString	:={,}
	Default lHasNext		:= .T.
	Default cIndexKey		:= ""

	lRet := ApiMainGet(@oApiManager, aQueryString, aRelation , aChildrenAlias, aFatherAlias, cIndexKey, oApiManager:GetApiAdapter(), oApiManager:GetApiVersion(), lHasNext)

	FreeObj( aRelation )
	FreeObj( aChildrenAlias )
	FreeObj( aFatherAlias )

Return lRet
/*/{Protheus.doc} ApiMap
Estrutura a ser utilizada na classe ServicesApiManager

@return cRet	, caracter	, Mensagem de retorno de sucesso/erro.

@author		Squad Faturamento/CRM
@since		06/09/2018
@version	12.1.20
/*/

Static Function ApiMap()
	Local aApiMap		:= {}
	Local aStrAOB		:= {}

	aStrAOB			:=	{"CTH","Fields","items","items",;
							{;
								{"CompanyId"					, "Exp:cEmpAnt"									},;
								{"BranchId"						, "Exp:cFilAnt"									},;
								{"CompanyInternalId"			, "Exp:cEmpAnt, CTH_FILIAL, CTH_CLVL"			},;								
								{"Code"							, "CTH_CLVL"									},;
								{"InternalId"					, "CTH_FILIAL, CTH_CLVL"						},;
								{"Description"					, "CTH_DESC01"									},;
								{"Bloqued"						, "CTH_BLOQ  "									};
							},;
						}

	aStructAlias  := {aStrAOB}

	aApiMap := {"CTBS060","items","1.000","CTBS060",aStructAlias, "items"}

Return aApiMap
#include <sourcemod>
#include <SteamWorks>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[Telegram] Chat",
	author = "Alexbu444",
	description = "Send messages to Telegram",
	version = "1.0.0",
	url = "https://t.me/alexbu444"
};

#define PMP PLATFORM_MAX_PATH
char g_szLogFile[PMP];
char sPath[PMP];
char szToken[256];
char szChatId[256];

public void OnPluginStart() {
	RegConsoleCmd("sm_tg", Telegram);
	BuildPath(Path_SM, g_szLogFile, sizeof(g_szLogFile), "logs/tg_chat.log");
}

public void OnConfigsExecuted() {
    BuildPath(Path_SM, sPath, sizeof(sPath), "configs/telegram.cfg");
    KeyValues kv = new KeyValues("Telegram");
    
    if(!kv.ImportFromFile(sPath) || !kv.GotoFirstSubKey()) SetFailState("[Telegram] file is not found (%s)", sPath);
    
    kv.Rewind();
    
    if(kv.JumpToKey("Chat"))
    {
        kv.GetString("token", szToken, sizeof(szToken));
        kv.GetString("chatId", szChatId, sizeof(szChatId));
    }
    else
    {
        SetFailState("[Telegram] settings not found (%s)", sPath);
    }
        
    delete kv;
}

public Action Telegram(int iClient, int iArgC) {
	char szMessage[256], szQuery[256];
	GetCmdArgString(szMessage, sizeof(szMessage));

	FormatEx(szQuery, sizeof(szQuery), "https://api.telegram.org/bot%s/sendMessage?chat_id=%s&parse_mode=markdown&text=Игрок **%N** отправил сообщение - `%s`", szToken, szChatId, iClient, szMessage);
	Handle hRequest = SteamWorks_CreateHTTPRequest(k_EHTTPMethodPOST, szQuery);
	SteamWorks_SetHTTPRequestHeaderValue(hRequest, "User-Agent", "telegram");
	SteamWorks_SetHTTPCallbacks(hRequest, OnTransferComplete);
	SteamWorks_SendHTTPRequest(hRequest);

	return Plugin_Continue;
}

public int OnTransferComplete(Handle hRequest, bool bFailure, bool bRequestSuccessful, EHTTPStatusCode eStatusCode) {
	int sz;
	SteamWorks_GetHTTPResponseBodySize(hRequest, sz);
	char[] sBody = new char[sz];
	SteamWorks_GetHTTPResponseBodyData(hRequest, sBody, sz);
	LogToFileEx(g_szLogFile, "Telegram: %s", sBody);
}
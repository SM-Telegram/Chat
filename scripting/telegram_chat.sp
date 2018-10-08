#include <sourcemod>
#include <telegram>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[Telegram] Chat",
	author = "Alexbu444",
	description = "Send messages to Telegram",
	version = "1.1.0",
	url = "https://t.me/alexbu444"
};

public void OnPluginStart() {
	RegConsoleCmd("sm_tg", Telegram);
}

public Action Telegram(int iClient, int iArgC) {
	char sHostname[256], sMessage[256], sBuffer[256];
	GetConVarString(FindConVar("hostname"), sHostname, sizeof(sHostname));
	GetCmdArgString(sMessage, sizeof(sMessage));

	Format(sBuffer, sizeof(sBuffer), "`Сервер: %s / Игрок %s отправил сообщение: %s`", sHostname, iClient, sMessage);

	TelegramMsg(sBuffer);
	TelegramSend();

	return Plugin_Continue;
}
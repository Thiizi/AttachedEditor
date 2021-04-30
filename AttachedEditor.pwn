/* AttachedEditor by Thiizi
 *
 *  (c) Copyright 2021, https://github.com/Thiizi
 *
*/
#define FILTERSCRIPT
#include <a_samp>
#include <sscanf2>
#include <Pawn.CMD>

#define RGBAToARGB(%0) 					((((%0) << 24) & 0xFF000000) | (((%0) >>> 8) & 0xFFFFFF))
#define DIALOG_ATTACH_INDEX				(32500)
#define DIALOG_ATTACH_ADD				(32501)
#define DIALOG_ATTACH_CORPO				(32502)
#define DIALOG_ATTACH_EDIT				(32503)
#define DIALOG_ATTACH_COLORS 			(32504)
#define DIALOG_ATTACH_INPUTCOLOR		(32505)
#define DIALOG_ATTACH_LISTCOLORS		(32506)
#define DIALOG_ATTACH_INPUTCOLOR2		(32507)
#define DIALOG_ATTACH_LISTCOLORS2		(32508)
#define DIALOG_ATTACH_EXPORT			(32509)

static const AttachedColors[] = {
	0xFFFFFFFF, 0x000000FF, 0x2A77A1FF, 0x840410FF, 0x263739FF, 0x86446EFF, 0xD78E10FF, 0x4C75B7FF, 0xBDBEC6FF, 0x5E7072FF,
	0x46597AFF, 0x656A79FF, 0x5D7E8DFF, 0x58595AFF, 0xD6DAD6FF, 0x9CA1A3FF, 0x335F3FFF, 0x730E1AFF, 0x7B0A2AFF, 0x9F9D94FF,
	0x3B4E78FF, 0x732E3EFF, 0x691E3BFF, 0x96918CFF, 0x515459FF, 0x3F3E45FF, 0xA5A9A7FF, 0x635C5AFF, 0x3D4A68FF, 0x979592FF,
	0x421F21FF, 0x5F272BFF, 0x8494ABFF, 0x767B7CFF, 0x646464FF, 0x5A5752FF, 0x252527FF, 0x2D3A35FF, 0x93A396FF, 0x6D7A88FF,
	0x221918FF, 0x6F675FFF, 0x7C1C2AFF, 0x5F0A15FF, 0x193826FF, 0x5D1B20FF, 0x9D9872FF, 0x7A7560FF, 0x989586FF, 0xADB0B0FF,
	0x848988FF, 0x304F45FF, 0x4D6268FF, 0x162248FF, 0x272F4BFF, 0x7D6256FF, 0x9EA4ABFF, 0x9C8D71FF, 0x6D1822FF, 0x4E6881FF,
	0x9C9C98FF, 0x917347FF, 0x661C26FF, 0x949D9FFF, 0xA4A7A5FF, 0x8E8C46FF, 0x341A1EFF, 0x6A7A8CFF, 0xAAAD8EFF, 0xAB988FFF,
	0x851F2EFF, 0x6F8297FF, 0x585853FF, 0x9AA790FF, 0x601A23FF, 0x20202CFF, 0xA4A096FF, 0xAA9D84FF, 0x78222BFF, 0x0E316DFF,
	0x722A3FFF, 0x7B715EFF, 0x741D28FF, 0x1E2E32FF, 0x4D322FFF, 0x7C1B44FF, 0x2E5B20FF, 0x395A83FF, 0x6D2837FF, 0xA7A28FFF,
	0xAFB1B1FF, 0x364155FF, 0x6D6C6EFF, 0x0F6A89FF, 0x204B6BFF, 0x2B3E57FF, 0x9B9F9DFF, 0x6C8495FF, 0x4D8495FF, 0xAE9B7FFF,
	0x406C8FFF, 0x1F253BFF, 0xAB9276FF, 0x134573FF, 0x96816CFF, 0x64686AFF, 0x105082FF, 0xA19983FF, 0x385694FF, 0x525661FF,
	0x7F6956FF, 0x8C929AFF, 0x596E87FF, 0x473532FF, 0x44624FFF, 0x730A27FF, 0x223457FF, 0x640D1BFF, 0xA3ADC6FF, 0x86F0A0FF,
	0x3214AAFF,	0x184D3BFF,	0xAE4B99FF,	0x7E49D7FF,	0x4C436EFF,	0xFA24CCFF,	0xCE76BEFF,	0xA04E0AFF,	0x9F945CFF, 0xED5547FF,
};

new ATTACHED_LIST_COLORS[4000] = "Cor padrão";

enum E_ATTACHED_EDITOR
{
	E_INDEX,
	E_CORPO,
	E_MODELID,
	Float:E_PosX,
	Float:E_PosY,
	Float:E_PosZ,
	Float:E_PosRX,
	Float:E_PosRY,
	Float:E_PosRZ,
	Float:E_PosSX,
	Float:E_PosSY,
	Float:E_PosSZ,
	E_COLOR1,
	E_COLOR2,
}
new AttacheEditor[10][E_ATTACHED_EDITOR], SelectEdit[MAX_PLAYERS], bool:AttachedCommand[MAX_PLAYERS];

CMD:aedit(playerid)
{
	if(!AttachedCommand[playerid])
	{
		AttachedCommand[playerid] = true;
		for(new i; i < 10; i++) RemovePlayerAttachedObject(playerid, i);
	}
	ShowDialog(playerid, DIALOG_ATTACH_INDEX);
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
		case DIALOG_ATTACH_INDEX:
		{
			if(!response) return 1;
			if(listitem == 0) return ShowDialog(playerid, DIALOG_ATTACH_ADD);
			else
			{
				SelectEdit[playerid] = listitem - 1;
				return ShowDialog(playerid, DIALOG_ATTACH_EDIT);
			}
		}
		case DIALOG_ATTACH_ADD:
		{
			if(!response) return ShowDialog(playerid, DIALOG_ATTACH_INDEX);
			new modelid, index = -1;
			if(sscanf(inputtext, "i", modelid)) return ShowDialog(playerid, dialogid);

			for(new i; i < 10; i++)
			{
				if(!IsPlayerAttachedObjectSlotUsed(playerid, i))
				{
					index = i;	
					break;
				}
			}
			if(index == -1) return SendClientMessage(playerid, -1, "Todas as slots estão oculpadas, elimine um objeto.");
			SetPVarInt(playerid, "AttachedIndex", index);
			SetPVarInt(playerid, "AttachedModelid", modelid);
			ShowDialog(playerid, DIALOG_ATTACH_CORPO);
		}
		case DIALOG_ATTACH_CORPO:
		{
			if(!response) return ShowDialog(playerid, DIALOG_ATTACH_ADD);
			new index = GetPVarInt(playerid, "AttachedIndex");
			AttacheEditor[index][E_INDEX]   = index;
			AttacheEditor[index][E_CORPO]   = listitem + 1;
			AttacheEditor[index][E_MODELID] = GetPVarInt(playerid, "AttachedModelid");
			AttacheEditor[index][E_PosX]    = 0.0;
			AttacheEditor[index][E_PosY]    = 0.0;
			AttacheEditor[index][E_PosZ]    = 0.0;
			AttacheEditor[index][E_PosRX]   = 0.0;
			AttacheEditor[index][E_PosRY]   = 0.0;
			AttacheEditor[index][E_PosRZ]   = 0.0;
			AttacheEditor[index][E_PosSX]   = 1.0;
			AttacheEditor[index][E_PosSY]   = 1.0;
			AttacheEditor[index][E_PosSZ]   = 1.0;
			AttacheEditor[index][E_COLOR1]  = 0;
			AttacheEditor[index][E_COLOR2]  = 0;
			UpdateAttachedObject(playerid, index);
			ShowDialog(playerid, DIALOG_ATTACH_INDEX);
			DeletePVar(playerid, "AttachedIndex");
			DeletePVar(playerid, "AttachedModelid");
		}
		case DIALOG_ATTACH_EDIT:
		{
			if(!response || !IsPlayerAttachedObjectSlotUsed(playerid, SelectEdit[playerid])) return ShowDialog(playerid, DIALOG_ATTACH_INDEX);
			switch(listitem)
			{
				case 0: EditAttachedObject(playerid, SelectEdit[playerid]);
				case 1: ShowDialog(playerid, DIALOG_ATTACH_COLORS);
				case 2: ShowDialog(playerid, DIALOG_ATTACH_EXPORT);
				case 3:
				{
					new index = SelectEdit[playerid];
					RemovePlayerAttachedObject(playerid, AttacheEditor[index][E_INDEX]);
					AttacheEditor[index][E_INDEX]   = 0;
					AttacheEditor[index][E_CORPO]   = 0;
					AttacheEditor[index][E_MODELID] = 0;
					AttacheEditor[index][E_PosX]    = 0.0;
					AttacheEditor[index][E_PosY]    = 0.0;
					AttacheEditor[index][E_PosZ]    = 0.0;
					AttacheEditor[index][E_PosRX]   = 0.0;
					AttacheEditor[index][E_PosRY]   = 0.0;
					AttacheEditor[index][E_PosRZ]   = 0.0;
					AttacheEditor[index][E_PosSX]   = 0.0;
					AttacheEditor[index][E_PosSY]   = 0.0;
					AttacheEditor[index][E_PosSZ]   = 0.0;
					AttacheEditor[index][E_COLOR1]  = 0;
					AttacheEditor[index][E_COLOR2]  = 0;
					ShowDialog(playerid, DIALOG_ATTACH_INDEX);
				}
			}
		}
		case DIALOG_ATTACH_COLORS:
		{
			if(!response) return ShowDialog(playerid, DIALOG_ATTACH_EDIT);
			switch(listitem)
			{
				case 0: ShowDialog(playerid, DIALOG_ATTACH_INPUTCOLOR);
				case 1: ShowDialog(playerid, DIALOG_ATTACH_LISTCOLORS);
			}
		}
		case DIALOG_ATTACH_INPUTCOLOR:
		{
			if(!response) return ShowDialog(playerid, DIALOG_ATTACH_COLORS);
			new color, index = SelectEdit[playerid];
			if(sscanf(inputtext, "h", color)) return ShowDialog(playerid, dialogid);
			AttacheEditor[index][E_COLOR1] = RGBAToARGB(color);
			UpdateAttachedObject(playerid, index);
			ShowDialog(playerid, DIALOG_ATTACH_INPUTCOLOR2);
		}
		case DIALOG_ATTACH_LISTCOLORS:
		{
			if(!response) return ShowDialog(playerid, DIALOG_ATTACH_COLORS);
			new index = SelectEdit[playerid];
			AttacheEditor[index][E_COLOR1] = (listitem == 0) ? 0 : RGBAToARGB(AttachedColors[listitem]);
			UpdateAttachedObject(playerid, index);
			ShowDialog(playerid, DIALOG_ATTACH_LISTCOLORS2);
		}
		case DIALOG_ATTACH_INPUTCOLOR2:
		{
			if(!response) return ShowDialog(playerid, DIALOG_ATTACH_INPUTCOLOR);
			new color, index = SelectEdit[playerid];
			if(sscanf(inputtext, "h", color)) return ShowDialog(playerid, dialogid);
			AttacheEditor[index][E_COLOR2] = RGBAToARGB(color);
			UpdateAttachedObject(playerid, index);
			ShowDialog(playerid, DIALOG_ATTACH_EDIT);
		}
		case DIALOG_ATTACH_LISTCOLORS2:
		{
			if(!response) return ShowDialog(playerid, DIALOG_ATTACH_LISTCOLORS);
			new index = SelectEdit[playerid];
			AttacheEditor[index][E_COLOR2] = (listitem == 0) ? 0 : RGBAToARGB(AttachedColors[listitem]);
			UpdateAttachedObject(playerid, index);
			ShowDialog(playerid, DIALOG_ATTACH_EDIT);
		}
		case DIALOG_ATTACH_EXPORT:
		{
			if(!response) return ShowDialog(playerid, DIALOG_ATTACH_EDIT);
			new SaveName[120];
			if(sscanf(inputtext, "s[120]", SaveName)) return ShowDialog(playerid, dialogid);
			new File:ExportFile = fopen("SavedAttachedEditor.pwn", io_append), ExportText[330], index = SelectEdit[playerid];
			format(ExportText, sizeof ExportText, "SetPlayerAttachedObject(playerid, %d, %d, %d, %f, %f, %f, %f, %f, %f, %f, %f, %f, %d, %d); // %s\n\n",
			AttacheEditor[index][E_INDEX],
			AttacheEditor[index][E_MODELID],
			AttacheEditor[index][E_CORPO],
			AttacheEditor[index][E_PosX],
			AttacheEditor[index][E_PosY],
			AttacheEditor[index][E_PosZ],
			AttacheEditor[index][E_PosRX],
			AttacheEditor[index][E_PosRY],
			AttacheEditor[index][E_PosRZ],
			AttacheEditor[index][E_PosSX],
			AttacheEditor[index][E_PosSY],
			AttacheEditor[index][E_PosSZ],
			AttacheEditor[index][E_COLOR1],
			AttacheEditor[index][E_COLOR2],
			SaveName);
			fwrite(ExportFile, ExportText);
			fclose(ExportFile);
			SendClientMessage(playerid, -1, "Posição do objeto foi salvo em {ED5547}scriptfiles/SavedAttachedEditor.pwn");
			ShowDialog(playerid, DIALOG_ATTACH_EDIT);
		}
	}
	return 1;
}

ShowDialog(playerid, dialogid)
{
	switch(dialogid)
	{
		case DIALOG_ATTACH_INDEX:
		{
			new dialog[820] = "Adicionar objeto";
			for(new i; i < 10; i++)
			{
				if(IsPlayerAttachedObjectSlotUsed(playerid, i))
					format(dialog, sizeof dialog, "%s\n{ED5547}%02d.{FFFFFF} Objeto: %d", dialog, i + 1, AttacheEditor[i][E_MODELID]);
			}
			ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_LIST, "{ED5547}Attached Editor", dialog, "Selecionar", "Cancelar");
		}

		case DIALOG_ATTACH_ADD:
			ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_INPUT, "{ED5547}Attached Editor{FFFFFF} - Adicionar objeto", "{FFFFFF}Coloque o ID do objeto que deseja adicionar.\n\nVocê pode procurar por objetos em {ED5547}https://dev.prineside.com/gtasa_samp_model_id/{FFFFFF}.", "Adicionar", "Voltar");

		case DIALOG_ATTACH_CORPO:
			ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_LIST, "{ED5547}Attached Editor{FFFFFF} - Selecione a parte do corpo", "\
				1. Coluna vertebral\n\
				2. Cabeça\n\
				3. Braço esquerdo\n\
				4. Braço direito\n\
				5. Mão esquerda\n\
				6. Mão direita\n\
				7. Coxa esquerda\n\
				8. Coxa direita\n\
				9. Pé esquerdo\n\
				10. Pé direito\n\
				11. Panturrilha direita\n\
				12. Panturrilha esquerda\n\
				13. Antebraço esquerdo\n\
				14. Antebraço direito\n\
				15. Ombro esquerdo\n\
				16. Ombro direito\n\
				17. Pescoço\n\
				18. Mandíbula", "Selecionar", "Voltar");

		case DIALOG_ATTACH_EDIT:
			ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_LIST, "{ED5547}Attached Editor{FFFFFF} - Editar objeto", "Editar posição\nAlterar cor\nSalvar objeto\nEliminar objeto", "Selecionar", "Voltar");

		case DIALOG_ATTACH_COLORS:
			ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_LIST, "{ED5547}Attached Editor{FFFFFF} - Cores", "Digitar uma cor\nLista de cores", "Selecionar", "Voltar");

		case DIALOG_ATTACH_INPUTCOLOR:
			ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_INPUT, "{ED5547}Attached Editor{FFFFFF} - Alterar cor #1", "{FFFFFF}Coloque a cor que deseja em hexadecimal. Por exemplo: 0xFF0000FF.\n\nVocê pode pesquisar por {ED5547}Color Picker{FFFFFF} no Google e copiar a cor.", "Adicionar", "Voltar");

		case DIALOG_ATTACH_LISTCOLORS:
			ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_LIST, "{ED5547}Attached Editor{FFFFFF} - Alterar cor #1", ATTACHED_LIST_COLORS, "Selecionar", "Voltar");

		case DIALOG_ATTACH_INPUTCOLOR2:
			ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_INPUT, "{ED5547}Attached Editor{FFFFFF} - Alterar cor #2", "{FFFFFF}Coloque a cor que deseja em hexadecimal.\nPor exemplo: 0xFF0000FF.\n\nVocê pode pesquisar por {ED5547}Color Picker{FFFFFF} no Google.", "Adicionar", "Voltar");

		case DIALOG_ATTACH_LISTCOLORS2:
			ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_LIST, "{ED5547}Attached Editor{FFFFFF} - Alterar cor #2", ATTACHED_LIST_COLORS, "Selecionar", "Voltar");

		case DIALOG_ATTACH_EXPORT:
			ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_INPUT, "{ED5547}Attached Editor{FFFFFF} - Salvar objeto", "{FFFFFF}Coloque o nome do projeto que queira salvar.", "Salvar", "Voltar");
	}
	return 1;
}

stock UpdateAttachedObject(playerid, index)
{
	if(!AttacheEditor[index][E_MODELID]) return 0;
	RemovePlayerAttachedObject(playerid, AttacheEditor[index][E_INDEX]);
	SetPlayerAttachedObject(playerid, AttacheEditor[index][E_INDEX],
		AttacheEditor[index][E_MODELID],
		AttacheEditor[index][E_CORPO],
		AttacheEditor[index][E_PosX],
		AttacheEditor[index][E_PosY],
		AttacheEditor[index][E_PosZ],
		AttacheEditor[index][E_PosRX],
		AttacheEditor[index][E_PosRY],
		AttacheEditor[index][E_PosRZ],
		AttacheEditor[index][E_PosSX],
		AttacheEditor[index][E_PosSY],
		AttacheEditor[index][E_PosSZ],
		AttacheEditor[index][E_COLOR1],
		AttacheEditor[index][E_COLOR2]);
	return 1;
}

public OnPlayerEditAttachedObject(playerid, response, index, modelid, boneid, Float:fOffsetX, Float:fOffsetY, Float:fOffsetZ, Float:fRotX, Float:fRotY, Float:fRotZ, Float:fScaleX, Float:fScaleY, Float:fScaleZ)
{
	if(response == EDIT_RESPONSE_FINAL)
	{
		AttacheEditor[index][E_PosX]  = fOffsetX;
		AttacheEditor[index][E_PosY]  = fOffsetY;
		AttacheEditor[index][E_PosZ]  = fOffsetZ;
		AttacheEditor[index][E_PosRX] = fRotX;
		AttacheEditor[index][E_PosRY] = fRotY;
		AttacheEditor[index][E_PosRZ] = fRotZ;
		AttacheEditor[index][E_PosSX] = fScaleX;
		AttacheEditor[index][E_PosSY] = fScaleY;
		AttacheEditor[index][E_PosSZ] = fScaleZ;
		UpdateAttachedObject(playerid, index);
		ShowDialog(playerid, DIALOG_ATTACH_EDIT);
	}
	else if(response == EDIT_RESPONSE_CANCEL)
	{
		UpdateAttachedObject(playerid, index);
		ShowDialog(playerid, DIALOG_ATTACH_EDIT);
	}
	return 1;
}

public OnFilterScriptInit()
{
	for(new color = 1; color < sizeof AttachedColors; color++) format(ATTACHED_LIST_COLORS, sizeof ATTACHED_LIST_COLORS, "%s\n{%06x}||||||||||||", ATTACHED_LIST_COLORS, AttachedColors[color] >>> 8);
	SendClientMessageToAll(-1, "AttachedEditor carregado! Escreva {ED5547}/aedit{FFFFFF} para começar a utilizar.");
	return 1;
}

enableSaving [false,false];

if(isDedicated) exitWith {};
showChat false;
waitUntil{!(isNull player)};

// Freeze player
player enableSimulation false;

[] spawn
{
	waitUntil{sleep 0.05; (!isNil "A3PL_ServerLoaded")};
	waitUntil{sleep 0.05; A3PL_ServerLoaded};

	Player_Loaded = false;

	waitUntil {sleep 0.05; ((vehicle player) isEqualTo player)};
	waitUntil {sleep 0.05; !isNil "A3PL_Player_Initialize"};

	[] call A3PL_Player_Initialize;
};
//DELETE ALL BELOW LATER
//DELETE ALL BELOW LATER
//DELETE ALL BELOW LATER
//DELETE ALL BELOW LATER
//DELETE ALL BELOW LATER

AJSDASJDKASJDFGU = true;
private ["_folder"]; _folder = "A3PL.Backend"; [_folder] call (compile preprocessFileLineNumbers format ["\%1\init.sqf",_folder]);

[] spawn Server_Setup_Init;
player setVariable ["player_inventory",[]];
player setVariable ["player_cash",50000];
player setVariable ["player_bank",50000];
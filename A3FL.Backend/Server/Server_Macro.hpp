/*
	ArmA 3 Fishers Life
	Code written by ArmA 3 Fishers Life Development Team
	@Copyright ArmA 3 Fishers Life (https://www.arma3fisherslife.net)
	YOU ARE NOT ALLOWED TO COPY OR DISTRIBUTE THE CONTENT OF THIS FILE WITHOUT AUTHOR AGREEMENT
	More informations : https://www.bistudio.com/community/game-content-usage-rules
*/

#define SUB(var1,var2) var1 = var1 - var2
#define ADD(var1,var2) var1 = var1 + var2
#define SEL(ARRAY,INDEX) (ARRAY select INDEX)

/*
	remoteExec Section
	When uncommented it enables proper testing via local testing
	Otherwise leave it commented out for "LIVE" servers
*/
#define DEBUG 1

#ifdef DEBUG
#define RCLIENT 0
#else
#define RCLIENT -2
#endif

#define RSERV 2
#define RANY 0

//Namespace Macros
#define SVAR_MNS missionNamespace setVariable 
#define SVAR_UINS uiNamespace setVariable 
#define SVAR_PNS parsingNamespace setVariable 
#define GVAR_MNS missionNamespace getVariable 
#define GVAR_UINS uiNamespace getVariable

//Scripting Macros
#define CONST(var1,var2) var1 = compileFinal (if(typeName var2 == "STRING") then {var2} else {str(var2)})
#define CONSTVAR(var) var = compileFinal (if(typeName var == "STRING") then {var} else {str(var)})
#define FETCH_CONST(var) (call var)
#define PVAR_ALL(var) publicVariable var
#define PVAR_SERV(var) publicVariableServer var
#define PVAR_ID(var,id) id publicVariableClient var
#define GVAR getVariable
#define SVAR setVariable
#define RIFLE primaryWeapon player
#define RIFLE_ITEMS primaryWeaponItems player
#define PISTOL handgunWeapon player
#define PISTOL_ITEMS handgunItems player
#define LAUNCHER secondaryWeapon player
#define EXTDB "extDB3" callExtension
#define EXTDB_SETTING(TYPE,SETTING) TYPE(configFile >> "Life_Server_Settings" >> "EXTDB" >> SETTING)
#define EXTDB_FAILED(MESSAGE) \
	life_server_extDB_notLoaded = [true,##MESSAGE]; \
	PVAR_ALL("life_server_extDB_notLoaded"); \
	diag_log MESSAGE;

//Display Macros
#define CONTROL(disp,ctrl) ((findDisplay ##disp) displayCtrl ##ctrl)
#define CONTROL_DATA(ctrl) (lbData[##ctrl,(lbCurSel ##ctrl)])
#define CONTROL_DATAI(ctrl,index) ctrl lbData index

//System Macros
#define grpPlayer group player
#define steamid getPlayerUID player

//Condition Macros
#define EQUAL(condition1,condition2) condition1 isEqualTo condition2
#define KINDOF_ARRAY(a,b) [##a,##b] call {_veh = _this select 0;_types = _this select 1;_res = false; {if (_veh isKindOf _x) exitwith { _res = true };} forEach _types;_res}

//Config Macros
#define FETCH_CONFIG(TYPE,CFG,SECTION,CLASS,ENTRY) TYPE(configFile >> CFG >> SECTION >> CLASS >> ENTRY)
#define FETCH_CONFIG2(TYPE,CFG,CLASS,ENTRY) TYPE(configFile >> CFG >> CLASS >> ENTRY)
#define FETCH_CONFIG3(TYPE,CFG,SECTION,CLASS,ENTRY,SUB) TYPE(configFile >> CFG >> SECTION >> CLASS >> ENTRY >> SUB)
#define FETCH_CONFIG4(TYPE,CFG,SECTION,CLASS,ENTRY,SUB,SUB2) TYPE(configFile >> CFG >> SECTION >> CLASS >> ENTRY >> SUB >> SUB2)
#define M_CONFIG(TYPE,CFG,CLASS,ENTRY) TYPE(missionConfigFile >> CFG >> CLASS >> ENTRY)
#define BASE_CONFIG(CFG,CLASS) inheritsFrom(configFile >> CFG >> CLASS)
#define CONFIG_VEHICLES "CfgVehicles"
#define CONFIG_WEAPONS "CfgWeapons"
#define CONFIG_MAGAZINES "CfgMagazines"
#define CONFIG_GLASSES "CfgGlasses"
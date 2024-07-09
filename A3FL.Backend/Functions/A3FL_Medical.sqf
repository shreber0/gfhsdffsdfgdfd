/*
	ArmA 3 Fishers Life
	Code written by ArmA 3 Fishers Life Development Team
	@Copyright ArmA 3 Fishers Life (https://www.arma3fisherslife.net)
	YOU ARE NOT ALLOWED TO COPY OR DISTRIBUTE THE CONTENT OF THIS FILE WITHOUT AUTHOR AGREEMENT
	More informations : https://www.bistudio.com/community/game-content-usage-rules
*/

#define LOGLIMIT 12
#define MAXBLOODLVL 5000
#define RESPAWNTIME 600
#define BLOODPERBAG 2000

["A3PL_Medical_Loop",
{
	private _bloodLevel = player getVariable ["A3PL_Medical_Blood",MAXBLOODLVL];
	private _isAlive = isNull (player getVariable["deadBody",objNull]);
	private _wounds = player getVariable ["A3PL_Wounds",[]];
	if(!_isAlive) exitWith {};
	if (_bloodLevel > 0) then {
		private _bloodChange = 0; {
			for "_i" from 1 to (count _x-1) do {
				private _woundArr = _x select _i;
				private _wound = _woundArr select 0;
				private _isTreated = _woundArr select 1;
				if (!_isTreated) then {
					_bloodChange = _bloodChange - ([_wound,"bloodLoss"] call A3PL_Config_GetWound);
				};
			};
		} foreach _wounds;
		if (_bloodChange != 0) then {[player,_bloodChange] call A3PL_Medical_ApplyVar;};
	};
	["\A3PL_Common\GUI\medical\overlay_blood.paa",1,(_bloodLevel/MAXBLOODLVL)] call A3PL_HUD_SetOverlay;
	if(_bloodLevel < MAXBLOODLVL) then {
		player setVariable["bloodOverlay",true,true];
	} else {
		player setVariable["bloodOverlay",false,true];
	};
}] call Server_Setup_Compile;

["A3PL_Medical_Hit",
{
	params ["_unit"];
	private ["_sHit","_sDamage","_sBullet"];
	private _unconscious = !(player getVariable["A3PL_Medical_Alive",true]);
	private _timeRemain = player getVariable ["TimeRemaining",600];
	private _customDamageBullets = [];
	if(_unconscious && {_timeRemain < 580}) exitWith {player setVariable ["DoubleTapped",true,true];};

	private _getHit = _unit getVariable ["getHit",[]];
	private _tmpDmg = 0;
	A3PL_HitTime = nil;
	_unit setVariable ["getHit",nil,false];

	{
		private ["_sel","_dmg","_bullet"];
		_sel = _x select 0;
		_dmg = _x select 1;
		_bullet = _x select 2;
		if (_bullet isEqualTo "") then {
			if (_dmg > _tmpDmg) then {
				_sHit = _sel;
				_sDamage = _dmg;
				_sBullet = _bullet;
				_tmpDmg = _dmg;
			};
		} else {
			if ((_dmg > _tmpDmg) && (_sel != "")) then {
				_sHit = _sel;
				_sDamage = _dmg;
				_sBullet = _bullet;
				_tmpDmg = _dmg;
			};
		};
	} foreach _getHit;
	if (isNil "_sHit") exitwith {};
	if (_sBullet IN ["A3FL_PepperSpray_Ball","A3PL_PickAxe_Bullet","A3PL_Shovel_Bullet","A3PL_Fireaxe_Bullet","A3PL_Machete_Bullet","A3PL_Axe_Bullet","A3FL_BaseballBat_Bullet","A3FL_PoliceBaton_Bullet","A3FL_GolfDriver"]) then {_sDamage = 0;};
	if ((isBurning player) && {_sBullet isEqualTo ""} && {_sHit IN ["spine1","spine2","spine3"]}) then {_sBullet = "FireDamage";};

	private _handles = [_sHit,_sDamage,_sBullet] call A3PL_Medical_GenerateWounds;
	if(_handles) then {
		private _applyDamage = [_sHit,_sBullet,_sDamage] call A3PL_Medical_GetDamage;
		private _curHit = 0;
		if(_sHit isEqualTo "pelvis") then {_sHit = "legs";};
		if (_sHit isEqualTo "") then {
			_curHit = damage _unit;
			if(_curHit + _applyDamage < 0.8) then {
				_unit setDamage _applyDamage;
			} else {
				_unit setDamage 0.8;
			};
		} else {
			_curHit = _unit getHit _sHit;
			if(_curHit + _applyDamage < 0.8) then {
				_unit setHit [_sHit, _applyDamage];
			} else {
				_unit setHit [_sHit, 0.8];
			};
		};
	};
}] call Server_Setup_Compile;

["A3PL_Medical_GenerateWounds",
{
	params ["_sHit", "_sDamage", "_sBullet"];
 	if(_sBullet isEqualTo "A3FL_PepperSpray_Ball") exitwith {
		private _masks = ["G_Balaclava_combat","A3PL_FD_Mask"];
		if(!((goggles player) IN _masks)) then {
			if(!([player,"head","pepper_spray"] call A3PL_Medical_HasWound)) then {
				[player,"head","pepper_spray"] call A3PL_Medical_ApplyWound;
			};
		};
		false;
	};
	if(_sBullet IN ["A3FL_BaseballBat_Bullet","A3FL_PoliceBaton_Bullet","A3FL_GolfDriver"]) exitWith {
		[player,([_sHit] call A3PL_Medical_GetHitPart),"bruise"] call A3PL_Medical_ApplyWound;
		private _chance = random 100;
		if(_chance > 40) then {
			[] call A3PL_Lib_Ragdoll;
		};
		false;
	};
	if(_sBullet IN ["A3PL_PickAxe_Bullet","A3PL_Shovel_Bullet","A3PL_Fireaxe_Bullet","A3PL_Machete_Bullet","A3PL_Axe_Bullet"]) exitWith {
		[player,([_sHit] call A3PL_Medical_GetHitPart),"cut"] call A3PL_Medical_ApplyWound;
		private _chance = random 100;
		if(_chance >= 40) then {
			[] call A3PL_Lib_Ragdoll;
		};
		false;
	};

	if((_sHit isEqualTo "") && (_sBullet isEqualTo "") && (vehicle player != player)) exitWith {
		if (_sDamage > 0.005) then
		{
			if(((driver (vehicle player)) isEqualTo player) && (_sDamage > 0.009)) then {
				_fifr = ["fifr"] call A3PL_Lib_FactionPlayers;
				if((count(_fifr) >= 5) && ((vehicle player) isKindOf "Car")) then {
					_chance = random 100;
					if(_chance > 85) then {
						(vehicle player) setVariable["trapped",true,true];
						["You have crashed and are trapped inside your vehicle, FIFR has been called!","red"] call A3PL_Player_Notification;
						["911: Someone is trapped in their vehicle, check your map for the location!","red","fifr",3] call A3PL_Lib_JobMessage;
						[position player, "Trapped in Vehicle","ColorRed"] remoteExec ["A3PL_Lib_CreateMarker",_fifr];
					};
					_fireChance = random 100;
					if((_sDamage > 0.04) && (_fireChance > 90)) then {
						[(getPosATL player)] call A3PL_Fire_StartFire;
						["Your vehicle has gone on fire due to a crash, FIFR has been called!","red"] call A3PL_Player_Notification;
						["911: A vehicle fire has been reported, check your map for the location!","red","fifr",3] call A3PL_Lib_JobMessage;
						[position player, "Vehicle Fire","ColorRed"] remoteExec ["A3PL_Lib_CreateMarker",_fifr];
					};
				};
			};
			_injuries = round (random 3);
			for "_i" from 1 to _injuries do {
				_parts = ["torso","pelvis","left upper leg","left lower leg","right upper leg","head","chest","right lower leg","right upper arm","left upper arm","left lower arm","right lower arm"];
				_part = _parts select (round (random [0,5,11]));
				switch (true) do
				{
					case (_part isEqualTo "head"): { if (!([player,_part,"concussion"] call A3PL_Medical_HasWound)) then {[player,"head","concussion"] call A3PL_Medical_ApplyWound;};};
					default {[player,_part,(["cut","bruise","wound_minor"] call A3PL_Lib_ArrayRandom)] call A3PL_Medical_ApplyWound;};
				};
			};
		};
		if (_sDamage >= 0.016) then {
			_injuries = round (random 4);
			for "_i" from 1 to _injuries do {
				_parts = ["torso","pelvis","left upper leg","left lower leg","right upper leg","chest","right lower leg","head","right upper arm","left lower arm","right lower arm","left upper arm"];
				_part = _parts select (round (random [0,5,11]));
				switch (true) do {
					case (_part isEqualTo "head"): { if (!([player,_part,"concussion"] call A3PL_Medical_HasWound)) then {[player,"head","concussion"] call A3PL_Medical_ApplyWound;};};
					default { [player,_part,(["cut","bruise","wound_minor","wound_major","bone_broken","bone_broken"] call A3PL_Lib_ArrayRandom)] call A3PL_Medical_ApplyWound; };
				};
			};
		};
		true;
	};
	if((_sHit IN ["pelvis","head"]) && (_sBullet isEqualTo "") && ((vehicle player) isEqualTo player)) exitWith {
		if ((_sDamage >= 0.1) && (_sDamage < 0.25)) then {
			_injuries = round (random 2);
			for "_i" from 1 to _injuries do {
				_parts = ["left lower leg","right upper leg","left lower leg","pelvis","left upper leg","right upper leg","left upper leg","right lower leg","left lower leg","left upper leg","head","right upper leg","right lower leg","head","head","right lower leg"];
				_part = _parts select (round (random [0,7,15]));
				if(_part isEqualTo "head") then {
					[player,"head","concussion"] call A3PL_Medical_ApplyWound;
				} else {
					[player,_part,(["cut","bruise","wound_minor"] call A3PL_Lib_ArrayRandom)] call A3PL_Medical_ApplyWound;
				};
			};
		};
		if (_sDamage > 0.25) then
		{
			_injuries = 1 + round (random 1);
			for "_i" from 1 to _injuries do
			{
				_parts = ["left lower leg","right upper leg","left lower leg","left upper leg","pelvis","left upper leg","right lower leg","left lower leg","left upper leg","head","right upper leg","right upper leg","right lower leg","head","head","right lower leg"];
				_part = _parts select (round (random [0,7,15]));
				if(_part isEqualTo "head") then {
					[player,"head","concussion"] call A3PL_Medical_ApplyWound;
				} else {
					[player,_part,(["cut","bruise","wound_major","bone_broken"] call A3PL_Lib_ArrayRandom)] call A3PL_Medical_ApplyWound;
				};
			};
		};
		true;
	};
	if((_sHit IN ["pelvis","head"]) && (_sBullet isEqualTo "") && ((vehicle player) isEqualTo player)) exitWith {
		if ((_sDamage >= 0.1) && (_sDamage < 0.25)) then {
			_injuries = round (random 2);
			for "_i" from 1 to _injuries do {
				_parts = ["left lower leg","right upper leg","left lower leg","pelvis","left upper leg","right upper leg","left upper leg","right lower leg","left lower leg","left upper leg","head","right upper leg","right lower leg","head","head","right lower leg"];
				_part = _parts select (round (random [0,7,15]));
				if(_part isEqualTo "head") then {
					[player,"head","concussion"] call A3PL_Medical_ApplyWound;
				} else {
					[player,_part,(["cut","bruise","wound_minor"] call A3PL_Lib_ArrayRandom)] call A3PL_Medical_ApplyWound;
				};
			};
		};
		if (_sDamage > 0.25) then
		{
			_injuries = 1 + round (random 1);
			for "_i" from 1 to _injuries do
			{
				_parts = ["left lower leg","right upper leg","left lower leg","left upper leg","pelvis","left upper leg","right lower leg","left lower leg","left upper leg","head","right upper leg","right upper leg","right lower leg","head","head","right lower leg"];
				_part = _parts select (round (random [0,7,15]));
				if(_part isEqualTo "head") then {
					[player,"head","concussion"] call A3PL_Medical_ApplyWound;
				} else {
					[player,_part,(["cut","bruise","wound_major","bone_broken"] call A3PL_Lib_ArrayRandom)] call A3PL_Medical_ApplyWound;
				};
			};
		};
		true;
	};

	if(_sBullet isEqualTo "FireDamage") exitWith {
		_part = ["torso","torso","torso","pelvis","left upper leg","left lower leg","right upper leg","chest","right lower leg","right upper arm","torso","right lower arm","left lower arm","left upper arm","right lower arm","left lower arm","head","right lower arm","head","head","head"] call A3PL_Lib_ArrayRandom;
		if (_part isEqualTo "chest") then {
			if(((goggles player) isEqualTo "A3PL_FD_Mask") && (_vest isEqualTo "A3PL_FD_Oxygen")) then {
				if((uniform player) != "A3PL_FD_Protective_Uniform") then {
					_wound = (["burn_second","burn_first","burn_second"] call A3PL_Lib_ArrayRandom);
					if (!([player,_part,_wound] call A3PL_Medical_HasWound)) then {[player,_part,_wound] call A3PL_Medical_ApplyWound;};
				};
			} else {
				if((uniform player) isEqualTo "A3PL_FD_Protective_Uniform") then {
					_wound = (["smoke_minor","smoke_major"] call A3PL_Lib_ArrayRandom);
					if (!([player,_part,_wound] call A3PL_Medical_HasWound)) then {[player,_part,_wound] call A3PL_Medical_ApplyWound;};
				} else {
					_wound = (["smoke_minor","smoke_major","burn_second","burn_first","burn_second"] call A3PL_Lib_ArrayRandom);
					if (!([player,_part,_wound] call A3PL_Medical_HasWound)) then {[player,_part,_wound] call A3PL_Medical_ApplyWound;};
				};
			};
		} else {
			if((uniform player) != "A3PL_FD_Protective_Uniform") then {
				[player,_part,(["burn_first","burn_second"] call A3PL_Lib_ArrayRandom)] call A3PL_Medical_ApplyWound;
			};
		};
		false;
	};
	if(!(_sBullet isEqualTo "") && {!(_sHit isEqualTo "")}) exitWith {
		_bulletWound = [_sBullet] call A3PL_Medical_GetBulletWound;
		if(_sHit IN ["neck","spine3","body"]) then {
			if((vest player) isEqualTo "A3PL_SuicideVest") then {[] call A3PL_Criminal_SuicideVest;};
			[player,"chest",_bulletWound,_sBullet] call A3PL_Medical_ApplyWound;
		} else {
			[player,([_sHit] call A3PL_Medical_GetHitPart),_bulletWound,_sBullet] call A3PL_Medical_ApplyWound;
		};
		true;
	};
	false;
}] call Server_Setup_Compile;

["A3PL_Medical_ApplyWound",
{
	private _player = param [0,player];
	private _part = param [1,""];
	private _wound = param [2,""];
	private _bullet = param [3,""];
	private _partF = false;
	private _set = true;
	private _wounds = _player getVariable ["A3PL_Wounds",[]];

	{
		if ((_x select 0) isEqualTo _part) then {
			if ((count _x) > 4) exitwith {_partF=true;_set=false;};
			_x pushback [_wound,false];
			_partF = true;
		};
	} foreach _wounds;

	if (!_partF) then {_wounds pushback [_part,[_wound,false]];};

	if (_set) then {
		_player setVariable ["A3PL_Wounds",_wounds,true];
		[_player,format ["%1 sustained a %2 on the %3",(_player getVariable ["name",name _player]),([_wound,"name"] call A3PL_Config_GetWound),_part],[1, 0, 0, 1]] call A3PL_Medical_AddLog;
		private _bloodLoss = [_wound,"bloodLossInstant"] call A3PL_Config_GetWound;
		if (_bloodLoss > 0) then {
			_bloodLoss = [_bloodLoss,_part,_wound] call A3PL_Medical_BloodLoss;
			[_player,-(_bloodLoss)] call A3PL_Medical_ApplyVar;
		};
	};

	if(_wound isEqualTo "concussion") then {[] spawn A3PL_Medical_Concussion;};
	if(_wound isEqualTo "pepper_spray") then {[] spawn A3PL_Medical_PepperSpray;};

	private _format = switch(_part) do {
		default {"You are wounded"};
		case ("head"): {"You are wounded at the head"};
		case ("chest"): {"You are wounded at the chest"};
		case ("torso"): {"You are wounded at the torso"};
		case ("pelvis"): {"You are wounded at the pelvis"};
		case ("left upper leg"): {"You are wounded at the left thigh"};
		case ("left lower leg"): {"You are wounded at the left leg"};
		case ("right upper leg"): {"You are wounded at the right thigh"};
		case ("right lower leg"): {"You are wounded at the right leg"};
		case ("left upper arm"): {"You are wounded at the left arm"};
		case ("left lower arm"): {"You are wounded at the left forearm"};
		case ("right upper arm"): {"You are wounded at the right arm"};
		case ("right lower arm"): {"You are wounded at the right forearm"};
	};
	[_format, "red"] call A3PL_Player_Notification;
}] call Server_Setup_Compile;

["A3PL_Medical_ApplyVar",
{
	private _player = param [0,player];
	private _change = param [1,0];
	private _bloodValue = _player getVariable ["A3PL_Medical_Blood",5000];
	private _newValue = _bloodValue + _change;
	if (_newValue < 0) then {_newValue = 0;};
	if (_newValue > 5000) then {_newValue = 5000;};
	if (_newValue isEqualTo 0) then {
		if (player getVariable["A3PL_Medical_Alive",true]) then {_player setDamage 1;};
	};
	if (_player isEqualTo player) then {
		["\A3PL_Common\GUI\medical\overlay_blood.paa",1,(_newValue/5000)] call A3PL_HUD_SetOverlay;
		_player setVariable["bloodOverlay",true,true];
	};
	_player setVariable ["A3PL_Medical_Blood",_newValue,true];
	[(findDisplay 73)] call A3PL_Medical_LoadParts;
}] call Server_Setup_Compile;

["A3PL_Medical_TreatWoundButton",
{
	disableSerialization;
	private _display = findDisplay 73;
	private _isEMS = (player getVariable ["job","unemployed"]) isEqualTo "fifr";
	private _player = missionNameSpace getVariable ["A3PL_MedicalVar_Target",objNull];
	private _part = missionNameSpace getVariable ["A3PL_MedicalVar_CurrentPart",nil];

	if (isNull _player) exitwith {["Error: Unknown target"] call A3PL_Player_Notification;};
	if (isNil "_part") exitwith {["Unable to determine the selected body part"] call A3PL_Player_Notification;};

	private _control = _display displayCtrl 1502;
	if ((lbCurSel _control) isEqualTo -1) exitwith {["Please select a treatment"] call A3PL_Player_Notification;};
	private _item = _control lbData (lbCurSel _control);
	
	if(_item isEqualTo "medS_bloodbag") exitWith {
		if (!([_item,1] call A3PL_Inventory_Has)) exitwith {["You don't have that"] call A3PL_Player_Notification;};
		if (_isEMS) then
		{
			if ((_player getVariable ["A3PL_Medical_Blood",MAXBLOODLVL]) >= 5000) exitwith {["This patient already has a maximum of blood"] call A3PL_Player_Notification;};
			if (player_itemClass == _item) then {[] call A3PL_Inventory_Clear};
			["medS_bloodbag",-1] call A3PL_Inventory_Add;
			[_player,BLOODPERBAG] call A3PL_Medical_ApplyVar;
			["You administered a blood test to this patient!","green"] call A3PL_Player_Notification;
			[player,format ["EMS %1 administered a blood bag",(player getVariable ["name",name player])],[0, 1, 0, 1]] call A3PL_Medical_AddLog;
			[(findDisplay 73),_player] call A3PL_Medical_LoadParts;
			[player, 1] call A3PL_Level_AddXP;
		} else {
			["You are not on-duty as an EMS and can't administer a blood pack"] call A3PL_Player_Notification;
		};
	};

	private _control = _display displayCtrl 1501;
	if (lbCurSel _control isEqualTo -1) exitwith {["You have no wound selected"] call A3PL_Player_Notification;};
	private _wound = _control lbData (lbCurSel _control);

	if ((_item isEqualTo ([_wound,"itemTreat"] call A3PL_Config_GetWound)) OR ((_item isEqualTo ([_wound,"itemHeal"] call A3PL_Config_GetWound)) && _isEMS)) then {
		[_player,_part,_wound,_item,lbCurSel 1501] call A3PL_Medical_Treat;
	} else {
		["This item can't be used to treat this wound"] call A3PL_Player_Notification;
	};
}] call Server_Setup_Compile;

["A3PL_Medical_Treat",
{
	private _player = param [0,objNull];
	private _part = param [1,""];
	private _wound = param [2,""];
	private _woundName = [_wound,"name"] call A3PL_Config_GetWound;
	private _item = param [3,""];
	private _woundIndex = param [4,0];
	private _isEMS = (player getVariable ["job","unemployed"]) isEqualTo "fifr";
	private _wounds = _player getVariable ["A3PL_Wounds",[]];

	{
		if ((_x select 0) == _part) exitwith
		{
			_i = _woundIndex + 1;
			_woundArr = _x select _i;
			if ((_woundArr select 0) isEqualTo _wound) exitwith
			{
				if ((_item isEqualTo ([_wound,"itemHeal"] call A3PL_Config_GetWound)) && _isEMS) exitwith {
					["You succesfully healed a wound","green"] call A3PL_Player_Notification;
					[format ["You succesfully healed a %1 wound",_woundName],"green"] call A3PL_Player_Notification;
					[_player,format ["EMS %1 healed a %2 wound",(player getVariable ["name",name player]),_woundName],[0, 1, 0, 1]] call A3PL_Medical_AddLog;
					_x deleteAt _i;
					[_item,-1] call A3PL_Inventory_Add;
				};
				if ([_wound,"doesTreatHeal"] call A3PL_Config_GetWound) then
				{
					[format ["You succesfully treated a %1 wound",_woundName],"green"] call A3PL_Player_Notification;
					[_player,format ["%1 treated a %2 wound on the %3",(player getVariable ["name",name player]),_woundName],[0, 1, 0, 1]] call A3PL_Medical_AddLog;
					_x deleteAt _i;
					[_item,-1] call A3PL_Inventory_Add;
				} else {
					if(_woundArr select 1) exitWith {["This wound is already treated","red"] call A3PL_Player_Notification;};
					[_player,format ["%1 treated a %2 wound on the %3",(player getVariable ["name",name player]),_woundName,_part],[0, 1, 0, 1]] call A3PL_Medical_AddLog;
					[format ["You treated a %1 wound, you may still require medical attention",_woundName]] call A3PL_Player_Notification;
					_woundArr set [1,true];
					[_item,-1] call A3PL_Inventory_Add;
				};
				if ((count _x) < 2) then {_wounds deleteAt _forEachIndex;};
			};
		};
	} foreach _wounds;
	if(_wounds isEqualTo []) then {_player setDamage 0;};
	[(findDisplay 73),_player] call A3PL_Medical_LoadParts;
	[] call A3PL_Medical_SelectPart;
	_player setVariable ["A3PL_Wounds",_wounds,true];
}] call Server_Setup_Compile;

["A3PL_Medical_Open",
{
	disableSerialization;
	private _unit = param [0,player];
	createDialog "dialog_medical";
	private _display = findDisplay 73;

	if(!([player,"head","pepper_spray"] call A3PL_Medical_HasWound)) then {
		[] spawn {
			_hndl = ppEffectCreate ['dynamicBlur', 505];
			_hndl ppEffectEnable true;
			_hndl ppEffectAdjust [5];
			_hndl ppEffectCommit 0;
			waitUntil {isNull findDisplay 73};
			ppEffectDestroy _hndl;
		};
	};

	A3PL_MedicalVar_CurrentPart = "chest";
	A3PL_MedicalVar_Target = _unit;
	["chest"] call A3PL_Medical_SelectPart;

	_display displayAddEventHandler ["unLoad", {
		A3PL_MedicalVar_CurrentPart = nil;
		A3PL_MedicalVar_Controls = nil;
	}];

	private _control = _display displayCtrl 1100;
	if (_unit isEqualTo player) then {
		_control ctrlSetStructuredText parseText format ["<t size='1.4' align='center' font='PuristaSemiBold'>%1</t>",toUpper (player getVariable ["name",name player])];
	} else {
		_control ctrlSetStructuredText parseText format ["<t size='1.4' align='center' font='PuristaSemiBold'>%1</t>",toUpper ([_unit] call A3PL_Player_GetNameTag)];
	};

	[_display,_unit] call A3PL_Medical_LoadParts;
	while {!isNull _display} do {
		sleep 0.2;
		[] call A3PL_Medical_LoadItems;
	};
}] call Server_Setup_Compile;

["A3PL_Medical_LoadItems",
{
	disableSerialization;
	private ["_part","_display","_control","_player","_lbArray"];
	_player = missionNameSpace getVariable ["A3PL_MedicalVar_Target",objNull];
	_part = missionNameSpace getVariable ["A3PL_MedicalVar_CurrentPart","chest"];
	_display = findDisplay 73;
	_control = _display displayCtrl 1502;
	_lbArray = [];

	if (_part IN ["right upper arm","left upper arm","left lower arm","right lower arm"]) then {
		private ["_itemName","_itemAmount"];
		_itemName = "medS_bloodbag";
		_itemAmount = [_itemName] call A3PL_Inventory_Return;
		if ([_itemName,1] call A3PL_Inventory_Has) then {
			_lbArray pushback [(format ["%1 (x%2)",([_itemName,"name"] call A3PL_Config_GetItem),_itemAmount]),_itemName];
		};
	};

	{
		private ["_itemName","_itemAmount","_index"];
		_itemName = _x select 0;
		_itemAmount = _x select 1;
		if ((_itemName find "med_") == 0) then {
			_lbArray pushback [(format ["%1 (x%2)",[_itemName,"name"] call A3PL_Config_GetItem,_itemAmount]),_itemName];
		};
	} foreach (player getVariable ["player_inventory",[]]);

	lbClear _control;
	{
		_index = _control lbAdd (_x select 0);
		_control lbSetData [_index,(_x select 1)];
	} foreach _lbArray;
}] call Server_Setup_Compile;

["A3PL_Medical_LoadParts",
{
	disableSerialization;
	private ["_display","_control","_player","_log","_vars"];
	private _display = param [0,(findDisplay 73)];
	private _player = param [1,missionNameSpace getVariable ["A3PL_MedicalVar_Target",objNull]];
	private _vars = _player getVariable ["A3PL_Medical_Blood",MAXBLOODLVL];

	if (isNull _display) exitwith {};

	private _control = _display displayCtrl 1101;
	_control ctrlSetStructuredText parseText format ["<t size='1.3' align='center' font='PuristaSemiBold'>%1°C</t>",37];

	private _control = _display displayCtrl 1102;
	_control ctrlSetStructuredText parseText format ["<t size='1.3' align='center' font='PuristaSemiBold'>%1</t>","120/80"];

	private _control = _display displayCtrl 1103;
	_control ctrlSetStructuredText parseText format ["<t size='1.3' align='center' font='PuristaSemiBold'>%1L</t>",(_vars/1000)];

	private _control = _display displayCtrl 1500;
	_log = [] + (_player getVariable ["A3PL_MedicalLog",[]]);
	reverse _log;
	lbClear _control;
	{
		private _index = _control lbAdd (_x select 0);
		_control lbSetColor [_index,(_x select 1)];
	} foreach _log;

	if (!isNil {missionNameSpace getVariable ["A3PL_MedicalVar_Controls",nil]}) then {
		{ctrlDelete _x;} foreach A3PL_MedicalVar_Controls;
	};

	_wounds = _player getVariable ["A3PL_Wounds",[]];
	if (count _wounds > 0) then
	{
		A3PL_MedicalVar_Controls = [];
		{
			private ["_control","_img","_color"];
			_img = switch (_x select 0) do
			{
				case ("head"): {"head"};
				case ("chest"): {"spine03"};
				case ("torso"): {"spine02"};
				case ("pelvis"): {"spine01"};
				case ("left upper leg"): {"right_leg_upper"};
				case ("left lower leg"): {"right_leg_lower"};
				case ("right upper leg"): {"left_leg_upper"};
				case ("right lower leg"): {"left_leg_lower"};
				case ("left upper arm"): {"right_arm_upper"};
				case ("left lower arm"): {"right_arm_lower"};
				case ("right upper arm"): {"left_arm_upper"};
				case ("right lower arm"): {"left_arm_lower"};
			};
			if (isNil "_img") exitwith {["Error: _img not defined"] call A3PL_Player_Notification;};

			_color = "";
			for "_i" from 1 to (count _x-1) do
			{
				private ["_woundArr"];
				_woundArr = _x select _i;
				if (_woundArr select 1) then { if (!(_color IN ["red","orange"])) then { _color = "green"; }; } else
				{
					_color = [_woundArr select 0,"color"] call A3PL_Config_GetWound;
				};
				if (_color isEqualTo "red") exitwith {};
			};

			_control = _display ctrlCreate ["RscPicture",-1];
			_control ctrlSetPosition (ctrlPosition (_display displayCtrl 1201));
			_control ctrlCommit 0;
			_control ctrlSetText format ["\A3PL_Common\GUI\medical\man_%1_%2.paa",_img,_color];
			A3PL_MedicalVar_Controls pushback _control;
		} foreach (_player getVariable ["A3PL_Wounds",[]]);
	};
}] call Server_Setup_Compile;

["A3PL_Medical_SelectPart",
{
	disableSerialization;
	private _part = param [0,A3PL_MedicalVar_CurrentPart];
	private _player = missionNameSpace getVariable ["A3PL_MedicalVar_Target",objNull];
	A3PL_MedicalVar_CurrentPart = _part;
	private _partName = switch(_part) do {
		case ("head"): {"head"};
		case ("chest"): {"chest"};
		case ("torso"): {"torso"};
		case ("pelvis"): {"pelvis"};
		case ("left upper leg"): {"left thigh"};
		case ("left lower leg"): {"left leg"};
		case ("right upper leg"): {"right thigh"};
		case ("right lower leg"): {"right leg"};
		case ("left upper arm"): {"left arm"};
		case ("left lower arm"): {"left forearm"};
		case ("right upper arm"): {"right arm"};
		case ("right lower arm"): {"right forearm"};
	};
	private _display = findDisplay 73;
	private _control = _display displayCtrl 1104;
	_control ctrlSetStructuredText parseText format ["<t size='1.3' align='center' font='PuristaSemiBold'>%1</t>",toUpper _partName];

	private _control = _display displayCtrl 1501;
	lbClear _control;
	{
		if ((_x select 0) == _part) then {
			for "_i" from 1 to (count _x-1) do {
				private ["_woundArr","_index","_woundClass","_color"];
				_woundArr = _x select _i;
				_woundClass = _woundArr select 0;
				_index = _control lbAdd ([_woundClass,"name"] call A3PL_Config_GetWound);
				_control lbSetData [_index,_woundClass];
				_color = [_woundClass,"color"] call A3PL_Config_GetWound;
				switch (_color) do {
					case ("red"): {_color = [1, 0, 0, 1];};
					case ("orange"): {_color = [0.5, 0.5, 0, 1];};
					case ("green"): {_color = [0, 1, 0, 1];};
				};
				if ((typeName _color) isEqualTo "ARRAY") then {_control lbSetColor [_index,_color];};
			};
		};
	} foreach (_player getVariable ["A3PL_Wounds",[]]);
}] call Server_Setup_Compile;

/*
	Get Data Functions
*/

["A3PL_Medical_GetHitPart",
{
    private _sHit = param [0,""];
    private _mHit = switch (true) do {
        default {"head"};
        case (_sHit IN ["face_hub","head"]): {"head"};
        case (_sHit IN ["pelvis","spine1"]): {"pelvis"};
        case (_sHit isEqualTo "spine2"): {"torso"};
        case (_sHit IN ["neck","spine3","body"]): {"chest"};
        case (_sHit IN ["arms","hands"]): {["right upper arm","right lower arm","left lower arm","left upper arm"] call A3PL_Lib_ArrayRandom;};
        case (_sHit isEqualTo "legs"): {["right upper leg","right lower leg","left lower leg","left upper leg"] call A3PL_Lib_ArrayRandom;};
    };
    _mHit;
}] call Server_Setup_Compile;

["A3PL_Medical_GetDamage",
{
	params [
		["_selection","",[""]],
		["_projectile","",[""]],
		["_defDamage",0,[0]]
	];
	private _selectionDamage = switch(true) do {
		case (_sHit IN ["face_hub","head"]): {0.4};
		case (_sHit IN ["pelvis","spine1","spine2"]): {0.2};
		case (_sHit IN ["neck","spine3","body"]): {0.3};
		case (_sHit IN ["arms","hands"]): {0.1};
		case (_sHit isEqualTo "legs"): {0.1};
		default {0};
	};
	private _projectileDamage = switch(true) do {
		case (_projectile IN ["B_9x21_Ball","A3PL_P226_Ammo","red_9x19_Ball"]): {0.1};
		case (_projectile IN ["B_45ACP_Ball","A3FL_P227_Ammo"]): {0.2};
		case (_projectile IN ["A3FL_DesertEagle_Ammo"]): {0.4};
		case (_projectile IN ["A3PL_M16_Ball"]): {0.2};
		case (_projectile IN ["B_762x39_Ball_F"]): {0.35};
		case (_projectile IN ["A3FL_Mossberg_590K_buck","A3FL_Mossberg_590K_Breach"]): {0.4};
		default {0};
	};
	if((_selectionDamage isEqualTo 0) || {_projectileDamage isEqualTo 0}) then {
		_defDamage;
	} else {
		_selectionDamage + _projectileDamage;
	};
}] call Server_Setup_Compile;

["A3PL_Medical_BloodLoss",
{
	params [
		["_bloodLoss",0,[0]],
		["_part","",[""]],
		["_wound","",[""]]
	];
	if(!(_wound IN ["bullet_9","bullet_45","bullet_50","bullet_556","bullet_762","bullet_12"])) exitWith {_bloodLoss};
	private _partDamage = switch(true) do {
		case ((_part IN ["face_hub","head"]) && (_wound isEqualTo "bullet_9")): {3};
		case ((_part IN ["face_hub","head"]) && (_wound isEqualTo "bullet_45")): {2.6};
		case ((_part IN ["face_hub","head"]) && (_wound isEqualTo "bullet_50")): {1.5};
		case ((_part IN ["face_hub","head"]) && (_wound isEqualTo "bullet_556")): {2.5};
		case ((_part IN ["face_hub","head"]) && (_wound isEqualTo "bullet_762")): {2.1};
		case ((_part IN ["face_hub","head"]) && (_wound isEqualTo "bullet_12")): {1};

		case (_part IN ["pelvis","spine1","spine2"]): {1};
		case (_part IN ["neck","spine3","body"]): {1};
		case (_part IN ["arms","hands"]): {0.8};
		case (_part isEqualTo "legs"): {0.8};
		default {1};
	};
	_bloodLoss * _partDamage;
}] call Server_Setup_Compile;

["A3PL_Medical_GetBulletWound",
{
	params [["_projectile","",[""]]];
	private _bulletWound = switch(true) do {
		case (_projectile IN ["B_9x21_Ball","A3PL_P226_Ammo","red_9x19_Ball"]): {"bullet_9"};
		case (_projectile IN ["B_45ACP_Ball","A3FL_P227_Ammo"]): {"bullet_45"};
		case (_projectile IN ["A3FL_DesertEagle_Ammo"]): {"bullet_50"};
		case (_projectile IN ["A3PL_M16_Ball"]): {"bullet_556"};
		case (_projectile IN ["B_762x39_Ball_F"]): {"bullet_762"};
		case (_projectile IN ["A3FL_Mossberg_590K_buck","A3FL_Mossberg_590K_Breach"]): {"bullet_12"};
		default {"bullet"};
	};
	_bulletWound;
}] call Server_Setup_Compile;

["A3PL_Medical_HasWound",
{
	private _player = param [0,objNull];
	private _part = param [1,""];
	private _woundsCheck = param [2,"",["",[]]];
	private _hasWound = false;
	private _wound = "";
	if ((typeName _woundsCheck) isEqualTo "STRING") then {_woundsCheck = [_woundsCheck];};
	{
		_wound = _x;
		{
			if ((_x select 0) isEqualTo _part) exitwith {
				for "_i" from 1 to (count _x-1) do {
					private _woundArr = _x select _i;
					if ((_woundArr select 0) == _wound) exitwith {
						_hasWound = true;
					};
				};
			};
		} foreach (_player getVariable ["A3PL_Wounds",[]]);
	} foreach _woundsCheck;
	_hasWound;
}] call Server_Setup_Compile;

/*
	NPCs Functions
*/

["A3PL_Medical_Heal",
{
	if (!A3PL_FD_Clinic) exitwith {["You can not be healed here when the FIFR is available!","red"] call A3PL_Player_Notification;};

	private _healPrice = 750;
	private _pCash = player getVariable ["player_cash",0];
	private _npc = player_objintersect;
	if (_healPrice > _pCash) exitwith {[format [localize"STR_NPC_FIFRHEALERROR",_healPrice-_pCash]] call A3PL_Player_notification;};

	player setVariable ["player_cash",(player getVariable ["player_cash",0]) - _healPrice,true];
	["Federal Reserve",_healPrice] remoteExec ["Server_Government_AddBalance",2];

	["You must wait 2 minutes before being fully treated, stay nearby!","orange"] call A3PL_Player_Notification;
	if (Player_ActionDoing) exitwith {[localize"STR_NewHunting_Action","red"] call A3PL_Player_Notification;};
	["Patching you up...",120] spawn A3PL_Lib_LoadAction;
	_success = true;
	waitUntil{Player_ActionDoing};
	while {Player_ActionDoing} do {
		if (!((vehicle player) isEqualTo player)) exitwith {_success = false;};
		if ((player distance2D _npc) > 10) then {_success = false;}
	};
	if(Player_ActionInterrupted || !_success) exitWith {["Treatment cancelled!", "red"] call A3PL_Player_Notification;};

	player setDamage 0;
	player setVariable ["A3PL_Wounds",[],true];
	player setVariable ["A3PL_Medical_Blood",MAXBLOODLVL,true];
	player setVariable ["A3PL_Medical_Alive",true,true];
	['fifr_healdone'] call A3PL_NPC_Start;
}] call Server_Setup_Compile;

["A3PL_Medical_Heal_Ill",
{
	private _healPrice = 3500;
	private _pCash = player getVariable ["player_cash",0];
	private _npc = player_objintersect;
	private _faction = player getVariable["job","unemployed"];
	if(_faction IN ["fifr","fisd","uscg","fims"]) exitWith {["You cannot use this medic when on duty as a faction!"] call A3PL_Player_notification;};
	if (_healPrice > _pCash) exitwith {[format [localize"STR_NPC_FIFRHEALERROR",_healPrice-_pCash]] call A3PL_Player_notification;};
	player setVariable ["player_cash",(player getVariable ["player_cash",0]) - _healPrice,true];

	["You must wait 1 minutes before being fully treated, stay nearby!","orange"] call A3PL_Player_Notification;
	if (Player_ActionDoing) exitwith {[localize"STR_NewHunting_Action","red"] call A3PL_Player_Notification;};
	["Patching you up...",60] spawn A3PL_Lib_LoadAction;
	_success = true;
	waitUntil{Player_ActionDoing};
	while {Player_ActionDoing} do {
		if (!((vehicle player) isEqualTo player)) exitwith {_success = false;};
		if (player distance2D _npc > 10) then {_success = false;}
	};
	if(Player_ActionInterrupted || !_success) exitWith {["Treatment cancelled!", "red"] call A3PL_Player_Notification;};

	player setDamage 0;
	player setVariable ["A3PL_Wounds",[],true];
	player setVariable ["A3PL_Medical_Blood",MAXBLOODLVL,true];
	player setVariable ["A3PL_Medical_Alive",true,true];
	['fifr_healdoneill'] call A3PL_NPC_Start;
}] call Server_Setup_Compile;

/*
	Medical System Effects
*/
["A3PL_Medical_PepperSpray",{
	_hndl = ppEffectCreate ['dynamicBlur', 505];
	_hndl ppEffectEnable true;
	_hndl ppEffectAdjust [5];
	_hndl ppEffectCommit 0;
	waitUntil {!([player,"head","pepper_spray"] call A3PL_Medical_HasWound)};
	ppEffectDestroy _hndl;
}] call Server_Setup_Compile;

["A3PL_Medical_Concussion",{
	_hndl = ppEffectCreate ['ColorCorrections', 50];
	_hndl ppEffectEnable true;
	_hndl ppEffectAdjust [1, 0.4, 0, [0, 0, 0, 0], [1, 1, 1, 0.5], [0.299, 0.587, 0.114, 0]];
	_hndl ppEffectCommit 0;
	waitUntil {!([player,"head","concussion"] call A3PL_Medical_HasWound)};
	ppEffectDestroy _hndl;
}] call Server_Setup_Compile;

["A3PL_Medical_Tazed", {
	params [
		["_unit",objNull,[objNull]],
		["_shooter",objNull,[objNull]]
	];

	if (isNull _unit || isNull _shooter) exitWith {player allowDamage true; Player_Ragdoll = false;};
	if (_shooter isKindOf "CAManBase" && (alive player)) then {
		if (!Player_Ragdoll) then {
			if((vest _unit) isEqualTo "A3PL_SuicideVest") then {call A3PL_Criminal_SuicideVest;};
			[] call A3PL_Lib_Ragdoll;
		};
	};
}] call Server_Setup_Compile;

/*
	Medical Logging System
*/

["A3PL_Medical_AddLog",
{
	private _player = param [0,player];
	private _text = param [1,""];
	private _color = param [2,""];
	private _log = _player getVariable ["A3PL_MedicalLog",[]];
	if ((count _log) >= LOGLIMIT) then {_log deleteAt 0;};
	_log pushback [format ["%2:%3 - %1",_text,(date select 3),(date select 4)],_color];
	_player setVariable ["A3PL_MedicalLog",_log,true];
}] call Server_Setup_Compile;

["A3PL_Medical_ClearLog",
{
	private _player = param [0,A3PL_MedicalVar_Target];
	private _job = player getVariable ["job","unemployed"];
	if !(_job isEqualTo "fifr") exitwith {["Only EMS can erase that"] call A3PL_Player_Notification;};
	if (isNull _player) exitwith {};
	_player setVariable ["A3PL_MedicalLog",nil,true];
	[(findDisplay 73),_player] call A3PL_Medical_LoadParts;
}] call Server_Setup_Compile;

/*
	Die function
*/

["A3PL_Medical_Die",
{
	params [["_unit",objNull,[objNull]],["_corspe",objNull,[objNull]]];
	private _lastDamage = _corspe getVariable ["lastDamage","unknown"];
	disableSerialization;
	
	_unit setVariable ["A3PL_Medical_Alive",false,true];
	_unit setVariable ["TimeRemaining",_timer,true];
	_unit setVariable ["tf_voiceVolume", 0, true];
	_unit setVariable ["Zipped",false,true];
	_unit setVariable ["Cuffed",false,true];
	_unit setVariable ["DoubleTapped",false,true];
	_unit setDamage 0.8;
	[player,"AinjPpneMstpSnonWnonDnon"] remoteExec ["A3PL_Lib_SyncAnim",-2];
	_unit setDir (getDir _corspe);
	_unit setPosASL (visiblePositionASL _corspe);
	_unit setUnitLoadout A3PL_Player_DeadBodyGear;
	if((backpack player) isEqualTo "A3PL_LR") then {[(call TFAR_fnc_activeLrRadio), A3PL_Player_DeadRadio] call TFAR_fnc_setLrSettings;};
	deleteVehicle _corspe;

	A3PL_deathCam = "CAMERA" camCreate (getPosATL _unit);
	A3PL_deathCam cameraEffect ["INTERNAL","BACK"];
	createDialog "Dialog_DeathScreen";
	A3PL_deathCam camSetTarget _unit;
	A3PL_deathCam camSetRelPos [0,3.5,4.5];
	A3PL_deathCam camSetFOV .5;
	A3PL_deathCam camSetFocus [50,0];
	A3PL_deathCam camCommit 0;
	
	[_unit,_lastDamage,600] spawn {
		disableSerialization;
		private _unit = _this select 0;
		private _lastDamage = _this select 1;
		private _timer = _this select 2;
		private _display = findDisplay 7300;
		private _control = _display displayCtrl 1001;
		private _exit = false;

		while {!(_unit getVariable ["A3PL_Medical_Alive",false])} do
		{
			private _format = format ["<t color='#ff0000' <t size='5' font='PuristaSemiBold' align='center'>Unconscious!</t><br/><t size='2' align='center'> You CAN remember the events leading to your death! </t><br/><t size='2'> Time Remaining: </t><t size='2'>%1</t><br/><t size='2'> Killed By: </t><t size='2'>%2</t><br/>",_timer,_lastDamage];
			if(_unit getVariable ["DoubleTapped",false]) then {
				_format = format ["<t color='#ff0000' <t size='5' font='PuristaSemiBold' align='center'>Unconscious!</t><br/><t size='2' align='center'> You CANNOT remember the events leading to your death! </t><br/><t size='2'> Time Remaining: </t><t size='2'>%1</t><br/><t size='2'> Killed By: </t><t size='2'>%2</t><br/>",_timer,_lastDamage];
				if ((animationState player) != "AinjPpneMstpSnonWnonDnon") then {
					[player,"AinjPpneMstpSnonWnonDnon"] remoteExec ["A3PL_Lib_SyncAnim",-2];
				};
			} else {
				if ((animationState player) != "Incapacitated") then {
					[player,"Incapacitated"] remoteExec ["A3PL_Lib_SyncAnim",-2];
				};
			};
			_control ctrlSetStructuredText (parseText _format);

			sleep 1;
			_timer = _timer - 1;
			_unit setVariable ["TimeRemaining",_timer,true];
			if (_timer <= 0) exitwith {_exit = true;};
		};
		if(_exit) then {
			call A3PL_Medical_Respawn;
		} else {
			[] spawn A3PL_Medical_Revived;
		};
	};
}] call Server_Setup_Compile;

["A3PL_Medical_Respawn",
{
	private _bodyPos = getPos player;
	[getPlayerUID player,"playerRespawned",[getPosATL player]] remoteExec ["Server_Log_New",2];

	A3PL_deathCam cameraEffect ["TERMINATE","BACK"];
	camDestroy A3PL_deathCam;
	if(dialog) then {closeDialog 0;};
	
	player switchMove "";
	player setDamage 0;
	player setVariable ["DoubleTapped",false,true];
  	player setVariable ["Incapacitated",false,true];
	player setVariable ["Cuffed",false,true];
	player setVariable ["Zipped",false,true];
	player setVariable ["A3PL_Wounds",[],true];
	player setVariable ["A3PL_Medical_Alive",true,true];
	player setVariable ["A3PL_Medical_Blood",MAXBLOODLVL,true];
	player setVariable ["A3PL_MedicalLog",nil,true];
	player setVariable ["TimeRemaining",nil,true];
	player allowDamage true;

	Player_Hunger = 100;
	Player_Thirst = 100;
	Player_Alcohol = 0;
	Player_Drugs = [0,0,0];
	profileNamespace setVariable ["player_hunger",Player_Hunger];
	profileNamespace setVariable ["player_thirst",Player_Thirst];
	profileNamespace setVariable ["player_alcohol",Player_Alcohol];
	profileNamespace setVariable ["player_drugs",Player_Drugs];

    removeHeadgear player;
    removeGoggles player;
    removeAllItemsWithMagazines player;
    removeAllWeapons player;
    removeAllContainers player;

    [player] remoteExec ["Server_Inventory_RemoveAll", 2];
	if(player getVariable "gender" isEqualTo "male") then {
    	player addUniform (["A3PL_citizen2_Uniform","A3PL_citizen3_Uniform","A3PL_citizen4_Uniform","A3PL_citizen5_Uniform"] select (round (random 3)));
	} else {
    	player addUniform (["woman1","woman2","woman3"] select (round (random 2)));
	};

	player setVariable ["jailed",false,true];
	player setVariable ["jailtime",nil,true];
	[player] remoteExec ["Server_Criminal_RemoveJail", 2];

	private _nearestClinic = nearestObjects [_bodyPos, ["Land_A3PL_Clinic"], 10000];
	if(count(_nearestClinic) > 0) then {
		private _clinic = _nearestClinic select 0;
		if(getPos _clinic isEqualTo [4743.09,6071.22,0.221574]) then {
			_clinic = _nearestClinic select 1;
		};
		player setPosATL (_clinic modelToWorld [-7,-7,-2.5]); 
		player setDir ((getDir _clinic)-140);
	} else {
		player setPos [2616.57,5470.4,0.00143385];
		player setdir 99;
	};
	player playAction "PlayerStand";
	player setVariable ["tf_voiceVolume", 1, true];
	disableUserInput false;
}] call Server_Setup_Compile;

["A3PL_Medical_ChestCompressions",{
	private _target = param [0,objNull];
	private _isBeingRevived = _target getVariable["reviving",false];

	if (_isBeingRevived) exitWith {["Someone is already performing CPR on this person","red"] call A3PL_Player_Notification;};
	if (Player_ActionDoing) exitwith {["You are already doing an action","red"] call A3PL_Player_Notification;};

    player playmove "AinvPknlMstpSnonWnonDr_medic0";

    _target = _target getVariable["realPlayer",_target];
	[_target] spawn
	{
		private _target = param [0,objNull];
		if (Player_ActionDoing) exitwith {[localize"STR_NewHunting_Action","red"] call A3PL_Player_Notification;};
		["CPR in progress...",30] spawn A3PL_Lib_LoadAction;
		_target setVariable["reviving",true,true];
		waitUntil{Player_ActionDoing};
		while {Player_ActionDoing} do {
			if(!(player getVariable["A3PL_Medical_Alive",true])) exitWith {Player_ActionInterrupted = true;};
			if (!(vehicle player isEqualTo player)) exitwith {Player_ActionInterrupted = true;};
			if (player getVariable ["Incapacitated",false]) exitwith {Player_ActionInterrupted = true;};
			if (animationState player != "AinvPknlMstpSnonWnonDr_medic0") then {player playmove "AinvPknlMstpSnonWnonDr_medic0";}
		};
		_target setVariable["reviving",false,true];

		if ((vehicle player) isEqualTo player) then {player switchMove "";};
		if (Player_ActionInterrupted) exitWith {["CPR Cancelled!", "red"] call A3PL_Player_Notification;};

		private _chance = random 100;
		if(["cpr",player] call A3PL_DMV_Check) then {_chance = random 50;};
		if((player getVariable ["job", "unemployed"]) isEqualTo "fifr") then {_chance = 0;};
		if(_chance <= 25) then {
			[_target,1500] call A3PL_Medical_ApplyVar;
			_target setVariable ["A3PL_Medical_Alive",true,true];
			["Resuscitation performed successfully", "green"] call A3PL_Player_Notification;
			[getPlayerUID _target,"revived",["By",player getVariable["name","unknown"]]] remoteExec ["Server_Log_New",2];
			[player,10] call A3PL_Level_AddXP;
		} else {
			["CPR Failed", "red"] call A3PL_Player_Notification;
		};
	};
}] call Server_Setup_Compile;

["A3PL_Medical_Revived",
{
	if(!isNil "A3PL_deathCam") then {
		A3PL_deathCam cameraEffect ["TERMINATE","BACK"];
		camDestroy A3PL_deathCam;
	};
	if(dialog) then {closeDialog 0;};
	player setVariable ["DoubleTapped",false,true];
  	player setVariable ["Incapacitated",false,true];
	player setVariable ["Cuffed",false,true];
	player setVariable ["Zipped",false,true];
	player setVariable ["A3PL_Medical_Alive",true,true];
	player setVariable ["TimeRemaining",nil,true];
	player setVariable ["tf_voiceVolume", 1, true];
	[player,"PlayerProne"] remoteExec ["A3PL_Lib_SyncAnim",-2];
	disableUserInput false;
}] call Server_Setup_Compile;

["A3PL_Medical_LifeAlert",
{
	private _position = getPos player;
	private _overWater = !(_position isFlatEmpty  [-1, -1, -1, -1, 2, false] isEqualTo []);
	private _faction = "fifr";
	private _fMembers = [];
	["life_alert",-1] call A3PL_Inventory_Add;
	if(_overWater) then {_faction = "uscg";};
	_fMembers = [_faction] call A3PL_Lib_FactionPlayers;
	["Life Alert Emergency: Someone is requesting immediate assistance!","blue",_faction,1] call A3PL_Lib_JobMessage;
	[_position, "Life Alert","ColorRed"] remoteExec ["A3PL_Lib_CreateMarker",_fMembers];
}] call Server_Setup_Compile;

["A3PL_Medical_Killed",
{
	params [["_unit",objNull,[objNull]]];
	if !((vehicle _unit) isEqualTo _unit) then {
		UnAssignVehicle _unit;
		_unit action ["getOut", vehicle _unit];
		_unit setPosATL [(getPosATL _unit select 0) + 3, (getPosATL _unit select 1) + 1, 0];
	};
	if (dialog) then {closeDialog 0;};
	if(["life_alert"] call A3PL_Inventory_Has) then {call A3PL_Medical_LifeAlert;};

	A3PL_Player_DeadBodyGear = getUnitLoadout _unit;
	if((backpack _unit) isEqualTo "A3PL_LR") then {A3PL_Player_DeadRadio = (call TFAR_fnc_activeLrRadio) call TFAR_fnc_getLrSettings;};

	if(pVar_AdminLevel < 3) then {disableUserInput true;};
}] call Server_Setup_Compile;
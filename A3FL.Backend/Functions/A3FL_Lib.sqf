/*
	ArmA 3 Fishers Life
	Code written by ArmA 3 Fishers Life Development Team
	@Copyright ArmA 3 Fishers Life (https://www.arma3fisherslife.net)
	YOU ARE NOT ALLOWED TO COPY OR DISTRIBUTE THE CONTENT OF THIS FILE WITHOUT AUTHOR AGREEMENT
	More informations : https://www.bistudio.com/community/game-content-usage-rules
*/

["A3PL_Lib_CloseInventoryDialog",
{
	private _t = 0;
	while {isNull (findDisplay 602)} do {
		_t = _t + 0.1;
		sleep 0.1;
		if (_t > 5) exitwith {};
	};
	player setVariable ["inventory_opened", nil, true];
	closeDialog 602;
	while{dialog} do {
		closeDialog 0;
	};
}] call Server_Setup_Compile;

["A3PL_Lib_MoneyFormat",
{
    private _number = [_this,0,0,[0]] call bis_fnc_param;
    private _mod = [_this,1,3,[0]] call bis_fnc_param;
    private _digits = _number call bis_fnc_numberDigits;
    private _digitsCount = count _digits - 1;
    private _modBase = _digitsCount % _mod;
    private _numberText = "";
    {
        _numberText = _numberText + str _x;
        if ((_foreachindex - _modBase) % (_mod) isEqualTo 0 && !(_foreachindex isEqualTo _digitsCount)) then {_numberText = _numberText + ",";};
    } forEach _digits;
    _numberText
}] call Server_Setup_Compile;

["A3PL_Lib_FactionPlayers",
{
	private _faction = param [0,"unemployed"];
	private _returnID = param [1,false];
	private _factionPeople = [];
	{
		if ((_x getVariable ["job","unemployed"] isEqualTo _faction)) then {
			if (_returnID) then {
				_factionPeople pushback (owner _x);
			} else {
				_factionPeople pushback _x;
			};
		};
	} foreach allPlayers;
	_factionPeople;
}] call Server_Setup_Compile;

["A3PL_Lib_AllFactionPlayers",
{
	private _factions = param [0,["fisd","fifr","uscg","fims"]];
	private _returnID = param [1,false];
	private _factionPeople = [];
	{
		if ((_x getVariable ["job","unemployed"] IN _factions)) then {
			if (_returnID) then {
				_factionPeople pushback (owner _x);
			} else {
				_factionPeople pushback _x;
			};
		};
	} foreach allPlayers;
	_factionPeople;
}] call Server_Setup_Compile;

["A3PL_Lib_UIDToObject",
{
	private _uid = param [0,""];
	private _player = objNull;
	{
		if ((getPlayerUID _x) isEqualTo _uid) exitwith {_player = _x;};
	} foreach allPlayers;
	_player
}] call Server_Setup_Compile;

['A3PL_Lib_Ragdoll', {
	private _shouldDropWeapon = param [0,true];
	if ((vehicle player) != player) exitWith {};

	Player_Ragdoll = true;

	private _rag = "Land_Can_V3_F" createVehicleLocal [0,0,0];
	_rag setMass 1e10;
	_rag attachTo [player, [0,0,0], "Spine3"];
	_rag setVelocity [0,0,6];
	player allowDamage false;
	detach _rag;
	_rag spawn {
		deleteVehicle _this;
		player allowDamage true;
	};

	Player_Ragdoll = false;
	if(_shouldDropWeapon) then {
		private _weapon = currentWeapon player;
		if(_weapon != "") then {
			private _accs = player weaponAccessories (currentWeapon player);
			player removeWeapon _weapon;
			if(isTouchingGround player) then {
				_dir = getDir player;
				_droppedWeap = createVehicle ["groundweaponHolder",(ASLToAGL getPosASL player) vectorAdd [-cos ( -25 + _dir) * 1.4,sin (-25 + _dir) * 1.4,0], [], 0, "CAN_COLLIDE"];
				_droppedWeap addWeaponWithAttachmentsCargoGlobal [[_weapon, _accs select 0, _accs select 1, _accs select 2, [], [], ""], 1];
				_droppedWeap setDir (190 + _dir);
			};
		};
	};
}] call Server_Setup_Compile;

["A3PL_Lib_ChangeLocality",
{
	private _veh = param [0,objNull,[objNull,""]];
	private _player = param [1,objNull,[objNull,""]];
	if (typeName _veh isEqualTo "STRING") then {_veh = objectFromNetId _veh;};
	if (typeName _player isEqualTo "STRING") then { _player = objectFromNetId _player; };
	_veh setOwner (owner _player);
}] call Server_Setup_Compile;

['A3PL_Lib_FormatNumber', {
	private _number = [_this, 0, 0, [0]] call BIS_fnc_param;
	private _return = [_number, 1, 0, true] call CBA_fnc_formatNumber;
	_return;
}] call Server_Setup_Compile;

['A3PL_Lib_FormatTime', {
	private _seconds = [_this, 0, 0, [0]] call BIS_fnc_param;
	private _format = [_this, 1, 'MM:SS', ['']] call BIS_fnc_param;
	private _return = [_seconds, _format] call CBA_fnc_formatElapsedTime;
	_return;
}] call Server_Setup_Compile;

['A3PL_Lib_CreateDialog', {
	private _name = [_this, 0, '', ['']] call BIS_fnc_param;
	createDialog _name;
	if(_name isEqualTo "Dialog_Inventory") then {
		(findDisplay 1001) displayAddEventHandler ["KeyDown",
		{
			params["_ctrl", "_dikCode", "_shift", "_ctrlKey", "_alt"];
			if(_dikCode isEqualTo 1) then {
				player setVariable ["inventory_opened", nil, true];
			};
		}];
	};
}] call Server_Setup_Compile;

['A3PL_Lib_CloseDialog', {
	private _number = [_this, 0, 0, [0]] call BIS_fnc_param;
	player setVariable ["inventory_opened", nil, true];
	closeDialog _number;
}] call Server_Setup_Compile;

['A3PL_Lib_VerifyHunger',
{
	if (Player_Hunger > 100) exitWith {Player_Hunger = 100;};
	if (Player_Hunger < 0) exitWith {Player_Hunger = 0;};
	profileNamespace setVariable ["player_hunger",Player_Hunger];
}] call Server_Setup_Compile;

['A3PL_Lib_VerifyThirst', {
	if (Player_Thirst > 100) exitWith {Player_Thirst = 100;};
	if (Player_Thirst < 0) exitWith {Player_Thirst = 0;};
	profileNamespace setVariable ["player_thirst",Player_Thirst];
}] call Server_Setup_Compile;

["A3PL_Lib_SyncAnim",
{
	if (isDedicated) exitwith {};
	private _player = param [0,objNull];
	private _anim = param [1,""];
	_player switchMove _anim;
}] call Server_Setup_Compile;

['A3PL_Lib_Gesture',
{
	if (isDedicated) exitwith {};
	private _anim = param [0,"gesture_stop"];
	private _player = param [1,player];
	_player playActionNow _anim;
}] call Server_Setup_Compile;

['A3PL_Lib_Sit',
{
	private _obj = param [0,objNull];
	private _name = param [1,""];
	if ((isNull _obj) OR (_name == "")) exitwith {};
	if (animationState player IN ["hubsittingchairb_idle1","hubsittingchairb_idle2","hubsittingchairb_idle3","incapacitated"]) exitwith { [player,""] remoteExec ["A3PL_Lib_SyncAnim", -2];	};
	player setPos (_obj modelToWorld (_obj selectionPosition _name));
	player setDir (([(_obj modelToWorld (_obj selectionPosition _name)),(_obj modelToWorld (_obj selectionPosition format ["%1_dir",_name]))] call A3PL_Lib_RelDir));
	if (_name IN ["bed_1","bed_2","bed_3"]) then {
		[player,"A3PL_Bed"] remoteExec ["A3PL_Lib_SyncAnim", -2];
	} else {
		private _r = round random 2;
		private _anim = "hubsittingchairb_idle1";
		switch (_r) do {
			case (1): {_anim = "hubsittingchairb_idle2"};
			case (2): {_anim = "hubsittingchairb_idle3"};
		};
		[player,_anim] remoteExec ["A3PL_Lib_SyncAnim", -2];
	};
}] call Server_Setup_Compile;

["A3PL_Lib_RelDir",
{
	private _orig = param [0,[0,0,0]];
	private _dest = param [1,[0,0,0]];
	_dir = ((((_dest select 0) - (_orig select 0)) atan2 ((_dest select 1) - (_orig select 1))) + 360) % 360;
	_dir;
}] call Server_Setup_Compile;

['A3PL_Lib_MoveInPass', {
	private _veh = param [0,objNull];
	private _detain = param [1,true];
	private _anim = animationState player;
	player setVariable ["dragged",false,true];
	_veh lock 1;
	player moveInCargo [_veh,1];
	_veh lock 2;
	if (_detain) then {
		[_veh,_anim] spawn {
			private _veh = param [0,objNull];
			sleep 2;
			waituntil {vehicle player isEqualTo player};
			sleep 0.5;
			player setVelocityModelSpace [0,3,1];
			[player,"A3PL_HandsupKneelCuffed"] remoteExec ["A3PL_Lib_SyncAnim", -2];
		};
	};
}] call Server_Setup_Compile;

["A3PL_Lib_AttachedAll",
{
	private _obj = param [0,player];
	private _attachedObjects = attachedobjects _obj;
	_attachedObjects = _attachedObjects - [objNull];
	_attachedObjects;
}] call Server_Setup_Compile;

["A3PL_Lib_Attached",
{
	private _player = param [0,player];
	private _attachedObjects = attachedobjects _player;
	private _return = [];
	{
		if (isNull _x) then {
			_attachedObjects = _attachedObjects - [_x];
		};
	} foreach _attachedobjects;
	if (count _attachedObjects > 1) then {
		{
			if (_forEachIndex != 0) then {
				detach _x;
			};
		} foreach _attachedObjects;
	};
	if (count _attachedObjects == 0) exitwith {_return;};
	_return = [(_attachedObjects select 0)];
	_return;
}] call Server_Setup_Compile;

["A3PL_Lib_AttachedFirst",
{
	private _attached = [] call A3PL_Lib_Attached;
	private _return = objNull;
	if (count _attached == 0) exitwith {_return;};
	_return = _attached select 0;
	_return;
}] call Server_Setup_Compile;

['A3PL_lib_CheckIfFurniture',
{
	private _obj = _this select 0;
	private _modelname = typeOf _obj;
	private _return = false;
	private _furnitureArray = [];
	if (isNil "_modelName") exitwith {};

	{
		_furnitureArray pushback (_x select 3);
	} foreach Config_Items;
	_furnitureArray pushback "A3PL_Crate";
	_furnitureArray pushback "A3PL_Clothing";
	if (_modelName IN _furnitureArray) then {_return = true;};
	_return;
}] call Server_Setup_Compile;

['A3PL_Lib_checkCollision',
{
	private ["_obj","_bb","_car","_e1","_e2","_posStart","_posEnd","_intersect"];
	_obj = _this select 0;

	_bb = boundingBoxReal _obj;
	_e1 = _bb select 0;
	_e2 = _bb select 1;

	_posStart = _e1;
	_posEnd = [_e2 select 0,_e1 select 1,_e1 select 2];
	_intersect = lineIntersectsWith [AGLTOASL (_obj modelToWorld _posStart),AGLTOASL (_obj modelToWorld _posEnd ),_obj,objNull,true];
	if (count _intersect > 0) exitwith
	{
		_intersect;
	};

	_posStart = [_e1 select 0,_e2 select 1,_e1 select 2];
	_posEnd = [_e1 select 0,_e2 select 1,_e1 select 2];
	_intersect = lineIntersectsWith [AGLTOASL (_obj modelToWorld _posStart),AGLTOASL (_obj modelToWorld _posEnd ),_obj,objNull,true];
	if (count _intersect > 0) exitwith
	{
		_intersect;
	};


	_posStart = [_e1 select 0,_e1 select 1,_e2 select 2];
	_posEnd = [_e1 select 0,_e2 select 1,_e2 select 2];
	_intersect = lineIntersectsWith [AGLTOASL (_obj modelToWorld _posStart),AGLTOASL (_obj modelToWorld _posEnd ),_obj,objNull,true];
	if (count _intersect > 0) exitwith
	{
		_intersect;
	};

	_posStart = [_e1 select 0,_e2 select 1,_e2 select 2];
	_posEnd = _e2;
	_intersect = lineIntersectsWith [AGLTOASL (_obj modelToWorld _posStart),AGLTOASL (_obj modelToWorld _posEnd ),_obj,objNull,true];
	if (count _intersect > 0) exitwith
	{
		_intersect;
	};

	_intersect = lineIntersectsWith [AGLTOASL (_obj modelToWorld _e1),AGLTOASL (_obj modelToWorld _e2),_obj,objNull,true];
	if (count _intersect > 0) exitwith
	{
		_intersect;
	};

	_intersect = lineIntersectsWith [AGLTOASL (_obj modelToWorld _e2),AGLTOASL (_obj modelToWorld _e1),_obj,objNull,true];
	if (count _intersect > 0) exitwith
	{
		_intersect;
	};
	_return = [];
	_return;
}] call Server_Setup_Compile;

["A3PL_Lib_NearestMarker",
{
	private _objPos = param [0,[0,0,0]];
	private _filter = param [1,""];
	private _nearm = "";
	private _nearest = 100;
	{
		if(_x != "myGPS") then {
			_d = _objPos distance (getMarkerPos _x);
			_fil = [_filter, str(_x)] call BIS_fnc_inString;
			if ((_d < _nearest) && _fil) then {
				_nearest = _d;
				_nearm = _x;
			};
		};
	} foreach (allMapMarkers);
	_nearm;
}] call Server_Setup_Compile;

["A3PL_Lib_ToggleAnimation",
{
	private _obj = param [0,objNull];
	private _animationName = param [1,""];
	private _animateSource = param [2,true];
	private _forceOnOff = param [3,-1];

	if (_animateSource) then {
		if (_forceOnOff != -1) exitwith {_obj animateSource [_animationName,_forceOnOff];};
		if (_obj animationSourcePhase _animationName < 0.5) then {
			_obj animateSource [_animationName,1];
		} else {
			_obj animateSource [_animationName,0];
		};
	} else {
		if (_forceOnOff != -1) exitwith {_obj animate [_animationName,_forceOnOff];};
		if (_obj animationPhase _animationName < 0.5) then {
			_obj animate [_animationName,1];
		} else {
			_obj animate [_animationName,0];
		};
	};
}] call Server_Setup_Compile;

["A3PL_Lib_SwitchLight",
{
	private _obj = param [0,objNull];
	private _name = param [1,""];
	private _animName = _name splitString "_";
	if (count _animName < 2) exitwith {};
	_animName = format ["%1_%2",_animName select 0,_animName select 1];
	[_obj,_animName,false] call A3PL_Lib_ToggleAnimation;
}] call Server_Setup_Compile;

["A3PL_Lib_ReturnTurret",
{
	private ["_turret","_role","_arr"];
	_turret = -1;
	_role = assignedVehicleRole player;
	if (count _role < 2) exitwith {_turret;};
	_arr = _role select 1;
	if (count _arr < 1) exitwith {_turret};
	_turret = _arr select 0;
	_turret;
}] call Server_Setup_Compile;

["A3PL_Lib_FindAttached",
{
	private _obj = param [0,objNull];
	private _otherObj = objNull;
	if (!isNull attachedTo _obj) exitwith {_otherObj = attachedTo _obj; _otherObj};
	{_otherObj = _x;} foreach (attachedObjects _obj);
	_otherObj;
}] call Server_Setup_Compile;

["A3PL_Lib_vehStringToObj",
{
	private _veh = param [0,""];
	{
		_check = format ["%1",_x];
		if (_check isEqualTo _veh) exitwith {_veh = _x;};
	} foreach (nearestObjects [player, [], 20]);
	_veh;
}] call Server_Setup_Compile;

["A3PL_Lib_ParseFaction",
{
	private _faction = param [0,""];
	private _return = "ERROR";
	switch (_faction) do
	{
		case ("fisd"): {_return = "Sheriff Department"};
		case ("uscg"): {_return = "US Coast Guard"};
		case ("fifr"): {_return = "Fire Rescue"};
		case ("fims"): {_return = "Marshals Service"};
		case ("doj"): {_return = "Department of Justice"};
	};
	_return;
}] call Server_Setup_Compile;

["A3PL_Lib_HideObject",
{
	private _object = param [0,objNull];
	private _hide = param [1,true];
	if (isServer) then {
		_object hideObjectGlobal _hide;
	} else {
		_object hideObject _hide;
	};
}] call Server_Setup_Compile;

["A3PL_Lib_ArrayRandom",
{
	private _array = _this;
	if (count _array == 0) exitwith {["System: Zero divisor error in Lib_ArrayRandom"] call A3PL_Player_Notification;};
	private _return = _array select (round (random (count _array-1)));
	_return;
}] call Server_Setup_Compile;

["A3PL_Lib_PPEffect",
{
	private _effect = param [0,"DynamicBlur"];
	private _value = param [1,[]];
	private _priority = 400;
	switch (_effect): {
		case ("DynamicBlur"): {_priority = 400;};
		case ("FilmGrain"): {_priority = 2000;};
	};
	while {
		_effect = ppEffectCreate ["DynamicBlur", _priority];
		_effect < 0
	} do { _priority = _priority + 1;};
	_effect ppEffectEnable true;
	_effect ppEffectAdjust _value;
	_effect ppEffectCommit 0;
	_effect;
}] call Server_Setup_Compile;

["A3PL_Lib_LoadAction",
{
	disableSerialization;
	private _text = param [0,""];
	private _actionTime = param [1,5];
	_time = 0;
	private _display = uiNamespace getVariable "Dialog_HUD_LoadAction";
	Player_ActionDoing = true;
	_refreshSpeed = _actionTime / 100;

	private _control = _display displayCtrl 351;
	_control ctrlSetStructuredText parseText format ["<t align='center'>%1</t>",_text];
	_control = _display displayCtrl 350;
	_control progressSetPosition 0;
	_control = _display displayCtrl 352;
	_control ctrlSetStructuredText parseText "<t size='1.8' font='RobotoCondensed' align='center' color='#B8B8B8'>0%</t>";

	_opacity = 1;
	for "_i" from 1 to 100 do
	{
		_opacity = _opacity - 0.01;
		(_display displayCtrl 394) ctrlSetFade  _opacity;
		(_display displayCtrl 350) ctrlSetFade _opacity;
		(_display displayCtrl 351) ctrlSetFade _opacity;
		(_display displayCtrl 352) ctrlSetFade _opacity;
		(_display displayCtrl 394) ctrlCommit 0;
		(_display displayCtrl 350) ctrlCommit 0;
		(_display displayCtrl 351) ctrlCommit 0;
		(_display displayCtrl 352) ctrlCommit 0;
	};

	private _controlPosition = _display displayCtrl 350;
	while {_time < _actionTime} do
	{
		_percent = _time / _actionTime;
		_control ctrlSetStructuredText parseText format ["<t size='1.8' font='RobotoCondensed' align='center' color='#B8B8B8'>%2%1</t>","%",round(_percent*100)];
		_controlPosition progressSetPosition _percent;
		sleep _refreshSpeed;
		_time = _time + _refreshSpeed;
		if(Player_ActionInterrupted) exitWith {};
		if(!(player getVariable["A3PL_Medical_Alive",true])) exitWith {};
		if (!(vehicle player isEqualTo player)) exitwith {};
		if (player getVariable ["Incapacitated",false]) exitwith {};
		if (!alive player) exitwith {};
	};

	Player_ActionCompleted = true;
	Player_ActionDoing = false;

	_opacity = 0;
	for "_i" from 1 to 100 do
	{
		_opacity = _opacity + 0.01;
		(_display displayCtrl 394) ctrlSetFade _opacity;
		(_display displayCtrl 350) ctrlSetFade _opacity;
		(_display displayCtrl 351) ctrlSetFade _opacity;
		(_display displayCtrl 352) ctrlSetFade _opacity;
		(_display displayCtrl 394) ctrlCommit 0;
		(_display displayCtrl 350) ctrlCommit 0;
		(_display displayCtrl 351) ctrlCommit 0;
		(_display displayCtrl 352) ctrlCommit 0;
		sleep 0.005;
	};
	sleep 3;
	Player_ActionInterrupted = false;
}] call Server_Setup_Compile;

["A3PL_Lib_HasPhone",
{
	private _player = param [0,player];
	private _items = assignedItems _player + items _player;
	private _hasPhone = false;
	{
		private _split = _x splitstring "_";
		{
			if (_x isEqualTo "Cellphone") exitwith {_hasPhone = true};
		} foreach _split;
		if (_hasPhone) exitwith {};
	} foreach _items;
	_hasPhone;
}] call Server_Setup_Compile;

["A3PL_Lib_MetersToMiles",
{
	private _meters = param [0,0];
	(_meters * 0.000621371);
}] call Server_Setup_Compile;

["A3PL_Lib_JobVehicle_Assign",
{
	private _class = param [0,""];
	private _pos = param [1,[]];
	private _job = param [2,""];
	private _inArea = param [4,""];

	[_class,_pos,format ["%1",toUpper _job],player] remoteExec ["Server_Vehicle_Spawn", 2];

	_t = 0;
	waituntil {sleep 0.5; _t = _t + 0.5; if (_t > 5) exitwith {true;}; !isNull (player getVariable ["jobVehicle",objNull]);};
	if (isNull (player getVariable ["jobVehicle",objNull])) exitwith
	{
		["System: Error occured, try to take the job back","red"] call A3PL_Player_Notification;
	};
	_veh = player getVariable ["jobVehicle",objNull];
	[localize"STR_NewLib_JobVehArrived"] call A3PL_Player_Notification;

	_job = toLower(_job);
	if(_job == "roadside") then {_job = "Roadside";};
	while {(player getVariable ["job","unemployed"]) == _job} do
	{
		if (isNull _veh) exitwith {[localize"STR_NewLib_JobVehDest","red"] call A3PL_Player_Notification; true;};
		if ((getDammage _veh) >= 1) exitwith {[localize"STR_NewLib_JobVehDest","red"] call A3PL_Player_Notification; true;};
		if ((player distance2D _veh) > 500) exitwith {[localize"STR_NewLib_JobVeh2Far","red"] call A3PL_Player_Notification; true;};
		sleep 300;
	};
	[_veh] call A3PL_Vehicle_Despawn;
	player setVariable ["jobVehicle",nil,true];
}] call Server_Setup_Compile;

["A3PL_Lib_hasPerk",
{
	private _perk = param [0,""];
	if (_perk IN (player getVariable ["perks",[]])) then {true;} else {false;};
}] call Server_Setup_Compile;

["A3PL_Lib_GetType",
{
	private ["_object","_return","_itemClass"];
	_object = param [0,objNull];
	if(isNull _object) exitWith {};
	_return = "aitem";
	_itemClass = typeOf _object;
	if(isClass (configFile >> "CfgWeapons" >> _itemClass)) then {_return = "weapon";};
	if(isClass (configFile >> "CfgMagazines" >> _itemClass)) then {_return = "magazine";};
	_return;
}] call Server_Setup_Compile;

["A3PL_Lib_GetHeading",
{
	private _heading = getDir player;
	switch (true) do {
        case ((_heading >= 0) && (_heading <= 22.5)): {_heading = "NORTH";};
        case ((_heading > 22.5) && (_heading < 67.5)): {_heading = "NE";};
        case ((_heading >= 67.5) && (_heading <= 112.5)): {_heading = "EAST";};
        case ((_heading > 112.5) && (_heading < 157.5)): {_heading = "SE";};
        case ((_heading >= 157.5) && (_heading <= 202.5)): {_heading = "SOUTH";};
        case ((_heading > 202.5) && (_heading < 247.5)): {_heading = "SW";};
        case ((_heading >= 247.5) && (_heading <= 292.5)): {_heading = "WEST";};
        case ((_heading > 292.5) && (_heading < 337.5)): {_heading = "NW";};
        case ((_heading >= 337.5) && (_heading <= 360)): {_heading = "NORTH";};
    };
	_heading;
}] call Server_Setup_Compile;

["A3PL_Lib_JobMessage",{
	private _msg = param [0,"No message defined!"];
	private _colour = param [1,"blue"];
	private _job = param [2,""];
	private _count = param [3,1];
	private _jobMembers = [_job] call A3PL_Lib_FactionPlayers;
	for [{_i = 0}, {_i < _count},{_i = _i + 1}] do {
		[_msg, _colour] remoteExec ["A3PL_Player_Notification",_jobMembers];
	};
}] call Server_Setup_Compile;

["A3PL_Lib_CreateMarker", {
	private _location = param [0,position player];
	private _msg = param [1,"No message defined!"];
	private _colour = param [2,"ColorWhite"];
	private _type = param [3,"mil_warning"];
	private _delTime = param [4,180];

	_marker = createMarkerLocal [format["marker_%1",floor (random 5000)],_location];
	_marker setMarkerShapeLocal "ICON";
	_marker setMarkerColorLocal _colour;
	_marker setMarkerTypeLocal _type;
	_marker setMarkerTextLocal format [_msg];

	sleep _delTime;
	deleteMarkerLocal _marker;
}] call Server_Setup_Compile;

["A3PL_Lib_AnimBusStop",
{
	{
		if (_x animationSourcePhase "advert_roll" >= 1.8) then {
			_x animateSource ["advert_roll",0.35,true];
		};
		_x animateSource ["advert_roll",1.8];
	} foreach Server_AllBusStops;
},true] call Server_Setup_Compile;

["A3PL_Lib_HandleItem",
{
	private ["_item","_details","_bool","_ispack","_items","_isgun","_ongun","_override","_toUniform","_toVest","_preview"];
	_item = [_this,0,"",[""]] call BIS_fnc_param;
	_bool = [_this,1,false,[false]] call BIS_fnc_param;
	_ispack = [_this,2,false,[false]] call BIS_fnc_param;
	_ongun = [_this,3,false,[false]] call BIS_fnc_param;
	_override = [_this,4,false,[false]] call BIS_fnc_param;
	_toUniform = [_this,5,false,[false]] call BIS_fnc_param;
	_toVest = [_this,6,false,[false]] call BIS_fnc_param;
	_preview = [_this,7,false,[false]] call BIS_fnc_param;

	if (_item isEqualTo "") exitWith {};
	_isgun = false;
	_details = [_item] call life_fnc_fetchCfgDetails;
	if (count _details isEqualTo 0) exitWith {};
	if (_bool) then {
	    switch (_details select 6) do {
	        case "CfgGlasses": {
	            if (_toUniform) exitWith {player addItemToUniform _item;};
	            if (_toVest) exitWith {player addItemToVest _item;};

	            if (_ispack) then {
	                player addItemToBackpack _item;
	            } else {
	                if (_override) then {
	                    player addItem _item;
	                } else {
	                    if (!(goggles player isEqualTo "")) then {
	                        removeGoggles player;
	                    };
	                    player addGoggles _item;
	                };
	            };
	        };
	        case "CfgVehicles": {
	            if (!(backpack player isEqualTo "")) then {
	                _items = (backpackItems player);
	                removeBackpack player;
	            };

	            player addBackpack _item;
	            clearAllItemsFromBackpack player;

	            if (!isNil "_items") then {
	                {[_x,true,true,false,true] call life_fnc_handleItem; } forEach _items;
	            };
	        };
	        case "CfgMagazines": {
	            if (_toUniform) exitWith {player addItemToUniform _item;};
	            if (_toVest) exitWith {player addItemToVest _item;};
	            if (_ispack) exitWith {player addItemToBackpack _item;};

	            player addMagazine _item;
	        };
	        case "CfgWeapons": {
	            if (_toUniform) exitWith {player addItemToUniform _item;};
	            if (_toVest) exitWith {player addItemToVest _item;};
	            if (_ispack) exitWith {player addItemToBackpack _item;};

	            if ((_details select 4) in [1,2,4,5,4096]) then {
	                if ((_details select 4) isEqualTo 4096) then {
	                    if ((_details select 5) isEqualTo -1) then {
	                        _isgun = true;
	                    };
	                } else {
	                    _isgun = true;
	                };
	            };
	            if (_isgun) then {
	                if (!_ispack && _override) exitWith {};
	                if (_item isEqualTo "MineDetector") then {
	                    player addItem _item;
	                } else {
	                    player addWeapon _item;
	                };
	            } else {
	                switch (_details select 5) do {
	                    case 0:  {
	                        if (_ispack) then {
	                            player addItemToBackpack _item;
	                        } else {
	                            if (_override) then {
	                                player addItem _item;
	                            } else {
	                                if (_item in (assignedItems  player)) then {
	                                    player addItem _item;
	                                } else {
	                                    player linkItem _item;
	                                };
	                            };
	                        };
	                    };
	                    case 605: {
	                        if (_ispack) then{
	                            player addItemToBackpack _item;
	                        } else {
	                            if (_override) then {
	                                player addItem _item;
	                            } else {
	                                if (headgear player isEqualTo _item && {!_preview}) then {
	                                    player addItem _item;
	                                } else {
	                                    if (!(headgear player isEqualTo "")) then {removeHeadGear player;};
	                                    player addHeadGear _item;
	                                };
	                            };
	                        };
	                    };
	                    case 801: {
	                        if (_ispack) then {
	                            player addItemToBackpack _item;
	                        } else {
	                            if (_override) then {
	                                player addItem _item;
	                            } else {
	                                if (player isKindOf "Civilian") then {
	                                    if (uniform player isEqualTo _item && {!_preview}) then {
	                                        player addItem _item;
	                                    } else {
	                                        if (!(uniform player isEqualTo "")) then {
	                                            _items = uniformItems player;
	                                            removeUniform player;
	                                        };

	                                        player addUniform _item;
	                                        if (!isNil "_items") then {
	                                            {player addItemToUniform _x} forEach _items;
	                                        };
	                                    };
	                                } else {
	                                    if (!(uniform player isEqualTo "")) then {
	                                        _items = uniformItems player;
	                                        removeUniform player;
	                                    };

	                                    if (!(player isUniformAllowed _item)) then {
	                                        player forceAddUniform _item;
	                                    } else {
	                                        player addUniform _item;
	                                    };
	                                    if (!isNil "_items") then {
	                                        {player addItemToUniform _x} forEach _items;
	                                    };
	                                };
	                            };
	                        };
	                    };
	                    case 701: {
	                        if (_ispack) then {
	                            player addItemToBackpack _item;
	                        } else {
	                            if (_override) then{
	                                player addItem _item;
	                            } else {
	                                if (vest player isEqualTo _item && {!_preview}) then {
	                                    player addItem _item;
	                                } else {
	                                    if (!(vest player isEqualTo "")) then {
	                                        _items = vestItems player;
	                                        removeVest player;
	                                    };

	                                    player addVest _item;

	                                    if (!isNil "_items") then {
	                                        {[_x,true,false,false,true] spawn life_fnc_handleItem;} forEach _items;
	                                    };
	                                };
	                            };
	                        };
	                    };
	                    case 201: {
	                        if (_ispack) then {
	                            player addItemToBackpack _item;
	                        } else {
	                            private "_type";
	                            _type = [_item,201] call life_fnc_accType;
	                            if (_ongun) then {
	                                switch (_type) do {
	                                    case 1: { player addPrimaryWeaponItem _item; };
	                                    case 2: { player addSecondaryWeaponItem _item; };
	                                    case 3: { player addHandgunItem _item; };
	                                };
	                            } else {
	                                if (_override) then {
	                                    player addItem _item;
	                                } else {
	                                    private ["_wepItems","_slotTaken"];
	                                    _wepItems = switch (_type) do {case 1:{primaryWeaponItems player}; case 2:{secondaryWeaponItems player}; case 3:{handgunItems player}; default {["","",""]};};
	                                    _slotTaken = false;
	                                    if (!((_wepItems select 2) isEqualTo "")) then {_slotTaken = true;};
	                                    if (_slotTaken) then {
	                                    } else {
	                                        switch (_type) do {
	                                            case 1: {player addPrimaryWeaponItem _item;};
	                                            case 2: {player addSecondaryWeaponItem _item;};
	                                            case 3: {player addHandgunItem _item;};
	                                            default {player addItem _item;};
	                                        };
	                                    };
	                                };
	                            };
	                        };
	                    };
	                    case 301: {
	                        if (_ispack) then {
	                            player addItemToBackpack _item;
	                        } else {
	                            private "_type";
	                            _type = [_item,301] call life_fnc_accType;

	                            if (_ongun) then {
	                                switch (_type) do {
	                                    case 1: { player addPrimaryWeaponItem _item; };
	                                    case 2: { player addSecondaryWeaponItem _item; };
	                                    case 3: { player addHandgunItem _item; };
	                                };
	                            } else {
	                                if (_override) then {
	                                    player addItem _item;
	                                } else {
	                                    private ["_wepItems","_slotTaken"];
	                                    _wepItems = switch (_type) do {case 1:{primaryWeaponItems player}; case 2:{secondaryWeaponItems player}; case 3:{handgunItems player}; default {["","",""]};};
	                                    _slotTaken = false;
	                                    if (!((_wepItems select 1) isEqualTo "")) then {_slotTaken = true;};
	                                    if (_slotTaken) then {
	                                    } else {
	                                        switch (_type) do {
	                                            case 1: {player addPrimaryWeaponItem _item;};
	                                            case 2: {player addSecondaryWeaponItem _item;};
	                                            case 3: {player addHandgunItem _item;};
	                                            default {player addItem _item;};
	                                        };
	                                    };
	                                };
	                            };
	                        };
	                    };
	                    case 101:{
	                        if (_ispack) then {
	                            player addItemToBackpack _item;
	                        } else {
	                            private "_type";
	                            _type = [_item,101] call life_fnc_accType;

	                            if (_ongun) then {
	                                switch (_type) do {
	                                    case 1: { player addPrimaryWeaponItem _item; };
	                                    case 2: { player addSecondaryWeaponItem _item; };
	                                    case 3: { player addHandgunItem _item; };
	                                };
	                            } else {
	                                if (_override) then {
	                                    player addItem _item;
	                                } else {
	                                    private ["_wepItems","_slotTaken"];
	                                    _wepItems = switch (_type) do {case 1:{primaryWeaponItems player}; case 2:{secondaryWeaponItems player}; case 3:{handgunItems player}; default {["","",""]};};
	                                    _slotTaken = false;
	                                    if (!((_wepItems select 0) isEqualTo "")) then {_slotTaken = true;};
	                                    if (_slotTaken) then {
	                                    } else {
	                                        switch (_type) do {
	                                            case 1: {player addPrimaryWeaponItem _item;};
	                                            case 2: {player addSecondaryWeaponItem _item;};
	                                            case 3: {player addHandgunItem _item;};
	                                            default {player addItem _item;};
	                                        };
	                                    };
	                                };
	                            };
	                        };
	                    };
	                    case 621: {
	                        if (_ispack) then {
	                            player addItemToBackpack _item;
	                        } else {
	                            if (_override) then {
	                                player addItem _item;
	                            } else {
	                                player linkItem _item;
	                            };
	                        };
	                    };
	                    case 616: {
	                        if (_ispack) then {
	                            player addItemToBackpack _item;
	                        } else {
	                            if (_override) then {
	                                player addItem _item;
	                            } else {
	                                player linkItem _item;
	                            };
	                        };
	                    };
	                    default {
	                        if (_ispack) then {
	                            player addItemToBackpack _item;
	                        } else {
	                            player addItem _item;
	                        };
	                    };
	                };
	            };
	        };
	    };
	} else {
	    if (_item isEqualTo "Binocular") exitWith {
	        if (_item in assignedItems player) then {
	            player removeWeapon "Binocular";
	        } else {
	            player removeItem "Binocular";
	        };
	    };
	    switch (_details select 6) do {
	        case "CfgVehicles": {
	            removeBackpack player;
	        };
	        case "CfgMagazines": {
	            player removeMagazine _item;
	        };
	        case "CfgGlasses": {
	            if (_item isEqualTo goggles player) then {
	                removeGoggles player;
	            } else {
	                player removeItem _item;
	            };
	        };
	        case "CfgWeapons": {
	            if ((_details select 4) in [1,2,4,5,4096]) then {
	                if ((_details select 4) isEqualTo 4096) then {
	                    if ((_details select 5) isEqualTo 1) then {
	                        _isgun = true;
	                    };
	                } else {
	                    _isgun = true;
	                };
	            };
	            if (_isgun) then {
	                switch (true) do {
	                    case (primaryWeapon player isEqualTo _item) : {_ispack = false;};
	                    case (secondaryWeapon player isEqualTo _item) : {_ispack = false;};
	                    case (handgunWeapon player isEqualTo _item) : {_ispack = false;};
	                    case (_item in assignedItems player) : {_ispack = false;};
	                    default {_ispack = true;};
	                };
	                if (_item isEqualTo "MineDetector") then {
	                    player removeItem _item;
	                } else {
	                    private "_tmpfunction";
	                    _tmpfunction = {
	                        private ["_tWeapons","_tWeaponCount"];
	                        switch (true) do {
	                            case (_this in (uniformItems player)): {
	                                _tWeapons = (getWeaponCargo (uniformContainer player)) select 0;
	                                _tWeaponCount = (getWeaponCargo (uniformContainer  player)) select 1;

	                                clearWeaponCargo (uniformContainer player);
	                                {
	                                    _numVestWeps = _tWeaponCount select _forEachIndex;
	                                    if (_x == _this) then
	                                    {
	                                        _numVestWeps = _numVestWeps - 1;
	                                    };
	                                    (uniformContainer player) addWeaponCargo [ _x,_numVestWeps];
	                                }forEach _tWeapons;
	                            };

	                            case (_this in (vestItems player)): {
	                                _tWeapons = (getWeaponCargo (vestContainer player)) select 0;
	                                _tWeaponCount = (getWeaponCargo (vestContainer  player)) select 1;

	                                clearWeaponCargo (vestContainer player);
	                                {
	                                    _numVestWeps = _tWeaponCount select _forEachIndex;
	                                    if (_x == _this) then
	                                    {
	                                        _numVestWeps = _numVestWeps - 1;
	                                    };
	                                    (vestContainer player) addWeaponCargo [ _x,_numVestWeps];
	                                }forEach _tWeapons;
	                            };

	                            case (_this in (backpackItems player)): {
	                                _tWeapons = (getWeaponCargo (backpackContainer player)) select 0;
	                                _tWeaponCount = (getWeaponCargo (backpackContainer  player)) select 1;

	                                clearWeaponCargo (backpackContainer player);
	                                {
	                                    _numVestWeps = _tWeaponCount select _forEachIndex;
	                                    if (_x == _this) then
	                                    {
	                                        _numVestWeps = _numVestWeps - 1;
	                                    };
	                                    (backpackContainer player) addWeaponCargo [ _x,_numVestWeps];
	                                }forEach _tWeapons;
	                            };
	                        };
	                    };

	                    if (_ispack) then {
	                        _item call _tmpfunction;
	                    } else {
	                        switch (true) do {
	                            case (_item in (uniformItems player)): {_item call _tmpfunction;};
	                            case (_item in (vestItems player)) : {_item call _tmpfunction;};
	                            case (_item in (backpackItems player)) : {_item call _tmpfunction;};
	                            default {player removeWeapon _item;};
	                        };
	                    };
	                };
	            } else {
	                switch (_details select 5) do {
	                    case 0: {player unassignItem _item; player removeItem _item;};
	                    case 605: {if (headgear player isEqualTo _item) then {removeHeadgear player} else {player removeItem _item};};
	                    case 801: {if (uniform player isEqualTo _item) then {removeUniform player} else {player removeItem _item};};
	                    case 701: {if (vest player isEqualTo _item) then {removeVest player} else {player removeItem _item};};
	                    case 621: {player unassignItem _item; player removeItem _item;};
	                    case 616: {player unassignItem _item; player removeItem _item;};
	                    default {
	                        switch (true) do {
	                            case (_item in primaryWeaponItems player) : {player removePrimaryWeaponItem _item;};
	                            case (_item in handgunItems player) : {player removeHandgunItem _item;};
	                            default {player removeItem _item;};
	                        };
	                    };
	                };
	            };
	        };
	    };
	};
},true] call Server_Setup_Compile;
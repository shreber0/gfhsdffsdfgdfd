/*
	ArmA 3 Fishers Life
	Code written by ArmA 3 Fishers Life Development Team
	@Copyright ArmA 3 Fishers Life (https://www.arma3fisherslife.net)
	YOU ARE NOT ALLOWED TO COPY OR DISTRIBUTE THE CONTENT OF THIS FILE WITHOUT AUTHOR AGREEMENT
	More informations : https://www.bistudio.com/community/game-content-usage-rules
*/

["A3PL_Robberies_RobPort",
{
	private ["_port"];
	_port = param [0,player_objintersect];
	_cooldown = missionNamespace getVariable ["PortRobberyCooldown",false];

	if (_cooldown) exitwith {["A port has already been robbed recently","red"] call A3PL_Player_Notification;};
	if ((currentWeapon player) isEqualTo "") exitwith {["You are not brandishing a firearm","red"] call A3PL_Player_Notification;};
	if ((currentWeapon player) IN ["A3FL_PepperSpray","A3FL_GolfDriver","A3FL_BaseballBat","Rangefinder","hgun_Pistol_Signal_F","A3PL_FireAxe","A3PL_Shovel","A3PL_Pickaxe","A3PL_Golf_Club","A3PL_Jaws","A3PL_High_Pressure","A3PL_Medium_Pressure","A3PL_Low_Pressure","A3PL_Taser","A3PL_FireExtinguisher","A3PL_Paintball_Marker","A3PL_Paintball_Marker_Camo","A3PL_Paintball_Marker_PinkCamo","A3PL_Paintball_Marker_DigitalBlue","A3PL_Paintball_Marker_Green","A3PL_Paintball_Marker_Purple","A3PL_Paintball_Marker_Red","A3PL_Paintball_Marker_Yellow","A3PL_Predator"]) exitwith {["You cannot rob a port with this weapon!","red"] call A3PL_Player_Notification;};

	_cg = ["uscg"] call A3PL_Lib_FactionPlayers;
	if ((count _cg) < 2) exitwith {["There must be at least 2 USCG on duty to rob this port!","red"] call A3PL_Player_Notification;};

	missionNamespace setVariable ["PortRobberyCooldown",true,true];
	[_port] call A3PL_Robberies_PortAlert;

	[getPlayerUID player,"portRobbery",[getPos _port]] remoteExec ["Server_Log_New",2];
	if (Player_ActionDoing) exitwith {[localize"STR_NewHunting_Action","red"] call A3PL_Player_Notification;};
	["Robbing the port captain...",180] spawn A3PL_Lib_LoadAction;
	waitUntil {Player_ActionDoing};
	_success = true;
	while {Player_ActionDoing} do {
		if ((player distance2D _port) > 5) exitWith {["You went away from the captain, the robbery failed!", "red"] call A3PL_Player_Notification; _success = false;};
		if (!(vehicle player == player)) exitwith {_success = false;};
		if (player getVariable ["Incapacitated",false]) exitwith {_success = false;};
		if ((currentWeapon player) isEqualTo "") exitWith {_success = false;};
	};
	if(!_success) exitWith {};

	["Successful robbery!", "green"] call A3PL_Player_Notification;
	["Some items have been added to your inventory, others may be on the ground!", "yellow"] call A3PL_Player_Notification;
	[player, 30] call A3PL_Level_AddXP;
	[_port] call A3PL_Robberies_PortReward;
	[getPlayerUID player,"portRobberrySuccess",[]] remoteExec ["Server_Log_New",2];

	uiSleep 1200;
	missionNamespace setVariable ["PortRobberyCooldown",false,true];
}] call Server_Setup_Compile;

["A3PL_Robberies_PortReward",
{
	private ["_port","_rewardArray"];
	_port = param [0,objNull];
	_itemsArray = [
		["item","cash",2000 + round(random(10000))],
		["item","v_lockpick",3],
		["item","Titanium",14],
		["item","shark_10lb",4],
		// ["item","SMG_Part_Body",1],
		["item","zipties",5],
		["item","weed_50g",11],

		["weapon","A3PL_Red_Glock",0],
		["weapon","hgun_Rook40_F",0],
		["weapon","A3PL_P226",0],

		["magazine","A3PL_Red_Glock_Mag",8],
		["magazine","16Rnd_9x21_Mag",8],
		["magazine","A3PL_P226_Mag",8]
	];
	_rewardArray = [];

	_chanceNbItems = 5 + round(random 4);
	for "_i" from 0 to _chanceNbItems do {
		_rewardArray pushBack (selectRandom _itemsArray);
	};

	{
		private["_type","_class","_maxAmount","_amount","_enoughtSpace"];
		_type = _x select 0;
		_class = _x select 1;
		_maxAmount = _x select 2;
		_amount = 1 + round(random _maxAmount);
		switch(_type) do {
			case("item"): {
				_enoughtSpace = (([[_class,_amount]] call A3PL_Inventory_TotalWeight) <= Player_MaxWeight);
				if(_enoughtSpace) then {
					[_class,_amount] call A3PL_Inventory_Add;
				} else {
					_obj = _itemClass createVehicle (getPos player);
					_obj setPosASL (AGLtoASL (player modelToWorld [0,1,0]));
				};
			};
			case("weapon"): {
				_weaponHolder = createVehicle ["GroundWeaponHolder", getposATL player, [], 0, "CAN_COLLIDE"];
				_weaponHolder addWeaponGlobal _class;
			};
			case("magazine"): {
				_weaponHolder = createVehicle ["GroundWeaponHolder", getposATL player, [], 0, "CAN_COLLIDE"];
				_weaponHolder addMagazineCargoGlobal [_class,_amount];
			};
		};
	} foreach _rewardArray;
}] call Server_Setup_Compile;

["A3PL_Robberies_PortAlert",
{
	private ["_port","_namePos"];
	_port = param [0,objNull];
	_namePos = "unknown location";
	switch(str(_port)) do {
		case("npc_port_1"): {
			_namePos = "Stoney Creek";
		};
		case("npc_port_2"): {
			_namePos = "Steel Mill";
		};
		case("npc_port_3"): {
			_namePos = "Elk City";
		};
		case("npc_port_4"): {
			_namePos = "Weapons Factory";
		};
		case("npc_port_5"): {
			_namePos = "Marine Factory";
		};
		case("npc_port_6"): {
			_namePos = "Bluecorp Mining";
		};
	};
	[format ["An alarm has been triggered by the port captain at %1",_namePos],"blue","uscg",1] call A3PL_Lib_JobMessage;
}] call Server_Setup_Compile;

["A3PL_Robberies_PickSeizure",{
	private ["_storage"];
	_storage = param [0,objNull];
	_timer = false;
	if (!isNil {_storage getVariable ["timer",nil]}) then {
		if (((serverTime - (_storage getVariable ["timer",0]))) < 1800) then {_timer = true};
	};
	if (_timer) exitwith {[format ["The evidince locker has recently been robbed, try again in %1 seconds",1800 - ((_bank getVariable ["timer",0]) - serverTime)],"red"] call A3PL_Player_Notification;};
	if (animationstate player == "Acts_carFixingWheel") exitwith {[localize"STR_CRIMINAL_YOUALREADYTAKEANACTION", "red"] call A3PL_Player_Notification;};
	if (!(vehicle player == player)) exitwith {[localize"STR_CRIMINAL_YOUCANTPICKVEHICLEINTOVEHICLE", "red"] call A3PL_Player_Notification;};
	if (Player_ActionDoing) exitwith {[localize"STR_CRIMINAL_YOUALREADYPICKVEHICLE", "red"] call A3PL_Player_Notification;};

	_fims = ["fims"] call A3PL_Lib_FactionPlayers;
	if ((count _fims) < 5) exitwith {["There must be at least 5 Marshals on duty to rob this!","red"] call A3PL_Player_Notification;};

	[] remoteExec ["A3PL_Robberies_SeizureAlert", _fims];

	player playmove "Acts_carFixingWheel";
	player setVariable ["picking",true,true];

	[getPlayerUID player,"docRobbery",[getPos _storage]] remoteExec ["Server_Log_New",2];
	[_storage] spawn
	{
		private ["_storage"];
		_storage = param [0,objNull];
		playSound3D ["A3PL_Common\effects\burglaralarm.ogg", _storage, false, getPosASL _storage, 1, 1, 200];

		if (Player_ActionDoing) exitwith {[localize"STR_NewHunting_Action","red"] call A3PL_Player_Notification;};
		["Lockpicking seizure storage...",90] spawn A3PL_Lib_LoadAction;

		_chance = random 100;
		if(_chance >= 80) then {playSound3D ["A3PL_Common\effects\lockdown.ogg", objNull, false, [4783.52,6294.25,12], 3, 1, 1800];};

		_success = true;
		waitUntil{Player_ActionDoing};
		while {Player_ActionDoing} do {
			if ((player distance2D _storage) > 5) exitWith {[localize"STR_CRIMINAL_NEEDTOBENEAR5M", "red"] call A3PL_Player_Notification; _success = false;};
			if (!((vehicle player) isEqualTo player)) exitwith {_success = false;};
			if (player getVariable ["Incapacitated",false]) exitwith {_success = false;};
			if (!(player_itemClass isEqualTo "v_lockpick")) exitwith {_success = false;};
			if (!(["v_lockpick",1] call A3PL_Inventory_Has)) exitwith {_success = false;};
		};
		player switchMove "";
		if(Player_ActionInterrupted || !_success) exitWith {
			[localize"STR_CRIMINAL_PICKENDED", "red"] call A3PL_Player_Notification;
			if ((vehicle player) isEqualTo player) then {player switchMove "";};
		};

		[player_item] call A3PL_Inventory_Clear;
		[player,"v_lockpick",-1] remoteExec ["Server_Inventory_Add",2];

		_chance = random 100;
		if(_chance >= 35) then {
			_storage setVariable["locked",false,true];
			_storage setVariable ["timer",serverTime,true];
			[localize"STR_CRIMINAL_PICKSUCCESSFULLHC", "green"] call A3PL_Player_Notification;
			[player,20] call A3PL_Level_AddXP;
			[getPlayerUID player,"seizureRobberrySuccess",[]] remoteExec ["Server_Log_New",2];
		} else {
			[localize"STR_CRIMINAL_YOUCANNOTPICKTHISVEHICLEHC", "red"] call A3PL_Player_Notification;
		};
	};
}] call Server_Setup_Compile;

["A3PL_Robberies_SeizureAlert",
{
	["The alarm in the seizure storage has been triggered","blue"] call A3PL_Player_Notification;
	playSound3D ["A3PL_Common\effects\panic-button.ogg", player, false, getPosASL player, 5, 1, 5];
}] call Server_Setup_Compile;

["A3PL_Robberies_RobPShip",
{
	private _isBeingRobbed = Ship_BlackMarket getVariable["robProgress",false];
	private _cooldown = Ship_BlackMarket getVariable ["RobCooldown",serverTime-7200];
	if (_isBeingRobbed) exitWith {["The ship is already being robbed!","red"] call A3PL_Player_Notification;};
	if (_cooldown > (serverTime-7200)) exitWith {["The ship has already been robbed recently!","red"] call A3PL_Player_Notification;};
	if ((currentWeapon player) isEqualTo "") exitwith {["You are not brandishing a firearm","red"] call A3PL_Player_Notification;};
	if ((currentWeapon player) IN ["A3FL_PepperSpray","A3FL_GolfDriver","A3FL_BaseballBat","Rangefinder","hgun_Pistol_Signal_F","A3PL_FireAxe","A3PL_Shovel","A3PL_Pickaxe","A3PL_Golf_Club","A3PL_Jaws","A3PL_High_Pressure","A3PL_Medium_Pressure","A3PL_Low_Pressure","A3PL_Taser","A3PL_FireExtinguisher","A3PL_Paintball_Marker","A3PL_Paintball_Marker_Camo","A3PL_Paintball_Marker_PinkCamo","A3PL_Paintball_Marker_DigitalBlue","A3PL_Paintball_Marker_Green","A3PL_Paintball_Marker_Purple","A3PL_Paintball_Marker_Red","A3PL_Paintball_Marker_Yellow","A3PL_Predator"]) exitwith {["You cannot rob a port with this weapon!","red"] call A3PL_Player_Notification;};
	if (Player_ActionDoing) exitwith {["You are already doing something.","red"] call A3PL_Player_Notification;};

	private _requiredCG = 5;
	private _CG = ["uscg"] call A3PL_Lib_FactionPlayers;
	if(count(_CG) < _requiredCG) exitWith {["There is not 5 CG available to rob the pirate ship!","red"] call A3PL_Player_Notification;};

	[] remoteExec ["A3PL_Robberies_PShipRobbed",_CG];

	["Robbing the ship...",480] spawn A3PL_Lib_LoadAction;
	waitUntil{Player_ActionDoing};
	while {Player_ActionDoing} do {
		if((player distance Ship_BlackMarket) > 20) exitWith {Player_ActionInterrupted = true;};
		if (!(player getVariable["A3PL_Medical_Alive",true])) exitWith {Player_ActionInterrupted = true;};
		if ((vehicle player) != player) exitwith {Player_ActionInterrupted = true;};
		if (player getVariable ["Incapacitated",false]) exitwith {Player_ActionInterrupted = true;};
	};
	if(Player_ActionInterrupted) exitWith {["Capture cancelled.","red"] call A3PL_Player_Notification;};
	[] call A3PL_Robberies_ShipSuccess;
	
	[getPlayerUID player,"shipCaptured",[]] remoteExec ["Server_Log_New",2];
}] call Server_Setup_Compile;

["A3PL_Robberies_ShipSuccess",
{
	private _countUSCG = count(["uscg"] call A3PL_Lib_FactionPlayers);
	private _moneyAmount = 250000 + round(random 50000) + (10000*_countUSCG);
	private _currentMoney = player getVariable["Player_Cash",0];
	private _totalArray = [["weed_100g",8],["shrooms",8],["cocaine",13]];
	private _finalArray = [];
	private _itemCount = 2 + round(random(5));
	for "_i" from 0 to _itemCount do {
		_item = (selectRandom _totalArray);
		_finalArray = [_finalArray, _item select 0, _item select 1, true] call BIS_fnc_addToPairs;
	};
	{
		[(_x select 0),(_x select 1)] call A3PL_Inventory_Add;
	} foreach _finalArray;
	player setVariable["Player_Cash",_currentMoney+_moneyAmount,true];
	Ship_BlackMarket setVariable ["RobCooldown",diag_Ticktime,true];
}] call Server_Setup_Compile;

["A3PL_Robberies_PShipRobbed",
{
	private _markers = [];
	private _shipRealPos = getPos Ship_BlackMarket;
	private _givenPos = [((_shipRealPos select 0) + (-20 + random 100)),((_shipRealPos select 1) + (-40 + random 100))];

	_marker = createMarkerLocal [format["%1_marker",floor (random 5000)],_givenPos];
	_marker setMarkerShapeLocal "ELLIPSE";
	_marker setMarkerSizeLocal [900,900];
	_marker setMarkerColorLocal "ColorRed";
	_marker setMarkerTypeLocal "Mil_dot";
	_marker setMarkerAlphaLocal 0.75;
	_markers pushback _marker;

	_marker = createMarkerLocal [format["%1_marker",floor (random 5000)],_givenPos];
	_marker setMarkerShapeLocal "ICON";
	_marker setMarkerColorLocal "ColorWhite";
	_marker setMarkerTypeLocal "A3PL_Markers_USCG";
	_marker setMarkerTextLocal "SHIP DISTRESS SIGNAL";
	_markers pushback _marker;

	["Coast Guard, look at me, I'm the captain now!","blue"] call A3PL_Player_Notification;
	["Help! They are taking over my ship! It's a big black ship! Send help!","blue"] call A3PL_Player_Notification;
	sleep 600;
	{
		deleteMarker _x;
	} foreach _markers;
}] call Server_Setup_Compile;

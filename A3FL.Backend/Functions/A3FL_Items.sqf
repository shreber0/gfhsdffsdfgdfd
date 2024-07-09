/*
	ArmA 3 Fishers Life
	Code written by ArmA 3 Fishers Life Development Team
	@Copyright ArmA 3 Fishers Life (https://www.arma3fisherslife.net)
	YOU ARE NOT ALLOWED TO COPY OR DISTRIBUTE THE CONTENT OF THIS FILE WITHOUT AUTHOR AGREEMENT
	More informations : https://www.bistudio.com/community/game-content-usage-rules
*/

["A3PL_Items_Thirst",
{

	private _classname = Player_ItemClass;
	private _quality = [_classname, "quality"] call A3PL_Config_GetThirst;
	private _alcohol = [_classname, "alcohol"] call A3PL_Config_GetThirst;
	private _coffeeTime = [_classname, "coffeeTime"] call A3PL_Config_GetThirst;
	if (Player_ItemClass isEqualTo "") exitwith {[localize"STR_NewItems_12","red"] call A3PL_Player_Notification;};
	if (!isNil "Player_isDrinking") exitwith {[localize"STR_NewItems_11","red"] call A3PL_Player_Notification;};
	Player_isDrinking = true;

	[_classname, -1] call A3PL_Inventory_Add;
	if(_classname isEqualTo "waterbottle") then {["waterbottlempty", 1] call A3PL_Inventory_Add;};

	player playAction "Gesture_drink";
	Player_Item attachTo [player, [-0.03,0,0.1], 'LeftHand'];
	sleep 3;
	Player_Item setVectorDirAndUp [[0,0,-1],[0,-1,0]];
	sleep 3;
	Player_Item setVectorDirAndUp [[0,1,0],[0,0,1]];
	sleep 4.5;

	// If the associated drink has a coffee time
	if (_coffeeTime > 0) then {
		// If you're not currently on coffee
		if (!(player getVariable ["UsingCoffee", false])) then {
			// You now are on coffee...
			player setVariable ["UsingCoffee", true, true];

			// Add effect handler to the scheduler
			[_coffeeTime] spawn {
				// Apply faster speed
				[format["You have drank coffee and will now be faster for %1 minutes!", (_this select 0)], "green"] call A3PL_Player_Notification;
				player setAnimSpeedCoef 1.7;

				// Sleep for the coffee effect duration
				sleep ((_this select 0) * 60);

				// Slower speed
				["You have run out of caffeine!", "amber"] call A3PL_Player_Notification;
				player setAnimSpeedCoef 0.7;

				// Sleep for the slowness length (3 minutes)
				sleep 180;

				// Back to normal
				["Your energy is now back to normal!", "green"] call A3PL_Player_Notification;
				player setAnimSpeedCoef 1;

				player setVariable ["UsingCoffee", false, true];
			};
		} else {
			["You are already experiencing a caffeine high, this coffee will not impact your speed!", "amber"] call A3PL_Player_Notification;
		};
	};

	if(_alcohol) then {
		[_quality] call A3PL_Alcohol_Add;
	} else {
		Player_Thirst = Player_Thirst + _quality;
		call A3PL_Lib_VerifyThirst;
		profileNamespace setVariable ["player_thirst",Player_Thirst];
		if((_classname isEqualTo "waterbottle") && (Player_Alcohol > 0)) then {
			[-5] call A3PL_Alcohol_Add;
			call A3PL_Alcohol_Verify;
		};
		if (Player_Thirst > 50) then { A3PL_ThirstWarning1 = Nil; };
		if (Player_Thirst > 20) then { A3PL_ThirstWarning2 = Nil; };
		if (Player_Thirst > 10) then { A3PL_ThirstWarning3 = Nil; };
		[format[localize"STR_NewItems_10", [_classname, "name"] call A3PL_Config_GetItem, _quality,"%"], "green"] call A3PL_Player_Notification;
	};

	Player_ItemAmount = Player_ItemAmount - 1;
	if(Player_ItemAmount isEqualTo 0) then{[] call A3PL_Inventory_Clear;};

	Player_isDrinking = nil;
}] call Server_Setup_Compile;

["A3PL_Items_Food",
{
	private _classname = Player_ItemClass;
	private _quality = [_classname, "quality"] call A3PL_Config_GetFood;
	private _drug = [_classname, "drug"] call A3PL_Config_GetFood;
	if (Player_ItemClass isEqualTo "") exitwith {[localize"STR_NewItems_7","red"] call A3PL_Player_Notification;};
	if (!isNil "Player_isEating") exitwith {[localize"STR_NewItems_8","red"] call A3PL_Player_Notification;};
	if (!([_classname,1] call A3PL_Inventory_Has)) exitwith {[localize"STR_NewItems_9","red"] call A3PL_Player_Notification;};
	
	Player_isEating = true;
	player playActionNow "gesture_eat";
	[_classname, -1] call A3PL_Inventory_Add;

	if(_drug) then {
		[_classname,_quality] call A3PL_Drugs_Add;
	} else {
		Player_Hunger = Player_Hunger + _quality;
		call A3PL_Lib_VerifyHunger;
		profileNamespace setVariable ["player_hunger",Player_Hunger];

		if (_quality > 0) then {
			[format[localize"STR_NewItems_6", [_classname, "name"] call A3PL_Config_GetItem, _quality,"%"], "green"] call A3PL_Player_Notification;
		};
		if (Player_Hunger > 50) then {A3PL_HungerWarning1 = Nil;};
		if (Player_Hunger > 20) then {A3PL_HungerWarning2 = Nil;};
		if (Player_Hunger > 10) then {A3PL_HungerWarning3 = Nil;};
	};

	[] spawn {
		sleep 3;
		Player_ItemAmount = Player_ItemAmount - 1;
		if(Player_ItemAmount isEqualTo 0) then{[] call A3PL_Inventory_Clear;};
		Player_isEating = Nil;
	};
}] call Server_Setup_Compile;

["A3PL_Items_IgniteRocket",
{
	private ["_rocket","_color"];

	_rocket = param [0,objNull];
	if ((isPlayer (attachedTo _rocket)) && (!((attachedTo _rocket) isKindOf "Car"))) exitwith {[localize"STR_NewItems_2","red"] call A3PL_Player_Notification;};
	if (!local _rocket) exitwith {[localize"STR_NewItems_3","red"] call A3PL_Player_Notification;};
	if ((_rocket animationSourcePhase "fuse") > 0) exitwith {};
	_color = _rocket getVariable ["class","rocket_blue"];

	_rocket setVariable ["inUse",true,true];

	//ignite rocket fuse
	_rocket animateSource ["fuse",2];
	uiSleep 4;

	//rocket goes up
	[_rocket,_color] remoteExec ["A3PL_Items_RemoteRocket", -2]; // change to -2
	_rocket setVelocity [(-20 + (random 40)),(-20 + (random 40)),(50 + random 50)];

	//rocket reaches point of explosion
	uiSleep 3;
	deleteVehicle _rocket;
}] call Server_Setup_Compile;

["A3PL_Items_RemoteRocket",
{
	private ["_rocket","_color","_pos","_i","_r","_g","_b","_s1","_sparks"];

	_rocket = param [0,objNull];
	_color = param [1,"rocket_blue"];

	//wait until the rocket is deleted, upon deletion we will do our fireworks :D
	_i = 0;
	_pos = getPos _rocket;
	waitUntil {_i = _i + 1; if (_i > 100) exitwith {true}; if (!isNull _rocket) then {_pos = getpos _rocket;}; sleep 0.1; isNull _rocket};
	if (_i > 100) exitwith {};

	_sparks = [];

	for "_ii" from 0 to 15 do
	{
		_s = "#particlesource" createVehicleLocal _pos;
		_sparks pushback _s;
	};

	_r = 0;
	_g = 0;
	_b = 1;

	switch (_color) do
	{
		case "rocket_blue": {_r = 0.02; _g = 0; _b =1};
		case "rocket_red": {_r = 1; _g = 0; _b = 0.02};
		case "rocket_green": {_r = 0.02; _g = 1; _b = 0};
		case "rocket_yellow": {_r = 0.95; _g = 0.95; _b = 0.05};
	};

	//lightpoint
	_lP = "#lightpoint" createVehiclelocal _pos;
	_lP setLightBrightness 30;
	_lP setLightDayLight true;
	_lP setLightAmbient [_r,_g,_b];
	_lP setLightColor [_r,_g,_b];

	//sound
	_logic = "Logic" createVehiclelocal _pos;
	_logic say3D [(["firework1","firework2","firework3"] call BIS_fnc_selectRandom), 1500, 1];

	{
		_vel = [(-10 + random 20),(-10 + random 20),(-10 + random 20)];
		_x setParticleCircle [0, [0, 0, 30]];
		_x setParticleRandom [0.5, [0, 0, 0], [0, 0, 0], 0, 0.5, [_r,_g,_b, 1], 1, 0];
		_x setParticleParams [["\A3\data_f\cl_exp", 1, 0, 1], "", "Billboard", 1, 2, [0, 0, 0], _vel, 0, 70, 0, 0, [0.5,1], [[_r,_g,_b, 1],[_r,_g,_b, 0.5]], [0.08], 1, 0, "", "",_x];
		_x setDropInterval 0.01;
	} foreach _sparks;

	uisleep 1;

	//main
	_pS = "#particlesource" createVehicleLocal [(_pos select 0),(_pos select 1),((_pos select 2) + random 10)];
	_xx = [-7,7] call BIS_fnc_selectRandom;
	_yy = [-5,7] call BIS_fnc_selectRandom;
	_zz = [-8,5] call BIS_fnc_selectRandom;
	_pS setParticleCircle [0, [_xx, _yy, _zz]];
	_pS setParticleRandom [0, [0, 0, 0], [_xx, _yy, _zz], 0, 0.5, [_r,_g,_b, 1], 1, 0];
	_pS setParticleParams [["\A3\data_f\cl_exp", 1, 0, 1], "", "Billboard", 1, 1.5, [0, 0, 0], [_xx, _yy, _zz], 0, 50, 0, 0, [0.5,1], [[_r, _g,_b, 1],[_r, _g, _b, 0.5]], [0.08], 1, 0, "", "",_pS];
	_pS setDropInterval 0.0005;


	uiSleep 1;
	deleteVehicle _pS;
	{
		deleteVehicle _x;
	} foreach _sparks;

	uiSleep 3;
	deleteVehicle _lP;
	deleteVehicle _logic;
}] call Server_Setup_Compile;

["A3PL_Items_FillBottle",
{
	if(!(call A3PL_Player_AntiSpam)) exitWith {};
	private _classname = Player_ItemClass;
	if(_classname != "waterbottlempty") exitwith {[localize"STR_NewItems_1","red"] call A3PL_Player_Notification;};
	if (!([_classname,1] call A3PL_Inventory_Has)) exitwith {[localize"STR_NewItems_1","red"] call A3PL_Player_Notification;};
	[_classname, -1] call A3PL_Inventory_Add;
	["waterbottle", 1] call A3PL_Inventory_Add;
	[false] call A3PL_Inventory_PutBack;
}] call Server_Setup_Compile;
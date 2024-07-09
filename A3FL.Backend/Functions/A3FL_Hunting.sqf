/*
	ArmA 3 Fishers Life
	Code written by ArmA 3 Fishers Life Development Team
	@Copyright ArmA 3 Fishers Life (https://www.arma3fisherslife.net)
	YOU ARE NOT ALLOWED TO COPY OR DISTRIBUTE THE CONTENT OF THIS FILE WITHOUT AUTHOR AGREEMENT
	More informations : https://www.bistudio.com/community/game-content-usage-rules
*/

["A3PL_Hunting_Skin",
{
	private _animal = param [0,objNull];
	private _success = true;
	if (isNull _animal) exitwith {};
	private _type = typeOf _animal;
	if (Player_ActionDoing) exitwith {[localize"STR_NewHunting_Action","red"] call A3PL_Player_Notification;};
	if (_animal getVariable ["skinning",false]) exitwith {[localize"STR_NewHunting_AlreadySkinned"] call A3PL_Player_Notification;};
	_animal setVariable ["skinning",true,true];

	["Skinning the animal...",20] spawn A3PL_Lib_LoadAction;
	waitUntil{Player_ActionDoing};
	player playMoveNow 'ainvpknlmstpsnonwnondnon_medic_1';
	while {Player_ActionDoing} do {
		if ((player distance2D _animal) > 5) exitwith {_success = false};
		if (!(player getVariable["A3PL_Medical_Alive",true])) exitWith {_success = false;};
		if ((vehicle player) != player) exitwith {_success = false;};
		if (player getVariable ["Incapacitated",false]) exitwith {_success = false;};
		if ((animationstate player) != "ainvpknlmstpsnonwnondnon_medic_1") then {player playMoveNow 'ainvpknlmstpsnonwnondnon_medic_1';};
	};
	player playMoveNow "";
	if(Player_ActionInterrupted || !_success) exitWith {["Action cancelled","red"] call A3PL_Player_Notification;_animal setVariable ["skinning",nil,true];};

	private _meatItem = "meat_sheep";
	private _animalType = "Unknown";
	switch (true) do
	{
		case (_type IN ["Goat","Goat02","Goat03"]): { _meatItem = "meat_goat"; _animalType = "goat"; };
		case (_type IN ["WildBoar"]): { _meatItem = "meat_boar"; _animalType = "wildboar"; };
		case (_type IN ["Sheep","Sheep02","Sheep03"]): { _meatItem = "meat_sheep"; _animalType = "sheep";};
		case (_type IN ["Cow01","Cow02","Cow03","Cow04","Cow05"]): { _meatItem = "meat_cow"; _animalType = "cow";};
	};

	_amount = 1 + floor(random(3));
	_amount = _amount * A3PL_Event_DblHarvest;
	[_meatItem,_amount] call A3PL_Inventory_Add;
	[format [localize"STR_NewHunting_Earned",_animalType,_amount,[_meatItem,"name"] call A3PL_Config_GetItem],"green"] call A3PL_Player_Notification;

	deleteVehicle _animal;
	[player,8] call A3PL_Level_AddXP;
}] call Server_Setup_Compile;

["A3PL_Hunting_Tag",
{
	private ["_meat","_newClass","_tagClass","_class"];
	_meat = param [0,objNull];
	_class = _meat getVariable ["class","unknown"];
	switch (_class) do
	{
		case ("meat_goat"): {_newClass = "meat_goat_tag"; _tagClass = "tag_meat";};
		case ("meat_sheep"): {_newClass = "meat_sheep_tag"; _tagClass = "tag_meat";};
		case ("meat_boar"): {_newClass = "meat_boar_tag"; _tagClass = "tag_meat";};
		case ("meat_cow"): {_newClass = "meat_cow_tag"; _tagClass = "tag_meat";};

		case ("mullet"): {_newClass = "mullet_tag"; _tagClass = "tag_fish";};
		case ("shark_2lb"): {_newClass = "shark_2lb_tag"; _tagClass = "tag_shark";};
		case ("shark_4lb"): {_newClass = "shark_4lb_tag"; _tagClass = "tag_shark";};
		case ("shark_5lb"): {_newClass = "shark_5lb_tag"; _tagClass = "tag_shark";};
		case ("shark_7lb"): {_newClass = "shark_7lb_tag"; _tagClass = "tag_shark";};
		case ("shark_10lb"): {_newClass = "shark_10lb_tag"; _tagClass = "tag_shark";};
	};
	if (isNil "_tagClass") exitwith {[localize"STR_NewHunting_NoLabel","red"] call A3PL_Player_Notification};
	if (!([_tagClass,1] call A3PL_Inventory_Has)) exitwith {[localize"STR_NewHunting_NoLabel","red"] call A3PL_Player_Notification};
	if (isNil "_newClass") exitwith {[localize"STR_NewHunting_AlreadyLabeled"] call A3PL_Player_Notification;};
	if ((_meat getVariable ["amount",1]) > 1) exitwith {[localize"STR_NewHunting_1By1","red"] call A3PL_Player_Notification;};
	_meat setVariable ["class",_newClass,true];
	[_tagClass,-1] call A3PL_Inventory_Add;
	[localize"STR_NewHunting_LabeledOk","green"] call A3PL_Player_Notification;
}] call Server_Setup_Compile;

/*
	ArmA 3 Fishers Life
	Code written by ArmA 3 Fishers Life Development Team
	@Copyright ArmA 3 Fishers Life (https://www.arma3fisherslife.net)
	YOU ARE NOT ALLOWED TO COPY OR DISTRIBUTE THE CONTENT OF THIS FILE WITHOUT AUTHOR AGREEMENT
	More informations : https://www.bistudio.com/community/game-content-usage-rules
*/

['A3PL_Loading_Start',
{
	[] spawn {
		private ['_display', '_format', '_control'];
		disableSerialization;
		if (!isServer) then
		{
			["A3PL_Common\ogv\logo_base_animated.ogv"] call BIS_fnc_titlecard;
			uiSleep 6;
		};
		player setVariable ["tf_voiceVolume", 0, true];
		['Dialog_Loading'] call A3PL_Lib_CreateDialog;
		_display = findDisplay 15;

		/* LOADING COLOR */
		// - <t color='#fac61c' size='2.8'>PARTIAL</t>
		//+ "<t size='1' align='left' color='#ff0000'> IMPORTANT: </t><t size='1' align='left'>TEXT_HERE.</t>"
		//+ "<t size='1' align='left' color='#00ff00'> Added: </t><t size='1' align='left'>TEXT_HERE.</t>"
		//+ "<t size='1' align='left' color='#ff8000'> Changed: </t><t size='1' align='left'>TEXT_HERE.</t>"
		//+ "<t size='1' align='left' color='#ff8000'> Fixed: </t><t size='1' align='left'>TEXT_HERE.</t>"
		//+ "<t size='1' align='left' color='#ff0000'> Deleted: </t><t size='1' align='left'>TEXT_HERE.</t>"

		_control = (_display displayCtrl 69);
		_format = "<t size='3' font='PuristaSemiBold' align='center' color='#B8B8B8'>VERSION 3.4.1</t>"
		+ "<br/>"
		+ "<t size='1' align='left' color='#00ff00'> Added: </t><t size='1' align='left'>Halloween Event</t>"
		+ "<br/>"
		+ "<t size='1' align='left' color='#00ff00'> Added: </t><t size='1' align='left'>More NPCs to Northern Island</t>"
		+ "<br/>"
		+ "<t size='1' align='left' color='#ff8000'> Fixed: </t><t size='1' align='left'>Lots of bugs</t>"
		+ "<br/>"
		+ "<t size='1' align='left' color='#ff0000'> Deleted: </t><t size='1' align='left'>USCG Dolphin Files</t>"
		+ "<br/>"
		+ "<t size='1' align='left' color='#ff8000'> Fixed: </t><t size='1' align='left'>Addon Optimization (Reduced Size)</t>"
		+ "<br/>"
		+ "<t size='1' align='left' color='#00ff00'> Added: </t><t size='1' align='left'>Smart Car / BMW M6 / Mercedes Benz C63 AMG</t>"
		+ "<br/>"
		+ "<t size='0.8' align='center'>For the full changelog visit the forum @ arma3fisherslife.net</t>";
		_control ctrlSetStructuredText (parseText _format);

		_control = (_display displayCtrl 10360);
		_format = "<t size='1' align='center' color='#B8B8B8'>0%</t>";
		_control ctrlSetStructuredText (parseText _format);

		_control = (_display displayCtrl 10359);
		_format = "<t size='1' align='center' color='#B8B8B8'>Receiving player functions...</t>";
		_control ctrlSetStructuredText (parseText _format);

		_control = (_display displayCtrl 11059);
		_control progressSetPosition 0.5;

		noEscape = _display displayAddEventHandler ["KeyDown", "if ((_this select 1) == 1) then {true}"];

		call A3PL_Loading_Request;
	};
}] call Server_Setup_Compile;

["A3PL_Loading_Request", {
	[] spawn {
		private ["_waiting","_display","_control", '_format',"_pos"];
		disableSerialization;

		_display = findDisplay 15;

		_control = (_display displayCtrl 10359);
		_format = localize "STR_A3PLS_LOADINGREQUEST_SERVERFUNCTIONSRECEIVED";
		_control ctrlSetStructuredText (parseText _format);

		_control = (_display displayCtrl 11059);
		_control progressSetPosition 0.3;

		_control = (_display displayCtrl 10360);
		_format = "<t size='2' align='center' color='#B8B8B8'>30%</t>";
		_control ctrlSetStructuredText (parseText _format);

		// Do not start doing any of this until we are in the game
		waitUntil {uiSleep 0.5; player == player};
		_pos = getpos player;
		uiSleep 1;

		//Send request to server to load player gear
		[player] remoteExec ["Server_Gear_Load", 2];

		_control = (_display displayCtrl 10359);
		_format = localize "STR_A3PLS_LOADINGREQUEST_RECEIVINGPLAYERGEAR";
		_control ctrlSetStructuredText (parseText _format);

		_waiting = 0;
		while {isNil "A3PL_RetrievedInventory"} do
		{
			uiSleep 1;
			_waiting = _waiting + 2;
			if (_waiting > 10) then
			{
				// send request again after 10sec of no reply
				[player] remoteExec ["Server_Gear_Load", 2];
				_waiting = 0;
			};
		};

		player setVariable ["Zipped",false,true];
		player setVariable ["picking",false,true];
		player setVariable ["working",false,true];
		player setVariable ["DoubleTapped",false,true];

		//okay, we are out of the loop, lets set the markers for houses
		_control = (_display displayCtrl 11059);
		_control progressSetPosition 0.4;

		_control = (_display displayCtrl 10360);
		_format = "<t size='2' align='center' color='#B8B8B8'>40%</t>";
		_control ctrlSetStructuredText (parseText _format);

		_control = (_display displayCtrl 10359);
		_format = localize "STR_A3PLS_LOADINGREQUEST_ASSIGNHOUSEAPPARTMENT";
		_control ctrlSetStructuredText (parseText _format);

		// Stats retrieved succesfully
		_control = (_display displayCtrl 11059);
		_control progressSetPosition 0.5;

		_control = (_display displayCtrl 10360);
		_format = "<t size='2' align='center' color='#B8B8B8'>50%</t>";
		_control ctrlSetStructuredText (parseText _format);

		_control = (_display displayCtrl 10359);
		_format = localize "STR_A3PLS_LOADINGREQUEST_PLAYERGEARLOADED";
		_control ctrlSetStructuredText (parseText _format);

		_format = localize "STR_A3PLS_LOADINGREQUEST_INITIALIZINGCURRENTVEHICLES";
		_control ctrlSetStructuredText (parseText _format);

		//Comment next line to disable all client vehicle inits from config (might help in debugging lag etc)
		A3PL_Vehicle_HandleInitU = toArray (format ["%1",A3PL_Vehicle_HandleInitU]);
		A3PL_Vehicle_HandleInitU deleteAt 0;
		A3PL_Vehicle_HandleInitU deleteAt ((count A3PL_Vehicle_HandleInitU) - 1);
		A3PL_Vehicle_HandleInitU = toString A3PL_Vehicle_HandleInitU;
		A3PL_HandleVehicleInit = compileFinal A3PL_Vehicle_HandleInitU;

		// Vehicles loaded
		_control = (_display displayCtrl 11059);
		_control progressSetPosition 0.9;

		_control = (_display displayCtrl 10360);
		_format = "<t size='2' align='center' color='#B8B8B8'>70%</t>";
		_control ctrlSetStructuredText (parseText _format);

		_control = (_display displayCtrl 10359);
		_format = localize "STR_A3PLS_LOADINGREQUEST_VEHICLESINITIALIZEDSUCCESFULLY";
		_control ctrlSetStructuredText (parseText _format);

		_control = (_display displayCtrl 10360);
		_format = "<t size='2' align='center' color='#B8B8B8'>80%</t>";
		_control ctrlSetStructuredText (parseText _format);

		_control = (_display displayCtrl 10359);
		_format = localize "STR_A3PLS_LOADINGREQUEST_MEDICALSYSTEMINITIALIZED";
		_control ctrlSetStructuredText (parseText _format);

		//Once done loading everything lets closeDialog
		_control = (_display displayCtrl 11059);
		_control progressSetPosition 1;

		_control = (_display displayCtrl 10360);
		_format = "<t size='2' align='center' color='#B8B8B8'>100%</t>";
		_control ctrlSetStructuredText (parseText _format);

		_control = (_display displayCtrl 10359);
		_format = localize "STR_A3PLS_LOADINGREQUEST_PLAYERINITIALIZEDSUCCESFULLY";
		_control ctrlSetStructuredText (parseText _format);

		[0] call A3PL_Lib_CloseDialog;

		if((player getVariable["alreadySpawned",false])) then {
			cutText["","BLACK IN"];
			player enableSimulation true;
		} else {
			call A3PL_Player_SpawnMenu;
		};

		player setVariable ["tf_voiceVolume", 1, true];
		call A3PL_Admin_Check;

		player setvariable ["FinishedLoading",true,true];
		showChat false;

		_display displayRemoveEventHandler ["KeyDown", noEscape];
	};
},false,true] call Server_Setup_Compile;
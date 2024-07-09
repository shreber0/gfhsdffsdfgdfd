/*
	ArmA 3 Fishers Life
	Code written by ArmA 3 Fishers Life Development Team
	@Copyright ArmA 3 Fishers Life (https://www.arma3fisherslife.net)
	YOU ARE NOT ALLOWED TO COPY OR DISTRIBUTE THE CONTENT OF THIS FILE WITHOUT AUTHOR AGREEMENT
	More informations : https://www.bistudio.com/community/game-content-usage-rules
*/

["Server_Chopshop_Chop",
{
	private _veh = param [0,objNull];
	private _player = param [1,objNull];
	private _amount = ([_veh] call Server_Chopshop_VehValue) * A3PL_Event_CrimePayout;
	[_player, 'Player_Cash', ((_player getVariable 'Player_Cash') + _amount)] remoteExec ["Server_Core_ChangeVar",2];
	[format["You received $%1 for this vehicle!",_amount], "green"] remoteExec ["A3PL_Player_Notification",_player];
	[_veh] call Server_Chopshop_Storecar;
	[getPlayerUID _player,"chopchoped",[typeOf _veh,(_veh getVariable"owner") select 1]] remoteExec ["Server_Log_New",2];
},true] call Server_Setup_Compile;

["Server_Chopshop_VehValue",
{
	private _vehPrice = [typeOF _veh] call A3PL_Config_GetVehicleMSRP;
	private _amount = if (_vehPrice < 150000) then {_vehPrice * 0.06} else {_vehPrice * 0.03};
	_amount;
},true] call Server_Setup_Compile;

["Server_Chopshop_Storecar",
{
	private _veh = param [0,objNull];
	if (isNull _veh) exitwith {};
	private _var = _veh getVariable ["owner",nil];
	private _isInsured = _veh getVariable ["insurance",false];
	private _id = _var select 1;
	if (!isNil "_var") then {
		if(_isInsured) then {
			private _query = format ["UPDATE objects SET plystorage = '1',impounded='3' WHERE id = '%1'",_id];
			[_query,1] spawn Server_Database_Async;
		} else {
			private _query = format ["DELETE FROM objects WHERE id = '%1'",_id];
			[_query,1] spawn Server_Database_Async;
		};
	};
	[_veh] call Server_Vehicle_Despawn;
},true] call Server_Setup_Compile;
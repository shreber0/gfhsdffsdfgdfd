/*
	ArmA 3 Fishers Life
	Code written by ArmA 3 Fishers Life Development Team
	@Copyright ArmA 3 Fishers Life (https://www.arma3fisherslife.net)
	YOU ARE NOT ALLOWED TO COPY OR DISTRIBUTE THE CONTENT OF THIS FILE WITHOUT AUTHOR AGREEMENT
	More informations : https://www.bistudio.com/community/game-content-usage-rules
*/

["Server_Gang_Load",
{
	private _player = param [0,objNull];
	private _req = format["SELECT id, owner, name, members, bank, maxmembers FROM gangs WHERE active='1' AND members LIKE '%2%1%2'",getPlayerUID _player,'%'];
	private _gang = [_req, 2] call Server_Database_Async;
	if(count(_gang) > 0) then {
		_gang = [_gang select 0, _gang select 1, _gang select 2, [_gang select 3] call Server_Database_ToArray, _gang select 4, _gang select 5];
		[_gang] remoteExec ["A3PL_Gang_SetData",_player];
	};
},true] call Server_Setup_Compile;

["Server_Gang_Create",
{
	params [
		["_owner",objNull,[objNull]],
		["_gangName","",[""]]
	];
	private _uid = getPlayerUID _owner;
	private _group = group _owner;
	private _gangName = [_gangName] call Server_Database_EsapeString;
	private _query = format ["SELECT id FROM gangs WHERE name='%1' AND active='1'",_gangName];
	private _queryResult = [_query,2] call Server_Database_Async;

	if (!(count _queryResult isEqualTo 0)) exitWith {[format[localize"STR_SERVER_GANG_GROUPALREADYEXIST",_gangName], "red"] remoteExec ["A3PL_Player_Notification",_owner];};

	private _gangMembers = [_uid];
	private _query = format ["INSERT INTO gangs(owner, name, members) VALUES('%1','%2','%3')",_uid,_gangName,_gangMembers];
	[_query,1] call Server_Database_Async;

	sleep 1;

	[_owner] call Server_Gang_Load;
	[_group] remoteExecCall ["A3PL_Gang_Created",_owner];
},true] call Server_Setup_Compile;

["Server_Gang_SaveMembers",
{
	private _group = param [0,grpNull];
	private _gang = _group getVariable ["gang_data",nil];
	if(isNil '_gang') exitWith {};
	private _groupID = _gang select 0;
	private _members = _gang select 3;
	[format ["UPDATE gangs SET members='%1' WHERE id='%2'",_members,_groupID], 1] call Server_Database_Async;
},true] call Server_Setup_Compile;

["Server_Gang_SaveBank",
{
	private _group = param [0,grpNull];
	private _gang = _group getVariable ["gang_data",nil];
	if(isNil '_gang') exitWith {};
	private _groupID = _gang select 0;
	private _bank = _gang select 4;
	[format ["UPDATE gangs SET bank='%1' WHERE id='%2'",_bank,_groupID], 1] call Server_Database_Async;
},true] call Server_Setup_Compile;

["Server_Gang_SaveMaxMembers",
{
	private _group = param [0,grpNull];
	private _gang = _group getVariable ["gang_data",nil];
	if(isNil '_gang') exitWith {};
	private _groupID = _gang select 0;
	private _maxMembers = _gang select 5;
	[format ["UPDATE gangs SET maxmembers='%1' WHERE id='%2'",_maxMembers,_groupID], 1] call Server_Database_Async;
},true] call Server_Setup_Compile;

["Server_Gang_DeleteGang",
{
	private _group = param [0,grpNull];
	private _player = param[1,objNull];
	private _gang = _group getVariable["gang_data",nil];
	if(isNil '_gang') exitWith {};
	private _groupID = _gang select 0;
	deleteGroup _group;
	[format["DELETE FROM gangs WHERE id = '%1'",_groupID], 1] call Server_Database_Async;
	["You disbanded your gang, relog for this to take effect", "green"] remoteExec ["A3PL_Player_Notification",_player];
},true] call Server_Setup_Compile;

["Server_Gang_SetLead",
{
	private _group = param [0,grpNull];
	private _gang = _group getVariable ["gang_data",nil];
	if(isNil '_gang') exitWith {};
	private _groupID = _gang select 0;
	private _owner = _gang select 1;
	[format ["UPDATE gangs SET owner='%1' WHERE id='%2'",_owner,_groupID], 1] call Server_Database_Async;
	private _owner = [_owner] call A3PL_Lib_UIDToObject;
	[format[localize"STR_SERVER_GANG_SETLEADER"], "green"] remoteExec ["A3PL_Player_Notification",_owner];
},true] call Server_Setup_Compile;

["Server_Gang_UpdateGangBalance",{
	private _gangID = param [0,objNull];
	private _amount = param [1,0];
	private _gangObj = grpNull;

	{
			private _gang = _x getVariable ["gang_data",nil];
			if(!isNil '_gang') then {
				private _groupID = _gang select 0;
				if(_groupID isEqualTo _gangID) exitWith {
					_prevBal = _gang select 4;
					_gang set[4,(_prevBal + _amount)];
					_gangObj = _x;
					_x setVariable["gang_data",_gang,true];
				};
			};			
	} forEach allGroups;

	[_gangObj] spawn Server_Gang_SaveBank;

},true] call Server_Setup_Compile;

["Server_Gang_NotifyPurchase",{
	private _gangID = param [0,0];
	private _amount = param [1,0];
	private _type = param [2,"purchased"];
	private _group = grpNull;

	{
			private _gang = _x getVariable ["gang_data",nil];
			if(!isNil '_gang') then {
				private _groupID = _gang select 0;
				if(_groupID isEqualTo _gangID) exitWith {
					_group = _x;
				};
			};
	} forEach allGroups;

	[format["Someone %1 goods from a store you are recieving protection money from, your gang has made $%2 from this sale!",_type,_amount],"green"] remoteExec ["A3PL_Player_Notification",_group];
}] call Server_Setup_Compile;

["Server_Gang_RewardFactions",{
	private _faction = param [0,"fisd"];
	private _amount = 800;
	{
		[_x, 'Player_Bank', ((_x getVariable 'Player_Bash') + _amount)] remoteExec ["Server_Core_ChangeVar",2];
		[format["Your faction has captured a gang hideout, you have been rewarded $%1 for good performance!",_amount],"green"] remoteExec ["A3PL_Player_Notification",_x];
	} foreach ([_faction] call A3PL_Lib_FactionPlayers);
},true] call Server_Setup_Compile;

["Server_Gang_ManageSetup",
{
	private _id = param [0,-1];
	private _player = param [1,objNull];
	private _query = [format ["SELECT bank, members FROM gangs WHERE id='%1'",_id], 2] call Server_Database_Async;
	if(count(_query) isEqualTo 0) exitWith {};
	private _money = _query select 0;
	private _members = [_query select 1] call Server_Database_ToArray;
	private _compileMembers = [];
	{
		private _name = ([format ["SELECT name FROM players WHERE uid='%1'",_x], 2] call Server_Database_Async) select 0;
		_compileMembers pushback ([_name, _x]);
	} foreach _members;
	[_money,_compileMembers] remoteExec ["A3PL_iPhoneX_gangMngmtReceived",(owner _player)];
},true] call Server_Setup_Compile;
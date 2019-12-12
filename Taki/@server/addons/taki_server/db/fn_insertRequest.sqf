#include "\life_server\script_macros.hpp"

//-- Check And parse input params
if !(params [
    ["_uid","",[""]],
    ["_name","",""],
    ["_money",-1,[0]],
    ["_bank",-1,[0]],
    ["_returnToSender",objNull,[objNull]]
])exitWith{};

//Checks	
if ((_uid isEqualTo "") || (_name isEqualTo "")) exitWith {["Bad UID or name",true,"slow"] call AR_fnc_notificationSystem;};
if (isNull _returnToSender) exitWith {["ReturnToSender is Null!",true,"slow"] call AR_fnc_notificationSystem;};

//-- Timestamp for logging
private _tickTime = diag_tickTime;

//-- Query Players
private _queryResult = [format ["SELECT pid, name FROM players WHERE pid='%1'",_uid],2] call AR_fnc_asyncCall;

//-- Query skills
private _querySkillsResult = [format["SELECT steamID, currentSkills FROM skills WHERE SteamID='%1'",_pid],2] call AR_fnc_asyncCall;

//-- Logging
if (EXTDB_SETTING(getNumber,"DebugMode") isEqualTo 1) then {
    diag_log "------------- Insert Query Request -------------";
    diag_log format ["QUERY: %1",_query];
    diag_log format ["Time to complete: %1 (in seconds)",(diag_tickTime - _tickTime)];
    diag_log format ["Result: %1",_queryResult];
    diag_log "------------------------------------------------";
};

//-- Check Player Query
if (_queryResult isEqualType "") exitWith {[] remoteExecCall ["AR_fnc_dataQuery",(owner _returnToSender)];};
if !(count _queryResult isEqualTo 0) exitWith {[] remoteExecCall ["AR_fnc_dataQuery",(owner _returnToSender)];};

//-- Check skills Query
if ((typeName _querySkillsResult) != "ARRAY") exitWith {[] remoteExecCall ["AR_fnc_dataQuery",(owner _returnToSender)];};
if !(count _querySkillsResult isEqualTo 0) exitWith {[] remoteExecCall ["AR_fnc_dataQuery",(owner _returnToSender)];};

//-- Convet Data
private _name = [_name] call AR_fnc_mresString;
private _alias = [[_name]] call AR_fnc_mresArray;
private _money = [_money] call AR_fnc_numberSafe;
private _bank = [_bank] call AR_fnc_numberSafe;
 
//-- Insert Players
_query = format ["INSERT INTO players (pid, name, cash, bankacc, aliases, cop_licenses, med_licenses, civ_licenses, civ_gear, cop_gear, med_gear) VALUES('%1', '%2', '%3', '%4', '%5','""[]""','""[]""','""[]""','""[[],[]]""','""[[],[]]""','""[[],[]]""')",
    _uid,
    _name,
    _money,
    _bank,
    _alias
];
[_query,1] call AR_fnc_asyncCall;

//-- Insert skills
[format ["INSERT INTO skills (SteamID, currentSkills) VALUES('%1','""[]""')",_uid],1] call AR_fnc_asyncCall;

//-- vehicle plates
private _plateGen = round(random [1000000, 5000000, 9999999]); 
private _plate = [_plateGen,7] call BIS_fnc_numberText;
private _vehicle = selectRandom AR_ShitCars;
[_uid,"civ","Car",_vehicle,[[1,1,1,1],[1,1,1,1],0.5],_plate,0] call AR_fnc_insertVehicle;

//Send back to client
[] remoteExecCall ["AR_fnc_dataQuery",(owner _returnToSender)];
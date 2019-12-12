#include "..\..\script_macros.hpp"
/*
    File: fn_updateRequest.sqf
    Author: Tonic

    Description:
    Passes ALL player information to the server to save player data to the database.
*/
private _packet = [getPlayerUID player,(profileName),playerSide,CASH,BANK];
private _array = [];
private _alive = alive player;
private _position = getPosATL player;
private _flag = switch (playerSide) do {case west: {"cop"}; case civilian: {"civ"}; case independent: {"med"};};

{
    private _varName = LICENSE_VARNAME(configName _x,_flag);
    _array pushBack [_varName,LICENSE_VALUE(configName _x,_flag)];
} forEach (format ["getText(_x >> 'side') isEqualTo '%1'",_flag] configClasses (missionConfigFile >> "Licenses"));

_packet pushBack _array;

[] call AR_fnc_saveGear;
_packet pushBack life_gear;
 
_packet pushBack [life_hunger,life_thirst];

switch (playerSide) do {
    case civilian: {
        _packet pushBack life_is_arrested;
        _packet pushBack _alive;
        _packet pushBack _position;
    };
    default {
        _packet pushBack false;
        _packet pushBack false;
        _packet pushBack [];
    };
};

// 10 (skills)
private _skills = missionNamespace getVariable ['ER_Skills',[]];
_packet pushBack (_skills apply {[_x#0,missionNamespace getVariable [_x#0,false]]});  

if (life_HC_isActive) then {
    _packet remoteExecCall ["HC_fnc_updateRequest",HC_Life];
} else {
    _packet remoteExecCall ["AR_fnc_updateRequestServer",RSERV];
};

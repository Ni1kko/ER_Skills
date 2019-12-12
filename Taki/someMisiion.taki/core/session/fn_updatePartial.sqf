#include "..\..\script_macros.hpp"
/*
    File: fn_updatePartial.sqf
    Author: Bryan "Tonic" Boardwine

    Description:
    Sends specific information to the server to update on the player,
    meant to keep the network traffic down with large sums of data flowing
    through remoteExec
*/
params [["_mode",0,[0]],["_combatlog",false,[false]]];

private _packet = [getPlayerUID player,playerSide,nil,_mode];
private _array = [];
private _flag = switch (playerSide) do {case west: {"cop"}; case civilian: {"civ"}; case independent: {"med"};};

switch (_mode) do {
    case 0: {
        _packet set[2,uiNamespace getVariable ["ERP_Cash",0]];
        [] call AR_fnc_hudUpdate;
    };

    case 1: {
        _packet set[2,uiNamespace getVariable ["ERP_Bank",0]];
    };

    case 2: {
        {
            private _varName = LICENSE_VARNAME(configName _x,_flag);
            _array pushBack [_varName,LICENSE_VALUE(configName _x,_flag)];
        } forEach (format ["getText(_x >> 'side') isEqualTo '%1'",_flag] configClasses (missionConfigFile >> "Licenses"));

        _packet set[2,_array];
    };

    case 3: {
        if (!_combatlog) then {
            [] call AR_fnc_saveGear;    
        };
        
        _packet set[2,life_gear];
    };

    case 4: {
        _packet set[2,player getVariable "life_is_alive"];
        _packet set[4,getPosATL player];
    };

    case 5: {
        _packet set[2,life_is_arrested];
    };

    case 6: {
        _packet set[2,uiNamespace getVariable ["ERP_Cash",0]];
        _packet set[4,uiNamespace getVariable ["",0]];
        [] call AR_fnc_hudUpdate;
    };

    case 7: {};//Keychain

    case 802: { //skills
        private _skills = missionNamespace getVariable ['ER_Skills',[]];
        _packet set[2,(_skills apply {
            [_x#0,missionNamespace getVariable [_x#0,false]]
        })];  
    };
};

if (life_HC_isActive) then {
    _packet remoteExecCall ["HC_fnc_updatePartial",HC_Life];
} else {
    _packet remoteExecCall ["AR_fnc_updatePartialServer",RSERV];
};


#include "..\..\script_macros.hpp"
/*
    File: fn_requestReceived.sqf
    Author: Bryan "Tonic" Boardwine

    Description:
    Called by the server saying that we have a response so let's
    sort through the information, validate it and if all valid
    set the client up.
*/
private _count = count _this;
life_session_tries = life_session_tries + 1;
if (life_session_completed) exitWith {}; //Why did this get executed when the client already initialized? Fucking arma...
if (life_session_tries > 3) exitWith {};

//Error handling and junk..
if (isNil "_this") exitWith {[] call AR_fnc_insertPlayerInfo;};
if (_this isEqualType "") exitWith {[] call AR_fnc_insertPlayerInfo;};
if (count _this isEqualTo 0) exitWith {[] call AR_fnc_insertPlayerInfo;};
if ((_this select 0) isEqualTo "Error") exitWith {[] call AR_fnc_insertPlayerInfo;};
if (!(getPlayerUID player isEqualTo (_this select 0))) exitWith {[] call AR_fnc_dataQuery;};

//Lets make sure some vars are not set before hand.. If they are get rid of them, hopefully the engine purges past variables but meh who cares.
if (!isServer && (!isNil "life_adminlevel" || !isNil "life_coplevel" || !isNil "life_donorlevel")) exitWith {
    sleep 0.9;
    failMission "oopsie";
};

//Parse basic player information.
_cash = parseNumber (_this select 2);
_bank = parseNumber (_this select 3);
missionNameSpace setVariable ["ERP_Cash", _cash];
missionNameSpace setVariable ["ERP_Bank", _bank];
uiNamespace setVariable ["ERP_Cash",_cash];
uiNamespace setVariable ["ERP_Bank",_bank];

CONST(life_adminlevel,(_this select 4));
if (MAIN_SETTINGS_TYPE(getNumber,"GameSettings","donor_level") isEqualTo 1) then {
    CONST(life_donorlevel,(_this select 5));
    player setVariable["donorLevel",(_this select 5),true];
} else {
    CONST(life_donorlevel,0);
};

//Loop through licenses
if (count (_this select 6) > 0) then {
    {missionNamespace setVariable [(_x select 0),(_x select 1)];} forEach (_this select 6);
};

//Parse side specific information.
switch (playerSide) do {
    case west: {
        CONST(life_coplevel,(_this select 7));
        CONST(life_copdept,(_this select 11));
        CONST(life_medicLevel,0);
        CONST(life_medicdept,0);
        life_blacklisted = _this select 9;
        if (MAIN_SETTINGS_TYPE(getNumber,"Saving","save_playerStats") isEqualTo 1) then {
            life_hunger = ((_this select 10) select 0);
            life_thirst = ((_this select 10) select 1);
        };
    };

    case civilian: {
        life_is_arrested = _this select 7;
        life_arrest_time = _this select 12;
        CONST(life_coplevel, 0);
        CONST(life_medicLevel, 0);
        CONST(life_copdept,0);
        life_houses = _this select (_count - 4);
        if (MAIN_SETTINGS_TYPE(getNumber,"Saving","save_playerStats") isEqualTo 1) then {
            life_hunger = ((_this select 9) select 0);
            life_thirst = ((_this select 9) select 1);
        };

        //Position
        if (MAIN_SETTINGS_TYPE(getNumber,"Saving","save_civilianPosition") isEqualTo 1) then {
            player setVariable ["life_is_alive",_this select 10,true];
            life_civ_position = _this select 11;
            if (player getVariable "life_is_alive" isEqualTo true) then {
                //if !(count life_civ_position isEqualTo 3) then {diag_log format ["[requestReceived] Bad position received. Data: %1",life_civ_position];life_is_alive =false;};
                //if (life_civ_position distance (getMarkerPos "respawn_civilian") < 300) then {life_is_alive = false;};
                player setVariable ["life_is_alive",false,true];

                _side = switch (playerSide) do {
                    case west: {"Cop"};
                    case independent: {"Medic"};
                    default {"Civilian"};
                };

                private _spawnConfig = missionConfigFile >> "CfgSpawnPoints" >> worldName >> _side;
                if !(isClass _spawnConfig) throw "No config found for given side";

                {
                    private _spawnMarker = getText (_x >> "spawnMarker");
                    _pos = getMarkerPos _spawnMarker; 
                    if ((life_civ_position distance _pos) < 600) exitWith {
                        player setVariable ["life_is_alive",true,true];
                    };
                } forEach ("true" configClasses _spawnConfig);

            };
        };

        {
            _house = nearestObject [(parseSimpleArray format ["%1",(_x select 0)]), "House"];
            life_vehicles pushBack _house;
        } forEach life_houses;

        life_gangData = _this select (_count - 3);
        if !(count life_gangData isEqualTo 0) then {
            [] spawn AR_fnc_initGang;
        };
        [] spawn AR_fnc_initHouses;
    };

    case independent: {
        CONST(life_medicLevel,(_this select 7));
        CONST(life_medicdept,(_this select 10));
        CONST(life_coplevel,0);
        CONST(life_copdept,0);
        if (MAIN_SETTINGS_TYPE(getNumber,"Saving","save_playerStats") isEqualTo 1) then {
            life_hunger = ((_this select 9) select 0);
            life_thirst = ((_this select 9) select 1);
        };
    };
};

//gear
life_gear = _this select 8;
call AR_fnc_loadGear;

//skills
missionNamespace setVariable ['ER_Skills',(_this select (_count - 3))];

//Keys
if (count (_this select (_count - 2)) > 0) then {
    {life_vehicles pushBack _x;} forEach (_this select (_count - 2));
};

//Tickets
missionNamespace setVariable ["AR_PlayerTickets", _this select (_count - 1)];
life_session_completed = true;

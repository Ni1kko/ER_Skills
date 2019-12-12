
private _uid = param[0,"",[""]];
private _side = param[1,sideUnknown,[civilian]];
private _mode = param[3,-1,[0]];

if (_uid isEqualTo "" || _side isEqualTo sideUnknown) exitWith {};
private _query = "";

switch (_mode) do {
    case 0: { //cash
        private _value = param[2,0,[0]];
        _value = [_value] call AR_fnc_numberSafe;
        _query = format ["UPDATE players SET cash='%1' WHERE pid='%2'",_value,_uid];
    };

    case 1: { //bank
        private _value = param[2,0,[0]];
        _value = [_value] call AR_fnc_numberSafe;
        _query = format ["UPDATE players SET bankacc='%1' WHERE pid='%2'",_value,_uid];
    };

    case 2: { //licenses
        private _value = param[2,[],[[]]];
        for "_i" from 0 to count(_value)-1 do {
            private _bool = [(_value select _i) select 1] call AR_fnc_bool;
            _value set[_i,[(_value select _i) select 0,_bool]];
        };
        _value = [_value] call AR_fnc_mresArray;
        switch (_side) do {
            case west: {_query = format ["UPDATE players SET cop_licenses='%1' WHERE pid='%2'",_value,_uid];};
            case civilian: {_query = format ["UPDATE players SET civ_licenses='%1' WHERE pid='%2'",_value,_uid];};
            case independent: {_query = format ["UPDATE players SET med_licenses='%1' WHERE pid='%2'",_value,_uid];};
        };
    };

    case 3: { //gear
        private _value = param[2,[],[[]]];
        _value = [_value] call AR_fnc_mresArray;
        switch (_side) do {
            case west: {_query = format ["UPDATE players SET cop_gear='%1' WHERE pid='%2'",_value,_uid];};
            case civilian: {_query = format ["UPDATE players SET civ_gear='%1' WHERE pid='%2'",_value,_uid];};
            case independent: {_query = format ["UPDATE players SET med_gear='%1' WHERE pid='%2'",_value,_uid];};
        };
    };

    case 4: { //Alive & pos
        private _value = param[2,false,[true]];
        _value = [_value] call AR_fnc_bool;
        private _value2 = param[4,[],[[]]];
        _value2 = if (count _value2 isEqualTo 3) then {_value2} else {[0,0,0]};
        _value2 = [_value2] call AR_fnc_mresArray;
        _query = format ["UPDATE players SET civ_alive='%1', civ_position='%2' WHERE pid='%3'",_value,_value2,_uid];
    };

    case 5: { //Arrseted
        private _value = param[2,false,[true]];
        _value = [_value] call AR_fnc_bool;
        _query = format ["UPDATE players SET arrested='%1' WHERE pid='%2'",_value,_uid];
    };

    case 6: { //Bank & cash
        private _value1 = param[2,0,[0]];
        private _value2 = param[4,0,[0]];
        _value1 = [_value1] call AR_fnc_numberSafe;
        _value2 = [_value2] call AR_fnc_numberSafe;
        _query = format ["UPDATE players SET cash='%1', bankacc='%2' WHERE pid='%3'",_value1,_value2,_uid];
    };

    case 7: { //KeyChain
        private _array = param[2,[],[[]]];
        [_uid,_side,_array,0] call TON_fnc_keyManagement;
    };

    case 802: { //skills
        private _skills = param[2,[],[[]]]; 
        _query = format ["UPDATE skills SET currentSkills='%1' WHERE SteamID='%2'",([_skills] call AR_fnc_mresArray),_uid];
    };
};

if (_query isEqualTo "") exitWith {};

[_query,1] call AR_fnc_asyncCall;

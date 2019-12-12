if!(params[
    ['_uid','',['']],
    ['_name','',['']],
    ['_side',sideUnknown,[civilian]],
    ['_cash',0,[0]],
    ['_bank',5000,[0]],
    ['_licenses',[],[[]]],
    ['_gear',[],[[]]],
    ['_stats',[100,100],[[]]],
    ['_arrested',false,[true]],
    ['_alive',false,[true]], 
    ['_position',[],[[]]],
    ['_skills',[],[[]]]
])exitWith{
    diag_log "bad params passed! <UpdateRequest Failed>";
    diag_log str _this;
};

//checks
if ((_uid isEqualTo "") || (_name isEqualTo "")) exitWith {}; 
if (_side != civilian) then {_position =[]};//Check player side is civ for logging pos 
  
// convert every lic bool to tiny int	
for "_i" from 0 to count(_licenses)-1 do {
    private _bool = [(_licenses select _i) select 1] call AR_fnc_bool;
    _licenses set[_i,[(_licenses select _i) select 0,_bool]];
};

// convert data for sql
_name = [_name] call AR_fnc_mresString;  
_cash = [_cash] call AR_fnc_numberSafe;
_bank = [_bank] call AR_fnc_numberSafe; 
_licenses = [_licenses] call AR_fnc_mresArray;
_gear = [_gear] call AR_fnc_mresArray;
_stats = [_stats] call AR_fnc_mresArray;
_arrested = [_arrested] call AR_fnc_bool;
_alive = [_alive] call AR_fnc_bool;
_position = [_position] call AR_fnc_mresArray; 
 
//Update players
_nul = [(switch (_side) do {
    case west: {format ["UPDATE players SET name='%1', cash='%2', bankacc='%3', cop_gear='%4', cop_licenses='%5', cop_stats='%6' WHERE pid='%7'",_name,_cash,_bank,_gear,_licenses,_stats,_uid]};
    case civilian: {format ["UPDATE players SET name='%1', cash='%2', bankacc='%3', civ_licenses='%4', civ_gear='%5', arrested='%6', civ_stats='%7', civ_alive='%8', civ_position='%9' WHERE pid='%10'",_name,_cash,_bank,_licenses,_gear,_arrested,_stats,_alive,_position,_uid]};
    case independent: format ["UPDATE players SET name='%1', cash='%2', bankacc='%3', med_licenses='%4', med_gear='%5', med_stats='%6' WHERE pid='%7'",_name,_cash,_bank,_licenses,_gear,_stats,_uid]};
}),1] call AR_fnc_asyncCall;

//Update skills
_nul = [format ["UPDATE skills SET currentSkills='%1' WHERE SteamID='%2'",([_skills] call AR_fnc_mresArray),_uid],1] call AR_fnc_asyncCall;
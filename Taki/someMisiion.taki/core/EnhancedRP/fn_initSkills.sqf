if !(isClass (missionConfigFile >> "ER_Skills")) exitWith {diag_log "ER_Skills: System Config Is missing!!!"};
if ((uiNamespace getVariable ['ER_Skills_Init',0]) > 0)exitWith {diag_log "ER_Skills: System Already Loaded!!!"}; 
if (isNil {missionNamespace getVariable 'ER_Skills'}) exitWith {diag_log "ER_Skills: Failed To Load DB Data!!!"}; 
uiNamespace setVariable ['ER_Skills_Init',time];
private _isOk = true;
private _classError = '';

//Get skills From DB 
private _playerSkills = missionNamespace getVariable ['ER_Skills',[]];

//Get skills From Config
private _Skills = [missionConfigFile >> 'ER_Skills','skills',[]] call BIS_fnc_returnConfigEntry;

//TEMP
	AR_fnc_testSkill = {
		systemChat 'Test Skill (1) Loaded!'
	};
	AR_fnc_testSkill2 = {
		systemChat 'Test Skill (2) Loaded!'
	};  
//END TEMP 

//Check Each Skill Has a Class
{ 
	_class = _x;
	if !(isClass (missionConfigFile >> "ER_Skills" >> _class))exitWith{_isOk = false};

	//New skill Added
	if !(_class in (_playerSkills apply {_x#0}))then{ 
		private _newSkill = [_class,false];
		_playerSkills pushBack _newSkill;  
	};  
}forEach _Skills;

//Check if there was an error
if !_isOk exitWith {diag_log format ["ER_Skills: Skill `%1` Is missing!!!",_class]};

//Load Skills
{ 
	missionNamespace setVariable _x;//set skill var
	private _scriptName = [missionConfigFile >> 'ER_Skills' >> (_x#0), 'skillScriptName',''] call BIS_fnc_returnConfigEntry;//get skill init function name
	private _scriptCode = missionNamespace getVariable [_scriptName,{}];//get skill init function
	uiSleep 0.2; //prespone exceution for a few mil seconds
	[] spawn _scriptCode;//load script init function 
}forEach _playerSkills;

//Update DB 
if (_classError isEqualTo 'NEW-CLASS')then{
	missionNamespace setVariable ['ER_Skills',_playerSkills];
	[802] call AR_fnc_updatePartial; 
};
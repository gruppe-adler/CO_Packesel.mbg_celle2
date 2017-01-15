// F3 - Caching Script Tracker
// Credits: Please see the F3 online manual (http://www.ferstaberinde.com/f3/en/)
// ====================================================================================

// DECLARE VARIABLES AND FUNCTIONS
private ["_range","_groups","_debug"];

_range = _this select 0;
_debug = if (f_param_debugMode == 1) then [{true},{false}];

// ====================================================================================

// BEGIN THE TRACKING LOOP
[{
        params ["_args", "_handle"];
        _args params ["_range", "_debug"];

        if (_debug) then{diag_log format ["f_fnc_cache DBG: Tracking %1 groups",count _groups]};
        _groups = allGroups;
        {
                if (isnull _x) then {
                        _groups = _groups - [_x];

                        if (_debug) then{diag_log format ["f_fnc_cache DBG: Group is null, deleting: %1",_x,count _groups]};

                } else {
                        _exclude = _x getvariable ["f_cacheExcl",false];
                        _cached = _x getvariable ["f_cached", false];

                        if (!_exclude) then {
                                if (_cached) then {

                                        if ([leader _x, _range] call f_fnc_nearPlayer) then {

                                                if (_debug) then {diag_log format ["f_fnc_cache DBG: Decaching: %1",_x]};

                                                _x setvariable ["f_cached", false];
                                                _x spawn f_fnc_gUncache;

                                        };
                                } else {
                                        if !([leader _x, _range * 1.1] call f_fnc_nearPlayer) then {

                                                if (_debug) then {diag_log format ["f_fnc_cache DBG: Caching: %1",_x]};

                                                _x setvariable ["f_cached", true];
                                                [_x] spawn f_fnc_gCache;
                                        };
                                };
                        } else {
                          if (_debug) then {diag_log format ["f_fnc_cache DBG: Group is excluded: %1",_x]};
                        };
                };
        } foreach _groups;

        if (!f_var_cacheRun) exitWith {
          diag_log "f_fnc_cache DBG: Tracking terminated. Uncaching all groups.";
          {
                  if (_x getvariable ["f_cached", false]) then {
                          _x spawn f_fnc_gUncache;
                          _x setvariable ["f_cached", false];
                  };
          } forEach allGroups;
          [_handle] call CBA_fnc_removePerFrameHandler;
        };
}, f_var_cacheSleep, [_range,_debug]] call CBA_fnc_addPerFrameHandler;

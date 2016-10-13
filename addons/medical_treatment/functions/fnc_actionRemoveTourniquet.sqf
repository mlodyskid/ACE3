/*
 * Author: Glowbal
 * Action for removing the tourniquet on specified selection
 *
 * Arguments:
 * 0: The medic <OBJECT>
 * 1: The patient <OBJECT>
 * 2: Body part <STRING>
 *
 * Return Value:
 * None
 *
 * Public: Yes
 */

#include "script_component.hpp"

params ["_caller", "_target", "_bodyPart"];
TRACE_3("params",_caller,_target,_bodyPart);

// grab the required data
private _partIndex = ALL_BODY_PARTS find toLower _bodyPart;
private _tourniquets = _target getVariable [QEGVAR(medical,tourniquets), [0,0,0,0,0,0]];

// Check if there is a tourniquet on this bodypart
if ((_tourniquets select _partIndex) == 0) exitWith {
    [QEGVAR(common,displayTextStructured), [ELSTRING(medical,noTourniquetOnBodyPart), 1.5, _caller], [_caller]] call CBA_fnc_targetEvent;
};

// Removing the tourniquet
_tourniquets set [_partIndex, 0];
_target setVariable [QEGVAR(medical,tourniquets), _tourniquets, true];

// Adding the tourniquet item to the caller
[_caller, "ACE_tourniquet", true] call CBA_fnc_addItem;

//Handle all injected medications now that blood is flowing:
private _delayedMedications = _target getVariable [QGVAR(occludedMedications), []];
private _updatedArray = false;
TRACE_2("meds",_partIndex,_delayedMedications);
{
    _x params ["", "", "_medPartNum"];
    if (_partIndex == _medPartNum) then {
        TRACE_1("delayed medication call after tourniquet removeal",_x);
        [QGVAR(treatmentAdvanced_medicationLocal), _x, [_target]] call CBA_fnc_targetEvent;
        _delayedMedications set [_forEachIndex, -1];
        _updatedArray = true;
    };
} forEach _delayedMedications;

if (_updatedArray) then {
    _delayedMedications = _delayedMedications - [-1];
    _target setVariable [QGVAR(occludedMedications), _delayedMedications, true];
};

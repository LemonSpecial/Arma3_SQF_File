/*
    File: shuabing.sqf
    Author: LemonSpecial
    GitHub: https://github.com/LemonSpecial
    Version: Alpha-0.2 
    License: MIT License - See full license text below or in LICENSE file.
    
    功能：刷新在随机出生点、自动前往目标位置、随机生成步兵和载具
    使用：在项目的根目录下，触发器的初始化或任何根目录的文件可用   [] execVM "shuabing.sqf";

    ------------------------------------------------------------------------------------
    MIT License

    Copyright (c) 2025 LemonSpecial

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
 */



// 定义独立阵营 与 步兵类型 与 载具类型
 _side = INDEPENDENT;
 _infantryTypes = [
    "I_Soldier_F",       // 普通步兵
    "I_Soldier_AR_F",    // 自动步枪手
    "I_Soldier_M_F",     // 机枪手
    "I_Soldier_GL_F",    // 榴弹兵
    "I_Soldier_AA_F",    // 防空兵
    "I_Soldier_AT_F",    // 反坦克兵
    "I_Soldier_LAT_F"    // 轻型反坦克兵
];
 _vehicleTypes = [
    "I_MRAP_03_hmg_F"         // MRAP（带重机枪）
];



// ============================================================================
// 定义出生点标记前缀和出生点数量（例如变量名为 spawn_point_1, spawn_point_2, ...）
// ============================================================================
 _spawnPointPrefix = "spawn_point_";
 _numberOfSpawnPoints = 9;



// ======================
// 定义总批次  每批次最大步兵与最大载具数量   前往目标
// ======================
 _totalBatches = 5;
 maxinfantry = 10;
 maxvehicles = 1;
 _target = "Target"; 



// ==========================
// 定义AI基础熟练度(0.0f~1.0f)
// ==========================
 _aiSkill = 0.2;



FSetAISkill ={
    params ["_unit"];
    //===================================================================================
    // 从上到下依次是：射击精度、瞄准速度、指挥能力、勇气、耐力、常规、换弹、视野、反应、瞄准稳定
    //===================================================================================
    _unit setSkill ["aimingAccuracy", _aiSkill];    
    _unit setSkill ["aimingSpeed", _aiSkill];
    _unit setSkill ["commanding", _aiSkill];
    _unit setSkill ["courage", _aiSkill];
    _unit setSkill ["endurance", _aiSkill];
    _unit setSkill ["general", _aiSkill];
    _unit setSkill ["reloadSpeed", _aiSkill];
    _unit setSkill ["spotDistance", _aiSkill];
    _unit setSkill ["spotTime", _aiSkill];
    _unit setSkill ["aimingShake", _aiSkill];
};



// ======================================
// Debug （默认输出开启，如果不需要则false）
// ======================================
DEBUG = true;



if (DEBUG) then {
    debug_infantrycount = 0;
    debug_vehiclescount = 0;
};
for "_batch" from 1 to _totalBatches do {
    for "_i" from 1 to maxinfantry do {
         _randomSpawnIndex = floor random _numberOfSpawnPoints;
         _spawnPointName = _spawnPointPrefix + str(_randomSpawnIndex);
         _spawnPos = getMarkerPos _spawnPointName;
        if (!(_spawnPos isEqualTo [0, 0, 0])) then {
             _infantryType = selectRandom _infantryTypes;
             _group = createGroup _side;
             _unit = _group createUnit [_infantryType, _spawnPos, [], 0, "NONE"];
            [_unit] call FSetAISkill;
            _unit setBehaviour "COMBAT";
            _unit setCombatMode "RED";
            _unit doMove getMarkerPos _target;
            if (DEBUG) then {
                debug_infantrycount = debug_infantrycount + 1;
            };
        }
    };
    for "_i" from 1 to maxvehicles do {
         _randomSpawnIndex = floor random _numberOfSpawnPoints;
         _spawnPointName = _spawnPointPrefix + str(_randomSpawnIndex);
         _spawnPos = getMarkerPos _spawnPointName;
        if (!(_spawnPos isEqualTo [0, 0, 0])) then {
             _vehicleType = selectRandom _vehicleTypes;
             _vehicleSpawnPos = [_spawnPos # 0, _spawnPos # 1, 0];
             _vehicle = _vehicleType createVehicle _vehicleSpawnPos;
            _vehicle setDir (random 360);
            createVehicleCrew _vehicle;
            {
                [_x] call FSetAISkill;
                _x setBehaviour "COMBAT";
                _x setCombatMode "RED";
            } forEach crew _vehicle;
            _vehicle doMove getMarkerPos _target;
            if (DEBUG) then {
                debug_vehiclescount = debug_vehiclescount + 1;
            };
        }
    };
    if (DEBUG) then {
        hint format["第 %1 批完成：生成 %2 步兵和 %3 载具", _batch, debug_infantrycount, debug_vehiclescount];
        debug_infantrycount = 0;
        debug_vehiclescount = 0;
    };
    // ===================
    // 批次间隔（单位：秒）
    // ===================
    sleep 30;
};

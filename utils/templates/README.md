# KPS
[![Build Status](https://travis-ci.org/kirk24788/KPS.svg?branch=master)](https://travis-ci.org/kirk24788/KPS)


_JUST ANOTHER PLUA ADDON FOR WORLD OF WARCRAFT_

This addon in combination with enabled protected LUA will help you get the most
out of your WoW experience. This addon is based on JPS with a lot of refactoring
to clean up the codebase which has grown a lot in the last 4 years.

The main goal is to have a clean and fast codebase to allow further development.

*Huge thanks to htordeux and pcmd for their contributions to KPS!*

*Thanks to jp-ganis, htordeux, nishikazuhiro, hax mcgee, pcmd
and many more for all their contributions to the original JPS!*

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

Copyright (C) 2015 Mario Mancino


## Commands

 * `/kps` - Show enabled status.
 * `/kps enable/disable/toggle` - Enable/Disable the addon.
 * `/kps cooldowns/cds` - Toggle use of cooldowns.
 * `/kps pew` - Spammable macro to do your best moves, if for some reason you don't want it fully automated.
 * `/kps interrupt/int` - Toggle interrupting.
 * `/kps multitarget/multi/aoe` - Toggle manual MultiTarget mode.
 * `/kps defensive/def` - Toggle use of defensive cooldowns.
 * `/kps help` - Show this help text.




## Builds and Classes

All DPS Specs have at least one rotation automatically generated from SimCraft - those might not be fully functional and aren't tested.

%(rotations)s

##  Development
If you want to help developing this AddOn, you are welcome, but there a few rules to make sure KPS is maintable.

### Prerequisites
If you don't have it yet please install Brew (http://brew.sh).
You also have to install the Command Line Utils to for `make` and of course you need to have LUA installed (also available via brew!).

If you don't have a Mac, you somehow have to provide these tools:

* python (at least 2.6)
* make

### Pull Requests
1. [Fork it!](https://github.com/kirk24788/KPS/fork)

2. Create a branch for your changes

        $ git checkout -b my_new_feature

3. Make any changes and run a `make test` in your KPS directory - only create the pull request if *ALL* tests
are OK!

4. Run `make readme` to update the current issues in the `README.md`.

4. Commit and Push your changes

        $ git commit -am "My new feature"
        $ git push origin my_new_feature

5. Open a [Pull Request](http://github.com/kirk24788/KPS/pulls)

### Code Guidelines
* Use 4 spaces for indentation - *NO TABS!*
* All variables must be _lower_ camel case
* All classes must be _upper_ camel case

### Project Structure
* `core`: Core functionality, please think twice before adding anything here, this should only contain backend stuff which isn't used in rotations.
* `gui`: All GUI-related stuff should be consolidated here.
* `libs`: External Libraries.
* `media`: Custom image and sound files.
* `modules`: Wrapper modules for blizzard functions which are used in the rotations.
* `rotations`: Class spells and rotation files. Spell Files are generated by `printClassSpells.py` don't edit these manually, your changes will be overwritten.
* `simc`: SimCraft rotation files used for rotation conversions.
* `utils`: Utility scripts for generating various files for this addon

### Automatic Code Generation
Some files are created automatically by the `makefile`. Please restrain from editing these files, as your changes will not be permanent.
Instead edit the apropriate files in the `utils` directory.

* `kps.toc`: Generated from `_test.lua` - if you need to change the order or add files, please add an additional `require(...)` statement there.
* `README.me`: Generated from `utils/generateREADME.py` - if you want to change the documentation, see the template at `utils/templates/README.md`.
* `modules/spell/spells.lua`: Generated by `utils/printGlobalSpells.py`
* `rotations/<classname>.lua`: Generated by `utils/printClassSpells.py` - if you need additional spells or functions, please add them there.
* `rotations/<classname>_<specname>.lua`: Generated by `utils/convertSimC.py` if not explicitly commented out in the `makefile` - if you want to write a custom rotation comment out the line in the makefile to prevent your rotation from being overwritten.

### Rotation Modules
%(modules)s

### Rotations
It is pretty simple to write your own rotation. The easiest way is to extend one of the rotation files in `rotations/CLASSNAME_SPECNAME.lua`.
But you may be better of if you create a seperate file or even another addon.

#### Rotation File Skeleton
No matter which way you choose, you should always start your
rotation with.
```
local spells = kps.spells.classname
local env = kps.env.classname
```

Replace `classname` with whatever class you're writing this rotation for. While not needed, this local definitions help you to write easier to read rotations.

Next will be your rotation(s), they can be registered with `kps.rotations.register(...)`. This function takes 4-5 parameters:

1. Classname (Uppercase String, e.g.: "SHAMAN")
1. Specname (Uppercase String, e.g.: "ENHANCEMENT")
1. Rotation Table
1. Description of the Rotation (will be shown in Dropdown if multiple Rotations exist)
1. _Optional:_ Required Talents for this Spec

```
kps.rotations.register("SHAMAN","ENHANCEMENT",
{
...
}
,"shaman enhancement", {...})
```

#### Rotation Table
This is your actual rotation, every element is evaluated until a tuple containing the spell object and a target are returned. The elements can be one of:

 * Simple Cast
 * Cast Sequence
 * Function
 * Macro
 * Nested Rotation Table

##### Simple Cast
_Syntax:_
```
  {SPELL, CONDITION, TARGET}
```

*SPELL*
The first element is mandatory, and must be a spell object - e.g.: `spells.lavaLash` - this is the reason why we needed the `local spells = kps.spells.classname` in the rotation skeleton, else we would also have to write `kps.spells.shaman.lavaLash`.

*CONDITION*
The second element is a little more complex, usually this is a string, like `'player.soulShards >= 3'`. For a detailed description
on the availabe modules check the _Rotation Modules_ section, but you can also call Lua functions within the condition.

But you can also supply a function here (_the function itself, not a call to a function!_). This function must not take any parameters
and should return a boolean value, like:
```
local function myCondition()
    return kps.env.player.soulShards >= 3
end

kps.rotations.register(
...
  {spells.chaosBolt, myCondition , "target"},
...
)
```
This would have the same effect as the string, but this should be avoided in most cases. The string will be compiled and doesn't need
to be parsed every time, so there is no speed benefit here to gain.

And finally you can also omit this parameter completely, if you want this spell to be case always (but you have to omit the target also!):
```
  {spells.incinerate},
```

*TARGET*
Just like the _CONDITION_, the _TARGET_ can either be a WoW Target String (e.g. `'target'` or `'focus'`).

But it can also be a function. This is pretty important if you have a healing rotation, e.g.:
```
    {spells.flashHeal, 'heal.defaultTank.hp < 0.4', kps.heal.defaultTank},
```


##### Cast Sequence
_Syntax:_
```
  {{SPELL, SPELL, SPELL,...}, CONDITION, TARGET}
```
This is basically the same as a simple cast, but instead of a single spell you supply a table of multiple spells.
If the condition is met, each spell will be cast in the give order at the given target.

##### Function
If you want, you can also supply a function instead of a table, this function must return a spell object and a target string:
```
local function mySpellFunction()
    if kps.env.player.soulShards >= 3 then
        return spells.chaosBolt, "target"
    end
end

kps.rotations.register(
...
  mySpellFunction,
...
)
```

While this might not be as useful on first sight - after all it could be written much easier, it can be used to trigger complex conditions like:
```
local burningRushLastMovement = 0
local function deactivateBurningRush()
    local player = kps.env.player
    if player.isMoving or not player.hasBuff(kps.spells.warlock.burningRush) then
        burningRushLastMovement = GetTime()
    else
        local nonMovingDuration = GetTime() - burningRushLastMovement
        if nonMovingDuration >= 1 then
            kps.runMacro("/cancelaura " .. kps.spells.warlock.burningRush)
        end
    end
end

kps.rotations.register(
...
  deactivateBurningRush,
...
)
```

##### Macro
_Syntax:_
```
  {{"macro"}, CONDITION, MACRO_TEXT}
```
You can also run simple macro commands. You only have to set the first element to `{"macro"}` (all lowercase!).

The condition is the same as in _Simple Spell_ or _Cast Sequence_.

The *MACRO_TEXT* is a string containing your command, e.g.:`'/use Healthstone'`.

##### Nested Rotation Table
_Syntax:_
```
  {{"nested"}, CONDITION, { ... }}
```
You can also nest rotation tables, you only have to set the first element to `{"nested"}` (all lowercase!).

The condition is still the same as in _Simple Spell_, _Cast Sequence_ or _Macro_.

The third element is another Rotation Table which gets evaluated if the condition matches. This has two advantages, for once
it makes your conditions easier to read, as you don't have to repeat the common conditions and your rotation gets slightly faster.


#### Required Talents Table
If your rotation requires specific talents, you can use the optional fifth parameter of `kps.rotations.register(...)`.
This *must* be a Table with 7 elements (one for each talent row).
KPS will write a warning if the talent requirements are not met once per fight, but not more than once per minute.

Each element stands for one Talent Tier and should have numeric values between `-3` and `+3`:

 * If the value is `0` than this Tier doesn't have any requiremnts.
 * If the value is positive, this tier must have the given talent (e.g.: `1` = _first talent_).
 * If the value is negative, this tier must have any talent but not the given (e.g.: `-2` = _first or third talent_)

_Example:_
```
{3,0,0,-1,-2,1,2}
-- Tier   1: Third Talent must be selected
-- Tier 2/3: No Requirements
-- Tier   4: First or Second Talant must be selected
-- Tier   5: First or Thirst Talant must be selected
-- Tier   6: First Talent must be selected
-- Tier   7: Second Talent must be selected
```

### Custom Functions
In some cases you might need some custom functions, which are only relevant to a specific class. Those can be registered in the
environment and can be used within your conditions:
```
local burnPhase = false
function kps.env.mage.burnPhase()
    if not burnPhase then
        burnPhase = kps.env.player.timeInCombat < 5 or kps.spells.mage.evocation.cooldown < 2
    else
        burnPhase = kps.env.player.mana > 0.35
    end
    return burnPhase
end

kps.rotations.register(
...
    {spells.arcaneMissiles, 'burnPhase()', "target"  },
...
)
```

Don't forgot to actually call this function within your condition, a simple `'burnPhase'` would always yield `true`.

You can also use functions with parameters:
```
function kps.env.warlock.isHavocUnit(unit)
    if not UnitExists(unit) then  return false end
    if UnitIsUnit("target",unit) then return false end
    return true
end


kps.rotations.register(
...
    {spells.havoc, 'isHavocUnit("focus") and focus.isAttackable', "focus"  },
...
)
```



### Open Issues
%(issues)s



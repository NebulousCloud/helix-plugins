local PLUGIN = PLUGIN

PLUGIN.DoAutoCreation = true

PLUGIN.name = "TFA Support"
PLUGIN.author = "Taxin2012"
PLUGIN.description = "Support for TFA Weapons Pack"
PLUGIN.license = [[
Copyright 2019 Taxin2012
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
]]

PLUGIN.readme = [[
What that plugin does:

Generates items (weapons, ammo, attachments);
Add ability to use attachments in inventory like items (equip to weapons);
Automatically changes and registering ammo and ammo types;
Shows in description what attachments are have the weapon, ammo type and magazine capacity;
Allows to edit weapons parameters without editing the original weapon.

Before use, edit the sound on those lines in "sh_tfa_support.lua" file:
142, 236, 306, 354

"sh_tfa_ammo.lua" - Here you can add ammo ( and new ammo types ).
"sh_tfa_weps.lua" - Here you can edit weapon parameters.
"sh_tfa_attach.lua" - Here you can add attachments.

You can select: auto-generate all weapons but blacklisted or auto-generate only that weapons that described in sh_tfa_weps.lua file. For that, just edit "PLUGIN.DoAutoCreation" option in "sh_tfa_support.lua" file.

`DoAutoCreation` parameter in `sh_plugin.lua` file:
If `true`:
	Auto-generate items for all weapons with `tfa_` prefix
If `false`:
	Auto-generate only that items that described in `sh_tfa_weps.lua` file
*Black List works for both methods
]]



ix.util.Include("sh_tfa_support.lua")
ix.util.Include("cl_tfa_support.lua")

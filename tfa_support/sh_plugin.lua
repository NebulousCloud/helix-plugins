local PLUGIN = PLUGIN
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


`DoAutoCreation` parameter in `sh_plugin.lua` file:
If `true`:
	Auto-generate items for all weapons with `tfa_` prefix
If `false`:
	Auto-generate only that items that described in `sh_tfa_weps.lua` file
*Black List works for both methods
]]

PLUGIN.DoAutoCreation = true

ix.util.Include("sh_tfa_support.lua")
ix.util.Include("cl_tfa_support.lua")

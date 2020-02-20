# Contribution guidelines
Since information about your plugin is gathered for use in the plugin center, there are a few things that need to be formatted in a specific way to ensure it displays properly. Most of the requirements are things that you'll have done in your plugin already, but it doesn't hurt to double-check.

## Required plugin fields
Your plugin needs some basic metadata for identification. These are required in order for it to show up in the plugin center.

### `PLUGIN.name`
The display name of your plugin. This should be short and to the point.

### `PLUGIN.description`
Some text that describes what your plugin does. While it's better to have a longer description, this field also shows up in the in-game plugins list, so you should keep it fairly succinct.

### `PLUGIN.author`
Your name! This should be consistent with any other plugins you submit so all of your plugins can be grouped together under your name.

### `PLUGIN.license`
How your plugin is allowed to be used. We **highly** recommend an open-source, permissible license like the [MIT License](https://opensource.org/licenses/MIT) for your plugin.

## Optional metadata
Some additional data can be used for the purpose of adding or changing how your plugin is shown in the plugin center.

### `PLUGIN.readme`
This field is only used for plugins that are a single file, not for folder plugins. It's used to display a longer, more verbose description that is **only** displayed in the plugin center (e.g it does not show up in game, so go nuts).

If `PLUGIN.readme` is not specified, then `PLUGIN.description` will be used as the verbose description in the plugin center.

### `README.md`
This file is only used for plugins that are contained in a folder, not for single-file plugins. This is analogous to `PLUGIN.readme`, but separated out to its own file so you can keep your code organized. If your plugin is called `myplugin`, then this file should be in `myplugin/README.md`. This is always rendered with markdown, so you can use things like headers and links.

If `README.md` does not exist, then `PLUGIN.description` will be used in the plugin center.

### `LICENSE`
This file is only used for plugins that are contained in a folder, not for single-file plugins. Again, this is analogous to `PLUGIN.license`, but separated out to its own file. It should reside in `myplugin/LICENSE`.

If `LICENSE` does not exist, then `PLUGIN.license` will be used.

### Commands
Any chat commands added with `ix.command.Add` in your plugin will be automatically added to a `Commands` tab in the plugin center. Ensure that you are properly using [language phrases](https://docs.gethelix.co/libraries/ix.lang.html) in the `description` field of your [commands](https://docs.gethelix.co/libraries/ix.command.html#CommandStructure), otherwise they will not display properly.

### Configs
Any server-side configs created with `ix.config.Add` in your plugin will be automatically added to a `Configs` tab in the plugin center.

### Options
Any client-side options created with `ix.option.Add` in your plugin will be automatically added to an `Options` tab in the plugin center. Ensure that you are properly using [language phrases](https://docs.gethelix.co/libraries/ix.lang.html) in the description of your [options](https://docs.gethelix.co/libraries/ix.option.html#OptionStructure), otherwise they will not display properly.

## Code style
We don't like imposing on the way you write code just so you can add it to the plugin center, but there are some things to take into consideration before you submit your plugin.

### Avoid C-style comments
Garry's Mod Lua has additional C-style comments (`//` and `/**/`) that are incompatible with the tools used to extract data from your plugin. You'll have to change them to regular Lua comments (`--` and `--[[]]`) in order to submit your plugin.

### Avoid `IsAdmin`, `IsSuperAdmin` and `IsUserGroup`
Helix fully leverages [CAMI](https://github.com/glua/CAMI) in order to provide the end-user the flexibility to customize permissions of commands and admin-only functionality to their liking.

If you have any `IsAdmin`, `IsSuperAdmin`, or `IsUserGroup` calls in your plugin, you should let Helix handle permissions for you instead by letting it automatically create permissions for each of your commands. Should you find that too limiting, use `CAMI.RegisterPrivilege` and `CAMI.PlayerHasAccess` to allow users to easily customize access to your plugin.

### Avoid `hook.Add`
Helix plugins are able to leverage [hooks](https://docs.gethelix.co/hooks/Plugin.html) by using `function PLUGIN:HookName(args)` instead of `hook.Add`. This allows Helix to prevent your plugin from unnecessarily running code in hooks if it's disabled.

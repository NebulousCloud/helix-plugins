# Helix Plugins

This repository contains plugins that are free to use for your [Helix](https://github.com/NebulousCloud/helix) server.

## Installing
To install a plugin for use on your server, you'll need to obtain the plugin by either cloning the repository, or by [downloading the zipped repo](https://github.com/NebulousCloud/helix-plugins/archive/master.zip).

Then, you place the plugin into the `plugins/` folder of your schema. Note that you should place these plugins into the **schema** folder, not the **helix** folder. For example, to install the `disable_char_swap` plugin into the `ixhl2rp` schema, you'd place the file in `gamemodes/ixhl2rp/plugins/disable_char_swap.lua`.

## Contributing
You are welcome (and encouraged) to create a pull request to add your own plugin to this repository so we can steadily build a plugin ecosystem for the framework.

When adding your plugin as a folder, you should add a `README.md` to the root of your plugin that describes what it does, how to use it, and any othe useful information that the end-user might need. It is also recommended that you license your plugin, either with a `LICENSE` file or embedded within the source code. Our go-to option would be the [MIT license](https://opensource.org/licenses/MIT).

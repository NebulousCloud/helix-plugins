# Helix Plugins

This repository contains plugins that are free to use for your [Helix](https://github.com/NebulousCloud/helix) server.

## Downloading plugins
If you'd like to install a plugin in this repo onto your own server, we recommend using the [Helix Plugin Center](https://plugins.gethelix.co/) to browse and download the plugins.

Plugins downloaded from the plugin center that are just one `.lua` file can be dropped straight into your schema's `plugins/` folder. Plugins that use folders will be packaged in a `.zip` archive, in which case you need to extract the contents of the archive into your schema's `plugins/` folder.

For example, to install the `disable_char_swap` plugin into the `ixhl2rp` schema, you'd place the file in `gamemodes/ixhl2rp/plugins/disable_char_swap.lua`. Note that you should install these plugins to your **schema's** `plugins/` folder, not the framework.

## Contributing
You are encouraged to create a pull request to add your own plugin to the repository and have it displayed in the plugin center for anyone to download. See [CONTRIBUTING.md](CONTRIBUTING.md) for more information on how to properly submit your plugin.

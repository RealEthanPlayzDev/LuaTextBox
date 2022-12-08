# LuaTextBox
LuaTextBox is a module providing a text input field with Lua syntax highlighting and autocompletion

## VERY WIP - DO NOT USE IN PRODUCTION
The current state of the module is very uncomplete, there are tons of bugs and features that need to be considered carefully.
Of course, you can still help contribute!

## Using the module
**Documentation coming soon on my website!**

Simple usage example:
```lua
local LuaTextBox = require(path.to.luatextbox)
local LuaEditorTextBox = LuaTextBox.new()
LuaEditorTextBox:SetParent(some.gui.object)
```

## Credits
- [Highlighter](https://github.com/boatbomber/highlighter) - Syntax highlighting
- [Codify](https://github.com/csqrl/codify-plugin) - Turning guis into code

## Acknowledgements
- boatbomber
- csqrl
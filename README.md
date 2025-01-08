# micro-concat-colorschemes

🚧 **ATTENTION**: this is a hack I came up with. I got it to work, but I did not have time to polish it yet.

To keep track of the plugin state between micro instances `settings.json` is used for this purpose.

## ⚠️ Setup

1. Clone the repo (**NOT** inside `.config/micro/plug`; see BUG in `concat_colorschemes.lua`).
2. Add the following lines to `settings.json` with your values:

    ```json
    "ColorSchemeConcat.INTERNAL_READONLY": "YOUR-MAIN-COLORSCHEME-HERE",
    "colorscheme": "YOUR-MAIN-COLORSCHEME-HERE",
    ```

3. In `concat_colorschemes.lua`, there is a **TODO** to mark the variable `extraColorSchemes`. See the example there to **add the colorschemes you want to include to your main colorscheme**.
4. ⚠️ **Close ALL micro instances**.
5. Execute `ENABLE_FOR_MICRO.sh` from the directory where it is located (this creates a symlink for the plugin inside `.config/micro/plug`).
6. Open micro.

> I was able to reproduce all these steps on my machine.

You can change the main colorschemes from the Command bar with `> set colorscheme VALUE` as usual (this works for me with multiple micro instances open; if you have trouble, try this with only one instance open).

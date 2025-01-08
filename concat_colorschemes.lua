VERSION = "0.0.1"

--BUG: The plugin does not let you change `settings.json` if the plugin is active.
--or at least this happened to me (I did not investigate further).
--Remove it and use ENABLE_FOR_MICRO.sh to re-enable it again.

-- TODO: add your Colorschemes here. Example:
-- local extraColorSchemes = { "your-colorscheme-here", "another-one" }
local extraColorSchemes = {}

local micro  = import("micro")
local config = import("micro/config")

local plugName = "ColorSchemeConcat"
local concatColorSchemeName = "colorscheme-concat"
local internal = plugName..".INTERNAL_READONLY"

local function log(...)
    -- micro.Log("[" .. plugName .. "]", unpack(arg))
end

log("config.GetGlobalOption(internal)", config.GetGlobalOption(internal))
log("select default repl internal",
    select(1, (config.GetGlobalOption("colorscheme"):gsub("default", config.GetGlobalOption(internal)))))

config.SetGlobalOption(
    "colorscheme",
    select(1, (config.GetGlobalOption("colorscheme"):gsub("default", config.GetGlobalOption(internal))))
)

local userColorScheme = nil
local hasExtra = false

---@param table<string> Colorschemes names to concat to your actual colorscheme.
local function ColorSchemeConcat(colorSchemes)
    log("ColorSchemeConcat::entry")
    local linesCS = {}
    local fmt = "include \"%s\""

    if not userColorScheme then -- avoid overwrite it (should not happen but...)
        userColorScheme = config.GetGlobalOption("colorscheme")
    end
    log("ColorSchemeConcat::userColorScheme", userColorScheme)

    table.insert(linesCS, fmt:format(userColorScheme))
    for _, cs in ipairs(colorSchemes) do table.insert(linesCS, fmt:format(cs)) end

    local concatColorScheme = table.concat(linesCS, "\n")
    log("ColorSchemeConcat::concatColorScheme", concatColorScheme)

    config.AddRuntimeFileFromMemory(
        config.RTColorscheme, concatColorSchemeName, concatColorScheme
    )

    config.SetGlobalOption("colorscheme", concatColorSchemeName)
    log("ColorSchemeConcat::exit")
end

function postinit()
    --If empty dont use the plugin
    if not next(extraColorSchemes) then
        micro.Log("["..plugName.."::WARN] extraColorSchemes is empty.")
        micro.Log("["..plugName.."::INFO] Leaving the user colorscheme...")
        return
    end
    hasExtra = true
    log("preinit::entry")
    if not userColorScheme then
        userColorScheme = config.GetGlobalOption("colorscheme")
        config.SetGlobalOptionNative(internal, userColorScheme)
        log("preinit::userColorScheme set to", userColorScheme)
    end
    ColorSchemeConcat(extraColorSchemes)
    log("preinit::exit")
end

function deinit()
    if not hasExtra then return end
    log("deinit::entry")
    micro.Log("ColorSchemeConcat::deinit::userColorScheme", userColorScheme)
    if config.GetGlobalOption("colorscheme") == concatColorSchemeName then
        config.SetGlobalOption("colorscheme", userColorScheme)
    end
    log("deinit::config.GetGlobalOption(\"colorscheme\")", config.GetGlobalOption("colorscheme"))
    userColorScheme = nil
    log("deinit::exit")
end

function preQuit(_)
    if not hasExtra then return true end
    log("preQuit::entry")
    if #micro.Tabs().List == 1 and #micro.CurTab().Panes == 1 then
        log("preQuit::reset_colorscheme")
        -- if config.GetGlobalOption("colorscheme") == userColorScheme.."CONCAT" then
        if config.GetGlobalOption("colorscheme") == concatColorSchemeName then
            log("preQuit::replacing_concatColorScheme")
            config.SetGlobalOption("colorscheme", userColorScheme)
        else
            log("preQuit::colorscheme was changed, ignore...")
            log("userColorScheme, concatColorSchemeName",
                 userColorScheme, concatColorSchemeName)
                 -- userColorScheme, userColorScheme.."CONCAT")
        end
    end
    log("preQuit::exit")
    return true
end

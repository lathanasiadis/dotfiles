local status_icons_dir = "/usr/share/icons/Papirus/48x48/status/"

local constants = {
    -- catppuccin colors
    rosewater = "#f2d5cf",
    flamingo = "#eebebe",
    pink = "#f4b8e4",
    mauve = "#ca9ee6",
    red = "#e78284",
    maroon = "#ea999c",
    peach = "#ef9f76",
    yellow = "#e5c890",
    green = "#a6d189",
    teal = "#81c8be",
    sky = "#99d1db",
    sapphire = "#85c1dc",
    blue = "#8caaee",
    lavender = "#babbf1",
    text = "#c6d0f5",
    subtext1 = "#b5bfe2",
    subtext0 = "#a5adce",
    overlay2 = "#949cbb",
    overlay1 = "#838ba7",
    overlay0 = "#737994",
    surface2 = "#626880",
    surface1 = "#51576d",
    surface0 = "#414559",
    base = "#303446",
    mantle = "#292c3c",
    crust = "#232634",
    --
    font = "Roboto 14",
    monofont = "RobotoMono Nerd Font 14",
    iconfont = "RobotoMono Nerd Font Propo 14",
    --
    notif_timeout = 5,
    notif_app_name = "volume-notif",
    icons = {
        status_dir = status_icons_dir,
        volume = {
            muted = status_icons_dir .. "notification-audio-volume-muted.svg",
            low = status_icons_dir .. "notification-audio-volume-low.svg",
            medium = status_icons_dir .. "notification-audio-volume-medium.svg",
            high = status_icons_dir .. "notification-audio-volume-high.svg"   
        },
        brightness = {
            low = status_icons_dir .. "notification-display-brightness-low.svg",
            medium = status_icons_dir .. "notification-display-brightness-medium.svg",
            high = status_icons_dir .. "notification-display-brightness-full.svg"
        }
    }
}



return constants
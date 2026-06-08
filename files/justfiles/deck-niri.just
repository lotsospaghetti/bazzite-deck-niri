alias fix-niri-config := reset-niri-config
alias set-screen-transform := set-screen-rotation

_regen-display-config:
    #!/usr/bin/bash
    mkdir -p "$HOME/.config/niri/" 2>/dev/null
    cat <<-EOF >"$HOME/.config/niri/internal-display.kdl"
        // this file is dynamically adjusted based on the device the first time Niri is run
        // please use 'ujust set-screen-rotation' and 'ujust set-screen-scale' to edit this file
        // and use custom configs to set up external displays
        output "eDP" {
          scale 1.0
          transform "normal"
        }
        output "eDP-1" {
          scale 1.0
          transform "normal"
        }
    EOF

reset-niri-config CONFIRM="":
    #!/usr/bin/bash
    set -euo pipefail
    source /usr/lib/ujust/ujust.sh 2>/dev/null || true

    CONFIRM="{{ CONFIRM }}"
    CHOICE=""
    if [[ -z $CONFIRM ]]; then
        echo "This will reset any changes you've made to the Niri configs in /etc/niri."
        echo "(Your user configs in ~/.config/niri will not be modified)"
        echo "Would you like to proceed?"
        CHOICE=$(ugum choose \
                "Reset configuration" \
                "Exit without changes")
    else
        case "$CONFIRM" in
            --[Yy][Ee][Ss]|-[Yy]) CHOICE="Reset configuration" ;;
            *) echo "Must pass '--yes' or '-y' to bypass confirmation prompt." ; exit 1 ;;
        esac
    fi

    case "$CHOICE" in
        "Reset configuration")
            echo "Applying default configuration..."
            cp /var/usr/etc/niri/* /etc/niri/.
            rm "$HOME/.config/bazzite/fixups/niri_rotation_fixup" 2>/dev/null
            rm "$HOME/.config/bazzite/fixups/niri_scaling_fixup" 2>/dev/null
            rm "$HOME/.config/niri/internal-display.kdl" 2>/dev/null
            ;;
        *)
            echo "No changes made."
            exit 0
            ;;
    esac

set-screen-rotation VALUE="":
    #!/usr/bin/bash
    set -euo pipefail
    source /usr/lib/ujust/ujust.sh 2>/dev/null || true

    VALUE="{{ VALUE }}"

    if [ ! -f "$HOME/.config/niri/internal-display.kdl" ]; then
        echo "WARNING: $HOME/.config/niri/internal-display.kdl not found! Restoring it..."
        ujust _regen-display-config
    fi

    rotate_status="$(grep -m 1 'transform' "$HOME/.config/niri/internal-display.kdl" | cut -d'"' -f2)"

    if [[ $ACTION == "help" ]]; then
        echo "Usage: ujust set-screen-rotation [0|normal|90|left|270|right|180|flipped|flipped-90|flipped-270|flipped-180]"
        echo "If no action is provided you'll be prompted with a picker."
        exit 0
    fi

    CHOICE=""
    if [[ -z $VALUE ]]; then
        echo -e "Current screen rotation: ${bold}${rotate_status}${normal}\n"
        echo "How would you like the screen rotated/transformed?"
        CHOICE=$(ugum choose \
                "Normal" \
                "Left-rotated (for some devices like the Legion Go)" \
                "Right-rotated (usually for the Steam Deck)" \
                "More options..." \
                "Exit without changes")
        # map choice above to valid strings, or give all options if user selected that
        case "$CHOICE" in
            Normal) CHOICE="normal" ;;
            Left*) CHOICE="90" ;;
            Right*) CHOICE="270" ;;
            More*)
                echo "Here are all the options supported by Niri:"
                CHOICE=$(ugum choose \
                        "normal" \
                        "90" \
                        "270" \
                        "180" \
                        "flipped" \
                        "flipped-90" \
                        "flipped-270" \
                        "flipped-180" \
                        "Exit without changes")) ;;
        esac
        if [[ "$CHOICE" =~ "Exit" ]]; then
            echo "No changes made."
            exit 0
        fi
    else
        case "$VALUE" in
            [Nn][Oo][Rr][Mm][Aa][Ll]|0) CHOICE="normal" ;;
            [Ll][Ee][Ff][Tt]|90) CHOICE="90" ;;
            [Rr][Ii][Gg][Hh][Tt]|270) CHOICE="270" ;;
            180) CHOICE="180" ;;
            [Ff][Ll][Ii][Pp][Pp][Ee][Dd]) CHOICE="flipped" ;;
            [Ff][Ll][Ii][Pp][Pp][Ee][Dd]-90) CHOICE="flipped-90" ;;
            [Ff][Ll][Ii][Pp][Pp][Ee][Dd]-270) CHOICE="flipped-270" ;;
            [Ff][Ll][Ii][Pp][Pp][Ee][Dd]-180) CHOICE="flipped-180" ;;
            *) echo "Unrecognized value: $VALUE" ; exit 1 ;;
        esac
    fi

    sed -i -E "s/^( |\t)+transform \".*\"/  transform \"$CHOICE\"/g" "$HOME/.config/niri/internal-display.kdl"
    ugum confirm "Keep changes?" || \
      sed -i -E "s/^( |\t)+transform \".*\"/  transform \"$rotate_status\"/g" "$HOME/.config/niri/internal-display.kdl"

set-screen-scaling VALUE="":
    #!/usr/bin/bash
    set -euo pipefail
    source /usr/lib/ujust/ujust.sh 2>/dev/null || true

    VALUE="{{ VALUE }}"

    if [ ! -f "$HOME/.config/niri/internal-display.kdl" ]; then
        echo "WARNING: $HOME/.config/niri/internal-display.kdl not found! Restoring it..."
        ujust _regen-display-config
    fi

    scale_status="$(grep -m 1 'scale' "$HOME/.config/niri/internal-display.kdl" | cut -d'"' -f2)"

    if [[ $ACTION == "help" ]]; then
        echo "Usage: ujust set-screen-scaling <SCALE>"
        echo "If no action is provided you'll be prompted with a picker."
        exit 0
    fi

    CHOICE=""
    if [[ -z $VALUE ]]; then
        echo -e "Current screen rotation: ${bold}${scale_status}${normal}\n"
        echo "How would you like the screen scaled? (pass an argument to define more specific values)"
        CHOICE=$(ugum choose \
                "0.75" \
                "1.0" \
                "1.25" \
                "1.5" \
                "1.75" \
                "2.0" \
                "Exit without changes")
        if [[ "$CHOICE" =~ "Exit" ]]; then
            echo "No changes made."
            exit 0
        fi
    else
        if [[ $VALUE -lt 0 ]] || [[ $VALUE -gt 10 ]] || [[ ! "$VALUE" =~ "([0-9]|10)(.[0-9]{1,4})?" ]]; then
            echo "Unrecognized or invalid value: $VALUE"
            exit 1
        fi
        CHOICE="$VALUE"
    fi

    sed -i -E "s/^( |\t)+scale .*/  scale $CHOICE/g" "$HOME/.config/niri/internal-display.kdl"
    ugum confirm "Keep changes?" || \
      sed -i -E "s/^( |\t)+scale .*/  scale $scale_status/g" "$HOME/.config/niri/internal-display.kdl"

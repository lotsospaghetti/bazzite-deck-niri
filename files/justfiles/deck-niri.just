alias fix-niri-config := reset-niri-config
alias niri-set-screen-transform := niri-set-screen-rotation

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
            sudo rm -f /etc/niri/*
            sudo cp /usr/etc/niri/* /etc/niri/.
            niri msg action do-screen-transition 2>/dev/null || true
            rm "$HOME/.config/bazzite/niri-internal-display.kdl" 2>/dev/null || true
            /usr/bin/bazzite-desktop-bootstrap
            ;;
        *)
            echo "No changes made."
            exit 0
            ;;
    esac

niri-set-screen-rotation VALUE="":
    #!/usr/bin/bash
    set -euo pipefail
    source /usr/lib/ujust/ujust.sh 2>/dev/null || true

    VALUE="{{ VALUE }}"

    # ensure display config exists, this shouldn't do anything if it does
    /usr/bin/bazzite-desktop-bootstrap

    rotate_status="$(grep -m 1 'transform' "$HOME/.config/bazzite/niri-internal-display.kdl" | cut -d'"' -f2)"

    if [[ $VALUE == "help" ]]; then
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

    niri msg action do-screen-transition 2>/dev/null || true
    sed -i -E "s/^( |\t)+transform \".*\"/  transform \"$CHOICE\"/g" "$HOME/.config/bazzite/niri-internal-display.kdl"
    if ! ugum confirm "Keep changes?"; then
      niri msg action do-screen-transition 2>/dev/null || true
      sed -i -E "s/^( |\t)+transform \".*\"/  transform \"$rotate_status\"/g" "$HOME/.config/bazzite/niri-internal-display.kdl"
    fi

niri-set-screen-scaling VALUE="":
    #!/usr/bin/bash
    set -euo pipefail
    source /usr/lib/ujust/ujust.sh 2>/dev/null || true

    VALUE="{{ VALUE }}"

    # ensure display config exists, this shouldn't do anything if it does
    /usr/bin/bazzite-desktop-bootstrap

    scale_status="$(grep -m 1 'scale' "$HOME/.config/bazzite/niri-internal-display.kdl" | cut -d'"' -f2)"

    if [[ $VALUE == "help" ]]; then
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

    niri msg action do-screen-transition 2>/dev/null || true
    sed -i -E "s/^( |\t)+scale .*/  scale $CHOICE/g" "$HOME/.config/bazzite/niri-internal-display.kdl"
    if ! ugum confirm "Keep changes?"; then
      niri msg action do-screen-transition 2>/dev/null || true
      sed -i -E "s/^( |\t)+scale .*/  scale $scale_status/g" "$HOME/.config/bazzite/niri-internal-display.kdl"
    fi

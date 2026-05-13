#!/usr/bin/env bash

set -e

DEV_DIR="$HOME/dev"
GITHUB_USER="mdk-zero"

check_gh_auth() {
    if ! gh auth status &>/dev/null; then
        echo "Not authenticated with GitHub. Running gh auth login..."
        gh auth login
    fi
}

fetch_repos() {
    gh repo list "$GITHUB_USER" --source --limit 100 --json name -q '.[].name'
}

select_repos() {
    local repos
    repos=$(fetch_repos)

    if command -v fzf &>/dev/null; then
        echo "$repos" | fzf --multi --prompt="Select repos to clone> "
    else
        echo "fzf not found. Using select menu."
        local selected=()
        local choice

        echo "Available repos (enter number to toggle, 'd' when done):"
        echo "$repos" | nl -w2 -s ". "

        while true; do
            echo -n "#? "
            read choice
            case "$choice" in
                d|D)
                    break
                    ;;
                "")
                    continue
                    ;;
                *)
                    repo=$(echo "$repos" | sed -n "${choice}p")
                    if [ -n "$repo" ]; then
                        if [[ ! " ${selected[*]} " =~ " $repo " ]]; then
                            selected+=("$repo")
                            echo "Added: $repo"
                        else
                            selected=("${selected[@]/$repo}")
                            echo "Removed: $repo"
                        fi
                    else
                        echo "Invalid selection"
                    fi
                    ;;
            esac
        done

        printf '%s\n' "${selected[@]}"
    fi
}

handle_existing() {
    local repo="$1"
    local path="$DEV_DIR/$repo"

    if [ -d "$path" ]; then
        echo "Repo '$repo' already exists at $path"
        echo "Options: [s]kip, [u]pdate (git pull), [r]e-clone"
        read -n 1 -r choice
        echo
        case "$choice" in
            s|S) return 1 ;;
            u|U)
                cd "$path"
                git pull
                return 1
                ;;
            r|R) rm -rf "$path" ;;
            *) echo "Invalid choice, skipping."; return 1 ;;
        esac
    fi
    return 0
}

main() {
    if ! command -v gh &>/dev/null; then
        echo "Error: gh CLI not installed. Install it from https://cli.github.com/"
        exit 1
    fi

    check_gh_auth

    if [ ! -d "$DEV_DIR" ]; then
        echo "Creating $DEV_DIR..."
        mkdir -p "$DEV_DIR"
    fi

    echo "Fetching your repos..."
    local selected
    selected=$(select_repos)

    if [ -z "$selected" ]; then
        echo "No repos selected. Exiting."
        exit 0
    fi

    while IFS= read -r repo; do
        [ -z "$repo" ] && continue

        if handle_existing "$repo"; then
            echo "Cloning $GITHUB_USER/$repo..."
            gh repo clone "$GITHUB_USER/$repo" "$DEV_DIR/$repo"
        fi
    done <<< "$selected"

    echo "Done!"
}

main
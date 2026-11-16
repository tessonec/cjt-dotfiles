# cjt-dotfiles — one shell setup on every machine

zsh, oh-my-zsh, Powerlevel10k and the plugins, kept identical on macOS, Linux and NAS boxes (Asustor ADM, Synology DSM with Entware), for your user and for root. The `cjt-casamia` command handles everything. [chezmoi](https://www.chezmoi.io) and git do the work underneath, but you never run them yourself.

## New machine: one command

```sh
curl -fsSL https://raw.githubusercontent.com/tessonec/cjt-dotfiles/main/dot_local/bin/executable_cjt-casamia | sh -s init
```

Then open a new shell. For root, run:

```sh
sudo cjt-casamia init
```

- It installs chezmoi, oh-my-zsh, Powerlevel10k, the plugins and the packages each system needs.
- A NAS needs Entware first; the command stops and tells you if it's missing.
- The repo must be **public** for this download to work. It holds no secrets.
- Accounts with a GitHub SSH key clone over SSH and can push. Root and keyless machines clone over HTTPS and only pull.

## Everyday use

| Command | What it does |
|---|---|
| `cjt-casamia push ["message"]` | collects your edits to managed files, commits and pushes |
| `cjt-casamia pull` | fetches and applies the latest version |
| `cjt-casamia sync` | push, then pull |
| `cjt-casamia add ~/.tmux.conf ~/.vimrc ~/.screenrc ~/.config/mc/ini` | starts managing more files; then run `push` |
| `cjt-casamia edit ~/.zshrc` | edits a templated file (`.zshrc`, `.profile`) |
| `cjt-casamia status` | shows what differs locally and what is unpushed |
| `cjt-casamia diff` / `apply` | previews or applies the local copy of the repo |
| `cjt-casamia import FILE.tar.gz` | unpacks a new version of the repo, then commits, pushes and applies it |
| `cjt-casamia auto on/off` | turns the background pull at shell start on or off (at most every 12 h; on by default) |

The automatic pull never overwrites local edits. If a file has been changed on the machine, it waits until you run `push` or `sync`.

## Machine-specific settings

Put them in `~/.zshrc.local`, which is not managed: conda init, local aliases, secrets. `init` moves an existing `conda initialize` block there automatically.

## What is in the repo

| Path | Purpose |
|---|---|
| `dot_zshrc.tmpl` | `~/.zshrc`, with NAS and macOS parts chosen automatically |
| `dot_p10k.zsh` | the prompt |
| `dot_profile.tmpl` | NAS only: starts Entware's zsh at login |
| `dot_screenrc.tmpl` | GNU screen: status bar in the prompt's palette (host, session, windows, uptime, IP, date); syntax picked per screen version |
| `dot_local/bin/executable_cjt-statusinfo` | Uptime and IP for status bars, on Linux, NAS and macOS |
| `dot_local/bin/executable_cjt-casamia` | the command itself |
| `.chezmoiexternal.toml` | oh-my-zsh, Powerlevel10k and plugins, refreshed weekly |
| `run_onchange_before_10-packages.sh.tmpl` | installs packages (Nerd Font, zsh, git, terminfo…) |

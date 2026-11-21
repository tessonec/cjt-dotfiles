# cjt-casamia (Casamia): one shell setup on every machine

Worker of Claudio's CJT workers (skill `cjt-worker`). Registered with the coordinator (Tero) by request,
21 Nov 2026. Folder: `~/Development/cjt-casamia` on the Mac (mba-m2).

## What it does

Keeps Claudio's shell environment identical on every machine he uses: zsh + oh-my-zsh + Powerlevel10k
prompt, GNU screen, tmux and Midnight Commander in one muted palette, and (planned) his SSH server list.
Claudio only ever runs `cjt-casamia` (init, pull, push, sync, status, reset ...): never chezmoi or git.

## Layout (two repositories)

| Where | Repository | Visibility | Holds |
|---|---|---|---|
| this folder | `tessonec/cjt-dotfiles` | **private** | the configurations (chezmoi source) and this worker's memory (`CLAUDE.md`, `docs/`) |
| `casamia/` (nested, own git) | `tessonec/cjt-casamia` | **public** | only the `cjt-casamia` script, its README and helper scripts |

- The Mac's chezmoi source is a symlink: `~/.local/share/chezmoi -> ~/Development/cjt-casamia`.
- Every machine gets the script from the public repo (chezmoi external) and the configurations from the
  private repo (its own SSH key; keyless machines use a read-only deploy key that `init` creates).
- `CLAUDE.md`, `docs/` and `casamia/` are in `.chezmoiignore`: they never land in anyone's home folder.

## Rules

1. Nothing private in the public repo, ever: no host names, users, IPs, paths of Claudio's, keys.
2. Keys are never managed or copied. SSH config (hosts, users, ports) goes in the private repo only.
3. Status bars and anything screen draws: ASCII only (non-ASCII makes screen miscount and wrap).
4. Test what can be tested in the VM (sh -n, zsh -n, screen/tmux load in tmux); say what is untested.
5. Edits here reach GitHub on Claudio's next new Mac shell (auto-push of this folder and of `casamia/`),
   other machines pull within 12 h. Tell Claudio which one command to run when he wants it at once.
6. The standing rules of 14 Nov hold: commit meaningful changes; deletions only by Claudio.

## Machines (user and root on each)

| Machine | Access | Notes |
|---|---|---|
| mba-m2 (Mac) | pushes (Claudio's GitHub SSH key) | dev machine; Homebrew; root via `sudo -i` |
| asustor6 (Asustor ADM) | pull only | Entware from App Central |
| ds620 (Synology DSM) | pull only | Entware by hand; boot-up task remounts /opt |
| ether1, abacus-1 (UZH Linux) | pull only | small /tmp; login shell bash, `init` adds `exec zsh -l` |

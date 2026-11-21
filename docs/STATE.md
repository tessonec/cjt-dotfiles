# STATE (cjt-casamia) - 21 Nov 2026

## Last done
- 16-18 Nov: zsh/p10k prompt, screen bar, mc skin, tmux config, `cjt-casamia` script (init, pull, push,
  sync, add, edit, diff, apply, import, reset, status, auto); deployed on Mac, asustor6, ds620, ether1, abacus-1.
- 21 Nov: registration request posted to the coordinator (messages/20261120T235500Z_cjt-casamia_to_cjt-coordinator_request.md).
- 21 Nov: repo split prepared: `casamia/` (own git, remote git@github.com:tessonec/cjt-casamia.git, files staged,
  first commit left to the Mac so it carries Claudio's git identity); script now reaches the private repo with
  the account's GitHub key or a read-only deploy key it creates (`init`), and migrates old https clones;
  bootstrap URL moved to the public repo; `.gitignore` keeps `casamia/` out of the private repo.

## Next
1. Repo split (decided by Claudio, 18 Nov, by voice): Claudio creates the empty public repo `tessonec/cjt-casamia`,
   then `cjt-casamia sync` + a new Mac shell pushes both; then he makes `cjt-dotfiles` private.
   After that: switch `dot_local/bin/executable_cjt-casamia` and `executable_cjt-statusinfo` to chezmoi
   externals from the public repo (one source for the script).
2. Migrate keyless machines to a read-only deploy key (`cjt-casamia init` on each, user and root).
3. SSH server list in the private repo (`~/.ssh/config`: hosts, users, IPs, ports; keys untouched).

## Waiting on
- Claudio: GitHub steps of the split. Coordinator: entry in WORKERS.md.

## Open questions
- Encrypt `~/.ssh/config` on top of the private repo, or is private enough? (Claudio said encryption was
  "good enough" before the split was decided.)

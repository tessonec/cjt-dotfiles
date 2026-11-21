# STATE (cjt-casamia) - 21 Nov 2026

## Wake
wake: on message

## Last done
- 16-18 Nov: zsh/p10k prompt, screen bar, mc skin, tmux config, `cjt-casamia` script (init, pull, push,
  sync, add, edit, diff, apply, import, reset, status, auto); deployed on Mac, asustor6, ds620, ether1, abacus-1.
- 21 Nov: registration request posted to the coordinator (messages/20261120T235500Z_cjt-casamia_to_cjt-coordinator_request.md).
- 21 Nov: repo split prepared: `casamia/` (own git, remote git@github.com:tessonec/cjt-casamia.git, files staged,
  first commit left to the Mac so it carries Claudio's git identity); script now reaches the private repo with
  the account's GitHub key or a read-only deploy key it creates (`init`), and migrates old https clones;
  bootstrap URL moved to the public repo; `.gitignore` keeps `casamia/` out of the private repo.
- 21 Nov: registered by the coordinator as `cjt-casamia` (Casamia), family Infrastructure and knowledge;
  folder to move to `~/Projects/cjt-casamia` when Tero says so (messages/20261121T080200Z_coordinator_to_cjt-casamia_answer.md).
  Wake line set to `wake: on message` (Tero's request 20261121T085422Z); messages read and acked.

## Next
1. Repo split (decided by Claudio, 18 Nov, by voice): Claudio creates the empty public repo `tessonec/cjt-casamia`,
   then `cjt-casamia sync` + a new Mac shell pushes both; then he makes `cjt-dotfiles` private.
   After that: switch `dot_local/bin/executable_cjt-casamia` and `executable_cjt-statusinfo` to chezmoi
   externals from the public repo (one source for the script).
2. Migrate keyless machines to a read-only deploy key (`cjt-casamia init` on each, user and root).
3. SSH server list in the private repo (`~/.ssh/config`: hosts, users, IPs, ports; keys untouched).

## Waiting on
- Claudio: GitHub steps of the split (feedback-needed message of 21 Nov).
- Tero: WORKERS.md row, and the folder move to `~/Projects/cjt-casamia` (on its move list for Claudio's OK).
  When Tero says it is done: redo `~/.local/share/chezmoi -> ~/Projects/cjt-casamia` and fix the paths in
  CLAUDE.md (lines 4 and 19; nothing else in either repo names the folder). Until then nothing changes.

## Open questions
- Encrypt `~/.ssh/config` on top of the private repo, or is private enough? (Claudio said encryption was
  "good enough" before the split was decided.)

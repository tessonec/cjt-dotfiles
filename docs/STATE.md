# STATE (cjt-casamia) - 21 Nov 2026

## Wake
wake: on message

## Last done
- 16-18 Nov: zsh/p10k prompt, screen bar, mc skin, tmux config, `cjt-casamia` script (init, pull, push,
  sync, add, edit, diff, apply, import, reset, status, auto); deployed on Mac, asustor6, ds620, ether1, abacus-1.
- 21 Nov: registration request posted to the coordinator (messages/20261120T235500Z_cjt-casamia_to_cjt-coordinator_request.md).
- 21 Nov: repo split prepared: `casamia/` (own git, remote git@github.com:tessonec/cjt-casamia.git; first commit
  ad721b5 made by the Mac's auto run, not yet pushed, no upstream); script now reaches the private repo with
  the account's GitHub key or a read-only deploy key it creates (`init`), and migrates old https clones;
  bootstrap URL moved to the public repo; `.gitignore` keeps `casamia/` out of the private repo.
- 21 Nov: registered by the coordinator as `cjt-casamia` (Casamia), family Infrastructure and knowledge;
  folder to move to `~/Projects/cjt-casamia` when Tero says so (messages/20261121T080200Z_coordinator_to_cjt-casamia_answer.md).
  Wake line set to `wake: on message` (Tero's request 20261121T085422Z); messages read and acked.
- 21 Nov: Tero created github.com/tessonec/cjt-casamia (empty, public) on Claudio's OK. Claudio: a private repo
  is enough for the SSH host list (no encryption); order: `cjt-dotfiles` private first, then Tero runs the sync;
  no push before Tero says dotfiles is private (answers 132725Z, 132844Z).
- 21 Nov: fix: `push`/`sync` now also push the public `casamia/` repo (`push_public`: commits its edits, first
  push sets the upstream; failures only warn). Before, `sync` pushed only the private repo and the auto run
  pushed `casamia/` only when it had uncommitted edits, so the first commit would never have reached GitHub.
  Tested: `sh -n`. Untested: a real run (the session could not write test repos; nothing was pushed).
  The public files were checked again for private data: only the GitHub user name in the repo URLs.
  Both repos committed locally, not pushed; trees clean, so a new Mac shell pushes nothing.

## Next
1. Repo split: when Tero says `cjt-dotfiles` is private, Tero runs `cjt-casamia sync` **twice** (the first run
   pushes the configurations and installs the new script; the second, with `push_public`, fills the public repo).
   Then check github.com/tessonec/cjt-casamia shows the script and README.
   After that: switch `dot_local/bin/executable_cjt-casamia` and `executable_cjt-statusinfo` to chezmoi
   externals from the public repo (one source for the script; today both copies are kept identical by hand).
2. Migrate keyless machines to a read-only deploy key (`cjt-casamia init` on each, user and root).
3. SSH server list in the private repo (`~/.ssh/config`: hosts, users, IPs, ports; keys untouched; no
   encryption, Claudio 21 Nov).

## Waiting on
- Tero: word that `cjt-dotfiles` is private (Claudio confirms with his passkey), then the double sync.
- Tero: WORKERS.md row, and the folder move to `~/Projects/cjt-casamia` (on its move list for Claudio's OK).
  When Tero says it is done: redo `~/.local/share/chezmoi -> ~/Projects/cjt-casamia` and fix the paths in
  CLAUDE.md (lines 4 and 19; nothing else in either repo names the folder). Until then nothing changes.

## Open questions
- None.

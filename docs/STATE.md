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
- 21 Nov: Claudio gave Casamia `cjt-exec`, the bridge that lets workers with a grant run commands on the Mac
  and the servers (request 20261121T140741Z). Proposal rev 1 written: `docs/PROPOSAL-cjt-exec.md` (copy in
  Milestones `projects/cjt-casamia/`). Design: request files in the worker's own folder; a launchd bridge on the
  Mac runs them over ssh; grants in a file only Tero writes, checked by Workbench; one log in
  `~/Library/Logs/cjt-exec/`; deleting, sudo, pushing and sending are refused and go to Claudio through Tero.
  Nothing built yet.
- 21 Nov: proposal rev 2, after Workbench's grant check (kit 270a4e8: registry line `hosts: [...]`, check
  `~/Robots/kit/bin/tero-workers may-exec <worker> <host>`) and bdlt-lib-utxo's answers on `mac.sh` and `run.sh`.
  - The caller's id comes from the request's folder, through `tero-workers owner <path>`, which Workbench is asked to
    add. Never from the worker itself.
  - Mode suffix `host:run` (a bare host means read).
  - stdin and stdout passed through (for `bdlt-call`).
  - The check's answer is logged with every command, and `utxo1-migration.log` is imported.
  - Refusals added: crontab and service changes, `pkill -f` and `killall`, background jobs (`-d` instead).
  - Cloud chats are not served.
- 21 Nov: proposal rev 3, after Workbench 161500Z and bdlt-lib-utxo 141847Z.
  - **Grants:** in `~/Robots/tero/grants/cjt-exec.json` (JSON: worker, hosts, mode, ok_by, date, until), which only
    Tero writes. They replace the registry line. The check is
    `~/Robots/kit/bin/tero-workers may-exec <worker> <host> <read|run>` (kit 08f2a87).
  - **Identity:** the innermost roster folder that holds the request is the caller; a folder with no roster row is
    refused. It holds only after Workbench's step 2: the `.cjt-exec/**` deny in perms.py, for 3 nested cases today.
    **No go-live before Workbench says so.**
  - **stdin:** in a sibling `<id>.in`.
  - **utxo1:** today's alias is `utxo1.bdlt`; the SSH list will add short names.
  - **`mac.sh`:** received. The old log is copied in by the installer.
- 21 Nov: proposal rev 4.
  - **Identity:** the bridge calls `~/Robots/kit/bin/tero-workers owner <path>` (Workbench, kit b2acf9c). It is
    innermost-roster and refuses when another worker's profile can write the path. It takes about 70 profile builds
    per call, to be timed on the Mac.
  - **Grant modes:** come from the grants file (`read` when missing), with no registry line.
  - **Server rules (Tero 143212Z), new section 5b:**
    - a wrapper per host, owned by the host's owner (ether `acc-diag.sh`, an abacus-2 watchdog);
    - tmux `<worker>-<id>` with START/END lines;
    - stdin up to 20 MB (code out by tar);
    - `-o` for results up to 50 MB.
- 21 Nov, 15:22-15:23 CET: **early push, against the agreed order.**
  - What happened: while I was editing the proposal, a new Mac shell found the private folder with uncommitted edits.
    The automatic run committed and pushed `cjt-dotfiles` (fc5507c, 3b6931f), applied the new script, and with it
    `push_public` pushed `casamia/` for the first time (now tracking origin/main).
  - No message says `cjt-dotfiles` was private by then, so it may have gone to a still-public repo. Contents:
    `docs/STATE.md` and `docs/PROPOSAL-cjt-exec.md`, with host aliases, worker names and folder paths (no
    addresses, users or keys).
  - The public repo got only the script, `cjt-statusinfo` and the README, checked clean.
  - The double sync is no longer needed.
  - **Lesson:** before editing while pushes must wait, ask for `cjt-casamia auto off` (my sandbox cannot write its
    flag), or commit at once.

## Next
1. Repo split: both repos are pushed (21 Nov, 15:23). Left to do: `cjt-dotfiles` to private (Claudio), and a
   check that github.com/tessonec/cjt-casamia shows the script and README (I cannot reach GitHub from here).
   After that: switch `dot_local/bin/executable_cjt-casamia` and `executable_cjt-statusinfo` to chezmoi
   externals from the public repo (one source for the script; today both copies are kept identical by hand).
2. Migrate keyless machines to a read-only deploy key (`cjt-casamia init` on each, user and root).
3. SSH server list in the private repo (`~/.ssh/config`: hosts, users, IPs, ports; keys untouched; no
   encryption, Claudio 21 Nov). `cjt-exec` takes its host aliases from it.
4. `cjt-exec` (after Claudio's OK on the proposal): build the worker script, the bridge and its launchd agent in
   `casamia/`. Test with fake workers against `mac` in read mode and against the refusals. Go live for `mac`
   read-only first, and on the servers when Claudio is home with the VPN. Take over `mac.sh` (old copy to
   `_handed-over/`, add it to `.chezmoiignore`). Then the skill `cjt-exec` via `skills-inbox/`.

## Waiting on
- Claudio and Tero: is `cjt-dotfiles` private yet? If not, make it private now (feedback-needed 20261121T163001Z).
- Tero: WORKERS.md row, and the folder move to `~/Projects/cjt-casamia` (on its move list for Claudio's OK).
  When Tero says it is done: redo `~/.local/share/chezmoi -> ~/Projects/cjt-casamia` and fix the paths in
  CLAUDE.md (lines 4 and 19; nothing else in either repo names the folder). Until then nothing changes.

- Claudio: OK on the `cjt-exec` proposal and its questions (feedback-needed 20261121T143001Z and 160001Z).
- Workbench: word that the `.cjt-exec/` deny of step 2 is in (needed before go-live).
- bdlt-lib-account: agree that `acc-diag.sh` is the ether wrapper the bridge calls. bdlt-lib-utxo: who writes the
  abacus-2 watchdog wrapper.
- Tero: agree to the grants file place; register bdlt-lib-utxo (no registry entry yet, so `may-exec` refuses it).

## Open questions
- `cjt-exec`: see section 7 of the proposal.

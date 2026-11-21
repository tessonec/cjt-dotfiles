# cjt-exec: proposal (rev 5, 21 Nov 2026, Casamia)

For Claudio, Tero, Workbench and bdlt-lib-utxo (request 20261121T140741Z). Nothing is built until Claudio says OK.

- Rev 2 took in Workbench's grant check (155500Z) and bdlt-lib-utxo's answers on `mac.sh` and `run.sh` (141335Z,
  141500Z).
- Rev 3 took in Workbench's grants file and identity rules (161500Z, replacing the registry line) and `mac.sh` itself
  (141847Z).
- Rev 4 took in `tero-workers owner` (Workbench 164500Z, kit b2acf9c) and the server run rules (Tero 143212Z,
  section 5b).
- Rev 5 names the wrappers per host (`acc-diag.sh` for ether, 144100Z; `guard.sh` for abacus-2 and utxo1, 144425Z),
  takes the time and concurrency limits from `remote.toml`, and notes the VPN (143916Z).

## 1. Use (the same in every worker, on the Mac and in the Linux VM)

    cjt-exec <host> '<command>'            run, wait, print output, exit with the command's exit code
    cjt-exec <host> '<command>' < in.json  stdin passed through unchanged (up to 20 MB)
    cjt-exec -o res.json <host> '<cmd>'    stdout to a file in .cjt-exec/in/ (up to 50 MB)
    cjt-exec -t 30m <host> '<command>'     timeout (default 10 min, at most 2 h)
    cjt-exec -d <host> '<command>'         long job: runs in a named tmux session on the host, returns a job id
    cjt-exec job <id>                      state, exit code and the last 50 lines of a long job
    cjt-exec hosts                         the hosts this worker may reach, and how (read / run)

- `<host>` is an alias from Claudio's SSH configuration, in lower case: `mac` (the Mac itself), `utxo1`,
  `abacus-2`, `ether1`, `asustor6`, `ds620` ... Never an address, user or key.
  - Today's alias for utxo1 is `utxo1.bdlt`. The SSH server list (Casamia's Next 3) gives each host its short name
    as well (`Host utxo1 utxo1.bdlt`), so both work and grants use the short name.
- stdout and stderr come back unchanged, up to 1 MB each. More stays in the log folder, and the worker is told.
  This covers the calculation service's `bdlt-call` (a JSON request on stdin, a short summary on stdout).

## 2. How it works

- **The worker side** (`cjt-exec`, a small sh script) holds no key and opens no connection. It writes a request
  into its own folder, `<worker folder>/.cjt-exec/out/<id>.req` (host, command, working folder, timeout). stdin
  goes in a sibling `<id>.in`, which the bridge pipes in unchanged. The worker then waits for
  `<worker folder>/.cjt-exec/in/<id>.done`. `.cjt-exec/` is git-ignored.
- **The bridge** (`cjt-execd`, a launchd agent running as Claudio on the Mac, outside every sandbox) handles each
  request in this order:
  1. Find out who is calling (below).
  2. Check the grant.
  3. Check the refusals (section 5).
  4. Log.
  5. Run it: `ssh -o BatchMode=yes <alias> -- <command>` with Claudio's keys and aliases, or locally for `mac`.
  6. Log the exit code and write the result.
- **Who is calling comes from the folder, never from the worker.** The worker only gives a command. The bridge finds
  the request in a folder and asks `~/Robots/kit/bin/tero-workers owner <path>` (with `KIT_MILESTONES` set).
  - Exit 0 gives the worker id: the innermost roster folder holding the path.
  - Exit 1 is logged as `REFUSED who: <why>`. Reasons: no owner, two workers sharing the folder, a robot or a worker
    that may not run, or another worker's profile able to write the path.
  - `owner` builds about 70 profiles per call. Its time is measured on the Mac at build time. If it is too slow,
    Workbench caches the profiles per dispatcher tick, so there is one implementation, not a cache in the bridge.
  - This works for sessions started by `tero-run` and for sessions Claudio opens himself. Workbench dropped the token
    idea (161500Z).
  - **It holds only once Workbench's step 2 is in** (perms.py). Today three worker folders sit inside another
    worker's: `bdlt-doc-widgets` in `bdlt-doc-beamer`, `bdlt-chain-blockscape-phones` in
    `bdlt-chain-blockscape-lab`, and the Condor robots in `cjt-condor-dev`. The outer worker could write the inner
    one's requests. The fix: every profile denies writing `<f>/.cjt-exec/**` for every other worker's folder `<f>`
    inside its own paths, in the Claude Code rules and in the sandbox.
  - **The bridge does not go live before Workbench says that deny is in.** Until then `owner` refuses the two inner
    workers, which is the safe side. `cjt-condor-dev` stays refused while it sits inside `cjt-condor`'s folder.
- **Why files and not a network port:** it works from inside the Mac sandbox and from the VM (through the folder the
  VM mounts). It is the same pattern as Milestones. Keys stay in Claudio's `~/.ssh` and agent on the Mac; workers get
  the bridge, never a key or a key path.
- **Cloud chats** (claude.ai) cannot write Mac folders, so `cjt-exec` does not serve them in this version
  (see section 7).
- **Code:** in the public `cjt-casamia` repo (generic, no hosts or names). The log stays on the Mac only.

## 3. Grants: `~/Robots/tero/grants/cjt-exec.json` (Workbench, kit 08f2a87)

    {"version": 1, "grants": [
      {"worker": "bdlt-lib-utxo", "hosts": ["utxo1", "abacus-2"], "mode": "run",  "ok_by": "Claudio",
       "date": "2026-11-2x", "until": null},
      {"worker": "bdlt-lib-utxo", "hosts": ["mac"],               "mode": "read", "ok_by": "Claudio",
       "date": "2026-11-2x", "until": null}]}

- **The file is in Tero's own folder,** where no worker can write. Tero writes it on Claudio's OK. No grant means no
  access. `until` is inclusive, or null. `run` includes `read`.
- **The check, called before every command:**
  `~/Robots/kit/bin/tero-workers may-exec <worker> <host> <read|run>`. Exit 0 means allowed; exit 1 means refused,
  with the reason on stderr. It refuses when there is no grant or it has ended, when the worker is freed, not started
  or has no folder, and when the file can't be read.
- **How the mode is chosen:** the bridge first asks for `run`; if that is refused, it asks for `read`. That gives
  the mode, and in `read` mode the read-only rules below apply.
  `tero-workers hosts <worker> --json` serves `cjt-exec hosts`.
  - `read`: only read-only commands (`ls cat head tail wc grep find df du ps uptime free nvidia-smi
    git status/log/diff/show`, `tmux ls`), run without a shell (no `; | & > < $( )` and no backticks).
  - `run`: any command except the refusals.
  - **Recommended:** `mac` stays `read`. `run` on the Mac is a complete way out of the worker's sandbox.
- The answer of the check is logged with each command (granted, or refused with the reason).
- bdlt-lib-utxo has no registry entry yet, so the check refuses it until Tero registers it.

## 4. Log (one place)

`~/Library/Logs/cjt-exec/exec.log` on the Mac, append only, one line per request:

    start  end  worker  host  mode  check  result  id  command

- `check` is the answer of `granted` or `refused <why>`.
- `result` is an exit code, `REFUSED <rule>`, `PENDING` or `APPROVED <by>`.
- Full output is in `~/Library/Logs/cjt-exec/out/<id>.out|.err`.
- Workers cannot write there. Tero and the dashboard can read it.
- The tool never deletes anything. Claudio sets the rule for old output.
- The old `logs-local/utxo1-migration.log` (kept since 7 Nov) is copied in unchanged as
  `imported/utxo1-migration.log` when the bridge is installed. The installer runs as Claudio, so it can read the
  log. The original stays where it is.

## 5. Refused, or sent to Claudio through Tero

Never run directly. The bridge refuses the command, tells the worker, and writes a Milestones `request` to Tero
(worker, host, command). On Claudio's OK, Tero writes an approval that the worker cannot write. The bridge then runs
that exact command once and logs `APPROVED claudio`.

- **Deleting:** `rm rmdir unlink shred`, `find -delete` or `-exec rm`, `git clean`, `git reset --hard`,
  `rsync --delete`, `truncate`, `dd of=`.
- **Privilege:** `sudo su doas pkexec`, and any host alias that logs in as root.
- **Pushing:** `git push`, `gh`/`glab` release, pr or repo, `scp rsync sftp` to another host,
  `docker push`, `npm publish`, `twine upload`.
- **Sending:** `mail sendmail msmtp`, `osascript`, and `curl`/`wget` with POST, PUT, `-d`, `-F` or
  `--upload-file`.
- **Keys and the Mac itself:** any path under `~/.ssh` or `~/Library/Keychains`; `ssh` onward from a host;
  `security`, `launchctl`, `defaults write`.
- **From the utxo1 rules** (bdlt-lib-utxo):
  - `crontab`, and `systemctl`/`service` start, stop, enable or disable: no crontab or service changes without Claudio.
  - `pkill -f` and `killall`.
  - Jobs sent to the background with `nohup`, `setsid` or a trailing `&`: long jobs go through `-d`, in a named tmux
    session.

## 5b. Server rules (what the analytics workers ran with, Tero 143212Z)

`cjt-exec` is the transport. The run rules belong to each host's owner, but the bridge applies them, so no worker has
to remember them.

- **Wrapper per host:** the bridge's host list (Casamia's private repo, next to the SSH list) can name a wrapper that
  every `run` command on that host goes through.
  - **ether:** `acc-diag.sh <cmd…>`, called with **no flags** (an 8 GB cap and a 12 GB guard; never a lower `-m`).
    Owner bdlt-lib-account; agreed in 144100Z. It sits at the path bdlt-lib-account gave, and logs to its own
    `acc-runs.log`.
  - **abacus-2:** `guard.sh -c 64 -r 250 -a 100 -d 300 -p /local/scratch/bdlt-blocksci -- <cmd…>`. Owner bdlt-lib-utxo
    (144425Z). It is a draft; it goes to `deploy/guard.sh`.
  - **utxo1:** `guard.sh -c 8 -r 8 -a 6 -d 200 -p /home -- <cmd…>`, from the same owner.
  - **The wrapper's exit codes are passed on:**
    - 137 is logged as `STOPPED guard` (killed by a guard);
    - 75 is logged as `REFUSED host` (`guard.sh` refuses to start when disk is low);
    - any other code is the command's own.
  - Each wrapper is written and kept by the host's owner worker; the bridge only calls it, and changes go through the
    owner.
  - **A host with a grant but no wrapper named runs nothing in `run` mode** until its owner names one. The safe side,
    since ether, abacus-2 and utxo1 all have rules.
  - `bdlt-call` runs under the same wrapper, so each host's rules exist once (bdlt-lib-core takes that into
    `bdlt.core.remote`).
  - The per-host limits table (memory, time, concurrency, quotas) is bdlt-lib-core's `remote.toml`.
    - **Time:** the bridge's timeout per host defaults to that table's `time_cap` (ether 1 h, abacus-2 2 h, utxo1
      30 min).
    - **Concurrency:** per host, from the same table (utxo1 1; ether 2). The bridge queues the rest.
- **Ether is a shared machine:** any `run` there through the bridge needs Claudio's own OK (bdlt-lib-account,
  144100Z), apart from the grant.
- **Long jobs** (`-d`) run in a tmux session named `<worker>-<id>`. A START and END line goes to the job's log, as in
  `run_a1.sh`. Per-index memory limits such as abacus-2's 50 GB stay in the calculation service's code.
- **Code out:** `cjt-exec <host> 'tar -x -C <dir>' < code.tar`. stdin is allowed up to 20 MB, enough for code, never
  data.
- **Results back:** stdout up to 1 MB by default. With `-o <file>`, stdout is written to a file in the worker's own
  `.cjt-exec/in/`, up to 50 MB. Which files may come back (for example no `.npz`) is the calculation service's rule.
- The ether helpers that were never saved are replaced by the calculation service, not by `cjt-exec`.

**What this cannot do:** checking the command text catches mistakes and the obvious cases. It cannot stop a
determined or misled worker that wraps a deletion in `python -c` or a script. The real limits are:
- who is calling, taken from the folder;
- the grants, which decide which hosts a worker reaches at all;
- `read` mode;
- the rights of the account on each host;
- the log.

## 6. Steps

1. Claudio's OK on this page. Tero agrees on the grants file. (Workbench's `owner` and `may-exec` are built.)
2. Build the script, the bridge and its launchd agent (installed by `cjt-casamia` on the Mac only). Test them with
   fake workers and a test grants file (`KIT_EXEC_GRANTS`):
   - `mac` in read mode;
   - the refusal list;
   - the identity check: a request in a folder with no roster row, or in an outer worker's folder, must be refused;
   - stdin and stdout passing through unchanged.
3. Live for `mac` in read mode first, **after** Workbench's step 2 (the `.cjt-exec/` deny in perms.py).
4. Servers: the Mac is on the UZH VPN since 21 Nov (Tero 143916Z), so only Claudio's OK and the steps above are
   missing. utxo1 and ether1 accept only Claudio's key, so they are reached through
   the Mac's aliases. First user: bdlt-lib-utxo on utxo1, replacing `mac.sh`; then abacus-2, replacing `run.sh`.
   - The other users are `bdlt-lib-analytics:utxo` and `bdlt-tools-analysis-studio`. Each needs its own grant from
     Tero. bdlt-lib-utxo first needs its registry entry.
   - The old scripts keep working until then. They then go to `logs-local/_handed-over/`, and nothing is deleted.
5. Skill `cjt-exec` (half a page) through `skills-inbox/` to cjt-skills.

## 7. Open points

- **Claudio** (feedback-needed 143001Z and 160001Z):
  - Is the design OK?
  - Is `mac` read-only by default?
  - What rule for old output?
  - Should the worker key in `bdlt-blocksci/deploy/keys` move behind the bridge? Once `run.sh` is replaced,
    nothing needs it on the worker side.
  - Cloud chats: they would need a network door into the Mac. I recommend not opening one; they keep asking a Mac
    worker, as today.
  - Ether (shared): may workers with a grant run commands there through the bridge, always under `acc-diag.sh`?
    This is the same question bdlt-lib-account asked for the calculation service (141000Z).
- **SSH keys:** if the keys need a passphrase, the bridge needs them loaded in the agent (macOS Keychain); otherwise
  every request fails at once with "key not loaded". UZH hosts without the VPN fail at once with "unreachable (VPN?)".
- **`mac.sh`:** received (141847Z). On the Mac it comes down to `ssh utxo1.bdlt "<cmd>"` plus two log lines, which
  is exactly what the bridge does.
- **`run.sh` and the old log:** no copy needed. The bridge replaces `run.sh`, and the installer copies the log.

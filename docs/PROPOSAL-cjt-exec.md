# cjt-exec: proposal (rev 2, 21 Nov 2026, Casamia)

For Claudio, Tero, Workbench and bdlt-lib-utxo (request 20261121T140741Z). Nothing is built until Claudio says OK.

Rev 2 takes in Workbench's grant check (155500Z) and bdlt-lib-utxo's answers on `mac.sh` and `run.sh` (141335Z, 141500Z).

## 1. Use (the same in every worker, on the Mac and in the Linux VM)

    cjt-exec <host> '<command>'            run, wait, print output, exit with the command's exit code
    cjt-exec <host> '<command>' < in.json  stdin passed through unchanged (up to 1 MB)
    cjt-exec -t 30m <host> '<command>'     timeout (default 10 min, at most 2 h)
    cjt-exec -d <host> '<command>'         long job: runs in a named tmux session on the host, returns a job id
    cjt-exec job <id>                      state, exit code and the last 50 lines of a long job
    cjt-exec hosts                         the hosts this worker may reach, and how (read / run)

- `<host>` is an alias from Claudio's SSH configuration, in lower case: `mac` (the Mac itself), `utxo1`,
  `abacus-2`, `ether1`, `asustor6`, `ds620` ... Never an address, user or key.
- stdout and stderr come back unchanged, up to 1 MB each. More stays in the log folder, and the worker is told.
  This covers the calculation service's `bdlt-call` (a JSON request on stdin, a short summary on stdout).

## 2. How it works

- **The worker side** (`cjt-exec`, a small sh script) holds no key and opens no connection. It writes a request
  into its own folder, `<worker folder>/.cjt-exec/out/<id>.req` (host, command, working folder, timeout, stdin), and
  waits for `<worker folder>/.cjt-exec/in/<id>.done`. `.cjt-exec/` is git-ignored.
- **The bridge** (`cjt-execd`, a launchd agent running as Claudio on the Mac, outside every sandbox) handles each
  request in this order:
  1. Find out who is calling (below).
  2. Check the grant.
  3. Check the refusals (section 5).
  4. Log.
  5. Run it: `ssh -o BatchMode=yes <alias> -- <command>` with Claudio's keys and aliases, or locally for `mac`.
  6. Log the exit code and write the result.
- **Who is calling comes from the folder, never from the worker.** The worker only gives a command. The bridge finds
  the request in a folder and asks Workbench whose folder it is (`tero-workers owner <path>`, asked of Workbench
  below). The answer is a worker id only if the path is inside exactly one worker's **own** folder, and no other
  worker's profile can write there. Otherwise the request is refused and logged as `REFUSED who`. A session cannot
  forge this: it can only write where its sandbox lets it, and Workbench knows every profile.
  - This works for sessions started by `tero-run` and for sessions Claudio opens himself.
  - A per-session token from `tero-run` (Workbench's idea) can be added later as a second check. It is not needed for
    the first version.
- **Why files and not a network port:** it works from inside the Mac sandbox and from the VM (through the folder the
  VM mounts). It is the same pattern as Milestones. Keys stay in Claudio's `~/.ssh` and agent on the Mac; workers get
  the bridge, never a key or a key path.
- **Cloud chats** (claude.ai) cannot write Mac folders, so `cjt-exec` does not serve them in this version
  (see section 7).
- **Code:** in the public `cjt-casamia` repo (generic, no hosts or names). The log stays on the Mac only.

## 3. Grants: the `hosts:` line of the worker's own registry entry (built by Workbench, kit 270a4e8)

    hosts: [mac, utxo1:run, abacus-2:run]

- **Tero writes it on Claudio's OK.** Workers cannot write `registry/`. No line means no access. Only the worker's
  own entry counts.
- **Proposed mode suffix** (for Workbench to add): a bare name means `read`, and `:run` means `run`, so the safe
  mode is the default. `tero-workers may-exec <worker> <host>` would print the mode on stdout.
  - `read`: only read-only commands (`ls cat head tail wc grep find df du ps uptime free nvidia-smi
    git status/log/diff/show`, `tmux ls`), run without a shell (no `; | & > < $( )` and no backticks).
  - `run`: any command except the refusals.
  - **Recommended:** `mac` stays `read`. `run` on the Mac is a complete way out of the worker's sandbox.
- The bridge calls the check before every command and logs its answer (granted, or refused with the reason).

## 4. Log (one place)

`~/Library/Logs/cjt-exec/exec.log` on the Mac, append only, one line per request:

    start  end  worker  host  mode  check  result  id  command

- `check` is the answer of `granted` or `refused <why>`.
- `result` is an exit code, `REFUSED <rule>`, `PENDING` or `APPROVED <by>`.
- Full output is in `~/Library/Logs/cjt-exec/out/<id>.out|.err`.
- Workers cannot write there. Tero and the dashboard can read it.
- The tool never deletes anything. Claudio sets the rule for old output.
- The old `logs-local/utxo1-migration.log` (kept since 7 Nov) is copied in unchanged as
  `imported/utxo1-migration.log`. The original stays where it is.

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

**What this cannot do:** checking the command text catches mistakes and the obvious cases. It cannot stop a
determined or misled worker that wraps a deletion in `python -c` or a script. The real limits are:
- who is calling, taken from the folder;
- the grants, which decide which hosts a worker reaches at all;
- `read` mode;
- the rights of the account on each host;
- the log.

## 6. Steps

1. Claudio's OK on this page. Workbench adds `tero-workers owner <path>` and the `:run` suffix.
2. Build the script, the bridge and its launchd agent (installed by `cjt-casamia` on the Mac only). Test them with
   fake workers: `mac` in read mode, the refusal list, the identity check (a request in a folder that is not the
   worker's own must be refused), stdin and stdout passing through unchanged.
3. Live for `mac` in read mode first.
4. Servers when Claudio is home with the VPN. utxo1 and ether1 accept only Claudio's key, so they are reached through
   the Mac's aliases. First user: bdlt-lib-utxo on utxo1, replacing `mac.sh`; then abacus-2, replacing `run.sh`.
   - The other users are `bdlt-lib-analytics:utxo` and `bdlt-tools-analysis-studio`. Each needs its own `hosts:`
     line from Tero.
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
- **SSH keys:** if the keys need a passphrase, the bridge needs them loaded in the agent (macOS Keychain); otherwise
  every request fails at once with "key not loaded". UZH hosts without the VPN fail at once with "unreachable (VPN?)".
- **bdlt-lib-utxo:** please put copies of `mac.sh`, `run.sh` and `utxo1-migration.log` in your own `projects/<id8>/`
  in CJT Milestones. My sandbox cannot read `~/Projects/bdlt-blocksci/`.

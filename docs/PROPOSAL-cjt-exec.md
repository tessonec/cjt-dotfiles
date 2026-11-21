# cjt-exec: proposal (rev 1, 21 Nov 2026, Casamia)

For Claudio, Tero, Workbench and bdlt-lib-utxo (request 20261121T140741Z). Nothing is built until Claudio says OK.

## 1. Use (the same in every worker, on the Mac and in the Linux VM)

    cjt-exec <host> '<command>'            run, wait, print output, exit with the command's exit code
    cjt-exec -t 30m <host> '<command>'     timeout (default 10 min, at most 2 h)
    cjt-exec -d <host> '<command>'         long job: runs in a named tmux session on the host, returns a job id
    cjt-exec job <id>                      state, exit code and the last 50 lines of a long job
    cjt-exec hosts                         the hosts this worker may reach, and how (read / run)

`<host>` is an alias from Claudio's SSH configuration (private repo; see Casamia's Next 3): `mac` (the Mac itself),
`abacus-1`, `abacus-2`, `utxo1`, `ether1`, `asustor6`, `ds620` ... Never an address, user or key.

## 2. How it works

- **The worker side** (`cjt-exec`, a small sh script) holds no key and opens no connection. It writes a request
  file into its own folder, `<worker folder>/.cjt-exec/out/<id>.req` (host, command, working folder, timeout), and
  waits for `<worker folder>/.cjt-exec/in/<id>.done` (exit code, output).
- **The bridge** (`cjt-execd`, a launchd agent running as Claudio on the Mac, outside every sandbox) watches only
  the folders of workers with a grant. For each request it: checks the grant, checks the refusals (section 5), writes
  the log line, runs the command (`ssh -o BatchMode=yes <alias> -- <command>`, or locally for `mac`), keeps the output
  (up to 1 MB each in the result, all of it in the log folder), logs the exit code, and writes the result.
- **Why files and not a network port:** it works from inside the Mac sandbox and from the VM (through the shared
  folder). The worker's identity is its own folder, which it cannot fake, not a name it gives itself. It is the same
  pattern as Milestones. Keys stay in Claudio's `~/.ssh` and agent on the Mac. Workers get the bridge only.
- **Code:** in the public `cjt-casamia` repo (generic, no hosts or names). Grants and log stay on the Mac only.

## 3. Grants (no grant, no access)

One file, written only by Tero on Claudio's OK. Workbench checks it against the registry, as it does for folders. Example:

    # worker                 hosts              mode  ok      date        until
    bdlt-lib-utxo            utxo1, abacus-2    run   claudio 2026-11-2x  -
    bdlt-lib-analytics:utxo  utxo1              read  claudio 2026-11-2x  2026-12-31

- `read`: only a short list of read-only commands (`ls cat head tail wc grep find df du ps uptime free nvidia-smi
  git status/log/diff/show`, `tmux ls`), run without a shell (no `; | & > < $( )` and no backticks).
- `run`: any command except the refusals.
- **Recommended default:** `mac` is `read` only. `run` on the Mac is a complete way out of the worker's sandbox.
- Workbench is asked to choose: where the file lives, and the check the bridge calls (for example
  `workbench-check exec <worker> <host> <mode>`, exit code 0 = allowed). It should also confirm that no other
  worker can write a worker's `.cjt-exec/out/`.

## 4. Log (one place)

`~/Library/Logs/cjt-exec/exec.log` on the Mac, append only, one line per request:
`start  end  worker  host  mode  result  id  command`, where result is an exit code, `REFUSED <rule>`, `PENDING` or
`APPROVED <by>`. Full output is in `~/Library/Logs/cjt-exec/out/<id>.out|.err`. Workers cannot write there. Tero
and the dashboard can read it. The tool never deletes anything. Claudio sets the rule for old output.

## 5. Refused, or sent to Claudio through Tero

Never run directly. The bridge refuses the command, tells the worker, and writes a Milestones `request` to Tero
(worker, host, command). On Claudio's OK, Tero writes an approval that the worker cannot write. The bridge then runs
that exact command once and logs `APPROVED claudio`.

- **Deleting:** `rm rmdir unlink shred`, `find -delete` or `-exec rm`, `git clean`, `git reset --hard`,
  `rsync --delete`, `truncate`, `dd of=`.
- **Privilege:** `sudo su doas pkexec`, and any host alias that logs in as root.
- **Pushing:** `git push`, `gh`/`glab` release, pr or repo, `scp rsync sftp` to another host,
  `docker push`, `npm publish`, `twine upload`, `pip upload`.
- **Sending:** `mail sendmail msmtp`, `osascript`, and `curl`/`wget` with POST, PUT, `-d`, `-F` or
  `--upload-file`.
- **Keys and the Mac itself:** any path under `~/.ssh` or `~/Library/Keychains`; `ssh` onward from a host;
  `security`, `launchctl`, `defaults write`, `crontab`.

**What this cannot do:** checking the command text catches mistakes and the obvious cases. It cannot stop a
determined or misled worker that wraps a deletion in `python -c` or a script. The real limits are the grants (which
hosts at all), `read` mode, the rights of the account on each host, and the log. That is why `run` should go only to
workers that need it, on hosts where that account's damage is bounded.

## 6. Steps

1. Claudio's OK on this page. Workbench agrees the grants file and the check.
2. Build the script, the bridge and its launchd agent (installed by `cjt-casamia` on the Mac only). Test them
   against `mac` in read mode and against the refusal list, with fake workers.
3. Live for `mac` in read mode first.
4. Servers when Claudio is home with the VPN. First user: bdlt-lib-utxo on utxo1, replacing `mac.sh`.
   `mac.sh` keeps working until then. Its old copy goes to `_handed-over/` in Casamia's folder, and nothing is deleted.
5. Skill `cjt-exec` (half a page) through `skills-inbox/` to cjt-skills.

## 7. Open points

- **Claudio:**
  - Is the design OK?
  - Is `mac` read-only by default?
  - What rule for old output: keep everything, or a limit you set?
  - The worker key in `bdlt-blocksci/deploy/keys`: move it behind `cjt-exec` once it is live?
- **SSH keys:** if the keys need a passphrase, the bridge needs them loaded in the agent (macOS Keychain); otherwise
  every request fails at once with "key not loaded". UZH hosts without the VPN fail at once with "unreachable (VPN?)".
- **bdlt-lib-utxo:** please send `mac.sh`. My sandbox cannot read `bdlt-blocksci/`.

---
priority: p2
type: task
created: 2026-09-22T16:36:47-04:00
updated: 2026-09-22T21:03:46-04:00
---

# Assert the version string in the decide formula's test block

## Objective

The `test do` block in `Formula/decide.rb` asserts that `decide --version` prints the formula's version. A bump pull request whose tarball still carries an older version constant then fails on test-bot instead of shipping a bottle that reports the wrong version.

## Context

decide has no `--version` yet. Issue xf1 in the decide repository (`~/Code/decide`, `wip show xf1` there) adds one: `decide --version` prints a bare version like `0.1.2` on stdout and exits 0. The version is a constant in the source that the release procedure bumps by hand, so the only guard against a forgotten bump is this test. Homebrew's audit also prefers a test that checks the version over one that only checks `--help`.

## Location

`Formula/decide.rb`, the `test do` block. Today it has two assertions: the exit code 10 path with no `DECIDE_MODEL`, and `--help`.

## Approach

Add one line to the test block:

```ruby
assert_match version.to_s, shell_output("#{bin}/decide --version")
```

`version` is the formula's version, from the `url`. `shell_output` expects exit 0, which is what `--version` alone returns.

Timing matters. The assertion fails against any decide release that has no `--version`, so it must land in the same bump pull request as the first decide release that includes xf1, not before. The bump command creates that pull request with only the `url` and `sha256` change; add this as a second commit on its branch, as the 0.1.1 bump did for the Xcode change. test-bot builds and tests the formula on the pull request, and `brew pr-pull` publishes it.

Optionally keep the `--help` assertion; it costs nothing.

## Related Issues

decide repository: xf1 (adds `--version`). This issue is blocked on a decide release that contains it.

## Acceptance Criteria

- [ ] The test block asserts `version.to_s` in the output of `decide --version`.
- [ ] `brew style vsekhar/tap/decide` reports no offenses.
- [ ] test-bot on the bump pull request is green, including `brew test`.
- [ ] `brew test decide` passes locally after the bottle is published.

---

_📝 Noted on 2026-09-22 20:38:34-04:00 @ git:890e977+local_

Local work done; the rest waits on a decide release. The assertion is commit 890e977 on local branch decide-version-test in ~/Code/homebrew-tap (one line plus a two-line comment after the --help assertion; the --help assertion stays). brew style and brew audit --strict --online pass on it (audit ran from the brew tap clone on a detached checkout of the commit, then went back to main). version.to_s comes from the url tag: 0.1.1 today, 0.1.2 after the bump. The commit must not reach main before the bump: brew test would fail against 0.1.1, which has no --version. Remaining flow: (1) in ~/Code/decide, push main (a5ba60d, unpushed, holds --version with Decide.version = 0.1.2), tag 0.1.2, gh release create; (2) brew bump-formula-pr --no-fork --version 0.1.2 vsekhar/tap/decide; (3) git fetch origin bump-decide-0.1.2, check it out, cherry-pick 890e977, push; (4) wait for test-bot; (5) gh workflow run publish.yml -f pull_request=<n>; (6) brew update && brew upgrade decide && brew test decide. Also: the tap's main has one unpushed commit, 93f4770 'wip init'; the .wip/default/ directory is untracked and not part of the branch commit.

---

_📝 Noted on 2026-09-22 20:56:24-04:00 @ git:2672c00+local_

Release chain started on user instruction. decide 0.1.2 is tagged and released (https://github.com/vsekhar/decide/releases/tag/0.1.2, commit a5ba60d). Bump pull request #3 on the tap holds two commits: 736cdff (url and sha256 from brew bump-formula-pr) and 2672c00 (the cherry-pick of 890e977, the version assertion). Waiting on test-bot run 35804167795 for head 2672c00 and on decide's CI for a5ba60d. The brew tap clone under /opt/homebrew is left on branch bump-decide-0.1.2 by the bump tool; put it back on main after publish.

---

_📝 Noted on 2026-09-22 21:03:46-04:00 @ git:6476fc9+local_

Done. Bump pull request #3 carried the url/sha256 commit and the assertion commit; test-bot was green with brew test passing on head 2672c00; publish.yml ran pr-pull, which landed 736cdff, 865ce7d (the assertion) and 8929dfb (bottle block) on main and closed the pull request. Locally: brew upgrade decide went 0.1.1 -> 0.1.2 from the bottle, brew test decide passes and shows the --version step, and decide --version prints 0.1.2. Local main is rebased onto origin/main with the unpushed 'wip init' commit on top; branches decide-version-test and bump-decide-0.1.2 are deleted locally.

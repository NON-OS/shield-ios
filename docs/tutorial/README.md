# The tutorial video

One video, about five minutes, that takes a viewer from the release file to a private send and a
withdrawal: install, create a wallet, receive test NOX, shield it, send it privately, withdraw it.

| File | What it is |
|---|---|
| [script.md](script.md) | the narration, scene by scene, with a running time |
| [shots.md](shots.md) | the shot list, the taps of each scene, and the text the phone should show |
| [captions.srt](captions.srt), [captions.vtt](captions.vtt) | the narration as captions, timed to the script; re-time them to the edit |

## The rules of the take

- **The presenter records every take by hand, on a real phone. No input is automated in a take**: no
  UI test, no script, no simulator standing in for the phone. The Screens UI test
  (`NoxShieldUITests/`) drives a simulator on the build server to check the screens, and none of
  its frames go in the video.
- The recovery words never appear. The app hides them from a recording by itself
  (`Views/PhraseView.swift`); the narration says so on screen rather than working around it.
- The tutorial wallet holds test tokens only. It is destroyed after the last take, and its words
  are never reused.

## What has to be true before the first take

| What | Why | State on 1 October 2026 |
|---|---|---|
| A tagged release on the production pool | the video installs a real release | the first production pool release |
| The release file reachable by a viewer | scene 1 downloads it | decided: releases on the public NON-OS/shield-ios, linked from nonos.software/download; neither carries one yet ([04-install.md](../04-install.md)) |
| A source of test NOX on Sepolia for viewers | scene 3 | sent on request in the NØNOS Telegram group; the app cannot ask for any itself |
| Sepolia ETH on the tutorial account | the approval, the deposit and a self settlement pay Sepolia gas | from any Sepolia faucet |
| The pool busy enough to add 20 notes between the takes | the wait before a private send ([script.md](script.md), scene 5) | depends on the day; the meter on the Shield screen says how many are left |

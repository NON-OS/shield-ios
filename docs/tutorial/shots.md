# Shot list and on-screen steps

Every shot is the presenter's own recording of a real phone, or of a computer for the file check.
Every tap is by hand. The quoted text is what the phone should show at that moment, from the app's sources;
if it shows something else, stop the take and note it.

## Before the first take

1. **Install the release being filmed** once off camera, to know it works, then delete it so scene 1
   installs it fresh.
2. **Allow recording before there is a wallet.** On a fresh install every screen is covered while
   the phone records, with "Hidden while the screen is recorded or shared.", until Settings allows
   it, and Settings needs a wallet (`Views/RootView.swift`, `Core/Recording.swift`). So, off
   camera: Create a wallet, Settings, tap "Screen recording: hidden" until it reads "Screen
   recording: allowed, words and keys hidden", then "Destroy this wallet". The choice survives the
   destruction. Quit the app from the app switcher and open it again, so it reads the choice.
3. **Phone.** Focus on, so no notification lands in the take. Low Power Mode off. Charged above
   50%. Language English. Text size at the default.
4. **Recording.** Control Center, Screen Recording, microphone off; the narration is recorded
   separately and laid over. Start each take on the home screen of the phone.
5. **Funds for scene 3**: Sepolia ETH for gas, and at least 10,000 test NOX, ready to send to the new
   wallet's 0x address.

## Scene 1: install (0:00 to 0:50)

| Shot | Recording | Taps | The screen shows |
|---|---|---|---|
| 1.1 | phone, Safari | open the release page, download `NONOS-<tag>-unsigned.ipa` and its `.sha256` | the two files in Downloads |
| 1.2 | computer screen, or phone in Shortcuts | `shasum -a 256 -c NONOS-<tag>-unsigned.ipa.sha256`, or Generate Hash, SHA-256 | `NONOS-<tag>-unsigned.ipa: OK`, or the same 64 characters as the `.sha256` file |
| 1.3 | phone, SideStore | My Apps, +, choose the `.ipa`, sign in if asked | NØNOS installing, then in My Apps |
| 1.4 | phone, Settings | Privacy & Security, Developer Mode, on, restart. Cut the restart | Developer Mode on |

## Scene 2: create a wallet (0:50 to 1:22)

| Shot | Taps | The screen shows |
|---|---|---|
| 2.1 | open NØNOS | "Shielded NOX. The keys never leave this phone." and "Create a wallet" |
| 2.2 | Create a wallet; confirm with Face ID if asked | "Write these 24 words down." and, because the screen is recording, "The words are hidden while the screen is recorded." |
| 2.3 | hold on the hidden words for the narration, then I have written them down | home, "Wallet" |

The words are written down off camera, after the take, from Settings, Recovery words and keys.

## Scene 3: receive test NOX (1:22 to 1:46)

| Shot | Taps | The screen shows |
|---|---|---|
| 3.1 | none | the account pill, "Sepolia" on the network pill, ETH, NOX and USDC |
| 3.2 | Receive | "Public: anyone can see what this address holds and sends." and the QR code |
| 3.3 | Copy address; send ETH and NOX to it from the funding wallet, off camera | "expires in a minute" by the pasteboard |
| 3.4 | Back, pull down on home | the ETH and NOX balances |

## Scene 4: shield (1:46 to 2:33)

| Shot | Taps | The screen shows |
|---|---|---|
| 4.1 | Shield | the private balances and the four actions: Deposit, Receive, Send, Withdraw |
| 4.2 | Deposit, NOX, type 10000, Review | "Reading the pool", then "First, let the pool take exactly 10000 NOX. Then the deposit." |
| 4.3 | hold on the facts, then Confirm approval, Face ID | "you shield", "pool fee", "the note holds", "network fee, at most"; then "Approval sent. Waiting for a block." |
| 4.4 | wait, cut to the block | "The pool may take it now." |
| 4.5 | Review the deposit, Confirm and shield, Face ID | "Deposit sent. Waiting for a block." |
| 4.6 | wait, cut to the block | "Shielded." and "The note is in the pool. A private send waits for 20 more notes and about six hours after it, which the meter on the shield counts down." |

## Scene 5: the wait (2:33 to 2:51)

| Shot | Taps | The screen shows |
|---|---|---|
| 5.1 | Done, then the Shield screen | the meter: "Ready to spend privately after 20 more notes in the pool and about 6 hours. Spending sooner can be linked by timing." |

End of the first sitting. Do not go early in the video: the scene teaches the wait.

## Scene 6: send privately (2:51 to 4:05)

Off camera first: the account pill, Add an account, then Account 2's Shield, Receive, Copy address,
and back to Account 1. Paste within a minute: the pasteboard is cleared after it.

| Shot | Taps | The screen shows |
|---|---|---|
| 6.1 | Shield | "Ready to spend privately." |
| 6.2 | Send, paste into "To wallet address", type 1000 | "This moves value to Account 2 of this wallet, as a private transfer that pays the relay fee." and "Fee from 2400 NOX, the same for everyone, with a network part that follows gas, paid from the shield." |
| 6.3 | Prove and seal | "Proving." and "On this device, using all 6 cores. Nothing has been sent." with the clock running. Cut the middle of the proof, keep the clock's last seconds |
| 6.4 | none | "Proved and sealed on this phone." and the five steps, the first done |
| 6.5 | Send over Tor | "Handing over Tor", then "Published over Tor. Waiting for the lander." |
| 6.6 | wait, cut between steps | "Scheduled by the lander. Waiting for its turn.", then "Settling on the pool." |
| 6.7 | none | "Settled on the pool.", every step done, and the settlement's hash |
| 6.8 | Done | the Shield screen, the balance less the amount and the fee |

## Scene 7: withdraw (4:05 to 4:42)

Second sitting, once the meter says the change is ready.

| Shot | Taps | The screen shows |
|---|---|---|
| 7.1 | Withdraw | the address filled in, and "A fresh address of this wallet, never used. The words restore it as the next account." |
| 7.2 | type 1000 | "A withdrawal is public: its amount and the address it pays can be seen by anyone." and "Fee: 0.50% of the amount and a network part, paid from the shield." |
| 7.3 | Prove and seal, then Send over Tor | as 6.3 to 6.7 |
| 7.4 | Done, then the account pill, Add an account: the fresh address is the next account's (`fresh_withdrawal_address` in the core). Its Home, pull down | the NOX withdrawn, on that account's public address |

## Scene 8: close (4:42 to 5:05)

| Shot | Taps | The screen shows |
|---|---|---|
| 8.1 | the gear, Settings, Lock now | "This wallet is sealed." and "Unlock" |
| 8.2 | none, on the locked screen | the end card is laid over in the edit |

After the last take: Settings, Destroy this wallet. The tutorial's words are never used again.

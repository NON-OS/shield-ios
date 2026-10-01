# Script

Narration for the tutorial, read by the presenter over a screen recording of a real phone. The running time on the left
of each line is where it starts in the edit; the captions files carry the same lines at the same
times. Words on screen, as the phone shows them, are in quotes in [shots.md](shots.md).

The video is recorded over three sittings, because a private send waits for the pool: day one is
scenes 1 to 5, the send is scene 6 once the meter says ready, and the withdrawal is scene 7 once
the change from the send is ready.

## 1. Open, and install (0:00)

- **0:00** NØNOS Wallet keeps a private balance on Ethereum, and proves every private payment on
  the phone itself. This is the whole path, from the file to a withdrawal.
- **0:10** The shield runs on Sepolia, a test network. Its tokens have no value, and nothing here is
  audited.
- **0:17** The app comes as a file from the release page, with its fingerprint beside it.
- **0:23** Before installing, check the fingerprint. If it doesn't match, stop.
- **0:31** SideStore signs the file with your own Apple ID. In My Apps, tap plus and pick it.
- **0:40** iOS asks for Developer Mode the first time. Turn it on, and the phone restarts.

## 2. Create a wallet (0:50)

- **0:50** Create a wallet. The seed is sealed under a key in the Secure Enclave, and that key
  opens only for you.
- **1:00** These are your 24 recovery words. In this recording they're hidden; the app hides them
  from any recording.
- **1:08** Write them on paper. Not a photo, not a notes app. They are the wallet.
- **1:15** Once they're written down, confirm, and you're home.

## 3. Receive test NOX (1:22)

- **1:22** Home shows the public account, the same 0x address on Sepolia and on Ethereum. We stay on
  Sepolia.
- **1:30** Receive shows that address. Send it a little Sepolia ETH for gas. For test NOX, ask in
  the NØNOS Telegram group, with this address.
- **1:39** Pull down, and the balances arrive.

## 4. Shield (1:46)

- **1:46** Shield is the private side. Deposit moves NOX from the public account into the pool.
- **1:54** Amounts come in standard sizes, so every deposit looks like many others. Ten thousand.
- **2:02** The review shows the pool fee, a quarter of a percent, and what the private note will hold.
- **2:10** NOX needs one approval first, for exactly this amount. Confirm it.
- **2:18** When it's in a block, review the deposit itself, and confirm.
- **2:26** Shielded. The NOX is now a private note, and only this wallet can read it.

## 5. The wait (2:33)

- **2:33** The meter says when the note can move privately: after twenty more notes join the pool,
  and about six hours.
- **2:42** Moving it sooner would let anyone watching link this deposit to the next payment, by
  timing. So we wait.

## 6. Send privately (2:51)

- **2:51** Later, the meter says ready. Send privately.
- **2:57** The recipient gives you a nox1 address. Here it's a second account of this same wallet.
- **3:05** A thousand NOX. The fee is the pool's, the same for everyone, and it's never typed.
- **3:13** Prove and seal. The proof is made here, on the phone, and nothing leaves until it's done.
- **3:22** It takes a minute or two.
- **3:27** The proof goes to the lander over Tor. You can follow each step.
- **3:35** Published. Scheduled. Settling.
- **3:42** Settled. On chain there's no sender, no receiver and no amount.
- **3:50** If it ever sits unlanded for half an hour, ask the lander again, or settle it yourself
  from the public account. That works without anyone else, but it shows your public account next
  to this payment.

## 7. Withdraw (4:05)

- **4:05** The change from that payment waits its own turn. When it's ready, Withdraw.
- **4:12** A withdrawal is public, so the app fills in a fresh address of this wallet, one never
  used before.
- **4:20** A thousand NOX. The fee is half a percent, and a network part.
- **4:27** Prove and seal again, and follow it to settled.
- **4:35** The NOX is back in a public account, at an address with no past.

## 8. Close (4:42)

- **4:42** Lock the wallet from Settings, or just leave the app: it locks itself.
- **4:49** Your words are the only way back. Keep them on paper, and nowhere else.
- **4:56** The guides are in the repository's docs. Sepolia only, not audited, and every proof
  made on your phone.
- **5:05** End.

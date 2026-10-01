# User guide

How to make or restore a wallet, use each screen, and read what a refusal means. Installing the app
is [04-install.md](04-install.md). What the core checks and what it does not is in
[its security status](https://github.com/NON-OS/shield-core/blob/main/docs/20-security-status.md).

> [!WARNING]
> The shield runs on Sepolia, a test network, and its tokens have no value. The public account
> holds real money on Ethereum mainnet. Nothing is audited.

## First run

1. Set a passcode on the phone if it has none. The wallet will not seal a seed without one, and the
   first screen says so.
2. **Create a wallet.** Write the 24 words down on paper while they are on screen, and keep the app
   open until you confirm them. Leaving before that discards the new wallet, which holds nothing
   yet, so the words are never left behind in a backgrounded app.
3. Confirm yourself when the phone asks. The seed is sealed under a key the Secure Enclave holds and
   is released only after that.

**Restore** takes 12, 15, 18, 21 or 24 words, or a private key. After words, the app looks over Tor
for the other accounts they were used with.

Nothing else is needed. There is no proxy app and no server address: the wallet carries its own Tor
client. The first read of the chain starts Tor, which takes longer on a cold start.

If the first screen says the phone shows signs of a jailbreak, it names what it found. The wallet
still works. On a jailbroken phone other code can read its memory and screens, so keep no more in
it than you would lose.

## Home

The account pill at the top shows the active account; tap it to switch or add one. The network pill
chooses Sepolia, a test network, or Ethereum, where money is real. Sepolia is the default. The tile
lists the ETH, NOX and USDC of the public account on that network. Pull down to read it again. The
same 0x address holds money on both networks.

- **Send**: choose the coin, the recipient and the amount, then Review. The core reads the chain
  over Tor, simulates the transfer, and shows what leaves, what arrives, the most the network fee
  can be, the nonce and the chain. Confirm with Face ID, Touch ID or the passcode.
- **Receive**: the 0x address as text and as a QR code.
- **Swap**: on Ethereum only, where the pools are. Choose what you pay and what you receive, the
  amount (Max leaves enough ETH for the fee) and the slippage. The review shows the rate, the least
  that must arrive, the price impact, the route, each pool and every fee. A token going in is first
  approved for the amount and no more. Review the swap again once that is mined.
- **Shield**: the private balances on Sepolia.

## The shield

On Sepolia, Shield shows the NOX and ETH held privately, the privacy meter, and four actions.

**Deposit.** The coin and a standard amount: 1, 2 or 5 followed by zeros, from 1,000 NOX or
0.01 ETH. The core reads the live pool first and refuses what the pool would refuse. The review
shows what you shield, the pool fee of 0.25%, what the note will hold, and the most the network fee
can be. For NOX the pool is first approved for exactly that amount, then the deposit follows. The
note is stored before the deposit leaves, and appears once it is in a block. Deposit from another
wallet shows the transactions to send there instead.

**Receive.** The `nox1` address, about 2,000 characters, because it carries a spend key and a
post-quantum key. Only this wallet can open a note sealed to it. The 0x address is one tap away,
for a faucet or an ordinary send.

**The wait.** A note is spent only after 20 more notes have joined the pool and about 6 hours have
passed since its deposit, because a note moved soon after it lands can be linked to its deposit by
timing. The meter counts both down. On the send screen, typing EARLY skips the wait, and the screen
says what that costs.

**Send privately and Withdraw.** Where to, and a standard amount. The fee is the pool's, the same
for everyone, and nothing about it is typed: for a private transfer it is from 2,400 NOX or
0.003 ETH, the protocol part and the lowest rung of a gas ladder that follows the base fee; a
withdrawal pays 0.50% of the amount and the rung. It is paid from the shield on top of the amount.
A withdrawal is public, so its address is filled in with an unused address of this wallet, and an
address typed in its place is checked for past use.

Prove and seal proves the spend on the phone. It takes a minute or two, uses every core, and can be
cancelled; nothing is sent until it finishes. Keep the app open while it runs: iOS pauses an app
that leaves the screen.

**On its way.** The proved spend is published to the lander over Tor, and the screen follows it in
five steps:

| Step | What it means |
|---|---|
| Proved and sealed on this phone | the proof exists, and nothing has left the phone |
| Published to the lander, over Tor | the lander has it in its queue |
| Scheduled by the lander | the lander has picked its turn |
| Settling on the pool | the settlement is on its way to a block |
| Settled | it is in the pool. The settlement's hash is shown, with Copy the hash |

If the app is closed while it waits, the spend is followed again after the next unlock, on the
Shield screen. After half an hour with no landing the screen offers two ways on: **Ask the lander
again**, or **Settle it yourself**, which sends the settlement from your public account. That
works without anyone else, but it names the public account next to this spend in public. The fee in
the proof comes back to the account that settles it.

**Take back.** When a spend was never settled, this returns every note the chain shows unspent.

**Time a proof on this phone.** The measurement screen: one real transfer proved and verified on
the phone, with its time, its peak memory and the limit iOS ends the app at. [06-measure.md](06-measure.md)
says how a figure is measured for publication.

## Settings

The facts of this install: the app version, the core it was built with, where the key is held, the
route, the lander, and the jailbreak signs found. Below them:

- **Recovery words and keys**: shown only after you are confirmed, and hidden from any recording.
- **Lock now**. The wallet also locks when the app leaves the screen, and after the idle time
  chosen.
- **Screen recording**: hidden by default. Allowed, the screens can be recorded and the words and
  keys stay hidden.
- **Licences**, and **Destroy this wallet**, which removes the sealed seed, the notes and the key.
  Only the recovery words bring it back.

## When something says no

| What the screen says | What it means |
|---|---|
| Amounts come in standard sizes, 1, 2 or 5 followed by zeros, from 1,000 NOX or 0.01 ETH. | the pool takes only standard amounts |
| These notes are still new. Wait, or go early from the send screen. | the wait after a deposit has not passed |
| The pool would not take this fee. Try again in a minute, or update the app. | the fee policy refused the fee read for this spend, usually because gas moved |
| Two notes are needed to send. Receive again first. | a spend needs two notes to prove against |
| This account needs ETH to pay the network fee | the public account holds no ETH on this network |
| Two servers disagree, about the NOX fees or about the pools | the two answers did not match, so nothing was sent. Try again |
| A server answered for the wrong network. Nothing was signed. | an RPC reported another chain id |
| The network could not be reached over Tor. Nothing was sent. | every listed server failed over Tor |
| That review has expired. Review the send again. | a review holds for 90 s |
| The lander refused it: … Settle it yourself, or Take back returns the notes. | the lander would not land this proof, with its reason |
| Not landed yet. Ask the lander again, or settle it yourself. | half an hour passed with no settlement |
| This device no longer has the key that sealed this wallet. Restore from the recovery words. | the key in the Enclave is gone, for example after the passcode was removed |
| The pool has paused deposits. | the pool's owner paused deposits |
| This pool is wound down. Money sent to it could not be spent. | it will never settle again |

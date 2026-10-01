# Measuring a proof on an iPhone

The proving time and the peak memory of one real iPhone, measured the way the core's rule asks,
and reported to the prover team. Nothing here has been measured yet with this build: the figures are
filled in by whoever holds the phone, on the template at the end.

## The rule

The core does not publish a proving time until it is the median of three runs, each proof accepted
by the live verifier, quoted with the device, the build and the thermal state
([the core's README](https://github.com/NON-OS/shield-core#readme), Limits). The app has shipped
a measurement screen for this since the launch circuit: Shield, Time a proof on this phone
(`Views/ShieldMore.swift`, `Views/MeasureView.swift`).

## What the measurement screen reports

| Figure | Where it comes from |
|---|---|
| seconds to prove, witness built, verified here | the core's `bench_proof`, which proves one real transfer on the launch circuit and verifies it (`BenchReport`) |
| circuit, params id, rows, columns, queries, soundness | the proof's own header and shape, so a fast run of the wrong circuit is not quoted (`Views/BenchPlate.swift`) |
| peak since launch | the kernel's high water mark of this process, `ledger_phys_footprint_peak` from `task_info(TASK_VM_INFO)` (`Core/Footprint.swift`) |
| memory limit | the footprint after the proof plus `os_proc_available_memory()`: where iOS ends the app |
| threads | every core, or the count chosen for this launch (`Core/Threads.swift`) |

The card the screen shares carries the same figures, and the phone model, the iOS version, the
thermal state and Low Power Mode at the start and at the end of the run (`State/Measure.swift`,
`Core/Machine.swift`). It holds no key, address, amount or note.

The peak is the highest the app has been since it opened, so the app is quit and opened again
before each run, and the run is the first thing it does.

## The procedure

1. Install the build being measured. Settings shows the app version and the core commit; both go on
   the report.
2. Charge above 50%, turn Low Power Mode off, close other apps, and let the phone cool until it is
   cool to the hand. The card says whether it was.
3. Quit the app from the app switcher and open it again. Unlock.
4. Shield, Time a proof on this phone. Keep the app in front until the plate shows: iOS suspends an
   app that leaves the screen, which stretches the time, and the wallet locks once the run ends
   (`State/Away.swift`).
5. Share the card, and Export the proof.
6. Repeat 3 to 5 twice more, for three runs.
7. On the measurement screen, tap Proving from the next launch until it says 2 threads. Repeat 3 to
   6, for three runs on two threads. Set it back to every core when done.

Each exported proof is checked against the live verifier by the prover team before its time counts,
since "verified here" is the core's own verifier on the phone, not the pool's.

## Deciding the memory question

A first proof was seen near 1.5 GB on a test iPhone. iOS ends an app that passes its limit, and the
limit is lower on a phone with 3 GB of memory, such as an iPhone XR or an iPhone SE of the second
generation, both of which run iOS 18. Two ways out exist, and the measurement chooses:

- **Fewer proving threads.** No entitlement, and it works for the sideloaded build too. It helps
  only if the peak on two threads is clearly lower, which the runs show. Most of a STARK prover's
  memory is usually the trace and its extension, which fewer threads do not shrink, while the
  time grows.
- **The increased memory limit entitlement**, `com.apple.developer.kernel.increased-memory-limit`.
  It raises the limit for the signed build only ([05-distribution.md](05-distribution.md)); the
  sideloaded build cannot rely on it.

The rule, with P the peak, T the median time and L the limit on a 3 GB phone:

1. If P on every core is under 80% of L, change nothing.
2. Else, if P on two threads is under 80% of L and T on two threads is at most 1.5 times T on every
   core, prove on two threads on phones with less than 4 GB, which `ProcessInfo.physicalMemory`
   tells the app.
3. Else, take the entitlement for the signed build, and say on the install page that the
   sideloaded build is not supported on 3 GB phones.

L comes from a 3 GB phone's own card, since the card reports the limit. If no such phone is at hand,
the rule cannot be applied, and the report says so rather than assuming a figure.

## The report to the prover team

Copy this into the prover team's thread, or into `docs/measurements/` as one file per phone, with
the six cards attached.

```text
NØNOS Wallet for iOS: proof on a phone

App            <version from Settings>        Core <commit from Settings>
Phone          <the card's first "where" item: model id, iOS version>
Circuit        <circuit, params id, rows, columns, queries at grind, soundness, from the plate>

Every core (<n> threads)
  run  proved s  built ms  verified here  live verifier  peak MiB  limit MiB  thermal start/end
  1
  2
  3
  median proved s:            max peak MiB:

Two threads
  run  proved s  built ms  verified here  live verifier  peak MiB  limit MiB  thermal start/end
  1
  2
  3
  median proved s:            max peak MiB:

Proof size     <bytes, from the plate>
Low Power Mode off for every run: <yes or no>
Live verifier check: <how each exported proof was checked, and its result>
Memory decision, by the rule in docs/06-measure.md: <1, 2 or 3, and why>
```

## The phase profile for the prover team

The prover team asked for one shape A proof timed phase by phase on a real phone: five runs in a row,
the first cold, on the release build, screen on, app in front. The core is adding the call
(`core-next`): it proves the pinned vector `transfer-eth` deterministically, times the prover's
eleven phases with a monotonic clock, takes a thread count, and says whether the proof matched the
vector byte for byte. The app adds what only it can read: the footprint after each run, the high
water mark since launch (which is the first run's alone), the limit iOS ends the app at, the RAM,
and the thermal state before and after. A run that ends serious or critical is kept and marked.

The request names its devices: the oldest iPhone
the app supports, which with iOS 18 as the floor (`project.yml`) is an iPhone XS or XR, the XR with
3 GB, plus one current model. Its peak is `phys_footprint` read right after the call, which the
table names "peak"; the kernel's high water mark is beside it as "hwm". The prover team's server reference
is 35.8 s on 6 cores and 50.9 s on 4, Fri more than half of it, and the question is whether a phone
proves under 45 s, and if not, whether Fri or Region and Products take the time.

Ready on `ios-next`: the run and its table as text for the share sheet (`Profile/ProfileRun.swift`,
`Profile/ProfileTable.swift`, `NoxShieldTests/ProfileTests.swift`). The screen and the five-run loop
follow once a core with the profiling call is pinned.

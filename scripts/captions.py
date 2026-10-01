#!/usr/bin/env python3
"""The tutorial's captions, written from its script, so the two never say different things.

Each narration line of docs/tutorial/script.md starts with its time, `- **m:ss** text`, and lasts
until the next line starts. A line too long for one caption is cut between sentences, or at words
when one sentence is too long, into captions of at most two rows of 42 characters, sharing the
line's time by length. The last line ends at the time of the final `End.` line. After the video is
edited, change the times in the script and run this again:

    scripts/captions.py docs/tutorial/script.md docs/tutorial/captions
"""

import re
import sys
import textwrap

ROW = 42
GAP = 0.2


def lines(script):
    """The narration as (start in seconds, text), in order, the end marker included."""
    out = []
    current = None
    for raw in open(script, encoding="utf-8"):
        found = re.match(r"- \*\*(\d+):(\d\d)\*\* (.*)", raw.rstrip())
        if found:
            current = [int(found[1]) * 60 + int(found[2]), found[3]]
            out.append(current)
        elif current and raw.startswith("  ") and raw.strip():
            current[1] += " " + raw.strip()
        else:
            current = None
    return out


def chunks(text):
    """The line as captions of at most two rows, cut between sentences where one fits."""
    out, current = [], ""
    for sentence in re.split(r"(?<=[.!?])\s+", text):
        joined = (current + " " + sentence).strip()
        if len(textwrap.wrap(joined, ROW)) <= 2:
            current = joined
            continue
        if current:
            out.append(current)
        rows = textwrap.wrap(sentence, ROW)
        while len(rows) > 2:
            out.append(" ".join(rows[:2]))
            rows = rows[2:]
        current = " ".join(rows)
    if current:
        out.append(current)
    return [textwrap.wrap(c, ROW) for c in out]


def captions(narration):
    """(start, end, rows) for every caption, a long line split into several."""
    out = []
    for (start, text), (following, _) in zip(narration, narration[1:]):
        chunks_of_line = chunks(text)
        total = sum(len(" ".join(c)) for c in chunks_of_line)
        at = float(start)
        for chunk in chunks_of_line:
            length = (following - start - GAP) * len(" ".join(chunk)) / total
            out.append((at, at + length, chunk))
            at += length
    return out


def stamp(seconds, comma):
    ms = round(seconds * 1000)
    text = f"{ms // 3600000:02}:{ms // 60000 % 60:02}:{ms // 1000 % 60:02}.{ms % 1000:03}"
    return text.replace(".", ",") if comma else text


def main():
    script, stem = sys.argv[1], sys.argv[2]
    cues = captions(lines(script))
    with open(stem + ".srt", "w", encoding="utf-8") as srt:
        for n, (start, end, rows) in enumerate(cues, 1):
            srt.write(f"{n}\n{stamp(start, True)} --> {stamp(end, True)}\n")
            srt.write("\n".join(rows) + "\n\n")
    with open(stem + ".vtt", "w", encoding="utf-8") as vtt:
        vtt.write("WEBVTT\n\n")
        for start, end, rows in cues:
            vtt.write(f"{stamp(start, False)} --> {stamp(end, False)}\n")
            vtt.write("\n".join(rows) + "\n\n")
    print(f"{len(cues)} captions from {script}")


if __name__ == "__main__":
    main()

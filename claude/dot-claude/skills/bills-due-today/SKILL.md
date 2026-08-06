---
name: bills-due-today
description: Report bills and deposits hitting the bank account today, plus unpaid stragglers from earlier this month, read from the budget file in the vault. Auto mode is silent and runs as part of /daily-checks. Interactive mode (default) gives a fuller listing.
argument-hint: "[--auto]"
allowed-tools: Read, Bash
---

# Bills Due Today

Read-only report of today's bank activity, pulled from `~/Vaults/Notes/3-areas/finances/budget-and-bills-paid.md`. Never edits that file.

Two modes, depending on argument:

- **`--auto`**: Silent run. Emits a single summary line. No prompts.
- **No argument (interactive)**: Fuller listing with running-balance context, plus a nudge if any matched entry still carries a `$???`/`TBD` placeholder.

## Argument parsing

If `$ARGUMENTS` contains the literal token `--auto`, run in **auto** mode. Otherwise run in **interactive** mode.

## Source file shape

`## Current Budget` is a nested bullet list, not headings: `* <year>` → `    * <Month> (optional parenthetical)` → `        * <item>`. Months run reverse-chronologically and are not contiguous — don't assume every month is present. Parse the month bullet's leading word only (e.g. `August (the 8th month)` and `August` both mean August).

Item bullet grammar (the common case): `[**status** ]<date>: <amount> (<payee>)[ — extra prose][ → **<balance>**]`.

- **Dates**: `Aug 13`, `July 20`, `Sep 4 (Fri)`. Fuzzy forms also occur: `Aug 27ish`, `Aug 21 or 22`, `Aug 7 or ASAP`, `Aug 7, 6am` — these should still match if today falls within or on the named day(s).
- **Amounts**: leading `-$` is a debit, bare `$` or `+$` is a credit, `-$???` is an unknown-amount debit.
- **Paid status**: bold inline prose *before* the date — `**paid**`, `**paid (but on the 24th)**`, `**partially paid**`, `**overdue**`, etc. No marker means unpaid/projected.
- **Cancellations**: `~~struck-through~~` entries are superseded — exclude them entirely.
- **Non-transaction bullets at the same indent** — exclude these: `Starting balance: …`, `**reconciled <date>**: …`, `**Balance: $… ** (as of …)`, `**done** TODO: …`, and similar notes that aren't a dated line item.

## Procedure

1. Resolve today's date with `date +"%Y-%m-%d %B %-d"` (gives ISO date, full month name, and day-of-month).
2. Read the budget file. Find `## Current Budget`, then the bullet matching the current year, then the bullet matching the current month name.
   - If the current month isn't present, that means nothing has been entered yet this month — report `No bills due today (no <Month> entries yet).` and stop.
3. Walk that month's item bullets (excluding struck-through and non-transaction lines per above). For each, determine:
   - **Due today**: date matches today, exactly or as one option in a fuzzy range/OR.
   - **Overdue**: date is earlier than today this month, and the item has no paid marker (unpaid or explicitly flagged `**overdue**`/`**confirmed late, unpaid**` etc).
   - Otherwise: not relevant, skip.
   - Items already marked `**paid**` (in any form) are done — never report them, even if dated today or earlier.
4. Within the relevant set, split into debits (bills) and credits (deposits/income).
5. Tag any date that came from a fuzzy form (see above) as approximate in the output.

## Auto output

One line, built from whichever of these three clauses are non-empty (omit empty ones, join with a space):

- `Bills due today: <debit>, <debit>, ….` — debits due today, firm dates first then approximate ones marked `~<date>`.
- `Overdue: <debit> (due <date>), ….` — debits carried from earlier this month, unpaid.
- `Incoming today: <credit>, <credit>, ….` — credits due today.

If all three are empty: `No bills due today.`

Example: `Bills due today: -$561 (Apple Card), ~-$241 (UMCU Visa). Incoming today: $1,250 (DMP).`

## Interactive output

Same lookup, rendered as a bulleted list grouped under "Due today", "Overdue", and "Incoming today" headings (omit empty groups), each bullet showing date, amount, payee, and running balance if present. After the listing, if any matched entry's amount or balance is `$???` or `TBD`, add a line: `Note: <payee> still shows a placeholder amount — fill in the real number in the budget file when known.`

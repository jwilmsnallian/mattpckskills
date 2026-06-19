# Findings report

The consolidated findings rendered as a single self-contained HTML file in the OS temp directory — the at-a-glance artifact for triage and sharing. Nothing lands in the repo.

## Mechanics

Resolve the temp dir from `$TMPDIR`, falling back to `/tmp` (`%TEMP%` on Windows). Write to `<tmpdir>/dotnet-code-review-<timestamp>.html` so each run gets a fresh file. Then open it — `open <path>` (macOS), `xdg-open <path>` (Linux), `start <path>` (Windows) — and tell the user the absolute path.

Styling comes from **Tailwind via CDN**. Use **Mermaid via CDN** only where a diagram genuinely earns its place (e.g. a sequence illustrating a race condition). This is a dashboard, not a slide deck — favour a dense, scannable layout over decorative visuals.

## Scaffold

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <title>.NET code review — {{repo name}} — {{date}}</title>
    <script src="https://cdn.tailwindcss.com"></script>
  </head>
  <body class="bg-stone-50 text-slate-900 font-sans">
    <main class="max-w-5xl mx-auto px-6 py-10 space-y-8">
      <header>...</header>                 <!-- title, date, severity tally -->
      <section id="summary">...</section>  <!-- findings-per-auditor breakdown -->
      <section id="findings">...</section> <!-- one card per finding, grouped by severity -->
    </main>
  </body>
</html>
```

## Header + summary

- Repo name and review date.
- Severity tally as coloured pills with counts: CRITICAL (red), HIGH (orange), MEDIUM (amber), LOW (slate).
- A compact table or bar of findings-per-auditor, so the reader sees where the risk concentrates.

## Finding cards

One card per CRITICAL/HIGH/MEDIUM finding, grouped under a severity heading, sorted most-dangerous-first (mirror the Consolidated Priority List). Collapse all LOW findings into a single trailing table (ID, title, file) — don't give each its own card.

Each card shows:

- **ID + severity badge** (e.g. `C01`, red) and **title**.
- **File** — `font-mono text-sm`, `path:line-range`.
- **Auditor(s)** — which auditor(s) found it.
- **What's wrong** — one or two sentences.
- **Impact** — what breaks in production.
- **Fix** — the concrete fix; render any code in a `<pre>`.

Keep prose tight. The card is a reference the reader scans, not an essay.

This shares the self-contained-HTML / temp-dir / open-it approach used by [`/improve-codebase-architecture`](../../engineering/improve-codebase-architecture/HTML-REPORT.md); see that file for richer diagram patterns if a finding genuinely needs one.

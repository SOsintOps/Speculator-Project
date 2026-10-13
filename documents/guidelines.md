# Analysis Guidelines

How the analytic method applies to an investigation run on Speculator. The method itself (analytic standards, OSINT methodology, analytic techniques, estimative language, source evaluation and report writing) is kept in one place for all the SOsintOps tools, the [Intelligence Field Notes](https://github.com/SOsintOps/intelligence-field-notes): personal notes, shared for convenience and with no claim to be exhaustive. A copy for offline use is in [`documents/field-notes/`](field-notes/README.md). This page covers only what is specific to Speculator; its sister project [Argos](https://github.com/SOsintOps/Argos) follows the same rules on Ubuntu Budgie.

## The Common Method
| Read | For |
| :--- | :--- |
| [Analytic Standards](field-notes/analytic-standards.md) | The intelligence cycle and the ICD 203 standards every product must meet |
| [OSINT Methodology](field-notes/osint-methodology.md) | The OSINT cycle, the 5W1H method, collection discipline and OPSEC |
| [Analytic Techniques](field-notes/analytic-techniques.md) | Biases, key assumptions check, ACH, deception |
| [Estimative Language](field-notes/estimative-language.md) | Likelihood terms and confidence levels, and how not to mix them |
| [Source Evaluation](field-notes/source-evaluation.md) | The UNODC 4 x 4 grading used in the Speculator templates |
| [Report Writing](field-notes/report-writing.md) | BLUF, structure, prose, checklist; see also [Writing the report with Speculator](report-writing.md) |

## The Standards in a Speculator Investigation
Speculator keeps the record that the standards require; the judgement stays with the analyst.

| Standard | Where Speculator helps |
| :--- | :--- |
| Describe the quality of sources and method (tradecraft 1) | Every search writes a session log in `~/Downloads/evidence/<target>/logs/` with the tools selected, the exact commands, their output and exit codes. The source table of every template has columns for the evidence folder, the SHA-256 and the 4 x 4 grade. |
| Express uncertainty (tradecraft 2) | The templates print the confidence levels and the likelihood row to use, so that the wording is the same in every report. |
| Separate information from judgement (tradecraft 3) | The evidence folder holds raw tool output, never edited. Notes, leads and draft judgements go in the CherryTree case notebook (`Speculator_Case_Notebook.ctd`); the report keeps findings and judgements in separate sections. |
| Analysis of alternatives (tradecraft 4) | Add a "Hypotheses" node to the case notebook and keep the ACH matrix there; Quaesitor draws hypothesised links dashed, apart from confirmed ones. |
| Explain change (tradecraft 7) | Reports carry a reference and a date; a later report quotes the reference it updates. |
| Visual information (tradecraft 9) | Quaesitor and Flowsint (under **Frameworks**) for link charts, Google Earth Pro for places. A chart is an annex of the written report, never a substitute. |
| Based on all available sources | The research log (`Speculator_Research_Log.csv`) records every search, including those that found nothing, so the gaps are visible. |

## Hash What You Cite
Speculator does not hash its output for you. Before a file is cited in a report, record its SHA-256 in the evidence folder:

```bash
cd ~/Downloads/evidence/<target>
find . -type f ! -name SHA256SUMS -exec sha256sum {} + > SHA256SUMS
sha256sum -c SHA256SUMS      # later: proves nothing has changed
```

## Tool Output Is a Lead, Not a Source
Most Speculator tools return pointers, not facts. Grade what the pointer leads to, after you have opened and captured it:
- **Username and e-mail tools** (Maigret, Sherlock, Blackbird, Holehe, Social Analyzer, WhatsMyName and the rest of *Person*): a "found" is a site that answered; it says nothing about who owns the account. Open the profile, capture it, then decide whether it is the same person and with what confidence.
- **Breach lookups** (h8mail and similar): third-party claims about a leak. Grade the service as the source and the data as information it does not know personally (`4` unless corroborated).
- **Domain tools** (Amass, Subfinder, theHarvester, Fierce): records from registries, DNS and scanners. The registry is usually a reliable source; what a registrant declared about themselves is their claim.
- **Media and metadata** (yt-dlp, Gallery-dl, Instaloader, ExifTool, Carbon14): the file is first-hand, its metadata can be stripped or forged. Corroborate dates and places before using them.

## OPSEC on the Speculator Virtual Machine
The general rules are in [OSINT Methodology](field-notes/osint-methodology.md#operational-security-opsec-best-practices). On Speculator in particular:
- Take a clean snapshot of the virtual machine after installation and return to it between unrelated cases.
- Use Firefox ESR with research accounts only; tools that borrow browser cookies (yt-dlp `--cookies-from-browser`) take that identity with them.
- Brave and Tor Browser are installed for separation: one persona per browser profile, never mixed.
- Keep `~/Downloads/evidence` on an encrypted disk, and move closed cases off the virtual machine.

## Further Reading
The full list, with a link for every text, is the [Reading List](field-notes/reading-list.md). The essentials:
- **"Psychology of Intelligence Analysis"** by Richards J. Heuer Jr. (CIA, 1999). [PDF](https://www.cia.gov/resources/csi/static/Pyschology-of-Intelligence-Analysis.pdf)
- **"ICD 203: Analytic Standards"** (ODNI). [PDF](https://www.dni.gov/files/documents/ICD/ICD-203.pdf)
- **"Criminal Intelligence: Manual for Analysts"** by Howard Atkin (UNODC, 2011). [PDF](https://www.unodc.org/documents/organized-crime/Law-Enforcement/Criminal_Intelligence_for_Analysts.pdf)
- **"Structured Analytic Techniques for Intelligence Analysis"** by Randolph H. Pherson and Richards J. Heuer Jr. (CQ Press / SAGE). [SAGE](https://www.sagepub.com/en-us/cab/structured-analytic-techniques-for-intelligence-analysis/book255432)
- **"OSINT Techniques"** (11th edition) by Michael Bazzell and Jason Edison. [IntelTechniques](https://inteltechniques.com/book1.html)
- **"Extreme Privacy"** (5th edition) by Michael Bazzell. [IntelTechniques](https://inteltechniques.com/book7.html)
- **"Deep Dive: Exploring the Real-World Value of Open Source Intelligence"** by Rae L. Baker (Wiley, 2023). [Wiley](https://www.wiley.com/en-us/Deep+Dive%3A+Exploring+the+Real+world+Value+of+Open+Source+Intelligence-p-9781119933243)

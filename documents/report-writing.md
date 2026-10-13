# Writing the Report with Speculator

The rules of the report (bottom line up front, structure, facts versus judgements, estimative language, prose, release checklist) are in [Report Writing](field-notes/report-writing.md), the copy shipped with Speculator of the page in the [Intelligence Field Notes](https://github.com/SOsintOps/intelligence-field-notes). This page says which Speculator template to use and how to fill it.

## Which Template
The installer copies the templates to `~/Documents/Speculator/templates`; the sources are in [`templates/`](../templates/).

| Product | Template | When |
| :--- | :--- | :--- |
| Full report | `Speculator_Report_Full.docx` | The complete written product of a case: bottom line, tasking, key findings, subject overview, narrative, timeline, analysis, recommendations, sources |
| Executive summary | `Speculator_Report_Executive.docx` | One or two pages for a decision maker; the full report stays in the case |
| Plain report | `Speculator_Report_Plain.md` | A shorter report in Markdown (bottom line, findings, details, sources, method) |
| Subject profile | `Speculator_Subject_Profile.docx` | One person or organisation, attribute by attribute, each with source and confidence |
| Event assessment | `Speculator_Event_Assessment.docx` | The risk around an event or a date: bottom line first, then indicators |
| Threat notice | `Speculator_Threat_Notice.docx` | A short alert to paste into chat or e-mail: what, where, when, who, grade, recommendation |
| Case cover sheet | `Speculator_Case_Cover_Sheet.docx` | The front page of the case, with the chain of custody of the evidence |
| Online investigations policy | `Speculator_OSINT_Policy.docx` | The rules your team works under: authorisation, accounts, OPSEC, retention |

## Filling It In
- **Bottom line first, written last.** Draft the findings, then write the three to five sentences that cover them.
- **Findings table:** one finding per row, its confidence (High, Moderate, Low) and the references of its sources (`S1`, `S2`). A finding with no source reference is a judgement: move it to the analysis.
- **Sources table:** one row per source with the URL or origin, the capture time in UTC, the evidence folder (`~/Downloads/evidence/<target>/`, with the session log in `logs/`), the SHA-256 of the file (see [Hash what you cite](guidelines.md#hash-what-you-cite)) and the **4 x 4 grade** (see [Source Evaluation](field-notes/source-evaluation.md)).
- **Likelihood words:** only the ICD 203 row printed in the template (almost no chance, very unlikely, unlikely, roughly even chance, likely, very likely, almost certain), and never in the same sentence as a confidence level.
- **Method and limitations:** the Speculator version, the collection window, the research environment, and what you did not search.
- **Annexes:** export Quaesitor or Flowsint charts to PDF and attach them; the chart supports the report, it does not replace it.
- **Before release:** run the checklist in [Report Writing](field-notes/report-writing.md#checklist-before-release), set the handling marking in the header, delete the grey guidance notes.

## Templates Written Before 0.11.1
Templates installed before 0.11.1 grade sources on the 6 x 6 scale (A to F, 1 to 6). Copy the new ones from `templates/` in the repository to `~/Documents/Speculator/templates`; to convert grades already written, see [Converting from the 6 x 6 system](field-notes/source-evaluation.md#converting-from-the-6-x-6-admiralty-system).

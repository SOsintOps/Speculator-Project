# Frequently Asked Questions (FAQ)

Frequently asked questions about the Speculator Project — installation, the tools, analysis and reporting, and the project itself.

## Table of Contents

* [Introduction](#introduction)
    * [What is the Speculator Project?](#what-is-the-speculator-project)
    * [Who is this project for?](#who-is-this-project-for)
* [Legal and Disclaimer](#legal-and-disclaimer)
    * [What is the licence for this project?](#what-is-the-licence-for-this-project)
* [Getting Started and Resources](#getting-started-and-resources)
    * [What operating system is required?](#what-operating-system-is-required)
    * [Can the Speculator Project be used for investigations?](#can-the-speculator-project-be-used-for-investigations)
    * [Do you provide pre-configured virtual machines?](#do-you-provide-pre-configured-virtual-machines)
    * [How can I prepare a Debian virtual machine?](#how-can-i-prepare-a-debian-virtual-machine)
    * [Is this project designed for digital forensics too?](#is-this-project-designed-for-digital-forensics-too)
    * [I don't know anything about OSINT. Where should I start?](#i-dont-know-anything-about-osint-where-should-i-start)
* [Tools: Usage and Customisation](#tools-usage-and-customisation)
    * [Why does Firefox take a long time to start the first time after installation?](#why-does-firefox-take-a-long-time-to-start-the-first-time-after-installation)
    * [How is Firefox hardened, and can I change it?](#how-is-firefox-hardened-and-can-i-change-it)
    * [What tools are included in the Speculator Project?](#what-tools-are-included-in-the-speculator-project)
    * [How can I learn to use the installed tools?](#how-can-i-learn-to-use-the-installed-tools)
    * [Where are the results saved?](#where-are-the-results-saved)
    * [Why does Mr.Holmes open in a terminal?](#why-does-mrholmes-open-in-a-terminal)
    * [Can I modify the script for my own needs?](#can-i-modify-the-script-for-my-own-needs)
    * [Can I propose other scripts for OSINT?](#can-i-propose-other-scripts-for-osint)
    * [Where can I learn about customising Zenity scripts?](#where-can-i-learn-about-customising-zenity-scripts)
* [Analysis and Reporting](#analysis-and-reporting)
    * [Where is the analysis method explained?](#where-is-the-analysis-method-explained)
    * [Which report template should I use?](#which-report-template-should-i-use)
    * [How do I grade a source?](#how-do-i-grade-a-source)
    * [How do I say how sure I am?](#how-do-i-say-how-sure-i-am)
    * [Is a Maigret or Sherlock hit a finding?](#is-a-maigret-or-sherlock-hit-a-finding)
    * [Are there other SOsintOps projects that work with Speculator?](#are-there-other-sosintops-projects-that-work-with-speculator)
* [Affiliation and Development](#affiliation-and-development)
    * [Is this project affiliated with Michael Bazzell?](#is-this-project-affiliated-with-michael-bazzell)
    * [Are you affiliated with any organisations?](#are-you-affiliated-with-any-organisations)
* [Contribution](#contribution)
    * [How can I contribute to the Speculator Project?](#how-can-i-contribute-to-the-speculator-project)
* [Additional Information](#additional-information)
    * [Were AI tools used to create these contents?](#were-ai-tools-used-to-create-these-contents)
    * [Who were the Speculatores?](#who-were-the-speculatores)
    * [Why did you choose this name?](#why-did-you-choose-this-name)

---

## Introduction

### What is the Speculator Project?
It is a Bash script for customising Debian-based virtual machines for OSINT activities. It automates the installation and configuration of tools and produces a standardised environment for intelligence work.

### Who is this project for?
The Speculator Project is designed for OSINT practitioners, researchers, analysts, and professionals in related fields who need a pre-configured and reliable environment for efficient intelligence gathering.

---

## Legal and Disclaimer

### What is the licence for this project?
The Speculator Project is released under the MIT licence. The media files and the few third-party files in the repository are listed, with their licences, in `media/CREDITS.md`. The individual tools it installs are downloaded from their own projects and are subject to their own licences. Review the licensing terms for each tool on its official repository. The Speculator Project does not modify or take responsibility for third-party licensing terms.

---

## Getting Started and Resources

### What operating system is required?
The Speculator Project requires Debian 13 "Trixie" (amd64). While the script might work on other Debian-based distributions, it is only tested and supported on this version.

### Can the Speculator Project be used for investigations?
Yes, it can be used for investigations. However, functionality is not guaranteed, and the tools are provided "as-is." Users assume all responsibility for their use.

### Do you provide pre-configured virtual machines?
No, we do not provide pre-configured virtual machines.

### How can I prepare a Debian virtual machine?
Use VirtualBox. Create a new VM with at least 4 GB of RAM and 50 GB of disk space, then install Debian 13 "Trixie" (amd64) with the GNOME desktop. Install the VirtualBox Guest Additions before running the script (VirtualBox menu > Devices > Insert Guest Additions CD image): they enable shared folders, clipboard sharing and display auto-resize. The installer only checks that they are present. For detailed VM setup instructions, refer to Chapter 8 of [*OSINT Techniques, 11th Edition*](https://inteltechniques.com/book1.html) by Michael Bazzell and Jason Edison.

### Is this project designed for digital forensics too?
No, this project focuses on OSINT. It does not include tools for digital forensic investigations.

### I don't know anything about OSINT. Where should I start?
Resources for beginners:

* **[Criminal Intelligence: Manual for Analysts](https://www.unodc.org/documents/organized-crime/Law-Enforcement/Criminal_Intelligence_for_Analysts.pdf)** by Howard Atkin (UNODC, 2011, free): the basics of criminal intelligence analysis, source evaluation and investigative method.
* **[Deep Dive: Exploring the Real-World Value of Open Source Intelligence](https://www.wiley.com/en-us/Deep+Dive%3A+Exploring+the+Real+world+Value+of+Open+Source+Intelligence-p-9781119933243)** by Rae L. Baker (Wiley, 2023): practical OSINT with real-world case studies.
* **[OSINT Techniques, 11th Edition](https://inteltechniques.com/book1.html)** by Michael Bazzell and Jason Edison: step-by-step instructions for OSINT tools and investigation strategies.
* **[Intelligence Field Notes](https://github.com/SOsintOps/intelligence-field-notes)**: our notes on analytic standards, OSINT method, source evaluation and report writing, with a linked reading list. A copy is in [`documents/field-notes`](field-notes/README.md).

---

## Tools: Usage and Customisation

### Why does Firefox take a long time to start the first time after installation?
This is normal. On the first launch after a fresh installation, Firefox performs initial profile setup, compiles shader caches and indexes extensions. Subsequent launches are fast. If Firefox appears to hang, wait up to two minutes before closing it.

### How is Firefox hardened, and can I change it?
The installer deploys an enterprise policy (`config/policies.json`) to `/usr/lib/firefox-esr/distribution/policies.json`; Firefox ESR reads it at every start and `about:policies` shows what is active. The policy disables telemetry, Studies, Pocket, Firefox Accounts, form history and the password manager; sets Enhanced Tracking Protection to strict and locks it (trackers, cryptominers, fingerprinters, email trackers and suspected fingerprinting); locks the fingerprinting protection (`privacy.fingerprintingProtection`); disables WebRTC, geolocation, camera and microphone, the battery API, DNS prefetching and link prefetching; turns off Google Safe Browsing (every visited address would otherwise be checked against Google); blocks the camera, microphone, location and notification permissions and autoplay; and clears cache, cookies, history and sessions on shutdown. The 18 extensions and the OSINT bookmarks come from the same file. Locked settings cannot be changed in the Settings page or in `about:config`; the Exploratores start page is not locked. Two settings are deliberately absent because Firefox does not let a policy set them: `privacy.resistFingerprinting` (enable it yourself in `about:config` if you want it; it forces the UTC time zone and a fixed window size, which some sites notice) and `beacon.enabled` (uBlock Origin and strict tracking protection block the tracker beacons). To change a locked setting, edit the deployed file and restart Firefox. Brave has its own policy, `/etc/brave/policies/managed/osint.json`, which only force-installs its three extensions; `brave://policy` shows it.

### What tools are included in the Speculator Project?
See the `Tools Included` section of the README for a full and current list of installed software.

### How can I learn to use the installed tools?
Refer to each tool's official documentation. Practical usage examples are covered in [*OSINT Techniques, 11th Edition*](https://inteltechniques.com/book1.html) by Michael Bazzell and Jason Edison and in [*Deep Dive: Exploring the Real-World Value of Open Source Intelligence*](https://www.wiley.com/en-us/Deep+Dive%3A+Exploring+the+Real+world+Value+of+Open+Source+Intelligence-p-9781119933243) by Rae L. Baker.

### Where are the results saved?
In `~/Downloads/evidence/<target>/`, one folder per target (a shortcut called `evidence` is placed on the Desktop). Each search adds a session log in `logs/` with the tools selected, the exact commands and their output; errors are saved there too. The report templates are in `~/Documents/Speculator/templates`.

### Why does Mr.Holmes open in a terminal?
Mr.Holmes asks its questions through its own menus and has no command-line options, so it cannot be run from a Zenity form. Open **Frameworks** and choose Mr.Holmes: it starts in the terminal with its own environment. Recon-ng and Sn0int work the same way; Osintgram, Maigret Web, Changedetection.io, Quaesitor and Flowsint open a web interface on your machine (Flowsint in Docker containers, stopped when you close its window).

### Can I modify the script for my own needs?
Yes. Modify, adapt or expand the script to suit your workflow. If you develop customisations that others would find useful, open an issue or submit a pull request. We may include them in future versions.

### Can I propose other scripts for OSINT?
Yes, contributions are welcome. Please note that not all suggestions can be added immediately.

### Where can I learn about customising Zenity scripts?
Customising Zenity scripts is covered in [*OSINT Techniques, 11th Edition*](https://inteltechniques.com/book1.html) by Michael Bazzell and Jason Edison (page 137). The Zenity reference is installed with it (`man zenity`, `zenity --help-all`); the source and documentation are on the [GNOME GitLab](https://gitlab.gnome.org/GNOME/zenity).

If you are serious about OSINT, reading the book and following Michael Bazzell's courses and podcast are strongly recommended. His material is among the most practical and consistently updated available in the field.

---

## Analysis and Reporting

### Where is the analysis method explained?
In the [analysis guidelines](guidelines.md), which cover what is specific to Speculator, and in the [Intelligence Field Notes](https://github.com/SOsintOps/intelligence-field-notes), the notes on analytic standards, OSINT method, estimative language, source evaluation and report writing shared by all the SOsintOps tools. A copy for offline reading is in [`documents/field-notes`](field-notes/README.md).

### Which report template should I use?
See [Writing the report with Speculator](report-writing.md): full report, executive summary, plain Markdown report, subject profile, event assessment, threat notice, case cover sheet and investigations policy, with what each is for. The full and plain reports keep the key judgements apart from the findings, as the field notes ask.

### How do I grade a source?
With the [UNODC](https://www.unodc.org/documents/organized-crime/Law-Enforcement/Criminal_Intelligence_for_Analysts.pdf) 4 x 4 system printed in every template: the source A, B, C or X, the information 1 to 4, written together as `B2`. The platform is not the source: grade the person or body that produced the information. See [Source Evaluation](field-notes/source-evaluation.md). Templates installed before 0.11.1 used the 6 x 6 scale.

### How do I say how sure I am?
Use one of the [ICD 203](https://www.dni.gov/files/documents/ICD/ICD-203.pdf) likelihood terms printed in the templates (almost no chance, very unlikely, unlikely, roughly even chance, likely, very likely, almost certain) for events, and High, Moderate or Low confidence for your judgements, never both in the same sentence. Facts in the findings table take neither. See [Estimative Language](field-notes/estimative-language.md).

### Is a Maigret or Sherlock hit a finding?
No. It is a lead: a site answered for that username. Open the profile, capture it, and decide with stated confidence whether it belongs to your subject. The same holds for every tool that returns matches or scores. Speculator installs Maigret from the [SOsintOps fork](https://github.com/SOsintOps/maigret), which adds the Maigret Web interface: its results are leads in the same way.

### Are there other SOsintOps projects that work with Speculator?
Yes:
- [Argos](https://github.com/SOsintOps/Argos) is the sister workstation for Ubuntu Budgie 24.04 or 26.04 LTS, with the same templates.
- [Wukong](https://github.com/SOsintOps/Wukong) is the China-focused spin-off of Speculator.
- [Quaesitor](https://github.com/SOsintOps/quaesitor), the case graph, runs under **Frameworks**.
- [Exploratores](https://github.com/SOsintOps/Exploratores), the browser toolkit, is the Firefox start page; [Claudii Exploratores](https://github.com/SOsintOps/claudii-exploratores) offers its catalogue as an agent skill and an MCP server for Claude (alpha).

For particular cases:
- [Elementary CTI](https://github.com/SOsintOps/elementary-CTI) tracks ransomware victims and actors.
- [Aethelburg](https://github.com/SOsintOps/Aethelburg-project) analyses UK company registers for shell companies.
- [TelEgrapherX](https://github.com/SOsintOps/TelEgrapherX) collects Telegram groups and channels; [TGchat-analytics](https://github.com/SOsintOps/TGchat-analytics), the SOsintOps fork of chat-analytics, builds statistical reports from a chat exported from Telegram Desktop (HTML), Chinese, Japanese, Korean and Russian chats included.
- [Acta Diurna](https://github.com/SOsintOps/acta-diurna) monitors Italian law-enforcement news.
- [Il Conclave](https://github.com/SOsintOps/il-conclave), a Claude Code skill in Italian, puts a question through forced analytic procedures (ACH, premortem, steelman) before you commit to a key judgement.

[Codex Machinae](https://github.com/SOsintOps/codex-machinae) is the playbook the projects are built with.

---

## Affiliation and Development

### Is this project affiliated with Michael Bazzell?
No. There is no affiliation, partnership or endorsement of any kind with Michael Bazzell or IntelTechniques.

The Speculator Project is an independent initiative inspired by his book, [*OSINT Techniques, 11th Edition*](https://inteltechniques.com/book1.html), written with Jason Edison. We recommend it as the primary reference for the tools included in this script.

### Are you affiliated with any organisations?
Yes. We are affiliated with osintops.com.

---

## Contribution

### How can I contribute to the Speculator Project?
You can contribute by:

* Reporting bugs or issues
* Submitting pull requests for improvements or fixes
* Suggesting new features or tools

---

## Additional Information

### Were AI tools used to create these contents?
Yes, AI tools were used to assist in creating this project. Rest assured, no AI was overworked during this process.

### Who were the Speculatores?
The Speculatores were ancient Roman scouts and reconnaissance officers who gathered intelligence for military operations. After installation, you will find *A Travelling Speculator* in your Documents folder. Read it to understand the historical background and the thinking behind this project. *A Travelling Speculator* is Sanja Pilipović's article on the stele of the speculator Lucius Blassius Nigellio (*Balcanica* 47, 2016). Further detail is also available in [The Speculatores](speculatores.md), included in the repository.

### Why did you choose this name?
The name "Speculatores" was chosen to honour the intelligence and reconnaissance traditions of the Roman Empire. See [The Speculatores](speculatores.md) for more detail.
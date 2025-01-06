## Frequently Asked Questions (FAQ)

### Indice

1. [Introduction](#introduction)
   - [What is the Speculator Project?](#what-is-the-speculator-project)
   - [Who is this project for?](#who-is-this-project-for)
2. [Legal and Disclaimer](#legal-and-disclaimer)
   - [What is the license for this project?](#what-is-the-license-for-this-project)
3. [Getting Started and Resources](#getting-started-and-resources)
   - [What operating system is required?](#what-operating-system-is-required)
   - [Can the Speculator Project be used for investigations?](#can-the-speculator-project-be-used-for-investigations)
   - [Do you provide pre-configured virtual machines?](#do-you-provide-pre-configured-virtual-machines)
   - [Where can I prepare a Debian virtual machine?](#where-can-i-prepare-a-debian-virtual-machine)
   - [Is this project designed for digital forensics too?](#is-this-project-designed-for-digital-forensics-too)
   - [I don't know anything about OSINT. Where should I start?](#i-dont-know-anything-about-osint-where-should-i-start)
4. [Affiliation and Development](#affiliation-and-development)
   - [Is this project affiliated with Michael Bazzell?](#is-this-project-affiliated-with-michael-bazzell)
   - [Are you affiliated with any organizations?](#are-you-affiliated-with-any-organizations)
5. [Tools: Usage and Customisation](#tools-usage-and-customisation)
   - [What tools are included in the Speculator Project?](#what-tools-are-included-in-the-speculator-project)
   - [Can I propose other scripts for OSINT?](#can-i-propose-other-scripts-for-osint)
   - [Where can I learn about customizing Zenity scripts?](#where-can-i-learn-about-customizing-zenity-scripts)
6. [Contribution](#contribution)
   - [How can I contribute to the Speculator Project?](#how-can-i-contribute-to-the-speculator-project)
7. [Additional Information](#additional-information)
   - [Were AI tools used to create these contents?](#were-ai-tools-used-to-create-these-contents)
   - [Who were the Speculatores?](#who-were-the-speculatores)
   - [Why did you choose this name?](#why-did-you-choose-this-name)

---

### Introduction

#### What is the Speculator Project?

It is a Bash script for customizing Debian-based virtual machines, specifically tailored for OSINT activities. It automates the installation and configuration of various tools, offering a secure and standardized environment for intelligence work.

#### Who is this project for?

The Speculator Project is designed for OSINT practitioners, researchers, analysts, and professionals in related fields who need a pre-configured and reliable environment for efficient intelligence gathering.

---

### Legal and Disclaimer

#### What is the license for this project?

The Speculator Project script itself is currently provided under a license that is still under investigation. However, please note that the individual tools and scripts installed by the Speculator Project are subject to their respective licenses. We encourage users to review the licensing terms of each tool directly on their official repositories or documentation. The Speculator Project does not modify or take responsibility for the licensing terms of third-party software.

---

### Getting Started and Resources

#### What operating system is required?

The Speculator Project requires Debian 12 (stable) or a compatible Linux distribution.

#### Can the Speculator Project be used for investigations?

Yes, it can be used for investigations. However, functionality is not guaranteed, and the tools are provided "as-is." Users assume all responsibility for their use.

#### Do you provide pre-configured virtual machines?

No, we do not provide pre-configured virtual machines.

#### How can I prepare a Debian virtual machine?

We recommend following the instructions provided in *OSINT Techniques, 11th Edition* by Michael Bazzell, specifically in **Chapter 8: OSINT VM Operating Systems**, which details the preparation of the operating system and virtual machine environment.

#### Is this project designed for digital forensics too?

No, this project focuses on OSINT. It does not include tools for digital forensic investigations.

#### I don't know anything about OSINT. Where should I start?

Resources for beginners:

- [Criminal Intelligence: Manual for Analysts](https://www.unodc.org/documents/organized-crime/Law-Enforcement/Criminal_Intelligence_for_Analysts.pdf): This manual offers a foundational understanding of criminal intelligence, with practical guidance for analysts looking to develop their investigative and analytical skills.
- [Deep Dive: Exploring the Real-world Value of OSINT](https://www.raebaker.net/deep-dive): Written by Rae Baker, this book delves into practical OSINT applications with real-world examples, focusing on tools, techniques, and methodologies for effective open-source intelligence gathering.
- [OSINT Techniques, 11th Edition](https://inteltechniques.com/osintbook11/): Authored by Michael Bazzell, this comprehensive guide provides step-by-step instructions for using OSINT tools, tailored techniques, and strategies for conducting investigations.

Resources for beginners:

- [Criminal Intelligence: Manual for Analysts](https://www.unodc.org/documents/organized-crime/Law-Enforcement/Criminal_Intelligence_for_Analysts.pdf)
- [Deep Dive: Exploring the Real-world Value of OSINT](https://www.raebaker.net/deep-dive)
- [OSINT Techniques, 11th Edition](https://inteltechniques.com/osintbook11/)

---

### Affiliation and Development

#### Is this project affiliated with Michael Bazzell?

No, this project is independent, although inspired by Michael Bazzell's work. While this project is independent, it has greatly benefited from the teachings and methodologies of Michael Bazzell. We have adapted his principles to meet our specific needs and tailored the toolset accordingly. Additional tools will be integrated in the future based on evolving requirements. We highly recommend reading his book *OSINT Techniques, 11th Edition* for comprehensive details on using the individual tools.

&#x20;

#### Are you affiliated with any organizations?

Yes, we are affiliated with the OSINT-focused blog [osintops.com](https://osintops.com).

---

### Tools: Usage and Customisation

#### What tools are included in the Speculator Project?

The script installs various tools, categorized by use case:

1. Username and Social Media Investigation: Sherlock, Maigret, WhatsMyName
2. Metadata and Forensics: Metagoofil, ExifTool, MAT2
3. Domain and Web Investigation: theHarvester, Sublist3r, Waybackpy
4. Frameworks: Spiderfoot, Recon-ng

See the [README](https://github.com/SOsintOps/Speculator-Project/blob/main/README.md) for a complete list.

#### Can I propose other scripts for OSINT?

Yes, contributions are welcome. Please note that not all suggestions can be added immediately.

#### Where can I learn about customizing Zenity scripts?

Customizing Zenity scripts is covered in *OSINT Techniques, 11th Edition* by Michael Bazzell (page 137).

---

### Contribution

#### How can I contribute to the Speculator Project?

You can contribute by:

- Reporting bugs or issues
- Submitting pull requests for improvements or fixes
- Suggesting new features or tools

---

### Additional Information

#### Were AI tools used to create these contents?

Yes, AI tools were used to assist in creating this project. Rest assured, no AI was overworked during this process.

#### Who were the Speculatores?

The Speculatores were ancient Roman scouts and reconnaissance officers who gathered intelligence for military operations. More details can be found in the [Speculatores Historical Background](https://github.com/SOsintOps/Speculator-Project/blob/main/document/speculatores.md).

#### Why did you choose this name?

It is a long story. The name "Speculatores" was chosen to honor the intelligence and reconnaissance traditions of the Roman Empire, reflecting the project's mission of providing tools for modern OSINT and intelligence work.


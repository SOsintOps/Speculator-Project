# Frequently Asked Questions (FAQ)

## Table of Contents

* [Introduction](#introduction)
    * [What is the Speculator Project?](#what-is-the-speculator-project)
    * [Who is this project for?](#who-is-this-project-for)
* [Legal and Disclaimer](#legal-and-disclaimer)
    * [What is the license for this project?](#what-is-the-license-for-this-project)
* [Getting Started and Resources](#getting-started-and-resources)
    * [What operating system is required?](#what-operating-system-is-required)
    * [Can the Speculator Project be used for investigations?](#can-the-speculator-project-be-used-for-investigations)
    * [Do you provide pre-configured virtual machines?](#do-you-provide-pre-configured-virtual-machines)
    * [How can I prepare a Debian virtual machine?](#how-can-i-prepare-a-debian-virtual-machine)
    * [Is this project designed for digital forensics too?](#is-this-project-designed-for-digital-forensics-too)
    * [I don't know anything about OSINT. Where should I start?](#i-dont-know-anything-about-osint-where-should-i-start)
* [Tools: Usage and Customisation](#tools-usage-and-customisation)
    * [What tools are included in the Speculator Project?](#what-tools-are-included-in-the-speculator-project)
    * [How can I learn to use the installed tools?](#how-can-i-learn-to-use-the-installed-tools)
    * [Can I modify the script for my own needs?](#can-i-modify-the-script-for-my-own-needs)
    * [Can I propose other scripts for OSINT?](#can-i-propose-other-scripts-for-osint)
    * [Where can I learn about customising Zenity scripts?](#where-can-i-learn-about-customising-zenity-scripts)
* [Affiliation and Development](#affiliation-and-development)
    * [Is this project affiliated with Michael Bazzell?](#is-this-project-affiliated-with-michael-bazzell)
    * [Are you affiliated with any organisations?](#are-you-affiliated-with-any-organisations)
* [Contribution](#contribution)
    * [How can I contribute to the Speculator Project?](#how-can-i-contribute-to-the-speculator-project)
* [Additional Information](#additional-information)
    * [Were AI tools used to create these contents?](#were-ai-tools-used-to-create-these-contents)
    * [Who were the Speculatores?](#who-were-the-speculatores)
    * [Why did you choose this name?](#why-did-you-choose-this-name)

## Introduction

### What is the Speculator Project?
It is a Bash script for customising Debian-based virtual machines for OSINT activities. It automates the installation and configuration of tools and produces a standardised environment for intelligence work.

### Who is this project for?
The Speculator Project is designed for OSINT practitioners, researchers, analysts, and professionals in related fields who need a pre-configured and reliable environment for efficient intelligence gathering.

## Legal and Disclaimer

### What is the license for this project?
The Speculator Project script is currently under licence review. The individual tools it installs are subject to their own licences. Review the licensing terms for each tool on its official repository. The Speculator Project does not modify or take responsibility for third-party licensing terms.

## Getting Started and Resources

### What operating system is required?
The Speculator Project requires Debian 13 "Trixie" (amd64). While the script might work on other Debian-based distributions, it is only tested and supported on this version.

### Can the Speculator Project be used for investigations?
Yes, it can be used for investigations. However, functionality is not guaranteed, and the tools are provided "as-is." Users assume all responsibility for their use.

### Do you provide pre-configured virtual machines?
No, we do not provide pre-configured virtual machines.

### How can I prepare a Debian virtual machine?
Use VirtualBox. Create a new VM with at least 4 GB of RAM and 50 GB of disk space, then install Debian 13 "Trixie" (amd64). The script installs VirtualBox Guest Additions automatically, which enables shared folders, clipboard sharing and display auto-resize. For detailed VM setup instructions, refer to Chapter 8 of *OSINT Techniques, 11th Edition* by Michael Bazzell.

### Is this project designed for digital forensics too?
No, this project focuses on OSINT. It does not include tools for digital forensic investigations.

### I don't know anything about OSINT. Where should I start?
Resources for beginners:

* **Criminal Intelligence: Manual for Analysts**: covers the basics of criminal intelligence analysis and investigative method.
* **Deep Dive: Exploring the Real-world Value of OSINT** by Rae Baker: covers practical OSINT tools and techniques with real-world examples.
* **OSINT Techniques, 11th Edition** by Michael Bazzell: step-by-step instructions for OSINT tools and investigation strategies.

## Tools: Usage and Customisation

### What tools are included in the Speculator Project?
See the `Tools Included` section of the README for a full and current list of installed software.

### How can I learn to use the installed tools?
Refer to each tool's official documentation. Practical usage examples are covered in Michael Bazzell's *OSINT Techniques, 11th Edition* and Rae Baker's *Deep Dive: Exploring the Real-world Value of OSINT*.

### Can I modify the script for my own needs?
Yes. Modify, adapt or expand the script to suit your workflow. If you develop customisations that others would find useful, open an issue or submit a pull request. We may include them in future versions.

### Can I propose other scripts for OSINT?
Yes, contributions are welcome. Please note that not all suggestions can be added immediately.

### Where can I learn about customising Zenity scripts?
Customising Zenity scripts is covered in *OSINT Techniques, 11th Edition* by Michael Bazzell (page 137).

## Affiliation and Development

### Is this project affiliated with Michael Bazzell?
No. There is no affiliation, partnership or endorsement of any kind with Michael Bazzell or IntelTechniques.

The Speculator Project is an independent initiative inspired by his book, *OSINT Techniques, 11th Edition*. We recommend it as the primary reference for the tools included in this script.

### Are you affiliated with any organisations?
Yes. We are affiliated with osintops.com.

## Contribution

### How can I contribute to the Speculator Project?
You can contribute by:

* Reporting bugs or issues
* Submitting pull requests for improvements or fixes
* Suggesting new features or tools

## Additional Information

### Were AI tools used to create these contents?
Yes, AI tools were used to assist in creating this project. Rest assured, no AI was overworked during this process.

### Who were the Speculatores?
The Speculatores were ancient Roman scouts and reconnaissance officers who gathered intelligence for military operations. More details can be found in the `Speculatores Historical Background`.

### Why did you choose this name?
The name "Speculatores" was chosen to honour the intelligence and reconnaissance traditions of the Roman Empire. See the Speculatores Historical Background document for more detail.
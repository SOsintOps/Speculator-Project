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
    * [Where can I learn about customizing Zenity scripts?](#where-can-i-learn-about-customizing-zenity-scripts)
* [Affiliation and Development](#affiliation-and-development)
    * [Is this project affiliated with Michael Bazzell?](#is-this-project-affiliated-with-michael-bazzell)
    * [Are you affiliated with any organizations?](#are-you-affiliated-with-any-organizations)
* [Contribution](#contribution)
    * [How can I contribute to the Speculator Project?](#how-can-i-contribute-to-the-speculator-project)
* [Additional Information](#additional-information)
    * [Were AI tools used to create these contents?](#were-ai-tools-used-to-create-these-contents)
    * [Who were the Speculatores?](#who-were-the-speculatores)
    * [Why did you choose this name?](#why-did-you-choose-this-name)

## Introduction

### What is the Speculator Project?
It is a Bash script for customizing Debian-based virtual machines, specifically tailored for OSINT activities. It automates the installation and configuration of various tools, offering a secure and standardized environment for intelligence work.

### Who is this project for?
The Speculator Project is designed for OSINT practitioners, researchers, analysts, and professionals in related fields who need a pre-configured and reliable environment for efficient intelligence gathering.

## Legal and Disclaimer

### What is the license for this project?
The Speculator Project script itself is currently provided under a license that is still under investigation. However, please note that the individual tools and scripts installed by the Speculator Project are subject to their respective licenses. We encourage users to review the licensing terms of each tool directly on their official repositories or documentation. The Speculator Project does not modify or take responsibility for the licensing terms of third-party software.

## Getting Started and Resources

### What operating system is required?
The Speculator Project requires Debian 13 "Trixie" (amd64). While the script might work on other Debian-based distributions, it is only tested and supported on this version.

### Can the Speculator Project be used for investigations?
Yes, it can be used for investigations. However, functionality is not guaranteed, and the tools are provided "as-is." Users assume all responsibility for their use.

### Do you provide pre-configured virtual machines?
No, we do not provide pre-configured virtual machines.

### How can I prepare a Debian virtual machine?
We recommend following the instructions provided in OSINT Techniques, 11th Edition by Michael Bazzell, specifically in Chapter 8: OSINT VM Operating Systems, which details the preparation of the operating system and virtual machine environment.

### Is this project designed for digital forensics too?
No, this project focuses on OSINT. It does not include tools for digital forensic investigations.

### I don't know anything about OSINT. Where should I start?
Resources for beginners:

* **Criminal Intelligence: Manual for Analysts**: This manual offers a foundational understanding of criminal intelligence, with practical guidance for analysts looking to develop their investigative and analytical skills.
* **Deep Dive: Exploring the Real-world Value of OSINT**: Written by Rae Baker, this book delves into practical OSINT applications with real-world examples, focusing on tools, techniques, and methodologies for effective open-source intelligence gathering.
* **OSINT Techniques, 11th Edition**: Authored by Michael Bazzell, this comprehensive guide provides step-by-step instructions for using OSINT tools, tailored techniques, and strategies for conducting investigations.

## Tools: Usage and Customisation

### What tools are included in the Speculator Project?
The script installs a comprehensive suite of tools for various OSINT tasks. For a complete and up-to-date list of all included software, please refer to the `Tools Included` section of the main README file.

### How can I learn to use the installed tools?
For detailed instructions on how to use each tool, we recommend referring to their official documentation or guides. Additionally, comprehensive usage examples and strategies can be found in Michael Bazzell's *OSINT Techniques, 11th Edition* and Rae Baker's *Deep Dive: Exploring the Real-world Value of OSINT*.

### Can I modify the script for my own needs?
Absolutely. You are encouraged to modify, adapt, or expand the script to best suit your specific workflow and requirements. If you develop improvements or customizations that you believe could benefit the community, we would be grateful if you shared them by opening an issue or submitting a pull request. We may adopt your solutions in future versions.

### Can I propose other scripts for OSINT?
Yes, contributions are welcome. Please note that not all suggestions can be added immediately.

### Where can I learn about customizing Zenity scripts?
Customizing Zenity scripts is covered in *OSINT Techniques, 11th Edition* by Michael Bazzell (page 137).

## Affiliation and Development

### Is this project affiliated with Michael Bazzell?
No. To be perfectly clear, there is no affiliation, partnership, or official endorsement of any kind with Michael Bazzell or IntelTechniques.

The Speculator Project is a completely independent initiative inspired by the work and methodologies presented in his book, *OSINT Techniques, 11th Edition*. We highly recommend this book as a valuable resource for learning how to use the individual tools included in this script.

### Are you affiliated with any organizations?
Yes, we are affiliated with the OSINT-focused blog osintops.com.

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
It is a long story. The name "Speculatores" was chosen to honor the intelligence and reconnaissance traditions of the Roman Empire, reflecting the project's mission of providing tools for modern OSINT and intelligence work.
# Remove Finder Sidebar Facorites

## 🗃️ Archival Notice

**This repository is made public since between Google and Apple they > figured something out and this annoying behaviour stopped > manifasting in early 2022. I'm leaving this up in case if findings in this repository can help anyone.**

## Overview

Objective-C CLI application to get rid of automatically appearing items in the Favorites section of Finder when using Google Drive or OneDrive on MacOS.

![Readme 01](/Readme/Readme%2001.png)

## Installation

Navigate to Releases section in GitHub and download the latest Unix Executable

![Readme 02](/Readme/Readme%2002.png)

Once downloaded, put the file in any folder (I suggest `/Applications` with all other applications)

## Usage

Application has two intended usage scienarios:

1. Automatic usage via Automator
2. Manual usage

### Automatic usage via Automator

Idea of this approach is to run the application without any arguments on every launch. It will remove all sidebar items with `OneDrive` names and all items that include ` - Google Drive` substring anywhere in the name.

🚧 TODO: Explain how to add this to Automator to run on google drive launch.

### Manual usage

🚧 TODO: Describe that it can be ran manually and be bound to a shortcut / automator menu in MacOS
---

name: "Bug Report"
about: "Use this issue template to report a bug with already existing feature"
title: "[BUG] "
ref: "master"
labels:

- bug
- "help wanted"

---

<!--
First of all: thanks for reporting the issue using this tracker. It keeps development work easy.

Please take few minutes to fill this template with all relevant informations.

p.s. Don't forget to change the title.
-->

# Bug description

Use this section to describe the bug with few sentences.

# Steps to reproduce

<!-- 
Steps to reproduce is the most important part of each report. Without knowing how to reproduce a bug chances to fix it are almost zero.
-->

1. Open app
2. Do something
3. **Bug occurs here**

# System Info

<!--
To get OS info:
Linux (in terminal): (. /etc/os-release && echo -n "$PRETTY_NAME "; uname -a)
Android: There is no standard way to determine that so use something like "Android 13, LineageOS 20 Official Build Kernel: 5.4.242-qgki-g4b3283a7d069; OnePlus 9 Pro"
-->
- OS: `Linux`
<!-- 
Which app version did you use?
-->
- App version: `v1.0.0RCx`
<!--
Flavor
- ANON <- main wallet
- NERO <- view-only flavor
- anonero <- flavor with both wallets inside, used mostly for debugging and desktop platforms. In general if either ANON or NERO is affected anonero is also affected.
-->
- Affected versions
  - [x] ANON
  - [ ] NERO
  - [x] anonero

# Wallet creation/restore method

<!--
How did you create/restore your wallet?
-->

- [ ] Restore via polyseed
- [ ] Restore via legacy mnemonic
- [ ] Restored via backup (v0 -> v1)
- [ ] Restored via backup (v1 -> v1)
- [ ] Created

# Logs

<!--
Use adb to obtain logs, and upload them to pastebin (preferably privatebin. Make sure to change expiry to 1 month and disable burn after read).

**NOTE: Logs may contain personal information. It is recommended to reboot your device before gathering logs, type `adb logcat`, wait for it to settle down[1], press enter couple times to mark the place, do the steps to reproduce the bug, and after bug got reproduced hit control + c and copy everything between the few enters you have placed and end of the command output.**
-->

https://privatebin.net/

# Extra informations

<!-- 
Magisk? Self built apk? Anything else? Drop it here.
-->
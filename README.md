# unnamed_monero_wallet

Downloads can be obtained from https://xmruw.net/, CI builds are published to static.mrcyjanek.net/unnamed_monero_wallet.

If you want to test the wallet you can join any of these rooms, messages are bridged.

- [Telegram @xmruw](https://t.me/xmruw)
- [Discord](https://discord.gg/YdM5yTVqed)
- #xmruw:matrix.org
- Other? If you want to moderate another platform I'll be happy to bridge them with rooms above.

Found a bug? Please use Gitea or Github issue tracker to report them.

### Building

Easiest way to build is to use a devcontainer, you can do it by pressing `,` if you are on github, or by using Dev Containers plugin for the IDE of your choice.

Otherwise you need

- flutter (version can be found in `.fvmrc`)

Then just build the app:

- android: `make libs_android_download android`
- x86_64 linux: `make linux FLUTTER_ARCH=x64`

For other platforms just run `flutter build`

### Donations

xmr: `83F5SjMRjE9UuaCUwso8zhix3DJEThnhcF8vTsCJ7zG3KiuKiqbyUshezKjmBwhqiAJP2KvzWNVRYVyBKaqpBwbp1cMD1FU`

# History

This project started as anonero v1.0 rewrite, which due to variety of reasons didn't happen. Now this is a sandbox for experiments, which will hopefully end up as a fairy decent wallet.

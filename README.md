# anonero

> Black box monero app

### Android

Android has first-class support, it should work out of the box in all situations.

### Linux support

Linux support is experimental, to get it to work you need to have compatible `libwallet2_api_c.so` in `/usr/local/lib/`

#### Debian


Install monero_c and anonero repository (it contains all the required stuff)

```bash
sudo curl https://git.mrcyjanek.net/api/packages/mrcyjanek/debian/repository.key -o /etc/apt/trusted.gpg.d/gitea-mrcyjanek.asc
echo "deb https://git.mrcyjanek.net/api/packages/mrcyjanek/debian no-distro main" | sudo tee -a /etc/apt/sources.list.d/anonero-dev.list
sudo apt update
```

Then just install

```
apt install anonero
```
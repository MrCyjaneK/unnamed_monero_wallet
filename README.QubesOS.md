# QubesOS secure setup

QubesOS offers a great security by default, from which `xmruw` wants to benefit. By using offline wallet (that keeps the private keys) and online wallet (which keeps public keys and private view key) you can keep your monero securerly.

Installation consist of two core pieces:
- Offline wallet
- Online wallet

Offline wallet should be installed in a qube that doesn't have access to internet (it's netvm is set to none), if you have already a secure qube like this created (for example `vault` qube that doesn't have any internet access and you already keep all your secrets there) you can reuse it, however I do recommend to create a separate Qube for monero wallet.

Online wallet - this one can be installed anywhere you want. I personally have it installed in my `personal` qube. Online wallet doesn't have any important contents in it - except for transaction history. Depending on your threat model you can use separate qube for it as well.

`xmruw` is distributed as `.tar.xz` and `.deb`. I recommend using `.deb` version because it will allow you to update the software when needed, and because xmruw doesn't make any external calls it is impossible - by design - to check for updates, therefore using debian qube is recommended.

# Setup

Follow this instructions to create a decent setup, similar to what I use

## Template setup

- Create new Template
- Open terminal in Template and type:

```bash
cat > file.txt <<EOF
-----BEGIN PGP PUBLIC KEY BLOCK-----

xsBNBGWVHzMBCADHbUyIVjJ2f7KjM59UCQLdMYaUbVrQenfc2loNCRqFIxkp9FuO
L1paaptD0/QjRPvFY/TfvHaXjU1dV2I3/TOyWkqXQhYSihHnHWrARr8h09HWyWYj
c4199TXy55N3gtjwhUFtz3jIjL7vbjCsMKid+IeWF+gcjFfFu/AjAb8fN0FWVRHb
lj+jyltEDcxeJC3flwMErg3c0I+nOmqRcqKVdcStvdDZB++fH3Tfuwx9dn1TZcd5
eevB7TMGSe0ED5FEU+MZOc3JbNvY1j3UtUp9rmEp4dp6A7YbjQWk/iuvQTXmF2JV
n7juew3Tdtsiuim3Bzk5A5D6MlfAigq2hPlbABEBAAHNJU9sZFBDJ3MgR2l0IEhv
c3RpbmcgKERlYmlhbiBSZWdpc3RyeSnCwGIEEwEIABYFAmWVHzMJEFHaJKJFpAqr
AhsDAhkBAAA3CQgATUju0dUpfVn0qLzLMfDNKyFR/lyne43a0LcsX811T5LnrNTS
6NvOR2uQuKrIKEjsOAB4mGYgmrmU9v+0lOoXsWIkhCWlQ0MLRCwoxCrK3fBQ8K6f
yv4jIeexPoxVHS+ygFZJQm5AUn/M04dA9apuAq7YdZAndJw83mrz1k3f0SqH22el
WRAd2I5G3Otq0uSnub0lIHe1dc4GBXIdFG5Rs59rNtur21IW7XMMXqjoOqONNb76
2dX0W+1rq96oZRxRuM0r+b+PZ3tfd/xfjf5QTAJr7AfswjqlK7AUplA8vUoJ6hXF
J6Zcgl8AXQ/ngAPLO5cRbUpYWRAfY0J8qimufM7ATQRllR8zAQgAvl2msdu/fKed
CjclN19ThXvizYjAx0VgewqcZvGh44V6xr1DKtbRNkPvsHoeDw+FXICSDQ9z9PLQ
o+06wJftBJh6c7Bf1Hegjwasa/IAj5seM259setNroWmVi23qtz3CLsJ82OM0vSw
lfD2yxNgdqHh14jE2l1Neb0LeVSlpPbLhfxyPDMNs+vzMk8zjdze39Iy+ji7kpGG
mUDA9W9dLaAGJ3lA+ZIwtMKdD2pWE64RXIO5HzWmOhpOCFlCFnCcKrDUqE4t7+za
EFc6WnzMuvkhowmllPtLyc/OptA8aQy65xmeAFvPicsC94AtIt2aGOIa0qPtTJGE
d5vOxvroLQARAQABwsBfBBgBCAATBQJllR8zCRBR2iSiRaQKqwIbDAAAa1QIAIPn
CKZVvFmiLO2VMHVWX9BaZDWxGmIuSolPFJLHaSGbrAkeZE98N9zgHnNUXRYAFr9z
HRYObIuOpAFVV4vsHp8MeXXJmnfLG2m0K/HRwjTPmvYCsDwBMX+pEDAHYr8VKwLf
zFQdFWnEBFrFlhwSxuEZsIHJitbE5C3xP1+FqOgDw3BpNxlT3kT4oRIF3H77XlRj
3jnD/StfLgMyd/Z/hIQHDediN11SXgN+eFGaxnUj6ul52a+3UXGsSx8BkDZ3qAxK
Xv3zCaBwB/8YUh49fkBLRe9d3GPIa/3+NuebPyj7dWFlNX5dI2lCgCWKuybr73ij
mT3x7T3oNkwVo/NkYCE=
=CZcl
-----END PGP PUBLIC KEY BLOCK-----
EOF
sudo mv file.txt /etc/apt/keyrings/gitea-mrcyjanek.asc
echo "deb [signed-by=/etc/apt/keyrings/gitea-mrcyjanek.asc] https://git.mrcyjanek.net/api/packages/mrcyjanek/debian no-distro main" | sudo tee -a /etc/apt/sources.list.d/git-mrcyjanek-net.list
sudo apt update
sudo apt install xmruw -y
```

- If no errors occured along the way you can power off the qube by typing `sudo poweroff`

## Offline wallet qube

- Create new qube
- Type: Application
- Template: `xmruw`
- Network: **no network connection**.
- Applications: xmruw

## (view-only) Online wallet qube

- Create new qube
- Type: Application
- Template: `xmruw`
- Network: sys-firewall or sys-whonix, depending on your preference.
- Applications: xmruw
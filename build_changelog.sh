#!/bin/bash
LANG=C TZ=UTC git log --pretty=format:'{^^^^date^^^^:^^^^%ci^^^^,^^^^hash^^^^:^^^^%H^^^^,^^^^body^^^^:^^^^%B^^^^, ^^^^name^^^^: ^^^^%an <%ae>^^^^}&&&&' | awk '{printf "%s\\n", $0}' | sed 's/&&&&\\n/\n/g' | sed 's/"/\\"/g' | sed 's/\^^^^/"/g' > assets/changelog.jsonp

source /etc/os-release

if [[ "x$ID" == "xsailfishos" ]];
then
    flutter-elinux pub get
else
    flutter pub get
fi

make lib/helpers/licenses.g.dart
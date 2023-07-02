# Note.. these are old PATs. They're here as an example...
docker run -e GH_PAT='ghp_...lt' -e GH_OWNER='pdieppa3' -e GH_REPOSITORY='Github-Runner' --name github-runner-gatech armyguy255a/github-runner-gatech:latest
docker run --rm -e REG_TOKEN='AAAK...4W' -e GH_OWNER='gt-omscs-se-2023summer' -e GH_REPOSITORY='6300Summer23Team127' --rm --name github-runner-gatech armyguy255a/github-runner-gatech:latest

# Interactive Debug
docker run --entrypoint /bin/bash -it --rm -e GH_PAT='ghp_...lt' -e GH_OWNER='pdieppa3' -e GH_REPOSITORY='Github-Runner' --name github-runner-gatech armyguy255a/github-runner-gatech:latest


docker run --entrypoint /bin/bash -it --rm -e REG_TOKEN='AAAPN2WZBR3QZJIPCRKU7J3ETFY2K' -e GH_OWNER='gt-omscs-se-2023summer' -e GH_REPOSITORY='6300Summer23Team127' --rm --name github-runner-gatech armyguy255a/github-runner-gatech:latest


docker run --entrypoint /bin/bash -it --rm -e REG_TOKEN='AAAPN2WZBR3QZJIPCRKU7J3ETFY2K' -e GH_OWNER='pdieppa3' -e GH_REPOSITORY='gatech-android-app-sample' --name github-runner-gatech armyguy255a/github-runner-gatech:latest

docker volume create runner-data

docker run -v runner-data:/home/docker/actions-runner --rm -e REG_TOKEN='AAAPN2VEOLMHLMZAKCXV5DLEUDDDI' -e GH_OWNER='pdieppa3' -e GH_REPOSITORY='gatech-android-app-sample' --name github-runner-gatech armyguy255a/github-runner-gatech:latest
docker run -v runner-data:/home/docker/actions-runner -it --rm -e REG_TOKEN='AAAPN2VEOLMHLMZAKCXV5DLEUDDDI' -e GH_OWNER='pdieppa3' -e GH_REPOSITORY='gatech-android-app-sample' --name github-runner-gatech armyguy255a/github-runner-gatech:latest
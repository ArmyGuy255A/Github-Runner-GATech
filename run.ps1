# Note.. these are old PATs. They're here as an example...
docker run -e GH_PAT='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' -e GH_OWNER='pdieppa3' -e GH_REPOSITORY='Github-Runner' --name github-runner-gatech armyguy255a/github-runner-gatech:latest

# Debug
docker run --entrypoint /bin/bash -it --rm -e GH_PAT='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' -e GH_OWNER='pdieppa3' -e GH_REPOSITORY='Github-Runner' --name github-runner-gatech armyguy255a/github-runner-gatech:latest

test
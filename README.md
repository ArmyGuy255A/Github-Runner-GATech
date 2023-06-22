# Getting Started


1. Clone this repository
2. Build the runner using the build.ps1 file
3. Push the runner to your Docker Hub
4. docker push

# Notes
1. The runner uses the following URL to register the runner: "https://github.gatech.edu/GH_OWNER/GH_REPOSITORY"
2. If you supply a PAT, the initialization will request a new token with the following permissions: **READ:ORG, REPO**
3. If you supply a Registration Token, it must have the following permissions: **READ:ORG, REPO**
4. Supplying a Registration Token will override the PAT and the runner will not request a new token

# Using the Runner for a personal/public Repository that you own

1. Create a new Container Instance and use the following container: **armyguy255a/github-runner-gatech:latest**
2. You need to define 3 environment variables during configuration:
   1. GH_PAT='...' -> You need to go to Settings/Developer Settings/Personal Access Token and create a new token with **READ:ORG, REPO**
   2. GH_OWNER='pdieppa3' 
   3. GH_REPOSITORY='Github-Runner'

# Using the Runner for an Organization with a PAT
1. Create a new Container Instance and use the following container: **armyguy255a/github-runner-gatech:latest**
2. You need to define 3 environment variables during configuration:
   1. REG_TOKEN='...' -> You need to go to Settings/Developer Settings/Personal Access Token and create a new token with **READ:ORG, REPO**
   2. GH_OWNER='gt-omscs-se-2023summer' 
   3. GH_REPOSITORY='6300Summer23Team127 '
# Getting Started


1. Clone this repository
2. Build the runner using the build.ps1 file
3. Push the runner to your Docker Hub
4. docker push

# Running the Github Runner on GA Tech's Github Servers using Azure

1. Create a new Container Instance and use the following container: **armyguy255a/github-runner-gatech:latest**
2. You need to define 3 environment variables during configuration:
   1. GH_PAT='...' -> You need to go to Settings/Developer Settings/Personal Access Token and create a new token with **READ:ORG, REPO**
   2. GH_OWNER='pdieppa3' 
   3. GH_REPOSITORY='Github-Runner'
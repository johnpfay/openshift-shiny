# openshift-shiny
Allows a user to simply deploy a [R](https://www.r-project.org/) [Shiny](https://shiny.rstudio.com/) app to an OpenShift cluster.

This is accomplished by providing
1. Base Docker images that are compatible with OpenShift
2. OpenShift Templates for deploying a shiny app

The Docker image tags match those of parent docker images from [rocker/shiny* images](https://github.com/rocker-org/rocker-versioned2).

## Prerequisites
- Shiny R code stored in a git repository
- OpenShift project

## Steps to Deploy your shiny app

### Create a Dockerfile in your git repo
Create a file named `Dockerfile` in your git repo.
This file will specify:
- The base docker image to use (such as `dukegcb/openshift-shiny-verse:4.0.2`)
- Any additional requirements that need to be installed
- Location of your R code within your repo

As an example if your R shiny app is under a directory named `src` within your git repo and has no additional requirements create a `Dockerfile` with the following contents:
```
FROM dukegcb/openshift-shiny-verse:4.0.2
ADD ./src /srv/code
```

If you additionally need to install the [here shiny package](https://github.com/jennybc/here_here) your `Dockerfile` should contain the following contents:
```
FROM dukegcb/openshift-shiny-verse:4.0.2
RUN install2.r here
ADD ./src /srv/code
```
The `install2.r` script is a simple utility to install R packages that is provided by the `rocker` images.

### Deploy your shiny app using the OpenShift console
In this step we will run an OpenShift template to deploy your shiny app.
The following steps should be performed from the OpenShift console:
- Select your OpenShift project
- In the top right corner Click "Add To Project" then "Import YAML/JSON" - this will open up a "Import YAML/JSON" dialog
- Copy the contents of [openshift/shiny-server.yaml](https://raw.githubusercontent.com/Duke-GCB/openshift-shiny/master/openshift/shiny-server.yaml) and paste it into the "Import YAML/JSON" dialog
- Click "Create
- Leave "Process the template" checked and click "Continue"
- Update the parameters that are appropriate for your app. Minimally set APP_GIT_URI to your git repo location and REPO_DOCKERFILE_PATH to your dockerfile path location.
- Click "Create"
- Click "Applications" then "Deployments". Wait for your app to be deployed.
- Click "Applications" then "Routes" click on the Hostname(URL) to view the website.

### Deploy your shiny app using the command line
Create a project for your app.
```
oc project <your_project_name>
```

Deploy your app.
```
oc process -f https://raw.githubusercontent.com/Duke-GCB/openshift-shiny/master/openshift/shiny-server.yaml \
   -p APP_GIT_URI=<YOUR_GIT_REPO> \
   -p APP_GIT_BRANCH=<YOUR_GIT_BRANCH> \
   -p REPO_DOCKERFILE_PATH=<PATH_TO_DOCKERFILE_IN_YOUR_REPO> \
   | oc create -f -
```

# AI4OS Hub QA pipeline

This Jenkins pipeline is intended to do a sanity check on the modules of the
AI4OS Hub before building container images and pushing them to the
corresponding registry.

In order to make it work, you need a working instance of Jenkins with the
following configuration:

- An organization called "AI4OS-Hub", configured:
    - To scan the repositories and branches of your choice from Github
    - With the [Folder Properties plugin](https://plugins.jenkins.io/folder-properties/) and following variables:
        - AI4OS_REGISTRY: Registry URL
        - AI4OS_REGISTRY_CREDENTIALS: Credentials ID in Jenkins
        - AI4OS_REGISTRY_REPOSITORY: Repository for the images
    - To build with the [Remote File](https://plugins.jenkins.io/remote-file/) plugin configured to pull this repo
- An organization called "AI4OS-Hub-TEST", configured:
    - To scan the repositories and branches of your choice from Github (the same as above)
    - Not building anything (as the build will be triggered by the other jobs)

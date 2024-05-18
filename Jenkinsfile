// vim: filetype=groovy

@Library([
    'github.com/indigo-dc/jenkins-pipeline-library@release/2.1.1',
]) _


def projectConfig

pipeline {
    agent {
        label 'docker'
    }

    environment {
        // Remove .git from the GIT_URL link
        THIS_REPO = "${env.GIT_URL.endsWith(".git") ? env.GIT_URL[0..-5] : env.GIT_URL}"
        // Get list of AI4OS Hub repositories from "modules-catalog/.gitmodules"
        MODULES_CATALOG_URL = "https://raw.githubusercontent.com/ai4os-hub/modules-catalog/master/.gitmodules"
        MODULES = sh (returnStdout: true, script: "curl -s ${MODULES_CATALOG_URL}").trim()
    }

    stages {
        stage('Metadata tests') {
            parallel {
                stage('AI4OS Hub metadata V1 validation') {
                    when {
                        expression {env.MODULES.contains(env.THIS_REPO)}
                    }
                    agent {
                        docker {
                            image 'python:3.12'
                        }
                    }
                    steps {
                        script {
                            // Check if .metadata.json is present in the repository
                            if (!fileExists("metadata.json")) {
                                error("metadata.json file not found in the repository")
                            }
                        }

                        withEnv([
                            "HOME=${env.WORKSPACE}",
                        ]) {
                            script {
                                sh "pip install ai4-metadata"
                                sh ".local/bin/ai4-metadata-validator --metadata-version 1.0.0 metadata.json"
                            }
                        }
                    }
                }
                stage('AI4OS Hub metadata V2 validation (JSON)') {
                    when {
                        expression {env.MODULES.contains(env.THIS_REPO)}
                        // Check if metadata.json is present in the repository
                        expression {fileExists("ai4-metadata.json")}
                    }
                    agent {                 
                        docker {
                            image 'python:3.12'
                        }
                    }
                    steps {
                        script {
                            // Check if metadata files are present in the repository
                            if (!fileExists("ai4-metadata.json")) {
                                error("ai4-metadata.json file not found in the repository")
                            }
                            if (fileExists("ai4-metadata.yml")) {
                                error("Both ai4-metadata.json and ai4-metadata.yml files found in the repository")
                            }
                        }
                        withEnv([
                            "HOME=${env.WORKSPACE}",
                        ]) {
                            script {
                                sh "pip install ai4-metadata"
                                sh ".local/bin/ai4-metadata-validator --metadata-version 2.0.0 ai4-metadata.json"
                            }
                        }
                    }
                }
                stage('AI4OS Hub metadata V2 validation (YAML)') {
                    when {
                        expression {env.MODULES.contains(env.THIS_REPO)}
                        // Check if metadata.json is present in the repository
                        expression {fileExists("ai4-metadata.yml")}
                    }
                    agent {                 
                        docker {
                            image 'python:3.12'
                        }
                    }
                    steps {
                        script {
                            if (!fileExists("ai4-metadata.yml")) {
                                error("ai4-metadata.yml file not found in the repository")
                            }
                            if (fileExists("ai4-metadata.json")) {
                                error("Both ai4-metadata.json and ai4-metadata.yml files found in the repository")
                            }
                            // load YAML file, dump as JSON
                            metadata = readYaml file: "ai4-metadata.yml"
                                writeJSON file: "ai4-metadata-${BUILD_NUMBER}.json", json: metadata
                        }
                        withEnv([
                            "HOME=${env.WORKSPACE}",
                        ]) {
                            script {
                                sh "pip install ai4-metadata"
                                sh ".local/bin/ai4-metadata-validator --metadata-version 2.0.0 ai4-metadata-${BUILD_NUMBER}.json"
                            }
                        }
                    }
                }
                stage("License validation") {
                    steps {
                        script {
                            // Check if LICENSE file is present in the repository
                            if (!fileExists("LICENSE")) {
                                error("LICENSE file not found in the repository")
                            }
                        }
                    }
                }
            }
        }
        stage("User-defined module pipeline job") {
            steps {
                //sh 'printenv'
                script {
                    build(job: "/AI4OS-HUB-TEST/" + env.JOB_NAME.drop(10))
                }
            }
        }
        stage("Docker Variable initialization") {
             when {
                 expression {env.MODULES.contains(env.THIS_REPO)}
             }
             environment {
                 AI4OS_REGISTRY_CREDENTIALS = credentials('AIOS-registry-credentials')
             }
             steps {
                 script {
                     withFolderProperties{
                         docker_registry = env.AI4OS_REGISTRY
                         docker_registry_credentials = env.AI4OS_REGISTRY_CREDENTIALS
                         docker_repository = env.AI4OS_REGISTRY_REPOSITORY
                     }
                     docker_ids = []
                    
                     docker_registry_credentials = env.AI4OS_REGISTRY_CREDENTIALS

                     // Check here if variables exist
                 }
             }
         }

         stage('AI4OS Hub Docker images build') {
             when {
                 anyOf {
                     branch 'cicd'
                     branch 'main'
                     branch 'master'
                     branch 'test'
                     branch 'dev'
                     branch 'release/*'
                 }
                 expression {env.MODULES.contains(env.THIS_REPO)}
             }
             steps {
                 checkout scm

                 script {

                     // define docker tag depending on the branch/release
                     if ( env.BRANCH_NAME.startsWith("release/") ) {
                         docker_tag = env.BRANCH_NAME.drop(8)
                     }
                     else if ( env.BRANCH_NAME in ['master', 'main'] ) {
                         docker_tag = "latest"
                     }
                     else {
                         docker_tag = env.BRANCH_NAME
                     }
                     docker_tag = docker_tag.toLowerCase()

                     // get docker image name from metadata.json
                     meta = readJSON file: "metadata.json"
                     image_name = meta["sources"]["docker_registry_repo"].split("/")[1]

                     // use preconfigured in Jenkins docker_repository
                     // XXX may confuse users? (e.g. expect xyz/myimage, but we push to ai4hub/myimage)
                     image = docker_repository + "/" + image_name + ":" + docker_tag

                     // build docker images
                     // by default we expect Dockerfile name and location in the git repo root
                     def dockerfile = "Dockerfile"
                     def base_cpu_tag = ""
                     def base_gpu_tag = ""
                     def build_cpu_tag = false
                     def build_gpu_tag = false
                     // try to load constants if defined in user's repository ($jenkinsconstants_file has to be in the repo root)
                     jenkinsconstants_file = "JenkinsConstants.groovy"
                     try {
                         def constants = load jenkinsconstants_file
                         // $jenkinsconstants_file may have all constants or only "dockefile" or only both base_cpu|gpu_tag:
                         try {
                             dockerfile = constants.dockerfile
                         } catch (e) {}
                         // let's define that if used, both "base_cpu_tag" && "base_gpu_tag" are required:
                         try {
                             base_cpu_tag = constants.base_cpu_tag
                         } catch (e) {}
                         try {
                             base_gpu_tag = constants.base_gpu_tag
                         } catch (e) {}
                         if (!base_cpu_tag && !base_gpu_tag) {
                             throw new Exception("Neither \"base_cpu_tag\" nor \"base_gpu_tag\" is defined. Using default tag from ${dockerfile}")
                         }
                         if (!base_cpu_tag || !base_gpu_tag) {
                             throw new Exception("Check ${jenkinsconstants_file}: If separate tags for CPU and GPU are needed, both \"base_cpu_tag\" and \"base_gpu_tag\" are required!")
                         }
                         // if no Exception so far, allow building "-cpu" and "-gpu" versions
                         build_cpu_tag = true
                         build_gpu_tag = true
                     } catch (err) {
                         // if $jenkinsconstants_file not found or one of base_cpu|gpu_tag is not defined or none of them, build docker image with default params
                         println("[WARNING] Exception: ${err}")
                         println("[INFO] Using default parameters for Docker image building")
                         image_id = docker.build(image, "--no-cache --force-rm -f ${dockerfile} .")
                     }
                     // build "-cpu" image, if configured
                     if (build_cpu_tag) {
                         image_id = docker.build(image, "--no-cache --force-rm --build-arg tag=${base_cpu_tag} -f ${dockerfile} .")
                         // define additional docker_tag_cpu to mark it as "cpu" version
                         docker_tag_cpu = (docker_tag == "latest") ? "cpu" : (docker_tag + "-cpu")
                         image_cpu = docker_repository + "/" + image_name + ":" + docker_tag_cpu
                         sh "docker tag ${image} ${image_cpu}"
                         docker_ids.add(image_cpu)
                     }

                     // check that in the built image (cpu or default), DEEPaaS API starts as expected
                     // EXCLUDE "cicd" branch
                     // do it with only "cpu|default" image: 
                     // a) can stop before proceeding with "gpu" version b) "gpu" may fail without GPU hardware anyway
                     if (env.BRANCH_NAME != 'cicd') {
                         sh "git clone https://github.com/ai4os/ai4os-hub-check-artifact"
                         sh "bash ai4os-hub-check-artifact/check-artifact ${image}"
                         sh "rm -rf ai4os-hub-check-artifact"
                     }

                     docker_ids.add(image)

                     // finally, build "-gpu" image, if configured
                     if (build_gpu_tag) {
                         // define additional docker_tag_gpu to mark "gpu" version
                         docker_tag_gpu = (docker_tag == "latest") ? "gpu" : (docker_tag + "-gpu")
                         image = docker_repository + "/" + image_name + ":" + docker_tag_gpu
                         image_id = docker.build(image, "--no-cache --force-rm --build-arg tag=${base_gpu_tag}  -f ${dockerfile} .")
                         docker_ids.add(image)
                     }

                 }
             }
         }
         stage('AI4OS Hub Docker delivery to registry') {
             when {
                 expression {env.MODULES.contains(env.THIS_REPO)}
             }
             steps {
                 script {
                     docker.withRegistry(docker_registry, docker_registry_credentials) {
                         docker_ids.each {
                             docker.image(it).push()
                         }
                     }
                 }
             }
         }
        stage('Enable Zenodo Github integration') {
            when {
                expression {env.MODULES.contains(env.THIS_REPO)}
            }
            environment {
                ZENODO_TOKEN = credentials('zenodo')  
            }
            steps {
                checkout scm
                script {
                    withFolderProperties{
                        zenodo_api_url = env.ZENODO_API_URL
                        zenodo_community = env.ZENODO_COMMUNITY
                    }
                    // Get repository ID from GitHub API
                    github_api_url = env.THIS_REPO.replace("github.com", "api.github.com/repos")
                    // Get repository ID from GitHub API
                    repo_id = sh (returnStdout: true, script: "curl -s ${github_api_url} | jq '.id'").trim()
                    // Get webhook URL form GitHub API
                    response = httpRequest authentication: 'github-ai4os-hub',
                               httpMode: 'GET',
                               url: "${github_api_url}/hooks"

                    content = readJSON text: response.content

                    for (entry in content) {
                        if (entry.config.url.startsWith(zenodo_api_url)) {
                            println("Zenodo webhook already enabled")
                            // If hook_url is defined, terminate the stage
                            need_zenodo_retrigger = false
                            return
                        }
                    }
                    
                    need_zenodo_retrigger = true
                    // Otherwise, enable Zenodo integration
                    httpRequest customHeaders: [[name: 'Authorization', value: 'Bearer ' + env.ZENODO_TOKEN]],
                                httpMode: 'POST',
                                url: "${zenodo_api_url}user/github/repositories/${repo_id}/enable"
                    
                }
            }
        }

        stage('Trigger Zenodo webhook on first integration') {
            when {
                expression {env.MODULES.contains(env.THIS_REPO)}
                expression {need_zenodo_retrigger}
            }
            environment {
                ZENODO_TOKEN = credentials('zenodo')  
            }
            steps {
                checkout scm
                script {
                    withFolderProperties{
                        zenodo_api_url = env.ZENODO_API_URL
                        zenodo_community = env.ZENODO_COMMUNITY
                    }

                    // Get webhook URL form GitHub API
                    response = httpRequest authentication: 'github-ai4os-hub',
                               httpMode: 'GET',
                               url: "${github_api_url}/hooks"

                    content = readJSON text: response.content

                    for (entry in content) {
                        if (entry.config.url.startsWith(zenodo_api_url)) {
                            println("Zenodo webhook enabled")
                            hook_url = entry.config.url
                        }
                    }
                    // Now, retrigger all releases to trigger Zenodo integration
                    
                    repository = sh (returnStdout: true, script: "curl -s ${github_api_url}").trim()

                    // Get all relreases from GitHub API
                    releases = httpRequest authentication: 'github-ai4os-hub',
                               httpMode: 'GET',
                               url: "${github_api_url}/releases"
                    releases = readJSON text: releases.content

                    // Uncomment this to retrigger all releases in reverse order, 
                    // and comment the next line
                    // releases = releases.reverse()
                    // Sync only the last release
                    releases = [releases[0]] 


                    for (release in releases) {
                        println("Retriggering release: ${release.tag_name}")
                        release = writeJSON returnText: true, json: release

                        requestBody = '{"action": "published", "release": ' + release + ', "repository": ' + repository + '}'
                        httpRequest httpMode: 'POST',
                                    acceptType: 'APPLICATION_JSON', contentType: 'APPLICATION_JSON',
                                    url: hook_url,
                                    quiet: true,
                                    requestBody: requestBody,
                                    validResponseCodes: "202,409"
                    }
                }
            }
        }
        stage('Get Zenodo DOI') {
            when {
                expression {env.MODULES.contains(env.THIS_REPO)}
                expression {need_zenodo_retrigger}
            }
            environment {
                ZENODO_TOKEN = credentials('zenodo')  
            }
            steps {
                checkout scm
                script {
                    withFolderProperties{
                        zenodo_api_url = env.ZENODO_API_URL
                        zenodo_community = env.ZENODO_COMMUNITY
                    }
                    query = "type:software%20AND ${env.THIS_REPO}"
                    query = URLEncoder.encode(query, "UTF-8")

                    // Search for Zenodo record in Zenodo API
                    response = httpRequest customHeaders: [[name: 'Authorization', value: 'Bearer ' + env.ZENODO_TOKEN]],
                               httpMode: 'GET',
                               url: "${zenodo_api_url}/records?size=1&q=${query}"
                    response = readJSON text: response.content
                    
                    zenodo_doi = response["hits"]["hits"][0]["links"]["parent_doi"]
                }
            }
        }
        stage('Update metadata.json') {
            when {
                expression {env.MODULES.contains(env.THIS_REPO)}
                expression {need_zenodo_retrigger}
                expression {zenodo_doi}
            }
            environment {
                GITHUB_TOKEN = credentials('github-ai4os-hub')  
            }
            steps {
                script {
                    // Checkout the repository
                    checkout scm

                    // Create a new branch, using shell, append a random suffix 
                    sh "git checkout -b zenodo-integration-${BUILD_NUMBER}"

                    meta = readJSON file: "metadata.json"

                    // If Zenodo DOI is not in metadata.json, add it
                    if (!meta["sources"].containsKey("zenodo_doi")) {
                        meta["sources"]["zenodo_doi"] = zenodo_doi
                        // write JSON to file
                        writeJSON file: "metadata.json", json: meta
                    }

                    // Setup git user
                    sh "git config --global user.email 'ai4eosc-support@listas.csic.es'"
                    sh "git config --global user.name 'AI4EOSC Jenkins user'"
            
                    // Now commit the changes
                    sh "git add metadata.json"
                    sh "git commit -m 'Add Zenodo DOI to metadata.json'"

                    // Push the changes to the repository
                    withCredentials([
                        gitUsernamePassword(credentialsId: 'github-ai4os-hub', gitToolName: 'git-tool')]) {
                            sh "git push origin zenodo-integration-${BUILD_NUMBER}"
                    }

                    // Get default branch for repo
                    response = httpRequest authentication: 'github-ai4os-hub',
                               httpMode: 'GET',
                               url: "${github_api_url}"
                    response = readJSON text: response.content
                    default_branch = response["default_branch"]


                    // Now, crete a PR using GitHub API
                    pr_body = "This is an automated change.\\n\\nThis pull request includes the Zenodo DOI in the metadata.json file. The obtained Zenodo DOI is ${zenodo_doi}, please veryfi chat this corresponds to your repository, carefully review the changes and, if they are correct, merge the PR."
                    pr_title = "Add Zenodo DOI to metadata.json"
                    pr_head = "zenodo-integration-${BUILD_NUMBER}"
                    pr = """{
                        "title": "${pr_title}",
                        "head": "${pr_head}",
                        "base": "${default_branch}",
                        "body": "${pr_body}"
                    }"""

                    // create a PR
                    response = httpRequest authentication: 'github-ai4os-hub',
                               httpMode: 'POST',
                               url: "${github_api_url}/pulls",
                               contentType: 'APPLICATION_JSON',
                               requestBody: pr

                    println("PR created: ${response.content}")
                }
            }
        }
    }
    post {
        // Clean after build
        always {
            cleanWs(cleanWhenNotBuilt: false,
                    deleteDirs: true,
                    disableDeferredWipeout: true,
                    notFailBuild: true,
                    patterns: [[pattern: '.gitignore', type: 'INCLUDE'],
                               [pattern: '.propsfile', type: 'EXCLUDE']])
        }
    }
}


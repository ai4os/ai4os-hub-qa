// vim: filetype=groovy

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
        stage('Checkout') {
            steps {
                script {
                    echo "Checking out the repository"
                    checkout scm
                }
            }
        }
        stage("V1 to V2 Metadata migration") {
            when {
                expression {! fileExists(".ai4-metadata.json")}
            }
            steps {
                script {
                    echo "Migrating metadata"
                    
                    // Checkout the repository
                    checkout scm
                    
                    sh "git checkout -b metadata-migration-${BUILD_NUMBER}"

                    metadata = readJSON file: "metadata.json"

                    // Create new metadata, from V1 to V2
                    new_meta = [
                        "title": metadata["title"],
                        "summary": metadata["summary"],
                        // description is an array, convert it to string
                        "description": metadata["description"].join(" "),
                        "dates": [
                            "created": metadata["date_creation"],
                            // Updated should be now
                            "updated": new Date().format("yyyy-MM-dd"),
                        ],
                        "links": [
                            "source_code": metadata["sources"]["code"],
                            "docker_image": metadata["sources"]["docker_registry_repo"],
                        ],
                        "tags": [],
                        "topics": [],
                        "libraries": [],
                    ]

                    // now move things into links
                    if (metadata["doi"]) {
                        new_meta["doi"] = metadata["doi"]
                    }
                    if (metadata["zenodo_doi"]) {
                        new_meta["links"]["zenodo_doi"] = metadata["zenodo_doi"]
                    }   
                    if (metadata["sources"]["pre_trained_weights"]) {
                        new_meta["links"]["weights"] = metadata["sources"]["pre_trained_weights"]
                    }
                    if (metadata["sources"]["ai4_template"]) {
                        new_meta["links"]["ai4_template"] = metadata["sources"]["ai4_template"]
                    }
                    if (metadata["dataset_url"]) {
                        new_meta["links"]["dataset"] = metadata["dataset_url"]
                    }
                    if (metadata["training_files_url"]) {
                        new_meta["links"]["training_data"] = metadata["sources"]["training_files_url"]
                    }
                    if (metadata["cite_url"]) {
                        new_meta["links"]["citation"] = metadata["cite_url"]    
                    }
                    // Add all keywords as tags, we can adjust manually at a glance
                    new_meta["tags"] = metadata["keywords"]
                    
                    if (metadata["keywords"].contains("tensorflow") || metadata["keywords"].contains("TensorFlow") || metadata["keywords"].contains("Tensor Flow")) {
                        new_meta["libraries"].add("TensorFlow")
                    }
                    if (metadata["keywords"].contains("keras") || metadata["keywords"].contains("Keras")) {
                        new_meta["libraries"].add("Keras")
                    }
                    if (metadata["keywords"].contains("pytorch") || metadata["keywords"].contains("PyTorch")) {
                        new_meta["libraries"].add("Pytorch")
                    }
                    if (metadata["keywords"].contains("scikit-learn") || metadata["keywords"].contains("scikit learn")) {
                        new_meta["libraries"].add("Scikit-Learn")
                    }
                    // if trainable add the AI4 trainable topic
                    if (metadata["trainable"]) {
                        new_meta["categories"].add("AI4 trainable")
                    }
                    // if inference add the AI4 inference topic
                    if (metadata["inference"]) {
                        new_meta["categories"].add("AI4 inference")
                        new_meta["categories"].add("AI4 pre trained")
                    }
    
                    // Create a new metadata file
                    writeJSON file: ".ai4-metadata.json", json: new_meta, pretty: 4

                    meta_json = readJSON file: ".ai4-metadata.json"

                    println("New metadata: ${new_meta}")

                    // Setup git user
                    sh "git config --global user.email 'ai4eosc-support@listas.csic.es'"
                    sh "git config --global user.name 'AI4EOSC Jenkins user'"
            
                    // Now commit the changes
                    sh "git add .ai4-metadata.json"
                    sh "git commit -m 'feat: Migrate metadata from v1 to v2'"

                    // Push the changes to the repository
                    withCredentials([
                        gitUsernamePassword(credentialsId: 'github-ai4os-hub', gitToolName: 'git-tool')]) {
                            sh "git push origin metadata-migration-${BUILD_NUMBER}:metadata -f"
                    }

                    // Get repository ID from GitHub API
                    github_api_url = env.THIS_REPO.replace("github.com", "api.github.com/repos")
                    
                    // Get default branch for repo
                    response = httpRequest authentication: 'github-ai4os-hub',
                               httpMode: 'GET',
                               url: "${github_api_url}"
                    response = readJSON text: response.content
                    default_branch = response["default_branch"]

                    // Now, crete a PR using GitHub API
                    pr_body = "This is an automated change.\\n\\nThis pull request migrates the module metadata from V1 to V2, please carefully review the changes and, if they are correct, merge the PR."
                    pr_title = "Migrate metadata from V1 to V2"
                    pr_head = "metadata"
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
        stage('Cleanup') {
            steps { 
                script {
                    echo "Cleaning workspace"
                }
            }
            post {
                always {
                    cleanWs()
                }
            }
        }
    }
}


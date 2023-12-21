#!groovy
@Library("liveramp-base@master") _

JENKINS_GITHUB_CREDENTIALS = 'ops-github--github.com'

agentLabel = 'ubuntu-2004'

pipeline {

    options {
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '50', daysToKeepStr: '30'))
    }

    triggers {
        githubPush()
    }

    agent {
        label agentLabel
    }

    stages {
        stage('Generate Terraform Docs') {
            when {
                expression { env.GIT_BRANCH != 'main' }
            }
            steps {
                script {
                    sh("script: scripts/generate-tf-docs.sh")
                    gitCommitAndPush()
                }
            }
        }
    }
}

void gitCommitAndPush() {
    sshagent(credentials: [JENKINS_GITHUB_CREDENTIALS]) {
        sh "git stash"
        sh "git fetch origin main:refs/remotes/origin/main"
        sh "git checkout main"
        sh "git pull origin main"
        sh "git stash pop"
        sh "git status"
        sh "git add ."
        sh "git commit -m \"README.md updated\""
        sh "git push -u origin main"
    }
}
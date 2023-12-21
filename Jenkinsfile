#!groovy
@Library("liveramp-base@master") _

JENKINS_GITHUB_CREDENTIALS = 'ops-github--github.com'

JENKINS_COMMIT_MESSAGE = "[CI/Automation] Update README.md"

pipeline {

    options {
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '50', daysToKeepStr: '30'))
    }

    triggers {
        githubPush()
    }

    agent {
        label 'ubuntu-2004'
    }

    stages {
        stage('Generate Terraform Docs') {
            when {
                expression { env.GIT_BRANCH == 'main' && !jenkinsCommit() }
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

boolean jenkinsCommit() {
    return !env.LAST_COMMIT_LOG.startsWith(JENKINS_COMMIT_MESSAGE)
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
        sh "git commit -m \"" + JENKINS_COMMIT_MESSAGE + "\""
        sh "git push -u origin main"
    }
}
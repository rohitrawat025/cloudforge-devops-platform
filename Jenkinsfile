
pipeline {

agent any

triggers { githubPush() }

stages {

stage('Build'){
steps{
sh 'docker build -t devops-app ./docker'
}
}

stage('Run'){
steps{
sh 'docker compose -f docker/docker-compose.yml up -d'
}
}

}

}


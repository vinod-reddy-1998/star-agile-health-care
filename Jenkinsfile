pipeline {
  agent any
     tools {
       maven 'M2_HOME'
           }
 
  stages {
    stage('Git Checkout') {
      steps {
        echo 'This stage is to clone the repo from GitHub'
        git branch: 'master', url: 'https://github.com/vinod-reddy-1998/star-agile-health-care'
      }
    }
    
    stage('Create Package') {
      steps {
        echo 'This stage will compile, test, and package the application'
        sh 'mvn package'
      }
    }
    
    stage('Generate Test Report') {
      steps {
        echo 'This stage generates a Test report using TestNG'
        publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, 
                     reportDir: '/var/lib/jenkins/workspace/health_care/target/surefire-reports', 
                     reportFiles: 'index.html', reportName: 'HTML Report', reportTitles: '', 
                     useWrapperFileDirectly: true])
      }
    }
    
    stage('Create-Image') {
      steps {
        echo 'This stage will create a Docker image of the application'
        sh 'docker build -t vinod179179/healthcare:1.0 .'
      }
    }
    
    stage('Docker-Login') {
    steps {
      echo 'This stage will login to docker hub'
        withCredentials([usernamePassword(credentialsId: '8fcdd6cb-7bcf-4989-aa1c-f30f6a2c0ff7', passwordVariable: 'docker-pass', usernameVariable: 'docker-login')]) {
            sh "docker login -u vinod179719 -p adminadmin"
        }
    }
}
 
    stage('Docker Push-Image') {
      steps {
        echo 'This stage will push the new Docker image to Docker Hub'
        sh 'docker push vinod179179/healthcare:1.0'
      }
    }
  }
}

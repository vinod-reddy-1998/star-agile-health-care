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
        withCredentials([usernamePassword(credentialsId: '0c9ebfff-840b-44d7-9519-28050e3a12a9', passwordVariable: 'docker-password', usernameVariable: 'docker-login')]) {
            //sh 'docker login -u ${docker-login} -p ${docker-pass}'
          sh "echo \$docker-password | docker login --username \$docker-login --password-stdin"
  
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

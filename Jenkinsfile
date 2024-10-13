pipeline {
  agent any
     tools {
       maven 'M2_HOME'
           }
 
  stages {
    stage('Git Checkout') {
      steps {
        echo 'This stage is to clone the repo from github'
        git branch: 'master', url: 'https://github.com/vinod-reddy-1998/star-agile-health-care'
                        }
            }
    stage('Create Package') {
      steps {
        echo 'This stage will compile, test, package my application'
        sh 'mvn package'
                          }
            }
    stage('Generate Test Report') {
      steps {
        echo 'This stage generate Test report using TestNG'
        publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: '/var/lib/jenkins/workspace/health_care/target/surefire-reports', reportFiles: 'index.html', reportName: 'HTML Report', reportTitles: '', useWrapperFileDirectly: true])
      }
            }

}
}

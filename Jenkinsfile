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
    stage('Create-Image') {
      steps {
        echo 'This stage will create a image of my application'
        sh 'docker build -t lvinod179179/healthcare:1.0 .'
                          }
            }
      }
  stage('Docker-Login') {
      steps {
       withCredentials([usernamePassword(credentialsId: '0c9ebfff-840b-44d7-9519-28050e3a12a9', passwordVariable: 'docker-password', usernameVariable: 'docker-login')])  {
        sh 'docker login -u ${dockerlogin} -p ${dockerpass}'
              }
              }
            }
  stage('Docker Push-Image') {
      steps {
        echo 'This stage will push my new image to the dockerhub'
        sh 'docker push lvinod179179/healthcare:1.0'
            }
                              }

  
}

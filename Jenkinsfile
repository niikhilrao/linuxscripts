node {
  stage('SCM') {
    checkout scm
  }
  stage('SonarQube Analysis') {
    def scannerHome = tool 'SonarScanner';
    withSonarQubeEnv(credentialsId: 'fef69c3e-7c1b-4b11-af91-818915e35bb1', installationName: 'SonarScanner') {
      sh "${scannerHome}/bin/sonar-scanner"
    }
  }
}

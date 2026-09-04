pipeline {
    agent any

    environment {
        appVersion = ""
        // Replace with your actual registry username and repository name
        REGISTRY_USER = 'sreenivaschitti'
        IMAGE_NAME    = 'roboshop-catalog'
        IMAGE_TAG     = "${env.BUILD_NUMBER}" // Uses the unique Jenkins build number as a tag
    }

    
    stages{
        stage('gitcheckout'){

             steps {

                git branch: 'main',
                url: 'https://github.com/sreenivaschitti/catalogue-unit_test.git'


                    }   

        }

        stage('Read Version'){
             steps {
                        script {
                            // Read and parse the package.json file
                            def packageJson = readJSON file: 'package.json'
                            
                            // Extract the version property
                            appVersion = packageJson.version
                            
                            // Output or use the version
                            echo "The application version is: ${appVersion}"
                    
                            }
                 }
        }


        stage('install dependencies'){

                    steps {

                        script {

                            sh """

                                npm install

                                """

                        }   

                    }

        }

        stage('unitest'){

            steps{

                script {

                     sh """
                        npm test
                     """   

                }    

            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    def scannerHome = tool name: 'sonar-8'

                    withSonarQubeEnv('SonarQube') {
                        sh "${scannerHome}/bin/sonar-scanner"
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Builds the image using the Dockerfile in your workspace root
                    sh "docker build -t ${REGISTRY_USER}/${IMAGE_NAME}:${IMAGE_TAG} ."
                    
                }
            }
        }

        stage('Trivy OS Scan') {
                steps {
                    script {
                        // Generate table report
                        sh """
                            trivy image \
                                --scanners vuln \
                                --pkg-types os \
                                --severity HIGH,MEDIUM \
                                --format table \
                                --output trivy-os-report.txt \
                                --exit-code 0 \
                                ${REGISTRY_USER}/${IMAGE_NAME}:${IMAGE_TAG}
                        """

                        // Print table to console
                        sh 'cat trivy-os-report.txt'

                        // Fail pipeline if vulnerabilities found
                        def scanResult = sh(
                            script: """
                                trivy image \
                                    --scanners vuln \
                                    --pkg-types os \
                                    --severity HIGH ,CRITICAL \
                                    --format table \
                                    --exit-code 1 \
                                    --quiet \
                                    ${REGISTRY_USER}/${IMAGE_NAME}:${IMAGE_TAG}
                            """,
                            returnStatus: true
                        )

                        if (scanResult != 0) {
                            utils.updateCommitStatus('failure', 'Trivy OS scan: HIGH/MEDIUM vulnerabilities found', 'trivy-scan')
                            error "🚨 Trivy found HIGH/MEDIUM OS vulnerabilities. Pipeline failed."
                        } else {
                            utils.updateCommitStatus('success', 'Trivy OS scan passed — no HIGH/MEDIUM vulnerabilities', 'trivy-scan')
                            echo "✅ No HIGH or MEDIUM OS vulnerabilities found. Pipeline continues."
                        }
                    }
                }
            }
            stage('Trivy Dockerfile Scan'){
                steps {
                    script {
                        sh """
                            trivy config \
                                --severity HIGH,MEDIUM \
                                --format table \
                                --output trivy-dockerfile-report.txt \
                                Dockerfile
                        """

                        sh 'cat trivy-dockerfile-report.txt'

                        def scanResult = sh(
                            script: """
                                trivy config \
                                    --severity HIGH,MEDIUM \
                                    --exit-code 1 \
                                    --format table \
                                    Dockerfile
                            """,
                            returnStatus: true
                        )

                        if (scanResult != 0) {
                            error "🚨 Trivy found HIGH/MEDIUM misconfigurations in Dockerfile. Pipeline failed."
                        } else {
                            echo "✅ No HIGH or MEDIUM Dockerfile misconfigurations found. Pipeline continues."
                        }
                    }
                }
            }

    }
    
}

    

   

   

    

       




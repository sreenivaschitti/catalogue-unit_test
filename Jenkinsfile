pipeline {
    agent any

    environment {
        appVersion   = ""
        REGISTRY_USER = 'sreenivaschitti'
        IMAGE_NAME    = 'roboshop-catalog'
        IMAGE_TAG     = "${env.BUILD_NUMBER}" // Jenkins build number as tag
    }

    stages {
        stage('Git Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/sreenivaschitti/catalogue-unit_test.git'
            }
        }

        stage('Read Version') {
            steps {
                script {
                    def packageJson = readJSON file: 'package.json'
                    appVersion = packageJson.version
                    echo "The application version is: ${appVersion}"
                }
            }
        }

        stage('Install Dependencies') {
            steps {
                sh "npm install"
            }
        }

        // Uncomment if you want unit tests + SonarQube
        /*
        stage('Unit Test') {
            steps {
                sh "npm test"
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
        */

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${REGISTRY_USER}/${IMAGE_NAME}:${IMAGE_TAG} ."
            }
        }

        stage('Trivy OS Scan') {
    steps {
        script {
            // Generate full report (always succeeds)
            sh """
                trivy image \
                    --scanners vuln \
                    --pkg-types os \
                    --severity HIGH,MEDIUM,CRITICAL \
                    --format table \
                    --output trivy-os-report.txt \
                    --exit-code 0 \
                    ${REGISTRY_USER}/${IMAGE_NAME}:${IMAGE_TAG}
            """
            sh 'cat trivy-os-report.txt'
            archiveArtifacts artifacts: 'trivy-os-report.txt', fingerprint: true

            // Fail only if HIGH/CRITICAL found
            def scanResult = sh(
                script: """
                    trivy image \
                        --scanners vuln \
                        --pkg-types os \
                        --severity HIGH,CRITICAL \
                        --format table \
                        --exit-code 1 \
                        --quiet \
                        ${REGISTRY_USER}/${IMAGE_NAME}:${IMAGE_TAG}
                """,
                returnStatus: true
            )

            if (scanResult != 0) {
                error "🚨 Trivy found HIGH/CRITICAL OS vulnerabilities. Pipeline failed."
            } else {
                echo "✅ No HIGH or CRITICAL OS vulnerabilities found. Pipeline continues."
            }
        }
    }
}


        stage('Trivy Dockerfile Scan') {
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
                    archiveArtifacts artifacts: 'trivy-dockerfile-report.txt', fingerprint: true

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

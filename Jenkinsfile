pipeline {
  agent {
    kubernetes {
      // Keep it simple to avoid Script Approval requirements
      cloud 'kubernetes'
      label 'oc-intro'
      defaultContainer 'node'
      yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
    - name: node
      image: node:20-bookworm
      command: ['cat']
      tty: true
      env:
        - name: http_proxy
          value: "http://10.0.2.2:10809"
        - name: https_proxy
          value: "http://10.0.2.2:10809"
        - name: ALL_PROXY
          value: "socks5://10.0.2.2:10808"
"""
    }
  }

  environment {
    REMOTE_HOST = '8.134.251.152'
    REMOTE_PORT = '22'

    REMOTE_APPDIR = 'C:/apps/openclaw-intro'
    REMOTE_ZIP    = 'C:/apps/openclaw-intro/release.zip'
    REMOTE_PS1    = 'C:/apps/openclaw-intro/deploy.ps1'

    APP_PORT = '3000'
  }

  options {
    disableConcurrentBuilds()
  }

  stages {
    stage('Build frontend') {
      steps {
        container('node') {
          sh '''
            set -eux
            cd frontend
            npm ci
            npm run build
          '''
        }
      }
    }

    stage('Assemble backend') {
      steps {
        container('node') {
          sh '''
            set -eux
            rm -rf backend/public
            cp -R frontend/dist backend/public
          '''
        }
      }
    }

    stage('Package') {
      steps {
        container('node') {
          sh '''
            set -eux
            apt-get update
            apt-get install -y zip openssh-client

            # put deploy script at root for convenience
            cp -f deploy/windows/deploy.ps1 ./deploy.ps1

            rm -f release.zip
            zip -r release.zip backend deploy.ps1
          '''
        }
      }
    }

    stage('Deploy to Windows (SSH)') {
      steps {
        container('node') {
          // Jenkins Credentials: type "SSH Username with private key"
          // credentialsId must be created in Jenkins: "ALIYUN_WIN_SSH"
          withCredentials([sshUserPrivateKey(credentialsId: 'ALIYUN_WIN_SSH', keyFileVariable: 'SSH_KEY', usernameVariable: 'SSH_USER')]) {
            sh '''
              set -eux
              chmod 600 "$SSH_KEY"

              # Create remote dir
              ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no -p "$REMOTE_PORT" "$SSH_USER@$REMOTE_HOST" \
                "powershell -NoProfile -Command \"New-Item -ItemType Directory -Force -Path '${REMOTE_APPDIR}' | Out-Null\""

              # Upload release zip + deploy.ps1
              scp -i "$SSH_KEY" -o StrictHostKeyChecking=no -P "$REMOTE_PORT" release.zip "$SSH_USER@$REMOTE_HOST:${REMOTE_ZIP}"
              scp -i "$SSH_KEY" -o StrictHostKeyChecking=no -P "$REMOTE_PORT" deploy.ps1 "$SSH_USER@$REMOTE_HOST:${REMOTE_PS1}"

              # Execute deploy
              ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no -p "$REMOTE_PORT" "$SSH_USER@$REMOTE_HOST" \
                "powershell -NoProfile -ExecutionPolicy Bypass -File '${REMOTE_PS1}' -AppDir '${REMOTE_APPDIR}' -ZipPath '${REMOTE_ZIP}' -Port '${APP_PORT}'"
            '''
          }
        }
      }
    }
  }
}

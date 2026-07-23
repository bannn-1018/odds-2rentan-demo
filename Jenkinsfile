// Jenkins Pipeline: phục vụ OpAppHtmlDemo NGAY TRONG VM Jenkins (10.0.4.85),
// không cần SSH / sudo / Docker.
//
// - Jenkins tự checkout code (Pipeline script from SCM) vào $WORKSPACE.
// - Chạy 1 web server Python (deploy/serve.py) ở port 8090, bind 0.0.0.0.
//   Server đọc file live từ $WORKSPACE nên mỗi lần checkout mới là site tự đổi.
// - JENKINS_NODE_COOKIE=dontKillMe: ngăn Jenkins kill server khi job kết thúc.
// - Triggers: pollSCM (deploy nhanh khi có commit) + cron (keepalive, tự bật lại
//   nếu server chết / VM reboot).
//
// Job type: Pipeline -> "Pipeline script from SCM" -> trỏ repo này -> Build Now 1 lần.
// Anh em truy cập: http://10.0.4.85:8090/keiba/SpRaceInfo.do
pipeline {
  agent any

  triggers {
    pollSCM('* * * * *')     // check commit mới mỗi phút
    cron('H/5 * * * *')      // ~5 phút/lần: đảm bảo server còn sống
  }

  options { disableConcurrentBuilds() }

  stages {
    stage('Ensure server') {
      steps {
        sh '''
          set -e
          export JENKINS_NODE_COOKIE=dontKillMe   # cho phép tiến trình sống sau job

          if pgrep -f "deploy/serve.py" >/dev/null 2>&1; then
            echo "Server đang chạy — chỉ cập nhật code (checkout đã làm)."
          else
            echo "Khởi động server..."
            cd "$WORKSPACE"
            setsid nohup python3 deploy/serve.py 8090 "$WORKSPACE" \
              >> "$WORKSPACE/serve.log" 2>&1 &
            sleep 1
          fi

          echo "--- kiểm tra ---"
          curl -sI http://127.0.0.1:8090/keiba/SpRaceInfo.do | head -1 || true
        '''
      }
    }
  }

  post {
    success { echo "OK: http://10.0.4.85:8090/keiba/SpRaceInfo.do" }
  }
}

@echo off
rem Idempotent volatile-mask session: re-applies /run systemd masks if absent.
rem Safe to run any time; a TV reboot clears /run, the next run re-applies.
chcp 65001 >nul
set "PYTHONUTF8=1"
set "PYTHONIOENCODING=utf-8"
set "PATH=%PATH%;C:\Program Files\Git\usr\bin"
C:\Users\decog\s90d-root\tools\samsung-tv-root\samsung-tv-root-0.0.12-windows-x86_64\samsung-tv-root.exe --sdb C:\Users\decog\s90d-root\tools\tizen-sdb\sdb.exe archive-root root 192.168.50.36 --command-timeout 150 --command "if [ -L /run/systemd/system/adagent-service.service ]; then echo masks-present; else for s in adagent-service.service contents-recognition-service.service contents-cognition-service-manager.service contents-ui-detector-service.service screen-analysis-service-manager.service abnormal_user_behavior.service org.tizen.remotepc.service slive-provider-daemon.service reporterCA.service scs-agent.service pushd.service register-device.service registertv-service.service registerav-service.service org.tizen.tv.tagpro-service-tv.service mirroring-recognition-manager.service aifw-msf-service.service swu-auto-upgrade.service muse-server.service org.tizen.aitech_daemon_service.service org.tizen.NPUManager.service com.samsung.tv.ai-interpreter-service.service com.samsung.tv.context-aware-agent.service com.samsung.tv.context-aware-service.service; do echo -n MASK $s: ; systemctl mask --runtime --now $s 2>&1 | head -1; done; echo REAPPLIED; fi; free | head -2"

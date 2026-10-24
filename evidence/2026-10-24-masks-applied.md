model: none
host: 192.168.50.36
runtime: 6.0
runtime source: detected
authenticated: yes
uid: 0
euid: 0
gid: 0
egid: 0
cap eff: 0000003fffffffff
smack: User
preflight capabilities: /usr/bin/dotnet cap_setgid,cap_sys_admin=ei
/usr/sbin/sdbd-tarlauncher cap_setgid,cap_setuid=eip
commands:
  - command: for s in adagent-service.service contents-recognition-service.service contents-cognition-service-manager.service contents-ui-detector-service.service screen-analysis-service-manager.service abnormal_user_behavior.service org.tizen.remotepc.service slive-provider-daemon.service reporterCA.service scs-agent.service pushd.service register-device.service registertv-service.service registerav-service.service org.tizen.tv.tagpro-service-tv.service mirroring-recognition-manager.service aifw-msf-service.service swu-auto-upgrade.service muse-server.service org.tizen.aitech_daemon_service.service org.tizen.NPUManager.service com.samsung.tv.ai-interpreter-service.service com.samsung.tv.context-aware-agent.service com.samsung.tv.context-aware-service.service; do echo $s $(systemctl is-enabled $s 2>&1) / $(systemctl is-active $s 2>&1); done
    exit code: 0
    timed out: no
    stdout: adagent-service.service masked-runtime / inactive
contents-recognition-service.service masked-runtime / inactive
contents-cognition-service-manager.service masked-runtime / inactive
contents-ui-detector-service.service masked-runtime / inactive
screen-analysis-service-manager.service masked-runtime / inactive
abnormal_user_behavior.service masked-runtime / inactive
org.tizen.remotepc.service masked-runtime / inactive
slive-provider-daemon.service masked-runtime / inactive
reporterCA.service masked-runtime / inactive
scs-agent.service masked-runtime / inactive
pushd.service masked-runtime / inactive
register-device.service masked-runtime / inactive
registertv-service.service masked-runtime / inactive
registerav-service.service masked-runtime / inactive
org.tizen.tv.tagpro-service-tv.service masked-runtime / inactive
mirroring-recognition-manager.service masked-runtime / failed
aifw-msf-service.service masked-runtime / inactive
swu-auto-upgrade.service masked-runtime / failed
muse-server.service masked-runtime / inactive
org.tizen.aitech_daemon_service.service masked-runtime / inactive
org.tizen.NPUManager.service masked-runtime / failed
com.samsung.tv.ai-interpreter-service.service masked-runtime / inactive
com.samsung.tv.context-aware-agent.service masked-runtime / inactive
com.samsung.tv.context-aware-service.service masked-runtime / inactive

    stderr: 
  - command: free | head -2
    exit code: 0
    timed out: no
    stdout:                total        used        free      shared  buff/cache   available
Mem:         1816840     1441496       93820        4040      326584      375344

    stderr: 

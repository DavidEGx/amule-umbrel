#!/bin/sh
set -eu

config_dir="${AMULE_CONFIG_DIR:-/config}"
config_file="${config_dir}/amule.conf"
download_dir="${AMULE_DOWNLOAD_DIR:-/downloads/amule}"
web_password="${APP_PASSWORD:-${AMULE_WEB_PASSWORD:-amule}}"

mkdir -p "${config_dir}" "${download_dir}/complete" "${download_dir}/incomplete"

if [ ! -f "${config_file}" ]; then
    password_hash="$(printf '%s' "${web_password}" | md5sum | cut -d' ' -f1)"

    cat >"${config_file}" <<EOF
[eMule]
AppVersion=3.0.1
Nick=aMule on Umbrel
Port=4662
UDPPort=4672
UDPEnable=1
Address=
MaxUpload=0
MaxDownload=0
SlotAllocation=2
TempDir=${download_dir}/incomplete
IncomingDir=${download_dir}/complete
ICH=1
AICHTrust=0
AddNewFilesPaused=0
StartNextFile=0
StartNextFileSameCat=0
CheckDiskspace=1
MinFreeDiskSpace=1

[ExternalConnect]
AcceptExternalConnections=1
ECAddress=127.0.0.1
ECPort=4712
ECPassword=${password_hash}
UPnPECEnabled=0
ShowProgressBar=1
ShowPercent=1
UseSecIdent=1

[WebServer]
Enabled=1
Password=${password_hash}
PasswordLow=
Port=4711
WebUPnPTCPPort=50001
UPnPWebServerEnabled=0
UseGzip=1
UseLowRightsUser=0
PageRefreshTime=10
Template=default
Path=/opt/amule/usr/bin/amuleweb

[Obfuscation]
IsClientCryptLayerSupported=1
IsCryptLayerRequested=1
IsCryptLayerRequired=0
EOF
fi

exec /opt/amule/usr/bin/amuled \
    --config-dir="${config_dir}" \
    --log-stdout \
    --use-amuleweb=/opt/amule/usr/bin/amuleweb

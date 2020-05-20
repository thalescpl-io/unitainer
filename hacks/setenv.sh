# Chrystoki.conf is expected to be in the same directory as this script
CONFIG_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export ChrystokiConfigurationPath=$CONFIG_PATH

CONFIG_FILE=Chrystoki.conf
CONFIG_FILE_BASE=Chrystoki-base.conf

if ! test -f "$CONFIG_PATH/$CONFIG_FILE_BASE"; then
  echo "$CONFIG_PATH/$CONFIG_FILE_BASE not found, ensure setenv is run inside a client directory with a $CONFIG_FILE_BASE"
  return 1
fi

# Make a tmp copy of the file.
CONFIG_FILE_TMP="$CONFIG_FILE".tmp
cp -f "$CONFIG_FILE_BASE" "$CONFIG_FILE_TMP"

ERROR=0

# Check that the expected output was provided, if so then write to tmp file, else set error flag
do_write() {
   if [ "$ERROR" -eq 0 ]; then
      echo "$1" | grep "$2" > /dev/null
      if [ "$?" -eq 0 ]; then
        # Write to file
        echo "$1" > "$CONFIG_FILE_TMP"
      else
        ERROR=1
        echo "Failed to configure $CONFIG_FILE_BASE, expected $2."
      fi
   fi
}

# Configure libCryptoki and certificate absolute paths
OUTPUT=$(sed -e "s@LibUNIX64 = .*/libs/64/libCryptoki2.so;@LibUNIX64 = $CONFIG_PATH/libs/64/libCryptoki2.so;@g" "$CONFIG_FILE_TMP")
do_write "$OUTPUT" "LibUNIX64 = $CONFIG_PATH/libs/64/libCryptoki2.so;"
OUTPUT=$(sed -e "s@PartitionCAPath = .*/partition-ca-certificate.pem;@PartitionCAPath = $CONFIG_PATH/partition-ca-certificate.pem;@g" "$CONFIG_FILE_TMP")
do_write "$OUTPUT" "PartitionCAPath = $CONFIG_PATH/partition-ca-certificate.pem;"
OUTPUT=$(sed -e "s@PartitionCertPath00 = .*/partition-certificate.pem;@PartitionCertPath00 = $CONFIG_PATH/partition-certificate.pem;@g" "$CONFIG_FILE_TMP")
do_write "$OUTPUT" "PartitionCertPath00 = $CONFIG_PATH/partition-certificate.pem;"
OUTPUT=$(sed -e "s@SSLClientSideVerifyFile = .*/server-certificate.pem;@SSLClientSideVerifyFile = $CONFIG_PATH/server-certificate.pem;@g" "$CONFIG_FILE_TMP")
do_write "$OUTPUT" "SSLClientSideVerifyFile = $CONFIG_PATH/server-certificate.pem;"
OUTPUT=$(sed -e "s@SSLConfigFile = .*/etc/openssl.cnf;@SSLConfigFile = $CONFIG_PATH/etc/openssl.cnf;@g" "$CONFIG_FILE_TMP")
do_write "$OUTPUT" "SSLConfigFile = $CONFIG_PATH/etc/openssl.cnf;"
OUTPUT=$(sed -e "s@ClientPrivKeyFile = .*/etc/ClientNameKey.pem;@ClientPrivKeyFile = $CONFIG_PATH/etc/ClientNameKey.pem;@g" "$CONFIG_FILE_TMP")
do_write "$OUTPUT" "ClientPrivKeyFile = $CONFIG_PATH/etc/ClientNameKey.pem;"
OUTPUT=$(sed -e "s@ClientCertFile = .*/etc/ClientNameCert.pem;@ClientCertFile = $CONFIG_PATH/etc/ClientNameCert.pem;@g" "$CONFIG_FILE_TMP")
do_write "$OUTPUT" "ClientCertFile = $CONFIG_PATH/etc/ClientNameCert.pem;"
OUTPUT=$(sed -e "s@ServerCAFile = .*/etc/CAFile.pem;@ServerCAFile = $CONFIG_PATH/etc/CAFile.pem;@g" "$CONFIG_FILE_TMP")
do_write "$OUTPUT" "ServerCAFile = $CONFIG_PATH/etc/CAFile.pem;"

if ! cat "$CONFIG_FILE_TMP" | grep -qoP "^[ ]*LunaG5Slots[ ]*=[ ]*0[ ]*;$"; then
   OUTPUT=$(sed '/CardReader.*/a\ \ LunaG5Slots = 0;' "$CONFIG_FILE_TMP")
   do_write "$OUTPUT" "LunaG5Slots = 0;"
fi

# Convert existing partition data to new format
PAR_DATA=$(grep -oP "^[ ]*PartitionData00[ ]*=[ ]*\d+[ ]*,[ ]*\S+[ ]*,[ ]*\d+[ ]*;$" "$CONFIG_FILE_TMP")
if [ "$?" -eq 0 ]; then
  # Get server name and port from partition data.
  IFS=',' read -r -a PAR_DATA <<< $(echo $PAR_DATA | cut -d= -f2 | tr -d [:space:])
  SERVER_NAME="${PAR_DATA[1]}"
  SERVER_PORT="${PAR_DATA[2]}"

  sed -i '/PartitionData00.*/d' "$CONFIG_FILE_TMP"
  OUTPUT=$(sed '/REST.*/a\ \ ServerPort = '"$SERVER_PORT" "$CONFIG_FILE_TMP")
  do_write "$OUTPUT" "ServerPort = $SERVER_PORT"
  OUTPUT=$(sed '/REST.*/a\ \ ServerName = '"$SERVER_NAME;" "$CONFIG_FILE_TMP")
  do_write "$OUTPUT" "ServerName = $SERVER_NAME;"
  OUTPUT=$(sed '/Misc.*/a\ \ PluginModuleDir = '"$CONFIG_PATH/libs/64/plugins;" "$CONFIG_FILE_TMP")
else
  # Ensure absolute path
  OUTPUT=$(sed -e "s@PluginModuleDir = .*/libs/64/plugins/libdpod.plugin;@PluginModuleDir = $CONFIG_PATH/libs/64/plugins;@g" "$CONFIG_FILE_TMP")
fi
do_write "$OUTPUT" "PluginModuleDir = $CONFIG_PATH/libs/64/plugins;"

if [ "$ERROR" -eq 0 ]; then
  mv -f "$CONFIG_FILE_TMP" "$CONFIG_FILE"
else
  rm -f "$CONFIG_FILE_TMP"
fi

#!/bin/bash

function addProperty() {
  local path=$1
  local name=$2
  local value=$3

  local entry="<property><name>$name</name><value>${value}</value></property>"
  local escapedEntry=$(echo $entry | sed 's/\//\\\//g')
  sed -i "/<\/configuration>/ s/.*/${escapedEntry}\n&/" $path
}

function configure() {
    local path=$1
    local module=$2
    local envPrefix=$3

    local var
    local value

    echo "Configuring $module"
    for c in `printenv | perl -sne 'print "$1 " if m/^${envPrefix}_(.+?)=.*/' -- -envPrefix=$envPrefix`; do
        name=`echo ${c} | perl -pe 's/___/-/g; s/__/@/g; s/_/./g; s/@/_/g;'`
        var="${envPrefix}_${c}"
        value=${!var}
        echo " - Setting $name=$value"
        addProperty $path $name "$value"
    done
}

configure /opt/hbase-1.2.6/conf/hbase-site.xml hbase HBASE_CONF

#/opt/hbase-2.4.5/bin/hbase-daemon.sh start thrift -p 16040 --infoport 16050
#/opt/hbase-2.4.5/bin/hbase-daemon.sh start rest -p 16060 --infoport 16070
#/opt/hbase-2.4.5/bin/hbase master start

/opt/hbase-1.2.6/bin/start-hbase.sh
/opt/hbase-1.2.6/bin/hbase-daemon.sh start thrift -p 16040 --infoport 16050
/opt/hbase-1.2.6/bin/hbase-daemon.sh start rest -p 16060 --infoport 16070
tail -f /opt/hbase-1.2.6/logs/*

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

# Wait for namenode
sleep 600

configure /opt/oozie-4.2.0/conf/hadoop-conf/core-site.xml oozie OOZIE_CONF
#configure /opt/oozie-4.2.0/conf/hadoop-conf/core-site.xml core CORE_CONF
configure /opt/oozie-4.2.0/conf/hadoop-conf/hdfs-site.xml hdfs HDFS_CONF
configure /opt/oozie-4.2.0/conf/hadoop-conf/yarn-site.xml yarn YARN_CONF
configure /opt/oozie-4.2.0/conf/hadoop-conf/httpfs-site.xml httpfs HTTPFS_CONF
configure /opt/oozie-4.2.0/conf/hadoop-conf/kms-site.xml kms KMS_CONF
configure /opt/oozie-4.2.0/conf/hadoop-conf/mapred-site.xml mapred MAPRED_CONF

echo -e "\nexport OOZIE_URL=http://localhost:11000/oozie\n" >> /home/hdfs/.bashrc

/opt/oozie-4.2.0/bin/oozie-setup.sh sharelib create -fs hdfs://namenode:8020
/opt/oozie-4.2.0/bin/oozied.sh run

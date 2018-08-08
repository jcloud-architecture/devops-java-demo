#!/bin/bash
#
# 1.下载jdk和maven3.0.5,为编译作准备
# 2.进行maven编译(依赖assembly)
# 3.替换启动脚本(线上和本地的启动参数可能不一样)
# 4.打包
# lishipu1@jd.com
#

set -eu
Prompt(){
	echo "[$(date '+%D %H:%M:%S')] $@"
}

WORKSPACE=$(cd $(dirname $0); pwd)
Prompt "Work dir: $WORKSPACE"

cd $WORKSPACE

#export PATH=$WORKSPACE/opbin/apache-maven-3.0.5/bin:$PATH

Prompt "Setting up environment variables ..."
#export JAVA_HOME=$WORKSPACE/opbin/jdk1.8.0_111
#export PATH=$JAVA_HOME/bin:$PATH

export LANG="en_US.UTF-8"

#if [ ! -d $JAVA_HOME ]
#then
#    Prompt "download and unzip jdk ..."
#    cd $WORKSPACE/opbin && \
#     curl http://172.22.132.84/hawkeye-deps/jdk-8u111-linux-x64.tar.gz > jdk-8u111-linux-x64.tar.gz \
#     && tar zxf jdk-8u111-linux-x64.tar.gz && cd -
#    #cd $WORKSPACE/opbin && tar zxf jdk1.8.0_111-linux-x64.tar.gz && cd -
#fi

#readonly LOCAL_MVN=$(which mvn)
#if test -z ${LOCAL_MVN}
#then
Prompt "download and unzip maven, copy setttings ..."
#cd $WORKSPACE/opbin && \
# curl http://172.22.132.84/hawkeye-deps/apache-maven-3.0.5-bin.tar.gz > apache-maven-3.0.5-bin.tar.gz \
# && tar zxf apache-maven-3.0.5-bin.tar.gz && cp -f settings.xml apache-maven-3.0.5/conf && cd -
#cd $WORKSPACE/opbin && tar zxf apache-maven-3.0.5-bin.tar.gz && cp -f settings.xml apache-maven-3.0.5/conf && cd -
#export PATH=$WORKSPACE/opbin/apache-maven-3.0.5/bin:$PATH
#fi

#Prompt "JAVA_HOME::"$JAVA_HOME
#Prompt "PATH::"$PATH

Prompt "Setting up environment variables OK..."


OUTPUT=$WORKSPACE/target/ark-1.0-SNAPSHOT-all/output

Prompt "Clean and Package"
mvn clean -U package -Dmaven.test.skip=true || exit $?
#mvn clean package || exit $?
#mvn clean cobertura:cobertura || exit $?

Prompt "Package for deploy"
rm -fr $WORKSPACE/output
mv $OUTPUT ./

Prompt "Copy file"
mkdir $WORKSPACE/output/opbin

#cp -r $WORKSPACE/target/ranger-server-1.0-SNAPSHOT-all/output/* $WORKSPACE/output/
#cp $WORKSPACE/swagger/swagger-ui.tar.gz $WORKSPACE/output/ && cd $WORKSPACE/output && tar -xzf swagger-ui.tar.gz && \
#rm -f swagger-ui.tar.gz && cd - > /dev/null
#cp $WORKSPACE/opbin/zookeeper.tar.gz $WORKSPACE/output/opbin
#cp $WORKSPACE/opbin/redis.tar.gz $WORKSPACE/output/opbin
#rm -rf $WORKSPACE/output/opbin/opbin

Prompt "Generate version and timestamp..."
echo $(date -d  today +%Y%m%d%H%M%S) > $WORKSPACE/output/version
git log | head -1 | awk '{print $2}' >> $WORKSPACE/output/version
Prompt "version::"`cat $WORKSPACE/output/version`

Prompt "replace control"

if [ "$COMPILER_TYPE" = "IMAGE" ]; then
    Prompt "rename control_image to control"
    mv $WORKSPACE/output/bin/control_image $WORKSPACE/output/bin/control
elif [ "$COMPILER_TYPE" = "PACKAGE" ];then
    Prompt "rename control_package to control"
    mv $WORKSPACE/output/bin/control_package $WORKSPACE/output/bin/control
    curl http://172.22.132.84/hawkeye-deps/jdk-8u111-linux-x64.tar.gz > $WORKSPACE/output/jdk-8u111-linux-x64.tar.gz
fi


Prompt "build finish exit:"$?

exit $?

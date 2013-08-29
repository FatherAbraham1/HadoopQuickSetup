#!/bin/sh

if [ -f /root/.bashrc ] ; then
    sed -i '/^export[[:space:]]\{1,\}JAVA_HOME[[:space:]]\{0,\}=/d' /root/.bashrc
    sed -i '/^export[[:space:]]\{1,\}CLASSPATH[[:space:]]\{0,\}=/d' /root/.bashrc
    sed -i '/^export[[:space:]]\{1,\}PATH[[:space:]]\{0,\}=/d' /root/.bashrc
fi
echo "" >>/root/.bashrc
echo "export JAVA_HOME=/usr/java/latest" >>/root/.bashrc
echo "export CLASSPATH=.:\$JAVA_HOME/lib/tools.jar:\$JAVA_HOME/lib/dt.jar">>/root/.bashrc
echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> /root/.bashrc

alternatives --install /usr/bin/java java /usr/java/latest 5
alternatives --set java /usr/java/latest 

source /root/.bashrc

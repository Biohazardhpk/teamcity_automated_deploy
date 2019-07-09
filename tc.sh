#!/usr/bin/env bash

#Just a quick check
echo "~~~~~~~~~This script will install MySQL "Ver 14.14 Distrib 5.7.26", Java "1.8.0_131", TeamCity "10.0.2" and Apache Maven "3.6.0" ~~~~~~~~~ "
echo " "
echo " "

# Changing the privilege level to root
sudo su <<'EOF'
## Install Java 8
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Installing  Java 8 !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "deb http://debian.opennms.org/ stable main" >> /etc/apt/sources.list
sudo wget -O - http://debian.opennms.org/OPENNMS-GPG-KEY | sudo apt-key add -
sudo apt-get update -y
sleep 3
echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
sudo apt-get install oracle-java8-installer -y
sleep 3

##Install MySQL
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Installing  MySQL !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
sudo apt-get update -y
sudo apt-get install mysql-server -y
sleep 3

# Configure MySQL for TC user
/usr/bin/mysql -u root -p='' <<MYSQL_SCRIPT
create database teamcity collate utf8_bin;
create user teamcity identified by 'teamcity';
grant all privileges on teamcity.* to teamcity;
grant process on *.* to teamcity;
MYSQL_SCRIPT
sleep 3

#Install TC
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Installing  TeamCity !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
cd /opt
sudo wget https://download-cf.jetbrains.com/teamcity/TeamCity-10.0.2.tar.gz
sudo tar -xzvf TeamCity-10.0.2.tar.gz
sudo useradd teamcity
sudo chown -R teamcity:teamcity /opt/TeamCity
sleep 3

###Create the configuration for TC startup
sudo touch /etc/init.d/teamcity
sudo chmod +x /etc/init.d/teamcity
sudo cat <<EOL >> /etc/init.d/teamcity
export TEAMCITY_DATA_PATH="/opt/TeamCity/.BuildServer"

case \$1 in
  start)
    echo "Starting Team City"
    start-stop-daemon --start  -c teamcity --exec /opt/TeamCity/bin/teamcity-server.sh start
    ;;
  stop)
    echo "Stopping Team City"
    start-stop-daemon --start -c teamcity  --exec  /opt/TeamCity/bin/teamcity-server.sh stop
    ;;
  restart)
    echo "Restarting Team City"
    start-stop-daemon --start  -c teamcity --exec /opt/TeamCity/bin/teamcity-server.sh stop
    start-stop-daemon --start  -c teamcity --exec /opt/TeamCity/bin/teamcity-server.sh start
    ;;
  *)
    echo "Usage: /etc/init.d/teamcity {start|stop|restart}"
    exit 1
    ;;
esac

exit 0
EOL

###Setup TC startup
sudo update-rc.d teamcity defaults
sudo chmod +x /etc/init.d/teamcity
sudo /etc/init.d/teamcity start
sleep 3

### Create an Agent on the server
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Creating Agent on TC !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
cd /etc/init.d/
sudo touch /etc/init.d/buildAgent
sudo chmod +x /etc/init.d/buildAgent
sudo cat <<EOL >> /etc/init.d/buildAgent
#!/bin/sh
### BEGIN INIT INFO
# Provides:          TeamCity Build Agent
# Required-Start:    \$remote_fs \$syslog
# Required-Stop:     \$remote_fs \$syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start build agent daemon at boot time
# Description:       Enable service provided by daemon.
### END INIT INFO
#Provide the correct user name:
USER="teamcity"
 
case "\$1" in
start)
 su - \$USER -c "cd BuildAgent/bin ; ./agent.sh start"
;;
stop)
 su - \$USER -c "cd BuildAgent/bin ; ./agent.sh stop"
;;
*)
  echo "usage start/stop"
  exit 1
 ;;
 
esac
 
exit 0
EOL

###Update system to use the agent

sudo update-rc.d buildAgent defaults
/opt/TeamCity/buildAgent/bin/agent.sh start
sleep 3

###Fix MySQL TC link
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Tweaking TC !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
sudo wget -P /opt http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.40.tar.gz
sudo tar -xzvf /opt/mysql-connector-java-5.1.40.tar.gz --directory /opt/
sleep 3
sudo -u teamcity mkdir -p /opt/TeamCity/.BuildServer /opt/TeamCity/.BuildServer/lib /opt/TeamCity/.BuildServer/lib/jdbc
sudo mv /opt/mysql-connector-java-5.1.40/mysql-connector-java-5.1.40-bin.jar /opt/TeamCity/.BuildServer/lib/jdbc/
sudo chown teamcity:teamcity /opt/TeamCity/.BuildServer/lib/jdbc/mysql-connector-java-5.1.40-bin.jar
sudo /etc/init.d/teamcity restart
sleep 3

###Install Maven on the agent
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Installing Maven on Agent !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
sudo apt-get update -y
sudo apt-get install maven -y
sudo apt-get install default-jdk

sudo cat <<EOL >> /etc/profile.d/maven.sh
export JAVA_HOME=/usr/lib/jvm/default-java
export M2_HOME=/opt/maven
export MAVEN_HOME=/opt/maven
export PATH=\${M2_HOME}/bin:\${PATH}

EOL

sudo chmod +x /etc/profile.d/maven.sh
source /etc/profile.d/maven.sh

#Final system reload
sudo /etc/init.d/teamcity restart
sleep 3

/opt/TeamCity/buildAgent/bin/agent.sh stop
sleep 1
/opt/TeamCity/buildAgent/bin/agent.sh start
sleep 3


EOF

echo ' '
echo ' '
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Login into TeamCity by accessing http://localhost:8111 !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
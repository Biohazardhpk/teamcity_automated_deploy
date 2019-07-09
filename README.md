# TeamCity automated deployment on a Windows Machine
This repo provides a quick setup for a functional TeamCity server using Vagrant and VirtualBox on a windows machine.

# Prerequisites.
___
  1) Cocolatey installation: (https://chocolatey.org/docs/installation)
  
  2) Install latest version of Vagrant fom the cmd:

    > choco install vagrant
  3) Install latest version of VirtualBox fom the cmd:

    > choco install virtualbox
___

# Deployment
The environment setup results in the deployment and configuration of MySQL "Ver 14.14 Distrib 5.7.26", Java "1.8.0_131", TeamCity "10.0.2" and Apache Maven "3.6.0".  
This deployment is the result of the guides/documentation available here:
  - PluralSight TeamCity Getting Started  
    https://app.pluralsight.com/player?course=teamcity-getting-started&author=wes-mcclure&name=teamcity-getting-started-m5&clip=0&mode=live
  - TeamCity Install  
https://www.youtube.com/watch?v=ey5_-p4gB6w  
https://coderscoffeehouse.com/tech/2017/04/07/teamcity-linux-setup.html   
  - MySQL  
https://support.rackspace.com/how-to/installing-mysql-server-on-ubuntu/  
  - Maven install:  
https://linuxize.com/post/how-to-install-apache-maven-on-ubuntu-18-04/  
  - JDK install  
https://deb.pkgs.org/universal/opennms-stable-amd64/oracle-java8-installer_8u131-1~webupd8~2_all.deb.html  
  - TeamCity configuration  
https://www.jetbrains.com/teamcity/documentation/  
https://confluence.jetbrains.com/display/TW/Documentation  
  
## Steps:
___

1) Clone or download the repo to your local PC  
___

2) Navigate to the respective folder and issue the vagrant command to setup the environment:  

    > vagrant up
    
*once the setup finishes the environment should be accessible at: http://localhost:8111
___

3) For the initial setup and demo project some mannual steps are required:
___
  a) Database connection setup and username (MySQL is selected and U: teamcity P: teamcity)  
![](https://github.com/Biohazardhpk/teamcity_automated_deploy/blob/master/images/1.PNG)  
  b) Deploy Windows Agent. In step 1 the actual deploy is a wizard in which te only configurable item is the server address(http://http://localhost:8111)  
![](https://github.com/Biohazardhpk/teamcity_automated_deploy/blob/master/images/2.PNG)

# Authors

Copyright (C)Eduard LUCHIAN : eduard.luchian89@gmail.com

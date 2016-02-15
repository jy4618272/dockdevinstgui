
FROM docker.io/ubuntu
MAINTAINER Nick Vidiadakis

# Install requirements, java and eclipse
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:webupd8team/java -y && \
    apt-get update && \
    echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get install -y oracle-java8-installer && \
    apt-get install -y nginx postgresql git nodejs npm supervisor wget && \
    apt-get install -y oracle-java8-installer libxext-dev libxrender-dev libxtst-dev && \
    apt-get update && apt-get install -y libgtk2.0-0 libcanberra-gtk-module && \
    wget http://eclipse.c3sl.ufpr.br/technology/epp/downloads/release/mars/1/eclipse-jee-mars-1-linux-gtk-x86_64.tar.gz -O /tmp/eclipse.tar.gz -q && \
    tar -xf /tmp/eclipse.tar.gz -C /opt && \
    rm /tmp/eclipse.tar.gz && \
    apt-get clean && \
    npm install -g cordova && \
    npm update -g && \
    ln -s /usr/bin/nodejs /usr/bin/node && \
    mkdir /var/run/sshd && \
    mkdir -p /home/developer && \
    echo "developer:x:1000:1000:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
    echo "developer:x:1000:" >> /etc/group && \
    echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer && \
    chmod 0440 /etc/sudoers.d/developer && \
    chown developer:developer -R /home/developer && \
    chown root:root /usr/bin/sudo && chmod 4755 /usr/bin/sudo

RUN dpkg-divert --local --rename --add /sbin/initctl && ln -sf /bin/true /sbin/initctl

# Install GNOME and tightvnc server.
RUN apt-get update && apt-get install -y xorg gnome-core gnome-session-fallback tightvncserver libreoffice

# Pull in the hack to fix keyboard shortcut bindings for GNOME 3 under VNC
ADD https://raw.githubusercontent.com/CannyComputing/Dockerfile-Ubuntu-Gnome/master/gnome-keybindings.pl /usr/local/etc/gnome-keybindings.pl
RUN chmod +x /usr/local/etc/gnome-keybindings.pl

# Add the script to fix and customise GNOME for docker
ADD https://raw.githubusercontent.com/CannyComputing/Dockerfile-Ubuntu-Gnome/master/gnome-docker-fix-and-customise.sh /usr/local/etc/gnome-docker-fix-and-customise.sh
RUN chmod +x /usr/local/etc/gnome-docker-fix-and-customise.sh

# Set up VNC
# Password is "acoman"
RUN mkdir -p /root/.vnc
ADD https://raw.githubusercontent.com/CannyComputing/Dockerfile-Ubuntu-Gnome/master/xstartup /root/.vnc/xstartup
RUN chmod 755 /root/.vnc/xstartup
ADD https://raw.githubusercontent.com/CannyComputing/Dockerfile-Ubuntu-Gnome/master/spawn-desktop.sh /usr/local/etc/spawn-desktop.sh
RUN chmod +x /usr/local/etc/spawn-desktop.sh
RUN apt-get install -y expect
ADD https://raw.githubusercontent.com/CannyComputing/Dockerfile-Ubuntu-Gnome/master/start-vnc-expect-script.sh /usr/local/etc/start-vnc-expect-script.sh
RUN chmod +x /usr/local/etc/start-vnc-expect-script.sh
ADD https://raw.githubusercontent.com/CannyComputing/Dockerfile-Ubuntu-Gnome/master/vnc.conf /etc/vnc.conf

CMD bash -C '/usr/local/etc/spawn-desktop.sh';'/bin/bash'

EXPOSE 5901
   
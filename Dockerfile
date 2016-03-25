############################################################
# Dockerfile to run Datascience Enviroment
# Based on Ubuntu Image with python Libaries
############################################################

FROM ubuntu

# Export env settings and set locals
RUN locale-gen "en_US.UTF-8"
RUN dpkg-reconfigure locales
ENV TERM=xterm
ENV LANG en_US.UTF-8

# Update Ubuntu
RUN apt-get update -y && apt-get install build-essential -y

# Install the needed developement packages
ADD apt-packages.txt /tmp/apt-packages.txt
RUN xargs -a /tmp/apt-packages.txt apt-get install -y

RUN pip install virtualenv
RUN mkdir -p /opt/ds/

RUN /usr/local/bin/virtualenv /opt/ds --python=/usr/bin/python3 --system-site-packages

ADD /requirements/ /tmp/requirements/

RUN /opt/ds/bin/pip install -r /tmp/requirements/pre-requirements.txt
RUN /opt/ds/bin/pip install -r /tmp/requirements/requirements.txt

RUN useradd --create-home --home-dir /home/ds --shell /bin/bash ds
RUN chown -R ds /opt/ds
RUN adduser ds sudo

ADD run_ipython.sh /home/ds
RUN chmod +x /home/ds/run_ipython.sh
RUN chown ds /home/ds/run_ipython.sh

ADD .bashrc.template /home/ds/.bashrc

EXPOSE 8888
RUN usermod -a -G sudo ds
RUN echo "ds ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
USER ds
RUN mkdir -p /home/ds/notebooks
ENV HOME=/home/ds
ENV SHELL=/bin/bash
ENV USER=ds
VOLUME /home/ds/notebooks
WORKDIR /home/ds/notebooks

CMD ["/home/ds/run_ipython.sh"]

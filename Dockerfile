FROM centos:7.4.1708
LABEL MAINTAINER="2775147135@qq.com"
RUN set -x; \
    rm -rf /etc/yum.repos.d/{CentOS-CR.repo,CentOS-Debuginfo.repo,CentOS-fasttrack.repo,CentOS-Media.repo,CentOS-Sources.repo,CentOS-Vault.repo} \
   && yum -y install ca-certificates python-dev python-devel.x86_64 curl wget gcc gcc-c++ python-gevent python-ldap python-qrcode \
   && yum clean packages && yum clean headers && yum clean all

WORKDIR /opop

# 建议先把包下载到内网中
ADD https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.2.1/wkhtmltox-0.12.2.1_linux-centos7-amd64.rpm /opop

RUN echo "2723ce77990f0f10933e48211c0e4f105563e223 wkhtmltox-0.12.2.1_linux-centos7-amd64.rpm" | sha1sum -c -
RUN yum -y install /opop/wkhtmltox-0.12.2.1_linux-centos7-amd64.rpm \
    && yum clean packages && yum clean headers && yum clean all

RUN rm -rf wkhtmltox-0.12.2.1_linux-centos7-amd64.rpm 
RUN yum -y install epel-release && yum -y install python-pip \
    && pip install --upgrade pip \
    && pip install psycogreen==1.0.1 \
    && pip install psutil==2.2.1

WORKDIR /opop

RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | bash \
    && echo export NVM_DIR="\$HOME/.nvm" >> /etc/profile \
    && echo "[ -s \"\$NVM_DIR/nvm.sh\" ] && \. \"\$NVM_DIR/nvm.sh\"" >> /etc/profile \
    && echo "[ -s \"\$NVM_DIR/bash_completion\" ] && \. \"\$NVM_DIR/bash_completion\"" >>/etc/profile 
CMD [ "/bin/bash", "-c", "source", "/etc/profile" ] \
    && nvm install --lts && npm install -g less

RUN echo y | pip uninstall urllib3

# Install Odoo
# http://nightly.odoo.com/10.0/nightly/rpm/odoo_10.0.20190128.noarch.rpm
# 建议先把包下载到内网中
RUN wget http://192.168.1.129:8011/package/linux/odoo/odoo_10.0.20190128.noarch.rpm \
    && wget http://download-ib01.fedoraproject.org/pub/epel/7/x86_64/Packages/p/python2-psutil-2.2.1-4.el7.x86_64.rpm \
    && mv /usr/lib64/python2.7/site-packages/psutil-2.2.1-py2.7.egg-info{,.bak} \
    && yum -y install python2-psutil-2.2.1-4.el7.x86_64.rpm \
    && yum -y install odoo_10.0.20190128.noarch.rpm \
    && yum clean packages && yum clean headers && yum clean all && rm -rf /var/cache/yum

# Copy entrypoint script and Odoo configuration file
RUN chown -R odoo.odoo /usr/lib/python2.7/site-packages/odoo/ 

COPY ./entrypoint.sh / 
COPY ./odoo.conf /etc/odoo/ 
RUN chmod 777 /entrypoint.sh \
    && chmod 777 /etc/odoo/odoo.conf

RUN chown odoo /etc/odoo/odoo.conf

# Mount /var/lib/odoo to allow restoring filestore and /mnt/extra-addons for users addons
RUN mkdir -p /mnt/extra-addons \
        && chown -R odoo /mnt/extra-addons

VOLUME ["/var/lib/odoo", "/mnt/extra-addons"]

# Expose Odoo services
EXPOSE 8069 8071

# Set the default config file
ENV ODOO_RC /etc/odoo/odoo.conf

# Set default user when running the container
USER odoo

ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo"]

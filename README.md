# odoo10
Open Source ERP and CRM

$ cat /etc/centos-release

         CentOS Linux release 7.4.1708 (Core)

$ uname -r

         3.10.0-693.el7.x86_64


官网参考：
https://hub.docker.com/_/odoo

    docker run -d -e POSTGRES_USER=odoo -e POSTGRES_PASSWORD=123456 -e POSTGRES_DB=postgres --name db postgres:10

    docker run -p 8069:8069 --name odoo -v addons:/usr/lib/python2.7/dist-packages/odoo/addons --link db:db -t odoo:10.0

注1：--link指的db是PostgreSQL容器的名字 

注2：addons为 "上面" 的目录


停止并重新启动Odoo实例:

    docker stop odoo
    
    docker start -a odoo


使用自定义配置运行Odoo:

服务器的默认配置文件（/etc/odoo/odoo.conf）可以在启动时使用卷覆盖。 假设您在/path/to/config/odoo.conf中有自定义配置

    docker run -v /path/to/config:/etc/odoo -p 8069:8069 --name odoo --link db:db -t odoo:10.0

容器插件位置：/mnt/extra-addons


运行多个Odoo实例：
    
    docker run -p 8070:8069 --name odoo2 --link db:db -t odoo

    docker run -p 8071:8069 --name odoo3 --link db:db -t odoo

请注意，为了明确使用邮件和报告功能，当主机和容器端口不同时（例如8070和8069），必须在Odoo中设置设置 - >参数 - >系统参数（需要技术特性），web。 base.url到容器端口（例如127.0.0.1:8069）。


环境变量
调整这些环境变量以轻松连接到postgres服务器：

HOST：postgres服务器的地址。 如果您使用了postgres容器，请设置为容器的名称。 默认为db。

PORT：postgres服务器正在侦听的端口。 默认为5432。

USER：Odoo将与之连接的postgres角色。 如果您使用了postgres容器，请将其设置为与POSTGRES_USER相同的值。 默认为odoo。

PASSWORD：Odoo将与之连接的postgres角色的密码。 如果您使用了postgres容器，请将其设置为与POSTGRES_PASSWORD相同的值。 默认为odoo。

访问：
http://You_IP:8069
(创建odoo容器时映射的就是到的8069)

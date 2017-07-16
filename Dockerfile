# https://bugs.alpinelinux.org/issues/7372
# do not use latest alpine until this bug will be fixed
FROM alpine:3.5

ARG LCT_NAME="U2000WebLCTV100R009C00SPC302_en_win32_x86.zip"
ARG LCT_DIST="data/${LCT_NAME}"
ARG LCT_PORT="13002"

LABEL Description="iManager U2000 Web LCT" \
      Maintainer="spiderx@spiderx.dp.ua"

ENV LANG C.UTF-8
ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk/jre
ENV JAVA_VERSION 8u121
ENV JAVA_ALPINE_VERSION 8.121.13-r0
# Disable fontconfig warning (https://github.com/docker-library/openjdk/issues/73)
ENV FC_LANG en-US

#COPY ${LCT_DIST} /tmp/
#ADD ftp://jupiter.spiderx.dp.ua/docker/imanager-u2000-web-lct/U2000WebLCTV100R009C00SPC302_en_win32_x86.zip /tmp/

WORKDIR /app/WebLCT

# Create properties for log4j, use fonts from WebLCT dist,
# disable connections only from localhost
RUN set -ex && \
    apk --update add curl fontconfig openjdk8-jre  \
    && curl -fL ftp://jupiter.spiderx.dp.ua/docker/imanager-u2000-web-lct/${LCT_NAME} -o /tmp/ \
    && unzip /tmp/${LCT_NAME} -d .. && \
    touch web_app/conf/log4j.properties && \
    sed -i 's/l>0/l>1/' weblct/plugins/com.huawei.weblct.rwcfgfile/common/conf/system.xml && \
    rm -rf /var/cache/apk/* /tmp/${LCT_NAME} && \
    mkdir -p /usr/share/fonts/ && \
    ln -s /app/WebLCT/jre/lib/fonts/ /usr/share/fonts/

EXPOSE ${LCT_PORT}/tcp

# # List of properties: https://ops4j1.jira.com/wiki/display/paxweb/Basic+Configuration
ENTRYPOINT exec java -DappName=weblct -DdeploymentMode=independent -DinstanceName=java_1 -DAppPath=/weblct \
           -Dorg.osgi.service.http.port=13002 -Dorg.ops4j.pax.web.session.timeout=30 -Dfile.encoding=UTF-8 \
           -Xms128m -Xmx512m -XX:+HeapDumpOnOutOfMemoryError -Djava.class.path=bin/com.huawei.uflight.osgistarter.jar:plugins/org.eclipse.osgi_3.5.1.R35x_v20090827.jar \
           com.huawei.uflight.FrameworkStarter -clean -configuration conf

# works with params from console
#ENTRYPOINT ["java", "-DappName=weblct -DdeploymentMode=independent -DAppPath=/weblct -Dorg.ops4j.pax.web.session.timeout=30 -Dfile.encoding=UTF-8"]
#CMD ["-DinstanceName=java_1 -Dorg.osgi.service.http.port=13002 -Xms128m -Xmx512m -XX:+HeapDumpOnOutOfMemoryError -Djava.class.path=bin/com.huawei.uflight.osgistarter.jar:plugins/org.eclipse.osgi_3.5.1.R35x_v20090827.jar com.huawei.uflight.FrameworkStarter -clean -configuration conf"]

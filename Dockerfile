#
# docker build -t pmfa/wavesnode-container .
#
# docker run -it -v /home/u/var/wavesmainnet:/var/lib/waves -v waves.conf:/etc/waves -p 6868:6868 -p 6886:6886 -p 127.0.0.1:6869:6869 pmfa/wavesnode-container
#

FROM ubuntu:latest

RUN export DEBIAN_FRONTEND=noninteractive && apt-get -qq update && apt-get -qqy upgrade && apt-get -qqy install curl openjdk-8-jre-headless && apt-get -qqy clean
RUN curl -s -L -o   /waves.deb https://github.com/wavesplatform/Waves/releases/download/v1.0.0/waves_1.0.0_all.deb && dpkg -i waves.deb
EXPOSE 6868 6886 6869
USER waves:waves
CMD ["/usr/share/waves/bin/waves","/etc/waves/waves.conf"]


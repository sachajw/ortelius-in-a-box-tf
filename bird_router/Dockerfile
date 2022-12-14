FROM ubuntu:18.04 AS builder
RUN apt update
RUN apt -y upgrade
RUN apt-get -q -y install \
  iproute2 \
  tcpdump \
  iputils-ping \
  readline-common \
  libreadline7 \
  libssh-4 \
  inotify-tools \
  curl \
  build-essential \
  flex \
  bison \
  libncurses-dev \
  libreadline-dev \
  libssh-dev \
  git

RUN curl -LOk https://bird.network.cz/download/bird-2.0.9.tar.gz
RUN tar xvf bird-2.0.9.tar.gz
WORKDIR /bird-2.0.9
RUN ./configure
RUN make

FROM ubuntu:18.04
RUN apt update
RUN apt -y upgrade
RUN apt-get -q -y install \
  iproute2 \
  tcpdump \
  iputils-ping \
  readline-common \
  libreadline7 \
  libssh-4 \
  inotify-tools
RUN mkdir -p /usr/local/var/run
COPY --from=builder /bird-2.0.9/bird /usr/local/sbin/bird
COPY --from=builder /bird-2.0.9/birdc /usr/local/sbin/birdc
COPY birdvars.conf /usr/local/include/birdvars.conf
COPY wrapper.sh /wrapper.sh
COPY reconfig.sh /reconfig.sh
COPY docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
# CMD ["bird",  "-fR"]
CMD ./wrapper.sh

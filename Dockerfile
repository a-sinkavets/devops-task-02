FROM ubuntu:latest

ARG PLATFORM=linux/amd64
ARG ARCH=x86_64
ARG SIGNATURE=01EA5486DE18A882D4C2684590C8019E36C2E964
ENV VERSION=0.21.0
ENV PATH=/opt/bitcoin-${VERSION}/bin:$PATH

RUN apt update -y && apt upgrade -yq
RUN apt install -y wget gnupg gosu
RUN apt clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN wget https://bitcoincore.org/bin/bitcoin-core-${VERSION}/bitcoin-${VERSION}-${ARCH}-linux-gnu.tar.gz \
  && wget https://bitcoincore.org/bin/bitcoin-core-${VERSION}/SHA256SUMS.asc \
  && gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys ${SIGNATURE} \
  && gpg --verify SHA256SUMS.asc \
  && grep bitcoin-${VERSION}-${ARCH}-linux-gnu.tar.gz SHA256SUMS.asc | sha256sum -c - \
  && tar -xzf bitcoin-${VERSION}-${ARCH}-linux-gnu.tar.gz -C /opt \
  && rm bitcoin-${VERSION}-${ARCH}-linux-gnu.tar.gz SHA256SUMS.asc \
  && rm /opt/bitcoin-${VERSION}/bin/bitcoin-qt /opt/bitcoin-${VERSION}/bin/test_bitcoin

VOLUME ["/home/bitcoin/.bitcoin"]
EXPOSE 8332 8333 18332 18333 18443 18444 38333 38332

CMD ["sh","-c", "bitcoind -daemon -debuglogfile=/var/log/bitcoind.log && tail -f /var/log/bitcoind.log"]

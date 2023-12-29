FROM ubuntu:20.04 as container_re
ENV VERSION=v3.8.0
WORKDIR /root/
RUN apt update
RUN apt install -y tzdata
RUN apt install -y build-essential make cmake pkg-config git libssl-dev wget ca-certificates libz-dev && \
    git clone -b ${VERSION} --depth=1 https://github.com/baresip/re.git && \
    cd re && \
    cmake -B build -DCMAKE_BUILD_TYPE=Release && \
    cmake --build build -j && \
    cmake --install build --prefix dist && cp -a dist/* /usr/

FROM container_re as container_baresip
ENV VERSION=v3.8.0
WORKDIR /root/
RUN apt update
RUN apt-get install -y libopus-dev libasound2-dev libmosquitto-dev libspandsp-dev libpulse-dev
RUN git clone -b ${VERSION} --depth=1 https://github.com/baresip/baresip.git && \
    cd baresip && \
    ldconfig && \
    cmake -B build -DCMAKE_BUILD_TYPE=Release && \
    cmake --build build -j && \
    cmake --install build --prefix dist && cp -a dist/* /usr/


FROM balenalib/raspberry-pi-debian:latest
RUN apt update
RUN apt install -y libopus0 ca-certificates openssl alsa-utils libasound2 libmosquitto1 libspandsp2 libpulse0 pulseaudio
RUN ldconfig

COPY --from=container_baresip /root/re/dist/ /usr/
COPY --from=container_baresip /root/baresip/dist/ /usr/

WORKDIR /root
USER root
ENV USER=root
ADD ./entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["baresip"]

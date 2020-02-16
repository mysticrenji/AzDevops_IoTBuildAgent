FROM arm32v7/ubuntu:16.04

ARG DOCKER_CLI_VERSION="18.06.3-ce"
ENV DOWNLOAD_URL="https://download.docker.com/linux/static/stable/armhf/docker-$DOCKER_CLI_VERSION.tgz"
ENV PS_VERSION=6.1.2
ENV PS_PACKAGE=powershell-${PS_VERSION}-linux-arm32.tar.gz
ENV PS_PACKAGE_URL=https://github.com/PowerShell/PowerShell/releases/download/v${PS_VERSION}/${PS_PACKAGE}
# Install .NET Core SDK
ENV DOTNET_SDK_VERSION 2.1.803


# install docker client
#RUN apk --update add bash curl nano git gcc libffi-dev openssl-dev py-pip python-dev libc-dev make zip unzip libgcc libintl libssl1.1 libstdc++ tzdata userspace-rcu zlib icu-libs \
ENV DEBIAN_FRONTEND=noninteractive
RUN echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes

RUN apt-get update \
&& apt-get install -y --no-install-recommends \
        apt-utils \
	ca-certificates \
        curl \
        git \
        jq \
        gcc \
	libc-dev \
	make \
        libcurl3 \
        libicu55 \
        libstdc++6 \
        zlib1g \
        liblttng-ust0 \
        libssl1.0.2 \
        libunwind8 \
        netcat \
	iputils-ping \
        build-essential \
        libssl-dev \
        libffi-dev \
        python3-dev \
        libseccomp2 libunwind8 libssl1.0 wget nano \
    && mkdir -p /tmp/download \
    && curl -L $DOWNLOAD_URL | tar -xz -C /tmp/download \
    && mv /tmp/download/docker/docker /usr/local/bin/ \
    && rm -rf /tmp/download \
    && wget https://github.com/PowerShell/PowerShell/releases/download/v${PS_VERSION}/${PS_PACKAGE} \
    && mkdir ~/powershell \
    && tar -xvf ./${PS_PACKAGE} -C ~/powershell \
    && rm -rf ./${PS_PACKAGE} \
    && ln -s /root/powershell/pwsh /usr/bin/pwsh \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN  curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py \
     && python3  get-pip.py \
     && pip3 install cryptography iotedgedev azure-cli \ 
     && az extension add --name azure-cli-iot-ext

# Install .NET Core SDK
#ENV DOTNET_SDK_VERSION 2.1.803

RUN curl -SL --output dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Sdk/$DOTNET_SDK_VERSION/dotnet-sdk-$DOTNET_SDK_VERSION-linux-arm.tar.gz \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf dotnet.tar.gz -C /usr/share/dotnet \
    && rm dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    # Add NuGet cache (ARM SDK doesn't include it)
    && curl -SL --output /usr/share/dotnet/sdk/$DOTNET_SDK_VERSION/nuGetPackagesArchive.lzma https://dotnetcli.azureedge.net/dotnet/Sdk/$DOTNET_SDK_VERSION/nuGetPackagesArchive.lzma 

WORKDIR /azp

COPY ./start.sh /azp/start.sh
COPY ./requirements.txt /azp/requirements.txt
RUN pip install -r /azp/requirements.txt 
#    && pip install azure-cli \
#    && az extension add --name azure-cli-iot-ext 
RUN chmod +x /azp/start.sh

#CMD ["/azp/start.sh]
ENTRYPOINT ["/azp/start.sh"]


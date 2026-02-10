# FROM ubuntu:20.04

# WORKDIR /usr/src/app
# RUN chmod 777 /usr/src/app

# RUN apt-get -qq update
# RUN apt-get -qq install -y git python3 python3-pip \
#     locales python3-lxml aria2 \
#     curl pv jq nginx npm
	
# COPY requirements.txt .
# RUN pip3 install --no-cache-dir -r requirements.txt && \
#     apt-get -qq purge git
	
# RUN locale-gen en_US.UTF-8
# ENV LANG en_US.UTF-8
# ENV LANGUAGE en_US:en
# ENV LC_ALL en_US.UTF-8

# COPY . .

# RUN chmod +x start.sh
# RUN chmod +x gclone

# CMD ["bash","start.sh"]

FROM ubuntu:20.04

# 🔴 IMPORTANT: disable interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

WORKDIR /usr/src/app
RUN chmod 777 /usr/src/app

# Install system packages (tzdata handled safely)
RUN apt-get -qq update && apt-get -qq install -y \
    tzdata \
    git \
    python3 \
    python3-pip \
    locales \
    python3-lxml \
    aria2 \
    curl \
    pv \
    jq \
    nginx \
    npm \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && dpkg-reconfigure -f noninteractive tzdata

# Install Python dependencies
COPY requirements.txt .
RUN pip3 uninstall -y telegram || true \
    && pip3 install --upgrade pip setuptools wheel \
    && pip3 install --no-cache-dir -r requirements.txt \
    && python3 -c "import telegram; from telegram import ParseMode; print('OK ParseMode:', ParseMode.HTML)" \
    && apt-get -qq purge git \
    && apt-get -qq autoremove -y \
    && apt-get -qq clean




# Locale setup
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Copy application
COPY . .

RUN chmod +x start.sh
RUN chmod +x gclone

CMD ["bash", "start.sh"]

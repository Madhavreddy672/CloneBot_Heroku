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

# ===== Basic non-interactive setup =====
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# ===== CRITICAL: remove Ubuntu telegram package =====
RUN apt-get update && apt-get remove -y python3-telegram || true

# ===== Install system dependencies =====
RUN apt-get update && apt-get install -y \
    tzdata \
    python3 \
    python3-pip \
    python3-lxml \
    aria2 \
    curl \
    pv \
    jq \
    git \
    locales \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && dpkg-reconfigure -f noninteractive tzdata \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ===== Set working directory =====
WORKDIR /usr/src/app

# ===== Copy & install Python dependencies =====
COPY requirements.txt .

RUN pip3 install --upgrade pip setuptools wheel \
    && pip3 install --no-cache-dir -r requirements.txt \
    && python3 - << 'EOF'
import telegram
from telegram import ParseMode
print("ParseMode OK:", ParseMode.HTML)
EOF

# ===== Locale setup =====
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# ===== Copy application source =====
COPY . .

RUN chmod +x start.sh gclone

# ===== Run bot (Worker mode) =====
CMD ["bash", "start.sh"]

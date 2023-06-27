FROM node:lts

WORKDIR /usr/src/app
ENV NODE_ENV production
ENV PORT 9000
EXPOSE 9000

RUN apt-get update \
    && apt-get install -yq \
        gconf-service libasound2 libatk1.0-0 libc6 \
        libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 \
        libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 \
        libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 \
        libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 \
        libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 \
        libxrender1 libxss1 libxtst6 ca-certificates fonts-liberation \
        libappindicator1 libnss3 lsb-release xdg-utils wget \
    && rm -r /var/lib/apt/lists/*

# Install Google Chrome Stable and fonts
RUN echo 'deb http://deb.debian.org/debian/ buster  contrib non-free' >> /etc/apt/sources.list
RUN echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula \
    select true | debconf-set-selections
RUN apt-get update && apt-get install curl gnupg -y \
  && curl --location --silent https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
  && apt-get update \
  && apt-get install google-chrome-stable ttf-mscorefonts-installer -y --no-install-recommends \
  && rm -rf /var/lib/apt/lists/*
ADD fonts /usr/share/fonts/truetype/msttcorefonts
RUN fc-cache -f "/usr/share/fonts/truetype/msttcorefonts/" &> /dev/null


COPY package.json package-lock.json ./
RUN npm ci 

COPY . .

ENV ALLOW_HTTP true
ENV BROWSER_EXECUTABLE_PATH /usr/bin/google-chrome
CMD ["node", "src/index.js"]

FROM node:8-slim

RUN apt-get update && \
apt-get install -yq gconf-service libasound2 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 \
libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 \
libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 \
libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 \
fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst ttf-freefont \
ca-certificates fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils wget && \
wget https://github.com/Yelp/dumb-init/releases/download/v1.2.1/dumb-init_1.2.1_amd64.deb && \
dpkg -i dumb-init_*.deb && rm -f dumb-init_*.deb && \
apt-get clean && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

RUN yarn global add puppeteer@1.8.0 && yarn cache clean

ENV NODE_PATH="/usr/local/share/.config/yarn/global/node_modules:${NODE_PATH}"

ENV PATH="/tools:${PATH}"

RUN groupadd -r 1001 && useradd -r -g 0 -G audio,video 0

COPY --chown=1001:0 ./tools /tools

# Set language to UTF8
ENV LANG="C.UTF-8"

WORKDIR /app
ENV HOME=/app
# Add user so we don't need --no-sandbox.

COPY s2i /home/1001/s2i
LABEL io.k8s.description="S2I builder image for puppeteer" \
      io.k8s.display-name="puppeteer" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="puppeteer" \
      io.openshift.s2i.scripts-url="image:///home/1001/s2i/bin"
RUN mkdir /screenshots \
	&& mkdir -p /home/1001/Downloads \
    && chown -R 1001:0 /home/1001 \
    && chown -R 1001:0 /usr/local/share/.config/yarn/global/node_modules \
    && chown -R 1001:0 /screenshots \
    && chown -R 1001:0 /app \
    && chown -R 1001:0 /tools \
    && find /home/1001/s2i -type d -exec chmod g+ws {} \;
# Run everything after as non-privileged user.
USER 1001

# --cap-add=SYS_ADMIN
# https://docs.docker.com/engine/reference/run/#additional-groups

ENTRYPOINT ["dumb-init", "--"]

 #CMD ["/usr/local/share/.config/yarn/global/node_modules/puppeteer/.local-chromium/linux-526987/chrome-linux/chrome"]

CMD ["node", "index.js"]

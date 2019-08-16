FROM node:8-slim

# Install latest chrome dev package and fonts to support major charsets (Chinese, Japanese, Arabic, Hebrew, Thai and a few others)
# Note: this installs the necessary libs to make the bundled version of Chromium that Puppeteer
# installs, work.
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update \
    && apt-get install -y google-chrome-unstable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst ttf-freefont \
      --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# If running Docker >= 1.13.0 use docker run's --init arg to reap zombie processes, otherwise
# uncomment the following lines to have `dumb-init` as PID 1
ADD https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64 /usr/local/bin/dumb-init
 RUN chmod +x /usr/local/bin/dumb-init
 # ENTRYPOINT ["dumb-init", "--"]

# Uncomment to skip the chromium download when installing puppeteer. If you do,
# you'll need to launch puppeteer with:
#     browser.launch({executablePath: 'google-chrome-unstable'})
# ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true

# Install puppeteer so it's available in the container.
RUN npm i puppeteer \
    # Add user so we don't need --no-sandbox.
    # same layer as npm install to keep re-chowned files from using up several hundred MBs more space
    && groupadd -r 1001 && useradd -r -g 0 -G audio,video 0 \
    && mkdir -p /home/1001/s2i \
	&& mkdir -p /opt/app-root \
    && chown -R 1001:0 /home/1001 \
	&& chown -R 1001:0 /opt/app-root \
    && chown -R 1001:0 /node_modules


COPY s2i /home/1001/s2i


LABEL io.k8s.description="S2I builder image for puppeteer" \
      io.k8s.display-name="puppeteer" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="puppeteer" \
      io.openshift.s2i.scripts-url="image:///home/1001/s2i/bin"
#aseguro que puedan ejecutar los scripts

RUN chown -R 1001:0 /opt/app-root/s2i && \
    find /opt/app-root/s2i -type d -exec chmod g+ws {} \;

# Run everything after as non-privileged user.
USER 1001
ENV HOME=/opt/app-root


RUN mkdir /opt/app-root/src && \
find /opt/app-root -type d -exec chmod g+ws {} \;

# aseguro que la build este levantando como raiz, el directorio donde tengo los archivos estaticos

WORKDIR /opt/app-root/src

# corro usage

CMD [ "/opt/app-root/s2i/bin/usage" ]

#CMD ["google-chrome-unstable"]

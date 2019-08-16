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
 ARG S2IDIR="/opt/app-root/s2i"

# Uncomment to skip the chromium download when installing puppeteer. If you do,
# you'll need to launch puppeteer with:
#     browser.launch({executablePath: 'google-chrome-unstable'})
# ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true

# Install puppeteer so it's available in the container.

RUN useradd -u 1001 -r -g 0 -G audio,video -d /opt/app-root -s /sbin/nologin -c "Default Application User" default \
    && mkdir -p /opt/app-root \
    && chown -R 1001:0 /opt/app-root && chmod -R g+rwX /opt/app-root

COPY s2i "$S2IDIR/"
RUN chmod 777 -R $S2IDIR

LABEL io.k8s.description="S2I builder image for puppeteer" \
      io.k8s.display-name="puppeteer" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="puppeteer" \
      io.openshift.s2i.scripts-url="image:///opt/app-root/s2i/bin"
#aseguro que puedan ejecutar los scripts

RUN chown -R 1001:0 /opt/app-root && \
    find /opt/app-root/s2i/bin -type d -exec chmod g+ws {} \;

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

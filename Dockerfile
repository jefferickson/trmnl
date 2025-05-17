FROM python:3.13.0-alpine

# Set this at deploy
# ENV BUCKET
# SECRET AWS_ACCESS_KEY_ID
# SECRET AWS_SECRET_ACCESS_KEY
# SECRET AWS_DEFAULT_REGION

ENV GECKODRIVER_VER=v0.36.0
ENV FIREFOX_VER=138.0
ENV BINARYLOC=/usr/bin/geckodriver

RUN apk --no-cache add curl

RUN apk --no-cache add firefox-esr
RUN apk --no-cache add libx11
RUN apk --no-cache add dbus-glib
RUN apk --no-cache add fontconfig ttf-dejavu

RUN curl -sSLO https://download-installer.cdn.mozilla.net/pub/firefox/releases/${FIREFOX_VER}/linux-x86_64/en-US/firefox-${FIREFOX_VER}.tar.xz \
    && tar -xf firefox-* \
    && mv firefox /opt/ \
    && chmod 755 /opt/firefox \
    && chmod 755 /opt/firefox/firefox

RUN curl -sSLO https://github.com/mozilla/geckodriver/releases/download/${GECKODRIVER_VER}/geckodriver-${GECKODRIVER_VER}-linux64.tar.gz \
    && tar zxf geckodriver-*.tar.gz \
    && mv geckodriver /usr/bin/

ENV SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v0.2.29/supercronic-linux-amd64 \
    SUPERCRONIC=supercronic-linux-amd64 \
    SUPERCRONIC_SHA1SUM=cd48d45c4b10f3f0bfdd3a57d054cd05ac96812b

RUN curl -fsSLO "$SUPERCRONIC_URL" \
    && echo "${SUPERCRONIC_SHA1SUM}  ${SUPERCRONIC}" | sha1sum -c - \
    && chmod +x "$SUPERCRONIC" \
    && mv "$SUPERCRONIC" "/usr/local/bin/${SUPERCRONIC}" \
    && ln -s "/usr/local/bin/${SUPERCRONIC}" /usr/local/bin/supercronic

COPY ./src /src
COPY ./crontab /crontab
COPY ./requirements.txt /requirements.txt

RUN pip install --upgrade pip
RUN pip install -r requirements.txt
RUN pip freeze

CMD ["echo", "\"container running\""]

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

COPY ./src /src
COPY ./requirements.txt /requirements.txt

RUN pip install --upgrade pip
RUN pip install -r requirements.txt
RUN pip freeze

CMD ["sh", "/src/download.sh"]

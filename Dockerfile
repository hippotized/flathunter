##### PYTHON-BASE
FROM python:3.10-slim AS python-base
ARG DEBIAN_FRONTEND=noninteractive

RUN \
    python -VV && \
    apt -qy update && \
    apt -qy install --no-install-recommends gnupg2 wget

RUN \
    wget -qO - https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor | tee /etc/apt/trusted.gpg.d/google.gpg >/dev/null && \
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | tee /etc/apt/sources.list.d/google-chrome.list >/dev/null && \
    apt -qy update && \
    apt -qy install --no-install-recommends google-chrome-stable && \
    apt -qy autoclean && \
    apt -qy autoremove && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/


##### PYTHON-DEPS
FROM python-base AS python-deps
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ARG PIP_NO_CACHE_DIR=1
ARG PIP_DISABLE_PIP_VERSION_CHECK=1

# Install pipenv
RUN pip install --upgrade pipenv

WORKDIR /usr/src/app

# Copy files that list dependencies
COPY Pipfile.lock Pipfile ./

# Generate requirements.txt and install dependencies from there
RUN pipenv requirements > requirements.txt && \
    pip install -r requirements.txt


##### RUNTIME
FROM python-deps AS runtime

# Copy all other files, including source files
COPY . .

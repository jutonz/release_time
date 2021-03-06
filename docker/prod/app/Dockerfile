FROM ubuntu:18.04

RUN DEBIAN_FRONTEND="noninteractive" \
&& apt-get update -y && apt-get install -y \
  software-properties-common \
  wget \
  locales \
&& rm -rf /var/lib/apt/lists/*

USER root
ENV HOME /root
WORKDIR /root

# Configure locale
RUN locale-gen en_US.utf8 && update-locale LANG=en_US.utf8 LC_ALL=en_US.utf8

# Utilility packages
RUN export DEBIAN_FRONTEND="noninteractive" \
&& apt-get update -y && apt-get install -y \
  build-essential \
  vim \
  git \
  curl \
  tzdata \
  htop \
  sudo \
  libpq-dev \
&& rm -rf /var/lib/apt/lists/*

# Erlang and Elixir
RUN export DEBIAN_FRONTEND="noninteractive" \
  && wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb \
  && dpkg -i erlang-solutions_1.0_all.deb \
  && apt-get update \
  && apt-get install -y esl-erlang elixir \
  && rm erlang-solutions_1.0_all.deb

# Node
RUN export DEBIAN_FRONTEND="noninteractive" \
 && curl -sL https://deb.nodesource.com/setup_6.x | bash - \
 && apt-get install -y nodejs

# Yarn
RUN export DEBIAN_FRONTEND="noninteractive" \
 && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - \
 && echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list \
 && apt-get update \
 && apt-get install -y yarn

COPY docker/prod/app/init.sh /etc/

COPY . /root/code/
WORKDIR /root/code

# Compile elixir
RUN MIX_ENV=prod mix local.hex --force
RUN MIX_ENV=prod mix local.rebar --force
RUN MIX_ENV=prod mix deps.get
RUN MIX_ENV=prod mix compile

# Compile js
#RUN cd apps/client/assets && yarn && yarn cache clean && yarn run bundle
RUN MIX_ENV=prod mix phx.digest

CMD ["/bin/bash", "-c", "/etc/init.sh"]

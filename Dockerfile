FROM kalilinux/kali-rolling:latest AS base

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends apt-utils \
    && apt-get install -y --no-install-recommends amass awscli curl dnsutils \
    dotdotpwn file finger ffuf gobuster git hydra impacket-scripts john less locate \
    lsof man-db netcat-traditional nikto nmap proxychains4 python3 python3-pip python3-setuptools \
    python3-wheel smbclient smbmap socat ssh-client sslscan sqlmap telnet tmux unzip whatweb neovim zip \
    fish exa bat kali-tools-top10 \
    # Slim down layer size
    && apt-get autoremove -y \
    && apt-get autoclean -y \
    # Remove apt-get cache from the layer to reduce container size
    && rm -rf /var/lib/apt/lists/*


# Second set of installs to slim the layers a bit
# exploitdb and metasploit are huge packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    exploitdb metasploit-framework \
    # Slim down layer size
    && apt-get autoremove -y \
    && apt-get autoclean -y \
    && rm -rf /var/lib/apt/lists*

WORKDIR /tmp
# AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install

WORKDIR /root
# enum4linux-ng
RUN apt-get update \
    && apt-get install -y --no-install-recommends python3-impacket python3-ldap3 python3-yaml \
    && mkdir /tools \
    # Slim down layer size
    && apt-get autoremove -y \
    && apt-get autoclean -y \
    && rm -rf /var/lib/apt/lists*

WORKDIR /tools
#enum4linux-ng
RUN git clone https://github.com/cddmp/enum4linux-ng.git /tools/enum4linux-ng \
    && ln -s /tools/enum4linux-ng/enum4linux-ng.py /usr/local/bin/enum4linux-ng

# set fish as default shell
RUN echo "/usr/bin/fish" >> /etc/shells
RUN chsh -s /usr/bin/fish
ENTRYPOINT ["/usr/bin/fish"]

# Set Aliases
#RUN /usr/bin/fish "alias -s ls=exa"
#RUN /usr/bin/fish "alias -s cat=bat"

FROM base AS wordlists

# Install Seclists
RUN mkdir -p /usr/share/wordlists/seclists \
    # The apt-get install seclists command isn't installing the wordlists, so clone the repo.
    && git clone --depth 1 https://github.com/danielmiessler/SecLists.git /usr/share/wordlists/seclists

# Prepare rockyou wordlist
WORKDIR /usr/share/wordlists
RUN cp /usr/share/seclists/Passwords/Leaked-Databases/rockyou.txt.tar.gz /usr/share/wordlists/
RUN tar -xzf rockyou.txt.tar.gz

WORKDIR /root

ARG GITPOD_IMAGE=gitpod/workspace-base:latest
FROM ${GITPOD_IMAGE}


# Install Terraform
RUN sudo apt-get update && sudo apt-get install -y gnupg software-properties-common \
    && wget -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null \
    && gpg --no-default-keyring \
    --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    --fingerprint \
    && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/hashicorp.list \
    && sudo apt update \
    && sudo apt-get install terraform

# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && sudo ./aws/install \
    && rm awscliv2.zip \
    && mkdir /home/gitpod/.aws \
    && gp sync-done AWSCLI \
# Configure AWS Credentials
    && cd /home/gitpod/.aws/ \
    && touch credentials \
    && echo "[default]" > /home/gitpod/.aws/credentials \
    && echo "aws_access_key_id=$AWS_ACCESS_KEY" >> /home/gitpod/.aws/credentials \
    && echo "aws_secret_access_key=$AWS_SECRET_KEY" >> /home/gitpod/.aws/credentials

# Install KubeCTL
RUN curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.29.3/2024-04-19/bin/linux/amd64/kubectl \
    && chmod +x ./kubectl \
    && mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$HOME/bin:$PATH
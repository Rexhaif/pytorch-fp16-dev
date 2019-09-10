FROM nvcr.io/nvidia/pytorch:19.07-py3

RUN apt-get update && apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN echo "root:dockerpass" | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

RUN mkdir /root/.ssh
ADD ./id_ed25519.pub /root/.ssh
RUN echo "`cat ~/.ssh/id_ed25519.pub`" >> /root/.ssh/authorized_keys
RUN chmod 755 /root/.ssh && chmod 644 /root/.ssh/authorized_keys

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
RUN pip install tb-nightly
#WORKDIR /tmp/unique_for_apex
# uninstall Apex if present, twice to make absolutely sure :)
#RUN pip uninstall -y apex || :
#RUN pip uninstall -y apex || :
# SHA is something the user can touch to force recreation of this Docker layer,
# and therefore force cloning of the latest version of Apex
#RUN SHA=ToUcHMe git clone https://github.com/NVIDIA/apex.git
#WORKDIR /tmp/unique_for_apex/apex
#RUN pip install -v --no-cache-dir --global-option="--cpp_ext" --global-option="--cuda_ext" .
#WORKDIR /workspace

EXPOSE 22 6006 8888

CMD ["/usr/sbin/sshd", "-D"]


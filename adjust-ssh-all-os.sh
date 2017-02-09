echo "Enable ssh via password authentication"
echo "#"
perl -pi -e 's|ChallengeResponseAuthentication no|ChallengeResponseAuthentication yes|g' /etc/ssh/sshd_config
echo "#"
perl -pi -e 's|PasswordAuthentication no|PasswordAuthentication yes|g' /etc/ssh/sshd_config
echo "#"
echo "Restart sshd"
service sshd restart

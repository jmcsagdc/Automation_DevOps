# Takes	a hostname in arg. This	is used	to make
# the commands unique and to reference the file 
# we are appending to in /usr/local/nagios/etc/servers


echo "
define service{
        use                             generic-service         ; Service template
        host_name                       $1
        service_description             Check My Processes
        check_command                   $1_check_processes
}

define command {
        command_name     $1_check_processes
        command_line     /usr/local/nagios/libexec/check_nrpe -H $1 -c check_processes
}

define service{
        use                             generic-service         ; Service template
        host_name                       $1
        service_description             Check Python
        check_command                   $1_check_python
}

define command {
        command_name     $1_check_python
        command_line     /usr/local/nagios/libexec/check_nrpe -H $1 -c check_python
}
" >> /usr/local/nagios/etc/servers/$1.cfg

service	nagios reload  

# To pick up changes, a reload. Now check your UI.
# If the services show errors, likely the plugins are not installed on the host.

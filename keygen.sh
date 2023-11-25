#!/bin/bash

file="id_rsa"
phrase=""

show_help(){
    echo "Generate public/private key pair to local path $HOME/.ssh/ and append public key to remote ~/.ssh/authorized_keys"
    echo "usage: $0 [-f] [-p] [-r] [-u] [-h]"
    echo "  -f  filename; default 'id_rsa'"
    echo "  -p  passphrase to key pair"
    echo "  -r  remote host name"
    echo "  -u  remote host user name"
    echo "  -h  show help"
    exit 0
}

main(){
    ssh-keygen -t rsa -f "$HOME/.ssh/$file" -N "$phrase" -C "$USERNAME@$HOSTNAME. $file. This key was provided by https://github.com/bartholomaeuss/ssh-key-gen-and-deploy"
    cat "$HOME/.ssh/$file.pub" | ssh -l $user $remote "cat >> .ssh/authorized_keys"
    if [ $? -ne 0 ]
    then
      exit 1
    fi
    echo "$USERNAME@$HOSTNAME:$HOME/.ssh/$file.pub was appended to $user@$remote:~/.ssh/authorized_keys."
    exit 0
}

while getopts ":f:p:r:u:h" opt; do
  case $opt in
    f)
      file="$OPTARG"
      ;;
    p)
      passphrase="$OPTARG"
      ;;
    r)
      remote="$OPTARG"
      ;;
    u)
      user="$OPTARG"
      ;;
    h)
      show_help
      ;;
    \?)
      echo "unknown option: -$OPTARG" >&2
      show_help
      ;;
    :)
      echo "option requires an argument -$OPTARG." >&2
      show_help
      ;;
  esac
done

if [ "$#" -le 0 ]
then
  echo "script requires an option"
  show_help
fi

if [ -z "$remote" ]
then
  echo "'-r' option is mandatory"
  show_help
fi

if [ -z "$user" ]
then
  echo "'-u' option is mandatory"
  show_help
fi

main

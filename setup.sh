#!/bin/bash

# Output a cool Roboflow Quickstart ASCII art intro
echo "██████╗  ██████╗ ██████╗  ██████╗ ███████╗██╗      ██████╗ ██╗    ██╗"
sleep 0.1
echo "██╔══██╗██╔═══██╗██╔══██╗██╔═══██╗██╔════╝██║     ██╔═══██╗██║    ██║"
sleep 0.1
echo "██████╔╝██║   ██║██████╔╝██║   ██║█████╗  ██║     ██║   ██║██║ █╗ ██║"
sleep 0.1
echo "██╔══██╗██║   ██║██╔══██╗██║   ██║██╔══╝  ██║     ██║   ██║██║███╗██║"
sleep 0.1
echo "██║  ██║╚██████╔╝██████╔╝╚██████╔╝██║     ███████╗╚██████╔╝╚███╔███╔╝"
sleep 0.1
echo "╚═╝  ╚═╝ ╚═════╝ ╚═════╝  ╚═════╝ ╚═╝     ╚══════╝ ╚═════╝  ╚══╝╚══╝ "
sleep 0.1

# print the text "Welcome to the Roboflow Quickstart!" one character at a time
# with a 0.1 second delay between each character
# and a 0.2 second delay between each word
for word in "Welcome to the Roboflow Quickstart!"
do
  for ((i=0; i<${#word}; i++))
  do
    echo -n "${word:$i:1}"
    sleep 0.02
  done
  echo
  sleep 0.1
done

sleep 0.5

for word in "Let's check your dependencies and get started."
do
  for ((i=0; i<${#word}; i++))
  do
    echo -n "${word:$i:1}"
    sleep 0.02
  done
  echo
  sleep 0.1
done

# sleep for 1 second
sleep 1

# for debugging, uncomment the following line to print all commands
# set -ex

# modified install_using_package_manager function which accepts a second argument which,
# when true, returns the command that will be run (so the calling code can preview it for the user),
# and when false actually runs the command
install_using_package_manager() {
  # determine OS
  OS=$(uname -s | tr A-Z a-z)

  case $OS in
  linux)
    source /etc/os-release
    case $ID in
    debian | ubuntu | mint)
      if [[ $2 ]]
      then
        echo "apt install $1"
      else
        sudo apt install $1
      fi
      ;;

    fedora | rhel | centos)
      if [[ $2 ]]
      then
        echo "yum install $1"
      else
        sudo yum install $1
      fi
      ;;

    *)
      echo -n "unsupported linux distro"
      ;;
    esac
    ;;

  darwin)
    if [[ $2 ]]
    then
      echo "brew install $1"
    else
      # first ensure brew is installed
      if ! command -v brew &> /dev/null
      then
        # notify them brew is missing and ask if they want to install it
        echo "brew was not found on your system, but is required to run this project"
        read -p "Would you like to install brew now? [Y/n] " -n 1 -r

        # if not, exit
        if [[ $REPLY =~ ^[Yy]$ ]]
        then
          exit 1
        fi

        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      fi
      brew install $1
    fi
    ;;

  *)
    echo -n "unsupported OS"
    ;;
  esac
}

# check if a dependency is installed or not and if not, ask if they want to install it and if so, install it
check_and_install_dependencies() {
  # check if the dependency is installed
  if ! command -v $1 &> /dev/null
  then
    echo "$1 was not found on your system, but is required to run this project"
    # get command to run to install the dependency and save it to  a variable we can print later
    install_command=$(install_using_package_manager $1 true)
    
    # ask if they'd like to install it (default to y if they just hit enter)
    # and if reply is not Y/y or N/n (i.e. they just hit enter), ask again
    while [[ ! $REPLY =~ ^[YyNn]$ ]]
    do
      read -p "Would you like to install $1 now? (command: \`$install_command\`) [Y/n] " -n 1 -r
    done

    # if no, exit
    if [[ $REPLY =~ ^[Nn]$ ]]
    then
      exit 1
    fi

    # if yes, use the install_using_package_manager function to install the dependency
    install_using_package_manager $1
  fi
}

# check for node
check_and_install_dependencies node

# check for python3
check_and_install_dependencies python3

# create a virtual environment called roboflow if it doesn't already exist from a previous time they ran this script
# and activate it
if [[ ! -d roboflow ]]
then
  python3 -m venv roboflow
fi
source roboflow/bin/activate

# run @roboflow/inference-server in the background with npx
# this will exit when the script ends
npx @roboflow/inference-server &> /dev/null &

# pip install the requirements
# and run the roboflow notebook
pip3 install roboflow notebook

# run the roboflow notebook (./quickstart.ipynb)
jupyter notebook ./quickstart.ipynb

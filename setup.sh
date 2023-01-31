#!/bin/bash

# Output a cool Roboflow Quickstart ASCII art intro
echo ""
sleep 0.1
echo ""
sleep 0.1
echo " ██████╗   ██████╗  ██████╗   ██████╗  ███████╗ ██╗       ██████╗  ██╗    ██╗"
sleep 0.1
echo " ██╔══██╗ ██╔═══██╗ ██╔══██╗ ██╔═══██╗ ██╔════╝ ██║      ██╔═══██╗ ██║    ██║"
sleep 0.1
echo " ██████╔╝ ██║   ██║ ██████╔╝ ██║   ██║ █████╗   ██║      ██║   ██║ ██║ █╗ ██║"
sleep 0.1
echo " ██╔══██╗ ██║   ██║ ██╔══██╗ ██║   ██║ ██╔══╝   ██║      ██║   ██║ ██║███╗██║"
sleep 0.1
echo " ██║  ██║ ╚██████╔╝ ██████╔╝ ╚██████╔╝ ██║      ███████╗ ╚██████╔╝ ╚███╔███╔╝"
sleep 0.1
echo " ╚═╝  ╚═╝  ╚═════╝  ╚═════╝   ╚═════╝  ╚═╝      ╚══════╝  ╚═════╝   ╚══╝╚══╝ "
echo ""
sleep 0.1
echo ""
sleep 0.2

# print the text from parameter 1 one character at a time
printLettersOneByOne() {
  delay=$1
  words=$2

  echo -n " "
  for word in $words
  do
    for ((i=0; i<${#word}; i++))
    do
      echo -n "${word:$i:1}"
      sleep $delay
    done
    echo -n " "
  done
  echo ""
}

printLettersOneByOne 0.01 "Welcome to the Roboflow computer vision quickstart!"
printLettersOneByOne 0.01 "Let's check your dependencies and get started."
echo ""
sleep 0.5

# determine OS
OS=$(uname -s | cut -d_ -f1 | tr A-Z a-z)

# if OS is windows, exit with an error message to use WSL
if [[ $OS == "msys" || $OS == "mingw32" || $OS == "mingw64" ]]
then
  echo " Windows is not supported; please use WSL."
  sleep 69420
  exit 1
fi

printLettersOneByOne 0.01 "This script will:"
printLettersOneByOne 0.01 "    - check for node.js and python3"
printLettersOneByOne 0.01 "    - create a virtual environment for pip dependencies"
printLettersOneByOne 0.01 "    - start a local Roboflow inference server"
printLettersOneByOne 0.01 "    - open a local Jupyter notebook with quickstart.ipynb"
echo ""

sleep 0.5

# Pause to wait for user to read the above and be ready to continue
read -p " Press any key to continue... 🦝 " -n 1 -r

# for debugging, uncomment the following line to print all commands
# set -ex

# don't fail if already running as root
sudo ()
{
    [[ $EUID = 0 ]] || set -- command sudo "$@"
    "$@"
}

PYTHON_COMMAND="python3"
PIP_COMMAND="pip3"
# if using yum package manager, use python3.8 and pip3.8 instead of python3 and pip3
if [[ $OS == "linux" ]]
then
  source /etc/os-release
  if [[ $ID == "fedora" || $ID == "rhel" || $ID == "centos" ]]
  then
    PYTHON_COMMAND="python3.8"
    PIP_COMMAND="pip3.8"
  fi
fi

# modified install_using_package_manager function which accepts a second argument which,
# when true, returns the command that will be run (so the calling code can preview it for the user),
# and when false actually runs the command
install_using_package_manager() {
  case $OS in
  linux)
    source /etc/os-release

    package=$1
    # overwrite node to nodejs
    if [[ $1 == "node" ]]
    then
      package="nodejs"
    fi

    case $ID in
    debian | ubuntu | mint)
      # overwrite the package name to python3-pip here if it's pip3 because apt is different
      # otherwise leave it the same
      
      if [[ $1 == "pip3" ]]
      then
        package="python3-pip python3-venv"
      fi

      if [[ $2 ]]
      then
        echo "sudo apt update && sudo apt install -y $package"
      else
        sudo apt update && sudo apt install -y $package
      fi
      ;;

    fedora | rhel | centos)
      if [[ $1 == $PYTHON_COMMAND ]]
      then
        package="python38 python38-pip python3-devel gcc"
      fi

      if [[ $2 ]]
      then
        echo "sudo yum install -y $package"
      else
        sudo yum install -y $package
      fi
      ;;

    *)
      echo -n "Unable to detect the default package manager for this Linux distro (please install node.js and python3 on your own and try again)."
      exit 1
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
        echo ""

        # if $REPLY is not on of { Y, y, or "empty string" } then exit
        if ! [[ $REPLY =~ ^[Yy]$|^$ ]]
        then
          exit 1
        fi

        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      fi
    fi
    ;;

  # windows
  msys | mingw32 | mingw64)
    if [[ $2 ]]
    then
      echo "Windows is not supported; please use Ubuntu via WSL."
    else
      # Can't get here because we exited already
      sleep 0.1
    fi
    ;;

  *)
    echo -n "Unsupported OS, $OS"
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
    
    # ask if they'd like to install it (default to yes if they just hit enter)
    # and if reply is not Y/y or N/n or default <Enter>, ask again
    while true
    do
      read -p "Would you like to install $1 now ($install_command)? [Y/n] " -n 1 -r
      echo ""
      if [[ $REPLY =~ ^[Yy]$ || $REPLY =~ ^[Nn]$ || $REPLY == "" ]]
      then
        break
      fi
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
check_and_install_dependencies $PYTHON_COMMAND
check_and_install_dependencies $PIP_COMMAND

# create a virtual environment called roboflow if it doesn't already exist from a previous time they ran this script
# and activate it
if [[ ! -d roboflow ]]
then
  $PYTHON_COMMAND -m venv roboflow
fi
source roboflow/bin/activate
export PATH=$PATH:~/.local/bin

# run @roboflow/inference-server in the background with npx
# this will exit when the script ends
npx --yes @roboflow/inference-server &> /dev/null &

# pip install the requirements
# and run the roboflow notebook
$PIP_COMMAND install -v --log /tmp/pip.log roboflow notebook

echo ""
echo ""
echo "Installation Complete!"
echo ""
echo ""
echo "     && , &&                 &&(,.&&&   "
echo "   && ,###( &&             && ,###, &&  "
echo "   &&*####,*  &&         &&  *,####*#&  "
echo "   & ,,####,,  &&&&&&&&&&&  ,,#####, &. "
echo "   && ,#####,*,*,*,###,*,*,*,#####,  &  "
echo "   &&  ,,#,  &&&   ###   &&&  ,,,,  &&  "
echo "    && *,          ###          ,* &&   "
echo "    &&    ######## ### ########    &&   "
echo "  &&   ##### &&########### &&#####   && "
echo "#&   ############  ###  ############   &"
echo "  &&&#########    &&&&&   .#########&&& "
echo "   &&&######,     @@@@@     ,######&&&  "
echo "       &&&,*,*,&&&&&&&&&&&,*,*&&&&      "
echo "           &&&&& & ((( & &&&&           "
echo "                &&&   &&&               "
echo ""
echo ""
echo "Starting Roboflow quickstart notebook..."
echo ""
sleep 3

# run the roboflow notebook (./quickstart.ipynb)
# if we're running in WSL, open with --no-browser and use the native cmd to open Jupyter
# otherwise, open Jupyter normally

# detect WSL
if grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null
then
  sleep 1 && /mnt/c/Windows/system32/cmd.exe /c "start http://localhost:8888/notebooks/quickstart.ipynb" &
  jupyter notebook --no-browser --port 8888
else
  jupyter notebook --allow-root ./quickstart.ipynb
fi

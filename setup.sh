#!/bin/bash

NOTEBOOK_PASSWORD="roboflow"

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

# override the read command to just echo & not wait if the user passes in the -y flag
if [[ $1 == "-y" ]]
then
  read() {
    echo "$2"
  }
fi

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
    if [[ $EUID = 0 ]]; then
        # already root, just run the command
        if [[ $1 = "-E" ]]; then
          shift
        fi
        "$@"
    else
        # not root, so use sudo
        set -- command sudo "$@"
        "$@"
    fi
}

PYTHON_COMMAND="python3"
PIP_COMMAND="pip3"
# if using yum package manager, use python3.8 and pip3.8 instead of python3 and pip3
if [[ $OS == "linux" ]]
then
  source /etc/os-release
  if [[ $ID == "rhel" || $ID == "centos" || $ID == "amzn" ]]
  then
    PYTHON_COMMAND="python3.8"
    PIP_COMMAND="pip3.8"
  fi

  # for suse (ID starts with opensuse) use python3.9 and pip3.9 (because they're in zypper)
  if [[ $ID =~ "opensuse" ]]
  then
    PYTHON_COMMAND="python3.9"
    PIP_COMMAND="pip3.9"
  fi
fi

# modified install_using_package_manager function which accepts a second argument which,
# when true, returns the command that will be run (so the calling code can preview it for the user),
# and when false actually runs the command
install_using_package_manager() {
  case $OS in
  linux)
    source /etc/os-release

    # if the ID starts with opensuse, simplify it to opensuse
    if [[ $ID =~ "opensuse" ]]
    then
      ID="opensuse"
    fi

    package=$1
    case $ID in
    debian | ubuntu | linuxmint | mint)
      # overwrite the package names to nodejs and python3-pip here if it's pip3 because apt is different
      # otherwise leave it the same

      # overwrite node to nodejs
      if [[ $1 == "node" ]]
      then
        package="nodejs"
      fi
      
      if [[ $1 == "pip3" ]]
      then
        package="python3-pip python3-venv"
      fi

      if [[ $2 ]]
      then
        if [[ $1 == "node" ]]
        then
          echo "curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - && sudo apt update && sudo apt install -y $package"
        else
          echo "sudo apt update && sudo apt install -y $package"
        fi
      else
        if [[ $1 == "node" ]]
        then
          curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
        fi
        sudo apt update && sudo apt install -y $package
      fi
      ;;

    fedora | rhel | centos)
      package=$1
      module=""

      if [[ $1 == $PYTHON_COMMAND ]]
      then
        package="python38 python38-pip python38-devel gcc"
      fi

      # overwrite node to nodejs
      if [[ $1 == "node" ]]
      then
        if [[ $ID == "centos" ]]
        then
          # on centos their version of nodejs is too old so we have to add a different source
          if [[ $2 ]]
          then
            echo "curl -fsSL https://rpm.nodesource.com/setup_16.x | sudo bash - && sudo yum install -y nodejs"
          else
            curl -fsSL https://rpm.nodesource.com/setup_16.x | sudo bash - && sudo yum install -y nodejs
          fi
          return
        else
          module=" module"
          package="nodejs:18/common"
        fi
      fi

      if [[ $2 ]]
      then
        echo "sudo yum$module install -y $package"
      else
        sudo yum$module install -y $package
      fi
      ;;
    amzn)
      package=$1
      
      if [[ $1 == $PYTHON_COMMAND ]]
      then
        package="python38 python38-devel gcc"
      fi

      if [[ $1 == "node" ]]
      then
        if [[ $2 ]]
        then
          echo "curl -fsSL https://raw.githubusercontent.com/tj/n/master/bin/n | sudo bash -s 16"
        else
          curl -fsSL https://raw.githubusercontent.com/tj/n/master/bin/n | sudo bash -s 16
        fi
        return
      fi

      if [[ $2 ]]
      then
        echo "sudo yum install -y $package"
      else
        # if python or pip command, enable from amazon-linux-extras
        if [[ $1 == $PYTHON_COMMAND || $1 == $PIP_COMMAND ]]
        then
          sudo amazon-linux-extras enable python3.8
        fi
        sudo yum install -y $package
      fi
      ;;
    arch | manjaro)
      if [[ $1 == $PYTHON_COMMAND ]]
      then
        package="python3 cmake gcc"
      fi

      # overwrite node to nodejs
      if [[ $1 == "node" ]]
      then
        package="nodejs npm"
      fi

      if [[ $2 ]]
      then
        echo "sudo pacman -S --noconfirm $package"
      else
        sudo pacman -S --noconfirm $package
      fi
      ;;
    alpine)
      if [[ $1 == $PYTHON_COMMAND ]]
      then
        package="python3 cmake gcc"
      fi

      # overwrite node to nodejs
      if [[ $1 == "node" ]]
      then
        package="nodejs npm"
      fi

      if [[ $2 ]]
      then
        echo "sudo apk add $package"
      else
        sudo apk add $package
      fi
      ;;
    opensuse)
      if [[ $1 == $PYTHON_COMMAND ]]
      then
        package="python39 python39-pip cmake gcc"
      fi

      # overwrite node to nodejs
      if [[ $1 == "node" ]]
      then
        package="nodejs npm"
      fi

      if [[ $2 ]]
      then
        echo "sudo zypper install -y $package"
      else
        sudo zypper install -y $package
      fi
      ;;
    gentoo)
      if [[ $1 == $PYTHON_COMMAND ]]
      then
        package="python"
      fi

      # overwrite node to nodejs
      if [[ $1 == "node" ]]
      then
        package="nodejs npm"
      fi

      if [[ $2 ]]
      then
        echo "sudo emerge $package"
      else
        sudo emerge $package
      fi
      ;;
    *)
      echo ""
      echo ""
      echo "❌ Unable to detect the default package manager for this Linux distro (please install node.js>=16 and python>=3.8 (along with basic utils like curl, gcc, and tar) on your own and try again."
      echo ""
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
        echo ""
        echo "🚨 brew was not found on your system, but is required to run this project"
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
    echo ""
    echo "🚨 $1 was not found on your system, but is required to run this project"
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

# check for curl
check_and_install_dependencies curl

# check for python3
check_and_install_dependencies $PYTHON_COMMAND

# check for pip
# except on fedora, arch, and manjaro, where pip is installed with python
if [[ $OS != "linux" || $ID != "fedora" && $ID != "arch" && $ID != "manjaro" && $ID != "alpine" ]]
then
  check_and_install_dependencies $PIP_COMMAND
fi

# if OS is linux and ID is amzn install basic dependencies
if [[ $OS == "linux" && $ID == "amzn" ]]
then
  check_and_install_dependencies gcc
  check_and_install_dependencies tar
fi

# check for node
check_and_install_dependencies node

# ensure node is at least version 16
if [[ $(node -v | cut -d'v' -f2 | cut -d'.' -f1) -lt 16 ]]
then
  echo ""
  echo "❌ Node.js version 16 or greater is required to run this project"
  echo "If we just finished installing it, your package manager's version is too old; consider upgrading your distro."
  echo ""
  exit 1
fi

# ensure python ($PYTHON_COMMAND) is at least version 3.8
VALID_PYTHON_VERSION=$($PYTHON_COMMAND -c 'import sys; print(1) if sys.version_info.major >= 3 and sys.version_info.minor >= 8 else print(0)')

if [[ $VALID_PYTHON_VERSION -eq 0 ]]
then
  echo ""
  echo "❌ Python version 3.8 or greater is required to run this project"
  echo "If we just finished installing it, your package manager's version is too old; consider upgrading your distro."
  echo ""
  exit 1
fi

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
# we cd into the `roboflow` folder we just created so we run as the same user that just created it; this prevents an issue when running as root in docker
cd roboflow && npx @roboflow/inference-server --yes &> /dev/null &

# alpine needs some additional build tools
if [[ $OS == "linux" && $ID == "alpine" ]]
then
  apk add build-base g++ gfortran jpeg-dev libjpeg make py3-numpy py3-numpy-dev py3-pip python3-dev zlib-dev
  $PIP_COMMAND -v --log /tmp/pip.log install wheel
fi

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
echo "🚨 If prompted, use the password: $NOTEBOOK_PASSWORD"
echo ""
sleep 3

# run the roboflow notebook (./quickstart.ipynb)
# if we're running in WSL, open with --no-browser and use the native cmd to open Jupyter
# otherwise, open Jupyter normally

token=$(head /dev/urandom | sha256sum | cut -d' ' -f1)

# detect WSL
if grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null
then
  sleep 1 && /mnt/c/Windows/system32/cmd.exe /c "start http://localhost:8888/notebooks/quickstart.ipynb" &
  jupyter notebook --no-browser --port 8888 --ip 0.0.0.0 --NotebookApp.token="$token" --NotebookApp.password="$(echo $NOTEBOOK_PASSWORD | python3 -c 'from notebook.auth import passwd;print(passwd(input()))')"
else
  jupyter notebook --allow-root --port 8888 --ip 0.0.0.0 --NotebookApp.token="$token" --NotebookApp.password="$(echo $NOTEBOOK_PASSWORD | python3 -c 'from notebook.auth import passwd;print(passwd(input()))')" ./quickstart.ipynb 
fi

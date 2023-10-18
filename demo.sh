#!/bin/bash

COMMAND=$1

ROBOT=$2

BASE=$(cd `dirname $0` && pwd)

if [ "$COMMAND" = "" ]
then
    echo "ROSConDemo Script usage:"
    echo "./demo.sh [COMMAND] [ROBOT]"
    echo
    echo "COMMAND (launch|spawn|rviz|editor|build)"
    echo
    echo "Example:  Launch the Simulation:"
    echo "  ./demo.sh launch"
    echo
    echo "Example:  Launch the Editor:"
    echo "  ./demo.sh editor"
    echo
    echo "Example:  Build:"
    echo "  ./demo.sh build"
    echo
    echo "Example:  Spawn Robot 1:"
    echo "  ./demo.sh spawn 1"
    echo
    echo "Example:  Spawn Robot 2:"
    echo "  ./demo.sh spawn 2"
    echo
    echo "Example:  Start RViz for Robot 1:"
    echo "  ./demo.sh rviz 1"
    echo
    echo "Example:  Start RViz for Robot 2:"
    echo "  ./demo.sh rviz 2"
    echo
    echo "Example:  Start Apple Picking for Robot 1:"
    echo "  ./demo.sh start 1"
    echo
    echo "Example:  Stop Apple Picking for Robot 1:"
    echo "  ./demo.sh stop 1"
    echo
    echo "Example:  Start Apple Picking for Robot 2:"
    echo "  ./demo.sh start 2"
    echo
    echo "Example:  Stop Apple Picking for Robot 2:"
    echo "  ./demo.sh stop 2"
    echo
    exit 0
fi

source /opt/ros/humble/setup.bash

export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp

source $BASE/kraken_nav/install/setup.bash

if [ "$COMMAND" = "launch" ]
then
    # Kill any AssetBuilder Process
    for i in $(ps -ef | grep AssetBuilder | grep -v grep | awk '{print $2}')
    do
        echo Killing AssetBuilder $i
        kill -9 $i
    done

    ros2 daemon stop

    ros2 daemon start

    echo Launching ROSCon Demo Simulation

    $BASE/Project/build/linux/bin/profile/./ROSConDemo.GameLauncher -bg_ConnectToAssetProcessor=0 > /dev/null
    exit $?

elif [ "$COMMAND" = "spawn" ]
then
    echo Spawn Robot $1
    if [ "$ROBOT" = "1" ]
    then 
        ros2 service call /spawn_entity gazebo_msgs/srv/SpawnEntity '{name: 'apple_kraken_rusty', xml: 'line1'}'
    elif [ "$ROBOT" = "2" ]
    then
        ros2 service call /spawn_entity gazebo_msgs/srv/SpawnEntity '{name: 'apple_kraken_shiny', xml: 'line2'}'
    elif [ "$ROBOT" = "3" ]
    then
        ros2 service call /spawn_entity gazebo_msgs/srv/SpawnEntity '{name: 'apple_kraken_rusty', xml: 'line3'}'
    elif [ "$ROBOT" = "4" ] 
    then
        ros2 service call /spawn_entity gazebo_msgs/srv/SpawnEntity '{name: 'apple_kraken_shiny', xml: 'line4'}'
    else
        echo "Invalid Robot $ROBOT"
    fi
elif [ "$COMMAND" = "rviz" ]
then
    echo RViz $1
    if [ "$ROBOT" = "1" ]
    then 
        ros2 launch o3de_kraken_nav navigation_multi.launch.py namespace:=apple_kraken_rusty_1 rviz:=True
    elif [ "$ROBOT" = "2" ]
    then
        ros2 launch o3de_kraken_nav navigation_multi.launch.py namespace:=apple_kraken_shiny_2 rviz:=True
    elif [ "$ROBOT" = "3" ]
    then
        ros2 launch o3de_kraken_nav navigation_multi.launch.py namespace:=apple_kraken_rusty_3 rviz:=True
    elif [ "$ROBOT" = "4" ] 
    then
        ros2 launch o3de_kraken_nav navigation_multi.launch.py namespace:=apple_kraken_shiny_4 rviz:=True
    else
        echo "Invalid Robot $ROBOT"
    fi
elif [ "$COMMAND" = "start" ]
then
    echo RViz $1
    if [ "$ROBOT" = "1" ]
    then 
        ros2 service call /apple_kraken_rusty_1/trigger_apple_gathering std_srvs/srv/Trigger
    elif [ "$ROBOT" = "2" ]
    then
        ros2 service call /apple_kraken_shiny_2/trigger_apple_gathering std_srvs/srv/Trigger
    elif [ "$ROBOT" = "3" ]
    then
        ros2 service call /apple_kraken_rusty_3/trigger_apple_gathering std_srvs/srv/Trigger
    elif [ "$ROBOT" = "4" ] 
    then
        ros2 service call /apple_kraken_shiny_4/trigger_apple_gathering std_srvs/srv/Trigger
    else
        echo "Invalid Robot $ROBOT"
    fi
elif [ "$COMMAND" = "stop" ]
then
    echo RViz $1
    if [ "$ROBOT" = "1" ]
    then 
        ros2 service call /apple_kraken_rusty_1/cancel_apple_gathering std_srvs/srv/Trigger
    elif [ "$ROBOT" = "2" ]
    then
        ros2 service call /apple_kraken_shiny_2/cancel_apple_gathering std_srvs/srv/Trigger
    elif [ "$ROBOT" = "3" ]
    then
        ros2 service call /apple_kraken_rusty_3/cancel_apple_gathering std_srvs/srv/Trigger
    elif [ "$ROBOT" = "4" ] 
    then
        ros2 service call /apple_kraken_shiny_4/cancel_apple_gathering std_srvs/srv/Trigger
    else
        echo "Invalid Robot $ROBOT"
    fi
elif [ "$COMMAND" = "editor" ]
then
    ros2 daemon stop

    ros2 daemon start

    echo Launching Editor for Robot Vacuum Demo

    $BASE/Project/build/linux/bin/profile/Editor > /dev/null
    exit $?
elif [ "$COMMAND" = "build" ]
then

    cd $BASE/kraken_nav
    colcon build --symlink-install

    cd $BASE
    
    cmake -B $BASE/Project/build/linux -G "Ninja Multi-Config" -S $BASE/Project -DLY_DISABLE_TEST_MODULES=ON -DLY_STRIP_DEBUG_SYMBOLS=ON -DAZ_USE_PHYSX5=ON
    if [ $? -ne 0 ]
    then
        echo "Error building"
        exit 1
    fi

    cmake --build $BASE/Project/build/linux --config profile --target Editor ROSConDemo.GameLauncher ROSConDemo.Assets

    exit 0 

else
    echo "Invalid Command $COMMAND"
fi

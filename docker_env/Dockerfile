FROM osrf/ros:noetic-desktop-full

# Dependencies we use, catkin tools is very good build system
# Also some helper utilities for fast in terminal edits (nano etc)
RUN apt-get update && apt-get install -y libeigen3-dev nano git
RUN sudo apt-get install -y python3-catkin-tools python3-osrf-pycommon
RUN sudo apt-get install -y cmake libeigen3-dev libsuitesparse-dev
RUN apt-get update && apt-get install -y python3-dev python3-matplotlib python3-numpy python3-psutil python3-tk

WORKDIR /sqrt_ws

RUN /bin/bash -c "source /opt/ros/noetic/setup.bash"

CMD ["/bin/bash"]


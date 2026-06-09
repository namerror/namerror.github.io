---
layout: blog_post
title: "[Project] 2D SLAM Robot Prototype"
categories: robotics slam hardware arduino esp32 python c++ 
date: 2026-06-09
---
## A Low-Cost 2D SLAM Robot Prototype with Real-Time Mapping and Pose Estimation
A while ago, I built this prototype with the goal of exploring SLAM (Simultaneous Localization and Mapping) in robotics. It took about a week design and build, and I had a lot of fun doing it.

The robot is built using affordable components, including an ultrasonic distance sensor for mapping nearby walls and an IMU (Inertial Measurement Unit) for estimating its position and orientation. The collected sensor data is streamed to a laptop, where a live visualization displays a rough 2D map of the maze in real time.

As a proof-of-concept prototype, it works just fine for simple mazes, but localization purely based on IMU data proves to be quite challenging. In the future, maybe I will expand this project with more sensors and better algorithms to improve the accuracy and robustness of the SLAM system.

For anyone interested in the details, check out the github repo where I have documented the design, components, and code: [GitHub Repo](https://github.com/namerror/2DMappingBot)

## Quick Demo

![Demo]({{site.base_url}}/assets/img/2dslam/demo.gif)

![Front]({{site.base_url}}/assets/img/2dslam/robot_front.jpg)

![Top]({{site.base_url}}/assets/img/2dslam/robot_top.jpg)

![Action]({{site.base_url}}/assets/img/2dslam/robot_in_action.png)
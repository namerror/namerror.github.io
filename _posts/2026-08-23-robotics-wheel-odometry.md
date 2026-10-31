---
layout: blog_post
title: "Building My Robotics Stack, Part 2: Writing Wheel Odometry and Debugging Time"
categories: robotics ros2 cpp odometry
date: 2026-08-23
---

[Part 1]({% post_url 2026-08-11-robotics-stack-model-to-motion %}) · **Part 2** · [Part 3]({% post_url 2026-10-05-robotics-ekf-sensor-fusion %}) · [Part 4]({% post_url 2026-10-22-robotics-lidar-slam-nav2 %})

Once my simulated robot could move through `ros2_control`, I wanted to understand the motion estimate behind it. Instead of treating `/diff_drive_controller/odom` as a black box, I wrote a C++ ROS 2 node that reads wheel joint states and publishes its own estimate on `/student/odom`.

The core math was compact. The more interesting lesson came from a timestamp edge case: I could have correct kinematics and still publish a broken trajectory.

## From two wheel angles to motion

A differential-drive robot changes direction by driving its wheels at different speeds. Under the rolling-without-slip model, equal wheel travel produces straight motion; a difference between the two sides changes heading.

With wheel radius `r` and wheel separation `L`, I convert changes in joint angle into distances:

```text
d_left  = r * (left_angle_now  - left_angle_previous)
d_right = r * (right_angle_now - right_angle_previous)

distance = (d_right + d_left) / 2
turn     = (d_right - d_left) / L
```

For this robot, `r = 0.05 m` and `L = 0.34 m`. If the right wheel travels farther than the left, the robot turns left under the conventions used in this model.

Those distances describe incremental motion. To maintain a pose, I have to express that motion in the odometry frame and accumulate it.

## Why I used the midpoint heading

During an arc, the robot's heading changes throughout the sample interval. Projecting the whole distance along only the initial heading introduces a discretization error. I used the midpoint heading as an approximation:

```cpp
pose.pose.position.x = last_odom_msg_->pose.pose.position.x
    + delta_s * cos(prev_yaw + delta_theta / 2);
pose.pose.position.y = last_odom_msg_->pose.pose.position.y
    + delta_s * sin(prev_yaw + delta_theta / 2);
```

This excerpt comes from my [odometry implementation at the phase-2 hardening commit](https://github.com/namerror/Robot-starter/blob/a620d01/ros2_ws/src/robot_core/src/odom.cpp). The node also updates the orientation quaternion and divides distance and heading increments by elapsed time to estimate forward velocity and yaw rate.

The midpoint method is a small-step approximation. It is useful here because the joint-state stream gives frequent updates; it is not a claim that discrete integration eliminates odometry error.

The ROS message makes two frame roles explicit: the pose is expressed in `odom`, and the child frame is `base_link`. Keeping my estimate on a separate topic let me compare it with the controller without replacing the working baseline or introducing another owner of its TF transform.

## A straight run checked the basics

I first integrated recorded `/joint_states` offline and compared the relative motion with controller odometry. Over the straight run, each wheel traveled **7.095 m**, and the integrated result agreed with the controller to floating-point precision.

That checked wheel ordering, signs, dimensions, and the calculation. It did not establish physical accuracy. Both estimates used the same ideal simulated wheel states and the same geometry. They could agree while sharing an incorrect assumption about real wheel slip or calibration.

The next test was an arc, which exercises translation and rotation together.

## The equation was right; the update path was wrong

An early arc recording contained repeated joint-state timestamps while wheel positions kept changing. My node detected a non-positive time interval, but its original skip path returned a default odometry message. The caller then published that message and stored it as the previous state.

The practical effect was a reset hidden inside what should have been a skipped update. The bag contained messages with zero timestamps and empty frame IDs. The recorded student estimate ended roughly **0.14 m** away from controller odometry.

An offline recomputation from the same raw wheel data stayed close to the controller. That comparison was particularly useful: it separated a problem with callback state handling from a problem with the motion equations.

The corrected structure rejects the invalid time interval before publishing or replacing the previous valid state:

```cpp
if (dt <= 0) {
    RCLCPP_WARN(this->get_logger(),
                "Non-positive time difference between joint states: %f", dt);
    return;
}
```

Here `dt` is measured in nanoseconds in the implementation. The velocity calculation converts it to seconds later. Preserving the previous valid wheel sample also means the next valid update can include movement accumulated across the skipped interval.

This is a policy for the repeated-stamp failure I observed. A full simulation reset or backward clock jump would deserve its own reset-handling policy.

## What the corrected run showed

In the subsequent slow arc, the student stream had valid frames throughout and no default/reset messages. Against controller odometry, the position RMSE was **1.74 micrometers**, with a final position difference of **2.45 micrometers**.

Those tiny values belong to this ideal-simulation consistency check. The [recorded experiments and analysis](https://github.com/namerror/Robot-starter/blob/8db53dc/experiments/diff_drive_odometry/report.md) explain the inputs, timestamp alignment, failed recording, and corrected recording.

There is another limit to the evidence: the follow-up recording did not itself contain non-positive timestamp transitions. It showed that normal operation remained continuous after the fix; the callback inspection explains why the old default-message publication path was removed.

## Connecting commands to measured response

I also inspected a straight velocity response. A command of **0.2 m/s** predicts **4 rad/s** at each wheel because `0.2 / 0.05 = 4`. The observed wheels reached approximately that speed, and odometry advanced **0.004 m per 20 ms tick**.

The robot continued briefly after the final command, then stopped through the controller's command timeout. That connected the abstract command to wheel feedback, integration, and timing behavior.

This was an exercise in control intuition and response inspection. It was not an implementation or tuning study of a custom PID motor loop. Real motors would add effects that this clean simulation does not establish, including backlash, voltage variation, and encoder noise.

## The lesson I am carrying forward

Writing the node made odometry concrete: it is a stateful estimate built from measurements, geometry, and timing. Debugging it also taught me to preserve raw data and compare independent calculation paths before changing equations.

The next step was to stop treating every estimate as equally trustworthy. Even a perfectly smooth trajectory needs a statement about uncertainty before it becomes an input to sensor fusion.

---

[Project source and learning roadmap](https://github.com/namerror/Robot-starter) · [Part 1]({% post_url 2026-08-11-robotics-stack-model-to-motion %}) · **Part 2** · [Part 3]({% post_url 2026-10-05-robotics-ekf-sensor-fusion %}) · [Part 4]({% post_url 2026-10-22-robotics-lidar-slam-nav2 %})

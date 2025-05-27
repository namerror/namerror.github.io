---
layout: project
title: "[Project] KIM-1 LCD Trivia Game"
categories:  hardware
tags: Assembly KIM-1 Microcomputer Circuits
date: 2025-05-06
bio: "A physical Trivia Game running on the KIM-1 6502-Computer, displayed by an LCD, programmed with assembly."
image: "/assets/img/KIM1Trivia/fullPic.jpg"
---

This project marks my first attempt at physical computing involving low-level programming and circuit design. The project showcases a Trivia game that is displayed on an LCD. By pressing the buttons on the keypad, the user can choose an answer to the displayed question and play the game.

Here is a quick demonstration of the project.

![Demo]({{site.base_url}}/assets/img/KIM1Trivia/demo.gif)

## For my tech friends
The project runs on the vintage computer KIM-1, which is based on the 6502-CPU. The program is written in ASM and sent to the KIM-1 via [Tera Term](https://github.com/TeraTermProject/teraterm/releases). The source code of the project can be found [here](https://github.com/namerror/KIM-1-Trivia-Game/tree/main/project).

Materials used for this project:
- Corsham Tech KIM-1 clone
- 4*20 LCD screen [NHD-0420D3Z-NSW-BBW-V3](https://newhavendisplay.com/content/specs/NHD-0420D3Z-NSW-BBW-V3.pdf)
- [Membrane 1x4 Keypad](https://www.adafruit.com/product/1332)
- Resistor 9X-1-103LF

SPI is used for data transmission between the LCD and KIM-1. The schematics are shown below
![Schematics]({{site.base_url}}/assets/img/KIM1Trivia/schematics.jpg)


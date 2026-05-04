# Machine Learning Tag Project
**Jackson K, Cole M**, *May 2026*

## Project Overview
This repository contains a pursuit-evasion simulation built in the **Godot Game Engine** (v4.6.1 .NET). The project explores Multi-Agent Reinforcement Learning by training a seeker and a runner to compete in games of tag. 

Using the **Godot RL-agents** library, we established a communication bridge between the game physics and a Python-based training environment using Proximal Policy Optimization. The agents were trained in a static arena with central obstacles to test their ability to navigate and strategize under different reward conditions. Tagger and Evader agents operate on entirely separate reward functions and observation spaces to simulate a true competitive environment. The simulation logs win rates, average proximity, and time-to-tag metrics in real-time for quantitative analysis.

## Technical Architecture
The system utilizes a dual-stack approach to separate training from inference:
1.  **Training Phase**: Agents are trained in Python 3.12 using `stable-baselines3`. The environment runs multiple simulations in parallel to accelerate data collection.
2.  **Inference Phase**: Trained models can be exported in the **ONNX** format and plugged directly into Godot using the .NET ONNX Runtime. This allows the agents to run in real-time within the engine without a Python backend.

We compared three levels of agent intelligence:
* **Sparse**: A simple reward system where the seeker is only rewarded for a successful tag.
* **Distance**: Reward system that rewards the seeker for getting closer and rewards the runner for increasing the gap between them.
* **Complex**: A more finley tuned system that incorporates time penalties and collision awareness, which achieved the highest seeker win rate.

## Running on your PC
### Dependencies
To ensure compatibility between the .NET environment and the ONNX models, the following versions are required:
* **Python**: v3.12 (Later versions may cause .NET compilation issues).
* **Godot**: v4.6.1 or later (.NET/C# Edition).
* **ONNX Runtime**: `Microsoft.ML.OnnxRuntime` v1.18.0 (Required for IR Version 10 support).
* **Python Libraries**: `godot-rl` v0.8.2, `onnx` v1.16.1.

### Installation
1.  Follow this [Godot RL-Agents Tutorial](https://www.youtube.com/watch?v=f8arMv_rtUU) for the initial environment handshake.
2.  Clone this repository into your Godot projects folder.
3.  Open the project in Godot and click the **Hammer icon (Build)** in the MSBuild tab to compile the C# solution.
4.  Launch the Python training script or use the `Sync` node to run inference on the provided `.onnx` files.

**Video Demo**: [Watch the agents in action](https://youtu.be/piHB9InAK7c)

For a more detailed analysis of our findings, please refer to our [project paper](https://github.com/JacksonK01/Tag-RL-Project/blob/main/Project%20Paper.pdf).

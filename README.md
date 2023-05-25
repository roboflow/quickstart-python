# Roboflow Quickstart 🚀

![68747470733a2f2f6d656469612e726f626f666c6f772e636f6d2f62616e6e65722e6a7065673f7570646174656441743d31363832353233363232333834](https://github.com/roboflow/quickstart-python/assets/60797147/1793a92b-4ef7-469e-ae43-2a188ea9d2d3)


<div align="center">
    <a href="https://youtube.com/roboflow">
        <img
          src="https://media.roboflow.com/notebooks/template/icons/purple/youtube.png?ik-sdk-version=javascript-1.4.3&updatedAt=1672949634652"
          width="3%"
        />
    </a>
    <img src="https://github.com/SkalskiP/SkalskiP/blob/master/icons/transparent.png" width="3%"/>
    <a href="https://roboflow.com">
        <img
          src="https://media.roboflow.com/notebooks/template/icons/purple/roboflow-app.png?ik-sdk-version=javascript-1.4.3&updatedAt=1672949746649"
          width="3%"
        />
    </a>
    <img src="https://github.com/SkalskiP/SkalskiP/blob/master/icons/transparent.png" width="3%"/>
    <a href="https://www.linkedin.com/company/roboflow-ai/">
        <img
          src="https://media.roboflow.com/notebooks/template/icons/purple/linkedin.png?ik-sdk-version=javascript-1.4.3&updatedAt=1672949633691"
          width="3%"
        />
    </a>
    <img src="https://github.com/SkalskiP/SkalskiP/blob/master/icons/transparent.png" width="3%"/>
    <a href="https://docs.roboflow.com">
        <img
          src="https://media.roboflow.com/notebooks/template/icons/purple/knowledge.png?ik-sdk-version=javascript-1.4.3&updatedAt=1672949634511"
          width="3%"
        />
    </a>
    <img src="https://github.com/SkalskiP/SkalskiP/blob/master/icons/transparent.png" width="3%"/>
    <a href="https://disuss.roboflow.com">
        <img
          src="https://media.roboflow.com/notebooks/template/icons/purple/forum.png?ik-sdk-version=javascript-1.4.3&updatedAt=1672949633584"
          width="3%"
        />
    <img src="https://github.com/SkalskiP/SkalskiP/blob/master/icons/transparent.png" width="3%"/>
    <a href="https://blog.roboflow.com">
        <img
          src="https://media.roboflow.com/notebooks/template/icons/purple/blog.png?ik-sdk-version=javascript-1.4.3&updatedAt=1672949633605"
          width="3%"
        />
    </a>
    </a>
</div>

Welcome to the Roboflow Quickstart repo! 👋

Roboflow is a set of tools to help you build a production-ready computer vision workflow, fast. Roboflow empowers developers to deploy computer vision models with ease, providing utilities to help at every step of the way: from annotation to using your model in production.

## Features

- **Live Inference with Webcam:** Perform real-time object detection using your webcam in a Jupyter notebook.
- **Dependency Installation:** Automatically installs all the necessary dependencies to quickly get started with Roboflow.
- **Comprehensive Model Support:** Utilize Roboflow for object detection, semantic segmentation, and image classification tasks within your projects.
- **Training Resources:** Access additional guides and materials to kickstart your own model training process.

## Installation

Run:

```
git clone https://github.com/roboflow/quickstart-python
cd quickstart-python && ./setup.sh
```

https://user-images.githubusercontent.com/37276661/226327781-fb2b7b7e-f896-407d-9f0c-6e10e9a7198c.mov

## Troubleshooting

If you encounter any errors during the installation process in Mac, try the following:

1. `ImportError: urllib3 v2.0 only supports OpenSSL 1.1.1+, currently the 'ssl' module is compiled with LibreSSL 2.8.3.`

```
brew install openssl@1.1
pip3 install urllib3==1.26.6
```

If the error persists or you encounter a different error, please open an issue in the project repository for further assistance.

## Getting Started

Once the installation is complete, a Jupyter notebook will open in your browser. Follow the instructions provided in the notebook to get started!

https://user-images.githubusercontent.com/37276661/226327812-c5a6a14b-dff7-4726-86a3-e588f20d5e4e.mov

This repository includes the following demos:

`quickstart.ipynb`: **Real-time Object Detection with Webcam**

This notebook demonstrates how to perform real-time object detection using your webcam. It utilizes the Roboflow library and provides step-by-step instructions to set up and run the webcam object detection.

`create-models.ipynb`: **Create and Re-train Models**

This notebook provides a technical walkthrough on creating and re-training models for blood cell analysis. It demonstrates how to enhance the model's generalization capabilities by augmenting the dataset with additional data. The goal is to improve the model's ability to accurately identify and classify blood cells across different tasks.

`model-types.ipynb`: **Experiment with Different Model Types**

Roboflow provides a powerful set of tools for applying computer vision to various problem domains. This notebook focuses on three fundamental computer vision tasks: classification, object detection, and instance segmentation. We will explore how to load and utilize models to solve problems in each of these task types. 

`integration.ipynb`: **Integrating Roboflow Into Your Application**

To seamlessly integrate Roboflow into your application, you can connect your application to a Roboflow inference engine. The inference engine can be hosted on our cloud servers or run locally using a Docker container as an inference server. By establishing this connection, you can utilize the predictions generated by your model to build intelligent logic within your application. This guide covers two integration approaches, Hosted API and Local Deployment with Docker Container.

## Feedback

We value your feedback on how we can improve the Roboflow Quickstart experience. If you encounter any issues or have suggestions, please leave an issue in the project's GitHub Issues section. We will review your feedback and respond promptly.

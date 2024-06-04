# Cavifree - URP Integration

This folder contains the Universal Render Pipeline (URP) version of Cavifree.

Follow these instructions to integrate the effect into your URP project.

## Setup

1. **Import the Shader**: Copy the 3 other files in this folder into your Unity project's Assets folder.

2. **Configure Material**: Adjust the material's (`CavityMaterial.mat`) properties to your liking. Parameters such as Intensity, Radius, and Sharpness can be tweaked to achieve the desired effect.

3. **Renderer Feature**: To apply the shader as a full-screen post-processing effect, you'll need to create a Renderer Feature.

   - In your Universal Renderer Data asset, navigate to the Renderer Features section at the bottom.
   - Click the `Add Renderer Feature` button and select `Full Screen Pass Renderer Feature` to add it.
   - Set the material you tweaked in step 2 as the Material.
   - Ensure that the required buffers are set to "Color" and "Normal".

4. **Injection Point**: Decide whether you want to inject the effect before or after other post-processing effects.

## Adjusting Parameters

To adjust the parameters of the effect (Intensity, Radius, Angle Sensitivity, Edge Intensity Multiplier, Sharpness), modify the properties of the `CavityMaterial.mat` material directly. You can also create several different materials using the included shader (`CavityShader.shadergraph`) if you want to have different presets you can easily swap.

## Note

For any issues or questions, please refer to the [main README](../README.md).

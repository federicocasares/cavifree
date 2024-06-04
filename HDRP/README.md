# Cavifree - HDRP Integration

This folder contains the High Definition Render Pipeline (HDRP) version of Cavifree.

Follow these instructions to integrate the effect into your HDRP project.

## Setup

1. **Import the Shader**: Copy the 3 other files in this folder into your Unity project's Assets folder.

2. **Register the Custom Pass**: Open your `HD Render Pipeline Global Settings` asset and add the Cavity pass in the `Before TAA` section under `Custom Post Process Orders`.

3. **Add the Effect to the Volume**: Go to the volume profile you are using for your post processing effects, click on `Add Override` and add the `Cavity` effect.

4. **Configure Effect**: Adjust the properties to your liking. Parameters such as Intensity, Radius, and Sharpness can be tweaked to achieve the desired effect.

## Note

For any issues or questions, please refer to the [main README](../README.md).

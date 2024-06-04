using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;

[Serializable, VolumeComponentMenu("Post-processing/Custom/Cavity")]
public sealed class Cavity : CustomPostProcessVolumeComponent, IPostProcessComponent {

    [Tooltip("Controls the strength of the effect.")]
    public FloatParameter intensity = new ClampedFloatParameter(1f, 0f, 10f);
    [Tooltip("Specifies the pixel radius for sampling, affecting smoothness. A radius of 0 only samples the current pixel.")]
    public IntParameter radius = new ClampedIntParameter(1, 0, 10);
    [Tooltip("Together with the edge intensity multiplier setting, fine-tunes sensitivity to changes in surface angle.")]
    public FloatParameter angleSensitivity = new ClampedFloatParameter(2.5f, 1f, 5f);
    [Tooltip("Multiplies the intensity of edges. The higher it is, the more edges will be fully highlighted, regardless of their angle.")]
    public FloatParameter edgeIntensityMultiplier = new ClampedFloatParameter(0.6f, 0f, 10f);
    [Tooltip("Affects the importance of the current pixel compared to surrounding pixels being sampled. Has no effect when the radius is 0.")]
    public FloatParameter sharpness = new ClampedFloatParameter(0.9f, 0f, 1f);

    Material m_Material;

    public bool IsActive() => m_Material != null && intensity.value > 0f;

    // Do not forget to add this post process in the Custom Post Process Orders list (Project Settings > Graphics > HDRP Global Settings).
    public override CustomPostProcessInjectionPoint injectionPoint => CustomPostProcessInjectionPoint.BeforeTAA;

    const string kShaderName = "Shader Graphs/Cavity";

    public override void Setup() {
        if (Shader.Find(kShaderName) != null)
            m_Material = new Material(Shader.Find(kShaderName));
        else
            Debug.LogError($"Unable to find shader '{kShaderName}'. Post Process Volume Cavity is unable to load.");
    }

    public override void Render(CommandBuffer cmd, HDCamera camera, RTHandle source, RTHandle destination) {
        if (m_Material == null)
            return;

        m_Material.SetFloat("_Intensity", intensity.value);
        m_Material.SetTexture("_MainTex", source);
        m_Material.SetInt("_Radius", radius.value);
        m_Material.SetFloat("_Exponent", angleSensitivity.value);
        m_Material.SetFloat("_Multiplier", edgeIntensityMultiplier.value);
        m_Material.SetFloat("_Sharpness", sharpness.value);
        HDUtils.DrawFullScreen(cmd, m_Material, destination, shaderPassId: 0);
    }

    public override void Cleanup() {
        CoreUtils.Destroy(m_Material);
    }
}

float2 SampleSceneNormalBuffer(float2 uv, float3x3 viewMatrix)
{
    // sample the normal buffer and convert from world space normals
    // to the camera's space
    float3 normalWorldSpace = SHADERGRAPH_SAMPLE_SCENE_NORMAL(uv);
    float3 normalViewSpace = (mul(viewMatrix, normalWorldSpace));
    return normalViewSpace.xy;
}

float CalculateCurvature(float2 left, float2 right, float2 down, float2 up, float exponent, float multiplier)
{
    float resultX = left.x - right.x;
    float resultY = up.y - down.y;
    float totalResult = resultX + resultY;

    // we raise curvature to some power to control the sensitivity
    // of which angles we highlight and which ones we don't
    float curvature = 0.5 + sign(totalResult) * pow(abs(totalResult * multiplier), exponent);
    return clamp(curvature, 0.0, 1.0);
}

float GetCurvatureAtPoint(float2 uv, float exponent, float multiplier, float3x3 viewMatrix)
{
    float2 leftRight = float2(1.0 / _ScreenParams.x, 0);
    float2 upDown = float2(0, 1.0 / _ScreenParams.y);

    float2 left = SampleSceneNormalBuffer(uv + leftRight, viewMatrix);
    float2 right = SampleSceneNormalBuffer(uv - leftRight, viewMatrix);
    float2 down = SampleSceneNormalBuffer(uv - upDown, viewMatrix);
    float2 up = SampleSceneNormalBuffer(uv + upDown, viewMatrix);

    return CalculateCurvature(left, right, down, up, exponent, multiplier);
}

void GetAverageCurvature_float(float2 screenPosition, int radius, float exponent, float multiplier, float sharpness, out float curvature)
{
    float3x3 viewMatrix = (float3x3)UNITY_MATRIX_V;
    float totalWeight = 0.0;
    curvature = 0.0;

    // 0.0001 to prevent nasty divisions by zero when calculating weights
    sharpness = clamp(1.0 - sharpness, 0.0001, 1.0);

    // sample points around the current pixel, giving each one of them
    // a weight depending on the distance to the centre
    for (int i = -radius; i <= radius; i++)
    {
        for (int j = -radius; j <= radius; j++)
        {
            float2 pixelOffset = float2(i, j);
            float2 uvOffset = pixelOffset / _ScreenParams.xy;
            float weight = 1 / (dot(pixelOffset, pixelOffset) + sharpness);
            totalWeight += weight;
            curvature += weight * GetCurvatureAtPoint(screenPosition + uvOffset, exponent, multiplier, viewMatrix);
        }
    }

    curvature /= totalWeight;
}
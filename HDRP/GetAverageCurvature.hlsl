float2 SampleNormalBuffer(uint2 pixelCoords, float3x3 viewMatrix)
{
    // sample the normal buffer and convert from world space normals
    // to the camera's space
    NormalData normalData;
    DecodeFromNormalBuffer(pixelCoords, normalData);
    float3 normalVS = (mul(viewMatrix, normalData.normalWS));
    return normalVS.xy;
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

float GetCurvatureAtPoint(uint2 pixelCoords, float exponent, float multiplier, float3x3 viewMatrix)
{
    uint2 leftRight = uint2(1, 0);
    uint2 upDown = uint2(0, 1);

    float2 left = SampleNormalBuffer(pixelCoords + leftRight, viewMatrix);
    float2 right = SampleNormalBuffer(pixelCoords - leftRight, viewMatrix);
    float2 down = SampleNormalBuffer(pixelCoords - upDown, viewMatrix);
    float2 up = SampleNormalBuffer(pixelCoords + upDown, viewMatrix);

    return CalculateCurvature(left, right, down, up, exponent, multiplier);
}

void GetAverageCurvature_float(float2 screenPosition, int radius, float exponent, float multiplier, float sharpness, out float curvature)
{
    uint2 pixelCoords = screenPosition * _ScreenParams.xy;
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
            uint2 offset = uint2(i, j);
            float weight = 1 / (dot(offset, offset) + sharpness);
            totalWeight += weight;
            curvature += weight * GetCurvatureAtPoint(pixelCoords + offset, exponent, multiplier, viewMatrix);
        }
    }

    curvature /= totalWeight;
}
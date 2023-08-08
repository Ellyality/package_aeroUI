#define PI 3.14159265

#if defined(BIG_KERNEL)
	#define KERNEL_SIZE 30
#elif defined(MEDIUM_KERNEL)
	#define KERNEL_SIZE 20
#elif defined(LITTLE_KERNEL)
	#define KERNEL_SIZE 10
#else
	#define KERNEL_SIZE 1
#endif

float gauss(float x, float sigma)
{
	return  1.0f / (2.0f * PI * sigma * sigma) * exp(-(x * x) / (2.0f * sigma * sigma));
}

float gauss(float x, float y, float sigma)
{
    return  1.0f / (2.0f * PI * sigma * sigma) * exp(-(x * x + y * y) / (2.0f * sigma * sigma));
}

struct pixel_info
{
	sampler2D tex;
	half2 uv;
	half4 texelSize;
};

float4 GaussianBlur(pixel_info pinfo, float sigma, float2 dir)
{
	float4 o = 0;
	float sum = 0;
	float2 uvOffset;
	float weight;
	
	for(int kernelStep = - KERNEL_SIZE / 2; kernelStep <= KERNEL_SIZE / 2; ++kernelStep)
	{
		uvOffset = pinfo.uv;
		uvOffset.x += ((kernelStep) * pinfo.texelSize.x) * dir.x;
		uvOffset.y += ((kernelStep) * pinfo.texelSize.y) * dir.y;
		weight = gauss(kernelStep, sigma) + gauss(kernelStep+1, sigma);
		o += tex2D(pinfo.tex, uvOffset) * weight;
		sum += weight;
	}
	o *= (1.0f / sum);
	return o;
}

float4 GaussianBlurOnePass(pixel_info pinfo, float sigma, float2 dir, int k_size)
{
	float4 o = 0;
	float sum = 0;
	float2 uvOffset;
	float weight;
	
	for (int x = -k_size / 2; x <= k_size / 2; ++x)
		for (int y = -k_size / 2; y <= k_size / 2; ++y)
		{
			uvOffset = pinfo.uv;
			uvOffset.x += x * pinfo.texelSize.x;
			uvOffset.y += y * pinfo.texelSize.y;
			weight = gauss(x, y, sigma);
			o += tex2D(pinfo.tex, uvOffset) * weight;
			sum += weight;
		}
	o *= (1.0f / sum);
	return o;
}
float4 GaussianBlurOnePassFast(pixel_info pinfo, float sigma, float2 dir)
{
	float4 o = 0;
	float sum = 0;
	float2 uvOffset;
	float weight;
	
	[unroll]
	for (int x = -KERNEL_SIZE / 2; x <= KERNEL_SIZE / 2; ++x)
	{
		[unroll]
		for (int y = -KERNEL_SIZE / 2; y <= KERNEL_SIZE / 2; ++y)
		{
			uvOffset = pinfo.uv;
			uvOffset.x += x * pinfo.texelSize.x;
			uvOffset.y += y * pinfo.texelSize.y;
			weight = gauss(x, y, sigma);
			o += tex2D(pinfo.tex, uvOffset) * weight;
			sum += weight;
		}
	}
	o *= (1.0f / sum);
	return o;
}

float4 GaussianBlurLinearSampling(pixel_info pinfo, float sigma, float2 dir)
{
	float4 o = 0;
	float sum = 0;
	float2 uvOffset;
	float weight;
	
	for(int kernelStep = - KERNEL_SIZE / 2; kernelStep <= KERNEL_SIZE / 2; kernelStep += 2)
	{
		uvOffset = pinfo.uv;
		uvOffset.x += ((kernelStep+0.5f) * pinfo.texelSize.x) * dir.x;
		uvOffset.y += ((kernelStep+0.5f) * pinfo.texelSize.y) * dir.y;
		weight = gauss(kernelStep, sigma) + gauss(kernelStep+1, sigma);
		o += tex2D(pinfo.tex, uvOffset) * weight;
		sum += weight;
	}
	o *= (1.0f / sum);
	return o;
}

float4 KawaseBlur(pixel_info pinfo, int pixelOffset)
{
	float4 o = 0;
	o += tex2D(pinfo.tex, pinfo.uv + (float2(pixelOffset + 0.5,pixelOffset + 0.5) * pinfo.texelSize.xy)) * 0.25;
	o += tex2D(pinfo.tex, pinfo.uv + (float2(-pixelOffset - 0.5,pixelOffset + 0.5) * pinfo.texelSize.xy))* 0.25;
	o += tex2D(pinfo.tex, pinfo.uv + (float2(-pixelOffset - 0.5,-pixelOffset - 0.5) * pinfo.texelSize.xy)) * 0.25;
	o += tex2D(pinfo.tex, pinfo.uv + (float2(pixelOffset + 0.5,-pixelOffset - 0.5) * pinfo.texelSize.xy)) * 0.25;
	return o;
}

float4 linear_blur(sampler2D sp, float4 uv, float2 dir) {
	static const int samples = 9;

	float4 color = 0.0;

	// Move coordinates in opposite direction to center the sampling.
	uv = UNITY_PROJ_COORD(float4(
		uv.x - dir.x * samples * 0.5,
		uv.y - dir.y * samples * 0.5,
		uv.z,
		uv.w
	));

	[unroll]
	for (int i = 0; i < samples; ++i) {
		uv = UNITY_PROJ_COORD(float4(
			uv.x + dir.x,
			uv.y + dir.y,
			uv.z,
			uv.w
		));
		color += tex2Dproj(sp, uv);
	}

	return color / samples;
}
fixed4 kawase_blur(sampler2D sp, float2 uv, float2 res, float si){
	fixed4 col = fixed4(0.0, 0.0, 0.0, 0.0);
	col.rgb = tex2D( sp, uv ).rgb;
    col.rgb += tex2D( sp, uv + float2( si, si ) * res ).rgb;
    col.rgb += tex2D( sp, uv + float2( si, -si ) * res ).rgb;
    col.rgb += tex2D( sp, uv + float2( -si, si ) * res ).rgb;
    col.rgb += tex2D( sp, uv + float2( -si, -si ) * res ).rgb;
    col.rgb /= 5.0f;
	return col;
}
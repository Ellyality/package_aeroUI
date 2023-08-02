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
	o += tex2D(pinfo.tex, pinfo.uv + (float2(pixelOffset + 0.5,pixelOffset + 0.5) * pinfo.texelSize)) * 0.25;
	o += tex2D(pinfo.tex, pinfo.uv + (float2(-pixelOffset - 0.5,pixelOffset + 0.5) * pinfo.texelSize))* 0.25;
	o += tex2D(pinfo.tex, pinfo.uv + (float2(-pixelOffset - 0.5,-pixelOffset - 0.5) * pinfo.texelSize)) * 0.25;
	o += tex2D(pinfo.tex, pinfo.uv + (float2(pixelOffset + 0.5,-pixelOffset - 0.5) * pinfo.texelSize)) * 0.25;
	return o;
}



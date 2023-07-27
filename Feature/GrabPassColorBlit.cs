using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace URPGrabPass.Runtime
{
    internal class ColorBlitPass : ScriptableRenderPass
    {
        public RenderTargetIdentifier Recevier;
        ProfilingSampler m_ProfilingSampler = new ProfilingSampler("ColorBlit");
        Material m_Material;
        RenderTargetIdentifier m_CameraColorTarget;
        float m_Intensity;

        public ColorBlitPass(GrabTiming timing, Material material)
        {
            renderPassEvent = timing.ToRenderPassEvent();
            m_Material = material;
            renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;
        }

        public void SetTarget(RenderTargetIdentifier colorHandle, float intensity)
        {
            m_CameraColorTarget = colorHandle;
            m_Intensity = intensity;
            Recevier = new RenderTargetIdentifier(m_CameraColorTarget, 0, CubemapFace.Unknown, -1);
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            var camera = renderingData.cameraData.camera;

            CommandBuffer cmd = CommandBufferPool.Get();
            using (new ProfilingScope(cmd, m_ProfilingSampler))
            {
                m_Material.SetFloat("_Intensity", m_Intensity);
                cmd.SetRenderTarget(Recevier);
                //The RenderingUtils.fullscreenMesh argument specifies that the mesh to draw is a quad.
                cmd.DrawMesh(RenderingUtils.fullscreenMesh, Matrix4x4.identity, m_Material);
            }
            context.ExecuteCommandBuffer(cmd);
            cmd.Clear();
            CommandBufferPool.Release(cmd);
        }
    }
}

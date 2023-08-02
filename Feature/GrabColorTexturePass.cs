using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace URPGrabPass.Runtime
{
    /// <summary>
    ///     Path that grabs the color texture of the camera.
    /// </summary>
    public class GrabColorTexturePass : ScriptableRenderPass
    {
        private ProfilingSampler _ProfilingSampler = new ProfilingSampler("Grab Pass");
        private readonly RTHandle _grabbedTextureHandle;
        private readonly string _grabbedTextureName;
        private readonly int _grabbedTexturePropertyId;

        private RenderTargetIdentifier m_CameraColorTarget;
        private ScriptableRenderer _renderer;

        public GrabColorTexturePass(GrabTiming timing, string grabbedTextureName)
        {
            renderPassEvent = timing.ToRenderPassEvent();
            _grabbedTextureName = grabbedTextureName;
            _grabbedTextureHandle = RTHandles.Alloc(_grabbedTextureName, _grabbedTextureName);
            _grabbedTexturePropertyId = Shader.PropertyToID(_grabbedTextureName);
        }

        public void SetTarget(RenderTargetIdentifier target)
        {
            m_CameraColorTarget = target;
        }

        public void BeforeEnqueue(ScriptableRenderer renderer)
        {
            _renderer = renderer;
        }

        public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
        {
            cmd.GetTemporaryRT(_grabbedTexturePropertyId, cameraTextureDescriptor);
            cmd.SetGlobalTexture(_grabbedTextureName, _grabbedTextureHandle.nameID);
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            var cmd = CommandBufferPool.Get(nameof(GrabColorTexturePass));
            cmd.Clear();
            using (new ProfilingScope(cmd, _ProfilingSampler))
            {
                //cmd.SetRenderTarget(m_CameraColorTarget);
                //cmd.DrawMesh(RenderingUtils.fullscreenMesh, Matrix4x4.identity, m_Material);
                Blit(cmd, m_CameraColorTarget, _grabbedTextureHandle.nameID);
            }
            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }

        public override void FrameCleanup(CommandBuffer cmd)
        {
            cmd.ReleaseTemporaryRT(_grabbedTexturePropertyId);
        }
    }
}

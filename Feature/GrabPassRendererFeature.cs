using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace URPGrabPass.Runtime
{
    /// <summary>
    ///     Renderer feature to grab color texture and render objects that use it.
    /// </summary>
    [Serializable]
    public class GrabPassRendererFeature : ScriptableRendererFeature
    {
        private const string DefaultShaderLightMode = "UseColorTexture";
        private const string DefaultGrabbedTextureName = "_GrabbedTexture";

        [SerializeField] [Tooltip("When to grab color texture.")]
        private GrabTiming _timing = GrabTiming.AfterTransparents;

        [SerializeField] [Tooltip("Texture name to use in the shader.")]
        private string _grabbedTextureName = DefaultGrabbedTextureName;

        [SerializeField] [Tooltip("Light Mode of shaders that use grabbed texture.")]
        private List<string> _shaderLightModes = new List<string> {DefaultShaderLightMode};

        [SerializeField] [Tooltip("How to sort objects during rendering.")]
        private SortingCriteria _sortingCriteria = SortingCriteria.CommonTransparent;

        [SerializeField]
        private Shader _shader;

        private ColorBlitPass _grabColorBlit;
        private GrabColorTexturePass _grabColorTexturePass;
        private UseColorTexturePass _useColorTexturePass;
        private Material _material;

        public override void Create()
        {
            if (_shader == null)
                _shader = Shader.Find("ColorBlit");
            if (_shader != null)
                _material = new Material(_shader);

            _grabColorBlit = new ColorBlitPass(_timing, _material);
            _grabColorTexturePass = new GrabColorTexturePass(_timing, _grabbedTextureName, _material);
            _useColorTexturePass = new UseColorTexturePass(_timing, _shaderLightModes, _sortingCriteria);
        }

        public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
        {
            _grabColorTexturePass.BeforeEnqueue(renderer);
            _useColorTexturePass.BeforeEnqueue(renderer);
            _grabColorBlit.ConfigureInput(ScriptableRenderPassInput.Color);
            _grabColorBlit.SetTarget(renderer.cameraColorTarget, 1.5f);
            renderer.EnqueuePass(_grabColorBlit);
            _grabColorTexturePass.SetTarget(_grabColorBlit.Recevier);
            //_grabColorTexturePass.SetTarget(renderer.cameraColorTarget);
            renderer.EnqueuePass(_grabColorTexturePass);
            renderer.EnqueuePass(_useColorTexturePass);
        }

        protected override void Dispose(bool disposing)
        {
            base.Dispose(disposing);
            CoreUtils.Destroy(_material);
        }
    }


}

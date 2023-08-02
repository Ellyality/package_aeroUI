using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.UI;

namespace Funique.UIEffect
{
    public class GlassBase<T> : MonoBehaviour where T : MaskableGraphic
    {
        [SerializeField] BlurType GlassType;
        [SerializeField][Range(0, 1)] float Opacity;
        [SerializeField][Range(1f, 30)] float Size;

        T image;
        Material material;

        const string URPName = "UniversalRenderPipelineAsset";
        const string URPShader = "Funique/URP/UI Blur Effet";
        const string BuildinShader = "Funique/Build-in/UI Blur Effet";

        private void OnEnable()
        {
            image = GetComponent<T>();
        }

        private void OnDisable()
        {
            image = null;
        }

        private void Update()
        {
            if(GraphicsSettings.renderPipelineAsset == null)
            {
                BuildinUpdate();
            }
            else
            {
                if(GraphicsSettings.renderPipelineAsset.GetType().Name == URPName)
                {
                    URPUpdate();
                }
            }
        }

        private void BuildinUpdate()
        {
            if (image.material != material || image.material.shader.name != BuildinShader)
            {
                material = new Material(Shader.Find(BuildinShader));
                image.material = material;
            }

            material.SetFloat("_Opacity", Opacity);
            material.SetFloat("_Size", Size);
        }

        private void URPUpdate()
        {
            if (image.material != material || image.material.shader.name != URPShader)
            {
                material = new Material(Shader.Find(URPShader));
                image.material = material;
            }

            material.SetFloat("_Opacity", Opacity);
            material.SetFloat("_Size", Size);
        }
    }
}

using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.UI;

namespace Funique.UIEffect
{
    public class GlassBase<T> : MonoBehaviour where T : MaskableGraphic
    {
        [SerializeField] bool Fast;
        [SerializeField][Range(0, 1)] float Opacity;
        [SerializeField][Range(1f, 30)] float Size;
        [SerializeField] BlurLevel GlassType;

        T image;
        Material material;

        const string URPName = "UniversalRenderPipelineAsset";
        const string URPShader = "Funique/URP/UI Blur Effet";
        const string BuildinShader = "Funique/Build-in/UI Blur Effet";
        const string URPFShader = "Funique/URP/UI Blur Effet Fast";
        const string BuildinFShader = "Funique/Build-in/UI Blur Effet Fast";

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
            if(GraphicsSettings.renderPipelineAsset == null) BuildinUpdate();
            else
            {
                if (GraphicsSettings.renderPipelineAsset.GetType().Name == URPName) URPUpdate();
            }
        }

        private void BuildinUpdate()
        {
            if (Fast)
            {
                if (image.material != material || image.material.shader.name != BuildinFShader)
                {
                    material = new Material(Shader.Find(BuildinFShader));
                    image.material = material;
                }
            }
            else
            {
                if (image.material != material || image.material.shader.name != BuildinShader)
                {
                    material = new Material(Shader.Find(BuildinShader));
                    image.material = material;
                }
            }
            Assign();
        }

        private void URPUpdate()
        {
            if (Fast)
            {
                if (image.material != material || image.material.shader.name != URPFShader)
                {
                    material = new Material(Shader.Find(URPFShader));
                    image.material = material;
                }
            }
            else
            {
                if (image.material != material || image.material.shader.name != URPShader)
                {
                    material = new Material(Shader.Find(URPShader));
                    image.material = material;
                }
            }
            Assign();
        }

        private void Assign()
        {
            material.SetFloat("_Opacity", Opacity);
            material.SetFloat("_Size", Size);
            DisableAll();
            switch (GlassType)
            {
                case BlurLevel.None:
                    material.EnableKeyword("NONE");
                    break;
                case BlurLevel.Little:
                    material.EnableKeyword("LITTLE_KERNEL");
                    break;
                case BlurLevel.Middle:
                    material.EnableKeyword("MEDIUM_KERNEL");
                    break;
                case BlurLevel.Large:
                    material.EnableKeyword("BIG_KERNEL");
                    break;
            }
        }

        private void DisableAll()
        {
            material.DisableKeyword("NONE");
            material.DisableKeyword("LITTLE_KERNEL");
            material.DisableKeyword("MEDIUM_KERNEL");
            material.DisableKeyword("BIG_KERNEL");
        }
    }
}

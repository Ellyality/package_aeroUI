using System;
using UnityEngine;
using UnityEngine.UI;

namespace Funique.UIEffect
{
    public class OneBlurBase<T> : MonoBehaviour where T : MaskableGraphic
    {
        [SerializeField][Range(0, 1)] float Opacity;
        [SerializeField][Range(1f, 30)] float Size;
        [SerializeField] BlurLevel GlassType;

        T image;

        private void OnEnable()
        {
            image = GetComponent<T>();
        }

        private void OnDisable()
        {
            image = null;
        }
    }
}

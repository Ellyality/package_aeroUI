using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEngine.UI;

namespace Funique.UIEffect
{
    public sealed class CreateMenuItem
    {
        [MenuItem("GameObject/UI/Funique/Glass Image", false, -1000)]
        public static void CreateGlassImage()
        {
            if (Selection.activeGameObject == null) return;

            GameObject g = new GameObject("Glass RawImage");
            g.transform.SetParent(Selection.activeGameObject.transform);
            g.AddComponent<Image>();
            g.AddComponent<GlassImage>();
        }

        [MenuItem("GameObject/UI/Funique/Glass RawImage", false, -1000)]
        public static void CreateGlassRawImage()
        {
            if (Selection.activeGameObject == null) return;

            GameObject g = new GameObject("Glass RawImage");
            g.transform.SetParent(Selection.activeGameObject.transform);
            g.AddComponent<RawImage>();
            g.AddComponent<GlassRawImage>();
        }
    }
}

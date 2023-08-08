using System;
using System.Collections;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.UI;

namespace Funique.UIEffect
{
    public class OneShotGlassBase<T> : MonoBehaviour where T : MaskableGraphic
    {
        [SerializeField] ComputeShader m_ComputeShader;
        [SerializeField] float Size = 20f;

        T image;
        GameObject go;
        RenderTexture rt;

        private void Start()
        {
            StartCoroutine(OneShot());
        }

        private void Reset()
        {
            m_ComputeShader = Resources.Load<ComputeShader>("UIEffect/OneShotGlass");
            Size = 20f;
        }

        private void OnEnable()
        {
            image = GetComponent<T>();
        }

        private void OnDisable()
        {
            image = null;
        }

        IEnumerator OneShot()
        {
            go = new GameObject("Local");
            go.transform.SetParent(transform, false);
            go.transform.localPosition = new Vector3(0, 0, -0.001f);
            Camera cam = go.AddComponent<Camera>();
            cam.orthographic = true;
            cam.farClipPlane = 10;
            yield return new WaitForEndOfFrame();
            rt = new RenderTexture(1, 1, 24);
            rt.enableRandomWrite = true;
            rt.Create();
            cam.targetTexture = rt;
            cam.Render();
            Destroy(go);
            rt.Release();
        }

        private void OnDrawGizmos()
        {
            Gizmos.DrawWireCube(transform.TransformPoint(Vector3.zero), new Vector3(1.0f, 1.0f, 1.0f) * 0.01f);
            Gizmos.DrawRay(transform.TransformPoint(Vector3.zero), Vector3.forward);
        }
    }
}

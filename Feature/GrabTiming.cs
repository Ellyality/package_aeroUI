using System;
using System.Runtime.Remoting.Messaging;
using UnityEngine.Rendering.Universal;

namespace URPGrabPass.Runtime
{
    public enum GrabTiming
    {
        AfterOpaques,
        AfterTransparents,
        Before
    }

    public static class GrabTimingExtensions
    {
        public static RenderPassEvent ToRenderPassEvent(this GrabTiming grabTiming)
        {
            switch (grabTiming)
            {
                case GrabTiming.AfterOpaques:
                    return RenderPassEvent.AfterRenderingSkybox;
                case GrabTiming.AfterTransparents:
                    return RenderPassEvent.AfterRenderingTransparents;
                case GrabTiming.Before:
                    return RenderPassEvent.BeforeRendering;
                default:
                    throw new ArgumentOutOfRangeException(nameof(grabTiming), grabTiming, null);
            };
        }
    }
}
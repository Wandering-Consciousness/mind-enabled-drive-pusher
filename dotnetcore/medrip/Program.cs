using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Text;

namespace medrip
{
    class Program
    {
        [DllImport("qwqng", CallingConvention = CallingConvention.Cdecl)]
        public extern static void randbytes(byte[] buffer, int bytecount);

        static void Main(string[] args)
        {
            var s = "DefaultEndpointsProtocol=https;AccountName=medentropyqueue;AccountKey=YsLKNOquLXl/f5dMS6aL0RjVIC0BrOvuOsKsc5FgbNVIyi9GCKF9Wjzl+SoNgd8sPiBKN9ZfnGmbf9W52f+4Nw==;EndpointSuffix=core.windows.net";
            var n = "entropy-queue";
            var p = new Pusher(s, n);

            var buffer = new List<byte>();
            var slen = 8192;
            while (true)
            {
                for (int i = 0; i < 5; i++)
                {
                    var smallBuff = new byte[slen];
                    randbytes(smallBuff, slen);
                    buffer.AddRange(smallBuff);
                }
                p.SendEntropy(buffer);
                buffer.Clear();
            }
        }
    }
}

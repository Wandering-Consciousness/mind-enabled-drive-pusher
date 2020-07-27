using System;
using System.Collections.Generic;
using Azure.Storage.Queues;

namespace medrip
{
    public class Pusher
    {
        string connectionString;
        string queueName;
        QueueClient queue;

        public Pusher(string connectionString, string queueName)
        {
            this.connectionString = connectionString;
            this.queueName = queueName;
            queue = new QueueClient(connectionString, queueName);
            queue.Create();
        }

        public void SendEntropy(List<byte> entropyBinary)
        {
            string entropStr = Convert.ToBase64String(entropyBinary.ToArray());
            entropStr = $"<entropy>{entropStr}</entropy>";
            var ttl = new TimeSpan(3, 0, 0); // hrs|min|sec
            queue.SendMessage(entropStr, timeToLive: ttl);
            Console.WriteLine($"{DateTime.Now.ToString()} sent {entropStr.Length} bytes");
        }
    }
}

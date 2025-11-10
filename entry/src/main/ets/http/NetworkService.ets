import { http } from '@kit.NetworkKit';

export class HttpHelper {
  private static instance: HttpHelper;
  private requestQueue: Array<() => void> = [];
  private isProcessing = false;
  private lastRequestTime = 0;
  private readonly MIN_REQUEST_INTERVAL = 2000; // 最小请求间隔500ms（2次/秒）

  private constructor() {
  }

  static getInstance(): HttpHelper {
    if (!HttpHelper.instance) {
      HttpHelper.instance = new HttpHelper();
    }
    return HttpHelper.instance;
  }

  async request(url: string, options?: http.HttpRequestOptions): Promise<http.HttpResponse> {
    return new Promise((resolve, reject) => {
      this.addToQueue(async () => {
        try {
          const result = await this.executeRequest(url, options);
          resolve(result);
        } catch (error) {
          reject(error);
        }
      });
    });
  }

  private addToQueue(requestFn: () => void): void {
    this.requestQueue.push(requestFn);
    this.processQueue();
  }

  private async processQueue(): Promise<void> {
    if (this.isProcessing || this.requestQueue.length === 0) {
      return;
    }

    this.isProcessing = true;

    while (this.requestQueue.length > 0) {
      // 计算需要等待的时间
      const now = Date.now();
      const timeSinceLastRequest = now - this.lastRequestTime;
      const waitTime = Math.max(0, this.MIN_REQUEST_INTERVAL - timeSinceLastRequest);

      if (waitTime > 0) {
        await this.delay(waitTime);
      }

      // 执行请求
      const requestFn = this.requestQueue.shift();
      if (requestFn) {
        this.lastRequestTime = Date.now(); // 更新最后请求时间
        requestFn(); // 执行请求（请求本身会消耗时间）
      }
    }

    this.isProcessing = false;
  }

  private async executeRequest(url: string, options?: http.HttpRequestOptions): Promise<http.HttpResponse> {
    const httpRequest = http.createHttp();
    try {
      const response = await httpRequest.request(url, options);
      return response;
    } finally {
      httpRequest.destroy();
    console.info("ra_q_size = " + this.requestQueue.length)
    }
  }

  private delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}
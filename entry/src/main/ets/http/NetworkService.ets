import { http } from '@kit.NetworkKit';

export class HttpHelper {
  private static instance: HttpHelper;
  private requestQueue: Array<() => void> = [];
  private isProcessing = false;
  private lastRequestTime = 0;

  // 修正：将固定间隔改为随机范围，以模拟更自然的用户行为
  private readonly MIN_DELAY = 20;
  private readonly MAX_DELAY = 50;

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
          console.info(`[HTTP START] URL: ${url}`);
          const response = await this.executeRequest(url, options);

          // 🌟 添加日志：检查响应状态码和结果
          if (response.responseCode !== 200) {
            // 记录失败的请求的详细信息
            console.error(`[HTTP FAIL] URL: ${url}, Code: ${response.responseCode}, Result: ${response.result}`);
          } else {
            // 记录成功的请求（可以精简）
            console.info(`[HTTP OK] URL: ${url}, Code: ${response.responseCode}`);
          }

          resolve(response);
        } catch (error) {
          // 🌟 添加日志：记录请求执行时的异常（例如网络错误、超时等）
          console.error(`[HTTP ERROR] URL: ${url}, Execution Error: ${JSON.stringify(error)}`);
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

      // 🌟 核心修正：计算 20ms 到 50ms 之间的随机间隔
      // 生成 [MIN_DELAY, MAX_DELAY] 范围内的随机整数
      const randomInterval = Math.floor(
        Math.random() * (this.MAX_DELAY - this.MIN_DELAY + 1)
      ) + this.MIN_DELAY;

      // 计算需要等待的时间
      const now = Date.now();
      const timeSinceLastRequest = now - this.lastRequestTime;

      // 使用随机生成的间隔来计算等待时间
      const waitTime = Math.max(0, randomInterval - timeSinceLastRequest);

      console.info(`[HttpHelper] Required Interval: ${randomInterval}ms, Actual Wait Time: ${waitTime}ms`);

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
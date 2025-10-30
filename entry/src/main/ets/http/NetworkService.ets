import { http } from '@kit.NetworkKit'; // ✅ 注意这里要解构导入


export class HttpHelper {
  private static instance: HttpHelper;

  private constructor() {
  }

  static getInstance(): HttpHelper {
    if (!HttpHelper.instance) {
      HttpHelper.instance = new HttpHelper();
    }
    return HttpHelper.instance;
  }



  async request(url: string, options?: http.HttpRequestOptions): Promise<http.HttpResponse>{
    const httpRequest = http.createHttp();
    const response = await httpRequest.request(
      url,
      options
    );
    httpRequest.destroy()
    return response;
  }
}
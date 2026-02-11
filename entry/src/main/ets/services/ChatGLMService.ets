import http from '@ohos.net.http';

export interface ChatMessage {
  role: 'system' | 'user' | 'assistant';
  content: string;
}

interface ChatChoice {
  message: ChatMessage;
}

interface ChatResponse {
  choices: ChatChoice[];
}

export class ChatGLMService {
  private static readonly API_URL: string = 'https://open.bigmodel.cn/api/paas/v4/chat/completions';
  private static readonly API_KEY: string = '82e4d46a05264dd19a27e1d91b30dce6.UNpMhFWNznhFSPLo';
  private static chatHistory: ChatMessage[] = [];

  static initChat(city: string, weather: string): void {
    ChatGLMService.clearHistory();
    const safeCity = (city === '定位中...' || !city) ? '这座城市' : city;

    ChatGLMService.chatHistory.push({
      role: "system",
      content: `你是一个高效的城市探险向导。当前城市：${safeCity}，天气：${weather}。
规则：
1. 直击重点，拒绝废话，拒绝过度煽情。
2. 每次回复严格控制在288字以内。
3. 重点提供地理逻辑合理的路线、真实好吃的店名、避雷建议。
4. 有文采但不堆砌辞藻，以解决问题为第一优先级。
5. 输出的时候不要使用markdown格式，正常文本输出
6. 你必须严格依据提供的实时天气数据进行回答。如果数据显示气温为 -1°C，严禁建议用户穿短袖。`
    });
  }

  static async getAdventureAdvice(city: string, weather: string, userQuery: string): Promise<string> {
    let httpRequest = http.createHttp();
    const queryContent = userQuery.trim() || "请推荐当前的探索亮点";

    if (ChatGLMService.chatHistory.length === 0) {
      ChatGLMService.initChat(city, weather);
    }

    ChatGLMService.chatHistory.push({ role: "user", content: queryContent });

    const MAX_HISTORY = 10;
    if (ChatGLMService.chatHistory.length > MAX_HISTORY) {
      const systemMsg = ChatGLMService.chatHistory[0];
      const recent = ChatGLMService.chatHistory.slice(-(MAX_HISTORY - 1));
      ChatGLMService.chatHistory = [systemMsg, ...recent];
    }

    console.info('[GLM] ===== 请求开始 =====');
    console.info('[GLM] 请求消息条数:', ChatGLMService.chatHistory.length);

    try {
      let response = await httpRequest.request(ChatGLMService.API_URL, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${ChatGLMService.API_KEY}`
        },
        connectTimeout: 10000,
        readTimeout: 20000,
        extraData: {
          "model": "glm-4.7",
          "messages": ChatGLMService.chatHistory,
          thinking: { type: "disabled" },
          "temperature": 0.6,
          "max_tokens": 512
        }
      });

      console.info('[GLM] responseCode:', response.responseCode);
      console.info('[GLM] 原始返回:', response.result);

      if (response.responseCode === 200) {
        const result = JSON.parse(response.result as string) as ChatResponse;

        if (!result.choices || result.choices.length === 0) {
          console.error('[GLM] 返回结构异常:', result);
          return "【解析异常】智库返回了未知结构。";
        }

        const aiReply = result.choices[0].message.content;
        ChatGLMService.chatHistory.push({ role: "assistant", content: aiReply });

        console.info('[GLM] ===== 请求成功结束 =====');
        return aiReply;
      } else {
        console.error('[GLM] 非200状态码:', response.responseCode);
        return "【信号波动】探险家，城市里的灵感似乎被乌云遮住了，请稍后再试。";
      }

    } catch (err) {
      console.error('[GLM] 请求异常:', JSON.stringify(err));
      console.error('[GLM] 请求异常对象:', err);
      return "【连接异常】时空波动，无法同步智库。";
    } finally {
      console.info('[GLM] 销毁 httpRequest');
      httpRequest.destroy();
    }
  }

  static getHistory(): ChatMessage[] {
    return ChatGLMService.chatHistory;
  }

  static clearHistory(): void {
    ChatGLMService.chatHistory = [];
  }
}

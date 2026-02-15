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

export type ChatMode = 'guide' | 'copywriting' | 'casual' | 'dating';

export class ChatGLMService {

  private static readonly API_URL = 'http://192.168.10.107:3000/api/chat';
  private static chatHistory: ChatMessage[] = [];
  private static currentMode: ChatMode | null = null;

  private static detectMode(query: string): ChatMode {

    const text = query.toLowerCase();

    if (/朋友圈|文案|发圈|配文/.test(text)) {
      return 'copywriting';
    }

    if (/约会|第一次见面|适合两个人|表白/.test(text)) {
      return 'dating';
    }

    if (/心情不好|被骂|失恋|难受|疗愈/.test(text)) {
      return 'dating';
    }

    if (/路线|攻略|怎么玩|安排|推荐行程/.test(text)) {
      return 'guide';
    }

    return 'casual';
  }

  private static buildSystemPrompt(
    mode: ChatMode,
    city: string,
    weather: string
  ): string {

    const safeCity = (city === '定位中...' || !city) ? '这座城市' : city;

    const weatherRule = `
你必须严格使用提供的天气信息。
禁止虚构天气。
禁止更改天气状态。
当前天气数据：${weather}。`;

    if (mode === 'guide') {
      return `你是一名城市路线规划顾问。
当前城市：${safeCity}。
${weatherRule}

规则：
1. 提供逻辑清晰的动线安排。
2. 可以推荐具体地点或商圈。
3. 避免固定模板表达。
4. 不使用markdown。
5. 控制在300字以内。
6. 语言自然，不要像旅游宣传册。`;
    }

    if (mode === 'copywriting') {
      return `你是一位审美在线的朋友圈文案写手。
当前城市：${safeCity}。
${weatherRule}

规则：
1. 输出可直接发布的朋友圈文案。
2. 不写攻略、不写路线、不推荐店名。
3. 不解释、不加说明。
4. 避免模板化句式。
5. 控制在90字以内。
6. 文风自然、有画面感。`;
    }

    if (mode === 'dating') {
      return `你是一位擅长氛围营造的城市生活顾问。
当前城市：${safeCity}。
${weatherRule}

规则：
1. 根据场景给出2-3种建议。
2. 不做完整路线规划。
3. 不写“避雷”列表。
4. 不使用固定结构。
5. 语气自然、真实。
6. 控制在200字以内。`;
    }

    return `你是一个自然、聪明的城市生活助手。
当前城市：${safeCity}。
${weatherRule}

规则：
1. 简洁回答问题。
2. 不使用固定模板。
3. 控制在180字以内。`;
  }

  static initChat(city: string, weather: string, mode: ChatMode): void {
    ChatGLMService.clearHistory();
    ChatGLMService.currentMode = mode;
    ChatGLMService.chatHistory.push({
      role: "system",
      content: ChatGLMService.buildSystemPrompt(mode, city, weather)
    });
  }

  static async getAdventureAdvice(
    city: string,
    weather: string,
    userQuery: string
  ): Promise<string> {

    let httpRequest = http.createHttp();
    const queryContent = userQuery.trim() || "今天适合做什么？";

    if (ChatGLMService.chatHistory.length === 0) {
      ChatGLMService.currentMode = ChatGLMService.detectMode(queryContent);
      ChatGLMService.initChat(city, weather, ChatGLMService.currentMode);
      console.info('[GLM] 初始化新对话，模式:', ChatGLMService.currentMode);
    }

    const activeMode = ChatGLMService.currentMode || ChatGLMService.detectMode(queryContent);

    ChatGLMService.chatHistory.push({
      role: "user",
      content: queryContent
    });

    let temperature = 0.7;
    let maxTokens = 400;

    switch (activeMode) {
      case 'guide':
        temperature = 0.5;
        maxTokens = 600;
        break;
      case 'copywriting':
        temperature = 0.9;
        maxTokens = 200;
        break;
      case 'dating':
        temperature = 0.85;
        maxTokens = 350;
        break;
      case 'casual':
        temperature = 0.75;
        maxTokens = 300;
        break;
    }

    try {
      let response = await httpRequest.request(ChatGLMService.API_URL, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json',
        },
        connectTimeout: 30000,
        readTimeout: 30000,
        extraData: {
          "model": "glm-4.7",
          "messages": ChatGLMService.chatHistory,
          thinking: { type: "disabled" },
          "temperature": temperature,
          "max_tokens": maxTokens
        }
      });

      if (response.responseCode === 200) {

        const result = JSON.parse(response.result as string) as ChatResponse;

        if (!result.choices || result.choices.length === 0) {
          return "【解析异常】灵感似乎被城市里的乌云遮住了";
        }

        const aiReply = result.choices[0].message.content;

        ChatGLMService.chatHistory.push({
          role: "assistant",
          content: aiReply
        });

        return aiReply;

      } else {
        return "【信号波动】稍后再试。";
      }

    } catch (err) {
      return "【连接异常】无法连接智库。";
    } finally {
      httpRequest.destroy();
    }
  }

  static getHistory(): ChatMessage[] {
    return ChatGLMService.chatHistory;
  }

  static clearHistory(): void {
    ChatGLMService.chatHistory = [];
    ChatGLMService.currentMode = null;
  }
}

import { http } from '@kit.NetworkKit';
const BASE_URL = 'https://login-inchnzmmux.cn-hangzhou.fcapp.run';

export interface RegisterPayload {
  username: string;
  email: string;
  password: string;
  avatar: string;
}

export interface LoginPayload {
  email: string;
  password: string;
}

export interface GetUserPayload {
  userId: string;
}

export interface ChangePasswordPayload {
  token: string;
  newPassword: string;
}

export interface DeleteAccountPayload {
  token: string;
}

export interface CloudUser {
  _id: string;
  username: string;
  email: string;
  avatar: string;
  domainId: string;
}

export interface ApiResponse {
  success: boolean;
  user?: CloudUser;
  token?: string;
  message?: string;
}

class UserRepository {

  private async post(path: string, data: object): Promise<ApiResponse> {
    const httpRequest = http.createHttp();

    const response = await httpRequest.request(
      `${BASE_URL}${path}`,
      {
        method: http.RequestMethod.POST,
        header: { 'Content-Type': 'application/json' },
        extraData: data
      }
    );

    httpRequest.destroy();

    return JSON.parse(response.result as string) as ApiResponse;
  }

  async register(username: string, email: string, password: string): Promise<ApiResponse> {
    const payload: RegisterPayload = {
      username,
      email,
      password,
      avatar: 'app.media.start'
    };
    return this.post('/user/register', payload);
  }

  async login(email: string, password: string): Promise<ApiResponse> {
    const payload: LoginPayload = {
      email,
      password
    };
    return this.post('/user/login', payload);
  }

  async getUserById(userId: string): Promise<CloudUser | null> {
    const payload: GetUserPayload = { userId };
    const result = await this.post('/user/getUserById', payload);
    return result.success && result.user ? result.user : null;
  }

  async changePassword(token: string, newPassword: string): Promise<boolean> {
    const payload: ChangePasswordPayload = { token, newPassword };
    const result = await this.post('/user/changePassword', payload);
    return result.success;
  }

  async deleteAccount(token: string): Promise<boolean> {
    const payload: DeleteAccountPayload = { token };
    const result = await this.post('/user/deleteAccount', payload);
    return result.success;
  }
}

export const userRepo = new UserRepository();

import { PreferenceManager } from '../services/PreferenceManager';
import { common } from '@kit.AbilityKit';
import { http } from '@kit.NetworkKit';

class AutoLoginUser {
  _id: string = '';
  username: string = '';
  email: string = '';
  avatar: string = '';
}

class AutoLoginResponse {
  success: boolean = false;
  user?: AutoLoginUser;
}

const BASE_URL = 'https://login-inchnzmmux.cn-hangzhou.fcapp.run';

export async function autoLogin(context: common.UIAbilityContext): Promise<boolean> {
  const token = await PreferenceManager.get(context, 'token', '');

  if (!token) {
    return false;
  }

  const httpRequest = http.createHttp();
  try {
    const response = await httpRequest.request(
      `${BASE_URL}/user/autoLogin`,
      {
        method: http.RequestMethod.POST,
        header: { 'Content-Type': 'application/json' },
        extraData: { token }
      }
    );

    if (response.responseCode !== 200) {
      return false;
    }

    let data: AutoLoginResponse;
    if (typeof response.result === 'string') {
      data = JSON.parse(response.result) as AutoLoginResponse;
    } else {
      data = response.result as AutoLoginResponse;
    }

    if (!data.success || !data.user) {
      return false;
    }

    const user = data.user;
    const domainId = await PreferenceManager.get(context, 'domainId', '') as string;

    AppStorage.setOrCreate('domainId', domainId ?? '');
    AppStorage.setOrCreate('isLoggedIn', true);
    AppStorage.setOrCreate('userName', user.username);
    AppStorage.setOrCreate('currentUserId', user._id);
    AppStorage.setOrCreate('userAvatar', user.avatar);

    await PreferenceManager.put(context, 'isLoggedIn', true);
    await PreferenceManager.put(context, 'userName', user.username);
    await PreferenceManager.put(context, 'currentUserId', user._id);
    await PreferenceManager.put(context, 'userAvatar', user.avatar);

    return true;
  } catch (err) {
    return false;
  } finally {
    httpRequest.destroy();
  }
}
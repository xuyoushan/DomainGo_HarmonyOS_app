import { FormExtensionAbility, formBindingData, formProvider } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';
import preferences from '@ohos.data.preferences';
import { common } from '@kit.AbilityKit';
import wantAgent from '@ohos.app.ability.wantAgent';

interface MySchedule {
  id: string;
  title: string;
  location: string;
  description: string;
  date: string;
}

export default class EntryFormAbility extends FormExtensionAbility {

  onAddForm(want: Want): formBindingData.FormBindingData {
    console.info('[FormAbility] onAddForm');

    const context = this.context as common.Context;
    const formId = want.parameters?.['ohos.extra.param.key.form_id'] as string;

    this.initializeFormData(formId, context);

    return formBindingData.createFormBindingData({});
  }

  private async initializeFormData(formId: string, context: common.Context) {
    try {
      const pref = await preferences.getPreferences(context, 'travel_db');
      await pref.put('current_form_id', formId);
      await pref.flush();

      await this.updateForm(formId, context);
    } catch (err) {
      console.error('[FormAbility] initializeFormData failed');
    }
  }

  async onUpdateForm(formId: string) {
    console.info('[FormAbility] onUpdateForm');
    const context = this.context as common.Context;
    await this.updateForm(formId, context);
  }

  onDeleteForm(formId: string) {
    console.info('[FormAbility] onDelete formId:', formId);
  }

  async onFormEvent(formId: string, message: string) {
    if (message !== 'openSchedule') {
      return;
    }

    const wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [
        {
          bundleName: 'com.youshan.domaingo',
          abilityName: 'EntryAbility',
          parameters: {
            route: 'scheduleview'
          }
        }
      ],
      operationType: wantAgent.OperationType.START_ABILITY,
      requestCode: 0,
      wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    };

    const agent = await wantAgent.getWantAgent(wantAgentInfo);
    wantAgent.trigger(agent, {
      code: 0
    });
  }

  private async updateForm(formId: string, context: common.Context) {
    try {
      const pref = await preferences.getPreferences(context, 'travel_db');
      const raw = await pref.get('schedules', '[]');

      const schedules = JSON.parse(raw as string) as MySchedule[];

      const formData = formBindingData.createFormBindingData({
        'schedules': schedules
      });

      await formProvider.updateForm(formId, formData);

      console.info('[FormAbility] updateForm success');
    } catch (err) {
      console.error('[FormAbility] updateForm failed', JSON.stringify(err));
    }
  }
}
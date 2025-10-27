import { common } from '@kit.AbilityKit';
import { util } from '@kit.ArkTS';
import ThingModel from './ThingModel';

export default class TodoListModel {
  things: Array<ThingModel> = [];

  constructor(things: Array<ThingModel>) {
    this.things = things;
  }

  async loadTasks(context: common.UIAbilityContext) {
    let getJson = await context.resourceManager.getRawFileContent('default_tasks.json');
    let textDecoderOptions: util.TextDecoderOptions = { ignoreBOM: true };
    let textDecoder = util.TextDecoder.create('utf-8', textDecoderOptions);
    let result = textDecoder.decodeToString(getJson, { stream: false });
    this.things = JSON.parse(result);
  }
}
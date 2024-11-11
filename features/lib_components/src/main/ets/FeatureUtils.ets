import { ArkTSUtils, util } from "@kit.ArkTS";


export class FeatureUtils {
  static getRandomColor() {
    const letters: string = '0123456789ABCDEF';
    let color: string = '#';
    for (let i = 0; i < 6; i++) {
      let Itemp: number = Math.floor(Math.random() * 16)
      color += letters[Itemp];
    }
    console.log(color)
    return color;
  }
}
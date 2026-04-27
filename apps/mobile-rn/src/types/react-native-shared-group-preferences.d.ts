/**
 * react-native-shared-group-preferences — 공식 @types 미존재.
 * Sprint W1 에서 iOS 홈 화면 위젯 App Group UserDefaults 브릿지로 사용.
 * API 참고: https://github.com/KjellConnelly/react-native-shared-group-preferences
 */
declare module 'react-native-shared-group-preferences' {
  /**
   * App Group UserDefaults 에 key-value 저장.
   * iOS: `UserDefaults(suiteName: appGroup).setObject(value, forKey: key)`
   * Android: no-op (또는 SharedPreferences) — lib 내부에서 처리.
   */
  export function setItem(
    key: string,
    value: string,
    appGroup: string,
  ): Promise<null>;

  export function getItem(
    key: string,
    appGroup: string,
  ): Promise<string | null>;

  const SharedGroupPreferences: {
    setItem: typeof setItem;
    getItem: typeof getItem;
  };

  export default SharedGroupPreferences;
}

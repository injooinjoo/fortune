/**
 * LockScreen — iOS 16+ 잠금화면.
 * Date / Time / Widget tray (3 circular + 2 rect) / flashlight+camera.
 * 원본: Ondo Widgets.html LockScreen().
 */

import { View } from 'react-native';
import Svg, { Circle, Path } from 'react-native-svg';

import { AppText } from '../../../components/app-text';

import {
  LockConstellationCircle,
  LockFortuneRect,
  LockScoreCircle,
  LockTarotRect,
  LockUnreadCircle,
} from '../lock-widgets';

import { Wallpaper } from './wallpaper';

export function LockScreen() {
  return (
    <Wallpaper variant="aurora">
      {/* Date */}
      <View
        pointerEvents="none"
        style={{
          position: 'absolute',
          top: 62,
          left: 0,
          right: 0,
          alignItems: 'center',
          zIndex: 5,
        }}
      >
        <AppText
          color="rgba(255,255,255,0.9)"
          style={{ fontSize: 15, fontWeight: '600', letterSpacing: 0.2 }}
        >
          Friday, April 12
        </AppText>
      </View>

      {/* Hero time */}
      <View
        pointerEvents="none"
        style={{
          position: 'absolute',
          top: 86,
          left: 0,
          right: 0,
          alignItems: 'center',
          zIndex: 5,
        }}
      >
        <AppText
          color="#FFFFFF"
          style={{
            fontSize: 90,
            fontWeight: '300',
            letterSpacing: -3,
            lineHeight: 96,
          }}
        >
          9:41
        </AppText>
      </View>

      {/* Widget tray */}
      <View
        style={{
          position: 'absolute',
          top: 222,
          left: 0,
          right: 0,
          alignItems: 'center',
          gap: 8,
          zIndex: 5,
        }}
      >
        <View style={{ flexDirection: 'row', gap: 10, alignItems: 'center' }}>
          <LockScoreCircle />
          <LockConstellationCircle />
          <LockUnreadCircle />
        </View>
        <LockFortuneRect />
        <LockTarotRect />
      </View>

      {/* Bottom shortcut buttons */}
      <View
        style={{
          position: 'absolute',
          bottom: 40,
          left: 24,
          width: 44,
          height: 44,
          borderRadius: 22,
          backgroundColor: 'rgba(0,0,0,0.35)',
          alignItems: 'center',
          justifyContent: 'center',
          zIndex: 50,
        }}
      >
        <Svg width={18} height={18} viewBox="0 0 18 18">
          <Path
            d="M5 2h8v3H5V2zm1 4h6l-1 10H7L6 6z"
            stroke="#fff"
            strokeWidth={1.4}
            fill="none"
          />
        </Svg>
      </View>
      <View
        style={{
          position: 'absolute',
          bottom: 40,
          right: 24,
          width: 44,
          height: 44,
          borderRadius: 22,
          backgroundColor: 'rgba(0,0,0,0.35)',
          alignItems: 'center',
          justifyContent: 'center',
          zIndex: 50,
        }}
      >
        <Svg width={18} height={18} viewBox="0 0 18 18">
          <Path
            d="M6 5V3h6v2h3a1 1 0 011 1v8a1 1 0 01-1 1H3a1 1 0 01-1-1V6a1 1 0 011-1h3z"
            stroke="#fff"
            strokeWidth={1.4}
            fill="none"
          />
          <Circle cx="9" cy="10" r="3" stroke="#fff" strokeWidth={1.4} fill="none" />
        </Svg>
      </View>
    </Wallpaper>
  );
}

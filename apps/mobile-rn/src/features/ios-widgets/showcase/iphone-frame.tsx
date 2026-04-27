/**
 * IPhoneFrame — iPhone 14/15 Pro 외형 목업.
 * 372×806 기본. 상단 Dynamic Island (126×37). 스케일 prop.
 * 원본: iphone-shell.jsx IPhoneFrame + StatusBar + HomeIndicator.
 */

import type { ReactNode } from 'react';
import { View } from 'react-native';
import Svg, { Path, Rect } from 'react-native-svg';

import { AppText } from '../../../components/app-text';

export interface IPhoneFrameProps {
  children?: ReactNode;
  width?: number;
  height?: number;
  showIsland?: boolean;
  showStatusBar?: boolean;
  showHomeIndicator?: boolean;
  liveActivity?: ReactNode;
  /** 디폴트 0.78 (RN에서는 372×806이 너무 커서 축소) */
  scale?: number;
  time?: string;
}

export function IPhoneFrame({
  children,
  width = 372,
  height = 806,
  showIsland = true,
  showStatusBar = true,
  showHomeIndicator = true,
  liveActivity,
  scale = 0.78,
  time = '9:41',
}: IPhoneFrameProps) {
  const outerW = width + 14;
  const outerH = height + 14;

  return (
    <View
      style={{
        width: outerW * scale,
        height: outerH * scale,
      }}
    >
      <View
        style={{
          width: outerW,
          height: outerH,
          transform: [{ scale }],
          transformOrigin: 'top left',
          // iOS 15 Pro titanium shell
          borderRadius: 54,
          padding: 7,
          backgroundColor: '#1F1F24',
          shadowColor: '#000',
          shadowOpacity: 0.6,
          shadowRadius: 50,
          shadowOffset: { width: 0, height: 30 },
          position: 'relative',
        }}
      >
        {/* Inner screen */}
        <View
          style={{
            width,
            height,
            borderRadius: 48,
            overflow: 'hidden',
            position: 'relative',
            backgroundColor: '#000',
          }}
        >
          {children}

          {showStatusBar ? <StatusBar time={time} /> : null}

          {/* Dynamic Island / Live Activity */}
          {showIsland ? (
            <View
              style={{
                position: 'absolute',
                top: 11,
                left: 0,
                right: 0,
                alignItems: 'center',
                zIndex: 100,
              }}
            >
              {liveActivity ?? (
                <View
                  style={{
                    width: 110,
                    height: 34,
                    borderRadius: 20,
                    backgroundColor: '#000',
                  }}
                />
              )}
            </View>
          ) : null}

          {/* Home indicator */}
          {showHomeIndicator ? (
            <View
              style={{
                position: 'absolute',
                bottom: 6,
                left: 0,
                right: 0,
                alignItems: 'center',
                zIndex: 100,
              }}
            >
              <View
                style={{
                  width: 120,
                  height: 4.5,
                  borderRadius: 3,
                  backgroundColor: 'rgba(255,255,255,0.75)',
                }}
              />
            </View>
          ) : null}
        </View>

        {/* Side buttons */}
        <View
          style={{
            position: 'absolute',
            left: -2,
            top: 140,
            width: 3,
            height: 32,
            backgroundColor: '#2A2A30',
            borderRadius: 2,
          }}
        />
        <View
          style={{
            position: 'absolute',
            left: -2,
            top: 186,
            width: 3,
            height: 56,
            backgroundColor: '#2A2A30',
            borderRadius: 2,
          }}
        />
        <View
          style={{
            position: 'absolute',
            left: -2,
            top: 252,
            width: 3,
            height: 56,
            backgroundColor: '#2A2A30',
            borderRadius: 2,
          }}
        />
        <View
          style={{
            position: 'absolute',
            right: -2,
            top: 180,
            width: 3,
            height: 88,
            backgroundColor: '#2A2A30',
            borderRadius: 2,
          }}
        />
      </View>
    </View>
  );
}

interface StatusBarProps {
  time: string;
}

function StatusBar({ time }: StatusBarProps) {
  return (
    <View
      pointerEvents="none"
      style={{
        position: 'absolute',
        top: 0,
        left: 0,
        right: 0,
        zIndex: 50,
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'space-between',
        paddingHorizontal: 26,
        paddingTop: 14,
      }}
    >
      <AppText color="#FFFFFF" style={{ fontSize: 15, fontWeight: '600' }}>
        {time}
      </AppText>
      <View style={{ width: 126, height: 32 }} />
      <View style={{ flexDirection: 'row', alignItems: 'center', gap: 5 }}>
        <Svg width={17} height={11} viewBox="0 0 19 12">
          <Rect x="0" y="7.5" width="3.2" height="4.5" rx="0.7" fill="#fff" />
          <Rect x="4.8" y="5" width="3.2" height="7" rx="0.7" fill="#fff" />
          <Rect x="9.6" y="2.5" width="3.2" height="9.5" rx="0.7" fill="#fff" />
          <Rect x="14.4" y="0" width="3.2" height="12" rx="0.7" fill="#fff" />
        </Svg>
        <Svg width={24} height={11} viewBox="0 0 27 13">
          <Rect
            x="0.5"
            y="0.5"
            width="23"
            height="12"
            rx="3.5"
            stroke="#fff"
            strokeOpacity={0.4}
            fill="none"
          />
          <Rect x="2" y="2" width="20" height="9" rx="2" fill="#fff" />
          <Path
            d="M25 4.5V8.5C25.8 8.2 26.5 7.2 26.5 6.5C26.5 5.8 25.8 4.8 25 4.5Z"
            fill="#fff"
            fillOpacity={0.4}
          />
        </Svg>
      </View>
    </View>
  );
}

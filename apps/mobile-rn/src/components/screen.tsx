import {
  useEffect,
  useState,
  type PropsWithChildren,
  type ReactNode,
  type RefObject,
} from 'react';

import { Keyboard, KeyboardAvoidingView, Platform, Pressable, ScrollView, View } from 'react-native';
import { SafeAreaView, useSafeAreaInsets } from 'react-native-safe-area-context';
import Svg, { Defs, LinearGradient, Rect, Stop } from 'react-native-svg';

import { fortuneTheme } from '../lib/theme';

interface ScreenProps extends PropsWithChildren {
  header?: ReactNode;
  footer?: ReactNode;
  overlay?: ReactNode;
  keyboardAvoiding?: boolean;
  scrollViewRef?: RefObject<ScrollView | null>;
  onScrollContentSizeChange?: (width: number, height: number) => void;
  contentBottomInset?: number;
  centerContent?: boolean;
  /** Dismisses the keyboard on empty-space taps and scroll drags. */
  dismissKeyboardOnTap?: boolean;
  /** Header 아래 스크롤 콘텐츠가 스르르 사라지도록 덮는 상단 fade 경계. */
  topBoundaryFade?: boolean;
}

export function Screen({
  children,
  header,
  footer,
  overlay,
  keyboardAvoiding = false,
  scrollViewRef,
  onScrollContentSizeChange,
  contentBottomInset = 0,
  centerContent = false,
  dismissKeyboardOnTap = false,
  topBoundaryFade = false,
}: ScreenProps) {
  const insets = useSafeAreaInsets();
  const [keyboardVisible, setKeyboardVisible] = useState(false);

  useEffect(() => {
    if (!keyboardAvoiding) {
      setKeyboardVisible(false);
      return;
    }

    const showEvent = Platform.OS === 'ios' ? 'keyboardWillShow' : 'keyboardDidShow';
    const hideEvent = Platform.OS === 'ios' ? 'keyboardWillHide' : 'keyboardDidHide';
    const showSub = Keyboard.addListener(showEvent, () => setKeyboardVisible(true));
    const hideSub = Keyboard.addListener(hideEvent, () => setKeyboardVisible(false));

    return () => {
      showSub.remove();
      hideSub.remove();
    };
  }, [keyboardAvoiding]);

  const footerPaddingBottom =
    keyboardAvoiding && keyboardVisible
      ? fortuneTheme.spacing.sm
      : fortuneTheme.spacing.pageVertical + insets.bottom;
  const floatingHeader = Boolean(header && topBoundaryFade);
  const [headerChromeHeight, setHeaderChromeHeight] = useState(96);
  const floatingHeaderHeight = Math.max(headerChromeHeight, 96);
  const topFadeHeight = floatingHeader ? floatingHeaderHeight + 28 : 28;

  const content = (
    <View style={{ flex: 1 }}>
      {topBoundaryFade ? (
        <View
          pointerEvents="none"
          style={{
            height: topFadeHeight,
            left: 0,
            position: 'absolute',
            right: 0,
            top: 0,
            zIndex: 8,
          }}
        >
          <Svg height={topFadeHeight} preserveAspectRatio="none" width="100%">
            <Defs>
              {floatingHeader ? (
                <LinearGradient id="screenTopBoundaryFade" x1="0" y1="0" x2="0" y2="1">
                  <Stop offset="0" stopColor={fortuneTheme.colors.background} stopOpacity={0.78} />
                  <Stop offset="0.54" stopColor={fortuneTheme.colors.background} stopOpacity={0.44} />
                  <Stop offset="0.78" stopColor={fortuneTheme.colors.background} stopOpacity={0.16} />
                  <Stop offset="1" stopColor={fortuneTheme.colors.background} stopOpacity={0} />
                </LinearGradient>
              ) : (
                <LinearGradient id="screenTopBoundaryFade" x1="0" y1="0" x2="0" y2="1">
                  <Stop offset="0" stopColor={fortuneTheme.colors.background} stopOpacity={0.62} />
                  <Stop offset="0.42" stopColor={fortuneTheme.colors.background} stopOpacity={0.24} />
                  <Stop offset="1" stopColor={fortuneTheme.colors.background} stopOpacity={0} />
                </LinearGradient>
              )}
            </Defs>
            <Rect
              x="0"
              y="0"
              width="100%"
              height={topFadeHeight}
              fill="url(#screenTopBoundaryFade)"
            />
          </Svg>
        </View>
      ) : null}
      {header ? (
        <View
          pointerEvents={floatingHeader ? 'box-none' : 'auto'}
          onLayout={({ nativeEvent }) => {
            if (!floatingHeader) {
              return;
            }
            const nextHeight = Math.ceil(nativeEvent.layout.height);
            if (nextHeight > 0 && Math.abs(nextHeight - headerChromeHeight) > 1) {
              setHeaderChromeHeight(nextHeight);
            }
          }}
          style={{
            backgroundColor: floatingHeader ? 'transparent' : fortuneTheme.colors.background,
            left: floatingHeader ? 0 : undefined,
            paddingHorizontal: fortuneTheme.spacing.pageHorizontal,
            paddingTop: fortuneTheme.spacing.pageVertical,
            paddingBottom: fortuneTheme.spacing.sm,
            position: floatingHeader ? 'absolute' : undefined,
            right: floatingHeader ? 0 : undefined,
            top: floatingHeader ? 0 : undefined,
            zIndex: 10,
          }}
        >
          {header}
        </View>
      ) : null}
      <View style={{ flex: 1 }}>
        <ScrollView
          contentContainerStyle={{
            paddingHorizontal: fortuneTheme.spacing.pageHorizontal,
            paddingTop: header
              ? floatingHeader
                ? floatingHeaderHeight
                : fortuneTheme.spacing.sm
              : fortuneTheme.spacing.pageVertical,
            paddingBottom:
              (footer ? fortuneTheme.spacing.md : fortuneTheme.spacing.pageVertical) +
              contentBottomInset,
            gap: fortuneTheme.spacing.md,
            maxWidth: 600,
            alignSelf: 'center',
            width: '100%',
            ...(centerContent
              ? { flexGrow: 1, justifyContent: 'center' }
              : dismissKeyboardOnTap
                ? { flexGrow: 1 }
                : null),
          }}
          keyboardShouldPersistTaps="handled"
          keyboardDismissMode={dismissKeyboardOnTap ? 'on-drag' : 'none'}
          onContentSizeChange={onScrollContentSizeChange}
          ref={scrollViewRef}
          style={{ flex: 1 }}
        >
          {dismissKeyboardOnTap ? (
            <Pressable
              onPress={() => Keyboard.dismiss()}
              style={{ flexGrow: 1 }}
            >
              <View style={{ flexGrow: 1, gap: fortuneTheme.spacing.md }}>
                {children}
              </View>
            </Pressable>
          ) : (
            <View style={{ gap: fortuneTheme.spacing.md }}>{children}</View>
          )}
        </ScrollView>
      </View>
      {footer ? (
        <View
          style={{
            backgroundColor: fortuneTheme.colors.background,
            // keyboardAvoiding 모드: SafeAreaView 가 bottom 을 빼므로 footer 가 직접
            // insets.bottom 처리. KAV 가 키보드 올라오면 알아서 위로 밀어줌.
            paddingBottom: footerPaddingBottom,
            paddingHorizontal: fortuneTheme.spacing.pageHorizontal,
            paddingTop: fortuneTheme.spacing.sm,
          }}
        >
          {footer}
        </View>
      ) : null}
      {overlay ? (
        <View
          pointerEvents="box-none"
          style={{
            bottom: fortuneTheme.spacing.pageVertical,
            left: fortuneTheme.spacing.pageHorizontal,
            position: 'absolute',
            right: fortuneTheme.spacing.pageHorizontal,
          }}
        >
          {overlay}
        </View>
      ) : null}
    </View>
  );

  // 키보드 감지 모드에서는 SafeAreaView bottom 인셋을 빼고 footer가 직접
  // inset 처리. 이래야 iOS에서 키보드가 composer를 가리지 않음.
  return (
    <SafeAreaView
      edges={
        keyboardAvoiding ? ['top', 'left', 'right'] : ['top', 'bottom', 'left', 'right']
      }
      style={{
        flex: 1,
        backgroundColor: fortuneTheme.colors.background,
      }}
    >
      {keyboardAvoiding ? (
        <KeyboardAvoidingView
          behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
          style={{ flex: 1 }}
          // iOS는 SafeAreaView 가 top inset 처리하므로 KAV 자체 offset 은 0.
          // bottom 은 SafeAreaView edges 에서 제외했고 footer 가 직접 inset 처리.
          keyboardVerticalOffset={0}
        >
          {content}
        </KeyboardAvoidingView>
      ) : (
        content
      )}
    </SafeAreaView>
  );
}

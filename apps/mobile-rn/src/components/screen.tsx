import type { PropsWithChildren, ReactNode, RefObject } from 'react';

import { KeyboardAvoidingView, Platform, ScrollView, View } from 'react-native';
import { SafeAreaView, useSafeAreaInsets } from 'react-native-safe-area-context';

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
}: ScreenProps) {
  const insets = useSafeAreaInsets();
  const content = (
    <View style={{ flex: 1 }}>
      {header ? (
        <View
          style={{
            backgroundColor: fortuneTheme.colors.background,
            paddingHorizontal: fortuneTheme.spacing.pageHorizontal,
            paddingTop: fortuneTheme.spacing.pageVertical,
            paddingBottom: fortuneTheme.spacing.sm,
            zIndex: 10,
          }}
        >
          {header}
        </View>
      ) : null}
      <ScrollView
        contentContainerStyle={{
          paddingHorizontal: fortuneTheme.spacing.pageHorizontal,
          paddingTop: header
            ? fortuneTheme.spacing.sm
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
            : null),
        }}
        keyboardShouldPersistTaps="handled"
        onContentSizeChange={onScrollContentSizeChange}
        ref={scrollViewRef}
        style={{ flex: 1 }}
      >
        <View style={{ gap: fortuneTheme.spacing.md }}>{children}</View>
      </ScrollView>
      {footer ? (
        <View
          style={{
            backgroundColor: fortuneTheme.colors.background,
            paddingBottom: keyboardAvoiding
              ? fortuneTheme.spacing.pageVertical
              : fortuneTheme.spacing.pageVertical + insets.bottom,
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

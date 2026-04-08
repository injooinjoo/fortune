import type { PropsWithChildren, ReactNode, RefObject } from 'react';

import { KeyboardAvoidingView, Platform, ScrollView, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { fortuneTheme } from '../lib/theme';

interface ScreenProps extends PropsWithChildren {
  header?: ReactNode;
  footer?: ReactNode;
  overlay?: ReactNode;
  keyboardAvoiding?: boolean;
  scrollViewRef?: RefObject<ScrollView | null>;
  onScrollContentSizeChange?: (width: number, height: number) => void;
  contentBottomInset?: number;
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
}: ScreenProps) {
  const content = (
    <View style={{ flex: 1 }}>
      {header ? (
        <View
          style={{
            backgroundColor: fortuneTheme.colors.background,
            paddingHorizontal: fortuneTheme.spacing.pageHorizontal,
            paddingTop: fortuneTheme.spacing.pageVertical,
            paddingBottom: fortuneTheme.spacing.sm,
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
            paddingBottom: fortuneTheme.spacing.pageVertical,
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

  return (
    <SafeAreaView
      style={{
        flex: 1,
        backgroundColor: fortuneTheme.colors.background,
      }}
    >
      {keyboardAvoiding ? (
        <KeyboardAvoidingView
          behavior={Platform.OS === 'ios' ? 'padding' : undefined}
          style={{ flex: 1 }}
        >
          {content}
        </KeyboardAvoidingView>
      ) : (
        content
      )}
    </SafeAreaView>
  );
}

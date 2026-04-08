import * as React from 'react';
import { Platform } from 'react-native';

import {
  createWidget,
  type Widget,
  type WidgetEnvironment,
} from 'expo-widgets';
import { Host, HStack, Text, VStack } from '@expo/ui/swift-ui';
import {
  backgroundOverlay,
  cornerRadius,
  fixedSize,
  font,
  foregroundStyle,
  lineLimit,
  multilineTextAlignment,
  opacity,
  padding,
  frame,
} from '@expo/ui/swift-ui/modifiers';

import { fortuneTheme } from '../lib/theme';

export type FortuneWidgetTone = 'positive' | 'balanced' | 'careful';

export type FortuneHomeWidgetProps = {
  headline: string;
  summary: string;
  scoreLabel: string;
  badgeLabel: string;
  updatedAtLabel: string;
  tone: FortuneWidgetTone;
  accentColor: string;
  surfaceColor: string;
  textColor: string;
  secondaryTextColor: string;
};

const widgetName = 'FortuneHomeWidget';

let widgetInstance: Widget<FortuneHomeWidgetProps> | null = null;

function getToneLabel(tone: FortuneWidgetTone) {
  switch (tone) {
    case 'positive':
      return '좋은 흐름';
    case 'careful':
      return '주의 흐름';
    default:
      return '안정 흐름';
  }
}

function getWidgetSizeMetrics(context: WidgetEnvironment) {
  switch (context.widgetFamily) {
    case 'systemSmall':
      return {
        headlineSize: 18,
        summarySize: 13,
        metaSize: 11,
        gap: 8,
      };
    case 'systemLarge':
    case 'systemExtraLarge':
      return {
        headlineSize: 22,
        summarySize: 14,
        metaSize: 12,
        gap: 10,
      };
    default:
      return {
        headlineSize: 20,
        summarySize: 13,
        metaSize: 11,
        gap: 9,
      };
  }
}

export function FortuneHomeWidget(
  props: FortuneHomeWidgetProps,
  context: WidgetEnvironment,
) {
  'widget';

  const metrics = getWidgetSizeMetrics(context);
  const margins = context.widgetContentMargins ?? {
    top: 0,
    bottom: 0,
    leading: 0,
    trailing: 0,
  };
  const layoutPadding = {
    top: Math.max(12, margins.top + 4),
    bottom: Math.max(12, margins.bottom + 4),
    leading: Math.max(12, margins.leading + 4),
    trailing: Math.max(12, margins.trailing + 4),
  };

  return (
    <Host
      colorScheme={context.colorScheme ?? 'dark'}
      style={{
        flex: 1,
        backgroundColor: props.surfaceColor,
      }}
    >
      <VStack
        alignment="leading"
        spacing={metrics.gap}
        modifiers={[padding(layoutPadding)]}
      >
        <HStack spacing={8} alignment="center">
          <Text
            modifiers={[
              padding({ horizontal: 10, vertical: 5 }),
              backgroundOverlay({ color: props.accentColor }),
              cornerRadius(999),
              font({ size: 11, weight: 'semibold' }),
              foregroundStyle(props.textColor),
              fixedSize({ horizontal: true, vertical: true }),
            ]}
          >
            {props.badgeLabel || getToneLabel(props.tone)}
          </Text>

          <Text
            modifiers={[
              font({ size: metrics.metaSize, weight: 'medium' }),
              foregroundStyle(props.secondaryTextColor),
              opacity(0.82),
              fixedSize({ horizontal: true, vertical: true }),
            ]}
          >
            {props.updatedAtLabel}
          </Text>
        </HStack>

        <Text
          modifiers={[
            font({ size: metrics.headlineSize, weight: 'bold' }),
            foregroundStyle(props.textColor),
            lineLimit(context.widgetFamily === 'systemSmall' ? 2 : 3),
            fixedSize({ horizontal: false, vertical: true }),
            multilineTextAlignment('leading'),
            frame({ maxWidth: 1000, alignment: 'leading' }),
          ]}
        >
          {props.headline}
        </Text>

        <Text
          modifiers={[
            font({ size: metrics.summarySize, weight: 'regular' }),
            foregroundStyle(props.secondaryTextColor),
            lineLimit(context.widgetFamily === 'systemSmall' ? 2 : 3),
            fixedSize({ horizontal: false, vertical: true }),
            multilineTextAlignment('leading'),
            opacity(0.94),
          ]}
        >
          {props.summary}
        </Text>

        <HStack spacing={6} alignment="center">
          <Text
            modifiers={[
              font({ size: metrics.metaSize, weight: 'semibold' }),
              foregroundStyle(props.textColor),
              backgroundOverlay({ color: props.accentColor }),
              cornerRadius(12),
              padding({ horizontal: 8, vertical: 4 }),
            ]}
          >
            {props.scoreLabel}
          </Text>
        </HStack>
      </VStack>
    </Host>
  );
}

export function getFortuneHomeWidget() {
  if (Platform.OS !== 'ios') {
    return null;
  }

  if (!widgetInstance) {
    try {
      widgetInstance = createWidget(widgetName, FortuneHomeWidget);
    } catch (error) {
      console.warn('[fortune-widget] Failed to create iOS widget instance.', error);
      widgetInstance = null;
    }
  }

  return widgetInstance;
}

export { widgetName as fortuneHomeWidgetName };

export const fortuneHomeWidgetTheme = {
  surfaceColor: fortuneTheme.colors.surface,
  accentColor: fortuneTheme.colors.ctaBackground,
  textColor: fortuneTheme.colors.textPrimary,
  secondaryTextColor: fortuneTheme.colors.textSecondary,
};

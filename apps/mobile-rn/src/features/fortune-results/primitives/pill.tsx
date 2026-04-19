// Pill: port of result-cards.jsx:55-63. Small badge pill, solid or outline.
import { Text, View } from 'react-native';

interface PillProps {
  text: string;
  color: string;
  solid?: boolean;
}

export function Pill({ text, color, solid = false }: PillProps) {
  return (
    <View
      style={{
        height: 24,
        paddingHorizontal: 10,
        borderRadius: 12,
        alignItems: 'center',
        justifyContent: 'center',
        backgroundColor: solid ? color : `${color}24`,
        borderWidth: solid ? 0 : 1,
        borderColor: solid ? 'transparent' : `${color}50`,
      }}
    >
      <Text
        style={{
          fontSize: 11,
          lineHeight: 14,
          fontWeight: '600',
          color: solid ? '#0B0B10' : color,
        }}
      >
        {text}
      </Text>
    </View>
  );
}

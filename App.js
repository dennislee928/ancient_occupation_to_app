import { StatusBar } from "expo-status-bar";
import { SafeAreaView, ScrollView, StyleSheet, Text, TouchableOpacity, View } from "react-native";
import whippingBoy from "./src/features/whipping-boy";
import royalTaster from "./src/features/royal-taster";
import sinEater from "./src/features/sin-eater";
import nomenclator from "./src/features/nomenclator";
import moirologist from "./src/features/moirologist";
import { theme } from "./src/theme";
import { useState } from "react";

const features = [whippingBoy, royalTaster, sinEater, nomenclator, moirologist];

export default function App() {
  const [activeId, setActiveId] = useState(features[0].id);
  const activeFeature = features.find((feature) => feature.id === activeId) ?? features[0];
  const ActiveComponent = activeFeature.Component;

  return (
    <SafeAreaView style={styles.safeArea}>
      <StatusBar style="dark" />
      <ScrollView contentContainerStyle={styles.screen} showsVerticalScrollIndicator={false}>
        <View style={styles.hero}>
          <Text style={styles.eyebrow}>Ancient Occupation to App</Text>
          <Text style={styles.heroTitle}>Five speculative mobile products from five forgotten jobs.</Text>
          <Text style={styles.heroCopy}>
            Each concept transforms a historical social role into a modern iOS/Android interaction pattern:
            accountability, emotional filtering, ritual release, memory prompting, and emergency affirmation.
          </Text>
        </View>

        <ScrollView
          horizontal
          showsHorizontalScrollIndicator={false}
          contentContainerStyle={styles.tabRail}
        >
          {features.map((feature) => {
            const isActive = feature.id === activeId;
            return (
              <TouchableOpacity
                key={feature.id}
                style={[
                  styles.tab,
                  isActive && { backgroundColor: feature.accent, borderColor: feature.accent },
                ]}
                onPress={() => setActiveId(feature.id)}
                activeOpacity={0.88}
              >
                <Text style={[styles.tabLabel, isActive && styles.tabLabelActive]}>{feature.shortLabel}</Text>
              </TouchableOpacity>
            );
          })}
        </ScrollView>

        <View style={styles.panel}>
          <Text style={styles.kicker}>{activeFeature.kicker}</Text>
          <Text style={styles.panelTitle}>{activeFeature.title}</Text>
          <Text style={styles.panelSubtitle}>{activeFeature.tagline}</Text>

          <View style={styles.badgeRow}>
            {activeFeature.meta.map((item) => (
              <View key={item} style={styles.badge}>
                <Text style={styles.badgeText}>{item}</Text>
              </View>
            ))}
          </View>

          <Text style={styles.summary}>{activeFeature.summary}</Text>

          <View style={styles.moduleShell}>
            <ActiveComponent />
          </View>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: theme.colors.canvas,
  },
  screen: {
    paddingHorizontal: 18,
    paddingTop: 18,
    paddingBottom: 48,
    gap: 18,
  },
  hero: {
    padding: 20,
    borderRadius: 28,
    backgroundColor: theme.colors.card,
    borderWidth: 1,
    borderColor: theme.colors.line,
    gap: 12,
    shadowColor: "#51361f",
    shadowOpacity: 0.12,
    shadowRadius: 18,
    shadowOffset: { width: 0, height: 10 },
    elevation: 3,
  },
  eyebrow: {
    color: theme.colors.accent,
    textTransform: "uppercase",
    letterSpacing: 2,
    fontSize: 11,
    fontWeight: "700",
  },
  heroTitle: {
    color: theme.colors.ink,
    fontSize: 34,
    lineHeight: 34,
    fontWeight: "800",
  },
  heroCopy: {
    color: theme.colors.muted,
    fontSize: 15,
    lineHeight: 24,
  },
  tabRail: {
    gap: 10,
    paddingVertical: 2,
    paddingRight: 12,
  },
  tab: {
    paddingHorizontal: 16,
    paddingVertical: 10,
    borderRadius: 999,
    borderWidth: 1,
    borderColor: theme.colors.line,
    backgroundColor: theme.colors.cardSoft,
  },
  tabLabel: {
    color: theme.colors.ink,
    fontWeight: "700",
    fontSize: 13,
  },
  tabLabelActive: {
    color: "#fffaf4",
  },
  panel: {
    padding: 18,
    borderRadius: 28,
    backgroundColor: theme.colors.card,
    borderWidth: 1,
    borderColor: theme.colors.line,
    gap: 14,
  },
  kicker: {
    color: theme.colors.accent,
    textTransform: "uppercase",
    letterSpacing: 2,
    fontWeight: "700",
    fontSize: 11,
  },
  panelTitle: {
    color: theme.colors.ink,
    fontSize: 28,
    lineHeight: 30,
    fontWeight: "800",
  },
  panelSubtitle: {
    color: theme.colors.muted,
    fontSize: 16,
    lineHeight: 24,
  },
  badgeRow: {
    flexDirection: "row",
    flexWrap: "wrap",
    gap: 8,
  },
  badge: {
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 999,
    backgroundColor: theme.colors.cardSoft,
  },
  badgeText: {
    color: theme.colors.ink,
    fontWeight: "600",
    fontSize: 12,
  },
  summary: {
    color: theme.colors.muted,
    fontSize: 15,
    lineHeight: 24,
  },
  moduleShell: {
    marginTop: 4,
    gap: 14,
  },
});

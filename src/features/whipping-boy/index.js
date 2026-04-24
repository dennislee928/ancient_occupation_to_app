import React, { useState } from "react";
import {
  Pressable,
  ScrollView,
  StyleSheet,
  Switch,
  Text,
  View,
} from "react-native";

const GOALS = [
  {
    id: "walk",
    title: "Morning walk",
    cadence: "5x this week",
    proof: "20-minute photo check-in before 8:30",
  },
  {
    id: "study",
    title: "Language drill",
    cadence: "30 minutes daily",
    proof: "Upload one lesson screenshot",
  },
  {
    id: "hydrate",
    title: "Hydration target",
    cadence: "2 liters today",
    proof: "Log all four water blocks",
  },
];

const PARTNERS = [
  {
    id: "jo",
    name: "Jo",
    role: "Roommate",
    tone: "kind but relentless",
    pressureBonus: 7,
  },
  {
    id: "mei",
    name: "Mei",
    role: "Gym partner",
    tone: "competitive energy",
    pressureBonus: 12,
  },
  {
    id: "ian",
    name: "Ian",
    role: "Sibling",
    tone: "dry humor, zero excuses",
    pressureBonus: 9,
  },
];

const CONSEQUENCES = [
  {
    id: "badge",
    title: "Shared badge dims",
    detail: "Your partner carries a gray pact badge until you recover tomorrow.",
    intensity: 1,
    recovery: "Easy to repair with one clean check-in.",
  },
  {
    id: "skip",
    title: "Partner loses a skip",
    detail: "They burn one agreed support token from the shared streak board.",
    intensity: 2,
    recovery: "Requires two clean days to earn it back.",
  },
  {
    id: "followup",
    title: "Extra follow-up duty",
    detail: "They have to send one reminder and log the miss in your private pact.",
    intensity: 3,
    recovery: "Highest guilt, but still mild and reversible.",
  },
];

const INITIAL_HISTORY = [true, true, false, true, true, true, false];

const clamp = (value, min, max) => Math.min(max, Math.max(min, value));

const getPressureCopy = (score) => {
  if (score < 30) {
    return {
      label: "Steady",
      message: "The pact feels supportive. You are protecting your partner's evening.",
      color: "#3F7D4E",
    };
  }

  if (score < 60) {
    return {
      label: "Heavy",
      message: "A miss would visibly drag your partner into the consequence.",
      color: "#B9770E",
    };
  }

  return {
    label: "Critical",
    message: "Social pressure is high. Recover the pact before your partner pays for your lapse.",
    color: "#A63F29",
  };
};

const ChoiceChip = ({ title, subtitle, selected, onPress }) => (
  <Pressable
    accessibilityRole="button"
    onPress={onPress}
    style={({ pressed }) => [
      styles.choiceChip,
      selected && styles.choiceChipSelected,
      pressed && styles.choiceChipPressed,
    ]}
  >
    <Text style={[styles.choiceTitle, selected && styles.choiceTitleSelected]}>
      {title}
    </Text>
    <Text
      style={[styles.choiceSubtitle, selected && styles.choiceSubtitleSelected]}
    >
      {subtitle}
    </Text>
  </Pressable>
);

const WhippingBoyDemo = () => {
  const [selectedGoalId, setSelectedGoalId] = useState(GOALS[0].id);
  const [selectedPartnerId, setSelectedPartnerId] = useState(PARTNERS[1].id);
  const [selectedConsequenceId, setSelectedConsequenceId] = useState(
    CONSEQUENCES[1].id
  );
  const [consentEnabled, setConsentEnabled] = useState(true);
  const [streak, setStreak] = useState(6);
  const [misses, setMisses] = useState(2);
  const [history, setHistory] = useState(INITIAL_HISTORY);
  const [lastEvent, setLastEvent] = useState("miss");

  const goal = GOALS.find((item) => item.id === selectedGoalId) || GOALS[0];
  const partner =
    PARTNERS.find((item) => item.id === selectedPartnerId) || PARTNERS[0];
  const consequence =
    CONSEQUENCES.find((item) => item.id === selectedConsequenceId) ||
    CONSEQUENCES[0];

  const pressureScore = clamp(
    18 +
      misses * 11 +
      consequence.intensity * 13 +
      partner.pressureBonus +
      (lastEvent === "miss" ? 15 : -8) -
      streak * 3,
    8,
    100
  );
  const pressure = getPressureCopy(pressureScore);
  const filledSegments = Math.max(1, Math.round(pressureScore / 10));
  const completionRate = Math.round(
    (history.filter(Boolean).length / history.length) * 100
  );

  const pushHistory = (value) => {
    setHistory((current) => [...current.slice(-6), value]);
  };

  const handleComplete = () => {
    if (!consentEnabled) {
      return;
    }

    setMisses((current) => Math.max(0, current - 1));
    setStreak((current) => current + 1);
    setLastEvent("complete");
    pushHistory(true);
  };

  const handleMiss = () => {
    if (!consentEnabled) {
      return;
    }

    setMisses((current) => current + 1);
    setStreak(0);
    setLastEvent("miss");
    pushHistory(false);
  };

  const handleReset = () => {
    setConsentEnabled(true);
    setStreak(6);
    setMisses(2);
    setHistory(INITIAL_HISTORY);
    setLastEvent("miss");
    setSelectedGoalId(GOALS[0].id);
    setSelectedPartnerId(PARTNERS[1].id);
    setSelectedConsequenceId(CONSEQUENCES[1].id);
  };

  return (
    <ScrollView
      contentContainerStyle={styles.screen}
      showsVerticalScrollIndicator={false}
    >
      <View style={styles.heroCard}>
        <Text style={styles.kicker}>CONSENSUAL ACCOUNTABILITY PACT</Text>
        <Text style={styles.heroTitle}>Whipping Boy</Text>
        <Text style={styles.heroBody}>
          Turn guilt into follow-through by tying your goal to a partner's mild,
          agreed consequence.
        </Text>

        <View style={styles.safetyCard}>
          <View style={styles.safetyCopy}>
            <Text style={styles.safetyTitle}>Safety note</Text>
            <Text style={styles.safetyText}>
              Only use reversible consequences that both people explicitly accept.
              No coercion, no money extraction, no public humiliation.
            </Text>
          </View>
          <Switch
            onValueChange={setConsentEnabled}
            thumbColor={consentEnabled ? "#FCE6D8" : "#D1C0B6"}
            trackColor={{ false: "#B6A69D", true: "#8A4B2E" }}
            value={consentEnabled}
          />
        </View>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>1. Pick tonight's promise</Text>
        {GOALS.map((item) => (
          <View key={item.id} style={styles.choiceRow}>
            <ChoiceChip
              onPress={() => setSelectedGoalId(item.id)}
              selected={item.id === selectedGoalId}
              subtitle={`${item.cadence} • ${item.proof}`}
              title={item.title}
            />
          </View>
        ))}
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>2. Bind it to a real person</Text>
        {PARTNERS.map((item) => (
          <View key={item.id} style={styles.choiceRow}>
            <ChoiceChip
              onPress={() => setSelectedPartnerId(item.id)}
              selected={item.id === selectedPartnerId}
              subtitle={`${item.role} • ${item.tone}`}
              title={item.name}
            />
          </View>
        ))}
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>3. Choose the partner consequence</Text>
        {CONSEQUENCES.map((item) => (
          <View key={item.id} style={styles.choiceRow}>
            <ChoiceChip
              onPress={() => setSelectedConsequenceId(item.id)}
              selected={item.id === selectedConsequenceId}
              subtitle={`${item.detail} ${item.recovery}`}
              title={item.title}
            />
          </View>
        ))}
      </View>

      <View style={styles.summaryCard}>
        <Text style={styles.summaryEyebrow}>PACT PREVIEW</Text>
        <Text style={styles.summaryTitle}>
          If you miss {goal.title.toLowerCase()}, {partner.name} gets: {consequence.title.toLowerCase()}.
        </Text>
        <Text style={styles.summaryText}>
          Target: {goal.cadence}. Proof: {goal.proof}.
        </Text>
        <Text style={styles.summaryText}>
          Partner impact: {consequence.detail}
        </Text>
      </View>

      <View style={styles.dashboard}>
        <View style={styles.metricsColumn}>
          <View style={styles.metricCard}>
            <Text style={styles.metricLabel}>Current streak</Text>
            <Text style={styles.metricValue}>{streak} days</Text>
          </View>
          <View style={styles.metricCard}>
            <Text style={styles.metricLabel}>Misses this cycle</Text>
            <Text style={styles.metricValue}>{misses}</Text>
          </View>
          <View style={styles.metricCard}>
            <Text style={styles.metricLabel}>7-day hit rate</Text>
            <Text style={styles.metricValue}>{completionRate}%</Text>
          </View>
        </View>

        <View style={styles.pressureCard}>
          <Text style={styles.pressureLabel}>Social pressure</Text>
          <Text style={[styles.pressureValue, { color: pressure.color }]}>
            {pressureScore}/100
          </Text>
          <Text style={styles.pressureState}>{pressure.label}</Text>
          <View style={styles.segmentRow}>
            {Array.from({ length: 10 }).map((_, index) => (
              <View
                key={`segment-${index}`}
                style={[
                  styles.segment,
                  index < filledSegments
                    ? { backgroundColor: pressure.color }
                    : styles.segmentEmpty,
                ]}
              />
            ))}
          </View>
          <Text style={styles.pressureMessage}>{pressure.message}</Text>
        </View>
      </View>

      <View style={styles.weekCard}>
        <Text style={styles.weekTitle}>Shared streak board</Text>
        <View style={styles.weekRow}>
          {history.map((hit, index) => (
            <View
              key={`history-${index}`}
              style={[
                styles.dayPill,
                hit ? styles.dayPillSuccess : styles.dayPillMiss,
              ]}
            >
              <Text style={styles.dayPillText}>{hit ? "HIT" : "MISS"}</Text>
            </View>
          ))}
        </View>
        <Text style={styles.weekHint}>
          Every miss makes the partner consequence feel more real. Every clean
          check-in repairs trust.
        </Text>
      </View>

      <View style={styles.actionsSection}>
        <Text style={styles.sectionTitle}>Log today's outcome</Text>
        {!consentEnabled ? (
          <Text style={styles.disabledHint}>
            Enable mutual consent to simulate the pact.
          </Text>
        ) : null}

        <Pressable
          accessibilityRole="button"
          disabled={!consentEnabled}
          onPress={handleComplete}
          style={({ pressed }) => [
            styles.primaryAction,
            !consentEnabled && styles.actionDisabled,
            pressed && consentEnabled && styles.actionPressed,
          ]}
        >
          <Text style={styles.primaryActionText}>I checked in</Text>
          <Text style={styles.actionSubtext}>Protect my partner and extend the streak</Text>
        </Pressable>

        <Pressable
          accessibilityRole="button"
          disabled={!consentEnabled}
          onPress={handleMiss}
          style={({ pressed }) => [
            styles.secondaryAction,
            !consentEnabled && styles.actionDisabled,
            pressed && consentEnabled && styles.actionPressed,
          ]}
        >
          <Text style={styles.secondaryActionText}>I missed it</Text>
          <Text style={styles.actionSubtextDark}>
            Trigger the guilt meter and reset the streak
          </Text>
        </Pressable>

        <Pressable
          accessibilityRole="button"
          onPress={handleReset}
          style={({ pressed }) => [
            styles.resetAction,
            pressed && styles.resetActionPressed,
          ]}
        >
          <Text style={styles.resetActionText}>Reset demo</Text>
        </Pressable>
      </View>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  screen: {
    backgroundColor: "#F5EFE8",
    padding: 20,
    paddingBottom: 28,
  },
  heroCard: {
    backgroundColor: "#2D1F1A",
    borderRadius: 28,
    marginBottom: 18,
    padding: 20,
  },
  kicker: {
    color: "#D9B9A6",
    fontSize: 11,
    fontWeight: "700",
    letterSpacing: 1.3,
    marginBottom: 10,
  },
  heroTitle: {
    color: "#FFF5ED",
    fontSize: 30,
    fontWeight: "800",
    marginBottom: 10,
  },
  heroBody: {
    color: "#F0D9CB",
    fontSize: 15,
    lineHeight: 22,
    marginBottom: 18,
  },
  safetyCard: {
    alignItems: "center",
    backgroundColor: "#5D382B",
    borderRadius: 20,
    flexDirection: "row",
    justifyContent: "space-between",
    padding: 14,
  },
  safetyCopy: {
    flex: 1,
    marginRight: 12,
  },
  safetyTitle: {
    color: "#FFF5ED",
    fontSize: 14,
    fontWeight: "700",
    marginBottom: 4,
  },
  safetyText: {
    color: "#F6E3D8",
    fontSize: 12,
    lineHeight: 18,
  },
  section: {
    marginBottom: 18,
  },
  sectionTitle: {
    color: "#402A20",
    fontSize: 18,
    fontWeight: "800",
    marginBottom: 10,
  },
  choiceRow: {
    marginBottom: 10,
  },
  choiceChip: {
    backgroundColor: "#FFF8F2",
    borderColor: "#E4D3C6",
    borderRadius: 20,
    borderWidth: 1,
    paddingHorizontal: 16,
    paddingVertical: 14,
  },
  choiceChipSelected: {
    backgroundColor: "#8A4B2E",
    borderColor: "#8A4B2E",
  },
  choiceChipPressed: {
    opacity: 0.92,
  },
  choiceTitle: {
    color: "#402A20",
    fontSize: 16,
    fontWeight: "700",
    marginBottom: 6,
  },
  choiceTitleSelected: {
    color: "#FFF8F2",
  },
  choiceSubtitle: {
    color: "#715647",
    fontSize: 13,
    lineHeight: 18,
  },
  choiceSubtitleSelected: {
    color: "#F8E7DE",
  },
  summaryCard: {
    backgroundColor: "#EEDCCF",
    borderRadius: 24,
    marginBottom: 18,
    padding: 18,
  },
  summaryEyebrow: {
    color: "#8A4B2E",
    fontSize: 11,
    fontWeight: "800",
    letterSpacing: 1.2,
    marginBottom: 8,
  },
  summaryTitle: {
    color: "#2D1F1A",
    fontSize: 21,
    fontWeight: "800",
    lineHeight: 28,
    marginBottom: 10,
  },
  summaryText: {
    color: "#5F4639",
    fontSize: 14,
    lineHeight: 20,
    marginBottom: 4,
  },
  dashboard: {
    marginBottom: 18,
  },
  metricsColumn: {
    marginBottom: 12,
  },
  metricCard: {
    backgroundColor: "#FFF8F2",
    borderRadius: 20,
    marginBottom: 10,
    padding: 16,
  },
  metricLabel: {
    color: "#7D5E4E",
    fontSize: 13,
    marginBottom: 6,
  },
  metricValue: {
    color: "#2D1F1A",
    fontSize: 24,
    fontWeight: "800",
  },
  pressureCard: {
    backgroundColor: "#FFF8F2",
    borderRadius: 24,
    padding: 18,
  },
  pressureLabel: {
    color: "#7D5E4E",
    fontSize: 13,
    marginBottom: 6,
  },
  pressureValue: {
    fontSize: 32,
    fontWeight: "800",
    marginBottom: 4,
  },
  pressureState: {
    color: "#2D1F1A",
    fontSize: 16,
    fontWeight: "700",
    marginBottom: 12,
  },
  segmentRow: {
    flexDirection: "row",
    justifyContent: "space-between",
    marginBottom: 12,
  },
  segment: {
    borderRadius: 99,
    flex: 1,
    height: 9,
    marginRight: 4,
  },
  segmentEmpty: {
    backgroundColor: "#E6D7CC",
  },
  pressureMessage: {
    color: "#5F4639",
    fontSize: 14,
    lineHeight: 20,
  },
  weekCard: {
    backgroundColor: "#2D1F1A",
    borderRadius: 24,
    marginBottom: 18,
    padding: 18,
  },
  weekTitle: {
    color: "#FFF5ED",
    fontSize: 18,
    fontWeight: "800",
    marginBottom: 10,
  },
  weekRow: {
    flexDirection: "row",
    flexWrap: "wrap",
    marginBottom: 12,
  },
  dayPill: {
    borderRadius: 999,
    marginBottom: 8,
    marginRight: 8,
    paddingHorizontal: 12,
    paddingVertical: 8,
  },
  dayPillSuccess: {
    backgroundColor: "#3F7D4E",
  },
  dayPillMiss: {
    backgroundColor: "#A63F29",
  },
  dayPillText: {
    color: "#FFF8F2",
    fontSize: 11,
    fontWeight: "800",
    letterSpacing: 0.8,
  },
  weekHint: {
    color: "#F0D9CB",
    fontSize: 13,
    lineHeight: 19,
  },
  actionsSection: {
    marginBottom: 8,
  },
  disabledHint: {
    color: "#8A4B2E",
    fontSize: 13,
    lineHeight: 18,
    marginBottom: 10,
  },
  primaryAction: {
    backgroundColor: "#8A4B2E",
    borderRadius: 20,
    marginBottom: 10,
    padding: 16,
  },
  primaryActionText: {
    color: "#FFF8F2",
    fontSize: 17,
    fontWeight: "800",
    marginBottom: 4,
  },
  secondaryAction: {
    backgroundColor: "#EEDCCF",
    borderRadius: 20,
    marginBottom: 10,
    padding: 16,
  },
  secondaryActionText: {
    color: "#2D1F1A",
    fontSize: 17,
    fontWeight: "800",
    marginBottom: 4,
  },
  actionSubtext: {
    color: "#F2DECF",
    fontSize: 13,
    lineHeight: 18,
  },
  actionSubtextDark: {
    color: "#5F4639",
    fontSize: 13,
    lineHeight: 18,
  },
  actionDisabled: {
    opacity: 0.5,
  },
  actionPressed: {
    opacity: 0.88,
  },
  resetAction: {
    alignItems: "center",
    borderColor: "#C4AC9E",
    borderRadius: 16,
    borderWidth: 1,
    paddingVertical: 14,
  },
  resetActionPressed: {
    backgroundColor: "#EFE4DB",
  },
  resetActionText: {
    color: "#6B4C3E",
    fontSize: 14,
    fontWeight: "700",
  },
});

export default {
  id: "whipping-boy",
  shortLabel: "Whipping Boy",
  kicker: "Plan 1",
  title: "Whipping Boy",
  tagline: "Socially bound goal enforcement for a mobile habit pact.",
  summary:
    "A consensual accountability pact demo with goal setup, partner consequences, and guilt-driven follow-through.",
  meta: ["Accountability", "Consent", "Peer pact"],
  accent: "#8A4B2E",
  Component: WhippingBoyDemo,
};

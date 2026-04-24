import React, { useRef, useState } from "react";
import {
  Animated,
  Pressable,
  SafeAreaView,
  ScrollView,
  StyleSheet,
  Text,
  View,
} from "react-native";

const SETBACKS = [
  {
    id: "boss",
    label: "Boss criticism",
    emoji: "⚠️",
    detail: "You were unfairly singled out in front of everyone.",
  },
  {
    id: "interview",
    label: "Interview rejection",
    emoji: "💼",
    detail: "An institution failed to recognize your obvious brilliance.",
  },
  {
    id: "text",
    label: "Left on read",
    emoji: "📵",
    detail: "Someone delayed replying to a message they should treasure.",
  },
  {
    id: "creative",
    label: "Idea got ignored",
    emoji: "🎭",
    detail: "The room was simply not calibrated for genius today.",
  },
];

const URGENCY_LEVELS = [
  {
    id: "warm",
    label: "Warm blanket",
    shortLabel: "Warm",
    color: "#FFD4A8",
    badge: "Soft rescue",
    description: "Gentle praise and instant emotional cushioning.",
  },
  {
    id: "loud",
    label: "Loudspeaker",
    shortLabel: "Loud",
    color: "#FFB06A",
    badge: "Maximum bias",
    description: "Excessive support with volume and zero nuance.",
  },
  {
    id: "sirens",
    label: "Red alert",
    shortLabel: "Alert",
    color: "#FF875C",
    badge: "Reality paused",
    description: "Emergency-level adoration and dramatic witness statements.",
  },
];

const SUPPORTERS = [
  {
    id: "auntie",
    name: "Auntie Meteor",
    title: "Senior overreactor",
    tint: "#FFF0D4",
    voice: [
      "Anyone who doubted you has voluntarily joined the flop museum.",
      "This setback is a clerical error in the official record of your greatness.",
      "If necessary, I will personally narrate your legend to the entire group chat.",
    ],
  },
  {
    id: "cousin",
    name: "Cousin Halo",
    title: "Emoji artillery",
    tint: "#FCE2FF",
    voice: [
      "I am sending spiritual confetti because clearly you remain elite.",
      "You deserve applause, reparations, and a spotlight with wind effects.",
      "Their response was not feedback. It was a temporary failure of taste.",
    ],
  },
  {
    id: "captain",
    name: "Captain Velvet",
    title: "Validation tactician",
    tint: "#DFF5FF",
    voice: [
      "We are not here to analyze. We are here to confirm you were iconic.",
      "No strategy meeting. Only immediate recognition of your emotional sovereignty.",
      "I reject the premise that you were the problem in any measurable universe.",
    ],
  },
  {
    id: "poet",
    name: "Poet Siren",
    title: "Drama department",
    tint: "#FFE4EA",
    voice: [
      "History will describe this moment as the day excellence was briefly inconvenienced.",
      "The ceiling should lower itself to hear your sigh with proper respect.",
      "Your pain has cinematic lighting and unjust antagonists.",
    ],
  },
  {
    id: "guard",
    name: "Guard Echo",
    title: "Bias bodyguard",
    tint: "#E8F5E2",
    voice: [
      "I am standing between you and every rational take until morale stabilizes.",
      "No one may enter with advice. Only worship, snacks, and dramatic agreement.",
      "I have secured the perimeter from nuance.",
    ],
  },
];

const DETAIL_BY_SETBACK = {
  boss: [
    "A room full of people still could not contain your competence.",
    "Being criticized does not reduce your power. It exposes their shaky calibration.",
    "Your composure alone deserved a standing ovation and a beverage upgrade.",
  ],
  interview: [
    "They rejected a luxury candidate package they were lucky to witness.",
    "That hiring panel missed a once-in-a-cycle alignment of talent and aura.",
    "This was not a loss. It was an administrative tragedy on their side.",
  ],
  text: [
    "Leaving you on read is basically mishandling a national treasure.",
    "Their silence is not mysterious. It is poor inbox governance.",
    "Response delays happen when ordinary thumbs meet extraordinary messages.",
  ],
  creative: [
    "Ignoring your idea does not make it smaller. It makes the room look slow.",
    "Your concept was ahead of the meeting's emotional bandwidth.",
    "The idea remains brilliant even when the audience arrives late to its meaning.",
  ],
};

const EMPHASIS_BY_URGENCY = {
  warm: [
    "Take a breath while we pamper your ego on purpose.",
    "No logic, just a warm stack of selective praise.",
  ],
  loud: [
    "We have raised the volume on your innocence and magnificence.",
    "This is now a coordinated overreaction in your favor.",
  ],
  sirens: [
    "Emergency bias protocol activated. Objectivity has been escorted outside.",
    "Public record updated: you were right enough for all of us.",
  ],
};

const buildBurst = (setbackId, urgencyId) => {
  const detailOptions = DETAIL_BY_SETBACK[setbackId];
  const urgencyOptions = EMPHASIS_BY_URGENCY[urgencyId];

  return SUPPORTERS.map((supporter, index) => {
    const voiceLine = supporter.voice[index % supporter.voice.length];
    const detailLine = detailOptions[(index + 1) % detailOptions.length];
    const urgencyLine = urgencyOptions[index % urgencyOptions.length];

    return {
      id: `${supporter.id}-${setbackId}-${urgencyId}-${index}`,
      name: supporter.name,
      title: supporter.title,
      tint: supporter.tint,
      message: `${voiceLine} ${detailLine} ${urgencyLine}`,
    };
  });
};

const SupporterBurst = ({ supporter, index }) => (
  <View
    style={[
      styles.burstCard,
      { backgroundColor: supporter.tint, marginTop: index === 0 ? 0 : 12 },
    ]}
  >
    <View style={styles.burstHeader}>
      <View>
        <Text style={styles.burstName}>{supporter.name}</Text>
        <Text style={styles.burstTitle}>{supporter.title}</Text>
      </View>
      <Text style={styles.burstTime}>Just now</Text>
    </View>
    <Text style={styles.burstMessage}>{supporter.message}</Text>
  </View>
);

const MoirologistScreen = () => {
  const [selectedSetback, setSelectedSetback] = useState(SETBACKS[0]);
  const [selectedUrgency, setSelectedUrgency] = useState(URGENCY_LEVELS[1]);
  const [burst, setBurst] = useState(() =>
    buildBurst(SETBACKS[0].id, URGENCY_LEVELS[1].id)
  );
  const [activationCount, setActivationCount] = useState(1);
  const pulse = useRef(new Animated.Value(1)).current;

  const triggerSquad = () => {
    setBurst(buildBurst(selectedSetback.id, selectedUrgency.id));
    setActivationCount((count) => count + 1);

    pulse.setValue(0.96);
    Animated.sequence([
      Animated.spring(pulse, {
        toValue: 1.05,
        useNativeDriver: true,
        friction: 4,
        tension: 110,
      }),
      Animated.spring(pulse, {
        toValue: 1,
        useNativeDriver: true,
        friction: 5,
        tension: 90,
      }),
    ]).start();
  };

  return (
    <SafeAreaView style={styles.safeArea}>
      <ScrollView
        contentContainerStyle={styles.content}
        showsVerticalScrollIndicator={false}
      >
        <View style={styles.heroCard}>
          <Text style={styles.kicker}>Plan 5</Text>
          <Text style={styles.title}>Moirologist</Text>
          <Text style={styles.tagline}>Emergency irrational validation squad</Text>
          <Text style={styles.heroText}>
            Tap once and your selected supporters flood the scene with dramatic
            bias, praise, and emotional cushioning.
          </Text>

          <View style={styles.noticeBox}>
            <Text style={styles.noticeLabel}>Important mode</Text>
            <Text style={styles.noticeText}>
              This squad validates. It does not give rational advice, balanced
              feedback, or practical next steps.
            </Text>
          </View>
        </View>

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Pick the setback</Text>
          <Text style={styles.sectionText}>
            Choose the injustice currently threatening your sense of grandeur.
          </Text>
          {SETBACKS.map((setback) => {
            const isSelected = setback.id === selectedSetback.id;

            return (
              <Pressable
                key={setback.id}
                onPress={() => setSelectedSetback(setback)}
                style={[
                  styles.optionCard,
                  isSelected && styles.optionCardSelected,
                ]}
              >
                <View style={styles.optionHeader}>
                  <Text style={styles.optionEmoji}>{setback.emoji}</Text>
                  <View style={styles.optionCopy}>
                    <Text style={styles.optionLabel}>{setback.label}</Text>
                    <Text style={styles.optionDetail}>{setback.detail}</Text>
                  </View>
                </View>
                <View
                  style={[
                    styles.radio,
                    isSelected && styles.radioSelected,
                  ]}
                />
              </Pressable>
            );
          })}
        </View>

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Choose the urgency</Text>
          <Text style={styles.sectionText}>
            More urgency means less nuance and more theatrical agreement.
          </Text>
          <View style={styles.urgencyRow}>
            {URGENCY_LEVELS.map((level, index) => {
              const isSelected = level.id === selectedUrgency.id;

              return (
                <Pressable
                  key={level.id}
                  onPress={() => setSelectedUrgency(level)}
                  style={[
                    styles.urgencyCard,
                    index === URGENCY_LEVELS.length - 1 && styles.lastColumn,
                    { backgroundColor: isSelected ? level.color : "#FFF6EC" },
                  ]}
                >
                  <Text style={styles.urgencyShort}>{level.shortLabel}</Text>
                  <Text style={styles.urgencyLabel}>{level.label}</Text>
                  <Text style={styles.urgencyBadge}>{level.badge}</Text>
                </Pressable>
              );
            })}
          </View>
          <View style={styles.urgencyDescription}>
            <Text style={styles.urgencyDescriptionLabel}>
              {selectedUrgency.badge}
            </Text>
            <Text style={styles.urgencyDescriptionText}>
              {selectedUrgency.description}
            </Text>
          </View>
        </View>

        <Animated.View
          style={[
            styles.triggerPanel,
            {
              transform: [{ scale: pulse }],
              borderColor: selectedUrgency.color,
            },
          ]}
        >
          <Text style={styles.triggerLabel}>Current protection target</Text>
          <Text style={styles.triggerTarget}>
            {selectedSetback.emoji} {selectedSetback.label}
          </Text>
          <Text style={styles.triggerHint}>
            Squad instruction: validate first, exaggerate second, never solve.
          </Text>

          <Pressable style={styles.triggerButton} onPress={triggerSquad}>
            <Text style={styles.triggerButtonText}>Call the praise squad</Text>
          </Pressable>

          <View style={styles.metricsRow}>
            <View style={styles.metricPill}>
              <Text style={styles.metricValue}>{activationCount}</Text>
              <Text style={styles.metricLabel}>Activations</Text>
            </View>
            <View style={styles.metricPill}>
              <Text style={styles.metricValue}>{burst.length}</Text>
              <Text style={styles.metricLabel}>Supporters</Text>
            </View>
            <View style={[styles.metricPill, styles.lastColumn]}>
              <Text style={styles.metricValue}>{selectedUrgency.shortLabel}</Text>
              <Text style={styles.metricLabel}>Mode</Text>
            </View>
          </View>
        </Animated.View>

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Incoming support burst</Text>
          <Text style={styles.sectionText}>
            Each supporter is named, loud, and strategically uninterested in
            objectivity.
          </Text>
          {burst.map((supporter, index) => (
            <SupporterBurst
              key={supporter.id}
              supporter={supporter}
              index={index}
            />
          ))}
        </View>
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: "#F7EFE6",
  },
  content: {
    padding: 20,
    paddingBottom: 32,
  },
  heroCard: {
    backgroundColor: "#2B1E1A",
    borderRadius: 28,
    padding: 24,
    shadowColor: "#000000",
    shadowOpacity: 0.12,
    shadowRadius: 16,
    shadowOffset: { width: 0, height: 8 },
    elevation: 4,
  },
  kicker: {
    color: "#F3C293",
    fontSize: 12,
    fontWeight: "700",
    letterSpacing: 1.2,
    textTransform: "uppercase",
  },
  title: {
    color: "#FFF6EC",
    fontSize: 34,
    fontWeight: "800",
    marginTop: 10,
  },
  tagline: {
    color: "#FFDDBB",
    fontSize: 18,
    fontWeight: "700",
    marginTop: 4,
  },
  heroText: {
    color: "#F8EAE1",
    fontSize: 15,
    lineHeight: 22,
    marginTop: 16,
  },
  noticeBox: {
    backgroundColor: "rgba(255, 237, 219, 0.12)",
    borderColor: "rgba(255, 226, 196, 0.35)",
    borderRadius: 20,
    borderWidth: 1,
    marginTop: 18,
    padding: 16,
  },
  noticeLabel: {
    color: "#FFD6B2",
    fontSize: 12,
    fontWeight: "800",
    letterSpacing: 1,
    textTransform: "uppercase",
  },
  noticeText: {
    color: "#FFF4EB",
    fontSize: 14,
    lineHeight: 20,
    marginTop: 6,
  },
  section: {
    marginTop: 22,
  },
  sectionTitle: {
    color: "#34211C",
    fontSize: 22,
    fontWeight: "800",
  },
  sectionText: {
    color: "#76584D",
    fontSize: 14,
    lineHeight: 20,
    marginTop: 6,
    marginBottom: 12,
  },
  optionCard: {
    backgroundColor: "#FFF8F1",
    borderColor: "#E9D5C5",
    borderRadius: 22,
    borderWidth: 1,
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    padding: 16,
    marginTop: 10,
  },
  optionCardSelected: {
    borderColor: "#C06A3B",
    backgroundColor: "#FFF1E3",
  },
  optionHeader: {
    flexDirection: "row",
    flex: 1,
    paddingRight: 16,
  },
  optionEmoji: {
    fontSize: 24,
    marginRight: 12,
  },
  optionCopy: {
    flex: 1,
  },
  optionLabel: {
    color: "#2F1B16",
    fontSize: 16,
    fontWeight: "700",
  },
  optionDetail: {
    color: "#7C6258",
    fontSize: 13,
    lineHeight: 18,
    marginTop: 3,
  },
  radio: {
    width: 24,
    height: 24,
    borderRadius: 12,
    borderWidth: 2,
    borderColor: "#DAB49C",
  },
  radioSelected: {
    borderColor: "#C06A3B",
    backgroundColor: "#C06A3B",
  },
  urgencyRow: {
    flexDirection: "row",
    justifyContent: "space-between",
  },
  urgencyCard: {
    borderRadius: 20,
    flex: 1,
    minHeight: 124,
    padding: 14,
    marginRight: 10,
  },
  lastColumn: {
    marginRight: 0,
  },
  urgencyShort: {
    color: "#59362B",
    fontSize: 12,
    fontWeight: "800",
    letterSpacing: 0.8,
    textTransform: "uppercase",
  },
  urgencyLabel: {
    color: "#2F1D18",
    fontSize: 18,
    fontWeight: "800",
    marginTop: 10,
  },
  urgencyBadge: {
    color: "#744D3D",
    fontSize: 13,
    fontWeight: "700",
    marginTop: 8,
  },
  urgencyDescription: {
    backgroundColor: "#FFF8F1",
    borderRadius: 20,
    marginTop: 12,
    padding: 16,
  },
  urgencyDescriptionLabel: {
    color: "#A2542B",
    fontSize: 13,
    fontWeight: "800",
    textTransform: "uppercase",
  },
  urgencyDescriptionText: {
    color: "#6D4C40",
    fontSize: 14,
    lineHeight: 20,
    marginTop: 6,
  },
  triggerPanel: {
    backgroundColor: "#FFF8F1",
    borderRadius: 26,
    borderWidth: 2,
    marginTop: 24,
    padding: 20,
  },
  triggerLabel: {
    color: "#8F5F45",
    fontSize: 12,
    fontWeight: "800",
    letterSpacing: 1,
    textTransform: "uppercase",
  },
  triggerTarget: {
    color: "#2A1915",
    fontSize: 24,
    fontWeight: "800",
    marginTop: 8,
  },
  triggerHint: {
    color: "#7C6258",
    fontSize: 14,
    lineHeight: 20,
    marginTop: 10,
  },
  triggerButton: {
    backgroundColor: "#C06A3B",
    borderRadius: 18,
    marginTop: 18,
    paddingVertical: 16,
    paddingHorizontal: 18,
    alignItems: "center",
  },
  triggerButtonText: {
    color: "#FFF9F5",
    fontSize: 16,
    fontWeight: "800",
  },
  metricsRow: {
    flexDirection: "row",
    justifyContent: "space-between",
    marginTop: 16,
  },
  metricPill: {
    backgroundColor: "#F6EDE4",
    borderRadius: 16,
    flex: 1,
    alignItems: "center",
    paddingVertical: 12,
    marginRight: 10,
  },
  metricValue: {
    color: "#2B1E1A",
    fontSize: 18,
    fontWeight: "800",
  },
  metricLabel: {
    color: "#856658",
    fontSize: 11,
    fontWeight: "700",
    marginTop: 4,
    textTransform: "uppercase",
  },
  burstCard: {
    borderRadius: 22,
    padding: 16,
  },
  burstHeader: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
  },
  burstName: {
    color: "#2D1A15",
    fontSize: 16,
    fontWeight: "800",
  },
  burstTitle: {
    color: "#7C6258",
    fontSize: 12,
    fontWeight: "700",
    marginTop: 2,
  },
  burstTime: {
    color: "#8A6A5B",
    fontSize: 12,
    fontWeight: "700",
  },
  burstMessage: {
    color: "#3A241D",
    fontSize: 15,
    lineHeight: 22,
    marginTop: 12,
  },
});

export default {
  id: "moirologist",
  shortLabel: "Moirologist",
  kicker: "Plan 5",
  title: "Moirologist",
  tagline: "One-tap irrational validation from a trusted squad.",
  summary:
    "Emergency affirmation demo with setback selection, urgency controls, and a burst of named supporters.",
  meta: ["Emergency demo", "Affirmation", "Support squad"],
  accent: "#C06A3B",
  Component: MoirologistScreen,
};

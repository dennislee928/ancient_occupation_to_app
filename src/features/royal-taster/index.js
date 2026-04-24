import React, { useMemo, useState } from "react";
import {
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  TextInput,
  View,
} from "react-native";

const SAMPLE_MESSAGES = [
  {
    id: "manager",
    label: "Manager",
    message:
      "Why are you ignoring this? I need the revised deck, budget numbers, and client reply before 9 AM tomorrow. This delay makes us look incompetent, and if you miss it again I will escalate it to leadership immediately.",
  },
  {
    id: "ex",
    label: "Ex",
    message:
      "You still have my cat carrier and I need it back tonight. Stop being impossible. If you keep dodging me I will tell everyone how selfish you've been. Reply in the next hour and confirm where I can pick it up.",
  },
  {
    id: "family",
    label: "Family",
    message:
      "Call me back right now. The clinic needs your insurance photo and confirmation for Friday's appointment. I am already stressed enough, so please do not make this harder than it has to be.",
  },
];

const STAGES = [
  {
    key: "intercepted",
    title: "Intercepted",
    caption: "Raw message quarantined before it hits the recipient.",
  },
  {
    key: "reviewed",
    title: "Reviewed",
    caption: "Royal taster removes emotional residue and flags intent.",
  },
  {
    key: "delivered",
    title: "Delivered",
    caption: "Only the calm brief and next steps reach the recipient.",
  },
];

const PHRASE_BANK = {
  urgent: [
    "right now",
    "asap",
    "immediately",
    "urgent",
    "before",
    "tonight",
    "next hour",
    "by 9 am",
  ],
  pressure: [
    "need",
    "must",
    "have to",
    "don't make this harder",
    "stop being",
    "why are you ignoring",
    "reply",
    "confirm",
  ],
  toxic: [
    "selfish",
    "impossible",
    "incompetent",
    "dodging",
    "ignore",
    "ignoring",
    "blame",
    "disappointing",
  ],
  threat: [
    "i will escalate",
    "i will tell everyone",
    "or else",
    "if you miss it again",
    "if you keep",
  ],
};

const ACTION_PATTERNS = [
  { pattern: /\b(call|phone)\b/i, label: "Return the call" },
  { pattern: /\breply\b/i, label: "Send a reply" },
  { pattern: /\bconfirm\b/i, label: "Confirm the requested detail" },
  { pattern: /\bsend\b/i, label: "Send the requested material" },
  { pattern: /\bshare\b/i, label: "Share the requested information" },
  { pattern: /\breturn\b/i, label: "Return the requested item" },
  { pattern: /\bbring\b/i, label: "Bring the requested item" },
  { pattern: /\brevised\b|\bdeck\b|\bbudget\b/i, label: "Prepare the revised deck and budget numbers" },
  { pattern: /\bclient reply\b|\bclient\b/i, label: "Respond to the client" },
  { pattern: /\binsurance\b/i, label: "Send the insurance photo" },
  { pattern: /\bappointment\b|\bfriday\b/i, label: "Confirm the appointment timing" },
  { pattern: /\bcat carrier\b/i, label: "Arrange the cat carrier handoff" },
];

const DEFAULT_MESSAGE = SAMPLE_MESSAGES[0].message;

const clamp = (value, min, max) => Math.min(Math.max(value, min), max);

const sentenceCase = (text) =>
  text.charAt(0).toUpperCase() + text.slice(1).toLowerCase();

const extractDeadline = (message) => {
  const match = message.match(
    /\b(before\s+\d{1,2}(?::\d{2})?\s?(?:am|pm)|tonight|tomorrow|today|next hour|friday(?:'s)? appointment)\b/i
  );

  return match ? sentenceCase(match[1]) : null;
};

const normalizeMessage = (message) =>
  message
    .replace(/\s+/g, " ")
    .replace(/[!?]{2,}/g, "!")
    .trim();

const collectSignalHits = (message) => {
  const lower = message.toLowerCase();
  const entries = [];

  Object.entries(PHRASE_BANK).forEach(([category, phrases]) => {
    phrases.forEach((phrase) => {
      if (lower.includes(phrase)) {
        entries.push({
          category,
          phrase,
        });
      }
    });
  });

  return entries;
};

const extractActionItems = (message) => {
  const found = [];
  const deadline = extractDeadline(message);

  ACTION_PATTERNS.forEach(({ pattern, label }) => {
    if (pattern.test(message) && !found.includes(label)) {
      found.push(label);
    }
  });

  if (deadline) {
    found.push(`Timing noted: ${deadline}`);
  }

  if (!found.length) {
    found.push("No concrete action request detected. Treat as emotional venting.");
  }

  return found.slice(0, 4);
};

const buildSafeBrief = ({ actionItems, label, threats, deadline }) => {
  const lead =
    actionItems[0] === "No concrete action request detected. Treat as emotional venting."
      ? "The sender is upset, but there is no specific task hidden inside the message."
      : `The sender wants ${actionItems
          .filter((item) => !item.startsWith("Timing noted:"))
          .slice(0, 2)
          .join(" and ")
          .toLowerCase()}.`;

  const timing = deadline ? `Preferred timing: ${deadline}.` : "No hard deadline detected.";
  const safetyNote = threats
    ? "Pressure tactics were filtered out before delivery."
    : "No explicit threat language was detected.";

  return `${lead} ${timing} ${safetyNote} Overall tone: ${label.toLowerCase()}.`;
};

const analyzeMessage = (rawMessage) => {
  const message = normalizeMessage(rawMessage);

  if (!message) {
    return {
      message: "",
      score: 0,
      label: "Idle",
      deadline: null,
      actionItems: ["Paste a message to let the royal taster inspect it."],
      safeBrief: "No message has been intercepted yet.",
      toxicHighlights: [],
      metrics: [
        { label: "Emotional heat", value: 0 },
        { label: "Urgency", value: 0 },
        { label: "Manipulation", value: 0 },
      ],
    };
  }

  const signalHits = collectSignalHits(message);
  const actionItems = extractActionItems(message);
  const deadline = extractDeadline(message);
  const allCapsWords = (message.match(/\b[A-Z]{3,}\b/g) || []).length;
  const exclamations = (message.match(/!/g) || []).length;
  const questions = (message.match(/\?/g) || []).length;
  const threatCount = signalHits.filter((item) => item.category === "threat").length;
  const toxicCount = signalHits.filter((item) => item.category === "toxic").length;
  const pressureCount = signalHits.filter(
    (item) => item.category === "pressure" || item.category === "urgent"
  ).length;

  const score = clamp(
    pressureCount * 12 +
      toxicCount * 14 +
      threatCount * 20 +
      allCapsWords * 4 +
      exclamations * 3 +
      questions * 2,
    8,
    98
  );

  let label = "Composed";
  if (score >= 70) {
    label = "Corrosive";
  } else if (score >= 48) {
    label = "High Pressure";
  } else if (score >= 28) {
    label = "Guarded";
  }

  const manipulation = clamp(threatCount * 32 + toxicCount * 14, 6, 94);
  const urgency = clamp(pressureCount * 18 + exclamations * 6, 8, 96);
  const emotionalHeat = clamp(toxicCount * 24 + allCapsWords * 6 + questions * 4, 10, 97);

  const safeBrief = buildSafeBrief({
    actionItems,
    deadline,
    label,
    threats: threatCount > 0,
  });

  const toxicHighlights = signalHits
    .map((item) => item.phrase)
    .filter((phrase, index, array) => array.indexOf(phrase) === index)
    .slice(0, 5);

  return {
    message,
    score,
    label,
    deadline,
    actionItems,
    safeBrief,
    toxicHighlights,
    metrics: [
      { label: "Emotional heat", value: emotionalHeat },
      { label: "Urgency", value: urgency },
      { label: "Manipulation", value: manipulation },
    ],
  };
};

const MetricBar = ({ label, value, accent }) => (
  <View style={styles.metricRow}>
    <View style={styles.metricHeader}>
      <Text style={styles.metricLabel}>{label}</Text>
      <Text style={styles.metricValue}>{value}%</Text>
    </View>
    <View style={styles.metricTrack}>
      <View
        style={[
          styles.metricFill,
          {
            width: `${value}%`,
            backgroundColor: accent,
          },
        ]}
      />
    </View>
  </View>
);

const StagePill = ({ stage, index, activeIndex }) => {
  const active = index === activeIndex;
  const complete = index < activeIndex;

  return (
    <View
      style={[
        styles.stagePill,
        active && styles.stagePillActive,
        complete && styles.stagePillComplete,
      ]}
    >
      <Text
        style={[
          styles.stageStep,
          (active || complete) && styles.stageStepActive,
        ]}
      >
        {index + 1}
      </Text>
      <View style={styles.stageTextWrap}>
        <Text
          style={[
            styles.stageTitle,
            (active || complete) && styles.stageTitleActive,
          ]}
        >
          {stage.title}
        </Text>
        <Text
          style={[
            styles.stageCaption,
            (active || complete) && styles.stageCaptionActive,
          ]}
        >
          {stage.caption}
        </Text>
      </View>
    </View>
  );
};

const RoyalTasterScreen = () => {
  const [message, setMessage] = useState(DEFAULT_MESSAGE);
  const [activeStage, setActiveStage] = useState(0);
  const [selectedSample, setSelectedSample] = useState(SAMPLE_MESSAGES[0].id);

  const analysis = useMemo(() => analyzeMessage(message), [message]);

  const handleSamplePress = (sample) => {
    setSelectedSample(sample.id);
    setMessage(sample.message);
    setActiveStage(0);
  };

  const advanceStage = () => {
    setActiveStage((current) => Math.min(current + 1, STAGES.length - 1));
  };

  const resetDelivery = () => {
    setActiveStage(0);
  };

  const stageButtonLabel =
    activeStage === 0
      ? "Send to Royal Taster"
      : activeStage === 1
        ? "Deliver safe brief"
        : "Safe brief delivered";

  return (
    <ScrollView style={styles.screen} contentContainerStyle={styles.content}>
      <View style={styles.hero}>
        <View style={styles.heroBadge}>
          <Text style={styles.heroBadgeText}>ROYAL TASTER PROTOCOL</Text>
        </View>
        <Text style={styles.title}>Emotional Firewall</Text>
        <Text style={styles.subtitle}>
          Intercept incoming pressure, strip out the venom, and deliver only the useful signal.
        </Text>
        <View style={styles.statusRow}>
          <View style={styles.statusCard}>
            <Text style={styles.statusLabel}>Current shield state</Text>
            <Text style={styles.statusValue}>{STAGES[activeStage].title}</Text>
          </View>
          <View style={styles.statusCard}>
            <Text style={styles.statusLabel}>Stress score</Text>
            <Text style={styles.statusValue}>{analysis.score}/100</Text>
          </View>
        </View>
      </View>

      <View style={styles.card}>
        <Text style={styles.sectionEyebrow}>Message feed</Text>
        <Text style={styles.sectionTitle}>Incoming message to quarantine</Text>
        <Text style={styles.sectionBody}>
          Choose a scenario or paste your own high-pressure message. The module keeps the raw version behind the shield and prepares a safer delivery.
        </Text>

        <View style={styles.sampleRow}>
          {SAMPLE_MESSAGES.map((sample) => {
            const selected = selectedSample === sample.id;
            return (
              <Pressable
                key={sample.id}
                onPress={() => handleSamplePress(sample)}
                style={[styles.sampleChip, selected && styles.sampleChipSelected]}
              >
                <Text
                  style={[
                    styles.sampleChipText,
                    selected && styles.sampleChipTextSelected,
                  ]}
                >
                  {sample.label}
                </Text>
              </Pressable>
            );
          })}
        </View>

        <TextInput
          multiline
          textAlignVertical="top"
          value={message}
          onChangeText={(nextMessage) => {
            setMessage(nextMessage);
            setSelectedSample(null);
            setActiveStage(0);
          }}
          placeholder="Paste a stressful message here..."
          placeholderTextColor="#6E746B"
          style={styles.input}
        />

        <View style={styles.buttonRow}>
          <Pressable
            onPress={advanceStage}
            disabled={activeStage === STAGES.length - 1}
            style={[
              styles.primaryButton,
              activeStage === STAGES.length - 1 && styles.primaryButtonDisabled,
            ]}
          >
            <Text style={styles.primaryButtonText}>{stageButtonLabel}</Text>
          </Pressable>
          <Pressable onPress={resetDelivery} style={styles.secondaryButton}>
            <Text style={styles.secondaryButtonText}>Reset flow</Text>
          </Pressable>
        </View>
      </View>

      <View style={styles.stageColumn}>
        {STAGES.map((stage, index) => (
          <StagePill
            key={stage.key}
            stage={stage}
            index={index}
            activeIndex={activeStage}
          />
        ))}
      </View>

      <View style={styles.card}>
        <Text style={styles.sectionEyebrow}>Step 1</Text>
        <Text style={styles.sectionTitle}>Intercepted payload</Text>
        <Text style={styles.sectionBody}>
          The full message is visible only inside the shielded review chamber.
        </Text>
        <View style={styles.interceptedBox}>
          <Text style={styles.interceptedLabel}>Quarantined original</Text>
          <Text style={styles.interceptedText}>{analysis.message || "No message captured yet."}</Text>
        </View>
      </View>

      <View style={styles.card}>
        <Text style={styles.sectionEyebrow}>Step 2</Text>
        <Text style={styles.sectionTitle}>Royal taster review</Text>
        <Text style={styles.sectionBody}>
          Lightweight heuristics estimate how much urgency, hostility, and manipulation the message is carrying.
        </Text>

        <View style={styles.scoreHero}>
          <View>
            <Text style={styles.scoreLabel}>Assessment</Text>
            <Text style={styles.scoreTitle}>{analysis.label}</Text>
          </View>
          <View style={styles.scoreBadge}>
            <Text style={styles.scoreBadgeText}>{analysis.score}/100</Text>
          </View>
        </View>

        {analysis.metrics.map((metric) => (
          <MetricBar
            key={metric.label}
            label={metric.label}
            value={metric.value}
            accent={metric.value > 70 ? "#BE5B44" : "#2F6A61"}
          />
        ))}

        <View style={styles.highlightPanel}>
          <Text style={styles.highlightTitle}>Filtered pressure signals</Text>
          <View style={styles.highlightWrap}>
            {analysis.toxicHighlights.length ? (
              analysis.toxicHighlights.map((highlight) => (
                <View key={highlight} style={styles.highlightChip}>
                  <Text style={styles.highlightChipText}>{highlight}</Text>
                </View>
              ))
            ) : (
              <Text style={styles.highlightFallback}>
                No direct trigger phrases detected. The shield still compresses tone and urgency.
              </Text>
            )}
          </View>
        </View>
      </View>

      <View style={styles.card}>
        <Text style={styles.sectionEyebrow}>Step 3</Text>
        <Text style={styles.sectionTitle}>Delivered safe brief</Text>
        <Text style={styles.sectionBody}>
          The recipient only sees the reviewed summary and concrete next steps.
        </Text>

        <View
          style={[
            styles.deliveryCard,
            activeStage < 2 && styles.deliveryCardMuted,
          ]}
        >
          <Text style={styles.deliveryLabel}>
            {activeStage < 2 ? "Pending delivery" : "Ready for recipient"}
          </Text>
          <Text style={styles.deliveryBrief}>{analysis.safeBrief}</Text>
        </View>

        <Text style={styles.actionTitle}>Extracted action items</Text>
        <View style={styles.actionList}>
          {analysis.actionItems.map((item) => (
            <View key={item} style={styles.actionRow}>
              <View style={styles.actionDot} />
              <Text style={styles.actionText}>{item}</Text>
            </View>
          ))}
        </View>
      </View>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  screen: {
    flex: 1,
    backgroundColor: "#F4EFE4",
  },
  content: {
    padding: 20,
    paddingBottom: 32,
    gap: 16,
  },
  hero: {
    backgroundColor: "#17352F",
    borderRadius: 28,
    padding: 20,
    gap: 12,
  },
  heroBadge: {
    alignSelf: "flex-start",
    backgroundColor: "#F0D6B6",
    borderRadius: 999,
    paddingHorizontal: 10,
    paddingVertical: 6,
  },
  heroBadgeText: {
    color: "#17352F",
    fontSize: 11,
    fontWeight: "800",
    letterSpacing: 1,
  },
  title: {
    color: "#F8F2E8",
    fontSize: 30,
    fontWeight: "800",
    letterSpacing: -0.8,
  },
  subtitle: {
    color: "#D9E4DD",
    fontSize: 15,
    lineHeight: 22,
  },
  statusRow: {
    flexDirection: "row",
    gap: 12,
  },
  statusCard: {
    flex: 1,
    backgroundColor: "rgba(248, 242, 232, 0.1)",
    borderRadius: 18,
    padding: 14,
    gap: 4,
  },
  statusLabel: {
    color: "#B5C8BF",
    fontSize: 12,
    textTransform: "uppercase",
    letterSpacing: 0.8,
  },
  statusValue: {
    color: "#F8F2E8",
    fontSize: 18,
    fontWeight: "700",
  },
  card: {
    backgroundColor: "#FFF9F0",
    borderRadius: 24,
    padding: 18,
    gap: 14,
    borderWidth: 1,
    borderColor: "#E3D7C4",
  },
  sectionEyebrow: {
    color: "#8A5A2E",
    fontSize: 12,
    fontWeight: "800",
    textTransform: "uppercase",
    letterSpacing: 1,
  },
  sectionTitle: {
    color: "#20322D",
    fontSize: 22,
    fontWeight: "800",
    letterSpacing: -0.4,
  },
  sectionBody: {
    color: "#5E625D",
    fontSize: 14,
    lineHeight: 21,
  },
  sampleRow: {
    flexDirection: "row",
    flexWrap: "wrap",
    gap: 8,
  },
  sampleChip: {
    paddingHorizontal: 12,
    paddingVertical: 10,
    borderRadius: 999,
    backgroundColor: "#EFE4D4",
  },
  sampleChipSelected: {
    backgroundColor: "#2F6A61",
  },
  sampleChipText: {
    color: "#6D5340",
    fontSize: 13,
    fontWeight: "700",
  },
  sampleChipTextSelected: {
    color: "#F8F2E8",
  },
  input: {
    minHeight: 170,
    borderRadius: 20,
    padding: 16,
    backgroundColor: "#F7F0E2",
    borderWidth: 1,
    borderColor: "#D9CAB1",
    color: "#1F2724",
    fontSize: 15,
    lineHeight: 23,
  },
  buttonRow: {
    flexDirection: "row",
    gap: 10,
  },
  primaryButton: {
    flex: 1,
    backgroundColor: "#2F6A61",
    borderRadius: 16,
    paddingVertical: 14,
    paddingHorizontal: 16,
    alignItems: "center",
    justifyContent: "center",
  },
  primaryButtonText: {
    color: "#F8F2E8",
    fontSize: 15,
    fontWeight: "800",
  },
  primaryButtonDisabled: {
    backgroundColor: "#7E9B95",
  },
  secondaryButton: {
    borderRadius: 16,
    paddingVertical: 14,
    paddingHorizontal: 16,
    backgroundColor: "#EDE4D8",
    alignItems: "center",
    justifyContent: "center",
  },
  secondaryButtonText: {
    color: "#43514B",
    fontSize: 14,
    fontWeight: "700",
  },
  stageColumn: {
    gap: 10,
  },
  stagePill: {
    flexDirection: "row",
    alignItems: "center",
    gap: 12,
    backgroundColor: "#E9E1D5",
    borderRadius: 22,
    padding: 14,
  },
  stagePillActive: {
    backgroundColor: "#F0D6B6",
  },
  stagePillComplete: {
    backgroundColor: "#D5E3DB",
  },
  stageStep: {
    width: 34,
    height: 34,
    borderRadius: 17,
    backgroundColor: "#FFF9F0",
    color: "#81796E",
    textAlign: "center",
    textAlignVertical: "center",
    fontWeight: "800",
    overflow: "hidden",
    paddingTop: 7,
  },
  stageStepActive: {
    backgroundColor: "#17352F",
    color: "#F8F2E8",
  },
  stageTextWrap: {
    flex: 1,
    gap: 2,
  },
  stageTitle: {
    color: "#473F36",
    fontSize: 15,
    fontWeight: "800",
  },
  stageTitleActive: {
    color: "#17352F",
  },
  stageCaption: {
    color: "#6C665D",
    fontSize: 12,
    lineHeight: 18,
  },
  stageCaptionActive: {
    color: "#2F453D",
  },
  interceptedBox: {
    backgroundColor: "#1F2623",
    borderRadius: 20,
    padding: 16,
    gap: 8,
  },
  interceptedLabel: {
    color: "#B7C2BB",
    fontSize: 12,
    textTransform: "uppercase",
    letterSpacing: 1,
    fontWeight: "700",
  },
  interceptedText: {
    color: "#F3EFE8",
    fontSize: 15,
    lineHeight: 23,
  },
  scoreHero: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    backgroundColor: "#F7EBDC",
    borderRadius: 18,
    padding: 16,
  },
  scoreLabel: {
    color: "#7D654A",
    fontSize: 12,
    fontWeight: "700",
    textTransform: "uppercase",
    letterSpacing: 1,
  },
  scoreTitle: {
    color: "#20322D",
    fontSize: 24,
    fontWeight: "800",
  },
  scoreBadge: {
    minWidth: 76,
    borderRadius: 999,
    paddingHorizontal: 14,
    paddingVertical: 12,
    backgroundColor: "#17352F",
    alignItems: "center",
  },
  scoreBadgeText: {
    color: "#F8F2E8",
    fontSize: 18,
    fontWeight: "800",
  },
  metricRow: {
    gap: 8,
  },
  metricHeader: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
  },
  metricLabel: {
    color: "#33403B",
    fontSize: 14,
    fontWeight: "700",
  },
  metricValue: {
    color: "#6A5D4B",
    fontSize: 13,
    fontWeight: "700",
  },
  metricTrack: {
    height: 10,
    borderRadius: 999,
    overflow: "hidden",
    backgroundColor: "#E8DED0",
  },
  metricFill: {
    height: "100%",
    borderRadius: 999,
  },
  highlightPanel: {
    backgroundColor: "#F7F0E6",
    borderRadius: 18,
    padding: 14,
    gap: 10,
  },
  highlightTitle: {
    color: "#37423D",
    fontSize: 14,
    fontWeight: "800",
  },
  highlightWrap: {
    flexDirection: "row",
    flexWrap: "wrap",
    gap: 8,
  },
  highlightChip: {
    backgroundColor: "#F1D0C2",
    borderRadius: 999,
    paddingHorizontal: 10,
    paddingVertical: 8,
  },
  highlightChipText: {
    color: "#8D4135",
    fontSize: 12,
    fontWeight: "700",
  },
  highlightFallback: {
    color: "#6C665D",
    fontSize: 13,
    lineHeight: 20,
  },
  deliveryCard: {
    borderRadius: 20,
    padding: 16,
    gap: 10,
    backgroundColor: "#DDEBE3",
  },
  deliveryCardMuted: {
    backgroundColor: "#E8E2D8",
  },
  deliveryLabel: {
    color: "#325047",
    fontSize: 12,
    fontWeight: "800",
    textTransform: "uppercase",
    letterSpacing: 1,
  },
  deliveryBrief: {
    color: "#17352F",
    fontSize: 16,
    lineHeight: 24,
    fontWeight: "600",
  },
  actionTitle: {
    color: "#20322D",
    fontSize: 16,
    fontWeight: "800",
  },
  actionList: {
    gap: 10,
  },
  actionRow: {
    flexDirection: "row",
    alignItems: "flex-start",
    gap: 10,
    padding: 12,
    borderRadius: 16,
    backgroundColor: "#F7F0E2",
  },
  actionDot: {
    width: 10,
    height: 10,
    borderRadius: 5,
    backgroundColor: "#2F6A61",
    marginTop: 5,
  },
  actionText: {
    flex: 1,
    color: "#30403A",
    fontSize: 14,
    lineHeight: 21,
    fontWeight: "600",
  },
});

export default {
  id: "royal-taster",
  shortLabel: "Royal Taster",
  kicker: "Plan 2",
  title: "Royal Food Taster",
  tagline: "Message interception before emotional impact hits the recipient.",
  summary:
    "A mobile emotional firewall that intercepts stressful messages, reviews toxicity, and delivers a calm brief with action items.",
  meta: ["Emotional firewall", "Delegation", "Safe brief"],
  accent: "#2F6A61",
  Component: RoyalTasterScreen,
};

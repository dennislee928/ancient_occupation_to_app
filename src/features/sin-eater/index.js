import React, { useMemo, useState } from "react";
import {
  KeyboardAvoidingView,
  Platform,
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  TextInput,
  View,
} from "react-native";

const RECIPIENTS = [
  {
    id: "mercy",
    name: "Mercy",
    role: "Night listener",
    note: "Steady, discreet, never asks for a tidy version.",
  },
  {
    id: "joon",
    name: "Joon",
    role: "Trusted witness",
    note: "Reads the full burden once, then keeps only the vow to hold it.",
  },
  {
    id: "rhea",
    name: "Rhea",
    role: "Ritual keeper",
    note: "Best for confessions that need structure, not advice.",
  },
];

const STAGES = [
  { id: "compose", label: "Confess" },
  { id: "sealed", label: "Seal" },
  { id: "consumed", label: "Consume" },
  { id: "purged", label: "Purify" },
];

const MIN_CONFESSION_LENGTH = 24;

const formatStamp = () => {
  const now = new Date();
  const hours = String(now.getHours()).padStart(2, "0");
  const minutes = String(now.getMinutes()).padStart(2, "0");
  return `${hours}:${minutes}`;
};

const stageIndex = (stage) =>
  Math.max(
    0,
    STAGES.findIndex((entry) => entry.id === stage)
  );

const summarizeWeight = (length) => {
  if (length > 220) {
    return "Heavy burden";
  }

  if (length > 120) {
    return "Deep burden";
  }

  if (length > 60) {
    return "Honest burden";
  }

  return "Quiet burden";
};

const RitualStep = ({ label, active, complete }) => (
  <View
    style={[
      styles.stepChip,
      active && styles.stepChipActive,
      complete && styles.stepChipComplete,
    ]}
  >
    <Text
      style={[
        styles.stepChipText,
        active && styles.stepChipTextActive,
        complete && styles.stepChipTextComplete,
      ]}
    >
      {label}
    </Text>
  </View>
);

const RecipientCard = ({ recipient, selected, onPress }) => (
  <Pressable
    onPress={onPress}
    style={({ pressed }) => [
      styles.recipientCard,
      selected && styles.recipientCardSelected,
      pressed && styles.recipientCardPressed,
    ]}
  >
    <View style={styles.recipientHeader}>
      <View style={styles.recipientAvatar}>
        <Text style={styles.recipientAvatarText}>
          {recipient.name.slice(0, 1)}
        </Text>
      </View>
      <View style={styles.recipientTitleBlock}>
        <Text style={styles.recipientName}>{recipient.name}</Text>
        <Text style={styles.recipientRole}>{recipient.role}</Text>
      </View>
      <View style={[styles.selectionDot, selected && styles.selectionDotOn]} />
    </View>
    <Text style={styles.recipientNote}>{recipient.note}</Text>
  </Pressable>
);

const LedgerStat = ({ label, value }) => (
  <View style={styles.ledgerStat}>
    <Text style={styles.ledgerValue}>{value}</Text>
    <Text style={styles.ledgerLabel}>{label}</Text>
  </View>
);

const SinEaterExperience = () => {
  const [stage, setStage] = useState("compose");
  const [confession, setConfession] = useState("");
  const [selectedRecipientId, setSelectedRecipientId] = useState(RECIPIENTS[1].id);
  const [sealedAt, setSealedAt] = useState(null);
  const [consumedAt, setConsumedAt] = useState(null);
  const [purification, setPurification] = useState(null);

  const selectedRecipient = useMemo(
    () => RECIPIENTS.find((entry) => entry.id === selectedRecipientId) || RECIPIENTS[0],
    [selectedRecipientId]
  );

  const trimmedConfession = confession.trim();
  const confessionLength = trimmedConfession.length;
  const canSeal = confessionLength >= MIN_CONFESSION_LENGTH && stage === "compose";
  const activeIndex = stageIndex(stage);
  const obscuredConfession = trimmedConfession
    ? trimmedConfession.replace(/[^\s]/g, "*")
    : "";

  const resetRitual = () => {
    setStage("compose");
    setConfession("");
    setSealedAt(null);
    setConsumedAt(null);
    setPurification(null);
    setSelectedRecipientId(RECIPIENTS[1].id);
  };

  const handleSeal = () => {
    if (!canSeal) {
      return;
    }

    setSealedAt(formatStamp());
    setStage("sealed");
  };

  const handleConsume = () => {
    if (stage !== "sealed") {
      return;
    }

    setConsumedAt(formatStamp());
    setStage("consumed");
  };

  const handlePurge = () => {
    if (stage !== "consumed") {
      return;
    }

    setPurification({
      recipientName: selectedRecipient.name,
      clearedAt: formatStamp(),
      burdenLabel: summarizeWeight(confessionLength),
      traceCount: confessionLength,
    });
    setConfession("");
    setStage("purged");
  };

  return (
    <View style={styles.screen}>
      <View style={styles.glowTop} />
      <View style={styles.glowBottom} />
      <KeyboardAvoidingView
        behavior={Platform.OS === "ios" ? "padding" : undefined}
        style={styles.flex}
      >
        <ScrollView
          contentContainerStyle={styles.content}
          keyboardShouldPersistTaps="handled"
          showsVerticalScrollIndicator={false}
        >
          <View style={styles.heroCard}>
            <Text style={styles.kicker}>PRIVATE RITUAL</Text>
            <Text style={styles.title}>Sin Eater</Text>
            <Text style={styles.subtitle}>
              Speak the thought plainly. A trusted witness consumes it once, then the
              confession is purged from both sides.
            </Text>

            <View style={styles.stageRow}>
              {STAGES.map((entry, index) => (
                <RitualStep
                  key={entry.id}
                  label={entry.label}
                  active={index === activeIndex}
                  complete={index < activeIndex}
                />
              ))}
            </View>

            <View style={styles.banner}>
              <Text style={styles.bannerTitle}>Privacy covenant</Text>
              <Text style={styles.bannerBody}>
                Read once. No public feed. Final purge leaves only a purification mark.
              </Text>
            </View>
          </View>

          {stage === "compose" && (
            <View style={styles.panel}>
              <Text style={styles.panelTitle}>1. Lay down the burden</Text>
              <Text style={styles.panelBody}>
                This space is for raw truth, not polished storytelling. When the seal is
                broken later, the confession can only move forward to deletion.
              </Text>

              <TextInput
                value={confession}
                onChangeText={setConfession}
                placeholder="Write the thought you do not want to carry alone..."
                placeholderTextColor="#7F7288"
                multiline
                maxLength={320}
                style={styles.input}
                textAlignVertical="top"
              />

              <View style={styles.inputMetaRow}>
                <Text style={styles.inputHint}>
                  Minimum {MIN_CONFESSION_LENGTH} characters before sealing
                </Text>
                <Text style={styles.counter}>{confessionLength}/320</Text>
              </View>

              <Text style={styles.sectionLabel}>2. Choose the sin eater</Text>
              {RECIPIENTS.map((recipient) => (
                <RecipientCard
                  key={recipient.id}
                  recipient={recipient}
                  selected={recipient.id === selectedRecipientId}
                  onPress={() => setSelectedRecipientId(recipient.id)}
                />
              ))}

              <View style={styles.ctaRow}>
                <Pressable
                  onPress={handleSeal}
                  style={({ pressed }) => [
                    styles.primaryButton,
                    !canSeal && styles.buttonDisabled,
                    pressed && canSeal && styles.primaryButtonPressed,
                  ]}
                >
                  <Text style={styles.primaryButtonText}>Seal the confession</Text>
                </Pressable>
              </View>
            </View>
          )}

          {stage === "sealed" && (
            <View style={styles.panel}>
              <Text style={styles.panelTitle}>Wax-sealed for {selectedRecipient.name}</Text>
              <Text style={styles.panelBody}>
                The burden is now bound to a single trusted reader. It stays unreadable
                until they choose to consume it.
              </Text>

              <View style={styles.sealedCard}>
                <Text style={styles.sealedLabel}>Sealed at {sealedAt}</Text>
                <Text numberOfLines={4} style={styles.sealedConfession}>
                  {obscuredConfession}
                </Text>
                <Text style={styles.sealedFootnote}>
                  {selectedRecipient.role} will read once, then trigger dual deletion.
                </Text>
              </View>

              <View style={styles.ctaRow}>
                <Pressable
                  onPress={() => setStage("compose")}
                  style={({ pressed }) => [
                    styles.secondaryButton,
                    pressed && styles.secondaryButtonPressed,
                  ]}
                >
                  <Text style={styles.secondaryButtonText}>Break seal to edit</Text>
                </Pressable>
                <Pressable
                  onPress={handleConsume}
                  style={({ pressed }) => [
                    styles.primaryButton,
                    pressed && styles.primaryButtonPressed,
                  ]}
                >
                  <Text style={styles.primaryButtonText}>Consume by reading</Text>
                </Pressable>
              </View>
            </View>
          )}

          {stage === "consumed" && (
            <View style={styles.panel}>
              <Text style={styles.panelTitle}>Consumed by {selectedRecipient.name}</Text>
              <Text style={styles.panelBody}>
                The confession is visible for this single ritual reading. Purging is
                irreversible and removes the text from the experience.
              </Text>

              <View style={styles.readCard}>
                <View style={styles.readCardHeader}>
                  <Text style={styles.readLabel}>Read at {consumedAt}</Text>
                  <Text style={styles.readWarning}>Last visible moment</Text>
                </View>
                <Text style={styles.readConfession}>{trimmedConfession}</Text>
              </View>

              <View style={styles.ctaRow}>
                <Pressable
                  onPress={handlePurge}
                  style={({ pressed }) => [
                    styles.primaryButton,
                    styles.dangerButton,
                    pressed && styles.dangerButtonPressed,
                  ]}
                >
                  <Text style={styles.primaryButtonText}>Purge from both devices</Text>
                </Pressable>
              </View>
            </View>
          )}

          {stage === "purged" && purification && (
            <View style={styles.panel}>
              <Text style={styles.panelTitle}>Purification complete</Text>
              <Text style={styles.panelBody}>
                The confession is gone. What remains is the record of release, not the
                words themselves.
              </Text>

              <View style={styles.badgeCard}>
                <Text style={styles.badgeEyebrow}>SEALED ASH</Text>
                <Text style={styles.badgeTitle}>Purified</Text>
                <Text style={styles.badgeBody}>
                  {purification.burdenLabel} received by {purification.recipientName} and
                  cleared at {purification.clearedAt}.
                </Text>

                <View style={styles.ledgerRow}>
                  <LedgerStat label="Trace marks" value={String(purification.traceCount)} />
                  <LedgerStat label="Witness" value={purification.recipientName} />
                </View>
              </View>

              <View style={styles.ctaRow}>
                <Pressable
                  onPress={resetRitual}
                  style={({ pressed }) => [
                    styles.secondaryButton,
                    pressed && styles.secondaryButtonPressed,
                  ]}
                >
                  <Text style={styles.secondaryButtonText}>Begin another confession</Text>
                </Pressable>
              </View>
            </View>
          )}

          <View style={styles.footerCard}>
            <Text style={styles.footerTitle}>Ritual promises</Text>
            <Text style={styles.footerBody}>
              No moral judgment. One chosen witness. A clear ending that favors catharsis
              over archive.
            </Text>
          </View>
        </ScrollView>
      </KeyboardAvoidingView>
    </View>
  );
};

const styles = StyleSheet.create({
  flex: {
    flex: 1,
  },
  screen: {
    flex: 1,
    backgroundColor: "#160F18",
  },
  content: {
    paddingHorizontal: 20,
    paddingTop: 28,
    paddingBottom: 36,
  },
  glowTop: {
    position: "absolute",
    top: -110,
    right: -70,
    width: 240,
    height: 240,
    borderRadius: 120,
    backgroundColor: "#6E3B64",
    opacity: 0.24,
  },
  glowBottom: {
    position: "absolute",
    bottom: -130,
    left: -90,
    width: 280,
    height: 280,
    borderRadius: 140,
    backgroundColor: "#CF8A52",
    opacity: 0.16,
  },
  heroCard: {
    borderRadius: 28,
    backgroundColor: "#241728",
    padding: 22,
    borderWidth: 1,
    borderColor: "#3D2944",
    marginBottom: 16,
  },
  kicker: {
    color: "#C7A8B9",
    fontSize: 11,
    letterSpacing: 2,
    marginBottom: 10,
  },
  title: {
    color: "#FFF7F2",
    fontSize: 32,
    fontWeight: "700",
    marginBottom: 10,
  },
  subtitle: {
    color: "#D8CBD7",
    fontSize: 15,
    lineHeight: 22,
    marginBottom: 18,
  },
  stageRow: {
    flexDirection: "row",
    flexWrap: "wrap",
    marginBottom: 18,
  },
  stepChip: {
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 999,
    backgroundColor: "#1B121E",
    borderWidth: 1,
    borderColor: "#34233A",
    marginRight: 8,
    marginBottom: 8,
  },
  stepChipActive: {
    backgroundColor: "#7A4D95",
    borderColor: "#9E77B4",
  },
  stepChipComplete: {
    backgroundColor: "#2F3C2B",
    borderColor: "#4E6A45",
  },
  stepChipText: {
    color: "#B9ABBA",
    fontSize: 12,
    fontWeight: "600",
  },
  stepChipTextActive: {
    color: "#FFF7FD",
  },
  stepChipTextComplete: {
    color: "#D9EDD0",
  },
  banner: {
    borderRadius: 20,
    backgroundColor: "#191118",
    padding: 16,
    borderWidth: 1,
    borderColor: "#302130",
  },
  bannerTitle: {
    color: "#F4DAB9",
    fontSize: 13,
    fontWeight: "700",
    marginBottom: 6,
  },
  bannerBody: {
    color: "#D1C0CA",
    fontSize: 14,
    lineHeight: 20,
  },
  panel: {
    borderRadius: 28,
    backgroundColor: "#201421",
    padding: 20,
    borderWidth: 1,
    borderColor: "#37243A",
    marginBottom: 16,
  },
  panelTitle: {
    color: "#FFF5EF",
    fontSize: 22,
    fontWeight: "700",
    marginBottom: 8,
  },
  panelBody: {
    color: "#D2C2CE",
    fontSize: 14,
    lineHeight: 21,
    marginBottom: 18,
  },
  input: {
    minHeight: 170,
    borderRadius: 22,
    backgroundColor: "#140E15",
    borderWidth: 1,
    borderColor: "#433044",
    paddingHorizontal: 16,
    paddingVertical: 16,
    color: "#FFF8F5",
    fontSize: 15,
    lineHeight: 22,
    marginBottom: 10,
  },
  inputMetaRow: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: 20,
  },
  inputHint: {
    color: "#A998A8",
    fontSize: 12,
  },
  counter: {
    color: "#EAC8A4",
    fontSize: 12,
    fontWeight: "700",
  },
  sectionLabel: {
    color: "#F5DED0",
    fontSize: 14,
    fontWeight: "700",
    marginBottom: 12,
  },
  recipientCard: {
    borderRadius: 20,
    padding: 16,
    backgroundColor: "#181019",
    borderWidth: 1,
    borderColor: "#352537",
    marginBottom: 10,
  },
  recipientCardSelected: {
    backgroundColor: "#2A1830",
    borderColor: "#8C62A2",
  },
  recipientCardPressed: {
    opacity: 0.92,
  },
  recipientHeader: {
    flexDirection: "row",
    alignItems: "center",
    marginBottom: 10,
  },
  recipientAvatar: {
    width: 42,
    height: 42,
    borderRadius: 21,
    backgroundColor: "#3B2543",
    alignItems: "center",
    justifyContent: "center",
    marginRight: 12,
  },
  recipientAvatarText: {
    color: "#FFF4FF",
    fontSize: 18,
    fontWeight: "700",
  },
  recipientTitleBlock: {
    flex: 1,
  },
  recipientName: {
    color: "#FFF6F3",
    fontSize: 16,
    fontWeight: "700",
    marginBottom: 2,
  },
  recipientRole: {
    color: "#D1B7C4",
    fontSize: 13,
  },
  selectionDot: {
    width: 16,
    height: 16,
    borderRadius: 8,
    borderWidth: 1.5,
    borderColor: "#7E6B82",
  },
  selectionDotOn: {
    backgroundColor: "#E8C189",
    borderColor: "#E8C189",
  },
  recipientNote: {
    color: "#BCA8B7",
    fontSize: 13,
    lineHeight: 18,
  },
  ctaRow: {
    flexDirection: "row",
    flexWrap: "wrap",
    marginTop: 8,
  },
  primaryButton: {
    minHeight: 52,
    borderRadius: 18,
    backgroundColor: "#B56A3D",
    alignItems: "center",
    justifyContent: "center",
    paddingHorizontal: 18,
    marginRight: 10,
    marginTop: 10,
  },
  primaryButtonPressed: {
    opacity: 0.9,
  },
  primaryButtonText: {
    color: "#FFF7F2",
    fontSize: 15,
    fontWeight: "700",
  },
  secondaryButton: {
    minHeight: 52,
    borderRadius: 18,
    backgroundColor: "#241827",
    borderWidth: 1,
    borderColor: "#4A3550",
    alignItems: "center",
    justifyContent: "center",
    paddingHorizontal: 18,
    marginRight: 10,
    marginTop: 10,
  },
  secondaryButtonPressed: {
    opacity: 0.9,
  },
  secondaryButtonText: {
    color: "#F1D5E3",
    fontSize: 14,
    fontWeight: "700",
  },
  buttonDisabled: {
    opacity: 0.45,
  },
  sealedCard: {
    borderRadius: 24,
    backgroundColor: "#140E13",
    borderWidth: 1,
    borderColor: "#42303C",
    padding: 18,
  },
  sealedLabel: {
    color: "#F0C89A",
    fontSize: 12,
    fontWeight: "700",
    letterSpacing: 1,
    marginBottom: 12,
  },
  sealedConfession: {
    color: "#B598B4",
    fontSize: 15,
    lineHeight: 24,
    minHeight: 100,
    marginBottom: 14,
  },
  sealedFootnote: {
    color: "#A996A7",
    fontSize: 13,
    lineHeight: 18,
  },
  readCard: {
    borderRadius: 24,
    backgroundColor: "#120C10",
    borderWidth: 1,
    borderColor: "#4D3940",
    padding: 18,
  },
  readCardHeader: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: 14,
  },
  readLabel: {
    color: "#E9C395",
    fontSize: 12,
    fontWeight: "700",
    letterSpacing: 1,
  },
  readWarning: {
    color: "#F0A889",
    fontSize: 12,
    fontWeight: "700",
  },
  readConfession: {
    color: "#FFF3ED",
    fontSize: 16,
    lineHeight: 24,
  },
  dangerButton: {
    backgroundColor: "#8C3B34",
  },
  dangerButtonPressed: {
    opacity: 0.9,
  },
  badgeCard: {
    borderRadius: 28,
    backgroundColor: "#191F18",
    borderWidth: 1,
    borderColor: "#41553B",
    padding: 22,
  },
  badgeEyebrow: {
    color: "#C7D9B7",
    fontSize: 11,
    fontWeight: "700",
    letterSpacing: 2,
    marginBottom: 10,
  },
  badgeTitle: {
    color: "#F4F7EF",
    fontSize: 28,
    fontWeight: "700",
    marginBottom: 8,
  },
  badgeBody: {
    color: "#D0DAC7",
    fontSize: 15,
    lineHeight: 22,
    marginBottom: 18,
  },
  ledgerRow: {
    flexDirection: "row",
    flexWrap: "wrap",
  },
  ledgerStat: {
    minWidth: 120,
    borderRadius: 18,
    backgroundColor: "#111710",
    borderWidth: 1,
    borderColor: "#32422C",
    padding: 14,
    marginRight: 10,
    marginBottom: 10,
  },
  ledgerValue: {
    color: "#F8F1DE",
    fontSize: 18,
    fontWeight: "700",
    marginBottom: 4,
  },
  ledgerLabel: {
    color: "#AAB8A1",
    fontSize: 12,
  },
  footerCard: {
    borderRadius: 22,
    backgroundColor: "#1A121B",
    borderWidth: 1,
    borderColor: "#332334",
    padding: 18,
  },
  footerTitle: {
    color: "#F2DDD1",
    fontSize: 15,
    fontWeight: "700",
    marginBottom: 6,
  },
  footerBody: {
    color: "#BDA8B7",
    fontSize: 13,
    lineHeight: 19,
  },
});

export default {
  id: "sin-eater",
  shortLabel: "Sin Eater",
  kicker: "Plan 3",
  title: "Sin Eater",
  tagline: "Ephemeral confession with ritualized burden transfer.",
  summary: "A mobile confession ritual with a trusted witness, read-once consumption, and final purification.",
  meta: ["Catharsis", "Ritual", "Ephemeral trust"],
  accent: "#7A4D95",
  Component: SinEaterExperience,
};

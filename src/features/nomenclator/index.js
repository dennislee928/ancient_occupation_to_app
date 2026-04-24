import React, { useMemo, useState } from "react";
import {
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  View,
} from "react-native";

const PEOPLE = [
  {
    id: "victor-chen",
    name: "Victor Chen",
    role: "Procurement lead at Helios Display",
    pronunciation: "VIK-ter CHEN",
    familiarity: "Warm lead",
    confidence: 86,
    lastSeen: "Seen 7 months ago at Taipei Smart Venue Expo",
    relationship: "Introduced by Ivy after the panel on retail hardware.",
    identityCue: "Tall, rimless glasses, usually carries a navy tote.",
    opener:
      "Ask whether the pilot stores in Taichung kept the queue times down.",
    avoid: "Do not open with pricing pressure; he pushed that topic aside last time.",
    followUp: "Congratulate him on the golden retriever he adopted in November.",
    anchors: [
      "Met at booth D14 while comparing kiosk uptime vendors.",
      "Remembers practical details more than broad vision talk.",
      "Likes concise follow-ups with exact next steps.",
    ],
    topics: ["Retail rollout", "Golden retriever", "Store operations"],
    companion: "Maya",
    contexts: [
      {
        id: "expo-floor",
        label: "Expo floor",
        setting: "High-noise, short windows between demos.",
        goal: "Reconnect fast and earn a follow-up meeting.",
        cue: "Lead with the Taichung pilot and one concrete result.",
      },
      {
        id: "coffee-line",
        label: "Coffee line",
        setting: "Casual queue, 90 seconds before he moves on.",
        goal: "Sound personal without overloading him.",
        cue: "Mention the dog first, then pivot into rollout timing.",
      },
      {
        id: "after-party",
        label: "After-party",
        setting: "Louder room, social mode, business later.",
        goal: "Keep it light and leave with permission to message.",
        cue: "Use the dog or travel angle and skip procurement detail.",
      },
    ],
    backstageFeed: [
      {
        id: "victor-feed-1",
        label: "Priority cue",
        source: "Maya",
        age: "Now",
        text: "This is Victor from Helios. Last spoke at Smart Venue Expo about Taichung self-checkout pilots.",
      },
      {
        id: "victor-feed-2",
        label: "Human detail",
        source: "Maya",
        age: "1 min ago",
        text: "He adopted a golden retriever named Bao. Safe personal opener if the room is too noisy for business.",
      },
      {
        id: "victor-feed-3",
        label: "Risk note",
        source: "Maya",
        age: "2 min ago",
        text: "Avoid opening with discounts. He reacted better when you framed uptime and training support.",
      },
    ],
  },
  {
    id: "amelia-wong",
    name: "Amelia Wong",
    role: "Nonprofit fundraiser and museum trustee",
    pronunciation: "uh-MEE-lee-uh WONG",
    familiarity: "Social acquaintance",
    confidence: 79,
    lastSeen: "Seen 5 weeks ago at the heritage dinner",
    relationship: "Sat at your left during the donor table raffle.",
    identityCue: "Short silver earrings, velvet blazer, warm laugh.",
    opener:
      "Ask whether the youth conservation workshop sold out again this spring.",
    avoid: "Skip office politics around the trustee board reshuffle.",
    followUp: "She mentioned her daughter was applying for architecture programs.",
    anchors: [
      "Bonded over old storefront signage and local history archives.",
      "Prefers cause-driven conversation over networking small talk.",
      "Likes remembering people who followed up on family milestones.",
    ],
    topics: ["Local history", "Youth workshop", "Architecture schools"],
    companion: "Noah",
    contexts: [
      {
        id: "benefit-reception",
        label: "Benefit reception",
        setting: "High-trust room with donors and trustees nearby.",
        goal: "Show you remembered the mission, not just the name.",
        cue: "Open on the workshop impact and ask one sincere question.",
      },
      {
        id: "gallery-walk",
        label: "Gallery walk",
        setting: "Slow pace, easy to linger near exhibits.",
        goal: "Turn memory into a thoughtful conversation.",
        cue: "Tie the exhibit to the storefront-signage conversation you had.",
      },
      {
        id: "exit lobby",
        label: "Exit lobby",
        setting: "Brief goodbye window before cars arrive.",
        goal: "Land a considerate follow-up message.",
        cue: "Wish her daughter luck and ask if an introduction would help.",
      },
    ],
    backstageFeed: [
      {
        id: "amelia-feed-1",
        label: "Priority cue",
        source: "Noah",
        age: "Now",
        text: "Amelia Wong, museum trustee. You spoke about preserving old storefront signs and neighborhood memory.",
      },
      {
        id: "amelia-feed-2",
        label: "Mission cue",
        source: "Noah",
        age: "45 sec ago",
        text: "Safe opener: ask if the youth conservation workshop filled up again. She lit up when describing it.",
      },
      {
        id: "amelia-feed-3",
        label: "Family cue",
        source: "Noah",
        age: "2 min ago",
        text: "Her daughter was applying to architecture schools. Good personal check-in if you have a quiet moment.",
      },
    ],
  },
  {
    id: "daniel-kim",
    name: "Daniel Kim",
    role: "Product designer turned startup advisor",
    pronunciation: "DAN-yul KIM",
    familiarity: "Friendly repeat contact",
    confidence: 91,
    lastSeen: "Seen 3 days ago on a founder breakfast panel",
    relationship: "Introduced you to two wearable-device founders last quarter.",
    identityCue: "Usually in monochrome layers, analog watch, gentle voice.",
    opener:
      "Thank him for the wearable intros and ask how his studio move is going.",
    avoid: "Do not pitch immediately; he dislikes being cornered into a live demo.",
    followUp: "He just moved his studio closer to Songshan Cultural Park.",
    anchors: [
      "Strong on product craft, skeptical of hype-heavy AR claims.",
      "Responds well when you ask for critique instead of approval.",
      "Often remembers who respected his time constraints.",
    ],
    topics: ["Wearables", "Studio move", "Founder intros"],
    companion: "Eli",
    contexts: [
      {
        id: "panel-green-room",
        label: "Green room",
        setting: "Pre-talk focus, low patience for wandering chat.",
        goal: "Be useful and brief.",
        cue: "Lead with gratitude for the intros, then one precise update.",
      },
      {
        id: "demo-table",
        label: "Demo table",
        setting: "He can see products and will assess quickly.",
        goal: "Invite critique, not a hard sell.",
        cue: "Ask what feels too noisy in the experience.",
      },
      {
        id: "street walk",
        label: "Street walk",
        setting: "Conversation while leaving the venue.",
        goal: "Make the studio move the center of the exchange.",
        cue: "Check in on the move first and keep startup talk second.",
      },
    ],
    backstageFeed: [
      {
        id: "daniel-feed-1",
        label: "Priority cue",
        source: "Eli",
        age: "Now",
        text: "Daniel Kim. He introduced you to two wearable founders and respects concise thank-yous.",
      },
      {
        id: "daniel-feed-2",
        label: "Approach cue",
        source: "Eli",
        age: "50 sec ago",
        text: "Ask for critique, not validation. He engages when the ask is specific and design-focused.",
      },
      {
        id: "daniel-feed-3",
        label: "Personal cue",
        source: "Eli",
        age: "3 min ago",
        text: "He recently moved his studio near Songshan Cultural Park. Easy way to open while walking out.",
      },
    ],
  },
];

const findById = (items, id) => items.find((item) => item.id === id) || items[0];

const PersonChip = ({ person, isActive, onPress }) => (
  <Pressable
    accessibilityRole="button"
    onPress={onPress}
    style={[styles.personChip, isActive && styles.personChipActive]}
  >
    <View style={styles.personAvatar}>
      <Text style={styles.personInitials}>
        {person.name
          .split(" ")
          .map((part) => part[0])
          .join("")}
      </Text>
    </View>
    <View style={styles.personChipText}>
      <Text style={[styles.personName, isActive && styles.personNameActive]}>
        {person.name}
      </Text>
      <Text
        style={[styles.personRole, isActive && styles.personRoleActive]}
        numberOfLines={1}
      >
        {person.role}
      </Text>
    </View>
  </Pressable>
);

const ContextCard = ({ item, isActive, onPress }) => (
  <Pressable
    accessibilityRole="button"
    onPress={onPress}
    style={[styles.contextCard, isActive && styles.contextCardActive]}
  >
    <Text style={[styles.contextLabel, isActive && styles.contextLabelActive]}>
      {item.label}
    </Text>
    <Text style={[styles.contextSetting, isActive && styles.contextSettingActive]}>
      {item.setting}
    </Text>
    <Text style={[styles.contextGoal, isActive && styles.contextGoalActive]}>
      {item.goal}
    </Text>
  </Pressable>
);

const FeedCard = ({ item, isActive, onPress }) => (
  <Pressable
    accessibilityRole="button"
    onPress={onPress}
    style={[styles.feedCard, isActive && styles.feedCardActive]}
  >
    <View style={styles.feedHeader}>
      <Text style={styles.feedBadge}>{item.label}</Text>
      <Text style={styles.feedAge}>{item.age}</Text>
    </View>
    <Text style={styles.feedText}>{item.text}</Text>
    <Text style={styles.feedMeta}>Sent by {item.source} to your earpiece</Text>
  </Pressable>
);

const NoteRow = ({ label, value }) => (
  <View style={styles.noteRow}>
    <Text style={styles.noteLabel}>{label}</Text>
    <Text style={styles.noteValue}>{value}</Text>
  </View>
);

const NomenclatorScreen = () => {
  const [selectedPersonId, setSelectedPersonId] = useState(PEOPLE[0].id);
  const [selectedContextId, setSelectedContextId] = useState(PEOPLE[0].contexts[0].id);
  const [selectedPromptId, setSelectedPromptId] = useState(PEOPLE[0].backstageFeed[0].id);

  const selectedPerson = useMemo(
    () => findById(PEOPLE, selectedPersonId),
    [selectedPersonId]
  );
  const selectedContext = useMemo(
    () => findById(selectedPerson.contexts, selectedContextId),
    [selectedContextId, selectedPerson]
  );
  const selectedPrompt = useMemo(
    () => findById(selectedPerson.backstageFeed, selectedPromptId),
    [selectedPromptId, selectedPerson]
  );

  const previewLines = useMemo(
    () => [
      `${selectedPerson.name} | ${selectedPerson.familiarity}`,
      selectedContext.cue,
      `Say: ${selectedPerson.opener}`,
      `Avoid: ${selectedPerson.avoid}`,
      `Prompt: ${selectedPrompt.text}`,
    ],
    [selectedContext, selectedPerson, selectedPrompt]
  );

  const selectPerson = (person) => {
    setSelectedPersonId(person.id);
    setSelectedContextId(person.contexts[0].id);
    setSelectedPromptId(person.backstageFeed[0].id);
  };

  return (
    <ScrollView
      style={styles.screen}
      contentContainerStyle={styles.content}
      showsVerticalScrollIndicator={false}
    >
      <View style={styles.heroCard}>
        <View style={styles.heroHeader}>
          <View>
            <Text style={styles.eyebrow}>Companion memory demo</Text>
            <Text style={styles.heroTitle}>Discreet social recall, live.</Text>
          </View>
          <View style={styles.liveBadge}>
            <Text style={styles.liveBadgeText}>Link live</Text>
          </View>
        </View>
        <Text style={styles.heroBody}>
          A backstage partner can push short recognition cues, human details,
          and risk notes while you talk. The watch or AR view stays terse enough
          to glance at mid-conversation.
        </Text>
        <View style={styles.heroStats}>
          <View style={styles.statPill}>
            <Text style={styles.statLabel}>Companion</Text>
            <Text style={styles.statValue}>{selectedPerson.companion}</Text>
          </View>
          <View style={styles.statPill}>
            <Text style={styles.statLabel}>Recall confidence</Text>
            <Text style={styles.statValue}>{selectedPerson.confidence}%</Text>
          </View>
          <View style={styles.statPill}>
            <Text style={styles.statLabel}>Mode</Text>
            <Text style={styles.statValue}>{selectedContext.label}</Text>
          </View>
        </View>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>People in view</Text>
        <Text style={styles.sectionSubtitle}>
          Pick the person you have just spotted so the backstage notes and
          preview reframe around the right encounter.
        </Text>
        <View style={styles.personList}>
          {PEOPLE.map((person) => (
            <PersonChip
              key={person.id}
              person={person}
              isActive={person.id === selectedPerson.id}
              onPress={() => selectPerson(person)}
            />
          ))}
        </View>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Contextual notes</Text>
        <Text style={styles.sectionSubtitle}>
          Choose the interaction setting. The prompt style changes with the
          social tempo and the amount of time you realistically have.
        </Text>
        <View style={styles.contextGrid}>
          {selectedPerson.contexts.map((context) => (
            <ContextCard
              key={context.id}
              item={context}
              isActive={context.id === selectedContext.id}
              onPress={() => setSelectedContextId(context.id)}
            />
          ))}
        </View>
        <View style={styles.notesCard}>
          <Text style={styles.notesTitle}>{selectedPerson.name}</Text>
          <Text style={styles.notesSubhead}>{selectedPerson.role}</Text>
          <Text style={styles.notesMeta}>
            {selectedPerson.lastSeen} | {selectedPerson.relationship}
          </Text>
          <View style={styles.divider} />
          <NoteRow label="Recognition cue" value={selectedPerson.identityCue} />
          <NoteRow label="Pronunciation" value={selectedPerson.pronunciation} />
          <NoteRow label="Best opener" value={selectedPerson.opener} />
          <NoteRow label="Follow-up" value={selectedPerson.followUp} />
          <NoteRow label="Avoid" value={selectedPerson.avoid} />
          <NoteRow label="Scene tactic" value={selectedContext.cue} />
        </View>
        <View style={styles.anchorCard}>
          <Text style={styles.anchorTitle}>Memory anchors</Text>
          {selectedPerson.anchors.map((anchor) => (
            <View key={anchor} style={styles.anchorRow}>
              <View style={styles.anchorDot} />
              <Text style={styles.anchorText}>{anchor}</Text>
            </View>
          ))}
          <View style={styles.topicWrap}>
            {selectedPerson.topics.map((topic) => (
              <View key={topic} style={styles.topicTag}>
                <Text style={styles.topicTagText}>{topic}</Text>
              </View>
            ))}
          </View>
        </View>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Backstage companion feed</Text>
        <Text style={styles.sectionSubtitle}>
          Tap any incoming cue to pin it to the wearable view. Feed items stay
          short because someone backstage is usually typing under pressure.
        </Text>
        <View style={styles.feedList}>
          {selectedPerson.backstageFeed.map((item) => (
            <FeedCard
              key={item.id}
              item={item}
              isActive={item.id === selectedPrompt.id}
              onPress={() => setSelectedPromptId(item.id)}
            />
          ))}
        </View>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Watch / AR preview</Text>
        <Text style={styles.sectionSubtitle}>
          This is the glanceable version: the smallest useful prompt that still
          helps you recover a name, a safe opener, and one thing not to say.
        </Text>
        <View style={styles.previewShell}>
          <View style={styles.previewHeader}>
            <Text style={styles.previewTitle}>Prompt pulse</Text>
            <Text style={styles.previewStatus}>Haptic burst ready</Text>
          </View>
          {previewLines.map((line) => (
            <Text key={line} style={styles.previewLine}>
              {line}
            </Text>
          ))}
        </View>
        <View style={styles.previewFooter}>
          <View style={styles.previewFootCard}>
            <Text style={styles.previewFootLabel}>Suggested first sentence</Text>
            <Text style={styles.previewFootValue}>{selectedPerson.opener}</Text>
          </View>
          <View style={styles.previewFootCard}>
            <Text style={styles.previewFootLabel}>Why this works</Text>
            <Text style={styles.previewFootValue}>{selectedContext.goal}</Text>
          </View>
        </View>
      </View>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  screen: {
    flex: 1,
    backgroundColor: "#F4EFE7",
  },
  content: {
    padding: 20,
    paddingBottom: 28,
    gap: 18,
  },
  heroCard: {
    backgroundColor: "#143A52",
    borderRadius: 28,
    padding: 20,
    gap: 14,
    shadowColor: "#0F2230",
    shadowOffset: { width: 0, height: 10 },
    shadowOpacity: 0.18,
    shadowRadius: 18,
    elevation: 6,
  },
  heroHeader: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "flex-start",
    gap: 12,
  },
  eyebrow: {
    color: "#9FD1E7",
    fontSize: 12,
    fontWeight: "700",
    letterSpacing: 1,
    textTransform: "uppercase",
  },
  heroTitle: {
    color: "#FFFFFF",
    fontSize: 28,
    lineHeight: 34,
    fontWeight: "800",
    marginTop: 8,
    maxWidth: 260,
  },
  liveBadge: {
    backgroundColor: "#EFD7A7",
    borderRadius: 999,
    paddingHorizontal: 12,
    paddingVertical: 8,
  },
  liveBadgeText: {
    color: "#5A4319",
    fontSize: 12,
    fontWeight: "700",
  },
  heroBody: {
    color: "#D6E4EB",
    fontSize: 14,
    lineHeight: 21,
  },
  heroStats: {
    flexDirection: "row",
    flexWrap: "wrap",
    gap: 10,
  },
  statPill: {
    backgroundColor: "#214C68",
    borderRadius: 18,
    paddingHorizontal: 12,
    paddingVertical: 10,
    minWidth: 96,
  },
  statLabel: {
    color: "#9FD1E7",
    fontSize: 11,
    fontWeight: "700",
    textTransform: "uppercase",
    marginBottom: 4,
  },
  statValue: {
    color: "#FFFFFF",
    fontSize: 14,
    fontWeight: "700",
  },
  section: {
    gap: 12,
  },
  sectionTitle: {
    color: "#173042",
    fontSize: 22,
    fontWeight: "800",
  },
  sectionSubtitle: {
    color: "#50626F",
    fontSize: 14,
    lineHeight: 20,
  },
  personList: {
    gap: 10,
  },
  personChip: {
    backgroundColor: "#FBF8F2",
    borderRadius: 24,
    borderWidth: 1,
    borderColor: "#D9CDC0",
    padding: 14,
    flexDirection: "row",
    alignItems: "center",
    gap: 12,
  },
  personChipActive: {
    backgroundColor: "#1E5A80",
    borderColor: "#1E5A80",
  },
  personAvatar: {
    width: 42,
    height: 42,
    borderRadius: 21,
    backgroundColor: "#E6D8C7",
    alignItems: "center",
    justifyContent: "center",
  },
  personInitials: {
    color: "#173042",
    fontSize: 16,
    fontWeight: "800",
  },
  personChipText: {
    flex: 1,
    gap: 4,
  },
  personName: {
    color: "#173042",
    fontSize: 16,
    fontWeight: "800",
  },
  personNameActive: {
    color: "#FFFFFF",
  },
  personRole: {
    color: "#5A6B77",
    fontSize: 13,
  },
  personRoleActive: {
    color: "#D9EBF4",
  },
  contextGrid: {
    gap: 10,
  },
  contextCard: {
    backgroundColor: "#FBF8F2",
    borderRadius: 22,
    padding: 16,
    borderWidth: 1,
    borderColor: "#D9CDC0",
    gap: 8,
  },
  contextCardActive: {
    backgroundColor: "#E9F4FA",
    borderColor: "#7FB2CE",
  },
  contextLabel: {
    color: "#173042",
    fontSize: 16,
    fontWeight: "800",
    textTransform: "capitalize",
  },
  contextLabelActive: {
    color: "#0D5378",
  },
  contextSetting: {
    color: "#50626F",
    fontSize: 13,
    lineHeight: 18,
  },
  contextSettingActive: {
    color: "#375668",
  },
  contextGoal: {
    color: "#7C5C29",
    fontSize: 13,
    lineHeight: 18,
  },
  contextGoalActive: {
    color: "#8A5E12",
  },
  notesCard: {
    backgroundColor: "#FFFDF9",
    borderRadius: 24,
    padding: 18,
    borderWidth: 1,
    borderColor: "#E3D8CC",
    gap: 10,
  },
  notesTitle: {
    color: "#173042",
    fontSize: 20,
    fontWeight: "800",
  },
  notesSubhead: {
    color: "#355165",
    fontSize: 14,
    fontWeight: "700",
  },
  notesMeta: {
    color: "#61717C",
    fontSize: 13,
    lineHeight: 18,
  },
  divider: {
    height: 1,
    backgroundColor: "#E9DFD3",
    marginVertical: 2,
  },
  noteRow: {
    gap: 4,
  },
  noteLabel: {
    color: "#7C5C29",
    fontSize: 12,
    fontWeight: "700",
    textTransform: "uppercase",
    letterSpacing: 0.6,
  },
  noteValue: {
    color: "#173042",
    fontSize: 14,
    lineHeight: 20,
  },
  anchorCard: {
    backgroundColor: "#EFE6D9",
    borderRadius: 22,
    padding: 16,
    gap: 10,
  },
  anchorTitle: {
    color: "#173042",
    fontSize: 17,
    fontWeight: "800",
  },
  anchorRow: {
    flexDirection: "row",
    alignItems: "flex-start",
    gap: 10,
  },
  anchorDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: "#1E5A80",
    marginTop: 6,
  },
  anchorText: {
    flex: 1,
    color: "#304754",
    fontSize: 14,
    lineHeight: 20,
  },
  topicWrap: {
    flexDirection: "row",
    flexWrap: "wrap",
    gap: 8,
    marginTop: 4,
  },
  topicTag: {
    backgroundColor: "#FFF7EA",
    borderRadius: 999,
    paddingHorizontal: 12,
    paddingVertical: 8,
  },
  topicTagText: {
    color: "#7A5315",
    fontSize: 12,
    fontWeight: "700",
  },
  feedList: {
    gap: 10,
  },
  feedCard: {
    backgroundColor: "#FCFBF8",
    borderRadius: 22,
    padding: 16,
    borderWidth: 1,
    borderColor: "#DDD2C6",
    gap: 10,
  },
  feedCardActive: {
    borderColor: "#1E5A80",
    backgroundColor: "#EEF7FC",
  },
  feedHeader: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    gap: 10,
  },
  feedBadge: {
    color: "#0D5378",
    fontSize: 12,
    fontWeight: "800",
    textTransform: "uppercase",
    letterSpacing: 0.6,
  },
  feedAge: {
    color: "#6D7E8A",
    fontSize: 12,
    fontWeight: "700",
  },
  feedText: {
    color: "#173042",
    fontSize: 15,
    lineHeight: 22,
  },
  feedMeta: {
    color: "#627480",
    fontSize: 12,
  },
  previewShell: {
    backgroundColor: "#091720",
    borderRadius: 28,
    padding: 18,
    gap: 10,
    borderWidth: 1,
    borderColor: "#2E556B",
  },
  previewHeader: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    gap: 10,
    marginBottom: 6,
  },
  previewTitle: {
    color: "#FFFFFF",
    fontSize: 18,
    fontWeight: "800",
  },
  previewStatus: {
    color: "#7ED6A8",
    fontSize: 12,
    fontWeight: "700",
  },
  previewLine: {
    color: "#DCECF4",
    fontSize: 14,
    lineHeight: 20,
  },
  previewFooter: {
    gap: 10,
  },
  previewFootCard: {
    backgroundColor: "#FBF8F2",
    borderRadius: 20,
    padding: 16,
    borderWidth: 1,
    borderColor: "#E3D8CC",
    gap: 8,
  },
  previewFootLabel: {
    color: "#7C5C29",
    fontSize: 12,
    fontWeight: "700",
    textTransform: "uppercase",
    letterSpacing: 0.6,
  },
  previewFootValue: {
    color: "#173042",
    fontSize: 14,
    lineHeight: 20,
  },
});

export default {
  id: "nomenclator",
  shortLabel: "Nomenclator",
  kicker: "Plan 4",
  title: "Nomenclator",
  tagline: "Shared recall prompts for live social encounters.",
  summary: "Mobile companion-memory demo for discreet live social recall.",
  meta: ["Memory support", "Wearables", "Companion mode"],
  accent: "#26638E",
  Component: NomenclatorScreen,
};

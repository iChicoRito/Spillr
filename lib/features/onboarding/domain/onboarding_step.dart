class OnboardingIntroStep {
  const OnboardingIntroStep({
    required this.titlePrimary,
    required this.titleAccent,
    required this.subtitle,
    required this.ctaLabel,
  });

  final String titlePrimary;
  final String titleAccent;
  final String subtitle;
  final String ctaLabel;
}

const onboardingIntroSteps = [
  OnboardingIntroStep(
    titlePrimary: 'Vibe',
    titleAccent: 'Check',
    subtitle: 'Awkward silence gets cancelled before it even starts, bestie.',
    ctaLabel: 'Okay',
  ),
  OnboardingIntroStep(
    titlePrimary: 'Tea',
    titleAccent: 'Time',
    subtitle:
        'Pick a card and let the group reveal their funniest, weirdest lore.',
    ctaLabel: 'It sounds fun',
  ),
  OnboardingIntroStep(
    titlePrimary: 'Main',
    titleAccent: 'Character',
    subtitle: 'Play with friends, dates, or anyone brave enough to answer.',
    ctaLabel: 'Start Spilling',
  ),
];

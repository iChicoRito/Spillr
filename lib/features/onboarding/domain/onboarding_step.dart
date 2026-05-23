class OnboardingIntroStep {
  const OnboardingIntroStep({
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
  });

  final String title;
  final String subtitle;
  final String ctaLabel;
}

const onboardingIntroSteps = [
  OnboardingIntroStep(
    title: 'Vibe Check',
    subtitle: 'Awkward silence gets cancelled before it even starts, bestie.',
    ctaLabel: 'Okay',
  ),
  OnboardingIntroStep(
    title: 'Tea Time',
    subtitle:
        'Pick a card and let the group reveal their funniest, weirdest lore.',
    ctaLabel: 'It sounds fun',
  ),
  OnboardingIntroStep(
    title: 'Main Character',
    subtitle: 'Play with friends, dates, or anyone brave enough to answer.',
    ctaLabel: 'Start Spilling',
  ),
];

// Re-export for backward compatibility
// This file maintains the original public API while the implementation
// has been split into modular components in the personality_dna/ directory

export 'personality_dna/personality_dna_page_impl.dart';

// For convenience, also provide the original class name as an alias
import 'personality_dna/personality_dna_page_impl.dart';

typedef PersonalityDNAPage = PersonalityDNAPageImpl;

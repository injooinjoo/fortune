#!/usr/bin/env python3

from __future__ import annotations

import argparse
import difflib
import json
import os
import re
import subprocess
import sys
from collections import Counter, defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
INCLUDE_DIRTY = os.environ.get('SOURCE_INVENTORY_INCLUDE_DIRTY') == '1'

INVENTORY_PREFIXES = (
    'lib/',
    'assets/',
    'supabase/',
    'scripts/',
    'docs/',
    'test/',
    'integration_test/',
)
INPUT_PREFIXES = (
    '.github/workflows/',
    'web/',
    'android/',
    'ios/',
    'macos/',
)
INPUT_FILES = (
    'pubspec.yaml',
    'README.md',
    'l10n.yaml',
)

FILE_INVENTORY_PATH = 'docs/development/FILE_INVENTORY.md'
UNUSED_CANDIDATES_PATH = 'docs/development/UNUSED_CANDIDATES.md'
MANIFEST_PATH = 'artifacts/file_inventory.json'
GENERATED_OUTPUTS = {
    FILE_INVENTORY_PATH,
    UNUSED_CANDIDATES_PATH,
    MANIFEST_PATH,
}

TEXT_SUFFIXES = {
    '.dart',
    '.ts',
    '.tsx',
    '.js',
    '.jsx',
    '.mjs',
    '.cjs',
    '.py',
    '.sh',
    '.sql',
    '.md',
    '.txt',
    '.yml',
    '.yaml',
    '.json',
    '.html',
    '.xml',
    '.plist',
    '.swift',
    '.gradle',
    '.kts',
    '.pbxproj',
    '.xcconfig',
    '.toml',
    '.cfg',
    '.ini',
    '.arb',
}
TEXT_FILENAMES = {
    'Podfile',
    '.gitignore',
    '.claudeignore',
    '.metadata',
}
SOURCE_MODULE_SUFFIXES = ('.dart', '.ts', '.tsx', '.js', '.jsx', '.mjs', '.cjs')
TS_JS_SUFFIXES = ('.ts', '.tsx', '.js', '.jsx', '.mjs', '.cjs')
LEGACY_HINTS = (
    '_old',
    '.old',
    '.backup',
    '_backup',
    '_unused',
    'unused_',
    'pages_unused',
    'legacy',
    '_renewed',
    '_enhanced',
)
GENERATED_PATTERNS = (
    re.compile(r'\.g\.dart$'),
    re.compile(r'\.freezed\.dart$'),
    re.compile(r'^lib/l10n/app_localizations(?:_[a-z]{2})?\.dart$'),
    re.compile(r'^docs/development/(?:FILE_INVENTORY|UNUSED_CANDIDATES)\.md$'),
    re.compile(r'^supabase/\.temp/cli-latest$'),
)

DART_DIRECTIVE_RE = re.compile(r'^\s*(?:import|export|part)\b[\s\S]*?;', re.MULTILINE)
QUOTED_URI_RE = re.compile(r'[\'"]([^\'"]+)[\'"]')
MODULE_IMPORT_RE = re.compile(
    r'(?:import|export)\s+(?:[^\'"]*?\s+from\s+)?[\'"]([^\'"]+)[\'"]|'
    r'require\(\s*[\'"]([^\'"]+)[\'"]\s*\)'
)
ASSET_REF_RE = re.compile(r'assets/[A-Za-z0-9_./@+-]+\.[A-Za-z0-9]+')
PATH_REF_RE = re.compile(
    r'(?<![A-Za-z0-9_./-])(?:\./)?'
    r'((?:lib|assets|supabase|scripts|docs|test|integration_test|'
    r'\.github/workflows|web|android|ios|macos)/[A-Za-z0-9_./@+-]+)'
)
MARKDOWN_LINK_RE = re.compile(r'\[[^\]]*\]\(([^)#]+)')
FUNCTION_INVOKE_RE = re.compile(r'functions\.invoke\(\s*[\'"]([a-z0-9-]+)[\'"]')
FUNCTION_INVOKE_VAR_RE = re.compile(
    r'functions\.invoke\(\s*([A-Za-z_][A-Za-z0-9_]*)\s*(?:,|\))'
)
FUNCTION_ASSIGN_LITERAL_RE = re.compile(
    r'\b(?:final|const|var|String)\s+([A-Za-z_][A-Za-z0-9_]*)\s*=\s*[\'"]([a-z0-9-]+)[\'"]\s*;'
)
FUNCTION_ASSIGN_TERNARY_RE = re.compile(
    r'\b(?:final|const|var|String)\s+([A-Za-z_][A-Za-z0-9_]*)\s*=\s*[^;]*\?\s*[\'"]([a-z0-9-]+)[\'"]\s*:\s*[\'"]([a-z0-9-]+)[\'"]\s*;'
)
ENDPOINT_LITERAL_RE = re.compile(r'[\'"](/(?:[a-z0-9-]+))[\'"]')
FUNCTIONS_V1_LITERAL_RE = re.compile(r'functions/v1/([a-z0-9-]+)')
SUPABASE_FUNCTION_DEPLOY_RE = re.compile(
    r'supabase\s+functions\s+(?:deploy|serve)\s+([a-z0-9-]+)'
)
DYNAMIC_FAMILY_ENDPOINT_RE = re.compile(r'fortune-family-\$[A-Za-z_][A-Za-z0-9_]*')


def run_git(*args: str) -> str:
    result = subprocess.run(
        ['git', *args],
        cwd=ROOT,
        check=True,
        capture_output=True,
        text=True,
    )
    return result.stdout


def posix_relative(path: Path) -> str:
    return path.relative_to(ROOT).as_posix()


def is_generated_path(path: str) -> bool:
    if path in GENERATED_OUTPUTS:
        return True
    return any(pattern.search(path) for pattern in GENERATED_PATTERNS)


def is_text_file(path: str) -> bool:
    suffix = Path(path).suffix.lower()
    return suffix in TEXT_SUFFIXES or Path(path).name in TEXT_FILENAMES


def read_text(path: str, dirty_paths: set[str]) -> str | None:
    if not is_text_file(path):
        return None

    if not INCLUDE_DIRTY and path in dirty_paths and not path.startswith('docs/development/'):
        result = subprocess.run(
            ['git', 'show', f':{path}'],
            cwd=ROOT,
            check=True,
            capture_output=True,
        )
        return result.stdout.decode('utf-8', errors='ignore')

    file_path = ROOT / path
    if not file_path.exists():
        return None
    try:
        return file_path.read_text(encoding='utf-8')
    except UnicodeDecodeError:
        return file_path.read_text(encoding='utf-8', errors='ignore')


def tracked_and_untracked_paths() -> list[str]:
    args = ['ls-files', '--cached']
    if INCLUDE_DIRTY:
        args.extend(['--others', '--exclude-standard'])
    args.append('-z')
    raw = run_git(*args)
    seen: set[str] = set()
    paths: list[str] = []
    for path in raw.split('\0'):
        if not path:
            continue
        if path in seen:
            continue
        seen.add(path)
        paths.append(path)
    return sorted(paths)


def dirty_status_map() -> dict[str, str]:
    raw = run_git('status', '--porcelain=v1', '-z')
    parts = raw.split('\0')
    dirty: dict[str, str] = {}
    index = 0
    while index < len(parts):
        entry = parts[index]
        if not entry:
            break
        status = entry[:2]
        path = entry[3:]
        dirty[path] = status.strip() or '??'
        if 'R' in status or 'C' in status:
            index += 1
            if index < len(parts) and parts[index]:
                dirty[parts[index]] = status.strip() or '??'
        index += 1
    return dirty


def inventory_paths(all_paths: list[str]) -> list[str]:
    result = []
    for path in all_paths:
        if any(path.startswith(prefix) for prefix in INVENTORY_PREFIXES):
            result.append(path)
    return sorted(result)


def input_paths(all_paths: list[str]) -> list[str]:
    result = []
    for path in all_paths:
        if any(path.startswith(prefix) for prefix in INPUT_PREFIXES) or path in INPUT_FILES:
            result.append(path)
    return sorted(result)


def path_exists(path: str) -> bool:
    if not INCLUDE_DIRTY:
        return True
    return (ROOT / path).exists()


def parse_pubspec_asset_entries(pubspec_text: str) -> list[str]:
    lines = pubspec_text.splitlines()
    in_flutter = False
    in_assets = False
    flutter_indent = 0
    assets_indent = 0
    results: list[str] = []
    for line in lines:
        stripped = line.strip()
        if not stripped or stripped.startswith('#'):
            continue
        indent = len(line) - len(line.lstrip(' '))
        if not in_flutter and stripped == 'flutter:':
            in_flutter = True
            flutter_indent = indent
            continue
        if in_flutter and indent <= flutter_indent and stripped.endswith(':') and stripped != 'flutter:':
            in_flutter = False
            in_assets = False
        if not in_flutter:
            continue
        if not in_assets and stripped == 'assets:':
            in_assets = True
            assets_indent = indent
            continue
        if in_assets and indent <= assets_indent and not stripped.startswith('- '):
            in_assets = False
        if in_assets and stripped.startswith('- '):
            value = stripped[2:].split('#', 1)[0].strip()
            if value:
                results.append(value.rstrip('/'))
    return results


def asset_declarations(pubspec_text: str) -> tuple[set[str], dict[str, str]]:
    entries = parse_pubspec_asset_entries(pubspec_text)
    declared: set[str] = set()
    owner: dict[str, str] = {}
    for entry in entries:
        path = ROOT / entry
        if entry.startswith('assets/') and path.exists():
            if path.is_dir():
                for file_path in path.rglob('*'):
                    if file_path.is_file():
                        rel = posix_relative(file_path)
                        declared.add(rel)
                        owner[rel] = entry
            elif path.is_file():
                declared.add(entry)
                owner[entry] = entry
    return declared, owner


def resolve_repo_path(base_path: str, target: str) -> str | None:
    normalized = target.split('#', 1)[0].split('?', 1)[0]
    if not normalized or normalized.startswith(('http://', 'https://', 'mailto:')):
        return None
    if normalized.startswith('/'):
        try:
            rel = Path(normalized).resolve().relative_to(ROOT)
            return rel.as_posix()
        except ValueError:
            return None
    try:
        rel = (ROOT / base_path).parent.joinpath(normalized).resolve().relative_to(ROOT)
    except ValueError:
        return None
    return rel.as_posix()


def resolve_module_target(source: str, target: str, known_paths: set[str]) -> str | None:
    source_suffix = Path(source).suffix.lower()
    if target.startswith('package:fortune/'):
        candidate = target.replace('package:fortune/', 'lib/')
        return candidate if candidate in known_paths else None
    if target.startswith('package:'):
        return None
    is_relative_dart_import = source_suffix == '.dart' and not target.startswith('/')
    if target.startswith(('.', '..', '/')) or is_relative_dart_import:
        direct = resolve_repo_path(source, target)
        if direct and direct in known_paths:
            return direct
        if Path(target).suffix:
            return None
        base = resolve_repo_path(source, target)
        if not base:
            return None
        stem = Path(base)
        candidates = [stem]
        candidates.extend(stem.with_suffix(suffix) for suffix in SOURCE_MODULE_SUFFIXES)
        candidates.extend(stem.joinpath(f'index{suffix}') for suffix in SOURCE_MODULE_SUFFIXES)
        for candidate in candidates:
            candidate_path = candidate.as_posix()
            if candidate_path in known_paths:
                return candidate_path
    return None


def top_level_asset_dir(path: str) -> str:
    parts = Path(path).parts
    if len(parts) >= 2:
        return f'{parts[0]}/{parts[1]}'
    return path


def file_kind(path: str) -> str:
    suffix = Path(path).suffix.lower()
    if path in GENERATED_OUTPUTS:
        return 'generated_output'
    if path.startswith('lib/'):
        return 'dart' if suffix == '.dart' else f'lib_{suffix.lstrip(".") or "file"}'
    if path.startswith('assets/'):
        return f'asset_{suffix.lstrip(".") or "file"}'
    if path.startswith('supabase/functions/_shared/'):
        return 'edge_shared_source'
    if path.startswith('supabase/functions/'):
        return 'edge_function_source'
    if path.startswith('supabase/migrations/'):
        return 'supabase_migration'
    if path.startswith('supabase/'):
        return 'supabase_support'
    if path.startswith('scripts/'):
        return f'script_{suffix.lstrip(".") or "file"}'
    if path.startswith('docs/'):
        return 'doc_markdown' if suffix == '.md' else f'doc_{suffix.lstrip(".") or "file"}'
    if path.startswith(('test/', 'integration_test/')):
        return 'test_dart' if suffix == '.dart' else f'test_{suffix.lstrip(".") or "file"}'
    return suffix.lstrip('.') or 'file'


def file_area(path: str) -> str:
    parts = Path(path).parts
    return parts[0] if parts else ''


def explicit_legacy(path: str) -> bool:
    lowered = path.lower()
    if lowered.endswith(('.g.dart', '.freezed.dart')):
        return False
    return any(token in lowered for token in LEGACY_HINTS)


def source_usage_context(path: str) -> str:
    if path.startswith(('test/', 'integration_test/')):
        return 'test'
    if path.startswith('docs/'):
        return 'doc'
    if path.startswith('scripts/'):
        return 'tooling'
    if path.startswith(('.github/workflows/', 'web/', 'android/', 'ios/', 'macos/')):
        return 'tooling'
    if path.startswith('supabase/migrations/'):
        return 'tooling'
    if path.startswith('supabase/functions/'):
        return 'runtime'
    if path.startswith('lib/'):
        return 'runtime'
    return 'tooling'


def first_non_generated_ref(referrers: set[str]) -> list[str]:
    return sorted(ref for ref in referrers if ref not in GENERATED_OUTPUTS)


def build_analysis() -> dict[str, object]:
    all_paths = tracked_and_untracked_paths()
    working_dirty_map = dirty_status_map()
    dirty_map = working_dirty_map if INCLUDE_DIRTY else {}
    inventory = inventory_paths(all_paths)
    extra_inputs = input_paths(all_paths)
    inventory_lookup = set(inventory)
    scan_inputs = sorted(set(inventory + extra_inputs))

    texts: dict[str, str] = {}
    dirty_paths_for_snapshot = set(working_dirty_map)
    for path in scan_inputs:
        if path in GENERATED_OUTPUTS:
            continue
        content = read_text(path, dirty_paths_for_snapshot)
        if content is not None:
            texts[path] = content

    pubspec_text = texts.get('pubspec.yaml', '')
    declared_assets, declared_asset_owner = asset_declarations(pubspec_text)

    references: dict[str, set[str]] = defaultdict(set)
    dart_outgoing: dict[str, set[str]] = defaultdict(set)
    dart_incoming: dict[str, set[str]] = defaultdict(set)
    module_outgoing: dict[str, set[str]] = defaultdict(set)
    function_referrers: dict[str, set[str]] = defaultdict(set)

    for source, text in texts.items():
        suffix = Path(source).suffix.lower()
        function_name_vars: dict[str, set[str]] = defaultdict(set)
        if suffix == '.dart':
            for directive in DART_DIRECTIVE_RE.findall(text):
                for target in QUOTED_URI_RE.findall(directive):
                    resolved = resolve_module_target(source, target, inventory_lookup)
                    if not resolved:
                        continue
                    references[resolved].add(source)
                    dart_outgoing[source].add(resolved)
                    dart_incoming[resolved].add(source)
        elif suffix in TS_JS_SUFFIXES:
            for raw_target, raw_require in MODULE_IMPORT_RE.findall(text):
                target = raw_target or raw_require
                resolved = resolve_module_target(source, target, inventory_lookup)
                if not resolved:
                    continue
                references[resolved].add(source)
                module_outgoing[source].add(resolved)

        for asset_path in ASSET_REF_RE.findall(text):
            if asset_path in inventory_lookup:
                references[asset_path].add(source)

        for token in PATH_REF_RE.findall(text):
            cleaned = token.rstrip('.,);:`\'"')
            if cleaned in inventory_lookup:
                references[cleaned].add(source)

        if suffix == '.md':
            for link in MARKDOWN_LINK_RE.findall(text):
                resolved = resolve_repo_path(source, link)
                if resolved and resolved in inventory_lookup:
                    references[resolved].add(source)

        for function_name in FUNCTION_INVOKE_RE.findall(text):
            function_referrers[function_name].add(source)

        for variable_name, function_name in FUNCTION_ASSIGN_LITERAL_RE.findall(text):
            function_name_vars[variable_name].add(function_name)

        for variable_name, when_true, when_false in FUNCTION_ASSIGN_TERNARY_RE.findall(text):
            function_name_vars[variable_name].update({when_true, when_false})

        for variable_name in FUNCTION_INVOKE_VAR_RE.findall(text):
            for function_name in function_name_vars.get(variable_name, set()):
                function_referrers[function_name].add(source)

        for literal in ENDPOINT_LITERAL_RE.findall(text):
            function_name = literal.lstrip('/')
            if function_name and '-' in function_name and not function_name.endswith('-'):
                function_referrers[function_name].add(source)

        for function_name in FUNCTIONS_V1_LITERAL_RE.findall(text):
            function_referrers[function_name].add(source)

        for function_name in SUPABASE_FUNCTION_DEPLOY_RE.findall(text):
            function_referrers[function_name].add(source)

    runtime_dart_seen: set[str] = set()
    stack = ['lib/main.dart']
    while stack:
        current = stack.pop()
        if current in runtime_dart_seen:
            continue
        runtime_dart_seen.add(current)
        stack.extend(sorted(dart_outgoing.get(current, set()) - runtime_dart_seen))

    function_dirs: dict[str, list[str]] = defaultdict(list)
    for path in inventory:
        if path.startswith('supabase/functions/'):
            parts = Path(path).parts
            if len(parts) >= 3 and parts[2] != '_shared':
                function_dirs[parts[2]].append(path)

    for source, text in texts.items():
        if DYNAMIC_FAMILY_ENDPOINT_RE.search(text):
            for function_name in function_dirs:
                if function_name.startswith('fortune-family-'):
                    function_referrers[function_name].add(source)

    referenced_function_dirs = {
        function_name
        for function_name, referrers in function_referrers.items()
        if function_name in function_dirs and referrers
    }

    runtime_function_dirs = {
        function_name
        for function_name, referrers in function_referrers.items()
        if function_name in function_dirs
        and any(source_usage_context(referrer) == 'runtime' for referrer in referrers)
    }

    for function_name, referrers in function_referrers.items():
        if function_name not in function_dirs:
            continue
        for target in function_dirs[function_name]:
            references[target].update(referrers)

    runtime_supabase_seen: set[str] = set()
    supabase_stack: list[str] = []
    for function_name in sorted(runtime_function_dirs):
        supabase_stack.extend(sorted(function_dirs[function_name]))
    while supabase_stack:
        current = supabase_stack.pop()
        if current in runtime_supabase_seen:
            continue
        runtime_supabase_seen.add(current)
        supabase_stack.extend(
            sorted(module_outgoing.get(current, set()) - runtime_supabase_seen)
        )

    def ref_context(referrer: str) -> str:
        if referrer.startswith('supabase/functions/'):
            return 'runtime' if referrer in runtime_supabase_seen else 'tooling'
        return source_usage_context(referrer)

    missing_function_refs = sorted(
        function_name
        for function_name in function_referrers
        if function_name not in function_dirs
    )
    unreferenced_function_dirs = sorted(
        function_name
        for function_name in function_dirs
        if function_name not in referenced_function_dirs
    )

    records: list[dict[str, object]] = []
    for path in sorted(inventory):
        refs = first_non_generated_ref(references.get(path, set()))
        contexts = {ref_context(referrer) for referrer in refs}
        exists = path_exists(path)
        area = file_area(path)
        kind = file_kind(path)
        dirty = path in dirty_map
        runtime_reachable = False
        notes: list[str] = []

        if path == 'lib/main.dart':
            runtime_reachable = True
            notes.append('runtime_root')
        elif path.startswith('lib/'):
            runtime_reachable = path in runtime_dart_seen
        elif path.startswith('assets/'):
            runtime_reachable = 'runtime' in contexts
        elif path.startswith('supabase/functions/'):
            runtime_reachable = path in runtime_supabase_seen

        if is_generated_path(path):
            usage_status = 'generated_excluded'
            notes.append('generated_or_generated_output')
        elif dirty:
            usage_status = 'dirty_conflict'
            notes.append(f'dirty_status:{dirty_map[path]}')
        elif path.startswith('lib/l10n/') and Path(path).suffix.lower() == '.arb':
            usage_status = 'runtime_used'
            notes.append('l10n_source')
        elif area == 'docs' or Path(path).suffix.lower() == '.md':
            usage_status = 'doc_only'
        elif area in {'test', 'integration_test'}:
            usage_status = 'test_only'
        elif area == 'scripts' or path.startswith('supabase/migrations/'):
            usage_status = 'tooling_only'
        elif runtime_reachable or 'runtime' in contexts:
            usage_status = 'runtime_used'
        elif contexts == {'test'}:
            usage_status = 'test_only'
        elif 'test' in contexts and contexts <= {'doc', 'test'}:
            usage_status = 'test_only'
        elif contexts == {'doc'}:
            usage_status = 'doc_only'
        elif contexts and contexts <= {'doc', 'tooling'}:
            usage_status = 'tooling_only'
        else:
            usage_status = 'unreferenced'

        if not exists:
            notes.append('tracked_path_missing_on_disk')
        if explicit_legacy(path):
            notes.append('explicit_legacy_name')
        if path.startswith('lib/') and not is_generated_path(path):
            incoming_count = len(first_non_generated_ref(dart_incoming.get(path, set())))
            if incoming_count == 0 and path != 'lib/main.dart':
                notes.append('zero_incoming_dart')
            if not runtime_reachable:
                notes.append('runtime_unreachable')
        if path in declared_assets:
            notes.append(f'pubspec_declared:{declared_asset_owner[path]}')
        if path.startswith('assets/') and top_level_asset_dir(path) == 'assets/avatar':
            notes.append('top_level_asset_dir_not_declared_in_pubspec')
        if area == 'docs' and '/_archive/' in path:
            notes.append('archive_doc')
        if path.startswith('supabase/functions/'):
            parts = Path(path).parts
            if len(parts) >= 3 and parts[2] != '_shared':
                function_name = parts[2]
                if function_name in runtime_function_dirs:
                    notes.append(f'edge_function_ref:{function_name}')
                elif function_name in referenced_function_dirs:
                    notes.append(f'edge_function_non_runtime_ref:{function_name}')
                else:
                    notes.append(f'edge_function_unreferenced:{function_name}')
        if not refs:
            notes.append('no_inbound_refs')

        if usage_status == 'dirty_conflict':
            candidate_action = 'keep_dirty'
        elif usage_status == 'generated_excluded':
            candidate_action = 'keep_generated'
        elif usage_status == 'runtime_used':
            candidate_action = 'keep'
        elif usage_status in {'test_only', 'tooling_only', 'doc_only'}:
            candidate_action = 'phase2_review_candidate'
        elif path.startswith('assets/') and path not in declared_assets:
            candidate_action = 'phase1_remove_candidate'
        elif path.startswith('assets/'):
            candidate_action = 'manual_review'
        elif path.startswith('supabase/functions/') and '/_shared/' not in path:
            candidate_action = 'manual_review'
        elif path.startswith('lib/') and (
            path.endswith('_page.dart')
            or '/pages/' in path
            or '/screens/' in path
            or '/services/' in path
            or '/providers/' in path
        ):
            candidate_action = 'phase3_feature_cleanup'
        else:
            candidate_action = 'phase1_remove_candidate'

        records.append(
            {
                'path': path,
                'area': area,
                'kind': kind,
                'usage_status': usage_status,
                'referenced_by': refs,
                'runtime_reachable': runtime_reachable,
                'test_only': usage_status == 'test_only',
                'dirty': dirty,
                'candidate_action': candidate_action,
                'notes': sorted(set(notes)),
            }
        )

    lib_dart_records = [
        record
        for record in records
        if record['path'].startswith('lib/') and record['kind'] == 'dart'
    ]
    zero_incoming_lib_dart = sum(
        1
        for record in lib_dart_records
        if 'zero_incoming_dart' in record['notes'] and record['path'] != 'lib/main.dart'
    )

    top_level_asset_dirs = sorted(
        posix_relative(path)
        for path in (ROOT / 'assets').iterdir()
        if path.is_dir()
    )
    declared_asset_top_levels = {
        '/'.join(entry.split('/')[:2])
        for entry in parse_pubspec_asset_entries(pubspec_text)
        if entry.startswith('assets/')
    }
    undeclared_asset_top_levels = sorted(
        asset_dir for asset_dir in top_level_asset_dirs if asset_dir not in declared_asset_top_levels
    )

    declared_asset_dir_runtime_counts: dict[str, int] = Counter()
    for record in records:
        path = record['path']
        if path in declared_asset_owner and record['usage_status'] == 'runtime_used':
            declared_asset_dir_runtime_counts[declared_asset_owner[path]] += 1
    declared_asset_dirs_without_runtime_refs = sorted(
        entry
        for entry in parse_pubspec_asset_entries(pubspec_text)
        if entry.startswith('assets/') and declared_asset_dir_runtime_counts[entry] == 0
    )

    summary = {
        'inventory_scope': [
            'lib',
            'assets',
            'supabase',
            'scripts',
            'docs',
            'test',
            'integration_test',
        ],
        'generated_outputs': sorted(GENERATED_OUTPUTS),
        'total_files': len(records),
        'counts_by_area': dict(sorted(Counter(record['area'] for record in records).items())),
        'counts_by_usage_status': dict(
            sorted(Counter(record['usage_status'] for record in records).items())
        ),
        'counts_by_candidate_action': dict(
            sorted(Counter(record['candidate_action'] for record in records).items())
        ),
        'lib_dart_total': len(lib_dart_records),
        'lib_dart_runtime_reachable': sum(
            1 for record in lib_dart_records if record['runtime_reachable']
        ),
        'lib_dart_zero_incoming': zero_incoming_lib_dart,
        'runtime_function_dirs': sorted(runtime_function_dirs),
        'unreferenced_function_dirs': unreferenced_function_dirs,
        'missing_function_refs': missing_function_refs,
        'undeclared_asset_top_levels': undeclared_asset_top_levels,
        'declared_asset_dirs_without_runtime_refs': declared_asset_dirs_without_runtime_refs,
    }

    return {
        'records': records,
        'summary': summary,
    }


def format_table(headers: list[str], rows: list[list[str]]) -> str:
    if not rows:
        return '_none_'
    table = ['| ' + ' | '.join(headers) + ' |', '| ' + ' | '.join(['---'] * len(headers)) + ' |']
    for row in rows:
        table.append('| ' + ' | '.join(row) + ' |')
    return '\n'.join(table)


def record_lookup(records: list[dict[str, object]]) -> dict[str, dict[str, object]]:
    return {record['path']: record for record in records}


def top_hubs(records: list[dict[str, object]], limit: int = 15) -> list[dict[str, object]]:
    filtered = [
        record
        for record in records
        if record['usage_status'] not in {'generated_excluded', 'dirty_conflict'}
    ]
    return sorted(
        filtered,
        key=lambda record: (-len(record['referenced_by']), record['path']),
    )[:limit]


def generate_file_inventory(records: list[dict[str, object]], summary: dict[str, object]) -> str:
    lines = [
        '# File Inventory',
        '',
        'Generated by `python3 scripts/source_inventory.py generate`. Do not edit by hand.',
        '',
        '## Scope',
        '',
        '- Inventory targets: `lib`, `assets`, `supabase`, `scripts`, `docs`, `test`, `integration_test`',
        '- Analysis inputs only: `pubspec.yaml`, `.github/workflows/`, `web/`, `android/`, `ios/`, `macos/`, `README.md`, `l10n.yaml`',
        '- Generated outputs use the tracked snapshot by default so CI and local `check` stay deterministic.',
        '- Local dirty view is opt-in via `SOURCE_INVENTORY_INCLUDE_DIRTY=1` and marks modified paths as `dirty_conflict`.',
        '',
        '## Baseline',
        '',
        f"- Total inventory files: `{summary['total_files']}`",
        f"- `lib` Dart files: `{summary['lib_dart_total']}`",
        f"- Runtime reachable from `lib/main.dart`: `{summary['lib_dart_runtime_reachable']}`",
        f"- Zero-incoming `lib` Dart files: `{summary['lib_dart_zero_incoming']}`",
        '',
        '## Usage Status',
        '',
        '- `runtime_used`: runtime or backend reachable from app or Edge Function entrypoints',
        '- `test_only`: referenced only from `test/` or `integration_test/`',
        '- `tooling_only`: only used by scripts, workflows, or deployment tooling',
        '- `doc_only`: documentation or documentation-only references',
        '- `unreferenced`: no runtime, test, tooling, or doc consumer was found',
        '- `generated_excluded`: generated files or generated outputs excluded from candidate decisions',
        '- `dirty_conflict`: currently modified, deleted, or untracked in the worktree',
        '',
        '## Counts By Area',
        '',
        format_table(
            ['Area', 'Files'],
            [
                [area, str(count)]
                for area, count in sorted(summary['counts_by_area'].items())
            ],
        ),
        '',
        '## Counts By Usage Status',
        '',
        format_table(
            ['Status', 'Files'],
            [
                [status, str(count)]
                for status, count in sorted(summary['counts_by_usage_status'].items())
            ],
        ),
        '',
        '## Top Hubs',
        '',
        format_table(
            ['Path', 'Referenced By', 'Status'],
            [
                [
                    f"`{record['path']}`",
                    str(len(record['referenced_by'])),
                    f"`{record['usage_status']}`",
                ]
                for record in top_hubs(records)
            ],
        ),
        '',
        '## Focus Checks',
        '',
        f"- Unreferenced Edge Function directories: `{len(summary['unreferenced_function_dirs'])}`",
        f"- Missing function references with no directory target: `{len(summary['missing_function_refs'])}`",
        f"- Undeclared top-level asset directories: `{len(summary['undeclared_asset_top_levels'])}`",
        f"- Declared asset directories with zero runtime refs: `{len(summary['declared_asset_dirs_without_runtime_refs'])}`",
        '',
        '## Exception Rules',
        '',
        '- Generated docs (`docs/development/FILE_INVENTORY.md`, `docs/development/UNUSED_CANDIDATES.md`) are tracked but excluded from reference scoring.',
        '- Generated Dart artifacts (`*.g.dart`, `*.freezed.dart`, generated localizations) are marked `generated_excluded`.',
        '- Dirty paths are preserved as `dirty_conflict` even when they also look removable.',
        '- Asset declarations from `pubspec.yaml` are treated as keep-signals, but declaration alone does not make an asset runtime-used.',
        '',
        '## Regeneration',
        '',
        '```bash',
        'python3 scripts/source_inventory.py generate',
        'python3 scripts/source_inventory.py check',
        'SOURCE_INVENTORY_INCLUDE_DIRTY=1 python3 scripts/source_inventory.py generate',
        '```',
        '',
    ]
    return '\n'.join(lines)


def render_candidate_rows(records: list[dict[str, object]], limit: int, action: str) -> list[list[str]]:
    chosen = [record for record in records if record['candidate_action'] == action]
    chosen.sort(key=lambda record: (record['area'], record['path']))
    rows: list[list[str]] = []
    for record in chosen[:limit]:
        note = ', '.join(record['notes'][:3]) if record['notes'] else '-'
        rows.append(
            [
                f"`{record['path']}`",
                f"`{record['usage_status']}`",
                str(len(record['referenced_by'])),
                note,
            ]
        )
    return rows


def focus_group_rows(records: list[dict[str, object]], predicate, limit: int = 20) -> list[list[str]]:
    chosen = [record for record in records if predicate(record)]
    chosen.sort(key=lambda record: record['path'])
    return [
        [
            f"`{record['path']}`",
            f"`{record['usage_status']}`",
            f"`{record['candidate_action']}`",
        ]
        for record in chosen[:limit]
    ]


def generate_unused_candidates(records: list[dict[str, object]], summary: dict[str, object]) -> str:
    lines = [
        '# Unused Candidates',
        '',
        'Generated by `python3 scripts/source_inventory.py generate`. Do not edit by hand.',
        '',
        '## Action Summary',
        '',
        format_table(
            ['Candidate Action', 'Files'],
            [
                [action, str(count)]
                for action, count in sorted(summary['counts_by_candidate_action'].items())
            ],
        ),
        '',
        '## Phase 1 Remove Candidates',
        '',
        'Immediate review list for `unreferenced` files, explicit legacy names, and undeclared/unreferenced assets.',
        '',
        format_table(
            ['Path', 'Status', 'Refs', 'Notes'],
            render_candidate_rows(records, 40, 'phase1_remove_candidate'),
        ),
        '',
        '## Phase 2 Review Candidates',
        '',
        'Files that are only used by tests, tooling, or documentation and may be removable after owner review.',
        '',
        format_table(
            ['Path', 'Status', 'Refs', 'Notes'],
            render_candidate_rows(records, 40, 'phase2_review_candidate'),
        ),
        '',
        '## Phase 3 Feature Cleanup Candidates',
        '',
        'Runtime-unreachable pages, screens, services, or providers that should be removed feature-by-feature.',
        '',
        format_table(
            ['Path', 'Status', 'Refs', 'Notes'],
            render_candidate_rows(records, 40, 'phase3_feature_cleanup'),
        ),
        '',
        '## Focus Groups',
        '',
        '### Duplicate Screen Layers',
        '',
        format_table(
            ['Path', 'Status', 'Action'],
            focus_group_rows(
                records,
                lambda record: record['path'].startswith('lib/screens/')
                and record['candidate_action'] in {'phase1_remove_candidate', 'phase3_feature_cleanup'},
            ),
        ),
        '',
        '### Route-Orphan Pages',
        '',
        format_table(
            ['Path', 'Status', 'Action'],
            focus_group_rows(
                records,
                lambda record: record['path'].startswith('lib/')
                and (
                    record['path'].endswith('_page.dart')
                    or '/pages/' in record['path']
                    or '/screens/' in record['path']
                )
                and record['usage_status'] in {'unreferenced', 'tooling_only', 'doc_only'},
            ),
        ),
        '',
        '### Edge Function Mismatches',
        '',
        format_table(
            ['Type', 'Value'],
            [[
                'Unreferenced function directories',
                '`' + '`, `'.join(summary['unreferenced_function_dirs'][:20]) + '`'
                if summary['unreferenced_function_dirs']
                else '_none_',
            ], [
                'Missing referenced functions',
                '`' + '`, `'.join(summary['missing_function_refs'][:20]) + '`'
                if summary['missing_function_refs']
                else '_none_',
            ]],
        ),
        '',
        '### Pubspec Asset Mismatches',
        '',
        format_table(
            ['Type', 'Value'],
            [[
                'Undeclared top-level asset directories',
                '`' + '`, `'.join(summary['undeclared_asset_top_levels']) + '`'
                if summary['undeclared_asset_top_levels']
                else '_none_',
            ], [
                'Declared asset directories with zero runtime refs',
                '`' + '`, `'.join(summary['declared_asset_dirs_without_runtime_refs'][:20]) + '`'
                if summary['declared_asset_dirs_without_runtime_refs']
                else '_none_',
            ]],
        ),
        '',
        '### Archive Docs Drift',
        '',
        format_table(
            ['Path', 'Status', 'Action'],
            focus_group_rows(
                records,
                lambda record: record['path'].startswith('docs/')
                and 'archive_doc' in record['notes'],
            ),
        ),
        '',
    ]
    return '\n'.join(lines)


def generate_manifest(records: list[dict[str, object]], summary: dict[str, object]) -> str:
    payload = {
        'meta': summary,
        'files': records,
    }
    return json.dumps(payload, ensure_ascii=True, indent=2, sort_keys=True) + '\n'


def rendered_outputs() -> dict[str, str]:
    analysis = build_analysis()
    records = analysis['records']
    summary = analysis['summary']
    return {
        FILE_INVENTORY_PATH: generate_file_inventory(records, summary),
        UNUSED_CANDIDATES_PATH: generate_unused_candidates(records, summary),
        MANIFEST_PATH: generate_manifest(records, summary),
    }


def write_outputs(outputs: dict[str, str]) -> None:
    for relative_path, content in outputs.items():
        target = ROOT / relative_path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(content, encoding='utf-8')


def check_outputs(outputs: dict[str, str]) -> int:
    mismatches = 0
    for relative_path, content in outputs.items():
        target = ROOT / relative_path
        existing = target.read_text(encoding='utf-8') if target.exists() else None
        if existing == content:
            continue
        mismatches += 1
        print(f'Inventory drift detected: {relative_path}', file=sys.stderr)
        if existing is None:
            print('  file is missing', file=sys.stderr)
            continue
        diff = difflib.unified_diff(
            existing.splitlines(),
            content.splitlines(),
            fromfile=f'a/{relative_path}',
            tofile=f'b/{relative_path}',
            lineterm='',
        )
        for line in list(diff)[:40]:
            print(line, file=sys.stderr)
    if mismatches:
        print(
            "Remediation: run `npm run repo:sync` (or `python3 scripts/source_inventory.py generate`) and commit the regenerated outputs.",
            file=sys.stderr,
        )
    return 1 if mismatches else 0


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description='Generate source inventory outputs.')
    parser.add_argument('mode', choices=('generate', 'check'))
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    outputs = rendered_outputs()
    if args.mode == 'generate':
        write_outputs(outputs)
        print('Generated inventory outputs:')
        for path in outputs:
            print(f'  - {path}')
        return 0
    return check_outputs(outputs)


if __name__ == '__main__':
    raise SystemExit(main())

# Publishing Checklist

Use this checklist before every pub.dev release. Cursor rule: `.cursor/rules/publishing.mdc`.

## 1. Version & changelog

- [ ] Bump `version` in `pubspec.yaml`
- [ ] Add new section at top of `CHANGELOG.md` with date and changes

## 2. README

- [ ] Installation example shows the new version (`prayer_timetable: ^x.y.z`)
- [ ] Timezone examples use `package:timezone/data/latest_all.dart` (full IANA database)

## 3. Lint & typecheck

```bash
dart analyze
dart pub publish --dry-run
```

- [ ] `dart analyze` — no issues
- [ ] `dart pub publish --dry-run` — passes (no errors)

Optional:

```bash
dart run test/edge_cases.dart
```

## 4. Git

- [ ] All changes committed
- [ ] Pushed to `origin/master` (or release branch)

```bash
git status
git push origin master
```

## 5. Publish

```bash
dart pub publish --force
```

## Version sync check

```bash
VERSION=$(grep '^version:' pubspec.yaml | awk '{print $2}')
grep "prayer_timetable: ^$VERSION" README.md
head -5 CHANGELOG.md | grep "$VERSION"
```

Current package version: see `pubspec.yaml`.

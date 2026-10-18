# Issue tracker

GitHub Issues on `BHarper77/klbdesigns`. Use `gh` CLI.

## Parent / child

Native sub-issues. API takes the child's database `id`, not its number:

```sh
id=$(gh api repos/BHarper77/klbdesigns/issues/<child> -q .id)
gh api -X POST repos/BHarper77/klbdesigns/issues/<parent>/sub_issues -F sub_issue_id=$id
```

List children:

```sh
gh api repos/BHarper77/klbdesigns/issues/<parent>/sub_issues
```

## Claiming

Assign the issue to the dev driving the work (`gh issue edit <n> --add-assignee BHarper77`) before starting. Open + unassigned = unclaimed.

## Blocking

Record both ways:

1. `## Blocked by` section in the issue body, one `- #<n>` per blocker
2. Native dependency:

```sh
id=$(gh api repos/BHarper77/klbdesigns/issues/<blocker> -q .id)
gh api -X POST repos/BHarper77/klbdesigns/issues/<blocked>/dependencies/blocked_by -F issue_id=$id
```

Unblocked when every blocker is closed.

## Frontier query

Open, unassigned children of the parent whose blockers are all closed:

```sh
gh api repos/BHarper77/klbdesigns/issues/<parent>/sub_issues \
  -q '.[] | select(.state=="open" and (.assignees|length)==0) | .number' |
while read n; do
  open=$(gh api repos/BHarper77/klbdesigns/issues/$n/dependencies/blocked_by -q '[.[] | select(.state=="open")] | length')
  if [ "$open" = 0 ]; then gh issue view $n --json number,title -q '"#\(.number) \(.title)"'; fi
done
```

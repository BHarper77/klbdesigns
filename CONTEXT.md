# KLB Designs

## Language

**Share status**:
Per-platform state of an entry's outward share: `Off`, `Share` (editor-set; approval), `Shared`, `Failed` (system-set).
_Avoid_: approved flag, sync state

**Share**:
One-shot push of an entry's media to a platform. Once shared, the platform owns it; edits in Contentful don't propagate.
_Avoid_: sync, mirror

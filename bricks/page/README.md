# page brick

Generate a standalone `FilamentPage` that lives in the panel sidebar
(outside any resource).

```bash
mason make page --name Pengaturan --title "Pengaturan" --icon settings
```

Auto-registers into `adminPanel` in
`lib/core/filament/panel_config.dart`. Route becomes `/admin/<slug>`.
